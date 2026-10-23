import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../../../core/design/design.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/entities.dart';
import '../../domain/services/voyage_comparison.dart';
import '../formatters/operation_text.dart';
import '../formatters/vessel_error_message.dart';
import '../providers/vessel_providers.dart';
import '../widgets/voyage_summary_card.dart' show smdg15Notice;
import '../../../../core/utils/voyage_number.dart';

/// T-96 · El archivo que se compara: nombre y texto, nada más.
typedef ComparisonFile = ({String name, String content});

/// El selector del segundo archivo. Es un proveedor para que el banco de
/// aceptación entregue un archivo sin el diálogo del sistema; el producto usa
/// el mismo selector que «Cargar archivo BAPLIE».
final comparisonFilePickerProvider =
    Provider<Future<ComparisonFile?> Function()>((ref) => _pickWithDialog);

Future<ComparisonFile?> _pickWithDialog() async {
  final result = await FilePicker.platform.pickFiles(
    type: FileType.any,
    withData: true,
    dialogTitle: 'Comparar con otro BAPLIE',
  );
  if (result == null || result.files.isEmpty) return null;
  final file = result.files.first;
  return (
    name: file.name,
    content: file.bytes == null ? '' : String.fromCharCodes(file.bytes!),
  );
}

/// Lee el segundo archivo con el lector, **sin el flujo de carga**: no
/// confirma identidad ni perfil, no publica, no entra a Recientes ni se guarda.
Future<void> compareWithAnotherBaplie(
    BuildContext context, WidgetRef ref, VesselVoyage open) async {
  void notice(String message) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(message)));
  try {
    final file = await ref.read(comparisonFilePickerProvider)();
    if (file == null || !context.mounted) return;
    if (file.content.isEmpty) {
      notice('Archivo «${file.name}»: $notBaplieFileMessage');
      return;
    }
    final parsed =
        await ref.read(vesselRepositoryProvider).parseBaplieFile(file.content);
    if (!context.mounted) return;
    parsed.fold(
        (failure) =>
            notice('Archivo «${file.name}»: '
                '${vesselFailureMessage(failure, 'leer el archivo')}'),
        (second) => Navigator.of(context).push(MaterialPageRoute<void>(
            builder: (_) => VoyageComparisonPage(
                first: open,
                second: second,
                firstLabel: 'Viaje abierto',
                secondLabel: file.name))));
  } catch (error, stack) {
    if (context.mounted) {
      notice(vesselErrorMessage(error, stack, 'comparar los dos archivos'));
    }
  }
}

/// Las tres secciones: cada una con color, ícono y rótulo (RNF-003).
enum _Section { discharged, loaded, permanent }

class VoyageComparisonPage extends StatefulWidget {
  final VesselVoyage first;
  final VesselVoyage second;
  final String firstLabel;
  final String secondLabel;

  const VoyageComparisonPage({
    super.key,
    required this.first,
    required this.second,
    required this.firstLabel,
    required this.secondLabel,
  });

  @override
  State<VoyageComparisonPage> createState() => _VoyageComparisonPageState();
}

class _VoyageComparisonPageState extends State<VoyageComparisonPage> {
  late final VoyageComparison _comparison =
      VoyageComparison.compare(widget.first, widget.second);
  bool _onlyChanged = true;

  @override
  Widget build(BuildContext context) {
    final c = _comparison;
    // Pestaña con ícono y rótulo, del alto que pide la letra del dispositivo.
    final tabHeight =
        24 + 10 + MediaQuery.textScalerOf(context).scale(14) * 1.5 + 12;
    return DefaultTabController(
      length: 3,
      initialIndex: 2,
      child: Scaffold(
        appBar: AppBar(title: const Text('Comparar BAPLIE')),
        body: NestedScrollView(
          headerSliverBuilder: (context, _) => [
            SliverToBoxAdapter(child: _header(context, c)),
            SliverPersistentHeader(
                pinned: true,
                delegate: _TabsHeader(_tabs(context, c, tabHeight), tabHeight)),
          ],
          body: TabBarView(children: [
            _units(context, _Section.discharged, c.discharged),
            _units(context, _Section.loaded, c.loaded),
            _permanent(context, c),
          ]),
        ),
      ),
    );
  }

  Widget _header(BuildContext context, VoyageComparison c) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final changed = c.changesByField.entries.where((e) => e.value > 0);
    Widget warning(String message, Key key) => Container(
          key: key,
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: scheme.errorContainer,
              borderRadius: BorderRadius.circular(12)),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(Icons.warning_amber, color: scheme.onErrorContainer),
            const SizedBox(width: 8),
            Expanded(
                child: Text(message,
                    style: text.bodyMedium
                        ?.copyWith(color: scheme.onErrorContainer))),
          ]),
        );
    String side(String label, VesselVoyage v) =>
        '$label: ${v.vessel.name} · ${voyageNumberLabel(v.voyageNumber)} · '
        '${operationCount(v.totalContainers, 'contenedor', 'contenedores')}';
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (c.vesselNotice != null)
          warning(c.vesselNotice!, const ValueKey('comparison-vessel-notice')),
        for (final (label, v) in [
          (widget.firstLabel, widget.first),
          (widget.secondLabel, widget.second)
        ])
          if (v.metadata?.readWithV2Rules ?? false)
            warning('$label: $smdg15Notice',
                ValueKey('comparison-smdg15-$label')),
        Text(side('Primero', widget.first), style: text.bodyMedium),
        Text('(${widget.firstLabel})', style: text.bodySmall),
        const SizedBox(height: 4),
        Text(side('Segundo', widget.second), style: text.bodyMedium),
        Text('(${widget.secondLabel})', style: text.bodySmall),
        const SizedBox(height: 12),
        Text(
          '${operationCount(c.discharged.length, 'descargado', 'descargados')} · '
          '${operationCount(c.loaded.length, 'cargado', 'cargados')} · '
          '${operationCount(c.permanent.length, 'permanente', 'permanentes')}, '
          '${c.withChanges} con cambios',
          key: const ValueKey('comparison-counts'),
          style: text.titleMedium,
        ),
        const SizedBox(height: 4),
        Text(
          'Reservas sin número: ${c.reservedFirst} en el primero · '
          '${c.reservedSecond} en el segundo',
          key: const ValueKey('comparison-reserved'),
        ),
        if (c.duplicatesFirst.isNotEmpty || c.duplicatesSecond.isNotEmpty)
          Text(
            'Números repetidos, sin clasificar: '
            '${_duplicates(c.duplicatesFirst)} en el primero · '
            '${_duplicates(c.duplicatesSecond)} en el segundo',
            key: const ValueKey('comparison-duplicates'),
          ),
        const SizedBox(height: 8),
        Text(
          changed.isEmpty
              ? 'Ningún campo cambia en los permanentes.'
              : 'Cambios en los permanentes: '
                  '${changed.map((e) => '${e.key.label} ${e.value}').join(' · ')}',
          key: const ValueKey('comparison-fields'),
        ),
      ]),
    );
  }

  String _duplicates(Map<String, int> d) => d.isEmpty
      ? '0'
      : d.entries.map((e) => '${e.key} ×${e.value}').join(', ');

  List<Widget> _tabs(BuildContext context, VoyageComparison c, double height) => [
        for (final (section, count) in [
          (_Section.discharged, c.discharged.length),
          (_Section.loaded, c.loaded.length),
          (_Section.permanent, c.permanent.length),
        ])
          Tab(
            key: ValueKey('comparison-tab-${section.name}'),
            height: height,
            icon: Icon(_icon(section), color: _color(context, section)),
            text: '${_label(section)} ($count)',
          ),
      ];

  static IconData _icon(_Section s) => switch (s) {
        _Section.discharged => BsIconos.descarga,
        _Section.loaded => BsIconos.carga,
        _Section.permanent => Icons.sync_alt,
      };

  static String _label(_Section s) => switch (s) {
        _Section.discharged => 'Descargados',
        _Section.loaded => 'Cargados',
        _Section.permanent => 'Permanentes',
      };

  static Color _color(BuildContext context, _Section s) {
    final scheme = Theme.of(context).colorScheme;
    return switch (s) {
      _Section.discharged => scheme.error,
      _Section.loaded => scheme.primary,
      _Section.permanent => scheme.tertiary,
    };
  }

  Widget _units(
      BuildContext context, _Section section, List<ContainerUnit> units) {
    if (units.isEmpty) {
      return Center(child: Text('Ningún contenedor ${_label(section).toLowerCase()}.'));
    }
    return ListView.builder(
      key: ValueKey('comparison-list-${section.name}'),
      itemCount: units.length,
      itemBuilder: (context, i) {
        final u = units[i];
        return ListTile(
          key: ValueKey('comparison-row-${u.containerId}'),
          leading: Icon(_icon(section), color: _color(context, section),
              semanticLabel: _label(section)),
          title: Text(u.containerId),
          subtitle: Text([
            u.stowagePosition?.toIsoCode() ?? 'sin posición',
            u.isoSizeType ?? 'sin ISO',
            'POL ${u.portOfLoading ?? 'sin dato'}',
            'POD ${u.portOfDischarge ?? 'sin dato'}',
            u.effectiveWeight == null
                ? 'peso sin dato'
                : '${comparisonValue(ComparedField.weight, u.effectiveWeight)}\u00A0kg',
          ].join(' · ')),
        );
      },
    );
  }

  Widget _permanent(BuildContext context, VoyageComparison c) {
    final rows =
        _onlyChanged ? c.permanent.where((p) => p.changed).toList() : c.permanent;
    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: Align(
          alignment: Alignment.centerLeft,
          child: FilterChip(
            key: const ValueKey('comparison-only-changed'),
            label: const Text('Solo con cambios'),
            selected: _onlyChanged,
            onSelected: (value) => setState(() => _onlyChanged = value),
          ),
        ),
      ),
      Expanded(
        child: rows.isEmpty
            ? const Center(child: Text('Ningún permanente con cambios.'))
            : ListView.builder(
                key: const ValueKey('comparison-list-permanent'),
                itemCount: rows.length,
                itemBuilder: (context, i) => _permanentRow(context, rows[i]),
              ),
      ),
    ]);
  }

  Widget _permanentRow(BuildContext context, PermanentContainer p) {
    final weights = [
      for (final (label, u) in [('Primero', p.first), ('Segundo', p.second)])
        if (u.grossWeight != null &&
            u.vgmWeight != null &&
            u.grossWeight != u.vgmWeight)
          '$label: WT ${_kg(u.grossWeight!)} · VGM ${_kg(u.vgmWeight!)}\u00A0kg',
    ];
    return ListTile(
      key: ValueKey('comparison-row-${p.containerId}'),
      leading: Icon(_icon(_Section.permanent),
          color: _color(context, _Section.permanent),
          semanticLabel: _label(_Section.permanent)),
      title: Text('${p.containerId} · '
          '${p.second.stowagePosition?.toIsoCode() ?? 'sin posición'}'),
      subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (!p.changed) const Text('Sin cambios.'),
        for (final change in p.changes)
          Text(
            comparisonChangeText(change),
            key: ValueKey('comparison-change-${p.containerId}-${change.field.name}'),
          ),
        for (final line in weights) Text(line),
      ]),
    );
  }
}

/// «Peso 24 260 → 24 200 kg»: la unidad va una vez, al final, pegada a la
/// cifra para que la letra grande no la deje sola en una línea.
String comparisonChangeText(FieldChange change) =>
    '${change.field.label} ${comparisonValue(change.field, change.before)} → '
    '${comparisonValue(change.field, change.after)}'
    '${change.field == ComparedField.weight ? '\u00A0kg' : ''}';

/// Cómo se lee cada valor; `null` es «sin dato». El peso va sin unidad.
String comparisonValue(ComparedField field, Object? value) {
  if (value == null) return 'sin dato';
  return switch (field) {
    ComparedField.weight => _kg(value as double),
    ComparedField.status => value == ContainerStatus.full ? 'lleno' : 'vacío',
    _ => '$value',
  };
}

/// Kilos con separador de miles que no parte la cifra: «24 260».
String _kg(double kg) {
  final whole = kg == kg.roundToDouble();
  final text = whole ? kg.toStringAsFixed(0) : kg.toStringAsFixed(2);
  final parts = text.split('.');
  final digits = parts.first;
  final grouped = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) grouped.write('\u00A0');
    grouped.write(digits[i]);
  }
  return parts.length == 1 ? '$grouped' : '$grouped.${parts[1]}';
}

class _TabsHeader extends SliverPersistentHeaderDelegate {
  final List<Widget> tabs;
  final double tabHeight;
  _TabsHeader(this.tabs, this.tabHeight);

  // El alto de la pestaña más el indicador.
  @override
  double get minExtent => tabHeight + 2;
  @override
  double get maxExtent => tabHeight + 2;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlaps) =>
      Material(
        color: Theme.of(context).colorScheme.surface,
        child: TabBar(isScrollable: true, tabs: tabs),
      );

  @override
  bool shouldRebuild(covariant _TabsHeader old) =>
      old.tabHeight != tabHeight || old.tabs != tabs;
}
