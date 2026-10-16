# T-96 · Comparar la llegada con la salida

Timonel · 15-oct-2026 · Base `32a1a94` (T-56 con la corrección de 10.57), rama `sprint-3`. HEAD no cambió durante la tarea.
La acepta Codex (10.58).

Trabajé en una copia en `%TEMP%\baystream-t96` y coloqué los archivos al final. Antes de colocarlos comprobé que `vessel_overview_page.dart` y `departure_baplie_page.dart` seguían iguales a la base: `git diff --stat 32a1a94 HEAD` vacío, y los mismos SHA (`AC0423A4…` y `F945A622…`).

## 1. El cambio

**El servicio:** `domain/services/voyage_comparison.dart`, puro y sin Flutter. `VoyageComparison.compare(primero, segundo)` clasifica por número de contenedor:
- **descargados:** solo en el primero;
- **cargados:** solo en el segundo;
- **permanentes:** en los dos, ordenados por número, con la lista de campos que cambian (`FieldChange`, con su antes y su después):
  - posición, ISO, lleno o vacío, POL, POD, línea, peso, peligrosas y temperatura;
  - **el peso es `effectiveWeight`** (T-66): el VGM si lo hay, si no el WT;
  - **las peligrosas** son los números ONU y las clases, ordenados, así que el orden de los DGS no cuenta;
  - **un campo que falta en uno de los dos** cuenta como cambio y se muestra «sin dato». `ContainerStatus.unknown` también es «sin dato».
- **Las reservas** no tienen número: se cuentan aparte, en cada archivo.
- **Un número repetido dentro de un archivo** no se clasifica y se reporta con su cuenta. Si está repetido en el otro archivo, tampoco se clasifica en este.
- **Distinto buque:** si `VesselIdentity` no coincide, se compara igual, con el aviso «No parece el mismo buque: … (clave) y … (clave).»
- **Es simétrica:** B contra A intercambia descargados y cargados, con los mismos cambios invertidos.

**La pantalla:** `presentation/pages/voyage_comparison_page.dart`.
- **Arriba:**
  - los avisos: distinto buque, y la 1.5 de T-103 si alguno de los dos se leyó con las reglas de 2.x;
  - los dos archivos, con su rótulo;
  - las cuentas en singular y plural, por ejemplo «114 descargados · 121 cargados · 284 permanentes, 262 con cambios»;
  - las reservas aparte, los repetidos si los hay y el resumen por campo («Cambios en los permanentes: POL 127 · POD 189 · Línea 58 · Peso 113»).
- **Tres pestañas fijas,** cada una con color, ícono y rótulo con su cuenta: ↓ Descargados, ↑ Cargados y ⇄ Permanentes (RNF-003, el color nunca va solo). Se desplazan, y su alto sigue la letra del dispositivo.
- **Listas perezosas** (`ListView.builder`).
- **En los permanentes:**
  - el filtro «Solo con cambios», encendido por omisión;
  - cada campo cambiado como «antes → después», por ejemplo «Peso 24 260 → 24 200 kg»;
  - el WT y el VGM de cada lado cuando difieren.
- **Las cifras** llevan espacios que no parten, para que a letra 2.0 «kg» no quede solo en una línea.

**Las dos entradas:**
- **«Comparar con otro BAPLIE…»,** en la fila de acciones del viaje abierto, junto a «Generar BAPLIE de salida» y «Alertas de estiba».
  - Elige el archivo con el mismo selector (`FilePicker`, por un proveedor que el banco puede sustituir) y lo lee con `VesselRepository.parseBaplieFile`, **sin pasar por `parseBaplieContent`**.
  - No confirma identidad ni perfil, no publica, no entra a Recientes y no guarda ni sube.
  - Un archivo que no es BAPLIE da el mensaje de siempre, «Archivo «…»: …», y no abre la comparación.
  - **Por qué ahí y no en la barra superior:** la tira desplazable de T-91 tiene su lista de acciones fijada en `test/support/t91_toolbar_support.dart`, que está fuera del carril. La fila de acciones del viaje es la otra «barra» y está a la vista. **Yov decide si la quiere arriba;** moverla es un cambio de una línea más esa lista.
- **«Comparar con la llegada»,** en la salida de T-82 (`departure_baplie_page.dart`).
  - Relee en memoria el texto generado y la fuente `arrival_baplie` de la operación, los dos con el mismo lector, y compara llegada contra salida. **No guarda la salida.**
  - Si la operación no tiene plano de llegada, lo dice y no ofrece comparar.
  - **El escritor de T-82 no se tocó:** mismo SHA, `05EE9198…`.

**La observación de 10.20 queda resuelta:** el detalle del plano de llegada sigue mostrando la llegada (0020310: 24 260 kg), y la diferencia con el plan se ve en la comparación.

## 2. Las cifras del caso

`tool/t96_corpus_test.dart` (6 pruebas):

| Comparación | Descargados | Cargados | Permanentes | Con cambios | Reservas (1.º / 2.º) | POL | POD | Línea | Peso | Posición · ISO · lleno/vacío · peligrosas · temperatura |
|---|---:|---:|---:|---:|---|---:|---:|---:|---:|---|
| **A07 → A08** | **114** | **121** | **284** | 262 | 0 / **55** | **127** | **189** | **58** | **113** | 0 · 0 · 0 · 0 · 0 |
| **A08 → A07** | 121 | 114 | 284 | 262 | 55 / 0 | 127 | 189 | 58 | 113 | 0 |
| **A07 → A08v_VGM** | 114 | 121 | 284 | 262 | 0 / 55 | 127 | 189 | 58 | 113 | 0 |
| **A07 → salida de los 177 eventos** | **114** | **176** | **284** | 262 | 0 / 0 | 127 | 189 | 58 | 113 | 0 |
| A08 → A08v_VGM | 0 | 0 | 405 | 0 | 55 / 55 | 0 | 0 | 0 | 0 | 0 |
| A05 → A06 | 736 | 717 | 0 | 0 | 0 / 0 | — | — | — | — | — |

- **El peso efectivo da 113,** como en 10.20. El ejemplo: XSPU8166070, en 0020310, **24 260 → 24 200 kg**.
- **A08 → A07** es la misma comparación intercambiada, contenedor por contenedor y campo por campo, con cada antes y después invertidos.
- **El VGM de A08v:** sus 405 contenedores traen VGM y ningún WT. Cada VGM es igual al WT de A08, así que el peso efectivo no cambia en ninguno (0 diferencias) y la clasificación contra A07 es idéntica.
- **La operación de 177 eventos** se arma como en `tool/t82_corpus_test.dart`, con las 114 descargas y los 177 eventos.
  - **Por origen,** los 176 cargados son los 121 números del plan más las 55 celdas reservadas. Es la forma de la ficha: «121 llenos y 55 vacíos asignados».
  - **Por su estado,** son **120 llenos y 56 vacíos**, como en los eventos del caso (`SPRINT-3.md`, 2.4: «120 llenos, 56 vacíos asignados»). Un contenedor del plan con número sube vacío. La prueba afirma las dos cuentas.
- **Un archivo consigo mismo** (A07, A08 y A01): 0, 0, todos permanentes y sin cambios.
- **A05 → A06**, sin cifra esperada: 736 descargados, 717 cargados y 0 permanentes. Los dos viajes de BUQUE ECO no comparten ni un número.
  - Sale el aviso «No parece el mismo buque: BUQUE ECO (callSign:ZZC5603) y BUQUE ECO (imo:9000039).», porque sus claves son distintas, como ya vio T-55.
  - El aviso de la 1.5 de A06 se ve en la pantalla: lo prueba el widget.

## 3. Las pruebas

**18 nuevas:**
- `test/t96_voyage_comparison_test.dart` (9): la clasificación, cada uno de los nueve campos de cambio con su antes y después, el peso efectivo (VGM sobre WT), el «sin dato», las peligrosas sin orden, las reservas aparte, los repetidos, el distinto buque y la simetría.
- `test/t96_comparison_page_test.dart` (9):
  - las cuentas, las reservas, el resumen por campo, «Peso 24 260 → 24 200 kg» y la línea WT/VGM;
  - las pestañas con ícono y rótulo;
  - el filtro;
  - el aviso de distinto buque y el de la 1.5;
  - 360 dp con la escala real del Honor (la tabla de T-104), en claro y oscuro;
  - **la entrada desde el viaje**, con el selector sustituido como en T-89: el viaje publicado sigue siendo el mismo objeto, y el almacén de prueba lanzaría si algo intentara guardar;
  - un archivo que no es BAPLIE;
  - **la entrada desde la salida de T-82** («1 descargado · 2 cargados · 1 permanente»);
  - la operación sin llegada.

No cambió ninguna prueba existente.

## 4. Los clientes

Banco `tool/t96_main.dart`, compilado en `%TEMP%\baystream-t96-clientes`, sin `docs`, `build` ni `android/key.properties`.
- **Solo en esa copia** se agregaron como assets A07, A08, A08v_VGM, el listado y los eventos (`t96_inputs/`), y se cambió el applicationId a `.t96`.
- Modo sin cuenta con sesión local, namespace `t96acc`: nada sube a la nube.
- El banco solo sustituye el diálogo del selector, que entrega A08. La lectura, la comparación, la salida de T-82 y las pantallas son las del producto.
- Compilado con `--dart-define-from-file=C:\Proyectos\baystream-privado\firebase-prod.json`, sin abrir ese archivo.

| Comprobación | Windows | Honor `.t96`, 360 dp, letra 2.0 | Web (navegador integrado) |
|---|---|---|---|
| A07 abierto, «Comparar con otro BAPLIE…» con A08 | 114 · 121 · 284, 262 con cambios; reservas 0 / 55; POL 127 · POD 189 · Línea 58 · Peso 113 | igual | igual |
| El ejemplo | XSPU8166070 · 0020310 · Peso 24 260 → 24 200 kg | (filas visibles; ejemplo en Windows y Web) | igual que Windows |
| Recientes tras comparar | solo BUQUE GOLF · VIAJE007A (A07) | — | solo A07 |
| «Comparar con la llegada», desde la salida de los 177 eventos | 114 · 176 · 284, 262 con cambios, las mismas cifras por campo, sin guardar | igual | igual |
| Temas | oscuro | **claro y oscuro**, legible, sin cortes | oscuro |

- **Windows:** abierto con `explorer.exe`, PID **15364**, y cerrado por PID. **El almacén real** es `C:\Users\Giova\AppData\Local\BayStream`, con la huella tomada **fuera del paquete** (`powershell ← cmd.exe ← explorer.exe`):
  - **388 archivos antes;**
  - **400 tras comparar,** antes de preparar la operación: los 12 nuevos son `t96acc_*`, con un solo viaje guardado (A07, 142 077 bytes) y 0 movimientos;
  - **400 al terminar:** los 388 previos conservan su SHA, y lo único nuevo son los 12 `t96acc_*`. Los 151 271 bytes de movimientos y la operación son de la preparación del banco, no de la comparación.
  - **Una incidencia mía, declarada:** al traer la ventana al frente con la herramienta de escritorio, se abrió una segunda instancia del banco (PID 18260), no por `explorer.exe`. La cerré por PID en segundos. Como había tocado `t96acc_profiles.lock`, cerré también la primera (PID 12032) y relancé una sola con `explorer.exe` (15364). La huella final no muestra nada fuera de `t96acc_*`.
  - **La app de Codex** (`t105`, PID 29340) estuvo abierta todo el tiempo y no se tocó.
  - **Windows se probó con la compilación anterior a un detalle visual:** el espacio que no parte antes de «kg», que solo afecta el ajuste de línea a letra grande. El Honor y la Web usan la compilación final.
- **El Honor:** NAA-LX3, 360 × 800 dp. Lo encontré con la letra en 1.0 y `.t105` al frente.
  - Instalé `gt.cmartinez.baystream.t96`: primero el APK `8170BCB6…`; después, por el detalle de «kg», el `DE76EE6A…`.
  - Volcados con `adb exec-out uiautomator dump /dev/tty`, en memoria y sanitizados. En modo sin cuenta no apareció ningún dato de cuenta ni ningún diálogo del sistema.
  - **Lo devolví** con la letra en 1.0 y `.t105` al frente, en la misma tarea (t411).
- **La Web:** `http://127.0.0.1:8196`, servida con `python -m http.server` desde `build/web` de la copia. Se usó el **navegador integrado de la app, con la autorización de Carlos** en lugar de Chrome, visible por Carlos. El servidor y la pestaña se cerraron.

Evidencia en `%TEMP%\baystream-t96-evidencia`:
- `honor-comparar-*.png` y `honor-comparar-mosaico.png`;
- `honor-llegada-oscuro.png`;
- `huella-antes.txt`, `huella-tras-comparar.txt` y `huella-despues.txt`, con sus `.bat` y su `.ps1`.

Compilaciones:
- Windows, 148 s;
- APK, 121 s y 71 s;
- Web, 53 s y 63 s.

## 5. Validaciones y SHA

| Validación | Resultado | Registro en `%TEMP%` |
|---|---|---|
| Suite completa | **764/764** (piso 746 + 18 nuevas), dos veces, en el repo después de colocar | `t96-suite-repo-1.log`, `t96-suite-repo-2.log` |
| `flutter analyze` | **0 incidencias**, sin ningún `// ignore` en `lib/` | — |
| Corpus `tool/*corpus*test.dart` | **135/135 en 34 archivos** (129 + 6 de `t96_corpus_test.dart`) | `t96-corpus-repo.log` |

**Lo que no cambia** (`git diff --stat --ignore-cr-at-eol` vacío sobre estas rutas, y los congelados iguales a `m2-baseline`):

| Archivo | SHA-256 |
|---|---|
| `firestore.rules` | `0112510984D9A16364F9752E243999C47306E0BCF82766E380DB380E8FE8E60A` |
| `lib/main.dart` | `C5189B1D8711837A05C68306D424C9FDBCC977BA3BBB6C823089FFE4CA5339D5` |
| `pubspec.yaml` | `1B40E5308D3D1594EAFBF48EE578ABB73A39DC2E3FE0A4551F0D1AC6956F38EA` |
| `pubspec.lock` | `577D742E04143131BC02A1BBB6C246D298C90396E08F6C9DFE393637A2617F53` |
| `lib/latency_test_screen.dart` | `599310DB13A713E82FC0D6A411BE2D7757CBC2B803D772C1CAA16C471725CDFF` |
| `lib/c3_reconciliation_screen.dart` | `3AF478364A8C5386E1F921E0142DC4F847594BECA00B6743563CB09A8A4112A5` |
| Lector, `baplie_parser_service.dart` | `D34FE7F5D12AABD25119382305315747601D6AC77AC97CFD817911E02FF94B7C` |
| Escritor de T-82, `departure_baplie_writer.dart` | `05EE91981499215E9981094EE3C3230C00AB98C54F4793B8750880D23E656147` |
| Codec, `firestore_operation_sync.dart` | `EA63A21606865495E3B189800184871433F24AC775C0E6D0C044CD7EF4C0E974` |
| Modelo, `container_unit.dart` | `6DAF61CD1C5EEF19711E80FD910B56A63C7412E902594B36F117971DE65C32EC` |
| Modelo, `vessel_voyage.dart` | `2F527E1952BB425667020E923043736955A47208CDFB945740C7D0D691BEE1D9` |

**`pubspec.yaml` y `pubspec.lock` no cambian; no hay dependencias nuevas.**

## 6. Incidencias y observaciones

- **El semáforo:** Carlos lo dio para el corpus, para analyze y las pruebas, y para analyze y las compilaciones. Los dispositivos los cedió mientras Codex no los usaba. La Web fue al navegador integrado por decisión suya.
- **«121 llenos y 55 vacíos asignados»** de la ficha es la cuenta por origen. Por estado son 120 y 56, como dicen los eventos del caso. Lo explica la sección 2; no es un defecto.
- **En el Honor no busqué el ejemplo de 0020310 en la lista:** lo vi en Windows y en la Web. En el Honor se vieron las filas con el mismo formato.
- **La segunda instancia de Windows,** declarada arriba, no dejó rastro fuera de `t96acc_*`.
- **Fuera del alcance, para el cierre:** el código viejo de `voyages` en `deleteVoyage` (10.18) sigue igual.

## 7. Horas

Unas **0.75 h de pared** frente a 6.0 h estimadas, de 22:27 a 23:12, contando las esperas cortas del semáforo.

## 8. Archivos

**Nuevos:**
- `lib/features/vessel/domain/services/voyage_comparison.dart`
- `lib/features/vessel/presentation/pages/voyage_comparison_page.dart`
- `test/t96_voyage_comparison_test.dart`
- `test/t96_comparison_page_test.dart`
- `tool/t96_corpus_test.dart`
- `tool/t96_main.dart`
- `docs/T96-RESULTADOS.md`

**Modificados:**
- `lib/features/vessel/presentation/pages/vessel_overview_page.dart`: la entrada, 8 líneas.
- `lib/features/vessel/presentation/pages/departure_baplie_page.dart`: la segunda entrada, 36 líneas.

No toqué `bay_plan_view.dart` ni `change_requests*`. Git: solo `log`, `show`, `diff --stat --ignore-cr-at-eol` y `ls-files`.
