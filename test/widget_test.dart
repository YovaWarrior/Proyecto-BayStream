import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:baystream/core/app.dart';
import 'package:baystream/features/vessel/domain/entities/app_theme_preference.dart';
import 'package:baystream/features/vessel/presentation/providers/theme_preference_provider.dart';

class _SystemTheme extends ThemePreferenceNotifier {
  @override
  Future<AppThemePreference> build() async => AppThemePreference.system;
}

void main() {
  testWidgets('BayStreamApp debe mostrar título correctamente', (WidgetTester tester) async {
    // Construir la app con ProviderScope
    await tester.pumpWidget(
      ProviderScope(
        overrides: [themePreferenceProvider.overrideWith(_SystemTheme.new)],
        child: const BayStreamApp(),
      ),
    );

    // Verificar que el título BayStream aparece
    expect(find.text('BayStream'), findsWidgets);
  });
}
