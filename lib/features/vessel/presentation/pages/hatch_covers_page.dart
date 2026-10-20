import 'package:flutter/material.dart';
import '../../domain/entities/entities.dart';
import '../widgets/hatch_cover_diagram.dart';
import '../formatters/operation_text.dart';

/// Borrador local: cancelar no cambia el perfil; copiar se valida antes de aplicar.
class HatchCoversPage extends StatefulWidget {
  final VesselGeometry geometry;
  final Set<int> holdBays;
  final Map<int, HatchCoverDeclaration> initial;
  const HatchCoversPage(
      {super.key,
      required this.geometry,
      required this.holdBays,
      required this.initial});
  @override
  State<HatchCoversPage> createState() => _HatchCoversPageState();
}

class _HatchCoversPageState extends State<HatchCoversPage> {
  late final Map<int, HatchCoverDeclaration> _draft = {...widget.initial};
  late final List<int> _bays = widget.holdBays.toList()..sort();
  int? _bay;
  HatchCoverKind? _kind;
  int _count = 1;
  final _rows = List.generate(3, (_) => TextEditingController());
  String? _error;
  @override
  void initState() {
    super.initState();
    if (_bays.isNotEmpty) _select(_bays.first);
  }

  @override
  void dispose() {
    for (final row in _rows) {
      row.dispose();
    }
    super.dispose();
  }

  void _select(int bay) {
    _bay = bay;
    final declaration = _draft[bay];
    _kind = declaration?.kind;
    _count = declaration?.covers.length.clamp(1, 3) ?? 1;
    for (var i = 0; i < 3; i++) {
      _rows[i].text = declaration != null && i < declaration.covers.length
          ? (widget.geometry.orderedRows
              .where(declaration.covers[i].contains)
              .map((r) => r.toString().padLeft(2, '0'))).join(', ')
          : '';
    }
    _error = null;
  }

  bool _apply() {
    if (_bay == null) return true;
    if (_kind == null) {
      _draft.remove(_bay);
      return true;
    }
    final covers = <Set<int>>[];
    if (_kind != HatchCoverKind.openHold) {
      for (var i = 0;
          i < (_kind == HatchCoverKind.automatic ? 1 : _count);
          i++) {
        final tokens = _rows[i].text.trim().split(RegExp(r'[,;\s]+'));
        if (tokens.any((r) => !RegExp(r'^\d{1,2}$').hasMatch(r))) {
          setState(() => _error =
              'Tapa ${i + 1}: las filas no tienen el formato esperado; escribe filas '
              'de uno o dos dígitos separadas por coma.');
          return false;
        }
        final parsed = tokens.map(int.parse).toList();
        if (parsed.toSet().length != parsed.length) {
          setState(() => _error = 'Tapa ${i + 1}: hay una fila repetida; quítala.');
          return false;
        }
        covers.add(parsed.toSet());
      }
    }
    final declaration = HatchCoverDeclaration(kind: _kind!, covers: covers);
    final error = declaration.validate(widget.geometry,
        hasHold: widget.holdBays.contains(_bay));
    setState(() => _error = error);
    if (error != null) return false;
    _draft[_bay!] = declaration;
    return true;
  }

  Future<void> _copy() async {
    if (!_apply()) return;
    final targets = <int>{};
    final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => StatefulBuilder(
            builder: (context, update) => AlertDialog(
                  title: const Text('Copiar a otras bahías'),
                  content: SizedBox(
                      width: 320,
                      child: SingleChildScrollView(
                          child:
                              Column(mainAxisSize: MainAxisSize.min, children: [
                        const Text(
                            'Reemplaza la declaración de las bahías seleccionadas.'),
                        for (final bay in _bays.where((b) => b != _bay))
                          CheckboxListTile(
                              key: ValueKey('hatch-target-$bay'),
                              value: targets.contains(bay),
                              title: Text(
                                  'Bahía ${bay.toString().padLeft(2, '0')}'),
                              onChanged: (v) => update(() => v == true
                                  ? targets.add(bay)
                                  : targets.remove(bay))),
                      ]))),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancelar')),
                    FilledButton(
                        key: const ValueKey('hatch-copy-confirm'),
                        onPressed: targets.isEmpty
                            ? null
                            : () => Navigator.pop(context, true),
                        child: const Text('Copiar'))
                  ],
                )));
    if (!mounted || confirmed != true) return;
    final declaration = _draft[_bay];
    for (final target in targets) {
      final error = declaration?.validate(widget.geometry,
          hasHold: widget.holdBays.contains(target));
      if (error != null) {
        setState(() => _error = 'Bahía $target: $error');
        return;
      }
    }
    setState(() {
      for (final target in targets) {
        if (declaration == null) {
          _draft.remove(target);
        } else {
          _draft[target] = declaration;
        }
      }
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Copiado a ${operationCount(targets.length, 'bahía', 'bahías')}')));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('Tapas de escotilla')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        const Text(
            'Solo bahías con bodega observada en los planes, incluidas las huellas de 40 pies. '
            'El BAPLIE no declara tapas: revisa la hoja del buque antes de declarar.'),
        const SizedBox(height: 16),
        if (_bays.isEmpty)
          const Text(
              'Tapas: sin declarar. Abre un BAPLIE con bodega para identificar las bahías.')
        else ...[
          const Text('Bahía de bodega'),
          DropdownButton<int>(
              key: ValueKey('hatch-bay-$_bay'),
              value: _bay,
              isExpanded: true,
              items: [
                for (final bay in _bays)
                  DropdownMenuItem(
                      value: bay,
                      child: Text('Bahía ${bay.toString().padLeft(2, '0')}'))
              ],
              onChanged: (bay) {
                if (bay != null && _apply()) setState(() => _select(bay));
              }),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
              key: ValueKey('hatch-kind-$_bay'),
              initialValue: _kind?.name ?? 'unknown',
              isExpanded: true,
              // T-56: sin altura fija, a letra grande la opción elegida y las
              // del menú envuelven en vez de cortar «abierta».
              isDense: false,
              itemHeight: null,
              decoration: const InputDecoration(
                  labelText: 'Declaración', border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: 'unknown', child: Text('Sin declarar')),
                DropdownMenuItem(
                    value: 'openHold',
                    child: Text('Sin tapa · bodega abierta')),
                DropdownMenuItem(
                    value: 'automatic', child: Text('Una tapa automática')),
                DropdownMenuItem(value: 'crane', child: Text('Tapas de grúa'))
              ],
              onChanged: (value) => setState(() {
                    _kind = value == 'unknown'
                        ? null
                        : HatchCoverKind.values.byName(value!);
                    _error = null;
                  })),
          if (_kind == HatchCoverKind.crane) ...[
            const SizedBox(height: 12),
            Wrap(spacing: 8, children: [
              for (var n = 1; n <= 3; n++)
                ChoiceChip(
                    key: ValueKey('hatch-count-$n'),
                    label: Text('$n ${n == 1 ? 'tapa' : 'tapas'}'),
                    selected: _count == n,
                    onSelected: (_) => setState(() => _count = n))
            ]),
          ],
          if (_kind == HatchCoverKind.crane ||
              _kind == HatchCoverKind.automatic) ...[
            const SizedBox(height: 12),
            Text(
                'Filas de la geometría: ${widget.geometry.orderedRows.where((r) => r != 0 || widget.geometry.centerRowInHold != false).map((r) => r.toString().padLeft(2, '0')).join(', ')}'),
            for (var i = 0;
                i < (_kind == HatchCoverKind.automatic ? 1 : _count);
                i++)
              Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: TextField(
                      key: ValueKey('hatch-rows-$i'),
                      controller: _rows[i],
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                          labelText: 'Tapa ${i + 1} · filas',
                          hintText: '02, 04',
                          border: const OutlineInputBorder()))),
          ],
          if (_error != null)
            Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(_error!,
                    key: const ValueKey('hatch-error'),
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error))),
          const SizedBox(height: 12),
          OutlinedButton(
              key: const ValueKey('hatch-apply'),
              onPressed: () {
                if (_apply()) setState(() {});
              },
              child: const Text('Revisar declaración')),
          HatchCoverDiagram(
              declaration: _draft[_bay], rows: widget.geometry.orderedRows),
          const SizedBox(height: 12),
          OutlinedButton.icon(
              key: const ValueKey('hatch-copy'),
              onPressed: _bays.length < 2 ? null : _copy,
              icon: const Icon(Icons.copy),
              label: const Text('Copiar a otras bahías')),
        ],
        const SizedBox(height: 16),
        FilledButton(
            key: const ValueKey('hatch-done'),
            onPressed: () {
              if (_apply()) {
                Navigator.pop(context,
                    Map<int, HatchCoverDeclaration>.unmodifiable(_draft));
              }
            },
            child: const Text('Usar estas declaraciones')),
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar')),
      ]));
}
