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
///
/// T-147 (10.151, hallazgo 3) · [pod] es el puerto con que la fila se cruza
/// con el plan: donde el contenedor baja del buque. El plan trae ese puerto
/// en su `LOC+11`, y el listado lo trae en la columna POT cuando la llena; su
/// columna POD es entonces el destino final. Por eso [pod] sale del POT si la
/// fila lo trae y, si no, del POD, como hasta la 1.0.1 ([listCrossPort]). La
/// fila conserva los dos como vinieron, en [listPot] y [listPod], y la forma
/// guardada no cambia: la 1.0.1 lee el grupo de `pod`, igual que antes.
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
        pod = pod ?? listPot ?? listPod,
        line = line ?? listLine,
        unNumbers = List.unmodifiable(unNumbers);

  /// T-147 · El código de puerto del Excel con que la fila se cruza con el
  /// plan: el POT si la fila lo trae; si no, el POD.
  String get listCrossPort => listPot ?? listPod;

  /// T-147 · Si el Excel trae en esta fila un POT distinto del POD: la
  /// pantalla enseña entonces los dos.
  bool get potDiffersFromPod => listPot != null && listPot != listPod;

  /// T-147, entrega 2 (10.156 y 10.160, cambio 1) · Las tres notas con que la
  /// agencia dice que una fila no se carga en este buque: la palabra CANCEL
  /// con sus formas (CANCELADO, CANCELADA, sus plurales, CANCELLED y
  /// CANCELED), «ROLEADO» y «YA EMBARCADO», con su femenino y su plural.
  /// Enteras, sobre el texto en mayúsculas, sin tildes y con un solo espacio.
  ///
  /// En el listado del piloto 4 (caso A09) vienen en la columna MARCHAMO:
  /// «ROLEADO - CANCEL», «YA EMBARCADO -CANCEL», «CANCELADO» y «REEMPLAZO -
  /// CANCEL». Carlos confirmó que las cuatro, y «ROLEADO» y «YA EMBARCADO»
  /// solas, quieren decir siempre que la fila no se carga.
  static final cancellationNote = RegExp(r'\bCANCEL(?:AD[OA]S?|LED|ED)?\b'
      r'|\bROLEAD[OA]S?\b'
      r'|\bYA EMBARCAD[OA]S?\b');

  /// Mayúsculas, sin tildes y con un solo espacio, para buscar una nota.
  static String _plain(String text) {
    const from = 'ÁÉÍÓÚÜáéíóúü';
    const to = 'AEIOUUaeiouu';
    final buffer = StringBuffer();
    for (final rune in text.runes) {
      final char = String.fromCharCode(rune);
      final index = from.indexOf(char);
      buffer.write(index < 0 ? char : to[index]);
    }
    return buffer.toString().toUpperCase().replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  /// T-147, entrega 2 · La nota con que el listado cancela esta fila, o nulo
  /// si la fila se carga. Se busca en MARCHAMO ([seal]) y, si no está, en
  /// CONTENIDO ([contents]), que es donde T-132 ya la buscaba. Sale de lo que
  /// la fila ya guarda: un listado guardado por la 1.0.1 o la 1.0.2 se lee
  /// cancelado sin volver a importarlo.
  ///
  /// De MARCHAMO se devuelve el texto entero, como lo escribió la agencia; de
  /// CONTENIDO, solo la nota, porque el resto es la descripción de la carga.
  late final String? cancelNote = _findCancelNote();

  String? _findCancelNote() {
    final mark = seal;
    if (mark != null && cancellationNote.hasMatch(_plain(mark))) {
      return mark.replaceAll(RegExp(r'\s+'), ' ').trim();
    }
    return cancellationNote.firstMatch(_plain(contents))?.group(0);
  }

  /// Si el listado dice que esta fila no se carga en este buque.
  bool get cancelled => cancelNote != null;

  /// T-147, entrega 2 (D1) · Un texto en MARCHAMO que no es una cancelación
  /// ni parece un marchamo, porque no trae ninguna cifra («PENDIENTE»): la
  /// fila se carga y el resumen la avisa.
  String? get unrecognizedNote {
    final mark = seal?.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (mark == null || mark.isEmpty || cancelled) return null;
    return RegExp(r'\d').hasMatch(mark) ? null : mark;
  }

  /// T-122 (H4, 10.51) · La fila que el listado no trae: **un lleno** del plan
  /// de carga, armado desde el plan para cargarlo por su número de
  /// contenedor. Sin OR: [order] y [sheetRow] valen 0 y [unlisted] la
  /// distingue; su movimiento se registra sin `order`. Un vacío con número o
  /// un contenedor sin estado no se carga así (10.59): su tara y su tipo
  /// exactos solo están en su fila, y `LoadingOperation.draft` lo rechaza.
  factory ExportListRow.fromPlan(ContainerUnit container) => ExportListRow(
        sheetRow: 0,
        order: 0,
        containerId: container.containerId,
        status: container.status,
        listType: container.isoSizeType ?? '',
        listPod: container.portOfDischarge ?? '',
        listLine: container.operatorCode ?? '',
        tareKg: container.tareWeight ?? 0,
        vgmKg: container.vgmWeight,
        imdgClass: container.imdgClass,
        unNumbers: [if (container.unNumber != null) container.unNumber!],
      );

  /// Verdadero para una fila armada desde el plan ([ExportListRow.fromPlan]).
  bool get unlisted => sheetRow == 0;

  /// Cómo se nombra en un aviso: «OR 12» o, sin fila, el número.
  String get name => unlisted ? containerId : 'OR $order';

  /// Cómo se rotula en una lista o un diálogo.
  String get label =>
      unlisted ? '$containerId · sin OR en el listado' : 'OR $order · $containerId';

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
        pod: equivalences.translate(EquivalenceKind.port, listCrossPort),
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

  /// T-147, entrega 2 (hallazgo 6 de la 10.151; D9) · «También llena»: los
  /// códigos ISO del plan que un tipo del listado llena además del suyo, cada
  /// uno con el código principal de ese tipo. El listado del piloto 4 dice
  /// 40HC y el plan separa 45G1 y 45G0: con `{45G0: 45G1}`, una celda 45G0 es
  /// del grupo de los 45G1.
  ///
  /// La fila no cambia: su [ExportListRow.type] sigue siendo el principal, así
  /// que la 1.0.2, que no lee esta clave, arma los mismos grupos que antes.
  /// Un código del plan lo llena un solo grupo (10.160, cambio 4).
  final Map<String, String> typeFamilies;

  ExportList({
    required this.fileName,
    Iterable<String> titleLines = const [],
    required Iterable<ExportListRow> rows,
    Iterable<ExportListIssue> issues = const [],
    CodeEquivalences? equivalences,
    Map<String, String> typeFamilies = const {},
  })  : titleLines = List.unmodifiable(titleLines),
        rows = List.unmodifiable(rows),
        issues = List.unmodifiable(issues),
        equivalences = equivalences ?? CodeEquivalences.empty,
        typeFamilies = Map.unmodifiable(typeFamilies);

  Iterable<ExportListRow> get fulls => rows.where((r) => r.isFull);
  Iterable<ExportListRow> get empties => rows.where((r) => r.isEmpty);

  /// T-147, entrega 2 · Las filas que se cargan en este buque y las que el
  /// listado cancela ([ExportListRow.cancelled]). [fulls], [empties] y [rows]
  /// siguen trayendo todas.
  Iterable<ExportListRow> get loadRows => rows.where((r) => !r.cancelled);
  Iterable<ExportListRow> get cancelledRows => rows.where((r) => r.cancelled);

  /// Las canceladas contadas por su nota, de la más repetida a la menos.
  Map<String, int> get cancelNotes {
    final counts = <String, int>{};
    for (final row in cancelledRows) {
      counts[row.cancelNote!] = (counts[row.cancelNote!] ?? 0) + 1;
    }
    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Map.fromEntries(sorted);
  }

  /// Las notas de MARCHAMO que no se reconocen, con los OR que las traen.
  Map<String, List<int>> get unrecognizedNotes {
    final notes = <String, List<int>>{};
    for (final row in rows) {
      final note = row.unrecognizedNote;
      if (note != null) notes.putIfAbsent(note, () => []).add(row.order);
    }
    return notes;
  }

  /// El código del grupo de [planType]: el principal del tipo que lo llena,
  /// o él mismo si nadie lo declaró.
  String? groupType(String? planType) =>
      planType == null ? null : typeFamilies[planType] ?? planType;

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
  ExportList normalized(CodeEquivalences equivalences,
          {Map<String, String> typeFamilies = const {}}) =>
      ExportList(
        fileName: fileName,
        titleLines: titleLines,
        rows: rows.map((r) => r.translated(equivalences)),
        issues: issues,
        equivalences: equivalences,
        typeFamilies: typeFamilies,
      );

  @override
  List<Object?> get props => [
        fileName,
        titleLines,
        rows,
        issues,
        equivalences,
        (typeFamilies.entries.toList()..sort((a, b) => a.key.compareTo(b.key)))
            .map((e) => '${e.key}=${e.value}')
            .join(','),
      ];

  /// `typeFamilies` solo se escribe si hay algo declarado: un listado sin
  /// «también llena» se guarda byte por byte como lo guardaba la 1.0.2.
  Map<String, dynamic> toJson() => {
        'format': format,
        'schema': schema,
        'fileName': fileName,
        'titleLines': titleLines,
        'equivalences': equivalences.toJson(),
        if (typeFamilies.isNotEmpty) 'typeFamilies': typeFamilies,
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
      typeFamilies:
          Map<String, String>.from(json['typeFamilies'] as Map? ?? const {}),
      rows: (json['rows'] as List<dynamic>)
          .map((r) => ExportListRow.fromJson(Map<String, dynamic>.from(r as Map))),
      issues: (json['issues'] as List<dynamic>? ?? const [])
          .map((i) => ExportListIssue.fromJson(Map<String, dynamic>.from(i as Map))),
    );
  }
}
