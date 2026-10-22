import 'package:flutter/material.dart';

import '../bs_formato.dart';
import '../bs_medidas.dart';

/// Una bahía en la tira: su número, su ocupación (de 0 a 1; nula sin
/// geometría) y su peso en kilos.
@immutable
class BsBahiaDeTira {
  /// Crea la bahía.
  const BsBahiaDeTira({required this.numero, this.ocupacion, this.pesoKg});

  /// El número de bahía.
  final int numero;

  /// La ocupación contra la geometría, de 0 a 1; nula si no hay geometría.
  final double? ocupacion;

  /// El peso de la bahía en kilos, para la vista por peso.
  final double? pesoKg;
}

/// La silueta del buque como selector de bahías (`DESIGN.md`, sección 4.3):
/// proa a la izquierda, popa a la derecha, una casilla por bahía con su número
/// debajo; la altura de cada barra sigue la ocupación (o el peso), y tocarla
/// la selecciona. Cada casilla mide al menos 48 dp de ancho y 64 de alto.
///
/// Es la firma de la dirección A: el perfil longitudinal que vivía en
/// Estadísticas, convertido en el control principal del plano.
class BsTiraDeBahias extends StatelessWidget {
  /// Crea la tira.
  const BsTiraDeBahias({
    super.key,
    required this.bahias,
    required this.onSeleccion,
    this.seleccionada,
    this.porPeso = false,
    this.controlador,
  });

  /// Las bahías, de proa a popa.
  final List<BsBahiaDeTira> bahias;

  /// La bahía seleccionada.
  final int? seleccionada;

  /// Qué pasa al tocar una bahía.
  final ValueChanged<int> onSeleccion;

  /// Barras por peso en vez de por ocupación.
  final bool porPeso;

  /// El controlador del desplazamiento horizontal, si la pantalla lo maneja.
  final ScrollController? controlador;

  /// El alto de la tira.
  static const double alto = 64;

  @override
  Widget build(BuildContext context) {
    final medidas = BsMedidas.de(context);
    final esquema = Theme.of(context).colorScheme;
    final maximoPeso = bahias.fold<double>(
        0, (maximo, bahia) => (bahia.pesoKg ?? 0) > maximo ? bahia.pesoKg! : maximo);
    return SizedBox(
      height: alto,
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: RepaintBoundary(
              child: CustomPaint(
                painter: _CascoPainter(color: esquema.outlineVariant),
              ),
            ),
          ),
          ListView.builder(
            controller: controlador,
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: medidas.espacioL),
            itemCount: bahias.length,
            itemBuilder: (BuildContext context, int indice) {
              final bahia = bahias[indice];
              final fraccion = porPeso
                  ? (maximoPeso > 0 ? (bahia.pesoKg ?? 0) / maximoPeso : 0.0)
                  : (bahia.ocupacion ?? 0);
              return _Casilla(
                bahia: bahia,
                fraccion: fraccion.clamp(0.0, 1.0).toDouble(),
                seleccionada: bahia.numero == seleccionada,
                porPeso: porPeso,
                onTap: () => onSeleccion(bahia.numero),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Casilla extends StatelessWidget {
  const _Casilla({
    required this.bahia,
    required this.fraccion,
    required this.seleccionada,
    required this.porPeso,
    required this.onTap,
  });

  final BsBahiaDeTira bahia;
  final double fraccion;
  final bool seleccionada;
  final bool porPeso;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final medidas = BsMedidas.de(context);
    final esquema = Theme.of(context).colorScheme;
    final textos = Theme.of(context).textTheme;
    final numero = bahia.numero.toString().padLeft(2, '0');
    final magnitud = porPeso
        ? (bahia.pesoKg == null
            ? 'sin peso'
            : formatearToneladas(bahia.pesoKg!))
        : (bahia.ocupacion == null
            ? 'sin geometría'
            : '${formatearPorcentaje(bahia.ocupacion!)} de ocupación');
    final relleno = Color.lerp(esquema.primaryContainer, esquema.primary, fraccion)!;
    return Semantics(
      button: true,
      selected: seleccionada,
      label: 'Bahía $numero, $magnitud',
      onTap: onTap,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(medidas.radioControl),
        child: SizedBox(
          width: medidas.objetivoTactil,
          height: BsTiraDeBahias.alto,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Container(
                width: medidas.espacioXl + medidas.espacioXs,
                height: medidas.espacioXs + fraccion * medidas.espacioXxl,
                decoration: BoxDecoration(
                  color: relleno,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(medidas.radioCelda),
                  ),
                  border: seleccionada
                      ? Border.all(color: esquema.primary, width: 2)
                      : null,
                ),
              ),
              SizedBox(height: medidas.espacioXs),
              Text(
                numero,
                style: (seleccionada ? textos.titleSmall : textos.labelMedium)
                    ?.copyWith(
                  color: seleccionada ? esquema.primary : esquema.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// El casco: una línea que recorre el pie de la tira y se levanta en la proa.
class _CascoPainter extends CustomPainter {
  const _CascoPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final pintura = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final pie = size.height - 18;
    final casco = Path()
      ..moveTo(4, pie - 14)
      ..quadraticBezierTo(10, pie, 28, pie)
      ..lineTo(size.width - 16, pie)
      ..quadraticBezierTo(size.width - 4, pie - 4, size.width - 4, pie - 12);
    canvas.drawPath(casco, pintura);
  }

  @override
  bool shouldRepaint(_CascoPainter oldDelegate) => oldDelegate.color != color;
}
