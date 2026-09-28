# Bloque 5 y T-53 · Recorrido a mano en los tres clientes

27-sep-2026, Guatemala. Autor: Timonel. Cumple lo pedido en `SPRINT-2.md` §10.16:
T‑32, T‑33, T‑34 y T‑53 quedaban en revisión hasta recorrer las pantallas nuevas a
mano en los tres clientes, con el APK final instalado. **Sin cambios de código.**

## Qué se recorrió

Los tres binarios salen de una copia exacta de **`c1199fb`**, extraída con
`git archive`. En `lib/`, `test/` y `pubspec` ese commit es idéntico a `1fa28cc`
(`git diff --stat --ignore-cr-at-eol` vacío): es el código del bloque 5 más T‑53,
sin nada encima.

| Cliente | Binario | Dónde corrió |
|---|---|---|
| Android | APK release, 57 684 140 bytes, SHA‑256 `009d9e7a2880c30e…`, compilado a las 19:01 | **Honor X5d (NAA‑LX3), Android 15, API 35.** No es el POCO de la serie de H5 (decisión 10.11) |
| Windows | Release nativo | Windows 11 Home, esta máquina |
| Web | Release, servida en `localhost:8791` | **Chrome 154.0.8037.57** en Windows |

Es el APK de la app, no el de QA con identificador propio que usó Codex. El hash
instalado es igual al compilado. La compilación de Windows se hizo desde una copia
en `%LOCALAPPDATA%\Temp\bs5`, porque la ruta larga del directorio temporal rompía
MSBuild (MAX_PATH). No cambia nada de lo compilado.

**Se recorrió `c1199fb`, antes de T‑43.** El build de T‑43 (`5c024eb`) se compiló en
los tres clientes pero no se recorrió; sus cambios son de forma y están descritos en
`docs/T43-RESULTADOS.md`.

## Resultados

| # | Prueba | Honor X5d / Android 15 | Windows | Chrome 154 |
|---|---|---|---|---|
| 1 | Sin perfiles guardados, cargar un buque nuevo **no** ofrece plantilla | **Pasó** · 19:03:44 | **Pasó** · ~19:15 | **Pasó** · 23:15:24 |
| 2 | Con un perfil guardado, otro buque sí la ofrece. El clon marca «plantilla» en geometría **y** en tomas, y se guarda con la clave del buque nuevo | **Pasó** · 19:05:18 · 19:06:23 | **Pasó** · ~19:16 | **Pasó** · 23:17:53 · ~23:18 |
| 3 | Abrir el editor fuera del flujo de carga y salir sin tocar: el perfil **no** queda modificado | **Pasó** · 19:07:22–28 | **Pasó** · ~22:41 | **Pasó** · ~23:21 |
| 4 | Cambiar un valor, confirmar, cerrar la app del todo y reabrir: el cambio persiste | **Pasó** · 19:08:16 · 19:08:37 | **Pasó** · 22:42 | **Pasó** · 23:22:05 · ~23:23 |
| 5 | A05 y A06, los dos BUQUE ECO, preguntan en vez de fusionarse | **Pasó** · 19:10:23 | **Pasó** · 22:43 | **Pasó** · ~23:34 |
| 6 | PDF de A01 desde el menú: las siete bahías con sus huecos de vecino; Vacío y OOG distintos en celda y leyenda | **Pasó**, con el límite de abajo · 19:11:25 | **Pasó**, ídem · 22:44:04 | **Pasó**, ídem · 23:35:26 |

Las horas con «~» salen de la bitácora de la sesión, no de un reloj leído en el
momento; las demás, del reloj de la computadora o de la marca del archivo.

**Punto 6, límite en los tres clientes:** la leyenda distingue Vacío de OOG, pero
**la celda OOG no se puede ver con datos reales**. Ningún archivo del corpus trae
segmentos `DIM` y el parser nunca marca `isOverDimension`, así que ningún contenedor
de A01 sale OOG. La celda OOG solo aparece en el PDF sintético de contraste de Codex
(`output/pdf/T53-contraste.pdf`, `docs/T53-RESULTADOS.md`).

## Cómo se comprobó cada punto

**1 · Sin plantilla.** «Perfiles guardados» estaba vacío en los tres clientes antes de
empezar (captura `h01` en el Honor; en Windows el almacén local se creó a las 19:14,
al abrir la app; en Chrome el origen `localhost:8791` era nuevo). A01 fue directo a
Parámetros, sin el diálogo «Perfil del buque nuevo». Se declaró un límite de
**75 000 kg** y se confirmó.

**2 · Plantilla y clave.** Al cargar A04 apareció «Perfil del buque nuevo» con
«Plantilla: BUQUE ALFA · imo:9000003». Tras elegirla:

- la geometría y las tomas de reefer mostraban origen «plantilla»;
- en «Perfiles guardados» quedaron **dos** perfiles: BUQUE ALFA con `imo:9000003` y
  BUQUE DELTA con `imo:9000027`. El clon se guardó con la clave del buque nuevo y el
  de origen no cambió.

**3 · Salir sin tocar.** Se abrió el perfil de BUQUE ALFA desde «Perfiles guardados»,
que muestra «Editando el perfil guardado de BUQUE ALFA», y se salió dos veces sin
cambiar nada:

- con «Guardar perfil», cuando el resumen decía «Perfil sin cambios.»;
- con la X.

En ninguna de las dos salidas apareció el aviso «Perfil guardado». La pantalla se
capturó justo después de cada salida; en el Honor y en Chrome, también a los ~2 s.

**4 · Persistencia.** El límite se cambió a **80 000**. El resumen pasó a «Perfil
modificado; pendiente de guardar.» y al guardar apareció «Perfil guardado». Después
se cerró la app del todo:

| Cliente | Cómo se cerró |
|---|---|
| Honor | `am force-stop` |
| Windows | Se cerró el proceso; el nuevo arrancó a las 22:42:07 |
| Chrome | Se cerró la pestaña y se abrió la app en otra nueva; es otra instancia que lee IndexedDB |

Al reabrir, el editor de BUQUE ALFA mostraba **80 000** en los tres.

**5 · Mismo nombre, sin fusión.** A05 se cargó como buque nuevo, con «Proponer desde
el archivo» y «No lo tengo» para el límite: BUQUE ECO, 736 contenedores. Al cargar A06
apareció «Confirma la identidad del buque», con «Hay perfiles con el mismo nombre. El
nombre por sí solo no identifica al buque», el perfil BUQUE ECO `callSign:ZZC5603` y
las opciones «Cancelar» y «Es otro buque». No se fusionó nada; se canceló.

**6 · PDF.** A01 se recargó y el perfil de BUQUE ALFA se aplicó sin preguntar la
geometría: 977 contenedores y 34 bahías. Se exportó desde el menú → PDF.

- En el Honor, el diálogo de guardado de Android lo dejó en Descargas.
- En Windows, se guardó con el diálogo nativo.
- En Chrome, se descargó directo: `BayStream_BUQUE ALFA_V01N (4).pdf`.

Los tres PDF se revisaron con PyMuPDF, con los dos scripts que están en la carpeta de
evidencia:

| | Honor | Windows | Chrome |
|---|---|---|---|
| Tamaño | 268 508 bytes | 268 508 bytes | 271 483 bytes |
| Páginas · planos | 62 · 34 | 62 · 34 | 62 · 34 |
| Sombras `40'` en las rejillas | 1 698 | 1 698 | 1 698 |
| Huecos de vecino en 005 · 013 · 015 · 035 · 039 · 043 · 045 | 62 · 92 · 92 · 104 · 98 · 25 · 25 | ídem | ídem |
| Celdas por relleno: Lleno · IMO · Vacío · Reefer | 196 · 4 · 727 · 50 | ídem | ídem |
| Celdas OOG | 0 | 0 | 0 |
| Bloques fuera de la página | 0 | 0 | 0 |

- **Las celdas propias suman 977**, los contenedores del archivo; las 1 698 sombras
  van aparte y no se cuentan como carga.
- **Las siete bahías tienen 0 contenedores propios** y muestran solo sus huecos de
  vecino. La bahía 005 se renderizó y se inspeccionó en los tres.
- **Leyenda:** Vacío con relleno `(1.0, 0.878, 0.698)` y OOG con `(0.584, 0.459,
  0.804)`, dos colores distintos. «Vecino de 40 pies» con `(0.812, 0.847, 0.863)`, el
  mismo relleno que tienen las 1 698 celdas `40'`.
- **El texto de las 62 páginas es idéntico** entre los tres PDF, descontando fechas.

El PDF de Chrome pesa algo más, pero no cambia nada de lo comprobado: texto, celdas y
sombras coinciden con los otros dos. Los PDF del Honor y de Windows pesan lo mismo y
solo difieren en el hash.

## Qué hizo Carlos a mano

En Chrome, el selector de archivos es el diálogo nativo de Windows, y ese diálogo no
se puede manejar desde la extensión. **Carlos eligió los archivos** —A01, A04, A05,
A06 y otra vez A01—; todo lo demás lo manejó Timonel desde la extensión. En el Honor y
en Windows, Timonel eligió los archivos.

## Observaciones fuera de alcance

- **El límite se muestra distinto según el cliente.** En Android y Windows el campo
  muestra `75000.0`; en Chrome, `75000`. Sale de `double.toString()`
  (`vessel_geometry_page.dart:129`), que en la VM de Dart conserva el `.0` y en Web no.
  Es solo de presentación: el valor guardado y releído es el mismo en los tres, como
  confirma el punto 4. Se registra y no se corrige de paso.
- **Un desplazamiento en Chrome se hizo con un evento de rueda por JavaScript.** Al
  reabrir la app para el punto 4, la extensión la puso en una ventana de Chrome oculta
  (`visibilityState: hidden`). Ahí la rueda simulada no llegaba y las transiciones iban
  lentas. En el formulario de A05 se bajó con un `WheelEvent` enviado a
  `flutter-view`, que es el mismo evento que recibe con la rueda del ratón. No toca la
  lógica de la app. Es una limitación de la herramienta, no un defecto del producto.

## Evidencia

Está fuera del repositorio, en `Descargas\BLOQUE5-T53-evidencia\`:

- `honor\`: 30 capturas de pantalla (`h00` a `h29`), del inicio al diálogo de
  guardado; el PDF y las bahías 005 y 014 renderizadas.
- `windows\`: el PDF y las bahías 005 y 014 renderizadas.
- `chrome\`: el PDF y las bahías 005 y 014 renderizadas.
- `revisar_pdf.py` y `comparar_pdf.py`, los dos verificadores.

| PDF | SHA-256 |
|---|---|
| `honor-A01.pdf` | `d77adf28ff5dd3d2…` |
| `windows-A01.pdf` | `d50f1dfccd27e9a5…` |
| `chrome-A01.pdf` | `fc222460c5feb22e…` |

Las capturas de Windows y de Chrome se tomaron y se inspeccionaron durante la sesión,
pero **no se guardaron en disco**. De esos dos clientes queda como evidencia el PDF
de cada uno.

Si el recorrido se acepta, T‑32, T‑33, T‑34 y T‑53 pueden pasar a Terminado; el
tablero lo actualiza Yov.
