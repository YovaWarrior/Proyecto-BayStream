import 'imdg_42_24_data.dart';

enum SegregationCode {
  substance,
  away,
  separated,
  compartment,
  longitudinal,
  compatibility
}

class SegregationRules {
  SegregationRules._();
  static const disclaimer =
      'Fuente: Código IMDG, Enmienda 42-24 (7.2.4 y 7.4.3.2). '
      'Apoyo a la decisión, no verificación de cumplimiento. '
      'No se evalúa la columna 16b de la Lista de mercancías peligrosas, '
      'que tiene prioridad (7.2.3.1), ni los mamparos ni la resistencia de '
      'las cubiertas. Las distancias se derivan de huecos, no se miden.';
  static const classes = Imdg4224Data.classes;

  /// Normaliza la clase declarada, sin inferirla del número ONU.
  static String? classRow(String? declared) {
    final value = (declared ?? '').trim().toUpperCase();
    if (classes.contains(value)) return value;
    final m = RegExp(r'^1\.([1-6])[A-Z]?$').firstMatch(value);
    if (m == null) return null;
    return switch (m[1]) {
      '1' || '2' || '5' => classes[0],
      '3' || '6' => classes[1],
      _ => '1.4',
    };
  }

  static SegregationCode? code(String a, String b) {
    final ra = classRow(a), rb = classRow(b);
    if (ra == null || rb == null) return null;
    return switch (Imdg4224Data.matrix[classes.indexOf(ra)]
        [classes.indexOf(rb)]) {
      '1' => SegregationCode.away,
      '2' => SegregationCode.separated,
      '3' => SegregationCode.compartment,
      '4' => SegregationCode.longitudinal,
      '*' => SegregationCode.compatibility,
      _ => SegregationCode.substance,
    };
  }

  static int requirement(SegregationCode code) => switch (code) {
        SegregationCode.away => 1,
        SegregationCode.separated => 2,
        SegregationCode.compartment => 3,
        SegregationCode.longitudinal => 4,
        _ => 0,
      };
  static String symbol(SegregationCode code) => switch (code) {
        SegregationCode.substance => 'X',
        SegregationCode.compatibility => '*',
        _ => '${requirement(code)}',
      };
}
