# T-137 · Revisión de Timonel

Fecha: 3 de noviembre de 2026. Revisa: Timonel. Hizo la tarea: Capitán Codex.
Carpeta: `C:\Proyectos\baystream-t137`. Rama: `t137-instalador`, sin commit de la
entrega, sobre `8ea84bd`. Fuentes: `SPRINT-4.md` de `baystream-rediseno`, 10.99 a
10.103, y `SPRINT-3.md` 10.37.

## Dictamen: NO PASA, por un solo hallazgo

**El aviso del bloqueo por MSIX promete algo que en otro equipo es falso, y es
justo el paso que hace perder los datos (H1).** La corrección son dos líneas de
texto más regenerar los instaladores. Todo lo demás de la revisión pasa o queda
como observación.

En la laptop de Carlos el aviso es cierto: H1 no le afecta a la demostración.
Tampoco detiene la 1.0.0, porque T-137 no toca la app (10.103).

No revisé el recorrido a mano: es de Carlos, en «BayStream Prueba». No instalé
nada, no abrí BayStream ni los asistentes y no regeneré el arte.

**H1 ya está corregido:** ver «Corrección», al final. Este dictamen queda como
registro de lo que se encontró.

## Lo que hay que corregir

### H1 · P1 · El aviso dice «Tus datos se quedan», y sin una carpeta previa se borran

**Dónde:** `windows/installer/baystream.iss:159-163`, función `ErrorMsix`.

**Qué dice el asistente, al detenerse por la MSIX:**
> Abre Configuración > Aplicaciones y desinstala BayStream. […] Tus datos se
> quedan: están fuera del paquete, en %LOCALAPPDATA%\BayStream.

**Qué dice el proyecto:**
- `SPRINT-3.md` 10.37: en una PC sin BayStream previo, «como la de la oficina y la
  del piloto», el almacén vive en la carpeta privada del paquete y **se borra al
  desinstalar**. Por eso hay que sincronizar hasta «Al día» antes.
- `docs/T93-RESULTADOS.md`, secciones 2 y 6: se borra
  `Packages\gt.cmartinez.baystream_bq33510ehc1x4\` completa, con A07, T-84,
  perfiles, bitácora y copia del operador. La caché de Firestore sigue la misma regla.
- `AGENTS.md`: la MSIX usa esa carpeta **si ya existe**.

**Qué pasaría:** alguien con la MSIX en una PC nueva abre el asistente. El
asistente le dice que desinstale y le promete que los datos se quedan. Desinstala
y lo que no estaba sincronizado se pierde. No es una falla rara: es el camino
normal de quien pasa de la MSIX al asistente fuera de la laptop.

**Por qué nadie lo vio:** la frase viene de la 10.100, que cita la 10.75, y la
10.75 midió la laptop de Carlos. Allí es cierta: la carpeta ya existía. Lo comprobé
hoy: el paquete tiene 10 archivos y en `LocalCache\Local` solo está `Microsoft`,
sin `BayStream`. La aceptación automática corre en esa misma cuenta, así que no
podía encontrarlo.

**Corrección propuesta** (Yov y Carlos deciden la redacción). Es solo texto, cierto
en cualquier equipo y comprobable en la laptop:

> Abre Configuración > Aplicaciones y desinstala BayStream. Después abre este
> asistente otra vez.
>
> **Antes de desinstalar, abre BayStream y sincroniza hasta «Al día».** Si
> BayStream se instaló en este equipo por primera vez como MSIX, tus datos están
> dentro del paquete y se borran con él. Si ya tenías %LOCALAPPDATA%\BayStream,
> se quedan ahí.
>
> Este asistente no desinstala la MSIX y no copió archivos de la aplicación.

Una alternativa más fina es que el asistente mire si existe
`Packages\gt.cmartinez.baystream_*\LocalCache\Local\BayStream` y dé el aviso que
corresponda. No la recomiendo para esta semana: es una rama nueva y probarla pide
una MSIX instalada desde cero.

**Después de corregir:**
- Codex regenera los dos instaladores y repite la aceptación, por el cambio de
  huella. No hace falta regenerar el arte para H1.
- Conviene hacerlo **antes** del recorrido de Carlos, para que recorra el `.exe` final.
- Yov corrige la frase «Los datos no corren riesgo» de la 10.100.

## Observaciones que no bloquean

### O-137-1 · P2 · El armado solo funciona desde `baystream-t137`

`_comprobarArte` (`tool/t137_instalador.dart:1048`) compara las huellas de las 21
fuentes del arte byte por byte, y 11 son texto. Esas huellas dependen del fin de
línea, y en esta máquina `core.autocrlf` es `true`:

- `tool/t137_arte_test.dart` está en LF en esta carpeta, y el manifiesto guarda esa
  huella (`fd84d497…`). Con `autocrlf` activo, Git lo escribe en CRLF al mezclarlo en
  otra carpeta (`431e04f2…`), como `tool/t93_msix.ps1`, que en `baystream-rediseno`
  está `i/lf w/crlf`. Entonces no coincide.
- Hoy mismo, en `baystream-rediseno` no coinciden 8 fuentes, aunque
  `git diff 8ea84bd HEAD` no marca ningún cambio de contenido en esas rutas: las 8
  coinciden en cuanto se pasan a CRLF. Es solo el fin de línea.

**Efecto:** después de que T-137 entre a `sprint-4`, armar desde `proyecto-baystream`
o `baystream-rediseno` se detiene con «El arte quedó anterior a…» y manda a
regenerar el arte, que no es la causa. Falla del lado seguro: no sale ningún
instalador malo. Pero le cae a Carlos la noche de publicar.

**Mientras tanto:** armar siempre desde `C:\Proyectos\baystream-t137`, que es lo
que dice la sección de abajo. Probé esa ruta contra una Release 1.0.0 y funciona.

**Arreglo:** calcular la huella de las fuentes de texto normalizando `\r\n` a `\n`,
en el generador y en el armador. Eso regenera `manifiesto.json`. Las imágenes no
deberían cambiar: las 14 pequeñas dieron la misma huella en dos corridas distintas.

### O-137-2 · P2 · La trampa se detecta en `extracted`, no en el `.exe`

La trampa de la 10.99 está bien cubierta tal como se escribió: compara el
`FIREBASE_SDK_VERSION` del `firebase_core` resuelto con el `version.h` de `extracted`
y se detiene si difieren. El rechazo está probado (`sdk-distinto-02.log`).

Lo que no ve es una Release vieja con `extracted` ya corregido: un `.exe` compilado
con el 13.9.0 y después un `extracted` nuevo sin recompilar. Es improbable, pero la
10.100 pide comprobar «el SDK enlazado», y se puede: el `.exe` trae la cadena.

| `.exe` | Cadena dentro del binario |
|---|---|
| `proyecto-baystream`, 0.4.2+8 | `Firebase C++ 13.9.0` |
| `baystream-qa-r4`, 1.0.0+9 | `Firebase C++ 13.13.1` |

**Arreglo:** una lectura más en `_metadatos`. Mientras no esté, va como comprobación
a mano en el paso 2 de abajo.

### O-137-3 · P3 · Las DLL de Visual C++ se toman de System32

- **De dónde salen:** el orden de `_buscarRuntime` es Release → System32 → Redist de
  Visual Studio, así que hoy salen de System32. Microsoft dice que los archivos
  redistribuibles están en `VC\Redist`.
- **Si se pueden redistribuir así:** los tres archivos son **byte por byte iguales** a
  los de `VC\Redist\MSVC\14.51.36231\x64\Microsoft.VC145.CRT`: mismas tres huellas
  SHA-256. Lo que va en el instalador es entonces lo que `VC\redist` permite
  distribuir, sin modificar. La página de redistribución de Visual Studio 2026 lo
  limita a usuarios con licencia y a sus términos. Leí esa página, no el texto de la
  licencia de Community. No es un dictamen legal.
- **El riesgo:** si una actualización de Windows cambia System32, el instalador
  llevaría otra versión sin que nadie la eligiera.
- **Arreglo:** cambiar el orden a Release → Redist, y dejar System32 solo como
  último recurso, con aviso.
- **Falta declararlo en los límites:** copiadas junto al `.exe`, Windows Update no
  las actualiza. Microsoft no recomienda el despliegue local por eso, aunque la guía
  de Flutter lo admite. Para un proyecto de graduación es aceptable, pero se dice.

**La auditoría con dumpbin pasa.** Revisa los 5 módulos PE y exige que cada DLL esté
junto al `.exe`, sea un contrato API-set o esté en una lista cerrada de Windows. No
acepta una DLL solo porque esté en esta máquina, y `dumpbin` también lista las de
carga diferida. La 1.0.0 da los mismos 5 módulos sin ninguna dependencia nueva. Sigue
siendo cierto lo que Codex declara: no prueba las DLL que se cargan en tiempo de
ejecución.

### O-137-4 · P3 · La confirmación de desinstalar se lee como si borrara todo

`ConfirmUninstall` (`baystream.iss:102`) pregunta «¿Seguro que quieres desinstalar
por completo %1 y todos sus componentes?». Es el texto estándar, pero es el momento
en que alguien teme por sus datos, y la aclaración llega recién al terminar.

Propuesta: «¿Seguro que quieres desinstalar %1? Tus datos en
%LOCALAPPDATA%\BayStream se conservan.»

### O-137-5 · P3 · En oscuro, los cuadros de texto no llevan el color de BayStream

`PrepararTexto` pide el papel oscuro `#07111f` para las dos páginas informativas,
pero en la captura `03-lo-que-hay-detras-oscuro.jpg` el cuadro sale `#1f1f1f` sobre
la página `#081120`. El tema del motor manda sobre ese color. Se lee bien, y es solo
de aspecto. Carlos decide en el recorrido si le molesta. El tema claro no lo vi.

### O-137-6 · P3 · 36 MB de restos de compilación dentro de la carga

La carga incluye `baystream.lib`, `baystream.exp` y las tres `*_plugin.lib`: 36.3 MB
que la app no usa al correr. Pasa por copiar la Release completa, como pide la
10.100, y no hace daño. Se podrían excluir con `Excludes` en `[Files]`. Lo dejo a
Carlos, porque entonces la carga ya no sería idéntica a la Release.

### O-137-7 · P3 · Tres detalles menores

- El asistente mostrará **1.0.0.9**, no «1.0.0». Es el recurso real del `.exe`, y
  Aplicaciones dirá lo mismo, mientras la MSIX dice 1.0.0.0. Es correcto. Solo hay
  que saberlo antes de la demostración.
- `ErrorMsix` espera a PowerShell sin límite de tiempo y con la ventana oculta. Si
  PowerShell se colgara, el asistente no abriría. No lo reproduje.
- La carga trae dos archivos viejos, solo en `proyecto-baystream`:
  `data/flutter_assets/NOTICES` y `AssetManifest.bin.json`, del 15-oct. Por eso allí
  son 29 archivos y en `baystream-qa-r4` son 27. No hace falta tocarlo. Sin un
  `flutter clean` seguirán ahí.

## Lo que se revisó y pasa

| Punto | Resultado | Evidencia |
|---|---|---|
| **Paso 0** | Pasa | 34 archivos sin versionar, iguales a la lista y al bloque de Git del informe. Cero en `lib/`, `test/`, `pubspec.*`, `android/`, `web/` y `tool/t93_msix.ps1`. Los tres de `windows/flutter/` solo cambian el fin de línea (`--numstat` vacío), y el informe lo declara |
| **El instalador y el almacén** | Pasa | Ninguna orden del `.iss` nombra el almacén, salvo el rechazo de carpeta. Almacén, hijos y padres quedan rechazados, en el clic y otra vez en `PrepareToInstall`, que cubre `/DIR` en silencio. Leído, no ejecutado: va al recorrido |
| **El desinstalador** | Pasa | Inno quita lo que registró. La única regla propia es `dirifempty` sobre `{app}`. `aceptacion-03`: 592 archivos con huella idéntica antes y después, sin residuos |
| **Sin administrador** | Pasa | `PrivilegesRequired=lowest`: la ayuda de 7.1.1 dice que siempre corre sin privilegios. Carpeta en `{localappdata}\Programs`, accesos en `{userprograms}` y `{userdesktop}`, entrada en `HKCU`, leída por la aceptación |
| **Las dos variantes** | Pasa | AppId, nombre, carpeta y archivo distintos. La de prueba no compila ningún `[Run]`, se marca `publicable: false` y no está en `C:\Users\Public` |
| **Rechazo cruzado de carpetas** | Pasa | La llave `{{#T137OtroAppId}}_is1` expande bien. La aceptación no pasaba por ahí, y lo probé con ISCC (abajo) |
| **Bloqueo si Get-AppxPackage o PowerShell fallan** | **Se detiene** | Si `Exec` falla o sale cualquier código distinto de 0 y 10, el asistente no sigue y lo explica. No instala en la duda. Se repite antes de copiar |
| **Versiones** | Pasa | Ninguna escrita a mano. App del recurso PE, paquetes de `pubspec.lock` cruzado con `package_config`, Flutter y Dart del SDK de la compilación, C++ de `version.h` |
| **Con la 1.0.0** | Pasa | Armado real contra una Release 1.0.0: 1.0.0.9, 6.10.2, 4.15.2, 13.13.1, 3.1.0 (abajo) |
| **Textos de tú** | Pasa | Los 30 mensajes propios existen en `Spanish.isl`. Los mensajes de usted sin sobrescribir son solo de errores: disco, ruta inválida, instalación dañada. Quedan fuera del recorrido normal, como declara Codex |
| **Textos veraces** | Falla H1 | Lo demás es cierto: sin administrador, solo tu cuenta, runtime dentro de la carpeta, el desinstalador conserva tus datos |
| **Arte** | Pasa | 28 de 28 PNG con huella y medida del manifiesto, 21 de 21 fuentes en esta carpeta, nada de más. Las siete medidas son las de la ayuda de 7.1.1, y los tres textos están en la imagen |
| **Entrega** | Pasa | Las tres copias en `C:\Users\Public\BayStream-T137\0.4.2.8\` dan las huellas de `entrega-public.json` (`c6ddb83e…`) |

**Dos sospechas mías que resultaron falsas:**
- Creí que `{{#` no se expandía. El preprocesador da `{BBBB-OTRO}_is1`, correcto.
- Creí que abrir el asistente desde PowerShell 7 rompería el bloqueo. Con un
  `PSModulePath` ajeno la consulta sigue dando 10. PowerShell 7 no está instalado en
  esta laptop, así que lo simulé solo con esa variable.

## Corridas

Con la luz verde y el SEMÁFORO de Carlos, de una en una. La evidencia está en
`build/t137/revision-timonel/evidencia/`.

| Corrida | Resultado |
|---|---|
| `flutter analyze --no-pub tool/t137_instalador.dart tool/t137_arte_test.dart` | Salida 0, sin incidencias, 5.0 s |
| Armado de prueba 0.4.2 en `build/t137/revision-timonel/` | Salida 0, 20 s. **32 de 32 archivos con las mismas huellas que el de Codex**, y además el mismo instalador: `b265d0af…`, 20,107,042 bytes. Los metadatos y el runtime también coinciden |
| Autorizada de más: ISCC con un script mínimo en mi carpeta temporal | Salida 0, y las dos formas de llave expanden bien |
| Autorizada de más: armado de prueba desde `baystream-qa-r4`, en `build/t137/revision-timonel-100/` | Salida 0, 20 s. `BayStream_Setup_1.0.0.9_prueba.exe`, 30 archivos, 5 módulos, Flutter 3.38.9, Dart 3.10.8, cloud_firestore 6.10.2, firebase_core 4.15.2, C++ 13.13.1 pedido y extraído, Riverpod 3.1.0 |

Ese último instalador es solo evidencia del armado: no se instala ni se publica. No
modifiqué los archivos de Codex. `pubspec.*`, `lib/` y `test/` siguen sin cambios.

## Cómo arma Carlos el asistente de la 1.0.0

Probado contra una Release 1.0.0 (la de `baystream-qa-r4`), con la variante de
prueba. La variante de producción contra `proyecto-baystream` se corre por primera
vez ese día.

**Antes:**
- La carpeta `C:\Proyectos\baystream-t137` sigue en su sitio, con esta herramienta.
- El asistente corregido de H1. Sin esa corrección, puede usarse en la laptop de
  Carlos, pero no en otra PC.

**Paso 1. La Release.** Es la misma que firma la MSIX: la deja la sección 4.2 de la
lista en `C:\Proyectos\proyecto-baystream\build\windows\x64\runner\Release`. No hagas
`flutter clean` ni recompiles después. `tool\t93_msix.ps1` deja la MSIX en `build\t93`,
fuera de la Release, así que no se mete en el asistente.

**Paso 2. Mira que la Release sea la buena.** Tienen que salir `1.0.0+9` y
`Firebase C++ 13.13.1`:

```powershell
$exe = 'C:\Proyectos\proyecto-baystream\build\windows\x64\runner\Release\baystream.exe'
(Get-Item -LiteralPath $exe).VersionInfo.FileVersion
[regex]::Matches([Text.Encoding]::ASCII.GetString([IO.File]::ReadAllBytes($exe)), 'Firebase C\+\+ [\d.]+') | ForEach-Object { $_.Value } | Sort-Object -Unique
```

**Paso 3. Arma, desde `baystream-t137`.** Tarda unos 20 segundos y usa un comando de
Dart, así que va con el SEMÁFORO:

```powershell
Set-Location -LiteralPath C:\Proyectos\baystream-t137
dart run tool\t137_instalador.dart --origen C:\Proyectos\proyecto-baystream --variante produccion --salida build\t137\v1.0.0
```

Las últimas líneas tienen que decir `Instalador: …`, `SHA-256: …`,
`AppId: {D837B138-34EF-4B47-9B86-58295383D542}` y `Origen verificado sin cambios.`
El asistente queda en `C:\Proyectos\baystream-t137\build\t137\v1.0.0\`.

| Si dice | Qué pasa | Qué haces |
|---|---|---|
| `Trampa de 10.99` | El SDK extraído no es el que pide `firebase_core` | No empaquetes. Vuelve a la 4.2 de la lista |
| `El arte quedó anterior a…` | Lo corriste desde otra carpeta (O-137-1) | No regeneres el arte. Vuelve a `baystream-t137` |
| `--origen debe conservar la ruta…` | La ruta no es la raíz del proyecto | Usa exactamente la del comando |

**Paso 4. Mira el manifiesto.** Tienen que salir `1.0.0.9`, `6.10.2`, `4.15.2`,
`13.13.1` dos veces, `produccion` y `True`. Son **32 archivos**, por los dos viejos de
O-137-7; con una compilación limpia serían 30, y también estaría bien:

```powershell
$m = Get-Content -LiteralPath build\t137\v1.0.0\BayStream_Setup_1.0.0.9.manifiesto.json -Raw -Encoding UTF8 | ConvertFrom-Json
$m.metadatos | Select-Object version, cloud_firestore, firebase_core, firebaseCpp, firebaseCppPedido, flutter, dart, flutter_riverpod
$m.variante; $m.publicable; @($m.archivos).Count
```

**Paso 5. Déjalo donde se reparte.** Solo el `.exe`, su `.sha256` y su
`.manifiesto.json`, nunca la variante de prueba:

```powershell
$d = 'C:\Users\Public\BayStream-T137\1.0.0.9'
New-Item -ItemType Directory -Path $d -Force | Out-Null
Copy-Item -LiteralPath build\t137\v1.0.0\BayStream_Setup_1.0.0.9.exe, build\t137\v1.0.0\BayStream_Setup_1.0.0.9.exe.sha256, build\t137\v1.0.0\BayStream_Setup_1.0.0.9.manifiesto.json -Destination $d
```

**Paso 6. En tu laptop.** Mientras tenga la MSIX, el asistente se detiene con el
aviso: es lo correcto. Si el jueves eliges el asistente:
1. Quita la MSIX desde Configuración → Aplicaciones. En tu laptop los datos se quedan:
   lo comprobé hoy.
2. Abre `BayStream_Setup_1.0.0.9.exe` y sigue el recorrido.
3. Lo primero, la sesión de oficina contra Firebase de verdad (10.102).

**Para volver a la MSIX:** primero desinstala el asistente desde Aplicaciones. La MSIX
no sabe nada de él: si instalas una encima, conviven con el mismo almacén.

## Para el recorrido de Carlos

Además de la lista del informe de Codex, cuatro cosas que nada automático cubrió:

1. **Es la primera vez que corre el camino sin MSIX**, en una cuenta estándar. Si
   aparece «Windows no pudo completar la consulta del paquete MSIX», anótalo: el
   asistente se detiene ahí y no hay otra forma de seguir.
2. En la página de la carpeta, escribe `C:\Users\<esa cuenta>\AppData\Local\BayStream`
   y pulsa Instalar. Tiene que rechazarla.
3. Desinstala una vez con BayStream abierta, y mira qué dice.
4. En oscuro, mira si el cuadro gris de O-137-5 te molesta.

## Archivos y Git

Archivo nuevo: `docs/t137/revision-timonel.md`. Cambio solo eso; `build/` está
ignorado. `pubspec.yaml` y `pubspec.lock` no cambian.

Para **Carlos**, después del commit de T-137:

```powershell
Set-Location -LiteralPath C:\Proyectos\baystream-t137
git add -- docs/t137/revision-timonel.md
git commit -m "Sprint 4: revision de T-137, no pasa por el aviso de la MSIX"
git push
```

## Tres líneas

T-137 NO PASA por un solo texto: el aviso de la MSIX promete que los datos se quedan, y en una PC sin carpeta previa se borran (10.37).
Todo lo demás pasa: datos, cuenta, variantes, versiones, arte, y el armado da el mismo instalador que el de Codex, también probado con una 1.0.0 real.
Quedan siete observaciones; la que más importa: armar solo desde `baystream-t137`, porque las huellas del arte dependen del fin de línea.

## Mensaje para Yov

> Yov: revisé T-137 y **no pasa, por un solo hallazgo** (`docs/t137/revision-timonel.md`).
> El aviso del bloqueo por MSIX dice «Tus datos se quedan: están fuera del paquete», y
> la 10.37 dice lo contrario para una PC sin BayStream previo: el almacén vive en el
> paquete y se borra al desinstalar. En la laptop de Carlos sí es cierto (lo comprobé:
> el paquete no tiene `BayStream`), y por eso la aceptación no podía verlo. La frase
> viene de la 10.100, así que también hay que corregirla ahí. Propongo el texto en el
> informe: son dos líneas y regenerar los instaladores, de preferencia antes del
> recorrido.
>
> Lo demás pasa. Mi armado salió idéntico al de Codex (32 de 32 y `b265d0af…`). Contra
> la 1.0.0 de `qa-r4` da 1.0.0.9, 6.10.2, 4.15.2 y 13.13.1. El bloqueo se detiene si
> PowerShell falla. Hay siete observaciones. Para la lista de la 1.0.0: **armar desde
> `baystream-t137`**, porque las huellas del arte dependen del fin de línea (O-137-1), y
> mirar el SDK dentro del `.exe` (O-137-2). El paso a paso está en el informe. La 1.0.0
> no cambia: T-137 no toca la app.

## Corrección

Fecha: 3 de noviembre de 2026. Corrige: Timonel, porque Codex se quedó sin tokens.
Carlos autorizó tocar T-137 solo para esto, y Yov revisa la corrección.

**Dictamen sobre H1: corregido.** El aviso ya no promete nada que sea falso en algún
equipo, y la aceptación pasa. O-137-4 también queda resuelta. **Falta para dar por
buena T-137:** la revisión de Yov, la captura del cuadro que manda Carlos y su
recorrido en «BayStream Prueba». Las demás observaciones quedan para después del 7-nov.

### El texto que se pidió no era cierto en todos los equipos

Me detuve antes de armar. El texto propuesto tenía dos problemas, y Carlos y Yov
dieron el texto final:

| Problema | Evidencia | Qué cambió |
|---|---|---|
| **En cualquier equipo.** «Abre BayStream y espera a que diga «Al día»» no ocurre: con el plano cerrado, nada lo dice | `syncStatusProvider` sigue la operación que se ve, y «Nube y cuenta» pide «Abre un plano con su escala confirmada para ver su operación.» | «abre cada una en BayStream» |
| **En dos casos raros.** «Si existe `%LOCALAPPDATA%\BayStream`, tus datos están ahí» es falso si la carpeta apareció después de la MSIX, porque Windows lee antes la copia privada (T-93, 3.3), y en Windows 10 anterior a 1903, donde toda escritura en AppData va al paquete (Microsoft Learn). La MSIX instala desde 10.0.17763 | `configuration.dart` de msix 3.18.0, `osMinVersion` | Se mira la carpeta del paquete, que es la prueba exacta, y se llega a ella por partes |

### El cambio en `windows/installer/baystream.iss`

Dos cambios y nada más. Lógica, arte y las demás páginas siguen igual. El anterior está
en `build/t137/h1-antes/baystream.iss` (`6c1f0aed…`).

**1. `ErrorMsix`, caso `Codigo = 10`:**

> BayStream ya está instalado como paquete MSIX en esta cuenta, y este asistente no
> lo reemplaza.
>
> Para saber dónde están tus datos, abre %LOCALAPPDATA%\Packages en el Explorador y
> entra en la carpeta que empieza por gt.cmartinez.baystream, después en LocalCache y
> en Local. Si ahí hay una carpeta BayStream, tus datos están dentro del paquete y se
> borran con él: si los necesitas, sigue con la MSIX. Si no la hay, están en
> %LOCALAPPDATA%\BayStream y se quedan al desinstalar la MSIX.
>
> Para cambiar al asistente: si tienes operaciones publicadas, abre cada una en
> BayStream y espera a que diga «Al día». Después desinstala BayStream en
> Configuración > Aplicaciones y abre este asistente otra vez.
>
> Este asistente no desinstala la MSIX y no copió archivos de la aplicación.

**2. `ConfirmUninstall`:** «¿Seguro que quieres desinstalar %1? Tus datos en
%LOCALAPPDATA%\BayStream se conservan.»

### Corridas

Con la luz verde y el SEMÁFORO de Carlos, de una en una.

| Corrida | Resultado | Evidencia |
|---|---|---|
| Archivo previo | Instaladores, sus tres archivos de la copia pública, `.iss` y captura del aviso anterior, copiados y comparados por huella | `build/t137/h1-antes/` |
| Armado de prueba, misma Release 0.4.2 (`b3389a8a…`, 29 archivos) | Salida 0, 23 s, 32 archivos, 5 módulos | `armado-prueba-h1-01.log` |
| Armado de producción, misma Release | Salida 0, 24 s, 32 archivos, 5 módulos | `armado-produccion-h1-01.log` |
| Aceptación automática por `.bat` y `explorer.exe` | **Aprobada** | `aceptacion-04/resultado.json` |
| Copia en `C:\Users\Public\BayStream-T137\0.4.2.8\` | Los tres archivos coinciden con los originales | `entrega-public-h1.json` |

Los dos armados conservan la misma carga de 32 archivos con las mismas huellas, los
mismos metadatos y el mismo AppId que los anteriores: solo cambian los instaladores.

| Variante | Archivo en `build/t137/` | Bytes | SHA-256 |
|---|---|---:|---|
| Producción | `BayStream_Setup_0.4.2.8.exe` | 20,107,728 | `0e4b8b07552f30720725dc4cfb7a671e309532d9834e2e9fc7a4ac6049d2db24` |
| Prueba | `BayStream_Setup_0.4.2.8_prueba.exe` | 20,107,014 | `a8952666e1437d611312fd43798bcafb21ab7bbfa7862fbc756d2f7c67cb760f` |

Los anteriores (`c6ddb83e…` y `b265d0af…`) quedan en `build/t137/h1-antes/` y como
`anterior-*` en las carpetas de `corridas/` de hoy.

**La aceptación, en `build/t137/aceptacion-04/`:**
- Proceso exterior: Explorer 7932 → cmd 18004 → Windows PowerShell 34228, con
  identidad 15700, sin paquete. BayStream cerrada, cero procesos antes y después.
- Instalación de prueba sin escritorio, instalación encima con escritorio y
  desinstalación, sin carpeta, accesos ni registro residuales.
- Producción detenida por la MSIX, salida 1, sin carpeta ni registro nuevos.
- **`produccion-msix.log` trae el aviso nuevo completo**, los cuatro párrafos, en la
  línea `T137_BLOQUEO_MSIX:`.
- Almacén real `C:\Users\Giova\AppData\Local\BayStream`: **592 archivos, huella idéntica
  antes y después**, `33c6c07fb8c608bba1ca1656a9859ce8d477a2d26186f59a5eaef40f02af1040`.

### Lo que esta corrida no comprueba

- **Cómo se ve el cuadro del aviso.** El registro prueba el texto, no el diseño. Lo
  comprueba Carlos: abre el asistente de producción en su cuenta, que se detiene por la
  MSIX sin instalar nada, y manda la captura.
- **Cómo se ve la confirmación de desinstalar.** La aceptación corre en silencio, así
  que ese cuadro no aparece. Lo ve Carlos en el recorrido, y ahí tiene que leerse
  `%LOCALAPPDATA%\BayStream` entero.
- **La rama «hay una carpeta BayStream».** Es texto y no lógica: el mismo aviso cubre
  los dos casos, y esa rama de la frase no se probó con una PC así.

### Git

El bloque de T-137 de `docs/T137-RESULTADOS.md` sigue con los **mismos 34 archivos**:
incluye `windows/installer/baystream.iss` y ese informe, ya con los cambios. Lo
comprobé contra el árbol. `pubspec.*`, `lib/`, `test/` y el arte no cambian.

Después de ese commit, Carlos sube esta revisión. Reemplaza al bloque de arriba:

```powershell
Set-Location -LiteralPath C:\Proyectos\baystream-t137
git add -- docs/t137/revision-timonel.md
git commit -m "Sprint 4: revision de T-137 y correccion del aviso de la MSIX"
git push
```
