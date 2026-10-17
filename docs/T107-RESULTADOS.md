# T-107 · Parte A: el encabezado del plano, compacto en el teléfono — resultados (Timonel)

**Estado: PARTE A COLOCADA EN EL ÁRBOL, SIN COMMIT, PARA LA REVISIÓN RÁPIDA DE CODEX.** La parte B (la etiqueta de accesibilidad, los avisos del deriver y U+2011 en lo demás) va después de la demo (10.77).

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
