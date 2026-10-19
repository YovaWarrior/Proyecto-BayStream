# T-110 · Aceptación cruzada de las bahías con evidencia del archivo y los dos textos de T-108 — resultados (Timonel)

**Dictamen: ACEPTADA, con observaciones.** El código de `8d1bbb8` cumple la regla de 10.87 y lo que Yov aceptó en 10.88, y pasan todos los criterios de «Terminada cuando». No encontré ningún defecto de T-110 en `lib/`. Las observaciones están en la sección 8: una es consecuencia menor del cambio de texto (viajes guardados antes conservan su «.0»), las demás son anteriores a T-110. **El Honor también pasa**: está en `docs/HONOR-19OCT-RESULTADOS.md`.

Timonel (Claude Code), 19-oct-2026, solo y con los permisos de 10.88. Sin Firebase, sin cuentas, sin git de escritura y sin tocar `lib/`.

## 1. Base y copias

- **`git log --oneline -3`:** `9728900` (decisión 10.88), `8d1bbb8` (T-110) y `246d577` (10.87). Rama `sprint-3`.
- **HEAD solo agrega documentos sobre T-110:** `git diff --stat 8d1bbb8 9728900` toca `SPRINT-3.md` y el tablero, nada más. El árbol coincide con HEAD en `lib/`, `test/`, `tool/` y `pubspec.*`.
- **Tres copias limpias**, todas con `git archive --format=tar` y extraídas con Python (`tarfile`, UTF-8), verificadas byte a byte con su manifiesto SHA-256:

| Copia | Commit | Archivos | Uso |
|---|---|---:|---|
| `%TEMP%\baystream-t110acc-9728900\head` | `9728900` (HEAD) | 714, 0 distintos | suite, analyze, corpus, mi cotejo, Windows y Web |
| `%TEMP%\baystream-t110acc-9728900\base` | `246d577` (padre de T-110) | 711, 0 distintos | mis referencias del «antes» |
| `%TEMP%\baystream-honor19-8d1bbb8\app` | `8d1bbb8` | 714, 0 distintos | la app del Honor |

- La copia de HEAD y la de `8d1bbb8` solo difieren en `SPRINT-3.md` y el tablero: el código es el mismo.
- `pubspec.yaml` y `pubspec.lock` son iguales en las tres (normalizando CRLF). Reutilicé `package_config.json`, `package_graph.json` y `.flutter-plugins-dependencies` del árbol, sin `pub get`, salvo en la copia del Honor (Android va sin `--no-pub`, 10.86).

## 2. El diff (`246d577..8d1bbb8`, 3 archivos de `lib/`)

**Una sola regla al leer, al reabrir y con la geometría.** `VesselVoyage.withFileBays()` (`vessel_voyage.dart:135`) arma la lista con cuatro fuentes y la ordena por número:
- la carga propia (`_baysFromContainers`);
- las reservas;
- la proyección de dibujo de las reservas largas (`neighborReservedSlots`, de T-69);
- las sombras físicas de los 40/45 en las pares (`neighborOccupiedSlots`).

La llaman los tres caminos: el lector (`baplie_parser_service.dart:74`, que ya no tiene `_organizeBays`), `fromJson` (`vessel_voyage.dart:433`) y `withGeometry` (`:155`), que ahora solo inyecta la geometría y vuelve a llamar a la misma función.

**El perfil no se usa como inventario.** `withFileBays` no lee el perfil, ni `observedHoldBayNumbers`, ni `hatchCovers`, y no numera del 1 al máximo. La geometría solo se inyecta para dibujar; no decide la lista.

**El codec, `toJson` y lo guardado no cambian.**
- `toJson` y `local_vessel_codec.dart` no están en el diff. El almacén local guarda sin bahías (`toJson(includeBays: false)`), así que su registro es el mismo (sección 4).
- El único que guarda `bays` en Firestore es `VesselRepositoryImpl.saveVoyage`, y solo lo llama la pantalla congelada de C3, que arma su viaje sin pasar por `withFileBays` y solo lee `containers`. No cambia.
- El orden del mapa pasa a ser numérico; los consumidores que iteran sin ordenar solo suman, y la igualdad de `Equatable` no depende del orden.

**Los textos.** `voyage_summary_card.dart:305` da «falta 1 segmento» con uno y «faltan N segmentos» con más. En `_parseMEA` solo cambia el texto del aviso (`toStringAsFixed(0)`): la conversión `(peso × factor).roundToDouble()` queda igual.

**Una precisión sobre el «18 al leer» de 10.85.** En el padre, el producto ya publicaba A07 con 21: `_publish` aplica `withGeometry`, que sumaba las sombras (padre, `vessel_providers.dart:313`; mi referencia del padre da 18 al leer, 21 con geometría y 21 al reabrir). El 18 lo vi en mi banco de T-108, que mostraba la lectura cruda del lector. T-110 hace que la lectura cruda también dé 21: la regla queda una sola en todos los caminos, y en el flujo del producto A07 sigue en 21.

## 3. Suite, analyze y corpus (copia de HEAD)

| Validación | Resultado | Registro en `%TEMP%\baystream-t110acc-9728900\logs\` |
|---|---|---|
| F1 · suite completa, A07 por `--dart-define` | **1034/1034**, código 0, 75 s, **0 omitidas** | `f1-suite.txt` |
| F2 · `flutter analyze --no-pub` | **0 incidencias** | `f2-analyze.txt` |
| F6 · `analyze` con mis dos archivos Dart de `tool/` | **0 incidencias** | `f6-analyze-con-instrumentos.txt` |
| `// ignore` y `skip:` en `lib/`, `test/` y `tool/` | **0 y 0** | — |
| F4 · corpus: los 36 instrumentos + `t110_corpus_test` | **167/167** (157 + 10), código 0, sin omitidas | `f4-corpus-head.txt` |
| F5 · batería de T-98 (`T98_BASE=9728900`) | 13 negativos «avisa», 5 rechazos, 10 positivos en silencio | `f5-t98.txt`, `t98\conformidad.md` |

- **La referencia de los 10 cotejos de Codex la capturé yo, en el padre:** `t110_corpus_test.dart` con `T110_CAPTURE=true` sobre la copia de `246d577` (10/10). En HEAD, los 10 cotejos pasan contra esa referencia y dan la misma tabla de Codex.
- **La batería de T-98 ya dice el singular:** «Archivo posiblemente incompleto: falta 1 segmento (UNB)», y lo mismo con BGM, UNT y UNZ.
- `t108_corpus_test` y la batería de T-98 no entran en las 157, como en la cuenta de Codex.

## 4. Mis dos cotejos

### 4.1 El cotejo crudo (`tool/t110acc_cotejo_crudo.py`)

Lee cada EDI **sin pasar por el lector de BayStream** y reconstruye de dónde sale cada bahía: carga propia, reservas, sombra de los 40/45 en pares y proyección de reservas largas. El tamaño sale del primer carácter del tipo ISO 6346. Salida: `cotejo\crudo.json`.

**Da exactamente la tabla de Codex en los 10 archivos** (A01 27→34, A02 20→30, A03 14→27, A03v 14→27, A04 27→34, A05 21→27, A06 21→27, A07 18→21, A08 21→24, A08v 21→24). **Ninguna bahía agregada queda sin explicar, y todas son sombras físicas**; ninguna sale solo de una reserva.

**A07, bahía por bahía:**

| Bahía agregada | Sale de | Largos que la ocupan |
|---|---|---:|
| 027 | la 026 | 13 |
| 029 | la 030 | 29 |
| 031 | la 030 | 29 |

La 028 no trae carga, así que la 027 solo tiene sombra de la 026.

**A03, la que más gana (+13):** 005 y 007 de la 006 (20 largos); 009 y 011 de la 010 (25); 013 y 015 de la 014 (63); 017 y 019 de la 018 (66); 021 y 023 de la 022 (33); 029 y 031 de la 030 (7), y 035 de la 034 (24). Las otras vecinas de esas pares ya tenían carga propia.

**A08:** la 027 tiene reservas y no tiene carga propia, pero también es sombra de una par vecina, así que cuenta como ocupada. Por eso Estadísticas da 24 con 24 bahías en el selector.

### 4.2 El cotejo con el lector y el codec reales (`tool/t110acc_corpus_test.dart`)

Corre igual en el padre y en HEAD. En el padre escribe la referencia (`cotejo\dart\baseline.json`); en HEAD compara. Cubre los 10 archivos del corpus y tres sintéticos míos (ACC1, el de la aceptación de T-108; ACC2 y ACC3, abajo). **Pasa en HEAD (1/1).**

**Lo que exige:**
- **una sola lista:** al leer, al reabrir por el codec, con geometría, al reabrir lo publicado y al reabrir con el perfil, la misma;
- **igual que en el padre:** contenedores, reservas, la lista al reabrir y con geometría, las bahías ocupadas de Estadísticas (publicado y reabierto, leídas del `voyageStatsProvider` real), el registro local sin avisos, el registro publicado sin avisos, la exportación sin bahías ni avisos, los pesos de cada contenedor y el peso total;
- **los avisos:** los mismos tipos y detalles, y solo cambia «N.0 kg» por «N kg».

**Lo que sale:**
- **El registro del almacén local es idéntico al del padre** en los 10 archivos y en ACC2 y ACC3. En ACC1 solo cambia el texto de los dos avisos de peso.
- **Estadísticas no cambia en lo publicado.** Lo que cambia es la cuenta sobre la lectura cruda, antes de la geometría (A07 18→21, A08 20→24), porque ahora la lectura cruda ya trae las sombras. La fórmula de `vessel_providers.dart:632` no cambió, y en el producto el usuario solo ve el viaje publicado.

### 4.3 Lo que aceptó Yov en 10.88: la reserva de 40

ACC2 trae un 20 en la 1, un 40 (`45G1`) en la 4 y **una reserva de 40 (`45G1`) en la 10, sin carga en la 9, la 10 ni la 11**. Le falta solo UNZ.

| | Padre al leer | Padre con geometría | HEAD (leer, reabrir y con geometría) |
|---|---|---|---|
| Selector | 1, 4, 10 | 1, 3, 4, 5, 9, 10, 11 | 1, 3, 4, 5, 9, 10, 11 |
| Bahías ocupadas (Estadísticas) | 2 | 4 | **4** (1, 3, 4 y 5) |

- **La reserva de 40 trae sus impares vecinas, 9 y 11, y Estadísticas no las cuenta.** Confirma lo que dice 10.88, y también que «ya pasaba antes» con la geometría (`_addReservedBays`).
- En el plano, la 9 dibuja la reserva proyectada («40' reserva 45G1») con 0 % de ocupación (`win-acc2-bahia09-reserva-proyectada.jpg`).

### 4.4 LBR y TNE: mismo valor, otro texto

En ACC1, mi cotejo exige los pesos iguales al padre, y lo son: TSTU0000020 queda con VGM 23 457.0 kg (TNE 23.4567) y CSQU3054388 con bruto 24 000.0 kg (LBR 52 910). Solo cambia el texto del aviso:
- **en el padre (VM):** «VGM en TNE convertido a 23457.0 kg» y «WT en LBR convertido a 24000.0 kg»;
- **en HEAD:** «… 23457 kg» y «… 24000 kg».

## 5. Windows, con el namespace `t110acc`

**El banco** es mío y vive solo en TEMP: `%TEMP%\baystream-t110acc-9728900\t110acc_main.dart.banco`, con copia en `evidencia\t110acc_main.dart` (SHA-256 `09bd6e78…39f4e5`). No va al repo porque la Web lee A07 con `package:http`, que es transitiva y el analizador la marcaría.
- Monta los widgets reales (`BayPlanView`, `VoyageSummaryCard` y `VoyageStatsView`) con el `VoyageNotifier` real y Recientes por `openRecentVoyage`.
- No usa Firebase ni cuentas. El almacén es `store-t110acc`, en TEMP, y tiene solo cajas `t110acc_*`.
- «Sin perfil» guarda el viaje con la geometría propuesta y sin perfil. «Con perfil» guarda el perfil propuesto con origen «declarado por el usuario», como `confirmGeometry`, y publica con su geometría.

**Compilación y procesos:**
- Release, código 0 (61 s y, la segunda, 30 s). El exe se copió como `baystream_t110acc.exe`, con SHA-256 `cb9cbb31…bffc7`.
- Abierto con `Start-Process explorer.exe` y cerrado por PID con `CloseMainWindow`: PID 16420 (padre `explorer.exe` 16352) y PID 18656 (padre `explorer.exe` 11504). No se abrió el almacén real ni el del paquete.
- **La primera versión del banco falló al leer «con perfil»** («Bad state: …error inesperado»): usaba `parseBaplieContent` del notifier, y `VesselRepositoryImpl` toma `FirebaseFirestore.instance` al construirse (observación 8.4). La corregí para guardar el perfil por el repositorio y recompilé. La captura del error queda como evidencia.

| Comprobación | Resultado | Captura (`evidencia\`) |
|---|---|---|
| A07 sin perfil | lectura del archivo **21**, guardado 21, 398 contenedores | — |
| Reabierto desde Recientes, **sin perfil** | **21** bahías, la misma lista (1, 2, 3, 9, 10, 11, 13, 14, 15, 17, 18, 19, 21, 22, 23, 25, 26, 27, 29, 30, 31) | `win-a07-recientes-sin-perfil.jpg` |
| La 27 | 0 contenedores, rejilla de cubierta (90–80) y bodega (10–02), y **13 marcas «40'»** en bodega (4 + 4 + 3 + 2), las 13 de la 026 | `win-a07-bahia27-rejilla.jpg`, `win-a07-bahia27-bodega-13-marcas.jpg` |
| A07 con perfil | lectura 21, guardado 21 y **reabierto con perfil 21**, la misma lista | `win-a07-con-perfil-y-recientes.jpg` |
| El viaje guardado sin clave de perfil, otra vez | reabre con perfil, porque lo encuentra por identidad: 21 | `win-a07-viaje-sin-clave-reabierto-con-perfil.jpg` |
| Estadísticas de A07 | **21 ocupadas**, 398, 6940.6 t, 290/108 y 12 reefers, lo mismo que en la aceptación de T-109 | `win-a07-estadisticas-21-ocupadas.jpg` |
| ACC2 | selector 1, 3, 4, 5, 9, 10, 11; **4 ocupadas** | `win-acc2-estadisticas-4-ocupadas.jpg` |
| ACC1 | las cuatro líneas, con «faltan 2 segmentos (UNB, BGM)»; detalle «**23457 kg**» y «**24000 kg**» | `win-acc1-detalle-pesos-kg-enteros.jpg` |
| ACC2 | «**falta 1 segmento (UNZ)**» | `win-acc2-falta-1-segmento.jpg` |

## 6. La Web, con `t110acc`

- Compilación release con `--pwa-strategy=none` y `--no-wasm-dry-run`: código 0, 33 s.
- Servida solo en `http://127.0.0.1:8830/`, desde `%TEMP%\…\serve`, con A07 en `acc/` dentro de esa carpeta. El servidor (PID 24908) se detuvo y el puerto quedó libre.

**En Chrome (Claude in Chrome),** con la pestaña propia visible (`visibilityState=visible`):
- A07 sin perfil: lectura 21 y guardado 21. Reabierto desde Recientes sin perfil: **21**, la misma lista (`chrome-a07-recientes-sin-perfil.jpg`).
- La 27: 0 contenedores, la rejilla y las marcas «40'» (`chrome-a07-bahia27-rejilla.jpg`).
- A07 con perfil: lectura 21, guardado 21 y reabierto con perfil 21.
- ACC2: «4 Bahías Ocupadas» y el perfil longitudinal con sus 7 bahías (001, 003, 004, 005, 009, 010, 011).
- ACC1: las cuatro líneas, con «faltan 2 segmentos (UNB, BGM)».
- ACC2: «falta 1 segmento (UNZ)».

**La captura de Chrome se colgó** (`Page.captureScreenshot` sin respuesta en 30 s) después de cada operación pesada, aunque la página seguía viva (`requestAnimationFrame` respondía).
- Esas lecturas las hice en el árbol de semántica de Flutter, como en T-108.
- Pedí ver Chrome con el control del escritorio y **el acceso fue denegado**; no insistí.

**El detalle de pesos en la Web lo vi en mi navegador integrado** (se declara, como en 10.55): «**23457 kg**» y «**24000 kg**», iguales a Windows (`integrado-acc1-detalle-pesos-kg-enteros.jpg`). La pestaña de Chrome y la del navegador integrado se cerraron.

## 7. Los criterios de «Terminada cuando» (10.87)

| Criterio | Resultado |
|---|---|
| A07 da el mismo número al leer y al reabrir; se espera 21 | **PASA**: 21 en mi cotejo (todos los caminos), en Windows, en Chrome y en el Honor |
| Pruebas en `test/t110_*` | **PASA**: `t110_bays_test.dart` da 18/18 corrido solo (`f7-t110-bays.txt`) y dentro de la suite (1034/1034). Cubren los dos caminos con y sin perfil, la sombra sin carga, la reserva fuera de Estadísticas, la rejilla y los dos textos |
| Los dos textos: «falta 1 segmento» / «faltan N segmentos», y los kilos enteros iguales en las tres plataformas | **PASA**: Windows, la Web y el Honor muestran «23457 kg» y «24000 kg» |
| El corpus 157/157, idéntico salvo la lista; qué archivos ganan bahías | **PASA**: 167/167 con mi referencia, y mis dos cotejos dan la misma tabla |
| Validaciones: piso 1016 + nuevas, sin *skip*; `analyze` en cero, sin `// ignore:` | **PASA**: 1034, 0 omitidas, 0 incidencias y 0 `ignore` |
| Windows y la Web; el Honor | **PASA**, el Honor en su informe |

## 8. Observaciones (ninguna impide aceptar)

1. **Un viaje guardado antes de T-110 en Windows o Android conserva su «.0».** El texto del aviso se guarda tal cual en el registro local (`readNotices` → `details` → `text`, `vessel_voyage.dart:549–569`). Un viaje con LBR o TNE guardado con el binario anterior reabre con «23457.0 kg» hasta que se vuelva a leer el archivo. Es una inferencia del código, no lo reproduje con un binario del padre. El corpus no trae LBR ni TNE: solo pasa con sintéticos.
2. **«1 celdas reservadas».** `voyage_summary_card.dart:161–162` escribe «N contenedores · N celdas reservadas» sin singular. Se ve en ACC2, en Windows y en el Honor. Viene de T-69 (`8a87219`), no de T-110. Es el mismo tipo de arreglo que «faltan 1 segmentos»: `operationCount` ya existe y lo usa `bay_plan_view.dart:735`.
3. **«Bahías» de la tarjeta y de Recientes ya no es «ocupadas».** Ahora cuentan también las bahías de solo reservas y su proyección: ACC2 da 7 en la tarjeta y 4 ocupadas en Estadísticas. Es el contrato de 10.87 («`bays.length` incluye reservas»). En A07 las dos dan 21.
4. **El lector del producto pide Firebase inicializado** aunque no use la nube. `VesselRepositoryImpl` evalúa `FirebaseFirestore.instance` en su constructor (`vessel_repository_impl.dart:19`), y `parseBaplieContent` lo usa para leer. El comentario de `operation_sync_factory.dart:13–15` dice que sin Firebase la app sigue en un solo dispositivo; para leer archivos no es así. `lib/main.dart` lo evita, porque sin opciones no arranca. Solo afecta a bancos y pruebas. No es de T-110.
5. **`tool/t108_corpus_test.dart` necesita una referencia nueva.** Compara la huella de `toJson()`, que incluye las bahías, contra una referencia capturada en su padre. Una referencia capturada antes de T-110 ya no coincide al leer, así que quien corra `tool/` completo (T-98 Fase B) tiene que capturarla otra vez sobre el padre que corresponda. Lo mismo vale para mi `t110acc_corpus_test` y para `t110_corpus_test`.

## 9. Evidencia

Todo en `%TEMP%\baystream-t110acc-9728900\`, fuera del repositorio:
- `head-manifest.json` y `base-manifest.json`;
- `logs\`, con las corridas F1 a F7 y las compilaciones;
- `corpus110\`, con mi referencia del padre y los resultados de los 10 cotejos;
- `cotejo\crudo.json`, y en `cotejo\dart\` la referencia, `head.json`, `resumen.txt` y los tres sintéticos en `.edi`;
- `t98\`;
- `evidencia\`, con 14 capturas y la fuente del banco;
- `store-t110acc\`, con solo cajas `t110acc_*`.

## 10. Archivos de esta aceptación

**Nuevos:**
- `docs/T110-ACEPTACION-RESULTADOS.md` (este informe)
- `tool/t110acc_corpus_test.dart`: mi cotejo con el lector y el codec reales. Se corre con `BAYSTREAM_CORPUS_DIRECTORY`, `T110ACC_OUTPUT` (en TEMP) y, en el padre, `T110ACC_CAPTURE_BASELINE=true`.
- `tool/t110acc_cotejo_crudo.py`: el cotejo crudo, sin el lector.

No cambia `lib/`, `test/`, `pubspec.yaml` ni `pubspec.lock`. Sin dependencias nuevas.
