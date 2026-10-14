/// Dictado a borrador de búsqueda. No interpreta órdenes de operación ni
/// descarta palabras desconocidas: quedan visibles para corregir a mano.
String normalizeContainerVoiceQuery(String transcript) {
  const words = {
    'cero': '0',
    'uno': '1',
    'un': '1',
    'una': '1',
    'dos': '2',
    'tres': '3',
    'cuatro': '4',
    'cinco': '5',
    'seis': '6',
    'siete': '7',
    'ocho': '8',
    'nueve': '9',
    'a': 'A',
    'be': 'B',
    'b': 'B',
    'ce': 'C',
    'c': 'C',
    'de': 'D',
    'd': 'D',
    'e': 'E',
    'efe': 'F',
    'f': 'F',
    'ge': 'G',
    'g': 'G',
    'hache': 'H',
    'h': 'H',
    'i': 'I',
    'jota': 'J',
    'j': 'J',
    'ka': 'K',
    'k': 'K',
    'ele': 'L',
    'l': 'L',
    'eme': 'M',
    'm': 'M',
    'ene': 'N',
    'n': 'N',
    'o': 'O',
    'pe': 'P',
    'p': 'P',
    'cu': 'Q',
    'q': 'Q',
    'erre': 'R',
    'r': 'R',
    'ese': 'S',
    's': 'S',
    'te': 'T',
    't': 'T',
    'u': 'U',
    'uve': 'V',
    've': 'V',
    'v': 'V',
    'dobleuve': 'W',
    'dobleve': 'W',
    'w': 'W',
    'equis': 'X',
    'x': 'X',
    'ye': 'Y',
    'y': 'Y',
    'zeta': 'Z',
    'z': 'Z',
  };
  String key(String value) => value
      .toLowerCase()
      .replaceAll('á', 'a')
      .replaceAll('é', 'e')
      .replaceAll('í', 'i')
      .replaceAll('ó', 'o')
      .replaceAll('ú', 'u')
      .replaceAll('ü', 'u');
  final tokens = RegExp(r'[A-Za-zÁÉÍÓÚÜÑáéíóúüñ0-9]+')
      .allMatches(transcript)
      .map((m) => m[0]!)
      .toList();
  final result = StringBuffer();
  for (var i = 0; i < tokens.length; i++) {
    final token = key(tokens[i]);
    final next = i + 1 < tokens.length ? key(tokens[i + 1]) : '';
    if ((token == 'doble' && (next == 'uve' || next == 've' || next == 'u')) ||
        (token == 'i' && next == 'griega') ||
        (token == 've' && next == 'corta') ||
        (token == 'be' && (next == 'larga' || next == 'alta'))) {
      result.write(token == 'doble'
          ? 'W'
          : token == 'i'
              ? 'Y'
              : token == 've'
                  ? 'V'
                  : 'B');
      i++;
    } else {
      result.write(words[token] ?? tokens[i]);
    }
  }
  return result.toString();
}
