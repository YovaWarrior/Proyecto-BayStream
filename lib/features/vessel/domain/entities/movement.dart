import 'package:equatable/equatable.dart';

/// T-72 · Un movimiento de la bitácora de muelle (T-79a, secciones 2.3 a 2.6).
///
/// La bitácora es **solo de anexar**: un movimiento se crea una vez y no se
/// edita ni se borra. Se deshace con otro que lo anula (`annul`) o que lo
/// reemplaza en la misma escritura (`payload.corrects`). El estado de cada
/// contenedor y reserva no se guarda: se deriva de los movimientos vigentes
/// (`OperationStateDeriver`).
///
/// Los nombres de campo y de tipo son los del documento de Firestore de
/// T-79a (5.1), para que T-79 los envíe sin traducir.
enum MovementType {
  discharge('discharge'),
  loadFull('load_full'),
  assignEmpty('assign_empty'),
  annul('annul'),
  cancelItem('cancel_item'),

  /// T-80 · Solicitudes y decisiones de la oficina.
  requestChange('request_change'),
  changePosition('change_position'),
  rejectChange('reject_change'),

  /// Se guarda y exporta desde ya, pero se deriva en T-84.
  hatchCover('hatch_cover');

  const MovementType(this.wire);

  /// Nombre en el documento persistido y en Firestore.
  final String wire;

  static MovementType? fromWire(String? value) {
    for (final type in values) {
      if (type.wire == value) return type;
    }
    return null;
  }

  /// Tipos que admiten `payload.corrects` (T-79a 2.4).
  bool get canCorrect =>
      this == discharge ||
      this == loadFull ||
      this == assignEmpty ||
      this == hatchCover;
}

/// Rol de quien registra (T-80 lo exige con reglas; aquí solo se registra).
enum OperatorRole { dock, office }

/// Quién registró el movimiento. En Windows y mientras no haya cuentas
/// (T-79), `uid` es nulo y el nombre es el que declaró el operador.
class MovementAuthor extends Equatable {
  final String? uid;
  final String name;
  final OperatorRole role;

  const MovementAuthor({this.uid, required this.name, required this.role});

  /// Solo un autor con cuenta está verificado por la nube.
  bool get verified => uid != null;

  @override
  List<Object?> get props => [uid, name, role];

  Map<String, dynamic> toJson() =>
      {'uid': uid, 'name': name, 'role': role.name};

  factory MovementAuthor.fromJson(Map<String, dynamic> json) => MovementAuthor(
        uid: json['uid'] as String?,
        name: json['name'] as String,
        role: OperatorRole.values.firstWhere((r) => r.name == json['role'],
            orElse: () => OperatorRole.dock),
      );
}

class Movement extends Equatable {
  static const int schema = 1;

  /// UUID v4 creado en el dispositivo. Es también el id del documento remoto.
  final String id;
  final String operationId;
  final MovementType type;

  /// Clave natural del objeto: `C:` + número, `R:` + posición o `T:` + tapa.
  /// Nula en los movimientos sobre varios objetos (T-80).
  final String? target;

  /// Datos propios del tipo, solo con valores JSON (texto, números, bool,
  /// listas y mapas). Las horas van como texto ISO-8601.
  final Map<String, Object?> payload;
  final MovementAuthor author;
  final String deviceId;
  final int sequence;

  /// Cuándo se registró, con la hora del dispositivo.
  final DateTime createdAt;

  /// Cuándo lo recibió la nube (T-79). Informativo: no entra en el orden.
  final DateTime? receivedAt;

  Movement({
    required this.id,
    required this.operationId,
    required this.type,
    this.target,
    Map<String, Object?> payload = const {},
    required this.author,
    required this.deviceId,
    required this.sequence,
    required this.createdAt,
    this.receivedAt,
  }) : payload = Map.unmodifiable(payload);

  /// T-79 · El mismo movimiento con la hora en que lo recibió la nube.
  Movement withReceivedAt(DateTime? value) => Movement(
        id: id,
        operationId: operationId,
        type: type,
        target: target,
        payload: payload,
        author: author,
        deviceId: deviceId,
        sequence: sequence,
        createdAt: createdAt,
        receivedAt: value,
      );

  String? get annuls => payload['annuls'] as String?;
  String? get corrects => payload['corrects'] as String?;
  String? get position => payload['position'] as String?;
  String? get reason => payload['reason'] as String?;

  /// Orden total de T-79a 2.7.2: solo campos inmutables, así que todos los
  /// dispositivos ordenan igual sin importar cuándo les llegó cada movimiento.
  static int compareOrder(Movement a, Movement b) {
    var result = a.createdAt.compareTo(b.createdAt);
    if (result != 0) return result;
    result = a.deviceId.compareTo(b.deviceId);
    if (result != 0) return result;
    result = a.sequence.compareTo(b.sequence);
    if (result != 0) return result;
    return a.id.compareTo(b.id);
  }

  @override
  List<Object?> get props => [
        id,
        operationId,
        type,
        target,
        payload,
        author,
        deviceId,
        sequence,
        createdAt,
        receivedAt,
      ];

  Map<String, dynamic> toJson() => {
        'id': id,
        'schema': schema,
        'operationId': operationId,
        'type': type.wire,
        'target': target,
        'payload': payload,
        'author': author.toJson(),
        'deviceId': deviceId,
        'sequence': sequence,
        'createdAt': createdAt.toUtc().toIso8601String(),
        if (receivedAt != null)
          'receivedAt': receivedAt!.toUtc().toIso8601String(),
      };

  factory Movement.fromJson(Map<String, dynamic> json) {
    final type = MovementType.fromWire(json['type'] as String?);
    if (type == null) {
      throw FormatException('Tipo de movimiento desconocido: ${json['type']}');
    }
    return Movement(
      id: json['id'] as String,
      operationId: json['operationId'] as String,
      type: type,
      target: json['target'] as String?,
      payload: Map<String, Object?>.from(json['payload'] as Map? ?? const {}),
      author: MovementAuthor.fromJson(
          Map<String, dynamic>.from(json['author'] as Map)),
      deviceId: json['deviceId'] as String,
      sequence: json['sequence'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      receivedAt: json['receivedAt'] == null
          ? null
          : DateTime.parse(json['receivedAt'] as String),
    );
  }
}

/// Lo que arma la pantalla. `MovementLogRepository.append` le pone id,
/// autor, dispositivo, secuencia y hora.
class MovementDraft extends Equatable {
  final String operationId;
  final MovementType type;
  final String? target;
  final Map<String, Object?> payload;

  MovementDraft._(
      this.operationId, this.type, this.target, Map<String, Object?> payload)
      : payload = Map.unmodifiable(
            Map.fromEntries(payload.entries.where((e) => e.value != null)));

  /// T-75: un contenedor del plano de llegada baja en esta escala.
  /// `restow` marca la re-estiba de un contenedor que no descarga aquí.
  factory MovementDraft.discharge(
          String operationId, String containerId, String position,
          {bool restow = false,
          String? reason,
          String? corrects,
          DateTime? operatedAt}) =>
      MovementDraft._(operationId, MovementType.discharge, 'C:$containerId', {
        'position': position,
        'restow': restow,
        'reason': reason,
        'corrects': corrects,
        'operatedAt': operatedAt?.toUtc().toIso8601String(),
      });

  /// T-76: se carga un contenedor que el plan trae con número.
  factory MovementDraft.loadFull(
          String operationId, String containerId, String position,
          {int? order,
          String? seal,
          String? reason,
          String? corrects,
          DateTime? operatedAt}) =>
      MovementDraft._(operationId, MovementType.loadFull, 'C:$containerId', {
        'position': position,
        'order': order,
        'seal': seal,
        'reason': reason,
        'corrects': corrects,
        'operatedAt': operatedAt?.toUtc().toIso8601String(),
      });

  /// T-76: un vacío del listado ocupa una celda reservada del plan.
  factory MovementDraft.assignEmpty(String operationId, String reservedPosition,
          String containerId, double tareKg,
          {int? order,
          String? seal,
          String? reason,
          String? corrects,
          DateTime? operatedAt}) =>
      MovementDraft._(
          operationId, MovementType.assignEmpty, 'R:$reservedPosition', {
        'container': containerId,
        'tareKg': tareKg,
        'order': order,
        'seal': seal,
        'reason': reason,
        'corrects': corrects,
        'operatedAt': operatedAt?.toUtc().toIso8601String(),
      });

  /// Deshace un movimiento anterior. El motivo es obligatorio.
  factory MovementDraft.annul(
          String operationId, String movementId, String reason,
          {String? target}) =>
      MovementDraft._(operationId, MovementType.annul, target,
          {'annuls': movementId, 'reason': reason});

  /// T-81: un contenedor o reserva sale del plan de esta escala.
  factory MovementDraft.cancelItem(
          String operationId, String target, String reason) =>
      MovementDraft._(operationId, MovementType.cancelItem, target,
          {'reason': reason.trim()});

  /// T-81: la oficina cambia el plan directamente, sin una solicitud.
  factory MovementDraft.changePosition(
          String operationId, List<PositionChange> changes, String reason) =>
      MovementDraft._(operationId, MovementType.changePosition, null, {
        'changes': changes.map((c) => c.toJson()).toList(),
        'reason': reason.trim()
      });

  factory MovementDraft.requestChange(
          String operationId, List<PositionChange> changes, String reason) =>
      MovementDraft._(operationId, MovementType.requestChange, null, {
        'changes': changes.map((c) => c.toJson()).toList(),
        'reason': reason.trim()
      });

  factory MovementDraft.approveChange(
          String operationId, Movement request, String reason) =>
      MovementDraft._(operationId, MovementType.changePosition, null, {
        'changes': request.payload['changes'],
        'request': request.id,
        'reason': reason.trim(),
      });

  factory MovementDraft.rejectChange(
          String operationId, String request, String reason) =>
      MovementDraft._(operationId, MovementType.rejectChange, null,
          {'request': request, 'reason': reason.trim()});

  factory MovementDraft.hatchCover(String operationId, int bay, int number,
          {required bool remove}) =>
      MovementDraft._(operationId, MovementType.hatchCover, 'T:$bay-$number',
          {'action': remove ? 'remove' : 'replace'});

  /// Para los tipos que se derivan después (T-80, T-84) y para importar.
  factory MovementDraft.raw(String operationId, MovementType type,
          String? target, Map<String, Object?> payload) =>
      MovementDraft._(operationId, type, target, payload);

  static final _position = RegExp(r'^[0-9]{6,7}$');
  static final _container = RegExp(r'^C:[A-Z0-9]{1,17}$');
  static final _reserved = RegExp(r'^R:[0-9]{6,7}$');

  /// Mensaje del primer problema de forma, o null si el borrador es válido.
  /// Las mismas comprobaciones que las reglas propuestas de T-79a (5.2).
  String? validate() {
    bool hasReason() =>
        (payload['reason'] as String?)?.trim().isNotEmpty ?? false;
    final corrects = payload['corrects'];
    if (corrects != null && !type.canCorrect) {
      return 'Este tipo de movimiento no admite corrección: deshazlo y regístralo de nuevo.';
    }
    switch (type) {
      case MovementType.discharge:
      case MovementType.loadFull:
        if (!_container.hasMatch(target ?? '')) {
          return 'Falta el número de contenedor: escríbelo.';
        }
        if (!_position.hasMatch(payload['position'] as String? ?? '')) {
          return 'La posición debe tener 6 o 7 cifras (BBBRRTT): corrígela.';
        }
      case MovementType.assignEmpty:
        if (!_reserved.hasMatch(target ?? '')) {
          return 'Falta la celda reservada: elige una.';
        }
        final container = payload['container'] as String? ?? '';
        if (!RegExp(r'^[A-Z0-9]{1,17}$').hasMatch(container)) {
          return 'Falta el número del vacío: indícalo.';
        }
        final tare = payload['tareKg'];
        if (tare is! num || tare <= 0 || tare >= 15000) {
          return 'Tara fuera de rango: debe ser mayor que 0 y menor que 15 000 kg. '
              'Corrígela.';
        }
      case MovementType.annul:
        if ((payload['annuls'] as String?)?.isEmpty ?? true) {
          return 'Falta el movimiento a anular: vuelve a elegirlo en el detalle de la celda.';
        }
        if (!hasReason()) return 'Anular exige un motivo: escríbelo.';
      case MovementType.cancelItem:
        if (!_container.hasMatch(target ?? '') &&
            !_reserved.hasMatch(target ?? '')) {
          return 'Falta el contenedor o la reserva a cancelar: vuelve a elegirlo en el plano.';
        }
        if (!hasReason() || (payload['reason'] as String).length > 300) {
          return 'Cancelar exige un motivo de hasta 300 caracteres: escríbelo.';
        }
      case MovementType.requestChange:
      case MovementType.changePosition:
        if (target != null) {
          return 'El cambio llegó mal armado: sus objetos van en la lista, no aparte. '
              'Vuelve a abrir el formulario y repite el cambio.';
        }
        if (!hasReason() || (payload['reason'] as String).length > 300) {
          return 'Falta el motivo: escribe uno de hasta 300 caracteres.';
        }
        final changes = PositionChange.readAll(payload['changes']);
        if (changes == null) {
          return 'Los cambios de la solicitud no son válidos: indica de uno a cuatro, '
              'sin repetir objetos ni destinos.';
        }
      case MovementType.rejectChange:
        if (target != null ||
            payload['request'] is! String ||
            (payload['request'] as String).isEmpty) {
          return 'Falta la solicitud que se rechaza: vuelve a abrirla desde la bandeja.';
        }
        if (!hasReason() || (payload['reason'] as String).length > 300) {
          return 'Falta el motivo: escribe uno de hasta 300 caracteres.';
        }
      case MovementType.hatchCover:
        if (!RegExp(r'^T:[0-9]{1,3}-[1-9]$').hasMatch(target ?? '') ||
            !['remove', 'replace'].contains(payload['action']) ||
            payload.keys.any((k) => !['action', 'operatedAt', 'corrects'].contains(k))) {
          return 'Falta la tapa o la acción: indica una tapa y si se quita o se repone.';
        }
    }
    return null;
  }

  @override
  List<Object?> get props => [operationId, type, target, payload];
}

/// Posiciones del plan efectivo en el momento de pedir el cambio. La clave
/// de una reserva permanece la del plan publicado, aunque cambie de celda.
class PositionChange extends Equatable {
  final String target;
  final String from;
  final String to;
  const PositionChange(this.target, this.from, this.to);

  Map<String, Object?> toJson() => {'target': target, 'from': from, 'to': to};

  static List<PositionChange>? readAll(Object? value) {
    if (value is! List || value.isEmpty || value.length > 4) return null;
    final result = <PositionChange>[];
    final targets = <String>{}, destinations = <String>{};
    for (final entry in value) {
      if (entry is! Map || entry.length != 3) return null;
      final target = entry['target'], from = entry['from'], to = entry['to'];
      if (target is! String ||
          from is! String ||
          to is! String ||
          !RegExp(r'^(C:[A-Z0-9]{1,17}|R:[0-9]{6,7})$').hasMatch(target) ||
          !MovementDraft._position.hasMatch(from) ||
          !MovementDraft._position.hasMatch(to) ||
          from.padLeft(7, '0') == to.padLeft(7, '0') ||
          !targets.add(target) ||
          !destinations.add(to.padLeft(7, '0'))) {
        return null;
      }
      result.add(
          PositionChange(target, from.padLeft(7, '0'), to.padLeft(7, '0')));
    }
    return List.unmodifiable(result);
  }

  @override
  List<Object?> get props => [target, from, to];
}

/// Estado de envío (T-79a 4.2). `localOnly` es el normal sin sincronización:
/// en Windows y, hasta T-79, en todos los clientes.
enum SendState { localOnly, pending, confirmed, rejected }

class MovementRecord extends Equatable {
  final Movement movement;
  final SendState state;

  /// Razón legible cuando la nube lo rechazó (T-79).
  final String? rejection;

  const MovementRecord(this.movement, this.state, {this.rejection});

  @override
  List<Object?> get props => [movement, state, rejection];
}
