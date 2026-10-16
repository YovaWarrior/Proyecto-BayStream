import '../entities/container_unit.dart';
import '../entities/hatch_covers.dart';
import '../entities/vessel_geometry.dart';
import '../entities/vessel_voyage.dart';

/// T-95 · RF-028: el orden de descarga sugerido para un puerto, con las
/// sobreestibas por columna y por tapa, según las definiciones de Carlos (10.59).
///
/// Es un cálculo sobre el archivo leído: no registra, no sigue el avance en
/// vivo (eso es T-75) ni reparte grúas. Las tapas vienen del perfil del buque
/// y, mientras ningún buque del corpus las declare, son PROVISIONALES (T-83).

/// La huella física de una bahía, sin calcular pares: una impar es ella misma
/// y una par ocupa sus dos impares vecinas. En ALFA la 044 va sobre la 043 y
/// la 045, y la 041 queda sola, sin ninguna fórmula.
Set<int> bayFootprint(int bay) => bay.isOdd ? {bay} : {bay - 1, bay + 1};

bool footprintsTouch(int a, int b) =>
    bayFootprint(a).intersection(bayFootprint(b)).isNotEmpty;

enum DischargeStepKind { discharge, restowOut, coverOff, coverOn, restowBack }

enum RestowReason { column, cover }

/// Una tapa física. Las copias de la misma tapa en bahías de la misma celda,
/// con las mismas filas, se unen en una sola.
class PhysicalHatchCover {
  final int number;
  final HatchCoverKind kind;
  final Set<int> rows;
  final Set<int> bays;
  PhysicalHatchCover(this.number, this.kind, Set<int> rows, Set<int> bays)
      : rows = Set.unmodifiable(rows),
        bays = Set.unmodifiable(bays);

  bool get crane => kind == HatchCoverKind.crane;
  Set<int> get footprint => {for (final b in bays) ...bayFootprint(b)};
  bool touches(int bay) => footprint.intersection(bayFootprint(bay)).isNotEmpty;
  int get firstBay => bays.reduce((a, b) => a < b ? a : b);

  /// Dónde se muestra: la par si la tapa tiene una, para que declararla solo
  /// en la par o copiarla a las impares se vea igual.
  int get bay {
    final even = bays.where((b) => b.isEven);
    return even.isEmpty ? firstBay : even.reduce((a, b) => a < b ? a : b);
  }
}

/// Un paso de la secuencia. La posición es el código ISO de siete dígitos; una
/// tapa lleva los tres dígitos de su bahía ([PhysicalHatchCover.bay]).
class DischargeStep {
  final int number;
  final DischargeStepKind kind;
  final String position;
  final ContainerUnit? container;
  final PhysicalHatchCover? cover;
  final RestowReason? reason;
  const DischargeStep(this.number, this.kind, this.position,
      {this.container, this.cover, this.reason});
}

/// La celda física: las bahías cuyas huellas se tocan, la par con sus impares.
class DischargeCell {
  final List<int> bays;
  final List<DischargeStep> steps;
  final int deckDischarges;
  final int holdDischarges;
  final int columnRestows;
  final int coverRestows;
  final int craneCovers;
  final int automaticCovers;
  DischargeCell({
    required List<int> bays,
    required List<DischargeStep> steps,
    required this.deckDischarges,
    required this.holdDischarges,
    required this.columnRestows,
    required this.coverRestows,
    required this.craneCovers,
    required this.automaticCovers,
  })  : bays = List.unmodifiable(bays),
        steps = List.unmodifiable(steps);

  int get discharges => deckDischarges + holdDischarges;
  int get restows => columnRestows + coverRestows;

  /// 10.59: la re-estiba a bordo cuenta 1; por muelle, 2. La tapa de grúa, 2.
  int get movesOnBoard => discharges + restows + 2 * craneCovers;
  int get movesByQuay => discharges + 2 * restows + 2 * craneCovers;
}

class DischargeSequence {
  final String port;

  /// En el orden sugerido: de más a menos movimientos por muelle y, con
  /// empate, de proa a popa (la bahía menor primero).
  final List<DischargeCell> cells;

  /// Contenedores de este puerto que el archivo no ubica: no entran en la
  /// secuencia y se cuentan aparte.
  final List<ContainerUnit> withoutPosition;

  /// Contenedores a bordo sin puerto de descarga: no bajan, así que pueden
  /// estorbar, y se cuentan aparte.
  final int withoutDischargePort;

  /// Descargas en bodega sin tapa declarada que la cubra. Aviso, sin tapa.
  final List<String> holdWithoutCover;

  /// Cubierta que no baja, junto a una tapa que se quita, en filas que
  /// ninguna tapa declara: no estorba y se cuenta aparte, sin suponer.
  final List<String> outsideCoverRows;

  /// Cuántas declaraciones repetidas se unieron en una tapa física.
  final int mergedCoverDeclarations;

  DischargeSequence._({
    required this.port,
    required List<DischargeCell> cells,
    required List<ContainerUnit> withoutPosition,
    required this.withoutDischargePort,
    required List<String> holdWithoutCover,
    required List<String> outsideCoverRows,
    required this.mergedCoverDeclarations,
  })  : cells = List.unmodifiable(cells),
        withoutPosition = List.unmodifiable(withoutPosition),
        holdWithoutCover = List.unmodifiable(holdWithoutCover),
        outsideCoverRows = List.unmodifiable(outsideCoverRows);

  int _sum(int Function(DischargeCell c) f) =>
      cells.fold(0, (total, c) => total + f(c));
  int get deckDischarges => _sum((c) => c.deckDischarges);
  int get holdDischarges => _sum((c) => c.holdDischarges);
  int get discharges => deckDischarges + holdDischarges;
  int get columnRestows => _sum((c) => c.columnRestows);
  int get coverRestows => _sum((c) => c.coverRestows);
  int get restows => columnRestows + coverRestows;
  int get craneCovers => _sum((c) => c.craneCovers);
  int get automaticCovers => _sum((c) => c.automaticCovers);
  int get movesOnBoard => _sum((c) => c.movesOnBoard);
  int get movesByQuay => _sum((c) => c.movesByQuay);

  /// Los puertos de descarga del archivo: la escala primero, después los
  /// demás del más frecuente al menos frecuente.
  static List<String> dischargePorts(VesselVoyage voyage) {
    final counts = <String, int>{};
    for (final c in voyage.containers) {
      final port = c.portOfDischarge;
      if (port == null || port.trim().isEmpty) continue;
      counts[port] = (counts[port] ?? 0) + 1;
    }
    final ports = counts.keys.toList()
      ..sort((a, b) {
        if (a == voyage.portOfCall) return -1;
        if (b == voyage.portOfCall) return 1;
        final byCount = counts[b]!.compareTo(counts[a]!);
        return byCount != 0 ? byCount : a.compareTo(b);
      });
    return ports;
  }

  factory DischargeSequence.build(VesselVoyage voyage, String port,
      {required VesselGeometry geometry,
      Map<int, HatchCoverDeclaration> hatchCovers = const {}}) {
    final placed = [
      for (final c in voyage.containers)
        if (c.stowagePosition != null) c,
    ];
    bool down(ContainerUnit c) => c.portOfDischarge == port;
    bool deck(ContainerUnit c) => geometry.isDeckTier(c.stowagePosition!.tier);
    final discharges = placed.where(down).toList();
    final staying = placed.where((c) => !down(c)).toList();

    // Por columna: lo que no baja y va más arriba en la misma pila (misma
    // fila, misma zona y huellas que se tocan).
    bool above(ContainerUnit upper, ContainerUnit lower) {
      final a = upper.stowagePosition!, b = lower.stowagePosition!;
      return a.row == b.row &&
          deck(upper) == deck(lower) &&
          footprintsTouch(a.bay, b.bay) &&
          a.tier > b.tier;
    }

    final column = <ContainerUnit>{
      for (final s in staying)
        if (discharges.any((d) => above(s, d))) s,
    };

    // Las tapas físicas: cada tapa declarada, unida con sus copias.
    final candidates = <PhysicalHatchCover>[];
    final openHolds = <int>{};
    for (final entry in hatchCovers.entries) {
      if (entry.value.kind == HatchCoverKind.openHold) {
        openHolds.add(entry.key);
        continue;
      }
      for (var i = 0; i < entry.value.covers.length; i++) {
        candidates.add(PhysicalHatchCover(
            i + 1, entry.value.kind, entry.value.covers[i], {entry.key}));
      }
    }
    final covers = _mergeCopies(candidates);

    // Por tapa: cada descarga en bodega quita la tapa que declara su fila, en
    // una bahía cuya huella toca la suya; la estorba la cubierta de esas filas.
    final toRemove = <PhysicalHatchCover>{};
    final holdWithoutCover = <String>[];
    for (final d in discharges.where((d) => !deck(d))) {
      final p = d.stowagePosition!;
      final over = covers.where((k) => k.rows.contains(p.row) && k.touches(p.bay));
      if (over.isNotEmpty) {
        toRemove.addAll(over);
      } else if (!openHolds.any((b) => footprintsTouch(b, p.bay))) {
        holdWithoutCover.add(p.toIsoCode());
      }
    }
    final onCover = <ContainerUnit, PhysicalHatchCover>{};
    final outside = <String>{};
    for (final k in _byNumber(toRemove)) {
      for (final s in staying.where(deck)) {
        final p = s.stowagePosition!;
        if (!k.touches(p.bay)) continue;
        if (k.rows.contains(p.row)) {
          if (!column.contains(s)) onCover.putIfAbsent(s, () => k);
        } else if (!column.contains(s) &&
            !covers.any((other) =>
                other.touches(p.bay) && other.rows.contains(p.row))) {
          outside.add(p.toIsoCode());
        }
      }
    }

    // Las celdas físicas: componentes de bahías cuyas huellas se tocan.
    final cellOf = _cells({
      for (final c in placed) c.stowagePosition!.bay,
      for (final k in covers) ...k.bays,
    });
    int rowRank(int row) {
      final i = geometry.orderedRows.indexOf(row);
      return i < 0 ? 1000 + row : i;
    }

    // Dentro de un nivel, por `orderedRows`; con la misma fila, la bahía menor.
    int rowThenBay(ContainerUnit a, ContainerUnit b) {
      final p = a.stowagePosition!, q = b.stowagePosition!;
      final byRow = rowRank(p.row).compareTo(rowRank(q.row));
      return byRow != 0 ? byRow : p.bay.compareTo(q.bay);
    }

    int topDown(ContainerUnit a, ContainerUnit b) {
      final byTier = b.stowagePosition!.tier.compareTo(a.stowagePosition!.tier);
      return byTier != 0 ? byTier : rowThenBay(a, b);
    }

    int bottomUp(ContainerUnit a, ContainerUnit b) {
      final byTier = a.stowagePosition!.tier.compareTo(b.stowagePosition!.tier);
      return byTier != 0 ? byTier : rowThenBay(a, b);
    }

    final cells = <DischargeCell>[];
    for (final bays in {...cellOf.values}) {
      bool inCell(ContainerUnit c) => bays.contains(c.stowagePosition!.bay);
      final down = discharges.where(inCell).toList();
      if (down.isEmpty) continue;
      final cellColumn = column.where(inCell).toList();
      final cellCovers = _byNumber(toRemove.where((k) => bays.containsAll(k.bays)));
      final steps = <DischargeStep>[];
      void add(DischargeStepKind kind, String position,
              {ContainerUnit? container,
              PhysicalHatchCover? cover,
              RestowReason? reason}) =>
          steps.add(DischargeStep(steps.length + 1, kind, position,
              container: container, cover: cover, reason: reason));
      void out(ContainerUnit c, {RestowReason? reason}) => add(
          reason == null ? DischargeStepKind.discharge : DischargeStepKind.restowOut,
          c.stowagePosition!.toIsoCode(),
          container: c,
          reason: reason);
      // Una tapa no tiene celda propia: su posición es su bahía.
      String coverPosition(PhysicalHatchCover k) =>
          k.bay.toString().padLeft(3, '0');

      // 1. La cubierta, de arriba abajo: cada re-estiba antes de lo de abajo.
      for (final c in [...down, ...cellColumn].where(deck).toList()..sort(topDown)) {
        out(c, reason: column.contains(c) ? RestowReason.column : null);
      }
      // 2. Lo que estorba sobre cada tapa, y después la tapa.
      final cellOnCover = <ContainerUnit>[];
      for (final k in cellCovers) {
        final mine = onCover.entries
            .where((e) => e.value == k)
            .map((e) => e.key)
            .toList()
          ..sort(topDown);
        for (final c in mine) {
          out(c, reason: RestowReason.cover);
        }
        cellOnCover.addAll(mine);
        add(DischargeStepKind.coverOff, coverPosition(k), cover: k);
      }
      // 3. La bodega, de arriba abajo.
      final holdColumn = cellColumn.where((c) => !deck(c)).toList();
      for (final c in [...down, ...holdColumn].where((c) => !deck(c)).toList()
        ..sort(topDown)) {
        out(c, reason: column.contains(c) ? RestowReason.column : null);
      }
      // 4. Las re-estibas de bodega vuelven antes de reponer la tapa (Carlos).
      for (final c in holdColumn..sort(bottomUp)) {
        add(DischargeStepKind.restowBack, c.stowagePosition!.toIsoCode(),
            container: c, reason: RestowReason.column);
      }
      // 5. Las tapas, en orden inverso.
      for (final k in cellCovers.reversed) {
        add(DischargeStepKind.coverOn, coverPosition(k), cover: k);
      }
      // 6. Las re-estibas de cubierta vuelven, de abajo arriba.
      final deckBack = [...cellColumn.where(deck), ...cellOnCover]..sort(bottomUp);
      for (final c in deckBack) {
        add(DischargeStepKind.restowBack, c.stowagePosition!.toIsoCode(),
            container: c,
            reason: column.contains(c) ? RestowReason.column : RestowReason.cover);
      }
      cells.add(DischargeCell(
        bays: bays.toList()..sort(),
        steps: steps,
        deckDischarges: down.where(deck).length,
        holdDischarges: down.where((c) => !deck(c)).length,
        columnRestows: cellColumn.length,
        coverRestows: cellOnCover.length,
        craneCovers: cellCovers.where((k) => k.crane).length,
        automaticCovers: cellCovers.where((k) => !k.crane).length,
      ));
    }
    cells.sort((a, b) {
      final byMoves = b.movesByQuay.compareTo(a.movesByQuay);
      return byMoves != 0 ? byMoves : a.bays.first.compareTo(b.bays.first);
    });
    return DischargeSequence._(
      port: port,
      cells: cells,
      withoutPosition: [
        for (final c in voyage.containers)
          if (c.stowagePosition == null && down(c)) c,
      ],
      withoutDischargePort: voyage.containers
          .where((c) => c.portOfDischarge == null || c.portOfDischarge!.trim().isEmpty)
          .length,
      holdWithoutCover: holdWithoutCover..sort(),
      outsideCoverRows: outside.toList()..sort(),
      mergedCoverDeclarations: candidates.length - covers.length,
    );
  }

  static List<PhysicalHatchCover> _byNumber(Iterable<PhysicalHatchCover> covers) =>
      covers.toList()
        ..sort((a, b) {
          final byNumber = a.number.compareTo(b.number);
          return byNumber != 0 ? byNumber : a.firstBay.compareTo(b.firstBay);
        });

  /// Une las declaraciones de la misma tapa: mismo tipo, mismas filas y
  /// bahías cuyas huellas se tocan, también de forma encadenada.
  static List<PhysicalHatchCover> _mergeCopies(List<PhysicalHatchCover> all) {
    final groups = <List<PhysicalHatchCover>>[];
    for (final candidate in all) {
      final joined = groups.where((g) => g.any((k) =>
          k.kind == candidate.kind &&
          k.rows.length == candidate.rows.length &&
          k.rows.containsAll(candidate.rows) &&
          footprintsTouch(k.firstBay, candidate.firstBay))).toList();
      final merged = [candidate, for (final g in joined) ...g];
      groups
        ..removeWhere(joined.contains)
        ..add(merged);
    }
    return [
      for (final g in groups)
        PhysicalHatchCover(
            g.map((k) => k.number).reduce((a, b) => a < b ? a : b),
            g.first.kind,
            g.first.rows,
            {for (final k in g) ...k.bays}),
    ];
  }

  /// Cada bahía con su celda: el componente de bahías cuyas huellas se tocan.
  static Map<int, Set<int>> _cells(Set<int> bays) {
    final cellOf = <int, Set<int>>{};
    for (final bay in bays.toList()..sort()) {
      final touching = {
        for (final entry in cellOf.entries)
          if (footprintsTouch(entry.key, bay)) entry.value,
      };
      final cell = <int>{bay, for (final t in touching) ...t};
      for (final member in cell) {
        cellOf[member] = cell;
      }
    }
    return cellOf;
  }
}
