# T-120, entrega 2 · Los dos monitores (docs/T120-RESULTADOS.md 1.7).
#
# Abre el banco de Windows de la entrega 2 (compilado en DEPURACIÓN, para que
# un desborde se reporte) con el escenario «monitores»: el Plano con zoom y
# desplazado, quieto. Mientras Carlos arrastra la ventana de un monitor al
# otro, este script sondea cada medio segundo la ventana de ESE proceso (por
# su PID, nada más) y, en cada cambio, anota en monitores.jsonl el monitor,
# su DPI (GetDpiForWindow), el rectángulo del cliente en la pantalla y si está
# maximizada o minimizada, y guarda una captura de la ventana (PrintWindow).
# El conductor anota en pasos.jsonl el tamaño lógico, la densidad, el zoom,
# los desplazamientos y cada error de Flutter (los desbordes).
#
#   ./tool/t120_monitores.ps1 -Exe "$env:TEMP\t120-e2\banco-debug\...\baystream.exe" `
#     -Almacen "$env:TEMP\t120-e2\almacenes\monitores" -Caso "$env:TEMP\t120-e2\caso" `
#     -Salida build/t120/e2/monitores [-Minutos 40]
#
# El almacén va en %TEMP% (namespace r4): no abre la BayStream instalada, ni
# %LOCALAPPDATA%\BayStream, ni la carpeta de ningún paquete. Termina cuando
# se cierra la ventana del banco o al pasar -Minutos.
param(
    [Parameter(Mandatory = $true)] [string] $Exe,
    [Parameter(Mandatory = $true)] [string] $Almacen,
    [Parameter(Mandatory = $true)] [string] $Caso,
    [Parameter(Mandatory = $true)] [string] $Salida,
    [string] $Archivo = 'T120_BUQUE_LISTA_977.edi',
    [int] $Minutos = 40
)
$ErrorActionPreference = 'Stop'
$repo = (Resolve-Path (Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) '..')).Path
$temp = [IO.Path]::GetFullPath($env:TEMP).TrimEnd('\') + '\'
foreach ($ruta in @($Exe, $Almacen, $Caso)) {
    if (-not ([IO.Path]::GetFullPath($ruta) + '\').StartsWith($temp, [StringComparison]::OrdinalIgnoreCase)) {
        throw "Tiene que estar en %TEMP%: $ruta"
    }
}
$salidaCompleta = [IO.Path]::GetFullPath((Join-Path $repo $Salida))
if (-not $salidaCompleta.StartsWith((Join-Path $repo 'build\t120\e2'), [StringComparison]::OrdinalIgnoreCase)) {
    throw "La salida va dentro de build\t120\e2: $salidaCompleta"
}
if (Test-Path (Join-Path $salidaCompleta 'monitores.jsonl')) {
    throw "Ya hay una corrida en $salidaCompleta: cada corrida, su carpeta."
}
New-Item -ItemType Directory -Force -Path (Join-Path $salidaCompleta 'capturas') | Out-Null
New-Item -ItemType Directory -Force -Path $Almacen | Out-Null

Add-Type -ReferencedAssemblies System.Drawing -TypeDefinition @'
using System;
using System.Drawing;
using System.Drawing.Imaging;
using System.Runtime.InteropServices;
public static class T120Ventana {
    [StructLayout(LayoutKind.Sequential)] public struct RECT { public int Left, Top, Right, Bottom; }
    [StructLayout(LayoutKind.Sequential)] public struct POINT { public int X, Y; }
    [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
    public struct MONITORINFOEX { public int cbSize; public RECT rcMonitor; public RECT rcWork; public uint dwFlags;
        [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 32)] public string szDevice; }
    [DllImport("user32.dll")] public static extern bool SetProcessDpiAwarenessContext(IntPtr v);
    [DllImport("user32.dll")] public static extern uint GetDpiForWindow(IntPtr h);
    [DllImport("user32.dll")] public static extern bool GetClientRect(IntPtr h, out RECT r);
    [DllImport("user32.dll")] public static extern bool ClientToScreen(IntPtr h, ref POINT p);
    [DllImport("user32.dll")] public static extern IntPtr MonitorFromWindow(IntPtr h, uint f);
    [DllImport("user32.dll", CharSet = CharSet.Unicode)] public static extern bool GetMonitorInfo(IntPtr m, ref MONITORINFOEX i);
    [DllImport("user32.dll")] public static extern bool IsZoomed(IntPtr h);
    [DllImport("user32.dll")] public static extern bool IsIconic(IntPtr h);
    [DllImport("user32.dll")] public static extern bool PrintWindow(IntPtr h, IntPtr dc, uint f);
    public static string Estado(IntPtr h) {
        RECT r; GetClientRect(h, out r);
        POINT p = new POINT(); ClientToScreen(h, ref p);
        MONITORINFOEX m = new MONITORINFOEX(); m.cbSize = Marshal.SizeOf(typeof(MONITORINFOEX));
        GetMonitorInfo(MonitorFromWindow(h, 2), ref m);
        return String.Format("{0}|{1}|{2},{3},{4}x{5}|{6}|{7}", m.szDevice, GetDpiForWindow(h),
            p.X, p.Y, r.Right, r.Bottom, IsZoomed(h) ? "maximizada" : "", IsIconic(h) ? "minimizada" : "");
    }
    public static bool Capturar(IntPtr h, string ruta) {
        RECT r; GetClientRect(h, out r);
        if (r.Right <= 0 || r.Bottom <= 0) return false;
        using (Bitmap b = new Bitmap(r.Right, r.Bottom)) {
            using (Graphics g = Graphics.FromImage(b)) {
                IntPtr dc = g.GetHdc();
                // PW_CLIENTONLY | PW_RENDERFULLCONTENT
                PrintWindow(h, dc, 3);
                g.ReleaseHdc(dc);
            }
            b.Save(ruta, ImageFormat.Png);
        }
        return true;
    }
}
'@
# Por monitor: las medidas en píxeles físicos, sin el escalado del sistema.
[void][T120Ventana]::SetProcessDpiAwarenessContext([IntPtr](-4))

$env:T147_ALMACEN = [IO.Path]::GetFullPath($Almacen)
$env:T147_CASO = [IO.Path]::GetFullPath($Caso)
$env:T147_SALIDA = $salidaCompleta
$env:T147_ESCENARIO = 'monitores'
$env:T147_ARCHIVO = $Archivo
$proceso = Start-Process -FilePath $Exe -WorkingDirectory (Split-Path -Parent $Exe) -PassThru
$registro = Join-Path $salidaCompleta 'monitores.jsonl'
"{`"paso`":`"inicio`",`"pid`":$($proceso.Id),`"ts`":`"$((Get-Date).ToUniversalTime().ToString('o'))`"}" | Out-File -FilePath $registro -Encoding utf8 -Append
Write-Host "Banco abierto (PID $($proceso.Id)). Sondeo la ventana hasta que se cierre."

$ultimo = ''
$n = 0
$fin = (Get-Date).AddMinutes($Minutos)
while (-not $proceso.HasExited -and (Get-Date) -lt $fin) {
    Start-Sleep -Milliseconds 500
    $proceso.Refresh()
    $h = $proceso.MainWindowHandle
    if ($h -eq [IntPtr]::Zero) { continue }
    $estado = [T120Ventana]::Estado($h)
    if ($estado -eq $ultimo) { continue }
    $ultimo = $estado
    $n++
    $partes = $estado.Split('|')
    $captura = ('{0:D3}.png' -f $n)
    $ok = [T120Ventana]::Capturar($h, (Join-Path $salidaCompleta "capturas\$captura"))
    $linea = [ordered]@{
        paso = 'ventana'; n = $n; ts = (Get-Date).ToUniversalTime().ToString('o');
        monitor = $partes[0]; dpi = [int]$partes[1]; cliente = $partes[2];
        maximizada = ($partes[3] -ne ''); minimizada = ($partes[4] -ne '');
        captura = $(if ($ok) { $captura } else { $null })
    }
    ($linea | ConvertTo-Json -Compress) | Out-File -FilePath $registro -Encoding utf8 -Append
    Write-Host ("{0} {1} dpi {2} cliente {3} {4}{5}" -f $n, $partes[0], $partes[1], $partes[2], $partes[3], $partes[4])
}
if (-not $proceso.HasExited) { Stop-Process -Id $proceso.Id }
"{`"paso`":`"fin`",`"ts`":`"$((Get-Date).ToUniversalTime().ToString('o'))`"}" | Out-File -FilePath $registro -Encoding utf8 -Append
Write-Host "Fin: $n cambios en $registro"
