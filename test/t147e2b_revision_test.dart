// T-147, entrega 2, parte 2b · Lo que sumaron la revisión y la aceptación de
// la 2a: O-147-7 (la tarjeta de las celdas sin dueño), O-147-8 (cuatro
// textos), O-147-9 (el motivo, a la vista) y O-147-10 (el lápiz).
//
// Compila también contra la punta de la 2a, para que la roja de cada punto
// sea por comportamiento.
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/repositories/departure_export_repository.dart';
import 'package:baystream/features/vessel/domain/services/export_list_cross_checker.dart';
import 'package:baystream/features/vessel/presentation/pages/departure_baplie_page.dart';
import 'package:baystream/features/vessel/presentation/pages/operation_progress_page.dart';
import 'package:baystream/features/vessel/presentation/providers/export_list_providers.dart';
import 'package:baystream/features/vessel/presentation/providers/loading_operation_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/sync_providers.dart';
import 'package:baystream/features/vessel/presentation/widgets/loading_controls.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/t147_listado_support.dart';
import 'support/t147e2_support.dart';

/// El plan de «también llena» de la 2a: 40HC repartido en 45G1 y 45G0, 20TK
/// en 22K2 y 22T1, y celdas reservadas de códigos que nadie llena.
final _ediDeLosTipos = e2PlanEdi([
  e2Grupo('0100282', t147Matricula(1), '45G1', 'COCTG', 'LNH'),
  e2Grupo('0100482', t147Matricula(2), '45G1', 'COCTG', 'LNH'),
  e2Grupo('0100682', t147Matricula(3), '45G0', 'COCTG', 'LNH'),
  e2Grupo('0110282', t147Matricula(4), '22K2', 'COCTG', 'LNH'),
  e2Grupo('0110482', t147Matricula(5), '22T1', 'COCTG', 'LNH'),
  e2Grupo('0110682', t147Matricula(6), '22K2', 'COCTG', 'LNH'),
  e2Reserva('0180082', '45G1', 'COTRB', 'LNH'),
  e2Reserva('0180282', '45G0', 'COTRB', 'LNH'),
  e2Reserva('0180482', 'L5G1', 'COTRB', 'LNH'),
  e2Reserva('0180682', 'L5G0', 'COTRB', 'LNH'),
  e2Reserva('0190282', '22T4', 'COCTG', 'LNH'),
  e2Reserva('0200082', '49P9', 'JMKIN', 'LNH'),
]);

List<List<Object?>> _hojaDeLosTipos() => [
      e2Fila(1, 1, '40HC', 'COCTG', 'LGH'),
      e2Fila(2, 2, '40HC', 'COCTG', 'LGH'),
      e2Fila(3, 3, '40HC', 'COCTG', 'LGH'),
      e2Fila(4, 4, '20TK', 'COCTG', 'LGH'),
      e2Fila(5, 5, '20TK', 'COCTG', 'LGH'),
      e2Fila(6, 6, '20TK', 'COCTG', 'LGH'),
      e2Fila(7, 11, '40HC', 'COTRB', 'LGH', vacio: true),
      e2Fila(8, 12, '40HC', 'COTRB', 'LGH', vacio: true),
      e2Fila(9, 13, '45HC', 'COTRB', 'LGH', vacio: true),
      e2Fila(10, 14, '45HC', 'COTRB', 'LGH', vacio: true),
      e2Fila(11, 15, '20TK', 'COCTG', 'LGH', vacio: true),
    ];

List<String> _codigos(Iterable<OrphanTypeCode> celdas) =>
    [for (final c in celdas) c.code];

class _Guardar implements DepartureExportRepository {
  @override
  Future<String?> save(Operation operation, String edi) async => null;
}

/// El rectángulo de lo que se ve del diálogo: su zona desplazable.
Rect _loQueSeVe(WidgetTester tester) => tester.getRect(find
    .descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(SingleChildScrollView))
    .first);

void main() {
  group('O-147-7 · La tarjeta de las celdas sin dueño', () {
    final plan = e2Plan(_ediDeLosTipos);
    final lista = e2Listado(_hojaDeLosTipos());

    test('con un tipo por elegir no dice nada; elegido, las de verdad', () {
      final pendientes = ExportListCrossChecker.propose(lista, plan,
          portOfCall: e2Escala);
      expect([
        for (final p in pendientes)
          if (p.kind == EquivalenceKind.type && p.needsUser) p.listCode
      ], ['45HC']);
      expect(
          ExportListCrossChecker.orphanTypeCodes(pendientes, plan,
              portOfCall: e2Escala),
          isEmpty,
          reason: 'la 2a contaba como sin dueño las celdas del tipo que '
              'todavía no se había elegido');
      final elegidas = e2Proponer(lista, plan, tipos: {'45HC': 'L5G1'});
      expect(
          _codigos(ExportListCrossChecker.orphanTypeCodes(elegidas, plan,
              portOfCall: e2Escala)),
          ['22T4', '49P9', 'L5G0']);
    });

    testWidgets('en pantalla sale al elegir el último tipo, y a 360 dp las '
        'tres fichas van en una línea', (tester) async {
      // Con la letra de verdad: la de las pruebas es más ancha.
      await (FontLoader('Roboto')
            ..addFont(rootBundle.load('assets/fonts/Roboto-Regular.ttf')))
          .load();
      final scope = await e2AbrirLaPagina(tester, plan, lista);
      expect(find.byKey(const ValueKey('orphan-codes')), findsNothing,
          reason: 'la 2a la enseñaba con 45HC todavía por elegir');
      scope
          .read(exportListImportProvider.notifier)
          .choose(EquivalenceKind.type, '45HC', 'L5G1');
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('orphan-codes')), findsOneWidget);
      expect(
          e2Textos(tester, 'Celdas reservadas que ningún tipo'),
          ['Celdas reservadas que ningún tipo del listado llena (3)']);
      // L5G0 trae sugerencia: «Sí», «Otro tipo…» y «No».
      final si = tester.getRect(find.byKey(const ValueKey('orphan-yes-L5G0')));
      final otro =
          tester.getRect(find.byKey(const ValueKey('orphan-other-L5G0')));
      final no = tester.getRect(find.byKey(const ValueKey('orphan-no-L5G0')));
      expect(otro.top, si.top);
      expect(no.top, si.top,
          reason: 'en la 2a «No: piden motivo» bajaba a otra línea');
      expect(no.right, lessThanOrEqualTo(360));
      expect(
          find.descendant(
              of: find.byKey(const ValueKey('orphan-no-L5G0')),
              matching: find.text('No')),
          findsOneWidget);
      // Y sigue diciendo qué pasa al elegirlo.
      await tester.tap(find.byKey(const ValueKey('orphan-no-L5G0')));
      await tester.pumpAndSettle();
      expect(e2Textos(tester, 'L5G0 · 1 celda'),
          ['L5G0 · 1 celda: pide motivo al cargar.']);
      expect(tester.takeException(), isNull);
    });
  });

  group('O-147-8 · Cuatro textos', () {
    final plan = e2Plan(e2EdiDeLasCanceladas);

    /// Las canceladas de la 2a, con POT y POD distintos en dos filas que se
    /// cargan (OR 1 y 2) y en una cancelada (OR 3).
    ExportList lista() {
      final hoja = e2HojaDeLasCanceladas();
      for (final fila in hoja.take(3)) {
        fila[4] = 'INMUN';
      }
      return e2Listado(hoja);
    }

    ExportList normalizada() {
      final leida = lista();
      return e2Normalizar(
          leida, e2Proponer(leida, plan, tipos: {'20ST': '22G1'}));
    }

    final lleno = e2Movimiento(
        MovementDraft.loadFull('e2', t147Matricula(3), '0100682',
            order: 3, reason: 'Llegó al gancho y subió'),
        1);

    testWidgets('(a) el resumen cuenta el POT y el POD de las que se cargan',
        (tester) async {
      await e2AbrirLaPagina(tester, plan, lista());
      final texto = tester
          .widget<Text>(find.byKey(const ValueKey('export-list-pot')))
          .data!;
      expect(
          texto,
          startsWith('2 filas que se cargan traen POT y POD distintos '
              '(y 1 cancelada): el cruce con el plan usa el POT'),
          reason: 'la 2a decía «3 filas traen POT y POD distintos», contando '
              'la cancelada');
      expect(tester.takeException(), isNull);
    });

    Future<void> abrirElAvance(
        WidgetTester tester, List<Movement> movimientos) async {
      tester.view.physicalSize = const Size(360, 3000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(ProviderScope(
          overrides: [
            loadingOperationProvider(plan).overrideWith((ref) =>
                Stream.value(e2Operacion(plan, normalizada(), movimientos))),
          ],
          child: MaterialApp(home: OperationProgressPage(voyage: plan))));
      await tester.pumpAndSettle();
    }

    testWidgets('(b) el avance dice cuántas canceladas están a bordo',
        (tester) async {
      await abrirElAvance(tester, [lleno]);
      final texto = tester
          .widget<Text>(find.byKey(const ValueKey('progress-list-cancelled')))
          .data!;
      expect(
          texto,
          'Listado: 8 filas canceladas (7 llenos y 1 vacío): 7 no se cargan y '
          '1 está a bordo.',
          reason: 'la 2a decía que ninguna se carga, con una a bordo');
      expect(tester.takeException(), isNull);
    });

    testWidgets('(b) sin ninguna a bordo dice lo de la 2a', (tester) async {
      await abrirElAvance(tester, const []);
      expect(
          tester
              .widget<Text>(
                  find.byKey(const ValueKey('progress-list-cancelled')))
              .data,
          'Listado: 8 filas canceladas, que no se cargan (7 llenos y 1 '
          'vacío).');
    });

    testWidgets('(c) la salida dice «1 conflicto vigente», en singular',
        (tester) async {
      tester.view.physicalSize = const Size(360, 4000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(ProviderScope(
          overrides: [
            operatorProvider.overrideWith((ref) => Stream.value(null)),
            activeOperationProvider.overrideWith(
                (ref) async => e2OperacionGuardada(e2EdiDeLasCanceladas, plan)),
            loadingOperationProvider(plan).overrideWith((ref) =>
                Stream.value(e2Operacion(plan, normalizada(), [lleno]))),
            departureExportRepositoryProvider.overrideWithValue(_Guardar()),
          ],
          child: MaterialApp(home: DepartureBapliePage(voyage: plan))));
      await tester.pumpAndSettle();
      final lineas = e2Textos(tester, 'Revisa el avance');
      expect(lineas, hasLength(1));
      expect(lineas.single, startsWith('1 conflicto vigente. Revisa el avance'),
          reason: 'la 2a decía «1 conflictos vigentes»');
      expect(tester.takeException(), isNull);
    });

    testWidgets('(d) el detalle de la celda no manda al detalle de la celda',
        (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final datos = e2Operacion(plan, normalizada(), [lleno]);
      // El mensaje que se deriva no cambia: el avance lo sigue diciendo
      // entero.
      expect(datos.state.conflicts.single.message,
          endsWith('deshazlo desde el detalle de la celda.'));
      await tester.pumpWidget(ProviderScope(
          overrides: [
            operatorProvider.overrideWith((ref) => Stream.value(null)),
            activeOperationProvider.overrideWith((ref) async => null),
            loadingOperationProvider(plan)
                .overrideWith((ref) => Stream.value(datos)),
          ],
          child: MaterialApp(
              home: Scaffold(
                  body: Builder(
                      builder: (context) => TextButton(
                          onPressed: () => showLoadingDetails(
                              context, plan, 'C:${t147Matricula(3)}'),
                          child: const Text('abrir')))))));
      await tester.pumpAndSettle();
      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();
      final conflicto = e2Textos(tester, 'lo marca cancelado');
      final esperado = 'OR 3 · ${t147Matricula(3)} se cargó y el listado lo '
          'marca cancelado («ROLEADO - CANCEL»).';
      expect(conflicto, [esperado],
          reason: 'la 2a terminaba «deshazlo desde el detalle de la celda»');
      expect(find.text('Deshacer carga'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('O-147-9 · Cuando la carga pide motivo, su campo está a la vista', () {
    // El plan de las canceladas, con una celda de 40 pies de otro grupo.
    final plan = e2Plan(e2PlanEdi([
      e2Grupo('0100282', t147Matricula(1), '45G1', 'COCTG', 'LNH'),
      e2Grupo('0100482', t147Matricula(2), '45G1', 'COCTG', 'LNH'),
      e2Grupo('0100682', t147Matricula(3), '45G1', 'COCTG', 'LNH'),
      e2Reserva('0180082', '45G1', 'COTRB', 'LNH'),
      e2Reserva('0180282', '45G1', 'COTRB', 'LNH'),
      e2Reserva('0190682', '22G1', 'JMKIN', 'LNJ'),
      e2Reserva('0200082', '45G1', 'JMKIN', 'LNJ'),
    ]));
    final leida = e2Listado(e2HojaDeLasCanceladas());
    final lista =
        e2Normalizar(leida, e2Proponer(leida, plan, tipos: {'20ST': '22G1'}));
    ReservedSlot celda(String posicion) => plan.reservedSlots
        .firstWhere((s) => s.stowagePosition.toIsoCode() == posicion);

    Future<void> abrir(WidgetTester tester, int orden,
        {ReservedSlot? enLaCelda}) async {
      // Con la letra de verdad: la de las pruebas es más ancha y parte los
      // textos en más líneas de las que salen en el teléfono.
      await (FontLoader('Roboto')
            ..addFont(rootBundle.load('assets/fonts/Roboto-Regular.ttf')))
          .load();
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final datos = e2Operacion(plan, lista);
      await tester.pumpWidget(ProviderScope(
          overrides: [
            operatorProvider.overrideWith((ref) => Stream.value(null)),
            activeOperationProvider.overrideWith((ref) async => null),
            loadingOperationProvider(plan)
                .overrideWith((ref) => Stream.value(datos)),
          ],
          child: MaterialApp(
              home: Scaffold(
                  body: Consumer(builder: (context, ref, _) {
                // Como en el plano: alguien sigue la operación.
                ref.watch(loadingOperationProvider(plan));
                return TextButton(
                    onPressed: () => openLoadingRow(
                        context, ref, plan, lista.byOrder(orden)!,
                        slot: enLaCelda),
                    child: const Text('abrir'));
              })))));
      await tester.pumpAndSettle();
      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();
    }

    void aLaVista(WidgetTester tester, String aviso) {
      final seVe = _loQueSeVe(tester);
      final pide = find.textContaining(aviso);
      expect(pide, findsOneWidget);
      final motivo = find.byKey(const ValueKey('loading-reason'));
      expect(motivo, findsOneWidget);
      expect(find.text('Motivo (obligatorio)'), findsOneWidget);
      final rAviso = tester.getRect(pide);
      final rMotivo = tester.getRect(motivo);
      final rHora = tester.getRect(find.byKey(const ValueKey('loading-hour')));
      expect(rMotivo.top, greaterThanOrEqualTo(rAviso.bottom),
          reason: 'el motivo va debajo del aviso que lo pide');
      expect(rMotivo.top, lessThan(rHora.top),
          reason: 'en la 2a iba debajo de la hora, la fecha y el marchamo');
      // Sin desplazar: el aviso y el campo caben en lo que se ve.
      expect(rAviso.top, greaterThanOrEqualTo(seVe.top));
      expect(rMotivo.bottom, lessThanOrEqualTo(seVe.bottom),
          reason: 'en la 2a el campo quedaba fuera de la pantalla a 360 × 800');
      final confirmar =
          tester.getRect(find.byKey(const ValueKey('loading-confirm')));
      expect(confirmar.bottom, lessThanOrEqualTo(800));
      expect(tester.takeException(), isNull);
    }

    testWidgets('con el vacío cancelado', (tester) async {
      await abrir(tester, 11, enLaCelda: celda('0180082'));
      aLaVista(tester, 'lo marca cancelado');
    });

    testWidgets('con el lleno cancelado', (tester) async {
      await abrir(tester, 3);
      aLaVista(tester, 'lo marca cancelado');
    });

    testWidgets('con una celda de otro grupo', (tester) async {
      // OR 9 es un 40HC de COTRB; la celda 020-00-82 es de 45G1 a JMKIN.
      await abrir(tester, 9, enLaCelda: celda('0200082'));
      final seVe = _loQueSeVe(tester);
      final motivo =
          tester.getRect(find.byKey(const ValueKey('loading-reason')));
      final hora = tester.getRect(find.byKey(const ValueKey('loading-hour')));
      expect(motivo.top, lessThan(hora.top),
          reason: 'en la 2a iba debajo de la hora, la fecha y el marchamo');
      expect(motivo.bottom, lessThanOrEqualTo(seVe.bottom));
      expect(tester.takeException(), isNull);
    });

    testWidgets('sin nada que pida motivo, el diálogo queda como estaba',
        (tester) async {
      await abrir(tester, 9, enLaCelda: celda('0180082'));
      expect(find.byKey(const ValueKey('loading-reason')), findsNothing);
      expect(find.byKey(const ValueKey('loading-hour')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('O-147-10 · El lápiz', () {
    final plan = e2Plan(_ediDeLosTipos);
    final lista = e2Listado(_hojaDeLosTipos());

    test('el código que deja de ser principal se queda como «también» si el '
        'plan lo respalda', () {
      final hc = e2De(
          ExportListCrossChecker.propose(lista, plan, portOfCall: e2Escala),
          EquivalenceKind.type,
          '40HC');
      expect(hc.planCode, '45G1');
      expect(hc.also, ['45G0']);
      final cambiada = hc.choose('45G0');
      expect(cambiada.planCode, '45G0');
      expect(cambiada.also, ['45G1'],
          reason: 'en la 2a 45G1 se perdía, y sus celdas volvían a la '
              'tarjeta');
      // Y de vuelta.
      final deVuelta = cambiada.choose('45G1');
      expect(deVuelta.planCode, '45G1');
      expect(deVuelta.also, ['45G0']);
    });

    test('si el plan no lo respalda, se pierde, como en la 2a', () {
      final hc = e2De(
          ExportListCrossChecker.propose(lista, plan, portOfCall: e2Escala),
          EquivalenceKind.type,
          '40HC');
      // 49P9 no está en lo que dicen los contenedores de 40HC.
      final rara = hc.choose('49P9');
      expect(rara.planCode, '49P9');
      expect(rara.also, ['45G1', '45G0']);
      final otra = rara.choose('45G1');
      expect(otra.planCode, '45G1');
      expect(otra.also, ['45G0'],
          reason: '49P9 no tiene respaldo: no se queda como «también»');
    });

    testWidgets('en pantalla: 40HC cambiado a 45G0 conserva 45G1, y el cruce '
        'sigue cuadrando', (tester) async {
      final scope = await e2AbrirLaPagina(tester, plan, lista);
      final importacion = scope.read(exportListImportProvider.notifier);
      importacion.choose(EquivalenceKind.type, '45HC', 'L5G1');
      await tester.pumpAndSettle();
      final antes = scope.read(exportListImportProvider);
      importacion.choose(EquivalenceKind.type, '40HC', '45G0');
      await tester.pumpAndSettle();
      final despues = scope.read(exportListImportProvider);
      final hc = e2De(despues.proposals, EquivalenceKind.type, '40HC');
      expect(hc.planCode, '45G0');
      expect(hc.also, ['45G1'], reason: 'en la 2a 45G1 se perdía');
      expect(_codigos(despues.orphans), _codigos(antes.orphans),
          reason: 'en la 2a las celdas 45G1 volvían a la tarjeta');
      expect(despues.conflicts, isEmpty);
      expect(despues.crossCheck!.groups.map((g) => g.balanced),
          antes.crossCheck!.groups.map((g) => g.balanced));
      expect(find.byTooltip('Quitar 45G1 de 40HC'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('si otro tipo ya lo tiene de principal, no se queda: no hay '
        'choque', (tester) async {
      // 45HC se elige 45G1, el principal de 40HC; después, 40HC pasa a 45G0.
      final scope = await e2AbrirLaPagina(tester, plan, lista);
      final importacion = scope.read(exportListImportProvider.notifier);
      importacion.choose(EquivalenceKind.type, '45HC', '45G1');
      await tester.pumpAndSettle();
      importacion.choose(EquivalenceKind.type, '40HC', '45G0');
      await tester.pumpAndSettle();
      final estado = scope.read(exportListImportProvider);
      final hc = e2De(estado.proposals, EquivalenceKind.type, '40HC');
      expect(hc.planCode, '45G0');
      expect(hc.also, isNot(contains('45G1')));
      expect(e2De(estado.proposals, EquivalenceKind.type, '45HC').planCode,
          '45G1');
      expect(estado.conflicts, isEmpty);
      expect(tester.takeException(), isNull);
    });
  });
}
