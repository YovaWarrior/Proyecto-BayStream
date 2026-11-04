<#
T-137: aceptación nativa, sin abrir BayStream.
Primero -Preparar: escribe un .bat en build/t137. Ese .bat se lanza con
explorer.exe cuando Carlos reserve el almacén y la app de Windows.
El proceso exterior verifica su identidad y registra la ascendencia antes
de tomar huellas del almacén real. Solo instala/desinstala la variante de
prueba; producción se ejecuta únicamente con una MSIX registrada.
#>
[CmdletBinding()]
param(
  [Parameter(Mandatory)][string]$InstaladorPrueba,
  [Parameter(Mandatory)][string]$InstaladorProduccion,
  [Parameter(Mandatory)][string]$Evidencia,
  [switch]$Preparar,
  [switch]$DesdeExplorer
)
$ErrorActionPreference = 'Stop'
$t137Repo = Split-Path -Parent $PSScriptRoot

function Write-T137Json {
  param([string]$Path, [object]$Value)
  [IO.File]::WriteAllText($Path, ($Value | ConvertTo-Json -Depth 12),
    [Text.UTF8Encoding]::new($false))
}

function Get-T137Sha {
  param([string]$Path)
  $t137Stream = [IO.File]::OpenRead($Path)
  $t137Algorithm = [Security.Cryptography.SHA256]::Create()
  try {
    return [BitConverter]::ToString($t137Algorithm.ComputeHash($t137Stream)).Replace('-', '').ToLowerInvariant()
  } finally {
    $t137Stream.Dispose()
    $t137Algorithm.Dispose()
  }
}

function Assert-T137 {
  param([bool]$Condition, [string]$Message)
  if (-not $Condition) { throw $Message }
}

function Get-T137FullPath {
  param([string]$Path)
  if ([IO.Path]::IsPathRooted($Path)) { return [IO.Path]::GetFullPath($Path) }
  return [IO.Path]::GetFullPath((Join-Path $t137Repo $Path))
}

$Evidencia = Get-T137FullPath $Evidencia
$t137Allowed = [IO.Path]::GetFullPath((Join-Path $t137Repo 'build\t137')) + '\'
Assert-T137 ($Evidencia.StartsWith($t137Allowed, 'OrdinalIgnoreCase')) `
  'La evidencia debe quedar en una subcarpeta de build/t137.'
$InstaladorPrueba = Get-T137FullPath $InstaladorPrueba
$InstaladorProduccion = Get-T137FullPath $InstaladorProduccion

if ($Preparar) {
  Assert-T137 (-not $DesdeExplorer) 'Preparar y DesdeExplorer son excluyentes.'
  foreach ($t137Path in @($PSCommandPath, $Evidencia,
      $InstaladorPrueba, $InstaladorProduccion)) {
    Assert-T137 ($t137Path -notmatch '[%"&|<>^\r\n]') `
      'La ruta contiene caracteres que no admite el lanzador .bat.'
  }
  New-Item -ItemType Directory -Path $Evidencia -Force | Out-Null
  $t137Bat = Join-Path $Evidencia 't137_aceptacion_fuera_del_paquete.bat'
  $t137Line = 'powershell.exe -NoLogo -NoProfile -NonInteractive -WindowStyle Hidden ' +
    '-ExecutionPolicy Bypass -File "' + $PSCommandPath + '" ' +
    '-InstaladorPrueba "' + $InstaladorPrueba + '" ' +
    '-InstaladorProduccion "' + $InstaladorProduccion + '" ' +
    '-Evidencia "' + $Evidencia + '" -DesdeExplorer > "' +
    (Join-Path $Evidencia 'lanzador.log') + '" 2>&1'
  [IO.File]::WriteAllText($t137Bat,
    "@echo off`r`n$t137Line`r`nexit /b %ERRORLEVEL%`r`n", [Text.Encoding]::ASCII)
  Write-Output $t137Bat
  return
}

Assert-T137 ([bool]$DesdeExplorer) `
  'Usar -Preparar y abrir el .bat con explorer.exe; no ejecutar desde el agente.'
Assert-T137 (Test-Path -LiteralPath $Evidencia -PathType Container) `
  'Primero hay que preparar la carpeta de evidencia.'
Assert-T137 (-not (Test-Path -LiteralPath (Join-Path $Evidencia 'resultado.json'))) `
  'La corrida ya tiene resultado; usar otra carpeta de evidencia.'

function Get-T137Parents {
  $t137Parents = @()
  $t137ProcessId = $PID
  for ($t137Index = 0; $t137Index -lt 10 -and $t137ProcessId -gt 0; $t137Index++) {
    $t137Process = Get-CimInstance Win32_Process -Filter "ProcessId=$t137ProcessId"
    if (-not $t137Process) { break }
    $t137Parents += [pscustomobject]@{
      pid = $t137Process.ProcessId
      padre = $t137Process.ParentProcessId
      nombre = $t137Process.Name
      ejecutable = $t137Process.ExecutablePath
    }
    $t137ProcessId = $t137Process.ParentProcessId
  }
  return $t137Parents
}

function Get-T137StoreFingerprint {
  param([string]$Name)
  $t137Store = Join-Path ([Environment]::GetFolderPath('LocalApplicationData')) 'BayStream'
  $t137Exists = Test-Path -LiteralPath $t137Store -PathType Container
  $t137Files = @()
  $t137Directories = @()
  if ($t137Exists) {
    $t137Entries = @(Get-ChildItem -LiteralPath $t137Store -Recurse -Force |
      Sort-Object FullName)
    foreach ($t137Entry in $t137Entries) {
      Assert-T137 (-not ($t137Entry.Attributes -band [IO.FileAttributes]::ReparsePoint)) `
        'El almacén tiene enlaces; no se sigue una ruta de datos ambigua.'
      $t137Relative = $t137Entry.FullName.Substring($t137Store.Length + 1)
      if ($t137Entry.PSIsContainer) { $t137Directories += $t137Relative }
      else {
        $t137Files += [pscustomobject]@{
          archivo = $t137Relative
          bytes = $t137Entry.Length
          sha256 = Get-T137Sha $t137Entry.FullName
        }
      }
    }
  }
  $t137Content = [ordered]@{ existe = $t137Exists; carpetas = $t137Directories; archivos = $t137Files }
  $t137Hasher = [Security.Cryptography.SHA256]::Create()
  try {
    $t137Digest = $t137Hasher.ComputeHash([Text.Encoding]::UTF8.GetBytes(
      ($t137Content | ConvertTo-Json -Depth 6 -Compress)))
    $t137Sha = [BitConverter]::ToString($t137Digest).Replace('-', '').ToLowerInvariant()
  } finally { $t137Hasher.Dispose() }
  $t137Result = [ordered]@{
    almacen = $t137Store; fechaUtc = [DateTime]::UtcNow.ToString('o')
    sha256 = $t137Sha; cantidadArchivos = $t137Files.Count; contenido = $t137Content
  }
  Write-T137Json (Join-Path $Evidencia "$Name.json") $t137Result
  return $t137Result
}

function Read-T137Manifest {
  param([string]$Installer, [string]$Variant)
  Assert-T137 (Test-Path -LiteralPath $Installer -PathType Leaf) "Falta $Installer"
  $t137ManifestPath = [IO.Path]::ChangeExtension($Installer, 'manifiesto.json')
  $t137Manifest = Get-Content -LiteralPath $t137ManifestPath -Raw -Encoding UTF8 | ConvertFrom-Json
  Assert-T137 ($t137Manifest.variante -eq $Variant) 'El manifiesto pertenece a otra variante.'
  $t137Hash = Get-T137Sha $Installer
  Assert-T137 ($t137Hash -eq $t137Manifest.instalador.sha256) 'El instalador no coincide con su manifiesto.'
  $t137Sidecar = (Get-Content -LiteralPath "$Installer.sha256" -Raw).Trim()
  Assert-T137 ($t137Sidecar -match ('^' + $t137Hash + '\s+')) 'El .sha256 no coincide.'
  return $t137Manifest
}

function Invoke-T137Installer {
  param([string]$Path, [string]$Log, [string[]]$Extra = @())
  $t137Arguments = @('/VERYSILENT', '/SUPPRESSMSGBOXES', '/NORESTART',
    '/NOCLOSEAPPLICATIONS', ('/LOG="' + $Log + '"')) + $Extra
  $t137Process = Start-Process -FilePath $Path -ArgumentList $t137Arguments `
    -WindowStyle Hidden -PassThru -Wait
  return $t137Process.ExitCode
}

function Assert-T137Shortcut {
  param([string]$Path, [string]$Target)
  Assert-T137 (Test-Path -LiteralPath $Path -PathType Leaf) "Falta el acceso: $Path"
  $t137Shell = New-Object -ComObject WScript.Shell
  try {
    $t137Shortcut = $t137Shell.CreateShortcut($Path)
    Assert-T137 ($t137Shortcut.TargetPath -eq $Target) 'El acceso apunta a otro ejecutable.'
  } finally {
    if ($t137Shortcut) { [void][Runtime.InteropServices.Marshal]::ReleaseComObject($t137Shortcut) }
    [void][Runtime.InteropServices.Marshal]::ReleaseComObject($t137Shell)
  }
}

function Test-T137Installed {
  param([string]$Phase, [bool]$Desktop)
  $t137Installed = @(Get-ChildItem -LiteralPath $t137App -File -Recurse | Sort-Object FullName)
  $t137Rows = @()
  foreach ($t137File in $t137Installed) {
    $t137Rows += [pscustomobject]@{
      archivo = $t137File.FullName.Substring($t137App.Length + 1).Replace('\', '/')
      bytes = $t137File.Length
      sha256 = Get-T137Sha $t137File.FullName
    }
  }
  Write-T137Json (Join-Path $Evidencia "$Phase-archivos.json") $t137Rows
  foreach ($t137Expected in $t137Trial.archivos) {
    $t137Matching = @($t137Rows | Where-Object archivo -EQ $t137Expected.archivo)
    Assert-T137 ($t137Matching.Count -eq 1) "Falta el archivo: $($t137Expected.archivo)"
    Assert-T137 ($t137Matching[0].sha256 -eq $t137Expected.sha256) `
      "Huella distinta: $($t137Expected.archivo)"
  }
  $t137Extras = @($t137Rows | Where-Object { $_.archivo -notin $t137Trial.archivos.archivo })
  foreach ($t137Extra in $t137Extras) {
    Assert-T137 ($t137Extra.archivo -match '^unins\d{3}\.(exe|dat|msg)$') `
      "Archivo instalado fuera del manifiesto y del motor: $($t137Extra.archivo)"
  }
  Assert-T137 (@($t137Extras | Where-Object archivo -Match '\.exe$').Count -eq 1) `
    'No hay exactamente un desinstalador generado por Inno.'
  $t137Registry = Get-ItemProperty -LiteralPath $t137TrialKey
  Assert-T137 ($t137Registry.DisplayName -eq $t137Trial.nombre) 'Nombre distinto en Aplicaciones.'
  Assert-T137 ($t137Registry.DisplayVersion -eq $t137Trial.version) 'Version distinta en Aplicaciones.'
  Assert-T137 ($t137Registry.Publisher -eq $t137Trial.editor) 'Editor distinto en Aplicaciones.'
  Assert-T137 ($t137Registry.InstallLocation.TrimEnd('\') -eq $t137App) 'Otra carpeta registrada.'
  Assert-T137 ($t137Registry.DisplayIcon -like "$t137App\baystream.exe*") 'Otro icono registrado.'
  Write-T137Json (Join-Path $Evidencia "$Phase-registro.json") ([ordered]@{
    nombre = $t137Registry.DisplayName; version = $t137Registry.DisplayVersion
    editor = $t137Registry.Publisher; carpeta = $t137Registry.InstallLocation
    icono = $t137Registry.DisplayIcon; desinstalar = $t137Registry.UninstallString
  })
  Assert-T137Shortcut $t137Start (Join-Path $t137App 'baystream.exe')
  if ($Desktop) { Assert-T137Shortcut $t137Desktop (Join-Path $t137App 'baystream.exe') }
  else { Assert-T137 (-not (Test-Path -LiteralPath $t137Desktop)) 'El escritorio no era opcional.' }
}

$t137State = [ordered]@{ aceptada = $false; pasos = @(); error = $null }
$t137BeforeStore = $null
try {
  $t137Parents = @(Get-T137Parents)
  Write-T137Json (Join-Path $Evidencia 'procesos.json') $t137Parents
  Assert-T137 (@($t137Parents | Where-Object nombre -EQ 'explorer.exe').Count -gt 0) `
    'No se encontro explorer.exe en la ascendencia; la corrida no vale.'
  Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
public static class T137PackageIdentity {
  [DllImport("kernel32.dll", CharSet = CharSet.Unicode, ExactSpelling = true)]
  public static extern int GetCurrentPackageFullName(ref uint length, IntPtr name);
}
'@
  [uint32]$t137PackageLength = 0
  $t137PackageCode = [T137PackageIdentity]::GetCurrentPackageFullName([ref]$t137PackageLength, [IntPtr]::Zero)
  Write-T137Json (Join-Path $Evidencia 'identidad-proceso.json') @{ resultado = $t137PackageCode; sinPaquete = ($t137PackageCode -eq 15700) }
  Assert-T137 ($t137PackageCode -eq 15700) 'El proceso tiene identidad de paquete; no se toma la huella.'
  Assert-T137 (@(Get-Process -Name baystream -ErrorAction SilentlyContinue).Count -eq 0) `
    'BayStream esta abierto; Carlos debe reservar la app antes de esta aceptacion.'
  $t137Trial = Read-T137Manifest $InstaladorPrueba 'prueba'
  $t137Production = Read-T137Manifest $InstaladorProduccion 'produccion'
  Assert-T137 (-not $t137Trial.publicable) 'La variante de prueba esta marcada publicable.'
  Assert-T137 ($t137Trial.appId -ne $t137Production.appId) 'Las variantes comparten AppId.'
  Assert-T137 ($t137Trial.nombre -eq 'BayStream (prueba T-137)') 'Nombre de prueba inesperado.'
  $t137App = Join-Path ([Environment]::GetFolderPath('LocalApplicationData')) 'Programs\BayStream-Prueba-T137'
  $t137Start = Join-Path ([Environment]::GetFolderPath('Programs')) ($t137Trial.nombre + '.lnk')
  $t137Desktop = Join-Path ([Environment]::GetFolderPath('DesktopDirectory')) ($t137Trial.nombre + '.lnk')
  $t137UninstallBase = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall'
  $t137TrialKey = Join-Path $t137UninstallBase ('{' + $t137Trial.appId + '}_is1')
  $t137ProductionKey = Join-Path $t137UninstallBase ('{' + $t137Production.appId + '}_is1')
  foreach ($t137Path in @($t137App, $t137Start, $t137Desktop, $t137TrialKey, $t137ProductionKey)) {
    Assert-T137 (-not (Test-Path -LiteralPath $t137Path)) "Ya existe $t137Path; no se reemplaza una instalacion ajena a la corrida."
  }
  $t137Msix = @(Get-AppxPackage -Name 'gt.cmartinez.baystream' -ErrorAction Stop)
  Assert-T137 ($t137Msix.Count -gt 0) 'No hay MSIX: no se ejecuta produccion en la cuenta de Carlos.'
  $t137BeforeStore = Get-T137StoreFingerprint 'almacen-antes'
  $t137Code = Invoke-T137Installer $InstaladorPrueba (Join-Path $Evidencia 'instalar-1.log')
  Assert-T137 ($t137Code -eq 0) "Primera instalacion: salida $t137Code."
  Test-T137Installed 'instalar-1' $false
  $t137State.pasos += 'Instalacion de prueba: payload, desinstalador, registro, Inicio y escritorio ausente verificados.'
  $t137Code = Invoke-T137Installer $InstaladorPrueba (Join-Path $Evidencia 'instalar-2.log') @('/TASKS=escritorio')
  Assert-T137 ($t137Code -eq 0) "Instalar encima: salida $t137Code."
  Test-T137Installed 'instalar-2' $true
  $t137State.pasos += 'Instalacion encima: payload y accesos, incluido escritorio, verificados.'
  $t137Uninstall = @(Get-ChildItem -LiteralPath $t137App -Filter 'unins*.exe' -File)
  Assert-T137 ($t137Uninstall.Count -eq 1) 'Desinstalador ambiguo; no se ejecuta.'
  $t137Code = Invoke-T137Installer $t137Uninstall[0].FullName (Join-Path $Evidencia 'desinstalar.log')
  Assert-T137 ($t137Code -eq 0) "Desinstalar prueba: salida $t137Code."
  for ($t137Wait = 0; $t137Wait -lt 30 -and (Test-Path -LiteralPath $t137App); $t137Wait++) {
    Start-Sleep -Milliseconds 200
  }
  foreach ($t137Path in @($t137App, $t137Start, $t137Desktop, $t137TrialKey)) {
    Assert-T137 (-not (Test-Path -LiteralPath $t137Path)) "Quedo un residuo de prueba: $t137Path"
  }
  $t137State.pasos += 'Desinstalacion de prueba: carpeta, accesos y registro ausentes.'
  Assert-T137 (@(Get-AppxPackage -Name 'gt.cmartinez.baystream' -ErrorAction Stop).Count -gt 0) `
    'La MSIX dejo de estar registrada; no se ejecuta produccion.'
  $t137Forbidden = Join-Path $Evidencia 'produccion-no-debe-existir'
  Assert-T137 (-not (Test-Path -LiteralPath $t137Forbidden)) 'El destino testigo ya existe.'
  $t137ProductionLog = Join-Path $Evidencia 'produccion-msix.log'
  $t137Code = Invoke-T137Installer $InstaladorProduccion $t137ProductionLog @('/DIR="' + $t137Forbidden + '"')
  Assert-T137 ($t137Code -ne 0) 'Produccion no se detuvo ante la MSIX.'
  Assert-T137 ((Get-Content -LiteralPath $t137ProductionLog -Raw) -match 'T137_BLOQUEO_MSIX:') `
    'El rechazo no quedo acreditado como bloqueo de MSIX.'
  Assert-T137 (-not (Test-Path -LiteralPath $t137Forbidden)) 'Produccion copio archivos antes del bloqueo.'
  Assert-T137 (-not (Test-Path -LiteralPath $t137ProductionKey)) 'Produccion creo una entrada en Aplicaciones.'
  $t137State.pasos += "Produccion rechazada por MSIX, salida $t137Code, sin carpeta ni registro nuevos."
  Assert-T137 (@(Get-Process -Name baystream -ErrorAction SilentlyContinue).Count -eq 0) `
    'Aparecio un proceso de BayStream: la corrida no acredita que la app quedara cerrada.'
  $t137State.aceptada = $true
} catch {
  $t137State.error = $_.Exception.Message
} finally {
  if ($null -ne $t137BeforeStore) {
    try {
      $t137AfterStore = Get-T137StoreFingerprint 'almacen-despues'
      $t137State.almacen = $t137AfterStore.almacen
      $t137State.huellaAntes = $t137BeforeStore.sha256
      $t137State.huellaDespues = $t137AfterStore.sha256
      $t137State.almacenIgual = $t137BeforeStore.sha256 -eq $t137AfterStore.sha256
      if (-not $t137State.almacenIgual) {
        $t137State.aceptada = $false
        $t137State.error = 'La huella del almacen cambio; la aceptacion no pasa.'
      }
    } catch {
      $t137State.aceptada = $false
      $t137State.error = 'No se pudo completar la huella final: ' + $_.Exception.Message
    }
  }
  $t137State.fechaUtc = [DateTime]::UtcNow.ToString('o')
  Write-T137Json (Join-Path $Evidencia 'resultado.json') $t137State
}
if (-not $t137State.aceptada) {
  Write-Error $t137State.error
  exit 1
}
Write-Output 'T137: aceptacion nativa completada; BayStream no se abrio y el almacen conserva su huella.'
