import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/vessel/domain/entities/app_theme_preference.dart';
import '../features/vessel/presentation/providers/theme_preference_provider.dart';
import '../features/vessel/presentation/pages/vessel_overview_page.dart';
import 'design/bs_tema.dart';

/// La densidad del tema (`DESIGN.md` 4.3): la del muelle en el teléfono
/// (Android e iOS) y la de la oficina en Windows y en la Web.
bool get bayStreamEsMuelle =>
    !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS);

/// El tema por omisión según el equipo (`DESIGN.md` 13.5, decisión 10.14):
/// claro en el muelle (Android e iOS, al sol) y oscuro en la oficina (Windows
/// y la Web). Es lo que toca cuando el usuario **nunca eligió** un tema.
///
/// Todavía no gobierna [bayStreamThemeMode]: el almacén devuelve `system`
/// tanto cuando nadie eligió como cuando el usuario eligió «Seguir al
/// sistema» (`hive_vessel_data_source.dart:117`), y la presentación no puede
/// distinguirlos sin tocar `data/`; T-90 exige que «Seguir al sistema» siga al
/// sistema. Queda propuesto en `DESIGN.md` 13.5 y en el informe de la Fase 2
/// bis; cuando el almacén distinga «no elegido», ese caso resuelve aquí.
ThemeMode get bayStreamTemaPorOmision =>
    bayStreamEsMuelle ? ThemeMode.light : ThemeMode.dark;

/// El [ThemeMode] que corresponde a la preferencia de T-90: «Claro» y
/// «Oscuro» mandan, y «Seguir al sistema» sigue al sistema, como en T-90.
ThemeMode bayStreamThemeMode(AppThemePreference preference) =>
    switch (preference) {
      AppThemePreference.system => ThemeMode.system,
      AppThemePreference.light => ThemeMode.light,
      AppThemePreference.dark => ThemeMode.dark,
    };

class BayStreamApp extends ConsumerWidget {
  final Widget home;
  final TransitionBuilder? builder;
  const BayStreamApp({super.key, this.home = const VesselOverviewPage(), this.builder});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preference = ref.watch(themePreferenceProvider).value ?? AppThemePreference.system;
    final muelle = bayStreamEsMuelle;
    return MaterialApp(
      title: 'BayStream',
      debugShowCheckedModeBanner: false,
      // T-112: los textos que pone Flutter (botón de volver, diálogos, selector
      // de fecha, copiar y pegar) también en español.
      locale: const Locale('es'),
      supportedLocales: const [Locale('es')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      // T-114 (Fase 3): el tema de la dirección C «Puente de mando», el día y
      // la noche, con la preferencia de tema que ya existía (T-90). El tema
      // por omisión según el equipo (10.14) espera a que el almacén distinga
      // «no elegido» (Fase 2 bis, 2b.6 del informe).
      theme: BayStreamTema.claro(muelle: muelle),
      darkTheme: BayStreamTema.oscuro(muelle: muelle),
      themeMode: bayStreamThemeMode(preference),
      builder: builder,
      home: home,
    );
  }
}
