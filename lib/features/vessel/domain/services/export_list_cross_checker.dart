import 'package:equatable/equatable.dart';

import '../entities/container_unit.dart';
import '../entities/export_list.dart';
import '../entities/reserved_slot.dart';
import '../entities/vessel_voyage.dart';

/// De dónde sale el código del plan de una equivalencia.
enum EquivalenceOrigin {
  /// Se dedujo de los contenedores que están en el listado y en el plan.
  inferred,

  /// Ya estaba en la tabla del dispositivo.
  saved,

  /// La eligió el usuario en esta importación.
  chosen,

  /// Nada permite deducirla: se pide al usuario.
  pending,
}

/// T-73 · Una fila de la tabla de equivalencias para un listado concreto.
class EquivalenceProposal extends Equatable {
  final EquivalenceKind kind;
  final String listCode;

  /// Código del plan; nulo mientras el usuario no lo elija.
  final String? planCode;
  final EquivalenceOrigin origin;

  /// Filas del listado con ese código.
  final int rows;

  /// Códigos del plan que traen los contenedores de ese código que están en
  /// el listado y en el plan, con cuántos lo respaldan.
  final Map<String, int> observed;

  /// Sugerencias para el usuario cuando hay que preguntar.
  final List<String> candidates;

  EquivalenceProposal({
    required this.kind,
    required this.listCode,
    required this.planCode,
    required this.origin,
    required this.rows,
    Map<String, int> observed = const {},
    Iterable<String> candidates = const [],
  })  : observed = Map.unmodifiable(observed),
        candidates = List.unmodifiable(candidates);

  bool get needsUser => planCode == null;
  bool get isIdentity => planCode == listCode;

  /// Contenedores que respaldan el código elegido.
  int get evidence => planCode == null ? 0 : observed[planCode] ?? 0;

  /// Lo guardado o elegido contradice lo que dicen los contenedores.
  bool get contradicted =>
      planCode != null && observed.isNotEmpty && !observed.containsKey(planCode);

  EquivalenceProposal choose(String code) => EquivalenceProposal(
        kind: kind,
        listCode: listCode,
        planCode: code,
        origin: EquivalenceOrigin.chosen,
        rows: rows,
        observed: observed,
        candidates: candidates,
      );

  @override
  List<Object?> get props => [kind, listCode, planCode, origin, rows, observed, candidates];
}

/// Un lleno del listado encontrado en el plan por su número.
class ExportListMatch extends Equatable {
  final ExportListRow row;
  final ContainerUnit container;

  /// Lo que no coincide entre las dos fuentes, ya con los códigos traducidos.
  final List<String> differences;

  ExportListMatch(this.row, this.container, Iterable<String> differences)
      : differences = List.unmodifiable(differences);

  @override
  List<Object?> get props => [row, container.containerId, differences];
}

/// Un grupo de vacíos del plan: tipo, puerto de descarga y línea. Sus celdas
/// son las reservas sin número y los vacíos que el plan ya trae numerados.
class EmptyGroup extends Equatable {
  final String type;
  final String pod;
  final String line;
  final List<ReservedSlot> reservedSlots;
  final List<ContainerUnit> numberedEmpties;
  final List<ExportListRow> empties;

  EmptyGroup({
    required this.type,
    required this.pod,
    required this.line,
    Iterable<ReservedSlot> reservedSlots = const [],
    Iterable<ContainerUnit> numberedEmpties = const [],
    Iterable<ExportListRow> empties = const [],
  })  : reservedSlots = List.unmodifiable(reservedSlots),
        numberedEmpties = List.unmodifiable(numberedEmpties),
        empties = List.unmodifiable(empties);

  int get planCells => reservedSlots.length + numberedEmpties.length;
  bool get balanced => planCells == empties.length;

  @override
  List<Object?> get props =>
      [type, pod, line, reservedSlots, numberedEmpties.map((c) => c.containerId), empties];
}

/// Un aviso de peligrosas: lo que el listado declara en CONTENIDO y el plan
/// en sus `DGS` no coincide.
class DangerousGoodsNotice extends Equatable {
  final ExportListRow row;
  final String message;

  const DangerousGoodsNotice(this.row, this.message);

  @override
  List<Object?> get props => [row.order, message];
}

/// T-73 · Resultado del cruce del listado con el plan de carga.
class ExportListCrossCheck {
  final String portOfCall;
  final List<ExportListMatch> matches;
  final List<ExportListRow> fullsNotInPlan;

  /// Contenedores con número que el plan carga en la escala y el listado no trae.
  final List<ContainerUnit> planNotInList;
  final List<EmptyGroup> groups;
  final List<ExportListRow> emptiesWithoutGroup;
  final List<DangerousGoodsNotice> dangerousGoods;

  /// Llenos cuyo VGM del listado difiere del peso del plan, y la suma de
  /// (plan − listado) en kg: negativa si el plan pesa menos.
  final int weightDifferences;
  final double weightDifferenceKg;

  ExportListCrossCheck({
    required this.portOfCall,
    required Iterable<ExportListMatch> matches,
    required Iterable<ExportListRow> fullsNotInPlan,
    required Iterable<ContainerUnit> planNotInList,
    required Iterable<EmptyGroup> groups,
    required Iterable<ExportListRow> emptiesWithoutGroup,
    required Iterable<DangerousGoodsNotice> dangerousGoods,
    required this.weightDifferences,
    required this.weightDifferenceKg,
  })  : matches = List.unmodifiable(matches),
        fullsNotInPlan = List.unmodifiable(fullsNotInPlan),
        planNotInList = List.unmodifiable(planNotInList),
        groups = List.unmodifiable(groups),
        emptiesWithoutGroup = List.unmodifiable(emptiesWithoutGroup),
        dangerousGoods = List.unmodifiable(dangerousGoods);

  int get emptiesInGroups => groups.fold(0, (sum, g) => sum + g.empties.length);
  Iterable<ExportListMatch> get matchesWithDifferences =>
      matches.where((m) => m.differences.isNotEmpty);

  /// Todo cruza: cada lleno con su contenedor, cada vacío con su grupo y
  /// cada grupo con tantos vacíos como celdas.
  bool get clean =>
      fullsNotInPlan.isEmpty &&
      planNotInList.isEmpty &&
      emptiesWithoutGroup.isEmpty &&
      groups.every((g) => g.balanced) &&
      matchesWithDifferences.isEmpty;
}

/// T-73 · Propone las equivalencias y cruza el listado con el plan de carga.
/// Dart puro: no sabe de Excel ni de almacenes.
class ExportListCrossChecker {
  const ExportListCrossChecker._();

  static String? _planCode(EquivalenceKind kind, ContainerUnit c) => switch (kind) {
        EquivalenceKind.type => c.isoSizeType,
        EquivalenceKind.port => c.portOfDischarge,
        EquivalenceKind.line => c.operatorCode,
      };

  static String? _slotCode(EquivalenceKind kind, ReservedSlot s) => switch (kind) {
        EquivalenceKind.type => s.isoSizeType,
        EquivalenceKind.port => s.portOfDischarge,
        EquivalenceKind.line => s.operatorCode,
      };

  static String _listCode(EquivalenceKind kind, ExportListRow r) => switch (kind) {
        EquivalenceKind.type => r.listType,
        EquivalenceKind.port => r.listPod,
        EquivalenceKind.line => r.listLine,
      };

  /// Una fila por código del listado (tipo, POD y línea), en orden de
  /// aparición. Lo guardado en el dispositivo manda; si no hay, se deduce de
  /// los contenedores que están en los dos; si tampoco, se pide.
  static List<EquivalenceProposal> propose(
    ExportList list,
    VesselVoyage plan, {
    required String portOfCall,
    CodeEquivalences? saved,
  }) {
    final byId = {for (final c in plan.containers) c.containerId: c};
    final result = <EquivalenceProposal>[];
    for (final kind in EquivalenceKind.values) {
      final rows = <String, int>{};
      final observed = <String, Map<String, int>>{};
      for (final row in list.rows) {
        final code = _listCode(kind, row);
        rows[code] = (rows[code] ?? 0) + 1;
        final container = byId[row.containerId];
        final planCode = container == null ? null : _planCode(kind, container);
        final seen = observed.putIfAbsent(code, () => {});
        if (planCode != null) seen[planCode] = (seen[planCode] ?? 0) + 1;
      }
      final proposals = <EquivalenceProposal>[];
      for (final code in rows.keys) {
        final seen = observed[code]!;
        final stored = saved?.lookup(kind, code);
        final sorted = seen.keys.toList()..sort((a, b) => seen[b]!.compareTo(seen[a]!));
        proposals.add(EquivalenceProposal(
          kind: kind,
          listCode: code,
          planCode: stored ?? (seen.length == 1 ? seen.keys.single : null),
          origin: stored != null
              ? EquivalenceOrigin.saved
              : seen.length == 1
                  ? EquivalenceOrigin.inferred
                  : EquivalenceOrigin.pending,
          rows: rows[code]!,
          observed: seen,
          candidates: sorted,
        ));
      }
      // Sin respaldo, se sugieren los códigos que el plan carga en la escala
      // y que ninguna otra equivalencia de este tipo explica todavía.
      final claimed = {for (final p in proposals) if (p.planCode != null) p.planCode!};
      final loadCodes = <String>{
        for (final c in plan.containers)
          if (c.portOfLoading == portOfCall && _planCode(kind, c) != null) _planCode(kind, c)!,
        for (final s in plan.reservedSlots)
          if (s.portOfLoading == portOfCall && _slotCode(kind, s) != null) _slotCode(kind, s)!,
      }.where((code) => !claimed.contains(code)).toList()
        ..sort();
      for (final p in proposals) {
        result.add(p.needsUser && p.candidates.isEmpty
            ? EquivalenceProposal(
                kind: p.kind,
                listCode: p.listCode,
                planCode: null,
                origin: EquivalenceOrigin.pending,
                rows: p.rows,
                candidates: loadCodes,
              )
            : p);
      }
    }
    return result;
  }

  /// Tabla resultante de unas propuestas resueltas. Las identidades deducidas
  /// no se guardan: se vuelven a deducir cada vez.
  static CodeEquivalences tableOf(Iterable<EquivalenceProposal> proposals) {
    var table = CodeEquivalences.empty;
    for (final p in proposals) {
      if (p.planCode == null) continue;
      if (p.origin == EquivalenceOrigin.inferred && p.isIdentity) continue;
      table = table.put(p.kind, p.listCode, p.planCode!);
    }
    return table;
  }

  /// Cruza un listado ya traducido con el plan de carga de [portOfCall].
  static ExportListCrossCheck crossCheck(
      ExportList normalized, VesselVoyage plan, String portOfCall) {
    final byId = {for (final c in plan.containers) c.containerId: c};
    final listed = {for (final r in normalized.rows) r.containerId};

    final groups = <String, EmptyGroup>{};
    String key(String? type, String? pod, String? line) => '$type|$pod|$line';
    EmptyGroup groupFor(String type, String pod, String line) =>
        groups[key(type, pod, line)] ?? EmptyGroup(type: type, pod: pod, line: line);
    for (final slot in plan.reservedSlots) {
      if (slot.portOfLoading != portOfCall) continue;
      final g = groupFor(slot.isoSizeType ?? '?', slot.portOfDischarge ?? '?', slot.operatorCode ?? '?');
      groups[key(g.type, g.pod, g.line)] = EmptyGroup(
          type: g.type, pod: g.pod, line: g.line,
          reservedSlots: [...g.reservedSlots, slot], numberedEmpties: g.numberedEmpties);
    }
    for (final c in plan.containers) {
      if (c.portOfLoading != portOfCall || c.status != ContainerStatus.empty) continue;
      final g = groupFor(c.isoSizeType ?? '?', c.portOfDischarge ?? '?', c.operatorCode ?? '?');
      groups[key(g.type, g.pod, g.line)] = EmptyGroup(
          type: g.type, pod: g.pod, line: g.line,
          reservedSlots: g.reservedSlots, numberedEmpties: [...g.numberedEmpties, c]);
    }

    final matches = <ExportListMatch>[];
    final fullsNotInPlan = <ExportListRow>[];
    final emptiesByGroup = <String, List<ExportListRow>>{};
    final withoutGroup = <ExportListRow>[];
    final notices = <DangerousGoodsNotice>[];
    var weightDifferences = 0;
    var weightDifferenceKg = 0.0;

    for (final row in normalized.rows) {
      final container = byId[row.containerId];
      if (row.isEmpty) {
        final k = key(row.type, row.pod, row.line);
        if (groups.containsKey(k)) {
          emptiesByGroup.putIfAbsent(k, () => []).add(row);
        } else {
          withoutGroup.add(row);
        }
        if (container != null) _notice(row, container, notices);
        continue;
      }
      if (container == null) {
        fullsNotInPlan.add(row);
        continue;
      }
      final differences = <String>[
        if (container.portOfLoading != portOfCall)
          'el plan no lo carga en $portOfCall (${container.portOfLoading ?? 'sin puerto de carga'})',
        if (container.status == ContainerStatus.empty) 'el plan lo trae vacío',
        if (container.isoSizeType != row.type) 'tipo ${row.type} en el listado, ${container.isoSizeType} en el plan',
        if (container.portOfDischarge != row.pod) 'descarga ${row.pod} en el listado, ${container.portOfDischarge} en el plan',
        if (container.operatorCode != row.line) 'línea ${row.line} en el listado, ${container.operatorCode} en el plan',
      ];
      matches.add(ExportListMatch(row, container, differences));
      final planWeight = container.effectiveWeight;
      if (planWeight != null && row.vgmKg != null && (planWeight - row.vgmKg!).abs() >= 0.005) {
        weightDifferences++;
        weightDifferenceKg += planWeight - row.vgmKg!;
      }
      _notice(row, container, notices);
    }

    final finalGroups = [
      for (final entry in groups.entries)
        EmptyGroup(
          type: entry.value.type,
          pod: entry.value.pod,
          line: entry.value.line,
          reservedSlots: entry.value.reservedSlots,
          numberedEmpties: entry.value.numberedEmpties,
          empties: emptiesByGroup[entry.key] ?? const [],
        ),
    ]..sort((a, b) {
        final cells = b.planCells.compareTo(a.planCells);
        return cells != 0 ? cells : '${a.type}${a.pod}${a.line}'.compareTo('${b.type}${b.pod}${b.line}');
      });

    return ExportListCrossCheck(
      portOfCall: portOfCall,
      matches: matches,
      fullsNotInPlan: fullsNotInPlan,
      planNotInList: plan.containers
          .where((c) => c.portOfLoading == portOfCall && !listed.contains(c.containerId)),
      groups: finalGroups,
      emptiesWithoutGroup: withoutGroup,
      dangerousGoods: notices,
      weightDifferences: weightDifferences,
      weightDifferenceKg: weightDifferenceKg,
    );
  }

  /// Compara clase y números ONU del listado con los `DGS` del plan.
  static void _notice(ExportListRow row, ContainerUnit container, List<DangerousGoodsNotice> out) {
    final declarations = container.dangerousGoods ?? const [];
    final planNumbers = <String>{
      for (final d in declarations)
        if (d.unNumber != null) d.unNumber!,
      if (declarations.isEmpty && container.unNumber != null) container.unNumber!,
    };
    final planClasses = <String>{
      for (final d in declarations)
        if (d.hazardClass != null) d.hazardClass!,
      if (declarations.isEmpty && container.imdgClass != null) container.imdgClass!,
    };
    if (!row.isDangerous && planNumbers.isEmpty && planClasses.isEmpty) return;
    final who = 'OR ${row.order} · ${row.containerId}';
    if (!row.isDangerous) {
      out.add(DangerousGoodsNotice(row,
          '$who: el plan trae peligrosas (${_describe(planClasses, planNumbers)}) y el listado no las declara.'));
      return;
    }
    if (planNumbers.isEmpty && planClasses.isEmpty) {
      out.add(DangerousGoodsNotice(row,
          '$who: el listado declara ${_describe({if (row.imdgClass != null) row.imdgClass!}, row.unNumbers)} y el plan no trae peligrosas.'));
      return;
    }
    final problems = <String>[
      for (final n in row.unNumbers)
        if (!planNumbers.contains(n)) 'el plan no trae UN $n',
      for (final n in planNumbers)
        if (!row.unNumbers.contains(n)) 'el listado no declara UN $n',
      if (row.imdgClass != null && planClasses.isNotEmpty && !planClasses.contains(row.imdgClass))
        'clase ${row.imdgClass} en el listado, ${planClasses.join(' y ')} en el plan',
    ];
    if (problems.isEmpty) return;
    out.add(DangerousGoodsNotice(row,
        '$who: el listado declara ${_describe({if (row.imdgClass != null) row.imdgClass!}, row.unNumbers)}; ${problems.join('; ')}.'));
  }

  static String _describe(Set<String> classes, Iterable<String> numbers) {
    final parts = <String>[
      if (classes.isNotEmpty) 'clase ${classes.join(' y ')}',
      if (numbers.isNotEmpty) 'UN ${_joinY(numbers.toList())}',
    ];
    return parts.join(' y ');
  }

  static String _joinY(List<String> items) => items.length <= 1
      ? items.join()
      : '${items.sublist(0, items.length - 1).join(', ')} y ${items.last}';
}
