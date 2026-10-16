/// Datos funcionales del IMDG 42-24, 7.2.4 y 7.4.3.2.
/// Solo codigos, cotejables con tool/t85_tabla_privada.dart; sin texto del Codigo.
enum ImdgUnitPair { closedClosed, closedOpen, openOpen }

enum ImdgAxis { longitudinal, transverse }

enum ImdgVerticalRule { stacked, openAboveClosed, deck, forbidden }

enum ImdgHorizontalRule {
  none,
  space1,
  space1OrBulkhead,
  bulkhead1,
  space2,
  bulkhead2,
  space3,
  meters24,
  bulkheadAnd24,
  forbidden
}

class Imdg4224Data {
  Imdg4224Data._();
  static const classes = [
    '1.1/1.2/1.5',
    '1.3/1.6',
    '1.4',
    '2.1',
    '2.2',
    '2.3',
    '3',
    '4.1',
    '4.2',
    '4.3',
    '5.1',
    '5.2',
    '6.1',
    '6.2',
    '7',
    '8',
    '9',
  ];
  // Filas y columnas en el orden de classes. X no afirma conformidad.
  static const matrix = [
    '***4224444442424X',
    '***4224334442422X',
    '***211222222X422X',
    '442XXX212222X421X',
    '221XXX1X1XX1X21XX',
    '221XXX2X2XX2X21XX',
    '442212XX2222X32XX',
    '4321XXXX1X12X321X',
    '43221221X1221321X',
    '4422XX2X1X22X221X',
    '4422XX2122X21312X',
    '44221222222X1322X',
    '22XXXXXX1X11X1XXX',
    '4444223332331X33X',
    '222211222212X3X2X',
    '4221XXX11122X32XX',
    'XXXXXXXXXXXXXXXXX',
  ];
  // Exigencias 1..4, pares CC, CO, OO.
  static const vertical = [
    [
      ImdgVerticalRule.stacked,
      ImdgVerticalRule.openAboveClosed,
      ImdgVerticalRule.deck
    ],
    [ImdgVerticalRule.deck, ImdgVerticalRule.deck, ImdgVerticalRule.deck],
    [ImdgVerticalRule.deck, ImdgVerticalRule.deck, ImdgVerticalRule.deck],
    [
      ImdgVerticalRule.forbidden,
      ImdgVerticalRule.forbidden,
      ImdgVerticalRule.forbidden
    ],
  ];
  // Por exigencia: longitudinal CC(cubierta,bodega), CO, OO; transversal igual.
  static const horizontal = [
    [
      ImdgHorizontalRule.none,
      ImdgHorizontalRule.none,
      ImdgHorizontalRule.none,
      ImdgHorizontalRule.none,
      ImdgHorizontalRule.space1,
      ImdgHorizontalRule.space1OrBulkhead,
      ImdgHorizontalRule.none,
      ImdgHorizontalRule.none,
      ImdgHorizontalRule.none,
      ImdgHorizontalRule.none,
      ImdgHorizontalRule.space1,
      ImdgHorizontalRule.space1,
    ],
    [
      ImdgHorizontalRule.space1,
      ImdgHorizontalRule.space1OrBulkhead,
      ImdgHorizontalRule.space1,
      ImdgHorizontalRule.space1OrBulkhead,
      ImdgHorizontalRule.space1,
      ImdgHorizontalRule.bulkhead1,
      ImdgHorizontalRule.space1,
      ImdgHorizontalRule.space1,
      ImdgHorizontalRule.space1,
      ImdgHorizontalRule.space2,
      ImdgHorizontalRule.space2,
      ImdgHorizontalRule.bulkhead1,
    ],
    [
      ImdgHorizontalRule.space1,
      ImdgHorizontalRule.bulkhead1,
      ImdgHorizontalRule.space1,
      ImdgHorizontalRule.bulkhead1,
      ImdgHorizontalRule.space2,
      ImdgHorizontalRule.bulkhead2,
      ImdgHorizontalRule.space2,
      ImdgHorizontalRule.bulkhead1,
      ImdgHorizontalRule.space2,
      ImdgHorizontalRule.bulkhead1,
      ImdgHorizontalRule.space3,
      ImdgHorizontalRule.bulkhead2,
    ],
    [
      ImdgHorizontalRule.meters24,
      ImdgHorizontalRule.bulkheadAnd24,
      ImdgHorizontalRule.meters24,
      ImdgHorizontalRule.bulkhead2,
      ImdgHorizontalRule.meters24,
      ImdgHorizontalRule.bulkhead2,
      ImdgHorizontalRule.forbidden,
      ImdgHorizontalRule.forbidden,
      ImdgHorizontalRule.forbidden,
      ImdgHorizontalRule.forbidden,
      ImdgHorizontalRule.forbidden,
      ImdgHorizontalRule.forbidden,
    ],
  ];
  static ImdgHorizontalRule horizontalRule(
          int requirement, ImdgAxis axis, ImdgUnitPair pair,
          {required bool onDeck}) =>
      horizontal[requirement - 1]
          [axis.index * 6 + pair.index * 2 + (onDeck ? 0 : 1)];
}
