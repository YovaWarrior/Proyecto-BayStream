import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/utils/iso_coordinate_parser.dart';
import '../../domain/entities/entities.dart';
import '../formatters/stack_weight_formatter.dart';

/// Lo que la pantalla devuelve: la geometría del buque y el puerto de esta
/// escala. El puerto no es geometría —el casco no cambia entre escalas— pero
/// se confirma en el mismo paso porque es el otro dato que el archivo no trae.
typedef VesselCallParameters = ({VesselGeometry geometry, String? portOfCall,
  Set<String> reeferSlots, VesselProfileOrigin reeferSlotsOrigin, bool changed});

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
  final VesselProfile? profile;
  final bool profileOnly;

  /// Nombre del archivo cargado, para situar al usuario.
  final String? fileName;

  /// Solo para informar: confirmar esta pantalla no declara las tomas.
  final int? proposedReeferSocketCount;

  /// Puertos de carga del archivo con su conteo, del más frecuente al menos.
  final Map<String, int> loadingPorts;

  /// Puerto de salida declarado por el archivo (`LOC+5`), si lo trae.
  ///
  /// Es la propuesta principal, por delante del puerto de carga más
  /// frecuente: lo dice el archivo en vez de deducirse contando cajas.
  final String? declaredPort;

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
    this.declaredPort,
    this.initialPortOfCall,
    this.initial,
    this.profile,
    this.profileOnly = false,
    this.fileName,
    this.proposedReeferSocketCount,
  });

  @override
  State<VesselGeometryPage> createState() => _VesselGeometryPageState();
}

class _VesselGeometryPageState extends State<VesselGeometryPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _portRows;
  late final TextEditingController _starboardRows;
  late final TextEditingController _stackLimit;
  late final TextEditingController _floor;
  late final TextEditingController _firstHold;
  late final TextEditingController _firstDeck;
  bool? _centerRowOnDeck;
  bool? _centerRowInHold;
  final _socketInput = TextEditingController();
  late Set<String> _sockets;
  bool _declareSockets = false;
  String? _socketError;
  VesselGeometry get _start => widget.initial ?? widget.profile?.geometry ?? widget.proposal;
  VesselProfileOrigin get _socketOrigin => _declareSockets
      ? VesselProfileOrigin.declaredByUser
      : widget.profile?.reeferSlotsOrigin ?? VesselProfileOrigin.proposedFromFile;

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
    final start = _start;
    _portRows = TextEditingController(text: '${start.portRows}');
    _starboardRows = TextEditingController(text: '${start.starboardRows}');
    _deckTiers = [...start.deckTiers];
    _holdTiers = [...start.holdTiers];
    _floor = TextEditingController(text: '${start.deckTierFloor}');
    _firstHold = TextEditingController(text: '${start.firstHoldTier}');
    _firstDeck = TextEditingController(text: '${start.firstDeckTier}');
    _centerRowOnDeck = start.centerRowOnDeck;
    _centerRowInHold = start.centerRowInHold;
    _sockets = {...?widget.profile?.reeferSlots};
    _ocupados.addAll(widget.positions.map((p) => p.tier));
    _portOfCall = widget.initialPortOfCall ??
        widget.declaredPort ??
        (widget.loadingPorts.keys.isEmpty ? null : widget.loadingPorts.keys.first);
    _puertoElegido = widget.initialPortOfCall != null;
    _stackLimit = TextEditingController(
      text: formatStackWeightLimit(start.stackWeightLimitKg),
    );
    _limitUnavailable =
        (widget.initial != null || widget.profileOnly ||
          widget.profile?.origin == VesselProfileOrigin.template) && start.stackWeightLimitKg == null;

    for (final controller in _controllers) {
      controller.addListener(_onFieldChanged);
    }
  }

  List<TextEditingController> get _controllers => [
        _portRows,
        _starboardRows,
        _stackLimit,
        _floor, _firstHold, _firstDeck,
      ];

  @override
  void dispose() {
    _socketInput.dispose();
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onFieldChanged() => setState(() {
    final floor = _value(_floor);
    if (floor != null && floor > 0 && floor <= 99) {
      final tiers = {..._holdTiers, ..._deckTiers};
      final basis = _start.copyWith(deckTierFloor: floor);
      _holdTiers = tiers.where((t) => !basis.isDeckTier(t)).toList()..sort();
      _deckTiers = tiers.where(basis.isDeckTier).toList()..sort();
    }
  });

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
    final floor = _value(_floor), hold = _value(_firstHold), deck = _value(_firstDeck);
    if (port == null || starboard == null || port < 0 || starboard < 0 ||
        port > 49 || starboard > 50 || floor == null || floor < 1 || floor > 99 ||
        hold == null || hold < 0 || hold >= floor ||
        deck == null || deck < floor || deck > 99) {
      return null;
    }
    return VesselGeometry(
      deckTierFloor: floor,
      firstHoldTier: hold,
      firstDeckTier: deck,
      portRows: port,
      starboardRows: starboard,
      centerRowOnDeck: _centerRowOnDeck,
      centerRowInHold: _centerRowInHold,
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
        .pop((geometry: geometry, portOfCall: _portOfCall,
          reeferSlots: Set<String>.unmodifiable(_sockets),
          reeferSlotsOrigin: _socketOrigin, changed: _changed(geometry)));
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
            if (widget.proposedReeferSocketCount != null) ...[
              const SizedBox(height: 12),
              Text(
                'Tomas de reefer: ${widget.proposedReeferSocketCount} posiciones '
                'propuestas del archivo (cota inferior). El buque puede tener '
                'más tomas. Confirmar la geometría no las convierte en declaradas.',
                key: const ValueKey('reefer-sockets-proposal'),
                style: textTheme.bodyMedium,
              ),
            ],
            const SizedBox(height: 24),

            ExpansionTile(title: const Text('Frontera y anclas'),
              key: const ValueKey('geometry-anchors'),
              children: [
                _parameterField(_floor, 'Frontera cubierta / bodega', 'geometry-floor'),
                _parameterField(_firstHold, 'Primer nivel de bodega', 'geometry-first-hold'),
                _parameterField(_firstDeck, 'Primer nivel de cubierta', 'geometry-first-deck'),
                const Text('La frontera clasifica los niveles. Las anclas indican dónde empieza la propuesta de cada zona.'),
                if (_buildGeometry() == null)
                  const Text('Revisa frontera y anclas: bodega debajo de la frontera y cubierta desde ella.'),
              ]),
            const SizedBox(height: 16),
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
            const SizedBox(height: 12),
            _buildCenterRowSelector(
              key: 'geometry-center-deck',
              label: 'Fila 00 en cubierta',
              value: _centerRowOnDeck,
              occupied: widget.positions.any((p) => p.row == 0 &&
                  (_buildGeometry() ?? _start).isDeckTier(p.tier)),
              onChanged: (value) => setState(() => _centerRowOnDeck = value),
            ),
            const SizedBox(height: 12),
            _buildCenterRowSelector(
              key: 'geometry-center-hold',
              label: 'Fila 00 en bodega',
              value: _centerRowInHold,
              occupied: widget.positions.any((p) => p.row == 0 &&
                  !(_buildGeometry() ?? _start).isDeckTier(p.tier)),
              onChanged: (value) => setState(() => _centerRowInHold = value),
            ),
            const SizedBox(height: 24),

            Text('Niveles', style: textTheme.titleMedium),
            const SizedBox(height: 8),
            _buildTierChips(
              context,
              titulo: 'Niveles de cubierta',
              prefijo: 'deck',
              tiers: _deckTiers,
              anchor: _value(_firstDeck) ?? _start.firstDeckTier,
              onChanged: (nuevos) => setState(() => _deckTiers = nuevos),
            ),
            const SizedBox(height: 16),
            _buildTierChips(
              context,
              titulo: 'Niveles de bodega',
              prefijo: 'hold',
              tiers: _holdTiers,
              anchor: _value(_firstHold) ?? _start.firstHoldTier,
              onChanged: (nuevos) => setState(() => _holdTiers = nuevos),
            ),
            const SizedBox(height: 24),

            // Se pregunta el puerto cuando hay alguno que ofrecer: el que
            // declara la cabecera o los de la carga. Sin ninguno la seccion
            // seria una pregunta sin respuestas posibles.
            if (_portOptions.isNotEmpty) ...[
              _buildPortOfCallSection(context),
              const SizedBox(height: 24),
            ],

            _buildStackLimitSection(context),
            const SizedBox(height: 24),

            if (widget.profile != null) _buildSockets(context),

            if (candidate != null) _buildSummary(context, candidate),
            const SizedBox(height: 24),

            FilledButton.icon(
              key: const ValueKey('geometry-confirm'),
              onPressed: _canConfirm ? _confirm : null,
              icon: const Icon(Icons.check),
              label: Text(widget.profileOnly ? 'Guardar perfil' : 'Confirmar y ver el plano'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(widget.profileOnly ? 'Cancelar' : 'Cancelar la carga'),
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

  Widget _parameterField(TextEditingController controller, String label, String key) =>
      Padding(padding: const EdgeInsets.only(bottom: 12), child: TextFormField(
        key: ValueKey(key), controller: controller,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(2)],
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      ));

  Widget _buildSockets(BuildContext context) {
    final source = switch (_socketOrigin) {
      VesselProfileOrigin.template => 'Heredadas de plantilla; pendientes de declaración para este buque.',
      VesselProfileOrigin.proposedFromFile => 'Propuestas del archivo: cota inferior, puede haber más tomas.',
      VesselProfileOrigin.declaredByUser => 'Tomas declaradas por el usuario.',
    };
    return ExpansionTile(
      key: const ValueKey('profile-sockets'),
      title: Text('Tomas de reefer (${_sockets.length})'),
      subtitle: Text(source),
      children: [
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final slot in _sockets.toList()..sort())
            InputChip(key: ValueKey('socket-$slot'), label: Text(slot),
              onDeleted: () => setState(() => _sockets.remove(slot))),
        ]),
        const SizedBox(height: 12),
        TextField(key: const ValueKey('socket-input'), controller: _socketInput,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(7)],
          decoration: InputDecoration(labelText: 'Posición BBBRRTT',
            helperText: 'Ejemplo: 0020182', errorText: _socketError)),
        TextButton.icon(key: const ValueKey('socket-add'), icon: const Icon(Icons.add),
          label: const Text('Agregar toma'), onPressed: () {
            final code = _socketInput.text.trim();
            setState(() {
              if (!IsoCoordinateParser.isValid(code) || code.startsWith('000')) {
                _socketError = 'Escribe siete dígitos y una bahía distinta de 000.';
                return;
              }
              _socketError = null;
              _sockets.add(code);
              _socketInput.clear();
            });
          }),
        if (widget.profile!.reeferSlotsOrigin != VesselProfileOrigin.declaredByUser)
          CheckboxListTile(key: const ValueKey('sockets-declare'),
            value: _declareSockets, onChanged: (v) => setState(() => _declareSockets = v ?? false),
            title: const Text('Declaro este conjunto de tomas para el buque'),
            subtitle: const Text('Marca solo después de revisar las tomas. Confirmar la geometría no las declara.')),
      ],
    );
  }

  Widget _buildExplanation(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (widget.profileOnly || widget.profile?.origin == VesselProfileOrigin.template) {
      return Card(child: Padding(padding: const EdgeInsets.all(16), child: Text(
        widget.profileOnly
          ? 'Editando el perfil guardado de ${widget.profile!.vesselName}. Los cambios se guardan solo al confirmar.'
          : 'Parámetros heredados de una plantilla para ${widget.profile!.vesselName}. Revisa si corresponden a este buque antes de confirmar.')));
    }

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
            'como en el plano impreso. Declara si existe físicamente en cada '
            'zona; sin declaración, 01 y 02 se consideran vecinas.',
            style: textTheme.bodySmall
                ?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
        ),
      ],
    );
  }

  Widget _buildCenterRowSelector({
    required String key,
    required String label,
    required bool? value,
    required bool occupied,
    required ValueChanged<bool?> onChanged,
  }) => DropdownButtonFormField<String>(
        key: ValueKey(key),
        initialValue: value == null ? 'unknown' : value ? 'yes' : 'no',
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        items: [
          const DropdownMenuItem(value: 'unknown', child: Text('No declarada')),
          const DropdownMenuItem(value: 'yes', child: Text('Sí existe')),
          DropdownMenuItem(
            value: 'no',
            enabled: !occupied,
            child: const Text('No existe'),
          ),
        ],
        onChanged: (selection) => onChanged(switch (selection) {
          'yes' => true,
          'no' => false,
          _ => null,
        }),
      );

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
    final basis = _buildGeometry() ?? _start;
    final candidatos = _nivelesAgregables(tiers, anchor).where((tier) =>
      tier <= 99 && basis.isDeckTier(tier) == (prefijo == 'deck')).toSet();
    // También ofrece carga observada bajo el ancla declarada.
    candidatos.addAll(_ocupados.where((tier) => !tiers.contains(tier) &&
      basis.isDeckTier(tier) == (prefijo == 'deck')));

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
                for (final tier in candidatos.toList()..sort())
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
          widget.profileOnly || widget.profile?.origin == VesselProfileOrigin.template
              ? '${ordenados.length} niveles del perfil. Revisa los que tiene el buque.'
              : ordenados.isEmpty
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

  /// Puertos elegibles: primero el que declara el archivo, después los
  /// puertos de carga de la propia mercancía.
  ///
  /// El declarado va primero porque es el único que el archivo afirma; los
  /// otros salen de contar dónde se cargó cada caja, y en `CORPUS_A01` el más
  /// contado no es el de la escala.
  List<String> get _portOptions {
    final options = <String>[];
    final declared = widget.declaredPort;
    if (declared != null && declared.isNotEmpty) options.add(declared);
    for (final port in widget.loadingPorts.keys) {
      if (!options.contains(port)) options.add(port);
    }
    return options;
  }

  /// Puerto de esta escala: el dato que separa la carga que se opera aquí de
  /// la que ya venía a bordo.
  ///
  /// El archivo lo declara en la cabecera (`LOC+5`) y esa es la propuesta. Si
  /// no lo trae se cae a contar puertos de carga, que es una apuesta y se
  /// rotula como tal.
  Widget _buildPortOfCallSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final declared = widget.declaredPort;
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
              declared == null
                  ? 'El archivo no declara puerto de salida. Se propone el '
                      'puerto de carga más frecuente, que es una apuesta; '
                      'corrígelo si la escala es otra.'
                  : 'El archivo declara $declared como puerto de salida y se '
                      'propone ese. Los demás son los puertos donde se cargó '
                      'la mercancía que va a bordo; corrígelo si la escala es '
                      'otra.',
              key: const ValueKey('port-source'),
              style: textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final port in _portOptions)
                  ChoiceChip(
                    key: ValueKey('port-$port'),
                    label: Text(
                      widget.loadingPorts.containsKey(port)
                          ? '$port (${widget.loadingPorts[port]})'
                          : port,
                    ),
                    selected: _portOfCall == port,
                    onSelected: (_) => setState(() {
                      _portOfCall = port;
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
                  : widget.loadingPorts.isEmpty
                      ? 'El archivo no dice dónde se cargó cada contenedor, '
                          'así que la carga de paso no se puede separar.'
                      : '$enEscala se operan en esta escala y $dePaso ya vienen '
                          'a bordo, de paso.',
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
              'del buque. Si procede de una plantilla, comprueba que corresponde '
              'a este buque.',
              style: textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            TextFormField(
              key: const ValueKey('geometry-stack-limit'),
              controller: _stackLimit,
              enabled: !_limitUnavailable,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
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
    final corrected = !_sameShapeAs(geometry, _start);

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
            if (widget.profile != null)
              Text(_changed(geometry) ? 'Perfil modificado; pendiente de guardar.' : 'Perfil sin cambios.',
                key: const ValueKey('profile-changes')),
            Text(
              corrected
                  ? 'Geometría corregida por el usuario.'
                  : widget.initial != null || widget.profileOnly
                    ? 'Geometría igual al perfil inicial.'
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
      a.deckTierFloor == b.deckTierFloor &&
      a.firstHoldTier == b.firstHoldTier && a.firstDeckTier == b.firstDeckTier &&
      a.stackWeightLimitKg == b.stackWeightLimitKg &&
      a.portRows == b.portRows &&
      a.starboardRows == b.starboardRows &&
      a.centerRowOnDeck == b.centerRowOnDeck &&
      a.centerRowInHold == b.centerRowInHold &&
      _sameTiers(a.holdTierNumbers, b.holdTierNumbers) &&
      _sameTiers(a.deckTierNumbers, b.deckTierNumbers);

  bool _changed(VesselGeometry geometry) => !_sameShapeAs(geometry, _start) ||
      !setEquals(_sockets, widget.profile?.reeferSlots ?? const <String>{}) ||
      _socketOrigin != (widget.profile?.reeferSlotsOrigin ?? VesselProfileOrigin.proposedFromFile);

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
