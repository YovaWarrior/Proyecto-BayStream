import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design/design.dart';
import '../../../../core/utils/iso_coordinate_parser.dart';
import '../../domain/entities/entities.dart';
import '../../domain/entities/stowage_validation_result.dart';
import '../widgets/loading_plan_controls.dart' show BayPlanMode;
import 'stowage_validation_provider.dart';
import 'voyage_ui_state.dart';

/// Las tres vistas de «Colorear por» (`DESIGN.md` 5.4 y 13.2): el puerto de
/// destino, el tipo ISO de los vacíos o el estado de la operación.
enum ColorearPor {
  /// Pendiente, hecho, de paso, recién movido: el plano como el ícono.
  estado('Estado'),

  /// El puerto de descarga, con sus cinco letras en la celda.
  destino('Destino'),

  /// El tipo ISO de los vacíos y las reservas; los llenos en papel.
  tipo('Tipo de vacío');

  const ColorearPor(this.rotulo);

  /// Cómo se escribe en el selector.
  final String rotulo;
}

/// La vista por omisión de cada modo (10.4): el destino al mirar el plano; el
/// tipo de vacío en número de orden y en carga; el estado en la descarga.
ColorearPor colorearPorOmision(BayPlanMode modo) => switch (modo) {
      BayPlanMode.content => ColorearPor.destino,
      BayPlanMode.order || BayPlanMode.loading => ColorearPor.tipo,
      BayPlanMode.discharge => ColorearPor.estado,
    };

/// La vista que el planificador eligió por modo; sin elección, la de
/// [colorearPorOmision]. Vive en memoria mientras la app está abierta: la
/// preferencia por dispositivo exigiría `data/` (fuera del rediseño).
final colorearPorProvider =
    NotifierProvider<ColorearPorNotifier, Map<BayPlanMode, ColorearPor>>(
        ColorearPorNotifier.new);

class ColorearPorNotifier extends Notifier<Map<BayPlanMode, ColorearPor>> {
  @override
  Map<BayPlanMode, ColorearPor> build() => const {};

  /// La vista vigente para [modo].
  ColorearPor de(BayPlanMode modo) => state[modo] ?? colorearPorOmision(modo);

  void elegir(BayPlanMode modo, ColorearPor vista) =>
      state = {...state, modo: vista};
}

/// El modo del plano (Contenido, Número de orden, Descarga o Carga). Vive en
/// un provider para que la banda del muelle y el selector del plano manden
/// sobre el mismo estado.
final bayPlanModeProvider =
    NotifierProvider<BayPlanModeNotifier, BayPlanMode>(BayPlanModeNotifier.new);

class BayPlanModeNotifier extends Notifier<BayPlanMode> {
  @override
  BayPlanMode build() {
    // Al cerrar o cambiar el viaje, el plano vuelve a «Contenido».
    ref.listen(voyageUiStateProvider, (previo, actual) {
      if (actual is SinViaje || actual is Leyendo) state = BayPlanMode.content;
    });
    return BayPlanMode.content;
  }

  void elegir(BayPlanMode modo) => state = modo;
}

/// La escala del zoom del plano (T-106): la rejilla se amplía dentro de su
/// lienzo (`PlanZoomViewport`) y el chip que la muestra vive fuera de la
/// rejilla, en la línea de los controles (`ZoomDelPlano`, 10.20). Vuelve a
/// 100 % al cerrar o cambiar el viaje.
final planZoomProvider =
    NotifierProvider<PlanZoomNotifier, double>(PlanZoomNotifier.new);

class PlanZoomNotifier extends Notifier<double> {
  /// Lo más lejos y lo más cerca que se ve el plano, y cuánto cambia cada
  /// toque en el menú del zoom.
  static const double minimo = 0.75;
  static const double maximo = 3;
  static const double paso = 0.25;

  @override
  double build() {
    ref.listen(voyageUiStateProvider, (previo, actual) {
      if (actual is SinViaje || actual is Leyendo) state = 1;
    });
    return 1;
  }

  /// Fija la escala, acotada entre [minimo] y [maximo].
  void fijar(double escala) => state = escala.clamp(minimo, maximo).toDouble();

  void acercar() => fijar(state + paso);

  void alejar() => fijar(state - paso);

  void restablecer() => fijar(1);
}

/// Verdadero mientras dura un pellizco del touchpad sobre la rejilla de la
/// oficina (T-119, `DESIGN.md` 16.2): la columna que desplaza la rejilla no se
/// mueve con el gesto, como no se mueve la rejilla con dos dedos en la
/// pantalla. Lo enciende y lo apaga `PlanZoomViewport`.
final pellizcoDelPlanoProvider =
    NotifierProvider<PellizcoDelPlanoNotifier, bool>(
        PellizcoDelPlanoNotifier.new);

class PellizcoDelPlanoNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void empezar() => state = true;

  void terminar() => state = false;
}

/// El contenedor cuyo detalle se ve en el panel lateral de la oficina
/// (`DESIGN.md` 8 y 13.8). En pantallas angostas el detalle abre como hoja y
/// este provider no se usa.
final celdaSeleccionadaProvider =
    NotifierProvider<CeldaSeleccionadaNotifier, ContainerUnit?>(
        CeldaSeleccionadaNotifier.new);

class CeldaSeleccionadaNotifier extends Notifier<ContainerUnit?> {
  @override
  ContainerUnit? build() {
    ref.listen(voyageUiStateProvider, (previo, actual) {
      if (actual is! Publicado && actual is! Previo) state = null;
    });
    return null;
  }

  void elegir(ContainerUnit? contenedor) => state = contenedor;
  void limpiar() => state = null;
}

/// Lo que se acaba de mover (`DESIGN.md` 13.3): el contenedor, su bahía y
/// quién lo movió. Dura `BsMovimiento.recienMovido` y lo apaga el notifier.
class RecienMovido {
  const RecienMovido({
    required this.containerId,
    required this.bahia,
    required this.movimientoId,
    required this.quien,
  });

  /// El número del contenedor.
  final String containerId;

  /// La bahía donde pasó, para el destello de la silueta.
  final int bahia;

  /// El movimiento que lo trajo.
  final String movimientoId;

  /// El rol del equipo que lo registró; nunca un nombre.
  final BsEquipo quien;
}

/// La regla del naranja con datos de verdad: la celda que llega bajada o
/// cargada por la bitácora (la propia o la de la sincronización) es la recién
/// movida durante 1.5 s. El notifier no lleva reloj: la pantalla
/// (`RelojDelNaranja`, en `navegacion_del_viaje.dart`) corre
/// `BsMovimiento.recienMovido` y llama a `apagar`,
/// así que el tiempo es el de los cuadros de Flutter (13.3, punto 2) y no
/// queda ningún `Timer` colgado al cerrar.
final recienMovidoProvider =
    NotifierProvider<RecienMovidoNotifier, RecienMovido?>(
        RecienMovidoNotifier.new);

class RecienMovidoNotifier extends Notifier<RecienMovido?> {
  final Set<String> _vistos = <String>{};
  bool _primeraLectura = true;

  @override
  RecienMovido? build() {
    ref.listen(voyageUiStateProvider, (previo, actual) {
      if (actual is! Publicado) _olvidar();
    });
    return null;
  }

  /// Mira los movimientos de la operación tal como llegan. La primera lectura
  /// solo aprende los que ya estaban (al abrir no destella nada); de ahí en
  /// adelante, cada descarga o carga nueva es lo recién movido.
  void observar(Iterable<Movement> movimientos) {
    final nuevos = <Movement>[];
    for (final m in movimientos) {
      if (_vistos.add(m.id) && !_primeraLectura) nuevos.add(m);
    }
    _primeraLectura = false;
    if (nuevos.isEmpty) return;
    nuevos.sort(Movement.compareOrder);
    final ultimo = nuevos.lastWhere(
      (m) => _esMovimientoDeCarga(m) && _contenedorDe(m) != null,
      orElse: () => nuevos.last,
    );
    final contenedor = _contenedorDe(ultimo);
    final posicion = _posicionDe(ultimo);
    if (contenedor == null || posicion == null) return;
    final coordenada = IsoCoordinateParser.tryParse(posicion);
    if (coordenada == null) return;
    marcar(
      RecienMovido(
        containerId: contenedor,
        bahia: coordenada.bay,
        movimientoId: ultimo.id,
        quien: ultimo.author.role == OperatorRole.office
            ? BsEquipo.oficina
            : BsEquipo.muelle,
      ),
    );
  }

  /// Enciende el naranja; lo apaga la pantalla con [apagar].
  void marcar(RecienMovido movido) => state = movido;

  /// Apaga el naranja de [movimientoId], si sigue siendo el encendido.
  void apagar(String movimientoId) {
    if (state?.movimientoId == movimientoId) state = null;
  }

  void _olvidar() {
    _vistos.clear();
    _primeraLectura = true;
    state = null;
  }
}

bool _esMovimientoDeCarga(Movement m) =>
    m.type == MovementType.discharge ||
    m.type == MovementType.loadFull ||
    m.type == MovementType.assignEmpty;

String? _contenedorDe(Movement m) {
  final target = m.target;
  if (target != null && target.startsWith('C:')) return target.substring(2);
  final container = m.payload['container'];
  return container is String && container.isNotEmpty ? container : null;
}

/// La celda del movimiento: la que trae la carga de un lleno o una descarga
/// o, en un vacío asignado, la reserva que es su destino (`R:0030482`), que
/// el borrador no repite en la carga (10.21, H2: la reserva también
/// enciende su celda).
String? _posicionDe(Movement m) {
  final posicion = m.position;
  if (posicion != null) return posicion;
  final target = m.target;
  if (target != null && target.startsWith('R:')) return target.substring(2);
  return null;
}

/// Cuántas alertas de estiba incumplen, para el contador de «Más» y la
/// tarjeta de alertas. En previo no se evalúan (sin perfil confirmado el peso
/// por pila y las tomas dicen «sin evaluar»), así que es cero.
final cuentaDeAlertasProvider = Provider<int>((ref) {
  final ui = ref.watch(voyageUiStateProvider);
  // Sin geometría declarada (documentos anteriores a C-3) las reglas no se
  // evalúan: no hay nada que contar.
  if (ui is! Publicado || ui.voyage.geometry == null) return 0;
  return ref
      .watch(stowageValidationResultsProvider)
      .where((r) => r.status == ValidationStatus.nonConforming)
      .length;
});

/// Si alguna alerta que incumple es crítica (severidad de error): el
/// contador de «Más» pasa de aviso a error (13.3, punto 6).
final alertaCriticaProvider = Provider<bool>((ref) {
  final ui = ref.watch(voyageUiStateProvider);
  if (ui is! Publicado || ui.voyage.geometry == null) return false;
  return ref.watch(stowageValidationResultsProvider).any((r) =>
      r.status == ValidationStatus.nonConforming &&
      r.severity == ValidationSeverity.error);
});

/// Un movimiento de la bitácora como evento del panel «En vivo» (13.6): qué
/// pasó, el rol del equipo (nunca el nombre), el dato en mono y cuándo.
BsEventoEnVivo eventoEnVivo(Movement m, DateTime ahora,
    {String? recienMovidoId}) {
  final contenedor = _contenedorDe(m);
  final posicion = _posicionDe(m);
  final detalle = <String>[
    if (contenedor != null) formatearContenedor(contenedor),
    if (posicion != null) formatearPosicion(posicion),
    if (contenedor == null && posicion == null && m.target != null) m.target!,
  ].join(' · ');
  final esRestiba = m.payload['restow'] == true;
  final (String que, BsTipoDeEvento tipo) = switch (m.type) {
    MovementType.discharge =>
      esRestiba ? ('Re‑estiba', BsTipoDeEvento.hecho) : ('Bajado', BsTipoDeEvento.hecho),
    MovementType.loadFull => ('Cargado', BsTipoDeEvento.hecho),
    MovementType.assignEmpty => ('Vacío asignado', BsTipoDeEvento.hecho),
    MovementType.annul => ('Deshecho', BsTipoDeEvento.aprobado),
    MovementType.cancelItem => ('Embarque cancelado', BsTipoDeEvento.aviso),
    MovementType.requestChange => ('Cambio pedido', BsTipoDeEvento.aviso),
    MovementType.changePosition => ('Posición cambiada', BsTipoDeEvento.aprobado),
    MovementType.rejectChange => ('Cambio rechazado', BsTipoDeEvento.aviso),
    MovementType.hatchCover => (
        m.payload['remove'] == true ? 'Tapa quitada' : 'Tapa puesta',
        BsTipoDeEvento.aprobado
      ),
  };
  return BsEventoEnVivo(
    que: que,
    quien: m.author.role == OperatorRole.office ? BsEquipo.oficina : BsEquipo.muelle,
    detalle: detalle.isEmpty ? 'sin dato' : detalle,
    tipo: m.id == recienMovidoId ? BsTipoDeEvento.movido : tipo,
    momento: m.id == recienMovidoId ? 'ahora' : haceCuanto(m.createdAt, ahora),
  );
}

/// Los eventos del panel, del más reciente al más antiguo, hasta [maximo].
List<BsEventoEnVivo> eventosEnVivo(Iterable<Movement> movimientos, DateTime ahora,
    {String? recienMovidoId, int maximo = 8}) {
  final ordenados = movimientos.toList()..sort(Movement.compareOrder);
  return [
    for (final m in ordenados.reversed.take(maximo))
      eventoEnVivo(m, ahora, recienMovidoId: recienMovidoId),
  ];
}

/// «ahora», «hace 3 min», «hace 2 h» o la hora, en relativo y corto.
String haceCuanto(DateTime instante, DateTime ahora) {
  final diferencia = ahora.difference(instante);
  if (diferencia.inSeconds < 45) return 'ahora';
  if (diferencia.inMinutes < 60) return 'hace ${diferencia.inMinutes} min';
  if (diferencia.inHours < 24) return 'hace ${diferencia.inHours} h';
  final local = instante.toLocal();
  String dos(int n) => n.toString().padLeft(2, '0');
  return '${dos(local.day)}/${dos(local.month)} ${dos(local.hour)}:${dos(local.minute)}';
}
