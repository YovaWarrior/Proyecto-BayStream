param(
    [Parameter(Mandatory)]
    [ValidatePattern('^(max-)?sin0[1-5]$')]
    [string]$Corrida
)
$ErrorActionPreference = 'Stop'
# Solo cierra el binario propio y aparta su almacén TEMP. No automatiza UI.
$banco = [IO.Path]::GetFullPath("$env:TEMP/t98-b-33404a5-20oct")
$exe = [IO.Path]::GetFullPath("$banco/app/build/windows/x64/runner/Release/baystream.exe")
$origen = [IO.Path]::GetFullPath("$banco/store-windows")
$destino = [IO.Path]::GetFullPath("$banco/primera/almacenes/anterior-a-$Corrida")
foreach ($ruta in @($exe, $origen, $destino)) {
    if (!$ruta.StartsWith($banco + [IO.Path]::DirectorySeparatorChar,
            [StringComparison]::OrdinalIgnoreCase)) { throw 'Ruta fuera del banco T98.' }
}
if (!(Test-Path -LiteralPath $origen) -or (Test-Path -LiteralPath $destino)) {
    throw 'Almacén ausente o respaldo existente; no sobrescribir.'
}
$propios = @(Get-CimInstance Win32_Process -Filter "Name='baystream.exe'" |
    Where-Object ExecutablePath -EQ $exe)
if ($propios.Count -ne 1) { throw 'Se requiere un único PID del binario T98.' }
$proceso = Get-Process -Id $propios[0].ProcessId
Stop-Process -Id $proceso.Id
$proceso.WaitForExit()
$quedan = @(Get-CimInstance Win32_Process -Filter "Name='baystream.exe'" |
    Where-Object ExecutablePath -EQ $exe)
if ($quedan.Count) { throw 'La app propia sigue abierta; no mover el almacén.' }
New-Item -ItemType Directory -Path (Split-Path -Parent $destino) -Force | Out-Null
Move-Item -LiteralPath $origen -Destination $destino
if (Test-Path -LiteralPath $origen) { throw 'El almacén anterior sigue presente.' }
[ordered]@{
    base = '33404a5804be4fad85aab80dd923a7ae9e878ee9'
    corrida = $Corrida
    pidCerrado = $proceso.Id
    respaldo = $destino
    archivosApartados = @(Get-ChildItem -LiteralPath $destino -File -Recurse).Count
    sinAlmacenAntesDeAbrir = $true
    utcHostSoloTrazabilidad = [DateTime]::UtcNow.ToString('o')
} | ConvertTo-Json | Set-Content -LiteralPath "$destino.preparacion.json" -Encoding utf8
Write-Output "T98: $Corrida preparada sin almacén previo; PID propio cerrado."
