<#
T-137 y T-145: aceptación nativa, sin abrir BayStream.
Primero -Preparar: escribe un .bat en build/t137 o build/t145. Ese .bat se
lanza con explorer.exe (doble clic) cuando Carlos reserve el almacén y la app
de Windows. El proceso exterior verifica su identidad y registra la
ascendencia antes de tomar huellas del almacén real. Solo instala y
desinstala la variante de prueba; producción se ejecuta únicamente con una
MSIX registrada, para comprobar que se detiene.

T-145 agrega, en este orden (docs/T145-RESULTADOS.md, 3.9, y 10.130):
  1. el instalador de prueba de T-137 y el nuevo encima: los cinco .lib y
     .exp desaparecen (O-137-6);
  2. el sustituto (una copia de PING.EXE, solo contra 127.0.0.1) en una
     carpeta hermana que empieza igual: la desinstalación sigue sin cuadro y
     el sustituto sigue vivo (O-137-8, condición de la 10.130);
  3. el sustituto dentro de la carpeta de la prueba: en silencio, la
     desinstalación se cancela sin quitar nada y sin cerrarlo; con cuadros,
     Reintentar vuelve a preguntar, y después de cerrarlo sigue hasta el final;
  4. el ensayo de la consulta colgada: se detiene en 30 a 60 s (O-137-7b).
#>
[CmdletBinding()]
param(
  [Parameter(Mandatory)][string]$InstaladorPrueba,
  [Parameter(Mandatory)][string]$InstaladorProduccion,
  [Parameter(Mandatory)][string]$InstaladorPruebaT137,
  [Parameter(Mandatory)][string]$InstaladorEnsayo,
  [Parameter(Mandatory)][string]$Evidencia,
  [switch]$Preparar,
  [switch]$DesdeExplorer,
  [switch]$SinProduccion
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
$t137AllowedEvidence = @('build\t137', 'build\t145') | ForEach-Object {
  [IO.Path]::GetFullPath((Join-Path $t137Repo $_)) + '\'
}
Assert-T137 (@($t137AllowedEvidence | Where-Object { $Evidencia.StartsWith($_, 'OrdinalIgnoreCase') }).Count -gt 0) `
  'La evidencia debe quedar en una subcarpeta de build/t137 o build/t145.'
$InstaladorPrueba = Get-T137FullPath $InstaladorPrueba
$InstaladorProduccion = Get-T137FullPath $InstaladorProduccion
$InstaladorPruebaT137 = Get-T137FullPath $InstaladorPruebaT137
$InstaladorEnsayo = Get-T137FullPath $InstaladorEnsayo

if ($Preparar) {
  Assert-T137 (-not $DesdeExplorer) 'Preparar y DesdeExplorer son excluyentes.'
  foreach ($t137Path in @($PSCommandPath, $Evidencia, $InstaladorPrueba,
      $InstaladorProduccion, $InstaladorPruebaT137, $InstaladorEnsayo)) {
    Assert-T137 ($t137Path -notmatch '[%"&|<>^\r\n]') `
      'La ruta contiene caracteres que no admite el lanzador .bat.'
  }
  New-Item -ItemType Directory -Path $Evidencia -Force | Out-Null
  $t137Bat = Join-Path $Evidencia 't137_aceptacion_fuera_del_paquete.bat'
  $t137Line = 'powershell.exe -NoLogo -NoProfile -NonInteractive -WindowStyle Hidden ' +
    '-ExecutionPolicy Bypass -File "' + $PSCommandPath + '" ' +
    '-InstaladorPrueba "' + $InstaladorPrueba + '" ' +
    '-InstaladorProduccion "' + $InstaladorProduccion + '" ' +
    '-InstaladorPruebaT137 "' + $InstaladorPruebaT137 + '" ' +
    '-InstaladorEnsayo "' + $InstaladorEnsayo + '" ' +
    '-Evidencia "' + $Evidencia + '" -DesdeExplorer' +
    $(if ($SinProduccion) { ' -SinProduccion' } else { '' }) + ' > "' +
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

# El desinstalador devuelve su código antes de que su copia en TEMP termine
# de escribir, y mientras tanto tiene el registro abierto: se lee compartido
# (aceptacion-04) y se espera la línea un momento.
function Read-T137Shared {
  param([string]$Path)
  if (-not (Test-Path -LiteralPath $Path)) { return '' }
  $t137Stream = [IO.File]::Open($Path, [IO.FileMode]::Open, [IO.FileAccess]::Read,
    ([IO.FileShare]::ReadWrite -bor [IO.FileShare]::Delete))
  try {
    $t137Reader = New-Object IO.StreamReader($t137Stream, [Text.Encoding]::UTF8, $true)
    return $t137Reader.ReadToEnd()
  } finally {
    $t137Stream.Dispose()
  }
}

function Read-T137Log {
  param([string]$Path, [string]$Pattern, [int]$Seconds = 10)
  for ($t137Try = 0; $t137Try -lt ($Seconds * 5); $t137Try++) {
    $t137Text = Read-T137Shared $Path
    if ($t137Text -match $Pattern) { return $t137Text }
    Start-Sleep -Milliseconds 200
  }
  return (Read-T137Shared $Path)
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

function Get-T137InstalledRows {
  param([string]$Phase)
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
  return $t137Rows
}

function Assert-T137Payload {
  param([object[]]$Rows, [object]$Manifest)
  foreach ($t137Expected in $Manifest.archivos) {
    $t137Matching = @($Rows | Where-Object archivo -EQ $t137Expected.archivo)
    Assert-T137 ($t137Matching.Count -eq 1) "Falta el archivo: $($t137Expected.archivo)"
    Assert-T137 ($t137Matching[0].sha256 -eq $t137Expected.sha256) `
      "Huella distinta: $($t137Expected.archivo)"
  }
}

function Test-T137Installed {
  param([string]$Phase, [bool]$Desktop, [object]$Manifest)
  $t137Rows = @(Get-T137InstalledRows $Phase)
  Assert-T137Payload $t137Rows $Manifest
  $t137Extras = @($t137Rows | Where-Object { $_.archivo -notin $Manifest.archivos.archivo })
  foreach ($t137Extra in $t137Extras) {
    Assert-T137 ($t137Extra.archivo -match '^unins\d{3}\.(exe|dat|msg)$') `
      "Archivo instalado fuera del manifiesto y del motor: $($t137Extra.archivo)"
  }
  Assert-T137 (@($t137Extras | Where-Object archivo -Match '\.exe$').Count -eq 1) `
    'No hay exactamente un desinstalador generado por Inno.'
  $t137Registry = Get-ItemProperty -LiteralPath $t137TrialKey
  Assert-T137 ($t137Registry.DisplayName -eq $Manifest.nombre) 'Nombre distinto en Aplicaciones.'
  Assert-T137 ($t137Registry.DisplayVersion -eq $Manifest.version) 'Version distinta en Aplicaciones.'
  Assert-T137 ($t137Registry.Publisher -eq $Manifest.editor) 'Editor distinto en Aplicaciones.'
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
  return $t137Rows
}

function Wait-T137Gone {
  param([string[]]$Paths, [string]$Label)
  for ($t137Wait = 0; $t137Wait -lt 50 -and
      @($Paths | Where-Object { Test-Path -LiteralPath $_ }).Count -gt 0; $t137Wait++) {
    Start-Sleep -Milliseconds 200
  }
  foreach ($t137Path in $Paths) {
    Assert-T137 (-not (Test-Path -LiteralPath $t137Path)) "$Label`: quedo $t137Path"
  }
}

function Get-T137Uninstaller {
  $t137Uninstall = @(Get-ChildItem -LiteralPath $t137App -Filter 'unins*.exe' -File)
  Assert-T137 ($t137Uninstall.Count -eq 1) 'Desinstalador ambiguo; no se ejecuta.'
  return $t137Uninstall[0].FullName
}

# El sustituto de BayStream (O-137-8): una copia de PING.EXE, oculta, solo
# contra 127.0.0.1. No es BayStream y no abre ningún almacén.
function Start-T137Substitute {
  param([string]$Folder)
  $t137Exe = Join-Path $Folder 't145-sustituto.exe'
  Assert-T137 (-not (Test-Path -LiteralPath $t137Exe)) "Ya existe $t137Exe"
  Copy-Item -LiteralPath (Join-Path $env:SystemRoot 'System32\PING.EXE') -Destination $t137Exe
  $t137Process = Start-Process -FilePath $t137Exe -ArgumentList @('-n', '900', '127.0.0.1') `
    -WindowStyle Hidden -PassThru
  Start-Sleep -Seconds 1
  $t137Cim = Get-CimInstance Win32_Process -Filter "ProcessId=$($t137Process.Id)"
  Assert-T137 ($null -ne $t137Cim -and $t137Cim.ExecutablePath -eq $t137Exe) `
    'El sustituto no quedo corriendo desde su carpeta.'
  return [pscustomobject]@{ id = $t137Process.Id; ruta = $t137Exe; proceso = $t137Process }
}

function Assert-T137SubstituteAlive {
  param([object]$Substitute, [string]$Label)
  $t137Cim = Get-CimInstance Win32_Process -Filter "ProcessId=$($Substitute.id)"
  Assert-T137 ($null -ne $t137Cim -and $t137Cim.ExecutablePath -eq $Substitute.ruta) `
    "$Label`: el sustituto $($Substitute.id) ya no corre; el desinstalador no debe cerrarlo."
}

function Stop-T137Substitute {
  param([object]$Substitute)
  # Solo el proceso que arrancó esta corrida, por su Id y su ruta.
  $t137Cim = Get-CimInstance Win32_Process -Filter "ProcessId=$($Substitute.id)"
  if ($null -ne $t137Cim -and $t137Cim.ExecutablePath -eq $Substitute.ruta) {
    Stop-Process -Id $Substitute.id
    [void]$Substitute.proceso.WaitForExit(10000)
  }
  for ($t137Try = 0; $t137Try -lt 25 -and (Test-Path -LiteralPath $Substitute.ruta); $t137Try++) {
    try { Remove-Item -LiteralPath $Substitute.ruta } catch { Start-Sleep -Milliseconds 200 }
  }
  Assert-T137 (-not (Test-Path -LiteralPath $Substitute.ruta)) 'No se pudo quitar el sustituto.'
}

# --- UI Automation para el cuadro de O-137-8 --------------------------------
Add-Type -AssemblyName UIAutomationClient, UIAutomationTypes

function Get-T137ProcessTree {
  param([int]$RootId)
  $t137Ids = @($RootId)
  $t137All = @(Get-CimInstance Win32_Process)
  for ($t137Depth = 0; $t137Depth -lt 3; $t137Depth++) {
    foreach ($t137Child in $t137All) {
      if ($t137Ids -contains [int]$t137Child.ParentProcessId -and
          $t137Ids -notcontains [int]$t137Child.ProcessId) {
        $t137Ids += [int]$t137Child.ProcessId
      }
    }
  }
  return $t137Ids
}

# Solo mira las ventanas del desinstalador de esta corrida y de su copia en
# TEMP, que es su hijo: no recorre otras aplicaciones.
function Find-T137Dialog {
  param([int]$Seconds, [int]$RootId, [int]$ExceptHandle = 0)
  $t137Root = [Windows.Automation.AutomationElement]::RootElement
  # Inno Setup 7 dibuja su propio cuadro (TTaskDialogForm): sus botones son
  # TNewButton y UI Automation los muestra como Pane, no como Button
  # (aceptacion-03/cuadro-no-visto.json). Se busca por el nombre.
  $t137Button = New-Object Windows.Automation.PropertyCondition(
    [Windows.Automation.AutomationElement]::NameProperty, 'Reintentar')
  $t137Deadline = [DateTime]::UtcNow.AddSeconds($Seconds)
  while ([DateTime]::UtcNow -lt $t137Deadline) {
    $t137Tree = @(Get-T137ProcessTree $RootId)
    $t137Windows = $t137Root.FindAll([Windows.Automation.TreeScope]::Children,
      [Windows.Automation.Condition]::TrueCondition)
    foreach ($t137Window in $t137Windows) {
      try {
        # La copia del desinstalador en TEMP puede no colgar del original:
        # también vale una ventana cuyo título nombra la variante de prueba.
        if ($t137Tree -notcontains [int]$t137Window.Current.ProcessId -and
            $t137Window.Current.Name -notlike '*prueba T-137*') { continue }
        if ($t137Window.Current.NativeWindowHandle -eq $ExceptHandle) { continue }
        $t137Retry = $t137Window.FindFirst([Windows.Automation.TreeScope]::Descendants, $t137Button)
        if ($null -ne $t137Retry) {
          $t137Texts = @($t137Window.FindAll([Windows.Automation.TreeScope]::Descendants,
              [Windows.Automation.Condition]::TrueCondition) |
            ForEach-Object { $_.Current.Name } | Where-Object { $_ })
          return [pscustomobject]@{
            ventana = $t137Window; boton = $t137Retry
            handle = $t137Window.Current.NativeWindowHandle
            titulo = $t137Window.Current.Name; textos = $t137Texts
          }
        }
      } catch {
        # La ventana se cerró mientras se leía; se vuelve a buscar.
      }
    }
    Start-Sleep -Milliseconds 250
  }
  return $null
}

# Si el cuadro no aparece por UI Automation, deja lo que se veía: las
# ventanas de primer nivel del desinstalador y las que nombran BayStream,
# con sus elementos. No pulsa nada.
function Save-T137Windows {
  param([int]$RootId, [string]$Path)
  $t137Tree = @(Get-T137ProcessTree $RootId)
  $t137Rows = @()
  $t137Root = [Windows.Automation.AutomationElement]::RootElement
  foreach ($t137Window in $t137Root.FindAll([Windows.Automation.TreeScope]::Children,
      [Windows.Automation.Condition]::TrueCondition)) {
    try {
      $t137Pid = [int]$t137Window.Current.ProcessId
      $t137Name = $t137Window.Current.Name
      if ($t137Tree -notcontains $t137Pid -and $t137Name -notlike '*BayStream*') { continue }
      $t137Items = @($t137Window.FindAll([Windows.Automation.TreeScope]::Descendants,
          [Windows.Automation.Condition]::TrueCondition) | Select-Object -First 80 |
        ForEach-Object { [ordered]@{
          tipo = $_.Current.ControlType.ProgrammaticName
          nombre = $_.Current.Name; clase = $_.Current.ClassName } })
      $t137Rows += [ordered]@{
        pid = $t137Pid; enArbol = ($t137Tree -contains $t137Pid); titulo = $t137Name
        clase = $t137Window.Current.ClassName; handle = $t137Window.Current.NativeWindowHandle
        elementos = $t137Items
      }
    } catch { }
  }
  $t137Processes = @(Get-CimInstance Win32_Process | Where-Object {
      $t137Tree -contains [int]$_.ProcessId -or $_.ExecutablePath -like '*uninstall.tmp*' } |
    ForEach-Object { [ordered]@{ pid = $_.ProcessId; padre = $_.ParentProcessId; ruta = $_.ExecutablePath } })
  Write-T137Json $Path ([ordered]@{ arbol = $t137Tree; procesos = $t137Processes; ventanas = $t137Rows })
}

Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
public static class T145Boton {
  [DllImport("user32.dll")]
  public static extern bool PostMessage(IntPtr hWnd, uint msg, IntPtr wParam, IntPtr lParam);
}
'@

function Invoke-T137Retry {
  param([object]$Dialog)
  $t137Invoke = $null
  if ($Dialog.boton.TryGetCurrentPattern([Windows.Automation.InvokePattern]::Pattern, [ref]$t137Invoke)) {
    $t137Invoke.Invoke()
    return 'InvokePattern'
  }
  # TNewButton es un botón de Win32: BM_CLICK (0x00F5) lo pulsa como un clic.
  $t137Handle = [IntPtr][int]$Dialog.boton.Current.NativeWindowHandle
  Assert-T137 ($t137Handle -ne [IntPtr]::Zero) 'El boton Reintentar no tiene ventana nativa.'
  Assert-T137 ([T145Boton]::PostMessage($t137Handle, 0x00F5, [IntPtr]::Zero, [IntPtr]::Zero)) `
    'No se pudo pulsar Reintentar.'
  return 'BM_CLICK'
}

function Stop-T137UninstallTree {
  param([int]$RootId)
  # Solo el desinstalador de prueba de esta corrida y sus hijos.
  foreach ($t137Id in @(Get-T137ProcessTree $RootId)) {
    Stop-Process -Id $t137Id -ErrorAction SilentlyContinue
  }
}

$t137State = [ordered]@{ aceptada = $false; pasos = @(); error = $null }
$t137BeforeStore = $null
$t137Substitutes = @()
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

  $t137Old = Read-T137Manifest $InstaladorPruebaT137 'prueba'
  $t137Trial = Read-T137Manifest $InstaladorPrueba 'prueba'
  $t137Essay = Read-T137Manifest $InstaladorEnsayo 'prueba'
  $t137Production = Read-T137Manifest $InstaladorProduccion 'produccion'
  Assert-T137 (-not $t137Trial.publicable) 'La variante de prueba esta marcada publicable.'
  Assert-T137 ($null -eq $t137Trial.ensayo) 'El instalador de prueba es un ensayo.'
  Assert-T137 ($t137Essay.ensayo -eq 'msix-colgada' -and -not $t137Essay.publicable) `
    'El instalador de ensayo no es el de la consulta colgada.'
  Assert-T137 ($t137Old.appId -eq $t137Trial.appId -and $t137Essay.appId -eq $t137Trial.appId) `
    'La prueba de T-137, la nueva y el ensayo deben compartir el AppId de prueba.'
  Assert-T137 ($t137Trial.appId -ne $t137Production.appId) 'Las variantes comparten AppId.'
  Assert-T137 ($t137Trial.nombre -eq 'BayStream (prueba T-137)') 'Nombre de prueba inesperado.'
  $t137Excluded = @($t137Trial.excluidos | ForEach-Object { $_.archivo })
  Assert-T137 ($t137Excluded.Count -eq 5) 'El manifiesto nuevo no trae los cinco excluidos.'
  foreach ($t137Name in $t137Excluded) {
    Assert-T137 (@($t137Old.archivos | Where-Object archivo -EQ $t137Name).Count -eq 1) `
      "El instalador de T-137 no trae $t137Name; no prueba [InstallDelete]."
  }

  $t137Programs = Join-Path ([Environment]::GetFolderPath('LocalApplicationData')) 'Programs'
  $t137App = Join-Path $t137Programs 'BayStream-Prueba-T137'
  $t137Sibling = Join-Path $t137Programs 'BayStream-Prueba-T137-hermana'
  $t137Start = Join-Path ([Environment]::GetFolderPath('Programs')) ($t137Trial.nombre + '.lnk')
  $t137Desktop = Join-Path ([Environment]::GetFolderPath('DesktopDirectory')) ($t137Trial.nombre + '.lnk')
  $t137UninstallBase = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall'
  $t137TrialKey = Join-Path $t137UninstallBase ('{' + $t137Trial.appId + '}_is1')
  $t137ProductionKey = Join-Path $t137UninstallBase ('{' + $t137Production.appId + '}_is1')
  $t137Fresh = @($t137App, $t137Sibling, $t137Start, $t137Desktop, $t137TrialKey)
  if (-not $SinProduccion) { $t137Fresh += $t137ProductionKey }
  foreach ($t137Path in $t137Fresh) {
    Assert-T137 (-not (Test-Path -LiteralPath $t137Path)) "Ya existe $t137Path; no se reemplaza una instalacion ajena a la corrida."
  }
  $t137Msix = @(Get-AppxPackage -Name 'gt.cmartinez.baystream' -ErrorAction Stop)
  if ($SinProduccion) {
    $t137State.pasos += "Sin produccion: MSIX registradas en la cuenta: $($t137Msix.Count)."
  } else {
    Assert-T137 ($t137Msix.Count -gt 0) `
      'No hay MSIX: no se ejecuta produccion en la cuenta de Carlos. Usar -SinProduccion.'
  }
  $t137BeforeStore = Get-T137StoreFingerprint 'almacen-antes'

  # 1. La prueba de T-137, con los cinco restos, y la nueva encima.
  $t137Code = Invoke-T137Installer $InstaladorPruebaT137 (Join-Path $Evidencia 'instalar-t137.log')
  Assert-T137 ($t137Code -eq 0) "Instalacion de T-137: salida $t137Code."
  [void](Test-T137Installed 'instalar-t137' $false $t137Old)
  $t137State.pasos += "Prueba de T-137 instalada ($($t137Old.version)), con los cinco .lib y .exp."
  $t137Code = Invoke-T137Installer $InstaladorPrueba (Join-Path $Evidencia 'instalar-1.log')
  Assert-T137 ($t137Code -eq 0) "Nueva encima de T-137: salida $t137Code."
  $t137Rows = @(Test-T137Installed 'instalar-1' $false $t137Trial)
  foreach ($t137Name in $t137Excluded) {
    Assert-T137 (@($t137Rows | Where-Object archivo -EQ $t137Name).Count -eq 0) `
      "Quedo $t137Name despues de instalar encima."
  }
  $t137State.pasos += 'Nueva encima de T-137: carga de 27 verificada y los cinco excluidos ya no estan.'
  $t137Code = Invoke-T137Installer $InstaladorPrueba (Join-Path $Evidencia 'instalar-2.log') @('/TASKS=escritorio')
  Assert-T137 ($t137Code -eq 0) "Instalar encima con escritorio: salida $t137Code."
  [void](Test-T137Installed 'instalar-2' $true $t137Trial)
  $t137State.pasos += 'Instalacion encima: payload y accesos, incluido escritorio, verificados.'

  # 2. La carpeta hermana (10.130): no cuenta como la app abierta.
  New-Item -ItemType Directory -Path $t137Sibling | Out-Null
  $t137SiblingSub = Start-T137Substitute $t137Sibling
  $t137Substitutes += $t137SiblingSub
  $t137Log = Join-Path $Evidencia 'desinstalar-hermana.log'
  $t137Code = Invoke-T137Installer (Get-T137Uninstaller) $t137Log
  Assert-T137 ($t137Code -eq 0) "Desinstalar con la hermana abierta: salida $t137Code."
  Wait-T137Gone @($t137App, $t137Start, $t137Desktop, $t137TrialKey) 'Desinstalar con la hermana abierta'
  $t137Text = Read-T137Log $t137Log 'T145_SIN_PROCESOS'
  Assert-T137 ($t137Text -match 'T145_SIN_PROCESOS') 'El registro no acredita la comprobacion de procesos.'
  Assert-T137 ($t137Text -notmatch 'T145_APP_ABIERTA') 'La hermana se tomo por la app abierta.'
  Assert-T137SubstituteAlive $t137SiblingSub 'Hermana'
  Stop-T137Substitute $t137SiblingSub
  Assert-T137 (@(Get-ChildItem -LiteralPath $t137Sibling -Force).Count -eq 0) `
    'La carpeta hermana tiene otros archivos; no se borra.'
  Remove-Item -LiteralPath $t137Sibling
  Assert-T137 (-not (Test-Path -LiteralPath $t137Sibling)) 'Quedo la carpeta hermana.'
  $t137State.pasos += "Hermana: sustituto $($t137SiblingSub.id) en BayStream-Prueba-T137-hermana, desinstalacion sin cuadro y sin residuos, sustituto vivo; despues cerrado por su Id y carpeta borrada."

  # 3. El sustituto dentro de la carpeta de la prueba.
  $t137Code = Invoke-T137Installer $InstaladorPrueba (Join-Path $Evidencia 'instalar-3.log')
  Assert-T137 ($t137Code -eq 0) "Reinstalar: salida $t137Code."
  [void](Test-T137Installed 'instalar-3' $false $t137Trial)
  $t137InsideSub = Start-T137Substitute $t137App
  $t137Substitutes += $t137InsideSub
  $t137Log = Join-Path $Evidencia 'desinstalar-abierta-silencio.log'
  $t137Code = Invoke-T137Installer (Get-T137Uninstaller) $t137Log
  Assert-T137 ($t137Code -ne 0) 'Con la app abierta, la desinstalacion silenciosa no se cancelo.'
  $t137Text = Read-T137Log $t137Log 'T145_DESINSTALAR_CANCELADO'
  Assert-T137 ($t137Text -match 'T145_APP_ABIERTA: 1 ') 'El registro no acredita la app abierta.'
  Assert-T137 ($t137Text -match 'T145_DESINSTALAR_CANCELADO') 'El registro no acredita la cancelacion.'
  Start-Sleep -Seconds 2
  $t137Rows = @(Get-T137InstalledRows 'abierta-silencio')
  Assert-T137Payload $t137Rows $t137Trial
  Assert-T137 (Test-Path -LiteralPath $t137TrialKey) 'Se quito la entrada de Aplicaciones.'
  Assert-T137Shortcut $t137Start (Join-Path $t137App 'baystream.exe')
  Assert-T137SubstituteAlive $t137InsideSub 'Silencio'
  $t137State.pasos += "Abierta, en silencio: salida $t137Code, cancelada sin quitar nada; sustituto $($t137InsideSub.id) vivo."

  $t137Log = Join-Path $Evidencia 'desinstalar-abierta-cuadro.log'
  $t137Uninstaller = Start-Process -FilePath (Get-T137Uninstaller) `
    -ArgumentList @('/SILENT', '/NORESTART', ('/LOG="' + $t137Log + '"')) -PassThru
  # En Windows PowerShell 5.1, sin leer Handle el código de salida queda vacío.
  $null = $t137Uninstaller.Handle
  $t137Dialog = Find-T137Dialog 20 $t137Uninstaller.Id
  if ($null -eq $t137Dialog) {
    # Lo aprobado (3.8): si UI Automation no ve el cuadro, el arnés termina
    # su desinstalador, que todavía no quitó nada, y Reintentar queda para el
    # recorrido de Carlos. El resto de la aceptación sigue.
    Save-T137Windows $t137Uninstaller.Id (Join-Path $Evidencia 'cuadro-no-visto.json')
    Stop-T137UninstallTree $t137Uninstaller.Id
    Start-Sleep -Seconds 2
    $t137Text = Read-T137Log $t137Log 'T145_APP_ABIERTA'
    Assert-T137 ($t137Text -match 'T145_APP_ABIERTA: 1 ') 'Con cuadros, el registro no acredita la app abierta.'
    $t137Rows = @(Get-T137InstalledRows 'abierta-cuadro')
    Assert-T137Payload $t137Rows $t137Trial
    Assert-T137SubstituteAlive $t137InsideSub 'Cuadro no visto'
    Stop-T137Substitute $t137InsideSub
    $t137Log = Join-Path $Evidencia 'desinstalar-cerrada.log'
    $t137Code = Invoke-T137Installer (Get-T137Uninstaller) $t137Log
    Assert-T137 ($t137Code -eq 0) "Desinstalar con el sustituto cerrado: salida $t137Code."
    Wait-T137Gone @($t137App, $t137Start, $t137Desktop, $t137TrialKey) 'Desinstalar con el sustituto cerrado'
    Assert-T137 ((Read-T137Log $t137Log 'T145_SIN_PROCESOS') -match 'T145_SIN_PROCESOS') `
      'El registro no acredita la comprobacion de procesos.'
    $t137State.cuadroReintentar = 'no acreditado: UI Automation no vio el cuadro; queda para el recorrido de Carlos'
    $t137State.pasos += 'Abierta, con cuadros: el desinstalador registro la app abierta y espero sin quitar nada; UI Automation no vio el cuadro (cuadro-no-visto.json). Cerrado el sustituto, la desinstalacion termino sin residuos.'
  } else {
  Write-T137Json (Join-Path $Evidencia 'cuadro-1.json') ([ordered]@{
    titulo = $t137Dialog.titulo; textos = $t137Dialog.textos })
  Assert-T137 (($t137Dialog.textos -join ' ') -match 'abierta') 'El cuadro no dice que la app esta abierta.'
  $t137State.pulsacion = Invoke-T137Retry $t137Dialog
  $t137Again = Find-T137Dialog 15 $t137Uninstaller.Id $t137Dialog.handle
  if ($null -eq $t137Again) {
    Stop-T137UninstallTree $t137Uninstaller.Id
    throw 'Reintentar con la app abierta no volvio a preguntar.'
  }
  Assert-T137SubstituteAlive $t137InsideSub 'Cuadro'
  Write-T137Json (Join-Path $Evidencia 'cuadro-2.json') ([ordered]@{
    titulo = $t137Again.titulo; textos = $t137Again.textos })
  Stop-T137Substitute $t137InsideSub
  [void](Invoke-T137Retry $t137Again)
  if (-not $t137Uninstaller.WaitForExit(90000)) {
    Stop-T137UninstallTree $t137Uninstaller.Id
    throw 'La desinstalacion no termino en 90 s despues de cerrar el sustituto.'
  }
  Assert-T137 ($t137Uninstaller.ExitCode -eq 0) "Desinstalar despues de cerrar: salida $($t137Uninstaller.ExitCode)."
  Wait-T137Gone @($t137App, $t137Start, $t137Desktop, $t137TrialKey) 'Desinstalar despues de cerrar'
  $t137Text = Read-T137Log $t137Log 'T145_APP_CERRADA'
  Assert-T137 ($t137Text -match 'T145_APP_CERRADA') 'El registro no acredita que la app se cerro antes de seguir.'
  $t137State.cuadroReintentar = 'acreditado'
  $t137State.pasos += 'Abierta, con cuadro: Reintentar con el sustituto vivo volvio a preguntar; cerrado el sustituto, Reintentar siguio y la desinstalacion termino sin residuos.'
  }

  # 4. El ensayo de la consulta colgada (O-137-7b).
  $t137Log = Join-Path $Evidencia 'ensayo-msix.log'
  $t137Clock = [Diagnostics.Stopwatch]::StartNew()
  $t137Code = Invoke-T137Installer $InstaladorEnsayo $t137Log
  $t137Clock.Stop()
  $t137Seconds = [Math]::Round($t137Clock.Elapsed.TotalSeconds, 1)
  Assert-T137 ($t137Code -ne 0) 'El ensayo no se detuvo.'
  Assert-T137 ($t137Seconds -ge 30 -and $t137Seconds -lt 60) "El ensayo tardo $t137Seconds s; se esperaban de 30 a 60."
  $t137Text = Read-T137Log $t137Log 'T145_MSIX_TERMINADA'
  Assert-T137 ($t137Text -match 'T137_BLOQUEO_MSIX:') 'El ensayo no registro el bloqueo.'
  Assert-T137 ($t137Text -match 'T145_MSIX_TERMINADA') 'El ensayo no registro que termino la consulta.'
  Assert-T137 ($t137Text -match '30 segundos') 'El ensayo no registro el texto del limite.'
  foreach ($t137Path in @($t137App, $t137Start, $t137TrialKey)) {
    Assert-T137 (-not (Test-Path -LiteralPath $t137Path)) "El ensayo dejo $t137Path"
  }
  $t137Hung = @(Get-CimInstance Win32_Process -Filter "Name='powershell.exe'" |
    Where-Object { $_.CommandLine -like '*t145-msix-*' -and $_.CommandLine -like '*Start-Sleep*' })
  Assert-T137 ($t137Hung.Count -eq 0) 'Quedo viva la consulta colgada del ensayo.'
  $t137State.pasos += "Ensayo de la consulta colgada: salida $t137Code en $t137Seconds s, consulta terminada, sin carpeta ni registro."

  # 5. Producción, solo para ver que se detiene por la MSIX.
  if ($SinProduccion) {
    $t137State.pasos += 'Produccion no se ejecuto (-SinProduccion).'
  } else {
    Assert-T137 (@(Get-AppxPackage -Name 'gt.cmartinez.baystream' -ErrorAction Stop).Count -gt 0) `
      'La MSIX dejo de estar registrada; no se ejecuta produccion.'
    $t137Forbidden = Join-Path $Evidencia 'produccion-no-debe-existir'
    Assert-T137 (-not (Test-Path -LiteralPath $t137Forbidden)) 'El destino testigo ya existe.'
    $t137ProductionLog = Join-Path $Evidencia 'produccion-msix.log'
    $t137Code = Invoke-T137Installer $InstaladorProduccion $t137ProductionLog @('/DIR="' + $t137Forbidden + '"')
    Assert-T137 ($t137Code -ne 0) 'Produccion no se detuvo ante la MSIX.'
    Assert-T137 ((Read-T137Log $t137ProductionLog 'T137_BLOQUEO_MSIX:') -match 'T137_BLOQUEO_MSIX:') `
      'El rechazo no quedo acreditado como bloqueo de MSIX.'
    Assert-T137 (-not (Test-Path -LiteralPath $t137Forbidden)) 'Produccion copio archivos antes del bloqueo.'
    Assert-T137 (-not (Test-Path -LiteralPath $t137ProductionKey)) 'Produccion creo una entrada en Aplicaciones.'
    $t137State.pasos += "Produccion rechazada por MSIX, salida $t137Code, sin carpeta ni registro nuevos."
  }
  Assert-T137 (@(Get-Process -Name baystream -ErrorAction SilentlyContinue).Count -eq 0) `
    'Aparecio un proceso de BayStream: la corrida no acredita que la app quedara cerrada.'
  $t137State.aceptada = $true
} catch {
  $t137State.error = $_.Exception.Message
} finally {
  # Ningún sustituto queda vivo, pase lo que pase.
  foreach ($t137Sub in $t137Substitutes) {
    try { Stop-T137Substitute $t137Sub } catch { $t137State.pasos += "No se pudo cerrar el sustituto $($t137Sub.id): $($_.Exception.Message)" }
  }
  if ($null -ne $t137BeforeStore) {
    try {
      $t137AfterStore = Get-T137StoreFingerprint 'almacen-despues'
      $t137State.almacen = $t137AfterStore.almacen
      $t137State.huellaAntes = $t137BeforeStore.sha256
      $t137State.huellaDespues = $t137AfterStore.sha256
      $t137State.cantidadArchivos = $t137AfterStore.cantidadArchivos
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
