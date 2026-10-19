# Sonda de Fase A (ensayo) o B; no produce por si sola un dictamen RNF.
# UID solo en memoria: netstats crudo y UID nunca se escriben en la evidencia.
param(
  [Parameter(Mandatory=$true)][ValidateSet('antes','despues')][string]$Momento,
  [Parameter(Mandatory=$true)][ValidatePattern('^[a-z0-9_-]+$')][string]$Operacion,
  [string]$Adb = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe",
  [string]$Salida = "$env:TEMP\t98\honor",
  [string]$Paquete = 'gt.cmartinez.baystream.t98',
  [ValidateSet('A','B')][string]$Fase = 'A',
  [ValidatePattern('^$|^[0-9a-f]{7,40}$')][string]$Base = '',
  [switch]$Autoprueba
)
$ErrorActionPreference='Stop'

function Select-T98Buckets([string[]]$Lines, [string]$TargetUid) {
  $section=$null
  $inBlock=$false
  $duration=$null
  $network=0
  $set=''
  $tag=''
  foreach ($line in $Lines) {
    if ($line -match '^UID (tag )?stats:\s*$') {
      $section=if ($Matches[1]) { 'UID tag stats' } else { 'UID stats' }
      $inBlock=$false
      $network=0
      continue
    }
    if ($line -match '^\S') { $section=$null; $inBlock=$false }
    if ($null -eq $section) { continue }
    if ($line -match '^\s*ident=') { $network++; $inBlock=$false }
    if ($line -match '\buid=(\d+)\b') {
      $inBlock=$Matches[1] -eq $TargetUid
      $duration=$null
      $set=[regex]::Match($line,'\bset=([A-Za-z0-9_-]+)').Groups[1].Value
      $tag=[regex]::Match($line,'\btag=([A-Za-z0-9x_-]+)').Groups[1].Value
      continue
    }
    if (-not $inBlock) { continue }
    if ($line -match '\bbucketDuration=(\d+)') { $duration=$Matches[1] }
    # Un set del mapa BPF o un encabezado no son un bucket de trafico.
    if ($line -notmatch '\bst=\d+\b' -or
        $line -notmatch '\b(?:rb|tb|rxBytes|txBytes)=\d+\b') { continue }
    $values=[regex]::Matches($line,'\b(?:st|rb|rp|tb|tp|rxBytes|txBytes)=[0-9]+')
    [pscustomobject][ordered]@{ seccion=$section; contextoRed=$network;
      set=$set; tag=$tag; duracionBucket=$duration;
      campos=($values.Value -join ' ') }
  }
}

if ($Autoprueba) {
  # Datos sinteticos: dos secciones, otro UID, otra red y un mapa BPF.
  $fixture=@('UID stats:', '  ident=CONTEXTO_SINTETICO',
    '    uid=12001 set=DEFAULT tag=0x0',
    '      NetworkStatsHistory: bucketDuration=3600000',
    '        st=100 rb=4 rp=1 tb=8 tp=1',
    '    uid=12002 set=DEFAULT tag=0x0', '        st=100 rb=99 tb=99',
    '  ident=OTRO_CONTEXTO', '        st=100 rb=99 tb=99',
    'UID tag stats:', '  ident=CONTEXTO_SINTETICO',
    '    uid=12001 set=DEFAULT tag=0x1',
    '      NetworkStatsHistory: bucketDuration=7200000',
    '        st=200 rb=2 tb=3', 'BPF map content:',
    '    uid=12001 set=1', '        st=100 rb=999 tb=999')
  $observed=@(Select-T98Buckets $fixture '12001')
  if ($observed.Count -ne 2) { throw 'Autoprueba: atribucion o secciones incorrectas.' }
  if ($observed[0].seccion -ne 'UID stats' -or
      $observed[1].seccion -ne 'UID tag stats') { throw 'Autoprueba: mezcla de secciones.' }
  if ($observed[0].duracionBucket -ne '3600000' -or
      $observed[1].duracionBucket -ne '7200000') { throw 'Autoprueba: duracion perdida.' }
  if (($observed | ConvertTo-Json) -match '12001|12002|CONTEXTO_SINTETICO|OTRO_CONTEXTO|999|99') {
    throw 'Autoprueba: fuga de identificadores o atribucion ajena.'
  }
  if (@(Select-T98Buckets @('BPF map content:', '    uid=12001 set=1') '12001').Count -ne 0) {
    throw 'Autoprueba: un encabezado BPF cuenta como bucket.'
  }
  Write-Output 'T-98: 5 autocomprobaciones de atribucion, secciones, duracion, sanitizacion y BPF correctas.'
  return
}

if ($Paquete -notmatch '\.t98$') { throw 'Solo el paquete aislado .t98.' }
$root=[IO.Path]::GetFullPath($Salida)
if (-not $root.StartsWith(([IO.Path]::GetFullPath($env:TEMP).TrimEnd('\')+'\'),[StringComparison]::OrdinalIgnoreCase)) { throw 'Salida fuera de TEMP.' }
$packageInfo = & $Adb shell pm list packages -U $Paquete
if ($LASTEXITCODE -ne 0) { throw 'No se pudo consultar el paquete.' }
# Android 15 del Honor muestra appId, no userId, en dumpsys package.
# pm devuelve el UID completo; no se confunde con appId ni con otro paquete
# que comparta prefijo. Una atribucion ambigua se detiene, nunca cuenta cero.
$packageMatches = [regex]::Matches(($packageInfo -join "`n"),
  ('(?m)^package:'+[regex]::Escape($Paquete)+' uid:(\d+)\s*$'))
if ($packageMatches.Count -ne 1) { throw 'No se obtuvo una atribucion unica al paquete reservado.' }
$appUid=$packageMatches[0].Groups[1].Value
# netstats --poll puede requerir permisos; nunca asumir que quedó actualizado.
$pollOutput=(& $Adb shell dumpsys netstats --poll 2>&1) -join "`n"
$pollOk=$LASTEXITCODE -eq 0 -and $pollOutput -notmatch '(?i)exception|denied|unknown|error'
$lines = & $Adb shell dumpsys netstats detail
if ($LASTEXITCODE -ne 0) { throw 'netstats no disponible.' }
$selected=@(Select-T98Buckets $lines $appUid)
# Segunda fuente puntual: sin extremos remotos, UID ni contenido en la salida.
$tcp=(& $Adb shell 'cat /proc/net/tcp /proc/net/tcp6' 2>&1) -join "`n"
$tcpOk=$LASTEXITCODE -eq 0 -and $tcp -match '(?m)^\s*sl\s' -and
  $tcp -notmatch '(?i)denied|error|not found'
$tcpCount=$null
if ($tcpOk) {
  $tcpCount=0
  foreach ($line in ($tcp -split "`n")) {
    $columns=$line.Trim() -split '\s+'
    if ($line -match '^\s*\d+:' -and $columns.Count -ge 8 -and
        $columns[7] -eq $appUid) { $tcpCount++ }
  }
}
$airplane=(& $Adb shell settings get global airplane_mode_on | Out-String).Trim()
$wifi=(& $Adb shell settings get global wifi_on | Out-String).Trim()
& $Adb shell ping -c 1 -W 2 1.1.1.1 | Out-Null
$pingFailed=$LASTEXITCODE -ne 0
New-Item -ItemType Directory -Force $root | Out-Null
$file=Join-Path $root "$Operacion-$Momento.json"
if (Test-Path -LiteralPath $file) { throw 'No sobrescribir evidencia.' }
[ordered]@{ fase=$Fase; base=$Base; paquete=$Paquete;
  atribucion='pm list packages -U, coincidencia exacta; UID solo en memoria';
  operacion=$Operacion; momento=$Momento; utc=[DateTime]::UtcNow.ToString('o');
  pollSolicitado=$pollOk; bucketsEncontrados=$selected.Count;
  estadoHistorial=if ($selected.Count) { 'buckets atribuibles; validar frescura' } else { 'sin historial atribuible; no equivale a cero trafico' };
  consultaTcpValida=$tcpOk; filasTcpAtribuidas=$tcpCount;
  limitacion='No sumar secciones duplicadas ni comparar buckets cambiados. Validar frescura y una transferencia de control antes de dictaminar.';
  modoAvion=$airplane; wifi=$wifi; pingFalla=$pingFailed;
  sinRedVerificada=($airplane -eq '1' -and $wifi -eq '0' -and $pingFailed);
  buckets=$selected } | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $file -Encoding utf8
Write-Output 'T-98: netstats filtrado sin UID; cotejar antes/despues y segunda fuente TCP.'
