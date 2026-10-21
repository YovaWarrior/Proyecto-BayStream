# Observa la tanda sin cambiar adaptadores, rutas ni configuracion de red.
param(
    [ValidateRange(2, 900)][int]$Segundos = 600,
    [Parameter(Mandatory)][string]$Salida
)
$ErrorActionPreference = 'Stop'
$destino = [IO.Path]::GetFullPath($Salida)
$banco = [IO.Path]::GetFullPath("$env:TEMP/t98-b-33404a5-20oct/tanda")
if (!$destino.StartsWith($banco + [IO.Path]::DirectorySeparatorChar,
        [StringComparison]::OrdinalIgnoreCase)) { throw 'Salida fuera de la tanda T98.' }
if (Test-Path -LiteralPath $destino) { throw 'No sobrescribir evidencia.' }
New-Item -ItemType Directory -Path $banco -Force | Out-Null
$reloj = [Diagnostics.Stopwatch]::StartNew()
$muestras = [Collections.Generic.List[object]]::new()
$ping = [Net.NetworkInformation.Ping]::new()
try {
    while ($reloj.Elapsed.TotalSeconds -lt $Segundos) {
        $fila = [ordered]@{
            utc = [DateTime]::UtcNow.ToString('o')
            msDesdeInicio = $reloj.ElapsedMilliseconds
            adaptadoresFisicosActivos = $null
            rutasPredeterminadasIPv4 = $null
            pingExterno = 'no_comprobado'
            consultaAdaptadoresValida = $false
            consultaRutasValida = $false
        }
        try {
            $fila.adaptadoresFisicosActivos = @(Get-NetAdapter -Physical -ErrorAction Stop |
                Where-Object Status -EQ 'Up').Count
            $fila.consultaAdaptadoresValida = $true
        } catch { } # Error es inconcluso, nunca se convierte en cero.
        try {
            $fila.rutasPredeterminadasIPv4 = @(Get-NetRoute -AddressFamily IPv4 `
                -ErrorAction Stop | Where-Object DestinationPrefix -EQ '0.0.0.0/0').Count
            $fila.consultaRutasValida = $true
        } catch { }
        try { $fila.pingExterno = [string]$ping.Send('1.1.1.1', 800).Status }
        catch { $fila.pingExterno = 'error_sonda' }
        $muestras.Add($fila)
        Start-Sleep -Milliseconds 1000
    }
} finally { $ping.Dispose() }
[ordered]@{
    base = '33404a5804be4fad85aab80dd923a7ae9e878ee9'
    duracionRealMs = $reloj.ElapsedMilliseconds
    declaracion = 'Solo lectura. Carlos cambia Wi-Fi; el instrumento no lo cambia.'
    limite = 'Un ping fallido solo no prueba desconexion. Correlacionar adaptadores, rutas y video; no clasifica trafico ni latencia del producto.'
    muestras = @($muestras.ToArray())
} | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $destino -Encoding utf8
Write-Output "T98: $($muestras.Count) muestras de red guardadas sin direcciones locales."
