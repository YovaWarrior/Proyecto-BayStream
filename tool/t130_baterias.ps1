# T-130 · Las baterías de reglas en el emulador, de una sola vez (como
# tool/t127_baterias.ps1, con la batería nueva y las reglas de T-130).
#
# Levanta el emulador local de Firestore con tool/t113_emulador.ps1 (solo un
# proyecto `demo-*`, puerto 8282 para no chocar con el de la Expo, 8181 y
# 4000), espera a que escuche, corre las cuatro baterías contra las reglas de
# T-130 y contra las de T-127, guarda cada salida en build\t130\ y cierra el
# emulador por su árbol de procesos (la CLI y el JAR de Java).
#
# Uso, desde la carpeta del rediseño:
#
#     powershell -File tool/t130_baterias.ps1 [-Proyecto demo-t130] [-Puerto 8282]
#
# Sale con 0 si las siete baterías que cuentan dieron lo esperado. Contra
# T-127, la batería de T-130 tiene que fallar en los casos que esperan
# «permitido» y en el trozo suelto que T-127 todavía permite: ese registro
# (reglas-t130-contra-t127.log) es la prueba roja de las reglas y no cuenta
# para el código de salida.

param(
  [string]$Proyecto = 'demo-t130',
  [int]$Puerto = 8282,
  [string]$Salida = 'build\t130'
)

if (-not $Proyecto.StartsWith('demo-')) {
  Write-Error 'Solo un proyecto demo- del emulador.'
  exit 2
}
$raiz = Split-Path -Parent $PSScriptRoot
Set-Location -LiteralPath $raiz
New-Item -ItemType Directory -Force $Salida | Out-Null
$t130 = 'docs/T130-firestore.rules.propuesta'
$t127 = 'docs/T127-firestore.rules.propuesta'

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
    Write-Error "El emulador no escuchó en el puerto $Puerto (ver $Salida\emulador-*.log)."
    exit 3
  }
  $corridas = @(
    @{ nombre = 'reglas-t80-contra-t130';  comando = @('tool/t80_reglas.mjs', $Puerto, $Proyecto, $t130); cuenta = $true },
    @{ nombre = 'reglas-t113-contra-t130'; comando = @('tool/t113_reglas_abuso.mjs', $Puerto, $Proyecto, $t130); cuenta = $true },
    @{ nombre = 'reglas-t127-contra-t130'; comando = @('tool/t127_reglas_revision.mjs', $Puerto, $Proyecto, $t130); cuenta = $true },
    @{ nombre = 'reglas-t130-contra-t130'; comando = @('tool/t130_reglas_plan.mjs', $Puerto, $Proyecto, $t130); cuenta = $true },
    @{ nombre = 'reglas-t80-contra-t127';  comando = @('tool/t80_reglas.mjs', $Puerto, $Proyecto, $t127); cuenta = $true },
    @{ nombre = 'reglas-t113-contra-t127'; comando = @('tool/t113_reglas_abuso.mjs', $Puerto, $Proyecto, $t127); cuenta = $true },
    @{ nombre = 'reglas-t127-contra-t127'; comando = @('tool/t127_reglas_revision.mjs', $Puerto, $Proyecto, $t127); cuenta = $true },
    @{ nombre = 'reglas-t130-contra-t127'; comando = @('tool/t130_reglas_plan.mjs', $Puerto, $Proyecto, $t127); cuenta = $false }
  )
  foreach ($c in $corridas) {
    $registro = Join-Path $Salida "$($c.nombre).log"
    $argumentos = $c.comando
    Write-Output "--- $($c.nombre): node $($argumentos -join ' ')"
    # Las líneas como texto (sin los envoltorios de error de PowerShell 5.1) y
    # el registro en UTF-8, que Tee-Object no escribe.
    $lineas = @(& node @argumentos 2>&1 | ForEach-Object { "$_" })
    $codigo = $LASTEXITCODE
    $lineas | Set-Content -LiteralPath $registro -Encoding utf8
    $lineas | Select-Object -Last 1
    $resultados += [pscustomobject]@{ bateria = $c.nombre; salida = $codigo; cuenta = $c.cuenta }
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
$fallidas = @($resultados | Where-Object { $_.cuenta -and $_.salida -ne 0 })
if ($fallidas.Count -gt 0) { exit 1 }
exit 0
