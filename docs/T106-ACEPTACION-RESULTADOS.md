# T-106 · Aceptación cruzada de Capitán Codex

**Veredicto: ACEPTADA. Aceptación de `ce13547` cerrada el 16-oct-2026 según 10.75 y 10.77. D1: no es defecto. Honor liberado para Timonel, con letra en 1.0.**

La decisión 10.75 corrige el criterio de la 10.72: el consejo «inclúyelo en el intercambio» es correcto también en el formulario del muelle cuando aplica, porque ese formulario sí ofrece intercambio. Se retiró la clasificación de D1 como defecto y se invirtió la prueba propia externa, que pasa **1/1**. La falta de vista previa en el muelle se conserva como observación anterior a T-106. Windows y Web quedan comprobados con los métodos declarados abajo; el almacén real conserva sus 502 archivos originales y agrega solo 14 `t106cx_*`. En el Honor pasan el pellizco de Carlos a 300 %, los dibujos, T-95 y cuatro avisos a 1.45; Carga, el arrastre rojo sobre BAJA, la copia a escala a 300 % y la sombra sin gestos se comprobaron al volver a 1.0. Se declara por separado el encabezado que tapa Carga a 1.45, ya asignado a T-107 en 10.76. No se modificó código del producto. El Honor conserva los 3 registros iniciales y queda libre, con letra en 1.0; `demo17` conserva su huella.

## 1. Base, aislamiento y reglas

- Base exacta: **`ce135475e5905147f7e51f888b4915ae47de6158`**. El árbol principal estaba en `8f8d856`, que documenta decisiones posteriores; no se utilizó como base de código.
- Copia nueva, sin `.git`: `C:\Users\Giova\AppData\Local\Temp\baystream-t106cx-ce13547-20261016`, exportada con `git ls-files` y `git show`: **646 archivos**. Ninguna lectura ni copia de `android/key.properties` o de la configuración local de Claude.
- Carlos confirmó libres Flutter y Windows. Los comandos de Flutter se ejecutaron en secuencia. No se usó Git de escritura, `git status`, Firebase CLI ni consolas externas.
- Se leyeron la sección 2, la ficha y las decisiones 10.63, 10.66, 10.69, 10.72, 10.74, 10.75 y 10.77 de `SPRINT-3.md`, el informe de Timonel y las observaciones de la sección 12 de T-105. La corrección 10.75 prevalece sobre la redacción original de 10.72; 10.77 autoriza el Honor antes de la demo.
- Mis casos se fijaron **antes de abrir `test/t106_*`**: `evidence/casos-previos.md`, SHA-256 `e690b6bd072dedbbc7c31afe414b05a0d223b48989e81706bd4291c397132c70`.
- El banco de clientes es una variante externa `tool/t106cx_main.dart`: namespace **`t106cx`**, misma operación sintética **«PRUEBA T-106»**, y acceso añadido a la pantalla de T-95. El banco original queda intacto. No se recrea ni publica la operación; ya tiene los dos movimientos de la prueba de humo.
- No se toca «PRUEBA T-105» ni los clientes `demo17`. El Honor se usa por turno de 10.77, con paquete propio.

## 2. Las reglas de `review()` no cambiaron

Comparación directa de `change_requests.dart` entre `ab67fcb` y `ce13547`:

- Los **15 controles `if`/`for` de `review()`**, con sus expresiones completas y en su orden, son idénticos.
- `_footprint` y `_overlaps` son idénticos. El código anterior a `review()` y posterior a los ayudantes de texto también es idéntico.
- Lo añadido selecciona etiquetas y segundas frases. No altera el rechazo, su orden ni el estado.
- Mi matriz propia compara **288 decisiones** con el servicio extraído de `ab67fcb`: todas conservan la misma validez. Incluye ocupación prevista y a bordo, tránsito, descarga, carga registrada, 20/40, origen cambiado, geometría inexistente y destinos fuera de la huella.

Evidencias externas: `change_requests.diff.txt`, `review-controls.json`, `audit.json`, `own-clean.log`. El servicio anterior se instrumentó fuera de `lib/`, con importaciones de paquete y otro nombre de clase, para ejecutarlo junto al actual.

## 3. Casos propios y resultado

**14 pruebas de dominio, todas en verde** (`t106cx_own_test.dart`):

| Caso | Resultado |
|---|---|
| Objeto ausente y origen cambiado con orden | «OR 23 · CXUNO», sin clave interna |
| Objeto sin orden | Solo su número sintético |
| Reserva reubicada: no cabe y choque contra ella | Se nombra por su celda original del BAPLIE; «en …» conserva la posición actual |
| 20 contra 40 y 40 contra 20 | Rechazo y frase de tamaños, sin sugerir intercambio |
| Tránsito a bordo | Carga de paso; no pide marcar descarga |
| Descarga pendiente | Pide marcar primero su descarga |
| Otro pendiente del mismo tamaño | Sugiere incluirlo en el intercambio |
| Contenedor ya cargado del mismo tamaño | Rechazo sin segunda frase |
| Reserva ya asignada | Número asignado y OR, sin segunda frase de acción |
| Destinos del mismo lote que se superponen | Rechazo sin sugerir intercambio |
| Matriz frente a `ab67fcb` | 288/288 decisiones iguales |

**4 pruebas propias de widget del zoom, en verde** (`t106cx_zoom_test.dart`): 200 % y 300 %, con anchos 1389 y 1920. Comprueban acceso inicial a las celdas, margen físico de 16 px y copia del arrastre con las mismas dimensiones que la celda. Con 1389 a 300 % se permite que las columnas del extremo requieran desplazamiento; no se confunde ese caso con un lienzo vacío.

**1 prueba propia de widget corregida según 10.75, en verde** (`t106cx_dock_test.dart`): el formulario del muelle abre con intercambio activado; al apagarlo y enviar un objeto a la celda de otro pendiente del mismo tamaño, muestra el consejo exacto «inclúyelo en el intercambio» y no registra movimientos. También verifica que el aviso no aparece antes de enviar, como comportamiento preexistente de T-81.

La expectativa inicial exigía ausencia del consejo, siguiendo la redacción errónea de 10.72. Carlos pidió invertirla al corregirse esa decisión en 10.75. Se conserva la prueba anterior como `t106cx_dock_test.dart.antes-10-75.txt` y el fallo original en `cx-extra-final.log`; el archivo fechado de casos previos y su SHA no se alteraron. La nueva corrida es **1/1, sin skip**, en `dock-10-75.log`. No se cambió el producto ni las pruebas del repositorio para obtener este resultado.

Las 20 pruebas de Timonel se leyeron después de fijar mis casos. La suite completa las ejecuta: descarga dibujada, desaparición al registrar descarga, sombra de uno/dos 20 sin gestos, rojo físico, margen, copia y guion U+2011. La prueba de T-95 recorre 360–420 dp con la escala no lineal del Honor a 2.0 y verifica que la palabra ocupa una sola línea.

## 4. D1: no es defecto (10.75)

**Clasificación retirada por la decisión 10.75:** el consejo de intercambio llega correctamente al formulario del muelle cuando aplica. La clasificación inicial se basó en la instrucción errónea de 10.72, corregida por Yov y Carlos.

Reproducción con datos sintéticos y rol de muelle:

1. Abrir **«Pedir cambio»**.
2. Desactivar **«Intercambiar dos contenedores»**.
3. Objeto OR 1, destino `0030682`, ocupado por OR 2 del mismo tamaño; escribir motivo y enviar.
4. La solicitud se rechaza, sin registrar movimientos, pero `change-error` muestra:

> 0030682 choca con OR 2 · FULL0005678 en 0030682. La celda está prevista para otro objeto; inclúyelo en el intercambio.

**Resultado correcto según 10.75:** «Pedir cambio» sí tiene la opción de intercambio y abre con ella activada (`swap = !widget.direct`). Si el usuario la apaga, el rechazo puede aconsejar que vuelva a incluir el otro pendiente del mismo tamaño en el intercambio. El consejo es válido en los dos formularios. Esta evidencia ya no se considera un incumplimiento de T-106.

Rutas y líneas:

- `lib/features/vessel/domain/services/change_requests.dart:177`: construye el consejo común.
- `lib/features/vessel/presentation/pages/change_requests_page.dart:277`: el formulario del muelle llama a `request()`.
- `lib/features/vessel/presentation/pages/change_requests_page.dart:288`: guarda el mensaje de la excepción.
- `lib/features/vessel/presentation/pages/change_requests_page.dart:385`: lo dibuja también en el formulario del muelle.

Evidencia histórica: `evidence/cx-extra-final.log`, donde la expectativa anterior falla por el texto encontrado. Evidencia vigente: `evidence/dock-10-75.log`, **1/1**, con la expectativa invertida y el texto completo verificado. La bitácora sintética queda vacía en ambos casos. No hace falta cambiar ninguna regla ni corregir la aplicación.

**Reproducido también en la Web de aceptación, con la sesión de muelle iniciada por Carlos:** OR 1, actualmente en `0030182`, hacia `0030282`, ocupada por OR 2; intercambio desactivado y motivo «T106cx comprobar aviso». Al pulsar «Enviar solicitud», aparece «0030282 choca con OR 2 · TSTU0000002 en 0030282. La celda está prevista para otro objeto; inclúyelo en el intercambio.». Se volvió atrás: no aparece una solicitud nueva y la operación conserva **3 registros, 0 conflictos y 0 solicitudes pendientes**. Captura: `web-D1-muelle.png`.

**Observación O1, ajena a T-106:** la oficina ve la revisión antes de enviar y el muelle solo ve el error al enviar. La guarda `widget.direct &&` ya existe en T-81 (`c31055d`), igual que `swap = !widget.direct`; ambas se cotejaron con `git show` y con el archivo actual. T-106 no modifica `change_requests_page.dart`. Se conserva como observación de uso para que Carlos/Yov decidan su alcance futuro, sin bloquear T-106 ni corregirla en esta aceptación.

## 5. Validaciones ejecutadas en la copia

| Validación | Resultado |
|---|---|
| `flutter analyze`, copia de `ce13547` | **0 incidencias** |
| Suite completa `flutter test --reporter expanded` | **914/914**, sin skip |
| Corpus completo: 36 archivos `tool/*_test.dart` | **157/157**, sin skip |
| Dominio propio | **14/14**, con 288 comparaciones |
| Zoom propio | **4/4** |
| Formulario del muelle propio, criterio 10.75 | **1/1**, consejo correcto, sin registros ni skip |
| `flutter analyze`, banco y pruebas propias incluidos | **0 incidencias** (`analyze-last.log`) |
| Compilación Windows release | Correcta, **137.3 s** |
| Compilación Web release | Correcta, **51.2 s** |
| Compilación Android release para el Honor | Correcta, **106.8 s**, paquete independiente `gt.cmartinez.baystream.t106cx` |

El corpus se leyó desde su carpeta externa mediante `BAYSTREAM_CORPUS_DIRECTORY`; no se copió al repositorio. Sus salidas y todos los registros permanecen en `%TEMP%`. No se ejecutó `flutter test --platform chrome`.

Para la actualización 10.75 solo se repitió `flutter test --no-pub evidence/t106cx_dock_test.dart --reporter expanded`, en la misma copia externa de `ce13547`. Antes de ejecutarlo no había otro proceso de Flutter/Dart activo; se ejecutó un solo comando de Flutter. Terminó con código 0 y «+1: All tests passed!». La suite 914, el corpus 157 y el análisis cero de la tabla son las corridas anteriores, conservadas sin atribuirles una repetición en esta actualización documental.

Sin `// ignore` ni `skip:` en los `.dart` de `lib/`, `test/` y `tool/` de la copia. El script histórico `prepare_block5_probe.ps1` contiene una directiva dentro del texto que genera; no se ejecutó ni modificó.

Las huellas SHA-256 de `lib/main.dart`, los dos congelados, `firestore.rules`, `pubspec.yaml` y `pubspec.lock` son iguales entre `ab67fcb`, `ce13547` y la copia después de compilar. **No cambian `pubspec.yaml` ni `pubspec.lock`; no hay dependencias nuevas.**

El cotejo final contra el árbol confirma también iguales a `ce13547` los cinco archivos de implementación revisados y los seis protegidos anteriores, normalizando únicamente CRLF/LF (`source-final.json`). No se colocó código en `lib/`.

Advertencias de compilación declaradas: MSBuild MSB8029 por compilar en `%TEMP%`, Web avisa de CupertinoIcons ausente durante la reducción de fuentes y Android informa de APIs obsoletas/operaciones sin comprobación de tipos en dependencias. Ninguna impidió compilar; no se atribuyen a un cambio de T-106. Para el cierre del Honor se compiló Android y se comprobó el cliente; no se repitieron la suite, el corpus ni el análisis ya ejecutados sobre esta misma base.

## 6. Clientes

### Windows

Proceso **25468**, lanzado con `explorer.exe`, una instancia, ventana maximizada de **1707 × 1019 px** en la captura y namespace `t106cx`. La sesión de oficina que Carlos había iniciado ya estaba disponible; Codex no escribió credenciales.

Se pulsó «Unirse» exclusivamente en «PRUEBA T-106», luego «Abrir plan de carga». No se pulsó «Preparar sintética» ni se abrió otra operación.

**Referencia al abrir: 3 registros, 0 conflictos, bandeja de cambios 0, «Al día».** La petición habla de dos movimientos de humo; el contador de la app muestra tres registros. Se conserva ese contador como referencia, sin atribuir ni inventar la composición de los registros.

| Comprobación visual | Resultado y evidencia |
|---|---|
| 200 %, maximizada, sin desplazar | Título y rejilla visibles, centrados; `windows-200.png` |
| 300 %, sin desplazar horizontalmente | Título y primeras filas de rejilla a la vista, sin lienzo blanco; `windows-300-inicial.png` |
| 300 %, acceso al nivel 82 | Desplazamiento vertical normal; se ven los extremos y las celdas, sin corregir un desplazamiento horizontal; `windows-300-carga.png` |
| Margen sin escalar | Comprobación geométrica propia: 16 px a 200 y 300 %; no se afirma una medición de píxeles sobre el cliente |
| Descarga en Carga | «↓ BAJA» en `0030082`, junto a OR 1; también se ve su sombra en la par |
| Bahía 004 | Sombras «20'» y «2×20'», leyenda «Ocupado por 20 pies»; tocar la sombra no abre ficha ni hoja; `windows-sombras.png` |
| Aviso de paso | OR 4 a `0040482`: nombra `TSTU0000012` y dice «Es carga de paso: no se descarga aquí.»; `windows-aviso-paso.png` |
| Aviso de descarga | OR 4 a `0040682`: nombra `TSTU0000013` y pide marcar primero su descarga; `windows-aviso-descarga.png` |
| Aviso entre tamaños | OR 4 a `0040282`: «OR 2 · TSTU0000002» y «Un 20 y un 40 no se intercambian.»; `windows-aviso-tamanos.png` |
| Aviso «no cabe» | OR 1 a `0040282`: «OR 1 · TSTU0000001 no cabe en la bahía 4.»; `windows-aviso-no-cabe.png` |
| Otro pendiente igual | Formulario de oficina: OR 1 a `0030282`, ocupada por OR 2, muestra «inclúyelo»; `windows-aviso-intercambio-oficina.png` |
| T-95 | «re‑estibas» completa en el resumen y la celda; `windows-t95.png`. La comprobación a 360 dp/2.0 es de widget, no de este cliente ancho |

Los avisos se observaron en **«Mover desde oficina»**, mediante sus vistas previas. El motivo quedó vacío, «Confirmar movimiento» deshabilitado y se volvió atrás y canceló la ficha de carga. No se guardaron cambios.

**Gesto físico hecho por Carlos:** el `drag` de la herramienta Windows no sostiene la pulsación larga; el intento automático OR 1 → BAJA no levantó la celda ni generó aviso o registro y no se contó como prueba aceptada. Se dejó la bahía 003 a 300 %, con OR 1 y BAJA visibles, y Carlos hizo el gesto. Su confirmación expresa fue **«Sí, pasó todo»** a la pregunta que enumeraba copia del mismo tamaño, rojo y aviso, sin hoja ni registro. Se distingue esa confirmación manual de las capturas y comprobaciones automáticas de Codex. La ausencia de arrastre por pulsación larga sobre la sombra queda cubierta en widget y, además, en la Web real.

Al reanudar, la ventana estaba restaurada, no maximizada; las comprobaciones maximizada a 200/300 % se habían completado antes de la pausa. No se repitieron ni se sustituyeron sus capturas. Al final Windows estaba minimizado y el control de activación se detuvo por entrada del usuario; no se obtuvo una nueva lectura de su contador. El contador final se comprobó en Web y Carlos confirmó que su gesto Windows no registró nada. Se cerró **únicamente el PID 25468**, verificando antes su ruta exacta de la copia.

### Web

Compilación release servida en `http://127.0.0.1:8116`, PID de servidor **28548**, en el **navegador integrado de Codex visible**, viewport de las capturas **1092 × 871 px**. Carlos inició la sesión de **muelle autorizada** y se unió correctamente a «PRUEBA T-106». Codex pulsó «Abrir plan de carga». Namespace `t106cx`, **3 registros y 0 conflictos al abrir**, «Al día». No se capturaron pantallas durante el acceso. **Chrome no se probó.**

| Comprobación | Resultado y evidencia |
|---|---|
| Carga | Se ve BAJA en `0030082`; OR 1 sigue en `0030182`; `web-carga.png` |
| OR 1 sobre BAJA | Copia visible, borde rojo y ⊘; al soltar, aviso de descarga pendiente, sin hoja ni registro; `web-rojo-baja.png`, `web-aviso-baja.png` |
| Bahía 004 | «20'» y «2×20'» con leyenda; toque, pulsación larga y movimiento sobre la sombra no levantan copia ni abren ficha/hoja; `web-sombras-sin-gesto.png` |
| OR 4 a `0040282` | Rojo y «OR 2 · TSTU0000002» con «Un 20 y un 40 no se intercambian.»; `web-rojo-tamanos.png`, `web-aviso-tamanos.png` |
| OR 4 a `0040482` | «TSTU0000012» y «Es carga de paso: no se descarga aquí.»; `web-aviso-paso.png` |
| Zoom 200 y 300 % | Rejilla a la vista, con desplazamiento vertical normal para llegar al 82; en este viewport estrecho a 300 % las columnas derechas exceden la vista; `web-200.png`, `web-300-inicial.png` |
| Arrastre a 300 % | Copia de OR 4 del mismo tamaño visible que las celdas y rojo sobre la sombra; al soltar, aviso de tamaños, sin hoja ni registro; `web-300-arrastre.png` |
| T-95 | La pantalla muestra «re‑estibas» completa y con U+2011; `web-t95.png` |
| Formulario de muelle | **Correcto según 10.75:** «inclúyelo» después del rechazo, sin solicitud nueva; O1: no tiene vista previa, comportamiento anterior a T-106; `web-D1-muelle.png` |
| Final | **3 registros, 0 conflictos y 0 solicitudes pendientes**, «Al día»; `web-final.png`, `web-final.txt` |

**Método del arrastre Web:** eventos ordinarios de ratón mediante la capacidad CDP del navegador integrado, con movimiento inicial para establecer el puntero, botón presionado durante 800 ms y desplazamiento gradual. Se observaron el rojo y la copia con el botón sostenido, y se liberó después para comprobar el aviso. No se invocaron funciones internas de Flutter ni APIs de Firebase; no se modificó código ni se simuló el estado de la operación. La capacidad se llama CDP por el protocolo: **eso no convierte esta prueba en una prueba de Chrome**.

La Web y su servidor se dejaron abiertos para revisión, como pidió Carlos. No hay botones de ratón retenidos. El único intento de guardar fue la solicitud imposible de D1, rechazada localmente antes de anexarse; los demás avisos se produjeron con arrastres rojos.

### Honor, turno autorizado esta noche (10.77)

Aplicación externa **BayStream T106 CX**, paquete `gt.cmartinez.baystream.t106cx` y namespace `t106cx`, compilada de la misma copia de `ce13547`. Solo se cambian en esa copia el `applicationId` y la etiqueta Android; no se copia ni abre `key.properties`. APK release sin `debuggable`, firmado con la clave de depuración: **58 253 799 bytes**, SHA-256 `441825443c0a10e5ffe107c0ca0ecb660dd01c05e91c588396d41791bd429a0b`. Compilación correcta en **106.8 s**, sin otro comando Flutter activo; Flutter se liberó al terminar.

Honor de **720 × 1600 px**, densidad 320 (**360 dp**). Carlos ajustó la letra a **1.45**, verificada por lectura de `font_scale`; inició la sesión de muelle. Codex terminó de abrir exclusivamente «PRUEBA T-106» mediante los controles normales de la app. Referencia: **3 registros, 0 conflictos y 0 solicitudes pendientes**, «Al día». No hubo capturas durante el acceso.

| Comprobación a 1.45 | Resultado y evidencia externa |
|---|---|
| Pellizco real de Carlos | Confirmó 300 % y lo verifica la pantalla; `honor-300-145.png` |
| Descarga pendiente | «BAJA» en `0030082`, en «Número de orden»; `honor-orden-deck-145.png` |
| Bahía 004 | Sombras «20'» y «2×20'»; `honor-par-celdas-145.png` |
| 20 contra 40, formulario de muelle | «OR 2 · TSTU0000002» y «Un 20 y un 40 no se intercambian.»; `honor-aviso-tamanos-completo-145.png` |
| Carga de paso | «TSTU0000012» y «Es carga de paso: no se descarga aquí.»; `honor-aviso-paso-145.png` |
| Descarga pendiente | «TSTU0000013» y «marca primero su descarga»; `honor-aviso-descarga-145.png` |
| Otro pendiente igual | OR 1 hacia `0030282`: «OR 2 · TSTU0000002» e «inclúyelo en el intercambio», correcto según 10.75; `honor-aviso-intercambio-145.png` |
| T-95 | «re‑estibas» no se parte, en resumen y celda; `honor-t95-145.png` |

Los cuatro avisos son rechazos locales de destinos imposibles, con intercambio apagado y motivo sintético no vacío. Los textos no llevan `C:` ni `R:`. No se aprueba ni ejecuta ningún movimiento.

**Observación O2, ya asignada a T-107 (10.76):** a 1.45, el encabezado de Carga consume la pantalla y no deja área útil para la rejilla (`honor-carga-145.png`; `loading_plan_controls.dart:51`, encabezado en `Wrap`, y `:106`, resumen de Carga). No se corrige en esta aceptación. Los dibujos y el pellizco se comprobaron en «Número de orden». Ese modo desactiva el arrastre por diseño (`bay_plan_view.dart:1096`); los intentos de automatización solo desplazaron la rejilla, no levantaron copia y no se cuentan como prueba de arrastre. **Carga y su arrastre se verificaron después a 1.0; no se afirma haberlos verificado a 1.45.** La observación pertenece al alcance ya abierto de T-107; no cambia el resultado de las funciones de T-106 comprobadas aquí.

Carlos volvió la letra a **1.0** desde Ajustes; se verificó por lectura, sin escribir ajustes mediante ADB. Tras reabrir la operación se completó:

| Comprobación en Carga, letra 1.0 | Resultado y evidencia externa |
|---|---|
| BAJA visible | `0030082` dibujada como descarga pendiente; `honor-carga-deck-100.png` |
| Soltar OR 3 sobre BAJA | Borde rojo y ⊘ mientras se sostiene; al soltar, «0030082 choca con TSTU0000011 en 0030082. La celda está ocupada a bordo; marca primero su descarga.». Sin hoja de confirmación; `honor-baja-confirmado-100-{sostenido,soltado}.png` |
| Sombras en bahía 004 | «20'» y «2×20'»; tocar y mantener/desplazar sobre «2×20'» no abre ficha ni levanta copia. Solo desplaza el lienzo; `honor-sombras-carga-100.png`, `honor-sombra-sin-gesto-100-{sostenido,soltado}.png` |
| Copia a 300 % | Se amplió con los controles después del pellizco ya comprobado a 1.45. OR 4 hacia `0040682`: copia del tamaño de la celda, rojo y ⊘ sobre «2×20'»; al soltar, identifica `TSTU0000013` en `0050682` y pide marcar su descarga, sin hoja; `honor-copia300-confirmada-100-{sostenido,soltado}.png` |
| Estado final | **3 registros, 0 conflictos y 0 solicitudes pendientes**, «Al día»; `honor-final-100.png` y `.json` |

**Método del arrastre aceptado:** entradas táctiles ordinarias `DOWN`, espera de un segundo, movimientos graduales y `UP`, por ADB. La captura sostenida se tomó en memoria y se sanitizó antes de guardar; la captura posterior y el volcado verifican el rechazo. No se invocan APIs internas de Flutter ni Firebase. Todos los contactos se liberan al terminar cada gesto.

Los volcados se obtienen únicamente con `adb exec-out uiautomator dump /dev/tty`, se sanitizan en memoria y después se guardan fuera del repositorio. Las imágenes también se sanitizan antes de guardarlas. No se capturó ningún diálogo del sistema con datos de cuenta.

**Cierre del Honor: 16-oct-2026, 21:24:27 (Guatemala).** Letra **1.0** verificada, sin cambios en los contadores. Se cerró exclusivamente `gt.cmartinez.baystream.t106cx` con `am force-stop` y se comprobó que no quedara su PID. El APK de `demo17` tiene la misma huella antes y después: `a6564096f1795014f93f62636c4d1c098ac51c906b054b053d3396930981e899`. No se abrió, reinstaló ni operó esa app; no se tocó «PRUEBA T-105». Evidencias: `honor-final-state.json`, `honor-demo17-before.txt`, `honor-demo17-after.txt`. **Honor liberado para Timonel y avisado a Carlos.** La revisión rápida de T-107 no se inició; espera su mensaje específico.

## 7. Almacén real de Windows

Huella previa tomada **fuera del paquete**, con un BAT propio abierto mediante `explorer.exe`. Cadena registrada: `explorer.exe` → `cmd.exe` → `python.exe`.

- Ruta: `%LOCALAPPDATA%\BayStream` del proceso exterior.
- Antes: **502 archivos**, **0 inaccesibles**, ningún `t106cx_*`.
- Después de cerrar el PID 25468: **516 archivos**, **0 inaccesibles**.
- Los **502 originales quedan idénticos**: 0 modificados, 0 borrados.
- Los **14 nuevos** son exclusivamente `vessel_store\t106cx_*`: device, movements, operations, profiles, session, settings y voyages, cada uno con `.hive` y `.lock`.
- La cadena exterior posterior también queda registrada: `explorer.exe` (13768) → `cmd.exe` (25636) → `python.exe` (27644).

Evidencias: `store-before.bat`, `store-after.bat`, `store-before.json`, `store-after.json` y `store-comparison.json`; las huellas contienen solo rutas relativas, tamaños y hashes, sin abrir el contenido lógico del almacén.

## 8. Incidencias de la aceptación

- El primer lanzamiento del BAT con una ruta de barras diagonales no produjo huella. Se repitió con ruta Windows entre comillas y se verificó su cadena de procesos.
- Al imprimir el final del corpus, mi envoltorio Python falló por la codificación cp1252 de la consola. El comando de corpus ya había terminado correctamente en **157/157**; su registro UTF-8 se conserva. Los siguientes envoltorios usan UTF-8.
- Mi prueba auxiliar de dominio produjo cinco avisos de estilo al analizarla desde `evidence/` (dos `print` y tres bucles sin llaves). Se corrigió únicamente esa evidencia externa; el análisis final vuelve a cero, sin `ignore`.
- La primera prueba auxiliar del muelle buscó el destino cuando todavía estaba activado el intercambio; se corrigieron la preparación y los `pumpAndSettle`. La corrida original falló por una expectativa basada en la redacción errónea de 10.72. Según la corrección 10.75, se invirtió la expectativa y la nueva corrida pasa 1/1; el fallo anterior se conserva como evidencia histórica.
- La prueba auxiliar de zoom exigía inicialmente ver todas las columnas a 300 % en 1389 px. Se corrigió esa exigencia ajena a la ficha; acceso inicial, margen y copia pasan en los cuatro escenarios.
- Dos clics de accesibilidad a «Unirse» fueron rechazados por identificadores caducados; finalmente Codex lo resolvió por imagen, tras comprobar que la vista autenticada solo muestra el nombre de la cuenta. La petición inicial de ayuda para unirse en Windows quedó reemplazada por la del gesto. No se pulsó «Preparar sintética».
- `type_text` no escribió en el campo Flutter y Ctrl+A no seleccionó el texto. Se verificó el foco y se usaron teclas numéricas y retroceso; no se enviaron formularios ni movimientos. Las capturas de los avisos se guardaron después de verificar el destino completo correcto.
- El arrastre de la herramienta no produjo pulsación larga; se declara como intento no realizado y se pidió el gesto a Carlos. No se atribuye como fallo de la app.
- En Web, el primer intento CDP no estableció previamente la posición del puntero y no levantó la celda. Se liberó el botón; al añadir el movimiento inicial y el desplazamiento gradual, se obtuvieron copia, rojo y aviso. Se cuentan solo los gestos observados que funcionaron.
- `setValue` sobre las etiquetas de accesibilidad Web cambió sus valores DOM, pero no los campos visibles de Flutter. Se detectó porque el botón seguía deshabilitado y el resumen no cambiaba; se enfocó cada campo y se escribió con `typeText`. Antes de enviar D1 se verificaron en pantalla los tres valores reales. Al cerrar el formulario no quedó un cambio en la operación.
- Al reanudar Windows, una captura devolvió la ventana frontal de Codex y no BayStream; no se guardó como evidencia ni se actuó sobre Codex. Se seleccionó y activó de nuevo BayStream. En el cierre, las dos activaciones adicionales fueron rechazadas con «user input was detected in this window» y la lectura indicó ventana minimizada; se detuvo el control UI. El cierre por PID y las huellas sí se completaron.
- En el Honor, al crecer la ayuda del formulario cambió la posición de los campos: una entrada quedó en el campo equivocado y se corrigió antes de enviar. Después, el ayudante externo confundió `text` con `content-desc` al buscar el interruptor y se detuvo sin enviar. Se ajustó únicamente el ayudante; los casos posteriores verifican objeto, destino e intercambio apagado antes de pulsar «Enviar solicitud».
- Los intentos iniciales de arrastre en «Número de orden», sobre OR 1 ya reubicado y con el comando `draganddrop` no levantaron copia y no se cuentan como resultados positivos. Se usaron después OR 3 y OR 4, con `DOWN` sostenido un segundo. Un primer destino quedó debajo del control de zoom: se desplazó la fila y se repitió fuera de ese control. Solo se aceptan las capturas finales con copia, rojo y rechazo visible; no se modificó el producto para obtenerlas. El ayudante también se detuvo antes de un gesto sobre sombra al exigir una altura mayor que la de su texto; se ajustó esa comprobación externa y se completó el gesto.
- Una consulta `git show --stat` mostró metadatos del autor. Fue un error de salida; no se copiaron a este informe ni a los archivos de evidencia. Las consultas posteriores deben omitir el encabezado del commit.

## 9. Archivos de entrega y Git para Carlos

**Único archivo modificado del árbol en esta actualización:** `docs/T106-ACEPTACION-RESULTADOS.md`. Todo el código auxiliar, las compilaciones y evidencias están fuera del repositorio. No se modificaron archivos de producto; D1 no requiere una corrección de la aplicación. `pubspec.yaml` y `pubspec.lock` no cambian.

```powershell
git add -- docs/T106-ACEPTACION-RESULTADOS.md
git commit -m "Sprint 3: cerrar aceptacion cruzada de T-106"
git push
```

## 10. Tres líneas

Las reglas de `review()` conservan sus 15 controles y 288 decisiones propias; la suite da 914/914, el corpus 157/157 y el análisis cero.
D1 no es defecto según 10.75: el consejo aplica en ambos formularios; la prueba propia invertida pasa 1/1 y la falta de vista previa se conserva como observación de T-81.
Windows, Web integrada y Honor completan la aceptación; en el Honor se distinguen dibujo/avisos a 1.45 y Carga/arrastre a 1.0 por el encabezado ya asignado a T-107. Quedan 3 registros, letra 1.0 y Honor libre; el almacén Windows solo sumó 14 `t106cx_*`.

## 11. Mensaje para Yov

**T-106 ACEPTADA**, sobre `ce13547`. Honor completado esta noche según 10.77, con paquete y namespace `t106cx`: pellizco real de Carlos a 300 %, BAJA y sombras en «Número de orden», T-95 y cuatro avisos en palabras a 1.45. El encabezado tapa Carga a 1.45, como ya documenta 10.76 para T-107; se declara esa limitación y se verifica Carga a 1.0: rojo sobre BAJA, copia a escala a 300 % y sombra sin gestos. **D1 no es defecto (10.75)**; O1 sigue ajena a T-106. Se conservan reglas intactas, suite 914/914, corpus 157/157 y análisis cero; Windows/Web integrada comprobados y almacén Windows con originales idénticos y solo 14 `t106cx_*` nuevos. Honor termina con **3 registros, 0 conflictos, 0 solicitudes pendientes y letra 1.0**; app de aceptación cerrada y dispositivo libre para Timonel. APK `demo17` idéntico antes/después; «PRUEBA T-105» intacta. Informe colocado sin commit, sin cambios de producto ni `pubspec.*`. No se inició la revisión rápida de T-107.
