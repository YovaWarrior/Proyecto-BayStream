# T-62 · Crea el archivo privado de opciones de H5 FUERA del repositorio,
# copiando los valores que hoy estan en lib/main.dart. No imprime ningun valor:
# solo los nombres de las claves y si quedaron con contenido.
#
# Uso: powershell -File tool\t62_h5_opciones.ps1
#      [-Destino C:\Proyectos\baystream-privado\h5-temporal.json]
param(
  [string]$Destino = 'C:\Proyectos\baystream-privado\h5-temporal.json'
)
$ErrorActionPreference = 'Stop'
$repo = Split-Path -Parent $PSScriptRoot
$destinoCompleto = [System.IO.Path]::GetFullPath($Destino)
if ($destinoCompleto.StartsWith([System.IO.Path]::GetFullPath($repo), 'OrdinalIgnoreCase')) {
  throw 'El archivo de opciones no puede quedar dentro del repositorio.'
}
$main = Get-Content (Join-Path $repo 'lib\main.dart') -Raw

function Bloque([string]$nombre) {
  $m = [regex]::Match($main, "const $nombre = FirebaseOptions\((.*?)\);", 'Singleline')
  if (-not $m.Success) { throw "No se encontro $nombre en lib/main.dart" }
  $m.Groups[1].Value
}
function Valor([string]$bloque, [string]$campo) {
  $m = [regex]::Match($bloque, "$campo\s*:\s*'([^']*)'")
  if ($m.Success) { $m.Groups[1].Value } else { '' }
}

$web = Bloque '_firebaseWebOptions'
$android = Bloque '_firebaseAndroidOptions'
$opciones = [ordered]@{
  H5_API_KEY             = Valor $web 'apiKey'
  H5_PROJECT_ID          = Valor $web 'projectId'
  H5_MESSAGING_SENDER_ID = Valor $web 'messagingSenderId'
  H5_STORAGE_BUCKET      = Valor $web 'storageBucket'
  H5_AUTH_DOMAIN         = Valor $web 'authDomain'
  H5_WEB_APP_ID          = Valor $web 'appId'
  H5_ANDROID_APP_ID      = Valor $android 'appId'
}
# Las dos plataformas comparten clave, proyecto y emisor; si no, mejor saberlo.
foreach ($campo in 'apiKey', 'projectId', 'messagingSenderId') {
  if ((Valor $web $campo) -ne (Valor $android $campo)) {
    throw "Web y Android difieren en $campo; revisar a mano."
  }
}
New-Item -ItemType Directory -Force (Split-Path $destinoCompleto) | Out-Null
# Sin BOM: Set-Content -Encoding utf8 lo agrega en PowerShell 5.1.
[System.IO.File]::WriteAllText($destinoCompleto, ($opciones | ConvertTo-Json),
  (New-Object System.Text.UTF8Encoding($false)))
foreach ($k in $opciones.Keys) {
  "{0,-24} {1}" -f $k, $(if ($opciones[$k]) { 'con valor' } else { 'VACIO' })
}
"Escrito: $destinoCompleto"
