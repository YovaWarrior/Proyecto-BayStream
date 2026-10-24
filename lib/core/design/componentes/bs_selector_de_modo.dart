import 'package:flutter/material.dart';

import '../bs_medidas.dart';
import '../bs_paleta.dart';
import '../bs_tipografia.dart';
import 'bs_primera_que_cabe.dart';

/// Cómo se dibuja el selector (`DESIGN.md`, 14.6).
enum BsFormaDelSelector {
  /// Todos los modos a la vista, uno junto a otro.
  segmentos,

  /// Un botón con el modo elegido que abre la lista.
  menu,

  /// Los segmentos si caben enteros en el ancho que hay; si no, el menú.
  segunElAncho,
}

/// Un modo del selector: lo que vale, cómo se dice y qué cuenta.
@immutable
class BsEntradaDeModo<T> {
  /// Crea la entrada.
  const BsEntradaDeModo({
    required this.valor,
    required this.rotulo,
    this.rotuloCorto,
    this.icono,
    this.cuenta,
    this.cuentaCorta,
    this.ayuda,
  });

  /// El valor que se elige.
  final T valor;

  /// El nombre entero («Número de orden»).
  final String rotulo;

  /// El nombre en los segmentos («Orden»); sin él, el entero.
  final String? rotuloCorto;

  /// El icono, si el modo lo lleva.
  final IconData? icono;

  /// La cuenta del modo, en el menú («28 por bajar en GTSTC»).
  final String? cuenta;

  /// La cuenta en los segmentos, solo la cifra («28»).
  final String? cuentaCorta;

  /// Qué se hace en ese modo, para la descripción emergente y el menú.
  final String? ayuda;

  /// Lo que dice la descripción emergente: el nombre, la cuenta y la ayuda.
  String get descripcion => <String>[
        rotulo,
        if (cuenta != null) cuenta!,
        if (ayuda != null) ayuda!,
      ].join('. ');
}

/// El selector de modo del plano (`DESIGN.md`, 14.6): uno solo, en segmentos
/// o en menú según el ancho medido, y el mismo para «Colorear por» (14.8).
///
/// En segmentos, el elegido va invertido (13.1) y cada uno lleva su icono, su
/// nombre corto y su cuenta en tinta suave; el nombre entero y la ayuda van
/// en la descripción emergente. En menú, un botón con el elegido abre un
/// `MenuAnchor` de Material 3 con el panel, el borde en línea y el radio de
/// hoja; cada entrada mide 56 dp o más, con el icono, el nombre, su cuenta o
/// su ayuda, y la palomita en marca en la elegida.
class BsSelectorDeModo<T> extends StatelessWidget {
  /// Crea el selector.
  const BsSelectorDeModo({
    super.key,
    required this.entradas,
    required this.elegido,
    required this.onElegir,
    this.forma = BsFormaDelSelector.segunElAncho,
    this.nombre = 'Modo del plano',
  });

  /// Los modos que se ofrecen, en su orden.
  final List<BsEntradaDeModo<T>> entradas;

  /// El modo elegido; sin él, ninguno va marcado.
  final T? elegido;

  /// Qué pasa al elegir un modo.
  final ValueChanged<T> onElegir;

  /// Segmentos, menú o lo que quepa.
  final BsFormaDelSelector forma;

  /// Qué se elige, para el lector de pantalla y el botón del menú.
  final String nombre;

  @override
  Widget build(BuildContext context) {
    final segmentos = _Segmentos<T>(selector: this);
    final menu = _Menu<T>(selector: this);
    return switch (forma) {
      BsFormaDelSelector.segmentos => segmentos,
      BsFormaDelSelector.menu => menu,
      BsFormaDelSelector.segunElAncho =>
        BsPrimeraQueCabe(variantes: <Widget>[segmentos, menu]),
    };
  }
}

class _Segmentos<T> extends StatelessWidget {
  const _Segmentos({required this.selector});

  final BsSelectorDeModo<T> selector;

  @override
  Widget build(BuildContext context) {
    final medidas = BsMedidas.de(context);
    final esquema = Theme.of(context).colorScheme;
    final elegido = selector.elegido;
    final valores = selector.entradas.map((e) => e.valor).toSet();
    return Semantics(
      label: selector.nombre,
      container: true,
      child: SegmentedButton<T>(
        segments: <ButtonSegment<T>>[
          for (final entrada in selector.entradas)
            ButtonSegment<T>(
              value: entrada.valor,
              tooltip: entrada.descripcion,
              icon: entrada.icono == null ? null : Icon(entrada.icono),
              label: Text.rich(
                TextSpan(children: <InlineSpan>[
                  TextSpan(text: entrada.rotuloCorto ?? entrada.rotulo),
                  if (entrada.cuentaCorta != null)
                    TextSpan(
                      text: ' ${entrada.cuentaCorta}',
                      // En el elegido, el color de la selección: la tinta
                      // suave sobre la tinta invertida no se lee.
                      style: TextStyle(
                        color: entrada.valor == elegido
                            ? null
                            : esquema.onSurfaceVariant,
                        fontFeatures: cifrasTabulares,
                      ),
                    ),
                ]),
                maxLines: 1,
                softWrap: false,
              ),
            ),
        ],
        selected: <T>{
          if (elegido != null && valores.contains(elegido)) elegido,
        },
        emptySelectionAllowed: true,
        showSelectedIcon: false,
        style: SegmentedButton.styleFrom(
          minimumSize: Size(medidas.objetivoTactil, medidas.alturaBoton),
        ),
        onSelectionChanged: (Set<T> valores) {
          if (valores.isNotEmpty) selector.onElegir(valores.first);
        },
      ),
    );
  }
}

class _Menu<T> extends StatelessWidget {
  const _Menu({required this.selector});

  final BsSelectorDeModo<T> selector;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final medidas = BsMedidas.de(context);
    final paleta = BsPaleta.de(tema.brightness);
    final esquema = tema.colorScheme;
    final textos = tema.textTheme;
    final elegida = selector.entradas
        .where((e) => e.valor == selector.elegido)
        .firstOrNull;
    return MenuAnchor(
      style: MenuStyle(
        backgroundColor: WidgetStatePropertyAll<Color>(paleta.hoja),
        surfaceTintColor: const WidgetStatePropertyAll<Color>(Colors.transparent),
        side: WidgetStatePropertyAll<BorderSide>(
            BorderSide(color: esquema.outlineVariant)),
        shape: WidgetStatePropertyAll<OutlinedBorder>(RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(medidas.radioHoja))),
      ),
      menuChildren: <Widget>[
        for (final entrada in selector.entradas)
          _EntradaDelMenu<T>(
            entrada: entrada,
            elegida: entrada.valor == selector.elegido,
            onElegir: selector.onElegir,
          ),
      ],
      builder: (BuildContext context, MenuController menu, Widget? _) {
        final rotulo = elegida?.rotulo ?? selector.nombre;
        return Tooltip(
          message: elegida?.descripcion ?? selector.nombre,
          excludeFromSemantics: true,
          child: Semantics(
            label: '${selector.nombre}: $rotulo',
            button: true,
            excludeSemantics: true,
            onTap: () => menu.isOpen ? menu.close() : menu.open(),
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                minimumSize: Size(medidas.objetivoTactil, medidas.alturaBoton),
                padding: EdgeInsets.symmetric(horizontal: medidas.espacioM),
                side: BorderSide(color: esquema.outline),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(medidas.radioControl)),
              ),
              onPressed: () => menu.isOpen ? menu.close() : menu.open(),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  if (elegida?.icono != null) ...<Widget>[
                    Icon(elegida!.icono, size: 18),
                    SizedBox(width: medidas.espacioS),
                  ],
                  Flexible(
                    child: Text(rotulo,
                        style: textos.labelLarge, softWrap: true),
                  ),
                  SizedBox(width: medidas.espacioXs),
                  Icon(menu.isOpen ? Icons.expand_less : Icons.expand_more,
                      size: 18),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _EntradaDelMenu<T> extends StatelessWidget {
  const _EntradaDelMenu({
    required this.entrada,
    required this.elegida,
    required this.onElegir,
  });

  final BsEntradaDeModo<T> entrada;
  final bool elegida;
  final ValueChanged<T> onElegir;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final medidas = BsMedidas.de(context);
    final paleta = BsPaleta.de(tema.brightness);
    final esquema = tema.colorScheme;
    final textos = tema.textTheme;
    final linea = entrada.cuenta ?? entrada.ayuda;
    return MenuItemButton(
      style: MenuItemButton.styleFrom(
        minimumSize: const Size(240, 56),
        padding: EdgeInsets.symmetric(
            horizontal: medidas.espacioL, vertical: medidas.espacioS),
        backgroundColor: elegida ? paleta.hojaAlta : null,
      ),
      leadingIcon: entrada.icono == null ? null : Icon(entrada.icono, size: 20),
      trailingIcon: elegida
          ? Icon(Icons.check, color: esquema.primary, size: 20)
          : null,
      semanticsLabel: <String>[
        entrada.rotulo,
        if (linea != null) linea,
        if (elegida) 'elegido',
      ].join(', '),
      onPressed: () => onElegir(entrada.valor),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(entrada.rotulo, style: textos.titleSmall),
            if (linea != null)
              Text(
                linea,
                style: textos.bodySmall?.copyWith(
                  color: esquema.onSurfaceVariant,
                  fontFeatures: cifrasTabulares,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
