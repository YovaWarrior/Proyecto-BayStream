# T-99 · RNF-007, extensión de módulos, retrospectiva (T-63 2 y decisión 7.4 a).
#
# Para cada tarea, con `git log` y `git show` (solo lectura), los archivos que
# tocaron sus commits y si ya existían antes del primero: «modificar
# existentes» es tocar un archivo que ya estaba. El proyecto no tiene carpeta
# por función (todo vive en lib/features/vessel), así que no se descuenta una
# «carpeta nueva»: se informa dónde cayeron los archivos nuevos.
# Commits de una tarea: los que la nombran en el mensaje, los que tocaron su
# informe docs/<T##>-RESULTADOS.md (un commit de código puede no nombrarla:
# ac72849 es de T-85) y los que se indiquen con -Indicados 'T-85=ac72849'.
# Los que solo tocan docs/ o los rectores (decisiones, aceptaciones) se
# listan y no cuentan. Los que nombran varias tareas se marcan para que una
# persona confirme que son de esta.
#
#   ./tool/t99_modulos.ps1 -Salida "$env:TEMP\t99-…\modulos" [-Tareas T-85,T-95,T-96,T-73] [-Hasta <sha>]
param(
    [Parameter(Mandatory = $true)] [string] $Salida,
    [string[]] $Tareas = @('T-85', 'T-95', 'T-96', 'T-73'),
    [string[]] $Indicados = @(),
    [string] $Hasta = 'HEAD',
    [string] $Repo = ''
)
$ErrorActionPreference = 'Stop'
# En Windows PowerShell 5.1, $PSScriptRoot llega vacío en los valores por defecto.
if (-not $Repo) { $Repo = (Resolve-Path (Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) '..')).Path }
# Con powershell -File una lista llega como «a,b»: se separa aquí.
$Tareas = @($Tareas | ForEach-Object { $_ -split ',' } | Where-Object { $_ })
$Indicados = @($Indicados | ForEach-Object { $_ -split ',' } | Where-Object { $_ })
$temp = [IO.Path]::GetFullPath($env:TEMP).TrimEnd('\') + '\'
if (-not ([IO.Path]::GetFullPath($Salida) + '\').StartsWith($temp, [StringComparison]::OrdinalIgnoreCase)) {
    throw 'La salida debe ir en %TEMP%.'
}
if ((Test-Path $Salida) -and @(Get-ChildItem $Salida).Count -gt 0) { throw "Ya hay una corrida en $Salida" }
New-Item -ItemType Directory -Force -Path $Salida | Out-Null

function Get-Area([string] $ruta) {
    switch -Regex ($ruta) {
        '^lib/' { 'lib'; break }
        '^test/' { 'test'; break }
        '^integration_test/' { 'integration_test'; break }
        '^tool/' { 'tool'; break }
        '^(android|windows|web|ios|macos|linux)/' { 'nativo'; break }
        '^pubspec\.(yaml|lock)$' { 'pubspec'; break }
        '^(docs/|SPRINT-\d+\.md|AGENTS\.md|CLAUDE\.md|README\.md)' { 'documentos'; break }
        default { 'otro' }
    }
}
$hastaSha = (& git -C $Repo rev-parse $Hasta).Trim()
$filas = @()
$resumen = @()
foreach ($tarea in $Tareas) {
    $patron = [regex]::Escape($tarea) + '([^0-9]|$)'
    $origen = [ordered]@{}
    foreach ($sha in @(& git -C $Repo log $hastaSha --format='%H' -E "--grep=$patron")) { $origen[$sha] = 'mensaje' }
    $informe = "docs/$($tarea.Replace('-', ''))-RESULTADOS.md"
    foreach ($sha in @(& git -C $Repo log $hastaSha --format='%H' -- $informe)) {
        if (-not $origen.Contains($sha)) { $origen[$sha] = 'informe' }
    }
    foreach ($c in @($Indicados | Where-Object { $_ -like "$tarea=*" })) {
        $origen[(& git -C $Repo rev-parse ($c.Split('=')[1])).Trim()] = 'indicado'
    }
    $log = @(foreach ($sha in $origen.Keys) { & git -C $Repo show -s --format='%H%x09%ad%x09%ct%x09%s' --date=short $sha })
    $commits = @()
    foreach ($l in $log) {
        $p = $l -split "`t", 4
        $p = @($p[0], $p[1], $p[3], [long]$p[2])
        $rutas = @(& git -C $Repo show --name-status --format= $p[0] | Where-Object { $_ })
        $cambios = foreach ($r in $rutas) {
            $c = $r -split "`t"
            [pscustomobject]@{ estado = $c[0].Substring(0, 1); ruta = $c[-1] }
        }
        $areas = @($cambios | ForEach-Object { Get-Area $_.ruta } | Sort-Object -Unique)
        $otras = @([regex]::Matches($p[2], 'T-\d+') | ForEach-Object { $_.Value } |
            Where-Object { $_ -ne $tarea } | Sort-Object -Unique)
        $commits += [pscustomobject]@{
            sha = $p[0]; fecha = $p[1]; asunto = $p[2]; orden = $p[3]; cambios = @($cambios); origen = $origen[$p[0]]
            solo_documentos = (@($areas | Where-Object { $_ -ne 'documentos' }).Count -eq 0)
            otras_tareas = $otras
        }
    }
    $conCodigo = @($commits | Where-Object { -not $_.solo_documentos } | Sort-Object orden)
    $base = if ($conCodigo.Count -gt 0) { (& git -C $Repo rev-parse "$($conCodigo[0].sha)^").Trim() } else { $null }
    $porRuta = @{}
    foreach ($c in $conCodigo) {
        foreach ($x in $c.cambios) {
            if (-not $porRuta.ContainsKey($x.ruta)) { $porRuta[$x.ruta] = @() }
            $porRuta[$x.ruta] += $x.estado
        }
    }
    foreach ($ruta in ($porRuta.Keys | Sort-Object)) {
        $existia = [bool](& git -C $Repo ls-tree $base -- $ruta)
        $filas += [pscustomobject]@{
            tarea = $tarea; ruta = $ruta; area = Get-Area $ruta; existia_antes = $existia
            estados = ($porRuta[$ruta] -join ' '); carpeta = (Split-Path $ruta -Parent) -replace '\\', '/'
        }
    }
    $deTarea = @($filas | Where-Object { $_.tarea -eq $tarea })
    $existentesLib = @($deTarea | Where-Object { $_.area -eq 'lib' -and $_.existia_antes })
    $existentesProducto = @($deTarea | Where-Object { $_.area -in @('lib', 'pubspec', 'nativo') -and $_.existia_antes })
    $resumen += [ordered]@{
        tarea                               = $tarea
        commits_con_codigo                  = @($conCodigo | ForEach-Object { "$($_.sha.Substring(0,7)) ($($_.origen)) $($_.asunto)" })
        commits_solo_documentos             = @($commits | Where-Object { $_.solo_documentos } | ForEach-Object { $_.sha.Substring(0, 7) })
        commits_que_nombran_otras_tareas    = @($conCodigo | Where-Object { $_.otras_tareas.Count -gt 0 } |
                ForEach-Object { "$($_.sha.Substring(0,7)): $($_.otras_tareas -join ', ')" })
        base                                = $base
        lib_nuevos                          = @($deTarea | Where-Object { $_.area -eq 'lib' -and -not $_.existia_antes }).Count
        lib_existentes_modificados          = $existentesLib.Count
        producto_existentes_modificados     = $existentesProducto.Count
        carpetas_de_los_nuevos              = @($deTarea | Where-Object { $_.area -eq 'lib' -and -not $_.existia_antes } |
                ForEach-Object { $_.carpeta } | Sort-Object -Unique)
    }
}
$filas | Export-Csv -NoTypeInformation -Encoding UTF8 (Join-Path $Salida 'modulos.csv')
[ordered]@{ instrumento = 'tool/t99_modulos.ps1'; hasta = $hastaSha; criterio = '7.4 (a): ningún archivo existente modificado'; tareas = $resumen } |
    ConvertTo-Json -Depth 6 | Set-Content -Encoding utf8 (Join-Path $Salida 'modulos.json')
foreach ($r in $resumen) {
    Write-Output ("{0}: {1} commits con código; lib/ {2} nuevos y {3} existentes modificados; producto {4} existentes" -f
        $r.tarea, $r.commits_con_codigo.Count, $r.lib_nuevos, $r.lib_existentes_modificados, $r.producto_existentes_modificados)
}
Write-Output "Salida: $Salida (solo lectura de git)"
