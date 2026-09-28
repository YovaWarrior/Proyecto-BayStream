# Sprint 2 · Bloque 4 · T-29 → T-30 → T-31

25-sep-2026. RF-036. Implementación posterior a T-52; Git lo ejecuta Carlos.

## Implementación y procedencia

**T-29 ya tenía implementación de producción**: T-24 conserva el límite una
sola vez en `VesselProfile.geometry`, lo expone mediante getter/copyWith y
T-28 guarda y recupera esa geometría por buque. No se duplicó el campo ni se
retiró una constante inexistente. Se agregaron pruebas con 75 000 kg y null:
cierre de viaje, cierre de Hive, reapertura y carga del mismo buque sin volver
a preguntar; el límite llega al viaje y a cada bahía. Retirar explícitamente
un límite anterior conserva null al reabrir.

La única comparación de peso para alerta está en `BayPlanView`: exige límite
no nulo. Sus pruebas C-7 verifican ausencia de alerta con null y contraste con
una pila que sí supera un valor declarado. Estadísticas, perfil longitudinal
y PDF muestran pesos, sin inventar límites ni alertas adicionales. RF-027 y
T-38 no se adelantaron.

**T-30 ya tenía Set y serialización básica**: se conserva `Set<String>`
inmutable con códigos BBBRRTT, consulta `contains` O(1) promedio y JSON como
lista ordenada de cadenas. No se guardan objetos por coordenada. Se añadieron
pruebas de representación, duplicados, igualdad y persistencia. Una toma
continúa en el perfil cuando el siguiente viaje lleva carga seca allí.

**T-31**: `VesselProfile.proposeFrom` ahora siembra exclusivamente las
posiciones de contenedores con `isReefer`, sea por ISO o TMP. El parser ya
reconocía ambas señales y no necesitó cambios. No agrega posiciones secas,
vecinas de un 40 pies ni reefers sin posición. Un perfil recuperado no se
recalcula ni amplía automáticamente por la carga de otro viaje.

El origen general cambia a `declaredByUser` al confirmar la geometría; eso no
puede declarar también el inventario de tomas. Se agregó `reeferSlotsOrigin`,
del mismo enum `VesselProfileOrigin`, independiente y persistido. Confirmar,
copiar y reabrir conservan `proposedFromFile` para las tomas. La pantalla
informa cantidad propuesta, cota inferior y que confirmar geometría no las
convierte en declaradas. T-39 podrá consultar ese origen sin confundirlo con
el origen de la geometría.

Compatibilidad: campo aditivo en esquema v1; si falta, las tomas se leen con
origen propuesto conservador. No se presume que alguien declaró las tomas
por haber confirmado una geometría antigua. Un origen desconocido falla
explícitamente. Sin anotaciones Hive ni imports Flutter en dominio.

## Medición con CORPUS_A01 real

Comparación independiente desde bloques LOC/EQD/TMP del archivo, además del
booleano del parser: **977 contenedores, 50 ISO reefer, 43 TMP, exactamente 50
posiciones propuestas**. Las cifras 327/238 del brief son del corpus completo.

Tamaños de JSON compacto UTF-8, fecha fija 19-sep para comparación reproducible:

| Representación | Bytes |
|---|---:|
| Lista de 50 tomas, sin clave ni envoltura | 501 |
| Entidad propuesta completa | 855 |
| Registro de perfil con envoltura/versionado Hive | **882** |
| Registro confirmado, con límite de 75 000 kg | **909** |
| Viaje A01 del mismo ensayo, registro local | 326 477 |

Los **787 bytes de T-36 ya incluían estas 50 tomas**. La diferencia actual es
95 bytes: 56 por frontera/anclas del bloque 3 y 39 por `reeferSlotsOrigin`.
No se atribuye ese crecimiento al conjunto de enchufes. El registro propuesto
es aproximadamente 0.27 % del viaje medido. Hive se cerró y reabrió de verdad;
la igualdad incluye tomas, límite y ambos orígenes.

Evidencia: `build/block4/metrics.json`, `profile.json` y logs. Reproducir:

```powershell
flutter test tool/block4_corpus_test.dart --dart-define="BAYSTREAM_CORPUS_DIRECTORY=C:\Users\Giova\OneDrive\Documentos\OneDrive\Desktop\Archivos .EDI\Anonimizados\files"
```

## Pruebas

Suite completa: **194/194**, diez nuevas sobre el piso 184. Ninguna prueba ni
aserción previa se eliminó; las 42 de geometría no se modificaron. Corpus
adicional: **1/1**. Incluye confirmación visible y origen, compatibilidad de
registros anteriores, los tres orígenes independientes, ISO sin TMP, TMP con
ISO seco, duplicados, exclusión de posiciones vecinas y reapertura del almacén.

Verificación final después de corregir los avisos de las pruebas nuevas:
**194/194**, `build/block4/tests-final.log`. Analyze: **49 incidencias**,
`build/block4/analyze-final.log`; comparación con el cierre de T-52 sin
diferencias de diagnóstico, descontando números de línea desplazados.

Compilaciones Web release, Windows debug y Android debug correctas (logs
`build-web.log`, `build-windows.log` y `build-android.log` bajo `build/block4`).
No se instaló el APK en el teléfono. No se afirma una nueva prueba física
en Android. La reapertura inicial se ejercitó en la VM de Windows.

### Pendiente Web resuelto con ejecución real (25-sep, 21:38 Guatemala)

El ejecutor `flutter test --platform chrome` sigue sin completar: inicialmente
buscaba `host.dart.js` en una ruta del equipo constructor del SDK. Inyectar el
package_config local elimina ese error, pero se detiene al cargar la suite.
No se registra ese intento como aprobado ni se modificó el SDK para hacerlo pasar.

Se preparó un lanzador de QA independiente en `build/block4_web`, ejecutado
por `flutter run -d chrome --release`, Chrome 154 headless real. Usa el parser,
repositorio local, Hive/IndexedDB, notifier Riverpod y generador PDF de producción.
No sustituye esas implementaciones por mocks; solo el puerto de entrada de
archivo recibe el corpus desde memoria. Sin Firebase ni cambios a `main.dart`.

Ejecución `block4_20260925213721`:

- **WRITE_OK**: 26-sep 03:38:08.200 UTC (25-sep 21:38:08 Guatemala).
  Dos espacios de almacenamiento nuevos: límite 75 000 kg y retirada explícita
  a null. Cierre de las cajas seguido de recarga real de la página.
- **RELOAD_READ_PDF_OK**: 03:38:10.312 UTC. Ambos perfiles se recuperan sin
  preguntar geometría; límites correctos en todas las bahías; 50 tomas exactas,
  contrastadas con LOC/EQD/TMP, con origen `proposedFromFile` y geometría declarada.
- Un segundo viaje del mismo buque, transformado a carga seca y verificado como
  tal, conserva las 50 tomas. No se confundió inventario con carga del viaje.
- PDF generado dentro de Chrome: **284 891 bytes, 62 páginas**, 977 contenedores
  y 34 bahías. Comprobación independiente de las 34 rejillas y márgenes completa;
  inspección visual de las 62 páginas y bahía 014 ampliada, sin desbordes.

Evidencia local: `build/block4_web/results.jsonl`, `run.log`, `verify.log` y
`output/pdf/T52-Chrome-A01.pdf`. Los estados se recibieron desde el navegador;
no son mensajes inferidos de la compilación. La sonda prueba las operaciones
del código de producción y la recarga; no automatiza el menú ni el diálogo de
descarga. No se afirma que pasó la suite de `flutter test` en Chrome.

Reproducción (dos terminales; primero generar la evidencia de T-52 indicada
en su informe). Cada preparación crea un namespace nuevo:

```powershell
./tool/prepare_block4_web_probe.ps1 -CorpusPath 'C:\Users\Giova\OneDrive\Documentos\OneDrive\Desktop\Archivos .EDI\Anonimizados\files\CORPUS_A01.edi'
python build/block4_web/receiver.py
# En la otra terminal:
flutter run -d chrome --release --no-pub --no-web-resources-cdn --web-port=8774 --web-browser-flag=--headless -t build/block4_web/probe.dart
# Tras recibir RELOAD_READ_PDF_OK:
python tool/verify_block4_web.py
```

El receptor solo escucha loopback y guarda evidencia bajo `build/block4_web`.
Al terminar se cerraron la ejecución de Flutter y el receptor. No se agregó
ninguna dependencia ni se cambió código de producción en esta continuación.

## Archivos

- `lib/features/vessel/domain/entities/vessel_profile.dart`
- `lib/features/vessel/presentation/pages/vessel_geometry_page.dart`
- `lib/features/vessel/presentation/pages/vessel_overview_page.dart`
- `test/vessel_profile_test.dart`
- `test/profile_persistence_test.dart`
- `test/reefer_profile_proposal_test.dart`
- `test/profile_loading_page_test.dart`
- `tool/block4_corpus_test.dart`
- `tool/prepare_block4_web_probe.ps1`
- `tool/verify_block4_web.py`
- `docs/BLOQUE4-RESULTADOS.md`

Sin dependencias nuevas: pubspec.yaml y pubspec.lock no cambiaron. Tampoco
main.dart, Firebase, archivos congelados, otros documentos ni configuración
de Claude. Los únicos informes de esta tarea son `docs/T52-RESULTADOS.md` y
`docs/BLOQUE4-RESULTADOS.md`.

## Aclaración documental para Yov (fuera de este bloque)

SPRINT-2 §10.11 dice que la fase 0 fue el 23-sep. En esta conversación existe
ejecución el **25-sep a las 12:32:51 -06:00**, antes de publicar: listar voyages
200; GET voyages/c3-measurement-voyage 200; listar latency_test 200; GET
t45_control_acceso/sonda 403. Después, a las 12:33:57, las mismas rutas dieron
403/200/200/403 y se añadió GET voyages/otro-id, 403. Esta es la evidencia de
Codex; no se presume qué rutas o fechas usó otro colaborador. No se modificó
SPRINT-2.md ni la bitácora de H5.
