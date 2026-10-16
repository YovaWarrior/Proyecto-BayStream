import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/repositories/session_repository.dart';
import 'package:baystream/features/vessel/domain/services/loading_operation.dart';
import 'package:baystream/features/vessel/presentation/providers/loading_operation_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/loading_plan_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/movement_log_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/sync_providers.dart';
import 'package:baystream/features/vessel/presentation/providers/vessel_providers.dart';
import 'package:baystream/features/vessel/presentation/widgets/bay_plan_view.dart';
import 'package:baystream/features/vessel/presentation/widgets/plan_drag_confirmation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'support/local_profile_test_support.dart';
import 'support/t75_memory_log.dart';
import 'support/t76_fixture.dart';
import 't105_preview_test.dart' show t105Data;
import 't81_office_changes_test.dart' as f;

Future<(T75MemoryLog, ProviderContainer)> start(WidgetTester tester,
    {Operator? actor = f.office,
    bool closed = false,
    bool published = true,
    Brightness brightness = Brightness.light,
    List<MovementDraft> initial = const []}) async {
  final log = T75MemoryLog();
  for (final draft in initial) {
    await log.append(draft, f.office.author);
  }
  final scope = ProviderContainer(overrides: [
    movementLogRepositoryProvider.overrideWith((ref) async => log),
    vesselRepositoryProvider.overrideWithValue(ParserOnlyRepository()),
    operatorProvider.overrideWith((ref) => Stream.value(actor)),
    activeOperationProvider.overrideWith((ref) async => f.operation.copyWith(
        published: published, closedAt: closed ? DateTime.utc(2026) : null)),
    loadingOperationProvider(t76Loading).overrideWith((ref) async* {
      await for (final records in log.watch('op')) {
        yield t105Data(records.map((r) => r.movement).toList());
      }
    }),
    loadingPlanProgressProvider(t76Loading).overrideWith((ref) async* {
      await for (final records in log.watch('op')) {
        yield t105Data(records.map((r) => r.movement).toList()).progress;
      }
    }),
  ]);
  addTearDown(scope.dispose);
  await tester.pumpWidget(UncontrolledProviderScope(
      container: scope,
      child: MaterialApp(
          theme: ThemeData(brightness: brightness),
          home: Scaffold(body: BayPlanView(voyage: t76Loading)))));
  await tester.pumpAndSettle();
  await mode(tester, 'Carga');
  return (log, scope);
}

Future<void> mode(WidgetTester tester, String text) async {
  await tester.tap(find.byKey(const ValueKey('bay-plan-display-mode')));
  await tester.pumpAndSettle();
  await tester.tap(find.text(text).last);
  await tester.pumpAndSettle();
}

Future<void> openZoom(WidgetTester tester) async {
  if (find.byKey(const ValueKey('plan-zoom-in')).evaluate().isEmpty) {
    await tester.tap(find.byKey(const ValueKey('plan-zoom-toggle')));
    await tester.pumpAndSettle();
  }
}

Future<void> drag(WidgetTester tester, String from, String to,
    {String expected = 'valid',
    PointerDeviceKind kind = PointerDeviceKind.touch}) async {
  final origin = find.byKey(ValueKey('plan-cell-$from'));
  final destination = find.byKey(ValueKey('plan-cell-$to'));
  await Scrollable.ensureVisible(tester.element(origin), alignment: .5);
  await Scrollable.ensureVisible(tester.element(destination), alignment: .5);
  final gesture =
      await tester.startGesture(tester.getCenter(origin), kind: kind);
  await tester.pump(const Duration(milliseconds: 600));
  await gesture.moveTo(tester.getCenter(destination));
  await tester.pump();
  expect(find.byKey(ValueKey('plan-preview-$expected-$to')), findsOneWidget);
  await gesture.up();
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('T-105 a 300 % se alcanzan ambos bordes y el toque abre detalle',
      (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final (log, _) = await start(tester, actor: null);
    await openZoom(tester);
    for (var i = 0; i < 8; i++) {
      await tester.tap(find.byKey(const ValueKey('plan-zoom-in')));
      await tester.pumpAndSettle();
    }
    await tester.tap(find.byKey(const ValueKey('plan-zoom-toggle')));
    await tester.pumpAndSettle();
    expect(find.text('300 %'), findsOneWidget);
    final viewport =
        tester.getRect(find.byKey(const ValueKey('plan-zoom-gesture')));
    for (final position in ['0030882', '0030582', '0030282']) {
      final cell = find.byKey(ValueKey('plan-cell-$position'));
      await Scrollable.ensureVisible(tester.element(cell), alignment: .5);
      await tester.pumpAndSettle();
      expect(viewport.contains(tester.getCenter(cell)), isTrue);
      expect(cell.hitTestable(), findsOneWidget);
    }
    await tester.tap(find.byKey(const ValueKey('plan-cell-0030282')));
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
    expect(log.of('op'), isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets('T-105 zoom con ratón conserva arrastre y cancelación',
      (tester) async {
    final (log, _) = await start(tester);
    final cell = find.byKey(const ValueKey('plan-cell-0030282'));
    final width = tester.getSize(cell).width;
    await openZoom(tester);
    await tester.tap(find.byKey(const ValueKey('plan-zoom-in')));
    await tester.pumpAndSettle();
    expect(find.text('125 %'), findsOneWidget);
    expect(tester.getRect(cell).width, closeTo(width * 1.25, .1));
    await drag(tester, '0030282', '0030082', kind: PointerDeviceKind.mouse);
    expect(find.byType(PlanDragConfirmation), findsOneWidget);
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(log.of('op'), isEmpty);
    await openZoom(tester);
    await tester.tap(find.byKey(const ValueKey('plan-zoom-reset')));
    await tester.pumpAndSettle();
    expect(tester.getRect(cell).width, closeTo(width, .1));
    expect(tester.takeException(), isNull);
  });

  testWidgets('T-105 pellizco a 360 dp amplía y deja desplazar la rejilla',
      (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final (log, _) = await start(tester);
    final viewport = find.byKey(const ValueKey('plan-zoom-gesture'));
    final center = tester.getCenter(viewport);
    final first =
        await tester.startGesture(center - const Offset(30, 0), pointer: 1);
    final second =
        await tester.startGesture(center + const Offset(30, 0), pointer: 2);
    await tester.pump();
    await first.moveTo(center - const Offset(60, 0));
    await second.moveTo(center + const Offset(60, 0));
    await tester.pump();
    await first.up();
    await second.up();
    await tester.pumpAndSettle();
    final percent =
        tester.widget<Text>(find.textContaining(RegExp(r'^\d+ %$')));
    expect(int.parse(percent.data!.split(' ').first), greaterThan(100));
    final cell = find.byKey(const ValueKey('plan-cell-0030282'));
    await Scrollable.ensureVisible(tester.element(cell), alignment: .5);
    await tester.pumpAndSettle();
    final before = tester.getCenter(cell);
    await tester.drag(cell, const Offset(-80, 0));
    await tester.pumpAndSettle();
    expect(tester.getCenter(cell).dx, lessThan(before.dx));
    expect(find.byType(PlanDragConfirmation), findsNothing);
    expect(log.of('op'), isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'T-105 descarga y tránsito no se arrastran aunque aparezcan en Carga',
      (tester) async {
    final discharge = t76Unit('DISCHARGE', '0030282', incoming: true);
    final transit = t76Unit('TRANSIT', '0030482', incoming: true)
        .copyWith(portOfDischarge: 'PAMIT');
    final voyage =
        t76Voyage([discharge, transit, t76Unit('PENDING', '0030682')]);
    final data = LoadingOperation.build(
        operationId: 'op',
        arrival: t76Voyage([discharge, transit]),
        loading: voyage);
    expect(data.state['C:DISCHARGE']!.role, PlanRole.discharge);
    expect(data.state['C:TRANSIT']!.role, PlanRole.transit);
    final scope = ProviderContainer(overrides: [
      movementLogRepositoryProvider.overrideWith((ref) async => T75MemoryLog()),
      vesselRepositoryProvider.overrideWithValue(ParserOnlyRepository()),
      operatorProvider.overrideWith((ref) => Stream.value(f.office)),
      activeOperationProvider.overrideWith((ref) async => f.operation),
      loadingOperationProvider(voyage)
          .overrideWith((ref) => Stream.value(data)),
      loadingPlanProgressProvider(voyage)
          .overrideWith((ref) => Stream.value(data.progress)),
    ]);
    addTearDown(scope.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(
        container: scope,
        child: MaterialApp(home: Scaffold(body: BayPlanView(voyage: voyage)))));
    await tester.pumpAndSettle();
    await mode(tester, 'Carga');
    expect(find.byKey(const ValueKey('plan-drag-C:DISCHARGE')), findsNothing);
    expect(find.byKey(const ValueKey('plan-drag-C:TRANSIT')), findsNothing);
    expect(find.byKey(const ValueKey('plan-drag-C:PENDING')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  for (final brightness in Brightness.values) {
    testWidgets(
        'T-105 360 dp ${brightness.name}: reserva, motivo libre y cancelar',
        (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final (log, _) = await start(tester, brightness: brightness);
      await drag(tester, '0030482', '0030082');
      await tester.enterText(find.byKey(const ValueKey('plan-drag-reason')),
          'Motivo escrito a mano');
      await tester.pumpAndSettle();
      expect(
          tester
              .widget<FilledButton>(
                  find.byKey(const ValueKey('plan-drag-confirm')))
              .onPressed,
          isNotNull);
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();
      expect(log.of('op'), isEmpty);
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets(
      'T-105 la oficina ve el reloj de una solicitud llegada por el stream',
      (tester) async {
    final (log, scope) = await start(tester);
    await log.append(
        MovementDraft.requestChange(
            'op',
            const [PositionChange(f.key, '0030282', '0030082')],
            'Solicitud remota'),
        f.dock.author);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('plan-pending-0030082')), findsOneWidget);
    expect(
        scope
            .read(loadingOperationProvider(t76Loading))
            .value!
            .plan
            .loading[f.key]!
            .plannedPosition,
        '0030282');
    await log.append(
        MovementDraft.rejectChange(
            'op', log.of('op').single.movement.id, 'No procede'),
        f.office.author);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('plan-pending-0030082')), findsNothing);
  });
  testWidgets('T-105 40 en impar: rojo con mensaje de review', (tester) async {
    final (log, _) = await start(tester);
    await drag(tester, '0030182', '0030082', expected: 'invalid');
    expect(find.textContaining('no cabe en la bahía 3'), findsOneWidget);
    expect(find.byType(PlanDragConfirmation), findsNothing);
    expect(log.of('op'), isEmpty);
  });
  testWidgets(
      'T-105 deslizar sobre un pendiente desplaza sin iniciar el arrastre',
      (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final (log, _) = await start(tester);
    final cell = find.byKey(const ValueKey('plan-cell-0030282'));
    await tester.ensureVisible(cell);
    final before = tester.getCenter(cell);
    await tester.drag(cell, const Offset(-100, 0));
    await tester.pumpAndSettle();
    expect(tester.getCenter(cell).dx, lessThan(before.dx));
    expect(find.byType(PlanDragConfirmation), findsNothing);
    expect(log.of('op'), isEmpty);
  });
  for (final actor in [f.office, f.dock]) {
    for (final swap in [false, true]) {
      testWidgets(
          'T-105 ${actor.role.name}: ${swap ? 'intercambio' : 'libre'} confirma por repositorio',
          (tester) async {
        final (log, _) = await start(tester, actor: actor);
        await drag(tester, '0030282', swap ? '0030682' : '0030082',
            expected: swap ? 'swap' : 'valid',
            kind: actor.role == OperatorRole.office
                ? PointerDeviceKind.mouse
                : PointerDeviceKind.touch);
        expect(log.of('op'), isEmpty);
        expect(
            tester
                .widget<FilledButton>(
                    find.byKey(const ValueKey('plan-drag-confirm')))
                .onPressed,
            isNull);
        await tester.tap(find.text('Peso'));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('plan-drag-confirm')));
        await tester.pumpAndSettle();
        final movement = log.of('op').single.movement;
        expect(
            movement.type,
            actor.role == OperatorRole.office
                ? MovementType.changePosition
                : MovementType.requestChange);
        final changes = PositionChange.readAll(movement.payload['changes'])!;
        expect(changes, [
          PositionChange(f.key, '0030282', swap ? '0030682' : '0030082'),
          if (swap) const PositionChange('C:FULL0005678', '0030682', '0030282')
        ]);
        expect(tester.takeException(), isNull);
      });
    }
  }
  testWidgets('T-105 cancelar no registra', (tester) async {
    final (log, _) = await start(tester);
    await drag(tester, '0030282', '0030082');
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(log.of('op'), isEmpty);
  });
  testWidgets('T-105 rojo conserva el mensaje del dominio y no abre hoja',
      (tester) async {
    final (log, _) = await start(tester);
    await drag(tester, '0030282', '0030182', expected: 'invalid');
    expect(find.byType(PlanDragConfirmation), findsNothing);
    expect(find.textContaining('no cabe'), findsOneWidget);
    expect(log.of('op'), isEmpty);
  });
  testWidgets(
      'T-105 cargados y cancelados no son arrastrables; otros modos tampoco',
      (tester) async {
    await start(tester, initial: [
      MovementDraft.loadFull('op', 'FULL0001234', '0030282'),
      MovementDraft.cancelItem('op', 'C:FULL0005678', 'No embarca')
    ]);
    expect(find.byKey(const ValueKey('plan-drag-C:FULL0001234')), findsNothing);
    expect(find.byKey(const ValueKey('plan-drag-C:FULL0005678')), findsNothing);
    await mode(tester, 'Contenido');
    expect(find.byType(PlanDragCell), findsNothing);
    await mode(tester, 'Número de orden');
    expect(find.byKey(const ValueKey('plan-drag-R:0030482')), findsNothing);
  });
  testWidgets('T-105 sin rol: pulsación larga informa; toque abre detalle',
      (tester) async {
    await start(tester, actor: null);
    final cell = find.byKey(const ValueKey('plan-cell-0030282'));
    await tester.ensureVisible(cell);
    await tester.longPress(cell);
    await tester.pumpAndSettle();
    expect(find.text('Inicia sesión para mover'), findsOneWidget);
    await tester.tap(cell);
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
  for (final closed in [false, true]) {
    testWidgets(
        'T-105 operación ${closed ? 'cerrada' : 'sin publicar'} no arrastra',
        (tester) async {
      await start(tester, closed: closed, published: closed);
      expect(
          find.byKey(const ValueKey('plan-drag-C:FULL0001234')), findsNothing);
    });
  }
  testWidgets('T-105 revalida una carga remota antes de confirmar',
      (tester) async {
    final (log, _) = await start(tester);
    await drag(tester, '0030282', '0030082');
    await log.append(
        MovementDraft.loadFull('op', 'FULL0001234', '0030282'), f.dock.author);
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('plan-drag-reason')),
        'Cambio después de carga');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('plan-drag-confirm')));
    await tester.pumpAndSettle();
    expect(log.of('op'), hasLength(1));
    expect(find.textContaining('Solo se mueve un objeto pendiente'),
        findsOneWidget);
  });
  for (final approve in [true, false]) {
    testWidgets(
        'T-105 solicitud pendiente conserva origen; ${approve ? 'aprobación mueve' : 'rechazo quita marca'}',
        (tester) async {
      final (log, scope) = await start(tester, actor: f.dock);
      await drag(tester, '0030282', '0030082');
      await tester.tap(find.text('Peso'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('plan-drag-confirm')));
      await tester.pumpAndSettle();
      expect(
          find.byKey(const ValueKey('plan-pending-0030082')), findsOneWidget);
      expect(
          scope
              .read(loadingOperationProvider(t76Loading))
              .value!
              .plan
              .loading[f.key]!
              .plannedPosition,
          '0030282');
      final request = log.of('op').single.movement;
      await log.append(
          approve
              ? MovementDraft.approveChange('op', request, 'Aprobada')
              : MovementDraft.rejectChange('op', request.id, 'Rechazada'),
          f.office.author);
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('plan-pending-0030082')), findsNothing);
      expect(
          scope
              .read(loadingOperationProvider(t76Loading))
              .value!
              .plan
              .loading[f.key]!
              .plannedPosition,
          approve ? '0030082' : '0030282');
    });
  }
}
