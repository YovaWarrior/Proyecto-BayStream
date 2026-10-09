# T-78 · Avance de la operación para la oficina

**Fecha:** 8-oct-2026. **Responsable:** Capitán Codex. **Rama de trabajo:** `sprint-3`.

**Resultado:** aceptación cruzada de T-77 aprobada; T-78 implementada y aceptada en Windows, Honor a 360 dp y Chrome. El cierre del caso da 114 descargados, 120 llenos cargados, 56 vacíos asignados, cero pendientes y dos conflictos.

## 1. Aceptación cruzada de T-77, separada de T-78

Se revisó la entrega de Timonel `01721dd` antes de editar código. Se leyeron completos `AGENTS.md`, `SPRINT-3.md`, el caso Magellan Star y los informes T-76/T-77; también las secciones 2.3–2.7 del diseño T-79a. No hubo discrepancia de aceptación que exigiera detener la tarea ni se corrigió T-77 de paso. El cambio de rótulo posterior pertenece expresamente a T-78, decisión 10.13.

| Comprobación | Windows | Honor `.t78`, 360 dp | Chrome visible |
|---|---|---|---|
| Validación en memoria de los 176 eventos contra A08 | Exactamente 2 avisos: OR 128 y OR 145; cero bloqueos | Igual | Igual |
| Carga en una de las 54 celdas que A07 descarga | OR 145 en 014-01-08 ofrece «Marcar su descarga y cargar»; registra descarga y carga | Igual | Igual |
| OR 12 en reserva de otro grupo | Reserva 005-02-02; sin motivo no confirma; con motivo registra y deja conflicto | Igual | Igual |
| 40 pies en posición de 20 | OR 1 en 025-06-02: bloqueado; no se registra | Igual | Igual |
| Límite de prueba de 90 000 kg | OR 134 en pila 014, bodega, fila 01: avisa 123,4 t frente a 90 t; sin motivo no confirma | Igual | Igual |
| Retirada del límite | Perfil sin límite declarado | Igual | Igual |

Los 176 eventos se validaron contra el plan de carga A08, como exige la ficha. La prueba de ocupación se hizo aparte, con llegada A07, carga A08 y listado. El par descarga/carga dejó 175 cargas pendientes (119/56) y 113 descargas pendientes (66/47). La asignación posterior del OR 12 dejó 174 cargas pendientes (119/55) y conservó su tara de 2 185 kg y el motivo escrito. La bitácora de aceptación quedó con tres registros en cada cliente; los intentos bloqueados y cancelados no añadieron movimientos.

**Corpus antes de implementar T-78:** 42/42, incluyendo los corpus existentes T-68, T-69 y T-72 a T-77. Registro: `t77-corpus.txt` en el directorio temporal indicado en la sección 5.

Windows usó `t78acc` en el almacén real, abierto con `Start-Process explorer.exe -ArgumentList <exe>` y cerrado por su PID. Honor usó exclusivamente `gt.cmartinez.baystream.t78`, namespace `t78acc`. Chrome usó IndexedDB del origen local `http://127.0.0.1:8799`, namespace `t78acc`, en la ventana visible que Carlos facilitó. Se avisó con SEMÁFORO antes de usar Windows y Honor.

La automatización inicial no podía operar la ventana de Chrome disponible. Se detuvo esa comprobación y se informó a Carlos; cuando facilitó la ventana visible, se completó. No fue una discrepancia funcional de T-77.

## 2. Implementación de T-78

- Entrada **«Avance de la operación»** desde Bay Plan, disponible con la operación de carga.
- Tabla de escritorio y tarjetas a 360 dp: TOTAL y bahías agrupadas igual que el plano. Descarga hecha/pendiente, pendientes en cubierta/bodega y re-estibas aparte; llenos cargados/pendientes; vacíos asignados/pendientes; cancelados; conflictos; último movimiento con fecha, hora de registro y autor.
- Proyección de solo lectura sobre `LoadingOperation.state`, derivado por T-72. No se guardan contadores ni se vuelven a aplicar movimientos en la pantalla. Riverpod entrega las actualizaciones de la operación existente.
- Los conflictos incluyen posición real y enlace que selecciona la bahía, cambia al modo correspondiente y revela la celda. En una carga fuera de plan se revela la posición registrada.
- El peso se calcula con los objetos que siguen a bordo en el estado derivado: llegada/tránsito, VGM de llenos del listado y tara de vacíos asignados. Se separa cada pila física por bahía, fila y cubierta/bodega. Reservas sin asignar no añaden peso. Sin límite, «no evaluado»; pesos faltantes se mantienen explícitos.
- Las pilas sobre su límite se muestran aparte y no inflan los conflictos de la bitácora, según 10.13. Los 90 t usados aquí son exclusivamente un límite de prueba, sin validez operativa.
- Después de una corrección, el detalle muestra **«Deshacer corrección»**; conserva la semántica existente de anulación que recupera el movimiento anterior.

La presentación usa Material 3 y `colorScheme`; el dominio no importa Flutter. No se agregaron dependencias. `pubspec.yaml` y `pubspec.lock` permanecen sin cambios. No se modificaron `lib/main.dart`, archivos H5 congelados, Firebase, documentos ajenos ni los acuerdos del repositorio.

## 3. Aceptación en los tres clientes

Para T-78 se utilizó un namespace distinto del de la aceptación T-77: **`t78op`**. Cada cliente comenzó con tres fuentes completas, cero registros y el perfil sin límite. El banco privado prepara las fuentes mediante los importadores existentes y registra los movimientos mediante el repositorio de producción.

| Criterio | Windows release | Honor release, 360 dp | Chrome release visible |
|---|---|---|---|
| Inicial: descarga pendiente | 114: 66 cubierta / 48 bodega | Igual | Igual |
| Inicial: carga pendiente | 176: 120 llenos / 56 vacíos | Igual | Igual |
| Inicial: hechos / cancelados / conflictos | 0 / 0 / 0 | Igual | Igual |
| Recorrido del banco contra conteo independiente | 290/290 pasos iguales | 290/290 | 290/290 |
| Final: descargados / llenos / vacíos | 114 / 120 / 56 | Igual | Igual |
| Final: pendientes / cancelados / conflictos | 0 / 0 / 2 | Igual | Igual |
| Conflictos finales | 014-01-02 y 014-01-08, fuera de plan | Igual | Igual |
| Pila 014, fila 01, bodega, con límite de prueba | 121,2 t / 90,0 t: sobre límite | Igual | Igual |
| Enlace a 014-01-08 | Selecciona BAY 14, modo carga, revela OR 145 «REVISAR» | Igual, con banco oculto para disponer de altura | Igual |
| Corrección posterior de OR 1 | Registro 291; «Deshacer corrección» | Igual | Igual |
| Límite al terminar | Sin declarar | Sin declarar | Sin declarar |

Con el límite de prueba de 90 t, el estado final informa **11 pilas** sobre el límite y conserva solamente los **dos conflictos** de movimientos. El último movimiento muestra el autor de prueba y su hora de registro; tras corregir OR 1, esa corrección pasa a ser el último movimiento sin aumentar los hechos.

### Tamaños y persistencia

- **Windows:** ventana nativa de 1920×1080 píxeles físicos, a escala 150 %. El runner crea 1280×720 multiplicado por la escala; se comprobó DPR 1,5 y área útil Flutter de 1898×1024 px, descontando el marco y título. La tabla es legible sin desplazamiento horizontal. Además, los widget tests ejercitan un viewport Flutter de 1920×1080 a DPR 1.
- **Honor:** 720×1600 píxeles, DPR 2, ancho lógico **360 dp**. La pantalla de avance ocupa una ruta completa con tarjetas y desplazamiento vertical. Se volvió al inicio antes de abrir la variante; no se tocaron la app de Play, otras variantes ni pantallas de ajustes. Al reabrir conservó tres fuentes y 291 registros. El enlace se verificó también con los controles del banco ocultos.
- **Chrome:** ventana visible facilitada por Carlos, origen `http://127.0.0.1:8800`, namespace `t78op`. El origen nuevo evita reutilizar el service worker de la aceptación previa. Se comprobó la tabla, los conflictos, el peso, el enlace y el rótulo mediante UI real; **no** se utilizó `flutter test --platform chrome`. Se dejó el avance final visible, con el límite retirado.
- **Almacén Windows:** `%LOCALAPPDATA%\BayStream\vessel_store`, fuera de `Packages\…\LocalCache`. Se cerró por PID y se reabrió desde Explorer: tres fuentes, 291 registros y límite sin declarar. El almacén de operación por defecto no se utilizó para registrar estas aceptaciones.
- **Almacén Honor:** `/data/user/0/gt.cmartinez.baystream.t78/files/vessel_store`. **Web:** IndexedDB del origen correspondiente.

Las apps de Windows y Honor quedaron cerradas y se liberaron mediante SEMÁFORO. Los namespaces contienen bitácoras de prueba de solo anexar; no se borraron registros para simular un reinicio.

## 4. Pruebas y corpus

| Ejecución | Resultado | Evidencia temporal |
|---|---|---|
| `flutter test` | **459/459**; supera el piso 449 | `t78-suite.txt` |
| `flutter analyze` | **0 incidencias** | `t78-analyze.txt` |
| Corpus previos T-68, T-69, T-72 a T-77 | **42/42** | `t77-corpus.txt`, después `t78-all-corpus.txt` |
| Corpus nuevo T-78 | **6/6** | `t78-all-corpus.txt` |
| Corpus combinado final | **48/48** | `t78-all-corpus.txt` |
| Windows / Android / Web release | Tres compilaciones correctas | `t78-windows-build.txt`, `t78-android-build.txt`, `t78-web-build.txt` |

Las diez pruebas nuevas de la suite son seis de dominio y cuatro de widgets. Cubren carga retenida por ocupación y liberación por descarga posterior; duplicados; corregir/anular y recuperar el movimiento anterior; cancelados y anulación de cancelación; re-estiba aparte; peso real, VGM, tara, ausencia de límite y pesos faltantes; separación de pilas por bahía/zona. Los widgets verifican el flujo desde Bay Plan, actualización al añadir movimientos, enlace a posición real y rótulo de corrección a 360×800 y 1920×1080, en tema claro y oscuro, sin excepciones de layout.

El corpus T-78 usa **A08 y A08v_VGM × tres órdenes de T-76**: cargas primero, descargas primero e intercalados con las cargas en orden inverso. En cada uno compara los 290 prefijos: **1 740 pasos** en total, más los estados iniciales. Compara TOTAL y cada bahía, hechos, pendientes, re-estibas, cancelados y conflictos; también el último movimiento. El oráculo lee contenedores, reservas y registros crudos, mantiene su propia ocupación y no usa `OperationPlan`, `OperationState`, su derivador ni sus contadores. Al final verifica los dos conflictos en sus posiciones registradas y 121 200 kg en la pila de prueba.

Los corpus previos conservan sus comprobaciones de 460 posiciones frente al CSV y persistencia. No existen scripts independientes `t70_corpus_test.dart` ni `t71_corpus_test.dart`; la invocación final usa los nueve scripts existentes. Una primera invocación incluyó esos dos nombres inexistentes y se corrigió; la ejecución final fue 48/48.

Para repetir los corpus, desde la raíz del proyecto, sin copiar sus datos:

```powershell
$t78Corpus = 'C:\Users\Giova\OneDrive\Documentos\OneDrive\Desktop\Archivos .EDI\Anonimizados\files'
flutter test tool/t68_corpus_test.dart tool/t69_corpus_test.dart tool/t72_corpus_test.dart tool/t73_corpus_test.dart tool/t74_corpus_test.dart tool/t75_corpus_test.dart tool/t76_corpus_test.dart tool/t77_corpus_test.dart tool/t78_corpus_test.dart "--dart-define=BAYSTREAM_CORPUS_DIRECTORY=$t78Corpus"
```

Las compilaciones Firebase emplearon `--dart-define-from-file=C:\Proyectos\baystream-privado\firebase-prod.json`; no se abrió ni imprimió el archivo. La compilación Windows privada emitió MSB8029 por compilar dentro del temporal; Web avisó de la fuente Cupertino no disponible. Ninguno produjo un fallo de compilación ni una incidencia de `analyze`; no se añadió una dependencia para silenciarlos.

## 5. Evidencia privada y protección del corpus

Todo el banco de aceptación, sus copias de trabajo, assets del corpus, binarios, logs y capturas permanecen en:

`%TEMP%\baystream_t78_acceptance\`

**No se copió ninguno al repositorio**, tampoco a `build/`. En el repo quedan solo código, pruebas con fixtures sintéticos, el script que lee el corpus externo y este informe agregado. No se publicaron ni desplegaron cambios.

Capturas principales, relativas al directorio temporal:

- Windows T-78: `evidence/windows/initial.jpg`, `final.jpg`, `conflicts-weight.jpg`, `link.jpg`, `correction.jpg`, `reopen.jpg`, `viewport.jpg`, `desktop-final.jpg`.
- Honor T-77: `evidence/honor/events176done.png`, `pairDone.png`, `blocked.png`, `weightWarning.png`, `groupConflict.png`. Windows T-77 se observó en la UI durante la aceptación; no se conservó una captura de archivo de esa sesión.
- Honor T-78: `evidence/honor/t78initial.png`, `t78replaydone.png`, `t78final.png`, `t78rows3.png`, `t78correction.png`, `t78nolimit.png`, `t78probereopened.png`, `t78fulllink.png`.
- Chrome: `evidence/chrome/t77-group.png`, `t78-initial.png`, `t78-final.png`, `t78-conflicts-weight.png`, `t78-link.png`, `t78-correction.png`, `t78-delivery.png`.

El banco se construyó en una copia temporal con entrypoint propio para no modificar `lib/main.dart` ni sobrescribir los binarios compartidos del repo. Dos compilaciones adicionales, `t78-android-probe-build.txt` y `t78-windows-probe-build.txt`, añadieron solo al banco privado un rótulo de dimensiones y la opción de ocultarlo; el código de producción probado no cambió.

## 6. Archivos de esta entrega

1. `lib/features/vessel/domain/services/operation_progress.dart` — nuevo.
2. `lib/features/vessel/presentation/pages/operation_progress_page.dart` — nuevo.
3. `lib/features/vessel/presentation/widgets/loading_plan_controls.dart` — entrada a la pantalla.
4. `lib/features/vessel/presentation/widgets/bay_plan_view.dart` — navegación y revelado de celda.
5. `lib/features/vessel/presentation/widgets/loading_controls.dart` — rótulo de corrección.
6. `test/t78_operation_progress_test.dart` — nuevo.
7. `test/t78_operation_progress_widget_test.dart` — nuevo.
8. `tool/t78_corpus_test.dart` — nuevo; lectura externa, cálculo en memoria.
9. `docs/T78-RESULTADOS.md` — este informe.

Los cambios preexistentes en cuatro documentos de tesis permanecieron intactos y quedan fuera del bloque Git de Carlos. No se ejecutó `git status` ni ninguna operación Git de escritura.

## 7. Horas

Horas locales de Guatemala; son tiempo de trabajo transcurrido aproximado de esta sesión, no mediciones H5 ni una estimación retrospectiva de CPU.

| Trabajo | Ventana aproximada | Horas | Comparación |
|---|---|---|---|
| Lecturas y aceptación cruzada T-77 | 13:20–13:50 | **≈ 0,50 h** | Separadas de T-78; incluye la breve interrupción hasta disponer de Chrome visible |
| T-78: implementación, pruebas, tres clientes e informe | 13:50–14:25 | **≈ 0,58 h** | Frente a **3,0 h estimadas**; ≈ 2,42 h menos |

## 8. Mensaje para Yov

Capitán Codex aceptó T-77 (`01721dd`) en Windows, Honor `.t78` a 360 dp y Chrome: exactamente dos avisos, par descarga/carga, motivo para otro grupo, bloqueo 20/40 y prueba de pila de 90 t; corpus 42/42. T-78 quedó implementada y aceptada en los tres clientes: proyección sobre T-72, TOTAL y bahías, enlaces, peso actual separado de conflictos y «Deshacer corrección». Los 1 740 prefijos del corpus independiente cuadran; cada cliente reprodujo 290/290. Cierre: 114/120/56 hechos, cero pendientes, conflictos 014-01-02 y 014-01-08. Suite 459/459, analyze cero, corpus 48/48; pubspec y main intactos. Horas separadas: aceptación ≈ 0,50 h y T-78 ≈ 0,58 h frente a 3,0. Informe `docs/T78-RESULTADOS.md`; Carlos conserva Git y la decisión de cierre de Ola 2. Sin publicación.
