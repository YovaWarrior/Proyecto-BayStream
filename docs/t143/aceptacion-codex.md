# T-143 · Aceptación de Capitán Codex

**Dictamen: NO PASA.** Hay un P2 reproducible: al reconectar una cola con dos movimientos posteriores al cierre, la notificación del documento y los dos rechazos provocan **tres guardados locales del cierre**, cuando el encargo exige uno. La suite entregada está verde, pero no comprueba ese contador. No se corrigió código.

Sí pasan el análisis de todo el paquete en la copia aislada, **2145/2145 pruebas sin omitidas**, los 59 casos de T-131 y el recorrido **Windows como oficina → Web a 360 dp como muelle**, con red y al recuperar la red. La reserva nativa que dejó Timonel quedó recorrida. Se añade una observación P3 sobre el alcance de la regla de cabecera con un viaje más largo; no se presenta como una regresión demostrada.

Fecha: **11-nov-2026**, horario de Guatemala. Carpeta: `C:\Proyectos\baystream-qa-r4`. Evidencias propias: `build/t143acc/`, fuera de Git.

## 1. Base, autorización y preparación

Se leyeron `AGENTS.md`, `CLAUDE.md`, SPRINT-4 10.105, 10.110, 10.117 y 10.118, el informe completo `docs/T143-RESULTADOS.md` y DESIGN 7.2, 11 y 14.8. Carlos autorizó `pub get`, los comandos de Flutter y Firebase Emulator con el carril libre; ratificó continuar después de actualizar esta carpeta.

El primer paso 0 se detuvo correctamente en `fb03bec`, porque faltaban los commits de código. Al retomar, y también al finalizar, las consultas permitidas dieron:

```text
04cd717 Sprint 4: T-143, los estados y los textos de la operacion
b6374bf Sprint 4: analyze en cero otra vez, tool de T-140 y T-141
fb03bec Sprint 4: decision 10.118, T-143 revisada
```

`flutter pub get` terminó con «Got dependencies!». No se ejecutaron escrituras de Git, `git status`, publicaciones ni comandos contra Firebase real. No se usó el Honor.

### El análisis directo de esta carpeta y la copia aislada

**El análisis directo de la carpeta de aceptación no dio cero: informó 427 incidencias.** Incluyó instrumental histórico bajo `build/` y encontró ausente `build/t124/entradas/t124_entradas.dart`, importado por `tool/t124_main.dart`. No se ocultaron esas incidencias con exclusiones ni con `ignore`. Un intento anterior sin salida se interrumpió y no cuenta como resultado de análisis.

Para separar esos residuos del código aceptado se preparó `build/t143acc/copia/`, con `lib/`, `test/`, `tool/`, `integration_test/`, Windows, Web, fuentes y recursos idénticos a esta punta. Se recuperó la entrada generada de T-124 del banco de T-136; sus datos son sintéticos. **791/791 archivos cotejados siguieron idénticos tanto en el origen como en la copia.** `pubspec.yaml` y `pubspec.lock` también coinciden. Las fuentes Android necesarias para la suite se copiaron después, sin opciones privadas de Firebase.

La primera corrida de la copia tuvo **2144 aprobadas y un error**, porque yo había omitido copiar el manifiesto Android que lee T-88. Se incorporó ese archivo con sus recursos y se repitió **toda la suite**, no solo el caso fallido. El resultado válido es la segunda corrida completa de la tabla siguiente. Los errores de preparación no se atribuyen a T-143.

## 2. Cifras ejecutadas

| Validación | Resultado | Evidencia en `build/t143acc/` |
|---|---|---|
| `flutter analyze --no-pub`, desde la raíz del paquete aislado, sin limitar rutas; incluye `tool/` | **Cero**, «No issues found!»; salida 0 | `analyze.log`, `analyze-ejecucion.json` |
| `flutter test --no-pub --machine`, corrida completa válida | **2145 aprobadas, 0 fallidas, 0 omitidas**; salida 0 | `suite-completa.log`, `suite-completa-resumen.json`, `suite-completa-ejecucion.json` |
| T-131 dentro de esa misma corrida | **59/59** | Resumen por archivo de la suite |
| T-143 dentro de esa misma corrida | **31/31**: estados 16, cierre 12, límite 3 | Resumen por archivo de la suite |
| Sonda adicional del guardado único, fuera de la suite entregada | **Falla dos veces: esperado 1, observado 3** | `single-save2.log`, `single-save-repeticion.log` y sus registros de ejecución |
| Windows Release, código r4 de esta punta, banco contra demo | **Compila**; salida 0 | `windows.log`, `windows-ejecucion.json` |
| Web Release con recursos locales, banco contra demo | **Compila**; salida 0 | `web.log`, `web-ejecucion.json` |
| Exportaciones y archivos protegidos contra `b6374bf`, antes de T-143 | **12/12 sin diferencias de contenido** | `exportaciones-y-protegidos.json` |

El análisis válido terminó a las **01:46:23** y la suite válida se ejecutó de **01:50:49 a 01:53:14**. Los tiempos de ejecución registrados no se usan como mediciones H5. Todos los comandos de Flutter fueron consecutivos; se avisó con SEMÁFORO al ocupar y liberar el carril.

La sonda adicional usa el motor y la bitácora Hive reales, con `FakeCloud` de T-79. El único cambio de la bitácora es contar las invocaciones de `saveOperation` con `closed == true`. No añade demoras, no sustituye `_markClosed` y no modifica archivos de producto. Su primer intento no compiló por un import faltante del instrumento; las dos ejecuciones citadas ya compilaron y fallaron por el contador.

## 3. Código frente a la propuesta aprobada

| Punto | Comprobación y resultado |
|---|---|
| Regla del estado | `estadoDeLaOperacion` distingue Sin confirmar, Confirmado, Publicada y Cerrada. Sin operación o sin publicar queda Confirmado; un cierre local o del motor cuenta desde una operación publicada. Perder red no convierte Publicada en Confirmado. **Pasa.** |
| Píldora, descripción y etiqueta | La cabecera usa `textoDelEstado` y la misma `fraseDelEstado` para Tooltip y Semantics; el Tooltip queda excluido de la semántica para no duplicarla. Los casos de widget comprueban las frases. Windows mostró las etiquetas de Sin confirmar, Confirmado y Cerrada; Web mostró Publicada y su etiqueta «Publicada en la nube». **Pasa.** |
| Escucha del cierre | `watchOperation` conserva la escucha del documento que antes usaba `watchSources`, y añade `closedAt` al manifiesto emitido. Filtra `hasPendingWrites` antes de mapear. No añade otra consulta ni cambia reglas. Los casos del adaptador y el recorrido real pasan. |
| Persistencia | El motor toma la operación local actual, preservando un plan recibido desde el arranque. El caso de T-143 lo verifica. **El guardado único no pasa** con rechazos concurrentes: hallazgo T143-ACC-01. |
| Aviso | Se detecta la transición abierta → cerrada, se pide releer la operación y se suprime en el equipo anotado como autor del cierre. Unitarias y recorrido de muelle pasan; los observadores DOM contaron una aparición por muelle. Reabrir una operación ya cerrada no avisó. |
| Cola | No se impide enviar lo registrado antes del cierre. Los registros posteriores se rechazan; el chip cambia al texto aprobado y se oculta Reintentar con la operación cerrada. **Pasa en la suite y contra el emulador.** |
| Silueta | Sin escala dice «sin operación»; una bahía sin trabajo en la descarga dice «sin movimientos en GTSTC»; el plan de carga agregado, en Contenido, omite el avance y «sin operación». **Pasa**, también en la Web. |
| Perfil guardado | «No lo tengo» llegó marcado y se vio «Del perfil guardado: “No lo tengo”.». Los casos con valor y con propuesta pasan; las pruebas previas de plantilla siguen dentro de la suite. **Pasa.** No se atribuye a T-143 haber corregido el marcado previo. |
| Textos | «Peso total», «Lleno» y «Vacío» se comprobaron en pantalla. «Sin dato» se comprobó en la prueba con estado desconocido; los sintéticos del recorrido no contienen ese caso. **Pasa.** |
| Exportaciones | PDF, exportador general, escritor BAPLIE de salida y contrato/implementación de salida son idénticos a la base anterior a T-143. **Ninguna exportación cambió.** |

Las frases de la píldora son las aprobadas en la implementación: «Sin confirmar: confirma el perfil del buque para operar», «Confirmado en este equipo: la operación todavía no está en la nube», «Publicada en la nube» y «Cerrada por la oficina: ya no se registran movimientos».

## 4. La excepción de Confirmado: las cinco condiciones

Se usó Chrome visible, con viewport de **1366 × 768 dp**, escala de texto **2.0** aplicada por el banco mediante MediaQuery, sin cambiar `lib/`. El mismo banco se amplió a **1920 × 1080** para la comprobación ancha. Son recorridos de la app compilada, además de las pruebas de widget.

| Condición de 3.4 | Resultado |
|---|---|
| 1. Publicada y Cerrada mantienen la línea de 92 dp en el caso de T-131 | **Pasa el caso patrón.** Los ocho casos automatizados siguen dentro de T-131. En Web, V117 mostró ambas en una línea; la silueta comienza en y=96, frente a y=148 con Confirmado. Véanse capturas 18 y 19. La observación con A143B va aparte, como P3. |
| 2. Confirmado a 1366/2.0 en dos líneas de 144 dp, sin cortes, y a 1920/2.0 en una línea de 92 dp | **Pasa.** Casos automatizados y revisión de capturas 08, 09 y 17. Los controles de la cabecera quedan visibles. |
| 3. Al publicar se vuelve a una línea conservando bahía, zoom y desplazamiento | **Pasa con V118**, de cuatro caracteres como el caso patrón. Se eligió bahía 006, zoom 200 % y se desplazó horizontalmente la rejilla antes de publicar. La cabecera pasó de dos líneas a una. Las x de las celdas MNLU0000200 y MNLU0000196 permanecieron en **272.00 y 704.00 dp**, con el mismo ancho; siguieron Bahía 06 y 200 %. Capturas 20 y 21 y comparación DOM `iguales: true` en `web-pasos.jsonl`. |
| 4. Excepción escrita en DESIGN 14.8 | **Pasa.** Está en la punta aceptada; Codex no editó DESIGN. |
| 5. Censo T-112 diferido como O-143-2 | **Respetada la decisión.** No se puso al día ni se ejecutó aquí ese censo. El informe y 10.118 reconocen las 143 cadenas previas y las dos nuevas del aviso; no se transforma ese pendiente aceptado en un hallazgo nuevo. |

## 5. Windows contra Firebase Emulator y los muelles

**Entorno:** proyecto `demo-t143`; Auth `127.0.0.1:9399`, Firestore `127.0.0.1:8383`. Las reglas cargadas son las de T-130. El cotejo normalizando LF/CRLF dio igualdad; no se cambiaron las reglas. La huella del archivo cargado es `8b9039496cccda9fbc1412cc1f8610b3183d58fb4ba779efb0c0c7d920eeff71`.

**Windows:** ejecutable Release de la copia r4, con SDK C++ 13.13.1 y versión interna 1.0.0+9. No es una nueva versión publicable. Se abrió por Explorador y se verificó la ruta del proceso, PID **19276**:

```text
C:\Proyectos\baystream-qa-r4\build\t143acc\copia\build\windows\x64\runner\Release\baystream.exe
SHA-256 D4F9E2773BA5379F86EA21774855F1E625230D084D2A3ACB3F5FD8546AA6E0E8
```

**Almacén nativo usado:** `C:\Users\Giova\AppData\Local\Temp\t143acc-windows`, namespace **t143acc**, fijado por el entry point del banco. No se usó el almacén de operación por defecto. La sesión sintética se preparó mediante Firebase Auth nativo antes de abrir la interfaz; `windows-auth.json` registra éxito y la pantalla mostró «Oficina de prueba · Oficina / Cuenta autorizada». **No se acredita aquí el formulario de inicio de sesión Windows:** sí el SDK nativo, el rol autorizado, la publicación, la recepción y el cierre desde la interfaz real.

El banco deriva de `tool/t130_emu_main.dart`: inicialización demo DEFAULT adicional solo para el cliente nativo, namespace propio y sesión sintética de arranque; la Web añade únicamente el control de escala de texto para esta aceptación. No se sustituyeron el motor, la sesión de dominio, las páginas ni la bitácora del producto. Las claves sintéticas permanecen en TEMP y no se imprimen en el informe.

**Web:** dos perfiles nuevos de Chrome, ambos a **360 × 800 dp**, uno claro y otro oscuro. IndexedDB usa el namespace del banco; los perfiles están en `%TEMP%\t143acc-web`. No se usó Chrome personal. Las entradas son los sintéticos T-100, con BUQUE MANUAL y 60 contenedores; solo se cambiaron los números de viaje para aislar operaciones. `entradas-manifiesto.json` conserva las huellas originales y las primeras derivadas.

### Recorrido A143W

1. Windows abrió la llegada, confirmó GTSTC con «No lo tengo» y mostró Confirmado. Publicó desde Nube y cuenta y mostró Publicada / Al día. Ambos muelles se unieron y abrieron la llegada desde la nube.
2. El primer muelle quedó **con red y sin registrar nada**. Al cerrar la oficina cambió solo a «Al día · operación cerrada», mostró el aviso aprobado **una vez** y Nube y cuenta pasó a Publicada y cerrada. Capturas 02 y 06.
3. El segundo muelle quedó **sin red**, comprobado con `navigator.onLine == false` y una petición HTTP local fallida. Registró MNLU0000107 antes del cierre: «Sin conexión · 1 por enviar».
4. Windows cerró la operación desde la interfaz y recibió «Operación cerrada». Su cabecera quedó Cerrada y no apareció el aviso destinado al muelle. La hora del servidor fue **02:03:53.865**.
5. El segundo muelle siguió sin enterarse. Registró MNLU0000093 después del cierre y quedó en «Sin conexión · 2 por enviar».
6. Al devolverle la red cambió solo. MNLU0000107 quedó descargado; MNLU0000093 volvió a por descargar. El chip dijo **«Al día · 1 rechazado: la operación ya estaba cerrada · operación cerrada»**, y Nube y cuenta no ofreció **Reintentar**. El observador DOM contó **un aviso**, también capturado en oscuro. Capturas 03, 04 y 05.
7. Windows recibió el movimiento anterior al cierre en En vivo. Una lectura final del emulador encontró **un solo movimiento remoto** de A143W, `C:MNLU0000107`, creado a las **02:03:02.415**, anterior al cierre. No se encontró el registro rechazado entre los movimientos remotos. No se borró ni reescribió ese movimiento para limpiar la prueba.
8. Se recargó el primer muelle, se cortó la red y se reabrió A143W desde Recientes. Conservó **Publicada y cerrada**, sin otro aviso: contador **0** en esa apertura. En esta reapertura la sesión Web estaba ausente y el chip mostró «Solo este dispositivo · operación cerrada»; **no se presenta como prueba de restauración de sesión ni de la frase Sin conexión tras reiniciar**. Sí prueba la persistencia del cierre en el almacén local. Capturas 23 y 24.

Las cuatro operaciones sintéticas finales —A143W, A143B, V117 y V118— quedaron cerradas antes de detener el emulador. V118 conserva sus fuentes de llegada y carga. El resumen remoto está en `emulador-resumen-final.json`.

## 6. Hallazgos

### T143-ACC-01 · P2 · El cierre se guarda tres veces con rechazos concurrentes

**Requisito incumplido:** `_markClosed` debe guardar la operación local una sola vez.

**Ubicación:** `lib/features/vessel/data/repositories/sync_engine.dart:272`, `:283` y `:492`.

**Reproducción ejecutada**, con el mismo soporte de T-79/T-143:

1. Guardar una operación publicada y abierta en Hive, con un autor de muelle autorizado.
2. Arrancar `SyncEngine` con `FakeCloud` sin red.
3. Anexar dos movimientos propios cuya `createdAt` sea posterior al cierre del servidor.
4. Notificar el cierre mientras no hay red y ejecutar `cloud.goOnline()`. Llegan el documento cerrado y los rechazos de los dos movimientos.
5. Esperar ambos rechazos y contar únicamente las llamadas a `saveOperation` que guardan una operación cerrada.

**Esperado:** 1. **Observado:** 3, en dos ejecuciones sin demoras artificiales. El contador solo incrementa y delega en la implementación real:

```dart
@override
Future<Either<Failure, void>> saveOperation(Operation operation) {
  if (operation.closed) closedSaves++;
  return super.saveOperation(operation);
}
```

El instrumento completo queda en `build/t143acc/copia/build/t143acc/single_save_test.dart`. Para repetirlo, con el carril de Flutter libre:

```powershell
flutter test --no-pub --machine build/t143acc/single_save_test.dart
# Desde C:\Proyectos\baystream-qa-r4\build\t143acc\copia
```

**Causa observada:** la guarda de `_onDocument` solo protege ese camino. `_failed` también llama a `_markClosed` para cada rechazo. Las invocaciones pueden solaparse antes de que termine la lectura local; todas leen una operación aún abierta y llegan a `saveOperation`. Asignar `_closed = true` no serializa esa persistencia ni impide las llamadas desde `_failed`.

**Impacto comprobado:** escrituras locales redundantes y falta de la garantía solicitada. **No se observó pérdida de movimientos ni de fuentes en esta sonda**, y no se afirma que el recorrido real haya guardado tres veces: ese recorrido no llevaba un contador en el binario.

**Corrección propuesta, sin implementarla:** compartir o serializar la persistencia en curso entre documento y rechazos, y añadir una prueba que cuente los guardados con varios rechazos concurrentes. Volver a ejecutar esa prueba y la suite antes de aceptar.

### T143-ACC-02 · P3 · La regla de una línea depende también del número de viaje

Con **BUQUE MANUAL · A143B · GTSTC**, 1366 × 768 y letra 2.0, Confirmado tuvo dos líneas y **Publicada conservó esas dos líneas** después de publicar. Bahía, zoom y desplazamiento sí se conservaron. Capturas 11 y 12. Cerrada cupo en una línea, captura 16.

Con **V117/V118**, de cuatro caracteres como el caso patrón de T-131, Publicada y Cerrada sí ocuparon una línea, y V118 cumplió la transición completa de 3.4. No hay cortes de controles en las capturas de A143B. **No se demostró que este comportamiento sea una regresión de T-143.**

La observación limita una lectura universal de «dos líneas solo en Confirmado». Conviene que Carlos y Yov precisen si 14.8 describe la identidad ensayada o exige una línea también para identidades más anchas; en este último caso hace falta ampliar la cobertura y revisar el reparto de la cabecera. No se cambia esa decisión desde la aceptación.

**Balance:** 0 P1; **1 P2 que impide aceptar**; 1 P3 de alcance/cobertura. O-143-1 y O-143-2 siguen diferidas como se aprobó y no se suman como defectos nuevos.

## 7. Evidencia, integridad y cierre

- `web-pasos.jsonl`: acciones y observaciones DOM, comparaciones antes/después, desconexión y contadores del aviso; no incluye valores del formulario de sesión.
- `capturas/`: **25 PNG Web**. Las capturas 08/09, 17/18/19 y 20/21 sustentan la cabecera; 02/04/05/06 el cierre; 13 el perfil; 22 la silueta; 25/26 los textos; 23/24 la reapertura. La 14 se renombró como intento previo no confirmado: mostró la protección de T-130 frente a reemplazar una llegada de una operación abierta, y **no** se usa como prueba de Confirmado.
- `windows-capturas/`: seis PNG y sus árboles de accesibilidad, desde el previo hasta Cerrada y el movimiento recibido.
- `windows-auth.json`, `windows-verificacion.json`, `emulador-resumen-final.json`, `integridad-final.json` y `exportaciones-y-protegidos.json`: entorno, autenticación nativa sintética, procedencia del ejecutable y cotejos.
- `single-save2.log` y `single-save-repeticion.log`: los dos fallos de producto de la sonda; separados del resultado verde de la suite entregada.
- `evidencia-indice.json`: índice de huellas de los principales registros y capturas, generado al cerrar.

El banco de Windows quedó cerrado; los tres contextos Chrome, el conductor, el servidor HTTP y el árbol propio del emulador se cerraron al terminar. A las **02:27:03 de Guatemala**, no quedaban procesos BayStream ni escuchas en 5943, 5944, 8383, 9399, 4498, 4598 o 9150 (`cierre-final.json`). El índice final reúne **65 archivos de evidencia**; además del cotejo de 791 archivos, se verificaron **27 archivos Android sin diferencias**. No se accedió a Firebase real ni se publicó nada.

**Único archivo para Git: `docs/t143/aceptacion-codex.md`.** El instrumental, las copias, los binarios y los registros propios están bajo `build/t143acc/`, ignorado por `/build/`; no se propone forzarlos. **No cambian `pubspec.yaml` ni `pubspec.lock`**, `lib/`, `test/`, `tool/`, opciones Firebase, archivos H5 ni configuración local. El diff de contenido rastreado seguía vacío antes de añadir este informe; se conservan los avisos preexistentes de fin de línea de los registrantes Windows.

## 8. Git para Carlos

Desde `C:\Proyectos\baystream-qa-r4`, como en la aceptación `86b6f50`, llevando solo el informe a sprint-4:

```powershell
git add -- docs/t143/aceptacion-codex.md
git commit -m "Sprint 4: aceptacion de T-143"
git push origin HEAD:sprint-4
```

Codex no ejecutó estos comandos.

## 9. Tres líneas

1. **NO PASA:** un P2 reproducible guarda tres veces el cierre con dos rechazos concurrentes; no se modificó producto.
2. Analyze del paquete aislado en cero y suite **2145/2145 sin omitidas**, con T-131 **59/59**; la excepción se comprobó también en Web.
3. Windows publicó, recibió y cerró contra demo; ambos muelles cambiaron solos y la cola distinguió antes/después del cierre, sin Reintentar.

## 10. Mensaje para Yov

> Yov: aceptación de T-143 en `docs/t143/aceptacion-codex.md`, NO PASA por T143-ACC-01 (P2): documento de cierre más dos rechazos concurrentes producen tres guardados locales en vez de uno, reproducido dos veces con Hive real y la nube falsa existente. Analyze del paquete aislado cero; suite 2145/2145 sin omitidas y T-131 59/59. La vuelta que faltaba sí pasó: Windows publica, recibe el movimiento y cierra contra demo-t143; el muelle con red cambia solo y el de la cola confirma lo anterior y rechaza lo posterior, sin Reintentar. La cabecera patrón pasó también en Web; P3 aparte para Publicada con viaje de cinco caracteres, sin regresión demostrada. No se corrigió producto; solo va a Git este informe. Se cerró el instrumental y no se tocó Firebase real ni el Honor.

## 11. Reaceptación (corrección 1)

**Dictamen: NO PASA.** La corrección elimina los guardados duplicados del caso original y cumple la aclaración de cabecera. Sin embargo, introduce un **P2 de recuperación de persistencia, T143-ACC-03**: si el primer guardado del cierre devuelve `Left(CacheFailure)`, el motor memoriza la operación asíncrona como completada con éxito y ya no vuelve a intentar ese guardado durante su vida, aunque el almacenamiento se recupere. La operación local queda abierta mientras el motor conoce el cierre remoto. Se reprodujo con una sonda de fallo transitorio y se contrastó con el motor anterior.

Revisión del **11-nov-2026**, horario de Guatemala, sobre:

```text
b336117 Sprint 4: T-143, correccion 1, el cierre se guarda una vez
e5eff4e Sprint 4: decision 10.119, T-143 no pasa la aceptacion
6978711 Sprint 4: aceptacion de T-143
```

Se leyeron la decisión 10.119 y la sección 13 completa del informe de Timonel. Carlos confirmó el carril libre. No se cambió código de producto ni se ejecutaron escrituras de Git. No se repitieron Windows ni Web, ni se levantó Firebase Emulator: el alcance modificado está en el motor y el defecto nuevo se reproduce allí, sin interfaz ni Firebase.

### 11.1 Entorno y cifras

Evidencia propia: **`build/t143acc/reaceptacion1/`**. Se prepararon dos copias nuevas, sin alterar el banco ni los registros de la aceptación anterior:

- `copia/`: **796/796 archivos cotejados** de la punta actual, incluidos todos los Dart de `tool/`, más los recursos Android necesarios y la entrada generada de T-124 recuperada del banco anterior. O-143-3 sigue diferida; no se añadieron exclusiones al análisis.
- `roja/`: los mismos archivos, con **una sola diferencia de producto**, `sync_engine.dart` obtenido mediante `git show` de `04cd717`. El motor anterior se puso únicamente en esa copia, nunca en el árbol de trabajo.
- La sonda original solicitada se conservó sin modificar su contenido y se copió al mismo lugar relativo de ambas variantes para que importara el motor correspondiente. Su SHA-256 es `16049e40925fc70fe312b88d484f4afad07cdd5fe4dd6f5b61ecae249897f39a`.

| Comprobación ejecutada | Resultado | Registro relativo a la evidencia |
|---|---|---|
| `pub get`, copia actual | Correcto; sin cambios de pubspec | `pub.log`, `pub-ejecucion.json` |
| Sonda original + cuatro pruebas permanentes contra `b336117` | **5/5**; la sonda original exige y obtiene **1 guardado** | `foco.log`, `foco-resumen.json` |
| Analyze desde la raíz del paquete aislado, sin limitar rutas | **Cero incidencias**, salida 0 | `analyze.log`, `analyze-ejecucion.json` |
| Suite completa, una sola corrida | **2149/2149, 0 omitidas**, salida 0; T-131 59/59 y nuevas permanentes 4/4 | `suite.log`, `suite-resumen.json`, `suite-ejecucion.json` |
| Sonda original contra `04cd717` | **Roja: 3 frente a 1** | `roja-pruebas.log`, `roja-pruebas-resumen.json` |
| Cuatro pruebas permanentes contra `04cd717` | **4/4 rojas**: contadores 3, 4, 3 y 3 | Los mismos registros rojos |
| Sonda de fallo transitorio contra `b336117` | **Falla**: local abierta después del rechazo posterior y `retry()`; un solo intento de guardar cierre | `fallo-al-guardar.log`, `fallo-al-guardar-resumen.json` |
| La misma sonda de fallo transitorio contra `04cd717` | **Pasa**: el cierre local se recupera | `roja-pruebas.log` |

Analyze corrió de **02:50:43 a 02:51:59** y la suite completa de **02:52:37 a 02:56:00**. Son duraciones de ejecución, no mediciones H5. No se combinaron subconjuntos para formar la cifra de 2149. La sonda adicional de fallo está bajo `build/` y se ejecutó aparte; no forma parte de esas 2149 pruebas del paquete.

### 11.2 Qué cuentan las cuatro pruebas

Se revisó `test/t143_cierre_una_vez_test.dart` completo y se ejecutó el contraste rojo/verde, sin modificarlo.

1. La primera reproduce la sonda original con dos rechazos: el contador solo incrementa cuando se llama a `saveOperation` con una operación cerrada, y luego delega en Hive real. La operación abierta de preparación no se cuenta. Exige exactamente **1**, comprueba el cierre local y el del motor. Da **3** sin la corrección.
2. La segunda usa tres rechazos y demora 15 ms el retorno de las lecturas, conservando la instantánea que se leyó. Abre la ventana de concurrencia de forma explícita y exige **1**. Da **4** sin la corrección.
3. La prueba del plan comprueba el cierre, el contenido exacto del nuevo plan y la llegada original. El contador cuenta **todos los guardados de una operación cerrada**, también el guardado legítimo de una fuente posterior al cierre; por eso su límite es **2**, no 1. Da **3** sin la corrección.
4. La del listado comprueba cierre, revisión 1 del listado y contenido de la llegada original, con el mismo límite de **2**. Da **3** sin la corrección.

Los dos últimos casos permiten que la fuente se guarde antes del cierre —un guardado cerrado— o después —dos guardados cerrados—. No prometen contar exclusivamente la transición de cierre. **Las cuatro detectan el defecto de la entrega anterior.** En el control rojo, las dos de fuentes fallaron por el contador, no por pérdida de contenido; no se afirma que esa corrida haya demostrado pérdida de fuentes. Ninguna de las cuatro inyecta un `Left` al persistir, por lo que no cubren ACC-03.

### 11.3 Revisión de `_closing`, `_enCola` y DESIGN

- **Una persistencia compartida, en el camino exitoso:** `_closing ??=` memoriza el futuro que esperan documento y rechazos. El caso original queda resuelto, verificado por la sonda sin cambios y las permanentes.
- **Una cola del motor:** las únicas tres llamadas a `log.saveOperation` del archivo están en las tareas de cierre, listado y plan, dentro de `_enCola` —líneas 296, 366 y 422—. Cada una relee la operación dentro de su turno. Las lecturas previas de revisión y los viajes a la nube quedan fuera; no son escrituras adicionales de la operación local.
- **Sin espera recursiva identificada:** ninguna de esas tareas llama a `_enCola` ni espera a otra tarea de la misma cola. El documento espera el cierre antes de sincronizar fuentes, una vez liberado ese turno. No se identificó un bloqueo mutuo en esos caminos; las pruebas terminaron.
- **El `onError` de la cola no es por sí solo el defecto:** normaliza únicamente el futuro interno `_writes` para que un trabajo fallido no impida ejecutar el siguiente. `_enCola` devuelve `resultado` sin convertir su error en éxito para el llamador. La incidencia está en el resultado `Either` del repositorio que `_markClosed` no examina, detallada abajo.
- **ACC-02, cerrado conforme a 10.119:** DESIGN 14.8 ahora limita las medidas a BUQUE MANUAL y un viaje de cuatro caracteres, V117, y permite dos líneas con Publicada o Cerrada para identidades más anchas, sin cortes. Cita el caso A143B y conserva el rediseño de la cabecera para usabilidad. No se añadió cobertura visual, tal como se decidió.

### 11.4 T143-ACC-03 · P2 · Un guardado fallido queda memorizado como éxito

**Ubicación:** `lib/features/vessel/data/repositories/sync_engine.dart:289`, especialmente la llamada a `saveOperation` de la línea **296** y la memorización en `_closing`. El filtro del documento en la línea 275 y el uso del futuro compartido en el rechazo, línea 527, impiden una persistencia posterior en el mismo motor.

**Reproducción ejecutada:** `copia/build/t143acc/save_failure_test.dart`, con Hive real y `FakeCloud` de T-79. La bitácora solo sustituye **el primer intento de guardar una operación cerrada** por un `Left(CacheFailure)`; las lecturas, los movimientos y todas las escrituras siguientes usan la implementación real.

1. Guardar una operación publicada y abierta y arrancar el motor con un muelle autorizado y red.
2. Recibir el cierre del servidor. El primer guardado devuelve `Left(CacheFailure)` y no persiste.
3. Comprobar que el motor conoce el cierre y que el registro local sigue abierto.
4. Con el almacenamiento ya recuperado, registrar un movimiento posterior al cierre; su rechazo vuelve a llamar a `_markClosed`. Ejecutar además `retry()` y releer la operación local.

**Resultado con la corrección 1:**

```text
intentos=1
estado=SyncState.upToDate
motorCerrado=true
localCerrado=false
Expected: true / Actual: false
```

**Resultado del control:** la misma prueba pasa con el motor `04cd717`, donde el rechazo posterior sí permite recuperar la persistencia. Las dos variantes tienen idéntica sonda y difieren únicamente en el motor. Es una regresión de la memorización nueva, no una inferencia basada solo en leer el código.

**Causa:** `saveOperation` comunica errores mediante `Either<Failure, void>`. Un `Left` no es una excepción del futuro: el `await` termina normalmente. `_markClosed` descarta ese valor, ejecuta `_emit()` y deja `_closing` resuelto. El rechazo siguiente espera ese mismo futuro completado y no vuelve a guardar. Al reescuchar, `_closed == true` hace que el documento tampoco lo intente. El aviso técnico que pudiera imprimir `_guard` en un fallo real de Hive no cambia esta conclusión: **el motor no propaga ese `Failure`, no conserva la persistencia como pendiente y no se recupera en los caminos ensayados**.

**Impacto demostrado:** falta la persistencia local del cierre durante la vida de ese motor, aun con el almacenamiento recuperado. El hecho remoto de que la operación está cerrada sigue siendo verdadero; no se propone ocultarlo. La sonda no prueba ni afirma pérdida de movimientos, corrupción del almacén o imposibilidad de recuperación tras reiniciar.

**Corrección propuesta, sin implementarla:** distinguir el cierre conocido de la persistencia confirmada; examinar el `Either`, conservar una única escritura en curso para las llamadas concurrentes y permitir recuperar un guardado fallido sin memorizarlo como éxito. Propagar o comunicar el fallo por el mecanismo acordado del producto y añadir la prueba del error transitorio a la cobertura permanente.

Para repetir únicamente la sonda, con el carril libre:

```powershell
# Desde C:\Proyectos\baystream-qa-r4\build\t143acc\reaceptacion1\copia
flutter test --no-pub --machine build/t143acc/save_failure_test.dart
```

**Balance de esta reaceptación:** 0 P1; **1 P2 nuevo que impide aceptar, ACC-03**; 0 P3 nuevos. ACC-01 pasa su reproducción original; ACC-02 se cierra por la decisión y el texto aprobado. O-143-1, O-143-2 y O-143-3 conservan su tratamiento anterior.

### 11.5 Entrega y Git para Carlos

Solo se añade esta sección a **`docs/t143/aceptacion-codex.md`**. Se preservó byte por byte el contenido anterior del informe; la comprobación del prefijo y las huellas están en `build/t143acc/reaceptacion1/verificacion-final.json` e `indice.json`. Los instrumentos y las copias nuevas quedan bajo `build/t143acc/reaceptacion1/`, ignorados por `/build/`, sin forzarlos a Git.

**No cambian `pubspec.yaml` ni `pubspec.lock`**, ni código de producto, pruebas permanentes, DESIGN, Firebase o configuración local. No se ejecutó Firebase real, emulador ni clientes gráficos. Todos los comandos de Flutter terminaron y se liberó el semáforo. El diff de contenido rastreado previo a esta sección seguía vacío, con los mismos avisos de fin de línea de los registrantes Windows.

Desde la carpeta de aceptación, solo este archivo:

```powershell
git add -- docs/t143/aceptacion-codex.md
git commit -m "Sprint 4: reaceptacion de T-143"
git push origin HEAD:sprint-4
```

Codex no ejecutó estos comandos.

### 11.6 Tres líneas

1. **NO PASA por ACC-03 (P2):** un fallo transitorio de persistencia queda memorizado como éxito y no se recupera en el mismo motor.
2. La sonda original da **1 guardado**; las cuatro permanentes pasan y son rojas con el motor anterior; ACC-02 queda documentado.
3. Analyze cero y **2149/2149 sin omitidas** en una corrida; sin repetir Windows/Web ni modificar producto.

### 11.7 Mensaje para Yov

> Yov: reaceptación de la corrección 1 añadida al informe. ACC-01 pasa la sonda original y las cuatro permanentes; comprobé que las cuatro son rojas con 04cd717. ACC-02 está resuelto en 14.8. Analyze cero y suite 2149/2149 sin omitidas, pero NO PASA por ACC-03 (P2): un Left al guardar el cierre queda memorizado como éxito; incluso tras otro rechazo y retry, el motor está cerrado y Al día, y la operación local sigue abierta. La sonda de fallo transitorio falla con b336117 y pasa con el motor anterior. No corregí producto ni repetí Windows/Web; solo va a Git el informe.
