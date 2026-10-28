# NO PASA — Aceptación de la entrega 1 de T-117 y T-118

Capitán Codex · 24–25 de octubre de 2026 · Sprint 4, decisiones 10.36–10.41.

La entrega tiene dos defectos P2: el botón que anuncia cerrar el panel lateral lo fija y cambia la preferencia; el menú de modo no consume Atrás en Android. Hay además un P3 de aprovechamiento del espacio a 700 dp. No se corrigió el producto. Carlos decide el siguiente paso.

## Candidata, alcance y custodia

- Árbol: `C:\Proyectos\baystream-qa-r4`, HEAD separado `f60d2a858544a318b2658881f6aab41c728be260`. `git log --oneline -3`: `f60d2a8`, `ccf300d`, `096b8dc`. Base: `cc24766`.
- Se leyeron AGENTS completo, las decisiones 10.36–10.41, DESIGN §14, fase 0 y E1.1–E1.13 de `docs/T117-T121-RESULTADOS.md`. Se revisaron individualmente los 45 archivos del diff de `lib/`, `test/` y `tool/`; catálogo y huellas en `revision-codigo.json`, diff íntegro en `diff-base.patch`.
- Se consultó, sin modificar, la evidencia de Timonel en `C:\Proyectos\baystream-rediseno\docs\t117\entrega1\`, incluida `ventana-real/06-borde-875px.png`. Los resultados que siguen son de Codex; no se suman a los de Timonel.
- Evidencia propia: `C:\Proyectos\baystream-qa-r4\build\t117-entrega1-aceptacion\`. Las rutas de evidencia citadas debajo son relativas a esa carpeta. `resumen.json` contiene los resultados estructurados; `manifest.json` enumera los SHA-256 de los archivos y del informe. El manifiesto se excluye de su propia huella.
- Banco propio desde el árbol: `%TEMP%\t117-codex-f60d2a8\copia`. Se usó el copiador T-99 con `-Arbol -Sufijo t117codex`; la copia del script sustituye la consulta del commit por el HEAD comprobado. No se usó ni borró `%TEMP%\t99-r4-e1`.
- Las 539 fuentes de `lib/`, `test/` y `tool/` de la copia coinciden por SHA-256 con qa-r4. Las adaptaciones de identidad Android y assets sintéticos del copiador están solamente en TEMP. `banco.json` conserva un literal antiguo que dice `.t99`: la identidad efectiva instalada y comprobada fue **`gt.cmartinez.baystream.t117codex`**, rótulo **BayStream T117CODEX**.
- Solo datos sintéticos: `T100_LLEGADA`, `T100_CARGA` y `T99_SINTETICO_977`; nombres, tamaños y huellas en `banco.json`. No se abrió el Honor ni el corpus, ni se publicó. Las capturas muestran el banco; no se capturó «Nube y cuenta».

## Hallazgos

### H1 · P2 — «Cerrar el panel lateral» lo fija y guarda «visible»

**Reproducción:** abrir un plano a 1536 × 793, ocultar el panel lateral y seleccionar una celda ocupada. Se abre el detalle flotante y el botón de la cabecera anuncia «Cerrar el panel lateral». Pulsarlo.

**Resultado:** desaparece el flotante, aparece el panel fijo y la preferencia queda en `visible`. El planificador pierde ancho y cambia su disposición guardada al pedir cerrar. **Esperado:** cerrar el flotante conservando el panel oculto. La X interna del flotante permite cerrar como alternativa.

**Evidencia propia:** `cerrar_panel_test.dart`, `cerrar-panel.jsonl` y `cerrar-panel-exit.txt` (una prueba deliberadamente roja); `matriz/cerrar-panel-antes.png`, `matriz/cerrar-panel-despues.png` y `matriz/cerrar-panel.json`. Este último registra `rotuloAntes: Cerrar el panel lateral`, `panelFijoDespues: true`, `flotanteDespues: false`, `preferenciaDespues: visible`.

**Código:** `lib/features/vessel/presentation/pages/vessel_overview_page.dart`, líneas 364–382. Con ancho para panel fijo, la acción ejecuta `mostrarPanel(!panelFijo)` incluso cuando el rótulo anuncia cerrar el flotante. Prioridad P2 por comportamiento contrario a la acción anunciada y persistencia del cambio. Reproducción automatizada con widgets reales; no se presenta como una captura nativa.

### H2 · P2 — Atrás no cierra el menú del modo en Android

**Reproducción:** en `emulator-5554`, abrir T100_LLEGADA, entrar al plano en Descarga y abrir su menú de modo. Pulsar Atrás del sistema. Pulsar dos veces seguidas desde ese menú para comprobar la salida.

**Resultado:** la primera pulsación deja el menú abierto y muestra «Toca Atrás otra vez para volver al inicio»; dos pulsaciones devuelven al inicio. **Esperado:** el primer Atrás cierra el menú y mantiene el plano. El menú de «Acciones» sí se cierra con Atrás en la misma sesión. Elegir de nuevo el modo vigente cierra el menú como alternativa.

**Evidencia nativa:** `android/11-claro-menu-descarga.png` y `android/12-claro-menu-cerrado.png`; pese al nombre de la segunda captura, la imagen demuestra que **no** se cerró. `android/22-oscuro-menu-antes-de-atras.png` y `android/23-doble-atras-sale-al-inicio.png` muestran el menú oscuro y la salida al inicio; las acciones exactas están en `android/acciones.jsonl`. Comparación con Acciones: imágenes 07–08 y 18–19.

**Código relacionado:** `lib/core/design/componentes/bs_selector_de_modo.dart:184` usa `MenuAnchor` sin integrarlo en el registro de elementos cerrables; `lib/features/vessel/presentation/widgets/navegacion_del_viaje.dart:225` consulta ese registro antes de iniciar el doble Atrás. Prioridad P2: un gesto habitual para cerrar un menú inicia la salida del contexto de trabajo.

También se observó que Escape no cerró el menú en el recorrido de widgets; esto dejó el menú encima de «Deshacer» en dos casos de la matriz. DESIGN §14.6 exige Esc. La prueba nativa de Android es suficiente para H2; no se afirma aquí una cobertura exhaustiva de todos los estados de foco del teclado de escritorio.

### H3 · P3 — El botón de plegar el puente queda solo a 700 dp

**Reproducción:** ventana de oficina a 700 dp de ancho, letra 1.0, Contenido y sin panel lateral fijo. Observar la franja de la bahía.

**Resultado:** el botón del puente queda aislado en una segunda línea. La franja mide 108 dp frente a 56 en una línea: consume 52 dp adicionales. No se corta ni se superpone; plegar sigue funcionando. Es un defecto menor de distribución, **P3**, porque desperdicia espacio en una tarea cuyo objetivo es recuperar plano, pero permite trabajar.

**Evidencia:** `windows-real/borde-700.png` y `.json` (875 píxeles de cliente a 120 DPI = 700 dp); `matriz/700-inicial.png`, `matriz/700-plegado.png` y fila `700-observacion` de `matriz/medidas.json`. Coincide con la observación de Yov. Código relacionado: el reparto por `Wrap` de `franjas_del_plano.dart`.

## Suite y análisis

| Comprobación | Resultado propio | Evidencia |
|---|---|---|
| Suite completa, una sola ejecución | **1629 aprobadas, 0 fallidas, 0 omitidas**, 153,9 s; supera el piso 1371 | `suite.jsonl`, `suite-exit.txt` |
| `flutter analyze --no-pub` en qa-r4 | Salida 1: **33 incidencias, todas bajo `build/`** | `analyze.txt`, `analyze-exit.txt` |
| `flutter analyze --no-pub` en la copia limpia de compilación | **0 incidencias**, salida 0, 16,7 s | `analyze-banco.txt`, `analyze-banco-exit.txt` |

La ejecución en qa-r4 encontró 32 incidencias en evidencias anteriores y un import sin uso en la primera versión del instrumento propio. El import se retiró solo del instrumento. No se borraron ni corrigieron los artefactos ajenos. Por tanto, el cero acreditado corresponde a la copia limpia con las mismas fuentes del producto; **no se afirma que el comando en qa-r4 devolviera cero**. No se volvió a correr la suite completa ni se usó `flutter test --platform chrome`.

## Matriz independiente y lectura del plano

Se escribió `matriz_codex_test.dart`, con el parser real de T100_LLEGADA y las fuentes IBM Plex Sans, Condensed, Mono, Roboto e iconos del producto. Se reutilizó el soporte de montaje y carga de fuentes de T-117; las acciones y aserciones de aceptación son propias.

| Tamaño lógico | Letras | Modos | Panel solicitado | Casos |
|---|---|---|---|---:|
| 1920 × 1000 | 1.0 y 2.0 | Contenido, Descarga, Carga | fijo, oculto, flotante | 18 |
| 1536 × 793 | 1.0 y 2.0 | los tres | los tres | 18 |
| 1366 × 690 | 1.0 y 2.0 | los tres | los tres | 18 |
| 960 × 1000 | 1.0 y 2.0 | los tres | los tres | 18 |
| 800 × 600 | 1.0 y 2.0 | los tres | los tres | 18 |

Son cinco tamaños de 0.5.5, incluidos los tres exigidos. Por debajo de 1200 dp el producto no ofrece panel fijo: se comprobó que esa preferencia se adapta a oculto. `panelFijoReal` lo distingue en cada fila; no se cuenta como un fijo visible inexistente.

Las **90 combinaciones** completaron las medidas y las comprobaciones de textos y límites anteriores a la interacción con avisos. El resultado bruto de `matriz.jsonl` es **90 pruebas aprobadas y 2 fallidas de 92**: 88 recorridos de matriz aprobados, dos fallidos y dos pruebas adicionales aprobadas. Los dos fallos son 800 × 600, letra 2.0, Descarga, panel solicitado fijo y oculto: el menú que Escape no cerró interceptó el toque en Deshacer. No se ocultan ni se convierten en aprobados.

Para separar O3 del cierre del menú se añadió `aviso800_test.dart`: selecciona explícitamente Descarga para cerrar, comprueba que ya no quedan entradas de menú y genera el aviso por el mecanismo real. **Pasa:** aviso dentro de la franja y la columna, Deshacer alcanzable y acción ejecutada. Evidencia: `aviso800.jsonl`, salida 0 y `matriz/800x600-2.0-descarga-aviso.png`. La versión inicial del arnés, con expectativas erróneas sobre un espacio no separable y el gesto de arrastre, se conserva como `matriz-instrumento-v0*`; no es una repetición de la suite del producto.

Resultados de T-117/T-118, con las salvedades H1–H3:

- **Tres alturas:** botón, arrastre del borde, doble clic y teclado ejercitados por la prueba propia. Se alcanzaron completo, compacto y plegado. Doble clic y persistencia se comprobaron además en Windows nativo. La cobertura de arrastre del puente y teclado se acredita con widgets; el arrastre nativo medido es el del borde de la ventana.
- **Columna completa:** al desplazarla suben puente y franja de bahía cuando corresponde; se llega a la leyenda. A 1920, con panel fijo, la leyenda queda dentro de la columna, atendiendo la queja que abrió T-117. Evidencia: capturas `matriz/1920x1000-1.0-*-fijo-leyenda.png`.
- **Lateral:** fijo, oculto, flotante por mouse y detalle flotante comprobados. El flotante permanece mientras el mouse está dentro, se recoge al salir y no invade la franja de cifras. El defecto H1 afecta al botón de cabecera cuando el flotante está abierto.
- **Bahía y cifras:** con panel fijo real y letra 1.0, la franja mide 56 dp en los tres modos a 1920, 1536 y 1366. Las cifras de bahía son la primera ficha del pie. Se comprobó un solo selector de modo y sus entradas legibles también abiertas; «Colorear por» sigue siendo un control distinto.
- **Idioma y tema:** textos del recorrido en español, sin emojis añadidos; componentes usan los colores del tema y la paleta de diseño. Las fichas envuelven según DESIGN §14.7, sin convertir el contenido completo en elipsis en oficina. Se revisaron capturas claras y oscuras, además de geometría automatizada.

### ¿Se puede trabajar a 800 × 600?

**Sí, con desplazamiento y plegado del puente.** Los 24 dp perdidos por pasar de 64 a 88 dp son aceptables y no constituyen por sí solos un defecto bloqueante. La altura depende del contenido: en esta matriz a letra 1.0, el pie mide 64 dp en Contenido, 109 en Descarga y 88 en Carga; el espacio inicial calculado de rejilla es 302,8, 257,8 y 226,8 dp respectivamente. No debe generalizarse «siempre dos líneas».

La Web con T100_CARGA real muestra 30 pendientes y una línea adicional de aviso de listado; sigue siendo legible y permite operar y desplazarse (`web/800x600-light-carga.png`). A letra 2.0 puede quedar apenas 1,6 dp de rejilla en la composición inicial de Carga: exige desplazar la columna o plegar el puente. La columna sí permite llegar al plano y a la leyenda, sin recortar definitivamente el contenido (`matriz/800x600-2.0-loading-oculto-leyenda.png`). Se acepta como adaptación de accesibilidad, no como una vista completa simultánea.

## Bancos nativos

### Windows

Compilación propia `flutter build windows --release --no-pub -t tool/t99_main.dart`, con `T99_ALMACEN` apuntando a `%TEMP%\t117-codex-f60d2a8\store-windows` y `T99_NAMESPACE=t117codex`. Salida 0; log `build-windows.txt`. SHA-256 del EXE: `62064001d1a4524dd4e4fdd5322bc659991b3a857afc580f8e8ae79928d0ce80`.

Se abrió con **explorer.exe**. El almacén fue **`C:\Users\Giova\AppData\Local\Temp\t117-codex-f60d2a8\store-windows`**, caja de ajustes `t117codex_settings.hive`; no el almacén de la app instalada ni una copia virtualizada de BayStream.

Se verificó el hover inicialmente encendido, se dejó puente plegado, panel oculto y hover apagado, se cerró el proceso y se volvió a abrir mediante Explorer. **Las tres preferencias sobrevivieron.** Evidencia: `preferencias.json`, `preferencias-huella-cierre.json` y capturas 10–14 de `windows-real/`.

Ventana maximizada, Win + izquierda y derecha, y arrastre real del borde hasta **1000, 700, 560 y 1280 dp**, con cliente medido a 120 DPI. Los JSON de `windows-real/borde-*.json` incluyen dimensiones, PID, EXE y `alFrente: true`. Para el borde exterior, el control de escritorio no alcanzó el marco; se utilizó el script autorizado, restringido a la ventana del EXE propio. No se simuló el arrastre cambiando solo MediaQuery. No se probó cambio entre monitores.

El conductor nativo produjo además ocho capturas claras/oscuras, sin textos fuera de medida, errores Flutter ni esperas vencidas (`windows-conductor/`, `windows-inicial.txt`).

### RNF-002

Instrumento de la familia T-98/T-99: `tool/t114_primera_windows.py`, con la corrección de primer plano de 10.41. Se anunciaron **SEMÁFORO:** de inicio y fin; no se compiló ni ejecutó la suite durante la medición. Datos: T99_SINTETICO_977; cinco aperturas independientes.

| Repetición | Hasta rejilla | Pasos | alFrente | Válida |
|---:|---:|---:|---|---|
| 1 | 3,497 s | 3 | true | sí |
| 2 | 2,629 s | 3 | true | sí |
| 3 | 2,799 s | 3 | true | sí |
| 4 | 2,709 s | 3 | true | sí |
| 5 | 4,712 s | 3 | true | sí |

**5/5 válidas**, sin reintentos de clic; mediana **2,799 s**, incertidumbre del instrumento 0,05 s, todas bajo 30 s. Los registros originales y capturas están en `rnf002/sin01` a `sin05`. Una invocación previa con ruta que Explorer no abrió terminó por espera, sin generar mediciones; queda en `rnf002-ejecucion.txt` y no forma parte de estas cinco.

### Web

Compilación propia de `tool/t99_main.dart`, salida 0, servidor en **`http://127.0.0.1:5877/`**, Chrome visible con perfil exclusivo `%TEMP%\t117-codex-f60d2a8\chrome-perfil`. `web_codex.py` conserva el recorrido. Se cargaron T100_CARGA y T100_LLEGADA: 30 pendientes de carga (20 llenos, 10 vacíos) y 30 de descarga.

Se comprobaron Contenido, Descarga y Carga a 1920 × 1000, 1366 × 690 y 800 × 600, claro y oscuro; segmentos, menú abierto y flotante activado por el mouse real del navegador en el borde. **40 capturas, sin errores de página registrados**, salida 0 (`web/recorrido.json`, `web-ejecucion.txt`). Chrome y servidor propios quedaron cerrados.

### Android

APK release propio, salida 0; únicamente **`adb -s emulator-5554`**, AVD `t99_api26`, Android 8/API 26, 1080 × 1920 píxeles, override de densidad existente 480 DPI. No se cambió la densidad ni se usó el Honor. Se instaló el paquete exclusivo del banco; tras restaurarse el snapshot del emulador hubo que reinstalar ese mismo paquete.

Se miraron menú abierto, Acciones y resumen recogido/expandido en **claro y oscuro**, en Contenido, Descarga y Carga. Menús y fichas son legibles; el resumen recogido conserva el comportamiento de una línea de T-107 y al expandir permite leer los datos. Las opciones Descarga/Carga de la banda operativa y el menú que contiene el modo vigente corresponden a DESIGN §14.6; no se contabilizan como duplicación accidental.

Aquí se usó llegada con 30 por descargar y **Carga sin pendientes**; la carga con 30 pendientes se comprobó en Web, no se atribuye a Android. H2 es el defecto encontrado al usar Atrás. Evidencia visual: `android/04` a `23` y `acciones.jsonl`. `03-reinicio.png` es el launcher después de restaurar el snapshot y no valida producto.

Al terminar se restauró `night no`, se detuvo y desinstaló solamente `gt.cmartinez.baystream.t117codex`, y se cerró el emulador; constancias en `android/tema-sistema-restaurado.txt`, `retirada-banco.txt` y `cierre-emulador.txt`.

## Reglas e integridad final

`domain/` y `data/` cambian exactamente **31 líneas añadidas**, 0 eliminadas, en los tres archivos autorizados: enum/repositorio (11), implementación (8), datasource Hive (12). `pubspec.yaml`, `pubspec.lock`, `lib/main.dart` y los dos congelados no cambian contra la base. No hay `// ignore:` en `lib/`, `test/` ni `tool/`.

**Salvedad documental:** `docs/piloto/LISTA-PILOTO.md` sí difiere contra `cc24766` (+28/−14), por los commits documentales anteriores `38965b8` (10.34) y `fddcc95` (10.35). No tiene diferencias desde `430fa29`, antes de entrega 1. No lo cambió esta entrega ni esta aceptación. No sería correcto afirmar que coincide literalmente con la base solicitada.

Las **621 huellas iniciales** de fuentes, plataformas y archivos protegidos coinciden al cierre (`arbol-inicial.json`, `arbol-final.json`: lista vacía). `git diff --stat` no mostró cambios de contenido; emitió únicamente avisos de normalización de fin de línea de los tres generados de Windows. La comparación adicional de 539 fuentes entre árbol y banco dio cero diferencias.

Entregables escritos: este informe, `docs/t117/entrega1/aceptacion-codex.md`, y los archivos propios enumerados en `build/t117-entrega1-aceptacion/manifest.json`. No se modificó código del producto, pruebas de `test/`, instrumentos de `tool/`, dependencias ni documentos ajenos. No se ejecutaron operaciones de escritura de Git. **El informe no se añade a Git; Carlos lo copia al rediseño.**

## Mensaje para Yov

Yov: entrega 1 **NO PASA** por dos P2: «Cerrar el panel lateral» fija el panel y guarda visible; Atrás con el menú de modo abierto en Android inicia la salida en vez de cerrarlo. El botón aislado a 700 dp es P3. A 800 × 600 se puede trabajar con scroll/plegado. Suite 1629/1629, cero omitidas; analyze cero en copia limpia, con la salvedad de artefactos en build de qa-r4; RNF-002 5/5, mediana 2,799 s, todos al frente. Producto intacto; informe y evidencia propia con SHA-256 listos para Carlos.

ALTO: Carlos decide
