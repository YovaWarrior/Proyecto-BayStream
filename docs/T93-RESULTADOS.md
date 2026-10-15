# T-93 · Instalador de Windows: BayStream como paquete MSIX firmado

Fecha: 14-oct-2026. Responsable: Timonel (Claude Code). Rama de trabajo: `sprint-3`.
Base inspeccionada: `557806b` (decisión 10.36). Aceptación cruzada pendiente: Capitán Codex.

## Resultado

El `.msix` firmado con el certificado de Carlos (`CN=BayStream`, huella
`60BEF8F4D26ECF7AD25CC478E715CF9B26A278EC`) se instala, aparece en Inicio, abre con
las opciones de Firebase y muestra A07 y «PRUEBA T-84» con las cifras de la ficha. Una
versión mayor (1.0.1.0) se instala encima y conserva el viaje, Recientes y la sesión.
La desinstalación borra el paquete y su almacén privado.

**Un criterio no pasa tal como estaba escrito: «el almacén real con la misma huella
antes y después».** El primer arranque de la app instalada escribió directamente en
`%LOCALAPPDATA%\BayStream` (sección 3). Me detuve y avisé. Con el método que indicó
Yov (respaldo, renombre y devolución), el resto de la aceptación se hizo sobre un
almacén limpio, y el almacén real terminó **idéntico al estado posterior a ese primer
arranque** (288 archivos, `6F6E95EB…8F61`). La corrección del criterio va en la 10.37.

Validaciones: **660 pruebas = piso 655 + 5 nuevas; analyze en cero; corpus 116/116;
124 archivos protegidos con el mismo SHA-256** (los 122 de `lib/`, `firestore.rules` y
`firebase.json`). Los congelados de H5 no difieren de `m2-baseline`. `pubspec.yaml` y
`pubspec.lock` cambian solo por `msix` y tres transitivas nuevas.

| Criterio de la ficha | Estado |
| --- | --- |
| Instalación, Inicio con su ícono, abre con Firebase | Pasa |
| A07: 398 / 21 / `6940.6 t` / GTSTC 0 cargan, 114 descargan, 284 de paso, y se conserva al cerrar por PID | Pasa |
| «PRUEBA T-84» en «Al día»: 4 / 3 / `20.0 t` / 0, 3, 1, sin movimientos | Pasa (la sesión ya existía: 4.3) |
| Actualización 1.0.0.0 → 1.0.1.0 conserva viaje, Recientes y sesión | Pasa |
| Desinstalación documentada | Pasa (sección 6) |
| Almacén real con la misma huella antes y después | **No pasa** como estaba escrito (sección 3) |
| Instrucciones para una PC de oficina y bloque para regenerar | En este informe (secciones 7 y 8) |
| Piso, analyze, corpus y SHA protegidos | Pasa |

## 1. Lo construido

### 1.1 `msix` como dependencia de desarrollo

`msix: 3.18.0`, fija, en `dev_dependencies`. Es la última publicada (27-jun-2026) y
pide `sdk: >=2.19.0 <4.0.0`. Resuelve con Flutter **3.38.9** y Dart **3.10.8**, que es
lo que trae la máquina; la ficha decía Dart 3.9.

`pubspec.lock` comparado entrada por entrada contra la copia previa: **ninguna versión
existente se movió**. Solo hay cuatro altas:

| Paquete | Versión | Tipo |
| --- | --- | --- |
| `msix` | 3.18.0 | direct dev |
| `cli_util` | 0.5.0 | transitiva nueva |
| `console` | 4.1.0 | transitiva nueva |
| `get_it` | 9.3.0 | transitiva nueva |

Sus otras dependencias (`args`, `yaml`, `path`, `package_config`, `image` y
`pub_semver`) ya estaban en el lock y no cambiaron de versión. Es una dependencia de
desarrollo, así que no entra en la app compilada.

### 1.2 `msix_config` en `pubspec.yaml`

Los nombres de las opciones se confirmaron en `lib/src/configuration.dart` de
msix 3.18.0, no de memoria.

```yaml
msix_config:
  display_name: BayStream
  publisher_display_name: Carlos Martínez
  identity_name: gt.cmartinez.baystream
  publisher: CN=BayStream
  msix_version: 1.0.0.0
  capabilities: internetClient
  logo_path: windows/runner/resources/app_icon.ico
  build_windows: false
  install_certificate: false
  output_path: build/t93
  output_name: BayStream
```

Lo comprobado en el código de msix 3.18.0:

- **Con `/sha1` en `signtool_options`,** `SignTool.isCustomSignCommand` es verdadero y
  `validateConfigValues` no cae en el certificado de prueba (`test_certificate.pfx`
  con contraseña `1234`).
- **Con `publisher` declarado,** `getCertificatePublisher` no consulta el almacén de
  certificados.
- **`installCertificate`** solo corre si `install_certificate` está activo y no hay
  `signtool_options`. Aquí no se cumple ninguna de las dos condiciones.
- **`signtool sign /fd SHA256 /sha1 <huella>`** busca el certificado en el almacén
  «Personal» del usuario. No se exportó la clave ni se usó un `.pfx` o una
  contraseña.

El manifiesto generado trae `Identity Name="gt.cmartinez.baystream" Version="1.0.0.0"
Publisher="CN=BayStream"`, `PublisherDisplayName` «Carlos Martínez» y como
capacidades `internetClient` más `rescap:runFullTrust`. msix agrega `runFullTrust`
siempre (`appx_manifest.dart`, línea 217), y lo exige toda app Win32 empaquetada:
sin ella, `baystream.exe` no arranca. El paquete incluye el runtime de VC++, así que
una PC de oficina no necesita instalarlo aparte.

### 1.3 `tool/t93_msix.ps1`

1. Valida que la huella tenga 40 hexadecimales, que la versión vaya como `1.0.1.0` y
   que el archivo de opciones de Firebase exista **fuera** del repositorio.
2. Ejecuta `flutter build windows --release --dart-define-from-file=<ruta>` y se
   detiene si falla. El archivo de opciones solo se pasa por ruta: no se abre ni se
   imprime.
3. Ejecuta `dart run msix:create` con `--version`, `--output-path build\t93`,
   `--output-name BayStream_<versión>`, `--build-windows false`,
   `--install-certificate false` y `--signtool-options "/fd SHA256 /sha1 <huella>"`.
4. Escribe `BayStream_<versión>.msix.sha256` y verifica con
   `Get-AuthenticodeSignature` que el firmante tenga esa huella. Si no la tiene, falla.

El parámetro `-SinCompilar` reempaqueta la compilación Release que ya existe. Lo usé
para la 1.0.1.0, que salió de la misma compilación que la 1.0.0.0. El script es ASCII
puro, para que PowerShell 5.1 lo lea bien sin BOM.

| Paquete | SHA-256 | Firma | Tiempo |
| --- | --- | --- | --- |
| `BayStream_1.0.0.0.msix` (25.6 MB) | `290DE7A6842FD8471E6FE66AB62D3070CE1C8A6898A9BDE1D7EC7402F7F61EAB` | Valid · CN=BayStream · 60BEF8F4…78EC | 77 s (compilación 39.7 s) |
| `BayStream_1.0.1.0.msix` | `ABBCD33BD8ACFD2B80E785381207FCB1C340DA53963FFF94018BFD8703F7CA0B` | Valid · CN=BayStream · 60BEF8F4…78EC | 62 s (sin compilar) |

Ninguno de los dos paquetes se copió ni se repartió: siguen en `build\t93\`, que está
ignorado por Git.

### 1.4 `test/t93_msix_config_test.dart` (5 pruebas)

1. `build_windows: false` e `install_certificate: false`, sin `sign_msix` ni `store`.
2. `publisher: CN=BayStream`, la identidad, el nombre, `msix_version`, solo
   `internetClient` y el ícono actual.
3. `pubspec.yaml` no trae `certificate_path`, `certificate_password`,
   `signtool_options`, `.pfx`, `.p12`, `password`, `/sha1` ni una huella de 40
   hexadecimales.
4. `msix` está solo en `dev_dependencies`, fija en 3.18.0, y el lock la registra como
   `direct dev` 3.18.0.
5. El script compila con `--dart-define-from-file` antes de `msix:create`, firma con
   `"/fd SHA256 /sha1 $Huella"`, fuerza `--build-windows false` e
   `--install-certificate false`, y no trae huella literal ni `--certificate-path` o
   `--certificate-password`.

Las pruebas leen `pubspec.yaml` como texto. `yaml` es transitiva, y importarla habría
exigido declararla.

## 2. Dónde escribe la app instalada

| Qué | Dónde | ¿Se virtualiza? |
| --- | --- | --- |
| Almacén de BayStream (`vessel_store`), si `%LOCALAPPDATA%\BayStream` **ya existe** | La carpeta real | **No.** Lee y escribe lo que ya había |
| Almacén de BayStream, si la carpeta **no existe** | `%LOCALAPPDATA%\Packages\gt.cmartinez.baystream_bq33510ehc1x4\LocalCache\Local\BayStream\vessel_store` | Sí. Se borra al desinstalar |
| Caché de Firestore | `%LOCALAPPDATA%\firestore\[DEFAULT]\baystream-app\main` (ya existía en la laptop) | No, por la misma regla. La comparte con la app sin instalar |
| Sesión de Firebase Auth | Administrador de credenciales de Windows (sección 4.3) | No. Es por usuario de Windows |

**¿Ve lo que ya había en el almacén real?** Sí. En el primer arranque, Recientes
mostró los cinco viajes de BUQUE GOLF del almacén real.

**¿Ve la app el almacén correcto en mi consola?** No, y hay que tenerlo en cuenta. Mi
PowerShell corre dentro del paquete de Claude, y desde ahí `%LOCALAPPDATA%\BayStream`
se ve mezclado con `Packages\Claude_pzs8sxrjxfjjc\LocalCache\Local\BayStream`: 297
archivos frente a los 283 reales. Por eso todas las huellas del almacén real se tomaron
**fuera del paquete**, con un `.bat` lanzado por `explorer.exe`. Cada archivo de
huella registra el proceso padre.

## 3. El almacén real: qué pasó

### 3.1 Huellas

| Momento | Archivos | Huella total | Archivo de evidencia |
| --- | ---: | --- | --- |
| Antes de instalar | 283 | `F9E043B1DD4AB815F7636180CBD252D81EC5B39E4166EEFFECEC21DE85B15325` | `antes_huella_fuera.txt` |
| Después del primer arranque (A07) | 288 | `6F6E95EB8C1BD436A2C83F82228541847D31A7971256E5FC5806BA9DF6F58F61` | `despues_a07_huella_fuera.txt` |
| Respaldo `%TEMP%\baystream-t93-respaldo` | 288 | `6F6E95EB…8F61` (idéntico) | `respaldo_huella_copia.txt` |
| Al terminar, tras devolverlo a su sitio | 288 | `6F6E95EB…8F61` (idéntico al paso 1) | `final_huella_fuera.txt` |

Los archivos de evidencia están en `build\t93\`, que no se versiona. La huella total es
el SHA-256 de la lista «SHA-256, tamaño, ruta» de todos los archivos, ordenada por
ruta.

### 3.2 Qué escribió el primer arranque

Fue la app 1.0.0.0, PID 19896, abierta a las 18:20:13 desde `shell:AppsFolder`. Cargó
A07, confirmé GTSTC y «No lo tengo», y la cerré por PID. Solo cambió el namespace por
defecto `baystream`. Todos los `t*acc`, `t74_aceptacion_*` y `t102acc` quedaron
idénticos.

| Archivo de `vessel_store` | Cambio |
| --- | --- |
| `baystream_operations.hive` | 4 942 968 → 5 336 271 bytes: la operación de A07 |
| `baystream_voyages.hive` | 756 302 → 740 728 bytes: A07 entra en Recientes y, por el límite de 5, sale el viaje más antiguo de BUQUE GOLF. Se recupera recargando su BAPLIE del corpus |
| `baystream_profiles.hive` | 9 598 → 10 274 bytes: perfil de BUQUE GOLF confirmado de nuevo, con la escala |
| `baystream_settings.hive` | 862 → 905 bytes |
| `baystream_session.hive` | **nuevo** (123 bytes): la copia local del último operador (uid, nombre y rol; nunca correo ni contraseña, según `firebase_session_repository.dart`) |
| `baystream_device.lock`, `baystream_movements.lock`, `baystream_operations.lock`, `baystream_session.lock` | **nuevos** (18 bytes cada uno) |

Ningún archivo se abrió para leerlo: solo hash, tamaño y fecha. Como pidió Yov, los
cinco archivos nuevos se quedan donde están. Carlos decide antes del piloto si limpia
el almacén real (10.13). Después de eso no se perdió nada más: el almacén terminó igual
que en el paso 1.

### 3.3 Por qué el paquete no virtualizó la escritura

- **El manifiesto no es la causa.** El `AppxManifest.xml` que generó msix no trae
  `unvirtualizedResources`, `desktop6:FileSystemWriteVirtualization`,
  `RegistryWriteVirtualization`, `uap10:RuntimeBehavior` ni `uap10:TrustLevel`. La
  aplicación es `Windows.FullTrustApplication`: una app de escritorio empaquetada con
  la virtualización por defecto. msix 3.18.0 solo conoce `unvirtualizedResources` como
  nombre de capacidad (`capabilities.dart`, línea 146), y no la pusimos.
- **La causa es la regla de Windows para AppData** (Microsoft Learn, *Understanding
  how packaged desktop apps run on Windows*, «AppData operations on Windows 10,
  version 1903 and later»):
  - solo se redirigen las carpetas y archivos **nuevos** creados en los directorios
    que lista: `Local`, `Local\Microsoft`, `Roaming`, `Roaming\Microsoft` y
    `Roaming\Microsoft\Windows\Start Menu\Programs`;
  - modificar lo que ya existe está permitido en la ubicación real;
  - al abrir, el sistema busca primero en la ubicación privada del paquete y, si no
    está, en la real.
  - Como `Local\BayStream\vessel_store` ya existía, los archivos nuevos y modificados
    de su interior fueron a la ubicación real.
- **La prueba que lo confirma:** con la carpeta apartada, la misma app creó su almacén
  en `Packages\…\LocalCache\Local\BayStream`, y `%LOCALAPPDATA%\BayStream` no
  apareció fuera del paquete.
- **Lo que vio 10.9 con los paquetes de Claude y Codex es la otra rama de la misma
  regla.** Esos paquetes tienen su propia copia de `BayStream` en su `LocalCache`, y
  la copia privada se lee primero. Cuándo nació cada copia no lo pude reconstruir: es
  una hipótesis, no una medición.

## 4. Aceptación sobre el almacén limpio

El almacén real se apartó así: SEMÁFORO; copia completa con `robocopy` a
`%TEMP%\baystream-t93-respaldo\`, con las mismas 288 huellas; y renombre a
`%LOCALAPPDATA%\BayStream.t93-real`. Todo se hizo fuera del paquete de Claude y sin
ningún `baystream.exe` abierto.

### 4.1 Instalación

- `Add-AppxPackage BayStream_1.0.0.0.msix` instaló el paquete con la familia
  `gt.cmartinez.baystream_bq33510ehc1x4`, `SignatureKind Developer` y estado `Ok`, en
  `C:\Program Files\WindowsApps\gt.cmartinez.baystream_1.0.0.0_x64__bq33510ehc1x4`.
- `Get-StartApps` muestra «BayStream» con el AppID `…!baystream`. El AppID es
  `baystream`, no `App`: `explorer.exe shell:AppsFolder\gt.cmartinez.baystream_bq33510ehc1x4!baystream`.
- La app abre con su barra completa, Recientes y Nube y cuenta. No muestra «Falta la
  configuración de Firebase».
- No probé el doble clic al `.msix` (App Installer). El paquete y la firma son los
  mismos que instaló `Add-AppxPackage`.

### 4.2 El plano

| Prueba | Contenedores | Bahías | Peso | GTSTC |
| --- | ---: | ---: | --- | --- |
| Primer arranque (almacén real) | 398 | 21 | `6940.6 t` | 114 se descargan · 0 se cargan · 284 de paso |
| Almacén limpio, perfil propuesto del archivo | 398 | 21 | `6940.6 t` | 114 · 0 · 284 |
| Tras cerrar por PID 22140 y reabrir (PID 10728), desde Recientes | 398 | 21 | `6940.6 t` | 114 · 0 · 284 |
| Tras actualizar a 1.0.1.0 (PID 888), desde Recientes | 398 | 21 | `6940.6 t` | 114 · 0 · 284 |

Estadísticas, en el primer arranque: 290 llenos, 108 vacíos, 12 reefers y 14 IMO/DG.
Cada proceso se abrió desde `shell:AppsFolder`, con `explorer.exe` como padre, y se
cerró con `CloseMainWindow` sobre su PID.

### 4.3 La sincronización y la sesión

- **La app instalada entró con la sesión ya abierta** («Carlos Oficina · Oficina ·
  Cuenta autorizada»), aunque el almacén de BayStream estaba vacío. Carlos no tuvo que
  escribir credenciales, y yo no vi ni anoté correos, UID ni contraseñas.
- **Dónde guarda Firebase la sesión en Windows.** Al arrancar la app (18:31:26), y
  otra vez al arrancar la 1.0.1.0 (18:33:50), se escribieron dos entradas en
  `%LOCALAPPDATA%\Microsoft\Credentials`. Esa es la ubicación en disco del
  Administrador de credenciales de Windows, que el SDK de escritorio de Firebase Auth
  usa para guardar al usuario.
  - Lo deduzco de las fechas de escritura y de lo que sé del SDK. No abrí esos
    archivos ni listé las credenciales.
  - Ese almacén no lo virtualiza MSIX, así que **la app instalada y la app sin
    instalar comparten la sesión** de la misma cuenta de Windows.
- **«Unirse» a «PRUEBA T-84» solo lee** (`FirestoreOperationSync.join`: dos lecturas
  del servidor, ninguna escritura).
  - Plano de llegada: **4 contenedores, 3 bahías, `20.0 t`, GTSTC 3 se descargan · 0
    se cargan · 1 de paso**.
  - Nube y cuenta: «PRUEBA T-84 · T84 · GTSTC · Publicada · **Al día**».
- **No registré ningún movimiento.**
  - `baystream_movements.hive` del paquete (9 549 bytes) es la bitácora de T-84
    descargada de la nube.
  - A07 quedó como «Solo en este dispositivo» y no se publicó.

### 4.4 La actualización

- Con la app cerrada por PID, `Add-AppxPackage BayStream_1.0.1.0.msix` reemplazó la
  versión en la misma familia.
- Los 14 archivos del almacén del paquete conservaron tamaño y fecha.
- La 1.0.1.0 abrió con:
  - Recientes con «BUQUE GOLF · VIAJE007A, 398 contenedores · 21 bahías» y «PRUEBA
    T-84 · T84, 4 contenedores · 3 bahías»;
  - A07 con sus cifras;
  - la misma sesión de oficina;
  - T-84 «Publicada · Al día».

## 5. La huella del almacén real, antes y después

Ver 3.1. La ficha pide la misma huella antes de instalar y al final. **No pasa**: se
rompió en el primer arranque, de `F9E043B1…5325` (283) a `6F6E95EB…8F61` (288). Desde
ese momento el almacén ya no cambió. Lo confirman el respaldo y la huella final, ambos
idénticos al estado del paso 1, y la comparación archivo por archivo.

## 6. La desinstalación: qué queda y qué se borra

Se hizo con `Get-AppxPackage gt.cmartinez.baystream | Remove-AppxPackage`, con la app
cerrada por PID.

| Se borra | Queda |
| --- | --- |
| El paquete instalado (`C:\Program Files\WindowsApps\…_1.0.1.0_…`) | La sesión de Firebase en el Administrador de credenciales: las dos entradas siguen ahí |
| `%LOCALAPPDATA%\Packages\gt.cmartinez.baystream_bq33510ehc1x4\` completa (24 archivos), con el almacén privado: A07, T-84, perfiles, bitácora y copia del operador | La caché de Firestore en `%LOCALAPPDATA%\firestore\[DEFAULT]\baystream-app` **cuando la carpeta ya existía**, como en la laptop. Si la creara el paquete, se redirigiría y se borraría con él |
| La entrada «BayStream» de Inicio | `%LOCALAPPDATA%\BayStream` **cuando ya existía antes de instalar**: el paquete la usa y no la borra |
| | El certificado en «Personas de confianza» del equipo |

La app quedó **desinstalada**. Si Carlos quiere dejar instalada la versión final en
esta laptop, va a usar y modificar su almacén real, por 3.3. Lo recomendable es
instalarla solo en una PC sin la app previa, o apartar antes el almacén.

## 7. Instrucciones para una PC de oficina (para T-100 y el piloto)

Lo que se lleva a la PC: `BayStream.cer` (la parte pública del certificado),
`BayStream_<versión>.msix` y su `.sha256`. Ningún `.pfx` ni contraseña.

1. **Comprobar el paquete:** `Get-FileHash .\BayStream_<versión>.msix` tiene que dar el
   SHA-256 del `.sha256`.
2. **Confiar en el certificado, una sola vez y como administrador:**
   `Import-Certificate -FilePath .\BayStream.cer -CertStoreLocation Cert:\LocalMachine\TrustedPeople`.
3. **Instalar:** doble clic al `.msix` y «Instalar», o `Add-AppxPackage .\BayStream_<versión>.msix`.
4. **Abrir** «BayStream» desde Inicio. La oficina inicia sesión con su cuenta desde
   Nube y cuenta.
5. **Dónde quedan los datos.** En una PC **sin** BayStream previo, el almacén vive en
   la carpeta privada del paquete,
   `%LOCALAPPDATA%\Packages\gt.cmartinez.baystream_bq33510ehc1x4\LocalCache\Local\BayStream`.
   Se conserva al actualizar y **se borra al desinstalar**.
   - Si la PC ya tenía `%LOCALAPPDATA%\BayStream`, de una copia de la carpeta
     `Release`, el paquete usa esa carpeta, la modifica y no la borra al desinstalar.
   - Para el piloto conviene una PC sin copia previa, o apartar esa carpeta antes de
     instalar.
6. **Actualizar:** doble clic al `.msix` de la versión mayor (por ejemplo `1.0.2.0`).
   Se conservan el viaje, Recientes y la sesión. La versión siempre sube: Windows no
   instala una igual o menor encima.
7. **Desinstalar:**
   1. sincronizar hasta «Al día» en Nube y cuenta: desinstalar borra el almacén del
      paquete, con los movimientos que no hayan subido;
   2. cerrar la sesión, porque la sesión de Firebase queda en el Administrador de
      credenciales después de desinstalar;
   3. Configuración → Aplicaciones → Aplicaciones instaladas → BayStream →
      Desinstalar, o `Get-AppxPackage gt.cmartinez.baystream | Remove-AppxPackage`.

   No comprobé que «Cerrar sesión» borre esa entrada.
8. **Firma y vigencia.** La firma no lleva sello de tiempo, porque la ficha pedía solo
   `/fd SHA256 /sha1`. El paquete instala mientras el certificado esté vigente, tres
   años desde su creación. Después habrá que generar otro certificado y repetir el
   paso 2.

Queda fuera de esta tarea, como dice la ficha: Windows 10 en una PC de COMAR, el
`.appinstaller` y el acceso directo en el escritorio.

## 8. Bloque para regenerar el paquete

En PowerShell normal, sin administrador, en la laptop donde está el certificado:

```powershell
cd C:\Proyectos\proyecto-baystream
powershell -NoProfile -ExecutionPolicy Bypass -File tool\t93_msix.ps1 -Huella 60BEF8F4D26ECF7AD25CC478E715CF9B26A278EC -Version 1.0.2.0
```

- Compila Release con `C:\Proyectos\baystream-privado\firebase-prod.json`; otra ruta
  va con `-Opciones <ruta>`.
- Firma y deja `build\t93\BayStream_1.0.2.0.msix` con su `.sha256`.
- Termina con error si la compilación falla o si la firma no es de esa huella.
- Cada entrega lleva una versión mayor que la anterior.
- El `.msix` contiene la app compilada con las opciones de Firebase, como cualquier
  binario de cliente. Lo distribuye Carlos.

## 9. Validaciones, SHA y horas

```text
flutter test --no-pub                         660/660   35 s
flutter analyze --no-pub                      No issues found (26.6 s)
flutter test <31 corpus de tool/> --no-pub --dart-define=BAYSTREAM_CORPUS_DIRECTORY=…   116/116   28 s
dart format --set-exit-if-changed test/t93_msix_config_test.dart   0 cambios
```

- **Piso:** 655 de T-92 más 5 de T-93 = **660**. Ninguna prueba se borró ni se marcó
  `skip`.
- **SHA protegidos:** `lib/` (122), `firestore.rules` y `firebase.json` son iguales
  antes y después (`build\t93\sha_protegidos_*.txt`).
  `git diff --stat --ignore-cr-at-eol m2-baseline` de los dos congelados está vacío.
- **Sin cambios** en `lib/`, `lib/main.dart`, `windows/`, `SPRINT-3.md`, `AGENTS.md`,
  `CLAUDE.md` ni `README.md`.
- **Lo que no hice:** no abrí `firebase-prod.json`, `android/key.properties` ni nada
  de `baystream-privado`. No toqué los almacenes de certificados, la CLI de Firebase,
  los emuladores ni el proyecto de H5. No ejecuté `git status`.
- **Observación:** el manifiesto declara el idioma `en-us`, que es el predeterminado
  de msix. La interfaz es en español. Si se quiere `es`, es una línea `languages:` en
  `msix_config`; no la agregué porque la ficha no la pedía.
- **Horas:** ≈ 0.9 h de pared, de 17:55 a 18:50, incluidas las esperas por la huella,
  el semáforo y la decisión sobre el almacén. Frente a 2.5 estimadas.

## 10. Archivos

| Archivo | Cambio |
| --- | --- |
| `pubspec.yaml` | `msix: 3.18.0` en `dev_dependencies` y `msix_config` |
| `pubspec.lock` | Cuatro altas: `msix` 3.18.0, `cli_util` 0.5.0, `console` 4.1.0, `get_it` 9.3.0 |
| `tool/t93_msix.ps1` | Nuevo |
| `test/t93_msix_config_test.dart` | Nuevo |
| `docs/T93-RESULTADOS.md` | Este informe |

Fuera del repositorio:
- `build\t93\`: paquetes, huellas, registros y captura, ignorado por Git;
- `%TEMP%\baystream-t93-respaldo\`: el respaldo del almacén real. Se conserva hasta que
  Carlos decida.
