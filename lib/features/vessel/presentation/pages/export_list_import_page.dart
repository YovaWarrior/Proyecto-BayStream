import 'package:flutter/material.dart';
import '../../../../core/design/design.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/entities.dart';
import '../../domain/services/export_list_cross_checker.dart';
import '../providers/export_list_providers.dart';
import '../providers/vessel_providers.dart';
import '../widgets/avisos_del_viaje.dart';
import '../../../../core/utils/voyage_number.dart';

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
    // Con un listado leído y sin confirmar, sus dos botones van al pie fijo
    // de la página (`persistentFooterButtons`), siempre a la vista: al final
    // de la lista, el aviso flotante «Archivo … cargado correctamente» de
    // hace un momento tapaba «Confirmar e importar» (10.29, H2). Los avisos
    // flotan por encima del pie fijo.
    List<Widget>? pie;
    if (plan == null || plan.portOfCall == null) {
      body = const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
              'No hay un plan de carga confirmado: abre primero el plan de carga '
              '(BAPLIE) y confirma la escala.',
              textAlign: TextAlign.center),
        ),
      );
    } else {
      final list = state.normalized;
      body = ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('${plan.vessel.name} · ${voyageNumberLabel(plan.voyageNumber)} · escala ${plan.portOfCall}',
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
              icon: const Icon(BsIconos.listadoAgencia),
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
              conflicts: state.conflicts,
              onChoose: notifier.choose,
              onUndeclare: (listCode, planCode) =>
                  notifier.undeclare(planCode, listCode: listCode),
            ),
            // T-147, entrega 2 (P4): «también llena».
            if (state.orphans.isNotEmpty)
              _OrphansCard(
                orphans: state.orphans,
                proposals: state.proposals,
                onDeclare: notifier.declare,
              ),
            if (state.crossCheck != null) _CrossCheckCard(check: state.crossCheck!),
            if (state.impact != null) _RevisionImpactCard(impact: state.impact!),
            _RowsCard(list: list),
            const SizedBox(height: 8),
            if (state.hasPending)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'Falta elegir ${state.proposals.where((p) => p.needsUser).length} '
                  'equivalencias antes de importar. Elige una para cada código '
                  'pendiente.',
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ),
            // 10.160, cambio 4: un código del plan, un solo tipo del listado.
            if (state.conflicts.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'No se puede importar: '
                  '${state.conflicts.map((c) => c.message).join(' ')}',
                  key: const ValueKey('export-list-family-conflicts'),
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ),
          ],
          // T-147, entrega 2 (P3): lo guardado en este dispositivo, a la vista.
          if (state.device != null && !state.device!.isEmpty)
            _SavedEquivalencesCard(
              device: state.device!,
              busy: state.busy,
              onRemove: notifier.removeSaved,
              onRemovePorts: notifier.removeSavedPorts,
              onRemoveAll: notifier.removeAllSaved,
            ),
        ],
      );
      if (list != null) {
        pie = [
          OutlinedButton(
            onPressed: state.busy ? null : notifier.discard,
            child: const Text('Descartar'),
          ),
          FilledButton.icon(
            key: const ValueKey('export-list-confirm'),
            onPressed: state.busy || !state.canConfirm
                ? null
                : () async {
                    final error = await notifier.confirm();
                    if (!context.mounted) return;
                    // Puede seguir en pantalla al volver al plano: sabe
                    // su lugar (10.33).
                    ScaffoldMessenger.of(context).showSnackBar(avisoDelViaje(
                        texto: error ?? 'Listado importado.',
                        corto: error == null
                            ? null
                            : 'No se importó el listado.'));
                  },
            icon: const Icon(Icons.check),
            label: const Text('Confirmar e importar'),
          ),
        ];
      }
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Listado de la agencia')),
      body: body,
      persistentFooterButtons: pie,
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

/// «0100282» → «010-02-82».
String _cell(String? position) => position == null
    ? 'sin posición'
    : position.length == 7
        ? '${position.substring(0, 3)}-${position.substring(3, 5)}-${position.substring(5)}'
        : position;

/// «12», «12 y 31», «12, 31 y 40».
String _joinY(Iterable<Object> items) {
  final list = [for (final item in items) '$item'];
  return list.length <= 1
      ? list.join()
      : '${list.sublist(0, list.length - 1).join(', ')} y ${list.last}';
}

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
    // T-147, entrega 2 (P1): las filas que el listado cancela no se cargan.
    final cancelled = list.cancelledRows.toList();
    final loading = list.loadRows.toList();
    final unknown = list.unrecognizedNotes;
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
              cancelled.isEmpty
                  ? '${list.rows.length} filas en ${agencies.length} agencias · '
                      '${list.fulls.length} llenos · ${list.empties.length} vacíos'
                  : '${list.rows.length} filas en ${agencies.length} agencias · '
                      '${loading.length} para cargar: '
                      '${_count(loading.where((r) => r.isFull).length, 'lleno', 'llenos')} y '
                      '${_count(loading.where((r) => r.isEmpty).length, 'vacío', 'vacíos')}',
              key: const ValueKey('export-list-counts'),
              style: theme.textTheme.titleMedium,
            ),
            if (cancelled.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                '${_count(cancelled.length, 'cancelada', 'canceladas')} en el '
                'listado, que no se ${cancelled.length == 1 ? 'carga' : 'cargan'}: '
                '${_count(cancelled.where((r) => r.isFull).length, 'lleno', 'llenos')} y '
                '${_count(cancelled.where((r) => r.isEmpty).length, 'vacío', 'vacíos')}',
                key: const ValueKey('export-list-cancelled'),
                style: theme.textTheme.titleSmall,
              ),
              Text(
                [
                  for (final note in list.cancelNotes.entries)
                    '${note.key} ${note.value}'
                ].join(' · '),
                key: const ValueKey('export-list-cancel-notes'),
              ),
              ExpansionTile(
                key: const ValueKey('export-list-cancelled-rows'),
                tilePadding: EdgeInsets.zero,
                title: Text('Canceladas en el listado (${cancelled.length})'),
                children: [
                  for (final r in cancelled)
                    Align(
                        alignment: Alignment.centerLeft,
                        child: Text('OR ${r.order} · ${r.containerId} · '
                            '${r.isFull ? 'lleno' : 'vacío'} · «${r.cancelNote}»')),
                ],
              ),
            ],
            // D1: una nota que no es una cancelación ni parece un marchamo.
            for (final note in unknown.entries)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '${_count(note.value.length, 'fila trae', 'filas traen')} en '
                  'MARCHAMO una nota que no se reconoce: «${note.key}» '
                  '(OR ${_joinY(note.value)}). '
                  '${note.value.length == 1 ? 'Se carga. Si no se carga' : 'Se cargan. Si no se cargan'} '
                  'en este buque, pide a la agencia que diga CANCELADO y vuelve '
                  'a importar el listado.',
                  key: ValueKey('export-list-unknown-note-${note.key}'),
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ),
            const SizedBox(height: 4),
            for (final entry in agencies.entries) Text('${entry.key}: ${entry.value}'),
            // T-147 (10.151, hallazgo 3): con POT y POD distintos, el cruce
            // usa el POT. Se dice aquí, antes de las equivalencias.
            if (list.rows.any((r) => r.potDiffersFromPod)) ...[
              const SizedBox(height: 8),
              Text(
                '${_count(list.rows.where((r) => r.potDiffersFromPod).length, 'fila trae', 'filas traen')} '
                'POT y POD distintos: el cruce con el plan usa el POT, donde '
                'el contenedor baja del buque.',
                key: const ValueKey('export-list-pot'),
              ),
            ],
            const SizedBox(height: 8),
            if (list.issues.isEmpty)
              const Text('Todas las filas se entendieron.',
                  key: ValueKey('export-list-issues'))
            else ...[
              Text(list.issues.length == 1 ? '1 fila sin entender:' : '${list.issues.length} filas sin entender:',
                  key: const ValueKey('export-list-issues'),
                  style: TextStyle(color: theme.colorScheme.error)),
              // T-112: el aviso guardado no cambia; la acción se agrega al mostrarlo.
              for (final issue in list.issues)
                Text('Fila ${issue.sheetRow}: ${issue.message} Corrige esa fila en '
                    'el Excel y vuelve a importarlo.'),
            ],
          ],
        ),
      ),
    );
  }
}

class _EquivalencesCard extends StatelessWidget {
  final List<EquivalenceProposal> proposals;
  final List<TypeFamilyConflict> conflicts;
  final void Function(EquivalenceKind kind, String listCode, String planCode) onChoose;
  final void Function(String listCode, String planCode) onUndeclare;

  const _EquivalencesCard(
      {required this.proposals,
      this.conflicts = const [],
      required this.onChoose,
      required this.onUndeclare});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Una identidad deducida no se enseña, salvo que tenga algo que decir:
    // un «también llena» o algo guardado que no se usó (T-147, entrega 2).
    final shown = proposals
        .where((p) => !(p.origin == EquivalenceOrigin.inferred &&
            p.isIdentity &&
            p.also.isEmpty &&
            p.discarded == null))
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
            for (final conflict in conflicts)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Text(conflict.message,
                    key: ValueKey('family-conflict-${conflict.code}'),
                    style: TextStyle(color: theme.colorScheme.error)),
              ),
            for (final p in shown)
              _EquivalenceTile(
                  proposal: p, onChoose: onChoose, onUndeclare: onUndeclare),
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
  final void Function(String listCode, String planCode) onUndeclare;

  const _EquivalenceTile(
      {required this.proposal,
      required this.onChoose,
      required this.onUndeclare});

  /// T-147, entrega 2 (P3) · Lo que este dispositivo tenía guardado y no se
  /// usó, con el porqué.
  String? get _discarded {
    final p = proposal;
    final saved = p.discarded;
    if (saved == null) return null;
    final String why;
    if (p.observed.isNotEmpty) {
      why = 'el plan dice ${_joinY([
            for (final e in p.observed.entries)
              '${e.key} (${_count(e.value, 'contenedor', 'contenedores')})'
          ])}';
    } else if (p.origin == EquivalenceOrigin.previous) {
      why = 'la revisión anterior de este listado usa ${p.planCode}';
    } else {
      why = 'el plan no carga $saved en esta escala';
    }
    return 'En este dispositivo estaba guardada ${p.listCode} → $saved, y $why: '
        'no se usó.';
  }

  String get _origin {
    final p = proposal;
    final seen = p.observed.entries.map((e) => '${e.key} (${e.value})').join(', ');
    switch (p.origin) {
      case EquivalenceOrigin.inferred:
        // T-147, entrega 2 (P4, D10): el respaldo repartido se propone con
        // el código más repetido como principal, y el tipo llena todos.
        if (p.observed.length > 1) {
          final codes = p.observed.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));
          final first = codes.first;
          return 'Propuesta: '
              '${first.value == 1 ? '1 contenedor va' : '${first.value} contenedores van'} '
              'a ${_joinY([first.key, for (final e in codes.skip(1)) '${e.value} a ${e.key}'])}. '
              '${p.listCode} llena ${codes.length == 2 ? 'los dos' : 'todos'}.';
        }
        return p.evidence == 1
            ? 'Propuesta: 1 contenedor está en el listado y en el plan.'
            : 'Propuesta: ${p.evidence} contenedores están en el listado y en el plan.';
      case EquivalenceOrigin.previous:
        return 'De la revisión anterior de este listado.';
      case EquivalenceOrigin.saved:
        return p.contradicted
            ? 'Guardada en este dispositivo, pero el plan dice $seen.'
            : 'Guardada en este dispositivo.';
      case EquivalenceOrigin.chosen:
        return p.contradicted ? 'Elegida por ti; el plan dice $seen.' : 'Elegida por ti.';
      case EquivalenceOrigin.samePlanCode:
        // T-147 (10.151, regla 5): la identidad se propone, y se dice por qué.
        return 'Propuesta: el plan carga ${p.planCode} en esta escala con ese '
            'mismo código. Ningún contenedor de ${p.listCode} está en el '
            'listado y en el plan (${p.rows} ${p.rows == 1 ? 'fila' : 'filas'}).';
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
          if (_discarded != null)
            Text(_discarded!,
                key: ValueKey('equivalence-discarded-${p.kind.wire}-${p.listCode}'),
                style: Theme.of(context).textTheme.bodySmall),
          // T-147, entrega 2 (P4): los otros códigos del plan que este tipo
          // llena. Cada uno se quita con su ficha.
          if (p.also.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Wrap(
                spacing: 8,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const Text('También llena:'),
                  for (final code in p.also)
                    InputChip(
                      key: ValueKey('also-${p.listCode}-$code'),
                      label: Text(code),
                      deleteButtonTooltipMessage:
                          'Quitar $code de ${p.listCode}',
                      onDeleted: () => onUndeclare(p.listCode, code),
                    ),
                ],
              ),
            ),
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

/// T-147, entrega 2 (P4; hallazgo 6 de la 10.151) · «También llena»: las
/// celdas reservadas de la escala cuyo código ISO no llena ningún tipo del
/// listado. La oficina dice qué tipo las llena; lo que no declare sigue
/// pidiendo motivo al cargar, como hasta la 1.0.2. No detiene la importación.
class _OrphansCard extends StatefulWidget {
  final List<OrphanTypeCode> orphans;
  final List<EquivalenceProposal> proposals;
  final void Function(String listCode, String planCode) onDeclare;

  const _OrphansCard(
      {required this.orphans, required this.proposals, required this.onDeclare});

  @override
  State<_OrphansCard> createState() => _OrphansCardState();
}

class _OrphansCardState extends State<_OrphansCard> {
  /// Los códigos a los que la oficina dijo «No: piden motivo».
  final _dismissed = <String>{};

  Future<void> _other(OrphanTypeCode orphan) async {
    final types = [
      for (final p in widget.proposals)
        if (p.kind == EquivalenceKind.type && p.planCode != null) p
    ];
    final chosen = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text('¿Qué tipo del listado llena ${orphan.code}?'),
        children: [
          for (final p in types)
            SimpleDialogOption(
              key: ValueKey('orphan-type-${orphan.code}-${p.listCode}'),
              onPressed: () => Navigator.pop(context, p.listCode),
              child: Text(p.isIdentity
                  ? p.listCode
                  : '${p.listCode} (${p.planCode})'),
            ),
        ],
      ),
    );
    if (chosen != null) widget.onDeclare(chosen, orphan.code);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cells = widget.orphans.fold<int>(0, (sum, o) => sum + o.cells);
    return Card(
      key: const ValueKey('orphan-codes'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                'Celdas reservadas que ningún tipo del listado llena ($cells)',
                style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
                'Al cargar piden motivo, salvo que digas qué tipo del listado '
                'las llena. No detiene la importación.',
                style: theme.textTheme.bodySmall),
            for (final orphan in widget.orphans)
              Padding(
                key: ValueKey('orphan-${orphan.code}'),
                padding: const EdgeInsets.only(top: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        '${orphan.code} · ${_count(orphan.cells, 'celda', 'celdas')}'
                        '${_dismissed.contains(orphan.code) ? ': ${orphan.cells == 1 ? 'pide' : 'piden'} motivo al cargar.' : orphan.suggestedListCode == null ? '. Ningún tipo del listado se le parece.' : '. ¿${orphan.cells == 1 ? 'La' : 'Las'} llena ${orphan.suggestedListCode}${orphan.suggestedListCode == orphan.suggestedPlanCode ? '' : ' (${orphan.suggestedPlanCode})'}?'}',
                        style: theme.textTheme.titleSmall),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        if (orphan.suggestedListCode != null &&
                            !_dismissed.contains(orphan.code))
                          ActionChip(
                            key: ValueKey('orphan-yes-${orphan.code}'),
                            label: const Text('Sí'),
                            onPressed: () => widget.onDeclare(
                                orphan.suggestedListCode!, orphan.code),
                          ),
                        ActionChip(
                          key: ValueKey('orphan-other-${orphan.code}'),
                          label: const Text('Otro tipo…'),
                          onPressed: () => _other(orphan),
                        ),
                        if (!_dismissed.contains(orphan.code))
                          ActionChip(
                            key: ValueKey('orphan-no-${orphan.code}'),
                            label: const Text('No: piden motivo'),
                            onPressed: () =>
                                setState(() => _dismissed.add(orphan.code)),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// T-147, entrega 2 (P3; hallazgo 3 de la 10.85) · Lo que este dispositivo
/// guarda de importaciones anteriores, a la vista y con cómo quitarlo. Hasta
/// la 1.0.2 no había dónde verlo. Los puertos ya no se usan: quedan de
/// versiones anteriores y se quitan de una vez.
class _SavedEquivalencesCard extends StatelessWidget {
  final CodeEquivalences device;
  final bool busy;
  final void Function(EquivalenceKind kind, String listCode) onRemove;
  final VoidCallback onRemovePorts;
  final VoidCallback onRemoveAll;

  const _SavedEquivalencesCard(
      {required this.device,
      required this.busy,
      required this.onRemove,
      required this.onRemovePorts,
      required this.onRemoveAll});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final used = [
      for (final kind in [EquivalenceKind.type, EquivalenceKind.line])
        for (final entry in device.of(kind).entries.toList()
          ..sort((a, b) => a.key.compareTo(b.key)))
          (kind: kind, from: entry.key, to: entry.value)
    ];
    final ports = device.of(EquivalenceKind.port).length;
    return Card(
      child: ExpansionTile(
        key: const ValueKey('saved-equivalences'),
        title: Text(
            'Equivalencias guardadas en este dispositivo (${used.length})'),
        subtitle: Text(ports == 0
            ? 'Se usan en el próximo listado, si el plan no dice otra cosa.'
            : 'Y ${_count(ports, 'de puerto, que ya no se usa', 'de puerto, que ya no se usan')}.'),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final e in used)
            Row(
              children: [
                Expanded(
                    child: Text('${e.kind.label} ${e.from} → ${e.to}',
                        key: ValueKey('saved-${e.kind.wire}-${e.from}'))),
                TextButton(
                  key: ValueKey('saved-remove-${e.kind.wire}-${e.from}'),
                  onPressed: busy ? null : () => onRemove(e.kind, e.from),
                  child: const Text('Quitar'),
                ),
              ],
            ),
          if (ports > 0)
            Row(
              children: [
                Expanded(
                    child: Text(
                        'De puerto, de versiones anteriores ($ports): ya no se '
                        '${ports == 1 ? 'usa' : 'usan'}.',
                        key: const ValueKey('saved-ports'))),
                TextButton(
                  key: const ValueKey('saved-remove-ports'),
                  onPressed: busy ? null : onRemovePorts,
                  child: Text(ports == 1 ? 'Quitarla' : 'Quitar las $ports'),
                ),
              ],
            ),
          const SizedBox(height: 8),
          Text('Quitar una equivalencia no cambia ningún listado ya importado.',
              style: theme.textTheme.bodySmall),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: TextButton(
              key: const ValueKey('saved-remove-all'),
              onPressed: busy ? null : onRemoveAll,
              child: const Text('Quitar todas'),
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
                // T-147, entrega 2 (P4): con «también llena», de qué códigos.
                '${g.cellsByCode.length < 2 ? '' : ' (${_joinY([for (final e in g.cellsByCode.entries) '${e.value} de ${e.key}'])})'}'
                '${g.numberedEmpties.isEmpty ? '' : ' (${g.numberedEmpties.length} ya con número en el plan)'}',
              ),
            // T-147, entrega 2 (P1): las canceladas no entran en el cruce.
            if (check.cancelled.isNotEmpty) ...[
              const SizedBox(height: 8),
              status(
                  check.cancelledInPlan.isEmpty,
                  check.cancelledInPlan.isEmpty
                      ? '${_count(check.cancelled.length, 'cancelada', 'canceladas')} '
                          'en el listado: el plan no carga ninguna'
                      : '${_count(check.cancelledInPlan.length, 'cancelada', 'canceladas')} '
                          'en el listado que el plan todavía carga',
                  key: const ValueKey('cross-cancelled')),
            ],
            if (check.cancelledInPlan.isNotEmpty) ...[
              section(
                  'Canceladas en el listado que el plan todavía carga '
                  '(${check.cancelledInPlan.length})',
                  check.cancelledInPlan.map((m) =>
                      'OR ${m.row.order} · ${m.row.containerId} · '
                      '${_cell(m.container.stowagePosition?.toIsoCode())}')),
              const Text('Cancela su embarque desde el detalle de la celda o '
                  'pide el plan corregido. Si alguna sube, el muelle la '
                  'registra con motivo.'),
            ],
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

/// T-127 (10.78) · Lo ya operado con el listado nuevo: antes de confirmar, el
/// cruce dice con números cuántos contenedores ya cargados no están en el
/// listado nuevo y cuántos vacíos asignados cambian de grupo. Los movimientos
/// no se pierden ni cambian: se vuelven a leer con el listado nuevo.
class _RevisionImpactCard extends StatelessWidget {
  final ExportListRevisionImpact impact;
  const _RevisionImpactCard({required this.impact});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
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
    final missing = impact.loadedNotListed.length;
    final regrouped = impact.emptiesRegrouped.length;
    final cancelled = impact.loadedNowCancelled.length;
    return Card(
      key: const ValueKey('revision-impact'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Lo ya operado con el listado nuevo',
                style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
                'Los movimientos registrados no se pierden ni cambian: se '
                'vuelven a leer con el listado nuevo.',
                style: theme.textTheme.bodySmall),
            const SizedBox(height: 8),
            status(
                missing == 0,
                missing == 1
                    ? '1 contenedor ya cargado no está en el listado nuevo'
                    : '$missing contenedores ya cargados no están en el listado nuevo',
                key: const ValueKey('revision-loaded-missing')),
            status(
                regrouped == 0,
                regrouped == 1
                    ? '1 vacío asignado cambia de grupo'
                    : '$regrouped vacíos asignados cambian de grupo',
                key: const ValueKey('revision-empties-regrouped')),
            // T-147, entrega 2 (P1): la carga no se toca; queda como conflicto.
            if (cancelled > 0)
              status(
                  false,
                  cancelled == 1
                      ? '1 contenedor ya cargado queda cancelado en el listado nuevo'
                      : '$cancelled contenedores ya cargados quedan cancelados en el listado nuevo',
                  key: const ValueKey('revision-loaded-cancelled')),
            if (cancelled > 0)
              section(
                  'Ya cargados que el listado nuevo cancela ($cancelled)',
                  impact.loadedNowCancelled),
            if (missing > 0)
              section('Ya cargados sin fila en el listado nuevo ($missing)',
                  impact.loadedNotListed),
            if (regrouped > 0)
              section('Vacíos asignados que cambian de grupo ($regrouped)',
                  impact.emptiesRegrouped),
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
                      '${r.type != r.listType || r.pod != r.listCrossPort || r.line != r.listLine ? ' (listado: ${r.listType} · ${r.listCrossPort} · ${r.listLine})' : ''}'
                      ' · ${r.agency ?? 'sin agencia'}'),
                  // T-147: el POD es el destino final cuando la fila trae
                  // otro POT; se enseñan los dos, como vienen en el Excel.
                  if (r.potDiffersFromPod)
                    Text('POT ${r.listPot} · POD ${r.listPod}'),
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
                  // T-147, entrega 2 (P1): la nota de la agencia no es un
                  // marchamo.
                  if (r.cancelled)
                    Text('Cancelada en el listado: «${r.cancelNote}»',
                        style: TextStyle(color: theme.colorScheme.error)),
                  if (r.hour != null || (r.seal != null && !r.cancelled))
                    Text([
                      if (r.hour != null) 'Hora ${r.hour}',
                      if (r.seal != null && !r.cancelled) 'Marchamo ${r.seal}',
                    ].join(' · ')),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
