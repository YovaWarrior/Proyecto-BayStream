# T-120, entrega 2 · Aceptación de GLM (22-nov)

La entrega 2 de T-120, el plano y la oficina (O-119-1, O-128-4, O2, O-120-4,
O-120-5, D9 precisada y las pruebas de la lista corta y de la matrícula
repetida), sobre la punta `fcc8302` de `sprint-4` (`7ace4b4`, la entrega,
mezclada con `261ee4b`, la entrega 2 de T-147).

## Dictamen

**PASA, con un hallazgo nuevo (T120-E2-01, P3) que no detiene la aceptación.**

Todo lo que el encargo (10.169) pide como criterio pasa: `analyze` en cero en
la copia limpia y en el Dart versionado de esta carpeta; la suite, 2558 de
2558 en una sola corrida, sin omitidas ni fallidas; `pubspec.yaml` y
`pubspec.lock` idénticos a `261ee4b`, versión `1.0.3+12`; las 13 pruebas rojas
contra `261ee4b`, cada una en su comprobación y ninguna de compilación; las
cinco corridas de Windows y las cinco de la Web terminan en «fin», cada corrida
de la Web con el programa de la carpeta que se sirve; lo prometido se ve en la
pantalla, de día y de noche; y las sondas de «tratar de romper» no rompieron
nada de lo corregido, salvo un caso borde nuevo de la matrícula repetida que va
abajo.

## La tabla

| Punto | Resultado | Evidencia (`build/t120/glm-e2/`) |
|---|---|---|
| 0 · `git log --oneline -4` y `git show --stat HEAD~1` | La punta es `fcc8302` (10.169), debajo `7ace4b4` (la entrega 2) y `261ee4b` (la mezcla); el commit de la entrega trae exactamente las 18 rutas de E2.11 | `paso0/git-log-oneline-4.txt`, `paso0/git-show-stat-head-1.txt` |
| 0 · `flutter pub get --offline --enforce-lockfile` (esta carpeta) | Salida 0 | `paso0/pubget-carpeta.txt` |
| 0 · SHA-256 de la entrada de T-124 | `d4384834fb9fc9cb18632b87180a7998cc3f91109edcbd33dbbf9787542d1162` — la pedida | `paso0/sha256-t124-entradas.txt` |
| A1 · Dos copias limpias en `%TEMP%\t120-glm2` (`despues` = HEAD, `antes` = `261ee4b`), sin tuberías, cada una con la entrada de T-124 y su `pub get` | Ambas `pub get` con salida 0 | `a/semaphore-pubget-copias-*.txt`, `%TEMP%\t120-glm2\despues-pubget.txt`, `antes-pubget.txt` |
| A2a · `flutter analyze --no-pub` en `despues`, todo el paquete | **«No issues found!»** (64.8 s) | `%TEMP%\t120-glm2\analyze-despues.txt` |
| A2b · `flutter analyze --no-pub lib test tool integration_test` en esta carpeta | **Cero** (13.1 s). No hizo falta `dart analyze --cache` | `a/analyze-carpeta.txt` |
| A3 · La suite en `despues`, una sola corrida | **`+2558: All tests passed!`**, sin `~` ni `-` | `a/suite-despues.txt` |
| A4 · `pubspec.*` contra `261ee4b` | **Idénticos**; versión `1.0.3+12` | `diff` en la sesión; las copias en `%TEMP%` |
| B5 · `t120_pellizco_test.dart` en `antes` | **Fallan 5 de 8** (2 de O-119-1 y 3 de O-128-4), ninguna de compilación | `b/rojas-pellizco.txt` |
| B5 · `t120_selector_nombre_test.dart` en `antes` | **Fallan 4 de 4** | `b/rojas-selector.txt` |
| B5 · `t120_e2_lista_test.dart` en `antes` | **Fallan 4 de 15** (las 2 de O-120-5 y las 2 de O-120-4 a 1366 y a 360) | `b/rojas-lista.txt` |
| B6 · `t120_filtros_matriz_test.dart` de la punta en `antes` | **Fallan 6** — sus seis casos del teléfono (360 × 800 y 599 × 900, letras 1.0, 1.45 y 2.0): esperan 2 renglones y `261ee4b` da 3. El registro que faltaba (10.169) | `b/rojas-matriz.txt` |
| C7 · Entradas con `t120e2_buques.dart` | **977** contenedores (977 matrículas); **200** con VELAG 2 y sin destino 2; **12** con 11 matrículas y el aviso `duplicate` | `c/buques-salida.txt` |
| C8 · Banco en `%TEMP%\t120-glm2\banco` (`t99_copia.ps1 -Arbol -Sufijo r4`) + build Windows release | Compiló (nota abajo, primer intento fallido por el SDK de Firebase) | `c/pubget-banco.txt`, `c/build-windows-banco*.txt` |
| C8 · 5 corridas de `t120e2_windows.py` | **30, 8, 12, 8 y 1 capturas**, cada `pasos.jsonl` en «fin», **0 errores de Flutter y 0 textos que no caben** (la de foco, con 1 línea a medias que el arnés salta) | `c/windows/final-{977,corta,repetida,pellizco,foco}/` |
| C9 · O-120-5 en pantalla | Se ve, abajo | `c/windows/final-977/capturas/` |
| C9 · O-120-4 en pantalla y en la grabación | Se ve, abajo | `c/windows/final-977/ventana.mkv`, hojas en `d/cuadros-web` y zooms en la sesión |
| C9 · D9 con la lista corta | Se ve, abajo | `c/windows/final-corta/capturas/` |
| C9 · La repetida | Se ve, abajo | `c/windows/final-repetida/capturas/` |
| C9 · Foco | `pellizco_abierto_antes: true`, `pellizco_abierto_despues: false`, `la_rueda_movio_la_columna: true` (37.2 → 137.2); ciclo **hidden → inactive → resumed** | `c/windows/final-foco/pasos.jsonl` |
| C10 · O2, árbol a 1539 × 844 dp (la ventana no dio más: pantalla de 1920 al 125 %) | Los cinco segmentos, **una vez**, en UIA y en MSAA; contra el árbol de la punta de Timonel cambian **exactamente los 10 renglones de los cinco segmentos** y nada más; contra su árbol de la entrega-2, **0 renglones**; `HelpText` de UIA y descripción y ayuda de MSAA de los cinco: **vacíos** | `c/o2glm/o2glm.txt`, `o2glm.json`, pasos en `c/o2glm-pasos/` |
| C11 · El banco sin escenario con UIA y grabación a 60 cuadros | **No se hizo** (opcional, 30 min: no quedó sesión) | — |
| D12 · Build web release del banco | Compiló (51.2 s) | `d/semaphore-build-web-*.txt`, `%TEMP%\t120-glm2\build-web.txt` |
| D12 · 5 corridas de `t120e2_web.py`, a 1366 × 690, perfiles `glm-*` | En las cinco, `programa.es_el_que_se_sirve: true`, `red.json` sin nada cortado fuera de 127.0.0.1, `consola.log` sin errores, «fin» | `d/web/final-{977,corta,repetida,pellizco,foco}/` |
| D12 · La grabación Web (screencast) | 807 cuadros conservados (±1 s de cada toque); se ven, abajo | `d/web/final-977/pantalla-conservada/`, `pantalla-conservada.json` |
| D13 · Sonda propia de Playwright (la descripción emergente y el árbol de Chrome) | **No se hizo** (opcional, 40 min: no quedó sesión) | — |
| E14 · O-120-2 con la misma sonda en los dos lados | **antes 1053.0 dp → punta 1109.0 dp con la letra a 1.0 (+56.0)**; **antes 1964.6 → punta 2031.2 con la letra a 2.0 (+66.6)**. Suma dato a O-120-2 y confirma los «unos 56 dp» de Timonel | `e/sonda-salida-6.txt`, `e/sonda-antes-o1202.txt`, `e/sonda-antes-o1202-l2.txt` |
| E15 · O-128-4 a media seña y a media arrastre | Sin excepción en inactive (teléfono, dos dedos sin `up`), en hidden y paused (el pellizco se suelta y la rueda responde al volver), en arrastre a medias (el banco sintético no arrastra piezas: el gesto pasa igual), y con resumed sin nada: la escala no se movió | `e/sonda-salida-6.txt`, `e/t120_glm_sonda_e2_test.dart` |
| E15 · O-119-1 en pasos de 0.5 % y de 3 %, alejando desde el 300 %, en los topes 75 y 300 %, con la rejilla al extremo derecho y con la letra a 2.0 | **Peor desvío 0.000 dp en los seis casos** (84 a 488 medidas reales por caso); en los topes el zoom queda clavado en 3.000 y 0.750; alejando, la bahía vuelve a caber (alcance 0). Nada pasa de 0.25 dp | `e/sonda-salida-6.txt` |
| E15 · O-120-4 a golpes | Dos barras sin esperar: la Lista queda pintada, con el título arriba; de una barra a la Lista, Atrás y otra barra: pintada; tocar una barra y cambiar de pestaña antes del cuadro siguiente: al volver por el riel, la Lista **se ve desde el primer cuadro** (no queda con opacidad 0) | `e/sonda-salida-6.txt` |
| E15 · O-120-4 y el lector | Con la semántica encendida, tras llegar de una barra, el título y la primera tarjeta están en el árbol | `e/sonda-salida-6.txt` |
| E15 · O-120-5 a 320 dp, con letra 1.45 y con las tres cargas en cero | Los tres casos: los chips enteros y dentro de la pantalla, sin «Ver las 3 cargas»; con VELAG los tres quedan en cero, apagados, y nada se desborda | `e/sonda-salida-6.txt` |
| E15 · Una matrícula en tres celdas | La Lista enseña **13 tarjetas** (una por celda), sin excepción; el filtro de su naviera deja **4**; el buscador da **3** resultados con esa matrícula. Al soltar el filtro: **T120-E2-01** (abajo) | `e/sonda-salida-6.txt` |
| E16 · Android en el emulador | **No se hizo** (opcional; no se arrancó ningún emulador) | — |
| F17 · Los dos monitores y el pellizco de verdad (escenario `mano`) | **Pendientes, con Carlos y Timonel.** No los hice ni los doy por vistos | — |

## Lo que se vio en pantalla, captura por captura

### Windows (banco de la punta, `%TEMP%\t120-glm2\banco`)

**O-120-5** (`final-977/capturas/`):
- `360x800_claro_letra1.0_o1205_fila_de_carga.png`: la fila «Carga especial»
  con **«Peligrosa IMDG 81», «Refrigerado 97» y «Fuera de medida 19», enteros,
  uno por renglón, cada uno con su ícono**; no hay «Ver las 3 cargas»; debajo,
  «Contenedores (977)».
- `360x800_oscuro_letra2.0_o1205_fila_de_carga.png`: de noche con la letra a
  2.0, los tres chips siguen enteros, uno por renglón, y siguen **«Ver las 4
  navieras»** (con Todas y LNA a la vista) **y «Ver los 10 destinos»**.
- `1366x690_oscuro_letra1.0_o1205_fila_de_carga.png`: a 1366 la fila va como
  antes, **en un renglón**, con el rótulo a la izquierda.

**O-120-4** (la grabación `final-977/ventana.mkv`, 1582 × 853 a 60 cuadros/s;
1533 cuadros en 33.06 s de línea: `gdigrab` dejó huecos, así que los cuadros se
sacaron por su hora, no por su índice; hojas y zooms guardados en
`d/cuadros-web/`):
- Toque 1 (claro, 1366): Estadísticas → Lista con el título. El cuadro vacío no
  quedó entregado (se fue en un hueco).
- Toque 2 (claro, 360): Estadísticas → **1 cuadro con el cuerpo del teléfono
  vacío** (la cabecera «BUQUE LISTA» y el riel inferior, sin resumen, sin
  botones, sin filtros, sin título) → la Lista con «Contenedores (98), destino
  PAMIT» arriba.
- Toque 3 (oscuro, 1366): Estadísticas → **2 cuadros con la columna central
  vacía** (cabecera, riel izquierdo y panel «En vivo») → el título.
- Toque 4 (oscuro, 360): Estadísticas → el título directo (el vacío se perdió
  en un hueco; dos cuadros muestran la Lista con el riel todavía en Estad.).
- **En ningún cuadro de ningún toque se ve la Lista arriba** (ni el resumen del
  viaje, ni los botones, ni los filtros).
- Por dentro, el conductor lo dice con sus cifras: cuadro 1 con el título
  dispuesto a 816.0 dp (1366) y 1186.0 (360), **sin pintarse**; desde el cuadro
  2, a 0 dp (`final-977/pasos.jsonl`).

**D9, la lista corta** (`final-corta/capturas/`):
- `1366x690_claro_letra1.0_d9_corta_VELAG.png`: «Contenedores (2), destino
  VELAG» arriba, con las **dos tarjetas enteras** (TSTU0000007, Bahía 002, Fila
  07, Nivel 82; TSTU0000107, Bahía 010, Fila 03, Nivel 84).
- `360x800_oscuro_letra1.0_d9_corta_sin_destino.png`: «Contenedores (2), sin
  destino» arriba y las dos tarjetas enteras (TSTU0000097 y TSTU0000194, ambas
  en Nivel 82), con el desplazamiento en su tope.

**La repetida** (`final-repetida/capturas/`):
- `360x800_claro_letra1.0_repetida_1_aviso.png`: arriba, en el resumen, el
  aviso del lector: «**Matrículas repetidas en EQD: 1 contenedor · revisa esas
  celdas con quien hizo el plan**» (junto al de «Dígito de control inválido»),
  y el título «Contenedores (12)» con 12 Contenedores, 3 Bahías, 252.0 t.
- `360x800_claro_letra1.0_repetida_2_tarjeta_1.png` y `_3_tarjeta_2.png`: las
  **dos tarjetas de TSTU0000003**, una con **LNB · Bahía 002, Fila 03, Nivel
  82** y otra con **LNC · Bahía 002, Fila 05, Nivel 82**. Ninguna dice que la
  matrícula está repetida (O-120-6, ya conocida).

**El foco** (`final-foco/pasos.jsonl`, 1 captura): el pellizco quedó abierto
(`pellizco_abierto_antes: true`), el arnés minimizó y restauró la ventana, el
ciclo de vida pasó por **hidden → inactive → resumed**, el pellizco se soltó
(`pellizco_abierto_despues: false`) y la rueda volvió a mover la columna
(37.2 → 137.2).

**O2** (`c/o2glm/`): el banco abierto con el escenario `monitores` (el Plano
quieto, zoom 1.5), la ventana a su máximo (1539 × 844 dp, la pantalla es de
1920 al 125 %), el árbol sacado con `t117_correccion2_windows.ps1`. En UIA:
«botón Contenido», «botón Número de orden, Sin listado de la agencia», «botón
Carga, 977 pendientes: 977 llenos, 0 vacíos», «botón Destino», «botón Tipo de
vacío» — **cada nombre una vez**. Lo mismo en MSAA («botón de comando …»). El
JSON trae los diez nodos con `Ayuda: ''`/`Ayuda: null`: **la ayuda no llega**.

### La Web (`%TEMP%\t120-glm2\web`, servido en 127.0.0.1:5948)

- En las cinco corridas, `navegador.json` con `es_el_que_se_sirve: true`,
  `red.json` vacío de cortes y `consola.log` sin errores.
- **O-120-5**: `360x800_claro_letra1_o1205_fila_de_carga.png` y
  `360x800_oscuro_letra2_o1205_fila_de_carga.png` (`d/web/final-977/capturas/`):
  igual que Windows, de día y de noche.
- **O-120-4** (el screencast, 3061 cuadros; conservé los 807 de ±1 s de cada
  toque en `pantalla-conservada/`, con su hora en `pantalla-conservada.json`;
las hojas del barrido están en `d/cuadros-web/`):
  - Toque 1 (claro, 1366): Estadísticas → **el cuadro 2186 con la columna
    central vacía** (cabecera, riel con Estadísticas y panel «En vivo», cuerpo
    vacío) → la Lista con el título arriba (2187).
  - Toque 2 (claro, 360): Estadísticas → el título directo; **el cuadro vacío
    no lo entregó el screencast** (lo dice el barrido por estadística de
    píxeles: ninguno de los 220 cuadros del ±1 s tiene el cuerpo uniforme).
  - Toque 3 (oscuro, 1366): **el cuadro 2692, columna vacía de noche** → título.
  - Toque 4 (oscuro, 360): **el cuadro 2926, cuerpo vacío de noche** → título.
  - **Ningún cuadro enseñó la Lista arriba.**
  - Por dentro, igual que Windows: cuadro 1 con el título a 816/1186 dp sin
    pintarse (`pasos.jsonl`).
- **D9**: `1366x690_oscuro_letra1_d9_corta_VELAG.png`: título arriba y las dos
  tarjetas enteras, de noche.
- **La repetida**: `360x800_claro_letra1_repetida_1_aviso.png`: el aviso arriba,
  igual que Windows.

## El hallazgo

**T120-E2-01 (P3) · Al soltar un filtro quedando dos tarjetas de la misma
matrícula a la vista, el rearme de la Lista tropieza con la verificación de
integridad del SliverList.** Con un plan que trae una matrícula en **tres**
celdas (buque sintético de 13 contenedores, el 3.º, el 4.º y el 7.º con
TSTU0000003), la Lista enseña 13 tarjetas sin excepción y el filtro de su
naviera (LNB) deja 4, dos de ellas con la clave `tarjeta-TSTU0000003`
adyacentes; al soltar el filtro, el rearme de `ContainersSliverList` lanza la
aserción del framework `'child == null || indexOf(child) > index'`
(`sliver_multi_box_adaptor.dart:277`), y la cascada sigue («RenderSliverPadding
expected a child of type RenderSliver but received a child of type
RenderErrorBox» y, al desmontar, `'_dependents.isEmpty'`). Son aserciones de
depuración; en release el chequeo no corre, pero la inconsistencia del orden de
hijos es real. Comparte causa raíz con O-120-6 (las tarjetas de una matrícula
repetida llevan la misma clave), que solo había ejercitado el caso de un filtro
que deja **una** de las dos. Reproducción: la sonda `t120_glm_sonda_e2_test.dart`
(en `e/`), grupo «una matrícula en tres celdas»; registro en
`e/sonda-salida-6.txt` y el volcado completo en `e/sonda-salida-2.txt`. Propuesta
de arreglo para la corrección: que la clave de tarjeta incluya la posición de la
celda (o el índice), como el resto del contenido de la tarjeta.

## La medición (O-120-2, con el mismo instrumento en los dos lados)

Con la sonda de widgets que no entra al repositorio (`e/t120_glm_sonda_e2_test.dart`),
a 360 × 800 con el buque de 977 y sin filtros, la primera tarjeta (TSTU0000001)
queda del borde de arriba de la Lista, con el desplazamiento en 0:

| | `261ee4b` (antes) | punta (después) | Diferencia |
|---|---:|---:|---:|
| Letra 1.0 | 1053.0 dp | 1109.0 dp | **+56.0** |
| Letra 2.0 | 1964.6 dp | 2031.2 dp | **+66.6** |

Los «unos 1 109 y unos 2 021 dp» de la entrega 1 salían de otra sonda; con el
mismo instrumento en los dos lados, el renglón que O-120-5 añade se ve y se
mide: +56.0 dp con la letra a 1.0, que es lo que dijo Timonel («unos 56 dp»),
y +66.6 con la letra a 2.0. Suman a O-120-2.

## Lo que no se pudo, y lo que queda anotado

- **Los dos monitores y el pellizco de verdad** (escenario `mano`): pendientes
  de Carlos, con Timonel (F17). No los hice ni los doy por vistos.
- **El punto 11** (el banco sin escenario, la barra de PAMIT por UIA y la
  grabación a 60 cuadros sin el conductor capturando por dentro): opcional con
  tope de 30 minutos; no quedó sesión. De lo ya medido queda el dato con el
  conductor capturando por dentro (1–2 cuadros vacíos grabados por toque).
- **El punto 13** (la descripción emergente de los segmentos al pasar el mouse
  y el árbol de accesibilidad de Chrome, con Playwright propio): opcional con
  tope de 40 minutos; no quedó sesión. Sigue sin medirse qué recibe el lector
  en la Web (10.169).
- **El punto 16** (Android en el emulador): opcional; no se arrancó ningún
  emulador.
- **La sonda del teléfono tras `inactive`**: el dedo de la comprobación movió
  la rejilla 0.0 dp; la comprobación que pasa es la de la entrega (la física del
  desplazable vuelve a ser la de siempre). La arena de gestos de la sonda
  retiene el par de contactos viejos; no lo afirmo como gesto comprobado.
- **Conocidas, no cuentan, con dato que suma**: el pellizco con eventos
  sintéticos en el banco de la entrega dio **0.52 / 0.28 / 0.503 dp**
  (`c/windows/final-pellizco/pasos.jsonl`), las mismas cifras de la punta que
  ya conocíamos: el instrumento no distingue el arreglo de O-119-1; lo verá el
  escenario `mano`. El resto de la lista conocida (O-120-1, O-120-2, O-120-3,
  O-120-4 deja su cuadro con la columna vacía, O-120-6, O-143-3, O-146-1, la
  ayuda de los segmentos en Windows que decide Carlos, DESIGN.md 14.9 y 17.7)
  queda como está; T120-E2-01 suma a O-120-6.
- El árbol de trabajo de esta carpeta trae tres archivos de `windows/flutter/`
  modificados (`generated_plugin_registrant.cc`, `.h`,
  `generated_plugins.cmake`) que **no son de esta aceptación**: no los toqué,
  no los corrompí y no van en el bloque de Git.

## Horas

Por la fecha de mis archivos (el reloj de las líneas `SEMÁFORO:` y de los
registros): de las **10:00:09** (el `pub get` del paso 0) a las **11:28:02**
(último registro de la limpieza), del 22-nov. Una hora y 28 minutos de reloj.
Dentro, las ventanas de Flutter y Dart están estampadas una por una en
`build/t120/glm-e2/{paso0,a,b,c,d,e}/semaphore-*.txt`.

## Cómo trabajé

GLM 5.3 Flash, con el esfuerzo en Max (10.137), corriendo mi consola desde la
**aplicación de escritorio ZCode** de Carlos, en `C:\Proyectos\baystream-qa-r4`
con HEAD separado en la punta de `sprint-4`. Las herramientas `tool/t120e2_*`
corrieron en la copia del banco de `%TEMP%\t120-glm2\banco` y escribieron solo
en su `build/t120/e2`; lo que cito está copiado a `build/t120/glm-e2/` (157 MB,
1072 archivos). Los perfiles de Chrome míos llevaron prefijo `glm-` en
`%TEMP%\t120-e2\perfiles\` y **ya están borrados**; los de Timonel quedaron
intactos. No quedó ningún servidor del banco escuchando. `%TEMP%\t120-glm2\`
(12 GB: las copias `despues` y `antes`, el banco, la compilación Web, el caso y
los cuadros extraídos) se queda para quien revise; se puede borrar entera cuando
se cierre la entrega. El disco quedó en 45.2 GB libres.

**Una incidencia de la máquina, no de la entrega:** la primera compilación del
banco falló porque la extracción del SDK de C++ de Firebase quedó a medias
(12 KB de 8.5 GB) y el CMake trató la carpeta incompleta como «cached extracted
Firebase SDK». Borré la extracción parcial, completé la extracción desde el zip
que CMake ya había descargado en mi banco (963 835 368 bytes, el de la 10.141)
y la segunda compilación salió en 26.6 s. Los avisos MSB8029 de MSBuild sobre
directorios intermedios en `%TEMP%` son los mismos que tuvo el banco de
Timonel. La carpeta `extracted/` que dejé dentro del banco lo explica.

## Git, para que lo ejecutes tú, Carlos

Desde esta carpeta (`C:\Proyectos\baystream-qa-r4`):

```bash
git add -- docs/t120/entrega2/aceptacion-glm.md
git commit -m "Sprint 4: aceptacion de la entrega 2 de T-120"
git push origin HEAD:sprint-4
```

## En tres líneas

- La entrega 2 de T-120 pasa: analyze y suite en verde (2558/2558), las 13 rojas
  contra `261ee4b` confirmadas una por una (más las 6 del teléfono de la matriz,
  cuyo registro faltaba), y lo prometido se ve en pantalla en Windows y en la
  Web, de día y de noche, con el programa de la carpeta que se sirve.
- O-119-1 y O-128-4 aguantaron todos los intentos de romperlos (0.000 dp en seis
  casos del touchpad; el ciclo de vida suelta todo sin excepción); O-120-4 deja
  solo el cuadro con la columna vacía que ya se conocía, y O-120-5 suma su
  renglón medido: +56.0 dp con letra 1.0 y +66.6 con letra 2.0.
- Hallazgo nuevo T120-E2-01 (P3, suma a O-120-6): soltar un filtro dejando dos
  tarjetas de la misma clave a la vista revienta la verificación de integridad
  del SliverList en depuración. Los monitores, el pellizco de verdad y las
  sondas Web opcionales quedan pendientes o sin hacer, con Carlos y Timonel.

## Mensaje para Yov

> Yov, la aceptación de la entrega 2 de T-120 dice **PASA** con un hallazgo
> nuevo que no detiene: T120-E2-01 (P3). Todo el criterio del encargo corre y
> pasa: analyze cero (copia limpia y Dart versionado), suite 2558/2558 sin
> omitidas, pubspec igual a 261ee4b, las 13 rojas confirmadas cada una en su
> comprobación (ninguna de compilación) y las 6 rojas del teléfono de
> `t120_filtros_matriz_test.dart`, cuyo registro no existía (esperan 2 renglones
> y la punta vieja da 3). En pantalla: O-120-5 con sus tres chips uno por
> renglón de día y de noche y a 1366 en un renglón; O-120-4 en la grabación de
> Windows (1–2 cuadros vacíos por toque, la Lista arriba no sale en ningún
> cuadro) y en el screencast (3 cuadros vacíos entregados, 1 se lo saltó
> Chrome, ninguna Lista arriba); D9 con el título arriba y las tarjetas
> enteras; la repetida con el aviso arriba y las dos tarjetas de TSTU0000003
> (LNB fila 03 / LNC fila 05); el foco real suelta el pellizco en Windows y en
> la Web (hidden→inactive→resumed, rueda 37.2→137.2). O2: los cinco segmentos
> dicen su nombre una vez en UIA y MSAA; contra la punta cambian exactamente
> 10 renglones y nada más, y la ayuda de UIA y de MSAA viene vacía (lo de
> Windows lo decides tú). Las sondas no rompieron nada corregido: O-119-1 dio
> 0.000 dp en pasos de 0.5 % y 3 %, alejando desde el 300 %, en los topes, con
> la rejilla al tope y con letra 2.0; el ciclo de vida suelta todo sin
> excepción; la Lista nunca queda sin pintarse a golpes de barras y pestañas;
> a 320 dp y con letra 1.45 nada se desborda. Medí O-120-2 con la misma sonda
> en los dos lados: antes 1053.0 → punta 1109.0 dp con letra 1.0 (+56.0, el
> renglón de O-120-5) y 1964.6 → 2031.2 con letra 2.0 (+66.6). T120-E2-01:
> con una matrícula en tres celdas, soltar el filtro de su naviera deja dos
> tarjetas con la misma clave visibles y el rearme del SliverList lanza
> 'indexOf(child) > index' en depuración (cascada incluida); comparte causa
> raíz con O-120-6 y el arreglo sería una clave con la celda. No se hizo lo
> opcional (banco sin escenario a 60 cuadros, las sondas Web de Playwright y
> Android): no quedó sesión. Monitores y pellizco de verdad siguen pendientes
> de Carlos. La evidencia está en build/t120/glm-e2/ y las copias en
> %TEMP%\t120-glm2\ (12 GB); mis perfiles de Chrome ya están borrados.
