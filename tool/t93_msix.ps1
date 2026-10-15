# T-93 - Arma el instalador MSIX firmado de BayStream para Windows.
#
# 1. flutter build windows --release con las opciones de Firebase (archivo
#    privado, fuera del repositorio; no se abre ni se imprime).
# 2. dart run msix:create sobre esa compilacion, firmado con el certificado de
#    Carlos por su huella (/sha1): signtool toma la clave del almacen de usuario
#    sin exportarla. Sin .pfx, sin contrasena y sin tocar almacenes.
# 3. Deja el .msix en build\t93\ y escribe su SHA-256 al lado.
#
# Uso: powershell -NoProfile -ExecutionPolicy Bypass -File tool\t93_msix.ps1
#        -Huella <40 hexadecimales> [-Version 1.0.0.0]
#        [-Opciones C:\Proyectos\baystream-privado\firebase-prod.json]
#        [-SinCompilar]
param(
  [Parameter(Mandatory)][string]$Huella,
  [string]$Version = '1.0.0.0',
  [string]$Opciones = 'C:\Proyectos\baystream-privado\firebase-prod.json',
  # Reempaqueta la compilacion Release que ya existe (solo si se hizo con
  # las mismas opciones de Firebase).
  [switch]$SinCompilar
)
$ErrorActionPreference = 'Stop'
$repo = Split-Path -Parent $PSScriptRoot
Set-Location $repo

$Huella = ($Huella -replace '[\s:]', '').ToUpperInvariant()
if ($Huella -notmatch '^[0-9A-F]{40}$') {
  throw 'La huella tiene que ser el Thumbprint SHA-1 del certificado: 40 hexadecimales.'
}
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

if (-not $SinCompilar) {
  Write-Host '== 1/2 flutter build windows --release'
  & flutter build windows --release "--dart-define-from-file=$opcionesCompletas"
  if ($LASTEXITCODE -ne 0) { throw "flutter build windows fallo ($LASTEXITCODE)." }
}
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
$firma = Get-AuthenticodeSignature -LiteralPath $msix
Write-Host "Paquete: $msix"
Write-Host "SHA-256: $sha"
Write-Host "Firma:   $($firma.Status) | $($firma.SignerCertificate.Subject) | $($firma.SignerCertificate.Thumbprint)"
if ($firma.SignerCertificate.Thumbprint -ne $Huella) {
  throw 'El paquete no quedo firmado con el certificado de esa huella.'
}
