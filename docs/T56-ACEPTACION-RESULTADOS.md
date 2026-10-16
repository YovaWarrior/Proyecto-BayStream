# T-56 · Aceptación cruzada

Capitán Codex · 16-oct-2026 · Guatemala.

**Veredicto actual: T-56 aceptada.** Carlos midió manualmente **56 segundos** desde abrir el perfil hasta «Perfil guardado», conforme a la decisión 10.68 transmitida directamente por él. Capitán verificó después **216 tomas, «Propuestas del archivo»**, y la huella real final solo difiere en archivos `t56cx_*`. Honor: 27,902 s. Los casos funcionales de los tres clientes, los cinco textos y el almacén real resultaron conformes. El cierre definitivo y el Mensaje para Yov están en la sección 18. Las etapas anteriores se conservan como historial; el intento de 96,337 s mide instrumentación del agente y no se usa para el criterio humano.

## 1. Base y coordinación

- Base indicada por Carlos: `7a06c5d51377226a7c8e7babbaed5653ddab3756`, HEAD de `sprint-3`.
- Objeto de aceptación: T-56, `5b1d8a1`, y corrección de 10.57, `32a1a94`. La base también incluye T-96 y T-105.
- Referencias leídas: acuerdos de `AGENTS.md`, ficha vigente de T-56 al inicio de la Ola 6, decisiones 10.52/10.57 y contexto posterior de `SPRINT-3.md`, e informe `docs/T56-RESULTADOS.md`, incluida su sección 10.
- Copia de ejecución: `C:\Users\Giova\AppData\Local\Temp\baystream-t56cx-20261016\base`.
- Exportación de solo lectura con `git archive` del SHA indicado. Se cotejaron los 400 archivos de la copia con sus versiones del árbol actual; el contenido coincidía al normalizar CRLF/LF. Se materializaron los bytes actuales para conservar también los SHA de la sección 6 del informe. `git diff --stat --ignore-cr-at-eol` sobre las rutas exportadas no mostró diferencias respecto de la base.
- El repositorio no se utilizó para compilar ni ejecutar pruebas. No se cambió de rama ni se ejecutaron operaciones de escritura de Git.
- Carlos cedió primero Flutter para suite y analyze. Se le notificaron ambos resultados y se liberó el turno antes de pedir otro. Carlos cedió después el turno para corpus y cotejo. Al concluir se volvió a avisar que Flutter quedaba libre.
- Honor y Windows continúan reservados para Timonel, que acepta T-105. No se abrió ninguna app ni se utilizó ningún dispositivo en esta etapa.
- Namespace reservado para los clientes: `t56cx`; applicationId Android: sufijo `.t56cx`. Aún no se compiló ni instaló ese cliente.

## 2. Validaciones ejecutadas

Todos los comandos terminaron con código 0. No se ejecutó `flutter test --platform chrome`.

| Comprobación | Resultado observado | Registro |
|---|---|---|
| Suite completa de HEAD | **799/799**, piso vigente de 799 conservado; salida `00:42 +799: All tests passed!` | `suite.log` |
| `flutter analyze` | **0 incidencias**; `No issues found! (ran in 27.1s)` | `analyze.log` |
| Búsqueda de supresiones | Sin `// ignore:` ni `// ignore_for_file:` en `lib/` y `test/`; búsqueda con salida 1 por ausencia de coincidencias | Inspección con `rg` |
| Corpus completo `tool/*corpus*test.dart` | **135/135 en 34 archivos**; salida `00:47 +135: All tests passed!` | `corpus.log` |
| Sonda propia contra producción | Código 0; sin importar pruebas ni auxiliares de Timonel | `independent-validator.json` |
| Comparación del resultado de producción con el cálculo independiente sobre EDI crudo | Coinciden las 20 combinaciones fuente/origen, los cinco cruces, el escenario A01 y las dos uniones | `t56cx_compare.py` |

Se pasó al corpus `--dart-define=BAYSTREAM_CORPUS_DIRECTORY=<carpeta externa autorizada>`. Los 135 casos corresponden al HEAD actual, que ya incluye T-96; los 129 casos en 33 archivos del informe de T-56 eran su piso histórico.

Los registros y las sondas están fuera del repositorio, en `C:\Users\Giova\AppData\Local\Temp\baystream-t56cx-20261016`. El corpus anonimizado permanece en su carpeta externa; no se copió al repositorio.

## 3. SHA de la sección 6

Los ocho SHA coinciden exactamente con el informe de Timonel, en la copia antes y después de ejecutar las validaciones.

| Archivo | SHA-256 |
|---|---|
| `firestore.rules` | `0112510984D9A16364F9752E243999C47306E0BCF82766E380DB380E8FE8E60A` |
| `lib/features/vessel/domain/entities/vessel_profile.dart` | `70F26644CADDFF4FC2413A133FC3E336AD865EE0CFFB4164F428FF2B1F242EDF` |
| `lib/features/vessel/data/repositories/firestore_operation_sync.dart` | `EA63A21606865495E3B189800184871433F24AC775C0E6D0C044CD7EF4C0E974` |
| `lib/main.dart` | `C5189B1D8711837A05C68306D424C9FDBCC977BA3BBB6C823089FFE4CA5339D5` |
| `pubspec.yaml` | `1B40E5308D3D1594EAFBF48EE578ABB73A39DC2E3FE0A4551F0D1AC6956F38EA` |
| `pubspec.lock` | `577D742E04143131BC02A1BBB6C246D298C90396E08F6C9DFE393637A2617F53` |
| `lib/latency_test_screen.dart` | `599310DB13A713E82FC0D6A411BE2D7757CBC2B803D772C1CAA16C471725CDFF` |
| `lib/c3_reconciliation_screen.dart` | `3AF478364A8C5386E1F921E0142DC4F847594BECA00B6743563CB09A8A4112A5` |

**`pubspec.yaml` y `pubspec.lock` no cambian. No se agregaron dependencias.** No se modificó código de producción, reglas, perfil, codec ni congelados.

## 4. Cotejo independiente del validador

Se escribieron sondas propias **fuera del repositorio**, sin consultar ni reutilizar las pruebas de T-56 de Timonel:

1. `t56cx_raw.py` lee directamente los segmentos `LOC+147`, `EQD` y `TMP` de las diez fuentes. Extrae posiciones, tipos y refrigerados; calcula las bahías de bodega desde el texto crudo.
2. `t56cx_oracle.py` calcula por separado la regla del código exacto y la regla solicitada por celda sobre esa lectura del EDI, sin importar código de BayStream.
3. `t56cx_check.dart` importa exclusivamente código de producción de la copia: lector, entidades y `ReeferSocketValidator`. Construye los escenarios y comprueba los resultados con condiciones que lanzan error si no se cumplen. Se ejecutó con el SDK Dart y el `package_config.json` de la copia, sin incorporar la sonda a `test/` ni `tool/` del repositorio.
4. `t56cx_compare.py` contrasta automáticamente los JSON de ambas lecturas y exige que coincidan sus cifras.

La suite y el corpus completos sí incluyen las pruebas existentes de Timonel, como corresponde a la validación general. El cotejo de esta sección es adicional e independiente de ellas.

### Escenario de T-55 sobre A01

Desde los 50 refrigerados observados en A01 se construyeron 82 refrigerados de 20 pies en las impares vecinas de las tomas de 40, y nueve de 40 pies sobre las tomas de 20, conservando fila y nivel. El inventario se marcó declarado para este escenario de prueba.

| Resultado | Código exacto anterior | Validador de T-56 |
|---|---:|---:|
| Errores | **91** | **0** |
| Avisos de extremo | 0 | **82** |
| Conformes, sin alerta | 0 | **9** |

Los 82 resultados son `notEvaluated` con severidad `warning` y el texto de confirmación del extremo. El cálculo separado sobre el EDI crudo da exactamente las mismas cifras.

### Diez fuentes, cada una con su inventario

Se ejecutó cada fuente con su perfil propuesto y después con el mismo inventario marcado declarado: **20 combinaciones**. En todas, la regla anterior y la actual dan cero alertas; no aparece ninguna nueva. El número de refrigerados coincide también entre el lector de producción y la lectura independiente del EDI.

| Fuente | Refrigerados / tomas | Antes | Después | Nuevas |
|---|---:|---:|---:|---:|
| A01 | 50 / 50 | 0 | 0 | 0 |
| A02 | 14 / 14 | 0 | 0 | 0 |
| A03 | 10 / 10 | 0 | 0 | 0 |
| A03v_VGM | 10 / 10 | 0 | 0 | 0 |
| A04 | 71 / 71 | 0 | 0 | 0 |
| A05 | 91 / 91 | 0 | 0 | 0 |
| A06 | 91 / 91 | 0 | 0 | 0 |
| A07 | 12 / 12 | 0 | 0 | 0 |
| A08 | 8 / 8 | 0 | 0 | 0 |
| A08v_VGM | 8 / 8 | 0 | 0 | 0 |

### Cruces con inventario declarado y geometría de ambos viajes

| Inventario → carga | Antes | Después | Nuevas |
|---|---:|---:|---:|
| A05 → A06 | 0 | 0 | 0 |
| A06 → A05 | 0 | 0 | 0 |
| A07 → A08 | 0 | 0 | 0 |
| **A08 → A07** | **4** | **4** | **0** |
| A07 → A08v_VGM | 0 | 0 | 0 |

## 5. Las 21 bahías de A07 ∪ A08

**01, 02, 03, 05, 06, 07, 09, 10, 11, 13, 14, 15, 17, 18, 19, 21, 22, 23, 25, 26 y 27.**

La sonda de producción propone la geometría desde las posiciones de ambos viajes y une sus `observedHoldBays`. Da exactamente esa lista con A08 y con A08v_VGM.

El cotejo independiente reproduce la lista leyendo el texto EDI: posiciones `LOC+147` por debajo de 80 y, para los tipos de 40/45 pies en bahía par, sus dos impares vecinas. No utiliza el lector ni la función de bahías de BayStream. La comparación automática confirma ambas uniones.

## 6. Pendientes al entregar la primera etapa (histórico)

Estos resultados **no se sustituyen por las pruebas automatizadas ni por lo observado por Timonel**. Todavía no se ejecutaron en esta aceptación:

- **Windows, Honor y Chrome:** BUQUE GOLF propuesto desde A07, inicialmente 12 tomas; rango `002-026/4`, filas vacías, niveles `82-86, 94`; vista previa 204 / 6 / 70; guardar y reabrir con 216 y «Propuestas del archivo».
- **Honor y Windows con la compilación final:** cronómetro continuo desde abrir el perfil hasta «Perfil guardado», menos de un minuto.
- **Tres clientes:** lista `0020184 0060188, 12345 ABCDEFG 0000182 0021282 0100382`, resultado 1 / 2 / 1 y «No se cargan 3…»; quitar `002-026/4`, nivel 86, deja 147; diálogo con «Quitar no cambia la casilla de declaración.»; solo la casilla declara; la sección conserva su apertura después de alejarse y volver.
- **Honor, 360 dp, letra 2.0:** cinco textos en claro y oscuro, incluido A06 en GTPBR con «717 sin puerto de carga en el archivo»; devolver la letra a 1.0 al terminar.
- **Windows:** huellas anterior y posterior fuera del paquete, con `.bat` lanzado mediante `explorer.exe` y proceso padre documentado; diferencias exclusivamente en `t56cx_*`. La huella anterior se tomará cuando Carlos ceda el cliente, antes de abrirlo.

No se utilizó el navegador integrado. No se abrió el archivo privado de defines. No se accedió a Firebase ni se publicó nada. No se capturaron volcados del Honor ni se lanzó la app de Windows en esta etapa.

## 7. Evidencia y archivos de esta entrega parcial

Carpeta externa: `C:\Users\Giova\AppData\Local\Temp\baystream-t56cx-20261016`.

- Registros: `suite.log`, `analyze.log`, `corpus.log`.
- Sondas propias: `t56cx_raw.py`, `t56cx_oracle.py`, `t56cx_check.dart`, `t56cx_compare.py`.
- Resultados: `raw-corpus.json`, `raw-oracle.json`, `independent-validator.json`, `protected-sha.json`.
- Manifiesto de SHA de registros y sondas: `evidence-sha.json`.
- SHA-256 de la sonda Dart: `0D4FEDDC65E4F3ED0FD3666402E043548F40C45F07AC1E2F979A5A1F8188792D`.

**Único archivo creado o modificado en el repositorio por esta aceptación:** `docs/T56-ACEPTACION-RESULTADOS.md`. Los demás artefactos permanecen en `%TEMP%`.

## 8. Git para Carlos

Bloque exclusivamente para versionar este informe parcial si Carlos decide hacerlo; no implica que T-56 ya esté aceptada.

```powershell
git add -- docs/T56-ACEPTACION-RESULTADOS.md
git commit -m "Sprint 3: documentar validaciones y cotejo independiente de T-56"
git push
```

## 9. Tres líneas

Suite 799/799, analyze en cero, corpus 135/135 y ocho SHA conservados sobre el HEAD indicado.
Cotejo propio sobre A01 y diez fuentes conforme; A08 → A07 permanece en cuatro y las dos uniones dan las 21 bahías.
No cambia el producto; la aceptación completa espera los tres clientes, las mediciones y la huella del almacén real.

## 10. Mensaje para Yov de la primera etapa (histórico)

T-56: puntos 1–3 de la aceptación cruzada conformes sobre 7a06c5d51377226a7c8e7babbaed5653ddab3756, en copia de TEMP. Suite 799/799, analyze cero sin supresiones, corpus completo 135/135 en 34 archivos y ocho SHA de la sección 6 iguales antes y después. Una sonda propia fuera del repo, sin pruebas ni auxiliares de Timonel, ejecutó el validador de producción y coincidió con un cálculo independiente sobre EDI crudo: A01 91 errores → 82 avisos de extremo + 9 conformes; ninguna alerta nueva en las diez fuentes; A08 → A07 sigue en 4; A07 ∪ A08 y su variante VGM dan las 21 bahías exactas. Flutter quedó libre y Carlos fue avisado. Honor y Windows siguen con Timonel; faltan los puntos 4–6, por lo que T-56 todavía no se declara aceptada. Informe parcial: docs/T56-ACEPTACION-RESULTADOS.md. No se modificó producción ni pubspec.*.


## 11. Reanudación de los clientes sobre HEAD

Carlos cedió los dispositivos para terminar primero T-56 y después aceptar T-96. La copia de clientes se preparó sobre `ff14dc0d5e8b3f4e7461b760fa28208380029ce7`, HEAD al comenzar esta etapa, en `C:\Users\Giova\AppData\Local\Temp\baystream-t56cx-ff14dc0\base`. Namespace `t56cx`, applicationId `gt.cmartinez.baystream.t56cx`.

Al cerrar, HEAD era `0b2dfce8bf06f06c0a2d98fe49f3879067dc4443`. El diff entre ambos HEAD solo contiene `SPRINT-3.md`, la presentación y el tablero; no hay diferencias de producto. Se leyeron las decisiones posteriores hasta 10.67. El producto de la copia sigue correspondiendo al HEAD actual. Los ocho archivos protegidos de la sección 3 conservaron sus SHA en el repositorio, cotejados de nuevo al terminar (`protected-sha-final.json`).

Se usó el banco existente `tool/t56_main.dart`. Solo en TEMP se sustituyó su namespace por `t56cx`, se agregó una anulación explícita de `LocalOnlyOperationSync`, se incorporaron A07 y A06 como assets y se cambió el applicationId. El banco conserva `LocalSessionRepository`: modo sin cuenta. Ninguna operación de nube ni publicación. El archivo privado pasado por `--dart-define-from-file` no se abrió.

Las compilaciones finales terminaron con código 0: Android release 83,9 s, Windows release 36,3 s y Web release 56,3 s. Después `flutter run -d chrome --release --no-pub` compiló la Web en 36,0 s y sirvió el puerto 8157. Un solo comando de Flutter a la vez. Estos son tiempos de compilación, no de interacción.

**Ningún archivo de producción del repositorio fue modificado. `pubspec.yaml` y `pubspec.lock` del repositorio no cambian; no se agregaron dependencias.** Los cambios de assets y arranque pertenecen exclusivamente a la copia temporal.

## 12. Casos funcionales de los tres clientes

Se ejecutaron personalmente en esta aceptación, sin sustituirlos por los resultados de Timonel. En cada cliente se empezó con BUQUE GOLF propuesto desde A07 y sus 12 tomas. Bahías `002-026/4`, filas vacías y niveles `82-86,94`.

| Comprobación observada | Honor | Windows final | Web autorizada |
|---|---|---|---|
| Vista previa del rango | 204 nuevas / 6 existentes / 70 descartadas | Igual | Igual |
| Guardar y reabrir | 216, «Propuestas del archivo» | Igual | Igual |
| Lista `0020184 0060188, 12345 ABCDEFG 0000182 0021282 0100382` | 1 nueva / 2 existentes / 1 fuera; «No se cargan 3…» | Igual | Igual |
| Aplicar la lista | 217 | 217 | 217 |
| Quitar `002-026/4`, filas vacías, nivel 86 | Se quitan 70, no estaban 0; quedan 147 | Igual | Igual |
| Cierre del diálogo de quitar | «Quitar no cambia la casilla de declaración.» | Igual | Igual |
| Reabrir después de cargar y quitar, sin marcar la casilla | 147 propuestas | Igual | Igual |
| Marcar expresamente la casilla, guardar y reabrir | 147, «Tomas declaradas por el usuario» | Igual | Igual |
| Alejarse de la sección y volver sin tocar su expansión | Sigue abierta con formulario y tomas | Igual | Igual |

La declaración se comprobó separadamente: cargar, quitar y guardar conservaron el origen propuesto; solo marcar la casilla lo cambió. Se conservan capturas y volcados de las dos reaperturas (propuesto/declarado).

**Navegador utilizado:** la Web pasó en el navegador integrado de Codex, visible, en `http://127.0.0.1:8157/`, con autorización directa posterior de Carlos: «Haz las pruebas con el navegador integrado…». Chrome se abrió con Flutter, pero **no se declara probado**: Computer Use detuvo su inspección por no poder determinar la URL con suficiente confianza para aplicar su política. No se usó `flutter test --platform chrome`. La pestaña integrada, Chrome de esta prueba y el proceso Flutter que la servía se cerraron al terminar esa etapa.

Evidencia principal: `honor-timed-preview.*`, `honor-reopened-216.*`, `honor-pasted-preview.*`, `honor-remove-preview.*`, `honor-section-still-open.*`, `honor-147-reopened-proposed.*`, `honor-147-declared-reopened.*`; sus equivalentes `windows-*` y `web-*`.

## 13. Cinco textos del Honor

Honor a 720 × 1600 píxeles y densidad 320: **360 × 800 dp**. Letra del sistema **2.0**, en claro y oscuro. Se inspeccionaron las capturas, además del texto accesible sanitizado.

| Texto | Resultado en ambos temas |
|---|---|
| Recientes: «1 contenedor · 1 bahía» y «717 contenedores · 27 bahías» | Concordancia correcta; texto completo al desplazarse |
| «Sin tapa · bodega abierta» | Completo dentro del campo en dos líneas y completo en el menú |
| «Viaje: VIAJE007A» y «Viaje: VIAJE004A» | Dos líneas dentro de su fondo, sin salirse |
| «Contenido compatible: BAPLIE 2.x, y la 1.5 con aviso.» | Completo al desplazarse hasta el final de la pantalla vacía |
| A06, escala GTPBR | «0 se descargan · 0 se cargan · 0 de paso · 717 sin puerto de carga en el archivo», completo; conserva el aviso de la versión 1.5 |

Capturas: `honor-recientes-claro-2.png`, `honor-recientes-singular-claro-2.png`, `honor-recientes-oscuro-2-final.png`, `honor-recientes-singular-oscuro-2.png`, `honor-tapas-{claro,oscuro}-2.png`, `honor-tapas-menu-{claro,oscuro}-2.png`, `honor-producto-A0{6,7}-{claro,oscuro}-2.png`, `honor-A06-resumen-{claro,oscuro}-2.png`, `honor-vacia-texto-claro-2-completo.png` y `honor-vacia-texto-oscuro-2.png`.

El botón «Usar estas declaraciones» conserva la observación de T-104 ya documentada por Timonel; no es uno de los cinco textos de esta aceptación y no se modificó.

Los volcados se obtuvieron con `adb exec-out uiautomator dump /dev/tty`, sanitizados en memoria antes de imprimirlos o guardarlos. Se descartan formularios con contraseña y diálogos de cuenta; se ocultan correos y UID. **La letra terminó en 1.0**, comprobado otra vez después de detener Windows (`honor-font-final.txt`).

## 14. Almacén real de Windows

La app se lanzó con `explorer.exe` desde la copia final, fuera del paquete del agente. Primera ejecución: PID **27516**; segunda, para preparar la medición: PID **13540**. Ambas se cerraron por su PID exacto, después de verificar la ruta del ejecutable.

Almacén real: `C:\Users\Giova\AppData\Local\BayStream`. Huellas obtenidas con `.bat` lanzados por `explorer.exe`, que ejecutan el script de huella fuera del paquete:

- Antes: **414 archivos**; padre `cmd.exe` PID 28468, abuelo `explorer.exe` PID 27768.
- Después de los casos funcionales: **426 archivos**; padre `cmd.exe` PID 3388, abuelo `explorer.exe` PID 612.
- Después de repetir la preparación y detener la medición final: **426 archivos**; padre `cmd.exe` PID 17236, abuelo `explorer.exe` PID 6224.
- Los **414 originales conservan exactamente su SHA**. No hay archivos eliminados. Los 12 añadidos son exclusivamente `t56cx_{device,movements,operations,profiles,settings,voyages}.{hive,lock}`.

Para repetir la medición desde las 12 tomas iniciales, se apartaron únicamente los 12 archivos de este namespace de prueba a `windows-before-timing-retry/` en TEMP, con la app cerrada. El script se ejecutó fuera del paquete y verificó la ruta absoluta del almacén y el prefijo de cada archivo antes de moverlo. El banco volvió a proponer A07. No se tocaron archivos de otros namespaces. El segundo recorrido final dejó de nuevo 216 propuestas en el namespace de prueba; la secuencia funcional hasta 147 declaradas queda conservada en el respaldo y en su evidencia anterior.

Registros: `store-before.json`, `store-after-functional.json`, `store-after.json`, `store-comparison.json`, `store-comparison-final.json`, `fingerprint.ps1`, los `.bat` y `windows-reset-own-namespace.json`.

## 15. Cronómetros e incidencias de instrumentación

**Honor: conforme, 27,9021708 s**, de abrir el perfil hasta observar «Perfil guardado», en una transacción continua con vista previa 204 / 6 / 70. Inicio `2026-10-16T17:12:53.282590+00:00`, fin `2026-10-16T17:13:21.185459+00:00`. Registro `honor-timing.json`.

**Windows: no acredita el límite solicitado.** El último intento continuo, con la compilación final y partiendo de las 12 tomas, consumió **96,337 s hasta regresar a Perfiles guardados**. Esa captura aún no registró «Perfil guardado» (`observed_saved: false`), por lo que no es lícito presentarlo como un cronómetro completo hasta ese texto. Ya había superado el minuto antes de poder acreditar el final exigido. Registro crudo `windows-timing.json`, vista previa `windows-timed-preview.png` y captura/árbol al volver `windows-timed-saved.*`. Los nombres de estos últimos archivos identifican la acción de guardar; no convierten en verdadera la observación del texto, cuyo indicador permanece `false`.

Este resultado incluye la latencia entre llamadas del agente y la escritura de ocho caracteres por separado. **No permite atribuir 96,337 s a procesamiento de BayStream ni afirmar que una persona tarda eso.** Tampoco permite declarar conforme el requisito de menos de un minuto. No se descontaron pausas ni se sumaron fragmentos de distintos intentos. Carlos pidió que lo hiciera el agente; no se sustituyó por una medición manual suya.

Incidencias conservadas, sin cambios al producto:

1. Un primer intento de Windows quedó interrumpido por una pausa de la herramienta antes de completar los campos. Se descartó, sin guardar.
2. Otro intento se interrumpió al comprobar que `type_text` no insertaba texto en Flutter Windows. El teclado de teclas individuales sí funcionaba. Carlos escribió correctamente los niveles en ese borrador; no se utilizó esa intervención como medición continua.
3. El texto auxiliar se preparó en una pestaña nueva de Bloc de notas y se pegó mediante el menú contextual del campo. No se editaron documentos previos del usuario. La pestaña auxiliar contiene solo datos sintéticos de prueba.
4. Al preparar inicialmente el banco temporal se retiró erróneamente `Firebase.initializeApp`, lo que produjo `[core/no-app]` al construir el repositorio usado por el parser. No se leyó A07 ni se guardó perfil en ese intento. Se restituyó el arranque original del banco temporal, con sesión y sincronización locales explícitas, y se recompilaron los tres clientes finales. Registro `bank-incident.txt`. No se cambió producción ni se ejecutaron operaciones de nube.
5. Algunos volcados del Honor no obtuvieron XML durante una transición. Se observaron de nuevo las pantallas antes de continuar; no se guardaron volcados sin sanitizar.
6. La revisión automática rechazó inicialmente un comando compuesto de servidor y Chrome; no se ejecutó. Se utilizó después el flujo específico `flutter run -d chrome`. Al inspeccionar Chrome, Computer Use detuvo el control por la comprobación de URL; Carlos autorizó el integrado. Tras cerrar Chrome, Carlos pidió retomar Windows y el control de BayStream volvió a funcionar.

**SEMÁFORO:** se anunció el inicio y el cierre de las mediciones. Durante la medición final de Windows no se usó el Honor ni se ejecutó Flutter. Al terminar se cerraron los procesos de esta prueba; el turno de Flutter quedó libre.

## 16. Veredicto anterior a la medición manual (histórico)

**T-56 queda pendiente y no se declara aceptada.** Están conformes los puntos 1–3 de la primera etapa, los casos funcionales de los tres clientes de esta etapa, los cinco textos y la huella real. Falta acreditar el recorrido de Windows en menos de un minuto. El último intento continuo no lo acredita.

Se aplica la instrucción directa de Carlos: «Si algo no cuadra, te detienes y avisas. No lo arreglas de paso». Se detuvo la aceptación y se notificó el resultado. **No se arregló ni se modificó el producto. No se inició la aceptación de T-96**, que debía ir después del cierre de T-56. Su preparación independiente anterior permanece en `%TEMP%\baystream-t96cx-preparacion-20261016`, sin atribuirle una nueva ejecución sobre HEAD.

Único archivo modificado en el repositorio por esta entrega: `docs/T56-ACEPTACION-RESULTADOS.md`. No se creó `docs/T96-ACEPTACION-RESULTADOS.md` porque esa aceptación no comenzó.

## 17. Mensaje de la etapa detenida y Git anterior (histórico)

**Mensaje para Yov:** T-56 sigue En revisión. La aceptación cruzada verificó en los tres clientes 204 / 6 / 70, 216 propuestas al reabrir, lista 1 / 2 / 1 con tres inválidos, retirada de 70 hasta 147, declaración solo por casilla y persistencia de la expansión. Los cinco textos pasan en Honor a 360 dp y letra 2.0, claro/oscuro; quedó en 1.0. Honor cronometrado: 27,902 s. La huella real de Windows es 414 → 426: los 414 previos idénticos y solo 12 t56cx_* nuevos. La Web se probó en el integrado con autorización explícita de Carlos; Chrome no se declara probado. El intento continuo de Windows consumió 96,337 s hasta volver a perfiles, sin registrar aún el texto final en esa captura; no acredita <60 s. Incluye latencia del agente y no se atribuye a procesamiento del producto. Se detuvo por la regla de Carlos, sin arreglos; no comenzó T-96. Copia ff14dc0, idéntica en producto al HEAD 0b2dfce. Informe: docs/T56-ACEPTACION-RESULTADOS.md.

Tres líneas:

- Los casos funcionales de los tres clientes, cinco textos y almacén real están comprobados y conformes.
- Honor da 27,902 s; Windows no acredita el límite de un minuto y T-56 no se declara aceptada.
- Se detuvo sin modificar producción; T-96 queda sin iniciar y Flutter libre.

```powershell
git add -- docs/T56-ACEPTACION-RESULTADOS.md
git commit -m "Sprint 3: documentar clientes de T-56 y medicion pendiente de Windows"
git push
```


## 18. Cierre: medición manual de Carlos, decisión 10.68

Carlos dispuso que el límite de un minuto se mida por una persona con su teléfono. El intento de 96,337 s del agente se conserva como incidencia de instrumentación y **no constituye una medición de respuesta de BayStream ni un rechazo del producto**.

Se volvió a preparar la misma compilación final de Windows, con el script de reinicio anterior y un nuevo nombre de respaldo, siempre fuera del paquete. Solo se apartaron los 12 archivos `t56cx_*`. La app se abrió mediante `explorer.exe`, PID **5864**, y se verificaron en pantalla las **12 tomas propuestas de A07** antes de dejar «Perfiles guardados» a la vista. Evidencia `windows-reset-before-manual.json`, `windows-manual-before-12.*` y `windows-manual-profiles-ready.png`.

Se esperó la ventana con Timonel. Carlos confirmó que ya no utilizaba nada. El primer recorrido suyo se detuvo para localizar la sección de tomas y se descartó como ensayo, sin atribuirle un tiempo ni un resultado. Para el segundo recorrido, se confirmó otra vez la pantalla de perfiles y se indicó iniciar el cronómetro del teléfono justo antes de abrir BUQUE GOLF. Durante la medición no se ejecutaron comandos ni se utilizó la máquina desde el agente.

**Resultado informado directamente por Carlos: «listo, en 56 segundos».** Se registra como **medición manual de Carlos, 56 s**, desde abrir el perfil hasta ver «Perfil guardado», con el recorrido de bahías `002-026/4`, filas vacías, niveles `82-86,94`, vista previa 204 / 6 / 70, Agregar y Guardar. **56 < 60: criterio conforme.** El agente no presenta este tiempo como medición propia. Registro `windows-manual-timing.json`.

Después, Capitán reabrió el perfil y observó **«Tomas de reefer (216)» y «Propuestas del archivo: cota inferior, puede haber más tomas.»**, sin cambios pendientes. Captura y árbol `windows-manual-reopened.png` y `.txt`. La app se cerró por el PID 5864 tras comprobar la ruta del ejecutable.

**Huella final, de nuevo fuera del paquete:**

- Antes de la preparación manual: **426 archivos**, `cmd.exe` 22768 ← `explorer.exe` 13864.
- Después de la medición y el cierre: **426 archivos**, `cmd.exe` 10044 ← `explorer.exe` 9800.
- Solo cambian `t56cx_device.hive`, `t56cx_operations.hive`, `t56cx_profiles.hive` y `t56cx_voyages.hive`.
- Los **414 archivos originales de la primera huella conservan su SHA**; respecto de aquella, solo existen los 12 añadidos `t56cx_*`.
- Registros: `store-before-manual.json`, `store-after-manual.json`, `store-comparison-manual.json`. La letra del Honor continúa en 1.0.

**Veredicto definitivo: T-56 aceptada.** La base de clientes ff14dc0 conserva el mismo producto en HEAD `f59afafc801e2b2c4699f2c0c47111545f6bf77a`: sus diferencias son documentos de sprint, presentación, tablero y este informe. No se modificó código de producción. `pubspec.yaml` y `pubspec.lock` no cambian. Con este cierre se continúa, en el orden solicitado, con T-96.

**Mensaje para Yov:** T-56 aceptada. Carlos cronometró manualmente Windows en 56 s según la decisión 10.68; Capitán verificó al reabrir 216 tomas y «Propuestas del archivo». Honor dio 27,902 s. Los tres clientes dan 204 / 6 / 70, lista 1 / 2 / 1 y tres inválidos, retirada hasta 147, declaración solo por casilla y expansión conservada. Los cinco textos pasan a 360 dp y letra 2.0 en claro/oscuro; Honor terminó en 1.0. La huella real conserva los 414 archivos originales y solo añade t56cx_*; la repetición manual solo modifica cuatro archivos de ese namespace. Web en el integrado con autorización de Carlos; Chrome no se declara probado. El intento de 96 s se conserva como instrumentación y no se usa para el criterio humano. Windows cerrado por PID. Informe: docs/T56-ACEPTACION-RESULTADOS.md. Se continúa con T-96; producción y pubspec.* intactos.

Tres líneas:

- Se verificaron los tres clientes, los cinco textos y el almacén real.
- Windows manual de Carlos: 56 s; Honor: 27,902 s; T-56 aceptada.
- Solo cambia este informe; se continúa con T-96 sin modificar producción.

```powershell
git add -- docs/T56-ACEPTACION-RESULTADOS.md
git commit -m "Sprint 3: cerrar aceptacion de T-56 con medicion manual de Windows"
git push
```
