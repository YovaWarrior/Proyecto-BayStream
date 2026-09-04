import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/utils/iso_coordinate_parser.dart';
import '../../domain/entities/entities.dart';

/// Lo que la pantalla devuelve: la geometría del buque y el puerto de esta
/// escala. El puerto no es geometría —el casco no cambia entre escalas— pero
/// se confirma en el mismo paso porque es el otro dato que el archivo no trae.
typedef VesselCallParameters = ({VesselGeometry geometry, String? portOfCall});

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

  /// Puertos de carga del archivo con su conteo, del más frecuente al menos.
  final Map<String, int> loadingPorts;

  /// Puerto de escala ya confirmado, al reabrir la pantalla.
  final String? initialPortOfCall;

  /// Posiciones ocupadas del viaje.
  ///
  /// Sirven para saber qué niveles traen carga: esos no se pueden quitar,
  /// porque dejarían contenedores fuera del plano.
  final Iterable<IsoCoordinate> positions;

  const VesselGeometryPage({
    super.key,
    required this.proposal,
    this.positions = const [],
    this.loadingPorts = const {},
    this.initialPortOfCall,
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
  late final TextEditingController _stackLimit;

  /// Niveles declarados. Son listas y no cuentas: el usuario puede quitar uno
  /// intermedio que el buque no tenga.
  late List<int> _deckTiers;
  late List<int> _holdTiers;

  /// Niveles que este viaje trae ocupados. No se pueden quitar.
  final Set<int> _ocupados = {};

  /// Puerto de esta escala. `null` significa que el usuario prefirió no
  /// declararlo, y entonces no se distingue la carga de paso.
  String? _portOfCall;

  /// El usuario tocó la selección de puerto.
  bool _puertoElegido = false;

  /// El usuario declaró no tener el manual de estabilidad a mano.
  bool _limitUnavailable = false;

  @override
  void initState() {
    super.initState();
    final start = widget.initial ?? widget.proposal;
    _portRows = TextEditingController(text: '${start.portRows}');
    _starboardRows = TextEditingController(text: '${start.starboardRows}');
    _deckTiers = [...start.deckTiers];
    _holdTiers = [...start.holdTiers];
    _ocupados.addAll(widget.positions.map((p) => p.tier));
    _portOfCall = widget.initialPortOfCall ??
        (widget.loadingPorts.keys.isEmpty ? null : widget.loadingPorts.keys.first);
    _puertoElegido = widget.initialPortOfCall != null;
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
    if (candidate == null) return false;
    // Las filas se declaran por cantidad y no pueden bajar del mínimo; los
    // niveles se declaran uno a uno y el invariante es que ninguna carga del
    // archivo quede fuera.
    return candidate.portRows >= widget.proposal.portRows &&
        candidate.starboardRows >= widget.proposal.starboardRows &&
        candidate.coversAll(widget.positions);
  }

  VesselGeometry? _buildGeometry() {
    final port = _value(_portRows);
    final starboard = _value(_starboardRows);
    if (port == null || starboard == null) return null;
    return VesselGeometry(
      portRows: port,
      starboardRows: starboard,
      holdTiers: _holdTiers,
      deckTiers: _deckTiers,
      stackWeightLimitKg:
          _limitUnavailable ? null : double.tryParse(_stackLimit.text.trim()),
    );
  }

  void _confirm() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final geometry = _buildGeometry();
    if (geometry == null) return;
    Navigator.of(context)
        .pop((geometry: geometry, portOfCall: _portOfCall));
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
            _buildTierChips(
              context,
              titulo: 'Niveles de cubierta',
              prefijo: 'deck',
              tiers: _deckTiers,
              anchor: VesselGeometry.firstDeckTier,
              onChanged: (nuevos) => setState(() => _deckTiers = nuevos),
            ),
            const SizedBox(height: 16),
            _buildTierChips(
              context,
              titulo: 'Niveles de bodega',
              prefijo: 'hold',
              tiers: _holdTiers,
              anchor: VesselGeometry.firstHoldTier,
              onChanged: (nuevos) => setState(() => _holdTiers = nuevos),
            ),
            const SizedBox(height: 24),

            if (widget.loadingPorts.isNotEmpty) ...[
              _buildPortOfCallSection(context),
              const SizedBox(height: 24),
            ],

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

  /// Sección de niveles de una zona, como chips quitables.
  ///
  /// Un nivel con carga en este viaje no trae aspa: quitarlo dejaría
  /// contenedores fuera del plano. Los demás sí, porque el buque puede no
  /// tener ese nivel aunque la numeración ISO lo contemple.
  Widget _buildTierChips(
    BuildContext context, {
    required String titulo,
    required String prefijo,
    required List<int> tiers,
    required int anchor,
    required ValueChanged<List<int>> onChanged,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final ordenados = [...tiers]..sort((a, b) => b.compareTo(a));
    final candidatos = _nivelesAgregables(tiers, anchor);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titulo, style: textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final tier in ordenados)
              InputChip(
                key: ValueKey('$prefijo-tier-${_pad(tier)}'),
                label: Text(_pad(tier)),
                backgroundColor: _ocupados.contains(tier)
                    ? colorScheme.secondaryContainer
                    : null,
                tooltip: _ocupados.contains(tier)
                    ? 'Este viaje trae carga en el nivel ${_pad(tier)}: no se '
                        'puede quitar'
                    : 'Quitar el nivel ${_pad(tier)}',
                onDeleted: _ocupados.contains(tier)
                    ? null
                    : () => onChanged([...tiers]..remove(tier)),
              ),
            PopupMenuButton<int>(
              key: ValueKey('$prefijo-add'),
              tooltip: 'Agregar un nivel',
              onSelected: (tier) => onChanged([...tiers, tier]..sort()),
              itemBuilder: (context) => [
                for (final tier in candidatos)
                  PopupMenuItem(
                    key: ValueKey('$prefijo-add-${_pad(tier)}'),
                    value: tier,
                    child: Text('Nivel ${_pad(tier)}'),
                  ),
              ],
              child: Chip(
                avatar: const Icon(Icons.add, size: 18),
                label: const Text('Agregar'),
                backgroundColor: colorScheme.surfaceContainerHighest,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          ordenados.isEmpty
              ? 'El archivo no trae carga en esta zona.'
              : 'Propuesto desde el archivo: ${ordenados.length} niveles. '
                  'Quita los que el buque no tenga.',
          style: textTheme.bodySmall
              ?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }

  /// Niveles que se pueden agregar: los que falten dentro de la corrida y el
  /// siguiente por encima del más alto declarado.
  List<int> _nivelesAgregables(List<int> tiers, int anchor) {
    final maximo = tiers.isEmpty
        ? anchor - VesselGeometry.tierStep
        : tiers.reduce(math.max);
    final siguiente = maximo + VesselGeometry.tierStep;
    return [
      for (var t = anchor; t < siguiente; t += VesselGeometry.tierStep)
        if (!tiers.contains(t)) t,
      siguiente,
    ];
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

  /// Puerto de esta escala: el dato que separa la carga que se opera aquí de
  /// la que ya venía a bordo.
  ///
  /// El archivo no lo dice. Solo dice dónde se cargó cada contenedor, así que
  /// lo más frecuente es una apuesta razonable y nada más: se propone y se
  /// confirma, como el resto.
  Widget _buildPortOfCallSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final total = widget.loadingPorts.values.fold(0, (a, b) => a + b);
    final enEscala = _portOfCall == null ? 0 : widget.loadingPorts[_portOfCall] ?? 0;
    final dePaso = total - enEscala;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Puerto de esta escala', style: textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'El archivo dice dónde se cargó cada contenedor, no en qué escala '
              'está el buque. Se propone el puerto más frecuente; corrígelo si '
              'la escala es otra.',
              style: textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final entry in widget.loadingPorts.entries)
                  ChoiceChip(
                    key: ValueKey('port-${entry.key}'),
                    label: Text('${entry.key} (${entry.value})'),
                    selected: _portOfCall == entry.key,
                    onSelected: (_) => setState(() {
                      _portOfCall = entry.key;
                      _puertoElegido = true;
                    }),
                  ),
                ChoiceChip(
                  key: const ValueKey('port-none'),
                  label: const Text('Sin declarar'),
                  selected: _portOfCall == null,
                  onSelected: (_) => setState(() {
                    _portOfCall = null;
                    _puertoElegido = true;
                  }),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _portOfCall == null
                  ? 'Sin puerto declarado no se distingue la carga de paso: el '
                      'plano muestra todo igual.'
                  : '$enEscala se operan en esta escala y $dePaso ya vienen a '
                      'bordo, de paso.',
              key: const ValueKey('port-split'),
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: _puertoElegido ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
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
      _sameTiers(a.holdTierNumbers, b.holdTierNumbers) &&
      _sameTiers(a.deckTierNumbers, b.deckTierNumbers);

  /// Compara los niveles por contenido y no por identidad.
  ///
  /// `==` entre listas compara referencias, y la pantalla trabaja sobre copias
  /// de las de la propuesta: comparar con `==` rotulaba como «corregida» una
  /// geometría que nadie había tocado.
  bool _sameTiers(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
