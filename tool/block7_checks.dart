import 'package:baystream/features/vessel/data/datasources/local_vessel_codec.dart';
import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/entities/stowage_validation_result.dart';
import 'package:baystream/features/vessel/domain/repositories/local_vessel_repository.dart';
import 'package:baystream/features/vessel/domain/services/dangerous_goods_validator.dart';
import 'package:baystream/features/vessel/domain/services/stack_weight_validator.dart';
import 'package:baystream/features/vessel/presentation/providers/segregation_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/stack_weight_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/vessel_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void require(bool value, String reason) {
  if (!value) throw StateError(reason);
}

bool sameValues<T>(List<T> a, List<T> b) =>
    a.length == b.length &&
    Iterable<int>.generate(a.length).every((i) => a[i] == b[i]);

/// Usa los seis archivos reales. Sin datos del corpus embebidos ni repositorios
/// simulados: sirve para VM y para las sondas compiladas de los tres clientes.
Future<Map<String, dynamic>> checkBlock7(Map<String, String> sources,
    Future<LocalVesselRepository> Function() open) async {
  final metrics = <String, dynamic>{};
  final voyages = <String, VesselVoyage>{};
  var declarations = 0, units = 0;
  const dg = DangerousGoodsValidator();
  const weight = StackWeightValidator();
  for (final entry in sources.entries) {
    final parsed = BaplieParserService().parse(entry.value);
    final profile = VesselProfile.proposeFrom(parsed);
    final voyage = parsed
        .withGeometry(profile.geometry)
        .copyWith(vesselProfileKey: profile.key);
    voyages[entry.key] = voyage;
    final count =
        voyage.containers.fold<int>(0, (n, c) => n + c.dangerousGoods!.length);
    final dangerous =
        voyage.containers.where((c) => c.dangerousGoods!.isNotEmpty).length;
    declarations += count;
    units += dangerous;
    require(count == RegExp(r"DGS\+").allMatches(entry.value).length,
        '${entry.key}: se perdió DGS');
    final results = dg.validate(voyage.containers, profile.geometry);
    final restored = const LocalVesselCodec()
        .decodeVoyage(const LocalVesselCodec().encodeVoyage(voyage));
    require(sameValues(restored.containers, voyage.containers),
        'Roundtrip containers');
    require(
        sameValues(
            dg.validate(restored.containers, restored.geometry!), results),
        'Roundtrip reglas');
    metrics[entry.key] = {
      'containers': voyage.totalContainers,
      'dgs': count,
      'dangerousUnits': dangerous,
      'results': results.length,
      for (final state in ValidationStatus.values)
        state.name: results.where((r) => r.status == state).length
    };
  }
  require(declarations == 34 && units == 30,
      'Corpus incompleto: $declarations DGS/$units unidades');
  final a03 = voyages['A03']!;
  require(metrics['A03']['dgs'] == 23 && metrics['A03']['dangerousUnits'] == 20,
      'A03 incorrecto');
  ContainerUnit at(String p) =>
      a03.containers.singleWhere((c) => c.stowagePosition?.toIsoCode() == p);
  final oxidizer = at('0140784');
  require(
      oxidizer.dangerousGoods!.length == 2 &&
          oxidizer.dangerousGoods!
              .every((d) => d.unNumber == '3084' && d.labels.isEmpty),
      'A03: hueco subsidiario distinto');
  final flammables = a03.containers
      .where((c) =>
          c.stowagePosition?.bay == 14 &&
          c.stowagePosition?.tier == 84 &&
          c.dangerousGoods!.any((d) => d.hazardClass == '3'))
      .toList();
  require(
      flammables.length == 4, 'A03: no hay cuatro clase 3 en bahía 14 tier 84');
  final compared = [
    for (final c in flammables)
      dg.evaluatePair(
          oxidizer,
          oxidizer.dangerousGoods!.first,
          c,
          c.dangerousGoods!.firstWhere((d) => d.hazardClass == '3'),
          a03.geometry!)
  ];
  require(
      compared.every((r) =>
          r.description.contains('5.1') && r.description.contains('Código 2')),
      'UN3084 no aplica la regla del secundario');
  final aerosol = at('0260186'), below = at('0260184');
  require(
      aerosol.dangerousGoods!.single.unNumber == '1950' &&
          below.dangerousGoods!.single.unNumber == '3085',
      'A03 vertical distinta');
  final exception = dg.evaluatePair(aerosol, aerosol.dangerousGoods!.single,
      below, below.dangerousGoods!.single, a03.geometry!);
  require(
      exception.status == ValidationStatus.notEvaluated &&
          exception.description.contains('126'),
      'Falsa alarma UN1950');
  metrics['mandatoryA03'] = {
    'UN3084': [
      for (final r in compared)
        {
          'positions': r.positions.map((p) => p.toIsoCode()).toList(),
          'status': r.status.name
        }
    ],
    'UN1950_UN3085': exception.status.name
  };

  final a01 = voyages['A01']!;
  require(
      a01.totalContainers == 977 && a01.bays.length == 34, 'A01 no es el real');
  final profile = VesselProfile.proposeFrom(a01).copyWith(
      stackWeightLimitKg: 75000, origin: VesselProfileOrigin.declaredByUser);
  final alerts = weight.validate(a01, profile);
  require(alerts.isNotEmpty, 'No hay excesos A01 con límite de prueba');
  require(
      weight.validate(a01, profile.copyWith(stackWeightLimitKg: null)).isEmpty,
      'Null inventa límite');
  final shadowBays = {5, 13, 15, 35, 39, 43, 45};
  require(
      alerts
          .every((r) => r.positions.every((p) => !shadowBays.contains(p.bay))),
      'Se suman sombras');
  metrics['weightA01'] = {
    'testLimitKg': 75000,
    'excessStacks': alerts.length,
    'nullLimitAlerts': 0,
    'shadowStacks': 0
  };
  var repository = await open();
  ProviderContainer? scope;
  try {
    (await repository.saveProfile(profile))
        .fold((f) => throw StateError(f.message), (_) {});
    final loaded = a01
        .withGeometry(profile.geometry)
        .copyWith(vesselProfileKey: profile.key);
    for (final voyage in [loaded, a03]) {
      (await repository.saveVoyage(voyage))
          .fold((f) => throw StateError(f.message), (_) {});
    }
    await repository.close();
    repository = await open();
    scope = ProviderContainer(overrides: [
      localVesselRepositoryProvider.overrideWith((ref) async => repository)
    ]);
    final notifier = scope.read(voyageNotifierProvider.notifier);
    require(await notifier.openRecentVoyage(loaded.id) == null,
        'No abre A01 de Hive');
    require(scope.read(stackWeightResultsProvider).length == alerts.length,
        'Provider peso difiere');
    scope.read(selectedCarrierProvider.notifier).select('FILTRO_SIN_CARGA');
    require(scope.read(stackWeightResultsProvider).length == alerts.length,
        'Filtro altera peso');
    require(
        await notifier
                .confirmGeometry(profile.geometry.withoutStackWeightLimit()) ==
            null,
        'No guarda null');
    require(scope.read(stackWeightResultsProvider).isEmpty,
        'Provider conserva exceso obsoleto');
    require(
        await notifier.openRecentVoyage(a03.id) == null, 'No abre A03 Hive');
    final restored = notifier.publishedVoyage!;
    require(
        restored.containers
                .fold<int>(0, (n, c) => n + c.dangerousGoods!.length) ==
            23,
        'Hive pierde DGS');
    require(
        scope.read(segregationResultsProvider).length ==
            metrics['A03']['results'],
        'Provider segregación difiere');
    metrics['hiveAndProviders'] =
        'PASS: reopen, full DGS, filter independent, profile null invalidates';
  } finally {
    scope?.dispose();
    await repository.close();
  }
  return metrics;
}
