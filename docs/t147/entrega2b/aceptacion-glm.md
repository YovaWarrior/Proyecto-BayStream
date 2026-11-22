# Aceptación GLM · T-147, entrega 2, parte 2b

21 de noviembre de 2026 · Capitán Codex (GLM 5.3 Flash, esfuerzo Max), en el
papel de las decisiones 10.129 y 10.137 de `SPRINT-4.md`. Sobre
`baystream-qa-r4` en la punta `528ea3b` (la corrección de la 10.164, sobre
`f71675c`, la 2b, sobre `912daac`, mi aceptación de la 2a). Encargo: la
aceptación de la parte 2b de la entrega 2 de T-147 (10.165).

## Dictamen

**PASA, sin hallazgos nuevos.** Los nueve puntos programados y la corrección
pasan: la suite y `analyze`, las rojas, las cifras del caso, el corpus, lo que
nadie había visto en pantalla (el muelle frente a la cerrada y a la nueva, la
oficina que cierra y abre el BAPLIE de salida, la matrícula repetida en la
nube a 360 × 800, Descarga con la repetida, la nube a 360 × 800), los
recorridos de Timonel y la medición con el arnés corregido. No abrí ningún
hallazgo T147-E2B-xx; los textos que no caben que vieron mis corridas son los
conocidos de O-147-6.

## 1. Los puntos de la sección 4, uno por uno

| Punto | Resultado | Evidencia (`build/t147/glm-e2b/`) |
|---|---|---|
| Paso 0 · git, huellas, `pub get`, T-124 | OK: la punta y las 8 rutas del HEAD son las de E2b-18.9, y las 32 de `f71675c` las de E2b-13; huellas de `CORPUS_A09.edi` y `LISTADO_A09.xlsx` exactas; `pub get` salida 0 en las cuatro copias; `t124_entradas.dart` con la huella esperada | este informe (los números), `A/` |
| A.1-2 · tres copias limpias y `analyze` | OK: «No issues found!» con todo el paquete en `t147-glm2b-despues` y en el Dart versionado de esta carpeta; no hizo falta repetir con `dart analyze --cache` | `A/analyze-copia-limpia.log`, `A/analyze-esta-carpeta.log` |
| A.3 · la suite, una corrida | OK: `+2418: All tests passed!`, sin `~` ni `-` (piso 2357 + 55 + 6) | `A/suite-copia-limpia.log` |
| A.4 · pubspec contra `912daac` | OK: `git diff` vacío para `pubspec.yaml` y `pubspec.lock`; versión `1.0.3+12` | este informe |
| B.5 · las rojas contra `v1.0.2` | OK: repetida **10 de 17** fallan; huella **1 de 2**; listado **7 de 11** (lo que Yov esperaba y nadie había corrido: confirmado); otra operación, con la versión de `f71675c`, **9 de 11**. Ninguna de compilación | `B/rojas-v102-*.log` |
| B.6 · contra la punta de la 2a | OK: revisión **12 de 15** fallan (O-147-7 ×2, O-147-8 ×4, O-147-9 ×3, O-147-10 ×3) | `B/rojas-p2a-revision.log` |
| B.7 · la corrección, contra `f71675c` | OK: **7 de 27** fallan y son las que dice Timonel: las dos que cambian de regla, la de agregar, la de «AGREGADOS» y tres de la lista de cerradas. Las 20 que pasan en los dos lados fijan lo que no debía cambiar (el plan corregido se publica y se agrega, una vez en la llegada y una en la carga no es repetida, el mismo archivo conserva la cerrada visible, la copia local anterior no la tapa, «el muelle no la ve», que en la 2b era cierto porque la lista no existía) | `B/rojas-p2b-correccion.log` |
| C.8 · las cifras del caso | OK: las 9 claves de mi `C-otra.json` de la 2a salen iguales una por una y el bloque `parte2b` da lo esperado (abajo, en «Las cifras») | `C/caso-otra-glm2b.json` |
| C.9 · mi cuenta aparte del Excel | OK: 448; 334 bajo la primera agencia (141 antes de cualquier sección, 6 en «TRANSBORDOS», 187 en «VACIOS»); 53 bajo la segunda; 61 en «AGREGADOS»; 202 con POT ≠ POD, 33 canceladas — todo exacto | `C/cuenta-excel-2b.py.txt`, `C/cuenta-excel-2b-salida.txt` |
| D.10-13 · el emulador (puntos 11 a 13) | OK, captura por captura abajo | `D-emulador/glm-11*.png`, `glm-12*.png`, `glm-13*.png` |
| D.14 · Descarga con la repetida | OK: ficha, primera celda que responde y la otra que se descarga, a 360 × 800 y a 1366 × 690 (escenario propio en la copia de %TEMP%) | `D-recorridos/glm-dl-360-dia/`, `glm-dl-1366-dia/` |
| D.15 · los recorridos de Timonel | OK: cinco corridas con 10, 10, 10, 7 y 7 capturas, `pasos.jsonl` terminado en «fin», `red.json` sin peticiones fuera de 127.0.0.1, `consola.log` sin errores de Flutter y `programa.es_el_que_se_sirve` verdadero en las siete | `D-recorridos/r2b-*`, `rep-*` |
| E.16 · el corpus | OK: los trece `.edi` y `LISTADO_A08.xlsx` iguales a mi `despues.json` de la 2a; **DISTINTO** solo `LISTADO_A09.xlsx`: 5 «agencias» → 3 entradas y las filas guardadas con `section` | `E-corpus/despues.json` |
| F.17 · la medición | OK con matiz: 18 corridas (3 preparar + 15 medir), las 18 con `es_el_que_se_sirve` verdadero, `consola.log` y `servidor.log` guardados; las 15 de medir corrieron **sin el listado importado** y con un perfil compartido por vuelta (abajo); los criterios, recalculados abajo | `F-medicion/medicion-glm/`, `F-medicion/resumen.txt` |
| G.18-19 · sondas propias | OK (abajo): la repetida en tres celdas, llegada+carga, el texto sin forma de matrícula, y cinco estados de `OperationSources` | `G-sondas/sondas-glm-salida.txt`, `sonda-glm-g.dart.txt` |
| G.20-22 · secciones, lápiz, versiones mezcladas | **No llegó**: queda dicho en «Lo que no se pudo» | — |
| G.23 · muelle en la 1.0.2 en pantalla | **No llegó** (sección 6) | — |
| H.24 · el banco de Windows de la punta | **No llegó** (sección 6); Android no hacía falta en esta aceptación | — |

## 2. Las cifras

### El caso A09 (C.8 y C.9)

De `tool/t147e2_caso.dart` en la copia limpia de la punta: las 9 claves de la
2a (`escala`, `listado`, `equivalencias`, `declarado`, `cruce`, `hoja`,
`cargas`, `salida`, `dispositivo`) **iguales una por una** a mi
`C-otra.json` de la 2a, y el bloque `parte2b` nuevo con:

| Qué | Esperado | Dado |
|---|---|---|
| Agencias | 2, y «AGREGADOS» aparte | **2** |
| Primera agencia | 334 (141 + 6 + 187) | **334** (secciones TRANSBORDOS 6, VACIOS 187) |
| Segunda agencia | 53 | **53** |
| «AGREGADOS» | 61 | **61** |
| POT ≠ POD que se cargan / canceladas | 169 / 33 | **169 / 33** |
| Con los seis tipos por elegir | 0 códigos y 0 celdas sin dueño | **0 / 0** |
| Elegidos los seis | 11 celdas en 6 códigos | **11 en 6** |
| El lápiz, 40HC de 45G1 a 45G0 | queda 45G0 con «también» 45G1; 14 de 14 grupos cuadran antes y después; sin choques ni celdas sin dueño | **45G0 (también 45G1); 14/14 antes y después; 0 y []** |
| Matrículas repetidas en el plan del caso | 0 | **0** |

Mi cuenta aparte, con el Excel leído sin el lector del producto (zipfile + XML,
hoja «OPS»), da exactamente lo esperado: **448** filas con OR; **334** bajo la
primera agencia, de ellas **141** antes de cualquier sección, **6** bajo
«TRANSBORDOS» y **187** bajo «VACIOS»; **53** bajo la segunda; **61** bajo
«AGREGADOS» (en el Excel son tres títulos «AGREGADOS»: filas 396, 455 y 457);
**202** con POT ≠ POD, de las que **33** canceladas (CANCEL con sus formas,
ROLEADO y YA EMBARCADO, en MARCHAMO o CONTENIDO).

### La medición (F.17)

21-nov, 15:02 a 15:14 (hora local). Tres bancos compilados con la misma orden
en sus copias; corridas alternadas 1.0.2 → 2a → punta, cinco rondas, con
`--cpu 4`, a 360 × 800 y con el `tool/t147_web.py` de la punta. **Las 18
corridas con `es_el_que_se_sirve` verdadero** y `consola.log` y
`servidor.log` guardados; las huellas que cargó cada banco: 1.0.2 =
`7526c039…` (la misma que Timonel anotó para la 1.0.2 de verdad), 2a =
`079e3f51…`, punta = `a16aab54…` (la compilación de mi copia, que lleva
además el escenario que añadí para el punto 14; los escenarios `medir`,
`recorrido2b` y `repetida2b` no los toqué).

**Qué se midió de verdad** (corregido en la revisión; lo que escribí antes de
«un perfil preparado por cada banco» está mal): el guion `medir-glm.sh` pasa
al arnés, en las corridas de medir, el perfil de la vuelta (`--perfil "$3"`,
el número de vuelta), no el del banco: los `navegador.json` de las quince
dicen `…\t147\perfiles\1` a `…\t147\perfiles\5`. Cinco perfiles, cada
uno compartido por los tres bancos de su vuelta, en el orden del guion
(primero la 1.0.2; después la 2a y la punta, sobre lo que dejó la anterior).
Los tres perfiles de preparar (`e2b-glm2b-v102`, `-2a` y `-2b`, con el
listado importado) **no se usaron al medir**. Y como el escenario `medir` no
importa el listado por su cuenta, las quince corridas midieron **Carga del
caso sin el listado importado**: `filas_a_la_vista` es `[]` en los pasos
«toque» y «tecla» de mis quince registros, donde en los de Timonel están los
OR 250 a 259. Lo que sí vale y se queda: las 18 corridas cargaron el programa
que se servía (`es_el_que_se_sirve` y las tres huellas de arriba), y mis
quince cifras son las de mis registros.

Milisegundos, de soltar el dedo a la pantalla dibujada:

| | 1.0.2 (5 corridas) | mediana | 2a (5) | mediana | 2b (5) | mediana |
|---|---|---|---|---|---|---|
| El teclado | 935.5 · 910.5 · 898.3 · 912.3 · 893.2 | **910.5** | 927.9 · 914 · 914.4 · 940.9 · 939.2 | **927.9** | 501.1 · 435.1 · 469.1 · 425.4 · 431.6 | **435.1** |
| Tocar la celda | 258.5 · 161.3 · 162.6 · 163.5 · 167.2 | **163.5** | 163.7 · 166.8 · 164.2 · 169.8 · 162.5 | **164.2** | 118.9 · 123.6 · 116.1 · 116.5 · 116.6 | **116.6** |
| Una tecla | 90.4 · 89.5 · 88.9 · 90.6 · 87.2 | **89.5** | 90.7 · 89.5 · 85.2 · 90.8 · 89.9 | **89.9** | 45.5 · 49.1 · 49.4 · 46.2 · 47.7 | **47.7** |

Los tres criterios, sin el listado:

1. **El teclado tarda claramente menos con la punta:** mediana 435.1 contra
   910.5 de la 1.0.2 (**52 % menos**), sin el listado; las cinco corridas de
   la punta (425 a 501) quedan por debajo de la más rápida de la 1.0.2
   (893). Es más o menos la mitad que midió Timonel (664→379 y 999→498); mi
   serie se sitúa cerca de su serie 2 en la 1.0.2 y algo por debajo en la
   punta.
2. **De soltar el dedo a la hoja:** 116.6 contra 163.5 y ninguna corrida de
   la punta pasa de medio segundo (máximo 123.6) — pero mi hoja estaba sin
   filas (`filas_a_la_vista` vacío), que no es la del criterio: es el toque
   con una hoja de reservas, no con las filas del listado. El criterio con
   listado queda medido por Timonel (10.164, 159 contra 134 ms con la CPU
   frenada); no lo repetí.
3. **La 2a contra la 1.0.2 en el teclado:** 927.9 contra 910.5 (**+1.9 %**),
   con las cinco corridas de cada uno entremezcladas en rangos que se cruzan
   (893-940 en ambas). En mi máquina no se ve diferencia; coincide con lo que
   dijo Timonel («menos del 1 %, dentro del ruido») y con lo que Yov sospechó
   de mis 899/916 de la 2a: ruido del paso de la máquina.

Máquina y condiciones: la laptop de Carlos, Chrome de Playwright con la
ventana visible toda la ventana de medición, la CPU dividida entre 4, y la
máquina quieta: yo no ejecuté nada durante la ventana y no había otro
Flutter/Dart corriendo; quedaron arriba, ociosos, el emulador de Firebase, el
control (5944) y el servidor estático del banco del emulador (5943).

## 3. En pantalla (D), captura por captura

Banco del emulador: `tool/t130_emu_main.dart` compilado desde la punta en la
copia de %TEMP%, servido en `127.0.0.1:5943` desde `%TEMP%\t147-glm2b\servido-emu\`
con los archivos del caso en su subcarpeta `t143\` (nada del caso en el
repositorio). Antes de empezar borré los perfiles del control
(`%TEMP%\t143\perfil-*`) y comprobé que corría la punta con la prueba que solo
ella pasa: tras cerrar, «Nube y cuenta», sin ningún plano abierto, enseña
«Operaciones cerradas en este dispositivo» (captura `glm-11d-01`). Contra
producción no se fue nada: `red.json` de las corridas y las órdenes del control
solo tocan 127.0.0.1.

### Punto 11 · El muelle frente a la operación cerrada y a la nueva

- **a.** La oficina (1920 × 1080, cuenta office) abre `CORPUS_A09.edi`,
  confirma el perfil («No lo tengo») y publica (`glm-11a-02-publicada`:
  «Operación publicada.»). El muelle (360 × 800, cuenta dock, otro perfil)
  ve «Operaciones abiertas en la nube» con «Unirse» (`glm-11a-03`), se une,
  abre el plan de carga y registra una carga por el buscador: el diálogo
  «Confirmar carga» completo y al alcance a 360 × 800 (`glm-11a-04`); queda
  «407 pendientes». La oficina lo ve en el Avance: «1 cargado · 134
  pendientes» y «Último movimiento: Carga … Muelle de prueba»
  (`glm-11a-05`).
- **b.** La oficina cierra (`glm-11b-02`: «Operación cerrada.» con su botón).
  El muelle, en «Nube y cuenta», lee «BUQUE HOTEL · VIAJE009A · GTSTC /
  Publicada y cerrada / Se sigue viendo, solo para mirar. Si la oficina
  publica otra operación de esta escala, únete a ella desde «Operaciones
  abiertas en la nube».», **sin** el botón «Empezar una operación nueva» y
  **sin** la sección «Operaciones cerradas en este dispositivo»
  (`glm-11b-03`). Intenta registrar otra carga: el diálogo la acepta y la
  snackbar dice «Carga registrada · Deshacer», pero la nube la rechaza y la
  cabecera pasa a «Nube y cuenta · Al día · **1 rechazado: la operación ya
  estaba cerrada** · operación cerrada», con la celda en naranja (Revisar)
  (`glm-11b-04`, `glm-11b-05`); los pendientes no cambian (407).
- **c.** El muelle abre la llegada sintética desde el inicio: **se rechaza,
  no se guarda nada** y la app se queda en el inicio. A 360 × 800 el aviso
  rojo del pie enseña **las 58 palabras completas** (`glm-11c-04`), sigue a
  la vista unos 3 segundos después de abrirse y ya no está a los ~6
  (capturas t2/t5 idénticas: `glm-11c-05/06`): dura lo que dice O-147-12
  (~4 s) y **no salió el texto corto con «Ver»** a este tamaño.
- **d.** Lo recorrí por la **tarjeta de «Operaciones cerradas en este
  dispositivo»**, con el inicio a la vista y sin ningún plano abierto (no por
  el camino del encargo, «con el plano de la cerrada abierto»: ese no lo
  recorrió ninguna captura mía; lo cubren las de Timonel, E2b-5.2 paso 05 y
  c164-04/05). «Nube y cuenta» enseña arriba «Abre un plano con su escala
  confirmada para ver su operación.» y, al final, la tarjeta «BUQUE HOTEL ·
  VIAJE009A · GTSTC / Cerrada el 21-nov, 13:37» con su botón (`glm-11d-01`).
  Al pulsarlo, el diálogo dice «Empieza de cero con los planos de la
  operación cerrada: el plan de carga («CORPUS_A09.edi»). El listado de la
  agencia se importa de nuevo.» y «Lo registrado se queda en la operación
  cerrada, que deja de verse en este equipo.», con «Cancelar» y «Empezar»
  (`glm-11d-02`; la tarjeta queda detrás, a la vista). Con «Empezar»:
  «**Operación nueva, en este dispositivo. Abre o confirma su plano para
  trabajar en ella.**» y la tarjeta ya no está (`glm-11d-03`). Abrí entonces
  su plano desde «Recientes» y en «Nube y cuenta» vio «Es una operación
  nueva: la anterior de esta escala se cerró el 21-nov, 13:37 y lo
  registrado se quedó en ella.», «Solo en este dispositivo» y «Fuentes:
  carga», con «Publicar operación» encendido (`glm-11d-04`). La publica:
  «Operación publicada.» (`glm-11d-05`).
- **e.** El muelle la encuentra en «Operaciones abiertas en la nube»
  (`glm-11e-01`), se une y abre el plan de carga: **Carga no tiene nada**.
  La captura `glm-11e-02` enseña el modo Carga de la nueva sobre la bahía 01,
  con celdas «Sube» y reservas y ninguna carga registrada, pero **no** trae
  la línea del conteo; esa línea, «408 pendientes: 135 llenos, 273 vacíos»,
  la leí en los nodos del control en ese paso, y la única captura donde el
  texto se ve es `glm-diag-modo2`, en la opción «Carga» del menú de modo del
  muelle (tomada durante la primera operación, antes de la carga del paso a).
  Registra una (`glm-11e-03`) y la oficina la ve en el avance de la nueva
  («1 cargado · 134 pendientes», `glm-11e-04`).
- **f.** Por el REST del emulador (solo 127.0.0.1): la nube tenía entonces la
  operación nueva con **exactamente 1 movimiento** en `movements`. La cuenta
  de la cerrada en la nube no la pude tomar después (incidente del
  instrumental, abajo): antes del cierre, su avance mostraba «1 cargado»
  (`glm-11a-05`) y tras el cierre la nube rechazó el segundo movimiento
  («1 rechazado», `glm-11b-05`), y la cerrada local siguió mostrando su
  carga (407 pendientes, `glm-12c-01`).

### Punto 12 · La oficina que cierra y abre el BAPLIE de salida

Con la operación nueva de la escala cerrada (tenía la carga del muelle), la
oficina abre `SALIDA_CERRADA.edi` —la salida que armé con una sonda (una
carga registrada, 302 contenedores, en %TEMP%)— en el mismo equipo:

- **Se rechaza** con el aviso de 18.2 y no se guarda nada; la app queda en el
  inicio y el aviso completo se lee de una vez a 1920 × 1080
  (`glm-12b-01-t0`), y a los ~2.5 s ya se fue (`glm-12b-02`).
- Al abrir otra vez el plano de la cerrada desde «Recientes», la cerrada
  sigue ahí con lo registrado: «Carga. 407 pendientes» y «operación cerrada»
  (`glm-12c-01`).
- Con el inicio a la vista, «Nube y cuenta» enseña al final «Operaciones
  cerradas en este dispositivo»: «Para trabajar otra vez una escala que ya
  se cerró, empieza una operación nueva con sus planos.», y una tarjeta
  «BUQUE HOTEL · VIAJE009A · GTSTC / Cerrada el 21-nov, 14:06» con su botón
  (`glm-12c-02`). La cerrada que ya se ve arriba no sale dos veces
  (`glm-12c-03`). Con dos cerradas de escalas distintas (creé VIAJE009B y
  VIAJE009C con planos derivados del caso), **la más reciente va primero**:
  la lista mostró VIAJE009B (14:10) antes que VIAJE009A (14:06), y la más
  reciente de todas queda arriba, fuera de la lista (`glm-12c-04`,
  `glm-12c-05`, `glm-12e-02`).
- «Empezar una operación nueva» desde la tarjeta: el mismo diálogo
  (`glm-12d-01`); después, «Operación nueva, en este dispositivo. Abre o
  confirma su plano para trabajar en ella.» y la tarjeta ya no está
  (`glm-12d-02`).
- El archivo de la salida, otra vez: **ahora entra**. La app queda en la
  operación con «Carga. 1 pendiente: 1 lleno» y en «Nube y cuenta» dice
  «Fuentes: **carga**» — la salida se lee como plan de carga de la escala
  (`glm-12e-01`, `glm-12e-02`).

### Punto 13 · La matrícula repetida en la nube, a 360 × 800

Con el cliente «muelle2» (360 × 800) como oficina y `PLAN_REPETIDO.edi`:

- «Publicar operación» **apagado** y, debajo, el motivo completo sin
  recortes: «No se publica: el plan de carga («PLAN_REPETIDO.edi») trae 1
  matrícula en más de una celda: ‹matrícula› en 018-01-82 y 018-00-82. Un
  contenedor solo puede estar en una. Pide el plan corregido a quien lo hizo
  y ábrelo de nuevo.» (`glm-13-01`). **Los textos caben.**
- La operación cerrada con su botón a 360 × 800 (`glm-13-02`: cerrada
  VIAJE009C con «Empezar una operación nueva» a lo ancho) y el diálogo
  entero sin desplazar (`glm-13-03`). De noche lo miré en el cliente
  «oscuro» a 1920 × 1080.
- «No se agrega»: **no lo repetí yo.** Mi intento en el cliente oscuro topó
  primero con «La carga excede el perfil guardado» (el perfil guardado venía
  de la llegada sintética, de 3 contenedores, y la revisión de ampliación se
  me enredó con el instrumental). El punto está cubierto por la roja «el
  diálogo de agregar dice el motivo y apaga su botón» y por las capturas de
  Timonel (E2b-5.2, paso 10); lo declaro no visto por mí a 360 × 800.

### Punto 14 · Descarga con la matrícula repetida

El banco sin nube (`tool/t147_main.dart`) servido por el arnés, con un plano
de llegada propio (`LLEGADA_REPETIDA.edi`, en %TEMP%: la matrícula del caso
en 002-01-82 y 002-03-82, que bajan en GTSTC) y un escenario añadido por mí
al conductor **en la copia de %TEMP%** (`descarga-repetida-glm`; el archivo
va en mi evidencia como `herramientas/t147_conductor-con-mi-escenario.dart.txt`
y ninguna de las líneas de los escenarios de Timonel cambia):

- A 360 × 800 y a 1366 × 690: en Descarga, la ficha «Plan con 1 matrícula
  repetida: una descarga no se puede registrar. Pide el plan corregido.» en
  una línea propia sobre el resumen (`glm-dl360d-02`, que muestra además
  «Bahía 02: 2 por bajar en cub.»); la primera celda (002-01-82) responde
  «Matrícula repetida» con «El plan trae ‹matrícula› también en 002-03-82.
  Esta celda no se puede operar hasta abrir el plan corregido.» y
  «Entendido» (`glm-dl360d-03`); la otra celda (002-03-82) se descarga como
  cualquiera: `glm-dl360d-04` enseña la snackbar «Descargado · ‹matrícula› ·
  002-03-82 · Deshacer», la celda con la marca de bajado y los contadores
  «Por bajar 1 · Bajado 1» (antes eran 2 por bajar; el «0» de mi registro
  `dl-segunda-celda` es el campo `pendientes` del progreso, que es otra
  cuenta). «fin», sin errores de Flutter, con el programa de la carpeta que
  se sirve, en los dos tamaños.

### Punto 15 · Los recorridos de Timonel

Cinco corridas con el banco de la punta y el arnés de la punta, perfil nuevo
por corrida: `recorrido2b` a 360 × 800 de día y de noche y a 1366 × 690 de
día; `repetida2b` a 360 × 800 de día con el listado revisado y a 1366 × 690
de noche sin él. En las siete corridas (estas cinco más las dos del punto
14): 10, 10, 10, 7, 7, 4 y 4 capturas, «fin», `red.json` sin peticiones fuera
de 127.0.0.1, `consola.log` sin errores de Flutter y `programa.es_el_que_se_sirve`
verdadero. Abro capturas de todas y `pasos.jsonl` dice en cada corrida:

- El resumen: «448 filas en 2 agencias · 408 para cargar: 135 llenos y 273
  vacíos», «AGENCIA 1 S.A.: 334 (TRANSBORDOS 6, VACIOS 187)», «AGENCIA 2
  S.A.: 53», «AGREGADOS: 61» y «169 filas que se cargan traen POT y POD
  distintos (y 33 canceladas)…» — en las tres corridas de `recorrido2b`, y
  con 40 canceladas (37 llenos y 3 vacíos) (`…01-resumen`).
- Con los seis tipos por elegir, la tarjeta de las celdas sin dueño no está
  (la corrida la mira antes de elegir); elegidos, «Celdas reservadas que
  ningún tipo del listado llena (11)» con los seis códigos y «Sí», «Otro
  tipo…» y «No» **en una línea en los seis**, también a 360 dp
  (`…02-celdas-sin-duenio`; el registro `fichas_en_una_linea` verdadero para
  los seis códigos en las tres).
- El lápiz: 40HC queda en «45G0» con «También llena: 45G1», 14 de 14 grupos
  cuadran, ningún choque y ninguna celda sin dueño (`…03-lapiz`; registro
  `principal=45G0, tambien=[45G1], cuadran=14/14, conflictos=0`).
- El motivo en los tres casos: el aviso, «Motivo (obligatorio)» con su ayuda
  «Viaja con el movimiento.» y «Confirmar carga» se ven sin desplazar, en
  imagen (`…04/05/06`) y por los rangos de píxeles que registra la corrida
  (aviso, motivo, hora y botón a la vista y al alcance en los tres, a 360 y
  a 1366). Con dos avisos, la cabecera con el OR queda fuera de la vista
  pero **se sabe qué fila se asigna**: el segundo aviso nombra el OR («…el
  OR 156 es 45G1 · COTRB · LNH»); con un solo aviso la cabecera con el OR
  está arriba (`…05`, OR 157).
- El detalle de la celda: «OR 1 · ‹matrícula› se cargó y el listado lo marca
  cancelado («CANCELADO»).», sin «…deshazlo desde el detalle de la celda.»
  (`…07-detalle-de-la-celda`).
- El avance: «Listado: 41 filas canceladas (38 llenos y 3 vacíos): 40 no se
  cargan y 1 está a bordo.» y «Conflictos: 1» (`…08-avance`).
- La salida: «1 conflicto vigente. Revisa el avance…» y la segunda captura
  baja hasta «Avisos de la salida» con su título — 09 y 10 son imágenes
  distintas (tamaños 324 y 373 KB) (`…09`, `…10-salida-avisos`).
- En `repetida2b` (con y sin listado dice lo mismo): en Lista, «Matrículas
  repetidas en EQD…»; en Carga, la ficha «Plan con 1 matrícula repetida: una
  carga no se puede registrar. Pide el plan corregido.» en su línea y la
  bahía 18 con «9 contenedores · 73 celdas reservadas · 148.2 t» y 407
  pendientes (`rep…02`); la celda 018-01-82 responde «Matrícula repetida»
  (`rep…03`); la 018-00-82 se carga como cualquier lleno (406 pendientes,
  ningún conflicto); la salida avisa «‹matrícula›: el plan de carga lo trae
  en 2 celdas (018-01-82 y 018-00-82)… la salida escribe un solo grupo para
  esa matrícula. Pide el plan corregido.» (`rep…06/07`).
- Textos que no caben: los detectados son los conocidos de O-147-6 (las
  filas del listado en la hoja, «L5G1 C…», detrás del diálogo del motivo, y
  «Reservas libres…» montada sobre «Celda reservada», que se ve en
  `glm-r2b360d-04/05`). Ninguno nuevo.

Nota de instrumental: mi primer lote de estas cinco corridas lo borró un
`flutter clean` que hice durante el punto 14 (abajo, en lo que no se pudo);
las repetí con el mismo comando, perfiles nuevos y el banco recompilado desde
la misma copia. Los registros de `pasos.jsonl` de las repetidas dicen lo
mismo que los de las originales (los comparé en el punto de la ficha, la
celda que responde y la salida); las capturas que abrí y describo arriba son
de los dos lotes indistintamente porque dicen lo mismo.

## 4. Las sondas (G.18 y G.19)

Salida completa en `G-sondas/sondas-glm-salida.txt`; los planes sintéticos
salen del caso por archivos en %TEMP% y las matrículas del caso no se
imprimen.

- **18a · la misma matrícula en tres celdas:** el lector avisa una sola
  familia (`duplicate:1`), la operación cuenta **1** matrícula repetida con
  **3 celdas** (014-06-06 —mi celda añadida—, 018-01-82 y 018-00-82), se
  queda con la **última del archivo** (018-00-82) y las otras dos responden
  que no se pueden operar (`repeatedAt` verdadero en 018-01-82 y en la
  tercera; falso en la conservada).
- **18b · una vez en la llegada y una en la carga:** la operación con ambos
  planos trae **0** repetidas.
- **18d · un texto repetido sin forma de matrícula ISO 6346:** **no es una
  matrícula repetida**. Sus dos celdas se leen «como si viniera en blanco»:
  los contenedores bajan de 438 a 436 y las reservas suben de 271 a 273, y
  el lector avisa como grupo sin número («BUQUEXX» en 2 celdas), junto al de
  siempre («NO» en 271 celdas). En la nube no habría bloqueo de publicación:
  no hay matrícula repetida que lo dispare.
- **19 · `OperationSources`:** con dos cerradas de escalas distintas y una
  nueva de la primera, `current` da la nueva y `closedToRestart` lista solo
  la otra cerrada, la más reciente primero; una cerrada con copia local de
  antes del cierre y otra de después se ve la **de después** (la de antes no
  tapa); una abierta publicada manda sobre la cerrada; con el reloj del
  equipo 30 días atrás en `startNew`, la nueva nace igualmente posterior al
  cierre (18:00:01 contra 18:00:00) y es la que se ve; una cerrada cuyo plan
  de carga declara otro número de viaje (el caso T-130) se encuentra por el
  viaje de la operación y **no** por el del plan, y sí sale en la lista de
  cerradas.

## 5. Hallazgos

**Ninguno nuevo.** Lo que vi y no es defecto:

- **O-147-12, con mis datos:** a 360 × 800 el aviso del rechazo se lee
  completo, las 58 palabras, sin necesidad de «Ver»; dura unos 4 segundos
  (a la vista ~3 s después de abrirse, ido a los ~6). A 1920 × 1080 cabe en
  un bloque de tres líneas. Sumo lo visto a la propuesta de Yov (diez
  segundos y «ábrelo de nuevo»): con la duración de hoy, en el teléfono se
  lee entero si uno está atento, pero se va rápido.
- Los textos recortados que detectaron mis corridas son los conocidos de
  O-147-6 (fuera del alcance de esta entrega).

Incidentes de mi instrumental, que no son del producto (los dejo escritos
porque explican huecos de evidencia):

- Reinicié el emulador de Firebase a media sesión para recuperar el inicio
  de sesión (abajo): al no exportar datos, se perdió de la nube el documento
  de la operación cerrada hasta entonces publicada. Por eso el conteo REST
  del punto 11.f solo cubre la operación nueva; de la cerrada quedan las
  capturas anteriores al reinicio y su estado local.
- Tras el reinicio del emulador, una página con la sesión guardada falló el
  inicio de sesión con «error que BayStream no reconoce» hasta recargarla
  limpia; con la página recargada, la misma cuenta entró sin tocar nada del
  producto.
- El botón «Volver al inicio» necesitó a veces dos pulsos del control; los
  menús desplegables no reciben el clic del control y se navegan con el
  teclado (Escape, flechas, Enter). Son límites del control, no de la app.
- Un `flutter clean` que hice en mi copia de %TEMP% (para descartar una
  caché de compilación durante el punto 14) borró las cinco corridas de
  recorrido de mi primer lote; las repetí con el mismo comando (arriba).
- Un error mío de guion hizo que las rondas 2-5 del primer intento de
  medición reutilizara la carpeta de salida de la ronda 1 (el arnés se niega,
  con razón): lo corregí y repetí la medición entera. Los números finales son
  de la repetición completa. `F-medicion/resumen.txt` dice lo mismo de los
  perfiles y pone la hora de sus ts en UTC como si fuera local; lo digo aquí
  y no lo cambio, para no retocar la evidencia.

## 6. Lo que no se pudo, y por qué

- **G.20, G.21 y G.22** (secciones sintéticas, el lápiz con sus tres casos,
  y versiones mezcladas con el código de la 1.0.2): sin sesión. El corte de
  cinco horas llegó con la medición terminada; en la reanudación preferí
  cerrar D (recorridos), F y el informe antes que esos puntos, según el
  orden de prioridad del encargo.
- **G.23** (un muelle en la 1.0.2 frente a la operación nueva, en pantalla):
  ídem. Lo que se sabe sigue siendo lo leído en el código (E2b-9).
- **H.24** (el banco de Windows de la punta, `repetida2b` a 1366 × 690 de
  día con el listado): no llegó ni se nombró en el primer informe; sin
  sesión.
- **La tarjeta de las cerradas a 360 × 800** (la lista «Operaciones cerradas
  en este dispositivo» que pide el punto 13 a ese tamaño): no la miré. A
  360 × 800 vi la cerrada a la vista con su botón (`glm-13-02`) y el diálogo
  (`glm-13-03`); la lista-tarjeta a ese tamaño solo la vi a 1920 × 1080
  (`glm-11d-01`, `glm-12c-02`).
- **«No se agrega» a 360 × 800 y de noche por mí:** explicado en el punto
  13; cubierto por las rojas y por Timonel.
- **El conteo REST de la cerrada después del reinicio del emulador:**
  explicado arriba.
- **No se probó en el iPhone ni en el Honor**, y no lo hago: lo digo tal
  cual. El Honor va desconectado; no corrí `flutter run`, `flutter install`
  ni `adb install` contra él.
- En la cuenta de Carlos no abrí la BayStream instalada ni toqué
  `%LOCALAPPDATA%\BayStream` ni la carpeta de la MSIX; no compilé ninguna
  Release de publicación; no toqué Firebase real ni `baystream-privado`; no
  ejecuté escrituras de Git ni `git status`; no corrí
  `flutter test --platform chrome`; un comando de Flutter/Dart a la vez, con
  sus líneas `SEMÁFORO:`.

## 7. Las horas del reloj

Rehecha en la revisión con la hora de cada tramo tomada de los archivos: la
fecha de modificación de los registros de `%TEMP%\t147-glm2b\` (los de
`build\t147\glm-e2b\` tienen todos la hora de la copia, las 18:01) y el
campo `ts` de cada `pasos.jsonl`, que está en UTC (Guatemala es UTC−6). La
hora de la primera actividad la da el registro más viejo del tramo.

| Tramo | De | A | De dónde sale la hora |
|---|---|---|---|
| Paso 0 y lecturas | 13:05 | 13:09 | `analyze-despues.log` 13:08 y `analyze-qar4.log` 13:09 |
| A · la suite | 13:10 | 13:11 | `suite-despues.log` 13:11 |
| B · las rojas | 13:12 | 13:15 | `rojas-v102-…log` 13:12 a `rojas-p2b-correccion.log` 13:15 |
| C · el caso y el corpus | 13:15 | 13:16 | `caso-run.log` 13:15 y `corpus-run.log` 13:16 |
| Bancos (sin nube, emulador, 2a, 1.0.2) | 13:18 | 13:21 | `build-banco-*.log` 13:18 a 13:21 |
| D · emulador, puntos 11 a 13 | 13:22 | 14:30 | `servidor-5943.log`, su última petición a las 14:30; el control se reinició a media sesión (`control-5944.log`, 13:51) |
| D.15 · recorridos de Timonel (primer lote) | 14:35 | 14:40 | la lectura de Yov sobre los registros, hoy sobrescritos por la repetición (18:01-18:03) |
| D.14 · Descarga con la repetida | 14:42 | 14:58 | `recorrido-glm-dl-360d2.log` a `…dl-1366d4.log`, última 14:58 |
| F · la medición (18 corridas) | 15:02 | 15:14 | `ts` de los `pasos.jsonl` (21:02-21:14 UTC) |
| Sin archivos (corte de la sesión por el límite de 5 horas) | 15:14 | 17:54 | no hay ningún registro mío en ese intervalo |
| G · las sondas de los puntos 18 y 19 | 17:54 | 17:58 | `sondas-glm.txt` y sus intentos previos, 17:54-17:58 |
| D.15 · recorridos repetidos (el clean del instrumental borró el primer lote) | 18:01 | 18:03 | `recorrido-glm-r2b-*.log` y `…rep-*.log` 18:01 a 18:03; los `pasos.jsonl` copados a las 18:03 |
| Evidencia, informe, revisión y limpieza | 18:03 | 18:30 | los archivos de `build/t147/glm-e2b/` copados a las 18:01 y este informe |

Unas **2 h 35 min de actividad**, en dos tramos (13:05-15:14 y 17:54-18:30);
el corte de las 5 horas fue de reloj de sesión, no de actividad. La sonda de
G **no** estaba escrita antes del corte: antes del corte escribí su primera
versión, con errores de API, y la que corrió (17:54-17:58) la reescribí
entera en la reanudación.

## 8. Cómo trabajé

GLM 5.3 Flash, con el esfuerzo en Max (10.137), como Capitán Codex en el
papel de las aceptaciones (10.129); la consola corre desde **ZCode** (la CLI
de ZCode Desktop) sobre `baystream-qa-r4`. El proyecto de Yov que leí:
`SPRINT-4.md` (decisiones 10.137, 10.141, 10.151, 10.152 y 10.160 a 10.165),
`docs/S4-CASO-A09.md`, AGENTS.md/CLAUDE.md de esta carpeta y la parte
«Entrega 2 · Parte 2b» de `docs/T147-RESULTADOS.md` (E2b-0 a E2b-18).

Las copias limpias quedan en `%TEMP%\t147-glm2b\`: `despues` (la punta),
`v102` (99995db), `p2a` (912daac) y `p2b` (f71675c), cada una con su entrada
de T-124 y sus dependencias, junto con mis registros de comandos; la carpeta
`caso\` con los sintéticos ya la borré en la limpieza, igual que los
archivos tar de la extracción (corregido en la revisión: el primer informe
decía que `caso\` seguía ahí). **No borré `%TEMP%\t147\perfiles\**: ahí
quedan los perfiles de Chrome del arnés; hoy tiene **25 carpetas** (Yov
contaba 24: `1` a `5` de la medición, los tres `e2b-glm2b-*` de preparar
y 17 de recorridos, incluidos los intentos fallidos) y unos **1004 MB**;
Carlos las puede borrar. Todo lo demás de la aceptación vive fuera de
%TEMP%: en `build/t147/glm-e2b/` y en este informe.

## 9. Git para Carlos (lo ejecutas tú)

```powershell
git add -- docs/t147/entrega2b/aceptacion-glm.md
git commit -m "Sprint 4: aceptacion de la parte 2b de la entrega 2 de T-147"
git push origin HEAD:t147-piloto4
```

(la evidencia vive en `build/`, que no se versiona)

---

**En tres líneas:**

1. La parte 2b de la entrega 2 de T-147 **pasa sin hallazgos nuevos**: suite
   2418/2418 y `analyze` en cero, **27 de 41 rojas contra la 1.0.2** (10/17,
   1/2, 7/11 y 9/11) y 7 de 27 contra la 2b exactamente las esperadas, el
   caso y el corpus exactos, y lo que nadie había visto (el muelle frente a
   la cerrada y a la nueva, la salida en la misma laptop, la repetida en la
   nube a 360 × 800, Descarga con la repetida) se vio y cuadra.
2. La medición, alternada y con las 18 corridas válidas, midió **sin el
   listado importado**: el teclado baja de 910.5 a 435.1 ms con la huella; la
   hoja al tocar la celda no quedó más lenta (163.5 → 116.6 ms), aunque esa
   hoja estaba sin filas, que no es la del criterio; y la 2a no quedó más
   lenta que la 1.0.2 (927.9 contra 910.5, dentro del ruido). Con el
   listado, la medición que queda es la de Timonel (10.164).
3. Quedaron sin hacer los puntos 20 a 22 y el muelle en la 1.0.2 en pantalla
   por el corte de sesión; lo que sumo a O-147-12 es que a 360 × 800 el
   aviso completo se lee entero, dura ~4 s y no salió la variante corta con
   «Ver».

**Para Yov:** está la aceptación de la parte 2b en
`docs/t147/entrega2b/aceptacion-glm.md` (revisada, con la sección «Revisión
del 21-nov» al final), con la evidencia en `build/t147/glm-e2b/`. PASA, sin
hallazgos nuevos; el listado de la corrección dio 7 de 27 contra `f71675c` y
7 de 11 contra la 1.0.2, que era tu apuesta y nadie había corrido — y en la
cuenta total son 27 de 41, no las 26 de 40 de mi primer texto. Lo que sumo a
O-147-12: a 360 × 800 el aviso completo se lee entero sin «Ver» y dura lo
que dijiste (~4 s); con tu propuesta de diez segundos queda mejor. Dos
cosas de instrumental que te ahorro: reiniciar el emulador de T-143 borra lo
publicado en la nube (no exporta datos), y tras un reinicio así una página
con la sesión guardada puede fallar el inicio de sesión hasta recargarse.
Sin sesión quedaron los puntos 20 a 22, el punto G.23 (el muelle en la
1.0.2 en pantalla), el punto H.24 (el banco de Windows), la tarjeta de las
cerradas a 360 × 800 y mi propio «No se agrega» a 360 (el de Timonel y las
rojas lo cubren).

## Revisión del 21-nov

Yov comprobó la aceptación contra la carpeta y la evidencia: el dictamen se
sostiene (PASA, sin hallazgos nuevos) y pidió siete correcciones de texto.
Todas aplicadas sobre este mismo archivo; la evidencia no se tocó y no corrió
nada de Flutter ni de Dart para escribirlas. Una línea por cambio: qué decía,
qué dice ahora y de qué archivo sale.

1. **La medición (sección 2, fila F.17 y línea 2 de «En tres líneas»).**
   Decía que se midió «con un perfil preparado por cada banco»; dice que las
   quince corridas de medir usaron los perfiles de la vuelta (\TEMP@\t147\perfiles\1 a
   …\5, uno por vuelta y compartido por los tres bancos de esa vuelta, en el
   orden 1.0.2 → 2a → punta), que los tres perfiles de preparar
   (e2b-glm2b-v102, -2a y -2b, con el listado importado) no se usaron al
   medir, y que se midió **sin el listado importado**: filas_a_la_vista va
   vacía en los pasos «toque» y «tecla» de mis quince registros. Los tres
   criterios quedan recalculados (el del toque se declara no comparable,
   porque esa hoja estaba sin filas); con el listado, la medición que queda
   es la de Timonel (10.164) y no la repetí. Lo que se queda: las 18
   corridas cargaron el programa que se servía (las tres huellas) y mis
   quince cifras son las de mis registros. Fuente:
   herramientas/medir-glm.sh.txt (la línea «--perfil "$3"» de medir()), el
   campo perfil de los navegador.json de las quince corridas y
   filas_a_la_vista en sus pasos.jsonl; los OR 250 a 259, en una corrida de
   Timonel (baystream-t147\build\t147\e2b\medicion\).
2. **El paso 11.d (sección 3).** Decía «con el plano de la cerrada abierto»
   y el mensaje «…Publícala para que el muelle la reciba.»; dice que lo
   recorrí por la tarjeta de «Operaciones cerradas en este dispositivo»,
   con el inicio a la vista y sin ningún plano abierto, y que el mensaje
   tras «Empezar» es «Operación nueva, en este dispositivo. Abre o confirma
   su plano para trabajar en ella.», captura por captura; el camino del
   plano abierto no tiene captura mía y lo cubren las de Timonel (E2b-5.2
   paso 05 y c164-04/05). Fuente: releyendo
   D-emulador/glm-11d-01-cerrada-con-boton.png, glm-11d-02-dialogo.png y
   glm-11d-03-nueva.png en esta revisión.
3. **El paso 11.e (sección 3).** Decía que «408 pendientes: 135 llenos, 273
   vacíos» se ve en glm-11e-02; dice que esa captura no trae la línea (la
   leí en los nodos del control) y que el texto se ve en glm-diag-modo2, en
   la opción «Carga» del menú de modo del muelle, tomada durante la primera
   operación. Fuente: releyendo D-emulador/glm-11e-02-carga-vacia.png y
   D-emulador/glm-diag-modo2.png.
4. **Descarga (punto 14, sección 3).** Decía que «Por bajar» queda en 0;
   dice lo que enseña glm-dl360d-04: «Por bajar 1 · Bajado 1» (antes eran 2
   por bajar), la snackbar «Descargado · ‹matrícula› · 002-03-82 ·
   Deshacer» y la celda con su marca de bajado; el «0» era el campo
   pendientes de mi registro dl-segunda-celda, que es otra cuenta. Fuente:
   D-recorridos/glm-dl-360-dia/capturas/glm-dl360d-04-dl-segunda-celda.png
   y su pasos.jsonl, releídos en esta revisión.
5. **«En tres líneas», línea 1.** Decía «26 de 40 rojas contra la 1.0.2»
   (la cuenta del informe de Timonel, con el listado de 10 pruebas); dice
   **27 de 41** con el desglose 10/17, 1/2, 7/11 y 9/11. Fuente: la última
   línea de los cuatro B/rojas-v102-*.log, releídos en esta revisión.
6. **Las horas (sección 7).** La tabla era una estimación por tramos de
   memoria; está rehecha con la fecha de modificación de los registros de
   \TEMP@\t147-glm2b\ y el campo ts (UTC) de cada pasos.jsonl, con una columna
   que dice de dónde sale cada hora. El total pasa de «unas 4 h 25 min» a
   **unas 2 h 35 min de actividad en dos tramos** (13:05-15:14 y
   17:54-18:30); el corte de las 5 horas fue de reloj de sesión. Y donde
   decía que la sonda de G ya estaba escrita antes del corte, ahora dice
   que antes del corte solo escribí una primera versión con errores de API,
   y la que corrió la reescribí en la reanudación. Fuente: los listados de
   archivos y los pasos.jsonl citados dentro de la propia tabla.
7. **La tabla de la sección 1 y la sección 6.** El «H.23 · muelle en la
   1.0.2 en pantalla» pasa a **G.23** (es de la sección G del encargo) y se
   añade el **H.24**, el banco de Windows de la punta, que no se corrió y
   que el primer informe no nombraba. Fuente: el encargo (sus secciones G
   y H).
8. **La sección 6 y la sección 8.** Se añade que la **tarjeta de las
   cerradas a 360 × 800** no se miró (a ese tamaño miré la cerrada a la
   vista con su botón y el diálogo: glm-13-02 y glm-13-03; la lista-tarjeta
   la vi solo a 1920 × 1080, en glm-11d-01 y glm-12c-02), y que
   \TEMP@\t147\perfiles\ **no se borró**: hoy tiene 25 carpetas y unos 1004 MB
   (Yov contaba 24; el listado de hoy da 25, con los perfiles 1 a 5 de la
   medición, los tres e2b-glm2b-* de preparar y 17 de recorridos, incluidos
   los intentos fallidos). En \TEMP@\t147-glm2b\ la carpeta caso\ ya no está: la
   borré en la limpieza, igual que los tar de la extracción; quedan las
   cuatro copias limpias y mis registros de comandos. Fuente: el listado de
   las dos carpetas y la revisión de las capturas de D-emulador/ hecha en
   esta revisión.
9. **F-medicion/resumen.txt.** Dice lo mismo de los perfiles y pone la hora
   de los ts en UTC como si fuera local. No se cambia (es evidencia); lo
   que dice de más queda declarado aquí y en la sección 2.
