# T-69 · Celdas reservadas en el plan de estiba

**Responsable:** Capitán Codex. **Fecha de validación local:** 6-oct-2026.
**Estado:** implementación verificada, lista para el commit de Carlos. La aceptación cruzada de T-68 y T-69 corresponde a Timonel después del commit, según 10.4 y 10.5.

## 1. Implementación

Se conserva cada grupo `EQD+CN` sin número como una entidad de dominio `ReservedSlot`, separada de `ContainerUnit`. Su identidad se deriva de la posición del plan: `R:0030984`. No contiene `containerId` ni UUID; releer y reabrir el mismo plan mantiene esa clave.

El parser conserva tipo ISO, estado, puertos de carga y descarga, línea, peso nominal, temperatura y declaraciones DGS. Se cierra el grupo al llegar a otra posición, a `UNT` o al final del archivo. Los atributos anteriores y posteriores al EQD quedan dentro de su grupo, sin trasladarse a los contenedores vecinos.

`VesselVoyage.reservedSlots` se serializa mediante el contrato local y el codec existentes. Los documentos anteriores sin el campo se leen con lista vacía. Las bahías se reconstruyen con sus contenedores y reservas cuando el almacén omite los datos derivados.

El plano muestra un contorno monocromático, ISO y puerto de descarga; tocarlo abre el detalle de la reserva con peso **nominal**. Las reservas de 40 y 45 pies en bahía par se proyectan a las impares vecinas, conservando la clave de la posición original y sin duplicar el conteo. La lista tiene una sección desplegable propia, aparte de los filtros de contenedores.

La ficha y el diálogo cuentan las operaciones por los puertos de cada reserva, por separado de las cajas. En A08 y A08v_VGM con GTSTC se observó en los tres clientes:

> Se cargan 121 contenedores y 55 reservas (176 movimientos)

Los conteos de contenedores de T-68 se conservan: 121 cargas, cero descargas y 284 de paso. El calificador de cabecera `LOC+61` pasa a la constante correspondiente de `BaplieConstants`, según la nota de revisión de 10.4.

## 2. Peso y ocupación

Las reservas no se incorporan a `containers`, pesos del viaje, peso por pila, posiciones físicamente ocupadas, contenedores llenos/vacíos ni validaciones de carga. «Bahías Ocupadas» cuenta únicamente las bahías con cajas propias o ocupación por cajas largas de las vecinas.

Las posiciones reservadas sí aportan evidencia para proponer una geometría que pueda dibujarlas. Las pruebas comparan peso y ocupación con **la misma geometría declarada**: cambiar el tamaño de la rejilla cambia su denominador, aunque las reservas no ocupen huecos.

El peso nominal se mantiene como información del plan. La sustitución por tara real al asignar un contenedor corresponde a T-76, según el punto 5 de la ficha; no se adelanta esa operación.

## 3. Matriz de aceptación observada

Cada celda indica **contenedores / reservas**. Se importó cada archivo en cada aplicación y se comprobó la ficha y la presencia o ausencia de la sección de reservas. Esta matriz es aceptación de interfaz, además de las pruebas del parser.

| Archivo | Corpus esperado | Windows | Honor 360 dp | Chrome |
|---|---:|---:|---:|---:|
| CORPUS_A01 | 977 / 0 | 977 / 0 | 977 / 0 | 977 / 0 |
| CORPUS_A02 | 806 / 0 | 806 / 0 | 806 / 0 | 806 / 0 |
| CORPUS_A03 | 369 / 0 | 369 / 0 | 369 / 0 | 369 / 0 |
| CORPUS_A04 | 979 / 0 | 979 / 0 | 979 / 0 | 979 / 0 |
| CORPUS_A05 | 736 / 0 | 736 / 0 | 736 / 0 | 736 / 0 |
| CORPUS_A06 | 717 / 0 | 717 / 0 | 717 / 0 | 717 / 0 |
| CORPUS_A07 | 398 / 0 | 398 / 0 | 398 / 0 | 398 / 0 |
| CORPUS_A08 | 405 / 55 | 405 / 55 | 405 / 55 | 405 / 55 |
| CORPUS_A08v_VGM | 405 / 55 | 405 / 55 | 405 / 55 | 405 / 55 |

El corpus de T-69 comprueba las **55 posiciones exactas** de la sección 4 del caso, excluyendo `0060204`, que ya trae número. Conserva los cinco grupos de reservas (9, 20, 7, 17 y 2), el peso de **6 899 700 kg** y las mismas **diez alertas** con el límite **de prueba** de **90 000 kg** para A08 y A08v_VGM. No se convierte ese límite en especificación operativa.

Las cuatro filas de contenedores de T-68 se mantienen en las pruebas de corpus y en las fichas de los tres clientes: A07/GTSTC **0 cargas, 114 descargas, 284 de paso**; A02/GTSTC **0/303/503**; A08/GTSTC **121/0/284**; A01/GTPBR **325/0/652**. Las 55 reservas de A08 se cuentan aparte como carga.

### 3.1 Dibujo y detalle

En los tres clientes se revisaron reservas de 20 pies y representaciones de 40 pies. Windows y Chrome muestran las reservas propias de bahía 06; en el Honor se verificaron el detalle de 40 pies y la proyección a bahía 05. El contorno muestra ISO y puerto de descarga. La proyección no duplica las 55 reservas y abre la posición original: en el Honor, una sombra de bahía 05 abrió `R:0060284`, **Bay 006, Row 02, Tier 84**, `45G1 · PAMIT · LNC · vacío · 3.7 t nominal`.

El detalle de 20 pies `R:0030984` muestra **22G1 · JMKWL · LNA · vacío · 2.1 t nominal**, el puerto de carga GTSTC y la frase que indica que no suma peso ni ocupación. También se comprobó `R:0031084` en el Honor. Las descripciones PAMIT/LNC pertenecen a otro grupo del caso; no se trasladan a estas cuatro reservas de bahía 03.

El Honor usa **720 × 1600 píxeles físicos y densidad 320, equivalentes a 360 dp**. El resumen envuelve el texto y el detalle se desplaza; se pudo leer el conteo, los 176 movimientos y los atributos de las reservas.

### 3.2 Persistencia por el almacén existente

| Cliente | Procedimiento observado | Resultado y almacén |
|---|---|---|
| Windows | Importar A08v, cerrar el proceso, iniciar una sola instancia y abrir el viaje de 405 cajas desde Viajes recientes, sin importar otra vez el archivo | **405 / 55**, GTSTC, 176 movimientos y la misma `R:0030984` con sus atributos. Almacén efectivo: `C:\Users\Giova\AppData\Local\BayStream\vessel_store`; se comprobó la actualización de sus cajas `baystream_*`. Esta ejecución no usó la ruta de Packages/LocalCache. |
| Honor | Importar A08v, detener únicamente la variante `.t69`, abrir su actividad y recuperar el viaje desde Viajes recientes | **405 / 55**, GTSTC, 176 movimientos y las mismas `R:0030984` y `R:0060284`. Variante `gt.cmartinez.baystream.t69`; `dataDir` confirmado con `dumpsys`, y `filesDir` más el contrato existente sitúan el almacén en `/data/user/0/gt.cmartinez.baystream.t69/files/vessel_store`. |
| Chrome | Cerrar la pestaña de prueba, abrir otra en el mismo origen y recuperar el viaje desde Viajes recientes | **405 / 55**, GTSTC, 176 movimientos y pesos VGM conservados. Hive/IndexedDB del origen `http://127.0.0.1:8879`. El detalle `R:0030984` se comprobó antes del cierre; la comprobación adicional de ese detalle después de reabrir quedó interrumpida por Computer Use, como se indica debajo. |

La serialización y la reconstrucción de bahías, claves y atributos después del ciclo JSON/Hive están además cubiertas por las pruebas. La app de Play y la variante `.t68` del Honor no se sustituyeron.

## 4. Verificación

La revisión estática no encontró una razón para apartarse del diseño de la ficha. Se respetó la ventana de medición de T-70b: las ejecuciones empezaron después del **SEMÁFORO** de Carlos y se realizaron con un solo comando de Flutter a la vez.

| Verificación ejecutada | Resultado | Registro local en `build/t69/` |
|---|---|---|
| Suite completa, ejecución final | **360/360**: piso 320 más 40 casos nuevos; sin pruebas eliminadas ni omitidas | `full-tests-final.txt` |
| Corpus externo T-66/T-67/T-68/T-69 | **31/31**, incluidos 14 casos de T-69 | `corpus-tests.txt` |
| `flutter analyze` final | **No issues found!** | `analyze-final.txt` |
| Compilación Windows release final | **Correcta**, 25.1 s | `windows-build-final.txt` |
| Compilación Web release | **Correcta**, 53.1 s | `web-build.txt` |
| Compilación Android arm64 release de prueba, mediante Gradle e init script aislado | **BUILD SUCCESSFUL in 1m 21s** | `android-build.txt` |
| `git diff --check` | Sin errores de espacios; avisos habituales LF/CRLF | Consulta de lectura |

Los 40 casos nuevos incluyen separación de entidades, atributos antes/después de EQD, grupos y delimitadores, retrocompatibilidad JSON, persistencia, pesos/ocupación con geometría fija, conteos de escala, dibujo, sombras y detalles a 360 dp. El formato se limitó a los archivos nuevos de T-69.

Las compilaciones conservan dos advertencias ajenas al cambio: Web indica que no encuentra la fuente `packages/cupertino_icons/CupertinoIcons`; Gradle indica `Deprecated Gradle features were used in this build, making it incompatible with Gradle 9.0.` El ensayo automático de Wasm no equivale a una aplicación Wasm probada. No se modificó `pubspec` para estas advertencias.

No hubo un fallo del producto T-69 en Windows. La automatización del Honor devolvió transitoriamente `ERROR: null root node returned by UiTestAutomationBridge.`; se repitieron las capturas exigiendo un XML nuevo. Dos llamadas del capturador ADB imprimieron `FORTIFY: pthread_mutex_lock called on a destroyed mutex`; sus PNG fueron válidos y la app siguió operativa.

Al intentar mostrar la ventana de Chrome para completar la comprobación adicional de identidad tras reabrir, Computer Use bloqueó la acción con este mensaje exacto:

> Computer Use has been stopped for this turn because it could not determine the current browser URL on Windows with enough confidence to enforce policy.

Se detuvieron las acciones de interfaz. Esto ocurrió **después** de comprobar las nueve filas de Chrome y de recuperar **405 / 55** desde su almacén al cerrar y abrir la pestaña. No se atribuye a Chrome una comprobación posterior del detalle que no llegó a ejecutarse.

### 4.1 Evidencia

Capturas y lecturas de interfaz permanecen en `build/t69/`, ignorado por Git:

- Windows: `windows-a01` … `windows-a08` y `windows-a08vgm` (`.png`/`.txt`); `windows-a08-plan20`, `windows-a08-detail20`, `windows-a08-plan40`, `windows-a08-shadow40`, `windows-reopened`, `windows-reopened-detail` y `windows-store.txt`.
- Honor: `honor-a01` … `honor-a08` y `honor-a08vgm` (`.png`/`.xml`); `honor-a08vgm-reopened`, `honor-a08vgm-reopened-detail20`, `honor-a08vgm-reopened-detail40`, `honor-a08vgm-plan-shadow5` y `honor-a08vgm-shadow-detail40`.
- Chrome: `chrome-a01` … `chrome-a08` y `chrome-a08vgm` (`.jpg`/`.txt`); `chrome-a08-plan20`, `chrome-a08-detail20`, `chrome-a08-plan40`, `chrome-a08-shadow40` y `chrome-reopened`.

Los archivos del corpus permanecen fuera del repositorio. Para Android se usaron copias de texto en `Download/T69`, conservando el contenido EDIFACT. El APK de prueba es `build/t69/baystream-t69.apk`. No se publicó Web ni Android y no se instalaron herramientas globales.

## 5. Rutas de T-69

- `lib/core/constants/baplie_constants.dart`
- `lib/features/vessel/data/services/baplie_parser_service.dart`
- `lib/features/vessel/domain/entities/entities.dart`
- `lib/features/vessel/domain/entities/reserved_slot.dart`
- `lib/features/vessel/domain/entities/vessel_voyage.dart`
- `lib/features/vessel/presentation/pages/vessel_geometry_page.dart`
- `lib/features/vessel/presentation/pages/vessel_overview_page.dart`
- `lib/features/vessel/presentation/providers/vessel_providers.dart`
- `lib/features/vessel/presentation/widgets/bay_plan_view.dart`
- `lib/features/vessel/presentation/widgets/reserved_slot_details.dart`
- `lib/features/vessel/presentation/widgets/reserved_slots_list_view.dart`
- `lib/features/vessel/presentation/widgets/voyage_call_summary.dart`
- `lib/features/vessel/presentation/widgets/voyage_summary_card.dart`
- `test/t69_reserved_slots_test.dart`
- `test/t69_reserved_slots_view_test.dart`
- `tool/t68_corpus_test.dart`
- `tool/t69_corpus_test.dart`
- `docs/T69-RESULTADOS.md`

`tool/t68_corpus_test.dart` adapta únicamente el texto esperado cuando hay reservas; mantiene las cifras de contenedores de la tabla de T-68.

**No cambian `pubspec.yaml` ni `pubspec.lock`.** No hay dependencias nuevas. Los cambios concurrentes de documentos de tesis quedan fuera de T-69. No se modifica el arranque, las opciones de Firebase, los documentos de planificación ni las pantallas H5.

## 6. Resumen para entrega

1. El parser conserva las reservas con identidad natural `R:` por posición y las guarda por el almacén local existente.
2. Plano, lista y escala muestran las reservas aparte; no suman peso ni ocupación y T-68 conserva sus cifras.
3. A08/A08v dan 405 contenedores y 55 reservas en los tres clientes; A01…A07 dan cero. Suite 360/360, corpus 31/31, análisis limpio y tres compilaciones correctas.

**Mensaje para Yov, listo para copiar:**

> Yov: T-69 implementada y verificada por Capitán Codex, lista para el commit de Carlos. `ReservedSlot` usa `R:` por posición, sin UUID ni número ficticio, y se persiste detrás del contrato local. A08 y A08v_VGM muestran 405 contenedores y 55 reservas en Windows, Honor a 360 dp y Chrome; A01…A07 muestran cero reservas. GTSTC dice «Se cargan 121 contenedores y 55 reservas (176 movimientos)» sin cambiar los conteos de T-68. Las reservas no suman peso ni ocupación: A08/A08v mantienen 6 899 700 kg y diez alertas con 90 000 kg de prueba. Suite 360/360, corpus 31/31, analyze sin incidencias y builds correctas de los tres destinos. La reapertura recuperó 55 reservas en los tres; la misma R:0030984 se comprobó nuevamente en Windows y el Honor. La verificación adicional de su detalle tras reabrir Chrome se interrumpió por el bloqueo de URL de Computer Use y está declarada en docs/T69-RESULTADOS.md. Sin cambios en pubspec ni dependencias. Commit propuesto: «Sprint 3: T-69 celdas reservadas con identidad por posicion y conteos separados». Tras el commit queda tu revisión y la aceptación cruzada de Timonel de T-68/T-69, antes de T-72. No se adelantó T-76 ni T-70c.
