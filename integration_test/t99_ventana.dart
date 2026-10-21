// T-99 · Maximiza la ventana del propio proceso en Windows (decisión 1.4:
// ventana maximizada en la laptop de 1920×1080). Solo dart:ffi del SDK: busca
// las ventanas visibles cuyo dueño es este proceso, nunca las de otra app.
import 'dart:ffi';
import 'dart:io';

typedef _EnumNativo = Int32 Function(IntPtr ventana, IntPtr dato);
typedef _EnumWindowsNativo = Int32 Function(Pointer<NativeFunction<_EnumNativo>>, IntPtr);
typedef _EnumWindowsDart = int Function(Pointer<NativeFunction<_EnumNativo>>, int);

final _propias = <int>[];
int _proceso = 0;
final DynamicLibrary _user32 = DynamicLibrary.open('user32.dll');
final DynamicLibrary _kernel32 = DynamicLibrary.open('kernel32.dll');

final _getWindowThreadProcessId = _user32.lookupFunction<
    Uint32 Function(IntPtr, Pointer<Uint32>), int Function(int, Pointer<Uint32>)>(
  'GetWindowThreadProcessId',
);
final _isWindowVisible =
    _user32.lookupFunction<Int32 Function(IntPtr), int Function(int)>('IsWindowVisible');
final _localAlloc = _kernel32.lookupFunction<Pointer<Uint32> Function(Uint32, IntPtr),
    Pointer<Uint32> Function(int, int)>('LocalAlloc');
final _localFree =
    _kernel32.lookupFunction<IntPtr Function(Pointer<Uint32>), int Function(Pointer<Uint32>)>(
        'LocalFree');

int _alEnumerar(int ventana, int dato) {
  final pid = _localAlloc(0x40, 4);
  _getWindowThreadProcessId(ventana, pid);
  if (pid.value == _proceso && _isWindowVisible(ventana) != 0) _propias.add(ventana);
  _localFree(pid);
  return 1;
}

/// Maximiza las ventanas visibles de este proceso. Devuelve cuántas tocó;
/// fuera de Windows no hace nada y devuelve 0.
int maximizarVentanaPropia() {
  if (!Platform.isWindows) return 0;
  final showWindow =
      _user32.lookupFunction<Int32 Function(IntPtr, Int32), int Function(int, int)>('ShowWindow');
  final propias = _ventanasPropias();
  for (final v in propias) {
    showWindow(v, 3); // SW_MAXIMIZE
  }
  return propias.length;
}

/// Fija las ventanas visibles de este proceso a [ancho]×[alto] píxeles
/// físicos en la esquina superior izquierda, sin maximizar (10.86). Devuelve
/// cuántas tocó; fuera de Windows no hace nada y devuelve 0.
int fijarVentanaPropia(int ancho, int alto) {
  if (!Platform.isWindows) return 0;
  final setWindowPos = _user32.lookupFunction<
      Int32 Function(IntPtr, IntPtr, Int32, Int32, Int32, Int32, Uint32),
      int Function(int, int, int, int, int, int, int)>('SetWindowPos');
  final propias = _ventanasPropias();
  for (final v in propias) {
    setWindowPos(v, 0, 0, 0, ancho, alto, 0x0004 | 0x0010); // SWP_NOZORDER | SWP_NOACTIVATE
  }
  return propias.length;
}

/// Si la ventana visible de este proceso quedó maximizada (IsZoomed), para
/// anotarlo; `null` fuera de Windows o sin ventana.
bool? ventanaPropiaMaximizada() {
  if (!Platform.isWindows) return null;
  final propias = _ventanasPropias();
  if (propias.isEmpty) return null;
  final isZoomed =
      _user32.lookupFunction<Int32 Function(IntPtr), int Function(int)>('IsZoomed');
  return propias.every((v) => isZoomed(v) != 0);
}

List<int> _ventanasPropias() {
  _proceso = _kernel32
      .lookupFunction<Uint32 Function(), int Function()>('GetCurrentProcessId')();
  _propias.clear();
  final enumWindows =
      _user32.lookupFunction<_EnumWindowsNativo, _EnumWindowsDart>('EnumWindows');
  enumWindows(Pointer.fromFunction<_EnumNativo>(_alEnumerar, 0), 0);
  return List.of(_propias);
}
