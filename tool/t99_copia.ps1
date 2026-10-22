# T-99 · Copia de compilación fuera del repositorio, para el banco y el arnés.
#
# Saca el commit con `git archive` (solo lectura: no toca el índice ni la rama)
# a una carpeta de %TEMP% y, solo en la copia:
#   - Android usa la identidad gt.cmartinez.baystream.t99 y el rótulo
#     «BayStream T99», para no instalarse nunca encima de la app real;
#   - pubspec.yaml declara t99_inputs/ como assets, con los .edi de -Entradas
#     (el corpus y los sintéticos no entran al repositorio);
#   - con -ConInstrumentos, superpone los archivos t99_* del árbol de trabajo
#     y su pubspec (Fase A, mientras T-99 no tiene commit).
# Reutiliza .dart_tool/package_config.json del árbol si el pubspec.lock es el
# mismo: alcanza para analyze, test y los scripts de Dart. Para COMPILAR
# (Windows, Android) hace falta igual `flutter pub get` en la copia, con
# semáforo: crea los enlaces de plugins de windows/flutter/ephemeral.
#
#   ./tool/t99_copia.ps1 -Destino "$env:TEMP\t99-b-<sha>\copia" -Commit <sha> `
#     -Entradas "<corpus>\CORPUS_A01.edi,$env:TEMP\t99-…\sinteticos\T99_SINTETICO_5000.edi"
#   Fase 3 de T-114 (10.9): -Arbol copia el árbol de trabajo (lo que todavía no
#   tiene commit) en vez de un commit, sin verificación contra git, y -Sufijo
#   da la identidad del cliente (por ejemplo r4: gt.cmartinez.baystream.r4 y
#   «BayStream R4»), siempre aparte de la app instalada.
param(
    [Parameter(Mandatory = $true)] [string] $Destino,
    [string] $Commit = 'HEAD',
    [string] $Repo = '',
    [string[]] $Entradas = @(),
    [switch] $ConInstrumentos,
    [switch] $Arbol,
    [string] $Sufijo = 't99'
)
$ErrorActionPreference = 'Stop'
# En Windows PowerShell 5.1, $PSScriptRoot llega vacío en los valores por defecto.
if (-not $Repo) { $Repo = (Resolve-Path (Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) '..')).Path }
# Con powershell -File una lista llega como «a,b»: se separa aquí.
$Entradas = @($Entradas | ForEach-Object { $_ -split ',' } | Where-Object { $_ })

$temp = [IO.Path]::GetFullPath($env:TEMP).TrimEnd('\') + '\'
$dest = [IO.Path]::GetFullPath($Destino).TrimEnd('\')
$repoCompleto = [IO.Path]::GetFullPath($Repo).TrimEnd('\') + '\'
if (-not ($dest + '\').StartsWith($temp, [StringComparison]::OrdinalIgnoreCase)) {
    throw "El destino debe estar dentro de %TEMP%: $dest"
}
if (($dest + '\').StartsWith($repoCompleto, [StringComparison]::OrdinalIgnoreCase)) {
    throw "El destino no puede estar dentro del repositorio: $dest"
}
if ((Test-Path $dest) -and @(Get-ChildItem $dest -Force).Count -gt 0) {
    throw "La carpeta ya tiene contenido; usa otra: $dest"
}
New-Item -ItemType Directory -Force -Path $dest | Out-Null

$sha = (& git -C $Repo rev-parse "$Commit^{commit}").Trim()
if ($Arbol) {
    # El árbol de trabajo tal cual, sin build, .dart_tool ni lo que no compila.
    $sha = "arbol-de-trabajo-sobre-$sha"
    # Solo las carpetas de la raíz, con su ruta completa: «design» también es
    # lib/core/design, el sistema de diseño, que sí se copia.
    $raiz = $repoCompleto.TrimEnd('\')
    $fuera = @('build', '.dart_tool', '.git', 'docs', 'outputs', 'design', 'prototipos', 'presentacion', '.claude', 'windows/flutter/ephemeral') | ForEach-Object { Join-Path $raiz $_ }
    & robocopy $raiz $dest /E /NFL /NDL /NJH /NJS /XD @fuera | Out-Null
    if ($LASTEXITCODE -ge 8) { throw "robocopy falló con $LASTEXITCODE" }
    $ahora = Get-Date
    Get-ChildItem $dest -Recurse -File | ForEach-Object { $_.LastWriteTime = $ahora }
} else {
$tar = "$dest.tar"
$excluir = @(':(exclude)docs', ':(exclude)outputs', ':(exclude)design', ':(exclude)prototipos',
    ':(exclude)presentacion', ':(exclude).claude')
# Sin conversión de finales de línea: la copia queda byte a byte como los blobs
# del commit, y así se verifica contra su árbol (el manifiesto del cierre).
& git -C $Repo -c core.autocrlf=false archive --format=tar -o $tar $sha -- . @excluir
if ($LASTEXITCODE -ne 0) { throw 'git archive falló' }
& tar -xf $tar -C $dest
if ($LASTEXITCODE -ne 0) { throw 'tar falló' }
Remove-Item $tar
# Fecha actual: una limpieza de temporales borra antes lo que trae fechas viejas.
$ahora = Get-Date
Get-ChildItem $dest -Recurse -File | ForEach-Object { $_.LastWriteTime = $ahora }
}

# Verificación contra el árbol del commit: cada archivo, con su hash de blob.
# (En PowerShell $arbolGit y $Arbol son la misma variable: la bandera va aparte.)
$verificarContraGit = -not $Arbol
$arbolGit = @{}
foreach ($l in @(if ($verificarContraGit) { & git -C $Repo -c core.quotepath=false ls-tree -r $sha })) {
    $p = $l -split "`t", 2
    if ($p[1] -notmatch '^(docs|outputs|design|prototipos|presentacion|\.claude)/') {
        $arbolGit[$p[1]] = ($p[0] -split ' ')[2]
    }
}
if (-not $verificarContraGit) {
    $verificacion = [ordered]@{ archivos = @(Get-ChildItem $dest -Recurse -File).Count; distintos = 'sin verificar'; sobrantes = 'sin verificar'; contra = 'arbol de trabajo (-Arbol), no un commit' }
} else {
$rutas = @($arbolGit.Keys | Sort-Object)
# Por lotes y como argumentos: en PowerShell 5.1 la tubería a git agrega un BOM.
$hashes = @()
for ($i = 0; $i -lt $rutas.Count; $i += 80) {
    $lote = @($rutas[$i..([math]::Min($i + 79, $rutas.Count - 1))] | ForEach-Object { Join-Path $dest $_ })
    $hashes += @(& git -C $Repo hash-object --no-filters -- @lote)
}
$distintos = @(for ($i = 0; $i -lt $rutas.Count; $i++) { if ($hashes[$i] -ne $arbolGit[$rutas[$i]]) { $rutas[$i] } })
$sobrantes = @(Get-ChildItem $dest -Recurse -File | ForEach-Object {
        $_.FullName.Substring($dest.Length + 1).Replace('\', '/') } | Where-Object { -not $arbolGit.ContainsKey($_) })
if ($distintos.Count -gt 0 -or $sobrantes.Count -gt 0) {
    throw "La copia no cuadra con $sha`: $($distintos.Count) distintos, $($sobrantes.Count) sobrantes"
}
$verificacion = [ordered]@{ archivos = $rutas.Count; distintos = 0; sobrantes = 0; contra = "git ls-tree -r $sha" }
}

$superpuestos = @()
if ($ConInstrumentos) {
    foreach ($patron in @('tool\t99_*', 'integration_test\t99_*', 'test\t99_*')) {
        foreach ($f in @(Get-ChildItem (Join-Path $Repo $patron) -File -ErrorAction SilentlyContinue)) {
            $rel = $f.FullName.Substring($repoCompleto.Length)
            New-Item -ItemType Directory -Force -Path (Split-Path (Join-Path $dest $rel)) | Out-Null
            Copy-Item $f.FullName (Join-Path $dest $rel)
            $superpuestos += $rel
        }
    }
    foreach ($f in @('pubspec.yaml', 'pubspec.lock')) {
        Copy-Item (Join-Path $Repo $f) (Join-Path $dest $f) -Force
        $superpuestos += $f
    }
}

function Set-Texto([string] $ruta, [string] $texto) {
    [IO.File]::WriteAllText($ruta, $texto, (New-Object Text.UTF8Encoding($false)))
}

# Android: identidad propia, solo en la copia.
$gradle = Join-Path $dest 'android\app\build.gradle.kts'
$g = [IO.File]::ReadAllText($gradle)
$nl = if ($g.Contains("`r`n")) { "`r`n" } else { "`n" }
$ancla = 'applicationId = "gt.cmartinez.baystream"'
if (-not $g.Contains($ancla)) { throw "No está el applicationId esperado en $gradle" }
Set-Texto $gradle ($g.Replace($ancla, "$ancla$nl        applicationIdSuffix = `".$Sufijo`""))
$manifiesto = Join-Path $dest 'android\app\src\main\AndroidManifest.xml'
$m = [IO.File]::ReadAllText($manifiesto)
if (-not $m.Contains('android:label="BayStream"')) { throw "No está el rótulo esperado en $manifiesto" }
Set-Texto $manifiesto ($m.Replace('android:label="BayStream"', ('android:label="BayStream ' + $Sufijo.ToUpper() + '"')))

# Entradas como assets de la copia.
$entradasCopiadas = @()
if ($Entradas.Count -gt 0) {
    $carpeta = Join-Path $dest 't99_inputs'
    New-Item -ItemType Directory -Force -Path $carpeta | Out-Null
    foreach ($e in $Entradas) {
        Copy-Item $e $carpeta
        $entradasCopiadas += [ordered]@{
            archivo = Split-Path $e -Leaf
            sha256  = (Get-FileHash $e -Algorithm SHA256).Hash.ToLower()
            bytes   = (Get-Item $e).Length
        }
    }
    $pubspec = Join-Path $dest 'pubspec.yaml'
    $p = [IO.File]::ReadAllText($pubspec)
    $nl = if ($p.Contains("`r`n")) { "`r`n" } else { "`n" }
    if (-not $p.Contains("  assets:$nl")) { throw "No está la lista de assets en $pubspec" }
    Set-Texto $pubspec ($p.Replace("  assets:$nl", "  assets:$nl    - t99_inputs/$nl"))
}

# Dependencias: las del árbol, si el lock es el mismo.
# Se comparan sin CR: git archive da CRLF y pub escribe LF.
$lockCopia = [IO.File]::ReadAllText((Join-Path $dest 'pubspec.lock')).Replace("`r", '')
$lockArbol = [IO.File]::ReadAllText((Join-Path $Repo 'pubspec.lock')).Replace("`r", '')
$paquetes = 'pendiente: flutter pub get en la copia, con semáforo'
if ($lockCopia -eq $lockArbol -and (Test-Path (Join-Path $Repo '.dart_tool\package_config.json'))) {
    New-Item -ItemType Directory -Force -Path (Join-Path $dest '.dart_tool') | Out-Null
    foreach ($f in @('package_config.json', 'package_graph.json')) {
        $origen = Join-Path $Repo ".dart_tool\$f"
        if (Test-Path $origen) { Copy-Item $origen (Join-Path $dest ".dart_tool\$f") }
    }
    $paquetes = 'reutilizados del árbol (mismo pubspec.lock); para compilar, flutter pub get en la copia'
}

$registro = [ordered]@{
    instrumento        = 'tool/t99_copia.ps1'
    commit             = $sha
    destino            = $dest
    superpuestos       = $superpuestos
    android            = 'applicationIdSuffix .t99, rótulo BayStream T99 (solo en la copia)'
    entradas           = $entradasCopiadas
    paquetes           = $paquetes
    verificacion       = $verificacion
    fecha              = (Get-Date).ToString('o')
}
Set-Texto (Join-Path $dest 't99_copia.json') ($registro | ConvertTo-Json -Depth 5)
Write-Output "Copia de $sha en $dest · paquetes: $paquetes"
if ($superpuestos.Count -gt 0) { Write-Output "Superpuestos del árbol: $($superpuestos.Count)" }
