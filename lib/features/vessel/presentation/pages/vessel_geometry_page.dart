import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/entities/entities.dart';

/// Pantalla de parámetros del buque, previa al plano.
///
/// El archivo BAPLIE no transmite las dimensiones del buque: solo revela los
/// slots que este viaje trae ocupados. Por eso la aplicación **propone** la
/// geometría mínima compatible con la carga y el usuario la confirma o la
/// corrige. Lo propuesto es un mínimo observado, no una medición.
class VesselGeometryPage extends StatefulWidget {
  /// Geometría mínima deducida del archivo. Hace de piso de la validación.
  final VesselGeometry proposal;

  /// Geometría ya confirmada, cuando se reabre la pantalla para corregirla.
  final VesselGeometry? initial;

  /// Nombre del archivo cargado, para situar al usuario.
  final String? fileName;

  const VesselGeometryPage({
    super.key,
    required this.proposal,
    this.initial,
    this.fileName,
  });

  @override
  State<VesselGeometryPage> createState() => _VesselGeometryPageState();
}

class _VesselGeometryPageState extends State<VesselGeometryPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _portRows;
  late final TextEditingController _starboardRows;
  late final TextEditingController _holdTiers;
  late final TextEditingController _deckTiers;
  late final TextEditingController _stackLimit;

  /// El usuario declaró no tener el manual de estabilidad a mano.
  bool _limitUnavailable = false;

  @override
  void initState() {
    super.initState();
    final start = widget.initial ?? widget.proposal;
    _portRows = TextEditingController(text: '${start.portRows}');
    _starboardRows = TextEditingController(text: '${start.starboardRows}');
    _holdTiers = TextEditingController(text: '${start.holdTiers}');
    _deckTiers = TextEditingController(text: '${start.deckTiers}');
    _stackLimit = TextEditingController(
      text: start.stackWeightLimitKg == null
          ? ''
          : start.stackWeightLimitKg!.round().toString(),
    );
    _limitUnavailable =
        widget.initial != null && widget.initial!.stackWeightLimitKg == null;

    for (final controller in _controllers) {
      controller.addListener(_onFieldChanged);
    }
  }

  List<TextEditingController> get _controllers => [
        _portRows,
        _starboardRows,
        _holdTiers,
        _deckTiers,
        _stackLimit,
      ];

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onFieldChanged() => setState(() {});

  int? _value(TextEditingController controller) =>
      int.tryParse(controller.text.trim());

  /// El límite queda resuelto si se escribió un número o si se declaró no tenerlo.
  bool get _limitResolved =>
      _limitUnavailable || (double.tryParse(_stackLimit.text.trim()) ?? 0) > 0;

  bool get _canConfirm {
    if (!_limitResolved) return false;
    final candidate = _buildGeometry();
    return candidate != null && candidate.isAtLeast(widget.proposal);
  }

  VesselGeometry? _buildGeometry() {
    final port = _value(_portRows);
    final starboard = _value(_starboardRows);
    final hold = _value(_holdTiers);
    final deck = _value(_deckTiers);
    if (port == null || starboard == null || hold == null || deck == null) {
      return null;
    }
    return VesselGeometry(
      portRows: port,
      starboardRows: starboard,
      holdTiers: hold,
      deckTiers: deck,
      stackWeightLimitKg:
          _limitUnavailable ? null : double.tryParse(_stackLimit.text.trim()),
    );
  }

  void _confirm() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final geometry = _buildGeometry();
    if (geometry == null) return;
    Navigator.of(context).pop(geometry);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final proposal = widget.proposal;
    final candidate = _buildGeometry();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Parámetros del buque'),
        leading: IconButton(
          key: const ValueKey('geometry-cancel'),
          icon: const Icon(Icons.close),
          tooltip: 'Cancelar',
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        // Sin esto el mensaje no se ve nunca: al bajar un valor por debajo del
        // minimo el boton Confirmar ya queda deshabilitado y validate() no
        // llega a correr, asi que el usuario veria un boton muerto sin motivo.
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildExplanation(context),
            const SizedBox(height: 24),

            Text('Filas', style: textTheme.titleMedium),
            const SizedBox(height: 8),
            _buildCountField(
              fieldKey: const ValueKey('geometry-port-rows'),
              controller: _portRows,
              label: 'Filas a babor',
              minimum: proposal.portRows,
              observed: proposal.portRowNumbers.isEmpty
                  ? null
                  : 'la fila ${_pad(proposal.portRowNumbers.first)}',
              unit: 'filas a babor',
            ),
            const SizedBox(height: 16),
            _buildCountField(
              fieldKey: const ValueKey('geometry-starboard-rows'),
              controller: _starboardRows,
              label: 'Filas a estribor',
              minimum: proposal.starboardRows,
              observed: proposal.starboardRowNumbers.isEmpty
                  ? null
                  : 'la fila ${_pad(proposal.starboardRowNumbers.last)}',
              unit: 'filas a estribor',
            ),
            const SizedBox(height: 8),
            _buildCenterRowNote(context),
            const SizedBox(height: 24),

            Text('Niveles', style: textTheme.titleMedium),
            const SizedBox(height: 8),
            _buildCountField(
              fieldKey: const ValueKey('geometry-deck-tiers'),
              controller: _deckTiers,
              label: 'Niveles de cubierta',
              minimum: proposal.deckTiers,
              observed: proposal.deckTierNumbers.isEmpty
                  ? null
                  : 'el nivel ${_pad(proposal.deckTierNumbers.first)}',
              unit: 'niveles de cubierta',
            ),
            const SizedBox(height: 16),
            _buildCountField(
              fieldKey: const ValueKey('geometry-hold-tiers'),
              controller: _holdTiers,
              label: 'Niveles de bodega',
              minimum: proposal.holdTiers,
              observed: proposal.holdTierNumbers.isEmpty
                  ? null
                  : 'el nivel ${_pad(proposal.holdTierNumbers.first)}',
              unit: 'niveles de bodega',
            ),
            const SizedBox(height: 24),

            _buildStackLimitSection(context),
            const SizedBox(height: 24),

            if (candidate != null) _buildSummary(context, candidate),
            const SizedBox(height: 24),

            FilledButton.icon(
              key: const ValueKey('geometry-confirm'),
              onPressed: _canConfirm ? _confirm : null,
              icon: const Icon(Icons.check),
              label: const Text('Confirmar y ver el plano'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar la carga'),
            ),
            if (!_limitResolved) ...[
              const SizedBox(height: 8),
              Text(
                'Falta resolver el límite de apilamiento.',
                textAlign: TextAlign.center,
                style: textTheme.bodySmall
                    ?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _pad(int value) => value.toString().padLeft(2, '0');

  Widget _buildExplanation(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      color: colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.straighten, color: colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Lo propuesto es un mínimo observado',
                    style: textTheme.titleSmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'El archivo BAPLIE no transmite las dimensiones del buque. Solo '
              'revela los slots que este viaje trae ocupados, así que la '
              'aplicación puede deducir el mínimo, nunca el total: un buque de '
              'catorce filas que hoy carga en diez se ve, desde el archivo, '
              'como un buque de diez filas.',
              style: textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Los valores propuestos se pueden subir sin restricción. Bajarlos '
              'por debajo del mínimo dejaría carga real fuera del plano.',
              style: textTheme.bodyMedium,
            ),
            if (widget.fileName != null) ...[
              const SizedBox(height: 12),
              Text(
                'Archivo: ${widget.fileName}',
                style: textTheme.bodySmall
                    ?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCenterRowNote(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.info_outline, size: 16, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'La fila 00 se dibuja siempre en el centro, venga ocupada o no, '
            'como en el plano impreso.',
            style: textTheme.bodySmall
                ?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
        ),
      ],
    );
  }

  Widget _buildCountField({
    required Key fieldKey,
    required TextEditingController controller,
    required String label,
    required int minimum,
    required String? observed,
    required String unit,
  }) {
    final helper = observed == null
        ? 'El archivo no trae carga aquí.'
        : 'Mínimo observado en el archivo: $minimum. El buque puede tener más.';

    return TextFormField(
      key: fieldKey,
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        labelText: label,
        helperText: helper,
        helperMaxLines: 2,
        border: const OutlineInputBorder(),
      ),
      validator: (raw) {
        final value = int.tryParse((raw ?? '').trim());
        if (value == null) return 'Escribe un número.';
        if (value < minimum) {
          return observed == null
              ? 'No puede ser menor que $minimum.'
              : 'El archivo trae carga en $observed; con $value $unit '
                  'quedaría fuera del plano.';
        }
        return null;
      },
    );
  }

  Widget _buildStackLimitSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Límite de apilamiento', style: textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Este dato no está en el archivo. Viene del manual de estabilidad '
              'del buque, y es el único parámetro que la aplicación no puede '
              'proponer.',
              style: textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            TextFormField(
              key: const ValueKey('geometry-stack-limit'),
              controller: _stackLimit,
              enabled: !_limitUnavailable,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Límite por pila',
                suffixText: 'kg',
                border: OutlineInputBorder(),
              ),
              validator: (raw) {
                if (_limitUnavailable) return null;
                final value = double.tryParse((raw ?? '').trim());
                if (value == null || value <= 0) {
                  return 'Escribe el límite o marca que no lo tienes.';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            CheckboxListTile(
              key: const ValueKey('geometry-no-limit'),
              value: _limitUnavailable,
              onChanged: (checked) {
                setState(() {
                  _limitUnavailable = checked ?? false;
                  if (_limitUnavailable) _stackLimit.clear();
                });
              },
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              title: const Text('No lo tengo'),
              subtitle: Text(
                'Sin límite declarado no se muestra ninguna alerta de peso. La '
                'aplicación no inventa un umbral.',
                style: textTheme.bodySmall
                    ?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary(BuildContext context, VesselGeometry geometry) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final corrected = !_sameShapeAs(geometry, widget.proposal);

    return Card(
      color: colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Rejilla resultante', style: textTheme.titleSmall),
            const SizedBox(height: 8),
            Text(
              '${geometry.orderedRows.length} columnas × '
              '${geometry.totalTiers} niveles = '
              '${geometry.slotsPerBay} huecos por bahía',
              style: textTheme.bodyMedium,
            ),
            const SizedBox(height: 4),
            Text(
              corrected
                  ? 'Geometría corregida por el usuario.'
                  : 'Geometría igual al mínimo observado en el archivo.',
              style: textTheme.bodySmall
                  ?.copyWith(color: colorScheme.onSecondaryContainer),
            ),
          ],
        ),
      ),
    );
  }

  bool _sameShapeAs(VesselGeometry a, VesselGeometry b) =>
      a.portRows == b.portRows &&
      a.starboardRows == b.starboardRows &&
      a.holdTiers == b.holdTiers &&
      a.deckTiers == b.deckTiers;
}
