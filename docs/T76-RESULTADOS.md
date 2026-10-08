# T-76 · Carga desde el listado y plan combinado

**Responsable:** Capitán Codex. **Rama de trabajo:** `sprint-3`.
**Fecha de trabajo:** 7–8 de octubre de 2026, hora de Guatemala.
**Estado:** implementación verificada; Windows aceptado. Honor y Chrome
pendientes de completar por interrupción de la automatización. **T-76 no se
declara terminada.** Corte: 8-oct, 08:21, Guatemala.

## 1. Aceptación cruzada de T-75

Aceptado el trabajo de Timonel, `4bfa268`, antes de implementar T-76.
No se encontró discrepancia con su ficha ni se corrigió código de T-75.

### 1.1. Cifras y corpus

A07 en GTSTC comienza con **114 pendientes: 66 en cubierta y 48 en bodega**.

| Bahía del BAPLIE | Cubierta | Bodega |
|---|---:|---:|
| 003 | 3 | 0 |
| 014 | 19 | 16 |
| 021 | 0 | 12 |
| 022 | 20 | 8 |
| 023 | 0 | 12 |
| 030 | 24 | 0 |
| Total | 66 | 48 |

Los corpus anteriores dieron **28/28**, con A08 y A08v. El de T-75
registró las 114 descargas: quedaron 0 pendientes. Las 114 anulaciones
devolvieron los 114 pendientes y conservaron **228 movimientos**. Una
re-estiba aparte dejó **229 movimientos**, sin alterar esos pendientes.
La suite inicial dio **420/420** y `flutter analyze` no encontró incidencias.

### 1.2. Tres clientes

En Windows, Honor a 360 dp y Chrome se comprobaron los conteos, una bahía
completa, Deshacer inmediato, Deshacer desde el detalle, re-estiba confirmada
y reapertura con persistencia. La bahía 003 completa deja **111 pendientes
(63/48)** y 3 descargas normales. La re-estiba se cuenta aparte.

| Cliente | Estado conservado al reabrir | Bitácora |
|---|---|---:|
| Windows, oscuro | 112 pendientes (64/48), 2 descargas + 1 re-estiba | 7 |
| Honor, oscuro, 360 dp | 111 pendientes (63/48), 3 descargas + 1 re-estiba | 8 |
| Chrome visible, oscuro | 112 pendientes (64/48), 2 descargas + 1 re-estiba | 7 |

La diferencia final entre clientes corresponde a los deshacer ejercitados,
no a una diferencia de cálculo. En el Honor se repitió una marca para probar
el aviso inmediato dentro de su plazo. Se conservaron una operación, sus
tres fuentes y su identidad al reabrir.

Almacenes de aceptación, todos con namespace **`t76acc`**:

- Windows: `%LOCALAPPDATA%\BayStream\vessel_store`, fuera del paquete de
  Codex. Se abrió mediante `Start-Process explorer.exe -ArgumentList <exe>`
  y se cerró por el PID comprobado.
- Honor: `/data/user/0/gt.cmartinez.baystream.t76/files/vessel_store`.
  Solo se instaló y operó la variante `.t76`, en 720 × 1600 px, densidad 320.
- Chrome: IndexedDB del origen local `http://127.0.0.1:8796`, con la ventana
  visible. No se usó `flutter test --platform chrome`.

**Tiempo de aceptación:** aproximadamente **0.40 h**, separado de T-76.
Se excluyen las pausas por créditos: primer tramo 17:42:56–17:52:15
(cierre estimado por la última evidencia) y segundo tramo 21:28:10–21:42:43.

## 2. Implementación de T-76

- Modo **Carga**, con las fuentes de llegada, carga y listado de la misma
  operación. El plano muestra las posiciones de carga; el estado y ambos
  avances se derivan del plan combinado.
- Llenos y el vacío numerado OR 85: tocar la celda o buscar OR/sufijo,
  resaltar su posición y confirmar `load_full`. Solo se admite la posición
  planificada. Una búsqueda ambigua conserva las coincidencias para elegir.
- Vacíos del listado: `assign_empty` con OR, contenedor y tara real. Solo
  se ofrecen reservas libres del mismo tipo, puerto y línea, con las de la
  bahía actual primero. Al asignar, la celda muestra el OR.
- Hora y marchamo opcionales. La hora omitida se guarda como `operatedAt`
  igual a `createdAt`, también cuando el movimiento se registra fuera de la
  pantalla. Una hora explícita conserva fecha y hora; formato inválido no
  escribe. El marchamo usa `seal`.
- Deshacer inmediato y desde detalle anexa `annul`; el detalle pide motivo.
  Corregir anexa una sola carga con `payload.corrects` y motivo.
  No se edita ni borra la bitácora. No se agrega `cancel_item` a esta UI.

### 2.1. Dos reglas del derivador

**Descarga posterior a carga.** Se determina primero qué ocupantes de llegada
tienen una descarga vigente y se liberan sus celdas. Luego se aplican los
movimientos en el orden total existente. Una descarga anulada o rechazada
por cancelación no libera la celda. Si falta la descarga, sigue el conflicto
«celda ocupada». Dos cargas nuevas que compiten por la misma celda siguen
en conflicto; no se oculta la colisión.

**Cadena de correcciones, confirmada por Carlos.** La regla anterior de T-72
podía revivir A al corregir A→B→C. Se amplió la vigencia para que una
corrección sustituya toda su cadena anterior. C queda vigente; anular C
restaura B; anular esa anulación restaura C. La validación previa de una
corrección retira la cadena sustituida sin escribir movimientos ficticios.
Esta decisión fue consultada y autorizada expresamente durante T-76.

## 3. Validación automatizada

La suite completa da **437/437**, por encima del piso de 420, y
`flutter analyze --no-pub` da **cero incidencias**. Son 17 pruebas nuevas:
15 de dominio/persistencia y dos recorridos de pantalla a 360 dp, en claro
y oscuro. Cubren orden de registro y entrega, ocupación sin descarga,
anulación de descarga, cancelación, colisiones entre cargas, duplicados,
restricción de grupos, OR/sufijo, OR 85, navegación a bahía par, corrección
de vacío, cadenas de correcciones, hora opcional y persistencia.

Comandos ejecutados desde el proyecto:

```powershell
flutter test --reporter expanded
flutter analyze --no-pub
flutter test tool/t68_corpus_test.dart tool/t69_corpus_test.dart tool/t72_corpus_test.dart tool/t73_corpus_test.dart tool/t74_corpus_test.dart tool/t75_corpus_test.dart tool/t76_corpus_test.dart '--dart-define=BAYSTREAM_CORPUS_DIRECTORY=<carpeta externa>' --reporter expanded
```

Los corpus T-68, T-69, T-72, T-73, T-74, T-75 y T-76 dieron **36/36**.
T-70 y T-71 no aportan scripts de corpus a esta batería.

### 3.1. Corpus de carga

El script nuevo lee directamente la carpeta externa y abre sus almacenes
temporales con `Directory.systemTemp`; cierra y reabre antes de comprobar.
Ejercita A08 y A08v_VGM en cuatro escenarios, **8 pruebas**:

| Escenario por variante | Registros persistidos | Posiciones iguales al CSV | Celda ocupada |
|---|---:|---:|---:|
| Solo los 176 eventos de carga, sin intercambio | 176 | 460 | 0 |
| Todas las cargas antes de las 114 descargas | 290 | 460 | 0 |
| Todas las descargas antes de las cargas | 290 | 460 | 0 |
| Descargas y cargas intercaladas, cargas en orden inverso | 290 | 460 | 0 |

En todos: carga pendiente 0; en el plan combinado, descarga pendiente 0;
**OR 12 en `R:0030984`, tara 2 185 kg**. No hay discrepancias de ocupación
con el CSV: los eventos de carga ya contienen las posiciones finales de
los OR intercambiados. Quedan exactamente dos conflictos **fuera de plan**,
en **014-01-02 y 014-01-08**, porque no se reproduce el evento de cambio de
posición, reservado para T-80. Es la misma distinción documentada en T-72.

## 4. Aceptación T-76 en clientes

Las compilaciones y las pantallas usan una copia privada del
proyecto en `%TEMP%\baystream_t76_acceptance`, con los archivos de producción
de esta tarea. El banco privado prepara las fuentes; las interacciones de
carga se hacen en los controles de producción.

Las tres compilaciones release terminaron correctamente: Windows, APK y
Web, con el entrypoint privado `lib/t76_client_acceptance.dart`. Se verificó
por hash que los siete archivos de producción modificados coinciden con el
repositorio. Los avisos de compilación son el MSB8029 por usar el temporal
en Windows y el aviso de fuente Cupertino ausente en Web; no son incidencias
de `analyze` ni se agregaron dependencias para silenciarlos.

### 4.1. Windows: aceptado

- Comienza con carga 176 (120/56) y descarga 112 (64/48), más una re-estiba
  conservada de la aceptación de T-75.
- La búsqueda del OR 1 selecciona y resalta su celda en la bahía real 22.
  Se cancela ese diálogo sin registrar; no se elige una posición alternativa.
- Se confirma el lleno OR 3 en 025-06-02: quedan 175 pendientes (119/56).
  Deshacer desde el detalle, con «Marcado por error», devuelve 176.
- Se repite la carga tocando la celda y se prueba Deshacer inmediato: vuelve
  a 176. La primera tentativa del aviso inmediato había expirado durante
  la automatización; se repitió y se comprobó el resultado.
- Buscar por el sufijo del contenedor encuentra el mismo OR 3. Se confirma
  con hora operada **08-oct 02:45** y marchamo de prueba `w1`; el detalle
  diferencia esa hora de la hora de registro.
- Corregir a `w2`, motivo `ajuste`, conserva la hora y mantiene una carga
  vigente. El detalle muestra el marchamo y el motivo nuevos.
- OR 12 ofrece solo cinco reservas libres de su grupo: primero las tres
  de la bahía 25 que se estaba viendo, luego las dos de la bahía 03. Se
  elige **003-09-84**, con **2 185 kg**, sin hora ni marchamo. Quedan
  **174 pendientes (119 llenos / 55 vacíos)**; en la celda aparece OR 12.
- Cierre por PID y reapertura mediante Explorer: **14 movimientos**, una
  operación, tres fuentes, mismos 174 pendientes. El detalle del OR 12
  conserva celda, tara y hora por omisión. Se cierra el PID 35248 al terminar.

Almacén real y namespace: los declarados en 1.2. Evidencias externas:
`t76-windows-correccion.png`, `t76-windows-reapertura.png` y
`t76-windows-or12.png`.

### 4.2. Honor a 360 dp: aceptación parcial

Instalada únicamente la actualización de `.t76`. Se recuperan las tres
fuentes y los 8 movimientos anteriores. Carga muestra 176 (120/56),
descarga 111 (63/48), más una re-estiba.

Buscar por OR y confirmar OR 3 deja 175 (119/56); la celda muestra OR 3
y CARG. legibles a 360 dp. El Deshacer inmediato vuelve a 176 y a SUBE.
Buscar por sufijo vuelve a ofrecer exclusivamente ese contenedor y abre
su confirmación en la posición planificada.

Al introducir los opcionales, una captura posterior mostró «Opciones del
desarrollador» del teléfono. Se pausaron los toques y se pidió a Carlos
confirmar que el Honor está libre. No se dan por ejecutadas esas entradas:
el volcado de accesibilidad falló con `could not get idle state` y conservó
un XML anterior; se usó la captura actual para detectar el cambio de app.
**Faltan:** opcionales, corrección, deshacer desde detalle, OR 12 y reapertura.
Evidencia válida: `t76-h10-carga.png`; XML hasta `t76-h14.xml`.

### 4.3. Chrome: aceptación pendiente

La nueva compilación carga y recupera la operación con tres fuentes y los
7 movimientos de T-75 en IndexedDB. No se han registrado cargas de T-76.
El menú quedó dibujándose parcialmente; se intentó traer la ventana al
frente para cumplir la regla de Chrome visible.

La herramienta Computer Use detuvo el turno porque no pudo determinar
con suficiente confianza la URL actual de la ventana de Chrome para
aplicar su política. Se dejó de automatizar, sin intentar eludir el bloqueo.
**Falta el recorrido de carga completo y su reapertura en Chrome.** No se
ha sustituido esta aceptación por `flutter test --platform chrome`.

## 5. Evidencias, privacidad y alcance

- Evidencias con el corpus, capturas y binarios: exclusivamente
  `%TEMP%\baystream_t76_acceptance\evidence` y el `build` de esa copia privada.
- Logs sin datos del corpus: `build/t76/` del proyecto, ignorado por Git.
- **Incidencia declarada:** al iniciar la aceptación, una salida del corpus
  T-72, que imprime identificadores anonimizados, se redirigió por error a
  `build/t76/t75-aceptacion-corpus.txt`. Se movió inmediatamente ese archivo
  al temporal del sistema. No se copiaron fuentes del corpus ni almacenes al
  repositorio. Las corridas posteriores redirigen la salida fuera del repo.
- Las compilaciones usan `--dart-define-from-file` con la ruta privada
  indicada por Carlos. No se abrió ni imprimió su archivo de configuración.
- `lib/main.dart`, congelados H5 y configuración Firebase sin cambios.
  **`pubspec.yaml` y `pubspec.lock` sin cambios; sin dependencias nuevas.**
- Sin Git de escritura, sin `git status`, sin publicación ni despliegue.
  Los cambios ajenos en SPRINT-3 y los entregables de tesis se dejan intactos.

## 6. Horas y entrega

T-76 lleva aproximadamente **0.73 h de trabajo activo**, frente a **5.0 h
estimadas**; duración final pendiente al completar Honor y Chrome.
Tramos: 7-oct 21:49:56–≈22:15 (último artefacto de compilación, cierre
aproximado); 8-oct 02:51:16–03:02:36; 8-oct 08:13:55–≈08:21.
Se excluyen las interrupciones por créditos/límite de sesión y la espera
entre 03:02 y 08:13. Los límites aproximados se declaran como tales.
La aceptación cruzada de T-75 se contabiliza aparte (≈ 0.40 h).

Rutas propias para la entrega:

1. `lib/features/vessel/data/repositories/movement_log_repository_impl.dart`
2. `lib/features/vessel/domain/services/operation_state_deriver.dart`
3. `lib/features/vessel/domain/services/loading_operation.dart`
4. `lib/features/vessel/presentation/providers/loading_operation_provider.dart`
5. `lib/features/vessel/presentation/widgets/loading_plan_controls.dart`
6. `lib/features/vessel/presentation/widgets/loading_controls.dart`
7. `lib/features/vessel/presentation/widgets/bay_plan_view.dart`
8. `test/support/t76_fixture.dart`
9. `test/t76_loading_test.dart`
10. `test/t76_loading_widget_test.dart`
11. `tool/t76_corpus_test.dart`
12. `docs/T76-RESULTADOS.md`
