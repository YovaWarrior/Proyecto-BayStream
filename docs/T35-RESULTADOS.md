# T-35 · Motor local elegido por medición

Fecha: 19 de septiembre de 2026, Guatemala. Requerimiento: RF-031+.

**Decisión: `hive_ce: 2.20.0`, con un presupuesto de cinco viajes recientes**
confirmado por Carlos. La retención se implementará en las tareas siguientes;
T-35 verifica únicamente el motor. No se implementaron T-36 ni T-37.

## Medición

Se ejecutó el parser actual sobre `CORPUS_A01.edi` y se reprodujo la confirmación
de la geometría propuesta, sin editar sus parámetros, con el puerto declarado
`GTPBR`. Se llamó a `ExportService.bytesFor(voyage, VoyageExportFormat.json)`;
se escribieron sus bytes en disco y se releyeron para comprobar su igualdad.
No se creó otro serializador ni se compactó el JSON. El diálogo de guardado no
se automatizó: se midieron exactamente los bytes que recibe ese diálogo.

| Magnitud | Resultado |
|---|---:|
| Archivo EDI de entrada | 164.310 bytes |
| Contenedores | 977 |
| Bahías después de confirmar geometría | 34 |
| JSON UTF-8 exportado | **1.788.129 bytes** |
| JSON en MiB (1 MiB = 1.048.576 bytes) | **1,705 MiB** |
| Cinco exportaciones | **8.940.645 bytes / 8,527 MiB** |
| Referencia Web de la ficha, usando 5 MiB | 5.242.880 bytes |

El total supera incluso la interpretación de 5 MiB, más generosa que 5 MB
decimales. Por tanto, no cabe holgadamente en `localStorage`:
**se descarta `shared_preferences` y se selecciona `hive_ce`**, siguiendo T-35.
El tamaño UTF-8 del archivo no pretende medir la representación interna del
navegador ni el espacio de claves, perfiles o metadatos: la decisión ya se
resuelve con los cinco archivos, antes de añadir ese costo.

Como control, el viaje inmediatamente salido del parser, antes de confirmar
geometría, produjo 1.786.603 bytes. Tampoco cambia la elección.

Archivo medido original: `build/t35/CORPUS_A01.json`.

- SHA-256 EDI: `3D793F8056A3D8B96140E681B6C468EA49922658AFDEA4F7416A169A60A8CE5B`.
- SHA-256 JSON original: `8ABA324655554FC27396EB2F00A8634544AA5DC11A451A762D539776ACCBEE70`.

El parser genera UUID nuevos en cada ejecución: otra exportación puede tener
otro hash conservando el tamaño. La repetición con el script entregable volvió
a producir **1.788.129 bytes**.

## Verificación del motor

Entorno: Flutter 3.38.9, Dart 3.10.8. Entrada de diagnóstico independiente,
sin inicializar Firebase ni modificar `lib/main.dart`.

La prueba guardó **cinco copias del JSON real en cinco claves diferentes**;
son una carga equivalente a cinco viajes para medir capacidad, no cinco viajes
reales distintos. Esperó las escrituras y `flush`, cerró la caja, la abrió de
nuevo y comparó cada cadena completa contra el JSON original. Además, cada
lectura se deserializó y comprobó sus 977 contenedores. En una segunda ejecución
leyó los valores existentes sin reescribir los cinco viajes.

| Plataforma | Compilación del ensayo | Guardar/cerrar/leer | Segunda ejecución |
|---|---|---|---|
| Web, navegador integrado de Codex, `http://127.0.0.1:8735` | Release ✓ | 5/5 ✓ | Recarga de página, 5/5 ✓ |
| Windows | Debug ✓ | 5/5 ✓ | Proceso terminado y abierto de nuevo, 5/5 ✓ |
| Android, POCO X3 NFC, Android 12 | Debug ✓ | 5/5 ✓ | `force-stop` y apertura, 5/5 ✓ |

En los tres clientes aparecieron ambos resultados:

```text
T35_ESCRITURA_LECTURA_OK: 5 viajes, 977 contenedores por viaje, 8940645 bytes; igualdad completa
T35_REINICIO_OK: 5 viajes, 977 contenedores por viaje, 8940645 bytes; igualdad completa
```

Evidencia local: `build/t35/build-web.log`, `build-windows.log`,
`build-android.log`, `windows-first.log`, `windows-restart.log`,
`android-first.log` y `android-restart.log`. Web mostró los resultados tanto
en la pantalla como en la consola del navegador. Caja física Windows:
8.940.783 bytes, incluidos sus registros auxiliares.

La carga está embebida en el diagnóstico: no hay lectura de viajes desde la
nube. No se hizo una prueba de desconexión de red. La prueba desde el dominio
publicado queda en T-48; IndexedDB tiene cuotas y políticas de conservación del
navegador, no capacidad infinita.

## Validaciones y alcance

- `flutter test --no-pub`: **138/138**, sin editar ni omitir pruebas existentes.
- La entrada normal `lib/main.dart` también compiló en Web release, Windows
  debug y APK debug. Registros: `build/t35/app-web.log`, `app-windows.log` y
  `app-android.log`. Los artefactos habituales quedaron con la app normal.
- `flutter analyze --no-pub`: **49 avisos preexistentes, cero nuevos**.
  El primer informe contó 50 porque incluía un `print` del diagnóstico temporal;
  se corrigió el diagnóstico y se compararon los 49 avisos del producto.
- `pubspec.yaml`: única dependencia directa nueva, `hive_ce: 2.20.0` exacta.
- `pubspec.lock`: añade `hive_ce 2.20.0` e `isolate_channel 0.6.1` transitiva;
  no se actualizaron las dependencias anteriores.
- Sin `hive_ce_flutter`, generador ni anotaciones del motor en dominio.
- Sin cambios en `lib/`, las pantallas H5, Firebase o los archivos de pruebas.
  El contrato y la fuente local de producción corresponden a T-36.
- Se repuso en el POCO el APK anterior al ensayo, sin desinstalar ni borrar
  datos. SHA-256 del APK original y del reinstalado, iguales:
  `0BE0847F07A6C0D3445EE3B9A7E1F0386DB1E23509FBC9B3E9196EB55820F48B`.

## Hallazgo que debe atender T-36

Una comprobación adicional de igualdad de entidad completa falló:
`VesselVoyage.fromJson` no reconstruye `slotsOccupiedByNeighbors`. `Bay.toJson`
omite deliberadamente ese conjunto porque es derivado, pero `fromJson` no vuelve
a calcularlo. El motor sí conserva íntegro el JSON y los 977 contenedores.

La comprobación del diagnóstico se precisó explícitamente: exige igualdad
completa del JSON, igualdad de los contenedores y, después de aplicar
`withGeometry` con la misma geometría y puerto, igualdad de la entidad completa.
Las tres aserciones pasaron. **T-36 debe reconstruir este estado derivado al
recuperar viajes**; no basta con comprobar el conteo. No se corrigió el dominio
dentro de T-35 ni se cambió ninguna aserción preexistente.

## Repetir la medición y el ensayo

Desde la raíz, con el corpus descargado localmente:

```powershell
./tool/prepare_t35.ps1 -CorpusPath 'RUTA_COMPLETA_A_CORPUS_A01.edi'
```

El script genera el JSON, su hash, un diagnóstico Flutter y su carga en
`build/t35-replay/`. Todo queda bajo `build/`, ignorado por `.gitignore`.
No instala nada ni modifica código de producción. Por defecto usa `C:/flutter`;
se puede indicar otro SDK mediante `-FlutterSdk`.

Primero Web:

```powershell
flutter build web --no-pub --target build/t35-replay/storage_probe.dart --output build/t35-replay/web
python -m http.server 8735 --bind 127.0.0.1 --directory build/t35-replay/web
```

Abrir `http://127.0.0.1:8735`, comprobar `T35_ESCRITURA_LECTURA_OK`, recargar y
comprobar `T35_REINICIO_OK`. Usar el mismo origen y los mismos archivos de carga
entre ambas ejecuciones. Detener el servidor anterior si el puerto está ocupado.

Windows:

```powershell
flutter run -d windows --no-pub --target build/t35-replay/storage_probe.dart --dart-define=T35_PATH=C:/Proyectos/proyecto-baystream/build/t35-replay/windows-store
```

Android (identificador del POCO de esta verificación):

```powershell
flutter run -d 5d0750b5 --no-pub --target build/t35-replay/storage_probe.dart --dart-define=T35_PATH=/data/user/0/com.example.baystream/files/t35-probe
```

En ambos casos, comprobar el primer resultado, terminar el proceso y ejecutar
de nuevo para comprobar el segundo. El diagnóstico Android usa el identificador
de BayStream: conservar el APK anterior y reponerlo al terminar, sin desinstalar
ni borrar sus datos. Las cajas tienen un nombre propio por hash del JSON; no
leen ni escriben colecciones de producción. Un nuevo exportado genera otra caja.

Los binarios de diagnóstico se generan en rutas habituales de Flutter. Volver
a compilar la entrada normal después del ensayo para que esas rutas contengan
la aplicación normal antes de cualquier entrega.

## Fuentes de la decisión

- Ficha T-35 y restricciones de `SPRINT-2.md`.
- [Hive CE 2.20.0](https://pub.dev/packages/hive_ce/versions/2.20.0).
- [Shared preferences](https://pub.dev/packages/shared_preferences).
- [Cuotas y conservación de almacenamiento Web](https://developer.mozilla.org/en-US/docs/Web/API/Storage_API/Storage_quotas_and_eviction_criteria).

La selección se basa en los bytes medidos, no en el benchmark del proveedor.
