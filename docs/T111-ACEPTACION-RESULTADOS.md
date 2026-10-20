# T-111 · Aceptación cruzada de la tarjeta del viaje a 360 dp y de «1 celda reservada» — resultados (Timonel)

**Dictamen: ACEPTADA, con observaciones.** El cambio de `3cfd0e1` hace lo que pide la ficha y pasan todos los criterios de «Terminada cuando». **En el Honor quedan resueltos los tres casos que encontré esta mañana**: «Contenedores» entero a letra 1.0, y «Contenedores», «7419.5 t» y «Peso Total» enteros a 1.45, más «1 celda reservada». No encontré ningún defecto. Las observaciones están en la sección 8; la principal es que las 13 pruebas nuevas no pueden reproducir el caso de 1.0 del Honor, que cubren mi barrido y el propio Honor.

Timonel (Claude Code), 19-oct-2026, de 15:37 a 16:06, solo y con los permisos de 10.88. Sin Firebase, sin cuentas, sin git de escritura y sin tocar `lib/`.

## 1. Base y copias

- **`git log --oneline -3`:** `0c704c9` (decisión 10.90), `22f3573` y `2312fe5`. `3cfd0e1` (T-111) está debajo y su padre es `83d0dc1`.
- **Lo que hay encima de T-111 no toca código del producto:** `2312fe5` agrega `docs/T107-ACEPTACION-RESULTADOS.md`, `22f3573` cambia `tool/t98_honor_red.ps1` y su informe, y `0c704c9` toca `SPRINT-3.md` y el tablero.
- **Tres copias limpias,** con `git archive` y extraídas con Python, verificadas byte a byte con su manifiesto:

| Copia | Commit | Archivos | Uso |
|---|---|---:|---|
| `%TEMP%\baystream-t111acc-0c704c9\head` | `0c704c9` (HEAD) | 724, 0 distintos | suite, analyze, corpus, barrido, Windows y Web |
| `…\base` | `83d0dc1` (padre de T-111) | 720, 0 distintos | referencias y control de regresión |
| `…\honor` | `0c704c9` | 724, 0 distintos | la app del Honor; solo aquí cambia la identidad Android |

- Entre el padre y HEAD solo cambian la tarjeta, `test/t111_summary_test.dart`, `tool/t111_main.dart`, `tool/t98_honor_red.ps1` y documentos. `pubspec.*` es igual en las tres copias y en el árbol.
- No hay `key.properties` en ninguna copia. No abrí la configuración de Firebase.

## 2. El diff: solo `voyage_summary_card.dart`

- **Mide con lo mismo que dibuja** (`voyage_summary_card.dart:126–155`):
  - las tres etiquetas, con `textTheme.bodySmall`, el estilo de la etiqueta de `_buildStatItem`; el color no cambia el ancho;
  - los tres valores, con `titleMedium` en negrita, el mismo estilo del valor;
  - en `TextPainter`, con el `TextScaler`, la dirección y el idioma activos.
- **Apila los tres indicadores si alguno no cabe** en `(ancho − 32) / 3`. Conserva además la regla anterior: menos de 480 dp de ancho disponible en la tarjeta y letra por encima de 1.5.
- **Si caben, usa el mismo ancho de antes** y los mismos widgets.
- No achica la letra, no pone elipsis, no usa `FittedBox` ni recorta.
- **El texto:** `:187–189` da «N contenedores · 1 celda reservada» o «… N celdas reservadas».
- **No toca nada más:** ni el resto de `lib/`, ni el modelo, el codec, el tema, `lib/main.dart`, los congelados o `pubspec.*`.

## 3. Suite, analyze y corpus (copia de HEAD)

| Validación | Resultado | Registro en `%TEMP%\baystream-t111acc-0c704c9\logs\` |
|---|---|---|
| F1 · suite completa, con el corpus por `--dart-define` | **1047/1047**, código 0, 54 s, **0 omitidas** | `f1-suite.txt` |
| F2 · `flutter analyze --no-pub` | **0 incidencias** | `f2-analyze.txt` |
| F7 · `analyze` con mi instrumento en `tool/` | **0 incidencias** | `f7-analyze-con-instrumento.txt` |
| `// ignore` y `skip:` en `lib/`, `test/` y `tool/` | **0 y 0** | — |
| F3 · referencias en el padre (`83d0dc1`) | 22/22: cotejos de T-108 (10), T-110 (10) y T-110acc (1), y mi barrido (1) | `f3-padre.txt` |
| F4 · corpus: los 36 instrumentos + los cotejos de T-108, T-110 y T-110acc | **178/178** (157 + 10 + 10 + 1), código 0, sin omitidas | `f4-corpus.txt` |

**Los cotejos se comparan contra referencias del padre de T-111**, que capturé yo, no contra HEAD. Pasan los 21: T-111 no cambia ningún dato, aviso ni registro guardado.

## 4. El control de regresión, repetido

Corrí `test/t111_summary_test.dart` sobre la tarjeta del padre (copié la prueba a la copia de `83d0dc1`, sin tocar su `lib/`, y la quité al terminar):

| Fuente del viaje | Resultado en el padre | Las que fallan |
|---|---|---|
| Sintéticos (por defecto) | **9 aprobadas y 4 fallidas** | 360 dp a 1.45 sin reservas; 360 dp a 1.45 con reservas; «mismo ancho»; el singular |
| A07 y A08 reales, por `--dart-define` | **9 aprobadas y 4 fallidas** | las mismas 4 |

Coincide con Codex. Las pruebas detectan el defecto a 1.45 y el singular. **No detectan el de 1.0**, porque cargan Roboto y a 360 dp «Contenedores» cabe con esa fuente (observación 8.1). Registros: `f5-regresion-sinteticos.txt` y `f5-regresion-corpus.txt`.

## 5. Mi barrido de la tarjeta (`tool/t111acc_card_test.dart`)

**El instrumento** dibuja la `VoyageSummaryCard` real, con Roboto, como las pruebas de Codex. Recorre 4 viajes (A07, A03, A08 con 55 reservas y ACC2, un sintético con una reserva), **8 anchos** (300, 320, 340, 360, 400, 480, 600 y 1280 dp) y **6 escalas** (1.0, 1.15, 1.3, 1.45, 1.6 y 2.0): **192 casos**.
- Para cada caso registra si la fila se apila, qué textos se parten (por las cajas de selección del motor) y la huella RGBA de la tarjeta.
- Corre igual en el padre, donde captura la referencia, y en HEAD, donde compara.

**En el padre, cada viaje parte palabras en 17 casos.**
- A 1.0, «Contenedores» en 300, 320 y 340 dp.
- «Contenedores» también a 360 dp desde 1.15 y a 400 dp desde 1.3.
- «Peso Total» y el peso (por ejemplo «7419.5 t») se parten desde 1.15 a 300 dp, desde 1.3 a 320 y 340 dp, y con 1.45 a 360 dp.
- Es el defecto del Honor, que con Roboto aparece unos 20 dp más angosto.

**En HEAD: 0 fallas** (`ref\t111acc\resumen.txt`):
- **Ningún texto partido** en los 192 casos.
- **76 casos conservan la fila y son idénticos píxel por píxel al padre.** Entre ellos están los 18 de 1280 dp de A07, A03 y A08, con las seis escalas: **a 1280 dp la tarjeta queda igual que antes.** ACC2 no se compara por píxel, porque cambia su singular.
- **68 casos se apilan, y en todos el padre partía alguna palabra.** Ninguno se apila sin necesidad.
- **48 casos ya se apilaban antes** y siguen igual: los de 1.6 y 2.0 en pantallas de 300 a 480 dp, donde la tarjeta deja menos de 480 dp (regla anterior).
- **ACC2:** en los 48 casos, el padre decía «2 contenedores · 1 celdas reservadas» y HEAD dice «2 contenedores · 1 celda reservada». En A07, A03 y A08 el resumen de reservas no cambia.

## 6. Windows y la Web, con `t111acc`

**El banco** vive solo en TEMP (`evidencia\t111acc_main.dart`, con sus dos ayudantes). Es el banco de Codex (`tool/t111_main.dart`): la UI real del producto, sin Firebase ni sesión y con el lector protegido por `_NoCloud`, con el namespace `t111acc`.
- Agrega tres botones que cargan A07, A03 y ACC2 por el notifier real y confirman el perfil propuesto, para no depender del selector de archivos.
- Agrega un **modo automático**: carga cada archivo y dibuja la página a ancho completo y en una caja de 360 dp con letra 1.0, 1.45 y 2.0. En cada caso anota qué textos se parten y si la fila se apila.
- Las entradas están en `%TEMP%\…\acc` (copias de A07 y A03, y ACC2). El almacén de Windows es `%TEMP%\…\store-t111acc`, con solo cajas `t111acc_*`.

**Windows** (compilaciones release con código 0, de 60 s y 32 s):
- El control del escritorio fue **denegado** al pedirlo para este banco, y no lo rodeé. Usé el modo automático: el propio banco escribe sus capturas PNG y su informe en `windows-auto\`.
- Lo abrí con `explorer.exe` y lo cerré por PID con `CloseMainWindow`: primero el banco interactivo (PID 30404, padre `explorer.exe` 27556, que no llegué a manejar) y después el automático (PID 28396, padre `explorer.exe` 11280).
- **Con Segoe UI, en los 12 casos ningún texto se parte.**
  - A ancho completo (unos 1265 dp), la fila de siempre: 398 · 21 · 6940.6 t (`CORPUS_A07-ancho-1.0.png`).
  - A 360 dp con letra 1.0, la fila, porque Segoe cabe. Con 1.45 y 2.0, los indicadores apilados (`CORPUS_A03-360-1.45.png`).
  - ACC2 dice «2 contenedores · 1 celda reservada».

**La Web, en Chrome** (Claude in Chrome, pestaña propia visible, servida solo en `http://127.0.0.1:8831/` y detenida al final):
- La captura de Chrome se colgó desde el primer intento, como esta mañana. Compilé el banco con el modo automático para la Web, que deja su informe en una variable de la página (`window.t111accReport`), y lo leí desde Chrome (`evidencia\chrome-informe.txt`).
- **En los 12 casos, ningún texto se parte**, con el mismo patrón que Windows: a 360 dp, fila con 1.0 y apilado con 1.45 y 2.0; a ancho completo, fila. ACC2 dice «1 celda reservada».
- Antes, con los botones normales, la semántica de Chrome ya daba los textos completos: «398 Contenedores 21 Bahías 6940.6 t Peso Total», «369 Contenedores 27 Bahías 7419.5 t Peso Total» y «2 contenedores · 1 celda reservada».
- **El navegador integrado no sirvió:** con su panel oculto, Flutter no recibió ni clics ni la activación de la semántica. No uso nada de él como evidencia.

## 7. El Honor, a 360 dp

**La app:** `honor19`, la misma de esta mañana, **actualizada a HEAD** con `install -r`, así que conserva sus cuatro viajes.
- Compilada desde la copia `…\honor`: `applicationId` `gt.cmartinez.baystream.honor19`, entrada `tool/honor19_main.dart` y configuración por `--dart-define-from-file`, sin abrirla. Release sin `--no-pub`: código 0, 79 s.
- 66 298 035 bytes, SHA-256 `c09bffa02b24acce69ee8f557e199b7b89cf6fc5788deb036b291cd771d0ed69`. No es `debuggable`.
- **Nadie inició sesión,** y la página «Nube y cuenta» no se abrió.

**Los viajes se reabrieron desde Recientes,** que dibuja la misma tarjeta. Capturas en `%TEMP%\baystream-t111acc-0c704c9\evidencia\`, recortadas en memoria sin la barra de estado (`tool/honor19_capturas.py`):

| Caso de esta mañana | Letra | Resultado | Captura |
|---|---|---|---|
| A07: «Contenedore / s» | **1.0** | Indicadores apilados; «Contenedores», «Bahías», «6940.6 t» y «Peso Total» **enteros** | `honor-a07-letra10.png` |
| A03: «Contene / dores», «7419.5 / t», «Peso / Total» | **1.45** | Apilados; «Contenedores», «**7419.5 t**» y «**Peso Total**» en una línea cada uno | `honor-a03-letra145-arriba.png`, `…-abajo.png` |
| ACC2: «1 celdas reservadas» | **1.0** | «2 contenedores · **1 celda reservada**», indicadores enteros | `honor-acc2-letra10.png` |
| ACC2 | **1.45** | Lo mismo; el resumen salta de línea entre «celda» y «reservada», no dentro de una palabra | `honor-acc2-letra145-arriba.png`, `…-celda.png` |
| ACC2 | **2.0** | Indicadores apilados y enteros; el volcado da «1 celda reservada» | `honor-acc2-letra20.png` |
| A07 | **2.0** | «398 Contenedores», «21 Bahías», «6940.6 t» y «Peso Total», enteros | `honor-a07-letra20-arriba.png`, `honor-a07-letra20.png` |

**A 1.0, el Honor apila y Windows y Chrome no.** La fuente del sistema del Honor es más ancha, y es justo lo que la medición tiene que detectar.

**Cómo quedó el Honor** (`honor-inicial.txt`, `honor-final.txt`, `cambios-del-honor.txt`):
- `font_scale` pasó a 1.45 (16:00:46) y a 2.0 (16:01:56), y quedó en **1.0** (16:02:44).
- `wm size` 720x1600 y `wm density` 320, **sin tocar**.
- Sin modo avión y con el Wi‑Fi encendido, igual que al llegar.
- `honor19` quedó cerrada, sin PID.
- **De los 46 paquetes BayStream, solo cambió `honor19`,** mi app, por la actualización. Las otras 45 conservan su `lastUpdateTime`, incluidas demo17 y la `t111.t98` de Codex.
- No metí archivos nuevos: usé los de `Download/honor19`, ya indexados esta mañana.

## 8. Observaciones (ninguna impide aceptar)

1. **Las 13 pruebas no ven el caso de 1.0.** Cargan Roboto, y a 360 dp y 1.0 «Contenedores» cabe con esa fuente, así que sobre el padre esas pruebas también pasan. El defecto de 1.0 depende de la fuente del Honor. El arreglo sí lo resuelve, porque mide con la fuente activa: lo muestran mi barrido (a 1.0 el padre parte en 300–340 dp y HEAD no) y el Honor. Si se quiere que la suite lo atrape, basta un caso a 1.0 y unos 320 dp.
2. **«1 contenedores».** El mismo resumen sigue sin singular para los contenedores (`voyage_summary_card.dart:187`), si hay reservas y un solo contenedor. Codex ya lo anotó y la ficha no lo pedía.
3. **Las etiquetas están escritas dos veces.** Se miden con la lista de `:148` y se dibujan con los literales de `:161`, `:169` y `:177`. Si alguien cambia una sola, la medición deja de corresponder a lo dibujado. Es un detalle de mantenimiento, para el rediseño.
4. **En el Honor, con letra 1.0, la tarjeta ahora es más alta,** porque los tres indicadores van en columna. Es lo que pide la ficha, ninguna palabra partida; lo anoto porque cambia lo que el planificador ve al abrir un viaje en el teléfono.
5. **Del proceso:** el control del escritorio para Windows fue denegado, la captura de Chrome se colgó y el panel integrado oculto no recibió la entrada. Por eso Windows y la Web se comprobaron con el modo automático del banco, que mide desde dentro de la app. Lo declaro.

## 9. Archivos de esta aceptación

**Nuevos:**
- `docs/T111-ACEPTACION-RESULTADOS.md` (este informe)
- `tool/t111acc_card_test.dart`: mi barrido. Se corre con `BAYSTREAM_CORPUS_DIRECTORY`, `T111ACC_OUTPUT` (en TEMP) y, en el padre, `T111ACC_CAPTURE_BASELINE=true`.

No cambia `lib/`, `test/`, `pubspec.yaml` ni `pubspec.lock`. Las evidencias quedan en `%TEMP%\baystream-t111acc-0c704c9\`.
