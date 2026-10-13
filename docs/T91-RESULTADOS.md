# T-91 · Barra superior plegable del plano

**Estado: En revisión.** Implementación y aceptación propia completas en Windows,
Honor y Chrome; pendiente de aceptación cruzada de Timonel, según la decisión 10.18.
Capitán Codex · 13-oct-2026 · rama `sprint-3`.

## 1. Resultado y alcance

En Bay Plan, con un viaje abierto, la barra comienza plegada cuando el dispositivo
no tiene una elección anterior. Muestra únicamente «BayStream» y «Desplegar acciones».
Un toque despliega; otro pliega. La elección se guarda como `planToolbarCollapsed`
en la caja local de ajustes, junto al último puerto de T-68; sobrevive la reapertura
y no depende del viaje ni se envía a otro dispositivo.

Al desplegar siguen las ocho acciones originales: viajes recientes, perfiles,
nube/cuenta, búsqueda, exportación, parámetros, cargar BAPLIE y limpiar datos.
El botón de plegar permanece fijo. Si las acciones no caben, su tira se desplaza
horizontalmente para alcanzar las del extremo. Esto fue necesario para poder
volver a plegar con un toque en el Honor a 360 dp: la primera implementación
dejaba ese botón fuera de pantalla.

Los callbacks de las acciones se conservan. El cambio no vuelve a cargar el
archivo ni sustituye el estado de Bay Plan. Los controles de Contenido, Descarga,
Carga, Número de orden y Tapas siguen siendo los del producto. Fuera de Bay Plan
se conserva la barra anterior y no aparece el botón de plegar.

El proveedor Riverpod lee/escribe mediante el contrato del repositorio local;
la presentación no abre Hive. La escritura usa la cola existente y hace `flush`.
Ante un fallo de lectura se puede recuperar la barra; ante un fallo de guardado
las acciones siguen accesibles y se informa con un mensaje. Los colores añadidos
proceden de Material/`colorScheme`, incluido `colorScheme.error`; no hay colores
literales nuevos ni dependencias nuevas.

**Deuda de T-97:** a 360 dp, desplegada, el título puede quedar sin espacio visible;
las acciones del extremo requieren desplazar la tira. También siguen los textos
cortados del plano y los demás textos enumerados en la ficha de T-97. No se
reescribieron textos ni se abordó su disposición general en esta tarea. Plegada,
la barra superior ya no desborda, tanto en claro como en oscuro.

## 2. Aceptación en los tres clientes

Se usó `tool/t91_main.dart`, que abre la **pantalla real `VesselOverviewPage`** con
selector real y persistencia real, dentro de un banco de aceptación local. Namespace
`t91acc`, sesión «Solo este dispositivo», sin iniciar sesión ni registrar movimientos.
Firebase se inicializa únicamente con opciones de `baystream-app`; el banco rechaza
otro projectId. No se probaron autenticación ni operaciones de nube porque no son
parte de T-91.

En los tres clientes se cargó A07 anonimizado, se confirmó GTSTC y se comprobaron:
**398 contenedores, 21 bahías, 6 940 578 kg; 114 para descargar, 0 para cargar y
284 de paso.** No se usaron datos reales de buques.

| Comprobación | Windows | Honor `.t91` | Chrome visible |
| --- | --- | --- | --- |
| Plegada: solo título y botón, sin desborde a 360 dp | Pasa, claro y oscuro | Pasa, claro y oscuro | Pasa, claro y oscuro |
| Desplegada: ocho acciones recuperadas y botón fijo | Pasa | Pasa; desplazamiento hasta «Limpiar datos» | Pasa; ocho acciones en árbol accesible |
| Un toque para cada transición | Pasa | Pasa | Pasa |
| Bahía 02, modo y desplazamiento conservados al alternar | Pasa | Pasa, Descarga | Pasa, Descarga |
| Cerrar/reabrir conserva desplegada y plegada | Pasa, ambas elecciones | Pasa, ambas elecciones | Pasa, ambas elecciones |

**Windows.** Binario propio en `%TEMP%\baystream-t91-clientes`, abierto exclusivamente
con `Start-Process explorer.exe -ArgumentList <exe>`. Almacén real utilizado:
`C:\Users\Giova\AppData\Local\BayStream\vessel_store`, cajas `t91acc_*`;
no el LocalCache del paquete de Codex. `t91acc_movements.hive` quedó en **0 bytes**.
El banco limita la pantalla a una columna de 360 dp y transmite esa medida a su
MediaQuery en Windows. Se verificaron claro/oscuro, elección de bahía, desplazamiento
y reapertura. La app se cerró únicamente por PID, tras comprobar su ruta;
PIDs registrados en `%TEMP%\t91-windows-pids.txt`.

**Honor.** Variante `gt.cmartinez.baystream.t91`, sin sustituir la app habitual.
Pantalla 720 × 1600 px a densidad 320: **360 × 800 dp**. A07 se llevó desde el
temporal a `/sdcard/Download/t91/T91_A07.edi` y se eligió con el selector real.
Almacén privado de esa variante, namespace `t91acc`. Se comprobaron ambos temas,
las dos elecciones tras cerrar/reabrir y el botón fijo al desplegar. En oscuro,
bahía 02, modo Descarga y plano desplazado, el cuerpo antes/después de alternar
dio **cero diferencias de píxeles** en el rectángulo `[0,324,720,1600]`.
Los XML de uiautomator se capturaron en memoria y se sanitizaron antes de guardarlos
o mostrarlos, como en T-89; campos de cuenta se sustituyen por «cuenta oculta».
No se guardaron capturas del selector que mostraran cuentas. Variante cerrada.

**Chrome.** Servidor exclusivamente local `http://127.0.0.1:8111/`; almacén Hive
del navegador para ese origen, namespace `t91acc`. Ventana visible y viewport
360 × 800, reaplicado en la pestaña nueva. Se cerró y volvió a abrir la pestaña:
el banco releyó primero «desplegada» y después «plegada», recuperando el mismo A07.
En oscuro, bahía 02 y modo Descarga, la comparación antes/después de plegar dio
**cero diferencias de píxeles** del cuerpo `[0,130,360,800]`; se conservaron los
controles y el desplazamiento. En claro, la reapertura mostró título y botón;
al desplegar reaparecieron las ocho acciones. El botón ocupa x=320…360 en ambos
estados. Viewport restaurado y pestaña propia cerrada; servidor cerrado por PID 11240.
La aceptación fue de Codex mediante automatización; Carlos ayudó a poner Chrome
visible cuando la ventana dejó de dibujar.

La implementación actual de Bay Plan tiene desplazamiento, pero no un control
de zoom ni `InteractiveViewer`. Se conservó su estado real; no se agregó zoom
ni se afirma haber probado una función inexistente.

Se avisó con **SEMÁFORO** antes de usar Windows y Honor y al liberarlos. Ninguno
queda abierto al terminar. No se borró el namespace de aceptación ni su bitácora.

## 3. Pruebas, corpus y compilaciones

| Validación ejecutada desde la fuente final de producción | Resultado | Registro en `%TEMP%` |
| --- | --- | --- |
| Suite completa, piso previo 599 | **605/605**, seis nuevas | `t91-suite.log` |
| `flutter analyze`, repetido tras el último ajuste del banco Windows | **0 issues** | `t91-analyze.log` |
| Corpus completo del sprint e históricos | **110/110**, 108 anteriores + dos de T-91 | `t91-corpus.log` |
| Pruebas dirigidas T-91 y su corpus | **8/8** | `t91-directed-final.log` |

Las seis pruebas nuevas cubren Hive real con cierre/reapertura, retención y borrado
de viajes sin perder el ajuste/puerto; aislamiento de namespaces; toques rápidos;
fallos de escritura; lectura inaccesible; y pantalla completa en ambos temas.
Las pruebas de pantalla verifican ausencia de acciones plegada a 360 dp, botón
dentro del ancho al desplegar y «Limpiar datos» alcanzable desplazando la tira.
Para los cuatro modos comprueban identidad del State de Bay Plan y del AsyncValue
del viaje, bahía, modo y posiciones de desplazamiento antes/después de dos toques.
Las dos pruebas de corpus repiten esas invariantes con A07 y sus cifras comprobadas.
No se eliminaron ni omitieron pruebas anteriores.

Reproducción, desde el repositorio y con los comandos de Flutter **en serie**:

```powershell
flutter test --reporter expanded
flutter analyze
$t91CorpusTests = @(rg --files tool -g '*corpus_test.dart')
flutter test --reporter expanded --dart-define="BAYSTREAM_CORPUS_DIRECTORY=C:\Users\Giova\OneDrive\Documentos\OneDrive\Desktop\Archivos .EDI\Anonimizados\files" @t91CorpusTests
flutter test --reporter expanded --dart-define="BAYSTREAM_CORPUS_DIRECTORY=C:\Users\Giova\OneDrive\Documentos\OneDrive\Desktop\Archivos .EDI\Anonimizados\files" test/t91_plan_toolbar_test.dart tool/t91_corpus_test.dart
```

Se compiló en una copia temporal propia, sin sobreescribir binarios de otra tarea:

| Última compilación aceptada | Tiempo del compilador | Registro en `%TEMP%` |
| --- | --- | --- |
| Windows release | **32.5 s** | `t91-windows-final-build.log` |
| APK release `.t91`, firma debug solo en la copia | **74.3 s**, 61.4 MB | `t91-apk-final-build.log` |
| Web release | **71.4 s** | `t91-web-final-build.log` |

Comandos usados en la copia: `flutter build windows`, `flutter build apk` y
`flutter build web`, cada uno con `--release -t tool/t91_main.dart` y
`--dart-define-from-file=C:\Proyectos\baystream-privado\firebase-prod.json`.
Ese archivo y `android/key.properties` no se abrieron ni imprimieron. La copia
excluyó credenciales y firma privada; el applicationId `.t91` y la firma debug
se ajustaron exclusivamente allí. El SDK C++ existente se reutilizó sin descargar
dependencias nuevas.

El SHA de **cada archivo de `lib/`** coincide entre repositorio y copia: **0 diferencias**.
Tras compilar Android/Web se corrigió únicamente la rama Windows del MediaQuery
del banco; se recompiló Windows y se repitió analyze. Ese último ajuste no cambia
el código ejecutado por Android/Web ni la fuente de producción de `lib/`.

Advertencias de compilación declaradas: MSB8029 por compilar Windows en TEMP,
avisos de APIs Android obsoletas/unchecked y la referencia preexistente a la fuente
CupertinoIcons en Web. Analyze no presenta advertencias ni errores. No se ejecutó
`flutter test --platform chrome` ni se hicieron mediciones H5.

## 4. Integridad y evidencia

Reglas intactas: mismo SHA local que el documentado para las reglas publicadas.
No se consultó ni alteró producción mediante Firebase CLI o credenciales de
administrador. No se ejecutaron deploy, publicaciones ni Git de escritura/status.

| Archivo protegido | SHA-256 antes = después |
| --- | --- |
| `docs/T80-firestore.rules.propuesta` | `21894B7F43E59F856045473731B795D21F8373C5AC8A1D9FFF324334AC3C9000` |
| `lib/main.dart` | `C5189B1D8711837A05C68306D424C9FDBCC977BA3BBB6C823089FFE4CA5339D5` |
| `lib/latency_test_screen.dart` | `599310DB13A713E82FC0D6A411BE2D7757CBC2B803D772C1CAA16C471725CDFF` |
| `lib/c3_reconciliation_screen.dart` | `3AF478364A8C5386E1F921E0142DC4F847594BECA00B6743563CB09A8A4112A5` |
| `pubspec.yaml` | `14916474A1874780E0D5851F9AFB4AE46A4B6B75286D4B497919DE38B7509E9F` |
| `pubspec.lock` | `FAA283751D6D97B1F87059EA683B4CC12ED43DDF6E92A52C1B993A801A510C97` |
| Lector BAPLIE | `5D8C843E54D94250E5AE716B839C3000B9A8F7BD4760A5092DD6DC0EFFC4802F` |
| Escritor BAPLIE de salida | `05EE91981499215E9981094EE3C3230C00AB98C54F4793B8750880D23E656147` |

**`pubspec.yaml` y `pubspec.lock` no cambian.** Los cuatro documentos ajenos que
ya tenían modificaciones al llegar no se tocaron ni se incluyen en la entrega.

Las capturas y sus derivados viven en
`C:\Users\Giova\AppData\Local\Temp\baystream-t91-clientes\evidence\`.
No se copió al repo el corpus, sus temporales, almacenes ni salidas.

Evidencias finales seleccionadas:

- Windows: `windows-claro-plegada-final.png`, `windows-oscuro-expandida-final.png`,
  `windows-oscuro-plegada-final.png`, `windows-reapertura-plegada-final.png`.
- Honor: `honor-claro-plegada-final.png`, `honor-claro-expandida-final.png`,
  `honor-oscuro-expandida-final.png`, `honor-oscuro-antes-final.png`,
  `honor-oscuro-despues-final.png`, `honor-reapertura-plegada.png` y
  `honor-state-safe.xml`.
- Chrome: `chrome-oscuro-expandida-final.png`, `chrome-oscuro-antes-final.png`,
  `chrome-oscuro-plegada-final.png`, `chrome-claro-plegada-final.png`.

![Chrome claro: barra plegada a 360 dp](C:/Users/Giova/AppData/Local/Temp/baystream-t91-clientes/evidence/chrome-claro-plegada-final.png)

Incidencias resueltas durante la aceptación: botón de plegar fuera del Honor
(se añadió la tira desplazable); medida MediaQuery del banco Windows mayor que su
columna (se corrigió el banco y se recompiló); reintento automático de Riverpod ante
lectura fallida (se desactivó para permitir recuperar las acciones). Algunas capturas
de Windows/Chrome vencieron o salieron negras; no se presentan como pruebas exitosas.
En Chrome fue necesario recuperar una pestaña cerrada y reaplicar el viewport al
crear otra; la captura final clara es de la pestaña nueva a 360 dp.

## 5. Horas frente a la estimación

Estimación de la ficha: **1.5 h**. Inicio observado: **12:54:16** de Guatemala
(18:54:16 UTC). Fin de comprobaciones técnicas/aceptación: **15:58:01**
(21:58:01 UTC): **3 h 03 min 45 s de pared**.

Esa ventana incluye la interrupción de la sesión antes de «prosigue»: entre las
capturas del Honor de **13:19:20** y **15:21:07** transcurrieron **2 h 01 min 47 s**.
Descontando ese intervalo quedan aproximadamente **1.03 h**, más la redacción
final del informe. Es una reconstrucción del tiempo observado, **no un cronómetro
continuo de dedicación**; no se cargan las tres horas de pared como trabajo activo.
La implementación necesitó ajustes y recompilaciones por los hallazgos de aceptación
indicados arriba. No quedó trabajo funcional pendiente ni se amplió el alcance a T-97.

## 6. Archivos propios y entrega a Carlos

Diez rutas, incluyendo este informe:

1. `lib/features/vessel/domain/repositories/local_vessel_repository.dart`.
2. `lib/features/vessel/data/datasources/hive_vessel_data_source.dart`.
3. `lib/features/vessel/data/repositories/local_vessel_repository_impl.dart`.
4. `lib/features/vessel/presentation/providers/plan_toolbar_provider.dart` (nuevo).
5. `lib/features/vessel/presentation/pages/vessel_overview_page.dart`.
6. `test/support/t91_toolbar_support.dart` (nuevo).
7. `test/t91_plan_toolbar_test.dart` (nuevo).
8. `tool/t91_corpus_test.dart` (nuevo).
9. `tool/t91_main.dart` (nuevo).
10. `docs/T91-RESULTADOS.md` (nuevo).

Ninguna de estas rutas requiere `git add -f`. Carlos ejecuta Git:

```powershell
git add -- "lib/features/vessel/domain/repositories/local_vessel_repository.dart"
git add -- "lib/features/vessel/data/datasources/hive_vessel_data_source.dart"
git add -- "lib/features/vessel/data/repositories/local_vessel_repository_impl.dart"
git add -- "lib/features/vessel/presentation/providers/plan_toolbar_provider.dart"
git add -- "lib/features/vessel/presentation/pages/vessel_overview_page.dart"
git add -- "test/support/t91_toolbar_support.dart"
git add -- "test/t91_plan_toolbar_test.dart"
git add -- "tool/t91_corpus_test.dart"
git add -- "tool/t91_main.dart"
git add -- "docs/T91-RESULTADOS.md"
git commit -m "Sprint 3: T-91 barra del plano plegable con preferencia local"
git push
```

### Resumen de tres líneas

La barra de Bay Plan se pliega con un toque y recuerda la elección por dispositivo.
Windows, Honor y Chrome pasan con A07 y ambos temas; la vista se conserva y plegada no desborda a 360 dp.
605 pruebas, analyze 0 y corpus 110/110; reglas intactas, deuda de textos en T-97 y T-91 En revisión.

### Mensaje para Yov

T-91 queda En revisión, pendiente de Timonel por 10.18. La barra del plano muestra
solo título y botón plegada, recupera las ocho acciones al desplegar y persiste la
elección en ajustes por dispositivo. Aceptación propia completada con A07 en Windows
(almacén real t91acc), Honor .t91 y Chrome visible: ambos temas, 360 dp, conservación
de bahía/modo/desplazamiento y ambas preferencias tras reapertura. Suite 605/605,
analyze 0, corpus completo 110/110; reglas, main, H5 y pubspec intactos, sin dependencias
ni publicación. El título/textos cortados siguen para T-97. Informe y diez rutas exactas
en docs/T91-RESULTADOS.md. Ventana técnica de pared 3.06 h con una interrupción
observada de 2.03 h; resto aproximado 1.03 h más redacción, frente a 1.5 h estimadas.
