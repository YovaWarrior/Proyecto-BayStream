# T-100 · Ayudas para capturar y manejar la app de Windows del manual.
#
# La app se abre aparte, con explorer.exe, y se identifica por su PID. Este
# script no abre ni cierra la app: solo captura su ventana (PrintWindow, que
# funciona aunque esté tapada), le da el foco y le envía clics y teclas.
#
#   ./tool/t100_windows.ps1 -Accion captura -Proceso 1234 -Salida "$env:TEMP\x.png"
#   ./tool/t100_windows.ps1 -Accion foco -Proceso 1234
#   ./tool/t100_windows.ps1 -Accion clic -Proceso 1234 -X 100 -Y 200      (coordenadas del cliente)
#   ./tool/t100_windows.ps1 -Accion texto -Texto "SNTU0000018"       (Unicode, mayúsculas incluidas)
#   ./tool/t100_windows.ps1 -Accion tecla -Tecla "{ENTER}"             (sintaxis de SendKeys)
#   ./tool/t100_windows.ps1 -Accion rueda -Proceso 1234 -X 100 -Y 200 -Pasos -3
#   ./tool/t100_windows.ps1 -Accion ventana -Proceso 1234                  (rectángulo del cliente)
param(
    [Parameter(Mandatory = $true)] [string] $Accion,
    [int] $Proceso = 0,
    [string] $Salida = '',
    [int] $X = 0,
    [int] $Y = 0,
    [int] $Pasos = 0,
    [string] $Texto = '',
    [string] $Tecla = '',
    [int] $Espera = 400
)
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Windows.Forms
Add-Type @"
using System;
using System.Runtime.InteropServices;
public class T100Win {
    [DllImport("user32.dll")] public static extern bool SetProcessDPIAware();
    [DllImport("user32.dll")] public static extern bool PrintWindow(IntPtr hwnd, IntPtr hdc, uint flags);
    [DllImport("user32.dll")] public static extern bool GetClientRect(IntPtr hwnd, out RECT rect);
    [DllImport("user32.dll")] public static extern bool ClientToScreen(IntPtr hwnd, ref POINT p);
    [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr hwnd);
    [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hwnd, int cmd);
    [DllImport("user32.dll")] public static extern bool SetCursorPos(int x, int y);
    [DllImport("user32.dll")] public static extern void mouse_event(uint flags, int dx, int dy, int data, UIntPtr extra);
    [DllImport("user32.dll")] public static extern uint SendInput(uint n, INPUT[] inputs, int size);
    [DllImport("user32.dll")] public static extern IntPtr GetForegroundWindow();
    [StructLayout(LayoutKind.Sequential)] public struct RECT { public int Left, Top, Right, Bottom; }
    [StructLayout(LayoutKind.Sequential)] public struct POINT { public int X, Y; }
    [StructLayout(LayoutKind.Sequential)] public struct KEYBDINPUT { public ushort wVk, wScan; public uint dwFlags, time; public IntPtr dwExtraInfo; }
    [StructLayout(LayoutKind.Explicit)] public struct INPUTUNION { [FieldOffset(0)] public KEYBDINPUT ki; [FieldOffset(0)] public long pad1; [FieldOffset(8)] public long pad2; [FieldOffset(16)] public long pad3; }
    [StructLayout(LayoutKind.Sequential)] public struct INPUT { public uint type; public INPUTUNION u; }
    public static void TypeUnicode(string text) {
        foreach (char c in text) {
            INPUT[] seq = new INPUT[2];
            seq[0].type = 1; seq[0].u.ki.wScan = c; seq[0].u.ki.dwFlags = 4;
            seq[1].type = 1; seq[1].u.ki.wScan = c; seq[1].u.ki.dwFlags = 4 | 2;
            SendInput(2, seq, Marshal.SizeOf(typeof(INPUT)));
            System.Threading.Thread.Sleep(15);
        }
    }
}
"@

# Píxeles reales de la pantalla (escala 125 %), no coordenadas lógicas.
[void][T100Win]::SetProcessDPIAware()

function Get-Hwnd([int] $procId) {
    $p = Get-Process -Id $procId
    if ($p.MainWindowHandle -eq 0) { throw "El proceso $procId no tiene ventana principal." }
    return $p.MainWindowHandle
}

function Get-ClientOrigin([IntPtr] $hwnd) {
    $pt = New-Object T100Win+POINT
    [void][T100Win]::ClientToScreen($hwnd, [ref]$pt)
    return $pt
}

switch ($Accion) {
    'captura' {
        $hwnd = Get-Hwnd $Proceso
        $r = New-Object T100Win+RECT
        [void][T100Win]::GetClientRect($hwnd, [ref]$r)
        $w = $r.Right - $r.Left; $h = $r.Bottom - $r.Top
        $bmp = New-Object System.Drawing.Bitmap $w, $h
        $g = [System.Drawing.Graphics]::FromImage($bmp)
        $hdc = $g.GetHdc()
        # PW_CLIENTONLY (1) | PW_RENDERFULLCONTENT (2): el cliente, aunque esté tapado.
        $ok = [T100Win]::PrintWindow($hwnd, $hdc, 3)
        $g.ReleaseHdc($hdc); $g.Dispose()
        if (-not $ok) { throw 'PrintWindow falló.' }
        $bmp.Save($Salida, [System.Drawing.Imaging.ImageFormat]::Png); $bmp.Dispose()
        Write-Output "$Salida ${w}x${h}"
    }
    'ventana' {
        $hwnd = Get-Hwnd $Proceso
        $r = New-Object T100Win+RECT
        [void][T100Win]::GetClientRect($hwnd, [ref]$r)
        $o = Get-ClientOrigin $hwnd
        Write-Output ("cliente {0}x{1} en pantalla ({2},{3}); primer plano: {4}" -f ($r.Right - $r.Left), ($r.Bottom - $r.Top), $o.X, $o.Y, ([T100Win]::GetForegroundWindow() -eq $hwnd))
    }
    'foco' {
        $hwnd = Get-Hwnd $Proceso
        [void][T100Win]::ShowWindow($hwnd, 3)   # SW_MAXIMIZE
        [void][T100Win]::SetForegroundWindow($hwnd)
        Start-Sleep -Milliseconds $Espera
        Write-Output ("primer plano: {0}" -f ([T100Win]::GetForegroundWindow() -eq $hwnd))
    }
    'clic' {
        $hwnd = Get-Hwnd $Proceso
        $o = Get-ClientOrigin $hwnd
        [void][T100Win]::SetCursorPos($o.X + $X, $o.Y + $Y)
        Start-Sleep -Milliseconds 60
        [T100Win]::mouse_event(2, 0, 0, 0, [UIntPtr]::Zero)   # LEFTDOWN
        Start-Sleep -Milliseconds 40
        [T100Win]::mouse_event(4, 0, 0, 0, [UIntPtr]::Zero)   # LEFTUP
        Start-Sleep -Milliseconds $Espera
        Write-Output "clic en ($X,$Y)"
    }
    'rueda' {
        $hwnd = Get-Hwnd $Proceso
        $o = Get-ClientOrigin $hwnd
        [void][T100Win]::SetCursorPos($o.X + $X, $o.Y + $Y)
        Start-Sleep -Milliseconds 60
        [T100Win]::mouse_event(0x0800, 0, 0, $Pasos * 120, [UIntPtr]::Zero)
        Start-Sleep -Milliseconds $Espera
        Write-Output "rueda $Pasos en ($X,$Y)"
    }
    'texto' {
        [T100Win]::TypeUnicode($Texto)
        Start-Sleep -Milliseconds $Espera
        Write-Output "texto enviado ($($Texto.Length) caracteres)"
    }
    'tecla' {
        [System.Windows.Forms.SendKeys]::SendWait($Tecla)
        Start-Sleep -Milliseconds $Espera
        Write-Output "tecla $Tecla"
    }
    default { throw "Acción desconocida: $Accion" }
}
