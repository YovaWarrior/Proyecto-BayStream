# No compila ni instala. Usa SOLO un binario t98 preparado en la copia limpia.
param(
  [Parameter(Mandatory=$true)][ValidateSet('abrir','cerrar','grabar')][string]$Accion,
  [string]$Exe,
  [int]$AppPid,
  [string]$Ffmpeg = 'ffmpeg',
  [ValidateRange(1,600)][int]$Segundos = 30,
  [string]$Salida = "$env:TEMP\t98\pantalla.mkv"
)
$ErrorActionPreference='Stop'
if ($Accion -eq 'abrir') {
  $exePath=(Resolve-Path -LiteralPath $Exe).Path
  if ($exePath -notmatch '(?i)[\\/]t98[^\\/]*[\\/]' -or $exePath -match '(?i)demo17' -or [IO.Path]::GetFileName($exePath) -ne 'baystream.exe') { throw 'Solo binario aislado bajo carpeta t98.' }
  if (@(Get-Process baystream -ErrorAction SilentlyContinue).Count -gt 0) { throw 'Ya hay una app BayStream abierta; coordinar con Carlos.' }
  Start-Process explorer.exe -ArgumentList ('"'+$exePath+'"') -WindowStyle Hidden
  Write-Output 'Abierta mediante explorer.exe. Consultar y anotar su PID y almacén real; no usar Stop-Process por nombre.'
} elseif ($Accion -eq 'cerrar') {
  if ($AppPid -lt 1) { throw 'Indicar PID reservado.' }
  $app=Get-Process -Id $AppPid
  if ($app.Path -notmatch '(?i)[\\/]t98[^\\/]*[\\/]' -or $app.Path -match '(?i)demo17' -or $app.ProcessName -ne 'baystream') { throw 'PID fuera del cliente t98.' }
  Stop-Process -Id $AppPid
} else {
  $target=[IO.Path]::GetFullPath($Salida)
  if (-not $target.StartsWith(([IO.Path]::GetFullPath($env:TEMP).TrimEnd('\')+'\'),[StringComparison]::OrdinalIgnoreCase)) { throw 'Salida fuera de TEMP.' }
  if (Test-Path -LiteralPath $target) { throw 'No sobrescribir evidencia.' }
  New-Item -ItemType Directory -Force (Split-Path $target) | Out-Null
  # Carlos prepara un escritorio sin cuentas ni notificaciones personales.
  # El login se realiza ANTES de grabar; no capturar correo ni contraseña.
  & $Ffmpeg -hide_banner -loglevel error -n -f gdigrab -framerate 30 -i desktop -t $Segundos -c:v ffv1 $target
  if ($LASTEXITCODE -ne 0) { throw 'La captura falló; no hay evidencia válida.' }
}
