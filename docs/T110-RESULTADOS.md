# T-110 · Bahías con evidencia del archivo y textos de lectura

Capitán Codex · 19-oct-2026 · Implementación, Windows y Web verificados.
Código de esta implementación sin commit; diagnóstico previo versionado en `1a1febf`.
Honor y aceptación de Timonel pendientes.

## Base y aislamiento

HEAD `246d577`: decisión 10.87. Debajo están `1a1febf` (diagnóstico),
`51c5e8e` (T-99 Fase A), y `d2095fe` (10.86). Se comprobó con Git de lectura.
La condición inicial de esperar el commit de T-99 quedó cumplida.

Piso antes de editar lib o test: **1016/1016**, código 0, sin omisiones;
`%TEMP%\baystream-t110-246d577\suite-head.txt`. Esa corrida se ejecutó en el
árbol de trabajo, todavía igual a HEAD en lib y test; no se presenta como una
corrida en la copia. No había trabajo paralelo de Timonel.

Para la referencia y las validaciones del cambio se creó otra copia:
`%TEMP%\baystream-t110-246d577\head`. `git archive --format=tar` de la revisión
exacta, extracción Python UTF-8 y **711 archivos verificados byte a byte**.
`head-manifest.json` conserva sus huellas. Se copiaron únicamente la
configuración de paquetes ya instalados y los metadatos de plugins, sin pub
get. Luego se superpusieron solo las rutas propias de T-110.

Antes del cambio se ejecutó allí `tool/t110_corpus_test.dart` con captura:
**10/10**, `corpus-head.txt`; referencia `corpus/baseline.json` en TEMP.
Los archivos se indicaron mediante `--dart-define=BAYSTREAM_CORPUS_DIRECTORY`.
No hay contenido del corpus en este repositorio.

## Diagnóstico previo, conservado como antecedente

El 18-oct se detuvo la ficha original, antes de editar código, porque exigía
todas las bahías del casco y el perfil no contiene ese inventario. Carlos
versionó el diagnóstico como `1a1febf`. `observedHoldBayNumbers` es una cota
inferior de bodega; las tapas tampoco enumeran todas las bahías. La geometría
contiene filas y niveles, no el inventario longitudinal.

Las dos rutas previas explican A07: el parser organizaba únicamente carga
propia y reservas; `withGeometry()` y `fromJson()` añadían las sombras físicas
de 40/45 en las impares vecinas. No salían de un inventario del perfil.

La decisión **10.87** resuelve la parada: T-110 cubre solo la evidencia del
archivo. Todas las bahías del buque quedan para después del cierre, con un
inventario declarado y el alcance de persistencia definido entonces.

## Implementación

`VesselVoyage.withFileBays()` es la transformación común utilizada por el
parser, la reconstrucción desde JSON/Recientes y la inyección de geometría.
El conjunto se obtiene de carga propia, reservas y sombras físicas de 40/45
en pares; se ordena por número. No consulta el perfil, las tapas ni las
observaciones de bodega y no rellena del uno al máximo.

Se conserva la proyección de dibujo de reservas largas de T-69 en las impares
vecinas: representa esa misma reserva, no carga física. No se cambió
`neighborOccupiedSlots()` ni la proyección de reservas. Las pruebas anteriores
del corpus y de T-69 permanecen sin editar y pasan.

Los atributos de las bahías históricas con evidencia se conservan. La
geometría solo se inyecta para dibujar: no determina la lista. No se modifican
codec, versión de esquema, toJson ni formato guardado. Estadísticas mantiene
su código: carga propia o sombra física; las bahías solo con reservas quedan
fuera de su cuenta.

Los textos de la tarjeta dicen «falta 1 segmento» o «faltan N segmentos».
Las conversiones LBR/TNE conservan el mismo valor double redondeado; solamente
el aviso usa `toStringAsFixed(0)` para mostrar kilos enteros en nativo y Web.

## Pruebas y validaciones

- Suite final: **1034/1034**, código 0, sin skip (1016 + 18 nuevas),
  `suite-final.txt` en TEMP.
- Corpus anterior: **157/157** de los mismos 36 instrumentos, sin editarlos.
  Más diez cotejos nuevos: **167/167**, código 0, `corpus-final.txt`.
- Los diez cotejos comparan huellas canónicas de todos los campos sin bahías,
  del viaje completo con geometría aplicada y del registro que escribe el codec.
  Solo se excluyen UUID; se conservan números de contenedor, posiciones, pesos,
  reservas, metadatos y avisos. Todo coincide con HEAD, salvo la lista en crudo.
  La suite del corpus comprueba también validaciones y órdenes de trabajo.
- Las 18 nuevas cubren 40/45 en tres códigos ISO, ambos caminos con/sin
  geometría/perfil, Recientes mediante repositorio local y notifier reales,
  una sombra sin carga propia, reservas fuera de Estadísticas, rejilla de
  cubierta y bodega, singular/plural y seis avisos de peso entero (WT/VGM/T,
  LBR/TNE). Los perfiles de prueba con observaciones/tapas de la 99 no añaden
  esa bahía al selector.
- La primera dirigida pasó 27/28 (18 nuevas + 10 corpus): la prueba de rejilla
  buscaba la clave exclusiva del arrastre. Se corrigió el instrumento para
  comprobar las celdas normales; la suite final pasa. Sin cambios a pruebas
  previas ni excepciones toleradas nuevas.

Analyze final: **0 incidencias**, código 0 (`analyze-final.txt`). La primera
corrida pidió llaves en cuatro if de los instrumentos nuevos; se corrigieron
sin alterar el producto y la segunda quedó en cero. Sin `// ignore:`.
Windows y Web comprobados como se detalla abajo.
No se ejecutan comandos Flutter en paralelo.

## Corpus: bahías añadidas al leer

A07 medido: **18 → 21 al leer**, con 27, 29 y 31 añadidas; **21 al reabrir**.
Coincide con la expectativa. Son sombras físicas, no bahías inventadas.
Los diez archivos ganan bahías al leerlos; al reabrir ya tenían esas listas.

| Archivo | Antes al leer | Ahora leer/reabrir | Ganancia | Bahías añadidas |
|---|---:|---:|---:|---|
| CORPUS_A01.edi | 27 | 34 | +7 | 005, 013, 015, 035, 039, 043, 045 |
| CORPUS_A02.edi | 20 | 30 | +10 | 017, 019, 025, 027, 029, 031, 037, 039, 041, 043 |
| CORPUS_A03.edi | 14 | 27 | +13 | 005, 007, 009, 011, 013, 015, 017, 019, 021, 023, 029, 031, 035 |
| CORPUS_A03v_VGM.edi | 14 | 27 | +13 | 005, 007, 009, 011, 013, 015, 017, 019, 021, 023, 029, 031, 035 |
| CORPUS_A04.edi | 27 | 34 | +7 | 001, 017, 019, 025, 027, 043, 045 |
| CORPUS_A05.edi | 21 | 27 | +6 | 001, 017, 019, 031, 033, 035 |
| CORPUS_A06.edi | 21 | 27 | +6 | 001, 017, 019, 031, 033, 035 |
| CORPUS_A07.edi | 18 | 21 | +3 | 027, 029, 031 |
| CORPUS_A08.edi | 21 | 24 | +3 | 021, 023, 031 |
| CORPUS_A08v_VGM.edi | 21 | 24 | +3 | 021, 023, 031 |

Evidencia: `corpus/baseline.json` y `corpus/results.json`, solo en TEMP.

## Clientes: banco local aislado

Banco `tool/t110_main.dart`: widgets reales del plano, resumen y Estadísticas;
selector de A07, Recientes por el notifier del producto, confirmación de perfil
local de ensayo y dos sintéticos para los avisos. Namespace t110. En Windows
exige una ruta TEMP explícita; Web usa IndexedDB de su origen local. Sin
inicialización Firebase, cuenta ni pantallas «Nube y cuenta».
La geometría del banco es una propuesta del archivo para este ensayo; no
pretende declarar un inventario del casco ni medir RNF.

### Windows

Compilación release: **código 0**, `build-windows.txt`, 55.2 s. Se copiaron el
ZIP y el SDK C++ 13.9.0 ya descargados a la caché propia de T-110, sin compartir
binarios de aplicación. MSBuild conserva el aviso MSB8029 de compilar en TEMP;
no es una incidencia de analyze.

Abierta con `Start-Process explorer.exe -ArgumentList <exe>`. PID **7788**,
con padre **explorer.exe** PID 12412 observado y registrado en
`windows-process.json`. Se comprobó la ruta del ejecutable y se cerró por
ese mismo PID; `windows-close.json`. Una sola BayStream durante el ensayo.

Almacén exacto:
`C:\Users\Giova\AppData\Local\Temp\baystream-t110-246d577\store-t110`.
Cajas `t110_profiles`, `t110_settings`, `t110_voyages`; `windows-store.json`.
No se usó el almacén real ni el del paquete.

Comprobaciones con la interfaz:

- A07: **21 bahías y 398 contenedores al leer**, y la misma lista desde
  Recientes sin perfil guardado. Se confirmó un perfil de ensayo y se reabrió
  de nuevo: **21 y 398**, misma lista ordenada.
- Se eligió la **27**, que trae cero contenedores propios: aparece con su
  rejilla de cubierta/bodega y las marcas físicas de 40 de la vecina.
- Sintético: selector con **1, 2, 3 y 11**; la 11 solo tiene una reserva.
  Estadísticas muestra **3 bahías ocupadas**, un contenedor, sin contar la 11.
- Resumen: **«falta 1 segmento (UNZ)»**, **«faltan 2 segmentos (UNT, UNZ)»**.
  Detalles: **10886 kg** desde LBR y **23457 kg** desde TNE, sin «.0».

Capturas TEMP: `windows-a07-read.png`, `windows-a07-recent-no-profile.png`,
`windows-a07-recent-profile.png`, `windows-a07-shadow27.png`,
`windows-synthetic-grid.png`, `windows-reservation-stats.png`,
`windows-missing-one.png`, `windows-missing-two.png`,
`windows-lbr-integer.png`, `windows-tne-integer.png`.
SHA-256 EXE: `a7f2051d8d2891cf07eec56299cf8bf8774eeb6c040329216d56f6c5d1d6bf79`.
SHA-256 app.so: `6a6c56e18bb63234f7368b46539a27b5fc8db178baf7e41a6e8f5dc2638fb5fe`.
`windows-binaries.json`.

### Web

Compilación release: **código 0**, `build-web.txt`, 32.3 s, con `--no-pub`
y `--no-wasm-dry-run`. Conserva la advertencia de fuente Cupertino ausente
ya observada en las tareas previas; no se cambian dependencias ni pubspec.

Servida solo en **http://127.0.0.1:8820/**, Chrome visible, namespace **t110**
en IndexedDB de ese origen. A07 se abrió mediante el selector documentado
de archivos de Chrome. Se comprobó **21 al leer y al reabrir desde Recientes**,
primero sin perfil guardado y después de confirmar el perfil local de ensayo.
En ambos casos, **398 contenedores** y la misma lista de números.

El sintético vuelve a mostrar **4 bahías en el selector y 3 ocupadas** en
Estadísticas; se comprobaron singular/plural y los detalles **10886 kg** y
**23457 kg**, idénticos a Windows. Capturas TEMP: `web-a07-read.png`,
`web-a07-recent-no-profile.png`, `web-a07-recent-profile.png`,
`web-reservation-stats.png`, `web-missing-one.png`, `web-missing-two.png`,
`web-lbr-integer.png`, `web-tne-integer.png`.

Se cerró la pestaña propia y el servidor propio por PID **19724**;
`web-close.json`. No hubo publicación, Firebase, cuentas ni lecturas remotas.
Ninguna captura incluye «Nube y cuenta» o datos de acceso.

### Pendientes y límites

Honor pendiente para la ronda indicada por Carlos; **no se utilizó**. No se
compiló Android ni se afirma una comprobación de ese dispositivo. El formateo
de kilos está en la función común y pasa en VM y en la Web; falta la ronda
permitida del Honor. Aceptación de Timonel pendiente.

Los clientes se comprobaron con el banco aislado y los widgets/notifier del
producto; no es un recorrido integral del binario real ni una medición RNF.
No se tocaron demo17, PRUEBA T-105, almacén real ni documentos ajenos.
`pubspec.yaml` y `pubspec.lock` sin cambios de Codex. Sin Git de escritura.
Las seis rutas de fuentes probadas y del árbol coinciden byte a byte
(`source-manifest.json`). Main, congelados, pubspec y codec coinciden con HEAD
normalizando los CRLF de Git en el árbol; en la copia son byte-idénticos.

## Archivos exactos

Modificados:

- `lib/features/vessel/domain/entities/vessel_voyage.dart`
- `lib/features/vessel/data/services/baplie_parser_service.dart`
- `lib/features/vessel/presentation/widgets/voyage_summary_card.dart`
- `docs/T110-RESULTADOS.md`

Nuevos:

- `test/t110_bays_test.dart`
- `tool/t110_corpus_test.dart`
- `tool/t110_main.dart`

## Git para Carlos

Este bloque sustituye el bloque del diagnóstico anterior. Versiona únicamente
T-110; Carlos realiza Git. Ninguna ruta necesita `-f`.

```powershell
git add -- lib/features/vessel/domain/entities/vessel_voyage.dart
git add -- lib/features/vessel/data/services/baplie_parser_service.dart
git add -- lib/features/vessel/presentation/widgets/voyage_summary_card.dart
git add -- test/t110_bays_test.dart
git add -- tool/t110_corpus_test.dart
git add -- tool/t110_main.dart
git add -- docs/T110-RESULTADOS.md
git commit -m "Sprint 3: Unifica bahias con evidencia y corrige avisos en T-110"
git push
```

## Tres líneas para Carlos

A07 da 21 bahías al leer y reabrir, con o sin perfil; una sola regla desde la evidencia.
Reservas fuera de Estadísticas; avisos en singular/plural y kilos enteros, sin cambiar el codec.
Suite 1034/1034, analyze cero y corpus 157/157 + 10 cotejos; Windows/Web verificados, Honor pendiente.

## Mensaje para Yov

T-110 implementada según 10.87, sobre 246d577, sin commit de código.
Una sola función reconstruye bahías al leer, reabrir y aplicar geometría; no usa el perfil como inventario.
A07 medido: 18→21 al leer, añade 27/29/31; al reabrir sigue en 21, con o sin perfil guardado.
Las reservas no cuentan como ocupación; se conserva la proyección de dibujo de T-69 y el contrato de Estadísticas.
Textos corregidos: falta 1/faltan N segmentos y kilos enteros idénticos en Windows y Chrome.
Suite 1034/1034, analyze cero y corpus 157/157 más diez cotejos: datos y formato guardado iguales a HEAD.
Windows por Explorer, namespace t110 en TEMP, cerrado por PID; Chrome local t110 y servidor también cerrados.
Honor y aceptación pendientes; diagnóstico y tabla por archivo en docs/T110-RESULTADOS.md; sin codec, pubspec ni Firebase.
