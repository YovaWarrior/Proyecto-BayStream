import 'dart:math' as math;

import 'package:equatable/equatable.dart';
import '../../../../core/utils/iso_coordinate_parser.dart';

/// Geometría declarada del buque: la rejilla contra la que se dibuja el plano
/// y se calcula la ocupación.
///
/// El archivo BAPLIE **no transmite las dimensiones del buque**; solo revela
/// los slots que este viaje trae ocupados. Por eso `proposeFrom` devuelve
/// siempre una **cota inferior**: la geometría real es mayor o igual, nunca
/// menor. La confirma o la corrige el usuario.
///
/// Lo que sí queda fijo es dónde **empieza** cada zona, porque la numeración
/// ISO la ancla: la bodega en el nivel 02 y la cubierta en el 82. La primera
/// fila de contenedores sobre cubierta va en el 82.
class VesselGeometry extends Equatable {
  /// Fila central del buque. Existe siempre, aunque el viaje no la cargue.
  static const int centerRow = 0;

  /// Primer nivel de bodega según la numeración ISO.
  static const int firstHoldTier = 2;

  /// Primer nivel de cubierta según la numeración ISO.
  ///
  /// La primera fila de contenedores sobre cubierta va en el **82**, no en el
  /// 80. Evidencia en el corpus: de 4 584 slots ocupados en los seis archivos,
  /// el nivel 80 no aparece **ni una sola vez**, y el nivel más bajo con carga
  /// es el 82 en 45 bahías. El contraste con la bodega lo confirma: allí el
  /// nivel ancla 02 sí es el piso más común, con 66 bahías. Anclar la cubierta
  /// en el 80 dibujaba una fila vacía fantasma bajo toda la carga.
  static const int firstDeckTier = 82;

  /// Paso entre niveles consecutivos (los impares son de contenedores altos).
  static const int tierStep = 2;

  /// Filas a babor: las pares 02, 04, ... sin contar la fila central.
  final int portRows;

  /// Filas a estribor: las impares 01, 03, ...
  final int starboardRows;

  /// Niveles de bodega declarados, por su número: 02, 04, 06...
  ///
  /// Se guardan los números y no una cuenta porque un buque puede no tener un
  /// nivel intermedio. La **propuesta** que calcula `proposeFrom` es siempre la
  /// corrida contigua anclada; solo la corrección manual admite huecos. Si la
  /// propuesta pasara a ser «los niveles distintos que trae el archivo»,
  /// volveríamos a inventar geometrías con agujeros que el buque no tiene.
  final List<int> holdTiers;

  /// Niveles de cubierta declarados, por su número: 82, 84, 86...
  /// Ver [holdTiers].
  final List<int> deckTiers;

  /// Límite de apilamiento en kilogramos.
  ///
  /// Es el único parámetro que **no se deduce del archivo**: viene del manual
  /// de estabilidad del buque. `null` significa que el usuario declaró no
  /// tenerlo, y entonces no se muestra ninguna alerta de peso — antes que
  /// inventar un umbral.
  final double? stackWeightLimitKg;

  const VesselGeometry({
    required this.portRows,
    required this.starboardRows,
    required this.holdTiers,
    required this.deckTiers,
    this.stackWeightLimitKg,
  });

  /// Números de fila a babor, de fuera hacia el centro: 12, 10, ... 02.
  List<int> get portRowNumbers =>
      [for (var i = portRows; i >= 1; i--) i * 2];

  /// Números de fila a estribor, del centro hacia fuera: 01, 03, ... 11.
  List<int> get starboardRowNumbers =>
      [for (var i = 1; i <= starboardRows; i++) i * 2 - 1];

  /// Orden fijo de columnas del plano: pares descendentes, la fila central,
  /// e impares ascendentes. Es el orden de la hoja impresa.
  ///
  /// La fila central se dibuja siempre, venga ocupada o no.
  List<int> get orderedRows =>
      [...portRowNumbers, centerRow, ...starboardRowNumbers];

  /// Niveles de cubierta de arriba hacia abajo: 90, 88, ... 82.
  List<int> get deckTierNumbers =>
      [...deckTiers]..sort((a, b) => b.compareTo(a));

  /// Niveles de bodega de arriba hacia abajo: 14, 12, ... 02.
  List<int> get holdTierNumbers =>
      [...holdTiers]..sort((a, b) => b.compareTo(a));

  /// Total de niveles declarados, cubierta más bodega.
  int get totalTiers => deckTiers.length + holdTiers.length;

  /// Huecos por bahía: columnas por niveles. Es el denominador de la ocupación.
  int get slotsPerBay => orderedRows.length * totalTiers;

  /// Indica si la geometría declarada contiene esta posición de estiba.
  bool covers(IsoCoordinate position) {
    final row = position.row;
    final tier = position.tier;

    final rowFits = row == centerRow
        ? true
        : row.isEven
            ? row <= portRows * 2
            : row <= starboardRows * 2 - 1;
    if (!rowFits) return false;

    return tier >= firstDeckTier
        ? deckTiers.contains(tier)
        : holdTiers.contains(tier);
  }

  /// Indica si la geometría declarada contiene toda la carga del archivo.
  ///
  /// Es el invariante que sostiene la edición manual: el usuario puede quitar
  /// un nivel que el buque no tenga, pero no uno donde este viaje trae carga.
  bool coversAll(Iterable<IsoCoordinate> positions) => positions.every(covers);

  /// Deduce del archivo la geometría **mínima** compatible con la carga.
  ///
  /// Se ancla en la numeración ISO y toma el **máximo observado**, no la
  /// cantidad de valores distintos. Esa diferencia es la que rescata los
  /// niveles vacíos **intermedios**: una bahía cargada en 82 y 86 pero no en
  /// 84 propone igual los tres niveles, porque el 84 existe aunque hoy esté
  /// vacío. Lo que la deducción no hace es inventar niveles por debajo del
  /// ancla.
  ///
  /// El límite de apilamiento nunca se propone.
  factory VesselGeometry.proposeFrom(Iterable<IsoCoordinate> positions) {
    var maxPortRow = 0;
    var maxStarboardRow = 0;
    int? maxHoldTier;
    int? maxDeckTier;

    for (final position in positions) {
      final row = position.row;
      if (row != centerRow) {
        if (row.isEven) {
          maxPortRow = math.max(maxPortRow, row);
        } else {
          maxStarboardRow = math.max(maxStarboardRow, row);
        }
      }

      final tier = position.tier;
      if (tier >= firstDeckTier) {
        maxDeckTier = math.max(maxDeckTier ?? tier, tier);
      } else {
        maxHoldTier = math.max(maxHoldTier ?? tier, tier);
      }
    }

    return VesselGeometry(
      portRows: maxPortRow ~/ 2,
      starboardRows: (maxStarboardRow + 1) ~/ 2,
      holdTiers: _anchoredRun(firstHoldTier, maxHoldTier),
      deckTiers: _anchoredRun(firstDeckTier, maxDeckTier),
    );
  }

  /// Corrida contigua desde [anchor] hasta [maxObserved], de dos en dos.
  ///
  /// Vacía si el archivo no trae carga en esa zona. Si el máximo observado
  /// queda por debajo del ancla —un nivel que la numeracion ISO no contempla—
  /// la corrida sale vacia y esa carga aparece en el aviso de la rejilla, que
  /// es donde corresponde: no se silencia ni se fuerza un nivel inventado.
  static List<int> _anchoredRun(int anchor, int? maxObserved) {
    if (maxObserved == null || maxObserved < anchor) return const [];
    return [for (var t = anchor; t <= maxObserved; t += tierStep) t];
  }

  @override
  List<Object?> get props =>
      [portRows, starboardRows, holdTiers, deckTiers, stackWeightLimitKg];

  VesselGeometry copyWith({
    int? portRows,
    int? starboardRows,
    List<int>? holdTiers,
    List<int>? deckTiers,
    double? stackWeightLimitKg,
  }) {
    return VesselGeometry(
      portRows: portRows ?? this.portRows,
      starboardRows: starboardRows ?? this.starboardRows,
      holdTiers: holdTiers ?? this.holdTiers,
      deckTiers: deckTiers ?? this.deckTiers,
      stackWeightLimitKg: stackWeightLimitKg ?? this.stackWeightLimitKg,
    );
  }

  /// Devuelve una copia sin límite de apilamiento declarado.
  VesselGeometry withoutStackWeightLimit() => VesselGeometry(
        portRows: portRows,
        starboardRows: starboardRows,
        holdTiers: holdTiers,
        deckTiers: deckTiers,
      );

  Map<String, dynamic> toJson() => {
        'portRows': portRows,
        'starboardRows': starboardRows,
        'holdTiers': holdTiers,
        'deckTiers': deckTiers,
        if (stackWeightLimitKg != null)
          'stackWeightLimitKg': stackWeightLimitKg,
      };

  factory VesselGeometry.fromJson(Map<String, dynamic> json) => VesselGeometry(
        portRows: json['portRows'] as int,
        starboardRows: json['starboardRows'] as int,
        holdTiers: (json['holdTiers'] as List<dynamic>).cast<int>(),
        deckTiers: (json['deckTiers'] as List<dynamic>).cast<int>(),
        stackWeightLimitKg: (json['stackWeightLimitKg'] as num?)?.toDouble(),
      );

  @override
  String toString() => 'VesselGeometry(${orderedRows.length} filas, '
      '$deckTiers cubierta + $holdTiers bodega = $slotsPerBay huecos)';
}
