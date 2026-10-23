import 'package:flutter/widgets.dart';

import 'bs_iconos.dart';

/// El catálogo de los íconos del dominio (`DESIGN.md` 13, paquete de Nube,
/// 10.19): cada constante de [BsIconos] con el nombre que lleva en
/// `design/iconos/codigos.json` y en su SVG. `bs_iconos.dart` es un archivo
/// generado y se deja tal cual; esto es lo que las pruebas, los censos y las
/// vistas previas necesitan para recorrerlos.
///
/// Los 31 primeros se dibujan en la rejilla de 24 y se usan a 16, 20 o 24 px;
/// las cuatro insignias (`insignia_*`) se dibujan en la rejilla de 12 y van a
/// 12 px en la esquina de la celda.
abstract final class BsIconosCatalogo {
  /// Los 31 íconos del dominio, por su nombre del paquete.
  static const Map<String, IconData> iconos = <String, IconData>{
    'contenedor_20': BsIconos.contenedor20,
    'contenedor_40': BsIconos.contenedor40,
    'contenedor_45': BsIconos.contenedor45,
    'vacio': BsIconos.vacio,
    'refrigerado': BsIconos.refrigerado,
    'peligrosa': BsIconos.peligrosa,
    'fuera_de_medida': BsIconos.fueraDeMedida,
    'tanque': BsIconos.tanque,
    'plataforma': BsIconos.plataforma,
    'techo_abierto': BsIconos.techoAbierto,
    'buque': BsIconos.buque,
    'bahia': BsIconos.bahia,
    'tapa_escotilla': BsIconos.tapaEscotilla,
    'peso_pila': BsIconos.pesoPila,
    'limite_apilamiento': BsIconos.limiteApilamiento,
    'vgm': BsIconos.vgm,
    'segregacion': BsIconos.segregacion,
    'descarga': BsIconos.descarga,
    'carga': BsIconos.carga,
    'reestiba': BsIconos.reestiba,
    'pedir_cambio': BsIconos.pedirCambio,
    'orden': BsIconos.orden,
    'grua': BsIconos.grua,
    'muelle': BsIconos.muelle,
    'escala': BsIconos.escala,
    'baplie': BsIconos.baplie,
    'comparar_baplie': BsIconos.compararBaplie,
    'baplie_salida': BsIconos.baplieSalida,
    'listado_agencia': BsIconos.listadoAgencia,
    'al_dia': BsIconos.alDia,
    'solo_aqui': BsIconos.soloAqui,
  };

  /// Las cuatro insignias de 12 px, por su nombre del paquete.
  static const Map<String, IconData> insignias = <String, IconData>{
    'insignia_refrigerado': BsIconos.insigniaRefrigerado,
    'insignia_peligrosa': BsIconos.insigniaPeligrosa,
    'insignia_fuera_de_medida': BsIconos.insigniaFueraDeMedida,
    'insignia_vacio': BsIconos.insigniaVacio,
  };

  /// Los 35 glifos de la fuente, por su nombre del paquete.
  static const Map<String, IconData> todos = <String, IconData>{
    ...iconos,
    ...insignias,
  };

  /// El tamaño al que se dibujó cada glifo: 24 para los íconos, 12 para las
  /// insignias. Es la rejilla de su SVG y el tamaño al que coincide exacto.
  static double rejillaDe(String nombre) =>
      insignias.containsKey(nombre) ? 12 : 24;
}
