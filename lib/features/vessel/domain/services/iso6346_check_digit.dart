/// Dígito ISO 6346: valores alfabéticos sin múltiplos de 11, potencias de 2
/// y residuo módulo 11 (10 se representa con 0). No valida al propietario.
class Iso6346CheckDigit {
  static final _format = RegExp(r'^[A-Z]{4}[0-9]{7}$');

  /// null significa que el número no tiene el formato que se evalúa.
  static bool? isValid(String number) {
    if (!_format.hasMatch(number)) return null;
    var sum = 0;
    for (var i = 0; i < 10; i++) {
      final code = number.codeUnitAt(i);
      final value = code <= 57 ? code - 48 : code - 55 + (code - 56) ~/ 10;
      sum += value * (1 << i);
    }
    return (sum % 11) % 10 == int.parse(number[10]);
  }
}
