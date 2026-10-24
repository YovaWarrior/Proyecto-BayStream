// T-114 · El tema se construye una vez (10.17, hallazgo del arnés de la
// corrección de la Fase 2 bis): `BayStreamApp.build` pedía un `ThemeData`
// nuevo en cada build y el `AnimatedTheme` de `MaterialApp` corría 200 ms
// aunque nada hubiera cambiado. Ahora `bayStreamTemaClaro` y
// `bayStreamTemaOscuro` (app.dart) devuelven la misma instancia por densidad,
// y volver a construir la app no anima nada. `BayStreamTema` sigue
// construyendo un tema nuevo cada vez que se le pide: la caché es de la app.
import 'package:baystream/core/app.dart';
import 'package:baystream/core/design/design.dart';
import 'package:baystream/features/vessel/domain/entities/app_theme_preference.dart';
import 'package:baystream/features/vessel/presentation/providers/theme_preference_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// La preferencia fija, sin almacén.
class _Fija extends ThemePreferenceNotifier {
  _Fija(this.valor);
  final AppThemePreference valor;
  @override
  Future<AppThemePreference> build() async => valor;
}

void main() {
  test('el tema de cada densidad y brillo se construye una sola vez', () {
    expect(identical(bayStreamTemaClaro(), bayStreamTemaClaro()), isTrue);
    expect(identical(bayStreamTemaOscuro(), bayStreamTemaOscuro()), isTrue);
    expect(
        identical(bayStreamTemaClaro(muelle: true),
            bayStreamTemaClaro(muelle: true)),
        isTrue);
    expect(
        identical(bayStreamTemaOscuro(muelle: true),
            bayStreamTemaOscuro(muelle: true)),
        isTrue);
    // Densidades y brillos distintos son temas distintos.
    expect(identical(bayStreamTemaClaro(), bayStreamTemaClaro(muelle: true)),
        isFalse);
    expect(identical(bayStreamTemaClaro(), bayStreamTemaOscuro()), isFalse);
    expect(bayStreamTemaClaro().extension<BsMedidas>()!.esMuelle, isFalse);
    expect(bayStreamTemaClaro(muelle: true).extension<BsMedidas>()!.esMuelle,
        isTrue);
    expect(bayStreamTemaOscuro().brightness, Brightness.dark);
    // El sistema de diseño sigue construyendo uno nuevo cada vez (T-115 le
    // pasa otra tabla de «Colorear por»); la caché es de la app.
    expect(identical(BayStreamTema.claro(), BayStreamTema.claro()), isFalse);
  });

  testWidgets(
      'volver a construir BayStreamApp deja el mismo ThemeData y no anima el tema',
      (tester) async {
    late StateSetter rehacer;
    var construcciones = 0;
    await tester.pumpWidget(ProviderScope(
      overrides: [
        themePreferenceProvider
            .overrideWith(() => _Fija(AppThemePreference.light)),
      ],
      child: StatefulBuilder(builder: (context, setState) {
        rehacer = setState;
        construcciones++;
        return const BayStreamApp(home: SizedBox(key: ValueKey('hogar')));
      }),
    ));
    await tester.pumpAndSettle();
    final hogar = find.byKey(const ValueKey('hogar'));
    final antes = Theme.of(tester.element(hogar));
    final temaDeLaApp =
        tester.widget<MaterialApp>(find.byType(MaterialApp)).theme;
    expect(identical(temaDeLaApp, bayStreamTemaClaro(muelle: bayStreamEsMuelle)),
        isTrue, reason: 'la app usa la instancia guardada');

    // Un rebuild de la raíz, como el que provoca cualquier provider.
    rehacer(() {});
    await tester.pump();
    expect(construcciones, 2);
    expect(tester.hasRunningAnimations, isFalse,
        reason: 'con el mismo ThemeData el AnimatedTheme no tiene nada que animar');
    final despues = Theme.of(tester.element(hogar));
    expect(identical(antes, despues), isTrue);
    expect(
        identical(tester.widget<MaterialApp>(find.byType(MaterialApp)).theme,
            temaDeLaApp),
        isTrue);
    expect(tester.takeException(), isNull);
  });
}
