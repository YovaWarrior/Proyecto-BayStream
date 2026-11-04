# T-136 - Comprueba que el SDK de C++ de Firebase extraido en build\ es el que
# pide el firebase_core resuelto.
#
# El windows\CMakeLists.txt de firebase_core descarga el zip de su version, pero
# si build\windows\x64\extracted ya existe no lo extrae ("Using cached extracted
# Firebase SDK") y enlaza lo que haya ahi (SPRINT-4.md, 10.99). Sin este paso, un
# firebase_core nuevo puede seguir enlazando un SDK viejo sin que nada lo diga.
#
# Uso: powershell -NoProfile -ExecutionPolicy Bypass -File tool\t136_sdk_firebase.ps1
#        (-Apartar | -Verificar) [-Proyecto <carpeta del proyecto>]
# -Apartar:   si extracted existe y su version no es la pedida, lo renombra a
#             extracted-<version>. No borra nada.
# -Verificar: se detiene si las dos versiones no son iguales o si falta version.h.
[CmdletBinding()]
param(
  [string]$Proyecto,
  [Parameter(Mandatory, ParameterSetName = 'Apartar')][switch]$Apartar,
  [Parameter(Mandatory, ParameterSetName = 'Verificar')][switch]$Verificar
)
$ErrorActionPreference = 'Stop'
# Aqui y no en param(): con -File, PowerShell 5.1 deja $PSScriptRoot vacio ahi.
if (-not $Proyecto) { $Proyecto = Split-Path -Parent $PSScriptRoot }

# La version que pide el firebase_core resuelto en .dart_tool\package_config.json.
function Get-VersionPedida {
  param([Parameter(Mandatory)][string]$Raiz)
  $archivo = Join-Path $Raiz '.dart_tool\package_config.json'
  if (-not (Test-Path -LiteralPath $archivo -PathType Leaf)) {
    throw "No existe $archivo. Corra flutter pub get primero."
  }
  $config = Get-Content -LiteralPath $archivo -Raw -Encoding UTF8 | ConvertFrom-Json
  $paquete = @($config.packages | Where-Object { $_.name -eq 'firebase_core' })
  if ($paquete.Count -ne 1) {
    throw "firebase_core no esta en $archivo."
  }
  # rootUri puede ser absoluta o relativa a la carpeta del archivo.
  $base = New-Object System.Uri((Get-Item -LiteralPath $archivo).FullName)
  $carpeta = (New-Object System.Uri($base, [string]$paquete[0].rootUri)).LocalPath
  $cmake = Join-Path $carpeta 'windows\CMakeLists.txt'
  if (-not (Test-Path -LiteralPath $cmake -PathType Leaf)) {
    throw "No existe $cmake."
  }
  $texto = Get-Content -LiteralPath $cmake -Raw
  $version = [regex]::Match($texto, 'set\(\s*FIREBASE_SDK_VERSION\s+"(\d+\.\d+\.\d+)"\s*\)')
  if (-not $version.Success) {
    throw "No se encontro FIREBASE_SDK_VERSION en $cmake."
  }
  return $version.Groups[1].Value
}

# La version de version.h, o $null si falta el archivo o no se puede leer.
function Get-VersionExtraida {
  param([Parameter(Mandatory)][string]$Extraido)
  $archivo = Join-Path $Extraido 'firebase_cpp_sdk_windows\include\firebase\version.h'
  if (-not (Test-Path -LiteralPath $archivo -PathType Leaf)) { return $null }
  $texto = Get-Content -LiteralPath $archivo -Raw
  $partes = foreach ($nombre in 'MAJOR', 'MINOR', 'REVISION') {
    $parte = [regex]::Match($texto, "#define\s+FIREBASE_VERSION_$nombre\s+(\d+)")
    if (-not $parte.Success) { return $null }
    $parte.Groups[1].Value
  }
  return $partes -join '.'
}

$raiz = (Get-Item -LiteralPath $Proyecto).FullName
$extraido = Join-Path $raiz 'build\windows\x64\extracted'
$pedida = Get-VersionPedida -Raiz $raiz
$hallada = Get-VersionExtraida -Extraido $extraido

if ($Apartar) {
  if (-not (Test-Path -LiteralPath $extraido)) {
    Write-Host "SDK de Firebase: no hay extracted. La compilacion extrae el $pedida."
    return
  }
  if ($hallada -eq $pedida) {
    Write-Host "SDK de Firebase: extracted ya es el $pedida."
    return
  }
  # Sin version.h, la extraccion quedo a medias: CMake la daria por buena igual.
  $sufijo = if ($hallada) { $hallada } else { 'desconocida' }
  $destino = "$extraido-$sufijo"
  if (Test-Path -LiteralPath $destino) {
    throw "No se aparta extracted: ya existe $destino. Pedida: $pedida. Extraida: $sufijo."
  }
  Rename-Item -LiteralPath $extraido -NewName (Split-Path -Leaf $destino)
  Write-Host "SDK de Firebase: extracted ($sufijo) apartado a $destino. La compilacion extrae el $pedida."
  return
}

if (-not $hallada) {
  throw "SDK de Firebase: falta version.h en $extraido. Pedida: $pedida. Extraida: ninguna."
}
if ($hallada -ne $pedida) {
  throw "SDK de Firebase: el extraido no es el pedido. Pedida: $pedida. Extraida: $hallada."
}
Write-Host "SDK de Firebase: pedida $pedida, extraida $hallada."
