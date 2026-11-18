import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design/design.dart';
import '../../domain/entities/entities.dart';
import '../formatters/consulta_de_busqueda.dart';
import '../formatters/cuentas_de_los_filtros.dart';
import '../providers/loading_operation_provider.dart';
import '../providers/vessel_providers.dart';
import 'navegacion_del_viaje.dart';

/// T-120 · Las filas de filtros de la Lista (`DESIGN.md` 18.1 a 18.3):
/// «Filtrar por naviera», «Filtrar por destino» y «Carga especial», con las
/// cuentas cruzadas de [cuentasDeLosFiltrosProvider].
///
/// - **En la oficina** (desde 600 dp) van en una tabla de dos columnas: el
///   rótulo a la izquierda, alineado con el más largo, y los chips en un
///   `Wrap` que envuelve en las líneas que pida. Si el rótulo pasa del 30 %
///   del ancho (la letra a 2.0 en una ventana angosta), va encima.
/// - **En el teléfono**, el rótulo arriba y los chips en hasta dos líneas
///   ([BsFichasEnLineas]); si no caben, «Ver los n destinos» abre una hoja con
///   todos. El elegido siempre se ve.
/// - El orden es el del viaje y no cambia al elegir (10.147, punto 1).
class FilasDeFiltros extends ConsumerWidget {
  /// Crea las filas.
  const FilasDeFiltros({super.key});

  /// Desde esta fracción del ancho, el rótulo va encima de sus chips.
  static const double parteDelRotulo = 0.3;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cuentas = ref.watch(cuentasDeLosFiltrosProvider);
    final filtros = ref.watch(filtrosDeLaListaProvider);
    final semanticos = BsColoresSemanticos.de(context);
    final medidas = BsMedidas.de(context);
    final naviera = ref.read(selectedCarrierProvider.notifier);
    final destino = ref.read(selectedDischargePortProvider.notifier);
    final carga = ref.read(selectedSpecialCargoProvider.notifier);

    final filas = <_Fila>[
      if (cuentas.navieras.isNotEmpty)
        _Fila(
          clave: 'naviera',
          rotulo: 'Filtrar por naviera',
          verTodas: 'Ver las ${cuentas.navieras.length} navieras',
          tituloDeLaHoja: 'Todas las navieras',
          fichas: <_DatosDeFicha>[
            _DatosDeFicha(
              clave: 'todas',
              rotulo: 'Todas',
              cuenta: cuentas.todasLasNavieras,
              elegida: filtros.naviera == null,
              onTocar: naviera.clear,
            ),
            for (final f in cuentas.navieras)
              _DatosDeFicha(
                clave: f.clave,
                rotulo: f.clave,
                enMono: true,
                cuenta: f.cuenta,
                elegida: filtros.naviera == f.clave,
                onTocar: () => naviera
                    .select(filtros.naviera == f.clave ? null : f.clave),
              ),
          ],
        ),
      _Fila(
        clave: 'destino',
        rotulo: 'Filtrar por destino',
        verTodas: 'Ver los ${cuentas.destinos.length} destinos',
        tituloDeLaHoja: 'Todos los destinos',
        fichas: <_DatosDeFicha>[
          _DatosDeFicha(
            clave: 'todos',
            rotulo: 'Todos',
            cuenta: cuentas.todosLosDestinos,
            elegida: filtros.destino == null,
            onTocar: destino.clear,
          ),
          for (final f in cuentas.destinos)
            _DatosDeFicha(
              clave: f.clave == FiltrosDeLaLista.sinDestino
                  ? 'sin-destino'
                  : f.clave,
              rotulo: f.clave == FiltrosDeLaLista.sinDestino
                  ? FiltrosDeLaLista.rotuloSinDestino
                  : f.clave,
              caja: f.clave == FiltrosDeLaLista.sinDestino
                  ? null
                  : semanticos.categorico(f.clave),
              cuenta: f.cuenta,
              elegida: filtros.destino == f.clave,
              onTocar: () =>
                  destino.select(filtros.destino == f.clave ? null : f.clave),
            ),
        ],
      ),
      if (cuentas.cargas.isNotEmpty)
        _Fila(
          clave: 'carga',
          rotulo: 'Carga especial',
          verTodas: 'Ver las ${cuentas.cargas.length} cargas',
          tituloDeLaHoja: 'Carga especial',
          fichas: <_DatosDeFicha>[
            for (final f in cuentas.cargas)
              _DatosDeFicha(
                clave: f.clave.name,
                rotulo: f.clave.rotulo,
                icono: switch (f.clave) {
                  CargaEspecial.peligrosa => BsIconos.peligrosa,
                  CargaEspecial.refrigerado => BsIconos.refrigerado,
                  CargaEspecial.fueraDeMedida => BsIconos.fueraDeMedida,
                },
                cuenta: f.cuenta,
                elegida: filtros.cargas.contains(f.clave),
                onTocar: () => carga.toggle(f.clave),
              ),
          ],
        ),
    ];

    final oficina =
        MediaQuery.sizeOf(context).width >= AnchosDeNavegacion.riel;
    final estiloRotulo = Theme.of(context).textTheme.titleSmall;
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints restricciones) {
        final escala = MediaQuery.textScalerOf(context);
        double anchoDe(String texto) => (TextPainter(
              text: TextSpan(text: texto, style: estiloRotulo),
              textScaler: escala,
              textDirection: TextDirection.ltr,
              maxLines: 1,
            )..layout())
                .width;
        final anchoDelRotulo = filas.fold<double>(
            0, (double m, _Fila f) => m > anchoDe(f.rotulo) ? m : anchoDe(f.rotulo));
        final enTabla = oficina &&
            restricciones.hasBoundedWidth &&
            anchoDelRotulo <= restricciones.maxWidth * parteDelRotulo;

        Widget chips(_Fila fila, {required bool enLineas}) {
          final fichas = <Widget>[
            for (final d in fila.fichas) _Ficha(fila: fila.clave, datos: d),
          ];
          if (!enLineas) {
            return Wrap(
              spacing: medidas.espacioS,
              runSpacing: medidas.espacioS,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: fichas,
            );
          }
          final elegida = fila.fichas.indexWhere((d) => d.elegida);
          return BsFichasEnLineas(
            key: ValueKey<String>('filtro-${fila.clave}-lineas'),
            fichas: fichas,
            fija: elegida < 0 ? null : elegida,
            espacio: medidas.espacioS,
            espacioEntreLineas: medidas.espacioS,
            verTodas: ActionChip(
              key: ValueKey<String>('filtro-${fila.clave}-ver-todas'),
              avatar: const Icon(Icons.expand_more),
              label: Text(fila.verTodas),
              onPressed: () => _abrirLaHoja(context, fila),
            ),
          );
        }

        Widget rotulo(_Fila fila) => Semantics(
              header: true,
              child: Text(fila.rotulo, style: estiloRotulo),
            );

        if (enTabla) {
          return Table(
            key: const ValueKey<String>('filtros-de-la-lista'),
            columnWidths: const <int, TableColumnWidth>{
              0: IntrinsicColumnWidth(),
              1: FlexColumnWidth(),
            },
            defaultVerticalAlignment: TableCellVerticalAlignment.top,
            children: <TableRow>[
              for (final fila in filas)
                TableRow(children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(
                        right: medidas.espacioL,
                        top: medidas.espacioS + 4,
                        bottom: medidas.espacioS),
                    child: rotulo(fila),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: medidas.espacioS),
                    child: chips(fila, enLineas: false),
                  ),
                ]),
            ],
          );
        }
        return Column(
          key: const ValueKey<String>('filtros-de-la-lista'),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            for (final fila in filas) ...<Widget>[
              rotulo(fila),
              SizedBox(height: medidas.espacioXs),
              chips(fila, enLineas: !oficina),
              SizedBox(height: medidas.espacioS),
            ],
          ],
        );
      },
    );
  }

  Future<void> _abrirLaHoja(BuildContext context, _Fila fila) async {
    final elegida = await showModalBottomSheet<_DatosDeFicha>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (BuildContext context) => _HojaDeLaFila(fila: fila),
    );
    elegida?.onTocar();
  }
}

/// Los datos de una fila.
class _Fila {
  const _Fila({
    required this.clave,
    required this.rotulo,
    required this.verTodas,
    required this.tituloDeLaHoja,
    required this.fichas,
  });

  final String clave;
  final String rotulo;
  final String verTodas;
  final String tituloDeLaHoja;
  final List<_DatosDeFicha> fichas;
}

/// Los datos de un chip.
class _DatosDeFicha {
  const _DatosDeFicha({
    required this.clave,
    required this.rotulo,
    required this.cuenta,
    required this.elegida,
    required this.onTocar,
    this.caja,
    this.icono,
    this.enMono = false,
  });

  final String clave;
  final String rotulo;
  final int cuenta;
  final bool elegida;
  final VoidCallback onTocar;

  /// La ficha del puerto (`BsCajaDeCodigo`), si es un puerto.
  final BsRol? caja;

  /// El ícono del paquete, si es una carga especial.
  final IconData? icono;

  /// El rótulo en Plex Mono: una naviera.
  final bool enMono;

  /// Un chip en cero se apaga y no se toca; el elegido siempre se puede
  /// soltar.
  bool get activa => elegida || cuenta > 0;

  /// Lo que oye el lector de pantalla: el nombre y la cuenta, una vez.
  String get etiqueta => activa
      ? '$rotulo, ${formatearCuenta(cuenta, 'contenedor', 'contenedores')}'
      : '$rotulo, sin contenedores con estos filtros';
}

/// Un chip de filtro. **El elegido se distingue sin depender del color**
/// (10.147, punto 2): su borde mide 2 dp en la tinta del texto, en vez de 1
/// en la línea, y su cifra va en negrita. Va sin palomita, para que no cambie
/// de ancho al elegirlo.
class _Ficha extends StatelessWidget {
  const _Ficha({required this.fila, required this.datos});

  final String fila;
  final _DatosDeFicha datos;

  /// El grosor del borde del elegido y del que no.
  static const double bordeElegido = 2;
  static const double borde = 1;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final esquema = tema.colorScheme;
    final medidas = BsMedidas.de(context);
    final mono = tema.extension<BsTextos>()?.datoMono;
    // Sin color: el texto toma el del chip, que el tema resuelve por estado
    // (el elegido, el texto de la selección; de noche, la noche sobre la
    // tinta). Con el color de `labelLarge`, de noche el elegido quedaba
    // tinta sobre tinta (T-120: lo vieron las capturas del banco).
    final tamano = tema.textTheme.labelLarge?.fontSize;
    final peso = datos.elegida ? FontWeight.w700 : FontWeight.w500;
    final estilo = TextStyle(fontSize: tamano, fontWeight: peso);
    final estiloRotulo = datos.enMono
        ? estilo.copyWith(fontFamily: mono?.fontFamily, height: 1.2)
        : estilo;
    return FilterChip(
      key: ValueKey<String>('filtro-$fila-${datos.clave}'),
      showCheckmark: false,
      selected: datos.elegida,
      onSelected: datos.activa ? (_) => datos.onTocar() : null,
      side: BorderSide(
        width: datos.elegida ? bordeElegido : borde,
        color: datos.elegida ? esquema.onSurface : esquema.outline,
      ),
      label: Semantics(
        label: datos.etiqueta,
        excludeSemantics: true,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (datos.caja != null)
              BsCajaDeCodigo(codigo: datos.rotulo, rol: datos.caja!)
            else ...<Widget>[
              if (datos.icono != null) ...<Widget>[
                Icon(datos.icono, size: 18),
                SizedBox(width: medidas.espacioXs),
              ],
              Text(datos.rotulo, style: estiloRotulo),
            ],
            SizedBox(width: medidas.espacioS - 2),
            Text(
              '${datos.cuenta}',
              style: estilo.copyWith(fontFeatures: cifrasTabulares),
            ),
          ],
        ),
      ),
    );
  }
}

/// La hoja con todos los chips de una fila, para el teléfono.
class _HojaDeLaFila extends StatelessWidget {
  const _HojaDeLaFila({required this.fila});

  final _Fila fila;

  @override
  Widget build(BuildContext context) {
    final medidas = BsMedidas.de(context);
    final tema = Theme.of(context);
    return SingleChildScrollView(
      key: ValueKey<String>('hoja-filtro-${fila.clave}'),
      padding: EdgeInsets.symmetric(vertical: medidas.espacioS),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: medidas.espacioL, vertical: medidas.espacioS),
            child: Semantics(
              header: true,
              child: Text(fila.tituloDeLaHoja, style: tema.textTheme.titleMedium),
            ),
          ),
          for (final d in fila.fichas)
            ListTile(
              key: ValueKey<String>('hoja-filtro-${fila.clave}-${d.clave}'),
              enabled: d.activa,
              selected: d.elegida,
              leading: d.caja != null
                  ? BsCajaDeCodigo(codigo: d.rotulo, rol: d.caja!)
                  : d.icono != null
                      ? Icon(d.icono)
                      : null,
              title: d.caja != null ? null : Text(d.rotulo),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text('${d.cuenta}',
                      style: tema.textTheme.bodyLarge
                          ?.copyWith(fontFeatures: cifrasTabulares)),
                  if (d.elegida) ...<Widget>[
                    SizedBox(width: medidas.espacioS),
                    Icon(Icons.check, color: tema.colorScheme.primary),
                  ],
                ],
              ),
              onTap: () => Navigator.of(context).pop(d),
            ),
        ],
      ),
    );
  }
}

/// T-120 · El título de la Lista: «Contenedores (520)» y lo que filtra
/// («, naviera LNA, destino GTSTC»), los llenos y los vacíos, y «Quitar
/// filtros» si hay alguno (`DESIGN.md` 18.1).
class TituloDeLaLista extends ConsumerWidget {
  /// Crea el título.
  const TituloDeLaLista({super.key});

  /// El texto del título con [cuantos] y [filtros].
  static String texto(int cuantos, FiltrosDeLaLista filtros) {
    final partes = <String>[
      'Contenedores ($cuantos)',
      if (filtros.naviera != null) 'naviera ${filtros.naviera}',
      if (filtros.destino == FiltrosDeLaLista.sinDestino)
        'sin destino'
      else if (filtros.destino != null)
        'destino ${filtros.destino}',
      if (filtros.cargas.isNotEmpty)
        <String>[
          for (final c in CargaEspecial.values)
            if (filtros.cargas.contains(c))
              c.rotulo[0].toLowerCase() + c.rotulo.substring(1),
        ].join(' o '),
    ];
    return partes.join(', ');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filtrados = ref.watch(filteredContainersProvider);
    final filtros = ref.watch(filtrosDeLaListaProvider);
    final tema = Theme.of(context);
    final esquema = tema.colorScheme;
    Widget cifra(String texto, Color color) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withValues(alpha: 0.5)),
          ),
          child: Text(
            texto,
            style: tema.textTheme.labelMedium
                ?.copyWith(color: color, fontWeight: FontWeight.w500),
          ),
        );
    final llenos =
        filtrados.where((c) => c.status == ContainerStatus.full).length;
    final vacios =
        filtrados.where((c) => c.status == ContainerStatus.empty).length;
    return Wrap(
      key: const ValueKey<String>('titulo-de-la-lista'),
      spacing: 12,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        Semantics(
          header: true,
          child: Text(
            texto(filtrados.length, filtros),
            style: tema.textTheme.titleLarge,
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            cifra(formatearCuenta(llenos, 'lleno', 'llenos'), esquema.primary),
            const SizedBox(width: 8),
            cifra(formatearCuenta(vacios, 'vacío', 'vacíos'), esquema.secondary),
          ],
        ),
        if (filtros.activos)
          TextButton.icon(
            key: const ValueKey<String>('quitar-filtros'),
            icon: const Icon(Icons.filter_alt_off_outlined),
            label: const Text('Quitar filtros'),
            onPressed: () => quitarFiltros(ref),
          ),
      ],
    );
  }

  /// Suelta los tres filtros de la Lista.
  static void quitarFiltros(WidgetRef ref) {
    ref.read(selectedCarrierProvider.notifier).clear();
    ref.read(selectedDischargePortProvider.notifier).clear();
    ref.read(selectedSpecialCargoProvider.notifier).clear();
  }
}
