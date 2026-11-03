import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:baystream/core/errors/failures.dart';
import 'package:baystream/features/vessel/data/datasources/hive_movement_data_source.dart';
import 'package:baystream/features/vessel/data/repositories/movement_log_repository_impl.dart';
import 'package:baystream/features/vessel/data/repositories/source_revisions.dart';
import 'package:baystream/features/vessel/data/repositories/sync_engine.dart';
import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/repositories/operation_sync_repository.dart';
import 'package:baystream/features/vessel/domain/repositories/session_repository.dart';
import 'package:baystream/features/vessel/domain/services/departure_baplie_writer.dart';
import 'package:baystream/features/vessel/domain/services/loading_operation.dart';
import 'package:baystream/features/vessel/domain/services/operation_sources.dart';
import 'package:baystream/features/vessel/presentation/providers/plan_attach_provider.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/t75_memory_log.dart';
import 'support/t79_fake_cloud.dart';
import 'support/t82_fixture.dart';

/// T-130 (10.85, 10.90) · La operación publicada acepta el plan que le falta:
/// el dominio y el transporte (el viaje que declara una fuente, la búsqueda
/// de la oficina, `save` con confirmación), el motor que baja el BAPLIE
/// agregado con los movimientos intactos (contra la nube falsa de T-79 sobre
/// la bitácora real en Hive, en una carpeta temporal por prueba), unirse con
/// las tres fuentes, y la propiedad: el estado y el BAPLIE de salida con el
/// plan agregado después son los mismos que con los dos planos publicados
/// juntos.
void main() {
  const dock = Operator(uid: 'uid-muelle', name: 'Tarjador 1', role: OperatorRole.dock);
  const operationId = '3f6a9c21-7b4d-4e8f-9a1c-2d5e8f0b4c73';
  late Directory directory;
  late String namespace;
  late DateTime now;
  DateTime clock() => now;

  // Los planos sintéticos de T-82 (BUQUE PRUEBA, viaje VTEST, escala GTSTC): la
  // llegada descarga TSTU0000110 en 0030984; el plan de carga sube
  // TSTU0000014 a 0030282 y trae una reserva en 0030984. La copia del plan
  // de carga con otro viaje solo cambia el TDT (el archivo real no se toca).
  final loadingOtherVoyageEdi =
      t82LoadingEdi.replaceFirst('TDT+20+VTEST+', 'TDT+20+VTESTN+');
  final loadingOtherVoyage = BaplieParserService()
      .parse(loadingOtherVoyageEdi)
      .copyWith(portOfCall: 'GTSTC');
  const arrivalSource = OperationSource(
      kind: OperationSourceKind.arrivalBaplie,
      fileName: 'llegada.edi',
      content: t82ArrivalEdi);
  const loadingSource = OperationSource(
      kind: OperationSourceKind.loadingBaplie,
      fileName: 'carga.edi',
      content: t82LoadingEdi);
  Operation published(
          {Iterable<OperationSource> sources = const [arrivalSource],
          String id = operationId,
          DateTime? closedAt,
          bool isPublished = true}) =>
      Operation(
        id: id,
        vesselName: 'BUQUE PRUEBA',
        voyageNumber: 'VTEST',
        portOfCall: 'GTSTC',
        createdAt: DateTime.utc(2026, 11, 1, 14, 5),
        sources: sources,
        published: isPublished,
        closedAt: closedAt,
      );
  PublishedOperation remote(Operation o, {DateTime? createdAt}) =>
      PublishedOperation(
          id: o.id,
          vesselName: o.vesselName,
          voyageNumber: o.voyageNumber,
          portOfCall: o.portOfCall,
          createdAt: createdAt ?? DateTime.utc(2026, 11, 1, 20, 5),
          sources: [for (final s in o.sources) s.kind]);

  Future<MovementLogRepositoryImpl> open() async => MovementLogRepositoryImpl(
      await HiveMovementDataSource.open(
          directory: directory.path, namespace: namespace),
      clock: () {
        now = now.add(const Duration(seconds: 1));
        return now;
      });
  Future<Operation?> local(MovementLogRepositoryImpl log) async =>
      (await log.getOperation(operationId)).getOrElse(() => null);
  Future<List<MovementRecord>> records(MovementLogRepositoryImpl log) async =>
      (await log.records(operationId)).getOrElse(() => const []);

  /// Espera a que la cola y Hive terminen: son escrituras de disco reales.
  Future<void> until(Future<bool> Function() condition) async {
    for (var i = 0; i < 300; i++) {
      if (await condition()) return;
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
    fail('No se cumplió a tiempo');
  }

  Future<void> settle() => Future<void>.delayed(const Duration(milliseconds: 80));

  SyncEngine engine(MovementLogRepositoryImpl log, FakeCloud cloud, Operation operation,
          {OwnSourceWrites? ownWrites}) =>
      SyncEngine(
          log: log,
          remote: cloud,
          operation: operation,
          clock: clock,
          tick: const Duration(hours: 1),
          ownWrites: ownWrites);

  LoadingOperation derive(Operation operation, Iterable<Movement> movements) {
    VesselVoyage? parse(OperationSourceKind kind) {
      final source = operation.source(kind);
      return source == null
          ? null
          : BaplieParserService().parse(source.content).copyWith(portOfCall: 'GTSTC');
    }

    final listSource = operation.source(OperationSourceKind.exportList);
    return LoadingOperation.build(
        operationId: operation.id,
        arrival: parse(OperationSourceKind.arrivalBaplie),
        loading: parse(OperationSourceKind.loadingBaplie)!,
        list: listSource == null
            ? null
            : ExportList.fromJson(jsonDecode(listSource.content) as Map<String, dynamic>),
        movements: movements);
  }

  // Un movimiento de otro dispositivo, que el servidor hace llegar.
  final fromOther = Movement(
    id: '9b2e4d61-5c7f-4a0b-8d3e-1f6a2c9b7e40',
    operationId: operationId,
    type: MovementType.discharge,
    target: 'C:TSTU0000110',
    payload: const {'position': '0030984', 'restow': false},
    author: const MovementAuthor(uid: 'uid-otro', name: 'Tarjador 2', role: OperatorRole.dock),
    deviceId: 'otro-dispositivo',
    sequence: 1,
    createdAt: DateTime.utc(2026, 11, 2, 8, 30),
  );

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('t130_plan_');
    namespace = 't130_${DateTime.now().microsecondsSinceEpoch}';
    now = DateTime.utc(2026, 11, 2, 8);
  });

  tearDown(() async {
    if (directory.existsSync()) await directory.delete(recursive: true);
  });

  group('el dominio: el viaje que declara una fuente', () {
    test('OperationSource.voyage va y vuelve en JSON, ausente si es nulo, y una fuente guardada antes se lee sin él',
        () {
      const source = OperationSource(
          kind: OperationSourceKind.loadingBaplie,
          fileName: 'carga.edi',
          content: 'UNB+A',
          voyage: 'VTESTN');
      final back = OperationSource.fromJson(
          jsonDecode(jsonEncode(source.toJson())) as Map<String, dynamic>);
      expect(back, source);
      expect(back.voyage, 'VTESTN');
      expect(loadingSource.toJson().containsKey('voyage'), isFalse);
      final old = OperationSource.fromJson(
          {'kind': 'loading_baplie', 'fileName': 'c.edi', 'content': 'UNB+A'});
      expect(old.voyage, isNull);
      expect(source.withVoyage(null).voyage, isNull);
      expect(loadingSource.withVoyage('VTESTN').voyage, 'VTESTN');
      expect(source.withRevision(2).voyage, 'VTESTN');
      // La operación conserva su viaje y relaciona el de la fuente.
      final operation = published(sources: [arrivalSource, source]);
      expect(operation.voyageNumber, 'VTEST');
      expect(operation.matchesVoyage('VTEST'), isTrue);
      expect(operation.matchesVoyage('VTESTN'), isTrue);
      expect(operation.matchesVoyage('OTRO'), isFalse);
      expect(operation.departureVoyageNumber, 'VTESTN',
          reason: 'el BAPLIE de salida lleva el viaje del plan de carga');
      expect(published().departureVoyageNumber, 'VTEST');
    });

    test('la entrada del manifiesto lleva voyage solo si lo hay, y el manifiesto entero se lee por tipo',
        () {
      final packed = packSource(loadingSource.withVoyage('VTESTN'));
      expect(packed.entry.voyage, 'VTESTN');
      expect(packed.entry.toMap()['voyage'], 'VTESTN');
      expect(packed.entry.toMap().containsKey('revision'), isFalse);
      expect(packed.parts.single.id, 'loading_baplie-0');
      expect(packed.parts.single.toMap().containsKey('revision'), isFalse);
      expect(packSource(arrivalSource).entry.toMap().containsKey('voyage'), isFalse);
      final read = SourceManifestEntry.read(
          OperationSourceKind.loadingBaplie, packed.entry.toMap())!;
      expect(read, packed.entry);

      final manifest = SourceManifest.read({
        'arrival_baplie': packSource(arrivalSource).entry.toMap(),
        'loading_baplie': packed.entry.toMap(),
        'export_list': {'fileName': 'l.xlsx', 'sha256': 'c' * 64, 'parts': 1, 'length': 7, 'revision': 2},
        'otro': {'parts': 'x'},
      });
      expect(manifest.entries.keys, containsAll(OperationSourceKind.values));
      expect(manifest.plans.map((e) => e.kind),
          [OperationSourceKind.arrivalBaplie, OperationSourceKind.loadingBaplie]);
      expect(manifest.exportList!.revision, 2);
      expect(manifest[OperationSourceKind.loadingBaplie]!.voyage, 'VTESTN');
      expect(SourceManifest.read(null), SourceManifest.empty);
      expect(SourceManifest.read({'loading_baplie': {'parts': 'x'}}).plans, isEmpty);
    });

    test('assembleSource arma un BAPLIE agregado con su viaje y no mezcla los trozos de una revisión',
        () {
      final server = FakeServer()
        ..addPlan(OperationSourceKind.arrivalBaplie, t82ArrivalEdi, fileName: 'llegada.edi');
      server.addPlan(OperationSourceKind.loadingBaplie, loadingOtherVoyageEdi,
          fileName: 'carga.edi', voyage: 'VTESTN');
      server.publishList('{"fileName":"l.xlsx","rows":[]}');
      server.reviseList('{"fileName":"l2.xlsx","rows":[]}');
      final manifest = server.manifest;
      final sources = [
        for (final entry in manifest.entries.values)
          assembleSource(entry, server.sourceParts)!
      ];
      expect(sources.map((s) => s.kind), containsAll(OperationSourceKind.values));
      final loading = sources.firstWhere((s) => s.kind == OperationSourceKind.loadingBaplie);
      expect(loading.content, loadingOtherVoyageEdi);
      expect(loading.voyage, 'VTESTN');
      expect(loading.revision, isNull);
      expect(sources.firstWhere((s) => s.kind == OperationSourceKind.arrivalBaplie).voyage, isNull);
      expect(sources.firstWhere((s) => s.kind == OperationSourceKind.exportList).revision, 1);
      expect(server.sourceParts.map((p) => p.id),
          ['arrival_baplie-0', 'loading_baplie-0', 'export_list-0', 'export_list-r1-0']);
    });

    test('find encuentra la operación por su viaje o por el que declara una fuente', () async {
      final log = T75MemoryLog();
      await log.saveOperation(published(
          sources: [arrivalSource, loadingSource.withVoyage('VTESTN')]));
      expect((await OperationSources.find(log, t82Arrival, 'GTSTC'))?.id, operationId);
      expect((await OperationSources.find(log, loadingOtherVoyage, 'GTSTC'))?.id, operationId,
          reason: 'el plan de carga abierto declara VTESTN');
      expect(await OperationSources.find(log, loadingOtherVoyage, 'PAMIT'), isNull);
      final otherVoyage = t82Loading.copyWith(voyageNumber: 'OTRO');
      expect(await OperationSources.find(log, otherVoyage, 'GTSTC'), isNull);
      // publishedAtCall: solo las publicadas y abiertas de ese buque en esa escala.
      await log.saveOperation(published(id: 'local', isPublished: false));
      await log.saveOperation(published(id: 'cerrada', closedAt: DateTime.utc(2026, 11, 2)));
      final atCall = await OperationSources.publishedAtCall(log, 'BUQUE PRUEBA', 'GTSTC');
      expect(atCall.map((o) => o.id), [operationId]);
      expect(await OperationSources.publishedAtCall(log, 'BUQUE PRUEBA', 'PAMIT'), isEmpty);
    });
  });

  group('la búsqueda de la oficina (lookup), con sus cuatro salidas', () {
    final here = published();
    PlanAttachment look(
            {Iterable<Operation> local = const [],
            List<PublishedOperation>? remote,
            OperationSourceKind kind = OperationSourceKind.loadingBaplie,
            String content = t82LoadingEdi}) =>
        OperationSources.lookup(
            local: local,
            remote: remote,
            vesselName: 'BUQUE PRUEBA',
            port: 'GTSTC',
            kind: kind,
            content: content);

    test('ninguna, una aquí a la que le falta el plan, una que ya lo tiene', () {
      expect(look(), isA<NoPublishedOperation>());
      expect(look(remote: const []), isA<NoPublishedOperation>());
      final attachable = look(local: [here], remote: [remote(here)]) as AttachablePlan;
      expect(attachable.operation.id, operationId);
      expect(attachable.publishedAt, DateTime.utc(2026, 11, 1, 20, 5),
          reason: 'la fecha de publicación es la de la nube');
      expect((look(local: [here]) as AttachablePlan).publishedAt, isNull,
          reason: 'sin la nube no hay fecha del servidor');
      final withPlan = published(sources: [arrivalSource, loadingSource]);
      final same = look(local: [withPlan]) as PlanAlreadyThere;
      expect(same.sameContent, isTrue);
      final other = look(local: [withPlan], content: loadingOtherVoyageEdi) as PlanAlreadyThere;
      expect(other.sameContent, isFalse);
      expect(other.source.fileName, 'carga.edi');
      // Otro tipo que sí falta en esa misma operación.
      expect(look(local: [withPlan], kind: OperationSourceKind.exportList),
          isA<AttachablePlan>());
    });

    test('una solo en la nube, varias abiertas, y una copia local que la nube ya no lista', () {
      final cloudOnly = look(remote: [remote(here)]) as PlanInCloudOnly;
      expect(cloudOnly.remote.id, operationId);
      // Dos abiertas de ese buque en esa escala: la app no elige.
      final old = published(id: 'vieja').copyWith();
      final several = look(
          local: [here],
          remote: [
            remote(here),
            PublishedOperation(
                id: 'vieja',
                vesselName: 'BUQUE PRUEBA',
                voyageNumber: 'VOLD',
                portOfCall: 'GTSTC',
                createdAt: DateTime.utc(2026, 10, 5, 9, 12)),
          ]) as SeveralOpenOperations;
      expect(several.candidates.map((c) => c.voyage), ['VOLD', 'VTEST'],
          reason: 'ordenadas por fecha de publicación');
      expect(several.candidates.first.publishedAt, DateTime.utc(2026, 10, 5, 9, 12));
      expect(look(local: [here, old]), isA<SeveralOpenOperations>(),
          reason: 'también con dos locales y sin nube');
      // Con la nube a la vista, una local que la nube no lista está cerrada o
      // retirada y no cuenta; otra escala u otro buque tampoco.
      expect(look(local: [here], remote: const []), isA<NoPublishedOperation>());
      expect(
          look(local: [here], remote: const [
            PublishedOperation(
                id: 'x', vesselName: 'OTRO BUQUE', voyageNumber: 'V', portOfCall: 'GTSTC'),
            PublishedOperation(
                id: 'y', vesselName: 'BUQUE PRUEBA', voyageNumber: 'V', portOfCall: 'PAMIT'),
          ]),
          isA<NoPublishedOperation>());
    });

    test('lookupPlanAttachment reúne la bitácora y la nube, y sin sesión o sin respuesta sigue con lo local',
        () async {
      final log = T75MemoryLog();
      await log.saveOperation(here);
      final sync = _CloudList([remote(here)]);
      final withCloud = await lookupPlanAttachment(
          log: log,
          sync: sync,
          vesselName: 'BUQUE PRUEBA',
          port: 'GTSTC',
          kind: OperationSourceKind.loadingBaplie,
          content: t82LoadingEdi);
      expect((withCloud as AttachablePlan).publishedAt, isNotNull);
      final withoutSession = await lookupPlanAttachment(
          log: log,
          sync: null,
          vesselName: 'BUQUE PRUEBA',
          port: 'GTSTC',
          kind: OperationSourceKind.loadingBaplie,
          content: t82LoadingEdi);
      expect((withoutSession as AttachablePlan).publishedAt, isNull);
      final silent = await lookupPlanAttachment(
          log: log,
          sync: _CloudList.silent(),
          vesselName: 'BUQUE PRUEBA',
          port: 'GTSTC',
          kind: OperationSourceKind.loadingBaplie,
          content: t82LoadingEdi,
          cloudTimeout: const Duration(milliseconds: 50));
      expect((silent as AttachablePlan).publishedAt, isNull,
          reason: 'la nube no respondió a tiempo: solo lo local');
    });

    test('los textos de la búsqueda', () {
      String? texto(PlanAttachment lookup) => textoDeLaBusqueda(lookup,
          vesselName: 'BUQUE PRUEBA', port: 'GTSTC', kind: OperationSourceKind.loadingBaplie);
      expect(texto(const NoPublishedOperation()), isNull);
      expect(texto(AttachablePlan(here)),
          'La escala GTSTC ya tiene una operación publicada (viaje VTEST) sin plan de '
          'carga: confirma para agregarlo.');
      expect(texto(PlanInCloudOnly(remote(here))),
          'La escala GTSTC ya tiene una operación publicada de este buque (viaje VTEST) '
          'que este equipo no tiene. Únete en «Nube y cuenta» y vuelve a abrir el plan '
          'para agregarlo.');
      expect(texto(PlanAlreadyThere(here, loadingSource, sameContent: true)), isNull);
      expect(texto(PlanAlreadyThere(here, loadingSource, sameContent: false)),
          startsWith('La operación publicada de esta escala ya tiene el plan de carga '
              '(«carga.edi») y los BAPLIE de una operación publicada no cambian.'));
      final several = texto(SeveralOpenOperations([
        (voyage: 'VOLD', publishedAt: DateTime.utc(2026, 10, 5, 9, 12)),
        (voyage: 'VTEST', publishedAt: null),
      ]))!;
      expect(several, startsWith('Hay 2 operaciones publicadas y abiertas de BUQUE PRUEBA en GTSTC: viaje VOLD (publicada el '));
      expect(several, contains(') y viaje VTEST. Cierra la que no corresponde desde «Nube y cuenta» y vuelve a abrir el plan.'));
    });
  });

  group('la oficina: OperationSources.save en una operación publicada', () {
    test('el plan que falta sube por addSource solo con la confirmación, y la fuente recuerda el viaje si difiere',
        () async {
      final log = T75MemoryLog();
      await log.saveOperation(published());
      final sync = _RecordingSync(log);
      // Sin confirmación (attachTo), no se agrega solo.
      await expectLater(
          OperationSources.save(log, t82Loading, 'GTSTC', loadingSource, sync: sync),
          throwsA(isA<ValidationFailure>().having(
              (f) => f.message, 'message', contains('acepta «Agregar a la operación»'))));
      expect(sync.added, isEmpty);
      // Con confirmación y el mismo viaje: sin voyage.
      final updated = await OperationSources.save(
          log, t82Loading, 'GTSTC', loadingSource,
          sync: sync, attachTo: published());
      expect(sync.added.single.voyage, isNull);
      expect(updated.source(OperationSourceKind.loadingBaplie)!.content, t82LoadingEdi);
      expect(updated.source(OperationSourceKind.arrivalBaplie), arrivalSource);
      expect(log.operations.single.sources, hasLength(2));
      // Volver a abrir el mismo plan no sube nada.
      final same = await OperationSources.save(log, t82Loading, 'GTSTC', loadingSource, sync: sync);
      expect(same.sources, hasLength(2));
      expect(sync.added, hasLength(1));
      // Otro texto del mismo tipo: los BAPLIE no cambian.
      final otherText = loadingSource.withVoyage(null);
      await expectLater(
          OperationSources.save(
              log,
              t82Loading,
              'GTSTC',
              OperationSource(
                  kind: otherText.kind, fileName: 'otro.edi', content: '$t82LoadingEdi '),
              sync: sync,
              attachTo: log.operations.single),
          throwsA(isA<ValidationFailure>().having(
              (f) => f.message, 'message', contains('ya tiene el plan de carga («carga.edi»)'))));
      expect(sync.added, hasLength(1));
    });

    test('con otro viaje, la fuente declara el suyo; sin nube o cerrada, no cambia nada', () async {
      final log = T75MemoryLog();
      await log.saveOperation(published());
      final sync = _RecordingSync(log);
      final updated = await OperationSources.save(
          log,
          loadingOtherVoyage,
          'GTSTC',
          const OperationSource(
              kind: OperationSourceKind.loadingBaplie,
              fileName: 'carga_n.edi',
              content: 'UNB+N'),
          sync: sync,
          attachTo: published());
      expect(sync.added.single.voyage, 'VTESTN');
      expect(updated.voyageNumber, 'VTEST', reason: 'la operación conserva su viaje');
      expect(updated.matchesVoyage('VTESTN'), isTrue);

      final log2 = T75MemoryLog();
      await log2.saveOperation(published());
      await expectLater(
          OperationSources.save(log2, t82Loading, 'GTSTC', loadingSource, attachTo: published()),
          throwsA(isA<ValidationFailure>()),
          reason: 'sin la nube no hay por dónde agregar');
      await log2.saveOperation(published().copyWith(closedAt: DateTime.utc(2026, 11, 2)));
      await expectLater(
          OperationSources.save(log2, t82Loading, 'GTSTC', loadingSource,
              sync: _RecordingSync(log2), attachTo: log2.operations.single),
          throwsA(isA<ValidationFailure>()
              .having((f) => f.message, 'message', contains('ya está cerrada'))));
      expect(log2.operations.single.source(OperationSourceKind.loadingBaplie), isNull);
      // Si la nube no acepta, se lanza su fallo y nada local cambia.
      final log3 = T75MemoryLog();
      await log3.saveOperation(published());
      await expectLater(
          OperationSources.save(log3, t82Loading, 'GTSTC', loadingSource,
              sync: _RecordingSync(log3,
                  failure: const FirestoreFailure(
                      code: 'permission-denied', message: 'La nube no aceptó el plan.')),
              attachTo: published()),
          throwsA(isA<FirestoreFailure>()));
      expect(log3.operations.single, published());
    });
  });

  group('el motor: el plan agregado llega al muelle', () {
    test('el plan de carga llega a un muelle con el plano de llegada y descargas hechas: la fuente entra, los movimientos no cambian y el estado suma la carga',
        () async {
      final log = await open();
      await log.saveOperation(published());
      final cloud = FakeCloud(clock: clock)..authorization[dock.uid] = RemoteAuthorization.active;
      cloud.server.addPlan(OperationSourceKind.arrivalBaplie, t82ArrivalEdi, fileName: 'llegada.edi');
      final sync = engine(log, cloud, published());
      await sync.start(dock);
      final discharged = (await log.append(
              MovementDraft.discharge(operationId, 'TSTU0000110', '0030984'), dock.author))
          .getOrElse(() => throw StateError('no se anexó'));
      await until(() async =>
          (await records(log)).every((r) => r.state == SendState.confirmed));
      expect(cloud.planPartsRequests, 0, reason: 'el plano de llegada ya estaba en el dispositivo');
      expect(sync.current.planArrival, isNull);

      cloud.server.addPlan(OperationSourceKind.loadingBaplie, loadingOtherVoyageEdi,
          fileName: 'carga.edi', voyage: 'VTESTN');
      await until(() async =>
          (await local(log))?.source(OperationSourceKind.loadingBaplie) != null);
      final after = (await local(log))!;
      final loading = after.source(OperationSourceKind.loadingBaplie)!;
      expect(loading.content, loadingOtherVoyageEdi);
      expect(loading.fileName, 'carga.edi');
      expect(loading.voyage, 'VTESTN');
      expect(loading.revision, isNull);
      expect(after.source(OperationSourceKind.arrivalBaplie), arrivalSource,
          reason: 'el plano de llegada no cambia');
      expect(after.voyageNumber, 'VTEST');
      final kept = await records(log);
      expect(kept.map((r) => r.movement.id), [discharged.movement.id]);
      expect(kept.single.state, SendState.confirmed);
      expect(cloud.docs, hasLength(1), reason: 'la nube no recibió ni perdió movimientos');
      await until(() async =>
          sync.current.planArrival ==
          const PlanArrival(
              kind: OperationSourceKind.loadingBaplie,
              fileName: 'carga.edi',
              voyage: 'VTESTN'));
      expect(cloud.planPartsRequests, 1);
      // El estado derivado: la descarga hecha y la carga pendiente.
      final state = derive(after, kept.map((r) => r.movement)).state;
      expect(state['C:TSTU0000110']!.state, ItemState.moved);
      expect(state['C:TSTU0000110']!.position, isNull);
      expect(state['C:TSTU0000014']!.state, ItemState.planned);
      expect(state['C:TSTU0000014']!.role, PlanRole.load);
      expect(state['R:0030984']!.role, PlanRole.load);
      // El mismo manifiesto otra vez (reconectar) no vuelve a bajar nada.
      cloud.goOnline();
      await settle();
      expect(cloud.planPartsRequests, 1);
      // Y la revisión del listado (T-127) sigue funcionando después.
      cloud.server.reviseList(jsonEncode(ExportList(fileName: 'l.xlsx', rows: const []).toJson()));
      await until(() async => (await local(log))?.exportListRevision == 1);
      expect((await local(log))!.sources, hasLength(3));
      await sync.stop();
      await log.close();
    });

    test('el plano de llegada llega a un muelle con el plan de carga', () async {
      final log = await open();
      final before = published(sources: [loadingSource]);
      await log.saveOperation(before);
      final cloud = FakeCloud(clock: clock)..authorization[dock.uid] = RemoteAuthorization.active;
      cloud.server.addPlan(OperationSourceKind.loadingBaplie, t82LoadingEdi, fileName: 'carga.edi');
      final sync = engine(log, cloud, before);
      await sync.start(dock);
      await until(() async => sync.current.state == SyncState.upToDate);
      cloud.server.addPlan(OperationSourceKind.arrivalBaplie, t82ArrivalEdi, fileName: 'llegada.edi');
      await until(() async =>
          (await local(log))?.source(OperationSourceKind.arrivalBaplie) != null);
      expect((await local(log))!.source(OperationSourceKind.arrivalBaplie)!.content, t82ArrivalEdi);
      await until(() async =>
          sync.current.planArrival ==
          const PlanArrival(kind: OperationSourceKind.arrivalBaplie, fileName: 'llegada.edi'));
      await sync.stop();
      await log.close();
    });

    test('sin red, el muelle se queda con lo que tiene y baja el plan al reconectar', () async {
      final log = await open();
      await log.saveOperation(published());
      final cloud = FakeCloud(clock: clock)..authorization[dock.uid] = RemoteAuthorization.active;
      cloud.server.addPlan(OperationSourceKind.arrivalBaplie, t82ArrivalEdi);
      final sync = engine(log, cloud, published());
      await sync.start(dock);
      await until(() async => sync.current.state == SyncState.upToDate);

      cloud.goOffline();
      cloud.server.addPlan(OperationSourceKind.loadingBaplie, t82LoadingEdi, fileName: 'carga.edi');
      await settle();
      await until(() async => sync.current.state == SyncState.offline);
      expect((await local(log))!.source(OperationSourceKind.loadingBaplie), isNull);
      expect(sync.current.planArrival, isNull);
      expect(cloud.planPartsRequests, 0);

      cloud.goOnline();
      await until(() async =>
          (await local(log))?.source(OperationSourceKind.loadingBaplie) != null);
      expect((await local(log))!.source(OperationSourceKind.loadingBaplie)!.content,
          t82LoadingEdi);
      await until(() async =>
          sync.current.planArrival ==
          const PlanArrival(kind: OperationSourceKind.loadingBaplie, fileName: 'carga.edi'));
      await settle();
      expect(cloud.planPartsRequests, 1, reason: 'una sola bajada aunque lleguen dos avisos');
      await sync.stop();
      await log.close();
    });

    test('si los trozos no bajan a la primera, el motor lo reintenta con el siguiente contacto con el servidor',
        () async {
      final log = await open();
      await log.saveOperation(published());
      final cloud = FakeCloud(clock: clock)..authorization[dock.uid] = RemoteAuthorization.active;
      cloud.server.addPlan(OperationSourceKind.arrivalBaplie, t82ArrivalEdi);
      final sync = engine(log, cloud, published());
      await sync.start(dock);
      await until(() async => sync.current.state == SyncState.upToDate);

      cloud.planPartsFailures = 1;
      cloud.server.addPlan(OperationSourceKind.loadingBaplie, t82LoadingEdi, fileName: 'carga.edi');
      await until(() async => cloud.planPartsRequests == 1);
      await settle();
      expect((await local(log))!.source(OperationSourceKind.loadingBaplie), isNull);
      expect(sync.current.planArrival, isNull);

      // Llega un movimiento de otro dispositivo: el servidor contesta y el
      // motor vuelve a pedir los trozos.
      cloud.receiveWithoutAck(fromOther);
      await until(() async =>
          (await local(log))?.source(OperationSourceKind.loadingBaplie) != null);
      expect(cloud.planPartsRequests, 2);
      await until(() async => (await records(log)).length == 1);
      await sync.stop();
      await log.close();
    });

    test('un plan cuyos trozos no cuadran con su entrada se ignora y no se vuelve a pedir', () async {
      final log = await open();
      await log.saveOperation(published());
      final cloud = FakeCloud(clock: clock)..authorization[dock.uid] = RemoteAuthorization.active;
      cloud.server.addPlan(OperationSourceKind.arrivalBaplie, t82ArrivalEdi);
      final sync = engine(log, cloud, published());
      await sync.start(dock);
      await until(() async => sync.current.state == SyncState.upToDate);

      cloud.goOffline();
      cloud.server.addPlan(OperationSourceKind.loadingBaplie, t82LoadingEdi);
      final index = cloud.server.sourceParts
          .indexWhere((p) => p.kind == OperationSourceKind.loadingBaplie);
      final part = cloud.server.sourceParts[index];
      cloud.server.sourceParts[index] = SourcePart(
          id: part.id,
          kind: part.kind,
          part: part.part,
          parts: part.parts,
          sha256: part.sha256,
          content: '${part.content} ');
      cloud.goOnline();
      await until(() async => cloud.planPartsRequests == 1);
      await settle();
      expect((await local(log))!.source(OperationSourceKind.loadingBaplie), isNull);
      expect(sync.current.planArrival, isNull);
      cloud.receiveWithoutAck(fromOther);
      await until(() async => (await records(log)).length == 1);
      await settle();
      expect(cloud.planPartsRequests, 1);
      await sync.stop();
      await log.close();
    });

    test('el eco antes que el acuse: la oficina que agrega no se avisa a sí misma ni guarda el plan dos veces, tampoco con el listado (T-127)',
        () async {
      final log = await open();
      await log.saveOperation(published());
      final cloud = FakeCloud(clock: clock)..authorization[dock.uid] = RemoteAuthorization.active;
      cloud.server.addPlan(OperationSourceKind.arrivalBaplie, t82ArrivalEdi);
      final ownWrites = OwnSourceWrites();
      final sync = engine(log, cloud, published(), ownWrites: ownWrites);
      await sync.start(dock);
      await until(() async => sync.current.state == SyncState.upToDate);

      // El adaptador anota la escritura, el lote llega al servidor y el eco
      // del manifiesto alcanza al motor ANTES de que el adaptador guarde en
      // local: el motor no baja nada ni avisa.
      final packed = packSource(loadingSource);
      ownWrites.begin(operationId, OperationSourceKind.loadingBaplie, packed.entry.sha256);
      cloud.server.addPlan(OperationSourceKind.loadingBaplie, t82LoadingEdi, fileName: 'carga.edi');
      await settle();
      await settle();
      expect(cloud.planPartsRequests, 0);
      expect(sync.current.planArrival, isNull);
      expect((await local(log))!.source(OperationSourceKind.loadingBaplie), isNull);
      // Ahora el adaptador guarda en local, una sola vez, y suelta la anotación.
      await log.saveOperation(published(sources: [arrivalSource, loadingSource]));
      ownWrites.end(operationId, OperationSourceKind.loadingBaplie, packed.entry.sha256);
      expect(ownWrites.isEmpty, isTrue);
      cloud.goOnline();
      await settle();
      await settle();
      expect(cloud.planPartsRequests, 0, reason: 'ya está en local: nada que bajar');
      expect(sync.current.planArrival, isNull);
      expect((await local(log))!.sources, hasLength(2));

      // Lo mismo con el listado de T-127.
      final listJson = jsonEncode(ExportList(fileName: 'l.xlsx', rows: const []).toJson());
      final listPacked = packSource(
          OperationSource(
              kind: OperationSourceKind.exportList, fileName: 'l.xlsx', content: listJson),
          revision: 1);
      ownWrites.begin(operationId, OperationSourceKind.exportList, listPacked.entry.sha256);
      cloud.server.reviseList(listJson, fileName: 'l.xlsx');
      await settle();
      await settle();
      expect(cloud.listPartsRequests, 0);
      expect(sync.current.listArrival, isNull);
      await log.saveOperation(published(sources: [
        arrivalSource,
        loadingSource,
        OperationSource(
            kind: OperationSourceKind.exportList,
            fileName: 'l.xlsx',
            content: listJson,
            revision: 1),
      ]));
      ownWrites.end(operationId, OperationSourceKind.exportList, listPacked.entry.sha256);
      cloud.goOnline();
      await settle();
      await settle();
      expect(cloud.listPartsRequests, 0);
      expect(sync.current.listArrival, isNull);
      await sync.stop();
      await log.close();
    });

    test('el acuse antes que el eco: lo que el dispositivo guardó manda, como en T-127', () async {
      final log = await open();
      await log.saveOperation(published());
      final cloud = FakeCloud(clock: clock)..authorization[dock.uid] = RemoteAuthorization.active;
      cloud.server.addPlan(OperationSourceKind.arrivalBaplie, t82ArrivalEdi);
      final sync = engine(log, cloud, published());
      await sync.start(dock);
      await until(() async => sync.current.state == SyncState.upToDate);
      await log.saveOperation(published(sources: [arrivalSource, loadingSource]));
      cloud.server.addPlan(OperationSourceKind.loadingBaplie, t82LoadingEdi);
      await settle();
      await settle();
      expect(cloud.planPartsRequests, 0);
      expect(sync.current.planArrival, isNull);
      await sync.stop();
      await log.close();
    });
  });

  group('la propiedad: el plan agregado después es el mismo que publicado junto', () {
    test('el estado derivado y el BAPLIE de salida son idénticos', () {
      final moves = [
        t82Move(MovementDraft.discharge('op', 'TSTU0000110', '0030984'), 1),
        t82Move(MovementDraft.loadFull('op', 'TSTU0000014', '0030282', order: 5), 2),
        t82Move(MovementDraft.assignEmpty('op', '0030984', 'TSTU0000020', 2185, order: 12), 3),
      ];
      // Publicados juntos (el fixture de T-82) y la llegada publicada con la
      // operación, el plan de carga agregado después con otro viaje.
      final together = t82Operation;
      final added = Operation(
          id: 'op',
          vesselName: 'BUQUE PRUEBA',
          voyageNumber: 'VTEST',
          portOfCall: 'GTSTC',
          createdAt: DateTime.utc(2026),
          sources: [
            arrivalSource,
            const OperationSource(
                kind: OperationSourceKind.loadingBaplie,
                fileName: 'carga.edi',
                content: t82LoadingEdi,
                voyage: 'VTESTN'),
          ]);
      LoadingOperation build(Operation operation) {
        VesselVoyage parse(OperationSourceKind kind) => BaplieParserService()
            .parse(operation.source(kind)!.content)
            .copyWith(portOfCall: 'GTSTC');
        return LoadingOperation.build(
            operationId: 'op',
            arrival: parse(OperationSourceKind.arrivalBaplie),
            loading: parse(OperationSourceKind.loadingBaplie),
            list: t82List,
            movements: moves);
      }

      final a = build(together);
      final b = build(added);
      expect(b.state.items, a.state.items);
      expect(b.state.conflicts, a.state.conflicts);
      expect(b.state.occupancy, a.state.occupancy);
      expect(b.state.progress(), a.state.progress());
      final now = DateTime.utc(2026, 11, 3, 10);
      final salidaA = const DepartureBaplieWriter().generate(
          operation: together, state: a.state, list: t82List, movements: moves, now: now);
      final salidaB = const DepartureBaplieWriter().generate(
          operation: added, state: b.state, list: t82List, movements: moves, now: now);
      expect(salidaB.text, salidaA.text);
      expect(salidaB.containers, salidaA.containers);
      expect(salidaB.text, contains('TDT+20+VTEST+'),
          reason: 'el TDT es el del plan de carga tal como llegó');
    });
  });
}

/// La nube de la oficina en las pruebas del dominio: anota cada `addSource`
/// y, si no se le pide fallar, hace lo que hace Firestore: la fuente queda en
/// la operación local.
class _RecordingSync implements OperationSyncRepository {
  _RecordingSync(this.log, {this.failure});

  final T75MemoryLog log;
  final Failure? failure;
  final added = <OperationSource>[];

  @override
  Future<Either<Failure, Operation>> addSource(
      Operation operation, OperationSource source) async {
    added.add(source);
    final failure = this.failure;
    if (failure != null) return Left(failure);
    final updated = operation.copyWith(sources: [
      ...operation.sources.where((s) => s.kind != source.kind),
      source,
    ]);
    await log.saveOperation(updated);
    return Right(updated);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// La lista de operaciones abiertas de la nube, para la búsqueda; `silent`
/// nunca responde (sin red).
class _CloudList implements OperationSyncRepository {
  _CloudList(this.open) : _silent = false;
  _CloudList.silent()
      : open = const [],
        _silent = true;

  final List<PublishedOperation> open;
  final bool _silent;

  @override
  SyncCapability get capability => SyncCapability.realtime;

  @override
  Stream<List<PublishedOperation>> watchOpenOperations() => _silent
      ? StreamController<List<PublishedOperation>>().stream
      : Stream.value(open);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
