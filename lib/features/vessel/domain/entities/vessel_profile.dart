import 'package:equatable/equatable.dart';

import 'vessel.dart';
import 'vessel_geometry.dart';
import 'vessel_voyage.dart';

enum VesselProfileOrigin { template, proposedFromFile, declaredByUser }

/// Parámetros persistentes del buque, separados de la carga de cada viaje.
/// El origen siempre es explícito: una propuesta no equivale a una declaración.
class VesselProfile extends Equatable {
  final VesselIdentity identity;
  final String vesselName;
  final VesselGeometry geometry;
  final Set<String> reeferSlots;
  final VesselProfileOrigin origin;
  final DateTime updatedAt;

  VesselProfile({
    required this.identity,
    required this.vesselName,
    required VesselGeometry geometry,
    Set<String> reeferSlots = const {},
    required this.origin,
    required DateTime updatedAt,
  })  : geometry = geometry.copyWith(
          holdTiers: List<int>.unmodifiable(geometry.holdTiers),
          deckTiers: List<int>.unmodifiable(geometry.deckTiers),
        ),
        reeferSlots = Set<String>.unmodifiable(reeferSlots),
        updatedAt = updatedAt.toUtc();

  String get key => identity.key;

  /// Primera versión propuesta; no se guarda ni se declara automáticamente.
  factory VesselProfile.proposeFrom(
    VesselVoyage voyage, {
    VesselGeometry? parameters,
    DateTime? updatedAt,
  }) =>
      VesselProfile(
        identity: voyage.vessel.profileIdentity,
        vesselName: voyage.vessel.name,
        geometry: VesselGeometry.proposeFrom(voyage.stowagePositions,
            parameters: parameters),
        origin: VesselProfileOrigin.proposedFromFile,
        updatedAt: updatedAt ?? DateTime.now(),
      );

  /// Parámetro del perfil guardado una sola vez dentro de su geometría.
  int get deckTierFloor => geometry.deckTierFloor;
  int get firstHoldTier => geometry.firstHoldTier;
  int get firstDeckTier => geometry.firstDeckTier;

  /// Se conserva una sola copia del límite, dentro de la geometría persistida.
  /// `null` significa que no hay límite declarado, nunca un umbral supuesto.
  double? get stackWeightLimitKg => geometry.stackWeightLimitKg;

  bool hasReeferSocket(String position) => reeferSlots.contains(position);

  static const _unchanged = Object();

  VesselProfile copyWith({
    VesselIdentity? identity,
    String? vesselName,
    VesselGeometry? geometry,
    int? deckTierFloor,
    int? firstHoldTier,
    int? firstDeckTier,
    Object? stackWeightLimitKg = _unchanged,
    Set<String>? reeferSlots,
    VesselProfileOrigin? origin,
    DateTime? updatedAt,
  }) {
    var nextGeometry = (geometry ?? this.geometry).copyWith(
      deckTierFloor: deckTierFloor,
      firstHoldTier: firstHoldTier,
      firstDeckTier: firstDeckTier,
    );
    if (!identical(stackWeightLimitKg, _unchanged)) {
      nextGeometry = stackWeightLimitKg == null
          ? nextGeometry.withoutStackWeightLimit()
          : nextGeometry.copyWith(
              stackWeightLimitKg: (stackWeightLimitKg as num).toDouble(),
            );
    }
    return VesselProfile(
      identity: identity ?? this.identity,
      vesselName: vesselName ?? this.vesselName,
      geometry: nextGeometry,
      reeferSlots: reeferSlots ?? this.reeferSlots,
      origin: origin ?? this.origin,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'identity': identity.toJson(),
        'vesselName': vesselName,
        'geometry': geometry.toJson(),
        'reeferSlots': reeferSlots.toList()..sort(),
        'origin': origin.name,
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory VesselProfile.fromJson(Map<String, dynamic> json) => VesselProfile(
        identity:
            VesselIdentity.fromJson(json['identity'] as Map<String, dynamic>),
        vesselName: json['vesselName'] as String,
        geometry:
            VesselGeometry.fromJson(json['geometry'] as Map<String, dynamic>),
        reeferSlots:
            (json['reeferSlots'] as List<dynamic>?)?.cast<String>().toSet() ??
                {},
        origin: VesselProfileOrigin.values.byName(json['origin'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  @override
  List<Object?> get props =>
      [identity, vesselName, geometry, reeferSlots, origin, updatedAt];
}
