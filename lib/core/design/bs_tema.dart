import 'package:flutter/material.dart';

import 'bs_categorico.dart';
import 'bs_colores_semanticos.dart';
import 'bs_medidas.dart';
import 'bs_paleta.dart';
import 'bs_tipografia.dart';

/// El tema de BayStream: la dirección C «Puente de mando» sobre Material 3
/// (`DESIGN.md`, 13.1): el día de la Fase 2 y la noche de 10.14.
///
/// Construye el [ColorScheme] desde la paleta, el [TextTheme] con Plex y los
/// temas de componente con las medidas de la densidad, y cuelga las tres
/// extensiones: [BsColoresSemanticos], [BsMedidas] y [BsTextos]. Material 3
/// sigue siendo la base (RNF-002 lo mide): no hay ninguna biblioteca más.
abstract final class BayStreamTema {
  /// El tema del día. Con [muelle], la densidad del muelle; [tablaFija] es la
  /// tabla de «Colorear por», por omisión la confirmada en 10.6
  /// ([tablaFijaConfirmada]); T-115 le suma las asignaciones de la oficina.
  static ThemeData claro({
    bool muelle = false,
    Map<String, int> tablaFija = tablaFijaConfirmada,
  }) =>
      construir(
        paleta: BsPaleta.claro,
        semanticos: BsColoresSemanticos.claro(tablaFija: tablaFija),
        medidas: muelle ? BsMedidas.muelle : BsMedidas.oficina,
      );

  /// El tema de la noche. Con [muelle], la densidad del muelle; [tablaFija]
  /// como en [claro].
  static ThemeData oscuro({
    bool muelle = false,
    Map<String, int> tablaFija = tablaFijaConfirmada,
  }) =>
      construir(
        paleta: BsPaleta.oscuro,
        semanticos: BsColoresSemanticos.oscuro(tablaFija: tablaFija),
        medidas: muelle ? BsMedidas.muelle : BsMedidas.oficina,
      );

  /// El [ColorScheme] de una paleta: la semilla de Material 3 y, encima, los
  /// roles con los colores con nombre (la tabla de 13.1).
  static ColorScheme esquema(BsPaleta paleta, BsColoresSemanticos semanticos) {
    final claro = paleta.brillo == Brightness.light;
    final hojaMedia = Color.lerp(paleta.papel, paleta.hojaAlta, 0.5)!;
    return ColorScheme.fromSeed(
      seedColor: BsPaleta.claro.marca,
      brightness: paleta.brillo,
    ).copyWith(
      primary: paleta.marca,
      onPrimary: paleta.sobreMarca,
      primaryContainer: paleta.marcaTenue,
      onPrimaryContainer: paleta.tinta,
      secondary: paleta.acero,
      onSecondary: paleta.sobreAcero,
      secondaryContainer: paleta.aceroTenue,
      onSecondaryContainer: paleta.tinta,
      tertiary: paleta.grua,
      onTertiary: paleta.sobreGrua,
      tertiaryContainer: paleta.gruaRelleno,
      onTertiaryContainer: paleta.sobreGrua,
      error: semanticos.error.contorno,
      onError: semanticos.error.relleno,
      errorContainer: semanticos.error.relleno,
      onErrorContainer: semanticos.error.texto,
      surface: paleta.papel,
      onSurface: paleta.tinta,
      onSurfaceVariant: paleta.tintaSuave,
      surfaceDim: claro ? paleta.hojaAlta : paleta.papel,
      surfaceBright: claro ? paleta.hoja : paleta.hojaAlta,
      surfaceContainerLowest: claro ? paleta.hoja : paleta.papel,
      surfaceContainerLow: claro ? paleta.papel : paleta.hoja,
      surfaceContainer: claro ? hojaMedia : paleta.hoja,
      surfaceContainerHigh: paleta.hojaAlta,
      surfaceContainerHighest: paleta.hojaAlta,
      surfaceTint: paleta.marca,
      outline: paleta.lineaFuerte,
      outlineVariant: paleta.linea,
    );
  }

  /// Arma el [ThemeData] completo.
  static ThemeData construir({
    required BsPaleta paleta,
    required BsColoresSemanticos semanticos,
    required BsMedidas medidas,
  }) {
    final claro = paleta.brillo == Brightness.light;
    final colores = esquema(paleta, semanticos);
    final textos = bsTextTheme(paleta);
    final propios = BsTextos.de(paleta);
    final radioControl = BorderRadius.circular(medidas.radioControl);
    final formaControl = RoundedRectangleBorder(borderRadius: radioControl);
    // La selección (13.1): de día, el tinte de marca con tinta encima; de
    // noche se invierte, tinta con la noche encima, como el segmento
    // «Descarga» del concepto. El indicador del riel y de la barra usa la marca
    // como superficie, con texto en tinta de día y blanco de noche.
    final seleccionFondo = claro ? paleta.marcaTenue : paleta.tinta;
    final seleccionTexto = claro ? paleta.tinta : paleta.papel;
    final sobreIndicador = claro ? paleta.tinta : paleta.sobreMarcaSuperficie;
    return ThemeData(
      useMaterial3: true,
      brightness: paleta.brillo,
      colorScheme: colores,
      scaffoldBackgroundColor: paleta.papel,
      canvasColor: paleta.papel,
      fontFamily: BsFuentes.sans,
      fontFamilyFallback: BsFuentes.respaldo,
      textTheme: textos,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      visualDensity: VisualDensity.standard,
      iconTheme: IconThemeData(color: paleta.tinta, size: 24),
      dividerTheme:
          DividerThemeData(color: paleta.linea, thickness: 1, space: 1),
      appBarTheme: AppBarTheme(
        backgroundColor: paleta.papel,
        foregroundColor: paleta.tinta,
        surfaceTintColor: paleta.papel,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        toolbarHeight: medidas.alturaBarraSuperior,
        titleTextStyle: textos.titleLarge,
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: medidas.alturaBarraNavegacion,
        backgroundColor: paleta.hoja,
        surfaceTintColor: paleta.hoja,
        indicatorColor: paleta.marcaTenue,
        labelTextStyle: WidgetStatePropertyAll<TextStyle?>(textos.labelMedium),
        iconTheme: WidgetStateProperty.resolveWith<IconThemeData>(
          (Set<WidgetState> estados) => IconThemeData(
            color: estados.contains(WidgetState.selected)
                ? sobreIndicador
                : paleta.tinta,
            size: 24,
          ),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: paleta.papel,
        indicatorColor: paleta.marcaTenue,
        minWidth: medidas.anchoRiel,
        labelType: NavigationRailLabelType.all,
        selectedIconTheme: IconThemeData(color: sobreIndicador, size: 24),
        unselectedIconTheme: IconThemeData(color: paleta.tintaSuave, size: 24),
        selectedLabelTextStyle: textos.labelMedium,
        unselectedLabelTextStyle:
            textos.labelMedium?.copyWith(color: paleta.tintaSuave),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: Size(medidas.objetivoTactil, medidas.alturaBoton),
          shape: formaControl,
          textStyle: textos.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: Size(medidas.objetivoTactil, medidas.alturaBoton),
          shape: formaControl,
          side: BorderSide(color: paleta.lineaFuerte),
          textStyle: textos.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: Size(medidas.objetivoTactil, medidas.alturaBoton),
          shape: formaControl,
          textStyle: textos.labelLarge,
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          selectedBackgroundColor: seleccionFondo,
          selectedForegroundColor: seleccionTexto,
          minimumSize: Size(medidas.objetivoTactil, medidas.alturaBoton),
          shape: formaControl,
          textStyle: textos.labelLarge,
        ),
      ),
      chipTheme: ChipThemeData(
        shape: formaControl,
        side: BorderSide(color: paleta.linea),
        backgroundColor: paleta.hoja,
        selectedColor: seleccionFondo,
        labelStyle: textos.labelMedium,
        secondaryLabelStyle: textos.labelMedium?.copyWith(color: seleccionTexto),
        padding: EdgeInsets.symmetric(
          horizontal: medidas.espacioM,
          vertical: (medidas.alturaChip - BsEscala.rotulo * 1.2) / 2,
        ),
        showCheckmark: false,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: paleta.hoja,
        surfaceTintColor: paleta.hoja,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(medidas.radioHoja),
          side: BorderSide(color: paleta.linea),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: paleta.hoja,
        surfaceTintColor: paleta.hoja,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(medidas.radioDialogo),
        ),
        titleTextStyle: textos.titleLarge,
        contentTextStyle: textos.bodyMedium,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: paleta.hoja,
        surfaceTintColor: paleta.hoja,
        showDragHandle: true,
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(medidas.radioDialogo)),
        ),
      ),
      inputDecorationTheme: InputDecorationThemeData(
        filled: true,
        fillColor: paleta.hoja,
        border: OutlineInputBorder(
          borderRadius: radioControl,
          borderSide: BorderSide(color: paleta.lineaFuerte),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: radioControl,
          borderSide: BorderSide(color: paleta.lineaFuerte),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: radioControl,
          borderSide: BorderSide(color: paleta.marca, width: 2),
        ),
        labelStyle: textos.bodyMedium?.copyWith(color: paleta.tintaSuave),
        helperStyle: textos.bodySmall,
        helperMaxLines: 3,
        constraints: BoxConstraints(minHeight: medidas.alturaCampo),
      ),
      listTileTheme: ListTileThemeData(
        minTileHeight: medidas.alturaFila,
        iconColor: paleta.tintaSuave,
        textColor: paleta.tinta,
        titleTextStyle: textos.bodyLarge,
        subtitleTextStyle: textos.bodySmall,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: paleta.hojaAlta,
        contentTextStyle: textos.bodyMedium,
        actionTextColor: paleta.marca,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(medidas.radioHoja),
          side: BorderSide(color: paleta.linea),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: paleta.marca,
        linearTrackColor: claro ? paleta.marcaTenue : paleta.linea,
        linearMinHeight: medidas.espacioS,
      ),
      badgeTheme: BadgeThemeData(
        backgroundColor: paleta.grua,
        textColor: paleta.sobreMarca,
      ),
      tooltipTheme: TooltipThemeData(
        textStyle: textos.bodySmall?.copyWith(color: paleta.papel),
        decoration: BoxDecoration(
          color: paleta.tinta,
          borderRadius: radioControl,
        ),
      ),
      extensions: <ThemeExtension<dynamic>>[semanticos, medidas, propios],
    );
  }
}
