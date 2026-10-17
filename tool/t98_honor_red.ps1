# Preparado para Fase B. NO ejecutar durante la Fase A del 17-oct.
# UID solo en memoria: netstats crudo y UID nunca se escriben en la evidencia.
param(
  [Parameter(Mandatory=$true)][ValidateSet('antes','despues')][string]$Momento,
  [Parameter(Mandatory=$true)][ValidatePattern('^[a-z0-9_-]+$')][string]$Operacion,
  [string]$Adb = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe",
  [string]$Salida = "$env:TEMP\t98\honor",
  [string]$Paquete = 'gt.cmartinez.baystream.t98'
)
$ErrorActionPreference='Stop'
if ($Paquete -notmatch '\.t98$') { throw 'Solo el paquete aislado .t98.' }
$root=[IO.Path]::GetFullPath($Salida)
if (-not $root.StartsWith(([IO.Path]::GetFullPath($env:TEMP).TrimEnd('\')+'\'),[StringComparison]::OrdinalIgnoreCase)) { throw 'Salida fuera de TEMP.' }
$packageInfo = & $Adb shell dumpsys package $Paquete
if ($LASTEXITCODE -ne 0) { throw 'No se pudo consultar el paquete.' }
$match = [regex]::Match(($packageInfo -join "`n"),'userId=(\d+)')
if (-not $match.Success) { throw 'No se obtuvo el UID reservado.' }
$appUid=$match.Groups[1].Value
# netstats --poll puede requerir permisos; nunca asumir que quedó actualizado.
& $Adb shell dumpsys netstats --poll | Out-Null
$pollOk=$LASTEXITCODE -eq 0
$lines = & $Adb shell dumpsys netstats detail
if ($LASTEXITCODE -ne 0) { throw 'netstats no disponible.' }
$selected=[Collections.Generic.List[string]]::new()
$inBlock=$false
foreach ($line in $lines) {
  if ($line -match '\buid=(\d+)\b') {
    $inBlock=$Matches[1] -eq $appUid
  } elseif ($line -match '^\S' -and $line -notmatch '^\s') { $inBlock=$false }
  if ($inBlock) {
    # Solo números de buckets, etiquetas de tráfico y tiempo. Sin UID/ident.
    $values=[regex]::Matches($line,'\b(?:st|rb|rp|tb|tp|rxBytes|txBytes|bucketDuration|set|tag)=[A-Za-z0-9x_-]+')
    if ($values.Count -gt 0) { $selected.Add(($values.Value -join ' ')) }
  }
}
$airplane=(& $Adb shell settings get global airplane_mode_on | Out-String).Trim()
$wifi=(& $Adb shell settings get global wifi_on | Out-String).Trim()
& $Adb shell ping -c 1 -W 2 1.1.1.1 | Out-Null
$pingFailed=$LASTEXITCODE -ne 0
New-Item -ItemType Directory -Force $root | Out-Null
$file=Join-Path $root "$Operacion-$Momento.json"
if (Test-Path -LiteralPath $file) { throw 'No sobrescribir evidencia.' }
[ordered]@{ fase='Instrumento preparado; completar fase al ejecutar';
  operacion=$Operacion; momento=$Momento; utc=[DateTime]::UtcNow.ToString('o');
  pollSolicitado=$pollOk; bucketsEncontrados=$selected.Count;
  limitacion='No sumar secciones duplicadas ni comparar buckets cambiados. Validar frescura y una transferencia de control antes de dictaminar.';
  modoAvion=$airplane; wifi=$wifi; pingFalla=$pingFailed;
  sinRedVerificada=($airplane -eq '1' -and $wifi -eq '0' -and $pingFailed);
  buckets=@($selected.ToArray()) } | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $file -Encoding utf8
Write-Output 'T-98: netstats filtrado sin UID; cotejar antes/despues y segunda fuente TCP.'
