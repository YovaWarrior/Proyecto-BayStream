# T-130 · La operación publicada acepta el plan que le falta · Resultados

Timonel (Claude Code, Claude Fable 5.1). Rama `sprint-4`, carpeta del rediseño
(`C:\Proyectos\baystream-rediseno`), punta `687d68d` («Sprint 4: decisiones 10.84 a 10.88…»).
Es el hallazgo 1 (P1) de la tercera prueba piloto (10.85 de `SPRINT-4.md`): la oficina publicó
la operación del MAGELLAN STAR 26043S con el plano de llegada para empezar la descarga, el plan
de carga llegó después y la app lo rechazó; la carga se hizo con un rodeo (otra operación, con
una copia del plan que decía 26043X en `TDT`). Carlos decidió que se corrige antes del 7-nov.

**Las dos fases están entregadas.** La fase 1 (el paso 0 y la sección «Diseño», 1 a 5) la
aprobó Carlos el 2-nov con las cinco decisiones de 3.14 y seis ajustes, más dos cambios de Yov
(T-132 en la base, así que el nombre del archivo de salida y la nota del viaje los hace T-130;
la base se comprueba antes de tocar nada). La fase 2 (6 a 15: la base, lo hecho, las pruebas con
sus cifras, las reglas en el emulador, cómo publicarlas y cotejarlas, la lista del piloto, los
archivos y el bloque de Git) se escribió el 3-nov sobre `a18d2d3`, con T-129 y su corrección y
la mezcla de T-132 en `sprint-4`, sin esperar a T-131, que se cruza con T-130 solo en
`vessel_overview_page.dart` (3.11). **Cifras:** 37 pruebas nuevas en verde, la suite en 1951 de
1951, `analyze` en cero, y en el emulador 69, 25, 31 y 38 de 38 contra las reglas de T-130.

## 1. Paso 0: la base, lo que hay en el árbol y lo que leí

- **La punta** es `687d68d`, con las decisiones 10.84 a 10.88 y la lista del piloto al día
  (`git log --oneline -12`, `git show --stat HEAD`). Es lo que pedía el encargo.
- **T-129 no está en commits.** `git diff --stat` marca
  `lib/features/vessel/data/repositories/firestore_operation_sync.dart` (+18/−1, el arreglo de
  `close()`), y sin seguimiento están `test/support/t129_fake_firestore.dart`,
  `test/t129_cierre_test.dart`, `tool/t129_evidencia.py` y `docs/T129-RESULTADOS.md`. Mientras
  leía, ese informe cambió en el disco: otro chat está haciendo sus corridas en esta misma
  carpeta (su sección 6.1, en Claude Opus 5.5). No toqué nada de eso. Como manda el encargo,
  **la fase 1 sigue** (solo escribe en `docs/`) **y la fase 2 espera** a que Carlos confirme la
  mezcla de T-132 en `sprint-4`, con T-129 adentro, y a su luz verde sobre `lib/`, `test/` y
  `pubspec.*` (con los ajustes de 3.14, ya no espera a T-131). Antes de tocar nada, la base se
  comprueba: la suite completa en una corrida tiene que dar 1912 y `analyze` cero (3.10).
- **Otros cambios ajenos**, los de siempre: `test/t114_fase3_correccion_test.dart` y tres
  archivos de `windows/flutter/` (solo fin de línea) y `docs/t117/entrega1/` sin seguimiento.
  No son míos y no van en ningún bloque.
- **Al cerrar esta fase** (2-nov, 21:30), `git diff --stat` traía además `SPRINT-4.md` (+18: la
  decisión 10.89, de Yov) y `pubspec.yaml` con `pubspec.lock`: la dependencia de desarrollo
  `cloud_firestore_platform_interface: 8.0.6` que Carlos autorizó en 10.89 para rehacer la nube
  falsa de T-129, porque `cloud_firestore` marca `@sealed` sus clases y la línea base no admite
  `// ignore:`. Tampoco los toqué. Dos consecuencias para T-130: el commit de T-129 cambia
  `pubspec.*` (lo declaro aquí para que nadie lo atribuya a esta tarea), y esa nube falsa en la
  capa de plataforma sirve para probar `addSource` contra el SDK (3.10), cosa que T-127 no pudo
  hacer con `replaceSource`.
- **Leí**, en el orden del encargo: `CLAUDE.md` con `AGENTS.md`; de `SPRINT-4.md`, 10.49 a
  10.52, 10.76 a 10.79 y 10.83 a 10.88; `docs/T122-RESULTADOS.md` (8, 8.3, 8bis y la O1);
  `docs/T127-RESULTADOS.md` completo; `docs/T129-RESULTADOS.md`; `docs/piloto/LISTA-PILOTO.md`
  (0, 1, 2, 3 y 5); y el código: `operation_sources.dart`, `firestore_operation_sync.dart`,
  `source_revisions.dart`, `sync_engine.dart`, `operation_state_deriver.dart`,
  `departure_baplie_writer.dart`, `operation.dart`, `operation_sync_repository.dart`,
  `local_only_operation_sync.dart`, `vessel_providers.dart` (el flujo de `loadVesselFromFile`,
  `_useProfile`, `_publish` y `confirmGeometry`), `voyage_ui_state.dart`,
  `vessel_overview_page.dart` (`_loadBaplieFile`, `_confirmPreview`, `_askForGeometry` y el
  diálogo «Tipo de BAPLIE»), `cloud_page.dart` (`openOperationSource` y la lista de
  operaciones abiertas), `sync_providers.dart`, `loading_operation_provider.dart`,
  `loading_plan_provider.dart`, `discharge_provider.dart`, `export_list_providers.dart`,
  `export_list_import_page.dart` (la tarjeta de T-127), `aviso_del_listado.dart`,
  `departure_baplie_page.dart`, `vessel_voyage.dart` y la lectura del `TDT` en
  `baplie_parser_service.dart`; las reglas `docs/T127-firestore.rules.propuesta` y sus baterías
  `tool/t127_reglas_revision.mjs`, `tool/t80_reglas.mjs`, `tool/t113_reglas_abuso.mjs`, con
  `tool/t127_baterias.ps1` y `tool/t113_emulador.ps1`; y las pruebas de T-127 con la nube falsa
  de T-79 (`test/support/t79_fake_cloud.dart`, `test/t127_listado_revision_test.dart`,
  `test/t127_listado_pantallas_test.dart`).
- **Nada se corrió:** ni Flutter, ni Dart, ni el emulador, ni un navegador. Solo lecturas de
  Git y de archivos. Por eso no hubo líneas `SEMÁFORO:`.
- **Dos matices entre el encargo y lo que hay, que no cambian el diseño:**
  - el mensaje que vio Carlos en la 0.4.0 dice «…sus **fuentes** no cambian…» (10.50); el
    «…sus **BAPLIE** no cambian; solo el listado de la agencia se puede reemplazar…» es el de
    la 0.4.1, desde T-127. El código de hoy es el segundo;
  - el punto 9 del encargo cita T-103 para «el BAPLIE de salida con los dos planos». T-103 es la
    lectura de la 1.5 (SMDG15, 10.35 de `SPRINT-3.md`); lo de los dos planos en la salida es la
    decisión del 11-oct que aplica T-82 (`_aboard`: manda el plan de carga, la llegada respalda
    lo no declarado) y «Comparar con la llegada» es T-96. La página de la salida cita T-103 solo
    para rechazar una fuente en 1.5. El diseño lo trata en 3.9 con esos nombres.
- **Las reglas publicadas hoy** son las de T-80 (10.108 de `SPRINT-3.md`) hasta que Carlos
  publique las de T-127 con la 0.4.1 (lista del piloto, 0.1 y 4.0). Las de T-130 parten de las
  de T-127 y las incluyen: si la 0.4.1 todavía no se ha publicado cuando T-130 esté aceptada,
  se publica el archivo de T-130 en lugar del de T-127 y el cotejo se hace contra ese archivo
  (3.7).

## 2. Resultado de la fase 1 en tres líneas

- **Una operación publicada y abierta acepta el BAPLIE que le falta:** el plan de carga cuando
  solo tiene el plano de llegada, y el plano de llegada cuando solo tiene el plan de carga. Una
  fuente de cada tipo, como hoy; **reemplazar** un BAPLIE que ya está no entra en la 0.4.x (3.2).
- **Viaja como el listado de T-127:** la oficina confirma en un diálogo que dice el viaje que
  declara el archivo y sus cifras, el plan sube en un solo lote con sus huellas, el muelle lo baja
  solo, avisa y sigue sin reiniciar; `join` trae los dos planos; los movimientos no se tocan y el
  estado se vuelve a derivar. La operación conserva su viaje y la fuente agregada recuerda el que
  declara su archivo (3.3). Sin red, nada cambia hasta reconectar.
- **Las reglas** son las de T-127 más dos cláusulas (agregar la entrada del manifiesto y sus
  trozos, solo la oficina, solo con la operación abierta, solo si el tipo no estaba) y un ajuste
  de una línea al trozo publicado; con una batería nueva y las tres de siempre en el emulador,
  también en rojo contra las de T-127. Un cliente 0.4.0 o 0.4.1 no daña nada y se puede unir a
  una operación con un plan agregado (3.8).

## 3. Diseño (decide Carlos)

**La regla de diseño que se conserva de T-127:** los BAPLIE son el contrato de las claves
naturales de los movimientos (`C:número`, `R:posición`) y de sus posiciones del plan. Por eso un
BAPLIE publicado **no cambia**. Lo que T-130 abre es distinto: **completar** la operación con el
BAPLIE que todavía no tiene, que no altera ninguna clave ya usada. Todo lo demás se reutiliza de
T-127 tal cual: el lote único con las huellas, el motor que escucha el documento de la operación,
`join` que arma lo que el manifiesto declara, las reglas en el mismo estilo, las baterías en el
emulador y la tabla de compatibilidad.

### 3.1 Qué se puede agregar

**Lo que dice el código hoy.** `OperationSources.save` (`operation_sources.dart`) encuentra la
operación de la escala por buque, viaje y puerto (`find`); si está publicada, acepta la misma
fuente con el mismo texto (no cambia nada), acepta un `export_list` nuevo o distinto (T-127, por
`replaceSource`) y rechaza cualquier BAPLIE con el `ValidationFailure` «La operación de esta
escala ya está publicada y sus BAPLIE no cambian; solo el listado de la agencia se puede
reemplazar…». El manifiesto `sources` de `operations/{id}` es un mapa por tipo
(`arrival_baplie`, `loading_baplie`, `export_list`), y `Operation.sources` guarda una fuente por
tipo. Las reglas de T-127 solo dejan actualizar `sources.export_list` (`validListRevision`).

**Lo que hace T-130.**

- Una operación **publicada y abierta** acepta **el BAPLIE que no tiene**: `arrival_baplie` si
  solo tiene `loading_baplie`, o `loading_baplie` si solo tiene `arrival_baplie`. Con o sin
  listado. Sigue siendo una fuente de cada tipo: nunca una segunda del mismo tipo, nunca un
  cuarto tipo, nunca con la operación cerrada.
- **Solo la oficina**, con sesión autorizada (`_office()` en el adaptador, `isOffice()` en las
  reglas), y **siempre con una confirmación explícita** en pantalla (3.5): nada se agrega a la
  nube por la regla de publicación directa (`DESIGN.md` 7.2) sin que la oficina lo vea.
- **Qué tipo es el archivo** se decide como hoy: `OperationSources.baplieKind(voyage, port)` por
  los `LOC+9`/`LOC+11` (solo cargas → plan de carga; solo descargas → plano de llegada) y, si el
  archivo tiene las dos cosas, el diálogo «Tipo de BAPLIE» de `vessel_overview_page.dart`.
- **El contrato** suma `OperationSyncRepository.addSource(operation, source)` junto a
  `replaceSource`. `OperationSources.save(…, sync:, attachTo:)` toma la rama nueva solo cuando
  la operación está publicada, le falta ese tipo y la pantalla ya confirmó (`attachTo` es la
  operación confirmada): sube por `sync.addSource`; si la nube no acepta, lanza su `Failure` y
  nada local cambia, como en T-127. Sin confirmación (`attachTo` nulo), un BAPLIE que falta no
  se agrega solo: `save` lanza «La operación de esta escala ya está publicada y no tiene este
  plan: confirma el plano desde la banda y acepta «Agregar a la operación».» Es la guarda para
  los bancos de `tool/` y para cualquier camino que no pase por el diálogo.
- **La operación local sin publicar no cambia:** con el mismo viaje, los dos planos se juntan en
  la misma operación como siempre (`save` reemplaza la fuente de su tipo); con viajes distintos
  siguen naciendo dos operaciones locales, como hoy. El camino que importa es el de la nube, y
  es el que lleva la confirmación. Si los viajes difieren antes de publicar, se publica el
  primero y se agrega el segundo con T-130.

### 3.2 Reemplazar un BAPLIE que ya está: no en la 0.4.x

**Propongo que no se permita en la 0.4.x,** ni siquiera «solo si nadie registró movimientos de
ese rol». Las razones, por lo que hay en el código:

1. **Las reglas no ven los movimientos.** `validListRevision` y la cláusula nueva de 3.7 miran
   el documento de la operación; una regla no puede contar `movements/`. Una condición «sin
   movimientos de ese rol» viviría solo en el cliente, y entre que la oficina mira su bitácora y
   el lote llega, el muelle puede registrar. El listado se puede reemplazar porque volverlo a
   derivar es benigno (los OR, los grupos, los pesos exactos); un BAPLIE no: cambia las
   posiciones del plan y las claves `R:` de las reservas, y cada movimiento registrado cambia de
   significado (`outOfPlan`, `notInPlan`, `cellTaken` en `operation_state_deriver.dart`).
2. **El estado derivado no se rompería, pero mentiría.** La derivación es pura y aguantaría
   cualquier plan, así que el riesgo no es un error: es una operación cuyas marcas ya no dicen
   lo que dijeron cuando se hicieron, y sin forma de distinguirlas.
3. **El plazo.** Reemplazar con revisión (los trozos `loading_baplie-r{n}-{i}`, la cláusula de
   revisión para los BAPLIE, la comprobación en el cliente, el aviso al muelle de que su plan
   cambió entero) es otra tarea del tamaño de T-127, y el 7-nov está encima. Lo que el piloto
   necesitó fue agregar, no reemplazar.

**El mensaje de la página** cuando la oficina abre un BAPLIE de un tipo que la operación
publicada ya tiene, con otro texto (el `ValidationFailure` de `save`, que la banda muestra como
aviso en rojo y deja el plano en previo, sin publicar nada):

> «La operación publicada de esta escala ya tiene el plan de carga («<archivo publicado>») y
> los BAPLIE de una operación publicada no cambian. Si este archivo lo corrige, cierra la
> operación y publica una nueva con los planos correctos; si es otra escala o viaje, cámbialo en
> «Parámetros del buque».»

(con «plano de llegada» cuando es ese tipo). Lo que cuesta ese camino se dice sin rodeos: las
marcas se quedan en la operación cerrada y la nueva empieza de cero. La defensa es **antes**: la
confirmación de 3.5 muestra el archivo, el viaje que declara y sus cifras, y el cruce del
listado (0 de 104 en el piloto) atrapa un plan equivocado antes de la primera carga.

**Para después del piloto:** «Reemplazar un BAPLIE con revisión, solo mientras no haya
movimientos vigentes de su rol», con el mecanismo de T-127 generalizado (3.4 ya deja el motor y
`assembleSource` preparados para un BAPLIE con revisión). **Carlos lo puso primero en la lista de
después del 7-nov** (2-nov): el plan de carga suele revisarse durante la escala.

### 3.3 El viaje

**Lo que dice el código.** El lector toma el número de viaje del `TDT` (`e8028`,
`baplie_parser_service.dart`) o guarda `UNKNOWN` si no viene (`voyage_number.dart`). La
operación es «un buque, un viaje y un puerto» (`Operation`, T-72): `find` exige los tres
iguales, `activeOperationProvider` arma su clave con el viaje del plano que se ve, el documento
`operations/{id}` lleva `voyage` (≤ 40, y las reglas nunca dejan cambiarlo), el nombre del
archivo de salida lleva `operation.voyageNumber`
(`departure_export_repository_impl.dart`) y el escritor copia la cabecera del plan de carga,
`TDT` incluido (`_header` en `departure_baplie_writer.dart`): el BAPLIE de salida **ya** lleva
el viaje que declara el plan de carga. Con un plan de carga que declare otro viaje, hoy `find`
no encuentra la operación y nace una segunda, local y sin publicar: es el rodeo del piloto, y
es lo que T-130 tiene que evitar.

**Lo que hace T-130.**

1. **La operación conserva su viaje.** Es su identidad: lo que el muelle eligió al unirse, lo
   que Firestore tiene y lo que `validNewOperation` fijó. No se reescribe.
2. **La fuente agregada recuerda el viaje que declara su archivo,** solo si es distinto:
   `OperationSource.voyage` (`String?`), en el JSON local (`voyage`, ausente si es nulo, como
   `revision`) y en la entrada del manifiesto (`sources.loading_baplie.voyage`, opcional, ≤ 40,
   validado en 3.7). **El archivo no se toca:** su texto sube tal cual y la huella es la del
   texto leído (10.11).
3. **`OperationSources.find` relaciona los dos viajes:** encuentra la operación si su viaje es
   el del plano que se ve **o** si alguna de sus fuentes declara ese viaje. Con eso, con el plan
   de carga 26043N abierto, `activeOperationProvider`, `loadingOperationProvider`,
   `dischargeProgressProvider` y el importador del listado encuentran la operación 26043S, y
   el motor, los movimientos, el listado y el BAPLIE de salida trabajan sobre ella. En
   pantalla, el plano abierto sigue diciendo el viaje que su archivo declara («Viaje 26043N ·
   GTSTC») y «Nube y cuenta» dice el de la operación, con el otro junto a la fuente: «Fuentes:
   llegada · carga (viaje 26043N) · listado».
4. **La confirmación explícita de la oficina** (3.5): al confirmar el plano, después de
   «Parámetros del buque» (donde se elige la escala) y antes de publicar, la app busca la
   operación publicada y abierta de **ese buque en esa escala**, con cualquier viaje, **en este
   equipo y en la nube** (ajuste 1 de Carlos): las publicadas de la bitácora local
   (`OperationSources.publishedAtCall`) y las abiertas en la nube (`watchOpenOperations`, la
   misma consulta de «Nube y cuenta», leída una vez del servidor con un tope de unos segundos;
   exige la sesión autorizada que la adición exige de todos modos; sin sesión o sin red, la
   búsqueda sigue solo con lo local). Cuatro salidas:
   - **una, y este equipo la tiene:** si le falta este tipo de BAPLIE, el diálogo dice el
     archivo, **cuándo se publicó la operación** (ajuste 2), sus cifras y, cuando difiere,
     **«Este archivo declara el viaje 26043N. La operación publicada es el viaje 26043S.»** con
     el botón principal «Agregar a la operación 26043S». Con el mismo viaje el diálogo es el
     mismo, sin esa línea: es la confirmación de una escritura en la nube;
   - **una, en la nube y no en este equipo** (la oficina la publicó desde la laptop y el plan le
     llega al teléfono): hoy `find` no la encuentra, nace una operación local y «Publicar
     operación» publicaría una segunda de la misma escala, el rodeo del piloto por otro camino.
     Con T-130 la banda del previo dice **«La escala GTSTC ya tiene una operación publicada de
     este buque (viaje M100) que este equipo no tiene. Únete en «Nube y cuenta» y vuelve a abrir
     el plan para agregarlo.»**, con «Nube y cuenta» a mano; no nace ninguna operación local, y
     «Confirmar» repite el mensaje. Después de unirse (`join` baja la operación con sus
     fuentes) y de volver a abrir el plan, es el caso anterior;
   - **más de una publicada y abierta** de ese buque en esa escala, aquí o en la nube (ajuste 2:
     una operación vieja que nadie cerró): la app **no elige**. La banda las nombra con su viaje
     y su fecha: «Hay 2 operaciones publicadas y abiertas de MAGELLAN STAR en GTSTC: viaje 26039S
     (publicada el 5-oct, 09:12) y viaje 26043S (publicada el 1-nov, 14:05). Cierra la que no
     corresponde desde «Nube y cuenta» y vuelve a abrir el plan.»;
   - **ninguna:** el flujo de hoy.
   La fecha de publicación es el `createdAt` del documento en la nube (hora del servidor), que
   `watchOpenOperations` ya trae; si la nube no respondió, la fecha local de la operación, y el
   diálogo dice «guardada el …» en lugar de «publicada el …».
5. **La publicación directa no agrega sola.** Cuando el perfil cubre la carga, la escala
   propuesta es la última confirmada y el tipo está claro, hoy `_useProfile` publica sin pasar
   por «Parámetros del buque» (`DESIGN.md` 7.2). Si existe una operación publicada de ese buque
   en esa escala a la que le falta este tipo, el plano abre **en previo** con un motivo nuevo,
   `PreviewReason.operacionPublicada`, y la banda dice: «La escala GTSTC ya tiene una operación
   publicada (viaje 26043S) sin plan de carga: confirma para agregarlo.» «Confirmar» lleva a
   «Parámetros del buque» y de ahí al diálogo. Si la operación publicada **ya tiene** ese tipo
   con otro texto, también abre en previo, con el mensaje de 3.2 a la vista. Los dos textos del
   punto 4 (la operación en la nube y no aquí; varias abiertas) usan el mismo motivo y la misma
   banda.
6. **El BAPLIE de salida lleva el viaje que declara el plan de carga,** como hoy: es el viaje
   de salida del buque, el que la línea espera. T-130 no cambia el escritor: T-132 («El BAPLIE
   de salida, fiel», 10.87) ya está integrada en `sprint-4` y es la base de la fase 2. Lo único
   que hoy no cuadra es el **nombre del archivo**, que usa el viaje de la operación
   (`BayStream_<buque>_<viaje>_salida.edi`). **Ajuste 5, corregido por Yov con T-132 en la
   base:** el nombre del archivo y la nota de la página los hace **T-130 en la fase 2**, y de
   esos archivos solo eso: en `departure_export_repository_impl.dart` el nombre lleva
   `OperationSource.voyage ?? operation.voyageNumber` del plan de carga
   (`BayStream_<buque>_M100N_salida.edi`); en `departure_baplie_page.dart`, cuando ese viaje
   difiere del de la operación, «El archivo lleva el viaje M100N, el del plan de carga. La
   operación es la M100.» Lo demás de esos archivos es de T-132 y no se toca.
7. **«Publicar operación» no publica una segunda** (ajuste 1): antes del lote, `publish` lee del
   servidor las operaciones abiertas (la misma consulta de `watchOpenOperations`) y, si ya hay
   una del **mismo buque, viaje y puerto** con otro id, no publica: «Ya hay una operación
   publicada y abierta de MAGELLAN STAR · 26043S · GTSTC, publicada el 1-nov, 14:05. No se
   publica otra: únete a ella desde «Operaciones abiertas en la nube».» El botón «Unirse» de esa
   operación está en la misma página, debajo. Vive en el cliente: las reglas no pueden exigir
   unicidad. Con otro viaje, publicar sigue permitido (puede ser otra escala); el rodeo con otro
   viaje lo corta antes la banda del punto 4, que no deja nacer la operación local.

### 3.4 Cómo viaja

**La oficina (`FirestoreOperationSync.addSource`), igual que `replaceSource`:**

- exige sesión de oficina autorizada; lee la operación **del servidor** (`_serverGet`: sin red
  falla enseguida, nada local cambia); la rechaza si no existe (`not_found`), si está cerrada
  (`closed`) o si ya tiene ese tipo (`already_has`, con el mensaje de 3.2);
- escribe **en un solo lote** los trozos `{tipo}-{i}` (`packSource`, **sin `revision`**, el
  mismo formato que `publish`: por eso un cliente 0.4.0 o 0.4.1 se puede unir después, 3.8) y
  la entrada `sources.{tipo}` del manifiesto con `FieldPath(['sources', tipo])`, con `fileName`,
  `sha256`, `parts`, `length` y, si difiere, `voyage`;
- si el lote pasa, guarda la fuente en la operación local y la devuelve; si no, devuelve el fallo
  con causa y acción: permiso denegado («La nube no aceptó el plan: la operación está cerrada,
  ya tiene ese plan, la cuenta no es de oficina o las reglas publicadas todavía no lo admiten.
  Vuelve a abrir el plano e inténtalo de nuevo.»), sin conexión, sin respuesta (45 s).

**El eco antes que el acuse (ajuste 3, lo que enseñó T-129).** El motor de la oficina escucha el
mismo documento, y el eco del manifiesto puede llegar **antes** de que `addSource` guarde la
fuente en local. Si llega antes, el motor de hoy (T-127) no encuentra la fuente en la operación
local, la baja, la guarda y avisa: la oficina se avisaría a sí misma y guardaría el plan dos
veces (la segunda idéntica, pero con un `changed()` de más). **Sí: `replaceSource` de T-127
tiene el mismo hueco**, por lectura del código («lo que el dispositivo guardó manda» solo
protege cuando el guardado local llega antes que el eco); no se vio en la aceptación porque el
acuse llega normalmente primero (T-129, 3.4), y es el mismo orden que O-128-2 enseñó a no dar
por seguro. T-130 lo cierra para los dos con un **registro de escrituras propias en vuelo**
(`OwnSourceWrites`, en `sync_engine.dart`), compartido por el adaptador y sus motores:
`addSource` y `replaceSource` anotan (operación, tipo, huella) **antes** de `batch.commit()` y lo
borran **después** de guardar en local (o al fallar el lote); el motor, al ver en el manifiesto
una entrada cuya huella está anotada, no baja nada ni avisa: ese plan lo guarda el adaptador, una
sola vez. Lo que el motor sabe de lo local se refresca en la siguiente pasada, porque relee la
operación antes de bajar. Se prueba en los dos órdenes, con la nube falsa de T-129 (3.10).

**El muelle (`SyncEngine`), generalizando T-127:**

- el puerto del motor cambia `watchList(operationId)` por **`watchSources(operationId)`**, que
  emite las tres entradas del manifiesto (`SourceManifest`, en `source_revisions.dart`) al
  suscribirse y cada vez que el servidor las cambia (la misma escucha del documento, filtrada
  por `!hasPendingWrites`); `listParts(operationId, revision)` sigue, y se suma
  `planParts(operationId, kind)` (`where('kind', isEqualTo: …)`, índice de un solo campo que
  Firestore crea solo);
- `_syncList` pasa a ser `_syncSources`: (a) el listado, exactamente como hoy, por revisión;
  (b) por cada BAPLIE que el manifiesto remoto declara y la operación local no tiene: relee la
  operación local (lo que el dispositivo guardó manda) y salta lo que esté anotado como
  escritura propia en vuelo (el registro de abajo), baja sus trozos, los arma y comprueba con `assembleSource` (número,
  huella de cada trozo y del texto unido), guarda la fuente en la operación local **sin tocar
  los movimientos** y emite `SyncStatus.planArrival` (`PlanArrival(kind, fileName, voyage)`),
  que se suma a `listArrival`;
- sin red, `planParts` falla y el motor se queda con lo que tiene; lo reintenta con el siguiente
  contacto con el servidor (un movimiento que llega, el reloj de 15 s, «Reintentar»), como el
  listado. Un plan cuyos trozos no cuadran se anota y no se vuelve a pedir; el muelle sigue con
  su plano (se verá en «Nube y cuenta» porque la fuente no aparece).

**`join` no cambia de lógica:** recorre los tipos del manifiesto y arma cada uno con
`assembleSource`; con la entrada sin `revision` toma los trozos `{tipo}-{i}`, que es lo que
`addSource` escribe. Una operación con un plan agregado se une con sus dos planos, y la fuente
guarda el `voyage` de la entrada.

**Sin red, en la oficina:** `addSource` lee el servidor primero, así que falla enseguida y no
cambia nada local; la oficina lo repite con red. No hay «agregar primero en local y subir
después»: el BAPLIE tiene que estar en la nube antes de que el muelle lo vea, y una copia local
sin subir partiría la verdad en dos.

### 3.5 Qué ve cada uno

**La oficina, antes de confirmar.** Un diálogo, en `vessel_overview_page.dart` después de
«Parámetros del buque» (y del diálogo «Tipo de BAPLIE», si hace falta) y antes de
`confirmGeometry`:

> **Agregar el plan de carga a la operación publicada**
> MAGELLAN STAR · 26043S · GTSTC, publicada el 1-nov, 14:05, abierta, sin plan de carga.
> «PLAN_CARGA.edi» declara el viaje 26043N. *(solo si difiere)*
> Se cargan 104 contenedores y 55 celdas reservadas; se descargan 0.
> El muelle lo recibe solo. Los movimientos registrados no se pierden ni cambian.
> [Cancelar] [Agregar a la operación 26043S]

Las cifras salen de `cargoCountsFor(port)` y `reservedCountsFor(port)` del archivo leído, los
mismos conteos del diálogo «Tipo de BAPLIE». Con un plano de llegada: «Se descargan 398; se
cargan 0.» «Cancelar» deja el previo como estaba. Al aceptar: `confirmGeometry(…, attachTo:)`
→ `_publish` → `save(sync:, attachTo:)` → `addSource`; después, el aviso de siempre del archivo
cargado dice «Plan de carga agregado a la operación publicada de GTSTC: 104 contenedores y 55
reservas. El muelle lo recibe solo.» Si la nube no acepta, el aviso en rojo con el mensaje de la
nube, y el plano sigue en previo para volver a intentarlo. Claves para las pruebas:
`attach-plan-dialog`, `attach-plan-published-at`, `attach-plan-voyage`, `attach-plan-counts`,
`attach-plan-confirm`.

**El muelle, sin reiniciar.** `AvisoDelPlan` (`widgets/aviso_del_plan.dart`, nuevo, hermano de
`AvisoDelListado`), en la página del viaje: escucha `syncStatusProvider.planArrival`, avisa una
vez por llegada y llama a `operationSourcesRevisionProvider.changed()`:

- «Plan de carga agregado por la oficina: 104 contenedores y 55 reservas.» (6 s, flota como los
  demás avisos; las cifras se leen del plan ya guardado en la operación local, con el lector; si
  no se pudieran leer, el aviso dice el nombre del archivo);
- «Plano de llegada agregado por la oficina: 398 se descargan.» con la acción **«Abrir»**, que
  abre ese plano desde la operación (`openOperationSource`, el mismo camino que «Abrir plano de
  llegada» en «Nube y cuenta»).

**Por qué los dos casos no son simétricos,** por el código: el selector de modo ofrece «Carga»
siempre que haya escala y «Descarga» solo con un plano de llegada abierto (`offersDischarge`,
T-75; `vessel_overview_page.dart`, `modos`). Con el plano de llegada abierto, `changed()` basta:
`loadingOperationProvider(voyage)` vuelve a derivar con `operation.source(loadingBaplie)`, y
«Carga» muestra las celdas del plan, «OR / últimos dígitos» y «Asignar vacío» (con listado)
funcionan en el acto, sin cambiar de plano ni volver a unirse. Con el plan de carga abierto y un
plano de llegada que llega, «Descarga» necesita ese plano a la vista: por eso el aviso ofrece
«Abrir». En los dos casos, «Nube y cuenta» muestra el botón «Abrir plan de carga» / «Abrir plano
de llegada» en cuanto el motor guarda la fuente (`localOperationsProvider` sigue a
`operationSourcesRevisionProvider`), y un muelle que todavía no se unió ve «Fuentes: llegada,
carga» al instante, porque `watchOpenOperations` lee las claves del manifiesto.

### 3.6 El estado derivado, los movimientos ya registrados y el cruce del listado

- **Los movimientos no se tocan.** Viven en `movements/` con claves naturales; ni `addSource` ni
  el motor los escriben, y las reglas de los movimientos no cambian. `OperationStateDeriver`
  es una función pura de (plan, movimientos).
- **Agregar un plano da el mismo estado que si se hubieran publicado juntos.** `OperationPlan.
  build(arrival:, loading:)` ya combina los dos; para una clave que está en ambos, manda el del
  plan de carga si se carga aquí, si no el de llegada si se descarga aquí (`_Run`, el
  constructor). Una descarga registrada antes de que llegara el plan de carga conserva su
  significado (su objeto sigue siendo el de llegada, con rol descarga); una carga registrada
  después se evalúa contra el plan de carga. Es exactamente lo que pasa hoy cuando los dos
  planos se publican a la vez, y es una **propiedad que se prueba**: `derive(llegada ∪ carga,
  M)` con el plan agregado después es igual, movimiento por movimiento y conflicto por
  conflicto, al estado con los dos planos desde el inicio (3.10).
- **Qué cambia a la vista** al llegar el plan de carga a un muelle con descargas hechas: el
  «Avance» suma la carga a la descarga, «Carga» muestra lo pendiente del plan, y los conflictos
  posibles son los de siempre (una carga registrada en una celda que la llegada aún ocupa sigue
  siendo `cellTaken`, y la pasada de salidas de T-76 ya libera las celdas descargadas antes).
- **El cruce del listado.** «Listado de la agencia» se ofrece solo con un plan que carga en la
  escala (`_loadsAtCall`, `loading_operation_provider.dart`): el listado entra con el plan de
  carga abierto, después de agregarlo, por el camino de T-127 (revisión 1, 2…). El aviso «Lo ya
  operado con el listado nuevo» deriva con `OperationPlan.build(loading: plan, list: anterior)`
  del plan abierto y sigue igual. En el muelle, `LoadingOperation.build(list:)` toma el listado
  de la operación: los OR, los grupos de los vacíos y «vacío de otro grupo» salen como hoy. El
  orden (plan de carga primero, listado después) es el único posible, porque el listado necesita
  el plan abierto; si el listado ya estaba (publicado con el plan de carga y la llegada se agrega
  después), nada de él cambia.

### 3.7 Las reglas de Firestore y sus baterías

`docs/T130-firestore.rules.propuesta` parte de `docs/T127-firestore.rules.propuesta` (lo que
publica la 0.4.1) y solo cambia esto; un `diff` entre los dos archivos mostrará el encabezado y
estos bloques:

**a. `operations/{id}`:** `allow update: if isOffice() && (validClosing() || validListRevision()
|| validPlanAddition())`.

```
function validPlanAddition() {
  let before = resource.data;
  let after = request.resource.data;
  return before.status == 'open'
    && after.diff(before).affectedKeys().hasOnly(['sources'])
    && after.sources is map
    && (validAddedPlan(before.sources, after.sources, 'arrival_baplie')
        || validAddedPlan(before.sources, after.sources, 'loading_baplie'));
}

// Agregar, nunca reemplazar ni quitar: el tipo no estaba, ahora esta, y es lo unico que cambia.
function validAddedPlan(b, a, kind) {
  return !(kind in b) && kind in a
    && a.diff(b).affectedKeys().hasOnly([kind])
    && validPlanEntry(a[kind]);
}

function validPlanEntry(e) {
  return e is map
    && e.keys().hasAll(['fileName', 'sha256', 'parts', 'length'])
    && e.keys().hasOnly(['fileName', 'sha256', 'parts', 'length', 'voyage'])
    && e.fileName is string && e.fileName.size() >= 1 && e.fileName.size() <= 300
    && e.sha256 is string && e.sha256.matches('^[0-9a-f]{64}$')
    && e.parts is int && e.parts >= 1 && e.parts <= 20
    && e.length is int && e.length >= 0
    && (!('voyage' in e) || (e.voyage is string && e.voyage.size() >= 1 && e.voyage.size() <= 40));
}
```

**b. `sources/{sourceId}`:** `validSource` acepta tres clases de trozo, y cada una queda atada a
su escritura del manifiesto:

```
function validSource(opId, id) {
  let d = request.resource.data;
  let op = getAfter(/databases/$(database)/documents/operations/$(opId)).data;
  return op.status == 'open'
    // T-130: un trozo sin revision solo nace con la operacion, en su lote (ajuste 4 de
    // Carlos: con el op que getAfter ya trae, sin exists ni get de mas).
    && ((validPublishedPart(d, id) && op.createdAt == request.time)
        || validRevisionPart(d, id, op)
        || validAddedPart(d, id, op));
}

// T-130: un trozo `{tipo}-{i}` de un BAPLIE que se agrega despues de publicar, en el mismo
// lote que su entrada del manifiesto (getAfter la ve), con la huella y el numero de trozos
// que la entrada declara. Sin get() ni exists(): un trozo de un tipo que ya estaba solo
// podria apuntar a un id que ya existe (part < parts), y crear sobre un documento que
// existe es un update, que esta cerrado.
function validAddedPart(d, id, op) {
  let fields = ['id', 'kind', 'sha256', 'part', 'parts', 'content', 'createdBy', 'createdAt'];
  return d.keys().hasOnly(fields) && d.keys().hasAll(fields)
    && d.id == id
    && d.kind in ['arrival_baplie', 'loading_baplie']
    && d.kind in op.sources
    && d.part is int && d.part >= 0
    && id == d.kind + '-' + string(d.part)
    && d.sha256 is string && d.sha256 == op.sources[d.kind].sha256
    && d.parts is int && d.parts == op.sources[d.kind].parts
    && d.part < d.parts
    && d.content is string && d.content.size() <= 900000
    && d.createdBy == request.auth.uid
    && d.createdAt == request.time;
}
```

- **El ajuste al trozo publicado, sin un acceso de más** (ajuste 4): `op.createdAt ==
  request.time`, con el `op` que `getAfter` ya trae. En el lote que publica, `validNewOperation`
  fija `createdAt == request.time`, así que un trozo sin revisión solo pasa si **nace con la
  operación, en su lote**; en cualquier lote posterior la operación es más vieja que la petición
  y la rama cae. Es el único cambio a una cláusula de T-80. Hoy T-80 deja que la oficina cree un
  trozo suelto en cualquier operación abierta (lo anotó la O1 de T-122: `join` lo ignora, pero
  existe); con T-130 cada trozo queda atado al manifiesto que lo declara: publicado con la
  operación, revisión del listado o plan agregado. Las 69 de T-80, los 25 de T-113 y los 31 de
  T-127 no tienen ningún caso que cree un trozo suelto esperando «permitido», así que siguen
  dando lo mismo. `validAddedPart` tampoco lee nada de más: no necesita el estado anterior de
  la operación, porque un trozo de un tipo que ya estaba solo podría apuntar a un id que ya
  existe. **Si la batería no sale limpia** (por ejemplo, si `getAfter` no resuelve la hora del
  servidor como `request.time`), el ajuste se quita, como ofrecí: queda `validAddedPart` sola,
  que el trozo publicado abarca, y la integridad la comprueba el cliente con las huellas, como
  en T-79.
- **Lo que no cambia:** `validListRevision` (`hasOnly(['export_list'])`: una adición no se cuela
  en una revisión, ni una revisión en una adición; un lote que intente las dos en una
  actualización se deniega, y la app nunca lo hace), los movimientos, el cierre, `publish`.
- **El presupuesto de accesos a documentos**, que Firestore limita a 10 por operación y 20 por
  lote, sin prometer el caché entre llamadas: por cada trozo, `isOffice()` hace `exists` y `get`
  de la lista de autorizados y `validSource` un `getAfter` de la operación: **3 accesos, los
  mismos que hoy con T-80 y T-127**; T-130 no suma ninguno. Una publicación de 5 trozos cuesta
  2 (la operación) + 5 × 3 = 17; una adición de 4 trozos, 2 (el manifiesto) + 4 × 3 = 14. Es un
  techo que ya existía y conviene dejar escrito: sin caché, un lote no admite más de 6 trozos
  (1,8 millones de caracteres) aunque las reglas digan `parts <= 20`; el BAPLIE más grande del
  corpus cabe en un trozo. La batería comprueba, como la de T-127, que ninguna denegación agote
  las 1 000 expresiones, y suma los dos lotes grandes (abajo).

**La batería nueva, `tool/t130_reglas_plan.mjs`** (puerto 8282, proyecto `demo-t130`, como
T-127; un tercer argumento con el archivo de reglas), con dos operaciones base publicadas por
la oficina: A solo con el plan de carga (el caso del piloto al revés) y B solo con el plano de
llegada (el caso del piloto). Lo que prueba, alrededor de 32 casos:

- **Quién:** el muelle no agrega; una cuenta fuera de la lista no; la oficina agrega el plano de
  llegada a A (permitido) y el plan de carga a B (permitido), cada uno con su entrada y su trozo
  en un lote;
- **Una sola vez, nunca reemplazar:** el mismo tipo otra vez (ya está) no; la entrada con otra
  huella sobre un tipo que ya está no; quitar una entrada no; agregar el plan y el listado en la
  misma actualización no; agregar el plan y cambiar `vessel` no;
- **La entrada:** sin `length` no; con un campo de más no; huella que no es hex de 64 no; `parts`
  0 o 21 no; `voyage` de 41 caracteres no; `voyage` válido sí (permitido, sobre una operación
  nueva) y un cliente que lee la operación lo ve (comprobación de lectura);
- **Los trozos:** con otra huella que la entrada no; con otro número de partes no; con id de
  revisión (`arrival_baplie-r1-0`) no; con campo `revision` no; sin su entrada en el mismo lote
  no; un trozo de más de un tipo que la operación ya tenía (`loading_baplie-1` cuando `parts`
  es 1) no; dos trozos (`parts: 2`) sí (permitido);
- **Lo que se cierra:** un trozo suelto `loading_baplie-0` en una operación existente sin tocar
  el manifiesto, no (es el rojo del ajuste de la línea de T-80: contra T-127 pasa);
- **El presupuesto de accesos (ajuste 4):** una publicación de **cinco trozos** en un lote y una
  adición de **cuatro trozos**, las dos permitidas con las reglas nuevas. La batería busca en la
  respuesta del emulador el texto de su límite de accesos a documentos, y el informe de la fase
  2 dice si el emulador los contó como producción; si no los cuenta, lo digo y queda la cuenta a
  mano de arriba;
- **Lo que sigue igual:** publicar una operación nueva con sus dos planos; la revisión del
  listado después de agregar el plan; el muelle registra movimientos después; el muelle lee los
  trozos y quedan `arrival_baplie-0`, `loading_baplie-0` y `export_list-r1-0`; un trozo
  anterior no se actualiza ni se borra; la oficina cierra la operación con plan agregado;
  cerrada, no admite ni la entrada ni el trozo.

**`tool/t130_baterias.ps1`** hace las ocho corridas de una vez, con `tool/t113_emulador.ps1`
en 8282 y `demo-t130`, cada una con su registro en `build/t130/`: T-80 (69), T-113 (25), T-127
(31) y T-130 contra las reglas de T-130, todas con lo esperado; y las cuatro contra las de T-127:
las tres de siempre iguales, y la de T-130 con sus fallos **donde tiene que fallar**: los casos
que esperan «permitido» (las dos adiciones, el `voyage` válido, los dos trozos y los cuatro
trozos; la publicación de cinco trozos pasa con las dos) y el trozo suelto que T-127 todavía
permite. Ese registro es el rojo de las reglas. Nunca a la vez que el emulador
de la Expo (4400).

**Para Carlos, en la fase 2 (como la sección 7 de T-127):** respaldo de lo publicado en
`build\t130\reglas-antes.txt` y cotejo con `tool/t113_reglas.mjs` contra el archivo de T-127
(o el de T-80, si la 0.4.1 no se publicó); pegar `docs\T130-firestore.rules.propuesta` en la
consola (nunca `firebase deploy`); publicar; cotejar lo publicado con el archivo nuevo como tercer
argumento, con la huella normalizada que anotará el informe; y la vuelta atrás, que es pegar el
archivo anterior: la 0.4.2 entonces dice «La nube no aceptó el plan…» y no cambia nada local.
Sin índices nuevos: `where('kind', isEqualTo: …)` usa el índice de un solo campo.

### 3.8 Compatibilidad: qué hace un cliente 0.4.0 o 0.4.1

Un cliente 0.4.0 (`v0.4.0`, el del piloto) no sabe de revisiones ni de planes agregados: `join`
recorre los tipos del manifiesto y toma **todos** los trozos de cada tipo; `follow` solo escucha
`movements/`; `save` rechaza cualquier fuente nueva o distinta. Uno 0.4.1 (T-127) arma cada tipo
con `assembleSource` (sin revisión, los trozos `{tipo}-{i}`), y su motor lee del manifiesto solo
`export_list`.

| Caso | Lo que hace | Daño |
|---|---|---|
| **0.4.0 o 0.4.1 se une** a una operación con un plan agregado | Los trozos del plan agregado son `{tipo}-{i}` sin `revision`, los mismos que escribe `publish`: el número y las huellas cuadran con el manifiesto y **se une con los dos planos**. `SourceManifestEntry.read` (0.4.1) y el `join` de la 0.4.0 ignoran la clave `voyage`. Solo falla si el listado tiene revisiones (0.4.0, `source_mismatch`, como en la sección 4 de T-127) | Ninguno |
| **0.4.0 o 0.4.1 ya unido** cuando la oficina agrega el plan | No se entera: sigue con el plano que tenía y registra; las reglas de los movimientos no cambian, así que la nube los acepta. Ve el otro plano solo al pasar a la 0.4.2 (que lo baja sola al arrancar) | Ninguno sobre la operación ni sus movimientos |
| **Oficina 0.4.0 o 0.4.1** | No puede agregar: su `save` rechaza el BAPLIE («…sus fuentes no cambian…» / «…sus BAPLIE no cambian…»). Cierra como siempre | Ninguno |
| **0.4.2 con las reglas de T-127 (o T-80) publicadas** | `addSource` recibe `permission-denied`: «La nube no aceptó el plan…»; nada local cambia | Ninguno |
| **0.4.0 o 0.4.1 abre un plan agregado que declara otro viaje** (se unió después de la adición y toca «Abrir plan de carga») | Su `find` no relaciona los viajes: el plano se publica en una **operación local nueva, sin publicar**, y lo que registre ahí **se queda en el dispositivo** («Solo en este dispositivo» en «Nube y cuenta»). Con el mismo viaje no pasa | **Ninguno sobre la nube**, pero sus marcas no suben. Es la razón de la regla de uso |

**Una oficina 0.4.0 o 0.4.1 sigue pudiendo publicar una segunda operación de la misma escala,**
como hoy: la negativa de «Publicar operación» (3.3, punto 7) y la búsqueda en la nube (3.3, punto
4) son de la 0.4.2 y viven en el cliente; las reglas no pueden exigir unicidad.

**La regla de uso:** las reglas de T-130 se publican primero; la laptop, el teléfono de la
oficina y el Honor pasan a la 0.4.2 antes de agregar un plan. La lista del piloto lo dirá en 0.1
y en la sección 5.

**La vuelta a la 0.4.1:** lo único nuevo en el almacén local es `voyage` en una fuente, que la
0.4.1 ignora al leer; una fuente agregada se lee como cualquier otra. Los datos locales siguen
valiendo.

### 3.9 El BAPLIE de salida con los dos planos

Lo que dice `departure_baplie_writer.dart`: exige el plan de carga (sin él, «La operación no
tiene el plan de carga (BAPLIE): impórtalo antes de generar la salida.»); arma los grupos de la
llegada y del plan de carga desde el texto de las fuentes; recorre el estado derivado y deja
fuera lo cancelado y lo que no tiene posición (lo descargado); para lo que sigue a bordo manda
el plan de carga y la llegada respalda lo no declarado (`_aboard`, decisión del 11-oct, T-82);
para lo cargado, la fila del listado o el grupo del plan (8bis de T-122); copia la cabecera del
plan de carga y vuelve a escribir UNB, UNH, BGM y DTM. Es una función pura de (fuentes de la
operación, estado, listado, movimientos).

Con T-130:

- **Plan de carga publicado, plano de llegada agregado después:** los grupos de la llegada son los
  mismos que si se hubiera publicado con la operación; lo que bajó tiene posición nula y queda
  fuera; lo que sigue a bordo toma el respaldo de la llegada. «Comparar con la llegada» aparece
  en la página (hoy solo si la operación tiene esa fuente).
- **Plano de llegada publicado, plan de carga agregado después (el piloto):** la salida se puede
  generar, cosa que sin el plan no podía; las descargas registradas antes del plan quedan fuera
  del archivo como corresponde; el `TDT` es el del plan de carga, con su viaje declarado (3.3).
- **Nada cambia en el escritor.** T-132 («El BAPLIE de salida, fiel», 10.87) ya está en
  `sprint-4` y es la base: T-130 lo deja como está, y de la página y del nombre del archivo toca
  solo lo del viaje (3.3, punto 6). La prueba es la de 3.10: el texto generado con el plan
  agregado después es idéntico, con el mismo reloj, al generado con los dos planos publicados
  juntos, con el escritor de T-132.

### 3.10 Las pruebas y la prueba de punta a punta

**Lo que escribo en la fase 2** (archivos nuevos, con prefijo `t130_`):

- **Transporte y dominio** (`test/t130_plan_agregado_test.dart`): `packSource`/`assembleSource`
  con un BAPLIE sin revisión y los ids `arrival_baplie-0`; `SourceManifestEntry` y
  `OperationSource` con `voyage` (va y vuelve en JSON, ausente si es nulo, una operación guardada
  antes se lee igual); `find` por el viaje de la operación y por el de una fuente;
  la búsqueda de 3.3 con sus cuatro salidas (una en el equipo, una solo en la nube, varias
  abiertas, ninguna) y la negativa de `publish` ante una operación abierta del mismo buque,
  viaje y puerto; `save` en una operación publicada: tipo que falta y confirmación →
  `addSource` una vez y la operación local con la fuente; tipo que falta sin confirmación →
  `ValidationFailure`; tipo que ya está con otro texto → el mensaje de 3.2; cerrada, sin nube y
  el listado (T-127) como hasta hoy.
- **El motor**, contra la nube falsa de T-79 sobre la bitácora real en Hive (como T-127): el plan
  de carga llega a un muelle con el plano de llegada y dos descargas confirmadas → la operación
  local gana la fuente, los movimientos conservan ids y estados, la nube no recibió ni perdió
  ninguno, `planArrival`, y el estado derivado tiene las descargas y lo pendiente del plan; el
  plano de llegada llega a un muelle con el plan de carga; sin red se queda y baja al reconectar;
  si los trozos no bajan a la primera, reintenta con el siguiente contacto; trozos que no cuadran
  se ignoran y no se vuelven a pedir; la oficina que acaba de agregar no lo recibe como novedad
  **en los dos órdenes** (el acuse antes que el eco, y el eco antes que el acuse: con el
  registro de escrituras propias anotado, el manifiesto llega al motor antes del guardado local,
  y el motor ni baja ni avisa, y la fuente queda guardada una sola vez), lo mismo para el listado
  de `replaceSource`; la revisión del listado sigue funcionando después de la adición.
  `FakeServer` suma `addPlan` y el manifiesto de los tres tipos; `FakeCloud`, `watchSources` y
  `planParts`.
- **Unirse:** un manifiesto con `loading_baplie-0` (publicado), `arrival_baplie-0` (agregado) y
  `export_list-r2-0` arma las tres fuentes, la llegada con su `voyage`.
- **El adaptador de Firestore contra la nube falsa de T-129** (10.89, y el ajuste 3 de Carlos):
  `addSource` con `T129FakeFirestore` o su versión en la capa de plataforma: el lote escribe los
  trozos y solo la entrada `sources.{tipo}` (las otras entradas intactas), lee del servidor
  antes y falla sin red, y con un permiso denegado no guarda nada local. **La carrera, en los
  dos órdenes:** con el motor de la oficina siguiendo la operación (`follow`), la falsa entrega
  el eco del documento (`hasPendingWrites` falso) una vez **después** de que el lote resuelve y
  otra **antes**; en los dos, la operación local se guarda **una sola vez** con la fuente, el
  estado de `follow` no emite `planArrival` y nadie pide los trozos. Lo mismo para
  `replaceSource` y `listArrival`, que es el hueco de T-127. Lo que la falsa necesita crecer:
  `batch()` con `set`, `update` y `commit`, `snapshots()` del documento con metadatos y
  `where(…).get()`; si crece más de la cuenta, el orden del adaptador (anotar antes del lote,
  limpiar después del guardado) se prueba con una falsa mínima y la carrera queda cubierta en el
  motor (arriba). T-127 no pudo probar `replaceSource` a ese nivel.
- **La propiedad del estado y de la salida:** con un plano de llegada, descargas antes y cargas
  después, el estado derivado y el texto del BAPLIE de salida con el plan agregado son iguales a
  los de la operación con los dos planos desde el inicio. Compila hoy y pasa hoy: es una
  propiedad, no una regresión, y se dice así.
- **Las pantallas** (`test/t130_plan_pantallas_test.dart`), a 360 dp con los sintéticos de T-73
  y T-100: la oficina ve el diálogo con las cifras y la línea del viaje, «Agregar» llama a
  `addSource` una vez y el plano queda publicado, «Cancelar» no llama a nada, un fallo de la nube
  deja el mensaje y el previo; la banda con el motivo nuevo en sus tres textos (sin ese plan; en
  la nube y no en este equipo; varias abiertas, con viaje y fecha); el diálogo con la fecha de
  publicación; «Publicar operación» negándose ante una operación abierta del mismo buque, viaje
  y puerto, con «Unirse» a mano; el muelle avisa «Plan de carga
  agregado por la oficina: …», llama a `changed()` una vez por llegada, el aviso de la llegada
  ofrece «Abrir»; «Nube y cuenta» muestra «Abrir plan de carga» después.
- **Las reglas:** las ocho corridas de 3.7.
- **El rojo:** las pruebas nuevas contra el código de hoy no compilan, porque usan el contrato
  nuevo (`addSource`, `planArrival`, `watchSources`, `OperationSource.voyage`), como en T-127
  (O-127-1); las reglas tienen su rojo caso por caso; y el comportamiento que cambia lo muestra
  la aceptación con la app real. **La base y el piso:** la base es `sprint-4` con T-129 y T-132
  mezcladas; **antes de tocar nada**, la suite completa en una sola corrida tiene que dar
  **1912** (las 1876 de T-129 más las 36 de T-132) y `analyze` cero; si no, me detengo y lo digo.
  Después, el piso solo sube: 1912 más las nuevas, en una sola corrida, sin omitidas; `analyze`
  en cero antes y después.

**La prueba de punta a punta para Carlos: la laptop como oficina y el Honor como muelle, contra
el emulador.** Con el instrumental de la aceptación de T-128 (4.3 de T-129): el emulador con
Auth (9399) y Firestore (8383) y las reglas de T-130, las dos cuentas sembradas, y un banco en el
repositorio, `tool/t130_emu_main.dart`, hecho como el `t128_emu_main.dart` de Codex (el proyecto
`demo-t130`, el anfitrión y los puertos por `--dart-define`). La oficina es la Web del banco en
Chrome, en la laptop; el muelle, un APK de depuración del banco en el Honor, con
`T130_HOST=<IP de la laptop en el Wi-Fi>`. **El cortafuegos lo abre Carlos** (8383 y 9399, solo
en el perfil privado) **y lo cierra al terminar**, y el emulador escucha en `0.0.0.0` **solo
durante la prueba** (en el `firebase.json` del banco, que Carlos edita para esa ventana). **Yo no
toco el cortafuegos** (ajuste 6). **Datos sintéticos:** los de T-100 (`T100_LLEGADA.edi`,
`T100_CARGA.edi`, `T100_LISTADO.xlsx`; BUQUE MANUAL, viaje M100, escala GTSTC) y una copia
`T100_CARGA_M100N.edi` con el viaje del `TDT` cambiado a M100N; el bloque que la deriva y sus
huellas irán en el informe de la fase 2, como hizo Yov con `T100_CARGA_RESERVA.edi`. Cada
ventana con Flutter o el emulador, con luz verde y `SEMÁFORO:`.

| Paso | Dónde | Qué hacer | Lo que se tiene que ver |
|---|---|---|---|
| 1 | Laptop (oficina) | Abrir `T100_LLEGADA.edi`, confirmar el perfil y la escala GTSTC; «Nube y cuenta» → «Publicar operación» | «Publicada» y «Al día» |
| 2 | Honor (muelle) | «Unirse» → «Abrir plano de llegada» → «Descarga» → descargar dos contenedores | «Hecho» en las dos celdas; en la laptop, «Avance» las cuenta |
| 3 | Honor | Modo avión **con el Wi-Fi apagado** (10.39; un `ping` que falla) | «Sin conexión» |
| 4 | Laptop | «Más» → «Cargar archivo BAPLIE» → `T100_CARGA_M100N.edi` | La banda: «La escala GTSTC ya tiene una operación publicada (viaje M100) sin plan de carga: confirma para agregarlo.» |
| 5 | Laptop | «Confirmar» → «Parámetros del buque» (escala GTSTC) → «Confirmar y ver el plano» | El diálogo «Agregar el plan de carga a la operación publicada» con «publicada el <fecha del paso 1>», «declara el viaje M100N», «Se cargan 30 contenedores y 0 celdas reservadas» (las cifras exactas de T-100 las fija el informe) → «Agregar a la operación M100» → «Plan de carga agregado a la operación publicada de GTSTC: …» |
| 6 | Honor, sin red | Mirar «Carga» y «Nube y cuenta» | Sin aviso; «Carga» sin plan; en «Nube y cuenta» solo «Abrir plano de llegada» |
| 7 | Honor | Quitar el modo avión | «Al día»; el aviso «Plan de carga agregado por la oficina: …»; «Carga» muestra el plan; «Nube y cuenta» muestra «Abrir plan de carga»; las dos descargas siguen «Hecho» |
| 8 | Honor | «Carga» → cargar un lleno por sus últimos dígitos (H4) | «Cargado»; en la laptop, «Avance» suma la carga a las dos descargas |
| 9 | Laptop | «Listado de la agencia» → `T100_LISTADO.xlsx` → «Confirmar e importar» | «…revisión 1. El muelle lo recibe solo.» (T-127); en el Honor, «Listado actualizado por la oficina: 30 filas.» y los OR |
| 10 | Laptop | «Más» → «Cargar archivo BAPLIE» → `T100_CARGA.edi` (otro texto del mismo tipo) | El previo con el mensaje de 3.2 en rojo; nada sube. «Descartar» |
| 11 | Laptop | Con el plan de carga abierto, «Generar BAPLIE de salida» | Las cifras de a bordo, pendientes y cancelados; «Comparar con la llegada» disponible; la página dice «El archivo lleva el viaje M100N, el del plan de carga. La operación es la M100.»; el archivo guardado se llama `BayStream_<buque>_M100N_salida.edi` y dice M100N en `TDT` |
| 12 | Laptop | «Nube y cuenta» → «Cerrar operación» | «Operación cerrada.» (T-129) |
| 13 | Laptop | «Más» → «Cargar archivo BAPLIE» → cualquier plan de ese buque en GTSTC | El mensaje de cerrada; nada sube |
| 14 | Consola del emulador | `operations/{id}`: `voyage: M100`, `sources.arrival_baplie`, `sources.loading_baplie` con `voyage: M100N`, `sources.export_list.revision: 1`; `sources/`: `arrival_baplie-0`, `loading_baplie-0`, `export_list-r1-0` | Nada borrado ni cambiado |
| 15 | Opcional, Chrome en incógnito con el banco de la 0.4.1 de Codex (`banco-emu`) | «Unirse» a una operación donde se agregó un plan **con el mismo viaje** | Se une con los dos planos (3.8) |

La variante al revés (publicar `T100_CARGA.edi` primero y agregar `T100_LLEGADA.edi`) repite 4
a 7 con el aviso «Plano de llegada agregado por la oficina: …» y su «Abrir». Si en el paso 7 el
aviso no llega en medio minuto: «Nube y cuenta» → «Reintentar», y se anota.

**La variante de los ajustes 1 y 2, antes del paso 4,** con un segundo contexto de Chrome (la
cuenta de oficina, sin la operación en ese equipo, como hizo Codex en T-128): abrir
`T100_CARGA_M100N.edi` → la banda dice que la escala ya tiene una operación publicada de este
buque que este equipo no tiene → «Nube y cuenta» → «Unirse» → volver a abrir el plan → el
diálogo del paso 5, con la fecha de publicación. Después, en ese mismo contexto, abrir
`T100_CARGA.edi` como operación local (otra escala, por ejemplo PAMIT, y después GTSTC con el
mismo viaje M100) y «Publicar operación» → la negativa con la operación nombrada y «Unirse» a
mano, y la nube con una sola operación de BUQUE MANUAL · M100 · GTSTC.

### 3.11 Los archivos que toco, y el cruce con T-132

**Nuevos**

- `docs/T130-firestore.rules.propuesta` — T-127 más las cláusulas de 3.7.
- `lib/features/vessel/presentation/widgets/aviso_del_plan.dart` — el aviso del muelle (3.5).
- `tool/t130_reglas_plan.mjs`, `tool/t130_baterias.ps1` — la batería y el lanzador (3.7).
- `tool/t130_emu_main.dart` — el banco contra el emulador (3.10).
- `test/t130_plan_agregado_test.dart`, `test/t130_plan_pantallas_test.dart`.
- `docs/T130-RESULTADOS.md` — este informe.

**Modificados**

- `lib/features/vessel/domain/entities/operation.dart` — `OperationSource.voyage`, `withVoyage`,
  JSON.
- `lib/features/vessel/domain/repositories/operation_sync_repository.dart` — `addSource`,
  `PlanArrival`, `SyncStatus.planArrival`.
- `lib/features/vessel/domain/services/operation_sources.dart` — `find` por el viaje declarado,
  `publishedAtCall`, `save(attachTo:)` y los mensajes de 3.1 y 3.2.
- `lib/features/vessel/data/repositories/source_revisions.dart` — `voyage` en la entrada,
  `SourceManifest`.
- `lib/features/vessel/data/repositories/sync_engine.dart` — `watchSources`, `planParts`,
  `_syncSources` y el registro `OwnSourceWrites` (3.4).
- `lib/features/vessel/data/repositories/firestore_operation_sync.dart` — `addSource`,
  `watchSources`, `planParts`, `join` con `voyage`, la negativa de `publish` ante una operación
  abierta igual (3.3, punto 7) y el registro de escrituras propias en `addSource` y
  `replaceSource`. **Es el archivo de T-129:** su arreglo está en `close()` y `_afterOwnWrite`;
  T-130 toca otras funciones. Por eso la fase 2 parte de `sprint-4` con T-129 y T-132 ya
  mezcladas.
- `lib/features/vessel/data/repositories/local_only_operation_sync.dart` — `addSource` sin nube.
- `lib/features/vessel/presentation/providers/vessel_providers.dart` — el previo con el motivo
  nuevo en `_useProfile`, `publishedOperationFor` (la búsqueda de 3.3 en el equipo y en la
  nube, con sus cuatro salidas), `confirmGeometry(attachTo:)` y `_publish` con la nube.
- `lib/features/vessel/presentation/providers/voyage_ui_state.dart` —
  `PreviewReason.operacionPublicada` y su texto.
- `lib/features/vessel/presentation/pages/vessel_overview_page.dart` — el diálogo de 3.5 en
  `_askForGeometry` y la línea de `AvisoDelPlan`. **Es el único archivo que se cruza con
  T-131**, que corre en su propia carpeta: T-130 toca `_askForGeometry` y esa línea; T-131,
  `_TituloDelViaje`, `_CabeceraDeOficina` y `_BandaDelMuelle`, que T-130 no toca. En la mezcla
  no hay conflicto si cada uno se queda en lo suyo.
- `lib/features/vessel/presentation/pages/cloud_page.dart` — el viaje declarado junto a la fuente
  y el mensaje de la negativa de «Publicar operación», con «Unirse» debajo.
- `test/support/t79_fake_cloud.dart` — el manifiesto de los tres tipos, `addPlan`, `watchSources`,
  `planParts`. Las pruebas de T-127 no cambian: usan la nube falsa a través del motor.

**Modificados, de T-132, solo en lo del viaje** (ajuste 5, corregido por Yov):

- `lib/features/vessel/data/repositories/departure_export_repository_impl.dart` — el nombre del
  archivo con `OperationSource.voyage ?? operation.voyageNumber` del plan de carga.
- `lib/features/vessel/presentation/pages/departure_baplie_page.dart` — la nota «El archivo lleva
  el viaje …, el del plan de carga. La operación es la ….», solo cuando difieren.

**No se tocan:** `departure_baplie_writer.dart` (es de T-132, ya en la base), `lib/main.dart`,
`pubspec.*`, las opciones de Firebase, `docs/T80-firestore.rules.propuesta`,
`docs/T127-firestore.rules.propuesta`, los archivos congelados, `export_list_*` ni
`operation_state_deriver.dart`.

**El cruce con T-132:** ninguno. T-132 ya está integrada en `sprint-4` y es la base de la fase 2;
de sus archivos, T-130 toca solo el nombre del archivo de salida y la nota del viaje, y nada del
escritor.

### 3.12 Lo que no entra

Reemplazar un BAPLIE (3.2); relacionar viajes distintos en operaciones locales sin publicar
(3.1); borrar trozos; cambiar el escritor del BAPLIE de salida (T-132, ya en la base) o nada de
su página fuera de la nota del viaje;
el nombre de la versión (`pubspec.*` no cambia; la candidata va aparte); T-131 (el distintivo) y
T-133 (la marca sobre el OR); publicar cualquier cosa.

### 3.13 Horas

- **Fase 1:** ≈ 3,5 h de lectura y diseño, sin Flutter, más ≈ 1 h de los ajustes y los cambios
  de Yov.
- **Fase 2, hecha en una sesión del 3-nov:** la base y las lecturas de T-129 y T-132, 0,5 h; el
  dominio, el transporte, el contrato y el adaptador, 2 h; el motor y el registro, 1 h; la
  oficina (búsqueda, previo, diálogo, notificador, página), 2 h; el muelle, «Nube y cuenta» y la
  salida, 0,5 h; las reglas, la batería y el lanzador, 1,5 h; las nubes falsas y las tres
  pruebas, 3 h; las corridas y los ocho fallos de la primera (las dos trampas de las falsas, la
  del repositorio del lector y la del listado), 1,5 h; el informe, 1,5 h. **≈ 13,5 h**, por
  debajo de las 20 estimadas, porque el diseño ya decía qué escribir y las nubes falsas de T-79
  y T-129 cubrieron más de lo previsto. Faltan la prueba de punta a punta de Carlos (≈ 2 h, con
  la variante de los ajustes 1 y 2) y la aceptación de Codex.

### 3.14 Lo que Carlos decidió (2-nov): aprobado con seis ajustes

**Las cinco decisiones, aprobadas tal cual:**

1. **Agregar sí, reemplazar no en la 0.4.x** (3.1 y 3.2), con el mensaje de 3.2.
2. **El viaje:** la operación conserva el suyo, la fuente recuerda el que declara, `find` los
   relaciona, y el BAPLIE de salida lleva el del plan de carga (3.3).
3. **Las reglas:** las dos cláusulas y el ajuste de una línea al trozo publicado (3.7).
4. **El muelle:** `watchSources` en lugar de `watchList` en el puerto del motor (3.4), y el
   aviso con «Abrir» para el plano de llegada (3.5).
5. **La prueba de punta a punta** contra el emulador con el banco `tool/t130_emu_main.dart` y la
   copia `T100_CARGA_M100N.edi` (3.10).

**Los seis ajustes, y dónde quedaron:**

1. **La búsqueda mira también la nube** (3.3, punto 4): cruza las operaciones abiertas de
   `watchOpenOperations`; si la operación está en la nube y no en el equipo, la banda lo dice y
   lleva a «Unirse», y no nace ninguna operación local. **«Publicar operación» no publica una
   segunda** del mismo buque, viaje y puerto: lo dice y ofrece «Unirse» (3.3, punto 7).
2. **Una operación vieja que nadie cerró no se confunde con la de hoy** (3.3, punto 4, y 3.5):
   el diálogo dice cuándo se publicó la operación; con más de una publicada y abierta de ese
   buque en esa escala, la app no elige: las nombra con su viaje y su fecha y pide cerrar la que
   no corresponde.
3. **El eco antes que el acuse** (3.4 y 3.10): el registro de escrituras propias en vuelo,
   para `addSource` y para `replaceSource` de T-127, que tiene el mismo hueco; se prueba en los
   dos órdenes con la nube falsa de T-129.
4. **Las reglas** (3.7): las dos cláusulas, sí; el ajuste al trozo publicado con `op.createdAt ==
   request.time` sobre el `getAfter` que ya hay, sin `exists` ni `get` de más por trozo;
   `validAddedPart` sin `get`; la batería suma una publicación de cinco trozos y una adición de
   cuatro, y dice si el emulador cuenta los accesos como producción. Si no sale limpio, queda
   sin el ajuste.
5. **El nombre del archivo de salida y la nota del viaje los hace T-130** (corregido por Yov:
   T-132 ya está integrada en `sprint-4`): en `departure_export_repository_impl.dart`, el nombre
   con `OperationSource.voyage ?? operation.voyageNumber` del plan de carga; en la página del
   BAPLIE de salida, cuando ese viaje difiera del de la operación, «El archivo lleva el viaje
   M100N, el del plan de carga. La operación es la M100.» De esos archivos, solo eso; lo demás
   es de T-132 (3.3, punto 6, y 3.11).
6. **El cortafuegos lo abre y lo cierra Carlos**, solo en el perfil privado, y el emulador
   escucha en `0.0.0.0` solo durante la prueba (3.10). Yo no toco el cortafuegos.

**El orden y la base** (corregidos por Yov): la fase 2 **no espera a T-131** y empieza cuando
Carlos confirme que **la mezcla de T-132 está en `sprint-4`**, no con el commit de T-129. La base
es `sprint-4` con T-129 y T-132: **antes de tocar nada**, la suite completa en una corrida tiene
que dar **1912** (las 1876 de T-129 más las 36 de T-132) y `analyze` cero; si no, me detengo y lo
digo. T-131 va en su propia carpeta y se cruza con T-130 solo en `vessel_overview_page.dart`
(3.11). **Reemplazar un BAPLIE** queda primero en la lista de después del 7-nov (3.2).

Lo que cambia en la lista del piloto lo propondré en el informe de la fase 2 (la mantiene Yov):
1.7 deja de ser «antes de publicar»; un paso nuevo en la oficina para agregar el plan que falta
(con el diálogo), otro en el muelle para recibirlo (el aviso y «Abrir»), el caso del segundo
equipo de oficina (la banda y «Unirse»), 0.1 y la sección 5 con las reglas de T-130 y la regla
de uso.

**Con el informe al día, Carlos versiona el diseño con el bloque de la sección 5.** Hasta que
Carlos confirme la mezcla de T-132 no se toca `lib/`, `test/` ni `pubspec.*`.

## 4. Mensajes para Yov (fase 1: el primero, antes de los ajustes; el segundo, después)

> T-130, fase 1 sobre `687d68d`: el diseño está en `docs/T130-RESULTADOS.md`, sección 3, y
> espera la aprobación de Carlos. En una línea: una operación publicada y abierta acepta el
> BAPLIE que le falta (llegada o carga, uno de cada tipo), con el mecanismo de T-127 tal cual
> (un lote, huellas, el motor escucha el manifiesto entero con `watchSources`, `join` arma los
> dos planos, los movimientos no se tocan y el estado se deriva igual que si se hubieran
> publicado juntos: es una propiedad que se prueba). Reemplazar un BAPLIE no entra en la 0.4.x
> (las reglas no ven los movimientos y el plan es el contrato de las claves); el mensaje de la
> página lo dice. El viaje: la operación conserva el suyo, la fuente agregada recuerda el que
> declara su archivo (`OperationSource.voyage`, también en el manifiesto), `find` los
> relaciona, la oficina lo confirma en un diálogo con las cifras del plan, y el BAPLIE de
> salida sigue llevando el `TDT` del plan de carga; el nombre del archivo y la nota en la
> página se los dejo a T-132, que está en esos archivos (no hay cruce de archivos; sí de ese
> campo). Reglas: T-127 más `validPlanAddition` y `validAddedPart`, y una línea al trozo
> publicado (`!exists`) para que ningún trozo nazca suelto; batería `tool/t130_reglas_plan.mjs`
> (≈ 32 casos) y lanzador con ocho corridas, también en rojo contra T-127. Compatibilidad: un
> 0.4.0 o 0.4.1 se une con los dos planos (los trozos van sin revisión), uno ya unido sigue con
> su plano y sus movimientos entran; el único cuidado es que un cliente viejo que abra un plan
> agregado con otro viaje registraría en una operación local que no sube: regla de uso, la
> 0.4.2 antes. T-129 sigue sin commit en el árbol (otro chat corre sus pruebas aquí); la fase 2
> espera a T-129, a T-131 y a Carlos. Prueba de punta a punta contra el emulador con un banco en
> `tool/` y una copia de `T100_CARGA.edi` con el viaje M100N, 15 pasos. Fase 2 ≈ 16 h.

> **Tras los ajustes (2-nov, de noche):** Carlos aprobó el diseño con seis ajustes, ya escritos
> en el informe (3.14): la búsqueda cruza también las operaciones abiertas de la nube y la banda
> lleva a «Unirse» cuando la operación no está en el equipo; «Publicar operación» se niega ante
> una segunda del mismo buque, viaje y puerto; el diálogo dice la fecha de publicación y con
> varias abiertas la app no elige; un registro de escrituras propias en vuelo cierra la carrera
> del eco antes que el acuse, también para `replaceSource` de T-127, que tiene el mismo hueco
> (por lectura; no se vio en la aceptación); el ajuste del trozo publicado va con `op.createdAt
> == request.time` sobre el `getAfter` existente, sin accesos de más, y la batería mide lotes de
> cinco y cuatro trozos; el cortafuegos es de Carlos. Con tus dos cambios: T-132 ya está en
> `sprint-4`, así que el nombre del archivo de salida (`OperationSource.voyage ??
> operation.voyageNumber` del plan de carga) y la nota del viaje en la página los hago yo en la
> fase 2, y de esos archivos solo eso; la base es `sprint-4` con T-129 y T-132, y antes de tocar
> nada la suite tiene que dar 1912 en una corrida y `analyze` cero, o me detengo. La fase 2
> arranca cuando Carlos confirme la mezcla de T-132, no con el commit de T-129; no espera a
> T-131, que se cruza solo en `vessel_overview_page.dart`. Reemplazar un BAPLIE, primero de la
> lista de después del 7-nov. Fase 2 ≈ 20 h.

## 5. Bloque de Git de la fase 1 (el diseño aprobado)

Solo `docs/T130-RESULTADOS.md`; nada de `lib/`, `test/` ni `pubspec.*`. El bloque de la tarea
completa, con el commit «Sprint 4: T-130, la operacion publicada acepta el plan que le falta»,
va con la fase 2.

```powershell
Set-Location -LiteralPath C:\Proyectos\baystream-rediseno
git add -- docs/T130-RESULTADOS.md
git commit -m "Sprint 4: T-130, fase 1, el diseno aprobado de la operacion publicada que acepta el plan que le falta" --trailer "Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>"
git push origin sprint-4
git log --oneline -1
```

## 6. Fase 2 · La base y lo que se corrió

- **La base** es `a18d2d3`: `sprint-4` con T-129 (`2d98f23`) y su corrección (`a18d2d3`, 10.92),
  la mezcla de T-132 (`7cb96ec`), las decisiones 10.90 y 10.91 (`fb8be28`) y el diseño aprobado
  (`733a8ab`). Al empezar, `SPRINT-4.md` traía la 10.92 sin confirmar (de Yov); no la toqué.
  `git log a18d2d3..` no trae nada más. Los cambios ajenos de siempre (`test/t114_…`, tres de
  `windows/flutter/`, `docs/t117/entrega1/`) siguen fuera de mi bloque.
- **La comprobación de la base, antes de tocar nada** (3.10): `flutter analyze lib test
  integration_test` → **No issues found** (82 s; `build/t130/00-analyze-base.log`); la suite
  completa en una corrida, `flutter test --no-pub --reporter expanded` → **1914 de 1914**, sin
  fallas ni omitidas, en 2 min 04 s (`01-suite-base.log`). Es lo que Carlos anunció (las 1912 de
  T-129 y T-132 más las 2 de la corrección).
- **Una falta mía:** la suite de la base corrió a la vez que la ventana exclusiva de Codex, que
  estaba repitiendo sus sondas y `analyze`. Carlos lo señaló; Codex volvió a correr lo suyo.
  Desde ese momento, **cada comando de Flutter de esta tarea se pide a Carlos y espera su
  respuesta** (10.93 lo deja escrito para los dos programadores). El resultado de la suite vale
  como lectura de la base (pasa o no pasa), no como medición de tiempo, y lo digo aquí para que
  nadie lo tome por otra cosa.
- **Durante la fase 2 entraron dos commits de `docs/`**, `e1ad29e` (la segunda revisión corta de
  T-129, que la da por cerrada) y `bda658b` (10.92 y 10.93): no tocan `lib/`, `test/`,
  `pubspec.*` ni `tool/`, así que la base del código sigue siendo `a18d2d3` y el bloque de 14
  aplica sobre la punta `bda658b`.
- **Después, sin Flutter:** todo el código de 7, las pruebas de 8, las reglas y la batería de 9
  (con `node --check` de `tool/t130_reglas_plan.mjs`) y la huella de
  `docs/T130-firestore.rules.propuesta` con `tool/t113_reglas.mjs`:
  **`8B9039496CCCDA9FBC1412CC1F8610B3183D58FB4BA779EFB0C0C7D920EEFF71`** (484 líneas, LF; la
  huella cruda y la normalizada coinciden). Un `diff` con el archivo de T-127 da 99 líneas: el
  encabezado nuevo, `validPlanAddition` con `validAddedPlan` y `validPlanEntry`, el `validSource`
  nuevo y `validAddedPart`.

## 7. Lo hecho (el diseño de 3, con los seis ajustes y los dos cambios de Yov)

### 7.1 El dominio y el transporte

- `OperationSource.voyage` (`String?`, solo si difiere del de la operación), `withVoyage`, y
  `voyage` en el JSON local (ausente si es nulo; lo guardado antes se lee igual).
  `Operation.matchesVoyage(viaje)` (el suyo o el que declara una fuente) y
  `Operation.departureVoyageNumber` (el del plan de carga, o el de la operación).
- `SourceManifestEntry.voyage` (en `toMap` solo si lo hay; `read` lo lee) y `SourceManifest`
  (las tres entradas por tipo, `read` del mapa `sources`, `plans`, `exportList`).
  `packSource`/`assembleSource` llevan y traen el viaje. Un BAPLIE agregado va en trozos
  `{tipo}-{i}` sin `revision`, el mismo formato que `publish`.
- El contrato: `OperationSyncRepository.addSource`, `PlanArrival(kind, fileName, voyage)` y
  `SyncStatus.planArrival`. `LocalOnlyOperationSync.addSource` contesta «sin nube».
- `OperationSources`: `find` encuentra la operación por su viaje **o** por el que declara una
  fuente; `publishedAtCall` (las publicadas y abiertas de ese buque en esa escala en este
  equipo); `lookup` (función pura con las dos listas, el equipo y la nube, y las cuatro salidas
  de 3.3: `NoPublishedOperation`, `AttachablePlan` con la fecha de publicación,
  `PlanAlreadyThere` con `sameContent`, `PlanInCloudOnly`, `SeveralOpenOperations` ordenadas por
  fecha); `save(…, attachTo:)`: en una operación publicada, el mismo texto no cambia nada, una
  cerrada se niega, el listado sigue por `replaceSource`, un BAPLIE que ya está con otro texto
  lanza el mensaje de 3.2 (`replaceMessage`), uno que falta sin confirmación lanza «…confirma el
  plano desde la banda y acepta «Agregar a la operación».», y con confirmación sube por
  `addSource` con `voyage` si el viaje del plano difiere. `sourceName` da el nombre de cada
  fuente.

### 7.2 El adaptador de Firestore y el motor

- `FirestoreOperationSync.addSource`: exige oficina, lee del servidor, se niega si la operación
  no está (`not_found`), está cerrada (`closed`) o ya tiene ese tipo (`already_has`, con el
  archivo que tiene); escribe por `_writeSource`, que comparte con `replaceSource`: los trozos y
  la entrada `sources.{tipo}` en un lote y, si pasa, la operación local. Los mensajes de la nube
  en contra, por código (permiso, sin conexión, sin respuesta).
- **El registro de escrituras propias** (`OwnSourceWrites`, en `sync_engine.dart`; ajuste 3):
  `_writeSource` anota (operación, tipo, huella) antes de `batch.commit()` y lo borra en un
  `finally` después de guardar en local; el adaptador se lo pasa a cada motor que crea en
  `follow`. `replaceSource` queda cubierto por el mismo camino.
- `publish` (ajuste 1): antes del lote, lee del servidor las operaciones abiertas
  (`_openDuplicateOf`) y, si ya hay una del mismo buque, viaje y puerto con otro id, contesta
  `duplicate` con el texto de 3.3 (punto 7), con la fecha de publicación (`fechaCorta`, nueva en
  `core/utils/`). Otro viaje o la misma operación no son una segunda.
- `FirestoreRemoteMovementStore`: `watchList` pasa a `watchSources` (las tres entradas del
  manifiesto, sin escrituras propias pendientes) y se suma `planParts(operación, tipo)`
  (`where('kind', isEqualTo: …)`, del servidor).
- `SyncEngine`: `watchSources` → `_syncSources` = `_syncList` (como T-127, más el salto de lo
  anotado como escritura propia) y `_syncPlans` (por cada BAPLIE que el manifiesto declara y lo
  local no tiene: relee lo local, salta lo propio en vuelo, baja los trozos, arma y comprueba,
  guarda sin tocar los movimientos y emite `planArrival`; sin red se queda y reintenta con el
  siguiente contacto; los trozos que no cuadran se anotan por huella y no se vuelven a pedir).
  `ownWrites` opcional en el constructor (un motor solo tiene el suyo).

### 7.3 La oficina

- `plan_attach_provider.dart` (nuevo): `lookupPlanAttachment` reúne la bitácora y, con sesión
  autorizada, la lista de operaciones abiertas de la nube (`watchOpenOperations().first` con un
  tope de 5 s; sin respuesta, solo lo local) y decide con `OperationSources.lookup`;
  `textoDeLaBusqueda` escribe la banda o el aviso de cada salida.
- `VoyageNotifier.lookupForPlan(port, kind)`; `_useProfile` (la publicación directa) ya no
  publica si la escala tiene una operación publicada de este buque, aquí o en la nube: abre el
  previo con `PreviewReason.operacionPublicada` y la nota de la búsqueda (`Previo.nota`,
  `previewNota`); solo con ninguna, o con la misma fuente y el mismo texto, publica como hoy.
  `confirmGeometry(…, attachTo:, sync:)` → `_publish` → `save(…, sync:, attachTo:)`.
- `vessel_overview_page.dart`, `_askForGeometry`: después de «Parámetros del buque» (y del diálogo
  «Tipo de BAPLIE»), la búsqueda; con una operación aquí a la que le falta el plan, el diálogo
  `confirmarAgregarPlan` (`widgets/dialogo_agregar_plan.dart`, nuevo: cuándo se publicó,
  «declara el viaje …» si difiere, las cifras y «Agregar a la operación …»); con una solo en la
  nube, ya con ese tipo con otro texto o varias abiertas, el aviso en rojo y el plano sigue en
  previo; «Cancelar» no publica nada. Al agregar, el aviso «Plan de carga agregado a la
  operación publicada de GTSTC: … El muelle lo recibe solo.» (`textoDelPlanAgregado`). Es el
  único archivo que se cruza con T-131, en `_askForGeometry` y en la línea de `AvisoDelPlan`.

### 7.4 El muelle, «Nube y cuenta» y la salida

- `AvisoDelPlan` (`widgets/aviso_del_plan.dart`, nuevo), hermano de `AvisoDelListado`: avisa una
  vez por llegada con las cifras del plan leído de la operación local («Plan de carga agregado
  por la oficina: 104 contenedores y 55 reservas.», «Plano de llegada agregado por la oficina:
  398 se descargan.»; si no se puede leer, el archivo), llama a `changed()` y ofrece «Abrir»
  (`openOperationSource`).
- `cloud_page.dart`: la línea «Fuentes: llegada · carga (viaje M100N) · listado r1»
  (`fuentesDeLaOperacion`), y la negativa de `publish` se muestra como cualquier fallo, con
  «Unirse» debajo.
- Ajuste 5, corregido por Yov: `departure_export_repository_impl.dart` nombra el archivo con
  `operation.departureVoyageNumber`; `departure_baplie_page.dart` dice «El archivo lleva el
  viaje M100N, el del plan de carga. La operación es la M100.» solo cuando difieren
  (`departure-voyage-note`). Nada más de esos archivos; el escritor no se toca.

### 7.5 Las nubes falsas y el banco

- `test/support/t79_fake_cloud.dart`: `FakeServer.plans`, `manifest` y `addPlan(kind, content,
  fileName:, voyage:)`; `FakeCloud.watchSources`, `planParts` con `planPartsRequests` y
  `planPartsFailures`. Las pruebas de T-127 no cambian: usan la nube falsa a través del motor.
- `test/support/t129_fake_firestore.dart` (Carlos autorizó tocarla en 10.92): `batch()` (`set`,
  `update` con rutas anidadas, `commit` con la vista pendiente, el servidor y el eco),
  `echoBeforeAck` (el eco antes de que el `commit` termine), `where(…).get()` y la escucha de una
  colección (lo justo para el motor), `queryGets`, `docsIn`, `writePending` y `echo`.
- `tool/t130_emu_main.dart` (nuevo): la app contra el emulador, como el banco de T-128, con el
  anfitrión por `T130_HOST` (loopback o una IP privada del Wi-Fi, para el Honor) y solo
  proyectos `demo-`.

## 8. Las pruebas

**37 pruebas nuevas, 37 en verde** (`build/t130/03-pruebas-nuevas.log`, «+37: All tests
passed!»), en tres archivos, de a un comando y con la luz verde de Carlos para cada uno:

1. `flutter analyze lib test integration_test` sobre el código nuevo: dos avisos de estilo
   (`prefer_const_constructors`) en una prueba, corregidos; después **No issues found**
   (`02-analyze-primero.log`).
2. Las tres pruebas: en la primera corrida pasaron 29 de 37 (`03-…`, sobrescrito por la corrida
   final). Los ocho fallos eran de las pruebas y de las nubes falsas, no del producto:
   - **cuatro carreras del adaptador vencían el plazo** después de dar todas sus comprobaciones:
     se colgaban al parar el motor, porque la bitácora en memoria de T-75 implementa `watch`
     como un generador `async*` que espera en un `await for` sobre un flujo que nunca emite, y
     cancelar un generador así no termina (la de Hive, la real, cierra con un controlador). La
     bitácora de la prueba lo implementa como Hive. T-75 no cambia;
   - **la consulta `where` sobre una colección de la nube falsa** fallaba con «type 'Null' is
     not a subtype of type 'Iterable'»: `cloud_firestore` lee `parameters['where']` del
     delegado antes de llamar a la plataforma, y la colección base lo deja vacío. La falsa lo
     llena con los parámetros iniciales y la consulta reemplaza las condiciones (que
     `cloud_firestore` manda acumuladas) en vez de sumarlas;
   - **el aviso del muelle** no mostraba las cifras: `VesselRepositoryImpl` pide
     `FirebaseFirestore.instance` al construirse, y en una prueba de widget no hay Firebase (en
     la app siempre lo hay; los bancos lo reemplazan). La prueba le da un repositorio con una
     nube vacía. Además el aviso leía la operación de `activeOperationProvider` sin esperar a
     que resolviera; ahora espera su `future` después de `changed()`, que es lo que vuelve a
     leerla de la bitácora;
   - **el listado de la prueba del motor** era un JSON a mano que el lector no entiende: va con
     `ExportList.toJson()`, como en T-127.
   Con eso, **37 de 37**.
3. `flutter analyze` otra vez, sin las marcas de diagnóstico: **No issues found**
   (`04-analyze-tras-pruebas.log`).
4. **El rojo contra la base:** una copia del árbol en `%TEMP%\t130-antes\copia` (robocopy sin
   `.git`, `build`, `docs` ni `.dart_tool`, más `package_config.json`, `package_graph.json`,
   `version` y `.flutter-plugins-dependencies` del árbol, como en T-127), con los 13 archivos de
   `lib/` que toca T-130 repuestos desde `a18d2d3` con `git show` y los 4 nuevos de `lib/`
   borrados; las pruebas y las nubes falsas, como están. `flutter test --no-pub` de los tres
   archivos ahí: **ninguno compila** («Failed to load»; `05-rojo-contra-a18d2d3.log`): 254
   errores, 152 en la prueba del motor y el dominio, 54 en la de pantallas, 24 en la del
   adaptador y 22 en la nube falsa de T-79, todos por el contrato que no existe en la base
   (`addSource`, `planArrival`, `watchSources`, `planParts`, `OperationSource.voyage`,
   `SourceManifest`, `OwnSourceWrites`, `lookup`, `confirmarAgregarPlan`,
   `departureVoyageNumber`…). Es el rojo que admite un contrato nuevo (O-127-1): no es «cada
   una en su comprobación», y se dice así. Las reglas sí tienen su rojo caso por caso (9).
5. **La suite completa en una sola corrida**, `flutter test --no-pub --reporter expanded`:
   **1951 de 1951**, sin fallas ni omitidas, en 2 min 04 s (`06-suite-completa.log`): las 1914
   de la base más las 37 nuevas. **El piso de `sprint-4` sube a 1951.** `pubspec.lock` no
   cambia.
6. `flutter analyze lib test integration_test` al final: **No issues found**
   (`07-analyze-final.log`).

**Lo que prueba cada archivo:**

- `test/t130_plan_agregado_test.dart` (18): el dominio (4: el viaje en la fuente y en el manifiesto,
  `assembleSource` con un plan agregado, `find` y `publishedAtCall`), la búsqueda (4: las cuatro
  salidas, varias abiertas y la copia local que la nube ya no lista, `lookupPlanAttachment` con
  nube, sin sesión y sin respuesta, los textos), `save` (2), el motor (7: el plan de carga llega
  con descargas hechas y la revisión del listado sigue; el plano de llegada llega; sin red;
  reintento con el siguiente contacto; trozos que no cuadran; el eco antes que el acuse para el
  plan y para el listado; el acuse antes que el eco) y la propiedad (1: estado y BAPLIE de salida
  idénticos, con el `TDT` del plan de carga).
- `test/t130_plan_pantallas_test.dart` (10): el diálogo (3), la banda con la nota, «Nube y
  cuenta», los textos del plan agregado, el aviso del muelle con «Abrir» (1), y la salida: la
  nota del viaje, sin nota con el mismo viaje y el nombre del archivo (3).
- `test/t130_adaptador_test.dart` (9), contra la nube falsa de T-129: `addSource` (3: el lote y
  lo local; lo que no agrega y nada local cambia; la sesión), la carrera en los dos órdenes para
  `addSource` y para `replaceSource` (4) y la negativa de `publish` (2). **La carrera, medida:**
  con el motor de la oficina escuchando la operación, el eco del manifiesto antes y después del
  acuse del lote; en los cuatro casos la fuente se guarda en local una sola vez (dos escrituras
  en la bitácora: la de la prueba y la del adaptador), `follow` no emite `planArrival` ni
  `listArrival`, y ninguna consulta pidió trozos.

## 9. Las reglas y sus baterías

**Las ocho corridas, en una sola pasada del lanzador** (`tool/t130_baterias.ps1`, 3-nov, con la
luz verde de Carlos; emulador en `127.0.0.1:8282`, proyecto `demo-t130`, ningún puerto del
emulador en escucha antes y el emulador cerrado al terminar; registros en `build/t130/`,
resumen en `baterias-resumen.json`):

| Batería | Contra T-130 | Contra T-127 | Registros |
|---|---|---|---|
| T-80, `tool/t80_reglas.mjs` | **69 de 69** | **69 de 69** | `reglas-t80-contra-t130.log`, `reglas-t80-contra-t127.log` |
| T-113, `tool/t113_reglas_abuso.mjs` | **25 de 25** | **25 de 25** | `reglas-t113-contra-*.log` |
| T-127, `tool/t127_reglas_revision.mjs` | **31 de 31** | **31 de 31** | `reglas-t127-contra-*.log` |
| T-130, `tool/t130_reglas_plan.mjs` | **38 de 38** | **27 de 38**: caen los 11 de abajo | `reglas-t130-contra-*.log` |

**Los once que caen contra T-127, y por qué tienen que caer:** las dos adiciones (el plano de
llegada a una operación con solo el plan de carga, y al revés), el `voyage` válido y su lectura
(T-127 no admite la entrada: denegado, 403), los dos trozos y la adición de cuatro trozos (lo
mismo), y cuatro consecuencias de la holgura de T-80 que T-130 cierra: un trozo suelto sin su
entrada pasa con T-127 (`validPublishedPart` no mira el manifiesto), un trozo suelto que no
cuadra con el manifiesto también pasa, y por eso el que «completa» lo que el manifiesto declara
encuentra su id ocupado y cae, y «un trozo agregado no se actualiza» resulta una creación
permitida porque la adición nunca entró; la lectura de los trozos de la operación A solo
encuentra `export_list-r1-0` y `loading_baplie-0`. Lo que T-130 **habilita** es exactamente lo
que T-127 niega, y lo que T-130 **cierra** es lo que T-80 dejaba pasar.

**El presupuesto de accesos (ajuste 4):** la publicación de cinco trozos en un lote y la adición
de cuatro pasaron con las reglas de T-130. **Ninguna respuesta del emulador mencionó el límite
de accesos a documentos**, ni en esa corrida ni en la de T-127, y ninguna denegación agotó las
1 000 expresiones. No puedo afirmar que el emulador cuente los accesos como producción: no lo
dijo, y la documentación de Firebase no lo promete. Queda la cuenta a mano de 3.7: 3 accesos por
trozo, los mismos de T-80 (`exists` y `get` de la lista de autorizados, `getAfter` de la
operación), 17 para publicar cinco trozos y 14 para agregar cuatro, bajo el límite de 20 por
lote; y el techo preexistente de 6 trozos por lote sin caché. Si en producción un lote grande
fallara por el límite, el síntoma sería «La nube no aceptó el plan…» y la vuelta atrás es la de
10.3; con el BAPLIE más grande del corpus en un solo trozo, no es un caso del piloto.

`docs/T130-firestore.rules.propuesta` es lo de 3.7 con el ajuste 4: `validPlanAddition`,
`validAddedPlan`, `validPlanEntry`, `validAddedPart` sin `get`, y `validPublishedPart &&
op.createdAt == request.time`. `tool/t130_reglas_plan.mjs` trae 38 comprobaciones (36 casos y dos
lecturas): quién (4), una sola vez (5), la entrada (7, con el `voyage` válido y su lectura), los
trozos (7), el ajuste al trozo publicado (2: el suelto que no cuadra no pasa; el que completa lo
que el manifiesto declara sí, porque es inofensivo), el presupuesto (2: cinco trozos al publicar
y cuatro al agregar) y lo que sigue igual (11). Busca en cada respuesta el texto del límite de
accesos a documentos y lo dice al final. `tool/t130_baterias.ps1` corre las ocho (T-80, T-113,
T-127 y T-130 contra T-130; las cuatro contra T-127, la última sin contar), en 8282 y
`demo-t130`, nunca a la vez que el emulador de la Expo.

## 10. Para Carlos: publicar las reglas de T-130 y cotejarlas

### 10.1 Publicar desde la consola (nunca `firebase deploy`)

1. Antes, Codex acepta T-130 y la candidata está lista para compilar. Las reglas van **antes**
   que los clientes de la 0.4.2.
2. En Chrome, `https://console.firebase.google.com` → proyecto **baystream-app** → **Firestore
   Database** → pestaña **Reglas**.
3. **Respaldo de lo publicado:** seleccionar todo el editor (Ctrl + A), copiar y guardar en
   `build\t130\reglas-antes.txt` (UTF-8). Desde la carpeta del rediseño:
   `node tool/t113_reglas.mjs build/t130/reglas-antes.txt build/t130 docs/T127-firestore.rules.propuesta`
   → `"equal": true` con `FC17842C…` si lo publicado es T-127; si la 0.4.1 no se publicó, sin el
   tercer argumento, `7E57F227…` (T-80).
4. Abrir `docs\T130-firestore.rules.propuesta`, seleccionar todo, copiar; en la consola,
   seleccionar todo y pegar encima; ninguna marca roja; la primera línea sigue siendo
   `rules_version = '2';`.
5. **Publicar.** Rige en menos de un minuto. No hace falta tocar índices: `where('kind',
   isEqualTo: …)` usa el índice de un solo campo.

### 10.2 Cotejar

1. Copiar el editor a `build\t130\reglas-publicadas.txt` (UTF-8).
2. `node tool/t113_reglas.mjs build/t130/reglas-publicadas.txt build/t130 docs/T130-firestore.rules.propuesta`
3. Tiene que decir `"equal": true`, salir con 0 y dar la huella normalizada
   **`8B9039496CCCDA9FBC1412CC1F8610B3183D58FB4BA779EFB0C0C7D920EEFF71`** (484 líneas, LF). Si no,
   el script lista las líneas distintas: se corrige en la consola y se vuelve a cotejar. El
   resultado queda en `build\t130\reglas-cotejo.json`.

### 10.3 Volver atrás

Pegar `build\t130\reglas-antes.txt` y publicar: la 0.4.2 vuelve a decir «La nube no aceptó el
plan…» al agregar y no cambia nada local; el listado de T-127 y todo lo demás siguen igual.

## 11. La lista del piloto: lo que cambia (propuesta; la mantiene Yov)

- **0.1 y 4.0:** las reglas de T-130 (`8B903949…`) antes que los clientes de la 0.4.2; el respaldo
  de lo anterior en `build\t130\reglas-antes.txt`.
- **1.7:** deja de ser «antes de publicar»: con la operación publicada, el plan que falta entra
  después (1.18).
- **1.18, nuevo (oficina):** «Más» → «Cargar archivo BAPLIE» → el plan que falta. La banda dice
  «La escala … ya tiene una operación publicada (viaje …) sin plan de carga: confirma para
  agregarlo.» → «Confirmar» → «Parámetros del buque» → el diálogo «Agregar el plan de carga a la
  operación publicada» (cuándo se publicó, el viaje que declara el archivo si difiere, las
  cifras) → «Agregar a la operación …» → «Plan de carga agregado a la operación publicada de …».
  Si la banda dice que la operación está en la nube y este equipo no la tiene: «Nube y cuenta»
  → «Unirse» y volver a abrir el plan. Si hay varias abiertas, cerrar la que no corresponde.
- **1.19, nuevo (oficina):** «Publicar operación» con otra abierta del mismo buque, viaje y
  puerto se niega y nombra la que hay: «Unirse».
- **2.16, nuevo (muelle):** con red y sin tocar nada, «Plan de carga agregado por la oficina: N
  contenedores y M reservas.» (6 s), «Carga» muestra el plan y «Nube y cuenta» ofrece «Abrir plan
  de carga»; con un plano de llegada agregado, «Abrir» en el aviso. Sin red, llega al volver la
  red; si en medio minuto no llega, «Reintentar».
- **1.13 y 1.14:** la nota «El archivo lleva el viaje …, el del plan de carga.» cuando difiera, y
  el nombre del archivo con ese viaje.
- **Sección 5:** la regla de uso (la laptop, el teléfono de la oficina y el Honor en la 0.4.2
  antes de agregar un plan) y lo que hace un cliente viejo (3.8), en particular el que abre un
  plan agregado con otro viaje.

## 12. Lo que no entra y los límites

Lo de 3.12. Además: la búsqueda en la nube necesita sesión autorizada y responde en 5 s o sigue
con lo local (lo dice 7.3); la fecha de publicación es la de la nube cuando la nube respondió, y
si no, la local («guardada el …»); las cifras del aviso del muelle salen de leer el plan ya
guardado y, si no se puede leer, el aviso dice el archivo.

## 13. Archivos tocados

**Nuevos:** `docs/T130-firestore.rules.propuesta`; `lib/core/utils/fecha_corta.dart`;
`lib/features/vessel/presentation/providers/plan_attach_provider.dart`;
`lib/features/vessel/presentation/widgets/aviso_del_plan.dart`;
`lib/features/vessel/presentation/widgets/dialogo_agregar_plan.dart`;
`test/t130_plan_agregado_test.dart`; `test/t130_plan_pantallas_test.dart`;
`test/t130_adaptador_test.dart`; `tool/t130_reglas_plan.mjs`; `tool/t130_baterias.ps1`;
`tool/t130_emu_main.dart`; `docs/T130-RESULTADOS.md`.

**Modificados:** `lib/features/vessel/domain/entities/operation.dart`;
`lib/features/vessel/domain/repositories/operation_sync_repository.dart`;
`lib/features/vessel/domain/services/operation_sources.dart`;
`lib/features/vessel/data/repositories/source_revisions.dart`;
`lib/features/vessel/data/repositories/sync_engine.dart`;
`lib/features/vessel/data/repositories/firestore_operation_sync.dart`;
`lib/features/vessel/data/repositories/local_only_operation_sync.dart`;
`lib/features/vessel/data/repositories/departure_export_repository_impl.dart`;
`lib/features/vessel/presentation/providers/vessel_providers.dart`;
`lib/features/vessel/presentation/providers/voyage_ui_state.dart`;
`lib/features/vessel/presentation/pages/vessel_overview_page.dart`;
`lib/features/vessel/presentation/pages/cloud_page.dart`;
`lib/features/vessel/presentation/pages/departure_baplie_page.dart`;
`test/support/t79_fake_cloud.dart`; `test/support/t129_fake_firestore.dart`.

No cambian `pubspec.yaml` ni `pubspec.lock`, ni `lib/main.dart`, ni las opciones de Firebase, ni
`docs/T80-firestore.rules.propuesta`, ni `docs/T127-firestore.rules.propuesta`, ni
`departure_baplie_writer.dart`, ni los archivos congelados.

## 14. Bloque de Git para Carlos

(Todas las validaciones de 8 y 9 están hechas: 37 de 37, suite 1951 de 1951, `analyze` cero y
las ocho baterías. No incluye `SPRINT-4.md`, `pubspec.*`, `lib/main.dart`, los archivos de
`docs/t117/` ni nada ajeno.)

```powershell
Set-Location -LiteralPath C:\Proyectos\baystream-rediseno
git add -- docs/T130-firestore.rules.propuesta
git add -- lib/core/utils/fecha_corta.dart
git add -- lib/features/vessel/domain/entities/operation.dart
git add -- lib/features/vessel/domain/repositories/operation_sync_repository.dart
git add -- lib/features/vessel/domain/services/operation_sources.dart
git add -- lib/features/vessel/data/repositories/source_revisions.dart
git add -- lib/features/vessel/data/repositories/sync_engine.dart
git add -- lib/features/vessel/data/repositories/firestore_operation_sync.dart
git add -- lib/features/vessel/data/repositories/local_only_operation_sync.dart
git add -- lib/features/vessel/data/repositories/departure_export_repository_impl.dart
git add -- lib/features/vessel/presentation/providers/plan_attach_provider.dart
git add -- lib/features/vessel/presentation/providers/vessel_providers.dart
git add -- lib/features/vessel/presentation/providers/voyage_ui_state.dart
git add -- lib/features/vessel/presentation/pages/vessel_overview_page.dart
git add -- lib/features/vessel/presentation/pages/cloud_page.dart
git add -- lib/features/vessel/presentation/pages/departure_baplie_page.dart
git add -- lib/features/vessel/presentation/widgets/aviso_del_plan.dart
git add -- lib/features/vessel/presentation/widgets/dialogo_agregar_plan.dart
git add -- test/support/t79_fake_cloud.dart
git add -- test/support/t129_fake_firestore.dart
git add -- test/t130_plan_agregado_test.dart
git add -- test/t130_plan_pantallas_test.dart
git add -- test/t130_adaptador_test.dart
git add -- tool/t130_reglas_plan.mjs
git add -- tool/t130_baterias.ps1
git add -- tool/t130_emu_main.dart
git add -- docs/T130-RESULTADOS.md
git commit -m "Sprint 4: T-130, la operacion publicada acepta el plan que le falta" --trailer "Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>"
git push origin sprint-4
git log --oneline -1
```

## 15. Tres líneas y mensaje para Yov (fase 2)

**Tres líneas:**

- Una operación publicada y abierta acepta el BAPLIE que le falta: la oficina lo confirma en un
  diálogo que dice cuándo se publicó la operación, el viaje que declara el archivo y las cifras
  del plan; sube en un lote con sus huellas y, si la nube no acepta, nada local cambia. La
  búsqueda mira el equipo y la nube; si la operación está solo en la nube, la banda lleva a
  «Unirse», y «Publicar operación» ya no publica una segunda del mismo buque, viaje y puerto.
- El muelle lo recibe solo, avisa con las cifras y ofrece «Abrir»; los movimientos no se
  tocan y el estado se deriva igual que con los dos planos publicados juntos (es una propiedad
  probada); `join` trae las tres fuentes; la operación conserva su viaje y la fuente recuerda el
  que declara. El eco antes que el acuse ya no hace que la oficina se avise a sí misma, tampoco
  con el listado de T-127. La salida lleva el viaje del plan de carga en el nombre y lo dice en
  la página.
- 37 pruebas nuevas en verde (rojas contra `a18d2d3`: no compilan), la suite en 1951 de 1951
  sin omitidas, `analyze` en cero antes y después; en el emulador, 69 de 69, 25 de 25, 31 de 31 y
  38 de 38 contra las reglas de T-130 (`docs/T130-firestore.rules.propuesta`, `8B903949…`), y
  contra las de T-127 solo caen los 11 casos que T-130 abre o cierra.

**Mensaje para Yov:**

> T-130, fase 2, sobre `a18d2d3` (T-129 con su corrección y T-132 en `sprint-4`): la base dio
> `analyze` cero y 1914 de 1914, aunque esa suite corrió encima de la ventana de Codex, lo digo en
> el informe (6), y desde entonces cada comando de Flutter se pidió a Carlos. Lo hecho es el
> diseño de 3 con los seis ajustes y tus dos cambios (7): `addSource` y `OwnSourceWrites` en el
> adaptador (el registro cubre también `replaceSource`), `watchSources` y `_syncPlans` en el
> motor, `OperationSources.find` por el viaje declarado y `lookup` con sus cuatro salidas, la
> búsqueda en el equipo y en la nube, el previo con el motivo nuevo, el diálogo
> `confirmarAgregarPlan` (fecha de publicación, viaje, cifras), `AvisoDelPlan` con «Abrir»,
> «Fuentes: …» en «Nube y cuenta», la negativa de `publish`, y en la salida el nombre con
> `departureVoyageNumber` y la nota del viaje (solo eso de los archivos de T-132). Reglas:
> T-127 más `validPlanAddition`, `validAddedPart` sin `get` y `validPublishedPart &&
> op.createdAt == request.time`; huella `8B9039496CCC…` (484 líneas). Cifras: 37 nuevas en
> verde (8 fallos de primera corrida, todos de las pruebas o de las nubes falsas: 8), rojo contra
> `a18d2d3` = no compilan (254 errores), suite 1951 de 1951 sin omitidas, `analyze` cero;
> emulador 69/25/31/38 contra T-130 y 69/25/31 contra T-127, con 27 de 38 en la de T-130 contra
> T-127 (los 11 que caen, explicados en 9); el emulador no mencionó el límite de accesos, y lo
> digo sin afirmar que lo cuente como producción. Para Carlos: publicar y cotejar en 10, la
> lista del piloto en 11, la prueba de punta a punta en 3.10 con `tool/t130_emu_main.dart`.
> ALTO: Yov revisa, Codex acepta.
