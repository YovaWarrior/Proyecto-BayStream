# T-47: genera las opciones de produccion FUERA del repositorio.
# Nunca imprime valores ni incluye los archivos privados en el control de versiones.
param(
  [string]$WebConfig = 'C:\Proyectos\baystream-privado\firebase-prod-web.txt',
  [string]$AndroidConfig = 'C:\Proyectos\baystream-privado\google-services.json',
  [string]$Destino = 'C:\Proyectos\baystream-privado\firebase-prod.json'
)
$ErrorActionPreference = 'Stop'
$repo = [System.IO.Path]::GetFullPath((Split-Path -Parent $PSScriptRoot)).TrimEnd('\', '/')
foreach ($ruta in $WebConfig, $AndroidConfig, $Destino) {
  $completa = [System.IO.Path]::GetFullPath($ruta)
  if ($completa.Equals($repo, 'OrdinalIgnoreCase') -or
      $completa.StartsWith($repo + [System.IO.Path]::DirectorySeparatorChar, 'OrdinalIgnoreCase')) {
    throw 'Las entradas y las opciones privadas deben estar fuera del repositorio.'
  }
}
try {
  $webTexto = [System.IO.File]::ReadAllText([System.IO.Path]::GetFullPath($WebConfig))
  $android = [System.IO.File]::ReadAllText([System.IO.Path]::GetFullPath($AndroidConfig)) | ConvertFrom-Json
} catch {
  throw 'No se pudieron leer las configuraciones privadas. Revisa las rutas y el formato.'
}
$patron = @'
(?m)^\s*(apiKey|authDomain|projectId|storageBucket|messagingSenderId|appId)\s*:\s*["']([^"'\r\n]+)["']
'@
$web = @{}
foreach ($m in [regex]::Matches($webTexto, $patron.Trim())) {
  $nombre = $m.Groups[1].Value
  if ($web.ContainsKey($nombre)) { throw "Campo Web duplicado: $nombre." }
  $web[$nombre] = $m.Groups[2].Value
}
$clientes = @($android.client | Where-Object {
  $_.client_info.android_client_info.package_name -eq 'gt.cmartinez.baystream'
})
if ($clientes.Count -ne 1) { throw 'Debe existir un unico cliente Android para gt.cmartinez.baystream.' }
$cliente = $clientes[0]
$clavesAndroid = @($cliente.api_key)
if ($clavesAndroid.Count -ne 1) { throw 'El cliente Android debe tener una unica clave API; revisar a mano.' }
if ($web['projectId'] -ne 'baystream-app' -or $android.project_info.project_id -ne 'baystream-app') {
  throw 'Las dos configuraciones deben pertenecer al proyecto de produccion baystream-app.'
}
if ($web['messagingSenderId'] -ne [string]$android.project_info.project_number) {
  throw 'Web y Android difieren en el emisor; revisar a mano.'
}
$opciones = [ordered]@{
  FIREBASE_WEB_API_KEY = $web['apiKey']
  FIREBASE_WEB_APP_ID = $web['appId']
  FIREBASE_WEB_MESSAGING_SENDER_ID = $web['messagingSenderId']
  FIREBASE_WEB_PROJECT_ID = $web['projectId']
  FIREBASE_WEB_AUTH_DOMAIN = $web['authDomain']
  FIREBASE_WEB_STORAGE_BUCKET = $web['storageBucket']
  FIREBASE_ANDROID_API_KEY = $clavesAndroid[0].current_key
  FIREBASE_ANDROID_APP_ID = $cliente.client_info.mobilesdk_app_id
  FIREBASE_ANDROID_MESSAGING_SENDER_ID = [string]$android.project_info.project_number
  FIREBASE_ANDROID_PROJECT_ID = $android.project_info.project_id
  FIREBASE_ANDROID_STORAGE_BUCKET = $android.project_info.storage_bucket
}
foreach ($k in $opciones.Keys) {
  if ([string]::IsNullOrWhiteSpace([string]$opciones[$k])) { throw "Falta la opcion $k." }
}
$destinoCompleto = [System.IO.Path]::GetFullPath($Destino)
try {
  New-Item -ItemType Directory -Force (Split-Path -Parent $destinoCompleto) | Out-Null
  [System.IO.File]::WriteAllText($destinoCompleto, ($opciones | ConvertTo-Json),
    (New-Object System.Text.UTF8Encoding($false)))
} catch {
  throw 'No se pudo escribir el archivo privado de opciones.'
}
foreach ($k in $opciones.Keys) { "{0,-34} con valor" -f $k }
"Escrito: $destinoCompleto"
