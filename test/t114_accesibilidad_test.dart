// T-114 · Fase 2 del rediseño: las pautas de accesibilidad de Flutter sobre
// cada componente, en claro y en oscuro: contraste del texto (4.5:1),
// objetivos táctiles de 48 × 48 (Android) y etiqueta en todo lo que se toca.
import 'package:baystream/core/design/design.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _envuelve(Widget hijo, {required bool oscuro, bool muelle = true}) =>
    MaterialApp(
      theme: BayStreamTema.claro(muelle: muelle),
      darkTheme: BayStreamTema.oscuro(muelle: muelle),
      themeMode: oscuro ? ThemeMode.dark : ThemeMode.light,
      home: Scaffold(
        body: Padding(padding: const EdgeInsets.all(16), child: hijo),
      ),
    );

Future<void> _cumpleLasPautas(WidgetTester tester) async {
  await expectLater(tester, meetsGuideline(textContrastGuideline));
  await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
  await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
}

void main() {
  final componentes = <String, Widget Function(BuildContext context)>{
    'celdas con categoría, marcas e insignias': (context) {
      final semanticos = BsColoresSemanticos.de(context);
      return Wrap(
        children: [
          BsCelda(
            codigo: 'GTSTC',
            linea2: '28.7',
            categoria: semanticos.categorico('GTSTC'),
            etiqueta: 'MSCU 123456 7, 002-01-82, GTSTC, 28.7 t',
            onTap: () {},
          ),
          BsCelda(
            codigo: 'USHOU',
            insignia: BsInsigniaDeCelda.peligrosa,
            categoria: semanticos.categorico('USHOU'),
            etiqueta: 'MSCU 123456 8, peligrosa',
            onTap: () {},
          ),
          BsCelda(
            codigo: 'GTSTC',
            marca: BsMarcaDeCelda.baja,
            categoria: semanticos.categorico('GTSTC'),
            etiqueta: 'MSCU 123457 0, baja',
            onTap: () {},
          ),
          BsCelda(
            codigo: 'GTSTC',
            marca: BsMarcaDeCelda.hecho,
            categoria: semanticos.categorico('GTSTC'),
            etiqueta: 'MSCU 123457 1, hecho',
            onTap: () {},
          ),
          BsCelda(
            codigo: 'GTSTC',
            marca: BsMarcaDeCelda.cancelado,
            categoria: semanticos.categorico('GTSTC'),
            etiqueta: 'MSCU 123457 2, cancelado',
            onTap: () {},
          ),
          BsCelda(
            codigo: 'GTSTC',
            marca: BsMarcaDeCelda.revisar,
            categoria: semanticos.categorico('GTSTC'),
            etiqueta: 'MSCU 123457 3, revisar',
            onTap: () {},
          ),
          BsCelda(
            codigo: 'USHOU',
            marca: BsMarcaDeCelda.paso,
            categoria: semanticos.categorico('USHOU'),
            etiqueta: 'MSCU 123457 4, de paso',
          ),
          const BsCelda(
            codigo: '45G1',
            reservada: true,
            etiqueta: 'Reserva 002-06-84, 45G1',
            resaltada: true,
          ),
          const BsCelda(codigo: '', etiqueta: 'Hueco 002-07-84'),
          BsCelda(
            codigo: 'GTSTC',
            atenuada: true,
            categoria: semanticos.categorico('GTSTC'),
            etiqueta: 'MSCU 123457 5, fuera del filtro',
            onTap: () {},
          ),
          BsCelda(
            codigo: 'USHOU',
            atenuada: true,
            insignia: BsInsigniaDeCelda.refrigerado,
            marca: BsMarcaDeCelda.hecho,
            categoria: semanticos.categorico('USHOU'),
            etiqueta: 'MSCU 123457 6, hecho, refrigerado, fuera del filtro',
            onTap: () {},
          ),
        ],
      );
    },
    'las 24 ranuras categóricas en celdas': (context) {
      final semanticos = BsColoresSemanticos.de(context);
      return Wrap(
        children: [
          for (var k = 0; k < ranurasCategoricas; k++)
            BsCelda(
              codigo: 'R$k',
              linea2: '28.7',
              categoria: semanticos.categoricos[k],
              etiqueta: 'ranura $k',
              onTap: () {},
            ),
        ],
      );
    },
    'tira de bahías': (context) => BsTiraDeBahias(
          bahias: const [
            BsBahiaDeTira(numero: 1, ocupacion: 0.2),
            BsBahiaDeTira(numero: 2, ocupacion: 0.9),
            BsBahiaDeTira(numero: 3, ocupacion: 1),
            BsBahiaDeTira(numero: 5),
          ],
          seleccionada: 2,
          onSeleccion: (_) {},
        ),
    'cartela': (context) {
      final semanticos = BsColoresSemanticos.de(context);
      return BsCartela(
        titulo: 'Bahía 02',
        cifras: const [
          BsCifraDeCartela(rotulo: 'Contenedores', valor: '63'),
          BsCifraDeCartela(rotulo: 'Peso', valor: '416.8 t'),
        ],
        leyenda: [
          BsEntradaDeLeyenda(
              rotulo: 'GTSTC',
              cuenta: 120,
              rol: semanticos.categorico('GTSTC'),
              activa: true,
              onTap: () {}),
          BsEntradaDeLeyenda(
              rotulo: 'USHOU',
              cuenta: 55,
              rol: semanticos.categorico('USHOU'),
              onTap: () {}),
          const BsEntradaDeLeyenda(
              rotulo: 'Refrigerado', cuenta: 12, icono: Icons.ac_unit),
        ],
        nota: 'Peso por pila: sin evaluar hasta confirmar el perfil.',
      );
    },
    'bandas': (context) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BsBanda(
              texto: 'Plano sin confirmar. Escala propuesta GTSTC.',
              accion: 'Confirmar',
              onAccion: () {},
            ),
            const SizedBox(height: 8),
            const BsBanda(
              texto: 'Peso por pila y tomas: sin evaluar hasta confirmar el perfil.',
              tono: BsTonoDeBanda.aviso,
            ),
            const SizedBox(height: 8),
            BsBanda(
              texto: 'No se registró la descarga. Inténtalo de nuevo.',
              tono: BsTonoDeBanda.error,
              onCerrar: () {},
            ),
            const SizedBox(height: 8),
            const BsBanda(
              texto: 'Perfil guardado.',
              tono: BsTonoDeBanda.confirmacion,
            ),
          ],
        ),
    'cifra': (context) => const BsCifra(
          valor: '120 de 150',
          rotulo: 'Descargados',
          progreso: 0.8,
          detalle: '80 %',
        ),
    'hoja de detalle': (context) => const BsHojaDeDetalle(
          titulo: BsNumeroDeContenedor('MSCU1234567'),
          subtitulo: 'Lleno',
          filas: [
            BsFilaDeDetalle('Posición', 'Bahía 002, Fila 01, Nivel 82'),
            BsFilaDeDetalle('VGM', '28 650 kg'),
          ],
        ),
    'barra de operación': (context) => BsBarraDeOperacion(
          contadores: const [
            BsContador(valor: '18', rotulo: 'por bajar'),
            BsContador(valor: '6', rotulo: 'hechas'),
            BsContador(valor: '3', rotulo: 're‑estibas'),
          ],
          aviso: BsAvisoDeOperacion(
            texto: 'Descarga registrada, MSCU 123456 7',
            accion: 'Deshacer',
            onAccion: () {},
          ),
          accion: OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.table_chart_outlined),
            label: const Text('Pendientes por bahía'),
          ),
        ),
  };

  for (final componente in componentes.entries) {
    for (final oscuro in [false, true]) {
      final modo = oscuro ? 'oscuro' : 'claro';
      testWidgets('${componente.key}: contraste, objetivos y etiquetas en $modo',
          (tester) async {
        final semantica = tester.ensureSemantics();
        await tester.pumpWidget(_envuelve(
          Builder(builder: componente.value),
          oscuro: oscuro,
        ));
        await _cumpleLasPautas(tester);
        semantica.dispose();
      });
    }
  }

  testWidgets('la celda de la oficina también cumple los objetivos táctiles',
      (tester) async {
    final semantica = tester.ensureSemantics();
    await tester.pumpWidget(_envuelve(
      Builder(
        builder: (context) => BsCelda(
          codigo: 'GTSTC',
          linea2: '28.7',
          categoria: BsColoresSemanticos.de(context).categorico('GTSTC'),
          etiqueta: 'MSCU 123456 7, 002-01-82, GTSTC, 28.7 t',
          onTap: () {},
        ),
      ),
      oscuro: false,
      muelle: false,
    ));
    await _cumpleLasPautas(tester);
    semantica.dispose();
  });
}
