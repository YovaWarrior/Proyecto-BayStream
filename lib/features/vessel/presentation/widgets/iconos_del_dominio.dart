import 'package:flutter/widgets.dart';

import '../../../../core/design/design.dart';
import '../../domain/entities/entities.dart';

/// El ícono del dominio de un contenedor (`DESIGN.md` 13.11): manda la carga
/// especial (peligrosa, refrigerado, fuera de medida); después, el vacío;
/// luego el tipo ISO (tanque, plataforma, techo abierto) y, si no, el tamaño
/// (20, 40 o 45 pies). Es la misma regla en la lista, en la búsqueda y en el
/// detalle, para que un contenedor se vea igual en todas partes.
IconData iconoDeContenedor(ContainerUnit contenedor) {
  if (contenedor.isDangerous) return BsIconos.peligrosa;
  if (contenedor.isReefer) return BsIconos.refrigerado;
  if (contenedor.isOverDimension) return BsIconos.fueraDeMedida;
  if (contenedor.status == ContainerStatus.empty) return BsIconos.vacio;
  return iconoDeTipo(contenedor.containerType, pies: contenedor.sizeInFeet);
}

/// El ícono del tipo ISO; con el tipo genérico (o sin tipo), el del tamaño.
IconData iconoDeTipo(ContainerType? tipo, {int? pies}) => switch (tipo) {
      ContainerType.reefer => BsIconos.refrigerado,
      ContainerType.tank => BsIconos.tanque,
      ContainerType.openTop => BsIconos.techoAbierto,
      ContainerType.flatRack => BsIconos.plataforma,
      _ => iconoDeTamano(pies),
    };

/// El contenedor de 20, 40 o 45 pies; sin tamaño declarado, el de 40.
IconData iconoDeTamano(int? pies) => switch (pies) {
      20 => BsIconos.contenedor20,
      45 => BsIconos.contenedor45,
      _ => BsIconos.contenedor40,
    };
