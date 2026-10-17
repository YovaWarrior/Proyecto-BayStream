import 'package:flutter/material.dart';

import '../../domain/entities/entities.dart';
import '../../domain/services/discharge_sequence.dart';
import '../formatters/operation_text.dart';
import '../widgets/loading_controls.dart' show loadingPosition;

/// T-95 · RF-028: el orden de descarga sugerido para un puerto, con sus
/// sobreestibas. Es un cálculo sobre el archivo: no registra ni sigue el
/// avance, que es del modo Descarga (T-75).
///
/// Las tapas llegan del perfil vigente; la página no lee providers para que se
/// pueda probar con cualquier declaración.
class DischargeSequencePage extends StatefulWidget {
  final VesselVoyage voyage;
  final Map<int, HatchCoverDeclaration> hatchCovers;
  const DischargeSequencePage(
      {super.key, required this.voyage, this.hatchCovers = const {}});

  @override
  State<DischargeSequencePage> createState() => _DischargeSequencePageState();
}

/// Una fila de la lista perezosa: la cabecera de una celda o uno de sus pasos.
typedef _Entry = ({DischargeCell cell, DischargeStep? step});

class _DischargeSequencePageState extends State<DischargeSequencePage> {
  String? _port;

  @override
  Widget build(BuildContext context) {
    final voyage = widget.voyage;
    final geometry = voyage.geometry;
    final ports = DischargeSequence.dischargePorts(voyage);
    final port = _port ??
        (ports.contains(voyage.portOfCall) ? voyage.portOfCall : null) ??
        (ports.isEmpty ? null : ports.first);
    return Scaffold(
      appBar: AppBar(title: const Text('Orden de descarga')),
      body: geometry == null || port == null
          ? Center(
              child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                  key: const ValueKey('discharge-unavailable'),
                  geometry == null
                      ? 'Confirma la geometría del buque para sugerir el orden de descarga.'
                      : 'El archivo no trae puertos de descarga.',
                  textAlign: TextAlign.center),
            ))
          : _body(
              context,
              ports,
              DischargeSequence.build(voyage, port,
                  geometry: geometry, hatchCovers: widget.hatchCovers)),
    );
  }

  Widget _body(BuildContext context, List<String> ports, DischargeSequence s) {
    final text = Theme.of(context).textTheme;
    final entries = <_Entry>[
      for (final cell in s.cells) ...[
        (cell: cell, step: null),
        for (final step in cell.steps) (cell: cell, step: step),
      ],
    ];
    final header = Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Wrap(
            spacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Text('Puerto de descarga'),
              DropdownButton<String>(
                key: const ValueKey('discharge-port'),
                value: s.port,
                items: [
                  for (final p in ports)
                    DropdownMenuItem(
                        value: p,
                        child: Text(p == widget.voyage.portOfCall
                            ? '$p (escala)'
                            : p)),
                ],
                onChanged: (value) => setState(() => _port = value),
              ),
            ]),
        const SizedBox(height: 8),
        Text(_summary(s),
            key: const ValueKey('discharge-summary'), style: text.titleMedium),
        Text(
            '${s.deckDischarges} en cubierta · ${s.holdDischarges} en bodega · '
            '${operationCount(s.cells.length, 'celda', 'celdas')}, de más a menos '
            'movimientos por muelle',
            key: const ValueKey('discharge-zones'),
            style: text.bodySmall),
        const SizedBox(height: 8),
        for (final (key, message) in _warnings(s)) _warning(context, key, message),
      ]),
    );
    return ListView.builder(
      key: const ValueKey('discharge-list'),
      itemCount: entries.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) return header;
        final entry = entries[index - 1];
        return entry.step == null
            ? _cellHeader(context, entry.cell)
            : _stepRow(context, entry.cell, entry.step!);
      },
    );
  }

  static String _summary(DischargeSequence s) =>
      '${operationCount(s.discharges, 'descarga', 'descargas')} · '
      '${operationCount(s.restows, 're‑estiba', 're‑estibas')} '
      '(${s.columnRestows} por columna, ${s.coverRestows} por tapa) · '
      '${operationCount(s.craneCovers, 'tapa de grúa', 'tapas de grúa')} · '
      '${operationCount(s.movesOnBoard, 'movimiento', 'movimientos')} a bordo, '
      '${s.movesByQuay} por muelle';

  static List<(String, String)> _warnings(DischargeSequence s) => [
        if (s.holdWithoutCover.isNotEmpty)
          (
            'hold-without-cover',
            '${operationCount(s.holdWithoutCover.length, 'descarga', 'descargas')} '
                'en bodega sin tapa declarada: no se cuentan movimientos de tapa '
                '(${_positions(s.holdWithoutCover)}).'
          ),
        if (s.outsideCoverRows.isNotEmpty)
          (
            'outside-cover-rows',
            '${operationCount(s.outsideCoverRows.length, 'contenedor', 'contenedores')} '
                'de cubierta en filas fuera de las tapas: no estorban y no se '
                'cuentan (${_positions(s.outsideCoverRows)}).'
          ),
        if (s.withoutPosition.isNotEmpty)
          (
            'without-position',
            '${operationCount(s.withoutPosition.length, 'contenedor', 'contenedores')} '
                'de ${s.port} sin posición: no entran en la secuencia.'
          ),
        if (s.withoutDischargePort > 0)
          (
            'without-port',
            '${operationCount(s.withoutDischargePort, 'contenedor', 'contenedores')} '
                'sin puerto de descarga: se tratan como que no bajan.'
          ),
        if (s.mergedCoverDeclarations > 0)
          (
            'merged-covers',
            '${operationCount(s.mergedCoverDeclarations, 'declaración repetida', 'declaraciones repetidas')} '
                'de tapa se unieron con su tapa física.'
          ),
      ];

  static String _positions(List<String> positions) {
    final shown = positions.take(6).map(loadingPosition).join(', ');
    return positions.length > 6 ? '$shown…' : shown;
  }

  Widget _warning(BuildContext context, String key, String message) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      key: ValueKey('discharge-warning-$key'),
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: scheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(12)),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(Icons.info_outline, color: scheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Expanded(child: Text(message)),
      ]),
    );
  }

  static String _cellName(DischargeCell cell) =>
      cell.bays.map((b) => b.toString().padLeft(3, '0')).join('/');

  Widget _cellHeader(BuildContext context, DischargeCell cell) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final name = _cellName(cell);
    return Container(
      key: ValueKey('discharge-cell-$name'),
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: scheme.secondaryContainer,
          borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Celda $name',
            style: text.titleSmall?.copyWith(color: scheme.onSecondaryContainer)),
        Text(
            '${operationCount(cell.movesOnBoard, 'movimiento', 'movimientos')} a bordo, '
            '${cell.movesByQuay} por muelle · '
            '${operationCount(cell.discharges, 'descarga', 'descargas')} · '
            '${operationCount(cell.restows, 're‑estiba', 're‑estibas')} · '
            '${operationCount(cell.craneCovers, 'tapa de grúa', 'tapas de grúa')}',
            style: text.bodySmall?.copyWith(color: scheme.onSecondaryContainer)),
      ]),
    );
  }

  /// El rótulo nunca va solo con color: lleva su texto y su ícono. «Re‑estiba»
  /// lleva un guion que no parte línea (U+2011, T-106).
  static (String, IconData) _label(DischargeStep step) {
    final cover = step.cover;
    final name = cover == null
        ? ''
        : cover.crane
            ? 'Tapa T${cover.number}'
            : 'Tapa automática';
    return switch (step.kind) {
      DischargeStepKind.discharge => ('Descarga', Icons.south),
      DischargeStepKind.restowOut => ('Re‑estiba: sale', Icons.north),
      DischargeStepKind.coverOff => (
          cover!.crane ? '$name: quitar' : '$name: abrir',
          Icons.expand_less
        ),
      DischargeStepKind.coverOn => (
          cover!.crane ? '$name: reponer' : '$name: cerrar',
          Icons.expand_more
        ),
      DischargeStepKind.restowBack => ('Re‑estiba: vuelve', Icons.undo),
    };
  }

  Widget _stepRow(BuildContext context, DischargeCell cell, DischargeStep step) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final (label, icon) = _label(step);
    final why = switch (step.reason) {
      RestowReason.column => ' · por columna',
      RestowReason.cover => ' · por tapa',
      null => '',
    };
    final where = step.cover == null
        ? '${loadingPosition(step.position)} · ${step.container!.containerId}$why'
        : 'Bahía ${step.position} · filas '
            '${(step.cover!.rows.toList()..sort()).map((r) => r.toString().padLeft(2, '0')).join(', ')}';
    return Padding(
      key: ValueKey('discharge-step-${_cellName(cell)}-${step.number}'),
      padding: const EdgeInsets.fromLTRB(24, 4, 16, 4),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
            width: 40,
            child: Text('${step.number}.',
                style: text.bodyMedium, textAlign: TextAlign.end)),
        const SizedBox(width: 8),
        Icon(icon, size: 20, color: scheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: text.bodyMedium),
          Text(where, style: text.bodySmall),
        ])),
      ]),
    );
  }
}
