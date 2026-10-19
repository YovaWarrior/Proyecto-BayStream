# T-111 · Tarjeta del viaje legible y reserva en singular

Capitán Codex · 19-oct-2026 · **Entregada para aceptación de Timonel, sin commit.**

Base: `83d0dc1d55358e66d5bc23ccc0b59a284327f8be`, con `8ef6da1` debajo,
como pidió Carlos. Se leyeron AGENTS.md, las secciones 2 y 9, las fichas y las
decisiones 10.81, 10.88 y 10.89 de SPRINT-3.md y los informes indicados.

## Qué cambió

Solo cambia un archivo de producto: `voyage_summary_card.dart`.

- El ancho de cada tercio se contrasta con los tres valores y las tres etiquetas
  completos mediante `TextPainter`, con el estilo, dirección, idioma y
  `TextScaler` activos. Si alguno no cabe, los tres indicadores se apilan.
- Se conserva también la condición previa de letra grande. No se achica la
  letra, no se agrega elipsis y no se recorta el texto para hacerlo caber.
- Cuando caben, se usa exactamente el ancho anterior `(ancho - 32) / 3` y los
  mismos widgets. A 1280 dp se conserva la fila.
- El resumen dice «1 celda reservada» o «N celdas reservadas».

Sin cambios en el resto de `lib/`, modelo, codec, reglas, archivos congelados,
`lib/main.dart`, tema ni dependencias. **`pubspec.yaml` y `pubspec.lock` no cambian.**
La tarjeta conserva CRLF; su contenido, normalizado a LF, coincide con la copia validada.

## Aislamiento y banco

Toda la evidencia está en:

`%TEMP%\baystream-19oct-codex-83d0dc1\`

- `head/`: exportación de HEAD por `git archive`, sin T-111 para aceptar T-107.
- `t111/`: la misma base con la tarjeta, las pruebas y el banco de esta tarea.
- `clients/`: copia de compilación; solo aquí cambia la identidad Android.
- `evidencia/windows/`, `evidencia/web/`, `evidencia/honor/`: capturas.

`tool/t111_main.dart` monta la UI real. Usa el lector real con el adaptador
`_NoCloud` del mismo enfoque que el ensayo de T-98: cualquier acceso remoto
accidental falla explícitamente. **No inicializa Firebase ni inicia sesión.**
La configuración entró en las tres compilaciones mediante
`--dart-define-from-file=C:\Proyectos\baystream-privado\firebase-prod.json`,
sin abrirla. No se abrió ni copió `android/key.properties`.

Almacenes utilizados:

| Cliente | Almacén de prueba |
|---|---|
| Windows | `%TEMP%\baystream-19oct-codex-83d0dc1\windows-store`, namespace `t111`, 12 archivos al comprobarlo |
| Chrome | IndexedDB del origen exclusivo `http://127.0.0.1:11119`, namespace `t111` |
| Honor | Carpeta privada de `gt.cmartinez.baystream.t111.t98`, namespace `t111` |

Windows se abrió por Explorer y se cerró por su PID. **No se consultó ni se
usó el almacén real**, demo17 o «PRUEBA T-105». No hubo Git de escritura ni publicación.

## Pruebas y validaciones

`test/t111_summary_test.dart` agrega **13 casos**:

- Tarjeta a 360×780 dp con letra 1.0, 1.45 y 2.0, con y sin reservas.
  Se comprueban las cajas de selección del motor: una sola línea para cada
  etiqueta y para la cifra con su unidad, sin elipsis ni reducción de escala.
- A 1280 dp, las tres escalas conservan los indicadores alineados y equidistantes.
- A igual ancho de 400 dp, aumentar la letra cambia la fila por una columna.
- Singular, plural, ausencia del resumen sin reservas y el caso `999 kg`.

Por defecto usan sintéticos. Con `BAYSTREAM_CORPUS_DIRECTORY` usan **A07 y A08
reales**, salvo los casos específicos de singular y kilos. Las fuentes del
corpus no entraron al repositorio; sus rutas se pasaron por `--dart-define`.

| Validación ejecutada | Resultado | Registro en TEMP |
|---|---|---|
| Nuevas con sintéticos | **13/13** | `t111-focused-3.log` |
| Nuevas con A07/A08 por define | **13/13** | `t111-real-corpus.log` |
| Suite completa, manifiesto original | **1047/1047**, sin skip = 1034 + 13 | `t111-suite-final.log` |
| `flutter analyze --no-pub` | **0 incidencias**, sin `// ignore:` nuevos | `t111-analyze.log` |
| Los 36 instrumentos habituales del corpus | **157/157** | `t111-corpus157.log` |
| Cotejos T-108, T-110 y T-110ACC contra referencias nuevas de HEAD | **21/21** | `t111-corpus-cotejos.log` |
| Total del corpus y cotejos | **178/178**, sin skip | Los dos registros anteriores |

Las referencias se capturaron primero en HEAD, sin T-111
(`corpus-referencias-head.log`). Los cotejos preservan datos, avisos y formato
guardado; no se presentan como una nueva comparación de T-110 contra su padre.

**Control de regresión:** las mismas 13 pruebas sobre la tarjeta de HEAD,
fuera de la suite, dan **9 aprobadas y 4 fallidas**: los dos casos estrechos a
1.45, el cambio de distribución por escala y el singular. Registro:
`t111-control-head.log`. La copia de HEAD usada antes para la suite de T-107
seguía sin estos archivos durante aquella validación.

Incidencias de preparación conservadas en los registros:

- La primera comprobación de cajas usaba el ancho intrínseco del párrafo y
  detectaba el pequeño saliente de un glifo. Se corrigió para comprobar el
  ancho disponible de su celda, conservando la comprobación de una sola línea.
- Un caso exigía apilar incluso cuando el texto cabía con la fuente de prueba.
  Se ajustó a comprobar el contenido completo y se añadió el caso de ancho fijo.
- La primera suite dio 1046 aprobadas y una fallida por el nombre Android de la
  variante de prueba (T-88). Se separó `clients/` y se repitió con el manifiesto
  original: 1047/1047. No se cambió la prueba de T-88 ni el producto para ocultarlo.

## Clientes comprobados

**Windows:** release de `tool/t111_main.dart`, A07, escala GTSTC.
398 contenedores, 21 bahías y **6940.6 t**, en una fila; etiquetas completas.
Captura: `evidencia/windows/t111-a07-lista.png`.

**Chrome real, visible:** no hizo falta sustituirlo por el navegador integrado.
A07 a 1280×900 y 360×780: palabras y peso completos. Sintético de una reserva
a ambos anchos: **«1 celda reservada»** y **7419.5 t**, completos.
Capturas `evidencia/web/t111-{a07,una-reserva}-{1280,360}.png`.
Se restableció el viewport, se cerró la pestaña propia y se detuvo el servidor local.

**Honor, 360 dp, sin tocar `wm`:**

| Fuente | Letra | Resultado / capturas en `evidencia/honor/` |
|---|---|---|
| A07 | 1.0 | Apilados; «Contenedores», «Bahías», «Peso Total» y `6940.6 t` enteros. `t111-a07-letra10.png` |
| A07 | 1.45 | Lo mismo, con la letra realmente aumentada. `t111-a07-letra145-arriba-final.png` |
| Sintético con una reserva | 1.0 | Indicadores completos y singular. `t111-reserva1-letra10-{arriba,abajo}.png` |
| Sintético con una reserva | 1.45 | `7419.5 t` en una línea; «celda» y «reservada» completas. `t111-reserva1-letra145-{arriba,abajo}.png` |

El sintético está solo en TEMP y en `Descargas/t111codex` del Honor. No es un
buque operativo ni una medición de peso. El texto anterior «1 contenedores»
sigue visible en ese caso; esta ficha corrige el singular de las reservas.
Una captura inicial rotulada 1.45 se tomó antes del redibujado del sistema;
**la evidencia válida es la que termina en `arriba-final`**, comprobada visualmente.

APK release: **65 233 079 bytes**, SHA-256
`bb60ab9b5750704bf6e5bb3727524340a2545f35e5a1ee5498a24ca6f9f30213`.
`aapt` confirma «BayStream T111 Codex» y el paquete propio;
`apksigner verify --print-certs` confirma firma **Android Debug**.
Android se compiló **sin `--no-pub`**. Las tres compilaciones terminaron con código 0.
Los avisos nativos de TEMP, APIs de plugins y fuente Cupertino se conservan en sus
registros de compilación; no son incidencias nuevas de `flutter analyze`.

Las capturas del Honor se recortaron en memoria para quitar la barra de estado;
los volcados se filtraron con `tool/honor19_capturas.py`. No se capturó la página
«Nube y cuenta» ni datos de cuenta. Se indexaron los archivos copiados con
`MEDIA_SCANNER_SCAN_FILE`; no se capturó el selector del Honor.

**Estado final comprobado:** avión 0, Wi-Fi 1 y letra 1.0; app propia detenida.
Los 45 paquetes BayStream previos conservan `lastUpdateTime`; solo se añadió el
paquete propio. Evidencias: `honor-inicial.txt`, `honor-final.json` y los dos
inventarios de paquetes. La misma app HEAD + T-111 sirvió para T-107 y T-98.

## Archivos y Git para Carlos

1. `lib/features/vessel/presentation/widgets/voyage_summary_card.dart` — modificado.
2. `test/t111_summary_test.dart` — nuevo.
3. `tool/t111_main.dart` — nuevo.
4. `docs/T111-RESULTADOS.md` — nuevo.

```powershell
git add -- lib/features/vessel/presentation/widgets/voyage_summary_card.dart
git add -- test/t111_summary_test.dart
git add -- tool/t111_main.dart
git add -- docs/T111-RESULTADOS.md
git commit -m "Sprint 3: corrige tarjeta del viaje y reserva singular T-111"
git push
```

## Tres líneas

La tarjeta apila por el espacio real del texto y conserva la fila cuando cabe.
1047/1047, analyze 0 y corpus 178/178; Windows, Chrome y Honor comprobados.
«1 celda reservada» corregido; entregada para aceptación de Timonel, sin publicar.

## Mensaje para Yov

T-111 entregada sobre 83d0dc1 para aceptación de Timonel. Solo cambia la tarjeta
en lib/: mide etiquetas y valores con el estilo y TextScaler activos, apila si
no caben y corrige «1 celda reservada». Suite 1047/1047 sin skip, analyze 0,
corpus 178/178; 13 nuevas pasan también con A07/A08. Windows y Chrome pasan;
Honor a 360 dp con A07 y una reserva, letra 1.0/1.45, pasa. Banco t111 sin
Firebase ni sesión, Windows en TEMP, Android con identidad propia y firma Debug.
pubspec.* sin cambios. Informe docs/T111-RESULTADOS.md; commit propuesto
«Sprint 3: corrige tarjeta del viaje y reserva singular T-111».
