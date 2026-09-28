# Verificacion Web aislada: corpus real, IndexedDB y PDF. Sin Firebase.
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$CorpusPath,
    [string]$RunTag = ('block4_' + (Get-Date -Format 'yyyyMMddHHmmss'))
)
$ErrorActionPreference = 'Stop'
if ($RunTag -notmatch '^[a-z0-9_]+$') { throw 'RunTag invalido.' }
$root = Split-Path -Parent $PSScriptRoot
$output = Join-Path $root 'build/block4_web'
New-Item -ItemType Directory -Force -Path $output | Out-Null
$encoded = [Convert]::ToBase64String([IO.File]::ReadAllBytes((Resolve-Path -LiteralPath $CorpusPath).Path))
$utf8 = [Text.UTF8Encoding]::new($false)
[IO.File]::WriteAllText((Join-Path $output 'payload.dart'), "const corpusBase64 = '$encoded';`nconst runTag = '$RunTag';`n", $utf8)
$probe = @'
import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dartz/dartz.dart';
import 'package:baystream/core/errors/failures.dart';
import 'package:baystream/features/vessel/data/repositories/local_vessel_repository_factory.dart';
import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/data/services/pdf_report_service.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/repositories/vessel_repository.dart';
import 'package:baystream/features/vessel/presentation/providers/vessel_providers.dart';
import 'payload.dart';

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
Future<void> report(Map<String, dynamic> values) async {
  await html.HttpRequest.request('http://localhost:8775/result', method: 'POST',
      sendData: jsonEncode({'run': runTag, 'userAgent': html.window.navigator.userAgent,
        'time': DateTime.now().toUtc().toIso8601String(), ...values}));
}
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final phase = Uri.base.queryParameters['phase'] ?? 'write';
  try {
    final content = String.fromCharCodes(base64Decode(corpusBase64));
    final parsed = BaplieParserService().parse(content);
    // Oraculo independiente de isReefer: LOC/EQD/TMP del archivo real.
    final expected = <String>{};
    String? position;
    for (final raw in content.split("'")) {
      final segment = raw.trim();
      if (segment.startsWith('LOC+147+')) position = segment.split('+')[2].split(':').first;
      if (segment.startsWith('EQD+CN+')) {
        final iso = segment.split('+')[3].split(':').first;
        if (iso.length > 2 && iso[2] == 'R' && position != null) expected.add(position);
      }
      if (segment.startsWith('TMP+') && position != null) expected.add(position);
    }
    check(parsed.totalContainers == 977 && expected.length == 50, 'Corpus incorrecto');
    final seed = VesselProfile.proposeFrom(parsed).geometry;
    final shape = seed.copyWith(portRows: seed.portRows + 2, starboardRows: seed.starboardRows + 2,
      holdTiers: [...seed.holdTiers, seed.holdTiers.last + 2, seed.holdTiers.last + 4],
      deckTiers: [...seed.deckTiers, seed.deckTiers.last + 2, seed.deckTiers.last + 4]);
    VesselVoyage? pdfVoyage;
    final measurements = <Map<String, dynamic>>[];
    for (final limit in <double?>[75000, null]) {
      final local = await openLocalVesselRepository(namespace: '${runTag}_${limit == null ? 'null' : 'limit'}');
      final scope = ProviderContainer(overrides: [
        vesselRepositoryProvider.overrideWithValue(CorpusParser()),
        localVesselRepositoryProvider.overrideWith((ref) async => local),
      ]);
      try {
        final notifier = scope.read(voyageNotifierProvider.notifier);
        final loaded = await notifier.parseBaplieContent(content);
        check(loaded.success && !loaded.needsIdentity, 'Carga fallida');
        if (phase == 'write') {
          check(loaded.needsGeometry, 'Se esperaba un almacen nuevo');
          // Declara primero un limite; luego prueba su retirada explicita.
          check(await notifier.confirmGeometry(shape.copyWith(stackWeightLimitKg: 75000)) == null, 'No guarda');
          if (limit == null) {
            final removed = notifier.currentProfile!.copyWith(stackWeightLimitKg: null);
            (await local.saveProfile(removed)).fold((f) => throw StateError(f.message), (_) {});
          }
        } else {
          check(!loaded.needsGeometry, 'El reinicio perdio el perfil');
          final profile = notifier.currentProfile!;
          check(profile.stackWeightLimitKg == limit, 'Limite perdido');
          check(profile.origin == VesselProfileOrigin.declaredByUser, 'Geometria sin confirmar');
          check(profile.reeferSlotsOrigin == VesselProfileOrigin.proposedFromFile, 'Tomas declaradas indebidamente');
          check(profile.reeferSlots.length == expected.length && profile.reeferSlots.containsAll(expected), 'Tomas distintas');
          final voyage = notifier.publishedVoyage!;
          check(voyage.bays.length == 34 && voyage.totalContainers == 977, 'Viaje distinto');
          check(voyage.bays.values.every((b) => b.geometry!.stackWeightLimitKg == limit), 'Limite no propagado');
          pdfVoyage = voyage;
          // Un viaje seco del mismo buque no elimina los enchufes.
          notifier.clearVoyage();
          final dry = content.replaceAll(RegExp(r'TMP[^\x27]*\x27'), '').replaceAllMapped(
            RegExp(r'(EQD\+CN\+[^+]*\+\d{2})R'), (m) => '${m[1]}G');
          final next = await notifier.parseBaplieContent(dry);
          check(next.success && !next.needsGeometry, 'No recupera el perfil en viaje seco');
          check(notifier.publishedVoyage!.containers.every((c) => !c.isReefer), 'El viaje de control no es seco');
          check(notifier.currentProfile!.reeferSlots.length == 50, 'Perdio tomas sin carga refrigerada');
          measurements.add({'limit': limit, 'sockets': profile.reeferSlots.length,
            'socketOrigin': profile.reeferSlotsOrigin.name, 'bays': voyage.bays.length});
        }
      } finally {
        scope.dispose();
        (await local.close()).fold((f) => throw StateError(f.message), (_) {});
      }
    }
    if (phase == 'write') {
      await report({'status': 'WRITE_OK', 'reloadNext': true});
      html.window.location.search = '?phase=read';
      return;
    }
    final bytes = await const PdfReportService().generate(pdfVoyage!, geometry: pdfVoyage.geometry!);
    check(String.fromCharCodes(bytes.take(5)) == '%PDF-', 'No genera PDF');
    await report({'status': 'RELOAD_READ_PDF_OK', 'measurements': measurements,
      'containers': 977, 'pdfBytes': bytes.length, 'pdfBase64': base64Encode(bytes)});
    runApp(const MaterialApp(home: Scaffold(body: Center(child: Text(
      'WEB OK: reinicio, limites 75000/null, 50 tomas propuestas y PDF A01.')))));
  } catch (error, stack) {
    await report({'status': 'ERROR', 'phase': phase, 'error': '$error', 'stack': '$stack'});
    runApp(MaterialApp(home: Scaffold(body: Text('ERROR: $error'))));
  }
}
'@
[IO.File]::WriteAllText((Join-Path $output 'probe.dart'), $probe, $utf8)
$receiver = @'
import base64, json
from datetime import datetime, timezone
from http.server import BaseHTTPRequestHandler, HTTPServer
from pathlib import Path

root = Path(__file__).resolve().parent
class Receiver(BaseHTTPRequestHandler):
    def do_POST(self):
        if self.path != '/result':
            self.send_error(404)
            return
        data = json.loads(self.rfile.read(int(self.headers['Content-Length'])))
        if 'pdfBase64' in data:
            (root / 'T52-Chrome-A01.pdf').write_bytes(base64.b64decode(data.pop('pdfBase64')))
        data['receivedUtc'] = datetime.now(timezone.utc).isoformat()
        with (root / 'results.jsonl').open('a', encoding='utf-8') as out:
            out.write(json.dumps(data, ensure_ascii=False) + '\n')
        print(json.dumps(data, ensure_ascii=False), flush=True)
        self.send_response(200)
        self.send_header('Access-Control-Allow-Origin', 'http://localhost:8774')
        self.end_headers()
        self.wfile.write(b'OK')

HTTPServer(('127.0.0.1', 8775), Receiver).serve_forever()
'@
[IO.File]::WriteAllText((Join-Path $output 'receiver.py'), $receiver, $utf8)
Write-Output "Sonda preparada: $output. Iniciar receiver.py y flutter run -d chrome --release --no-web-resources-cdn --web-port=8774 -t build/block4_web/probe.dart."
