import 'package:equatable/equatable.dart';

import 'container_unit.dart';

/// T-73 · Qué código traduce una equivalencia: el listado de la agencia y el
/// plan del planificador nombran distinto el mismo tipo, puerto o línea.
enum EquivalenceKind {
  type('type', 'Tipo'),
  port('port', 'Puerto'),
  line('line', 'Línea');

  const EquivalenceKind(this.wire, this.label);
  final String wire;
  final String label;
}

/// Tabla de equivalencias del dispositivo: código del listado → código del
/// plan. Un código que no está en la tabla se usa tal cual.
class CodeEquivalences extends Equatable {
  final Map<EquivalenceKind, Map<String, String>> _tables;

  CodeEquivalences([Map<EquivalenceKind, Map<String, String>> tables = const {}])
      : _tables = Map.unmodifiable({
          for (final kind in EquivalenceKind.values)
            kind: Map<String, String>.unmodifiable(tables[kind] ?? const {}),
        });

  static final empty = CodeEquivalences();

  Map<String, String> of(EquivalenceKind kind) => _tables[kind]!;

  String? lookup(EquivalenceKind kind, String code) => _tables[kind]![code];

  String translate(EquivalenceKind kind, String code) => lookup(kind, code) ?? code;

  bool get isEmpty => _tables.values.every((t) => t.isEmpty);

  CodeEquivalences put(EquivalenceKind kind, String from, String to) => CodeEquivalences({
        ..._tables,
        kind: {..._tables[kind]!, from: to},
      });

  CodeEquivalences remove(EquivalenceKind kind, String from) => CodeEquivalences({
        ..._tables,
        kind: {..._tables[kind]!}..remove(from),
      });

  /// Las de [other] reemplazan a las de esta tabla.
  CodeEquivalences merge(CodeEquivalences other) => CodeEquivalences({
        for (final kind in EquivalenceKind.values)
          kind: {..._tables[kind]!, ...other._tables[kind]!},
      });

  @override
  List<Object?> get props => [
        for (final kind in EquivalenceKind.values)
          (_tables[kind]!.entries.toList()..sort((a, b) => a.key.compareTo(b.key)))
              .map((e) => '${e.key}=${e.value}')
              .join(','),
      ];

  Map<String, dynamic> toJson() => {
        for (final kind in EquivalenceKind.values) kind.wire: _tables[kind],
      };

  factory CodeEquivalences.fromJson(Map<String, dynamic> json) => CodeEquivalences({
        for (final kind in EquivalenceKind.values)
          kind: Map<String, String>.from(json[kind.wire] as Map? ?? const {}),
      });
}

/// Una fila de contenedor del listado. Los códigos `list*` son los del Excel;
/// [type], [pot], [pod] y [line] son los vigentes, ya traducidos cuando la
/// lista pasó por [ExportList.normalized].
class ExportListRow extends Equatable {
  /// Fila de la hoja, contada desde 1 como la ve el usuario en Excel.
  final int sheetRow;

  /// Número de orden (OR): el que el muelle escribe en la celda del plano.
  final int order;
  final String containerId;
  final ContainerStatus status;

  final String listType;
  final String? listPot;
  final String listPod;
  final String listLine;
  final String type;
  final String? pot;
  final String pod;
  final String line;

  final double tareKg;

  /// VGM tal como viene en el listado, sin truncar. Nulo en un vacío.
  final double? vgmKg;
  final String? reeferTemperature;
  final String? origin;
  final String contents;
  final String? hour;
  final String? seal;
  final String? agency;

  /// Leídos del texto libre de CONTENIDO.
  final String? imdgClass;
  final List<String> unNumbers;

  ExportListRow({
    required this.sheetRow,
    required this.order,
    required this.containerId,
    required this.status,
    required this.listType,
    this.listPot,
    required this.listPod,
    required this.listLine,
    String? type,
    String? pot,
    String? pod,
    String? line,
    required this.tareKg,
    this.vgmKg,
    this.reeferTemperature,
    this.origin,
    this.contents = '',
    this.hour,
    this.seal,
    this.agency,
    this.imdgClass,
    Iterable<String> unNumbers = const [],
  })  : type = type ?? listType,
        pot = pot ?? listPot,
        pod = pod ?? listPod,
        line = line ?? listLine,
        unNumbers = List.unmodifiable(unNumbers);

  bool get isFull => status == ContainerStatus.full;
  bool get isEmpty => status == ContainerStatus.empty;
  bool get isDangerous => imdgClass != null || unNumbers.isNotEmpty;

  /// PESO NETO del listado es una fórmula (VGM − TARA): se recalcula siempre.
  double? get netKg => vgmKg == null ? null : vgmKg! - tareKg;

  /// Grupo de un vacío: tipo, puerto de descarga y línea, ya traducidos.
  ({String type, String pod, String line}) get group => (type: type, pod: pod, line: line);

  ExportListRow translated(CodeEquivalences equivalences) => ExportListRow(
        sheetRow: sheetRow,
        order: order,
        containerId: containerId,
        status: status,
        listType: listType,
        listPot: listPot,
        listPod: listPod,
        listLine: listLine,
        type: equivalences.translate(EquivalenceKind.type, listType),
        pot: listPot == null ? null : equivalences.translate(EquivalenceKind.port, listPot!),
        pod: equivalences.translate(EquivalenceKind.port, listPod),
        line: equivalences.translate(EquivalenceKind.line, listLine),
        tareKg: tareKg,
        vgmKg: vgmKg,
        reeferTemperature: reeferTemperature,
        origin: origin,
        contents: contents,
        hour: hour,
        seal: seal,
        agency: agency,
        imdgClass: imdgClass,
        unNumbers: unNumbers,
      );

  @override
  List<Object?> get props => [
        sheetRow, order, containerId, status, listType, listPot, listPod, listLine,
        type, pot, pod, line, tareKg, vgmKg, reeferTemperature, origin, contents,
        hour, seal, agency, imdgClass, unNumbers,
      ];

  Map<String, dynamic> toJson() => {
        'row': sheetRow,
        'order': order,
        'container': containerId,
        'status': status.name,
        'type': type,
        if (pot != null) 'pot': pot,
        'pod': pod,
        'line': line,
        'listType': listType,
        if (listPot != null) 'listPot': listPot,
        'listPod': listPod,
        'listLine': listLine,
        'tareKg': tareKg,
        if (vgmKg != null) 'vgmKg': vgmKg,
        if (netKg != null) 'netKg': netKg,
        if (reeferTemperature != null) 'reeferTemperature': reeferTemperature,
        if (origin != null) 'origin': origin,
        'contents': contents,
        if (hour != null) 'hour': hour,
        if (seal != null) 'seal': seal,
        if (agency != null) 'agency': agency,
        if (imdgClass != null) 'imdgClass': imdgClass,
        if (unNumbers.isNotEmpty) 'unNumbers': unNumbers,
      };

  factory ExportListRow.fromJson(Map<String, dynamic> json) => ExportListRow(
        sheetRow: json['row'] as int,
        order: json['order'] as int,
        containerId: json['container'] as String,
        status: ContainerStatus.values.firstWhere((s) => s.name == json['status'],
            orElse: () => ContainerStatus.unknown),
        listType: json['listType'] as String,
        listPot: json['listPot'] as String?,
        listPod: json['listPod'] as String,
        listLine: json['listLine'] as String,
        type: json['type'] as String?,
        pot: json['pot'] as String?,
        pod: json['pod'] as String?,
        line: json['line'] as String?,
        tareKg: (json['tareKg'] as num).toDouble(),
        vgmKg: (json['vgmKg'] as num?)?.toDouble(),
        reeferTemperature: json['reeferTemperature'] as String?,
        origin: json['origin'] as String?,
        contents: json['contents'] as String? ?? '',
        hour: json['hour'] as String?,
        seal: json['seal'] as String?,
        agency: json['agency'] as String?,
        imdgClass: json['imdgClass'] as String?,
        unNumbers: (json['unNumbers'] as List<dynamic>?)?.cast<String>() ?? const [],
      );
}

/// Una fila que no se entendió: se informa con su número, nunca se descarta
/// en silencio.
class ExportListIssue extends Equatable {
  final int sheetRow;
  final String message;

  const ExportListIssue(this.sheetRow, this.message);

  @override
  List<Object?> get props => [sheetRow, message];

  Map<String, dynamic> toJson() => {'row': sheetRow, 'message': message};

  factory ExportListIssue.fromJson(Map<String, dynamic> json) =>
      ExportListIssue(json['row'] as int, json['message'] as String);
}

/// T-73 · El listado de exportación de la agencia, normalizado. Es la fuente
/// `export_list` de la operación (T-79a 2.1).
class ExportList extends Equatable {
  static const format = 'baystream-listado';
  static const schema = 1;

  final String fileName;

  /// Filas de título antes de los encabezados, como texto.
  final List<String> titleLines;
  final List<ExportListRow> rows;
  final List<ExportListIssue> issues;

  /// Las equivalencias con que se tradujeron los códigos; vacía si todavía no.
  final CodeEquivalences equivalences;

  ExportList({
    required this.fileName,
    Iterable<String> titleLines = const [],
    required Iterable<ExportListRow> rows,
    Iterable<ExportListIssue> issues = const [],
    CodeEquivalences? equivalences,
  })  : titleLines = List.unmodifiable(titleLines),
        rows = List.unmodifiable(rows),
        issues = List.unmodifiable(issues),
        equivalences = equivalences ?? CodeEquivalences.empty;

  Iterable<ExportListRow> get fulls => rows.where((r) => r.isFull);
  Iterable<ExportListRow> get empties => rows.where((r) => r.isEmpty);

  /// Agencias en el orden del listado, con cuántos contenedores trae cada una.
  Map<String, int> get agencies {
    final result = <String, int>{};
    for (final row in rows) {
      final agency = row.agency ?? 'Sin agencia';
      result[agency] = (result[agency] ?? 0) + 1;
    }
    return result;
  }

  ExportListRow? byContainer(String containerId) {
    for (final row in rows) {
      if (row.containerId == containerId) return row;
    }
    return null;
  }

  ExportListRow? byOrder(int order) {
    for (final row in rows) {
      if (row.order == order) return row;
    }
    return null;
  }

  /// Traduce los códigos de cada fila desde los del Excel, nunca sobre una
  /// traducción anterior.
  ExportList normalized(CodeEquivalences equivalences) => ExportList(
        fileName: fileName,
        titleLines: titleLines,
        rows: rows.map((r) => r.translated(equivalences)),
        issues: issues,
        equivalences: equivalences,
      );

  @override
  List<Object?> get props => [fileName, titleLines, rows, issues, equivalences];

  Map<String, dynamic> toJson() => {
        'format': format,
        'schema': schema,
        'fileName': fileName,
        'titleLines': titleLines,
        'equivalences': equivalences.toJson(),
        'rows': rows.map((r) => r.toJson()).toList(),
        'issues': issues.map((i) => i.toJson()).toList(),
      };

  factory ExportList.fromJson(Map<String, dynamic> json) {
    if (json['format'] != format || json['schema'] != schema) {
      throw FormatException(
          'Listado guardado en un formato no admitido: ${json['format']} ${json['schema']}');
    }
    return ExportList(
      fileName: json['fileName'] as String,
      titleLines: (json['titleLines'] as List<dynamic>? ?? const []).cast<String>(),
      equivalences: CodeEquivalences.fromJson(
          Map<String, dynamic>.from(json['equivalences'] as Map? ?? const {})),
      rows: (json['rows'] as List<dynamic>)
          .map((r) => ExportListRow.fromJson(Map<String, dynamic>.from(r as Map))),
      issues: (json['issues'] as List<dynamic>? ?? const [])
          .map((i) => ExportListIssue.fromJson(Map<String, dynamic>.from(i as Map))),
    );
  }
}
