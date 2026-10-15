# T-103 · Leer la 1.5 (SMDG15) con un aviso visible

Timonel · 15-oct-2026 · rama `sprint-3`, sobre `bd09a4d` (decisión 10.41).
Estado: **entregada, pendiente de la aceptación cruzada de Codex** (10.41).

## Cambio

- **El lector acepta exactamente `BAPLIE:1:911:UN:SMDG15`** además de SMDG20, 21 y
  22, con las mismas condiciones de cabecera que T-86 (un solo UNH, antes de la
  carga, cinco componentes). Cualquier otra 1.x, la 3.x, las variantes de la 1.5
  con otra versión o liberación (`BAPLIE:D:95B:UN:SMDG15`, `BAPLIE:1:912:UN:SMDG15`)
  y lo que no tiene UNH se rechazan **con el mismo mensaje de T-86**, sin cambiarlo.
- **El aviso** «Versión 1.5, leída con las reglas de 2.x; revisa pesos y peligrosas»
  va arriba de la tarjeta de resumen del viaje (pestaña Lista, la que abre por
  defecto), fijo, con `errorContainer` del tema. No es un SnackBar.
  - **Sale de los metadatos que ya se guardaban**: el UNH de la 1.5 trae versión `1`
    (`BaplieMetadata.messageVersion`), y el lector solo admite versión 1 en la 1.5.
    `BaplieMetadata.readWithV2Rules` lo deriva. **No hay campo nuevo ni cambio de
    esquema**: el JSON de las 2.x no cambia, y al reabrir desde Recientes el viaje
    trae su `messageVersion` y el aviso sigue ahí. Un A06 guardado antes de T-86 en
    un almacén también lo muestra.
- **La salida de T-82 se niega desde una fuente 1.5.** La página de salida revisa las
  fuentes BAPLIE de la operación —plan de carga **y** llegada, porque la llegada
  respalda segmentos de los que siguen a bordo— antes de llamar al escritor, y dice:

  > No se genera el BAPLIE de salida: «A06.edi» es versión 1.5 (SMDG15) y se leyó
  > con las reglas de 2.x. Escribir la salida con esas reglas no sería fiel a lo que
  > llegó. Importa el plano en SMDG20, SMDG21 o SMDG22.

  Sin botón de guardar. **El escritor de T-82 no se tocó** (mismo SHA): ya rechazaba
  la 1.5 por su cuenta; ahora la acción lo explica antes.

Rutas de `lib/` (cuatro, cambios quirúrgicos): el lector (+5/−3), la entidad del
viaje (+18: el identificador, `declaresSmdg15` y `readWithV2Rules`), la página de
salida (+16) y la tarjeta de resumen (+33).

## A06 antes y después, tomado de la historia

**Antes de T-86 (`1b1be4b^`).** Dos fuentes, las dos de la historia y no de memoria:

1. **Los informes de `1b1be4b^`**, leídos con `git show 1b1be4b^:<ruta>`:

   | Cifra | Valor | Dónde lo dice |
   |---|---:|---|
   | Contenedores | 717 | `BLOQUE7A`, `BLOQUE7B`, `T37`, `T44`, `T55` |
   | Bahías (con las invisibles de 40 pies) | 27 (21 + 6) | `T37` (717/27), `HALLAZGOS-PLANO-REAL` |
   | 20 pies / 40-45 pies | 190 / 527 | `BLOQUE7B` |
   | Reefer por ISO / con `TMP` | 91 / 73 | `BLOQUE7B`, `HALLAZGOS-PLANO-REAL` |
   | DGS / unidades peligrosas | 1 / 1 | `BLOQUE7A` (total del corpus: 34 DGS en 30 unidades) |
   | Clave del perfil | `imo:9000039` | `SPRINT-2.md`, `BLOQUE2` |
   | `LOC+61` | enmascarado (nulo) | `tool/t68_corpus_test.dart` de `1b1be4b^` |
   | Fila 00: cubierta / bodega, celdas | 33 / 0, 74 | `T55` |
   | Huella del archivo | `84B8C708…E3F1A6` | `T55` |

2. **El lector de `1b1be4b^` ejecutado.** Se extrajo con `git show` a un archivo
   temporal de `tool/`, se leyó A06 y se guardó el viaje completo, sin UUID, en
   `%TEMP%\t103_a06_antes.json` (SHA-256 `8030C09A…1FAF8C`). El temporal se borró
   después; no queda en el árbol. Dio **717 contenedores, 21 bahías leídas,
   0 reservas, 10 766 933.00 kg (WT = efectivo), 1 DGS en 1 unidad, 190 de 20 pies,
   91 reefer por ISO, 73 con `TMP`, BUQUE ECO, VIAJE004A, LOC+5 GTPBR**. Entre
   `1b1be4b^` y HEAD, las entidades que arma el lector no cambiaron (solo tapas,
   movimientos, operación, perfil y tema), y el lector solo sumó el control de UNH.

**Después de T-103.** `tool/t103_corpus_test.dart` exige cada cifra de la tabla y,
con `--dart-define=T103_A06_BEFORE=…`, el **viaje completo igual al del lector de
`1b1be4b^`, salvo los UUID: sin diferencias**. Con la geometría propuesta, 27 bahías.
El archivo del corpus conserva la huella de T-55 (`84B8C708…E3F1A6`).

## Las nueve 2.x, idénticas

Antes de tocar el lector, `tool/t103_baseline.dart` guardó la referencia de las
nueve fuentes en `%TEMP%\t103_baseline.json` (5 589 199 bytes, SHA-256
`326E702B1F20B1AFD6C312A5FA3842A5D0CC59ED522FDEE9414526FB3499F37B`): el
`toJson()` completo de cada viaje, sin UUID —bahías, contenedores, reservas y
metadatos—, como en T-86. Después del cambio, `tool/t86_corpus_test.dart` con
`--dart-define=T86_BASELINE=%TEMP%\t103_baseline.json`:

| Fuente | Contenedores | Reservas | Peso efectivo, kg | Referencia completa |
|---|---:|---:|---:|---|
| A01 | 977 | 0 | 8 366 089.00 | sin diferencias |
| A02 | 806 | 0 | 10 719 976.00 | sin diferencias |
| A03 | 369 | 0 | 7 419 486.99 | sin diferencias |
| A03v_VGM | 369 | 0 | 7 419 486.99 | sin diferencias |
| A04 | 979 | 0 | 12 267 702.00 | sin diferencias |
| A05 | 736 | 0 | 11 210 489.02 | sin diferencias |
| A07 | 398 | 0 | 6 940 578.00 | sin diferencias |
| A08 | 405 | 55 | 6 899 700.00 | sin diferencias |
| A08v_VGM | 405 | 55 | 6 899 700.00 | sin diferencias |

**Nueve de nueve, idénticas.** Además, ninguna de las nueve lleva la marca del aviso.

## Pruebas y corpus adaptados

Ninguna prueba se borró ni se marcó `skip`.

**Lo que exigía el rechazo de A06 ahora exige la lectura con aviso.** El apoyo
`requireA06Rejection` de `tool/t86_corpus_support.dart` pasa a ser
`readA06WithNotice`: lee A06, comprueba que el UNH es la 1.5, que el viaje lleva la
marca del aviso y que da 717 contenedores. Cada ruta vuelve a lo que hacía en
`1b1be4b^` (cotejado con `git diff 1b1be4b^`), salvo esa comprobación:

- `tool/block2_corpus_test.dart`: A06 vuelve a la lista y el homónimo A05/A06 se
  compara con el TDT real de A06, no con un buque sintético.
- `tool/block7_checks.dart`: el bloque 7 vuelve a **34 DGS en 30 unidades**: A06
  aportaba una declaración en una unidad.
- `tool/t68_corpus_test.dart`: A04 y A06 con `LOC+61` enmascarado, y A06 con aviso.
- `tool/t69_corpus_test.dart`: A06 vuelve a «cero reservas».
- `tool/t82_corpus_test.dart`: A06 se lee, y el escritor la sigue negando
  (`StateError`), como en `1b1be4b^`.
- `tool/t86_corpus_test.dart`: A06 deja de ser el espécimen del rechazo y se lee con
  aviso; las nueve 2.x comprueban además que no llevan aviso.
- Auxiliares `block7b_corpus`, `t44_corpus_parse`, `t55_fila_central`,
  `t55_tabla_segregacion`, `t55_tomas_paridad` y `t59_bahias_tomas`: vuelven a leer
  A06. `t55_tomas_paridad` recupera los cruces de los dos BUQUE ECO
  (`ECO_A05_contra_A06` y al revés), que T-86 había sustituido por A05/A01.
- `test/profile_loading_test.dart`: A05/A06 vuelven a preguntar por la identidad del
  homónimo, con A06 en su cabecera 1.5; al publicar, el viaje de A06 lleva el aviso.
- `test/vessel_identity_test.dart`: el TDT de A06 va en su cabecera real 1.5.

**Las pruebas de rechazo pasan a una 1.x sintética distinta de la 1.5,
`BAPLIE:1:911:UN:SMDG10`:** `test/t86_baplie_version_test.dart` (repositorio, lista
de identificadores y aviso a 360 dp) y `test/t89_file_input_test.dart`. La lista de
T-86 suma dos variantes que deben seguir rechazándose: `BAPLIE:D:95B:UN:SMDG15` y
`BAPLIE:1:912:UN:SMDG15`.

**Nuevas, `test/t103_smdg15_test.dart` (10):** la 1.5 se lee completa y da lo mismo
que su gemela 2.x; solo la cabecera exacta se reconoce como 1.5; la 1.x sintética,
`t86_smdg31` y `t86_sin_unh` se rechazan con el mensaje de T-86 y conservan el viaje
sin abrir el almacén; publicar una 1.5 y reabrirla desde Recientes, en un almacén Hive
real en temporal, conserva el aviso; el resumen a 360 dp en claro y oscuro muestra el
aviso solo en la 1.5; y la salida de T-82 se niega con una 1.5 como plan de carga o
como llegada.

**Un matiz del rechazo sin UNH.** El lector lanza para `t86_sin_unh` el mensaje de
T-86 («sin UNH/S009 reconocible»), pero desde T-89 la pantalla lo traduce a «Este
archivo no parece un BAPLIE…». T-103 no cambia ninguno de los dos, y la prueba
exige los dos.

## Validaciones

| Validación | Resultado | Registro en `%TEMP%` |
|---|---|---|
| Suite completa | **697/697** (piso 685 + 12 nuevas: 10 de T-103 y 2 variantes en T-86), dos veces | `t103-suite.log`, `t103-suite-final.log` |
| `flutter analyze` | **0 incidencias**, sin `// ignore:` | — |
| Corpus completo, `tool/*corpus*test.dart` | **118/118 en 32 archivos** (los 116/116 en 31 de T-104 más los 2 de `t103_corpus_test.dart`), 36 s | `t103-corpus-1.log` |
| Referencias (9 de 2.x y A06 completa) | 12/12, sin diferencias | `t103-referencias.log` |
| Auxiliares | 6/6 con código 0; A06: 717/27/190/527/91 y fila 00 33/0/74, como en `1b1be4b^` | `t103-<auxiliar>.json` |

**Lo que no cambia, SHA-256 iguales a HEAD** (`git diff --stat --ignore-cr-at-eol`
sobre estas rutas, vacío):

| Archivo | SHA-256 |
|---|---|
| `firestore.rules` | `0112510984D9A16364F9752E243999C47306E0BCF82766E380DB380E8FE8E60A` |
| Escritor de T-82 | `05EE91981499215E9981094EE3C3230C00AB98C54F4793B8750880D23E656147` (el mismo que registró T-86) |
| `lib/main.dart` | `C5189B1D8711837A05C68306D424C9FDBCC977BA3BBB6C823089FFE4CA5339D5` (el mismo que T-86) |
| `pubspec.yaml` | `CDE9A4B132CB83898A9D1909898B89BD9380990CA8225FDFC776C342947DA716` |
| `pubspec.lock` | `577D742E04143131BC02A1BBB6C246D298C90396E08F6C9DFE393637A2617F53` |
| `lib/latency_test_screen.dart` | `599310DB13A713E82FC0D6A411BE2D7757CBC2B803D772C1CAA16C471725CDFF` |
| `lib/c3_reconciliation_screen.dart` | `3AF478364A8C5386E1F921E0142DC4F847594BECA00B6743563CB09A8A4112A5` |

El SHA de `firestore.rules` no es el que T-86 anotó (`21894B7F…`), pero el archivo
es idéntico al de HEAD: T-103 no lo tocó. **`pubspec.yaml` y `pubspec.lock` no
cambian; no hay dependencias nuevas.**

## Clientes

Banco `tool/t103_main.dart`, compilado en una copia de `%TEMP%`
(`baystream-t103-clientes`, sin `docs`, `build`, `.dart_tool` ni
`android/key.properties`). **Solo en esa copia** se agregaron como assets A06 y las
tres fuentes de rechazo (la 1.x sintética, `t86_smdg31` y `t86_sin_unh`) y se cambió
el applicationId a `.t103`. Modo sin cuenta con sesión local: **nada sube a la nube**
y no hay movimientos. Las tres compilaciones llevan
`--dart-define-from-file=C:\Proyectos\baystream-privado\firebase-prod.json`, sin abrir
ese archivo. El banco entrega el asset al notifier real; el aviso, la salida, los
rechazos y Recientes son las pantallas del producto.

**Pasa en los tres clientes:**

| Cliente | A06 | Salida T-82 | 1.x sintética · 3.x · sin UNH | Recientes |
|---|---|---|---|---|
| Web, navegador integrado de la app (Chromium), visible | 717 · 27 · 10 766.9 t, aviso, Bay Plan dibujado | Negada con el mensaje, sin botón de guardar | Los tres avisos; A06 sigue abierta con su aviso | Aviso al reabrir, **también tras recargar la página** |
| Windows, `t103acc`, almacén real | Mismas cifras y aviso | Negada | Los tres; conserva A06 | Aviso al reabrir **tras cerrar el proceso y relanzar** |
| Honor `.t103`, 360×800 dp | Mismas cifras y aviso, a letra 2.0 | Negada | Los tres a letra 1.0; la 1.x también a 2.0 | Aviso al reabrir tras `force-stop` y relanzar |

- **Web.** `http://127.0.0.1:8103`, servido con `python -m http.server` desde
  `build/web` de la copia, namespace `t103acc` en el almacén de ese origen. Se usó el
  navegador integrado de la app (el que este entorno usa por defecto), no la
  extensión de Chrome; mientras el panel estuvo oculto Flutter no dibujaba, y Carlos
  lo mostró. El servidor (PID 4240) y la pestaña se cerraron al terminar.
- **Windows.** Abierto con `Start-Process explorer.exe -ArgumentList <exe>`, PID
  **31560**, y relanzado igual, PID **26408**; los dos se cerraron por PID y no queda
  ningún `baystream.exe`. **El almacén usado fue el real**,
  `C:\Users\Giova\AppData\Local\BayStream`. Huella tomada **fuera del paquete**, con un
  `.bat` lanzado por `explorer.exe` que anota su cadena
  (`powershell ← cmd.exe ← explorer.exe`): **316 archivos antes y 328 después; lo
  único nuevo son los 12 archivos `t103acc_*`**, y los 316 previos conservan su SHA.
  `t103acc_movements.hive` queda en **0 bytes**: sin movimientos.
- **Honor.** NAA LX3, 720×1600 px a densidad 320 = **360×800 dp**. Se instaló solo
  `gt.cmartinez.baystream.t103` (APK `58FA41AF…990393`) y se cerró con `force-stop`.
  Volcados con `adb exec-out uiautomator dump /dev/tty`, en memoria y con correos y UID
  ocultos antes de mostrarlos; en modo sin cuenta no apareció ninguno. No apareció
  ningún diálogo del sistema.
  - **La letra del Honor estaba en 2.0** (la dejó la aceptación de T-104). A06, la
    salida, Recientes y la 1.x se probaron a 2.0. Para los otros dos rechazos, **con
    permiso de Carlos**, se bajó a 1.0 y **se devolvió a 2.0** al terminar
    (`settings get system font_scale` = 2.0).
  - **Un error mío, declarado:** dije que a 2.0 «Cargar archivo BAPLIE» quedaba fuera
    de la barra. No era así: la barra se desplaza en horizontal y la acción está a un
    deslizamiento, también a 1.0. El cambio de letra no hacía falta.

Evidencia en `%TEMP%\baystream-t103-evidencia`: `web-*` (8), `windows-*` (6),
`honor-*` (8), y `huella-antes.txt` / `huella-despues.txt` con su `.bat` y `.ps1`.

Compilaciones de la copia: Web **67 s**, Windows **252 s** y APK **85 s**. La primera
de Windows cayó en 9 s porque la copia arrastró los enlaces de
`windows\flutter\ephemeral\.plugin_symlinks`; se borró esa carpeta **solo en la copia**
y la segunda terminó. Avisos conocidos: la fuente CupertinoIcons en la Web y las
notas de APIs obsoletas de plugins en Android.

## Observaciones fuera del alcance

- **La pantalla vacía dice «Contenido compatible: BAPLIE 2.x.»** Ahora la 1.5 también
  se lee, con aviso. No se cambió: la ficha no lo pide. Sugerencia para Yov o una tarea
  de textos (T-56): «BAPLIE 2.x; la 1.5, con aviso».
- **A06 en GTPBR da «0 se descargan · 0 se cargan · 0 de paso».** A06 no trae `LOC+9`
  en ningún contenedor (ya registrado en `HALLAZGOS-PLANO-REAL`), así que la escala no
  los clasifica. Pasaba igual antes de T-86; T-103 no lo toca.
- **El chip «Viaje: VIAJE004A» se sale de su fondo a letra 2.0** en el Honor: es la
  observación que 10.41 ya asignó a T-56.

## Archivos

Rutas propias de T-103 (26):

- `lib/features/vessel/data/services/baplie_parser_service.dart`
- `lib/features/vessel/domain/entities/vessel_voyage.dart`
- `lib/features/vessel/presentation/pages/departure_baplie_page.dart`
- `lib/features/vessel/presentation/widgets/voyage_summary_card.dart`
- `test/profile_loading_test.dart`
- `test/t86_baplie_version_test.dart`
- `test/t89_file_input_test.dart`
- `test/vessel_identity_test.dart`
- `test/t103_smdg15_test.dart` (nueva)
- `tool/block2_corpus_test.dart`
- `tool/block7_checks.dart`
- `tool/block7b_corpus.dart`
- `tool/t44_corpus_parse.dart`
- `tool/t55_fila_central.dart`
- `tool/t55_tabla_segregacion.dart`
- `tool/t55_tomas_paridad.dart`
- `tool/t59_bahias_tomas.dart`
- `tool/t68_corpus_test.dart`
- `tool/t69_corpus_test.dart`
- `tool/t82_corpus_test.dart`
- `tool/t86_corpus_support.dart`
- `tool/t86_corpus_test.dart`
- `tool/t103_baseline.dart` (nueva)
- `tool/t103_corpus_test.dart` (nueva)
- `tool/t103_main.dart` (nueva)
- `docs/T103-RESULTADOS.md` (este informe)

Sin cambios en `lib/main.dart`, los congelados de H5, `pubspec.*`, las reglas, el
escritor de T-82, `SPRINT-3.md`, `AGENTS.md`, `CLAUDE.md` ni `README.md`. Las rutas de
T-93 que corrige Codex (`tool/t93_msix.ps1`, `test/t93_msix_config_test.dart`,
`docs/T93-CORRECCION-RESULTADOS.md`) no son de esta entrega. Nada del corpus entra al
árbol: las fuentes de A06 vivieron solo en la copia de `%TEMP%`. Git: solo `log`,
`show`, `diff --stat --ignore-cr-at-eol` y `ls-files`.

## Horas

Inicio 11:20:55, cierre del informe 12:05 (15-oct, Guatemala): **≈ 0.75 h frente a
1.0 h estimada**. Incluye lecturas, implementación, las tres compilaciones, las dos
preguntas a Carlos y la aceptación en los tres clientes.
