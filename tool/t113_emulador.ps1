# T-113 · Levanta el emulador local de Firestore para la batería de reglas.
#
# Solo el emulador, en 127.0.0.1:8181, con un proyecto `demo-*` que no existe
# en la nube: la CLI no inicia sesión ni toca baystream-app. La configuración
# vive en %TEMP%\t113\emu, no en el firebase.json de la raíz.
#
# Uso (deja el emulador en primer plano; se cierra con Ctrl+C o por su PID):
#
#     powershell -File tool/t113_emulador.ps1 [-Proyecto demo-t113] [-Puerto 8181]
#
# Después, en otra consola:
#
#     node tool/t80_reglas.mjs 8181 demo-t113
#
# El JAR del emulador, con Windows en español, necesita -Duser.language=en
# (T-80, sección 1: sin él responde HTTP 500 por JValidationMessages).

param(
  [string]$Proyecto = 'demo-t113',
  [int]$Puerto = 8181
)

if (-not $Proyecto.StartsWith('demo-')) {
  Write-Error 'Solo un proyecto demo- del emulador.'
  exit 2
}

$jbr = 'C:\Program Files\Android\Android Studio\jbr\bin'
if (-not (Get-Command java -ErrorAction SilentlyContinue)) {
  if (-not (Test-Path "$jbr\java.exe")) {
    Write-Error 'No hay Java: el emulador de Firestore lo necesita.'
    exit 3
  }
  $env:PATH = "$jbr;$env:PATH"
}
$env:JAVA_TOOL_OPTIONS = '-Duser.language=en -Duser.country=US'

$dir = Join-Path $env:TEMP 't113\emu'
New-Item -ItemType Directory -Force $dir | Out-Null
$config = @{
  emulators = @{
    firestore = @{ host = '127.0.0.1'; port = $Puerto }
    ui = @{ enabled = $false }
    singleProjectMode = $true
  }
} | ConvertTo-Json -Depth 5
[IO.File]::WriteAllText((Join-Path $dir 'firebase.json'), $config)

Set-Location $dir
& firebase emulators:start --only firestore --project $Proyecto
