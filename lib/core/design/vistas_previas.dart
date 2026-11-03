import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import 'bs_colores_semanticos.dart';
import 'bs_iconos.dart';
import 'bs_paleta.dart';
import 'bs_tema.dart';
import 'componentes/bs_anillo_avance.dart';
import 'componentes/bs_banda.dart';
import 'componentes/bs_banda_muelle.dart';
import 'componentes/bs_barra_de_magnitud.dart';
import 'componentes/bs_barra_de_operacion.dart';
import 'componentes/bs_buque_en_corte.dart';
import 'componentes/bs_cartela.dart';
import 'componentes/bs_casco_bodega.dart';
import 'componentes/bs_celda.dart';
import 'componentes/bs_cifra.dart';
import 'componentes/bs_distintivo_de_rol.dart';
import 'componentes/bs_ficha_de_cifra.dart';
import 'componentes/bs_fondo_de_plano.dart';
import 'componentes/bs_hoja_de_detalle.dart';
import 'componentes/bs_marca.dart';
import 'componentes/bs_numero_de_contenedor.dart';
import 'componentes/bs_panel.dart';
import 'componentes/bs_panel_en_vivo.dart';
import 'componentes/bs_selector_de_modo.dart';
import 'componentes/bs_silueta_buque.dart';
import 'componentes/bs_tarjeta_cifra.dart';
import 'componentes/bs_tarjeta_de_rol.dart';
import 'componentes/bs_tira_de_bahias.dart';
import 'componentes/bs_travesia.dart';

/// Los temas que usa el previsualizador de widgets (`flutter widget-preview
/// start`): el día y la noche de la dirección C, con la densidad del muelle.
PreviewThemeData bsTemaDeVistaPrevia() => PreviewThemeData(
      materialLight: BayStreamTema.claro(muelle: true),
      materialDark: BayStreamTema.oscuro(muelle: true),
    );

/// Los mismos temas con la densidad de la oficina (celda de 52 × 48, segunda
/// línea con zoom de 100 % o más).
PreviewThemeData bsTemaDeVistaPreviaOficina() => PreviewThemeData(
      materialLight: BayStreamTema.claro(),
      materialDark: BayStreamTema.oscuro(),
    );

/// Un lienzo con el papel del tema y relleno alrededor.
Widget _lienzo(Widget hijo) => Builder(
      builder: (BuildContext context) => Material(
        color: Theme.of(context).colorScheme.surface,
        child: Padding(padding: const EdgeInsets.all(16), child: hijo),
      ),
    );

/// Las celdas del plano en la vista por destino, con insignias y marcas, en
/// el muelle: la segunda línea que reciben no se dibuja (10.7, H2), y las
/// atenuadas conservan el código legible (10.7, H1).
@Preview(name: 'Celdas · muelle, claro', group: 'Diseño', theme: bsTemaDeVistaPrevia)
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
              onTap: () {},
            ),
            BsCelda(
              codigo: 'USHOU',
              atenuada: true,
              insignia: BsInsigniaDeCelda.peligrosa,
              categoria: semanticos.categorico('USHOU'),
              etiqueta: 'MSCU 123457 5, peligrosa, fuera del filtro',
              onTap: () {},
            ),
            BsCelda(
              codigo: 'GTSTC',
              atenuada: true,
              marca: BsMarcaDeCelda.hecho,
              categoria: semanticos.categorico('GTSTC'),
              etiqueta: 'MSCU 123457 6, hecho, fuera del filtro',
              onTap: () {},
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

/// Las mismas celdas en la noche: destino y tipo como fichas (13.4).
@Preview(
  name: 'Celdas · muelle, noche',
  group: 'Diseño',
  theme: bsTemaDeVistaPrevia,
  brightness: Brightness.dark,
)
Widget vistaPreviaCeldasOscuro() => vistaPreviaCeldas();

/// Las celdas en la oficina: la segunda línea (peso o tipo) se dibuja con
/// zoom de 100 % o más, y desaparece por debajo (10.7, H2).
@Preview(
  name: 'Celdas · oficina, zoom 100 % y 75 %',
  group: 'Diseño',
  theme: bsTemaDeVistaPreviaOficina,
)
Widget vistaPreviaCeldasOficina() => _lienzo(Builder(
      builder: (BuildContext context) {
        final semanticos = BsColoresSemanticos.de(context);
        return Wrap(
          children: <Widget>[
            for (final zoom in <double>[1.0, 1.5, 0.75])
              BsCelda(
                codigo: 'GTSTC',
                linea2: '28.7',
                zoom: zoom,
                categoria: semanticos.categorico('GTSTC'),
                etiqueta: 'MSCU 123456 7, 002-01-82, GTSTC, 28.7 t, '
                    'zoom ${(zoom * 100).round()} %',
                onTap: () {},
              ),
            BsCelda(
              codigo: '45G1',
              linea2: 'vacío',
              categoria: semanticos.categorico('45G1'),
              etiqueta: 'MSCU 123456 8, 002-03-82, 45G1, vacío',
              onTap: () {},
            ),
            BsCelda(
              codigo: 'GTSTC',
              linea2: '28.7',
              atenuada: true,
              categoria: semanticos.categorico('GTSTC'),
              etiqueta: 'MSCU 123457 3, fuera del filtro',
              onTap: () {},
            ),
          ],
        );
      },
    ));

/// La vista Estado (13.2): por bajar en cubierta y en bodega, de paso, bajado
/// y recién movido, en la oficina de noche: el plano como el ícono.
@Preview(
  name: 'Celdas · vista Estado, noche',
  group: 'Diseño',
  theme: bsTemaDeVistaPreviaOficina,
  brightness: Brightness.dark,
)
Widget vistaPreviaCeldasEstado() => _lienzo(Builder(
      builder: (BuildContext context) {
        final semanticos = BsColoresSemanticos.de(context);
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Wrap(
              children: <Widget>[
                BsCelda(
                  codigo: 'GTSTC',
                  linea2: '24.1',
                  estado: BsEstadoDeCelda.porBajarCubierta,
                  categoria: semanticos.categorico('GTSTC'),
                  etiqueta: 'TSTU 000110 8, 014-02-86, GTSTC, por bajar',
                  onTap: () {},
                ),
                BsCelda(
                  codigo: 'GTSTC',
                  linea2: '18.0',
                  estado: BsEstadoDeCelda.recienMovido,
                  categoria: semanticos.categorico('GTSTC'),
                  etiqueta: 'TSTU 004218 0, 014-01-86, GTSTC',
                  onTap: () {},
                ),
                BsCelda(
                  codigo: 'GTSTC',
                  estado: BsEstadoDeCelda.bajado,
                  etiqueta: 'Celda 014-03-86, bajado',
                  onTap: () {},
                ),
                BsCelda(
                  codigo: 'USHOU',
                  linea2: '27.5',
                  estado: BsEstadoDeCelda.dePaso,
                  categoria: semanticos.categorico('USHOU'),
                  etiqueta: 'TSTU 012775 5, 014-05-86, USHOU, de paso',
                  onTap: () {},
                ),
                BsCelda(
                  codigo: 'USHOU',
                  insignia: BsInsigniaDeCelda.refrigerado,
                  estado: BsEstadoDeCelda.porBajarCubierta,
                  atenuada: true,
                  etiqueta: 'TSTU 020493 3, 014-07-86, fuera del filtro',
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 16),
            BsCascoBodega(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      BsCelda(
                        codigo: 'GTSTC',
                        estado: BsEstadoDeCelda.porBajarBodega,
                        etiqueta: 'TSTU 031167 5, 014-04-08, GTSTC, por bajar',
                        onTap: () {},
                      ),
                      BsCelda(
                        codigo: 'PAMIT',
                        estado: BsEstadoDeCelda.dePaso,
                        etiqueta: 'TSTU 031168 0, 014-02-08, PAMIT, de paso',
                        onTap: () {},
                      ),
                      BsCelda(
                        codigo: 'GTSTC',
                        estado: BsEstadoDeCelda.porBajarBodega,
                        etiqueta: 'TSTU 031169 6, 014-00-08, GTSTC, por bajar',
                        onTap: () {},
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      BsCelda(
                        codigo: 'GTSTC',
                        estado: BsEstadoDeCelda.porBajarBodega,
                        curva: BsCurvaDeCelda.babor,
                        etiqueta: 'TSTU 031170 2, 014-04-06, GTSTC, por bajar',
                        onTap: () {},
                      ),
                      BsCelda(
                        codigo: 'GTSTC',
                        estado: BsEstadoDeCelda.porBajarBodega,
                        etiqueta: 'TSTU 031171 8, 014-02-06, GTSTC, por bajar',
                        onTap: () {},
                      ),
                      BsCelda(
                        codigo: 'USHOU',
                        estado: BsEstadoDeCelda.dePaso,
                        curva: BsCurvaDeCelda.estribor,
                        etiqueta: 'TSTU 031172 3, 014-00-06, USHOU, de paso',
                        onTap: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    ));

/// La vista Estado de día, en el muelle: «Baja» en la marca, «Hecho» y
/// «Paso» con los roles de la Fase 2, y la celda que sale de su sitio.
@Preview(name: 'Celdas · vista Estado, muelle de día', group: 'Diseño', theme: bsTemaDeVistaPrevia)
Widget vistaPreviaCeldasEstadoMuelle() => _lienzo(Wrap(
      children: <Widget>[
        BsCelda(
          codigo: 'GTSTC',
          estado: BsEstadoDeCelda.porBajarCubierta,
          marca: BsMarcaDeCelda.baja,
          etiqueta: 'TSTU 000110 8, 014-02-86, por bajar',
          onTap: () {},
        ),
        BsCelda(
          codigo: 'GTSTC',
          estado: BsEstadoDeCelda.recienMovido,
          marca: BsMarcaDeCelda.baja,
          etiqueta: 'TSTU 004218 0, 014-01-86',
          onTap: () {},
        ),
        BsCelda(
          codigo: 'GTSTC',
          estado: BsEstadoDeCelda.bajado,
          marca: BsMarcaDeCelda.hecho,
          etiqueta: 'TSTU 012775 5, 014-03-86, hecho',
          onTap: () {},
        ),
        const BsCelda(
          codigo: 'JMKCT',
          estado: BsEstadoDeCelda.dePaso,
          marca: BsMarcaDeCelda.paso,
          etiqueta: 'TSTU 020493 3, 014-05-86, JMKCT, de paso',
        ),
        BsCelda(
          codigo: 'GTSTC',
          estado: BsEstadoDeCelda.porBajarBodega,
          marca: BsMarcaDeCelda.baja,
          curva: BsCurvaDeCelda.babor,
          etiqueta: 'TSTU 031167 5, 014-04-10, por bajar',
          onTap: () {},
        ),
      ],
    ));

/// La marca no tapa el código (T-133): las reservas de la bahía 10 del
/// piloto con su OR y «Revisar» debajo, un cancelado y una recién movida.
@Preview(name: 'Celdas · la marca debajo del código', group: 'Diseño', theme: bsTemaDeVistaPrevia)
Widget vistaPreviaCeldasConMarca() => _lienzo(Builder(
      builder: (BuildContext context) {
        final semanticos = BsColoresSemanticos.de(context);
        return Wrap(
          children: <Widget>[
            for (final orden in const <int>[142, 148, 67, 62])
              BsCelda(
                codigo: 'OR $orden',
                marca: BsMarcaDeCelda.revisar,
                categoria: semanticos.hecho,
                etiqueta: 'Reserva 010, OR $orden, revisar',
                onTap: () {},
              ),
            BsCelda(
              codigo: 'OR 49',
              marca: BsMarcaDeCelda.cancelado,
              categoria: semanticos.pendiente,
              etiqueta: 'OR 49, cancelado',
              onTap: () {},
            ),
            BsCelda(
              codigo: 'OR 1',
              marca: BsMarcaDeCelda.revisar,
              estado: BsEstadoDeCelda.recienMovido,
              etiqueta: 'OR 1, revisar',
              onTap: () {},
            ),
          ],
        );
      },
    ));

/// La marca: con recuadro, sin recuadro, monocroma y en espera.
@Preview(name: 'Marca', group: 'Diseño', theme: bsTemaDeVistaPrevia)
Widget vistaPreviaMarca() => _lienzo(const Wrap(
      spacing: 16,
      runSpacing: 16,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        BsMarca(tamano: 44),
        BsMarca(tamano: 44, variante: BsVarianteDeMarca.sinRecuadro),
        BsMarca(tamano: 44, variante: BsVarianteDeMarca.monocroma),
        BsMarca(tamano: 72, espera: true),
        BsMarca(tamano: 24),
      ],
    ));

/// La silueta del buque con una bahía seleccionada, el avance y una recién
/// movida.
@Preview(name: 'Silueta del buque', group: 'Diseño', theme: bsTemaDeVistaPrevia)
Widget vistaPreviaSiluetaBuque() => _lienzo(BsSiluetaBuque(
      bahias: <BsBahiaDeSilueta>[
        for (var i = 0; i < 10; i++)
          BsBahiaDeSilueta(
            numero: 2 + 4 * i,
            nivelesCubierta: <int>[2, 3, 4, 3, 4, 4, 4, 4, 4, 3][i],
            nivelesBodega: <int>[3, 4, 4, 4, 4, 4, 4, 4, 4, 4][i],
            avance: i < 3 ? 1.0 : (i == 3 ? 0.25 : (i == 4 ? 0.6 : 0.0)),
            conTrabajo: i >= 3 && i <= 6,
          ),
      ],
      seleccionada: 14,
      recienMovida: 14,
      onSeleccion: (int bahia) {},
      rotuloDeAvance: 'avance de la descarga en GTSTC',
    ));

/// Las tarjetas de cifra del mosaico, con el anillo de avance.
@Preview(name: 'Tarjetas de cifra', group: 'Diseño', theme: bsTemaDeVistaPreviaOficina)
Widget vistaPreviaTarjetasCifra() => _lienzo(Builder(
      builder: (BuildContext context) => Wrap(
        spacing: 12,
        runSpacing: 12,
        children: <Widget>[
          const SizedBox(
            width: 220,
            child: BsTarjetaCifra(
              valor: '80 %',
              rotulo: 'Descarga',
              detalle: '120 de 150 bajados en GTSTC',
              anillo: BsAnilloAvance(fraccion: 0.8),
            ),
          ),
          const SizedBox(
            width: 160,
            child: BsTarjetaCifra(
              valor: '30',
              rotulo: 'Por bajar',
              detalle: '18 en la bahía 14',
            ),
          ),
          const SizedBox(
            width: 160,
            child: BsTarjetaCifra(
              valor: '3',
              rotulo: 'Re‑estibas',
              detalle: '2 para abrir la tapa de la 14',
            ),
          ),
          SizedBox(
            width: 200,
            child: BsTarjetaCifra(
              valor: '2',
              rotulo: 'Alertas de estiba',
              detalle: '1 de peso por pila, 1 de segregación',
              rol: BsColoresSemanticos.de(context).revisar,
              onTap: () {},
            ),
          ),
        ],
      ),
    ));

/// El panel «En vivo», con el rol del equipo y nunca un nombre.
@Preview(name: 'Panel En vivo', group: 'Diseño', theme: bsTemaDeVistaPreviaOficina, size: Size(400, 420))
Widget vistaPreviaPanelEnVivo() => _lienzo(BsPanelEnVivo(
      resumen: 'Oficina y 2 teléfonos del muelle',
      eventos: <BsEventoEnVivo>[
        const BsEventoEnVivo(
          que: 'Bajando',
          quien: BsEquipo.muelle,
          detalle: 'TSTU 000110 8 · 014-02-86',
          tipo: BsTipoDeEvento.movido,
          momento: 'ahora',
        ),
        const BsEventoEnVivo(
          que: 'Bajado',
          quien: BsEquipo.muelle,
          detalle: 'TSTU 004218 0 · 014-01-86',
          tipo: BsTipoDeEvento.hecho,
          momento: 'hace 1 min',
        ),
        BsEventoEnVivo(
          que: 'Cambio pedido',
          quien: BsEquipo.muelle,
          detalle: 'TSTU 020493 3 · 014-03-84',
          tipo: BsTipoDeEvento.aviso,
          accion: 'Revisar',
          onAccion: () {},
        ),
        const BsEventoEnVivo(
          que: 'Re‑estiba aprobada',
          quien: BsEquipo.oficina,
          detalle: 'TSTU 031167 5 · 018-07-84 → 018-05-86',
          tipo: BsTipoDeEvento.aprobado,
          momento: 'hace 9 min',
        ),
      ],
    ));

/// La banda del muelle, con la marca sin recuadro y los modos.
@Preview(name: 'Banda del muelle', group: 'Diseño', theme: bsTemaDeVistaPrevia, size: Size(390, 160))
Widget vistaPreviaBandaMuelle() => BsBandaMuelle(
      buque: 'BUQUE MANUAL',
      viaje: 'Viaje M100 · GTSTC',
      nube: BsChipDeNube(texto: 'Al día', onTap: () {}),
      modo: BsModoDeOperacion.descarga,
      onModo: (BsModoDeOperacion modo) {},
    );

/// Los cuatro distintivos de rol: el muelle y la oficina, completo y
/// compacto.
Widget _distintivos() => Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        for (final equipo in BsEquipo.values) ...<Widget>[
          BsDistintivoDeRol(equipo: equipo, onTap: () {}),
          BsDistintivoDeRol(equipo: equipo, compacto: true, onTap: () {}),
        ],
      ],
    );

/// El distintivo de rol (13.12; 10.86, «Filo de metal»), con la densidad del
/// muelle: sobre el papel y en la banda, a la izquierda de Descarga / Carga.
@Preview(name: 'Distintivo de rol', group: 'Diseño', theme: bsTemaDeVistaPrevia, size: Size(420, 320))
Widget vistaPreviaDistintivoDeRol() => Builder(
      builder: (BuildContext context) => Material(
        color: Theme.of(context).colorScheme.surface,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(padding: const EdgeInsets.all(16), child: _distintivos()),
            BsBandaMuelle(
              buque: 'BUQUE MANUAL',
              viaje: 'Viaje M100 · GTSTC',
              nube: BsChipDeNube(texto: 'Al día', onTap: () {}),
              modo: BsModoDeOperacion.descarga,
              onModo: (BsModoDeOperacion modo) {},
              distintivo: (bool compacto) => BsDistintivoDeRol(
                equipo: BsEquipo.muelle,
                compacto: compacto,
                onTap: () {},
              ),
            ),
          ],
        ),
      ),
    );

/// El mismo, de noche: el metal no cambia con el tema.
@Preview(
  name: 'Distintivo de rol, noche',
  group: 'Diseño',
  theme: bsTemaDeVistaPrevia,
  brightness: Brightness.dark,
  size: Size(420, 320),
)
Widget vistaPreviaDistintivoDeRolOscuro() => vistaPreviaDistintivoDeRol();

/// Con la densidad de la oficina (32 dp de alto visible y el ícono a 18), de
/// noche, como en la cabecera de la oficina.
@Preview(
  name: 'Distintivo de rol · oficina, noche',
  group: 'Diseño',
  theme: bsTemaDeVistaPreviaOficina,
  brightness: Brightness.dark,
  size: Size(420, 120),
)
Widget vistaPreviaDistintivoDeRolOficina() => _lienzo(_distintivos());

/// El fondo de plano: la rejilla al 5 % solo de noche.
@Preview(
  name: 'Fondo de plano, noche',
  group: 'Diseño',
  theme: bsTemaDeVistaPreviaOficina,
  brightness: Brightness.dark,
  size: Size(320, 200),
)
Widget vistaPreviaFondoDePlano() => const BsFondoDePlano(
      child: Center(child: BsMarca(tamano: 64)),
    );

/// La tira de bahías de la Fase 2, que la silueta evoluciona.
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
            BsCifraDeCartela(rotulo: 'Peso', valor: '416.8 t'),
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
                rotulo: 'Refrigerado', cuenta: 12, icono: BsIconos.refrigerado),
            const BsEntradaDeLeyenda(
                rotulo: 'IMO', cuenta: 3, icono: BsIconos.peligrosa),
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
        BsFilaDeDetalle('Peso', '28.7 t'),
        BsFilaDeDetalle('VGM', '28 650 kg'),
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
        icon: const Icon(Icons.table_chart),
        label: const Text('Pendientes por bahía'),
      ),
    );

/// La travesía del inicio (13.11, regla 7): el buque de `sin_conexion`
/// reflejado, con la proa a la derecha, el mar a todo el ancho, el vaivén, el
/// cabeceo, la estela y las dos olas. Con reducción de movimiento, quieto a un
/// tercio del ancho.
@Preview(
  name: 'Travesía del inicio',
  group: 'Diseño',
  theme: bsTemaDeVistaPrevia,
  size: Size(720, 240),
)
Widget vistaPreviaTravesia() => Builder(
      builder: (BuildContext context) => Material(
        color: Theme.of(context).colorScheme.surface,
        child: const SizedBox(height: 240, child: BsTravesia()),
      ),
    );

/// Las entradas del selector de modo de las vistas previas (`DESIGN.md` 14.6).
const List<BsEntradaDeModo<String>> _modosDeEjemplo = <BsEntradaDeModo<String>>[
  BsEntradaDeModo<String>(
    valor: 'contenido',
    rotulo: 'Contenido',
    icono: BsIconos.contenedor40,
    ayuda: 'El destino de cada contenedor',
  ),
  BsEntradaDeModo<String>(
    valor: 'orden',
    rotulo: 'Número de orden',
    rotuloCorto: 'Orden',
    icono: BsIconos.orden,
    cuenta: '30 OR del listado',
  ),
  BsEntradaDeModo<String>(
    valor: 'descarga',
    rotulo: 'Descarga',
    icono: BsIconos.descarga,
    cuenta: '28 por bajar en GTSTC',
    cuentaCorta: '28',
    ayuda: 'Toca un contenedor para marcarlo como descargado',
  ),
  BsEntradaDeModo<String>(
    valor: 'carga',
    rotulo: 'Carga',
    icono: BsIconos.carga,
    cuenta: '29 pendientes: 20 llenos, 9 vacíos',
    cuentaCorta: '29',
  ),
];

/// El selector de modo de la oficina, en segmentos y en menú (14.6).
@Preview(name: 'Selector de modo', group: 'Diseño', theme: bsTemaDeVistaPreviaOficina, size: Size(720, 200))
Widget vistaPreviaSelectorDeModo() => _lienzo(Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        BsSelectorDeModo<String>(
          entradas: _modosDeEjemplo,
          elegido: 'carga',
          forma: BsFormaDelSelector.segmentos,
          onElegir: (String _) {},
        ),
        const SizedBox(height: 16),
        BsSelectorDeModo<String>(
          entradas: _modosDeEjemplo,
          elegido: 'carga',
          forma: BsFormaDelSelector.menu,
          onElegir: (String _) {},
        ),
      ],
    ));

/// El resumen del modo en fichas y las tarjetas cortas del panel del buque
/// (14.2 y 14.7).
@Preview(name: 'Fichas y tarjetas cortas', group: 'Diseño', theme: bsTemaDeVistaPreviaOficina, size: Size(720, 220))
Widget vistaPreviaFichasYTarjetasCortas() => _lienzo(Builder(
      builder: (BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Wrap(
            spacing: 24,
            runSpacing: 4,
            children: <Widget>[
              const BsFichaDeCifra(rotulo: 'Bahía 10', valor: 'cub. 2, bod. 7'),
              const BsFichaDeCifra(
                  rotulo: 'Carga', valor: '29 pendientes, 20 llenos, 9 vacíos'),
              BsFichaDeCifra(
                valor: 'Importa el listado de agencia para operar por OR.',
                rol: BsColoresSemanticos.de(context).revisar,
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Wrap(
            spacing: 12,
            children: <Widget>[
              SizedBox(
                width: BsTarjetaCifra.anchoCorta,
                child: BsTarjetaCifra(
                  corta: true,
                  valor: '120 de 150',
                  rotulo: 'Descarga',
                  detalle: '80 %',
                  anillo: BsAnilloAvance(
                      fraccion: 0.8, tamano: BsTarjetaCifra.anilloCorta, grosor: 7),
                ),
              ),
              SizedBox(
                width: BsTarjetaCifra.anchoCorta,
                child: BsTarjetaCifra(
                  corta: true,
                  valor: '30',
                  rotulo: 'Por bajar',
                  detalle: '18 en la bahía 14',
                ),
              ),
            ],
          ),
        ],
      ),
    ));

/// El buque en corte de Estadísticas (15.4), con las cifras de ejemplo de 9.5:
/// las dos pilas por bahía y el pie con el número, la cuenta y el peso.
@Preview(name: 'Buque en corte', group: 'Diseño', theme: bsTemaDeVistaPreviaOficina, size: Size(900, 320))
Widget vistaPreviaBuqueEnCorte() => _lienzo(BsBuqueEnCorte(
      bahias: const <BsBahiaEnCorte>[
        BsBahiaEnCorte(numero: 2, contenedoresCubierta: 33, contenedoresBodega: 30, pesoCubiertaKg: 210000, pesoBodegaKg: 206800),
        BsBahiaEnCorte(numero: 6, contenedoresCubierta: 30, contenedoresBodega: 28, pesoCubiertaKg: 190200, pesoBodegaKg: 190000),
        BsBahiaEnCorte(numero: 10, contenedoresCubierta: 31, contenedoresBodega: 30, pesoCubiertaKg: 201100, pesoBodegaKg: 201000),
        BsBahiaEnCorte(numero: 14, contenedoresCubierta: 24, contenedoresBodega: 20, pesoCubiertaKg: 150500, pesoBodegaKg: 140000),
        BsBahiaEnCorte(numero: 18, contenedoresCubierta: 26, contenedoresBodega: 26, pesoCubiertaKg: 171500, pesoBodegaKg: 171500),
        BsBahiaEnCorte(numero: 22, contenedoresCubierta: 25, contenedoresBodega: 24, pesoCubiertaKg: 161700, pesoBodegaKg: 161700),
        BsBahiaEnCorte(numero: 26, contenedoresCubierta: 20, contenedoresBodega: 18, pesoCubiertaKg: 125400, pesoBodegaKg: 125400),
        BsBahiaEnCorte(numero: 30, contenedoresCubierta: 21, contenedoresBodega: 20, pesoCubiertaKg: 135300, pesoBodegaKg: 135300),
        BsBahiaEnCorte(numero: 34, contenedoresCubierta: 15, contenedoresBodega: 14, pesoCubiertaKg: 95700, pesoBodegaKg: 95700),
        BsBahiaEnCorte(numero: 38, contenedoresCubierta: 11, contenedoresBodega: 10, pesoCubiertaKg: 69300, pesoBodegaKg: 69300),
      ],
      onSeleccion: (int _) {},
    ));

/// Los paneles de Estadísticas (15.5): las barras con la caja del código, la
/// rampa de los tamaños y las tarjetas de rol de la carga especial.
@Preview(name: 'Paneles de Estadísticas', group: 'Diseño', theme: bsTemaDeVistaPreviaOficina, size: Size(760, 560))
Widget vistaPreviaPanelesDeEstadisticas() => _lienzo(Builder(
      builder: (BuildContext context) {
        final semanticos = BsColoresSemanticos.de(context);
        final rampa = BsPaleta.de(Theme.of(context).brightness).rampaDeMagnitud;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            BsPanel(
              titulo: 'Por puerto de descarga',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  BsBarraDeMagnitud(rotulo: 'GTSTC', valor: 520, total: 977, maximo: 520, caja: semanticos.categorico('GTSTC')),
                  const SizedBox(height: 8),
                  BsBarraDeMagnitud(rotulo: 'USHOU', valor: 245, total: 977, maximo: 520, caja: semanticos.categorico('USHOU')),
                  const SizedBox(height: 8),
                  BsBarraDeMagnitud(rotulo: 'PAMIT', valor: 130, total: 977, maximo: 520, caja: semanticos.categorico('PAMIT')),
                  const SizedBox(height: 8),
                  const BsBarraDeMagnitud(rotulo: 'Otros 3 puertos', valor: 82, total: 977, maximo: 520),
                ],
              ),
            ),
            const SizedBox(height: 16),
            BsPanel(
              titulo: 'Por tamaño',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  BsBarraDeMagnitud(rotulo: '20 pies', valor: 410, total: 977, maximo: 487, color: rampa[1]),
                  const SizedBox(height: 8),
                  BsBarraDeMagnitud(rotulo: '40 pies', valor: 487, total: 977, maximo: 487, color: rampa[2]),
                  const SizedBox(height: 8),
                  BsBarraDeMagnitud(rotulo: '45 pies', valor: 80, total: 977, maximo: 487, color: rampa[3]),
                ],
              ),
            ),
            const SizedBox(height: 16),
            BsPanel(
              titulo: 'Carga especial',
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: <Widget>[
                  BsTarjetaDeRol(rol: semanticos.peligrosa, icono: BsIconos.peligrosa, valor: '3', rotulo: 'Peligrosa IMDG'),
                  BsTarjetaDeRol(rol: semanticos.refrigerado, icono: BsIconos.refrigerado, valor: '12', rotulo: 'Refrigerado'),
                  BsTarjetaDeRol(rol: semanticos.oog, icono: BsIconos.fueraDeMedida, valor: '1', rotulo: 'Fuera de medida'),
                ],
              ),
            ),
          ],
        );
      },
    ));
