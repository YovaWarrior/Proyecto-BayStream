/// Cómo se escriben los números en pantalla (`DESIGN.md`, sección 11, regla 5).
///
/// Es Dart puro: lo usan los componentes de `lib/core/design/` y lo pueden
/// usar las pantallas sin pasar por un widget.
library;

/// Espacio fino que no parte la línea (U+202F): separador de miles.
const String espacioFino = ' ';

/// Espacio duro que no parte la línea (U+00A0): entre la cifra y su unidad.
const String espacioDuro = ' ';

/// Signo menos tipográfico (U+2212).
const String menos = '−';

/// «MSCU1234567» → «MSCU 123456 7»: propietario, serie y dígito de control.
///
/// Lo que no tenga once caracteres se devuelve tal cual, sin espacios de más.
String formatearContenedor(String numero) {
  final limpio = numero.trim().toUpperCase().replaceAll(' ', '');
  if (limpio.length != 11) return numero.trim();
  return '${limpio.substring(0, 4)} ${limpio.substring(4, 10)} '
      '${limpio.substring(10)}';
}

/// «0020182» → «002-01-82»: bahía, fila y nivel como en el plano impreso.
///
/// Admite la posición con guiones o espacios. Lo que no sean siete dígitos se
/// devuelve tal cual.
String formatearPosicion(String posicion) {
  final digitos = posicion.replaceAll(RegExp(r'[\s-]'), '');
  if (digitos.length != 7 || int.tryParse(digitos) == null) {
    return posicion.trim();
  }
  return '${digitos.substring(0, 3)}-${digitos.substring(3, 5)}-'
      '${digitos.substring(5)}';
}

/// Kilos → «28.7 t»: toneladas con un decimal y la unidad pegada con espacio
/// duro. Es la única unidad de peso en pantalla; los kilos van en el detalle.
///
/// Redondea a la décima más cercana con el medio hacia arriba: 28 650 kg son
/// «28.7 t». `toStringAsFixed(1)` daría «28.6» por cómo se guarda 28.65 en
/// binario.
String formatearToneladas(double kilos) {
  final decimas = (kilos / 100).round().abs();
  final signo = kilos < 0 ? menos : '';
  return '$signo${decimas ~/ 10}.${decimas % 10}${espacioDuro}t';
}

/// Kilos → «28 650 kg»: sin decimales, miles con espacio fino.
String formatearKilos(double kilos) {
  final entero = kilos.round().abs().toString();
  final cifras = StringBuffer();
  for (var i = 0; i < entero.length; i++) {
    if (i > 0 && (entero.length - i) % 3 == 0) cifras.write(espacioFino);
    cifras.write(entero[i]);
  }
  return '${kilos < 0 ? menos : ''}$cifras${espacioDuro}kg';
}

/// Fracción (0 a 1) → «91 %», con espacio antes del signo.
String formatearPorcentaje(double fraccion) =>
    '${(fraccion * 100).round()}$espacioDuro%';

/// Un número con una palabra que concuerda: «1 contenedor», «3 contenedores».
String formatearCuenta(int cuenta, String singular, String plural) =>
    '$cuenta ${cuenta == 1 ? singular : plural}';
