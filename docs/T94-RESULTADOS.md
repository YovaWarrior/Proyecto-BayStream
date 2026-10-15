# T-94 · Búsqueda por voz en el muelle

**Estado: En revisión.** Implementación, controles automatizados y aceptación
propia completados. Carlos aceptó manualmente el dictado del Honor, el modo avión
y las búsquedas de Windows. Falta la aceptación cruzada de Timonel (10.18).
Capitán Codex · 13-oct-2026, Guatemala · rama `sprint-3` comprobada.

## 1. Resultado

La búsqueda de T-76 («OR / últimos dígitos») incorpora un micrófono junto al
campo de su selector. También sirve en «Asignar vacío», que comparte el selector.
Solo se inicializa el reconocimiento después de pulsarlo; abrir el selector no
pide permiso ni empieza a escuchar.

El transcript se normaliza y entra **como borrador editable**. Mientras se dicta
o corrige ese borrador, las coincidencias quedan suspendidas. **Buscar** o la
acción de búsqueda del teclado confirman el texto; después se elige la fila y
se conserva la confirmación de carga existente. Reconocer voz no busca, no
selecciona una fila, no cambia bahía ni registra movimientos. La escritura manual
inicial mantiene el filtrado de T-76, incluidos OR y sufijos ambiguos.

La normalización vive en Dart puro: palabras 0–9, grupos numéricos con sus ceros,
nombres españoles de letras y variantes como «doble uve», «doble ve», «doble u»,
«i griega», «be larga» y «ve corta». Quita espacios y puntuación. Conserva las
palabras desconocidas para corregirlas; no adivina cantidades compuestas ni
interpreta órdenes. Ejemplo sintético: «te ese te u cero cero cero uno dos tres
cuatro» → `TSTU0001234`.

`VoiceRecognizer` es el contrato de dominio. Riverpod proporciona un adaptador
único del plugin por sesión. La UI cancela al cerrar, editar durante la escucha,
confirmar o abandonar la app; descarta callbacks tardíos y limita a 35 segundos
un servicio que no contesta. Los fallos dejan avisos en español y permiten buscar
manualmente. El borrador no se persiste ni se añade a Firestore.

## 2. Dependencia, permisos y soporte

**Cambian `pubspec.yaml` y `pubspec.lock`.** Se fija **`speech_to_text: 7.2.0`**:
compatible con Flutter **3.38.9 / Dart 3.10.8** instalados, sin incorporar el
soporte inicial de Windows de 7.3. La 7.5 exige Flutter 3.44 / Dart 3.12.
Fuentes: [versión 7.2.0](https://pub.dev/packages/speech_to_text/versions/7.2.0)
y [historial oficial](https://pub.dev/packages/speech_to_text/changelog).

El lock añade solo esa dependencia directa y sus transitivas
`speech_to_text_platform_interface 2.5.0` y `pedantic 1.11.1`. **No se mueve
ninguna versión preexistente.** No hay otra dependencia directa nueva.

| Plataforma | Voz del paquete 7.2.0 | Comportamiento de BayStream / verificación |
| --- | --- | --- |
| Android | Sí, sujeta al servicio y permisos | Micrófono visible; español del sistema o primer español disponible. Dictado real aceptado en el Honor. |
| Web | Sí, en navegadores con Web Speech | Se detecta `SpeechRecognition`/`webkitSpeechRecognition`; sin API se oculta. Se solicita `es-GT` explícitamente. Chrome probado muestra el botón y conserva la búsqueda manual. |
| Windows | Sin implementación nativa | Botón oculto. BayStream compiló y abrió correctamente sin invocar reconocimiento; búsquedas manuales aceptadas. |
| iOS / macOS | Sí en el paquete | Fuera de los clientes de esta tarea; BayStream no ofrece aquí el botón ni se añadieron permisos de esas plataformas. |
| Linux | No | Botón oculto; no se compiló ni aceptó este cliente. |

La tabla describe soporte del paquete y comportamiento comprobado por separado.
Su documentación marca Windows sin soporte, incluso en su fila de compilación;
**la compilación de BayStream sí pasó**, con la voz excluida por plataforma.
En Web, `locales()` del plugin no enumera idiomas instalados como Android: se
corrigió esa rama y se añadió una prueba del adaptador con lista vacía.

**Manifest Android autorizado:** se añade `android.permission.RECORD_AUDIO`
y una consulta mínima para `android.speech.RecognitionService`, necesaria desde
Android SDK 30. El permiso se solicita al usar el micrófono. El manifest combinado
de `.t94` confirma ambos y conserva `INTERNET` aportado por las dependencias
anteriores; no incorpora permisos Bluetooth. Se usa `androidNoBluetooth`.

**Implicación para T-88 (Yov):** documentar el permiso de micrófono, su uso
opcional para dictar búsquedas y que el servicio de voz del sistema/navegador puede
procesar audio remotamente. BayStream no guarda audio ni sube el transcript a
Firestore. No se promete reconocimiento sin conexión: depende del servicio y
sus modelos disponibles. La búsqueda manual sigue siendo local.

## 3. Aceptación en los tres clientes

Banco `tool/t94_main.dart`, compilado exclusivamente en
`%TEMP%\baystream-t94-clientes`. Preparó A07, A08 y el listado con los lectores
de producción, equivalencias ya comprobadas y un namespace **`t94acc`**. Los
tres assets de aceptación se agregaron solo al pubspec de esa copia temporal;
no existen en el árbol del repositorio. El banco presenta los controles reales
`LoadingControls`, su selector y su confirmación de carga. No sustituye esos
controles por una recreación ni prueba el recorrido de importación.

Los tres clientes muestran **405 contenedores, 55 reservas, carga 176 (120/56)
y descarga 114 (66/48)**. No se registraron cargas durante esta aceptación.
Se trabajó en «Solo este dispositivo», sin cuentas ni operación publicada;
Firebase se inicializó únicamente con projectId `baystream-app`, sin lecturas ni
escrituras de aceptación a Firestore.

| Comprobación | Honor `.t94` | Windows | Chrome visible |
| --- | --- | --- | --- |
| Micrófono y soporte | Visible | Oculto, comprobado también tras recompilar | Visible: API disponible |
| Contenedor completo dictado, borrador → Buscar → OR 1 | **Aceptado por Carlos**, también en APK final | No aplica a voz | No se dictó audio real |
| Últimos cuatro dígitos dictados, borrador → Buscar → OR 3 | **Aceptado por Carlos**, también en APK final | No aplica a voz | No se dictó audio real |
| Búsqueda manual OR 1 y sufijo de OR 3 | Carlos comprobó el sufijo sin red | **Aceptadas por Carlos** | Codex observó ambas y abrió las confirmaciones existentes |
| Modo avión, Wi-Fi apagado | **Carlos:** la voz falló con aviso y la búsqueda manual encontró OR 3 | No exigido | No exigido |

Carlos confirmó los dos borradores correctos, la ausencia de coincidencias antes
de Buscar y la fila encontrada después. Confirmó cancelar las cargas. Los
mensajes de aceptación inicial, modo avión y Windows se recibieron durante
aproximadamente **21:20–21:25**; la repetición de ambos dictados sobre el APK
final se recibió aproximadamente a las **21:34** del 13-oct, Guatemala. Estas
horas son ventanas de la sesión, no mediciones de latencia.

La aceptación del dictado y del modo avión es **manual de Carlos**. Codex no se
atribuye haber oído su voz ni observado el texto literal del aviso sin conexión;
los mensajes de Carlos son la evidencia de esos pasos. Los XML posteriores
mostraron el banco con los conteos conservados. No se grabó su voz.

**Honor:** `gt.cmartinez.baystream.t94`, 720×1600 px, densidad 320,
**360×800 dp**. Almacén propio bajo
`/data/user/0/gt.cmartinez.baystream.t94/files/vessel_store`, según la ruta de la
factoría Android; no se inspeccionaron sus archivos privados. La instalación
final con `adb install -r` conservó el caso. Solo se cerró `.t94`. Los volcados
se capturaron en memoria y se sanitizaron antes de mostrarse o guardarse, como
T-89; no se usaron pantallas de cuentas.

**Windows:** abierto mediante `Start-Process explorer.exe -ArgumentList <exe>`.
Almacén **real observado**:
`C:\Users\Giova\AppData\Local\BayStream\vessel_store`, cajas `t94acc_*`,
fuera del LocalCache de Codex. `t94acc_movements.hive` terminó en **0 bytes**
tras las dos sesiones. Se cerraron por PID y ruta verificada **8796** y
**18644**; la segunda reapertura usó la fuente final, recuperó los conteos y
mostró el selector sin micrófono.

**Chrome:** origen local `http://127.0.0.1:8114/`, namespace `t94acc`, ventana
visible. OR 1 abrió **022-04-02** y el sufijo de OR 3 abrió **025-06-02**;
ambas cargas se cancelaron. Tras recargar la compilación final, el micrófono
siguió visible y el sufijo volvió a encontrar OR 3. Pestaña cerrada y servidor
propio **PID 19244** detenido al terminar. No se ejecutó
`flutter test --platform chrome`.

Todas las compilaciones finales usaron
`--dart-define-from-file=C:\Proyectos\baystream-privado\firebase-prod.json`,
sin abrir ni imprimir ese archivo. No se abrió `android/key.properties`;
la copia de Android omitió ese archivo y usa firma de depuración y sufijo `.t94`.
Windows reutilizó el SDK C++ de Firebase ya disponible. SHA-256 de **todos los
archivos de `lib/`** entre repositorio y copia final: **0 diferencias**.

| Compilación release final | Resultado |
| --- | --- |
| APK `.t94` | Correcta, 52.8 s; APK 52.4 MB |
| Web | Correcta, 53.3 s |
| Windows | Correcta, 30.9 s |

Los avisos de fuentes/CupertinoIcons, comprobación WASM y MSB8029 por usar TEMP
se conservan; el primer APK también emitió avisos del código nativo de Firebase.
No son incidencias del análisis Dart.

## 4. Pruebas y corpus

| Control final ejecutado | Resultado | Registro fuera del repositorio |
| --- | --- | --- |
| Suite completa | **635/635**, frente al piso **612** | `%TEMP%\t94-suite.log` |
| Pruebas nuevas dirigidas | **23/23** | `%TEMP%\t94-directed.log` |
| Analyze | **0 incidencias** | `%TEMP%\t94-analyze.log` |
| Corpus completo, 30 archivos, incluidos PDF | **114/114** | `%TEMP%\t94-corpus.log` |

Las 23 nuevas son **6 de normalización, 12 de widget y 5 del adaptador**. Cubren
dígitos, ceros, secuencias, prefijos, variantes y ruido; borrador sin coincidencias
ni movimientos hasta confirmar; edición y confirmación por teclado; ausencia
del botón sin soporte; errores de servicio, permiso, idioma, red y falta de
resultado; cancelación, reapertura, callbacks tardíos, pausa y timeout. Los
recorridos del selector se ejercitan a 360 dp y el principal en ambos temas.
Las pruebas del adaptador usan un canal falso, verifican español explícito en
Web sin enumeración y español en Android, inicialización única y ausencia de
llamadas cuando no hay soporte. La suite no depende de micrófono ni red.

`tool/t94_corpus_test.dart` añade **2** casos a los **112** existentes.
Lee A08 y A08v_VGM desde el corpus externo y coteja las **121 filas numeradas
de cada variante**: número completo convertido a palabras de letras/dígitos y
sufijo de cuatro dígitos convertido a palabras. **242 números completos y
242 sufijos** coinciden con la búsqueda manual original, conservando posibles
ambigüedades. Quedan 176 pendientes y cero movimientos. No cambia la búsqueda
de dominio de T-76.

El corpus se leyó desde
`C:\Users\Giova\OneDrive\Documentos\OneDrive\Desktop\Archivos .EDI\Anonimizados\files`.
Entradas, salidas, almacenes, binarios y capturas permanecen en TEMP. Se usó el
patrón `*corpus*test.dart`, que incluye los PDF de T-52 y T-53.

```powershell
flutter test --no-pub
flutter analyze --no-pub
$t94Corpus = 'C:\Users\Giova\OneDrive\Documentos\OneDrive\Desktop\Archivos .EDI\Anonimizados\files'
$t94Tests = @(Get-ChildItem -LiteralPath tool -Filter '*corpus*test.dart' | ForEach-Object { $_.FullName })
flutter test $t94Tests --no-pub --dart-define="BAYSTREAM_CORPUS_DIRECTORY=$t94Corpus"
```

Cada comando Flutter se ejecutó en serie. No se modificaron ni eliminaron
pruebas anteriores. La primera prueba nueva de pausa simulaba una transición
inválida de Flutter; se corrigió a inactive → hidden → paused y su regreso.
El banco tuvo imports y llaves pendientes de corregir antes del analyze final.
No quedaron excepciones de esas corridas en los resultados finales.

## 5. Integridad, incidencias y horas

Las reglas **no cambian**. SHA-256 inicial y final de la referencia local de las
reglas publicadas, `docs/T80-firestore.rules.propuesta`:

```text
21894B7F43E59F856045473731B795D21F8373C5AC8A1D9FFF324334AC3C9000
```

La comprobación es local; no se consultó de nuevo la publicación en Firebase.
También conservan sus SHA iniciales:

| Archivo | SHA-256 |
| --- | --- |
| `firestore.rules` | `0112510984D9A16364F9752E243999C47306E0BCF82766E380DB380E8FE8E60A` |
| `lib/main.dart` | `C5189B1D8711837A05C68306D424C9FDBCC977BA3BBB6C823089FFE4CA5339D5` |
| `lib/latency_test_screen.dart` | `599310DB13A713E82FC0D6A411BE2D7757CBC2B803D772C1CAA16C471725CDFF` |
| `lib/c3_reconciliation_screen.dart` | `3AF478364A8C5386E1F921E0142DC4F847594BECA00B6743563CB09A8A4112A5` |

No se tocó H5, no se usó CLI de Firebase ni credenciales de administrador, no se
publicó nada y no se ejecutó Git que escriba ni `git status`. Los cuatro
documentos de tesis con cambios preexistentes se dejaron intactos.

**Incidencias de herramientas:** Pub falló tres veces al limpiar su descarga.
Se verificó el archivo oficial contra el SHA-256 publicado, se extrajo al cache
del paquete y `flutter pub get` resolvió el lock normalmente. No hay override
de fuente ni modificación del paquete. La automatización Windows devolvió
índices que ya no estaban en su cache y sus teclas no llegaron al campo; se
verificaron pantallas con capturas y Carlos hizo las dos búsquedas manuales.
Una captura mostró otra ventana al perder el foco: se descartó, no se guardó
como evidencia de BayStream y se recuperó la ventana correcta. En Chrome, la
primera escritura no llegó a Flutter; se enfocó el campo y se verificó la
entrada con teclas y con el resultado renderizado. No se atribuyen éxitos a
acciones que no produjeron el resultado.

**Tiempo:** aproximadamente **0.60 h de pared**, desde **21:04:51** hasta
aproximadamente **21:41** del 13-oct, Guatemala, incluida coordinación manual,
compilaciones y redacción. Cierre aproximado, sin interrupciones largas
descontadas, frente a **4.5 h estimadas**.

Evidencias bajo `%TEMP%\baystream-t94-clientes\evidence`:
`chrome-or1.png`, `chrome-or3.png`, `chrome-final-sufijo.png`,
`windows-final-sin-microfono.jpg` y su árbol de accesibilidad, más los XML
sanitizados del Honor. Las respuestas de Carlos a las preguntas de aceptación
quedan en este chat; los resultados de voz y avión no se presentan como capturas.

## 6. Archivos propios y Git para Carlos

**19 archivos**, enumerados exactamente en este bloque; incluye el manifest y
**ambos `pubspec.*` autorizados**. Ninguna ruta propia está ignorada, según las
reglas vigentes de `.gitignore`; no hace falta `-f`. Carlos ejecuta estos comandos:

```powershell
git add -- android/app/src/main/AndroidManifest.xml
git add -- pubspec.yaml
git add -- pubspec.lock
git add -- lib/features/vessel/domain/repositories/voice_recognizer.dart
git add -- lib/features/vessel/domain/services/container_voice_query.dart
git add -- lib/features/vessel/data/services/browser_voice_support.dart
git add -- lib/features/vessel/data/services/browser_voice_support_stub.dart
git add -- lib/features/vessel/data/services/browser_voice_support_web.dart
git add -- lib/features/vessel/data/services/speech_to_text_recognizer.dart
git add -- lib/features/vessel/presentation/providers/voice_recognizer_provider.dart
git add -- lib/features/vessel/presentation/widgets/voice_search_field.dart
git add -- lib/features/vessel/presentation/widgets/loading_controls.dart
git add -- test/support/t94_fake_recognizer.dart
git add -- test/t94_voice_test.dart
git add -- test/t94_voice_widget_test.dart
git add -- test/t94_speech_adapter_test.dart
git add -- tool/t94_corpus_test.dart
git add -- tool/t94_main.dart
git add -- docs/T94-RESULTADOS.md
git commit -m "Sprint 3: T-94 busqueda por voz como borrador en el muelle"
git push
```

## 7. Tres líneas y mensaje para Yov

La voz prepara un borrador editable; Buscar confirma y la carga mantiene su confirmación existente.
Carlos aceptó ambos dictados del Honor final y el modo avión; Windows oculta el micrófono y Chrome conserva la búsqueda manual.
635/635 pruebas, 114/114 corpus, analyze 0 y reglas intactas; speech_to_text 7.2.0 y RECORD_AUDIO declarados.

**Mensaje para Yov:** T-94 queda En revisión por 10.18. Commit propuesto:
`Sprint 3: T-94 busqueda por voz como borrador en el muelle`. Carlos aceptó
contenedor completo de OR 1 y sufijo de OR 3 como borradores, también en el APK
final; en modo avión la voz falló con aviso y la búsqueda manual funcionó.
Windows sin micrófono, búsquedas aceptadas manualmente por Carlos y 0 bytes de
movimientos en t94acc del almacén real; Chrome visible con soporte Web, OR y
sufijo comprobados. 635/635 frente al piso 612, 114/114 corpus (30 archivos),
analyze 0; reglas con SHA idéntico. Cambian pubspec.yaml y pubspec.lock por
speech_to_text 7.2.0 y dos transitivas, sin mover versiones anteriores; manifest
añade RECORD_AUDIO y RecognitionService, sin Bluetooth. T-88 debe describir el
micrófono opcional y el posible procesamiento remoto por el servicio de voz.
≈0.60 h frente a 4.5. No hubo publicación, acceso a H5 ni cambios en main o
reglas. Informe: docs/T94-RESULTADOS.md.

## Corrección del 15-oct

La aceptación en lote (10.38) invalida la conclusión anterior sobre el aviso
sin red: el Honor terminó tres escuchas sin mostrarlo. Esta corrección pertenece
a T-94 y no añade una estimación.

**Mecanismo:** al recibir `done`, el widget apaga el indicador y conserva durante
500 ms los callbacks de esa escucha. Un error recibido antes o durante ese
intervalo muestra su aviso. Si termina sin transcript ni error, muestra «No se
entendió el dictado. Reintenta o escribe la búsqueda.». La comprobación cuenta
texto de la escucha actual, aunque hubiera un borrador anterior. Editar,
confirmar, cerrar, pausar o iniciar otra escucha invalida los callbacks previos.
El texto no cambia al terminar ni al fallar y no se confirma ninguna búsqueda.

**Validación automatizada de la corrección:**

| Control | Resultado | Registro en `%TEMP%/baystream-t94-correccion-20261015/` |
| --- | --- | --- |
| Widget de voz | 20/20; ocho pruebas nuevas | `widget.log` |
| Suite completa | 668/668, piso 660 + 8, sin omitidas | `suite.log` |
| Analyze | 0 incidencias | `analyze.log` |
| Corpus completo | 116/116 en 31 archivos | `corpus.log` |
| T-94 dentro del corpus | Dos variantes; 242 números completos y 242 sufijos | `corpus.log` |

Los tres órdenes exigidos (`error → done`, `done → error`, `done` vacío) tienen
prueba con reconocedor falso: aparece el aviso, conserva el campo y solo Buscar
confirma. Otras cinco pruebas comprueban una segunda escucha vacía y los eventos
tardíos después de editar, confirmar, cerrar o iniciar otro dictado.

**Almacén del corpus:** antes de corregir block3 en T-104, esta corrida redirigió
`LOCALAPPDATA` solo en su proceso a
`%TEMP%/baystream-t94-correccion-20261015/corpus-localappdata`.
Así, la bitácora predeterminada de block3 quedó en TEMP, sin acceder al almacén
real. No se presenta esa corrida como la aceptación de aislamiento de T-104 ni
como una comparación de huellas del almacén real.

**Cliente preparado:** APK release `.t94`, compilado en
`%TEMP%/baystream-t94-clientes`, con 0 diferencias de SHA entre sus archivos de
`lib/` y los del repositorio. Se inicializa `baystream-app` con
`--dart-define-from-file`, sin abrir el archivo privado. Banco local de T-94,
namespace `t94acc`, sin cuenta ni movimientos. Instalación `adb install -r`
correcta; compilación en 87.4 s, 52.4 MB. No se copió ni abrió
`android/key.properties`; firma de depuración solo en la copia temporal.
SHA-256 del APK:
`8EE75B9BDE277B8C2492DB3389DFD616895A9A50E86B3315DC18E55F77CA2862`.

**Honor:** Carlos confirmó la búsqueda manual por `5568` (OR 3) sin red y los
dos dictados con red como borrador, sin resultados hasta Buscar. Realizó tres
activaciones con su voz sin red y comunicó que solo veía lo que había en pantalla.
Inicialmente interpretó que faltaba el aviso; el XML de esa pantalla contiene
«Reconocimiento en español no disponible. Puedes escribir la búsqueda.». Se
aclaró que ese texto debajo de Buscar es el aviso, no un diálogo emergente.
Codex no atribuye a Carlos una confirmación expresa de haber leído tres avisos.

**Comprobación técnica adicional, 3/3:** Codex pulsó el micrófono tres veces
consecutivas y comprobó el texto anterior tras cada una. Tres XML sanitizados:
`honor-offline-intento-1.xml`, `honor-offline-intento-2.xml` y
`honor-offline-intento-3.xml`. Modo avión activo, Wi-Fi apagado y `ping` con
«Network is unreachable». Otra activación anterior produjo «Reconocimiento sin
conexión o servicio no disponible. Puedes escribir la búsqueda.». Esta
comprobación no grabó ni simuló la voz de Carlos. La aceptación cruzada de
Timonel deberá confirmar el criterio manual sin confundir el aviso inline con
una ventana emergente.

La variante usa su directorio
privado `/data/user/0/gt.cmartinez.baystream.t94/files/vessel_store`, namespace
`t94acc`; no se inspeccionaron sus cajas privadas. Windows y Chrome no se han
reabierto para esta corrección. No se atribuyen a esta entrega sus resultados
históricos del 13-oct ni los del lote.

**Integridad:** ocho SHA iniciales/finales iguales, registrados en
`sha-antes.json`: propuesta de reglas, reglas, `firebase.json`, `main.dart`, los
dos congelados y `pubspec.*`. Referencia de reglas T-80:
`21894B7F43E59F856045473731B795D21F8373C5AC8A1D9FFF324334AC3C9000`;
`firestore.rules`:
`0112510984D9A16364F9752E243999C47306E0BCF82766E380DB380E8FE8E60A`.
Es comprobación local; no se accedió a la consola ni al proyecto H5. No hay
dependencias nuevas; **no cambian `pubspec.yaml` ni `pubspec.lock`**.
Los cuatro documentos ajenos preexistentes se conservaron.

**Archivos de esta corrección y bloque exclusivo para Carlos:**

```powershell
git add -- lib/features/vessel/presentation/widgets/voice_search_field.dart
git add -- test/t94_voice_widget_test.dart
git add -- docs/T94-RESULTADOS.md
git commit -m "Sprint 3: T-94 conserva el aviso al terminar el dictado"
git push
```

La voz conserva el error que llega alrededor de done y avisa si no reconoce texto.
El borrador se conserva y ninguna búsqueda se ejecuta automáticamente.
668/668, analyze 0 y corpus 116/116; Honor con tres avisos comprobados por XML.

**Mensaje para Yov:** corrección de T-94 implementada sobre `5163654`, con espera
de 500 ms tras done, aviso para escucha vacía y ocho pruebas nuevas. 668/668,
analyze 0 y corpus 116/116 (242 completos y 242 sufijos), aislando LOCALAPPDATA
en TEMP por 10.38. Carlos confirmó los dos borradores con red y la búsqueda de
OR 3 sin red. Tres activaciones técnicas sin red mostraron aviso (XML 3/3).
Carlos hizo también tres con su voz, pero interpretaba que faltaba el aviso;
el XML final contiene el aviso de español no disponible. Se aclaró el texto
inline; no se inventa una confirmación manual expresa de los tres mensajes.
Queda En revisión para que Timonel compruebe ese criterio.
Reglas y protegidos con los mismos SHA, sin dependencias nuevas. Commit propuesto:
`Sprint 3: T-94 conserva el aviso al terminar el dictado`. Solo tres rutas propias.
