# T-105 · Arrastrar objetos pendientes en el plano

**Estado: EN REVISIÓN, lista para la aceptación cruzada de Timonel.** Implementación, pruebas y aceptación funcional de los tres clientes completadas; transferencia conjunta verificada por SHA.

## Base, autorizaciones y alcance

- Base original: `5fba2f23697523c4918961234448bbf0c1e166f2`, decisión 10.56, comprobada con `git log --oneline -3`. Copia exacta de 601 archivos versionados en `%TEMP%/baystream-t105-fhmrftp6`, obtenida mediante `git ls-files` y `git show`.
- Se leyeron AGENTS.md completo, sección 2 y fichas T-105/T-80/T-81 de SPRINT-3.md, sus decisiones y los tres archivos indicados por Carlos.
- La ficha suponía igualdad entre `move()` y `request()`. Se encontró que `request()` omitía tres controles de `move()`: carga pendiente, ocupación a bordo y grupo de reservas. Se avisó antes de continuar; Carlos autorizó unificarlos mediante `preview()`.
- Carlos autorizó ajustar `test/t80_requests_widget_test.dart`: sus dos variantes de tema parten ahora de la descarga del ocupante de llegada. Conservan solicitud, aprobación, rechazo y permisos; ninguna prueba se borra ni omite.
- Carlos autorizó añadir el zoom que faltaba en HEAD y repetir su comprobación en clientes. Antes solo existía un comentario que mencionaba InteractiveViewer; el plano implementaba dos desplazamientos.
- Durante la interrupción avanzó HEAD a `f6bac1f32ad66f7f6edd50a560ed6108f22a6404`, decisión 10.60. Se creó otra copia exacta de sus 615 archivos y se aplicaron allí únicamente las siete fuentes/pruebas de T-105: `%TEMP%/baystream-t105-integracion-2d962z_o`. Las fuentes finales son idénticas en ambas copias. Esa comprobación de regresión incluye los cambios recientes de T-56 y T-96; no es su aceptación cruzada.

## Cambio

`ChangeRequests.preview(data, actor, changes)` es puro y devuelve validez, intercambio o error. `move()` y `request()` comparten la revisión. El acceso a la operación y el motivo se validan al guardar; `decide()` conserva la regularización de cargas anteriores a una aprobación.

En Carga se arrastran con `LongPressDraggable` únicamente objetos pendientes, con sesión autorizada, operación publicada y abierta, dentro de la bahía visible. El toque sigue abriendo los detalles. La copia queda por encima del dedo y se conserva la respuesta háptica inicial del widget. Los destinos muestran verde/check, ámbar/intercambio o rojo/bloqueo; la vista consulta las reglas del dominio.

Al soltar se abre una hoja desplazable con motivo obligatorio, sugerencias y Cancelar. Se releen operación, rol y plan después de esperar el repositorio. La oficina anexa `changePosition`; el muelle anexa `requestChange`. Cancelar no escribe. El formulario anterior sigue disponible.

Mientras una solicitud está pendiente, su destino lleva borde punteado y reloj en Carga y Número de orden; el objeto sigue en origen. La proyección existente mueve el objeto al aprobar y retira la marca al rechazar.

El zoom admite pellizco de dos dedos y controles de 75 a 300 %, en pasos de 25 puntos. El porcentaje flotante abre los controles; se pliegan al tocar el plano. La escala reduce el viewport lógico de los desplazamientos para conservar acceso a ambos bordes. Un dedo conserva desplazamiento y pulsación larga; durante el pellizco se suspende el desplazamiento. Cambiar de bahía reinicia su zoom.

**Sin cambios** en modelo de movimientos, codec, reglas, Firebase, main.dart, congelados ni dependencias. **pubspec.yaml y pubspec.lock no cambian.** El applicationId `.t105` se modifica exclusivamente en la copia temporal; no se entrega `android/app/build.gradle.kts`.

## Validaciones automáticas

| Comprobación | Resultado final | Evidencia |
|---|---:|---|
| Suite completa sobre HEAD actualizado + T-105 | **799/799**, código 0 | `build-t105-zoom-integration-suite.log` |
| Dominio T-105 | **13 casos**: preview/move/request equivalentes, ocupación, reservas, cargados, cancelados, origen obsoleto, geometría y 20/40 | `test/t105_preview_test.dart` |
| Widgets T-105 | **22 casos**: ambos roles, movimiento/intercambio, cancelar, permisos, operación cerrada, carga remota, marcas y decisiones por stream, descarga/tránsito no arrastrables, toque y desplazamiento; zoom por ratón y pellizco; bordes y toque a 300 % | `test/t105_drag_widget_test.dart`, suite y `build-t105-zoom-regression.log` |
| Análisis final | **0 incidencias** | `build-t105-zoom-integration-analyze.log` |
| Corpus completo final | **135/135 en 34 archivos**, código 0 | `build-t105-zoom-integration-corpus.log` |
| Windows Release final | Pasa, 37.4 s | `build-t105-windows-zoom.log` |
| Android Release final | Pasa, 85.4 s, variante .t105 instalada | `build-t105-android-zoom.log` |
| Web Release final | Pasa, 54.4 s | `build-t105-web-zoom.log` |

El corpus permanece en la carpeta externa autorizada. No se usa `flutter test --platform chrome`. Los 118 casos del corpus de la base original también pasaron antes de incorporar los cambios recientes (32 archivos); la copia actual contiene 34 archivos de pruebas de corpus.

Compilaciones con `--dart-define-from-file=C:/Proyectos/baystream-privado/firebase-prod.json`, sin abrir ni imprimir el archivo. Nunca se abrió `android/key.properties`. No se usaron Firebase CLI, el proyecto H5 ni publicaciones. Un comando Flutter a la vez en la fase final.

## Tres clientes y sincronización

Banco `tool/t105_main.dart`, fuentes sintéticas mínimas, sesión/repositorios/sincronización reales, proyecto `baystream-app`, operación **PRUEBA T-105**, namespace **t105acc**. Los tres objetos son TSTU0000001/2/3, órdenes 1/2/3. Los datos sintéticos se declaran PROVISIONALES.

| Cliente | Oficina | Muelle | Comprobación en otra pantalla |
|---|---|---|---|
| Windows, ratón | Carlos movió OR 1 de 003-02-82 a 003-00-82 e intercambió OR 2 con OR 3. Dos registros persistieron al cerrar por PID y reabrir. | Carlos, con rol dock verificado, pidió OR 3 de 003-04-82 a 003-08-82 con «T105 Windows muelle». El objeto conservó origen y apareció reloj/borde. | La solicitud llegó al Honor como oficina con la misma marca. Codex la aprobó allí con «T105 aprobar Windows» y Windows recibió la posición nueva sin recargar. |
| Web integrada, manual de Carlos | Carlos movió OR 1 de vuelta a 003-02-82 e intercambió OR 2 con OR 3. | Carlos pidió OR 2 de 003-04-82 a 003-08-82 con «T105 Web muelle». | Codex observó en Windows y Honor los cambios de oficina y ambas solicitudes pendientes. El rechazo desde Windows conservó OR 2 en origen y retiró la marca en Honor. Carlos confirmó después la repetición de aprobación y rechazo en el integrado sin recargar. |
| Honor, 360×800 dp, dedo | Tras verificar cuenta de oficina, Carlos movió OR 1 de 003-02-82 a 003-00-82 con «T105 Honor oficina mover» e intercambió OR 2/3 con «T105 Honor oficina intercambio». | Codex hizo pulsación larga táctil con ADB DOWN/MOVE/UP: OR 1 de 003-02-82 a 003-00-82, motivo Peso. Carlos hizo además dos gestos con el dedo que se registraron como solicitudes al conservar el rol de muelle. | Windows recibió los gestos de oficina: 19 y 20 registros respectivamente, posiciones correctas y cero conflictos. La primera solicitud del Honor mostró reloj/borde en Honor y Windows; tras aprobar en Windows, el Honor movió OR 1 sin recargar. |

El integrado sustituye Chrome con **autorización expresa de Carlos** (precedente 10.55). Su conector no inicializa (`failed to write kernel assets`, ruta inexistente); las acciones y observaciones allí son manuales de Carlos, contrastadas desde los otros clientes. No se afirma una prueba de Chrome ni automatización del integrado. Un intento previo de Chrome fue detenido al no poder verificar la URL, y se respetó la detención.

### Recuperación de la confusión y repetición solicitada

Carlos avisó que había confundido la secuencia. Se inspeccionó antes de pedir más gestos: Windows seguía como oficina y el Honor como muelle. «T105 Honor mover» y «T105 Honor intercambio» eran solicitudes pendientes válidas, no movimientos directos. OR 2 estaba cargado y OR 3 cancelado con «me confundi». No se atribuyen los demás registros adicionales a acciones no observadas.

Codex anuló la carga de OR 2 mediante «Marcado por error» y Carlos anuló la cancelación de OR 3 con «T105 recuperar cancelacion accidental». El Honor recibió **16 registros, tres pendientes de carga y cero conflictos**. No se borró la bitácora.

Carlos vio en el integrado los relojes en 003-02-82, 003-04-82 y 003-06-82. Desde Windows aprobó solo «T105 Honor mover» con «T105 repetir aprobacion»; OR 1 pasó a 003-02-82 y desapareció su reloj en Honor y, confirmado por Carlos, en el integrado sin recargar. Después rechazó «T105 Honor intercambio» con «T105 repetir rechazo»: sus marcas desaparecieron, OR 2/3 conservaron origen en Honor y en el integrado sin recargar.

Después se verificó cada rol antes de los gestos restantes. La última aprobación desde el Honor dejó **22 registros, tres pendientes de carga, cero solicitudes pendientes y cero conflictos**. Posiciones: OR 1 en **003-00-82**, OR 2 en **003-06-82**, OR 3 en **003-08-82**. Windows lo mostró «Al día» y Carlos confirmó el mismo efecto final en el integrado sin recargar.

### Comprobación final después de añadir zoom

- **Windows:** reabrió como muelle con los 22 registros conservados. Codex amplió al 125 %. Carlos desplazó el plano, arrastró OR 1 de 003-00-82 a 003-02-82, comprobó «Enviar solicitud» y canceló. La lectura final de Windows muestra 22 registros, cero conflictos, cero solicitudes pendientes y 125 %.
- **Honor:** Carlos hizo pellizco y desplazamiento; el porcentaje terminó en 75 %. Codex amplió con botones al 125 %, hizo pulsación larga táctil ADB OR 3: 003-08-82 → 003-04-82, comprobó «Movimiento válido» y la hoja de oficina «Confirmar», y canceló. Se verificaron otra vez 22 registros y cero solicitudes pendientes.
- **Web integrada:** la primera recarga conservaba la compilación anterior, comprobada mediante la captura enviada por Carlos. El SHA de index, bootstrap y main servidos coincidía con los archivos finales. Se preparó una entrada temporal `t105-refresh.html` que desregistra el SW de la raíz y renueva solo los tres cachés Flutter de localhost:8105, conservando IndexedDB/sesión. Carlos confirmó la versión nueva y después zoom al 125 %, desplazamiento, arrastre OR 1: 003-00-82 → 003-02-82, hoja «Enviar solicitud» y Cancelar. Windows conservó 22 registros/0 solicitudes. Estas comprobaciones Web son manuales de Carlos.

Las cancelaciones de esta repetición no añadieron registros. La matriz de movimientos, intercambios y solicitudes con sincronización se completó antes de incorporar el zoom; después se repitió la interacción modificada sobre las compilaciones finales. No se presenta la matriz entera como repetida después del zoom.

El Honor usa la variante `gt.cmartinez.baystream.t105`, 720×1600 a 320 dpi (360×800 dp). Se encontró letra 2.0 y se usó temporalmente 1.0 en la aceptación. Al terminar se cerró solo la variante .t105 y se restauró y leyó `font_scale=2.0`; resolución y densidad no cambiaron.

Los volcados se capturan en memoria mediante `adb exec-out uiautomator dump /dev/tty`, ocultan cuentas antes de mostrar/guardar y rechazan formularios con contraseña o ventanas de otro paquete. Carlos introduce las credenciales.

## Almacén real de Windows y cierre

App lanzada mediante `explorer.exe`, fuera del paquete; cierres por PID exacto. Almacén real: `%LOCALAPPDATA%/BayStream`, namespace t105acc. Huellas mediante BAT propio lanzado con explorer.exe; cada manifiesto identifica proceso padre cmd.exe.

Primer cierre: **374 archivos previos idénticos**, ninguno modificado o borrado y **14 añadidos**, todos `vessel_store/t105acc_*` (siete Hive y siete lock). Cierre definitivo: **400 archivos, los 374 originales idénticos, cero modificados y cero borrados**. Los 26 añadidos son **14 de t105acc** y **12 de t96acc**, correspondientes a la tarea paralela; T-105 no escribe ese namespace. Ninguna huella quedó inaccesible. Evidencia: `store-before.json`, `store-after.json` (primer cierre), `store-final.json` y `store-comparison-final.json`.

La ventana anterior se cerró por PID 29340 antes de reconstruir; la ventana final, abierta con explorer.exe, se cerró por PID **33004**. El padre de esa app ya no existía al tomar su ficha; no se atribuye un nombre de padre no observado. El BAT de la huella final sí registra padre cmd.exe. El servidor propio 8105 se cerró por PID **18824** tras comprobar script/puerto. No quedan comandos Flutter activos ni clientes T-105 abiertos por Codex; la pestaña del integrado queda en manos de Carlos, con el servidor detenido.

## Incidencias declaradas

- Se inició por error un build propio de Windows mientras el corpus aún figuraba activo. Se detuvo únicamente ese build y su cmake por PID y se esperó el corpus. La descarga interrumpida dejó el SDK ZIP/extracción incompletos en TEMP: se apartó la extracción y reutilizó el ZIP 13.9.0 ya empleado por T-88. El build posterior pasó. Ningún binario compartido se sobrescribió.
- La herramienta nativa devolvió en dos ocasiones el primer plano de otra ventana al pedir el estado de BayStream. Esas capturas se descartaron como evidencia. Se añadió activación explícita y se prefirió lectura de accesibilidad.
- Al verificar Windows después del aviso «listo», la accesibilidad devolvió todavía el formulario de acceso e incluyó un identificador de cuenta, con contraseña enmascarada. Se declaró, descartó la lectura y vació la variable; no se copió a archivos. Las lecturas siguientes descartan formularios antes de imprimir y ocultan identificadores.
- Al desarrollar zoom, las pruebas detectaron competencia entre pellizco y desplazamiento, pérdida de alto por la barra y una celda cubierta con letra 2.0. Se corrigió la presentación; T-75 y T-97 quedaron intactas. Las pruebas finales se ejecutan después de esas correcciones.
- El build Windows avisa MSB8029 por compilar en TEMP. La compilación Web anterior avisó de la fuente CupertinoIcons; no se añaden dependencias para silenciarlo. El análisis Dart final queda en cero.

## Guardia de concurrencia y SHA

Antes del trabajo, dominio y T-80 coincidían byte a byte con HEAD. `bay_plan_view.dart` tenía diferencias CRLF: SHA bruto inicial `8976b2b7439a7075543409ffe2b445d0d0090d3824aad017d28cabcbd55903ef`, SHA HEAD LF `ebb6cb68ed5565ffbb4640cb52d1fa1b18facaad56142170bfecf2c90de86642`; contenido normalizado idéntico y diff-stat ignorando CR vacío. Se preserva el SHA bruto inicial como guardia del árbol.

Antes de copiar, las tres rutas existentes conservaban sus SHA brutos iniciales y sus contenidos normalizados coincidían con HEAD; sus versiones de HEAD conservaban los SHA de la base original. Las cinco rutas nuevas no existían en el árbol compartido. Las ocho se colocaron en una sola transferencia y se verificaron byte a byte; los nueve archivos protegidos conservaron los SHA previos. La evidencia `delivery-sha256.json` incluye también el SHA del informe, sin introducir una huella autorreferente en él. No se sobrescribe trabajo concurrente ni se incluyen sus rutas en Git.

### SHA-256 de las siete fuentes y pruebas entregadas

| Ruta | SHA-256 |
|---|---|
| `lib/features/vessel/domain/services/change_requests.dart` | `a3bbf6e388da386b6dde872d3b5b1cbf64e4e75626273567487454b29e875918` |
| `lib/features/vessel/presentation/widgets/bay_plan_view.dart` | `0f92e2bcb5d1f7882ccbd646684bda5b7548d58567a94075c23aab683b82e820` |
| `lib/features/vessel/presentation/widgets/plan_drag_confirmation.dart` | `6e4530adaf51f7821ed279a01e32d52dc5372533428008c29a2f4f79172fba80` |
| `test/t105_preview_test.dart` | `a2dd21e019a954c247391570973a45081c004d2dbb73d0ae7dde915d6336adfb` |
| `test/t105_drag_widget_test.dart` | `8b3aabfe00bf388317b87b58ca2a74663c2634d9f4d71af455ad4170f9e496b3` |
| `test/t80_requests_widget_test.dart` | `081e7d6dbb5adeb8fb171fc9f90b02cb1fdc877ffb2356d8e0c45d4c8c5be521` |
| `tool/t105_main.dart` | `eeee4d25ebfaf6c7ea3820c465f38900d5ebb48082bb35fe17d819dea20b8a74` |

### SHA-256 protegidos de la copia base, conservados

| Ruta | SHA-256 |
|---|---|
| `firestore.rules` | `0112510984d9a16364f9752e243999c47306e0bcf82766e380db380e8fe8e60a` |
| `firebase.json` | `9bcfd4d9b5a717bd4f044c0e67440c7a81d9858edb1363cbd2cba695d30852e9` |
| `lib/main.dart` | `c5189b1d8711837a05c68306d424c9fdbcc977ba3bbb6c823089ffe4ca5339d5` |
| `lib/latency_test_screen.dart` | `599310db13a713e82fc0d6a411be2d7757cbc2b803d772c1caa16c471725cdff` |
| `lib/c3_reconciliation_screen.dart` | `3af478364a8c5386e1f921e0142dc4f847594beca00b6743563cb09a8a4112a5` |
| `pubspec.yaml` | `6cafa52d781b95b33cadbdf286b95dc989cdf9dbf530bbbb216ac613f09a29b0` |
| `pubspec.lock` | `577d742e04143131bc02a1bbb6c246d298c90396e08f6c9dfe393637a2617f53` |
| `lib/features/vessel/domain/entities/movement.dart` | `a3a773f725ae063f3b9b518c6ca57bd1b779c49a70ee7f20162533ecc9a974c6` |
| `lib/features/vessel/data/repositories/firestore_operation_sync.dart` | `ea63a21606865495e3b189800184871433f24ac775c0e6d0c044cd7ef4c0e974` |

## Horas frente a 3.5

Presupuesto: **3.5 h**. Estimación por los tramos con huellas: **≈ 1.56 h**, incluyendo compilaciones y esperas dentro de esos tramos.

Ventana completa: **2026-10-15 19:24:25 → 2026-10-16 00:11:17, Guatemala**, **4.78 h**. Se descuenta aproximadamente la interrupción por límite de sesión: **2026-10-15 20:16:49 → 2026-10-15 23:29:51**, **3.22 h**, entre `honor-audit-role-and-count.xml` y `build-t105-analyze-delivery.log`. Es una estimación por huellas, no un cronómetro continuo de trabajo activo; la inspección anterior a crear la copia no se midió. No se presenta la ventana completa como horas efectivas. Método y tiempos UTC: `timing-final.json`.

## Archivos de entrega

1. `lib/features/vessel/domain/services/change_requests.dart`
2. `lib/features/vessel/presentation/widgets/bay_plan_view.dart`
3. `lib/features/vessel/presentation/widgets/plan_drag_confirmation.dart`
4. `test/t105_preview_test.dart`
5. `test/t105_drag_widget_test.dart`
6. `test/t80_requests_widget_test.dart`
7. `tool/t105_main.dart`
8. `docs/T105-RESULTADOS.md`

Evidencias y registros locales fuera del commit: `build/t105/entrega-20261016/`. El corpus no se entrega.

## Git para Carlos

```powershell
git add -- lib/features/vessel/domain/services/change_requests.dart
git add -- lib/features/vessel/presentation/widgets/bay_plan_view.dart
git add -- lib/features/vessel/presentation/widgets/plan_drag_confirmation.dart
git add -- test/t105_preview_test.dart
git add -- test/t105_drag_widget_test.dart
git add -- test/t80_requests_widget_test.dart
git add -- tool/t105_main.dart
git add -- docs/T105-RESULTADOS.md
git commit -m "Sprint 3: arrastrar objetos del plan con confirmacion y zoom"
git push
```

## Tres líneas

Arrastrar usa PositionChange y la misma revisión de dominio para oficina y muelle.
Las solicitudes conservan origen y muestran reloj/borde hasta aprobar o rechazar; confirmación con motivo y cancelación sin escritura.
Zoom incorporado y comprobado en los tres clientes; 799 pruebas, análisis cero y corpus 135, listo para la aceptación de Timonel.

## Mensaje para Yov

T-105 implementada sobre 5fba2f2 y comprobada también contra f6bac1f con T-56/T-96: 799 pruebas y análisis cero. Carlos autorizó unificar los tres controles que faltaban en request(), ajustar las dos fixtures de T-80 y añadir el zoom que HEAD no implementaba. Matriz de roles completa en Windows, Honor e integrado autorizado: aprobaciones/rechazos sincronizados sin recargar; confusión recuperada con anulaciones, bitácora conservada y estado final de 22 registros/0 conflictos. Zoom comprobado también en los tres clientes finales, con cancelaciones sin registros. Los 374 archivos originales del almacén real quedan idénticos; se añaden 14 de t105acc y 12 de la tarea paralela t96acc. Ocho rutas transferidas juntas con guardia de SHA y protegidos intactos. Chrome no se da por probado. La aceptación cruzada de T-105 corresponde a Timonel.
