import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/vessel/domain/entities/app_theme_preference.dart';
import '../features/vessel/presentation/providers/theme_preference_provider.dart';
import '../features/vessel/presentation/pages/vessel_overview_page.dart';

class BayStreamApp extends ConsumerWidget {
  final Widget home;
  final TransitionBuilder? builder;
  const BayStreamApp({super.key, this.home = const VesselOverviewPage(), this.builder});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preference = ref.watch(themePreferenceProvider).value ?? AppThemePreference.system;
    return MaterialApp(
      title: 'BayStream',
      debugShowCheckedModeBanner: false,
      // T-112: los textos que pone Flutter (botón de volver, diálogos, selector
      // de fecha, copiar y pegar) también en español.
      locale: const Locale('es'),
      supportedLocales: const [Locale('es')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0D47A1),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0D47A1),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
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
