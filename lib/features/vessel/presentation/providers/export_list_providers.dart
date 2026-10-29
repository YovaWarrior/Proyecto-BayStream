import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failures.dart';
import '../../data/repositories/export_list_repository_impl.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/export_list_repository.dart';
import '../../domain/repositories/movement_log_repository.dart';
import '../../domain/services/export_list_cross_checker.dart';
import '../../domain/services/operation_sources.dart';
import '../../domain/services/operation_state_deriver.dart';
import 'movement_log_provider.dart';
export 'movement_log_provider.dart' show movementLogRepositoryProvider;
import '../formatters/vessel_error_message.dart';
import 'sync_providers.dart' show operationSyncProvider;
import 'vessel_providers.dart';

final exportListRepositoryProvider =
    Provider<ExportListRepository>((ref) => const ExportListRepositoryImpl());

/// Lo que la pantalla de importación muestra.
class ExportListImportState {
  /// Listado recién leído, con los códigos del Excel.
  final ExportList? list;
  final List<EquivalenceProposal> proposals;

  /// El listado con las equivalencias resueltas hasta ahora, y su cruce.
  final ExportList? normalized;
  final ExportListCrossCheck? crossCheck;

  /// T-127 · Lo que el listado leído cambia en lo ya operado, cuando la
  /// operación de la escala tiene movimientos; nulo si no los tiene.
  final ExportListRevisionImpact? impact;

  /// Listado ya guardado en la operación de esta escala, si lo hay.
  final ExportList? saved;
  final ExportListCrossCheck? savedCrossCheck;
  final bool busy;
  final String? error;
  final String? message;

  const ExportListImportState({
    this.list,
    this.proposals = const [],
    this.normalized,
    this.crossCheck,
    this.impact,
    this.saved,
    this.savedCrossCheck,
    this.busy = false,
    this.error,
    this.message,
  });

  bool get hasPending => proposals.any((p) => p.needsUser);

  ExportListImportState copyWith({
    ExportList? list,
    List<EquivalenceProposal>? proposals,
    ExportList? normalized,
    ExportListCrossCheck? crossCheck,
    ExportListRevisionImpact? impact,
    bool clearImpact = false,
    ExportList? saved,
    ExportListCrossCheck? savedCrossCheck,
    bool clearImport = false,
    bool? busy,
    String? error,
    String? message,
  }) =>
      ExportListImportState(
        list: clearImport ? null : list ?? this.list,
        proposals: clearImport ? const [] : proposals ?? this.proposals,
        normalized: clearImport ? null : normalized ?? this.normalized,
        crossCheck: clearImport ? null : crossCheck ?? this.crossCheck,
        impact: clearImport || clearImpact ? null : impact ?? this.impact,
        saved: saved ?? this.saved,
        savedCrossCheck: savedCrossCheck ?? this.savedCrossCheck,
        busy: busy ?? this.busy,
        error: error,
        message: message,
      );
}

final exportListImportProvider = NotifierProvider.autoDispose<
    ExportListImportNotifier,
    ExportListImportState>(ExportListImportNotifier.new);

/// T-73 · Importa el listado de la agencia contra el plan de carga abierto.
class ExportListImportNotifier extends Notifier<ExportListImportState> {
  @override
  ExportListImportState build() => const ExportListImportState();

  VesselVoyage? get _plan => ref.read(voyageNotifierProvider).value;

  /// T-127 · Lo ya operado en la operación de la escala, derivado con el
  /// listado que tiene hoy, para decir qué cambia con el que se lee.
  ({OperationState state, ExportList? previous})? _operated;

  /// Operación de la escala del plan abierto: buque, viaje y puerto.
  Future<Operation?> _operation(
      MovementLogRepository log, VesselVoyage plan) async {
    return OperationSources.find(log, plan, plan.portOfCall!);
  }

  /// T-127 · El estado de la operación con su listado de hoy, si tiene
  /// movimientos. Si la bitácora no se puede leer, el cruce va sin este
  /// aviso: no impide leer el listado.
  Future<({OperationState state, ExportList? previous})?> _operatedState(
      MovementLogRepository log, VesselVoyage plan) async {
    try {
      final operation = await _operation(log, plan);
      if (operation == null) return null;
      final movements = (await log.records(operation.id))
          .getOrElse(() => const [])
          .where((r) => r.state != SendState.rejected)
          .map((r) => r.movement)
          .toList();
      if (movements.isEmpty) return null;
      final source = operation.source(OperationSourceKind.exportList);
      final previous = source == null
          ? null
          : ExportList.fromJson(
              jsonDecode(source.content) as Map<String, dynamic>);
      final state = const OperationStateDeriver().derive(
          OperationPlan.build(
              portOfCall: plan.portOfCall!,
              loading: plan,
              geometry: plan.geometry,
              list: previous),
          movements);
      return (state: state, previous: previous);
    } catch (_) {
      return null;
    }
  }

  /// Lee el listado que ya se guardó en la operación, para verlo sin el Excel.
  Future<void> loadSaved() async {
    final plan = _plan;
    if (plan == null || plan.portOfCall == null) return;
    try {
      final log = await ref.read(movementLogRepositoryProvider.future);
      final operation = await _operation(log, plan);
      final source = operation?.source(OperationSourceKind.exportList);
      if (source == null || !ref.mounted) return;
      final saved = ExportList.fromJson(
          jsonDecode(source.content) as Map<String, dynamic>);
      state = state.copyWith(
        saved: saved,
        savedCrossCheck:
            ExportListCrossChecker.crossCheck(saved, plan, plan.portOfCall!),
      );
    } catch (error, stack) {
      if (ref.mounted) {
        state = state.copyWith(
            error: vesselErrorMessage(
                error, stack, 'leer el listado guardado en la operación'));
      }
    }
  }

  Future<void> pickFile() async {
    if (state.busy) return;
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
      withData: true,
      dialogTitle: 'Seleccionar el listado de la agencia',
    );
    if (picked == null || picked.files.isEmpty || !ref.mounted) return;
    final file = picked.files.first;
    final bytes = file.bytes;
    if (bytes == null || bytes.isEmpty) {
      state = state.copyWith(
          error: 'El archivo está vacío o no se pudo leer: vuelve a elegir el '
              'Excel (.xlsx) de la agencia.');
      return;
    }
    await loadBytes(bytes, fileName: file.name);
  }

  Future<void> loadBytes(List<int> bytes, {required String fileName}) async {
    final plan = _plan;
    if (plan == null || plan.portOfCall == null) {
      state = state.copyWith(
          error: 'No hay un plan de carga confirmado: abre primero el plan de '
              'carga y confirma la escala.');
      return;
    }
    state = state.copyWith(busy: true);
    try {
      final list = (await ref
              .read(exportListRepositoryProvider)
              .parseExportList(bytes, fileName: fileName))
          .fold((failure) => throw _ListFailure(failure), (l) => l);
      final local = await ref.read(localVesselRepositoryProvider.future);
      final saved = (await local.getCodeEquivalences())
          .fold((failure) => throw VesselOperationFailure(failure), (e) => e);
      final proposals = ExportListCrossChecker.propose(list, plan,
          portOfCall: plan.portOfCall!, saved: saved);
      final log = await ref.read(movementLogRepositoryProvider.future);
      _operated = await _operatedState(log, plan);
      if (!ref.mounted) return;
      state = _withCrossCheck(
          state.copyWith(list: list, proposals: proposals, busy: false), plan);
    } on _ListFailure catch (e) {
      if (ref.mounted) {
        state = state.copyWith(busy: false, error: e.failure.message);
      }
    } catch (error, stack) {
      if (ref.mounted) {
        state = state.copyWith(
            busy: false,
            error: vesselErrorMessage(error, stack, 'leer el listado'));
      }
    }
  }

  /// El usuario confirma o corrige una equivalencia.
  void choose(EquivalenceKind kind, String listCode, String planCode) {
    final plan = _plan;
    final code = planCode.trim().toUpperCase();
    if (plan == null || code.isEmpty) return;
    state = _withCrossCheck(
        state.copyWith(proposals: [
          for (final p in state.proposals)
            p.kind == kind && p.listCode == listCode ? p.choose(code) : p,
        ]),
        plan);
  }

  ExportListImportState _withCrossCheck(
      ExportListImportState s, VesselVoyage plan) {
    final list = s.list;
    if (list == null) return s;
    final normalized =
        list.normalized(ExportListCrossChecker.tableOf(s.proposals));
    // T-127: el aviso sigue a las equivalencias elegidas, porque el grupo de
    // un vacío sale de los códigos ya traducidos.
    final operated = _operated;
    return s.copyWith(
      normalized: normalized,
      crossCheck:
          ExportListCrossChecker.crossCheck(normalized, plan, plan.portOfCall!),
      impact: operated == null
          ? null
          : ExportListCrossChecker.revisionImpact(
              operated.state, operated.previous, normalized),
      clearImpact: operated == null,
    );
  }

  /// Guarda el listado normalizado como fuente `export_list` de la operación
  /// y las equivalencias en el dispositivo. Devuelve el error, o null.
  ///
  /// T-127 · En una operación publicada el listado sube a la nube con la
  /// revisión siguiente (`OperationSyncRepository.replaceSource`) y el muelle
  /// lo recibe solo; si la nube no lo acepta, nada local cambia, tampoco las
  /// equivalencias, que se guardan después.
  Future<String?> confirm({DateTime Function()? clock}) async {
    final plan = _plan;
    final normalized = state.normalized;
    if (plan == null || plan.portOfCall == null || normalized == null) {
      return 'No hay un listado leído para importar: elige primero el Excel de '
          'la agencia.';
    }
    if (state.hasPending) {
      return 'Falta elegir equivalencias: ${state.proposals.where((p) => p.needsUser).map((p) => p.listCode).join(', ')}. '
          'Elige una para cada código antes de importar.';
    }
    if (state.busy) return 'Hay una operación en curso: espera a que termine.';
    state = state.copyWith(busy: true);
    try {
      final log = await ref.read(movementLogRepositoryProvider.future);
      final source = OperationSource(
        kind: OperationSourceKind.exportList,
        fileName: normalized.fileName,
        content: jsonEncode(normalized.toJson()),
      );
      final existing = await _operation(log, plan);
      final sync = existing != null && existing.published
          ? await ref.read(operationSyncProvider.future)
          : null;
      final saved = await OperationSources.save(
          log, plan, plan.portOfCall!, source,
          sync: sync, clock: clock);

      final local = await ref.read(localVesselRepositoryProvider.future);
      final stored = (await local.getCodeEquivalences())
          .fold((failure) => throw VesselOperationFailure(failure), (e) => e);
      (await local.saveCodeEquivalences(
              stored.merge(ExportListCrossChecker.tableOf(state.proposals))))
          .fold((failure) => throw VesselOperationFailure(failure), (_) {});

      ref.read(operationSourcesRevisionProvider.notifier).changed();
      if (!ref.mounted) return null;
      final revision = saved.exportListRevision;
      state = ExportListImportState(
        saved: normalized,
        savedCrossCheck: state.crossCheck,
        message: revision == 0
            ? 'Listado guardado en la operación de ${plan.portOfCall}: '
                '${normalized.rows.length} filas.'
            : 'Listado guardado en la operación publicada de ${plan.portOfCall}: '
                '${normalized.rows.length} filas, revisión $revision. '
                'El muelle lo recibe solo.',
      );
      return null;
    } catch (error, stack) {
      // T-127: lo que la nube contesta al reemplazar el listado ya viene
      // escrito para el usuario, con su causa y su acción (10.78).
      final message = error is Failure
          ? error.message
          : vesselErrorMessage(error, stack, 'importar el listado');
      if (ref.mounted) state = state.copyWith(busy: false, error: message);
      return message;
    }
  }

  /// Descarta el listado leído sin guardar nada.
  void discard() {
    _operated = null;
    state = state.copyWith(clearImport: true);
  }
}

class _ListFailure implements Exception {
  final Failure failure;
  const _ListFailure(this.failure);
}
