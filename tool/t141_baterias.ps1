# T-141 · Las cuatro baterías de reglas contra el TEXTO PUBLICADO, de una
# sola vez (adaptación de tool/t130_baterias.ps1, 1.3 de T-141).
#
# Levanta el emulador local de Firestore con tool/t113_emulador.ps1 (solo un
# proyecto `demo-*`, puerto 8383 para no chocar con 8181 de T-113, 8282 de
# T-130 ni 4000 de la Expo), espera a que escuche, corre las cuatro baterías
# (T-80, T-113, T-127 y T-130) contra build\t141\reglas-publicadas.txt —el
# texto copiado de la consola, no la propuesta versionada—, guarda cada salida
# en build\t141\ y cierra el emulador por su árbol de procesos.
#
# Uso, desde la carpeta del rediseño:
#
#     powershell -File tool/t141_baterias.ps1 [-Proyecto demo-t141] [-Puerto 8383]
#
# Antes de arrancar comprueba que el puerto esté libre; si algo lo escucha, se
# detiene sin tocar ese proceso. Sale con 0 si las cuatro baterías dieron lo
# esperado (69, 25, 31 y 38).

param(
  [string]$Proyecto = 'demo-t141',
  [int]$Puerto = 8383,
  [string]$Salida = 'build\t141',
  [string]$Reglas = 'build\t141\reglas-publicadas.txt'
)

if (-not $Proyecto.StartsWith('demo-')) {
  Write-Error 'Solo un proyecto demo- del emulador.'
  exit 2
}
$raiz = Split-Path -Parent $PSScriptRoot
Set-Location -LiteralPath $raiz
New-Item -ItemType Directory -Force $Salida | Out-Null
if (-not (Test-Path -LiteralPath $Reglas)) {
  Write-Error "No existe ${Reglas}: copia primero el texto publicado de la consola."
  exit 2
}

$ocupado = Get-NetTCPConnection -LocalPort $Puerto -State Listen -ErrorAction SilentlyContinue
if ($ocupado) {
  Write-Error "El puerto $Puerto ya esta en escucha (proceso $($ocupado[0].OwningProcess)): no se arranca el emulador."
  exit 4
}

$emulador = Start-Process -FilePath 'powershell' -PassThru -WindowStyle Hidden `
  -ArgumentList '-NoProfile', '-File', (Join-Path $PSScriptRoot 't113_emulador.ps1'), '-Proyecto', $Proyecto, '-Puerto', $Puerto `
  -RedirectStandardOutput (Join-Path $Salida 'emulador-salida.log') `
  -RedirectStandardError (Join-Path $Salida 'emulador-error.log')
Write-Output "Emulador: proceso $($emulador.Id), proyecto $Proyecto, puerto $Puerto"

$listo = $false
for ($i = 0; $i -lt 90 -and -not $listo; $i++) {
  Start-Sleep -Seconds 2
  try {
    $cliente = New-Object Net.Sockets.TcpClient
    $cliente.Connect('127.0.0.1', $Puerto)
    $cliente.Close()
    $listo = $true
  } catch {
    if ($emulador.HasExited) { break }
  }
}

$resultados = @()
try {
  if (-not $listo) {
    Write-Error "El emulador no escucho en el puerto $Puerto (ver $Salida\emulador-*.log)."
    exit 3
  }
  $corridas = @(
    @{ nombre = 'reglas-t80-contra-publicadas';  comando = @('tool/t80_reglas.mjs', $Puerto, $Proyecto, $Reglas); esperado = '69 de 69' },
    @{ nombre = 'reglas-t113-contra-publicadas'; comando = @('tool/t113_reglas_abuso.mjs', $Puerto, $Proyecto, $Reglas); esperado = '25 de 25' },
    @{ nombre = 'reglas-t127-contra-publicadas'; comando = @('tool/t127_reglas_revision.mjs', $Puerto, $Proyecto, $Reglas); esperado = '31 de 31' },
    @{ nombre = 'reglas-t130-contra-publicadas'; comando = @('tool/t130_reglas_plan.mjs', $Puerto, $Proyecto, $Reglas); esperado = '38 de 38' }
  )
  foreach ($c in $corridas) {
    $registro = Join-Path $Salida "$($c.nombre).log"
    $argumentos = $c.comando
    Write-Output "--- $($c.nombre): node $($argumentos -join ' ')"
    # Las lineas como texto (sin los envoltorios de error de PowerShell 5.1) y
    # el registro en UTF-8, que Tee-Object no escribe.
    $lineas = @(& node @argumentos 2>&1 | ForEach-Object { "$_" })
    $codigo = $LASTEXITCODE
    $lineas | Set-Content -LiteralPath $registro -Encoding utf8
    $lineas | Select-Object -Last 1
    $resultados += [pscustomobject]@{ bateria = $c.nombre; salida = $codigo; esperado = $c.esperado }
  }
} finally {
  if (-not $emulador.HasExited) {
    & taskkill /T /F /PID $emulador.Id | Out-Null
  }
  # El JAR puede sobrevivir a su padre: lo que siga escuchando en el puerto, fuera.
  $escuchando = Get-NetTCPConnection -LocalPort $Puerto -State Listen -ErrorAction SilentlyContinue |
    Select-Object -ExpandProperty OwningProcess -Unique
  foreach ($proceso in $escuchando) {
    if ($proceso -and $proceso -ne 0) { Stop-Process -Id $proceso -Force -ErrorAction SilentlyContinue }
  }
  Write-Output 'Emulador cerrado.'
}

$resultados | Format-Table -AutoSize | Out-String | Write-Output
$resultados | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $Salida 'baterias-resumen.json') -Encoding utf8
$fallidas = @($resultados | Where-Object { $_.salida -ne 0 })
if ($fallidas.Count -gt 0) { exit 1 }
exit 0
