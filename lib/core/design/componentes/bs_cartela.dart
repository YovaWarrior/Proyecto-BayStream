import 'package:flutter/material.dart';

import '../bs_colores_semanticos.dart';
import '../bs_medidas.dart';
import '../bs_tipografia.dart';

/// Una cifra de la cartela: su rótulo y su valor ya formateado.
@immutable
class BsCifraDeCartela {
  /// Crea la cifra.
  const BsCifraDeCartela({required this.rotulo, required this.valor});

  /// El rótulo («Contenedores», «Peso»).
  final String rotulo;

  /// El valor («63», «416.8 t»).
  final String valor;
}

/// Una entrada de la leyenda: su rol de color o su icono, su rótulo, su cuenta
/// y, si sirve para resaltar, qué pasa al tocarla.
@immutable
class BsEntradaDeLeyenda {
  /// Crea la entrada.
  const BsEntradaDeLeyenda({
    required this.rotulo,
    this.rol,
    this.icono,
    this.cuenta,
    this.activa = false,
    this.onTap,
  });

  /// El rótulo («GTSTC», «Refrigerado»).
  final String rotulo;

  /// El rol de color que dibuja la muestra.
  final BsRol? rol;

  /// El icono, para las entradas que se señalan con icono (carga especial).
  final IconData? icono;

  /// Cuántos hay.
  final int? cuenta;

  /// Si el resaltado está activo.
  final bool activa;

  /// Qué pasa al tocarla; sin él no es un botón.
  final VoidCallback? onTap;
}

/// La cartela del plano: el cajetín de la hoja impresa (`DESIGN.md`, 4.3).
///
/// Lleva el título de la bahía, sus cifras con dígitos tabulares, la leyenda
/// de la vista de color activa como chips que envuelven (nunca un scroll
/// horizontal que corte «Refrigerado») y, si hace falta, una nota.
class BsCartela extends StatelessWidget {
  /// Crea la cartela.
  const BsCartela({
    super.key,
    required this.titulo,
    this.cifras = const <BsCifraDeCartela>[],
    this.leyenda = const <BsEntradaDeLeyenda>[],
    this.nota,
    this.compacta = false,
  });

  /// El título («Bahía 02»).
  final String titulo;

  /// Las cifras de la bahía.
  final List<BsCifraDeCartela> cifras;

  /// La leyenda de la vista de color activa.
  final List<BsEntradaDeLeyenda> leyenda;

  /// Una nota corta debajo de la leyenda.
  final String? nota;

  /// En una línea bajo la rejilla: sin el título ni las cifras, con el aire
  /// justo, para que la rejilla se quede con el alto (13.8). El título sigue
  /// en la etiqueta accesible del bloque.
  final bool compacta;

  @override
  Widget build(BuildContext context) {
    final medidas = BsMedidas.de(context);
    final esquema = Theme.of(context).colorScheme;
    final textos = Theme.of(context).textTheme;
    if (compacta) {
      return Semantics(
        container: true,
        label: titulo,
        child: Container(
          padding: EdgeInsets.all(medidas.espacioS),
          decoration: BoxDecoration(
            color: esquema.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(medidas.radioHoja),
            border: Border.all(color: esquema.outlineVariant),
          ),
          child: Wrap(
            spacing: medidas.espacioS,
            runSpacing: medidas.espacioXs,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              for (final entrada in leyenda) _ChipDeLeyenda(entrada: entrada),
              if (nota != null) Text(nota!, style: textos.bodySmall),
            ],
          ),
        ),
      );
    }
    return Container(
      padding: EdgeInsets.all(medidas.dentroDeBloque),
      decoration: BoxDecoration(
        color: esquema.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(medidas.radioHoja),
        border: Border.all(color: esquema.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Wrap(
            spacing: medidas.espacioL,
            runSpacing: medidas.espacioS,
            crossAxisAlignment: WrapCrossAlignment.end,
            children: <Widget>[
              Text(titulo, style: textos.titleMedium),
              for (final cifra in cifras)
                Semantics(
                  label: '${cifra.rotulo}: ${cifra.valor}',
                  excludeSemantics: true,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        cifra.valor,
                        style: textos.titleMedium
                            ?.copyWith(fontFeatures: cifrasTabulares),
                      ),
                      Text(cifra.rotulo, style: textos.labelSmall),
                    ],
                  ),
                ),
            ],
          ),
          if (leyenda.isNotEmpty) ...<Widget>[
            SizedBox(height: medidas.espacioM),
            Wrap(
              spacing: medidas.espacioS,
              runSpacing: medidas.espacioXs,
              children: <Widget>[
                for (final entrada in leyenda) _ChipDeLeyenda(entrada: entrada),
              ],
            ),
          ],
          if (nota != null) ...<Widget>[
            SizedBox(height: medidas.espacioS),
            Text(nota!, style: textos.bodySmall),
          ],
        ],
      ),
    );
  }
}

class _ChipDeLeyenda extends StatelessWidget {
  const _ChipDeLeyenda({required this.entrada});

  final BsEntradaDeLeyenda entrada;

  @override
  Widget build(BuildContext context) {
    final medidas = BsMedidas.de(context);
    final esquema = Theme.of(context).colorScheme;
    final textos = Theme.of(context).textTheme;
    final tocable = entrada.onTap != null;
    final cuenta = entrada.cuenta;
    final contenido = Container(
      constraints: BoxConstraints(
        minHeight: tocable ? medidas.objetivoTactil : medidas.alturaChip,
      ),
      padding: EdgeInsets.symmetric(horizontal: medidas.espacioS),
      decoration: BoxDecoration(
        color: entrada.activa ? esquema.primaryContainer : null,
        borderRadius: BorderRadius.circular(medidas.radioControl),
        border: Border.all(
          color: entrada.activa ? esquema.primary : esquema.outlineVariant,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (entrada.rol != null)
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: entrada.rol!.relleno,
                borderRadius: BorderRadius.circular(medidas.radioCelda),
                border: Border.all(color: entrada.rol!.contorno),
              ),
            )
          else if (entrada.icono != null)
            Icon(entrada.icono, size: 16, color: esquema.onSurfaceVariant),
          SizedBox(width: medidas.espacioS - 2),
          Text(entrada.rotulo, style: textos.labelMedium),
          if (cuenta != null) ...<Widget>[
            SizedBox(width: medidas.espacioXs),
            Text(
              '$cuenta',
              style: textos.labelMedium?.copyWith(
                color: esquema.onSurfaceVariant,
                fontFeatures: cifrasTabulares,
              ),
            ),
          ],
        ],
      ),
    );
    final etiqueta =
        '${entrada.rotulo}${cuenta == null ? '' : ', $cuenta'}';
    if (!tocable) {
      return Semantics(label: etiqueta, excludeSemantics: true, child: contenido);
    }
    return Semantics(
      button: true,
      selected: entrada.activa,
      label: etiqueta,
      onTap: entrada.onTap,
      excludeSemantics: true,
      child: InkWell(
        onTap: entrada.onTap,
        borderRadius: BorderRadius.circular(medidas.radioControl),
        child: contenido,
      ),
    );
  }
}
