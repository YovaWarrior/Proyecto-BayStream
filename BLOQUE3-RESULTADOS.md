# Sprint 2 · Bloque 3 · T-26 → T-27 → T-28

23 de septiembre de 2026. Implementado y verificado; Git lo ejecuta Carlos.

## Cambios y límites del bloque

**T-26.** `deckTierFloor` es un campo de instancia y `isDeckTier` consulta ese
campo. El perfil lo conserva una sola vez dentro de `VesselProfile.geometry` y
lo expone mediante un getter. Los predeterminados se aplican al construir y
deserializar, nunca en consumidores. Se conserva 80 para geometrías anteriores.

Recorrido de llamadas: `covers` usa la propia instancia; `proposeFrom` recibe los
parámetros del perfil; los dos getters de peso por pila de `Bay` usan su geometría
inyectada; el PDF recibe una geometría obligatoria en `generate` y la propaga hasta
la clasificación. `ContainerSlot` no tiene otra clasificación de zona.

El cambio mínimo del PDF sigue §10.9: firma y clasificación por instancia. No se
modificaron `_orderedRows`, `_tierRange` ni la generación de su rejilla observada.
**T-52 queda pendiente**, incluyendo la fila 00 cuando está vacía y la concordancia
entre la rejilla del PDF y la pantalla. Este bloque no declara corregido RF-025.

**T-27.** `firstHoldTier` y `firstDeckTier` son parámetros del perfil mediante su
geometría, con 02 y 82 por omisión. Se incluyen en igualdad, copia y JSON. La
propuesta conserva las anclas declaradas y desciende por pasos de dos cuando hay
carga debajo; no cambia el parámetro declarado por haber observado un nivel menor.
Se conserva el comentario con la evidencia del corpus para el valor 82.

Son valores ISO convertidos en parámetros por buque, **no supuestos provisionales**.
La pantalla actual conserva estos parámetros al editar y usa sus anclas en los
menús de niveles; la interfaz dedicada a editar campos del perfil corresponde a
T-32. No se adelanta el selector de plantillas T-33.

**T-28.** `VesselProfile.proposeFrom` siembra una propuesta con origen explícito.
El notifier consulta el repositorio local antes de publicar:

1. Identificador coincidente y perfil que cubre la carga: publica directamente
   usando la geometría guardada, sin volver a proponerla ni modificarla.
2. Sin perfil: presenta parámetros, guarda el perfil declarado al confirmar y
   después publica. Si guardar falla, conserva el pendiente y muestra el error.
3. Coincidencia solo por nombre: pregunta qué perfil corresponde, permite declarar
   otro buque o cancelar. Dos buques indistinguibles solo por nombre no pueden
   sobrescribirse como si fueran distintos: se pide un identificador en el archivo.
4. Carga fuera del perfil: muestra las coordenadas y permite cancelar o revisar
   una ampliación. El borrador se prepara únicamente después de esa elección;
   el perfil se escribe solo al confirmar. Cancelar conserva el viaje anterior
   y el perfil almacenado.

Elegir un homónimo existente no crea un perfil duplicado ni registra un alias
automático: una coincidencia futura solo por nombre vuelve a requerir confirmación.
El puerto sigue siendo dato de la escala; no se hereda del perfil de otro viaje.

`parseBaplieContent` ahora usa el mismo flujo que el selector de archivos. Antes
permitía publicar directamente un viaje parseado sin geometría. `_publish` es el
único punto que asigna un viaje publicado y siempre llama a `withGeometry`, tanto
para perfiles recuperados como para confirmaciones nuevas.

## Almacén y arquitectura

Riverpod mantiene una instancia compartida del contrato local. La apertura y la
resolución de directorios quedan en datos:

- Web: IndexedDB del origen.
- Windows: `%LOCALAPPDATA%/BayStream/vessel_store`.
- Android: `filesDir/vessel_store`, obtenido mediante un canal nativo mínimo en
  `MainActivity.kt`; no se codifica un identificador de paquete ni una ruta privada.

No se agregaron dependencias. **pubspec.yaml y pubspec.lock no cambiaron.** Dominio
sigue sin imports de Flutter ni Hive. Los campos nuevos son aditivos y los registros
v1 anteriores reciben 80/02/82 al deserializar; no se requiere reescribirlos.

## Pruebas y evidencia

| Verificación | Resultado |
|---|---|
| Suite completa | **184/184**, desde 169 |
| T-26, geometría + frontera + PDF | 47/47 |
| T-27, geometría + parámetros + pantalla + perfil | 71/71 |
| Corpus real adicional | **2/2**: A01 y PRUEBA_NIVEL_80 |
| Analyze final | **49 incidencias**, sin diagnósticos nuevos |
| Web release, diagnóstico de flujo | Guardado/lectura y recarga correctos |
| Windows debug, diagnóstico de flujo | Guardado/lectura y proceso nuevo correctos |
| POCO X3 NFC debug, diagnóstico de flujo | Guardado/lectura y force-stop/reinicio correctos |
| Aplicación completa con main.dart original | Compila Web release, Windows debug y Android debug |

Las quince pruebas nuevas son cuatro de parámetros declarados, ocho de carga de
perfiles con Hive real y tres de decisiones visibles en la pantalla. Cubren carga
repetida, frontera distinta, descenso bajo el ancla, compatibilidad histórica,
homónimos, cancelación, ampliación confirmada y fallo de escritura.

**Las 42 pruebas de `vessel_geometry_test.dart` siguen presentes y conservan todas
sus aserciones.** Se cambió únicamente el helper `bahiaCon` para inyectar geometría
en las cuatro pruebas C-7:

- «la pila es la columna vertical, no la suma horizontal del nivel»;
- «cubierta y bodega son pilas separadas, no se suman»;
- «una fila sin carga en una zona no aparece en esa zona»;
- «un contenedor sin peso no rompe la suma».

Fuera de esas 42, se adaptaron dos pruebas existentes por el contrato nuevo:

- `pdf_report_service_test.dart`, «genera un documento PDF con contenido»: pasa
  geometría explícita a la firma obligatoria; conserva las dos aserciones.
- `vessel_geometry_page_test.dart`, «confirmGeometry propaga la geometría a todas
  las bahías»: espera el guardado asíncrono en Hive y usa el viaje pendiente real.
  Las comprobaciones previas de geometría/ocupación nulas se hacen sobre ese
  pendiente, añadiendo que no hay viaje publicado. Se conservan las tres
  comprobaciones posteriores de geometría y ocupación. Se retiró el notifier de
  prueba que fabricaba un viaje publicado sin geometría.

No se eliminó ninguna prueba ni se agregó `skip`.

**A01 real:** 977 contenedores y 34 bahías. Las siete bahías sin carga propia con
vecinos mantienen ocupación positiva. Se guardó un perfil de prueba deliberadamente
distinto del mínimo observado (siete filas a estribor, nivel 92 adicional, anclas
04/84) para detectar cualquier recálculo silencioso. Al reabrir se conserva intacto.
La variante de prueba con posición **0181996** exige ampliación y no se publica;
cancelar deja intactos el viaje y el perfil previos. Esta variante no modifica el EDI
original ni declara esos parámetros como reales del buque.

SHA-256 de CORPUS_A01:
`3D793F8056A3D8B96140E681B6C468EA49922658AFDEA4F7416A169A60A8CE5B`.

**PRUEBA_NIVEL_80.edi real:** con ancla declarada 84, el nivel 80 sigue clasificado
en cubierta, la corrida desciende y `coversAll` devuelve true.
SHA-256: `254DB9FD0B9A2AE41E77C6261D53B673F51A982A93FB5856F9275BD44B4E072A`.

Los diagnósticos por plataforma ejecutan el notifier, el parser real y la fábrica
del repositorio con un namespace de prueba. Verifican la geometría recuperada,
los conteos y la cancelación de ampliación. Los diálogos se verifican aparte con
widget tests. El diagnóstico usa contenido local y no inicializa Firebase; no se
afirma haber desconectado físicamente la red del equipo o del teléfono.

El APK original del POCO se respaldó y repuso, sin desinstalar ni borrar datos.
Su SHA-256 antes/después coincide:
`0BE0847F07A6C0D3445EE3B9A7E1F0386DB1E23509FBC9B3E9196EB55820F48B`.

## Reproducción

```powershell
flutter test --reporter expanded
flutter analyze
flutter test tool/block3_corpus_test.dart --reporter expanded --dart-define="BAYSTREAM_CORPUS_DIRECTORY=C:\Users\Giova\OneDrive\Documentos\OneDrive\Desktop\Archivos .EDI\Anonimizados\files"

.\tool\prepare_block3_probe.ps1 -CorpusPath "C:\Users\Giova\OneDrive\Documentos\OneDrive\Desktop\Archivos .EDI\Anonimizados\files\CORPUS_A01.edi"
flutter build web --release --target build/block3/profile_probe.dart --output build/block3/web
flutter build windows --debug --target build/block3/profile_probe.dart
flutter build apk --debug --target build/block3/profile_probe.dart
```

El script genera el diagnóstico, no instala aplicaciones. `RunTag` permite elegir
otro namespace de prueba; debe conservarse entre la primera ejecución y el reinicio.
Las marcas correctas son `BLOQUE3_GUARDAR_LEER_OK` y `BLOQUE3_REINICIO_OK`.

Logs locales en `build/block3/`: `tests.log`, `t26-tests.log`, `t27-tests.log`,
`t28-tests.log`, `ui-tests.log`, `corpus-test.log`, `analyze-before.log`,
`analyze-after.log`, `windows-first.log`, `windows-restart.log`, `android-first.log`,
`android-restart.log` y los seis `build-*.log` de diagnóstico/app normal.
La prueba Web se observó en consola y pantalla de `http://127.0.0.1:8737/`:
20:05:57 UTC (guardado) y 20:06:25 UTC (recarga), 23-sep-2026.
Estos outputs y los APK quedan ignorados por Git.

## Archivos de la entrega

1. `lib/features/vessel/domain/entities/vessel_geometry.dart`
2. `lib/features/vessel/domain/entities/vessel_profile.dart`
3. `lib/features/vessel/domain/entities/bay.dart`
4. `lib/features/vessel/data/services/pdf_report_service.dart`
5. `lib/features/vessel/data/datasources/local_store_directory.dart`
6. `lib/features/vessel/data/datasources/local_store_directory_io.dart`
7. `lib/features/vessel/data/datasources/local_store_directory_web.dart`
8. `lib/features/vessel/data/repositories/local_vessel_repository_factory.dart`
9. `lib/features/vessel/presentation/providers/vessel_providers.dart`
10. `lib/features/vessel/presentation/pages/vessel_geometry_page.dart`
11. `lib/features/vessel/presentation/pages/vessel_overview_page.dart`
12. `android/app/src/main/kotlin/com/example/baystream/MainActivity.kt`
13. `test/vessel_geometry_test.dart`
14. `test/pdf_report_service_test.dart`
15. `test/vessel_geometry_page_test.dart`
16. `test/declared_geometry_test.dart`
17. `test/profile_loading_test.dart`
18. `test/profile_loading_page_test.dart`
19. `test/support/local_profile_test_support.dart`
20. `tool/block3_corpus_test.dart`
21. `tool/prepare_block3_probe.ps1`
22. `BLOQUE3-RESULTADOS.md`

No se modificaron main.dart, pantallas H5 congeladas, credenciales, docs/ ni la
configuración personal. No se ejecutó Git ni se publicaron cambios.
