// T-117 y T-118 · Corrección 2 de la entrega 1 (SPRINT-4.md 10.44): el hallazgo
// H4 de la reaceptación de Codex (docs/t117/entrega1/reaceptacion-codex.md),
// con la prueba que lo reproduce y que fallaba antes del arreglo.
//
// «Acciones» era un `PopupMenuButton` con un hijo propio: sin rol de botón y,
// solo con su icono, sin etiqueta. Windows toma el nombre de la etiqueta y le
// suma la descripción emergente: a 700 dp el icono
// desaparecía del árbol accesible, y a 600 dp, con su rótulo, salía «texto
// Acciones. Acciones». Ahora es el botón «Acciones», dicho una vez, con la
// cuenta del distintivo cuando la muestra, y la descripción emergente sigue al
// pasar el mouse, fuera de la semántica (DESIGN.md 14.8).
//
// El mismo patrón en lo que tocaron T-117 y T-118: el resumen de una línea del
// teléfono (`PlanSummaryLine`), un `InkWell` con su hijo, sin rol de botón.
import 'package:baystream/core/design/design.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/repositories/session_repository.dart';
import 'package:baystream/features/vessel/presentation/providers/loading_operation_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/sync_providers.dart';
import 'package:baystream/features/vessel/presentation/widgets/loading_plan_controls.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/t117_oficina_support.dart';
import 'support/t76_fixture.dart';

final _acciones = find.byKey(const ValueKey('bay-plan-actions'));
final _resumen = find.byKey(const ValueKey('plan-summary-toggle'));

/// El rótulo «Acciones» dentro del botón (no el de la descripción emergente).
final _rotulo =
    find.descendant(of: _acciones, matching: find.text('Acciones'));

/// El nodo de «Acciones» es un botón que se toca, con [nombre] por etiqueta y
/// el nombre dicho una sola vez: ni el rótulo pegado a la etiqueta ni la
/// descripción emergente, que Windows suma al nombre.
void _esElBoton(WidgetTester tester, {String nombre = 'Acciones'}) {
  expect(_acciones, findsOneWidget);
  final datos = tester.getSemantics(_acciones).getSemanticsData();
  expect(datos.label, nombre);
  expect(datos.flagsCollection.isButton, isTrue, reason: '$datos');
  expect(datos.hasAction(SemanticsAction.tap), isTrue, reason: '$datos');
  expect(datos.tooltip, isEmpty,
      reason: 'la descripción emergente repetiría el nombre en Windows');
  expect(RegExp('Acciones').allMatches('${datos.label} ${datos.tooltip}'),
      hasLength(1));
  expect(find.bySemanticsLabel(RegExp('^Acciones')), findsOneWidget,
      reason: 'un solo nodo con ese nombre');
}

void main() {
  group('H4 · «Acciones» es un botón con su nombre (14.8)', () {
    for (final modo in [BayPlanMode.content, BayPlanMode.discharge]) {
      testWidgets(
          'a 700 dp en ${modo.name}, solo con el icono, es el botón «Acciones»',
          (tester) async {
        final semantica = tester.ensureSemantics();
        await t117Pump(tester, tamano: const Size(700, 682), modo: modo);
        expect(_rotulo, findsNothing, reason: 'la cuarta variante: el icono');
        _esElBoton(tester);
        semantica.dispose();
      });
    }

    testWidgets(
        'a 600 dp en Descarga, con su rótulo, el nombre no se repite y no es '
        'texto', (tester) async {
      final semantica = tester.ensureSemantics();
      await t117Pump(tester,
          tamano: const Size(600, 682), modo: BayPlanMode.discharge);
      expect(_rotulo, findsOneWidget, reason: 'la variante con el rótulo');
      _esElBoton(tester);
      semantica.dispose();
    });

    testWidgets('en el teléfono, solo con el icono, es el mismo botón',
        (tester) async {
      final semantica = tester.ensureSemantics();
      await t117Pump(tester, tamano: const Size(360, 800));
      expect(_rotulo, findsNothing);
      _esElBoton(tester);
      semantica.dispose();
    });

    testWidgets(
        'el lector de pantalla lo toca y abre el menú; la descripción '
        'emergente sigue al pasar el mouse', (tester) async {
      final semantica = tester.ensureSemantics();
      await t117Pump(tester, tamano: const Size(700, 682));
      expect(find.byType(PopupMenuItem<VoidCallback>), findsNothing);
      tester.semantics.tap(find.semantics.byLabel('Acciones'));
      await tester.pumpAndSettle();
      expect(find.byType(PopupMenuItem<VoidCallback>), findsWidgets);
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();
      expect(find.byType(PopupMenuItem<VoidCallback>), findsNothing);

      final raton = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await raton.addPointer(location: Offset.zero);
      addTearDown(raton.removePointer);
      expect(find.text('Acciones'), findsNothing);
      await raton.moveTo(tester.getCenter(_acciones));
      await tester.pumpAndSettle();
      expect(find.text('Acciones'), findsOneWidget,
          reason: 'la descripción emergente, con el icono solo');
      await raton.moveTo(Offset.zero);
      await tester.pumpAndSettle(const Duration(seconds: 1));
      semantica.dispose();
    });

    // La cuenta del distintivo (las solicitudes de cambio pendientes) va en
    // el nombre, con el icono y con el rótulo.
    final operacion = Operation(
        id: 'op',
        vesselName: 'PRUEBA',
        voyageNumber: 'VTEST',
        portOfCall: 'GTSTC',
        createdAt: DateTime.utc(2026),
        published: true);
    const oficina = Operator(
        uid: 'prueba-office', name: 'Oficina', role: OperatorRole.office);
    final solicitud = t76Movement(
        MovementDraft.requestChange('op', const [
          PositionChange('C:FULL0001234', '0030282', '0030682'),
          PositionChange('C:FULL0005678', '0030682', '0030282'),
        ], 'Intercambio'),
        1);
    for (final soloIcono in [true, false]) {
      testWidgets(
          '${soloIcono ? 'solo con el icono' : 'con el rótulo'}, el nombre '
          'lleva la cuenta del distintivo', (tester) async {
        final semantica = tester.ensureSemantics();
        await tester.pumpWidget(ProviderScope(
          overrides: [
            activeOperationProvider.overrideWith((ref) async => operacion),
            operatorProvider.overrideWith((ref) => Stream.value(oficina)),
            loadingOperationProvider(t76Loading).overrideWith(
                (ref) => Stream.value(t76Operation([solicitud]))),
          ],
          child: MaterialApp(
            theme: BayStreamTema.claro(),
            home: Scaffold(
              body: Center(
                child: AccionesDelPlano(
                  voyage: t76Loading,
                  selectedBay: null,
                  dischargeMode: false,
                  loadingMode: false,
                  onPendingTable: null,
                  onProgress: null,
                  soloIcono: soloIcono,
                ),
              ),
            ),
          ),
        ));
        await tester.pumpAndSettle();
        expect(find.descendant(of: _acciones, matching: find.text('1')),
            findsOneWidget,
            reason: 'el distintivo con la cuenta');
        _esElBoton(tester, nombre: 'Acciones, 1 solicitud pendiente');
        semantica.dispose();
      });
    }
  });

  group('el mismo patrón: el resumen de una línea del teléfono', () {
    testWidgets(
        'es un botón que se toca, que se abre y se recoge, y su nombre no se '
        'repite', (tester) async {
      final semantica = tester.ensureSemantics();
      await t117Pump(tester, tamano: const Size(360, 800));
      expect(_resumen, findsOneWidget);
      for (final dice in ['Ver el resumen completo', 'Recoger el resumen']) {
        final datos = tester.getSemantics(_resumen).getSemanticsData();
        expect(datos.flagsCollection.isButton, isTrue, reason: '$datos');
        expect(datos.hasAction(SemanticsAction.tap), isTrue, reason: '$datos');
        expect(RegExp(dice).allMatches(datos.label), hasLength(1),
            reason: datos.label);
        await tester.ensureVisible(_resumen);
        await tester.pumpAndSettle();
        await tester.tap(_resumen);
        await tester.pumpAndSettle();
      }
      semantica.dispose();
    });
  });
}
