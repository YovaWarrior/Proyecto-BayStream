import 'package:baystream/features/vessel/data/datasources/local_vessel_codec.dart';
import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/services/iso6346_check_digit.dart';
import 'package:baystream/features/vessel/presentation/widgets/voyage_summary_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../tool/t98_support.dart';

VesselVoyage read(String source) => BaplieParserService().parse(source);
List<String> details(VesselVoyage voyage, BaplieReadNoticeKind kind) =>
    voyage.readNotices
        .where((notice) => notice.kind == kind)
        .expand((notice) => notice.details)
        .toList();

String fourNotices() =>
    t98Message(position: '012A082', id: 'CSQU3054384', unit: 'LBR')
        .replaceAll(RegExp(r"UNT[^']*'|UNZ[^']*'"), '');

void main() {
  for (final qualifier in ['WT', 'VGM', 'T']) {
    for (final (unit, expected) in [('LBR', 10886.0), ('TNE', 24000000.0)]) {
      test('T108 $qualifier $unit se convierte y redondea al kilo', () {
        final voyage = read(t98Message(unit: unit, qualifier: qualifier));
        final container = voyage.containers.single;
        final weight = switch (qualifier) {
          'VGM' => container.vgmWeight,
          'T' => container.tareWeight,
          _ => container.grossWeight,
        };
        expect(weight, expected);
        expect(details(voyage, BaplieReadNoticeKind.weight).single,
            contains('$qualifier en $unit'));
      });
    }
  }
  for (final numeric in [':24000', '24000']) {
    test('T108 sin unidad ($numeric) conserva kg y avisa', () {
      final voyage = read(t98Message().replaceFirst('KGM:24000', numeric));
      expect(voyage.containers.single.grossWeight, 24000);
      expect(details(voyage, BaplieReadNoticeKind.weight).single,
          contains('sin unidad'));
    });
  }
  test('T108 unidad desconocida no inventa peso ni afecta el VGM', () {
    final voyage = read(t98Message(unit: 'XYZ').replaceFirst(
        'MEA+WT++XYZ:24000', 'MEA+VGM++KGM:25000\'MEA+WT++XYZ:24000'));
    expect(voyage.containers.single.grossWeight, isNull);
    expect(voyage.containers.single.vgmWeight, 25000);
    expect(details(voyage, BaplieReadNoticeKind.weight).single,
        contains('unidad desconocida XYZ'));
  });
  test('T108 MEA después de EQD y unidad desconocida reemplaza ese peso', () {
    final voyage =
        read(t98Message().replaceFirst('UNT+13+', 'MEA+WT++XYZ:4\'UNT+14+'));
    expect(voyage.containers.single.grossWeight, isNull);
    expect(details(voyage, BaplieReadNoticeKind.weight), hasLength(1));
  });
  for (final position in ['01234', '01200000', '012A082', '-120082']) {
    test('T108 posición $position queda fuera de rejilla y conserva el texto',
        () {
      final voyage = read(t98Message(position: position));
      expect(voyage.totalContainers, 1);
      expect(voyage.containers.single.stowagePosition, isNull);
      expect(voyage.bays, isEmpty);
      expect(details(voyage, BaplieReadNoticeKind.position),
          ['CSQU3054383: $position']);
    });
  }
  for (final prefix in ['CSQU305438', 'TSTU000098', 'ABCU123456']) {
    test('T108 $prefix válido y alterado, sin rechazar el contenedor', () {
      final digit = t98CheckDigit(prefix);
      final valid = '$prefix$digit';
      final invalid = '$prefix${(digit + 1) % 10}';
      expect(Iso6346CheckDigit.isValid(valid), isTrue);
      expect(Iso6346CheckDigit.isValid(invalid), isFalse);
      expect(read(t98Message(id: valid)).readNotices, isEmpty);
      final voyage = read(t98Message(id: invalid));
      expect(voyage.containers.single.containerId, invalid);
      expect(details(voyage, BaplieReadNoticeKind.checkDigit), [invalid]);
    });
  }
  test('T108 otro formato de número no se evalúa', () {
    expect(Iso6346CheckDigit.isValid('SINTETICO-1'), isNull);
    expect(read(t98Message(id: 'SINTETICO-1')).readNotices, isEmpty);
  });
  for (final tags in [
    ['UNT', 'UNZ'],
    ['UNB', 'BGM']
  ]) {
    test('T108 sin ${tags.join('/')} abre y precisa los segmentos', () {
      final source = t98Segments(t98Message())
          .where((segment) => !tags.contains(segment.split('+').first))
          .map((segment) => "$segment'")
          .join();
      final voyage = read(source);
      expect(voyage.totalContainers, 1);
      expect(details(voyage, BaplieReadNoticeKind.incomplete), tags);
    });
  }
  test('T108 limpio no agrega avisos ni campos al JSON histórico', () {
    final voyage = read(t98Message().replaceFirst('KGM:24000', 'KGM:24000.25'));
    expect(voyage.containers.single.grossWeight, 24000.25);
    expect(voyage.readNotices, isEmpty);
    expect(voyage.toJson().containsKey('readNotices'), isFalse);
  });
  test('T108 cuatro tipos sobreviven codec local y copyWith sin cambiar codec',
      () {
    final voyage = read(fourNotices());
    const codec = LocalVesselCodec();
    final record = codec.encodeVoyage(voyage);
    expect(RegExp('CSQU3054384').allMatches(record), hasLength(1));
    final restored = codec.decodeVoyage(record);
    // T-144: los cuatro tipos de T-108 (los de T-144 tienen su prueba).
    expect(restored.readNotices.map((notice) => notice.kind),
        BaplieReadNoticeKind.values.where((k) => k.readByV100));
    expect(restored.readNotices, voyage.readNotices);
    expect(restored.copyWith(voyageNumber: 'OTRO').readNotices,
        voyage.readNotices);
    expect(
        codec.decodeVoyage(codec.encodeVoyage(read(t98Message()))).readNotices,
        isEmpty);
  });
  test('T108 los avisos no se filtran entre grupos ni entre lecturas', () {
    final first = t98Message(unit: 'LBR');
    final second = t98Message(id: 'ABCU1234560');
    final group = t98Segments(second)
        .skipWhile((s) => !s.startsWith('LOC+147'))
        .takeWhile((s) => !s.startsWith('UNT'))
        .map((s) => "$s'")
        .join();
    final voyage = read(first.replaceFirst('UNT+13+', '${group}UNT+20+'));
    expect(voyage.totalContainers, 2);
    expect(details(voyage, BaplieReadNoticeKind.weight), hasLength(1));
    final parser = BaplieParserService();
    parser.parse(fourNotices());
    expect(parser.parse(t98Message()).readNotices, isEmpty);
  });
  testWidgets(
      'T108 cuatro resúmenes visibles y detalle a un toque tras reabrir',
      (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    const codec = LocalVesselCodec();
    final voyage = codec.decodeVoyage(codec.encodeVoyage(read(fourNotices())));
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: SingleChildScrollView(
                child: VoyageSummaryCard(voyage: voyage)))));
    // T-144: los cuatro tipos de T-108; los de T-144 tienen su prueba.
    for (final kind in BaplieReadNoticeKind.values.where((k) => k.readByV100)) {
      final notice = find.byKey(ValueKey('voyage-${kind.name}-notice'));
      expect(notice, findsOneWidget);
      await tester.tap(notice);
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
      for (final detail in details(voyage, kind)) {
        expect(find.text(detail), findsOneWidget);
      }
      await tester.tap(find.text('Cerrar'));
      await tester.pumpAndSettle();
    }
    expect(tester.takeException(), isNull);
  });
}
