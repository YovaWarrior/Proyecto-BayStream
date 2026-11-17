# T-139 · El manual de usuario de la 1.0.0: cómo se hizo

Timonel · 4-nov-2026, de 12:40 a 13:30 · Base: `sprint-4` en `606c093` (el código de la
app es el de `32eac61`, el mismo de la 1.0.0) · Decisión 10.107. **Entregada para la
revisión de Yov; sin commit.**

Los entregables son `docs/MANUAL-USUARIO-1.0.0.md` (11 capítulos, 45 figuras numeradas con
su pie) y sus capturas en `docs/manual-1.0.0/` (43 archivos; las figuras 5 y 6, la
instalación en Android y en la Web, las toma Carlos y en el manual quedan como marcador).
Este informe dice sobre qué se escribió, con qué se capturó, de dónde sale cada figura, qué
pasó en la máquina y qué observé. No repite el manual.

## 1. Resultado

- **El manual de la 1.0.0, completo**, con el índice propuesto en la 10.107 ajustado a lo
  que hace la app: el inicio y el previo, «ver primero y confirmar después», la escala, el
  plano con el puente y la silueta, «Colorear por», el panel lateral, el zoom, la
  búsqueda por los últimos dígitos, la Lista, Estadísticas («el buque en corte»), Alertas,
  la nube completa (sesión, roles con distintivo, publicar, unirse, descargar, re‑estibar,
  el avance con «En vivo», agregar el plan de carga a la operación publicada, el listado,
  cargar por OR, la celda ocupada, sin conexión, cerrar), el BAPLIE de salida y la
  comparación, el tema, los mensajes y el glosario.
- **Más corto que el de T-100:** 6 850 palabras (el de T-100 tiene unas 15 000) y 45
  figuras (T-100 tiene 103). Son unas 15 páginas carta de texto; con las figuras a media
  página, entre 25 y 30.
- **Todo recorrido en la app de la 1.0.0**, oficina y muelle contra el emulador de
  Firebase, salvo lo que la última sección del manual marca «(no recorrido en esta
  edición)».
- **Sin cambios en `lib/`, `test/` ni `pubspec.*`.** Lo que encontré va en la sección 6.
- **Dos marcadores para Carlos:** las figuras 5 (Android, la prueba interna de Play) y 6
  (la Web), con el nombre de archivo ya fijado: `docs/manual-1.0.0/05-instalar-android-play.png`
  y `06-instalar-web.png`. Al copiarlas ahí, el manual las toma sin cambiar una línea.

## 2. La base

| Qué | Valor |
|---|---|
| Código | `sprint-4` en `606c093`; `lib/` es el de `32eac61`, el de la 1.0.0 (10.105). `pubspec.yaml` dice `1.0.0+9`; `version.json` del banco, `1.0.0 (9)` |
| Entrada | `tool/t130_emu_main.dart`, el banco de T-130: `BayStreamApp` de `lib/` sin tocar, almacenes propios `t130emu`, Firebase en una app aparte contra el emulador (`demo-t139`, Auth 9399, Firestore 8383). Nunca `baystream-app` ni `baystream-privado` |
| Web | `flutter build web --release --no-pub --no-web-resources-cdn -t tool/t130_emu_main.dart --dart-define=T130_HOST=127.0.0.1 --dart-define=T130_PROJECT=demo-t139 --output=build/t139/web-emu` (64.7 s). `main.dart.js` SHA-256 `11a8f98d…`, `flutter_bootstrap.js` `7dc97db8…` (`build/t139/web-emu-huellas.txt`). Servida en `127.0.0.1:5939` con `python -m http.server` |
| Emulador | `tool/t139_emulador.py` (nuevo): `firebase emulators:start --only auth,firestore` con las reglas de T-130 (`docs/T130-firestore.rules.propuesta`, `8B903949…`), UI apagada, `--project demo-t139`; siembra dos cuentas sintéticas, «Oficina de prueba» (`office`) y «Muelle de prueba» (`dock`), activas en `authorized/{uid}`. Correos y claves solo en `%TEMP%\t139\emu\cuentas.json`; no se imprimen ni se versionan |
| Datos | **Solo los sintéticos de T-100**, regenerados con `dart run tool/t100_sintetico.dart` en `%TEMP%\t139\sinteticos` (las 15 comprobaciones en verde) y `python -I tool/t100_listado.py`. Mismas huellas que en T-100: `T100_LLEGADA.edi` 8 021 bytes `9573cfd7…`, `T100_CARGA.edi` 8 009 bytes `4acf7539…`, `T100_LISTADO.xlsx` 4 555 bytes `feb12a90…` (`build/t139/sinteticos-manifiesto.json`). Nada del corpus, ni en las capturas ni en el texto |
| Windows | Las capturas del asistente son las de Carlos en «BayStream Prueba» (10.106), `C:\Proyectos\baystream-t137\build\t137\capturas\carlos\claro\`, recortadas a la ventana del asistente con su borde (figuras 1 a 3) o enteras (figura 4) |

Honor, apps instaladas y almacén real: **no se tocaron**. El banco corre en Chrome de
Playwright con perfiles temporales en `%TEMP%\t139\`.

## 3. Cómo se capturó

- **`tool/t139_control_web.py`** (nuevo): un servidor HTTP local que sostiene el Chrome de
  Playwright entre llamadas, como el `control_web.py` de la aceptación de T-128, con un
  perfil persistente por cliente: **oficina** a 1920 × 1080 y **muelle** a 360 × 800,
  los dos con `device_scale_factor = 2` (los PNG salen a 3840 × 2160 y 720 × 1600) y tema
  claro; el oscuro, con `emulate_media` y «Parámetros → Oscuro». Recibe órdenes en JSON:
  abrir, nodos (la semántica de Flutter con sus cajas), pulsar, clic, rueda (con Ctrl para
  el zoom), teclear, escribir, sesión (lee las credenciales del archivo de TEMP y rellena el
  formulario), archivo (el selector del sistema lo intercepta el instrumento de
  `tool/t114_primera_web.js`), captura con recorte, sin_conexion (corta la red del
  navegador) y salir. Antes de cada captura aparta el puntero para que ninguna
  descripción emergente entre en la figura, y oculta la franja «Running in emulator
  mode» que el SDK de Auth pinta fuera de la app.
- **`tool/t139_recortes.py`** (nuevo): recorta cada captura cruda a lo que el manual
  explica (coordenadas en píxeles lógicos, multiplicadas por la escala), la nombra con su
  número de figura y escribe `build/t139/figuras.json` con el origen, el recorte, el tamaño
  y la huella de cada una.
- **El teléfono se recorrió en la Web a 360 dp**, no en el emulador de Android. La 10.107
  dice «el teléfono, en el emulador de Android y no en el Honor»; la opción de la Web a
  360 dp viene del prompt de T-139 que me pasó Carlos («El muelle, en el emulador de
  Android o en la Web a 360 dp. Usa lo que dé capturas fieles a la app»). Elegí la Web
  porque da capturas fieles del mismo código con la mitad del tiempo y sin una segunda
  compilación. Lo que depende de Android (Atrás, el dictado, el selector de documentos)
  queda en texto y marcado.
- **El recorrido**, en orden, con la oficina y el muelle a la vez contra el emulador: el
  inicio vacío → `T100_LLEGADA.edi` abre en previo (escala propuesta PAMIT) → Confirmar →
  GTSTC y «No lo tengo» → publicado → Recientes → Colorear por, detalle, zoom (Ctrl + rueda,
  212 %) → búsqueda «0004» → Lista → Estadísticas y su tabla → Alertas → «Nube y cuenta»,
  sesión de oficina, «Publicar operación» → en el muelle, sesión de muelle, «Unirse», «Abrir
  plano de llegada» → Descarga: una descarga (MNLU0000107) y una re‑estiba (MNLU0000405) →
  Avance en la oficina con «En vivo» → la oficina abre `T100_CARGA.edi`, la banda de T-130,
  «Agregar a la operación M100» → el listado `T100_LISTADO.xlsx`, «Confirmar e importar» →
  el muelle en Carga: OR 7 por el selector; OR 25 sobre una celda ocupada, «Marcar su
  descarga y cargar», sin red («Sin conexión · 2 por enviar») y de vuelta a «Al día» →
  BAPLIE de salida y «Comparar con la llegada» → Parámetros, tema oscuro y de vuelta a
  «Seguir al sistema» → «Cerrar operación» → un `.xlsx` como BAPLIE para el aviso.
- **SEMÁFORO.** Un solo comando de Flutter o Dart a la vez, cada uno con su línea al
  empezar y al terminar: `dart run tool/t100_sintetico.dart` (12:47), el emulador (12:48,
  hasta las 13:24), `flutter build web` (12:49 a 12:50). No corrió la suite ni `analyze`:
  la tarea no toca `lib/` ni `test/`.

## 4. Las figuras y de dónde sale cada una

Las 43 capturas de `docs/manual-1.0.0/` pesan 6.3 MB. «Carlos» son las del asistente de
Windows (3-nov, cuenta «BayStream Prueba», 10.106), las figuras 1 a 3 recortadas a la
ventana del asistente con su borde, medida pixel a pixel en cada captura, y la 4 entera;
«Web» son del banco en Chrome de
Playwright, a escala 2. El recorte va en píxeles lógicos (x, y, ancho, alto); «entera» es
la ventana completa. La huella SHA-256 de cada archivo está en `build/t139/figuras.json`.

| Figura | Archivo | Qué muestra | Origen | Recorte | Tamaño |
|---|---|---|---|---|---|
| 1 | `01-instalador-bienvenida.png` | La bienvenida del asistente de Windows. | Carlos, Captura de pantalla 2026-11-03 215231.png | (295, 50, 798, 615) | 798 × 615 |
| 2 | `02-instalador-que-se-instala.png` | Qué se instala y dónde quedan los datos. | Carlos, Captura de pantalla 2026-11-03 215245.png | (291, 50, 798, 615) | 798 × 615 |
| 3 | `03-instalador-carpeta-y-accesos.png` | La carpeta de destino y los accesos. | Carlos, Captura de pantalla 2026-11-03 215431.png | (293, 50, 798, 615) | 798 × 615 |
| 4 | `04-instalador-listo.png` | El final del asistente, con «Abrir BayStream». | Carlos, Captura de pantalla 2026-11-03 215542.png | entera | 796 × 607 |
| 5 | `05-instalar-android-play.png` | BayStream en la prueba interna de Google Play. | **La toma Carlos** (marcador) | — | — |
| 6 | `06-instalar-web.png` | La Web de BayStream en Chrome. | **La toma Carlos** (marcador) | — | — |
| 7 | `07-inicio-oficina.png` | El inicio en la oficina, todavía sin viajes. | Web, `f03-01-inicio.png` | (0, 0, 1920, 600) | 3840 × 1200 |
| 8 | `08-inicio-muelle.png` | El inicio en el teléfono. | Web, `f03-10-inicio-muelle.png` | entera | 720 × 1600 |
| 9 | `09-plano-previo.png` | El plano de llegada abierto en previo, con la banda «Plano sin confirmar» y «Confirmar». | Web, `f03-02-previo.png` | (0, 0, 1920, 790) | 3840 × 1580 |
| 10 | `10-parametros-arriba.png` | «Parámetros del buque», de arriba abajo: el mínimo observado, las tomas, la frontera, las filas y los niveles. | Web, `f03-03-parametros-arriba.png` | (0, 0, 1920, 560) | 3840 × 1120 |
| 11 | `11-parametros-escala.png` | La escala de un plano de llegada: GTSTC elegido y el reparto de la escala. | Web, `f03-04-escala.png` | (0, 700, 1920, 380) | 3840 × 760 |
| 12 | `12-parametros-limite-y-confirmar.png` | «No lo tengo» marcado y «Confirmar y ver el plano» activo. | Web, `f03-05-parametros-abajo.png` | (0, 400, 1920, 680) | 3840 × 1360 |
| 13 | `13-plano-publicado.png` | El plano confirmado: «Publicado», la escala GTSTC en la cabecera y los modos Descarga y Carga ya disponibles. | Web, `f03-06-plano-publicado.png` | (0, 0, 1920, 700) | 3840 × 1400 |
| 14 | `14-inicio-recientes.png` | El inicio con el viaje en Recientes y el perfil guardado. | Web, `f03-07-inicio-recientes.png` | (0, 0, 1920, 560) | 3840 × 1120 |
| 15 | `15-volver-al-inicio.png` | La marca del riel es «Volver al inicio». | Web, `f03-13-volver-al-inicio.png` | entera | 1280 × 720 |
| 16 | `16-mas-oficina.png` | La hoja «Más» en la oficina, con un plan de carga abierto. | Web, `f03-09-mas.png` | (600, 350, 720, 730) | 1440 × 1460 |
| 17 | `17-colorear-tipo-de-vacio.png` | La bahía 02 con «Colorear por» en «Tipo de vacío»: los vacíos en color y los llenos en papel. | Web, `f04-02-colorear-tipo-vacio.png` | (100, 170, 1520, 510) | 3040 × 1020 |
| 18 | `18-detalle-de-la-celda.png` | El detalle de un refrigerado en el panel lateral. | Web, `f04-03-detalle-celda.png` | (560, 0, 1360, 720) | 2720 × 1440 |
| 19 | `19-zoom.png` | La rejilla al 212 % con Ctrl + rueda. | Web, `f04-04-zoom.png` | (100, 170, 1520, 880) | 3040 × 1760 |
| 20 | `20-plano-muelle.png` | El plano en el teléfono, con la sesión de muelle. | Web, `f07-08-muelle-plano.png` | entera | 720 × 1600 |
| 21 | `21-buscador-resultados.png` | La búsqueda por los últimos dígitos, con la coincidencia resaltada. | Web, `f05-02-buscador-resultados.png` | (0, 0, 1920, 840) | 3840 × 1680 |
| 22 | `22-buscador-resaltado.png` | El contenedor elegido, resaltado en su bahía. | Web, `f05-03-buscador-resaltado.png` | (100, 170, 1520, 510) | 3040 × 1020 |
| 23 | `23-lista.png` | La Lista del plano de llegada. | Web, `f05-04-lista.png` | (0, 0, 1920, 1080) | 3840 × 2160 |
| 24 | `24-estadisticas.png` | Estadísticas en la oficina. | Web, `f06-01-estadisticas.png` | entera | 3840 × 2160 |
| 25 | `25-alertas-de-estiba.png` | Alertas de estiba: un par de peligrosas «no evaluado», con «Ver» a cada celda. | Web, `f06-04-alertas.png` | (0, 0, 1920, 430) | 3840 × 860 |
| 26 | `26-nube-sin-cuenta.png` | «Nube y cuenta» sin sesión, con la operación local. | Web, `f07-01-nube-sin-cuenta.png` | (0, 0, 1920, 710) | 3840 × 1420 |
| 27 | `27-nube-publicada.png` | La operación publicada por la oficina. | Web, `f07-03-nube-publicada.png` | (0, 0, 1920, 650) | 3840 × 1300 |
| 28 | `28-cabecera-oficina-publicada.png` | La cabecera de la oficina con el distintivo «Oficina» y la nube «Al día». | Web, `f07-04-oficina-publicada.png` | (0, 0, 1920, 170) | 3840 × 340 |
| 29 | `29-muelle-unirse.png` | La operación abierta en la nube, con «Unirse», desde el teléfono. | Web, `f07-06-muelle-unirse.png` | (0, 0, 360, 480) | 720 × 960 |
| 30 | `30-muelle-descarga.png` | El modo Descarga en el teléfono. | Web, `f07-10-muelle-descarga.png` | entera | 720 × 1600 |
| 31 | `31-muelle-descargado.png` | Una descarga registrada, con «Deshacer». | Web, `f07-11-muelle-descargado.png` | entera | 720 × 1600 |
| 32 | `32-avance-oficina.png` | El avance en la oficina con la descarga y la re‑estiba del muelle, y «En vivo». | Web, `f07-15-oficina-avance.png` | (0, 0, 1920, 880) | 3840 × 1760 |
| 33 | `33-plan-de-carga-previo.png` | El plan de carga abierto en previo sobre la operación publicada. | Web, `f07-16-oficina-plan-previo.png` | (0, 0, 1920, 170) | 3840 × 340 |
| 34 | `34-agregar-plan-dialogo.png` | El diálogo que agrega el plan de carga a la operación publicada. | Web, `f07-17-oficina-agregar-plan.png` | (700, 415, 520, 300) | 1040 × 600 |
| 35 | `35-listado-leido.png` | El listado leído: el resumen, las equivalencias propuestas y el cruce con el plan. | Web, `f07-19-listado-leido.png` | entera | 3840 × 2160 |
| 36 | `36-numero-de-orden-oficina.png` | El plano en «Orden»: cada carga pendiente con su OR, y las tarjetas de carga. | Web, `f07-23-oficina-numero-orden.png` | (100, 60, 1520, 620) | 3040 × 1240 |
| 37 | `37-muelle-carga.png` | El modo Carga en el teléfono, con los OR del listado y el campo «OR / últimos dígitos». | Web, `f07-22-muelle-carga.png` | entera | 720 × 1600 |
| 38 | `38-muelle-confirmar-carga.png` | «Confirmar carga» para el OR 7. | Web, `f07-26-muelle-confirmar-carga.png` | (40, 30, 280, 740) | 560 × 1480 |
| 39 | `39-muelle-celda-ocupada.png` | La celda planificada sigue ocupada: «Marcar su descarga y cargar». | Web, `f07-32-muelle-celda-ocupada.png` | (40, 20, 280, 760) | 560 × 1520 |
| 40 | `40-muelle-sin-conexion.png` | Una carga registrada sin red: la nube dice «Sin conexión» y la cola espera. | Web, `f07-31-muelle-sin-conexion.png` | (0, 0, 360, 300) | 720 × 600 |
| 41 | `41-operacion-cerrada.png` | La operación cerrada desde la oficina. | Web, `f07-34-operacion-cerrada.png` | (0, 0, 1920, 500) | 3840 × 1000 |
| 42 | `42-baplie-de-salida.png` | El BAPLIE de salida con la operación a medias: lo que queda a bordo y lo que no cargó. | Web, `f08-01-baplie-salida.png` | entera | 3840 × 2160 |
| 43 | `43-parametros-tema.png` | Parámetros: el tema y el panel lateral. | Web, `f09-01-parametros.png` | (0, 0, 1920, 480) | 3840 × 960 |
| 44 | `44-plano-oscuro.png` | El plano en tema oscuro, con las cargas registradas en verde. | Web, `f09-04-plano-oscuro.png` | entera | 3840 × 2160 |
| 45 | `45-aviso-no-es-baplie.png` | El aviso al abrir un archivo que no es BAPLIE: la causa y la acción. | Web, `f10-01-error-no-baplie.png` | (100, 1000, 1520, 80) | 3040 × 160 |

## 5. Lo que pasó en la máquina (para Carlos y para Yov)

1. **La sesión del banco no sobrevive a reiniciar Chrome.** Al cerrar y volver a abrir el
   Chrome de Playwright con el mismo perfil, las dos sesiones salieron «Solo este
   dispositivo» y el reingreso falló con «No se pudo iniciar sesión: el servicio de
   cuentas respondió con un error que BayStream no reconoce». La causa está en el banco,
   no en la app: el SDK de Auth web recupera la sesión guardada en IndexedDB antes de que
   `tool/t130_emu_main.dart` llame a `useAuthEmulator`, y desde entonces el SDK ya no
   admite apuntarlo al emulador. Lo resolví borrando las bases `firebase*` de IndexedDB de
   cada perfil y volviendo a iniciar sesión. **Ninguna petición llegó a producción:** el
   proyecto es `demo-t139`, sin clave de API real, y el intento fue la única llamada
   fallida. Para quien repita el banco: no cerrar el navegador a medias, o borrar esas
   bases antes de reabrir.
2. **Las capturas intermedias que no sirven se descartaron**, entre ellas la única con el
   formulario de sesión relleno (traía el correo sintético). Las 78 crudas que quedan están
   en `%TEMP%\t139\capturas` (`build/t139/capturas-crudas.txt` las lista) y ninguna
   muestra correos ni UID; el nombre de la cuenta sí («Oficina de prueba», «Muelle de
   prueba»), que es lo que la app enseña.
3. **El emulador quedó cerrado a las 13:24**, con los puertos 9399, 8383, 4498 y 4598
   libres; el servidor Web y el control también. Lo que queda en `%TEMP%\t139\` (perfiles
   de Chrome, sintéticos, capturas crudas, las cuentas del emulador) se puede borrar.
4. **`build/t139/web-emu/t139/`** tiene copias de los tres sintéticos para servirlos al
   banco, como hizo T-114 con `build/web/t114/`. `build/` está ignorado por Git.

## 6. Observaciones (nada se corrigió)

| # | Qué vi | Dónde | Peso |
|---|---|---|---|
| O-139-1 | En «Nube y cuenta» del muelle, con la operación ya cerrada por la oficina, el estado sigue diciendo «Publicada» y «Al día», aunque «Operaciones abiertas en la nube» ya dice «No hay operaciones abiertas». En la oficina sí dice «Publicada y cerrada» y «Al día · operación cerrada». El muelle se entera al registrar (la nube rechaza) | figura 41 y su gemela del muelle (`f07-35-muelle-cerrada.png`, cruda) | Texto; para después del 7-nov |
| O-139-2 | La tarjeta del viaje en la Lista conserva «Peso Total» en mayúscula inicial y «LLENO» / «VACÍO» en mayúsculas sostenidas en cada contenedor, contra la regla 3 de `DESIGN.md` 11. Son textos de T-112 que la regla 6 conserva tal cual | figura 23 | Texto; decide Yov |
| O-139-3 | En el plan de carga agregado, la silueta dice «sin operación» en la etiqueta accesible de cada bahía («Bahía 02, 1 nivel en cubierta y 3 en bodega, sin operación») mientras la cabecera y las tarjetas sí muestran la operación con «Carga 30». Solo en la etiqueta: lo visible está bien | nodos tras la figura 34 | Accesibilidad; menor |
| O-139-4 | El selector de archivos del banco (el navegador) acepta el `.xlsx` como BAPLIE y la app responde bien con el aviso de la figura 45; en Windows y Android el selector del sistema haría lo mismo. No es un defecto: lo anoto porque el manual lo usa como ejemplo | figura 45 | — |
| O-139-5 | En el muelle, al elegir el modo Carga, «Colorear por» pasa solo a «Tipo de vacío» (la vista por omisión de 5.4 de `DESIGN.md`); el manual lo explica en 4.1 | figura 37 | — |
| O-139-6 | Al confirmar el plan de carga sobre la operación publicada, «Parámetros del buque» vuelve a pedir el límite de apilamiento con «No lo tengo» sin marcar aunque el perfil guardado ya lo tenía resuelto. Es lo que dice `DESIGN.md` 7.2 («No lo tengo sin marcar»); para el planificador es un clic más por plan | figura 34 | Usabilidad; decide Yov |
| O-139-7 | La cabecera del plano dice «Publicado» en cuanto se confirma el perfil en este equipo, mientras el chip dice «Solo este dispositivo» y la operación no está en la nube; «Publicada» es el estado de la operación en «Nube y cuenta» tras «Publicar operación». Un lector puede creer que el plano ya está en la nube. El manual lo distingue en 3.3. Es el texto que la 10.105 dejó para después del 7-nov | figuras 13 y 24 | Texto; para después del 7-nov |

## 7. Lo que no se pudo recorrer, y por qué

- «Perfil del buque nuevo», «Confirma la identidad del buque» y «La carga excede el
  perfil guardado»: hacen falta un segundo buque o un perfil distinto; los sintéticos de
  T-100 son un solo buque.
- «Tipo de BAPLIE»: solo aparece con cargas y descargas del mismo puerto en un archivo.
- Atrás en Android y el dictado: el teléfono se recorrió en la Web.
- Mover con arrastre, las solicitudes de cambio, las tapas, el orden de descarga y
  «Perfiles guardados»: están en la app (el orden de descarga y el menú de acciones del
  muelle sí se capturaron en crudo), pero el manual los deja en texto para quedarse en 45
  figuras.
- Las descargas de archivos del banco (el BAPLIE de salida, PDF, CSV y JSON) las
  gestiona el navegador: el manual describe el guardado sin captura.

## 8. Archivos

**Nuevos**

- `docs/MANUAL-USUARIO-1.0.0.md` — el manual.
- `docs/manual-1.0.0/*.png` — las 43 capturas (figuras 1 a 4 y 7 a 45).
- `docs/T139-RESULTADOS.md` — este informe.
- `tool/t139_emulador.py` — el emulador con Auth y Firestore y las dos cuentas sembradas.
- `tool/t139_control_web.py` — el control del banco Web en Chrome de Playwright.
- `tool/t139_recortes.py` — los recortes y la numeración de las figuras.

**Evidencias, fuera de Git** (`build/t139/`): `01-flutter-build-web.log`,
`02-emulador-salida.log`, `emulador-firebase.json`, `sinteticos-manifiesto.json`,
`web-emu-huellas.txt`, `capturas-crudas.txt`, `figuras.json` y el banco `web-emu/`.

**Sin cambios:** `lib/`, `test/`, `pubspec.yaml`, `pubspec.lock`, `lib/main.dart`.

**Revisión de Yov (4-nov, tarde):** las figuras 1 a 3 se recortaron a la ventana del
asistente con su borde, cada una a su propia posición (`VENTANA_1` a `VENTANA_3` en
`tool/t139_recortes.py`; las otras 40 figuras conservan su huella, cotejadas contra
`build/t139/figuras-antes-revision.json`); el manual suma en 3.3 la diferencia entre
«Publicado» y «Publicada» y en 7.11 lo que el muelle ve tras el cierre; el informe
corrige la sección 3 (la Web a 360 dp viene del prompt, no de la 10.107) y agrega O-139-7.

## 9. Para Carlos: los comandos de Git

Con la autorización de la 10.107 para `docs/MANUAL-USUARIO-1.0.0.md`, cada archivo de
`docs/manual-1.0.0/`, `docs/T139-RESULTADOS.md` y `tool/t139_*`. Un `git add` por ruta;
la carpeta de capturas va por nombre (43 archivos, todos nuevos y míos), no por comodín.
Cuando Carlos copie las figuras 5 y 6 a `docs/manual-1.0.0/`, se agregan con las dos
últimas líneas de `git add`.

```
git add docs/MANUAL-USUARIO-1.0.0.md
git add docs/T139-RESULTADOS.md
git add tool/t139_emulador.py
git add tool/t139_control_web.py
git add tool/t139_recortes.py
git add docs/manual-1.0.0/01-instalador-bienvenida.png
git add docs/manual-1.0.0/02-instalador-que-se-instala.png
git add docs/manual-1.0.0/03-instalador-carpeta-y-accesos.png
git add docs/manual-1.0.0/04-instalador-listo.png
git add docs/manual-1.0.0/07-inicio-oficina.png
git add docs/manual-1.0.0/08-inicio-muelle.png
git add docs/manual-1.0.0/09-plano-previo.png
git add docs/manual-1.0.0/10-parametros-arriba.png
git add docs/manual-1.0.0/11-parametros-escala.png
git add docs/manual-1.0.0/12-parametros-limite-y-confirmar.png
git add docs/manual-1.0.0/13-plano-publicado.png
git add docs/manual-1.0.0/14-inicio-recientes.png
git add docs/manual-1.0.0/15-volver-al-inicio.png
git add docs/manual-1.0.0/16-mas-oficina.png
git add docs/manual-1.0.0/17-colorear-tipo-de-vacio.png
git add docs/manual-1.0.0/18-detalle-de-la-celda.png
git add docs/manual-1.0.0/19-zoom.png
git add docs/manual-1.0.0/20-plano-muelle.png
git add docs/manual-1.0.0/21-buscador-resultados.png
git add docs/manual-1.0.0/22-buscador-resaltado.png
git add docs/manual-1.0.0/23-lista.png
git add docs/manual-1.0.0/24-estadisticas.png
git add docs/manual-1.0.0/25-alertas-de-estiba.png
git add docs/manual-1.0.0/26-nube-sin-cuenta.png
git add docs/manual-1.0.0/27-nube-publicada.png
git add docs/manual-1.0.0/28-cabecera-oficina-publicada.png
git add docs/manual-1.0.0/29-muelle-unirse.png
git add docs/manual-1.0.0/30-muelle-descarga.png
git add docs/manual-1.0.0/31-muelle-descargado.png
git add docs/manual-1.0.0/32-avance-oficina.png
git add docs/manual-1.0.0/33-plan-de-carga-previo.png
git add docs/manual-1.0.0/34-agregar-plan-dialogo.png
git add docs/manual-1.0.0/35-listado-leido.png
git add docs/manual-1.0.0/36-numero-de-orden-oficina.png
git add docs/manual-1.0.0/37-muelle-carga.png
git add docs/manual-1.0.0/38-muelle-confirmar-carga.png
git add docs/manual-1.0.0/39-muelle-celda-ocupada.png
git add docs/manual-1.0.0/40-muelle-sin-conexion.png
git add docs/manual-1.0.0/41-operacion-cerrada.png
git add docs/manual-1.0.0/42-baplie-de-salida.png
git add docs/manual-1.0.0/43-parametros-tema.png
git add docs/manual-1.0.0/44-plano-oscuro.png
git add docs/manual-1.0.0/45-aviso-no-es-baplie.png
git commit -m "T-139: manual de usuario de la 1.0.0 con 45 figuras, su informe y las herramientas del banco Web"
git push
```

Las dos figuras de Carlos, cuando existan:

```
git add docs/manual-1.0.0/05-instalar-android-play.png
git add docs/manual-1.0.0/06-instalar-web.png
git commit -m "T-139: figuras 5 y 6, la instalacion en Android y en la Web"
git push
```
