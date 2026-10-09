import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_ce/hive.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/movement.dart';
import '../../domain/repositories/session_repository.dart';

/// Copia local del último operador, para arrancar sin red (T-79a 3.3).
/// Guarda uid, nombre y rol; nunca el correo ni la contraseña.
abstract class LastOperatorStore {
  Operator? read();
  Future<void> write(Operator? operator);
}

class HiveLastOperatorStore implements LastOperatorStore {
  final Box<String> _box;
  HiveLastOperatorStore._(this._box);

  /// Mismo directorio y motor que la bitácora; en Web, IndexedDB del origen.
  static Future<HiveLastOperatorStore> open(
          {required String? directory, String namespace = 'baystream'}) async =>
      HiveLastOperatorStore._(
          await Hive.openBox<String>('${namespace}_session', path: directory));

  @override
  Operator? read() {
    final text = _box.get('lastOperator');
    if (text == null) return null;
    try {
      return Operator.fromJson(jsonDecode(text) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> write(Operator? operator) async {
    if (operator == null) {
      await _box.delete('lastOperator');
    } else {
      await _box.put('lastOperator', jsonEncode(operator.toJson()));
    }
    await _box.flush();
  }
}

/// T-79 · Firebase Auth con correo y contraseña, y el rol de la lista de
/// autorizados. Sin registro: las cuentas las crea Carlos en la consola.
class FirebaseSessionRepository implements SessionRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _db;
  final LastOperatorStore _store;
  final _changes = StreamController<Operator?>.broadcast();
  Operator? _current;
  StreamSubscription<User?>? _users;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _authorized;

  FirebaseSessionRepository(this._auth, this._db, this._store) {
    final user = _auth.currentUser;
    final cached = _store.read();
    if (user != null) {
      _current = cached?.uid == user.uid ? cached : _unknown(user.uid);
    }
    _users = _auth.authStateChanges().listen(_onUser);
  }

  @override
  bool get supportsAccounts => true;

  @override
  Operator? get current => _current;

  @override
  Stream<Operator?> watchOperator() async* {
    yield _current;
    yield* _changes.stream;
  }

  /// Con sesión pero sin haber leído nunca la lista: no se sabe el rol, así
  /// que no se envía nada hasta leerla.
  static Operator _unknown(String uid) => Operator(
      uid: uid, name: 'Cuenta sin comprobar', role: OperatorRole.dock,
      authorized: false, cached: true);

  void _set(Operator? operator) {
    if (operator == _current) return;
    _current = operator;
    _changes.add(operator);
  }

  void _onUser(User? user) {
    unawaited(_authorized?.cancel());
    _authorized = null;
    if (user == null) {
      _set(null);
      return;
    }
    if (_current?.uid != user.uid) {
      final cached = _store.read();
      _set(cached?.uid == user.uid ? cached : _unknown(user.uid));
    }
    // En tiempo real: si Carlos pone `active` en falso o en verdadero, el
    // motor pausa o reanuda sin reiniciar la app (C5).
    _authorized = _db.collection('authorized').doc(user.uid).snapshots().listen(
      (snapshot) {
        // Sin red y sin copia en caché, Firestore dice «no existe»: no es
        // una baja, así que se conserva lo que se sabía.
        if (!snapshot.exists && snapshot.metadata.isFromCache) return;
        final operator = _fromDocument(user.uid, snapshot.data());
        unawaited(_store.write(operator));
        _set(operator);
      },
      onError: (Object _) {},
    );
  }

  Operator _fromDocument(String uid, Map<String, dynamic>? data) {
    if (data == null) {
      return Operator(
          uid: uid,
          name: _current?.name ?? 'Cuenta no autorizada',
          role: _current?.role ?? OperatorRole.dock,
          authorized: false);
    }
    return Operator(
      uid: uid,
      name: (data['name'] as String?)?.trim().isNotEmpty == true
          ? (data['name'] as String).trim()
          : 'Sin nombre',
      role: data['role'] == 'office' ? OperatorRole.office : OperatorRole.dock,
      authorized: data['active'] == true &&
          (data['role'] == 'office' || data['role'] == 'dock'),
    );
  }

  @override
  Future<Either<Failure, Operator>> signIn(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
          email: email.trim(), password: password);
      final uid = credential.user!.uid;
      Map<String, dynamic>? data;
      try {
        data = (await _db.collection('authorized').doc(uid).get()).data();
      } on FirebaseException {
        data = null;
      }
      final operator = _fromDocument(uid, data);
      await _store.write(operator);
      _set(operator);
      return Right(operator);
    } on FirebaseAuthException catch (error) {
      return Left(ServerFailure(code: error.code, message: signInMessage(error.code)));
    } catch (_) {
      return const Left(ServerFailure(
          code: 'unknown', message: 'No se pudo iniciar sesión. Inténtalo de nuevo.'));
    }
  }

  static String signInMessage(String code) => switch (code) {
        'invalid-credential' ||
        'wrong-password' ||
        'user-not-found' ||
        'invalid-login-credentials' =>
          'Correo o contraseña incorrectos.',
        'invalid-email' => 'El correo no es válido.',
        'user-disabled' => 'Esta cuenta está deshabilitada. Habla con el responsable.',
        'too-many-requests' => 'Demasiados intentos. Espera un momento.',
        'network-request-failed' => 'Sin conexión: iniciar sesión requiere red.',
        _ => 'No se pudo iniciar sesión ($code).',
      };

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _auth.signOut();
      _set(null);
      return const Right(null);
    } catch (_) {
      return const Left(
          ServerFailure(code: 'sign_out', message: 'No se pudo cerrar la sesión.'));
    }
  }

  @override
  Future<Either<Failure, void>> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return const Right(null);
    } on FirebaseAuthException catch (error) {
      return Left(ServerFailure(
          code: error.code,
          message: error.code == 'invalid-email'
              ? 'El correo no es válido.'
              : 'No se pudo enviar el correo (${error.code}).'));
    }
  }

  @override
  Future<void> verify() async {
    try {
      await _auth.currentUser?.reload();
    } on FirebaseAuthException catch (error) {
      if (const {'user-disabled', 'user-not-found', 'user-token-expired'}
          .contains(error.code)) {
        await signOut();
      }
    } catch (_) {
      // Sin red no se puede comprobar; se queda como está.
    }
  }

  @override
  Future<void> dispose() async {
    await _users?.cancel();
    await _authorized?.cancel();
    await _changes.close();
  }
}
