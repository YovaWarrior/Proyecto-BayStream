# T-66 y T-67 · Peso efectivo (VGM o bruto) y peso por pila con «no evaluado»

Timonel · 6-oct-2026 · rama `sprint-3`, sobre `51857ba` · carril de `lib/`, `test/` y `pubspec.*`

## 1. Resultado

| Tarea | Estado | Pruebas | Corpus | Pantalla |
|---|---|---|---|---|
| T-66 | Hecha, salvo Android | 282 → **294** | 5 de 5 cifras ✓ | Windows ✓ · Web ✓ (también a 360 px) · **Android pendiente** |
| T-67 | Hecha, salvo Android | 294 → **300** | A08 = A08v_VGM ✓ | Windows ✓ · Android pendiente |

- `flutter test`: **300/300** en 5 corridas seguidas después de T-67. `flutter analyze`: **cero**, sin `// ignore:` nuevos.
- `pubspec.yaml` y `pubspec.lock` **no cambian**. No hay dependencias nuevas.
- No se tocaron `lib/main.dart`, los archivos H5, ni la exportación CSV/JSON.

**Android no se miró.** El Honor estaba conectado, pero `AGENTS.md` reserva el teléfono a través de Carlos y Codex lo usa en T-70. El emulador `Pixel_8_Pro` tiene un PIN de bloqueo, y sin desbloquearlo Android no monta el almacenamiento ni abre la app. No introduje ese PIN. Ver el punto 7.

## 2. Qué cambió

### T-66 · Peso efectivo

- `ContainerUnit.effectiveWeight`: el VGM si viene y, si no, el bruto de `MEA+WT`. `weightSource` dice de qué segmento salió: `WeightSource.vgm`, `WeightSource.gross` o `null`. `netWeight` se calcula sobre el peso efectivo.
- `Bay.totalWeight`, `weightByTier`, `deckWeightByRow` y `holdWeightByRow` suman el peso efectivo. Las pilas de T-67 salen de aquí.
- `VesselVoyage.totalWeight` es nuevo y es el que se muestra. `totalGrossWeight` y `totalVgmWeight` se quedan como **sumas crudas**, con su comentario. Así la prueba existente de `totalGrossWeight` sigue diciendo lo que decía.
- **Pantalla:**
  - Tarjeta resumen («Peso Total») y Estadísticas («Peso Bruto Total» → «Peso Total»): muestran el total efectivo.
  - Lista: el rótulo dice «Peso (VGM)» o «Peso bruto»; si no hay peso, «Sin peso».
  - Búsqueda: toneladas del peso efectivo.
  - Detalle, en el plano y en la lista: una fila «Peso (VGM)» y una «Peso bruto»; si vienen los dos, salen los dos. Sin peso: «El archivo no trae peso». Ya no aparece «N/A kg».
  - **Celda del plano:** el peso en toneladas con un decimal («28.7»), debajo del tipo y la línea. Va dentro de un `FittedBox` que solo reduce: con la letra del sistema agrandada, la celda encoge su contenido en vez de desbordarse.
- **PDF:**
  - La tarjeta «Peso bruto» pasa a «Peso total», con el total efectivo.
  - La tabla conserva sus dos columnas crudas. La primera pasa de «Peso t» a «Bruto t», porque dejaba «-» en un contenedor que solo trae VGM sin decir de qué columna se trataba.
- **Estadísticas a 360 px:** la cifra «Peso Total» salía cortada («6940....»). Ahora se reduce hasta caber. Ver el punto 4.

### T-67 · Peso por pila

`StackWeightValidator`:

| Pila | Resultado |
|---|---|
| Suma conocida > límite | **Posible incumplimiento**, como antes. Si además falta algún peso, la descripción agrega «N contenedores de esta pila no traen peso: el peso real es mayor». |
| Suma conocida ≤ límite y falta algún peso | **No evaluado**, severidad aviso, con la razón: «N contenedores de esta pila no traen peso». Incluye las posiciones y los números de la pila completa. |
| Pesos completos y ≤ límite | Nada, como antes. |
| Sin límite en el perfil | Nada (C-7). |

## 3. Cifras contra la ficha

### T-66 · Peso total del viaje

Comprobado con `tool/t66_corpus_test.dart` (lector y bahías) y en la pantalla de los clientes indicados:

| Archivo | Contenedores | Esperado | Obtenido | Hoy (antes) | Fuente del peso | Pantalla |
|---|---:|---:|---:|---:|---|---|
| `CORPUS_A07` | 398 | 6 940 578 kg | **6 940 578 kg** ✓ | 213 310 kg | 333 VGM · 65 WT | Windows y Web: «6940.6t» |
| `CORPUS_A05` | 736 | 11 210 489 kg | **11 210 489.02 kg** ✓ | 0 kg | 736 VGM | Web a 360 px: «11210.5t» |
| `CORPUS_A08` | 405 | 6 899 700 kg | **6 899 700 kg** ✓ | igual | 405 WT | Windows: «6899.7t» |
| `CORPUS_A08v_VGM` | 405 | 6 899 700 kg | **6 899 700 kg** ✓ | 0 kg | 405 VGM | Windows: «6899.7t» |
| `CORPUS_A01` | 977 | 8 366 089 kg | **8 366 089 kg** ✓ | igual | 977 WT | — (no regresa) |

- A05 trae decimales de kilo; la prueba compara redondeando al kilo.
- **Ningún contenedor** de esos cinco archivos queda sin peso efectivo, así que ninguno puede mostrar «N/A kg».
- En el corpus **ningún contenedor trae VGM y WT a la vez**, ni ninguno viene sin peso. La preferencia por el VGM no cambia ninguna cifra existente, como preveía la ficha.
- Celdas: en A07 las **398** celdas con contenedor dibujan su peso en las 21 bahías, y en A08v_VGM las **405** en 24 bahías. Se recorrió bahía por bahía en una prueba de widget, sin «N/A» y sin desbordes.

### T-67 · Alertas de peso por pila

**Límite de prueba: 90 000 kg.** No es del buque, porque el corpus no trae el manual de estabilidad. Es el valor de las pruebas de C-7 y el del supuesto que C-7 retiró. Lo elegí porque deja pocas alertas, legibles; con 60 t salían 42.

| Archivo | Alertas con 90 000 kg | Antes (solo `WT`, faltante = 0) | Pantalla (Windows) |
|---|---:|---:|---|
| `CORPUS_A08` | **10** | 10 | «10 posibles incumplimientos · 0 no evaluados» |
| `CORPUS_A08v_VGM` | **10**, idénticas a A08 | **0** | «10 posibles incumplimientos · 0 no evaluados» |
| `CORPUS_A07` | 15 | 0 | «15 posibles incumplimientos» |
| `CORPUS_A05` | 1 | 0 | — |
| `CORPUS_A01` | 26 | 26 (no regresa) | — |

- Las 10 de A08 están en las bahías 14, 15, 18, 26 y 30. La mayor es la bodega 014, filas 01 y 03, con 121 200 kg cada una.
- A08 y A08v_VGM dan **las mismas alertas** (regla, estado, descripción, posiciones y contenedores) también con 50, 60, 70 y 80 t: 62, 42, 37 y 26.
- Sin límite declarado no hay ninguna alerta en los cinco archivos.
- Ningún archivo del corpus produce «no evaluado» de peso, porque todos sus contenedores traen peso. Ese estado se prueba con fixtures sintéticos.

## 4. Lo que se vio en pantalla

| Cliente | Ancho | Qué se miró | Resultado |
|---|---|---|---|
| Windows 11, versión de lanzamiento | 1920 px, maximizada | A07: resumen, lista, bahías 01 y 14, detalle, alertas. A08 y A08v_VGM: resumen, lista y alertas | Peso en todas las celdas, legible; «Peso (VGM) 29000 kg» en el detalle; pilas de más de 90 t en rojo |
| Web (Chrome del panel, compilación local) | 800 px | A07: resumen, plano | Igual que Windows |
| Web | **360 px** | A05: resumen, Estadísticas, bahía 02 | Las celdas miden lo mismo en cualquier ancho (50 × 40) y el plano se desplaza en horizontal. Tipo, línea y peso caben sin taparse, también en las celdas reefer con ícono |
| Android | — | — | **Pendiente** (punto 1) |

**Hallazgo a 360 px, corregido dentro de T-66.**
- Qué pasaba: la tarjeta «Peso Total» de Estadísticas cortaba la cifra («6940....»). Antes del cambio no se notaba, porque mostraba «213.3 t» o «0 kg».
- Arreglo: la cifra se reduce hasta caber («11210.5 t» completo).
- La tarjeta resumen de «Lista» y la lista ya cabían.

Evidencia local en `build/t66-t67/`: capturas `windows_a07_bahia01.jpg`, `windows_a07_bahia14.jpg`, `web360_a05_bahia02.jpg` y `web360_a05_estadisticas.jpg`; registros de las cinco corridas de la suite, de `analyze` y de las dos aceptaciones. La carpeta `build/` está ignorada por Git.

**Almacén local.** Las pruebas de pantalla no eran de persistencia, pero lo dejo dicho:
- La app de Windows se lanzó desde la sesión de Claude Code. Abrí A07 con un límite de 90 000 kg, que guardó un perfil «BUQUE GOLF», y luego A08v_VGM y A08.
- Desde esa sesión no encontré ningún `.hive` modificado hoy ni en `%LOCALAPPDATA%\BayStream` ni en `…\Packages\Claude_…\LocalCache\Local\BayStream`. No sé con certeza dónde escribió.
- Si Carlos abre BayStream en Windows y ve un perfil «BUQUE GOLF» con 90 000 kg, es de esta prueba y se puede borrar desde «Perfiles guardados».
- La Web usó el almacén del navegador del panel, que es aislado.

## 5. Pruebas

**Nuevas:**

| Archivo | Prueba | Qué cubre |
|---|---|---|
| `test/effective_weight_test.dart` | 5 de unidad | Solo VGM, solo WT, los dos, ninguno, neto sobre el efectivo |
| | 3 de sumas | Viaje (efectivo y crudas), bahía, nivel y pila; la exportación CSV conserva las columnas crudas |
| | 4 de pantalla | Peso de la celda («28.7», «21.0», «25.5», nada sin peso); detalle con VGM, con los dos y sin peso; ningún «N/A kg» |
| `test/stack_weight_validator_test.dart` | 6 de T-67 | Excedida con pesos completos (VGM); VGM y bruto mezclados; excedida con un faltante; no excedida con dos faltantes (no evaluado); completa por debajo; sin límite con un faltante |
| `tool/t66_corpus_test.dart` | — | Aceptación de T-66 contra el corpus; necesita `--dart-define=BAYSTREAM_CORPUS_DIRECTORY` |
| `tool/t67_corpus_test.dart` | — | Aceptación de T-67 contra el corpus; necesita `--dart-define=BAYSTREAM_CORPUS_DIRECTORY` |

**Reescritas porque cambió el contrato** (ninguna se borró ni se marcó `skip`):

1. `test/bay_plan_grid_test.dart`, grupo «C-7 · peso por pila en la cabecera»: tres búsquedas (`'20.0'`/`'30.0'`, `'30.0'` × 4 y `'120.0'`).
   - Por qué: la celda ahora también muestra su peso, y `find.text('20.0')` encontraba la cabecera **y** la celda.
   - Cambio: se acotan a la cabecera, excluyendo la clave `peso-celda`. Lo que prueban no cambia.
2. `test/stack_weight_validator_test.dart`, «T-38 igualdad no es exceso; cubierta y bodega no se suman».
   - Por qué: su pila de bodega lleva un contenedor sin peso, y con T-67 esa pila ya no calla, sale «no evaluado».
   - Cambio: la prueba sigue exigiendo que no haya ningún posible incumplimiento (igualdad no es exceso, cubierta y bodega no se suman) y ahora además exige ese «no evaluado».

**Intermitencia observada.**
- Al cerrar T-66, dos corridas de la suite completa dieron 293 + 1 fallo (14 s y 26 s, frente a los 10 s habituales). Coincidió con la máquina cargada.
- Las diez corridas siguientes, cinco de ellas guardadas en `build/t66-t67/`, dieron todo en verde.
- No pude identificar la prueba: la salida compacta no mostró el bloque del error. No es ninguna de las nuevas, que corrieron aparte en verde varias veces.
- Queda anotada para quien la vea de nuevo.

## 6. Decisiones

- **Las sumas crudas se conservan con otro sentido declarado.** `totalGrossWeight` y `totalVgmWeight` siguen en `VesselVoyage` y en `VoyageStats` como sumas de cada segmento. Se agregó `totalWeight`. Ninguna pantalla muestra ya la suma cruda del bruto como «peso total».
- **Peso de la celda.** Solo se dibuja si existe: sin peso no se pinta «0.0». La fuente (VGM o bruto) se ve en el detalle, no en la celda: a 50 × 40 no cabe y el plano impreso tampoco la pone.
- **Severidad del «no evaluado» de peso:** aviso, como en las demás reglas que no se pueden evaluar (`dangerous_goods_validator`, `reefer_socket_validator`).
- La regla de la celda del plano y la de T-67 dependen de `VesselGeometry.isDeckTier`. No se tocaron las anclas de nivel ni su comentario.

## 7. Lo que quedó fuera o anotado

1. **Android, en los dos sentidos.**
   - Falta mirar las celdas y el panel en el Honor: A07 y A08v_VGM, 360 dp.
   - Propuesta: que lo haga Codex en la aceptación cruzada (paso 2 de la sección 6), cuando le toque el Honor. O bien que Carlos me reserve el Honor 15 minutos, o desbloquee él el emulador.
   - El APK de lanzamiento con las opciones de producción ya está compilado en `build/app/outputs/flutter-apk/app-release.apk` y quedó instalado en el emulador `Pixel_8_Pro`. El emulador está apagado y su densidad, restaurada.
2. **Pila incompleta en la cabecera del plano.** La línea de pesos por pila suma lo conocido y no marca que falta un peso: una pila con un contenedor sin peso se ve como un número normal. El panel sí lo dice (T-67). En el corpus no ocurre. Marcarlo, por ejemplo «28.7+?», sería un cambio de la vista que la ficha no pide; queda propuesto.
3. **Las celdas del PDF** no muestran el peso. La ficha pide la celda del plano de la app. El PDF muestra el peso por contenedor en su tabla.
4. **`ContainerSlot.canAccept`** compara `grossWeight` contra `maxWeight`. Ningún código la llama, así que no la toqué. Si alguna tarea la usa (T-77, validación preventiva), debe usar `effectiveWeight`.
5. **Visto de paso, de T-68:** A07 propone la escala HNPCR (`LOC+5`) y 260 contenedores salen «de paso». Es el defecto de T-68, a cargo de Codex; no lo toqué.
6. **A 360 px** el rótulo «Total Contenedores» de Estadísticas también se corta («Total Conte…»). Es un rótulo y no una cifra, y pasaba ya antes; no lo toqué. Va con T-97 (título a 360 px).

## 8. Archivos

**T-66**
- `lib/features/vessel/domain/entities/container_unit.dart`
- `lib/features/vessel/domain/entities/bay.dart`
- `lib/features/vessel/domain/entities/vessel_voyage.dart`
- `lib/features/vessel/presentation/providers/vessel_providers.dart`
- `lib/features/vessel/presentation/widgets/bay_plan_view.dart`
- `lib/features/vessel/presentation/widgets/containers_list_view.dart`
- `lib/features/vessel/presentation/widgets/container_search_delegate.dart`
- `lib/features/vessel/presentation/widgets/voyage_summary_card.dart`
- `lib/features/vessel/presentation/widgets/voyage_stats_view.dart`
- `lib/features/vessel/data/services/pdf_report_service.dart`
- `test/effective_weight_test.dart` (nuevo)
- `test/bay_plan_grid_test.dart`
- `tool/t66_corpus_test.dart` (nuevo)

**T-67**
- `lib/features/vessel/domain/services/stack_weight_validator.dart`
- `test/stack_weight_validator_test.dart`
- `tool/t67_corpus_test.dart` (nuevo)
- `docs/T66-T67-RESULTADOS.md` (nuevo, este informe)

Los dos conjuntos no comparten archivos. El estado T-66 se comprobó solo antes de empezar T-67: 294/294 y `analyze` en cero. El arreglo de la tarjeta de Estadísticas (`voyage_stats_view.dart`, de T-66) llegó después, al mirar la Web a 360 px. Está cubierto por las corridas con T-67 incluida, no por una corrida de T-66 sola.

**Cómo repetir la aceptación:**

```
flutter test tool/t66_corpus_test.dart --dart-define=BAYSTREAM_CORPUS_DIRECTORY="C:\Users\Giova\OneDrive\Documentos\OneDrive\Desktop\Archivos .EDI\Anonimizados\files"
flutter test tool/t67_corpus_test.dart --dart-define=BAYSTREAM_CORPUS_DIRECTORY="C:\Users\Giova\OneDrive\Documentos\OneDrive\Desktop\Archivos .EDI\Anonimizados\files"
```
