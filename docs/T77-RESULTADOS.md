# T-77 · Validación antes de confirmar, con motivo escrito, y la aceptación de T-76

Timonel · 8-oct-2026 · rama `sprint-3`, sobre `3fe8950` · carril de `lib/`, `test/` y `tool/`

## 1. Resultado

| Tarea | Resultado |
|---|---|
| **Aceptación cruzada de T-76** (`21d73ab`, de Codex) | **PASA** en Windows, el Honor a 360 dp y Chrome, antes de tocar `lib/` (sección 2). Completé el Honor y Chrome, que Codex no pudo cerrar. No se cambió su código para aceptarla |
| **T-77** | **Hecha.** Pasa contra el corpus y en los tres clientes (secciones 3 a 6) |

- **Pruebas:** **449/449** (piso 437 + 12 nuevas). `flutter analyze` en **cero**, sin `// ignore:`.
- **Corpus:** **42/42**: los 36 de T-68 a T-76 y los 6 nuevos de T-77.
- **Sin cambios** en `pubspec.yaml` ni `pubspec.lock`. Sin dependencias nuevas.
- **No se tocó** `lib/main.dart`, las pantallas H5 ni los documentos que mantiene Yov.

**Las cifras de la ficha.**

| Criterio de T-77 | Resultado |
|---|---|
| Validar los 176 eventos del caso contra A08 | **Exactamente 2 avisos**, «fuera de plan» del **OR 128** y el **OR 145**. Ninguno más, ningún bloqueo. Igual con A08v_VGM |
| El OR 12 en una reserva de otro grupo | No se confirma sin motivo. Con motivo queda registrado y en conflicto «vacío de otro grupo» |
| Un 40 pies en una posición de 20 | No se registra, ni con motivo |
| Cargar en una de las 54 celdas que A07 descarga, sin marcar la descarga | Ofrece **«Marcar su descarga y cargar»**. Quedan los dos movimientos y ningún conflicto. En el caso completo son **54 de 54** |
| Límite de prueba de 90 000 kg, pila 014, bodega, fila 01 | Avisa con el peso resultante: en el corpus, **90.9 t** al tercer lleno y **121.2 t** al cuarto; en los clientes, **123.4 t** con los de A07 aún a bordo. Sin límite: «no evaluado» y no bloquea |

## 2. Aceptación cruzada de T-76

Se hizo **antes de cambiar el código**, sobre `3fe8950`: línea base **437/437**, `analyze` en cero y corpus T-68 a T-76 en **36/36**.

### 2.1 Las dos reglas nuevas del derivador, revisadas en el código

`lib/features/vessel/domain/services/operation_state_deriver.dart`:

1. **La descarga libera la celda en cualquier orden.** Antes de aplicar la bitácora, una pasada aparte (`departures`) aplica en el orden total solo las descargas y las cancelaciones del plano de llegada. Si el ocupante de llegada termina descargado, su celda se libera desde el principio. Comprobé:
   - una descarga **anulada** no es vigente y no libera la celda: la carga queda «celda ocupada»;
   - un contenedor **cancelado** antes de su descarga no se libera (la descarga sale en conflicto);
   - la descarga posterior no vuelve a liberar una celda que ya ocupa la carga (`occupied[...] == key`);
   - dos cargas en la misma celda siguen en conflicto: la regla solo afecta al ocupante de llegada.
2. **Una corrección sustituye toda su cadena.** `_voided` recorre `corrects` hacia atrás y apunta cada antecesor a la corrección vigente. Con A→B→C: C vigente; anular C deja vigente B y A sigue sin efecto; anular esa anulación devuelve C. La regla de ciclos sigue: un ciclo malformado no anula a nadie.

**Las dos cuadran con la ficha y con T-79a 2.5.** Lo confirmé además en pantalla (sección 2.3).

### 2.2 Cómo se probó en los clientes

Un banco privado, `lib/t77_client_acceptance.dart`, en una copia del código en **el temporal del sistema** (`%TEMP%\baystream_t77_acceptance`). Es el banco de Codex con tres cambios: namespace por `--dart-define` (`T77_NS`), los temas claro y oscuro de la app, y dos botones para poner y quitar el límite de prueba del perfil con `saveEditedProfile`. Usa la pantalla, los proveedores, el lector y el repositorio de producción; sus botones solo preparan las fuentes. Las cargas se registran en los controles de producción.

| Cliente | Almacén y método |
|---|---|
| Windows | El real, `C:\Users\Giova\AppData\Local\BayStream\vessel_store`, **namespace `t77acc`**. Abierto con `Start-Process explorer.exe -ArgumentList <exe>` y cerrado por PID |
| Honor NAA-LX3 | 720 × 1600 a densidad 320, **360 dp**. Variante propia **`gt.cmartinez.baystream.t77`** (el `applicationId` solo cambia en la copia privada), namespace `t77acc`. La app de Play y las variantes `.t68` a `.t76` no se tocaron |
| Chrome | Web de lanzamiento servida en `127.0.0.1:8797`, IndexedDB vacío. **Chrome propio con perfil aparte** en el scratchpad, manejado por el protocolo de depuración, con la ventana visible (`visibilityState: visible`) |

### 2.3 El recorrido completo

| Criterio | Windows (oscuro) | Honor 360 dp (oscuro) | Chrome (oscuro) |
|---|---|---|---|
| Al empezar: carga **176 (120/56)**, descarga **114 (66/48)** | PASA | PASA | PASA |
| Confirmar un lleno **por OR** (OR 3 en 025-06-02) → 175 (119/56) | PASA | PASA | PASA |
| Confirmar **por sufijo** (`5568`) | PASA | PASA | PASA |
| **Hora y marchamo**: el detalle separa la hora operada de la de registro | PASA (10:15, `W77A`) | PASA (10:20, `H77A`) | PASA (10:25, `C77A`) |
| **Deshacer inmediato** → 176 | PASA | PASA | PASA |
| **Corregir con `corrects`**: marchamo nuevo, hora conservada, motivo visible, una sola carga vigente | PASA | PASA | PASA |
| **Deshacer desde el detalle** | PASA («Marcado por error») | PASA (texto libre y «Marcado por error») | PASA («Marcado por error») |
| **OR 12** → `R:0030984` con **2 185 kg**; solo reservas libres de su grupo | PASA: 9 de 9, primero las 3 de la bahía 25 | PASA: las mismas 9 | PASA: las mismas 9 |
| **Reapertura** (PID y Explorer · `am force-stop` · recarga): 1 operación, 3 fuentes, 175 (120/55), el OR 12 con su celda y tara | PASA, 7 registros | PASA, 9 registros | PASA, 7 registros |

- **Nueve reservas, no cinco.** Codex vio cinco porque su almacén ya tenía cuatro vacíos del grupo asignados. En un namespace limpio el grupo 22G1 · JMKWL · LNA tiene sus 9 celdas: 003-09-82, 003-09-84, 003-10-82, 003-10-84, 025-06-04, 025-08-04, 025-08-06, 027-06-04 y 027-08-06, las del caso (sección 4).
- **Lo que comprueba la regla de cadena en pantalla.** Después de corregir, «Deshacer carga» anula la corrección y **vuelve la carga anterior** (con su marchamo original). Un segundo «Deshacer» la quita. Es justo T-79a 2.5 ampliada. **Observación para T-78 o T-97, no defecto:** el botón dice «Deshacer carga» y, tras una corrección, lo que deshace es la corrección. Un rótulo «Deshacer la corrección» lo diría mejor.
- **El «Deshacer» del aviso** dura 6 s. En Windows venció una vez antes de mi clic, como en T-75; en la ráfaga siguiente funcionó en los tres.

**T-76 cuadra en los tres clientes.** Con la parte de Windows de Codex y esta, puede pasar a Terminado.

## 3. T-77: qué se construyó

### 3.1 La revisión, en el dominio

`lib/features/vessel/domain/services/load_check.dart` (nuevo, Dart puro): `LoadValidator` revisa una carga contra el **estado derivado del propio dispositivo** (T-79a 2.8): plan combinado, bitácora y perfil. Devuelve un `LoadCheck` con:

| Qué | Tipo | Qué pasa |
|---|---|---|
| Un 40 en posición de 20, o al revés | `size` | **No se registra**, ni con motivo |
| Una celda que no existe | `unknownCell` | **No se registra**, ni con motivo |
| Un lleno fuera de su posición planificada | `outOfPlan` | Pide motivo. La derivación lo deja «fuera de plan» |
| Un vacío en una reserva de otro grupo | `otherGroup` | Pide motivo. La derivación lo deja «vacío de otro grupo» (nuevo, 3.3) |
| La celda la ocupa algo que no baja aquí | `cellTaken` | Pide motivo, como un «fuera de plan» (punto 3 de la ficha). La derivación lo deja «celda ocupada» |
| La pila supera el límite del perfil | `stackWeight` | Pide motivo. Muestra el peso resultante contra el límite |
| La celda la ocupa un contenedor que **baja aquí** y no se marcó | `dischargeFirst` | Ofrece «Marcar su descarga y cargar» |

`LoadingOperation` gana `check()`, `candidateSlots()` y `dischargeDraft()`. `draft()` aplica la revisión: rechaza lo bloqueado, exige motivo donde toca y exige `dischargeOccupant` si la celda la ocupa algo que baja. El motivo viaja en **`payload.reason`**.

### 3.2 Cómo decide cada regla

- **20/40.** Por el primer carácter del tipo ISO 6346: `2` es 20 pies; `4` y los largos de 41 a 53 pies (`G H K L M N P`) van en posición de 40. Bahía impar, 20; par, 40. Un código que no se reconoce no se juzga.
- **Celda inexistente.** La geometría declarada trae filas y niveles, pero **no la lista de bahías**. Por eso:
  - la fila y el nivel se comprueban con `VesselGeometry.covers`;
  - la bahía existe si aparece en el plano de llegada o en el de carga, ella o una vecina (una posición de 40 en la bahía par ocupa las dos impares).
  - **Es un supuesto declarado**, no una especificación del buque: una bahía vacía en los dos planes y sin vecinas se tomaría por inexistente. Cuando el perfil declare las bahías (T-27 o T-83), la regla las usa.
- **Peso de la pila.** Es la pila de T-67: bahía del BAPLIE, fila y zona, sin sumar las bahías vecinas.
  - Se suma **lo que está en la pila después de esta carga**: lo que sigue a bordo según el estado derivado, lo ya cargado y el contenedor nuevo. No se suma lo que todavía está solo planificado; eso ya lo dice el panel de T-67.
  - **Peso del listado** para lo que sube: VGM exacto del lleno y tara real del vacío. Para lo que ya venía, el peso efectivo del plan (T-66).
  - El ocupante que se va a descargar con «Marcar su descarga y cargar» no cuenta.
  - Sin límite, «no evaluado» y no bloquea. Con un contenedor sin peso, «no evaluado» salvo que la suma conocida ya pase el límite (las reglas de T-67).
- **Celda ocupada.** Si el ocupante es del plano de llegada, baja en esta escala y sigue planificado, se ofrece su descarga. Si no (de paso, ya cargado, otro vacío en la misma reserva), pide motivo.

### 3.3 Dos cambios pequeños en el derivador y el plan

- **«Vacío de otro grupo» es un conflicto derivado** (`ConflictKind.otherGroup`), como pide la tabla de T-79a 2.7.2. Para verlo en cualquier dispositivo, el derivador necesita el grupo del vacío, que solo trae el listado. `OperationPlan.build` acepta el listado y guarda `emptyGroups`. Sin listado, no se inventa el conflicto. La vista de carga de T-74 (`loading_plan_provider.dart`) pasa el listado al plan, para que su tabla también lo cuente.
- **El peso de pila sobre el límite no es un conflicto derivado.** T-79a no lo pone en su tabla. El motivo queda en `payload.reason` y la pila sigue a la vista en el panel de T-67. Si Yov o Carlos quieren el conflicto, es una regla más en el derivador.

### 3.4 En la pantalla

En los diálogos de confirmar de T-76 (`loading_controls.dart`):

- **Un lleno** muestra la posición planificada y un campo «Celda donde quedó (opcional)». Vacío, es la planificada; otra celda pide motivo.
- **Un vacío** ofrece primero las reservas libres de su grupo, luego las de su grupo que ocupa un contenedor que baja aquí («· ocupada, baja aquí»). Un interruptor «Mostrar reservas de otros grupos» añade las de otros grupos («· otro grupo»).
- **Al tocar una reserva**, el selector ofrece primero los vacíos de su grupo y luego los demás, marcados «Otro grupo: pide motivo».
- **La revisión** se ve debajo, con icono y texto, no solo color: «No se registra: …» (`error`), «Pide motivo: …» (`tertiary`), la descarga que falta (`primary`) y la línea del peso de la pila. Si no hay avisos: «Revisado: tipo, celda y grupo coinciden con el plan».
- **El campo «Motivo (obligatorio)»** aparece cuando hace falta, y el botón queda inactivo hasta que tiene texto. Ante un bloqueo no aparece: no hay motivo que valga.
- **«Marcar su descarga y cargar»** reemplaza a «Confirmar carga» cuando la celda la ocupa algo que baja. Registra la descarga y luego la carga. Su «Deshacer» inmediato anula las dos.

## 4. T-77 contra el corpus

`tool/t77_corpus_test.dart` (6) lee la carpeta externa y **no escribe nada**: la bitácora vive en memoria. Cada evento se valida contra el estado que dejan los anteriores y se registra como lo haría la pantalla.

| Escenario | Resultado |
|---|---|
| A08, los 176 eventos sin el intercambio | **2 avisos: OR 128 y OR 145, `outOfPlan`.** 0 bloqueos, 0 descargas pendientes, las 460 posiciones del CSV |
| A08v_VGM, lo mismo | Igual |
| A08 + A07, sin marcar descargas | Los mismos 2 avisos y **54 «Marcar su descarga y cargar»**. Las 460 posiciones del CSV, 2 conflictos (los del intercambio) y 60 descargas pendientes que no ocupan celdas de carga |
| A08 + A07, con las 114 descargas antes | Los mismos 2 avisos, 0 ofertas, descarga pendiente 0 |
| OR 12 en 007-02-02 (22G1 · PAMIT · LNC) | «La reserva 007-02-02 es de otro grupo (puerto PAMIT, línea LNC); el OR 12 es 22G1 · JMKWL · LNA.» Sin motivo, no; con motivo, asignado y en conflicto `otherGroup` |
| OR 12 en 006-02-84 (reserva de 40) | Bloqueado por largo, ni con motivo |
| OR 1 (45G1) en 025-06-02 | «Un contenedor de 40 pies (45G1) no cabe en 025-06-02: la bahía 025 es impar, de 20 pies.» Ni con motivo |
| Celda 022-99-02 y bahía 098 | Bloqueadas por inexistentes |
| Límite de prueba de 90 000 kg, pila 014, bodega, fila 01 | OR 128 → 30.3 t; OR 134 → 60.6 t; **OR 144 → 90.9 t, avisa**; **OR 145 → 121.2 t, avisa** |
| Sin límite, la misma pila | «no evaluado», sin aviso de peso |

**Con 90 t en toda la carga, 9 cargas avisan por peso en 7 pilas.** No es la cifra de T-67 (10 alertas con el mismo límite): T-67 mira el plan completo, con lo que todavía no sube; T-77 mira la pila física en el momento de cada carga, y en el caso los contenedores de A07 no cuentan porque no hay plano de llegada en ese escenario.

```
flutter test tool/t68_corpus_test.dart tool/t69_corpus_test.dart tool/t72_corpus_test.dart tool/t73_corpus_test.dart tool/t74_corpus_test.dart tool/t75_corpus_test.dart tool/t76_corpus_test.dart tool/t77_corpus_test.dart --dart-define=BAYSTREAM_CORPUS_DIRECTORY="C:\Users\Giova\OneDrive\Documentos\OneDrive\Desktop\Archivos .EDI\Anonimizados\files"
```

**42/42.** El corpus de T-76 no cambió: su `draft(row12, '0030984')` sigue pasando, porque 003-09-84 no está entre las 54 celdas que A07 descarga.

## 5. T-77 en los tres clientes

El mismo banco de la sección 2.2, con mis seis archivos de `lib/` copiados y un namespace nuevo, **`t77val`**, para no mezclar con la aceptación de T-76. Mismo almacén real en Windows, misma variante `.t77` en el Honor, mismo Chrome propio y origen.

| Criterio | Windows | Honor 360 dp | Chrome |
|---|---|---|---|
| **20/40**: OR 1 (45G1) en 025-06-02 → «No se registra», sin campo de motivo, Confirmar inactivo | PASA | PASA (legible a 360 dp) | PASA (`aria-disabled`) |
| **Celda inexistente**: 099-02-02 → «La bahía 099 no existe en este buque» | PASA | — | — |
| **Celda ocupada**: OR 145 en 014-01-08, ocupada por XSHU4021394 que baja → «Marcar su descarga y cargar»; un toque: carga 175, descarga 113 (66/47) | PASA | PASA | PASA |
| **Peso de la pila** con 90 t: OR 134 en 014-01-04 → «quedaría en 123.4 t y el límite del perfil es 90.0 t», pide motivo | PASA | PASA, y registrado con motivo: 174 (118/56), descarga 112 | PASA |
| **Sin límite**: la misma pila, «124.6 t / 123.4 t. Peso no evaluado: el perfil no declara límite», sin motivo | PASA | PASA | PASA |
| **OR 12 en otra reserva** (005-02-02 · otro grupo): Confirmar inactivo sin motivo; con motivo, asignado y en el detalle «quedó en una reserva de 22G1 · PAMIT · LNC» | PASA | PASA | PASA |
| **Reapertura**: el conflicto, el motivo, la tara y los pendientes siguen | PASA (3 registros) | PASA (5 registros) | PASA (3 registros) |

**El límite de 90 t vivió solo en el perfil de BUQUE GOLF del namespace `t77val`**, y se quitó con «Sin límite» antes de terminar en los tres clientes. El perfil real de Carlos no se tocó.

## 6. Pruebas

**Nuevas en la suite (12):**

`test/t77_load_check_test.dart` (10), con el fixture sintético de T-76:
- el plan tal cual no avisa y, sin límite, el peso sale «no evaluado»;
- lleno fuera de plan: sin motivo (ni con espacios) no; con motivo, «fuera de plan»;
- vacío de otro grupo por puerto y por línea; con motivo, conflicto `otherGroup`; sin listado, la derivación no lo inventa;
- el orden de las reservas que se ofrecen;
- 20/40 en los dos sentidos, ni con motivo; `nominalLength`;
- celdas inexistentes: fila, nivel, bahía y texto mal formado;
- celda ocupada por un contenedor que baja: su descarga y la carga, sin conflicto; también en una reserva;
- celda ocupada de verdad: motivo y conflicto «celda ocupada»;
- peso de la pila: dentro del límite, sobre el límite con motivo, sin límite y con un contenedor sin peso;
- una corrección revisa la celda nueva sin contar la carga corregida.

`test/t77_load_check_widget_test.dart` (2), **a 360 dp en claro y en oscuro**: 20/40 bloqueado sin campo de motivo, fuera de plan con motivo, «Marcar su descarga y cargar» con sus dos movimientos, y un vacío de otro grupo con motivo. Sin desbordes (`takeException` nulo).

**Las pruebas de T-76 no cambiaron.** Su contrato sigue: `slots()` devuelve solo las reservas libres de su grupo, y `draft()` sin motivo sigue rechazando una celda distinta de la planificada o de otro grupo.

```
flutter test                      → 449/449
flutter analyze --no-pub          → No issues found!
```

## 7. Incidencias y lo que queda

- **El clasificador de permisos no dejó copiar el corpus a `C:\Proyectos\baystream-privado\t77-aceptacion`.** Hice la copia privada en el temporal del sistema, como pidió Carlos. Ahí quedan el código, los binarios y el corpus como assets: `%TEMP%\baystream_t77_acceptance`. Nada del corpus entró al repositorio.
- **Carlos rechazó primero el control de la ventana de Windows.** Cerré la app por PID y seguí con el Honor; cuando dijo «retomemos también Windows», volví a pedir acceso.
- **Una segunda instancia en Windows.** Al reenfocar la ventana después de reabrir, la herramienta de pantalla abrió otra instancia del banco (PID 34108, 11:56:26). Las dos usaban el almacén real y el namespace `t77val`; la comprobación de 3 registros salió bien. Las cerré por PID.
- **El Honor estaba en «Opciones del desarrollador»** al empezar, como lo dejó la sesión de Codex. Abrí mi variante encima y no toqué esos ajustes. Un `BACK` de más cerró un diálogo sin registrar nada, y el teclado tapó una vez el botón: lo detecté en la captura y lo repetí.
- **El almacén real de Windows** queda con los namespaces `t77acc` (7 movimientos de T-76) y `t77val` (3 de T-77), además de los de antes. La bitácora es solo de anexar; su limpieza antes del piloto sigue pendiente (10.11).
- **El Honor** conserva la variante `.t77` con los namespaces `t77acc` y `t77val`.
- **Fuera de la ficha y anotado, no hecho:**
  - la cabecera de pesos por pila no marca una pila con pesos faltantes («28.7+?»), que 10.2 dejó «con T-77». La ficha de T-77 no lo pide y es de la vista de T-67;
  - `ContainerSlot.canAccept` sigue sin uso: T-77 no la necesitó;
  - el rótulo «Deshacer carga» tras una corrección (2.3).
- **Supuesto declarado:** la existencia de una bahía se deduce de los dos planes (3.2).

Evidencia fuera del repo, en `%TEMP%\baystream_t77_acceptance\evidence\` (`honor/`, `chrome/` y los registros de compilación). La suite y `analyze` quedaron en `build/t77/`, que Git ignora.

## 8. Horas

Hora de Guatemala, del reloj de la máquina. Horas de reloj, con compilaciones y clientes.

| Trabajo | Inicio | Fin | Horas |
|---|---|---|---:|
| Lectura de CLAUDE.md, AGENTS.md, SPRINT-3, el caso, T-79a y T-75/T-76 | — | ≈ 11:00 | no cronometrada |
| **Aceptación de T-76** (suite, corpus, revisión del derivador, banco y tres clientes) | ≈ 11:00 | 11:38 | **≈ 0.63 h** |
| **T-77** (diseño, código, pruebas, corpus, tres clientes e informe) | 11:38 | 12:10 | **≈ 0.53 h** |

El inicio de la aceptación es aproximado: no anoté la hora del primer comando; la primera marca de reloj es 11:10:37, al terminar la compilación de Windows.

**T-77: ≈ 0.53 h frente a 3.0 estimadas.** El derivador de T-72 y los diálogos de T-76 ya tenían casi todo lo que la revisión necesitaba.

## 9. Archivos

**Nuevos:**
- `lib/features/vessel/domain/services/load_check.dart`
- `test/t77_load_check_test.dart`
- `test/t77_load_check_widget_test.dart`
- `tool/t77_corpus_test.dart`
- `docs/T77-RESULTADOS.md` (este informe)

**Modificados:**
- `lib/features/vessel/domain/entities/operation.dart` (`ConflictKind.otherGroup`, `OperationPlan.emptyGroups`)
- `lib/features/vessel/domain/services/operation_state_deriver.dart` (conflicto «vacío de otro grupo»)
- `lib/features/vessel/domain/services/loading_operation.dart` (`check`, `candidateSlots`, `dischargeDraft` y `draft` con la revisión)
- `lib/features/vessel/presentation/providers/loading_plan_provider.dart` (el listado entra al plan)
- `lib/features/vessel/presentation/widgets/loading_controls.dart` (la revisión en los diálogos)

Los `.docx` y el `.pdf` modificados de `docs/` no son míos y no van en el bloque.
