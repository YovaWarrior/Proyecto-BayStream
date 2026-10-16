import '../entities/container_unit.dart';
import '../entities/vessel_voyage.dart';

/// T-96 · RF-029: qué bajó, qué subió y qué cambió en lo que sigue a bordo.
///
/// Compara dos viajes ya leídos por número de contenedor. No publica, no
/// guarda ni lee archivos: es un cálculo sobre lo que el lector entregó.
enum ComparedField {
  position('Posición'),
  isoType('ISO'),
  status('Lleno o vacío'),
  portOfLoading('POL'),
  portOfDischarge('POD'),
  operator('Línea'),
  weight('Peso'),
  dangerousGoods('Peligrosas'),
  temperature('Temperatura');

  const ComparedField(this.label);
  final String label;
}

/// Un campo distinto entre los dos archivos. `null` es «sin dato».
class FieldChange {
  final ComparedField field;
  final Object? before;
  final Object? after;
  const FieldChange(this.field, this.before, this.after);
}

/// Un contenedor que está en los dos archivos, con lo que cambió.
class PermanentContainer {
  final ContainerUnit first;
  final ContainerUnit second;
  final List<FieldChange> changes;
  PermanentContainer(this.first, this.second, Iterable<FieldChange> changes)
      : changes = List.unmodifiable(changes);
  String get containerId => first.containerId;
  bool get changed => changes.isNotEmpty;
}

class VoyageComparison {
  /// Solo en el primero: lo que bajó.
  final List<ContainerUnit> discharged;

  /// Solo en el segundo: lo que subió.
  final List<ContainerUnit> loaded;

  /// En los dos, ordenados por número.
  final List<PermanentContainer> permanent;

  /// Números repetidos dentro de cada archivo, con su cuenta. No se clasifican.
  final Map<String, int> duplicatesFirst;
  final Map<String, int> duplicatesSecond;

  /// Las reservas no tienen número: se cuentan aparte, en cada archivo.
  final int reservedFirst;
  final int reservedSecond;

  /// `null` si la identidad del buque coincide.
  final String? vesselNotice;

  VoyageComparison._({
    required Iterable<ContainerUnit> discharged,
    required Iterable<ContainerUnit> loaded,
    required Iterable<PermanentContainer> permanent,
    required Map<String, int> duplicatesFirst,
    required Map<String, int> duplicatesSecond,
    required this.reservedFirst,
    required this.reservedSecond,
    required this.vesselNotice,
  })  : discharged = List.unmodifiable(discharged),
        loaded = List.unmodifiable(loaded),
        permanent = List.unmodifiable(permanent),
        duplicatesFirst = Map.unmodifiable(duplicatesFirst),
        duplicatesSecond = Map.unmodifiable(duplicatesSecond);

  /// Permanentes con al menos un campo distinto.
  int get withChanges => permanent.where((p) => p.changed).length;

  /// Cuántos permanentes cambian en cada campo; los que no cambian dan 0.
  Map<ComparedField, int> get changesByField => {
        for (final field in ComparedField.values)
          field: permanent
              .where((p) => p.changes.any((c) => c.field == field))
              .length,
      };

  factory VoyageComparison.compare(VesselVoyage first, VesselVoyage second) {
    final a = _index(first.containers);
    final b = _index(second.containers);
    final permanent = <PermanentContainer>[];
    for (final id in a.unique.keys.where(b.unique.containsKey).toList()..sort()) {
      final before = a.unique[id]!, after = b.unique[id]!;
      permanent.add(PermanentContainer(before, after, _changes(before, after)));
    }
    List<ContainerUnit> only(_Index from, _Index other) => [
          for (final id in from.unique.keys.toList()..sort())
            if (!other.unique.containsKey(id) &&
                !other.duplicates.containsKey(id))
              from.unique[id]!,
        ];
    final sameVessel =
        first.vessel.profileIdentity == second.vessel.profileIdentity;
    return VoyageComparison._(
      discharged: only(a, b),
      loaded: only(b, a),
      permanent: permanent,
      duplicatesFirst: a.duplicates,
      duplicatesSecond: b.duplicates,
      reservedFirst: first.reservedSlots.length,
      reservedSecond: second.reservedSlots.length,
      vesselNotice: sameVessel
          ? null
          : 'No parece el mismo buque: ${first.vessel.name} '
              '(${first.vessel.profileKey}) y ${second.vessel.name} '
              '(${second.vessel.profileKey}).',
    );
  }

  static _Index _index(Iterable<ContainerUnit> containers) {
    final counts = <String, int>{};
    for (final c in containers) {
      counts[c.containerId] = (counts[c.containerId] ?? 0) + 1;
    }
    return _Index(
      unique: {
        for (final c in containers)
          if (counts[c.containerId] == 1) c.containerId: c,
      },
      duplicates: {
        for (final e in counts.entries)
          if (e.value > 1) e.key: e.value,
      },
    );
  }

  /// Valor comparable de cada campo; `null` cuando el archivo no lo trae.
  static Object? valueOf(ContainerUnit c, ComparedField field) =>
      switch (field) {
        ComparedField.position => c.stowagePosition?.toIsoCode(),
        ComparedField.isoType => _text(c.isoSizeType),
        ComparedField.status =>
          c.status == ContainerStatus.unknown ? null : c.status,
        ComparedField.portOfLoading => _text(c.portOfLoading),
        ComparedField.portOfDischarge => _text(c.portOfDischarge),
        ComparedField.operator => _text(c.operatorCode),
        // T-66: el mismo peso que usa la app, el VGM si lo hay.
        ComparedField.weight => c.effectiveWeight,
        ComparedField.dangerousGoods => _dangerous(c),
        ComparedField.temperature => c.temperature == null
            ? null
            : '${c.temperature} ${c.temperatureUnit ?? ''}'.trim(),
      };

  static String? _text(String? value) =>
      value == null || value.trim().isEmpty ? null : value.trim();

  /// Números ONU y clases, ordenados, para que el orden de los DGS no cuente.
  static String? _dangerous(ContainerUnit c) {
    final items = <String>{
      for (final d in c.dangerousGoods ?? const [])
        [
          if (_text(d.unNumber) != null) 'UN${d.unNumber!.trim()}',
          if (_text(d.hazardClass) != null) d.hazardClass!.trim(),
        ].join(' '),
      if ((c.dangerousGoods ?? const []).isEmpty &&
          (_text(c.unNumber) != null || _text(c.imdgClass) != null))
        [
          if (_text(c.unNumber) != null) 'UN${c.unNumber!.trim()}',
          if (_text(c.imdgClass) != null) c.imdgClass!.trim(),
        ].join(' '),
    }..removeWhere((s) => s.isEmpty);
    if (items.isEmpty) return null;
    return (items.toList()..sort()).join(', ');
  }

  static List<FieldChange> _changes(ContainerUnit a, ContainerUnit b) => [
        for (final field in ComparedField.values)
          if (valueOf(a, field) != valueOf(b, field))
            FieldChange(field, valueOf(a, field), valueOf(b, field)),
      ];
}

class _Index {
  final Map<String, ContainerUnit> unique;
  final Map<String, int> duplicates;
  _Index({required this.unique, required this.duplicates});
}
