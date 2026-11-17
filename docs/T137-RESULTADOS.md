# T-137 · El instalador de Windows con asistente

Fecha: 3 de noviembre de 2026. Responsable: Capitán Codex.
Carpeta: `C:\Proyectos\baystream-t137`. Rama: `t137-instalador`.

> **Nota del 3-nov (Timonel):** después de esta entrega cambiaron el aviso del
> bloqueo por MSIX y la confirmación de desinstalar, y se regeneraron los dos
> instaladores. El de producción vigente es `0e4b8b07…`, no `c6ddb83e…`. La
> corrección y su aceptación están en `docs/t137/revision-timonel.md`, «Corrección».

**Estado: textos corregidos, arte y ambos instaladores regenerados; aceptación automática nueva aprobada.**
La primera entrega pasó la aceptación automática y queda conservada como
evidencia. Se ajustaron únicamente los textos del arte y del recorrido
normal; los nuevos binarios pasaron el armado y el análisis final dio cero.
El primer intento de aceptación nueva se detuvo porque la MSIX estaba abierta;
se conservó y, después del nuevo aviso de Carlos, la repetición pasó con
el almacén intacto. Se guardaron siete capturas nuevas. Se conserva como
origen la Release **0.4.2** de `proyecto-baystream`, por instrucción expresa
de Carlos; la 1.0.0 se compila al publicar. Timonel hace T-138. Cada comando
de Flutter o Dart necesita luz verde individual y una línea `SEMÁFORO:`.
La pausa se respetó: no hubo comandos ni cambios durante ella. Este informe
no acredita T-137 como terminada: faltan el recorrido de Carlos y la
revisión de Timonel.

## Revisión de textos previa al recorrido

Carlos pidió tres cambios después de la revisión de Yov:

- Arte: «OFICINA Y MUELLE» y «Windows, Android y Web», conservando
  «Tu carga, a la vista.», las imágenes, los colores, las fuentes y las medidas.
- Bienvenida: «BayStream lee el BAPLIE y muestra el plano de estiba, para la
  oficina y el muelle.»
- Trato de tú mediante `[Messages]`: bienvenida y su pie, carpeta y selector,
  confirmaciones de carpeta y salida, listo para instalar, preparación,
  progreso, final y desinstalación. No se modifica el `Spanish.isl` instalado
  ni los textos de pantallas ajenas al recorrido normal.

Antes de editar se copiaron y verificaron **49 archivos anteriores** en
`build/t137/textos-antes/`: arte y manifiesto, ambos instaladores y sus
archivos de integridad, cinco capturas, los fuentes de la entrega y el
informe anterior. `manifiesto.json` registra sus SHA-256. Las aceptaciones
y logs anteriores también permanecen en sus carpetas originales.

La lógica, el AppId de cada variante, las páginas, las rutas, los accesos,
el bloqueo por MSIX, la separación de datos y la Release **0.4.2+8** no cambian.
El recorrido de Carlos se hará con los instaladores **regenerados**, no con
los archivados en `textos-antes/`. El registro histórico de la primera
entrega se conserva aparte de las corridas de esta revisión.

Corridas de esta revisión:

1. `flutter test --no-pub tool/t137_arte_test.dart`: salida **1**, **1 prueba
   fallida**. Windows impidió sobrescribir `grande_claro_200.png` con error
   **1224**, por una sección de memoria abierta. No se atribuyó el bloqueo
   a una aplicación sin evidencia y no se cerró ningún proceso ajeno.
   La carpeta de salida parcial se conservó mediante un movimiento dentro
   del workspace en `build/t137/textos-intento-01-arte/`; el destino de
   generación quedó libre. El generador no cambió fuera de las dos cadenas
   solicitadas. Evidencia: `build/t137/arte-textos-01.log`.
2. Repetición de la generación en el destino nuevo: salida **0**, **1 prueba
   aprobada**, **28 PNG** y **21 fuentes registradas**. Cambiaron solo las
   **14 imágenes grandes**; las 14 pequeñas conservan su SHA-256. Se revisó
   el arte claro al 100 % y oscuro al 250 %, con las dos líneas completas y
   sin recortes. Evidencia: `build/t137/arte-textos-02.log`.
3. Armado de prueba con los textos nuevos: salida **0**, **22.77 s**, los
   mismos **32 archivos** y **5 módulos PE**, AppId fijo y Release sin cambios.
   Evidencia: `build/t137/armado-prueba-textos-01.log`.
4. Armado de producción con los textos nuevos: salida **0**, **21.36 s**,
   los mismos **32 archivos** y **5 módulos PE**, AppId fijo y Release sin
   cambios. Evidencia: `build/t137/armado-produccion-textos-01.log`.
5. Análisis final tras los textos, con
   `flutter analyze --no-pub lib test tool/t137_instalador.dart tool/t137_arte_test.dart`:
   salida **0**, **cero incidencias**, **8.6 s**.
   Evidencia: `build/t137/analyze-textos-01.log`.
6. Aceptación exterior de los binarios nuevos: **detenida, no aceptada**.
   La comprobación previa detectó BayStream abierto como MSIX, proceso
   **27300**. No instaló, no desinstaló y no llegó a tomar la huella del
   almacén. Carlos respondió «Esperar; BayStream sigue en uso». Se conserva
   el intento en `build/t137/aceptacion-02/`; la siguiente corrida usará
   otra carpeta, sin sobrescribir este resultado. En ese intento no se operó
   la MSIX ni se cerró el proceso. La repetición siguiente resuelve la espera.
7. Con la ventana liberada por Carlos, aceptación exterior nueva
   **aprobada** en `build/t137/aceptacion-03/resultado.json`: instalación
   de prueba sin escritorio, instalación encima con escritorio y
   desinstalación, todas correctas. Se verificaron los **32 archivos** de
   carga y los **2 archivos** generados por Inno, los accesos y la entrada
   de Aplicaciones; no quedaron carpeta, accesos ni registro de prueba.
   Producción se detuvo por MSIX, salida **1**, sin carpeta ni registro
   nuevos. El proceso exterior fue Explorer **32740** → cmd **28064** →
   Windows PowerShell **34428**, con identidad **15700**, sin paquete.
   Los **592 archivos** del almacén real conservaron su huella antes y
   después: `33c6c07fb8c608bba1ca1656a9859ce8d477a2d26186f59a5eaef40f02af1040`.
8. Vista previa de los instaladores nuevos: **siete capturas reales**, en
   oscuro, guardadas en `build/t137/capturas/codex-textos/`, con el texto
   de accesibilidad de cada captura. Se revisaron bienvenida y arte,
   ambas páginas informativas, carpeta/accesos, selector de carpeta,
   confirmación de salida y bloqueo de producción. Se canceló la vista
   previa antes de instalar; el selector tampoco cambió el destino.
   Los dos asistentes quedaron cerrados y BayStream no se abrió.
   El control de Windows devuelve JPEG: se conservó ese formato como
   `.jpg`; el arte generado por Flutter sigue siendo PNG.

La verificación de archivos confirmó que el `.iss` es idéntico al anterior
fuera de `[Messages]`, que el generador solo cambia las dos cadenas
solicitadas y que `Spanish.isl` conserva su SHA-256. Los **29 archivos** de
la Release externa y `pubspec.yaml`/`pubspec.lock` conservan sus huellas;
los **32 archivos de carga**, las versiones y los AppId de ambos manifiestos
son idénticos a los anteriores. Se verificaron los **28 PNG**, sus **21
fuentes** y las **34 rutas** del bloque de Git. Evidencias:
`build/t137/textos-alcance.json` y `build/t137/verificacion-final.json`.

La copia compartida de producción se actualizó con los tres archivos nuevos
y se verificó contra sus originales. La versión anterior queda archivada.
El ejecutable que Carlos debe recorrer tiene SHA-256
`c6ddb83e37038aab021d66f3b707e619b7964c0eca7a067b1c65b2c249d46b06`.

## 1. Paso 0: comprobaciones realizadas

- `HEAD`: `8ea84bd`, decisión 10.100, en `t137-instalador`.
- Al llegar, `git diff --stat`, `git diff --cached --stat` y
  `git diff --stat HEAD` no mostraron cambios versionados.
- La comparación de los archivos no ignorados con los árboles de `HEAD`
  mediante consultas `git show` inspeccionó 1,972 archivos en 184
  directorios: ninguno nuevo fuera de Git.
- `ISCC.exe --version` devolvió `7.1.1`. Existe
  `C:\Users\Giova\AppData\Local\Programs\Inno Setup 7\Languages\Spanish.isl`.
- Se leyeron los acuerdos del proyecto, las decisiones 10.99 y 10.100,
  la identidad de T-93 y `msix_config`, y el diseño de «Puente de mando».
- Release externa comprobada después del aviso de Carlos:
  `C:\Proyectos\proyecto-baystream\build\windows\x64\runner\Release\baystream.exe`.
  Producto BayStream, versión textual **0.4.2+8**, recurso numérico
  **0.4.2.8**, 15,931,392 bytes. La carpeta contiene **29 archivos**.
  SHA-256 del ejecutable:
  `b3389a8a3a9402703c10a446a74e5352360424c56baa89b344148f0cad44f041`.
- El lock externo resuelve `firebase_core 4.13.0`, `cloud_firestore 6.8.0`
  y `flutter_riverpod 3.1.0`. El CMake del `firebase_core` resuelto pide
  **13.9.0** y el `version.h` de `extracted` declara **13.9.0**: coinciden.
- El SDK identificado en el CMake generado es `C:\flutter`; su
  `flutter.version.json` declara Flutter **3.38.9** y Dart **3.10.8**.
  Estas son lecturas, no nuevas ejecuciones de esos SDK.
- Se guardó `build/t137/lectura-release-0.4.2.json` con la huella y el tamaño
  de los **29 archivos**, que suman **89,298,235 bytes**. Es una lectura de
  origen; no es una corrida del programa de armado ni de la aplicación.
- Se localizaron las tres DLL de Visual C++ en System32, todas con versión
  **14.51.36231.0**. El armado copió las tres, comprobó arquitectura x64 y
  registró sus versiones y SHA-256.
- Se encontró dumpbin en Visual Studio Community:
  `C:\Program Files\Microsoft Visual Studio\18\Community\VC\Tools\MSVC\14.51.36231\bin\Hostx64\x64\dumpbin.exe`.
  También hay una copia de BuildTools 14.50.35717. El armado ejecutó la
  auditoría con la copia x64 de Community.

No se ejecutó `git status` ni ninguna escritura de Git. BayStream y la MSIX
no se abrieron ni se desinstaló la MSIX. Solo se instaló y desinstaló la
variante de prueba. El almacén real se leyó para calcular sus huellas,
desde fuera del paquete, sin escribir en él.

## 2. Implementación escrita

### `windows/installer/baystream.iss`

Asistente en español, por usuario, sin elevación, para Windows 10/11 de
64 bits. Seis páginas: bienvenida, qué se instala, lo que hay detrás,
carpeta y accesos, progreso y final. El acceso en Inicio es obligatorio;
el del escritorio es opcional en la misma página que la carpeta. Las
tareas nativas permiten también `/TASKS=escritorio` en aceptación.

La producción consulta `Get-AppxPackage` solo en la cuenta actual. Si
encuentra `gt.cmartinez.baystream`, o si falla esa comprobación, se detiene
sin copiar la aplicación. Repite la comprobación justo antes de instalar.
No desinstala la MSIX. El texto explica cómo quitarla desde Configuración
y que los datos externos permanecen.

El destino predeterminado es `%LOCALAPPDATA%\Programs\BayStream`. Se
rechazan el almacén, sus descendientes y sus padres como destino, así como
la carpeta de la otra variante. Inno registra sus propios archivos y
accesos para desinstalarlos; la única limpieza adicional retira `{app}` si
está vacía. No hay una regla de borrado para `%LOCALAPPDATA%\BayStream`.

El mismo AppId permite instalar encima, con `CloseApplications=yes` y sin
reiniciar automáticamente la aplicación. La variante de prueba usa otro
nombre, carpeta y accesos, omite el bloqueo de la MSIX y no contiene una
orden `[Run]` para abrir la app.

### `tool/t137_instalador.dart`

Programa de Dart estándar, sin paquetes ni cambios de dependencias. Acepta
`--origen`, `--variante produccion|prueba` y `--salida`; también `--help`.
`--origen` admite la raíz que compiló la app o su carpeta Release, con la
estructura original. Por alcance de esta tarea, `--salida` debe quedar en
`build/t137` de este worktree o una subcarpeta suya.

Lee la versión numérica de cuatro componentes del recurso PE. Esa versión
se utiliza en `AppVersion`, en la información del instalador y en su
nombre; conserva también las versiones textuales del ejecutable en el
manifiesto. Para la Release comprobada corresponde **0.4.2.8**, leída del
recurso, y no la versión **0.4.2.0** del contenedor MSIX.

La identidad se lee del `msix_config` de la carpeta de origen. Las versiones
de los paquetes salen de su `pubspec.lock`; se comprueba que el
`firebase_core` resuelto tenga esa misma versión. Compara el
`FIREBASE_SDK_VERSION` de su CMake con las tres macros de `version.h` en
`extracted`. Si difieren, aborta sin modificar el SDK ni la Release.
Flutter y Dart se leen de `flutter.version.json` del SDK identificado por
el archivo generado de la compilación, y se cruza con `package_config`.
La lectura del archivo real mostró que Flutter usa
`file(TO_CMAKE_PATH "C:\\flutter" FLUTTER_ROOT)`: se adaptó el lector para
esa forma, además de `set(FLUTTER_ROOT ...)`, sin imprimir `DART_DEFINES`.
Este formato real quedó verificado durante los dos armados correctos.

Copia la Release completa y agrega junto al ejecutable las tres DLL de
Visual C++ si no venían ya incluidas. Comprueba su arquitectura x64 y
registra origen, versión, tamaño y SHA-256. Busca en System32 y en el
redistribuible de Visual Studio.

Inspecciona cada EXE y DLL con `dumpbin /dependents`. Una dependencia debe
estar junto al ejecutable o ser una DLL admitida de Windows 10/11 o un
contrato API-set. Una DLL de terceros presente en System32 no se acepta
solo por estar en esta máquina. Si falta dumpbin, aborta y explica la
alternativa de `llvm-readobj --coff-imports`, pendiente de acordar y validar;
no la sustituye silenciosamente.

Una lectura nativa preliminar de los cinco módulos esperados (EXE, motor
Flutter y las tres DLL del runtime) se guardó en
`build/t137/lectura-dependencias-native.txt`. Mostró que el motor también
importa `UIAutomationCore.dll`; se agregó a la lista de DLL del sistema
admitidas. Es el componente de accesibilidad de Windows documentado por
[Microsoft, UI Automation Overview](https://learn.microsoft.com/en-us/windows/win32/winauto/uiauto-uiautomationoverview).
Su presencia y editor Microsoft se comprobaron en System32. Ambos armados
repitieron la auditoría sobre sus cinco módulos PE y la carga final.

Verifica las huellas del origen y de los metadatos durante el armado,
comprueba el arte antes y después de ISCC, y verifica nuevamente la carga.
Las corridas conservan logs y preparaciones anteriores; no hay borrados
recursivos. ISCC recibe un include generado con las versiones y los colores.
El programa deja el instalador, su `.sha256`, un manifiesto JSON del payload
y el manifiesto del compilador de Inno. Se generaron y verificaron los dos
instaladores descritos en la sección 4.

### `tool/t137_arte_test.dart`

Una prueba de widget fuera de `test/`, para ejecución explícita. Reutiliza
`BayStreamTema`, `BsPaleta`, la escala tipográfica, `BsFondoDePlano`, el
pintor de `BsIlustraciones.inicio` y el ícono PNG de la MSIX. Carga las
fuentes con `t117CargarFuentes` y fija la reducción de movimiento.

El diseño contempla 28 PNG: grande y pequeña, claro y oscuro, en las siete
escalas de Inno. El manifiesto registra archivo, medida, escala, tema y
SHA-256, además de las huellas de las fuentes del diseño. El armado rechaza
arte cuyo archivo, dimensiones, contenido o fuentes hayan cambiado.

Las medidas siguen la ayuda oficial de
[WizardImageFile](https://jrsoftware.org/ishelp/topic_setup_wizardimagefile.htm)
y [WizardSmallImageFile](https://jrsoftware.org/ishelp/topic_setup_wizardsmallimagefile.htm).
Los colores de fondo y las imágenes usan las variantes `DynamicDark` de
[WizardStyle](https://jrsoftware.org/ishelp/topic_setup_wizardstyle.htm).
El tema de Windows se consulta al arrancar el asistente: hay que cerrarlo y
abrirlo de nuevo para probar el otro tema. Los controles del motor conservan
su estilo nativo y sus adaptaciones de alto contraste.

### `tool/t137_aceptacion.ps1`

Arnés nativo de aceptación, ejecutado en una ventana reservada por Carlos.
El modo `-Preparar` escribe un `.bat` bajo `build/t137/`, lanzado mediante
`explorer.exe`. Antes de tomar huellas, el arnés
registra los procesos padres, exige un ancestro Explorer, consulta la
identidad del proceso y requiere `APPMODEL_ERROR_NO_PACKAGE` (15700).

Con BayStream cerrado y la MSIX presente, toma la huella del almacén real,
instala solo la variante de prueba, verifica payload y archivos generados
por Inno, registro y accesos; instala encima con escritorio, desinstala y
comprueba los residuos. Después ejecuta producción solo para comprobar el
bloqueo por MSIX. Toma otra huella incluso si falla un paso. No abre
BayStream, no desinstala la MSIX y no escribe en el almacén. Se detiene
si encuentra una instalación previa de la variante o un proceso BayStream.

El parser de PowerShell comprobó su sintaxis. La corrida exterior pasó;
el resultado y los registros están en `build/t137/aceptacion-01/`.

## 3. Identidades permanentes

| Variante | AppId | Nombre | Carpeta predeterminada |
|---|---|---|---|
| Producción | `{D837B138-34EF-4B47-9B86-58295383D542}` | BayStream | `%LOCALAPPDATA%\Programs\BayStream` |
| Prueba | `{71B5E2CB-F84C-46C9-A7CA-684EA57A5137}` | BayStream (prueba T-137) | `%LOCALAPPDATA%\Programs\BayStream-Prueba-T137` |

Estos GUID quedan fijados en el programa de armado y no se regeneran al
cambiar la versión. El editor es Carlos Martínez. La identidad de la MSIX
permanece `gt.cmartinez.baystream`; no es el AppId del nuevo instalador.

## 4. Corridas y evidencia

| Validación | Estado |
|---|---|
| Existencia y versión de la Release 0.4.2 externa | Comprobadas: 0.4.2+8 / 0.4.2.8, 29 archivos |
| SDK C++ extraído frente al pedido por firebase_core | Comprobado por lectura: 13.9.0 = 13.9.0 |
| Huellas de los archivos de la Release | Guardadas en lectura-release-0.4.2.json; 29 archivos, 89,298,235 bytes |
| dumpbin y las tres DLL del runtime | Dos armados correctos; 32 archivos y 5 módulos PE en cada uno |
| Formato de los dos Dart | Salida 0; 2 archivos cambiados; 0.01 s informado por el formateador |
| Preparación local de dependencias | Salida 0, offline y enforce-lockfile; pubspec.* conserva sus huellas |
| Análisis de lib, test y los dos Dart | Tras los textos: salida 0, cero incidencias, 8.6 s |
| Sintaxis y ejecución del arnés PowerShell | Parser sin errores; aceptación exterior aprobada |
| Prueba del arte | Regeneración de textos aprobada: salida 0, 1 prueba, 28 PNG |
| Rechazo de SDK C++ distinto | Dos rechazos esperados; final 2.32 s, sin carpeta de salida |
| Primer empaquetado de prueba | Interrumpido en consulta de huellas, salida 1; antes de copiar y llamar a ISCC |
| Armado de prueba con textos nuevos | Salida 0, 22.77 s totales |
| Armado de producción con textos nuevos | Salida 0, 21.36 s totales |
| Instalación silenciosa de prueba, encima y desinstalación | Textos nuevos aprobados; payload, accesos, registro y ausencia de residuos |
| Huellas del almacén real desde fuera del paquete | Nueva corrida: idénticas, 592 archivos, proceso sin paquete (15700) |
| Bloqueo de producción ante la MSIX | Binario nuevo aprobado: salida 1, sin copiar ni registrar la app |
| Vista de las páginas del asistente | Siete capturas nuevas; cinco anteriores conservadas |
| Recorrido de Carlos en claro y oscuro | Pendiente |
| Revisión final de Timonel | Pendiente |

Registro histórico de ejecuciones autorizadas de la primera entrega
(las de los textos nuevos están al principio del informe):

1. `dart format tool/t137_instalador.dart tool/t137_arte_test.dart`: salida
   **0**, dos archivos formateados, **0.01 s** según el propio formateador.
   Advirtió que no resolvía `flutter_lints`: todavía no había
   `package_config` en este worktree. No es un resultado de `analyze`.
   Evidencia: `build/t137/formato-01.log`.
2. `flutter pub get --offline --enforce-lockfile`: salida **0**.
   `pubspec.yaml` y `pubspec.lock` conservaron sus SHA-256; sus huellas
   previas están en `build/t137/pubspec-antes.json`. La herramienta anunció
   16 versiones nuevas disponibles, pero no se cambió ninguna dependencia.
   Evidencia: `build/t137/pub-get-01.log`.
3. `flutter analyze --no-pub lib test tool/t137_instalador.dart tool/t137_arte_test.dart`:
   salida **1**, **6 errores y 4 avisos**, **39.0 s** según el analizador.
   Todos están en `t137_instalador.dart`: tres usos de `map(File)` necesitan
   `map(File.new)` (dos errores por uso); dos elementos de lista usaban
   literales adyacentes y dos `if` necesitaban llaves. Se corrigieron esos
   diez diagnósticos; la segunda corrida verifica su corrección.
   `lib`, `test` y el generador de arte no reportaron incidencias.
   Evidencia: `build/t137/analyze-01.log`.
4. Segunda ejecución del mismo análisis: salida **0**, **cero incidencias**,
   **4.7 s**. Evidencia: `build/t137/analyze-02.log`.
5. `flutter test --no-pub tool/t137_arte_test.dart`: salida **0**, **1 prueba**
   y **28 PNG**, en siete escalas y dos temas, con **21 archivos fuente**
   registrados en el manifiesto. La inspección visual al 250 % encontró que
   `Center` permitía al `FittedBox` conservar su tamaño original: el PNG
   medía lo correcto pero el contenido quedaba pequeño. **Ese arte no se
   acepta.** Se conserva, junto con el generador original, en
   `build/t137/arte-intento-01/`; log en `build/t137/arte-01.log`.
   Se quitó ese `Center` y se añadió una aserción del tamaño renderizado;
   la segunda corrida comprueba esa corrección.
6. Segunda ejecución del arte: salida **0**, **1 prueba aprobada**, **28 PNG**.
   La aserción nueva comprueba que `FittedBox` ocupa cada lienzo. La revisión
   visual de las imágenes grandes claras/oscuras y la pequeña oscura al
   250 % confirma que el contenido ya escala y no está recortado.
   Evidencia: `build/t137/arte-02.log` y `windows/installer/arte/`.
7. Prueba negativa con el fixture aislado
   `build/t137/negativos/sdk-distinto/origen`: el ejecutable es una copia
   del real; `version.h` es deliberadamente sintético, **0.0.1**. El
   programa rechazó ese SDK frente a **13.9.0**, salida **1 esperada**, sin
   crear la carpeta de salida ni llamar a ISCC. No se ejecutó BayStream.
   Evidencia: `build/t137/sdk-distinto-01.log`.
8. Primer armado de prueba con la Release real: se bloqueó una consulta de
   huellas por PowerShell antes de crear `corridas/`, copiar la carga o
   llamar a ISCC. Se identificó la cadena propia Dart 25564 → dartvm 28868
   → PowerShell 11956 y se interrumpió solo ese PowerShell. El programa
   devolvió **1**; la corrida es **no válida**. No se tocaron procesos
   ajenos. Evidencia: `build/t137/armado-prueba-01.log`.
   Se sustituyó el transporte que esperaba EOF de stdin por una variable
   de entorno de la consulta, con lotes de 16 archivos, límite de tamaño
   y espera máxima de 45 s.
9. Segundo armado de prueba: terminó en **2.49 s**, salida **1**, antes de
   copiar. La consulta ahora devuelve el error concreto: Windows PowerShell
   no reconoce `Get-FileHash`. El entorno del agente usa PowerShell Core
   **7.6.5**; se aisló `PSModulePath` del hijo a los módulos nativos de
   Windows PowerShell y se pasó el cálculo SHA-256 y la lectura de recursos
   PE a las API de .NET. El arnés nativo también usa el SHA-256 de .NET.
   No se cambia el entorno global. Evidencia:
   `build/t137/armado-prueba-02.log`. La tercera corrida verifica la corrección.
10. Tercer armado de prueba: salida **0**, **24.17 s** de extremo a extremo;
    ISCC informó **12.297 s** de compilación. Copió los **29 archivos**
    originales y agregó **3 DLL**, con **32 archivos** de carga y **5 módulos
    PE** verificados. Las huellas del origen no cambiaron. Evidencias:
    `build/t137/armado-prueba-03.log` y la carpeta `prueba-*` de `corridas/`.
11. Armado de producción: salida **0**, **21.89 s** totales, los mismos
    **32 archivos** de carga y **5 módulos PE**, origen sin cambios.
    Evidencia: `build/t137/armado-produccion-01.log` y `produccion-*` en `corridas/`.
12. Aceptación exterior por `.bat` y Explorer: **aprobada**. El registro
    acredita Explorer → cmd → Windows PowerShell y código de identidad
    **15700**, sin paquete. Primera instalación sin escritorio; segunda
    encima, con escritorio; desinstalación sin carpeta, accesos ni registro
    residuales. En ambas instalaciones coinciden los **32 archivos** del
    payload; también se registran las huellas de los **2 archivos** del
    desinstalador que genera Inno. Producción se detiene por MSIX, salida
    **1**, sin copiar ni registrar la app. Evidencia completa:
    `build/t137/aceptacion-01/resultado.json` y sus logs e inventarios.
13. Vista previa del asistente de prueba, en oscuro: bienvenida, «Qué se
    instala», «Lo que hay detrás» y carpeta/accesos. Se canceló antes de
    instalar. Se capturó también el mensaje de bloqueo de producción y se
    cerraron ambos asistentes. Un índice de la confirmación de salida no
    estaba disponible en la caché del control de Windows: se reobservó el
    diálogo y se cerró por teclado, sin pulsar Instalar. Las cinco capturas
    quedan enumeradas más abajo. BayStream no se abrió.
14. Formato final solo del armador: salida **0**, **1 archivo**, **0.02 s**.
    No se reformateó el generador del arte después de generar sus huellas.
    Evidencia: `build/t137/formato-02.log`.
15. Análisis final, mismo alcance de O-126-1: salida **0**, **cero
    incidencias**, **13.8 s**. Evidencia: `build/t137/analyze-03.log`.
16. Rechazo de SDK con el código final: salida **1 esperada**, **2.32 s**,
    mismo fixture sintético 0.0.1 frente al 13.9.0 solicitado, sin crear
    carpeta de salida ni instalador. Evidencia: `build/t137/sdk-distinto-02.log`.

La primera corrida de análisis falló y el primer arte no pasó la revisión
visual: ambos quedan registrados junto con los dos armados no válidos.
El análisis final da cero. La aceptación automática de la primera entrega
pasó; la repetición con los textos nuevos también pasó en `aceptacion-03/`.
No se afirma todavía que pasó el recorrido manual de producción en una
cuenta nueva, en claro y oscuro, ni la revisión de Timonel.
`pub get` regeneró los tres archivos de
`windows/flutter/` con finales LF; `git diff --stat HEAD` no muestra cambios
de contenido, solo las advertencias conocidas de conversión a CRLF. No se
incluyen esos archivos en el bloque de Git.

### Instaladores generados

| Variante | Archivo en `build/t137/` | Bytes | SHA-256 |
|---|---|---:|---|
| Producción | `BayStream_Setup_0.4.2.8.exe` | 20,107,513 | `c6ddb83e37038aab021d66f3b707e619b7964c0eca7a067b1c65b2c249d46b06` |
| Prueba | `BayStream_Setup_0.4.2.8_prueba.exe` | 20,107,042 | `b265d0af6a0d28df73be58716a5dc5bb6d1fd059a6e2e0070f0fefe6ade745a7` |

Esta tabla corresponde a los textos nuevos. Los instaladores anteriores,
de 20,090,450 y 20,089,948 bytes, se conservan con sus hashes y manifiestos
en `build/t137/textos-antes/instaladores/` y en las corridas originales.

Cada instalador tiene su `.exe.sha256`, `.manifiesto.json` e
`.inno-manifiesto.txt`. La variante de prueba permanece en `build/t137/`
y no se copia a la entrega compartida ni se publica.

### Almacén real y capturas

Almacén usado para la aceptación **de la primera entrega**:
**`C:\Users\Giova\AppData\Local\BayStream`**,
**592 archivos**, consultado desde el proceso exterior sin paquete.
SHA-256 agregado **idéntico antes y después**:
`5280fb93d4b651b063852d4becd3c556229558bcc37fd0f5a888883486deb13c`.
Los inventarios de archivos y carpetas, `procesos.json` e
`identidad-proceso.json` están en `build/t137/aceptacion-01/`.

La aceptación **de los textos nuevos**, `build/t137/aceptacion-03/`, usó
la misma ruta real y contó **592 archivos**. Su SHA-256 agregado fue
**idéntico antes y después**:
`33c6c07fb8c608bba1ca1656a9859ce8d477a2d26186f59a5eaef40f02af1040`.
Es una ventana distinta de la primera entrega: se comparan las huellas
dentro de cada corrida, no se exige igualdad entre sesiones separadas
por el uso normal de Carlos. El intento `aceptacion-02/` no tomó huellas.

Capturas propias **anteriores al cambio de textos**, guardadas en
`build/t137/capturas/codex/` y copiadas a `build/t137/textos-antes/capturas/`:

- `01-bienvenida-oscuro.png`
- `02-que-se-instala-oscuro.png`
- `03-lo-que-hay-detras-oscuro.png`
- `04-carpeta-y-accesos-oscuro.png`
- `05-bloqueo-produccion-msix.png`

Capturas reales **de los textos nuevos**, guardadas en
`build/t137/capturas/codex-textos/`, con un `.txt` de accesibilidad por imagen:

- `01-bienvenida-oscuro.jpg`
- `02-que-se-instala-oscuro.jpg`
- `03-lo-que-hay-detras-oscuro.jpg`
- `04-carpeta-y-accesos-oscuro.jpg`
- `05-selector-carpeta-oscuro.jpg`
- `06-confirmacion-salida-oscuro.jpg`
- `07-bloqueo-produccion-msix.jpg`

Las capturas anteriores no se presentan como evidencia de los textos nuevos.
Las de progreso, final, inicio de la
app y desinstalación de producción en ambos temas corresponden al recorrido
pendiente de Carlos. No se presentan las imágenes de Flutter como capturas
de esas páginas nativas. Las evidencias bajo `build/` son locales y no
se fuerzan a Git.

No quedan comandos de Flutter o Dart solicitados sin ejecutar. Cualquier
repetición o ajuste futuro conserva la luz verde individual de Carlos.

## 5. Recorrido manual preparado para Carlos

La entrega de producción **con los textos nuevos ya está copiada y verificada** en:

`C:\Users\Public\BayStream-T137\0.4.2.8\`

Contiene exactamente el `.exe` de producción, su `.exe.sha256` y su
`.manifiesto.json`. Las tres copias coinciden con los originales; detalle
en `build/t137/entrega-public.json`. El SHA-256 del `.exe` empieza por
`c6ddb83e37038aab`; el anterior empezaba por `6a58ffbc8b9f1fbf` y ya está
archivado. La variante de prueba no está allí. La aceptación automática
y las capturas de los textos nuevos ya quedaron comprobadas.
Para este recorrido se usa la **0.4.2+8**; la 1.0.0 se compila al publicar.

1. Carlos crea la cuenta local estándar **BayStream Prueba**, sin la MSIX y
   sin datos previos de BayStream.
2. Iniciar sesión en **BayStream Prueba** y abrir
   `C:\Users\Public\BayStream-T137\0.4.2.8\BayStream_Setup_0.4.2.8.exe`.
   No abrirlo para instalar en la cuenta de Carlos: allí la MSIX lo bloquea.
3. En esa cuenta, seleccionar el modo claro de Windows. Abrir el instalador
   normalmente, sin «Ejecutar como administrador». Crear y guardar las
   capturas en `%USERPROFILE%\Pictures\BayStream-T137\claro\` de esa cuenta,
   una carpeta en la que ese usuario puede escribir.
4. Revisar las seis páginas: arte y marca; versión y separación de los
   datos; Flutter 3.38.9, Dart 3.10.8, cloud_firestore 6.8.0, firebase_core
   4.13.0, SDK C++ 13.9.0 y Riverpod 3.1.0, como el manifiesto; carpeta por usuario,
   Inicio obligatorio y escritorio opcional; progreso; final con
   «Abrir BayStream». Comprobar texto entero, ausencia de elevación y que
   el aspecto corresponde al tema. Comprobar «OFICINA Y MUELLE»,
   «Windows, Android y Web», «Tu carga, a la vista.», la nueva frase de
   bienvenida y el trato de tú durante todo el recorrido.
5. Marcar «Abrir BayStream» al finalizar. Comprobar que abre con Firebase
   real y cerrar sin iniciar sesión. Abrir desde Inicio y cerrar de nuevo.
   Si se eligió escritorio, comprobar también ese acceso.
6. Revisar Configuración → Aplicaciones: nombre, ícono, versión y editor.
   Desinstalar desde ahí y capturar el mensaje de conservación de datos.
   Comprobar que desaparecen la aplicación y sus accesos.
7. Cambiar Windows a oscuro, abrir de nuevo el instalador y repetir los
   pasos. Guardar las capturas en la subcarpeta `oscuro`. Cerrar y volver a
   abrir el asistente tras cambiar el tema: se elige al arrancar.
8. Carlos entrega esas capturas para guardarlas en
   `build/t137/capturas/carlos/`. Las siete nuevas del agente están separadas
   en `build/t137/capturas/codex-textos/`, y las cinco anteriores permanecen
   en `build/t137/capturas/codex/`. El recorrido y las capturas de Carlos
   siguen pendientes y no se dan por aprobados.

Nadie inicia sesión en Firebase durante este recorrido. El almacén que
abra la app en la cuenta de prueba se documentará por su ruta real; no es
el almacén de Carlos.

Lista de capturas esperadas por tema: bienvenida; qué se instala;
tecnologías; carpeta/accesos; progreso, si se alcanza a capturarlo; final
con la opción de abrir; app abierta desde el final; app abierta desde
Inicio; entrada de Aplicaciones; mensaje al terminar de desinstalar.
Si el progreso termina antes de capturarlo, se anota y no se inventa una
captura. Se usa solo la ventana de BayStream o del asistente, sin datos de
cuentas del sistema. Carlos informa también la versión, tema, escala de
Windows y cualquier fallo observado; Timonel revisa luego esta entrega.

## 6. Límites declarados

- Instalador y desinstalador sin firma de código comercial. Una descarga
  desde internet puede activar el aviso de SmartScreen.
- No se dispone de Windows limpio sin runtime de Visual C++ para probarlo.
  La auditoría de DLL es necesaria, pero no acredita esa ejecución.
- Las dependencias cargadas dinámicamente pueden no aparecer en las tablas
  de importaciones. La aceptación manual sigue siendo necesaria.
- El manifiesto JSON de armado describe los archivos de la Release y el
  runtime agregado. Inno genera sus archivos `unins000.exe` y
  `unins000.dat` al instalar; sus huellas exactas están registradas en
  `instalar-1-archivos.json` e `instalar-2-archivos.json` de la aceptación,
  separadas del payload. No se inventaron huellas antes de instalar.
- La variante de prueba nunca se publica ni se abre en la cuenta de Carlos.

## 7. Archivos y Git

Archivos nuevos de la entrega (**34**):

- `windows/installer/baystream.iss`
- `tool/t137_instalador.dart`
- `tool/t137_arte_test.dart`
- `tool/t137_aceptacion.ps1`
- `docs/T137-RESULTADOS.md`
- `windows/installer/arte/grande_claro_100.png`
- `windows/installer/arte/grande_claro_125.png`
- `windows/installer/arte/grande_claro_150.png`
- `windows/installer/arte/grande_claro_175.png`
- `windows/installer/arte/grande_claro_200.png`
- `windows/installer/arte/grande_claro_225.png`
- `windows/installer/arte/grande_claro_250.png`
- `windows/installer/arte/grande_oscuro_100.png`
- `windows/installer/arte/grande_oscuro_125.png`
- `windows/installer/arte/grande_oscuro_150.png`
- `windows/installer/arte/grande_oscuro_175.png`
- `windows/installer/arte/grande_oscuro_200.png`
- `windows/installer/arte/grande_oscuro_225.png`
- `windows/installer/arte/grande_oscuro_250.png`
- `windows/installer/arte/pequena_claro_100.png`
- `windows/installer/arte/pequena_claro_125.png`
- `windows/installer/arte/pequena_claro_150.png`
- `windows/installer/arte/pequena_claro_175.png`
- `windows/installer/arte/pequena_claro_200.png`
- `windows/installer/arte/pequena_claro_225.png`
- `windows/installer/arte/pequena_claro_250.png`
- `windows/installer/arte/pequena_oscuro_100.png`
- `windows/installer/arte/pequena_oscuro_125.png`
- `windows/installer/arte/pequena_oscuro_150.png`
- `windows/installer/arte/pequena_oscuro_175.png`
- `windows/installer/arte/pequena_oscuro_200.png`
- `windows/installer/arte/pequena_oscuro_225.png`
- `windows/installer/arte/pequena_oscuro_250.png`
- `windows/installer/arte/manifiesto.json`

`pubspec.yaml` y `pubspec.lock` **no cambian**. No se modificaron `lib/`,
`test/`, `tool/t93_msix.ps1`, `android/` ni `web/`.

Bloque completo de Git para que **Carlos** versione la entrega. Describe
los archivos concretos, sin incluir binarios ni evidencia de `build/`.
Versionar la implementación no da por aprobado el recorrido manual ni la
revisión pendiente de Timonel:

```powershell
Set-Location -LiteralPath C:\Proyectos\baystream-t137
git add -- windows/installer/baystream.iss
git add -- tool/t137_instalador.dart
git add -- tool/t137_arte_test.dart
git add -- tool/t137_aceptacion.ps1
git add -- docs/T137-RESULTADOS.md
git add -- windows/installer/arte/grande_claro_100.png
git add -- windows/installer/arte/grande_claro_125.png
git add -- windows/installer/arte/grande_claro_150.png
git add -- windows/installer/arte/grande_claro_175.png
git add -- windows/installer/arte/grande_claro_200.png
git add -- windows/installer/arte/grande_claro_225.png
git add -- windows/installer/arte/grande_claro_250.png
git add -- windows/installer/arte/grande_oscuro_100.png
git add -- windows/installer/arte/grande_oscuro_125.png
git add -- windows/installer/arte/grande_oscuro_150.png
git add -- windows/installer/arte/grande_oscuro_175.png
git add -- windows/installer/arte/grande_oscuro_200.png
git add -- windows/installer/arte/grande_oscuro_225.png
git add -- windows/installer/arte/grande_oscuro_250.png
git add -- windows/installer/arte/pequena_claro_100.png
git add -- windows/installer/arte/pequena_claro_125.png
git add -- windows/installer/arte/pequena_claro_150.png
git add -- windows/installer/arte/pequena_claro_175.png
git add -- windows/installer/arte/pequena_claro_200.png
git add -- windows/installer/arte/pequena_claro_225.png
git add -- windows/installer/arte/pequena_claro_250.png
git add -- windows/installer/arte/pequena_oscuro_100.png
git add -- windows/installer/arte/pequena_oscuro_125.png
git add -- windows/installer/arte/pequena_oscuro_150.png
git add -- windows/installer/arte/pequena_oscuro_175.png
git add -- windows/installer/arte/pequena_oscuro_200.png
git add -- windows/installer/arte/pequena_oscuro_225.png
git add -- windows/installer/arte/pequena_oscuro_250.png
git add -- windows/installer/arte/manifiesto.json
git commit -m "Sprint 4: T-137, el instalador de Windows con asistente"
git push -u origin t137-instalador
```

`build/` está ignorado: sus binarios y evidencias no se fuerzan a Git. El
arte sí se versiona bajo `windows/installer/arte/`, con rutas explícitas.
No se necesita `git add -f`.

## 8. Tres líneas y mensaje para Yov

Se creó el asistente en español, por usuario, con AppId fijos y variantes separadas.
Se regeneraron el arte y ambos instaladores con los textos pedidos; análisis en cero.
La aceptación nueva pasó con el almacén intacto; siguen el recorrido de Carlos y Timonel.

Mensaje para Yov:

> Yov: los tres cambios de texto están aplicados; arte y ambos instaladores
> 0.4.2+8 regenerados, análisis en cero. Producción nueva está en
> C:\Users\Public\BayStream-T137\0.4.2.8 (SHA-256 c6ddb83e…); lo anterior
> queda archivado. La aceptación nueva pasó: instalar, instalar encima,
> desinstalar y bloqueo por MSIX; 592 archivos del almacén con huella
> idéntica antes y después. Hay siete capturas nuevas. Faltan el recorrido
> de Carlos y la revisión de Timonel. Informe y bloque de Git actualizados;
> lib/, test/ y pubspec.* intactos.
