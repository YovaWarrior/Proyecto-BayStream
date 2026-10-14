# T-97 · Textos completos y estado de conexión veraz

**Responsable:** Capitán Codex. **Rama:** `sprint-3`. **Fecha:** 14-oct-2026, Guatemala.

**Estado:** **En revisión**. Implementación y aceptación propia completadas; pendiente de aceptación cruzada por Timonel, de acuerdo con 10.18. No se declara aceptada por él.

Se leyeron AGENTS.md completo, las secciones 2, 6, 7, 8 y 9, la ficha T-97 de la sección 5 y las decisiones 10.1–10.31 de SPRINT-3.md, además de docs/T91-RESULTADOS.md y docs/T102-RESULTADOS.md. No se editaron los documentos de planificación de Yov.

## 1. Catálogo y correcciones

| Punto y origen | Corrección | Dónde |
|---|---|---|
| 1. Título completo a 360 dp, incluso con barra desplegada · RNF-003; deuda de T-91 | `BayStream` admite hasta dos líneas y reduce su tamaño si hace falta. La tira horizontal de acciones reserva espacio para el título; conserva las ocho acciones y el botón fijo de plegado. Se aplica también a Lista y Estadísticas para conservar el acceso a cargar archivo sin viaje. La revisión del Honor encontró además truncado `Avance de la operación`: recibe el mismo ajuste de tamaño. | `vessel_overview_page.dart`, `operation_progress_page.dart` |
| 2. `Total Contenedores` completo · 10.2 | La etiqueta ocupa el ancho de la tarjeta bajo el icono y la cifra, sin elipsis. Altura y columnas responden al tamaño del texto. | `voyage_stats_view.dart` |
| 3. Fila del detalle adaptable, también al 200 % · 10.11 | Etiqueta y valor pasan a columna en un detalle estrecho o con letra grande; en ancho suficiente usan dos columnas flexibles. En ambos casos envuelven el texto. Los avisos IMO/reefer también pueden envolverlo. | nuevo `detail_text_row.dart`, `bay_plan_view.dart`, `containers_list_view.dart` |
| 4. Singular y plural · 10.14 | Formatter común: `1 cargado`, `1 pendiente`, `1 asignado`, `1 celda`, `1 reserva`, etc.; cero y varios conservan el plural. Cambia palabras, no cantidades. | nuevo `operation_text.dart`, `operation_progress_page.dart`, `loading_controls.dart`, `discharge_controls.dart`, `loading_plan_controls.dart`, `bay_plan_view.dart` |
| 5. Zonas que dicen pendientes · 10.14 | Forma completa: `(66 pendientes en cubierta / 48 pendientes en bodega)`; el singular es `1 pendiente en bodega`. | `operation_text.dart`, `operation_progress_page.dart`, `discharge_controls.dart`, `loading_controls.dart` |
| 6. Rechazo sin punto doble terminal · 10.16 | El motor evita añadir otro punto a un detalle remoto ya puntuado, origen del defecto observado en T-79. Se conserva la clasificación del rechazo y no se reescriben registros antiguos. El formulario Nube y cuenta también normaliza puntos repetidos al final de sus mensajes de error. | `sync_engine.dart`, `operation_text.dart`, `cloud_page.dart` |
| 7. `Conectando…` mientras averigua; `Sin conexión` con evidencia · 10.16; ampliación autorizada por Carlos | Nuevo estado `connecting`, independiente de `offline`. La caché inicial conserva conexión desconocida; una respuesta del servidor permite `Al día`/`Enviando`. Servidor → caché o error `unavailable` confirma caída. Al reintentar vuelve a averiguar. Una recarga de Riverpod no muestra el `offline` retenido de otro plano. | `operation_sync_repository.dart`, `sync_engine.dart`, `sync_status_chip.dart`, `cloud_page.dart` |
| 8. Selector de bahía sin desborde al 200 % · observación T-102 | Altura calculada con los tamaños de las dos líneas, ancho máximo del chip limitado al espacio entre los controles y ajuste del texto completo. Se comprobó también la escala no lineal del Honor: escalar solamente un tamaño de 28 no bastaba. | `bay_plan_view.dart` |

## 2. Ampliación de alcance autorizada: futura decisión 10.32

Carlos autorizó expresamente distinguir conexión desconocida de caída confirmada en el contrato y en el motor. Indicó que la frase histórica «es todo presentación» de la ficha se corregirá mediante 10.32 al revisar la tarea. Este informe registra la autorización; Codex no modificó SPRINT-3.md ni presupone que Yov ya incorporó esa decisión.

Las **dos rutas fuera de presentación** son:

- `lib/features/vessel/domain/repositories/operation_sync_repository.dart`: agrega `SyncState.connecting` al contrato en Dart puro.
- `lib/features/vessel/data/repositories/sync_engine.dart`: conserva el conocimiento de la conexión, emite las transiciones nuevas y corrige la puntuación de la razón de rechazo.

No hay cambios en el adaptador Firestore, reglas, colecciones, autorización, protocolo de envío, orden, identificadores de movimientos, esquema del almacén ni formato de las fuentes. El rechazo sigue siendo el mismo rechazo; cambia su texto terminal. El motor continúa enviando y confirmando por las vías existentes.

La caché inicial por sí sola no confirma una caída: el SDK puede entregarla antes de consultar al servidor. Por eso no se agregó un temporizador que declare desconexión por suposición. La documentación oficial explica esa primera respuesta desde caché en [escucha de Firestore](https://firebase.google.com/docs/firestore/query-data/listen).

## 3. Pruebas finales

| Validación | Resultado |
|---|---|
| Suite completa `flutter test --reporter expanded` | **648/648**, 27 s; piso vigente **635**, aumento de **13** pruebas |
| `flutter analyze` | **0 incidencias**, 29.6 s |
| Todos los archivos `tool/*corpus*test.dart` | **116/116**, 31 archivos de prueba, 24 s; incluidos PDF, A07/A08, barra T-91 y temas T-90 |
| Fuente `lib/` del repo contra copia compilada | **0 diferencias de SHA** |

Las 13 pruebas nuevas son diez en `test/t97_text_test.dart` y tres en `test/t79_sync_engine_test.dart`. Las dos de corpus T-97 se cuentan aparte dentro de las 116.

- T-97: concordancia cero/uno/varios, pendientes por zona, punto terminal, texto de estados; refresh público de Riverpod con un `offline` previo; título, selector y detalle a **360 × 800, escala 2.0**, en ambos temas; selector con escala no lineal Android; `Total Contenedores` completo; Avance con `1 cargado · 1 pendiente` y título completo, también a escala 2.0.
- Motor: arranque/caché inicial/tiempo transcurrido conservan `connecting`; servidor → caída → reintento → recuperación; `unavailable` confirma caída y conserva pendientes; rechazo remoto cuyo detalle termina en punto genera un solo punto terminal.
- T-74 y T-75: se actualizan únicamente las expectativas de palabras corregidas y el desplazamiento necesario para alcanzar controles cuando crece el detalle. Se conservan los asserts funcionales de carga/descarga.

La ejecución final repitió suite, analyze y corpus después de ajustar el título de Avance observado en el Honor. No se usó `flutter test --platform chrome`.

### Corpus y cifras

Origen externo: `C:\Users\Giova\OneDrive\Documentos\OneDrive\Desktop\Archivos .EDI\Anonimizados\files\`. La prueba nueva lee `CORPUS_A07.edi` desde esa ruta: **398 contenedores, 21 bahías, 6 940 578 kg y 114 con destino GTSTC**. En pantalla: **6 940.6 t**, **290 llenos**, **108 vacíos**, **12 reefers** y **14 IMO**. Avance de A07 sin movimientos: **114 pendientes**, **66 en cubierta / 48 en bodega**, **0 cargados**, **0 asignados**.

El conjunto completo conserva los controles de A01, A02, A03, A03v_VGM, A04, A05, A07, A08 y A08v_VGM que ya contienen los scripts existentes. No se cambió el lector ni el escritor. Las salidas y temporales de las pruebas permanecen en `%TEMP%`; no se incorporó ningún archivo del corpus al repo.

Comando reproducible en PowerShell:

```powershell
$t97CorpusTests = @(rg --files tool -g '*corpus*test.dart')
flutter test @t97CorpusTests '--dart-define=BAYSTREAM_CORPUS_DIRECTORY=C:\Users\Giova\OneDrive\Documentos\OneDrive\Desktop\Archivos .EDI\Anonimizados\files' --reporter expanded
```

## 4. Aceptación propia en los tres clientes

Se usó un banco que presenta las pantallas reales del producto con viewport interno de 360 dp y namespace **`t97acc`**. A07 se añadió como asset **solamente al pubspec de la copia en TEMP**. `tool/t97_main.dart` tiene botones de tema, producto y Avance; en su compilación Web con nube real también permite cortar/restablecer el SDK. Esos controles pertenecen al banco, no a la app de producción.

### Honor · variante `gt.cmartinez.baystream.t97`

Dispositivo de **720 × 1600 px, densidad 320: 360 × 800 dp**. Se revisaron ambos temas: título completo con barra desplegada, estadísticas con `Total Contenedores`, selector con letra del sistema al **200 %** y detalle de A07 con etiqueta/valor y puertos completos al **200 %**. Se leyó, entre otros, el detalle de `XSDU6975247`, posición 0010784, 2300 kg, HNPCR → JMKCT. Avance se revisó en los dos temas.

La primera disposición del selector pasó con escala lineal pero desbordó con la escala no lineal real del Honor. Se corrigió el cálculo y se agregaron dos pruebas que reproducen ese caso. Las capturas terminadas en `-final` corresponden a la disposición corregida.

Los volcados se obtuvieron en memoria y se guardaron sanitizados, siguiendo T-89. Se verificó el paquete antes de guardar capturas. No se inspeccionaron credenciales ni identificadores de cuenta.

Al cerrar se restauraron y verificaron los valores originales: `font_scale = 1.0`, `user_rotation = 0`, `accelerometer_rotation = 1`. Se cerró únicamente `gt.cmartinez.baystream.t97`. La variante queda instalada para la revisión de Timonel.

### Windows

Ejecutable de la copia en TEMP, abierto mediante `Start-Process explorer.exe -ArgumentList <exe>`. Se revisaron A07, título y selector con barra desplegada, estadísticas, detalle y Avance, en claro y oscuro. Las filas de puertos se ven completas.

Almacén real utilizado: **`C:\Users\Giova\AppData\Local\BayStream\vessel_store\`**, cajas `t97acc_*`. La caja `t97acc_movements.hive` permanece en **0 bytes**: no se registraron movimientos. Las cajas de operación y viaje contienen exclusivamente el A07 anonimizado del banco. No se usó el namespace por defecto ni el almacén del paquete de Codex.

La apertura anterior al último ajuste de título usó PID **31140**. El último build se volvió a abrir por Explorer y se verificó Avance en los dos temas; se cerró por su PID **7396**, después de comprobar la ruta. No se cerraron procesos ajenos. Los binarios del repo se conservaron: todos los builds se hicieron en la copia en TEMP.

### Chrome · Web real

Ventana visible, pestaña propia de aceptación, origen local **`http://127.0.0.1:8197/`**, contra **`baystream-app`** mediante SDK cliente. Carlos inició sesión personalmente con la cuenta de muelle; Codex no vio ni anotó correo, UID o contraseña.

Para conexión se abrió el plano de llegada de la operación **ya existente `PRUEBA T-84`**, con unidades sintéticas TSTU. La observación inmediata al abrir fue:

```text
PRUEBA T-84 · T84 · GTSTC Publicada Conectando…
```

Después se observó **`Al día`**. Tras el botón del banco que ejecuta `disableNetwork()` del SDK, se observó **`Sin conexión`** en el plano y en el acceso a cuenta. Al ejecutar `enableNetwork()` volvió a **`Al día`**. La conexión se dejó restablecida. Se guardaron `chrome-sin-conexion-final.png` y `chrome-recuperacion-final.png`.

Para la presentación se volvió a A07 anonimizado: se revisaron título/barra desplegada, selector, estadísticas, detalle de `XSOU9524030` con puertos JMKCT → GTSTC y Avance, en **ambos temas**, a 360 × 800. Se alternó plegar/desplegar sin perder la bahía. Se restableció el viewport y se cerró solamente la pestaña propia de aceptación.

Después del último build se volvió a comprobar Avance y su título completo, en claro y oscuro. Las capturas iniciales recortadas de esa reapertura se sustituyeron por capturas completas mediante la alternativa documentada del navegador. El servidor local final, PID **31096**, se cerró por ese PID tras comprobar su comando y directorio.

**Alcance de la evidencia:** A07 sin registrar movimientos cubre las cifras y el texto ordinario en los tres clientes. El caso `1 cargado` se verifica en el widget real de Avance con un fixture sintético en ambos temas; el rechazo se provoca en el motor con un remoto de prueba, no en producción. La transición real de nube usa T-84 existente, no se publicó A07 para fabricarla. No se presentan esos fixtures como movimientos reales en A07.

## 5. Builds, evidencias y cierre

Copia aislada: **`%TEMP%\baystream-t97-clientes\`**. Se excluyeron `.git`, documentos ajenos, credenciales, keystores y `key.properties`; no se abrió `android/key.properties`. Solo en esta copia se agregó el asset anonimizado, se cambió el applicationId a `.t97` y se usó firma de depuración para la variante de aceptación. El repo conserva su configuración de empaquetado y firma.

Los tres builds de aceptación usan:

```text
--dart-define-from-file=C:\Proyectos\baystream-privado\firebase-prod.json
```

Ese archivo se pasó por ruta, sin abrirlo ni imprimirlo. Web agrega `--dart-define=BAYSTREAM_T97_REAL_CLOUD=true`. Windows reutiliza el SDK C++ ya existente de T-82. Los tres builds finales, posteriores al ajuste del título de Avance, terminaron correctamente: **Windows 33.1 s; APK 59.7 s, 61.7 MB; Web 45.7 s**.

Advertencias de build ya existentes: MSB8029 por compilar bajo TEMP, avisos Android de APIs deprecadas/unchecked y aviso de fuente CupertinoIcons en Web. No hay incidencias en analyze. No se agregaron dependencias.

Evidencias fuera del repo, en **`%TEMP%\baystream-t97-clientes\evidence\`**:

- Honor: `honor-{claro,oscuro}-selector-200-final.png`, `honor-{claro,oscuro}-fila-200-final.png`, `honor-{claro,oscuro}-estadisticas-final.png` y Avance de ambos temas.
- Windows: `windows-{claro,oscuro}-expandida-final.png`, `windows-{claro,oscuro}-estadisticas-final.png`, `windows-{claro,oscuro}-fila-final.png`, `windows-{claro,oscuro}-avance-final.png`.
- Chrome: `chrome-{claro,oscuro}-expandida-final.png`, `chrome-{claro,oscuro}-estadisticas-final.png`, `chrome-{claro,oscuro}-fila-final.png`, `chrome-{claro,oscuro}-avance-final.png`, caída y recuperación del SDK.
- Logs en `%TEMP%`: `t97-suite-final.log`, `t97-analyze-final.log`, `t97-corpus-final.log`, `t97-windows-final-build.log`, `t97-apk-final-build.log`, `t97-web-final-build.log`.

El apagado de la laptop interrumpió la primera sesión; la reanudación recuperó las fuentes guardadas y reconstruyó los procesos propios. También hubo una interrupción del control de interfaz por imposibilidad de verificar la URL de Chrome; Carlos dejó visible la pestaña y se retomó mediante el control del navegador. No se confunde el tiempo apagado con horas de trabajo.

## 6. Integridad y restricciones

Los SHA de estos archivos coinciden antes y después de T-97:

| Archivo | SHA-256 |
|---|---|
| `docs/T80-firestore.rules.propuesta` | `21894B7F43E59F856045473731B795D21F8373C5AC8A1D9FFF324334AC3C9000` |
| `lib/main.dart` | `C5189B1D8711837A05C68306D424C9FDBCC977BA3BBB6C823089FFE4CA5339D5` |
| `lib/latency_test_screen.dart` | `599310DB13A713E82FC0D6A411BE2D7757CBC2B803D772C1CAA16C471725CDFF` |
| `lib/c3_reconciliation_screen.dart` | `3AF478364A8C5386E1F921E0142DC4F847594BECA00B6743563CB09A8A4112A5` |
| `pubspec.yaml` | `AEF5DF33B957708569646C4F751DD6D0B7E4CC91BD4B715871276EBC5F5F808A` |
| `pubspec.lock` | `E192B61FD5917159DB6D9FBFD0C6449586885F88A86738B3074E532E1720B5CC` |
| `baplie_parser_service.dart` | `5D8C843E54D94250E5AE716B839C3000B9A8F7BD4760A5092DD6DC0EFFC4802F` |
| `departure_baplie_writer.dart` | `05EE91981499215E9981094EE3C3230C00AB98C54F4793B8750880D23E656147` |

El SHA de reglas es el del artefacto local autorizado de T-80: no se consultó producción mediante CLI ni credenciales de administrador para volver a obtenerlo. No se ejecutó Firebase CLI, no se usó H5, no hubo deploy, publicación ni movimientos en la nube. No se ejecutó Git de escritura ni `git status`. No se tocaron los documentos ajenos ni los archivos congelados.

**`pubspec.yaml` y `pubspec.lock`: sin cambios en el repo.** No se versionan binarios, capturas, almacenes, corpus ni temporales.

## 7. Horas frente a la estimación

Estimación de la ficha: **1.0 h**. Primera ventana registrada: **13-oct 22:01:30–22:26:23**, aproximadamente **0.415 h**, reconstruida hasta la última evidencia conservada antes del apagado. No existe una marca exacta del apagado; puede haber un pequeño tramo final no registrado.

Reanudación: **14-oct 10:47:53–12:02:08**, incluido el cierre del informe: **1 h 14 min 15 s**. La aceptación propia cerró a las 11:58:33. Sumadas ambas ventanas registradas: **1 h 39 min 8 s, aproximadamente 1.65 h (1.7 h)** frente a **1.0 h estimada**; diferencia aproximada **+0.7 h**. No es una medición exacta del tramo final anterior al apagado. Se excluye el intervalo de laptop apagada. La corrección de la escala no lineal del Honor, la transición autorizada del motor, el ajuste final de Avance y la repetición de los tres builds explican el desvío.

## 8. Rutas propias para el commit de Carlos

Son **21 archivos**, incluidos cinco archivos nuevos de implementación/banco/pruebas y el informe; no se incluyen cambios ajenos:

1. `lib/features/vessel/presentation/pages/vessel_overview_page.dart`
2. `lib/features/vessel/presentation/pages/operation_progress_page.dart`
3. `lib/features/vessel/presentation/pages/cloud_page.dart`
4. `lib/features/vessel/presentation/widgets/bay_plan_view.dart`
5. `lib/features/vessel/presentation/widgets/containers_list_view.dart`
6. `lib/features/vessel/presentation/widgets/voyage_stats_view.dart`
7. `lib/features/vessel/presentation/widgets/discharge_controls.dart`
8. `lib/features/vessel/presentation/widgets/loading_controls.dart`
9. `lib/features/vessel/presentation/widgets/sync_status_chip.dart`
10. `lib/features/vessel/presentation/widgets/detail_text_row.dart` · nuevo
11. `lib/features/vessel/presentation/formatters/operation_text.dart` · nuevo
12. `lib/features/vessel/domain/repositories/operation_sync_repository.dart`
13. `lib/features/vessel/data/repositories/sync_engine.dart`
14. `test/t75_discharge_test.dart`
15. `test/t79_sync_engine_test.dart`
16. `test/t97_text_test.dart` · nuevo
17. `tool/t97_corpus_test.dart` · nuevo
18. `tool/t97_main.dart` · nuevo
19. `lib/features/vessel/presentation/widgets/loading_plan_controls.dart`
20. `test/t74_loading_plan_test.dart`
21. `docs/T97-RESULTADOS.md` · nuevo, informe propio autorizado

No necesitan `git add -f`. Carlos ejecuta el bloque; Codex no lo ejecutó.

```powershell
git add -- lib/features/vessel/presentation/pages/vessel_overview_page.dart
git add -- lib/features/vessel/presentation/pages/operation_progress_page.dart
git add -- lib/features/vessel/presentation/pages/cloud_page.dart
git add -- lib/features/vessel/presentation/widgets/bay_plan_view.dart
git add -- lib/features/vessel/presentation/widgets/containers_list_view.dart
git add -- lib/features/vessel/presentation/widgets/voyage_stats_view.dart
git add -- lib/features/vessel/presentation/widgets/discharge_controls.dart
git add -- lib/features/vessel/presentation/widgets/loading_controls.dart
git add -- lib/features/vessel/presentation/widgets/sync_status_chip.dart
git add -- lib/features/vessel/presentation/widgets/detail_text_row.dart
git add -- lib/features/vessel/presentation/formatters/operation_text.dart
git add -- lib/features/vessel/domain/repositories/operation_sync_repository.dart
git add -- lib/features/vessel/data/repositories/sync_engine.dart
git add -- test/t75_discharge_test.dart
git add -- test/t79_sync_engine_test.dart
git add -- test/t97_text_test.dart
git add -- tool/t97_corpus_test.dart
git add -- tool/t97_main.dart
git add -- lib/features/vessel/presentation/widgets/loading_plan_controls.dart
git add -- test/t74_loading_plan_test.dart
git add -- docs/T97-RESULTADOS.md
git commit -m "Sprint 3: T-97 textos completos y estado de conexion veraz"
git push
```
