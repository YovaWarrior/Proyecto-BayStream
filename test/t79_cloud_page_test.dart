import 'dart:async';

import 'package:baystream/core/errors/failures.dart';
import 'package:baystream/features/vessel/data/repositories/local_only_operation_sync.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/repositories/operation_sync_repository.dart';
import 'package:baystream/features/vessel/domain/repositories/session_repository.dart';
import 'package:baystream/features/vessel/presentation/pages/cloud_page.dart';
import 'package:baystream/features/vessel/presentation/providers/movement_log_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/sync_providers.dart';
import 'package:baystream/features/vessel/presentation/widgets/sync_status_chip.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/t75_memory_log.dart';

/// T-79 · La cuenta y el estado de envío en pantalla, a 360 dp y en los dos
/// temas. Sin registro: las cuentas las crea el responsable.
class _Session implements SessionRepository {
  final _changes = StreamController<Operator?>.broadcast();
  Operator? _current;
  String? lastEmail;

  @override
  bool get supportsAccounts => true;
  @override
  Operator? get current => _current;
  @override
  Stream<Operator?> watchOperator() async* {
    yield _current;
    yield* _changes.stream;
  }

  @override
  Future<Either<Failure, Operator>> signIn(String email, String password) async {
    lastEmail = email;
    if (password != 'correcta') {
      return const Left(ServerFailure(message: 'Correo o contraseña incorrectos.'));
    }
    _current = const Operator(uid: 'u1', name: 'Tarjador 1', role: OperatorRole.dock);
    _changes.add(_current);
    return Right(_current!);
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    _current = null;
    _changes.add(null);
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> sendPasswordReset(String email) async => const Right(null);
  @override
  Future<void> verify() async {}
  @override
  Future<void> dispose() async {}
}

Widget _app(Widget child, {Brightness brightness = Brightness.light, List overrides = const []}) =>
    ProviderScope(
      overrides: [...overrides],
      child: MaterialApp(
        theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF0D47A1), brightness: brightness)),
        home: child,
      ),
    );

void main() {
  Future<void> narrow(WidgetTester tester) async {
    tester.view.physicalSize = const Size(720, 1600);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
  }

  testWidgets('sin la nube configurada lo dice, y no ofrece registro', (tester) async {
    await narrow(tester);
    await tester.pumpWidget(_app(const CloudPage()));
    await tester.pumpAndSettle();
    expect(find.textContaining('no tiene la nube configurada'), findsOneWidget);
    expect(find.textContaining('Regist'), findsNothing);
    expect(find.byKey(const ValueKey('sign-in-button')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  for (final brightness in Brightness.values) {
    testWidgets('iniciar sesión sin registro, a 360 dp en tema ${brightness.name}',
        (tester) async {
      await narrow(tester);
      final session = _Session();
      await tester.pumpWidget(_app(const CloudPage(), brightness: brightness, overrides: [
        sessionRepositoryProvider.overrideWith((ref) async => session),
        operationSyncProvider
            .overrideWith((ref) async => const LocalOnlyOperationSync()),
        movementLogRepositoryProvider.overrideWith((ref) async => T75MemoryLog()),
      ]));
      await tester.pumpAndSettle();
      expect(find.text('Correo'), findsOneWidget);
      expect(find.text('Contraseña'), findsOneWidget);
      expect(find.text('Olvidé mi contraseña'), findsOneWidget);
      expect(find.textContaining('Regist'), findsNothing,
          reason: 'la app no tiene registro abierto');

      await tester.enterText(find.byKey(const ValueKey('sign-in-email')), 'muelle@ejemplo.test');
      await tester.enterText(find.byKey(const ValueKey('sign-in-password')), 'mala');
      await tester.tap(find.byKey(const ValueKey('sign-in-button')));
      await tester.pumpAndSettle();
      expect(find.text('Correo o contraseña incorrectos.'), findsOneWidget);

      await tester.enterText(find.byKey(const ValueKey('sign-in-password')), 'correcta');
      await tester.tap(find.byKey(const ValueKey('sign-in-button')));
      await tester.pumpAndSettle();
      expect(find.text('Tarjador 1 · Muelle'), findsOneWidget);
      expect(find.text('Cuenta autorizada'), findsOneWidget);
      expect(find.text('No hay operaciones abiertas.'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.tap(find.byKey(const ValueKey('sign-out-button')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('sign-in-button')), findsOneWidget);
    });
  }

  test('el texto del estado dice cuántos y qué hacer', () {
    expect(syncStatusText(SyncStatus.local), 'Solo este dispositivo');
    expect(syncStatusText(const SyncStatus(SyncState.upToDate)), 'Al día');
    expect(syncStatusText(const SyncStatus(SyncState.sending, pending: 3)), 'Enviando 3');
    expect(syncStatusText(const SyncStatus(SyncState.offline, pending: 2)),
        'Sin conexión · 2 por enviar');
    expect(syncStatusText(const SyncStatus(SyncState.sessionExpired, pending: 4)),
        'Sesión vencida: inicia sesión para enviar 4');
    expect(syncStatusText(const SyncStatus(SyncState.notAuthorized, pending: 1)),
        'Tu cuenta no está autorizada · 1 espera');
    expect(
        syncStatusText(SyncStatus(SyncState.unconfirmed,
            pending: 1, since: DateTime(2026, 10, 9, 14, 5))),
        'Sin confirmar desde las 14:05 · inicia sesión de nuevo');
    expect(
        syncStatusText(const SyncStatus(SyncState.upToDate,
            rejected: 1, otherAuthor: 2, localOnly: 7, closed: true)),
        'Al día · 1 rechazado · 2 de otra cuenta esperan a su autor · '
        '7 movimientos sin cuenta: solo aquí · operación cerrada');
  });

  for (final brightness in Brightness.values) {
    testWidgets('el chip se lee a 360 dp sin desbordar, tema ${brightness.name}',
        (tester) async {
      await narrow(tester);
      const states = [
        SyncStatus(SyncState.sessionExpired, pending: 12, rejected: 3, localOnly: 9),
        SyncStatus(SyncState.unconfirmed, pending: 1),
        SyncStatus(SyncState.upToDate),
      ];
      for (final status in states) {
        final shown = status.state == SyncState.unconfirmed
            ? SyncStatus(SyncState.unconfirmed, pending: 1, since: DateTime(2026, 10, 9, 9, 7))
            : status;
        await tester.pumpWidget(const SizedBox());
        await tester.pumpWidget(_app(
            const Scaffold(body: Wrap(children: [SyncStatusChip()])),
            brightness: brightness,
            overrides: [syncStatusProvider.overrideWith((ref) => Stream.value(shown))]));
        await tester.pumpAndSettle();
        expect(find.text(syncStatusText(shown)), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    });
  }
}
