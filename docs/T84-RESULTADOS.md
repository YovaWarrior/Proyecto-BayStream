# T-84 · Quitar y reponer tapas en la operación

Capitán Codex · 12–13-oct-2026 · rama `sprint-3`.

**Estado: En revisión.** Implementación y aceptación propia completadas en corpus,
producción y los tres clientes. Carlos inició la sesión de muelle; el APK final
conservó la sesión y el almacén. La aceptación cruzada por Timonel sigue pendiente
conforme a 10.18; Capitán no declara la aceptación de Timonel.

## Resultado

Las tapas se operan desde el icono «Tapas en la operación» del selector del plano
y desde Avance. Muelle y oficina registran hechos, sin solicitar ni aprobar.
La automática usa número 1; las de grúa conservan T1–T3. La bahía y el número
viajan en `target: T:bahía-número`; el payload nuevo solo lleva
`action: remove|replace`. Se conservan los nueve tipos de movimiento.

El estado se deriva de la misma bitácora, después de resolver anulaciones y
correcciones y ordenar los movimientos. Quitar dos veces y reponer sin quitar
producen conflictos; no cambian el estado aplicado ni se cuentan como duplicados
inocuos. La pantalla permite deshacer el movimiento vigente y el conflicto con
`annul` y motivo, respetando el rol del movimiento anulado. Las tapas no forman
parte de `items` ni de la ocupación de contenedores.

Al confirmar carga o descarga de bodega bajo su tapa puesta, el aviso nombra la
tapa y la bahía, marca **PROVISIONAL**, ofrece «Quitar tapa y continuar» o
«Seguir sin quitarla». También se puede cancelar. No exige motivo ni bloquea por
la declaración provisional. No avisa en cubierta, en filas no cubiertas, con la
tapa quitada, con bodega abierta ni en una bahía sin declarar.

El toque combinado anexa primero la tapa y luego el movimiento de contenedor;
si T-77 requiere descargar al ocupante, anexa tapa → descarga → carga. Deshacer
inmediato anula todos los movimientos de ese toque, en orden inverso. Como el par
de T-77, son escrituras consecutivas durables, no una transacción conjunta.

El avance añade tapas declaradas, actualmente quitadas y repuestas, agrupadas
como las bahías del plano. «Repuestas» cuenta tapas cuyo último movimiento
aplicado es reponer: volver a quitarla retira ese conteo. Una tapa inicial puesta
no se cuenta como repuesta. Conflictos y anulaciones de tapas se atribuyen a su
bahía; el último movimiento las incluye. La tabla amplia admite desplazamiento
horizontal y las tarjetas de 360 dp muestran los conteos completos.

En una operación publicada manda el perfil publicado; en una local, el perfil
publicado en la vista del dispositivo. No se usa el borrador de una edición.
Pendientes y confirmados cuentan; los rechazados se excluyen también en descarga.
Sin cuenta, el repositorio conserva el movimiento solo local. La cola y los
adaptadores de T-79 hacen el envío: no hay un canal especial para tapas.

## Corpus

`tool/t84_corpus_test.dart` solo lee la carpeta externa autorizada. No copia
fuentes, temporales ni salidas al repositorio.

- A08 y A08v_VGM: **460/460 posiciones** del CSV, cero conflictos y cero pendientes
  de carga y descarga.
- Declaraciones **PROVISIONALES** de prueba en las **21 bahías con evidencia de
  bodega** de A07/A08; alternan tres tapas de grúa y una automática. No representan
  tapas reales del buque.
- Tres órdenes reales de trabajo por bahía: ascendente, descendente y mezclado
  con semilla 84. En cada bahía se intercalan quitar → trabajar → reponer.
- Para cada bitácora, tres órdenes de entrega: cronológico, inverso y mezclado.
- Cada retirada/reposición conserva exactamente la ocupación anterior.
- El avance total y por bahía se coteja en **cada prefijo** con los conjuntos
  independientes de tapas quitadas/repuestas del guion.
- Se incluyen el intercambio del caso, las 176 cargas y las 114 descargas.

**Corpus completo final: 102/102**, los 100 anteriores más los dos casos T-84.
A06 conserva su rechazo SMDG15; los corpus históricos y los del sprint siguen
verdes. Registro: `%TEMP%\t84-corpus-final.log`.

## Pruebas y reglas

- Suite final: **580/580**, frente al piso 563; **17 nuevas**.
- Dominio, cola y codec: **13/13**; widgets T-84: **4/4**.
- `flutter analyze`: **0 incidencias**.
- Reglas publicadas T-80, batería sin modificaciones: **69/69**, emulador
  1.22.0 en `127.0.0.1:8184`, proyecto `demo-t84`.
- La prueba de cola usa Hive real en el temporal del sistema: pendiente,
  cierre/reapertura, envío al segundo cliente, reposición de vuelta y movimiento
  sin cuenta solo local. Es un servidor simulado; no se presenta como producción.
- La prueba anterior de T-72 se reescribe: la tapa sin declarar ahora produce
  `invalidHatchCover` en vez de quedar sin derivar. Conserva la comprobación del
  cambio inválido; ninguna prueba se borra ni se omite.

Registros en `%TEMP%`: `t84-suite-final.log`, `t84-analyze-final.log`,
`t84-codec.log`, `t84-widgets-corpus.log`, `t84-layout.log` y `t84-reglas.log`.
Los mensajes de Hive de caja cerrada que aparecen en la suite ya estaban en el
registro de T-83; no corresponden a pruebas fallidas.

SHA-256 de `docs/T80-firestore.rules.propuesta`, sin cambio:
`21894B7F43E59F856045473731B795D21F8373C5AC8A1D9FFF324334AC3C9000`.
Es el archivo que Carlos publicó el 11-oct; no se releyeron reglas con credenciales
de administrador ni desde la consola. No se modifica ningún archivo de reglas.

El primer arranque del emulador falló al cargar reglas por un recurso de idioma
ausente (`es_ES`). Se cerró su PID propio y se arrancó el mismo JAR con
`-Duser.language=en -Duser.country=US`: la misma batería dio 69/69. No hubo Firebase CLI.

## Incidencia hallada en la publicación y corrección

Los dos intentos anteriores a la corrección cerraron Windows el 12-oct a
**23:43:52** y **23:49:05**. Event ID 1000: `KERNELBASE.dll`, excepción
`0xe06d7363`; PIDs propios 4852 y 34088. Los cinco registros locales sobrevivieron.
No se obtuvo una pila nativa que identifique la instrucción exacta de la caída.

El perfil de T-83 usa `covers: [[filas], [filas]]` en su JSON local.
[Firestore Standard no admite arrays dentro de arrays](https://firebase.google.com/docs/firestore/manage-data/data-types).
La publicación de T-79 enviaba ese JSON directamente al SDK. T-84 corrige esa
incompatibilidad en **data/** con `FirestoreProfileCodec`: solo al viajar, `covers`
es un mapa `{1: [filas], 2: [filas]}` con claves de texto. Al recibirlo se reconstruye
la lista por número, sin depender del orden del mapa. Sigue leyendo los perfiles
históricos y el JSON local. Numeraciones con huecos se rechazan.

Las reglas exigen `profile is map` y admiten esta representación; no cambian
esquema de movimientos ni payloads. La suite prueba la ausencia de arrays
anidados, la ida/vuelta idéntica, compatibilidad y orden de T1/T2. El JSON de Hive,
el editor de T-83 y el dominio no cambian su representación por esta corrección.

Con el codec y la fuente final recompilada, **Windows publicó «PRUEBA T-84» con
las tres fuentes y el perfil de tapas, quedó «Al día» y siguió abierto**. Esto
corrobora la corrección de la incompatibilidad; no convierte el evento nativo
anterior en una traza de causa definitiva.

## Clientes y producción

Banco reproducible: `tool/t84_main.dart`, solo datos sintéticos TSTU. Usa los
notifiers, repositorios, avisos, página de tapas y avance del producto. No prueba
el selector nativo de archivos. Comprueba `baystream-app` antes de inicializar
Firebase; no incluye credenciales ni assets del corpus.

**Windows, aceptación local:** aviso de T1 puesta; continuar con la tapa puesta
registra descarga; quitar T1, quitar otra vez → conflicto; anular el sobrante →
sin conflicto; reponer → avance 3 declaradas / 0 quitadas / 1 repuesta y último
movimiento de tapa. Cierre por PID y reapertura conservan cinco registros.
Abierto por `Start-Process explorer.exe -ArgumentList <exe>`.
Almacén real comprobado: `C:\Users\Giova\AppData\Local\BayStream\vessel_store`,
cajas `t84acc_*`. La cuenta de oficina ya tenía una sesión persistida; no fue
necesario entrar credenciales en Windows.

**Honor, aceptación local anterior al codec:** solo `.t84`, **720×1600 px,
densidad 320, 360×800 dp**. Aviso de T1 completo; «Quitar tapa y continuar» deja
dos registros, T1 quitada y cero conflictos. Reponer T1; reponer T2 sin quitar
→ conflicto legible; «Deshacer conflicto» con motivo → sin conflicto. Avance
3 declaradas / 0 quitadas / 1 repuesta, último `annul` en bahía 03. Cierre forzado
solo de `.t84` y reapertura conservan cinco registros. Almacén privado de la
variante, namespace `t84acc`. El intento de usar el Deshacer fugaz llegó después
de que caducara: no se atribuye una aceptación de ese toque en el teléfono; el
deshacer del par sí pasó la prueba de widget. **El APK final se instaló con `-r`
después de la entrada manual de Carlos; conservó la sesión de muelle y los cinco
registros locales.** Se reabrió el almacén, se unió a PRUEBA T-84 y abrió la fuente
publicada de llegada; recibió las mismas tres tapas y T2 quitada por oficina.

**Chrome visible:** conector seleccionó una pestaña nueva y verificó el origen
local `http://127.0.0.1:8094/`. No hubo bloqueo de política ni se pidió controlar
la pestaña de T-83 de Carlos. Aviso, par tapa + descarga, doble retirada,
conflicto, `annul`, reposición, avance y último movimiento pasaron. La Web final
recompilada se recargó y reabrió IndexedDB: cinco registros, T1 repuesta y cero
conflictos. Namespace `t84acc`, sin cuenta. La pestaña inicial se abrió por error
en 8084, donde existía otro servidor; se corrigió a 8094 antes de actuar sobre
el caso. No se modificó ni se cerró el servidor ajeno.

**Producción: aceptación entre roles completada en `baystream-app`.** La operación
sintética «PRUEBA T-84» está publicada con llegada, carga, listado y las tapas
PROVISIONALES. Los cinco movimientos de Windows anteriores a publicar siguen
locales, como declara la app; no se presentan como movimientos enviados.

| Paso compartido | Operador y cliente | Hecho observado en el otro cliente |
|---|---|---|
| 1 | Oficina / Windows, 00:01 | Quita T2; el Honor la recibe al unirse |
| 2 | Muelle / Honor, 00:14 | Quita T1; Windows pasa a T1 quitada y 7 registros, sin recargar |
| 3 | Oficina / Windows, 00:15 | Repone T2; la página abierta del Honor pasa a repuesta |
| 4 | Oficina / Windows, 00:15 | Quita T2; la misma página del Honor pasa a quitada, sin recargar |
| 5 | Oficina / Windows, 00:16 | Repone T1; el Honor recibe T1 repuesta |
| 6 | Muelle / Honor, 00:16 | Repone T2; Windows recibe T2 repuesta |

Al terminar, ambos están **Al día y sin conflictos**. Honor muestra **6 registros
compartidos**; Windows **11 registros**, los mismos 6 compartidos más sus 5 locales.
El estado de tapas coincide: T1 y T2 repuestas, automática puesta. Avance total
**3 declaradas / 0 quitadas / 2 repuestas**; bahía 03 **2/0/2**, bahía 05 **1/0/0**,
bahía 07 **0/0/0**. Último movimiento: reponer T:3-2, muelle, 00:16.
Windows conserva una descarga local que el Honor no tiene; el avance de
contenedores refleja esa diferencia local y no se atribuye a sincronización.
Ningún movimiento de tapa fue rechazado por las reglas publicadas.

Carlos escribió las credenciales. Durante su entrada no se observó la pantalla.
Al retomar tras su aviso, un diálogo inesperado de Google para guardar contraseña
entró en el volcado y mostró identificadores de cuenta. Capitán informó el error,
descartó «Guardar» mediante «Ahora no» y eliminó inmediatamente ese archivo
temporal. La contraseña permaneció oculta; no se copia ningún identificador al
informe ni se conserva ese volcado como evidencia. Es una incidencia del manejo
de la aceptación, no una prueba del producto.

## Compilaciones y evidencia

Compilación en serie en `%TEMP%\baystream-t84-aceptacion`, con
`--dart-define-from-file=C:\Proyectos\baystream-privado\firebase-prod.json`,
sin abrir ni imprimir ese archivo. Android cambia solo a `.t84` en la copia y
se firma para prueba sin copiar ni abrir `android/key.properties`.

| Binario | Antes del codec | Final con codec |
|---|---:|---:|
| Windows release | 52.8 s | **29.1 s** |
| APK release `.t84` | 99.3 s | **51.8 s** |
| Web release | 46.9 s | **45.4 s** |

Se cotejó cada SHA de `lib/` entre repositorio y copia final: **0 diferencias**.
SHA del banco: `BB65B37C79798130642FA87CF2F740FA81D85D9EB6E8FF39D0591F85916BFB55`.
SHA del adaptador final: `EA63A21606865495E3B189800184871433F24AC775C0E6D0C044CD7EF4C0E974`.
Windows reutiliza el SDK C++ 13.9.0 local de T-82. MSBuild MSB8029 por compilar
en el temporal y las notas Android de APIs obsoletas son advertencias de build;
`analyze` queda en cero. La Web conserva el aviso de familia Cupertino sin asset.

Registros: `t84-windows-final.log`, `t84-apk-final.log`, `t84-web-final.log`, en
`%TEMP%`. Evidencia en `%TEMP%\baystream-t84-aceptacion\evidence`: avisos,
conflictos, avance y reaperturas de cada cliente; `windows-publicada-final.png`
documenta la publicación corregida. La prueba viva queda en
`windows-recibe-muelle.png`, `honor-recibe-oficina.png`,
`windows-produccion-final.png`, `honor-produccion-final.png`,
`windows-avance-produccion.png` y `honor-avance-produccion.png`.
Chrome final local queda documentado en `chrome-final.png`. Servidor propio PID
35552, solo `127.0.0.1:8094`; no se publica Hosting ni Play. Al cerrar la aceptación
se cerraron únicamente el PID 4696 de Windows, el PID 35552 del servidor, la
pestaña creada de Chrome y el paquete `.t84` del Honor. Los almacenes se conservan.

## Aceptación y revisión

Corpus, avisos, conflictos, avance, cola local, reglas y los tres clientes están
verificados. La prueba real muelle → oficina y oficina → muelle se completó sin
recargar. El APK final recibe correctamente el perfil publicado adaptado.
Se entrega **En revisión**, pendiente únicamente de la aceptación cruzada de
Timonel cuando esté disponible, según 10.18. SPRINT-3.md lo mantiene Yov.

## Archivos y límites

Sin cambios en `pubspec.yaml` ni `pubspec.lock`; sin dependencias nuevas.
No se modifica `lib/main.dart`, opciones de Firebase, los congelados de H5,
reglas, documentos ajenos, configuración local de Claude ni archivos rectores.
No se ejecutaron operaciones Git de escritura, `git status`, Firebase CLI,
credenciales de administrador ni acciones contra el proyecto H5. Las consultas
Git fueron `log --oneline -5` y `diff --stat --ignore-cr-at-eol`; HEAD se leyó como
archivo. Los cuatro entregables ajenos que ya tenían cambios se conservaron.

Lista exacta de archivos de T-84:

- `lib/features/vessel/domain/entities/hatch_covers.dart`
- `lib/features/vessel/domain/entities/movement.dart`
- `lib/features/vessel/domain/entities/operation.dart`
- `lib/features/vessel/domain/services/loading_operation.dart`
- `lib/features/vessel/domain/services/operation_progress.dart`
- `lib/features/vessel/domain/services/operation_state_deriver.dart`
- `lib/features/vessel/data/repositories/firestore_operation_sync.dart`
- `lib/features/vessel/presentation/pages/operation_progress_page.dart`
- `lib/features/vessel/presentation/providers/discharge_provider.dart`
- `lib/features/vessel/presentation/providers/loading_operation_provider.dart`
- `lib/features/vessel/presentation/widgets/bay_plan_view.dart`
- `lib/features/vessel/presentation/widgets/discharge_controls.dart`
- `lib/features/vessel/presentation/widgets/loading_controls.dart`
- `lib/features/vessel/presentation/widgets/loading_plan_controls.dart`
- `lib/features/vessel/presentation/widgets/hatch_operation_controls.dart`
- `test/t72_operation_state_test.dart`
- `test/t84_hatch_operation_test.dart`
- `test/t84_hatch_widget_test.dart`
- `tool/t84_corpus_test.dart`
- `tool/t84_main.dart`
- `docs/T84-RESULTADOS.md`

## Horas

Inicio registrado: **12-oct, 23:13:39 (Guatemala)**. Cierre de la aceptación y
liberación de clientes: **13-oct, 00:20:56**. Intervalo registrado:
**1.12 h frente a 4.0 h estimadas**, incluyendo lectura, implementación,
compilaciones, verificaciones y la espera de entrada manual de Carlos. Es tiempo
de pared de esta sesión, no una medición de esfuerzo activo ni de latencia H5.

## Git para Carlos

Solo rutas propias; el informe se incluye por la excepción permanente de AGENTS.
Codex no ejecuta estos comandos. El commit versiona la implementación y su
evidencia; la aceptación de Timonel sigue pendiente.

```powershell
git add -- "lib/features/vessel/domain/entities/hatch_covers.dart"
git add -- "lib/features/vessel/domain/entities/movement.dart"
git add -- "lib/features/vessel/domain/entities/operation.dart"
git add -- "lib/features/vessel/domain/services/loading_operation.dart"
git add -- "lib/features/vessel/domain/services/operation_progress.dart"
git add -- "lib/features/vessel/domain/services/operation_state_deriver.dart"
git add -- "lib/features/vessel/data/repositories/firestore_operation_sync.dart"
git add -- "lib/features/vessel/presentation/pages/operation_progress_page.dart"
git add -- "lib/features/vessel/presentation/providers/discharge_provider.dart"
git add -- "lib/features/vessel/presentation/providers/loading_operation_provider.dart"
git add -- "lib/features/vessel/presentation/widgets/bay_plan_view.dart"
git add -- "lib/features/vessel/presentation/widgets/discharge_controls.dart"
git add -- "lib/features/vessel/presentation/widgets/loading_controls.dart"
git add -- "lib/features/vessel/presentation/widgets/loading_plan_controls.dart"
git add -- "lib/features/vessel/presentation/widgets/hatch_operation_controls.dart"
git add -- "test/t72_operation_state_test.dart"
git add -- "test/t84_hatch_operation_test.dart"
git add -- "test/t84_hatch_widget_test.dart"
git add -- "tool/t84_corpus_test.dart"
git add -- "tool/t84_main.dart"
git add -- "docs/T84-RESULTADOS.md"
git commit -m "Sprint 3: T-84 operar tapas con avisos y avance derivado"
git push
```

## Tres líneas

Tapas como movimientos hatch_cover, con estado derivado, conflictos y annul.
Aviso PROVISIONAL sin bloqueo y avance por bahía sobre la misma bitácora.
580 pruebas, analyze 0, corpus 102/102 y producción bidireccional; En revisión.

## Mensaje para Yov

T-84 queda En revisión conforme a 10.18, con aceptación propia completada en
Windows, Honor 360 dp y Chrome visible. Producción PRUEBA T-84: muelle quita T1
y oficina lo recibe sin recargar; oficina quita T2 y muelle lo recibe sin recargar.
Seis movimientos compartidos confirmados, cero conflictos y avance de tapas
3/0/2 coincidente; Windows conserva aparte cinco movimientos locales previos.
Suite 580/580 (+17), analyze 0, corpus
102/102; A08 y A08v dan 460/460 en tres órdenes de trabajo y tres de llegada,
sin alterar contenedores y con avance cotejado por prefijo. Reglas 69/69 y mismo
SHA, sin pubspec, main.dart ni H5. La primera publicación detectó el JSON con
arrays anidados de T-83, incompatible con Firestore Standard: se adaptó solo su
transporte a un mapa por tapa, con lectura reversible y tres regresiones.
Windows final publicó PRUEBA T-84 y quedó Al día, sin repetir la caída; el Honor
final conservó sesión y almacén y recibió el perfil. Las tapas siguen
PROVISIONALES. La incidencia del diálogo de Google y su descarte están declarados
en el informe sin identificadores. Commit propuesto: «Sprint 3: T-84 operar tapas con
avisos y avance derivado». Tiempo de pared: 1.12 h frente a 4.0 estimadas.
La revisión de Timonel permanece pendiente.
