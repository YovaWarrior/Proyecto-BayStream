import 'package:baystream/features/vessel/domain/services/iso6346_check_digit.dart';
import 'package:flutter_test/flutter_test.dart';

/// T-116: los dígitos son constantes calculadas aparte con la tabla alfabética
/// ISO y las ponderaciones 1, 2, 4, ..., 512. La prueba no usa el validador
/// para construir su propio resultado esperado. Cálculos: PRUEBAS-CURSO.md.
void main() {
  group('Caja blanca del dígito ISO 6346', () {
    const formatosInvalidos = {
      'minúsculas': 'csqu3054383',
      'diez caracteres': 'CSQU305438',
      'doce caracteres': 'CSQU30543833',
      'dígito en el prefijo': 'CS1U3054383',
      'letra en la serie': 'CSQU30A4383',
      'cadena vacía': '',
    };

    for (final caso in formatosInvalidos.entries) {
      test('devuelve null con ${caso.key}', () {
        // Arrange
        final numero = caso.value;

        // Act
        final resultado = Iso6346CheckDigit.isValid(numero);

        // Assert
        expect(resultado, isNull);
      });
    }

    const letrasYDigitos = {
      'A vale 10': 'AAAU1234566',
      'B vale 12, salta 11': 'BAAU1234568',
      'K vale 21': 'KAAU1234566',
      'L vale 23, salta 22': 'LAAU1234568',
      'U vale 32': 'UAAU1234566',
      'V vale 34, salta 33': 'VAAU1234568',
    };

    for (final caso in letrasYDigitos.entries) {
      test('acepta letras y dígitos cuando ${caso.key}', () {
        // Arrange
        final numero = caso.value;

        // Act
        final resultado = Iso6346CheckDigit.isValid(numero);

        // Assert
        expect(resultado, isTrue);
      });
    }

    test('acepta el dígito correcto del ejemplo CSQU3054383', () {
      // Arrange
      const numero = 'CSQU3054383'; // 6185 / 11 deja residuo 3.

      // Act
      final resultado = Iso6346CheckDigit.isValid(numero);

      // Assert
      expect(resultado, isTrue);
    });

    test('rechaza el mismo ejemplo con un dígito incorrecto', () {
      // Arrange
      const numero = 'CSQU3054384';

      // Act
      final resultado = Iso6346CheckDigit.isValid(numero);

      // Assert
      expect(resultado, isFalse);
    });

    test('representa el residuo diez con el dígito cero', () {
      // Arrange
      const numero = 'AAAU0000060'; // 3398 / 11 deja residuo 10.

      // Act
      final resultado = Iso6346CheckDigit.isValid(numero);

      // Assert
      expect(resultado, isTrue);
    });

    test('rechaza uno donde el residuo diez exige cero', () {
      // Arrange
      const numero = 'AAAU0000061';

      // Act
      final resultado = Iso6346CheckDigit.isValid(numero);

      // Assert
      expect(resultado, isFalse);
    });
  });
}
