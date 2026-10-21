# Worker elevado de la tanda autorizada. No captura pantalla ni automatiza UAC.
param(
    [ValidatePattern('^tls-0[1-9]$')]
    [string]$Ronda = 'tls-01'
)
$ErrorActionPreference = 'Stop'
$raiz = Join-Path 'C:\Users\Giova\AppData\Local\Temp\t98-b-33404a5-20oct\tanda' $Ronda
$identidad = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = [Security.Principal.WindowsPrincipal]::new($identidad)
if (!$principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    throw 'Se requiere la aprobacion de administrador de Carlos.'
}
if (!(Test-Path -LiteralPath $raiz) -or (Test-Path -LiteralPath "$raiz\estado.json")) {
    throw 'Banco no preparado o ya utilizado; no sobrescribir.'
}
$iniciada = $false
$filtrosPropios = [Collections.Generic.List[string]]::new()
function Estado($fase, $detalle) {
    [ordered]@{ fase=$fase; detalle=$detalle; utc=[DateTime]::UtcNow.ToString('o') } |
        ConvertTo-Json | Set-Content -LiteralPath "$raiz\estado.json" -Encoding utf8
}
function Pkt([string[]]$Argumentos) {
    $salida = & pktmon @Argumentos 2>&1 | Out-String
    if ($LASTEXITCODE -ne 0) { throw "pktmon fallo: $($Argumentos[0])" }
    return $salida
}
try {
    $previo = Pkt @('status')
    $filtrosPrevios = Pkt @('filter','list')
    $previo | Set-Content -LiteralPath "$raiz\estado-previo.txt" -Encoding utf8
    $filtrosPrevios | Set-Content -LiteralPath "$raiz\filtros-previos.txt" -Encoding utf8
    Estado 'preflight' 'Esperando revision del estado y filtros por Codex.'
    $espera = [Diagnostics.Stopwatch]::StartNew()
    while (!(Test-Path -LiteralPath "$raiz\iniciar") -and $espera.Elapsed.TotalSeconds -lt 600) {
        Start-Sleep -Milliseconds 250
    }
    if (!(Test-Path -LiteralPath "$raiz\iniciar")) { throw 'No se autorizo iniciar tras la revision.' }
    if ((Pkt @('status')).Trim() -ne $previo.Trim() -or
        (Pkt @('filter','list')).Trim() -ne $filtrosPrevios.Trim()) {
        throw 'El estado global cambio desde la revision; no iniciar.'
    }
    foreach ($par in @(@('t98_https','TCP'), @('t98_quic','UDP'))) {
        Pkt @('filter','add',$par[0],'-t',$par[1],'-p','443') | Out-Null
        $filtrosPropios.Add($par[0])
    }
    Pkt @('start','--capture','--comp','nics','--pkt-size','0',
        '--file-size','128','--file-name',"$raiz\t98-tls.etl") |
        Set-Content -LiteralPath "$raiz\inicio.txt" -Encoding utf8
    $iniciada = $true
    Estado 'capturando' 'NIC TCP/UDP 443; sin pantalla. Limite automatico 1800 s.'
    $captura = [Diagnostics.Stopwatch]::StartNew()
    while (!(Test-Path -LiteralPath "$raiz\detener") -and $captura.Elapsed.TotalSeconds -lt 1800) {
        Start-Sleep -Milliseconds 250
    }
    $motivo = if (Test-Path -LiteralPath "$raiz\detener") { 'solicitado' } else { 'limite_1800s' }
    Pkt @('stop') | Set-Content -LiteralPath "$raiz\cierre.txt" -Encoding utf8
    $iniciada = $false
    Estado 'detenida' $motivo
} catch {
    Estado 'fallo' ([string]$_.Exception.Message)
} finally {
    if ($iniciada) {
        try { Pkt @('stop') | Set-Content -LiteralPath "$raiz\cierre-emergencia.txt" -Encoding utf8 }
        catch { Estado 'fallo_cierre' 'Revisar captura propia con Carlos.' }
    }
    foreach ($nombre in $filtrosPropios) {
        try { Pkt @('filter','remove',$nombre) | Out-Null }
        catch { Estado 'fallo_limpieza' "Revisar filtro propio $nombre con Carlos." }
    }
}
