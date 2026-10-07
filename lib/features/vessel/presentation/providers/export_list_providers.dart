import 'dart:async';
import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/errors/failures.dart';
import '../../data/repositories/export_list_repository_impl.dart';
import '../../data/repositories/local_vessel_repository_factory.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/export_list_repository.dart';
import '../../domain/repositories/movement_log_repository.dart';
import '../../domain/services/export_list_cross_checker.dart';
import '../formatters/vessel_error_message.dart';
import 'vessel_providers.dart';

final exportListRepositoryProvider =
    Provider<ExportListRepository>((ref) => const ExportListRepositoryImpl());

/// T-73 · La bitácora local de T-72, donde vive la operación con sus fuentes.
final movementLogRepositoryProvider = FutureProvider<MovementLogRepository>((ref) async {
  var disposed = false;
  MovementLogRepository? repository;
  ref.onDispose(() {
    disposed = true;
    if (repository != null) unawaited(repository.close());
  });
  repository = await openMovementLogRepository();
  if (disposed) await repository.close();
  return repository;
});

/// Lo que la pantalla de importación muestra.
class ExportListImportState {
  /// Listado recién leído, con los códigos del Excel.
  final ExportList? list;
  final List<EquivalenceProposal> proposals;

  /// El listado con las equivalencias resueltas hasta ahora, y su cruce.
  final ExportList? normalized;
  final ExportListCrossCheck? crossCheck;

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
        saved: saved ?? this.saved,
        savedCrossCheck: savedCrossCheck ?? this.savedCrossCheck,
        busy: busy ?? this.busy,
        error: error,
        message: message,
      );
}

final exportListImportProvider =
    NotifierProvider.autoDispose<ExportListImportNotifier, ExportListImportState>(
        ExportListImportNotifier.new);

/// T-73 · Importa el listado de la agencia contra el plan de carga abierto.
class ExportListImportNotifier extends Notifier<ExportListImportState> {
  @override
  ExportListImportState build() => const ExportListImportState();

  VesselVoyage? get _plan => ref.read(voyageNotifierProvider).value;

  /// Operación de la escala del plan abierto: buque, viaje y puerto.
  Future<Operation?> _operation(MovementLogRepository log, VesselVoyage plan) async {
    final operations = (await log.getOperations())
        .fold((failure) => throw VesselOperationFailure(failure), (o) => o);
    for (final operation in operations) {
      if (operation.vesselName == plan.vessel.name &&
          operation.voyageNumber == plan.voyageNumber &&
          operation.portOfCall == plan.portOfCall) {
        return operation;
      }
    }
    return null;
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
      final saved = ExportList.fromJson(jsonDecode(source.content) as Map<String, dynamic>);
      state = state.copyWith(
        saved: saved,
        savedCrossCheck: ExportListCrossChecker.crossCheck(saved, plan, plan.portOfCall!),
      );
    } catch (error, stack) {
      if (ref.mounted) state = state.copyWith(error: vesselErrorMessage(error, stack));
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
      state = state.copyWith(error: 'El archivo está vacío o no se pudo leer.');
      return;
    }
    await loadBytes(bytes, fileName: file.name);
  }

  Future<void> loadBytes(List<int> bytes, {required String fileName}) async {
    final plan = _plan;
    if (plan == null || plan.portOfCall == null) {
      state = state.copyWith(
          error: 'Abre primero el plan de carga y confirma la escala.');
      return;
    }
    state = state.copyWith(busy: true);
    try {
      final list = (await ref.read(exportListRepositoryProvider)
              .parseExportList(bytes, fileName: fileName))
          .fold((failure) => throw _ListFailure(failure), (l) => l);
      final local = await ref.read(localVesselRepositoryProvider.future);
      final saved = (await local.getCodeEquivalences())
          .fold((failure) => throw VesselOperationFailure(failure), (e) => e);
      final proposals = ExportListCrossChecker.propose(list, plan,
          portOfCall: plan.portOfCall!, saved: saved);
      if (!ref.mounted) return;
      state = _withCrossCheck(state.copyWith(list: list, proposals: proposals, busy: false), plan);
    } on _ListFailure catch (e) {
      if (ref.mounted) state = state.copyWith(busy: false, error: e.failure.message);
    } catch (error, stack) {
      if (ref.mounted) state = state.copyWith(busy: false, error: vesselErrorMessage(error, stack));
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

  ExportListImportState _withCrossCheck(ExportListImportState s, VesselVoyage plan) {
    final list = s.list;
    if (list == null) return s;
    final normalized = list.normalized(ExportListCrossChecker.tableOf(s.proposals));
    return s.copyWith(
      normalized: normalized,
      crossCheck: ExportListCrossChecker.crossCheck(normalized, plan, plan.portOfCall!),
    );
  }

  /// Guarda las equivalencias en el dispositivo y el listado normalizado como
  /// fuente `export_list` de la operación. Devuelve el error, o null.
  Future<String?> confirm({DateTime Function()? clock}) async {
    final plan = _plan;
    final normalized = state.normalized;
    if (plan == null || plan.portOfCall == null || normalized == null) {
      return 'No hay un listado leído para importar.';
    }
    if (state.hasPending) {
      return 'Falta elegir equivalencias: ${state.proposals.where((p) => p.needsUser).map((p) => p.listCode).join(', ')}.';
    }
    if (state.busy) return 'Hay una operación en curso.';
    state = state.copyWith(busy: true);
    try {
      final local = await ref.read(localVesselRepositoryProvider.future);
      final stored = (await local.getCodeEquivalences())
          .fold((failure) => throw VesselOperationFailure(failure), (e) => e);
      (await local.saveCodeEquivalences(
              stored.merge(ExportListCrossChecker.tableOf(state.proposals))))
          .fold((failure) => throw VesselOperationFailure(failure), (_) {});

      final log = await ref.read(movementLogRepositoryProvider.future);
      final existing = await _operation(log, plan);
      final source = OperationSource(
        kind: OperationSourceKind.exportList,
        fileName: normalized.fileName,
        content: jsonEncode(normalized.toJson()),
      );
      final operation = Operation(
        id: existing?.id ?? const Uuid().v4(),
        vesselName: plan.vessel.name,
        voyageNumber: plan.voyageNumber,
        portOfCall: plan.portOfCall!,
        createdAt: existing?.createdAt ?? (clock ?? DateTime.now)(),
        sources: [
          ...?existing?.sources.where((s) => s.kind != OperationSourceKind.exportList),
          source,
        ],
      );
      (await log.saveOperation(operation))
          .fold((failure) => throw VesselOperationFailure(failure), (_) {});
      if (!ref.mounted) return null;
      state = ExportListImportState(
        saved: normalized,
        savedCrossCheck: state.crossCheck,
        message: 'Listado guardado en la operación de ${plan.portOfCall}: '
            '${normalized.rows.length} filas.',
      );
      return null;
    } catch (error, stack) {
      final message = vesselErrorMessage(error, stack);
      if (ref.mounted) state = state.copyWith(busy: false, error: message);
      return message;
    }
  }

  /// Descarta el listado leído sin guardar nada.
  void discard() => state = state.copyWith(clearImport: true);
}

class _ListFailure implements Exception {
  final Failure failure;
  const _ListFailure(this.failure);
}
