// T-124 · La regla de la par en la presentación (SPRINT-4.md 10.65). Cada
// grupo reproduce un punto y estaba en rojo antes del arreglo
// (docs/T124-RESULTADOS.md):
//
// 1. P2 · La ficha de la bahía (DESIGN.md 14.7): con la 21 elegida decía
//    «Bahía 22: <las cifras de la 21>; por cargar <lo del grupo de la 22>».
//    Ahora dice lo de la bahía que se ve con su número, y lo del grupo con
//    el rótulo de su par: «Bahía 21: …; grupo 22 (21, 22 y 23), por cargar …».
// 2. Estadísticas (DESIGN.md 15) cuenta cada impar con la par vecina que la
//    cubre (`referenceBay`, con las bahías del viaje), como el avance.
// 3. P3 · «1 contenedor a bordo» en la página del BAPLIE de salida.
//
// Datos sintéticos: el buque de T-76 y los viajes de T-117 y T-121.
import 'package:baystream/core/design/design.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/services/loading_operation.dart';
import 'package:baystream/features/vessel/presentation/formatters/estadisticas_del_viaje.dart';
import 'package:baystream/features/vessel/presentation/pages/departure_baplie_page.dart';
import 'package:baystream/features/vessel/presentation/providers/loading_operation_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/loading_plan_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/movement_log_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/plano_providers.dart';
import 'package:baystream/features/vessel/presentation/providers/sync_providers.dart';
import 'package:baystream/features/vessel/presentation/providers/vessel_providers.dart';
import 'package:baystream/features/vessel/presentation/widgets/bay_plan_view.dart';
import 'package:baystream/features/vessel/presentation/widgets/loading_plan_controls.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/local_profile_test_support.dart';
import 'support/t117_oficina_support.dart';
import 'support/t121_estadisticas_support.dart';
import 'support/t75_memory_log.dart';
import 'support/t76_fixture.dart';
import 'support/t82_fixture.dart';
import 't81_office_changes_test.dart' as f;

/// Un plan de carga con un grupo de 40 pies: dos de 40 en la 22 y un 20 en
/// la 21 y otro en la 23, que la 22 cubre; y la 26 sola.
final _plan = t76Voyage([
  t76Unit('LONG0000022', '0220282').copyWith(isoSizeType: '42G1'),
  t76Unit('LONG0000023', '0220482').copyWith(isoSizeType: '42G1'),
  t76Unit('SHRT0000021', '0210282'),
  t76Unit('SHRT0000023', '0230282'),
  t76Unit('ALON0000026', '0260282'),
]);

/// El plano de [_plan], solo, en [tamano], en el [modo] y con la [bahia]
/// elegida; sin listado y sin movimientos.
Future<void> _plano(WidgetTester tester,
    {required Size tamano, required BayPlanMode modo, required int bahia}) async {
  tester.view.physicalSize = tamano;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final log = T75MemoryLog();
  LoadingOperation derive(List<MovementRecord> records) => LoadingOperation.build(
      operationId: 'op',
      loading: _plan,
      movements: records.map((r) => r.movement));
  final scope = ProviderContainer(overrides: [
    movementLogRepositoryProvider.overrideWith((ref) async => log),
    vesselRepositoryProvider.overrideWithValue(ParserOnlyRepository()),
    operatorProvider.overrideWith((ref) => Stream.value(f.dock)),
    activeOperationProvider.overrideWith((ref) async => f.operation),
    loadingOperationProvider(_plan).overrideWith((ref) async* {
      await for (final records in log.watch('op')) {
        yield derive(records);
      }
    }),
    loadingPlanProgressProvider(_plan).overrideWith((ref) async* {
      await for (final records in log.watch('op')) {
        yield derive(records).progress;
      }
    }),
  ]);
  addTearDown(scope.dispose);
  scope.read(bayPlanModeProvider.notifier).elegir(modo);
  scope.read(selectedBayProvider.notifier).select(bahia);
  await tester.pumpWidget(UncontrolledProviderScope(
      container: scope,
      child: MaterialApp(home: Scaffold(body: BayPlanView(voyage: _plan)))));
  await tester.pumpAndSettle();
}

String _ficha(WidgetTester tester, String clave) =>
    tester.widget<BsFichaDeCifra>(find.byKey(ValueKey(clave))).texto;

const _oficina = Size(1300, 900);
const _telefono = Size(360, 800);

void main() {
  group('1 · P2 · la ficha de la bahía dice lo de la que se ve y lo del grupo',
      () {
    testWidgets('en la oficina, en Carga, con la 21 elegida', (tester) async {
      await _plano(tester,
          tamano: _oficina, modo: BayPlanMode.loading, bahia: 21);
      final texto = _ficha(tester, 'loading-bay-pending');
      expect(texto, startsWith('Bahía 21: 1 contenedor, '),
          reason: 'el rótulo es el de la bahía cuyas cifras se leen');
      expect(texto, endsWith('; grupo 22 (21, 22 y 23), por cargar cub. 4, bod. 0'),
          reason: 'lo pendiente es del grupo, con el rótulo de su par');
      expect(tester.takeException(), isNull);
    });

    testWidgets('en la oficina, con la 22 elegida, el grupo también se nombra',
        (tester) async {
      await _plano(tester,
          tamano: _oficina, modo: BayPlanMode.loading, bahia: 22);
      final texto = _ficha(tester, 'loading-bay-pending');
      expect(texto, startsWith('Bahía 22: 2 contenedores, '));
      expect(texto, endsWith('; grupo 22 (21, 22 y 23), por cargar cub. 4, bod. 0'),
          reason: 'la 22 cuenta también la 21 y la 23: se dice');
    });

    testWidgets('una bahía sola sigue como antes, sin «grupo»', (tester) async {
      await _plano(tester,
          tamano: _oficina, modo: BayPlanMode.loading, bahia: 26);
      final texto = _ficha(tester, 'loading-bay-pending');
      expect(texto, startsWith('Bahía 26: 1 contenedor, '));
      expect(texto, endsWith('; por cargar cub. 1, bod. 0'));
      expect(texto, isNot(contains('grupo')));
    });

    testWidgets('en la oficina, en Contenido, con la 23 elegida',
        (tester) async {
      await _plano(tester,
          tamano: _oficina, modo: BayPlanMode.content, bahia: 23);
      final texto = _ficha(tester, 'bay-loading-pending');
      expect(texto, startsWith('Bahía 23: 1 contenedor, '));
      expect(
          texto,
          endsWith('; carga del grupo 22 (21, 22 y 23): '
              'cub. 4 (4 llenos, 0 vacíos), bod. 0 (0 llenos, 0 vacíos)'));
    });

    testWidgets('en el teléfono, sin las cifras, con la 21 elegida',
        (tester) async {
      await _plano(tester,
          tamano: _telefono, modo: BayPlanMode.loading, bahia: 21);
      expect(_ficha(tester, 'loading-bay-pending'),
          'Bahía 21: grupo 22 (21, 22 y 23), cub. 4, bod. 0');
      expect(tester.takeException(), isNull);
    });
  });

  group('2 · Estadísticas cuenta cada impar con la par que la cubre', () {
    test('la forma del plano de llegada (01 a 11): tres bahías, 02, 06 y 10',
        () {
      final viaje = t121ViajeCorto(t121Bahias9);
      final d = EstadisticasDelViaje.de(viaje);
      expect(d.bahias.map((b) => b.numero), <int>[2, 6, 10]);
      expect(d.bahiasConCarga, 3);
      // Cada grupo suma sus tres bahías, zona por zona y en peso.
      int cuantos(Iterable<int> bahias) => viaje.containers
          .where((c) => bahias.contains(c.stowagePosition!.bay))
          .length;
      final dos = d.bahias.first;
      expect(dos.contenedores, cuantos(<int>[1, 2, 3]));
      expect(dos.etiqueta, startsWith('Bahía 02, '));
      expect(d.bahias.fold<int>(0, (s, b) => s + b.contenedores), d.total);
    });

    test('el sintético de 977 (72 bahías): 24 grupos, de la 02 a la 94', () {
      final d = EstadisticasDelViaje.de(t121Sintetico977());
      expect(d.bahias.map((b) => b.numero),
          <int>[for (var b = 2; b <= 94; b += 4) b]);
      expect(d.bahiasConCarga, 24);
      expect(d.bahias.fold<int>(0, (s, b) => s + b.contenedores) + d.sinPosicion,
          977);
    });

    test('las impares vacías de T-117 se van con su par: 02 y 06', () {
      final d = EstadisticasDelViaje.de(t117SinEscala);
      expect(d.bahias.map((b) => b.numero), <int>[2, 6]);
      expect(d.bahias.first.contenedores, 12);
    });

    test('una impar sin par vecina en el viaje queda sola', () {
      final d = EstadisticasDelViaje.de(t121ViajeCorto(const <int>[1, 5, 9]));
      expect(d.bahias.map((b) => b.numero), <int>[1, 5, 9]);
    });

    testWidgets(
        'a 1920, la forma del plano de llegada da tres columnas en su tope, '
        'con el casco centrado; al tocar la 02 se abre la 02', (tester) async {
      int? abierta;
      await t121Pump(tester,
          voyage: t121ViajeCorto(t121Bahias9),
          tamano: const Size(1920, 1080),
          onBahia: (int b) => abierta = b);
      for (final b in <int>[1, 3, 5, 7, 9, 11]) {
        expect(find.byKey(ValueKey<String>('buque-en-corte-bahia-$b')),
            findsNothing,
            reason: 'la $b se cuenta con su par');
      }
      final vista = tester
          .getRect(find.byKey(const ValueKey<String>('buque-en-corte-scroll')));
      final columnas = <Rect>[
        for (final b in <int>[2, 6, 10])
          tester.getRect(find.byKey(ValueKey<String>('buque-en-corte-bahia-$b'))),
      ];
      for (final c in columnas) {
        expect(c.width,
            BsBuqueEnCorte.topeDeLaBahia * BsBuqueEnCorte.anchoBahiaBase);
      }
      final izquierda = columnas.first.left - vista.left;
      final derecha = vista.right - columnas.last.right;
      expect((izquierda - derecha).abs(), lessThanOrEqualTo(1),
          reason: 'el casco va centrado');
      await tester
          .tap(find.byKey(const ValueKey<String>('buque-en-corte-bahia-2')));
      await tester.pumpAndSettle();
      expect(abierta, 2);
      // «Ver como tabla» dice lo mismo: tres filas, rotuladas con la par.
      await tester.tap(find.text('Ver como tabla'));
      await tester.pumpAndSettle();
      expect(find.text('01'), findsNothing);
      expect(find.text('02'), findsWidgets);
      expect(tester.takeException(), isNull);
    });
  });

  testWidgets('3 · P3 · «1 contenedor a bordo en la salida», con su singular',
      (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    // Bajado el TSTU0000110, solo sigue a bordo el de paso.
    final scope = ProviderContainer(overrides: [
      operatorProvider.overrideWith((ref) => Stream.value(f.office)),
      activeOperationProvider.overrideWith((ref) async => t82Operation),
      loadingOperationProvider(t82Loading)
          .overrideWith((ref) => Stream.value(t82Derive([t82Loads.first]))),
    ]);
    addTearDown(scope.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(
        container: scope,
        child: MaterialApp(home: DepartureBapliePage(voyage: t82Loading))));
    await tester.pumpAndSettle();
    expect(find.text('1 contenedor a bordo en la salida.'), findsOneWidget);
    expect(find.textContaining('1 contenedores'), findsNothing);
  });
}
