# T-80 · Roles y solicitudes de cambio

Capitán Codex · 11-oct-2026 · rama indicada `sprint-3`.

**Estado: implementación, validación local y aceptación de producción completas.** T-79 aceptada por separado; T-80 lista para revisión cruzada de Timonel y Git por Carlos.

## 1. Aceptación cruzada de T-79

Se aceptaron los cambios de Timonel `f959024` y `f098e58` antes de implementar T-80. Se leyeron completos AGENTS.md, SPRINT-3.md, T79a-DISENO.md, la propuesta de reglas, su batería y T79-RESULTADOS.md. La revisión de Carlos descrita en 10.16 confirmó íntegros los datos anteriores; no se investigó producción con credenciales de administrador.

| Comprobación | Resultado ejecutado |
|---|---|
| Suite sin cambios T-80 | **485/485**, salida 0 |
| Analyze de entrada | **0 incidencias**, salida 0 |
| Reglas originales T-79 | **54/54**, 13 documentos en el emulador |
| Corpus T-68 a T-79 | **50/50**, salida 0 |
| Producción, Windows oficina y Honor muelle | **Al día** en ambos; 5 registros, 5 ids distintos y 5 cargas confirmadas; 0 conflictos y 171 cargas pendientes |

La operación nueva fue **ACEPTACION T-79 · VIAJE007A · GTSTC**, publicada desde la app de oficina con las fuentes de carga y listado. El Honor se unió desde «Nube y cuenta», sin elegir archivos locales. Registró tres cargas desde el banco de T-79 y las órdenes 4 y 5 desde la pantalla de carga. Se pulsó «Comprobar» en ambos: los conteos coincidieron. Se usó una copia privada de `tool/t79_c9_main.dart`, con el nombre de esta operación y namespace `t80acc`; el archivo de Timonel en el repositorio no se modificó.

Windows se abrió mediante `Start-Process explorer.exe -ArgumentList <exe>` y se cerró por su PID 16612. Almacén real verificado: `C:\Users\Giova\AppData\Local\BayStream\vessel_store`, cajas `t80acc_*`. Honor: variante `gt.cmartinez.baystream.t80`, namespace `t80acc`. Carlos inició la sesión de muelle personalmente; no se leyeron ni registraron credenciales o UID. Se avisó con SEMÁFORO antes de usar los dispositivos y al liberarlos.

**Incidencia del entorno, resuelta sin cambios en T-79:** el primer arranque directo del JAR del emulador omitió `-Duser.language=en`. Con el idioma español del equipo, el JAR produjo HTTP 500 y `MissingResourceException` para `JValidationMessages_messages`. Se detuvo la comprobación y se informó a Carlos; se contrastó el parámetro con el lanzador local instalado y se reinició únicamente el emulador con ese parámetro. La batería original pasó entonces 54/54. No se corrigió código de Timonel.

Emulador: Firestore 1.22.0, edición STANDARD, Java 21.0.8, `127.0.0.1:8181`, proyecto **demo-t80**, JAR directo. No se usó la CLI de Firebase contra producción.

Evidencia: `build/t80/t79-suite.log`, `t79-analyze.log`, `t79-reglas-en.log`; corpus fuera del repositorio en `%LOCALAPPDATA%\Temp\t80-t79-corpus.log`. La captura/jerarquía del Honor y las compilaciones privadas quedaron en `%LOCALAPPDATA%\Temp\baystream_t80_acceptance\`.

## 2. Implementación T-80

- El rol procede del `Operator` de T-79, cuya fuente es `authorized/{uid}`. El muelle ve «Solicitudes de cambio» y «Pedir cambio»; la oficina ve «Bandeja de cambios», «Aprobar» y «Rechazar». Sin cuenta autorizada o sin operación publicada no se ofrecen esas acciones. Una operación cerrada no admite decisiones nuevas.
- La solicitud admite uno a cuatro objetos `{target, from, to}`, con motivo de hasta 300 caracteres. Ofrece el intercambio de dos contenedores por OR o número, y cambios individuales o agrupados. También puede iniciarse desde el detalle de carga. Se muestra pendiente hasta la decisión.
- Aprobar anexa `change_position` con la referencia `request` y los mismos cambios de la solicitud. Rechazar anexa `reject_change` con referencia y motivo. Se conserva la bitácora de anexar; no se edita ni se borra una solicitud.
- El derivador resuelve vigencia y orden total, obtiene primero el plan efectivo y luego evalúa cargas y descargas contra ese plan final. Comprueba el lote entero antes de aplicarlo: el intercambio es atómico. Un origen obsoleto, un destino previsto para otro objeto ajeno al lote o una aprobación distinta de lo pedido quedan en conflicto.
- El estado expone solicitudes pendientes, aprobadas, rechazadas o en conflicto. Una decisión posterior sobre una solicitud ya decidida queda en conflicto; no reemplaza silenciosamente la primera decisión del orden total. Anular una aprobación restaura el plan y la solicitud pendiente.
- T-77, las reservas disponibles, los pendientes y la rejilla del modo Carga usan el plan efectivo. Las reservas mantienen su clave natural del plan publicado al cambiar de posición. La fuente BAPLIE publicada permanece intacta.
- Las proyecciones excluyen los registros rechazados por la nube, para que una aprobación sin permiso no altere el plan local. Se probó este límite expresamente.

Se siguió la ficha vigente de T-80 y T-79a 2.7.2: **una aprobación posterior a una carga puede regularizarla**. La fila histórica «cambio sobre algo ya movido» del cuadro de conflictos de T-79a no se utilizó para impedir el caso que la ficha y la solicitud de Carlos exigen aceptar.

## 3. Validación local y corpus

| Comprobación | Resultado |
|---|---|
| Suite final | **498/498**, salida 0; piso anterior 485 conservado |
| Analyze final | **0 incidencias**, salida 0 |
| Nuevas pruebas de dominio y pantalla | **13/13**; pantalla a 360 dp, temas claro y oscuro |
| Corpus completo T-68 a T-80 | **54/54**, salida 0 |
| Reglas T-80 | **69/69**, 16 documentos; ninguna denegación agotó las 1 000 expresiones |

El nuevo corpus lee A08 y A08v_VGM directamente de la carpeta externa autorizada. Los **177 eventos** (176 cargas y solicitud), más la decisión de oficina, dan **460/460 posiciones del CSV** y cero pendientes. Con aprobación dan **cero conflictos** en tres órdenes de llegada: cronológico, inverso y mezclado con semilla 80. La aprobación se registra después de todas las cargas, por lo que también se prueba ese caso en el orden total. T-77 valida las 176 cargas contra el plan aprobado sin avisos.

Con rechazo, en ambas variantes y en los tres órdenes, permanecen las 460 posiciones registradas y reaparecen exactamente los **dos conflictos fuera de plan** de 128 y 145. El plan publicado no cambia. El corpus de sincronización T-79 conserva sus 178 documentos, reenvíos, corte de red y cierre forzado; se actualizó su expectativa a cero conflictos tras la derivación de T-80.

Comandos ejecutados:

```powershell
flutter test --no-pub --reporter expanded
flutter analyze --no-pub
node tool/t80_reglas.mjs 8181 demo-t80
```

Los corpus se ejecutaron mediante `flutter test --no-pub --reporter expanded`, enumerando `tool/t68_corpus_test.dart` hasta T-80, con `--dart-define=BAYSTREAM_CORPUS_DIRECTORY=<carpeta externa autorizada>`. No se copió el corpus ni sus temporales al repositorio. Su salida quedó fuera, en `%LOCALAPPDATA%\Temp\t80-corpus-completo.log`.

Evidencia local: `build/t80/t80-suite-final.log`, `t80-analyze-final.log`, `t80-final-targeted.log`, `t80-reglas.log` y `t80-reglas-detalle.log`.

## 4. Reglas y publicación por Carlos

Archivo completo: **docs/T80-firestore.rules.propuesta**. Conserva el cierre por defecto, las autorizaciones, las fuentes inmutables, la bitácora y el reenvío idéntico de T-79. `validPayload` selecciona un validador por tipo; cada elemento de `changes` verifica forma y campos. La batería propia conserva los 54 casos anteriores y añade 15, incluidos cuatro cambios permitidos, cinco denegados, elementos inválidos, motivos y restricciones de rol.

SHA-256 del archivo probado: `21894B7F43E59F856045473731B795D21F8373C5AC8A1D9FFF324334AC3C9000`.

**Publicadas por Carlos:** versión activa del **11-oct, 16:08**, cuyo encabezado empieza con «PROPUESTA T-80». Carlos confirmó en el simulador lectura sin sesión rechazada y lectura autorizada con las cuentas de muelle y oficina. No pudo construir las escrituras en el simulador porque el sobre exige `receivedAt == request.time`; las escrituras de solicitud y aprobación se comprobaron después desde las apps reales, con hora del servidor. Codex no publicó reglas ni usó la CLI de Firebase contra producción.

## 5. Aceptación T-80 en producción

**Aceptada.** Operación nueva **PRUEBA T-80 · VIAJE007A · GTSTC** en `baystream-app`. La oficina en Windows preparó y publicó las fuentes de carga y listado; el Honor y Chrome se unieron y abrieron el plan desde la nube. Carlos inició las sesiones personalmente. No se leyeron ni anotaron correos, UID o contraseñas.

1. **Honor, muelle:** desde «Solicitudes de cambio», pidió a las **16:16:39** el intercambio de OR 128 y 145, con motivo. La pantalla resolvió OR 128 como `014-01-02` y OR 145 como `014-01-08`, y mostró ambas flechas. Windows recibió la solicitud pendiente en su bandeja.
2. **Prueba negativa pedida por Carlos:** el banco del Honor intentó `change_position` con esa solicitud, autor de muelle real, sobre normal y `receivedAt` del servidor. Firestore respondió **PERMISSION_DENIED**. Una lectura posterior del documento desde el servidor confirmó que **no existe**. El intento no se anexó a Hive ni se contó como movimiento; no se falsificó el rol y no se usaron credenciales de administrador.
3. **Antes de aprobar:** se reprodujeron las 176 cargas. El Honor mostró **177/177 registros confirmados**, 121 `load_full`, 55 `assign_empty` y una solicitud; **460/460 posiciones del CSV**, cero pendientes y **dos conflictos**. La bandeja de Windows también mostró dos conflictos.
4. **Windows, oficina:** aprobó desde la bandeja con motivo «validado», después de las cargas. Honor y Chrome comprobaron **178/178 confirmados**, una aprobación y **cero conflictos**, conservando **460/460 posiciones** y cero pendientes. La solicitud quedó aprobada en la bandeja de Windows.
5. **Segundo pedido, Honor:** a las **16:20:15** pidió el intercambio inverso con motivo «Segundo pedido para rechazo». El formulario ya usaba el plan efectivo: OR 128 desde `014-01-08` y OR 145 desde `014-01-02`.
6. **Windows:** rechazó ese segundo pedido con motivo «plan vigente». Los tres clientes vieron una solicitud aprobada y otra rechazada. El rechazo conservó el primer cambio aprobado y cero conflictos; el caso separado de rechazo sin aprobación previa se verificó con los corpus de la sección 3 y devuelve los dos «fuera de plan».

| Estado final comprobado | Windows oficina | Honor muelle | Chrome oficina |
|---|---:|---:|---:|
| Sincronización | **Al día** | **Al día** | **Al día** |
| Registros / ids distintos / confirmados | **180 / 180 / 180** | **180 / 180 / 180** | **180 / 180 / 180** |
| Tipos | 121 cargas, 55 reservas, 2 solicitudes, 1 aprobación, 1 rechazo | Igual | Igual |
| Posiciones contra el CSV | **460/460** | **460/460** | **460/460** |
| Conflictos / pendientes de carga | **0 / 0** | **0 / 0** | **0 / 0** |
| Solicitudes | Aprobada y rechazada | Aprobada y rechazada | Aprobada y rechazada |

El banco `tool/t80_main.dart` prepara fuentes, reproduce cargas y muestra conteos; las solicitudes, la aprobación válida y el rechazo se hicieron desde la interfaz del producto. Su botón exclusivo del muelle fuerza únicamente la prueba negativa de permisos autorizada por Carlos; usa el SDK cliente y verifica la ausencia del documento denegado.

Compilaciones privadas **Windows, APK y Web: correctas**, en una copia externa con `--dart-define=T80_NS=t80acc` y `--dart-define-from-file=C:\Proyectos\baystream-privado\firebase-prod.json`, sin abrir ese archivo. La prueba negativa se añadió al APK antes de instalarlo. Windows informó MSB8029 por compilar dentro de Temp; Web informó falta de la fuente CupertinoIcons. Ambas compilaciones terminaron correctamente; `analyze` final dio cero incidencias. Ninguna compilación Web se publicó: Chrome estuvo visible y abrió únicamente el servidor local `http://127.0.0.1:8083`.

Windows se abrió con explorer.exe, usó el almacén real `C:\Users\Giova\AppData\Local\BayStream\vessel_store` y se cerró por **PID 12620**. Honor: paquete `.t80`, namespace `t80acc`. Las cajas locales conservaron la operación de aceptación de T-79 separada de PRUEBA T-80. Se avisó con SEMÁFORO al reservar y liberar. Se cerraron la variante del Honor, la pestaña propia de Chrome, el servidor local y el emulador.

Evidencia externa, sin copiar corpus ni temporales al repositorio: `%LOCALAPPDATA%\Temp\baystream_t80_acceptance\`. Incluye `honor-pedido-inicial.xml/png`, `honor-negativa.xml/png`, `honor-antes-aprobar.xml/png`, `honor-aprobado.xml/png`, `honor-segundo-pedido.xml/png`, `honor-bandeja-final.xml`, `honor-final.xml/png`, `windows-aprobado.png`, `windows-bandeja-final.png`, `windows-final.png`, `chrome-final.png` y `chrome-bandeja-final.png`. Los logs privados de compilación están en esa misma carpeta. No se usa la captura intermedia de la bandeja del Honor cuyo screencap informó un error del dispositivo; la jerarquía y la captura final posteriores son válidas.

## 6. Horas

Hora de Guatemala, 11-oct-2026. Tiempo de sesión observado, incluida lectura, compilación y esperas; no se reconstruyeron horas de los commits de Timonel.

| Actividad | Inicio | Fin | Horas |
|---|---|---|---|
| Aceptación cruzada T-79 | 15:33:09 | 15:50:47 | **0.29 h**, separadas de T-80 |
| T-80 | 15:50:47 | 16:24:31 | **0.56 h** observadas frente a **6.0 h** estimadas |

## 7. Archivos propios

```text
lib/features/vessel/domain/entities/movement.dart
lib/features/vessel/domain/entities/operation.dart
lib/features/vessel/domain/services/change_requests.dart
lib/features/vessel/domain/services/load_check.dart
lib/features/vessel/domain/services/loading_operation.dart
lib/features/vessel/domain/services/loading_plan_progress.dart
lib/features/vessel/domain/services/operation_state_deriver.dart
lib/features/vessel/presentation/pages/change_requests_page.dart
lib/features/vessel/presentation/pages/operation_progress_page.dart
lib/features/vessel/presentation/providers/loading_operation_provider.dart
lib/features/vessel/presentation/providers/loading_plan_provider.dart
lib/features/vessel/presentation/widgets/bay_plan_view.dart
lib/features/vessel/presentation/widgets/loading_controls.dart
lib/features/vessel/presentation/widgets/loading_plan_controls.dart
test/t72_operation_state_test.dart
test/t80_changes_test.dart
test/t80_requests_widget_test.dart
tool/t79_corpus_test.dart
tool/t80_corpus_test.dart
tool/t80_main.dart
tool/t80_reglas.mjs
docs/T80-firestore.rules.propuesta
docs/T80-RESULTADOS.md
```

**pubspec.yaml y pubspec.lock no cambian.** No se modificaron main.dart, las opciones Firebase ni H5. Los cambios concurrentes de SPRINT-3.md y los entregables de tesis no pertenecen a esta tarea y quedan fuera de su bloque Git. La propuesta de reglas se entrega bajo docs por el alcance explícito de T-80; el otro documento propio es este informe.


## 8. Git para Carlos

Estos comandos son para que Carlos los ejecute; Codex no los ejecutó. Las 23 rutas son propias de T-80, incluida su propuesta de reglas y su informe. No incluyen cambios concurrentes ni binarios privados.

```powershell
git add -- lib/features/vessel/domain/entities/movement.dart
git add -- lib/features/vessel/domain/entities/operation.dart
git add -- lib/features/vessel/domain/services/change_requests.dart
git add -- lib/features/vessel/domain/services/load_check.dart
git add -- lib/features/vessel/domain/services/loading_operation.dart
git add -- lib/features/vessel/domain/services/loading_plan_progress.dart
git add -- lib/features/vessel/domain/services/operation_state_deriver.dart
git add -- lib/features/vessel/presentation/pages/change_requests_page.dart
git add -- lib/features/vessel/presentation/pages/operation_progress_page.dart
git add -- lib/features/vessel/presentation/providers/loading_operation_provider.dart
git add -- lib/features/vessel/presentation/providers/loading_plan_provider.dart
git add -- lib/features/vessel/presentation/widgets/bay_plan_view.dart
git add -- lib/features/vessel/presentation/widgets/loading_controls.dart
git add -- lib/features/vessel/presentation/widgets/loading_plan_controls.dart
git add -- test/t72_operation_state_test.dart
git add -- test/t80_changes_test.dart
git add -- test/t80_requests_widget_test.dart
git add -- tool/t79_corpus_test.dart
git add -- tool/t80_corpus_test.dart
git add -- tool/t80_main.dart
git add -- tool/t80_reglas.mjs
git add -- docs/T80-firestore.rules.propuesta
git add -- docs/T80-RESULTADOS.md
git commit -m "Sprint 3: T-80 roles y solicitudes de cambio"
git push
```

## 9. Resumen y mensaje para Yov

T-79 aceptada: 485 pruebas, 54 reglas, 50 corpus y cinco cargas iguales en Windows y Honor; 0.29 h separadas.
T-80 implementa roles, solicitud, aprobación, rechazo y plan efectivo; 498 pruebas, analyze en cero, 69 reglas y 54 corpus.
Producción convergió en Windows, Honor y Chrome: 180 confirmados, 460/460 posiciones, cero conflictos y permiso de muelle denegado; 0.56 h frente a 6.0 h.

**Mensaje para Yov:** Capitán terminó T-80 y aceptó T-79 por separado. Carlos publicó las reglas T-80 del 11-oct a las 16:08; la producción verificó solicitud 128↔145, aprobación de Windows, segundo pedido rechazado y PERMISSION_DENIED del intento forzado del muelle. Los tres clientes quedaron Al día con 180 confirmados, 460/460 posiciones y cero conflictos. Suite 498, analyze 0, reglas 69/69 y corpus 54/54. Horas: T-79 0.29 h; T-80 0.56 h frente a 6.0 estimadas. Informe y bloque Git en docs/T80-RESULTADOS.md; listo para revisión cruzada de Timonel. Lib y dispositivos libres.

