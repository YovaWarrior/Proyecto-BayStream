# Bloque 4 · Verificación en Android y exportación a mano en Chrome

27-sep-2026, Guatemala. Autor: Timonel. Cierra el hueco registrado en
`SPRINT-2.md` §10.14: el bloque 4 y T-52 se habían ejecutado en Chrome y en
Windows, pero el APK no se había instalado en un teléfono. Afecta a T-29, T-30,
T-31 y T-52. **Sin cambios de código.**

## Qué se compiló

Se compiló desde una copia exacta de **`711c79c`**, extraída con
`git archive`, con el árbol limpio. La copia deja lo compilado igual a ese
commit aunque el árbol cambie después.

| Artefacto | Resultado |
|---|---|
| APK release | 57 536 424 bytes, SHA-256 `c5b7c9fedf022d4e…`, compilado a las 17:44:13 |
| Web release | compilado a las 17:45:03 |

Carlos quedó avisado apenas terminaron las dos compilaciones, para que Codex
arrancara el bloque 5.

## Dispositivo

**Honor X5d (NAA-LX3), Android 15, API 35.** **No es el POCO X3 NFC de la
serie de H5** (decisión 10.11), y todo lo que sigue va rotulado con este
dispositivo.

- Antes de instalar se desinstaló la versión anterior de la app, así que se
  partió sin perfiles guardados.
- El SHA-256 del APK instalado es igual al del compilado.
- El reloj del teléfono coincidía al segundo con el de la computadora.
- La app se manejó por `adb`, con capturas de pantalla, y el `logcat` se
  escuchó durante toda la prueba.

## Resultados · Honor X5d / Android 15

| # | Prueba | Resultado | Hora |
|---|---|---|---|
| 1 | Cargar `CORPUS_A01` y confirmar el perfil | **Pasó** | 17:53:34 |
| 2 | Cerrar la app del todo, reabrirla y recargar: el perfil se recupera sin preguntar la geometría, con el límite y las 50 tomas de origen «propuesto» | **Pasó** | 17:54:47 (recarga) · 17:55:09 (parámetros) |
| 3 | Exportar el PDF desde el menú: 62 páginas, fila 00 presente, bahía 014 sin desbordes | **Pasó** | 17:56:15 (guardado) |

**1 · Primera carga.** La pantalla de parámetros mostró «Tomas de reefer: 50
posiciones propuestas del archivo (cota inferior)». Se aceptó la geometría
propuesta —13 columnas × 12 niveles— y se declaró un límite de **75 000 kg**,
el mismo valor que usó Codex en el bloque 4. Tras confirmar: 977 contenedores,
34 bahías y «Archivo "CORPUS_A01.edi" cargado correctamente».

**2 · Recuperación del perfil.**

- **Cierre.** La app se cerró con `am force-stop`. Se comprobó que no quedaba
  proceso (`pidof` vacío), y el `logcat` registró «app died, no saved state».
  Después se reabrió.
- **Recarga.** Al recargar el mismo archivo, la app pasó directo de «Procesando
  archivo BAPLIE…» a «cargado correctamente». **No abrió la pantalla de
  geometría.**
- **Parámetros.** Reabiertos con el icono de la regla, mostraban el límite de
  **75 000 kg** y la leyenda **«Tomas de reefer: 50 posiciones propuestas del
  archivo»**.
- **Origen.** Esa leyenda solo se muestra cuando el origen de las tomas es
  `proposedFromFile` (`vessel_overview_page.dart:434`), así que el origen
  también se recuperó.

Los parámetros se cerraron sin cambiar nada.

**3 · Exportación.** Menú de exportación → PDF. A los 6 segundos apareció el
diálogo de guardado de Android, ya en «Descargas» y con el nombre
`BayStream_BUQUE ALFA_V01N` propuesto. Se tocó «Guardar». El archivo, de
261 033 bytes, se bajó del teléfono y se revisó con PyMuPDF:

- **62 páginas:** 1 de portada, 34 de planos y 27 de tabla.
- **Fila 00 en las 34 rejillas.** La cabecera de columnas de cada plano es
  `12 10 08 06 04 02 00 01 03 05 07 09 11`.
- **Bahía 014** en la página 12 (92 contenedores, 364.8 t). Se renderizó e
  inspeccionó: rejilla, leyenda y pie completos, sin recortes.
- **Cero elementos fuera de los márgenes**, contando bloques de texto y trazos,
  en las 62 páginas.

**`logcat`:** ningún error de la app en toda la prueba. La única línea
capturada fue la del `force-stop`, provocada a propósito.

## Resultado · Chrome 154.0.8037.57 / Windows

| Prueba | Resultado | Hora |
|---|---|---|
| Exportar el PDF desde el **menú** y comprobar la descarga | **Pasó** | 18:00:30 (archivo en Descargas) |

Lo hizo Carlos a mano sobre la Web release de `711c79c`, servida en
`localhost`. La extensión de Claude no estaba conectada a Chrome, y el objetivo
era justamente recorrer el menú y la descarga como un usuario. Los pasos fueron
cargar `CORPUS_A01`, declarar 75 000 kg, confirmar y exportar desde el menú →
PDF.

**Chrome no mostró un cuadro «Guardar como»: descargó el archivo directo.**
Chrome se comporta así cuando la opción de preguntar dónde guardar cada archivo
está apagada, que es su valor por defecto; ese ajuste no se revisó en este
equipo. El archivo llegó entero: `BayStream_BUQUE ALFA_V01N (3).pdf`, 263 702
bytes, con el mismo resultado que el de Android.

- 62 páginas: 1 de portada, 34 de planos y 27 de tabla.
- La fila 00 en las 34 rejillas.
- Cero elementos fuera de los márgenes.
- La bahía 014 sin desbordes.
- **El mismo texto que el PDF del Honor, página por página**, descontando las
  fechas de generación.

## Qué no se probó

- **La primera carga en Chrome no se contrastó** con la recarga. Esa parte ya
  la había ejecutado Codex en Chrome 154 (`docs/BLOQUE4-RESULTADOS.md`).
- **Windows** no se repitió en esta sesión.
- **El PDF no se revisó celda por celda contra el archivo.** Se comprobaron
  estructura, filas, márgenes y la bahía 014 a la vista, lo mismo que pide la
  prueba. La comparación de celdas la hace `tool/verify_t52_pdf.py`, de Codex,
  y no se corrió aquí.

## Observaciones fuera de alcance

- **En el PDF, «Vacío» y «OOG» comparten color** (`orange100` con borde
  `orange`, `pdf_report_service.dart:412-419`), aunque la leyenda los lista
  como dos entradas. Dentro de la celda se distinguen porque la de OOG lleva el
  rótulo «OOG». La pantalla los agrupa a propósito como «Vacío / OOG». Es
  anterior al bloque 4. Se registra y no se corrige de paso.
- Sigue abierto lo que Codex ya registró en `docs/T52-RESULTADOS.md`: el PDF no
  dibuja los huecos ocupados por un 40 pies vecino.

## Evidencia

Está fuera del repositorio, en `Descargas\BLOQUE4-ANDROID-evidencia\`:

- ocho capturas del Honor, desde la primera carga hasta el diálogo de
  guardado;
- los dos PDF:
  - Honor: `honor-711c79c-A01.pdf`, SHA-256 `0f9b8d59961ec586…`
  - Chrome: `chrome-711c79c-A01.pdf`, SHA-256 `e75a7ff772b681f8…`
- la bahía 014 renderizada de cada uno.

Si pasa todo, T-29, T-30, T-31 y T-52 van a Terminado; el tablero lo actualiza
Yov.
