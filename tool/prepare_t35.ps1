# Genera diagnosticos aislados; no modifica lib/ ni instala aplicaciones.
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$CorpusPath,
    [string]$OutputDirectory = 'build/t35-replay',
    [string]$FlutterSdk = 'C:/flutter'
)

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$corpus = (Resolve-Path -LiteralPath $CorpusPath).Path
$output = [IO.Path]::GetFullPath((Join-Path $projectRoot $OutputDirectory))
$buildRoot = [IO.Path]::GetFullPath((Join-Path $projectRoot 'build')) + [IO.Path]::DirectorySeparatorChar
if (-not $output.StartsWith($buildRoot, [StringComparison]::OrdinalIgnoreCase)) {
    throw 'La salida debe quedar dentro de build/.'
}
$dart = Join-Path $FlutterSdk 'bin/cache/dart-sdk/bin/dart.exe'
$flutter = Join-Path $FlutterSdk 'bin/cache/flutter_tools.snapshot'
$utf8 = [Text.UTF8Encoding]::new($false)
New-Item -ItemType Directory -Force -Path $output | Out-Null

$measurement = @'
import 'dart:convert';
import 'dart:io';
import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/data/services/export_service.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Mide la exportación real de CORPUS_A01', () async {
    final source = File(const String.fromEnvironment('CORPUS_A01'));
    final parsed = BaplieParserService().parse(
      String.fromCharCodes(await source.readAsBytes()),
    );
    // Reproduce la confirmación de la propuesta sin editar los parámetros.
    final voyage = parsed.withGeometry(
      VesselGeometry.proposeFrom(parsed.stowagePositions),
      portOfCall: parsed.portOfOrigin,
    );
    expect(voyage.totalContainers, 977);
    final bytes = const ExportService().bytesFor(voyage, VoyageExportFormat.json);
    final file = File(const String.fromEnvironment('T35_OUTPUT'));
    await file.writeAsBytes(bytes, flush: true);
    final readBack = await file.readAsBytes();
    expect(readBack, bytes);
    final restored = VesselVoyage.fromJson(jsonDecode(utf8.decode(readBack)));
    expect(restored.toJson(), voyage.toJson());
    expect(restored.containers, voyage.containers);
    // Los slots vecinos son derivados y hoy fromJson no los reconstruye.
    // Se registra para T-36; no es una pérdida de bytes del motor local.
    expect(restored.withGeometry(voyage.geometry!, portOfCall: voyage.portOfCall), voyage);
    stdout.writeln('T35_MEDICION: ${await file.length()} bytes; '
        '5 viajes: ${bytes.length * 5} bytes; 977 contenedores por viaje');
  });
}
'@

$probe = @'
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'payload.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  String result;
  try {
    const path = String.fromEnvironment('T35_PATH');
    if (path.isNotEmpty) Hive.init(path);
    var box = await Hive.openBox<String>(probeBoxName);
    final persisted = box.get('ready') == 'yes';
    if (!persisted) {
      for (var i = 0; i < 5; i++) {
        await box.put('voyage_$i', payload);
      }
      await box.flush();
    }
    await box.close();
    box = await Hive.openBox<String>(probeBoxName);
    for (var i = 0; i < 5; i++) {
      final value = box.get('voyage_$i');
      if (value != payload) throw StateError('Contenido distinto en viaje $i');
      final voyage = VesselVoyage.fromJson(jsonDecode(value!));
      if (voyage.totalContainers != 977) throw StateError('Conteo incorrecto');
    }
    await box.put('ready', 'yes');
    await box.flush();
    await Hive.close();
    result = '${persisted ? 'T35_REINICIO_OK' : 'T35_ESCRITURA_LECTURA_OK'}: '
        '5 viajes, 977 contenedores por viaje, '
        '${utf8.encode(payload).length * 5} bytes; igualdad completa';
  } catch (error, stack) {
    result = 'T35_ERROR: $error';
    debugPrintStack(stackTrace: stack);
  }
  debugPrint(result);
  runApp(MaterialApp(
    theme: ThemeData.dark(useMaterial3: true),
    home: Scaffold(body: Center(child: SelectableText(result))),
  ));
}
'@

[IO.File]::WriteAllText((Join-Path $output 'measure_test.dart'), $measurement, $utf8)
[IO.File]::WriteAllText((Join-Path $output 'storage_probe.dart'), $probe, $utf8)
Push-Location $projectRoot
try {
    & $dart $flutter test --no-pub (Join-Path $output 'measure_test.dart') `
        "--dart-define=CORPUS_A01=$corpus" `
        "--dart-define=T35_OUTPUT=$(Join-Path $output 'CORPUS_A01.json')" --reporter expanded
    if ($LASTEXITCODE -ne 0) { throw 'Falló la medición del corpus.' }
    $jsonPath = Join-Path $output 'CORPUS_A01.json'
    $payload = [IO.File]::ReadAllText($jsonPath)
    $literal = (ConvertTo-Json -InputObject $payload -Compress).Replace('$', '\$')
    $hash = (Get-FileHash -LiteralPath $jsonPath -Algorithm SHA256).Hash
    # Una nueva exportación lleva UUID nuevos: caja propia para cada ejecución.
    $boxName = 'baystream_t35_' + $hash.Substring(0, 12).ToLowerInvariant()
    [IO.File]::WriteAllText((Join-Path $output 'payload.dart'),
        "const payload = $literal;`nconst probeBoxName = '$boxName';`n", $utf8)
    [pscustomobject]@{
        corpusSha256 = (Get-FileHash -LiteralPath $corpus -Algorithm SHA256).Hash
        jsonSha256 = $hash
        bytes = (Get-Item -LiteralPath $jsonPath).Length
        recentVoyages = 5
        totalBytes = (Get-Item -LiteralPath $jsonPath).Length * 5
        boxName = $boxName
    } | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $output 'measurement.json') -Encoding utf8
    Write-Output "Diagnosticos preparados en $output. Compilar primero Web; consultar T35-RESULTADOS.md."
} finally {
    Pop-Location
}
