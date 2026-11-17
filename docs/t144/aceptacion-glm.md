# T-144 · Reaceptación 2 · Aceptación de GLM

**Dictamen: PASA.** El paso 0 pasa (suite 2221/2221 sin omitidas en una sola
corrida; del `analyze`, tres avisos `info` no deterministas de dos pruebas
ajenas a T-144, documentados abajo). **T144-ACC-02 queda CERRADO**: en Android
real a 360 dp con letra 1.0, 1.45 y 2.0, la Lista y el detalle no cortan nada,
la matrícula sale entera en el árbol y en las capturas, y la naviera baja de
línea solo a 360 dp con letra 2.0. La sonda funcional de la R1 vuelve a pasar
sobre la punta nueva. A06, el DIM completo, la vuelta real a la 1.0.0 y los
recorridos de Windows y Chrome pasan. Sin hallazgos nuevos P1, P2 o P3.
O-144-1 se mantiene conocida y no cuenta.

Fechas: **15-nov y 16-nov-2026**, horario de Guatemala. Carpeta:
`C:\Proyectos\baystream-qa-r4`, HEAD separado en
`d32a6ddcbb0cd3a3caabaf0043ef1ff159eac2e6` («Sprint 4: decision 10.129, GLM en
lugar de Codex y T-145 con Timonel»). Evidencia propia:
`build/t144/aceptacion/reaceptacion2/` (en adelante **R2**), ignorada por
`/build/`. La evidencia de Codex (`build/t144/aceptacion/` y
`reaceptacion1/`) no se tocó.

## 1. Lecturas y preparación

Se leyeron `CLAUDE.md` y `AGENTS.md` vigentes de `baystream-rediseno`,
SPRINT-4 sección 2 y decisiones 10.121 a 10.129 (la 10.129 existía sin
commitear al empezar; el primer intento de este trabajo se detuvo por eso y
Carlos corrió el bloque), `docs/T144-RESULTADOS.md` completo y
`docs/t144/aceptacion-codex.md` completo (primera aceptación y R1), y la parte
de Windows y Web de `docs/t143/aceptacion-codex.md` para armar el banco de
clientes. Se leyeron antes de usarlos los instrumentos de Codex: el banco
Android `integration_test/t144acc_mobile_test.dart` de la R1, la sonda
funcional `build/t144acc/sintetico_test.dart` con su `sintetico.edi`, la sonda
de búsqueda `busqueda_test.dart` y `tool/t130_emu_main.dart`. También
`tool/t143_emulador.py` y `banco_main.dart` de T-143, que son la base del
banco de clientes.

Carlos reservó el emulador de Android y los turnos de Windows (la app del
banco se abrió solo cuando Timonel no estaba instalando ni tomando huellas).
Todos los comandos de Flutter/Dart de R2 fueron consecutivos, con líneas
`SEMÁFORO:` al ocupar y liberar el carril. El Honor no estuvo disponible;
queda en la **lista de comprobación de la versión** (10.126), igual que en la
R1.

Una copia limpia nueva está en `R2/copia/`: **839 archivos cotejados por
SHA-256** (los 838 de la R1 más `test/t144_titulo_sin_cortes_test.dart` de la
corrección 2), con `lib/`, `test/`, `tool/`, integración, plataformas y
recursos; se recuperó la entrada sintética generada de T-124 del banco de
T-143 con la misma huella de siempre
(`d4384834fb9fc9cb18632b87180a7998cc3f91109edcbd33dbbf9787542d1162`), porque
O-143-3 sigue diferida. `pubspec.yaml` y `pubspec.lock` sin cambios en origen
y copia.

Dos instrumentos propios, corregidos sobre los de la R1 y anotados: el
registrador `run.py` de la R1 falla antes de lanzar Flutter con ciertos
órdenes de argumentos (`FileNotFoundError`; a Codex también le pasó) — R2 usa
`correr.py`, sin argparse; y el banco de la 1.0.0 se escribío dos veces
(abajo, 2.6). El primer intento de `pub get` y el primero de `flutter build
windows` no llegaron a lanzar Flutter por esas causas; los registros vacíos
quedaron como `*-intento0.log`. No cuentan como validaciones.

## 2. Lo ejecutado

### 2.1 Paso 0 — PASA, con una observación de entorno

| Comprobación | Resultado | Evidencia en R2 |
|---|---|---|
| Punta y commits | `d32a6dd` (10.129, solo `SPRINT-4.md`), sobre `1ac6b62` (10.128, solo `SPRINT-4.md`), sobre `caefc45` («Sprint 4: T-144, correccion 2, la matricula del detalle sin cortes»: los cinco archivos del informe) | `punta.json` |
| Árbol de contenido al empezar | `git diff --stat` vacío; solo los avisos de fin de línea conocidos en los cuatro archivos que Git ya marcaba | `punta.json` |
| Copia limpia | 839 archivos cotejados por SHA-256; HEAD separado leído del `.git` del worktree | `manifiesto.json` |
| `flutter pub get` | Salida 0; «Got dependencies!»; sin cambios de pubspec | `pub-get.log`, `pub-get-ejecucion.json` |
| `flutter analyze --no-pub`, todo el paquete | **3 avisos `info`** (abajo, 2.1.1), salida 1 | `analyze.log` |
| Suite completa, una sola corrida | **2221 aprobadas, 0 fallidas, 0 omitidas**, salida 0; T-144 dentro: 58 + 8; T-131 59/59 | `suite.log`, `suite-resumen.json`, `suite-ejecucion.json` |
| Fuzzing | No se repite: exento por el encargo, el lector no cambió | — |
| Integridad al cerrar | **Origen 839/839 sin diferencias**; copia con solo las 2 diferencias conscientes de la identidad Android (`android_identidad.py`) | `integridad.json` |

#### 2.1.1 · Observación de entorno: `analyze` no determinista en dos pruebas ajenas a T-144

El `analyze` de la copia limpia dio 3 `info` `use_build_context_synchronously`
en `test/t112_localization_test.dart` (49, 50 y 67). El 11-nov el mismo
archivo, con el mismo SDK (Flutter 3.38.9, caché de febrero) y la misma
configuración, analizaba limpio. La bisección mostró además que el analizador
reporta distinto según el conjunto de archivos del paquete: en una copia de la
R1 con solo los dos archivos de `lib/` de la corrección 2 encima aparecieron
los tres de t112 **y uno más** en `test/t121_estadisticas_test.dart`, que en
la copia completa no sale. Ninguno de los avisos toca `lib/`, `tool/` ni
archivo de T-144; son avisos `info`, no errores; y la suite completa pasa
2221/2221. Conclusión: no determinismo del analizador sensible al lote de
archivos, **no un defecto del producto ni de la corrección 2**. No se cambió
ninguna prueba ni configuración. Bisección y registros: `analyze.log`,
`analyze-repeticion.log`, `analyze-r1.log`, `analyze-bisect-sin-nueva.log`,
`analyze-bisect-lib.log` y la copia temporal `R2/bisect/`.

### 2.2 La sonda funcional de la R1, otra vez sobre la punta nueva — PASA

Los tres instrumentos de la R1 se copiaron con huellas idénticas
(`busqueda_test.dart`, `sintetico_test.dart`, `entrada.dart`, `sintetico.edi`)
a `R2/copia/build/t144acc/`. La corrección 2 tocó `lib/`, así que la sonda se
volvió a ejecutar:

- `sintetico_test.dart`: **1/1, salida 0**. Peligrosas 2/3/1 en detalle, Lista
  («IMO 3 +1»/«IMO 3 +2») y hoja de la Lista; CSV `3 | 8`, `3 | 8 | 2.1`,
  «DGS declarados» 2/3/1; destino final tal cual («PA - DESTINO SINTETICO»)
  solo donde hay LOC+83; DIM CMT 31/12/9/7/19 cm e INH 5/8/10/13/15 cm con los
  cinco avisos de conversión; avisos UN/LOCODE con las dos causas y acción;
  `XXVSL` y `*****` sin aviso. Registro: el print final «T144ACC DGS 2/3/1 y
  LOC+83 PASAN; DIM CMT/INH 5..9 y avisos propios PASAN.» | `sintetico.log`,
  `sintetico-resumen.json`.
- `busqueda_test.dart` (ampliada de la R1): **4/4**. «bysu 967» encuentra
  BYSU9672095; tres espacios, una tabulación y un espacio duro dan 0 y estado
  inicial. | `busqueda.log`, `busqueda-resumen.json`.

### 2.3 T144-ACC-02 · CERRADO (Android, banco extendido)

El banco de la R1 (`integration_test/t144acc_mobile_test.dart`) se extendió
**solo en la copia** con lo que pide el encargo: además de
`didExceedMaxLines` (que ya no puede marcar la matrícula, porque ya no tiene
`maxLines`), comprueba en el árbol que el título del detalle trae
`TSTU 144000 2` completo y agrupado, que la etiqueta accesible lo trae
(`find.bySemanticsLabel`, con `ensureSemantics()`), que la Lista muestra los
11 caracteres, y mide con `getRect` si la naviera quedó debajo de la
matrícula. Dos correcciones de mi propio instrumento antes de correrlo: el
API de semántica es `ensureSemantics()` (no `setSemanticsEnabled`), detectado
por `analyze` del banco.

Entorno: `t99_api26`, Android 8.0.0, `emulator-5554`, override
`wm size 1080x2400` y `wm density 480` (3 px/dp → el `Scaffold` midió
**360.0 dp**), `font_scale` 1.0 como base; restituido y cerrado al terminar.
APK con identidad aislada `gt.cmartinez.baystream.t144acc` (sufijo y rótulo
solo en la copia). Los widgets son los reales de `lib/` (`ContainersListView`
y `DetalleContenedor`), con tema de muelle y fuentes empaquetadas; banco de
componentes, no navegación completa de `BayStreamApp`.

Resultado: **salida 0, seis pantallas**. Registro nativo:

```text
T144ACC android-lista-1.0    ancho=360.0 cortados=[] navieraDebajo=null
T144ACC android-detalle-1.0  ancho=360.0 cortados=[] navieraDebajo=false
T144ACC android-lista-1.45   ancho=360.0 cortados=[] navieraDebajo=null
T144ACC android-detalle-1.45 ancho=360.0 cortados=[] navieraDebajo=false
T144ACC android-lista-2.0    ancho=360.0 cortados=[] navieraDebajo=null
T144ACC android-detalle-2.0  ancho=360.0 cortados=[] navieraDebajo=true
```

La matrícula completa y agrupada pasó el `expect` del árbol en las tres
escalas del detalle, y la etiqueta accesible completa; la naviera está en la
misma línea con 1.0 y 1.45, y **baja a la línea siguiente solo con 2.0** —
exactamente lo dicho en la 10.128. Las seis capturas se recuperaron del
almacén privado de la app de prueba y las inspecté visualmente:
`android-detalle-2.0.png` muestra `TSTU 144000 2` completa, sin elipsis, con
la naviera abajo; `android-detalle-1.0.png` la naviera a la derecha en la
misma línea; `android-lista-2.0.png` la matrícula completa en la tarjeta.
Evidencia: `android.log`, `android-ejecucion.json`, `metricas.json`,
`android-dispositivo.json` (resolución, densidad, huellas de las capturas) y
las seis PNG en R2.

### 2.4 Windows (banco `t144acc`, recorrido corto) — PASA

`flutter build windows --release` de la punta con `banco_main.dart` (el de
T-143, con namespace **t144acc** y almacén en
`%TEMP%\t144acc-windows`), proyecto demo `demo-t144acc` contra el emulador
Firebase local (Auth 9399, Firestore 8383, reglas de T-130, sin cuentas;
abiertos con `emulador.py` propio y cerrados al terminar). El ejecutable se
abrió por el Explorador, fuera de paquete (AGENTS.md); **el almacén real de
Windows no se tocó** — la app del banco usó `%TEMP%\t144acc-windows`,
namespace `t144acc`. El almacén usado por la app queda dicho en este párrafo,
como pide AGENTS.md.

Recorrido con `tour.edi` (el sintético de la R1 más el séptimo contenedor
`BYSU 9672095` con espacio, escrito en `entradas/`, sin corpus):

- **Apertura y confirmación**: 7 contenedores, 1 bahía, 84.0 t; perfil
  propuesto; límite de apilamiento «No lo tengo»; «Confirmar y ver el
  plano»; «Confirmado en este equipo: la operación todavía no está en la
  nube». Español en todo lo recorrido.
- **Peligrosas**: detalle de TSTU 144000 2 con «Carga peligrosa · 2
  declaraciones», «IMO 3 · UN 1993», «IMO 8 · UN 1760».
  `windows-detalle-peligrosas.png`.
- **Destino final**: fila «Destino final: PA - DESTINO SINTETICO» en el mismo
  detalle, solo para el contenedor con LOC+83.
- **DIM**: plano con 2 celdas «Fuera de medida» y leyenda «OOG, 2»; detalle de
  TSTU 144003 9 con «Sobredimensionado: Frente 31 cm · Atrás 12 cm ·
  Izquierda 7 cm · Derecha 9 cm · Alto 19 cm». `windows-detalle-dim.png`.
- **Avisos**: en la Lista, el resumen trae «Códigos de puerto que no son
  UN/LOCODE: 1 contenedor · revisa esos puertos con la agencia» y «Medidas DIM
  revisadas: 1 contenedor · revisa esas medidas antes de estibar»; el detalle
  del primero trae las dos causas: «TSTU1440044: LOC+9 «GT-PB»: no tiene la
  forma de un UN/LOCODE (2 letras de país y 3 de lugar); LOC+11 «ZZABC»: el
  país ZZ no existe en ISO 3166-1». `windows-lista-avisos.png`,
  `windows-aviso-locode.png`.
- **Búsqueda**: «bysu 967» devuelve exactamente BYSU9672095; el detalle muestra
  «BYSU 967209 5» entera. `windows-detalle-bysu.png`.
- **BAPLIE de salida** (punto DIM de salida): la página de salida con 1
  contenedor a bordo (TSTU1440044, de paso); guardada como
  `R2/salida-tour.edi`. El grupo del contenedor sale **byte a byte idéntico**
  al de la entrada, incluidos los cinco `DIM+5..9+INH:…`; lo único nuevo es el
  encabezado generado (`UNB/UNH/BGM` de salida). Los DIM CMT no salen porque su
  contenedor sigue pendiente de carga, como dice la propia página.
- Persistencia: al reabrir la app, «BUQUE SINTETICO · VACC144» aparece en
  Recientes con su escala.

### 2.5 A06 y la operación local — PASA

`CORPUS_A06.edi` (fuera del repositorio) se abrió en el banco de Windows,
namespace `t144acc`, sin tocar el almacén real ni la nube real (sin sesión:
«Solo este dispositivo»):

- **717 contenedores, 27 bahías, 10766.9 t**; BUQUE ECO · VIAJE004A; escala
  propuesta **GTPBR**; el resumen de la escala ya no da 0/0/0 («0 se
  descargan · 363 se cargan · 354 de paso» — los puertos LOC+6/LOC+12 de la
  1.5 se leen). `windows-a06-carga-registrada.png` (captura de la carga).
- Las matrículas quedaron normalizadas; en pantalla se ven agrupadas («JMRU
  444685 5») y el dato guardado no tiene espacios.
- **Carga registrada**: modo Carga, contenedor DEMU 502633 2 (002-07-88):
  «Carga registrada · DEMU5026332», «Cargado, Muelle, DEMU 502633 2 ·
  002-07-88, ahora», «Carga: 362 pendientes». La matrícula con espacio del
  archivo pasa `validate()` normalizada.
- **Descarga registrada**: la escala GTPBR no trae descargas propuestas y el
  producto solo ofrece el modo Descarga cuando las hay (`offersDischarge`),
  así que la descarga se registró reabriendo A06 desde el archivo y
  confirmando la escala **COCTG** (463 por bajar): modo Descarga, toque sobre
  JMRU 444685 5 (002-01-04): «Descargado · JMRU4446855 · 002-01-04», «1 de
  463», «Bajado · Muelle … ahora». `windows-a06-descarga-registrada.png`.
  Los dos movimientos quedaron en la bitácora local del namespace `t144acc`;
  **nada salió a la nube real** (emulador demo, sin sesión).
- Nota del instrumento: el banco de la 1.0.0 se cubre en 2.6; el detalle
  «En COCTG: por descargar» y los mensajes de la sección de descarga coinciden
  con el comportamiento diseñado (T-75/T-107), no son hallazgo.

### 2.6 Vuelta real a la 1.0.0 — PASA

El código de v1.0.0 que Codex extrajo sigue en
`C:\Users\Giova\AppData\Local\Temp\t144acc-v100-20261111-235545` (su
`v100.tar`, 245 archivos). Lo extraje a `%TEMP%\t144acc-v100-ejecucion`,
verifiqué contra el tag `v1.0.0` que el contenido coincide (ignorando fin de
línea: `vessel_voyage.dart`, `pubspec.yaml`, `app.dart`, `sync_engine.dart`
idénticos), le agregué `windows/` del mismo tag y **no toqué `lib/`**. Dos
instrumentos propios:

- **Sonda de lectura** (`test/v100_lectura_test.dart`, fuera del paquete
  entregado): con el repositorio Hive real de la 1.0.0 sobre el almacén
  `%TEMP%\t144acc-windows`, namespace `t144acc`: `getAllVoyages` **no lanza**
  y trae **4 viajes** (la lista de viajes no se rompe); el tour trae sus 7
  contenedores con BYSU9672095 normalizada; los avisos nuevos (UN/LOCODE y
  DIM) guardados por la versión nueva no la rompen — van en `extraReadNotices`
  y la 1.0.0 los ignora (10.123, decisión 3). **1/1, salida 0.** |
  `v100-sonda.log`, `v100-sonda-resumen.json`.
- **App visible**: la 1.0.0 compilada con su banco (`banco_v100.dart`,
  almacén igual, Firebase [DEFAULT] contra el emulador demo —la 1.0.0
  construye `VesselRepositoryImpl` con `FirebaseFirestore.instance` sin
  condicional, así que su banco necesita Firebase inicializado como el de la
  publicada; la primera versión de mi banco iba sin Firebase y por eso el
  cálculo de pendientes daba «error interno»: corregí **mi instrumento**, no
  el producto) abre «Recientes» con los 4 viajes guardados por la versión
  nueva y abre el tour **sin error**, con sus pendientes de carga calculados
  (carga: cub. 6) y el plano completo.
  `windows-v100-tour.png`.

El hallazgo técnico del primer intento quedó como registro del instrumento
(`v100-pendientes*.log`): el stack señalaba el `Firebase.initializeApp`
ausente de mi banco, no un defecto de T-144 ni de la 1.0.0.

### 2.7 Chrome (perfil nuevo, recorrido corto) — PASA

`flutter build web --release --no-web-resources-cdn` del banco, servido por un
`http.server` local (127.0.0.1:8443), cerrado al terminar. Se usaron dos
navegadores, ambos sin el perfil personal y con la ventana visible (AGENTS.md):
el Chrome propio del banco (perfil nuevo en `%TEMP%\t144acc-web\perfil1`) y el
navegador gestionado de ZCode (perfil propio de la herramienta), que fue donde
el recorrido terminó.

- La interfaz, **100 % en español** en todo lo recorrido.
- **Apertura**: `tour.edi` abierto; plano de Bahía 02 con las 7 celdas
  coloreadas; «Plano sin confirmar; perfil propuesto desde el archivo. Escala
  propuesta GTSTC.»; confirmado con «No lo tengo»; «Confirmado»; «Archivo
  "tour.edi" cargado correctamente». `web-plano-confirmado.png`.
- **Peligrosas**: detalle de TSTU 144000 2 con «Carga peligrosa · 2
  declaraciones». `web-detalle-peligrosas.png` / `web-detalle-peligrosas2.png`.
- **Destino final**: «PA - DESTINO SINTETICO» en el mismo detalle.
- **DIM**: detalle de TSTU 144003 9 con «Sobredimensionado: Frente 31 cm ·
  Atrás 12 cm · Izquierda 7 cm · Derecha 9 cm · Alto 19 cm».
  `web-detalle-dim.png`.
- **Avisos**: los dos del resumen en la Lista; el detalle del UN/LOCODE con
  las dos causas («TSTU1440044: LOC+9 «GT-PB»: …; LOC+11 «ZZABC»: el país ZZ
  no existe…»). `web-lista-avisos.png`, `web-aviso-locode.png`.
- **Búsqueda**: «bysu 967» devuelve BYSU9672095 (LINEA, POD: PAMIT); el
  detalle muestra «BYSU 967209 5» entera. `web-busqueda-bysu.png`,
  `web-detalle-bysu.png`.

Nota del instrumento: el chooser de archivos de Flutter web no se dejó
manejar por los clics sintéticos de CDP ni por el clic UIA directo al canvas;
funcionó con el clic real del navegador gestionado (eventos de puntero con
activación de usuario) más el diálogo nativo manejado por UIA. Herramientas
propias en R2: `cdp_eval.py`, `cdp_clic.py`, `cdp_abrir.py`,
`cdp_esperar_chooser.py`, `cdp_archivo.py` (este último con dos errores de
sintaxis corregidos antes de servir). El Chrome del banco y el servidor se
cerraron al terminar.

### 2.8 Honor — no disponible

Carlos no lo prestó para este encargo. Queda en la **lista de comprobación de
la versión**, conforme a la 10.126 y a la R1.

## 3. Hallazgos

**Ninguno nuevo P1, P2 o P3.** O-144-1 (el resaltado de «BYSU 967») sigue
conocida y no cuenta (el resultado aparece; no se resalta).

Lo que apareció durante el trabajo fue de **instrumental**, corregido en mi
copia y anotado donde tocó: el registrador de la R1 (`run.py`) no lanzaba
Flutter con cierto orden de argumentos; el primer banco de la 1.0.0 no
inicializaba Firebase (la 1.0.0 lo necesita para construir su repositorio de
nube) y el aviso «error interno» de pendientes era del banco, no del
producto; la sonda Android extendida usó un API de semántica inexistente y lo
corrigió el `analyze`; y el chooser de archivos de la web exigió el clic real
del navegador gestionado en lugar de los sintéticos. Ninguno es del producto.

La observación de entorno del `analyze` no determinista (2.1.1) tampoco es de
T-144: dos pruebas de T-112/T-121 que analizan limpio en una corrida dan
avisos `info` en otra, según el lote de archivos. Queda registrada con su
bisección para quien la necesite; no bloquea ni pide cambio.

## 4. Lo que no se pudo y por qué

- **El Honor**: no disponible; pasa a la lista de la versión (10.126).
- **El fuzzing**: exento por el encargo (el lector no cambió).
- **El recorrido web en el Chrome del banco quedó a mitad del flujo de
  apertura**: el chooser de archivos de Flutter web no aceptó los clic
  sintéticos; el mismo recorrido se completó en el navegador gestionado con
  clic real y diálogo nativo. La web es el mismo binario compilado del mismo
  banco; la diferencia fue solo de instrumentación.

## 5. Horas

Horario de Guatemala; no son mediciones H5.

| Actividad | Inicio | Fin |
|---|---|---|
| Lecturas y preparación (con la detención del paso 0 del 15-nov) | 15-nov 17:55 | 15-nov 18:15 |
| Paso 0: copia, `pub get`, `analyze` (con la bisección del no determinismo), suite 2221 | 15-nov 18:15 | 15-nov 18:30 |
| Sondas funcional y de búsqueda | 15-nov 18:31 | 15-nov 18:33 |
| Banco Android extendido (escritura, identidad, build, prueba, capturas, restitución) | 15-nov 18:34 | 15-nov 18:41 |
| Build Windows del banco + emulador demo | 15-nov 18:43 | 15-nov 18:50 |
| Tour Windows (tour.edi: confirmación, peligrosas, destino, DIM, avisos, búsqueda, salida DIM) | 15-nov 18:51 | 15-nov 19:35 |
| A06 (apertura, verificación, carga, descarga COCTG, capturas) | 15-nov 19:36 | 15-nov 20:20 |
| Vuelta a la 1.0.0 (extracción, verificación del tar, sonda, banco con y sin Firebase, app visible) | 15-nov 20:21 | 15-nov 21:00 |
| Chrome: build web, servidor, chooser (con las vías CDP descartadas), recorrido completo | 15-nov 21:01 | 16-nov 00:30 |
| Cierre: integridad, informe | 16-nov 00:31 | 16-nov 00:55 |

Total ≈ **5 h**, de las cuales ≈ **1 h** fue espera de compilaciones y
esperas del emulador.

## 6. Archivos y Git para Carlos

**Único archivo versionable creado por GLM: `docs/t144/aceptacion-glm.md`**
(este informe). No se versiona nada más: toda la evidencia y los instrumentos
propios quedan bajo `build/t144/aceptacion/reaceptacion2/`, ignorado por
`/build/`, y no se propone forzar su incorporación.

**Código de producto, pruebas permanentes, `tool/`, `DESIGN.md`,
`pubspec.yaml` y `pubspec.lock`: sin cambios**, verificado por la integridad
final (origen 839/839). No se tocaron los congelados, `lib/main.dart`,
opciones Firebase ni `.claude/settings.local.json`. La carpeta del informe de
Codex (`docs/t144/aceptacion-codex.md`) no se tocó. En TEMP quedan el banco y
la sonda de la 1.0.0 (`t144acc-v100-ejecucion`) y el almacén del banco
(`t144acc-windows`), ambos fuera del repositorio.

Desde `qa-r4`, lo ejecuta Carlos:

```powershell
Set-Location C:\Proyectos\baystream-qa-r4
git add -- docs/t144/aceptacion-glm.md
git commit -m "Sprint 4: segunda reaceptacion de T-144"
git push origin HEAD:sprint-4
```

## 7. Tres líneas

1. **PASA**: paso 0 con suite 2221/2221 sin omitidas en una corrida;
   T144-ACC-02 cerrado en Android real (360 dp, letra 1.0/1.45/2.0, matrícula
   entera y naviera baja solo a 2.0), y la sonda funcional de la R1 vuelve a
   pasar sobre la punta nueva.
2. A06 (717 contenedores, puertos de la 1.5, GTPBR), el DIM completo
   (insignia, línea de medidas y BAPLIE de salida byte a byte idéntico), la
   vuelta real a la 1.0.0 (lista de 4 viajes entera y el tour abre sin error)
   y los recorridos de Windows y Chrome pasan, todo en español.
3. Sin hallazgos nuevos; solo observaciones de instrumental y del entorno
   (`analyze` no determinista en pruebas de T-112/T-121), documentadas con su
   evidencia; el Honor queda en la lista de la versión.

## 8. Mensaje para Yov

> Yov, reaceptación 2 de T-144 **PASA** sobre `d32a6dd` en qa-r4, informe en
> `docs/t144/aceptacion-glm.md`. Paso 0: copia de 839 archivos, suite
> 2221/2221 sin omitidas en una corrida; el `analyze` dio 3 infos no
> deterministas en `t112`/`t121` (bisección documentada, ninguno de T-144).
> ACC-02 cerrado: Android real a 360 dp, banco extendido de la R1 con árbol y
> etiqueta accesible — matrícula entera en las tres escalas y la naviera baja
> solo a 2.0; capturas inspeccionadas. Sonda funcional de la R1 1/1 y sonda
> de búsqueda 4/4 sobre la punta nueva. Windows: tour con peligrosas dobles,
> destino final, DIM (insignia, línea de medidas y BAPLIE de salida byte a
> byte idéntico), avisos con causa y acción, «bysu 967» y matrícula entera.
> A06: 717 contenedores, puertos de la 1.5, GTPBR sin 0/0/0, carga de
> DEMU5026332 y descarga de JMRU4446855 registradas en el namespace t144acc
> local (nada en la nube real). Vuelta a la 1.0.0: su repositorio lee 4
> viajes sin romperse y la app 1.0.0 abre el tour con avisos nuevos sin
> error. Chrome: mismo recorrido completo en el navegador gestionado, 100 %
> español. Honor a la lista de la versión. Sin hallazgos nuevos; dos notas de
> instrumento (banco 1.0.0 necesita Firebase como el de la publicada; el
> chooser web pide clic real) y la observación del `analyze`, todo en el
> informe con evidencia en `build/t144/aceptacion/reaceptacion2/`.
