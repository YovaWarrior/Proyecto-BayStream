# T-75 · Descarga: marcar en el plano lo que baja, con re-estiba y deshacer, con la aceptación de T-74

Timonel · 7-oct-2026 · rama `sprint-3`, sobre `500b44f` · carril de `lib/`, `test/` y `tool/`

## 1. Resultado

| Tarea | Resultado |
|---|---|
| **Aceptación cruzada de T-74** (`23525ae`, de Codex) | **PASA** en Windows, el Honor a 360 dp y Chrome, antes de tocar `lib/` (sección 2). No se cambió su código para aceptarla |
| **T-75** | **Hecha.** Pasa en los tres clientes y contra el corpus (secciones 3 a 6) |

- **Pruebas:** **420/420** (piso 412 + 8 nuevas). `flutter analyze` en **cero**, sin `// ignore:`.
- **Corpus:** **28/28**: T-68 y T-69 (20), T-72 (2), T-73 (2), T-74 (2) y el nuevo de T-75 (2).
- **Sin cambios** en `pubspec.yaml` ni `pubspec.lock`. Sin dependencias nuevas.
- **No se tocó** `lib/main.dart`, las pantallas H5 ni los documentos que mantiene Yov.

**La cifra de la ficha.** Con A07 confirmada en GTSTC, el modo Descarga muestra **114 pendientes: 66 en cubierta y 48 en bodega**, por bahía del BAPLIE: **003 3/0, 014 19/16, 021 0/12, 022 20/8, 023 0/12 y 030 24/0.** Igual en el corpus y en los tres clientes.

## 2. Aceptación cruzada de T-74

Se hizo **antes de cambiar el código**, sobre `500b44f`: línea base **412/412**, `analyze` en cero y corpus T-68, T-69 y T-74 en **22/22**.

### 2.1 Cómo se probó en los clientes

T-74 no tiene pantalla para registrar cargas (llega en T-76). Igual que Codex, usé un **banco de aceptación privado**, `lib/t75_client_acceptance.dart`, en una copia del código **fuera del repo** (`C:\Proyectos\baystream-privado\t75-aceptacion`). Es el banco de Codex con dos cambios: lee el corpus desde assets de esa copia y deja elegir el *namespace* del almacén. Usa la pantalla, los proveedores, el lector y el repositorio Hive de producción; sus botones solo preparan las fuentes y reproducen la bitácora.

| Cliente | Almacén |
|---|---|
| Windows | El real, `C:\Users\Giova\AppData\Local\BayStream\vessel_store`, abierto con `Start-Process explorer.exe -ArgumentList <exe>` y cerrado por PID. Como ese almacén ya tenía los 176 registros de la aceptación de Codex, el banco usó un **namespace propio, `t75acc`**, en el mismo directorio, para ver 176 → 0 desde cero sin tocar la operación de Carlos |
| Honor NAA-LX3 | 720 × 1600 a densidad 320, **360 dp**. Variante propia **`gt.cmartinez.baystream.t75`**, con un script de Gradle temporal que solo cambia el identificador y la firma de prueba; se retiró al terminar. La app de Play y las variantes `.t68` a `.t74` no se tocaron |
| Chrome | Web de lanzamiento servida en `127.0.0.1:8790`, con IndexedDB vacío. Chrome propio con perfil aparte, manejado por el protocolo de depuración y con la ventana visible (`visibilityState: visible`) |

### 2.2 Las cifras de la ficha

| Criterio | Windows | Honor 360 dp | Chrome |
|---|---|---|---|
| Una operación con tres fuentes (`arrival_baplie` A07, `loading_baplie` A08, `export_list`) | PASA | PASA | PASA |
| 121 OR en las celdas, con el **OR 85** en 006-02-04 | PASA | PASA (legible a 360 dp) | PASA |
| Las 55 reservas con su grupo (p. ej. 45G1/PAMIT/LNC y 45R1/PAMIT/LNC en 006-04-08 y 006-02-08); «0 celdas de carga sin cruce» | PASA | PASA | PASA |
| Tabla de 9 bahías: 03 1/4/0/0 · 05/06 14/12/16/10 · 07 0/0/6/5 · 13/14 14/0/18/0 · 15 0/0/4/0 · 22 6/0/16/0 · 25/26 0/13/7/10 · 27 0/0/0/2 · 29/30 18/0/0/0 → **82/94, 120/56** | PASA | PASA | PASA |
| Reproducir los 176 eventos: **176 → 0** pendientes, con «2 conflictos en la bitácora» (el intercambio, para T-80) | PASA | PASA | PASA |
| Cerrar y reabrir (PID, `am force-stop`, recarga): 1 operación, 3 fuentes, 176 registros | PASA | PASA | PASA |
| Releer A08v: solo cambia `loading_baplie` (`CORPUS_A08v_VGM.edi`); id, fecha y 176 registros se conservan | PASA | PASA | PASA |

Corpus de Codex (`tool/t74_corpus_test.dart`): **2/2**, con A08 y A08v_VGM.

**Una observación, no un defecto.** El texto de la fuente `export_list` mide 52 547 caracteres en Windows y Android, y 51 775 en Chrome. Es el JSON de los `double`: en la Web, `3900.0` se escribe `3900`. `ExportList.fromJson` lee los pesos como `num` y los convierte, así que el contenido es el mismo.

### 2.3 Las tres pruebas existentes que Codex cambió

**Ninguna dejó de comprobar lo que comprobaba.**

| Prueba | Qué cambió | Por qué no pierde nada |
|---|---|---|
| `test/profile_loading_test.dart` | Usa una bitácora en memoria (`T74MemoryLog`) y pasa `sourceKind: loadingBaplie` a `confirmGeometry` | Desde T-74, publicar un BAPLIE con escala escribe su fuente en la bitácora: sin la bitácora en memoria, la suite abriría el almacén real. El fixture no tiene cargas ni descargas en GTPBR, así que el tipo es ambiguo y ahora se pide (es el contrato nuevo); antes no existía la pregunta. Las aserciones sobre el perfil, su origen y el viaje siguen todas |
| `test/t68_port_of_call_test.dart` | Lo mismo, con `sourceKind: arrivalBaplie` | Igual. Las aserciones de la escala y de la preselección no cambiaron |
| `test/recent_voyages_test.dart` | Bitácora en memoria; la espera tras «Eliminar» lee el proveedor en lugar del almacén, y termina con `expect(... isEmpty)` | Antes el bucle esperaba a que el almacén quedara vacío **sin afirmarlo**. Ahora se afirma. `recentVoyagesProvider` lee `getAllVoyages()` del almacén y solo se invalida después de un borrado correcto, así que vacío en el proveedor significa vacío en el almacén. Las comprobaciones del estado vacío y del perfil conservado siguen. **Es más estricta que antes** |

Además comprobé, con la fecha de modificación de los archivos de `%LOCALAPPDATA%\BayStream\vessel_store`, que la suite completa no abre el almacén real: antes y después de correrla quedó en las 16:56:56 de mi banco.

## 3. T-75: qué se construyó

### 3.1 El modo «Descarga»

- **Dónde.** El selector del plano pasa de dos modos (Contenido, Número de orden) a tres. **«Descarga» solo aparece en un plano de llegada:** un viaje con escala confirmada y algo que baje en ella (`offersDischarge`). En A08 no aparece.
- **Fuera del modo**, tocar una celda abre el detalle, como siempre.
- **Dentro del modo:**
  - **Se descarga aquí** → un toque registra `discharge` con su posición, y aparece el aviso «Descargado · número · 003-08-84» con **«Deshacer»** durante **6 s** (la ficha dice «unos segundos»).
  - **Es de paso** → aviso de re-estiba: a qué puerto va, que no cuenta entre los que bajan, y un motivo opcional. Confirmado, el movimiento lleva `restow: true` y el motivo.
  - **Ya descargado, re-estibado, cancelado o en conflicto** → abre el detalle, donde se deshace.
  - **Celda vacía o reserva** → no pasa nada.
- **Sin operación guardada** para esa escala, el modo lo dice y no registra: hay que volver a abrir el BAPLIE de llegada y confirmar la escala (T-74 guarda ahí su fuente).

### 3.2 La marca en la celda

Cada marca lleva **icono y rótulo**, además del color, que sale de `colorScheme`. Así se distingue a 360 dp y en los dos temas.

| Estado | Icono | Rótulo | Color (`colorScheme`) |
|---|---|---|---|
| Por descargar | ↓ | BAJA | `primaryContainer`, borde `primary` |
| Descargado | ✓ en círculo | DESC. | `surfaceContainerHighest`, borde `outline` |
| De paso | barco | PASO | `surface`, borde `outlineVariant` |
| Re-estiba | ⇅ | RE-EST. | `secondaryContainer`, borde `secondary` |
| Cancelado (T-81) | prohibido | CANC. | `surfaceContainerHighest` |
| En conflicto | error | REVISAR | `errorContainer`, borde `error` |

### 3.3 Deshacer con `annul`, nunca borrando

- **Al momento:** el «Deshacer» del aviso registra `annul` con el motivo **«Marcado por error»**.
- **Después, desde el detalle:** «Deshacer la descarga» (o «la re-estiba») abre un diálogo con **«Marcado por error» de un toque** o **texto libre**; el botón del texto libre está inactivo mientras el campo está vacío.
- El aviso conserva el repositorio, no el `ref`: deshace aunque el usuario haya cambiado de pestaña.

### 3.4 Quién y cuándo

El detalle de la celda muestra, en cualquier modo: el estado en la escala («En GTSTC: descargado»), **«Registrado 07/10/2026 17:20 · Muelle (sin cuenta) · dispositivo f986cb2e»**, el motivo si lo hay, y los conflictos de ese contenedor.

**El autor es provisional hasta T-79.** La bitácora de T-72 exige un autor y todavía no hay cuentas: se registra `Muelle (sin cuenta)`, rol `dock`, sin `uid`, como prevé T-79a para Windows. El dispositivo sale del `deviceId` de T-72. T-79 cambia una constante (`dockOperator`).

### 3.5 Pendientes de descarga por bahía

- **`DischargeProgress`** (dominio, Dart puro) los calcula con el **estado derivado de T-72**, sin contador paralelo: cada movimiento vuelve a derivar.
- **Por bahía del BAPLIE**, como el plano agrupa sus bahías (un chip por bahía), y en cubierta y bodega. Las **re-estibas van aparte**, también en cubierta y bodega, y no restan de los pendientes.
- **En pantalla:** el resumen de la bahía elegida («Bahía 03 · pendientes de descarga: cubierta 3 · bodega 0 · descargados 0»), el total de la escala, y la tabla **«Pendientes de descarga»** con Bahía, Cub., Bod., Total, Desc. y Re-est.

### 3.6 Dos decisiones de diseño

**1. La descarga se deriva sobre el plan combinado.** El proveedor arma el plan con el plano de llegada que se ve y, si la operación lo tiene, el plan de carga de su fuente `loading_baplie`. Así una re-estiba encuentra al contenedor de paso en los dos planes, y las cargas de T-76 conviven con las descargas.

**2. La proyección de carga de T-74 deja fuera las descargas.** Su plan es solo el de carga, y no trae el plano de llegada: las 114 descargas le habrían salido como 114 conflictos «fuera del plan» en su tabla. `LoadingPlanProgress.loadingMovements` excluye los `discharge` y las anulaciones que los deshacen (también la anulación de una anulación). Los pendientes de carga no cambian. Comprobado en Windows: la tabla de carga sigue con sus **2 conflictos** del intercambio, no con 2 + las descargas.

**Lo que esto deja a la vista para T-76 y T-77.** Medí contra el corpus que **54 de las 176 celdas de carga de A08 son celdas que A07 descarga**. En el plan combinado, una carga registrada antes que la descarga de su celda sale «celda ocupada»: es lo correcto físicamente, pero T-77 tiene que avisarlo antes de confirmar, y T-76 tiene que decidir si su vista de carga usa el plan combinado. No lo cambié en T-75 porque la aceptación de T-74 reproduce las 176 cargas sin descargas.

### 3.7 La deuda de 10.10

`tool/t72_corpus_test.dart` y `tool/t73_corpus_test.dart` crean ahora su almacén temporal con `Directory.systemTemp.createTemp(...)`, como `tool/t74_corpus_test.dart`, y lo borran al terminar. Después de correr los 28 corpus, `build/t72/corpus-stores` y `build/t73/corpus-stores` siguen vacíos.

En `build/t72/test-stores/` quedan dos almacenes de 451 bytes del 7-oct a la 1:31. Son de las pruebas sintéticas de T-72, no del corpus. Están fuera de Git; no los borré.

## 4. T-75 en los tres clientes

Binarios de lanzamiento con `lib/main.dart` original y `--dart-define-from-file=C:\Proyectos\baystream-privado\firebase-prod.json` (sin abrir ni imprimir ese archivo), compilados en la copia privada con mi `lib/` sincronizado.

| Criterio | Windows (tema oscuro) | Honor 360 dp (tema oscuro) | Chrome (tema claro) |
|---|---|---|---|
| Modo Descarga en A07 · GTSTC: **114 (66 cub. / 48 bod.)** | PASA | PASA | PASA |
| Tabla: **003 3/0, 014 19/16, 021 0/12, 022 20/8, 023 0/12, 030 24/0** | PASA | PASA | PASA |
| Bahía 03 completa: 3 marcas → «cubierta 0 · bodega 0 · descargados 3», escala 111 | PASA | PASA | PASA |
| «Deshacer» inmediato (motivo «Marcado por error») | PASA | PASA | PASA |
| Deshacer desde el detalle | PASA («Marcado por error») | PASA (texto libre) | PASA («Marcado por error») |
| Quién y cuándo en el detalle | PASA | PASA, sin desbordes a 360 dp | PASA |
| De paso → aviso de re-estiba → `RE-EST.`, «re-estibas 1», los pendientes no cambian | PASA (con motivo) | PASA (sin motivo) | PASA (con motivo) |
| Cerrar y reabrir: marcas y pendientes iguales | PASA (cierre por PID y `explorer.exe`) | PASA (`am force-stop`) | PASA (recarga, 31 s antes de la lectura) |

- **Almacenes.** Windows usó el **almacén real** de Carlos, en la operación BUQUE GOLF · VIAJE007A · GTSTC que ya existía. El Honor usó `.t75`, el mismo almacén del banco. Chrome usó el mismo origen `127.0.0.1:8790` del banco; hubo que recargar dos veces para que el *service worker* tomara la compilación normal, sin borrar IndexedDB.
- **Los dos temas.** La app sigue el tema del sistema (`ThemeMode.system`), así que no toqué los ajustes de Windows ni del Honor, que están en oscuro. El tema claro se vio en Chrome, emulando `prefers-color-scheme: light`, y la suite prueba la pantalla en claro y en oscuro.
- **Los 114 completos** los cubre el corpus (sección 5). En pantalla bastaba una bahía completa, como dice la ficha.

## 5. Pruebas y corpus

**Nuevas en la suite (8), en `test/t75_discharge_test.dart`:**
- Pendientes por bahía, cubierta y bodega, sin contar lo de paso.
- Marcar baja el pendiente; `annul` lo devuelve; anular la anulación restaura la descarga.
- Re-estiba: `restow: true`, cuenta aparte, sin conflicto. Sin `restow`, un contenedor de paso que baja queda «en conflicto».
- `annul` exige motivo y la descarga exige posición.
- La proyección de T-74 deja fuera las descargas y sus anulaciones, en cadena.
- El modo Descarga solo existe en un plano de llegada.
- **La pantalla a 360 dp, en tema claro y en oscuro (2):** marcar, «Deshacer» del aviso, deshacer desde el detalle con texto libre, celda vacía sin efecto, re-estiba con motivo y la tabla.
  - Usa una bitácora en memoria (`test/support/t75_memory_log.dart`), así que no abre el almacén real.
  - El detalle se abre en ancho de escritorio. Sus filas previas a T-75 («Bay 003, Row 08, Tier 84») no caben en 360 con la fuente de prueba, donde cada letra es un cuadrado. En el Honor, con la fuente real, caben (sección 4).
  - **La prueba encontró un defecto mío, ya corregido:** el motivo de la re-estiba se perdía si se confirmaba antes del siguiente cuadro. El botón ahora lee el campo al pulsar.

**Corpus de T-75, `tool/t75_corpus_test.dart` (2), con A08 y con A08v_VGM como fuente de carga:**
1. Lee A08 y A07 y confirma GTSTC por el notificador real, sobre Hive en el temporal del sistema.
2. Comprueba **114 (66/48)** y las seis bahías de la ficha, por el **mismo proveedor que usa la pantalla**.
3. Marca los 114 uno por uno, y cada marca baja un pendiente en el proveedor vivo: **114 → 0**.
4. La carga de T-74 sigue en **176 pendientes y 0 conflictos**.
5. Cierra y reabre: siguen 0.
6. Anula los 114: **0 → 114**, y la bitácora tiene **228 movimientos**.
7. Una re-estiba: 114 pendientes, 0 descargados, 1 re-estiba.
8. Cierra y reabre: **229** movimientos y el mismo estado.

```
flutter test tool/t68_corpus_test.dart tool/t69_corpus_test.dart tool/t72_corpus_test.dart tool/t73_corpus_test.dart tool/t74_corpus_test.dart tool/t75_corpus_test.dart --dart-define=BAYSTREAM_CORPUS_DIRECTORY="C:\Users\Giova\OneDrive\Documentos\OneDrive\Desktop\Archivos .EDI\Anonimizados\files"
```

**Lo que no cubre una prueba con datos:** tocar una reserva en el modo Descarga. A07 no trae reservas y el fixture sintético tampoco; el código deja ese toque sin efecto (`onReservedSlotTap` vacío en el modo).

## 6. Incidencias

- **La pestaña de Chrome quedaba oculta.** La extensión abrió el banco en la ventana de Carlos, detrás de una pestaña suya, y no podía traerlo al frente sin tocar su ventana. Cerré esa pestaña y usé, como en T-72, un **Chrome propio con perfil aparte** en el scratchpad, por el protocolo de depuración. Lo cerré al terminar.
- **El «Deshacer» del aviso vencía antes de mi clic** en Windows y Chrome: entre la captura y mi siguiente acción pasan más de 6 s. No es un defecto. Lo probé marcando y deshaciendo en la misma ráfaga, y funcionó en los tres clientes.
- **El almacén real de Windows queda con lo que pedía la prueba:**
  - en la operación BUQUE GOLF: 4 descargas, 2 anulaciones y 1 re-estiba (7 movimientos). La bahía 03 queda con 2 descargados, 1 pendiente y la re-estiba;
  - el namespace `t75acc`, del banco de T-74: A07, A08, el listado y 176 cargas.
  - La bitácora es solo de anexar, así que esos registros no se borran desde la app.
- **El Honor** conserva la variante `.t75`, junto a `.t68` … `.t74`. La app de Play no se tocó.
- **Fuera de mi carril y anotado, no arreglado:** la fila del detalle (`_buildDetailRow`) no se adapta si el texto no cabe. En el Honor cabe; con letra del sistema muy grande podría no caber. Va con T-97 (texto a 360 px).

**Evidencia, fuera del repo**, en `C:\Proyectos\baystream-privado\t75-aceptacion\evidencias\`:
- `honor/` (h01–h17 para T-74, n01–n22 para T-75);
- `chrome/` (c01–c11 para T-74, w01–w18 para T-75);
- los registros de compilación.

La suite, `analyze` y los corpus quedaron en `build/t75/`, que Git ignora. La copia privada lleva el corpus como assets: **no se copió nada del corpus al repositorio.**

## 7. Horas

Hora de Guatemala, tomada del reloj de la máquina. Son horas de reloj, con compilaciones y clientes.

| Trabajo | Inicio | Fin | Horas |
|---|---|---|---:|
| Lectura de CLAUDE.md, AGENTS.md, SPRINT-3, el caso, T-79a y T-72/73/74 | — | 16:46:57 | no cronometrada |
| **Aceptación cruzada de T-74** (suite, corpus, banco y tres clientes) | 16:46:57 | 17:05:56 | **0.32 h** |
| **T-75** (diseño, código, pruebas, corpus, tres clientes e informe) | 17:05:56 | 17:33:30 | **0.46 h** |

**T-75: 0.46 h frente a 4.0 estimadas.** El derivador de T-72 ya trataba `discharge` y `restow`, y el banco y los ayudantes de clientes de la aceptación se reutilizaron.

## 8. Archivos

**Nuevos:**
- `lib/features/vessel/domain/services/discharge_progress.dart`
- `lib/features/vessel/presentation/providers/discharge_provider.dart`
- `lib/features/vessel/presentation/widgets/discharge_controls.dart`
- `test/support/t75_memory_log.dart`
- `test/t75_discharge_test.dart`
- `tool/t75_corpus_test.dart`
- `docs/T75-RESULTADOS.md` (este informe)

**Modificados:**
- `lib/features/vessel/domain/services/loading_plan_progress.dart` (`loadingMovements`)
- `lib/features/vessel/presentation/providers/loading_plan_provider.dart` (deriva solo la carga)
- `lib/features/vessel/presentation/widgets/loading_plan_controls.dart` (selector de tres modos)
- `lib/features/vessel/presentation/widgets/bay_plan_view.dart` (toque, marca y sección del detalle)
- `tool/t72_corpus_test.dart` y `tool/t73_corpus_test.dart` (temporal del sistema)

Los `.docx` y el `.pdf` modificados de `docs/` no son míos y no van en el bloque.
