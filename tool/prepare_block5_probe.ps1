# Sonda aislada de servicios reales para Windows, Android y Chrome.
[CmdletBinding()]
param([Parameter(Mandatory = $true)][string]$CorpusPath,
      [string]$RunTag = ('block5_' + (Get-Date -Format 'yyyyMMddHHmmss')))
$ErrorActionPreference = 'Stop'
if ($RunTag -notmatch '^[a-z0-9_]+$') { throw 'RunTag invalido.' }
$output = Join-Path (Split-Path -Parent $PSScriptRoot) 'build/block5_probe'
New-Item -ItemType Directory -Force -Path $output | Out-Null
$utf8 = [Text.UTF8Encoding]::new($false)
$encoded = [Convert]::ToBase64String([IO.File]::ReadAllBytes((Resolve-Path -LiteralPath $CorpusPath).Path))
[IO.File]::WriteAllText((Join-Path $output 'payload.dart'), "const corpusBase64 = '$encoded';`nconst runTag = '$RunTag';`n", $utf8)
$probe = @'
import 'dart:convert';
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
import 'report_io.dart' if (dart.library.html) 'report_web.dart';
import 'payload.dart';

class Parser implements VesselRepository {
  @override
  Future<Either<Failure, VesselVoyage>> parseBaplieFile(String s) async => Right(BaplieParserService().parse(s));
  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}
void check(bool condition, String reason) { if (!condition) throw StateError(reason); }
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MaterialApp(home: Scaffold(body: Center(child: Text('Verificando bloque 5 y T-53…')))));
  try {
    final content = String.fromCharCodes(base64Decode(corpusBase64));
    final parsed = BaplieParserService().parse(content);
    final seed = VesselProfile.proposeFrom(parsed);
    final geometry = seed.geometry.copyWith(portRows: seed.geometry.portRows + 2,
      starboardRows: seed.geometry.starboardRows + 2, stackWeightLimitKg: 75000,
      holdTiers: [...seed.geometry.holdTiers, seed.geometry.holdTiers.last + 2, seed.geometry.holdTiers.last + 4],
      deckTiers: [...seed.geometry.deckTiers, seed.geometry.deckTiers.last + 2, seed.geometry.deckTiers.last + 4]);
    final source = seed.copyWith(geometry: geometry, origin: VesselProfileOrigin.declaredByUser,
      reeferSlotsOrigin: VesselProfileOrigin.declaredByUser, updatedAt: DateTime.utc(2026, 9, 27));
    final targetContent = content.replaceFirst(parsed.vessel.imoNumber!, '9000999')
      .replaceFirst(parsed.vessel.name, 'BUQUE PLANTILLA QA');
    final targetVessel = BaplieParserService().parse(targetContent).vessel;
    final local = await openLocalVesselRepository(namespace: runTag);
    final scope = ProviderContainer(overrides: [
      vesselRepositoryProvider.overrideWithValue(Parser()),
      localVesselRepositoryProvider.overrideWith((ref) async => local),
    ]);
    var wrote = false;
    try {
      final stored = (await local.getAllProfiles()).fold((f) => throw StateError(f.message), (v) => v);
      final notifier = scope.read(voyageNotifierProvider.notifier);
      if (stored.isEmpty) {
        (await local.saveProfile(source)).fold((f) => throw StateError(f.message), (_) {});
        final load = await notifier.parseBaplieContent(targetContent);
        check(load.needsGeometry && notifier.canChooseTemplate, 'No ofrece plantilla al buque nuevo');
        notifier.useTemplate(source);
        final clone = notifier.currentProfile!;
        check(clone.key == targetVessel.profileKey && clone.key != source.key, 'Identidad heredada');
        check(clone.origin == VesselProfileOrigin.template && clone.reeferSlotsOrigin == VesselProfileOrigin.template, 'Origen heredado');
        check((await local.getAllProfiles()).getOrElse(() => []).length == 1, 'Guardado sin confirmar');
        check(await notifier.confirmGeometry(clone.geometry) == null, 'No confirma clon');
        final saved = notifier.currentProfile!;
        notifier.clearVoyage();
        final edited = saved.copyWith(deckTierFloor: 78, firstHoldTier: 4, firstDeckTier: 80,
          stackWeightLimitKg: null, reeferSlots: {...saved.reeferSlots, '0020094'}, updatedAt: DateTime.now());
        check(await notifier.saveEditedProfile(saved, edited) == null, 'No edita sin viaje');
        check(notifier.publishedVoyage == null, 'Editar abrió un viaje');
        final now = (await local.getAllProfiles()).getOrElse(() => []);
        check(now.firstWhere((p) => p.key == source.key) == source, 'Se alteró la fuente');
        wrote = true;
      } else {
        check(stored.length == 2, 'Cantidad de perfiles incorrecta');
        check(stored.firstWhere((p) => p.key == source.key) == source, 'Fuente alterada después del reinicio');
        final clone = stored.firstWhere((p) => p.key == targetVessel.profileKey);
        check(clone.stackWeightLimitKg == null && clone.deckTierFloor == 78 &&
          clone.firstHoldTier == 4 && clone.firstDeckTier == 80, 'Parámetros perdidos');
        check(clone.reeferSlots.length == 51 && clone.reeferSlots.containsAll(source.reeferSlots) &&
          clone.reeferSlots.contains('0020094'), 'Tomas perdidas');
        check(clone.reeferSlotsOrigin == VesselProfileOrigin.template, 'Confianza elevada');
        final load = await notifier.parseBaplieContent(targetContent);
        check(load.success && !load.needsGeometry, 'Volvió a preguntar al recuperar el perfil');
        check(notifier.publishedVoyage!.geometry == clone.geometry, 'No usa el perfil editado');
        notifier.clearVoyage();
        await notifier.parseBaplieContent(content);
        final voyage = notifier.publishedVoyage!;
        check(voyage.totalContainers == 977 && voyage.bays.length == 34, 'Viaje distinto');
        final bytes = await const PdfReportService().generate(voyage, geometry: voyage.geometry!);
        await report({'run': runTag, 'status': 'RESTART_READ_PDF_OK',
          'profiles': 2, 'cloneSockets': 51, 'sourceSockets': 50, 'sourceUnchanged': true,
          'cloneSocketOrigin': clone.reeferSlotsOrigin.name, 'limit': clone.stackWeightLimitKg,
          'floor': clone.deckTierFloor, 'holdAnchor': clone.firstHoldTier, 'deckAnchor': clone.firstDeckTier,
          'containers': 977, 'bays': 34, 'pdfBytes': bytes.length, 'pdfBase64': base64Encode(bytes)});
      }
    } finally {
      scope.dispose();
      (await local.close()).fold((f) => throw StateError(f.message), (_) {});
    }
    if (wrote) await report({'run': runTag, 'status': 'WRITE_OK', 'closed': true});
    runApp(MaterialApp(home: Scaffold(body: Center(child: Text(wrote
      ? 'GUARDADO OK. Reiniciar para comprobar recuperación.' : 'BLOQUE 5 / T-53 OK. Perfil recuperado y PDF generado.')))));
    if (wrote) restartWeb();
  } catch (error, stack) {
    await report({'run': runTag, 'status': 'ERROR', 'error': '$error', 'stack': '$stack'});
    runApp(MaterialApp(home: Scaffold(body: Text('ERROR: $error'))));
  }
}
'@
[IO.File]::WriteAllText((Join-Path $output 'probe.dart'), $probe, $utf8)
$web = @'
// Sonda de QA con el SDK instalado; no forma parte de lib/.
// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter
import 'dart:convert';
import 'dart:html' as html;
Future<void> report(Map<String, dynamic> data) async {
  await html.HttpRequest.request('http://localhost:8785/result', method: 'POST',
    sendData: jsonEncode({...data, 'platform': 'chrome', 'userAgent': html.window.navigator.userAgent,
      'utc': DateTime.now().toUtc().toIso8601String()}));
}
void restartWeb() => html.window.location.reload();
'@
[IO.File]::WriteAllText((Join-Path $output 'report_web.dart'), $web, $utf8)
$native = @'
import 'dart:convert';
import 'dart:io';
Future<void> report(Map<String, dynamic> data) async {
  final client = HttpClient();
  try {
    final request = await client.postUrl(Uri.parse('http://localhost:8785/result'));
    request.write(jsonEncode({...data, 'platform': Platform.operatingSystem,
      'utc': DateTime.now().toUtc().toIso8601String()}));
    final response = await request.close();
    if (response.statusCode != 200) throw StateError('Receptor ${response.statusCode}');
    await response.drain<void>();
  } finally { client.close(); }
}
void restartWeb() {}
'@
[IO.File]::WriteAllText((Join-Path $output 'report_io.dart'), $native, $utf8)
$receiver = @'
import base64, json
from http.server import BaseHTTPRequestHandler, HTTPServer
from pathlib import Path
root = Path(__file__).resolve().parent
class Receiver(BaseHTTPRequestHandler):
    def do_POST(self):
        if self.path != '/result':
            self.send_error(404)
            return
        if self.headers.get('Transfer-Encoding') == 'chunked':
            chunks = []
            while True:
                size = int(self.rfile.readline().split(b';')[0], 16)
                if not size:
                    self.rfile.readline()
                    break
                chunks.append(self.rfile.read(size))
                assert self.rfile.read(2) == b'\r\n'
            body = b''.join(chunks)
        else:
            body = self.rfile.read(int(self.headers['Content-Length']))
        data = json.loads(body)
        if data.get('platform') not in ['chrome', 'windows', 'android']:
            self.send_error(400)
            return
        if 'pdfBase64' in data:
            (root / ('T53-' + data['platform'] + '.pdf')).write_bytes(base64.b64decode(data.pop('pdfBase64')))
        with (root / 'results.jsonl').open('a', encoding='utf-8') as out:
            out.write(json.dumps(data, ensure_ascii=False) + '\n')
        print(json.dumps(data, ensure_ascii=False), flush=True)
        self.send_response(200)
        self.send_header('Access-Control-Allow-Origin', 'http://localhost:8784')
        self.end_headers()
        self.wfile.write(b'OK')
HTTPServer(('127.0.0.1', 8785), Receiver).serve_forever()
'@
[IO.File]::WriteAllText((Join-Path $output 'receiver.py'), $receiver, $utf8)
Write-Output "Sonda: $output/probe.dart. Receptor: puerto 8785. Chrome: puerto 8784. Namespace: $RunTag"
