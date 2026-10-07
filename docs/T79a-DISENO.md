# T-79a · Diseño del registro de movimientos y su sincronización

Timonel · 6-oct-2026 · rama `sprint-3`, sobre `79b39e1` · solo documentos: no toca `lib/`, `test/`, `pubspec.*` ni `firestore.rules`

Acompaña a este documento la propuesta de reglas [`docs/T79a-firestore.rules.propuesta`](T79a-firestore.rules.propuesta).

## 0. En una página

- **La unidad que se sincroniza es la operación:** una escala de un buque en un puerto. La publica la oficina con sus fuentes (BAPLIE de llegada, plan de carga y listado normalizado). El muelle la descarga una vez y desde ahí trabaja sin red.
- **La bitácora es solo de anexar.** Un movimiento se crea una vez, con un identificador UUID que nace en el dispositivo, y no se edita ni se borra. Se deshace con otro movimiento que lo anula, o con uno que lo corrige.
- **El estado no se guarda: se deriva.** El estado de cada contenedor, reserva y tapa sale de una función pura del dominio, que recibe el plan y los movimientos vigentes. Los choques entre dos dispositivos sin red no se resuelven en silencio: salen como conflictos que la oficina ve y anula.
- **Primero el almacén local, después la nube.** Cada movimiento se escribe en Hive antes de que la pantalla diga «registrado». Queda pendiente hasta que Firestore lo confirma. El reenvío es idempotente: el mismo id, el mismo documento, y las reglas solo aceptan como «actualización» el reenvío idéntico del propio autor.
- **Dos adaptadores detrás de un contrato:** Firestore para Android y Web, y uno sin sincronización para Windows, según la recomendación de 10.2. El dominio no sabe cuál corre.
- **Cuentas creadas por Carlos y lista de autorizados por UID**, con dos roles: muelle (`dock`) y oficina (`office`). Una cuenta que se registre sola no entra a nada.
- **Las reglas propuestas se probaron en el emulador local de Firestore:** 51 de 51 casos dieron lo esperado (sección 5.4). No se tocó ningún proyecto en la nube.
- **Horas:** T-80 cabe en 6.0. T-72 cabe en 3.0 si la derivación de los cambios de posición se queda en T-80 y la de las tapas en T-84. T-79 necesita ≈ 1.0 h más de las 10.0 que le quedan (sección 8).

**Tres decisiones nuevas quedan para Carlos** (sección 9): autorizar `crypto` como dependencia directa, la región de Firestore y quién crea las cuentas. La cuarta, la oficina en Chrome, ya estaba pendiente desde 10.2.

## 1. Supuestos y lo que el código actual impone

### 1.1 Supuestos de esta tarea

- **10.2:** Android (muelle) y Web en Chrome (oficina) sincronizan. La app de Windows funciona sin sincronizar: abre, dibuja, valida, exporta y, desde Sprint 3, lleva su bitácora local. Si Carlos decide otra cosa, cambia solo el adaptador de la sección 3.4.
- **Dependencias:** `firebase_auth` está autorizada (2.7). Versiones que resuelven con el repositorio, según T-70: `firebase_core` 4.13.0, `firebase_auth` 6.5.7 y `cloud_firestore` 6.8.0.
- **`lib/main.dart` no se toca.** Ya inicializa Firebase antes de `runApp`. Auth y Firestore se obtienen de forma perezosa desde la fábrica de `data/`, y la configuración por defecto de Firestore sirve (sección 4.6).
- **Los datos de prueba vienen del corpus**, fuera del repositorio: `CASO_A08_EVENTOS.json` (177 eventos) y `CASO_A08_ESTADO_FINAL.csv` (460 posiciones).

### 1.2 Tres hechos del código que condicionan el diseño

1. **El `id` de `ContainerUnit` y de `VesselVoyage` es un UUID nuevo en cada lectura** (`baplie_parser_service.dart`, `_uuid.v4()` en las líneas 51, 251, 420, 545 y 559). Si dos dispositivos leen el mismo BAPLIE, cada contenedor tiene un `id` distinto en cada uno. **La bitácora no puede referirse a un contenedor por ese `id`.** Usa claves naturales (sección 2.2).
2. **El almacén local guarda solo los últimos cinco viajes** (`LocalVesselRepository.recentVoyageLimit`, T-35). Al guardar el sexto, el más antiguo se borra. Si la bitácora viviera dentro del viaje, un movimiento sin enviar podría perderse por abrir otros cinco archivos. **La bitácora va en cajas propias**, sin ese límite (sección 4.1).
3. **La app de producción no usa Firestore hoy.**
   - `VesselRepositoryImpl.saveVoyage` solo lo llama la pantalla congelada de C3, a la que se llega por `tool/h5_main.dart`.
   - `baystream-app` todavía no tiene base de datos.
   - El `firestore.rules` de la raíz es del proyecto de H5 y no se toca: por eso la propuesta es un archivo aparte.

## 2. El modelo de la bitácora

### 2.1 La operación

Una **operación** es una escala: un buque, un viaje y un puerto de escala (UN/LOCODE, el de T-68). Reúne sus fuentes:

| Fuente | Qué es | Para qué |
|---|---|---|
| `arrival_baplie` | BAPLIE de llegada (A07) | Lo que se descarga en la escala (T-75) |
| `loading_baplie` | Plan de carga del planificador (A08), con sus reservas (T-69) | Lo que se carga y dónde (T-76) |
| `export_list` | Listado de la agencia normalizado (T-73), con las equivalencias ya aplicadas | Número de orden, VGM y tara reales, grupos de vacíos |

Además lleva el **perfil del buque** (`VesselProfile.toJson()`), para que el muelle dibuje el plano sin declarar la geometría otra vez.

- **Identificador:** `operationId`, un UUID v4 creado por quien publica. El paquete `uuid` ya es dependencia directa.
- **Fuentes:** se publican como texto. Cada dispositivo lo lee con su propio lector. Como las claves son naturales, no importa que los `id` internos salgan distintos.
- **Una operación sin publicar** es una operación local: así trabajan Windows y el modo de un solo dispositivo del punto de control del 14-oct.

### 2.2 Claves de los objetos

| Objeto | Clave | Ejemplo | Por qué es estable |
|---|---|---|---|
| Contenedor | `C:` + número ISO 6346 | `C:XQDU0060080` | Es el mismo número en el BAPLIE, en el listado y en la bitácora |
| Celda reservada (T-69) | `R:` + posición del plan | `R:0030984` | La reserva no tiene número de contenedor. Su posición en el plan publicado no cambia |
| Tapa de escotilla (T-83) | `T:` + bahía + `-` + número de tapa | `T:14-1` | Sale del perfil del buque, que viaja con la operación |

Un contenedor puede estar en el plan de llegada y en el de carga a la vez. Son los 284 que siguen a bordo en el caso: la clave es la misma y el plan combinado registra los dos papeles.

### 2.3 El movimiento

Todos los movimientos comparten el mismo sobre. Los nombres de campo están en inglés, como en el resto del código y en el documento `voyages` que ya existe.

| Campo | Tipo | Qué es |
|---|---|---|
| `id` | UUID v4 | Nace en el dispositivo al registrar. Es también el id del documento en Firestore |
| `schema` | int | Versión del formato (1) |
| `operationId` | UUID | La operación a la que pertenece |
| `type` | texto | Uno de los nueve tipos de 2.4 |
| `target` | texto o nulo | Clave del objeto (2.2); nulo en los movimientos sobre varios objetos |
| `payload` | mapa | Los datos propios del tipo |
| `author` | `{uid, name, role}` | **Quién.** En Android y Web, la cuenta; en Windows, un nombre declarado sin cuenta (3.4) |
| `deviceId` | UUID | Instalación que lo registró; se crea una vez por instalación |
| `sequence` | int ≥ 1 | Orden de los movimientos de ese dispositivo |
| `createdAt` | instante | **Cuándo se registró**, con la hora del dispositivo |
| `payload.operatedAt` | instante, opcional | **Cuándo ocurrió**, si se registra después, por ejemplo desde el papel. Es la columna HORA del listado |
| `receivedAt` | instante del servidor | Cuándo lo recibió la nube. Es informativo: **la derivación no lo usa** (2.7.2) |

### 2.4 Los nueve tipos

| `type` | Quién | `target` | `payload` | Tarea | En el caso real |
|---|---|---|---|---|---|
| `discharge` | muelle, oficina | `C:` | `position`, `restow` (bool), `reason`? | T-75 | Los 114 que bajan en GTSTC (A07) |
| `load_full` | muelle, oficina | `C:` | `position`, `order`?, `seal`?, `reason`? | T-76 | 120 llenos, por número de orden |
| `assign_empty` | muelle, oficina | `R:` | `container`, `tareKg`, `order`?, `seal`?, `reason`? | T-76 | 56 vacíos; p. ej. orden 12 → `R:0030984`, tara 2185 kg |
| `annul` | muelle (solo movimientos de muelle), oficina (cualquiera) | el del anulado | `annuls`, `reason` | T-72 | «Deshacer» de T-75 |
| `cancel_item` | oficina | `C:` o `R:` | `reason` | T-81 | Un contenedor del plan que no se embarca |
| `request_change` | muelle | nulo | `changes[]`, `reason` | T-80 | El muelle pide 128 ↔ 145 |
| `change_position` | oficina | nulo | `changes[]`, `request`?, `reason` | T-80, T-81 | La oficina lo aprueba (con `request`) o mueve por su cuenta (sin él) |
| `reject_change` | oficina | nulo | `request`, `reason` | T-80 | La oficina no aprueba |
| `hatch_cover` | muelle, oficina | `T:` | `action`: `remove` o `replace` | T-84 | Quitar y reponer una tapa |

- **`?`** marca un campo opcional.
- **`changes[]`** es una lista de uno a cuatro elementos `{target, from, to}`. El intercambio del caso es una sola solicitud con dos cambios: `C:XQDU0060080` de 0140102 a 0140108, y `C:XRFU2642829` de 0140108 a 0140102.
- **Corregir** no es un tipo aparte. Es un `discharge`, `load_full`, `assign_empty` o `hatch_cover` con `payload.corrects` = id del movimiento que reemplaza (2.5).

Ejemplo de la aprobación del intercambio, como documento de Firestore:

```json
{
  "id": "2f0c1d7e-3a94-4c55-9b7e-6a1f0e2d8c41",
  "schema": 1,
  "operationId": "8d3b0f52-1e6a-4b8f-a2c4-5e9d7f1a0b36",
  "type": "change_position",
  "target": null,
  "payload": {
    "request": "a71e9c04-5b2d-4f3a-8e61-0c9d2b7f4e15",
    "changes": [
      {"target": "C:XQDU0060080", "from": "0140102", "to": "0140108"},
      {"target": "C:XRFU2642829", "from": "0140108", "to": "0140102"}
    ],
    "reason": "Intercambio en bodega 14, mismo tipo, puerto, línea y peso"
  },
  "author": {"uid": "…", "name": "Oficina", "role": "office"},
  "deviceId": "…", "sequence": 3,
  "createdAt": "2025-10-04T21:12:05-06:00",
  "receivedAt": "<hora del servidor>"
}
```

### 2.5 Anular y corregir

- **`annul`** deja sin efecto un movimiento anterior. Es el «deshacer» de T-75 y la forma de resolver un conflicto. Exige motivo.
- **Corregir** es un movimiento nuevo con `payload.corrects`, que deja sin efecto al corregido **en la misma escritura**.
  - Por qué una sola escritura: con anular y luego registrar habría dos documentos, y si solo llegara el primero a la nube, la oficina vería un hueco.
  - Ejemplo: la corrección de 007-08-08 del caso es un `assign_empty` (orden 64, `R:0070808`) con `corrects` apuntando a la asignación equivocada. La bitácora conserva los dos pasos, como pide el caso.
- **Regla de vigencia:** un movimiento está vigente si ningún movimiento vigente lo anula (`annuls`) ni lo corrige (`corrects`).
  - Anular una anulación restaura el original.
  - Las referencias siempre apuntan a un movimiento que el autor ya tenía, así que no hay ciclos y la regla se calcula por recursión, sin importar el orden de llegada.

### 2.6 Propuesta: solo anexar

**Sí: la bitácora es solo de anexar.** Un movimiento no se edita ni se borra; se anula o se corrige con otro. Las razones:

1. **Es la bitácora que pide la tesis.** H3 y CU04 hablan de qué se hizo, quién y cuándo. En papel, el corrector líquido borra la historia (caso, sección 3); aquí la corrección queda con su autor y su hora.
2. **Sin red, no hay pérdidas.** Si el estado fuera un documento por contenedor que cada dispositivo actualiza, dos escrituras sin red sobre el mismo documento se pisarían: gana la última y la otra desaparece sin aviso. Con solo anexar, cada dispositivo crea documentos distintos y no hay nada que pisar.
3. **Idempotencia barata.** El id del documento es el id del movimiento. Reenviarlo produce el mismo documento, y la cola puede reintentar sin miedo a duplicar (4.3).
4. **Reglas simples y fuertes.** `create` con un esquema estricto; `update` solo para el reenvío idéntico del propio autor; `delete` nunca. Ni un cliente manipulado puede reescribir lo que otro registró (5.4).
5. **El BAPLIE de salida (T-82) y la vista de avance (T-78) salen de la misma derivación.** No hay dos verdades que reconciliar.

**Lo que cuesta:**
- El estado hay que derivarlo cada vez. Con unos 300 movimientos por operación (176 de carga más 114 descargas más las correcciones) es una pasada lineal, de microsegundos.
- La colección crece y no se compacta. Una operación son cientos de documentos de unos 600 bytes, lejos de cualquier límite.

**Alternativa descartada:** un documento de estado por contenedor, con historial aparte. Pierde escrituras concurrentes sin red, obliga a reglas que validen transiciones leyendo el historial, y duplica la verdad.

### 2.7 Cómo se deriva el estado

`OperationStateDeriver.derive(plan, movements)` es una función pura del dominio, sin Flutter, Hive ni Firebase. Corre igual en los tres clientes y en las pruebas.

#### 2.7.1 Los estados

T-72 los llama planificado, movido y cancelado:

| Objeto y papel | Planificado | Movido | Cancelado |
|---|---|---|---|
| Contenedor que se descarga en la escala | Por descargar | Descargado | Cancelado (no baja) |
| Contenedor de paso en la llegada | A bordo (no se opera) | Descargado para re-estiba (`restow: true`) → re-estibado al cargarlo de nuevo | — |
| Contenedor lleno del plan de carga | Planificado en su celda | Cargado (celda, hora, marchamo) | Cancelado (no embarca) |
| Celda reservada | Libre | Asignada (contenedor y tara) | Cancelada |
| Tapa | En su sitio | Quitada | — |

A cada objeto se le añaden dos marcas que no son estados:
- **«en conflicto»**, con la explicación;
- **«pendiente de envío»** o **«rechazado»**, que vienen de la cola (4.2) y no del dominio.

#### 2.7.2 El algoritmo

1. **Vigencia:** se descartan los movimientos anulados o corregidos (2.5).
2. **Orden total:** los vigentes se ordenan por `(createdAt, deviceId, sequence, id)`.
   - Son campos inmutables del documento, así que todos los dispositivos obtienen el mismo orden.
   - `receivedAt` no entra a propósito: el reenvío idempotente lo actualiza (4.3) y el orden cambiaría.
3. **Primera pasada, el plan efectivo.** Se aplican los `change_position` vigentes, en orden, sobre las posiciones del plan publicado.
   - Una solicitud queda **pendiente**, **aprobada** (un `change_position` la cita en `request`) o **rechazada** (un `reject_change` la cita).
   - Si el `from` de un cambio no coincide con la posición efectiva en ese momento, el cambio no se aplica y queda como conflicto.
4. **Segunda pasada, la operación.** Se aplican `discharge`, `load_full`, `assign_empty`, `cancel_item` y `hatch_cover`, en orden, **contra el plan efectivo final**.
   - Así, una carga registrada sin red antes de que llegara la aprobación del cambio no sale en conflicto cuando la aprobación llega.
   - Es justo el caso de 128 y 145: el evento 1 es el cambio y los eventos 129 y 146 son las cargas, pero en el muelle el orden de llegada puede ser otro.
5. **Conflictos.** Se marcan, no se resuelven en silencio:

| Conflicto | Ejemplo | Qué muestra la derivación |
|---|---|---|
| Doble operación del mismo objeto | Dos tarjadores sin red confirman el mismo lleno | Vale el primero en el orden. El segundo, si es la misma celda, es un duplicado inocuo; si no, es un conflicto |
| Celda ocupada dos veces | Dos vacíos asignados a `R:0030984` | Vale el primero; el segundo, en conflicto |
| Un vacío en dos celdas | El mismo contenedor en dos reservas | Vale la primera; la segunda, en conflicto |
| Fuera del plan | Un lleno en una celda distinta de la efectiva, o un contenedor que no está en el plan | Movido, en conflicto. T-77 lo frena al registrar; solo llega así con motivo escrito o desde otro dispositivo |
| Vacío de otro grupo | Un 40HC de PAMIT en una reserva de JMKWL | Asignado, en conflicto, con el motivo escrito |
| Cambio sobre algo ya movido | Se aprueba mover un contenedor que ya está cargado | El cambio no se aplica; conflicto |

**La oficina resuelve un conflicto anulando el movimiento que sobra.** La derivación se recalcula y el conflicto desaparece en todos los dispositivos.

**Salida de la derivación:**
- el estado de cada objeto, con el movimiento que lo dejó así;
- las solicitudes y su estado;
- los conflictos;
- los contadores por bahía y sección (cubierta y bodega): descargados, cargados, pendientes y cancelados. Es la vista de T-78 y el conteo del papel (caso, sección 3).

### 2.8 Validación preventiva y conflictos

**T-77 valida antes de escribir**, contra el estado derivado del propio dispositivo: celda, 20/40, peso de la pila, posición del planificador y grupo del vacío. Si algo no cuadra, pide confirmación con motivo; el motivo viaja en `payload.reason`.

**La derivación detecta lo que T-77 no podía ver**, porque ocurrió en otro dispositivo sin red. **Las reglas de Firestore no validan negocio:** validan forma, autor, rol y permisos. Meter la lógica del plan en las reglas exigiría leer el plan en cada escritura, y el límite es de 10 lecturas por evaluación (5.5).

## 3. El contrato de dominio y sus adaptadores

Las firmas son de ejemplo, para fijar el contrato; no son código de producción. Todo lo del dominio es Dart puro con `equatable` y `dartz`, como el contrato actual `LocalVesselRepository`. Los archivos nuevos van en carpetas que ya existen; no se reorganiza nada (2.6 de SPRINT-3).

### 3.1 Entidades — `domain/entities/movement.dart`, `operation.dart` (T-72)

```dart
enum MovementType { discharge, loadFull, assignEmpty, annul, cancelItem,
                    requestChange, changePosition, rejectChange, hatchCover }
enum OperatorRole { dock, office }

class MovementAuthor extends Equatable {
  final String? uid;          // null en Windows: sin cuenta
  final String name;
  final OperatorRole role;
  bool get verified => uid != null;
}

class Movement extends Equatable {
  final String id;            // UUID v4, nace en el dispositivo
  final String operationId;
  final MovementType type;
  final String? target;       // 'C:…' | 'R:…' | 'T:…' | null
  final Map<String, Object?> payload;
  final MovementAuthor author;
  final String deviceId;
  final int sequence;
  final DateTime createdAt;
  final DateTime? receivedAt; // de la nube; nunca entra al orden
  String? get annuls => payload['annuls'] as String?;
  String? get corrects => payload['corrects'] as String?;
}

class MovementDraft { … }     // lo que arma la pantalla: tipo, objetivo, payload

enum SendState { localOnly, pending, confirmed, rejected }
class MovementRecord extends Equatable {
  final Movement movement;
  final SendState state;
  final String? rejection;    // razón legible si state == rejected
}

class Operation extends Equatable {   // la escala
  final String id; final String vessel; final String voyage;
  final String portOfCall; final bool published; final bool closed;
  final DateTime? closedAt; final VesselProfile profile;
  final List<OperationSource> sources;
}
```

### 3.2 Bitácora local — `domain/repositories/movement_log_repository.dart` (T-72)

```dart
abstract class MovementLogRepository {
  /// Asigna id, autor, dispositivo, secuencia y hora; persiste con flush.
  /// Solo cuando devuelve Right la pantalla puede decir «registrado».
  Future<Either<Failure, MovementRecord>> append(MovementDraft draft);

  Stream<List<MovementRecord>> watch(String operationId);

  /// Para el adaptador de sincronización.
  Future<Either<Failure, List<MovementRecord>>> pendingOf(String operationId, String authorUid);
  Future<Either<Failure, void>> acceptRemote(Iterable<Movement> movements);
  Future<Either<Failure, void>> markConfirmed(String id, DateTime receivedAt);
  Future<Either<Failure, void>> markRejected(String id, String reason);
  Future<Either<Failure, void>> requeueRejected(String operationId);

  /// Punto de control del 14-oct: la bitácora en JSON, sin red.
  Future<Either<Failure, String>> exportJson(String operationId);

  Future<Either<Failure, void>> saveOperation(Operation operation, List<OperationSource> sources);
  Future<Either<Failure, List<Operation>>> getOperations();
}
```

### 3.3 Sincronización y sesión — `domain/repositories/operation_sync_repository.dart`, `session_repository.dart` (T-79)

```dart
enum SyncCapability { none, realtime }

sealed class SyncStatus {}
class LocalOnly extends SyncStatus {}                       // Windows
class UpToDate extends SyncStatus {}
class Sending extends SyncStatus { final int pending; }
class Offline extends SyncStatus { final int pending; }
class SessionExpired extends SyncStatus { final int pending; }
class NotAuthorized extends SyncStatus { final int pending; } // quitado de la lista
class SomeRejected extends SyncStatus { final int rejected; }

abstract class OperationSyncRepository {
  SyncCapability get capability;
  Stream<SyncStatus> status(String operationId);

  /// Oficina: operación y fuentes en un solo lote. Requiere red.
  Future<Either<Failure, void>> publish(Operation operation, List<OperationSource> sources);
  Stream<List<Operation>> watchOpenOperations();
  /// Muelle: descarga fuentes y movimientos, verifica y guarda en local.
  Future<Either<Failure, Operation>> join(String operationId);
  Future<Either<Failure, void>> close(String operationId);  // oficina

  Future<void> start(String operationId);   // escucha y envía
  Future<void> stop();
  Future<void> retryRejected(String operationId);
}

class Operator extends Equatable {
  final String? uid; final String name; final OperatorRole role;
}

abstract class SessionRepository {
  Stream<Operator?> watchOperator();      // incluye el último operador sin red
  Future<Either<Failure, Operator>> signIn(String email, String password);
  Future<Either<Failure, void>> signOut();
  Future<Either<Failure, void>> sendPasswordReset(String email);
}
```

La presentación usa solo estos contratos, como hoy usa `LocalVesselRepository`. Los proveedores de Riverpod los obtienen de una fábrica de `data/`.

### 3.4 Adaptadores — `data/`

| Archivo | Contrato | Plataforma | Qué hace |
|---|---|---|---|
| `datasources/hive_movement_data_source.dart` | — | todas | Cajas `{ns}_operations`, `{ns}_movements` y `{ns}_device` (4.1) |
| `repositories/movement_log_repository_impl.dart` | `MovementLogRepository` | todas | Igual que `LocalVesselRepositoryImpl`: `_guard`, escrituras serializadas, `CacheFailure` |
| `repositories/firestore_operation_sync.dart` | `OperationSyncRepository` | Android, Web | Publicar, unirse, cerrar; arma el motor de 4.3 con un `RemoteMovementStore` de Firestore |
| `repositories/sync_engine.dart` | — (interno) | Android, Web | El motor de la cola, en Dart puro, contra el puerto `RemoteMovementStore`. Se prueba con un falso en memoria |
| `repositories/local_only_operation_sync.dart` | `OperationSyncRepository` | Windows | `capability = none`; `status` emite siempre `LocalOnly`; `publish`/`join` devuelven un `Failure` claro («Windows no sincroniza: usa la oficina en Chrome») |
| `repositories/firebase_session_repository.dart` | `SessionRepository` | Android, Web | Firebase Auth más la lectura de `authorized/{uid}`; guarda en local el último operador para arrancar sin red |
| `repositories/local_session_repository.dart` | `SessionRepository` | Windows | Un nombre de operador que se declara una vez; rol `office`; `uid` nulo. **No llama a Firebase Auth** |
| `repositories/operation_sync_factory.dart` | — | — | Elige el adaptador con una importación condicional, como `local_store_directory.dart`: Web → Firestore; IO → Firestore en Android, local en Windows |

**El puerto `RemoteMovementStore`** es lo único del motor que toca Firestore:

```dart
abstract class RemoteMovementStore {          // interno de data/
  Future<void> put(Movement movement);        // set() con id = movement.id
  Stream<List<RemoteMovement>> watch(String operationId); // fromServer, receivedAt
  Future<AuthorizationState> authorizationOf(String uid);  // activo, inactivo, ausente
  Future<bool> isOperationClosedAfter(String operationId, DateTime createdAt);
}
```

**Por qué Windows no llama a Auth.** T-70 vio los errores de hilo de `firebase_auth` en Windows al usar Auth. Si el adaptador de Windows nunca crea `FirebaseAuth.instance`, no debería haber mensajes. Pero el plugin igual se enlaza en el binario de Windows al estar en `pubspec.yaml`, y eso **hay que comprobarlo en T-79** (prueba C8 de 7.3). Si aun así aparecen al arrancar, no hay forma de excluir una dependencia por plataforma en `pubspec.yaml`: se declara en H4 y en el informe.

#### Apéndice 3.4-A · Windows después de T-70b (7-oct)

**Qué condicionaba esta sección.** La decisión 10.3 mandaba que Windows usara el adaptador de Firestore **si T-70b pasaba**. **No pasó**: tres criterios de cuatro (`docs/T70b-RESULTADOS.md`).
- Pasan la hora con el listener (120 de 120), el cierre forzado con pendientes (por la persistencia del SDK) y la memoria.
- **Falla la renovación del token:** 50 de 50. Con el emulador, el SDK de Windows manda la renovación a `securetoken.googleapis.com` en vez de al emulador, y la sesión deja de poder escribir pasada la hora.

**Lo que queda para T-79, mientras Carlos no decida otra cosa:**
1. **La fábrica no cambia:** Windows → `LocalOnlyOperationSync` y `LocalSessionRepository`. La oficina sincroniza desde la Web instalada en Chrome o Edge, el respaldo de 10.3.
2. **Si una prueba con un proyecto real** (T-70b, sección 6.3) mostrara que Windows renueva el token, el cambio es una línea de la fábrica: Windows → `FirestoreOperationSync` y `FirebaseSessionRepository`. El contrato de dominio no cambia. En ese caso Windows usaría la persistencia del SDK, que T-70b probó contra el cierre forzado, **además** de la cola en Hive, que sigue siendo la fuente de verdad (4.1).
3. **Para todos los clientes, nuevo en 4.5.** El SDK puede quedarse sin token **sin avisar**: T-70b no vio ningún error en el listener ni en `idTokenChanges`. Por eso el motor no se fía solo de los códigos de error.
   - Si un movimiento lleva **más de 5 minutos** pendiente con el listener recibiendo del servidor, el estado pasa a `SessionExpired`.
   - La pantalla dice «sin confirmar desde las HH:MM · inicia sesión de nuevo».
   - Iniciar sesión otra vez vacía la cola: T-70b lo comprobó, y no se perdió nada.
   - El umbral de 5 minutos es **PROVISIONAL**.
   - Prueba nueva para 7.1: el `RemoteMovementStore` falso deja de confirmar sin dar error.

## 4. La cola persistente

### 4.1 Dónde vive

Tres cajas Hive nuevas, con el mismo directorio y el mismo motor que el almacén actual (`localStoreDirectory()`: carpeta privada en Android, `%LOCALAPPDATA%\BayStream` en Windows, IndexedDB en Web):

| Caja | Clave | Valor |
|---|---|---|
| `{ns}_operations` | `operationId` | Operación, perfil y texto de las fuentes, para abrir sin red |
| `{ns}_movements` | `movement.id` | `{schemaVersion, data: movimiento, send: {state, rejection, attempts}}` |
| `{ns}_device` | `deviceId` | El UUID de la instalación, creado una vez |

- **Sin límite de cinco.** Una operación con movimientos pendientes o rechazados no se puede borrar desde la app. Las demás se archivan a mano.
- **La secuencia no se guarda aparte.** Al abrir se toma el máximo `sequence` propio y se suma uno. Así no hay dos escrituras que puedan quedar a medias.
- **Codec:** el mismo patrón versionado que `LocalVesselCodec` (`schemaVersion`; una versión desconocida no se interpreta a ciegas).

### 4.2 Estados de envío

```
            append()                     set() confirmado / eco del servidor
 [pantalla] ────────► PENDIENTE ─────────────────────────────────────► CONFIRMADO
                         │  ▲                                    (eco de otro dispositivo
                         │  │ reintentar (Carlos corrigió         entra directo aquí)
                         │  │ el permiso o el dato)
            permiso      ▼  │
            denegado ─► RECHAZADO            Windows: append() ─► SOLO LOCAL (fin)
```

- **PENDIENTE y CONFIRMADO cuentan para el estado derivado.** En el pendiente, la pantalla lo marca «sin enviar».
- **RECHAZADO no cuenta, pero no se borra.** Se ve en la bitácora en rojo, con la razón, y se puede exportar o reintentar.
- **SOLO LOCAL** es el estado normal en Windows. No es «pendiente», para que la pantalla no anuncie un envío que nunca va a ocurrir.

### 4.3 Envío, confirmación e idempotencia

1. **`append()`** valida (T-77), arma el movimiento y hace `put` y `flush` en Hive. Solo entonces devuelve y la pantalla dice «registrado».
2. **El motor** envía cada pendiente propio con `set()` sobre `operations/{op}/movements/{id}`, en orden de `sequence`. El SDK de Firestore aplica las escrituras de un cliente en el orden en que se emiten. Eso importa: una anulación de un movimiento propio llega después del anulado, y la regla del muelle encuentra el documento que anula.
3. **La confirmación viene de dos lados, y basta uno:**
   - el `Future` de `set()` termina (el servidor confirmó);
   - el listener entrega el documento con `hasPendingWrites == false`.
4. **El listener** escucha toda la subcolección `movements`, sin consulta ni índice. Lo que llega de otros dispositivos entra a la caja como CONFIRMADO, por id: si ya estaba, no se duplica.
5. **Reenvío.** Al arrancar, al volver la sesión y al pulsar «reintentar», el motor vuelve a emitir `set()` de todo lo pendiente propio. Es el mismo id y el mismo contenido. Si el primer envío sí había llegado, para el servidor es una actualización, y **las reglas la aceptan solo si el autor es el mismo y no cambia nada más que `receivedAt`** (5.2). Por eso no hay duplicados ni falsos rechazos. Lo comprobé en el emulador: reenviar dejó un solo documento (5.4).

**Lo que hace el SDK por su cuenta.**
- En Android, Firestore guarda en disco sus escrituras pendientes y las reintenta. Algunas pueden ir dos veces: la nuestra y la del SDK. Las reglas lo absorben.
- En Web se deja la caché en memoria, que es la opción por defecto. La cola durable es la nuestra, en Hive, y se evita la persistencia de Firestore con varias pestañas.

### 4.4 Al cerrar la app

| Momento del cierre | Qué queda | Qué pasa al volver |
|---|---|---|
| Antes de que `append()` devuelva | Nada, o el registro completo: al abrir la caja, la recuperación de Hive descarta un último bloque incompleto. T-72 lo prueba cortando la escritura, no se da por hecho | Si la pantalla no dijo «registrado», el tarjador lo vuelve a marcar |
| Registrado, sin enviar | PENDIENTE en Hive | Se reenvía al arrancar |
| Enviado, sin confirmación | PENDIENTE en Hive (y quizá en la cola del SDK en Android) | Se reenvía; si ya había llegado, el reenvío es el no-op permitido |
| Confirmado | CONFIRMADO | Nada |
| Cerrar la pestaña de Chrome | Igual que arriba: Hive en IndexedDB | Igual que arriba |

T-70 solo probó una cola en memoria. **Que la escritura sobreviva al cierre se prueba en T-79** (C2 y C4 de 7.3).

### 4.5 Sesión vencida, cuenta dada de baja y rechazos

**Errores.** El motor clasifica el código de `FirebaseException`:

| Código | Interpretación | Acción del motor | Lo que ve el usuario |
|---|---|---|---|
| `unauthenticated`, o `authStateChanges` emite `null` | Sesión vencida o cerrada | Pausa el envío; todo queda PENDIENTE | «Sesión vencida: inicia sesión para enviar N movimientos» |
| `permission-denied`, y `authorized/{uid}` no existe o está inactivo | Carlos quitó la cuenta de la lista | Pausa; **no marca nada como rechazado** | «Tu cuenta ya no está autorizada. N movimientos esperan» |
| `permission-denied`, la operación se cerró y `createdAt` es posterior al cierre | Llegó tarde | RECHAZADO ese movimiento | «La operación se cerró antes de este movimiento» |
| `permission-denied` en los demás casos | El contenido no pasó las reglas (por ejemplo, anular algo que la nube no tiene) | RECHAZADO ese movimiento | «La nube rechazó este movimiento: …» |
| `unavailable`, `deadline-exceeded`, `aborted`, `resource-exhausted`, `internal` | Red o servicio | Sigue PENDIENTE; el SDK reintenta | «Sin conexión · N por enviar» |
| `invalid-argument`, `failed-precondition` | Error de la app | RECHAZADO, con el detalle en el registro | «Error de la aplicación: exporta la bitácora» |

**Sesión.**
- **Cuándo vence:** el token de Firebase dura una hora y el SDK lo renueva solo. La sesión vence de verdad cuando la cuenta se deshabilita o se borra, o cuando cambia su contraseña.
- **Sin red no hay renovación, ni hace falta:** Auth recuerda al último usuario en Android y Web, y el muelle trabaja todo el turno.
- **Cada movimiento lleva su autor.** Si en el teléfono entra otra cuenta, los pendientes de la anterior no se envían con la nueva, porque las reglas exigen `author.uid == request.auth.uid`. Quedan esperando a su autor o se exportan.
- **No hay suplantación.**

**Antigüedad.** Las reglas rechazan un `createdAt` de más de siete días o de más de diez minutos en el futuro. Un teléfono sin red una semana tendría que exportar. En una escala de dos días no ocurre.

### 4.6 Varias pestañas y configuración

- **Dos pestañas de la oficina** comparten las cajas de IndexedDB, pero no la memoria. Lo que registre una no se ve en la otra hasta que el listener lo trae de la nube. Ninguna pisa a la otra, porque las claves son ids únicos. Pueden repetir un `sequence`, y el `id` desempata el orden.
- **Se recomienda una sola pestaña**, y T-79 lo prueba (C4).
- **Firestore no necesita `Settings` especiales:** Android con su caché en disco y Web en memoria son los valores por defecto. Por eso no hace falta tocar `main.dart`.

## 5. Firestore: colecciones, documentos y reglas

### 5.1 Colecciones

```
authorized/{uid}                          ← la escribe Carlos en la consola
operations/{operationId}                  ← la publica la oficina
operations/{operationId}/sources/{id}     ← texto de las fuentes, en trozos
operations/{operationId}/movements/{id}   ← la bitácora
```

| Documento | Campos | Quién escribe | Quién lee |
|---|---|---|---|
| `authorized/{uid}` | `role` (`dock` u `office`), `name`, `active` (bool) | Solo la consola | Cada usuario, el suyo |
| `operations/{id}` | `id`, `schema`, `vessel`, `voyage`, `portOfCall`, `status` (`open`/`closed`), `createdBy`, `createdAt`, `profile` (mapa), `sources` (manifiesto); al cerrar, `closedBy` y `closedAt` | Oficina: crear y cerrar, una vez | Autorizados |
| `operations/{id}/sources/{id}` | `id`, `kind`, `sha256`, `part`, `parts`, `content` (≤ 900 000 caracteres), `createdBy`, `createdAt` | Oficina, en el mismo lote que la operación; inmutable | Autorizados |
| `operations/{id}/movements/{id}` | El sobre de 2.3 | Autorizados, según su rol; inmutable | Autorizados |

- **Tamaños.** El BAPLIE más grande del corpus (A01) pesa 164 KB y entra en un trozo. Los sintéticos de 5 000 y 10 000 contenedores de T-99 caben en dos o tres. El límite de Firestore es 1 MiB por documento y 10 MiB por petición.
- **Índices compuestos: ninguno.**
  - La lista de operaciones abiertas es `where('status', isEqualTo: 'open')` y se ordena en el cliente.
  - El listener lee la subcolección entera.

### 5.2 Las reglas, en resumen

El archivo completo está en `docs/T79a-firestore.rules.propuesta`. Lo esencial:

1. **Identidad.** Solo entra una cuenta con `authorized/{uid}` existente y `active == true`. El rol sale de ese documento, nunca de lo que diga el cliente.
2. **Movimientos.**
   - `create` exige el esquema exacto del sobre (`hasOnly` y `hasAll`), que el id del documento sea el del movimiento, autor igual a la cuenta, rol igual al de la lista, tipo permitido para ese rol, `payload` válido para el tipo, `receivedAt == request.time` y la operación abierta (o cerrada después de `createdAt`).
   - `update` solo admite el reenvío idéntico del autor.
   - `delete` nunca.
3. **Permisos por rol.** El muelle no cancela objetos del plan, no aprueba ni rechaza cambios y solo anula movimientos de muelle; para esto último, la regla lee el movimiento anulado. La oficina puede todo eso.
4. **Operaciones.** Las crea la oficina en un lote con sus fuentes; la regla de fuentes usa `getAfter` para ver la operación del mismo lote. La única edición es cerrar, una vez. No se reabre ni se borra.
5. **Todo lo demás, cerrado.** Incluye `voyages` y `latency_test`, que en producción no usa ninguna pantalla.

**Lo que las reglas no hacen:**
- No validan el negocio (2.8).
- No validan cada elemento de `changes[]`, porque el lenguaje no tiene bucles: limitan su tamaño a 1–4, y la derivación descarta un cambio mal formado.

### 5.3 Costo de una operación

- **Lecturas de las reglas:** cada escritura de movimiento hace hasta tres lecturas de documento (la lista de autorizados, la operación y, si el muelle anula, el anulado). El límite es 10 por evaluación, y Firebase las cobra como lecturas.
- **Estimación para el caso:** 178 movimientos, dos dispositivos y una carga inicial de unos 300 documentos por dispositivo. Salen alrededor de 200 escrituras y menos de 2 000 lecturas en el día.
- **La cuota sin costo** es de 20 000 escrituras y 50 000 lecturas diarias.

### 5.4 La propuesta, probada en el emulador

**Cómo se probó.**
- Emulador local de Firestore 1.22.0, edición standard, proyecto `demo-t79a` (sin recursos reales), puerto 8181.
- Firebase CLI 15.32.1, la de T-70.
- Las peticiones van por la API REST del emulador, con tokens sin firmar como los que él acepta.
- La escritura replica `set()` del SDK, con la hora del servidor como transformación.
- El guion y el emulador quedaron en el scratchpad de la sesión, fuera del repositorio. T-79 lo convierte en `tool/t79_reglas.mjs`.

**Resultado: 51 de 51 casos dieron lo esperado.**

| Grupo | Casos | Ejemplos |
|---|---:|---|
| Operación y fuentes | 5 | El muelle no crea operaciones; la oficina crea operación y fuente en un lote; una fuente no se modifica; la operación no se borra |
| Lectura | 9 | Sin sesión, sin estar en la lista o inactivo: no lee. Cada uno lee solo su registro de autorizado. `voyages`, cerrada |
| Movimientos del muelle | 20 | Confirmar un lleno sí. El reenvío idéntico sí, y no duplica. Editar, borrar, firmar como otro, declarar otro rol, id distinto, campos extra, tipo desconocido, hora una hora en el futuro, tara negativa: no. Seis horas sin red: sí. Descarga, vacío, tapa y corrección: sí |
| Cambio de posición (T-80) | 6 | El muelle pide; el muelle no aprueba; la oficina aprueba y rechaza; el muelle no cancela y la oficina sí |
| Anular | 5 | El muelle anula lo del muelle, no lo de la oficina ni algo inexistente. La oficina anula lo suyo. Sin motivo, no |
| Cierre | 6 | El muelle no cierra; la oficina cierra y no reabre; un movimiento nuevo tras el cierre, no; uno sin red anterior al cierre, sí; una fuente nueva en una operación cerrada, no |

Al final, la subcolección tenía **13 documentos**, uno por cada movimiento permitido. El reenvío idéntico no creó el decimocuarto.

**Lo que esta prueba no cubre:**
- El SDK de Flutter real (lo hace T-79, en 7.3).
- Firebase Auth real: el emulador acepta tokens sin firmar.
- El proyecto de producción. La edición y el motor de reglas de producción pueden diferir del emulador, y por eso C9 de 7.4 se repite en `baystream-app` con cuentas reales.

## 6. Pasos de consola para Carlos en `baystream-app`

Los hace Carlos; aquí solo se describen. **Antes de cada paso, comprobar en el selector de la consola que el proyecto es `baystream-app` y no `baystream-h5-temporal-20260814`, que no se toca.**

### 6.1 Crear Firestore

1. Consola de Firebase → `baystream-app` → **Bases de datos y almacenamiento → Firestore → Crear base de datos**. La ruta del menú es la de la guía actual; puede cambiar de nombre.
2. **Edición: Standard.** Es la de la guía de inicio de Firestore y la que corre el emulador con que se probaron T-70 y estas reglas.
3. **ID de la base de datos:** `(default)`. La app usa `FirebaseFirestore.instance`.
4. **Ubicación.** No se puede cambiar después. Se recomienda **`northamerica-south1` (Querétaro)**, la región más cercana a Guatemala de la lista de Firestore. Alternativa: la multirregión de Estados Unidos, con más disponibilidad. Si la consola no deja elegir, el proyecto ya tiene una ubicación por defecto: anotarla.
5. **Modo: producción**, que niega todo hasta publicar las reglas. **Nunca el modo de prueba:** abre la base a cualquiera y es lo que causó H-03.

### 6.2 Activar correo y contraseña

6. **Authentication → Comenzar → Método de acceso → Correo electrónico/contraseña → Habilitar → Guardar.** Dejar apagado «vínculo de correo electrónico (acceso sin contraseña)».

### 6.3 Crear las cuentas y la lista de autorizados

7. **Authentication → Usuarios → Agregar usuario**, una por persona (por ejemplo, Carlos como oficina y un tarjador como muelle). Correo y una contraseña temporal que se entrega en persona. Copiar el **UID** de cada usuario.
8. **Firestore → Datos → Iniciar colección `authorized`**. Un documento por usuario:
   - ID del documento: **el UID**.
   - Campos: `role` (cadena: `dock` u `office`), `name` (cadena: el nombre visible) y `active` (booleano: `true`).
9. **Los correos y los UID no se escriben en el repositorio**, que es público. El informe de T-79 solo cuenta cuántas cuentas hay y de qué rol.

**Para dar de baja a alguien:** `active` a `false`. Sus movimientos ya registrados siguen en la bitácora.

### 6.4 Publicar las reglas

10. **Cuándo:** después de que T-79 vuelva a pasar la batería de 5.4 sobre la versión final del archivo.
11. **Firestore → Reglas.** Reemplazar todo por el contenido de `docs/T79a-firestore.rules.propuesta` → **Publicar**.
12. **Comprobación en el simulador de reglas de esa misma pestaña** (*Rules Playground*; el nombre en español puede variar):
    - un `get` de `operations/x` sin autenticación debe salir denegado;
    - uno con un UID de la lista, permitido.
13. **No publicar con `firebase deploy`.**
    - `firebase.json` hoy solo tiene `hosting`, y `.firebaserc` apunta a `baystream-app`.
    - Si alguien agregara un bloque `firestore` que apunte a `firestore.rules` de la raíz, **publicaría en producción las reglas del proyecto de H5**.
    - Si más adelante se quiere usar la CLI, el bloque debe apuntar al archivo de producción. Esa es una decisión aparte.

### 6.5 Lo que no hace falta

- No hacen falta índices compuestos (5.1), huellas SHA de Android (el acceso es por correo, no con Google) ni un `google-services.json` nuevo: las opciones siguen llegando por `--dart-define-from-file` (T-47).
- **Plan Spark:** alcanza (5.3). La pestaña **Uso** de Firestore sirve para anotar las lecturas y escrituras reales de la prueba de T-79.

## 7. Plan de pruebas de T-79

### 7.1 En la suite (Dart, sin dispositivos)

| Prueba | Qué comprueba | Tarea |
|---|---|---|
| Derivación con fixtures sintéticos | Los estados de 2.7.1; anular, anular una anulación, corregir; los seis conflictos de 2.7.2; cambio aprobado después de la carga sin conflicto | T-72 |
| Orden total | Los mismos movimientos en tres órdenes de llegada dan el mismo estado | T-72 |
| Bitácora local con Hive en carpeta temporal | `append` + cerrar + reabrir: el pendiente sigue y la secuencia continúa. Un archivo de caja truncado a mitad del último registro abre sin él. Una operación con pendientes no se borra. Exportar JSON | T-72 |
| Motor con un `RemoteMovementStore` falso que imita las reglas (crear una vez, reenvío no-op) | Confirmación por `set` y por eco. Sin red queda pendiente. Reinicio: reenvía los mismos ids sin duplicar | T-79 |
| Errores del motor | Permiso denegado con cuenta inactiva → pausa sin rechazar. Con cuenta activa → rechazo. `unauthenticated` → `SessionExpired`. Operación cerrada → rechazo con razón | T-79 |
| Autor | Pendientes de otra cuenta no se envían tras cambiar de usuario | T-79 |
| Windows | `LocalOnly` siempre; `publish` y `join` devuelven el `Failure` de 3.4; la sesión local no toca Firebase Auth | T-79 |

### 7.2 Reglas en el emulador

`tool/t79_reglas.mjs`, con los 51 casos de 5.4 más los que agregue T-80. Debe pasar entero antes del paso 11 de la consola.

### 7.3 Dos dispositivos contra el emulador

Como en T-70: proyecto `demo-`, Honor por `adb reverse` y Chrome visible. La reproducción no escribe documentos a mano: pasa por el mismo camino de la app (`append` → cola → motor).

- **Cómo:** un punto de entrada aparte, `tool/t79_replay_main.dart`, como `tool/h5_main.dart`. Se ejecuta en cada dispositivo con `flutter run -t`.
- **Qué lee:** `CASO_A08_EVENTOS.json` desde `BAYSTREAM_CORPUS_DIRECTORY`.

| # | Prueba | Resultado esperado |
|---|---|---|
| C1 | La oficina (Chrome) publica la operación de A08 con su listado. El muelle (Honor) la ve y se une | El Honor dibuja 405 contenedores y 55 reservas sin tener el archivo |
| **C2** | **Los 177 eventos entre dos dispositivos.** El Honor (muelle) registra los 120 llenos, los 56 vacíos y la solicitud del intercambio. Chrome (oficina) aprueba la solicitud cuando le llega. El Honor espera a ver la aprobación antes de confirmar las órdenes 128 y 145. A mitad de la corrida: modo avión real en el Honor durante unos 40 eventos, cierre forzado de la app con pendientes (`am force-stop`), reapertura, fin del modo avión | **178 documentos** en `movements` (120 + 56 + solicitud + aprobación), cada id una sola vez; cero conflictos; Honor y Chrome derivan el mismo estado; **las 460 posiciones coinciden con `CASO_A08_ESTADO_FINAL.csv`** (contenedor y origen por posición); los conteos por bahía y sección coinciden con la tabla de la sección 2 del caso (82 cubierta + 94 bodega) |
| C3 | Dos tarjadores sin red. Honor y un segundo cliente con rol muelle asignan vacíos que chocan (dos a la misma reserva, y uno a dos reservas) | Al reconectar, los dos dispositivos muestran los mismos conflictos y el mismo ganador. La oficina anula el sobrante y todo converge |
| C4 | Chrome sin red (pestaña sin conexión): tres movimientos, recarga de la pestaña, red de vuelta. Luego dos pestañas a la vez | Tras recargar siguen pendientes; al volver la red llegan una vez. Con dos pestañas no se pierde ni se duplica nada |
| C5 | Baja y alta en la lista: `active = false` para el muelle a mitad de una corrida y luego `true` | Pausa con «cuenta no autorizada», ningún movimiento rechazado; al reactivar se envía todo |
| C6 | Sesión vencida: deshabilitar la cuenta en el emulador de Auth | `SessionExpired`, pendientes intactos; al habilitar e iniciar sesión, se envían |
| C7 | Cierre: la oficina cierra con un movimiento del muelle pendiente, registrado antes del cierre, y luego el muelle registra otro | El primero entra; el segundo queda RECHAZADO con «la operación se cerró antes» |
| C8 | Windows: abrir A08, registrar 5 movimientos, cerrar y reabrir, exportar | `LocalOnly`; los 5 siguen tras reabrir; el registro de la app no muestra los errores de hilo de `firebase_auth` de T-70; el informe dice qué almacén usó (`%LOCALAPPDATA%` o `Packages`) |

### 7.4 En producción, después de los pasos de consola

| # | Prueba | Resultado esperado |
|---|---|---|
| C9 | Dos cuentas reales (oficina en `baystream-app.web.app`, muelle en el Honor) y una operación corta llamada «PRUEBA T-79», con unos diez movimientos y un intercambio | Los dos ven el mismo avance. El muelle no puede aprobar: la pantalla no lo ofrece y, si se fuerza, la nube lo niega. Una cuenta sin lista no lee nada. **Es el «reglas verificadas en uso real» de la ficha** |
| C10 | Anotar las lecturas y escrituras de la pestaña Uso | Comparadas con 5.3 |

- **Limpieza:** la operación de prueba no se puede borrar desde la app (5.2). Carlos la borra desde la consola si quiere.
- **No es H5:** si se mide latencia, va como orientativa, igual que T-70.
- **Nada se publica antes del 17-oct** (2.2 de SPRINT-3): C9 usa la Web compilada en local contra `baystream-app`, o espera al 17.

## 8. Cómo quedan T-72, T-79 y T-80

| Tarea | Qué hace con este diseño | Horas de la ficha | Estimación | Comentario |
|---|---|---:|---:|---|
| **T-72** | Entidades `Movement` y `Operation`; cajas y `MovementLogRepository`; el plan combinado (llegada + carga + reservas de T-69); la derivación de descarga, carga, vacío, anular, corregir y cancelar, con conflictos; exportar JSON; pruebas 7.1 | 3.0 | **3.0–4.0** | Cabe en 3.0 si la derivación de cambios de posición pasa a T-80 y la de tapas a T-84, que es donde nacen esos movimientos. El riesgo es el plan combinado con las reservas: +1.0 si T-69 deja trabajo |
| **T-79** | `firebase_auth`; sesión e inicio de sesión; publicar, unirse y cerrar; motor de la cola; adaptador de Windows; estado en pantalla; pruebas 7.1–7.4 | 12.0 (2.0 son T-79a) | **≈ 13.0** | De las 10.0 que quedan: sesión e inicio 2.0, publicar/unirse 2.0, motor 2.0, Windows 0.5, pantalla 1.0, pruebas del motor y reglas 1.5, dos dispositivos y producción 2.0 = **11.0**. Falta ≈ 1.0 h |
| **T-80** | Rol desde `authorized`; la pantalla según el rol; solicitar desde el muelle; bandeja de la oficina para aprobar o rechazar; derivación de solicitudes y cambios; casos de reglas nuevos; aceptación del intercambio 128 ↔ 145 entre dos dispositivos | 6.0 | **≈ 5.5** | Las reglas de los dos roles ya están probadas aquí |

**De paso, T-81 se abarata:** «mover o cancelar desde la oficina» son `change_position` sin `request` y `cancel_item`, que ya tienen regla y derivación. Le quedan la pantalla y su prueba. Sus 4.0 h podrían bajar a ≈ 2.5, lo que compensaría el exceso de T-79. Eso lo decide Yov al abrir la ola 3.

**Recorte si el 14-oct aprieta** (punto de control):
- Lo primero que se corta es **publicar las fuentes**: cada dispositivo abre el mismo archivo y la operación se identifica por su huella. Ahorra ≈ 1.0 h, pero el tarjador necesita el archivo en el teléfono.
- Lo segundo, la sincronización entera: queda el modo de un solo dispositivo, con la bitácora exportable de T-72.

## 9. Decisiones para Carlos

1. **`crypto` como dependencia directa.**
   - Para qué: la huella SHA-256 de las fuentes, que permite verificar que el muelle bajó el archivo entero y el mismo.
   - Ya está en `pubspec.lock` como transitiva. No está en la lista de 2.7, así que necesita su autorización.
   - Sin ella, la verificación se reduce a número de trozos y longitud.
   - **Recomendación: autorizarla.**
2. **Región de Firestore:** `northamerica-south1` (Querétaro), o la multirregión de Estados Unidos. No se cambia después.
3. **Cuentas:** las crea Carlos en la consola (recomendado, sección 6.3) o se agrega un registro en la app.
   - Con el registro abierto, cualquiera podría crear una cuenta con un correo ajeno.
   - Como la lista es por UID, esa cuenta no entraría a nada, pero Carlos tendría que verificar a mano a quién pertenece cada UID antes de autorizarlo.
4. **La oficina en Chrome (10.2)** sigue pendiente. Este diseño la supone, y si cambia, solo cambia la fábrica de 3.4.

## 10. Lo que se hizo en esta tarea

- **Leído:** 10.2 y las fichas de T-72 y T-75 a T-81 de `SPRINT-3.md`, `docs/T70-RESULTADOS.md` completo, `docs/S3-CASO-MAGELLAN-STAR.md`, el almacén local (`data/datasources/`, `data/repositories/`, `domain/repositories/`), `vessel_repository_impl.dart`, `main.dart` (solo lectura), `firestore.rules`, `firebase.json` y `.firebaserc`, y la estructura de `CASO_A08_EVENTOS.json` y `CASO_A08_ESTADO_FINAL.csv`.
- **Comprobado en la documentación de Firebase:**
  - las ubicaciones de Firestore (incluida `northamerica-south1`) y que no se cambian;
  - la persistencia sin conexión: activa por defecto en Android, apagada en Web;
  - el límite de 10 lecturas por evaluación de reglas, que además se cobran;
  - la cuota sin costo y los límites de tamaño;
  - los modos de producción y de prueba al crear la base.
- **Probado:** la propuesta de reglas en el emulador local, 51 de 51 (5.4). Se usó una copia del JAR del emulador que T-70 ya había descargado, en la carpeta temporal de la sesión: no se descargó nada nuevo ni se tocó la carpeta de la espiga.
- **No tocado:** `lib/`, `test/`, `pubspec.*`, `firestore.rules`, `firebase.json` ni ningún proyecto en la nube. En el árbol hay cambios de Codex en `lib/` (T-68, en curso); no son míos y no los toqué.
