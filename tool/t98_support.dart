// Instrumentos T-98. No contiene datos comerciales ni modifica el producto.
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';

const t98Guide =
    'https://smdg.org/wp-content/uploads/MIGs/BAPLIE/Baplie221-03.pdf';

Directory t98Output(String path) {
  final root = Directory.systemTemp.resolveSymbolicLinksSync();
  final requested = Directory(path).absolute.uri.normalizePath().toFilePath();
  if (!requested
      .toLowerCase()
      .startsWith('${root.toLowerCase()}${Platform.pathSeparator}')) {
    throw ArgumentError('La salida debe estar bajo TEMP.');
  }
  final directory = Directory(path)..createSync(recursive: true);
  final resolved = directory.resolveSymbolicLinksSync();
  if (!resolved
      .toLowerCase()
      .startsWith('${root.toLowerCase()}${Platform.pathSeparator}')) {
    throw ArgumentError('La salida debe estar bajo TEMP.');
  }
  return directory;
}

String t98Hash(List<int> bytes) => sha256.convert(bytes).toString();

void t98Json(File file, Object value) => file.writeAsStringSync(
    '${const JsonEncoder.withIndent('  ').convert(value)}\n');

/// EDIFACT: el carácter de liberación protege separadores; UNA es opcional.
List<String> t98Segments(String source) {
  var separator = "'";
  var release = '?';
  if (source.startsWith('UNA') && source.length >= 9) {
    release = source[6];
    separator = source[8];
    source = source.substring(9);
  }
  final result = <String>[];
  final buffer = StringBuffer();
  var escaped = false;
  for (final rune in source.runes) {
    final c = String.fromCharCode(rune);
    if (escaped) {
      buffer.write(c);
      escaped = false;
    } else if (c == release) {
      buffer.write(c);
      escaped = true;
    } else if (c == separator) {
      if (buffer.toString().trim().isNotEmpty) {
        result.add(buffer.toString().trim());
      }
      buffer.clear();
    } else {
      buffer.write(c);
    }
  }
  if (buffer.toString().trim().isNotEmpty) result.add(buffer.toString().trim());
  return result;
}

int t98CheckDigit(String prefix) {
  if (!RegExp(r'^[A-Z]{3}[UJZ][0-9]{6}$').hasMatch(prefix)) {
    throw ArgumentError('Se requieren diez caracteres ISO 6346.');
  }
  var sum = 0;
  for (var i = 0; i < prefix.length; i++) {
    final char = prefix.codeUnitAt(i);
    final value = char <= 57 ? char - 48 : char - 55 + (char - 56) ~/ 10;
    sum += value * (1 << i);
  }
  return (sum % 11) % 10;
}

bool t98ValidId(String id) =>
    RegExp(r'^[A-Z]{3}[UJZ][0-9]{7}$').hasMatch(id) &&
    t98CheckDigit(id.substring(0, 10)) == int.parse(id[10]);

/// CSV RFC 4180: comillas dobles y campos con coma, también en UNECE.
List<List<String>> t98Csv(String source) {
  final rows = <List<String>>[];
  var row = <String>[];
  final field = StringBuffer();
  var quoted = false;
  for (var i = 0; i < source.length; i++) {
    final c = source[i];
    if (c == '"') {
      if (quoted && i + 1 < source.length && source[i + 1] == '"') {
        field.write('"');
        i++;
      } else {
        quoted = !quoted;
      }
    } else if (!quoted && (c == ',' || c == '\n')) {
      row.add(field.toString().replaceAll('\r', ''));
      field.clear();
      if (c == '\n') {
        rows.add(row);
        row = [];
      }
    } else {
      field.write(c);
    }
  }
  if (quoted) throw const FormatException('CSV con comillas sin cerrar.');
  if (field.isNotEmpty || row.isNotEmpty) {
    row.add(field.toString().replaceAll('\r', ''));
    rows.add(row);
  }
  return rows;
}

Set<String> t98Locodes(Directory directory) {
  final files = directory.listSync(recursive: true).whereType<File>().where(
      (f) => RegExp(r'CodeListPart[123]\.csv$', caseSensitive: false)
          .hasMatch(f.path));
  final found = files.toList()..sort((a, b) => a.path.compareTo(b.path));
  if (found.length != 3) {
    throw StateError('Se requieren las tres partes oficiales UNECE.');
  }
  final codes = <String>{};
  for (final file in found) {
    for (final row in t98Csv(latin1.decode(file.readAsBytesSync()))) {
      if (row.length >= 3 &&
          row[0] != 'X' &&
          RegExp(r'^[A-Z]{2}$').hasMatch(row[1]) &&
          RegExp(r'^[A-Z0-9]{3}$').hasMatch(row[2])) {
        codes.add('${row[1]}${row[2]}');
      }
    }
  }
  if (codes.length < 1000) {
    throw StateError('La lista UNECE no parece completa.');
  }
  return codes;
}

/// Mensaje sintético, una unidad; orden de grupos según SMDG 2.2.1 cap. 7.
String t98Message(
    {String position = '0020182',
    String? id,
    String unit = 'KGM',
    String qualifier = 'WT'}) {
  final number = id ?? 'CSQU305438${t98CheckDigit('CSQU305438')}';
  final segments = [
    'UNB+UNOA:2+TEST+TEST+261017:1200+T98',
    'UNH+T98+BAPLIE:D:95B:UN:SMDG22',
    'BGM++T98+9',
    'DTM+137:2610171200:201',
    'TDT+20+T98+++TEST:172:20+++:::BUQUE PRUEBA',
    'LOC+5+GTSTC:139:6',
    'DTM+178:2610171200:201',
    'LOC+147+$position::5',
    'MEA+$qualifier++$unit:24000',
    'LOC+9+GTSTC:139:6',
    'LOC+11+PAMIT:139:6',
    'RFF+BM:1',
    'EQD+CN+$number+22G1++2+5',
  ];
  segments.add('UNT+${segments.length}+T98');
  segments.add('UNZ+1+T98');
  return "${segments.join("'\n")}'\n";
}
