# Solo metadatos de sockets. No captura payload ni demuestra ausencia de tráfico.
param(
  [Parameter(Mandatory=$true)][ValidateRange(1,2147483647)][int]$AppPid,
  [ValidateRange(1,3600)][int]$Segundos = 30,
  [ValidateRange(50,5000)][int]$IntervaloMs = 200,
  [Parameter(Mandatory=$true)][ValidatePattern('^[a-z0-9_-]+$')][string]$Operacion,
  [ValidateSet('A','B','autoprueba')][string]$Condicion = 'A',
  [ValidateSet('A','B')][string]$Fase = 'A',
  [ValidatePattern('^$|^[0-9a-f]{7,40}$')][string]$Base = '',
  [string]$Salida = "$env:TEMP\t98\red-windows.json"
)
$ErrorActionPreference = 'Stop'
$target = [IO.Path]::GetFullPath($Salida)
$tempRoot = [IO.Path]::GetFullPath($env:TEMP).TrimEnd('\') + '\'
if (-not $target.StartsWith($tempRoot,[StringComparison]::OrdinalIgnoreCase)) { throw 'Salida fuera de TEMP.' }
if (Test-Path -LiteralPath $target) { throw 'No sobrescribir evidencia.' }
$process = Get-Process -Id $AppPid -ErrorAction Stop
if ($Condicion -ne 'autoprueba' -and ($process.ProcessName -ne 'baystream' -or $process.Path -notmatch '(?i)[\\/]t98[^\\/]*[\\/]')) {
  throw 'Se requiere el PID de un cliente BayStream en una carpeta t98, nunca la app real/demo17.'
}
$started = $process.StartTime.ToUniversalTime()
$startedUtc = [DateTime]::UtcNow
$clock = [Diagnostics.Stopwatch]::StartNew()
$samples = [Collections.Generic.List[object]]::new()
$errors = [Collections.Generic.List[object]]::new()
$exited = $false
while ($clock.Elapsed.TotalSeconds -lt $Segundos) {
  try {
    $current = Get-Process -Id $AppPid -ErrorAction Stop
    if ($current.StartTime.ToUniversalTime() -ne $started) { $exited = $true; break }
  } catch { $exited = $true; break }
  # Enumeración completa con ErrorAction Stop: cero conexiones no se confunde
  # con un error del proveedor. Después se filtra por el PID reservado.
  foreach ($protocol in @('TCP','UDP')) {
    try {
      $all = if ($protocol -eq 'TCP') { @(Get-NetTCPConnection -ErrorAction Stop) } else { @(Get-NetUDPEndpoint -ErrorAction Stop) }
      $endpoints = @($all | Where-Object OwningProcess -eq $AppPid | ForEach-Object {
        if ($protocol -eq 'TCP') {
          [ordered]@{ localAddress=$_.LocalAddress; localPort=$_.LocalPort; remoteAddress=$_.RemoteAddress; remotePort=$_.RemotePort; state="$($_.State)" }
        } else { [ordered]@{ localAddress=$_.LocalAddress; localPort=$_.LocalPort } }
      })
      $samples.Add([ordered]@{ ms=$clock.ElapsedMilliseconds; protocolo=$protocol; sockets=$endpoints })
    } catch {
      # No persistir mensajes del SO: pueden contener rutas o información ajena.
      $errors.Add([ordered]@{ ms=$clock.ElapsedMilliseconds; protocolo=$protocol; error='consulta_no_disponible' })
    }
  }
  Start-Sleep -Milliseconds $IntervaloMs
}
New-Item -ItemType Directory -Force (Split-Path $target) | Out-Null
[ordered]@{ fase=$Fase; base=$Base; operacion=$Operacion; condicion=$Condicion;
  inicioUtc=$startedUtc.ToString('o'); finUtc=[DateTime]::UtcNow.ToString('o');
  intervaloSolicitadoMs=$IntervaloMs; duracionRealMs=$clock.ElapsedMilliseconds;
  pidTermino=$exited; consultasValidas=$samples.Count; errores=@($errors.ToArray());
  limitacion='Muestreo de sockets: pierde conexiones breves; UDP no da destino ni bytes. No clasifica contenido ni prueba cero transmisiones.';
  muestras=@($samples.ToArray()) } | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $target -Encoding utf8
Write-Output "T-98: $($samples.Count) consultas; $($errors.Count) errores; metadatos en TEMP."
