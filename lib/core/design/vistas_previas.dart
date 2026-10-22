import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import 'bs_colores_semanticos.dart';
import 'bs_tema.dart';
import 'componentes/bs_banda.dart';
import 'componentes/bs_barra_de_operacion.dart';
import 'componentes/bs_cartela.dart';
import 'componentes/bs_celda.dart';
import 'componentes/bs_cifra.dart';
import 'componentes/bs_hoja_de_detalle.dart';
import 'componentes/bs_numero_de_contenedor.dart';
import 'componentes/bs_tira_de_bahias.dart';

/// Los temas que usa el previsualizador de widgets (`flutter widget-preview
/// start`): el claro y el oscuro de la dirección A, con la densidad del muelle.
PreviewThemeData bsTemaDeVistaPrevia() => PreviewThemeData(
      materialLight: BayStreamTema.claro(muelle: true),
      materialDark: BayStreamTema.oscuro(muelle: true),
    );

/// Un lienzo con el papel del tema y relleno alrededor.
Widget _lienzo(Widget hijo) => Builder(
      builder: (BuildContext context) => Material(
        color: Theme.of(context).colorScheme.surface,
        child: Padding(padding: const EdgeInsets.all(16), child: hijo),
      ),
    );

/// Las celdas del plano en la vista por destino, con insignias y marcas.
@Preview(name: 'Celdas · claro', group: 'Diseño', theme: bsTemaDeVistaPrevia)
Widget vistaPreviaCeldas() => _lienzo(Builder(
      builder: (BuildContext context) {
        final semanticos = BsColoresSemanticos.de(context);
        return Wrap(
          children: <Widget>[
            BsCelda(
              codigo: 'GTSTC',
              linea2: '28.7',
              categoria: semanticos.categorico('GTSTC'),
              etiqueta: 'MSCU 123456 7, 002-01-82, GTSTC, 28.7 t',
              onTap: () {},
            ),
            BsCelda(
              codigo: 'USHOU',
              linea2: '24.2',
              insignia: BsInsigniaDeCelda.peligrosa,
              categoria: semanticos.categorico('USHOU'),
              etiqueta: 'MSCU 123456 8, 002-03-82, USHOU, peligrosa',
              onTap: () {},
            ),
            BsCelda(
              codigo: 'PAMIT',
              insignia: BsInsigniaDeCelda.refrigerado,
              categoria: semanticos.categorico('PAMIT'),
              etiqueta: 'MSCU 123456 9, 002-05-82, PAMIT, refrigerado',
              onTap: () {},
            ),
            BsCelda(
              codigo: 'GTSTC',
              marca: BsMarcaDeCelda.baja,
              categoria: semanticos.categorico('GTSTC'),
              etiqueta: 'MSCU 123457 0, 002-01-84, baja',
              onTap: () {},
            ),
            BsCelda(
              codigo: 'GTSTC',
              marca: BsMarcaDeCelda.hecho,
              categoria: semanticos.categorico('GTSTC'),
              etiqueta: 'MSCU 123457 1, 002-02-84, hecho',
              onTap: () {},
            ),
            BsCelda(
              codigo: 'USHOU',
              marca: BsMarcaDeCelda.paso,
              categoria: semanticos.categorico('USHOU'),
              etiqueta: 'MSCU 123457 2, 002-04-84, de paso',
            ),
            const BsCelda(
              codigo: '45G1',
              reservada: true,
              etiqueta: 'Reserva 002-06-84, 45G1',
            ),
            const BsCelda(codigo: '', etiqueta: 'Hueco 002-07-84'),
            BsCelda(
              codigo: 'GTSTC',
              atenuada: true,
              categoria: semanticos.categorico('GTSTC'),
              etiqueta: 'MSCU 123457 3, fuera del filtro',
            ),
            BsCelda(
              codigo: 'GTSTC',
              resaltada: true,
              categoria: semanticos.categorico('GTSTC'),
              etiqueta: 'MSCU 123457 4, resaltada por la búsqueda',
            ),
          ],
        );
      },
    ));

/// Las mismas celdas en el modo oscuro.
@Preview(
  name: 'Celdas · oscuro',
  group: 'Diseño',
  theme: bsTemaDeVistaPrevia,
  brightness: Brightness.dark,
)
Widget vistaPreviaCeldasOscuro() => vistaPreviaCeldas();

/// La silueta del buque como selector de bahías.
@Preview(name: 'Tira de bahías', group: 'Diseño', theme: bsTemaDeVistaPrevia)
Widget vistaPreviaTiraDeBahias() => _lienzo(BsTiraDeBahias(
      bahias: <BsBahiaDeTira>[
        for (var i = 1; i <= 27; i += 2)
          BsBahiaDeTira(numero: i, ocupacion: ((i * 7) % 10) / 10),
      ],
      seleccionada: 7,
      onSeleccion: (int bahia) {},
    ));

/// La cartela con cifras y leyenda por destino.
@Preview(name: 'Cartela', group: 'Diseño', theme: bsTemaDeVistaPrevia)
Widget vistaPreviaCartela() => _lienzo(Builder(
      builder: (BuildContext context) {
        final semanticos = BsColoresSemanticos.de(context);
        return BsCartela(
          titulo: 'Bahía 02',
          cifras: const <BsCifraDeCartela>[
            BsCifraDeCartela(rotulo: 'Contenedores', valor: '63'),
            BsCifraDeCartela(rotulo: 'Peso', valor: '416.8 t'),
          ],
          leyenda: <BsEntradaDeLeyenda>[
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
            BsEntradaDeLeyenda(
                rotulo: 'PAMIT',
                cuenta: 30,
                rol: semanticos.categorico('PAMIT'),
                onTap: () {}),
            const BsEntradaDeLeyenda(
                rotulo: 'Refrigerado', cuenta: 12, icono: Icons.ac_unit),
            const BsEntradaDeLeyenda(
                rotulo: 'IMO', cuenta: 3, icono: Icons.warning_amber_rounded),
          ],
          nota: 'Peso por pila: sin evaluar hasta confirmar el perfil.',
        );
      },
    ));

/// Las bandas de los cuatro tonos.
@Preview(name: 'Bandas', group: 'Diseño', theme: bsTemaDeVistaPrevia)
Widget vistaPreviaBandas() => _lienzo(Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
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
          texto: 'No se registró la descarga: la operación cambió mientras '
              'tanto. Inténtalo de nuevo.',
          tono: BsTonoDeBanda.error,
          onCerrar: () {},
        ),
        const SizedBox(height: 8),
        const BsBanda(
          texto: 'Perfil guardado.',
          tono: BsTonoDeBanda.confirmacion,
        ),
      ],
    ));

/// Una cifra con progreso.
@Preview(name: 'Cifra', group: 'Diseño', theme: bsTemaDeVistaPrevia)
Widget vistaPreviaCifra() => _lienzo(const BsCifra(
      valor: '120 de 150',
      rotulo: 'Descargados',
      progreso: 0.8,
      detalle: '80 %',
    ));

/// La hoja de detalle de un contenedor.
@Preview(
  name: 'Hoja de detalle',
  group: 'Diseño',
  theme: bsTemaDeVistaPrevia,
  size: Size(360, 640),
)
Widget vistaPreviaHojaDeDetalle() => _lienzo(const BsHojaDeDetalle(
      titulo: BsNumeroDeContenedor('MSCU1234567'),
      subtitulo: 'Línea MSC, lleno',
      filas: <BsFilaDeDetalle>[
        BsFilaDeDetalle('Posición', 'Bahía 002, Fila 01, Nivel 82'),
        BsFilaDeDetalle('Tipo ISO', '45G1, 40 pies'),
        BsFilaDeDetalle('Peso', '28.7 t'),
        BsFilaDeDetalle('VGM', '28 650 kg'),
        BsFilaDeDetalle('Puerto de carga', 'PAMIT'),
        BsFilaDeDetalle('Puerto de descarga', 'GTSTC'),
      ],
    ));

/// La barra de operación del muelle en el modo Descarga.
@Preview(
  name: 'Barra de operación',
  group: 'Diseño',
  theme: bsTemaDeVistaPrevia,
  size: Size(360, 220),
)
Widget vistaPreviaBarraDeOperacion() => BsBarraDeOperacion(
      contadores: const <BsContador>[
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
    );
