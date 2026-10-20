# T-112 · La interfaz en español, Material 3 sin excepciones y los mensajes con causa y acción

Timonel · 20-oct-2026 · Base: `cdab56b` (10.93) · **Entregada para aceptación de Codex, sin commit.**

La ficha está en la Ola 5 de `SPRINT-3.md` y la decisión es la 10.93. La fuente son mis censos de
T-98 (`docs/T98-CENSOS-RESULTADOS.md`). Los identificadores M001…M218 e I01…I52 son los de ese censo.

## Resultado en tres líneas

1. **Idioma: 100 %.** De 1790 cadenas visibles de `lib/`, 1657 están en español y 133 no tienen
   idioma (siglas, nombres, unidades). Ninguna queda en inglés ni mezclada. Los 20 textos que pone
   Flutter («Atrás», el selector de fecha, copiar y pegar…) salen en español.
2. **Material 3: 237 controles, 0 excepciones.** Los resultados del buscador toman sus colores de
   `colorScheme`, los mismos que usan las celdas y la leyenda del plano.
3. **Mensajes: 218 de 218 con causa y acción explícitas, y 12 de 12 errores de lectura con su
   segmento.** Cambiaron 173 textos. Los otros 45 ya cumplían. Los seis sitios que mostraban el
   `toString()` de una excepción ahora dan un mensaje en español, y el detalle técnico va al registro.

### Terminada cuando

| La ficha pide | Resultado |
|---|---|
| Censos repetidos con `tool/t98c_*`: idioma al 100 % | **100 %** en las dos lecturas y los cuatro alcances de T-98: 0 cadenas en inglés o mezcladas (T-98: 52) y los 20 textos de Flutter en español (T-98: 20 en inglés). No queda nada que explicar uno por uno (sección 6) |
| Material 3 sin excepciones | **237 controles, 0 excepciones** (T-98: 1) |
| Mensajes al 100 %, con segmento en los de lectura | **218/218** con causa y acción explícitas (T-98: 49) y **12/12** errores de lectura con su segmento (T-98: 4) |
| Pruebas: 1047 + `test/t112_*`, en verde y sin omitir ninguna | **1063 de 1063** (1047 + 16 nuevas), 0 fallas, 0 omitidas, 83 s. Hay 20 archivos actualizados y 4 nuevos (sección 4) |
| `flutter analyze` en 0 | **0 incidencias**, sin ningún `// ignore:` nuevo |
| Corpus en verde, con datos y formato guardado iguales a HEAD | **36 instrumentos y 157 pruebas en verde.** Los cotejos contra la referencia de HEAD salen iguales: datos, geometría, formato guardado, avisos, bahías, registro y tarjeta (sección 5) |
| Windows, la Web y el Honor (360 dp, letra 1.0 y 1.45), con t112 | **Hecho en los tres**, con el banco `tool/t112_main.dart` y un recorrido automático de la interfaz real. Se revisaron 28 + 28 + 16 capturas: **0 palabras en inglés y 0 errores de Flutter**. Lo que no cabe ya tampoco cabía en HEAD (sección 7) |

**Todas las cifras de este informe salen del árbol final**: analyze, suite, corpus, cotejos, censos
y los tres clientes se corrieron después del último cambio en `lib/`.

## 1. Antes de empezar

- `git log --oneline -3`: arriba está `cdab56b` (10.93).
- Leí la ficha de T-112 y la decisión 10.93.
- En el árbol hay trabajo de Codex sin commit: `docs/T98-RESULTADOS.md` y `tool/t98_*`, incluidos
  `t98_grabar_escritorio.py`, `t98_iab_*`, `t98_primera_honor.py` y el cambio en
  `t98_recuperacion_honor.py`. No los toqué y no van en mi bloque de Git. Tampoco corrí
  `tool/t98_estandares_test.dart`.
- Toda la sesión hubo un `baystream.exe` abierto desde la copia de T-98 de Codex
  (`%TEMP%\t98-b-90dce4b-19oct\…`, PID 5684). No lo cerré ni lo usé. Mis bancos usaron otros
  almacenes, en TEMP.
- Pedí el control del escritorio para el banco de Windows y salió **denegado**. No lo volví a pedir
  ni lo rodeé. Windows se comprobó con un recorrido automático dentro del propio banco (sección 7).

## 2. Qué cambió

### 2.1 El idioma

**a. Los textos de Flutter.** `flutter_localizations`, del SDK, entra en `pubspec.yaml`, como autoriza
10.93. `lib/core/app.dart` declara `locale: Locale('es')`, `supportedLocales: [Locale('es')]` y
`GlobalMaterialLocalizations.delegates`. El lock agrega solo `flutter_localizations` (sdk) e `intl`
0.20.2, que es su dependencia fija.

**b. Los términos del oficio.**

| Hoy | Queda | Dónde |
|---|---|---|
| «Bay 002, Row 01, Tier 82» | «Bahía 002, Fila 01, Nivel 82» | `iso_coordinate_parser.dart` (`displayFormat`: detalle, Lista, reserva, buscador). Igual en `container_slot.dart`, que no tiene uso |
| «BAY 02 (…)», «BAY 02 · tapas…», «Bay 02» | «BAHÍA 02 (…)», «BAHÍA 02 · tapas…», «Bahía 02» | `bay_plan_view.dart` (selector, título de la rejilla, vista sin geometría) |
| «Reefer» / «Reefers» | «Refrigerado» / «Refrigerados» | leyenda del plano, Lista, Estadísticas (3), PDF (2) |
| «Tomas de reefer» | «Tomas de refrigerado» | Parámetros del buque (2), como dice ya Alertas («Toma de refrigerado») |
| «▲ CUBIERTA (DECK)», «▼ BODEGA (HOLD)» | «▲ CUBIERTA», «▼ BODEGA» | rejilla |
| «CUBIERTA (DECK) - Tiers N y superiores», «BODEGA (HOLD) - Tiers inferiores a N» | «CUBIERTA - niveles N y superiores», «BODEGA - niveles inferiores a N» | PDF |
| Pestaña «Bay Plan»; «Abrir bahía N en Bay Plan» | «Plano»; «Abrir bahía N en el plano» | pestaña; accesibilidad y tooltip del perfil |
| «Tip: …» | «Consejo: …» | buscador |
| «…revela los slots que…» | «…revela las posiciones que…» | Parámetros del buque |

**c. «UNKNOWN».** El nuevo `lib/core/utils/voyage_number.dart` define `unknownVoyageNumber = 'UNKNOWN'`
y `voyageNumberLabel()`, que muestra «sin número». La usan los 12 sitios de pantalla que muestran el
número de viaje y los 4 del PDF (título del documento, encabezado, tabla y pie). El lector usa la
misma constante, con el mismo valor. **No cambia lo guardado, la identidad del viaje ni los nombres
de archivo** (`export_service.dart` y `departure_export_repository_impl.dart` siguen usando el
valor).

**d. Identificadores en los mensajes.**
- `loading_baplie` pasa a «el plan de carga (BAPLIE)» (M143) y a «su plan de carga» (M155).
- Los tres códigos de Firebase interpolados (M034, M037, M048) salen de la pantalla: el mensaje
  dice la causa y la acción, y el código va al registro con `debugPrint`.
- La fuente de M050 se nombra en español («plano de llegada», «plan de carga», «listado de la
  agencia») en lugar de `kind.wire`.

**e. El CSV.** Los encabezados ahora están en español y siguen en el mismo orden: `id`, Contenedor,
Tipo ISO, Estado, Posición, Peso bruto (kg), Peso VGM (kg), Tara (kg), Puerto de carga, Puerto de
descarga, Destino final, Operador, Peligroso, Clase IMDG, Número ONU, Refrigerado, Temperatura,
Unidad de temperatura, Sobredimensionado, Sobrealtura (cm), Sobreancho izquierdo (cm), Sobreancho
derecho (cm), Sobrelongitud frontal (cm) y Sobrelongitud trasera (cm). Las unidades son las que
documenta `ContainerUnit`. Los valores salen en español: «lleno», «vacío», «desconocido», «sí» y
«no». El JSON no cambia: sigue siendo `VesselVoyage.toJson`.

### 2.2 Material 3

`container_search_delegate.dart`: el avatar de cada resultado usa `errorContainer` (peligrosa),
`primaryContainer` (refrigerado), `secondaryContainer` (lleno) y `surfaceContainerHighest` (vacío),
cada uno con su color `on*`. Son los mismos colores de las celdas y la leyenda del plano. Cada
categoría conserva además su icono. El texto que coincide con la búsqueda se resalta con
`tertiaryContainer`.

### 2.3 Los mensajes

Cambiaron **173 de los 218** textos:
- los **169** que en T-98 no decían causa y acción explícitas;
- **4** que sí las decían, pero mostraban un identificador (M050, M143) o no nombraban el segmento
  (M024, M180).

Los **45** restantes ya cumplían y no cambian. Cuando el código lo pidió, se cambió:

- **M001 y M006.** `vesselErrorMessage` y `vesselFailureMessage` reciben la operación que falló.
  Los llamadores la nombran en **40 de sus 41 sitios**: «abrir el viaje», «exportar PDF», «guardar
  el tema»… El sitio que falta solo muestra la versión no admitida (M024), que tiene su propio texto.
  - El genérico pasa a «No se pudo {operación} por un error interno de la aplicación; el detalle
    técnico quedó en el registro. Inténtalo de nuevo y, si se repite, reinicia la aplicación.».
  - El del almacén local pasa a «No se pudo {operación}: falló la lectura o la escritura de los
    datos guardados en este dispositivo…».
- **M004.** Mi censo suponía que el fallo traía `segment` y `lineNumber`, y no es así: en este
  camino llegaba sin los dos. **Es una corrección a mi censo de T-98.** Ahora el lector anota qué
  segmento lee. Si falla de forma inesperada, lanza `BaplieParsingException` con:
  - el código nuevo `unexpected_segment`;
  - el segmento;
  - su número de orden.

  El mensaje queda «No se pudo interpretar el segmento LOC (n.º 245 del archivo) del BAPLIE: trae
  un dato que el lector no esperaba. Revisa ese segmento en el archivo o pide una nueva
  exportación.». La lectura no cambia, porque solo se anota la posición, y el corpus da los mismos
  datos (sección 5). El genérico sin segmento queda solo de reserva y no se alcanza, porque el lector
  etiqueta un segmento antes de cualquier lectura. El detalle técnico va al registro desde
  `vessel_repository_impl.dart`.
- **M050.** La fuente se nombra en español.
- **M217 y M218.** En los seis sitios, una excepción que no es `StateError` pasa por
  `vesselErrorMessage` con su operación. La pantalla ya no muestra «Instance of
  'VesselOperationFailure'» ni «Bad state: …».
- **Conflictos (M190-M216).** Cada uno termina con la acción que lo deshace en su pantalla:
  - carga: «Si el registro fue un error, deshazlo desde el detalle de la celda»;
  - descarga: «…desde el detalle del contenedor»;
  - tapas: «…con «Deshacer conflicto»»;
  - cancelaciones: «Si la cancelación fue un error, la oficina la deshace…»;
  - cambios del plan: «Revísalo en la bandeja de cambios de la oficina».

  M216 ya traía la suya.
- **M099** («La operación no está disponible.») pasa a una constante con causa y acción, que usan
  sus cuatro sitios.
- **Fuera de los 218:** la línea de estado de «Nube y cuenta» repetía el texto de M056 sin su acción.
  Ahora dice lo mismo que M056.

**Dos familias de mensajes se guardan**, y su texto guardado **no cambió**:
- el detalle de los avisos de lectura (M181-M183), que se guarda con el viaje;
- los avisos de fila del listado (M141-M142), que se guardan con el listado y se publican con su
  huella.

Tocarlos habría cambiado lo guardado y la huella de lo publicado. Por eso la causa, el segmento y la
acción se agregan al mostrarlos:
- la tarjeta dice «Pesos revisados en MEA: 1 contenedor · revisa esos pesos antes de operar»;
- cada fila del listado termina en «Corrige esa fila en el Excel y vuelve a importarlo.».

### 2.4 Lo que no cambia

No cambia la lógica, las reglas, el codec, lo guardado, los identificadores, `lib/main.dart` ni los
congelados. Se **agregaron** identificadores nuevos, sin cambiar ninguno:
- el código `unexpected_segment`;
- las constantes `unknownVoyageNumber`, `operationUnavailable`, `ChangeRequests.operationNotOpen` y
  `ChangeRequests.signInToMove`;
- la función `unexpectedErrorMessage`.

## 3. «Detente y avisa»: lo que revisé

Ninguno de los casos de la ficha se dio, así que no me detuve.

| Caso de la ficha | Resultado |
|---|---|
| Un cambio de texto obliga a cambiar datos guardados o identificadores | **No.** `UNKNOWN` se guarda igual. Los avisos de lectura y los del listado, que se guardan, conservan su texto, y la acción se agrega al mostrarlos (2.3). Los campos de Firestore, las claves y los códigos no cambian. Los cotejos del corpus lo confirman (sección 5) |
| Algo del producto lee el CSV exportado | **No.** En `lib/` no hay ningún lector de CSV: solo `export_service.dart` lo escribe |
| Un mensaje vive en un archivo congelado | **No.** Una nota: la pantalla H5 `c3_reconciliation_screen.dart`, congelada y sin tocar, muestra `displayFormat` y ahora verá la posición en español |
| Cambiar «Bay Plan» toca algo más que textos | **No.** La pestaña cambia de texto. Las pestañas se eligen por índice (`animateTo(1)`) y los demás «Bay Plan» son comentarios |

## 4. Pruebas

| Comprobación | Resultado |
|---|---|
| `flutter analyze` | **0 incidencias** (34 s). Ningún `// ignore:` nuevo; `lib/` sigue sin ninguno |
| `flutter test` (suite completa) | **1063 de 1063**, 0 fallas, 0 omitidas, 83 s |
| `pubspec.yaml` / `pubspec.lock` | **Cambian**: `flutter_localizations` (sdk) e `intl` 0.20.2 transitiva. Ningún otro paquete cambia de versión |

**Un tropiezo, para que conste.** Una suite completa anterior también dio 1063 de 1063. Después
corregí el segundo sitio de M015 (`vessel_providers.dart:376`), y la suite siguiente encontró que
`t74_loading_plan_test.dart` esperaba «Elige». Lo actualicé y la suite final, de arriba, pasó
completa.

### 4.1 Pruebas nuevas (4 archivos, 16 pruebas)

| Archivo | Pruebas | Qué comprueba |
|---|---:|---|
| `test/t112_localization_test.dart` | 2 | Flutter en español: «Atrás», «Alerta», «Cerrar», «Menú emergente», «Eliminar», «Copiar», «Pegar»; el selector de fecha dice «Seleccionar fecha», «Cancelar» y «octubre» |
| `test/t112_messages_test.dart` | 7 | M001, M006 y M004 en el formateador; M034 y M037 sin el código de Firebase en pantalla; M061; M068; M218 en «Tapas» sin el `toString()` de la excepción |
| `test/t112_csv_test.dart` | 3 | encabezados en español y en el orden de antes; estado y banderas en español; el JSON sin cambios |
| `test/t112_position_test.dart` | 4 | posición «Bahía, Fila, Nivel»; sin número de viaje se guarda `UNKNOWN` y se muestra «sin número»; la tarjeta dice «Viaje: sin número»; los avisos de lectura nombran su segmento y dicen qué hacer |

### 4.2 Pruebas actualizadas (20 archivos)

Todas cambian **solo el texto esperado**. La única excepción es T-83, que además arrastra la lista
hasta el botón. Ningún archivo pierde pruebas ni aserciones: conté pruebas y `expect` antes y después.

| Archivo | Qué cambió |
|---|---|
| `test/baplie_parser_test.dart` | la posición en español («Bahía 012, Fila 00, Nivel 06») |
| `test/support/t91_toolbar_support.dart` | la pestaña «Plano» |
| `test/t103_smdg15_test.dart` | la versión no admitida nombra la cabecera UNH (M024) y el aviso de SMDG15 también (M180) |
| `test/t104_text_test.dart` | las pestañas «Lista», «Plano», «Estadísticas» |
| `test/t105_drag_widget_test.dart` | «Mover exige una cuenta autorizada…» |
| `test/t105_preview_test.dart` | ídem |
| `test/t106_messages_test.dart` | los rechazos de la oficina con su acción («Elige una bahía de su tamaño», «revisa el OR o el número») |
| `test/t106_plan_widget_test.dart` | el título «BAHÍA nn» y el intercambio con su acción |
| `test/t107_tabs_test.dart` | la pestaña «Plano» |
| `test/t107_texts_test.dart` | los conflictos con su acción (celda, contenedor, cancelación y bandeja) |
| `test/t110_bays_test.dart` | el selector «BAHÍA 01 (17%)» |
| `test/t56_socket_ranges_test.dart` | «Tomas de refrigerado» y los rangos mal escritos con su acción |
| `test/t73_export_list_page_test.dart` | «No hay un plan de carga confirmado: abre primero el plan de carga (BAPLIE)…» |
| `test/t74_loading_plan_test.dart` | M015: «…es de llegada o de carga: elige una opción» |
| `test/t79_cloud_page_test.dart` | las líneas de estado de la nube con su acción |
| `test/t82_departure_widget_test.dart` | «no tiene el plan de carga (BAPLIE)» (M143) |
| `test/t83_hatch_covers_test.dart` | el mensaje con su acción ocupa más líneas: `dragUntilVisible` hasta «Aplicar» |
| `test/t90_theme_test.dart` | M006 al guardar el tema |
| `test/vessel_geometry_page_test.dart` | los mensajes de la geometría con su acción («Escribe al menos 6.») |
| `test/vessel_profile_view_test.dart` | el selector «BAHÍA 03 (0%)» |

## 5. El corpus

Los archivos reales del corpus (A01…A08v_VGM) están fuera del repositorio.

**Instrumentos.** Son los 36 `tool/*_test.dart`, sin los cuatro de cotejo y sin
`t98_estandares_test.dart`, de Codex. Dan **157 de 157 en verde** (31 s), con las cifras de siempre,
como los 977 contenedores de A01 o los 177 eventos y 178 documentos de T-79 con A08v_VGM.

**Cotejos contra HEAD.** Hice una copia limpia de `cdab56b` en TEMP con `git archive`. Sobre esa
copia capturé las referencias con `T108_CAPTURE_BASELINE`, `T110_CAPTURE`,
`T110ACC_CAPTURE_BASELINE` y `T111ACC_CAPTURE_BASELINE`. Después corrí los mismos instrumentos sobre
el árbol de T-112:

| Cotejo | Qué compara | Resultado |
|---|---|---|
| T108 (10 archivos) | la huella de `voyage.toJson()` completo, avisos de lectura incluidos | **iguales** en los 10 |
| T110 (10 archivos) | datos, geometría aplicada, formato guardado (codec), contenedores, peso, reservas y bahías | **iguales** en los 10 |
| T110ACC (13 casos: ACC1-3 y los 10 del corpus) | bahías leídas y reabiertas, «Bahías ocupadas» de Estadísticas, registro local y publicado | **iguales** en los 13: «registro igual, publicado igual» |
| T111ACC (192 casos: 4 viajes × 8 anchos × 6 escalas) | la tarjeta del viaje: píxeles de la fila, si apila, si parte y el resumen de reservas | **192 de 192 idénticos en todos los campos** (comparé `baseline.json` con `head.json` campo por campo) |

Sobre T111ACC hay que leer algo con cuidado. El instrumento se hizo para comparar T-111 con su
padre, así que exige que la referencia diga «1 celdas reservadas», el plural que T-111 corrigió.
Contra HEAD, que ya lo corrigió, su aserción marca los 48 casos ACC2 con el mismo texto a los dos
lados: «2 contenedores · 1 celda reservada -> 2 contenedores · 1 celda reservada». **No es una
diferencia.** Los otros 21 cotejos pasan sin observaciones.

## 6. Los censos, otra vez

**Cómo se repiten.** `tool/t112_censos.py` importa los cinco `tool/t98c_*.py` sin cambiarlos.
Traslada sus tablas de decisión al árbol nuevo, archivo por archivo y línea por línea, con
`difflib` contra la copia de HEAD. Las cadenas nuevas de T-112 que el traslado no puede ubicar se
deciden en `T112_DECISIONES`, una por una y con su motivo. `tool/t112_mensajes.py` trae los mismos
218 mensajes de T-98, cada uno con su texto nuevo, el fragmento que lo ubica en el código y su
juicio. Si un fragmento no aparece, el censo se detiene.

```
python -I tool/t112_censos.py . %TEMP%\t112\censos --antes %TEMP%\t112\head
```

Tarda 3 s. Dos corridas sobre el árbol final dan las mismas huellas.

### 6.1 Idioma

| Canal | Español | Sin idioma | Mixta | Otro idioma | Total | T-98 (inglés o mixtas) |
|---|---:|---:|---:|---:|---:|---:|
| pantalla | 1525 | 111 | 0 | 0 | 1636 | 23 |
| accesibilidad | 49 | 0 | 0 | 0 | 49 | 2 |
| sistema | 5 | 2 | 0 | 0 | 7 | 0 |
| pdf | 46 | 19 | 0 | 0 | 65 | 4 |
| archivo (CSV) | 32 | 1 | 0 | 0 | 33 | 23 |
| **Total** | **1657** | **133** | **0** | **0** | **1790** | **52** |

Son 63 cadenas visibles más que en T-98 (1790 frente a 1727). El mismo censo sobre la copia de HEAD
da 1727, así que la diferencia es toda de T-112, y sale sobre todo de:
- las operaciones que los llamadores pasan al formateador (M001 y M006);
- los textos nuevos del formateador;
- las acciones de los conflictos;
- los cinco valores del CSV;
- las acciones de la tarjeta del viaje.

**La métrica** (las mismas dos lecturas de T-98: (a) español / (español + inglés o mixto); (b)
(español + sin idioma) / visibles):

| Alcance | (a) | (b) | T-98 (a) / (b) |
|---|---:|---:|---:|
| Interfaz (pantalla, accesibilidad y diálogos del sistema) | 100 % | 100 % | 98.4 % / 98.5 % |
| Interfaz, con los textos de Flutter | 100 % | 100 % | 97.1 % / 97.3 % |
| Todo lo visible, también el PDF y el CSV | 100 % | 100 % | 96.7 % / 97.0 % |
| Todo lo visible, con los textos de Flutter | 100 % | 100 % | 95.5 % / 95.9 % |

**Lo que no llega al 100 %: nada.** Las 133 sin idioma son las mismas categorías de T-98. Por tipo de
palabra (una cadena puede tener más de uno):
- 97 siglas o códigos, como OR, TEU, IMO, OOG, POL o ISO;
- 34 unidades, formatos o identificadores técnicos, como PDF, CSV, JSON, «t» o el correo omitido;
- 9 nombres propios, como BayStream.

El vocabulario nuevo es poco: los segmentos que ahora nombran los mensajes (MEA, LOC, EQD, UNA, DTM,
BGM, UNT, UNZ), el identificador SMDG15 y la unidad «cm» de los encabezados del CSV.

**Los textos de Flutter.** Las 20 entradas de la tabla I-7 de T-98 ahora salen de `material_es.arb`
(SDK 3.38.9): «Atrás», «Alerta», «Cerrar», «Menú emergente», «Eliminar», «Cortar / Copiar / Pegar /
Seleccionar todo», «Seleccionar fecha», «Cancelar / ACEPTAR», «Mes anterior / Mes siguiente»…
`t112_localization_test.dart` comprueba los principales.

**Las decisiones nuevas** (`T112_DECISIONES`):
- el código de idioma `'es'` de `app.dart`, que no se muestra (`NV-CODIGO`);
- el código `unexpected_segment`;
- los mensajes nuevos de sesión y sincronización;
- los nombres de las fuentes de M050;
- los valores del CSV;
- las etiquetas de fase del lector, que M004 muestra («los segmentos UNH y DTM», «el segmento TDT»);
- el texto técnico de la excepción, `NV-REEMPLAZADO`, que va al registro;
- el genérico de M004 sin segmento, que no se alcanza (`NV-INALCANZABLE`);
- `UNKNOWN`, que se decide como `NV-PERSISTENCIA`, y su rótulo «sin número»;
- las dos operaciones que nombran Parámetros y Perfiles.

Cada una lleva su motivo en el script.

### 6.2 Material 3

237 controles interactivos y 12 excluidos (rejilla y no interactivos), los mismos de T-98.
**Excepciones: 0.** La de T-98 era el avatar del buscador y queda resuelta en 2.2.

### 6.3 Mensajes

| Tipo | Mensajes | Causa y acción explícitas |
|---|---:|---:|
| falla | 51 | 51 |
| rechazo | 44 | 44 |
| validación | 70 | 70 |
| aviso de datos | 21 | 21 |
| estado de error | 4 | 4 |
| conflicto | 28 | 28 |
| **Total** | **218** | **218 (100 %; T-98: 49, 22.5 %)** |

**Errores de lectura de un BAPLIE que nombran el segmento: 12 de 12** (T-98: 4):
- ya lo hacían M002 (UNH/S009), M003 (TDT), M151 (UNB y UNH) y M184 (los segmentos que faltan);
- ahora también M004 (el segmento que falló, con su número), M024 y M152 (la cabecera UNH), M153
  (UNA), M180 (la cabecera UNH, SMDG15) y M181-M183 (MEA, LOC+147 y EQD, al mostrarlos).

Las 29 envolturas de T-98 siguen siendo 29.

## 7. Windows, la Web y el Honor

**El banco** es `tool/t112_main.dart`. Publica al arrancar un BAPLIE de ensayo escrito en el propio
archivo, que no es un buque real. Trae:
- un refrigerado, una IMO con su peso en LBR, bodega y cubierta y un 40;
- un vacío con el dígito de control mal;
- una posición mal formada (`00X0182`);
- una reserva;
- ningún número de viaje.

No inicializa Firebase: una llamada remota falla a propósito. Usa el lector real y un namespace
propio, `t112`. En Windows el almacén va en TEMP, en la Web en IndexedDB del origen local y en
Android en la carpeta privada de la identidad de prueba.

**El recorrido** es `tool/t112_recorrido.dart`. Toca la interfaz como una persona, con el mismo método
de `tool/t99_conductor.dart`, sin `flutter_test` y sin control del escritorio. Pasa por Lista, el
detalle de `TSTU1120009`, Plano, Estadísticas, el buscador vacío y con «TSTU112», y, en la ventana
real, Parámetros y Nube y cuenta. En cada captura anota:
- los textos que se dibujan;
- los que no caben (`didExceedMaxLines`);
- las palabras quitadas por T-112 que todavía aparezcan («Bay», «Row», «Tier», «Reefer», «DECK»,
  «HOLD», «Tip», «UNKNOWN», «Back»…);
- los desplazables horizontales;
- los errores de Flutter.

| Cliente | Compilación | Tamaños × letra | Capturas | Inglés | Errores | No caben |
|---|---|---|---:|---:|---:|---|
| Windows | release, abierta con `explorer.exe`, almacén en TEMP | lienzo de 360×780 y ventana real de 1265×683, con 1.0 y 1.45 | 28 | **0** | **0** | 10, todos iguales en HEAD |
| Web | release (`--pwa-strategy=none`), servida por `tool/t99_servidor.dart` en 127.0.0.1, Chrome *headless* con perfil propio en TEMP | lienzo de 360×780 y ventana de 1258×802, con 1.0 y 1.45 | 28 | **0** | **0** | los mismos 10 |
| Honor NAA-LX3 (Android 15) | `--profile` (AOT y depurable), identidad `gt.cmartinez.baystream.t112` | pantalla real, 360×800 dp (720×1600 px, 320 dpi), con `font_scale` del sistema en 1.0 y 1.45 | 8 + 8 | **0** | **0** | 2 con 1.0 y 4 con 1.45 |

**Control sobre HEAD.** Corrí el mismo banco y el mismo recorrido en Windows sobre la copia de
`cdab56b`. Salieron las mismas 28 capturas con **392 palabras en inglés**: «Bay» 172, «Row» y «Tier»
64 cada una, «Reefer» 28, «BAY» 22, «Reefers» 16, «UNKNOWN» 10, y «DECK», «HOLD», «Tip» y «Back»
4 cada una. Los textos que no caben son **los mismos 10**.

**Lo que no cabe, en los tres clientes.** Ninguno de estos textos cambió en T-112, y todos aparecen
igual en el control de HEAD:
- la línea de resumen del plano («Bahía 01/02 · pendientes de carga: cubierta 2…»), a 360 dp;
- «Número de orden» con 1.45;
- la pista del buscador («Buscar contenedor o puerto...»): con 1.45, y en el Honor también con 1.0;
- «SIN NAVIERA» en la ventana real con 1.45.

**Lo que se ve distinto, mirado en las capturas.**
- **El plano a 360 dp tiene más contenido en sus desplazables horizontales.** «BAHÍA 01 (11%)» es
  más largo que «BAY 01 (11%)», y «Refrigerado» que «Reefer». Sus desplazables horizontales crecen
  entre 29 y 114 px. Con 1.0, la leyenda deja «Refrigerad…» en el borde y el resto se ve desplazándola,
  donde HEAD mostraba «Reefer» completo.
- **En el lienzo de 360×780 de Windows con 1.45**, el título de la rejilla es más largo y la rejilla
  se centra unos 20 px más a la derecha. El peso de la última pila («2.2 t») queda en el borde y se
  lee desplazando, como ya pasaba en HEAD con el título. En el Honor con 1.45 el peso se ve completo.
- Igual que en HEAD: el título de la rejilla se corta con 1.45, y el rótulo de zoom «100 %» tapa el
  final del título.

No lo corregí porque sería cambiar la maqueta y no un texto, y la ficha no lo pide. Lo dejo para
que Carlos decida.

**Cómo llegué al APK del Honor, para que se pueda repetir.** Tuve dos intentos fallidos antes del
bueno:
1. El primer APK release (SHA-256 `422a5bf1…`) escribía el recorrido en
   `/storage/emulated/0/Android/data/<paquete>/files`. Esa carpeta solo la crea Android con
   `getExternalFilesDir`, que el banco no llama, así que la app no pudo crearla. Crearla desde adb
   tampoco sirve, porque queda a nombre de `shell`. Retiré esas carpetas vacías.
2. El segundo APK marcaba como depurable la variante release de la copia. El plugin de Gradle
   compiló Dart para debug, pero empaquetó el motor de release, y la app abortó al iniciar
   («Precompiled runtime requires a precompiled snapshot»).
3. **El bueno es `--profile`:** AOT como release, depurable y firmado con la clave de depuración.
   Escribe en su carpeta privada y adb lo lee con `run-as`. Pesa 94 937 933 bytes, SHA-256
   `265d2703f5b6272d73fd38de14dd781fca94a7e10edde208a18d8814096ffd4`. `aapt` confirma «BayStream
   T112» y `application-debuggable`, y `apksigner` confirma la firma Android Debug.

**El Honor quedó como estaba:**
- `font_scale` en 1.0, modo avión en 0 y Wi-Fi en 1;
- de los paquetes, solo se agregó `gt.cmartinez.baystream.t112`, que queda detenido (48 frente a 47).

**Evidencia** en `build/t112/` (141 archivos, 6.9 MB; `build/` está ignorado por Git):
- `windows/`, `web/`, `honor-letra-1.0/`, `honor-letra-1.45/` y `control-head-windows/`, cada una
  con su `recorrido.jsonl` y sus PNG;
- `censos/`;
- `cotejo-t108/`, `cotejo-t110/`, `cotejo-t110acc/` y `cotejo-t111acc/`;
- `registros/`, con analyze, las suites, corpus, cotejos, compilaciones y el estado del Honor.

Las copias de compilación siguen en `%TEMP%\t112\`. La de los clientes compila exactamente el `lib/`
del árbol: comparé las huellas de los 137 archivos. Solo cambia la identidad Android de prueba.

## 8. Notas para otras tareas

- **T-99:** `tool/t99_conductor.dart` busca la pestaña «Bay Plan» (líneas 114 y 196) y el rótulo
  «BAY nn (» (línea 334). Desde T-112 son «Plano» y «BAHÍA nn (». No lo toqué, porque es de T-99.
  Hay que actualizarlo antes de su próxima corrida. `tool/t99_ram_resumen.dart` solo lo nombra en un
  comentario.
- **H5:** `c3_reconciliation_screen.dart` (congelada) muestra `displayFormat`. Desde T-112 verá
  «Bahía 002, Fila 01, Nivel 82».
- **Mi censo de T-98 (M004):** el arreglo daba por hecho que el segmento y la línea viajaban en el
  fallo, y no viajaban. Por eso hubo que anotar la posición en el lector (2.3).

## 9. Archivos

**Modificados (75):**
- `pubspec.yaml` y `pubspec.lock`;
- 53 de `lib/`:
  - `lib/core/`: `app.dart`, `errors/exceptions.dart` y `utils/iso_coordinate_parser.dart`;
  - repositorios de datos: `export_list_repository_impl`, `firebase_session_repository`,
    `firestore_operation_sync`, `local_only_operation_sync`, `movement_log_repository_impl` y
    `vessel_repository_impl`;
  - servicios de datos: `baplie_parser_service`, `export_list_parser_service`, `export_service` y
    `pdf_report_service`;
  - entidades: `container_slot`, `hatch_covers` y `movement`;
  - servicios del dominio: `change_requests`, `departure_baplie_writer`, `load_check`,
    `loading_operation`, `operation_state_deriver`, `reefer_socket_ranges` y `voyage_comparison`;
  - el formateador `vessel_error_message`;
  - 13 páginas, 3 providers y 13 widgets de presentación;
- los 20 de `test/` de la tabla 4.2 (uno es `test/support/t91_toolbar_support.dart`).

**Nuevos (10):**
- `lib/core/utils/voyage_number.dart`;
- `test/t112_csv_test.dart`, `test/t112_localization_test.dart`, `test/t112_messages_test.dart` y
  `test/t112_position_test.dart`;
- `tool/t112_censos.py`, `tool/t112_mensajes.py`, `tool/t112_main.dart` y
  `tool/t112_recorrido.dart`;
- `docs/T112-RESULTADOS.md`, este informe.

La lista exacta, ruta por ruta, va en el bloque de Git de la entrega.

**No van:**
- `lib/main.dart`, los congelados y `.claude/settings.local.json`;
- los `tool/t98_*` y `docs/T98-RESULTADOS.md` de Codex;
- los `.docx` y `.pdf` de `docs/` que aparecen modificados en el árbol, que no son míos;
- los archivos que generan las compilaciones (`android/local.properties`,
  `GeneratedPluginRegistrant.java`, `windows/flutter/ephemeral/…`), que no están en HEAD.
