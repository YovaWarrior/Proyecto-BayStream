# T-99 · RAM de Android para RNF-001 y RNF-007 (T-63, 1.4: RSS).
#
# Solo el paquete del banco, gt.cmartinez.baystream.t99 (tool/t99_copia.ps1):
# nunca la app real. Sirve igual para el Honor (Fase B, cuando Carlos lo
# permita) y para el emulador API 26 (-Serial emulator-5554).
# RSS: «TOTAL RSS» de `dumpsys meminfo` (Android 10 en adelante). Si la versión
# no lo trae (Android 8 y 9), VmRSS de /proc/<pid>/status, y se anota la fuente.
# Volcados sanitizados: de dumpsys solo se guardan cifras, nunca el texto.
#
# Acciones:
#   entorno  -Serial <serie> -Salida <json>
#   medir    -Serial <serie> -Paso <paso> -Salida <csv> [-Archivo A01] [-Corrida 1]
#   seguir   -Serial <serie> -Salida <csv> …   (lee «T99 PASO» del logcat del banco)
param(
    [Parameter(Mandatory = $true)] [ValidateSet('entorno', 'medir', 'seguir')] [string] $Accion,
    [Parameter(Mandatory = $true)] [string] $Serial,
    [string] $Paquete = 'gt.cmartinez.baystream.t99',
    [string] $Paso,
    [string] $Salida,
    [string] $Archivo = '',
    [int] $Corrida = 1,
    [int] $Reposo = 5,
    [int] $Lecturas = 5,
    [int] $IntervaloMs = 500,
    [int] $LimiteMin = 30,
    [string] $Adb = 'adb'
)
$ErrorActionPreference = 'Stop'
if ($Paquete -notmatch '\.t99$') { throw 'Solo el paquete .t99 del banco, nunca la app real.' }
if (-not $Salida) { throw 'Indica -Salida en %TEMP%.' }
$temp = [IO.Path]::GetFullPath($env:TEMP).TrimEnd('\') + '\'
if (-not ([IO.Path]::GetFullPath($Salida)).StartsWith($temp, [StringComparison]::OrdinalIgnoreCase)) {
    throw 'La salida debe ir en %TEMP%.'
}
New-Item -ItemType Directory -Force -Path (Split-Path $Salida) | Out-Null

function Invoke-Adb { & $Adb -s $Serial @args }

function Get-PidDelBanco {
    $id = (Invoke-Adb shell pidof $Paquete | Out-String).Trim()
    if (-not $id) { throw "El banco $Paquete no está corriendo en $Serial." }
    return [int]($id -split '\s+')[0]
}

function Get-Lectura {
    $texto = Invoke-Adb shell dumpsys meminfo $Paquete | Out-String
    $pss = $null; $rss = $null; $fuente = $null
    if ($texto -match 'TOTAL PSS:\s+(\d+)') { $pss = [long]$Matches[1] }
    if ($texto -match 'TOTAL RSS:\s+(\d+)') { $rss = [long]$Matches[1]; $fuente = 'dumpsys TOTAL RSS' }
    if (-not $pss -and $texto -match '(?m)^\s*TOTAL\s+(\d+)') { $pss = [long]$Matches[1] }
    if (-not $rss) {
        $estado = Invoke-Adb shell cat "/proc/$(Get-PidDelBanco)/status" | Out-String
        if ($estado -match 'VmRSS:\s+(\d+)\s*kB') { $rss = [long]$Matches[1]; $fuente = '/proc VmRSS' }
    }
    if (-not $rss) { throw 'No se pudo leer el RSS del banco.' }
    # dumpsys y /proc dan kB de 1024 bytes; el resumen pasa a MB del SI.
    return @{ rss = $rss * 1024; pss = if ($pss) { $pss * 1024 } else { '' }; fuente = $fuente }
}

function Add-Lecturas([string] $paso) {
    if (-not (Test-Path $Salida)) {
        'plataforma,archivo,corrida,paso,lectura,ts,bytes,pss_bytes,fuente' | Set-Content -Encoding ascii $Salida
    }
    Start-Sleep -Seconds $Reposo
    for ($i = 1; $i -le $Lecturas; $i++) {
        $l = Get-Lectura
        $fila = @("android-$Serial", $Archivo, $Corrida, $paso, $i,
            (Get-Date).ToUniversalTime().ToString('o'), $l.rss, $l.pss, $l.fuente) -join ','
        Add-Content -Encoding ascii $Salida $fila
        if ($i -lt $Lecturas) { Start-Sleep -Milliseconds $IntervaloMs }
    }
    Write-Output "$paso · $Lecturas lecturas · última $([math]::Round($l.rss / 1e6, 1)) MB ($($l.fuente))"
}

switch ($Accion) {
    'entorno' {
        $prop = { param($n) (Invoke-Adb shell getprop $n | Out-String).Trim() }
        $version = (Invoke-Adb shell dumpsys package $Paquete | Select-String 'versionName=|versionCode=' |
            ForEach-Object { $_.Line.Trim() }) -join ' '
        $r = [ordered]@{
            serie          = $Serial
            android        = & $prop 'ro.build.version.release'
            api            = & $prop 'ro.build.version.sdk'
            fabricante     = & $prop 'ro.product.manufacturer'
            modelo         = & $prop 'ro.product.model'
            pantalla       = (Invoke-Adb shell wm size | Out-String).Trim()
            densidad       = (Invoke-Adb shell wm density | Out-String).Trim()
            paquete        = $Paquete
            version_banco  = $version
            fecha          = (Get-Date).ToString('o')
        }
        $r | ConvertTo-Json | Set-Content -Encoding utf8 $Salida
        $r | ConvertTo-Json
    }
    'medir' {
        if (-not $Paso) { throw 'Indica -Paso.' }
        [void](Get-PidDelBanco)
        Add-Lecturas $Paso
    }
    'seguir' {
        $id = Get-PidDelBanco
        $registro = "$Salida.logcat.tmp"
        $proceso = Start-Process $Adb -ArgumentList @('-s', $Serial, 'logcat', '-v', 'brief', "--pid=$id", '-T', '1') `
            -RedirectStandardOutput $registro -NoNewWindow -PassThru
        try {
            $vistos = 0
            $limite = (Get-Date).AddMinutes($LimiteMin)
            while ((Get-Date) -lt $limite) {
                $lineas = @(Get-Content $registro -ErrorAction SilentlyContinue | Where-Object { $_ -match 'T99 PASO (\S+)' })
                if ($lineas.Count -gt $vistos) {
                    $nuevas = $lineas[$vistos..($lineas.Count - 1)]
                    $vistos = $lineas.Count
                    foreach ($l in $nuevas) {
                        [void]($l -match 'T99 PASO (\S+)')
                        $paso = $Matches[1]
                        if ($paso -eq 'fin') { Write-Output 'Escenario terminado.'; return }
                        if ($paso -eq 'error') { throw "El conductor falló: $l" }
                        if ($paso -ne 'captura') { Add-Lecturas $paso }
                    }
                }
                Start-Sleep -Milliseconds 300
            }
            throw "El escenario no terminó en $LimiteMin min."
        } finally {
            if (-not $proceso.HasExited) { Stop-Process -Id $proceso.Id }
            # El registro solo traía líneas del banco; no se conserva.
            Remove-Item $registro -ErrorAction SilentlyContinue
        }
    }
}
