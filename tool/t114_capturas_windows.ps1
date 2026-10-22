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
    [string] $Letras = '1.0,1.45,2.0'
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
$env:T99_ESCENARIO = 'inicio'
$env:T99_ARCHIVO = $Archivo
$env:T99_ARCHIVO_PUBLICADO = $ArchivoPublicado
$env:T99_ESCALA_ANTERIOR = $EscalaAnterior
$env:T99_ANCHOS = $Anchos
$env:T99_LETRAS = $Letras
$env:T99_CAPTURAS = $Salida
$env:T99_PASOS = Join-Path $Salida 'pasos.jsonl'
$env:T99_PAUSA_MS = '300'
# El proceso hereda el entorno; el almacén es el de la compilación (T99_ALMACEN).
$proceso = Start-Process -FilePath $Exe -PassThru
$limite = (Get-Date).AddMinutes(10)
$pasos = $env:T99_PASOS
while (-not $proceso.HasExited -and (Get-Date) -lt $limite) {
    Start-Sleep -Seconds 2
    if ((Test-Path $pasos) -and (Select-String -Path $pasos -Pattern '"paso":\s*"(fin|error)"' -Quiet)) { break }
}
Start-Sleep -Seconds 1
if (-not $proceso.HasExited) { $proceso.CloseMainWindow() | Out-Null; Start-Sleep -Seconds 2 }
if (-not $proceso.HasExited) { Stop-Process -Id $proceso.Id }
$ultimo = if (Test-Path $pasos) { (Get-Content $pasos | Select-Object -Last 1) } else { '(sin pasos)' }
Write-Output "Capturas: $(@(Get-ChildItem $Salida -Filter *.png).Count) PNG en $Salida"
Write-Output "Último paso: $ultimo"
