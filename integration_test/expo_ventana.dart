// T-126 · Fija el tamaño de la ventana de Windows antes del primer cuadro.
//
// Cambiar la ventana ya visible (integration_test/t99_ventana.dart) hace que
// Flutter la dibuje corrida y aplastada, en la pantalla y no solo en la
// captura (10.97 de SPRINT-3.md; aquí se vio a 1366 × 768 y a 1536 × 864).
// Antes del primer cuadro la ventana del runner todavía está oculta: el
// runner la muestra con el primer cuadro (windows/runner/flutter_window.cpp).
// Se cambia ahí y el primer cuadro ya sale del tamaño nuevo. Solo dart:ffi
// del SDK, y solo la ventana del runner de este proceso.
import 'dart:ffi';
import 'dart:io';

typedef _EnumNativo = Int32 Function(IntPtr ventana, IntPtr dato);
typedef _EnumWindowsNativo = Int32 Function(
    Pointer<NativeFunction<_EnumNativo>>, IntPtr);
typedef _EnumWindowsDart = int Function(
    Pointer<NativeFunction<_EnumNativo>>, int);

final DynamicLibrary _user32 = DynamicLibrary.open('user32.dll');
final DynamicLibrary _kernel32 = DynamicLibrary.open('kernel32.dll');

final _getWindowThreadProcessId = _user32.lookupFunction<
    Uint32 Function(IntPtr, Pointer<Uint32>),
    int Function(int, Pointer<Uint32>)>('GetWindowThreadProcessId');
final _getClassName = _user32.lookupFunction<
    Int32 Function(IntPtr, Pointer<Uint16>, Int32),
    int Function(int, Pointer<Uint16>, int)>('GetClassNameW');
final _getWindowRect = _user32.lookupFunction<
    Int32 Function(IntPtr, Pointer<Int32>),
    int Function(int, Pointer<Int32>)>('GetWindowRect');
final _getClientRect = _user32.lookupFunction<
    Int32 Function(IntPtr, Pointer<Int32>),
    int Function(int, Pointer<Int32>)>('GetClientRect');
final _getDpiForWindow =
    _user32.lookupFunction<Uint32 Function(IntPtr), int Function(int)>(
        'GetDpiForWindow');
final _setWindowPos = _user32.lookupFunction<
    Int32 Function(IntPtr, IntPtr, Int32, Int32, Int32, Int32, Uint32),
    int Function(int, int, int, int, int, int, int)>('SetWindowPos');
final _localAlloc = _kernel32.lookupFunction<
    Pointer<Void> Function(Uint32, IntPtr),
    Pointer<Void> Function(int, int)>('LocalAlloc');
final _localFree = _kernel32.lookupFunction<IntPtr Function(Pointer<Void>),
    int Function(Pointer<Void>)>('LocalFree');

const _claseDelRunner = 'FLUTTER_RUNNER_WIN32_WINDOW';
final _delRunner = <int>[];
int _proceso = 0;

int _alEnumerar(int ventana, int dato) {
  final pid = _localAlloc(0x40, 4).cast<Uint32>();
  final nombre = _localAlloc(0x40, 512).cast<Uint16>();
  _getWindowThreadProcessId(ventana, pid);
  final largo = _getClassName(ventana, nombre, 256);
  if (pid.value == _proceso &&
      String.fromCharCodes(nombre.asTypedList(largo)) == _claseDelRunner) {
    _delRunner.add(ventana);
  }
  _localFree(nombre.cast());
  _localFree(pid.cast());
  return 1;
}

/// Deja el área de la app de la ventana del runner en [ancho] × [alto] puntos
/// lógicos (los multiplica por la escala de la pantalla), sin moverla.
/// Devuelve el tamaño del área en píxeles físicos, o null fuera de Windows o
/// sin la ventana del runner.
({int ancho, int alto})? fijarVentanaAntesDelPrimerCuadro(int ancho, int alto) {
  if (!Platform.isWindows) return null;
  _proceso = _kernel32.lookupFunction<Uint32 Function(), int Function()>(
      'GetCurrentProcessId')();
  _delRunner.clear();
  _user32.lookupFunction<_EnumWindowsNativo, _EnumWindowsDart>('EnumWindows')(
      Pointer.fromFunction<_EnumNativo>(_alEnumerar, 0), 0);
  if (_delRunner.isEmpty) return null;
  final ventana = _delRunner.first;
  final escala = _getDpiForWindow(ventana) / 96;
  final rect = _localAlloc(0x40, 32).cast<Int32>();
  _getWindowRect(ventana, rect);
  _getClientRect(ventana, rect + 4);
  final marcoAncho = (rect[2] - rect[0]) - (rect[6] - rect[4]);
  final marcoAlto = (rect[3] - rect[1]) - (rect[7] - rect[5]);
  _localFree(rect.cast());
  final fisico =
      (ancho: (ancho * escala).round(), alto: (alto * escala).round());
  // SWP_NOMOVE | SWP_NOZORDER | SWP_NOACTIVATE
  _setWindowPos(ventana, 0, 0, 0, fisico.ancho + marcoAncho,
      fisico.alto + marcoAlto, 0x0002 | 0x0004 | 0x0010);
  return fisico;
}
