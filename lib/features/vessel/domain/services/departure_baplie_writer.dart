import '../../../../core/utils/iso_coordinate_parser.dart';
import '../entities/entities.dart';
import 'departure_baplie_review.dart';

/// T-82 · Salida local en la versión del plan de carga. Para lo que sigue a
/// bordo manda loading_baplie; llegada respalda únicamente datos no declarados
/// en ese plan (decisión de Carlos del 11-oct). La posición es la física derivada.
class DepartureBaplieWriter {
  const DepartureBaplieWriter();

  DepartureBaplie generate({
    required Operation operation,
    required OperationState state,
    ExportList? list,
    Iterable<Movement> movements = const [],
    DateTime? now,
    Map<String, DepartureChoice> choices = const {},
    bool preview = false,
  }) {
    final source = operation.source(OperationSourceKind.loadingBaplie);
    if (source == null || source.content.trim().isEmpty) {
      throw StateError(
        'La operación no tiene el plan de carga (BAPLIE): '
        'impórtalo antes de generar la salida.',
      );
    }
    final header = _header(source.content, now ?? DateTime.now());
    final plan = state.effectivePlan;
    if (plan == null) {
      throw StateError(
        'No está disponible el plan efectivo de la operación: '
        'espera a que termine de cargar e inténtalo de nuevo.',
      );
    }
    final arrivalGroups = _groups(
      operation.source(OperationSourceKind.arrivalBaplie)?.content ?? '',
    );
    final loadingGroups = _groups(source.content);
    final rawLoading = _rawGroups(source.content);
    final rawArrival = _rawGroups(
      operation.source(OperationSourceKind.arrivalBaplie)?.content ?? '',
    );
    final charset = DepartureCharacterSet.fromSource(source.content);
    final decisions = <DepartureDecision>[];
    final warnings = <String>[];
    final errors = <String>[];
    final rows = {
      for (final row in list?.rows ?? <ExportListRow>[]) row.containerId: row,
    };
    final cargo = <({
      String position,
      String container,
      List<String> segments,
      String raw,
    })>[];
    final seen = <String>{};
    final cells = <String>{};
    final withoutRow = <String>[];
    for (final item in state.items.values) {
      if (item.state == ItemState.cancelled || item.position == null) continue;
      if (item.role == PlanRole.load && item.state != ItemState.moved) continue;
      final container = item.assignedContainer ??
          (item.kind == PlanItemKind.container ? item.key.substring(2) : null);
      if (container == null) continue;
      final position = IsoCoordinateParser.parse(item.position!).toIsoCode();
      if (!seen.add(container) || !cells.add(position)) {
        throw StateError(
          'Hay ocupantes duplicados en el estado derivado; '
          'resuelve el conflicto antes de generar.',
        );
      }
      final original = plan.arrival[item.key];
      List<String> group;
      if (original != null || item.role != PlanRole.load) {
        final current = loadingGroups[container];
        final backup = arrivalGroups[container];
        if (current == null && backup == null) {
          throw StateError(
            'Falta la fuente del ocupante $container; '
            'no se puede conservar su información. Vuelve a importar el plano '
            'de llegada y el plan de carga.',
          );
        }
        group = _aboard(current, backup);
        final loc = group.first.split('+');
        final components = loc[2].split(':');
        components[0] = position;
        loc[2] = components.join(':');
        group[0] = loc.join('+');
      } else {
        final row = rows[container];
        if (row != null) {
          group = _loaded(
            row,
            position,
            plan.portOfCall,
            current: loadingGroups[container],
            choices: choices,
            decisions: decisions,
            warnings: warnings,
            errors: errors,
            charset: charset,
            operationId: operation.id,
          );
        } else {
          // T-122, corrección 1 (10.57): un lleno cargado por su número sin
          // fila en el listado (H4) sale con el grupo de segmentos que el plan
          // de carga le dio, en la celda donde quedó, como lo que sigue a
          // bordo. Son los datos que la agencia transmitió (peso, puertos,
          // línea, DGS y lo que el lector no modela), no inventados; lo que
          // la fila añadiría (VGM y tara exactos, marchamo) no se adivina.
          final current = loadingGroups[container];
          if (current == null) {
            // Un vacío asignado a una reserva no tiene grupo propio en el
            // plan (la reserva va sin número): su fila sigue siendo la única
            // fuente de su tara y su tipo exactos (H4: los vacíos esperan el
            // listado).
            throw StateError(
              item.kind == PlanItemKind.reservedSlot
                  ? 'El vacío asignado $container no está en el listado; su fila '
                      'trae la tara y el tipo exactos. Importa el listado de la '
                      'agencia que lo incluye.'
                  : 'El contenedor cargado $container no está en el listado ni '
                      'trae su grupo en el plan de carga; faltan sus datos. Importa '
                      'el listado de la agencia que lo incluye.',
            );
          }
          group = [...current];
          final loc = group.first.split('+');
          final components = loc[2].split(':');
          components[0] = position;
          loc[2] = components.join(':');
          group[0] = loc.join('+');
          withoutRow.add(container);
        }
      }
      // Un grupo no alterado conserva incluso sus separadores y márgenes.
      // Si solo se movió, se sustituye únicamente el LOC+147 original.
      final current = loadingGroups[container] ?? arrivalGroups[container];
      final raw = rawLoading[container] ?? rawArrival[container];
      final preserve = current != null &&
          raw != null &&
          current.length == group.length &&
          Iterable<int>.generate(
            group.length,
          ).skip(1).every((i) => current[i] == group[i]);
      cargo.add((
        position: position,
        container: container,
        segments: group,
        raw: preserve
            ? raw.replaceFirst(current.first, group.first)
            : "${group.join("'\n")}'\n",
      ));
    }
    cargo.sort((a, b) => a.position.compareTo(b.position));
    final segments = [
      ...header.segments,
      for (final group in cargo) ...group.segments,
    ];
    final unh = segments.indexWhere((s) => s.startsWith('UNH+'));
    segments.add('UNT+${segments.length - unh + 1}+${header.message}');
    segments.add('UNZ+1+${header.interchange}');
    final byId = {for (final m in movements) m.id: m};
    final cancelled = state.items.values
        .where((i) => i.state == ItemState.cancelled)
        .toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    final cancelledLines = <String>[];
    for (final item in cancelled) {
      final row = rows[item.key.startsWith('C:') ? item.key.substring(2) : ''];
      final reason = byId[item.movementId]?.payload['reason'] as String?;
      cancelledLines.add(
        '${row == null ? item.key : 'OR ${row.order} · ${row.containerId}'}'
        ' · ${item.plannedPosition ?? 'sin posición'} · ${reason ?? 'Sin motivo registrado'}',
      );
    }
    final notLoaded = <String>[];
    final unshipped = rows.values
        .where((row) => !seen.contains(row.containerId))
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));
    for (final row in unshipped) {
      final item = state['C:${row.containerId}'];
      final cancelledInList = RegExp(
        r'\bCANCEL(?:ADO|ADA|ADOS|ADAS|LED|ED)?\b',
        caseSensitive: false,
      ).hasMatch(row.contents);
      final reason = cancelledInList
          ? 'cancelado en el listado'
          : item?.state == ItemState.cancelled
              ? 'cancelado en la operación'
              : !loadingGroups.containsKey(row.containerId)
                  ? (row.isEmpty
                      ? 'sin celda asignada en el plan'
                      : 'sin celda en el plan')
                  : 'carga no registrada';
      notLoaded.add('OR ${row.order} · ${row.containerId} · $reason');
    }
    final unresolved = decisions.where((d) => !choices.containsKey(d.id));
    final canSave = unresolved.isEmpty && errors.isEmpty;
    if (!preview && !canSave) {
      throw StateError(
        errors.isNotEmpty
            ? errors.join('\n')
            : 'Elige el dato válido en cada discrepancia antes de guardar el '
                'BAPLIE de salida.',
      );
    }
    final text = canSave
        ? "${header.segments.join("'\n")}'\n"
            '${cargo.map((c) => c.raw).join()}'
            "${segments.skip(segments.length - 2).join("'\n")}'\n"
        : '';
    DepartureCharacterSet.bytes(text);
    return DepartureBaplie(
      text: text,
      containers: cargo.length,
      pendingLoads: state.items.values
          .where((i) => i.role == PlanRole.load && i.state == ItemState.planned)
          .length,
      pendingDischarges: state.items.values
          .where(
            (i) =>
                (i.role == PlanRole.discharge || i.restow) &&
                i.state == ItemState.planned,
          )
          .length,
      cancelled: cancelledLines,
      withoutRow: withoutRow..sort(),
      decisions: decisions,
      warnings: warnings,
      errors: errors,
      notLoaded: notLoaded,
      canSave: canSave,
    );
  }

  /// Conserva los segmentos del plan, incluidos los que el lector no modela.
  /// WT/VGM son una familia: un VGM viejo no puede imponerse al WT vigente.
  /// Tara, puertos, línea, temperatura y DGS se respaldan por declaración.
  List<String> _aboard(List<String>? current, List<String>? backup) {
    if (current == null) return [...backup!];
    if (backup == null) return [...current];
    final result = [...current];
    String key(String segment) {
      final e = segment.split('+');
      if (e[0] == 'DGS') return 'DGS';
      if (e[0] == 'MEA') {
        final qualifier = {'WT', 'VGM', 'T'}.contains(e.elementAtOrNull(1))
            ? e[1]
            : e.elementAtOrNull(2);
        return qualifier == 'WT' || qualifier == 'VGM'
            ? 'MEA:weight'
            : 'MEA:$qualifier';
      }
      return '${e[0]}:${e.elementAtOrNull(1) ?? ''}';
    }

    bool declared(String segment) {
      final e = segment.split('+');
      return switch (e[0]) {
        'LOC' ||
        'NAD' =>
          e.elementAtOrNull(2)?.split(':').first.isNotEmpty ?? false,
        'MEA' =>
          e.elementAtOrNull(3)?.split(':').elementAtOrNull(1)?.isNotEmpty ??
              false,
        _ => true,
      };
    }

    final eqdIndex = result.indexWhere((s) => s.startsWith('EQD+CN+'));
    final backupEqd = backup.where((s) => s.startsWith('EQD+CN+')).firstOrNull;
    if (eqdIndex >= 0 && backupEqd != null) {
      final primary = result[eqdIndex].split('+');
      final fallback = backupEqd.split('+');
      while (primary.length < fallback.length) {
        primary.add('');
      }
      for (var i = 3; i < fallback.length; i++) {
        if (primary[i].isEmpty) primary[i] = fallback[i];
      }
      result[eqdIndex] = primary.join('+');
    }
    final candidates = <String, List<String>>{};
    for (final segment in backup.skip(1)) {
      if (segment.startsWith('EQD+')) continue;
      candidates.putIfAbsent(key(segment), () => []).add(segment);
    }
    for (final entry in candidates.entries) {
      if (result.any((s) => key(s) == entry.key && declared(s))) continue;
      result.removeWhere((s) => key(s) == entry.key);
      final afterEquipment = entry.value.first.startsWith('NAD+') ||
          entry.value.first.startsWith('DGS+');
      final equipment = result.indexWhere((s) => s.startsWith('EQD+'));
      result.insertAll(
          afterEquipment || equipment < 0 ? result.length : equipment,
          entry.value);
    }
    return result;
  }

  List<String> _loaded(
    ExportListRow row,
    String position,
    String port, {
    required List<String>? current,
    required Map<String, DepartureChoice> choices,
    required List<DepartureDecision> decisions,
    required List<String> warnings,
    required List<String> errors,
    required DepartureCharacterSet charset,
    required String operationId,
  }) {
    final who = 'OR ${row.order} · ${row.containerId}';
    void validate(String name, String value) {
      if (!charset.supported) {
        final error = 'El juego de caracteres ${charset.code} del UNB no está '
            'admitido para datos nuevos. Pide el plan en UNOA, UNOB o UNOC.';
        if (!errors.contains(error)) errors.add(error);
        return;
      }
      for (final rune in value.runes.toSet()) {
        if (!charset.accepts(rune)) {
          errors.add(
            '$who · fila ${row.sheetRow} · $name: el carácter '
            '«${String.fromCharCode(rune)}» (U+${rune.toRadixString(16).toUpperCase().padLeft(4, '0')}) '
            'no cabe en ${charset.code}. Corrige la fila y vuelve a importar el listado.',
          );
        }
      }
    }

    String field(String name, String value) {
      validate(name, value);
      return value
          .replaceAll('?', '??')
          .replaceAll('+', '?+')
          .replaceAll(':', '?:')
          .replaceAll("'", "?'")
          .replaceAll(RegExp(r'[\r\n]'), ' ');
    }

    String weight(double value) {
      if (!value.isFinite || value < 0) {
        throw StateError(
          '$who: el listado contiene un peso inválido. Corrige '
          'los pesos en el Excel y vuelve a importarlo.',
        );
      }
      // Para pesos no negativos, round redondea la mitad hacia arriba.
      return value.round().toString();
    }

    if (row.status != ContainerStatus.full &&
        row.status != ContainerStatus.empty) {
      throw StateError(
        'El listado no declara lleno/vacío para ${row.containerId}: corrige '
        'esa fila en el Excel y vuelve a importarlo.',
      );
    }
    if (row.isFull && row.vgmKg == null) {
      throw StateError(
        'El listado no declara el VGM de ${row.containerId}: '
        'pide el VGM a la agencia y vuelve a importar el listado.',
      );
    }
    final result =
        current == null ? <String>['LOC+147+$position::5'] : [...current];
    final loc = result.first.split('+');
    final coordinates = loc[2].split(':')..[0] = position;
    loc[2] = coordinates.join(':');
    result[0] = loc.join('+');

    void replace(
      bool Function(String) matches,
      List<String> values, {
      bool afterEquipment = false,
    }) {
      var index = result.indexWhere(matches);
      if (index < 0) {
        int rank(String s) => switch (s.split('+').first) {
              'LOC' => s.startsWith('LOC+147+') ? 0 : 6,
              'FTX' => 1,
              'MEA' => 2,
              'DIM' => 3,
              'TMP' => 4,
              'RNG' => 5,
              'RFF' => 7,
              'EQD' => 8,
              'NAD' => 9,
              'DGS' => 10,
              _ => afterEquipment ? 10 : 7,
            };
        final target = values.isEmpty ? 11 : rank(values.first);
        index = result.indexWhere((s) => rank(s) > target);
        if (index < 0) index = result.length;
      }
      result.removeWhere(matches);
      result.insertAll(index.clamp(0, result.length), values);
    }

    bool gross(String s) =>
        RegExp(r'^MEA\+(WT|VGM)\+|^MEA\+[^+]*\+(WT|VGM)\+').hasMatch(s);
    bool tare(String s) => RegExp(r'^MEA\+T\+|^MEA\+[^+]*\+T\+').hasMatch(s);
    replace(gross, [
      row.vgmKg == null
          ? 'MEA+WT++KGM:${weight(row.tareKg)}'
          : 'MEA+VGM++KGM:${weight(row.vgmKg!)}',
    ]);
    replace(tare, ['MEA+T++KGM:${weight(row.tareKg)}']);
    if (!result.any((s) => s.startsWith('LOC+9+'))) {
      replace((s) => s.startsWith('LOC+9+'), ['LOC+9+$port:139:6']);
    }
    replace((s) => s.startsWith('LOC+11+'), [
      'LOC+11+${field('POD', row.pod)}:139:6',
    ]);
    replace((s) => s.startsWith('LOC+13+'), [
      if (row.pot != null && row.pot!.isNotEmpty && row.pot != row.pod)
        'LOC+13+${field('POT', row.pot!)}:139:6',
    ]);
    if (!result.any((s) => s.startsWith('RFF+BM:'))) {
      replace((s) => s.startsWith('RFF+BM:'), ['RFF+BM:1']);
    }
    final equipment =
        (current?.where((s) => s.startsWith('EQD+CN+')).firstOrNull ?? 'EQD+CN')
            .split('+');
    while (equipment.length < 7) {
      equipment.add('');
    }
    equipment[2] = field('CONTENEDOR', row.containerId);
    // Solo se sustituye el código ISO; sus componentes adicionales se conservan.
    final type = equipment[3].split(':')..[0] = field('TIPO', row.type);
    equipment[3] = type.join(':');
    equipment[6] = row.isEmpty ? '4' : '5';
    replace((s) => s.startsWith('EQD+CN+'), [equipment.join('+')]);
    replace(
        (s) => s.startsWith('NAD+CA+'),
        [
          'NAD+CA+${field('OPR', row.line)}:172:20',
        ],
        afterEquipment: true);

    final dgs = result.where((s) => s.startsWith('DGS+')).toList();
    Set<String> declared(int element) => {
          for (final s in dgs)
            if ((s.split('+').elementAtOrNull(element)?.split(':').first ?? '')
                .isNotEmpty)
              s.split('+')[element].split(':').first,
        };
    final classes = declared(2);
    final numbers = declared(3);
    final listNumbers = row.unNumbers.toSet();
    final mismatch = dgs.isNotEmpty &&
        row.isDangerous &&
        ((row.imdgClass != null &&
                (classes.length != 1 || !classes.contains(row.imdgClass))) ||
            (listNumbers.isNotEmpty &&
                (listNumbers.length != numbers.length ||
                    !numbers.containsAll(listNumbers))));
    DepartureChoice? dangerousChoice;
    if (mismatch) {
      final details = <String>[
        if (listNumbers.isNotEmpty &&
            (listNumbers.length != numbers.length ||
                !numbers.containsAll(listNumbers)))
          'El plan dice ${numbers.map((n) => 'UN $n').join(', ')}; el listado, ${listNumbers.map((n) => 'UN $n').join(', ')}',
        if (row.imdgClass != null &&
            (classes.length != 1 || !classes.contains(row.imdgClass)))
          'El plan dice clase ${classes.join(', ')}; el listado, clase ${row.imdgClass}',
      ];
      final id =
          '$operationId|${row.containerId}|DGS|${dgs.join("'")}|${row.imdgClass}|${row.unNumbers.join(',')}';
      decisions.add(
        DepartureDecision(
          id: id,
          container: row.containerId,
          order: row.order,
          subject: 'Mercancías peligrosas',
          message: details.join('. '),
        ),
      );
      dangerousChoice = choices[id];
    }
    if (dgs.isEmpty && row.isDangerous) {
      warnings.add(
        '$who: solo el listado declara mercancías peligrosas. '
        'La salida lleva los datos disponibles; verifica la declaración de peligrosas.',
      );
    } else if (dgs.isNotEmpty && !row.isDangerous) {
      warnings.add(
        '$who: el plan declara mercancías peligrosas y el listado no las declara. '
        'Se conserva el DGS completo del plan.',
      );
    }
    if (row.isDangerous &&
        (dgs.isEmpty || dangerousChoice == DepartureChoice.list)) {
      final values = <String>[];
      final used = <int>{};
      // Una clase sin ONU en el listado no borra los ONU ni los otros DGS
      // que el plan sí declara.
      final uns = row.unNumbers.isNotEmpty
          ? row.unNumbers
          : dgs.isEmpty
              ? ['']
              : dgs
                  .map((s) =>
                      s.split('+').elementAtOrNull(3)?.split(':').first ?? '')
                  .toList();
      for (var i = 0; i < uns.length; i++) {
        var index = dgs.indexWhere(
          (s) => s.split('+').elementAtOrNull(3)?.split(':').first == uns[i],
        );
        if (index < 0 || used.contains(index)) {
          index = Iterable<int>.generate(
                dgs.length,
              ).where((n) => !used.contains(n)).firstOrNull ??
              -1;
        }
        if (index >= 0) used.add(index);
        final parts = (index < 0 ? 'DGS+IMD++' : dgs[index]).split('+');
        while (parts.length < 4) {
          parts.add('');
        }
        final hazard = parts[2].split(':');
        if (row.imdgClass != null) {
          hazard[0] = field('Clase IMDG', row.imdgClass!);
        }
        parts[2] = hazard.join(':');
        if (uns[i].isNotEmpty) {
          final un = parts[3].split(':')..[0] = field('Número ONU', uns[i]);
          parts[3] = un.join(':');
        }
        values.add(parts.join('+'));
      }
      replace((s) => s.startsWith('DGS+'), values, afterEquipment: true);
    }

    if (row.isFull && row.reeferTemperature?.trim().isNotEmpty == true) {
      final listTemperature = DepartureTemperature.parse(
        row.reeferTemperature!,
      );
      final planTemps = result.where((s) => s.startsWith('TMP+2+')).toList();
      if (listTemperature == null) {
        errors.add(
          '$who · fila ${row.sheetRow} · REEFER TEMP: '
          '«${row.reeferTemperature}» no es una temperatura válida. '
          'Usa un número en °C o indica C/CEL o F/FAH y vuelve a importar el listado.',
        );
      } else if (planTemps.isEmpty) {
        replace((s) => s.startsWith('TMP+2+'), [listTemperature.segment]);
      } else if (planTemps.any(
        (s) => !(DepartureTemperature.fromSegment(s)?.sameAs(listTemperature) ??
            false),
      )) {
        final id =
            '$operationId|${row.containerId}|TMP|${planTemps.join("'")}|${listTemperature.segment}';
        final planLabel = planTemps
            .map((s) => DepartureTemperature.fromSegment(s)?.label ?? s)
            .join(', ');
        decisions.add(
          DepartureDecision(
            id: id,
            container: row.containerId,
            order: row.order,
            subject: 'Temperatura del refrigerado',
            message:
                'El plan dice $planLabel; el listado, ${listTemperature.label}',
          ),
        );
        if (choices[id] == DepartureChoice.list) {
          replace((s) => s.startsWith('TMP+2+'), [listTemperature.segment]);
        }
      }
    }
    return result;
  }

  ({List<String> segments, String message, String interchange}) _header(
      String source, DateTime clock) {
    final segments = _segments(source);
    final firstCargo = segments.indexWhere((s) => s.startsWith('LOC+147+'));
    final end = segments.indexWhere((s) => s.startsWith('UNT+'));
    final header = segments
        .take(firstCargo < 0 ? (end < 0 ? segments.length : end) : firstCargo)
        .toList();
    final unh = header.where((s) => s.startsWith('UNH+')).toList();
    final unb = header.where((s) => s.startsWith('UNB+')).toList();
    if (unh.length != 1 ||
        unb.length != 1 ||
        segments.where((s) => s.startsWith('UNH+')).length != 1) {
      throw StateError(
          'El plan de carga debe contener un único mensaje BAPLIE con sus '
          'segmentos UNB y UNH: no se generó la salida. Vuelve a importar el '
          'plan de carga.');
    }
    final messageId = unh.single.split('+').elementAtOrNull(2)?.split(':');
    if (messageId == null ||
        messageId.length != 5 ||
        messageId.take(4).join(':') != 'BAPLIE:D:95B:UN' ||
        !{'SMDG20', 'SMDG21', 'SMDG22'}.contains(messageId[4])) {
      throw StateError('Versión BAPLIE no reconocida para salida 2.x en la '
          'cabecera UNH: ${messageId?.join(':') ?? 'sin cabecera'}. No se generó '
          'el archivo. Importa el plan de carga en SMDG20, SMDG21 o SMDG22.');
    }
    final utc = clock.toUtc();
    String two(int value) => value.toString().padLeft(2, '0');
    final date =
        '${utc.year}${two(utc.month)}${two(utc.day)}${two(utc.hour)}${two(utc.minute)}';
    final interchange =
        'BS${utc.microsecondsSinceEpoch.toRadixString(36).toUpperCase()}';
    final message = '${interchange}M';
    for (var i = 0; i < header.length; i++) {
      final elements = header[i].split('+');
      switch (elements[0]) {
        case 'UNB':
          while (elements.length < 6) {
            elements.add('');
          }
          elements[4] = '${date.substring(2, 8)}:${date.substring(8)}';
          elements[5] = interchange;
          header[i] = elements.join('+');
        case 'UNH':
          elements[1] = message;
          header[i] = elements.join('+');
        case 'BGM':
          while (elements.length < 4) {
            elements.add('');
          }
          elements[2] = interchange;
          header[i] = elements.join('+');
        case 'DTM':
          if (elements.elementAtOrNull(1)?.startsWith('137:') ?? false) {
            header[i] = 'DTM+137:$date:203';
          }
      }
    }
    return (segments: header, message: message, interchange: interchange);
  }

  /// La separación respeta el carácter de liberación; no descarta datos.
  List<String> _segments(String text) {
    if (text.trimLeft().startsWith('UNA') &&
        !text.trimLeft().startsWith("UNA:+.? '")) {
      throw StateError(
          'Separadores EDIFACT no reconocidos en el segmento UNA del plan de '
          'carga: no se generó la salida. Pide una exportación con los '
          'separadores estándar.');
    }
    final result = <String>[];
    var start = 0;
    for (var i = 0; i < text.length; i++) {
      if (text[i] == '?') {
        i++;
        continue;
      }
      if (text[i] != "'") continue;
      final segment = text.substring(start, i).trim();
      // El espacio de UNA es el separador reservado, no margen para recortar.
      if (segment.isNotEmpty) {
        result.add(segment.startsWith('UNA') ? 'UNA:+.? ' : segment);
      }
      start = i + 1;
    }
    return result;
  }

  Map<String, List<String>> _groups(String source) {
    final result = <String, List<String>>{};
    List<String>? group;
    String? container;
    void finish() {
      if (container != null && group != null) result[container!] = group!;
      container = null;
      group = null;
    }

    for (final segment in _segments(source)) {
      if (segment.startsWith('LOC+147+')) {
        finish();
        group = [];
      } else if (segment.startsWith('UNT+') || segment.startsWith('UNZ+')) {
        finish();
      }
      group?.add(segment);
      if (group != null && segment.startsWith('EQD+CN+')) {
        final value = segment
            .split('+')
            .elementAtOrNull(2)
            ?.split(':')
            .first
            .replaceAll(' ', '')
            .trim();
        if (value != null && value.isNotEmpty) container = value;
      }
    }
    finish();
    return result;
  }
  Map<String, String> _rawGroups(String source) {
    final result = <String, String>{};
    int? groupStart;
    String? container;
    var start = 0;
    void finish(int end) {
      if (groupStart != null && container != null) {
        result[container!] = source.substring(groupStart!, end);
      }
      groupStart = null;
      container = null;
    }

    for (var i = 0; i < source.length; i++) {
      if (source[i] == '?') {
        i++;
        continue;
      }
      if (source[i] != "'") continue;
      var tagStart = start;
      while (tagStart < i && source[tagStart].trim().isEmpty) {
        tagStart++;
      }
      final segment = source.substring(tagStart, i);
      if (segment.startsWith('LOC+147+')) {
        finish(tagStart);
        groupStart = tagStart;
      } else if (segment.startsWith('UNT+') || segment.startsWith('UNZ+')) {
        finish(tagStart);
      } else if (groupStart != null && segment.startsWith('EQD+CN+')) {
        final id = segment
            .split('+')
            .elementAtOrNull(2)
            ?.split(':')
            .first
            .replaceAll(' ', '')
            .trim();
        if (id?.isNotEmpty == true) container = id;
      }
      start = i + 1;
    }
    finish(source.length);
    return result;
  }
}

class DepartureBaplie {
  final String text;
  final int containers;
  final int pendingLoads;
  final int pendingDischarges;
  final List<String> cancelled;

  /// T-122, corrección 1 · Los llenos cargados sin fila en el listado, que
  /// van con los datos del plan de carga (H4).
  final List<String> withoutRow;
  final List<DepartureDecision> decisions;
  final List<String> warnings;
  final List<String> errors;
  final List<String> notLoaded;
  final bool canSave;
  DepartureBaplie({
    required this.text,
    required this.containers,
    required this.pendingLoads,
    required this.pendingDischarges,
    required Iterable<String> cancelled,
    Iterable<String> withoutRow = const [],
    Iterable<DepartureDecision> decisions = const [],
    Iterable<String> warnings = const [],
    Iterable<String> errors = const [],
    Iterable<String> notLoaded = const [],
    this.canSave = true,
  })  : cancelled = List.unmodifiable(cancelled),
        withoutRow = List.unmodifiable(withoutRow),
        decisions = List.unmodifiable(decisions),
        warnings = List.unmodifiable(warnings),
        errors = List.unmodifiable(errors),
        notLoaded = List.unmodifiable(notLoaded);
  String get cancelledText => cancelled.join('\n');
  String get notLoadedText => notLoaded.join('\n');
}
