import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/entities.dart';
import '../../domain/services/export_list_cross_checker.dart';
import '../providers/export_list_providers.dart';
import '../providers/vessel_providers.dart';

/// T-73 · Importar el listado de exportación de la agencia (RF-038): elegir
/// el archivo, revisar el resumen y las equivalencias, confirmar. La
/// operación en el muelle llega con T-74 a T-76.
class ExportListImportPage extends ConsumerStatefulWidget {
  const ExportListImportPage({super.key});

  @override
  ConsumerState<ExportListImportPage> createState() => _ExportListImportPageState();
}

class _ExportListImportPageState extends ConsumerState<ExportListImportPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(exportListImportProvider.notifier).loadSaved());
  }

  @override
  Widget build(BuildContext context) {
    final plan = ref.watch(voyageNotifierProvider).value;
    final state = ref.watch(exportListImportProvider);
    final notifier = ref.read(exportListImportProvider.notifier);
    final theme = Theme.of(context);

    final Widget body;
    if (plan == null || plan.portOfCall == null) {
      body = const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('Abre primero el plan de carga (BAPLIE) y confirma la escala.',
              textAlign: TextAlign.center),
        ),
      );
    } else {
      final list = state.normalized;
      body = ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('${plan.vessel.name} · ${plan.voyageNumber} · escala ${plan.portOfCall}',
              style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text('El listado se cruza con el plan de carga abierto.',
              style: theme.textTheme.bodySmall),
          const SizedBox(height: 12),
          if (state.error != null) _Banner(text: state.error!, error: true),
          if (state.message != null) _Banner(text: state.message!),
          if (list == null) ...[
            FilledButton.icon(
              key: const ValueKey('export-list-pick'),
              onPressed: state.busy ? null : notifier.pickFile,
              icon: const Icon(Icons.table_view),
              label: Text(state.saved == null
                  ? 'Elegir listado (.xlsx)'
                  : 'Importar otro listado (.xlsx)'),
            ),
            if (state.busy) const Padding(
              padding: EdgeInsets.only(top: 16),
              child: Center(child: CircularProgressIndicator()),
            ),
            if (state.saved != null) ...[
              const SizedBox(height: 16),
              Text('Guardado en la operación', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              _ListSummary(list: state.saved!),
              if (state.savedCrossCheck != null) _CrossCheckCard(check: state.savedCrossCheck!),
              _RowsCard(list: state.saved!),
            ],
          ] else ...[
            _ListSummary(list: list),
            _EquivalencesCard(
              proposals: state.proposals,
              onChoose: notifier.choose,
            ),
            if (state.crossCheck != null) _CrossCheckCard(check: state.crossCheck!),
            _RowsCard(list: list),
            const SizedBox(height: 8),
            if (state.hasPending)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'Falta elegir ${state.proposals.where((p) => p.needsUser).length} '
                  'equivalencias antes de importar.',
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: state.busy ? null : notifier.discard,
                  child: const Text('Descartar'),
                ),
                FilledButton.icon(
                  key: const ValueKey('export-list-confirm'),
                  onPressed: state.busy || state.hasPending
                      ? null
                      : () async {
                          final error = await notifier.confirm();
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(error ?? 'Listado importado.')));
                        },
                  icon: const Icon(Icons.check),
                  label: const Text('Confirmar e importar'),
                ),
              ],
            ),
          ],
        ],
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Listado de la agencia')),
      body: body,
    );
  }
}

class _Banner extends StatelessWidget {
  final String text;
  final bool error;
  const _Banner({required this.text, this.error = false});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      color: error ? scheme.errorContainer : scheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(text,
            style: TextStyle(
                color: error ? scheme.onErrorContainer : scheme.onSecondaryContainer)),
      ),
    );
  }
}

String _count(int n, String one, String many) => '$n ${n == 1 ? one : many}';

/// «7266.59» → «7 266.59»; «3900» → «3 900».
String formatKg(double kg) {
  final fixed = kg == kg.roundToDouble() ? kg.toStringAsFixed(0) : kg.toStringAsFixed(2);
  final negative = fixed.startsWith('-');
  final parts = (negative ? fixed.substring(1) : fixed).split('.');
  final digits = parts[0];
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(' ');
    buffer.write(digits[i]);
  }
  return '${negative ? '−' : ''}$buffer${parts.length > 1 ? '.${parts[1]}' : ''}';
}

class _ListSummary extends StatelessWidget {
  final ExportList list;
  const _ListSummary({required this.list});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final agencies = list.agencies;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(list.fileName, style: theme.textTheme.titleSmall),
            for (final line in list.titleLines)
              Text(line, style: theme.textTheme.bodySmall),
            const SizedBox(height: 8),
            Text(
              '${list.rows.length} filas en ${agencies.length} agencias · '
              '${list.fulls.length} llenos · ${list.empties.length} vacíos',
              key: const ValueKey('export-list-counts'),
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            for (final entry in agencies.entries) Text('${entry.key}: ${entry.value}'),
            const SizedBox(height: 8),
            if (list.issues.isEmpty)
              const Text('Todas las filas se entendieron.',
                  key: ValueKey('export-list-issues'))
            else ...[
              Text(list.issues.length == 1 ? '1 fila sin entender:' : '${list.issues.length} filas sin entender:',
                  key: const ValueKey('export-list-issues'),
                  style: TextStyle(color: theme.colorScheme.error)),
              for (final issue in list.issues) Text('Fila ${issue.sheetRow}: ${issue.message}'),
            ],
          ],
        ),
      ),
    );
  }
}

class _EquivalencesCard extends StatelessWidget {
  final List<EquivalenceProposal> proposals;
  final void Function(EquivalenceKind kind, String listCode, String planCode) onChoose;

  const _EquivalencesCard({required this.proposals, required this.onChoose});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shown = proposals
        .where((p) => !(p.origin == EquivalenceOrigin.inferred && p.isIdentity))
        .toList()
      ..sort((a, b) => (a.needsUser ? 0 : 1).compareTo(b.needsUser ? 0 : 1));
    final same = proposals.length - shown.length;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text('Equivalencias con el plan', style: theme.textTheme.titleMedium),
            ),
            for (final p in shown) _EquivalenceTile(proposal: p, onChoose: onChoose),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                '$same códigos son iguales en el listado y en el plan.',
                style: theme.textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EquivalenceTile extends StatelessWidget {
  final EquivalenceProposal proposal;
  final void Function(EquivalenceKind kind, String listCode, String planCode) onChoose;

  const _EquivalenceTile({required this.proposal, required this.onChoose});

  String get _origin {
    final p = proposal;
    final seen = p.observed.entries.map((e) => '${e.key} (${e.value})').join(', ');
    switch (p.origin) {
      case EquivalenceOrigin.inferred:
        return p.evidence == 1
            ? 'Propuesta: 1 contenedor está en el listado y en el plan.'
            : 'Propuesta: ${p.evidence} contenedores están en el listado y en el plan.';
      case EquivalenceOrigin.saved:
        return p.contradicted
            ? 'Guardada en este dispositivo, pero el plan dice $seen.'
            : 'Guardada en este dispositivo.';
      case EquivalenceOrigin.chosen:
        return p.contradicted ? 'Elegida por ti; el plan dice $seen.' : 'Elegida por ti.';
      case EquivalenceOrigin.pending:
        return p.observed.length > 1
            ? 'Los contenedores no coinciden: $seen. Elige el código del plan.'
            : 'Ningún contenedor de ${p.listCode} está en el listado y en el plan '
                '(${p.rows} filas). Elige su código en el plan.';
    }
  }

  Future<void> _edit(BuildContext context) async {
    final controller = TextEditingController(text: proposal.planCode ?? '');
    final code = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${proposal.kind.label} ${proposal.listCode} en el plan'),
        content: TextField(
          key: const ValueKey('equivalence-field'),
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.characters,
          decoration: const InputDecoration(labelText: 'Código del plan'),
          onSubmitted: (value) => Navigator.pop(context, value),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          FilledButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: const Text('Aceptar')),
        ],
      ),
    );
    controller.dispose();
    if (code != null && code.trim().isNotEmpty) {
      onChoose(proposal.kind, proposal.listCode, code);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final p = proposal;
    return Padding(
      key: ValueKey('equivalence-${p.kind.wire}-${p.listCode}'),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(p.needsUser ? Icons.help_outline : Icons.swap_horiz,
                  size: 20, color: p.needsUser ? scheme.error : scheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text('${p.kind.label} ${p.listCode} → ${p.planCode ?? '?'}',
                    style: Theme.of(context).textTheme.titleSmall),
              ),
              IconButton(
                tooltip: 'Corregir ${p.listCode}',
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => _edit(context),
              ),
            ],
          ),
          Text(_origin, style: Theme.of(context).textTheme.bodySmall),
          if (p.needsUser)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  for (final candidate in p.candidates)
                    ActionChip(
                      key: ValueKey('equivalence-choice-${p.listCode}-$candidate'),
                      label: Text(candidate),
                      onPressed: () => onChoose(p.kind, p.listCode, candidate),
                    ),
                  ActionChip(
                    label: const Text('Otro código…'),
                    onPressed: () => _edit(context),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _CrossCheckCard extends StatelessWidget {
  final ExportListCrossCheck check;
  const _CrossCheckCard({required this.check});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final fulls = check.matches.length + check.fullsNotInPlan.length;
    final empties = check.emptiesInGroups + check.emptiesWithoutGroup.length;
    Widget status(bool ok, String text, {Key? key}) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(ok ? Icons.check_circle_outline : Icons.warning_amber,
                  size: 18, color: ok ? scheme.primary : scheme.error),
              const SizedBox(width: 8),
              Expanded(child: Text(text, key: key)),
            ],
          ),
        );
    Widget section(String title, Iterable<String> items) => ExpansionTile(
          tilePadding: EdgeInsets.zero,
          title: Text(title, style: TextStyle(color: scheme.error)),
          children: [
            for (final item in items)
              Align(alignment: Alignment.centerLeft, child: Text(item)),
          ],
        );
    final weightTons = check.weightDifferenceKg / 1000;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cruce con el plan de ${check.portOfCall}', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            status(check.fullsNotInPlan.isEmpty && check.matchesWithDifferences.isEmpty,
                '${check.matches.length} de $fulls llenos cruzan con el plan',
                key: const ValueKey('cross-fulls')),
            status(check.planNotInList.isEmpty,
                check.planNotInList.length == 1
                    ? '1 contenedor del plan no está en el listado'
                    : '${check.planNotInList.length} contenedores del plan no están en el listado',
                key: const ValueKey('cross-plan-missing')),
            status(check.emptiesWithoutGroup.isEmpty,
                '${check.emptiesInGroups} de $empties vacíos en ${check.groups.length} grupos de reservas',
                key: const ValueKey('cross-empties')),
            const SizedBox(height: 8),
            for (final g in check.groups)
              status(
                g.balanced,
                '${g.type} · ${g.pod} · ${g.line}: ${_count(g.empties.length, 'vacío', 'vacíos')}, '
                '${_count(g.planCells, 'celda', 'celdas')}'
                '${g.numberedEmpties.isEmpty ? '' : ' (${g.numberedEmpties.length} ya con número en el plan)'}',
              ),
            if (check.fullsNotInPlan.isNotEmpty)
              section('Llenos del listado que no están en el plan (${check.fullsNotInPlan.length})',
                  check.fullsNotInPlan.map((r) => 'OR ${r.order} · ${r.containerId}')),
            if (check.planNotInList.isNotEmpty)
              section('Del plan, no están en el listado (${check.planNotInList.length})',
                  check.planNotInList.map((c) =>
                      '${c.containerId} · ${c.stowagePosition?.toIsoCode() ?? 'sin posición'}')),
            if (check.emptiesWithoutGroup.isNotEmpty)
              section('Vacíos sin grupo (${check.emptiesWithoutGroup.length})',
                  check.emptiesWithoutGroup
                      .map((r) => 'OR ${r.order} · ${r.containerId} · ${r.type} ${r.pod} ${r.line}')),
            if (check.matchesWithDifferences.isNotEmpty)
              section('Llenos con datos distintos (${check.matchesWithDifferences.length})',
                  check.matchesWithDifferences.map(
                      (m) => 'OR ${m.row.order} · ${m.row.containerId}: ${m.differences.join('; ')}')),
            if (check.dangerousGoods.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Peligrosas', style: theme.textTheme.titleSmall),
              for (final notice in check.dangerousGoods)
                status(false, notice.message, key: ValueKey('dg-${notice.row.order}')),
            ],
            if (check.weightDifferences > 0) ...[
              const SizedBox(height: 8),
              Text(
                '${check.weightDifferences} llenos con VGM distinto del plan: el plan suma '
                '${weightTons.abs().toStringAsFixed(1)} t '
                '${weightTons < 0 ? 'menos' : 'más'} que el listado. '
                'Se guarda el VGM del listado.',
                key: const ValueKey('cross-weight'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RowsCard extends StatelessWidget {
  final ExportList list;
  const _RowsCard({required this.list});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: ExpansionTile(
        key: const ValueKey('export-list-rows'),
        title: Text('Filas del listado (${list.rows.length})'),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          for (final r in list.rows)
            Padding(
              key: ValueKey('export-row-${r.order}'),
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('OR ${r.order} · ${r.containerId} · ${r.isFull ? 'lleno' : 'vacío'}',
                      style: theme.textTheme.titleSmall),
                  Text('${r.type} · ${r.pod} · ${r.line}'
                      '${r.type != r.listType || r.pod != r.listPod || r.line != r.listLine ? ' (listado: ${r.listType} · ${r.listPod} · ${r.listLine})' : ''}'
                      ' · ${r.agency ?? 'sin agencia'}'),
                  Text([
                    if (r.vgmKg != null) 'VGM ${formatKg(r.vgmKg!)} kg',
                    'tara ${formatKg(r.tareKg)} kg',
                    if (r.netKg != null) 'neto ${formatKg(r.netKg!)} kg',
                  ].join(' · ')),
                  if (r.isDangerous)
                    Text(
                      [
                        if (r.imdgClass != null) 'Clase ${r.imdgClass}',
                        if (r.unNumbers.isNotEmpty) 'UN ${r.unNumbers.join(', ')}',
                      ].join(' · '),
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                  if (r.hour != null || r.seal != null)
                    Text([
                      if (r.hour != null) 'Hora ${r.hour}',
                      if (r.seal != null) 'Marchamo ${r.seal}',
                    ].join(' · ')),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
