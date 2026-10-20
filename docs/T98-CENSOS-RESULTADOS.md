# T-98 · Censos de idioma, Material 3 y mensajes de error (Fase B)

Timonel · 20-oct-2026 · Base: `lib/` de `sprint3-cierre` (`90dce4b`) · **Solo lectura.**
El dictamen de cada submétrica lo da Codex en `docs/T98-RESULTADOS.md` (10.92).

Lo que se hizo y lo que no:

- Se leyó todo `lib/` de presentación y los servicios de dominio y datos que producen texto, y se
  escribieron cinco scripts de Python sin paquetes externos (`tool/t98c_*.py`). La corrida completa
  tarda menos de 4 s y solo lee archivos.
- **No** se ejecutó Flutter ni Dart, no se abrió BayStream, no se tocó el Honor, no se cortó la red y
  no se modificó `lib/`, `test/` ni `pubspec.*`. Codex medía tiempos en esta laptop.
- El censo es estático: dice lo que el código **puede** mostrar y por qué ruta. No sustituye el
  recorrido visual de las pantallas, que es de la Fase B de Codex.

## Resultado en tres líneas

1. **Idioma.** De 1727 cadenas visibles de `lib/`, 52 están en inglés o mezclan inglés (25 en la
   interfaz, 4 en el PDF y 23 encabezados del CSV). Además, Flutter pone en inglés 20 grupos de textos
   («Back», «Alert», el selector de fecha completo, la barra de copiar y pegar…) porque `MaterialApp`
   no declara localización. La métrica queda entre **95.5 % y 98.5 %** según el alcance: ninguna
   lectura llega al 100 % que pide «Idioma de interfaz: español».
2. **Material 3.** 237 controles interactivos en 19 pantallas, sin la rejilla. Todos son componentes
   de Material; **1 excepción** de color: los resultados del buscador usan `Colors.red`, `cyan`,
   `green`, `orange` y `yellow`.
3. **Mensajes de error.** 218 mensajes distintos. **49 (22.5 %)** dicen causa y acción explícitas;
   109 (50.0 %) si se cuentan las implícitas. De 12 errores de lectura de un BAPLIE, 4 nombran el
   segmento. En seis sitios, la pantalla puede mostrar tal cual, en inglés, el `toString()` de una
   excepción.

## 1. Procedencia y cómo se reproduce

- `git log --oneline --decorate -3`: HEAD `a8d2971` en `sprint-3`; la etiqueta `sprint3-cierre` está
  en `90dce4b`.
- `git diff --stat sprint3-cierre -- lib/` sale vacío: el `lib/` del árbol es el de la etiqueta. Entre
  `sprint3-cierre` y HEAD tampoco cambian `lib/`, `test/` ni `pubspec.*`.
- Los 136 archivos de `lib/` tienen la misma huella que la copia de la Fase B de Codex
  (`%TEMP%\t98-b-90dce4b-19oct\app\lib`) al normalizar los finales de línea: **136/136**. El
  inventario de Codex se generó sobre esa copia (136/136 huellas iguales).
- **Los cinco CSV salen idénticos, byte a byte, sobre `lib/` del árbol y sobre la copia archivada de
  Codex** (`%TEMP%\t98c-censos-copia\`). `tablas.md` y `resumen.json` difieren solo en la
  conciliación con los candidatos de Codex, que la corrida sobre la copia no hace.

Para repetirlo:

```powershell
python -I tool/t98c_censos.py . "$env:TEMP\t98c-censos" --codex "$env:TEMP\t98-b-90dce4b-19oct"
```

La salida va a `%TEMP%\t98c-censos\` (el script rechaza una carpeta fuera de TEMP). Las tablas de este
informe están copiadas de su `tablas.md`; solo baja el nivel de los títulos. Las listas completas que
no caben aquí, como las 4763 cadenas del censo de idioma, están en los CSV:

| Archivo | Contenido | SHA-256 |
|---|---|---|
| `idioma.csv` | las 4763 cadenas: archivo, línea, regla, visible, canal, idioma, palabras no españolas y motivo | `572222f46211c60b58a88c0badafe8c088f9719dc10ffb752cab3e8383b91aef` |
| `framework.csv` | los 20 textos de Flutter de la tabla I-7 | `707367c826129c633f73ddd2f6b11e5a8ee210b88b43c11a1e1dd29a8027c2de` |
| `material3.csv` | los 249 constructores (237 controles y 12 excluidos) con pantalla, origen, color y motivo | `570420da785cb5b4e641aab471ee35e082f5ddb3e2f205fc272f3f63400852d6` |
| `mensajes.csv` | los 218 mensajes con sus juicios y el arreglo sugerido (tabla E-3) | `394bba45e24fe289bb4feece8df67761a62d4b62f8320189be2b61ca41d1c7c0` |
| `envolturas.csv` | las 29 envolturas (tabla E-4) | `134a06287b63361b5348de5cce2577f708bc67950166c7d7be1875e5a46a0347` |
| `resumen.json` | procedencia y conteos de los tres censos | `1dc44972576f66add133535bd60593cd0b0bb9178732acb1a40ede491e40abe8` |
| `tablas.md` | las tablas de este informe | `d115ff4c3ebfb2511f33bf20ff787249fff9239da32e07b9d95feba0a97d7c3c` |

El correo de contacto de la política aparece como «[CORREO OMITIDO]» en los CSV. Para el idioma
cuenta como una sola palabra, `CORREO_ELECTRONICO`, sin idioma.

## 2. Método común a los tres censos

**La unidad.** Los 4997 «literales candidatos» de `tool/t98_inventario.py` no sirven como unidad:
su patrón no entiende las comillas dentro de una interpolación, así que
`'${operationCount(n, 'celda', 'celdas')}'` sale partido en trozos. **604** de los 4997 son trozos
así. `tool/t98c_lexico.py` es un tokenizador de cadenas de Dart: entiende comentarios anidados,
cadenas raw y triples, e interpolaciones con cadenas dentro. Encuentra 5104 literales simples, todos
bien cerrados, y los agrupa en **4763 cadenas de Dart**: los literales adyacentes se unen, como hace
el compilador. Los 4393 candidatos que sí coinciden con un literal quedan dentro de esas cadenas.

**El producto.** El grafo de imports desde `lib/main.dart` alcanza 132 de los 136 archivos. Los
cuatro que no llegan no se censan como producto:

| Archivo | Por qué no llega al producto |
|---|---|
| `lib/latency_test_screen.dart` | pantalla H5 congelada; solo la abre `tool/h5_main.dart` |
| `lib/c3_reconciliation_screen.dart` | pantalla H5 congelada; solo la abre `tool/h5_main.dart` |
| `presentation/pages/segregation_page.dart` | la matriz de segregación no tiene entrada (10.89, Sprint 4) |
| `lib/core/utils/privacy_policy_html.dart` | plantilla HTML/CSS de `tool/t88_privacidad.dart`; el texto sale de `privacy_policy.dart`, que sí se censa |

**Cada decisión tiene su regla escrita.** Las reglas automáticas solo cubren contextos sin duda
(directivas, claves de mapa y de widget, `debugPrint`, `RegExp`, comparaciones, el primer argumento
de `Text`, `tooltip`, `labelText`…). El resto está en las tablas de `t98c_idioma.py`, por archivo y
por línea, con el motivo. Se escribieron leyendo el código y la ruta hasta la pantalla.

## 3. Censo 1 · Idioma (RNF-002)

### 3.1 Qué cadenas son visibles

#### Tabla I-1 · De los candidatos léxicos a las cadenas censadas

| Paso | Cantidad |
|---|---:|
| Candidatos léxicos de `tool/t98_inventario.py` (Fase A de Codex) | 4997 |
| · coinciden exactamente con un literal de Dart | 4393 |
| · son trozos: comillas dentro de `${…}` parten el literal | 604 |
| Literales simples que encuentra el tokenizador de `tool/t98c_lexico.py` | 5104 |
| · anidados dentro de una interpolación | 422 |
| Cadenas de Dart (literales adyacentes unidos, como el compilador) | 4763 |

#### Tabla I-2 · Clasificación de las cadenas

| Grupo | Cadenas |
|---|---:|
| Directivas import/export/part | 694 |
| En archivos que no llegan al producto | 138 |
| Sin letras (cifras, signos, separadores o solo interpolaciones) | 630 |
| Con letras y no visibles para el usuario | 1574 |
| **Visibles** | **1727** |
| **Total** | **4763** |

Las reglas, con su cantidad. Las que empiezan con `V-` son visibles y las que empiezan con `NV-` no lo
son; `/ANIDADA` indica que la cadena hereda la decisión de la cadena que la contiene:

#### Tabla I-3 · Reglas de clasificación

| Regla | Cadenas |
|---|---:|
| `V-PANTALLA` | 866 |
| `NV-DIRECTIVA` | 694 |
| `NV-CLAVE-MAPA` | 672 |
| `SIN-LETRAS` | 630 |
| `V-TEXTO` | 542 |
| `NV-CLAVE-WIDGET` | 256 |
| `NV-INTERNO` | 187 |
| `NV-FUERA-DEL-PRODUCTO` | 138 |
| `V-TEXTO/ANIDADA` | 75 |
| `NV-COMPARACION` | 70 |
| `V-ETIQUETA` | 70 |
| `V-PANTALLA/ANIDADA` | 67 |
| `NV-OPERANDO` | 66 |
| `NV-VOZ` | 59 |
| `V-PDF` | 57 |
| `NV-DATOS-EDI` | 54 |
| `NV-PATRON` | 42 |
| `V-ARCHIVO` | 28 |
| `NV-CODIGO` | 28 |
| `NV-PERSISTENCIA` | 26 |
| `NV-DEPURACION` | 19 |
| `NV-DATOS` | 17 |
| `NV-EXCEPCION-INTERNA` | 15 |
| `V-ARGUMENTO` | 15 |
| `NV-REGISTRO` | 13 |
| `NV-ENTORNO` | 11 |
| `NV-INALCANZABLE` | 9 |
| `NV-REEMPLAZADO` | 9 |
| `NV-DEPURACION/ANIDADA` | 6 |
| `NV-SOLO-H5` | 5 |
| `V-ACCESIBILIDAD` | 5 |
| `NV-MEDICION` | 4 |
| `NV-SIN-USO` | 3 |
| `NV-NO-MOSTRADO` | 3 |
| `V-SISTEMA` | 2 |

Las no visibles que tienen letras se repartieron así: claves, códigos e identificadores
(`NV-INTERNO`, `NV-CODIGO`, `NV-CLAVE-*`, `NV-PERSISTENCIA`), datos EDIFACT del lector y del BAPLIE de
salida (`NV-DATOS-EDI`), vocabulario del dictado (`NV-VOZ`), registros (`NV-REGISTRO`) y
`toString()` de depuración (`NV-DEPURACION`). Hay tres grupos que conviene mirar, porque son textos
en español que el usuario **no** ve:

- `NV-REEMPLAZADO` (9): mensajes que existen en `lib/` pero que la pantalla cambia por otro antes de
  mostrarlos. Por ejemplo, los `CacheFailure` del almacén local se muestran con el texto genérico de
  `vessel_error_message.dart:48`.
- `NV-NO-MOSTRADO` (3): los motivos de rechazo de la nube (`sync_engine.dart:224, 255, 261`). Se
  guardan en el registro del movimiento, pero ninguna pantalla los lee: el usuario solo ve «N
  rechazados».
- `NV-SIN-USO` y `NV-INALCANZABLE` (12): código sin llamada, como `Bay.getContainerAt` con su
  `'No container at position'` (`bay.dart:165`), o ramas que no se pueden ejecutar.

### 3.2 Idioma de lo visible

El idioma se decide palabra por palabra, sobre el texto fijo de cada cadena, sin lo interpolado. Las
palabras con tilde o ñ son españolas por construcción. Las 1322 palabras distintas sin tilde de las
cadenas visibles se revisaron una por una. Las 123 que no son españolas quedaron en `VOCABULARIO`
(`t98c_idioma.py`) con su etiqueta: 37 en inglés, 42 siglas o códigos, 20 nombres propios, 21
unidades, formatos o rutas y 3 préstamos.

Como control, las cadenas clasificadas como españolas se cruzaron con una lista de unas 300 palabras
inglesas frecuentes. Solo aparecieron palabras que también son españolas («no», «plan», «total»,
«error», «local», «sea»), la sigla «OR», nombres y rutas («Cloud Firestore»,
`AppData\Local\…\[DEFAULT]`), el préstamo «zoom» (tabla I-6) y trozos de código interpolado
(«bay», «row», «group»).

#### Tabla I-4 · Visibles por canal e idioma

| Canal | español | sin idioma (siglas, nombres o unidades) | mixta | otro idioma | Total |
|---|---:|---:|---:|---:|---:|
| pantalla | 1444 | 111 | 13 | 10 | 1578 |
| accesibilidad | 47 | 0 | 2 | 0 | 49 |
| sistema | 5 | 2 | 0 | 0 | 7 |
| pdf | 42 | 19 | 2 | 2 | 65 |
| archivo | 4 | 1 | 0 | 23 | 28 |
| **Total** | **1542** | **133** | **17** | **35** | **1727** |

### 3.3 La métrica

#### Tabla I-8 · Métrica del idioma: visibles en español / visibles

Dos lecturas, porque T-63 no dice qué hacer con lo que no tiene idioma (siglas, nombres, unidades): (a) español / (español + inglés o mixto); (b) (español + sin idioma) / visibles. Los textos de Flutter cuentan por entrada de la tabla I-7, todas en inglés.

| Alcance | Español | Sin idioma | Inglés o mixto | Flutter (I-7) | (a) | (b) |
|---|---:|---:|---:|---:|---:|---:|
| Interfaz (pantalla, accesibilidad y diálogos del sistema) | 1496 | 113 | 25 | — | 98.4 % | 98.5 % |
| Interfaz, con los textos de Flutter | 1496 | 113 | 25 | 20 | 97.1 % | 97.3 % |
| Todo lo visible, también el PDF y el CSV | 1542 | 133 | 52 | — | 96.7 % | 97.0 % |
| Todo lo visible, con los textos de Flutter | 1542 | 133 | 52 | 20 | 95.5 % | 95.9 % |

Con cualquiera de las cuatro filas, y con cualquiera de las dos lecturas, el resultado queda por
debajo del 100 %.

### 3.4 Las que no están en español, y por qué

#### Tabla I-5 · Cadenas visibles en inglés o mixtas

| # | Archivo:línea | Canal | Idioma | Texto | Palabras en inglés y por qué |
|---|---|---|---|---|---|
| I01 | `lib/core/utils/iso_coordinate_parser.dart:25` | pantalla | otro idioma | Bay {bayPadded}, Row {rowPadded}, Tier {tierPadded} | Bay (inglés); Row (inglés); Tier (inglés) |
| I02 | `data/repositories/firebase_session_repository.dart:175` | pantalla | mixta | No se pudo iniciar sesión ({code}). | {valor interpolado} (inglés) |
| I03 | `data/repositories/firebase_session_repository.dart:200` | pantalla | mixta | No se pudo enviar el correo ({error.code}). | {valor interpolado} (inglés) |
| I04 | `data/repositories/firestore_operation_sync.dart:137` | pantalla | mixta | La nube devolvió un error ({error.code}). | {valor interpolado} (inglés) |
| I05 | `data/repositories/firestore_operation_sync.dart:202` | pantalla | mixta | La fuente {kind.wire} llegó incompleta o distinta de la publicada. No se guardó nada: vuelve a intentarlo. | {valor interpolado} (inglés) |
| I06 | `data/services/baplie_parser_service.dart:308` | pantalla | otro idioma | UNKNOWN | UNKNOWN (inglés) |
| I07 | `data/services/export_service.dart:25` | archivo | otro idioma | containerId | containerId (inglés) |
| I08 | `data/services/export_service.dart:26` | archivo | otro idioma | isoSizeType | isoSizeType (inglés) |
| I09 | `data/services/export_service.dart:27` | archivo | otro idioma | status | status (inglés) |
| I10 | `data/services/export_service.dart:28` | archivo | otro idioma | stowagePosition | stowagePosition (inglés) |
| I11 | `data/services/export_service.dart:29` | archivo | otro idioma | grossWeight | grossWeight (inglés) |
| I12 | `data/services/export_service.dart:30` | archivo | otro idioma | vgmWeight | vgmWeight (inglés) |
| I13 | `data/services/export_service.dart:31` | archivo | otro idioma | tareWeight | tareWeight (inglés) |
| I14 | `data/services/export_service.dart:32` | archivo | otro idioma | portOfLoading | portOfLoading (inglés) |
| I15 | `data/services/export_service.dart:33` | archivo | otro idioma | portOfDischarge | portOfDischarge (inglés) |
| I16 | `data/services/export_service.dart:34` | archivo | otro idioma | finalDestination | finalDestination (inglés) |
| I17 | `data/services/export_service.dart:35` | archivo | otro idioma | operatorCode | operatorCode (inglés) |
| I18 | `data/services/export_service.dart:36` | archivo | otro idioma | isDangerous | isDangerous (inglés) |
| I19 | `data/services/export_service.dart:37` | archivo | otro idioma | imdgClass | imdgClass (inglés) |
| I20 | `data/services/export_service.dart:38` | archivo | otro idioma | unNumber | unNumber (inglés) |
| I21 | `data/services/export_service.dart:39` | archivo | otro idioma | isReefer | isReefer (inglés) |
| I22 | `data/services/export_service.dart:40` | archivo | otro idioma | temperature | temperature (inglés) |
| I23 | `data/services/export_service.dart:41` | archivo | otro idioma | temperatureUnit | temperatureUnit (inglés) |
| I24 | `data/services/export_service.dart:42` | archivo | otro idioma | isOverDimension | isOverDimension (inglés) |
| I25 | `data/services/export_service.dart:43` | archivo | otro idioma | overHeight | overHeight (inglés) |
| I26 | `data/services/export_service.dart:44` | archivo | otro idioma | overWidthLeft | overWidthLeft (inglés) |
| I27 | `data/services/export_service.dart:45` | archivo | otro idioma | overWidthRight | overWidthRight (inglés) |
| I28 | `data/services/export_service.dart:46` | archivo | otro idioma | overLengthFront | overLengthFront (inglés) |
| I29 | `data/services/export_service.dart:47` | archivo | otro idioma | overLengthRear | overLengthRear (inglés) |
| I30 | `data/services/pdf_report_service.dart:267` | pdf | mixta | CUBIERTA (DECK) - Tiers {geometry.deckTierFloor} y superiores | DECK (inglés); Tiers (inglés) |
| I31 | `data/services/pdf_report_service.dart:290` | pdf | mixta | BODEGA (HOLD) - Tiers inferiores a {geometry.deckTierFloor} | HOLD (inglés); Tiers (inglés) |
| I32 | `data/services/pdf_report_service.dart:461` | pdf | otro idioma | Reefer | Reefer (inglés) |
| I33 | `data/services/pdf_report_service.dart:734` | pdf | otro idioma | Reefer | Reefer (inglés) |
| I34 | `domain/services/departure_baplie_writer.dart:19` | pantalla | mixta | La operación no tiene una fuente loading_baplie. Importa el plan de carga antes de generar la salida. | loading_baplie (inglés) |
| I35 | `presentation/pages/departure_baplie_page.dart:94` | pantalla | mixta | La escala no tiene una operación guardada con fuente loading_baplie. | loading_baplie (inglés) |
| I36 | `presentation/pages/vessel_geometry_page.dart:295` | pantalla | mixta | Tomas de reefer: {widget.proposedReeferSocketCount} posiciones propuestas del archivo (cota inferior). El buque puede tener más tomas. Confirmar la geometría no las convierte en declaradas. | reefer (inglés) |
| I37 | `presentation/pages/vessel_geometry_page.dart:458` | pantalla | mixta | Tomas de reefer ({_sockets.length}) | reefer (inglés) |
| I38 | `presentation/pages/vessel_geometry_page.dart:667` | pantalla | mixta | El archivo BAPLIE no transmite las dimensiones del buque. Solo revela los slots que este viaje trae ocupados, así que la aplicación puede deducir el mínimo, nunca el total: un buque de catorce filas que hoy carga en diez se ve, desde el archivo, como un buque de diez filas. | slots (inglés) |
| I39 | `presentation/pages/vessel_overview_page.dart:219` | pantalla | mixta | Bay Plan | Bay (inglés) |
| I40 | `presentation/widgets/bay_plan_view.dart:277` | pantalla | otro idioma | BAY {bayNumber.toString().padLeft(2, '0')} ({occupancyLabel}) | BAY (inglés) |
| I41 | `presentation/widgets/bay_plan_view.dart:341` | pantalla | otro idioma | Reefer | Reefer (inglés) |
| I42 | `presentation/widgets/bay_plan_view.dart:727` | pantalla | otro idioma | BAY {bay.bayNumber.toString().padLeft(2, '0')}{hatchCovers == null ? ' · tapas sin declarar' : ''} | BAY (inglés) |
| I43 | `presentation/widgets/bay_plan_view.dart:785` | pantalla | mixta | ▲ CUBIERTA (DECK) | DECK (inglés) |
| I44 | `presentation/widgets/bay_plan_view.dart:829` | pantalla | mixta | ▼ BODEGA (HOLD) | HOLD (inglés) |
| I45 | `presentation/widgets/bay_plan_view.dart:891` | pantalla | otro idioma | Bay {bay.bayNumber.toString().padLeft(2, '0')} | Bay (inglés) |
| I46 | `presentation/widgets/container_search_delegate.dart:268` | pantalla | mixta | Tip: Escribe parte del ID del contenedor (ej: "MSKU123") para encontrarlo rápidamente | Tip (inglés) |
| I47 | `presentation/widgets/containers_list_view.dart:268` | pantalla | otro idioma | Reefer | Reefer (inglés) |
| I48 | `presentation/widgets/vessel_profile_view.dart:158` | accesibilidad | mixta | Abrir bahía {bays[index].bayNumberPadded} en Bay Plan | Bay (inglés) |
| I49 | `presentation/widgets/vessel_profile_view.dart:161` | accesibilidad | mixta | Abrir bahía {bays[index].bayNumberPadded} en Bay Plan | Bay (inglés) |
| I50 | `presentation/widgets/voyage_stats_view.dart:235` | pantalla | otro idioma | Reefers | Reefers (inglés) |
| I51 | `presentation/widgets/voyage_stats_view.dart:597` | pantalla | otro idioma | Reefer | Reefer (inglés) |
| I52 | `presentation/widgets/voyage_stats_view.dart:631` | pantalla | otro idioma | Reefer | Reefer (inglés) |

Agrupadas por causa:

- **Posición en inglés (I01).** `IsoCoordinate.displayFormat` devuelve «Bay 002, Row 01, Tier 82».
  Se muestra como «Posición» en el detalle del contenedor (Bay Plan y Lista), en el de la reserva y en
  el buscador. Es la cadena en inglés con más presencia en pantalla.
- **«BAY», «Bay» y «Bay Plan» (I39-I40, I42, I45, I48-I49).** El chip de cada bahía, el título de la
  rejilla, el estado sin geometría, la pestaña y la etiqueta de accesibilidad del perfil. En otras
  pantallas el producto dice «Bahía». «Bay Plan» es el nombre de la vista en el ERS y en T-63 (2.2);
  sigue siendo inglés.
- **Glosas «(DECK)» y «(HOLD)» y «Tiers» (I30-I31, I43-I44).** En la rejilla y en el PDF.
- **«Reefer» y «Reefers» (I32-I33, I36-I37, I41, I47, I50-I52).** En la leyenda del plano, la Lista,
  Estadísticas, el PDF y la geometría. El detalle del contenedor, en cambio, dice «REFRIGERADO».
- **«slots» y «Tip» (I38, I46).** Palabras sueltas dentro de frases españolas.
- **«UNKNOWN» (I06).** Es el número de viaje por omisión cuando el TDT no lo trae. Se vería como
  «Viaje: UNKNOWN», en el PDF y en el nombre del archivo exportado.
- **Identificadores y códigos en mensajes (I02-I05, I34-I35).** `loading_baplie` está escrito en dos
  mensajes. Otros cuatro interpolan un código de Firebase («operation-not-allowed»,
  «deadline-exceeded»…) o el `wire` de la fuente («arrival_baplie»).
- **Encabezados del CSV (I07-I29).** Las 23 columnas del CSV exportado son nombres de propiedades en
  inglés (`containerId`, `grossWeight`…), y la columna `id` cuenta como sigla. Los valores tampoco
  están en español, aunque no son literales: `status` sale como `full`/`empty`/`unknown` y los
  booleanos como `true`/`false` (`export_service.dart:63` y siguientes).

### 3.5 Los textos que pone Flutter, incluido «Back»

`MaterialApp` (`lib/core/app.dart:15`) no declara `localizationsDelegates`, `supportedLocales` ni
`locale`, y `flutter_localizations` no está en `pubspec.yaml`. Flutter usa entonces
`DefaultMaterialLocalizations`, que es inglés de EE. UU. No son literales de `lib/`, pero se ven, o se
anuncian, porque `lib/` usa esos widgets. El origen de cada texto se leyó en el SDK local
(`C:\flutter`, Flutter 3.38.9, el mismo de la Fase B):

#### Tabla I-7 · Textos que pone Flutter en inglés

| # | Texto | Origen en el SDK 3.38.9 | Widget | Dónde aparece | Canal | Plataformas |
|---|---|---|---|---|---|---|
| F01 | Back | `material/action_buttons.dart:149 y :200 (backButtonTooltip)` | BackButton automático de AppBar | las 15 rutas empujadas sin leading propio (14 pantallas): Recientes, Perfiles, Parámetros, Política, Tapas de escotilla, Alertas, Listado, BAPLIE de salida, Comparar, Orden de descarga, Avance, Tapas en la operación, Solicitudes (y su formulario) y Nube y cuenta. El Honor lo leyó en Alertas, Recientes y Parámetros (Fase B). | accesibilidad y tooltip | Android, Windows y Web |
| F02 | Alert | `material/dialog.dart:782 (alertDialogLabel)` | AlertDialog sin semanticLabel | los 17 AlertDialog del producto | accesibilidad | Android, Windows y Linux (no iOS/macOS) |
| F03 | Dismiss | `material/dialog.dart:1680 (modalBarrierDismissLabel)` | barrera de showDialog | las 19 llamadas a showDialog | accesibilidad | todas |
| F04 | Scrim | `material/bottom_sheet.dart:1271 (scrimLabel)` | barrera de showModalBottomSheet | las 7 hojas modales (detalle del contenedor y de la reserva, tablas de pendientes, selector de OR, confirmación del arrastre) | accesibilidad | todas |
| F05 | Close Bottom Sheet | `material/bottom_sheet.dart:1272 (scrimOnTapHint + bottomSheetLabel)` | barrera de showModalBottomSheet | las mismas 7 hojas | accesibilidad | todas |
| F06 | Popup menu | `material/popup_menu.dart:1203 (popupMenuLabel)` | menú de PopupMenuButton | Exportar viaje, Acciones del Bay Plan compacto, Agregar un nivel (los tres botones traen tooltip propio) | accesibilidad | todas |
| F07 | Delete | `material/chip.dart:1307-1308 (deleteButtonTooltip)` | InputChip con onDeleted sin deleteButtonTooltipMessage | Parámetros del buque: niveles (vessel_geometry_page.dart:778) y tomas (:505) | tooltip y accesibilidad | todas |
| F08 | Tab 1 of 3 (Tab N of M) | `material/tabs.dart:1970 (tabLabel)` | TabBar | pestañas Lista / Bay Plan / Estadísticas y las de Comparar BAPLIE | accesibilidad | todas |
| F09 | N characters remaining | `material/text_field.dart:1243 (remainingTextFieldCharacterCount)` | TextField con maxLength | los cuatro campos de motivo con 300 caracteres (arrastre, oficina, solicitud, decisión); el contador visible «0/300» es numérico | accesibilidad | todas |
| F10 | Expanded / Collapsed | `material/expansion_tile.dart:533-534 (expandedHint, collapsedHint; se anuncia al abrir o cerrar)` | ExpansionTile | Celdas reservadas, Frontera y anclas, Tomas de reefer, secciones del cruce y Filas del listado | accesibilidad | todas (las pistas «double tap…» de :597-598 son solo de iOS y macOS) |
| F11 | Expand for more details / Collapse | `material/expansion_tile.dart:590-591` | ExpansionTile | los mismos cinco | accesibilidad | todas |
| F12 | Cut / Copy / Paste / Select all | `material/adaptive_text_selection_toolbar.dart:221-224` | barra de selección de texto | todos los TextField y TextFormField, los SelectableText (detalle de avisos, cancelados, etiquetas de Estadísticas) y la SelectionArea de la Política | pantalla | Android y Windows; en la Web los campos usan el menú del navegador (widgets/editable_text.dart:2511) |
| F13 | Look Up / Search Web / Share | `material/adaptive_text_selection_toolbar.dart:226-228` | barra de selección de texto | los mismos campos, según lo que ofrezca el sistema | pantalla | Android |
| F14 | Select date | `material/date_picker.dart:724 (datePickerHelpText)` | showDatePicker sin helpText | botón «Fecha» del diálogo Confirmar carga (loading_controls.dart:660) | pantalla | todas |
| F15 | Cancel / OK | `material/date_picker.dart:615 y :622` | showDatePicker sin cancelText ni confirmText | el mismo selector | pantalla | todas |
| F16 | Switch to input / Switch to calendar | `material/date_picker.dart:698 y :711` | showDatePicker | el mismo selector | tooltip | todas |
| F17 | Enter Date / mm/dd/yyyy | `material/input_date_picker_form_field.dart:273-274` | showDatePicker en modo texto | el mismo selector (formato de EE. UU., distinto del «día/mes/año» que muestra el diálogo) | pantalla | todas |
| F18 | Invalid format. / Out of range. | `material/input_date_picker_form_field.dart:232-234` | showDatePicker en modo texto | el mismo selector | pantalla | todas |
| F19 | Previous month / Next month / Select year | `material/calendar_date_picker.dart:874-889 y :489` | showDatePicker | el mismo selector | tooltip y accesibilidad | todas |
| F20 | January … December; S M T W T F S; «Tue, Oct 20»; «October 2026» | `material/material_localizations.dart (_months, _narrowWeekdays, formatMediumDate, formatMonthYear)` | showDatePicker | el mismo selector | pantalla | todas |

**«Back» (F01)** es lo que el Honor devolvió en Alertas, Recientes y Parámetros: el tooltip y la
etiqueta semántica del `BackButton` automático. Aparece en las 15 rutas que no traen `leading` propio.
Las dos que sí lo traen no lo muestran: Parámetros del buque (`IconButton` «Cancelar») y el buscador
(`IconButton` «Volver»). Estos textos no se arreglan con texto: hace falta declarar la localización en
español, que cambia `pubspec.yaml` y `lib/core/app.dart`. Queda anotado; no se corrige (10.73).

### 3.6 Préstamos y abreviaturas que no se cuentan como inglés

#### Tabla I-6 · Préstamos y abreviaturas que se cuentan como no inglés

| Archivo:línea | Canal | Texto | Palabra |
|---|---|---|---|
| `lib/core/constants/privacy_policy.dart:113` | pantalla | En Windows, desinstalar puede dejar en tu carpeta de usuario los datos de BayStream y la copia de Firebase. Para quitarlos, cierra sesión antes de desinstalar y borra las carpetas `AppData\\Local\\BayStream` y `AppData\\Local\\firestore\\[DEFAULT]\\baystream-app`. | app (préstamo de uso común) |
| `data/repositories/local_only_operation_sync.dart:18` | pantalla | Esta compilación no tiene la nube configurada: la app trabaja en un solo dispositivo. | app (préstamo de uso común) |
| `presentation/pages/cloud_page.dart:80` | pantalla | Esta compilación no tiene la nube configurada: la app trabaja en un solo dispositivo. | app (préstamo de uso común) |
| `presentation/pages/cloud_page.dart:107` | pantalla | Sin cuenta, lo que registres se queda en este dispositivo. Las cuentas las crea el responsable: la app no tiene registro. | app (préstamo de uso común) |
| `presentation/providers/vessel_providers.dart:760` | pantalla | N/A | N/A (sigla o código) |
| `presentation/widgets/bay_plan_view.dart:500` | pantalla | N/A | N/A (sigla o código) |
| `presentation/widgets/bay_plan_view.dart:501` | pantalla | N/A | N/A (sigla o código) |
| `presentation/widgets/bay_plan_view.dart:511` | pantalla | N/A | N/A (sigla o código) |
| `presentation/widgets/bay_plan_view.dart:512` | pantalla | N/A | N/A (sigla o código) |
| `presentation/widgets/containers_list_view.dart:368` | pantalla | N/A | N/A (sigla o código) |
| `presentation/widgets/containers_list_view.dart:449` | pantalla | N/A | N/A (sigla o código) |
| `presentation/widgets/containers_list_view.dart:450` | pantalla | N/A | N/A (sigla o código) |
| `presentation/widgets/containers_list_view.dart:461` | pantalla | N/A | N/A (sigla o código) |
| `presentation/widgets/containers_list_view.dart:462` | pantalla | N/A | N/A (sigla o código) |
| `presentation/widgets/containers_list_view.dart:481` | pantalla | N/A | N/A (sigla o código) |
| `presentation/widgets/containers_list_view.dart:482` | pantalla | N/A | N/A (sigla o código) |
| `presentation/widgets/containers_list_view.dart:505` | pantalla | N/A | N/A (sigla o código) |
| `presentation/widgets/plan_drag_confirmation.dart:113` | accesibilidad | Zoom del plano | Zoom (préstamo de uso común) |
| `presentation/widgets/plan_drag_confirmation.dart:129` | accesibilidad | Restablecer zoom del plano | zoom (préstamo de uso común) |
| `presentation/widgets/plan_drag_confirmation.dart:139` | accesibilidad | Cerrar controles de zoom | zoom (préstamo de uso común) |
| `presentation/widgets/voyage_summary_card.dart:221` | pantalla | N/A | N/A (sigla o código) |

«app» (Fundéu la admite como abreviación de «aplicación») y «zoom» (la forma española es «zum») se
cuentan como préstamos de uso común. «N/A» se lee en español como «no aplica»; en estas filas
significa «no disponible», y el PDF del propio producto usa «N/D». Si Codex los cuenta como inglés, la
lista los da por fila.

### 3.7 Lo que el criterio no deja aplicar tal cual

1. **Lo que no tiene idioma.** T-63 define la métrica como «cadenas en español / cadenas visibles»,
   pero no dice qué hacer con siglas del estándar (BAPLIE, IMO, OOG, VGM, POD, TEU), nombres
   (BayStream, Firebase), unidades ni códigos. Por eso se informan dos lecturas (tabla I-8). El
   umbral es «español», es decir el 100 %: el dictamen no cambia con la lectura.
2. **Términos del sector en inglés.** «Bay Plan», «Reefer» y las siglas que vienen del inglés (OOG,
   POD, POL, TEU, VGM, DG) se usan en los puertos de habla hispana, y algunas los usa el propio ERS.
   El criterio no los distingue. Aquí, las siglas del estándar cuentan como «sin idioma» y las
   palabras inglesas completas, como inglés.
3. **Textos que no están en `lib/`.** El criterio pide el inventario de las cadenas visibles «de
   `lib/`». Los textos de Flutter no son cadenas de `lib/`, pero la instrucción de 10.92 pide incluir
   «Back». Se cuentan aparte, por grupo (tabla I-7), y se suman en dos filas de la métrica.
4. **¿El PDF y el CSV son «interfaz»?** El ERS dice «Idioma de interfaz». El PDF y el CSV son
   documentos que genera la app. Se informan las dos cosas, con y sin ellos.
5. **El recorrido de las rutas de error** que pide T-63 es dinámico. Este censo lo cubre por lectura:
   en el censo 3 cada mensaje lleva su ruta hasta la pantalla. Provocar los fallos no se hizo, y le
   corresponde a Codex.

## 4. Censo 2 · Material 3 (RNF-002, decisión 2.4 a)

### 4.1 Del candidato al denominador

#### Tabla M-1 · Del candidato al denominador

| Paso | Cantidad |
|---|---:|
| Candidatos de `tool/t98_inventario.py` en todo lib/ | 210 |
| · en archivos que no llegan al producto (H5 y matriz de segregación) | 8 |
| · en las rutas del producto | 202 |
| Constructores que su patrón no encuentra (argumento de tipo o nombre no buscado) | 31 |
| Controles implícitos del framework | 16 |
| Excluidos: rejilla | 6 |
| Excluidos: no interactivos | 6 |
| **Denominador (controles interactivos)** | **237** |
| **Excepciones** | **1** |

Por qué no coincide con los 210 candidatos de Codex (210 − 8 − 6 − 5 − 1 + 31 + 16 = 237):

- **8** están en archivos que no llegan al producto.
- **6** son de la rejilla (4.2).
- **5** `ListTile` no son un control por sí mismos: tres van dentro de un `PopupMenuItem`, que es el
  control, y dos son filas sin `onTap` en Comparar.
- **1** no es un control: `FilledButton.styleFrom(` (`empty_state_widget.dart:98`), que el patrón
  `FilledButton(?:\.\w+)?\(` toma por un constructor.
- **31** controles no entran en sus candidatos, por dos motivos. Su patrón no admite argumentos de tipo
  (`PopupMenuButton<VoyageExportFormat>(`, `DropdownButton<int>(`, `DragTarget<_PlanDrag>(`…). Y no
  busca `ExpansionTile`, `DropdownButtonFormField`, `PopupMenuItem` ni `SnackBarAction`.
- Se suman **16** controles implícitos que construye el framework: el botón de volver de 14
  pantallas, el campo del buscador y el selector de fecha.

Los 12 excluidos están en la tabla M-4, cada uno con su motivo. En M-1, los cinco `ListTile` y la
fábrica de estilo van juntos como «no interactivos».

La unidad es la aparición de un constructor en el código, asignada a la pantalla donde se ve, como
cuenta `t98_inventario.py`. Los 10 elementos de la leyenda del plano son un solo `InkWell`.

### 4.2 La rejilla, excluida, y por qué

Las celdas de la bahía (`_ContainerCell`, `_ReservedCell`, `LoadingCell` y `PlanDragCell`, con sus
`GestureDetector`, `LongPressDraggable` y `DragTarget`) son la visualización del dominio. Material 3
no tiene un componente equivalente (2.4 a). Se excluyen por eso, no por su resultado. Por el
resultado tampoco cumplirían: tres de las cuatro celdas reciben los gestos con widgets que no son de
Material (`GestureDetector`, `LongPressDraggable`, `DragTarget`). Además, el borde de vista previa del
arrastre cambia el matiz del `primary` del esquema (HSL 45 y 140, `plan_drag_confirmation.dart:274-275`).

**Sus controles externos sí cuentan:** las flechas y los chips de bahía, el botón de tapas, la
leyenda, los controles de zoom (dentro de un `Material` con `surfaceContainerLow`), el modo de vista,
los botones del encabezado y las hojas de detalle.

### 4.3 Por pantalla

#### Tabla M-2 · Controles por pantalla

| Pantalla | Controles | Material | Color del esquema o del tema | Excepciones |
|---|---:|---:|---:|---:|
| S01 · Inicio y viaje: barra superior, pestañas y Lista (VesselOverviewPage) | 41 | 41 | 41 | 0 |
| S02 · Bay Plan (pestaña): encabezado, selector de bahías, leyenda, zoom y hojas de detalle | 73 | 73 | 73 | 0 |
| S03 · Estadísticas (pestaña) | 4 | 4 | 4 | 0 |
| S04 · Buscar contenedor (SearchDelegate) | 6 | 6 | 5 | 1 |
| S05 · Viajes recientes | 7 | 7 | 7 | 0 |
| S06 · Perfiles guardados | 3 | 3 | 3 | 0 |
| S07 · Parámetros | 4 | 4 | 4 | 0 |
| S08 · Política de privacidad | 1 | 1 | 1 | 0 |
| S09 · Parámetros del buque (geometría) | 27 | 27 | 27 | 0 |
| S10 · Tapas de escotilla | 12 | 12 | 12 | 0 |
| S11 · Alertas de estiba | 3 | 3 | 3 | 0 |
| S12 · Listado de la agencia | 12 | 12 | 12 | 0 |
| S13 · BAPLIE de salida | 4 | 4 | 4 | 0 |
| S14 · Comparar BAPLIE | 3 | 3 | 3 | 0 |
| S15 · Orden de descarga | 2 | 2 | 2 | 0 |
| S16 · Avance de la operación | 4 | 4 | 4 | 0 |
| S17 · Tapas en la operación | 6 | 6 | 6 | 0 |
| S18 · Solicitudes de cambio, Bandeja y formulario Pedir cambio / Mover | 15 | 15 | 15 | 0 |
| S19 · Nube y cuenta | 14 | 14 | 14 | 0 |

Un constructor que se ve en dos pantallas cuenta en las dos filas; el total del denominador lo cuenta una vez.

### 4.4 La excepción y las observaciones

**Excepción (1):** `container_search_delegate.dart:347`, el `ListTile` de cada resultado del
buscador. Su `leading` (`_buildLeadingIcon`, líneas 428-437) pinta el avatar con `Colors.red`
(peligrosa), `Colors.cyan` (refrigerado), `Colors.green` (lleno) y `Colors.orange` (vacío). El texto
que coincide con la búsqueda se resalta con `Colors.yellow.withValues(alpha: 0.4)`
(`_buildHighlightedText`, línea 470). Además va contra la regla monocromática de `AGENTS.md`.

**Comprobación de que no hay otra.** La regla automática lee el tramo de cada constructor y no entra
en métodos auxiliares. Por eso se buscaron todos los `Colors.*` y `Color(0x…)` de `lib/` del producto.
Fuera del PDF (que usa `PdfColors`) solo aparecen la semilla del tema (`app.dart:20` y `:31`), el
buscador, Estadísticas y un `Colors.transparent`.

**Observaciones que no se cuentan como excepción** (están en la columna «Nota» de M-3):

- `vessel_profile_view.dart:165`: el `InkWell` de cada bahía del perfil va dentro de
  `Material(color: Colors.transparent)`. Transparente no aporta color; el que se ve lo pinta
  `VesselProfilePainter` con colores del esquema. Si Codex cuenta el transparente como color fijo, la
  excepción sería una más.
- `stowage_alerts_page.dart:73`: la tarjeta de cada alerta mezcla dos colores del esquema
  (`Color.alphaBlend(colors.primary…, colors.surface)`).
- **Fuera del denominador.** Estadísticas usa colores fijos (`Colors.indigo`, `teal`, `blue`,
  `deepPurple`, `orange`, `green`, `amber`, `cyan`, `red`, `deepOrange`, `grey`, `purple`, `white`) en
  tarjetas, gráficos y leyendas que no son controles. Por la decisión 2.4 a no cuentan, pero también
  van contra la regla de colores de `AGENTS.md`.

### 4.5 Lista completa

#### Tabla M-3 · Lista completa de controles

| # | Pantalla | Archivo:línea | Control | Origen | Material | Color | Excepción | Nota |
|---|---|---|---|---|---|---|---|---|
| C001 | S01 | `presentation/pages/departure_baplie_page.dart:31` | TextButton.icon | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C002 | S01 | `presentation/pages/vessel_overview_page.dart:100` | IconButton | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C003 | S01 | `presentation/pages/vessel_overview_page.dart:107` | PopupMenuButton | agregado | sí | sí: tema (sin color propio) | no |  |
| C004 | S01 | `presentation/pages/vessel_overview_page.dart:113` | PopupMenuItem | agregado | sí | sí: tema (sin color propio) | no |  |
| C005 | S01 | `presentation/pages/vessel_overview_page.dart:121` | PopupMenuItem | agregado | sí | sí: tema (sin color propio) | no |  |
| C006 | S01 | `presentation/pages/vessel_overview_page.dart:129` | PopupMenuItem | agregado | sí | sí: tema (sin color propio) | no |  |
| C007 | S01 | `presentation/pages/vessel_overview_page.dart:140` | IconButton | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C008 | S01 | `presentation/pages/vessel_overview_page.dart:151` | IconButton | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C009 | S01 | `presentation/pages/vessel_overview_page.dart:158` | IconButton | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C010 | S01 | `presentation/pages/vessel_overview_page.dart:193` | IconButton | candidato Codex | sí | sí: esquema | no |  |
| C011 | S01 | `presentation/pages/vessel_overview_page.dart:212` | TabBar | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C012 | S01 | `presentation/pages/vessel_overview_page.dart:257` | FilledButton.icon | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C013 | S01 | `presentation/pages/vessel_overview_page.dart:296` | FloatingActionButton.extended | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C014 | S01 | `presentation/pages/vessel_overview_page.dart:427` | ListTile | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C015 | S01 | `presentation/pages/vessel_overview_page.dart:435` | TextButton | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C016 | S01 | `presentation/pages/vessel_overview_page.dart:438` | TextButton | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C017 | S01 | `presentation/pages/vessel_overview_page.dart:495` | ListTile | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C018 | S01 | `presentation/pages/vessel_overview_page.dart:500` | ListTile | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C019 | S01 | `presentation/pages/vessel_overview_page.dart:508` | TextButton | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C020 | S01 | `presentation/pages/vessel_overview_page.dart:566` | TextButton | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C021 | S01 | `presentation/pages/vessel_overview_page.dart:569` | FilledButton | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C022 | S01 | `presentation/pages/vessel_overview_page.dart:648` | TextButton | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C023 | S01 | `presentation/pages/vessel_overview_page.dart:651` | TextButton | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C024 | S01 | `presentation/pages/vessel_overview_page.dart:655` | FilledButton | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C025 | S01 | `presentation/pages/vessel_overview_page.dart:722` | TextButton.icon | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C026 | S01 | `presentation/pages/vessel_overview_page.dart:728` | TextButton.icon | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C027 | S01 | `presentation/pages/vessel_overview_page.dart:737` | TextButton.icon | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C028 | S01 | `presentation/pages/vessel_overview_page.dart:758` | TextButton.icon | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C029 | S01 | `presentation/pages/vessel_overview_page.dart:77` | IconButton | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C030 | S01 | `presentation/pages/vessel_overview_page.dart:788` | FilterChip | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C031 | S01 | `presentation/pages/vessel_overview_page.dart:803` | FilterChip | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C032 | S01 | `presentation/pages/vessel_overview_page.dart:89` | IconButton | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C033 | S01 | `presentation/widgets/containers_list_view.dart:514` | OutlinedButton | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C034 | S01 | `presentation/widgets/containers_list_view.dart:59` | InkWell | candidato Codex | sí | sí: typeColor y statusColor salen de _getTypeColor y _getStatusColor con colorScheme (líneas 349-387); borde outlineVariant | no |  |
| C035 | S01 | `presentation/widgets/reserved_slots_list_view.dart:15` | ExpansionTile | agregado | sí | sí: esquema | no |  |
| C036 | S01 | `presentation/widgets/reserved_slots_list_view.dart:22` | ListTile | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C037 | S01 | `presentation/widgets/sync_status_chip.dart:105` | IconButton | candidato Codex | sí | sí: esquema | no |  |
| C038 | S01 | `presentation/widgets/voyage_summary_card.dart:345` | InkWell | candidato Codex | sí | sí: esquema | no | dentro de Material(color: scheme.errorContainer) |
| C039 | S01 | `presentation/widgets/voyage_summary_card.dart:366` | TextButton | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C040 | S01+S02 | `presentation/widgets/reserved_slot_details.dart:125` | OutlinedButton | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C041 | S01+S05 | `presentation/widgets/empty_state_widget.dart:94` | FilledButton.icon | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C042 | S02 | `(framework) loading_controls.dart:660` | Selector de fecha de showDatePicker (botones y calendario del framework) | implícito | sí | sí: tema (sin color propio) | no | lo construye el framework |
| C043 | S02 | `presentation/pages/change_requests_page.dart:42` | TextButton.icon | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C044 | S02 | `presentation/widgets/bay_plan_view.dart:232` | IconButton | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C045 | S02 | `presentation/widgets/bay_plan_view.dart:245` | IconButton | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C046 | S02 | `presentation/widgets/bay_plan_view.dart:270` | FilterChip | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C047 | S02 | `presentation/widgets/bay_plan_view.dart:303` | IconButton | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C048 | S02 | `presentation/widgets/bay_plan_view.dart:396` | InkWell | candidato Codex | sí | sí: color recibido del llamador: scheme.secondaryContainer, surfaceContainerHighest, errorContainer, primaryContainer, tertiaryContainer,… | no |  |
| C049 | S02 | `presentation/widgets/bay_plan_view.dart:565` | OutlinedButton | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C050 | S02 | `presentation/widgets/discharge_controls.dart:123` | TextButton | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C051 | S02 | `presentation/widgets/discharge_controls.dart:200` | SnackBarAction | agregado | sí | sí: tema (sin color propio) | no |  |
| C052 | S02 | `presentation/widgets/discharge_controls.dart:300` | FilledButton.tonal | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C053 | S02 | `presentation/widgets/discharge_controls.dart:307` | TextField | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C054 | S02 | `presentation/widgets/discharge_controls.dart:316` | TextButton | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C055 | S02 | `presentation/widgets/discharge_controls.dart:319` | TextButton | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C056 | S02 | `presentation/widgets/discharge_controls.dart:380` | OutlinedButton.icon | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C057 | S02 | `presentation/widgets/hatch_operation_controls.dart:23` | TextButton | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C058 | S02 | `presentation/widgets/hatch_operation_controls.dart:26` | TextButton | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C059 | S02 | `presentation/widgets/hatch_operation_controls.dart:30` | FilledButton | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C060 | S02 | `presentation/widgets/loading_controls.dart:100` | TextButton.icon | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C061 | S02 | `presentation/widgets/loading_controls.dart:149` | InkWell | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C062 | S02 | `presentation/widgets/loading_controls.dart:181` | InkWell | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C063 | S02 | `presentation/widgets/loading_controls.dart:189` | InkWell | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C064 | S02 | `presentation/widgets/loading_controls.dart:305` | ListTile | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C065 | S02 | `presentation/widgets/loading_controls.dart:326` | TextButton | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C066 | S02 | `presentation/widgets/loading_controls.dart:473` | SnackBarAction | agregado | sí | sí: tema (sin color propio) | no |  |
| C067 | S02 | `presentation/widgets/loading_controls.dart:548` | DropdownButtonFormField | agregado | sí | sí: tema (sin color propio) | no |  |
| C068 | S02 | `presentation/widgets/loading_controls.dart:573` | TextField | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C069 | S02 | `presentation/widgets/loading_controls.dart:591` | DropdownButtonFormField | agregado | sí | sí: tema (sin color propio) | no |  |
| C070 | S02 | `presentation/widgets/loading_controls.dart:620` | SwitchListTile | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C071 | S02 | `presentation/widgets/loading_controls.dart:648` | TextField | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C072 | S02 | `presentation/widgets/loading_controls.dart:656` | TextButton | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C073 | S02 | `presentation/widgets/loading_controls.dart:671` | TextField | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C074 | S02 | `presentation/widgets/loading_controls.dart:678` | TextField | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C075 | S02 | `presentation/widgets/loading_controls.dart:707` | TextButton | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C076 | S02 | `presentation/widgets/loading_controls.dart:714` | TextButton | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C077 | S02 | `presentation/widgets/loading_controls.dart:717` | FilledButton | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C078 | S02 | `presentation/widgets/loading_controls.dart:79` | TextButton.icon | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C079 | S02 | `presentation/widgets/loading_controls.dart:843` | TextButton | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C080 | S02 | `presentation/widgets/loading_controls.dart:851` | TextButton | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C081 | S02 | `presentation/widgets/loading_controls.dart:876` | TextButton | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C082 | S02 | `presentation/widgets/loading_controls.dart:895` | TextButton | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C083 | S02 | `presentation/widgets/loading_plan_controls.dart:120` | DropdownButton | agregado | sí | sí: tema (sin color propio) | no |  |
| C084 | S02 | `presentation/widgets/loading_plan_controls.dart:171` | TextButton | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C085 | S02 | `presentation/widgets/loading_plan_controls.dart:268` | TextButton | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C086 | S02 | `presentation/widgets/loading_plan_controls.dart:327` | PopupMenuButton | agregado | sí | sí: esquema | no |  |
| C087 | S02 | `presentation/widgets/loading_plan_controls.dart:333` | PopupMenuItem | agregado | sí | sí: tema (sin color propio) | no |  |
| C088 | S02 | `presentation/widgets/loading_plan_controls.dart:345` | PopupMenuItem | agregado | sí | sí: tema (sin color propio) | no |  |
| C089 | S02 | `presentation/widgets/loading_plan_controls.dart:350` | PopupMenuItem | agregado | sí | sí: tema (sin color propio) | no |  |
| C090 | S02 | `presentation/widgets/loading_plan_controls.dart:358` | PopupMenuItem | agregado | sí | sí: tema (sin color propio) | no |  |
| C091 | S02 | `presentation/widgets/loading_plan_controls.dart:385` | IconButton | candidato Codex | sí | sí: esquema | no |  |
| C092 | S02 | `presentation/widgets/loading_plan_controls.dart:86` | TextButton.icon | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C093 | S02 | `presentation/widgets/loading_plan_controls.dart:93` | TextButton.icon | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C094 | S02 | `presentation/widgets/loading_plan_controls.dart:99` | TextButton.icon | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C095 | S02 | `presentation/widgets/office_plan_controls.dart:126` | TextField | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C096 | S02 | `presentation/widgets/office_plan_controls.dart:136` | TextButton | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C097 | S02 | `presentation/widgets/office_plan_controls.dart:139` | FilledButton | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C098 | S02 | `presentation/widgets/office_plan_controls.dart:80` | TextButton | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C099 | S02 | `presentation/widgets/office_plan_controls.dart:87` | TextButton | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C100 | S02 | `presentation/widgets/office_plan_controls.dart:93` | TextButton | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C101 | S02 | `presentation/widgets/plan_drag_confirmation.dart:114` | TextButton | candidato Codex | sí | sí: tema (sin color propio) | no | dentro de Material(color: colorScheme.surfaceContainerLow) |
| C102 | S02 | `presentation/widgets/plan_drag_confirmation.dart:119` | IconButton | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C103 | S02 | `presentation/widgets/plan_drag_confirmation.dart:125` | TextButton | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C104 | S02 | `presentation/widgets/plan_drag_confirmation.dart:131` | IconButton | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C105 | S02 | `presentation/widgets/plan_drag_confirmation.dart:137` | IconButton | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C106 | S02 | `presentation/widgets/plan_drag_confirmation.dart:441` | TextField | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C107 | S02 | `presentation/widgets/plan_drag_confirmation.dart:457` | ActionChip | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C108 | S02 | `presentation/widgets/plan_drag_confirmation.dart:471` | TextButton | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C109 | S02 | `presentation/widgets/plan_drag_confirmation.dart:474` | FilledButton | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C110 | S02 | `presentation/widgets/voice_search_field.dart:146` | TextField | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C111 | S02 | `presentation/widgets/voice_search_field.dart:159` | IconButton | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C112 | S02 | `presentation/widgets/voice_search_field.dart:174` | TextButton.icon | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C113 | S02+S16+S18 | `presentation/widgets/sync_status_chip.dart:84` | ActionChip | candidato Codex | sí | sí: esquema | no |  |
| C114 | S03 | `presentation/widgets/vessel_profile_view.dart:165` | InkWell | candidato Codex | sí | sí: tema (sin color propio) | no | Material(color: Colors.transparent) solo deja ver el pintor, que usa colores del esquema (baseColor, lowColor, outlineColor); transparente no aporta color |
| C115 | S03 | `presentation/widgets/vessel_profile_view.dart:85` | SegmentedButton | agregado | sí | sí: tema (sin color propio) | no |  |
| C116 | S03 | `presentation/widgets/voyage_stats_view.dart:891` | TextButton | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C117 | S03 | `presentation/widgets/voyage_stats_view.dart:905` | InkWell | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C118 | S04 | `(framework) container_search_delegate.dart:22` | Campo de búsqueda de SearchDelegate (tema de appBarTheme con colorScheme) | implícito | sí | sí: tema (sin color propio) | no | lo construye el framework |
| C119 | S04 | `presentation/widgets/container_search_delegate.dart:202` | ActionChip | candidato Codex | sí | sí: esquema | no |  |
| C120 | S04 | `presentation/widgets/container_search_delegate.dart:235` | ActionChip | candidato Codex | sí | sí: esquema | no |  |
| C121 | S04 | `presentation/widgets/container_search_delegate.dart:347` | ListTile | candidato Codex | sí | no: leading: _buildLeadingIcon usa Colors.red, Colors.cyan, Colors.green y Colors.orange (líneas 428-437) para el avatar; _buildHighlight… | sí |  |
| C122 | S04 | `presentation/widgets/container_search_delegate.dart:40` | IconButton | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C123 | S04 | `presentation/widgets/container_search_delegate.dart:53` | IconButton | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C124 | S05 | `(framework) recent_voyages_page.dart:78` | BackButton de AppBar | implícito | sí | sí: tema (sin color propio) | no | lo construye el framework |
| C125 | S05 | `presentation/pages/recent_voyages_page.dart:105` | ListTile | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C126 | S05 | `presentation/pages/recent_voyages_page.dart:114` | IconButton | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C127 | S05 | `presentation/pages/recent_voyages_page.dart:56` | TextButton | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C128 | S05 | `presentation/pages/recent_voyages_page.dart:59` | FilledButton | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C129 | S05 | `presentation/pages/recent_voyages_page.dart:95` | TextButton | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C130 | S06 | `(framework) vessel_profiles_page.dart:15` | BackButton de AppBar | implícito | sí | sí: tema (sin color propio) | no | lo construye el framework |
| C131 | S06 | `presentation/pages/vessel_profiles_page.dart:21` | TextButton | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C132 | S06 | `presentation/pages/vessel_profiles_page.dart:32` | ListTile | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C133 | S07 | `(framework) parameters_page.dart:18` | BackButton de AppBar | implícito | sí | sí: tema (sin color propio) | no | lo construye el framework |
| C134 | S07 | `presentation/pages/parameters_page.dart:22` | DropdownButtonFormField | agregado | sí | sí: esquema | no |  |
| C135 | S07 | `presentation/pages/parameters_page.dart:53` | ListTile | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C136 | S07 | `presentation/pages/parameters_page.dart:62` | ListTile | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C137 | S08 | `(framework) privacy_policy_page.dart:22` | BackButton de AppBar | implícito | sí | sí: tema (sin color propio) | no | lo construye el framework |
| C138 | S09 | `presentation/pages/vessel_geometry_page.dart:1016` | TextFormField | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C139 | S09 | `presentation/pages/vessel_geometry_page.dart:1037` | CheckboxListTile | candidato Codex | sí | sí: esquema | no |  |
| C140 | S09 | `presentation/pages/vessel_geometry_page.dart:275` | IconButton | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C141 | S09 | `presentation/pages/vessel_geometry_page.dart:304` | ExpansionTile | agregado | sí | sí: tema (sin color propio) | no |  |
| C142 | S09 | `presentation/pages/vessel_geometry_page.dart:397` | OutlinedButton.icon | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C143 | S09 | `presentation/pages/vessel_geometry_page.dart:410` | FilledButton.icon | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C144 | S09 | `presentation/pages/vessel_geometry_page.dart:417` | TextButton | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C145 | S09 | `presentation/pages/vessel_geometry_page.dart:439` | TextFormField | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C146 | S09 | `presentation/pages/vessel_geometry_page.dart:454` | ExpansionTile | agregado | sí | sí: tema (sin color propio) | no |  |
| C147 | S09 | `presentation/pages/vessel_geometry_page.dart:480` | OutlinedButton.icon | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C148 | S09 | `presentation/pages/vessel_geometry_page.dart:483` | OutlinedButton.icon | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C149 | S09 | `presentation/pages/vessel_geometry_page.dart:488` | TextField | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C150 | S09 | `presentation/pages/vessel_geometry_page.dart:495` | OutlinedButton.icon | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C151 | S09 | `presentation/pages/vessel_geometry_page.dart:505` | InputChip | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C152 | S09 | `presentation/pages/vessel_geometry_page.dart:509` | TextField | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C153 | S09 | `presentation/pages/vessel_geometry_page.dart:514` | TextButton.icon | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C154 | S09 | `presentation/pages/vessel_geometry_page.dart:528` | CheckboxListTile | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C155 | S09 | `presentation/pages/vessel_geometry_page.dart:538` | TextField | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C156 | S09 | `presentation/pages/vessel_geometry_page.dart:614` | TextButton | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C157 | S09 | `presentation/pages/vessel_geometry_page.dart:616` | FilledButton | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C158 | S09 | `presentation/pages/vessel_geometry_page.dart:722` | DropdownButtonFormField | agregado | sí | sí: tema (sin color propio) | no |  |
| C159 | S09 | `presentation/pages/vessel_geometry_page.dart:778` | InputChip | candidato Codex | sí | sí: esquema | no |  |
| C160 | S09 | `presentation/pages/vessel_geometry_page.dart:792` | PopupMenuButton | agregado | sí | sí: esquema | no |  |
| C161 | S09 | `presentation/pages/vessel_geometry_page.dart:798` | PopupMenuItem | agregado | sí | sí: tema (sin color propio) | no |  |
| C162 | S09 | `presentation/pages/vessel_geometry_page.dart:853` | TextFormField | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C163 | S09 | `presentation/pages/vessel_geometry_page.dart:938` | ChoiceChip | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C164 | S09 | `presentation/pages/vessel_geometry_page.dart:951` | ChoiceChip | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C165 | S10 | `(framework) hatch_covers_page.dart:155` | BackButton de AppBar | implícito | sí | sí: tema (sin color propio) | no | lo construye el framework |
| C166 | S10 | `presentation/pages/hatch_covers_page.dart:107` | CheckboxListTile | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C167 | S10 | `presentation/pages/hatch_covers_page.dart:117` | TextButton | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C168 | S10 | `presentation/pages/hatch_covers_page.dart:120` | FilledButton | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C169 | S10 | `presentation/pages/hatch_covers_page.dart:166` | DropdownButton | agregado | sí | sí: tema (sin color propio) | no |  |
| C170 | S10 | `presentation/pages/hatch_covers_page.dart:180` | DropdownButtonFormField | agregado | sí | sí: tema (sin color propio) | no |  |
| C171 | S10 | `presentation/pages/hatch_covers_page.dart:209` | ChoiceChip | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C172 | S10 | `presentation/pages/hatch_covers_page.dart:226` | TextField | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C173 | S10 | `presentation/pages/hatch_covers_page.dart:243` | OutlinedButton | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C174 | S10 | `presentation/pages/hatch_covers_page.dart:252` | OutlinedButton.icon | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C175 | S10 | `presentation/pages/hatch_covers_page.dart:259` | FilledButton | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C176 | S10 | `presentation/pages/hatch_covers_page.dart:268` | TextButton | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C177 | S11 | `(framework) stowage_alerts_page.dart:36` | BackButton de AppBar | implícito | sí | sí: tema (sin color propio) | no | lo construye el framework |
| C178 | S11 | `presentation/pages/stowage_alerts_page.dart:73` | InkWell | candidato Codex | sí | sí: esquema | no | Card(color: Color.alphaBlend(colors.primary…, colors.surface)): mezcla de colores del esquema |
| C179 | S11 | `presentation/pages/stowage_alerts_page.dart:98` | TextButton.icon | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C180 | S12 | `(framework) export_list_import_page.dart:123` | BackButton de AppBar | implícito | sí | sí: tema (sin color propio) | no | lo construye el framework |
| C181 | S12 | `presentation/pages/export_list_import_page.dart:103` | FilledButton.icon | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C182 | S12 | `presentation/pages/export_list_import_page.dart:281` | TextField | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C183 | S12 | `presentation/pages/export_list_import_page.dart:290` | TextButton | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C184 | S12 | `presentation/pages/export_list_import_page.dart:291` | FilledButton | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C185 | S12 | `presentation/pages/export_list_import_page.dart:322` | IconButton | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C186 | S12 | `presentation/pages/export_list_import_page.dart:338` | ActionChip | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C187 | S12 | `presentation/pages/export_list_import_page.dart:343` | ActionChip | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C188 | S12 | `presentation/pages/export_list_import_page.dart:378` | ExpansionTile | agregado | sí | sí: esquema | no |  |
| C189 | S12 | `presentation/pages/export_list_import_page.dart:460` | ExpansionTile | agregado | sí | sí: esquema | no |  |
| C190 | S12 | `presentation/pages/export_list_import_page.dart:56` | FilledButton.icon | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C191 | S12 | `presentation/pages/export_list_import_page.dart:99` | OutlinedButton | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C192 | S13 | `(framework) departure_baplie_page.dart:74` | BackButton de AppBar | implícito | sí | sí: tema (sin color propio) | no | lo construye el framework |
| C193 | S13 | `presentation/pages/departure_baplie_page.dart:125` | TextButton.icon | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C194 | S13 | `presentation/pages/departure_baplie_page.dart:136` | FilledButton.icon | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C195 | S13 | `presentation/pages/departure_baplie_page.dart:145` | OutlinedButton.icon | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C196 | S14 | `(framework) voyage_comparison_page.dart:101` | BackButton de AppBar | implícito | sí | sí: tema (sin color propio) | no | lo construye el framework |
| C197 | S14 | `presentation/pages/voyage_comparison_page.dart:270` | FilterChip | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C198 | S14 | `presentation/pages/voyage_comparison_page.dart:364` | TabBar | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C199 | S15 | `(framework) discharge_sequence_page.dart:39` | BackButton de AppBar | implícito | sí | sí: tema (sin color propio) | no | lo construye el framework |
| C200 | S15 | `presentation/pages/discharge_sequence_page.dart:75` | DropdownButton | agregado | sí | sí: tema (sin color propio) | no |  |
| C201 | S16 | `(framework) operation_progress_page.dart:21` | BackButton de AppBar | implícito | sí | sí: tema (sin color propio) | no | lo construye el framework |
| C202 | S16 | `presentation/pages/operation_progress_page.dart:164` | TextButton.icon | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C203 | S16 | `presentation/pages/operation_progress_page.dart:25` | IconButton | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C204 | S17 | `(framework) hatch_operation_controls.dart:80` | BackButton de AppBar | implícito | sí | sí: tema (sin color propio) | no | lo construye el framework |
| C205 | S17 | `presentation/widgets/hatch_operation_controls.dart:141` | OutlinedButton | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C206 | S17 | `presentation/widgets/hatch_operation_controls.dart:164` | TextButton | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C207 | S17 | `presentation/widgets/hatch_operation_controls.dart:202` | TextButton | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C208 | S17 | `presentation/widgets/hatch_operation_controls.dart:68` | SnackBarAction | agregado | sí | sí: tema (sin color propio) | no |  |
| C209 | S17 | `presentation/widgets/hatch_operation_controls.dart:95` | DropdownButton | agregado | sí | sí: tema (sin color propio) | no |  |
| C210 | S18 | `(framework) change_requests_page.dart:100 y :300` | BackButton de AppBar (bandeja y formulario) | implícito | sí | sí: tema (sin color propio) | no | lo construye el framework |
| C211 | S18 | `presentation/pages/change_requests_page.dart:123` | FilledButton.icon | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C212 | S18 | `presentation/pages/change_requests_page.dart:168` | FilledButton | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C213 | S18 | `presentation/pages/change_requests_page.dart:175` | OutlinedButton | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C214 | S18 | `presentation/pages/change_requests_page.dart:307` | SwitchListTile | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C215 | S18 | `presentation/pages/change_requests_page.dart:326` | TextField | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C216 | S18 | `presentation/pages/change_requests_page.dart:339` | TextField | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C217 | S18 | `presentation/pages/change_requests_page.dart:349` | TextButton | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C218 | S18 | `presentation/pages/change_requests_page.dart:358` | TextButton | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C219 | S18 | `presentation/pages/change_requests_page.dart:375` | TextField | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C220 | S18 | `presentation/pages/change_requests_page.dart:389` | FilledButton | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C221 | S18 | `presentation/pages/change_requests_page.dart:425` | TextField | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C222 | S18 | `presentation/pages/change_requests_page.dart:436` | TextButton | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C223 | S18 | `presentation/pages/change_requests_page.dart:439` | FilledButton | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C224 | S19 | `(framework) cloud_page.dart:66` | BackButton de AppBar | implícito | sí | sí: tema (sin color propio) | no | lo construye el framework |
| C225 | S19 | `presentation/pages/cloud_page.dart:110` | TextField | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C226 | S19 | `presentation/pages/cloud_page.dart:119` | TextField | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C227 | S19 | `presentation/pages/cloud_page.dart:130` | FilledButton | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C228 | S19 | `presentation/pages/cloud_page.dart:134` | TextButton | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C229 | S19 | `presentation/pages/cloud_page.dart:151` | TextButton | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C230 | S19 | `presentation/pages/cloud_page.dart:177` | OutlinedButton | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C231 | S19 | `presentation/pages/cloud_page.dart:212` | FilledButton | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C232 | S19 | `presentation/pages/cloud_page.dart:218` | OutlinedButton | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C233 | S19 | `presentation/pages/cloud_page.dart:224` | OutlinedButton | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C234 | S19 | `presentation/pages/cloud_page.dart:269` | TextButton | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C235 | S19 | `presentation/pages/cloud_page.dart:272` | FilledButton | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C236 | S19 | `presentation/pages/cloud_page.dart:331` | FilledButton | candidato Codex | sí | sí: tema (sin color propio) | no |  |
| C237 | S19 | `presentation/pages/cloud_page.dart:342` | OutlinedButton | candidato Codex | sí | sí: tema (sin color propio) | no |  |

#### Tabla M-4 · Constructores excluidos

| Archivo:línea | Control | Motivo |
|---|---|---|
| `presentation/pages/vessel_overview_page.dart:115` | ListTile | ListTile dentro de PopupMenuItem: el control es el PopupMenuItem |
| `presentation/pages/vessel_overview_page.dart:123` | ListTile | ListTile dentro de PopupMenuItem: el control es el PopupMenuItem |
| `presentation/pages/vessel_overview_page.dart:131` | ListTile | ListTile dentro de PopupMenuItem: el control es el PopupMenuItem |
| `presentation/pages/voyage_comparison_page.dart:243` | ListTile | ListTile sin onTap (fila de la lista) |
| `presentation/pages/voyage_comparison_page.dart:298` | ListTile | ListTile sin onTap (fila de la lista) |
| `presentation/widgets/bay_plan_view.dart:1231` | GestureDetector | rejilla (2.4 a): _ReservedCell: celda reservada de la rejilla |
| `presentation/widgets/bay_plan_view.dart:1642` | GestureDetector | rejilla (2.4 a): _ContainerCell: celda de contenedor de la rejilla |
| `presentation/widgets/empty_state_widget.dart:98` | FilledButton.styleFrom | no es un control: fábrica de estilo (el patrón de Codex la cuenta) |
| `presentation/widgets/loading_controls.dart:972` | InkWell | rejilla (2.4 a): LoadingCell: celda del modo Carga en la rejilla |
| `presentation/widgets/plan_drag_confirmation.dart:215` | GestureDetector | rejilla (2.4 a): PlanDragCell: pulsación larga sin sesión sobre una celda |
| `presentation/widgets/plan_drag_confirmation.dart:220` | LongPressDraggable | rejilla (2.4 a): PlanDragCell: arrastre de una celda |
| `presentation/widgets/plan_drag_confirmation.dart:243` | DragTarget | rejilla (2.4 a): PlanDragCell: destino de arrastre de una celda |

### 4.6 Lo que el criterio no deja aplicar tal cual

1. **La unidad de conteo** (constructor en el código o elemento dibujado) no está definida. Se usó el
   constructor, como `t98_inventario.py`.
2. **Los controles que construye el framework** (botón de volver, campo del buscador, selector de
   fecha) no están en `lib/`. Se incluyeron como implícitos; los 16 cumplen, así que no cambian el
   conteo de excepciones.
3. **«Su color sale de colorScheme».** Un control sin color propio usa los del tema. Con
   `useMaterial3: true` y `ColorScheme.fromSeed` (`app.dart:17-35`), esos colores se derivan del
   esquema, así que se cuentan como conformes. El criterio no lo dice expresamente.
4. **El borde de la rejilla.** Los controles de zoom se dibujan encima de la rejilla, dentro de
   `PlanZoomViewport`. Se contaron como controles externos porque son botones de Material y no celdas.

## 5. Censo 3 · Mensajes de error (RNF-006)

### 5.1 Qué entra y qué no

**Entra** todo texto que `lib/` puede mostrar cuando algo no se pudo hacer (falla), se rechazó por
cuenta, permiso o estado (rechazo), no pasó una validación, trae datos con problemas (aviso de datos)
o deja la bitácora en conflicto. También entran los cuatro estados de envío que la app marca como
error (`syncStatusNeedsAction`) y los dos casos, en seis sitios, en que se muestra el `toString()` de
una excepción.

**Unidad:** el mensaje distinto. Si el mismo texto está escrito en varios sitios, es una fila con
todas sus líneas.

**No entra**, y se dice por qué:

- Las alertas de estiba, la segregación IMDG y el cruce del listado con el plan. Son resultados del
  análisis que la app ofrece; no informan de algo que falló. Los textos sí están en el censo de idioma.
- Los avisos que solo matizan un cálculo (Orden de descarga, Avance).
- Las confirmaciones de éxito («Exportación PDF completada»), las cancelaciones del propio usuario
  («Carga cancelada: …») y los estados («Leyendo…», «No hay solicitudes»).
- Los textos que existen pero no se ven: `NV-REEMPLAZADO` y `NV-NO-MOSTRADO` de la sección 3.1.
- **Las envolturas** (tabla E-4): muestran un mensaje de la tabla sin cambiarlo, o con un prefijo que
  no agrega causa ni acción. Se listan para que se puedan revisar, pero no suman.

**Los juicios.** Causa «sí» si el mensaje dice por qué falló; «impl.» si solo se deduce de la
instrucción («Escribe un número.»); «no» si es genérico («No se pudo cerrar la sesión.»). Acción
«sí» si dice qué hacer; «impl.» si se deduce de la causa o de la regla; «no» si no la hay. Es la
misma vara que Codex usó con los seis mensajes de cuenta de su Fase B («Mensajes revisados por fuente
del cierre»), y los seis salen igual. Por ejemplo, «Sin conexión: iniciar sesión requiere red.»
queda con causa sí y acción implícita, donde Codex anotó «No explícita».

Hay dos diferencias con su tabla de la Fase A, y quedan a la vista para el dictamen:

- **«No se pudo interpretar el archivo BAPLIE…»** (M004) queda aquí con causa «no», porque es el
  genérico. Allí tenía «Parcial».
- **La versión no admitida** (M024): la Fase A dejó «UNH en excepción; comprobar texto visible en
  B». El texto visible muestra el identificador que trae S009, pero no nombra UNH ni S009. Por eso
  aquí va con segmento «no».

**El arreglo sugerido** da el texto que falta para que el mensaje diga causa y acción explícitas (la
lectura estricta) y, si es un error de lectura, el segmento. También señala los identificadores en
inglés (M050, M143). «—» quiere decir que no falta nada. Si una fila incompleta queda sin arreglo,
`t98c_mensajes.py` se detiene y no genera la tabla. Cuando no hay texto que lo resuelva, el arreglo
lo dice: invariantes del formulario, mensajes sin acción posible o fallos de causa desconocida.

### 5.2 Las métricas

#### Tabla E-1 · Métricas de los mensajes

| Medida | Cantidad | De | % |
|---|---:|---:|---:|
| Mensajes distintos | 218 | | |
| Dicen la causa (sí) | 172 | 218 | 78.9 |
| Causa solo implícita | 28 | 218 | 12.8 |
| Sin causa (genérica o ninguna) | 18 | 218 | 8.3 |
| Dicen la acción (sí) | 86 | 218 | 39.4 |
| Acción solo implícita | 32 | 218 | 14.7 |
| Sin acción | 100 | 218 | 45.9 |
| **Causa y acción explícitas (lectura estricta)** | **49** | 218 | **22.5** |
| Causa y acción, contando las implícitas | 109 | 218 | 50.0 |
| Errores de lectura de un BAPLIE que nombran el segmento | 4 | 12 | 33.3 |

#### Tabla E-2 · Por tipo de mensaje

| Tipo | Mensajes | Causa y acción explícitas | Contando implícitas |
|---|---:|---:|---:|
| validación | 70 | 9 | 48 |
| falla | 49 | 14 | 21 |
| rechazo | 44 | 18 | 26 |
| conflicto | 28 | 2 | 3 |
| aviso de datos | 21 | 5 | 9 |
| estado de error | 4 | 1 | 2 |
| no controlado | 2 | 0 | 0 |

### 5.3 Lo que falta, en resumen

- **Sin causa (18):** el genérico de errores inesperados (M001) y lo que lo envuelve (M007, M008,
  M026). El genérico de lectura del BAPLIE (M004) y el del almacén (M006). «No se pudo leer el tema»
  (M027). Los fallos de sesión y de nube con código (M034, M037, M048) o sin él (M035, M036). «No se
  abrió la fuente» (M042). «N rechazados» (M061). La bitácora (M062). «La operación no está
  disponible» (M099). Y los dos no controlados (M217, M218).
- **Con causa y sin acción (91).** Es el grupo más grande y se arregla con texto. Son 25 de los 28
  conflictos, 22 validaciones, 18 rechazos (como «Solo una cuenta de oficina autorizada publica y
  cierra operaciones.»), 13 fallas (entre ellas las del BAPLIE de salida), 12 avisos de datos y un
  estado de envío.
- **Errores de lectura sin segmento (8 de 12):** el genérico (M004), la versión no admitida (M024,
  que muestra el identificador de S009 sin nombrar UNH), la versión y los separadores del BAPLIE de
  salida (M152, M153), el aviso de la 1.5 (M180) y los avisos de pesos, posiciones y dígito de control
  (M181-M183, sin MEA, LOC ni EQD).
- **No controlados (2 filas, 6 sitios):** en cinco sitios de cuatro archivos se muestra `'$failure'`
  cuando el error no es un `StateError`: el registro de carga, el arrastre, las acciones de oficina y
  las solicitudes (dos sitios). Tapas en la operación muestra `Text('$error')` en su estado de error.
  Ahí puede salir «Instance of 'VesselOperationFailure'», el nombre de la clase de un `Failure` (en
  release, `equatable` 2.0.8 imprime solo `runtimeType`), «Bad state: …» o «FormatException: …». Son
  textos en inglés que no salen de ninguna cadena de `lib/`.

**Para la decisión de 10.92 (punto 2)**, sin dictamen. La mayoría de los arreglos sugeridos son de
texto: agregar la acción, o la causa, a un literal que ya existe. Seis piden además código:

- M001 y M006: que quien llama diga qué operación falló.
- M004: usar `segment` y `lineNumber`, que `BaplieParsingFailure` ya trae.
- M050: nombrar la fuente en español en lugar de `kind.wire`.
- M217 y M218: usar `vesselErrorMessage` en lugar de `'$failure'` y `'$error'`.

Los textos de Flutter del censo 1 tampoco se arreglan con texto.

### 5.4 Inventario

#### Tabla E-3 · Inventario de los mensajes de error

| # | Archivo:línea | Texto como se ve | Tipo | Causa | Acción | Parseo | Segmento | Arreglo sugerido |
|---|---|---|---|---|---|---|---|---|
| | **Formateador común (vessel_error_message.dart)** | | | | | | | |
| M001 | `presentation/formatters/vessel_error_message.dart:18` | No se pudo completar la operación por un error inesperado. Inténtalo de nuevo; si persiste, reinicia la aplicación. | falla | no | sí | no | — | Que el llamador diga qué falló, como ya hacen exportar, tema y preferencia: «No se pudo {operación}.» El motivo técnico queda en el registro. |
| M002 | `presentation/formatters/vessel_error_message.dart:22` | Este archivo no parece un BAPLIE: no se reconoce su cabecera UNH/S009. Selecciona una exportación BAPLIE completa. (También con «Archivo «nombre»: » delante.) | falla | sí | sí | sí | sí | — |
| M003 | `presentation/formatters/vessel_error_message.dart:35` | El archivo no trae el nombre del buque en el segmento TDT. Revisa que sea un BAPLIE completo o pide una nueva exportación. | falla | sí | sí | sí | sí | — |
| M004 | `presentation/formatters/vessel_error_message.dart:39` | No se pudo interpretar el archivo BAPLIE. Revisa su formato o pide una nueva exportación. | falla | no | sí | sí | no | Usar el segmento y la línea que ya trae BaplieParsingFailure: «No se pudo interpretar el segmento {segmento} (línea {n}) del archivo BAPLIE. Revisa su formato o pide una nueva exportación.» |
| M005 | `presentation/formatters/vessel_error_message.dart:44` | Hay un perfil con el mismo nombre y no se puede identificar el buque. Confirma su identidad antes de guardar. | rechazo | sí | sí | no | — | — |
| M006 | `presentation/formatters/vessel_error_message.dart:48` | No se pudo acceder a los datos guardados en este dispositivo. Inténtalo de nuevo; si persiste, reinicia la aplicación. | falla | no | sí | no | — | Decir qué dato no se pudo leer o guardar: «No se pudo leer el viaje guardado…», «No se pudo guardar el perfil…». |
| | **Carga del BAPLIE, perfil y viajes (vessel_providers.dart y pantallas)** | | | | | | | |
| M007 | `presentation/pages/vessel_overview_page.dart:203` | No se pudo guardar la preferencia. No se pudo completar la operación por un error inesperado. Inténtalo de nuevo; si persiste, reinicia la aplicación. | falla | no | sí | no | — | Agregar la consecuencia: «…; la barra queda como estaba.» |
| M008 | `presentation/pages/vessel_overview_page.dart:390` | No se pudo exportar {PDF\|CSV\|JSON}. No se pudo completar la operación por un error inesperado. Inténtalo de nuevo; si persiste, reinicia la aplicación. | falla | no | sí | no | — | Si el motivo es el selector o el disco, decirlo; si no se conoce, basta lo actual más «Revisa el espacio y los permisos de la carpeta elegida.» |
| M009 | `presentation/providers/vessel_providers.dart:132` | No hay un buque nuevo confirmado para usar la plantilla. Confirma primero el buque o inicia otra carga. | rechazo | sí | sí | no | — | — |
| M010 | `presentation/providers/vessel_providers.dart:177,213,410,450,506` | Ya hay una carga en curso. Termínala o cancélala antes de abrir otra. | rechazo | sí | sí | no | — | — |
| M011 | `presentation/providers/vessel_providers.dart:260,356` | Hay una operación en curso. Espera a que termine e inténtalo de nuevo. | rechazo | sí | sí | no | — | — |
| M012 | `presentation/providers/vessel_providers.dart:265` | No hay una identidad pendiente. Carga un BAPLIE para elegir el buque. | rechazo | sí | sí | no | — | — |
| M013 | `presentation/providers/vessel_providers.dart:269` | El perfil no corresponde a este buque. Elige uno de los perfiles propuestos. | validación | sí | sí | no | — | — |
| M014 | `presentation/providers/vessel_providers.dart:274` | No se pueden distinguir estos buques solo por nombre. Pide una exportación con IMO o indicativo en el archivo. | rechazo | sí | sí | no | — | — |
| M015 | `presentation/providers/vessel_providers.dart:323,373` | Elige si este BAPLIE es de llegada o de carga. | validación | impl. | sí | no | — | Decir la causa: «Falta indicar si este BAPLIE es de llegada o de carga: elige una opción.» |
| M016 | `presentation/providers/vessel_providers.dart:359` | Confirma primero la identidad del buque. | validación | impl. | sí | no | — | «La identidad del buque está sin confirmar: confírmala primero.» |
| M017 | `presentation/providers/vessel_providers.dart:363` | No hay un viaje para confirmar. Carga un BAPLIE primero. | rechazo | sí | sí | no | — | — |
| M018 | `presentation/providers/vessel_providers.dart:366` | La geometría deja posiciones del archivo fuera del plano. Amplía las filas o niveles para incluirlas. | validación | sí | sí | no | — | — |
| M019 | `presentation/providers/vessel_providers.dart:414` | La edición de parámetros no permite cambiar la identidad del buque. Abre el perfil correcto antes de editar. | rechazo | sí | sí | no | — | — |
| M020 | `presentation/providers/vessel_providers.dart:420` | La geometría deja posiciones del viaje abierto fuera del plano. Amplía las filas o niveles para incluirlas. | validación | sí | sí | no | — | — |
| M021 | `presentation/providers/vessel_providers.dart:431` | El perfil cambió. Vuelve a abrirlo antes de editar. | rechazo | sí | sí | no | — | — |
| M022 | `presentation/providers/vessel_providers.dart:458` | El viaje ya no está guardado. Vuelve a cargar su BAPLIE. | falla | sí | sí | no | — | — |
| M023 | `presentation/providers/vessel_providers.dart:462` | Este viaje no tiene una geometría válida guardada. Vuelve a cargar el BAPLIE. | falla | sí | sí | no | — | — |
| M024 | `data/services/baplie_parser_service.dart:133` | Archivo «{nombre}»: Versión BAPLIE no admitida: {identificador S009}. BayStream lee la familia 2.x (SMDG20, SMDG21 y SMDG22). [El archivo contiene más de un mensaje.] Pide una exportación compatible. | falla | sí | sí | sí | no | Nombrar el segmento: «… la cabecera UNH declara {identificador} …». |
| M025 | `presentation/pages/recent_voyages_page.dart:35` | No se aplicó del perfil vigente: {parámetros}. Dejaría contenedores de este viaje fuera del plano; se conserva el valor guardado con el viaje. Revisa el perfil del buque. | aviso de datos | sí | sí | no | — | — |
| M026 | `presentation/pages/parameters_page.dart:38` | No se pudo guardar el tema. No se pudo completar la operación por un error inesperado. Inténtalo de nuevo; si persiste, reinicia la aplicación. | falla | no | sí | no | — | Agregar la consecuencia: «…; se mantiene el tema anterior.» |
| M027 | `presentation/pages/parameters_page.dart:48` | No se pudo leer el tema guardado. Puedes elegirlo de nuevo. | falla | no | sí | no | — | «No se pudo leer el tema guardado; se usa el del sistema. Puedes elegirlo de nuevo.» |
| M028 | `lib/main.dart:67` | Falta la configuración de Firebase · Esta versión de BayStream no tiene todas las opciones necesarias para iniciar. Solicita una compilación configurada al responsable. | falla | sí | sí | no | — | — |
| | **Cuenta y nube (Nube y cuenta)** | | | | | | | |
| M029 | `data/repositories/firebase_session_repository.dart:170` | Correo o contraseña incorrectos. | rechazo | sí | no | no | — | «Correo o contraseña incorrectos. Revísalos e inténtalo de nuevo, o usa «Olvidé mi contraseña».» |
| M030 | `data/repositories/firebase_session_repository.dart:171,199` | El correo no es válido. | validación | sí | no | no | — | «El correo no es válido: escríbelo completo, como nombre@dominio.» |
| M031 | `data/repositories/firebase_session_repository.dart:172` | Esta cuenta está deshabilitada. Habla con el responsable. | rechazo | sí | sí | no | — | — |
| M032 | `data/repositories/firebase_session_repository.dart:173` | Demasiados intentos. Espera un momento. | rechazo | sí | sí | no | — | — |
| M033 | `data/repositories/firebase_session_repository.dart:174` | Sin conexión: iniciar sesión requiere red. | falla | sí | impl. | no | — | «Sin conexión: iniciar sesión requiere red. Conéctate e inténtalo de nuevo.» |
| M034 | `data/repositories/firebase_session_repository.dart:175` | No se pudo iniciar sesión ({código de Firebase}). | falla | no | no | no | — | «No se pudo iniciar sesión (código {código}). Inténtalo de nuevo; si se repite, avisa al responsable con ese código.» |
| M035 | `data/repositories/firebase_session_repository.dart:161` | No se pudo iniciar sesión. Inténtalo de nuevo. | falla | no | sí | no | — | Si el motivo no se conoce, no hay causa que agregar; basta la acción. |
| M036 | `data/repositories/firebase_session_repository.dart:186` | No se pudo cerrar la sesión. | falla | no | no | no | — | «No se pudo cerrar la sesión. Inténtalo de nuevo.» |
| M037 | `data/repositories/firebase_session_repository.dart:200` | No se pudo enviar el correo ({código de Firebase}). | falla | no | no | no | — | «No se pudo enviar el correo (código {código}). Revisa la conexión e inténtalo de nuevo.» |
| M038 | `presentation/pages/cloud_page.dart:140` | Escribe tu correo para recuperar la contraseña. | validación | impl. | sí | no | — | «Falta el correo: escríbelo para recuperar la contraseña.» |
| M039 | `presentation/pages/cloud_page.dart:244` | Abre el plano de la escala para publicarla con su perfil de buque. | rechazo | impl. | sí | no | — | «Falta el perfil del buque: abre el plano de la escala para publicarla con su perfil.» |
| M040 | `presentation/pages/cloud_page.dart:295` | No se pudieron leer las operaciones: revisa la conexión y la cuenta. | falla | impl. | sí | no | — | «No se pudieron leer las operaciones: puede faltar la conexión o el permiso de la cuenta. Revisa la conexión y la cuenta.» |
| M041 | `presentation/pages/cloud_page.dart:374` | La operación no tiene esa fuente. | rechazo | sí | no | no | — | «La operación no tiene esa fuente. Abre otra o pide a la oficina que la publique.» |
| M042 | `presentation/pages/cloud_page.dart:386,391` | No se abrió la fuente. | falla | no | no | no | — | «No se abrió la fuente publicada. Inténtalo de nuevo.» |
| M043 | `data/repositories/firestore_operation_sync.dart:54` | Inicia sesión con una cuenta de oficina. | rechazo | impl. | sí | no | — | «Publicar y cerrar exige sesión: inicia sesión con una cuenta de oficina.» |
| M044 | `data/repositories/firestore_operation_sync.dart:59` | Solo una cuenta de oficina autorizada publica y cierra operaciones. | rechazo | sí | no | no | — | «… Inicia sesión con una cuenta de oficina autorizada.» |
| M045 | `data/repositories/firestore_operation_sync.dart:127` | Sin respuesta de la nube. Publicar requiere conexión: revisa la red e inténtalo de nuevo. | falla | sí | sí | no | — | — |
| M046 | `data/repositories/firestore_operation_sync.dart:134` | La nube no aceptó la publicación: revisa que la cuenta sea de oficina y esté activa. | rechazo | sí | sí | no | — | — |
| M047 | `data/repositories/firestore_operation_sync.dart:136` | Sin conexión con la nube. Publicar requiere red. | falla | sí | impl. | no | — | «… Conéctate e inténtalo de nuevo.» |
| M048 | `data/repositories/firestore_operation_sync.dart:137` | La nube devolvió un error ({código de Firebase}). | falla | no | no | no | — | «La nube devolvió un error (código {código}). Inténtalo de nuevo; si se repite, avisa al responsable con ese código.» |
| M049 | `data/repositories/firestore_operation_sync.dart:178` | La operación ya no está en la nube. | falla | sí | no | no | — | «… Pide a la oficina que la publique de nuevo.» |
| M050 | `data/repositories/firestore_operation_sync.dart:202` | La fuente {arrival_baplie\|loading_baplie\|export_list} llegó incompleta o distinta de la publicada. No se guardó nada: vuelve a intentarlo. | falla | sí | sí | no | — | Nombrar la fuente en español en lugar del identificador: «La fuente {plano de llegada\|plan de carga\|listado} …». |
| M051 | `data/repositories/firestore_operation_sync.dart:226` | Tu cuenta no puede leer esta operación: revisa que esté autorizada. | rechazo | sí | sí | no | — | — |
| M052 | `data/repositories/firestore_operation_sync.dart:227` | Sin conexión con la nube. Unirse requiere red. | falla | sí | impl. | no | — | «… Conéctate e inténtalo de nuevo.» |
| M053 | `data/repositories/firestore_operation_sync.dart:230` | Sin respuesta de la nube. Unirse requiere red. | falla | sí | impl. | no | — | «… Revisa la red e inténtalo de nuevo.» |
| M054 | `data/repositories/firestore_operation_sync.dart:256` | No se encontró la operación para cerrarla. | falla | sí | no | no | — | «… Puede que ya esté cerrada: revisa las operaciones abiertas.» |
| M055 | `data/repositories/firestore_operation_sync.dart:264` | Sin respuesta de la nube. Cerrar requiere red. | falla | sí | impl. | no | — | «… Revisa la red e inténtalo de nuevo.» |
| M056 | `data/repositories/local_only_operation_sync.dart:18` | Esta compilación no tiene la nube configurada: la app trabaja en un solo dispositivo. | rechazo | sí | no | no | — | «… Para sincronizar, pide al responsable una compilación con la nube.» |
| M057 | `domain/services/operation_sources.dart:52` | La operación de esta escala ya está publicada y sus fuentes no cambian. Abre la fuente publicada desde «Nube y cuenta». | rechazo | sí | sí | no | — | — |
| | **Estado de envío con error (sync_status_chip.dart: barra, Bay Plan, Avance, Solicitudes)** | | | | | | | |
| M058 | `presentation/widgets/sync_status_chip.dart:32` | Sesión vencida: inicia sesión para enviar {n} | estado de error | sí | sí | no | — | — |
| M059 | `presentation/widgets/sync_status_chip.dart:34` | Tu cuenta no está autorizada · {n} espera(n) | estado de error | sí | no | no | — | «Tu cuenta no está autorizada · {n} esperan · pide al responsable que la autorice» |
| M060 | `presentation/widgets/sync_status_chip.dart:35` | Sin confirmar desde las {hh:mm} · inicia sesión de nuevo | estado de error | impl. | sí | no | — | «Sesión sin confirmar desde las {hh:mm} · inicia sesión de nuevo» |
| M061 | `presentation/widgets/sync_status_chip.dart:38` | {n} rechazado(s) | estado de error | no | no | no | — | «{n} rechazados por la nube · abre Nube y cuenta y pulsa Reintentar». El motivo se guarda en el registro (sync_engine.dart) y ninguna pantalla lo muestra. |
| | **Registro de movimientos (bitácora y validación del borrador)** | | | | | | | |
| M062 | `data/repositories/movement_log_repository_impl.dart:46` | No se pudo acceder a la bitácora local. Inténtalo de nuevo. | falla | no | sí | no | — | Agregar la consecuencia: «… El movimiento no se registró.» |
| M063 | `domain/entities/movement.dart:325` | Este tipo de movimiento no admite corrección. | validación | sí | no | no | — | «… Anúlalo y registra uno nuevo.» |
| M064 | `domain/entities/movement.dart:331` | Falta el número de contenedor. | validación | sí | impl. | no | — | «Falta el número de contenedor: escríbelo.» |
| M065 | `domain/entities/movement.dart:334` | La posición debe tener 6 o 7 cifras (BBBRRTT). | validación | sí | impl. | no | — | «La posición debe tener 6 o 7 cifras (BBBRRTT): corrígela.» |
| M066 | `domain/entities/movement.dart:338` | Falta la celda reservada. | validación | sí | impl. | no | — | «Falta la celda reservada: elige una.» |
| M067 | `domain/entities/movement.dart:342` | Falta el número del vacío. | validación | sí | impl. | no | — | «Falta el número del vacío: elige su OR.» |
| M068 | `domain/entities/movement.dart:346` | Tara fuera de rango. | validación | sí | no | no | — | «Tara fuera de rango: debe estar entre 1 y 14 999 kg.» |
| M069 | `domain/entities/movement.dart:350` | Falta el movimiento a anular. | validación | sí | no | no | — | Invariante del formulario; no se corrige con texto. |
| M070 | `domain/entities/movement.dart:352` | Anular exige un motivo. | validación | sí | impl. | no | — | «Anular exige un motivo: escríbelo.» |
| M071 | `domain/entities/movement.dart:356` | Falta el contenedor o la reserva a cancelar. | validación | sí | no | no | — | Invariante del formulario; no se corrige con texto. |
| M072 | `domain/entities/movement.dart:359` | Cancelar exige un motivo de hasta 300 caracteres. | validación | sí | impl. | no | — | «Cancelar exige un motivo de hasta 300 caracteres: escríbelo.» |
| M073 | `domain/entities/movement.dart:363` | Un cambio lleva sus objetos en la lista. | validación | sí | no | no | — | Invariante interna (el formulario no la produce); si se ve: «Error interno del cambio; vuelve a intentarlo.» |
| M074 | `domain/entities/movement.dart:365,378` | Escribe un motivo de hasta 300 caracteres. | validación | impl. | sí | no | — | «Falta el motivo: escribe uno de hasta 300 caracteres.» |
| M075 | `domain/entities/movement.dart:375` | Falta la solicitud. | validación | sí | no | no | — | Invariante del formulario; no se corrige con texto. |
| M076 | `domain/entities/movement.dart:384` | Indica una tapa y la acción quitar o reponer. | validación | impl. | sí | no | — | «Falta la tapa o la acción: indica una tapa y la acción quitar o reponer.» |
| | **Cambios del plan (arrastre, solicitudes, oficina)** | | | | | | | |
| M077 | `domain/services/change_requests.dart:19; presentation/widgets/plan_drag_confirmation.dart:217` | Inicia sesión para mover | rechazo | impl. | sí | no | — | «Mover exige sesión: inicia sesión para mover.» |
| M078 | `domain/services/change_requests.dart:24; domain/entities/movement.dart:369` | Indica de uno a cuatro cambios válidos, sin repetir objetos ni destinos. | validación | impl. | sí | no | — | «Los cambios de la solicitud no son válidos: indica de uno a cuatro, sin repetir objetos ni destinos.» |
| M079 | `domain/services/change_requests.dart:33` | Solo se mueve un objeto pendiente del plan de carga. | rechazo | sí | no | no | — | «… Este ya se cargó o se canceló.» |
| M080 | `domain/services/change_requests.dart:43` | Las reservas del intercambio deben ser del mismo grupo. | validación | sí | impl. | no | — | «… Elige reservas del mismo grupo (tipo, POD y línea).» |
| M081 | `domain/services/change_requests.dart:65` | Solo se cancela un objeto pendiente del plan de carga. | rechazo | sí | no | no | — | «… Este ya se cargó o ya está cancelado; si se cargó, anula antes ese movimiento.» |
| M082 | `domain/services/change_requests.dart:89` | El cambio de oficina ya no está vigente. | rechazo | sí | no | no | — | «… Actualiza el detalle para ver el estado actual.» |
| M083 | `domain/services/change_requests.dart:92` | Deshacer exige un motivo de hasta 300 caracteres. | validación | sí | impl. | no | — | «Deshacer exige un motivo de hasta 300 caracteres: escríbelo.» |
| M084 | `domain/services/change_requests.dart:101` | Solo una cuenta de muelle autorizada puede pedir cambios. | rechazo | sí | no | no | — | «… Inicia sesión con una cuenta de muelle autorizada.» |
| M085 | `domain/services/change_requests.dart:102` | Solo una cuenta de oficina autorizada puede decidir. | rechazo | sí | no | no | — | «… Inicia sesión con una cuenta de oficina autorizada.» |
| M086 | `domain/services/change_requests.dart:105; presentation/widgets/plan_drag_confirmation.dart:190` | La operación debe estar publicada y abierta. | rechazo | sí | no | no | — | «… La oficina la publica desde Nube y cuenta.» |
| M087 | `domain/services/change_requests.dart:113` | Indica de uno a cuatro cambios válidos. | validación | impl. | sí | no | — | «Los cambios no son válidos: indica de uno a cuatro.» |
| M088 | `domain/services/change_requests.dart:117` | {Objeto} no está en el plan. | validación | sí | no | no | — | «… Revisa el OR o el número.» |
| M089 | `domain/services/change_requests.dart:119` | El origen de {objeto} cambió; revisa la solicitud. | validación | sí | sí | no | — | — |
| M090 | `domain/services/change_requests.dart:125` | La celda {BBBRRTT} no existe en la geometría del buque. | validación | sí | no | no | — | «… Elige una celda de la geometría (BBB-RR-TT).» |
| M091 | `domain/services/change_requests.dart:131` | {Objeto} no cabe en la bahía {n}. | validación | sí | no | no | — | «… Un 20 va en bahía impar y un 40 en par.» |
| M092 | `domain/services/change_requests.dart:148` | {destino} choca con {objeto} en {posición}[: un 40 ocupa las dos mitades de la celda.] Es carga de paso: no se descarga aquí. | validación | sí | no | no | — | «… Elige otra celda.» |
| M093 | `domain/services/change_requests.dart:150` | {destino} choca con {objeto} en {posición}[…] La celda está ocupada a bordo; marca primero su descarga. | validación | sí | sí | no | — | — |
| M094 | `domain/services/change_requests.dart:177` | {destino} choca con {objeto} en {posición}[…] La celda está prevista para otro objeto; inclúyelo en el intercambio. | validación | sí | sí | no | — | — |
| M095 | `domain/services/change_requests.dart:228` | {destino} choca con {objeto} en {posición}[…] Un 20 y un 40 no se intercambian. | validación | sí | no | no | — | «… Elige otra celda del mismo tamaño.» |
| M096 | `domain/services/change_requests.dart:233` | {destino} choca con {objeto} en {posición}[: un 40 ocupa las dos mitades de la celda.] (sin segunda frase) | validación | sí | no | no | — | «… Elige otra celda.» |
| M097 | `domain/services/change_requests.dart:254` | La solicitud ya no está pendiente. | rechazo | sí | no | no | — | «… Otra cuenta ya la decidió; actualiza la bandeja.» |
| M098 | `presentation/widgets/plan_drag_confirmation.dart:194` | Para otra bahía utiliza el formulario. | rechazo | impl. | sí | no | — | «El arrastre solo mueve dentro de la bahía: para otra bahía utiliza el formulario.» |
| M099 | `presentation/widgets/plan_drag_confirmation.dart:387; presentation/widgets/office_plan_controls.dart:38; presentation/pages/change_requests_page.dart:76,275` | La operación no está disponible. | falla | no | no | no | — | «La operación todavía no se cargó o cambió mientras tanto. Espera un momento e inténtalo de nuevo.» |
| | **Registro de carga (diálogo Confirmar carga y revisión)** | | | | | | | |
| M100 | `domain/services/loading_operation.dart:240,256` | La escala no tiene operación guardada. | rechazo | sí | no | no | — | «… Vuelve a abrir el plan de carga y confirma la escala.» (como dice ya el modo Descarga) |
| M101 | `domain/services/loading_operation.dart:259` | El OR ya no está en el listado. | rechazo | sí | no | no | — | «… Importa de nuevo el listado de la agencia.» |
| M102 | `domain/services/loading_operation.dart:265` | La corrección exige un movimiento vigente y un motivo. | validación | sí | impl. | no | — | «… Elige un movimiento vigente y escribe el motivo.» |
| M103 | `domain/services/loading_operation.dart:271; domain/services/load_check.dart:180; presentation/widgets/office_plan_controls.dart:75` | Cancelado por la oficina. Debe deshacer la cancelación antes de cargar. | rechazo | sí | sí | no | — | — |
| M104 | `domain/services/loading_operation.dart:273` | El contenedor ya está operado. | rechazo | sí | no | no | — | «… Para cambiarlo, abre su detalle y usa Corregir o Deshacer.» |
| M105 | `domain/services/loading_operation.dart:280` | Un vacío se asigna a una celda reservada del plan. | validación | sí | impl. | no | — | «… Elige una celda reservada.» |
| M106 | `domain/services/loading_operation.dart:283` | La reserva está cancelada. | rechazo | sí | no | no | — | «… Elige otra reserva o pide a la oficina que deshaga la cancelación.» |
| M107 | `domain/services/loading_operation.dart:292` | La celda la ocupa {contenedor}, que baja aquí: marca primero su descarga. | validación | sí | sí | no | — | — |
| M108 | `domain/services/loading_operation.dart:296` | Esta carga se registra solo con un motivo escrito. | validación | sí | impl. | no | — | «… Escribe el motivo para registrarla.» |
| M109 | `domain/services/load_check.dart:162` | [No se registra:] La posición «{posición}» no tiene la forma BBB-RR-TT. | validación | sí | impl. | no | — | «… Escríbela como BBB-RR-TT, por ejemplo 012-04-82.» |
| M110 | `domain/services/load_check.dart:189` | No se registra: Un contenedor de {n} pies ({tipo}) no cabe en {celda}: la bahía {b} es {impar, de 20\|par, de 40} pies. | validación | sí | no | no | — | «… Elige una celda de {20\|40} pies.» |
| M111 | `domain/services/load_check.dart:200` | Pide motivo: OR {n} está planificado en {celda}; en {celda} quedará «fuera de plan»[, y {celda} es la celda de {objeto}]. | aviso de datos | sí | impl. | no | — | «… Para registrarlo ahí, escribe el motivo; si no, usa la celda planificada.» |
| M112 | `domain/services/load_check.dart:213` | Pide motivo: La reserva {celda} es de otro grupo ({diferencias}); el OR {n} es {tipo} · {POD} · {línea}. | aviso de datos | sí | impl. | no | — | «… Para registrarlo ahí, escribe el motivo; si no, elige una reserva de su grupo.» |
| M113 | `domain/services/load_check.dart:229` | Pide motivo: {celda} la ocupa {objeto}, que no baja en {escala}: la celda está ocupada. | aviso de datos | sí | impl. | no | — | «… Para registrarlo ahí, escribe el motivo; si no, elige otra celda.» |
| M114 | `domain/services/load_check.dart:262` | No se registra: La bahía {b} no existe en este buque: {celda} no se puede registrar. | validación | sí | no | no | — | «… Revisa la celda.» |
| M115 | `domain/services/load_check.dart:266` | No se registra: {celda} no existe en la geometría del buque (fila {f}, nivel {n}). | validación | sí | no | no | — | «… Revisa la celda o la geometría en Parámetros del buque.» |
| M116 | `domain/services/load_check.dart:85` | Pide motivo: {Pila de cubierta\|bodega} {bahía}, fila {f}: quedaría en {x} t y el límite del perfil es {y} t[; {n} contenedores de la pila no traen peso, el peso real es mayor]. | aviso de datos | sí | impl. | no | — | «… Para registrarlo ahí, escribe el motivo; si no, elige otra pila.» |
| M117 | `presentation/widgets/loading_controls.dart:40` | Este contenedor no tiene OR en el listado de agencia. | rechazo | sí | no | no | — | «… Importa el listado de la agencia actualizado.» |
| M118 | `presentation/widgets/loading_controls.dart:423` | Escribe la hora como HH:mm (00:00 a 23:59). | validación | impl. | sí | no | — | «Hora no válida: escríbela como HH:mm (00:00 a 23:59).» |
| | **Descarga y tapas** | | | | | | | |
| M119 | `presentation/widgets/discharge_controls.dart:153` | Esta escala no tiene operación guardada: vuelve a abrir el BAPLIE de llegada y confirma la escala. | rechazo | sí | sí | no | — | — |
| M120 | `domain/entities/hatch_covers.dart:38` | Una bahía sin bodega no puede declarar tapas. | validación | sí | no | no | — | «… Déjala «Sin declarar».» |
| M121 | `domain/entities/hatch_covers.dart:41` | Una bodega abierta no lleva tapas. | validación | sí | no | no | — | «… Quita las filas de tapa.» |
| M122 | `domain/entities/hatch_covers.dart:44` | Declara exactamente una tapa automática. | validación | impl. | sí | no | — | «Falta la tapa automática o hay más de una: declara exactamente una.» |
| M123 | `domain/entities/hatch_covers.dart:47` | Declara de una a tres tapas de grúa. | validación | impl. | sí | no | — | «Faltan las tapas de grúa o hay más de tres: declara de una a tres.» |
| M124 | `domain/entities/hatch_covers.dart:52` | La tapa {n} necesita al menos una fila. | validación | sí | impl. | no | — | «… Escribe sus filas.» |
| M125 | `domain/entities/hatch_covers.dart:63` | La fila {nn} de la tapa {n} no pertenece a la geometría de bodega de esta bahía. | validación | sí | no | no | — | «… Usa filas de la geometría.» |
| M126 | `domain/entities/hatch_covers.dart:66` | La fila {nn} se solapa entre tapas. | validación | sí | no | no | — | «… Déjala en una sola tapa.» |
| M127 | `presentation/pages/hatch_covers_page.dart:71` | Tapa {n}: escribe filas de uno o dos dígitos separadas por coma. | validación | impl. | sí | no | — | «Tapa {n}: las filas no tienen el formato esperado; escribe filas de uno o dos dígitos separadas por coma.» |
| M128 | `presentation/pages/hatch_covers_page.dart:76` | Tapa {n}: hay una fila repetida. | validación | sí | no | no | — | «… Quita la repetida.» |
| | **Listado de la agencia** | | | | | | | |
| M129 | `presentation/providers/export_list_providers.dart:129` | El archivo está vacío o no se pudo leer. | falla | sí | no | no | — | «… Vuelve a elegir el Excel (.xlsx) de la agencia.» |
| M130 | `presentation/providers/export_list_providers.dart:139` | Abre primero el plan de carga y confirma la escala. | rechazo | impl. | sí | no | — | «No hay un plan de carga confirmado: abre primero el plan de carga y confirma la escala.» |
| M131 | `presentation/pages/export_list_import_page.dart:38` | Abre primero el plan de carga (BAPLIE) y confirma la escala. | rechazo | impl. | sí | no | — | «No hay un plan de carga confirmado: abre primero el plan de carga (BAPLIE) y confirma la escala.» |
| M132 | `presentation/providers/export_list_providers.dart:200` | No hay un listado leído para importar. | rechazo | sí | impl. | no | — | «… Elige primero el Excel de la agencia.» |
| M133 | `presentation/providers/export_list_providers.dart:203` | Falta elegir equivalencias: {códigos}. | validación | sí | impl. | no | — | «… Elige una para cada código antes de importar.» |
| M134 | `presentation/providers/export_list_providers.dart:205` | Hay una operación en curso. | rechazo | sí | no | no | — | «… Espera a que termine.» |
| M135 | `presentation/pages/export_list_import_page.dart:90` | Falta elegir {n} equivalencias antes de importar. | validación | sí | impl. | no | — | «… Elige una para cada código pendiente.» |
| M136 | `data/repositories/export_list_repository_impl.dart:26` | No se pudo leer el listado. Revisa que sea el Excel de la agencia. | falla | impl. | sí | no | — | Sale del catch general (error inesperado): si el motivo no se conoce, no hay causa que agregar; basta la acción. El motivo técnico queda en el registro. |
| M137 | `data/services/export_list_parser_service.dart:65` | El archivo no es un libro de Excel (.xlsx) legible. | falla | sí | no | Excel | — | «… Guárdalo como .xlsx desde Excel y vuelve a elegirlo.» |
| M138 | `data/services/export_list_parser_service.dart:76` | El libro no tiene hojas con datos. | falla | sí | no | Excel | — | «… Elige el listado de la agencia.» |
| M139 | `data/services/export_list_parser_service.dart:155` | No se encontró la fila de encabezados del listado (OR, CONTENEDOR, TIPO…). | falla | sí | no | Excel | — | «… Revisa que sea el listado de exportación de la agencia.» |
| M140 | `data/services/export_list_parser_service.dart:169` | Al listado le faltan columnas: {columnas}. | falla | sí | no | Excel | — | «… Pide a la agencia el listado completo.» |
| M141 | `data/services/export_list_parser_service.dart:237` | Fila {n}: OR {orden}: {falta el número de contenedor; el contenedor «x» no tiene la forma ISO 6346 …; marca lleno (F) y vacío (E) a la vez; …}. | aviso de datos | sí | no | Excel | — | «… Corrige esas filas en el Excel y vuelve a importarlo.» |
| M142 | `data/services/export_list_parser_service.dart:200` | Fila {n}: No es un contenedor ni un separador de agencia: «{texto}». | aviso de datos | sí | no | Excel | — | «… Revisa esa fila del Excel.» |
| | **BAPLIE de salida** | | | | | | | |
| M143 | `domain/services/departure_baplie_writer.dart:19` | La operación no tiene una fuente loading_baplie. Importa el plan de carga antes de generar la salida. | rechazo | sí | sí | no | — | Sin el identificador: «La operación no tiene el plan de carga (BAPLIE). Impórtalo …». |
| M144 | `domain/services/departure_baplie_writer.dart:25` | No está disponible el plan efectivo de la operación. | falla | sí | no | no | — | «… Espera a que cargue la operación e inténtalo de nuevo.» |
| M145 | `domain/services/departure_baplie_writer.dart:45` | Hay ocupantes duplicados en el estado derivado; resuelve el conflicto antes de generar. | conflicto | sí | sí | no | — | — |
| M146 | `domain/services/departure_baplie_writer.dart:54` | Falta la fuente del ocupante {contenedor}; no se puede conservar su información. | falla | sí | no | no | — | «… Vuelve a importar el plano de llegada y el plan de carga.» |
| M147 | `domain/services/departure_baplie_writer.dart:66` | El contenedor cargado {contenedor} no está en el listado; faltan sus datos exactos. | falla | sí | no | no | — | «… Importa el listado que lo incluye.» |
| M148 | `domain/services/departure_baplie_writer.dart:183` | El listado contiene un peso inválido. | aviso de datos | sí | no | no | — | «… Corrige los pesos en el Excel y vuelve a importarlo.» |
| M149 | `domain/services/departure_baplie_writer.dart:193` | El listado no declara lleno/vacío para {contenedor}. | aviso de datos | sí | no | no | — | «… Corrige esa fila en el Excel y vuelve a importarlo.» |
| M150 | `domain/services/departure_baplie_writer.dart:196` | El listado no declara el VGM de {contenedor}. | aviso de datos | sí | no | no | — | «… Pide el VGM a la agencia e impórtalo de nuevo.» |
| M151 | `domain/services/departure_baplie_writer.dart:229` | La fuente debe contener un único mensaje BAPLIE con UNB y UNH. | falla | sí | no | sí | sí | «… Vuelve a importar el plan de carga.» |
| M152 | `domain/services/departure_baplie_writer.dart:236` | Versión BAPLIE no reconocida para salida 2.x: {identificador\|sin cabecera}. No se generó el archivo. | falla | sí | no | sí | no | «… (cabecera UNH) … Importa el plan en SMDG20, SMDG21 o SMDG22.» |
| M153 | `domain/services/departure_baplie_writer.dart:279` | Separadores EDIFACT no reconocidos para generar la salida. | falla | sí | no | sí | no | «Separadores EDIFACT no reconocidos en el segmento UNA … Pide una exportación con los separadores estándar.» |
| M154 | `presentation/pages/departure_baplie_page.dart:55` | No se genera el BAPLIE de salida: «{archivo}» es versión 1.5 (SMDG15) y se leyó con las reglas de 2.x. Escribir la salida con esas reglas no sería fiel a lo que llegó. Importa el plano en SMDG20, SMDG21 o SMDG22. | rechazo | sí | sí | no | — | — |
| M155 | `presentation/pages/departure_baplie_page.dart:94` | La escala no tiene una operación guardada con fuente loading_baplie. | rechazo | sí | no | no | — | «La escala no tiene una operación guardada con su plan de carga. Abre el plan de carga (BAPLIE) y confirma la escala.» |
| M156 | `presentation/pages/departure_baplie_page.dart:190` | La operación se está actualizando. Intenta de nuevo. | falla | sí | sí | no | — | — |
| | **Comparar BAPLIE** | | | | | | | |
| M157 | `domain/services/voyage_comparison.dart:128` | No se puede confirmar que sea el mismo buque: {motivo}. Confirma que es el mismo buque antes de usar la comparación. | aviso de datos | sí | sí | no | — | — |
| M158 | `domain/services/voyage_comparison.dart:131` | No parece el mismo buque: {nombre} ({clave}) y {nombre} ({clave}). | aviso de datos | sí | no | no | — | «… Revisa que el segundo archivo sea del mismo buque.» |
| | **Parámetros del buque (validación del formulario y de las tomas)** | | | | | | | |
| M159 | `presentation/pages/vessel_geometry_page.dart:866` | Escribe un número. | validación | impl. | sí | no | — | «Valor no numérico: escribe un número.» |
| M160 | `presentation/pages/vessel_geometry_page.dart:869` | No puede ser menor que {mínimo}. | validación | sí | impl. | no | — | «… Escribe {mínimo} o más.» |
| M161 | `presentation/pages/vessel_geometry_page.dart:870` | El archivo trae carga en {la fila nn}; con {v} {filas a babor\|estribor} quedaría fuera del plano. | validación | sí | impl. | no | — | «… Aumenta las filas a {babor\|estribor} hasta incluirla.» |
| M162 | `presentation/pages/vessel_geometry_page.dart:1031` | Escribe el límite o marca que no lo tienes. | validación | impl. | sí | no | — | «Falta el límite de apilamiento: escríbelo o marca que no lo tienes.» |
| M163 | `presentation/pages/vessel_geometry_page.dart:519` | Escribe siete dígitos y una bahía distinta de 000. | validación | impl. | sí | no | — | «Posición de toma no válida: escribe siete dígitos y una bahía distinta de 000.» |
| M164 | `presentation/pages/vessel_geometry_page.dart:550,566` | Revisa la frontera y las anclas antes de cargar tomas. | validación | impl. | sí | no | — | «La frontera y las anclas no forman una geometría válida: revísalas antes de cargar tomas.» |
| M165 | `presentation/pages/vessel_geometry_page.dart:568` | Pega al menos un código. | validación | impl. | sí | no | — | «No hay códigos pegados: pega al menos uno.» |
| M166 | `presentation/pages/vessel_geometry_page.dart:312` | Revisa frontera y anclas: bodega debajo de la frontera y cubierta desde ella. | validación | sí | sí | no | — | — |
| M167 | `presentation/pages/vessel_geometry_page.dart:424` | Falta resolver el límite de apilamiento. | validación | sí | impl. | no | — | «… Escribe el límite o marca que no lo tienes.» |
| M168 | `domain/services/reefer_socket_ranges.dart:43` | {Bahías\|Filas\|Niveles}: «{x}» no es un número ni un rango como 02-08. | validación | sí | impl. | no | — | «… Escribe un número o un rango como 02-08.» |
| M169 | `domain/services/reefer_socket_ranges.dart:53` | {campo}: «{x}» sale de {mín} a {máx}. | validación | sí | impl. | no | — | «… Escribe valores entre {mín} y {máx}.» |
| M170 | `domain/services/reefer_socket_ranges.dart:59` | {campo}: en «{x}» el final es menor que el inicio. | validación | sí | no | no | — | «… Escribe el inicio primero.» |
| M171 | `domain/services/reefer_socket_ranges.dart:65` | {campo}: en «{x}» el paso tiene que ser 1 o más. | validación | sí | impl. | no | — | «… Escribe un paso de 1 o más, como 002-038/4.» |
| M172 | `domain/services/reefer_socket_ranges.dart:90` | Escribe al menos una bahía. | validación | impl. | sí | no | — | «Faltan las bahías: escribe al menos una.» |
| M173 | `domain/services/reefer_socket_ranges.dart:93` | Escribe al menos un nivel. | validación | impl. | sí | no | — | «Faltan los niveles: escribe al menos uno.» |
| M174 | `domain/services/reefer_socket_ranges.dart:120` | El rango genera {n} códigos; el máximo es {m}. Acótalo. | validación | sí | sí | no | — | — |
| | **Búsqueda por voz** | | | | | | | |
| M175 | `presentation/widgets/voice_search_field.dart:119` | Permiso de micrófono denegado. Puedes escribir la búsqueda. | falla | sí | sí | no | — | — |
| M176 | `presentation/widgets/voice_search_field.dart:121` | Reconocimiento sin conexión o servicio no disponible. Puedes escribir la búsqueda. | falla | sí | sí | no | — | — |
| M177 | `presentation/widgets/voice_search_field.dart:123` | No se entendió el dictado. Reintenta o escribe la búsqueda. | falla | sí | sí | no | — | — |
| M178 | `presentation/widgets/voice_search_field.dart:125` | Reconocimiento en español no disponible. Puedes escribir la búsqueda. | falla | sí | sí | no | — | — |
| M179 | `presentation/widgets/voice_search_field.dart:127` | Reconocimiento de voz no disponible. Puedes escribir la búsqueda. | falla | sí | sí | no | — | — |
| | **Avisos de lectura del BAPLIE (tarjeta del viaje y Comparar)** | | | | | | | |
| M180 | `presentation/widgets/voyage_summary_card.dart:7` | Versión 1.5, leída con las reglas de 2.x; revisa pesos y peligrosas | aviso de datos | sí | sí | sí | no | «… (la cabecera UNH declara BAPLIE:1:911:UN:SMDG15) …». |
| M181 | `presentation/widgets/voyage_summary_card.dart:322` | Pesos revisados: {n} contenedores · detalle: «{número}: WT en LBR convertido a {x} kg», «… sin unidad; se tomó como kg», «… con unidad desconocida {u}; sin ese peso» | aviso de datos | sí | no | sí | no | «Pesos revisados en MEA: {n} contenedores · revisa sus pesos antes de operar.» |
| M182 | `presentation/widgets/voyage_summary_card.dart:323` | Posiciones mal formadas: {n} contenedores · detalle: «{número}: {posición}» | aviso de datos | sí | no | sí | no | «Posiciones mal formadas en LOC+147: {n} contenedores · pide una exportación corregida.» |
| M183 | `presentation/widgets/voyage_summary_card.dart:324` | Dígito de control inválido: {n} contenedores · detalle: «{número}» | aviso de datos | sí | no | sí | no | «Dígito de control inválido en EQD: {n} contenedores · revisa esos números con la agencia.» |
| M184 | `presentation/widgets/voyage_summary_card.dart:325` | Archivo posiblemente incompleto: faltan {n} segmentos ({UNB, BGM, UNT, UNZ}) · detalle: «El archivo puede venir incompleto. Revisa los segmentos que faltan:» | aviso de datos | sí | sí | sí | sí | — |
| | **Rejilla y geometría (Bay Plan y Orden de descarga)** | | | | | | | |
| M185 | `presentation/widgets/bay_plan_view.dart:962` | {n} contenedores fuera de la geometría declarada · No se dibujan en la rejilla porque su posición no existe en el buque declarado: {posiciones}. | aviso de datos | sí | no | no | — | «… Amplía la geometría en Parámetros del buque.» |
| M186 | `presentation/widgets/bay_plan_view.dart:865` | {n} celdas reservadas fuera de la geometría declarada: {posiciones}[ y {n} más]. | aviso de datos | sí | no | no | — | «… Amplía la geometría en Parámetros del buque.» |
| M187 | `presentation/widgets/bay_plan_view.dart:896` | Este viaje no trae la geometría del buque declarada, así que no hay rejilla contra la cual dibujarlo. Declara los parámetros del buque para ver el plano. | aviso de datos | sí | sí | no | — | — |
| M188 | `presentation/pages/discharge_sequence_page.dart:47` | Confirma la geometría del buque para sugerir el orden de descarga. | rechazo | impl. | sí | no | — | «La geometría del buque está sin confirmar: confírmala para sugerir el orden de descarga.» |
| M189 | `presentation/pages/discharge_sequence_page.dart:48` | El archivo no trae puertos de descarga. | aviso de datos | sí | no | no | — | «… (LOC+11): no hay orden que sugerir.» (no hay acción posible en la app) |
| | **Conflictos de la operación (detalle de la celda, Avance, Tapas en la operación)** | | | | | | | |
| M190 | `domain/services/operation_state_deriver.dart:97` | Solicitud con cambios inválidos. | conflicto | sí | no | no | — | «… Si el registro fue un error, anúlalo con Deshacer.» |
| M191 | `domain/services/operation_state_deriver.dart:104` | La decisión cita una solicitud que no está vigente. | conflicto | sí | no | no | — | «… Si el registro fue un error, anúlalo con Deshacer.» |
| M192 | `domain/services/operation_state_deriver.dart:108` | La solicitud ya tiene una decisión o está en conflicto. | conflicto | sí | no | no | — | «… Si el registro fue un error, anúlalo con Deshacer.» |
| M193 | `domain/services/operation_state_deriver.dart:113` | El rechazo no cita una solicitud. | conflicto | sí | no | no | — | «… Si el registro fue un error, anúlalo con Deshacer.» |
| M194 | `domain/services/operation_state_deriver.dart:124` | El cambio no contiene de uno a cuatro cambios válidos. | conflicto | sí | no | no | — | «… Si el registro fue un error, anúlalo con Deshacer.» |
| M195 | `domain/services/operation_state_deriver.dart:128` | La aprobación no coincide con lo solicitado. | conflicto | sí | no | no | — | «… Si el registro fue un error, anúlalo con Deshacer.» |
| M196 | `domain/services/operation_state_deriver.dart:135` | {Objeto} no está en el plan de carga. | conflicto | sí | no | no | — | «… Si el registro fue un error, anúlalo con Deshacer.» |
| M197 | `domain/services/operation_state_deriver.dart:137` | {Objeto}: origen obsoleto; plan efectivo {p}, cambio desde {p}. | conflicto | sí | no | no | — | «… Si el registro fue un error, anúlalo con Deshacer.» |
| M198 | `domain/services/operation_state_deriver.dart:140` | {celda} está prevista para otro objeto del plan. | conflicto | sí | no | no | — | «… Si el registro fue un error, anúlalo con Deshacer.» |
| M199 | `domain/services/operation_state_deriver.dart:289` | {tapa}: tapa sin declarar o acción inválida. | conflicto | sí | no | no | — | «… Si el registro fue un error, anúlalo con Deshacer.» |
| M200 | `domain/services/operation_state_deriver.dart:296` | Bahía {b} · {tapa}: {ya está quitada\|no está quitada para reponerla}. | conflicto | sí | no | no | — | «… Si el registro fue un error, anúlalo con Deshacer.» |
| M201 | `domain/services/operation_state_deriver.dart:318` | {Objeto} no está en el plano de llegada de esta escala. | conflicto | sí | no | no | — | «… Si el registro fue un error, anúlalo con Deshacer.» |
| M202 | `domain/services/operation_state_deriver.dart:322` | {Objeto} está cancelado y se descargó. | conflicto | sí | no | no | — | «… Si el registro fue un error, anúlalo con Deshacer.» |
| M203 | `domain/services/operation_state_deriver.dart:338` | {Objeto} no descarga en {escala}; si sale para volver a subir, es una re‑estiba. | conflicto | sí | impl. | no | — | «… Si el registro fue un error, anúlalo con Deshacer.» |
| M204 | `domain/services/operation_state_deriver.dart:351,392,442` | {celda} ya la ocupa {objeto}. (tres reglas: descarga, carga y vacío) | conflicto | sí | no | no | — | «… Si el registro fue un error, anúlalo con Deshacer.» |
| M205 | `domain/services/operation_state_deriver.dart:366` | {Objeto} no está en el plan de carga de {escala}. | conflicto | sí | no | no | — | «… Si el registro fue un error, anúlalo con Deshacer.» |
| M206 | `domain/services/operation_state_deriver.dart:370` | {Objeto} está cancelado y se cargó. | conflicto | sí | no | no | — | «… Si el registro fue un error, anúlalo con Deshacer.» |
| M207 | `domain/services/operation_state_deriver.dart:377` | {Objeto} no se carga en {escala}. | conflicto | sí | no | no | — | «… Si el registro fue un error, anúlalo con Deshacer.» |
| M208 | `domain/services/operation_state_deriver.dart:385` | {Objeto} ya se cargó en {posición}. | conflicto | sí | no | no | — | «… Si el registro fue un error, anúlalo con Deshacer.» |
| M209 | `domain/services/operation_state_deriver.dart:406` | {Objeto}: planificado en {p}, registrado en {p}. | conflicto | sí | no | no | — | «… Si el registro fue un error, anúlalo con Deshacer.» |
| M210 | `domain/services/operation_state_deriver.dart:415` | {Objeto} no es una celda reservada del plan. | conflicto | sí | no | no | — | «… Si el registro fue un error, anúlalo con Deshacer.» |
| M211 | `domain/services/operation_state_deriver.dart:419` | {Objeto} está cancelada y se asignó. | conflicto | sí | no | no | — | «… Si el registro fue un error, anúlalo con Deshacer.» |
| M212 | `domain/services/operation_state_deriver.dart:428` | {Objeto} ya tiene asignado {contenedor}. | conflicto | sí | no | no | — | «… Si el registro fue un error, anúlalo con Deshacer.» |
| M213 | `domain/services/operation_state_deriver.dart:435` | {contenedor} ya está en {objeto}. | conflicto | sí | no | no | — | «… Si el registro fue un error, anúlalo con Deshacer.» |
| M214 | `domain/services/operation_state_deriver.dart:466` | {contenedor} ({tipo} · {POD} · {línea}) quedó en una reserva de {tipo} · {POD} · {línea}. | conflicto | sí | no | no | — | «… Si el registro fue un error, anúlalo con Deshacer.» |
| M215 | `domain/services/operation_state_deriver.dart:475` | {Objeto} no está en el plan de esta escala. | conflicto | sí | no | no | — | «… Si el registro fue un error, anúlalo con Deshacer.» |
| M216 | `domain/services/operation_state_deriver.dart:484` | {Objeto} ya se movió; para cancelarlo, anula antes ese movimiento. | conflicto | sí | sí | no | — | — |
| | **Texto no controlado: toString() de la excepción** | | | | | | | |
| M217 | `presentation/widgets/plan_drag_confirmation.dart:400; presentation/widgets/loading_controls.dart:493; presentation/widgets/office_plan_controls.dart:50; presentation/pages/change_requests_page.dart:86,288` | '$failure' cuando el error no es StateError: el toString() de Dart o del paquete (p. ej. «HiveError: …», «FileSystemException: …», o el nombre de la clase de un Failure en release) | no controlado | no | no | no | — | Mostrar vesselErrorMessage(failure, stack), como el resto de la app. |
| M218 | `presentation/widgets/hatch_operation_controls.dart:83` | Text('$error') en el estado de error de Tapas en la operación: «Instance of 'VesselOperationFailure'», «CacheFailure» (release), «Bad state: …», «FormatException: …» | no controlado | no | no | no | — | Text(vesselErrorMessage(error, stack)), como Avance de la operación y las demás pantallas. |

#### Tabla E-4 · Envolturas (muestran un mensaje de E-3; no suman)

| Archivo:línea | Qué muestran |
|---|---|
| `presentation/pages/vessel_overview_page.dart:247` | título del estado de error + vesselErrorMessage y botón «Intentar de nuevo» |
| `presentation/pages/vessel_overview_page.dart:468` | SnackBar con el LoadFileResult.error |
| `presentation/pages/vessel_overview_page.dart:525` | plantilla del buque: vesselErrorMessage |
| `presentation/pages/vessel_overview_page.dart:678` | error de confirmGeometry (vessel_providers) |
| `presentation/providers/vessel_providers.dart:196` | prefijo con el nombre del archivo |
| `presentation/providers/vessel_providers.dart:224` | prefijo con el nombre del archivo |
| `presentation/pages/recent_voyages_page.dart:94` | estado de error + «Reintentar» |
| `presentation/pages/vessel_profiles_page.dart:20` | estado de error + «Reintentar» |
| `presentation/pages/vessel_profiles_page.dart:74` | error de saveEditedProfile |
| `presentation/pages/recent_voyages_page.dart:43` | error de openRecentVoyage |
| `presentation/widgets/discharge_controls.dart:176` | prefijo + error del registro |
| `presentation/widgets/discharge_controls.dart:191` | prefijo + error del registro |
| `presentation/widgets/discharge_controls.dart:210,401` | prefijo + error del registro (dos sitios) |
| `presentation/widgets/hatch_operation_controls.dart:63` | error del registro de tapa |
| `presentation/widgets/loading_controls.dart:487` | error de Deshacer |
| `presentation/pages/vessel_geometry_page.dart:120` | prefijo con la bahía + validación de tapas |
| `presentation/pages/hatch_covers_page.dart:134` | prefijo con la bahía + validación de tapas |
| `domain/entities/vessel_profile.dart:211` | prefijo con la bahía |
| `presentation/pages/voyage_comparison_page.dart:45` | prefijo con el nombre del archivo |
| `presentation/pages/voyage_comparison_page.dart:53` | prefijo con el nombre del archivo |
| `presentation/pages/voyage_comparison_page.dart:61` | vesselErrorMessage |
| `presentation/pages/departure_baplie_page.dart:201` | StateError del escritor o vesselErrorMessage |
| `presentation/pages/departure_baplie_page.dart:167` | vesselFailureMessage |
| `presentation/pages/cloud_page.dart:50` | _run: vesselErrorMessage |
| `presentation/pages/cloud_page.dart:55` | _run: el texto de la falla sin puntos repetidos |
| `presentation/providers/export_list_providers.dart:158` | mensaje de la lectura del listado |
| `presentation/pages/change_requests_page.dart:373` | error de la revisión del cambio |
| `presentation/widgets/plan_drag_confirmation.dart:251` | error de la revisión del arrastre |
| `presentation/widgets/loading_controls.dart:766` | prefijo de la revisión de carga |

#### Tabla E-5 · Conciliación con los 804 candidatos de Codex

| Medida | Cantidad |
|---|---:|
| Candidatos de `errores.csv` | 804 |
| · en la línea de un mensaje de E-3 | 152 |
| Mensajes de E-3 con algún candidato en su línea | 122 de 218 |

De los 804 candidatos de Codex, 152 caen en la línea de un mensaje del inventario. Los demás son
claves, registros, condiciones y código que mencionan «error» o «message», no mensajes.

Al revés, 96 mensajes del inventario no tienen un candidato en la línea que cita E-3. Solo 4 tienen
uno a tres líneas o menos (M060, M116, M133, M190). A los otros 92 el patrón no los marca: busca
`error|exception|failure|message|throw|snackbar|fallo|no se pudo|sin conex|inval|incorrect|rechaz`
en el literal y en los 240 caracteres anteriores (`t98_inventario.py:78-79`), y esos mensajes no
traen ninguna de esas palabras. Pasa, por ejemplo, con «Tara fuera de rango.», los conflictos y los
avisos de lectura. Por eso el patrón no basta para hacer el inventario, y hubo que recorrer el código.

### 5.5 Lo que el criterio no deja aplicar tal cual

1. **Causa y acción implícitas.** T-63 pide «causa y acción», pero no dice qué hacer cuando una sola
   frase las implica («Escribe un número.», «Sin conexión: iniciar sesión requiere red.»). Se informan
   la lectura estricta y la que cuenta las implícitas.
2. **Mensajes sin acción posible.** Algunos no tienen nada que el usuario pueda hacer en la app, como
   «El archivo no trae puertos de descarga.» o las invariantes del formulario («Falta la solicitud.»).
   El 100 % con acción no se alcanza ahí con texto. Se marcan «no» y se dice en el arreglo sugerido.
3. **Acción en un botón y no en el texto.** Algunas pantallas ponen la acción en un botón junto al
   mensaje: «Reintentar» en Recientes y Perfiles, «Intentar de nuevo» en la carga, «Deshacer
   conflicto» en Tapas en la operación. Se juzgó el texto, que es lo que pide el criterio.
4. **«Segmento» fuera de EDIFACT.** Para el Excel del listado (6 mensajes de lectura) no hay
   segmento. Lo equivalente sería la fila o la columna, y esos mensajes ya la nombran. Se marcan con
   parseo «Excel» y segmento «—», y no entran en el 4 de 12.
5. **El borde entre error y análisis.** El criterio no define si los resultados de análisis cuentan
   (alertas, cruce, conflictos). Aquí los conflictos entran (28) y el análisis no. La tabla E-2 da cada
   tipo por separado, para que Codex pueda quitar o sumar.
6. **Los no controlados no se pueden juzgar como texto.** Su contenido depende de la excepción. Se
   cuentan como dos mensajes sin causa ni acción, uno por cada forma de mostrar la excepción
   (`'$failure'` y `Text('$error')`). Sus seis sitios están en las filas M217 y M218.

## 6. Archivos y verificación

| Archivo | Qué hace |
|---|---|
| `tool/t98c_lexico.py` | tokenizador de cadenas de Dart, contexto de cada cadena, grafo de imports y copia literal de los dos patrones de `t98_inventario.py` para conciliar |
| `tool/t98c_idioma.py` | reglas y tablas de visibilidad, vocabulario revisado y textos de Flutter |
| `tool/t98c_material3.py` | extracción de controles, pantallas, rejilla, excluidos, implícitos y colores |
| `tool/t98c_mensajes.py` | inventario de mensajes con sus juicios; ubica cada fragmento en el código y falla si no lo encuentra |
| `tool/t98c_censos.py` | corre los tres censos, concilia con Codex y escribe CSV, JSON y `tablas.md` en TEMP |

Verificación:

- `python -I -m py_compile` de los cinco scripts: sin errores.
- La corrida completa: entre 2.5 y 4 s.
- Dos corridas seguidas dan las mismas huellas, y la corrida sobre la copia de Codex da los mismos
  CSV.
- Comprobaciones dentro de los scripts: cada fragmento de mensaje y de envoltura tiene que aparecer en
  el código (si no, el censo se detiene), y ninguna fila incompleta puede quedar sin arreglo.
- Las cifras que el texto cita fuera de las tablas se contaron sobre los CSV. Las referencias de
  línea que cita el texto se abrieron en el código (`vessel_error_message.dart:48`,
  `export_service.dart:63`, `cloud_page.dart:294`, entre otras).

No se modificaron `lib/`, `test/` ni `pubspec.*`; `pubspec.yaml` y `pubspec.lock` **sin cambios**. No
se tocaron los `tool/t98_*` de Codex ni `docs/T98-RESULTADOS.md`. No se ejecutó Flutter ni Git de
escritura.

Para la aceptación de T-98, que viene después: repetiré filas que no hice yo, como pide 10.92.
Cualquier fila de estos censos la puede repetir Codex abriendo el archivo y la línea que cita.
