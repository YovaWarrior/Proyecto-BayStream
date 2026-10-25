# T-117 y T-118 · Corrección 2 de la entrega 1 (SPRINT-4.md 10.44, H4): el árbol
# accesible de Windows del banco, para ver qué oye el lector de pantalla.
#
# Lee el árbol de la ventana de dos maneras, porque los lectores usan las dos:
#   - UIA (la vista de control): tipo de control localizado, nombre, ayuda y
#     patrones (Invoke: se puede activar);
#   - MSAA: rol y nombre.
# En los dos, el motor de Flutter arma el nombre con la etiqueta y la
# descripción emergente sumadas («Acciones. Acciones»).
# No mueve el mouse ni toca el teclado: activa los controles por UIA (Invoke) y
# cambia el tamaño de la ventana con SetWindowPos. La app se abre aparte, con
# explorer.exe, y se identifica por su PID; la captura es la de t100_windows.ps1.
#
#   ./tool/t117_correccion2_windows.ps1 -Accion arbol -Proceso 1234 -Salida "build\t117-correccion2\windows\despues\700-contenido"
#   ./tool/t117_correccion2_windows.ps1 -Accion activar -Proceso 1234 -Nombre '^Modo del plano: '
#   ./tool/t117_correccion2_windows.ps1 -Accion ancho -Proceso 1234 -AnchoDp 700 -AltoDp 682
param(
    [Parameter(Mandatory = $true)] [ValidateSet('arbol', 'activar', 'ancho')] [string] $Accion,
    [Parameter(Mandatory = $true)] [int] $Proceso,
    [string] $Salida = '',
    [string] $Nombre = '',
    [double] $AnchoDp = 0,
    [double] $AltoDp = 0,
    [int] $MaxNodos = 2000
)
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName UIAutomationClient
Add-Type -AssemblyName UIAutomationTypes
Add-Type -ReferencedAssemblies UIAutomationClient, UIAutomationTypes, Accessibility, WindowsBase @"
using System;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using System.Text;
using System.Windows.Automation;
using Accessibility;

public class T117Nodo {
    public string Arbol; public int Nivel; public string Rol; public string Nombre;
    public string Ayuda; public bool FueraDeVista; public string Rect; public string Patrones;
}

public static class T117Arbol {
    [DllImport("oleacc.dll")]
    static extern int AccessibleObjectFromWindow(IntPtr hwnd, uint id, ref Guid iid,
        [MarshalAs(UnmanagedType.Interface)] out IAccessible acc);
    [DllImport("oleacc.dll")]
    static extern int AccessibleChildren(IAccessible container, int start, int count,
        [Out] object[] children, out int obtained);
    [DllImport("oleacc.dll", CharSet = CharSet.Unicode)]
    static extern uint GetRoleText(uint role, StringBuilder text, uint max);
    [DllImport("user32.dll")] public static extern bool SetProcessDPIAware();
    [DllImport("user32.dll")] public static extern uint GetDpiForWindow(IntPtr hwnd);
    [DllImport("user32.dll")] public static extern bool GetClientRect(IntPtr hwnd, out RECT r);
    [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr hwnd, out RECT r);
    [DllImport("user32.dll")] public static extern bool IsZoomed(IntPtr hwnd);
    [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hwnd, int cmd);
    [DllImport("user32.dll")] public static extern bool SetWindowPos(IntPtr hwnd, IntPtr after,
        int x, int y, int w, int h, uint flags);
    [StructLayout(LayoutKind.Sequential)]
    public struct RECT { public int Left, Top, Right, Bottom; }

    public static List<T117Nodo> Uia(IntPtr hwnd, int max) {
        var lista = new List<T117Nodo>();
        Recorrer(TreeWalker.ControlViewWalker, AutomationElement.FromHandle(hwnd), 0, lista, max);
        return lista;
    }

    static void Recorrer(TreeWalker w, AutomationElement e, int nivel, List<T117Nodo> lista, int max) {
        if (lista.Count >= max) return;
        var nodo = new T117Nodo { Arbol = "uia", Nivel = nivel };
        try {
            var c = e.Current;
            nodo.Rol = c.LocalizedControlType; nodo.Nombre = c.Name; nodo.Ayuda = c.HelpText;
            nodo.FueraDeVista = c.IsOffscreen; nodo.Rect = c.BoundingRectangle.ToString();
            var patrones = new List<string>();
            foreach (var p in e.GetSupportedPatterns())
                patrones.Add(p.ProgrammaticName.Replace("PatternIdentifiers.Pattern", ""));
            nodo.Patrones = string.Join(",", patrones);
        } catch (Exception ex) { nodo.Rol = "error"; nodo.Nombre = ex.Message; }
        lista.Add(nodo);
        var hijo = w.GetFirstChild(e);
        while (hijo != null) {
            Recorrer(w, hijo, nivel + 1, lista, max);
            hijo = w.GetNextSibling(hijo);
        }
    }

    public static List<T117Nodo> Msaa(IntPtr hwnd, int max) {
        var lista = new List<T117Nodo>();
        var iid = new Guid("618736E0-3C3D-11CF-810C-00AA00389B71");
        IAccessible acc;
        if (AccessibleObjectFromWindow(hwnd, 0xFFFFFFFC, ref iid, out acc) != 0 || acc == null) return lista;
        RecorrerMsaa(acc, 0, 0, lista, max);
        return lista;
    }

    static string Rol(object rol) {
        if (!(rol is int)) return rol == null ? "" : rol.ToString();
        var texto = new StringBuilder(128);
        GetRoleText((uint)(int)rol, texto, 128);
        return texto.ToString();
    }

    static void RecorrerMsaa(IAccessible acc, int id, int nivel, List<T117Nodo> lista, int max) {
        if (lista.Count >= max || nivel > 60) return;
        var nodo = new T117Nodo { Arbol = "msaa", Nivel = nivel };
        try {
            nodo.Nombre = acc.get_accName(id);
            nodo.Rol = Rol(acc.get_accRole(id));
            var estado = acc.get_accState(id);
            int bits = estado is int ? (int)estado : 0;
            nodo.FueraDeVista = (bits & 0x8000) != 0 || (bits & 0x10000) != 0;
            try { nodo.Ayuda = acc.get_accDescription(id); } catch { }
        } catch (Exception ex) { nodo.Rol = "error"; nodo.Nombre = ex.Message; }
        lista.Add(nodo);
        if (id != 0) return;
        int cuantos = 0;
        try { cuantos = acc.accChildCount; } catch { }
        if (cuantos <= 0) return;
        var hijos = new object[cuantos];
        int obtenidos;
        if (AccessibleChildren(acc, 0, cuantos, hijos, out obtenidos) != 0) return;
        for (int i = 0; i < obtenidos; i++) {
            var hijo = hijos[i] as IAccessible;
            if (hijo != null) RecorrerMsaa(hijo, 0, nivel + 1, lista, max);
            else if (hijos[i] is int) RecorrerMsaa(acc, (int)hijos[i], nivel + 1, lista, max);
        }
    }

    /// El primer control a la vista cuyo nombre cumple el patrón, activado por
    /// Invoke (sin mouse); devuelve lo que encontró.
    public static string Activar(IntPtr hwnd, string patron) {
        var regex = new System.Text.RegularExpressions.Regex(patron);
        var pila = new Stack<AutomationElement>();
        pila.Push(AutomationElement.FromHandle(hwnd));
        var w = TreeWalker.ControlViewWalker;
        var hallados = new List<AutomationElement>();
        while (pila.Count > 0) {
            var e = pila.Pop();
            try {
                var c = e.Current;
                if (!c.IsOffscreen && c.Name != null && regex.IsMatch(c.Name)) hallados.Add(e);
            } catch { }
            var hijos = new List<AutomationElement>();
            var hijo = w.GetFirstChild(e);
            while (hijo != null) { hijos.Add(hijo); hijo = w.GetNextSibling(hijo); }
            for (int i = hijos.Count - 1; i >= 0; i--) pila.Push(hijos[i]);
        }
        if (hallados.Count == 0) throw new InvalidOperationException("Nada a la vista con el nombre " + patron);
        var elegido = hallados[0];
        var dicho = elegido.Current.LocalizedControlType + " " + elegido.Current.Name + " (de " + hallados.Count + ")";
        object patronInvoke;
        if (elegido.TryGetCurrentPattern(InvokePattern.Pattern, out patronInvoke)) {
            ((InvokePattern)patronInvoke).Invoke();
            return "UIA Invoke: " + dicho;
        }
        // Sin Invoke (las entradas de un menú de Flutter, que no son botón):
        // la acción por omisión de MSAA, la que usa el lector de pantalla.
        return "MSAA accDoDefaultAction (sin Invoke en UIA): " + ActivarMsaa(hwnd, regex);
    }

    static string ActivarMsaa(IntPtr hwnd, System.Text.RegularExpressions.Regex regex) {
        var iid = new Guid("618736E0-3C3D-11CF-810C-00AA00389B71");
        IAccessible raiz;
        if (AccessibleObjectFromWindow(hwnd, 0xFFFFFFFC, ref iid, out raiz) != 0 || raiz == null)
            throw new InvalidOperationException("Sin MSAA");
        var pila = new Stack<IAccessible>();
        pila.Push(raiz);
        while (pila.Count > 0) {
            var acc = pila.Pop();
            string nombre = null;
            int bits = 0;
            try { nombre = acc.get_accName(0); var e = acc.get_accState(0); bits = e is int ? (int)e : 0; } catch { }
            bool aLaVista = (bits & 0x8000) == 0 && (bits & 0x10000) == 0;
            if (aLaVista && nombre != null && regex.IsMatch(nombre)) {
                acc.accDoDefaultAction(0);
                return Rol(acc.get_accRole(0)) + " " + nombre;
            }
            int cuantos = 0;
            try { cuantos = acc.accChildCount; } catch { }
            if (cuantos <= 0) continue;
            var hijos = new object[cuantos];
            int obtenidos;
            if (AccessibleChildren(acc, 0, cuantos, hijos, out obtenidos) != 0) continue;
            for (int i = obtenidos - 1; i >= 0; i--) {
                var hijo = hijos[i] as IAccessible;
                if (hijo != null) pila.Push(hijo);
            }
        }
        throw new InvalidOperationException("Tampoco en MSAA: " + regex);
    }
}
"@
[void][T117Arbol]::SetProcessDPIAware()

$p = Get-Process -Id $Proceso
$hwnd = $p.MainWindowHandle
if ($hwnd -eq [IntPtr]::Zero) { throw "El proceso $Proceso no tiene ventana." }

function Get-Ventana {
    $c = New-Object T117Arbol+RECT
    $v = New-Object T117Arbol+RECT
    [void][T117Arbol]::GetClientRect($hwnd, [ref]$c)
    [void][T117Arbol]::GetWindowRect($hwnd, [ref]$v)
    $dpi = [T117Arbol]::GetDpiForWindow($hwnd)
    $escala = $dpi / 96.0
    [ordered]@{
        pid = $Proceso; exe = $p.Path; dpi = $dpi
        clientePx = @($c.Right, $c.Bottom)
        clienteDp = @([math]::Round($c.Right / $escala, 1), [math]::Round($c.Bottom / $escala, 1))
        ventanaPx = @(($v.Right - $v.Left), ($v.Bottom - $v.Top))
        maximizada = [T117Arbol]::IsZoomed($hwnd)
    }
}

switch ($Accion) {
    'ancho' {
        if ([T117Arbol]::IsZoomed($hwnd)) { [void][T117Arbol]::ShowWindow($hwnd, 9); Start-Sleep -Milliseconds 400 }
        $antes = Get-Ventana
        $escala = $antes.dpi / 96.0
        $alto = if ($AltoDp -gt 0) { $AltoDp } else { $antes.clienteDp[1] }
        $dw = $antes.ventanaPx[0] - $antes.clientePx[0]
        $dh = $antes.ventanaPx[1] - $antes.clientePx[1]
        $w = [int][math]::Round($AnchoDp * $escala) + $dw
        $h = [int][math]::Round($alto * $escala) + $dh
        # SWP_NOMOVE | SWP_NOZORDER | SWP_NOACTIVATE
        if (-not [T117Arbol]::SetWindowPos($hwnd, [IntPtr]::Zero, 0, 0, $w, $h, 0x0002 -bor 0x0004 -bor 0x0010)) {
            throw 'SetWindowPos falló.'
        }
        Start-Sleep -Milliseconds 900
        Get-Ventana | ConvertTo-Json -Compress
    }
    'activar' {
        $hallado = [T117Arbol]::Activar($hwnd, $Nombre)
        Start-Sleep -Milliseconds 900
        "activado: $hallado"
    }
    'arbol' {
        if (-not $Salida) { throw 'Falta -Salida (sin extensión).' }
        # La primera consulta enciende la semántica de Flutter; la segunda la lee entera.
        [void][T117Arbol]::Uia($hwnd, 50)
        Start-Sleep -Milliseconds 1500
        $uia = [T117Arbol]::Uia($hwnd, $MaxNodos)
        $msaa = [T117Arbol]::Msaa($hwnd, $MaxNodos)
        $carpeta = Split-Path -Parent $Salida
        if ($carpeta) { New-Item -ItemType Directory -Force -Path $carpeta | Out-Null }
        [ordered]@{ ventana = Get-Ventana; momento = (Get-Date).ToString('o'); uia = $uia; msaa = $msaa } |
            ConvertTo-Json -Depth 5 | Out-File -Encoding utf8 "$Salida.json"
        $lineas = New-Object System.Collections.Generic.List[string]
        foreach ($arbol in @(@('UIA (vista de control): tipo, nombre [ayuda]', $uia), @('MSAA: rol, nombre clásico', $msaa))) {
            $lineas.Add("== $($arbol[0])")
            foreach ($n in $arbol[1]) {
                $ayuda = if ($n.Ayuda) { " [ayuda: $($n.Ayuda)]" } else { '' }
                $fuera = if ($n.FueraDeVista) { ' (fuera de vista)' } else { '' }
                $lineas.Add(('  ' * $n.Nivel) + "$($n.Rol) $($n.Nombre)$ayuda$fuera")
            }
        }
        $lineas | Out-File -Encoding utf8 "$Salida.txt"
        "uia $($uia.Count) nodos, msaa $($msaa.Count) nodos -> $Salida.txt"
    }
}
