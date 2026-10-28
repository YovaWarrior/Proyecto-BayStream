# T-126 · El emulador de Firestore de la Expo, con su consola encendida.
#
# Copia de tool/t113_emulador.ps1 (ese no cambia) con la consola del emulador
# en http://127.0.0.1:4000: ahí se ven, mientras corren las baterías de
# reglas, las peticiones que llegan a Firestore y si las reglas las
# permitieron o las negaron. Solo el emulador de Firestore, en 127.0.0.1:8181,
# con el proyecto demo-expo, que no existe en la nube: la CLI no inicia sesión
# ni toca baystream-app. La configuración vive en %TEMP%\expo\emu, no en el
# firebase.json de la raíz.
#
# Uso (deja el emulador en primer plano):
#
#     powershell -File tool/expo_emulador.ps1 [-Proyecto demo-expo] [-Puerto 8181] [-PuertoConsola 4000]
#
# Después, en otra consola:
#
#     node tool/t80_reglas.mjs 8181 demo-expo
#     node tool/t113_reglas_abuso.mjs 8181 demo-expo
#
# Se apaga con Ctrl+C en esta consola: la CLI cierra el emulador y la consola
# y dice que terminó. La primera vez descarga la consola (ui-v*.zip) en
# %USERPROFILE%\.cache\firebase\emulators; desde entonces arranca sin internet.
#
# El JAR del emulador, con Windows en español, necesita -Duser.language=en
# (T-80, sección 1: sin él responde HTTP 500 por JValidationMessages).

param(
  [string]$Proyecto = 'demo-expo',
  [int]$Puerto = 8181,
  [int]$PuertoConsola = 4000
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

$dir = Join-Path $env:TEMP 'expo\emu'
New-Item -ItemType Directory -Force $dir | Out-Null
$config = @{
  emulators = @{
    firestore = @{ host = '127.0.0.1'; port = $Puerto }
    ui = @{ enabled = $true; host = '127.0.0.1'; port = $PuertoConsola }
    singleProjectMode = $true
  }
} | ConvertTo-Json -Depth 5
[IO.File]::WriteAllText((Join-Path $dir 'firebase.json'), $config)

Write-Host "Consola del emulador: http://127.0.0.1:$PuertoConsola/firestore (pestaña Requests)"
Write-Host "Baterías: node tool/t80_reglas.mjs $Puerto $Proyecto"
Write-Host "          node tool/t113_reglas_abuso.mjs $Puerto $Proyecto"
Write-Host 'Para apagarlo: Ctrl+C en esta consola.'

Set-Location $dir
& firebase emulators:start --only firestore --project $Proyecto
