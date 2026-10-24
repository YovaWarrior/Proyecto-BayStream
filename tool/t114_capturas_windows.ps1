# T-114 · Fase 3, entrega 1: las capturas del inicio y del previo con el arnés
# de T-99 (escenario `inicio` de tool/t99_conductor.dart), desde el banco de
# Windows compilado en la copia r4 (tool/t99_copia.ps1 -Arbol -Sufijo r4).
#
# El mismo binario que mide RNF-002 recorre el escenario cuando arranca con las
# variables de entorno T99_* (el conductor las lee si no vienen compiladas):
# publica T100_CARGA.edi como un reciente, deja el historial de escala en
# USHOU para que T100_LLEGADA.edi abra en previo (hallazgo 5 del manual), y
# captura inicio y previo a 360x800, 600x960 y 1920x1080, en claro y oscuro,
# con la letra a 1.0, 1.45 y 2.0: 36 PNG en -Salida, más pasos.jsonl.
#
#   ./tool/t114_capturas_windows.ps1 -Exe "$env:TEMP\t99-r4-fase3\copia\build\windows\x64\runner\Release\baystream.exe" `
#       -Salida "$env:TEMP\t114\capturas"
param(
    [Parameter(Mandatory = $true)] [string] $Exe,
    [Parameter(Mandatory = $true)] [string] $Salida,
    [string] $Archivo = 'T100_LLEGADA.edi',
    [string] $ArchivoPublicado = 'T100_CARGA.edi',
    [string] $EscalaAnterior = 'USHOU',
    [string] $Anchos = '360x800,600x960,1920x1080',
    [string] $Letras = '1.0,1.45,2.0',
    # Fase 3, entrega 2: `plano` publica $Archivo y captura plano, lista y
    # avance por tema, letra y tamano (tool/t99_conductor.dart, _escenarioPlano).
    [string] $Escenario = 'inicio',
    # Candidata del piloto (10.28): `piloto` recorre la operacion como la oficina
    # (el plan de carga por la interfaz, el listado de la agencia por su pagina,
    # la llegada publicada, descarga, carga, avance, alertas, BAPLIE de salida).
    [string] $Listado = 'T100_LISTADO.xlsx',
    # Desde la consola empaquetada (Claude de escritorio, Codex) un proceso hijo
    # hereda el paquete y Windows le virtualiza AppData: el binario no ve el
    # almacen ni escribe los pasos donde se le pide (AGENTS.md, T-73 10.9).
    # Con -PorExplorer el binario lo abre explorer.exe desde un .cmd que lleva
    # las variables, fuera del paquete; el proceso se busca y se cierra por su ruta.
    [switch] $PorExplorer,
    # El conductor pide reducción de movimiento (T99_MOVIMIENTO=reducido, 10.26):
    # el inicio con la travesía se captura quieto, con el buque a un tercio del
    # ancho. Con 'completo' la animación corre, y entonces las esperas de reposo
    # del inicio vencen y quedan anotadas como `aviso` en pasos.jsonl.
    [string] $Movimiento = 'reducido'
)
$ErrorActionPreference = 'Stop'
$temp = [IO.Path]::GetFullPath($env:TEMP).TrimEnd('\') + '\'
foreach ($ruta in @($Exe, $Salida)) {
    if (-not ([IO.Path]::GetFullPath($ruta) + '\').StartsWith($temp, [StringComparison]::OrdinalIgnoreCase)) {
        throw "Solo rutas dentro de %TEMP%: $ruta"
    }
}
if ((Test-Path $Salida) -and @(Get-ChildItem $Salida -Force).Count -gt 0) { throw "La salida ya tiene una corrida: $Salida" }
New-Item -ItemType Directory -Force -Path $Salida | Out-Null
$env:T99_ESCENARIO = $Escenario
$env:T99_ARCHIVO = $Archivo
$env:T99_ARCHIVO_PUBLICADO = $ArchivoPublicado
$env:T99_ESCALA_ANTERIOR = $EscalaAnterior
$env:T99_LISTADO = $Listado
$env:T99_ANCHOS = $Anchos
$env:T99_LETRAS = $Letras
$env:T99_CAPTURAS = $Salida
$env:T99_PASOS = Join-Path $Salida 'pasos.jsonl'
$env:T99_PAUSA_MS = '300'
$env:T99_MOVIMIENTO = $Movimiento
# El proceso hereda el entorno; el almacén es el de la compilación (T99_ALMACEN).
$pasos = $env:T99_PASOS
$exeCompleto = [IO.Path]::GetFullPath($Exe)
if ($PorExplorer) {
    $cmd = Join-Path $Salida 'lanzar.cmd'
    $lineas = @('@echo off')
    foreach ($nombre in @('T99_ESCENARIO', 'T99_ARCHIVO', 'T99_ARCHIVO_PUBLICADO', 'T99_ESCALA_ANTERIOR',
                          'T99_ANCHOS', 'T99_LETRAS', 'T99_CAPTURAS', 'T99_PASOS', 'T99_PAUSA_MS',
                          'T99_MOVIMIENTO', 'T99_LISTADO')) {
        $lineas += "set $nombre=$([Environment]::GetEnvironmentVariable($nombre))"
    }
    $lineas += "start `"`" `"$exeCompleto`""
    [IO.File]::WriteAllLines($cmd, $lineas, (New-Object Text.ASCIIEncoding))
    Start-Process explorer.exe -ArgumentList "`"$cmd`""
    $proceso = $null
    $limite = (Get-Date).AddSeconds(60)
    while ($null -eq $proceso -and (Get-Date) -lt $limite) {
        Start-Sleep -Seconds 1
        $proceso = Get-Process baystream -ErrorAction SilentlyContinue | Where-Object { $_.Path -eq $exeCompleto } | Select-Object -First 1
    }
    if ($null -eq $proceso) { throw "explorer.exe no abrio $exeCompleto" }
} else {
    $proceso = Start-Process -FilePath $Exe -PassThru
}
$limite = (Get-Date).AddMinutes(10)
while (-not $proceso.HasExited -and (Get-Date) -lt $limite) {
    Start-Sleep -Seconds 2
    if ((Test-Path $pasos) -and (Select-String -Path $pasos -Pattern '"paso":\s*"(fin|error)"' -Quiet)) { break }
}
Start-Sleep -Seconds 1
if (-not $proceso.HasExited) { $proceso.CloseMainWindow() | Out-Null; Start-Sleep -Seconds 2 }
if (-not $proceso.HasExited) { Stop-Process -Id $proceso.Id }
$ultimo = if (Test-Path $pasos) { (Get-Content $pasos | Select-Object -Last 1) } else { '(sin pasos)' }
# 10.26 (O1): el conductor anota como `aviso` cada espera de reposo que venció.
$avisos = if (Test-Path $pasos) { @(Select-String -Path $pasos -Pattern '"paso":\s*"aviso"').Count } else { 0 }
Write-Output "Capturas: $(@(Get-ChildItem $Salida -Filter *.png).Count) PNG en $Salida"
Write-Output "Esperas de reposo vencidas (aviso): $avisos"
Write-Output "Último paso: $ultimo"
