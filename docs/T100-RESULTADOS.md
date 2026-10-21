# T-100 · Parte A · El manual de usuario: cómo se hizo

Timonel · 20 y 21-oct-2026 · Base: `sprint3-cierre-2` (`33404a5`), decisión 10.98.
**Entregada para aceptación de Codex, sin commit.**

El entregable es `docs/MANUAL-USUARIO.md` con sus 71 capturas en `docs/manual/`. Este
informe dice sobre qué se escribió, con qué se capturó, qué se tocó en la máquina y qué
pasó. No repite el manual.

## 1. Resultado

- **Los 14 capítulos y el anexo de la geometría a mano, escritos.** Cada procedimiento
  con captura se siguió en la app antes de escribirlo; los que no se pudieron seguir con
  los archivos de prueba están marcados «(no recorrido en esta edición)» en el propio
  manual, y la lista completa va al final del manual.
- **71 capturas**, 47 de Windows (1920 × 991, la ventana maximizada sin la barra de
  tareas, a 125 %) y 24 del Honor X5d (360 × 800 dp, 720 × 1600 px). Todas con archivos
  sintéticos; ninguna con cuenta ni con «Nube y cuenta».
- **Lo PROVISIONAL**: el instalador MSIX, Play y la Web nueva, marcados en el capítulo 2
  y listados al final del manual.
- **Hallazgos**: cuatro, ninguno nuevo de fondo (lista al final del manual y en la
  sección 5). Nada se corrigió (10.73).

## 2. La base

| Qué | Valor |
|---|---|
| Copia limpia | `%TEMP%\t100-33404a5-20oct\app`, `git archive` de `33404a5` (745 archivos, tar `15dc1e41…`), más `tool/t100_main.dart` superpuesto. `lib/` y `pubspec.*` idénticos al cierre (`preparacion.json`, `binarios.json`) |
| Entrada | `tool/t100_main.dart`: `BayStreamApp` de `lib/` sin tocar, almacenes `t100`, Firebase inicializado en una app aparte «t100» sin sesión; en Windows el almacén en `%TEMP%\…\store-windows` |
| Windows | `flutter build windows --release --no-pub`, 15 937 536 bytes, SHA-256 `079611fb…`; abierto con `explorer.exe` (PID 8388, padre explorer) y cerrado por PID |
| Web | `flutter build web --release --no-web-resources-cdn`, `main.dart.js` 5 545 567 bytes, SHA-256 `3d180ada…`; servido en `127.0.0.1:8101` y abierto en el navegador integrado |
| Android | `flutter build apk --release` (sin `--no-pub`), 68 477 327 bytes, SHA-256 `d6b5792c…`, identidad `gt.cmartinez.baystream.t100`, rótulo «BayStream T100» |
| Archivos de prueba | `tool/t99_sintetico.dart` con 1600 y 600 contenedores (`%TEMP%\…\sinteticos*`, manifiestos con SHA) y `PRUEBA_T98.edi` de la copia de T-98 (solo leído). Para el listado de la agencia, `test/fixtures/t73_listado_sintetico_excel.xlsx` |

Nada del corpus en el manual ni en las capturas. El generador de sintéticos usa
`CORPUS_A01.edi` como plantilla de estructura, como en T-99; el archivo que sale es
sintético (buque `T99 SINTETICO`, contenedores `SNTU…`).

## 3. Cómo se capturó

- **Windows:** `tool/t100_windows.ps1` captura el cliente de la ventana por PID con
  `PrintWindow` (funciona aunque esté tapada) y es consciente del DPI, para que salgan
  los píxeles reales. La app se manejó con el control del escritorio (concedido para la
  ruta del exe de la copia) y, cuando hizo falta texto, con el mismo script.
- **Honor:** `adb exec-out screencap` para capturar; `uiautomator dump` para ubicar los
  botones por su etiqueta de accesibilidad y tocar por coordenadas. Letra del sistema en
  1.0, y en 1.45 solo para las dos capturas de letra grande; quedó en 1.0.
- **Web:** se abrió y se comprobó la pantalla de inicio en el navegador integrado; no
  hay capturas de la Web (la ficha pide Windows y teléfono).

## 4. Lo que pasó en la máquina (para Codex y para Yov)

1. **La app `t98` de Codex en el Honor vino al frente dos veces.** La tecla «atrás» en
   la raíz de mi app la cierra, y Android muestra la app anterior, que era la `t98`. La
   primera vez, mi siguiente toque abrió su pantalla «Viajes recientes» (solo lectura) y
   volvió atrás; la segunda, no se tocó. No se registró ni cambió nada en ella; descarté
   la captura que la mostraba. Relancé la mía con `monkey` y dejé la de Codex como estaba,
   al frente al terminar, porque mi app se cerró al final.
2. **Un CSV exportado cayó en `test/fixtures`.** Al probar «Exportar viaje → CSV», el
   diálogo de guardar propuso la última carpeta usada (el listado de pruebas) y la ruta
   que escribí no entró: el archivo se guardó con el nombre propuesto en
   `test/fixtures/BayStream_T99 SINTETICO 1600_T99S1600.csv`. Lo moví a
   `%TEMP%\…\exportes\` en cuanto lo vi; `test/` queda como en HEAD. Es de mi
   automatización, no del producto.
3. **La Web se compiló dos veces.** La primera, con `--no-pub --pwa-strategy=none`, salió
   sin `canvaskit/` ni `flutter.js` y la página quedaba en blanco. La segunda, con la
   receta de `tool/t98_cierre2.py`, salió completa; es la que se usó. `binarios.json` lo
   anota.
4. **No se tocó nada de Codex:** su `baystream.exe` (PID 9868) siguió abierto toda la
   noche, sus sesiones y sus archivos sin commit quedan como estaban, y Chrome no se usó
   (la Web se abrió en el navegador integrado).
5. **Al terminar:** mi app de Windows cerrada por PID, mi servidor local detenido, mi app
   del Honor detenida y sus archivos de prueba borrados de `Download/t100`, letra en 1.0,
   modo avión en 0. El paquete `gt.cmartinez.baystream.t100` queda instalado, como los de
   las aceptaciones anteriores.

## 5. Hallazgos

Los cuatro del manual, aquí con su evidencia:

| # | Hallazgo | Evidencia | Estado |
|---|---|---|---|
| 1 | «Confirmar y ver el plano» abre la Lista, no el plano | Windows y Honor, en cada confirmación | Conocido (10.97, Sprint 4) |
| 2 | A 360 dp con letra 1.45, el botón flotante «Cargar BAPLIE» tapa parte de «Seleccionar archivo» en la pantalla de inicio | `docs/manual/h00-inicio-letra-grande.png` | Nuevo; menor (se puede cargar con el flotante) |
| 3 | A 360 dp la barra superior deja fuera «Parámetros», «Cargar archivo BAPLIE» y «Limpiar datos» sin señal de que hay más; en Windows, en «Plano», la lupa y «Exportar viaje» solo tras «Desplegar acciones» | `h06-lista.png`, `w05-plano-bahia02.png` | Diseño (T-91, T-97); el manual lo explica |
| 4 | Con letra 1.45 la línea de resumen del plano y la leyenda se cortan | `h05-plano-letra-grande.png` | Conocido (10.94) |

## 6. Lo que no se pudo recorrer, y por qué

Los sintéticos de `t99_sintetico.dart` solo traen puertos de carga como escala posible,
así que no hay descargas: quedan descritos desde los textos de la app descarga,
re‑estiba, «Tipo de BAPLIE», pendientes de descarga, carga por OR (exige un listado que
cruce con el plan), arrastrar y solicitudes de cambio (exigen cuenta), el dictado
(exige el selector de carga por OR y el permiso del micrófono), los avisos de lectura y
los buques homónimos, «La carga excede el perfil guardado», y exportar en Android. Si
Carlos quiere capturas de la operación completa, hace falta un sintético con plano de
llegada y plan de carga de la misma escala, o la autorización para usar el caso A07/A08
sin que aparezca en las capturas.

## 7. Archivos

**Nuevos:**
- `docs/MANUAL-USUARIO.md`;
- `docs/manual/*.png` (71);
- `docs/T100-RESULTADOS.md`, este informe;
- `tool/t100_main.dart`, `tool/t100_preparar.py`, `tool/t100_windows.ps1`.

**No cambian:** `lib/`, `test/`, `pubspec.*`, `lib/main.dart`, los congelados, nada de
Codex.

## 8. Para la aceptación (Codex)

Tres procedimientos que se pueden seguir al pie de la letra con la copia de
`%TEMP%\t100-33404a5-20oct` o con cualquier compilación del cierre y un sintético:
cargar un BAPLIE y confirmar el perfil (capítulos 3 y 4), buscar un contenedor y verlo
en el plano (6.2) y cargar tomas por rangos en el anexo (A.5).
