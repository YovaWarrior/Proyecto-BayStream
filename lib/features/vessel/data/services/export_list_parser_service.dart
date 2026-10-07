import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:excel_community/excel_community.dart' as xlsx;

import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/export_list.dart';
import '../../domain/entities/container_unit.dart';

/// Una celda con fórmula. Su valor guardado no se usa: en el listado de la
/// agencia PESO NETO llega sin él (T-73) y se recalcula.
class SheetFormula {
  final String formula;
  const SheetFormula(this.formula);

  @override
  String toString() => '=$formula';
}

/// T-73 · Lee el listado de exportación de la agencia (RF-038).
///
/// Las columnas se ubican por su encabezado, no por su posición. Las filas
/// con «CODIGO» separan agencias. Una fila que no se entiende se informa con
/// su número; nunca se descarta en silencio.
class ExportListParserService {
  const ExportListParserService();

  /// Columnas sin las cuales una fila no se puede normalizar.
  static const requiredColumns = [
    'OR', 'CONTENEDOR', 'TIPO', 'POD', 'TARA', 'PESO VGM', 'F', 'E', 'CONTENIDO', 'OPR',
  ];

  /// Encabezado del Excel → nombre interno. Los alias cubren variantes de
  /// redacción vistas en listados; la forma de `LISTADO_A08.xlsx` es la primera.
  static const _aliases = {
    'OR': 'OR',
    'ORDEN': 'OR',
    'CONTENEDOR': 'CONTENEDOR',
    'TIPO': 'TIPO',
    'POT': 'POT',
    'POD': 'POD',
    'TARA': 'TARA',
    'PESO NETO': 'PESO NETO',
    'PESO VGM': 'PESO VGM',
    'VGM': 'PESO VGM',
    'REEFER TEMP': 'REEFER TEMP',
    'ORIG': 'ORIG',
    'F': 'F',
    'E': 'E',
    'CONTENIDO': 'CONTENIDO',
    'HORA': 'HORA',
    'MARCHAMO': 'MARCHAMO',
    'OPR': 'OPR',
  };

  static final _containerNumber = RegExp(r'^[A-Z]{4}\d{7}$');

  /// Lee la primera hoja que tenga la fila de encabezados.
  ExportList parseXlsx(List<int> bytes, {String fileName = 'listado.xlsx'}) {
    final xlsx.Excel book;
    try {
      book = xlsx.Excel.decodeBytes(withRelativeTargets(bytes));
    } catch (error) {
      throw ExportListParsingException(
          message: 'El archivo no es un libro de Excel (.xlsx) legible.', cause: error);
    }
    ExportListParsingException? firstError;
    for (final sheet in book.tables.values) {
      try {
        return parseGrid(_grid(sheet), fileName: fileName);
      } on ExportListParsingException catch (error) {
        firstError ??= error;
      }
    }
    throw firstError ??
        const ExportListParsingException(message: 'El libro no tiene hojas con datos.');
  }

  /// `excel_community` 1.0.10 (y hasta la 2.6.0) arma `xl/` + destino para
  /// la hoja y los estilos: un destino absoluto como `/xl/worksheets/sheet1.xml`,
  /// válido en OOXML y el que escribe openpyxl (así viene LISTADO_A08.xlsx),
  /// no se encuentra. Se vuelven relativos todos los de `workbook.xml.rels`
  /// antes de entregarle el libro; si no hay ninguno, el libro pasa intacto.
  static List<int> withRelativeTargets(List<int> bytes) {
    final Archive archive;
    try {
      archive = ZipDecoder().decodeBytes(bytes);
    } catch (_) {
      return bytes; // Que el lector de Excel informe el error de siempre.
    }
    const path = 'xl/_rels/workbook.xml.rels';
    final rels = archive.findFile(path);
    if (rels == null) return bytes;
    final original = utf8.decode(rels.content);
    final fixed = relativeWorkbookTargets(original);
    if (fixed == original) return bytes;
    archive.add(ArchiveFile.string(path, fixed));
    return ZipEncoder().encodeBytes(archive);
  }

  /// Destinos absolutos de `workbook.xml.rels`, relativos a `xl/`:
  /// `/xl/styles.xml` → `styles.xml`; `/customXml/item1.xml` → `../customXml/item1.xml`.
  static String relativeWorkbookTargets(String rels) =>
      rels.replaceAllMapped(RegExp(r'''Target=(["'])/([^"']*)\1'''), (m) {
        final target = m[2]!;
        final relative = target.startsWith('xl/') ? target.substring(3) : '../$target';
        return 'Target=${m[1]}$relative${m[1]}';
      });

  static List<List<Object?>> _grid(xlsx.Sheet sheet) => [
        for (final row in sheet.rows) [for (final cell in row) _cellValue(cell?.value)],
      ];

  static Object? _cellValue(xlsx.CellValue? value) => switch (value) {
        null => null,
        xlsx.TextCellValue(value: final text) => text.toString(),
        xlsx.IntCellValue(value: final number) => number,
        xlsx.DoubleCellValue(value: final number) => number,
        xlsx.FormulaCellValue(formula: final formula) => SheetFormula(formula),
        xlsx.TimeCellValue(hour: final hour, minute: final minute) => _hhmm(hour, minute),
        xlsx.DateTimeCellValue(:final year, :final month, :final day, :final hour, :final minute) =>
          '${_ymd(year, month, day)} ${_hhmm(hour, minute)}',
        xlsx.DateCellValue(:final year, :final month, :final day) => _ymd(year, month, day),
        xlsx.BoolCellValue(value: final flag) => flag ? 'X' : null,
      };

  static String _ymd(int year, int month, int day) =>
      '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';

  static String _hhmm(int hour, int minute) =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

  /// Mayúsculas, sin tildes y con un solo espacio: «Exportación» = «EXPORTACION».
  static String normalizeHeader(String text) {
    const from = 'ÁÉÍÓÚÜÑáéíóúüñ';
    const to = 'AEIOUUNaeiouun';
    final buffer = StringBuffer();
    for (final rune in text.runes) {
      final char = String.fromCharCode(rune);
      final index = from.indexOf(char);
      buffer.write(index < 0 ? char : to[index]);
    }
    return buffer.toString().toUpperCase().replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  /// Rejilla de la hoja, fila por fila, con `String`, `num`, [SheetFormula]
  /// o `null`. La fila 0 es la fila 1 de Excel.
  ExportList parseGrid(List<List<Object?>> grid, {String fileName = 'listado.xlsx'}) {
    final headerIndex = grid.indexWhere((row) {
      final names = row.map((c) => c is String ? normalizeHeader(c) : null).toSet();
      return names.contains('OR') && names.contains('CONTENEDOR');
    });
    if (headerIndex < 0) {
      throw const ExportListParsingException(
          message: 'No se encontró la fila de encabezados del listado '
              '(OR, CONTENEDOR, TIPO…).');
    }
    final columns = <String, int>{};
    final header = grid[headerIndex];
    for (var i = 0; i < header.length; i++) {
      final cell = header[i];
      if (cell is! String) continue;
      final name = _aliases[normalizeHeader(cell)];
      if (name != null) columns.putIfAbsent(name, () => i);
    }
    final missing = requiredColumns.where((c) => !columns.containsKey(c)).toList();
    if (missing.isNotEmpty) {
      throw ExportListParsingException(
          message: 'Al listado le faltan columnas: ${missing.join(', ')}.');
    }

    final titleLines = <String>[
      for (final row in grid.take(headerIndex))
        if (_rowText(row).isNotEmpty) _rowText(row),
    ];
    final rows = <ExportListRow>[];
    final issues = <ExportListIssue>[];
    final seenContainers = <String, int>{};
    final seenOrders = <int, int>{};
    String? agency;

    for (var r = headerIndex + 1; r < grid.length; r++) {
      final row = grid[r];
      final sheetRow = r + 1;
      if (row.every(_isBlank)) continue;
      Object? at(String column) {
        final index = columns[column];
        return index == null || index >= row.length ? null : row[index];
      }

      final order = _int(at('OR'));
      if (order == null) {
        final text = _rowText(row);
        if (normalizeHeader(text).contains('CODIGO')) {
          agency = text.substring(0, _codigoStart(text)).trim();
          if (agency.isEmpty) agency = text.trim();
          continue;
        }
        issues.add(ExportListIssue(sheetRow,
            'No es un contenedor ni un separador de agencia: «${_short(text)}».'));
        continue;
      }

      final problems = <String>[];
      final containerId = _text(at('CONTENEDOR'))?.replaceAll(RegExp(r'\s'), '').toUpperCase();
      if (containerId == null) {
        problems.add('falta el número de contenedor');
      } else if (!_containerNumber.hasMatch(containerId)) {
        problems.add('el contenedor «$containerId» no tiene la forma ISO 6346 (4 letras y 7 cifras)');
      }
      final full = !_isBlank(at('F'));
      final empty = !_isBlank(at('E'));
      if (full == empty) {
        problems.add(full ? 'marca lleno (F) y vacío (E) a la vez' : 'no marca lleno (F) ni vacío (E)');
      }
      final type = _code(at('TIPO'));
      final pod = _code(at('POD'));
      final line = _code(at('OPR'));
      if (type == null) problems.add('falta el tipo');
      if (pod == null) problems.add('falta el puerto de descarga (POD)');
      if (line == null) problems.add('falta la línea (OPR)');
      final tare = _number(at('TARA'));
      if (tare == null) problems.add('la tara no es un número');
      final vgmCell = at('PESO VGM');
      final vgm = _number(vgmCell);
      if (!_isBlank(vgmCell) && vgm == null) problems.add('el VGM no es un número');
      if (full && !empty && _isBlank(vgmCell)) {
        problems.add('un lleno sin VGM');
      }
      if (containerId != null && seenContainers.containsKey(containerId)) {
        problems.add('el contenedor ya está en la fila ${seenContainers[containerId]}');
      }
      if (seenOrders.containsKey(order)) {
        problems.add('el número de orden $order ya está en la fila ${seenOrders[order]}');
      }
      if (problems.isNotEmpty) {
        issues.add(ExportListIssue(sheetRow, 'OR $order: ${problems.join('; ')}.'));
        continue;
      }
      seenContainers[containerId!] = sheetRow;
      seenOrders[order] = sheetRow;
      final contents = _text(at('CONTENIDO')) ?? '';
      final dangerous = parseDangerousContents(contents);
      rows.add(ExportListRow(
        sheetRow: sheetRow,
        order: order,
        containerId: containerId,
        status: full ? ContainerStatus.full : ContainerStatus.empty,
        listType: type!,
        listPot: _code(at('POT')),
        listPod: pod!,
        listLine: line!,
        tareKg: tare!,
        vgmKg: vgm,
        reeferTemperature: _text(at('REEFER TEMP')),
        origin: _text(at('ORIG')),
        contents: contents.replaceAll(RegExp(r'\s+'), ' '),
        hour: _text(at('HORA')),
        seal: _text(at('MARCHAMO')),
        agency: agency,
        imdgClass: dangerous.imdgClass,
        unNumbers: dangerous.unNumbers,
      ));
    }
    return ExportList(fileName: fileName, titleLines: titleLines, rows: rows, issues: issues);
  }

  /// Clase y números ONU del texto libre de CONTENIDO:
  /// «DANGEROUS CARGO IMO 9 UN 3082, 3077» → clase 9, UN 3082 y 3077.
  static ({String? imdgClass, List<String> unNumbers}) parseDangerousContents(String text) {
    final upper = normalizeHeader(text);
    final classMatch =
        RegExp(r'\b(?:IMO|IMDG|CLASE|CLASS)\s*:?\s*(\d(?:\.\d)?)\b').firstMatch(upper);
    final unNumbers = <String>[];
    for (final match in RegExp(r'\bUN\s*:?\s*((?:\d{4})(?:\s*(?:,|/|&|Y|AND)\s*\d{4})*)')
        .allMatches(upper)) {
      for (final number in RegExp(r'\d{4}').allMatches(match.group(1)!)) {
        if (!unNumbers.contains(number.group(0))) unNumbers.add(number.group(0)!);
      }
    }
    return (imdgClass: classMatch?.group(1), unNumbers: unNumbers);
  }

  static bool _isBlank(Object? cell) =>
      cell == null || (cell is String && cell.trim().isEmpty);

  static String _rowText(List<Object?> row) => row
      .whereType<String>()
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .join(' ')
      .replaceAll(RegExp(r'\s+'), ' ');

  static int _codigoStart(String text) {
    final match = RegExp('C[OÓ]DIGO', caseSensitive: false).firstMatch(text);
    return match?.start ?? text.length;
  }

  static String _short(String text) => text.length <= 40 ? text : '${text.substring(0, 40)}…';

  static String? _text(Object? cell) {
    if (cell == null || cell is SheetFormula) return null;
    if (cell is num) return cell == cell.roundToDouble() ? cell.toInt().toString() : cell.toString();
    final text = cell.toString().trim();
    return text.isEmpty ? null : text;
  }

  static String? _code(Object? cell) => _text(cell)?.replaceAll(RegExp(r'\s'), '').toUpperCase();

  static double? _number(Object? cell) {
    if (cell is num) return cell.toDouble();
    final text = _text(cell);
    if (text == null) return null;
    final plain = text.replaceAll(RegExp(r'\s'), '');
    // «7266,59» con coma decimal; con punto y coma juntos no se adivina.
    final normalized =
        plain.contains(',') && !plain.contains('.') ? plain.replaceAll(',', '.') : plain;
    return double.tryParse(normalized);
  }

  static int? _int(Object? cell) {
    final value = _number(cell);
    if (value == null || value != value.roundToDouble()) return null;
    return value.toInt();
  }
}
