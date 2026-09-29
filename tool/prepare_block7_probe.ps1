[CmdletBinding()]
param([Parameter(Mandatory = $true)][string]$CorpusDirectory,
      [string]$RunTag = ('block7_' + (Get-Date -Format 'yyyyMMddHHmmss')))
$ErrorActionPreference = 'Stop'
if ($RunTag -notmatch '^[a-z0-9_]+$') { throw 'RunTag invalido.' }
$output = Join-Path (Split-Path -Parent $PSScriptRoot) 'build/block7_probe'
New-Item -ItemType Directory -Force -Path $output | Out-Null
$utf8 = [Text.UTF8Encoding]::new($false)
$payload = "const runTag = '$RunTag';`nconst corpusBase64 = <String,String>{`n"
foreach ($number in 1..6) {
    $name = 'A0' + $number
    $encoded = [Convert]::ToBase64String([IO.File]::ReadAllBytes((Join-Path $CorpusDirectory ('CORPUS_' + $name + '.edi'))))
    $payload += "'$name':'$encoded',`n"
}
$payload += "};`n"
[IO.File]::WriteAllText((Join-Path $output 'payload.dart'), $payload, $utf8)
$probe = @'
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:baystream/features/vessel/data/repositories/local_vessel_repository_factory.dart';
import 'package:baystream/features/vessel/presentation/providers/vessel_providers.dart';
import 'package:baystream/features/vessel/presentation/pages/vessel_overview_page.dart';
import '../../tool/block7_checks.dart';
import 'payload.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MaterialApp(home: Scaffold(body: Center(child:Text('Verificando T-38 y T-41...')))));
  try {
    final sources = corpusBase64.map((k,v) => MapEntry(k, utf8.decode(base64Decode(v))));
    final metrics = await checkBlock7(sources, () => openLocalVesselRepository(namespace:runTag));
    final evidence = jsonEncode({'status':'BLOCK7_PASS','run':runTag,'metrics':metrics});
    debugPrint(evidence, wrapWidth: 3500);
    final local = await openLocalVesselRepository(namespace:runTag);
    final scope = ProviderContainer(overrides:[localVesselRepositoryProvider.overrideWith((ref) async => local)]);
    final voyages = (await local.getAllVoyages()).getOrElse(() => []);
    final a03 = voyages.firstWhere((v) => v.totalContainers == 369);
    require(await scope.read(voyageNotifierProvider.notifier).openRecentVoyage(a03.id) == null, 'No abre A03 para UI');
    runApp(UncontrolledProviderScope(container:scope, child:MaterialApp(
      theme:ThemeData(useMaterial3:true), home:Scaffold(appBar:AppBar(title:const Text('T-38 / T-41 · PASS')),
      body:Builder(builder:(context)=>ListView(padding:const EdgeInsets.all(20),children:[
        FilledButton(onPressed:()=>Navigator.of(context).push(MaterialPageRoute<void>(
          builder:(_)=>const VesselOverviewPage())), child:const Text('Abrir A03 en BayStream')),
        SelectableText(evidence),
      ]))))));
  } catch (error, stack) {
    debugPrint('BLOCK7_ERROR: $error\n$stack');
    runApp(MaterialApp(home:Scaffold(body:SelectableText('BLOCK7_ERROR: $error\n$stack'))));
  }
}
'@
[IO.File]::WriteAllText((Join-Path $output 'probe.dart'), $probe, $utf8)
Write-Output "Sonda: $output/probe.dart. Namespace aislado: $RunTag"
