// T-125 · La 3.2.0 (SPRINT-4.md 10.68). Las dos pruebas de la candidata, que
// estaban en rojo antes del arreglo (docs/T125-RESULTADOS.md):
//   1. Estadísticas cuenta los vacíos asignados a una celda reservada, como la
//      Lista y las búsquedas (`aboardContainersProvider`): asignar uno sube las
//      cifras y saca la ficha que lo dice; deshacerlo las baja y la quita;
//   2. O-124-1 · en la vista de una par, cada celda tomada por veintes de las
//      impares vecinas lleva su propia clave: con dos en la misma fila del
//      dibujo, Flutter en debug ya no avisa de claves duplicadas.
// Con la página entera, en la oficina, y una bitácora en memoria. Buque y
// contenedores sintéticos (T-76); nunca el corpus.
import 'package:baystream/core/design/design.dart';
import 'package:baystream/features/vessel/data/repositories/local_only_operation_sync.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/repositories/session_repository.dart';
import 'package:baystream/features/vessel/domain/services/loading_operation.dart';
import 'package:baystream/features/vessel/presentation/pages/vessel_overview_page.dart';
import 'package:baystream/features/vessel/presentation/providers/loading_operation_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/loading_plan_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/movement_log_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/plano_providers.dart';
import 'package:baystream/features/vessel/presentation/providers/sync_providers.dart';
import 'package:baystream/features/vessel/presentation/providers/vessel_providers.dart';
import 'package:baystream/features/vessel/presentation/widgets/loading_plan_controls.dart';
import 'package:baystream/features/vessel/presentation/widgets/voyage_stats_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/local_profile_test_support.dart';
import 'support/t117_oficina_support.dart';
import 'support/t121_estadisticas_support.dart';
import 'support/t75_memory_log.dart';
import 'support/t76_fixture.dart';
import 't81_office_changes_test.dart' as f;

class _Viaje extends VoyageNotifier {
  _Viaje(this.voyage);
  final VesselVoyage voyage;
  @override
  AsyncValue<VesselVoyage?> build() => AsyncData(voyage);
}

/// La página del viaje en la oficina, con [voyage] como plan de carga y la
/// operación derivada de una bitácora en memoria, como en T-122.
Future<(T75MemoryLog, ProviderContainer)> _pagina(
  WidgetTester tester,
  VesselVoyage voyage, {
  Size tamano = const Size(1920, 1000),
  int? bahia,
  BayPlanMode? modo,
  Operator actor = f.office,
}) async {
  await t117CargarFuentes();
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = tamano;
  addTearDown(tester.view.reset);
  final log = T75MemoryLog();
  LoadingOperation derivar(List<MovementRecord> registros) =>
      LoadingOperation.build(
          operationId: 'op',
          loading: voyage,
          list: t76List,
          movements: registros.map((r) => r.movement));
  final scope = ProviderContainer(overrides: [
    voyageNotifierProvider.overrideWith(() => _Viaje(voyage)),
    localVesselRepositoryProvider.overrideWith((ref) async => T117Equipo()),
    vesselRepositoryProvider.overrideWithValue(ParserOnlyRepository()),
    movementLogRepositoryProvider.overrideWith((ref) async => log),
    sessionRepositoryProvider
        .overrideWith((ref) async => const LocalSessionRepository()),
    operatorProvider.overrideWith((ref) => Stream.value(actor)),
    activeOperationProvider.overrideWith((ref) async => f.operation),
    loadingOperationProvider(voyage).overrideWith((ref) async* {
      await for (final registros in log.watch('op')) {
        yield derivar(registros);
      }
    }),
    loadingPlanProgressProvider(voyage).overrideWith((ref) async* {
      await for (final registros in log.watch('op')) {
        yield derivar(registros).progress;
      }
    }),
  ]);
  addTearDown(scope.dispose);
  if (bahia != null) scope.read(selectedBayProvider.notifier).select(bahia);
  if (modo != null) scope.read(bayPlanModeProvider.notifier).elegir(modo);
  await tester.pumpWidget(UncontrolledProviderScope(
    container: scope,
    child: MaterialApp(
      theme: BayStreamTema.claro(),
      darkTheme: BayStreamTema.oscuro(),
      home: const VesselOverviewPage(),
    ),
  ));
  await tester.pumpAndSettle();
  return (log, scope);
}

final _protagonista =
    find.byKey(const ValueKey<String>('estadisticas-protagonista'));
final _ficha = find.byKey(const ValueKey<String>('estadisticas-vacios-asignados'));

String _texto(WidgetTester tester, Finder finder) =>
    tester.widget<Text>(finder).data!;

/// La columna de la bahía [numero] en el buque en corte.
BsBahiaEnCorte _bahia(WidgetTester tester, int numero) => tester
    .widget<BsBuqueEnCorte>(
        find.byKey(const ValueKey<String>('estadisticas-buque')))
    .bahias
    .singleWhere((BsBahiaEnCorte b) => b.numero == numero);

/// Las etiquetas de las barras de un panel, como las dice el lector.
List<String> _barras(WidgetTester tester, String panel) => tester
    .widgetList<BsBarraDeMagnitud>(find.descendant(
        of: find.byKey(ValueKey<String>(panel)),
        matching: find.byType(BsBarraDeMagnitud)))
    .map((BsBarraDeMagnitud b) => b.etiqueta)
    .toList();

void main() {
  group('1 · Estadísticas con los vacíos asignados (10.68)', () {
    testWidgets(
        'asignar un vacío sube las cifras y saca la ficha; deshacerlo las baja',
        (tester) async {
      final (log, _) = await _pagina(tester, t76Loading);
      await tester.tap(find.descendant(
          of: find.byKey(const ValueKey('riel-del-viaje')),
          matching: find.text('Estadísticas')));
      await tester.pumpAndSettle();
      expect(find.byType(VoyageStatsView), findsOneWidget);

      // El archivo: los dos llenos del plan en la 03, ningún vacío.
      expect(_texto(tester, _protagonista), '2');
      expect(_ficha, findsNothing);
      expect(_bahia(tester, 3).contenedores, 2);
      expect(_bahia(tester, 3).contenedoresCubierta, 2);
      expect(_barras(tester, 'estadisticas-puertos'),
          <String>['PAMIT: 2 contenedores, 100$espacioDuro%']);
      expect(_barras(tester, 'estadisticas-navieras'),
          <String>['TEST: 2 contenedores, 100$espacioDuro%']);
      expect(find.text('0 vacíos'), findsOneWidget);

      // El muelle asigna el vacío OR 12 a la reserva 003-08-82 (H6).
      final asignado = (await log.append(
              MovementDraft.assignEmpty('op', '0030882', 'EMPTY0000012', 2185,
                  order: 12),
              f.dock.author))
          .getOrElse(() => throw StateError('no se anotó la asignación'));
      await tester.pumpAndSettle();

      expect(_texto(tester, _protagonista), '3');
      expect(tester.widget<BsFichaDeCifra>(_ficha).texto,
          'Incluye: 1 vacío asignado a una celda reservada, que el archivo '
          'no trae');
      // Un contenedor más en su bahía, con su tara; su puerto y su naviera.
      expect(_bahia(tester, 3).contenedores, 3);
      expect(_bahia(tester, 3).contenedoresCubierta, 3);
      expect(_barras(tester, 'estadisticas-puertos'),
          <String>['PAMIT: 3 contenedores, 100$espacioDuro%']);
      expect(_barras(tester, 'estadisticas-navieras'),
          <String>['TEST: 3 contenedores, 100$espacioDuro%']);
      expect(find.text('1 vacío'), findsOneWidget);
      final conTara = _bahia(tester, 3).pesoKg;

      // Se deshace: todo vuelve a lo del archivo y la ficha se va.
      await log.append(
          MovementDraft.annul('op', asignado.movement.id, 'Marcado por error',
              target: asignado.movement.target),
          f.dock.author);
      await tester.pumpAndSettle();

      expect(_texto(tester, _protagonista), '2');
      expect(_ficha, findsNothing);
      expect(_bahia(tester, 3).contenedores, 2);
      expect(conTara - _bahia(tester, 3).pesoKg, 2185);
      expect(_barras(tester, 'estadisticas-puertos'),
          <String>['PAMIT: 2 contenedores, 100$espacioDuro%']);
      expect(find.text('0 vacíos'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    // El vacío asignado como lo da el dominio, sin la página.
    final asignados = t76Operation([
      t76Movement(
          MovementDraft.assignEmpty('op', '0030882', 'EMPTY0000012', 2185,
              order: 12),
          1),
    ]).assignedEmpties;
    for (final oscuro in <bool>[false, true]) {
      for (final (tamano, letra) in <(Size, double)>[
        (const Size(360, 800), 2.0),
        (const Size(1920, 1000), 1.0),
      ]) {
        testWidgets(
            '${oscuro ? 'noche' : 'día'}, ${tamano.width.toInt()} con la letra a '
            '$letra: la ficha se lee entera y la tabla trae la cifra',
            (tester) async {
          final semantica = tester.ensureSemantics();
          await t121Pump(tester,
              voyage: t76Loading,
              vaciosAsignados: asignados,
              tamano: tamano,
              letra: letra,
              oscuro: oscuro,
              muelle: tamano.width < 600);
          expect(asignados.single.containerId, 'EMPTY0000012');
          expect(tester.widget<BsFichaDeCifra>(_ficha).texto,
              'Incluye: 1 vacío asignado a una celda reservada, que el '
              'archivo no trae');
          expect(_texto(tester, _protagonista), '3');
          final pagina = find.byKey(const ValueKey<String>('estadisticas'));
          expect(t117TextosCortados(tester, pagina), isEmpty);
          expect(t121PalabrasPartidas(tester, pagina), isEmpty);
          await expectLater(tester, meetsGuideline(textContrastGuideline));
          // «Ver como tabla»: la cabecera con la ficha se queda, y el
          // resumen dice cuántos de los 3 son vacíos asignados.
          final verTabla =
              find.byKey(const ValueKey<String>('estadisticas-ver-tabla'));
          await tester.ensureVisible(verTabla);
          await tester.tap(verTabla);
          await tester.pumpAndSettle();
          expect(_ficha, findsOneWidget);
          final fila = find.ancestor(
              of: find.text('Vacíos asignados'), matching: find.byType(Table));
          expect(fila, findsOneWidget);
          expect(
              find.descendant(
                  of: find.byKey(const ValueKey<String>('estadisticas-tabla')),
                  matching: find.text('Vacíos asignados')),
              findsOneWidget);
          expect(t117TextosCortados(tester, pagina), isEmpty);
          semantica.dispose();
          expect(tester.takeException(), isNull);
        });
      }
    }

    testWidgets('sin vacíos asignados, ni la ficha ni la fila: como antes',
        (tester) async {
      await t121Pump(tester, voyage: t76Loading);
      expect(_texto(tester, _protagonista), '2');
      expect(_ficha, findsNothing);
      await tester.tap(
          find.byKey(const ValueKey<String>('estadisticas-ver-tabla')));
      await tester.pumpAndSettle();
      expect(find.text('Vacíos asignados'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });

  group('2 · O-124-1: una clave por celda de los veintes vecinos', () {
    // El caso de Codex (aceptación de T-124, 7): dos 20 por cargar en la 21 y
    // la 23, en filas distintas, y un 40 de paso en la 22.
    final viaje = t76Voyage([
      t76Unit('ODD10000021', '0210282'),
      t76Unit('ODD20000023', '0230482'),
      t76Unit('STAY0000022', '0220682').copyWith(
          isoSizeType: '42G1', portOfLoading: 'PAMIT', portOfDischarge: 'USHOU'),
    ]);

    for (final modo in <BayPlanMode>[BayPlanMode.content, BayPlanMode.loading]) {
      testWidgets(
          'el plano de la oficina en debug (${modo.name}), sin claves duplicadas',
          (tester) async {
        final errores = <String>[];
        final sombras = <String, int>{};
        final original = FlutterError.onError;
        FlutterError.onError =
            (FlutterErrorDetails d) => errores.add(d.exceptionAsString());
        try {
          await _pagina(tester, viaje,
              tamano: const Size(1920, 1080),
              bahia: 22,
              modo: modo,
              actor: f.dock);
          // Cada sombra con la suya, por su posición en la 22, y con su «20′».
          for (final posicion in <String>['0220282', '0220482']) {
            sombras[posicion] = find
                .descendant(
                    of: find.byKey(ValueKey('neighbor-twenty-$posicion')),
                    matching: find.text("20′"))
                .evaluate()
                .length;
          }
          // Desmontar tampoco deja errores.
          await tester.pumpWidget(const SizedBox());
          await tester.pumpAndSettle();
        } finally {
          FlutterError.onError = original;
        }
        expect(errores.where((String e) => e.contains('Duplicate keys')),
            isEmpty);
        expect(errores, isEmpty);
        expect(sombras, <String, int>{'0220282': 1, '0220482': 1});
      });
    }
  });
}
