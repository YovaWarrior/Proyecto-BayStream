# T-99 · RNF-007, extensión de módulos, prospectivo (T-63 2 y decisión 7.4 a).
#
# Agrega un módulo mínimo en una COPIA TEMPORAL fuera del repositorio, no en
# una rama: «Notas del viaje» (una entidad y una página, en memoria) en su
# propia carpeta, lib/features/notas/, y el único enganche que la hace
# alcanzable: un botón en la barra de VesselOverviewPage. Después compara la
# copia con su base archivo por archivo y cuenta lo agregado y lo modificado
# fuera de la carpeta nueva. Para probar que compila, `flutter analyze --no-pub`
# en el destino, con semáforo de Carlos.
#
#   ./tool/t99_modulo_prospectivo.ps1 -Base "$env:TEMP\t99-…\copia" -Destino "$env:TEMP\t99-…\modulo"
param(
    [Parameter(Mandatory = $true)] [string] $Base,
    [Parameter(Mandatory = $true)] [string] $Destino
)
$ErrorActionPreference = 'Stop'
$temp = [IO.Path]::GetFullPath($env:TEMP).TrimEnd('\') + '\'
$base = [IO.Path]::GetFullPath($Base).TrimEnd('\')
$dest = [IO.Path]::GetFullPath($Destino).TrimEnd('\')
foreach ($r in @($base, $dest)) {
    if (-not ($r + '\').StartsWith($temp, [StringComparison]::OrdinalIgnoreCase)) { throw "Debe estar en %TEMP%: $r" }
}
if ((Test-Path $dest) -and @(Get-ChildItem $dest -Force).Count -gt 0) { throw "Ya hay contenido en $dest" }

# /XJ: sin seguir los enlaces de plugins que crea `flutter pub get`
# (windows/flutter/ephemeral/.plugin_symlinks); se recrean con `pub get`.
& robocopy $base $dest /E /XJ /XD build ephemeral .gradle /NFL /NDL /NJH /NJS /NP | Out-Null
if ($LASTEXITCODE -ge 8) { throw "robocopy falló ($LASTEXITCODE)" }
$ahora = Get-Date
Get-ChildItem $dest -Recurse -File | ForEach-Object { $_.LastWriteTime = $ahora }

function Set-Texto([string] $ruta, [string] $texto) {
    New-Item -ItemType Directory -Force -Path (Split-Path $ruta) | Out-Null
    [IO.File]::WriteAllText($ruta, $texto, (New-Object Text.UTF8Encoding($false)))
}

Set-Texto (Join-Path $dest 'lib\features\notas\domain\entities\nota_de_viaje.dart') @'
/// T-99 · Módulo prospectivo de RNF-007: una nota del planificador.
class NotaDeViaje {
  final String texto;
  final DateTime creada;
  const NotaDeViaje(this.texto, this.creada);
}
'@
Set-Texto (Join-Path $dest 'lib\features\notas\presentation\pages\notas_page.dart') @'
import 'package:flutter/material.dart';

import '../../domain/entities/nota_de_viaje.dart';

/// T-99 · Módulo prospectivo de RNF-007: notas del viaje, en memoria.
class NotasPage extends StatefulWidget {
  const NotasPage({super.key});

  @override
  State<NotasPage> createState() => _NotasPageState();
}

class _NotasPageState extends State<NotasPage> {
  final _notas = <NotaDeViaje>[];
  final _campo = TextEditingController();

  @override
  void dispose() {
    _campo.dispose();
    super.dispose();
  }

  void _agregar() {
    if (_campo.text.trim().isEmpty) return;
    setState(() => _notas.add(NotaDeViaje(_campo.text.trim(), DateTime.now())));
    _campo.clear();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Notas del viaje')),
        body: Column(children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              Expanded(child: TextField(controller: _campo)),
              IconButton(onPressed: _agregar, tooltip: 'Agregar nota', icon: const Icon(Icons.add)),
            ]),
          ),
          Expanded(
            child: ListView(children: [
              for (final n in _notas) ListTile(title: Text(n.texto)),
            ]),
          ),
        ]),
      );
}
'@

# El enganche: lo mínimo para que el módulo se alcance desde la interfaz.
$pagina = Join-Path $dest 'lib\features\vessel\presentation\pages\vessel_overview_page.dart'
$t = [IO.File]::ReadAllText($pagina)
$nl = if ($t.Contains("`r`n")) { "`r`n" } else { "`n" }
$anclaImport = "import 'discharge_sequence_page.dart';"
$anclaBoton = '      // Botón para cargar archivo BAPLIE'
if (-not $t.Contains($anclaImport) -or -not $t.Contains($anclaBoton)) {
    throw 'Las anclas del enganche no están: revisa vessel_overview_page.dart en esta base.'
}
$boton = @(
    '      IconButton(',
    "          icon: const Icon(Icons.note_alt_outlined),",
    "          tooltip: 'Notas del viaje',",
    '          onPressed: () => Navigator.of(context).push(',
    '              MaterialPageRoute<void>(builder: (_) => const NotasPage()))),'
) -join $nl
$t = $t.Replace($anclaImport, "$anclaImport$nl" + "import '../../../notas/presentation/pages/notas_page.dart';")
$t = $t.Replace($anclaBoton, "$boton$nl$anclaBoton")
Set-Texto $pagina $t

# Comparación de árboles, archivo por archivo, solo de lo que forma el
# producto: sin build/, .dart_tool/, los enlaces de plugins ni lo que regenera
# `flutter pub get`.
function Get-Huellas([string] $raiz) {
    $h = @{}
    Get-ChildItem $raiz -Recurse -File | Where-Object {
        $_.FullName -notmatch '\\(build|\.dart_tool|ephemeral|\.gradle)\\' -and
        $_.Name -notin @('t99_copia.json', 't99_modulo.json', '.flutter-plugins', '.flutter-plugins-dependencies')
    } | ForEach-Object {
        $h[$_.FullName.Substring($raiz.Length + 1).Replace('\', '/')] = (Get-FileHash $_.FullName -Algorithm SHA256).Hash
    }
    return $h
}
$antes = Get-Huellas $base
$despues = Get-Huellas $dest
$nuevos = @($despues.Keys | Where-Object { -not $antes.ContainsKey($_) } | Sort-Object)
$modificados = @($despues.Keys | Where-Object { $antes.ContainsKey($_) -and $antes[$_] -ne $despues[$_] } | Sort-Object)
$borrados = @($antes.Keys | Where-Object { -not $despues.ContainsKey($_) } | Sort-Object)
$carpeta = 'lib/features/notas/'
$r = [ordered]@{
    instrumento                  = 'tool/t99_modulo_prospectivo.ps1'
    base                         = $base
    destino                      = $dest
    carpeta_nueva                = $carpeta
    nuevos                       = $nuevos
    modificados                  = $modificados
    borrados                     = $borrados
    fuera_de_la_carpeta_nueva    = @(@($nuevos + $modificados + $borrados) | Where-Object { -not $_.StartsWith($carpeta) })
    existentes_modificados       = $modificados.Count + $borrados.Count
    criterio                     = '7.4 (a): ningún archivo fuera de la carpeta nueva'
    siguiente                    = 'flutter analyze --no-pub en el destino (semáforo)'
}
$r | ConvertTo-Json -Depth 4 | Set-Content -Encoding utf8 (Join-Path $dest 't99_modulo.json')
Write-Output ("Nuevos {0}, modificados {1}, borrados {2}; fuera de {3}: {4}" -f $nuevos.Count, $modificados.Count,
    $borrados.Count, $carpeta, (@($r.fuera_de_la_carpeta_nueva) -join ', '))
