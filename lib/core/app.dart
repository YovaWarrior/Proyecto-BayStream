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
      // T-114 (Fase 3): el tema de la dirección A «Plano de a bordo», en claro
      // y en oscuro, con la preferencia de tema que ya existía (T-90).
      theme: BayStreamTema.claro(muelle: muelle),
      darkTheme: BayStreamTema.oscuro(muelle: muelle),
      themeMode: switch (preference) {
        AppThemePreference.system => ThemeMode.system,
        AppThemePreference.light => ThemeMode.light,
        AppThemePreference.dark => ThemeMode.dark,
      },
      builder: builder,
      home: home,
    );
  }
}
