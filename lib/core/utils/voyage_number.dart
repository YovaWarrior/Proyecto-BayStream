/// Número de viaje que guarda el lector cuando el segmento TDT no lo trae.
///
/// Es un valor guardado y forma parte de la identidad del viaje y de los
/// nombres de archivo: no cambia (T-112).
const unknownVoyageNumber = 'UNKNOWN';

/// El número de viaje como se muestra en pantalla y en el PDF (T-112): «sin
/// número» en lugar del marcador interno.
String voyageNumberLabel(String voyageNumber) =>
    voyageNumber == unknownVoyageNumber ? 'sin número' : voyageNumber;
