import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design/design.dart';
import '../providers/plano_providers.dart';
import '../providers/voyage_ui_state.dart';

/// Los destinos de la navegación con un viaje abierto (`DESIGN.md` 8):
/// Plano · Lista · Avance · Estadísticas · Más. «Avance» solo existe con una
/// escala confirmada; «Más» abre la hoja con lo demás.
enum DestinoDelViaje {
  plano('Plano', BsIconos.bahia, BsIconos.bahia),
  lista('Lista', Icons.list_alt, Icons.list_alt),
  avance('Avance', Icons.data_usage, Icons.data_usage),
  estadisticas('Estadísticas', Icons.bar_chart, Icons.bar_chart,
      corto: 'Estad.'),
  mas('Más', Icons.more_horiz, Icons.more_horiz);

  const DestinoDelViaje(this.rotulo, this.icono, this.iconoActivo,
      {String? corto})
      : rotuloCorto = corto ?? rotulo;

  /// Cómo se escribe.
  final String rotulo;

  /// Cómo se escribe en la barra inferior, donde cinco destinos comparten
  /// 360 dp (`DESIGN.md` 9.2 y 9.3: «Estad.»); el nombre entero va en la
  /// descripción emergente y para el lector de pantalla.
  final String rotuloCorto;

  /// El icono en reposo. El Plano lleva la bahía del paquete (13.11), que
  /// no tiene variante de contorno, y los genéricos van rellenos junto a él.
  final IconData icono;

  /// El icono del destino activo.
  final IconData iconoActivo;
}

/// El destino que se ve. Vive en un provider para que la búsqueda, las
/// estadísticas y las alertas puedan llevar al Plano; vuelve al Plano cuando
/// se abre otro viaje.
final destinoDelViajeProvider =
    NotifierProvider<DestinoDelViajeNotifier, DestinoDelViaje>(
        DestinoDelViajeNotifier.new);

class DestinoDelViajeNotifier extends Notifier<DestinoDelViaje> {
  @override
  DestinoDelViaje build() {
    // La pestaña del plano es la primera que se ve con un viaje (10.2 a).
    ref.listen(voyageUiStateProvider, (previo, actual) {
      if (actual is SinViaje || actual is Leyendo) state = DestinoDelViaje.plano;
    });
    return DestinoDelViaje.plano;
  }

  void ir(DestinoDelViaje destino) => state = destino;
}

/// Lo abierto que no es una ruta y que Atrás cierra antes que nada
/// (`DESIGN.md` 8): hoy, el menú del zoom. Las hojas, los diálogos y la
/// búsqueda son rutas y las cierra el `Navigator` por su cuenta. Quien abre
/// algo que no lo es se anota al abrir y se olvida al cerrar; Atrás cierra lo
/// último anotado. El estado es cuántas cosas hay abiertas.
final cerrablesDeAtrasProvider =
    NotifierProvider<CerrablesDeAtras, int>(CerrablesDeAtras.new);

class CerrablesDeAtras extends Notifier<int> {
  final List<VoidCallback> _cerrar = <VoidCallback>[];

  @override
  int build() => 0;

  /// Anota algo abierto con lo que lo cierra.
  void anotar(VoidCallback cerrar) {
    _cerrar.add(cerrar);
    if (ref.mounted) state = _cerrar.length;
  }

  /// Lo abierto se cerró por su cuenta (también al desmontarse abierto, cuando
  /// el registro puede estar yéndose con la pantalla).
  void olvidar(VoidCallback cerrar) {
    _cerrar.remove(cerrar);
    if (ref.mounted) state = _cerrar.length;
  }

  /// Cierra lo último que se abrió. Devuelve si había algo abierto.
  bool cerrarUltimo() {
    if (_cerrar.isEmpty) return false;
    _cerrar.last();
    return true;
  }
}

/// Atrás en Android con un viaje abierto (`DESIGN.md` 8; decisiones 10.28 y
/// 10.29).
///
/// En orden: (1) cierra lo abierto que no es una ruta (el menú del zoom,
/// [cerrablesDeAtrasProvider]); las hojas, los diálogos y la búsqueda son
/// rutas y se cierran solas antes de llegar aquí; (2) en la oficina con panel
/// lateral, cierra el detalle de la celda; (3) en la raíz del viaje, con un
/// previo pregunta si descartarlo ([onDescartarPrevio]) y, con el viaje
/// publicado, vuelve al inicio ([onVolverAlInicio]) **solo con dos toques
/// seguidos**: el primero advierte «Toca Atrás otra vez para volver al
/// inicio» y el segundo, dentro de [ventana], vuelve. En el muelle, un toque
/// por error no saca a nadie del plano. El viaje publicado sigue guardado y
/// se reabre desde los recientes.
///
/// La ventana se cuenta desde el primer toque, con su propio reloj, y la
/// advertencia es una pieza aparte que se dibuja arriba, sobre el viaje: no
/// entra en la cola de avisos del `ScaffoldMessenger`. Con un aviso de
/// movimiento en pantalla (los 6 s con «Deshacer» de cada registro), la
/// advertencia anterior quedaba formada detrás, la ventana dependía de cuándo
/// se apagaba ese aviso y el segundo toque intentaba cerrar un aviso que no
/// era el primero de la cola (10.29, H1). Ahora la advertencia se ve aunque
/// haya otro aviso, no toca ningún aviso ajeno y el «Deshacer» del
/// movimiento sigue su curso.
///
/// La ventana es solo para dos toques seguidos en la raíz: si en medio Atrás
/// cierra otra cosa (el menú del zoom, el detalle de una celda, una hoja) o
/// se abre otra cosa, se cancela y la advertencia se va; el siguiente Atrás
/// en la raíz vuelve a advertir (10.31, O1).
///
/// Solo gobierna Atrás donde hay un botón Atrás del sistema, Android; en la
/// Web el navegador manda y en Windows no existe ([activo]).
class AtrasDelViaje extends ConsumerStatefulWidget {
  const AtrasDelViaje({
    super.key,
    required this.previo,
    required this.conPanel,
    required this.onDescartarPrevio,
    required this.onVolverAlInicio,
    required this.child,
    this.activo,
  });

  /// El viaje está en previo: Atrás en la raíz pregunta.
  final bool previo;

  /// Hay panel lateral: el detalle de la celda se cierra antes que la raíz.
  final bool conPanel;

  /// Pregunta si descartar el previo y lo descarta si se acepta.
  final Future<void> Function() onDescartarPrevio;

  /// Deja el viaje publicado y vuelve al inicio.
  final VoidCallback onVolverAlInicio;

  final Widget child;

  /// Si Atrás se gobierna aquí. Sin valor, [porOmision].
  final bool? activo;

  /// Cuánto dura la advertencia y, con ella, la ventana para el segundo
  /// toque, contada desde el primero.
  static const Duration ventana = Duration(seconds: 2);

  /// La advertencia del primer toque con el viaje publicado.
  static const String avisoDeSalida =
      'Toca Atrás otra vez para volver al inicio.';

  /// Android, el único cliente con un botón Atrás del sistema.
  static bool get porOmision =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  @override
  ConsumerState<AtrasDelViaje> createState() => _AtrasDelViajeState();
}

class _AtrasDelViajeState extends ConsumerState<AtrasDelViaje> {
  /// El reloj de la ventana: corre desde el primer toque y, al vencer, la
  /// advertencia se va. Mientras exista, el siguiente toque vuelve al inicio.
  Timer? _ventana;

  @override
  void dispose() {
    _ventana?.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Una hoja, un diálogo o la búsqueda encima: la ruta del viaje deja de
    // ser la actual y la ventana se cancela. Viene un build: basta el campo.
    if (ModalRoute.isCurrentOf(context) == false && _ventana != null) {
      _ventana!.cancel();
      _ventana = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!(widget.activo ?? AtrasDelViaje.porOmision)) return widget.child;
    // Lo que se abre sin ser una ruta (el menú del zoom, el detalle en el
    // panel lateral) también cancela la ventana.
    ref.listen<int>(cerrablesDeAtrasProvider, (int? antes, int ahora) {
      if (ahora > (antes ?? 0)) _cerrarVentana();
    });
    ref.listen(celdaSeleccionadaProvider, (_, ahora) {
      if (ahora != null) _cerrarVentana();
    });
    return PopScope<Object?>(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? _) {
        if (!didPop) _atras();
      },
      // La advertencia va encima del viaje, con sus mismas medidas: la pila
      // pasa las restricciones tal cual y no cambia nada del layout.
      child: Stack(
        fit: StackFit.passthrough,
        children: <Widget>[
          widget.child,
          if (_ventana != null)
            const Positioned.fill(
              child: _AdvertenciaDeAtras(key: ValueKey('aviso-de-atras')),
            ),
        ],
      ),
    );
  }

  Future<void> _atras() async {
    // Atrás que cierra otra cosa no cuenta como primer toque y cancela la
    // ventana abierta.
    if (ref.read(cerrablesDeAtrasProvider.notifier).cerrarUltimo()) {
      _cerrarVentana();
      return;
    }
    if (widget.conPanel && ref.read(celdaSeleccionadaProvider) != null) {
      ref.read(celdaSeleccionadaProvider.notifier).limpiar();
      _cerrarVentana();
      return;
    }
    if (widget.previo) {
      await widget.onDescartarPrevio();
      return;
    }
    if (_ventana != null) {
      // El segundo toque, dentro de la ventana: se retira la advertencia y se
      // vuelve al inicio. Los avisos de la cola (el del movimiento, con su
      // «Deshacer») no se tocan.
      _cerrarVentana();
      widget.onVolverAlInicio();
      return;
    }
    // El primer toque abre la ventana, contada desde ahora.
    setState(() {
      _ventana = Timer(AtrasDelViaje.ventana, () {
        if (mounted) setState(() => _ventana = null);
      });
    });
  }

  void _cerrarVentana() {
    if (_ventana == null) return;
    _ventana!.cancel();
    if (mounted) setState(() => _ventana = null);
  }
}

/// La advertencia de Atrás: una tarjeta como la de los avisos (los mismos
/// colores, borde y letra del tema de `SnackBar`), centrada arriba, bajo la
/// barra de estado, que no recibe toques y se anuncia al lector de pantalla.
/// Arriba y no al pie, porque al pie van los avisos del registro y la franja
/// de la operación (10.29, H2): así se ve a la vez que cualquiera de ellos.
/// Entra con un fundido de opacidad; quieta si se reduce el movimiento.
class _AdvertenciaDeAtras extends StatelessWidget {
  const _AdvertenciaDeAtras({super.key});

  /// Hasta dónde se ensancha en una pantalla ancha.
  static const double anchoMaximo = 560;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final avisos = tema.snackBarTheme;
    final medidas = BsMedidas.de(context);
    final quieta = MediaQuery.disableAnimationsOf(context);
    return IgnorePointer(
      child: SafeArea(
        bottom: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
                medidas.espacioL, medidas.espacioS, medidas.espacioL, 0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: anchoMaximo),
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: quieta ? 1 : 0, end: 1),
                duration: quieta ? Duration.zero : BsMovimiento.pulsacion,
                builder: (BuildContext context, double opacidad, Widget? hijo) =>
                    Opacity(opacity: opacidad, child: hijo),
                child: Semantics(
                  container: true,
                  liveRegion: true,
                  child: Material(
                    color: avisos.backgroundColor ??
                        tema.colorScheme.inverseSurface,
                    elevation: avisos.elevation ?? 6,
                    shape: avisos.shape,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: medidas.espacioL,
                          vertical: medidas.espacioM),
                      child: Text(
                        AtrasDelViaje.avisoDeSalida,
                        textAlign: TextAlign.center,
                        style: avisos.contentTextStyle ??
                            tema.textTheme.bodyMedium?.copyWith(
                                color: tema.colorScheme.onInverseSurface),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Los anchos de la navegación adaptable (`DESIGN.md` 8): por debajo de
/// [riel] la barra inferior; desde [riel] el riel; desde [panel] el riel con
/// el panel lateral de 360.
abstract final class AnchosDeNavegacion {
  static const double riel = 600;
  static const double panel = 1200;
}

/// Dice a lo que está debajo si la pantalla tiene el panel lateral de la
/// oficina, para que el detalle de una celda vaya allí y no a una hoja.
class PanelLateralDisponible extends InheritedWidget {
  const PanelLateralDisponible({
    super.key,
    required this.disponible,
    required super.child,
  });

  /// Verdadero con el panel de 360 a la vista.
  final bool disponible;

  /// Si hay panel lateral; sin el widget, no lo hay (las pruebas del plano
  /// solo, por ejemplo).
  static bool of(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<PanelLateralDisponible>()
          ?.disponible ??
      false;

  @override
  bool updateShouldNotify(PanelLateralDisponible oldWidget) =>
      oldWidget.disponible != disponible;
}

/// La barra inferior de los teléfonos: los destinos con «Más» y su contador
/// de alertas en aviso, o en error si alguna es crítica (13.3, punto 6).
class BarraDelViaje extends StatelessWidget {
  const BarraDelViaje({
    super.key,
    required this.destinos,
    required this.activo,
    required this.onDestino,
    this.alertas = 0,
    this.alertaCritica = false,
  });

  final List<DestinoDelViaje> destinos;
  final DestinoDelViaje activo;
  final ValueChanged<DestinoDelViaje> onDestino;
  final int alertas;
  final bool alertaCritica;

  /// Hasta dónde crecen los rótulos de la barra con la letra del sistema:
  /// cinco destinos en 360 dp dan 72 dp a cada uno, y a 1.3 el rótulo más
  /// largo («Avance», «Estad.») todavía cabe entero; más allá se recortaría.
  /// El icono y la descripción emergente siguen enteros, y el lector de
  /// pantalla lee el nombre completo.
  static const double escalaMaxima = 1.3;

  @override
  Widget build(BuildContext context) {
    final indice = destinos.indexOf(activo);
    final datos = MediaQuery.of(context);
    return MediaQuery(
      data: datos.copyWith(
          textScaler: datos.textScaler.clamp(maxScaleFactor: escalaMaxima)),
      child: NavigationBar(
        key: const ValueKey('barra-del-viaje'),
        selectedIndex: indice < 0 ? 0 : indice,
        onDestinationSelected: (int i) => onDestino(destinos[i]),
        destinations: <Widget>[
          for (final destino in destinos)
            NavigationDestination(
              key: ValueKey<String>('destino-${destino.name}'),
              icon: ContadorDeAlertas(
                  cuenta: destino == DestinoDelViaje.mas ? alertas : 0,
                  critica: alertaCritica,
                  child: Icon(destino.icono)),
              selectedIcon: ContadorDeAlertas(
                  cuenta: destino == DestinoDelViaje.mas ? alertas : 0,
                  critica: alertaCritica,
                  child: Icon(destino.iconoActivo)),
              label: destino.rotuloCorto,
              tooltip: destino.rotulo,
            ),
        ],
      ),
    );
  }
}

/// El riel de la oficina: la marca arriba, los destinos y, al pie, la nube y
/// Parámetros (`DESIGN.md` 8 y 13.7). Con [onAlertas], Alertas de estiba
/// también va en el riel (≥ 1200).
class RielDelViaje extends StatelessWidget {
  const RielDelViaje({
    super.key,
    required this.destinos,
    required this.activo,
    required this.onDestino,
    this.alertas = 0,
    this.alertaCritica = false,
    this.onAlertas,
    this.pie = const <Widget>[],
  });

  final List<DestinoDelViaje> destinos;
  final DestinoDelViaje activo;
  final ValueChanged<DestinoDelViaje> onDestino;
  final int alertas;
  final bool alertaCritica;

  /// Con esto, «Alertas» es un destino más del riel que abre la pantalla.
  final VoidCallback? onAlertas;

  /// Lo que va al pie del riel (la nube, Parámetros).
  final List<Widget> pie;

  @override
  Widget build(BuildContext context) {
    final medidas = BsMedidas.de(context);
    final indice = destinos.indexOf(activo);
    final conAlertas = onAlertas != null;
    // El ancho del riel: los 80 dp de `DESIGN.md` 8 o, si la letra del
    // sistema lo pide, el del rótulo más largo con su aire, para que ningún
    // rótulo se corte (RNF-003). Se mide con la fuente porque el desplazable
    // de abajo necesita un ancho cierto.
    final tema = Theme.of(context);
    final estilo = tema.navigationRailTheme.selectedLabelTextStyle ??
        tema.textTheme.labelMedium;
    final escalador = MediaQuery.textScalerOf(context);
    var anchoDeRotulo = 0.0;
    for (final rotulo in <String>[
      for (final destino in destinos) destino.rotulo,
      if (conAlertas) 'Alertas',
    ]) {
      final pintor = TextPainter(
        text: TextSpan(text: rotulo, style: estilo),
        textDirection: TextDirection.ltr,
        textScaler: escalador,
      )..layout();
      if (pintor.width > anchoDeRotulo) anchoDeRotulo = pintor.width;
      pintor.dispose();
    }
    final conAire = anchoDeRotulo + 2 * medidas.espacioL;
    final ancho = conAire > medidas.anchoRiel ? conAire : medidas.anchoRiel;
    // En una ventana baja el riel se desplaza en vez de desbordarse: el
    // sliver llena el alto de la ventana y, si el riel pide más, crece y se
    // desplaza (10.21: sin el widget de alto intrínseco de la entrega 2).
    return SizedBox(
      width: ancho,
      child: CustomScrollView(
        slivers: <Widget>[
          SliverFillRemaining(
            hasScrollBody: false,
            child: _riel(context, medidas, indice, conAlertas, ancho),
          ),
        ],
      ),
    );
  }

  Widget _riel(BuildContext context, BsMedidas medidas, int indice,
      bool conAlertas, double ancho) {
    return NavigationRail(
      key: const ValueKey('riel-del-viaje'),
      minWidth: ancho,
      selectedIndex: indice < 0 ? 0 : indice,
      onDestinationSelected: (int i) {
        if (conAlertas && i == destinos.length) {
          onAlertas!();
          return;
        }
        onDestino(destinos[i]);
      },
      labelType: NavigationRailLabelType.all,
      leading: Padding(
        padding: EdgeInsets.only(
            top: medidas.espacioS, bottom: medidas.espacioM),
        child: const BsMarca(tamano: 44),
      ),
      // El pie va después del grupo de destinos, que ya se queda con todo el
      // alto sobrante: queda abajo sin otro `Expanded` (que duplicaba el alto
      // que el riel pedía en una ventana baja).
      trailing: pie.isEmpty
          ? null
          : Padding(
              padding: EdgeInsets.only(bottom: medidas.espacioM),
              child: Column(mainAxisSize: MainAxisSize.min, children: pie),
            ),
      destinations: <NavigationRailDestination>[
        for (final destino in destinos)
          NavigationRailDestination(
            icon: ContadorDeAlertas(
                cuenta: destino == DestinoDelViaje.mas && !conAlertas
                    ? alertas
                    : 0,
                critica: alertaCritica,
                child: Icon(destino.icono)),
            selectedIcon: Icon(destino.iconoActivo),
            label: Text(destino.rotulo),
          ),
        if (conAlertas)
          NavigationRailDestination(
            icon: ContadorDeAlertas(
                cuenta: alertas,
                critica: alertaCritica,
                child: const Icon(Icons.fact_check)),
            label: const Text('Alertas'),
          ),
      ],
    );
  }
}

/// El contador de alertas sobre un icono: en aviso, o en error si alguna es
/// crítica; nunca en grúa (13.3, punto 6, 10.16).
class ContadorDeAlertas extends StatelessWidget {
  const ContadorDeAlertas({
    super.key,
    required this.cuenta,
    required this.child,
    this.critica = false,
  });

  final int cuenta;
  final bool critica;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (cuenta <= 0) return child;
    final semanticos = BsColoresSemanticos.de(context);
    final rol = critica ? semanticos.error : semanticos.revisar;
    return Badge(
      key: const ValueKey('contador-de-alertas'),
      backgroundColor: rol.contorno,
      textColor: rol.relleno,
      label: Text('$cuenta'),
      child: child,
    );
  }
}

/// El reloj de lo recién movido (`DESIGN.md` 13.3, punto 2): la pantalla, no
/// la celda ni el notifier, apaga el naranja al cabo de
/// `BsMovimiento.recienMovido`. Corre con los cuadros de Flutter, como el
/// destello de la silueta, así que no deja ningún `Timer` pendiente. No
/// dibuja nada.
class RelojDelNaranja extends ConsumerWidget {
  const RelojDelNaranja({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final movido = ref.watch(recienMovidoProvider);
    if (movido == null) return const SizedBox.shrink();
    return TweenAnimationBuilder<double>(
      key: ValueKey<String>(movido.movimientoId),
      tween: Tween<double>(begin: 0, end: 1),
      duration: BsMovimiento.recienMovido,
      onEnd: () =>
          ref.read(recienMovidoProvider.notifier).apagar(movido.movimientoId),
      builder: (BuildContext context, double _, Widget? __) =>
          const SizedBox.shrink(),
    );
  }
}
