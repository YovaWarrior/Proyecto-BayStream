# T-99 · Emulador de Android 8.0 (API 26) para RNF-003 (Carlos lo autorizó, 10.83).
#
# Usa el SDK de Android que ya está instalado. No activa funciones de Windows
# ni pide administrador: si la aceleración no está lista, se detiene.
# `instalar-imagen` no acepta licencias por su cuenta: si sdkmanager pregunta,
# falla y hay que avisar a Carlos.
#
#   ./tool/t99_emulador.ps1 -Accion estado
#   ./tool/t99_emulador.ps1 -Accion instalar-imagen     (≈ 1 GB)
#   ./tool/t99_emulador.ps1 -Accion crear
#   ./tool/t99_emulador.ps1 -Accion arrancar
#   ./tool/t99_emulador.ps1 -Accion apk -Apk <copia t99>\build\app\outputs\flutter-apk\app-release.apk
#   ./tool/t99_emulador.ps1 -Accion detener
param(
    [Parameter(Mandatory = $true)] [ValidateSet('estado', 'instalar-imagen', 'crear', 'arrancar', 'apk', 'detener')] [string] $Accion,
    [string] $Sdk = (Join-Path $env:LOCALAPPDATA 'Android\Sdk'),
    [string] $Avd = 't99_api26',
    [string] $Imagen = 'system-images;android-26;google_apis;x86_64',
    [string] $Serial = 'emulator-5554',
    [string] $Apk
)
$ErrorActionPreference = 'Stop'
$emulador = Join-Path $Sdk 'emulator\emulator.exe'
$adb = Join-Path $Sdk 'platform-tools\adb.exe'
$sdkmanager = Join-Path $Sdk 'cmdline-tools\latest\bin\sdkmanager.bat'
$avdmanager = Join-Path $Sdk 'cmdline-tools\latest\bin\avdmanager.bat'
# sdkmanager y avdmanager necesitan Java: sin JAVA_HOME, el de Android Studio.
$jbr = 'C:\Program Files\Android\Android Studio\jbr'
if (-not $env:JAVA_HOME -and (Test-Path (Join-Path $jbr 'bin\java.exe'))) { $env:JAVA_HOME = $jbr }

switch ($Accion) {
    'estado' {
        & $emulador -accel-check
        Write-Output '--- AVD'
        & $emulador -list-avds
        Write-Output '--- imagen'
        Test-Path (Join-Path $Sdk ('system-images\' + ($Imagen -split ';', 2)[1].Replace(';', '\')))
        Write-Output '--- dispositivos'
        & $adb devices
    }
    'instalar-imagen' {
        $acel = (& $emulador -accel-check | Out-String)
        if ($acel -notmatch 'is installed and usable') { throw "La aceleración no está lista; no se activa nada: $acel" }
        # Sin entrada estándar: si hay una licencia nueva, sdkmanager no la acepta solo.
        $null | & $sdkmanager --install $Imagen
        if ($LASTEXITCODE -ne 0) { throw "sdkmanager terminó con $LASTEXITCODE" }
    }
    'crear' {
        'no' | & $avdmanager create avd -n $Avd -k $Imagen -d pixel
        if ($LASTEXITCODE -ne 0) { throw "avdmanager terminó con $LASTEXITCODE" }
    }
    'arrancar' {
        Start-Process $emulador -ArgumentList @('-avd', $Avd, '-no-snapshot-save', '-no-boot-anim')
        & $adb -s $Serial wait-for-device
        for ($i = 0; $i -lt 120; $i++) {
            if ((& $adb -s $Serial shell getprop sys.boot_completed | Out-String).Trim() -eq '1') {
                Write-Output "Arrancó: Android $((& $adb -s $Serial shell getprop ro.build.version.release | Out-String).Trim()), API $((& $adb -s $Serial shell getprop ro.build.version.sdk | Out-String).Trim())"
                return
            }
            Start-Sleep -Seconds 2
        }
        throw 'El emulador no terminó de arrancar en 4 min.'
    }
    'apk' {
        $ruta = (Resolve-Path -LiteralPath $Apk).Path
        $temp = [IO.Path]::GetFullPath($env:TEMP).TrimEnd('\') + '\'
        if (-not $ruta.StartsWith($temp, [StringComparison]::OrdinalIgnoreCase) -or $ruta -notmatch '(?i)t99') {
            throw 'Solo el APK del banco t99 compilado en una copia de %TEMP%.'
        }
        if ($Serial -notmatch '^emulator-') { throw 'Esta acción es solo para el emulador.' }
        & $adb -s $Serial install -r $ruta
    }
    'detener' {
        if ($Serial -notmatch '^emulator-') { throw 'Solo el emulador.' }
        & $adb -s $Serial emu kill
    }
}
