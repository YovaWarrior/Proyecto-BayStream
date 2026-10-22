import 'dart:async';

import 'package:baystream/core/errors/failures.dart';
import 'package:baystream/features/vessel/data/repositories/firestore_operation_sync.dart';
import 'package:baystream/features/vessel/data/repositories/sync_engine.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/repositories/session_repository.dart';
import 'package:baystream/features/vessel/domain/services/discharge_progress.dart';
import 'package:dartz/dartz.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/t75_memory_log.dart';
import '../support/t82_fixture.dart';

/// T-116 · RF-032: dos clientes comparten un único servidor en memoria.
/// Este falso NO evalúa las reglas de seguridad reales de Firestore: esas
/// tienen su propia batería en el emulador (tool/t113_*).
///
/// El envío se invoca explícitamente mediante FirestoreRemoteMovementStore;
/// aquí se comprueban publicación, unión y recepción por stream, no la cola
/// de SyncEngine (ya probada en t79_sync_engine_test.dart), ni latencia de red.
void main() {
  const cuentaOficina = Operator(
    uid: 'curso-oficina',
    name: 'Oficina sintética',
    role: OperatorRole.office,
  );
  const cuentaMuelle = Operator(
    uid: 'curso-muelle',
    name: 'Muelle sintético',
    role: OperatorRole.dock,
  );
  late FakeFirebaseFirestore servidor;
  late T75MemoryLog bitacoraOficina;
  late T75MemoryLog bitacoraMuelle;
  late FirestoreOperationSync oficina;
  late FirestoreOperationSync muelle;
  final perfil = VesselProfile.proposeFrom(t82Loading);

  setUp(() async {
    servidor = FakeFirebaseFirestore();
    bitacoraOficina = T75MemoryLog();
    bitacoraMuelle = T75MemoryLog();
    oficina = FirestoreOperationSync(
      servidor,
      bitacoraOficina,
      _SesionFalsa(cuentaOficina),
    );
    muelle = FirestoreOperationSync(
      servidor,
      bitacoraMuelle,
      _SesionFalsa(cuentaMuelle),
    );
    addTearDown(oficina.dispose);
    addTearDown(muelle.dispose);
    addTearDown(bitacoraOficina.close);
    addTearDown(bitacoraMuelle.close);
    for (final cuenta in [cuentaOficina, cuentaMuelle]) {
      await servidor.collection('authorized').doc(cuenta.uid).set({
        'active': true,
        'name': cuenta.name,
        'role': cuenta.role.name,
      });
    }
  });

  group('RF-032: la oficina y el muelle ven la misma operación', () {
    test('publica, se une y recibe una descarga por la escucha remota',
        () async {
      // Arrange
      final receptorOficina = FirestoreRemoteMovementStore(servidor);
      final emisorMuelle = FirestoreRemoteMovementStore(servidor);
      final escucha = StreamIterator(receptorOficina.watch(t82Operation.id));
      addTearDown(escucha.cancel);
      await escucha.moveNext().timeout(const Duration(seconds: 5));
      expect(escucha.current.movements, isEmpty);
      expect(
          t82Derive().discharge.markOf('TSTU0000110'), DischargeMark.pending);

      // Act
      final publicada = _valor(await oficina.publish(t82Operation, perfil));
      final recibida = _valor(await muelle.join(publicada.id));
      final registro = _valor(await bitacoraMuelle.append(
        MovementDraft.discharge(recibida.id, 'TSTU0000110', '0030984'),
        cuentaMuelle.author,
      ));
      await emisorMuelle.put(registro.movement);
      final llego =
          await escucha.moveNext().timeout(const Duration(seconds: 5));

      // Assert
      expect(publicada.published, isTrue);
      expect(recibida.published, isTrue);
      expect(recibida.id, publicada.id);
      expect(recibida.vesselName, publicada.vesselName);
      expect(recibida.voyageNumber, publicada.voyageNumber);
      expect(recibida.portOfCall, publicada.portOfCall);
      expect(recibida.sources, publicada.sources);
      expect(recibida.profile, publicada.profile);
      expect(bitacoraOficina.operations, [publicada]);
      expect(bitacoraMuelle.operations, [recibida]);
      expect(llego, isTrue);
      final movimiento = escucha.current.movements.single;
      expect(movimiento.id, registro.movement.id);
      expect(movimiento.operationId, publicada.id);
      expect(movimiento.type, MovementType.discharge);
      expect(movimiento.target, 'C:TSTU0000110');
      expect(movimiento.position, '0030984');
      expect(movimiento.payload, registro.movement.payload);
      expect(movimiento.author, cuentaMuelle.author);
      expect(movimiento.receivedAt, isNotNull);
      final estadoOficina = t82Derive([movimiento]).discharge;
      final estadoMuelle = t82Derive(
        bitacoraMuelle.of(recibida.id).map((r) => r.movement),
      ).discharge;
      expect(estadoOficina.markOf('TSTU0000110'), DischargeMark.discharged);
      expect(estadoOficina.markOf('TSTU0000110'),
          estadoMuelle.markOf('TSTU0000110'));
      expect(await receptorOficina.authorizationOf(cuentaOficina.uid),
          RemoteAuthorization.active);
      expect(await emisorMuelle.authorizationOf(cuentaMuelle.uid),
          RemoteAuthorization.active);
    });

    test('sin sesión publicar falla con no_session y no escribe', () async {
      // Arrange
      final sinSesion = FirestoreOperationSync(
        servidor,
        bitacoraOficina,
        _SesionFalsa(null),
      );
      addTearDown(sinSesion.dispose);

      // Act
      final resultado = await sinSesion.publish(t82Operation, perfil);

      // Assert
      expect(resultado.isLeft(), isTrue);
      expect(resultado.fold((fallo) => fallo.code, (_) => null), 'no_session');
      expect((await servidor.collection('operations').get()).docs, isEmpty);
      expect(bitacoraOficina.operations, isEmpty);
    });

    test('el muelle no publica: falla con not_office y no escribe', () async {
      // Arrange
      final operacion = t82Operation;

      // Act
      final resultado = await muelle.publish(operacion, perfil);

      // Assert
      expect(resultado.isLeft(), isTrue);
      expect(resultado.fold((fallo) => fallo.code, (_) => null), 'not_office');
      expect((await servidor.collection('operations').get()).docs, isEmpty);
      expect(bitacoraMuelle.operations, isEmpty);
    });
  });
}

T _valor<T>(Either<Failure, T> resultado) =>
    resultado.fold((fallo) => fail(fallo.message), (valor) => valor);

/// Identidad inyectada; nunca abre Firebase Auth ni almacenes del equipo.
class _SesionFalsa implements SessionRepository {
  _SesionFalsa(this.current);

  @override
  final Operator? current;

  @override
  bool get supportsAccounts => true;

  @override
  Stream<Operator?> watchOperator() => Stream.value(current);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
