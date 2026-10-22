import 'dart:convert';

/// Cuántas ranuras tiene la paleta categórica de «Colorear por»: doce tonos en
/// dos luminosidades (`DESIGN.md`, sección 5.2; decisión 10.4).
const int ranurasCategoricas = 24;

/// Los puertos de destino con ranura fija, confirmados por Carlos (decisión
/// 10.6 de `SPRINT-4.md`): las ranuras 0 a 14, en este orden.
///
/// Las ranuras 15 a 23 quedan libres para los puertos que asigne la oficina
/// (T-115). `XXVSL`, que salía en el corpus, no entra: no es un UN/LOCODE.
const Map<String, int> tablaFijaDePuertos = <String, int>{
  'JMKIN': 0,
  'USHOU': 1,
  'GTSTC': 2,
  'JMKCT': 3,
  'PAMIT': 4,
  'COSPC': 5,
  'JMKWL': 6,
  'PACCT': 7,
  'GTPBR': 8,
  'USPEF': 9,
  'PAONX': 10,
  'VEPBL': 11,
  'VELAG': 12,
  'COCTG': 13,
  'USMSY': 14,
};

/// La primera ranura de puertos que no tiene puerto fijo: de aquí a la 23 las
/// asigna la oficina (T-115).
const int primeraRanuraLibreDePuertos = 15;

/// Los tipos ISO de vacío con ranura fija, confirmados en 10.6: las ranuras
/// 0 a 12, en este orden.
const Map<String, int> tablaFijaDeTipos = <String, int>{
  '45G1': 0,
  '22G1': 1,
  '45G0': 2,
  'L5G1': 3,
  '45R1': 4,
  '42G1': 5,
  '42U1': 6,
  '42P3': 7,
  'L5G0': 8,
  '22K2': 9,
  '22U1': 10,
  '22T1': 11,
  '45R8': 12,
};

/// Las dos tablas fijas juntas: lo que entra por omisión en el tema.
///
/// Un puerto (cinco letras) y un tipo ISO (cuatro caracteres) nunca comparten
/// código, y sus vistas de «Colorear por» nunca coinciden en pantalla, así que
/// pueden compartir ranura. T-115 añade encima las asignaciones de la oficina.
const Map<String, int> tablaFijaConfirmada = <String, int>{
  ...tablaFijaDePuertos,
  ...tablaFijaDeTipos,
};

/// FNV-1a de 32 bits sobre [texto] en mayúsculas y UTF-8.
///
/// Es la función que asigna ranura a un código que no está en la tabla fija.
/// Va en aritmética de 16 bits por mitades para dar el mismo resultado en la
/// VM y en JavaScript, donde un producto de 32 × 25 bits perdería precisión.
int fnv1a32(String texto) {
  var hash = 0x811C9DC5;
  for (final byte in utf8.encode(texto.toUpperCase())) {
    hash = _multiplica32(hash ^ byte, 0x01000193);
  }
  return hash;
}

/// `(a * b) mod 2^32` sin pasar de 2^53 en ningún paso intermedio.
int _multiplica32(int a, int b) {
  final alto = (a >> 16) & 0xFFFF;
  final bajo = a & 0xFFFF;
  return ((bajo * b) + (((alto * b) & 0xFFFF) << 16)) & 0xFFFFFFFF;
}

/// La ranura (de 0 a [ranurasCategoricas] − 1) de un código de puerto o de
/// tipo ISO.
///
/// La [tablaFija] manda: por omisión del tema es [tablaFijaConfirmada] (10.6),
/// con los códigos en mayúsculas. Lo que no esté en ella usa [fnv1a32], que es
/// puro y no depende del viaje ni del dispositivo: un código se ve del mismo
/// color en la oficina, en el muelle, en la Web y en cualquier viaje.
int ranuraCategorica(String codigo, {Map<String, int> tablaFija = const {}}) {
  final clave = codigo.trim().toUpperCase();
  final fija = tablaFija[clave];
  if (fija != null) return fija % ranurasCategoricas;
  return fnv1a32(clave) % ranurasCategoricas;
}
