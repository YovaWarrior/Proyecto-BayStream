import 'package:equatable/equatable.dart';

import '../entities/container_unit.dart';
import '../entities/export_list.dart';
import '../entities/operation.dart';
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

  /// T-147 (10.151, regla 5) · Ningún contenedor la respalda, pero el plan
  /// carga en la escala ese mismo código: se propone como identidad y la
  /// pantalla dice de dónde sale. No se guarda en el dispositivo.
  samePlanCode,

  /// T-147, entrega 2 (P3) · Es la de la revisión anterior del listado de
  /// esta misma operación: viaja dentro del listado guardado, así que es la
  /// misma en todos los equipos.
  previous,
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

  /// T-147, entrega 2 (P4) · «También llena»: los otros códigos del plan que
  /// este tipo del listado llena, además de [planCode]. Solo en los tipos.
  final List<String> also;

  /// T-147, entrega 2 (P3) · Lo que este dispositivo tenía guardado para el
  /// código y no se usó, porque el plan dice otra cosa.
  final String? discarded;

  EquivalenceProposal({
    required this.kind,
    required this.listCode,
    required this.planCode,
    required this.origin,
    required this.rows,
    Map<String, int> observed = const {},
    Iterable<String> candidates = const [],
    Iterable<String> also = const [],
    this.discarded,
  })  : observed = Map.unmodifiable(observed),
        candidates = List.unmodifiable(candidates),
        also = List.unmodifiable(also);

  /// Los códigos del plan que este código del listado llena: el principal y
  /// los de «también llena».
  List<String> get planCodes => [if (planCode != null) planCode!, ...also];

  bool get needsUser => planCode == null;
  bool get isIdentity => planCode == listCode;

  /// Contenedores que respaldan el código elegido.
  int get evidence => planCode == null ? 0 : observed[planCode] ?? 0;

  /// Lo guardado o elegido contradice lo que dicen los contenedores.
  bool get contradicted =>
      planCode != null && observed.isNotEmpty && !observed.containsKey(planCode);

  /// El lápiz: la oficina elige [code] como el código del plan de este
  /// código del listado.
  ///
  /// T-147, entrega 2, parte 2b (O-147-10) · Al cambiar el principal de un
  /// tipo, el que deja de serlo se queda como «también llena» si el plan lo
  /// respalda (está en [observed]): sus celdas siguen siendo de este tipo y
  /// el cruce sigue cuadrando. Si el plan no lo respalda, se pierde, como
  /// hasta la 1.0.3 de la parte 2a, y sus celdas vuelven a la tarjeta de las
  /// que nadie llena. Con [keepFormer] en falso tampoco se queda: es el caso
  /// en que otro tipo del listado ya lo tiene de principal, y guardarlo aquí
  /// sería reclamarlo dos veces («un código del plan, un solo tipo»).
  EquivalenceProposal choose(String code, {bool keepFormer = true}) {
    final former = planCode;
    final keeps = keepFormer &&
        kind == EquivalenceKind.type &&
        former != null &&
        former != code &&
        observed.containsKey(former);
    return EquivalenceProposal(
      kind: kind,
      listCode: listCode,
      planCode: code,
      origin: EquivalenceOrigin.chosen,
      rows: rows,
      observed: observed,
      candidates: candidates,
      also: [
        if (keeps) former,
        ...also.where((c) => c != code && c != former),
      ],
      discarded: discarded,
    );
  }

  /// La misma propuesta con otros códigos de «también llena».
  EquivalenceProposal withAlso(Iterable<String> codes) => EquivalenceProposal(
        kind: kind,
        listCode: listCode,
        planCode: planCode,
        origin: origin,
        rows: rows,
        observed: observed,
        candidates: candidates,
        also: {
          for (final c in codes)
            if (c != planCode) c
        },
        discarded: discarded,
      );

  @override
  List<Object?> get props =>
      [kind, listCode, planCode, origin, rows, observed, candidates, also, discarded];
}

/// T-147, entrega 2 (P4) · Un código ISO que el plan reserva en la escala y
/// que ningún tipo del listado llena: sus celdas piden motivo al cargar, salvo
/// que la oficina diga qué tipo las llena.
class OrphanTypeCode extends Equatable {
  final String code;

  /// Celdas reservadas del plan con ese código, en la escala.
  final int cells;

  /// El tipo del listado que se sugiere, y su código principal: el único
  /// grupo con un código que empieza con los mismos tres caracteres. Nulos si
  /// no hay ninguno o hay más de uno.
  final String? suggestedListCode;
  final String? suggestedPlanCode;

  const OrphanTypeCode(this.code, this.cells,
      {this.suggestedListCode, this.suggestedPlanCode});

  @override
  List<Object?> get props => [code, cells, suggestedListCode, suggestedPlanCode];
}

/// T-147, entrega 2 (10.160, cambio 4) · Un código del plan que dos tipos del
/// listado, con códigos principales distintos, dicen llenar. Sus celdas
/// caerían en dos grupos: la importación no sigue hasta corregirlo.
class TypeFamilyConflict extends Equatable {
  final String code;

  /// Los tipos del listado que lo declaran, cada uno con su código principal.
  final List<({String listCode, String planCode})> claimants;

  TypeFamilyConflict(
      this.code, Iterable<({String listCode, String planCode})> claimants)
      : claimants = List.unmodifiable(claimants);

  /// «45G0 lo declaran dos tipos: 40HC (45G1) y 40XX (42G1). …»
  String get message {
    final names = [
      for (final c in claimants)
        c.listCode == c.planCode ? c.listCode : '${c.listCode} (${c.planCode})'
    ];
    final joined = names.length <= 1
        ? names.join()
        : '${names.sublist(0, names.length - 1).join(', ')} y ${names.last}';
    return '$code lo declaran ${names.length == 2 ? 'dos' : names.length} tipos: '
        '$joined. Un código del plan lo llena un solo tipo: corrige uno con el '
        'lápiz o quita el «también llena» que sobra.';
  }

  @override
  List<Object?> get props => [code, claimants];
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

  /// T-147, entrega 2 (P4) · Las celdas del grupo por el código ISO que el
  /// plan les da: con «también llena», un grupo junta varios. Primero el
  /// principal; después, de más a menos.
  Map<String, int> get cellsByCode {
    final counts = <String, int>{};
    for (final code in [
      for (final s in reservedSlots) s.isoSizeType ?? '?',
      for (final c in numberedEmpties) c.isoSizeType ?? '?',
    ]) {
      counts[code] = (counts[code] ?? 0) + 1;
    }
    final sorted = counts.entries.toList()
      ..sort((a, b) {
        if (a.key == b.key) return 0;
        if (a.key == type) return -1;
        if (b.key == type) return 1;
        final byCount = b.value.compareTo(a.value);
        return byCount != 0 ? byCount : a.key.compareTo(b.key);
      });
    return Map.fromEntries(sorted);
  }

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

  /// T-147, entrega 2 (P1) · Las filas que el listado cancela: no entran en
  /// ninguna de las cuentas de arriba.
  final List<ExportListRow> cancelled;

  /// De esas, las que el plan todavía carga en la escala, con su contenedor:
  /// la oficina cancela su embarque o pide el plan corregido.
  final List<ExportListMatch> cancelledInPlan;

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
    Iterable<ExportListRow> cancelled = const [],
    Iterable<ExportListMatch> cancelledInPlan = const [],
  })  : matches = List.unmodifiable(matches),
        fullsNotInPlan = List.unmodifiable(fullsNotInPlan),
        planNotInList = List.unmodifiable(planNotInList),
        groups = List.unmodifiable(groups),
        emptiesWithoutGroup = List.unmodifiable(emptiesWithoutGroup),
        dangerousGoods = List.unmodifiable(dangerousGoods),
        cancelled = List.unmodifiable(cancelled),
        cancelledInPlan = List.unmodifiable(cancelledInPlan);

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
      matchesWithDifferences.isEmpty &&
      cancelledInPlan.isEmpty;
}

/// T-127 (10.78) · Lo que un listado nuevo cambia en una operación que ya
/// tiene movimientos: el cruce lo dice con números antes de confirmar la
/// importación. Los movimientos no se pierden ni cambian; lo que cambia es lo
/// que el listado les da: los OR, los pesos exactos y los grupos de los vacíos.
class ExportListRevisionImpact extends Equatable {
  /// Contenedores ya cargados (llenos por su número y vacíos asignados a una
  /// reserva) que el listado nuevo no trae: se quedan sin OR ni fila.
  final List<String> loadedNotListed;

  /// Vacíos asignados cuya fila cambia de grupo (tipo, puerto o línea) frente
  /// al listado anterior o, sin él, frente a su reserva: pasan a verse como
  /// «vacío de otro grupo».
  final List<String> emptiesRegrouped;

  /// T-147, entrega 2 (P1) · Contenedores ya cargados que el listado nuevo
  /// cancela: la carga no se toca, y queda como conflicto para la oficina.
  final List<String> loadedNowCancelled;

  ExportListRevisionImpact({
    Iterable<String> loadedNotListed = const [],
    Iterable<String> emptiesRegrouped = const [],
    Iterable<String> loadedNowCancelled = const [],
  })  : loadedNotListed = List.unmodifiable(loadedNotListed),
        emptiesRegrouped = List.unmodifiable(emptiesRegrouped),
        loadedNowCancelled = List.unmodifiable(loadedNowCancelled);

  bool get isEmpty =>
      loadedNotListed.isEmpty &&
      emptiesRegrouped.isEmpty &&
      loadedNowCancelled.isEmpty;

  @override
  List<Object?> get props =>
      [loadedNotListed, emptiesRegrouped, loadedNowCancelled];
}

/// T-73 · Propone las equivalencias y cruza el listado con el plan de carga.
/// Dart puro: no sabe de Excel ni de almacenes.
class ExportListCrossChecker {
  const ExportListCrossChecker._();

  /// T-127 · Compara lo ya operado ([state], derivado con el listado
  /// [previous], o sin listado) con el listado [next] que se va a importar.
  static ExportListRevisionImpact revisionImpact(
      OperationState state, ExportList? previous, ExportList next) {
    final missing = <String>[];
    final regrouped = <String>[];
    final cancelled = <String>[];
    for (final item in state.items.values) {
      if (item.state != ItemState.moved || item.position == null) continue;
      final String container;
      if (item.kind == PlanItemKind.reservedSlot) {
        final assigned = item.assignedContainer;
        if (assigned == null) continue;
        container = assigned;
      } else if (item.role == PlanRole.load && item.key.startsWith('C:')) {
        container = item.key.substring(2);
      } else {
        continue;
      }
      final row = next.byContainer(container);
      if (row == null) {
        missing.add(container);
        continue;
      }
      if (row.cancelled) cancelled.add(container);
      if (item.kind != PlanItemKind.reservedSlot) continue;
      final slot = state.effectivePlan?.loading[item.key]?.reservedSlot;
      final before = previous?.byContainer(container)?.group ??
          (slot == null
              ? null
              : (
                  type: slot.isoSizeType ?? '?',
                  pod: slot.portOfDischarge ?? '?',
                  line: slot.operatorCode ?? '?'
                ));
      // T-147, entrega 2 (P4): el grupo se compara con lo que el listado
      // nuevo declara en «también llena».
      if (before != null &&
          (next.groupType(before.type) != next.groupType(row.type) ||
              before.pod != row.pod ||
              before.line != row.line)) {
        regrouped.add(container);
      }
    }
    return ExportListRevisionImpact(
      loadedNotListed: missing..sort(),
      emptiesRegrouped: regrouped..sort(),
      loadedNowCancelled: cancelled..sort(),
    );
  }

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
        // T-147: el puerto que se cruza es el POT si la fila lo trae.
        EquivalenceKind.port => r.listCrossPort,
        EquivalenceKind.line => r.listLine,
      };

  /// Una fila por código del listado (tipo, puerto y línea), en orden de
  /// aparición, contando solo las filas que se cargan (T-147, entrega 2: una
  /// fila cancelada no pide equivalencia).
  ///
  /// T-147, entrega 2 (P3; hallazgo 3 de la 10.85) · Quién manda, en orden:
  ///
  /// 1. **El plan.** Los contenedores que están en el listado y en el plan
  ///    dan un solo código. En un tipo, si dan varios y uno es el más
  ///    repetido, ese es el principal y los demás van a «también llena» (P4).
  /// 2. **La revisión anterior** del listado de esta operación ([previous]).
  /// 3. **El dispositivo** ([saved]), solo tipos y líneas.
  /// 4. La identidad, si el plan carga en la escala ese mismo código (T-147).
  /// 5. Si no, se pide.
  ///
  /// Lo de 2 y 3 solo vale si el plan no lo contradice: el plan carga ese
  /// código en la escala y los contenedores no dan otro. Hasta la 1.0.2, lo
  /// guardado en el dispositivo mandaba sobre los contenedores, y una
  /// equivalencia elegida con el plan equivocado desviaba los listados
  /// siguientes. Los puertos del dispositivo ya no se leen: con el cruce por
  /// POT salen por identidad, y los que no, son de ese viaje.
  static List<EquivalenceProposal> propose(
    ExportList list,
    VesselVoyage plan, {
    required String portOfCall,
    CodeEquivalences? saved,
    ExportList? previous,
  }) {
    final byId = {for (final c in plan.containers) c.containerId: c};
    final result = <EquivalenceProposal>[];
    for (final kind in EquivalenceKind.values) {
      final rows = <String, int>{};
      final observed = <String, Map<String, int>>{};
      for (final row in list.loadRows) {
        final code = _listCode(kind, row);
        rows[code] = (rows[code] ?? 0) + 1;
        final container = byId[row.containerId];
        final planCode = container == null ? null : _planCode(kind, container);
        final seen = observed.putIfAbsent(code, () => {});
        if (planCode != null) seen[planCode] = (seen[planCode] ?? 0) + 1;
      }
      final planCodes = <String>{
        for (final c in plan.containers)
          if (c.portOfLoading == portOfCall && _planCode(kind, c) != null) _planCode(kind, c)!,
        for (final s in plan.reservedSlots)
          if (s.portOfLoading == portOfCall && _slotCode(kind, s) != null) _slotCode(kind, s)!,
      };
      final proposals = <EquivalenceProposal>[];
      for (final code in rows.keys) {
        final seen = observed[code]!;
        final sorted = seen.keys.toList()
          ..sort((a, b) {
            final byCount = seen[b]!.compareTo(seen[a]!);
            return byCount != 0 ? byCount : a.compareTo(b);
          });
        bool agrees(String stored) =>
            planCodes.contains(stored) &&
            (seen.isEmpty || seen.containsKey(stored));
        final before = previous?.equivalences.lookup(kind, code);
        final device =
            kind == EquivalenceKind.port ? null : saved?.lookup(kind, code);
        // P4: en un tipo, el respaldo repartido se propone solo si uno de los
        // códigos es el más repetido; con un empate se sigue preguntando.
        final split = kind == EquivalenceKind.type &&
            seen.length > 1 &&
            seen[sorted[0]]! > seen[sorted[1]]!;
        final String? planCode;
        final EquivalenceOrigin origin;
        var also = const <String>[];
        if (seen.length == 1) {
          planCode = seen.keys.single;
          origin = EquivalenceOrigin.inferred;
        } else if (split) {
          planCode = sorted.first;
          also = sorted.sublist(1);
          origin = EquivalenceOrigin.inferred;
        } else if (before != null && agrees(before)) {
          planCode = before;
          origin = EquivalenceOrigin.previous;
        } else if (device != null && agrees(device)) {
          planCode = device;
          origin = EquivalenceOrigin.saved;
        } else {
          planCode = null;
          origin = EquivalenceOrigin.pending;
        }
        // Lo que la oficina ya declaró para este tipo en la revisión anterior
        // sigue valiendo, si el plan todavía carga esos códigos.
        if (kind == EquivalenceKind.type && planCode != null && previous != null) {
          also = [
            ...also,
            for (final entry in previous.typeFamilies.entries)
              if (entry.value == planCode &&
                  entry.key != planCode &&
                  planCodes.contains(entry.key) &&
                  !also.contains(entry.key))
                entry.key,
          ];
        }
        proposals.add(EquivalenceProposal(
          kind: kind,
          listCode: code,
          planCode: planCode,
          origin: origin,
          rows: rows[code]!,
          observed: seen,
          candidates: sorted,
          also: also,
          discarded: device != null && device != planCode ? device : null,
        ));
      }
      // T-147 (regla 5): sin ningún contenedor que lo respalde, un código que
      // el plan carga en la escala con ese mismo nombre se propone como
      // identidad. Con respaldo manda el respaldo.
      for (var i = 0; i < proposals.length; i++) {
        final p = proposals[i];
        if (p.needsUser && p.observed.isEmpty && planCodes.contains(p.listCode)) {
          proposals[i] = EquivalenceProposal(
            kind: p.kind,
            listCode: p.listCode,
            planCode: p.listCode,
            origin: EquivalenceOrigin.samePlanCode,
            rows: p.rows,
            discarded: p.discarded == p.listCode ? null : p.discarded,
          );
        }
      }
      // Sin respaldo, se sugieren los códigos que el plan carga en la escala
      // y que ninguna otra equivalencia de este tipo explica todavía.
      final claimed = {for (final p in proposals) ...p.planCodes};
      final loadCodes = planCodes.where((code) => !claimed.contains(code)).toList()
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
                discarded: p.discarded,
              )
            : p);
      }
    }
    return result;
  }

  /// Tabla resultante de unas propuestas resueltas: va dentro del listado
  /// guardado. Las identidades deducidas o propuestas (T-147) no se guardan:
  /// se vuelven a deducir cada vez.
  static CodeEquivalences tableOf(Iterable<EquivalenceProposal> proposals) {
    var table = CodeEquivalences.empty;
    for (final p in proposals) {
      if (p.planCode == null) continue;
      if (p.origin == EquivalenceOrigin.inferred && p.isIdentity) continue;
      if (p.origin == EquivalenceOrigin.samePlanCode) continue;
      table = table.put(p.kind, p.listCode, p.planCode!);
    }
    return table;
  }

  /// T-147, entrega 2 (P3) · Lo que una importación confirmada deja en el
  /// dispositivo: sus tipos y sus líneas, nunca sus puertos.
  static CodeEquivalences deviceTableOf(Iterable<EquivalenceProposal> proposals) =>
      tableOf(proposals.where((p) => p.kind != EquivalenceKind.port));

  /// T-147, entrega 2 (P4) · «También llena», como va en el listado: cada
  /// código de más, con el principal de su tipo.
  static Map<String, String> familiesOf(Iterable<EquivalenceProposal> proposals) => {
        for (final p in proposals)
          if (p.kind == EquivalenceKind.type && p.planCode != null)
            for (final code in p.also) code: p.planCode!,
      };

  /// T-147, entrega 2 (10.160, cambio 4) · Los códigos del plan que dos tipos
  /// del listado declaran con principales distintos. Dos tipos con el mismo
  /// principal son un solo grupo, y no chocan.
  static List<TypeFamilyConflict> familyConflicts(
      Iterable<EquivalenceProposal> proposals) {
    final claims = <String, List<({String listCode, String planCode})>>{};
    for (final p in proposals) {
      if (p.kind != EquivalenceKind.type || p.planCode == null) continue;
      for (final code in p.planCodes) {
        claims
            .putIfAbsent(code, () => [])
            .add((listCode: p.listCode, planCode: p.planCode!));
      }
    }
    return [
      for (final entry in claims.entries)
        if ({for (final c in entry.value) c.planCode}.length > 1)
          TypeFamilyConflict(entry.key, entry.value)
    ];
  }

  /// T-147, entrega 2 (P4) · Los códigos ISO de las celdas reservadas de la
  /// escala que ningún tipo del listado llena, con su sugerencia: el grupo
  /// que ya llena un código con los mismos tres primeros caracteres. Es una
  /// sugerencia, no una regla: la decide la oficina.
  ///
  /// T-147, entrega 2, parte 2b (O-147-7) · Mientras quede un tipo del
  /// listado por elegir no hay nada que decir: sus celdas todavía no tienen
  /// dueño porque nadie lo eligió, no porque no lo tengan. Con el caso A09 la
  /// tarjeta decía 95 celdas en 12 códigos hasta elegir los seis tipos, y
  /// entonces las 11 de verdad.
  static List<OrphanTypeCode> orphanTypeCodes(
      Iterable<EquivalenceProposal> proposals, VesselVoyage plan,
      {required String portOfCall}) {
    if (proposals.any((p) => p.kind == EquivalenceKind.type && p.needsUser)) {
      return const [];
    }
    final types = [
      for (final p in proposals)
        if (p.kind == EquivalenceKind.type && p.planCode != null) p
    ];
    final claimed = {for (final p in types) ...p.planCodes};
    final cells = <String, int>{};
    for (final slot in plan.reservedSlots) {
      final code = slot.isoSizeType;
      if (slot.portOfLoading != portOfCall || code == null) continue;
      if (claimed.contains(code)) continue;
      cells[code] = (cells[code] ?? 0) + 1;
    }
    String prefix(String code) => code.length < 3 ? code : code.substring(0, 3);
    return [
      for (final code in cells.keys.toList()..sort())
        () {
          final near = [
            for (final p in types)
              if (p.planCodes.any((c) => prefix(c) == prefix(code))) p
          ];
          final one = {for (final p in near) p.planCode}.length == 1;
          return OrphanTypeCode(code, cells[code]!,
              suggestedListCode: one ? near.first.listCode : null,
              suggestedPlanCode: one ? near.first.planCode : null);
        }()
    ];
  }

  /// Cruza un listado ya traducido con el plan de carga de [portOfCall].
  ///
  /// T-147, entrega 2 · Las filas canceladas no entran en ninguna cuenta: van
  /// aparte (P1). El grupo de un código del plan es el de su tipo principal,
  /// según «también llena» (P4): una celda 45G0 cuenta con los 45G1 si la
  /// oficina declaró que 40HC llena los dos.
  static ExportListCrossCheck crossCheck(
      ExportList normalized, VesselVoyage plan, String portOfCall) {
    final byId = {for (final c in plan.containers) c.containerId: c};
    final listed = {for (final r in normalized.rows) r.containerId};
    String? family(String? type) => normalized.groupType(type);

    final groups = <String, EmptyGroup>{};
    String key(String? type, String? pod, String? line) => '$type|$pod|$line';
    EmptyGroup groupFor(String type, String pod, String line) =>
        groups[key(type, pod, line)] ?? EmptyGroup(type: type, pod: pod, line: line);
    for (final slot in plan.reservedSlots) {
      if (slot.portOfLoading != portOfCall) continue;
      final g = groupFor(family(slot.isoSizeType) ?? '?', slot.portOfDischarge ?? '?', slot.operatorCode ?? '?');
      groups[key(g.type, g.pod, g.line)] = EmptyGroup(
          type: g.type, pod: g.pod, line: g.line,
          reservedSlots: [...g.reservedSlots, slot], numberedEmpties: g.numberedEmpties);
    }
    for (final c in plan.containers) {
      if (c.portOfLoading != portOfCall || c.status != ContainerStatus.empty) continue;
      final g = groupFor(family(c.isoSizeType) ?? '?', c.portOfDischarge ?? '?', c.operatorCode ?? '?');
      groups[key(g.type, g.pod, g.line)] = EmptyGroup(
          type: g.type, pod: g.pod, line: g.line,
          reservedSlots: g.reservedSlots, numberedEmpties: [...g.numberedEmpties, c]);
    }

    final matches = <ExportListMatch>[];
    final fullsNotInPlan = <ExportListRow>[];
    final emptiesByGroup = <String, List<ExportListRow>>{};
    final withoutGroup = <ExportListRow>[];
    final notices = <DangerousGoodsNotice>[];
    final cancelled = <ExportListRow>[];
    final cancelledInPlan = <ExportListMatch>[];
    var weightDifferences = 0;
    var weightDifferenceKg = 0.0;

    for (final row in normalized.rows) {
      final container = byId[row.containerId];
      if (row.cancelled) {
        cancelled.add(row);
        if (container != null && container.portOfLoading == portOfCall) {
          cancelledInPlan.add(ExportListMatch(row, container, const []));
        }
        continue;
      }
      if (row.isEmpty) {
        final k = key(family(row.type), row.pod, row.line);
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
        if (family(container.isoSizeType) != family(row.type)) 'tipo ${row.type} en el listado, ${container.isoSizeType} en el plan',
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
      cancelled: cancelled,
      cancelledInPlan: cancelledInPlan,
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
