import '../../../../core/utils/iso_coordinate_parser.dart';
import '../entities/vessel_geometry.dart';

/// T-56 · Carga de tomas de reefer por rangos y por lista pegada.
///
/// Genera los códigos BBBRRTT **de las bahías tal como se escriben**, sin
/// calcular pares: quien sabe el extremo escribe las impares, y quien no, las
/// pares (T-55: la correspondencia par ↔ impares es del buque). Cargar no
/// declara: la declaración sigue en la casilla de la pantalla.
class ReeferSocketRanges {
  const ReeferSocketRanges._();

  /// Tope de códigos por operación, para que un rango mal escrito no congele
  /// la pantalla. Un buque grande tiene cientos de tomas, no decenas de miles.
  static const maxCodes = 20000;

  /// Lee números y rangos con paso: `002-038/4, 041, 044`.
  ///
  /// Separados por comas o espacios. Un rango sin paso usa [defaultStep]. Vacío
  /// devuelve una lista vacía; quien llama decide si eso es «todas».
  static ({List<int> values, String? error}) parseNumbers(
    String text, {
    required String field,
    required int max,
    int min = 0,
    int defaultStep = 1,
  }) {
    final normalized = text
        .replaceAll(RegExp('[–—]'), '-')
        .replaceAll(RegExp(r'\s*-\s*'), '-')
        .replaceAll(RegExp(r'\s*/\s*'), '/');
    final tokens = normalized
        .split(RegExp(r'[,;\s]+'))
        .where((t) => t.isNotEmpty)
        .toList();
    final values = <int>{};
    final pattern = RegExp(r'^(\d{1,3})(?:-(\d{1,3})(?:/(\d{1,3}))?)?$');
    for (final token in tokens) {
      final match = pattern.firstMatch(token);
      if (match == null) {
        return (
          values: const <int>[],
          error: '$field: «$token» no es un número ni un rango como 02-08. '
              'Escribe un número o un rango así.'
        );
      }
      final from = int.parse(match.group(1)!);
      final to = match.group(2) == null ? from : int.parse(match.group(2)!);
      final step =
          match.group(3) == null ? defaultStep : int.parse(match.group(3)!);
      if (from < min || to > max) {
        return (
          values: const <int>[],
          error: '$field: «$token» sale de ${_pad(min, max)} a ${_pad(max, max)}. '
              'Escribe valores entre esos dos.'
        );
      }
      if (to < from) {
        return (
          values: const <int>[],
          error: '$field: en «$token» el final es menor que el inicio: escribe '
              'primero el menor.'
        );
      }
      if (step < 1) {
        return (
          values: const <int>[],
          error: '$field: en «$token» el paso tiene que ser 1 o más: escríbelo así, '
              'como 002-038/4.'
        );
      }
      for (var v = from; v <= to; v += step) {
        values.add(v);
      }
    }
    return (values: values.toList()..sort(), error: null);
  }

  static String _pad(int value, int max) =>
      value.toString().padLeft(max > 99 ? 3 : 2, '0');

  /// Códigos del rango: cada bahía por cada fila y cada nivel.
  ///
  /// Filas vacías o «todas» son las de la geometría; la fila 00 entra solo si
  /// la zona la declara, porque sin declaración el buque puede no tenerla.
  /// Los niveles van de dos en dos por omisión, como la numeración ISO.
  static ({List<String> codes, String? error}) codesFor({
    required String bays,
    required String rows,
    required String tiers,
    required VesselGeometry geometry,
  }) {
    if (bays.trim().isEmpty) {
      return (
        codes: const <String>[],
        error: 'Faltan las bahías: escribe al menos una.'
      );
    }
    if (tiers.trim().isEmpty) {
      return (
        codes: const <String>[],
        error: 'Faltan los niveles: escribe al menos uno.'
      );
    }
    final bayList =
        parseNumbers(bays, field: 'Bahías', min: 1, max: 999);
    if (bayList.error != null) {
      return (codes: const <String>[], error: bayList.error);
    }
    final allRows =
        rows.trim().isEmpty || rows.trim().toLowerCase() == 'todas';
    final rowList = allRows
        ? (values: geometry.orderedRows, error: null)
        : parseNumbers(rows, field: 'Filas', max: 99);
    if (rowList.error != null) {
      return (codes: const <String>[], error: rowList.error);
    }
    final tierList = parseNumbers(tiers,
        field: 'Niveles', min: 1, max: 99, defaultStep: VesselGeometry.tierStep);
    if (tierList.error != null) {
      return (codes: const <String>[], error: tierList.error);
    }
    final total = bayList.values.length *
        rowList.values.length *
        tierList.values.length;
    if (total > maxCodes) {
      return (
        codes: const <String>[],
        error: 'El rango genera $total códigos; el máximo es $maxCodes. '
            'Acótalo.'
      );
    }
    final codes = <String>[];
    for (final bay in bayList.values) {
      for (final row in rowList.values) {
        for (final tier in tierList.values) {
          if (allRows && row == VesselGeometry.centerRow) {
            final declared = geometry.isDeckTier(tier)
                ? geometry.centerRowOnDeck
                : geometry.centerRowInHold;
            if (declared != true) continue;
          }
          codes.add('${bay.toString().padLeft(3, '0')}'
              '${row.toString().padLeft(2, '0')}'
              '${tier.toString().padLeft(2, '0')}');
        }
      }
    }
    return (codes: codes, error: null);
  }

  /// Códigos pegados, separados por comas, espacios o saltos de línea.
  /// Lo que no es de siete dígitos, o trae la bahía 000, se devuelve aparte.
  static ({List<String> codes, List<String> invalid}) parsePasted(
      String text) {
    final codes = <String>[];
    final invalid = <String>[];
    for (final token in text.split(RegExp(r'[,;\s]+'))) {
      if (token.isEmpty) continue;
      if (RegExp(r'^\d{7}$').hasMatch(token) && !token.startsWith('000')) {
        codes.add(token);
      } else {
        invalid.add(token);
      }
    }
    return (codes: codes, invalid: invalid);
  }

  /// Vista previa de agregar: nuevos, ya existentes y fuera de la geometría.
  static SocketBatchPreview previewAdd(Iterable<String> codes,
      Set<String> current, VesselGeometry geometry,
      {List<String> invalid = const []}) {
    final added = <String>{}, existing = <String>{}, outside = <String>{};
    for (final code in codes) {
      if (!geometry.covers(IsoCoordinateParser.parse(code))) {
        outside.add(code);
      } else if (current.contains(code)) {
        existing.add(code);
      } else {
        added.add(code);
      }
    }
    return SocketBatchPreview._(
      removing: false,
      changed: added.toList()..sort(),
      unchanged: existing.toList()..sort(),
      outside: outside.toList()..sort(),
      invalid: List.unmodifiable(invalid),
    );
  }

  /// Vista previa de quitar: los que estaban y los que no.
  static SocketBatchPreview previewRemove(
      Iterable<String> codes, Set<String> current,
      {List<String> invalid = const []}) {
    final removed = <String>{}, absent = <String>{};
    for (final code in codes) {
      (current.contains(code) ? removed : absent).add(code);
    }
    return SocketBatchPreview._(
      removing: true,
      changed: removed.toList()..sort(),
      unchanged: absent.toList()..sort(),
      outside: const [],
      invalid: List.unmodifiable(invalid),
    );
  }
}

/// Lo que una carga o una corrección haría, antes de aplicarla.
class SocketBatchPreview {
  /// `true` si es «Quitar por rango».
  final bool removing;

  /// Al agregar, los nuevos; al quitar, los que estaban y se quitan.
  final List<String> changed;

  /// Al agregar, los que ya estaban; al quitar, los que no estaban.
  final List<String> unchanged;

  /// Fila o nivel fuera de la geometría: se descartan al agregar.
  final List<String> outside;

  /// Lo pegado que no es un código de siete dígitos.
  final List<String> invalid;

  const SocketBatchPreview._({
    required this.removing,
    required this.changed,
    required this.unchanged,
    required this.outside,
    required this.invalid,
  });

  /// El conjunto resultante; no cambia el origen de las tomas.
  Set<String> applyTo(Set<String> current) => removing
      ? ({...current}..removeAll(changed))
      : {...current, ...changed};
}
