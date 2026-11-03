/// T-132 · Elecciones de la oficina para esta salida, sin alterar las fuentes.
enum DepartureChoice { plan, list }

class DepartureDecision {
  final String id;
  final String container;
  final int order;
  final String subject;
  final String message;

  const DepartureDecision({
    required this.id,
    required this.container,
    required this.order,
    required this.subject,
    required this.message,
  });
}

/// El listado no declara unidades en su encabezado REEFER TEMP. Un valor
/// numérico se interpreta en Celsius; CEL/C y FAH/F explícitos se respetan.
/// Cualquier otro texto se informa: nunca se convierte en una temperatura 0.
class DepartureTemperature {
  final double value;
  final String unit;
  const DepartureTemperature(this.value, this.unit);

  static DepartureTemperature? parse(String text) {
    final match = RegExp(
      r'^\s*([+-]?\d+(?:[.,]\d+)?)\s*°?\s*(CEL|C|FAH|F)?\s*$',
      caseSensitive: false,
    ).firstMatch(text);
    if (match == null) return null;
    final value = double.tryParse(match[1]!.replaceAll(',', '.'));
    if (value == null || !value.isFinite) return null;
    return DepartureTemperature(
      value,
      {'FAH', 'F'}.contains(match[2]?.toUpperCase()) ? 'FAH' : 'CEL',
    );
  }

  static DepartureTemperature? fromSegment(String segment) {
    final parts = segment.split('+').elementAtOrNull(2)?.split(':');
    if (parts == null || parts.length < 2) return null;
    return parse('${parts[0]} ${parts[1]}');
  }

  double get celsius => unit == 'FAH' ? (value - 32) * 5 / 9 : value;
  bool sameAs(DepartureTemperature other) =>
      (celsius - other.celsius).abs() < 0.0000001;
  String get number => value == value.truncateToDouble()
      ? value.toInt().toString()
      : value.toString();
  String get label => '$number ${unit == 'FAH' ? '°F' : '°C'}';
  String get segment => 'TMP+2+$number:$unit';
}

/// El lector guarda cada byte como un carácter (String.fromCharCodes).
/// La salida invierte esa operación; no vuelve a codificar los bytes del plan.
/// Los datos nuevos sí se validan contra el repertorio declarado en UNB.
class DepartureCharacterSet {
  final String code;
  const DepartureCharacterSet(this.code);

  static DepartureCharacterSet fromSource(String source) {
    final match = RegExp(
      r"(?:^|[\r\n'])(?:\s*)UNB\+([^:+']+)",
    ).firstMatch(source);
    return DepartureCharacterSet(match?[1] ?? 'sin declarar');
  }

  bool get supported => const {'UNOA', 'UNOB', 'UNOC'}.contains(code);

  bool accepts(int rune) => switch (code) {
        'UNOA' => RegExp(
            r"^[A-Z0-9 .,'()+\-/:=?]$",
          ).hasMatch(String.fromCharCode(rune)),
        'UNOB' => RegExp(r'''^[A-Za-z0-9 .,'()+\-/:=?!"%&*;<>]$''')
            .hasMatch(String.fromCharCode(rune)),
        'UNOC' => (rune >= 32 && rune <= 126) || (rune >= 160 && rune <= 255),
        _ => false,
      };

  static List<int> bytes(String text) {
    if (text.codeUnits.any((byte) => byte > 255)) {
      throw StateError(
        'La salida contiene caracteres sin codificar: no se '
        'guardó el BAPLIE. Revisa los avisos del listado.',
      );
    }
    return text.codeUnits;
  }
}
