# NO PASA · Segunda reaceptación de la candidata del piloto (10.32)

Capitán Codex · 23-oct-2026, Guatemala · **HEAD `6b9d80e`**.

**La corrección del camino que usa `avisoDelViaje` pasa las 18 combinaciones solicitadas. El dictamen global es NO PASA porque quedan avisos que evitan esa función:** un error de Comparar tapa nueve celdas; el error de Parámetros persiste sobre la rejilla al volver; y un registro de tapa invade el resumen que se toca encima de la franja. Tres comprobaciones adicionales de aceptación fallan. No se rechaza la corrección por ejecutar contra ella el antiguo SnackBar hecho a mano.

Evidencia propia en **`build/t114-candidata-reaceptacion2/`**, abreviada **E/**. Solo se añade este informe, sin seguimiento; no se corrigió el producto.

## Paso 0, alcance y banco

`git log -3 --oneline`: **`6b9d80e`**, decisión 10.32; padre **`4e0835b`**, segunda corrección de Timonel; base **`81f4bc9`**, 10.31. HEAD está separado. `git diff --stat 81f4bc9 HEAD`: **72 archivos, 1991 inserciones, 169 eliminaciones**, los 71 de Timonel más SPRINT-4.md. **E/paso0.txt**.

Se leyeron AGENTS.md, decisiones 10.29–10.32, el dictamen anterior, REDISENO-RESULTADOS 11.1–11.9, DESIGN.md 8/13.8, las implementaciones y pruebas indicadas, y las rutas adicionales de avisos. El diff de las áreas restringidas está vacío: dominio, datos, main.dart, congelados, pubspec.* y LISTA-PILOTO. La comprobación final contra HEAD tampoco muestra cambios locales en las fuentes. **E/alcance-restringidos.txt**.

Banco Android nuevo en `%TEMP%\t114-reaceptacion2-6b9d80e\banco`: **317 fuentes Dart de lib/test idénticas byte a byte** a qa-r4. Solo en la copia se agregan los assets sintéticos `t99_inputs/` y el sufijo Android `.r4`. Se usan T100_CARGA.edi, T100_LLEGADA.edi y T100_LISTADO.xlsx; las pruebas de widget usan además fixtures sintéticos en memoria. **E/banco-huellas.json**, **E/resumen.json**. No se abrieron ni copiaron key.properties o firebase-prod.json, ni se usaron archivos reales del piloto en los bancos o capturas.

Sin escrituras de Git, `git status`, Firebase CLI/consola/deploy, cuentas, Honor, aplicaciones de producción, PRUEBA T-105 ni demo17. ADB siempre con **`-s emulator-5554`**; Flutter de uno en uno. No hubo publicación ni uso de claves de distribución. No se capturó la pantalla de cuenta. `pubspec.yaml` y `pubspec.lock` del repo no cambian.

## H2: qué queda cerrado

La app completa se prueba con fuentes reales Plex, Roboto e iconos, planes de **24 contenedores en seis niveles**, y el plano desplazado: **360 × 640, 360 × 800 y 412 × 915; letra 1.0, 1.45 y 2.0; Descarga y Carga**. El aviso se crea mediante `avisoDelViaje`, con los textos enteros/cortos de discharge_controls y loading_controls y Deshacer de 6 s.

**18/18 pasan:** tarjeta dentro de la franja y sobre sus controles, ninguna celda visible invadida, texto elegido completo y dentro de la tarjeta, sin elipsis, semántica del texto visible y Deshacer operable. Se recortan los rectángulos de las celdas por los desplazables y la ventana. **E/matriz-y-rutas.txt**, **E/matriz-resumen.json**, **E/matriz-*.json/.png**, **E/matriz_test.dart.txt**.

| Letra 2.0 | Franja, y | Aviso Descarga, y | Aviso Carga, y |
|---|---|---|---|
| 360 × 640 | 346–560 | 350–492 | 392–492 |
| 360 × 800 | 506–720 | 510–652 | 552–652 |
| 412 × 915 | Descarga 650–835; Carga 621–835 | 667–767 | 625–767 |

Las cifras se pueden tapar según la 10.30. El texto corto conserva la acción y el contenedor u OR; omite la celda de Baja, como se aceptó en 10.32. El número puede partirse entre líneas, pero no pierde caracteres. `_ElQueCabe` solo pinta, recibe toques y expone a semántica el hijo elegido; se comprobó que, cuando sale el corto, no se anuncia el entero oculto. No se reduce la letra ni se reserva espacio.

**No sería justo conservar mi prueba antigua, sin adaptar el productor del aviso, como criterio para rechazar este camino:** inyectaba directamente `SnackBar`, que ahora evita el contrato nuevo. Lo correcto es conservar sus exigencias geométricas y usar la API real, como en esta matriz. La inyección manual sigue siendo útil como prueba negativa: precisamente quedan caminos reales que hacen eso.

**Registros de verdad a letra 2.0:** las pruebas de la suite efectúan dos Baja y una carga por OR, con Deshacer; la prueba propia ejecuta dos Baja consecutivas, una re‑estiba confirmada y Deshacer, verificando anexos y anulación en la bitácora en memoria. El área de plano de esta última es 360 × 420, como el arnés de las pruebas entregadas. **E/rutas-reales-verificadas.txt**, **E/real-reestiba.json/.png**, **E/reales_test.dart.txt**. No son avisos de éxito fabricados para esos registros.

**Error con Ver:** el aviso compacto «No se pudo exportar PDF.» queda en y=392–492 a 360 × 640/2.0, sin tocar celdas ni controles. Ver abre todo el texto; Cerrar retira el diálogo y vuelve al Plano. La prueba de T-61 de la suite también comprueba texto completo y semántica. **E/error-con-ver.json/.png**, **E/error-entero.png**, **E/matriz-y-rutas.txt**.

## Hallazgos que impiden aceptar

### H2-A · P2 · Avisos largos fuera de la guarda, incluso directamente sobre el Plano

`voyage_comparison_page.dart:42` construye un SnackBar manual en `compareWithAnotherBaplie`. Esta función puede llamarse desde el Plano, sin abrir antes otra página. **La guarda de los cuatro archivos no lo cubre.**

Reproducción: viaje publicado en Descarga, varios niveles visibles, 360 × 640 y letra 2.0; Comparar con otro BAPLIE y seleccionar el sintético vacío **T100_SINTETICO_VACIO.edi**. La prueba usa la función del producto y sustituye solo el selector por el proveedor previsto para pruebas. El aviso de rechazo del archivo mide **328 × 364 dp**, **y=128–492**, y cubre **nueve celdas visibles**. Rebasa **218 dp** el borde de la franja (y=346). **E/real-comparacion-error.json/.png**, **E/aceptacion-rutas-y-otros.txt**.

`parameters_page.dart:37` tiene el mismo escape al regresar: abrir Parámetros, intentar guardar el tema con un fallo sintético de escritura y volver antes de los 4 s. Se ejecutó la página real; se inyectó el fallo, no se provocó un fallo del almacén de Carlos. El aviso persistente también ocupa **y=128–492** y tapa nueve celdas. **E/real-parametros-error.json/.png**.

**Dos aserciones de aceptación fallan** por top=128 frente a un mínimo de 346. La operación fallida se informa, pero su aviso obstruye el plano. Antes del piloto, la regla debe alcanzar también estos productores; no basta que los cuatro archivos vigilados estén libres de `SnackBar(`.

### H2-B · P2 · El aviso normal de una tapa cubre parte de un control

En `hatch_operation_controls.dart:67`, «Movimiento de tapa registrado» con Deshacer sigue siendo manual. Reproducción real: en un viaje sintético con tapa declarada, abrir Tapas en la operación, registrar Quitar y volver al Plano durante el aviso; 360 × 640, letra 2.0.

La tarjeta ocupa **x=16–344, y=338–492**, mientras la franja empieza en **346**. El resumen que se abre con un toque (`PlanSummaryLine`) ocupa **x=12–348, y=304–346**: el aviso invade **328 × 8 dp** de ese control. No cubre celdas en este tamaño, ni la fila inferior; **Deshacer sí responde y anula el movimiento**. El problema es el resumen, que la regla también exige dejar libre. **E/real-tapa.json/.png**, línea `QA_TAPA_RESUMEN` de **E/rutas-reales-verificadas.txt**. La tercera aserción de aceptación falla por 338 < 346.

## Censo de escapes y clasificación para el piloto

Se buscó en todo lib/: quedan **nueve construcciones manuales en ocho archivos**, además de la fábrica autorizada. **E/snackbars-directos.txt**. Las mediciones auxiliares conservan las construcciones/textos de esas páginas y mantienen el aviso al volver de una ruta. Se distinguen de las tres rutas reales anteriores; no se afirma haber provocado todos los fallos posibles de persistencia o exportación.

| Origen / aviso, letra 2.0 | Qué se midió | Clasificación |
|---|---|---|
| Tapas en la operación, éxito con Deshacer | 360 × 640: 338–492; 360 × 800: 498–652, 8 dp por encima de la franja; a 412 × 915 cabe | **P2, H2-B**; éxito real reproducido a 360 × 640 |
| Parámetros, error de guardar el tema | Aviso real de fallo inyectado: 364 dp de alto, nueve celdas tapadas en 360 × 640 | **P2, H2-A** |
| Perfiles guardados | «Perfil guardado», 422–492 a 360 × 640, sin obstrucción. Error largo de escritura: 128–492, nueve celdas | Éxito apto; **P2 en la ruta de error**, mismo escape |
| BAPLIE de salida | «Exportación BAPLIE completada» y «Lista de cancelados copiada»: 380–492, sin obstrucción. Error largo: 128–492, nueve celdas | Éxitos aptos; **P2 en la ruta de error** |
| Listado de la agencia | «Listado importado.», 422–492; también cabe en los otros dos tamaños | Apto para este éxito; el error variable no queda protegido por construcción |
| Comparar con otro BAPLIE | Error real del archivo sintético vacío: 128–492, nueve celdas | **P2, H2-A**, aviso directo sobre el Plano |
| Tapas por bahía | «Copiado a 1 bahía», 422–492, sin obstrucción | Apto para este texto; conserva el escape manual |
| Viajes recientes | «Viaje eliminado. El perfil del buque se conserva.», 338–492, rebasa 8 dp la franja. Los errores largos tampoco tienen tope | **P2 al volver al Plano**; medición del texto literal, no eliminación de datos de Carlos |

Los errores largos auxiliares de Parámetros/Perfiles/Salida también invaden celdas en **360 × 800** (12 claves visibles) y **412 × 915** (9). No es correcto suponer que todo aviso procedente de otra página tendrá una sola línea. **E/externo-*.json/.png**, **E/otros_avisos_test.dart.txt**.

### Observación P3 · T-61 sin operación

En modo Contenido, con leyenda y sin franja, T-61 sigue sin tope y muestra el texto entero, sin Ver. A **360 × 640/2.0**, la tarjeta mide **328 × 394 dp**, **y=84–478**. Cubre **18 celdas visibles** y parte de la cabecera con Descarga/Carga; el pie visible queda debajo (leyenda desde y=490). **E/sin-operacion-t61.json/.png**.

Lo clasifico **P3 para el piloto**, fuera del tramo de muelle operando que corrige 10.31: requiere reabrir un viaje cuyo perfil vigente dejaría carga fuera y aparece una vez durante 10 s. Es una obstrucción importante, aunque no se repite con cada contenedor. No lo presento como resuelto ni extiendo a ese caso la autorización de tapar solo cifras.

## O1, O2 y uso del emulador

**O1 cerrado.** Pasan las **16 pruebas de Atrás** dentro de la suite: las 13 anteriores y las tres de zoom, detalle lateral y hoja intermedia. Se revisaron la cancelación del Timer, los listeners y `ModalRoute.isCurrentOf`. Una prueba propia adicional abre y cierra un diálogo durante la ventana: la advertencia desaparece y el siguiente Atrás en la raíz vuelve a advertir, sin salir. **E/o1-dialogo.txt**, **E/dialogo_test.dart.txt**. Dos toques seguidos en la raíz siguen saliendo; H1 conserva el reloj independiente y no toca la cola de avisos.

**Emulador propio:** APK r4 de este commit, sin Firebase, instalado solo en **t99_api26 / emulator-5554**, 1080 × 1920 físicos, densidad 480 (**360 × 640 lógicos**), letra 1.0. El instrumento del repo se ejecutó **una vez**, desde `pm clear` del banco, con serial explícito en todas las llamadas reales de ADB. **27 pasos completos, salida 0**, sin reiniciar o retomar el recorrido. Las capturas p23/p24 muestran la advertencia y el plano; p23 también Deshacer. Las dos comprobaciones positivas registran **1,2 s**. **E/emulador/registro.tsv**, **E/emulador-salida.txt**, **E/adb-comandos.json**, **E/ejecutar_android.py.txt**.

**O2 · P3, instrumento dependiente del tiempo.** La comprobación positiva es mejor que la anterior y esta corrida pasó. No la considero independiente de la duración del volcado: `observe()` bloquea y puede consumir la ventana. Además, `advertencia_y_plano()` retorna al encontrar los tres textos **antes** de comprobar `visto > 2`. Una prueba aislada, sin ADB y con reloj/respuesta simulados, demuestra que acepta un resultado a **3,1 s**. **E/o2-plazo-simulado.json**, **E/sondeo_o2.py**. Debe comprobarse también el plazo en la rama de éxito. Este defecto del instrumento no invalida la evidencia de 1,2 s obtenida aquí ni demuestra un fallo del Timer del producto.

**«No lo tengo», letra 2.0: alcanzable y tocable.** En el banco real del emulador, desde Parámetros → Parámetros del buque, el barrido fijo no encontró el control. Se continuó visualmente: desplazar hasta el pie y retroceder permitió ver el título y la casilla completos. Un toque en **(156,838) físicos** la desmarcó, y otro la marcó de nuevo. **E/parametros2-casilla.png**, **E/parametros2-desmarcado.png**, **E/parametros2-marcado.png**. Es el mismo `geometry-no-limit` de la confirmación; aquí se probó en la edición del viaje sintético ya publicado, no se completó un segundo recorrido a letra 2.0. Lo observado señala una limitación del recorrido/barrido del instrumento, **P3**, no un control inaccesible del producto. No se guardaron cambios; se cerró el formulario, se restauró y consultó `font_scale=1.0` y se detuvo el banco Android.

## Oficina y comprobaciones generales

El banco Windows anterior seguía disponible. Se actualizó su lib con la de este commit y se recompiló reutilizando su caché nativa; no se repitió el escenario entero. Un conductor TEMP hace solo la preparación sintética, una Baja y Deshacer: **7 capturas, final fin, 0 esperas vencidas**. Almacén exclusivo **`%TEMP%\t114-reaceptacion2-6b9d80e\store-windows`**, namespace r4, iniciado por Explorer.

A **1920 × 1080/1.0**, el aviso compacto muestra texto entero y Deshacer; la leyenda y las celdas quedan libres. Deshacer devuelve el contador de **1 de 30 a 0 de 30**. Sigue cruzando el espacio inferior del riel y una zona del panel En vivo, sin un control obstruido: **O3 P3, para COMAR**, como lo decidido. **E/oficina/p06_aviso-compacto-oficina.png**, **E/oficina/p07_deshecho-oficina.png**, **E/conductor-oficina.dart.txt**. No se dependió solamente de la prueba de Timonel. La Web no se ensayó.

| Comprobación | Resultado propio | Evidencia |
|---|---|---|
| Suite completa `flutter test --no-pub --reporter expanded` | **1359 aprobadas, ninguna omitida, una sola invocación y sin reintentos**, 2 min 8 s | E/suite-unica.txt; salida 0 |
| `flutter analyze --no-pub` | **0 incidencias**, banco limpio con fuentes actuales antes de instrumentarlo | E/analisis.txt; salida 0 |
| Matriz y mediciones iniciales | **18 combinaciones de aceptación aprobadas**; 21 mediciones de avisos externos, T-61 sin operación y error con Ver: 41 pruebas ejecutadas | E/matriz-y-rutas.txt |
| Rutas reales y registros | Comparar, Parámetros, tapa con anulación y dos Baja/re‑estiba/Deshacer ejecutados | E/rutas-reales-verificadas.txt; 4 aprobadas funcionalmente |
| Aserciones de aceptación de esas rutas | **3 fallidas** (Comparar, Parámetros y tapa); otras 5 comprobaciones aprobadas | E/aceptacion-rutas-y-otros.txt; salida 1 |
| Diálogo intermedio de O1 | **1 aprobada** | E/o1-dialogo.txt |
| Emulador | **27 pasos en una corrida válida** | E/emulador/ |
| Oficina | Solo aviso compacto y Deshacer; sin fallo del escenario corto | E/oficina/ |

Las mediciones externas que recopilan obstrucciones no las declaran aprobadas: las tres aserciones negativas posteriores son las que impiden aceptar. No se ejecutó `flutter test --platform chrome` ni se repitió la suite completa para conseguir un verde. El análisis completo se hizo en el banco limpio, sin los instrumentos históricos de build/ de qa-r4.

**Incidencias del arnés, conservadas:** una prueba TEMP tuvo un paréntesis extra; otra compilación adicional se quedó sin espacio antes de ejecutar pruebas. Se liberó únicamente el ZIP descargado por mi banco anterior en TEMP (958942848 bytes), conservando su SDK extraído y la evidencia. Una captura de widget requirió mover su E/S a `runAsync`. En la inspección manual se corrigió el acceso a Parámetros y se abandonó el barrido fijo para seguir con desplazamientos visibles. Nada de esto cambió el producto, repitió la suite completa ni se contó como fallo suyo. Los logs iniciales permanecen en E/; las fuentes finales reproducibles están como `*_test.dart.txt`. **E/manifest.json** indexa la evidencia.

## Mensaje para Yov

**Yov: NO PASA `6b9d80e`.** La matriz nueva de 18 casos y la semántica pasan; también los registros, Ver/Cerrar, O1, 1359 pruebas y análisis cero. El emulador completó 27 pasos en una corrida, O2 a 1,2 s. La guarda deja escapar avisos manuales: Comparar y el error de Parámetros tapan nueve celdas; el éxito de Tapas tapa 8 dp del resumen. Son P2 con rutas reales y tres aserciones fallidas. No lo rechazo por el SnackBar artificial antiguo. «No lo tengo» sí se toca a 2.0; O2 conserva dependencia temporal y acepta éxito simulado fuera de plazo. T-61 sin operación y O3 quedan descritos como P3. Producto sin corregir ni publicar; informe y evidencia listos para tu revisión.

ALTO: Yov revisa la segunda reaceptación
