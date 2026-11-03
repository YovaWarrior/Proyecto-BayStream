import 'dart:convert';
import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/data/services/export_list_parser_service.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/services/departure_baplie_review.dart';
import 'package:flutter_test/flutter_test.dart';
import 'support/t132_fixture.dart';
import 'support/t82_fixture.dart' show t82Move;

void main() {
  test('T-132 UNOB admite minúsculas y sus signos adicionales', () {
    final f = T132Fixture(
        cargo: t132Group(1),
        rows: [t132Row(1, line: 'Test&co')],
        charset: 'UNOB');
    expect(f.output().text, contains('NAD+CA+Test&co:172:20'));
  });
  test('T-132 UNOB rechaza signos ASCII ajenos a su repertorio', () {
    final f = T132Fixture(
        cargo: t132Group(1), rows: [t132Row(1, line: 'L@')], charset: 'UNOB');
    expect(f.output(preview: true).errors.single,
        contains('«@» (U+0040) no cabe en UNOB'));
    expect(f.output, throwsStateError);
  });

  test('T-132 elegir solo una clase del listado conserva todos los ONU y DGS',
      () {
    final f = T132Fixture(
        cargo: "${t132Group(1)}$t132Dgs'DGS+IMD+6.1+2903+24:CEL+III'",
        rows: [t132Row(1, hazard: '3')]);
    final review = f.output(preview: true);
    final result =
        f.output(choices: {review.decisions.single.id: DepartureChoice.list});
    expect(result.text, contains(t132Dgs.replaceFirst('6.1:35', '3:35')));
    expect(result.text, contains('DGS+IMD+3+2903+24:CEL+III'));
  });

  for (final choice in DepartureChoice.values) {
    test(
      'T-132 peligrosas: elegir ${choice.name} conserva el DGS completo',
      () {
        final f = T132Fixture(
          cargo: "${t132Group(1, extra: t132Auxiliary)}$t132Dgs'",
          rows: [
            t132Row(1, hazard: '6.1', uns: ['2903']),
          ],
        );
        final review = f.output(preview: true);
        expect(review.canSave, isFalse);
        expect(
          review.text,
          isEmpty,
          reason: 'no existe un archivo con elección implícita',
        );
        expect(
          review.decisions.single.message,
          'El plan dice UN 2902; el listado, UN 2903',
        );
        expect(f.output, throwsStateError);
        final result = f.output(choices: {review.decisions.single.id: choice});
        expect(
          result.text,
          contains(
            choice == DepartureChoice.plan
                ? t132Dgs
                : t132Dgs.replaceFirst('2902', '2903'),
          ),
        );
        for (final segment in [
          "FTX+AAA+++CARGA ESPECIAL?' CON TILDE á",
          'LOC+83+SERVICIO:139:6',
          'RNG+5+CEL:-20:-16',
        ]) {
          expect(result.text, contains(segment));
        }
        expect(result.text, contains('MEA+VGM++KGM:18837'));
        expect(result.text, contains('MEA+T++KGM:3901'));
        expect(result.text, contains('NAD+CA+TEST:172:20'));
        expect(result.text, contains('EQD+CN+TSTU0001321+22G1:102:5++2+5'));
      },
    );
  }
  test('T-132 una clase distinta bloquea aunque coincida el ONU', () {
    final f = T132Fixture(
      cargo: "${t132Group(1)}$t132Dgs'",
      rows: [
        t132Row(1, hazard: '3', uns: ['2902']),
      ],
    );
    final review = f.output(preview: true);
    expect(review.canSave, isFalse);
    expect(
      review.decisions.single.message,
      'El plan dice clase 6.1; el listado, clase 3',
    );
    expect(
      f.output(
          choices: {review.decisions.single.id: DepartureChoice.list}).text,
      contains(t132Dgs.replaceFirst('6.1:35', '3:35')),
    );
  });
  test('T-132 varias peligrosas coincidentes conservan todos sus DGS', () {
    final f = T132Fixture(
      cargo: "${t132Group(1)}$t132Dgs'DGS+IMD+6.1+2903+24:CEL+III'",
      rows: [
        t132Row(1, hazard: '6.1', uns: ['2902', '2903']),
      ],
    );
    final result = f.output();
    expect(result.decisions, isEmpty);
    expect(result.text, contains(t132Dgs));
    expect(result.text, contains('DGS+IMD+6.1+2903+24:CEL+III'));
  });
  test('T-132 solo el listado declara peligrosa: aviso y lo disponible', () {
    final f = T132Fixture(
      cargo: t132Group(1),
      rows: [
        t132Row(1, hazard: '9', uns: ['3082']),
      ],
    );
    final result = f.output();
    expect(
      result.warnings.single,
      contains('solo el listado declara mercancías peligrosas'),
    );
    expect(result.text, contains('DGS+IMD+9+3082'));
  });
  test('T-132 el silencio del listado no elimina una peligrosa del plan', () {
    final f = T132Fixture(
      cargo: "${t132Group(1)}$t132Dgs'",
      rows: [t132Row(1)],
    );
    expect(f.output().text, contains(t132Dgs));
    expect(f.output().warnings.single, contains('Se conserva el DGS completo'));
  });
  test('T-132 lleno refrigerado: TMP del plan y sus segmentos auxiliares', () {
    final f = T132Fixture(
      cargo: t132Group(1, extra: "TMP+2+-18:CEL'$t132Auxiliary", type: '22R1'),
      rows: [t132Row(1)],
    );
    final result = f.output();
    expect(result.text, contains('TMP+2+-18:CEL'));
    expect(result.text, contains('LOC+83+SERVICIO:139:6'));
    expect(result.text, contains('RNG+5+CEL:-20:-16'));
  });
  test('T-132 lleno refrigerado: temperatura solo del listado', () {
    final f = T132Fixture(
      cargo: t132Group(1, type: '22R1'),
      rows: [t132Row(1, temperature: '-18,5 °C')],
    );
    expect(f.output().text, contains('TMP+2+-18.5:CEL'));
    final parsed =
        BaplieParserService().parse(f.output().text).containers.single;
    expect(parsed.temperature, -18.5);
  });
  for (final choice in DepartureChoice.values) {
    test('T-132 temperaturas distintas: elegir ${choice.name}', () {
      final f = T132Fixture(
        cargo: t132Group(1, extra: "TMP+2+-18:CEL'$t132Auxiliary"),
        rows: [t132Row(1, temperature: '-20')],
      );
      final review = f.output(preview: true);
      expect(review.canSave, isFalse);
      expect(
        review.decisions.single.message,
        'El plan dice -18 °C; el listado, -20 °C',
      );
      expect(f.output, throwsStateError);
      final output = f.output(choices: {review.decisions.single.id: choice});
      expect(
        output.text,
        contains('TMP+2+${choice == DepartureChoice.plan ? -18 : -20}:CEL'),
      );
      expect(output.text, contains('RNG+5+CEL:-20:-16'));
    });
  }
  test('T-132 temperaturas equivalentes en F y C no discrepan', () {
    final f = T132Fixture(
      cargo: t132Group(1, extra: "TMP+2+32:FAH'"),
      rows: [t132Row(1, temperature: '0 C')],
    );
    expect(f.output().decisions, isEmpty);
    expect(f.output().text, contains('TMP+2+32:FAH'));
  });
  test('T-132 una temperatura ilegible indica fila y bloquea', () {
    final f = T132Fixture(
      cargo: t132Group(1),
      rows: [t132Row(1, temperature: 'NO SABEMOS')],
    );
    final review = f.output(preview: true);
    expect(review.errors.single, contains('fila 6 · REEFER TEMP'));
    expect(review.canSave, isFalse);
    expect(f.output, throwsStateError);
  });
  test('T-132 el peso va al kilo, mitad hacia arriba, sin restos binarios', () {
    for (final entry in {
      18837.129999999997: 18837,
      1000.5: 1001,
      1000.49: 1000,
    }.entries) {
      final f = T132Fixture(
        cargo: t132Group(1),
        rows: [t132Row(1, weight: entry.key)],
      );
      final result = f.output();
      expect(result.text, contains("MEA+VGM++KGM:${entry.value}'"));
      expect(result.text, contains("MEA+T++KGM:3901'"));
    }
  });
  test('T-132 peso negativo o no finito se rechaza', () {
    for (final weight in [-1.0, double.nan, double.infinity]) {
      final f = T132Fixture(
        cargo: t132Group(1),
        rows: [t132Row(1, weight: weight)],
      );
      expect(f.output, throwsStateError);
    }
  });
  test('T-132 POT igual al POD quita LOC+13; distinto lo escribe', () {
    for (final pot in ['PAMIT', 'JMKWL']) {
      final f = T132Fixture(
        cargo: t132Group(1, extra: "LOC+13+OLD:139:6'"),
        rows: [t132Row(1, pot: pot)],
      );
      final text = f.output().text;
      expect(text.contains('LOC+13+'), pot != 'PAMIT');
      if (pot != 'PAMIT') expect(text, contains('LOC+13+JMKWL:139:6'));
      expect(text, isNot(contains('LOC+13+OLD')));
    }
  });
  test(
    'T-132 lo que sigue a bordo: tildes, escapes y CRLF idénticos byte a byte',
    () {
      final group = t132Group(
        1,
        pol: 'HNPCR',
        extra: t132Auxiliary,
      ).replaceAll("'", "'\r\n");
      final bytes = latin1.encode(group);
      final original = String.fromCharCodes(bytes);
      final f = T132Fixture(cargo: original, rows: [], loaded: []);
      final text = f.output().text;
      final start = text.indexOf('LOC+147+');
      final end = text.indexOf('UNT+', start);
      expect(DepartureCharacterSet.bytes(text.substring(start, end)), bytes);
      expect(text, isNot(contains('Ã¡')));
    },
  );
  test('T-132 UNOC permite tilde del listado, UNOA la ubica y bloquea', () {
    for (final charset in ['UNOC', 'UNOA']) {
      final f = T132Fixture(
        cargo: t132Group(1),
        rows: [t132Row(1, line: 'LÍNEA')],
        charset: charset,
      );
      final output = f.output(preview: true);
      expect(output.canSave, charset == 'UNOC');
      if (charset == 'UNOA') {
        expect(
          output.errors.single,
          contains('fila 6 · OPR: el carácter «Í» (U+00CD) no cabe en UNOA'),
        );
        expect(f.output, throwsStateError);
      } else {
        expect(DepartureCharacterSet.bytes(output.text), contains(0xcd));
      }
    }
  });
  test('T-132 UNOC rechaza emoji sin sustituirlo ni truncarlo', () {
    final f = T132Fixture(
      cargo: t132Group(1),
      rows: [t132Row(1, line: 'L🚢')],
    );
    expect(f.output(preview: true).errors.single, contains('U+1F6A2'));
    expect(f.output, throwsStateError);
  });
  test('T-132 cambios de datos invalidan la elección anterior', () {
    final first = T132Fixture(
      cargo: "${t132Group(1)}$t132Dgs'",
      rows: [
        t132Row(1, hazard: '6.1', uns: ['2903']),
      ],
    );
    final second = T132Fixture(
      cargo: "${t132Group(1)}$t132Dgs'",
      rows: [
        t132Row(1, hazard: '6.1', uns: ['1993']),
      ],
    );
    final id = first.output(preview: true).decisions.single.id;
    final output = second.output(
      preview: true,
      choices: {id: DepartureChoice.list},
    );
    expect(output.canSave, isFalse);
    expect(
      () => second.output(choices: {id: DepartureChoice.list}),
      throwsStateError,
    );
  });
  test(
    'T-132 filas no cargadas: cancelada, sin celda, pendiente y cancelada en operación',
    () {
      final cancel = t82Move(
        MovementDraft.cancelItem('t132', 'C:TSTU0001324', 'Agencia'),
        10,
      );
      final f = T132Fixture(
        cargo: '${t132Group(1)}${t132Group(3)}${t132Group(4)}',
        rows: [
          t132Row(1),
          t132Row(2, contents: 'REEMPLAZO - CANCEL'),
          t132Row(5),
          t132Row(3),
          t132Row(4),
        ],
        extraMovements: [cancel],
      );
      expect(f.output().notLoaded, [
        'OR 2 · TSTU0001322 · cancelado en el listado',
        'OR 3 · TSTU0001323 · carga no registrada',
        'OR 4 · TSTU0001324 · cancelado en la operación',
        'OR 5 · TSTU0001325 · sin celda en el plan',
      ]);
      expect(f.output().cancelledText, contains('Agencia'));
      expect(f.output().text, isNot(contains('EQD+CN+TSTU0001322')));
    },
  );
  test(
    'T-132 el lector real del listado conserva temperatura y cancelación',
    () {
      final list = const ExportListParserService().parseGrid([
        [
          'OR',
          'CONTENEDOR',
          'TIPO',
          'POD',
          'TARA',
          'PESO VGM',
          'F',
          'E',
          'CONTENIDO',
          'OPR',
          'REEFER TEMP',
        ],
        [
          1,
          'TSTU0001321',
          '22R1',
          'PAMIT',
          3900,
          18000,
          'X',
          '',
          'REEMPLAZO - CANCEL',
          'TEST',
          '-18',
        ],
      ]);
      expect(list.rows.single.reeferTemperature, '-18');
      expect(list.rows.single.contents, 'REEMPLAZO - CANCEL');
    },
  );
}
