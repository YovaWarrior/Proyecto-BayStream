# T-90 · Tema por dispositivo y barrido en claro

**Estado: En revisión.** Implementación y aceptación propia completas en Windows,
Honor y Chrome. Pendiente de aceptación de Timonel, según la decisión 10.18.
Capitán Codex · 13-oct-2026, Guatemala · rama `sprint-3`.

## 1. Resultado

«Parámetros» permite elegir **Claro**, **Oscuro** o **Seguir al sistema**. Esta última
es la elección inicial y la recuperación ante un valor desconocido. El ajuste
`themePreference` se guarda como `light`, `dark` o `system` en la caja local de
ajustes, junto a `planToolbarCollapsed` y el último puerto. La escritura usa la cola
existente y hace `flush`. No se sincroniza ni modifica el contenido del viaje.

`BayStreamApp` observa el proveedor Riverpod y aplica el `ThemeMode` correspondiente.
El contrato y el enum del dominio no dependen de Flutter; la presentación no abre
Hive. Un fallo de guardado se informa y permite elegir de nuevo. En ese caso la
elección se aplica a la sesión, pero no se afirma que haya quedado persistida.

El botón «Parámetros» está disponible incluso antes de cargar un viaje. Con viaje
abierto conserva el acceso a «Parámetros del buque», dentro de la nueva pantalla.
Las acciones de T-91 se conservan y la barra plegada sigue mostrando solo título
y botón. No se cambiaron modos ni controles de operación.

### Correcciones del barrido

| Zona | Corrección |
| --- | --- |
| Celdas del plano | Fondos y textos emparejados de `colorScheme` para llenos, vacíos, IMO, reefer, OOG, estado desconocido y tránsito. Peso, tamaño, naviera e iconos usan el color de contenido, separado del borde. |
| Número de orden y resaltado | `primaryContainer/onPrimaryContainer` para OR; `tertiaryContainer/onTertiaryContainer` para el resaltado, con marcas coherentes. |
| Rejilla y leyenda | Superficies y contornos del tema; la leyenda comparte los colores de las celdas. Cabeceras cubierta/bodega y sombras usan el esquema. |
| Lista y detalle de contenedor | Etiquetas de reefer, IMO, naviera, tipo y estado; encabezados y textos secundarios adaptados al tema. |
| Pantalla principal | Icono y mensaje de error con `error`; mensajes de éxito y contadores de llenos/vacíos adaptados al tema. |
| Recientes, reserva, avance, importación y perfil/tapas | Pasaron el barrido usando sus estilos Material existentes; no necesitaron cambios propios. |

No se añadieron colores RGB literales ni colores de marca. La semilla de color
preexistente de las dos paletas permanece igual. **`pubspec.yaml` y `pubspec.lock`
no cambian; no hay dependencias nuevas.**

**T-97 sigue pendiente:** recortes de títulos y textos del plano a 360 dp, así como
el espacio del título con la barra expandida. Las acciones del extremo de la barra
se alcanzan desplazando su tira, como en T-91. Estos recortes son de disposición,
no de contraste; no se arreglaron de paso. La barra plegada no desborda en ninguno
de los dos temas del Honor.

## 2. Aceptación en los tres clientes

Se compiló `tool/t90_main.dart`: banco local que usa **`BayStreamApp`, el selector
de tema y las pantallas reales del producto**, repositorio local real y namespace
`t90acc`. La sesión es «Solo este dispositivo», sin cuenta ni movimientos. El banco
rechaza projectId distinto de `baystream-app`. No prueba autenticación ni nube.

El banco encuadra la interfaz en 360 dp y transmite esa anchura a MediaQuery.
Los accesos a detalle y perfil abren los widgets reales; no son recreaciones de las
pantallas. La apertura prepara tapas automáticas **PROVISIONALES** en las bahías
con bodega observada: A07 quedó con **18 bahías declaradas**, sin quitar ni reponer
tapas. Esta preparación es del banco y no cambia el flujo de producción.

| Comprobación | Windows | Honor `.t90` | Chrome visible |
| --- | --- | --- | --- |
| Sin elección anterior: sistema manda | Sistema/efectivo oscuro | Sistema/efectivo oscuro | Sistema/efectivo oscuro |
| Claro elegido con sistema oscuro | Efectivo claro | Efectivo claro | Efectivo claro |
| Claro tras cerrar/reabrir | Pasa | Pasa | Pasa |
| Oscuro tras cerrar/reabrir | Pasa | Pasa | Pasa |
| Volver a sistema y cerrar/reabrir | Pasa; efectivo oscuro | Pasa; efectivo oscuro | Pasa; efectivo oscuro |
| A07, plegada y desplegada, en claro | Pasa, 360 dp | Pasa, 360 dp | Pasa, 360 px CSS |
| A07, plegada y desplegada, en oscuro | No se repitió aquí; regresión T-91 automatizada | Pasa, 360 dp | No se repitió manualmente aquí; regresión automatizada |

El cambio dinámico del brillo del sistema en ambos sentidos, y la prevalencia de
una elección explícita, se ejecutaron en la prueba de widgets del **`BayStreamApp`
real**. En la aceptación manual los tres sistemas estaban en oscuro; no se cambió
la configuración del sistema operativo. Se distingue esa prueba automatizada de
una alternancia manual del sistema en cada cliente.

### Datos y barrido en claro

Se eligieron archivos anonimizados con los selectores reales. A07:
**398 contenedores, 0 reservas, 21 bahías, 6 940 578 kg**, 114 pendientes de descarga
(66 cubierta/48 bodega), 0 realizados y 0 conflictos. A08:
**405 contenedores, 55 reservas, 24 bahías, 6 899 700 kg**.

| Pantalla | Windows | Honor | Chrome |
| --- | --- | --- | --- |
| Viajes recientes | A07 legible | A07 legible | A07 legible |
| A07: plano plegado/desplegado | Título/botón, acciones, leyenda y controles legibles | Ambos estados en claro y oscuro; sin desborde plegada | Ambos estados en claro; sin desborde plegada |
| Detalle de contenedor | Reefer, datos y etiquetas legibles | Reefer y temperatura 21 °C legibles | Reefer y temperatura legibles |
| Detalle de reserva | A08, reserva 22G1, datos legibles | Misma reserva, puertos y peso nominal legibles | Misma reserva, datos legibles |
| Número de orden | Bahía 03 y **OR 123/SUBE visibles** | Bahía 03 y **OR 123/SUBE visibles** | Controles legibles y OR 123 comprobado en el árbol accesible; celda fuera de la captura |
| Avance | A07: total y tarjetas legibles | A07: total y tarjetas legibles | A07: total y tarjetas legibles |
| Importación del listado | Vista previa, equivalencias, cruce y confirmación manual | Vista previa, equivalencias, cruce y confirmación manual | Vista previa y equivalencia manual; preparación del listado guardado mediante el banco |
| Perfil con tapas | Perfil recorrido hasta tapas y editor real de tapas | Perfil recorrido hasta tapas y editor real de tapas | Perfil y editor real de tapas mediante acceso del banco |

Listado A08: **176 filas en cuatro agencias, 120 llenos y 56 vacíos**. Se eligió
`40RF → 45R1`; el cruce mostró **120/120 llenos, 56/56 vacíos en seis grupos**.
Las advertencias preexistentes de peligrosas y VGM se conservaron y fueron legibles.
En Windows y Honor se pulsó «Confirmar e importar» y apareció «Listado importado».
En Chrome no se alcanzó ese pie mediante el desplazamiento del controlador:
tras revisar la vista previa, el acceso «Preparar listado para OR (banco)» eligió
el archivo real y llamó al importador existente para guardar esa misma equivalencia
y preparar el barrido. No se atribuye a Chrome una confirmación manual que no se vio.

No se encontraron textos ilegibles por contraste ni elementos invisibles en las
pantallas recorridas. Los controles intencionalmente deshabilitados del perfil
mantienen el estilo Material de deshabilitado. No se confirmaron ediciones del
perfil ni se registraron movimientos durante el barrido.

### Entornos y persistencia

**Windows:** binario propio en
`%TEMP%\baystream-t90-clientes\build\windows\x64\runner\Release\baystream.exe`.
Abierto siempre con `Start-Process explorer.exe -ArgumentList <exe>`.
Almacén observado: **`C:\Users\Giova\AppData\Local\BayStream\vessel_store`**,
cajas `t90acc_*`, fuera del LocalCache del paquete de Codex. Tras las tres
reaperturas `t90acc_movements.hive` quedó en **0 bytes**. Cierre solo por PID,
verificando la ruta; PIDs 24692, 22756, 3140 y 28424, registrados en
`%TEMP%\t90-windows-pids.txt`. App cerrada al liberar el semáforo.

**Honor:** `gt.cmartinez.baystream.t90`, almacén privado de la variante y namespace
`t90acc`. Pantalla física **720 × 1600 px**, densidad **320**, equivalente a
**360 × 800 dp**. Entradas en `/sdcard/Download/t90/`; se navegaron por la raíz
de almacenamiento del Honor porque la raíz «Descargas» no las listaba todavía.
No se alteró la app habitual. Cierre/reapertura con `force-stop` exclusivamente
de la variante propia; quedó cerrada. XML capturados en memoria y sanitizados
antes de mostrarse o guardarse, como T-89; no se guardaron capturas de cuentas
del selector de archivos.

**Chrome:** origen local **`http://127.0.0.1:8110/`**, almacén Hive del navegador
para ese origen, namespace `t90acc`. Ventana visible, viewport 360 × 800, cierre
y nueva pestaña para cada preferencia. La última reapertura mostró
`system / efectivo dark / sistema dark`. El viewport se restauró y se cerró la
pestaña propia; servidor local cerrado por su PID **30908**.

La copia de compilación está enteramente en `%TEMP%`. La comparación SHA-256 de
todos los archivos de `lib/` contra el repositorio dio **0 diferencias**. Android
usa sufijo `.t90` y firma de depuración solo en esa copia, sin abrir
`android/key.properties`. Windows reutiliza el SDK C++ de Firebase ya disponible.
Las tres compilaciones finales usaron
`--dart-define-from-file=C:\Proyectos\baystream-privado\firebase-prod.json`,
sin leer ni imprimir ese archivo:

| Cliente | Compilación final |
| --- | --- |
| Web | Correcta, 45.8 s |
| Android | Correcta, 56.2 s, APK 61.5 MB |
| Windows | Correcta, 34.2 s |

Se conservan los avisos de compilación de fuentes/CupertinoIcons, comprobación WASM,
y MSB8029 por compilar Windows en TEMP. `analyze` no presenta avisos ni errores.

## 3. Pruebas y corpus

| Validación ejecutada | Resultado | Registro temporal |
| --- | --- | --- |
| Suite completa | **612/612**, supera piso 605 | `%TEMP%\t90-suite.log` |
| Pruebas nuevas de tema | **7/7** | `%TEMP%\t90-directed.log` |
| Corpus completo: 29 archivos de pruebas | **112/112** | `%TEMP%\t90-corpus.log` |
| Corpus T-90 dirigido | **2/2**, incluido en las 112 | `%TEMP%\t90-corpus-directed.log` |
| Analyze final | **0 incidencias** | `%TEMP%\t90-analyze.log` |

Las siete pruebas nuevas verifican persistencia de las tres elecciones con cierre
y reapertura de Hive; namespace aislado; puerto y barra conservados; **bytes del
archivo de viajes idénticos** tras cambiar el tema; valor desconocido; elecciones
rápidas; selector real y cambios del sistema; fallo de escritura y recuperación;
y contraste del plano/encabezado reefer en claro y oscuro.

Las dos nuevas pruebas del corpus recorren todas las bahías de A07 y A08 en ambos
temas y conservan sus cifras. Comprueban contraste **≥ 4.5:1** del peso contra el
fondo de cada celda: **803 pesos por tema, 1 606 comprobaciones**. También alternan
la barra a 360 dp sin excepciones. Esta cifra describe esos textos comprobados;
no es una auditoría general de accesibilidad de toda la aplicación.

El conjunto completo incluye `t52_corpus_pdf_test.dart` y `t53_corpus_pdf_test.dart`,
además de los bloques anteriores y T-66 a T-102 que tienen prueba de corpus.
Se usa el patrón **`*corpus*test.dart`**, que incluye los PDF; el patrón
`*corpus_test.dart` los omitiría. No se ejecutó `flutter test --platform chrome`.

El corpus se leyó desde
`C:\Users\Giova\OneDrive\Documentos\OneDrive\Desktop\Archivos .EDI\Anonimizados\files`.
Las entradas de aceptación, salidas y temporales permanecen fuera del repo,
en `%TEMP%\t90-inputs` y `%TEMP%\baystream-t90-clientes`.

Reproducción de los controles de calidad, con un comando Flutter a la vez:

```powershell
flutter test
flutter analyze
$t90Corpus = 'C:\Users\Giova\OneDrive\Documentos\OneDrive\Desktop\Archivos .EDI\Anonimizados\files'
$t90CorpusTests = @(Get-ChildItem -LiteralPath tool -Filter '*corpus*test.dart' | ForEach-Object { $_.FullName })
flutter test $t90CorpusTests --dart-define="BAYSTREAM_CORPUS_DIRECTORY=$t90Corpus"
```

Durante el desarrollo se corrigieron dos fallos antes de la ejecución final:
el estilo de estado desconocido inicialmente coincidía con tránsito (regresión
C5a), y el banco del corpus reutilizaba un árbol con un ProviderScope ya dispuesto.
Ahora esos fondos son distintos y cada fixture desmonta el árbol anterior.
La suite final y el corpus completo posteriores pasaron.

## 4. Integridad, incidencias y horas

SHA-256 del archivo de referencia de las reglas publicadas
`docs/T80-firestore.rules.propuesta`, idéntico al inicio y al cierre:

```text
21894B7F43E59F856045473731B795D21F8373C5AC8A1D9FFF324334AC3C9000
```

No se llamó a la CLI de Firebase, no se usaron credenciales de administrador,
no se leyó ni borró producción y no se publicó nada. No hubo cambios de reglas,
nube o esquema/serialización del viaje. El SHA documenta la referencia local
conservada; no se realizó una consulta nueva a producción.

Otros hashes conservados:

| Archivo | SHA-256 |
| --- | --- |
| `lib/main.dart` | `C5189B1D8711837A05C68306D424C9FDBCC977BA3BBB6C823089FFE4CA5339D5` |
| `lib/latency_test_screen.dart` | `599310DB13A713E82FC0D6A411BE2D7757CBC2B803D772C1CAA16C471725CDFF` |
| `lib/c3_reconciliation_screen.dart` | `3AF478364A8C5386E1F921E0142DC4F847594BECA00B6743563CB09A8A4112A5` |
| `pubspec.yaml` | `14916474A1874780E0D5851F9AFB4AE46A4B6B75286D4B497919DE38B7509E9F` |
| `pubspec.lock` | `FAA283751D6D97B1F87059EA683B4CC12ED43DDF6E92A52C1B993A801A510C97` |
| Parser BAPLIE | `5D8C843E54D94250E5AE716B839C3000B9A8F7BD4760A5092DD6DC0EFFC4802F` |
| Writer BAPLIE de salida | `05EE91981499215E9981094EE3C3230C00AB98C54F4793B8750880D23E656147` |

**Incidencias de automatización:** Chrome necesitó recargar la copia final del banco
y tuvo capturas vencidas. Se restauró 360 × 800 después de un cambio incorrecto
de altura para intentar ver el perfil completo. **No se aceptan como evidencia**
`chrome-claro-perfil-completo.png` ni `chrome-claro-tapas.png`, tomadas con esa
altura distinta; el editor de tapas se verificó después en el viewport correcto
(`chrome-claro-tapas-final.png`). Windows produjo capturas negras e índices de
accesibilidad vencidos; se continuó solo con observaciones actuales y capturas
dibujadas, sin atribuir resultados a capturas negras.

**Horas frente a 2.0 estimadas:** inicio 13-oct a las **16:16:33 Guatemala**
(22:16:33 UTC). Hubo una interrupción por límite de sesión de aproximadamente
**17:17 a 20:24** (≈3.1 h), delimitada por el último acceso del servidor a las
23:16:55 UTC y la primera comprobación de reanudación a las 02:24:51 UTC.
La aceptación quedó comprobada a las **20:53** y se redactó este informe después:
**≈1.6 h de actividad, incluida la redacción, frente a 2.0 h estimadas**.
Informe cerrado a las **21:00 Guatemala**: **≈4.73 h de pared**, incluida esa pausa.
La actividad es una estimación por ventanas observadas, no un cronómetro continuo;
las horas de pared no se presentan como horas trabajadas.

## 5. Evidencias y archivos propios

Capturas en **`%TEMP%\baystream-t90-clientes\evidence`**, sin versionar:

- `chrome-reapertura-claro.png`, `chrome-reapertura-oscuro.png`,
  `chrome-reapertura-sistema.png`; `chrome-claro-plano-plegada.png`,
  `chrome-claro-plano-expandida.png`, `chrome-claro-recientes.png`,
  `chrome-claro-avance.png`, `chrome-claro-detalle-contenedor.png`,
  `chrome-claro-detalle-reserva.png`, `chrome-claro-importacion.png`,
  `chrome-claro-numero-orden.png`, `chrome-claro-perfil.png`,
  `chrome-claro-tapas-final.png`.
- `honor-reapertura-claro.png`, `honor-reapertura-oscuro.png`,
  `honor-reapertura-sistema.png`; `honor-claro-plano-plegada.png`,
  `honor-claro-plano-expandida.png`, `honor-oscuro-plano-plegada.png`,
  `honor-oscuro-plano-expandida.png`, `honor-claro-recientes.png`,
  `honor-claro-avance.png`, `honor-claro-detalle-contenedor.png`,
  `honor-claro-detalle-reserva.png`, `honor-claro-importacion.png`,
  `honor-claro-importacion-cruce.png`, `honor-claro-numero-orden.png`,
  `honor-claro-perfil.png`, `honor-claro-perfil-tapas.png`, `honor-claro-tapas.png`.
- `windows-reapertura-claro.png`, `windows-reapertura-oscuro.png`,
  `windows-reapertura-sistema.png`; `windows-claro-plano-plegada.png`,
  `windows-claro-plano-expandida.png`, `windows-claro-recientes.png`,
  `windows-claro-avance.png`, `windows-claro-detalle-contenedor.png`,
  `windows-claro-detalle-reserva.png`, `windows-claro-importacion.png`,
  `windows-claro-importacion-cruce.png`, `windows-claro-numero-orden.png`,
  `windows-claro-perfil.png`, `windows-claro-perfil-tapas.png`, `windows-claro-tapas.png`.

**17 archivos propios**, enumerados exactamente en el bloque siguiente. Los tres
tests preexistentes solo adaptan la expectativa de color, el proveedor de tema del
test raíz y la etiqueta «Parámetros» de T-91. Los cuatro documentos de tesis con
cambios preexistentes permanecen ajenos a esta entrega e intocados.

## 6. Git para Carlos

Codex no ejecutó Git que escriba, ni `git status`. No hay rutas propias ignoradas
por las reglas de `.gitignore`; no hace falta `-f`.

```powershell
git add -- lib/core/app.dart
git add -- lib/features/vessel/data/datasources/hive_vessel_data_source.dart
git add -- lib/features/vessel/data/repositories/local_vessel_repository_impl.dart
git add -- lib/features/vessel/domain/entities/app_theme_preference.dart
git add -- lib/features/vessel/domain/repositories/local_vessel_repository.dart
git add -- lib/features/vessel/presentation/pages/parameters_page.dart
git add -- lib/features/vessel/presentation/pages/vessel_overview_page.dart
git add -- lib/features/vessel/presentation/providers/theme_preference_provider.dart
git add -- lib/features/vessel/presentation/widgets/bay_plan_view.dart
git add -- lib/features/vessel/presentation/widgets/containers_list_view.dart
git add -- test/bay_plan_grid_test.dart
git add -- test/support/t91_toolbar_support.dart
git add -- test/t90_theme_test.dart
git add -- test/widget_test.dart
git add -- tool/t90_corpus_test.dart
git add -- tool/t90_main.dart
git add -- docs/T90-RESULTADOS.md
git commit -m "Sprint 3: T-90 tema por dispositivo y contraste en ambos modos"
git push
```

## 7. Tres líneas y mensaje para Yov

Parámetros ofrece claro, oscuro y sistema, persistentes por dispositivo en los tres clientes.
Barrido en claro completo y Honor a 360 dp en ambos temas; colores desde colorScheme y recortes para T-97.
612/612 pruebas, 112/112 corpus, analyze 0 y reglas con el mismo SHA; T-90 queda En revisión.

**Mensaje para Yov:** T-90 implementada y En revisión por 10.18. Commit propuesto:
`Sprint 3: T-90 tema por dispositivo y contraste en ambos modos`. Las tres elecciones
persisten tras cerrar/reabrir Windows (almacén real t90acc), Honor .t90 y Chrome.
Barrido en claro completo, con OR 123 visible en Honor/Windows y barra de A07 a
360 dp en claro/oscuro en Honor. 612/612 contra piso 605, corpus completo 112/112
(29 archivos, incluidos PDF), analyze 0; 1 606 pesos con contraste ≥4.5:1. Reglas SHA
21894B7F43E59F856045473731B795D21F8373C5AC8A1D9FFF324334AC3C9000 sin cambio.
Aproximadamente 1.6 h activas frente a 2.0, descontando pausa de sesión ≈3.1 h.
Sin dependencias, cambios en main/H5/nube/esquema del viaje ni publicaciones.
T-97 conserva los recortes; la preparación de OR en Chrome usó el importador desde
el banco tras inspeccionar la vista previa. Informe: docs/T90-RESULTADOS.md.
