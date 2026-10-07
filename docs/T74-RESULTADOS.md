# T-74 · Fuentes de la operación, número de orden y pendientes por bahía

Capitán Codex · 7-oct-2026 · rama `sprint-3` · carril de `lib/` y `test/` autorizado por Carlos.

## 1. Resultado

**T-74 pasa en Windows, el Honor a 360 dp y Chrome.** A07, A08 y el listado quedan en una operación; el plano muestra los OR y los grupos; los pendientes reproducen las nueve bahías del caso y terminan en cero al aplicar los 176 movimientos de carga.

| Verificación | Resultado |
|---|---|
| Aceptación cruzada de T-72 (`08a7dfa`) y T-73 (`04ecbab`), antes de implementar | PASA en los tres clientes; detalle en la sección 2 |
| Suite general | **412/412**; piso solicitado: 405 |
| `flutter analyze` final | **0 incidencias**, sin supresiones nuevas |
| Corpus T-68, T-69, T-72, T-73 y T-74 | **26/26**; los cuatro anteriores aportan 24 y T-74 aporta 2 |
| Compilaciones release Windows, Web y Android arm64 | PASA; todas con el archivo privado de definiciones Firebase |
| Dependencias | **Sin cambios en `pubspec.yaml` ni `pubspec.lock`** |

Se leyeron completos AGENTS.md, SPRINT-3.md, el caso y los informes T-72/T-73, además de T-79a, 2.1–2.2. No se modificaron `lib/main.dart`, las pantallas H5 ni los documentos mantenidos por Yov. No se ejecutaron operaciones de escritura de Git, `git status`, publicaciones ni despliegues.

## 2. Aceptación cruzada de T-72 y T-73

Se hizo **antes de cambiar el código de producción**. La línea base pasó **405/405 pruebas**, `analyze` sin incidencias y **24/24** pruebas de los corpus T-68/T-69/T-72/T-73. No se encontró una discrepancia que exigiera detener la aceptación o corregir el trabajo de Timonel.

### 2.1 T-72 · Bitácora y estado derivado

T-72 todavía no tiene pantalla de movimientos: esa interfaz llega con T-75 a T-78. Para aceptarla en cada plataforma se usó un banco local externo al repositorio, con el parser, el repositorio Hive y el derivador de producción. El banco comprobó los datos y presentó el resultado en la pantalla del cliente; no reemplazó Hive por un almacén en memoria.

| Criterio, tanto con A08 como con A08v_VGM | Windows | Honor 360 dp | Chrome visible |
|---|---|---|---|
| Reproducir los 176 eventos de carga, excluyendo el intercambio | PASA | PASA | PASA |
| Cerrar/reabrir las cajas y reiniciar el cliente: recuperar los mismos 176 registros | PASA | PASA | PASA |
| Ocupación derivada igual al CSV en las 460 posiciones | PASA | PASA | PASA |
| Cero cargas pendientes al finalizar | PASA | PASA | PASA |
| Dos conflictos previstos, fuera de plan: 014-01-02 y 014-01-08 | PASA | PASA | PASA |
| Nueve bahías; 82 en cubierta y 94 en bodega | PASA | PASA | PASA |

Los dos conflictos no son cargas pendientes: los movimientos colocan los contenedores en las posiciones finales del CSV, pero difieren del plan original por el intercambio. El cambio de posiciones corresponde a **T-80**; no se simuló su aprobación ni se corrigió el plan de paso.

### 2.2 T-73 · Listado, cruce y equivalencias

Se importó el XLSX mediante la pantalla real de T-73, se confirmó, se cerró/reabrió el cliente y se volvió a importar.

| Criterio de la ficha y del informe | Windows | Honor 360 dp | Chrome visible |
|---|---|---|---|
| 176 filas en cuatro agencias: 40 / 18 / 27 / 91 | PASA | PASA | PASA |
| 120 llenos que cruzan uno a uno con A08 | PASA | PASA | PASA |
| 56 vacíos en seis grupos: 20 / 17 / 9 / 7 / 2 / 1 | PASA | PASA | PASA |
| Cero filas sin entender y sin cruces pendientes | PASA | PASA | PASA |
| OR 127: clase 9, UN 3082 y 3077; aviso de UN 3082 ausente del plan | PASA | PASA | PASA |
| OR 130: VGM 7 266.59 kg, tara 3 900 kg, neto 3 366.59 kg | PASA | PASA | PASA |
| Listado confirmado y equivalencias sobreviven al reinicio; segunda importación sin volver a pedirlas | PASA | PASA | PASA |

En los almacenes nuevos del Honor y Chrome se observaron las **cinco propuestas automáticas** y la elección explícita **40RF → 45R1**. Windows ya tenía las seis equivalencias guardadas en el almacén real: las aplicó directamente, también después de reiniciar. No se borró ese almacén para forzar un escenario nuevo.

### 2.3 Clientes y almacenes de la aceptación

| Cliente | Almacén y forma de apertura |
|---|---|
| Windows | `C:\Users\Giova\AppData\Local\BayStream\vessel_store`. Apertura mediante `Start-Process explorer.exe -ArgumentList <exe>` y cierre exclusivamente por PID. No se usó el almacén de `Packages\…\LocalCache`. El banco T-72 usó namespaces propios; T-73 usó el almacén habitual de BayStream. |
| Honor NAA-LX3 | Variante **`gt.cmartinez.baystream.t74`**, 720 × 1600, densidad 320: **360 dp**. Almacén `/data/user/0/gt.cmartinez.baystream.t74/files/vessel_store`. La app de Play y las otras variantes permanecieron intactas. |
| Chrome | Ventana visible; IndexedDB local. T-73 se comprobó en `http://127.0.0.1:8784` y el banco T-72 en `http://127.0.0.1:8785`. Se recargó cada origen para comprobar persistencia. No se usó `flutter test --platform chrome`. |

## 3. Implementación de T-74

### 3.1 Fuentes e identidad

Al publicar un BAPLIE con escala confirmada se conserva **su texto completo**, con nombre y tipo de fuente. La clave natural sigue siendo **nombre del buque + viaje + escala**, conforme a T-73, 3.4. Guardar una fuente conserva el `id`, `createdAt` y las demás fuentes de la operación.

El tipo se decide con los conteos de T-68, incluyendo reservas: solo cargas → `loading_baplie`; solo descargas → `arrival_baplie`. Cuando hay ambas o ninguna, se pide elegir **Llegada** o **Carga** antes de publicar; cancelar deja el borrador sin guardar. Un perfil conocido no evita esa elección cuando el tipo es ambiguo.

En GTSTC, A07 aporta 114 descargas y A08 aporta 121 contenedores de carga más 55 reservas. Ambos pertenecen a BUQUE GOLF / VIAJE007A: quedan en una operación con `arrival_baplie`, `loading_baplie` y `export_list`. También funciona cuando la operación ya nació con el listado de T-73. Releer A08 o A08v reemplaza únicamente `loading_baplie`, conservando bitácora e identidad.

### 3.2 Número de orden

El selector **Contenido / Número de orden** aparece en Bay Plan. Se muestran los OR de los 121 contenedores de carga, incluido el **OR 85**, vacío numerado en 006-02-04. Las 55 reservas muestran **tipo / puerto / línea**, sin asignarles un OR; esa asignación corresponde a T-76. Las celdas de carga sin cruce muestran **—** y se cuentan en el resumen.

Sin listado, el modo explica que falta el listado de agencia y ofrece **Importar listado**; el conteo continúa con F/E del plan. Con el listado se usa F/E del listado: por eso son 120 llenos y 56 vacíos, aunque el plan traiga 121 contenedores numerados.

Los OR y grupos usan la escala de colores del tema. La exportación PDF no se modificó.

### 3.3 Pendientes derivados y actualización

El proveedor compartido abre el repositorio de T-72 y escucha su bitácora. El plano y la tabla se recalculan con `OperationStateDeriver`, sin mantener un contador paralelo. Se muestran cubierta/bodega y llenos/vacíos, tanto en el resumen de la bahía como en **Pendientes por bahía**.

Esta vista proyecta **la carga del BAPLIE de carga**. El BAPLIE de llegada se conserva completo para T-75; no se inventan sus 114 movimientos de descarga. La tabla conserva sus nueve filas aun cuando los pendientes llegan a cero. Las bahías pares se agrupan con su impar cuando ambas tienen carga planificada; **22 permanece como 22** en este caso.

## 4. Aceptación de T-74 en los tres clientes

### 4.1 Tabla inicial del caso

Se compararon las nueve filas con la sección 2 de `docs/S3-CASO-MAGELLAN-STAR.md`. Esta tabla de aceptación coincide en los tres clientes; L = llenos, V = vacíos.

| Bahía | Cub. L | Cub. V | Bod. L | Bod. V | Total | Windows | Honor | Chrome |
|---|---:|---:|---:|---:|---:|---|---|---|
| 03 | 1 | 4 | 0 | 0 | 5 | PASA | PASA | PASA |
| 05/06 | 14 | 12 | 16 | 10 | 52 | PASA | PASA | PASA |
| 07 | 0 | 0 | 6 | 5 | 11 | PASA | PASA | PASA |
| 13/14 | 14 | 0 | 18 | 0 | 32 | PASA | PASA | PASA |
| 15 | 0 | 0 | 4 | 0 | 4 | PASA | PASA | PASA |
| 22 | 6 | 0 | 16 | 0 | 22 | PASA | PASA | PASA |
| 25/26 | 0 | 13 | 7 | 10 | 30 | PASA | PASA | PASA |
| 27 | 0 | 0 | 0 | 2 | 2 | PASA | PASA | PASA |
| 29/30 | 18 | 0 | 0 | 0 | 18 | PASA | PASA | PASA |
| **Total** | **53** | **29** | **67** | **27** | **176** | **PASA** | **PASA** | **PASA** |

Cubierta: **82**. Bodega: **94**. Llenos: **120**. Vacíos: **56**.

### 4.2 Fuentes, OR, movimientos y reapertura

| Criterio | Windows | Honor 360 dp | Chrome visible |
|---|---|---|---|
| Una operación con tres fuentes completas; conservar id/fecha al agregar y releer | PASA | PASA | PASA |
| Modo OR y grupos de reserva visibles | PASA | PASA | PASA |
| 121 OR, 55 reservas con grupo, cero celdas de carga sin cruce | PASA | PASA | PASA |
| Aplicar los 176 registros: actualización del resumen y cero en las nueve filas | PASA | PASA | PASA |
| Releer A08v: conservar tres fuentes, id/fecha y 176 registros | PASA | PASA | PASA |
| Reiniciar: recuperar operación, fuentes y bitácora | PASA | PASA | PASA |
| Cliente normal final abre los datos preparados y muestra los pendientes derivados | PASA | PASA | PASA |

Para preparar las fuentes y reproducir la bitácora, que aún no dispone de interfaz de captura, se utilizó `lib/t74_client_acceptance.dart` **solo en la copia privada externa**. Reutiliza `VesselOverviewPage`, los proveedores, el parser, la importación del listado y el repositorio reales; sus botones adicionales son instrumentación de aceptación. Comprueba la operación única y los textos completos sin mostrarlos. La verificación exhaustiva de los 121 OR y los 55 grupos está además en el corpus automatizado; en pantalla se inspeccionaron celdas y grupos, no se afirmó leer manualmente las 176 celdas.

Después se abrieron los binarios normales, con `lib/main.dart` original, para verificar los mismos datos persistidos. Windows utilizó el almacén real indicado en 2.3; el Honor conservó el almacén de `.t74` al sustituir el APK del banco por el APK normal. Chrome usó IndexedDB de **`http://127.0.0.1:8786`**: tras la prueba se sirvió la compilación Web normal en el mismo origen y se recuperó el viaje. Hubo que recargar para que el service worker tomara el cliente nuevo; no se borró IndexedDB.

En el Honor se leyó el OR dentro de la celda a 360 dp, con desplazamiento horizontal del plano: por ejemplo, los OR de cubierta de la bahía 06 y sus grupos 45G1 / PAMIT / LNC. Se comprobó la tabla completa y el retorno al plano sin desbordamientos de los controles nuevos.

Los dos conflictos previstos de T-72 aparecen en la tabla final; **014-01-02 y 014-01-08 mantienen ocupación final fuera de plan**, y el intercambio sigue pendiente de T-80. No quedan movimientos de carga pendientes por esas posiciones.

## 5. Pruebas, corpus y compilaciones

| Ejecución | Resultado |
|---|---|
| Línea base antes de implementar: `flutter test` | 405/405 |
| Suite completa después de implementar: `flutter test` | 412/412 |
| Siete pruebas específicas T-74, repetidas al final | 7/7 |
| `flutter analyze` final | 0 incidencias |
| Corpus T-68/T-69/T-72/T-73, aceptación inicial | 24/24 |
| Corpus T-68/T-69/T-72/T-73/T-74, ejecución final en copia privada | 26/26 |
| Windows release | Compila y abre mediante explorer.exe |
| Android arm64 release | Compila e instala exclusivamente como `.t74` |
| Web release | Compila y funciona en Chrome visible |

Las siete pruebas nuevas cubren inferencia de tipo de fuente, identidad natural y reemplazo conservando otras fuentes, elección explícita del tipo ambiguo, cruces OR/reserva/sin cruce y F/E, carga/cancelación/anulación, y controles/tabla a 360 dp con y sin listado. Los tres archivos previos de pruebas de perfiles/viajes/escala usan un repositorio en memoria para evitar abrir el almacén real durante la suite. La prueba de eliminar un viaje espera el resultado del proveedor tras la escritura local; el código de producción de eliminación no cambió.

`tool/t74_corpus_test.dart` lee el corpus externo y usa almacenes Hive temporales **fuera del repositorio**, que cierra y elimina al terminar. Para A08 y A08v verifica las tres fuentes, su texto íntegro, el identificador y fecha conservados, reapertura, 121 OR, 55 reservas con grupo, cero sin cruce, OR 85 vacío, las nueve bahías y **cada uno de los 176 descensos**, incluida su actualización por el proveedor que usa la pantalla. Finalmente compara las 460 posiciones con el CSV, comprueba cero pendientes y los dos conflictos esperados.

Comandos de compilación ejecutados:

```powershell
flutter build windows --release --dart-define-from-file=C:\Proyectos\baystream-privado\firebase-prod.json
flutter build web --release --dart-define-from-file=C:\Proyectos\baystream-privado\firebase-prod.json
flutter build apk --release --target-platform android-arm64 --dart-define-from-file=C:\Proyectos\baystream-privado\firebase-prod.json
```

La variante Android se generó con un script Gradle temporal limitado al proyecto de prueba: `applicationId` `.t74` y firma de pruebas. El script de inicialización se retiró al acabar. El archivo privado de Firebase se pasó por ruta, **sin abrirlo ni imprimirlo**. Un solo comando de Flutter estuvo activo a la vez.

La corrida inicial de los scripts heredados T-72/T-73 creó almacenes temporales bajo `build` en el repositorio, que esos scripts borraron al terminar. Se repitió la ejecución conjunta de los 26 corpus en `C:\Proyectos\baystream-privado\t74-aceptacion`, con una copia del código y de los scripts, para que esos temporales también quedaran fuera del repo. No se modificaron los scripts heredados. La inspección final confirmó que los directorios temporales del repositorio no conservan archivos del corpus ni almacenes con su contenido. Esta incidencia queda declarada: la corrida inicial no cumplió la separación exigida para los temporales.

## 6. Evidencia y límites

Evidencias locales privadas: `C:\Proyectos\baystream-privado\t74-aceptacion\evidencias\`. No se incluyen capturas, XML del dispositivo, bases Hive, corpus ni el banco de aceptación en Git.

| Evidencia | Ubicación bajo esa carpeta |
|---|---|
| Suite 412/412 | `t74-suite.txt` |
| Siete pruebas finales | `t74-pruebas-finales.txt` |
| Analyze final | `t74-analyze-final.txt` |
| Corpus final 26/26 | `t74-corpus-externo.txt` |
| Compilaciones finales | `t74-prod-windows-build.txt`, `t74-prod-web-build.txt`, `t74-android-prod-build.txt` |
| Windows, tabla inicial / nueve filas / fuentes / reinicio | `windows/t74-pendientes-iniciales.png`, `windows/t74-tabla-inferior.png`, `windows/t74-vgm-fuentes.png`, `windows/t74-reinicio-fuentes.png` |
| Windows normal, OR y cero pendientes | `windows/t74-prod-or-llenos.png`, `windows/t74-prod-cero.png` |
| Honor, tabla inicial / fuentes tras reinicio | `honor/t74-tabla-inicial.png`, `honor/t74-reinicio-fuentes.xml` |
| Honor normal a 360 dp, OR y cero pendientes | `honor/t74-prod-or-lleno.png`, `honor/t74-prod-cero.png` |
| Chrome normal, OR y cero pendientes | `chrome/t74-prod-or-llenos.jpg`, `chrome/t74-prod-cero.jpg`, `chrome/t74-prod-cero-inferior.jpg` |

El alcance es local: no se aceptan con este informe sincronización, roles, aprobación del intercambio, captura de movimientos, asignación de OR a reservas ni PDF operativo. Corresponden a sus tareas del sprint. Los ensayos de interfaz usaron PowerShell/UI Automation y adb, expresamente autorizados por Carlos; Chrome se manejó con la ventana visible.

## 7. Horas

Zona horaria: Guatemala, UTC−6. Las horas son tiempo transcurrido registrado, incluyendo compilaciones y aceptación en clientes; no son una estimación de CPU.

| Trabajo | Inicio | Fin | Horas registradas |
|---|---|---|---:|
| Aceptación cruzada T-72 y T-73 | 15:12:45 | 15:39:54 | **0.45 h** (27 min 9 s) |
| T-74: implementación, pruebas, clientes e informe | 15:39:54 | 16:31:39 | **0.86 h** (51 min 45 s) |

La lectura inicial previa a las 15:12:45 no se cronometró y no se inventa su duración. La aceptación cruzada se contabiliza aparte. **T-74: 0.86 h registradas frente a 3.0 h estimadas**, dentro de la estimación.

## 8. Archivos propios y Git para Carlos

Archivos existentes modificados:

- `lib/features/vessel/presentation/pages/vessel_overview_page.dart`
- `lib/features/vessel/presentation/providers/export_list_providers.dart`
- `lib/features/vessel/presentation/providers/vessel_providers.dart`
- `lib/features/vessel/presentation/widgets/bay_plan_view.dart`
- `test/profile_loading_test.dart`
- `test/recent_voyages_test.dart`
- `test/t68_port_of_call_test.dart`

Archivos nuevos:

- `lib/features/vessel/domain/services/operation_sources.dart`
- `lib/features/vessel/domain/services/loading_plan_progress.dart`
- `lib/features/vessel/presentation/providers/movement_log_provider.dart`
- `lib/features/vessel/presentation/providers/loading_plan_provider.dart`
- `lib/features/vessel/presentation/widgets/loading_plan_controls.dart`
- `test/support/t74_movement_log_support.dart`
- `test/t74_loading_plan_test.dart`
- `tool/t74_corpus_test.dart`
- `docs/T74-RESULTADOS.md`

Son **16 rutas propias**. Los cambios ajenos en documentos DOCX/PDF observados al llegar permanecen fuera de esta entrega. `pubspec.yaml` y `pubspec.lock` no cambian. Los binarios y auxiliares de `build/t74/` están ignorados y no requieren `git add -f`.

Este bloque lo ejecuta Carlos en la rama actual `sprint-3`:

```powershell
git add -- lib/features/vessel/domain/services/operation_sources.dart
git add -- lib/features/vessel/domain/services/loading_plan_progress.dart
git add -- lib/features/vessel/presentation/pages/vessel_overview_page.dart
git add -- lib/features/vessel/presentation/providers/export_list_providers.dart
git add -- lib/features/vessel/presentation/providers/vessel_providers.dart
git add -- lib/features/vessel/presentation/providers/movement_log_provider.dart
git add -- lib/features/vessel/presentation/providers/loading_plan_provider.dart
git add -- lib/features/vessel/presentation/widgets/bay_plan_view.dart
git add -- lib/features/vessel/presentation/widgets/loading_plan_controls.dart
git add -- test/profile_loading_test.dart
git add -- test/recent_voyages_test.dart
git add -- test/t68_port_of_call_test.dart
git add -- test/support/t74_movement_log_support.dart
git add -- test/t74_loading_plan_test.dart
git add -- tool/t74_corpus_test.dart
git add -- docs/T74-RESULTADOS.md
git commit -m "Sprint 3: T-74 fuentes de operacion, numero de orden y pendientes por bahia"
git push
```

## 9. Resumen de tres líneas

1. T-72 y T-73 aceptadas en Windows, Honor a 360 dp y Chrome, con persistencia y corpus en verde.
2. T-74 conserva las tres fuentes en una operación y muestra OR, grupos y pendientes derivados por bahía.
3. Nueve bahías 82/94 y 120/56; 176→0 pendientes; 412 pruebas, analyze en cero y 26 corpus aprobados.

## 10. Mensaje para Yov

Yov: Capitán Codex aceptó T-72 (08a7dfa) y T-73 (04ecbab) antes de implementar T-74. T-74 pasa en Windows con el almacén real abierto mediante explorer.exe, en Honor .t74 a 360 dp y en Chrome visible. Una operación conserva arrival_baplie, loading_baplie y export_list, id/fecha y bitácora al releer; 121 OR y 55 reservas con grupo, sin celdas de carga sin cruce. La tabla reproduce las nueve bahías, 82/94 y 120/56, y llega a cero con los 176 eventos. Los dos conflictos del intercambio permanecen para T-80. Suite 412/412, analyze 0, corpus 26/26; sin dependencias nuevas ni cambios en main/H5. Evidencia y banco de aceptación fuera del repo. El informe separa las horas de aceptación y T-74, y trae las 16 rutas para el commit de Carlos. No se publicó ni desplegó.
