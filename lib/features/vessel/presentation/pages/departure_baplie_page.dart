import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../../core/design/design.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/departure_export_repository_impl.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/departure_export_repository.dart';
import '../../domain/repositories/session_repository.dart';
import '../../domain/services/departure_baplie_writer.dart';
import '../../domain/services/departure_baplie_review.dart';
import '../../domain/services/loading_operation.dart';
import '../formatters/operation_text.dart';
import '../formatters/vessel_error_message.dart';
import '../providers/loading_operation_provider.dart';
import '../providers/sync_providers.dart';
import '../providers/vessel_providers.dart';
import 'voyage_comparison_page.dart';
import '../widgets/avisos_del_viaje.dart';
import '../../../../core/utils/voyage_number.dart';

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
        icon: const Icon(BsIconos.baplieSalida),
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
  final _choices = <String, DepartureChoice>{};
  DepartureBaplie _output(Operation operation, LoadingOperation data,
      {bool preview = false}) {
    // T-103: la llegada también aporta segmentos de los que siguen a bordo.
    for (final source in operation.sources) {
      if (source.kind != OperationSourceKind.exportList &&
          declaresSmdg15(source.content)) {
        throw StateError('No se genera el BAPLIE de salida: '
            '«${source.fileName}» es versión 1.5 (SMDG15) y se leyó con las '
            'reglas de 2.x. Escribir la salida con esas reglas no sería fiel a '
            'lo que llegó. Importa el plano en SMDG20, SMDG21 o SMDG22.');
      }
    }
    return const DepartureBaplieWriter().generate(
        operation: operation,
        state: data.state,
        list: data.list,
        movements: data.movements,
        choices: _choices,
        preview: preview);
  }

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
                    operation.stackTrace ?? loading.stackTrace,
                    'abrir la operación de la escala'))
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
            'La escala no tiene una operación guardada con su plan de carga: abre '
            'el plan de carga (BAPLIE) y confirma la escala.');
      }
      output = _output(operation, data, preview: true);
    } on StateError catch (error) {
      return Text(error.message, key: const ValueKey('departure-error'));
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
          '${operation.vesselName} · ${voyageNumberLabel(operation.voyageNumber)} · ${operation.portOfCall}',
          style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 16),
      // T-124 (10.65, P3): con su singular.
      Text('${operationCount(output.containers, 'contenedor', 'contenedores')} '
          'a bordo en la salida.'),
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
      // T-122, corrección 1 (10.57): los llenos cargados sin fila (H4).
      if (output.withoutRow.isNotEmpty)
        Text(
            output.withoutRow.length == 1
                ? '1 lleno va con los datos del plan de carga porque no tiene '
                    'fila en el listado: ${output.withoutRow.single}.'
                : '${output.withoutRow.length} llenos van con los datos del plan '
                    'de carga porque no tienen fila en el listado: '
                    '${output.withoutRow.join(', ')}.',
            key: const ValueKey('departure-without-row')),
      if (output.decisions.isNotEmpty) ...[
        const SizedBox(height: 16),
        Text(
          'Datos por confirmar',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const Text(
          'Elige el dato válido para cada contenedor. '
          'No se puede guardar hasta resolver todas las discrepancias.',
        ),
        for (final decision in output.decisions) _decision(decision),
      ],
      if (output.warnings.isNotEmpty) ...[
        const SizedBox(height: 16),
        Text(
          'Avisos de la salida',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        for (final warning in output.warnings) Text(warning),
      ],
      if (output.errors.isNotEmpty) ...[
        const SizedBox(height: 16),
        Text(
          'Datos que impiden guardar',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        for (final error in output.errors) Text(error),
      ],
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
      const SizedBox(height: 16),
      Text(
        'Filas del listado que no cargaron (${output.notLoaded.length})',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      if (data.list == null)
        const Text('La operación no tiene un listado de la agencia.')
      else if (output.notLoaded.isEmpty)
        const Text('Todas las filas del listado están a bordo en la salida.')
      else ...[
        SelectableText(
          output.notLoadedText,
          key: const ValueKey('departure-not-loaded-list'),
        ),
        TextButton.icon(
          key: const ValueKey('departure-copy-not-loaded'),
          onPressed: () async {
            await Clipboard.setData(
              ClipboardData(text: output.notLoadedText),
            );
            if (mounted) _notice('Lista de filas no cargadas copiada');
          },
          icon: const Icon(Icons.copy),
          label: const Text('Copiar filas no cargadas'),
        ),
      ],
      const SizedBox(height: 24),
      FilledButton.icon(
          key: const ValueKey('departure-save'),
          onPressed: _saving || !output.canSave ? null : _save,
          icon: const Icon(BsIconos.baplieSalida),
          label: Text(_saving ? 'Guardando…' : 'Guardar BAPLIE de salida')),
      const SizedBox(height: 12),
      // T-96: la salida generada, releída en memoria, contra la llegada.
      if (operation.sources
          .any((s) => s.kind == OperationSourceKind.arrivalBaplie))
        OutlinedButton.icon(
            key: const ValueKey('departure-compare-arrival'),
            onPressed: output.canSave
                ? () => _compareWithArrival(operation, output)
                : null,
            icon: const Icon(BsIconos.compararBaplie),
            label: const Text('Comparar con la llegada'))
      else
        const Text('La operación no tiene un plano de llegada para comparar.',
            key: ValueKey('departure-compare-unavailable')),
    ]);
  }

  Widget _decision(DepartureDecision decision) => Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'OR ${decision.order} · ${decision.container} · ${decision.subject}',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Text(decision.message),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final choice in DepartureChoice.values)
                  ChoiceChip(
                    key: ValueKey(
                      'departure-choice-${decision.container}-'
                      '${decision.subject}-${choice.name}',
                    ),
                    label: Text(
                      choice == DepartureChoice.plan
                          ? 'Usar el plan'
                          : 'Usar el listado',
                    ),
                    selected: _choices[decision.id] == choice,
                    onSelected: _saving
                        ? null
                        : (_) => setState(() => _choices[decision.id] = choice),
                  ),
              ],
            ),
          ],
        ),
      );

  Future<void> _compareWithArrival(
      Operation operation, DepartureBaplie output) async {
    final arrivalSource = operation.sources
        .firstWhere((s) => s.kind == OperationSourceKind.arrivalBaplie);
    final repository = ref.read(vesselRepositoryProvider);
    final arrival = await repository.parseBaplieFile(arrivalSource.content);
    final departure = await repository.parseBaplieFile(output.text);
    if (!mounted) return;
    final failure = arrival.fold((f) => f, (_) => null) ??
        departure.fold((f) => f, (_) => null);
    if (failure != null) {
      _notice(vesselFailureMessage(failure, 'comparar la salida con la llegada'),
          corto: 'No se pudo comparar.');
      return;
    }
    await Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => VoyageComparisonPage(
            first: arrival.getOrElse(() => throw StateError('llegada')),
            second: departure.getOrElse(() => throw StateError('salida')),
            firstLabel: 'Llegada: ${arrivalSource.fileName}',
            secondLabel: 'Salida generada, sin guardar')));
  }

  /// Puede seguir en pantalla al volver al plano: sabe su lugar (10.33).
  void _notice(String message, {String? corto}) => ScaffoldMessenger.of(context)
      .showSnackBar(avisoDelViaje(texto: message, corto: corto));

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
        _notice('Exportación BAPLIE completada', corto: 'BAPLIE exportado.');
      }
    } catch (error, stack) {
      if (mounted) {
        _notice(
            error is StateError
                ? error.message
                : vesselErrorMessage(error, stack, 'generar el BAPLIE de salida'),
            corto: 'No se generó el BAPLIE.');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
