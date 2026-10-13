# T-89 · Entrada BAPLIE sin filtro por extensión

Capitán Codex · 13-oct-2026 · rama `sprint-3`.

**Estado: En revisión**, pendiente de aceptación cruzada de Timonel según 10.18.
La aceptación propia está completa en Windows, Honor y Chrome. Carlos confirmó
que no dispone de un iPhone: esa comprobación queda para el piloto **T-101**.

## Qué cambió

El selector BAPLIE compartido usa `FileType.any`, sin `allowedExtensions`.
Windows, Android y Web pueden elegir cualquier archivo; el selector de Excel y
los diálogos para guardar exportaciones no cambian.

La validación sigue siendo la de T-86, en el lector existente. La presentación
traduce su rechazo «sin UNH/S009 reconocible» a:

> Este archivo no parece un BAPLIE: no se reconoce su cabecera UNH/S009.
> Selecciona una exportación BAPLIE completa.

Se usa el mismo mensaje para bytes vacíos y contenido sin segmentos. El selector
añade el nombre del archivo. No se añade un segundo analizador ni se exige UNB
a los mensajes que el lector ya admite solo con UNH.

Si hay un identificador de mensaje legible pero su versión no es compatible,
se mantiene el aviso íntegro de T-86: identificador declarado, familia 2.x
admitida (SMDG20, SMDG21, SMDG22) y petición de una exportación compatible.
El rechazo sucede antes del acceso al almacén: no crea viaje ni perfil, no deja
un viaje pendiente y conserva la misma instantánea visible anterior.

**Sin cambios en lector, escritor, reglas, `lib/main.dart`, congelados H5,
`pubspec.yaml` ni `pubspec.lock`. Sin dependencias nuevas.**

## Web y regresión en clientes

`tool/t89_main.dart` es un banco reproducible con el **selector real** de cada
plataforma y el notifier real del producto. No sustituye el selector con fixtures.
Solo confirma la geometría propuesta y GTSTC para esta aceptación y permite
abrir `VesselOverviewPage`, incluida su pestaña Bay Plan. Usa `t89acc` y el
adaptador de sesión local, sin cuentas ni acciones de nube.

A07 se copió únicamente a `%TEMP%\t89-inputs` con tres nombres, conservando
sus bytes: `T89_A07`, `T89_A07.txt` y `T89_A07.edi`. Los rechazos usan un texto
corriente y dos mensajes sintéticos derivados de los fixtures T-86, con TSTU:
`T89_TEXTO.txt`, `T89_1x.edi` y `T89_3x.edi`.
En el Honor esos seis archivos de aceptación están en `/sdcard/Download/t89/`.
No se modificó la fuente externa ni entró ningún archivo del corpus al repo.

| Comprobación | Chrome visible | Windows | Honor `.t89`, 360 dp |
|---|---|---|---|
| A07 sin extensión | Elegido, validado y abierto | Cubierto por prueba de entrada; no recorrido nativo adicional | Cubierto por prueba de entrada; no recorrido nativo adicional |
| A07 `.txt` | Elegido, validado y abierto | Cubierto por prueba de entrada; no recorrido nativo adicional | Cubierto por prueba de entrada; no recorrido nativo adicional |
| A07 `.edi` | Elegido, validado y abierto | Elegido en diálogo nativo y abierto | Elegido en Archivos y abierto |
| Texto sin cabecera | Mensaje claro; conserva viaje y almacén | Igual | Igual; mensaje completo a 360 dp |
| 1.x sintética | Aviso T-86 completo; conserva estado | Igual | Igual; aviso completo a 360 dp |
| 3.x sintética | Aviso T-86 completo; conserva estado | Igual | Igual; aviso completo a 360 dp |
| Pantalla normal y plano A07 | Dibujados después de los rechazos | Dibujados después de los rechazos | Dibujados después de los rechazos |

En todos los archivos válidos observados: **398 contenedores, 0 reservas,
21 bahías, 6 940 578 kg**. En GTSTC: **0 cargas, 114 descargas, 284 de paso**.
Son las cifras de T-86 y los oráculos T-66/T-68, sin cambio.

Chrome abrió sucesivamente los tres nombres válidos: el almacén terminó con
**3 viajes y 1 perfil**. Los tres rechazos conservaron esos mismos viajes y
perfil. Windows y Honor abrieron un `.edi`: **1 viaje y 1 perfil**, conservados
en todos los rechazos. El banco coteja el JSON de los viajes y perfiles, además
de la identidad de la instantánea visible, antes y después de cada rechazo.
Esa lectura posterior pertenece al banco; la entrada rechazada no accede al
almacén, como comprueban las pruebas con un proveedor que falla si se abre.

Windows se abrió con `Start-Process explorer.exe -ArgumentList <exe>`.
El almacén real se comprobó en
`C:\Users\Giova\AppData\Local\BayStream\vessel_store`, cajas `t89acc_*`;
`t89acc_movements.hive` quedó en **0 bytes**. Se cerró solo su PID **33600**.
El Honor declaró **720×1600 px y densidad 320: 360×800 dp**. Solo se instaló
y cerró `gt.cmartinez.baystream.t89`; su almacén privado usa `t89acc`.

Chrome se sirvió únicamente en `http://127.0.0.1:8099/`, con pestaña visible y
namespace `t89acc` en IndexedDB. El conector abrió el file chooser real desde
el botón del producto y seleccionó los archivos temporales. No hubo bloqueo
de política. La pestaña propia y el servidor PID **28124** se cerraron.
No se usó `flutter test --platform chrome`, Hosting ni Play.

**iPhone:** Carlos respondió «No tengo iPhone disponible; queda para T-101».
No se atribuye una aceptación de Safari/iOS a esta sesión ni se publica esta
versión en la Web para hacerla.

## Pruebas y corpus

- **Suite final: 592/592**, frente al piso 580: **12 nuevas** de T-89.
- **`flutter analyze`: 0 incidencias**, sin ignorar avisos.
- **Corpus completo: 105/105**, los 102 anteriores más los 3 nombres de A07.
- Cada caso T-89 usa los bytes de A07 desde la carpeta externa, pasa por
  `loadVesselFromFile`, confirma, comprueba 398/21/6 940 578 y 0/114/284, y
  después rechaza un texto conservando el viaje y los perfiles del Hive temporal.
- Las pruebas de entrada comprueban cualquier tipo, ausencia de extensiones y
  solicitud de bytes; publicación solo tras confirmar; texto común, UNB sin UNH,
  UNH incompleto, bytes binarios y archivo vacío sin acceder al almacén;
  conservación del aviso 1.x/3.x y cancelación sin alterar la instantánea.
- El widget comprueba el mensaje real de `VesselOverviewPage` a 360 dp, sin viaje
  inicial y sin desbordar el aviso. La conservación del viaje anterior se prueba
  por separado en la función, los tres clientes y el corpus.
- A06 sigue rechazado por T-86. Los corpus históricos y T-84 siguen verdes;
  los casos operativos A08/A08v conservan su 460/460.

Registros solo en `%TEMP%`: `t89-directed.log`, `t89-suite-final.log`,
`t89-analyze-final.log` y `t89-corpus-final.log`.
Las pruebas y salidas de corpus usan el temporal del sistema, no `build/` del repo.
No se borró, omitió ni debilitó ninguna prueba anterior.

Comandos reproducibles desde el repositorio, uno de Flutter a la vez:

```powershell
flutter test --reporter expanded
flutter analyze
$t89corpusTests = Get-ChildItem tool -File | Where-Object { $_.Name -match 'corpus(_pdf)?_test\.dart$' } | ForEach-Object { 'tool/' + $_.Name }
flutter test @t89corpusTests '--dart-define=BAYSTREAM_CORPUS_DIRECTORY=C:\Users\Giova\OneDrive\Documentos\OneDrive\Desktop\Archivos .EDI\Anonimizados\files' --reporter expanded
```

## Compilaciones, evidencia e incidencias

Compilaciones release en serie en `%TEMP%\baystream-t89-aceptacion`, todas con
`--dart-define-from-file=C:\Proyectos\baystream-privado\firebase-prod.json`,
sin abrir ni imprimir ese archivo. La copia excluye `android/key.properties`
y claves de firma. Solo en la copia cambia el applicationId a `.t89`; se firma
con la clave de depuración para la aceptación, sin publicación.

| Build | Resultado | Duración del compilador |
|---|---|---:|
| Windows | Correcto | 57.7 s |
| APK `.t89` | Correcto | 77.9 s |
| Web | Correcto | 60.4 s |

Windows reutilizó el SDK C++ 13.9.0 de la copia privada T-82, la versión pedida
por el plugin. Avisos de build: MSB8029 por compilar bajo `%TEMP%`, APIs Android
obsoletas/operaciones no comprobadas, y familia CupertinoIcons ausente en Web.
No son avisos nuevos del análisis; `analyze` quedó en cero.
Los registros son `t89-windows-build.log`, `t89-apk-build.log` y
`t89-web-build.log`, en `%TEMP%`. Los SHA de todos los archivos de `lib/` entre
repo y copia dieron **0 diferencias**.

Capturas en `%TEMP%\baystream-t89-aceptacion\evidence`:

- Chrome: `chrome-sin-extension.png`, `chrome-txt.png`, `chrome-edi.png`,
  `chrome-texto.png`, `chrome-1x.png`, `chrome-3x.png`, `chrome-plano.png`.
- Windows: `windows-edi.png`, `windows-texto.png`, `windows-1x.png`,
  `windows-3x.png`, `windows-plano.png`.
- Honor: `honor-edi.png`, `honor-texto.png`, `honor-1x.png`, `honor-3x.png`,
  `honor-plano.png`; lecturas posteriores sanitizadas en `honor-state-safe.xml`.

Incidencias declaradas:

1. La primera compilación de la prueba nueva usó un tipo de error no exportado
   por Dart; se corrigió. El análisis inicial halló getters de conteos mal
   nombrados, una nulabilidad y avisos de estilo en los auxiliares nuevos; se
   corrigieron antes de la suite, el corpus y los builds finales.
2. Una prueba nueva con viaje abierto a 360 dp detectó un `RenderFlex` de la
   barra de acciones existente. En el Honor la cabecera también tiene acciones
   apretadas y solapamiento con la flecha de regreso del banco. La pantalla no
   se cambió: queda observado para **T-97**. El widget final comprueba el aviso
   sin viaje inicial; las comprobaciones de conservación siguen completas.
3. La primera interacción de Windows estaba dirigida a la ventana padre,
   mientras el diálogo tenía otro identificador: no seleccionó un archivo.
   Se identificó y activó el diálogo propio, se eligió el archivo y se comprobó
   el resultado. No se presenta el primer intento como una apertura válida.
4. Descargas del Honor no mostraba los archivos recién copiados aunque estaban
   presentes. Se abrió la raíz HONOR → Download → t89 del selector y aparecieron
   los seis archivos. No se modificaron permisos, cuentas ni ajustes del sistema.
5. **Privacidad:** el primer volcado del selector del Honor incluyó los
   identificadores de cuenta que Drive muestra en su lista de proveedores.
   Capitán lo informó y eliminó el temporal local y el volcado del teléfono.
   Se pasó a `adb exec-out uiautomator dump /dev/tty`, capturando la salida en
   memoria y ocultando los identificadores antes de mostrarlos o escribir una
   evidencia. Las siguientes lecturas ya mostraron «cuenta oculta». No se
   introdujeron contraseñas ni se incluyen identificadores en el informe.
6. Una captura del plano de Chrome caducó mientras Windows lo cubría. Tras
   cerrar el PID propio de Windows, la captura del mismo plano pasó. No se
   recargó ni se cambió el viaje para resolver la captura.

## SHA y límites

SHA-256 anterior y posterior, idénticos:

| Archivo | SHA-256 |
|---|---|
| Reglas T-80 publicadas | `21894B7F43E59F856045473731B795D21F8373C5AC8A1D9FFF324334AC3C9000` |
| Lector BAPLIE | `5D8C843E54D94250E5AE716B839C3000B9A8F7BD4760A5092DD6DC0EFFC4802F` |
| Escritor T-82 | `05EE91981499215E9981094EE3C3230C00AB98C54F4793B8750880D23E656147` |
| `lib/main.dart` | `C5189B1D8711837A05C68306D424C9FDBCC977BA3BBB6C823089FFE4CA5339D5` |
| `pubspec.yaml` | `14916474A1874780E0D5851F9AFB4AE46A4B6B75286D4B497919DE38B7509E9F` |
| `pubspec.lock` | `FAA283751D6D97B1F87059EA683B4CC12ED43DDF6E92A52C1B993A801A510C97` |

Las reglas son la propuesta que Carlos publicó; no se leyeron desde producción
con credenciales de administrador ni se volvió a ejecutar su batería en T-89.
La aceptación de T-84 ya la dejó en 69/69; T-89 no cambia la nube ni payloads.
No hubo Firebase CLI, deploy, publicación de Web/Play, acciones contra H5,
Git de escritura ni `git status`. Los cuatro documentos ajenos que tenían
cambios al comenzar quedaron intactos. No se tocó AGENTS, SPRINT ni documentos
de otras tareas.

## Archivos exactos de T-89

- `lib/features/vessel/presentation/formatters/vessel_error_message.dart`
- `lib/features/vessel/presentation/providers/vessel_providers.dart`
- `test/support/t89_file_picker.dart`
- `test/t89_file_input_test.dart`
- `tool/t89_corpus_test.dart`
- `tool/t89_main.dart`
- `docs/T89-RESULTADOS.md`

## Horas

Inicio registrado: **13-oct-2026, 00:30:18 (Guatemala)**. Cierre de aceptación y
liberación de clientes: **00:57:17**, 0.45 h. Cierre del informe: **00:59:19**.
**Total registrado: 0.48 h frente a 1.0 h estimada**, incluyendo lecturas,
implementación, correcciones, compilaciones, recorridos y redacción.
Es tiempo de pared, no una medición de esfuerzo activo ni de latencia H5.

## Git para Carlos

Solo siete rutas propias; Codex no ejecuta estos comandos. El informe se incluye
por la autorización de esta tarea y la excepción permanente de AGENTS.

```powershell
git add -- "lib/features/vessel/presentation/formatters/vessel_error_message.dart"
git add -- "lib/features/vessel/presentation/providers/vessel_providers.dart"
git add -- "test/support/t89_file_picker.dart"
git add -- "test/t89_file_input_test.dart"
git add -- "tool/t89_corpus_test.dart"
git add -- "tool/t89_main.dart"
git add -- "docs/T89-RESULTADOS.md"
git commit -m "Sprint 3: T-89 abrir BAPLIE por contenido sin filtro de extension"
git push
```

## Tres líneas

Selector BAPLIE sin filtro de extensión en Windows, Android y Web.
Rechazo claro sin cabecera, conservación del viaje y avisos T-86 intactos.
592 pruebas, analyze 0, corpus 105/105; En revisión, iPhone para T-101.

## Mensaje para Yov

T-89 queda En revisión según 10.18. Chrome eligió A07 sin extensión, como .txt
y como .edi: 398 contenedores, 21 bahías, 6 940 578 kg y 0/114/284 en GTSTC.
El .edi normal pasó en Windows y Honor .t89 a 360 dp; los tres clientes rechazan
texto sin cabecera conservando viaje y almacén, y mantienen los avisos 1.x/3.x
de T-86. Suite 592/592 (+12), analyze 0, corpus completo 105/105. Lector,
escritor, reglas, main.dart y pubspec conservan sus SHA. Siete rutas propias;
commit propuesto «Sprint 3: T-89 abrir BAPLIE por contenido sin filtro de
extension». Carlos no tiene iPhone: queda para T-101. Se declara la incidencia
de identificadores de Drive y su mitigación; la barra de acciones estrecha queda
observada para T-97. 0.48 h de pared frente a 1.0 estimada;
pendiente aceptación de Timonel.
