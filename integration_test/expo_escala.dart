// T-126 · El plano de llegada sintético de T-100, armado en memoria para la
// prueba de la Expo (integration_test/expo_recorrido_test.dart).
//
// Es T100_LLEGADA.edi de tool/t100_sintetico.dart: BUQUE MANUAL, viaje M100,
// emitido al salir de PAMIT rumbo a GTSTC, con 60 a bordo, 30 que se
// descargan en GTSTC y 30 de paso a USHOU y USMSY. Usa las piezas de ese
// script (la caja, la celda, el número y el mensaje) y repite solo el orden
// de las celdas y de las cajas, que allí vive dentro de main(). No escribe
// nada en disco y no usa el corpus.
import '../tool/t100_sintetico.dart' show Caja, celda, escala, id, mensaje;

/// El texto de T100_LLEGADA.edi.
String expoLlegada() {
  // Tres bahías de 40 pies; filas 01-06; bodega 02-06 y cubierta 82.
  const bahias = [2, 6, 10];
  final descargan = <String>[];
  final dePaso = <String>[];
  for (final b in bahias) {
    for (final f in [1, 2, 3, 4, 5, 6]) {
      descargan.add(celda(b, f, 6));
      dePaso.add(celda(b, f, 2));
      (f <= 2 ? descargan : dePaso).add(celda(b, f, 4));
    }
    descargan.add(celda(b, 1, 82));
    descargan.add(celda(b, 2, 82));
  }

  var n = 0;
  final llegada = <Caja>[];
  final transito = <Caja>[];
  for (var i = 0; i < 30; i++) {
    n++;
    llegada.add(Caja(id(n), i % 7 == 3 ? '45R1' : '45G1', descargan[i], 'PAMIT',
        escala, i.isEven ? 'MNA' : 'MNB', 12000 + 350 * i, true,
        temperatura: i % 7 == 3 ? -18.0 : null, un: i == 11 ? '3077' : null));
  }
  for (var i = 0; i < 30; i++) {
    n++;
    transito.add(Caja(
        id(n),
        i % 9 == 4 ? '45R1' : '42G1',
        dePaso[i],
        'HNPCR',
        i.isEven ? 'USHOU' : 'USMSY',
        i % 3 == 0 ? 'MNB' : 'MNA',
        9000 + 420 * i,
        i % 5 != 2,
        temperatura: i % 9 == 4 ? 4.0 : null,
        un: i == 20 ? '1950' : null));
  }
  return mensaje([...llegada, ...transito],
      salida: 'PAMIT', siguiente: escala, ref: 'M100LLEGADA');
}
