# T-147 · Entrega 1 — aceptación de GLM

GLM 5.3 Flash, en Max · 20-nov-2026 · carpeta `C:\Proyectos\baystream-qa-r4`,
HEAD en la punta de `t147-piloto4` (`57497db`), desde `v1.0.1` (`37be8a5`).
Aceptación de la entrega 1 de T-147 (los defectos del piloto 4), la candidata
**1.0.2+11**. Evidencia: `build/t147/glm-e1/`. No cambié código ni documentos;
no ejecuté ninguna escritura de Git; no publiqué; el caso A09 no entró al
repositorio.

## 1. El dictamen

**PASA.** Los cuatro puntos de la 10.153 y las seis reglas de la entrega 1 se
cumplen: la suite y `analyze` dan lo esperado en copia limpia y aquí, las rojas
fallan 3, 12 y 10 contra `37be8a5`, las cifras del caso coinciden todas con 5.1
de `S4-CASO-A09.md`, el corpus solo cambia en los dos archivos del caso, la Web
del banco dice en pantalla lo que la 10.151 manda mirar, la hoja «Vacíos del
listado» se dibuja en menos de medio segundo con la CPU frenada cuatro veces
donde la 1.0.1 tardaba 10.3 a 10.6 s en esta máquina, y las sondas de lo que el
programador no pensó se comportan como dice el informe de Timonel. **Sin
hallazgos nuevos.**

## 2. La tabla de los puntos

| Punto | Resultado | Evidencia |
|---|---|---|
| 0 · Punta, huellas, `pub get`, entrada de T-124 | ✔ (ver sección 3) | `paso0/` |
| A1 · Dos copias limpias con `git archive` + entrada de T-124 | ✔ | `paso0/`, `%TEMP%\t147-glm\` |
| A2 · `analyze` en la copia limpia (todo el paquete) | «No issues found!» (48.5 s) | `analyze/despues-paquete.log` |
| A2 · `analyze` aquí (lib test tool integration_test) | «No issues found!» (16.0 s) | `analyze/aqui-versionado.log` |
| A3 · Suite en la copia limpia, una corrida | `+2280: All tests passed!`, sin `~` ni `-` | `suite/despues.log` |
| B · Rojas contra `37be8a5` | `+19 -3`, `+3 -12`, `+6 -10` | `rojas/*.log` |
| C5 · Cifras del caso con el lector del producto | todas (sección 5) | `caso/glm-despues-como-vino.json`, `caso/caso-despues-consola.log` |
| C6 · Conteo aparte de segmentos | 709 · 271 · 408 · 0 `LOC+13` | `conteo/conteo-a09.json`, `conteo_segmentos.py` |
| D · Corpus antes y después, con `--comparar` | igual en 12 `.edi` y `LISTADO_A08.xlsx`; DISTINTO solo en `CORPUS_A09.edi` y `LISTADO_A09.xlsx` | `corpus/glm-antes.json`, `glm-despues.json`, `comparar.log` |
| E · La Web del banco, 3 recorridos de 22 capturas | «fin», cero peticiones cortadas, cero errores | `web/glm-360-dia/`, `glm-360-noche/`, `glm-1366-noche/` |
| F · Medición Web «después» y «antes» | criterio cumplido (sección 6) | `medicion/glm-despues-medir-*`, `glm-antes-medir-*` |
| G · La matrícula repetida en pantalla | aviso, diálogo y plano (sección 7) | `glm-matricula-repetida/` |
| H14 · El lector con planes sintéticos | las cinco variantes (sección 8) | `sondas/h14-lector.json` |
| H15 · El listado con hojas sintéticas | las cuatro variantes (sección 8) | `sondas/h15-listado-*.json` |
| H16 · El listado de la 1.0.2 lo abre la 1.0.1 | los mismos 23 grupos | `sondas/h16-leido-por-101.json` |
| H17 · El BAPLIE de salida del caso | sin `EQD+CN+NO`, sin `LOC+13`, releído sin avisos | `sondas/h17-salida.json` |
| I · Windows del banco | recorrido de noche + una medición | `windows/glm-w-recorrido/`, `glm-w-medir/` |

## 3. El paso 0

- `git log --oneline -3`: la punta es «Sprint 4: T-147, entrega 1: la hoja de
  los vacios no se traba, NO es sin numero, el cruce va por el POT y la
  candidata 1.0.2», y debajo está `37be8a5`. `git show --stat HEAD` trae
  exactamente las 30 rutas de la sección 12 del informe de Timonel y ninguna
  más.
- `CORPUS_A09.edi`: 123 619 bytes, SHA-256 `450219fe01c62e0c33e946c9d73c17f5
  765917376c74ccce3636200e76e0f07e` ✔. `LISTADO_A09.xlsx`: 64 524 bytes,
  `df40cd6fa1d58794016acbc2b9cfe8c0b7127012124e434c57cc18ba369daad0` ✔.
- `CORPUS_A07.edi`, `CORPUS_A08.edi` y `LISTADO_A08.xlsx` no están en la carpeta
  del corpus: están sueltos en el Escritorio, como dice el encargo (el
  `CLAUDE.md` de esta carpeta todavía dice lo contrario).
- `flutter pub get --offline --enforce-lockfile`: salida 0, aquí y en las dos
  copias limpias; `pubspec.lock` no cambió.
- `build\t124\entradas\t124_entradas.dart`: huella
  `d4384834fb9fc9cb18632b87180a7998cc3f91109edcbd33dbbf9787542d1162` ✔, y la
  misma en las dos copias.

## 4. La suite, `analyze` y las rojas

Las dos copias limpias están en `%TEMP%\t147-glm\` (`t147-glm-despues`, de
`57497db`, y `t147-glm-antes`, de `37be8a5`), hechas con `git -c
core.autocrlf=false archive --format=tar` y `tar -x`, sin tuberías. Las rojas
sobre la copia «antes», con los cinco archivos de la punta sacados con
`git archive`:

| Prueba | Contra `37be8a5` | Por qué falla |
|---|---|---|
| `t147_hoja_vacios_test.dart` | **+19 −3** | `identical(state.occupancy, state.occupancy)` da falso: la ocupación se rehace en cada lectura; y la prueba de escala **cuenta lecturas**: 15 123 272 y 15 121 772 contra el tope de 24 000 |
| `t147_lector_test.dart` | **+3 −12** | «NO» queda como contenedores (espera 3 y hay 6), sin aviso `noNumber`, la tarjeta no dice «N contenedores · N celdas reservadas», el BAPLIE de salida escribe «NO», y la matrícula repetida no se avisa (`null`) |
| `t147_listado_test.dart` | **+6 −10** | «COD.»/«TRANSBORDOS»/«VACIOS» quedan como filas sin entender; el puerto de la fila es el POD (espera COCTG y da INMUN); quedan `port:COTRB` y `port:CNTAO` pendientes; el vacío cruza por el POD (CNTAO) y no por el POT (JMKIN); no sale «Todas las filas se entendieron.»; la identidad propuesta no se ofrece |

Las tres compilan en `37be8a5` y fallan por comportamiento: son las rojas de
Timonel, una a una.

## 5. Las cifras del caso (C)

`dart run tool/t147_caso.dart --plan … --listado … --elegir "tipo:20ST=22G1,
tipo:20TK=22K2, tipo:40HC=45G1, tipo:45HC=L5G1, tipo:20OT=22U1, tipo:40FF=42P3,
tipo:40HF=45P3, tipo:40OT=42U1, tipo:40RF=42R1" --medir --salida …` sobre la
copia «despues». Mi número al lado del esperado (5.1 del caso):

| Cifra | Esperada | Mía |
|---|---|---|
| Contenedores / celdas reservadas | 438 / 271 | 438 / 271 |
| Avisos del lector | uno: «NO» en 271 celdas | uno: `noNumber`, ««NO» en 271 celdas» |
| Matrículas repetidas | ninguna | 0 |
| Carga: pendientes / llenos / vacíos | 408 / 135 / 273 | 408 / 135 / 273 (271 reservas + 2 vacíos con matrícula) |
| Bahía 01 | 4 cont. · 3 reservas · 116.0 t | 4 · 3 · 116.0 |
| Bahía 18 | 9 cont. · 73 reservas · 148.2 t | 9 · 73 · 148.2 |
| Listado: filas / llenos / vacíos | 448 / 172 / 276 | 448 / 172 / 276 |
| Filas sin entender | ninguna | ninguna |
| Secciones | 141 · 6 · 187 · 53 · 61 | 141 · 6 · 187 · 53 · 61 |
| Filas con POT ≠ POD | 202 | 202 |
| Puertos pendientes | ninguno | ninguno |
| Puertos por identidad con respaldo | COCTG 58 · COTRB 55 · JMKIN 18 · COBAQ 6 (137) | 58 · 55 · 18 · 6 (137) |
| Tipos pendientes | los nueve de 4.3 | 20ST, 20TK, 40HC, 45HC, 20OT, 40FF, 40HF, 40OT, 40RF |
| Llenos que cruzan | 135 de 172 | 135 de 172 |
| Del plan fuera del listado | 0 | 0 |
| Vacíos en grupos | 276 de 276 en 23 grupos, cuadran 7 | 276 de 276, 23 grupos, 7 |
| Llenos fuera del plan | 37 | 37 |
| Llenos con datos distintos | 17, todos por el tipo | 17 · tipo 17 · puerto 0 · los dos 0 |
| VGM distinto | 94, el plan suma 4.6 t menos | 94 · −4.6 t |
| La hoja | abre sin trabarse; ofrece lo mismo que la 1.0.1 | `ofreceLoMismoQueLa101: true`; 0.138 ms |

**El conteo aparte de segmentos** (mi script en `%TEMP%`, cortando los bloques
en `LOC+147` como la 10.152): 709 bloques, 271 con `EQD+CN+NO+`, 408 con
`LOC+9+GTSTC` (los 271 «NO» más 137 con matrícula: 135 llenos y 2 vacíos),
**ningún `LOC+13` en todo el archivo** ✔.

**El corpus (D)**, con `t147_corpus.dart` de la punta corriendo en las dos
copias (compila en las dos): «igual» en A01, A02, A03, A03v, A04, A05, A06, A07,
A08, A08v, `PRUEBA_NIVEL_78` y `PRUEBA_NIVEL_80`, y en `LISTADO_A08.xlsx`;
«DISTINTO» solo en `CORPUS_A09.edi` (709 y 0 → 438 y 271, con el aviso
`noNumber`) y en `LISTADO_A09.xlsx` (3 → 0 filas sin entender, 3 → 5 secciones,
13 → 9 pendientes). Dos distintos, los dos del caso ✔.

## 6. La medición (F)

**El instrumento** es el escenario `medir` del conductor, idéntico al que usó
Timonel; el banco Web compilado en la copia «despues», Chrome 157.0.8103.79
controlado por Playwright (`channel='chrome'`, ventana visible, escala 2),
perfil nuevo en `%TEMP%\t147\perfiles\` (preparar una vez con perfil nuevo;
las seis corridas de medir sobre ese mismo perfil, cada una con un arranque
nuevo de Chrome). 360 × 800, tema de día, la celda pedida 018-00-84, que no
estaba al alcance: el conductor tocó la 018-10-88, la misma de las 24 corridas
de Timonel. La máquina quedó quieta durante cada corrida (nada más corriendo
de mi parte; la sesión del agente y OneDrive son el fondo permanente).

**«Después»**, de soltar el dedo a la hoja dibujada (`dibujada_ms` del paso
«toque»), tres corridas sin frenar y tres con `--cpu 4`:

| | Mis tres corridas | Timonel | Criterio |
|---|---|---|---|
| Web · tocar la celda | 41.2 · 40.1 · 42.0 ms | 34–37 ms | — |
| Web · el teclado | 183.2 · 181.1 · 197.2 ms | 145–148 ms | — |
| Web · una tecla | 27.1 · 27.5 · 24.8 ms | 20–23 ms | — |
| **Web, CPU ÷ 4 · tocar la celda** | **237.3 · 246.5 · 260.8 ms** | 160–198 ms | **las tres < 500 ms ✔** |
| Web, CPU ÷ 4 · el teclado | 1167.7 · 1145.8 · 1167.3 ms | 698–735 ms | (O-147-1) |
| Web, CPU ÷ 4 · una tecla | 160.6 · 166.6 · 161.2 ms | 98–128 ms | — |

**«Antes»** (banco compilado sobre `37be8a5` con las nueve herramientas de
`build\t147\e1\antes\herramientas\` de la evidencia de Timonel; la copia en
blanco del plan hecha con `t147_copia_en_blanco.py` de la punta: 271
reemplazos, SHA-256 `cd80a4dcd116462c6cb5627d9aa71def7284e4bf12b9dc0dc19d94b
7f747799e`; las trece equivalencias de `antes\web-preparar\navegador.json`),
con la CPU frenada, tres corridas:

| Antes, CPU ÷ 4 · tocar la celda | 10 278.0 · 10 322.9 · 10 649.6 ms | Timonel: 5 577–5 735 ms |
|---|---|---|

El orden es el del iPhone de Carlos (unos 6 s), amplificado por esta máquina,
que corrió mis corridas algo más lenta que la de Timonel (en «después» un
factor de 1.3; el criterio no depende de eso: **la hoja dibujada en menos de
medio segundo con la CPU frenada, en las tres corridas ✔**). La relación
antes/después en mi máquina es de unas **40 veces**. El teclado frenado
(1.15 s) es el redibujar el plano de debajo de O-147-1, que no es de la hoja.

**Windows (I)**, el banco compilado `--release` con `-t tool/t147_main.dart`,
copiado a `%TEMP%\t147-glm\windows\`, namespace `r4` con el almacén en
`%TEMP%\t147-glm\store-glm-w\`: recorrido a 1366 × 690 de noche y una corrida
de medir a 360 × 800 con el almacén en cero (ver sección 9). No es una Release
de publicación: es el banco. No abrí la BayStream instalada,
`%LOCALAPPDATA%\BayStream` ni la carpeta de ninguna MSIX; Firebase no se tocó.

## 7. La Web, a la vista (E): captura por captura

Tres recorridos completos (360 × 800 de día, 360 × 800 de noche, 1366 × 690 de
noche), cada uno con 22 capturas, `pasos.jsonl` terminado en «fin», `red.json`
sin ninguna petición cortada (84 servidas, todas de `127.0.0.1:5947`) y
`consola.log` sin errores de Flutter. Abrí las 22 de la corrida de día y las
capturas clave de las otras dos; los textos de las tres corridas son los mismos
(cotejados una a una). Lo que lee el planificador, captura por captura
(nombres de la corrida de día):

- **01 plan-en-previo**: «BUQUE HOTEL · Viaje VIAJE009A», «Plano sin confirmar:
  perfil propuesto desde el archivo. Escala propuesta GTSTC.» con «Confirmar»,
  y la bahía 01 con «4 contenedores · 3 celdas reservadas · 116.0 t» y sus tres
  reservas dibujadas.
- **02 plan-publicado**: la bahía 01 en modo Contenido, «Bahía 01 · tapas sin
  declarar» y las tres reservas con su tipo (22T4/22K2 COCTG) y los contenedores
  con su peso.
- **03 lista-tarjeta-del-viaje**: la franja roja «Celdas sin matrícula en EQD:
  «NO» en 271 celdas · se leyeron como celdas reservadas» con su flecha; la
  tarjeta con «438 contenedores · 271 celdas reservadas», «Escala: GTSTC», «Se
  cargan 137 contenedores y 271 reservas (408 movimientos)», «Se descargan 0
  contenedores y 0 reservas (0 movimientos)» y «De paso 301 contenedores y 0
  reservas».
- **04 aviso-sin-matricula**: al tocarlo, el diálogo con el título y «El archivo
  trae un texto donde va la matrícula. Esas celdas se leyeron como reservadas,
  con su tipo, sus puertos, su línea y su peso: el vacío de cada una se asigna
  al cargar.» y la línea ««NO» en 271 celdas».
- **05 carga-sin-listado**: Carga en la bahía 01; las tres reservas se ven «—
  Sube»; el resumen «Carga: 408 pendientes, 135 llenos, 273 vacíos» lo anota el
  conductor y a 360 dp no está a la vista (queda bajo el pliegue del plano); a
  1366 × 690 se lee en la barra de estado de abajo y arriba en «Carga 0 de 408 ·
  Llenos 0 de 135 · Vacíos 0 de 273».
- **06 listado-leido**: «448 filas en 5 agencias · 172 llenos · 276 vacíos»; las
  cinco secciones con AGENCIA 1 S.A.: 141, TRANSBORDOS: 6, VACIOS: 187, AGENCIA
  2 S.A.: 53, AGREGADOS: 61; «202 filas traen POT y POD distintos: el cruce con
  el plan usa el POT, donde el contenedor baja del buque.»; «Todas las filas se
  entendieron.»; y la primera pendiente «Tipo 20ST → ?» con «Los contenedores no
  coinciden: 22G1 (19), 22G0 (1). Elige el código del plan.»; «Confirmar e
  importar» apagado.
- **07 equivalencias**: nueve pendientes, todas de tipo (20ST, 20TK, 40HC, 45HC,
  …), con sus respaldos; ninguno de puerto.
- **08 equivalencias-elegidas**: «Tipo 20ST → 22G1 · Elegida por ti.»; las
  deducidas como «Propuesta: N contenedores están en el listado y en el plan.»
  (40ST → 42G1 con 1, 40RA → 45R4 con 6, 40RC → 45R5 con 13, 40RH → 45R1 con
  14); «Confirmar e importar» ya encendido.
- **09 cruce**: «135 de 172 llenos cruzan con el plan», «0 contenedores del plan
  no están en el listado», «276 de 276 vacíos en 23 grupos de reservas», y los
  grupos con las cuentas de la tabla de 4.4 («42G1 · COTRB · LNH: 63 vacíos, 62
  celdas», «L5G1 · COTRB · LNH: 64 vacíos, 61 celdas», «45R1 · JMKIN · LNH: 43
  vacíos, 43 celdas», «45G1 · COTRB · LNH: 34 vacíos, 28 celdas»…).
- **10 listado-importado**: el final del cruce con «Llenos del listado que no
  están en el plan (37)», «Llenos con datos distintos (17)» y «94 llenos con VGM
  distinto del plan: el plan suma 4.6 t menos que el listado. Se guarda el VGM
  del listado.»; el aviso «Listado importado.».
- **11 carga-bahia**: la bahía 18 en Carga: «9 contenedores · 73 celdas
  reservadas · 148.2 t»; las reservas «Sube» con sus grupos y «OR 446 · Sube» en
  la celda del lleno ya planificado.
- **12 hoja-vacios** (tocada la reserva 018-10-88): «Vacíos del listado» con el
  campo «OR o últimos dígitos» y primero los de su grupo: OR 250 · XYRU4882688,
  OR 251, OR 252…, todos «L5G1 · COTRB · LNH». Se abre sin trabarse y el
  registro de la medición dice lo que tarda (sección 6).
- **13 asignar-vacio-en-su-grupo**: «Asignar vacío», OR 250 · XYRU4882688, «L5G1
  · COTRB · LNH», «Tara real: 4750 kg», «Reservas libres del mismo tipo, puerto
  y línea.», el selector «Celda reservada 018-10-88», «Pila de cubierta 018,
  fila 10: 4.8 t. Peso no evaluado: el perfil no declara límite.», «Revisado:
  tipo, celda y grupo coinciden con el plan.» y «Confirmar carga».
- **14 vacio-en-su-grupo-asignado**: la celda 018-10-88 en verde «OR 250 ·
  Cargado» y «Carga registrada · OR 250 · Deshacer»; el resumen pasa a «Carga:
  407 pendientes, 135 llenos, 272 vacíos».
- **15 hoja-vacios-segunda-celda** (reserva 018-08-88): la hoja otra vez
  empezando por su grupo (OR 251…, ya sin el OR 250 cargado).
- **16 hoja-vacios-otro-grupo**: después, «Otro grupo: pide motivo»: OR 153 ·
  «22K2 · COCTG · LNH · Otro grupo: pide motivo», OR 156 · «45G1 · COTRB · LNH ·
  Otro grupo: pide motivo»…
- **17 asignar-vacio-en-otro-grupo**: «Asignar vacío» con OR 156 · XDGU4305295,
  «45G1 · COTRB · LNH», el selector «018-08-88 · otro grupo», «Mostrar reservas
  de otros grupos» encendido, «Pide motivo: La reserva 018-08-88 es de otro
  grupo (tipo L5G1); el OR 156 es 45G1 · COTRB · LNH. Para cargarlo ahí, escribe
  el motivo; si no, elige una reserva de su grupo.», y «Confirmar carga»
  deshabilitado mientras el motivo está vacío.
- **18 asignar-vacio-en-otro-grupo-con-motivo**: «Motivo (obligatorio)» con el
  texto escrito; «Confirmar carga» encendido.
- **19 vacio-en-otro-grupo-asignado**: la celda 018-08-88 en ámbar «OR 156 ·
  Revisar»; «Carga registrada · OR 156 · Deshacer»; «Carga: 406 pendientes, 135
  llenos, 271 vacíos».
- **20 confirmar-carga-de-un-lleno**: «Confirmar carga», OR 446 · XPRU4933658,
  «45R4 · JMKIN · LNH», **«POT JMKIN · POD BSNAS»**, **«Posición planificada:
  018-02-82»**, «Revisado: tipo, celda y grupo coinciden con el plan.»
- **21 lleno-cargado**: «Carga registrada · OR 446 · Deshacer»; «Carga: 405
  pendientes, 134 llenos, 271 vacíos».
- **22 carga-al-final**: el plano final con «OR 446 · Cargado», los vacíos ya
  cargados con su OR (139, 140, 141) y la celda del vacío de otro grupo en
  «Revisar».

**Los textos que no caben.** El conductor anota los recortes a 360 dp: los
grupos de las celdas («L5G1 COTRB LNH» → «L5G1 C…»), el rótulo del selector de
bahía («Bahía 18: grupo 1…»), el resumen «Carga: 408 pendientes, 135 llenos,
273 vacíos» y «Descarga: 0 pendientes, 0 re‑estibas», el aviso «Sin listado de
agencia: los llenos se cargan por su número; los vacíos esperan el listado» y
«Celda donde quedó (opcional…». Son exactamente los mismos que anotó Timonel en
sus corridas (cotejados contra `baystream-t147\build\t147\e1\despues\
web-recorrido-360-dia\pasos.jsonl`): vienen de la 1.0.1 y van con O-147-6; les
sumo esos textos a la lista del conocido. Los dos pisones de «Asignar vacío» que
vio Yov («…puerto y línea.» sobre «Celda reservada» y «Motivo» sobre el borde de
«Marchamo») se ven igual en mis capturas 13 y 18. Nada nuevo.

## 8. Lo que nadie miró y lo que el programador no pensó (G y H)

**G · La matrícula repetida en pantalla.** Plan sintético a partir del caso, con
la misma matrícula (`XJZU5616792`, con forma y dígito válido) en las dos celdas
018-01-82 y 018-00-82, que cargan en GTSTC (bahía 18). En el banco Web
(sonda mía, capturas en `glm-matricula-repetida/`):
- el lector lo lee con **dos avisos**: el `noNumber` de los 271 «NO» del caso
  base y el `duplicate`: «Matrículas repetidas en EQD: 1 contenedor · revisa
  esas celdas con quien hizo el plan»;
- la tarjeta del viaje enseña los dos avisos y «438 contenedores · 271 celdas
  reservadas»;
- al tocar el aviso, el diálogo: «La misma matrícula viene en más de una celda.
  Un contenedor solo puede estar en una: pide el plan corregido antes de operar
  esas celdas.» y la línea «XJZU5616792: 018-01-82 y 018-00-82» con las dos
  celdas;
- en el plano de Carga (bahía 18, captura `glm-g-04`), el resumen baja a
  «Carga: 407 pendientes, 134 llenos, 273 vacíos» — una carga donde el plan trae
  dos — y la bahía dice «9 contenedores, 73 celdas reservadas, 140.3 t», donde
  el plan trae 148.2 t: una diferencia de 7.9 t cuyo porqué no comprobé. En esa
  captura, la celda 018-00-82 se ve con «— Sube», como cualquier carga pendiente
  (ahí está la pieza `C:XJZU5616792`), y la celda 018-01-82 queda hueco sin
  contenedor (`cell-1-82`, sin texto en el registro «celdas_de_la_bahia»,
  rodeada de ocho reservas `loading-R:`). Mi sonda buscó tocar
  `loading-C:XKLU3034357` y `cell-0-82`, que no están en el árbol (esa matrícula
  ya no existe en el plan sintético), y tocó `cell-1-82`, el hueco: no abrió
  nada. **Al tocar la pieza en 018-00-82 no la miré**: queda sin mirar. Es lo
  que 3.3 del informe dejó escrito («la primera celda se queda sin contenedor y
  no se puede operar»): la pantalla lo muestra tal cual, no falla y no dice otra
  cosa. No es hallazgo.

**H14 · El lector con planes sintéticos** (`sondas/h14-lector.json`; planes
generados a partir del caso cambiando solo los `EQD`):
- «NO» en **una sola** celda (270 blancos): 271 reservas y el aviso ««NO» en 1
  celda» ✔;
- «TBA» en **dos** celdas (269 blancos): 271 reservas y el aviso ««TBA» en 2
  celdas» — dos reservas y su línea en el aviso ✔;
- «TBA» en **una** celda (270 blancos): el TBA es **un contenedor** (439
  contenedores en `001-02-84`), 270 reservas, sin aviso ✔;
- «NO» y el número en blanco en el mismo archivo: todos son reservas (271) y el
  aviso cuenta solo las «NO» ✔;
- una matrícula con forma y con el dígito de control mal (`TSTU0000179`) en dos
  celdas: **«Matrículas repetidas»** («TSTU0000179: 001-02-84 y 001-06-84»), no
  «sin número» ✔; además sale el aviso de dígito de control que ya existía
  (`checkDigit`, dos líneas), que el lector solo emite cuando el dígito está mal
  de verdad;
- una celda con «NO» que no carga en la escala (014-06-06, `LOC+9+USHOU`): 272
  reservas y el aviso ««NO» en 272 celdas» (la cuenta del archivo). **En
  pantalla** (capturas `glm-p5/`): la tarjeta dice «437 contenedores · 272
  celdas reservadas» con el aviso, pero separa la escala: «Se cargan 137
  contenedores y 271 reservas (408 movimientos)» y «De paso 300 contenedores y
  1 reserva»; en el plano, la celda 014-06-06 se dibuja como reservada en
  Contenido y en Carga (`reserved-R:0140606`) y no entra en los pendientes de
  la escala («Carga: 408 pendientes…»).

**H15 · El listado con hojas sintéticas** (`sondas/h15-listado-*.json`; hojas
armadas como enseña `t147_listado_support.dart`):
- la columna **POT vacía** en unas filas: esas filas cruzan por el POD (OR 2
  pot nulo → cruza por COCTG; OR 3 pot nulo → cruza por ITLIV) y las que traen
  POT cruzan por el POT (OR 1: POT COCTG con POD INMUN cruza por COCTG) ✔;
- **sin la columna POT**: las filas cruzan por el POD en la 1.0.2 y en la 1.0.1
  con los mismos grupos (`45G1 · COTRB · LNH 2/2`, `22G1 · JMKIN · LNJ 1/1`,
  `45R1 · JMKIN · LNH 1/0`): el cruce es igual al de la 1.0.1 ✔; lo único
  distinto es lo que R6 y R5 traen a propósito (la 1.0.1 deja «TRANSBORDOS» y
  «VACIOS» como filas sin entender y «Sin agencia»; la 1.0.2 las reconoce; y
  `port:COTRB` sale por identidad propuesta en la 1.0.2 y queda pendiente en la
  1.0.1);
- **«Cod.», «CÓDIGO», «VACÍO» y «TRANSBORDO»**: las cuatro formas se reconocen
  como secciones (secciones «COD.», «TRANSBORDO», «VACIO»), con la agencia que
  dice «CÓDIGO» reconocida, y ninguna fila sin entender ✔;
- una fila **«VACIOS PENDIENTES DE CONFIRMAR»** se informa: «No es un
  contenedor ni un separador de agencia: «VACIOS PENDIENTES DE CONFIRMAR».» ✔.

**H16 · Lo que guarda la 1.0.2 lo abre la 1.0.1** (`sondas/
h16-leido-por-101.json`): la sonda de la copia «despues» escribió el listado del
caso ya normalizado con las nueve equivalencias (`ExportList.toJson`, 448
filas) en `%TEMP%`; la sonda de la copia «antes» lo abrió con
`ExportList.fromJson` (1.0.1) y lo cruzó contra el plan en blanco: **448 filas,
172 llenos, 276 vacíos, 135 llenos que cruzan, 0 del plan fuera del listado,
276 vacíos en 23 grupos y ninguno sin grupo**, con las mismas cuentas de vacíos
y celdas del punto 5, grupo por grupo (63/62, 64/61, 43/43, 34/28, 24/24, 10/10,
8/8, 9/6, 6/5, 8/4, 3/3, 0/3, 0/3, 0/3, 0/2, 1/1, 1/1, 0/1, 0/1, 0/1, 0/1, 2/1,
0/1) ✔.

**H17 · El BAPLIE de salida del caso** (`sondas/h17-salida.json`): la operación
armada con el plan como vino y el listado con las nueve, con tres cargas
registradas — el vacío XSPU1121509 (OR 400) en su grupo, en la celda 018-01-02;
el vacío XYRU4882688 (OR 250) en la celda 030-02-02 de otro grupo, con su
motivo; y el lleno XLCU9606945 (OR 1, POT distinto de su destino final) en la
celda 015-03-02 del plan —:
- la salida trae **304 grupos EQD** (los 301 de paso más los 3 cargados) y
  **405 cargas pendientes** (408 − 3);
- **no trae `EQD+CN+NO`** ✔;
- los dos vacíos salen en sus celdas con su matrícula ✔;
- el lleno lleva el POT en `LOC+11` (`LOC+11+COCTG:` presente) y **no trae
  `LOC+13`** en toda la salida ✔;
- vuelta a leer con el lector del producto: **304 contenedores, 0 reservas,
  cero avisos** ✔.

## 9. Windows (I)

Banco compilado `--release` con `-t tool/t147_main.dart`, copiado a
`%TEMP%\t147-glm\windows\`, con `--almacen %TEMP%\t147-glm\store-glm-w` y
`--caso %TEMP%\t147-glm\caso` (los dos archivos del caso copiados a `%TEMP%`).

**El recorrido** a 1366 × 690 de noche (`windows/glm-w-recorrido/`): «fin», 22
capturas, y los mismos textos clave que la Web (cotejados uno a uno en el
`pasos.jsonl`). Lo que vi en las capturas: la tarjeta del viaje con el aviso
«Celdas sin matrícula en EQD: «NO» en 271 celdas · se leyeron como celdas
reservadas» y «438 contenedores · 271 celdas reservadas»; la hoja «Vacíos del
listado» abierta sin trabarse, con el orden propio de Windows dentro del grupo
(OR 269, 284, 250, 251, 252… — el `sort` no estable de O-147-3); y el final con
«Carga: 405 pendientes, 134 llenos, 271 vacíos», el panel «En vivo» con los
tres movimientos («Cargado · Muelle XPRU4933658 · 018-02-82», «Vacío asignado ·
Muelle XFTU2047051 · 018-08-88», «Vacío asignado · Muelle XNKU4325850 ·
018-10-88») y el plano con «OR 269 · Cargado», «OR 239 · Revisar» y «OR 446 ·
Cargado».

**La medición** a 360 × 800, con el almacén en cero
(`windows/glm-w-medir/`): de soltar el dedo a la hoja dibujada, **toque 59.3
ms**, el teclado 115.2 ms y una tecla 66.9 ms — el mismo orden que midió
Timonel (toque 18 a 51 ms, teclado 79 a 101 ms, tecla 47 a 71 ms).

**Un intento fallido, que quedó de registro**
(`windows/glm-w-medir-intento-fallido/`): la primera corrida de medir usó el
mismo almacén que acababa de dejar el recorrido nocturno (con tres cargas y la
reserva 018-08-88 en «Revisar»); el conductor tocó una reserva ya asignada, la
hoja no abrió y la medición se detuvo a los tres minutos por su propio tope
(«La medición no terminó en tres minutos»). No es un defecto del producto: el
instrumento necesita el almacén en el estado que dejó `preparar` (o limpio),
como lo corrió Timonel. La repetí con el almacén borrado y salió de una.

No es una Release de publicación: es el banco, con el namespace `r4`. No abrí
la BayStream instalada, `%LOCALAPPDATA%\BayStream` ni la carpeta de ninguna
MSIX; Firebase no se tocó.

## 10. Los hallazgos

**Ninguno nuevo.** Los conocidos no cuentan y quedan con datos extra:
- **O-147-6** (textos que no caben a 360 dp): a la lista conocida se suman los
  recortes que el conductor anota y que ya estaban en las capturas de Timonel:
  el rótulo del selector de bahía («Bahía 01: grupo 0…»), el resumen «Carga: …
  pendientes…» y «Descarga: …», el aviso «Sin listado de agencia: …» y «Celda
  donde quedó (opcional…)». Los dos pisones de «Asignar vacío» se ven igual en
  mis capturas.
- O-147-1 a O-147-5, las 40 filas canceladas, las equivalencias guardadas, las
  16 celdas con otro ISO del mismo tipo, el destino final fuera del BAPLIE de
  salida, `DESIGN.md` y el manual sin actualizar, O-143-3 y O-146-1: sin datos
  nuevos de mi parte, salvo la medición del teclado frenado (sección 6) que
  apunta a O-147-1.

**Lo que no se pudo**, y por qué:
- No se probó en un iPhone ni en el Honor, como dice el encargo; la CPU frenada
  cuatro veces es una aproximación. El Honor va desconectado y no corrí
  `flutter run`, `flutter install` ni `adb install` contra él.
- El teclado de la medición es el simulado del conductor (`viewInsets` a 300),
  no un teclado real.
- En la sonda del punto H17, el campo «motivo» del JSON quedó mal etiquetado
  (trae la matrícula del vacío en vez del texto del motivo); el motivo real viaja
  en el payload del movimiento y la verificación de la salida no depende de esa
  etiqueta.

## 11. Cómo trabajaste

- **Modelo**: GLM 5.3 Flash, con el esfuerzo en **Max** (decisión 10.137).
- **Desde dónde corre mi consola**: la aplicación ZCode (agente de terminal)
  sobre Windows, abierta en `C:\Proyectos\baystream-qa-r4`.
- Todo lo que se ejecutó (Flutter, Dart, Python, Playwright) corrió en esta
  máquina, una ventana de Flutter o Dart a la vez con las líneas `SEMÁFORO:`
  de cada ventana en el mensaje; durante las corridas de medición la máquina
  no hizo nada más por mi parte.
- Las copias limpias quedan en `%TEMP%\t147-glm\` (`t147-glm-despues` y
  `t147-glm-antes`, sin los bancos compilados: ver sección 13); las copias del
  caso y lo que salió de él se borran al cerrar (sección 13).

## 12. Las horas del reloj

Hora local (Guatemala, UTC−6). Cada tramo sale de un archivo: la fecha de
modificación de los registros y el campo `ts` (UTC) de cada `pasos.jsonl`. El
inicio de la sesión (las lecturas del paso 0) no dejó archivo: el primer
registro de la aceptación es el `analyze` de la copia limpia.

| Tramo | Horas (20-nov, local) | Qué | Respaldo |
|---|---|---|---|
| 1 | hasta las 11:57:23 | Las lecturas del paso 0 (sin archivo propio) | — |
| 2 | hasta 11:57:47 | Copias limpias y los dos `analyze` | mtime de `analyze/despues-paquete.log` (11:57:23) y `analyze/aqui-versionado.log` (11:57:47) |
| 3 | hasta 12:00:27 | La suite | mtime de `suite/despues.log` |
| 4 | hasta 12:01:30 | Las rojas | mtime de los tres `rojas/*.log` (12:01:10, 12:01:20, 12:01:30) |
| 5 | hasta 12:03:11 | Las cifras del caso (C) y el conteo de segmentos | mtime de `caso/caso-despues-consola.log` (12:02:22), `caso/glm-despues-como-vino.json` (12:03:06) y `conteo/conteo-a09.json` (12:03:11) |
| 6 | hasta 12:04:13 | El corpus antes/después (D) | mtime de `corpus/despues-consola.log` (12:03:45), `corpus/antes-consola.log` (12:03:59) y `corpus/comparar.log` (12:04:13) |
| 7 | hasta 12:06:17 | La compilación del banco Web | mtime de `web/build-web.log` |
| 8 | 12:06:36 a 12:08:10 | Los tres recorridos (E) | `ts` de los tres `pasos.jsonl` de `web/` (UTC−6) |
| 9 | 12:08 a 12:16 | La mirada de las capturas (sin registro de archivo) | — |
| 10 | 12:16:22 a 12:19:56 | La medición «después» (F): preparar y las seis corridas | `ts` de `medicion/glm-despues-*` |
| 11 | hasta 12:22:01, y 12:22:26 a 12:26:26 | El banco «antes»: compilación, preparar y las tres corridas frenadas | mtime de `web/build-web-antes.log` (12:22:01) y `ts` de `medicion/glm-antes-*` |
| 12 | 12:44:08 a 12:44:13 | La matrícula repetida en pantalla (G), corrida que quedó | `ts` de `glm-matricula-repetida/pasos.jsonl` (las dos corridas anteriores se sobrescribieron al recompilar y no dejaron registro) |
| 13 | 12:54:46 | La sonda del lector (H14) | mtime de `sondas/h14-lector.json` |
| 14 | 12:57:17 a 12:57:30 | La variante del «NO» fuera de escala en pantalla (H14e) | mtime de `web/build-web-g.log` (12:57:17) y `ts` de `glm-p5/pasos.jsonl` |
| 15 | 13:01:18 a 13:01:20 | Los listados sintéticos (H15) | mtime de `sondas/h15-listado-*.json` |
| 16 | 13:03:06 | El guardado de la 1.0.2 leído por la 1.0.1 (H16) | mtime de `sondas/h16-leido-por-101.json` |
| 17 | 13:05:36 | El BAPLIE de salida del caso (H17) | mtime de `sondas/h17-salida.json` |
| 18 | hasta 13:08:25, y 13:10:13 a 13:15:49 | Windows (I): compilación, recorrido, intento fallido de medición (13:11:09 a 13:14:14) y medición | mtime de `web/build-windows.log` (13:08:25) y `ts` de `windows/*` |
| 19 | escrito después de 13:15; su modificación quedó a las 13:17:38 | Este informe | mtime del informe |
| 20 | después de las 13:17 | La revisión del 20-nov (esta sección) | mtime del informe al guardar |

## 13. La limpieza

- Al terminar borré de `%TEMP%`: las copias del caso (`t147-glm\caso`,
  `t147-glm\caso-g`, `t147-glm\sondas`), `t147-glm\listado-102.json`, los
  perfiles de Chrome `glm-360-dia`, `glm-360-noche`, `glm-1366-noche`,
  `glm-medir`, `glm-medir-antes`, `glm-g`, `glm-p5`, el almacén
  `store-glm-w`, el banco de Windows compilado (`t147-glm\windows`) y los
  `.tar` de las copias.
- **Las copias limpias se quedan** en `%TEMP%\t147-glm\t147-glm-despues` y
  `%TEMP%\t147-glm\t147-glm-antes`, listadas a mano el 20-nov después de la
  limpieza. **No tienen carpeta `build/`** (la borré con los resultados de las
  corridas): la entrada de T-124 (`build\t124\entradas\t124_entradas.dart`) ya
  **no está dentro de las copias**; esa sigue solo en `build\t124\entradas\` de
  esta carpeta, por su huella. En `tool\` de `t147-glm-despues` quedan mis seis
  sondas (`glm_g.dart`, `glm_main_g.dart`, `glm_lector.dart`, `glm_listado.dart`,
  `glm_guardado.dart`, `glm_salida.dart`) junto al `tool\` versionado; en
  `tool\` de `t147-glm-antes`, mis dos sondas (`glm_listado.dart`,
  `glm_leer_101.dart`) y las herramientas copiadas de la evidencia de Timonel
  (las nueve de `antes\herramientas\` y `t147_corpus.dart` de la punta). Sueltas
  en `%TEMP%\t147-glm\` quedan cuatro archivos míos sin datos del caso:
  `conteo-a09.json` (conteos y códigos), `conteo_segmentos.py`,
  `plan_repetido.py` y `planes_lector.py`. Se pueden borrar después de la
  revisión de Yov.
- Los bancos y servidores que levanté terminaron con cada corrida (cada
  `t147_web.py` baja su servidor y cierra su Chrome; `t147_windows.py` cierra
  su proceso). No quedó nada escuchando.

## 14. El bloque de Git (lo ejecuta Carlos)

Desde esta carpeta, `C:\Proyectos\baystream-qa-r4`:

```powershell
git add -- docs/t147/entrega1/aceptacion-glm.md
git commit -m "Sprint 4: aceptacion de la entrega 1 de T-147"
git push origin HEAD:t147-piloto4
```

Solo entra mi informe: ningún archivo versionado cambió durante la aceptación
(lo que escribí fuera de `docs/` está en `build/t147/glm-e1/`, que es
evidencia fuera de Git, igual que en las aceptaciones anteriores).

## 15. En tres líneas

1. La entrega 1 de T-147 pasa: suite 2280 de 2280 y `analyze` en cero aquí y en
   copia limpia; rojas 3, 12 y 10 contra `37be8a5`; las cifras del caso, el
   corpus y la pantalla dicen lo que la 10.151 y el caso A09 mandan.
2. La hoja «Vacíos del listado» se dibuja en 237 a 261 ms con la CPU frenada
   cuatro veces donde la 1.0.1 tardaba 10.3 a 10.6 s en esta máquina, y ofrece
   lo mismo; el criterio de la entrega (menos de medio segundo frenado) se
   cumple en las tres corridas.
3. Sin hallazgos nuevos: lo que no cabe a 360 dp ya estaba en la evidencia de
   Timonel (le sumo los textos anotados a O-147-6), y las sondas de lo que
   nadie miró (matrícula repetida en pantalla, «NO» aislado, TBA, dígito mal,
   «NO» fuera de escala, listados sin POT, separadores, la fila de pendientes,
   el guardado entre versiones y el BAPLIE de salida) se comportan como dice el
   informe.

---

**Para Yov:**

> Yov: acepté la entrega 1 de T-147 (candidata 1.0.2+11, sobre `57497db` en
> `t147-piloto4`): **PASA, sin hallazgos nuevos**. Repetí la suite (2280 de
> 2280), los dos `analyze` (copia limpia y Dart versionado), las rojas (3, 12 y
> 10), las cifras del caso contra 5.1 (todas), el conteo de segmentos en
> `LOC+147` (709 · 271 · 408 · 0 `LOC+13`), el corpus antes/después (DISTINTO
> solo en los dos archivos del caso) y los tres recorridos del banco Web mirados
> captura por captura. La medición, con el mismo instrumento de Timonel: con la
> CPU frenada cuatro veces, la hoja se dibuja en 237.3, 246.5 y 260.8 ms (las
> tres por debajo del medio segundo; Timonel midió 160 a 198) donde la 1.0.1
> tardó 10 278 a 10 650 ms en esta máquina. La matrícula repetida se ve en
> pantalla como decía 3.3 (aviso, diálogo con las dos celdas, pieza única, la
> otra celda hueco no operable, y el resumen baja a 407/134); las sondas del
> lector, del listado, del guardado entre versiones y del BAPLIE de salida
> cuadran con el informe, incluido «datos distintos» en 17 y los mismos 23
> grupos al abrir la 1.0.1 lo que guardó la 1.0.2. A O-147-6 le sumo los textos
> recortados que anotó el conductor (rótulo de bahía, resumen de Carga y
> Descarga, el aviso de sin listado y «Celda donde quedó»): ya estaban en tus
> capturas. Mi informe es `docs/t147/entrega1/aceptacion-glm.md` y mi evidencia,
> `build/t147/glm-e1/`. Las copias limpias quedan en `%TEMP%\t147-glm\` sin
> nada del caso; las copias del caso y lo que salió de él, borradas.

## 16. Revisión del 20-nov

Yov comprobó el dictamen contra esta carpeta y no cambió: PASA, sin hallazgos
nuevos. Antes del commit, corregí el informe con lo que dicen mis archivos,
releídos en esta revisión. Una línea por cambio:

1. **La tabla de la medición (sección 6), «Web · tocar la celda»**: decía
   «40.1 · 40.1 · 42.0 ms» y dice «41.2 · 40.1 · 42.0 ms» — el `dibujada_ms`
   del paso «toque» en los `pasos.jsonl` de `medicion/glm-despues-medir-cpu1-1`,
   `-2` y `-3`.
2. **«Web · el teclado»**: decía «181.1 · 181.1 · 197.2 ms» y dice
   «183.2 · 181.1 · 197.2 ms» — los mismos tres `pasos.jsonl`.
3. **«Web · una tecla»**: decía «24.8 · 27.1 · 27.5 ms» (orden mal) y dice
   «27.1 · 27.5 · 24.8 ms» — los mismos tres `pasos.jsonl`, en el orden de las
   corridas. Corrección propia al releer.
4. **«Web, CPU ÷ 4 · el teclado»**: decía «1145.8 · 1145.8 · 1167.3 ms» y dice
   «1167.7 · 1145.8 · 1167.3 ms» — los `pasos.jsonl` de `glm-despues-medir-cpu4-1`,
   `-2` y `-3`.
5. **«Web, CPU ÷ 4 · una tecla»**: decía «160.6 · 161.2 · 166.6 ms» (orden mal)
   y dice «160.6 · 166.6 · 161.2 ms» — los mismos tres `pasos.jsonl`, en el
   orden de las corridas. Corrección propia al releer.
6. **La matrícula repetida (sección 8, G)**: decía que la matrícula repetida era
   `XKLU3034357` y dice `XJZU5616792` — el aviso `duplicate` del
   `pasos.jsonl` de `glm-matricula-repetida`: «XJZU5616792: 018-01-82 y
   018-00-82» (mi `plan_repetido.py` cambió el `EQD` de la celda 018-00-82,
   que traía `XKLU3034357`, por el de 018-01-82).
7. **La pieza y las celdas (G)**: decía «la pieza única no aparece como celda
   operable: tocar el hueco y tocar la pieza no abre nada» y dice: la pieza
   `C:XJZU5616792` se ve en la celda 018-00-82 con «— Sube», como cualquier
   carga pendiente (captura `glm-g-04`); el hueco es la celda 018-01-82
   (`cell-1-82`, registro «celdas_de_la_bahia»); la sonda solo tocó ese hueco
   (buscaba `loading-C:XKLU3034357` y `cell-0-82`, que no están en el árbol) y
   **al tocar la pieza queda sin mirar**.
8. **El peso de la bahía 18 (G)**: decía «el peso repetido se cuenta una vez»
   (una explicación que no comprobé) y ahora solo dice lo que se ve: la bahía
   muestra «9 contenedores, 73 celdas reservadas, 140.3 t» (captura `glm-g-04`
   y registro) frente a 148.2 t del plan (cifra del punto C): una diferencia de
   7.9 t sin causa comprobada.
9. **Las horas (sección 12)**: la tabla era estimada, en tramos redondos hasta
   las 14:35, y se rehízo con la fecha de modificación de cada registro y el
   campo `ts` (UTC−6) de cada `pasos.jsonl`; va de las 11:57:23 (primer
   registro, `analyze/despues-paquete.log`) a las 13:17:38 (la modificación de
   este informe), y dice qué tramos no dejaron archivo (las lecturas del paso 0
   y la mirada de las capturas).
10. **Lo que quedó en `%TEMP%` (secciones 11 y 13)**: decía que las copias
    limpias conservaban los bancos compilados y la entrada de T-124 dentro, y
    dice lo que hay listado a mano: las dos copias **sin carpeta `build/`** (la
    entrada de T-124 solo está en `build\t124\entradas\` de esta carpeta), mis
    seis sondas en `tool\` de `t147-glm-despues`, mis dos sondas y las
    herramientas de Timonel en `tool\` de `t147-glm-antes`, y cuatro archivos
    sueltos míos sin datos del caso.
11. **Otras cifras releídas sin cambio**: el toque con la CPU frenada (237.3 ·
    246.5 · 260.8 ms), la medición de Windows (59.3 · 115.2 · 66.9 ms, contra
    `windows/glm-w-medir/pasos.jsonl`) y las cifras del caso y del corpus. El
    dictamen, la tabla de los puntos y los hallazgos no cambian.
