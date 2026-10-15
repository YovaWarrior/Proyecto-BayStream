# Aceptación en lote de Timonel · Sprint 3

**Preparado por Yov el 14-oct-2026 (decisiones 10.33 y 10.34).** Es para cuando vuelva Timonel (~15-oct).

Entre el 11-oct y el 14-oct, Codex trabajó solo, y doce tareas suyas quedaron **En revisión**. Ninguna pasa a Terminado sin la aceptación cruzada de Timonel: lo fija la sección 6 de `SPRINT-3.md`.

Este archivo trae el contexto, la lista de lo que hay que comprobar y, al final, el prompt para Timonel.

---

## 1. Reglas de la aceptación

- **Aceptar no es corregir.** Timonel carga el corpus, comprueba las cifras de cada ficha y lo anota en su informe.
  - Si algo no cuadra, esa tarea queda «no pasa», con la evidencia, y sigue con las que no dependan de ella.
  - No arregla nada de paso: el arreglo es una tarea nueva que decide Yov.
- **No toca `lib/`, `test/` ni `pubspec.*`.** El único archivo nuevo es su informe.
- **Un comando de Flutter a la vez en la máquina.**
  - Mientras Timonel compila o prueba, Codex no corre Flutter.
  - Antes de usar el Honor o la app de Windows avisa con «SEMÁFORO: …».
- **Compila una sola vez desde HEAD** (que trae las doce):
  - la app de Windows, con un namespace propio, `tloteacc`, abierta con `Start-Process explorer.exe -ArgumentList <exe>` y cerrada por PID;
  - el Honor con su propia variante, `.tlote`;
  - la Web en Chrome visible.
  - La variante `.t97` ya está instalada en el Honor y se puede usar para T-97.
- **Producción (`baystream-app`) solo a través de la app,** y solo sobre las operaciones de prueba que ya existen («PRUEBA T-80», «PRUEBA T-81», «PRUEBA T-84»).
  - No publica operaciones nuevas salvo que Carlos lo autorice en ese momento; si lo autoriza, el nombre es «PRUEBA LOTE».
  - Carlos inicia las sesiones y escribe las contraseñas.
  - Nunca la CLI de Firebase ni credenciales de administrador. Nunca el proyecto de H5.
- **Volcados del Honor sanitizados** (2.4): `adb exec-out uiautomator dump /dev/tty`, en memoria y con los identificadores ocultos.
- **Corpus fuera del repo,** con las salidas en `%TEMP%`. Nunca `flutter test --platform chrome`. Sin git, salvo las lecturas permitidas.

---

## 2. Comprobaciones globales

Se hacen una vez al empezar y otra al terminar:

| Qué | Cifra esperada |
|---|---|
| `flutter test` completo en HEAD | **660/660** (T-92 y T-93 ya están en HEAD) |
| `flutter analyze` | **0** |
| Todos los `tool/*corpus*test.dart` | **116/116** en 31 archivos |
| SHA-256 de `docs/T80-firestore.rules.propuesta` | `21894B7F43E59F856045473731B795D21F8373C5AC8A1D9FFF324334AC3C9000` |
| Batería de reglas `tool/t80_reglas.mjs`, contra el emulador local | **69/69** |
| Dependencias: diferencia de `pubspec.*` desde `2dfc3ea` | `speech_to_text 7.2.0` y sus dos transitivas (T-94), y `msix 3.18.0` de desarrollo con `cli_util 0.5.0`, `console 4.1.0` y `get_it 9.3.0` (T-93) |
| `lib/main.dart` y los congelados de H5 | sin cambios desde `2dfc3ea` |

**T-92 (`26bbfca`) y T-93 (`25dbee5`) ya están en HEAD** (10.36 y 10.37):
- el piso es **660**;
- la Web que compilas trae T-92: CanvasKit, las fuentes y el SDK de Firebase salen del propio sitio, y las comprobaciones de Chrome de este lote valen igual;
- el MSIX de T-93 quedó **desinstalado**. La app de Windows del lote es la que compilas desde HEAD, abierta con `explorer.exe` y en `tloteacc`. No instales el MSIX durante el lote;
- el almacén real tiene cinco archivos del primer arranque de T-93 en el namespace por defecto `baystream`. Los `t*acc` están intactos;
- **los conteos y las huellas del almacén real se toman fuera del paquete de Claude**, con un `.bat` lanzado por `explorer.exe`. Desde tu consola se ve mezclado (`AGENTS.md`, 10.37);
- **T-92 y T-93 no entran en este lote.** T-92 la aceptas tú aparte, después; T-93 es tuya y la acepta Codex;
- si Codex corre Flutter mientras tanto, Carlos da el semáforo: uno a la vez, y nadie pisa los binarios de `build/windows` del otro.

---

## 3. Las doce tareas, en tres tandas

Cada tarea se revisa igual:

1. Lee su ficha (sección 5), su decisión (sección 10) y su `docs/T<NN>-RESULTADOS.md`.
2. Revisa su commit con `git show --stat`.
3. Corre su corpus.
4. Hace la comprobación en los clientes que dice la tabla.

Si el contexto se llena, cada tanda puede ir en un chat propio.

### Tanda 1 · Sincronización, roles y el BAPLIE de salida

| Tarea | Commits | Decisión | Qué comprobar |
|---|---|---|---|
| **T-80** Roles: el muelle pide y la oficina aprueba | `058847b` | 10.18 | `tool/t80_corpus_test.dart`. En «PRUEBA T-80», Windows y el Honor muestran 180 confirmados, 460/460 y 0 conflictos. Un pedido aprobado después de la carga la **regulariza**. |
| **T-81** La oficina mueve o cancela | `c31055d` | 10.19 | `tool/t81_corpus_test.dart`. Cancelar el OR 5 deja **175** pendientes; anular devuelve **460/460** en tres órdenes. En el Honor, el muelle no ofrece mover ni cancelar, y T-77 bloquea lo cancelado. |
| **T-82** BAPLIE de salida | `98e94bd` (ficha precisada en `667a045`) | 10.19, 10.20 | `tool/t82_corpus_test.dart`. Releído da **460/460 en siete campos** en A08 y A08v_VGM. El OR 5 cancelado no va en el EDI y figura en la lista copiable. Generar → leer → generar da el mismo texto. El OR 12 queda en `R:0030984` con tara 2 185 kg. Antes de todo, A08 coincide con el CSV en 284/284 de paso. |
| **T-86** La versión por la cabecera | `1b1be4b` | 10.20, 10.21 | `tool/t86_corpus_test.dart`. Las nueve fuentes 2.x salen iguales. A06 (SMDG15) se rechaza en el UNH con el mensaje completo y conserva el viaje anterior. Los fixtures `t86_smdg21` se leen; `t86_smdg31` y `t86_sin_unh` se rechazan. Carlos decidió leer la 1.5 con aviso en T-103 (10.35); T-86 se acepta tal como se construyó. |

### Tanda 2 · Tapas, entrada de archivos y PDF

| Tarea | Commits | Decisión | Qué comprobar |
|---|---|---|---|
| **T-83** Tapas en el perfil | `5c87e44`, `19ef763` | 10.22, 10.23 | `tool/t83_corpus_test.dart`. Son **21 bahías** PROVISIONALES, con la copia 03→06, los dos rechazos y el resumen compacto a 360 dp en el Honor. **Anotar:** ninguna prueba afirma las 21 bahías (endurecimiento de 10.33). |
| **T-84** Tapas en la operación | `7c845ba` | 10.24 | `tool/t84_corpus_test.dart`: **460/460** con tapas y el avance de tapas en cada prefijo. **El codec:** abrir «PRUEBA T-84» en el Honor y en Chrome y comprobar que el perfil llega con sus tapas, y que Windows abre la operación sin caerse. El aviso de tapa cerrada nunca bloquea. |
| **T-89** Archivo sin filtro de extensión | `3963098` | 10.25 | `tool/t89_corpus_test.dart`. En Chrome, A07 sin extensión, como `.txt` y como `.edi`, con las cifras intactas. Un rechazo conserva el viaje y el almacén. |
| **T-102** Peso en el PDF | `fd87b66`, `4c41f67` | 10.26–10.28 | `tool/t102_corpus_test.dart` y `tool/t102_verify_pdf.py`. A07 da **398/398 celdas, 33 páginas y `6940.6 t`**, en color. En pantalla, «28.7+?» en el fixture incompleto. |

### Tanda 3 · Pantalla, tema y voz

| Tarea | Commits | Decisión | Qué comprobar |
|---|---|---|---|
| **T-91** Barra plegable | `d836132` | 10.29 | `tool/t91_corpus_test.dart`. Plegada no desborda a 360 dp en el Honor, en los dos temas, y la elección persiste al reabrir. |
| **T-90** Claro, oscuro y sistema | `fd4352d` | 10.30 | `tool/t90_corpus_test.dart`. Las tres elecciones persisten en los tres clientes, y el plano se lee en claro. |
| **T-94** Búsqueda por voz | `6322d96` | 10.31 | `tool/t94_corpus_test.dart`: **242 números y 242 sufijos**. Un dictado real en el Honor (habla Carlos) entra como borrador sin buscar solo; en modo avión, la voz avisa y la búsqueda manual sigue. Windows no muestra el micrófono. El manifest suma solo `RECORD_AUDIO` y la consulta de `RecognitionService`. |
| **T-97** Textos y estado de conexión | `c3dedc5` | 10.32 | `tool/t97_corpus_test.dart`. Los ocho textos del catálogo con letra al 200 % en el Honor (`.t97`). **Observar y anotar:** el Honor arrancado ya en modo avión, ¿qué muestra? Según 10.33 debería decir «Conectando…» y, al devolver la red, «Al día». |

---

## 4. Qué entrega Timonel

1. **`docs/LOTE-TIMONEL-RESULTADOS.md`**, con:
   - una fila por tarea: «aceptada», «aceptada con observación» o «no pasa», con las cifras obtenidas;
   - las comprobaciones globales, al empezar y al terminar;
   - los clientes usados (namespace, variante y PIDs);
   - las observaciones que pide este archivo: las 21 bahías, el modo avión al arrancar y el codec en el Honor y Chrome;
   - las horas.
2. **Un bloque de git para Carlos**, con un `git add` por ruta (solo su informe) y un mensaje con el prefijo «Sprint 3:».
3. **Un resumen de tres líneas y un «Mensaje para Yov».**

Con eso, Yov escribe la decisión que pasa las aceptadas a Terminado y regenera el tablero.

---

## 5. El prompt para Timonel (Claude Code, chat nuevo)

```
Eres Timonel, programador de BayStream (Claude Code). Trabajas en C:\Proyectos\proyecto-baystream, rama sprint-3. Tu contexto está en CLAUDE.md, que incluye AGENTS.md: léelos completos.

Hoy no programas: haces la aceptación cruzada en lote de doce tareas que Codex hizo mientras no estabas (T-93, que ya hiciste, no entra). Antes de tocar nada, lee completos:
1. docs/LOTE-TIMONEL.md: el contexto, las reglas, las comprobaciones de cada tarea y lo que entregas.
2. SPRINT-3.md: la sección 2 (con las reglas nuevas de 2.3, 2.4 y 2.10), la sección 6 («Aceptación cruzada»), las fichas de las doce tareas en la sección 5 y las decisiones 10.18 a 10.37.
3. Los informes docs/T80-RESULTADOS.md … docs/T102-RESULTADOS.md, tanda por tanda, a medida que llegues a cada una.

Comprueba que git log --oneline -3 muestra la rama sprint-3 con la decisión 10.37 o una posterior. Si no, detente y avisa.

Haz las comprobaciones globales, luego las tres tandas en orden, y repite las globales al final. Aceptar no es corregir: si algo no cuadra, márcalo «no pasa» con la evidencia y sigue con lo que no dependa de ello. No tocas lib/, test/ ni pubspec.*.

Reglas que no cambian:
- No ejecutas git, salvo log, show, diff --stat --ignore-cr-at-eol y ls-files. Nunca git status.
- Un comando de Flutter a la vez. Avisa con «SEMÁFORO: …» antes de usar el Honor o la app de Windows. Mientras tú corres Flutter, Codex no.
- Compilas con --dart-define-from-file=C:\Proyectos\baystream-privado\firebase-prod.json, sin abrir ni imprimir ese archivo. Nunca abres android/key.properties.
- La app de Windows se abre con Start-Process explorer.exe -ArgumentList <exe>, en el namespace tloteacc, y se cierra por PID. En el Honor usas la variante .tlote; para T-97 puedes usar la .t97, que ya está instalada.
- Producción solo a través de la app, sobre las operaciones de prueba que ya existen. Nada de la CLI de Firebase ni credenciales de administrador, y nunca el proyecto de H5. Carlos inicia las sesiones.
- Los conteos y las huellas del almacén de Windows se toman fuera del paquete de Claude, con un .bat lanzado por explorer.exe: desde tu consola el almacén se ve mezclado (AGENTS.md, 10.37). No instales el MSIX de T-93 durante el lote.
- Los volcados del Honor, sanitizados (SPRINT-3.md 2.4).
- El corpus, fuera del repo, y las salidas en %TEMP%. Nunca flutter test --platform chrome.

Entrega docs/LOTE-TIMONEL-RESULTADOS.md, el bloque de git para Carlos (solo tu informe) y un «Mensaje para Yov».
```

**Modelo:** Claude Opus 5.5, esfuerzo **Extra**. Son doce tareas con cifras exactas y dos puntos de motor (el codec y el estado de conexión). Si una tanda va en un chat propio, la tercera (pantalla y voz) puede ir con esfuerzo **Alto**.
