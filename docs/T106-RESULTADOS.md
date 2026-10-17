# T-106 · Pulido del arrastre y del zoom — resultados (Timonel)

**Estado: COLOCADA EN EL ÁRBOL, SIN COMMIT, PARA LA ACEPTACIÓN DE CODEX.** Código, pruebas, corpus y los dos clientes de la ficha (Windows y el Honor) se completaron en mi copia de `%TEMP%`. Se colocó el 16-oct por la noche, después de que los clientes de la demo del 17 pasaran su prueba de humo, que era la condición de la ficha, de la 10.69 y de la 10.72 (sección 9).

## 1. Qué pide la ficha

RF-038. Son las observaciones de la aceptación de T-105 (10.64 y 10.66) y la de T-95:
1. los avisos de `review()` en palabras, sin `C:` ni `R:`, con la segunda frase solo si aplica;
2. el zoom a 300 % sin lienzo en blanco, el margen de 16 dp sin escalar y la copia que se arrastra a escala;
3. la descarga pendiente dibujada en el modo Carga;
4. los 20 de las impares vecinas dibujados en la vista de una par, solo como dibujo;
5. «re‑estiba» con un guion que no parte línea (U+2011) en la pantalla de T-95.

## 2. Base y copias

- **Desarrollo:** copia de `93dc695` en `%TEMP%\baystream-t106-93dc695`. Son los 632 archivos de `git ls-files`, sacados con `git show`, sin tocar el índice ni el árbol.
- **HEAD avanzó dos veces durante la tarea:**
  - a `ab67fcb`, con T-85 (segregación IMDG): 19 archivos de `lib/`, `test/` y `tool/`, **ninguno mío**;
  - a `bd02328`: solo documentos (`SPRINT-3.md`, la presentación y el tablero).
- **Mis cinco archivos base son idénticos en `93dc695`, `ab67fcb` y el árbol** (SHA-256: `change_requests.dart` `4ac56868…`, `bay_plan_view.dart` `be80f428…`, `plan_drag_confirmation.dart` `2dae9633…`, `discharge_sequence_page.dart` `77a012ac…`, `t95_discharge_sequence_page_test.dart` `65137ae4…`).
- **Revalidé todo sobre `ab67fcb`** en una copia nueva, `%TEMP%\baystream-t106-ab67fcb`. Tiene los 641 archivos de HEAD y encima solo mis nueve. Comparé los 413 archivos de código y configuración contra HEAD: difieren exactamente mis cinco modificados.

## 3. Lo que cambia

**1. Los avisos, en palabras** (`change_requests.dart`). **Ninguna regla cambia:** las mismas condiciones, en el mismo orden.
- **El objeto se nombra como lo ve el planner:**
  - «OR 7 · TSTU0000017», con el orden del listado;
  - el número solo, si no tiene orden;
  - «la reserva 005 02 82».
- **Una reserva se nombra por su celda del BAPLIE,** igual que la pide el formulario de solicitudes de T-80. Si se reubicó, el «en …» dice dónde está prevista ahora.
- **La segunda frase sale solo si aplica:**
  - choca con otro tamaño (bahías de distinta paridad): «Un 20 y un 40 no se intercambian.»;
  - choca con carga de paso a bordo: «Es carga de paso: no se descarga aquí.»;
  - choca con una descarga pendiente a bordo: «La celda está ocupada a bordo; marca primero su descarga.»;
  - choca con otro pendiente del mismo tamaño: «La celda está prevista para otro objeto; inclúyelo en el intercambio.»;
  - con lo ya cargado del mismo tamaño, o entre destinos del mismo lote, no hay segunda frase.
- **«No está en el plan», «el origen cambió» y «no cabe»** también nombran el objeto en palabras.
- **Se conserva el contrato de la prueba de Capitán de la 10.63:** «choca con», el nombre, «en <celda>» y «un 40 ocupa las dos mitades de la celda.».

**2. El zoom** (`plan_drag_confirmation.dart` y `bay_plan_view.dart`).
- **Lienzo en blanco:** la rejilla tomaba su ancho mínimo del ancho real de la vista, fuera del zoom. A 300 %, en una ventana ancha, quedaba centrada en un lienzo tres veces más ancho que lo visible. Ahora un `LayoutBuilder` interno toma el ancho lógico de la vista ampliada.
- **El margen:** `PlanZoomScope` (un `InheritedWidget` nuevo) lleva la escala. El margen es `16 / escala`, así que en pantalla mide 16 dp a cualquier zoom.
- **La copia que se arrastra** vive en el Overlay, fuera del zoom. Lee la escala de `PlanZoomScope`, se dibuja con `Transform.scale` y su desplazamiento también escala. Queda centrada sobre el dedo y por encima de él.

**3. La descarga pendiente en Carga** (`bay_plan_view.dart`).
- **Qué se dibuja:** lo que el plano de llegada trae como descarga en esta escala, todavía planificado y a bordo. Solo en una celda donde el plan de carga no dibuja otra cosa.
- **Cómo se ve:** con la marca de T-75: «BAJA», el ícono ↓ y la etiqueta de accesibilidad «…, por descargar».
- **Qué se puede hacer:** no se arrastra. Soltar ahí sigue dando el rojo del dominio. Tocarla solo abre el detalle.
- **Una vez registrada su descarga,** la celda se ve libre otra vez.
- **También se dibuja en «Número de orden»,** porque esa vista lee la misma operación que Carga.

**4. Los 20 de las impares vecinas, en la vista de una par** (`bay_plan_view.dart`).
- **Qué cuenta:** por fila y nivel, lo que hay en la par − 1 y en la par + 1. Son contenedores, reservas y, en Carga, las descargas pendientes.
- **La huella** es la de T-95 y 10.63, sin calcular pares.
- **Cómo se ve:** una celda gris con «20'» o «2×20'».
- **Es solo dibujo:** la celda vacía de una par ya no tenía toque, y sigue siendo solo destino. No se arrastra ni se toca.
- **En la leyenda,** «Ocupado por 20 pies» va con el mismo gris, solo cuando la par tiene esas sombras. **«Ocupado por 40 pies» no cambia**, porque lo fija la prueba de aceptación de C‑5b (`bay_plan_grid_test.dart`).
- **No se cumplió ninguna de las dos condiciones para detenerse:** ningún aviso nuevo exigió cambiar una regla, y la sombra no cambia lo que se arrastra o se toca.

**5. «re‑estiba»** (`discharge_sequence_page.dart`): las 7 apariciones de la pantalla de T-95 llevan U+2011. La prueba de pantalla de T-95 ajusta sus 6 expectativas de texto, sin tocar ningún assert funcional.

## 4. Las pruebas nuevas (20)

- **`test/t106_messages_test.dart` (9), dominio, con los datos de T-76:**
  - cada aviso con su texto exacto;
  - sin `C:` ni `R:`;
  - el mismo aviso en `review`, `preview` (oficina y muelle), `move` y `request`;
  - los casos de la segunda frase: descarga, paso, 20 contra 40 en los dos sentidos, pendiente del mismo tamaño, reserva, reserva reubicada y ya cargado;
  - lo válido sigue válido.
- **`test/t106_plan_widget_test.dart` (10):**
  - a 300 % con 1600 y 1920 px de ancho, el título y las siete celdas de la 003 quedan dentro de la vista y tocables, sin desplazar;
  - el margen mide 16 px en pantalla, a 100 % y a 300 %;
  - la copia que se arrastra mide lo mismo que la celda a 300 %, centrada sobre el puntero y por encima de él;
  - la descarga pendiente en Carga: no se arrastra, su toque abre el detalle y soltar ahí da rojo con su aviso exacto; registrada la descarga, la celda vuelve a estar libre;
  - las sombras de 20 en la 004: «2×20'», «2×20'» y «20'» con la leyenda, sin arrastre ni gestos, sin hoja, diálogo ni aviso al tocar; el rojo de 10.63 sobre ellas, y ninguna sombra en las impares.
- **`test/t106_reestiba_test.dart` (1):**
  - la pantalla de T-95 con Roboto y la letra del Honor a 2.0 de T-104;
  - recorre de 360 a 420 dp, de 2 en 2, y comprueba que cada «re‑estiba» que se ve queda en una sola línea;
  - comprueba que ningún texto use el guion que parte;
  - comprueba que el paso 8, «Re‑estiba: vuelve», se lee entero.

**El control** (`build/t106/control-head.txt`): las 20 pruebas sobre HEAD sin mis cambios.
- **Fallan 16.**
- **Pasan 4,** que son guardas que HEAD cumple porque no dibuja nada: lo válido sigue válido, la celda libre tras la descarga, la sombra no se toca y la impar no la dibuja.
- **Un diagnóstico aparte, que no se entrega:** con el guion normal de HEAD, el resumen parte «re-estibas» en el guion en **22 anchos, de 378 a 420 dp**. A 360 dp justo no se parte, y por eso la prueba recorre los anchos. Con U+2011 no se parte en ninguno.

## 5. Validaciones

| Validación | Copia de `93dc695` | Copia de `ab67fcb` (HEAD de código) |
|---|---|---|
| Pruebas de T-106 | **20/20** | dentro de la suite |
| Suite completa | **886/886** (piso 866 + 20) | **914/914** (piso **894** medido en `ab67fcb` limpio + 20) |
| `flutter analyze` | **0**, con el banco | **0**, con el banco |
| Corpus completo (`tool/*_test.dart`) | **147/147** (35 archivos) | **157/157** (36 archivos, con el de T-85) |
| `pubspec.yaml` y `pubspec.lock` | sin cambio | sin cambio |

- **Sin cambio frente a HEAD (SHA-256):** `lib/main.dart` `c5189b1d…`, `lib/latency_test_screen.dart` `599310db…`, `lib/c3_reconciliation_screen.dart` `3af47836…`, `pubspec.yaml` `6cafa52d…`, `pubspec.lock` `577d742e…` y `firestore.rules` `01125109…`.
- **Las reglas de `review()` no cambian,** y lo comprueban las pruebas de T-105 y 10.63, intactas y en verde.
- **El modelo, el codec, el lector y el deriver no se tocan.** No hay dependencias nuevas.

## 6. Los clientes

**El banco, `tool/t106_main.dart`:**
- namespace `t106acc`, sesión real y la operación «PRUEBA T-106», sintética y PROVISIONAL;
- **llegada:** dos descargas pendientes (0030082, en una celda que el plan deja vacía, y 0050682, vecina de la 004) y una carga de paso (0050482);
- **carga:** tres 20 en la 003 (OR 1, 2 y 3) y un 40 en la 0040882 (OR 4);
- **geometría:** la misma de PRUEBA T-105, así que el perfil no cambia;
- **«PRUEBA T-105», la de la demo, no se tocó.**

**Compilaciones** con `--dart-define-from-file`, sin abrirlo: Windows en 142 s y APK en 94 s, con `applicationId` `.t106` solo en la copia (`gradle-variante.diff`, una línea; APK `d4d419af…`).

| | Windows (mouse, oficina) | Honor (dedo, muelle, 360 dp) |
|---|---|---|
| Zoom a 300 % | botones, con la ventana maximizada (≈1389 dp): **la rejilla abre a la vista**, con el título y las columnas 08 a 05 | **pellizco de Carlos a 300 %**; se desplaza con un dedo hasta el nivel 82 |
| Copia que se arrastra | a la escala de las celdas, encima del puntero | a la escala de las celdas, centrada sobre el dedo |
| Descarga pendiente en Carga | «↓ BAJA» en 0030082; el toque abre solo el detalle de TSTU0000011 | «BAJA», con la etiqueta «TSTU0000011, 0030082, por descargar» |
| OR 1 sobre la descarga | «0030082 choca con TSTU0000011 en 0030082. La celda está ocupada a bordo; marca primero su descarga.» | el mismo aviso |
| Sombras de 20 en la 004 | «2×20'», «2×20'», «20'» y «20'», con «Ocupado por 20 pies», en claro y en oscuro | las mismas cuatro, legibles |
| Tocar o mantener presionada una sombra | nada | nada |
| OR 4 a 0040482 | «…choca con TSTU0000012 en 0050482: un 40 ocupa las dos mitades de la celda. Es carga de paso: no se descarga aquí.» | el mismo aviso |
| OR 4 a 0040282 y a 0040682 | «…choca con OR 1 · TSTU0000001 en 0030282: … Un 20 y un 40 no se intercambian.» y «…choca con TSTU0000013 en 0050682: … marca primero su descarga.» | — |
| OR 1 a 0030882 (sombra del 40) | «0030882 choca con OR 4 · TSTU0000004 en 0040882: … Un 20 y un 40 no se intercambian.» | — |
| «Mover desde oficina», OR 1 | a 003-04-82: «0030482 choca con OR 2 · TSTU0000002 en 0030482. La celda está prevista para otro objeto; inclúyelo en el intercambio.»; a 004-02-84: «OR 1 · TSTU0000001 no cabe en la bahía 4.»; a 003-06-84, sin aviso. No se guardó | — |
| Registros | 0 movimientos y bandeja en 0 | solicitudes en 0 |

- **«Inclúyelo en el intercambio» no sale arrastrando,** porque el arrastre arma el intercambio solo. Por eso se comprobó en el formulario de oficina.
- **Windows:**
  - abierta con `explorer.exe` (PID 20732, padre `explorer.exe`), una sola instancia, y cerrada por PID;
  - **el almacén real, fuera del paquete** (BAT propio con padre `cmd.exe`): 474 → 488 archivos;
  - los 474 previos quedan idénticos, con 0 modificados, 0 borrados y 0 inaccesibles;
  - **los 14 agregados son todos `vessel_store\t106acc_*`** (`store-before.json`, `store-after.json`, `store-comparison.json`).
- **El Honor:**
  - **lo encontré** a letra 1.0, 720×1600 a 320 dpi, con el lanzador al frente y ningún proceso de BayStream;
  - **Carlos inició sesión** e hizo el pellizco;
  - **yo hice** los arrastres con `motionevent` DOWN/MOVE/UP;
  - **queda** a letra 1.0, sin tocarla, y solo con `.t106` cerrada con `am force-stop`;
  - **los volcados guardados** no traen cuentas, nombres ni UID; los de «Nube y cuenta» no se guardaron.
- **La Web no se probó en T-106,** por decisión de Carlos: la ficha detalla Windows y el Honor. Chrome tampoco.
- **«re‑estibas» de la pantalla de T-95** queda cubierto por la prueba de widget a 2.0, no por los clientes.

## 7. Observaciones fuera de alcance

1. **La etiqueta de accesibilidad de las celdas de carga lleva la clave interna:** «C:TSTU0000003, OR 3, SUBE» (`LoadingCell`, `loading_controls.dart`, `label: '$itemKey, …'`). Un lector de pantalla la lee así. T-106 solo cubría los avisos de `review()`.
2. **«re-estibas» se parte en el guion fuera de la pantalla de T-95:** en el resumen del modo Carga del Honor, a letra 1.0, se lee «· 0 re-» y «estibas.» en dos líneas (`loading_controls.dart`, línea 70). Usan el guion normal también `discharge_controls.dart`, `operation_progress_page.dart` y el aviso del deriver.
3. **Los avisos de conflicto del deriver** (`operation_state_deriver.dart`, líneas 116, 285, 305 y 442) todavía muestran la clave con `C:`.

## 8. Incidencias declaradas

- **El primer permiso para controlar la ventana de Windows salió denegado.** No la toqué, pregunté, y Carlos dijo que lo pidiera otra vez.
- **Mi primera corrida del corpus fue sin `BAYSTREAM_CORPUS_DIRECTORY`:** los 147 casos fallaron por no encontrar los archivos. La repetí con la carpeta y dio 147/147.
- **Mis propias pruebas, corregidas antes de correrlas:**
  - `getRect` sobre el propio `Transform` no incluye su escala, así que se mide un hijo;
  - el selector de bahías también dice «BAY 03 (…)», así que el título se busca anclado.
- **HEAD avanzó dos veces;** está en la sección 2.

## 9. La colocación (16-oct, noche)

- **La condición** (ficha, 10.69 y 10.72): no se coloca nada hasta que los clientes de la demo estén compilados y Carlos confirme que funcionan.
  - Los compilé yo, de `bd02328` y sin T-106, con el namespace `demo17`, en `C:\Proyectos\baystream-demo17\`, fuera del repo.
  - Pasaron la prueba de humo en Windows y en el Honor, con la sesión que inició Carlos. Carlos había dejado dicho que, si pasaban, colocara sin esperar otro aviso.
- **Antes de colocar:**
  - HEAD seguía en `bd02328`;
  - `lib/`, `test/`, `tool/`, `pubspec.*` y `firestore.rules` del árbol no diferían de `bd02328`;
  - mis cinco archivos base eran iguales en `ab67fcb`, en `bd02328` y en el árbol, sin contar el fin de línea;
  - mis cinco archivos nuevos no existían.
- **Lo colocado:** los nueve archivos de la sección 11 y este informe, copiados de la copia de `ab67fcb`.
  - Son byte a byte lo que se probó (`cmp`), con los mismos SHA-256 de la sección 11.
  - Van con fin de línea LF, como se probaron. Git avisa que en la copia de trabajo los pasará a CRLF; eso no cambia el contenido.
  - Este informe se actualizó después de colocarlo (estado y esta sección).
- **En el árbol, después de colocar:**
  - `flutter analyze`: sin incidencias, sin `// ignore`;
  - la suite completa: **914/914** (piso 914), sin skip ni fallos;
  - aparte, las tres de T-106 dan 20/20 y la pantalla de T-95, 6/6;
  - sin cambio: `lib/main.dart`, los dos congelados, `pubspec.yaml`, `pubspec.lock` y `firestore.rules`.
- **El corpus no se repitió en el árbol.** Dio 157/157 en la copia de `ab67fcb`, y los archivos colocados son los mismos bytes.

## 10. Horas

- **≈ 2.5 h de pared,** de 13:40 (copia) a 16:10.
- Incluye la espera del semáforo mientras Capitán tenía Flutter, y los dos clientes.
- No es un cronómetro de trabajo activo. La ficha estimaba 2.0 h.

## 11. Archivos (SHA-256 en la copia de `ab67fcb`, LF)

**Modificados:**
- `lib/features/vessel/domain/services/change_requests.dart` (`e2ec08d1…`)
- `lib/features/vessel/presentation/widgets/bay_plan_view.dart` (`7798edad…`)
- `lib/features/vessel/presentation/widgets/plan_drag_confirmation.dart` (`3d03a520…`)
- `lib/features/vessel/presentation/pages/discharge_sequence_page.dart` (`1df07816…`)
- `test/t95_discharge_sequence_page_test.dart` (`88d1e2f2…`)

**Nuevos:**
- `test/t106_messages_test.dart` (`56690156…`)
- `test/t106_plan_widget_test.dart` (`70cd7a5f…`)
- `test/t106_reestiba_test.dart` (`ed824cf5…`)
- `tool/t106_main.dart` (`3ec2b38e…`)
- `docs/T106-RESULTADOS.md`

**Solo en la copia, no se entregan:**
- la variante de Gradle;
- el diagnóstico del guion;
- las compilaciones;
- las evidencias de `build/t106/`.

**`pubspec.yaml` y `pubspec.lock` no cambian.**
