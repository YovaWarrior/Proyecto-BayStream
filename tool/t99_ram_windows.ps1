# T-99 · RAM de Windows para RNF-001 y RNF-007 (T-63, 1.4: WorkingSet64).
#
# Solo el banco t99 compilado en una copia de %TEMP% (tool/t99_copia.ps1):
# nunca la app real ni la de demo17. Se abre con explorer.exe, para que use
# el almacén real con su namespace t99 y no el del paquete del agente
# (AGENTS.md, T-73 10.9), y se cierra por PID.
#
# Acciones:
#   abrir    -Exe <copia>\build\windows\x64\runner\Release\baystream.exe [-Salida <json>]
#            Abre por explorer.exe, anota el PID y maximiza la ventana.
#   entorno  -AppPid <pid> -Salida <json>
#            Sistema, resolución física, escala de la ventana y si es la
#            recomendada (PerMonitorSettings DpiValue 0 o ausente), maximizada.
#   medir    -AppPid <pid> -Paso <paso> -Salida <csv> [-Archivo A01] [-Corrida 1]
#            Espera 5 s sin interacción y toma cinco lecturas separadas 0.5 s.
#   seguir   -AppPid <pid> -Pasos <pasos.jsonl del conductor> -Salida <csv> …
#            Hace «medir» en cada paso que anuncia tool/t99_conductor.dart.
#   cerrar   -AppPid <pid>
# Las salidas van a %TEMP% y no se sobrescriben: el CSV solo crece.
param(
    [Parameter(Mandatory = $true)] [ValidateSet('abrir', 'entorno', 'medir', 'seguir', 'cerrar')] [string] $Accion,
    [string] $Exe,
    [int] $AppPid,
    [string] $Paso,
    [string] $Pasos,
    [string] $Salida,
    [string] $Archivo = '',
    [int] $Corrida = 1,
    [int] $Reposo = 5,
    [int] $Lecturas = 5,
    [int] $IntervaloMs = 500,
    [int] $LimiteMin = 30
)
$ErrorActionPreference = 'Stop'

Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
public static class T99Ventana {
    [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr h, int n);
    [DllImport("user32.dll")] public static extern bool IsZoomed(IntPtr h);
    [DllImport("user32.dll")] public static extern uint GetDpiForWindow(IntPtr h);
    [DllImport("user32.dll")] public static extern bool SetProcessDPIAware();
    [StructLayout(LayoutKind.Sequential)] public struct RECT { public int L, T, R, B; }
    [DllImport("user32.dll")] public static extern bool GetClientRect(IntPtr h, out RECT r);
    [DllImport("user32.dll")] public static extern IntPtr GetDC(IntPtr h);
    [DllImport("user32.dll")] public static extern int ReleaseDC(IntPtr h, IntPtr dc);
    [DllImport("gdi32.dll")] public static extern int GetDeviceCaps(IntPtr dc, int i);
}
'@

function Test-EnTemp([string] $ruta) {
    $t = [IO.Path]::GetFullPath($env:TEMP).TrimEnd('\') + '\'
    return ([IO.Path]::GetFullPath($ruta)).StartsWith($t, [StringComparison]::OrdinalIgnoreCase)
}

function Get-ClienteT99([int] $id) {
    if ($id -lt 1) { throw 'Indica -AppPid.' }
    $p = Get-Process -Id $id
    if (-not $p.Path -or -not (Test-EnTemp $p.Path) -or $p.Path -notmatch '(?i)t99' -or
        $p.Path -match '(?i)demo17' -or $p.ProcessName -notmatch '^baystream') {
        throw "El PID $id no es un banco t99 de %TEMP%: $($p.Path)"
    }
    return $p
}

function Add-Lecturas([System.Diagnostics.Process] $p, [string] $paso) {
    if (-not $Salida -or -not (Test-EnTemp $Salida)) { throw 'La salida debe ir en %TEMP%.' }
    New-Item -ItemType Directory -Force -Path (Split-Path $Salida) | Out-Null
    if (-not (Test-Path $Salida)) {
        'plataforma,archivo,corrida,paso,lectura,ts,bytes,privada_bytes' | Set-Content -Encoding ascii $Salida
    }
    Start-Sleep -Seconds $Reposo
    for ($i = 1; $i -le $Lecturas; $i++) {
        $p.Refresh()
        $fila = @('windows', $Archivo, $Corrida, $paso, $i, (Get-Date).ToUniversalTime().ToString('o'),
            $p.WorkingSet64, $p.PrivateMemorySize64) -join ','
        Add-Content -Encoding ascii $Salida $fila
        if ($i -lt $Lecturas) { Start-Sleep -Milliseconds $IntervaloMs }
    }
    Write-Output "$paso · $Lecturas lecturas · última $([math]::Round($p.WorkingSet64 / 1e6, 1)) MB"
}

switch ($Accion) {
    'abrir' {
        $ruta = (Resolve-Path -LiteralPath $Exe).Path
        if (-not (Test-EnTemp $ruta) -or $ruta -notmatch '(?i)t99' -or $ruta -match '(?i)demo17' -or
            [IO.Path]::GetFileName($ruta) -notmatch '^baystream.*\.exe$') {
            throw 'Solo un banco t99 compilado en una copia de %TEMP%.'
        }
        if (@(Get-Process -ErrorAction SilentlyContinue | Where-Object { $_.Path -eq $ruta }).Count -gt 0) {
            throw 'Ese banco ya está abierto; ciérralo por PID antes.'
        }
        $desde = Get-Date
        Start-Process explorer.exe -ArgumentList ('"' + $ruta + '"')
        $p = $null
        for ($i = 0; $i -lt 60 -and -not $p; $i++) {
            Start-Sleep -Milliseconds 500
            $p = Get-Process -ErrorAction SilentlyContinue |
                Where-Object { $_.Path -eq $ruta -and $_.StartTime -ge $desde.AddSeconds(-1) } |
                Select-Object -First 1
        }
        if (-not $p) { throw 'El banco no arrancó en 30 s.' }
        $padre = (Get-CimInstance Win32_Process -Filter "ProcessId=$($p.Id)").ParentProcessId
        $nombrePadre = (Get-Process -Id $padre -ErrorAction SilentlyContinue).ProcessName
        for ($i = 0; $i -lt 40 -and $p.MainWindowHandle -eq 0; $i++) { Start-Sleep -Milliseconds 250; $p.Refresh() }
        if ($p.MainWindowHandle -ne 0) { [void][T99Ventana]::ShowWindow($p.MainWindowHandle, 3) }
        $r = [ordered]@{ pid = $p.Id; exe = $ruta; padre = $nombrePadre; abierto = $desde.ToString('o') }
        if ($Salida) { $r | ConvertTo-Json | Set-Content -Encoding utf8 $Salida }
        Write-Output "PID $($p.Id) · padre $nombrePadre · maximizada"
    }
    'entorno' {
        $p = Get-ClienteT99 $AppPid
        [void][T99Ventana]::SetProcessDPIAware()
        $dc = [T99Ventana]::GetDC([IntPtr]::Zero)
        $ancho = [T99Ventana]::GetDeviceCaps($dc, 118)   # DESKTOPHORZRES
        $alto = [T99Ventana]::GetDeviceCaps($dc, 117)    # DESKTOPVERTRES
        [void][T99Ventana]::ReleaseDC([IntPtr]::Zero, $dc)
        $h = $p.MainWindowHandle
        $rect = New-Object T99Ventana+RECT
        [void][T99Ventana]::GetClientRect($h, [ref]$rect)
        $dpi = [T99Ventana]::GetDpiForWindow($h)
        $ajustes = @()
        $clave = 'HKCU:\Control Panel\Desktop\PerMonitorSettings'
        if (Test-Path $clave) {
            foreach ($k in Get-ChildItem $clave) {
                $ajustes += [ordered]@{ monitor = $k.PSChildName; DpiValue = (Get-ItemProperty $k.PSPath).DpiValue }
            }
        }
        $so = Get-CimInstance Win32_OperatingSystem
        $r = [ordered]@{
            sistema              = "$($so.Caption) $($so.Version)"
            compilacion          = $so.BuildNumber
            pantalla_fisica      = "${ancho}x${alto}"
            escala_de_la_ventana = "$([math]::Round($dpi / 96 * 100)) %"
            # DpiValue es el paso respecto de la escala recomendada de cada
            # monitor: 0 (o ausente) es la recomendada. Hay que ver cuál es el
            # monitor de la ventana; Windows guarda también los que se conectaron.
            escala_recomendada   = 'DpiValue 0 o ausente = la recomendada; ver el monitor de la ventana en per_monitor_settings'
            per_monitor_settings = $ajustes
            maximizada           = [T99Ventana]::IsZoomed($h)
            area_cliente_fisica  = "$($rect.R - $rect.L)x$($rect.B - $rect.T)"
            pid                  = $p.Id
            exe                  = $p.Path
            fecha                = (Get-Date).ToString('o')
        }
        if (-not $Salida -or -not (Test-EnTemp $Salida)) { throw 'La salida debe ir en %TEMP%.' }
        $r | ConvertTo-Json -Depth 4 | Set-Content -Encoding utf8 $Salida
        $r | ConvertTo-Json -Depth 4
    }
    'medir' {
        if (-not $Paso) { throw 'Indica -Paso.' }
        Add-Lecturas (Get-ClienteT99 $AppPid) $Paso
    }
    'seguir' {
        $p = Get-ClienteT99 $AppPid
        if (-not $Pasos) { throw 'Indica -Pasos (el registro del conductor).' }
        # El registro tiene una ruta fija de compilación y crece entre corridas:
        # solo cuentan las líneas escritas desde que arrancó este proceso.
        $arranque = $p.StartTime.ToUniversalTime().AddSeconds(-1)
        $vistos = 0
        $limite = (Get-Date).AddMinutes($LimiteMin)
        while ((Get-Date) -lt $limite) {
            if ($p.HasExited) { throw 'El banco se cerró antes de terminar.' }
            # Solo líneas completas: el conductor puede estar escribiendo la última.
            # Lectura compartida: el banco puede tener el archivo abierto (ensayo
            # de la Fase B: IOException al leer «fin»). Si choca, se reintenta.
            $texto = ''
            if (Test-Path $Pasos) {
                try {
                    $flujo = New-Object IO.FileStream($Pasos, [IO.FileMode]::Open, [IO.FileAccess]::Read, [IO.FileShare]::ReadWrite)
                    $lector = New-Object IO.StreamReader($flujo)
                    $texto = $lector.ReadToEnd()
                    $lector.Dispose()
                } catch [IO.IOException] {
                    Start-Sleep -Milliseconds 100
                    continue
                }
            }
            $lineas = @($texto -split "`n" | Select-Object -SkipLast 1 | ForEach-Object { $_.TrimEnd("`r") })
            if ($lineas.Count -gt $vistos) {
                $nuevas = $lineas[$vistos..($lineas.Count - 1)]
                $vistos = $lineas.Count
                foreach ($l in $nuevas) {
                    if (-not $l.Trim()) { continue }
                    $registro = $l | ConvertFrom-Json
                    if ([DateTime]::Parse($registro.ts).ToUniversalTime() -lt $arranque) { continue }
                    $paso = $registro.paso
                    if ($paso -eq 'fin') { Write-Output 'Escenario terminado.'; return }
                    if ($paso -eq 'error') { throw "El conductor falló: $l" }
                    if ($paso -ne 'captura') { Add-Lecturas $p $paso }
                }
            }
            Start-Sleep -Milliseconds 200
        }
        throw "El escenario no terminó en $LimiteMin min."
    }
    'cerrar' {
        $p = Get-ClienteT99 $AppPid
        [void]$p.CloseMainWindow()
        if (-not $p.WaitForExit(5000)) { Stop-Process -Id $AppPid }
        Write-Output "Cerrado el PID $AppPid."
    }
}
