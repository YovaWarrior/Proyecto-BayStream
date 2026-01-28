import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:baystream/core/app.dart';

void main() {
  testWidgets('BayStreamApp debe mostrar título correctamente', (WidgetTester tester) async {
    // Construir la app con ProviderScope
    await tester.pumpWidget(
      const ProviderScope(
        child: BayStreamApp(),
      ),
    );

    // Verificar que el título BayStream aparece
    expect(find.text('BayStream'), findsWidgets);
  });
}
