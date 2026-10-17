# T-107 · El encabezado del plano, compacto en el teléfono, y los últimos textos internos — resultados (Timonel)

**Estado (17-oct): PARTE A VERSIONADA EN `2414588` (10.79). PARTE B EN EL ÁRBOL, SIN COMMIT, PARA LA ACEPTACIÓN DE CODEX.** La parte B está en la sección 10. Falta el criterio del Honor, que hoy no se usó.

## 1. Qué pide la parte A

- **En pantallas de menos de 600 dp, el encabezado del plano cabe en dos líneas:**
  - arriba: el modo, el desplegable «Acciones» con los botones de antes y la nube como ícono;
  - abajo: el resumen en una línea, que se abre completo con un toque.
- «OR / últimos dígitos» queda a la vista.
- En el resumen de Carga, «re‑estibas» lleva U+2011 y no se parte.
- Windows y la Web, a 600 dp o más, no cambian.
- Ningún botón cambia lo que hace, y las claves de prueba siguen encontrando cada control.

## 2. Base

- **Copia limpia de `9d2e1a5`** en `%TEMP%\baystream-t107-9d2e1a5`: los 647 archivos de `git ls-files`, sacados con `git show`. Su código es el de `ce13547` (T-106), y los commits posteriores solo traen documentos.
- **HEAD avanzó durante la tarea** a `80b8954` y `b0aac2e`, también solo con documentos (la aceptación de T-106 y la 10.78).
- Antes de colocar, mis siete archivos base eran idénticos byte a byte en `9d2e1a5` y en el árbol.

## 3. Lo que cambia

**`loading_plan_controls.dart`.** Un `LayoutBuilder` mira el ancho del encabezado, sin tocar `bay_plan_view.dart`.
- **A 600 dp o más** se arma el mismo `Wrap` de antes, con los mismos botones y las mismas claves.
- **Por debajo de 600 dp**, la primera línea lleva:
  - el modo (`bay-plan-display-mode`), que se recorta con «…» antes que desbordar;
  - **«Acciones»** (`bay-plan-actions`), un `PopupMenuButton`. Cada entrada llama a la misma acción que su botón y conserva su clave:
    - «Pendientes por bahía», o «Pendientes de descarga» (`discharge-table-button`);
    - «Avance de la operación» (`operation-progress-button`);
    - «Bandeja de cambios (n)» o «Solicitudes de cambio (n)» (`change-requests-button`), con las mismas condiciones que `ChangeRequestsButton`;
    - «Asignar vacío» (`empty-search`) en Carga.
  - **La cuenta de solicitudes pendientes** se ve también en «Acciones», como `Badge`.
  - **La nube como ícono** (`sync-status-chip`), con el ícono y el color del chip, su estado en la ayuda, y abre «Nube y cuenta».
- **El resumen de cada modo** va en una línea; un toque lo abre completo y otro lo recoge.
- **Las acciones del menú usan el contexto del plano,** no el del menú, que ya se cerró.

**`loading_controls.dart`.**
- `LoadingControls(compact: true)` pone el resumen de Carga en una línea, con «OR / últimos dígitos» al lado.
- «Asignar vacío» pasa a «Acciones». A 600 dp o más, todo sigue igual.
- **«re‑estiba» y «re‑estibas»** del resumen de Carga llevan U+2011 en los dos anchos.
- **`PlanSummaryLine`** (nuevo, público, porque lo usan los dos archivos):
  - **recogido:** muestra la primera línea, con «…» y el ícono ⌄. El resto sigue en el árbol, recortado (`ClipRect` + `OverflowBox`), así que los textos y sus claves (`loading-operation-totals`, `bay-discharge-pending`, `bay-loading-pending`…) no cambian;
  - **abierto:** el resumen va a todo el ancho, debajo de la línea, con un alto máximo del 30 % de la pantalla y desplazable, para que la rejilla no se quede sin espacio.

**No cambia:** `DischargeSummary`, `bay_plan_view.dart`, `sync_status_chip.dart`, las reglas, el modelo, el codec, `lib/main.dart`, los congelados, `pubspec.yaml`, `pubspec.lock` ni `firestore.rules`. Sin dependencias nuevas.

## 4. Las pruebas

**Nuevas: `test/t107_header_test.dart` (8),** con Roboto y datos sintéticos de T-75 (llegada) y T-76/T-105 (carga):
- **Carga a 360×780 dp, con letra 1.0 y 1.45:**
  - dos líneas: el modo, «Acciones» y la nube en la misma altura, y el resumen con «OR» debajo, sin nada más;
  - todo dentro de los 360 dp;
  - la rejilla tiene al menos la mitad del alto con 1.0 y un tercio con 1.45;
  - los botones de antes ya no están en la línea, y «OR / últimos dígitos» sí;
  - el resumen se abre y se recoge;
  - «re‑estibas» lleva U+2011 y queda en una sola línea.
- **Descarga a 360×780 dp, con letra 1.0 y 1.45:** las mismas dos líneas y la rejilla; la tabla se abre desde «Acciones»; el resumen recogido conserva su clave.
- **«Acciones» a 360 dp, con letra 1.0 y 1.45:**
  - «Pendientes por bahía» abre la tabla;
  - «Avance de la operación» abre su pantalla;
  - «Asignar vacío» abre el selector de vacíos (OR 12, sin OR 1), y «OR / últimos dígitos» el de llenos;
  - con una solicitud llegada por el stream, el `Badge` muestra 1, la entrada dice «Bandeja de cambios (1)» y abre `ChangeRequestsPage`;
  - la nube es un `IconButton` con la ayuda «Nube y cuenta · …».
- **A 1280 dp,** en Carga y en Descarga, el encabezado es el de antes: sin «Acciones» ni línea plegable, con los botones, el `ActionChip` y el resumen completo.

**El control** (`build/t107/control-head.txt`, en la copia): las 8 pruebas sobre el `lib/` de `9d2e1a5`.
- **Fallan 7.**
- **Pasa 1,** la de Descarga a 1280 dp, que en HEAD tiene que pasar: ese encabezado no cambia.

**Las pruebas existentes que se ajustaron (5).** Corren a 360 dp y tocaban un botón que ahora está en «Acciones».
- **El único cambio:** un toque en `bay-plan-actions` antes de la misma clave o el mismo texto.
- No cambia ninguna clave ni ningún assert. Es el «como mucho, a un toque más» de la ficha.
- **Ninguna necesitó otra clave,** así que no se cumplió la condición para detenerse.
- **Las cinco:**
  - `t74_loading_plan_test.dart` («Pendientes por bahía»);
  - `t75_discharge_test.dart` (`discharge-table-button`);
  - `t76_loading_widget_test.dart` y `t77_load_check_widget_test.dart` (`empty-search`, solo cuando buscan vacíos);
  - `t78_operation_progress_widget_test.dart` (`operation-progress-button`, solo a 360 dp; a 1920 sigue directo).
- **Antes del ajuste fallaban 10 casos,** todos por «Found 0 widgets» de esos controles. Ninguno por desborde. t81, t94, t97, t105 y t106 pasaron sin tocarlos.

## 5. Validaciones (en la copia de `9d2e1a5`)

| Validación | Resultado |
|---|---|
| Pruebas de T-107 | **8/8** |
| Suite completa | **922/922** (piso 914 + 8), sin skip |
| `flutter analyze` | **0**, sin `// ignore`, con el banco |
| Corpus completo (`tool/*_test.dart`, 36 archivos) | **157/157** |
| `pubspec.yaml` y `pubspec.lock` | sin cambio |

**En el árbol, después de colocar** (byte a byte igual a la copia; este informe se completó después): `flutter analyze` en 0 y la suite **922/922**, sin skip.

## 6. Los clientes

**El banco, `tool/t107_main.dart`:**
- la app del producto con el namespace `t107tm` y la sesión real;
- un botón abre A07 como llegada en GTSTC desde `t107_inputs/`, un recurso que existe **solo en la copia de compilación** (`%TEMP%\baystream-t107-build`), como en T-95;
- la copia de compilación agrega, solo allí, la línea del recurso en `pubspec.yaml` y el `applicationId` `.t107` (`build/t107/variante-compilacion.diff`);
- el corpus no entra al repo.

**Compilaciones,** con `--dart-define-from-file` sin abrirlo:
- Windows release: `baystream.exe` `fa535e8b…`;
- APK release, firmado con la clave de depuración porque la copia no tiene `key.properties`: `7d96eb1e…`, el mismo en el teléfono.

**Windows (oficina, ventana maximizada, sin sesión, A07):**
- **El encabezado es el de antes en Contenido, Carga y Descarga:** los botones en línea, el chip «Solo este dispositivo» y el resumen completo. En Carga se leen «0 re‑estibas.», «OR / últimos dígitos» y «Asignar vacío». No aparece «Acciones».
- **Abierta con `explorer.exe`.**
  - **El primer arranque se cayó** antes de mostrar la interfaz: excepción C++ `0xe06d7363` en `KERNELBASE.dll`, según el registro de aplicaciones de Windows. El cliente `demo17` de Carlos estaba abierto. El segundo arranque funcionó. Es nativo y anterior a cualquier pantalla del plano, así que no es del código de T-107. Queda anotado.
  - **El control del escritorio** resuelve el permiso por el nombre «Baystream» y solo concedía el cliente `demo17` de Carlos. Para no tocar su ventana, el banco se abrió como copia del mismo ejecutable con otro nombre, `baystream_t107.exe` (mismo SHA-256).
- **Cerrada por PID.**
- **El almacén real, fuera del paquete** (`.bat` con `explorer.exe`, padre `cmd.exe`): de 516 a 530 archivos.
  - Los 516 previos quedan iguales, sin modificados ni borrados.
  - **Los 14 agregados son `vessel_store\t107tm_*`.**
  - **Los 14 `demo17_*` no se pudieron hashear,** antes ni después, porque el cliente `demo17` de Carlos seguía abierto y los bloqueaba.

**El Honor (360 dp; lo soltó Capitán):**
- **Lo encontré** a letra 1.0, con el lanzador al frente y sin BayStream abierta. Instalé `.t107` aparte, sin tocar «BayStream demo».
- **A07, sin sesión:**
  - en Contenido, Carga y Descarga el encabezado ocupa dos líneas, y la rejilla empieza a unos 300 dp de 800;
  - en Carga, el resumen recogido y «OR / últimos dígitos» van al lado;
  - abierto, el resumen va a todo el ancho y «re‑estibas.» queda entera: el corte cae en el espacio;
  - **«Acciones» en Carga:** «Pendientes por bahía» abre su tabla; «Avance de la operación», su pantalla; «Asignar vacío» está;
  - **en Descarga:** «Pendientes de descarga» abre la tabla con 114 pendientes.
- **A letra 1.45** (el máximo de Ajustes): siguen las dos líneas en Descarga y en Carga. El resumen se recorta a «Car…» y se abre con un toque.
- **«PRUEBA T-106», la operación de prueba, con la sesión de muelle que inició Carlos, a 1.45:**
  - en Carga, el plano se ve en dos líneas, con la descarga pendiente «BAJA» de T-106;
  - **el arrastre funciona:** OR 3 de 003-06-82 a 003-04-82 abre «Mover OR 3 · TSTU0000003» con «Enviar solicitud». **Se canceló:** no se registró nada;
  - **«Acciones» del muelle:** «Pendientes por bahía», «Avance de la operación», «Solicitudes de cambio (0)», que abre su pantalla, y «Asignar vacío», que abre «Vacíos del listado»;
  - «OR / últimos dígitos» abre «Confirmar carga por OR o contenedor».
- **«PRUEBA T-105» no se abrió.**
- **Lo dejé** a letra 1.0, con `.t107` detenida por `am force-stop`.
- **Volcados sanitizados** en la copia de compilación, sin cuentas ni UID. Las pantallas de «Nube y cuenta» no se guardaron.

## 7. Observaciones fuera de la parte A

1. **La tabla de pendientes de descarga y el resumen de Descarga** todavía dicen «re-estibas» con el guion normal (`discharge_controls.dart`). Es de la parte B.
2. **El primer arranque de Windows que se cayó** está en la sección 6.

## 8. Horas

- ≈ 0.7 h de pared, de 20:59 a 21:40, con los dos clientes.
- No es un cronómetro de trabajo activo.

## 9. Archivos

**Modificados:**
- `lib/features/vessel/presentation/widgets/loading_plan_controls.dart`
- `lib/features/vessel/presentation/widgets/loading_controls.dart`
- `test/t74_loading_plan_test.dart`
- `test/t75_discharge_test.dart`
- `test/t76_loading_widget_test.dart`
- `test/t77_load_check_widget_test.dart`
- `test/t78_operation_progress_widget_test.dart`

**Nuevos:**
- `test/t107_header_test.dart`
- `tool/t107_main.dart`
- `docs/T107-RESULTADOS.md`

**Los archivos de `lib/` y `test/` modificados conservan el CRLF de sus blobs.**

**`pubspec.yaml` y `pubspec.lock` no cambian.**

## 10. Parte B: los textos (17-oct)

**Lo que pide la ficha** («Qué construye», punto 4):
- la etiqueta de accesibilidad nombra el objeto como lo ve el planner, igual que los avisos de T-106;
- «re‑estiba» lleva U+2011 en todos los lugares visibles que quedan;
- los avisos del deriver no muestran `C:` y usan el formato de T-106.

Hoy **no se usó el Honor**.

### 10.1 Base

- **HEAD en `9ae744a`.** Desde `2414588`, los commits solo traen documentos: la revisión de Codex y las decisiones 10.79 y 10.80.
- **La copia de validación:** `%TEMP%\baystream-t107b-9ae744a`.
  - Tiene los 471 archivos de `git ls-tree -r HEAD` fuera de `docs/`, sacados con `git show`.
  - Con `diff --strip-trailing-cr`, su `lib/` es igual al del árbol, salvo mis cuatro archivos.
- **Por qué no se validó en el árbol:** hay archivos de T-98 sin versionar, de hoy entre las 17:11 y las 17:15:
  - en `test/`: `t98_estandares_test.dart`, `t98_instrumentos_test.dart` y `t98_auxiliares_test.py`;
  - en `tool/`: varios `t98_*`.
  - Son de Codex: no los toqué. La suite y `analyze` del árbol los habrían incluido a medio hacer.

### 10.2 Lo que cambia

**`loading_controls.dart`, la etiqueta de las celdas de carga.**
- **`loadingCellSemantics()`, nuevo y público,** para probarlo sin pantalla.
  - **Un lleno:** «OR 1 · FULL0001234, sube».
    - El OR sale del listado o del movimiento, igual que en T-106.
    - Sin OR, va solo el número: «FULL0005678, sube».
  - **Una reserva:** «Reserva 005 02 82 · 22G1 · PAMIT · TEST, sube», con su grupo.
    - Con un vacío asignado: «Reserva 005 02 82 · OR 12 · EMPTY0000012, cargada».
  - **La marca, en palabras:** sube, cargado/cargada, cancelado/cancelada o revisar.
  - La celda dibuja lo mismo que antes: «OR 1» y «SUBE».
- **`excludeSemantics: true` y `onTap` en el `Semantics` de la celda.**
  - **Antes,** el lector juntaba la etiqueta con los textos visibles: «C:…, OR 1, SUBE» + «OR 1» + «SUBE». En HEAD pasaba igual; lo vi en el árbol de semántica de la prueba.
  - **Ahora** se lee solo la etiqueta.
  - La acción de tocar se conserva para el lector, y la prueba lo afirma (`hasTapAction`).
  - **No cambia lo que hace el botón:** el toque sigue llamando al mismo `onTap`.

**`operation_state_deriver.dart`, solo los textos de los avisos.**
- **Dos ayudantes privados,** con el formato de T-106: `_shown` (que también usa `_PlanChanges`) y `_name`/`_occupant` en `_Run`.
  - **«OR 7 · TSTU0000017»,** el número solo si no tiene orden, o «la reserva 005 02 82».
  - **Una reserva que ocupa la celda con su vacío asignado** se nombra por el contenedor: «0030882 ya la ocupa OR 12 · EMPTY0000012.»
- **Los 19 avisos que mostraban una clave pasan a ese formato,** entre ellos los de las líneas 116, 285, 305 y 442 que citaba la sección 7 de T-106.
- **«re‑estiba» con U+2011** en el aviso de la descarga de uno de paso.
- **Un límite declarado:** el plan no trae el listado, así que el deriver muestra el OR solo si lo registró el movimiento. Para traerlo habría que cambiar el modelo, y eso está fuera del carril.
- **No cambia:** el tipo de conflicto, la clave guardada, el orden, ni ninguna regla.
- **Queda igual:** el aviso de tapa inválida, que muestra `m.target` (`T:3-1`). No es `C:`, y su objetivo es justamente lo que no se reconoce.

**`discharge_controls.dart` y `operation_progress_page.dart`: «re‑estiba» con U+2011** en los 15 textos visibles.
- En la tabla, el resumen y su explicación.
- La columna «Re‑est.», la marca «RE‑EST.» y «re‑estiba» de la celda.
- El aviso «Re‑estiba», «Registrar re‑estiba», «Deshacer la re‑estiba» y «Re‑estiba registrada».
- En el avance, la explicación, las filas y el tipo de movimiento.
- Los comentarios `///` no se tocaron.

**No cambia:** `loading_plan_controls.dart`, `bay_plan_view.dart`, las reglas, el modelo, el codec, `lib/main.dart`, los congelados, `pubspec.yaml`, `pubspec.lock` ni `firestore.rules`. Sin dependencias nuevas.

**Fuera del carril, sin tocar:** `privacy_policy.dart:70` todavía dice «re-estibas» con el guion normal. Es texto visible de la política de privacidad.

### 10.3 Las pruebas

**Nuevas: `test/t107_texts_test.dart` (26).**
- **Los avisos del deriver (19 casos),** con un plan de llegada que trae un contenedor de paso y el plan de carga de T-76:
  - cada caso afirma el texto exacto;
  - y que ningún aviso tiene `C:`, `R:` ni «re-estiba».
- **La etiqueta (3):**
  - un lleno con OR en sus cuatro estados;
  - un lleno sin listado;
  - una reserva libre y con su vacío.
- **A 360×780 dp, con letra 1.0 y 1.45 (4):**
  - **en Carga,** la celda tiene exactamente la etiqueta «OR 1 · FULL0001234, sube», es botón y tiene la acción de tocar;
  - ninguna etiqueta del árbol tiene `C:` ni `R:`;
  - desde «Acciones», el avance dice «Las re‑estibas se muestran aparte.» y cada «re‑estiba» dibujada queda en una línea;
  - **en Descarga,** el resumen y la tabla terminan en «0 re‑estibas», la columna dice «Re‑est.», y lo dibujado no se parte.

**Nuevas: `test/t107_tabs_test.dart` (4).** La observación de la pestaña; está en 10.5.

**El control,** mis pruebas sobre el `lib/` de HEAD (`build/t107b/control-head*.txt`, en la copia):
- `t107_texts_test.dart` no compila sin `loadingCellSemantics`.
- **Sin el grupo de la etiqueta,** caso por caso: **fallan 21 de 23**.
  - Pasan 2, «la celda la ocupa lo que llegó» y «se carga lo que no sube aquí», porque HEAD ya quitaba el prefijo en esos dos avisos con `substring(2)`. Quedan como guardas.
- Las 4 de la pestaña pasan sobre HEAD (10.5).

**La prueba existente que se ajustó: `t75_discharge_test.dart`.**
- Cuatro aserciones fijaban el guion normal: «1 re-estiba» (dos veces), «RE-EST.» y «Re-est.». Pasan a U+2011.
- No cambia ninguna clave ni ningún paso.
- **Ninguna prueba necesitó otra clave,** así que no se cumplió la condición para detenerse.

### 10.4 Validaciones (en la copia de `9ae744a` con mis archivos)

| Validación | Resultado |
|---|---|
| T-107 (las 30 nuevas, las 8 de la parte A) y `t75` | **46/46** |
| Suite completa | **952/952** (piso 922 + 30), sin skip |
| `flutter analyze` | **0**, sin `// ignore` |
| Corpus completo (`tool/`, 36 archivos, la carpeta por `--dart-define`, salidas en `%TEMP%`) | **157/157** |
| `pubspec.yaml` y `pubspec.lock` | sin cambio |

- Mis 7 archivos del árbol son byte a byte los de la copia (`cmp`).
- **Fin de línea:** los tres archivos cuyo blob es LF siguen en LF; `loading_controls.dart` y `t75` siguen en CRLF.
- **La suite no se corrió en el árbol,** por los archivos de T-98 (10.1).

### 10.5 La pestaña «Estadísticas» (la observación del 17-oct)

**No se reproduce,** ni en las pruebas ni en Windows.
- **`t107_tabs_test.dart`** monta `VesselOverviewPage` completa (`pumpT91Plan`) a 360×780 dp con la llegada sintética de T-75. Prueba, con toque y con ratón:
  - «Lista → Estadísticas»;
  - «Bay Plan → Lista → Estadísticas».
  - Las cuatro terminan en el índice 2, con «Total Contenedores» a la vista. **Pasan sobre HEAD y con mis cambios.**
- **Un diagnóstico aparte** (`%TEMP%\baystream-t107b-evidencia\t107_tabs_diag_test.dart`, no se entrega) probó 12 casos:
  - letra 1.0, 1.45 y 2.0, la barra plegada y desplegada, y toque y ratón;
  - el clic va en el borde visible de «Estadísticas»: a letra 2.0 la pestaña llega a 403 dp y se sale de los 360.
  - **Los 12 dejan el índice en 2.** El controlador avisa solo el índice 2, nunca el 1.
- **En Windows,** a 1280 dp con A07, «Lista → Estadísticas» abrió Estadísticas.
- **El código:** en `vessel_overview_page.dart`, lo único que manda a «Bay Plan» es:
  - `_openBayPlan` (`animateTo(1)`), que solo se llama al tocar una bahía del «Perfil longitudinal» de Estadísticas (`vessel_profile_view.dart:171`);
  - y el buscador (`container_search_delegate.dart:322`).
- **Una hipótesis, sin confirmar:** que el toque cayera en una bahía del perfil, con la pestaña ya abierta. No toqué nada: los dos archivos están fuera del carril.
- **Para seguir,** haría falta reproducirlo en la Web publicada a 360 dp, anotando dónde cae el toque.

**De paso, fuera del carril:** en el diagnóstico, con letra **lineal** de 1.45 y 2.0, Estadísticas desborda a 360 dp en `voyage_stats_view.dart:139`, `:395` y `:770`.
- No se probó con la escala no lineal del Honor; T-97 mostró que dan resultados distintos.
- Queda anotado; no se corrigió.

### 10.6 Windows

**Compilación:** el banco `tool/t107_main.dart`, en la copia de compilación de la parte A (`%TEMP%\baystream-t107-build`) con mis cuatro archivos.
- `--dart-define-from-file`, sin abrirlo.
- `baystream.exe` `fa535e8b…`: el mismo de la parte A, porque el código Dart va en `data/app.so`, que ahora es `52a51d40…`.

**La revisión,** a 1280 × 900 dp medidos (cliente de 1920 × 1350 px a 144 ppp):
- **Abierta con `explorer.exe`** como `baystream_t107.exe` (PID 30716), con el namespace `t107tm`, el rol de oficina guardado y A07 como llegada en GTSTC.
- **El encabezado es el de antes:**
  - **Contenido:** «Pendientes por bahía», «Avance de la operación» y el chip «Solo este dispositivo» en línea.
  - **Carga:** lo mismo, el resumen completo con «· 0 re‑estibas.», «OR / últimos dígitos» y «Asignar vacío».
  - **Descarga:** «Pendientes de descarga», el avance y el chip; el resumen termina en «· 0 re‑estibas».
  - No aparece «Acciones».
- **La tabla de pendientes de descarga:** 6 bahías, 114 pendientes, la columna «Re‑est.» y su explicación.
- **Cerrada por PID.**
- **No se tocaron** las apps de `C:\Proyectos\baystream-demo17\` ni la operación «PRUEBA T-105». No había otra BayStream abierta.
- **El almacén real, fuera del paquete** (`.bat` con `explorer.exe`, padre `cmd.exe`): **544 archivos antes y 544 después**.
  - Ninguno agregado ni borrado, y ninguno inaccesible.
  - **Cambiaron 5, todos `vessel_store\t107tm_*`:** settings, session, voyages, operations y profiles.
  - Los `demo17_*` y el resto quedan iguales.

### 10.7 Pendiente

- **El Honor (criterio de la ficha):** con A07 y una operación de prueba, el plano se ve y se arrastra, y las acciones se alcanzan.
  - Hoy no se usó.
  - La parte A ya lo probó el 16-oct, con el arrastre en «PRUEBA T-106» (sección 6).
  - La parte B no cambia el encabezado ni el arrastre. Aun así, el criterio queda abierto hasta que se repita con este código.

### 10.8 Incidencias declaradas

- **Mis cuatro pruebas de widget fallaron en la primera corrida:**
  - **en Carga,** la etiqueta llegaba unida a los textos visibles de la celda; eso llevó a `excludeSemantics` (10.2);
  - **en Descarga,** mi `_unbroken` contaba el resumen recogido, donde «re‑estibas» queda cortada por el «…» y no se dibuja. Ahora no cuenta lo que no se dibuja.
- **Mi primer `analyze` dio 21 incidencias:** salían de mis dos archivos de control y diagnóstico, guardados en `build/t107b/` de la copia. Los saqué de la copia y dio 0.
- **El control del escritorio** no encontró la app por «BayStream». La concedió por `baystream_t107.exe`, y solo esa.

### 10.9 Archivos de la parte B

**Modificados:**
- `lib/features/vessel/domain/services/operation_state_deriver.dart` (`086058eb…`)
- `lib/features/vessel/presentation/pages/operation_progress_page.dart` (`21ae4cea…`)
- `lib/features/vessel/presentation/widgets/discharge_controls.dart` (`e2bc2987…`)
- `lib/features/vessel/presentation/widgets/loading_controls.dart` (`b1a1737b…`)
- `test/t75_discharge_test.dart` (`6d2ef608…`)
- `docs/T107-RESULTADOS.md` (este informe)

**Nuevos:**
- `test/t107_texts_test.dart` (`2c2ea63b…`)
- `test/t107_tabs_test.dart` (`d780ac78…`)

**`pubspec.yaml` y `pubspec.lock` no cambian.** Las evidencias quedan en `%TEMP%`, fuera del repo.
