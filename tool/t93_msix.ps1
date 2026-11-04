# T-93 - Arma el instalador MSIX firmado de BayStream para Windows.
#
# 1. flutter build windows --release con las opciones de Firebase (archivo
#    privado, fuera del repositorio; no se abre ni se imprime).
# 2. dart run msix:create sobre esa compilacion, firmado con el certificado de
#    Carlos por su huella (/sha1): signtool toma la clave del almacen de usuario
#    sin exportarla. Sin .pfx, sin contrasena y sin tocar almacenes.
# 3. Deja el .msix y su .sha256; verifica SHA-256, firma Valid y huella.
#
# Uso: powershell -NoProfile -ExecutionPolicy Bypass -File tool\t93_msix.ps1
#        -Huella <40 hexadecimales> [-Version 1.0.0.0]
#        [-Opciones C:\Proyectos\baystream-privado\firebase-prod.json]
#        [-SinCompilar]
# Solo verificar: -Huella <40 hexadecimales> -Verificar <ruta del .msix>
# No necesita Flutter ni comprueba las opciones de Firebase en ese modo.
[CmdletBinding(DefaultParameterSetName = 'Armar')]
param(
  [Parameter(Mandatory)][string]$Huella,
  [Parameter(ParameterSetName = 'Armar')][string]$Version = '1.0.0.0',
  [Parameter(ParameterSetName = 'Armar')]
  [string]$Opciones = 'C:\Proyectos\baystream-privado\firebase-prod.json',
  # Reempaqueta la compilacion Release que ya existe (solo si se hizo con
  # las mismas opciones de Firebase).
  [Parameter(ParameterSetName = 'Armar')][switch]$SinCompilar,
  [Parameter(Mandatory, ParameterSetName = 'Verificar')][string]$Verificar
)
$ErrorActionPreference = 'Stop'

function Test-PaqueteMsix {
  param(
    [Parameter(Mandatory)][string]$Ruta,
    [Parameter(Mandatory)][string]$HuellaEsperada
  )
  if (-not (Test-Path -LiteralPath $Ruta -PathType Leaf)) {
    throw "No existe el paquete: $Ruta. Status: NoDisponible. StatusMessage: No se pudo consultar la firma."
  }
  $paquete = (Get-Item -LiteralPath $Ruta).FullName
  $firma = Get-AuthenticodeSignature -LiteralPath $paquete
  $detalle = "Status: $($firma.Status). StatusMessage: $($firma.StatusMessage)"
  $sha = (Get-FileHash -LiteralPath $paquete -Algorithm SHA256).Hash
  $errores = @()
  $archivoSha = "$paquete.sha256"
  if (-not (Test-Path -LiteralPath $archivoSha -PathType Leaf)) {
    $errores += 'Falta el archivo .sha256 del paquete.'
  } else {
    [string]$contenidoSha = Get-Content -LiteralPath $archivoSha -Raw
    $entradaSha = [regex]::Match($contenidoSha.Trim(), '\A([0-9A-Fa-f]{64})(?:[ \t]+\*?[^\r\n]+)?\z')
    if (-not $entradaSha.Success) {
      $errores += 'El archivo .sha256 no contiene un SHA-256 valido en una sola linea.'
    } elseif ($sha -ne $entradaSha.Groups[1].Value) {
      $errores += 'El SHA-256 del paquete no coincide con su .sha256.'
    }
  }
  if ($firma.Status -ne 'Valid') {
    if ($firma.Status -eq 'HashMismatch') {
      $errores += 'El paquete esta alterado o danado; no se distribuye.'
    } elseif ($firma.Status -eq 'NotTrusted') {
      $errores += 'La firma no es de confianza. Primero importe BayStream.cer en Personas de confianza del equipo local.'
    } elseif ($firma.Status -eq 'UnknownError') {
      # T-88: una raiz que no esta en ningun almacen da UnknownError, no
      # NotTrusted (GetSignatureStatusFromWin32Error). No se afirma la causa.
      $errores += 'La firma no es de confianza en este equipo o no se pudo validar. Si no ha importado BayStream.cer en Personas de confianza del equipo local, importelo primero.'
    } else {
      $errores += 'La firma no es Valid; no se distribuye.'
    }
  }
  if ($firma.SignerCertificate.Thumbprint -ne $HuellaEsperada) {
    $errores += 'La huella del firmante no coincide con -Huella.'
  }
  Write-Host "Paquete: $paquete"
  Write-Host "SHA-256: $sha"
  Write-Host "Firma:   $($firma.Status) | $($firma.SignerCertificate.Subject) | $($firma.SignerCertificate.Thumbprint)"
  Write-Host $detalle
  if ($errores.Count -gt 0) {
    throw "Verificacion MSIX fallo: $($errores -join ' ') $detalle"
  }
}

$Huella = ($Huella -replace '[\s:]', '').ToUpperInvariant()
if ($Huella -notmatch '^[0-9A-F]{40}$') {
  throw 'La huella tiene que ser el Thumbprint SHA-1 del certificado: 40 hexadecimales.'
}
if ($PSCmdlet.ParameterSetName -eq 'Verificar') {
  Test-PaqueteMsix -Ruta $Verificar -HuellaEsperada $Huella
  return
}

$repo = Split-Path -Parent $PSScriptRoot
Set-Location $repo
if ($Version -notmatch '^\d+\.\d+\.\d+\.0$') {
  throw 'La version del paquete va como 1.0.1.0 (el cuarto numero es 0).'
}
if (-not (Test-Path -LiteralPath $Opciones)) {
  throw "No existe el archivo de opciones de Firebase: $Opciones"
}
$opcionesCompletas = [System.IO.Path]::GetFullPath($Opciones)
if ($opcionesCompletas.StartsWith([System.IO.Path]::GetFullPath($repo), 'OrdinalIgnoreCase')) {
  throw 'El archivo de opciones no puede estar dentro del repositorio.'
}

# T-136: CMake enlaza lo que haya en extracted aunque firebase_core pida otro SDK.
$sdkFirebase = Join-Path $PSScriptRoot 't136_sdk_firebase.ps1'
if (-not $SinCompilar) {
  & flutter pub get
  if ($LASTEXITCODE -ne 0) { throw "flutter pub get fallo ($LASTEXITCODE)." }
  & $sdkFirebase -Proyecto $repo -Apartar
  Write-Host '== 1/2 flutter build windows --release'
  & flutter build windows --release "--dart-define-from-file=$opcionesCompletas"
  if ($LASTEXITCODE -ne 0) { throw "flutter build windows fallo ($LASTEXITCODE)." }
}
& $sdkFirebase -Proyecto $repo -Verificar
$exe = Join-Path $repo 'build\windows\x64\runner\Release\baystream.exe'
if (-not (Test-Path -LiteralPath $exe)) {
  throw 'No hay compilacion Release: build\windows\x64\runner\Release\baystream.exe'
}

Write-Host "== 2/2 dart run msix:create (version $Version)"
$salida = Join-Path $repo 'build\t93'
New-Item -ItemType Directory -Force $salida | Out-Null
$nombre = "BayStream_$Version"
# build_windows e install_certificate tambien van en pubspec.yaml; aqui se
# repiten para que una edicion del pubspec no los encienda en silencio.
& dart run msix:create `
  --version $Version `
  --output-path $salida `
  --output-name $nombre `
  --build-windows false `
  --install-certificate false `
  --signtool-options "/fd SHA256 /sha1 $Huella"
if ($LASTEXITCODE -ne 0) { throw "msix:create fallo ($LASTEXITCODE)." }

$msix = Join-Path $salida "$nombre.msix"
if (-not (Test-Path -LiteralPath $msix)) { throw "No se genero $msix" }
$sha = (Get-FileHash -LiteralPath $msix -Algorithm SHA256).Hash
"$sha  $nombre.msix" | Set-Content -LiteralPath "$msix.sha256" -Encoding ascii
Test-PaqueteMsix -Ruta $msix -HuellaEsperada $Huella
