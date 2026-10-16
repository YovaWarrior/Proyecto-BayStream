# T-56 · Tomas de reefer por celda y por rangos, más los cinco textos

Timonel · 15-oct-2026 · Base `35f0058` (10.52); al cerrar, HEAD es `5fba2f2` (10.56), y desde la base solo cambiaron `SPRINT-3.md`, el tablero, la presentación y el informe de T-88.
Rama `sprint-3`. La acepta Codex (10.52).

## 1. El cambio

**El validador busca por celda física, sin tocar el modelo ni el JSON del perfil.**
`ReeferSocketValidator` sigue leyendo los mismos códigos `BBBRRTT` de `VesselProfile.reeferSlots`.
- **Un refrigerado en la par E** (40 o 45): hay toma si existe el código de E, de E−1 o de E+1, con la misma fila y el mismo nivel. No emite resultado.
- **Un refrigerado en la impar b** (20):
  - con el código de b: conforme;
  - si solo existe el de una par vecina (b−1 o b+1): aviso (`notEvaluated`, `warning`) que dice qué código encontró: «Refrigerado X en 0210704: consta la toma 0220704, de bahía par y sin extremo. La celda tiene toma, pero no consta en qué extremo: confírmalo.» Con las dos vecinas dice «constan las tomas 0200704 y 0220704». **Nunca es error**, ni con inventario declarado;
  - si solo existe el otro extremo (b±2), o nada: la regla de hoy, sin cambios (error si está declarado, aviso si no).
- **No se calcula la par de una impar:** se miran las dos vecinas. La 044 de ALFA cubre a la 043 y a la 045 sin fórmula.
- La bahía 001 no busca una 000. Una posición fuera de la geometría sigue en «no evaluado».
- La severidad de T-39 no cambia.
- **El tamaño sale de la paridad de la bahía,** como en T-55 y T-59: par es 40 o 45 e impar es 20. Un 20 anómalo en bahía par se trataría como 40. El corpus no trae ninguno: T-59 contó que todos los 20 están en impar.

**La carga por rangos** está en un servicio puro nuevo, `domain/services/reefer_socket_ranges.dart`, y en la sección de tomas de `vessel_geometry_page.dart`.
- **Bahías:** números y rangos con paso (`002-038/4, 041, 044`), separados por comas o espacios. Se generan **tal como se escriben**, sin calcular pares.
- **Filas:** vacío o «todas» son las de la geometría; también acepta `01-10` o una lista. Con «todas», la fila 00 entra solo si la zona la declara (`true`), porque sin declaración el buque puede no tenerla.
- **Niveles:** de dos en dos por omisión (`82-88`, `02-08`), y obligatorios.
- **Errores legibles:** «Bahías: «002-0x8» no es un número ni un rango como 02-08.», el final menor que el inicio, fuera de 001–999 y el paso 0. Hay un tope de 20 000 códigos por operación.
- **La vista previa** es un diálogo antes de aplicar. Dice cuántas tomas se agregan, cuántas ya estaban y cuántas se descartan con la fila o el nivel fuera de la geometría (contra la geometría del formulario, la misma que se guarda), con hasta tres ejemplos de cada grupo y la línea «Cargar no declara: la casilla de declaración no cambia.»
- **«Quitar por rango»** usa los mismos campos: cuántas se quitan y cuántas no estaban.
- **«Pegar una lista de códigos»** acepta comas, espacios, punto y coma o saltos de línea. Lo que no es de siete dígitos, o trae la bahía 000, se reporta con su cuenta y sus ejemplos; lo que cae fuera de la geometría se descarta con su cuenta.
- **Cargar no declara:** aplicar solo cambia el conjunto, y el origen sigue igual. La casilla «Declaro este conjunto de tomas para el buque» es lo único que declara.
- El campo uno a uno y los chips siguen como estaban.

**Los cinco textos:**
1. **Recientes:** «1 contenedor · 1 bahía», con `operationCount` de T-97.
2. **El desplegable de tapas:** `isDense: false` e `itemHeight: null` en `hatch_covers_page.dart`. A letra grande, la opción elegida y las del menú envuelven en vez de cortar «abierta».
3. **El chip del viaje:** el texto va en un `Flexible` dentro de la fila del chip, así que envuelve dentro de su fondo.
4. **La pantalla vacía:** «Contenido compatible: BAPLIE 2.x, y la 1.5 con aviso.»
5. **El resumen de la escala:** un método nuevo de la entidad del viaje, `VesselVoyage.withoutLoadingPortAt(port)` (no es el perfil), cuenta lo que `cargoCountsFor` y `reservedCountsFor` no cuentan en ninguna parte: sin `LOC+9` y sin descarga en la escala.
   - **Una decisión mía, para que Yov la confirme:** un contenedor sin `LOC+9` que se descarga aquí ya va en «se descargan» y no se repite, para que las cifras sumen el total. En el corpus no cambia nada: A06 no trae `LOC+9` ni descargas en GTPBR (717), y las otras fuentes dan 0.
   - **Resumen corto:** «0 se descargan · 0 se cargan · 0 de paso · 717 sin puerto de carga en el archivo». La cola solo aparece si hay alguno; si no, el texto es idéntico al de antes.
   - **Con reservas,** una línea más: «Sin puerto de carga en el archivo: N contenedores y M reservas».
   - Lo usan la ficha del viaje (`VoyageCallSummary`) y la sección de puerto de la pantalla de parámetros.

## 2. Pruebas del validador y escenario de T-55

`test/t56_reefer_cells_test.dart` (10 pruebas):

| Caso | Resultado |
|---|---|
| 40 en 022/07/04 con toma en 021, 022 o 023, en los tres orígenes | conforme |
| 40 sin ninguna (con 020, 024 y 022/07/06 presentes) | error con inventario declarado; aviso con propuesto y plantilla |
| 20 en 021 con 021 | conforme |
| 20 en 021 con solo 022 | aviso «confirmar el extremo», que nombra 0220704, en los tres orígenes |
| 20 en 021 con solo 020; 043 y 045 con la 044; con 020 y 022 a la vez | aviso, sin calcular pares; «constan las tomas 0200704 y 0220704» |
| 20 en 021 con solo 023 | error declarado; aviso propuesto con «cota inferior» |
| 20 en la 041 sola con 041 | conforme |
| 001 sin vecina 000; fuera de la geometría | sin cambio |
| **Escenario de T-55, sintético** | **91 errores con el código exacto → 82 avisos de extremo y 9 conformes** |

El escenario sintético usa 41 tomas de 40 en 002–038/4 y 044, y 9 tomas de 20 en la 021, con un 20 en cada impar vecina y un 40 en la 022 sobre cada toma de 20, como en `tool/t55_tomas_paridad.dart`.

**Sobre A01 real** (`tool/t56_corpus_test.dart`, con la misma construcción que T-55): 82 + 9 simulados. Antes daban 91 errores; ahora, **82 avisos de extremo y 9 conformes**. `tool/t55_tomas_paridad.dart`, corrido otra vez, da lo mismo: 82 avisos, 82 en un hueco físico con toma, y 0 alertas del escenario de 40.

## 3. La regla de tomas en el corpus, antes y después

`tool/t56_corpus_test.dart` corre en la misma pasada la regla anterior (código exacto, reimplementada en la prueba) y la de T-56. Exige que **no aparezca ninguna alerta nueva** y que **cada una que desaparece o pasa a aviso se explique por la regla de celda**: un 40 con la toma de una impar vecina, o un 20 con la de una par vecina.

**Cada fuente con su perfil propuesto,** como propuesta y también marcado como declarado:

| Fuente | Refrigerados | Tomas | Antes | Después |
|---|---:|---:|---:|---:|
| A01 | 50 | 50 | 0 | 0 |
| A02 | 14 | 14 | 0 | 0 |
| A03 | 10 | 10 | 0 | 0 |
| A03v_VGM | 10 | 10 | 0 | 0 |
| A04 | 71 | 71 | 0 | 0 |
| A05 | 91 | 91 | 0 | 0 |
| A06 | 91 | 91 | 0 | 0 |
| A07 | 12 | 12 | 0 | 0 |
| A08 | 8 | 8 | 0 | 0 |
| A08v_VGM | 8 | 8 | 0 | 0 |

**Mismo buque, otro viaje** (inventario de uno, declarado, contra la carga del otro, con la geometría de los dos):

| Inventario → carga | Antes | Después | Resueltas por celda | Pasan a aviso de extremo |
|---|---:|---:|---:|---:|
| A05 → A06 | 0 | 0 | 0 | 0 |
| A06 → A05 | 0 | 0 | 0 | 0 |
| A07 → A08 | 0 | 0 | 0 | 0 |
| A08 → A07 | 4 | 4 | 0 | 0 |
| A07 → A08v_VGM | 0 | 0 | 0 | 0 |

Las 4 de A08 → A07 son refrigerados de A07 sin toma en la celda dentro del inventario de A08, ni exacta ni vecina. No cambian. **Ninguna alerta nueva en ninguna fuente.**

`tool/block7b_corpus.dart` tampoco cambia. Quitar la toma `0210804` sigue dando error con inventario declarado y aviso con propuesto, porque la celda no tiene toma en 020 ni en 022.

## 4. Las 21 bahías de A07 ∪ A08

`tool/t56_corpus_test.dart` propone el perfil desde la unión: la geometría de los dos planes y `observedHoldBays` de cada uno. Exige la lista exacta:

**01, 02, 03, 05, 06, 07, 09, 10, 11, 13, 14, 15, 17, 18, 19, 21, 22, 23, 25, 26, 27**

- Es la misma lista que T-83 verificó en pantalla.
- Sale igual con A08 y con A08v_VGM.
- **Un cotejo sin el lector de BayStream** la reproduce desde el texto crudo: cada `LOC+147` de nivel < 80, más las dos impares vecinas de cada `EQD` de tipo 4x o Lx en bahía par.

## 5. Los tres clientes y los cinco textos

Banco `tool/t56_main.dart`, compilado en una copia en `%TEMP%\baystream-t56-clientes`, sin `docs`, `build` ni `android/key.properties`. Solo en esa copia se agregaron como assets A07 y A06 (`t56_inputs/`) y se cambió el applicationId a `.t56`. Modo sin cuenta con sesión local: **nada sube a la nube** y no hay movimientos. Todas las compilaciones con `--dart-define-from-file=C:\Proyectos\baystream-privado\firebase-prod.json`, sin abrir ese archivo.

**La carga por rango, en los tres:** perfil de BUQUE GOLF propuesto desde A07, con 12 tomas. Rango: bahías `002-026/4`, filas vacío (las 10 de la geometría) y niveles `82-86, 94`, que suman 7 × 10 × 3 = 210 códigos.

| Comprobación | Windows | Honor `.t56`, 360 dp | Web |
|---|---|---|---|
| Vista previa | 204 se agregan · 6 ya estaban · 70 fuera (nivel 94) | igual | igual |
| Guardado y reabierto | **216** = 12 + 204, «Propuestas del archivo» | 216, propuestas | 216, propuestas |
| Tiempo, de abrir el perfil a «Perfil guardado» | **41 s** | ver la nota | **22 s** |
| Lista pegada `0020184 0060188, 12345 ABCDEFG 0000182 0021282 0100382` | 1 se agrega · 2 ya estaban · 1 fuera · «No se cargan 3 que no son códigos de siete dígitos: 12345, ABCDEFG, 0000182.» | igual | igual |
| Quitar por rango `002-026/4`, nivel `86` | «Se quitan 70» · «No estaban 0» → 147 | igual | igual |
| La casilla | cargar y quitar dejan «Propuestas»; solo la casilla pasa a **«Tomas declaradas por el usuario» (147)** al reabrir | igual | igual |

**Los tiempos incluyen mi propia latencia de agente,** que es mayor que la de una persona escribiendo.
- **El Honor:** la primera carga tardó 122 s, contando la exploración de la pantalla (buscar los campos, varios volcados). Dos intentos de cronometrarla de un tirón fallaron por el teclado (ver «Incidencias»), así que no tengo un tiempo limpio en el Honor.
- **La vista previa** aparece al instante en los tres.
- **Sugiero que Codex cronometre a mano en el Honor** al aceptar.

**Los textos:**
- **Honor** (NAA-LX3, 720 × 1600 a 320 dpi = 360 × 800 dp), con la letra en **2.0** y en **claro y oscuro**. Capturas `honor-*-claro.png` y `honor-*-oscuro.png` y el mosaico `honor-oscuro-mosaico.png`:
  1. Recientes: «1 contenedor · 1 bahía» y «717 contenedores · 27 bahías».
  2. Tapas: «Sin tapa · bodega abierta» en dos líneas dentro del campo, y entero en el menú.
  3. El chip: «Viaje: VIAJE007A» y «Viaje: VIAJE004A» en dos líneas dentro del fondo gris.
  4. La pantalla vacía: «Contenido compatible: BAPLIE 2.x, y la 1.5 con aviso.»
  5. A06 en GTPBR: «0 se descargan · 0 se cargan · 0 de paso · 717 sin puerto de carga en el archivo», con el aviso de la 1.5.
- **Windows,** a letra 1.0 y en oscuro: los cinco, y el menú de tapas.

**El almacén y los clientes:**
- **Windows:** abierto con `explorer.exe`, PID **35288**, y cerrado por PID. **Usó el almacén real** `C:\Users\Giova\AppData\Local\BayStream`. La huella se tomó **fuera del paquete**, con `.bat` lanzados por `explorer.exe` (cadena `powershell ← cmd.exe ← explorer.exe`). **362 archivos antes y 374 después:** los 362 previos conservan su SHA, y los 12 nuevos son solo `t56acc_*`. `t56acc_movements.hive` pesa 0 bytes: sin movimientos.
- **El Honor:** se instaló solo `gt.cmartinez.baystream.t56` (APK `A3FDFE69…B20B2`). Volcados con `adb exec-out uiautomator dump /dev/tty`, en memoria y con correos y UID ocultos; en modo sin cuenta no apareció ninguno. No apareció ningún diálogo del sistema.
  - **La letra:** la encontré en 1.0, la subí a 2.0 y **la devolví a 1.0**.
- **La Web:** `http://127.0.0.1:8156`, servida con `python -m http.server` desde `build/web` de la copia. Se usó el navegador integrado de la app (Chromium), visible por Carlos, con el namespace `t56acc` en el almacén de ese origen. El servidor y la pestaña se cerraron al terminar.

## 6. Validaciones y SHA

| Validación | Resultado | Registro en `%TEMP%` |
|---|---|---|
| Suite completa | **745/745** (piso 710 + 35 nuevas), tres veces, la última después de la corrección de textos | `t56-suite-1.log`, `t56-suite-2.log`, `t56-suite-final.log` |
| `flutter analyze` | **0 incidencias**, sin `// ignore:` | `t56-analyze.log` |
| Corpus `tool/*corpus*test.dart` | **129/129 en 33 archivos** (118/118 de antes + 11 de `t56_corpus_test.dart`), dos veces | `t56-corpus-1.log`, `t56-corpus-final.log` |
| Auxiliares | `block7b_corpus`, `t55_tomas_paridad` y `t42_aceptacion`, con código 0 | `t56-<auxiliar>.json` |

**Las 35 nuevas:**
- `t56_reefer_cells_test.dart`: 10;
- `t56_socket_ranges_test.dart`: 12, 6 de dominio y 6 de pantalla;
- `t56_text_test.dart`: 13, todas a 360 dp con la escala real del Honor (la tabla de T-104) y en los dos temas donde aplica.

**Las pruebas de diseño sí detectan el defecto.** Con el desplegable y el chip de HEAD, las cuatro fallan:
- el chip, «A RenderFlex overflowed by 13 pixels»;
- el desplegable, «abierta» 27 px por debajo del campo.

**Pruebas existentes que cambian, ninguna borrada ni en `skip`:**
- `test/t104_text_test.dart`: el texto nuevo de la pantalla vacía.
- `test/t83_hatch_covers_test.dart`: el desplegable ya no tiene altura fija y empuja el botón 8 px fuera de los 800. Antes del segundo toque se agregan `ensureVisible` y `pumpAndSettle`.
- `test/vessel_geometry_page_test.dart`, «al quitar un nivel sí se rotula como corregida»: la sección de tomas creció con el formulario de rangos, y la lista perezosa ya no construía el resumen a 2600 px. La prueba sube la vista a 3600 px.

**Lo que no cambia** (`git diff --stat --ignore-cr-at-eol` vacío sobre estas rutas, y los congelados iguales a `m2-baseline`):

| Archivo | SHA-256 |
|---|---|
| `firestore.rules` | `0112510984D9A16364F9752E243999C47306E0BCF82766E380DB380E8FE8E60A` |
| `lib/features/vessel/domain/entities/vessel_profile.dart` (modelo y JSON del perfil) | `70F26644CADDFF4FC2413A133FC3E336AD865EE0CFFB4164F428FF2B1F242EDF` |
| `lib/features/vessel/data/repositories/firestore_operation_sync.dart` (codec) | `EA63A21606865495E3B189800184871433F24AC775C0E6D0C044CD7EF4C0E974` |
| `lib/main.dart` | `C5189B1D8711837A05C68306D424C9FDBCC977BA3BBB6C823089FFE4CA5339D5` |
| `pubspec.yaml` | `1B40E5308D3D1594EAFBF48EE578ABB73A39DC2E3FE0A4551F0D1AC6956F38EA` |
| `pubspec.lock` | `577D742E04143131BC02A1BBB6C246D298C90396E08F6C9DFE393637A2617F53` |
| `lib/latency_test_screen.dart` | `599310DB13A713E82FC0D6A411BE2D7757CBC2B803D772C1CAA16C471725CDFF` |
| `lib/c3_reconciliation_screen.dart` | `3AF478364A8C5386E1F921E0142DC4F847594BECA00B6743563CB09A8A4112A5` |

**`pubspec.yaml` y `pubspec.lock` no cambian; no hay dependencias nuevas.**

## 7. Incidencias y observaciones

- **El semáforo:** la primera vez Carlos pidió esperar a Codex. Luego cedió todo, y después cedió el Honor y Windows hasta cerca de las 23:30.
- **Al retomar tras el límite de uso,** Codex usaba el Honor (`.t105` al frente) y tenía abierta su app de Windows. Con permiso de Carlos usé el Honor y lo devolví con la letra en 1.0 y `.t105` al frente. **La actividad de `.t105` se recreó:** la tarea pasó de t408 a t411. Su almacén no se tocó, pero Codex encontrará la app recién abierta.
- **No relancé Windows tras la corrección de textos,** porque la app `t105` de Codex estaba abierta sobre el mismo almacén real. Windows se probó con la compilación anterior a esa corrección, que solo cambia dos detalles de la vista previa: «….» pasa a «…», y «Se agregaron 1 toma» pasa a «Se agregó 1 toma». Los dos están cubiertos por pruebas, y se vieron en el Honor y en la Web.
- **El teclado por gestos del Honor:** dos veces mis deslizamientos con el teclado abierto escribieron «de lo…» en campos del formulario, solo en el borrador y sin guardar. Un deslizamiento desde el borde derecho fue un «atrás» del sistema. Se corrigió cerrando el teclado antes de cada deslizamiento.
- **Algo limpió `%TEMP%` durante la pausa:** la copia de compilación quedó con 85 de sus 129 archivos de `lib/`, y la Web había salido sin `canvaskit/`. Rehice la copia con fechas actuales y recompilé la Web (45 s).
- **Una observación previa, fuera de la ficha:** con muchas tomas, al desplazarse lejos, la sección «Tomas de reefer» se pliega, porque la lista perezosa desecha el `ExpansionTile`. Las tomas no se pierden: viven en el estado de la página. Si molesta, se le puede dar un `PageStorageKey`.
- **Otra, de texto:** el diálogo de quitar repite «Cargar no declara…». Es veraz, pero dice «Cargar» al quitar.
- **El T-104 ya anotado,** fuera del alcance: «Usar estas declaraciones» se pega al borde de su botón a 2.0.

## 8. Horas

Unas **1.3 h de pared** frente a **3.5 h** estimadas:
- de 18:22 a 19:17, menos 8 minutos de espera del semáforo;
- de 21:43 a 22:10.

No cuentan la pausa por el límite de uso, de 19:17 a 21:43.

## 9. Archivos

**Modificados:**
- `lib/features/vessel/domain/entities/vessel_voyage.dart`
- `lib/features/vessel/domain/services/reefer_socket_validator.dart`
- `lib/features/vessel/presentation/pages/hatch_covers_page.dart`
- `lib/features/vessel/presentation/pages/recent_voyages_page.dart`
- `lib/features/vessel/presentation/pages/vessel_geometry_page.dart`
- `lib/features/vessel/presentation/widgets/empty_state_widget.dart`
- `lib/features/vessel/presentation/widgets/voyage_call_summary.dart`
- `lib/features/vessel/presentation/widgets/voyage_summary_card.dart`
- `test/t104_text_test.dart`
- `test/t83_hatch_covers_test.dart`
- `test/vessel_geometry_page_test.dart`

**Nuevos:**
- `lib/features/vessel/domain/services/reefer_socket_ranges.dart`
- `test/t56_reefer_cells_test.dart`
- `test/t56_socket_ranges_test.dart`
- `test/t56_text_test.dart`
- `tool/t56_corpus_test.dart`
- `tool/t56_main.dart`
- `docs/T56-RESULTADOS.md`

**Evidencia sin versionar**, en `%TEMP%\baystream-t56-evidencia`:
- las capturas del Honor;
- las huellas «antes» y «después» del almacén real, con su `.bat` y su `.ps1`;
- los ayudantes de volcado.

Git: solo `log`, `show`, `diff --stat --ignore-cr-at-eol` y `ls-files`.
