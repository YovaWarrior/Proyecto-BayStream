// T-121 · Las estadísticas, «El buque en corte» (SPRINT-4.md 10.36 a 10.38 y
// 10.46; DESIGN.md 15):
//   - las cifras cuadran entre sí, sobre el sintético de 977 en 72 bahías y
//     sobre el plano de dos bahías de T-117;
//   - el contraste compuesto de todo lo que se pinta, en los dos temas, y las
//     tres pautas de accesibilidad de Flutter;
//   - la página a 360 dp con la letra a 2.0 sin desbordes ni textos cortados,
//     con la silueta desplazable y su barra; la matriz de tamaños y letras;
//   - el censo sin `Colors.*` en la capa de presentación;
//   - la tabla con los mismos números que los gráficos; Esc y Atrás la cierran;
//   - «Otros N puertos» y «Otras N navieras»; tocar una bahía abre el plano.
// Con las fuentes del producto. Buque y números sintéticos; nunca el corpus.
import 'dart:io';

import 'package:baystream/core/design/design.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/presentation/formatters/estadisticas_del_viaje.dart';
import 'package:baystream/features/vessel/presentation/pages/vessel_overview_page.dart';
import 'package:baystream/features/vessel/presentation/providers/vessel_providers.dart';
import 'package:baystream/features/vessel/presentation/widgets/bay_plan_view.dart';
import 'package:baystream/features/vessel/presentation/widgets/navegacion_del_viaje.dart';
import 'package:baystream/features/vessel/presentation/widgets/voyage_stats_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/t117_oficina_support.dart';
import 'support/t121_estadisticas_support.dart';

final _sintetico = t121Sintetico977();
final _datos977 = EstadisticasDelViaje.de(_sintetico);

final _protagonista =
    find.byKey(const ValueKey<String>('estadisticas-protagonista'));
final _verTabla = find.byKey(const ValueKey<String>('estadisticas-ver-tabla'));
final _tabla = find.byKey(const ValueKey<String>('estadisticas-tabla'));
final _buque = find.byKey(const ValueKey<String>('estadisticas-buque'));
final _magnitud = find.byKey(const ValueKey<String>('estadisticas-magnitud'));

const _paneles = <String>[
  'estadisticas-carga-por-bahia',
  'estadisticas-puertos',
  'estadisticas-llenos',
  'estadisticas-tamano',
  'estadisticas-especial',
  'estadisticas-navieras',
];

/// La semántica encendida durante el cuerpo de la prueba: se suelta al final
/// y, si una aserción la deja viva, en el tearDown (el aviso del handle vivo
/// no tapa entonces el fallo real).
class _Semantica {
  _Semantica(WidgetTester tester) : _handle = tester.ensureSemantics() {
    addTearDown(() {
      if (_viva) _handle.dispose();
    });
  }

  final SemanticsHandle _handle;
  bool _viva = true;

  void soltar() {
    if (!_viva) return;
    _viva = false;
    _handle.dispose();
  }
}

Future<void> _cumpleLasPautas(WidgetTester tester) async {
  await expectLater(tester, meetsGuideline(textContrastGuideline));
  await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
  await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
}

/// Los textos de las barras de un panel, como los dice su etiqueta.
List<String> _etiquetasDeBarras(WidgetTester tester, String panel) => tester
    .widgetList<BsBarraDeMagnitud>(find.descendant(
        of: find.byKey(ValueKey<String>(panel)),
        matching: find.byType(BsBarraDeMagnitud)))
    .map((BsBarraDeMagnitud b) => b.etiqueta)
    .toList();

void main() {
  group('EstadisticasDelViaje: las cifras cuadran', () {
    test('el sintético de 977 en 72 bahías, que son 24 con la regla de la par',
        () {
      final d = _datos977;
      expect(d.total, 977);
      expect(d.llenos + d.vacios + d.sinEstado, d.total);
      expect(d.sinEstado, 0);
      expect(d.vacios, 196);
      expect(d.puertos.fold<int>(0, (s, p) => s + p.cuenta), d.total);
      expect(d.navieras.fold<int>(0, (s, n) => s + n.cuenta), d.total);
      expect(d.de20 + d.de40 + d.de45 + d.otroTamano, d.total);
      expect(d.otroTamano, 0);
      // T-124: cada impar se cuenta con la par que la cubre (15.4).
      expect(d.bahias.length, 24);
      expect(d.bahias.map((b) => b.numero).toList(),
          <int>[for (var b = 2; b <= 94; b += 4) b]);
      expect(d.bahias.fold<int>(0, (s, b) => s + b.contenedores) + d.sinPosicion,
          d.total);
      expect(d.sinPosicion, 0);
      expect(d.bahiasConCarga, 24);
      expect(
          d.bahias.fold<double>(0, (s, b) => s + b.pesoKg) + d.pesoSinPosicionKg,
          closeTo(d.pesoKg, 0.001));
      expect(d.pesoKg, greaterThan(0));
      // Cubierta y bodega: los niveles 82 a 94 arriba, 02 a 14 abajo.
      expect(d.bahias.fold<int>(0, (s, b) => s + b.contenedoresCubierta),
          greaterThan(0));
      expect(d.bahias.fold<int>(0, (s, b) => s + b.contenedoresBodega),
          greaterThan(0));
      expect(d.puertos.length, 9);
      expect(d.navieras.length, 10);
      // De más a menos.
      for (var i = 1; i < d.puertos.length; i++) {
        expect(d.puertos[i - 1].cuenta, greaterThanOrEqualTo(d.puertos[i].cuenta));
      }
      expect(d.puertos.first.codigo, 'GTSTC');
      expect(d.navieras.first.codigo, 'SNA');
      expect(d.peligrosas, 20);
      expect(d.fueraDeMedida, 5);
      expect(d.refrigerados, greaterThan(0));
      expect(d.de45, greaterThan(0), reason: 'los L5G1 de las bahías pares');
      expect(d.de20, greaterThan(0));
      expect(d.de40, greaterThan(0));
    });

    test('«Otros N puertos» y «Otras N navieras»: los que pasan de la vista', () {
      final puertos = EstadisticasDelViaje.conElResto(
          _datos977.puertos, VoyageStatsView.puertosALaVista,
          (int n) => 'Otros ${formatearCuenta(n, 'puerto', 'puertos')}');
      expect(puertos.length, 8);
      expect(puertos.last.codigo, isNull);
      expect(puertos.last.rotulo, 'Otros 2 puertos');
      expect(puertos.last.cuenta,
          _datos977.puertos[7].cuenta + _datos977.puertos[8].cuenta);
      expect(puertos.fold<int>(0, (s, p) => s + p.cuenta), 977);
      final navieras = EstadisticasDelViaje.conElResto(
          _datos977.navieras, VoyageStatsView.navierasALaVista,
          (int n) => 'Otras ${formatearCuenta(n, 'naviera', 'navieras')}');
      expect(navieras.length, 9);
      expect(navieras.last.rotulo, 'Otras 2 navieras');
      // Si sobra uno solo, se muestra él: nunca «Otros 1 puertos».
      final ocho = _datos977.puertos.take(8).toList();
      expect(EstadisticasDelViaje.conElResto(ocho, 7, (int n) => 'Otros $n'),
          same(ocho));
    });

    test('el plano de dos bahías de T-117: cifras exactas', () {
      final d = EstadisticasDelViaje.de(t117SinEscala);
      expect(d.total, 14);
      expect(d.llenos, 13);
      expect(d.vacios, 1);
      expect(d.sinEstado, 0);
      expect(d.pesoKg, 239000);
      // Los seis 42G1 de cubierta, el 42G1 y el 45G1 de la 006 (un 40 alto:
      // el largo lo dice la primera letra del tipo ISO) son 40 pies.
      expect(d.de20, 6);
      expect(d.de40, 8);
      expect(d.de45, 0);
      expect(d.puertos.map((p) => '${p.rotulo} ${p.cuenta}').toList(),
          <String>['GTSTC 9', 'USHOU 4', 'PAMIT 1']);
      expect(d.bahiasConCarga, 2);
      final bahia2 = d.bahias.singleWhere((b) => b.numero == 2);
      expect(bahia2.contenedores, 12);
      expect(bahia2.contenedoresCubierta, 6);
      expect(bahia2.contenedoresBodega, 6);
      expect(bahia2.pesoCubiertaKg, 92000);
      expect(bahia2.pesoBodegaKg, 110000);
      expect(bahia2.etiqueta,
          'Bahía 02, 12 contenedores, ${formatearToneladas(202000)}, 6 en cubierta y 6 en bodega');
      final bahia6 = d.bahias.singleWhere((b) => b.numero == 6);
      expect(bahia6.contenedores, 2);
      expect(bahia6.pesoKg, 37000);
      // Las vecinas de los de 40 se cuentan con su par (T-124): la 01 y la
      // 03 van en la 02, y la 05 y la 07 en la 06.
      expect(d.bahias.map((b) => b.numero), <int>[2, 6]);
      expect(d.navieras.single.rotulo, EstadisticasDelViaje.sinNaviera);
    });

    test('sin posiciones ni estado, las cifras siguen cuadrando', () {
      const suelto = VesselVoyage(
        id: 'suelto',
        vessel: Vessel(id: 'b', name: 'BUQUE SINTETICO'),
        voyageNumber: 'S1',
        containers: <ContainerUnit>[
          ContainerUnit(id: 'a', containerId: 'SNTU0000010', isoSizeType: '22G1',
              grossWeight: 10000),
          ContainerUnit(id: 'b', containerId: 'SNTU0000021', isoSizeType: 'XXXX',
              status: ContainerStatus.full),
        ],
      );
      final d = EstadisticasDelViaje.de(suelto);
      expect(d.total, 2);
      expect(d.sinEstado, 1);
      expect(d.llenos, 1);
      expect(d.otroTamano, 1);
      expect(d.sinPosicion, 2);
      expect(d.pesoSinPosicionKg, 10000);
      expect(d.bahias, isEmpty);
      expect(d.bahiasConCarga, 0);
      expect(d.puertos.single.rotulo, EstadisticasDelViaje.sinPuerto);
      expect(d.parte(1), 0.5);
    });
  });

  group('los colores, compuestos, en los dos temas (15.3)', () {
    for (final oscuro in <bool>[false, true]) {
      final nombre = oscuro ? 'noche' : 'día';
      final paleta = oscuro ? BsPaleta.oscuro : BsPaleta.claro;
      final tema = oscuro ? BayStreamTema.oscuro() : BayStreamTema.claro();
      final esquema = tema.colorScheme;
      final semanticos = tema.extension<BsColoresSemanticos>()!;
      final fondos = <String, Color>{'hoja': paleta.hoja, 'papel': paleta.papel};

      test('$nombre: la rampa es de un tono, ordenada y el paso extremo llega a 2:1',
          () {
        final rampa = paleta.rampaDeMagnitud;
        expect(rampa.length, 4);
        final luminancias = rampa.map((c) => c.computeLuminance()).toList();
        for (var i = 1; i < rampa.length; i++) {
          // De día de claro a oscuro; de noche se invierte.
          expect(oscuro ? luminancias[i] > luminancias[i - 1]
                        : luminancias[i] < luminancias[i - 1], isTrue,
              reason: 'paso $i');
          expect(BsRol.contrasteEntre(rampa[i], rampa[i - 1]),
              greaterThanOrEqualTo(1.4),
              reason: 'los pasos se distinguen');
        }
        for (final fondo in fondos.entries) {
          // El paso de menos (el extremo cercano al fondo) a 2:1 o más.
          expect(BsRol.contrasteEntre(rampa.first, fondo.value),
              greaterThanOrEqualTo(2.0),
              reason: 'el paso 1 sobre ${fondo.key}');
          // Los pasos que pintan barras (2, 3 y 4) a 3:1 o más.
          for (var i = 1; i < rampa.length; i++) {
            expect(BsRol.contrasteEntre(rampa[i], fondo.value),
                greaterThanOrEqualTo(3.0),
                reason: 'el paso ${i + 1} sobre ${fondo.key}');
          }
        }
        // La marca de este modo es un paso de la rampa.
        expect(rampa, contains(esquema.primary));
        // La barra sobre su pista, a 3:1 o más.
        expect(BsRol.contrasteEntre(esquema.primary, paleta.pistaDeMagnitud),
            greaterThanOrEqualTo(3.0));
      });

      test('$nombre: las pilas, el texto y las cajas de los puertos fijos', () {
        // La pila de cubierta sobre la hoja del panel; la de bodega sobre el
        // casco (la hoja alta) y sobre la hoja.
        expect(
            BsRol.contrasteEntre(
                semanticos.porBajarCubierta.relleno, paleta.hoja),
            greaterThanOrEqualTo(3.0));
        expect(
            BsRol.contrasteEntre(
                semanticos.porBajarBodega.relleno, esquema.surfaceContainerHigh),
            greaterThanOrEqualTo(3.0));
        expect(
            BsRol.contrasteEntre(semanticos.porBajarBodega.relleno, paleta.hoja),
            greaterThanOrEqualTo(3.0));
        // La tapa y el contorno del casco.
        expect(BsRol.contrasteEntre(esquema.outline, paleta.hoja),
            greaterThanOrEqualTo(3.0));
        // El texto: tinta, tinta suave y tinta tenue sobre la hoja y el papel.
        for (final fondo in fondos.values) {
          for (final tinta in <Color>[
            paleta.tinta,
            paleta.tintaSuave,
            paleta.tintaTenue,
          ]) {
            expect(BsRol.contrasteEntre(tinta, fondo), greaterThanOrEqualTo(4.5));
          }
        }
        // Las cajas de los quince puertos fijos: el código sobre el relleno a
        // 4.5:1 y el contorno sobre la hoja a 3:1.
        for (final puerto in tablaFijaDePuertos.keys) {
          final rol = semanticos.categorico(puerto);
          expect(BsRol.contrasteEntre(rol.texto, rol.relleno),
              greaterThanOrEqualTo(4.5),
              reason: 'el código de $puerto');
          expect(BsRol.contrasteEntre(rol.contorno, paleta.hoja),
              greaterThanOrEqualTo(3.0),
              reason: 'el contorno de $puerto');
        }
        // Las tarjetas de rol: el texto sobre el relleno a 4.5:1, el icono y
        // el contorno a 3:1.
        for (final rol in <BsRol>[
          semanticos.peligrosa,
          semanticos.refrigerado,
          semanticos.oog,
        ]) {
          expect(BsRol.contrasteEntre(rol.texto, rol.relleno),
              greaterThanOrEqualTo(4.5));
          expect(BsRol.contrasteEntre(rol.contorno, rol.relleno),
              greaterThanOrEqualTo(3.0));
        }
        // El naranja no aparece en nada de lo que pinta Estadísticas.
        final usados = <Color>{
          ...paleta.rampaDeMagnitud,
          paleta.pistaDeMagnitud,
          esquema.primary,
          semanticos.porBajarCubierta.relleno,
          semanticos.porBajarBodega.relleno,
        };
        expect(usados, isNot(contains(paleta.grua)));
        expect(usados, isNot(contains(paleta.gruaRelleno)));
      });
    }
  });

  group('la página en la oficina, a 1920 × 1000, en los dos temas', () {
    for (final oscuro in <bool>[false, true]) {
      testWidgets('${oscuro ? 'noche' : 'día'}: la protagonista, los paneles, '
          'la silueta de 72 bahías y las pautas', (tester) async {
        final semantics = _Semantica(tester);
        await t121Pump(tester, voyage: _sintetico, oscuro: oscuro);
        expect(tester.takeException(), isNull);
        expect(_protagonista, findsOneWidget);
        expect(tester.widget<Text>(_protagonista).data, '977');
        expect(tester.widget<Text>(_protagonista).style?.fontSize,
            BsEscala.cifraProtagonista);
        // Una sola vez por vista.
        expect(
            find.byWidgetPredicate((w) =>
                w is Text && w.style?.fontSize == BsEscala.cifraProtagonista),
            findsOneWidget);
        expect(find.text('contenedores a bordo'), findsOneWidget);
        expect(find.text(formatearToneladas(_datos977.pesoKg)), findsOneWidget);
        for (final panel in _paneles) {
          expect(find.byKey(ValueKey<String>(panel)), findsOneWidget,
              reason: panel);
        }
        expect(find.text('Otros 2 puertos'), findsOneWidget);
        expect(find.text('Otras 2 navieras'), findsOneWidget);
        expect(find.text('Sin carga especial'), findsNothing);
        expect(find.text('Peligrosa IMDG'), findsOneWidget);
        expect(find.text('Refrigerado'), findsOneWidget);
        expect(find.text('Fuera de medida'), findsOneWidget);
        // Las cajas de los siete puertos a la vista, con su rol.
        final cajas = tester.widgetList<BsCajaDeCodigo>(find.byType(BsCajaDeCodigo));
        expect(cajas.map((c) => c.codigo).toList(),
            _datos977.puertos.take(7).map((p) => p.codigo).toList());
        // La silueta mide las 24 bahías de referencia de las 72 (T-124) y,
        // con el panel lateral a 1920 × 1000, todavía se desplaza.
        final buque = tester.widget<BsBuqueEnCorte>(_buque);
        expect(buque.bahias.length, 24);
        expect(t121Buque(tester).position.maxScrollExtent, greaterThan(0));
        t121BarraVisible(tester);
        // El texto nunca lleva el color del dato: todo texto con color propio
        // va en una tinta o en el texto de su rol (la caja, la tarjeta).
        final paleta = oscuro ? BsPaleta.oscuro : BsPaleta.claro;
        final semanticos = oscuro
            ? BsColoresSemanticos.oscuro()
            : BsColoresSemanticos.claro();
        final permitidos = <Color>{
          paleta.tinta,
          paleta.tintaSuave,
          paleta.tintaTenue,
          semanticos.peligrosa.texto,
          semanticos.refrigerado.texto,
          semanticos.oog.texto,
          for (final rol in semanticos.categoricos) rol.texto,
        };
        for (final texto in tester.widgetList<Text>(find.descendant(
            of: find.byType(VoyageStatsView), matching: find.byType(Text)))) {
          final color = texto.style?.color;
          if (color != null) {
            expect(permitidos, contains(color),
                reason: '«${texto.data}» lleva ${color.toARGB32().toRadixString(16)}');
          }
        }
        // El contenido no pasa de 1 440 y queda centrado.
        final contenido = tester.getRect(find.byKey(const ValueKey<String>('estadisticas')));
        expect(contenido.width, lessThanOrEqualTo(1440));
        expect(contenido.left, greaterThan(0));
        t121NadaSeCorta(tester, find.byType(VoyageStatsView));
        await _cumpleLasPautas(tester);
        await t121RecorrerLaPagina(tester);
        semantics.soltar();
      });
    }

    testWidgets('«Contenedores / Peso» cambia lo que dice la pila', (tester) async {
      await t121Pump(tester, voyage: _sintetico);
      expect(tester.widget<BsBuqueEnCorte>(_buque).magnitud,
          BsMagnitudDeLaPila.contenedores);
      await tester.tap(find.descendant(of: _magnitud, matching: find.text('Peso')));
      await tester.pumpAndSettle();
      expect(tester.widget<BsBuqueEnCorte>(_buque).magnitud,
          BsMagnitudDeLaPila.peso);
      expect(tester.takeException(), isNull);
      // El pie sigue diciendo la cuenta y el peso, con cualquier magnitud.
      final bahia = _datos977.bahias.first;
      final columna = find.byKey(ValueKey<String>('buque-en-corte-bahia-${bahia.numero}'));
      expect(find.descendant(of: columna, matching: find.text('${bahia.contenedores}')),
          findsOneWidget);
      expect(
          find.descendant(
              of: columna, matching: find.text(formatearToneladas(bahia.pesoKg))),
          findsOneWidget);
    });

    testWidgets('tocar una bahía la abre; la última se alcanza entera', (tester) async {
      final tocadas = <int>[];
      await t121Pump(tester, voyage: _sintetico, onBahia: tocadas.add);
      await tester.tap(find.byKey(const ValueKey<String>('buque-en-corte-bahia-2')));
      expect(tocadas, <int>[2]);
      // La popa es la 94: la 95 se cuenta con ella (T-124).
      final ultima = find.byKey(const ValueKey<String>('buque-en-corte-bahia-94'));
      await tester.ensureVisible(ultima);
      await tester.pumpAndSettle();
      final buque = tester.getRect(_buque);
      final rect = tester.getRect(ultima);
      expect(rect.right, lessThanOrEqualTo(buque.right + 0.5),
          reason: 'la popa entera a la vista');
      expect(rect.width, greaterThanOrEqualTo(BsBuqueEnCorte.anchoBahia(TextScaler.noScaling)));
      await tester.tap(ultima);
      expect(tocadas, <int>[2, 94]);
      expect(tester.takeException(), isNull);
    });
  });

  group('«Ver como tabla» (15.6)', () {
    testWidgets('las mismas cifras en tablas; Esc y Atrás vuelven a los gráficos',
        (tester) async {
      final scope = await t121Pump(tester, voyage: _sintetico);
      final barrasDePuertos = _etiquetasDeBarras(tester, 'estadisticas-puertos');
      expect(barrasDePuertos.length, 8);
      expect(barrasDePuertos.first,
          'GTSTC: ${formatearCuenta(_datos977.puertos.first.cuenta, 'contenedor', 'contenedores')}, '
          '${formatearPorcentaje(_datos977.parte(_datos977.puertos.first.cuenta))}');
      final tamanos = _etiquetasDeBarras(tester, 'estadisticas-tamano');
      expect(tamanos, <String>[
        '20 pies: ${formatearCuenta(_datos977.de20, 'contenedor', 'contenedores')}, ${formatearPorcentaje(_datos977.parte(_datos977.de20))}',
        '40 pies: ${formatearCuenta(_datos977.de40, 'contenedor', 'contenedores')}, ${formatearPorcentaje(_datos977.parte(_datos977.de40))}',
        '45 pies: ${formatearCuenta(_datos977.de45, 'contenedor', 'contenedores')}, ${formatearPorcentaje(_datos977.parte(_datos977.de45))}',
      ]);
      expect(find.byType(BsBarraDeMagnitud), findsWidgets);
      expect(_tabla, findsNothing);
      expect(scope.read(cerrablesDeAtrasProvider), 0);

      await tester.tap(_verTabla);
      await tester.pumpAndSettle();
      expect(_tabla, findsOneWidget);
      expect(find.byType(BsBarraDeMagnitud), findsNothing);
      expect(find.text('Ver como gráficos'), findsOneWidget);
      expect(scope.read(cerrablesDeAtrasProvider), 1);
      // La cabecera se queda.
      expect(_protagonista, findsOneWidget);
      // Todos los puertos y todas las navieras, con la misma cuenta y parte
      // que los gráficos; por bahía, las 72 con sus zonas.
      final textos = tester
          .widgetList<Text>(find.descendant(of: _tabla, matching: find.byType(Text)))
          .map((t) => t.data)
          .whereType<String>()
          .toList();
      for (final puerto in _datos977.puertos) {
        expect(textos, contains(puerto.rotulo));
        expect(textos, contains('${puerto.cuenta}'));
        expect(textos, contains(formatearPorcentaje(_datos977.parte(puerto.cuenta))));
      }
      for (final naviera in _datos977.navieras) {
        expect(textos, contains(naviera.rotulo));
      }
      expect(textos, isNot(contains('Otros 2 puertos')));
      expect(textos, isNot(contains('Otras 2 navieras')));
      expect(textos, contains('Contenedores a bordo'));
      expect(textos, contains('977'));
      expect(textos, contains(formatearToneladas(_datos977.pesoKg)));
      expect(textos.where((t) => t == '20 pies'), hasLength(1));
      expect(textos, contains('${_datos977.de20}'));
      expect(textos, contains('${_datos977.peligrosas}'));
      for (final bahia in _datos977.bahias) {
        expect(textos, contains(bahia.rotulo));
        expect(textos, contains(formatearToneladas(bahia.pesoKg)));
      }
      // Las cabeceras son encabezados para el lector de pantalla.
      final semantics = _Semantica(tester);
      final cabecera = tester.getSemantics(
          find.descendant(of: _tabla, matching: find.text('Puerto')));
      expect(cabecera.flagsCollection.isHeader, isTrue);
      t121NadaSeCorta(tester, find.byType(VoyageStatsView));
      await t121RecorrerLaPagina(tester);

      // Esc vuelve a los gráficos.
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(_tabla, findsNothing);
      expect(scope.read(cerrablesDeAtrasProvider), 0);
      expect(find.text('Ver como tabla'), findsOneWidget);

      // Abierta con el teclado (Tab hasta el botón, Intro) Esc también la
      // cierra: el botón conserva el foco y el autofocus se habría descartado;
      // la tabla pide el foco a propósito.
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      final conFoco = tester.binding.focusManager.primaryFocus?.context;
      expect(conFoco, isNotNull);
      expect(
          find.descendant(of: _verTabla, matching: find.byWidget(conFoco!.widget)),
          findsOneWidget,
          reason: 'el primer Tab enfoca «Ver como tabla»');
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(_tabla, findsOneWidget, reason: 'Intro abre la tabla');
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(_tabla, findsNothing, reason: 'Esc con el foco venido del botón');
      expect(scope.read(cerrablesDeAtrasProvider), 0);
      semantics.soltar();

      // Atrás (lo que cierra el registro) también.
      await tester.tap(_verTabla);
      await tester.pumpAndSettle();
      expect(scope.read(cerrablesDeAtrasProvider), 1);
      expect(scope.read(cerrablesDeAtrasProvider.notifier).cerrarUltimo(), isTrue);
      await tester.pumpAndSettle();
      expect(_tabla, findsNothing);
      expect(scope.read(cerrablesDeAtrasProvider), 0);
      expect(tester.takeException(), isNull);
    });

    testWidgets('con la página desmontada abierta, el registro queda limpio',
        (tester) async {
      final scope = await t121Pump(tester, voyage: _sintetico);
      await tester.tap(_verTabla);
      await tester.pumpAndSettle();
      expect(scope.read(cerrablesDeAtrasProvider), 1);
      await tester.pumpWidget(const SizedBox());
      await tester.pump();
      expect(scope.read(cerrablesDeAtrasProvider), 0);
    });
  });

  group('con cualquier tamaño de ventana (15.7)', () {
    for (final tamano in const <Size>[Size(360, 800), Size(360, 640), Size(600, 960)]) {
      for (final letra in <double>[1.0, 1.45, 2.0]) {
        for (final oscuro in <bool>[false, true]) {
          testWidgets(
              'el muelle a ${tamano.width.toInt()} × ${tamano.height.toInt()}, '
              'letra $letra, ${oscuro ? 'noche' : 'día'}: todo apila y nada se corta',
              (tester) async {
            await t121Pump(tester,
                voyage: _sintetico,
                tamano: tamano,
                letra: letra,
                oscuro: oscuro,
                muelle: true);
            expect(tester.takeException(), isNull);
            expect(_protagonista.hitTestable(), findsOneWidget);
            t121NadaSeCorta(tester, find.byType(VoyageStatsView));
            // El selector, con rótulos o solo con iconos, pero entero.
            expect(find.byType(SegmentedButton<BsMagnitudDeLaPila>), findsOneWidget);
            // La silueta se desplaza a lo ancho, con su barra.
            expect(t121Buque(tester).position.maxScrollExtent, greaterThan(0));
            t121BarraVisible(tester);
            // Cada bahía mide 56 por la escala de la letra, o lo que pida su pie.
            final columna = tester.getSize(
                find.byKey(const ValueKey<String>('buque-en-corte-bahia-2')));
            expect(columna.width, greaterThanOrEqualTo(56 * letra - 0.01));
            if (tamano.width < 600) {
              // Con la letra a 2.0, «Ver como tabla» envuelve debajo de la
              // protagonista.
              if (letra == 2.0) {
                expect(tester.getRect(_verTabla).top,
                    greaterThanOrEqualTo(tester.getRect(_protagonista).bottom - 1));
              }
              // Los paneles, uno debajo de otro, a todo el ancho.
              final puertos = tester.getRect(find.byKey(const ValueKey<String>('estadisticas-puertos')));
              final llenos = tester.getRect(find.byKey(const ValueKey<String>('estadisticas-llenos')));
              expect(llenos.top, greaterThanOrEqualTo(puertos.bottom));
              expect(puertos.width, closeTo(tamano.width - 32, 0.5));
            }
            await t121RecorrerLaPagina(tester, paso: 300);
            await tester.tap(_verTabla);
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
            t121NadaSeCorta(tester, find.byType(VoyageStatsView), razon: 'la tabla');
            await t121RecorrerLaPagina(tester, paso: 300);
          });
        }
      }
    }

    testWidgets('a 360 × 800 con la letra a 2.0 las pautas se cumplen', (tester) async {
      final semantics = _Semantica(tester);
      await t121Pump(tester,
          voyage: _sintetico,
          tamano: const Size(360, 800),
          letra: 2.0,
          muelle: true);
      await _cumpleLasPautas(tester);
      semantics.soltar();
    });

    const ventanas = <Size>[
      Size(1920, 1000),
      Size(1707, 996),
      Size(1536, 793),
      Size(1366, 690),
      Size(1280, 720),
      Size(960, 1000),
      Size(800, 600),
      Size(700, 800),
      Size(600, 800),
    ];
    for (final ventana in ventanas) {
      for (final letra in <double>[1.0, 1.45, 2.0]) {
        for (final oscuro in <bool>[false, true]) {
          testWidgets(
              'la oficina a ${ventana.width.toInt()} × ${ventana.height.toInt()}, '
              'letra $letra, ${oscuro ? 'noche' : 'día'}: nada se corta y el panel '
              'lateral no lleva el detalle', (tester) async {
            final scope = await t117Pump(tester,
                tamano: ventana, letra: letra, oscuro: oscuro, voyage: _sintetico);
            scope.read(destinoDelViajeProvider.notifier).ir(DestinoDelViaje.estadisticas);
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
            expect(find.byType(VoyageStatsView), findsOneWidget);
            expect(_protagonista.hitTestable(), findsOneWidget);
            t121NadaSeCorta(tester, find.byType(VoyageStatsView));
            final contenido = tester.getRect(find.byKey(const ValueKey<String>('estadisticas')));
            expect(contenido.width, lessThanOrEqualTo(1440));
            // En Estadísticas la cabecera no lleva el selector de modo y el
            // panel lateral, si está, lleva solo «En vivo» o la frase.
            expect(find.byKey(const ValueKey('bay-plan-display-mode')), findsNothing);
            expect(find.byKey(const ValueKey('franja-de-cifras')), findsNothing);
            await t121RecorrerLaPagina(tester, paso: 300);
          });
        }
      }
    }
  });

  group('los componentes (15.10)', () {
    testWidgets('BsBarraDeMagnitud: en una línea o con la etiqueta encima', (tester) async {
      await t117CargarFuentes();
      Future<void> pump(double ancho) async {
        await tester.pumpWidget(MaterialApp(
          theme: BayStreamTema.claro(),
          home: Scaffold(
            body: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: ancho,
                child: Builder(
                  builder: (context) => BsBarraDeMagnitud(
                    rotulo: 'GTSTC',
                    valor: 520,
                    total: 977,
                    maximo: 520,
                    caja: BsColoresSemanticos.de(context).categorico('GTSTC'),
                  ),
                ),
              ),
            ),
          ),
        ));
        await tester.pumpAndSettle();
      }

      await pump(600);
      final barra = tester.widget<BsBarraDeMagnitud>(find.byType(BsBarraDeMagnitud));
      expect(barra.etiqueta, 'GTSTC: 520 contenedores, ${formatearPorcentaje(520 / 977)}');
      expect(find.text('520'), findsOneWidget);
      expect(find.text(formatearPorcentaje(520 / 977)), findsOneWidget);
      final caja = tester.getRect(find.byType(BsCajaDeCodigo));
      final cifra = tester.getRect(find.text('520'));
      expect((caja.center.dy - cifra.center.dy).abs(), lessThan(8),
          reason: 'en una línea');
      expect(tester.getSize(find.byType(BsBarraDeMagnitud)).height,
          lessThanOrEqualTo(40));
      expect(tester.widget<Tooltip>(find.byType(Tooltip)).message, barra.etiqueta);

      await pump(300);
      final cajaApilada = tester.getRect(find.byType(BsCajaDeCodigo));
      final tamano = tester.getSize(find.byType(BsBarraDeMagnitud));
      expect(cajaApilada.bottom, lessThan(tamano.height),
          reason: 'la etiqueta encima de la barra');
      expect(tester.takeException(), isNull);
    });

    testWidgets('BsTarjetaDeRol y BsPanel: etiqueta, encabezado y colores del rol',
        (tester) async {
      await t117CargarFuentes();
      final semantics = _Semantica(tester);
      await tester.pumpWidget(MaterialApp(
        theme: BayStreamTema.oscuro(),
        home: Scaffold(
          body: Builder(
            builder: (context) => BsPanel(
              titulo: 'Carga especial',
              child: BsTarjetaDeRol(
                rol: BsColoresSemanticos.de(context).peligrosa,
                icono: BsIconos.peligrosa,
                valor: '3',
                rotulo: 'Peligrosa IMDG',
              ),
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();
      expect(tester.getSemantics(find.byType(BsTarjetaDeRol)).label,
          'Peligrosa IMDG: 3');
      expect(
          tester.getSemantics(find.text('Carga especial')).flagsCollection.isHeader,
          isTrue);
      final rol = BsColoresSemanticos.oscuro().peligrosa;
      final decoracion = tester
          .widget<Container>(find.descendant(
              of: find.byType(BsTarjetaDeRol), matching: find.byType(Container)))
          .decoration as BoxDecoration;
      expect(decoracion.color, rol.relleno);
      expect(tester.widget<Icon>(find.byIcon(BsIconos.peligrosa)).color, rol.contorno);
      expect(tester.widget<Text>(find.text('3')).style?.color, rol.texto);
      await _cumpleLasPautas(tester);
      semantics.soltar();
    });

    testWidgets('BsBuqueEnCorte: sin bahías lo dice; con bahías, una columna por bahía',
        (tester) async {
      await t117CargarFuentes();
      await tester.pumpWidget(MaterialApp(
        theme: BayStreamTema.claro(),
        home: Scaffold(
          body: BsBuqueEnCorte(bahias: const <BsBahiaEnCorte>[], onSeleccion: (_) {}),
        ),
      ));
      expect(find.text('El archivo no trae posiciones de estiba.'), findsOneWidget);
      expect(BsBuqueEnCorte.anchoBahia(TextScaler.noScaling), 56);
      expect(BsBuqueEnCorte.anchoBahia(const TextScaler.linear(2.0)), 112);
      expect(BsBuqueEnCorte.anchoBahia(TextScaler.noScaling, anchoDelPie: 60), 68);
      expect(BsBuqueEnCorte.yTapa, 84);
      expect(BsBuqueEnCorte.yFondo, 170);
      final semantics = _Semantica(tester);
      await tester.pumpWidget(MaterialApp(
        theme: BayStreamTema.claro(),
        home: Scaffold(
          body: BsBuqueEnCorte(
            bahias: const <BsBahiaEnCorte>[
              BsBahiaEnCorte(numero: 2, contenedoresCubierta: 6, contenedoresBodega: 6,
                  pesoCubiertaKg: 92000, pesoBodegaKg: 110000),
              BsBahiaEnCorte(numero: 6, contenedoresCubierta: 2, pesoCubiertaKg: 37000),
            ],
            onSeleccion: (_) {},
          ),
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey<String>('buque-en-corte-bahia-2')), findsOneWidget);
      expect(find.byKey(const ValueKey<String>('buque-en-corte-bahia-6')), findsOneWidget);
      expect(find.text('02'), findsOneWidget);
      expect(find.text('12'), findsOneWidget);
      expect(find.text(formatearToneladas(202000)), findsOneWidget);
      final nodo = tester.getSemantics(
          find.byKey(const ValueKey<String>('buque-en-corte-bahia-2')));
      expect(nodo.label,
          'Bahía 02, 12 contenedores, ${formatearToneladas(202000)}, 6 en cubierta y 6 en bodega');
      expect(nodo.hint, 'Abre la bahía en el plano');
      expect(nodo.flagsCollection.isButton, isTrue);
      expect(tester.getSemantics(find.byType(BsBuqueEnCorte)).label,
          contains('El buque en corte, 2 bahías de proa a popa'));
      semantics.soltar();
      expect(tester.takeException(), isNull);
    });
  });

  testWidgets('tocar una bahía en Estadísticas abre su rejilla en el plano',
      (tester) async {
    final scope = await t117Pump(tester,
        tamano: const Size(1200, 800), voyage: t117SinEscala);
    // En la oficina el destino es el riel, por su rótulo.
    await tester.tap(find.descendant(
        of: find.byKey(const ValueKey('riel-del-viaje')),
        matching: find.text('Estadísticas')));
    await tester.pumpAndSettle();
    expect(find.byType(VoyageStatsView), findsOneWidget);
    final bahia6 = find.byKey(const ValueKey<String>('buque-en-corte-bahia-6'));
    await tester.ensureVisible(bahia6);
    await tester.pumpAndSettle();
    await tester.tap(bahia6);
    await tester.pumpAndSettle();
    expect(scope.read(selectedBayProvider), 6);
    expect(scope.read(destinoDelViajeProvider), DestinoDelViaje.plano);
    expect(find.byType(BayPlanView), findsOneWidget);
    expect(find.byType(VesselOverviewPage), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test('el censo: ningún Colors.* en la capa de presentación', () {
    final presentacion = Directory('lib/features/vessel/presentation');
    expect(presentacion.existsSync(), isTrue);
    final hallazgos = <String>[];
    final patron = RegExp(r'\bColors\.');
    for (final archivo in presentacion
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))) {
      final lineas = archivo.readAsLinesSync();
      for (var i = 0; i < lineas.length; i++) {
        // Los comentarios no pintan: solo cuenta el código.
        if (lineas[i].trimLeft().startsWith('//')) continue;
        if (patron.hasMatch(lineas[i])) {
          hallazgos.add('${archivo.path.replaceAll(r'\', '/')}:${i + 1}: ${lineas[i].trim()}');
        }
      }
    }
    expect(hallazgos, isEmpty,
        reason: 'Colors.* en la presentación (DESIGN.md 15.3):\n${hallazgos.join('\n')}');
    // Y la vista vieja ya no está.
    expect(
        File('lib/features/vessel/presentation/widgets/vessel_profile_view.dart')
            .existsSync(),
        isFalse);
  });
}
