# T-100 · Parte A · El manual de usuario: cómo se hizo

Timonel · 20 y 21-oct-2026 · Base: `sprint3-cierre-2` (`33404a5`), decisiones 10.98 y
10.99. **Entregada para aceptación de Codex, sin commit.**

El entregable es `docs/MANUAL-USUARIO.md` con sus 103 capturas en `docs/manual/`. Este
informe dice sobre qué se escribió, con qué se capturó, qué se tocó en la máquina y qué
pasó, en las dos noches. No repite el manual.

## 1. Resultado

- **Los 14 capítulos y el anexo de la geometría a mano, escritos.** Cada procedimiento
  con captura se siguió en la app antes de escribirlo.
- **La escala completa, recorrida con capturas (10.99):** plano de llegada, descarga,
  re‑estiba, pendientes de descarga, plan de carga, listado de la agencia importado,
  carga por OR, vacíos del listado, avance de la operación, BAPLIE de salida y su
  comparación con la llegada. En Windows completa; en el Honor la descarga, los
  pendientes, el listado, la carga por OR y el selector con el micrófono.
- **103 capturas**: 70 de Windows (1920 × 991, la ventana maximizada sin la barra de
  tareas, a 125 %) y 33 del Honor X5d (360 × 800 dp). Todas con archivos sintéticos;
  ninguna con cuenta ni con «Nube y cuenta».
- **Lo que sigue en texto**, con la cita de su aceptación: arrastrar y las solicitudes
  (T-105 y T-106, con sesión) y el dictado (T-94, en el Honor). Lo que sigue sin
  recorrer está marcado en el manual y listado al final.
- **Hallazgos**: cinco, uno nuevo de usabilidad (la escala cambiada después de
  confirmar no crea la operación) y uno nuevo menor (el flotante tapa «Seleccionar
  archivo» con letra 1.45). Nada se corrigió (10.73).

## 2. La base

| Qué | Valor |
|---|---|
| Copia limpia | `%TEMP%\t100-33404a5-20oct\app`, `git archive` de `33404a5` (745 archivos, tar `15dc1e41…`), más `tool/t100_main.dart` superpuesto. `lib/` y `pubspec.*` idénticos al cierre (`preparacion.json`, `binarios.json`) |
| Entrada | `tool/t100_main.dart`: `BayStreamApp` de `lib/` sin tocar, almacenes `t100`, Firebase inicializado en una app aparte «t100» sin sesión; en Windows el almacén en `%TEMP%\…\store-windows` |
| Windows | `flutter build windows --release --no-pub`, 15 937 536 bytes, SHA-256 `079611fb…`; abierto con `explorer.exe` (PID 8388 la primera noche, 7516 la segunda; padre explorer) y cerrado por PID |
| Web | `flutter build web --release --no-web-resources-cdn`, `main.dart.js` 5 545 567 bytes, SHA-256 `3d180ada…`; servido en `127.0.0.1:8101` y abierto en el navegador integrado |
| Android | `flutter build apk --release` (sin `--no-pub`), 68 477 327 bytes, SHA-256 `d6b5792c…`, identidad `gt.cmartinez.baystream.t100`, rótulo «BayStream T100» |
| Archivos de prueba, noche 1 | `tool/t99_sintetico.dart` con 1600 y 600 contenedores (`%TEMP%\…\sinteticos*`, manifiestos con SHA) y `PRUEBA_T98.edi` de la copia de T-98 (solo leído). Para el listado que no cruza, `test/fixtures/t73_listado_sintetico_excel.xlsx` |
| Archivos de prueba, noche 2 | **La escala sintética del manual**, `tool/t100_sintetico.dart`: `T100_LLEGADA.edi` (8021 bytes, `9573cfd7…`) y `T100_CARGA.edi` (8009 bytes, `4acf7539…`) del buque «BUQUE MANUAL» (IMO sintético 9900552), viaje M100, escala GTSTC: 60 a bordo en la llegada (30 bajan, 30 de paso) y 30 cargas en el plan (20 llenos, 10 vacíos), con refrigerados y peligrosas; y `tool/t100_listado.py`: `T100_LISTADO.xlsx` (4555 bytes, `feb12a90…`) con los 30 OR en dos agencias, escrito con el escritor de `tool/t73_listado_sintetico.py` sin cambiarlo. Todo en `%TEMP%\…\sinteticos-manual\`, con `manifiesto.json` |

Nada del corpus en el manual ni en las capturas. `t99_sintetico.dart` usa
`CORPUS_A01.edi` como plantilla de estructura, como en T-99; `t100_sintetico.dart` no
usa el corpus: los segmentos son los de `tool/t98_support.dart`.

**La escala sintética se verifica sola** con el lector real y las reglas de la
operación (15 comprobaciones): 60 leídos en cada archivo, 30 descargas y 0 cargas en
GTSTC en la llegada, 30 cargas y 0 descargas en el plan, `LOC+61` leído como siguiente
puerto, tipo «plano de llegada» y «plan de carga» según `OperationSources.baplieKind`,
mismo buque y viaje, sin avisos del lector y geometría propuesta que cubre todo. Si
una falla, el script se detiene.

## 3. Cómo se capturó

- **Windows:** `tool/t100_windows.ps1` captura el cliente de la ventana por PID con
  `PrintWindow` (funciona aunque esté tapada) y es consciente del DPI, para que salgan
  los píxeles reales. La app se manejó con el control del escritorio (concedido para la
  ruta del exe de la copia) y, cuando hizo falta texto, con el mismo script.
- **Honor:** `adb exec-out screencap` para capturar; `uiautomator dump` para ubicar los
  botones por su etiqueta de accesibilidad y tocar por coordenadas. Letra del sistema en
  1.0, y en 1.45 solo para las tres capturas de letra grande; quedó en 1.0.
- **Web:** se abrió y se comprobó la pantalla de inicio en el navegador integrado; no
  hay capturas de la Web (la ficha pide Windows y teléfono).

## 4. Lo que pasó en la máquina (para Codex y para Yov)

**Noche 1 (20-oct):**

1. **La app `t98` de Codex en el Honor vino al frente dos veces.** La tecla «atrás» en
   la raíz de mi app la cierra, y Android muestra la app anterior, que era la `t98`. La
   primera vez, mi siguiente toque abrió su pantalla «Viajes recientes» (solo lectura) y
   volvió atrás; la segunda, no se tocó. No se registró ni cambió nada en ella; descarté
   la captura que la mostraba. Relancé la mía con `monkey` y dejé la de Codex como estaba.
2. **Un CSV exportado cayó en `test/fixtures`.** Al probar «Exportar viaje → CSV», el
   diálogo de guardar propuso la última carpeta usada y la ruta que escribí no entró: el
   archivo se guardó con el nombre propuesto en `test/fixtures/`. Lo moví a
   `%TEMP%\…\exportes\`; `test/` queda como en HEAD. Es de mi automatización, no del
   producto.
3. **La Web se compiló dos veces.** La primera, con `--no-pub --pwa-strategy=none`, salió
   sin `canvaskit/` ni `flutter.js`. La segunda, con la receta de `tool/t98_cierre2.py`,
   salió completa; es la que se usó. `binarios.json` lo anota.

**Noche 2 (21-oct, de 05:20 a 06:00):**

4. **Ningún toque en lo de Codex.** Su app `t98` del Honor estaba al frente al empezar y
   queda al frente al terminar, porque la mía se cerró; no se tocó. Su `baystream.exe`
   de Windows siguió abierto. El servidor `adb` arrancó de nuevo al primer comando («daemon
   not running; starting now»): alguien lo había detenido antes; no fui yo.
5. **La escala confirmada con el puerto equivocado en el Honor.** Mi toque a la ficha
   GTSTC no llegó y la app confirmó con PAMIT, el propuesto. Corregí la escala desde
   «Parámetros del buque» y el modo «Descarga» dijo «Esta escala todavía no tiene
   operación guardada…»: la operación quedó creada para PAMIT. Volví a abrir el archivo
   con GTSTC y seguí. Es el hallazgo 5 del manual. En el almacén `t100` del Honor queda
   una operación de PAMIT vacía.
6. **El selector de archivos del Honor** para el `.xlsx` abre en otra raíz que para el
   `.edi`; se llegó al listado por la búsqueda del selector. Sin consecuencias.
7. **Al terminar:** mi app de Windows cerrada por PID, mi app del Honor detenida y sus
   archivos borrados de `Download/t100`, letra en 1.0, modo avión en 0. No se levantó
   servidor Web esta noche. El paquete `gt.cmartinez.baystream.t100` queda instalado,
   como los de las aceptaciones anteriores. El BAPLIE de salida de prueba se guardó en
   `%TEMP%\…\exportes\`, no en el repositorio (el diálogo proponía `test/fixtures`).

## 5. Hallazgos

Los cinco del manual, aquí con su evidencia:

| # | Hallazgo | Evidencia | Estado |
|---|---|---|---|
| 1 | «Confirmar y ver el plano» abre la Lista, no el plano | Windows y Honor, en cada confirmación | Conocido (10.97, Sprint 4) |
| 2 | A 360 dp con letra 1.45, el botón flotante «Cargar BAPLIE» tapa parte de «Seleccionar archivo» en la pantalla de inicio | `docs/manual/h00-inicio-letra-grande.png` | Nuevo; menor (se puede cargar con el flotante) |
| 3 | A 360 dp la barra superior deja fuera «Parámetros», «Cargar archivo BAPLIE» y «Limpiar datos» sin señal de que hay más; en Windows, en «Plano», la lupa y «Exportar viaje» solo tras «Desplegar acciones» | `h06-lista.png`, `w05-plano-bahia02.png` | Diseño (T-91, T-97); el manual lo explica |
| 4 | Con letra 1.45 la línea de resumen del plano y la leyenda se cortan | `h05-plano-letra-grande.png` | Conocido (10.94) |
| 5 | Un plano de llegada propone como escala el puerto de salida; si se confirma así y se corrige después desde «Parámetros del buque», la operación del puerto correcto no existe hasta reabrir el archivo | Honor, sección 4.5 de este informe; el mensaje de la app lo dice | Nuevo; usabilidad. El manual lo explica en 4.3 |

## 6. Lo que no se pudo recorrer, y por qué

- **«Tipo de BAPLIE»**: aparece solo cuando un archivo tiene cargas y descargas en el
  mismo puerto; los sintéticos de la escala separan llegada y carga, así que no lo
  provocan. Queda descrito desde el código.
- **Arrastrar y solicitudes**: exigen cuenta (y operación publicada). Citadas las
  aceptaciones de T-105 y T-106.
- **El dictado**: el selector con el micrófono se capturó en el Honor; grabar exige el
  permiso del micrófono, que no se concedió. Citada la aceptación de T-94.
- **Avisos de lectura, homónimos, «La carga excede el perfil guardado», exportar en
  Android**: descritos desde los textos de la app.
- **A07 sin capturas**: no hizo falta; la escala sintética bastó para la descarga.

## 7. Archivos

**Nuevos:**
- `docs/MANUAL-USUARIO.md`;
- `docs/manual/*.png` (103);
- `docs/T100-RESULTADOS.md`, este informe;
- `tool/t100_main.dart`, `tool/t100_preparar.py`, `tool/t100_windows.ps1`,
  `tool/t100_sintetico.dart`, `tool/t100_listado.py`.

**No cambian:** `lib/`, `test/`, `pubspec.*`, `lib/main.dart`, los congelados, nada de
Codex. `tool/t100_sintetico.dart` importa dos funciones de `tool/t99_sintetico.dart`
y `tool/t100_listado.py` importa `tool/t73_listado_sintetico.py`; ninguno de los dos
se modifica.

## 8. Para la aceptación (Codex)

Tres procedimientos que se pueden seguir al pie de la letra con cualquier compilación
del cierre y la escala sintética (`dart tool/t100_sintetico.dart <salida en %TEMP%>` y
`python -I tool/t100_listado.py <esa salida>`): abrir el plano de llegada eligiendo
la escala y registrar una descarga y una re‑estiba (4.3 y 8.1), importar el listado y
registrar una carga por OR (8.5 y 8.1) y cargar tomas por rangos en el anexo (A.5).
