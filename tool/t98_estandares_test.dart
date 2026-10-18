// Instrumento manual RNF-008 (10.81), excluido de la suite por defecto.
// flutter test --no-pub tool/t98_estandares_test.dart --reporter expanded
// --dart-define=T98_BASE=<commit> --dart-define=T98_SALIDA=<carpeta TEMP>
// Registra observaciones, nunca aprueba/reprueba los casos de conformidad.
import 'dart:convert';
import 'dart:io';

import 'package:baystream/core/errors/exceptions.dart';
import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/presentation/widgets/voyage_summary_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 't98_support.dart';

class _Case {
  final String name;
  final String standard;
  final String type;
  final String source;
  const _Case(this.name, this.standard, this.type, this.source);
}

List<_Case> _cases() {
  final cases = <_Case>[];
  for (final position in ['0010002', '0020182', '9999999']) {
    cases.add(_Case('BBBRRTT $position', 'BBBRRTT', 'positivo',
        t98Message(position: position)));
  }
  for (final position in ['01234', '01200000', '012A082', '-120082']) {
    cases.add(_Case('BBBRRTT $position', 'BBBRRTT', 'negativo',
        t98Message(position: position)));
  }
  for (final prefix in ['CSQU305438', 'TSTU000098', 'ABCU123456']) {
    cases.add(_Case('Dígito válido $prefix', 'ISO 6346', 'positivo',
        t98Message(id: '$prefix${t98CheckDigit(prefix)}')));
    cases.add(_Case('Dígito alterado $prefix', 'ISO 6346', 'negativo',
        t98Message(id: '$prefix${(t98CheckDigit(prefix) + 1) % 10}')));
  }
  cases.add(_Case('WT KGM 24000', 'KGM / SOLAS', 'positivo', t98Message()));
  cases.add(_Case('VGM KGM 24000', 'KGM / SOLAS VGM', 'positivo',
      t98Message(qualifier: 'VGM')));
  for (final unit in ['LBR', 'TNE']) {
    cases.add(_Case(
        'WT $unit 24000', 'KGM / SOLAS', 'negativo', t98Message(unit: unit)));
  }
  cases.add(_Case(
      'SMDG22 grupos 1, 2 y 3', 'BAPLIE 2.2.1', 'positivo', t98Message()));
  cases.add(_Case('Grupo 4 clase 3 ONU 1993', 'BAPLIE 2.2.1', 'positivo',
      t98Message().replaceFirst('UNT+13+', "DGS+IMD+3+1993'\nUNT+14+")));
  for (final tag in ['UNB', 'UNH', 'BGM', 'TDT', 'UNT', 'UNZ']) {
    final source = t98Segments(t98Message())
        .where((s) => !s.startsWith('$tag+'))
        .map((s) => "$s'")
        .join();
    cases.add(_Case('Sin $tag', 'BAPLIE 2.2.1', 'negativo', source));
  }
  for (final pair in [
    ['BAPLIE:D:95B:UN:SMDG22', 'COPRAR:D:95B:UN:SMDG22'],
    ['BAPLIE:D:95B:UN:SMDG22', 'BAPLIE:D:13B:UN:SMDG31'],
    ['TDT+20+', 'TDT+99+'],
  ]) {
    cases.add(_Case('Cabecera ${pair[1]}', 'BAPLIE 2.2.1', 'negativo',
        t98Message().replaceFirst(pair[0], pair[1])));
  }
  // Control del propio detector de aviso visible, separado de BAPLIE 2.2.1.
  // Una advertencia almacenada pero no dibujada NO cuenta como aviso visible.
  cases.add(_Case(
      'Control SMDG15 con aviso',
      'Control del instrumento',
      'control',
      t98Message()
          .replaceFirst('BAPLIE:D:95B:UN:SMDG22', 'BAPLIE:1:911:UN:SMDG15')));
  return cases;
}

Future<List<String>> _visibleNotices(
    WidgetTester tester, VesselVoyage voyage) async {
  await tester.pumpWidget(MaterialApp(
      home: Scaffold(
          body: SingleChildScrollView(
              child: VoyageSummaryCard(voyage: voyage)))));
  await tester.pump();
  final roots = <Element>{};
  roots.addAll(find.byWidgetPredicate((widget) {
    final key = widget.key;
    return key is ValueKey<String> &&
        RegExp('notice|warning|aviso').hasMatch(key.value);
  }).evaluate());
  const icons = [
    Icons.warning_amber,
    Icons.warning_amber_rounded,
    Icons.warning,
    Icons.warning_rounded,
    Icons.error_outline
  ];
  for (final element in find
      .byWidgetPredicate(
          (widget) => widget is Icon && icons.contains(widget.icon))
      .evaluate()) {
    element.visitAncestorElements((ancestor) {
      if (ancestor.widget is Row) {
        roots.add(ancestor);
        return false;
      }
      return true;
    });
  }
  final viewport =
      Offset.zero & (tester.view.physicalSize / tester.view.devicePixelRatio);
  final texts = <String>{};
  for (final root in roots) {
    final finder =
        find.byElementPredicate((element) => identical(element, root));
    if (!tester.getRect(finder).overlaps(viewport)) continue;
    void read(Element element) {
      final widget = element.widget;
      if (widget is Text) {
        final value = widget.data ?? widget.textSpan?.toPlainText() ?? '';
        if (value.trim().isNotEmpty) texts.add(value.trim());
      }
      element.visitChildElements(read);
    }

    read(root);
  }
  return texts.toList();
}

String _csv(Object? value) =>
    '"${(value ?? '').toString().replaceAll('"', '""')}"';
String _md(Object? value) =>
    (value ?? '').toString().replaceAll('|', r'\|').replaceAll('\n', ' ');

void main() {
  testWidgets('T98 registra la tabla de conformidad sin dictamen por caso',
      (tester) async {
    const base = String.fromEnvironment('T98_BASE');
    const phase = String.fromEnvironment('T98_FASE', defaultValue: 'A');
    const destination = String.fromEnvironment('T98_SALIDA');
    if (!RegExp(r'^[a-fA-F0-9]{7,40}$').hasMatch(base) ||
        !['A', 'B'].contains(phase) ||
        (phase == 'B' && base.length != 40)) {
      throw ArgumentError(
          'Declarar T98_BASE real; en Fase B, hash completo de cierre.');
    }
    final directory = t98Output(destination.isEmpty
        ? Directory.systemTemp.createTempSync('t98_conformidad_').path
        : destination);
    final csv = File('${directory.path}/conformidad.csv');
    final md = File('${directory.path}/conformidad.md');
    if (csv.existsSync() || md.existsSync()) {
      throw StateError('No sobrescribir tablas de una corrida anterior.');
    }
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final rows = <Map<String, Object?>>[];
    for (final specimen in _cases()) {
      var behavior = 'acepta en silencio';
      var notices = <String>[];
      final facts = <String, Object?>{};
      try {
        final voyage = BaplieParserService().parse(specimen.source);
        notices = await _visibleNotices(tester, voyage);
        if (notices.isNotEmpty) behavior = 'avisa';
        final unit = voyage.containers.firstOrNull;
        facts.addAll({
          'contenedores': voyage.totalContainers,
          'posicion': unit?.stowagePosition?.toIsoCode(),
          'id_sintetico': unit?.containerId,
          'peso_bruto_kg': unit?.grossWeight,
          'vgm_kg': unit?.vgmWeight,
          'clases_imdg':
              unit?.dangerousGoods?.map((d) => d.hazardClass).toList(),
        });
      } on BayStreamException catch (error) {
        behavior = 'rechaza';
        facts['rechazo_dominio'] = true;
        facts['codigo'] = error.code;
      }
      rows.add({
        'caso': specimen.name,
        'norma': specimen.standard,
        'tipo': specimen.type,
        'lector_hoy': behavior,
        'aviso_visible': notices.join(' / '),
        'datos_sinteticos_leidos': jsonEncode(facts),
        'fuente_sha256': t98Hash(utf8.encode(specimen.source)),
        'fase': phase,
        'base': base
      });
    }
    final columns = rows.first.keys.toList();
    csv.writeAsStringSync('${columns.map(_csv).join(',')}\n'
        '${rows.map((row) => columns.map((c) => _csv(row[c])).join(',')).join('\n')}\n');
    md.writeAsStringSync('# T-98 · Observaciones del lector · Fase $phase\n\n'
        'Base declarada: `$base`. Entradas sintéticas; sin dictamen RNF por caso.\n\n'
        '${phase == 'A' ? 'ENSAYO DE INSTRUMENTO: no es medición de cierre.' : 'Requiere validar procedencia del commit de cierre antes del dictamen.'}\n\n'
        'Negativo detectado = rechaza o avisa de forma visible. '
        'Un aviso solo almacenado no basta.\n\n'
        '| Caso | Norma | Tipo | Qué hace el lector hoy | Aviso visible |\n'
        '|---|---|---|---|---|\n'
        '${rows.map((r) => '| ${_md(r['caso'])} | ${_md(r['norma'])} | ${_md(r['tipo'])} | ${_md(r['lector_hoy'])} | ${_md(r['aviso_visible'])} |').join('\n')}\n\n'
        'Avisos observados renderizando VoyageSummaryCard real. '
        'No sustituye el recorrido de los tres clientes de Fase B. '
        'CSV incluye los datos leídos y la huella de cada fuente sintética.\n');
    stdout
        .writeln('T98: ${rows.length} observaciones, sin pasa/falla por caso. '
            'CSV y MD: ${directory.path}');
  });
}
