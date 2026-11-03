import 'package:flutter/material.dart';

/// La paleta de la dirección C, «Puente de mando» (`DESIGN.md`, 13.1): el día
/// de la Fase 2 (4.1) y la noche de 10.14.
///
/// Son los colores con nombre y sus derivados, en claro y en oscuro. Es la
/// **única** fuente de hexadecimales de la capa de presentación: todo lo demás
/// los toma del [ColorScheme] del tema o de la extensión semántica.
///
/// Entre el día y la noche cambia la luminosidad, no el tono, salvo en la
/// marca: de noche el azul del ícono no llega a 3:1 sobre la noche como texto,
/// así que pasa a ser superficie ([marcaTenue] y [marcaSuperficie], con texto
/// blanco a 8.6:1) y el texto y la selección van en el azul de selección
/// ([marca]). Cada par de texto y fondo está verificado con
/// `tool/rediseno_contraste.py` (`docs/rediseno/fase2bis/contraste.md`): AA
/// 4.5:1 para el texto y 3:1 para los bordes esenciales.
@immutable
class BsPaleta {
  /// Crea una paleta. En el producto solo existen [claro] y [oscuro].
  const BsPaleta({
    required this.brillo,
    required this.papel,
    required this.hoja,
    required this.hojaAlta,
    required this.tinta,
    required this.tintaSuave,
    required this.tintaTenue,
    required this.linea,
    required this.lineaFuerte,
    required this.marca,
    required this.sobreMarca,
    required this.marcaTenue,
    required this.marcaSuperficie,
    required this.sobreMarcaSuperficie,
    required this.sobreMarcaSuave,
    required this.marcaProfunda,
    required this.acero,
    required this.aceroTenue,
    required this.sobreAcero,
    required this.grua,
    required this.gruaRelleno,
    required this.sobreGrua,
    required this.rampaDeMagnitud,
    required this.pistaDeMagnitud,
    required this.metalMuelle,
    required this.metalOficina,
  });

  /// Claro u oscuro.
  final Brightness brillo;

  /// El fondo de la app: el papel de día, la noche de noche (con la rejilla de
  /// plano al 5 % de acero, que pinta `BsFondoDePlano`).
  final Color papel;

  /// Las superficies que se apoyan en el papel: tarjetas, hojas, paneles.
  final Color hoja;

  /// Una superficie por encima de la hoja: la fila activa, los chips de
  /// estado, la celda de paso de noche.
  final Color hojaAlta;

  /// Texto, iconos y bordes fuertes.
  final Color tinta;

  /// Texto secundario: metadatos, ayudas, rótulos.
  final Color tintaSuave;

  /// Texto terciario: el momento de un evento, el detalle de una tarjeta, los
  /// números de bahía no seleccionados.
  final Color tintaTenue;

  /// Separadores y la pista de las barras de avance, sin exigencia de
  /// contraste.
  final Color linea;

  /// Bordes esenciales, como el contorno de una celda o el casco (3:1 sobre el
  /// papel, la hoja, la hoja alta y el acero tenue).
  final Color lineaFuerte;

  /// La acción principal, el foco y la selección de celda y de bahía, como
  /// texto o como icono: la semilla del ícono de día, el azul de selección de
  /// noche.
  final Color marca;

  /// Texto sobre [marca].
  final Color sobreMarca;

  /// De día, el tinte de marca (chip seleccionado, indicador del riel); de
  /// noche, la marca como superficie (el riel activo, el chip seleccionado, el
  /// botón tonal), con texto en [tinta].
  final Color marcaTenue;

  /// La marca como superficie en los dos modos: la banda del muelle y el
  /// recuadro del ícono. Texto encima: [sobreMarcaSuperficie] y
  /// [sobreMarcaSuave].
  final Color marcaSuperficie;

  /// Texto blanco sobre [marcaSuperficie] (8.6:1).
  final Color sobreMarcaSuperficie;

  /// Texto secundario sobre [marcaSuperficie]: la frase de la banda (5.6:1).
  final Color sobreMarcaSuave;

  /// Un azul más profundo dentro de la banda: el chip de la nube (blanco
  /// encima, 10.7:1).
  final Color marcaProfunda;

  /// La bodega del ícono: por bajar en bodega, el segundo plano de la silueta.
  final Color acero;

  /// Relleno tenue de acero: la zona de bodega de la rejilla y el casco.
  final Color aceroTenue;

  /// Texto sobre [acero]: siempre tinta oscura, en los dos modos.
  final Color sobreAcero;

  /// Texto e iconos naranja: lo que se acaba de mover.
  final Color grua;

  /// Relleno naranja: solo la celda que se acaba de mover y el contenedor del
  /// ícono.
  final Color gruaRelleno;

  /// Texto sobre [gruaRelleno]: siempre tinta oscura, en los dos modos.
  final Color sobreGrua;

  /// La rampa de magnitudes de Estadísticas (`DESIGN.md`, 15.3): cuatro
  /// pasos de un solo tono, el azul de la marca, de menos a más. De día de
  /// claro a oscuro; de noche se invierte, de oscuro a claro, porque sobre la
  /// noche «más» tiene que ser más luminoso. Validada con el script de la
  /// skill de dataviz (`validate_palette.js --ordinal`): el paso extremo
  /// queda a 2:1 o más de la hoja y del papel, los pasos son visibles y es un
  /// solo tono. Va en lo ordenado (20, 40 y 45 pies); una sola serie va en
  /// [marca], no en la rampa. Nunca colorea texto.
  final List<Color> rampaDeMagnitud;

  /// La pista de las barras de Estadísticas: un paso más claro (de día) o
  /// más oscuro (de noche) del mismo tono que la rampa, para que la barra se
  /// lea entera, también donde no llega. No es un dato.
  final Color pistaDeMagnitud;

  /// El distintivo de rol del muelle (`DESIGN.md` 13.12; 10.86): el cobre de
  /// la presentación del 7-nov. Igual en claro y en oscuro.
  final BsMetalDeRol metalMuelle;

  /// El distintivo de rol de la oficina: el oro. Igual en claro y en oscuro.
  final BsMetalDeRol metalOficina;

  /// El cobre del muelle: el fondo de la banda en azul profundo, el filo de
  /// cobre y el ícono en cobre claro; el brillo, blanco al 18 %, y la sombra,
  /// la noche al 35 % (el lienzo de 10.86).
  static const BsMetalDeRol _cobre = BsMetalDeRol(
    fondoArriba: Color(0xFF0B3E93),
    fondoAbajo: Color(0xFF082F70),
    filoClaro: Color(0xFFF8D2B6),
    filoMedio: Color(0xFFE0895A),
    filoOscuro: Color(0xFF9E5530),
    icono: Color(0xFFF4B48E),
    rotulo: Color(0xFFFFFFFF),
    brillo: Color(0x2EFFFFFF),
    sombra: Color(0x5907111F),
  );

  /// El oro de la oficina: el fondo en el azul de la noche, el filo de oro y
  /// el ícono en oro; el brillo, blanco al 14 %, y la sombra, negro al 40 %.
  static const BsMetalDeRol _oro = BsMetalDeRol(
    fondoArriba: Color(0xFF16305C),
    fondoAbajo: Color(0xFF0E2244),
    filoClaro: Color(0xFFFFF0C4),
    filoMedio: Color(0xFFF2C46D),
    filoOscuro: Color(0xFFA87A2C),
    icono: Color(0xFFF2C46D),
    rotulo: Color(0xFFF4F6FB),
    brillo: Color(0x24FFFFFF),
    sombra: Color(0x66000000),
  );

  /// La paleta del día (el muelle): la de la Fase 2, sin cambios.
  static const BsPaleta claro = BsPaleta(
    brillo: Brightness.light,
    papel: Color(0xFFF5F8FC),
    hoja: Color(0xFFFFFFFF),
    hojaAlta: Color(0xFFE9EFF7),
    tinta: Color(0xFF10243F),
    tintaSuave: Color(0xFF4A5B73),
    tintaTenue: Color(0xFF566986),
    linea: Color(0xFFC9D3E0),
    lineaFuerte: Color(0xFF6D809F),
    marca: Color(0xFF0D47A1),
    sobreMarca: Color(0xFFFFFFFF),
    marcaTenue: Color(0xFFDCE7F8),
    marcaSuperficie: Color(0xFF0D47A1),
    sobreMarcaSuperficie: Color(0xFFFFFFFF),
    sobreMarcaSuave: Color(0xFFBCD2F7),
    marcaProfunda: Color(0xFF0A3A85),
    acero: Color(0xFF6E9DE6),
    aceroTenue: Color(0xFFE3EDFB),
    sobreAcero: Color(0xFF10243F),
    grua: Color(0xFFC2410C),
    gruaRelleno: Color(0xFFFF7A1A),
    sobreGrua: Color(0xFF10243F),
    // 2.19:1 sobre la hoja y 2.06:1 sobre el papel en el paso claro
    // (0.9.4 de docs/T117-T121-RESULTADOS.md); el último paso es la marca.
    rampaDeMagnitud: <Color>[
      Color(0xFF88B0F5),
      Color(0xFF518FF1),
      Color(0xFF1365E5),
      Color(0xFF0D47A1),
    ],
    pistaDeMagnitud: Color(0xFFD9E7FC),
    metalMuelle: _cobre,
    metalOficina: _oro,
  );

  /// La paleta de la noche (la oficina), de 10.14.
  static const BsPaleta oscuro = BsPaleta(
    brillo: Brightness.dark,
    papel: Color(0xFF07111F),
    hoja: Color(0xFF0C1A31),
    hojaAlta: Color(0xFF11223F),
    tinta: Color(0xFFEAF0F9),
    tintaSuave: Color(0xFFA9B9D2),
    tintaTenue: Color(0xFF8DA0BE),
    linea: Color(0xFF1E3457),
    lineaFuerte: Color(0xFF5272A6),
    marca: Color(0xFF4F8EF7),
    sobreMarca: Color(0xFF07111F),
    marcaTenue: Color(0xFF0D47A1),
    marcaSuperficie: Color(0xFF0D47A1),
    sobreMarcaSuperficie: Color(0xFFFFFFFF),
    sobreMarcaSuave: Color(0xFFBCD2F7),
    marcaProfunda: Color(0xFF0A3A85),
    acero: Color(0xFF6E9DE6),
    aceroTenue: Color(0xFF11213A),
    sobreAcero: Color(0xFF07111F),
    grua: Color(0xFFFF9A4D),
    gruaRelleno: Color(0xFFFF7A1A),
    sobreGrua: Color(0xFF07111F),
    // 2.62:1 sobre el panel y 2.86:1 sobre la noche en el paso oscuro; el
    // segundo paso es la selección de noche (la marca de este modo).
    rampaDeMagnitud: <Color>[
      Color(0xFF2C5BA8),
      Color(0xFF4F8EF7),
      Color(0xFF95BBF6),
      Color(0xFFD9E7FC),
    ],
    pistaDeMagnitud: Color(0xFF1E3457),
    // El metal no cambia con el tema (10.86).
    metalMuelle: _cobre,
    metalOficina: _oro,
  );

  /// La paleta que corresponde a un brillo.
  static BsPaleta de(Brightness brillo) =>
      brillo == Brightness.dark ? oscuro : claro;
}

/// El metal de un distintivo de rol (`DESIGN.md` 13.12; 10.86, la variante B
/// «Filo de metal»): los colores de la presentación del 7-nov, el cobre del
/// muelle y el oro de la oficina.
///
/// El metal va solo en el filo y en el ícono, nunca de relleno: así no se
/// confunde con el naranja de «recién movido» ni con el ámbar de «Revisar».
/// Es la única excepción a la escala de un solo tono y a «sin degradados»
/// (Carlos, 1-nov). No cambia con el tema: [BsPaleta.claro] y
/// [BsPaleta.oscuro] traen el mismo. Los pares están en
/// `tool/rediseno_contraste.py`: el rótulo a 4.5:1 o más sobre los dos
/// extremos del fondo, el ícono a 3:1 o más, y el filo o el relleno a 3:1 o
/// más contra cada fondo donde va.
@immutable
class BsMetalDeRol {
  /// Crea un metal. En el producto solo existen el cobre y el oro de
  /// [BsPaleta].
  const BsMetalDeRol({
    required this.fondoArriba,
    required this.fondoAbajo,
    required this.filoClaro,
    required this.filoMedio,
    required this.filoOscuro,
    required this.icono,
    required this.rotulo,
    required this.brillo,
    required this.sombra,
  });

  /// El relleno arriba; el degradado del fondo va de arriba abajo.
  final Color fondoArriba;

  /// El relleno abajo.
  final Color fondoAbajo;

  /// El filo a 135°: el claro, arriba a la izquierda.
  final Color filoClaro;

  /// El filo en [paradaMedia].
  final Color filoMedio;

  /// El filo oscuro, abajo a la derecha.
  final Color filoOscuro;

  /// El ícono del rol.
  final Color icono;

  /// El rótulo.
  final Color rotulo;

  /// El brillo de 1 dp arriba, por dentro: blanco con su opacidad.
  final Color brillo;

  /// La sombra leve, con su opacidad.
  final Color sombra;

  /// Dónde va [filoMedio] en el degradado del filo.
  static const double paradaMedia = 0.55;
}
