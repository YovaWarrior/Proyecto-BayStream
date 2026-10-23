import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import 'bs_iconos_catalogo.dart';
import 'bs_ilustraciones.dart';
import 'componentes/bs_ilustracion.dart';
import 'vistas_previas.dart' show bsTemaDeVistaPrevia, bsTemaDeVistaPreviaOficina;

// Las vistas previas del paquete de íconos e ilustraciones (10.19), para
// `flutter widget-preview start`: los 31 íconos del dominio a 24 y a 16 px,
// las cuatro insignias a 12 px y las seis ilustraciones, de día y de noche.

/// Un lienzo con el papel del tema y relleno alrededor.
Widget _lienzo(Widget hijo) => Builder(
      builder: (BuildContext context) => Material(
        color: Theme.of(context).colorScheme.surface,
        child: Padding(padding: const EdgeInsets.all(16), child: hijo),
      ),
    );

/// Un ícono a 24 y a 16 px con su nombre del paquete debajo.
Widget _muestraDeIcono(String nombre, IconData icono, {double rejilla = 24}) =>
    Builder(
      builder: (BuildContext context) => SizedBox(
        width: 112,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(icono, size: rejilla),
                const SizedBox(width: 8),
                Icon(icono, size: rejilla == 24 ? 16 : rejilla),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              nombre,
              style: Theme.of(context).textTheme.labelSmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );

/// Los 31 íconos del dominio en tinta, a 24 y a 16 px, con su nombre.
@Preview(
  name: 'Íconos del dominio · 24 y 16 px',
  group: 'Diseño',
  theme: bsTemaDeVistaPreviaOficina,
)
Widget vistaPreviaIconos() => _lienzo(Wrap(
      spacing: 8,
      runSpacing: 16,
      children: <Widget>[
        for (final entrada in BsIconosCatalogo.iconos.entries)
          _muestraDeIcono(entrada.key, entrada.value),
      ],
    ));

/// Los mismos, de noche.
@Preview(
  name: 'Íconos del dominio · 24 y 16 px, noche',
  group: 'Diseño',
  theme: bsTemaDeVistaPreviaOficina,
  brightness: Brightness.dark,
)
Widget vistaPreviaIconosOscuro() => vistaPreviaIconos();

/// Las cuatro insignias a 12 px, como van en la esquina de la celda, y al
/// doble para verlas.
@Preview(name: 'Insignias · 12 px', group: 'Diseño', theme: bsTemaDeVistaPrevia)
Widget vistaPreviaInsignias() => _lienzo(Wrap(
      spacing: 8,
      runSpacing: 16,
      children: <Widget>[
        for (final entrada in BsIconosCatalogo.insignias.entries)
          Builder(
            builder: (BuildContext context) => SizedBox(
              width: 136,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(entrada.value, size: 12),
                      const SizedBox(width: 8),
                      Icon(entrada.value, size: 24),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(entrada.key,
                      style: Theme.of(context).textTheme.labelSmall),
                ],
              ),
            ),
          ),
      ],
    ));

/// Las seis ilustraciones sobre el papel del día, con su nombre.
@Preview(name: 'Ilustraciones · día', group: 'Diseño', theme: bsTemaDeVistaPrevia)
Widget vistaPreviaIlustraciones() => _lienzo(Wrap(
      spacing: 16,
      runSpacing: 16,
      children: <Widget>[
        for (final datos in BsIlustraciones.todas)
          Builder(
            builder: (BuildContext context) => SizedBox(
              width: datos.nombre == 'inicio' ? 400 : 320,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  BsIlustracion(datos: datos),
                  const SizedBox(height: 4),
                  Text(datos.nombre,
                      style: Theme.of(context).textTheme.labelSmall),
                ],
              ),
            ),
          ),
      ],
    ));

/// Las mismas, de noche.
@Preview(
  name: 'Ilustraciones · noche',
  group: 'Diseño',
  theme: bsTemaDeVistaPrevia,
  brightness: Brightness.dark,
)
Widget vistaPreviaIlustracionesOscuro() => vistaPreviaIlustraciones();
