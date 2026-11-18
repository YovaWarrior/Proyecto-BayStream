# T-120, corrección 1 (R4, 10.149) · Abre el banco de tool/t120_main.dart con
# explorer.exe (fuera del paquete de la consola, AGENTS.md), con el
# conductor de tool/t120_conductor.dart, espera a que termine su recorrido y
# lo cierra por su PID. Las capturas y el registro van a -Salida, en %TEMP%.
#
#   ./tool/t120_capturas_windows.ps1 -Exe "$env:TEMP\t99-t120-c1\copia\build\windows\x64\runner\Release\baystream.exe" `
#       -Salida "$env:TEMP\t99-t120-c1\capturas" -Archivo T120_BUQUE_LISTA_977.edi
param(
    [Parameter(Mandatory = $true)] [string] $Exe,
    [Parameter(Mandatory = $true)] [string] $Salida,
    [string] $Archivo = 'T120_BUQUE_LISTA_977.edi',
    [string] $Tamanos = '1366x690,360x800',
    [string] $Temas = 'claro,oscuro',
    [string] $LetrasTelefono = '1.0,2.0',
    [int] $LimiteMin = 20
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
$exeCompleto = [IO.Path]::GetFullPath($Exe)
$pasos = Join-Path $Salida 'pasos.jsonl'
$cmd = Join-Path $Salida 'lanzar.cmd'
[IO.File]::WriteAllLines($cmd, @(
        '@echo off',
        "set T120_ARCHIVO=$Archivo",
        "set T120_CAPTURAS=$Salida",
        "set T120_PASOS=$pasos",
        "set T120_TAMANOS=$Tamanos",
        "set T120_TEMAS=$Temas",
        "set T120_LETRAS_TELEFONO=$LetrasTelefono",
        "start `"`" `"$exeCompleto`""
    ), (New-Object Text.ASCIIEncoding))
$desde = Get-Date
Start-Process explorer.exe -ArgumentList "`"$cmd`""
$p = $null
for ($i = 0; $i -lt 60 -and -not $p; $i++) {
    Start-Sleep -Milliseconds 500
    $p = Get-Process -ErrorAction SilentlyContinue |
        Where-Object { $_.Path -eq $exeCompleto -and $_.StartTime -ge $desde.AddSeconds(-1) } |
        Select-Object -First 1
}
if (-not $p) { throw 'El banco no arrancó en 30 s.' }
Write-Output "Banco · PID $($p.Id)"
$hasta = (Get-Date).AddMinutes($LimiteMin)
while ((Get-Date) -lt $hasta) {
    Start-Sleep -Seconds 1
    if ((Test-Path $pasos) -and (Select-String -Path $pasos -Pattern '"paso":"(fin|error)"' -Quiet)) { break }
}
Start-Sleep -Seconds 1
$vivo = Get-Process -Id $p.Id -ErrorAction SilentlyContinue
if ($vivo -and $vivo.Path -eq $exeCompleto) { Stop-Process -Id $p.Id -Confirm:$false }
$capturas = @(Get-ChildItem $Salida -Filter '*.png').Count
$final = if (Test-Path $pasos) { (Get-Content $pasos | Select-Object -Last 1) } else { 'sin registro' }
Write-Output "Capturas: $capturas · último paso: $final"
