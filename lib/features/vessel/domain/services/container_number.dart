/// T-144 · La matrícula de un contenedor como identidad: sin espacios y en
/// mayúsculas.
///
/// La guía SMDG de la BAPLIE 2.2.1 (06/2016, p. 25, EQD c237.e8260) pide el
/// número como «one continuous string»: «SCXU 2387653 must be transmitted as
/// "SCXU2387653"», y «EU 876» como «EU876». La 1.5 (05/1993, p. 22) hace lo
/// contrario: rellena el prefijo con espacios hasta cinco posiciones, y así
/// llega `CORPUS_A06`. Para que el mismo contenedor sea el mismo en el plano,
/// el listado, la búsqueda, los movimientos y las exportaciones, se quita todo
/// espacio en blanco (también el duro y la tabulación) y se pasa a mayúsculas.
///
/// No se completa ni se recorta a las 11 posiciones de ISO 6346: un número que
/// no tiene esa forma queda como viene, sin espacios. En pantalla se sigue
/// agrupando con `formatearContenedor`.
String numeroDeContenedor(String numero) =>
    numero.replaceAll(RegExp(r'\s'), '').toUpperCase();
