import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../entities/movement.dart';

/// T-79 · Quien opera con cuenta (T-79a 3.3). El rol y el nombre salen de
/// `authorized/{uid}`, que escribe Carlos en la consola; nunca de lo que diga
/// el cliente. La app no tiene registro: las cuentas las crea Carlos.
class Operator extends Equatable {
  final String uid;
  final String name;
  final OperatorRole role;

  /// Falso si la cuenta no está en la lista de autorizados o está inactiva.
  /// Sus movimientos se registran y esperan; no se rechazan (T-79a 4.5).
  final bool authorized;

  /// Rol y nombre de la copia local, porque no se pudo leer la lista (sin
  /// red). Así el muelle arranca sin conexión con el último operador.
  final bool cached;

  const Operator({
    required this.uid,
    required this.name,
    required this.role,
    this.authorized = true,
    this.cached = false,
  });

  MovementAuthor get author => MovementAuthor(uid: uid, name: name, role: role);

  @override
  List<Object?> get props => [uid, name, role, authorized, cached];

  Map<String, dynamic> toJson() =>
      {'uid': uid, 'name': name, 'role': role.name, 'authorized': authorized};

  factory Operator.fromJson(Map<String, dynamic> json) => Operator(
        uid: json['uid'] as String,
        name: json['name'] as String,
        role: OperatorRole.values.firstWhere((r) => r.name == json['role'],
            orElse: () => OperatorRole.dock),
        authorized: json['authorized'] as bool? ?? false,
        cached: true,
      );
}

abstract class SessionRepository {
  /// Falso en una compilación sin Firebase: la app sigue en el modo de un
  /// solo dispositivo y no ofrece iniciar sesión.
  bool get supportsAccounts;

  /// Emite el operador actual al suscribirse y en cada cambio; null sin
  /// sesión. Incluye el último operador conocido cuando no hay red.
  Stream<Operator?> watchOperator();
  Operator? get current;

  Future<Either<Failure, Operator>> signIn(String email, String password);
  Future<Either<Failure, void>> signOut();
  Future<Either<Failure, void>> sendPasswordReset(String email);

  /// Pregunta al servidor si la sesión sigue valiendo. Si la cuenta se
  /// deshabilitó, cierra la sesión; los movimientos pendientes esperan.
  Future<void> verify();

  Future<void> dispose();
}
