import 'dart:convert';

/// Cuántas ranuras tiene la paleta categórica de «Colorear por»: doce tonos en
/// dos luminosidades (`DESIGN.md`, sección 5.2; decisión 10.4).
const int ranurasCategoricas = 24;

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
/// La [tablaFija] manda: es la tabla que confirma Carlos (10.4), con los
/// códigos en mayúsculas. Lo que no esté en ella usa [fnv1a32], que es puro y
/// no depende del viaje ni del dispositivo: GTSTC se ve del mismo color en la
/// oficina, en el muelle, en la Web y en cualquier viaje.
int ranuraCategorica(String codigo, {Map<String, int> tablaFija = const {}}) {
  final clave = codigo.trim().toUpperCase();
  final fija = tablaFija[clave];
  if (fija != null) return fija % ranurasCategoricas;
  return fnv1a32(clave) % ranurasCategoricas;
}
