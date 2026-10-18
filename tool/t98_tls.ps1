# Compatibilidad con el punto de entrada anterior; solo usa Python instalado.
# No instala OpenSSL ni usa Firebase CLI/consola.
param(
  [string]$Python = 'python',
  [string]$Salida = "$env:TEMP\t98\tls.json",
  [ValidateSet('A','B')][string]$Fase = 'A',
  [Parameter(Mandatory=$true)][ValidatePattern('^[a-fA-F0-9]{7,40}$')][string]$Base
)
$ErrorActionPreference='Stop'
& $Python (Join-Path $PSScriptRoot 't98_tls.py') --salida $Salida --fase $Fase --base $Base
if ($LASTEXITCODE -ne 0) { throw 'El instrumento TLS no pudo completar su salida; revisar el error sin atribuirlo al servidor.' }
