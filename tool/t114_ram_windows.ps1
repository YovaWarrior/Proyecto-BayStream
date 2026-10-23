# T-114 · Fase 3, entrega 2: la RAM en Windows antes y después del plano nuevo,
# con el arnés de T-99 (tool/t99_ram_windows.ps1, acción `seguir`) y el escenario
# `ram` del conductor (tool/t99_conductor.dart): cargar, el plano, cada bahía,
# las estadísticas, la búsqueda y la Lista.
#
# El banco se abre con explorer.exe, fuera del paquete de la consola, desde un
# .cmd que lleva las variables del conductor (el proceso de explorer.exe no
# hereda las de esta consola), como hace tool/t114_capturas_windows.ps1
# -PorExplorer. Por corrida: un pasos-N.jsonl, el PID, `seguir` (que mide cinco
# lecturas tras 5 s de reposo en cada paso) y `cerrar`. La primera corrida es en
# frío y se descarta en el análisis, como en T-99 (B.3).
#
#   ./tool/t114_ram_windows.ps1 -Exe "$env:TEMP\t99-r4-e2\copia\build\windows\x64\runner\Release\baystream.exe" `
#       -Salida "$env:TEMP\t114-e2\ram-despues" -Archivo T99_SINTETICO_977.edi -Corridas 6
param(
    [Parameter(Mandatory = $true)] [string] $Exe,
    [Parameter(Mandatory = $true)] [string] $Salida,
    [string] $Archivo = 'T99_SINTETICO_977.edi',
    [int] $Corridas = 6,
    [int] $PausaMs = 12000
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
$ram = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) 't99_ram_windows.ps1'
$csv = Join-Path $Salida 'ram-windows.csv'
Add-Type -Namespace T114 -Name Ventana -MemberDefinition @'
[DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr h, int cmd);
'@

for ($n = 1; $n -le $Corridas; $n++) {
    $pasos = Join-Path $Salida "pasos-$n.jsonl"
    $cmd = Join-Path $Salida "lanzar-$n.cmd"
    $lineas = @(
        '@echo off',
        "set T99_ESCENARIO=ram",
        "set T99_ARCHIVO=$Archivo",
        "set T99_PASOS=$pasos",
        "set T99_PAUSA_MS=$PausaMs",
        "start `"`" `"$exeCompleto`""
    )
    [IO.File]::WriteAllLines($cmd, $lineas, (New-Object Text.ASCIIEncoding))
    $desde = Get-Date
    Start-Process explorer.exe -ArgumentList "`"$cmd`""
    $p = $null
    for ($i = 0; $i -lt 60 -and -not $p; $i++) {
        Start-Sleep -Milliseconds 500
        $p = Get-Process -ErrorAction SilentlyContinue |
            Where-Object { $_.Path -eq $exeCompleto -and $_.StartTime -ge $desde.AddSeconds(-1) } |
            Select-Object -First 1
    }
    if (-not $p) { throw "El banco no arrancó en 30 s (corrida $n)." }
    for ($i = 0; $i -lt 40 -and $p.MainWindowHandle -eq 0; $i++) { Start-Sleep -Milliseconds 250; $p.Refresh() }
    if ($p.MainWindowHandle -ne 0) { [void][T114.Ventana]::ShowWindow($p.MainWindowHandle, 3) }
    Write-Output "Corrida $n · PID $($p.Id) · $(if ($n -eq 1) { 'en frío' } else { 'medida' })"
    & $ram -Accion seguir -AppPid $p.Id -Pasos $pasos -Salida $csv -Archivo ([IO.Path]::GetFileNameWithoutExtension($Archivo)) -Corrida $n
    & $ram -Accion cerrar -AppPid $p.Id
    Start-Sleep -Seconds 3
}
Write-Output "Lecturas en $csv"
