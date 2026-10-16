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


## Corrección de 10.63

**16-oct-2026 · Capitán Codex. Corrección de dominio entregada; el gesto en pantalla lo verifica Timonel antes de cerrar su aceptación.**

### Base y alcance

- Base actual: `eb3504b193c0928c138c4758b8c73d4549a88938`, rama `sprint-3`; el piso de pruebas era **799**.
- Trabajo y validaciones en `C:\Users\Giova\AppData\Local\Temp\baystream-t105c-1063-20261016\base`, copia de HEAD. No se compiló ni probó en el árbol compartido.
- La solicitud directa de Carlos de 10.63 autoriza corregir la sombra de los 40 en `change_requests.dart` y agregar pruebas `test/t105_*`. El informe original se conserva completo; esta sección documenta la corrección posterior.
- Sin dispositivos, compilaciones de clientes, acceso a Firebase, publicaciones ni apertura del archivo privado de defines. Los comandos de Flutter fueron secuenciales, después de que Carlos cedió el turno; al concluir se le avisó que Flutter quedaba libre.

### Defecto y corrección

El código anterior comparaba solamente el código exacto de la celda. Así aceptaba un 20 bajo la sombra de un 40 pendiente o ya cargado y el caso inverso, tanto en el gesto como en el formulario y la solicitud.

**La revisión física queda exclusivamente en `ChangeRequests.review()`:**

- Huella de la impar b: `{b}`; huella de la par E: `{E−1, E+1}`. No se calcula la par de una impar.
- Hay choque cuando coinciden fila y nivel y las huellas se intersectan.
- Se revisan las posiciones reales a bordo y las previstas de los otros objetos del plan que no se descargan. Las reservas ya asignadas identifican el contenedor que las ocupa; las previstas identifican la reserva.
- Los orígenes de los objetos del mismo lote se excluyen, para conservar los intercambios atómicos. Sus destinos finales sí deben quedar separados físicamente.
- La comprobación anterior de ocupación exacta se retiró de `preview()` para que no exista una regla duplicada. `preview()`, `move()` y `request()` usan la revisión común.
- `decide()` **ya llamaba a `review()` al aprobar** y conserva esa llamada. Ahora también niega una aprobación si entretanto otro objeto quedó previsto o cargado en una huella que choca, con el mismo mensaje. Se conserva la regularización de cargas propias anteriores a la aprobación.

El aviso identifica destino, objeto y posición bloqueante. En el caso entregado por Timonel, el 20 de TSTU0000011 a 0030182 se rechaza con:

> 0030182 choca con TSTU0000016 en 0040182: un 40 ocupa las dos mitades de la celda. La celda está prevista para otro objeto; inclúyelo en el intercambio.

Cuando el bloqueante está a bordo, el cierre dice «La celda está ocupada a bordo; marca primero su descarga.». El código completo del destino se conserva en el texto, también para su identificación inequívoca en las pruebas y los clientes.

No se copió la regla a la vista. `plan_drag_confirmation.dart` y `bay_plan_view.dart` permanecen idénticos; la presentación ya utiliza el error devuelto por el dominio.

### Prueba de Timonel y regresión propia

**Origen autorizado:** `build/t105tm/t105tm_sombra40_test.dart`, entregado por Carlos. SHA-256:

`a144a0a8fe537e0f7cb6a7478433288216418c4f7c2d82bdec53404c3b7d96b5`

Se copió **byte a byte**, sin editar ni formatear, a `test/t105_timonel_shadow40_test.dart` en la copia y luego en la entrega. El original bajo `build/` sigue intacto e ignorado; no se propone forzarlo en Git.

- **Con el código base:** sus cuatro conflictos fallan porque salen válidos; sus dos controles pasan. Salida final `+2 -4`, código 1, esperado para reproducir el defecto.
- **Con la corrección:** pasan sus **6/6**: sombra en 003 y 005, 40 sobre los 20 de ambas mitades, 40 ya cargado y los dos controles libres.
- La sonda propia sobre el caso inicial de Carlos, 40 previsto en 004/02/82 y 20 destinado a 003/02/82, también falla en la base (`review()` devuelve null).
- `test/t105_physical_collision_test.dart` agrega **29 casos**, con igualdad de mensaje entre preview de oficina/muelle, move y request. Cubre ambos sentidos de 20/40 a bordo y previstos; ALFA 044 sobre 043/045 y 041 sola; diferencias de fila, nivel y huella; impares distintas; pares con huellas que se tocan; código exacto; reservas previstas y asignadas; descarga que libera; intercambios de 20 y de 40; destinos superpuestos del propio lote; aprobación después de otro cambio de plan y después de una carga; rechazo permitido y regularización de la carga propia.
- No se borró, omitió ni modificó ninguna prueba existente.

### Validaciones de la corrección

| Comprobación | Resultado observado | Registro externo |
|---|---|---|
| Sonda propia en la base | 1 fallo esperado, porque la colisión sale válida | `baseline-red.log` |
| Prueba de Timonel en la base | 2 controles pasan y 4 conflictos fallan, salida 1 esperada | `timonel-baseline-red.log` |
| Pruebas nuevas sobre la corrección | **35/35**, salida 0: 29 propias + 6 de Timonel | `regression-green.log` |
| `flutter analyze` | **0 incidencias**, salida 0; 35.0 s | `analyze.log` |
| Suite completa | **834/834 = 799 + 35**, salida 0; `00:54 +834: All tests passed!` | `suite.log` |
| Corpus completo `tool/*corpus*test.dart` | **135/135 en 34 archivos**, salida 0; `00:36 +135: All tests passed!` | `corpus.log` |
| Supresiones de análisis | Ningún `// ignore:` ni `// ignore_for_file:` en `lib/` y `test/` de la copia | búsqueda con `rg`, salida 1 sin coincidencias |

Los registros están en `C:\Users\Giova\AppData\Local\Temp\baystream-t105c-1063-20261016`. La evidencia incluye el diff acotado, los SHA iniciales, el origen de la prueba de Timonel y el manifiesto de entrega. El corpus se leyó de su carpeta externa autorizada. No se utilizó `flutter test --platform chrome`.

### Guardia de SHA y archivos de esta corrección

Antes de colocar se exige que las **15 rutas de la guardia inicial** sigan iguales en el árbol compartido y que las dos rutas nuevas continúen ausentes. La copia de los cuatro archivos se verifica por SHA después de transferirla; los restantes archivos de la guardia deben conservar sus SHA iniciales. La evidencia de cierre se conserva en `delivery-sha.json`.

**Cambian exactamente cuatro archivos:**

1. `lib/features/vessel/domain/services/change_requests.dart`.
2. `test/t105_physical_collision_test.dart` — nuevo.
3. `test/t105_timonel_shadow40_test.dart` — nuevo, prueba autónoma de Timonel sin cambios.
4. `docs/T105-RESULTADOS.md` — solo se agrega esta sección.

**`pubspec.yaml` y `pubspec.lock` no cambian.** Tampoco se modifican modelos, codec, reglas, `main.dart`, congelados ni presentación. Sin dependencias nuevas.

| Fuente o prueba entregada | SHA-256 |
|---|---|
| `lib/features/vessel/domain/services/change_requests.dart` | `bb7efcd1589c52c0feb94bc34e0eb98c303f15dcace44104689b3d97e0776340` |
| `test/t105_physical_collision_test.dart` | `732d0f35903da3a1ea7dc04bd08ccf23e05513fd56c351720ca7b8aab2d675c4` |
| `test/t105_timonel_shadow40_test.dart` | `a144a0a8fe537e0f7cb6a7478433288216418c4f7c2d82bdec53404c3b7d96b5` |

### Observación de Timonel que queda fuera de esta corrección

La vista de la bahía 004 no dibuja los 20 de las impares vecinas. No se corrige ahora. Desde esta corrección el dominio informa la colisión al consultar la vista previa, pero **el rojo y la ausencia de hoja en el gesto real siguen pendientes de la verificación de Timonel**. Estas pruebas automáticas no sustituyen esa comprobación de pantalla ni cierran su aceptación.

### Git para Carlos — solo esta corrección

```powershell
git add -- lib/features/vessel/domain/services/change_requests.dart
git add -- test/t105_physical_collision_test.dart
git add -- test/t105_timonel_shadow40_test.dart
git add -- docs/T105-RESULTADOS.md
git commit -m "Sprint 3: rechazar colisiones de 20 y 40 por huella fisica"
git push
```

### Tres líneas de la corrección

La celda física se revisa por huellas en el dominio, con el mismo rechazo en preview, move, request y al aprobar.
Los intercambios siguen válidos; el mensaje identifica quién bloquea y dónde, sin duplicar la regla en la vista.
35 pruebas nuevas pasan, incluidas las seis de Timonel; suite 834/834, analyze cero y corpus 135/135; queda el gesto de Timonel.

### Mensaje para Yov — corrección de 10.63

Corregida T-105 sobre eb3504b: review() detecta choques por huellas de bahía, con misma fila y nivel, contra ocupación real y posiciones previstas de otros objetos que no se descargan. Preview, move y request comparten la regla y el mensaje; decide() vuelve a revisarla al aprobar y niega la aprobación si apareció un choque. Se conservan los intercambios y la regularización de la carga propia. La prueba autónoma de Timonel se incorporó intacta (SHA a144a0a8fe537e0f7cb6a7478433288216418c4f7c2d82bdec53404c3b7d96b5): en la base reproduce cuatro conflictos y dos controles; corregida pasa 6/6. Más 29 casos propios: suite 834/834, analyze cero y corpus 135/135 en 34 archivos. Cuatro rutas entregadas con guardia de SHA; pubspec.*, modelos, codec, reglas, main y congelados sin cambios. Sin dispositivos ni Firebase. Flutter libre. Timonel aún verifica el gesto rojo sin hoja antes de cerrar su aceptación; la ausencia de dibujo de los 20 vecinos en la vista par queda anotada y sin corregir. T-56 vuelve a esperar la cesión de sus clientes.
