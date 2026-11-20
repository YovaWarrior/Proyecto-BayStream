# T-120, entrega 1 · La aceptación de GLM 5.3 Flash

**Aceptador:** Capitán Codex (GLM 5.3 Flash, esfuerzo en Max; 10.137 y 10.150).
**Fecha:** 18-nov-2026. **Carpeta:** `C:\Proyectos\baystream-qa-r4`, en la punta
de `sprint-4` (`f29fa2a`, la decisión 10.150), HEAD separado y sin cambios de
archivos versionados.

## Dictamen: NO PASA por un P2

La entrega 1 de T-120 está bien construida y todo lo comprobable pasó: la suite
(2340/2340), `analyze` en cero en los dos lugares, las rojas de la corrección y
de la entrega exactas, el buque de pruebas con la huella pedida, las 94 capturas
del banco limpias y revisadas, el árbol accesible, la Web, el corpus y la
medición de memoria. Pero la aceptación encontró **un caso que ni las pruebas ni
las capturas habían mirado** y que incumple la regla aprobada D9: desde la barra
de «Sin destino» en Estadísticas, la Lista no se abre con su título arriba
(T120-ACC-01, P2). Con el patrón del sprint (10.42, 10.53 y 10.59: un P2 no
pasa la aceptación), corresponde una corrección corta de Timonel con su prueba
roja, y después la reaceptación.

## La punta, verificada (paso 0)

De arriba abajo: `f29fa2a` («decision 10.150»), `e630668` («T-120, entrega 1,
correccion 1»), `d182649` («decision 10.149») y `02169fc` («T-120, entrega 1»).
`git show --stat HEAD~1` trae exactamente las 16 rutas de C1.10 y
`git show --stat 02169fc` las 27 de la sección 13. `flutter pub get --offline
--enforce-lockfile`, salida 0. La entrada de T-124 con la huella
`d4384834…d116` (O-143-3) ✓.

## Tabla de los puntos

| Punto | Resultado | Evidencia (`build/t120/glm-e1/`) |
|---|---|---|
| A.1 Tres copias limpias con `git archive` + entrada T-124 + pub get | ✓ las tres | las copias viven en `%TEMP%\t120-glm-despues`, `-entrega` y `-antes` |
| A.2.a `analyze` todo el paquete en t120-glm-despues | ✓ «No issues found!» (32.1 s) | `analyze-despues-todo-paquete.txt` |
| A.2.b `analyze` del Dart versionado en esta carpeta | ✓ cero (9.2 s); no hizo falta `dart analyze --cache` | `analyze-aqui-versionado.txt` |
| A.3 La suite en una sola corrida | ✓ `+2340: All tests passed!`, sin `~` ni `-` | `suite-despues.txt` |
| B.4 Rojas de la corrección contra `02169fc` | ✓ fallan 11, pasan 3 (R1 de día y las dos guardas) | `rojas-correccion-contra-entrega.txt` |
| B.5 Rojas de la entrega contra `899e4e3` | ✓ fallan 17, pasa «elegir un filtro no hace saltar lo de arriba» | `rojas-entrega-contra-antes.txt` |
| C.6 El buque de las pruebas | ✓ «977 leídos de 977, 9 puertos, 3 sin destino, 97 refrigerados, 81 peligrosos, 19 fuera de medida, 48 refrigerados peligrosos»; 124 100 bytes; SHA-256 `664de202…4a58` | `buque-glm.txt` (el archivo queda en `%TEMP%\t120-buque-glm\`) |
| C.7 El banco y su recorrido | ✓ 94 capturas, `pasos.jsonl` termina en `«fin»`, ningún texto que no cabe ni error de Flutter (94/94 arreglos vacíos) | `pasos-windows.jsonl`; el banco en `%TEMP%\t99-glm-t120\` |
| C.8 Las capturas, miradas | ✓ las 14 revisadas de día y de noche cumplen todas las cifras (detalle abajo) | las capturas quedan en `%TEMP%\t99-glm-t120\capturas\` |
| C.9 El árbol accesible de Windows | ✓ cada chip se oye una vez con su cuenta («USHOU, 195 contenedores»); la barra de puerto es un botón una vez («GTSTC: 391 contenedores, 40 %»); a 360 dp los chips que no caben no están en el árbol (PAMIT, COCTG…, «Fuera de medida» tampoco) | `arbol-accesible\1366-lista.txt`, `1366-estadisticas.txt`, `360-lista.txt` |
| D.10 La Web del banco | ✓ con perfil nuevo de Chrome, solo contra `127.0.0.1:61234`; las cuentas y los textos coinciden; sin errores de consola; al recargar, la página solo habló con `127.0.0.1` | capturas en `%TEMP%\t99-glm-t120\web-capturas\`; `web-build.txt`, `web-servidor.txt` |
| E.11 Dos archivos reales del corpus | ✓ con dos diferencias explicadas (abajo, «Datos para O-120-1») | `corpus-sonda.txt`, `corpus-segmentos.txt`, `sonda-tmp.txt`, `sonda-bloque.txt`, `sonda-orden.txt`, `corpus-diag-destino.txt` |
| F.12 La memoria | ✓ 505.5 MB antes, 159.0 MB después (el mismo orden de magnitud de Timonel: 512.1 y 151.8); corrida en frío descartada y una medida por banco, con `SEMÁFORO:` | `resumen-ram-antes\`, `resumen-ram-despues\`, `ram-antes.csv`, `ram-despues.csv`; bancos en `%TEMP%\t99-glm-ram\` |
| G.13 Las tres mediciones | ✓ O-120-2 y O-120-4 medidas; O-120-5 confirmada por las capturas | `sonda-g.txt`, `sonda-g2.txt`, `sonda-g2-repeticion.txt` |
| G.14 Tratar de romperlo | ✓ con matices (abajo) | `sonda-g.txt`, `sonda-g2.txt` |
| G.15 Android, Atrás en el emulador | ✗ no se pudo (presupuesto de sesión; es opcional) | — |

## Las capturas revisadas (C.8)

Miradas de día y de noche, una por grupo como mínimo: `1b` (el chip
«Refrigerado 97» elegido enseña su copo de noche, a 1366 y a 360 con letra 1.0
y 2.0: el defecto R1 corregido se ve), `1a` (PAMIT 98 con «Todas 98» y LNA 42,
LNB 28, LNC 14, LND 14; título «Contenedores (98), destino PAMIT»; las tres
cargas en 0 y apagadas), `2a`-`2d` (dos líneas por fila; «Ver los 10 destinos»;
la hoja con «Todos 977», GTSTC 391, USHOU 195, PAMIT 98, COCTG 49, USMSY 49,
JMKCT 48, JMKIN 48, PACCT 48, VELAG 48 y «Sin destino 3»; la hoja cerrada sin
elegir; JMKCT elegido queda a la vista), `3a` («Contenedores (3), sin
destino»), `3b` («Otros 3 puertos 99» y «Toca un puerto para verlo en la
Lista», D10), `3d` (la Lista con su título arriba, D9), `4a`-`4c` (la tarjeta
de un fuera de medida y, en su hoja, «Fuera de medida: Frente 30 cm · Alto 25
cm»), y el buscador: «oog» da «19 fuera de medida», «reefer imo» da «130
peligrosos o refrigerados» con TSTU0000030 y sus dos motivos, «reefer GTSTC» da
«48 refrigerados que coinciden con «GTSTC»» con GTSTC resaltado, «imo 3» da «65
peligrosos de clase 3». Todas las cifras coinciden con las que contó Yov.

## La Web (D.10)

Banco r4 de `tool/t99_main.dart` servido con `tool/t99_servidor.dart` en
`127.0.0.1:61234`, compilado en la copia limpia de la punta. Chrome con perfil
nuevo (`--user-data-dir` en `%TEMP%`). Cargué `T120_BUQUE_LISTA_977.edi` por el
selector de archivos (el diálogo nativo con el teclado, porque el
`file_picker` desmonta su input al momento y no es interceptable) y confirmé el
perfil con «No lo tengo» en el límite de apilamiento. Visto de día y de noche,
a 1366 × 690 y a 360 × 800: la Lista con «Refrigerado» elegido (el copo se ve
de noche), PAMIT elegido con sus 98 y sus navieras 42/28/14/14, «Ver los 10
destinos» y su hoja a 360 con las mismas cuentas, la línea de D10 en
Estadísticas, el salto de D9 al tocar la barra de PAMIT (título arriba), y el
buscador con «reefer imo» (130, TSTU0000030 con dos motivos) y «oog» (19). Al
recargar, la página solo habló con `127.0.0.1:61234`; sin errores de consola en
todo el recorrido. Chrome y el servidor quedaron detenidos.

## El corpus real (E.11)

Con `CORPUS_A01.edi` (977 contenedores) y `CORPUS_A03.edi` (369), una sonda en
la copia limpia que lee con `BaplieParserService` y saca las cuentas con
`CuentasDeLosFiltros` y `ConsultaDeBusqueda`, contra mi script de conteo de
segmentos (LOC+11, NAD+CA, TMP y tipo ISO, DGS y DIM), en `%TEMP%`. Lo que
coincide exacto: contenedores leídos, las navieras, las cargas peligrosas (4 y
20), fuera de medida (0 y 0), los cruces en su estructura, «imo» (4 y 20),
«oog» (0 y 0), «imo 3» (1 y 5 contenedores con 1 y 7 declaraciones), «imo 1.4»
(0 y 4; el A03 trae las 4 declaraciones sin letra, O-120-3 no se activa con
archivos reales) y «un NNNN» con el ONU más frecuente de cada archivo (3 y 3).

Las dos diferencias, que no son de la entrega sino del lector:

1. **«reefer»: 50 contra 92 en A01, y 10 contra 11 en A03.** El criterio
   «tipo ISO de refrigerado o un `TMP`» del producto solo cuenta los
   refrigerados por tipo ISO en A01; los 42 `TMP+2+-020:CEL` de contenedores
   `45G1` no marcan `isReefer` ni temperatura. Causa aislada con variantes de
   orden (`sonda-orden.txt`): **un `TMP` que llega después de un `LOC+147` cae
   en un builder ya cerrado y se pierde**; con el EQD al final del bloque, como
   en el buque sintético del generador de T-120, el `TMP` sí se aplica. Es el
   mismo origen de «la tarjeta dice «?°C» sin `TMP`» de O-120-1 (10.149 y
   10.150). **Datos que O-120-1 suma:** 42 de 92 refrigerados del A01 y 1 de 11
   del A03 no aparecen ni en el chip «Refrigerado», ni en el filtro, ni en la
   búsqueda «reefer» (RF-018): la ronda de revisión con archivos reales de esta
   forma se recorta. Sugerencia de prioridad para cuando se decida: P2, con el
   bloque 2 o el 3.
2. **El destino de un contenedor truncado.** En los dos archivos el último
   bloque llega sin `LOC+11` (el mensaje se corta tras el `NAD+CA`), y el
   lector lo cuenta con puerto (`corpus-diag-destino.txt`); por eso mi conteo
   de segmentos lo trae como «Sin destino» y el producto no. Con la regla del
   filtro («sin `LOC+11` o con el código en blanco»), ese contenedor debería
   decir «Sin destino». Cifra: 1 contenedor por archivo. Va anotado junto a
   O-120-1; decide Carlos dónde se trata.

## La memoria (F.12)

Con `T99_SINTETICO_977.edi` (164 312 bytes, el mismo de Timonel) y
`tool/t114_ram_windows.ps1`, bancos `t99-glm-ram\copia-antes` (de `899e4e3`,
con `git archive`) y `copia-despues` (de la punta), identidad `r4`, almacenes en
`%TEMP%`, `-t tool/t99_main.dart`. Una corrida en frío descartada y una medida
por banco, con la máquina quieta y su línea `SEMÁFORO:`:

| Banco | Vuelta a la Lista (estable) | Umbral |
|---|---:|---|
| antes (`899e4e3`) | **505.5 MB** | < 200 MB |
| **después (punta)** | **159.0 MB** | < 200 MB |

El mismo orden de magnitud que Timonel midió (512.1 y 151.8 MB). No dictamino
RNF-001 ni RNF-007: son del bloque 3.

## Las tres mediciones (G.13) y lo que el programador no pensó (G.14)

**O-120-2** (a 360 × 800, buque de 977, sin filtros; distancia del borde de
arriba de la vista a la primera tarjeta, medida desplazando hasta ella):
**unos 1 109 dp con la letra a 1.0 y unos 2 021 dp con la letra a 2.0.**
(`sonda-g2.txt`.) Más de una pantalla en los dos casos.

**O-120-5** (a 360 dp con la letra a 1.0): la fila «Carga especial» enseña
«Peligrosa IMDG 81» y «Refrigerado 97», y «Fuera de medida» queda detrás de
«Ver las 3 cargas», como dice la observación conocida: lo confirman las
capturas del banco (`…2a_ver_los_n_destinos.png` y `…1b_carga_elegida.png`).
La sonda por `ExcludeFocus` no sirvió como medición (marcó los tres chips, la
ruta del árbol no distingue los visibles de los ocultos); manda lo que se ve.

**O-120-4** (al tocar la barra de PAMIT): el título «Contenedores (98), destino
PAMIT» queda a **74 dp** del borde de arriba (primer cuadro) y la primera
tarjeta a 128 dp. El cuadro del parpadeo que anotó Timonel (la Lista arriba
antes de saltar) no se puede medir en una prueba de widgets; pedía grabar la
pantalla y no alcanzó el presupuesto (abajo).

**Tratar de romperlo** (`sonda-g.txt` y `sonda-g2.txt`):

- Dos contenedores con la misma matrícula en celdas distintas: los filtros y
  las cuentas cruzadas no excepcionan; el buscador tampoco. La sonda no llegó a
  construir la Lista con ese viaje (0 tarjetas sin excepción), así que el caso
  de las dos tarjetas con la misma clave queda **no concluyente**: lo revisa
  quien corrija (una prueba de widgets con dos tarjetas de la misma matrícula
  cierra la duda).
- Un buque con 40 destinos: «Ver los 40 destinos» abre su hoja y se desplaza
  sin excepción. Tocar fuera no la cierra (el punto tocado cayó sobre la
  cabecera; el cierre documentado es elegir o el asa, y la captura `2c` del
  banco muestra la hoja cerrada sin elegir).
- «Sin destino» desde su barra, con el buque de pocos puertos: sin excepción,
  pero **no pasa lo de D9** (el hallazgo, abajo).
- El buscador con «IMO», «Reefer», «REFRIGERADOS», «fuera  de   medida» (espacios
  de más), «imo 3 imo 8» (la clase queda 8: la última gana), una consulta de
  500 caracteres y un emoji: todo sin excepción, con su línea de lo que se
  entendió. «IMO» en mayúsculas sí busca la carga peligrosa.
- Los filtros después de ir al Plano y volver: **siguen** (el título dice
  «naviera LNA»). Que se sueltan al abrir otro viaje ya lo cubren las 99
  pruebas de la entrega; no lo repetí con una sonda.
- **Android, Atrás en el emulador:** no se pudo (presupuesto de sesión; era
  opcional y el teléfono se mide en el bloque 3, D5 de la 10.148).

## Hallazgos

**T120-ACC-01 · P2 · Desde la barra de «Sin destino», la Lista no se abre con
su título arriba.** La regla aprobada (D9 de la 10.149, `DESIGN.md` 18.5) dice
que cada puerto y «Sin destino» abren la Lista con el título arriba de lo que
se ve. Con la barra de un puerto (PAMIT) cumple: título a 74 dp. Con la barra
de «Sin destino», con el buque de pocos puertos a 360 × 800, la Lista queda en
el resumen del viaje y el título «Contenedores (1), sin destino» queda a
**483 dp**, repetido dos veces con la misma cifra. Sin excepción: solo falta el
salto. Ni las pruebas de la entrega (la de «Sin destino» solo comprueba que el
título existe; la del título arriba usa USHOU) ni las capturas del banco miran
este caso.

- **Cómo reproducirlo:** con la sonda `t120_glm_sonda_g2_test.dart` (en
  `%TEMP%\t120-glm-t120\`, sobre la copia `%TEMP%\t120-glm-despues`) —
  `flutter test --no-pub test/t120_glm_sonda_g2_test.dart --plain-name "pocos
  puertos"` — o a mano en el banco: abrir Estadísticas con
  `T120_BUQUE_LISTA_977.edi`, tocar la barra de «Sin destino» y mirar dónde
  queda el título.
- **Evidencia:** `sonda-g2.txt` (483.0 dp) y `sonda-g2-repeticion.txt`
  (483.0 dp); la captura del banco nocturno `3b` muestra la línea de D10 y la
  `3a` el chip de «Sin destino», pero ninguna llega desde su barra.
- **Corrección propuesta:** que el salto de D9 se aplique igual cuando el
  destino es «Sin destino», con su prueba roja contra este código.

Los datos para **O-120-1** y la nota del contenedor truncado van en «El corpus
real» de arriba. O-120-2, O-120-3, O-120-5 y las demás conocidas (la matrícula
del buscador que se parte con la letra a 2.0, las dos asas de la hoja, «Ver
los n» con el rótulo más chico, «imo» sola que ya no busca matrículas,
O-143-3, O-146-1) se comportaron como están anotadas; no apareció nada nuevo
de ellas. No dictamino RNF-001 ni RNF-007 (bloque 3).

## Lo que no se pudo, y por qué

- **Android, Atrás en el emulador** (G.15, opcional): no alcanzó el presupuesto
  de sesión.
- **La grabación de pantalla de O-120-4** (los cuadros del parpadeo de D9):
  no alcanzó el presupuesto de los 30 minutos del instrumental; la medida del
  título y de la primera tarjeta sí está.
- **La Lista con matrícula duplicada:** la sonda no llegó a construirla
  (0 tarjetas sin excepción); no concluyente, arriba.
- **La repetición nocturna de PAMIT en la Web:** el toque nocturno cayó en un
  resultado del buscador por el orden de los pasos; el caso lo cubren las
  capturas nocturnas `1a` del banco Windows.

## Horas del reloj

18-nov-2026: de las 13:36 a las 15:30, unas **2 horas de reloj**, en una sesión
continua. Ventanas de `SEMÁFORO:` para Flutter y Dart: los `pub get` y
`analyze`, la suite, las dos series de rojas, el build de los tres bancos de
Windows y el de la Web, las corridas de memoria y las sondas del corpus y de
G; nunca dos a la vez.

## Cómo trabajaste

Modelo **GLM 5.3 Flash**, esfuerzo **Max** (10.137). La consola corre desde la
aplicación de escritorio de ZCode, sobre el proyecto `baystream-qa-r4`. Las
sondas, las copias limpias y los bancos vivieron en `%TEMP%`; nada del corpus
ni de las copias entró al repositorio; no toqué el almacén real, la MSIX,
Firebase, el Honor ni ninguna Release de publicación; no ejecuté escrituras de
Git ni `git status`.

## Git, para que lo ejecute Carlos

Desde esta carpeta (`C:\Proyectos\baystream-qa-r4`):

```powershell
git add -- docs/t120/entrega1/aceptacion-glm.md
git commit -m "Sprint 4: aceptacion de la entrega 1 de T-120"
git push origin HEAD:sprint-4
```

La evidencia queda fuera de Git: `build/t120/glm-e1/` en esta carpeta y las
copias, bancos y capturas de `%TEMP%` (`t120-glm-*`, `t99-glm-t120\`,
`t99-glm-ram\`, `t120-buque-glm\`, `t120-glm-t120\`).

## En tres líneas

- Todo lo comprobable pasó: suite 2340/2340, `analyze` en cero en los dos
  lugares, las rojas exactas, el buque con su huella, las 94 capturas limpias y
  revisadas, el árbol accesible, la Web, el corpus y la memoria 505.5 → 159.0 MB.
- La aceptación encontró un caso que nadie había mirado: **desde la barra de
  «Sin destino», la Lista no se abre con su título arriba** (T120-ACC-01, P2,
  483 dp contra los 74 dp de PAMIT, repetido dos veces).
- **Dictamen: NO PASA por ese P2.** Corrección corta de Timonel con su prueba
  roja, reaceptación, y la entrega 2 puede seguir; el corpus le suma a
  O-120-1 que 42 de los 92 `TMP` del A01 se pierden por llegar tras el
  `LOC+147`.

## Mensaje para Yov

> Yov, la aceptación de la entrega 1 de T-120 está en
> `docs/t120/entrega1/aceptacion-glm.md`, sobre `f29fa2a`: **NO PASA por un
> P2** (T120-ACC-01). Lo que nadie había mirado: desde la barra de «Sin
> destino» en Estadísticas, la Lista no salta a su título (483 dp contra los
> 74 dp de PAMIT, repetido dos veces, con la sonda en la evidencia); la prueba
> de la entrega solo comprueba que el título existe y la del salto usa USHOU.
> Todo lo demás pasó: suite 2340/2340, `analyze` cero en copia limpia y aquí,
> rojas 11/3 y 17/1 exactas, buque con huella `664de202…4a58`, 94 capturas sin
> textos que no caben ni errores, árbol accesible correcto (los chips que no
> caben a 360 no están en el árbol), Web solo contra `127.0.0.1` sin errores de
> consola, corpus A01/A03 contra mis segmentos y memoria 505.5 → 159.0 MB con
> el instrumento de siempre. Dos datos para O-120-1 del corpus real: 42 de los
> 92 `TMP` del A01 (y 1 de 11 del A03) se pierden porque llegan después del
> `LOC+147` (aislado con variantes de orden), y un contenedor truncado sin
> `LOC+11` el lector lo cuenta con puerto. O-120-2 medida: la primera tarjeta a
> unos 1109 dp (letra 1.0) y 2021 dp (2.0) en el teléfono. La matrícula
> duplicada no excepciona en filtros ni buscador; la Lista no llegué a
> construirla en la sonda. Android y la grabación del parpadeo quedaron sin
> presupuesto. La corrección de T120-ACC-01 va antes de la reaceptación.

---

## Revisión del 19-nov (10.152)

Yov repasó mi aceptación contra la carpeta (10.152): lo comprobable coincide.
Dos puntos de mi informe no se sostenían como estaban escritos, y esta sección
los vuelve a medir, con sus cifras. La punta de esta carpeta al empezar era
`d51646f` (`f29fa2a` más el commit de mi informe), sin cambios versionados
míos; cada ventana de Flutter con su `SEMÁFORO:`, un comando a la vez (hay otra
tarea abierta en la máquina, T-147).

### T120-ACC-01, vuelto a medir: se retira el P2

Yov leyó en el código lo que mi sonda de ayer no dijo: la sonda de «Sin
destino» y la de PAMIT corrieron **sin llevar el tamaño a `t120Pump`**, así que
las dos corrieron a 1366 × 690 (la omisión, en
`test/support/t120_lista_support.dart:42`); el salto es el mismo código para un
puerto y para «Sin destino» (`vessel_overview_page.dart:137-158`); y lo que
cambió fue el largo de la lista: 98 tarjetas contra una. `ensureVisible` no
desplaza más allá del final.

Medición nueva, con las tres sondas pedidas, cada una a 1366 × 690 y a
360 × 800, letra 1.0, con el tamaño llevado a `t120Pump` de forma explícita
(`revision/sonda-acc01.txt` y `revision/sonda-acc01-b.txt`):

| Caso | Tamaño | Título a (dp) | pixels | maxScrollExtent | La última tarjeta |
|---|---|---:|---:|---:|---|
| A · «Sin destino» con lista larga (30 sin destino de 120) | 1366 × 690 | **74.0** | 712.0 | 4276.0 | cortada por abajo |
| A · «Sin destino» con lista larga | 360 × 800 | **56.0** | 972.0 | 7564.0 | cortada por abajo |
| B · «Sin destino» con lista corta (1 tarjeta, dos puertos) | 1366 × 690 | 483.0 | **247.0 = máximo** | 247.0 | a la vista, cortada por abajo |
| B · «Sin destino» con lista corta | 360 × 800 | 366.0 | **662.0 = máximo** | 662.0 | a la vista, cortada por abajo |
| C · un puerto con lista corta (2 tarjetas de VELAG) | 1366 × 690 | 346.0 | **384.0 = máximo** | 384.0 | a la vista, cortada por abajo |
| C · un puerto con lista corta | 360 × 800 | 66.0 | **962.0 = máximo** | 962.0 | a la vista, cortada por abajo |

- **A deja el título arriba, como PAMIT**: 74.0 dp a 1366 × 690 y 56.0 dp a
  360 × 800, con `pixels` por debajo del máximo (hay con qué desplazar).
- **B y C quedan con `pixels` igual a `maxScrollExtent`**: el desplazamiento
  está clavado en su tope; no hay con qué subir el título, y el título y la
  tarjeta ya están a la vista. Es lo que leyó Yov.
- Lo que se describe tal cual: en los cuatro casos de lista corta, la última
  tarjeta queda visible pero cortada por el borde de abajo de la vista (unos
  40 a 48 dp): el desplazamiento tope la deja en su sitio, no la baja hasta
  verse entera.
- Una nota del instrumental: en mi caso B nuevo con diez puertos, la barra de
  «Sin destino» no salió porque la fila cae dentro de «Otros N puertos» (la
  nota que ya tenía Timonel en el informe); la repetí con dos puertos, donde
  «Sin destino» tiene su barra, y esa es la que se reporta.

**La lectura de Yov se confirma: T120-ACC-01 se retira.** No es un defecto del
producto: es el límite físico de `Scrollable.ensureVisible` con contenido más
corto que la vista. Mi medición original midió cierto (483 dp), pero su
conclusión de defecto era un artefacto de dos cosas: la sonda a 1366 × 690 sin
decirlo, y una lista de una tarjeta donde el desplazamiento ya estaba en su
tope. Como decidió la 10.152 (punto 2): **la entrega 1 queda aceptada con
observaciones**; D9 se precisa en `DESIGN.md` 18.5 («arriba, o toda la lista a
la vista cuando no hay más que desplazar»), y la prueba de la lista corta entra
con la entrega 2.

### El conteo del corpus, corregido: se retiran los dos «datos para O-120-1»

Mi script cortaba los bloques en `EQD`; el formato BAPLIE abre el bloque en
`LOC+147`, y el `TMP` y el `LOC+11` de cada contenedor vienen **antes** de su
`EQD`. Así le atribuí cada `TMP` y cada `LOC+11` al contenedor equivocado. El
conteo nuevo, con los bloques cortados en `LOC+147`
(`revision/corpus-loc147.txt`):

| Archivo | Bloques | Refrigerados (ISO R o TMP) | Con `TMP` | Bloques sin `LOC+11` | Destinos |
|---|---:|---:|---:|---:|---|
| CORPUS_A01.edi | 977 | **50** | 43, los 43 en contenedores de tipo refrigerado | **0** | USHOU 907, USMSY 40, XXVSL 30 |
| CORPUS_A03.edi | 369 | **10** | 1, en contenedor de tipo refrigerado | **0** | GTPBR 267, USHOU 102 |

Es exactamente lo que contó Yov (10.152) y lo que da el producto. Los
«92 refrigerados» y el «contenedor truncado sin `LOC+11`» de mi informe de ayer
eran artefactos de ese corte; la variante «EQD, LOC+147, TMP» de mi sonda de
orden no es un contenedor: es el final de uno y el principio del siguiente, y
el lector sí aplica el `TMP` que llega antes del `EQD` (`pendingTemperature`).
**Se retiran los dos «datos para O-120-1»: O-120-1 queda como estaba, y no
nace ningún hallazgo del lector.**

### La Lista con una matrícula repetida (lo opcional)

Lo intenté de nuevo con `t120Pump` completo a 1366 × 690
(`revision/sonda-duplicada.txt`): la Lista sigue sin construir tarjetas con el
viaje de la matrícula repetida (0 tarjetas, 0 textos de la matrícula, sin
excepción). No concluyente, igual que ayer: queda para la entrega 2 con su
prueba, como lo dejó anotado la 10.152.

### Dictamen, dicho de nuevo

**PASA, con observaciones.** Se retira el P2 (T120-ACC-01) y se retiran los dos
«datos para O-120-1»; lo demás de la aceptación de ayer queda como está
escrito, y lo que Yov comprobó coincide. La entrega 2 de T-120 espera a T-147
(10.151).

### Evidencia de la revisión

`build/t120/glm-e1/revision/`: `sonda-acc01.txt` (A y C, los cuatro tamaños),
`sonda-acc01-b.txt` (B corregida, los dos tamaños), `corpus-loc147.txt` (el
conteo corregido), `sonda-duplicada.txt` (el intento opcional). Las sondas
viven en `%TEMP%\t120-glm-t120\` y las copias en `%TEMP%\t120-glm-despues\`.

### Git, para que lo ejecute Carlos (revisión)

Desde esta carpeta. La punta se trae primero, para que el commit quede sobre
ella; mi informe modificado se queda (si Carlos todavía no hubiera subido el
commit del informe original, los dos cambios van en este mismo commit):

```powershell
git fetch origin
git checkout --detach origin/sprint-4
git add -- docs/t120/entrega1/aceptacion-glm.md
git commit -m "Sprint 4: revision de la aceptacion de la entrega 1 de T-120, T120-ACC-01 retirado"
git push origin HEAD:sprint-4
```

Horas del reloj de esta revisión: los 20 minutos previstos por el encargo, en
tres ventanas de `SEMÁFORO:` (la sonda A/B/C y la repetición de B, el conteo
del corpus y la sonda opcional); el reloj del sistema al cerrar marca 20-nov,
08:58.
