import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/departure_export_repository_impl.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/departure_export_repository.dart';
import '../../domain/repositories/session_repository.dart';
import '../../domain/services/departure_baplie_writer.dart';
import '../../domain/services/loading_operation.dart';
import '../formatters/vessel_error_message.dart';
import '../providers/loading_operation_provider.dart';
import '../providers/sync_providers.dart';

final departureExportRepositoryProvider = Provider<DepartureExportRepository>(
    (ref) => const DepartureExportRepositoryImpl());

bool _allowed(AsyncValue<Operator?> actor) =>
    actor.hasValue &&
    (actor.value == null ||
        (actor.value!.authorized && actor.value!.role == OperatorRole.office));

class DepartureBaplieButton extends ConsumerWidget {
  final VesselVoyage voyage;
  const DepartureBaplieButton({super.key, required this.voyage});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!_allowed(ref.watch(operatorProvider))) return const SizedBox.shrink();
    return TextButton.icon(
        key: const ValueKey('departure-baplie-button'),
        icon: const Icon(Icons.save_alt),
        label: const Text('Generar BAPLIE de salida'),
        onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(
            builder: (_) => DepartureBapliePage(voyage: voyage))));
  }
}

class DepartureBapliePage extends ConsumerStatefulWidget {
  final VesselVoyage voyage;
  const DepartureBapliePage({super.key, required this.voyage});
  @override
  ConsumerState<DepartureBapliePage> createState() =>
      _DepartureBapliePageState();
}

class _DepartureBapliePageState extends ConsumerState<DepartureBapliePage> {
  bool _saving = false;
  DepartureBaplie _output(Operation operation, LoadingOperation data) =>
      const DepartureBaplieWriter().generate(
          operation: operation,
          state: data.state,
          list: data.list,
          movements: data.movements);

  @override
  Widget build(BuildContext context) {
    final actor = ref.watch(operatorProvider);
    final operation = ref.watch(activeOperationProvider);
    final loading = ref.watch(loadingOperationProvider(widget.voyage));
    return Scaffold(
      appBar: AppBar(title: const Text('BAPLIE de salida')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: !_allowed(actor)
            ? const Text('Disponible para oficina o en modo sin cuenta.')
            : operation.hasError || loading.hasError
                ? Text(vesselErrorMessage(operation.error ?? loading.error!,
                    operation.stackTrace ?? loading.stackTrace))
                : !operation.hasValue || !loading.hasValue
                    ? const Center(child: CircularProgressIndicator())
                    : _content(operation.value, loading.value!),
      ),
    );
  }

  Widget _content(Operation? operation, LoadingOperation data) {
    DepartureBaplie output;
    try {
      if (operation == null) {
        throw StateError(
            'La escala no tiene una operación guardada con fuente loading_baplie.');
      }
      output = _output(operation, data);
    } on StateError catch (error) {
      return Text(error.message, key: const ValueKey('departure-error'));
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
          '${operation.vesselName} · ${operation.voyageNumber} · ${operation.portOfCall}',
          style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 16),
      Text('${output.containers} contenedores a bordo en la salida.'),
      Text(
          'Pendientes: ${output.pendingLoads} de carga y ${output.pendingDischarges} de descarga.',
          key: const ValueKey('departure-pending')),
      if (output.pendingLoads + output.pendingDischarges > 0)
        const Text(
            'Puedes generar igual: la salida refleja lo registrado hasta ahora. '
            'Las cargas pendientes y los cancelados quedan fuera; lo que todavía no se descargó sigue a bordo.'),
      if (data.state.conflicts.isNotEmpty)
        Text(
            '${data.state.conflicts.length} conflictos vigentes. Revisa el avance de la operación; '
            'la salida usa las posiciones físicas registradas.'),
      const SizedBox(height: 16),
      Text('Cancelados vigentes (${output.cancelled.length})',
          style: Theme.of(context).textTheme.titleMedium),
      if (output.cancelled.isEmpty)
        const Text('No hay cancelados vigentes.')
      else ...[
        SelectableText(output.cancelledText,
            key: const ValueKey('departure-cancelled-list')),
        TextButton.icon(
            key: const ValueKey('departure-copy-cancelled'),
            onPressed: () async {
              await Clipboard.setData(
                  ClipboardData(text: output.cancelledText));
              if (mounted) _notice('Lista de cancelados copiada');
            },
            icon: const Icon(Icons.copy),
            label: const Text('Copiar cancelados')),
      ],
      const SizedBox(height: 24),
      FilledButton.icon(
          key: const ValueKey('departure-save'),
          onPressed: _saving ? null : _save,
          icon: const Icon(Icons.save_alt),
          label: Text(_saving ? 'Guardando…' : 'Guardar BAPLIE de salida')),
    ]);
  }

  void _notice(String message) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(message)));

  Future<void> _save() async {
    if (!_allowed(ref.read(operatorProvider))) return;
    setState(() => _saving = true);
    try {
      // Se toma el estado vigente al pulsar, no el de una vista previa anterior.
      final operation = ref.read(activeOperationProvider).value;
      final data = ref.read(loadingOperationProvider(widget.voyage)).value;
      if (operation == null || data == null) {
        throw StateError(
            'La operación se está actualizando. Intenta de nuevo.');
      }
      final output = _output(operation, data);
      final path = await ref
          .read(departureExportRepositoryProvider)
          .save(operation, output.text);
      if (mounted && (path != null || kIsWeb)) {
        _notice('Exportación BAPLIE completada');
      }
    } catch (error, stack) {
      if (mounted) {
        _notice(error is StateError
            ? error.message
            : vesselErrorMessage(error, stack));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
