# T-57 · Mensajes de error en español

## Resultado

Los errores del flujo de buques se presentan con causa y acción sugerida. Los fallos conocidos conservan su tipo hasta la capa de presentación; las excepciones desconocidas muestran un mensaje genérico en español y su detalle técnico se envía a `debugPrint`. No se cambió el parser, los validadores, `pubspec.yaml` ni `pubspec.lock`; no se agregaron dependencias.

El mensaje obtenido para los dos archivos exigidos fue: «El archivo no trae el nombre del buque en el segmento TDT. Revisa que sea un BAPLIE completo o pide una nueva exportación.» La cadena no contiene `Bad state`, `Exception` ni `FormatException`.

## Evidencia de clientes

| Cliente | `T44_INVALID.edi` (7 bytes) | `T57_A01_SIN_NOMBRE_TDT.edi` | Observación |
|---|---|---|---|
| Windows release | Causa y acción visibles | Causa y acción visibles | Verificación visual en la aplicación; tras la última recompilación se repitió el segundo caso. |
| Chrome / Web release, origen nuevo `http://127.0.0.1:8797` | Causa y acción visibles | Causa y acción visibles | Origen distinto de 8787. Ambos se verificaron antes de la última recompilación, después del cambio de mensajes. El intento adicional con el binario final en 8798 quedó inconcluso por la automatización del selector de archivos; no se usa como evidencia de aprobación. |
| Honor X5d / Android 15, APK release | Causa y acción visibles | Causa y acción visibles | Capturas de la última compilación: `build/t57/honor-final-invalid.png` y `build/t57/honor-final-noname.png`. |

El segundo archivo se generó a partir de A01 eliminando únicamente el nombre del buque en el segmento TDT: `9000003:146:11:BUQUE ALFA` → `9000003:146:11`. Los dos insumos quedaron en `build/t57/`, que no se incluye en Git. La carga de `T44_INVALID.edi` llega al mismo fallo de TDT porque no contiene datos BAPLIE.

## Verificación automatizada y compilación

- `flutter test --reporter compact`: `+262: All tests passed!` en la última ejecución completa, después de los cambios de código y prueba de T-57. Una repetición posterior quedó sin salida por un proceso de `flutter.bat` detenido y se interrumpió; no se cuenta como pasada.
- `flutter analyze`: `No issues found! (ran in 11.1s)` en la última ejecución completa.
- `flutter build windows --release`, `flutter build web --release` y `flutter build apk --release`: completados después de las modificaciones finales. HEAD en esa compilación: `1f6d23667c265ec10e204090f00342bade656ae9`; los cambios de T-57 aún no están en commit.
- SHA-256 Windows `baystream.exe`: `691BA48778FCAE46523617D71D4A4BDCE1B33882DAECC67636C0BC097BAC0822`.
- SHA-256 Web `main.dart.js`: `50CD6971D967C30B0A35487C87160C7DAD262DFC2E98E16A67EB49DA1DBFF4B0`.
- SHA-256 Android `app-release.apk`: `4495A796FD5FE568BCC4DE14063E5166CB5A54D23B788F2860CFB93994E500D6`.

La prueba nueva comprueba los mensajes de fallos de análisis y caché, el fallo desconocido y la carga real del `VoyageNotifier`; falla si aparece alguno de los tres prefijos de excepción pedidos. Se revisaron las interpolaciones de excepciones en `lib/`: las restantes visibles están en `lib/c3_reconciliation_screen.dart`, archivo congelado fuera del alcance autorizado.

## Corrección de T-44

Se corrigió `docs/T44-RESULTADOS.md` según §10.22: el error observado en Chrome/8787 provenía de la sonda del bloque 7a (`tool/prepare_block7_probe.ps1` y `tool/block7_checks.dart:69`), no del producto. El `Bad state` de RNF-002 en el Honor sí correspondía al producto y queda cubierto por T-57.

## Archivos de código modificados

`lib/features/vessel/presentation/formatters/vessel_error_message.dart`, `lib/features/vessel/presentation/providers/vessel_providers.dart`, `lib/features/vessel/data/repositories/vessel_repository_impl.dart`, `lib/features/vessel/data/repositories/local_vessel_repository_impl.dart`, `lib/features/vessel/presentation/pages/recent_voyages_page.dart`, `lib/features/vessel/presentation/pages/vessel_overview_page.dart`, `lib/features/vessel/presentation/pages/vessel_profiles_page.dart` y `test/vessel_error_message_test.dart`. No se crearon scripts `tool/t57_*.dart`.
