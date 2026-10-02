import 'package:baystream/core/app.dart';
import 'package:baystream/main.dart' as entry;
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
      'T-47 sin opciones muestra causa y accion antes de iniciar Firebase',
      (tester) async {
    await entry.main();
    await tester.pumpAndSettle();
    expect(find.text('Falta la configuración de Firebase'), findsOneWidget);
    expect(find.textContaining('Solicita una compilación configurada'),
        findsOneWidget);
    expect(find.byType(BayStreamApp), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
