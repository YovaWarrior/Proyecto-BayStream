# T-142 · Arranca o detiene el emulador de Hosting con una variante de
# build/t142/emu-<variante>/firebase.json (las escribe tool/t142_configs.py).
# Proyecto `demo-t142`: el emulador no habla con Firebase real. Solo detiene los
# procesos de node cuya línea de órdenes lleva `demo-t142`, es decir, los suyos.
#
#   powershell -File tool/t142_emulador.ps1 -Variante despues
#   powershell -File tool/t142_emulador.ps1 -Detener
param(
  [string]$Variante = 'despues',
  [switch]$Detener
)
$ErrorActionPreference = 'Stop'
$raiz = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$salida = Join-Path $raiz 'build\t142'

Get-CimInstance Win32_Process -Filter "Name='node.exe'" |
  Where-Object { $_.CommandLine -like '*demo-t142*' } |
  ForEach-Object { Stop-Process -Id $_.ProcessId -Force }
for ($i = 0; $i -lt 20; $i++) {
  if (-not (Get-NetTCPConnection -LocalPort 5942 -State Listen -ErrorAction SilentlyContinue)) { break }
  Start-Sleep -Milliseconds 250
}
if ($Detener) { 'detenido'; return }

$carpeta = Join-Path $salida "emu-$Variante"
if (-not (Test-Path (Join-Path $carpeta 'firebase.json'))) { throw "No existe la variante $Variante" }
$log = Join-Path $salida "emu-$Variante.log"
$firebase = (Get-Command firebase.cmd).Source
Start-Process -FilePath $firebase -WorkingDirectory $carpeta -WindowStyle Hidden `
  -ArgumentList @('emulators:start', '--only', 'hosting', '--project', 'demo-t142') `
  -RedirectStandardOutput $log -RedirectStandardError "$log.err"
for ($i = 0; $i -lt 120; $i++) {
  Start-Sleep -Milliseconds 500
  if ((Test-Path $log) -and (Select-String -Path $log -Pattern 'All emulators ready' -Quiet)) { "listo: $Variante"; return }
  if ((Test-Path $log) -and (Select-String -Path $log -Pattern 'Error:' -Quiet)) { Get-Content $log -Tail 5; throw 'El emulador no arrancó' }
}
throw 'El emulador no dijo que estaba listo en 60 s'
