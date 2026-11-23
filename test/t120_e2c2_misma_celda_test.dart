// T-120, corrección 2 de la entrega 2 · B2 (SPRINT-4.md 10.172): la tarjeta
// de la Lista con la misma matrícula dos veces en la misma celda.
//
// Desde la corrección 1, la clave de la tarjeta es la matrícula con su celda
// (T120-E2-01). Si el archivo repite las dos, el lector guarda los dos
// contenedores y la Lista los recibe: dos tarjetas podían volver a compartir
// clave. La sonda de GLM no lo resolvió: contaba las tarjetas por su texto
// (dos iguales le contaban como una) y su archivo traía solo esos dos, con lo
// que el filtro no movía ninguna tarjeta.
//
// Aquí: los 13 del buque sintético de la Lista, con el 4.º en la celda del 3.º
// (0020382) y con su matrícula; el filtro de su naviera puesto y quitado. Las
// tarjetas se cuentan por elemento (cada una por su altura en la lista), no
// por su texto.
//
// En su propio archivo: contra el código de antes, el árbol puede quedar roto.
// Buque sintético (BUQUE LISTA, TSTU); sin nube ni almacén real.
import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/presentation/providers/vessel_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/t120_lista_support.dart';

final _lista = find.byKey(const ValueKey('lista-scroll'));

ScrollPosition _posicion(WidgetTester tester) => tester
    .state<ScrollableState>(
        find.descendant(of: _lista, matching: find.byType(Scrollable)).first)
    .position;

/// Las tarjetas de toda la Lista, una por elemento, en el orden en que se
/// ven: «matrícula @ posición = clave». Cada tarjeta se reconoce por la altura
/// a la que está en la lista, así que dos tarjetas iguales cuentan como dos.
Future<List<String>> _porElemento(WidgetTester tester) async {
  final posicion = _posicion(tester);
  final vista = tester.getRect(_lista);
  final porAltura = <int, String>{};
  var y = 0.0;
  while (true) {
    posicion.jumpTo(y);
    await tester.pump();
    for (final el in t120Tarjetas().evaluate()) {
      final textos = find
          .descendant(of: find.byWidget(el.widget), matching: find.byType(Text))
          .evaluate()
          .map((t) => (t.widget as Text).data)
          .whereType<String>()
          .toList();
      final altura =
          (y + tester.getRect(find.byWidget(el.widget)).top - vista.top)
              .round();
      porAltura[altura] = '${textos.firstWhere((t) => t.startsWith('TSTU'))}'
          ' @ ${textos[textos.indexOf('Posición') + 1]}'
          ' = ${(el.widget.key! as ValueKey<String>).value}';
    }
    if (y >= posicion.maxScrollExtent) break;
    y = (y + 150).clamp(0, posicion.maxScrollExtent).toDouble();
  }
  posicion.jumpTo(0);
  await tester.pump();
  final alturas = porAltura.keys.toList()..sort();
  return [for (final a in alturas) porAltura[a]!];
}

/// El título de la Lista («Contenedores (n)…»).
String _titulo(WidgetTester tester) => find
    .byType(Text)
    .evaluate()
    .map((t) => (t.widget as Text).data)
    .whereType<String>()
    .firstWhere((t) => t.startsWith('Contenedores ('),
        orElse: () => '(sin título)');

void main() {
  testWidgets(
      'B2 · la misma matrícula dos veces en la misma celda: la Lista enseña '
      'las dos tarjetas, cada una con su clave, y con el filtro de su naviera '
      'puesto y quitado se rearma sin errores', (tester) async {
    final repetida = t120Numero(3);
    final texto = t120Baplie(13)
        .replaceFirst('LOC+147+0020482', 'LOC+147+0020382')
        .replaceFirst('EQD+CN+${t120Numero(4)}', 'EQD+CN+$repetida');
    final leido = BaplieParserService().parse(texto);
    final viaje = leido.withGeometry(VesselProfile.proposeFrom(leido).geometry);
    expect(viaje.containers, hasLength(13), reason: 'el lector guarda los 13');
    final dobles = viaje.containers
        .where((c) => c.containerId == repetida)
        .toList();
    expect(dobles.map((c) => c.stowagePosition!.toIsoCode()),
        ['0020382', '0020382'],
        reason: 'la matrícula, dos veces en la misma celda');
    final naviera = dobles.first.operatorCode;
    expect(dobles.last.operatorCode, naviera,
        reason: 'las dos, de la misma naviera');
    final scope = await t120Pump(tester, voyage: viaje);

    final antes = await _porElemento(tester);
    debugPrint('B2 antes del filtro (${_titulo(tester)}): '
        '${antes.length} tarjetas\n  ${antes.join('\n  ')}');

    final errores = <String>[];
    final anterior = FlutterError.onError;
    FlutterError.onError = (detalles) =>
        errores.add(detalles.exceptionAsString().split('\n').first);
    var filtradas = const <String>[];
    var despues = const <String>[];
    var tituloFiltrado = '';
    var tituloDespues = '';
    try {
      scope.read(selectedCarrierProvider.notifier).select(naviera);
      await tester.pumpAndSettle();
      filtradas = await _porElemento(tester);
      tituloFiltrado = _titulo(tester);
      scope.read(selectedCarrierProvider.notifier).clear();
      for (var i = 0; i < 10; i++) {
        await tester.pump();
      }
      despues = await _porElemento(tester);
      tituloDespues = _titulo(tester);
    } catch (error) {
      errores.add('$error'.split('\n').first);
    }
    if (errores.isNotEmpty) {
      await tester.pumpWidget(const SizedBox.shrink());
    }
    FlutterError.onError = anterior;
    debugPrint('B2 con el filtro de $naviera ($tituloFiltrado): '
        '${filtradas.length} tarjetas\n  ${filtradas.join('\n  ')}');
    debugPrint('B2 sin el filtro ($tituloDespues): ${despues.length} '
        'tarjetas; errores $errores');

    expect(antes, hasLength(13), reason: 'las 13 tarjetas, por elemento');
    expect(antes.where((t) => t.startsWith(repetida)), hasLength(2),
        reason: 'las dos de la matrícula repetida');
    expect(errores, isEmpty,
        reason: 'con el filtro puesto y quitado, la Lista se rearma sin '
            'errores');
    expect(filtradas.where((t) => t.startsWith(repetida)), hasLength(2));
    expect(despues, antes, reason: 'las 13, en el mismo orden');
    final claves = despues.map((t) => t.split(' = ').last).toList();
    expect(claves.toSet(), hasLength(13), reason: 'una clave por tarjeta');
    expect(tituloDespues, 'Contenedores (13)');
    for (final c in dobles) {
      expect(claves, contains('tarjeta-$repetida-0020382-${c.id}'),
          reason: 'la clave lleva la celda y el identificador del contenedor');
    }
    expect(tester.takeException(), isNull);
  });
}
