# T-145 · Las observaciones del instalador

Fecha: 15 de noviembre de 2026. Responsable: Timonel. Acepta: GLM 5.3 (10.129).
Carpeta: `C:\Proyectos\baystream-t137`. Rama: `t137-instalador`.
Fuentes: `CLAUDE.md`, `AGENTS.md` y `SPRINT-4.md` de `baystream-rediseno` (10.99,
10.100, 10.104 a 10.106, 10.117, 10.118, 10.122 y 10.129), `docs/T137-RESULTADOS.md`
y `docs/t137/revision-timonel.md`.

**Estado: fase 1, la propuesta. Me detengo aquí:** Yov la revisa y Carlos la aprueba.
No toqué código, no corrí ningún comando de Flutter ni de Dart y no instalé nada.
Solo escribí este informe.

## 1. Paso 0

| Comprobación | Resultado |
|---|---|
| Documentos vigentes | Leídos los de `baystream-rediseno`. `CLAUDE.md` y `AGENTS.md` dicen lo mismo que los de esta carpeta. Nada del prompt choca con ellos |
| Punta de la rama | `dae3259`, «revision de T-137 y correccion del aviso de la MSIX» |
| `git diff --stat sprint-4...HEAD` | `sprint-4` está en `1ac6b62`. **35 archivos, todos de T-137:** `windows/installer/` (el `.iss` y 29 del arte), `tool/t137_*` (3), `docs/T137-RESULTADOS.md` y `docs/t137/revision-timonel.md`. 3681 líneas agregadas, ninguna quitada |
| Árbol de trabajo | Los tres `windows/flutter/generated_*` aparecen modificados desde T-137: solo cambia el fin de línea (`docs/T137-RESULTADOS.md`, «pub get regeneró…»). No son de T-145: no los toco ni van en el bloque de Git |
| Release 1.0.0 | `C:\Proyectos\proyecto-baystream\build\windows\x64\runner\Release`, solo leída: `baystream.exe` dice **`1.0.0+9`** (recurso 1.0.0.9) y trae **una** cadena, **`Firebase C++ 13.13.1`**. 29 archivos, 90,242,817 bytes |
| ISCC | `%LOCALAPPDATA%\Programs\Inno Setup 7\ISCC.exe --version` da **7.1.1** |
| Flutter de la máquina | `C:\flutter`, 3.38.9 (`flutter.version.json`), la misma del 3-nov |
| `flutter pub get` y `flutter analyze` | **Pendientes de la luz verde de Carlos**, con su línea `SEMÁFORO:` |
| Instalación de la laptop | **Pendiente: me la dice Carlos** (la MSIX 1.0.0.0 o el asistente 1.0.0.9). Cambia la aceptación: ver 3.9 |

**Un hallazgo del paso 0 que cambia O-137-3.** Las DLL de Visual C++ de System32 ya no
son las del 3-nov. Windows las actualizó a **14.51.36247.0**, con otras huellas
(`msvcp140.dll` `7c26614e…`, `vcruntime140.dll` `d1f4225d…`, `vcruntime140_1.dll`
`a7146c08…`). El asistente 1.0.0.9 de T-137 lleva las 14.51.36231.0 (`639342ea…`,
`19c293ac…`, `a253a12e…`). Con el código de hoy, armar otra vez metería las nuevas sin
que nadie lo eligiera: es justo el riesgo de O-137-3. Las de
`VC\Redist\MSVC\14.51.36231\x64\Microsoft.VC145.CRT` siguen dando las huellas del 3-nov.

## 2. Lo que ofrece Inno Setup 7.1.1 (antes de escribir `[Code]`)

Leí la ayuda oficial **de la versión instalada**, `ISetup.chm` de
`%LOCALAPPDATA%\Programs\Inno Setup 7` (del 25-oct, la misma que trae ISCC 7.1.1),
descompilada con `hh.exe` en mi carpeta temporal, y su `whatsnew.htm`. Los temas:

| Tema de la ayuda | Lo que dice, para T-145 |
|---|---|
| `[Setup]: CloseApplications` | Usa el Restart Manager de Windows, pero **solo en el instalador**: «Setup will pause on the Preparing to Install wizard page» si los archivos de `[Files]` o `[InstallDelete]` están en uso. En silencio, los cierra solo. La ayuda no lo da para el desinstalador |
| `RmSessionStarted`, `RegisterExtraCloseApplicationsResource`, `CloseApplicationsFilter` | Las tres son de esa misma sesión del instalador |
| `[Setup]: AppMutex` | Es lo único que el desinstalador revisa al arrancar. Pide que **la app cree un mutex con nombre** al abrir. El runner de BayStream no crea ninguno (`windows/runner/`, sin `Mutex`), y T-145 no cambia la app. **No sirve** |
| `whatsnew.htm` | Ningún cambio de 7.x agrega el Restart Manager al desinstalador |
| Eventos (`topic_scriptevents`) | `InitializeUninstall`: devolver `False` cancela la desinstalación. Es el punto para detenerse antes de quitar nada |
| `Exec` | Espera sin límite (`ewWaitUntilTerminated`) o no espera (`ewNoWait`). **No tiene límite de tiempo**, y `ExecAndCaptureOutput` exige esperar al final |
| `CreateOleObject` y «Using COM Automation objects» | El script usa objetos COM por `IDispatch`: con eso se consulta WMI (`Win32_Process`) dentro del desinstalador, sin PowerShell |
| `TaskDialogMsgBox` y `SuppressibleTaskDialogMsgBox` | Cuadro con botones de texto propio (`ButtonLabels`), así «Reintentar» y «Cancelar» salen en español aunque Windows esté en otro idioma. En silencio con `/SUPPRESSMSGBOXES` devuelve el botón por omisión |
| Códigos de salida del desinstalador | Cualquier salida distinta de 0 es que no terminó; no hay un código fijo para «cancelado» |
| «Uninstall Code» | Con el mismo AppId, el desinstalador usa el `[Code]` de la instalación más reciente. Instalar el nuevo encima del 1.0.0.9 de T-137 basta para que su desinstalador ya pregunte |
| `[Files]`, parámetro `Excludes` | Patrones contra el final de la ruta; con `\` al inicio, contra el comienzo |

**Conclusión:** Inno Setup 7.1.1 no trae nada que detecte la app abierta al
desinstalar sin cambiar la app. O-137-8 va con `[Code]` propio, en
`InitializeUninstall`, con WMI y un `TaskDialogMsgBox`. Lo detallo en 3.8.

## 3. La propuesta, observación por observación

### 3.1 O-137-1 (P2) · La huella de las fuentes de texto, con `\r\n` normalizado a `\n`

**Hoy, medido:** de las 21 fuentes del arte, 11 son `.dart` y 10 binarias (9 `.ttf` y
`Icon-512.png`). En esta carpeta, 10 de las `.dart` están en CRLF y una,
`tool/t137_arte_test.dart`, en LF. Ninguna trae un `\r` suelto. Las 21 coinciden hoy
con el manifiesto.

**Qué cambia:**
- `tool/t137_arte_test.dart`: la huella de una fuente `.dart` se calcula sobre sus bytes
  con cada `\r\n` cambiado por `\n`; un `\r` suelto no se toca. Las binarias, como hoy.
  La clase sale de la extensión, con una lista cerrada: `.dart` es texto; `.ttf` y
  `.png`, binarias; otra extensión detiene la generación. El manifiesto pasa a
  `schema: 2` y cada fuente dice `"finDeLinea": "normalizado"` o `"bytes"`.
- `tool/t137_instalador.dart`, `_comprobarArte`: exige `schema: 2`, aplica la misma
  regla por extensión (y se detiene si el manifiesto dice otra cosa) y calcula la
  huella normalizada con .NET en la misma consulta de PowerShell que ya usa, sin
  paquetes nuevos.
- `windows/installer/arte/manifiesto.json` se regenera con `flutter test
  tool/t137_arte_test.dart`. **Las 28 imágenes tienen que salir con las mismas huellas
  de hoy.** Si alguna cambia, me detengo y lo digo.

**Huellas normalizadas que espero** (las 10 en CRLF cambian; la de LF no):
`bs_categorico` `a8974fd6…`, `bs_colores_semanticos` `047c7362…`, `bs_ilustraciones`
`980a6fb1…`, `bs_medidas` `c0ecc3ac…`, `bs_paleta` `618a02e8…`, `bs_tema` `8cd3714a…`,
`bs_tipografia` `8b7a2891…`, `bs_fondo_de_plano` `38f86e5f…`, `bs_ilustracion`
`fa7f669e…`, `t117_oficina_support` `f552c25e…` y `t137_arte_test` `fd84d497…` (esta
última cambia otra vez porque edito el generador).

**Cómo se prueba, sin Git:**
1. Una copia en `build/t145/copia-crlf/`, hecha con un script de PowerShell, con lo que
   el armado lee: `tool/t137_instalador.dart`, `windows/installer/` (el `.iss`, las 28
   imágenes y el manifiesto), `windows/runner/resources/app_icon.ico` y las 21 fuentes.
   **Todas las de texto, en CRLF** (incluida la que aquí está en LF, y el `.iss`). El
   script anota, por archivo, los finales que dejó y las dos huellas, la cruda y la
   normalizada.
2. Desde esa copia, `dart run build\t145\copia-crlf\tool\t137_instalador.dart` contra la
   misma Release 1.0.0. Tiene que dar **el mismo instalador** (misma huella), **la misma
   carga** y **el mismo manifiesto** que el armado desde esta carpeta. Si el instalador o
   el manifiesto difieren, me detengo y muestro la diferencia.
3. Negativo: en la copia cambio un carácter de `bs_paleta.dart`. El armado tiene que
   detenerse con «El arte quedó anterior a lib/core/design/bs_paleta.dart». Muestra que
   normalizar no afloja la comprobación.

### 3.2 O-137-2 (P2) · El SDK de Firebase C++, leído dentro del `.exe`

**Qué cambia** (`tool/t137_instalador.dart`, `_metadatos`): después de comparar el
`version.h` de `extracted` con el pedido, se lee `baystream.exe` y se buscan las cadenas
`Firebase C++ x.y.z`. Se detiene si:
- no hay ninguna: «T-137: el ejecutable no trae la cadena «Firebase C++ x.y.z»; no se puede
  comprobar el SDK enlazado. No se empaqueta.»;
- hay más de una versión: «T-137: el ejecutable trae más de una versión de Firebase C++
  (…). No se empaqueta.»;
- la versión no es la que pide el `firebase_core` resuelto: «T-137: el ejecutable enlaza
  Firebase C++ 13.9.0, pero firebase_core 4.15.2 pide 13.13.1. Trampa de 10.99: no se
  empaqueta. Hay que compilar la Release otra vez con el SDK que pide firebase_core.»

El manifiesto gana `metadatos.firebaseCppExe`. La comprobación corre en el preflight,
antes de escribir nada, y otra vez al final, como el resto de `_metadatos`. La página
«Lo que hay detrás» no cambia: el número que muestra ya quedaría comprobado en el `.exe`.

**Cómo se prueba:**
- **Rechazo:** un origen de prueba en `build/t145/negativos/exe-13.9.0/`, copia de la raíz
  de `proyecto-baystream` (`pubspec.*`, `package_config`, `generated_config.cmake` y el
  `version.h` **13.13.1** de hoy) con la Release 1.0.0, pero con el `baystream.exe`
  **real de la 0.4.2+8** que guardó T-137 en `build/t137/app/` (trae «Firebase C++
  13.9.0»). Es justo el caso de O-137-2: `extracted` ya corregido y un `.exe` viejo. El
  armado tiene que salir con 1 antes de crear la salida.
- **La 1.0.0 pasa** en los armados normales, con `firebaseCppExe: 13.13.1`.

### 3.3 O-137-3 (P3) · Las DLL de Visual C++: Release, después `VC\Redist`, System32 al final

**Qué cambia** (`_buscarRuntime`):
1. si la DLL viene en la Release, esa;
2. si no, `VC\Redist\MSVC\<versión>\x64\Microsoft.VC*.CRT`, de la instancia de Visual
   Studio que da `vswhere -latest`, eligiendo la **versión más alta por número**. Hoy el
   patrón con `**` también encuentra la carpeta `onecore\x64` (otras DLL, para OneCore),
   y si sale la de `x64` es solo porque «x» va después de «o» al ordenar. Paso el patrón
   a `*`, que no baja a `onecore`;
3. System32, solo si no hay ninguna de las dos, con un aviso en la consola y en el
   manifiesto (`runtime[i].aviso` y la lista `avisos`): «T-137: AVISO: msvcp140.dll sale
   de System32 (14.51.36247.0) porque no está en la Release ni en VC\Redist. Copiada junto
   al .exe, Windows Update no la actualiza.»

**Lo que eso da hoy:** las tres salen de `VC\Redist\MSVC\14.51.36231` de Visual Studio
18 Community, **con las huellas del 3-nov**. La carga del runtime queda igual que la del
1.0.0.9 de T-137, y no se cuelan las 14.51.36247 de System32.

**Cómo se prueba:** el armado normal tiene que mostrar el origen en `VC\Redist` y las tres
huellas de arriba. El último recurso se prueba sin tocar Visual Studio: un armado de
prueba con la variable `ProgramFiles(x86)` apuntando a una carpeta vacía (sin `vswhere`) y
`T137_DUMPBIN` explícito, que ya existe. Tiene que salir el aviso, y ese instalador se
descarta.

**Límite que se declara en el informe:** copiadas junto al `.exe`, las DLL no las
actualiza Windows Update. Microsoft recomienda el redistribuible instalado en el sistema;
la guía de Flutter admite llevarlas junto al `.exe`. Para un proyecto de graduación es
aceptable, y se dice.

### 3.4 O-137-4 · La confirmación de desinstalar

`windows/installer/baystream.iss:102` dice hoy, como quedó en la 10.104:
«¿Seguro que quieres desinstalar %1? Tus datos en %LOCALAPPDATA%\BayStream se
conservan.» **No cambia.** Lo vuelve a leer Carlos en su recorrido.

### 3.5 O-137-5 · El cuadro gris en oscuro

No cambia (10.106).

### 3.6 O-137-6 (P3) · Los restos de compilación, fuera de la carga

**La lista cerrada, medida en la Release 1.0.0:**

| Archivo | Bytes |
|---|---:|
| `baystream.exp` | 1,880 |
| `baystream.lib` | 3,582 |
| `cloud_firestore_plugin.lib` | 15,981,714 |
| `firebase_auth_plugin.lib` | 13,768,340 |
| `firebase_core_plugin.lib` | 7,154,756 |
| **Total** | **36,910,272** (35.2 MiB) |

Son los mismos cinco nombres que trae la carga de la 0.4.2 de T-137. La cifra de la
10.122, 36.3 MB, no coincide con esta; con la 1.0.0 son 36.9 MB (decimales).

**Dónde se excluyen, para que decida Carlos:**
- **A (la que recomiendo): en el armador.** La lista vive en `tool/t137_instalador.dart`
  y esos archivos no se copian a `app/`, la carpeta que ISCC empaqueta. Así el manifiesto,
  la carga, el manifiesto de Inno y lo que se instala son la misma lista, y la aceptación
  ya rechaza cualquier archivo instalado que no esté en el manifiesto.
- **B (la de Yov): `Excludes` en `[Files]` del `.iss`.** Funciona igual para lo que se
  instala, pero `app/` seguiría trayendo los cinco, y el armador tendría que repetir la
  lista para que el manifiesto no los cuente. Son dos listas que pueden separarse.

**Cómo cambia la comprobación de la carga** (en las dos opciones):
- cada archivo de la Release que **no** está en la lista tiene que estar en la carga con
  la misma huella;
- los de la lista no pueden estar en la carga;
- si falta alguno de la lista en la Release, o aparece un `.lib` o un `.exp` que no está
  en ella, **aviso** y sigue: el primero no hace daño y el segundo va en la carga, como
  hoy;
- el manifiesto gana `excluidos`, con archivo, bytes, huella y motivo («biblioteca de
  enlace: la app no la usa al correr»).

**Instalar encima:** quien ya tiene el 1.0.0.9 de T-137 conserva los cinco en la carpeta
de la aplicación aunque el nuevo no los traiga. Propongo cinco líneas `[InstallDelete]`
con esos nombres exactos, solo en `{app}` (sin comodines), para que el nuevo los quite al
instalar encima.

**Tamaño:**

| | Antes (1.0.0.9 de T-137) | Después |
|---|---:|---:|
| Carga | 32 archivos, 91,114,641 bytes | 27 archivos, 54,204,369 bytes |
| Instalador | 20,211,174 bytes (`ef8f2bbb…`, medido) | unos **18.7 MB**, estimado |
| En Aplicaciones | 94.5 MB (10.106) | unos 57.6 MB, estimado |

El «después» del instalador es una estimación: comprimí las dos cargas con LZMA2 de
Python (diccionario de 64 MB, preset 9), y quitar los cinco ahorra 1.51 MB comprimidos
(de 17.16 a 15.65 MB). El de Aplicaciones resta los 36.9 MB a los 94.5. Los dos se miden
en la fase 2.

### 3.7 O-137-7 (P3) · Tres detalles

**a. El 1.0.0.9.** No cambia. Va en los límites del informe: el asistente y Aplicaciones
dicen 1.0.0.9, que es el recurso real del `.exe` (`1.0.0+9`); la MSIX dice 1.0.0.0.

**b. Un límite de tiempo para PowerShell en `ErrorMsix`** (`baystream.iss`). `Exec` no
tiene límite (sección 2), así que:
1. PowerShell se lanza con `ewNoWait`, oculto, con la carpeta de trabajo en `{tmp}`, y deja
   su resultado (0, 10 o 20, como hoy) en `t145-msix-<n>.txt` (primero un `.part` y
   después lo renombra, para no leerlo a medias). La línea de comandos lleva una marca
   única, el nombre de la carpeta `{tmp}`.
2. El asistente espera ese archivo **hasta 30 segundos**, en pasos de 100 ms. Hoy la
   consulta tarda uno o dos.
3. Si se vence: busca por WMI el PowerShell con esa marca y lo termina (es nuestro, no
   BayStream), lo anota en el registro (`T145_MSIX_TERMINADA` o `T145_MSIX_NO_TERMINADA`)
   y se detiene **antes de copiar nada**, como en los otros dos errores. Dice:

> Windows no respondió en 30 segundos si BayStream está instalado como paquete MSIX, y el
> asistente se detuvo para no instalar en la duda.
>
> Cierra el asistente y vuelve a intentarlo. Si se repite, reinicia Windows y prueba otra
> vez. No se copió ningún archivo de la aplicación.

Los otros dos mensajes y el aviso de la MSIX no cambian. El límite vale en los dos sitios
donde se consulta: al abrir el asistente y justo antes de instalar.

**Cómo se prueba:** la variante de prueba no consulta la MSIX. Para ensayar el límite,
el armador acepta `--ensayo msix-colgada`, **solo con `--variante prueba`**: compila la
consulta con `Start-Sleep -Seconds 600` en lugar de `Get-AppxPackage`, nombra el
instalador `…_prueba_ensayo-msix.exe` y lo marca `publicable: false` y `ensayo` en el
manifiesto. En producción no existe esa rama: es una constante del preprocesador, no una
opción que lea el asistente. La aceptación lo corre en silencio y comprueba:
- salida distinta de 0 en no menos de 30 s y en menos de 60;
- el registro con `T137_BLOQUEO_MSIX:` y el texto del límite;
- ninguna carpeta, acceso ni entrada en Aplicaciones;
- ningún PowerShell vivo con la marca.

**c. Los dos archivos viejos de la Release.** El armador los detecta con una regla, no
con sus nombres: un archivo de `data/flutter_assets/` es un resto si **ningún** manifiesto
de esa compilación lo nombra (`AssetManifest.bin`, `FontManifest.json`) **y** es más de
10 minutos más viejo que `AssetManifest.bin`, que Flutter escribe en cada compilación. Con
la Release 1.0.0 la regla da exactamente los dos: `NOTICES` y `AssetManifest.bin.json`,
del 15-oct. Las fuentes y los íconos los nombran los manifiestos, y los archivos propios de
la compilación (`NOTICES.Z`, `shaders`, `NativeAssetsManifest.json`) tienen la fecha de
`AssetManifest.bin`, con menos de un minuto de diferencia. El aviso:

> T-137: AVISO: la Release trae 2 archivos que esta compilación no escribió:
> data/flutter_assets/NOTICES y data/flutter_assets/AssetManifest.bin.json (15-oct-2026).
> Van en la carga y no estorban; se quitan con flutter clean y una compilación nueva.

También va en `avisos` del manifiesto.

**¿Detenerse? Propongo que no.** No hacen daño: en Flutter 3.38.9 esos dos nombres solo
los lee la Web; Windows lee `NOTICES.Z` y `AssetManifest.bin`
(`C:\flutter\packages\flutter\lib\src\services\binding.dart:202-206` y
`asset_manifest.dart:14-19`, leídos). Detenerse obligaría a
recompilar la Release que ya firmó la MSIX 1.0.0.0 publicada, y el asistente dejaría de
empaquetar ese mismo binario. Si Carlos prefiere que la próxima versión salga sin ellos,
basta un `flutter clean` antes de compilarla.

### 3.8 O-137-8 · El desinstalador pide cerrar BayStream

**Qué cambia** (`baystream.iss`, `InitializeUninstall`, antes de quitar nada):
1. Busca por WMI (`Win32_Process`) los procesos cuyo ejecutable está **dentro de la
   carpeta de la aplicación** (`{app}`), sin contar el propio desinstalador
   (`unins*.exe`). La ayuda dice que el original sigue corriendo mientras su copia en
   TEMP desinstala. La comparación es de rutas, con `PathStartsWith` y sin distinguir
   mayúsculas. Así encuentra la BayStream de esa instalación, y no la de la MSIX, la de la
   variante de prueba ni el banco de GLM, que están en otras carpetas y no le bloquean
   ningún archivo.
2. Si hay alguno, un `SuppressibleTaskDialogMsgBox` con **Reintentar** y **Cancelar**,
   en bucle: Reintentar vuelve a mirar, y Cancelar cancela la desinstalación sin haber
   quitado nada. En silencio con `/SUPPRESSMSGBOXES`, Cancelar. **Nunca cierra la app.**
3. Lo anota en el registro: `T145_APP_ABIERTA: <n> proceso(s)` y
   `T145_DESINSTALAR_CANCELADO` o `T145_APP_CERRADA`.

**Lo que ve quien desinstala** (con la variante de prueba, el nombre es «BayStream (prueba
T-137)»):

> **BayStream está abierta**
>
> Ciérrala para poder desinstalarla: mientras está abierta, Windows no deja quitar todos
> sus archivos.
>
> Cuando la hayas cerrado, pulsa Reintentar. Si prefieres no desinstalar ahora, pulsa
> Cancelar. Tus datos en %LOCALAPPDATA%\BayStream no se tocan.
>
> [Reintentar] [Cancelar]

**Si WMI falla** (no debería): no se queda trabado para siempre ni sigue sin avisar.
Pregunta:

> **No se pudo comprobar si BayStream está abierta**
>
> Si está abierta, ciérrala antes de seguir: mientras está abierta, Windows no deja quitar
> todos sus archivos.
>
> Pulsa Desinstalar para seguir o Cancelar para no desinstalar ahora. Tus datos en
> %LOCALAPPDATA%\BayStream no se tocan.
>
> [Desinstalar] [Cancelar]

En silencio, Cancelar.

**Cómo se prueba sin abrir BayStream en tu cuenta.** En la variante de prueba, con un
sustituto que no es BayStream: una copia de `%SystemRoot%\System32\PING.EXE` dentro de la
carpeta de la prueba, `t145-sustituto.exe`, corriendo `-n 900 127.0.0.1` (solo la red
local), oculta. La aceptación:
1. con el sustituto corriendo, desinstala en silencio con `/SUPPRESSMSGBOXES`: la salida
   tiene que ser distinta de 0, el registro tiene que traer `T145_APP_ABIERTA` y
   `T145_DESINSTALAR_CANCELADO`, y la carga, los accesos y la entrada de Aplicaciones
   tienen que seguir iguales. **El sustituto tiene que seguir vivo, con el mismo Id:** el
   desinstalador no lo cerró;
2. desinstala con `/SILENT`, sin suprimir los cuadros. Con UI Automation, la aceptación
   espera el cuadro, guarda su texto, pulsa **Reintentar** con el sustituto vivo y
   comprueba que el cuadro vuelve. Después cierra **su** sustituto por Id, lo borra, pulsa
   Reintentar otra vez, y la desinstalación sigue hasta el final sin residuos. Si UI
   Automation no encuentra el cuadro en 20 s, termina **su** desinstalador de prueba (que
   todavía no quitó nada), lo anota como no acreditado y me detengo; Reintentar queda
   entonces para tu recorrido.

El cuadro aparece unos segundos en tu pantalla: es de la variante de prueba, y no hay que
tocarlo.

**Límites:**
- la comprobación es al empezar. Si alguien abre BayStream entre ese momento y el final
  de la desinstalación, vuelve el caso de hoy, «Windows no pudo quitar algunos archivos»;
- si WMI se colgara, el desinstalador esperaría: COM no tiene límite de tiempo en el
  script. No lo vi nunca y no tengo cómo reproducirlo.

### 3.9 La aceptación de T-137, otra vez (`tool/t137_aceptacion.ps1`)

Por `.bat` y `explorer.exe`, como siempre, con la huella del almacén real antes y
después, tomada fuera del paquete. Cambia:
- **La evidencia y la salida en `build/t145/`.** Hoy el arnés y el armador solo aceptan
  `build/t137`. Propongo aceptar `build/t137` o `build/t145` en los dos.
- **Instalar encima de T-137:** primero se instala el `BayStream_Setup_0.4.2.8_prueba.exe`
  de T-137 (`a8952666…`, con los cinco restos), después el nuevo encima, y se comprueba
  que los cinco ya no están (`[InstallDelete]`), además de la carga, los accesos y el
  registro de siempre.
- Después, el nuevo otra vez encima con escritorio, O-137-8 (los dos pasos de 3.8), el
  ensayo del límite (3.7 b) y la desinstalación sin residuos.
- **Producción, según lo que tenga tu laptop:**
  - **con la MSIX**, como hoy: producción tiene que detenerse por la MSIX, sin carpeta ni
    registro nuevos;
  - **sin la MSIX**, el arnés lo comprueba al empezar y **se detiene antes de tocar
    nada**, salvo que se corra con `-SinProduccion`. Con ese interruptor no ejecuta
    producción ni exige que falte la entrada de producción en Aplicaciones (si tienes el
    asistente 1.0.0.9 instalado, ahí está y no se toca).

### 3.10 Lo que no cambia

La app, `lib/`, `test/`, `pubspec.*`, `android/`, `web/` y `tool/t93_msix.ps1`. Los
AppId, las páginas, los textos del recorrido normal, el aviso de la MSIX, el rechazo de la
carpeta del almacén y la variante de prueba sin «Abrir BayStream». Ninguna dependencia
nueva; Firebase no se toca.

## 4. Archivos de la fase 2

- `windows/installer/baystream.iss`: 3.6 (`[InstallDelete]`, y `Excludes` si Carlos elige
  B), 3.7 b y 3.8;
- `windows/installer/arte/manifiesto.json`, regenerado; las 28 imágenes, sin cambios;
- `tool/t137_arte_test.dart`: 3.1;
- `tool/t137_instalador.dart`: 3.1, 3.2, 3.3, 3.6, 3.7 b (`--ensayo`), 3.7 c y la salida
  en `build/t145`;
- `tool/t137_aceptacion.ps1`: 3.9;
- `tool/t145_copia_crlf.ps1` (nuevo): arma la copia de 3.1;
- `docs/T145-RESULTADOS.md`;
- `build/t145/`: evidencia, fuera de Git.

## 5. Las corridas de la fase 2, por ventanas

Cada una con tu luz verde y su línea `SEMÁFORO:`. Si coinciden con GLM, primero lo corto.
1. **Paso 0, pendiente:** `flutter pub get --offline --enforce-lockfile` y
   `flutter analyze` de todo el paquete. Si `analyze` no da cero, me detengo.
2. **El arte:** `flutter test tool/t137_arte_test.dart`, después de editar el generador.
3. **Los armados** (Dart, unos 20 s cada uno): prueba y producción desde esta carpeta;
   prueba desde la copia en CRLF; los negativos de 3.1 y 3.2; el último recurso de 3.3;
   el ensayo de 3.7 b.
4. **Windows, en tu turno y sin GLM en la app:** la aceptación de 3.9.
5. **El cierre:** `flutter analyze` de todo el paquete, en cero y sin `// ignore:`.

Después armo el instalador de la 1.0.0 en `C:\Users\Public\BayStream-T145\1.0.0.9\`, con su
huella y su manifiesto, y escribo tu recorrido corto en «BayStream Prueba»: instalar el
nuevo encima del 1.0.0.9 de T-137 (si ya no está, primero ese), mirar que en la carpeta no
quedan los `.lib`, desinstalar con BayStream abierta y leer la confirmación de O-137-4.

## 6. Lo que tiene que decidir Carlos

1. **O-137-6:** excluir en el armador (A, la que recomiendo) o con `Excludes` en `[Files]`
   (B, la de Yov). Y si van las cinco líneas de `[InstallDelete]`.
2. **O-137-7 c:** solo aviso (lo que recomiendo) o detenerse.
3. **Qué instalación tiene hoy tu laptop:** la MSIX 1.0.0.0 o el asistente 1.0.0.9. Si es
   el asistente, la aceptación corre con `-SinProduccion`.
4. **La luz verde** para `flutter pub get` y `flutter analyze` del paso 0.

## 7. Horas

Fase 1: 1.5 h (lecturas, paso 0, la ayuda de Inno Setup, las mediciones y esta propuesta).

---

# Fase 2 · El código (aprobada en la 10.130; el cero de `analyze`, en la 10.131)

**Estado: entregada.** Pasaron el arte, los armados, la copia en CRLF, los negativos, la
aceptación por `.bat` y `explorer.exe` (`build/t145/aceptacion-05/`, los ocho pasos, con el
almacén igual antes y después) y los dos `analyze` de cierre. Falta el recorrido corto de
Carlos en «BayStream Prueba» (sección 13), y después la aceptación de GLM.

## 8. El paso 0 que quedaba

| Corrida | Resultado | Evidencia |
|---|---|---|
| `flutter pub get --offline --enforce-lockfile` | Salida 0, 10 s. `pubspec.yaml` y `pubspec.lock` conservan sus huellas | `build/t145/pub-get-01.log`, `pubspec-antes.sha256` |
| `flutter analyze --no-pub`, todo el paquete | Salida 1, **7 incidencias, ninguna de T-145**: 3 en `tool/t124_main.dart` (O-126-1, falta su entrada fuera de Git) y 4 en la evidencia de T-137 bajo `build/t137/`. Me detuve | `analyze-01.log` |
| La 10.131 | Carlos aprueba contar el cero sobre el Dart versionado y copiar la entrada de T-124 | — |
| Copia de `build/t124/entradas/t124_entradas.dart` desde `baystream-rediseno` | `d4384834…` en las dos carpetas. `git check-ignore` la da por ignorada (`/build/`) | `t124-entrada.sha256` |
| `flutter analyze --no-pub lib test tool integration_test` | **Salida 0, cero incidencias**, 8.3 s | `analyze-02.log` |

## 9. Lo que cambió

**`tool/t137_arte_test.dart` (O-137-1).** La huella de una fuente `.dart` se calcula con
cada `\r\n` como `\n`; las `.ttf` y la `.png`, byte por byte; otra extensión detiene la
generación. El manifiesto pasa a `schema: 2` y cada fuente dice `finDeLinea`.

**`tool/t137_instalador.dart`:**
- **O-137-1:** `_comprobarArte` exige `schema: 2`, aplica la misma regla por extensión y
  calcula la huella normalizada con .NET, en la misma consulta de PowerShell (ISO-8859-1
  pasa cada byte a un carácter y de vuelta sin cambios);
- **O-137-2:** `_metadatos` lee las cadenas `Firebase C++ x.y.z` del `.exe` y se detiene si
  no hay ninguna, si hay más de una versión o si no es la que pide `firebase_core`. El
  manifiesto gana `metadatos.firebaseCppExe`;
- **O-137-3:** `_buscarRuntime` busca la Release, después `VC\Redist\MSVC\*\x64`, de la
  versión más alta por número y sin `onecore`, y System32 al final, con aviso. Cada DLL dice
  su `procedencia`;
- **O-137-6:** la lista cerrada `_excluidos` (los cinco nombres); no se copian a la carga,
  el manifiesto gana `excluidos` y `_comprobarGuion` exige que `[InstallDelete]` del `.iss`
  sea exactamente esa lista. Si falta uno en la Release, o aparece otro `.lib` o `.exp`,
  aviso;
- **O-137-7b:** `--ensayo msix-colgada`, solo con `--variante prueba`; nombre
  `…_prueba_ensayo-msix.exe`, `publicable: false` y `ensayo` en el manifiesto;
- **O-137-7c:** el aviso de los archivos que esta compilación no escribió, con la regla de
  3.7 c;
- `--salida` admite `build/t137` o `build/t145`; los avisos van a la consola (`T-137:
  AVISO:`) y a `avisos` del manifiesto; dos límites nuevos en el manifiesto (las DLL junto al
  `.exe` y la versión de cuatro partes).

**`windows/installer/baystream.iss`:**
- las comprobaciones del ensayo en el preprocesador: un ensayo desconocido o en producción no
  compila;
- **O-137-6:** `[InstallDelete]` con los cinco nombres exactos, solo en `{app}`;
- **O-137-7b:** `ErrorMsix` lanza PowerShell sin esperar; el código llega en un archivo de la
  carpeta temporal del asistente (primero `.part` y después renombrado). Espera hasta 30 s; si
  se vence, busca por WMI el PowerShell con esa ruta en su línea de comandos, lo termina y se
  detiene con el mensaje de 3.7 b. Registro: `T145_MSIX_TERMINADA`, `T145_MSIX_NO_TERMINADA`
  o `T145_MSIX_SIN_RESULTADO`;
- **O-137-8:** `InitializeUninstall` con `ProcesosDeLaApp`: WMI, la carpeta con
  `AddBackslash` (la condición de la 10.130) y `PathStartsWith`, sin contar `unins*.exe`. El
  cuadro y sus textos son los de 3.8. Registro: `T145_SIN_PROCESOS`, `T145_APP_ABIERTA`,
  `T145_PROCESO_ABIERTO`, `T145_DESINSTALAR_CANCELADO`, `T145_APP_CERRADA` y
  `T145_WMI_FALLO`;
- O-137-4: la confirmación sigue diciendo «¿Seguro que quieres desinstalar %1? Tus datos en
  %LOCALAPPDATA%\BayStream se conservan.».

**`tool/t145_copia_crlf.dart` (nuevo).** Copia lo que lee el armado a una carpeta de
`build/t145`, con todas las fuentes de texto (`.dart`, `.iss`, `.json`) en CRLF, conserva
las fechas y anota los finales antes y después. Lo propuse en PowerShell; lo escribí en
Dart porque en esta sesión PowerShell quedó deshabilitado.

**`tool/t137_aceptacion.ps1` (3.9).** Los pasos de T-145 y de la 10.130, descritos al
principio del archivo, con `-SinProduccion` para una cuenta sin MSIX. Ningún sustituto
queda vivo: el `finally` cierra los suyos por Id, antes de la huella final.

## 10. Las pruebas que ya corrieron

Con `SEMÁFORO:` al empezar y al terminar cada ventana. Todo contra la Release 1.0.0 de
`proyecto-baystream`, solo leída.

| Prueba | Resultado | Evidencia |
|---|---|---|
| El arte, `flutter test tool/t137_arte_test.dart` | Salida 0, 21 s. **Las 28 imágenes, con las mismas 28 huellas de antes.** Las paletas, iguales. Las 10 fuentes en CRLF dan exactamente las huellas normalizadas que anticipó la propuesta; el generador da `9165348c…` porque cambió | `arte-01.log`, `arte-antes/` |
| Armado de prueba desde esta carpeta | Salida 0, 17 s. `5ef28b61…`, 18,486,844 bytes. 27 archivos, 54,204,369 bytes; 5 excluidos, 36,910,272 bytes; las tres DLL de `VC\Redist` 14.51.36231.0 (`639342ea…`, `19c293ac…`, `a253a12e…`); `firebaseCppExe` 13.13.1; el aviso de los dos archivos viejos | `armado-prueba-01.log` a `-03.log` |
| ISCC | La primera vez, un aviso (`ConsultasMsix` sin usar en la prueba) y después un error (una `{tmp}` dentro de un comentario `{ }` lo cerraba). Corregidos: sin avisos | `prueba/corridas/*/iscc.log`, `produccion/corridas/*/iscc.log` |
| El mismo armado, dos veces | Las dos dan `5ef28b61…` | `armado-prueba-02.log`, `-03.log` |
| Armado de producción | Salida 0. `e4e7304c…` | `armado-produccion-03.log` |
| Ensayo `msix-colgada` | Salida 0. `5e279822…` | `armado-ensayo-01.log` |
| Ensayo con `--variante produccion` | **Rechazado**, salida 64, sin carpeta de salida | `ensayo-produccion-rechazado.log` |
| **O-137-1:** la copia en CRLF | 53 archivos; los 14 de texto, en CRLF (4 estaban en LF: el generador, el armador, el `.iss` y el manifiesto del arte). La huella cruda del generador en la copia es `088d5554…` y la del manifiesto, `9165348c…`: con el código de T-137 se habría detenido | `copia-crlf/t145-copia-crlf.json` |
| **O-137-1:** armado de prueba desde la copia | Salida 0. **El mismo instalador, `5ef28b61…`; el mismo manifiesto, byte por byte; la misma carga.** El manifiesto de Inno solo cambia la ruta de origen de cada archivo: fechas, huellas, tamaños y posiciones, iguales | `armado-copia-crlf-01.log` |
| **O-137-1:** negativo, un carácter cambiado en `bs_paleta.dart` de otra copia | Salida 1: «El arte quedó anterior a lib/core/design/bs_paleta.dart». Sin carpeta de salida | `negativo-arte-01.log` |
| **O-137-2:** `extracted` 13.13.1 con el `.exe` 0.4.2+8 (13.9.0) de `build/t137/app/`, solo leído | Salida 1 en 1.5 s: «El ejecutable enlaza Firebase C++ 13.9.0, pero firebase_core 4.15.2 pide 13.13.1. Trampa de 10.99…». Sin carpeta de salida | `negativo-exe-01.log`, `negativos/exe-13.9.0/CASO-SINTETICO.txt` |
| **O-137-3:** último recurso, sin `vswhere` (`ProgramFiles(x86)` a una carpeta vacía) | Salida 0, con tres avisos: las tres salen de System32, **14.51.36247.0** (`7c26614e…`, `d1f4225d…`, `a7146c08…`). Ese instalador es solo evidencia | `negativo-system32-01.log` |
| El sustituto | Una copia de `PING.EXE` fuera de System32 corre 3 s con `-n 4 127.0.0.1` (sin texto, porque le falta su recurso de idioma) | — |
| `analyze` del Dart versionado, con todo lo de T-145 | Salida 0, cero incidencias | `analyze-03.log` |

**Tamaño:** el instalador de prueba pasa de 20,107,014 bytes (0.4.2.8 de T-137) a
**18,486,844**; contra el 1.0.0.9 de T-137 (20,211,174) son 1.72 MB menos. La estimación de
la propuesta era 18.7 MB.

## 11. La aceptación (3.9), en el turno de Windows de Carlos

Cinco corridas, cada una en su carpeta y con su `SEMÁFORO:`. Las cuatro primeras se
detuvieron por algo de la máquina o del arnés, nunca del instalador; quedan como evidencia.
Lancé cada `.bat` con `explorer.exe`. Como PowerShell estaba deshabilitado en esta sesión,
escribí los `.bat` con Python, con el mismo contenido que genera `-Preparar`.

| Corrida | Qué pasó | Qué cambió después |
|---|---|---|
| `aceptacion-01` | Se detuvo antes de tocar nada: BayStream estaba abierta (PID 15968). El arnés pasó la sintaxis, Explorer en la ascendencia y la identidad sin paquete (15700). No instaló nada ni tomó la huella | Carlos la cerró |
| `aceptacion-02` | Pasaron los pasos 1 a 3 y el silencio del 4. Con cuadros, **el cuadro apareció** (`T145_APP_ABIERTA` a las 22:19:36), pero UI Automation no lo encontró en 20 s, y el arnés terminó su desinstalador, que no había quitado nada. La prueba quedó instalada: la quité en silencio con su desinstalador, por `explorer.exe` (salida 0, `T145_SIN_PROCESOS`, sin carpeta, clave ni accesos). Almacén igual | Si no ve el cuadro, el arnés guarda lo que ve y sigue |
| `aceptacion-03` | **Aceptada**, con Reintentar sin acreditar. `cuadro-no-visto.json` mostró la causa: Inno Setup 7 dibuja su propio cuadro (`TTaskDialogForm`), y sus botones (`TNewButton`) aparecen como `Pane`, no como `Button`. Los textos eran exactamente los de 3.8 | Buscar «Reintentar» por nombre y pulsarlo con `BM_CLICK` |
| `aceptacion-04` | El bucle funcionó: primer cuadro, Reintentar con el sustituto vivo, segundo cuadro, sustituto cerrado, Reintentar, `T145_APP_CERRADA` y desinstalación completa, sin residuos. El arnés cayó después, al leer el registro mientras la copia del desinstalador lo tenía abierto. No llegó al ensayo ni a producción | Leer los registros con acceso compartido |
| **`aceptacion-05`** | **Aceptada, los ocho pasos** | — |

**`aceptacion-05`, la que vale:**
- proceso exterior: Explorer 15456 → cmd 21340 → Windows PowerShell 32328, identidad 15700,
  sin paquete. BayStream cerrada antes y después;
- **1.** la prueba de T-137 (`a8952666…`, 0.4.2.8) instalada con los cinco `.lib` y `.exp`;
  la nueva (`5ef28b61…`) encima: carga de 27 verificada y **los cinco ya no están**
  (`[InstallDelete]`); otra vez encima con escritorio;
- **2. la hermana (10.130):** el sustituto 20012 en
  `%LOCALAPPDATA%\Programs\BayStream-Prueba-T137-hermana\`. La desinstalación de la prueba
  salió con 0, **sin cuadro** (`T145_SIN_PROCESOS`, sin `T145_APP_ABIERTA`) y sin residuos; el
  sustituto siguió vivo; después el arnés lo cerró por su Id y borró la carpeta;
- **3. abierta, en silencio:** el sustituto 26044 en la carpeta de la prueba; salida 1,
  `T145_APP_ABIERTA: 1` y `T145_DESINSTALAR_CANCELADO`; la carga, la entrada de Aplicaciones
  y el acceso en Inicio, intactos; el sustituto, vivo con el mismo Id;
- **abierta, con cuadros:** `cuadro-1.json` («BayStream (prueba T-137) está abierta», el texto
  de 3.8, Reintentar y Cancelar). Reintentar (`BM_CLICK`) con el sustituto vivo **volvió a
  preguntar** (`cuadro-2.json`, otra ventana). Cerrado el sustituto, Reintentar siguió:
  `T145_APP_CERRADA`, salida 0 y sin residuos. El desinstalador nunca cerró el sustituto;
- **4. el ensayo:** salida 1 en **34.2 s**; `T145_MSIX_TERMINADA` y el aviso «Windows no
  respondió en 30 segundos…»; ningún PowerShell colgado vivo; sin carpeta ni registro;
- **5. producción** (`e4e7304c…`): detenida por la MSIX, salida 1, sin carpeta ni registro;
- **almacén real `C:\Users\Giova\AppData\Local\BayStream`: huella igual antes y después,
  `93d30d87d3e6361e2630e5da5663cdfa5e56bac1c0631c3d1cb27afc18614c09`.**

**Un hecho del almacén, ajeno a T-145.** Desde las corridas 02 a 05, y desde la primera
huella de cada una (antes de instalar nada), el proceso exterior ve que
`%LOCALAPPDATA%\BayStream` **no existe** (`existe: false`, 0 archivos). El 3-nov tenía 592.
Mi consola sí ve una carpeta con ese nombre, pero es la vista de mi propio paquete (AGENTS.md).
No lo investigué ni toqué nada: lo dice Carlos.

**Después de las cinco:** sin carpetas, claves, accesos ni procesos de la corrida. Quedan
tres carpetas `is-*-uninstall.tmp` en `%TEMP%`, de los desinstaladores que el arnés terminó en
las corridas 02 y 03 (y de una anterior). No estorban: Inno las limpia en una desinstalación
siguiente, o se borran a mano.

## 12. El cierre

| Corrida | Resultado | Evidencia |
|---|---|---|
| `flutter analyze --no-pub lib test tool integration_test` | **Salida 0, cero incidencias** | `build/t145/analyze-04.log` |
| `flutter analyze --no-pub`, todo el paquete | Salida 1, **95 incidencias, todas en evidencia fuera de Git**: 4 en `build/t137/` (las de la 10.131) y 91 en mis copias de `build/t145/` (85 en `negativos/arte-cambiado`, donde cambié un carácter a propósito; 4 en `copia-crlf`; 2 en `negativos/exe-13.9.0/pubspec.yaml`). **Ninguna en un archivo versionado** | `analyze-05.log` |
| `// ignore:` | Ninguno en `tool/t137_*` ni en `tool/t145_*` | — |
| El instalador para el recorrido | La copia exacta del aceptado, en `C:\Users\Public\BayStream-T145\1.0.0.9\`: `BayStream_Setup_1.0.0.9.exe` (`e4e7304cc83d3a3837b06288521054a6b884c0bf7155e97bba3f7790557bcbde`, 18,488,262 bytes), su `.sha256` y su manifiesto, iguales a los originales. Producción, publicable, AppId `{D837B138-…}`, 1.0.0.9, 27 archivos, 5 excluidos, `firebaseCppExe` 13.13.1 y las tres DLL de `VC\Redist` | — |

## 13. El recorrido corto de Carlos, en «BayStream Prueba»

En la cuenta estándar «BayStream Prueba», sin la MSIX. Las capturas, como en T-137.
1. En Configuración → Aplicaciones, mira si está «BayStream 1.0.0.9». **Si no está,** instala
   primero el de T-137: `C:\Users\Public\BayStream-T137\1.0.0.9\BayStream_Setup_1.0.0.9.exe`
   (`ef8f2bbb…`).
2. Abre el nuevo, `C:\Users\Public\BayStream-T145\1.0.0.9\BayStream_Setup_1.0.0.9.exe`
   (`e4e7304c…`), e instálalo **encima**. Las páginas son las de T-137.
3. Abre `%LOCALAPPDATA%\Programs\BayStream`: no tienen que estar `baystream.lib`,
   `baystream.exp` ni los tres `*_plugin.lib`.
4. Abre BayStream desde Inicio y **déjala abierta**, sin iniciar sesión. Desinstala desde
   Configuración → Aplicaciones:
   - tiene que aparecer «**BayStream está abierta**», con Reintentar y Cancelar. Anota si
     aparece antes o después de la confirmación;
   - pulsa **Reintentar con BayStream abierta:** tiene que volver a preguntar;
   - cierra BayStream y pulsa **Reintentar:** sigue;
   - si aparece la confirmación, tiene que decir «¿Seguro que quieres desinstalar BayStream?
     Tus datos en %LOCALAPPDATA%\BayStream se conservan.» (O-137-4);
   - al final, «BayStream se desinstaló correctamente», **no** «Windows no pudo quitar algunos
     archivos», y la carpeta de la aplicación ya no está.
5. Si quieres, instálalo otra vez, abre BayStream y desinstala pulsando **Cancelar**: no tiene
   que quitar nada.

## 14. Límites

- **Reintentar, pulsado por el arnés con `BM_CLICK`.** El cuadro de Inno Setup 7 no expone
  sus botones como botones a UI Automation, así que el arnés manda el clic a la ventana nativa
  del botón. Que lo pulse una persona y que se vea bien en claro y en oscuro es del recorrido
  de Carlos.
- **La comprobación de O-137-8 es al empezar.** Si alguien abre BayStream después, vuelve el
  caso de antes: «Windows no pudo quitar algunos archivos».
- **WMI sin límite de tiempo.** Si WMI se colgara, el desinstalador (y, al vencerse la consulta,
  el asistente) esperaría. No lo vi nunca y no lo puedo reproducir.
- **El ensayo usa la variante de prueba.** Producción compila la misma función con
  `Get-AppxPackage`; su límite no se vio vencer con la MSIX real, solo en el ensayo.
- **Las DLL de Visual C++, copiadas junto al `.exe`, no las actualiza Windows Update.**
  Microsoft recomienda el redistribuible instalado en el sistema; la guía de Flutter admite
  llevarlas junto al `.exe`. Aceptable para un proyecto de graduación.
- **1.0.0.9:** el asistente y Aplicaciones muestran el recurso real del `.exe` (`1.0.0+9`); la
  MSIX dice 1.0.0.0.
- **Los dos archivos viejos de la Release** (`NOTICES` y `AssetManifest.bin.json`, del
  15-oct) van en la carga, con aviso (10.130). La versión del bloque 1 sale de una compilación
  limpia.
- **El tamaño en Aplicaciones no se midió:** las instalaciones de la aceptación son
  silenciosas. Se ve en el recorrido; la estimación es unos 57.6 MB.
- **PowerShell estuvo deshabilitado en esta sesión.** La copia en CRLF es Dart; los `.bat` los
  escribí con Python; `-Preparar` no se ejecutó en T-145, aunque su código cambió (solo agrega
  dos parámetros y la carpeta `build/t145`).
- Instalador y desinstalador sin firma de código comercial, como en T-137.

## 15. Archivos y Git

Cambian 7 archivos, todos de T-137 o de T-145:
- `windows/installer/baystream.iss`
- `windows/installer/arte/manifiesto.json` (las 28 imágenes no cambian)
- `tool/t137_instalador.dart`
- `tool/t137_arte_test.dart`
- `tool/t137_aceptacion.ps1`
- `tool/t145_copia_crlf.dart` (nuevo)
- `docs/T145-RESULTADOS.md` (nuevo)

`pubspec.yaml` y `pubspec.lock` **no cambian**. No se tocaron `lib/`, `test/`, `android/`,
`web/`, `tool/t93_msix.ps1` ni `build/t137/`. Los tres `windows/flutter/generated_*` siguen
con solo el fin de línea cambiado desde T-137 y no van. `build/t124/` y `build/t145/` están
ignorados y no van.

Para **Carlos**, en `C:\Proyectos\baystream-t137`:

```powershell
Set-Location -LiteralPath C:\Proyectos\baystream-t137
git add -- windows/installer/baystream.iss
git add -- windows/installer/arte/manifiesto.json
git add -- tool/t137_instalador.dart
git add -- tool/t137_arte_test.dart
git add -- tool/t137_aceptacion.ps1
git add -- tool/t145_copia_crlf.dart
git add -- docs/T145-RESULTADOS.md
git commit -m "Sprint 4: T-145, las observaciones del instalador"
git push origin t137-instalador
```

Git avisará que cambiará LF por CRLF en esta carpeta: es lo normal con `core.autocrlf`, y
justo lo que O-137-1 vuelve inofensivo. En el repositorio quedan en LF.

**Lo que entra a `sprint-4` al mezclar la rama:** `git diff --stat sprint-4...HEAD` pasa de
35 a **37 rutas**, todas de T-137 y de T-145:
- `windows/installer/baystream.iss` y los 29 de `windows/installer/arte/` (28 PNG y el
  manifiesto);
- `tool/t137_instalador.dart`, `tool/t137_arte_test.dart`, `tool/t137_aceptacion.ps1` y
  `tool/t145_copia_crlf.dart`;
- `docs/T137-RESULTADOS.md`, `docs/t137/revision-timonel.md` y `docs/T145-RESULTADOS.md`.

Después de la mezcla, el primer armado desde `baystream-rediseno` comprueba O-137-1 en la
carpeta real (10.122).

## 16. Horas

Fase 1: 1.5 h. Fase 2: 3 h (código, arte, armados, copia en CRLF, negativos, cinco corridas de
aceptación con sus ajustes al arnés, cierre e informe). Total: 4.5 h.

## 17. Tres líneas y mensaje para Yov

O-137-1, 2, 3, 6, 7 y 8 quedan arreglados; O-137-4 se comprobó igual, y O-137-5 no cambia.
La misma copia en CRLF da el mismo instalador, el `.exe` viejo se rechaza y el instalador baja a 18.5 MB.
La aceptación 05 pasó los ocho pasos, la hermana de la 10.130 incluida, con el almacén igual; falta el recorrido de Carlos.

> Yov: T-145 entregada (`docs/T145-RESULTADOS.md`, sin commit, sobre `dae3259`). El arte da
> las mismas 28 imágenes, y desde una copia con todo el texto en CRLF sale el mismo instalador
> (`5ef28b61…`) con el mismo manifiesto: O-137-1 resuelta. Un `.exe` 13.9.0 con `extracted`
> 13.13.1 se rechaza; las DLL vuelven a salir de `VC\Redist` (14.51.36231); la carga baja a 27
> archivos y el instalador a 18.5 MB. Aceptación por `.bat` en `build/t145/aceptacion-05`: los
> ocho pasos, la hermana sin cuadro, Reintentar en bucle y el ensayo detenido en 34 s, con el
> almacén igual. Hicieron falta cinco corridas: Inno 7 dibuja su propio cuadro, y UI Automation
> ve sus botones como `Pane`. Dos cosas para mirar: visto desde fuera del paquete,
> `%LOCALAPPDATA%\BayStream` no existe (el 3-nov tenía 592 archivos), y PowerShell estuvo
> deshabilitado en la sesión. `analyze` del Dart versionado en cero; el paquete completo, solo
> evidencia de `build/`. El instalador para el recorrido está en
> `C:\Users\Public\BayStream-T145\1.0.0.9` (`e4e7304c…`).
