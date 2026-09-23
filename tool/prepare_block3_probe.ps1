# Diagnostico aislado del bloque 3; no modifica main.dart ni instala aplicaciones.
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$CorpusPath,
    [string]$RunTag = 'block3_20260923'
)
$ErrorActionPreference = 'Stop'
if ($RunTag -notmatch '^[a-z0-9_]+$') { throw 'RunTag debe usar minusculas, numeros y guion bajo.' }
$root = Split-Path -Parent $PSScriptRoot
$output = Join-Path $root 'build/block3'
New-Item -ItemType Directory -Force -Path $output | Out-Null
$bytes = [IO.File]::ReadAllBytes((Resolve-Path -LiteralPath $CorpusPath).Path)
$encoded = [Convert]::ToBase64String($bytes)
$utf8 = [Text.UTF8Encoding]::new($false)
[IO.File]::WriteAllText((Join-Path $output 'probe_payload.dart'),
    "const corpusBase64 = '$encoded';`nconst probeNamespace = '$RunTag';`n", $utf8)
$probe = @'
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dartz/dartz.dart';
import 'package:baystream/core/errors/failures.dart';
import 'package:baystream/features/vessel/data/repositories/local_vessel_repository_factory.dart';
import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/repositories/vessel_repository.dart';
import 'package:baystream/features/vessel/presentation/providers/vessel_providers.dart';
import 'probe_payload.dart';

class CorpusParser implements VesselRepository {
  @override
  Future<Either<Failure, VesselVoyage>> parseBaplieFile(String content) async =>
      Right(BaplieParserService().parse(content));
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
void check(bool condition, String message) {
  if (!condition) throw StateError(message);
}
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  String result;
  try {
    final content = String.fromCharCodes(base64Decode(corpusBase64));
    final parsed = BaplieParserService().parse(content);
    final seed = VesselProfile.proposeFrom(parsed);
    final declared = seed.geometry.copyWith(starboardRows: 7,
      firstHoldTier: 4, firstDeckTier: 84,
      deckTiers: [...seed.geometry.deckTiers, 92]);
    var local = await openLocalVesselRepository(namespace: probeNamespace);
    ProviderContainer open() => ProviderContainer(overrides: [
      vesselRepositoryProvider.overrideWithValue(CorpusParser()),
      localVesselRepositoryProvider.overrideWith((ref) async => local),
    ]);
    var scope = open();
    try {
      var notifier = scope.read(voyageNotifierProvider.notifier);
      final first = await notifier.parseBaplieContent(content);
      final persisted = !first.needsGeometry;
      check(first.success && !first.needsIdentity, 'Carga inicial: ${first.errorMessage}');
      if (!persisted) {
        check(notifier.publishedVoyage == null, 'Publicó antes de confirmar');
        final error = await notifier.confirmGeometry(declared);
        check(error == null, 'Guardado: $error');
      }
      check(notifier.publishedVoyage!.geometry == declared, 'Cambió el perfil declarado');
      scope.dispose();
      (await local.close()).fold((f) => throw StateError(f.message), (_) {});
      local = await openLocalVesselRepository(namespace: probeNamespace);
      scope = open();
      notifier = scope.read(voyageNotifierProvider.notifier);
      final reopened = await notifier.parseBaplieContent(content);
      check(reopened.success && !reopened.needsGeometry && !reopened.needsIdentity,
        'Volvió a preguntar: ${reopened.errorMessage}');
      final voyage = notifier.publishedVoyage!;
      check(voyage.geometry == declared, 'Recalculó la geometría guardada');
      check(voyage.totalContainers == 977 && voyage.bays.length == 34, 'Conteos distintos');
      final shadows = voyage.bays.values.where((b) => b.containers.isEmpty).toList();
      check(shadows.length == 7 && shadows.every((b) => b.occupancyRate! > 0), 'Vecinos perdidos');
      final raw = parsed.stowagePositions.first.rawCode;
      final outside = '${raw.substring(0, 3)}1996';
      final expanded = content.replaceFirst('LOC+147+$raw', 'LOC+147+$outside');
      check(expanded != content, 'No se creó la carga fuera de perfil');
      final blocked = await notifier.parseBaplieContent(expanded);
      check(blocked.needsGeometry && notifier.outsideProfilePositions.contains(outside), 'No avisó');
      check(notifier.publishedVoyage == voyage, 'Publicó la carga fuera del perfil');
      notifier.discardPendingVoyage();
      check(notifier.currentProfile!.geometry == declared, 'Amplió al cancelar');
      result = '${persisted ? 'BLOQUE3_REINICIO_OK' : 'BLOQUE3_GUARDAR_LEER_OK'}: '
        '977 contenedores; 34 bahías; 7 con vecinos; perfil recuperado sin preguntar; '
        'ampliación cancelada sin cambios';
    } finally {
      scope.dispose();
      await local.close();
    }
  } catch (error, stack) {
    result = 'BLOQUE3_ERROR: $error';
    debugPrintStack(stackTrace: stack);
  }
  debugPrint(result);
  runApp(MaterialApp(theme: ThemeData.dark(useMaterial3: true),
    home: Scaffold(body: Center(child: SelectableText(result)))));
}
'@
[IO.File]::WriteAllText((Join-Path $output 'profile_probe.dart'), $probe, $utf8)
Write-Output "Diagnostico preparado en $output/profile_probe.dart. Probar Web primero."
