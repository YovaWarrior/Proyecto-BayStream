import 'package:flutter/material.dart';

import '../../../../core/design/design.dart';
import '../../domain/entities/entities.dart';

/// Lo que el ícono principal de un contenedor dice (`DESIGN.md` 13.11): manda
/// la carga especial (peligrosa, refrigerado, fuera de medida); después, el
/// vacío; luego el tipo ISO (tanque, plataforma, techo abierto) y, si no, el
/// tamaño (20, 40 o 45 pies). Cada condición lleva su glifo del paquete y su
/// nombre, para que el lector de pantalla oiga lo mismo que el glifo muestra.
/// Es una sola regla para la Lista, la búsqueda y el detalle (H1 y O1 de la
/// aceptación del paquete, 10.23).
enum CondicionDelContenedor {
  /// Carga peligrosa (IMDG).
  peligrosa(BsIconos.peligrosa, 'Carga peligrosa'),

  /// Refrigerado, por la marca del archivo o por el tipo ISO.
  refrigerado(BsIconos.refrigerado, 'Refrigerado'),

  /// Fuera de medida (OOG).
  fueraDeMedida(BsIconos.fueraDeMedida, 'Fuera de medida'),

  /// Vacío.
  vacio(BsIconos.vacio, 'Vacío'),

  /// Tanque (ISO T).
  tanque(BsIconos.tanque, 'Tanque'),

  /// Plataforma (ISO P).
  plataforma(BsIconos.plataforma, 'Plataforma'),

  /// Techo abierto (ISO U).
  techoAbierto(BsIconos.techoAbierto, 'Techo abierto'),

  /// Contenedor de 20 pies.
  contenedor20(BsIconos.contenedor20, 'Contenedor de 20 pies'),

  /// Contenedor de 40 pies; también el que no declara tamaño.
  contenedor40(BsIconos.contenedor40, 'Contenedor de 40 pies'),

  /// Contenedor de 45 pies.
  contenedor45(BsIconos.contenedor45, 'Contenedor de 45 pies');

  const CondicionDelContenedor(this.icono, this.nombre);

  /// El glifo del paquete.
  final IconData icono;

  /// Lo que el ícono dice: su etiqueta accesible y su descripción emergente.
  final String nombre;

  /// Si la celda del plano la señala, con la insignia de la esquina (carga
  /// peligrosa, refrigerado, fuera de medida) o con el color del vacío, y por
  /// eso la nombra en su etiqueta accesible. El tipo y el tamaño no se
  /// señalan en la celda y no van en esa etiqueta.
  bool get enLaCelda => switch (this) {
        peligrosa || refrigerado || fueraDeMedida || vacio => true,
        _ => false,
      };
}

/// La condición de un contenedor, con la prioridad de `DESIGN.md` 13.11.
CondicionDelContenedor condicionDelContenedor(ContainerUnit contenedor) {
  if (contenedor.isDangerous) return CondicionDelContenedor.peligrosa;
  if (contenedor.isReefer) return CondicionDelContenedor.refrigerado;
  if (contenedor.isOverDimension) return CondicionDelContenedor.fueraDeMedida;
  if (contenedor.status == ContainerStatus.empty) {
    return CondicionDelContenedor.vacio;
  }
  return condicionDelTipo(contenedor.containerType,
      pies: contenedor.sizeInFeet);
}

/// La condición por el tipo ISO; con el tipo genérico (o sin tipo), la del
/// tamaño.
CondicionDelContenedor condicionDelTipo(ContainerType? tipo, {int? pies}) =>
    switch (tipo) {
      ContainerType.reefer => CondicionDelContenedor.refrigerado,
      ContainerType.tank => CondicionDelContenedor.tanque,
      ContainerType.openTop => CondicionDelContenedor.techoAbierto,
      ContainerType.flatRack => CondicionDelContenedor.plataforma,
      _ => condicionDelTamano(pies),
    };

/// La condición por el tamaño: 20, 40 o 45 pies; sin tamaño declarado, 40.
CondicionDelContenedor condicionDelTamano(int? pies) => switch (pies) {
      20 => CondicionDelContenedor.contenedor20,
      45 => CondicionDelContenedor.contenedor45,
      _ => CondicionDelContenedor.contenedor40,
    };

/// El ícono del dominio de un contenedor: el glifo de su condición.
IconData iconoDeContenedor(ContainerUnit contenedor) =>
    condicionDelContenedor(contenedor).icono;

/// El ícono del tipo ISO; con el tipo genérico (o sin tipo), el del tamaño.
IconData iconoDeTipo(ContainerType? tipo, {int? pies}) =>
    condicionDelTipo(tipo, pies: pies).icono;

/// El contenedor de 20, 40 o 45 pies; sin tamaño declarado, el de 40.
IconData iconoDeTamano(int? pies) => condicionDelTamano(pies).icono;

/// El ícono principal de un contenedor en la Lista, la búsqueda y el detalle:
/// el glifo de su condición, con el nombre como etiqueta accesible y como
/// descripción emergente. La descripción queda fuera de la semántica para que
/// el lector de pantalla no diga el nombre dos veces: la etiqueta ya lo dice.
class IconoDelContenedor extends StatelessWidget {
  /// Crea el ícono. [marco] envuelve al glifo (el círculo del resultado, el
  /// recuadro de la tarjeta), y la descripción emergente lo cubre entero.
  const IconoDelContenedor(
    this.contenedor, {
    super.key,
    this.tamano = 24,
    this.color,
    this.marco,
  });

  /// El contenedor.
  final ContainerUnit contenedor;

  /// El tamaño del glifo: 16, 20 o 24 (`DESIGN.md` 13.11, regla 1).
  final double tamano;

  /// El color del glifo; sin él, el del tema.
  final Color? color;

  /// Lo que rodea al glifo, si algo lo rodea.
  final Widget Function(Widget icono)? marco;

  @override
  Widget build(BuildContext context) {
    final condicion = condicionDelContenedor(contenedor);
    final icono = Icon(
      condicion.icono,
      size: tamano,
      color: color,
      semanticLabel: condicion.nombre,
    );
    return Tooltip(
      message: condicion.nombre,
      excludeFromSemantics: true,
      child: marco == null ? icono : marco!(icono),
    );
  }
}
