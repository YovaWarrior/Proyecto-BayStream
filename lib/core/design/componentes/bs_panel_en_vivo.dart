import 'package:flutter/material.dart';

import '../bs_colores_semanticos.dart';
import '../bs_medidas.dart';
import '../bs_paleta.dart';
import '../bs_movimiento.dart';
import '../bs_tipografia.dart';

/// Quién hizo un movimiento: el rol del equipo, nunca un nombre ni un
/// identificador (`DESIGN.md`, 13.9). La API solo admite este enum.
enum BsEquipo {
  /// Un teléfono del muelle.
  muelle('Muelle'),

  /// La oficina.
  oficina('Oficina');

  const BsEquipo(this.rotulo);

  /// Cómo se escribe.
  final String rotulo;
}

/// De qué tipo es un evento del panel, que decide el color de su marca.
enum BsTipoDeEvento {
  /// Algo que se acaba de mover: el naranja de la grúa.
  movido,

  /// Una descarga o carga hecha.
  hecho,

  /// Un cambio pedido o un conflicto: aviso.
  aviso,

  /// Una re‑estiba aprobada u otro dato de la oficina: acero.
  aprobado,
}

/// Un evento del panel «En vivo».
@immutable
class BsEventoEnVivo {
  /// Crea el evento.
  const BsEventoEnVivo({
    required this.que,
    required this.quien,
    required this.detalle,
    required this.tipo,
    this.momento,
    this.accion,
    this.onAccion,
  });

  /// Qué pasó («Bajado», «Cambio pedido», «Re‑estiba aprobada»).
  final String que;

  /// Quién: el rol del equipo.
  final BsEquipo quien;

  /// El dato en mono: el número de contenedor y la celda.
  final String detalle;

  /// El tipo, que decide el color de la marca.
  final BsTipoDeEvento tipo;

  /// Cuándo («ahora», «hace 1 min»). No se muestra si hay [accion].
  final String? momento;

  /// El rótulo de una acción («Revisar»).
  final String? accion;

  /// Qué hace la acción.
  final VoidCallback? onAccion;

  /// El título de la fila: «Bajado · Muelle».
  String get titulo => '$que · ${quien.rotulo}';

  /// La etiqueta accesible completa.
  String get etiqueta => <String>[
        que,
        quien.rotulo,
        detalle,
        if (momento != null) momento!,
      ].join(', ');
}

/// El panel «En vivo» (`DESIGN.md`, 13.6): la actividad en tiempo real que llega
/// por Firebase. Un punto en hecho con pulso de opacidad cuando está en línea,
/// el resumen («Oficina y 2 teléfonos del muelle») y una fila por evento con
/// la marca de su tipo, «Qué · Quién», el dato en mono y el momento o la
/// acción.
///
/// Es una región en vivo: el lector de pantalla anuncia el evento más
/// reciente (13.3). El pulso se queda quieto si el sistema pide reducir el
/// movimiento.
class BsPanelEnVivo extends StatelessWidget {
  /// Crea el panel.
  const BsPanelEnVivo({
    super.key,
    required this.eventos,
    this.resumen,
    this.enLinea = true,
    this.titulo = 'En vivo',
  });

  /// Los eventos, del más reciente al más antiguo.
  final List<BsEventoEnVivo> eventos;

  /// Quiénes están conectados, sin nombres («Oficina y 2 teléfonos del muelle»).
  final String? resumen;

  /// Si hay conexión: el punto pulsa; sin ella, el punto va en tinta suave.
  final bool enLinea;

  /// El título del panel.
  final String titulo;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final medidas = BsMedidas.de(context);
    final semanticos = BsColoresSemanticos.de(context);
    final esquema = tema.colorScheme;
    final paleta = BsPaleta.de(tema.brightness);
    final textos = tema.textTheme;
    final mono = tema.extension<BsTextos>()?.datoMono ?? textos.bodySmall;
    Color colorDe(BsTipoDeEvento tipo) => switch (tipo) {
          BsTipoDeEvento.movido => esquema.tertiaryContainer,
          BsTipoDeEvento.hecho => semanticos.hecho.contorno,
          BsTipoDeEvento.aviso => semanticos.revisar.contorno,
          BsTipoDeEvento.aprobado => esquema.secondary,
        };
    return Material(
      color: paleta.hoja,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(medidas.radioPanel),
        side: BorderSide(color: esquema.outlineVariant),
      ),
      child: Padding(
        padding: EdgeInsets.all(medidas.espacioL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Semantics(
              header: true,
              label: <String>[
                titulo,
                enLinea ? 'en línea' : 'sin conexión',
                if (resumen != null) resumen!,
              ].join(', '),
              excludeSemantics: true,
              child: Row(
                children: <Widget>[
                  BsPulso(
                    color: enLinea
                        ? semanticos.hecho.contorno
                        : esquema.onSurfaceVariant,
                    activo: enLinea,
                  ),
                  SizedBox(width: medidas.espacioS),
                  Text(
                    titulo,
                    style: textos.titleSmall
                        ?.copyWith(color: esquema.onSurfaceVariant),
                  ),
                  if (resumen != null) ...<Widget>[
                    SizedBox(width: medidas.espacioM),
                    Expanded(
                      child: Text(
                        resumen!,
                        textAlign: TextAlign.end,
                        style: textos.bodySmall
                            ?.copyWith(color: semanticos.tintaTenue),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            for (var i = 0; i < eventos.length; i++)
              _Fila(
                evento: eventos[i],
                color: colorDe(eventos[i].tipo),
                mono: mono,
                // La más reciente se anuncia al lector de pantalla.
                enVivo: i == 0,
              ),
            if (eventos.isEmpty)
              Padding(
                padding: EdgeInsets.only(top: medidas.espacioM),
                child: Text(
                  'Todavía no hay movimientos en esta escala.',
                  style: textos.bodySmall,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Fila extends StatelessWidget {
  const _Fila({
    required this.evento,
    required this.color,
    required this.mono,
    required this.enVivo,
  });

  final BsEventoEnVivo evento;
  final Color color;
  final TextStyle? mono;
  final bool enVivo;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final medidas = BsMedidas.de(context);
    final semanticos = BsColoresSemanticos.de(context);
    final esquema = tema.colorScheme;
    final textos = tema.textTheme;
    final esMovido = evento.tipo == BsTipoDeEvento.movido;
    return Semantics(
      liveRegion: enVivo,
      label: evento.etiqueta,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: medidas.espacioM),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: esquema.outlineVariant)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: medidas.espacioXs + 2),
              child: ExcludeSemantics(
                child: Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
            SizedBox(width: medidas.espacioM),
            Expanded(
              child: ExcludeSemantics(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(evento.titulo, style: textos.titleSmall),
                    Text(
                      evento.detalle,
                      style: mono?.copyWith(
                        fontSize: textos.bodySmall?.fontSize,
                        color: esquema.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: medidas.espacioM),
            if (evento.accion != null)
              OutlinedButton(
                onPressed: evento.onAccion,
                style: OutlinedButton.styleFrom(
                  foregroundColor: semanticos.revisar.contorno,
                  side: BorderSide(color: semanticos.revisar.contorno),
                ),
                child: Text(evento.accion!),
              )
            else if (evento.momento != null)
              ExcludeSemantics(
                child: Text(
                  evento.momento!,
                  style: textos.bodySmall?.copyWith(
                    color: esMovido ? esquema.tertiary : semanticos.tintaTenue,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Un punto que pulsa en opacidad (`BsMovimiento.pulso`): «Al día», «En vivo».
/// Quieto si el sistema pide reducir el movimiento o si no está [activo].
class BsPulso extends StatefulWidget {
  /// Crea el punto.
  const BsPulso({super.key, required this.color, this.activo = true, this.tamano = 9});

  /// El color del punto.
  final Color color;

  /// Si pulsa.
  final bool activo;

  /// El diámetro.
  final double tamano;

  @override
  State<BsPulso> createState() => _BsPulsoState();
}

class _BsPulsoState extends State<BsPulso> with SingleTickerProviderStateMixin {
  late final AnimationController _controlador = AnimationController(
    vsync: this,
    duration: BsMovimiento.pulso,
  );
  late final Animation<double> _opacidad = Tween<double>(begin: 1, end: 0.45)
      .chain(CurveTween(curve: BsMovimiento.vaiven))
      .animate(_controlador);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _ajustar();
  }

  @override
  void didUpdateWidget(BsPulso anterior) {
    super.didUpdateWidget(anterior);
    if (anterior.activo != widget.activo) _ajustar();
  }

  void _ajustar() {
    if (widget.activo && !BsMovimiento.reducido(context)) {
      if (!_controlador.isAnimating) _controlador.repeat(reverse: true);
    } else {
      _controlador.stop();
      _controlador.value = 0;
    }
  }

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
        opacity: _opacidad,
        child: Container(
          width: widget.tamano,
          height: widget.tamano,
          decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
        ),
      );
}
