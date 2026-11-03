import 'dart:async';
import 'dart:typed_data';

import 'package:baystream/core/design/design.dart';
import 'package:baystream/core/errors/failures.dart';
import 'package:baystream/features/vessel/data/repositories/departure_export_repository_impl.dart';
import 'package:baystream/features/vessel/data/repositories/vessel_repository_impl.dart';
import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/presentation/providers/vessel_providers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/repositories/departure_export_repository.dart';
import 'package:baystream/features/vessel/domain/repositories/movement_log_repository.dart';
import 'package:baystream/features/vessel/domain/repositories/operation_sync_repository.dart';
import 'package:baystream/features/vessel/domain/services/operation_sources.dart';
import 'package:baystream/features/vessel/presentation/pages/cloud_page.dart';
import 'package:baystream/features/vessel/presentation/pages/departure_baplie_page.dart';
import 'package:baystream/features/vessel/presentation/providers/loading_operation_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/movement_log_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/sync_providers.dart';
import 'package:baystream/features/vessel/presentation/providers/voyage_ui_state.dart';
import 'package:baystream/features/vessel/presentation/widgets/aviso_del_plan.dart';
import 'package:baystream/features/vessel/presentation/widgets/dialogo_agregar_plan.dart';
import 'package:dartz/dartz.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/t132_fixture.dart';
import 'support/t82_fixture.dart';

/// T-130 (10.90) · Las pantallas: el diálogo de la oficina («Agregar el plan
/// de carga a la operación publicada», con la fecha de publicación, las
/// cifras y el viaje que declara el archivo), la banda del previo con el
/// motivo nuevo, el aviso del muelle («Plan de carga agregado por la oficina:
/// …», una vez por llegada, con «Abrir»), las fuentes en «Nube y cuenta», y
/// en la salida la nota del viaje y el nombre del archivo (ajuste 5).
class _Log implements MovementLogRepository {
  _Log(this.operation);
  final Operation operation;

  @override
  Future<Either<Failure, Operation?>> getOperation(String id) async =>
      Right(id == operation.id ? operation : null);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Save implements DepartureExportRepository {
  @override
  Future<String?> save(Operation operation, String edi) async => 't130.edi';
}

/// Sin Firebase en la prueba: el repositorio del lector solo lee el archivo
/// (`parseBaplieFile`); cualquier llamada remota accidental falla enseguida.
class _NoCloud implements FirebaseFirestore {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw StateError('La prueba no tiene Firebase: ${invocation.memberName}');
}

class _Picker extends FilePicker {
  String? fileName;
  @override
  Future<String?> saveFile({
    String? dialogTitle,
    String? fileName,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    Uint8List? bytes,
    bool lockParentWindow = false,
  }) async {
    this.fileName = fileName;
    return 't130-sintetico.edi';
  }
}

void main() {
  const operationId = 'op-t130';
  final publishedAt = DateTime.utc(2026, 11, 1, 20, 5);
  final loadingOtherVoyage =
      t82Loading.copyWith(voyageNumber: 'VTESTN');
  Operation published({Iterable<OperationSource> sources = const []}) => Operation(
        id: operationId,
        vesselName: 'BUQUE PRUEBA',
        voyageNumber: 'VTEST',
        portOfCall: 'GTSTC',
        createdAt: DateTime.utc(2026, 11, 1, 14, 5),
        published: true,
        sources: [
          const OperationSource(
              kind: OperationSourceKind.arrivalBaplie,
              fileName: 'llegada.edi',
              content: t82ArrivalEdi),
          ...sources,
        ],
      );

  group('la oficina: el diálogo de agregar', () {
    Future<bool?> abrir(WidgetTester tester,
        {required VesselVoyage plan, required AttachablePlan lookup}) async {
      bool? resultado;
      await tester.pumpWidget(MaterialApp(
          theme: BayStreamTema.claro(muelle: false),
          home: Scaffold(
              body: Builder(
                  builder: (context) => FilledButton(
                      key: const ValueKey('abrir'),
                      onPressed: () async {
                        resultado = await confirmarAgregarPlan(context,
                            plan: plan,
                            port: 'GTSTC',
                            kind: OperationSourceKind.loadingBaplie,
                            lookup: lookup,
                            fileName: 'carga_n.edi');
                      },
                      child: const Text('abrir'))))));
      await tester.tap(find.byKey(const ValueKey('abrir')));
      await tester.pumpAndSettle();
      return resultado;
    }

    testWidgets('dice cuándo se publicó, el viaje que declara el archivo y las cifras; «Agregar» confirma',
        (tester) async {
      final lookup = AttachablePlan(published(), publishedAt: publishedAt);
      await abrir(tester, plan: loadingOtherVoyage, lookup: lookup);
      expect(find.byKey(const ValueKey('attach-plan-dialog')), findsOneWidget);
      expect(find.text('Agregar el plan de carga a la operación publicada'), findsOneWidget);
      final cuando = tester.widget<Text>(find.byKey(const ValueKey('attach-plan-published-at')));
      expect(cuando.data, startsWith('BUQUE PRUEBA · VTEST · GTSTC, publicada el '));
      expect(cuando.data, endsWith(', abierta, sin plan de carga.'));
      expect(
          find.text('«carga_n.edi» declara el viaje VTESTN. La operación publicada es el viaje VTEST.'),
          findsOneWidget);
      expect(find.text('Se cargan 1 contenedores y 1 celdas reservadas; se descargan 0.'),
          findsOneWidget);
      expect(find.text('El muelle lo recibe solo. Los movimientos registrados no se pierden ni cambian.'),
          findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('attach-plan-confirm')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('attach-plan-dialog')), findsNothing);
    });

    testWidgets('con el mismo viaje no habla del viaje; sin la nube dice «guardada el»; «Cancelar» no agrega',
        (tester) async {
      final lookup = AttachablePlan(published());
      await abrir(tester, plan: t82Loading, lookup: lookup);
      expect(find.byKey(const ValueKey('attach-plan-voyage')), findsNothing);
      final cuando = tester.widget<Text>(find.byKey(const ValueKey('attach-plan-published-at')));
      expect(cuando.data, contains(', guardada el '));
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('attach-plan-dialog')), findsNothing);
    });

    testWidgets('el resultado del diálogo es lo que la oficina tocó', (tester) async {
      final lookup = AttachablePlan(published(), publishedAt: publishedAt);
      bool? resultado;
      await tester.pumpWidget(MaterialApp(
          home: Scaffold(
              body: Builder(
                  builder: (context) => Column(children: [
                        FilledButton(
                            key: const ValueKey('si'),
                            onPressed: () async {
                              resultado = await confirmarAgregarPlan(context,
                                  plan: t82Loading,
                                  port: 'GTSTC',
                                  kind: OperationSourceKind.loadingBaplie,
                                  lookup: lookup,
                                  fileName: 'carga.edi');
                            },
                            child: const Text('si')),
                      ])))));
      await tester.tap(find.byKey(const ValueKey('si')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('attach-plan-confirm')));
      await tester.pumpAndSettle();
      expect(resultado, isTrue);
      await tester.tap(find.byKey(const ValueKey('si')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();
      expect(resultado, isFalse);
    });

    test('la banda del previo con el motivo nuevo dice la nota de la búsqueda', () {
      Previo previo({String? nota}) => Previo(
          voyage: t82Loading,
          profile: VesselProfile.proposeFrom(t82Loading),
          motivo: PreviewReason.operacionPublicada,
          fileName: 'carga.edi',
          portOfCall: 'GTSTC',
          nota: nota);
      expect(previo(nota: 'La escala GTSTC ya tiene una operación publicada (viaje VTEST) sin plan de carga: confirma para agregarlo.').texto,
          'La escala GTSTC ya tiene una operación publicada (viaje VTEST) sin plan de carga: confirma para agregarlo.');
      expect(previo().texto,
          'La escala GTSTC ya tiene una operación publicada de este buque: confirma para agregar este plan.');
    });

    test('«Nube y cuenta» nombra las fuentes con el viaje de un plan agregado y la revisión del listado',
        () {
      expect(fuentesDeLaOperacion(published()), 'Fuentes: llegada');
      expect(
          fuentesDeLaOperacion(published(sources: const [
            OperationSource(
                kind: OperationSourceKind.loadingBaplie,
                fileName: 'carga.edi',
                content: t82LoadingEdi,
                voyage: 'VTESTN'),
            OperationSource(
                kind: OperationSourceKind.exportList,
                fileName: 'l.xlsx',
                content: '{}',
                revision: 2),
          ])),
          'Fuentes: llegada · carga (viaje VTESTN) · listado r2');
      expect(
          fuentesDeLaOperacion(Operation(
              id: 'x',
              vesselName: 'B',
              voyageNumber: 'V',
              portOfCall: 'GTSTC',
              createdAt: DateTime.utc(2026))),
          'Sin fuentes');
    });

    test('los textos del plan agregado, con las cifras del plan', () {
      expect(
          textoDelPlanAgregado(
              kind: OperationSourceKind.loadingBaplie,
              port: 'GTSTC',
              plan: t82Loading,
              enElMuelle: false),
          'Plan de carga agregado a la operación publicada de GTSTC: 1 contenedores y 1 '
          'reservas. El muelle lo recibe solo.');
      expect(
          textoDelPlanAgregado(
              kind: OperationSourceKind.loadingBaplie,
              port: 'GTSTC',
              plan: t82Loading,
              enElMuelle: true),
          'Plan de carga agregado por la oficina: 1 contenedores y 1 reservas.');
      expect(
          textoDelPlanAgregado(
              kind: OperationSourceKind.arrivalBaplie,
              port: 'GTSTC',
              plan: t82Arrival,
              enElMuelle: true),
          'Plano de llegada agregado por la oficina: 1 se descargan.');
    });
  });

  group('el muelle recibe el plan', () {
    testWidgets('avisa «Plan de carga agregado por la oficina: …» una vez por llegada, con «Abrir», y vuelve a derivar el plano',
        (tester) async {
      final statuses = StreamController<SyncStatus>.broadcast();
      addTearDown(statuses.close);
      final operation = published(sources: const [
        OperationSource(
            kind: OperationSourceKind.loadingBaplie,
            fileName: 'carga.edi',
            content: t82LoadingEdi),
      ]);
      await tester.pumpWidget(ProviderScope(
          overrides: [
            syncStatusProvider.overrideWith((ref) => statuses.stream),
            activeOperationProvider.overrideWith((ref) async => operation),
            movementLogRepositoryProvider.overrideWith((ref) async => _Log(operation)),
            vesselRepositoryProvider.overrideWithValue(VesselRepositoryImpl(
                parserService: BaplieParserService(), firestore: _NoCloud())),
          ],
          child: MaterialApp(
              theme: BayStreamTema.claro(muelle: true),
              home: const Scaffold(body: AvisoDelPlan()))));
      await tester.pump();
      await tester.pump();
      final container =
          ProviderScope.containerOf(tester.element(find.byType(AvisoDelPlan)));
      const aviso = ValueKey('aviso-plan-agregado');

      statuses.add(const SyncStatus(SyncState.upToDate));
      await tester.pump();
      await tester.pump();
      expect(find.byKey(aviso), findsNothing);
      expect(container.read(operationSourcesRevisionProvider), 0);

      statuses.add(const SyncStatus(SyncState.upToDate,
          planArrival: PlanArrival(
              kind: OperationSourceKind.loadingBaplie, fileName: 'carga.edi')));
      for (var i = 0; i < 5; i++) {
        await tester.pump();
      }
      expect(find.text('Plan de carga agregado por la oficina: 1 contenedores y 1 reservas.'),
          findsOneWidget);
      expect(find.text('Abrir'), findsOneWidget);
      expect(container.read(operationSourcesRevisionProvider), 1,
          reason: 'el plano se vuelve a derivar con el plan nuevo');

      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 7));
      await tester.pumpAndSettle();
      expect(find.byKey(aviso), findsNothing);
      statuses.add(const SyncStatus(SyncState.sending,
          pending: 1,
          planArrival: PlanArrival(
              kind: OperationSourceKind.loadingBaplie, fileName: 'carga.edi')));
      for (var i = 0; i < 5; i++) {
        await tester.pump();
      }
      expect(find.byKey(aviso), findsNothing);
      expect(container.read(operationSourcesRevisionProvider), 1);

      // Otro plan, otro aviso; sin poder leerlo, dice el archivo.
      statuses.add(const SyncStatus(SyncState.upToDate,
          planArrival: PlanArrival(
              kind: OperationSourceKind.arrivalBaplie, fileName: 'llegada.edi')));
      for (var i = 0; i < 5; i++) {
        await tester.pump();
      }
      expect(find.text('Plano de llegada agregado por la oficina: 1 se descargan.'),
          findsOneWidget);
      expect(container.read(operationSourcesRevisionProvider), 2);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 7));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });

  group('la salida: el viaje del plan de carga (ajuste 5)', () {
    T132Fixture fixture() => T132Fixture(
        cargo: "${t132Group(1)}${t132Group(2)}", rows: [t132Row(1), t132Row(2)], loaded: [1, 2]);

    Future<void> mount(WidgetTester tester, T132Fixture f, Operation operation) async {
      await tester.pumpWidget(ProviderScope(
          overrides: [
            operatorProvider.overrideWith((ref) => Stream.value(null)),
            activeOperationProvider.overrideWith((ref) async => operation),
            loadingOperationProvider(f.voyage).overrideWith((ref) => Stream.value(f.data)),
            departureExportRepositoryProvider.overrideWithValue(_Save()),
          ],
          child: MaterialApp(
              theme: BayStreamTema.claro(muelle: false),
              home: DepartureBapliePage(voyage: f.voyage))));
      await tester.pumpAndSettle();
    }

    testWidgets('la página dice qué viaje lleva el archivo cuando no es el de la operación',
        (tester) async {
      final f = fixture();
      final withVoyage = f.operation.copyWith(sources: [
        f.operation.source(OperationSourceKind.loadingBaplie)!.withVoyage('V132N'),
      ]);
      await mount(tester, f, withVoyage);
      expect(
          find.text('El archivo lleva el viaje V132N, el del plan de carga. La operación es la V132.'),
          findsOneWidget);
      expect(find.byKey(const ValueKey('departure-voyage-note')), findsOneWidget);
    });

    testWidgets('con el mismo viaje no hay nota', (tester) async {
      final f = fixture();
      await mount(tester, f, f.operation);
      expect(find.byKey(const ValueKey('departure-voyage-note')), findsNothing);
    });

    test('el nombre del archivo lleva el viaje del plan de carga', () async {
      final picker = _Picker();
      FilePicker? previous;
      try {
        previous = FilePicker.platform;
      } catch (_) {
        // En la VM de pruebas no siempre hay una plataforma registrada.
      }
      FilePicker.platform = picker;
      addTearDown(() {
        if (previous != null) FilePicker.platform = previous;
      });
      final f = fixture();
      await const DepartureExportRepositoryImpl().save(f.operation, f.output().text);
      expect(picker.fileName, 'BayStream_BUQUE SINTETICO_V132_salida.edi');
      final withVoyage = f.operation.copyWith(sources: [
        f.operation.source(OperationSourceKind.loadingBaplie)!.withVoyage('V132N'),
      ]);
      await const DepartureExportRepositoryImpl().save(withVoyage, f.output().text);
      expect(picker.fileName, 'BayStream_BUQUE SINTETICO_V132N_salida.edi');
    });
  });
}
