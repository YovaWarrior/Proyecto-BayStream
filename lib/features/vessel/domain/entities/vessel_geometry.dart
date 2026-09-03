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
/// La demostración concreta está en el corpus: el plano impreso del MIZAR
/// tiene seis niveles de cubierta (80 a 90) y en los siete archivos el nivel
/// 80 no aparece ocupado ni una sola vez.
class VesselGeometry extends Equatable {
  /// Fila central del buque. Existe siempre, aunque el viaje no la cargue.
  static const int centerRow = 0;

  /// Primer nivel de bodega según la numeración ISO.
  static const int firstHoldTier = 2;

  /// Primer nivel de cubierta según la numeración ISO.
  static const int firstDeckTier = 80;

  /// Paso entre niveles consecutivos (los impares son de contenedores altos).
  static const int tierStep = 2;

  /// Filas a babor: las pares 02, 04, ... sin contar la fila central.
  final int portRows;

  /// Filas a estribor: las impares 01, 03, ...
  final int starboardRows;

  /// Niveles de bodega: 02, 04, ... por debajo de la línea de cubierta.
  final int holdTiers;

  /// Niveles de cubierta: 80, 82, ... por encima de la línea de cubierta.
  final int deckTiers;

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

  /// Niveles de cubierta de arriba hacia abajo: 90, 88, ... 80.
  List<int> get deckTierNumbers => [
        for (var i = deckTiers - 1; i >= 0; i--) firstDeckTier + i * tierStep,
      ];

  /// Niveles de bodega de arriba hacia abajo: 14, 12, ... 02.
  List<int> get holdTierNumbers => [
        for (var i = holdTiers - 1; i >= 0; i--) firstHoldTier + i * tierStep,
      ];

  /// Total de niveles declarados, cubierta más bodega.
  int get totalTiers => deckTiers + holdTiers;

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

    if (tier >= firstDeckTier) {
      return deckTiers > 0 &&
          tier <= firstDeckTier + (deckTiers - 1) * tierStep;
    }
    return holdTiers > 0 && tier <= firstHoldTier + (holdTiers - 1) * tierStep;
  }

  /// Indica si esta geometría es igual o mayor que [minimum] en los cuatro
  /// parámetros deducibles. Declarar menos que el mínimo observado dejaría
  /// carga real fuera del plano.
  bool isAtLeast(VesselGeometry minimum) =>
      portRows >= minimum.portRows &&
      starboardRows >= minimum.starboardRows &&
      holdTiers >= minimum.holdTiers &&
      deckTiers >= minimum.deckTiers;

  /// Deduce del archivo la geometría **mínima** compatible con la carga.
  ///
  /// Se ancla en la numeración ISO y toma el **máximo observado**, no la
  /// cantidad de valores distintos. Esa diferencia es la que rescata los
  /// niveles vacíos intermedios: con carga hasta el nivel 90 propone seis
  /// niveles de cubierta, incluido el 80 que el corpus nunca trae ocupado.
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
      holdTiers: maxHoldTier == null
          ? 0
          : math.max(1, (maxHoldTier - firstHoldTier) ~/ tierStep + 1),
      deckTiers: maxDeckTier == null
          ? 0
          : math.max(1, (maxDeckTier - firstDeckTier) ~/ tierStep + 1),
    );
  }

  @override
  List<Object?> get props =>
      [portRows, starboardRows, holdTiers, deckTiers, stackWeightLimitKg];

  VesselGeometry copyWith({
    int? portRows,
    int? starboardRows,
    int? holdTiers,
    int? deckTiers,
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
        holdTiers: json['holdTiers'] as int,
        deckTiers: json['deckTiers'] as int,
        stackWeightLimitKg: (json['stackWeightLimitKg'] as num?)?.toDouble(),
      );

  @override
  String toString() => 'VesselGeometry(${orderedRows.length} filas, '
      '$deckTiers cubierta + $holdTiers bodega = $slotsPerBay huecos)';
}
