// T-114 · Fase 2 bis: la fundación de la dirección C «Puente de mando»
// (10.14; DESIGN.md 13). La noche, los roles de la vista Estado, las fichas y
// la tabla reordenada, el tema por omisión según el equipo y el contraste
// compuesto de los estados nuevos de la celda.
//
// Las fichas de noche se verifican contra la receta OKLCH de 13.4, calculada
// aquí de nuevo (Björn Ottosson, 2020), y los rellenos de día contra la de
// HSL de la Fase 2, para que la tabla del código sea la del documento y no
// una copia a mano.
import 'dart:io';
import 'dart:math' as math;

import 'package:baystream/core/app.dart';
import 'package:baystream/core/design/design.dart';
import 'package:baystream/features/vessel/domain/entities/app_theme_preference.dart';
import 'package:baystream/features/vessel/presentation/providers/theme_preference_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

double _contraste(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

String _hex(Color c) =>
    '#${c.toARGB32().toRadixString(16).substring(2).toUpperCase()}';

// --- OKLCH → sRGB, como tool/rediseno_contraste.py ------------------------
double _lineal(double c) =>
    c.clamp(0.0, 1.0) <= 0.0031308 ? 12.92 * c : 1.055 * math.pow(c, 1 / 2.4) - 0.055;

List<double> _oklchALineal(double l, double c, double h) {
  final a = c * math.cos(h * math.pi / 180);
  final b = c * math.sin(h * math.pi / 180);
  final l1 = l + 0.3963377774 * a + 0.2158037573 * b;
  final m1 = l - 0.1055613458 * a - 0.0638541728 * b;
  final s1 = l - 0.0894841775 * a - 1.2914855480 * b;
  final l3 = l1 * l1 * l1, m3 = m1 * m1 * m1, s3 = s1 * s1 * s1;
  return [
    4.0767416621 * l3 - 3.3077115913 * m3 + 0.2309699292 * s3,
    -1.2684380046 * l3 + 2.6097574011 * m3 - 0.3413193965 * s3,
    -0.0041960863 * l3 - 0.7034186147 * m3 + 1.7076147010 * s3,
  ];
}

Color _oklch(double l, double c, double h) {
  var croma = c;
  List<double> lineal;
  while (true) {
    lineal = _oklchALineal(l, croma, h);
    if (lineal.every((v) => v >= -0.002 && v <= 1.002) || croma <= 0) break;
    croma -= 0.002;
  }
  int canal(double v) => (_lineal(v.clamp(0.0, 1.0)) * 255).round();
  return Color.fromARGB(255, canal(lineal[0]), canal(lineal[1]), canal(lineal[2]));
}

Color _hsl(double h, double s, double l) =>
    HSLColor.fromAHSL(1, h % 360, s, l).toColor();

const _tonosOklch = [35, 75, 110, 145, 170, 195, 230, 262, 285, 315, 345, 10];

class _PreferenciaFija extends ThemePreferenceNotifier {
  _PreferenciaFija(this.valor);
  final AppThemePreference valor;
  @override
  Future<AppThemePreference> build() async => valor;
}

void main() {
  group('la noche (13.1)', () {
    const noche = BsPaleta.oscuro;
    test('trae los valores de 10.14 y la marca pasa a superficie', () {
      expect(_hex(noche.papel), '#07111F');
      expect(_hex(noche.hoja), '#0C1A31');
      expect(_hex(noche.hojaAlta), '#11223F');
      expect(_hex(noche.linea), '#1E3457');
      expect(_hex(noche.lineaFuerte), '#5272A6');
      expect(_hex(noche.tinta), '#EAF0F9');
      expect(_hex(noche.tintaSuave), '#A9B9D2');
      expect(_hex(noche.tintaTenue), '#8DA0BE');
      expect(_hex(noche.marca), '#4F8EF7', reason: 'la selección');
      expect(_hex(noche.marcaSuperficie), '#0D47A1');
      expect(_hex(noche.marcaTenue), '#0D47A1', reason: 'la marca como superficie');
      expect(noche.sobreMarcaSuperficie, const Color(0xFFFFFFFF));
      expect(_hex(noche.acero), '#6E9DE6');
      expect(_hex(noche.gruaRelleno), '#FF7A1A');
      // El día es el de la Fase 2, sin cambios.
      expect(_hex(BsPaleta.claro.papel), '#F5F8FC');
      expect(_hex(BsPaleta.claro.marca), '#0D47A1');
      expect(_hex(BsPaleta.claro.marcaTenue), '#DCE7F8');
    });

    for (final paleta in [BsPaleta.claro, BsPaleta.oscuro]) {
      final modo = paleta.brillo == Brightness.light ? 'día' : 'noche';
      test('las parejas nuevas cumplen AA en $modo', () {
        final texto = <String, (Color, Color)>{
          'tinta tenue sobre papel': (paleta.tintaTenue, paleta.papel),
          'tinta tenue sobre hoja': (paleta.tintaTenue, paleta.hoja),
          'tinta tenue sobre hoja alta': (paleta.tintaTenue, paleta.hojaAlta),
          'tinta sobre hoja alta': (paleta.tinta, paleta.hojaAlta),
          'tinta suave sobre hoja alta': (paleta.tintaSuave, paleta.hojaAlta),
          'marca sobre hoja': (paleta.marca, paleta.hoja),
          'marca sobre hoja alta': (paleta.marca, paleta.hojaAlta),
          'blanco sobre la marca superficie':
              (paleta.sobreMarcaSuperficie, paleta.marcaSuperficie),
          'la frase sobre la marca superficie':
              (paleta.sobreMarcaSuave, paleta.marcaSuperficie),
          'blanco sobre la marca profunda':
              (paleta.sobreMarcaSuperficie, paleta.marcaProfunda),
          'la frase sobre la marca profunda':
              (paleta.sobreMarcaSuave, paleta.marcaProfunda),
          'tinta sobre marca tenue': (paleta.tinta, paleta.marcaTenue),
        };
        for (final par in texto.entries) {
          expect(_contraste(par.value.$1, par.value.$2), greaterThanOrEqualTo(4.5),
              reason: par.key);
        }
        expect(_contraste(paleta.lineaFuerte, paleta.hojaAlta), greaterThanOrEqualTo(3),
            reason: 'línea fuerte sobre hoja alta');
      });
    }

    test('el contraste de la noche es el que dice DESIGN.md 13.1', () {
      expect(_contraste(noche.tinta, noche.papel), closeTo(16.5, 0.1));
      expect(_contraste(noche.sobreMarcaSuperficie, noche.marcaSuperficie),
          closeTo(8.6, 0.1));
      expect(_contraste(noche.marca, noche.papel), closeTo(5.9, 0.1));
      expect(_contraste(noche.lineaFuerte, noche.hoja), closeTo(3.6, 0.1));
      expect(_contraste(noche.sobreAcero, noche.acero), closeTo(6.9, 0.1));
      expect(_contraste(noche.sobreGrua, noche.gruaRelleno), closeTo(7.3, 0.1));
    });

    test('el tema de noche pone la marca como superficie y la selección invertida', () {
      final tema = BayStreamTema.oscuro();
      final esquema = tema.colorScheme;
      expect(esquema.primary, noche.marca);
      expect(esquema.primaryContainer, noche.marcaSuperficie);
      expect(esquema.surface, noche.papel);
      expect(esquema.surfaceContainerLow, noche.hoja);
      expect(esquema.surfaceContainerHigh, noche.hojaAlta);
      expect(esquema.outline, noche.lineaFuerte);
      expect(esquema.secondaryContainer, noche.aceroTenue);
      expect(tema.navigationRailTheme.indicatorColor, noche.marcaSuperficie);
      expect(tema.navigationRailTheme.selectedIconTheme?.color,
          noche.sobreMarcaSuperficie);
      expect(tema.segmentedButtonTheme.style?.backgroundColor
              ?.resolve({WidgetState.selected}),
          noche.tinta);
      expect(tema.segmentedButtonTheme.style?.foregroundColor
              ?.resolve({WidgetState.selected}),
          noche.papel);
      expect(tema.progressIndicatorTheme.linearTrackColor, noche.linea);
      // De día, todo como en la Fase 2.
      final dia = BayStreamTema.claro();
      expect(dia.segmentedButtonTheme.style?.backgroundColor
              ?.resolve({WidgetState.selected}),
          BsPaleta.claro.marcaTenue);
      expect(dia.progressIndicatorTheme.linearTrackColor, BsPaleta.claro.marcaTenue);
    });
  });

  group('los roles de la vista Estado y los de la noche (13.2)', () {
    for (final (modo, semanticos, paleta) in [
      ('día', BsColoresSemanticos.claro(), BsPaleta.claro),
      ('noche', BsColoresSemanticos.oscuro(), BsPaleta.oscuro),
    ]) {
      test('cumplen AA sobre el relleno y 3:1 sobre los fondos en $modo', () {
        final roles = <String, BsRol>{
          'información': semanticos.informacion,
          'por bajar en cubierta': semanticos.porBajarCubierta,
          'por bajar en bodega': semanticos.porBajarBodega,
          'de paso': semanticos.dePaso,
          'bajado': semanticos.bajado,
          'recién movido': semanticos.recienMovido,
          'pendiente': semanticos.pendiente,
          'hecho': semanticos.hecho,
          'revisar': semanticos.revisar,
          'error': semanticos.error,
          'cubierta': semanticos.cubierta,
          'bodega': semanticos.bodega,
        };
        final fondos = [paleta.papel, paleta.hoja, paleta.hojaAlta, paleta.aceroTenue];
        for (final rol in roles.entries) {
          expect(_contraste(rol.value.texto, rol.value.relleno),
              greaterThanOrEqualTo(4.5),
              reason: '${rol.key}: texto sobre relleno');
          for (final fondo in fondos) {
            expect(_contraste(rol.value.contorno, fondo), greaterThanOrEqualTo(3),
                reason: '${rol.key}: contorno sobre ${_hex(fondo)}');
          }
        }
        expect(_contraste(semanticos.tintaTenue, paleta.hoja), greaterThanOrEqualTo(4.5));
      });
    }

    test('los valores son los del concepto', () {
      final noche = BsColoresSemanticos.oscuro();
      expect(_hex(noche.porBajarCubierta.relleno), '#F5F8FC');
      expect(_hex(noche.porBajarBodega.relleno), '#6E9DE6');
      expect(_hex(noche.dePaso.relleno), '#11223F');
      expect(_hex(noche.dePaso.texto), '#A9B9D2');
      expect(_hex(noche.bajado.relleno), '#07111F');
      expect(_hex(noche.bajado.texto), '#3DD68C');
      expect(noche.bajado.punteado, isTrue);
      expect(_hex(noche.recienMovido.relleno), '#FF7A1A');
      expect(_hex(noche.recienMovido.contorno), '#FFB27A');
      expect(_hex(noche.hecho.contorno), '#3DD68C');
      expect(_hex(noche.revisar.contorno), '#F5B83D');
      expect(_hex(noche.error.contorno), '#F2777A');
      final dia = BsColoresSemanticos.claro();
      expect(_hex(dia.porBajarCubierta.relleno), '#0D47A1');
      expect(dia.porBajarCubierta.texto, const Color(0xFFFFFFFF));
      expect(_hex(dia.porBajarBodega.relleno), '#1F5FD6');
      expect(dia.bajado.relleno, dia.hecho.relleno);
      expect(dia.bajado.punteado, isFalse);
      expect(dia.dePaso.relleno, BsPaleta.claro.papel, reason: 'la Fase 2');
    });

    test('la celda atenuada cae a tinta cuando la tinta suave no llega (13.2)', () {
      for (final (semanticos, paleta) in [
        (BsColoresSemanticos.claro(), BsPaleta.claro),
        (BsColoresSemanticos.oscuro(), BsPaleta.oscuro),
      ]) {
        final porBajar = semanticos.porBajarCubierta.atenuado(
          papel: paleta.papel,
          tintaSuave: paleta.tintaSuave,
          tinta: paleta.tinta,
          lineaFuerte: paleta.lineaFuerte,
        );
        expect(_contraste(paleta.tintaSuave, porBajar.relleno), lessThan(4.5),
            reason: 'la tinta suave no llega sobre el blanco o la marca al 35 %');
        expect(porBajar.texto, paleta.tinta);
        expect(_contraste(porBajar.texto, porBajar.relleno), greaterThanOrEqualTo(4.5));
        final ficha = semanticos.categorico('GTSTC').atenuado(
          papel: paleta.papel,
          tintaSuave: paleta.tintaSuave,
          tinta: paleta.tinta,
          lineaFuerte: paleta.lineaFuerte,
        );
        expect(ficha.texto, paleta.tintaSuave, reason: 'cuando llega, tinta suave');
        // Sin `tinta`, como en la Fase 2, sigue siendo la tinta suave.
        expect(
            semanticos.porBajarCubierta
                .atenuado(
                    papel: paleta.papel,
                    tintaSuave: paleta.tintaSuave,
                    lineaFuerte: paleta.lineaFuerte)
                .texto,
            paleta.tintaSuave);
        // El punteado se conserva al atenuar.
        expect(
            semanticos.bajado
                .atenuado(
                    papel: paleta.papel,
                    tintaSuave: paleta.tintaSuave,
                    lineaFuerte: paleta.lineaFuerte)
                .punteado,
            semanticos.bajado.punteado);
      }
    });
  });

  group('la tabla reordenada y las fichas (13.4)', () {
    test('la ranura k pinta el tono [11, 6, 3, 9, 1, 8, 4, 0, 10, 5, 2, 7][k mod 12]', () {
      expect(tonosPorRanura, [11, 6, 3, 9, 1, 8, 4, 0, 10, 5, 2, 7]);
      expect(tonosPorRanura.toSet(), hasLength(12), reason: 'una permutación');
      for (var k = 0; k < ranurasCategoricas; k++) {
        expect(tonoDeRanura(k), tonosPorRanura[k % 12]);
      }
      expect(nombresDeTono[tonoDeRanura(0)], 'rosa');
      expect(nombresDeTono[tonoDeRanura(1)], 'cielo');
      expect(nombresDeTono[tonoDeRanura(2)], 'hierba');
      expect(nombresDeTono[tonoDeRanura(3)], 'uva');
      expect(nombresDeTono[tonoDeRanura(4)], 'ámbar');
    });

    test('los cinco primeros puertos quedan a 60° o más en la rueda de 12 tonos', () {
      final puertos = ['JMKIN', 'USHOU', 'GTSTC', 'JMKCT', 'PAMIT'];
      int separacion(List<int> tonos) {
        var minimo = 360;
        for (var i = 0; i < tonos.length; i++) {
          for (var j = i + 1; j < tonos.length; j++) {
            final d = (tonos[i] - tonos[j]).abs();
            minimo = math.min(minimo, math.min(d, 360 - d));
          }
        }
        return minimo;
      }

      // La rueda de la tabla: doce tonos a 30° (la de la Fase 2 y la de 10.14).
      final rueda = [
        for (final puerto in puertos) 15 + 30 * tonoDeRanura(tablaFijaDePuertos[puerto]!),
      ];
      expect(rueda, [345, 195, 105, 285, 45]);
      expect(separacion(rueda), 60);
      // Antes (ranura k → tono k) quedaban a 30°.
      expect(separacion([15, 45, 75, 105, 135]), 30);
      // En los matices OKLCH de las fichas, uva y rosa quedan a 55° (13.4).
      final oklch = [
        for (final puerto in puertos) _tonosOklch[tonoDeRanura(tablaFijaDePuertos[puerto]!)],
      ];
      expect(oklch, [10, 230, 145, 315, 75]);
      expect(separacion(oklch), 55);
      // Las tablas de códigos y la ranura de reserva no cambian.
      expect(tablaFijaDePuertos['JMKIN'], 0);
      expect(tablaFijaDePuertos['USMSY'], 14);
      expect(ranuraCategorica('MXVER'), 21);
      expect(ranuraCategorica('PABLB'), 18);
    });

    test('de noche las 24 ranuras son las fichas OKLCH de la receta', () {
      final noche = BsColoresSemanticos.oscuro();
      for (var k = 0; k < ranurasCategoricas; k++) {
        final h = _tonosOklch[tonoDeRanura(k)].toDouble();
        final suave = k < 12;
        final relleno = suave ? _oklch(0.34, 0.075, h) : _oklch(0.44, 0.12, h);
        final vivo = suave ? _oklch(0.84, 0.12, h) : _oklch(0.93, 0.06, h);
        final rol = noche.categoricos[k];
        expect(_hex(rol.relleno), _hex(relleno), reason: 'ranura $k relleno');
        expect(_hex(rol.texto), _hex(vivo), reason: 'ranura $k código');
        expect(rol.contorno, rol.texto, reason: 'código y contorno, el mismo tono vivo');
        expect(_contraste(rol.texto, rol.relleno), greaterThanOrEqualTo(suave ? 7.0 : 6.0),
            reason: 'ranura $k código sobre relleno');
        for (final fondo in [BsPaleta.oscuro.papel, BsPaleta.oscuro.hoja, BsPaleta.oscuro.hojaAlta]) {
          expect(_contraste(rol.contorno, fondo), greaterThanOrEqualTo(3),
              reason: 'ranura $k contorno sobre ${_hex(fondo)}');
        }
        // Las intensas se separan de las suaves por luminosidad.
        if (!suave) {
          final suaveDelTono = noche.categoricos[k - 12];
          expect(rol.relleno.computeLuminance(),
              greaterThan(suaveDelTono.relleno.computeLuminance()));
          expect(rol.texto.computeLuminance(),
              greaterThan(suaveDelTono.texto.computeLuminance()));
        }
      }
      // Los ejemplos del concepto (Sistema.dc.html).
      expect(_hex(noche.categorico('PAMIT').relleno), '#4E3100');
      expect(_hex(noche.categorico('PAMIT').texto), '#F8BF6C');
      expect(_hex(noche.categorico('GTSTC').relleno), '#1B421E');
      expect(_hex(noche.categorico('GTSTC').texto), '#98DF9A');
      expect(_hex(noche.categorico('JMKIN').relleno), '#58252F');
    });

    test('de día las 24 ranuras son los rellenos de la Fase 2, reordenados', () {
      final dia = BsColoresSemanticos.claro();
      for (var k = 0; k < ranurasCategoricas; k++) {
        final h = (15 + 30 * tonoDeRanura(k)).toDouble();
        final (sRel, lRel, sBor, lBor) =
            k < 12 ? (0.55, 0.85, 0.60, 0.32) : (0.50, 0.74, 0.60, 0.26);
        final rol = dia.categoricos[k];
        expect(_hex(rol.relleno), _hex(_hsl(h, sRel, lRel)), reason: 'ranura $k relleno');
        expect(_hex(rol.contorno), _hex(_hsl(h, sBor, lBor)), reason: 'ranura $k contorno');
        expect(rol.texto, const Color(0xFF10243F));
      }
      // JMKIN era arcilla y ahora es rosa; GTSTC era oliva y ahora hierba.
      expect(_hex(dia.categorico('JMKIN').relleno), '#EEC4CE');
      expect(_hex(dia.categorico('GTSTC').relleno), '#CEEEC4');
    });

    test('tool/rediseno_contraste.py lleva la misma permutación y la receta', () {
      final script = File('tool/rediseno_contraste.py').readAsStringSync();
      expect(script, contains('TONO_DE_RANURA = [11, 6, 3, 9, 1, 8, 4, 0, 10, 5, 2, 7]'));
      expect(script, contains('TONOS_OKLCH = [35, 75, 110, 145, 170, 195, 230, 262, 285, 315, 345, 10]'));
      expect(script, contains("'suave': ((0.34, 0.075), (0.84, 0.12))"));
      expect(script, contains("'intensa': ((0.44, 0.12), (0.93, 0.06))"));
    });
  });

  group('el tema por omisión según el equipo (13.5)', () {
    tearDown(() => debugDefaultTargetPlatformOverride = null);

    test('el tema por omisión del equipo: oscuro en la oficina y claro en el muelle', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      expect(bayStreamTemaPorOmision, ThemeMode.dark);
      debugDefaultTargetPlatformOverride = TargetPlatform.linux;
      expect(bayStreamTemaPorOmision, ThemeMode.dark);
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      expect(bayStreamTemaPorOmision, ThemeMode.light);
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      expect(bayStreamTemaPorOmision, ThemeMode.light);
    });

    test('la preferencia de T-90 sigue igual: «Seguir al sistema» sigue al sistema', () {
      // Hasta que el almacén distinga «no elegido» de «Seguir al sistema»
      // (DESIGN.md 13.5; 2b.6 del informe), `system` no se resuelve por equipo.
      for (final plataforma in [TargetPlatform.windows, TargetPlatform.android]) {
        debugDefaultTargetPlatformOverride = plataforma;
        expect(bayStreamThemeMode(AppThemePreference.system), ThemeMode.system);
        expect(bayStreamThemeMode(AppThemePreference.light), ThemeMode.light);
        expect(bayStreamThemeMode(AppThemePreference.dark), ThemeMode.dark);
      }
    });

    for (final (plataforma, preferencia, sistema, brillo) in [
      (TargetPlatform.windows, AppThemePreference.system, Brightness.dark, Brightness.dark),
      (TargetPlatform.windows, AppThemePreference.system, Brightness.light, Brightness.light),
      (TargetPlatform.windows, AppThemePreference.light, Brightness.dark, Brightness.light),
      (TargetPlatform.android, AppThemePreference.dark, Brightness.light, Brightness.dark),
    ]) {
      testWidgets(
          'la app abre en ${brillo.name} en ${plataforma.name} con ${preferencia.name} '
          'y el sistema en ${sistema.name}', (tester) async {
        debugDefaultTargetPlatformOverride = plataforma;
        tester.platformDispatcher.platformBrightnessTestValue = sistema;
        addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
        Brightness? visto;
        try {
          await tester.pumpWidget(ProviderScope(
            overrides: [
              themePreferenceProvider.overrideWith(() => _PreferenciaFija(preferencia)),
            ],
            child: BayStreamApp(
              home: Builder(builder: (context) {
                visto = Theme.of(context).brightness;
                return const SizedBox();
              }),
            ),
          ));
          await tester.pumpAndSettle();
          expect(visto, brillo,
              reason: '«Seguir al sistema» sigue al sistema y la elección explícita '
                  'manda sobre él, en cualquier equipo (T-90)');
          await tester.pumpWidget(const SizedBox());
        } finally {
          // La plataforma vuelve a la de las pruebas antes de que el arnés
          // compruebe sus invariantes.
          debugDefaultTargetPlatformOverride = null;
        }
      });
    }
  });

  group('el contraste compuesto de los estados nuevos de la celda', () {
    for (final oscuro in [false, true]) {
      for (final muelle in [true, false]) {
        final modo = '${oscuro ? 'noche' : 'día'}, ${muelle ? 'muelle' : 'oficina'}';
        final tema = oscuro
            ? BayStreamTema.oscuro(muelle: muelle)
            : BayStreamTema.claro(muelle: muelle);
        testWidgets('los estados de la vista Estado cumplen 4.5:1 y 3:1 en $modo',
            (tester) async {
          final semanticos = tema.extension<BsColoresSemanticos>()!;
          final fondos = <String, Color>{
            'papel': tema.colorScheme.surface,
            'cubierta': semanticos.cubierta.relleno,
            'bodega': semanticos.bodega.relleno,
          };
          var medidos = 0;
          for (final fondo in fondos.entries) {
            for (final estado in BsEstadoDeCelda.values) {
              if (estado == BsEstadoDeCelda.ninguno) continue;
              for (final marca in [
                BsMarcaDeCelda.ninguna,
                BsMarcaDeCelda.baja,
                BsMarcaDeCelda.hecho,
                BsMarcaDeCelda.paso,
              ]) {
                for (final atenuada in [false, true]) {
                  for (final insignia in [
                    BsInsigniaDeCelda.ninguna,
                    BsInsigniaDeCelda.peligrosa,
                  ]) {
                    final donde =
                        '${estado.name} + ${marca.name}${atenuada ? ' atenuada' : ''}'
                        '${insignia == BsInsigniaDeCelda.ninguna ? '' : ' con insignia'}'
                        ' sobre ${fondo.key} en $modo';
                    await tester.pumpWidget(MaterialApp(
                      theme: tema,
                      home: Scaffold(
                        body: ColoredBox(
                          color: fondo.value,
                          child: Center(
                            child: BsCelda(
                              codigo: 'GTSTC',
                              linea2: '24.1',
                              estado: estado,
                              marca: marca,
                              insignia: insignia,
                              atenuada: atenuada,
                              categoria: semanticos.categorico('GTSTC'),
                              curva: BsCurvaDeCelda.babor,
                              etiqueta: donde,
                              onTap: () {},
                            ),
                          ),
                        ),
                      ),
                    ));
                    expect(tester.takeException(), isNull, reason: donde);
                    _medirCompuesto(tester, fondo.value, donde);
                    medidos++;
                  }
                }
              }
            }
          }
          expect(medidos, 3 * 5 * 4 * 2 * 2);
        });
      }
    }
  });
}

/// Compone lo que la celda dibuja sobre [fondo], como en
/// t114_celda_contraste_test.dart, y admite el contorno punteado (un
/// `CustomPaint` con `foregroundPainter` en vez de un `Border`).
void _medirCompuesto(WidgetTester tester, Color fondo, String donde) {
  final celda = find.byType(BsCelda);
  final contenedor = tester.widget<Container>(
      find.descendant(of: celda, matching: find.byType(Container)).first);
  final decoracion = contenedor.decoration! as BoxDecoration;
  final relleno = decoracion.color!;
  final fondoCompuesto = Color.alphaBlend(relleno, fondo);
  Color? contorno = (decoracion.border as Border?)?.top.color;
  if (contorno == null) {
    final pinturas = tester
        .widgetList<CustomPaint>(
            find.descendant(of: celda, matching: find.byType(CustomPaint)))
        .where((p) => p.foregroundPainter != null);
    expect(pinturas, isNotEmpty, reason: '$donde: sin contorno ni punteado');
    contorno = (pinturas.first.foregroundPainter! as BsContornoPunteado).color;
  }
  expect(_contraste(Color.alphaBlend(contorno, fondo), fondo), greaterThanOrEqualTo(3.0),
      reason: '$donde: contorno ${_hex(contorno)} sobre ${_hex(fondo)}');
  var tintas = 0;
  for (final rico in tester.widgetList<RichText>(
      find.descendant(of: celda, matching: find.byType(RichText)))) {
    final tramo = rico.text as TextSpan;
    final estilo = tramo.style!;
    final esIcono = estilo.fontFamily == 'MaterialIcons';
    if (!esIcono && tramo.toPlainText().isEmpty) continue;
    final compuesto = Color.alphaBlend(estilo.color!, fondoCompuesto);
    expect(_contraste(compuesto, fondoCompuesto),
        greaterThanOrEqualTo(esIcono ? 3.0 : 4.5),
        reason: '$donde: ${esIcono ? 'icono' : 'texto «${tramo.toPlainText()}»'} '
            '${_hex(compuesto)} sobre ${_hex(fondoCompuesto)}');
    tintas++;
  }
  expect(tintas, greaterThan(0), reason: '$donde: nada que medir');
}
