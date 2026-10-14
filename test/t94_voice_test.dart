import 'package:baystream/features/vessel/domain/services/container_voice_query.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('T-94 palabras de cero a nueve y ceros iniciales', () {
    expect(
        normalizeContainerVoiceQuery(
            'cero uno dos tres cuatro cinco seis siete ocho nueve'),
        '0123456789');
    expect(normalizeContainerVoiceQuery('un una cero'), '110');
  });
  test('T-94 secuencias dictadas y grupos numéricos sin perder ceros', () {
    expect(normalizeContainerVoiceQuery('cero cero 123 cuatro 05 seis siete'),
        '0012340567');
    expect(normalizeContainerVoiceQuery('000 123 4'), '0001234');
  });
  test('T-94 nombres españoles de todas las letras ISO', () {
    expect(
        normalizeContainerVoiceQuery(
            'a be ce de e efe ge hache i jota ka ele eme ene o pe cu erre ese te u uve doble uve equis ye zeta'),
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ');
  });
  test('T-94 variantes del reconocedor y acentos en nombres', () {
    expect(
        normalizeContainerVoiceQuery(
            'té ése te ú cero cero cero uno dos tres cuatro'),
        'TSTU0001234');
    expect(
        normalizeContainerVoiceQuery(
            'be larga ve corta doble ve doble u i griega'),
        'BVWWY');
  });
  test('T-94 prefijo contiguo, espacios y puntuación', () {
    expect(normalizeContainerVoiceQuery('TSTU 000.123-4!'), 'TSTU0001234');
    expect(
        normalizeContainerVoiceQuery('t s t u, 0 0 0 1 2 3 4'), 'TSTU0001234');
  });
  test('T-94 ruido desconocido permanece editable sin inventar una orden', () {
    expect(normalizeContainerVoiceQuery('cargar ruido extraño dos'),
        'cargarruidoextraño2');
    expect(normalizeContainerVoiceQuery('treinta y dos'), 'treintaY2');
    expect(normalizeContainerVoiceQuery('¿?... '), '');
  });
}
