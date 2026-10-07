# T-72 · Bitácora de movimientos y estado operativo, con la aceptación de T-68 y T-69

Timonel · 7-oct-2026 · rama `sprint-3`, sobre `bfde370` · carril de `lib/`, `test/` y `pubspec.*`

## 1. Resultado

| Tarea | Resultado |
|---|---|
| **Aceptación de T-68** (`b2f3190`) | **PASA** en Windows, el Honor a 360 dp y Chrome: las cuatro filas y GTSTC preseleccionado (sección 2) |
| **Aceptación de T-69** (`8a87219`) | **PASA** en los tres clientes, incluido lo que quedó pendiente en 10.6: el detalle de una reserva tras recargar Chrome (sección 2) |
| **T-72** | **Hecha**, con dominio, datos y pruebas; sin pantalla, que llega con T-75 a T-78 (secciones 3 a 5) |

- **Pruebas:** **383/383** en dos corridas (piso 360 + 23 nuevas). `flutter analyze` en **cero**, sin `// ignore:`.
- **Corpus:** **22/22**: T-68, T-69 y las dos de T-72, con A08 y con A08v_VGM.
- **Sin cambios** en `pubspec.yaml` ni `pubspec.lock`. No hay dependencias nuevas: `crypto`, autorizada en 10.3, no hace falta hasta que T-79 publique las fuentes.
- **No se tocó** `lib/main.dart`, las pantallas H5, la presentación ni nada fuera del carril.

**Aceptación de T-72 contra el caso real.** Se reprodujeron los 176 eventos de `CASO_A08_EVENTOS.json`, sin el intercambio, por el repositorio real sobre Hive. Después se cerró, se reabrió y se derivó:
- las **460 posiciones salen iguales a `CASO_A08_ESTADO_FINAL.csv`**;
- **solo 014-01-02 y 014-01-08 quedan en conflicto**, «fuera de plan»;
- los **nueve conteos por bahía y sección** del caso cuadran.

## 2. Aceptación de T-68 y T-69

Se hizo **antes de tocar el código**, sobre `bfde370`, que incluye los dos commits. La suite estaba en **360/360** y el corpus de T-68 y T-69 en **20/20**, ambos ejecutados por mí.

**Los tres clientes, compilados en lanzamiento desde `bfde370`:**

| Cliente | Compilación y almacén |
|---|---|
| Windows | `build/windows/…/Release/baystream.exe`. Almacén real de Carlos, `%LOCALAPPDATA%\BayStream`: el que usó Codex |
| Honor NAA-LX3 | 720 × 1600 a densidad 320, o sea **360 dp**. Variante propia **`gt.cmartinez.baystream.t72`**, con el método de Codex (Gradle y un script de inicialización que solo cambia el identificador). No reemplaza la app de Play ni las variantes `.t68` y `.t69`, y su almacén empezó vacío |
| Chrome 154 | Web servida en local en un origen nuevo, `127.0.0.1:8781`, con almacén vacío. Chrome propio, con perfil aparte, manejado por el protocolo de depuración. El panel del navegador integrado no dibujaba porque la ventana de Claude estaba detrás |

**Secuencia, la misma en los tres:**
1. A01, confirmando GTPBR. Así el último puerto confirmado **no** es GTSTC y la prueba de la preselección es limpia.
2. A07 como control: debe proponer HNPCR. Se cancela para no guardar ese puerto.
3. A08, confirmando GTSTC.
4. A07: debe preseleccionar GTSTC.
5. A02, A08v_VGM y A03 a A06.
6. Cerrar, reabrir, recuperar el viaje desde «Viajes recientes» y abrir el detalle de una reserva.

### 2.1 T-68: escala, carga, descarga y de paso

| Archivo | Escala | Ficha (carga/descarga/de paso) | Windows | Honor 360 dp | Chrome |
|---|---|---|---|---|---|
| CORPUS_A07 | GTSTC | 0 / **114** / **284** | PASA | PASA | PASA |
| CORPUS_A02 | GTSTC | 0 / **303** / **503** | PASA | PASA | PASA |
| CORPUS_A08 | GTSTC | **121** / 0 / **284** | PASA | PASA | PASA |
| CORPUS_A01 | GTPBR | **325** / 0 / **652** | PASA | PASA | PASA |

**Preselección:**
- **Control:** con GTPBR como último puerto, A07 propone **HNPCR** y ofrece GTSTC al lado. El texto: «El archivo se emitió al salir de HNPCR rumbo a GTSTC: para la salida, la escala es HNPCR; para la llegada, GTSTC».
- **Prueba:** tras confirmar A08 con GTSTC, A07 abre con **GTSTC preseleccionado sin tocarlo**, en los tres clientes. A02 también.
- **Windows:** A08 abrió directo con el perfil conocido. Como una apertura automática no es una confirmación (T-68), se confirmó GTSTC desde «Parámetros del buque».

### 2.2 T-69: celdas reservadas

| Archivo | Contenedores / reservas | Windows | Honor 360 dp | Chrome |
|---|---|---|---|---|
| CORPUS_A08 | 405 / **55** | PASA | PASA | PASA |
| CORPUS_A08v_VGM | 405 / **55** | PASA | PASA | PASA |
| CORPUS_A01 … A07 | 977, 806, 369, 979, 736, 717, 398 / **0** | PASA | PASA | PASA |

- **Resumen de la escala** en los tres clientes: **«Se cargan 121 contenedores y 55 reservas (176 movimientos)»**, «Se descargan 0 contenedores y 0 reservas» y «De paso 284 contenedores y 0 reservas».
- **De A01 a A07** la ficha no muestra ninguna sección de reservas.
- **Al cerrar y reabrir:**
  - **Honor:** cierre forzado (`am force-stop`). A08v_VGM conserva 405 / 55 y el detalle de `R:0070808` sale completo: 22G1, Bay 007 Row 08 Tier 08, 20 pies, vacío, LNC, GTSTC → PAMIT, 2.1 t nominal.
  - **Windows:** cierre y reapertura. Mismo viaje, mismas 55 reservas, mismo detalle de `R:0070808`.
  - **Chrome, lo pendiente de 10.6:** se recargó la página y se recuperó el viaje desde «Viajes recientes».
    - Con A08v_VGM, el detalle de `R:0070808` sale completo.
    - Después cargué **A08** (la lista dice «Peso bruto»), recargué otra vez y abrí la reserva de 40 pies `R:0060608`. **Sale completa:** 45G1, Bay 006 Row 06 Tier 08, 40 pies, vacío, LNC, GTSTC → PAMIT, 3.8 t nominal y la nota «La reserva no suma peso ni ocupación hasta que se asigne el contenedor».

**Conclusión:** T-68 y T-69 aceptadas. No cambié su código.

**Evidencia local en `build/t72/`** (ignorada por Git):
- `honor/` (jerarquías y capturas);
- `chrome/` (capturas);
- `windows/reabierto-detalle.jpg`;
- `aceptacion-suite.txt` y `aceptacion-corpus.txt`.

### 2.3 Incidencias de la aceptación

- **`taskkill /IM baystream.exe` cerró dos instancias** (PID 25484 y 11300), con un cierre normal, no forzado. En el momento la reporté como ajena, pero al terminar vi la causa: la orden «abrir aplicación» de la herramienta de pantalla **lanza una segunda instancia** aunque la app ya esté abierta, y la ventana que yo manejaba era esa. Lo comprobé en la reapertura: mi `Start-Process` dio el PID 35668, pero la instancia en pantalla era la 30340, creada el mismo minuto. Así que la 11300 casi seguro era mía. Igual debí cerrar por PID, y al final lo hice así.
- **Residuo de T-66 en el almacén real de Windows.** El perfil BUQUE GOLF conserva el **límite de prueba de 90 000 kg** que puse entonces. Esta aceptación agregó además perfiles y viajes recientes del corpus (BUQUE ALFA a ECO), como la de Codex. Carlos puede quitar el límite desde «Perfiles guardados».
- **El Honor, al terminar.** Estaba desconectado de `adb` («device offline») y no pude cerrar la variante `.t72`. Queda instalada, como `.t68` y `.t69`, sin tocar la app de Play.
- **Fallos transitorios del Honor.** `uiautomator` devolvió alguna vez `null root node returned by UiTestAutomationBridge`, como vio Codex; repetí la lectura. Apareció dos veces el diálogo «Confirma la identidad del buque» (dos BUQUE ECO con el mismo nombre) y elegí «Es otro buque».

## 3. T-72: qué se construyó

El diseño es el de `docs/T79a-DISENO.md` (secciones 2, 3.1, 3.2 y 4.1). Archivos nuevos:

| Archivo | Contenido |
|---|---|
| `domain/entities/movement.dart` | `Movement` con el sobre de T-79a 2.3 y los nombres de Firestore; los nueve tipos; `MovementAuthor`; `MovementDraft` con validación de forma, igual que las reglas propuestas; `SendState` y `MovementRecord` |
| `domain/entities/operation.dart` | `Operation` y `OperationSource`; el **plan combinado** `OperationPlan` (llegada, carga y reservas de T-69, con claves `C:` y `R:`); `ItemStatus`, `OperationConflict`, `OperationState` con su ocupación y el avance por bahía y zona |
| `domain/services/operation_state_deriver.dart` | La derivación: vigencia por anular y corregir, orden total y aplicación con conflictos |
| `domain/repositories/movement_log_repository.dart` | El contrato local |
| `data/datasources/hive_movement_data_source.dart` | Las cajas `{ns}_operations`, `{ns}_movements` y `{ns}_device` |
| `data/repositories/movement_log_repository_impl.dart` | El repositorio, con el mismo estilo que `LocalVesselRepositoryImpl` |

Cambian dos archivos existentes:
- `local_vessel_repository_factory.dart`: `openMovementLogRepository()`, en el mismo directorio y con el mismo motor;
- `entities.dart`: exporta las dos entidades nuevas.

### 3.1 Lo que deriva y lo que no

**Deriva:**
- descargar (con re-estiba);
- cargar un contenedor del plan;
- asignar un vacío a una reserva;
- cancelar;
- anular, incluso anular una anulación;
- corregir, que reemplaza en la misma escritura.

**Los seis conflictos de T-79a 2.7.2:** fuera del plan, fuera de su celda, celda ocupada, movido dos veces, un vacío en dos reservas y operar algo cancelado. **Vale el primero en el orden** y el resto queda a la vista, sin resolverse en silencio. Un registro repetido en la misma celda no es conflicto: se cuenta como duplicado y no se aplica dos veces.

**No deriva todavía:** los cambios de posición (T-80) y las tapas (T-84). Se guardan y se exportan, y el estado los cuenta en `notDerived` sin aplicarlos.

**Orden:** `(createdAt, deviceId, sequence, id)`, solo campos inmutables. La prueba que mezcla los mismos movimientos en tres órdenes de llegada da el mismo estado.

### 3.2 Persistencia

- **Cada anexo hace `put` y `flush`** antes de devolver; solo entonces la pantalla podrá decir «registrado».
- **La secuencia sale de los movimientos propios** al abrir, sin un contador aparte que pueda quedar a medias.
- **Sin límite de cinco viajes:** una operación con movimientos no confirmados no se puede quitar (`operation_has_movements`).
- **Hasta T-79 todo nace `localOnly`.** El repositorio recibe el estado inicial, y T-79 lo cambia por `pending` en los clientes que sincronizan.
- **La exportación JSON** lleva la operación sin el texto de las fuentes y cada movimiento con su estado de envío. Es el respaldo del punto de control del 14-oct.

## 4. Aceptación contra el caso real

`tool/t72_corpus_test.dart`, con A08 y con A08v_VGM:

1. **Plan:** escala GTSTC, con la geometría propuesta del propio archivo.
2. **Reproducción:** los 177 eventos en su orden. El intercambio de 128 y 145 se salta, porque es de T-80; **quedan 176 movimientos**, anexados por el repositorio real a un Hive en una carpeta temporal.
3. **Reapertura:** se cierra el repositorio, se abre de nuevo y se deriva desde lo guardado.

| Comprobación | Esperado | Obtenido |
|---|---|---|
| Movimientos guardados tras reabrir | 176 | **176** |
| Posiciones ocupadas contra `CASO_A08_ESTADO_FINAL.csv` | 460 iguales | **460 iguales** (contenedor por posición) |
| Conflictos | Solo 014-01-02 y 014-01-08 | **2, los dos «fuera de plan»** |
| Estados | 284 de paso, 176 movidos | **284 / 176**; 0 pendientes, 0 cancelados, 0 duplicados |
| Movimientos por bahía (cubierta/bodega), sección 2 del caso | 03 5/0 · 05/06 26/26 · 07 0/11 · 13/14 14/18 · 15 0/4 · 22 6/16 · 25/26 13/17 · 27 0/2 · 29/30 18/0 | **Iguales**: 82 en cubierta y 94 en bodega |
| Exportación | 176 movimientos | **176** |

**Las dos posiciones del intercambio.** Cada contenedor queda **movido en la celda donde lo registró el muelle**, que es la del estado final, y marcado con el conflicto que dice la derivación:

| Posición | Contenedor | Conflicto |
|---|---|---|
| 014-01-08 | XQDU0060080 (orden 128) | «planificado en 0140102, registrado en 0140108» |
| 014-01-02 | XRFU2642829 (orden 145) | «planificado en 0140108, registrado en 0140102» |

Cuando T-80 derive el cambio aprobado, la primera pasada moverá el plan efectivo y estos dos conflictos desaparecerán sin tocar los movimientos.

**El vacío de orden 85.** El plan ya trae ese vacío con número en `006-02-04` (`XQNU0333380`), así que no es una reserva: es uno de los 121 «contenedores que se cargan». La reproducción lo registra como `load_full` del contenedor del plan. La prueba comprueba que es el único caso y que su celda es la del plan.
- Lo que significa: `load_full` es «cargar un contenedor que el plan trae con número», sea lleno o vacío.
- El nombre del tipo se queda como lo fijó T-79a, porque lo usan las reglas propuestas.

## 5. Pruebas

**Nuevas en la suite (23):**

| Archivo | Casos |
|---|---|
| `test/t72_operation_state_test.dart` (16) | Plan combinado y lo que está a bordo antes de operar. Descarga. Descarga de un contenedor de paso, con y sin re-estiba, y su recarga. Carga en su celda, fuera de ella y de algo que no está en el plan. Cargar algo que va de paso. Celda ocupada. Duplicado contra «movido dos veces». Vacíos (asignación con tara real, celda ocupada, vacío en dos reservas, celda que no es reserva). Anular y anular la anulación. Corregir (el caso de 007-08-08). Cancelar. Independencia del orden. Tipos de T-80 y T-84 sin derivar. Avance por bahía y zona. Ida y vuelta por JSON. Validación del borrador |
| `test/t72_movement_log_test.dart` (7) | UUID v4, secuencia, autor, dispositivo y hora. Un borrador inválido no se guarda. Reabrir conserva todo y la secuencia continúa. **Caja truncada a mitad del último registro: abre sin él** (lo que prometió T-79a 7.1). Una operación con movimientos no se quita. Exportación. La escucha |

**Fuera de la suite:**
- `tool/t72_corpus_test.dart` (2): la aceptación de la sección 4.
- **Web sobre IndexedDB**, con una entrada aparte compilada para Web y abierta en Chrome (no queda en el repositorio). En tres cargas seguidas de la página hubo 1, 2 y 3 movimientos, con la secuencia continuando y el mismo identificador de dispositivo: **la bitácora sobrevive a recargar**.
- **Windows y Android** usan el almacén en archivos, el mismo que ejercen las pruebas en la máquina virtual de Dart sobre Windows. **En el Honor no se probó la bitácora**, porque T-72 no tiene pantalla; se verá en T-75.

**Un intento que no funcionó:** `flutter test --platform chrome` se quedó en «loading» más de diez minutos. Lo detuve y borré el archivo temporal que había puesto en `test/`; por eso hice la comprobación Web de la otra forma.

## 6. Decisiones

- **La escucha usa un aviso del propio repositorio, no `Box.watch()` de Hive.** La primera versión, con `watch()` dentro de un generador `async*`, no soltaba la caja al cancelar (la prueba se colgaba 30 s). Toda escritura pasa por el repositorio, también la remota en T-79, así que basta con avisar desde ahí.
- **Del contrato de T-79a 3.2 entra la parte local.** Lo propio de la sincronización (pendientes por autor, aceptar lo remoto, confirmar, rechazar, reintentar) lo agrega T-79 sobre el mismo almacén, para no dejar código sin uso.
- **El grupo del vacío no se valida aquí.** Saber si un vacío corresponde a una reserva de su grupo (tipo, puerto y línea) exige el listado de T-73, y es de la validación preventiva de T-77.
- **Sin cuentas todavía.** El autor lo pone quien llama. En Windows, y hasta T-79 en todos los clientes, es un nombre declarado sin `uid`.

## 7. Horas

- **Estimación:** la ficha dice 3.0 h; estimé ≈ 4.0 h antes de empezar.
- **Por qué no alcanzaban:** el plan combinado con reservas, el caso del orden 85 y la prueba de la caja truncada.
- **No incluye la aceptación de T-68 y T-69:** fueron 31 cargas en pantalla (10 en el Honor, 10 en Windows y 11 en Chrome), más compilaciones y ajustes de la automatización, y tardaron bastante más de lo que suele costar una aceptación.
- **No medí las horas reales con precisión,** así que no las afirmo. Yov las ajusta con la bitácora del sprint.

## 8. Archivos

**T-72:**
- `lib/features/vessel/domain/entities/movement.dart` (nuevo)
- `lib/features/vessel/domain/entities/operation.dart` (nuevo)
- `lib/features/vessel/domain/entities/entities.dart`
- `lib/features/vessel/domain/services/operation_state_deriver.dart` (nuevo)
- `lib/features/vessel/domain/repositories/movement_log_repository.dart` (nuevo)
- `lib/features/vessel/data/datasources/hive_movement_data_source.dart` (nuevo)
- `lib/features/vessel/data/repositories/movement_log_repository_impl.dart` (nuevo)
- `lib/features/vessel/data/repositories/local_vessel_repository_factory.dart`
- `test/t72_operation_state_test.dart` (nuevo)
- `test/t72_movement_log_test.dart` (nuevo)
- `tool/t72_corpus_test.dart` (nuevo)
- `docs/T72-RESULTADOS.md` (nuevo, este informe)

**Cómo repetir la aceptación:**

```
flutter test tool/t72_corpus_test.dart tool/t68_corpus_test.dart tool/t69_corpus_test.dart --dart-define=BAYSTREAM_CORPUS_DIRECTORY="C:\Users\Giova\OneDrive\Documentos\OneDrive\Desktop\Archivos .EDI\Anonimizados\files"
```
