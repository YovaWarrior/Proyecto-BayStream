import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late BaplieParserService parser;

  setUp(() {
    parser = BaplieParserService();
  });

  test('conserva TMP cuando llega antes de EQD', () {
    const baplieContent = '''
UNH+1+BAPLIE:D:95B:UN'
TDT+20+V001++++++:::TEST VESSEL'
LOC+147+0210804::5'
MEA+WT++KGM:22462'
TMP+2+-020:CEL'
LOC+9+PAMIT:139:6'
LOC+11+USHOU:139:6'
EQD+CN+REEF001+45G1++4+5'
UNT+9+1'
''';

    final container = parser.parse(baplieContent).containers.single;

    expect(container.isReefer, isTrue);
    expect(container.temperature, -20);
    expect(container.temperatureUnit, 'C');
  });

  test('marca refrigerado por tipo ISO R aunque no tenga TMP', () {
    const baplieContent = '''
UNH+1+BAPLIE:D:95B:UN'
TDT+20+V001++++++:::TEST VESSEL'
LOC+147+0210804::5'
EQD+CN+REEF002+45R1++4+5'
UNT+5+1'
''';

    final container = parser.parse(baplieContent).containers.single;

    expect(container.isReefer, isTrue);
    expect(container.temperature, isNull);
    expect(container.temperatureUnit, isNull);
  });

  test('no marca refrigerado sin TMP ni tipo ISO R', () {
    const baplieContent = '''
UNH+1+BAPLIE:D:95B:UN'
TDT+20+V001++++++:::TEST VESSEL'
LOC+147+0210804::5'
EQD+CN+DRY0001+45G1++4+5'
UNT+5+1'
''';

    final container = parser.parse(baplieContent).containers.single;

    expect(container.isReefer, isFalse);
    expect(container.temperature, isNull);
    expect(container.temperatureUnit, isNull);
  });
}
