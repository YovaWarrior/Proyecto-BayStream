import 'package:baystream/core/utils/iso_coordinate_parser.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/services/reefer_socket_ranges.dart';
import 'package:baystream/features/vessel/presentation/pages/vessel_geometry_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Geometría sintética del tamaño de A01: filas 01 a 11 y 02 a 12.
const _geometry = VesselGeometry(
  portRows: 6,
  starboardRows: 6,
  holdTiers: [2, 4, 6, 8, 10, 12, 14],
  deckTiers: [82, 84, 86, 88, 90],
  stackWeightLimitKg: 62500,
);

void main() {
  group('T-56 rangos', () {
    test('bahías tal como se escriben, con paso: 002-038/4, 041, 044', () {
      final r = ReeferSocketRanges.parseNumbers('002-038/4, 041, 044',
          field: 'Bahías', min: 1, max: 999);
      expect(r.error, isNull);
      expect(r.values, [2, 6, 10, 14, 18, 22, 26, 30, 34, 38, 41, 44]);
      expect(
          ReeferSocketRanges.parseNumbers('021 023\n025', field: 'B', max: 999)
              .values,
          [21, 23, 25]);
    });
    test('niveles de dos en dos por omisión; filas de uno en uno', () {
      List<int> tiers(String t) => ReeferSocketRanges.parseNumbers(t,
              field: 'Niveles', max: 99, defaultStep: 2)
          .values;
      expect(tiers('82-88'), [82, 84, 86, 88]);
      expect(tiers('02-08'), [2, 4, 6, 8]);
      expect(tiers('82 – 86'), [82, 84, 86]);
      expect(
          ReeferSocketRanges.parseNumbers('01-04', field: 'Filas', max: 99)
              .values,
          [1, 2, 3, 4]);
    });
    test('los errores dicen qué parte no se entiende', () {
      String? error(String text) =>
          ReeferSocketRanges.parseNumbers(text, field: 'Bahías', min: 1, max: 999)
              .error;
      expect(error('abc'), contains('«abc» no es un número ni un rango'));
      expect(error('038-002'), contains('el final es menor que el inicio'));
      expect(error('000'), contains('sale de 001 a 999'));
      expect(error('002-010/0'), contains('el paso tiene que ser 1 o más'));
      expect(
          ReeferSocketRanges.codesFor(
                  bays: '', rows: '', tiers: '82', geometry: _geometry)
              .error,
          'Escribe al menos una bahía.');
      expect(
          ReeferSocketRanges.codesFor(
                  bays: '002', rows: '', tiers: ' ', geometry: _geometry)
              .error,
          'Escribe al menos un nivel.');
      expect(
          ReeferSocketRanges.codesFor(
                  bays: '001-999', rows: '00-99', tiers: '01-99/1',
                  geometry: _geometry)
              .error,
          contains('el máximo es 20000'));
    });
    test('«todas» las filas son las de la geometría; la 00 solo declarada', () {
      final undeclared = ReeferSocketRanges.codesFor(
          bays: '002', rows: '', tiers: '82', geometry: _geometry);
      expect(undeclared.codes, hasLength(12));
      expect(undeclared.codes, isNot(contains('0020082')));
      final declared = ReeferSocketRanges.codesFor(
          bays: '002',
          rows: 'todas',
          tiers: '82, 02',
          geometry: _geometry.copyWith(centerRowOnDeck: true));
      expect(declared.codes, hasLength(25));
      expect(declared.codes, contains('0020082'));
      expect(declared.codes, isNot(contains('0020002')));
    });
    test('vista previa: agregadas, ya existentes y fuera de la geometría', () {
      final range = ReeferSocketRanges.codesFor(
          bays: '002-038/4, 041, 044',
          rows: '01-05',
          tiers: '88-92',
          geometry: _geometry);
      expect(range.codes, hasLength(180));
      final preview =
          ReeferSocketRanges.previewAdd(range.codes, {'0020188'}, _geometry);
      expect(preview.changed, hasLength(119));
      expect(preview.unchanged, ['0020188']);
      expect(preview.outside, hasLength(60));
      expect(preview.outside.every((c) => c.endsWith('92')), isTrue);
      final applied = preview.applyTo({'0020188', '0061290'});
      expect(applied, hasLength(121));
      // Quitar por rango usa los mismos campos.
      final removal = ReeferSocketRanges.previewRemove(
          ReeferSocketRanges.codesFor(
                  bays: '041', rows: '01-05', tiers: '88-90', geometry: _geometry)
              .codes,
          applied);
      expect(removal.changed, hasLength(10));
      expect(removal.applyTo(applied), hasLength(111));
      // Ningún código generado calcula pares: la 041 queda como 041.
      expect(applied.where((c) => c.startsWith('041')), hasLength(10));
      expect(applied.where((c) => c.startsWith('040') || c.startsWith('042')),
          isEmpty);
    });
    test('pegar: comas, espacios y saltos de línea; los inválidos se reportan',
        () {
      final pasted = ReeferSocketRanges.parsePasted(
          '0020182, 0060182\n12345 ABCDEFG\t0000182;0021582 0020182');
      expect(pasted.invalid, ['12345', 'ABCDEFG', '0000182']);
      final preview = ReeferSocketRanges.previewAdd(
          pasted.codes, {'0060182'}, _geometry,
          invalid: pasted.invalid);
      expect(preview.changed, ['0020182']);
      expect(preview.unchanged, ['0060182']);
      expect(preview.outside, ['0021582']);
      expect(preview.invalid, hasLength(3));
      for (final code in preview.changed) {
        expect(_geometry.covers(IsoCoordinateParser.parse(code)), isTrue);
      }
    });
  });

  group('T-56 pantalla de tomas', () {
    final profile = VesselProfile(
        identity: VesselIdentity(
            source: VesselIdentitySource.imo, value: '9000056'),
        vesselName: 'PRUEBA T56',
        geometry: _geometry,
        reeferSlots: {'0020188', '0061290', '0060102'},
        reeferSlotsOrigin: VesselProfileOrigin.proposedFromFile,
        origin: VesselProfileOrigin.proposedFromFile,
        updatedAt: DateTime.utc(2026));

    Future<List<VesselCallParameters?>> open(WidgetTester tester) async {
      tester.view.physicalSize = const Size(1000, 2600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final captured = <VesselCallParameters?>[];
      Future<void> push(BuildContext context) async {
        final page = MaterialPageRoute<VesselCallParameters>(
            builder: (_) => VesselGeometryPage(
                proposal: _geometry,
                initial: _geometry,
                profile: profile,
                profileOnly: true));
        captured.add(await Navigator.of(context).push(page));
      }

      await tester.pumpWidget(MaterialApp(
          home: Builder(
              builder: (context) => Scaffold(
                  body: Center(
                      child: ElevatedButton(
                          onPressed: () => push(context),
                          child: const Text('abrir')))))));
      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('profile-sockets')));
      await tester.pumpAndSettle();
      return captured;
    }

    Future<void> type(WidgetTester tester, String key, String text) async {
      final field = find.byKey(ValueKey(key));
      await tester.ensureVisible(field);
      await tester.enterText(field, text);
    }

    Future<void> press(WidgetTester tester, String key) async {
      final button = find.byKey(ValueKey(key));
      // Con más de cien chips, la lista perezosa no construye lo de abajo.
      if (button.evaluate().isEmpty) {
        await tester.scrollUntilVisible(button, 400,
            scrollable: find.byType(Scrollable).first);
      }
      await tester.ensureVisible(button);
      await tester.pumpAndSettle();
      await tester.tap(button);
      await tester.pumpAndSettle();
    }

    String text(WidgetTester tester, String key) =>
        tester.widget<Text>(find.byKey(ValueKey(key))).data!;

    Future<VesselCallParameters> save(
        WidgetTester tester, List<VesselCallParameters?> captured) async {
      await press(tester, 'geometry-confirm');
      return captured.single!;
    }

    testWidgets(
        'cien tomas por rango: la vista previa coincide con lo guardado y no '
        'declara', (tester) async {
      final captured = await open(tester);
      await type(tester, 'socket-range-bays', '002-038/4, 041, 044');
      await type(tester, 'socket-range-rows', '01-05');
      await type(tester, 'socket-range-tiers', '88-92');
      await press(tester, 'socket-range-add');
      expect(text(tester, 'socket-preview-changed'),
          'Se agregan 119 tomas: 0020190, 0020288, 0020290…');
      expect(text(tester, 'socket-preview-unchanged'),
          'Ya estaba 1: 0020188.');
      expect(text(tester, 'socket-preview-outside'),
          startsWith('Se descartan 60 con la fila o el nivel fuera de la '
              'geometría: 0020192'));
      expect(find.byKey(const ValueKey('socket-preview-invalid')), findsNothing);
      await press(tester, 'socket-batch-apply');
      expect(text(tester, 'socket-batch-summary'),
          'Se agregaron 119 tomas; quedan 122.');
      expect(find.text('Tomas de reefer (122)'), findsOneWidget);
      final saved = await save(tester, captured);
      expect(saved.reeferSlots, hasLength(122));
      expect(saved.reeferSlots.difference(profile.reeferSlots), hasLength(119));
      expect(saved.reeferSlotsOrigin, VesselProfileOrigin.proposedFromFile);
    });

    testWidgets('cancelar no cambia nada; una sola toma va en singular', (tester) async {
      final captured = await open(tester);
      await type(tester, 'socket-range-bays', '010');
      await type(tester, 'socket-range-tiers', '82');
      await press(tester, 'socket-range-add');
      expect(text(tester, 'socket-preview-changed'),
          startsWith('Se agregan 12 tomas'));
      await tester.tap(find.text('Cancelar').last);
      await tester.pumpAndSettle();
      expect(find.text('Tomas de reefer (3)'), findsOneWidget);
      // Una sola: los textos van en singular.
      await type(tester, 'socket-range-rows', '01');
      await press(tester, 'socket-range-add');
      expect(text(tester, 'socket-preview-changed'),
          'Se agrega 1 toma: 0100182.');
      await press(tester, 'socket-batch-apply');
      expect(text(tester, 'socket-batch-summary'),
          'Se agregó 1 toma; quedan 4.');
      expect((await save(tester, captured)).reeferSlots,
          {...profile.reeferSlots, '0100182'});
    });

    testWidgets('quitar por rango', (tester) async {
      final captured = await open(tester);
      await type(tester, 'socket-range-bays', '002, 006');
      await type(tester, 'socket-range-rows', '01, 12');
      await type(tester, 'socket-range-tiers', '88-90, 02');
      await press(tester, 'socket-range-remove');
      expect(text(tester, 'socket-preview-changed'),
          'Se quitan 3 tomas: 0020188, 0060102, 0061290.');
      expect(text(tester, 'socket-preview-unchanged'),
          startsWith('No estaban 9'));
      await press(tester, 'socket-batch-apply');
      expect(text(tester, 'socket-batch-summary'),
          'Se quitaron 3 tomas; quedan 0.');
      expect((await save(tester, captured)).reeferSlots, isEmpty);
    });

    testWidgets('pegar una lista reporta los inválidos y los de fuera',
        (tester) async {
      final captured = await open(tester);
      await type(tester, 'socket-paste',
          '0020182, 0060182\n12345 ABCDEFG 0000182 0021582 0020188');
      await press(tester, 'socket-paste-add');
      expect(text(tester, 'socket-preview-changed'),
          'Se agregan 2 tomas: 0020182, 0060182.');
      expect(text(tester, 'socket-preview-unchanged'), 'Ya estaba 1: 0020188.');
      expect(text(tester, 'socket-preview-outside'),
          'Se descarta 1 con la fila o el nivel fuera de la geometría: '
          '0021582.');
      expect(text(tester, 'socket-preview-invalid'),
          'No se cargan 3 que no son códigos de siete dígitos: 12345, ABCDEFG, '
          '0000182.');
      await press(tester, 'socket-batch-apply');
      final saved = await save(tester, captured);
      expect(saved.reeferSlots, {...profile.reeferSlots, '0020182', '0060182'});
      expect(saved.reeferSlotsOrigin, VesselProfileOrigin.proposedFromFile);
    });

    testWidgets('un rango mal escrito se explica y no abre la vista previa',
        (tester) async {
      await open(tester);
      await type(tester, 'socket-range-bays', '002-0x8');
      await type(tester, 'socket-range-tiers', '82');
      await press(tester, 'socket-range-add');
      expect(text(tester, 'socket-range-error'),
          'Bahías: «002-0x8» no es un número ni un rango como 02-08.');
      expect(find.byType(AlertDialog), findsNothing);
      await press(tester, 'socket-paste-add');
      expect(find.text('Pega al menos un código.'), findsOneWidget);
    });

    testWidgets('la casilla sigue siendo la única que declara', (tester) async {
      final captured = await open(tester);
      await type(tester, 'socket-range-bays', '014');
      await type(tester, 'socket-range-tiers', '02-08');
      await press(tester, 'socket-range-add');
      await press(tester, 'socket-batch-apply');
      await press(tester, 'sockets-declare');
      final saved = await save(tester, captured);
      expect(saved.reeferSlots, hasLength(3 + 12 * 4));
      expect(saved.reeferSlotsOrigin, VesselProfileOrigin.declaredByUser);
    });
  });
}
