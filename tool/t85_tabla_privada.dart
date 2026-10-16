import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:baystream/features/vessel/domain/services/imdg_42_24_data.dart';

/// Coteja los dos CSV privados. Solo imprime coordenadas y codigos.
/// Las huellas forman una tabla cerrada de traduccion: un texto desconocido falla.
/// Asi el comprobador no publica pasajes del IMDG. No forma parte de la suite.
void main(List<String> args) {
  if (args.length != 2) {
    throw ArgumentError('Indicar las rutas de ambos CSV privados.');
  }
  final matrix = _csv(File(args[0]).readAsStringSync());
  final spatial = _csv(File(args[1]).readAsStringSync());
  var matches = 0;
  if (matrix.length != 18 || matrix.any((r) => r.length != 18)) {
    throw StateError('Forma de matriz distinta de 17 x 17.');
  }
  for (var c = 0; c < 17; c++) {
    if (matrix[0][c + 1] != Imdg4224Data.classes[c]) {
      throw StateError('Cabecera de clase ${c + 1}.');
    }
  }
  for (var r = 0; r < 17; r++) {
    final label = matrix[r + 1][0].replaceAll(' ', '').replaceAll(',', '/');
    if (label != Imdg4224Data.classes[r]) {
      throw StateError('Fila de clase ${r + 1}.');
    }
    for (var c = 0; c < 17; c++) {
      if (matrix[r + 1][c + 1] != Imdg4224Data.matrix[r][c]) {
        throw StateError('Diferencia 7.2.4 fila ${r + 1}, columna ${c + 1}.');
      }
      matches++;
    }
  }
  const headings = [
    'segregacion',
    'nombre',
    'direccion',
    'sentido',
    'compartimentos',
    'ubicacion',
    'prescripcion'
  ];
  if (spatial.first.join('|') != headings.join('|')) {
    throw StateError('Cabecera espacial desconocida.');
  }
  final seen = <String>{};
  var spaceMatches = 0;
  for (final row in spatial.skip(1)) {
    if (row.length != 7) throw StateError('Fila espacial incompleta.');
    if (row[0] == 'nota') continue;
    final requirement = int.parse(row[0]);
    if (requirement < 1 || requirement > 4) {
      throw StateError('Exigencia desconocida.');
    }
    final pair = ['cerrado/cerrado', 'cerrado/abierto', 'abierto/abierto']
        .indexOf(row[4]);
    if (pair < 0) throw StateError('Par de unidades desconocido.');
    final normalized = row[6].trim().replaceAll(RegExp(r'\s+'), ' ');
    final translated =
        _translation[sha256.convert(utf8.encode(normalized)).toString()];
    if (translated == null) {
      throw StateError(
          'Texto desconocido en exigencia $requirement, ${row[2]}/$pair.');
    }
    String actual;
    String key;
    if (row[2] == 'vertical') {
      if (row[3].isNotEmpty || row[5].isNotEmpty) {
        throw StateError('Coordenadas verticales inesperadas.');
      }
      actual = Imdg4224Data.vertical[requirement - 1][pair].name;
      key = '$requirement/v/$pair';
    } else {
      if (row[2] != 'horizontal') throw StateError('Direccion desconocida.');
      final axis = ['longitudinal', 'transversal'].indexOf(row[3]);
      final zone = ['en cubierta', 'bajo cubierta'].indexOf(row[5]);
      if (axis < 0 || zone < 0) {
        throw StateError('Sentido o zona desconocidos.');
      }
      actual = Imdg4224Data.horizontalRule(
              requirement, ImdgAxis.values[axis], ImdgUnitPair.values[pair],
              onDeck: zone == 0)
          .name;
      key = '$requirement/h/$axis/$pair/$zone';
    }
    if (!seen.add(key)) throw StateError('Coordenada repetida: $key.');
    if (actual != translated) {
      throw StateError('Diferencia 7.4.3.2 $key: $actual / $translated.');
    }
    spaceMatches++;
  }
  if (matches != 289 || spaceMatches != 60) {
    throw StateError('Cotejo incompleto: $matches y $spaceMatches.');
  }
  stdout.writeln(
      'IMDG 42-24: 7.2.4 $matches/289; 7.4.3.2 $spaceMatches/60. COINCIDEN.');
}

// Huella del texto normalizado -> codigo funcional de BayStream.
const _translation = <String, String>{
  'ad47053cdc712068474beb84950f80e4efb7b8abb33e74e29b024bc45d9a222c': 'stacked',
  'a10046658293cc3d72aa848074a5a6e1871d98fc040db988a1221340a3db5391':
      'openAboveClosed',
  'ccc2e12071fdc316ac6285e7234a96737a1fd041416443badb54f09affb8ae5c': 'deck',
  'eba5e2a81a0484a76ec3e4ed6794d58acc650b7eb4783386461c0212d133ea98': 'none',
  'af37919fbfaede8fe5ceeca2097dff18d87a517a0e7013a435c5d1165af4f4e3': 'space1',
  '9205e67ca538ecd9f2d24f6c35bbd1e13bbc5183f723cb0a535bc78dd6ff02d6':
      'space1OrBulkhead',
  '2edf368b1d808b62f1fa063fd022f96dbc67afbd0abcca72ad292d8e8f99c0e1': 'deck',
  '46d5b795086caf1fbbee934cd8e652f535da52802ea30eb077d4773545153f89':
      'bulkhead1',
  'b234f299871fcc1a3b4940ea5128d01d885f04c9b48901310a5890802b308df3': 'space2',
  '768b1dbb39c085b7e42f0aa14eaaa524f9b1076d21bede33d202b9aef2e318a6':
      'bulkhead2',
  '1fdb30af6d95d9a8f9a134990ab1a73ef0c7ea27145ffb94615b02db147bf666': 'space3',
  '2a59ea2b49e67a412acaa7078bf96e64ff6704bdea097447b970bcc9baa97b6d':
      'forbidden',
  '2c07059ec92c1072bdd47739569de90ddcebcc644e4357e15a83e612d51c4c7a':
      'meters24',
  '4f35edebc5036784c3a6febfb726e169feb422e99c1067c1f6b043bc2fa3d4bd':
      'bulkheadAnd24',
};

List<List<String>> _csv(String source) {
  final rows = <List<String>>[];
  var row = <String>[];
  var field = StringBuffer();
  var quoted = false;
  final text = source.replaceFirst(RegExp('^\uFEFF'), '');
  for (var i = 0; i < text.length; i++) {
    final ch = text[i];
    if (ch == '"') {
      if (quoted && i + 1 < text.length && text[i + 1] == '"') {
        field.write('"');
        i++;
      } else {
        quoted = !quoted;
      }
    } else if (ch == ',' && !quoted) {
      row.add(field.toString());
      field = StringBuffer();
    } else if ((ch == '\n' || ch == '\r') && !quoted) {
      if (ch == '\r' && i + 1 < text.length && text[i + 1] == '\n') i++;
      row.add(field.toString());
      field = StringBuffer();
      if (row.any((x) => x.isNotEmpty)) rows.add(row);
      row = <String>[];
    } else {
      field.write(ch);
    }
  }
  if (quoted) throw const FormatException('Comillas CSV incompletas.');
  if (field.isNotEmpty || row.isNotEmpty) {
    row.add(field.toString());
    rows.add(row);
  }
  return rows;
}
