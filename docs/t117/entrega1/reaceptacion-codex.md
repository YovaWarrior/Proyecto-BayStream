# NO PASA — Reaceptación de T-117 y T-118, entrega 1, corrección 1

Capitán Codex · 25 de octubre de 2026 · decisiones 10.42 y 10.43.

**H1 y H2 pasan. La distribución visual de H3 pasa. Queda un P2: «Acciones» solo con ícono no tiene nombre accesible en Windows.** La variante nueva hace visible este problema en la oficina a 700 dp. El tooltip existe, pero no sustituye al nombre del control en ese cliente. No se corrigió el producto.

## Candidata y método

- Árbol: `C:\Proyectos\baystream-qa-r4`, HEAD separado **`916bf2b4b99163949ab792b63e64c29551d8b2e4`**, decisión 10.43. `git log --oneline -3`: `916bf2b`, `9ab01f1`, `80ae18b`. Base de esta revisión: **`f60d2a8`**.
- Se leyeron AGENTS, 10.42–10.43, C1.1–C1.11, DESIGN §8, 14.3, 14.6, 14.8 y 14.11, y el informe anterior. Se revisó archivo por archivo el diff de las **10 rutas** de `lib/`, `test/` y `tool/`. El diff completo y el catálogo con huellas están en `diff-base.patch` y `revision-codigo.json`.
- Banco nuevo desde el árbol: **`%TEMP%\t117-codex-c1-916bf2b\copia`**, namespace **`t117c1codex`**. Las **541 fuentes** de `lib/`, `test/` y `tool/` coinciden por SHA-256 con qa-r4. Las adaptaciones del copiador T-99 —identidad Android y assets sintéticos— quedan en la copia TEMP.
- Evidencia propia: **`C:\Proyectos\baystream-qa-r4\build\t117-entrega1-reaceptacion\`**. Las rutas de evidencia siguientes son relativas a ella. `resumen.json` contiene los resultados y `manifest.json` las huellas SHA-256, incluida la del informe; el manifiesto se excluye de su propia huella.
- Datos exclusivos: T100_LLEGADA, T100_CARGA y T99_SINTETICO_977, tomados de los sintéticos de mi aceptación anterior. No se utilizó el corpus ni se abrió el Honor. No se repitió RNF-002, conforme al alcance solicitado.

## Hallazgos

### H4 · P2 — Acciones solo con ícono carece de nombre accesible en Windows

**Reproducción:** abrir el plano en Windows, letra 1.0, sin panel fijo, a **700 dp** de cliente. Elegir Contenido o Descarga. «Acciones» queda solo con ⋮. Consultar el árbol accesible sin el tooltip desplegado y compararlo con la variante de 600 dp que conserva el rótulo.

**Resultado:** el control con ícono desaparece del árbol accesible de Windows como acción con nombre. En widgets, el nodo tiene **`label: ""`, `tooltip: "Acciones"`, `esBoton: false`, `accionTap: true`**. A 600 dp, con texto, el árbol sí contiene «Acciones». El mouse puede mostrar correctamente el tooltip y operar el menú; eso no satisface el nombre para el lector de pantalla pedido en esta reaceptación.

**Esperado:** que la variante con ícono conserve el nombre accesible «Acciones» y se exponga como control operable. **Prioridad P2:** el planificador que usa accesibilidad pierde la identificación del acceso a las acciones, y este criterio fue solicitado expresamente.

**Evidencia propia:**

- `nombre_acciones_test.dart`, `nombre-acciones.jsonl`, `nombre-acciones-exit.txt`: **una prueba roja**, sin omitidas, que exige el nombre además del tooltip. `nombre-acciones.json` guarda los datos semánticos completos.
- `windows-real/18-h3-700-semantica.json` y `.png`: árbol completo a 700 dp, sin «Acciones»; el ícono se ve en la captura.
- `windows-real/24-600-acciones-con-rotulo.json` y `.png`: comparación con el rótulo presente y anunciado.
- `windows-real/25-700-acciones-tooltip.png`: demuestra que el tooltip sí existe.
- Contraste de clientes: `web-semantica/acciones-ax.json` sí contiene un **button** cuyo nombre calculado por Chrome es **Acciones**. No se atribuye el defecto de Windows a la Web.

**Causa contrastada:** `_PlanActions`, en `lib/features/vessel/presentation/widgets/loading_plan_controls.dart:495`, elimina el `Text` en la variante con ícono; el `PopupMenuButton` de la línea 505 tiene `tooltip`, pero su hijo personalizado no añade el nombre ni el rol de botón. La corrección conecta esta variante con `accionesSoloIcono`.

El motor exacto del SDK utilizado distingue ambos campos: toma el nombre de `label` y transmite `tooltip` por separado; además, la combinación de nodo de texto sin etiqueta que produce este control puede quedar ignorada. Se contrastó con el [código oficial del motor correspondiente a Flutter 3.38.9](https://github.com/flutter/flutter/blob/67323de285b00232883f53b84095eb72be97d35c/engine/src/flutter/shell/platform/common/accessibility_bridge.cc#L335). Esta explicación concuerda con la ausencia observada en Windows. No se ejecutó Narrador ni NVDA: la comprobación nativa es del árbol accesible exportado.

### O1 · P3 — Menos rejilla inicial a 800 × 600, letra 2.0, Contenido

**Reproducción:** misma entrada y disposición de la matriz anterior, 800 × 600, letra 2.0, Contenido; comparar con `f60d2a8`. Ocurre en los tres estados de panel solicitados, que a ese ancho se adaptan a oculto o flotante.

**Resultado:** la franja pasa de **126 a 178 dp** y el espacio inicial calculado de rejilla baja de **102,6 a 50,6 dp**. Es un empeoramiento de espacio inicial de **52 dp**, que no procede de la tolerancia numérica: corresponde al nuevo reparto de la variante que envuelve.

**Prioridad P3, no bloqueante por sí sola.** Se puede desplazar la columna o plegar el puente para trabajar; la leyenda y los controles siguen accesibles, sin un recorte definitivo. Es el coste de conservar el botón en la primera línea y hacer envolver el contenido. No se presenta como ausencia de cambios de tamaño.

**Evidencia:** `pruebas-resumen.json`, apartado `comparacion_matriz`, y `matriz/medidas.json`; capturas `matriz/800x600-2.0-content-*-leyenda.png`. Las 90 combinaciones comprobaron textos y límites con las fuentes reales.

## H1 — Cerrar conserva oculto; Fijar y el botón sin flotante funcionan

**PASA.** Mis pruebas abren el flotante por una celda y por hover del mouse. «Cerrar el panel lateral» lo cierra, limpia la selección cuando corresponde y conserva `oculto`; luego se ejercitan mostrar/ocultar el fijo y «Fijar». Evidencia: `foco_hallazgos_test.dart` y las filas H1 de `foco-hallazgos.json`.

En Windows nativo se repitió por celda y por el borde. El botón de cabecera cerró sin fijar, el botón sin flotante mostró y ocultó el fijo, y «Fijar» dejó el panel fijo. Capturas **10–17** de `windows-real/`.

**Persistencia nativa:** después de ambos cierres, el panel quedó oculto. Se cerró el proceso **15064**, se verificó su salida y se reabrió mediante **explorer.exe**, proceso **26636**. Al entrar al reciente continuó oculto (`14-reabierto-panel-oculto.png`). Almacén utilizado:

`C:\Users\Giova\AppData\Local\Temp\t117-codex-c1-916bf2b\store-windows`

Caja `t117c1codex_settings.hive`, namespace propio; constancia y huella con la app cerrada en `windows-real/persistencia-h1.json`. No se utilizó el almacén de la app instalada.

## H2 — Atrás, Esc y foco

**PASA en los recorridos solicitados del modo.**

| Cliente y apertura | Cierre y foco observado |
|---|---|
| Windows, mouse | Esc cierra. No fuerza el foco al botón: la herramienta informa panel/scope sin control rotulado. El primer Tab alcanza el modo. |
| Windows, teclado | Tab e Intro abren el modo; Esc cierra y el foco funcional vuelve al botón: **Intro reabre el mismo menú**. Tras cerrar, **Tab pasa a Buscar contenedor**, cuyo foco sí anuncia Windows. |
| Web, mouse, claro y oscuro | Esc cierra. El DOM queda en `flutter-view`/scope; no se fuerza el retorno. El primer Tab permite abrir el modo con Intro. |
| Web, teclado, claro y oscuro | Esc devuelve el foco funcional al modo; **Intro reabre el mismo menú** y **Tab siguiente enfoca Buscar contenedor**. |
| Android, toque, claro y oscuro | Al abrir, la entrada Descarga aparece enfocada. Atrás cierra; solo queda la raíz sin rótulo marcada con foco, sin sombreado en el botón del modo. No se fuerza el foco al botón. |

**Limitación de observación del foco:** el `Semantics` del selector excluye el foco del botón hijo, así que Windows puede informar solo panel/scope y Chrome conservar `activeElement = flutter-view` aun cuando Flutter haya enfocado el botón. Las filas `vuelveAlBoton: false` de la primera sonda DOM **no son un fallo de retorno**: se resolvió con la prueba de conducta de Intro y Tab y con las capturas. La prueba propia de widgets también comprueba que, abierto mediante Tab e Intro, tras Esc el foco está dentro del botón.

Windows: `windows-real/02` a `09`; `08-intro-reabre-desde-foco-devuelto.png` y `09-tab-siguiente-buscar.png` documentan esa secuencia. «Colorear por» también se abrió con mouse y cerró con Esc a 700 dp (`19-colorear-mouse-esc.png`).

Web: banco propio compilado, **Chrome visible**, perfil TEMP exclusivo `chrome-perfil-4`, servido en **`http://127.0.0.1:5879/`**. `web_c1.py` conserva el recorrido; `web-verificada/` contiene capturas claras/oscuras y `recorrido.json`, sin errores de página registrados, salida 0. «Colorear por» abierto con mouse también cierra con Esc. Chrome y servidor propios quedaron cerrados.

Android: **solo `adb -s emulator-5554`**, AVD `t99_api26`, Android 8/API 26, 1080 × 1920 a 480 DPI existentes; paquete exclusivo **`gt.cmartinez.baystream.t117c1codex`**. El recorrido independiente `android_h2.py` y las capturas `android/h2-*` comprueban en ambos temas:

1. El menú se abre.
2. El primer Atrás lo cierra, **no muestra advertencia** y conserva el plano.
3. El siguiente Atrás es el primero del doble Atrás: **advierte y conserva el plano**.

Los seis estados están en `android/h2-registro.json`. En este teléfono de 360 dp, «Colorear por» no usa ese menú: se presenta mediante las fichas/controles de la leyenda, por lo que no aplica el recorrido condicionado de Atrás sobre ese menú. Al finalizar se restauró `night no`, se retiró solo el paquete propio y se cerró el emulador; constancias en `android/`.

## H3 — Distribución de la franja y ventana real

**La geometría pasa; el nombre accesible queda pendiente en H4.**

- A **700 dp, letra 1.0**, Contenido y Descarga miden **56 dp**, sin panel fijo y con el botón del puente en la misma línea. «Acciones» queda con su ícono.
- Carga a 700 y los tres modos a **600 dp** envuelven; el botón permanece al final de la primera línea. Mis casos propios también cubren 600/700 con letra **2.0**, sin desbordes ni textos cortados. Los datos y las capturas están en `foco-hallazgos.json` y `matriz/h3-*`.
- En **Windows nativo** se arrastró el borde hasta clientes exactos de **700 × 682,4** y **600 × 682,4 dp**, a **120 DPI**: 875 y 750 píxeles de ancho. Se miraron los tres modos a ambos anchos. Evidencia: `windows-real/h3-700-contenido.*`, `20-h3-700-descarga.png`, `21-h3-700-carga-envuelve-boton-arriba.png`, `h3-600-carga.*`, y capturas 22–24.
- El arrastre del control de escritorio no cambió el tamaño del marco. Se empleó el script autorizado, limitado al HWND y EXE del banco; sus registros incluyen PID, dimensiones reales y `alFrente: true`. La captura del tooltip se hizo también moviendo el mouse exclusivamente sobre ese cliente.

## Matriz, tolerancia y regresión

Se repitió la matriz propia anterior: **5 tamaños × 2 letras × 3 modos × 3 paneles = 90 combinaciones**, más las dos pruebas extra. Fuentes reales IBM Plex Sans/Condensed/Mono, Roboto e iconos; entrada real sintética T100_LLEGADA, parser del producto. Se reutilizó el soporte de montaje/carga de fuentes; las comprobaciones y acciones son de Codex.

| Tamaños | Letras | Modos | Paneles solicitados |
|---|---|---|---|
| 1920 × 1000; 1536 × 793; 1366 × 690; 960 × 1000; 800 × 600 | 1.0 y 2.0 | Contenido, Descarga, Carga | fijo, oculto, flotante |

Por debajo de 1200 dp no existe un fijo visible: la prueba verifica su adaptación a oculto y lo distingue con `panelFijoReal`.

**92/92 pasan**, sin omitidas. Los dos casos de **800 × 600, letra 2.0, Descarga, fijo solicitado y oculto** ahora cierran el menú con **Esc**, comprueban que ya no quedan entradas y ejecutan **Deshacer** del aviso. No se sustituyó Esc por elegir una opción. Registro original: las pruebas de matriz dentro de `propias-v0.jsonl`; resumen separado en `pruebas-resumen.json`.

**Efecto aislado de la tolerancia:** se leyeron los anchos intrínsecos de las variantes finales y se comparó su elección efectiva con la que resultaría de permitir medio dp, sin cambiar código. Hay **tres cambios equivalentes**, a **960 × 1000, letra 2.0, Descarga**, uno por estado de panel solicitado. Una variante mide **766,5800 dp** para **766,4960 disponibles**: excede **0,0840 dp**. Con medio dp se habría elegido el índice 3; con la tolerancia de RenderFlex se elige el 4, que envuelve. **No cambia ninguna elección de cabecera por este motivo**, y no aparece un desborde nuevo. La franja de esos casos sigue midiendo 126 dp.

La comparación geométrica completa también está registrada: tres casos ganan 70 dp de rejilla inicial, otros tres de Carga a 800/1.0 ganan 52 dp, y los tres de Contenido a 800/2.0 pierden 52 dp, descritos en O1. Por tanto, no sería correcto decir que nada cambia o que todo gana espacio.

## Suite, análisis e incidencias del banco

| Validación | Resultado propio |
|---|---|
| Suite completa, una ejecución | **1677 aprobadas, 0 fallidas, 0 omitidas**, 107,237 s; piso 1629 |
| Análisis de la copia limpia | **0 incidencias**, salida 0, 33,1 s |
| Matriz anterior y dos extras | **92/92** |
| Pruebas propias de H1, foco, geometría y tooltip | **16/16** finales |
| Prueba específica de nombre accesible H4 | **0/1**, roja |

Logs: `suite.jsonl`, `suite-exit.txt`, `analyze-banco.txt`, `propias-v0.jsonl`, `foco-hallazgos.jsonl`, `nombre-acciones.jsonl`. No se volvió a correr la suite completa ni se usó `flutter test --platform chrome`.

Se conservan los intentos del instrumento: en `propias-v0` la matriz pasó y **dos comprobaciones de etiqueta de Acciones ya detectaron H4**; no se descartan como falsos positivos. Las versiones v1/v2 del instrumento de semántica tuvieron un error de liberación de `SemanticsHandle`, corregido únicamente bajo `build/`. Las 16 pruebas finales validan geometría, interacción y tooltip; la prueba adicional exige el nombre que faltaba y sigue roja.

Windows y Web compilaron en cero. La primera compilación Android con `--no-pub` encontró un `GeneratedPluginRegistrant` de la copia que incluía `integration_test`; la compilación normal regeneró el archivo y produjo el APK en cero, sin editar código del producto. Ambos logs se conservan. El lector inicial de Web buscaba solo `aria-label`; se corrigió para contemplar `textContent`. El ayudante de servidor dejó un proceso hijo en Windows; se cerró solo el proceso propio verificado y el recorrido válido usó un servidor con cierre directo. Antes del recorrido nativo válido también se cerraron dos lanzamientos duplicados del banco propio; la prueba de persistencia sí usa un único proceso antes y otro después.

`banco.json` conserva el literal `.t99` del copiador; la identidad real instalada fue **`.t117c1codex`**. Las compilaciones, el banco y las huellas de binarios están descritos en `resumen.json`.

## Integridad y entrega

Las **624 huellas iniciales** siguen intactas. No hay fuentes nuevas fuera de la evidencia; las 541 fuentes del banco coinciden con el árbol. `domain/`, `data/`, **`pubspec.yaml` y `pubspec.lock`**, `lib/main.dart`, los congelados y `docs/piloto/LISTA-PILOTO.md` no cambian contra `f60d2a8`. No hay `// ignore:` en `lib/`, `test/` ni `tool/`. `git diff --stat` no muestra cambios de contenido; solo advierte de la normalización de fin de línea de tres generados de Windows.

Archivos escritos: **`docs/t117/entrega1/reaceptacion-codex.md`** y los archivos propios enumerados en **`build/t117-entrega1-reaceptacion/manifest.json`**. El producto permanece intacto. No se hicieron escrituras de Git ni publicaciones. **El informe no se añade a Git; Carlos lo mueve al rediseño.**

## Mensaje para Yov

Yov: la corrección 1 **NO PASA** por H4, P2: «Acciones» con ícono pierde nombre y presencia en el árbol accesible de Windows a 700 dp; el tooltip sí existe y Chrome sí anuncia el botón. H1, H2 y la geometría de H3 pasan, incluida persistencia nativa, foco con teclado, Android claro/oscuro y matriz 92/92. Suite única 1677/1677, analyze cero en copia limpia. O1, P3: Contenido a 800/2.0 pierde 52 dp iniciales, pero sigue utilizable con scroll/plegado. Producto intacto; evidencia propia y SHA-256 listos.

ALTO: Carlos decide
