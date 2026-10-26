import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design/design.dart';
import '../../domain/entities/entities.dart';
import '../formatters/estadisticas_del_viaje.dart';
import 'navegacion_del_viaje.dart';

/// Las estadísticas del viaje, «El buque en corte» (`DESIGN.md`, 15; T-121,
/// decisiones 10.36 a 10.38 y 10.46).
///
/// La protagonista es la silueta grande del buque con la carga de cada bahía
/// en cubierta y en bodega ([BsBuqueEnCorte]); encima, «977 contenedores a
/// bordo» a 48 y la fila de cifras; debajo, cinco paneles: por puerto de
/// descarga (la caja del código, la barra y la cifra), llenos y vacíos (el
/// anillo), por tamaño (la rampa), la carga especial (tarjetas de su rol) y
/// por naviera. «Contenedores / Peso» cambia lo que dice la altura de la
/// pila; tocar una bahía la abre en el plano ([onBaySelected]); «Ver como
/// tabla» muestra los mismos números en tablas, y Esc y Atrás vuelven a los
/// gráficos (se anota en `cerrablesDeAtrasProvider`). Ancho máximo de 1 440,
/// centrado, sobre [BsFondoDePlano]; con menos de [anchoDeDosColumnas] todo
/// apila. Las cifras salen de [EstadisticasDelViaje]; ningún color suelto de
/// Material: todo sale del tema (15.3).
class VoyageStatsView extends ConsumerStatefulWidget {
  const VoyageStatsView({
    super.key,
    required this.voyage,
    required this.onBaySelected,
  });

  /// El viaje publicado o en previo.
  final VesselVoyage voyage;

  /// Abre una bahía en el plano.
  final ValueChanged<int> onBaySelected;

  /// Cuántos puertos van a la vista antes de «Otros N puertos».
  static const int puertosALaVista = 7;

  /// Cuántas navieras van a la vista antes de «Otras N navieras».
  static const int navierasALaVista = 8;

  /// Desde este ancho del contenido los paneles van en dos columnas.
  static const double anchoDeDosColumnas = 720;

  /// Desde este ancho del contenido los paneles van en tres columnas.
  static const double anchoDeTresColumnas = 1100;

  @override
  ConsumerState<VoyageStatsView> createState() => _VoyageStatsViewState();
}

class _VoyageStatsViewState extends ConsumerState<VoyageStatsView> {
  BsMagnitudDeLaPila _magnitud = BsMagnitudDeLaPila.contenedores;
  bool _tabla = false;

  /// El registro de Atrás donde se anotó la tabla (`DESIGN.md` 8 y 15.6),
  /// guardado al abrirla: en `dispose` no se puede usar `ref`.
  CerrablesDeAtras? _registro;
  late final VoidCallback _cerrarLaTabla = _verGraficos;

  /// El foco de la tabla, para que Esc la cierre. Se pide a propósito al
  /// abrirla: `autofocus` se descarta si algo (el botón, activado con el
  /// teclado) ya tiene el foco en la ruta.
  final FocusNode _focoDeLaTabla =
      FocusNode(debugLabel: 'estadisticas-tabla', skipTraversal: true);

  VesselVoyage? _calculadoPara;
  EstadisticasDelViaje? _calculadas;

  EstadisticasDelViaje get _datos {
    if (_calculadas == null || !identical(_calculadoPara, widget.voyage)) {
      _calculadas = EstadisticasDelViaje.de(widget.voyage);
      _calculadoPara = widget.voyage;
    }
    return _calculadas!;
  }

  void _verTabla() {
    if (_tabla) return;
    final registro = ref.read(cerrablesDeAtrasProvider.notifier);
    _registro = registro;
    registro.anotar(_cerrarLaTabla);
    setState(() => _tabla = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _tabla) _focoDeLaTabla.requestFocus();
    });
  }

  void _verGraficos() {
    if (!_tabla) return;
    _registro?.olvidar(_cerrarLaTabla);
    _registro = null;
    if (mounted) setState(() => _tabla = false);
  }

  @override
  void dispose() {
    if (_tabla) _registro?.olvidar(_cerrarLaTabla);
    _focoDeLaTabla.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final medidas = BsMedidas.de(context);
    final datos = _datos;
    return BsFondoDePlano(
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints restricciones) {
          final anchoDelContenido = math.max(
            0.0,
            math.min(
              restricciones.maxWidth - 2 * medidas.espacioL,
              medidas.anchoMaximo,
            ),
          );
          return SingleChildScrollView(
            key: const ValueKey<String>('estadisticas-scroll'),
            padding: EdgeInsets.all(medidas.espacioL),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: medidas.anchoMaximo),
                child: Column(
                  key: const ValueKey<String>('estadisticas'),
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    _Cabecera(
                      datos: datos,
                      tabla: _tabla,
                      onVerTabla: _verTabla,
                      onVerGraficos: _verGraficos,
                    ),
                    SizedBox(height: medidas.entreBloques),
                    if (_tabla)
                      Focus(
                        focusNode: _focoDeLaTabla,
                        onKeyEvent: (FocusNode _, KeyEvent evento) {
                          if (evento is KeyDownEvent &&
                              evento.logicalKey == LogicalKeyboardKey.escape) {
                            _verGraficos();
                            return KeyEventResult.handled;
                          }
                          return KeyEventResult.ignored;
                        },
                        child: _Tablas(datos: datos),
                      )
                    else
                      _Graficos(
                        datos: datos,
                        anchoDelContenido: anchoDelContenido,
                        magnitud: _magnitud,
                        onMagnitud: (BsMagnitudDeLaPila m) =>
                            setState(() => _magnitud = m),
                        onBahia: widget.onBaySelected,
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// La protagonista a 48, «Ver como tabla» y la fila de cifras (15.2).
class _Cabecera extends StatelessWidget {
  const _Cabecera({
    required this.datos,
    required this.tabla,
    required this.onVerTabla,
    required this.onVerGraficos,
  });

  final EstadisticasDelViaje datos;
  final bool tabla;
  final VoidCallback onVerTabla;
  final VoidCallback onVerGraficos;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final medidas = BsMedidas.de(context);
    final esquema = tema.colorScheme;
    final textos = tema.textTheme;
    final propios = tema.extension<BsTextos>();
    final estiloProtagonista = (propios?.cifraProtagonista ?? textos.displayLarge)
        ?.copyWith(color: esquema.onSurface);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.end,
          runSpacing: medidas.espacioS,
          spacing: medidas.espacioL,
          children: <Widget>[
            Semantics(
              label: '${formatearCuenta(datos.total, 'contenedor', 'contenedores')} '
                  'a bordo',
              excludeSemantics: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    '${datos.total}',
                    key: const ValueKey<String>('estadisticas-protagonista'),
                    style: estiloProtagonista,
                  ),
                  Text(
                    datos.total == 1
                        ? 'contenedor a bordo'
                        : 'contenedores a bordo',
                    style: textos.bodyMedium
                        ?.copyWith(color: esquema.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            OutlinedButton.icon(
              key: const ValueKey<String>('estadisticas-ver-tabla'),
              onPressed: tabla ? onVerGraficos : onVerTabla,
              icon: Icon(tabla ? Icons.bar_chart : Icons.table_chart),
              label: Text(tabla ? 'Ver como gráficos' : 'Ver como tabla'),
            ),
          ],
        ),
        SizedBox(height: medidas.espacioL),
        Wrap(
          spacing: medidas.espacioXxl,
          runSpacing: medidas.espacioM,
          children: <Widget>[
            _Cifra(
              rotulo: 'peso total',
              valor: formatearToneladas(datos.pesoKg),
            ),
            _Cifra(
              rotulo: 'bahías con carga',
              valor: '${datos.bahiasConCarga}',
            ),
            _Cifra(rotulo: 'llenos', valor: '${datos.llenos}'),
            _Cifra(rotulo: 'vacíos', valor: '${datos.vacios}'),
            if (datos.sinEstado > 0)
              _Cifra(rotulo: 'sin estado', valor: '${datos.sinEstado}'),
          ],
        ),
      ],
    );
  }
}

/// Una cifra de la fila: a 28 tabular con su rótulo debajo en tinta suave.
class _Cifra extends StatelessWidget {
  const _Cifra({required this.rotulo, required this.valor});

  final String rotulo;
  final String valor;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final esquema = tema.colorScheme;
    final textos = tema.textTheme;
    return Semantics(
      label: '$rotulo: $valor',
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            valor,
            style: textos.headlineLarge?.copyWith(
              color: esquema.onSurface,
              fontFeatures: cifrasTabulares,
            ),
          ),
          Text(
            rotulo,
            style: textos.labelMedium?.copyWith(color: esquema.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

/// El buque en corte y los cinco paneles (15.4 y 15.5), repartidos por el
/// ancho del contenido (15.7).
class _Graficos extends StatelessWidget {
  const _Graficos({
    required this.datos,
    required this.anchoDelContenido,
    required this.magnitud,
    required this.onMagnitud,
    required this.onBahia,
  });

  final EstadisticasDelViaje datos;
  final double anchoDelContenido;
  final BsMagnitudDeLaPila magnitud;
  final ValueChanged<BsMagnitudDeLaPila> onMagnitud;
  final ValueChanged<int> onBahia;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final medidas = BsMedidas.de(context);
    final semanticos = BsColoresSemanticos.de(context);
    final paleta = BsPaleta.de(tema.brightness);
    final esquema = tema.colorScheme;
    final textos = tema.textTheme;
    final escala = MediaQuery.textScalerOf(context);
    final entre = SizedBox(height: medidas.espacioL);
    final lado = SizedBox(width: medidas.espacioL);
    // Sin ningún peso en el archivo, la pila por peso no diría nada.
    final conPesos = datos.bahias.any((BsBahiaEnCorte b) => b.pesoKg > 0);
    SegmentedButton<BsMagnitudDeLaPila> selector({required bool conRotulos}) =>
        SegmentedButton<BsMagnitudDeLaPila>(
          key: conRotulos
              ? const ValueKey<String>('estadisticas-magnitud')
              : const ValueKey<String>('estadisticas-magnitud-iconos'),
          segments: <ButtonSegment<BsMagnitudDeLaPila>>[
            ButtonSegment<BsMagnitudDeLaPila>(
              value: BsMagnitudDeLaPila.contenedores,
              icon: const Icon(BsIconos.contenedor40),
              label: conRotulos ? const Text('Contenedores') : null,
              tooltip: conRotulos ? null : 'Contenedores',
            ),
            ButtonSegment<BsMagnitudDeLaPila>(
              value: BsMagnitudDeLaPila.peso,
              icon: const Icon(Icons.scale),
              label: conRotulos ? const Text('Peso') : null,
              tooltip: conRotulos ? null : 'Peso',
              enabled: conPesos,
            ),
          ],
          selected: <BsMagnitudDeLaPila>{magnitud},
          showSelectedIcon: false,
          onSelectionChanged: (Set<BsMagnitudDeLaPila> elegido) =>
              onMagnitud(elegido.first),
        );

    final buque = BsPanel(
      key: const ValueKey<String>('estadisticas-carga-por-bahia'),
      titulo: 'Carga por bahía, de proa a popa',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          BsBuqueEnCorte(
            key: const ValueKey<String>('estadisticas-buque'),
            bahias: datos.bahias,
            magnitud: magnitud,
            onSeleccion: onBahia,
          ),
          SizedBox(height: medidas.espacioM),
          Wrap(
            spacing: medidas.espacioL,
            runSpacing: medidas.espacioS,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              // Con los rótulos si caben enteros en el ancho que hay; si no,
              // solo con los iconos y el nombre en la descripción emergente
              // (en el teléfono, un segmento de media pantalla parte
              // «Contenedores» a media palabra desde la letra a 1.1).
              Semantics(
                container: true,
                label: 'Qué dice la altura de la pila',
                child: BsPrimeraQueCabe(
                  variantes: <Widget>[
                    selector(conRotulos: true),
                    selector(conRotulos: false),
                  ],
                ),
              ),
              _Muestra(
                color: semanticos.porBajarCubierta.relleno,
                rotulo: 'Cubierta',
              ),
              _Muestra(
                color: semanticos.porBajarBodega.relleno,
                rotulo: 'Bodega',
              ),
              Text(
                'Toca una bahía para abrirla en el plano',
                style:
                    textos.bodySmall?.copyWith(color: esquema.onSurfaceVariant),
              ),
            ],
          ),
        ],
      ),
    );

    final puertos = BsPanel(
      key: const ValueKey<String>('estadisticas-puertos'),
      titulo: 'Por puerto de descarga',
      child: _Barras(
        filas: EstadisticasDelViaje.conElResto(
          datos.puertos,
          VoyageStatsView.puertosALaVista,
          (int n) => 'Otros ${formatearCuenta(n, 'puerto', 'puertos')}',
        ),
        total: datos.total,
        caja: (CuentaPorCodigo fila) =>
            fila.codigo == null ? null : semanticos.categorico(fila.codigo!),
      ),
    );

    final fraccionLlenos = datos.parte(datos.llenos);
    final porcentajeLlenos = formatearPorcentaje(fraccionLlenos);
    final estiloDelAnillo = textos.titleLarge?.copyWith(
      color: esquema.onSurface,
      fontFeatures: cifrasTabulares,
    );
    // El hueco del anillo tiene que dar para «100 %» con la letra del
    // sistema: 112 con la letra a 1.0, y lo que pida el texto a 2.0.
    const grosorDelAnillo = 12.0;
    final tamanoDelAnillo = math.max(
      112.0,
      _anchoDelTexto('100$espacioDuro%', estiloDelAnillo, escala) +
          2 * grosorDelAnillo +
          2 * medidas.espacioS,
    );
    final llenos = BsPanel(
      key: const ValueKey<String>('estadisticas-llenos'),
      titulo: 'Llenos y vacíos',
      child: Wrap(
        spacing: medidas.espacioL,
        runSpacing: medidas.espacioS,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: <Widget>[
          Stack(
            alignment: Alignment.center,
            children: <Widget>[
              BsAnilloAvance(
                fraccion: fraccionLlenos,
                tamano: tamanoDelAnillo,
                grosor: grosorDelAnillo,
                color: esquema.primary,
                etiqueta: '$porcentajeLlenos llenos',
              ),
              ExcludeSemantics(
                child: Text(porcentajeLlenos, style: estiloDelAnillo),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _Linea(formatearCuenta(datos.llenos, 'lleno', 'llenos')),
              _Linea(formatearCuenta(datos.vacios, 'vacío', 'vacíos')),
              if (datos.sinEstado > 0)
                _Linea('${datos.sinEstado} sin estado'),
            ],
          ),
        ],
      ),
    );

    final rampa = paleta.rampaDeMagnitud;
    final tamano = BsPanel(
      key: const ValueKey<String>('estadisticas-tamano'),
      titulo: 'Por tamaño',
      child: _Barras(
        filas: <CuentaPorCodigo>[
          CuentaPorCodigo(codigo: null, rotulo: '20 pies', cuenta: datos.de20),
          CuentaPorCodigo(codigo: null, rotulo: '40 pies', cuenta: datos.de40),
          CuentaPorCodigo(codigo: null, rotulo: '45 pies', cuenta: datos.de45),
          if (datos.otroTamano > 0)
            CuentaPorCodigo(
                codigo: null, rotulo: 'Otro', cuenta: datos.otroTamano),
        ],
        total: datos.total,
        colores: <Color>[rampa[1], rampa[2], rampa[3], rampa[0]],
      ),
    );

    final tarjetas = <Widget>[
      if (datos.peligrosas > 0)
        BsTarjetaDeRol(
          key: const ValueKey<String>('estadisticas-peligrosas'),
          rol: semanticos.peligrosa,
          icono: BsIconos.peligrosa,
          valor: '${datos.peligrosas}',
          rotulo: 'Peligrosa IMDG',
        ),
      if (datos.refrigerados > 0)
        BsTarjetaDeRol(
          key: const ValueKey<String>('estadisticas-refrigerados'),
          rol: semanticos.refrigerado,
          icono: BsIconos.refrigerado,
          valor: '${datos.refrigerados}',
          rotulo: 'Refrigerado',
        ),
      if (datos.fueraDeMedida > 0)
        BsTarjetaDeRol(
          key: const ValueKey<String>('estadisticas-fuera-de-medida'),
          rol: semanticos.oog,
          icono: BsIconos.fueraDeMedida,
          valor: '${datos.fueraDeMedida}',
          rotulo: 'Fuera de medida',
        ),
    ];
    final especial = BsPanel(
      key: const ValueKey<String>('estadisticas-especial'),
      titulo: 'Carga especial',
      child: tarjetas.isEmpty
          ? Text(
              'Sin carga especial',
              style: textos.bodyMedium?.copyWith(color: esquema.onSurfaceVariant),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                for (var i = 0; i < tarjetas.length; i++) ...<Widget>[
                  if (i > 0) SizedBox(height: medidas.espacioS),
                  tarjetas[i],
                ],
              ],
            ),
    );

    final navieras = BsPanel(
      key: const ValueKey<String>('estadisticas-navieras'),
      titulo: 'Por naviera',
      child: _Barras(
        filas: EstadisticasDelViaje.conElResto(
          datos.navieras,
          VoyageStatsView.navierasALaVista,
          (int n) => 'Otras ${formatearCuenta(n, 'naviera', 'navieras')}',
        ),
        total: datos.total,
        enMono: true,
      ),
    );

    Widget columna(List<Widget> paneles) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            for (var i = 0; i < paneles.length; i++) ...<Widget>[
              if (i > 0) entre,
              paneles[i],
            ],
          ],
        );

    final Widget paneles;
    if (anchoDelContenido >= VoyageStatsView.anchoDeTresColumnas) {
      paneles = columna(<Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(flex: 2, child: puertos),
            lado,
            Expanded(child: llenos),
            lado,
            Expanded(child: especial),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(child: navieras),
            lado,
            Expanded(child: tamano),
          ],
        ),
      ]);
    } else if (anchoDelContenido >= VoyageStatsView.anchoDeDosColumnas) {
      paneles = columna(<Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(child: puertos),
            lado,
            Expanded(child: columna(<Widget>[llenos, tamano])),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(child: especial),
            lado,
            Expanded(child: navieras),
          ],
        ),
      ]);
    } else {
      paneles = columna(<Widget>[puertos, llenos, tamano, especial, navieras]);
    }

    return columna(<Widget>[buque, paneles]);
  }
}

/// El ancho de [texto] con [estilo] y la [escala] de la letra del sistema.
double _anchoDelTexto(String texto, TextStyle? estilo, TextScaler escala) {
  final pintor = TextPainter(
    text: TextSpan(text: texto, style: estilo),
    textDirection: TextDirection.ltr,
    textScaler: escala,
  )..layout();
  final ancho = pintor.width;
  pintor.dispose();
  return ancho;
}

/// Una línea de la leyenda de llenos y vacíos.
class _Linea extends StatelessWidget {
  const _Linea(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: BsMedidas.de(context).espacioXs / 2),
      child: Text(
        texto,
        style: tema.textTheme.bodyMedium?.copyWith(
          color: tema.colorScheme.onSurface,
          fontFeatures: cifrasTabulares,
        ),
      ),
    );
  }
}

/// Una muestra de color con su rótulo, para la leyenda de las dos zonas.
class _Muestra extends StatelessWidget {
  const _Muestra({required this.color, required this.rotulo});

  final Color color;
  final String rotulo;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final medidas = BsMedidas.de(context);
    return Semantics(
      label: rotulo,
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
              border: Border.all(color: tema.colorScheme.outline),
            ),
          ),
          SizedBox(width: medidas.espacioXs + 2),
          Text(rotulo, style: tema.textTheme.labelMedium),
        ],
      ),
    );
  }
}

/// Las barras de un panel: una [BsBarraDeMagnitud] por fila, con la barra más
/// larga llenando el ancho; opcionalmente con la caja del código por fila o
/// un color por fila (la rampa).
class _Barras extends StatelessWidget {
  const _Barras({
    required this.filas,
    required this.total,
    this.caja,
    this.colores,
    this.enMono = false,
  });

  final List<CuentaPorCodigo> filas;
  final int total;
  final BsRol? Function(CuentaPorCodigo fila)? caja;
  final List<Color>? colores;
  final bool enMono;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final medidas = BsMedidas.de(context);
    if (filas.isEmpty) {
      return Text(
        'Sin contenedores',
        style: tema.textTheme.bodyMedium
            ?.copyWith(color: tema.colorScheme.onSurfaceVariant),
      );
    }
    final maximo = filas.fold<int>(
        0, (int m, CuentaPorCodigo f) => math.max(m, f.cuenta));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (var i = 0; i < filas.length; i++) ...<Widget>[
          if (i > 0) SizedBox(height: medidas.espacioS),
          BsBarraDeMagnitud(
            rotulo: filas[i].rotulo,
            valor: filas[i].cuenta,
            total: total,
            maximo: maximo,
            caja: caja?.call(filas[i]),
            color: colores == null || i >= colores!.length ? null : colores![i],
            enMono: enMono && filas[i].codigo != null,
          ),
        ],
      ],
    );
  }
}

/// Las mismas cifras en tablas, un panel por sección (15.6).
class _Tablas extends StatelessWidget {
  const _Tablas({required this.datos});

  final EstadisticasDelViaje datos;

  @override
  Widget build(BuildContext context) {
    final medidas = BsMedidas.de(context);
    String parte(int cuenta) => formatearPorcentaje(datos.parte(cuenta));
    final secciones = <Widget>[
      BsPanel(
        titulo: 'Resumen',
        child: _Tabla(
          columnas: const <String>['Cifra', 'Valor'],
          filas: <_Fila>[
            _Fila(<String>['Contenedores a bordo', '${datos.total}']),
            _Fila(<String>['Peso total', formatearToneladas(datos.pesoKg)]),
            _Fila(<String>['Bahías con carga', '${datos.bahiasConCarga}']),
            _Fila(<String>['Llenos', '${datos.llenos}']),
            _Fila(<String>['Vacíos', '${datos.vacios}']),
            _Fila(<String>['Sin estado', '${datos.sinEstado}']),
          ],
        ),
      ),
      BsPanel(
        titulo: 'Por bahía',
        child: _Tabla(
          columnas: const <String>[
            'Bahía',
            'Contenedores',
            'Cubierta',
            'Bodega',
            'Peso',
          ],
          filas: <_Fila>[
            for (final bahia in datos.bahias)
              _Fila(<String>[
                bahia.rotulo,
                '${bahia.contenedores}',
                '${bahia.contenedoresCubierta}',
                '${bahia.contenedoresBodega}',
                formatearToneladas(bahia.pesoKg),
              ], enMono: true),
            if (datos.sinPosicion > 0)
              _Fila(<String>[
                'Sin posición',
                '${datos.sinPosicion}',
                '',
                '',
                formatearToneladas(datos.pesoSinPosicionKg),
              ]),
          ],
        ),
      ),
      BsPanel(
        titulo: 'Por puerto de descarga',
        child: _Tabla(
          columnas: const <String>['Puerto', 'Contenedores', 'Parte'],
          filas: <_Fila>[
            for (final puerto in datos.puertos)
              _Fila(<String>[
                puerto.rotulo,
                '${puerto.cuenta}',
                parte(puerto.cuenta),
              ], enMono: puerto.codigo != null),
          ],
        ),
      ),
      BsPanel(
        titulo: 'Llenos y vacíos',
        child: _Tabla(
          columnas: const <String>['Estado', 'Contenedores', 'Parte'],
          filas: <_Fila>[
            _Fila(<String>['Llenos', '${datos.llenos}', parte(datos.llenos)]),
            _Fila(<String>['Vacíos', '${datos.vacios}', parte(datos.vacios)]),
            _Fila(<String>[
              'Sin estado',
              '${datos.sinEstado}',
              parte(datos.sinEstado),
            ]),
          ],
        ),
      ),
      BsPanel(
        titulo: 'Por tamaño',
        child: _Tabla(
          columnas: const <String>['Tamaño', 'Contenedores', 'Parte'],
          filas: <_Fila>[
            _Fila(<String>['20 pies', '${datos.de20}', parte(datos.de20)]),
            _Fila(<String>['40 pies', '${datos.de40}', parte(datos.de40)]),
            _Fila(<String>['45 pies', '${datos.de45}', parte(datos.de45)]),
            if (datos.otroTamano > 0)
              _Fila(<String>[
                'Otro',
                '${datos.otroTamano}',
                parte(datos.otroTamano),
              ]),
          ],
        ),
      ),
      BsPanel(
        titulo: 'Carga especial',
        child: _Tabla(
          columnas: const <String>['Carga', 'Contenedores'],
          filas: <_Fila>[
            _Fila(<String>['Peligrosa IMDG', '${datos.peligrosas}']),
            _Fila(<String>['Refrigerado', '${datos.refrigerados}']),
            _Fila(<String>['Fuera de medida', '${datos.fueraDeMedida}']),
          ],
        ),
      ),
      BsPanel(
        titulo: 'Por naviera',
        child: _Tabla(
          columnas: const <String>['Naviera', 'Contenedores', 'Parte'],
          filas: <_Fila>[
            for (final naviera in datos.navieras)
              _Fila(<String>[
                naviera.rotulo,
                '${naviera.cuenta}',
                parte(naviera.cuenta),
              ], enMono: naviera.codigo != null),
          ],
        ),
      ),
    ];
    return Column(
      key: const ValueKey<String>('estadisticas-tabla'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (var i = 0; i < secciones.length; i++) ...<Widget>[
          if (i > 0) SizedBox(height: medidas.espacioL),
          secciones[i],
        ],
      ],
    );
  }
}

/// Una fila de la tabla; con [enMono], la primera celda es un código.
class _Fila {
  const _Fila(this.celdas, {this.enMono = false});

  final List<String> celdas;
  final bool enMono;
}

/// Una tabla accesible: las celdas de la cabecera son encabezados, las cifras
/// van tabulares y a la derecha, y el texto envuelve. **Ninguna palabra se
/// parte:** cada columna de cifras mide lo que su texto más ancho pide (la
/// cabecera o una celda, con la letra del sistema) y la primera se queda con
/// el resto; si ni así cabe (las cinco columnas de «Por bahía» a 360 dp con la
/// letra a 2.0), la tabla se desplaza a lo ancho con su barra visible.
class _Tabla extends StatefulWidget {
  const _Tabla({required this.columnas, required this.filas});

  final List<String> columnas;
  final List<_Fila> filas;

  /// Lo menos que se queda la primera columna antes de desplazar, con la
  /// letra a 1.0: dos palabras cortas.
  static const double anchoMinimoDeLaPrimera = 120;

  @override
  State<_Tabla> createState() => _TablaState();
}

class _TablaState extends State<_Tabla> {
  final ScrollController _horizontal = ScrollController();

  @override
  void dispose() {
    _horizontal.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final medidas = BsMedidas.de(context);
    final esquema = tema.colorScheme;
    final textos = tema.textTheme;
    final escala = MediaQuery.textScalerOf(context);
    final mono = tema.extension<BsTextos>()?.datoMono;
    final estiloCabecera =
        textos.labelMedium?.copyWith(color: esquema.onSurfaceVariant);
    final estiloTexto = textos.bodyMedium?.copyWith(color: esquema.onSurface);
    final estiloCifra = estiloTexto?.copyWith(fontFeatures: cifrasTabulares);
    final estiloCodigo = (mono ?? textos.bodyMedium)
        ?.copyWith(color: esquema.onSurface, fontWeight: FontWeight.w500);
    final relleno = EdgeInsets.symmetric(
      vertical: medidas.espacioS,
      horizontal: medidas.espacioXs,
    );
    final columnas = widget.columnas;
    final filas = widget.filas;

    TextStyle? estiloDe(int columna, _Fila? fila) => columna == 0
        ? (fila?.enMono ?? false ? estiloCodigo : estiloTexto)
        : estiloCifra;

    // Lo que pide cada columna: su texto más ancho, con el relleno.
    final anchos = <double>[];
    for (var i = 0; i < columnas.length; i++) {
      var ancho = _anchoDelTexto(columnas[i], estiloCabecera, escala);
      for (final fila in filas) {
        if (i < fila.celdas.length) {
          ancho = math.max(
            ancho,
            _anchoDelTexto(fila.celdas[i], estiloDe(i, fila), escala),
          );
        }
      }
      anchos.add(ancho + relleno.horizontal + 1);
    }
    final deCifras = anchos.skip(1).fold<double>(0, (double s, double a) => s + a);
    final minimoDeLaPrimera =
        math.min(anchos.first, escala.scale(_Tabla.anchoMinimoDeLaPrimera));

    Widget tabla({required bool cabe}) => Table(
          columnWidths: <int, TableColumnWidth>{
            0: cabe ? const FlexColumnWidth() : FixedColumnWidth(anchos.first),
            for (var i = 1; i < columnas.length; i++)
              i: FixedColumnWidth(anchos[i]),
          },
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          border: TableBorder(
            horizontalInside: BorderSide(color: esquema.outlineVariant),
          ),
          children: <TableRow>[
            TableRow(
              children: <Widget>[
                for (var i = 0; i < columnas.length; i++)
                  Padding(
                    padding: relleno,
                    child: Semantics(
                      header: true,
                      child: Text(
                        columnas[i],
                        style: estiloCabecera,
                        textAlign: i == 0 ? TextAlign.start : TextAlign.end,
                      ),
                    ),
                  ),
              ],
            ),
            for (final fila in filas)
              TableRow(
                children: <Widget>[
                  for (var i = 0; i < columnas.length; i++)
                    Padding(
                      padding: relleno,
                      child: Text(
                        i < fila.celdas.length ? fila.celdas[i] : '',
                        style: estiloDe(i, fila),
                        textAlign: i == 0 ? TextAlign.start : TextAlign.end,
                      ),
                    ),
                ],
              ),
          ],
        );

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints restricciones) {
        final cabe = restricciones.hasBoundedWidth &&
            minimoDeLaPrimera + deCifras <= restricciones.maxWidth;
        if (cabe) return tabla(cabe: true);
        // No cabe ni con la primera columna al mínimo: a lo ancho, con la
        // barra a la vista, antes que partir una palabra.
        return Scrollbar(
          controller: _horizontal,
          thumbVisibility: true,
          scrollbarOrientation: ScrollbarOrientation.bottom,
          child: SingleChildScrollView(
            controller: _horizontal,
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.only(bottom: medidas.espacioM),
            child: SizedBox(
              width: anchos.first + deCifras,
              child: tabla(cabe: false),
            ),
          ),
        );
      },
    );
  }
}
