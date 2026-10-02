# T-44 (repeticion final) · RNF-004 en el Honor sin herramientas nuevas.
# Sondea /proc/net/tcp y /proc/net/tcp6 por ADB y registra cada extremo remoto
# que abre el UID de la app, con el instante en que aparece por primera vez.
# No captura contenido: solo direccion, puerto y estado TCP.
#
# Uso: powershell -File tool\t44_honor_red.ps1 -Uid 10231 -Segundos 90
#        [-Salida build\t44-final\honor-red.json]
param(
  [Parameter(Mandatory = $true)][int]$Uid,
  [int]$Segundos = 90,
  [string]$Salida = 'build\t44-final\honor-red.json',
  [string]$Adb = 'C:\Users\Giova\AppData\Local\Android\Sdk\platform-tools\adb.exe'
)
$ErrorActionPreference = 'Stop'

function Convertir-Ip([string]$hex) {
  if ($hex.Length -eq 8) {
    # IPv4 en /proc/net/tcp: 4 bytes en orden inverso.
    $b = for ($i = 6; $i -ge 0; $i -= 2) { [Convert]::ToInt32($hex.Substring($i, 2), 16) }
    return ($b -join '.')
  }
  # IPv6: cuatro palabras de 32 bits, cada una en orden inverso.
  $bytes = New-Object byte[] 16
  for ($w = 0; $w -lt 4; $w++) {
    for ($k = 0; $k -lt 4; $k++) {
      $bytes[$w * 4 + $k] = [Convert]::ToByte($hex.Substring($w * 8 + (3 - $k) * 2, 2), 16)
    }
  }
  $ip = New-Object System.Net.IPAddress (, $bytes)
  if ($ip.IsIPv4MappedToIPv6) { return $ip.MapToIPv4().ToString() }
  return $ip.ToString()
}

$estados = @{ '01' = 'ESTABLISHED'; '02' = 'SYN_SENT'; '06' = 'TIME_WAIT'; '08' = 'CLOSE_WAIT'; '0A' = 'LISTEN' }
$vistos = [ordered]@{}
$reloj = [System.Diagnostics.Stopwatch]::StartNew()
while ($reloj.Elapsed.TotalSeconds -lt $Segundos) {
  $lineas = & $Adb shell 'cat /proc/net/tcp /proc/net/tcp6'
  foreach ($l in $lineas) {
    $c = ($l.Trim() -split '\s+')
    if ($c.Count -lt 8 -or $c[0] -eq 'sl') { continue }
    if ([int]$c[7] -ne $Uid) { continue }
    $remoto = $c[2].Split(':')
    if ($remoto[0] -match '^0+$') { continue }
    $ip = Convertir-Ip $remoto[0]
    $puerto = [Convert]::ToInt32($remoto[1], 16)
    $clave = "${ip}:$puerto"
    if (-not $vistos.Contains($clave)) {
      $vistos[$clave] = [ordered]@{
        ip = $ip; puerto = $puerto
        primeraVezMs = [int]$reloj.ElapsedMilliseconds
        estado = $estados[$c[3]]
      }
      "{0,7} ms  {1}" -f $reloj.ElapsedMilliseconds, $clave
    }
  }
  Start-Sleep -Milliseconds 250
}
$lista = foreach ($v in $vistos.Values) {
  $nombre = try { (Resolve-DnsName -Type PTR $v.ip -ErrorAction Stop | Select-Object -First 1).NameHost } catch { $null }
  $v['ptr'] = $nombre
  [pscustomobject]$v
}
New-Item -ItemType Directory -Force (Split-Path $Salida) | Out-Null
[pscustomobject]@{ uid = $Uid; segundos = $Segundos; dispositivo = 'Honor X5d / Android 15'; extremos = @($lista) } |
  ConvertTo-Json -Depth 4 | Set-Content -Encoding utf8 $Salida
"Extremos remotos distintos: $($vistos.Count) -> $Salida"
