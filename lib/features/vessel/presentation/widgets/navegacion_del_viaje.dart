import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design/design.dart';
import '../providers/plano_providers.dart';
import '../providers/voyage_ui_state.dart';

/// Los destinos de la navegación con un viaje abierto (`DESIGN.md` 8):
/// Plano · Lista · Avance · Estadísticas · Más. «Avance» solo existe con una
/// escala confirmada; «Más» abre la hoja con lo demás.
enum DestinoDelViaje {
  plano('Plano', Icons.grid_view_outlined, Icons.grid_view),
  lista('Lista', Icons.list_alt_outlined, Icons.list_alt),
  avance('Avance', Icons.data_usage_outlined, Icons.data_usage),
  estadisticas('Estadísticas', Icons.bar_chart_outlined, Icons.bar_chart,
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

  /// El icono en reposo.
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
    // En una ventana baja el riel se desplaza en vez de desbordarse.
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints restricciones) =>
          SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: restricciones.maxHeight),
          child: IntrinsicHeight(child: _riel(context, medidas, indice, conAlertas)),
        ),
      ),
    );
  }

  Widget _riel(
      BuildContext context, BsMedidas medidas, int indice, bool conAlertas) {
    return NavigationRail(
      key: const ValueKey('riel-del-viaje'),
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
      trailing: pie.isEmpty
          ? null
          : Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.only(bottom: medidas.espacioM),
                  child: Column(mainAxisSize: MainAxisSize.min, children: pie),
                ),
              ),
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
                child: const Icon(Icons.fact_check_outlined)),
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
