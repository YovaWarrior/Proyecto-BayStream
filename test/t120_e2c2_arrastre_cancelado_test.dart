// T-120, corrección 2 de la entrega 2 · O-120-7 (P3; SPRINT-4.md 10.171 y
// 10.172): un arrastre de celda cancelado no propone nada.
//
// Al cancelarse el contacto, Flutter avisa el final del arrastre por el mismo
// `onDragEnd` que un soltado, y el plano tomaba la celda que quedaba bajo el
// puntero: salía la hoja que confirma el movimiento, o el aviso, sin que nadie
// soltara. Pasaba cuando el sistema cancela el contacto (desde T-122) y, desde
// la corrección 1, también al perder el foco, porque el plano cancela entonces
// los contactos que siguen puestos (`_soltarTodo`). Sin «Confirmar» nunca se
// registró nada.
//
// Aquí, sobre el arnés de T-105 (operación publicada y abierta, operador
// autorizado, la celda pendiente 0030282), con el dedo y con el mouse, el
// arrastre a medias con el puntero sobre una celda válida (la reserva 0030382:
// intercambio), sobre una que no lo admite (0030182: «no cabe») y sobre la de
// origen; y en cada una, la cancelación del sistema (un `PointerCancelEvent`)
// y la pérdida de foco (`inactive`). El modelo es la sonda de GLM de la
// aceptación de la corrección 1. Los eventos van crudos, por
// `sendEventToBinding`: después de una cancelación, el «up» tardío tiene que
// poder mandarse igual.
//
// En su propio archivo, como las demás de la corrección 2: contra el código de
// antes, la hoja abierta se queda en el árbol de la prueba.
import 'package:baystream/features/vessel/presentation/widgets/plan_drag_confirmation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 't105_drag_widget_test.dart' as t105;

const _origen = '0030282';
const _reserva = '0030382';

Finder _celda(String posicion) => find.byKey(ValueKey('plan-cell-$posicion'));

final _copia = find.byKey(const ValueKey('plan-drag-feedback'));

bool _hay(Finder f) => f.evaluate().isNotEmpty;

/// Arrastra la celda de origen con [puntero] hasta [punto], en tres pasos, y
/// lo deja ahí, sin soltar.
Future<void> _arrastrarA(
    WidgetTester tester, TestPointer puntero, Offset punto) async {
  final desde = tester.getCenter(_celda(_origen));
  await tester
      .sendEventToBinding(puntero.down(desde, buttons: kPrimaryButton));
  await tester.pump(const Duration(milliseconds: 600));
  await tester.pump();
  for (var i = 1; i <= 3; i++) {
    await tester
        .sendEventToBinding(puntero.move(Offset.lerp(desde, punto, i / 3)!));
    await tester.pump();
  }
  await tester.pump();
}

void main() {
  var ids = 40;
  for (final (caso, destino, vista) in [
    ('una celda válida', _reserva, 'plan-preview-swap-$_reserva'),
    ('una celda que no lo admite', '0030182', 'plan-preview-invalid-0030182'),
    ('la celda de origen', _origen, 'plan-preview-invalid-$_origen'),
  ]) {
    for (final (dispositivo, tipo) in [
      ('el dedo', PointerDeviceKind.touch),
      ('el mouse', PointerDeviceKind.mouse),
    ]) {
      for (final (como, porElFoco) in [
        ('la cancelación del sistema', false),
        ('la pérdida de foco', true),
      ]) {
        ids += 10;
        final id = ids;
        testWidgets(
            'O-120-7 · con ${dispositivo.replaceFirst('el ', '')} sobre '
            '$caso, $como: no sale ni la hoja ni el aviso, nada se registra '
            'y un arrastre nuevo termina en su hoja', (tester) async {
          tester.view.physicalSize = const Size(1366, 690);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.reset);
          final (log, _) = await t105.start(tester);
          await Scrollable.ensureVisible(tester.element(_celda(_origen)),
              alignment: .5);
          await Scrollable.ensureVisible(tester.element(_celda(destino)),
              alignment: .5);
          await tester.pumpAndSettle();
          final punto = tester.getCenter(_celda(destino));

          final puntero = TestPointer(id, tipo);
          await _arrastrarA(tester, puntero, punto);
          expect(_hay(_copia), isTrue, reason: 'el arrastre empezó');
          expect(_hay(find.byKey(ValueKey(vista))), isTrue,
              reason: 'el puntero está sobre $caso');

          if (porElFoco) {
            // Alt + Tab: en Windows, perder el foco es inactive.
            tester.binding
                .handleAppLifecycleStateChanged(AppLifecycleState.inactive);
            await tester.pump();
            tester.binding
                .handleAppLifecycleStateChanged(AppLifecycleState.resumed);
            await tester.pump();
          } else {
            await tester.sendEventToBinding(puntero.cancel());
            await tester.pump();
          }
          final hoja = _hay(find.byType(PlanDragConfirmation));
          final aviso = _hay(find.byType(SnackBar));
          final copia = _hay(_copia);
          debugPrint('O-120-7 $dispositivo, $caso, $como · al cancelarse: '
              'hoja=$hoja aviso=$aviso copia=$copia');
          expect(copia, isFalse, reason: 'la copia del arrastre desaparece');
          expect(hoja, isFalse, reason: 'un arrastre cancelado no propone');
          expect(aviso, isFalse, reason: 'ni avisa');

          // El «up» tardío, donde estaba el puntero: no tiene a quién avisar.
          await tester.sendEventToBinding(
              PointerUpEvent(pointer: id, kind: tipo, position: punto));
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 400));
          final hojaDespues = _hay(find.byType(PlanDragConfirmation));
          final avisoDespues = _hay(find.byType(SnackBar));
          debugPrint('O-120-7 $dispositivo, $caso, $como · tras el up tardío: '
              'hoja=$hojaDespues aviso=$avisoDespues '
              'registros=${log.of('op').length}');
          expect(hojaDespues, isFalse);
          expect(avisoDespues, isFalse);
          expect(log.of('op'), isEmpty, reason: 'nada se registra');

          // Un arrastre nuevo de la misma celda, a la reserva, termina en su
          // hoja; se cancela la hoja y tampoco se registra nada.
          await Scrollable.ensureVisible(tester.element(_celda(_reserva)),
              alignment: .5);
          await tester.pumpAndSettle();
          final nuevo = TestPointer(id + 1, tipo);
          await _arrastrarA(tester, nuevo, tester.getCenter(_celda(_reserva)));
          await tester.sendEventToBinding(nuevo.up());
          await tester.pumpAndSettle();
          expect(find.byType(PlanDragConfirmation), findsOneWidget,
              reason: 'un arrastre nuevo de la misma celda termina en su hoja');
          await tester.tap(find.text('Cancelar'));
          await tester.pumpAndSettle();
          expect(log.of('op'), isEmpty);
          expect(tester.takeException(), isNull);
        });
      }
    }
  }
}
