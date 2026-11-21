import '../../../../core/utils/iso_coordinate_parser.dart';
import '../entities/entities.dart';
import 'discharge_progress.dart';
import 'load_check.dart';
import 'loading_plan_progress.dart';
import 'operation_state_deriver.dart';
import 'reference_bay.dart';

/// T-76: selección de carga y reservas sobre la misma bitácora de descarga.
class LoadingOperation {
  final String? operationId;
  final VesselVoyage loading;
  final OperationPlan plan;
  final OperationPlan _publishedPlan;
  final ExportList? list;
  final List<Movement> movements;
  final OperationState state;
  final LoadingPlanProgress progress;
  final DischargeProgress discharge;

  LoadingOperation._(
      this.operationId,
      this.loading,
      this.plan,
      this._publishedPlan,
      this.list,
      this.movements,
      this.state,
      this.progress,
      this.discharge);

  factory LoadingOperation.build({
    String? operationId,
    VesselVoyage? arrival,
    required VesselVoyage loading,
    ExportList? list,
    Iterable<Movement> movements = const [],
    Map<int, HatchCoverDeclaration> hatchCovers = const {},
  }) {
    final events = List<Movement>.unmodifiable(movements);
    final plan = OperationPlan.build(
        portOfCall: loading.portOfCall!,
        arrival: arrival,
        loading: loading,
        geometry: loading.geometry,
        hatchCovers: hatchCovers,
        list: list);
    final state = const OperationStateDeriver().derive(plan, events);
    final effective = state.effectivePlan!;
    // La fuente publicada permanece intacta. Esta proyección se reconstruye
    // también en otra bahía, con sus sombras de 40 pies y sus reservas.
    final projected = VesselVoyage.fromJson({
      ...loading.toJson(includeBays: false),
      'containers': [
        for (final c in loading.containers)
          (effective.loading['C:${c.containerId}']?.container ?? c).toJson()
      ],
      'reservedSlots': [
        for (final s in loading.reservedSlots)
          (effective.loading[s.key]?.reservedSlot ?? s).toJson()
      ],
    });
    return LoadingOperation._(
        operationId,
        projected,
        effective,
        plan,
        list,
        events,
        state,
        LoadingPlanProgress.build(projected, state, list: list),
        DischargeProgress.build(effective, state,
            operationId: operationId, movements: events));
  }

  PlanItem? numbered(ExportListRow row) {
    final item = plan.loading['C:${row.containerId}'];
    return item?.role == PlanRole.load ? item : null;
  }

  /// T-122 (H6, 10.56) · Si el vacío de la fila ya quedó asignado a una
  /// reserva: vive solo como `assignedContainer` del estado, no en el plan.
  bool assigned(ExportListRow row) => state.items.values.any((s) =>
      s.state == ItemState.moved && s.assignedContainer == row.containerId);

  /// T-122 (H4, 10.51) · Los **llenos** que el plan carga aquí y el listado no
  /// trae, como filas sin OR, por número de contenedor. Solo los que el plan
  /// declara llenos (corrección 2, 10.59): un vacío con número, o un
  /// contenedor sin estado, necesita su fila, que trae su tara y su tipo
  /// exactos.
  List<ExportListRow> get unlistedRows => [
        for (final item in plan.loading.values)
          if (item.role == PlanRole.load &&
              item.container != null &&
              item.container!.status == ContainerStatus.full &&
              list?.byContainer(item.container!.containerId) == null)
            ExportListRow.fromPlan(item.container!)
      ]..sort((a, b) => a.containerId.compareTo(b.containerId));

  /// Por qué un contenedor del plan no se carga sin su fila, o nulo si sí
  /// (es un lleno del plan). Para el aviso del muelle y del borrador.
  String? needsRow(String containerId) {
    final item = plan.loading['C:$containerId'];
    if (item?.role != PlanRole.load || item?.container == null) {
      return '$containerId no está en el plan de carga de ${plan.portOfCall}: '
          'revisa el número o importa el listado.';
    }
    return switch (item!.container!.status) {
      ContainerStatus.full => null,
      ContainerStatus.empty => 'El vacío $containerId espera el listado de la '
          'agencia: su fila trae la tara y el tipo exactos. Importa el listado '
          'para cargarlo.',
      _ => '$containerId no declara lleno ni vacío en el plan: espera el '
          'listado de la agencia. Importa el listado para cargarlo.',
    };
  }

  /// La fila sin OR de un contenedor del plan; nula si el listado lo trae o
  /// el plan no lo carga aquí.
  ExportListRow? unlistedRow(String containerId) {
    for (final row in unlistedRows) {
      if (row.containerId == containerId) return row;
    }
    return null;
  }

  /// OR exacto o sufijo del contenedor; nunca se elige una coincidencia ambigua.
  ///
  /// Entre los llenos salen las filas con número en el plan, los vacíos ya
  /// asignados a una reserva (H6) y, después, los contenedores del plan sin
  /// fila en el listado (H4). Los vacíos por asignar siguen saliendo solo
  /// del listado.
  List<ExportListRow> search(String query, {bool empties = false}) {
    final value = query.trim().toUpperCase();
    final order = int.tryParse(value.replaceFirst(RegExp(r'^OR\s*'), ''));
    final listed = (list?.rows ?? const <ExportListRow>[]).where((row) {
      if (empties
          ? !row.isEmpty
          : numbered(row) == null && !assigned(row)) {
        return false;
      }
      return value.isEmpty ||
          row.order == order ||
          row.containerId.endsWith(value);
    }).toList()
      ..sort((a, b) => a.order.compareTo(b.order));
    if (empties) return listed;
    return [
      ...listed,
      for (final row in unlistedRows)
        if (value.isEmpty || row.containerId.endsWith(value)) row,
    ];
  }

  /// La nueva corrección sustituirá toda la cadena. La vista previa retira
  /// esa cadena sin registrar movimientos ni restaurar un antecesor.
  ///
  /// T-147 · El estado de una corrección se deriva una vez: el diálogo
  /// «Corregir carga» lo pedía por cada vacío del listado.
  OperationState _before(Movement? correcting) {
    if (correcting == null) return state;
    if (_beforeId == correcting.id) return _beforeState!;
    final derived = _deriveBefore(correcting);
    _beforeId = correcting.id;
    _beforeState = derived;
    return derived;
  }

  String? _beforeId;
  OperationState? _beforeState;

  OperationState _deriveBefore(Movement correcting) {
    final byId = {for (final movement in movements) movement.id: movement};
    final replaced = <String>{};
    Movement? previous = correcting;
    while (previous != null && replaced.add(previous.id)) {
      previous = previous.type.canCorrect ? byId[previous.corrects] : null;
    }
    return const OperationStateDeriver().derive(_publishedPlan,
        movements.where((movement) => !replaced.contains(movement.id)));
  }

  bool available(ExportListRow row, {Movement? correcting}) {
    final before = _before(correcting);
    if (before['C:${row.containerId}']?.state == ItemState.cancelled) {
      return false;
    }
    return !_operated(before).contains(row.containerId);
  }

  /// Los contenedores ya movidos en [state]: los que subieron o bajaron por
  /// su número y los vacíos asignados a una reserva. T-147 · Una vez por
  /// estado; antes se recorrían todas las piezas por cada fila.
  Set<String> _operated(OperationState state) {
    if (identical(state, _operatedOf)) return _operatedSet!;
    final result = <String>{};
    for (final s in state.items.values) {
      if (s.state != ItemState.moved) continue;
      if (s.key.startsWith('C:')) result.add(s.key.substring(2));
      final assigned = s.assignedContainer;
      if (assigned != null) result.add(assigned);
    }
    _operatedOf = state;
    _operatedSet = result;
    return result;
  }

  OperationState? _operatedOf;
  Set<String>? _operatedSet;

  List<ReservedSlot> slots(ExportListRow row,
      {int? selectedBay, Movement? correcting}) {
    if (!row.isEmpty ||
        numbered(row) != null ||
        !available(row, correcting: correcting)) {
      return const [];
    }
    final before = _before(correcting);
    final occupied = before.occupancy;
    final result = plan.loading.values
        .where((item) {
          final slot = item.reservedSlot;
          return item.role == PlanRole.load &&
              slot != null &&
              slot.isoSizeType == row.type &&
              slot.portOfDischarge == row.pod &&
              slot.operatorCode == row.line &&
              before[item.key]?.state == ItemState.planned &&
              !occupied.containsKey(item.plannedPosition);
        })
        .map((item) => item.reservedSlot!)
        .toList();
    result.sort((a, b) {
      final selectedGroup =
          selectedBay == null ? null : displayBay(selectedBay);
      final aHere = displayBay(a.stowagePosition.bay) == selectedGroup;
      final bHere = displayBay(b.stowagePosition.bay) == selectedGroup;
      if (aHere != bHere) return aHere ? -1 : 1;
      return a.stowagePosition
          .toIsoCode()
          .compareTo(b.stowagePosition.toIsoCode());
    });
    return result;
  }

  /// La bahía con la que se cuenta y se rotula [bay] en el avance: la regla
  /// de la par de referencia (`reference_bay.dart`), con las bahías que el
  /// plan dibuja.
  int displayBay(int bay) => referenceBay(bay, hasBay: loading.bays.containsKey);
  int bayOf(String position) => IsoCoordinateParser.parse(position).bay;

  /// T-122 (H6, 10.56) · Los vacíos asignados a una reserva, como contenedores
  /// a bordo: con su número, su celda, su tipo y su tara. El BAPLIE de salida
  /// ya los escribe así (`departure_baplie_writer.dart`); la búsqueda general
  /// y la Lista los toman de aquí, porque el plan los trae sin número.
  List<ContainerUnit> get assignedEmpties {
    final result = <ContainerUnit>[];
    for (final item in state.items.values) {
      final container = item.assignedContainer;
      final at = item.position;
      if (item.kind != PlanItemKind.reservedSlot ||
          item.state != ItemState.moved ||
          container == null ||
          at == null) {
        continue;
      }
      final slot = plan.loading[item.key]?.reservedSlot;
      final row = list?.byContainer(container);
      final tare = item.tareKg ?? row?.tareKg;
      result.add(ContainerUnit(
        id: 'assigned-$container',
        containerId: container,
        isoSizeType: row?.type ?? slot?.isoSizeType,
        status: ContainerStatus.empty,
        stowagePosition: IsoCoordinateParser.parse(at),
        grossWeight: tare,
        tareWeight: tare,
        portOfLoading: slot?.portOfLoading ?? plan.portOfCall,
        portOfDischarge: row?.pod ?? slot?.portOfDischarge,
        operatorCode: row?.line ?? slot?.operatorCode,
      ));
    }
    result.sort((a, b) => a.containerId.compareTo(b.containerId));
    return result;
  }

  Movement? movementOf(String key) {
    final id = state[key]?.movementId;
    for (final event in movements) {
      if (event.id == id) return event;
    }
    // Una carga rechazada por ocupación también puede deshacerse/corregirse.
    final conflicts = state.conflicts.where((c) => c.key == key).toList();
    for (final conflict in conflicts.reversed) {
      for (final event in movements) {
        if (event.id == conflict.movementId &&
            (event.type == MovementType.loadFull ||
                event.type == MovementType.assignEmpty)) {
          return event;
        }
      }
    }
    return null;
  }

  /// T-77 · Revisa la carga contra el estado derivado, antes de escribir.
  /// Con [correcting], la cadena corregida se retira de la vista previa.
  LoadCheck check(ExportListRow row, String position, {Movement? correcting}) =>
      LoadValidator(
              plan: plan,
              state: _before(correcting),
              loading: loading,
              list: list)
          .check(row, position, numbered: numbered(row));

  /// T-77 · Reservas que la pantalla ofrece a un vacío: primero las libres
  /// de su grupo (las de [slots]), luego las de su grupo que ocupa un
  /// contenedor que baja aquí sin marcar y, si [otherGroups], las libres de
  /// otros grupos, que piden motivo.
  List<ReservedSlot> candidateSlots(ExportListRow row,
      {int? selectedBay, Movement? correcting, bool otherGroups = false}) {
    final free = slots(row, selectedBay: selectedBay, correcting: correcting);
    if (!row.isEmpty ||
        numbered(row) != null ||
        !available(row, correcting: correcting)) {
      return free;
    }
    final before = _before(correcting);
    // T-147: una reserva es su celda; buscarla en `free` por su clave da lo
    // mismo que compararla campo por campo con cada una, que era un quinto
    // del tiempo de la hoja.
    final freeKeys = {for (final slot in free) slot.key};
    final waiting = <ReservedSlot>[];
    final others = <ReservedSlot>[];
    for (final item in plan.loading.values) {
      final slot = item.reservedSlot;
      if (slot == null ||
          item.role != PlanRole.load ||
          freeKeys.contains(slot.key) ||
          before[item.key]?.state != ItemState.planned) {
        continue;
      }
      if (!_leaves(before, item)) continue;
      final sameGroup = slot.isoSizeType == row.type &&
          slot.portOfDischarge == row.pod &&
          slot.operatorCode == row.line;
      if (sameGroup) {
        waiting.add(slot);
      } else if (otherGroups) {
        others.add(slot);
      }
    }
    int order(ReservedSlot a, ReservedSlot b) {
      final selectedGroup =
          selectedBay == null ? null : displayBay(selectedBay);
      final aHere = displayBay(a.stowagePosition.bay) == selectedGroup;
      final bHere = displayBay(b.stowagePosition.bay) == selectedGroup;
      if (aHere != bHere) return aHere ? -1 : 1;
      return a.stowagePosition
          .toIsoCode()
          .compareTo(b.stowagePosition.toIsoCode());
    }

    return [...free, ...waiting..sort(order), ...others..sort(order)];
  }

  /// Si la celda de [item] está libre o la ocupa un contenedor que baja en
  /// esta escala y todavía no se ha marcado.
  bool _leaves(OperationState before, PlanItem item) {
    final occupant = before.occupancy[item.plannedPosition];
    return occupant == null ||
        (before['C:$occupant']?.role == PlanRole.discharge &&
            before['C:$occupant']?.state == ItemState.planned);
  }

  /// T-147 (10.151, regla 1) · Si [slot] admite hoy un vacío del listado: es
  /// una reserva que el plan carga aquí, sigue planificada y su celda está
  /// libre o la ocupa un contenedor que baja aquí sin marcar.
  ///
  /// Es lo que [candidateSlots] decide de una celda con `otherGroups`, y no
  /// depende de la fila: las de su grupo entran por libres o por «baja
  /// aquí», y las de otro grupo, con motivo, por la misma condición. La hoja
  /// «Vacíos del listado» lo pregunta una vez, no una vez por fila.
  bool admitsEmpty(ReservedSlot slot) => plan.loading.values.any((item) =>
      item.reservedSlot?.key == slot.key &&
      item.role == PlanRole.load &&
      state[item.key]?.state == ItemState.planned &&
      _leaves(state, item));

  /// T-147 · Las filas que la hoja ofrece al abrirse desde [slot]: las de
  /// [search] que son un vacío por asignar (sin celda propia en el plan y sin
  /// operar), si la celda lo admite. Las mismas, y en el mismo orden, que
  /// filtrar [search] con `candidateSlots(row, otherGroups: true)` fila por
  /// fila, que es lo que hacía la hoja hasta la 1.0.1.
  List<ExportListRow> rowsFor(ReservedSlot slot, String query,
      {bool empties = true}) {
    if (!admitsEmpty(slot)) return [];
    return [
      for (final row in search(query, empties: empties))
        if (row.isEmpty && numbered(row) == null && available(row)) row
    ];
  }

  /// T-77 · «Marcar su descarga y cargar»: la descarga del ocupante que baja
  /// aquí, que se registra justo antes de la carga.
  MovementDraft dischargeDraft(PlanItem occupant) {
    if (operationId == null) {
      throw StateError('La escala no tiene operación guardada: vuelve a abrir el '
          'plan de carga y confirma la escala.');
    }
    return MovementDraft.discharge(operationId!,
        occupant.container!.containerId, occupant.plannedPosition);
  }

  /// Arma la carga después de revisarla (T-77). Lo imposible no se registra;
  /// lo que pide motivo exige [reason]; si un contenedor que baja aquí ocupa
  /// la celda, [dischargeOccupant] confirma que su descarga se registra antes.
  MovementDraft draft(ExportListRow row, String position,
      {String? seal,
      DateTime? operatedAt,
      Movement? correcting,
      String? reason,
      bool dischargeOccupant = false}) {
    if (operationId == null) {
      throw StateError('La escala no tiene operación guardada: vuelve a abrir el '
          'plan de carga y confirma la escala.');
    }
    if (row.unlisted) {
      // H4: un lleno del plan sin fila se carga por su número; la fila nace
      // del plan, así que lo que se comprueba es que el plan lo cargue aquí y
      // que sea un lleno (10.59: un vacío con número o un contenedor sin
      // estado necesita su fila, aunque alguien pase la fila armada).
      final motivo = needsRow(row.containerId);
      if (motivo != null) throw StateError(motivo);
    } else if (list?.byOrder(row.order) != row) {
      throw StateError('El OR ya no está en el listado de la agencia: importa de '
          'nuevo el listado.');
    }
    final hasReason = reason?.trim().isNotEmpty ?? false;
    if (correcting != null &&
        (movementOf(correcting.target!)?.id != correcting.id || !hasReason)) {
      throw StateError(
          'La corrección exige un movimiento vigente y un motivo: elige la carga '
          'vigente y escribe el motivo.');
    }
    if (!available(row, correcting: correcting)) {
      if (_before(correcting)['C:${row.containerId}']?.state ==
          ItemState.cancelled) {
        throw StateError(
            'Cancelado por la oficina. Debe deshacer la cancelación antes de cargar.');
      }
      throw StateError('El contenedor ya está operado: para cambiarlo, abre su '
          'detalle y usa Corregir o Deshacer carga.');
    }
    final item = numbered(row);
    if (item == null) {
      final reservation = plan.loadingItemAt(position);
      if (reservation?.reservedSlot == null ||
          reservation!.role != PlanRole.load) {
        throw StateError('Un vacío se asigna a una celda reservada del plan: '
            'elige una celda reservada.');
      }
      if (_before(correcting)[reservation.key]?.state == ItemState.cancelled) {
        throw StateError('La reserva está cancelada: elige otra o pide a la '
            'oficina que deshaga la cancelación.');
      }
    }
    final review = check(row, position, correcting: correcting);
    if (review.blocked) {
      throw StateError(review.issues.firstWhere((i) => i.blocks).message);
    }
    if (review.dischargeFirst != null && !dischargeOccupant) {
      throw StateError('La celda la ocupa '
          '${review.dischargeFirst!.container!.containerId}, que baja aquí: '
          'marca primero su descarga.');
    }
    if (review.needsReason && !hasReason) {
      throw StateError('Esta carga se registra solo con un motivo escrito: '
          'escribe el motivo para registrarla.');
    }
    if (item != null) {
      return MovementDraft.loadFull(operationId!, row.containerId, position,
          order: row.unlisted ? null : row.order,
          seal: seal,
          operatedAt: operatedAt,
          corrects: correcting?.id,
          reason: hasReason ? reason!.trim() : null);
    }
    return MovementDraft.assignEmpty(
        operationId!,
        plan.loadingItemAt(position)!.key.substring(2),
        row.containerId,
        row.tareKg,
        order: row.order,
        seal: seal,
        operatedAt: operatedAt,
        corrects: correcting?.id,
        reason: hasReason ? reason!.trim() : null);
  }
}
