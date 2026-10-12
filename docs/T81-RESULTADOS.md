# T-81 · Cambios directos de oficina en el plan de carga

Capitán Codex · 11-oct-2026, hora de Guatemala · rama indicada `sprint-3`.

**Estado: En revisión.** Implementación, corpus y aceptación de producción realizados; pendiente de aceptación de Timonel (decisión 10.18). T-80 sigue esperando a Timonel y no se acepta en esta tarea.

## 1. Alcance construido

- La oficina autorizada, sobre una operación publicada y abierta, mueve objetos pendientes del plan de carga con `change_position` sin `request`. El formulario admite una celda nueva, un intercambio y lotes de uno a cuatro cambios, con motivo obligatorio de hasta 300 caracteres.
- Antes de anexar se revisan el origen del plan efectivo, la geometría, el largo 20/40, destinos previstos para otros objetos, la ocupación actual y el grupo de las reservas intercambiadas. Todo el lote se revisa antes de escribir. Los objetos cargados, cancelados, de tránsito o de descarga no se ofrecen para mover o cancelar.
- Cancelar embarque anexa `cancel_item`, conserva el objeto marcado como cancelado, lo excluye de los pendientes y lo cuenta en «Cancelados» de T-78. La oficina deshace movimiento o cancelación con `annul`, con motivo y sin borrar la bitácora.
- Las acciones aparecen desde el detalle de carga, el detalle del contenedor y el de una reserva. El modo «Número de orden» dibuja el plan efectivo y la marca «CANC.» con icono. La proyección se actualiza por el flujo existente de movimientos, sin recargar el archivo.
- El muelle y el modo sin cuenta no ofrecen las acciones de oficina. T-77 informa «Cancelado por la oficina» y bloquea tanto contenedores como reservas cancelados; conserva el bloqueo previo del dominio incluso si se escribe un motivo.
- Al confirmar un diálogo se vuelve a consultar el estado vigente. Una carga recibida mientras estaba abierto impide anexar la cancelación.

No cambian las reglas publicadas. Su SHA-256 sigue siendo `21894B7F43E59F856045473731B795D21F8373C5AC8A1D9FFF324334AC3C9000`. No se ejecutó Firebase CLI, ninguna publicación ni ninguna operación contra el proyecto de H5.

## 2. Validación local

| Comprobación | Resultado ejecutado |
|---|---|
| Suite completa final con T-81 | 508/508, salida 0; piso anterior 498 conservado |
| Nuevas pruebas de dominio y pantalla | 10/10; seis de dominio y cuatro de pantalla |
| Analyze | Cero incidencias, salida 0 |
| Corpus T-68 a T-81 | 56/56, salida 0 |
| Corpus propio T-81 | 2/2; A08 y A08v_VGM |

La suite final incluye el modo Número de orden y la comprobación de ocupación con posiciones de seis cifras normalizadas a siete. La corrida dirigida de dominio y corpus tras esa precisión pasó 8/8.

Las pruebas propias cubren roles y autorización, operación abierta/publicada, motivo vacío o demasiado largo, límites de uno a cuatro cambios, objetos ya operados, geometría, 20/40, ocupación, grupo de reservas, cambio directo sin solicitud, cancelación, deshacer y el bloqueo de T-77. En pantalla se comprobaron 360 dp y ambos temas, cambio de rol en vivo, el diálogo abierto frente a una carga remota y el redibujado en «Número de orden».

La primera corrida dirigida tuvo un error de fixture (`closed` en vez de `closedAt`) y se corrigió. Las pruebas de pantalla necesitaron esperar el redibujado después de escribir el motivo, antes de pulsar el botón. Analyze detectó ocho avisos de llaves después del formato; quedaron corregidos y la corrida posterior dio cero.

Evidencia local: `build/t81/suite-final.log` y `build/t81/analyze-final.log`. Las salidas del corpus están fuera del repositorio: `%TEMP%\t81-corpus-nuevo.log`, `%TEMP%\t81-normalizacion.log` y `%TEMP%\t81-corpus-completo.log`.

## 3. Corpus

Se leen directamente A08, A08v_VGM, LISTADO_A08.xlsx, los 177 eventos y el CSV final desde la carpeta externa autorizada. No se crean almacenes ni se copian fuentes o temporales al repositorio.

En ambas variantes:

- El estado inicial tiene 176 cargas pendientes. Cancelar OR 5 deja **175**, con **1 cancelado** en T-78. T-77 bloquea su carga.
- OR 1 se mueve a una celda libre compatible elegida mediante la misma validación de dominio. Su carga queda allí sin conflicto. Al reproducir el caso omitiendo OR 5 y usando la posición nueva de OR 1, quedan **459 posiciones**, **0 pendientes**, **1 cancelado** y **0 conflictos**; la celda de OR 5 queda vacía.
- Anular ambos cambios **antes de las cargas** restaura el plan original y permite reproducir el caso con **460/460 posiciones**, **0 pendientes**, **0 cancelados** y **0 conflictos**.
- También se comprueba deshacer **después de cargar**. `annul` restaura la posición del plan; no mueve físicamente la carga ya registrada. Queda **1 pendiente** (OR 5) y el OR 1 queda fuera de plan. Cargar OR 5 y corregir OR 1 con `corrects` devuelve **460/460**, sin conflictos. Se conserva toda la historia.
- Cada resultado se compara en orden cronológico, inverso y mezclado con semilla fija. El intercambio 128↔145 del caso se registra como cambio directo de oficina para regularizar esas dos cargas.

## 4. Producción

Aceptación ejecutada contra **baystream-app**, en «PRUEBA T-81 · VIAJE007A · GTSTC», operación abierta. Windows y Chrome usan oficina; el Honor usa muelle. Carlos introdujo las credenciales. Banco propio: `tool/t81_main.dart`; prepara las fuentes de carga y listado, muestra conteos derivados y abre los detalles del producto. Los cambios se hicieron desde la interfaz real, con motivo «prueba».

| Paso | Resultado observado |
|---|---|
| Estado inicial | 176 pendientes, 0 cancelados, 0 conflictos |
| Windows mueve OR 1, 20:01 | 022-04-02 → 006-10-02, celda libre compatible; 176 pendientes, 0 conflictos. Honor y Chrome reciben la posición sin recargar. En Número de orden, Chrome pasa de 28 a 29 contenedores en BAY 06 |
| Windows cancela OR 5, 20:04 | 175 pendientes, 1 cancelado, 0 conflictos. T-78 abierto en Honor actualiza a 119 llenos y 56 vacíos pendientes; Chrome confirma Cancelados 1 |
| Honor intenta cargar OR 5 | El selector «OR / últimos dígitos» abre el detalle cancelado con el bloqueo de T-77; no ofrece confirmar carga ni acciones de oficina. Siguen 2 registros confirmados: un movimiento y una cancelación |
| Cancelación forzada desde muelle | **PERMISSION_DENIED**, documento ausente tras lectura del servidor, sin registro local. Se usó el SDK cliente con `receivedAt` del servidor, sin administrador |
| Oficina anula la cancelación, 20:14 | OR 5 vuelve a pendiente; 176 pendientes, 0 cancelados, 0 conflictos. Honor recibe 3 registros confirmados; T-78 ya abierto en Chrome vuelve a 120 llenos y 56 vacíos sin recargar |
| Oficina anula el movimiento, 20:15 | OR 1 vuelve a 022-04-02. Windows, Honor y Chrome terminan con **4 registros, 4 ids distintos y 4 confirmados**: `changePosition 1`, `cancelItem 1`, `annul 2`; 176 pendientes, 0 cancelados, 0 conflictos |
| Reapertura de Windows | Se cierra por PID, se abre de nuevo mediante explorer.exe y se recupera PRUEBA T-81 desde Viajes recientes. Conserva los cuatro registros confirmados y el plan restaurado |

No se recargó Honor ni Chrome durante los movimientos y anulaciones. La recarga de Chrome para tomar la compilación final fue anterior a los cambios. No se registraron cargas en producción: la reproducción de las 460 posiciones corresponde al corpus. La marca «CANC.» en el plano también se verifica en la prueba de pantalla; la evidencia manual de cancelación se tomó en T-78 y en el detalle bloqueado.

La copia privada está en `C:\Proyectos\baystream-privado\t81-aceptacion`. Assets y compilaciones permanecen fuera del repositorio. Las tres compilaciones finales release —Windows, APK y Web local— terminaron correctamente, usando `--dart-define-from-file=C:\Proyectos\baystream-privado\firebase-prod.json` sin abrir ni imprimir ese archivo y namespace `t81acc`. La variante Android es `gt.cmartinez.baystream.t81`; Chrome estuvo visible en `http://127.0.0.1:8084`, servido solo por localhost, sin publicación Web.

Windows se abrió mediante `Start-Process explorer.exe -ArgumentList <exe>`. PIDs observados: 26648 (primera compilación), 22668 (compilación final) y 24308 (reapertura); las instancias se cerraron únicamente por su PID. El almacén real usado y comprobado es `C:\Users\Giova\AppData\Local\BayStream\vessel_store`, archivos `t81acc_*.hive`, incluido el registro de movimientos. No se usó LocalCache del paquete. Honor, Windows y el servidor local quedaron cerrados; se liberó el semáforo.

Evidencias fuera del repositorio, en `C:\Proyectos\baystream-privado\t81-aceptacion\evidence`: `windows-movido.png`, `windows-cancelado.png`, `windows-final.png`, `windows-reabierto.png`; `chrome-movido.png`, `chrome-cancelado-avance.png`, `chrome-anulada-cancelacion.png`, `chrome-final.png`; y pares XML/PNG `honor-movido`, `honor-cancelado-avance`, `honor-carga-bloqueada`, `honor-negativa`, `honor-dos-registros`, `honor-anulada-cancelacion`, `honor-final-cuatro`. Los logs privados de compilación son `windows-final-build.log`, `apk-final-build.log` y `web-final-build.log`.

## 5. Horas e incidencias

Inicio observado: **11-oct-2026, 18:09:46**, hora de Guatemala. Cierre de la aceptación y liberación: **20:18:17**. Tiempo transcurrido: **2 h 08 min 31 s (2.14 h)** frente a **4.0 h** estimadas; incluye la interrupción por límite de tokens y no equivale a horas de trabajo efectivo.

Tiempo de trabajo documentado mínimo: **0.84 h**, sumando 18:09:46–18:40:55 (última evidencia con hora antes de la interrupción) y 19:59:09–20:18:17 (reanudación y cierre). Hubo algo de trabajo después de aquella evidencia y la redacción final del informe; esos minutos no se cronometraron por separado. No se atribuye toda la pausa al trabajo ni se inventa una duración activa exacta.

Se lanzó una prueba adicional de Flutter mientras todavía compilaba Windows en la copia privada. Fue un incumplimiento del acuerdo de un comando Flutter a la vez. Ambos comandos terminaron correctamente; desde ese momento los comandos se ejecutan en serie. No se forzó ningún bloqueo ni se borró ningún archivo de bloqueo.

Los cuatro entregables de tesis que ya tenían cambios al entrar se preservaron y quedan fuera de esta tarea.

Durante la primera inspección del Honor tras el acceso manual, el aviso de guardar contraseña mostró un correo en la salida de la herramienta. Se informó a Carlos; no se repite ni se incluyó en el informe o las evidencias. Se borró el XML temporal del dispositivo y Carlos cerró el aviso. Las inspecciones posteriores omiten formularios de acceso y avisos con correo/contraseña antes de emitir texto o guardar evidencia. El borrado del temporal no elimina la salida ya producida en la conversación.

## 6. Archivos propios

```text
lib/features/vessel/domain/entities/movement.dart
lib/features/vessel/domain/services/change_requests.dart
lib/features/vessel/domain/services/load_check.dart
lib/features/vessel/domain/services/loading_operation.dart
lib/features/vessel/presentation/pages/change_requests_page.dart
lib/features/vessel/presentation/widgets/bay_plan_view.dart
lib/features/vessel/presentation/widgets/loading_controls.dart
lib/features/vessel/presentation/widgets/office_plan_controls.dart
lib/features/vessel/presentation/widgets/reserved_slot_details.dart
test/t81_office_changes_test.dart
test/t81_office_widget_test.dart
tool/t81_corpus_test.dart
tool/t81_main.dart
docs/T81-RESULTADOS.md
```

**pubspec.yaml y pubspec.lock no cambian en el repositorio.** No cambian main.dart, los archivos congelados, las opciones Firebase, las reglas, AGENTS.md ni SPRINT-3.md. La copia privada añade solo la declaración de assets externos y el applicationId `.t81` para las compilaciones de aceptación.

## 7. Git para Carlos

Los comandos son para Carlos. Codex no los ejecuta. La única ruta bajo `docs/` es el informe propio de esta tarea; no se incluyen los cambios concurrentes de tesis.

```powershell
git add -- lib/features/vessel/domain/entities/movement.dart
git add -- lib/features/vessel/domain/services/change_requests.dart
git add -- lib/features/vessel/domain/services/load_check.dart
git add -- lib/features/vessel/domain/services/loading_operation.dart
git add -- lib/features/vessel/presentation/pages/change_requests_page.dart
git add -- lib/features/vessel/presentation/widgets/bay_plan_view.dart
git add -- lib/features/vessel/presentation/widgets/loading_controls.dart
git add -- lib/features/vessel/presentation/widgets/office_plan_controls.dart
git add -- lib/features/vessel/presentation/widgets/reserved_slot_details.dart
git add -- test/t81_office_changes_test.dart
git add -- test/t81_office_widget_test.dart
git add -- tool/t81_corpus_test.dart
git add -- tool/t81_main.dart
git add -- docs/T81-RESULTADOS.md
git commit -m "Sprint 3: T-81 mover y cancelar pendientes desde oficina"
git push
```

## 8. Tres líneas y mensaje para Yov

La oficina mueve y cancela pendientes con motivo, y deshace ambos cambios mediante annul.
Corpus: 175 pendientes al cancelar OR 5 y 460/460 tras anular, en tres órdenes; suite 508, analyze cero, corpus 56.
Producción: Windows, Honor y Chrome sincronizados; carga cancelada bloqueada y cancel_item del muelle denegado; En revisión.

**Mensaje para Yov:** T-81 quedó En revisión para Timonel, según 10.18. Implementé cambios directos de oficina de uno a cuatro objetos, cancelación y annul, con validación del plan efectivo y bloqueo de T-77. Pasaron 508 pruebas, analyze cero y 56 pruebas de corpus; A08 y A08v recuperan 460/460 en tres órdenes. En baystream-app, Windows movió OR 1 y canceló OR 5; Honor y Chrome recibieron sin recargar, el Honor no pudo cargar el cancelado y el cancel_item forzado del muelle dio PERMISSION_DENIED sin documento ni registro local. Se anularon ambos cambios y los tres clientes terminaron con cuatro registros confirmados y cero conflictos; Windows los conservó al reabrir. Reglas, main.dart, H5 y dependencias intactos. T-80 continúa pendiente de Timonel. Informe propio y bloque Git en docs/T81-RESULTADOS.md; incidencias y limitación del cronometraje declaradas allí.
