import '../entities/entities.dart';
import 'iso6346_check_digit.dart';

/// T-147, entrega 2, parte 2b (P5; 10.160, D11) · Una matrícula que el plan
/// trae en más de una celda.
///
/// Un contenedor solo puede estar en una. La operación guarda una pieza por
/// matrícula (`C:<matrícula>`), así que de las celdas de una repetida se queda
/// con la última del archivo ([kept]) y las demás ([extras]) no se pueden
/// operar: ni cargar, ni descargar, ni cancelar.
class RepeatedContainer {
  final String containerId;

  /// Las celdas, en el orden del archivo, como códigos ISO de siete cifras.
  final List<String> positions;

  RepeatedContainer(this.containerId, Iterable<String> positions)
      : positions = List.unmodifiable(positions);

  /// La celda con la que se queda la operación: la última del archivo.
  String get kept => positions.last;

  /// Las celdas que la operación no puede operar.
  Iterable<String> get extras => positions.take(positions.length - 1);

  /// «018-01-82 y 018-00-82».
  String get cells => RepeatedContainers.joined(positions);

  /// Las demás celdas, vistas desde [position]: «018-00-82».
  String othersThan(String position) => RepeatedContainers.joined(
      [for (final p in positions) if (p != position) p]);
}

class RepeatedContainers {
  const RepeatedContainers._();

  /// Las matrículas repetidas de [plan], con la misma regla del lector
  /// (`BaplieReadNoticeKind.duplicate`): con forma de matrícula ISO 6346 y en
  /// más de una celda. Un texto sin esa forma repetido no es un contenedor
  /// (10.151, regla 2) y no cuenta. Una matrícula que está una vez en el
  /// plano de llegada y una vez en el plan de carga no es repetida: aquí se
  /// mira un solo archivo.
  static List<RepeatedContainer> of(VesselVoyage? plan) {
    if (plan == null) return const [];
    final cells = <String, List<String>>{};
    for (final c in plan.containers) {
      final position = c.stowagePosition;
      if (position == null) continue;
      if (Iso6346CheckDigit.isValid(c.containerId) == null) continue;
      cells.putIfAbsent(c.containerId, () => []).add(position.toIsoCode());
    }
    return [
      for (final entry in cells.entries)
        if (entry.value.length > 1) RepeatedContainer(entry.key, entry.value)
    ];
  }

  /// Las celdas que la operación no puede operar, con su matrícula.
  static Map<String, RepeatedContainer> extraCells(
          Iterable<RepeatedContainer> repeated) =>
      {
        for (final r in repeated)
          for (final position in r.extras) position: r
      };

  /// «0180182» → «018-01-82».
  static String cell(String position) => position.length != 7
      ? position
      : '${position.substring(0, 3)}-${position.substring(3, 5)}-'
          '${position.substring(5)}';

  static String joined(List<String> positions) {
    final cells = [for (final p in positions) cell(p)];
    if (cells.length < 2) return cells.join();
    return '${cells.sublist(0, cells.length - 1).join(', ')} y ${cells.last}';
  }

  /// «1 matrícula» · «2 matrículas».
  static String count(int n) => n == 1 ? '1 matrícula' : '$n matrículas';

  /// Por qué un plan con matrículas repetidas no entra a la nube, o nulo si
  /// no trae ninguna. [action] es «No se publica» o «No se agrega».
  static String? refusal(
    String action, {
    required String sourceName,
    required String fileName,
    required List<RepeatedContainer> repeated,
  }) {
    if (repeated.isEmpty) return null;
    const shown = 3;
    final named = [
      for (final r in repeated.take(shown)) '${r.containerId} en ${r.cells}'
    ].join('; ');
    final more = repeated.length - shown;
    return '$action: el $sourceName («$fileName») trae '
        '${count(repeated.length)} en más de una celda: $named'
        '${more > 0 ? '; y $more más' : ''}. Un contenedor solo puede estar '
        'en una. Pide el plan corregido a quien lo hizo y ábrelo de nuevo.';
  }

  /// La ficha fija del modo, en el equipo que opera solo: cuántas no se
  /// pueden registrar. [what] es «carga» o «descarga».
  static String? band(List<RepeatedContainer> repeated,
      {required String what}) {
    if (repeated.isEmpty) return null;
    final lost = extraCells(repeated).length;
    final repetidas = repeated.length == 1
        ? '1 matrícula repetida'
        : '${repeated.length} matrículas repetidas';
    final perdidas = lost == 1
        ? 'una $what no se puede registrar'
        : '$lost ${what}s no se pueden registrar';
    return 'Plan con $repetidas: $perdidas. Pide el plan corregido.';
  }

  /// Lo que responde la celda que no se puede operar.
  static String cellMessage(RepeatedContainer repeated, String position) =>
      'El plan trae ${repeated.containerId} también en '
      '${repeated.othersThan(position)}. Esta celda no se puede operar hasta '
      'abrir el plan corregido.';

  /// El aviso de la salida: la matrícula sale en un solo grupo.
  static String departureWarning(RepeatedContainer repeated,
          {required String sourceName}) =>
      '${repeated.containerId}: el $sourceName lo trae en '
      '${repeated.positions.length} celdas (${repeated.cells}). Un contenedor '
      'solo puede estar en una: la salida escribe un solo grupo para esa '
      'matrícula. Pide el plan corregido.';
}
