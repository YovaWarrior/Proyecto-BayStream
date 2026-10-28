import 'package:baystream/features/vessel/domain/services/iso6346_check_digit.dart';
import 'package:flutter_test/flutter_test.dart';

/// T-126 · Rojo → verde en la Expo, sin editar ningún archivo en vivo.
///
///   flutter test test/curso/expo_rojo_verde_test.dart
///   flutter test test/curso/expo_rojo_verde_test.dart --dart-define=EXPO_ROJO=true
///
/// Sin el interruptor, la prueba espera el dígito que da la norma y pasa. Con
/// EXPO_ROJO=true espera a propósito uno equivocado y falla diciendo cuál
/// esperaba y cuál calcula el validador. El dígito de CSQU305438 se calculó
/// aparte, como en la caja blanca: 6185 entre 11 deja residuo 3.
const _rojo = bool.fromEnvironment('EXPO_ROJO');

void main() {
  const serie = 'CSQU305438';
  const esperado = _rojo ? 4 : 3;

  test('ISO 6346: el dígito de control de $serie es $esperado', () {
    // Arrange
    final digitos = List<int>.generate(10, (d) => d);

    // Act: los dígitos que el validador acepta para esa serie.
    final aceptados = [
      for (final d in digitos)
        if (Iso6346CheckDigit.isValid('$serie$d') == true) d,
    ];

    // Assert
    expect(aceptados, hasLength(1),
        reason: 'Un número ISO 6346 tiene un solo dígito de control correcto.');
    expect(aceptados.single, esperado,
        reason: _rojo
            ? 'ROJO A PROPÓSITO (EXPO_ROJO=true): la prueba esperaba el '
                'dígito $esperado y el validador calcula ${aceptados.single} '
                'para $serie. Sin el interruptor, vuelve a verde.'
            : 'El validador debe calcular $esperado para $serie.');
  });
}
