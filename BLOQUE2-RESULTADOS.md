# Sprint 2 · Bloque 2 · T-25 → T-24 → T-36

Implementación y pruebas iniciales: 19-sep-2026. Verificación de clientes y cierre:
23-sep-2026, después de la pausa de sesión. Git pendiente de ejecución por Carlos.

## Resultado

- **T-25:** clave de perfil `imo:<valor>` → `callSign:<valor>` →
  `name:<nombre normalizado>`, con origen explícito. `Vessel.id` conserva su UUID.
  Los calificadores TDT 146 y 103 deciden el tipo; no se deduce por apariencia.
  Los seis TDT reales dan claves estables en parseos distintos.
  A05 (`callSign:ZZC5603`) y A06 (`imo:9000039`) nunca se asocian automáticamente.
- **T-24:** `VesselProfile` de dominio, Equatable, copyWith y JSON, sin Flutter
  ni Hive. Conserva identidad, nombre, geometría, límite opcional, tomas reefer,
  origen y fecha UTC. Los tres orígenes permanecen distintos al serializar.
  El límite vive una sola vez en la geometría; `null` significa no declarado.
- **T-36:** contrato de repositorio en dominio, implementación y Hive en datos.
  Dos cajas String: perfiles por clave natural y viajes por UUID. Cada registro
  incluye `schemaVersion: 1` y `data`. Ausencia de versión se interpreta como v1;
  versiones desconocidas se rechazan, sin reescribir los registros.

La consulta distingue asociación automática de candidatos homónimos. Guardar un
homónimo exige `nameMatchConfirmed`; sin confirmación devuelve
`profile_confirmation_required` y no crea ni sobrescribe el perfil. Las escrituras
de perfiles se serializan dentro del repositorio para evitar carreras entre
consultar y guardar. La confirmación conserva la clave proporcionada, sin fusionar
otros perfiles. La presentación de esa pregunta corresponde a la integración de
T-28/T-33/T-34; este bloque entrega y protege el contrato que utilizará la interfaz.

El JSON local guarda los contenedores una sola vez. Omite `bays`, `slots` y
`slotsOccupiedByNeighbors`; los reconstruye al leer. El formato histórico de
exportación/Firestore sigue disponible por defecto. `VesselVoyage.fromJson`
recalcula vecinos para ambos formatos, incluso sin geometría, y conserva los
atributos históricos de celdas cuando el documento trae bahías serializadas.
El comentario de `Bay.toJson` describe ahora ese comportamiento explícitamente.
No hay lecturas ni escrituras contra un proyecto Firestore en esta verificación:
la regresión prueba el mismo serializador utilizado por su repositorio.

## Evidencia y medición

Se leyeron los seis EDI originales desde la carpeta local del corpus anonimizado.
CORPUS_A01: **164.310 bytes**, SHA-256:
`3D793F8056A3D8B96140E681B6C468EA49922658AFDEA4F7416A169A60A8CE5B`.

La prueba aplica la propuesta de geometría y compara la entidad completa, no solo
los conteos: **977 contenedores, 34 bahías**, incluidas las siete sin carga propia
ocupadas por vecinos: **05, 13, 15, 35, 39, 43 y 45**. Sus ocupaciones sobreviven al
JSON histórico y al registro local; ninguna vuelve a 0.0.

| Representación de A01 en esta ejecución | Bytes UTF-8 |
|---|---:|
| ExportService, JSON legible | 1.786.695 |
| Documento completo, JSON compacto | 1.068.938 |
| Esquema local v1, JSON legible | 514.285 |
| Registro local v1 realmente guardado, compacto | **326.442** |
| Perfil usado en la prueba | 787 |
| Cinco registros locales de viaje | **1.632.210** |

Comparando JSON compacto con compacto, la reducción es **69,5 %**, incluyendo
la envoltura de versión. Las cifras son tamaño lógico del contenido, no tamaño
físico de Hive/IndexedDB ni una medición de cuota del navegador.

**Precisión sobre §10.3:** la estimación de tres MB deduplicados quedó por encima
de lo medido. Estos cinco registros compactos ocupan **3.264.420 bytes en UTF-16**,
por debajo de unos cinco MB, antes de sobrecostos. Por tanto, no se sostiene la
frase de que el formato nuevo necesariamente excede ese techo. La decisión
explícita de mantener Hive permanece; no se vuelve a decidir T-35 ni se alteran
dependencias. El número de T-35 (1.788.129 bytes) corresponde a su exportación
histórica; aquí se mide la representación posterior a T-51/T-25 y con el puerto
propuesto por el viaje. No se reemplaza la evidencia anterior por una estimación.

## Validaciones ejecutadas

| Verificación | Resultado |
|---|---|
| Suite completa | **169/169**, frente al piso de 139 |
| Prueba adicional manual con los seis archivos reales | **1/1** |
| Analizador | **49 incidencias**, mismas líneas de diagnóstico que antes |
| Web, IndexedDB, compilación release | Guardado/lectura y recarga correctos |
| Windows, Hive en disco, compilación debug | Guardado/lectura y nuevo proceso correctos |
| Android, POCO X3 NFC, compilación debug | Guardado/lectura y force-stop/nuevo proceso correctos |

Las treinta pruebas nuevas son: identidad 11, perfil 5, deserialización 4 y
repositorio local 10. Las cuatro de regresión de deserialización se ejecutaron
antes de corregir el defecto y fallaron; después pasaron. Ninguna prueba previa
se editó, eliminó o marcó skip. Se compararon hashes de los archivos preexistentes.

Los tres clientes ejecutaron un punto de entrada diagnóstico aislado, con cinco
copias de A01 y un perfil. La prueba usa el repositorio nuevo, cierra/reabre las
cajas, verifica igualdad de cada viaje completo y luego repite desde un nuevo
proceso o una recarga. Las marcas obtenidas fueron `BLOQUE2_GUARDAR_LEER_OK` y
`BLOQUE2_REINICIO_OK`. El diagnóstico no inicializa Firebase ni obtiene datos de
la nube; trabaja con el corpus incorporado y almacenamiento local. No se afirma
haber desconectado físicamente las redes del equipo o del teléfono.

El APK anterior del POCO se respaldó y repuso sin desinstalar ni borrar datos.
SHA-256 del APK instalado antes y después:
`0BE0847F07A6C0D3445EE3B9A7E1F0386DB1E23509FBC9B3E9196EB55820F48B`.

La selección de directorio privado y la instancia compartida del repositorio se
inyectarán al integrar los providers en las tareas siguientes. Este bloque no
conecta todavía la pantalla de viajes recientes (T-37).

## Reproducción y evidencia local

```powershell
flutter test --reporter expanded
flutter analyze
flutter test tool/block2_corpus_test.dart --reporter expanded --dart-define="BAYSTREAM_CORPUS_DIRECTORY=C:\Users\Giova\OneDrive\Documentos\OneDrive\Desktop\Archivos .EDI\Anonimizados\files"
```

`tool/block2_corpus_test.dart` falla si no se indica la carpeta; no sustituye el
corpus real por un fixture ni se incluye en el conteo de 169 de la suite normal.

Evidencia conservada en `build/block2/`, ignorada por Git: `tests.log`,
`corpus-test.log`, `analyze-before.log`, `analyze-after.log`,
`t36-regression-before.log`, `t36-regression-after.log`, `windows-first.log`,
`windows-restart.log`, `android-first.log`, `android-restart.log`, compilaciones
`build-web.log`, `build-windows.log`, `build-android.log`, y la medición/JSON en
`corpus/`. Los diagnósticos usados son `storage_probe.dart` y `payload.dart`.
La evidencia Web se observó en consola y pantalla del navegador local
`http://127.0.0.1:8736/`: guardado a 08:25:17 UTC y recarga a 08:25:36 UTC,
23-sep-2026. No se versionan APK, corpus ni salidas de build.

## Archivos de esta entrega

RF-036 (T-25 y T-24):

1. `lib/features/vessel/domain/entities/vessel.dart`
2. `lib/features/vessel/data/services/baplie_parser_service.dart`
3. `lib/features/vessel/domain/entities/vessel_profile.dart`
4. `lib/features/vessel/domain/entities/entities.dart`
5. `test/vessel_identity_test.dart`
6. `test/vessel_profile_test.dart`

RF-031+ (T-36 y evidencia del bloque):

7. `lib/features/vessel/domain/entities/vessel_voyage.dart`
8. `lib/features/vessel/domain/entities/bay.dart`
9. `lib/features/vessel/domain/repositories/local_vessel_repository.dart`
10. `lib/features/vessel/data/datasources/local_vessel_codec.dart`
11. `lib/features/vessel/data/datasources/hive_vessel_data_source.dart`
12. `lib/features/vessel/data/repositories/local_vessel_repository_impl.dart`
13. `test/vessel_voyage_persistence_test.dart`
14. `test/local_vessel_repository_test.dart`
15. `tool/block2_corpus_test.dart`
16. `BLOQUE2-RESULTADOS.md`

**pubspec.yaml y pubspec.lock no cambian en este bloque.** Tampoco se modificaron
main.dart, las pantallas H5 congeladas, credenciales, documentación bajo docs/ ni
la configuración personal. No se ejecutó Git ni se publicaron cambios.
