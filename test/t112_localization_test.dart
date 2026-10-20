import 'package:baystream/core/app.dart';
import 'package:baystream/features/vessel/domain/entities/app_theme_preference.dart';
import 'package:baystream/features/vessel/presentation/providers/theme_preference_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// T-112 · Los textos que pone Flutter salen en español: la app declara el
/// locale `es` y los delegates de flutter_localizations.
class _SystemTheme extends ThemePreferenceNotifier {
  @override
  Future<AppThemePreference> build() async => AppThemePreference.system;
}

/// Abre una ruta empujada, como Alertas o Recientes, para ver el botón de
/// volver que construye Flutter. Devuelve el contexto de esa ruta.
Future<BuildContext> _pushed(WidgetTester tester) async {
  late BuildContext pushed;
  await tester.pumpWidget(ProviderScope(
    overrides: [themePreferenceProvider.overrideWith(_SystemTheme.new)],
    child: BayStreamApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: TextButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(
                builder: (context) {
                  pushed = context;
                  return Scaffold(appBar: AppBar(title: const Text('Segunda')));
                },
              )),
              child: const Text('Abrir'),
            ),
          ),
        ),
      ),
    ),
  ));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Abrir'));
  await tester.pumpAndSettle();
  return pushed;
}

void main() {
  testWidgets('T-112 la app declara el español y Flutter lo usa', (tester) async {
    final context = await _pushed(tester);

    expect(Localizations.localeOf(context), const Locale('es'));
    final material = MaterialLocalizations.of(context);
    expect(material.backButtonTooltip, 'Atrás');
    expect(material.alertDialogLabel, 'Alerta');
    expect(material.modalBarrierDismissLabel, 'Cerrar');
    expect(material.popupMenuLabel, 'Menú emergente');
    expect(material.deleteButtonTooltip, 'Eliminar');
    expect(material.copyButtonLabel, 'Copiar');
    expect(material.pasteButtonLabel, 'Pegar');
    // El botón de volver automático ya no dice «Back» (F01 del censo).
    expect(find.byTooltip('Atrás'), findsOneWidget);
    expect(find.byTooltip('Back'), findsNothing);
  });

  testWidgets('T-112 el selector de fecha habla en español', (tester) async {
    final context = await _pushed(tester);

    showDatePicker(
      context: context,
      initialDate: DateTime(2026, 10, 20),
      firstDate: DateTime(2026),
      lastDate: DateTime(2027),
    );
    await tester.pumpAndSettle();

    expect(find.text('Seleccionar fecha'), findsOneWidget);
    expect(find.text('Cancelar'), findsOneWidget);
    expect(find.textContaining('octubre'), findsWidgets);
    for (final english in ['Select date', 'Cancel', 'OK', 'October 2026']) {
      expect(find.text(english), findsNothing, reason: english);
    }
    expect(tester.takeException(), isNull);
  });
}
