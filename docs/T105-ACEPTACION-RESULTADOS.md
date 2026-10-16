# T-105 · Aceptación cruzada (Timonel)

**Estado: PASA. T-105 queda aceptada, con su corrección 10.63 verificada** (sección 6).
Acepto el commit `3473e10` de Capitán Codex (informe `docs/T105-RESULTADOS.md`, ficha en la Ola 5 de `SPRINT-3.md`, decisiones 10.54 y 10.62) y su corrección `3086db2` (10.63).

## 1. Resultado

- **Validaciones:** 799/799, `analyze` en cero, corpus 135/135 en 34 archivos y los SHA del informe, todo en verde.
- **Dominio:** `preview`, `move` y `request` coinciden en 18 casos propios. Los tres controles nuevos de `request()` son reales: con el código anterior a T-105 fallan los tres. El ajuste de T-80 solo cambia el estado de partida.
- **Tres clientes, sobre una operación nueva, «PRUEBA T-105 TM»:** pasan movimiento, intercambio, las solicitudes con borde punteado y reloj, la aprobación y el rechazo sin recargar, los rojos sin hoja, la cancelación sin registro, lo que no se arrastra, el toque, el zoom y el reinicio del zoom al cambiar de bahía.
- **Bitácora:** de 0 a 7 registros, con 0 conflictos y las mismas cifras en los tres clientes.
- **Almacén real de Windows:** los 400 archivos previos quedan idénticos; solo se agregan 14 `t105tm_*`.
- **Honor:** lo encontré con la letra en 2.0. Queda en 1.0 y con solo mi variante cerrada.
- **Un hallazgo real, anterior a T-105 pero visible por el arrastre:** `review()` no veía que un 40 en bahía par ocupa la misma fila y nivel en las dos impares vecinas. **Capitán lo corrigió en `3086db2` (10.63), y lo verifiqué:**
  - mi prueba de la sombra pasa 6/6;
  - en Windows, el gesto sobre la sombra sale en rojo y sin hoja, en los dos sentidos;
  - con `3086db2` y la corrección de T-96 encima: 842/842, `analyze` en cero y corpus 135/135.
- **Chrome queda sin probar por los dos lados.** La Web se probó en el navegador integrado, con autorización de Carlos.

## 2. Base y método

- **Base:** `7a06c5d`, confirmada por Carlos. `3473e10..7a06c5d` no cambia código (`git diff --stat --ignore-cr-at-eol` vacío en `lib`, `test`, `tool`, `android`, `pubspec.*`, reglas y `firebase.json`).
- **Copia:** los 620 archivos de `git ls-files`, sacados uno a uno con `git show 7a06c5d:<ruta>`, en `%TEMP%\baystream-t105tm-7a06c5d` (00:25, 0 fallos). El árbol compartido no se tocó.
- **Durante la aceptación entró `eb3504b`** (aceptación de T-56 de Capitán). Solo agrega `docs/T56-ACEPTACION-RESULTADOS.md` y no afecta a T-105.
- **Namespace `t105tm` y `applicationId` `.t105tm`,** solo en la copia. Banco variante en la sección 7.
- **Compilaciones** con `--dart-define-from-file=C:/Proyectos/baystream-privado/firebase-prod.json`, sin abrirlo. No abrí `android/key.properties`: no está en la copia, y el APK de la copia se firma con la clave de depuración.
- **Un comando de Flutter a la vez.** Avisé a Carlos al empezar y al terminar las compilaciones, porque Capitán trabaja en paralelo en la 10.63.
- **Git:** solo `log`, `show`, `diff --stat --ignore-cr-at-eol` y `ls-files`, más dos lecturas fuera de la lista, declaradas en la sección 14.
- **Nada de Firebase fuera de la app.** No usé `flutter test --platform chrome`.

## 3. Validaciones

| Comprobación | Resultado | Evidencia (`build/t105tm/`) |
|---|---:|---|
| Suite completa sobre la copia de HEAD | **799/799**, código 0, 52 s. Es el piso de HEAD: T-105 fue el último cambio de código | `suite.log` |
| `flutter analyze` | **0 incidencias** | `analyze.log` |
| Corpus completo (32 `*_corpus_test.dart` + `t52`/`t53`) | **135/135**, código 0, 43 s | `corpus.log` |
| `pubspec.lock` después de `pub get` | Sin cambio (`577d742e…`) | — |
| Compilaciones del banco variante | Windows Release 146 s · APK Release · Web Release 58.9 s | `build-windows.log`, `build-android.log`, `build-web.log` |

### SHA-256

**Los nueve protegidos del informe de Codex coinciden byte a byte en la copia:** `firestore.rules`, `firebase.json`, `lib/main.dart`, los dos congelados, `pubspec.yaml`, `pubspec.lock`, `movement.dart` (el modelo de movimientos) y `firestore_operation_sync.dart` (el codec).
- En el árbol compartido coinciden los mismos, salvo `pubspec.yaml`. Allí está con CRLF (`1b40e530…`) y, sin los CR, es idéntico al blob de HEAD (`6cafa52d…`).

**Las siete fuentes entregadas coinciden con la tabla del informe:**
- `tool/t105_main.dart` coincide byte a byte.
- Las otras seis, Codex las midió con CRLF, como las colocó en el árbol. En el árbol coinciden en bruto. En la copia, que es el blob LF de HEAD, coinciden al convertirlas a CRLF:
  - `change_requests.dart` `a3bbf6e3…`;
  - `bay_plan_view.dart` `0f92e2bc…`;
  - `plan_drag_confirmation.dart` `6e4530ad…`;
  - `t105_preview_test.dart` `a2dd21e0…`;
  - `t105_drag_widget_test.dart` `8b3aabfe…`;
  - `t80_requests_widget_test.dart` `081e7d6d…`.
- El contenido es el mismo; la diferencia es solo de fin de línea.

## 4. Dominio

### 4.1 `preview` = `move` = `request`, con casos propios

Están en `tool/t105tm_cruzada_test.dart`, solo en la copia; se guarda una copia en `build/t105tm/` (SHA `b5f5788d…`). Usan los fixtures de T-76, distintos de los de Codex. **18/18 en verde** (`dominio-cruzada.log`).

En cada caso:
- `preview` da lo mismo para oficina y muelle;
- `move` y `request` aceptan o rechazan igual, con **el mismo mensaje** que `preview`;
- en lo válido, `isSwap` se corresponde con el lote.

| Caso | Esperado | Mensaje (idéntico en los tres caminos) |
|---|---|---|
| Libre a otra bahía, con llegada | válido | — |
| Intercambio de reservas del mismo grupo, sin llegada | válido | — |
| El mismo, con INCOMING2 a bordo en 0030482 | rojo | `0030482 está ocupada; marca primero su descarga.` |
| El mismo, tras descargar INCOMING2 | válido | — |
| Contenedor ↔ reserva | válido | — |
| Reservas de distinta línea | rojo | `Las reservas del intercambio deben ser del mismo grupo.` |
| Reserva ya asignada con un vacío | rojo | `Solo se mueve un objeto pendiente del plan de carga.` |
| Pareja ya cargada en el intercambio | rojo | ídem |
| Pareja cancelada en el intercambio | rojo | ídem |
| Intercambio hacia INCOMING1 a bordo | rojo | `0030282 está ocupada; …` |
| El mismo, tras descargar INCOMING1 | válido | — |
| Rotación de tres, sin llegada (`isSwap` = sí) | válido | — |
| Rotación de tres hacia INCOMING1 | rojo | `0030282 está ocupada; …` |
| Reserva 45G1 hacia bahía impar | rojo | `R:0030182 no cabe en la bahía 5.` |
| Destino repetido | rojo | `Indica de uno a cuatro cambios válidos, sin repetir objetos ni destinos.` |
| Cinco cambios | rojo | ídem |
| Los tres controles de `request()`, aislados | rojo ×3 | los tres mensajes de arriba |
| `preview` es pura y exige sesión autorizada | — | `Inicia sesión para mover` |

### 4.2 Los tres controles nuevos de `request()`, contra el código anterior

`tool/t105tm_request_previo_test.dart` (SHA `c5d572d1…`) usa solo `request()`. Lo corrí en la copia con dos versiones de `change_requests.dart`, y después restauré la de HEAD con su SHA (`5c4da222…`):

| Código | Muelle pide mover lo cargado | Muelle pide una celda ocupada a bordo | Muelle pide intercambiar reservas de grupos distintos |
|---|---|---|---|
| HEAD (T-105) | rechaza | rechaza | rechaza |
| `f6bac1f` (antes de T-105) | **acepta** | **acepta** | **acepta** |

El hallazgo de 10.62 es real: antes de T-105, el muelle podía pedir los tres cambios. Evidencia: `request-controles-head.log` y `request-controles-previo.log`.

### 4.3 El ajuste de `test/t80_requests_widget_test.dart`

- **El diff tiene dos trozos, y los dos hacen lo mismo:** anteponen `t76Movement(MovementDraft.discharge('op', 'INCOMING1', '0030282'), -1)` a la operación, en el stream del widget y en la segunda solicitud. Así, INCOMING1 ya descargó y 0030282 queda libre.
- **No cambia ningún `expect` ni ningún paso.** Sigue probando la solicitud del muelle, la aprobación con motivo, la segunda solicitud rechazada, que sin cuenta no se ofrece nada y los permisos: rol, autorización, operación publicada y motivo del rechazo.
- **El ajuste era necesario.** El T-80 anterior, corrido contra el código de HEAD, falla en sus dos variantes de tema con `0030282 está ocupada; marca primero su descarga.` (`t80-previo-contra-head.log`). El archivo se puso en la copia solo para esa corrida y después se retiró.
- **El T-80 actual pasa 4/4** (`t80-actual.log`).

## 5. Banco y operación de prueba

- **«PRUEBA T-105» no se tocó.** Es la de la demo del 17. En Windows, el namespace `t105tm` hizo «Unirse» a ella, pero no la abrí. Unirse solo lee del servidor: `join()` hace dos `get` y guarda una copia local.
- **Las pruebas se hicieron sobre «PRUEBA T-105 TM»** (viaje T105TM, escala GTSTC), publicada por la oficina desde la app, con las fuentes llegada, carga y listado. Queda en Firestore como prueba, y Carlos la borra después desde la consola.

## 6. Hallazgo: la sombra del 40 (10.63)

**El caso exacto:**
- **El 40:** TSTU0000016 (OR 6), 45G1, pendiente, en **0040182**: bahía 004, fila 01, nivel 82. Ocupa físicamente 003-01-82 y 005-01-82.
- **El 20:** TSTU0000011 (OR 1), 22G1, pendiente, de 0030282 a **0030182**, bajo la sombra del 40. En pantalla lo moví desde 003-00-82, adonde lo había llevado el primer movimiento de la oficina.
- **Variantes:**
  - TSTU0000015, de 0050282 a 0050182;
  - el 40, de 0040182 a 0040282, encima de los 20 de 0030282 y 0050282;
  - el 20 a 0030182 con el 40 ya cargado a bordo.
- **Lo que da hoy:** `preview` válido. En pantalla, verde con ✓, y la hoja se abre. `move()` y `request()` lo aceptan. El formulario de T-81 y la solicitud de T-80 pasan por el mismo `review()`.
- **Lo que debe dar:** rojo, con el mismo mensaje en `preview`, `move` y `request`, y que nombre la celda de destino. La redacción la decide Capitán; propuse «0030182 está prevista para el 40 de 0040182.». Siguen válidos el 20 a 0030082 y el 40 a 0040082.
- **Visto en Windows:**
  - el verde sobre «40'» en 003-01-82, y la hoja «Mover OR 1 · TSTU0000011, 003-00-82 → 003-01-82», que cancelé;
  - el verde al revés, sobre 004-02-82;
  - la vista de la 004 no dibuja los 20 de las bahías vecinas, así que el planificador no ve el choque.
  - Captura: `windows-sombra40-verde-hoja.jpg`.
- **La prueba que lo reproduce** es `build/t105tm/t105tm_sombra40_test.dart` (SHA `a144a0a8…`). Es autónoma y se la entregué a Carlos en el chat para Capitán. Sobre `7a06c5d`: 4 conflictos fallan («hoy sale válido») y 2 controles pasan (`sombra40-head.log`).

### 6.1 Verificación de la corrección de Capitán (`3086db2`, 10.63)

**El cambio:**
- toca `change_requests.dart`, dos pruebas nuevas (`t105_physical_collision_test.dart`, 29 casos, y `t105_timonel_shadow40_test.dart`) y su sección del informe;
- `review()` compara por huella física (la par ocupa sus dos impares, en la misma fila y el mismo nivel);
- revisa a la vez lo que está a bordo y lo previsto;
- la ocupación a bordo pasa de `preview()` a `review()`, así que `decide()` también la revisa al aprobar.

**La prueba de la especificación:**
- Capitán la incorporó como `test/t105_timonel_shadow40_test.dart`. Tiene el mismo SHA que mi original, `a144a0a8…`, en el árbol (en bruto y sin CR), en `3086db2` y en `build/t105tm/`.

**Las comprobaciones:**

| Comprobación | Resultado | Evidencia (`build/t105tm/v3086/`) |
|---|---|---|
| Copia de `3086db2` (623 archivos) con la corrección de T-96 encima; igual al árbol en los 323 archivos de `lib/`, `test/`, `tool/` y `pubspec.*` | — | — |
| Suite completa | **842/842**: los 834 de Capitán (799 + 35) y las 8 de T-96 | `suite.log` |
| `flutter analyze` | **0** | `analyze.log` |
| Corpus, 34 archivos | **135/135** | `corpus.log` |
| Mi prueba de la sombra | **6/6**: los 4 conflictos en rojo y los 2 controles válidos | `sombra40-3086db2.log` |
| Mis 16 casos de equivalencia | `preview`, `move` y `request` siguen con la misma validez y mensajes idénticos entre sí | `propias-3086db2.log` |
| Tres controles de `request()` | siguen rechazando | ídem |

Dos aserciones mías fallan contra `3086db2`, y está bien que fallen:
- la que fijaba el texto viejo «0030282 está ocupada; …». Ahora dice «0030282 choca con INCOMING1 en 0030282: La celda está ocupada a bordo; marca primero su descarga.», y sigue rechazando;
- la de `t105tm_banco_test.dart`, que esperaba **verde** para el 40 de la 004 sobre 004-02-82. Era el hallazgo mismo, y ahora sale rojo.

**El gesto en Windows,** con `3086db2` y el banco variante, sobre «PRUEBA T-105 TM» como oficina:
- abierta con `explorer.exe`, PID 3728, una sola instancia, y cerrada por PID;
- **OR 1, de 003-00-82 a la sombra «40'» en 003-01-82:** borde rojo y ⊘, sin hoja. El aviso dice «0030182 choca con TSTU0000016 en 0040182: un 40 ocupa las dos mitades de la celda. La celda está prevista para otro objeto; inclúyelo en el intercambio.» (`windows-sombra40-rojo.jpg`, `windows-sombra40-aviso.jpg`);
- **al revés, OR 6 (el 40), de 004-01-82 a 004-02-82:** rojo y sin hoja, con «0040282 choca con TSTU0000014 en 0030282: un 40 ocupa las dos mitades de la celda. …». OR 4 está en 003-02-82 desde la aprobación (`windows-40-inverso-rojo.jpg`, `windows-40-inverso-aviso.jpg`);
- **la bitácora sigue en 7 registros y 0 conflictos.** Los dos gestos no registraron nada.

## 7. Banco variante (no se entrega)

- **`tool/t105_main.dart`, solo en la copia.** Diff completo en `build/t105tm/banco-variante.diff`; SHA en la copia `bb677d9a…`.
- **Lo que cambia:**
  - el namespace `t105acc` pasa a `t105tm`;
  - la operación, a «PRUEBA T-105 TM» (T105TM, IMO sintético 9000015);
  - el plan de carga tiene 7 pendientes, TSTU0000011 a 17 (OR 1 a 7), en las bahías 003, 004 y 005, más el tránsito TRNU0000021 en 0030382 (HNPCR → PAMIT);
  - el plano de llegada tiene una descarga, DSCU0000031 en 0030582 (HNPCR → GTSTC), y el mismo tránsito;
  - el listado lleva siete filas.
- **Los dos 40, como pidió Carlos:**
  - TSTU0000016 en 0040182, bien planificado;
  - TSTU0000017 en **0050482**: un 40 previsto en bahía impar. **Es un dato incoherente a propósito, PROVISIONAL, construido solo para ver el rojo «no cabe en la bahía 5».**
- **Gradle, solo en la copia:** `applicationId` pasa a `gt.cmartinez.baystream.t105tm` (`gradle-variante.diff`, una línea).
- **Antes de usarlas, comprobé las fuentes en el dominio** (`tool/t105tm_banco_test.dart`, `banco-fuentes.log`): bahías {3, 4, 5}, siete pendientes, DSCU como descarga, TRNU como tránsito, y los rojos, el ámbar y el verde donde se esperaban.

## 8. Tres clientes

**Reparto:**
- **Windows, con mouse, oficina:** PID 26668, abierta con `explorer.exe`, ventana de 1389×868.
- **Honor, con el dedo, muelle:** `.t105tm`, a 360×800 dp.
- **Web, muelle:** en el navegador integrado, servida desde mi copia en `localhost:8106` (PID 3916).

Carlos escribió las tres credenciales; no tomé capturas ni volcados mientras lo hacía. En el Honor, los gestos son pulsación larga táctil por ADB (`motionevent DOWN/MOVE/UP`); el pellizco lo hizo Carlos a mano.

| Comprobación | Windows (oficina) | Honor (muelle) | Web (muelle) |
|---|---|---|---|
| Mover OR 1, 003-02-82 → 003-00-82: verde con ✓, hoja «Mover OR 1 · TSTU0000011», motivo «Peso», «Confirmar» | hecho | lo ve sin recargar | lo ve sin recargar |
| Intercambiar OR 2 ↔ OR 3 (003-04-82 ↔ 003-06-82): ámbar con ícono de intercambio, hoja «Intercambiar OR 2 · TSTU0000012 ↔ OR 3 · TSTU0000013», «Segregación» | hecho | lo ve sin recargar | lo ve sin recargar |
| Solicitud de OR 4, 003-08-82 → 003-02-82, «TM muelle Honor OR4»: hoja «El objeto sigue en su celda…», «Enviar solicitud» | ve el borde punteado y el reloj; «Bandeja de cambios (1)» | hecho; borde punteado y reloj en 003-02-82, OR 4 sigue en la 08 | ve el borde punteado y el reloj |
| Solicitud de OR 5, 005-02-82 → 005-00-82, «Acceso de grúa» | ve la marca; «(2)» | ve «Solicitud pendiente en 005-00-82» | hecha por Carlos con el mouse (ver abajo) |
| La oficina aprueba la de OR 4 («TM aprobar Honor») | tarjeta «Aprobada» | OR 4 pasa a 003-02-82 y la marca se va, sin recargar | ídem |
| La oficina rechaza la de OR 5 («TM rechazar Web») | tarjeta «Rechazada» | OR 5 sigue en 005-02-82 y la marca se va, sin recargar | ídem |
| Rojo sin hoja: OR 7 (el 40 incoherente) dentro de la 005 | borde rojo y ⊘; aviso «C:TSTU0000017 no cabe en la bahía 5.» | igual, con el dedo | — |
| Rojo sin hoja: OR 1 sobre 003-05-82 (descarga a bordo) | ⊘; aviso «0030582 está ocupada; marca primero su descarga.» | — | — |
| Cancelar no registra | tres veces: sombra, OR 6 en la 004 y OR 3 a 300 % | una, con la solicitud de OR 5 a 125 % | — |
| Lo cargado no se arrastra (OR 2, que cargó la oficina) | no se levanta; el toque abre «OR 2 · Cargado» | no se levanta; el movimiento desplaza la rejilla; el toque abre la ficha | — |
| El tránsito no se arrastra (TRNU0000021) | no se levanta; el toque abre sus detalles | ídem | — |
| La descarga (DSCU0000031) | en el modo Carga no se dibuja: su celda se ve vacía y soltar ahí da rojo | — | — |
| El toque sobre un pendiente | abre «Confirmar carga» de OR 1 | — | — |
| El 40 bien planificado (OR 6, en la 004) | se mueve dentro de la 004 (verde en 004-08-82, cancelado); su sombra en la 003 no se levanta | — | — |

**La solicitud del muelle desde la Web la hizo Carlos con el mouse en el panel integrado.** La herramienta del navegador suelta enseguida y no sostiene la pulsación larga: mi intento no levantó nada y no registró nada. Comprobé el resultado en la propia Web («Movimientos 4», «Solicitudes de cambio (2)», la marca en 005-00-82) y en Windows y el Honor. **Chrome no se probó, ni por Codex ni por mí.**

### Zoom

| | Windows (mouse) | Honor (dedo) |
|---|---|---|
| Controles | «100 %» abre −, %, + y ×; pasos de 25 | igual; se pliegan al tocar el plano |
| Pellizco | — | Carlos, de 100 % a 150 %, sin registros |
| 125 %, bordes | la rejilla cabe entera en 1389 px | izquierda («bod.», 84 y 82), derecha (columna 05), arriba (título) y abajo (bodega 04 y 02) |
| 300 %, bordes | arriba, abajo, izquierda (niveles) y derecha («25.0 t»), con la rueda y Mayús + rueda | izquierda y abajo («02» y la primera celda) y derecha (la última celda de bodega con margen) |
| Un dedo desplaza | — | sí, también con zoom |
| Pulsación larga con zoom | arrastra a 300 % (OR 3, verde en 003-08-82, cancelado) | arrastra a 125 % (OR 5, verde en 005-00-82, cancelado) |
| Cambiar de bahía reinicia el zoom | 300 % → 100 % al pasar a la 04, y la 03 vuelve a 100 % | 125 % → 100 % al pasar a la 04; la 03 abre a 100 % |

## 9. Bitácora de «PRUEBA T-105 TM»

| Momento | Registros | Conflictos |
|---|---:|---:|
| Publicada, antes de los gestos | 0 | 0 |
| Mover OR 1 | 1 | 0 |
| Intercambio OR 2 ↔ OR 3 | 2 | 0 |
| Solicitud OR 4 (Honor) | 3 | 0 |
| Solicitud OR 5 (Web) | 4 | 0 |
| Aprobar OR 4 | 5 | 0 |
| Rechazar OR 5 | 6 | 0 |
| Rojos, sombra, OR 6 y tránsito, todos cancelados o sin hoja | 6 | 0 |
| Carga de OR 2 (para comprobar lo cargado) | 7 | 0 |
| Cancelaciones con zoom, rojo del Honor y pellizco | 7 | 0 |
| **Final, igual en Windows, el Honor y la Web** | **7** (6 pendientes, 0 solicitudes pendientes, «Al día») | **0** |

**Posiciones finales:** OR 1 en 0030082 · OR 2 en 0030682 (cargado) · OR 3 en 0030482 · OR 4 en 0030282 · OR 5 en 0050282 · OR 6 en 0040182 · OR 7 en 0050482 · TRNU en 0030382.

## 10. Almacén real de Windows

- **Las huellas se tomaron fuera del paquete:** un BAT propio lanzado con `explorer.exe`, cuyo proceso padre es `cmd.exe`. Están en `store-before.json`, `store-mid.json`, `store-after.json` y `store-comparison.json`.
- **Antes (06:34 UTC):** 400 archivos, 0 inaccesibles, ningún `t105tm_*`. Coincide con los 400 con que cerró Codex.
- **Intermedia,** tomada tras la incidencia de la sección 14: 400 originales idénticos y 8 `t105tm_*` agregados, bloqueados por la app abierta.
- **Después de cerrar por PID 26668 (07:28 UTC):** **414 archivos, los 400 originales idénticos, 0 modificados, 0 borrados, 0 inaccesibles.** Los **14 agregados son todos `vessel_store\t105tm_*`**: device, movements, operations, profiles, session, settings y voyages, cada uno con `.hive` y `.lock`.
- **Final, después de la verificación de la 10.63 y de cerrar por PID 3728 (07:56 UTC):** lo mismo. 414 archivos, los 400 originales idénticos, 14 agregados, todos `t105tm_*`, y 0 inaccesibles (`store-final.json`, `store-comparison-final.json`).

## 11. Honor

- **Cómo lo encontré:**
  - la letra en **2.0**, 720×1600 a 320 dpi;
  - ningún proceso de BayStream;
  - el lanzador en primer plano;
  - Wi-Fi encendido y modo avión apagado;
  - estaba instalada la `.t105` de Codex.
- **La letra la puso Carlos en 1.0,** porque el ajuste del sistema no lo cambio yo. Lo leí por ADB antes de los gestos.
- **Instalé solo `gt.cmartinez.baystream.t105tm`** (APK `bfb2add2…`).
- **Cómo queda:**
  - `font_scale` = **1.0**, la misma resolución y densidad;
  - **solo `.t105tm` cerrada,** con `am force-stop`, sin desinstalar nada;
  - ningún proceso de BayStream y el lanzador en primer plano.
- **Los volcados** se capturan en memoria (`build/t105tm/honor_dump.py`): ocultan cuentas y UID y descartan formularios de acceso o ventanas ajenas sin guardarlos.

## 12. Observaciones (no son defectos de T-105, para que Yov decida)

1. **El aviso rojo muestra la clave interna:** «C:TSTU0000017 no cabe en la bahía 5.», no «OR 7 · TSTU0000017». El texto sale de `review()` y ya se veía así en el formulario de T-81.
2. **Con una ventana ancha de Windows, a 300 % el plano abre en blanco:** la rejilla está centrada en un lienzo tan ancho como la vista sin zoom, y hay que bajar y desplazarse para encontrarla. En el Honor, a 300 %, las esquinas superiores también son margen.
3. **A 300 % el relleno de 16 dp también se escala:** en el Honor deja unos 48 dp sin celdas a cada lado (las celdas se cortan en x≈96 y x≈624 px).
4. **En el modo Carga, la descarga pendiente no se dibuja.** 003-05-82 se ve vacía, aunque el banco dice «Descarga: 1 pendiente». Soltar ahí da el rojo correcto. Viene de T-76, no de T-105.
5. **La vista de una bahía par (004) no dibuja los 20 de las impares vecinas.** Junto con el hallazgo de la sección 6, el choque no se ve.
6. **A 300 %, la copia que se arrastra se dibuja sin la escala** (más chica que la celda). Es cosmético.
7. **La consola de la Web registró una vez** «An unknown error occurred when fetching the script.». La app cargó y funcionó; no lo investigué.
8. **Con la 10.63, el consejo final del aviso no siempre aplica.**
   - Un 20 bajo la sombra de un 40 recibe «inclúyelo en el intercambio», pero un 20 y un 40 no se pueden intercambiar.
   - Un tránsito a bordo recibe «marca primero su descarga», pero un tránsito no se descarga: se re-estiba.
   - El rojo es correcto en los dos casos; solo sobra la segunda frase.
9. **La sombra del 40 en una impar no tiene toque:** no abre detalles, ni del 40 ni de la celda.

## 13. Lo que no se cubrió

- **Chrome:** no se probó, ni por Codex ni por mí.
- **La matriz de oficina solo en Windows.** La oficina movió e intercambió en Windows; el Honor y la Web la vieron como muelle. La lista de la aceptación pide el movimiento y el intercambio de oficina en un cliente; la ficha pedía los tres, y Codex ya lo hizo en los tres.
- **El zoom en la Web** no estaba en la lista y no lo probé.

## 14. Incidencias declaradas

1. **Dos instancias extra de BayStream en Windows (PID 37980 y 33188).**
   - Las abrió `open_application` del control de escritorio; su padre era `claude.exe`, dentro del paquete.
   - Las cerré por PID antes de un minuto.
   - La huella intermedia, tomada fuera del paquete, muestra los 400 originales idénticos. En el almacén del paquete no apareció ningún `t105tm_*`.
   - No volví a usar `open_application`: traje la ventana al frente con `SetForegroundWindow` sobre el PID 26668 (`focus.ps1`).
2. **El control de escritorio veía el shell como ventana frontal.** Carlos me concedió «File Explorer» en el nivel de solo clic, para activar BayStream con un clic en su barra de título. No hice clics ni escribí nada en el escritorio.
3. **Usé dos veces `git diff --no-index`,** fuera de la lista permitida, para comparar el banco de la copia con el del árbol. Es de solo lectura y no toca el índice. Después cambié a `diff` sin Git.
4. **Un `type` del control de escritorio pegó por portapapeles y Flutter no lo recibió.** Usé la sugerencia «Peso» de la propia hoja. Los demás motivos se escribieron bien.
5. **Python en Windows escribió el banco y Gradle con CRLF.** Los devolví a LF antes de compilar, y los diffs muestran solo los cambios reales.
6. **Una redirección de PowerShell corrompió una captura PNG.** La rehice con Bash y no la uso como evidencia.

## 15. Horas

- **Aceptación principal:** de **00:25** (se crea la copia) a **01:29** (cierre de los clientes), **≈ 1.1 h**, con compilaciones y esperas de Carlos.
- **Verificación de la 10.63:** de **01:52** a **01:57**, **≈ 0.1 h**, con el build de Windows. La suite, `analyze` y el corpus de esa copia los comparte con la corrección de T-96.
- **Entre las dos,** la aceptación quedó abierta mientras Capitán corregía; en ese tiempo hice la corrección de T-96, que se cuenta en su propio informe.
- No es un cronómetro de trabajo activo. Esta tarea no tiene presupuesto propio en la ficha.

## 16. Archivos

- **Se entrega solo este informe:** `docs/T105-ACEPTACION-RESULTADOS.md`. El bloque de Git lo escribe Yov.
- **No cambian** `lib/`, `test/`, `tool/`, `pubspec.yaml` ni `pubspec.lock` en el árbol.
- **Evidencias locales, fuera del commit, en `build/t105tm/`:**
  - registros de las validaciones;
  - las pruebas propias (`t105tm_*_test.dart`);
  - los diffs del banco y de Gradle;
  - las huellas;
  - volcados y capturas del Honor;
  - la captura de la sombra del 40.
- El corpus no se copia.

## 17. Tres líneas

T-105 pasa la aceptación cruzada: 799 pruebas, análisis cero y corpus 135, y en el dominio `preview`, `move` y `request` coinciden en 18 casos propios; los tres controles nuevos de `request()` fallan con el código anterior.
En Windows, el Honor y la Web, sobre «PRUEBA T-105 TM»: movimiento, intercambio, solicitudes con reloj, aprobación y rechazo sin recargar, rojos sin hoja, cancelación sin registro y zoom a 125 % y 300 %, con la bitácora en 7 registros y 0 conflictos.
El hallazgo de la sombra del 40 quedó corregido en `3086db2` (10.63): mi prueba pasa 6/6 y en Windows el gesto sale rojo y sin hoja en los dos sentidos; Chrome queda sin probar.

## 18. Mensaje para Yov

Timonel aceptó T-105 (`3473e10`) y su corrección 10.63 (`3086db2`). Informe: `docs/T105-ACEPTACION-RESULTADOS.md`.

- **Base `7a06c5d`, en una copia de `%TEMP%`:**
  - 799/799, `analyze` en cero y corpus 135/135;
  - los nueve SHA protegidos del informe de Codex, iguales;
  - las seis fuentes que Codex midió con CRLF coinciden al convertirlas.
- **Dominio:**
  - `preview`, `move` y `request` dan lo mismo en 18 casos propios, con mensajes idénticos;
  - los tres controles nuevos de `request()` fallan con el código de `f6bac1f`, así que el hallazgo de 10.62 es real;
  - el ajuste de T-80 solo cambia el estado de partida, y el T-80 viejo falla contra el código nuevo.
- **Los clientes,** sobre una operación nueva, «PRUEBA T-105 TM», que pidió Carlos. Es un banco variante que no se entrega (namespace `t105tm`): siete pendientes en las bahías 03, 04 y 05, una descarga, un tránsito y dos 40. El de la 005 es un dato incoherente a propósito, PROVISIONAL.
  - **Lo que pasa:** movimiento, intercambio, solicitudes con borde punteado y reloj, aprobación y rechazo sin recargar, rojos sin hoja, cancelar sin registro, lo cargado y el tránsito sin arrastre con su toque, el zoom a 125 % y 300 % con sus bordes, el pellizco y el reinicio del zoom al cambiar de bahía.
  - **Reparto:** Windows como oficina; el Honor y la Web como muelle.
  - **La solicitud desde la Web la hizo Carlos con el mouse,** porque la herramienta no sostiene la pulsación larga.
  - **La bitácora:** de 0 a 7 registros, con 0 conflictos en los tres clientes.
- **Hallazgo:** un 20 bajo la sombra de un 40 salía en verde.
  - Lo especifiqué en una prueba y Capitán la incorporó sin cambios (SHA `a144a0a8…`).
  - Con `3086db2`: pasa 6/6, y en Windows el gesto sale rojo y sin hoja en los dos sentidos.
  - Con la corrección de T-96 encima: 842/842, `analyze` en cero y corpus 135/135.
- **Almacén real de Windows:** los 400 archivos previos quedan idénticos; se agregan solo 14 `t105tm_*`.
- **Honor:** lo encontré en 2.0; queda en 1.0 y solo con `.t105tm` cerrada.
- **«PRUEBA T-105» no se tocó.** «PRUEBA T-105 TM» queda en Firestore para que Carlos la borre.
- **Incidencias declaradas:**
  - dos instancias extra de Windows, cerradas por PID antes de un minuto y sin rastro en el almacén;
  - dos `git diff --no-index` de solo lectura.
- **Nueve observaciones para decidir.** Entre ellas: el aviso muestra «C:…»; a 300 % el plano abre en blanco en una ventana ancha; la descarga no se dibuja en Carga; la vista par no dibuja los 20 vecinos; y el consejo «inclúyelo en el intercambio» no aplica entre un 20 y un 40.
- **Chrome queda sin probar,** por Codex y por mí.
