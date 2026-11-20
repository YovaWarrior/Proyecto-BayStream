# Publicación de la 1.0.2 · Lista de comprobación (10.155)

La sigue Carlos, que es quien mezcla, compila y publica. La escribió Yov el 20-nov, con el
dictamen de la aceptación de la entrega 1 de T-147 (GLM 5.3 Flash, en Max: PASA) ya comprobado
contra la carpeta. Todo se hace desde **`C:\Proyectos\proyecto-baystream`**, en `master`, como la
1.0.0 y la 1.0.1 (10.115).

**Lo que se publica.** La candidata es `57497db` («Sprint 4: T-147, entrega 1: …»), en la rama
`t147-piloto4`, que sale de `v1.0.1`. La aceptación se hizo sobre ese mismo commit. Encima solo
puede venir el informe de GLM: la mezcla lo comprueba (1). **`sprint-4` no se publica:** trae
T-120 a medias.

| Cliente | Versión | Sobre qué |
|---|---|---|
| Android (AAB, prueba interna de Play) | `1.0.2`, `versionCode` **11** | El último subido es el 10 (17-nov) |
| Windows, MSIX | **1.0.2.0** | Encima de la 1.0.1.0, sin desinstalar |
| Windows, asistente | **1.0.2.11** | Encima del 1.0.1.10, o en una PC nueva. Sale de la misma Release que la MSIX |
| Web (Hosting) | `1.0.2`, compilación **11** | `version.json` lo deja visible. Es la que usa el iPhone |

`pubspec.yaml` dice `version: 1.0.2+11` y `msix_version: 1.0.2.0`, y los comandos lo repiten.
`pubspec.lock` es el de la 1.0.1.

**El orden:** la mezcla (1), apartar `build` y limpiar (2), Android (3), Windows (4), la Web (5),
la prueba corta en el iPhone y en el Honor (6) y el asistente (7). **Los tres clientes salen el
mismo día.**

**La regla entre versiones** (10.153, y 9.1 de `docs/T147-RESULTADOS.md`). Una operación guarda
el BAPLIE como vino, y cada equipo lo lee con su versión. Un plan que trae «NO» donde va la
matrícula lo leen distinto la 1.0.1 (una sola pieza llamada «NO») y la 1.0.2 (sus celdas
reservadas): lo que registra una no lo reconoce la otra. Por eso:
- un plan con «NO» no se opera con versiones mezcladas: primero se actualizan todos los equipos;
- un viaje que la 1.0.1 guardó en «Recientes» desde un plan con «NO» conserva lo que leyó
  entonces. Para verlo bien, se vuelve a abrir el archivo.

La operación del piloto 4 se publicó con la copia en blanco del plan: no le afecta.

**Lo que cambia frente a la lista de la 1.0.1:**
- se mezcla `t147-piloto4`, no `sprint-4`. Con la 1.0.2 publicada, `master` se mezcla en
  `sprint-4` (8.2);
- la carpeta `build\` de la 1.0.1 se aparta entera en `build-1.0.1`: ahí quedan su MSIX y su
  Web, para volver (9);
- antes de empezar se coteja que la Web en vivo sigue siendo la 1.0.1 del 17-nov (0.6);
- la prueba corta es el caso A09, el del piloto 4 ya anonimizado, y se mira en el iPhone, que es
  donde se trabó (6);
- cada bloque comprueba al empezar que sus herramientas están en la terminal (O-146-5), y 5.1 lee
  de `firebase.json` qué carpeta publica (O-146-6);
- las reglas de Firestore no cambian: siguen las de T-130.

**Cómo se usan los bloques.** Cada bloque va dentro de `& { … }` y se pega entero. Se detiene en
la primera comprobación que falle, con una línea que empieza con «Parar:» (en la Web, «No
publicar:») y dice qué pasó. Si un bloque se detiene, no se sigue con el siguiente: esa línea se
le pasa a Yov. Mientras corren 2, 3, 4 y 5, ningún agente corre Flutter ni Dart en la laptop
(`AGENTS.md`, «Trabajo en paralelo», 3).

**Los bloques salen de los de la 1.0.1,** que corrieron completos el 17-nov, con los números y
las rutas cambiados. Lo nuevo: el bloque 0.6, las guardias de la mezcla (1), la comprobación de
las herramientas, la guardia de `firebase.json` en 5.1 y el bloque 8.2. Yov no puede ejecutar
PowerShell: los pasó por un analizador de gramática, que no marca nada nuevo frente a los de la
1.0.1. No es el analizador de PowerShell.

**El registro.** Los bloques anotan las huellas, los tamaños y las horas en
`C:\Proyectos\baystream-rediseno\build\t147\publicacion\registro.txt`, fuera de Git. Yov lo lee
al final desde el equipo: no hace falta copiarle nada, salvo lo que se detenga.

---

## 0. Antes de empezar

| # | Qué | Lo que se tiene que ver |
|---|---|---|
| 0.1 | Los dos bloques de Git de la 10.155 ya corrieron: el informe de GLM, en `t147-piloto4`; `SPRINT-4.md` y esta lista, en `sprint-4` | En `baystream-rediseno`, `git log --oneline -1` muestra «Sprint 4: decision 10.155, …». El bloque 1 comprueba lo del informe |
| 0.2 | Ningún agente trabaja: Timonel y GLM, cerrados o en espera | Nadie corre Flutter ni Dart |
| 0.3 | Play Console: el último `versionCode` subido sigue siendo el **10** | Si alguien subió el 11, parar: la versión pasa a `1.0.2+12` y vuelve a la aceptación |
| 0.4 | Las reglas publicadas siguen siendo las de T-130 (bloque 0.4). Si nadie las tocó en la consola desde el 4-nov, se puede saltar | «Lo publicado son las reglas de T-130» |
| 0.5 | Con la cuenta de oficina, «Operaciones abiertas en la nube»: mirar cuáles hay | Ninguna de BUQUE HOTEL: la prueba corta publica la suya. La del piloto 4 se cierra: esa escala terminó. La de la presentación (BUQUE GOLF · VIAJE007A) se puede quedar |
| 0.6 | La Web en vivo sigue siendo la 1.0.1 del 17-nov (bloque 0.6; solo lee) | «La Web en vivo es la 1.0.1 (10) del 17-nov: las tres huellas coinciden» |
| 0.7 | En la laptop, BayStream cerrada. El iPhone y el Honor, con batería y con red | |

**0.5, el porqué.** Con una operación abierta de BUQUE HOTEL en GTSTC, la prueba corta de 6 no
puede publicar la suya. Y una operación publicada con un plan que trae «NO» no puede quedar
abierta mientras unos equipos están en la 1.0.1 y otros en la 1.0.2 (la regla de arriba). Que se
sepa, hoy no hay ninguna así: la del piloto usó la copia en blanco. Una operación se cierra desde
el equipo que la tiene, o con «Unirse» desde la laptop y después «Cerrar operación». Una
operación cerrada no se reabre: si una no se reconoce, no se cierra, y se le avisa a Yov.

### 0.4 · El cotejo de las reglas (desde `C:\Proyectos\baystream-rediseno`)

1. En Chrome, `https://console.firebase.google.com` → **baystream-app** → **Firestore
   Database** → pestaña **Reglas**. En el editor, Ctrl + A y Ctrl + C. No se cambia nada.
2. Pegarlo en un archivo nuevo,
   `C:\Proyectos\baystream-rediseno\build\t147\publicacion\reglas-publicadas.txt` (VS Code,
   «Guardar como», UTF-8). La carpeta ya existe.
3. El bloque:

```powershell
& {
Set-Location -LiteralPath C:\Proyectos\baystream-rediseno
if (-not (Get-Command node -ErrorAction SilentlyContinue)) { throw 'Parar: no esta node en el PATH de esta terminal' }
if (-not (Test-Path -LiteralPath build\t147\publicacion\reglas-publicadas.txt)) { throw 'Parar: falta build\t147\publicacion\reglas-publicadas.txt; guardar primero la copia de la consola' }
node tool/t113_reglas.mjs build/t147/publicacion/reglas-publicadas.txt build/t147/publicacion/cotejo-reglas docs/T130-firestore.rules.propuesta | Out-Null
if ($LASTEXITCODE -ne 0) { throw 'Parar: lo publicado no son las reglas de T-130; no publicar nada y avisar' }
'Lo publicado son las reglas de T-130 (8B903949...): se puede seguir'
}
```

El detalle queda en `build\t147\publicacion\cotejo-reglas\reglas-cotejo.json`, con la huella
normalizada `8B9039496CCCDA9FBC1412CC1F8610B3183D58FB4BA779EFB0C0C7D920EEFF71`.

### 0.6 · La Web en vivo es la 1.0.1 (solo lee)

```powershell
& {
$registro = 'C:\Proyectos\baystream-rediseno\build\t147\publicacion\registro.txt'
New-Item -ItemType Directory -Force -Path (Split-Path -Parent $registro) | Out-Null
function Anotar([string]$texto) { $linea = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')  $texto"; Add-Content -LiteralPath $registro -Value $linea -Encoding UTF8; $linea }
if (-not (Get-Command curl.exe -ErrorAction SilentlyContinue)) { throw 'Parar: no esta curl.exe en el PATH de esta terminal' }
$esperadas = [ordered]@{
  'version.json' = 'F845ED7F3906BD01A95F013616ADA4D122A7069663BB27F08099550FB837E410'
  'main.dart.js' = '812F236D9576BE2314AA8FB055C42FA8988FE6A73D2C852F1CB8AF996405BA58'
  'flutter_bootstrap.js' = 'F7A8C04FCEF9B49D22A1A446F2AD947DFAE22D4395F7B3BF00CE50B2B131585A'
}
$carpeta = Join-Path $env:TEMP "baystream-web-en-vivo-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
New-Item -ItemType Directory -Force -Path $carpeta | Out-Null
foreach ($archivo in $esperadas.Keys) {
  $copia = Join-Path $carpeta $archivo
  curl.exe -s -f -o $copia "https://baystream-app.web.app/$archivo"
  if ($LASTEXITCODE -ne 0) { throw "Parar: no se pudo bajar $archivo de la Web en vivo; revisar la red y repetir" }
  $huella = (Get-FileHash -LiteralPath $copia -Algorithm SHA256).Hash
  if ($huella -ne $esperadas[$archivo]) { throw "Parar: en vivo, $archivo no es el de la 1.0.1 del 17-nov (sale $huella). No publicar y avisar" }
}
Anotar '0.6 La Web en vivo es la 1.0.1 (10) del 17-nov: las tres huellas coinciden'
}
```

Baja `version.json`, `main.dart.js` y `flutter_bootstrap.js` a una carpeta de `%TEMP%` y compara
sus huellas con las que anotó la publicación del 17-nov (10.144). No cambia nada. Yov hizo el
mismo cotejo desde el equipo el 20-nov, hacia las 17:00, y coincidían. Si no coinciden, alguien
publicó otra cosa: no se sigue.

---

## 1. La mezcla (desde `C:\Proyectos\proyecto-baystream`)

`master` está en `37be8a5`, con la etiqueta `v1.0.1`. `t147-piloto4` sale de ese mismo commit,
así que la mezcla no puede tener conflictos: entran las 30 rutas de la entrega (12 archivos
cambiados y 18 nuevos) y el informe de GLM. Yov comprobó el 20-nov que ninguna de esas rutas
está cambiada ni existe sin seguimiento en `proyecto-baystream`; los documentos de tesis que
Carlos tiene modificados ahí no cambian con la mezcla. **Si Git marca un conflicto, o dice que
la mezcla sobrescribiría cambios locales, parar y avisar antes de resolver nada.**

```powershell
& {
$registro = 'C:\Proyectos\baystream-rediseno\build\t147\publicacion\registro.txt'
New-Item -ItemType Directory -Force -Path (Split-Path -Parent $registro) | Out-Null
function Anotar([string]$texto) { $linea = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')  $texto"; Add-Content -LiteralPath $registro -Value $linea -Encoding UTF8; $linea }
if (-not (Get-Command git -ErrorAction SilentlyContinue)) { throw 'Parar: no esta git en el PATH de esta terminal' }
Set-Location -LiteralPath C:\Proyectos\proyecto-baystream
if ((git branch --show-current) -ne 'master') { throw 'Parar: la carpeta no esta en master' }
if ((git rev-parse HEAD) -notlike '37be8a5*') { throw 'Parar: master no esta en 37be8a5' }
git fetch origin
if ($LASTEXITCODE -ne 0) { throw 'Parar: git fetch fallo; revisar la red' }
git merge-base --is-ancestor 57497db origin/t147-piloto4
if ($LASTEXITCODE -ne 0) { throw 'Parar: en GitHub, t147-piloto4 no contiene 57497db, la entrega aceptada; avisar' }
git cat-file -e 'origin/t147-piloto4:docs/t147/entrega1/aceptacion-glm.md'
if ($LASTEXITCODE -ne 0) { throw 'Parar: en GitHub, t147-piloto4 todavia no trae el informe de GLM; falta su bloque de Git (10.155)' }
if (-not (git show origin/t147-piloto4:pubspec.yaml | Select-String -Pattern '^version: 1\.0\.2\+11' -Quiet)) { throw 'Parar: t147-piloto4 no trae la 1.0.2+11' }
git diff --quiet 57497db origin/t147-piloto4 -- lib test integration_test tool android windows web assets pubspec.yaml pubspec.lock firebase.json
if ($LASTEXITCODE -ne 0) { throw 'Parar: t147-piloto4 trae codigo que GLM no acepto (10.155); avisar' }
git merge --no-ff --no-commit origin/t147-piloto4
if ($LASTEXITCODE -ne 0) { throw 'Parar: la mezcla no salio limpia; no resolver nada y avisar' }
git commit -m "Sprint 4: la 1.0.2, mezcla de t147-piloto4 a master"
if ($LASTEXITCODE -ne 0) { throw 'Parar: el commit de la mezcla no salio' }
git tag -a v1.0.2 -m "BayStream 1.0.2, los defectos del piloto 4: la hoja de los vacios, NO como celda reservada y el cruce por el POT (Sprint 4)"
if ($LASTEXITCODE -ne 0) { throw 'Parar: la etiqueta v1.0.2 no salio; avisar antes de subir nada' }
git push origin master
if ($LASTEXITCODE -ne 0) { throw 'Parar: master no subio; revisar la red y repetir solo los dos git push' }
git push origin v1.0.2
if ($LASTEXITCODE -ne 0) { throw 'Parar: la etiqueta no subio; repetir solo git push origin v1.0.2' }
Anotar "1 Mezcla: master en $(git rev-parse --short HEAD), con la etiqueta v1.0.2"
git log --oneline -1
}
```

Las comprobaciones del principio detienen el bloque si la carpeta no está en `master`, si
`master` no está en `37be8a5`, si en GitHub `t147-piloto4` no contiene la entrega aceptada, si
todavía no trae el informe de GLM, si no dice `1.0.2+11` o si trae código que GLM no aceptó:
desde `57497db` solo pueden cambiar documentos. Se mezcla `origin/t147-piloto4`, lo que hay en
GitHub: la rama local de `baystream-t147` no hace falta moverla. La mezcla se detiene antes del
commit («stopped before committing as requested»): es lo esperado, y el `git commit` la cierra.
La última línea tiene que mostrar «Sprint 4: la 1.0.2, mezcla de t147-piloto4 a master».
`v1.0.1` sigue en Git para volver (9).

---

## 2. Apartar `build` y limpiar (desde esa carpeta, ya en `v1.0.2`)

`flutter clean` borra toda la carpeta `build\`, y ahí vive lo que se publicó el 17-nov: la MSIX
1.0.1.0, el asistente 1.0.1.10, la Web 1.0.1 y el `.zip` del SDK de C++ de Firebase. Por eso la
carpeta entera se renombra a `C:\Proyectos\baystream-publicaciones\build-1.0.1`, que es
instantáneo y no pierde nada, y después se limpia. Queda al lado de `build-hasta-1.0.0`, que no
se toca. Ningún editor ni otra terminal tiene abierta esa carpeta.

```powershell
& {
$registro = 'C:\Proyectos\baystream-rediseno\build\t147\publicacion\registro.txt'
New-Item -ItemType Directory -Force -Path (Split-Path -Parent $registro) | Out-Null
function Anotar([string]$texto) { $linea = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')  $texto"; Add-Content -LiteralPath $registro -Value $linea -Encoding UTF8; $linea }
foreach ($herramienta in 'git', 'flutter') { if (-not (Get-Command $herramienta -ErrorAction SilentlyContinue)) { throw "Parar: no esta $herramienta en el PATH de esta terminal" } }
Set-Location -LiteralPath C:\Proyectos\proyecto-baystream
if (Get-Process -Name baystream -ErrorAction SilentlyContinue) { throw 'Parar: cierra BayStream antes de seguir' }
if ((git describe --tags --exact-match HEAD 2>$null) -ne 'v1.0.2') { throw 'Parar: la carpeta no esta en v1.0.2; primero la mezcla (1)' }
if ($env:FIREBASE_CPP_SDK_DIR) { throw 'Parar: la variable FIREBASE_CPP_SDK_DIR tiene valor y CMake usaria ese SDK; avisar' }
if ((Get-PSDrive -Name C).Free -lt 20000000000) { throw 'Parar: quedan menos de 20 GB libres en C:' }
$publicaciones = 'C:\Proyectos\baystream-publicaciones'
$apartado = Join-Path $publicaciones 'build-1.0.1'
if (Test-Path -LiteralPath $apartado) {
  if (Test-Path -LiteralPath build) { throw 'Parar: este bloque ya corrio: hay un build apartado y otro nuevo. No se repite; seguir con Android (3)' }
  "build ya estaba apartado en $apartado. Sigo con las comprobaciones"
} else {
  if (-not (Test-Path -LiteralPath build)) { throw 'Parar: no hay carpeta build que apartar; avisar' }
  New-Item -ItemType Directory -Force -Path $publicaciones | Out-Null
  try { [IO.Directory]::Move('C:\Proyectos\proyecto-baystream\build', $apartado) } catch { throw "Parar: no se pudo apartar build ($($_.Exception.Message)). No se movio nada: cerrar lo que la tenga abierta (el Explorador, un editor, otra terminal) y repetir" }
}
$msix = Join-Path $apartado 't93\BayStream_1.0.1.0.msix'
if (-not (Test-Path -LiteralPath $msix)) { throw "Parar: falta $msix, la MSIX de la vuelta atras" }
if ((Get-FileHash -LiteralPath $msix -Algorithm SHA256).Hash -ne 'CBB75D003742F025DEE662CF7C1605AD474818B09C6AABDD63D2A2C541222DCE') { throw 'Parar: el BayStream_1.0.1.0.msix apartado no tiene la huella anotada; avisar' }
$zip = Join-Path $apartado 'windows\x64\firebase_cpp_sdk_windows_13.13.1.zip'
$huellaZip = '061508DE65535EF11E47DD7D0F1DE5780AED58D19865B71504F70F66FD3F9954'
if (-not (Test-Path -LiteralPath $zip)) { throw "Parar: falta $zip; avisar" }
if ((Get-FileHash -LiteralPath $zip -Algorithm SHA256).Hash -ne $huellaZip) { throw 'Parar: el .zip del SDK de C++ no tiene la huella anotada; no se copia. Avisar' }
flutter clean
if ($LASTEXITCODE -ne 0) { throw 'Parar: flutter clean fallo' }
New-Item -ItemType Directory -Force -Path build\windows\x64 | Out-Null
Copy-Item -LiteralPath $zip -Destination build\windows\x64
if ((Get-FileHash -LiteralPath build\windows\x64\firebase_cpp_sdk_windows_13.13.1.zip -Algorithm SHA256).Hash -ne $huellaZip) { throw 'Parar: la copia del .zip no salio igual; borrarla y avisar' }
Anotar "2 build apartado en $apartado, con la MSIX 1.0.1.0 en su huella; flutter clean; el .zip del SDK 13.13.1, copiado"
}
```

Lo que deja:
- `C:\Proyectos\baystream-publicaciones\build-1.0.1\`: el `build\` de la 1.0.1, entero. En su
  `t93\` está `BayStream_1.0.1.0.msix` (`CBB75D00…`), para volver (9), y en su `web\`, la Web
  1.0.1 publicada;
- un `build\` nuevo, solo con el `.zip` del SDK de C++ 13.13.1 (963 835 368 bytes, `061508DE…`).
  Con él, la compilación de Windows no baja los 920 MB otra vez; los extrae, que son 8.5 GB.
  `extracted` no se copia nunca: es la trampa de la 10.99.

Si el bloque se detuvo después de apartar y se repite, sigue desde las comprobaciones. Si ya
terminó una vez, no se repite: lo dice él mismo.

---

## 3. Android, primero (prueba interna de Play)

Va primero porque Play tarda en procesar el paquete; mientras tanto se hace Windows.

```powershell
& {
$registro = 'C:\Proyectos\baystream-rediseno\build\t147\publicacion\registro.txt'
New-Item -ItemType Directory -Force -Path (Split-Path -Parent $registro) | Out-Null
function Anotar([string]$texto) { $linea = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')  $texto"; Add-Content -LiteralPath $registro -Value $linea -Encoding UTF8; $linea }
foreach ($herramienta in 'git', 'flutter') { if (-not (Get-Command $herramienta -ErrorAction SilentlyContinue)) { throw "Parar: no esta $herramienta en el PATH de esta terminal" } }
Set-Location -LiteralPath C:\Proyectos\proyecto-baystream
if ((git describe --tags --exact-match HEAD 2>$null) -ne 'v1.0.2') { throw 'Parar: la carpeta no esta en v1.0.2' }
if (-not (Test-Path -LiteralPath android\key.properties)) { throw 'Parar: falta android\key.properties; el AAB saldria con la firma de depuracion' }
flutter build appbundle --release --build-name=1.0.2 --build-number=11 --dart-define-from-file=C:\Proyectos\baystream-privado\firebase-prod.json
if ($LASTEXITCODE -ne 0) { throw 'Parar: el AAB no salio; no subir nada' }
$aab = 'C:\Proyectos\proyecto-baystream\build\app\outputs\bundle\release\app-release.aab'
if (-not (Test-Path -LiteralPath $aab)) { throw "Parar: no esta $aab" }
$bytes = (Get-Item -LiteralPath $aab).Length
$huella = (Get-FileHash -LiteralPath $aab -Algorithm SHA256).Hash
Anotar "3 AAB 1.0.2 (11): $bytes bytes, SHA-256 $huella"
}
```

Sin `--no-pub` (10.86). Firma con la clave de subida de `android\key.properties` (T-49), que
está en esa carpeta y fuera de Git; el bloque solo comprueba que el archivo existe. Después:

1. Play Console → BayStream → **Prueba interna** → crear una versión → subir
   `build\app\outputs\bundle\release\app-release.aab`. Play tiene que decir **11 (1.0.2)**.
   Producción queda fuera.
2. Las novedades de la versión:

   ```
   BayStream 1.0.2
   - La hoja «Vacíos del listado» abre al instante, también con cientos de celdas reservadas.
   - Un plan que trae «NO» donde va la matrícula se lee como celdas reservadas, y lo avisa.
   - Avisa si una matrícula viene en más de una celda.
   - El listado de la agencia cruza por el puerto de transbordo (POT) y muestra el destino final.
   - Reconoce las secciones «TRANSBORDOS», «VACIOS» y «AGREGADOS» del listado.
   ```
3. Guardar, revisar e iniciar el lanzamiento en la prueba interna. Play volverá a avisar que
   deja fuera los equipos sin micrófono: el Honor lo tiene.
4. Seguir con Windows. El Honor se actualiza en 6. **Al Honor nunca se le manda una compilación
   local:** ni `flutter run`, ni `flutter install`, ni `adb install` (10.96).

---

## 4. Windows

Una sola compilación Release, y de ella salen los dos paquetes: la MSIX 1.0.2.0 (4.1) y el
asistente 1.0.2.11 (4.2). La laptop de Carlos tiene la MSIX 1.0.1.0 y se actualiza con la MSIX
(4.3).

### 4.1 La Release y la MSIX

```powershell
& {
$registro = 'C:\Proyectos\baystream-rediseno\build\t147\publicacion\registro.txt'
New-Item -ItemType Directory -Force -Path (Split-Path -Parent $registro) | Out-Null
function Anotar([string]$texto) { $linea = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')  $texto"; Add-Content -LiteralPath $registro -Value $linea -Encoding UTF8; $linea }
foreach ($herramienta in 'git', 'flutter', 'dart') { if (-not (Get-Command $herramienta -ErrorAction SilentlyContinue)) { throw "Parar: no esta $herramienta en el PATH de esta terminal" } }
Set-Location -LiteralPath C:\Proyectos\proyecto-baystream
if ((git describe --tags --exact-match HEAD 2>$null) -ne 'v1.0.2') { throw 'Parar: la carpeta no esta en v1.0.2' }
if ($env:FIREBASE_CPP_SDK_DIR) { throw 'Parar: la variable FIREBASE_CPP_SDK_DIR tiene valor y CMake usaria ese SDK; avisar' }
$h = @(Get-ChildItem Cert:\CurrentUser\My | Where-Object Subject -eq 'CN=BayStream')
if ($h.Count -ne 1) { throw "Parar: hay $($h.Count) certificados CN=BayStream y tiene que haber 1" }
powershell -NoProfile -ExecutionPolicy Bypass -File tool\t93_msix.ps1 -Huella $h[0].Thumbprint -Version 1.0.2.0
if ($LASTEXITCODE -ne 0) { throw 'Parar: el MSIX no salio o no paso la verificacion; no se instalo nada' }
$exe = 'C:\Proyectos\proyecto-baystream\build\windows\x64\runner\Release\baystream.exe'
$v = [Diagnostics.FileVersionInfo]::GetVersionInfo($exe)
$numero = '{0}.{1}.{2}.{3}' -f $v.FileMajorPart, $v.FileMinorPart, $v.FileBuildPart, $v.FilePrivatePart
if ($numero -ne '1.0.2.11' -or $v.ProductVersion -ne '1.0.2+11') { throw "Parar: el .exe dice $numero y $($v.ProductVersion), y tiene que decir 1.0.2.11 y 1.0.2+11" }
$texto = [Text.Encoding]::GetEncoding(28591).GetString([IO.File]::ReadAllBytes($exe))
$sdk = @([regex]::Matches($texto, 'Firebase C\+\+ (\d+\.\d+\.\d+)') | ForEach-Object { $_.Groups[1].Value } | Sort-Object -Unique)
if ($sdk.Count -ne 1 -or $sdk[0] -ne '13.13.1') { throw "Parar: el .exe enlaza Firebase C++ '$($sdk -join ', ')' y tiene que ser solo el 13.13.1 (10.99)" }
$msix = 'C:\Proyectos\proyecto-baystream\build\t93\BayStream_1.0.2.0.msix'
$bytes = (Get-Item -LiteralPath $msix).Length
$huella = (Get-FileHash -LiteralPath $msix -Algorithm SHA256).Hash
Anotar "4.1 Release 1.0.2.11 (1.0.2+11) con Firebase C++ 13.13.1. MSIX 1.0.2.0: $bytes bytes, SHA-256 $huella"
}
```

El script de T-93 corre `flutter pub get`, comprueba el SDK de C++ («no hay extracted. La
compilacion extrae el 13.13.1.»), compila Release con la configuración privada (`-Opciones`
apunta a `C:\Proyectos\baystream-privado\firebase-prod.json` por omisión, sin abrirla) y
termina verificando la firma `Valid`, la huella del certificado (`60BEF8F4…`) y el `.sha256`.
**`-Version` va siempre:** el valor por omisión del script sigue siendo `1.0.0.0` (O-146-2).
Después, el bloque mira dentro del `.exe`: la versión `1.0.2.11` y `1.0.2+11`, y una sola
`Firebase C++ 13.13.1` (O-137-2). El aviso LNK4078 del enlazador es el de la 1.0.0 (10.105) y
no detiene nada. Queda `build\t93\BayStream_1.0.2.0.msix` con su `.sha256`: es lo que recibe
quien ya tiene la MSIX.

### 4.2 El asistente 1.0.2.11, de la misma Release

Sin compilar otra vez. Si se detiene, dice por qué, y la MSIX no depende de él.

```powershell
& {
$registro = 'C:\Proyectos\baystream-rediseno\build\t147\publicacion\registro.txt'
New-Item -ItemType Directory -Force -Path (Split-Path -Parent $registro) | Out-Null
function Anotar([string]$texto) { $linea = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')  $texto"; Add-Content -LiteralPath $registro -Value $linea -Encoding UTF8; $linea }
foreach ($herramienta in 'git', 'dart') { if (-not (Get-Command $herramienta -ErrorAction SilentlyContinue)) { throw "Parar: no esta $herramienta en el PATH de esta terminal" } }
Set-Location -LiteralPath C:\Proyectos\proyecto-baystream
if ((git describe --tags --exact-match HEAD 2>$null) -ne 'v1.0.2') { throw 'Parar: la carpeta no esta en v1.0.2' }
dart run tool/t137_instalador.dart --origen C:\Proyectos\proyecto-baystream --variante produccion --salida build/t137/v1.0.2
if ($LASTEXITCODE -ne 0) { throw 'Parar: el asistente no se armo. La MSIX no depende de el: avisar con el mensaje y seguir con 4.3' }
$base = 'C:\Proyectos\proyecto-baystream\build\t137\v1.0.2\BayStream_Setup_1.0.2.11'
$partes = '.exe', '.exe.sha256', '.manifiesto.json', '.inno-manifiesto.txt'
foreach ($parte in $partes) { if (-not (Test-Path -LiteralPath ($base + $parte))) { throw "Parar: falta ${base}${parte}" } }
$m = Get-Content -LiteralPath ($base + '.manifiesto.json') -Raw -Encoding UTF8 | ConvertFrom-Json
if ($m.variante -ne 'produccion' -or $m.publicable -ne $true) { throw 'Parar: el manifiesto no es de produccion' }
if ($m.version -ne '1.0.2.11') { throw "Parar: el manifiesto dice la version $($m.version)" }
if ($m.metadatos.firebaseCppExe -ne '13.13.1') { throw "Parar: el manifiesto dice Firebase C++ $($m.metadatos.firebaseCppExe) dentro del .exe" }
$excluidos = @($m.excluidos).Count
if ($excluidos -ne 5) { throw "Parar: hay $excluidos excluidos y tienen que ser 5" }
$avisos = @($m.avisos)
if ($avisos.Count -ne 0) { throw "Parar: el armado dejo avisos y no se reparte: $($avisos -join ' / ')" }
$huella = (Get-FileHash -LiteralPath ($base + '.exe') -Algorithm SHA256).Hash
if ($huella -ne ([string]$m.instalador.sha256).ToUpperInvariant()) { throw 'Parar: el instalador no coincide con su manifiesto' }
$destino = 'C:\Users\Public\BayStream-1.0.2'
New-Item -ItemType Directory -Force -Path $destino | Out-Null
foreach ($parte in $partes) { Copy-Item -LiteralPath ($base + $parte) -Destination $destino -Force }
if ((Get-FileHash -LiteralPath (Join-Path $destino 'BayStream_Setup_1.0.2.11.exe') -Algorithm SHA256).Hash -ne $huella) { throw 'Parar: la copia en Public no salio igual' }
$bytes = (Get-Item -LiteralPath ($base + '.exe')).Length
$carga = @($m.archivos).Count
Anotar "4.2 Asistente 1.0.2.11: $bytes bytes, SHA-256 $huella. Carga de $carga archivos (se esperan 24), 5 excluidos, sin avisos. Copiado a $destino"
}
```

Lo que tiene que decir el armador:
- «T-137: Release 1.0.2.11 · produccion · 26 archivos de origen, 5 fuera de la carga.»;
- «Origen verificado sin cambios. 24 archivos en la carga; 5 módulos PE.»;
- ninguna línea de avisos.

Los 26 y los 24 son los de la 1.0.1, medidos al publicarla (10.144): T-147 no agrega ni quita
archivos de la Release. Si la carga no es de 24, no detiene: queda en el registro y Yov lo mira
antes de que el asistente se reparta. El guion del asistente (`windows/installer/`) es el mismo
de la 1.0.1.

El asistente queda en `C:\Users\Public\BayStream-1.0.2\`, con su `.sha256` y sus dos
manifiestos. **No se reparte hasta que pase 7.**

### 4.3 La copia de los datos y la MSIX en la laptop

Con BayStream cerrada. Verifica el paquete, copia las dos carpetas de datos y solo entonces
instala; si algo falla antes, no toca nada.

```powershell
& {
$registro = 'C:\Proyectos\baystream-rediseno\build\t147\publicacion\registro.txt'
New-Item -ItemType Directory -Force -Path (Split-Path -Parent $registro) | Out-Null
function Anotar([string]$texto) { $linea = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')  $texto"; Add-Content -LiteralPath $registro -Value $linea -Encoding UTF8; $linea }
if (-not (Get-Command robocopy -ErrorAction SilentlyContinue)) { throw 'Parar: no esta robocopy en el PATH de esta terminal' }
Set-Location -LiteralPath C:\Proyectos\proyecto-baystream
if (Get-Process -Name baystream -ErrorAction SilentlyContinue) { throw 'Parar: cierra BayStream antes de seguir' }
$h = @(Get-ChildItem Cert:\CurrentUser\My | Where-Object Subject -eq 'CN=BayStream')
if ($h.Count -ne 1) { throw "Parar: hay $($h.Count) certificados CN=BayStream y tiene que haber 1" }
$msix = 'C:\Proyectos\proyecto-baystream\build\t93\BayStream_1.0.2.0.msix'
powershell -NoProfile -ExecutionPolicy Bypass -File tool\t93_msix.ps1 -Huella $h[0].Thumbprint -Verificar $msix
if ($LASTEXITCODE -ne 0) { throw 'Parar: la MSIX 1.0.2.0 no pasa la verificacion; no se instalo nada' }
$app = @(Get-AppxPackage | Where-Object Name -like '*baystream*')
if ($app.Count -ne 1) { throw "Parar: hay $($app.Count) paquetes de BayStream instalados y tiene que haber 1" }
$instalada = [version]$app[0].Version
if ($instalada -ne [version]'1.0.1.0') { throw "Parar: la instalada es la $instalada y no la 1.0.1.0; avisar" }
$respaldo = "C:\Proyectos\respaldo-almacen-$(Get-Date -Format yyyyMMdd-HHmm)"
$copiadas = 0
$fuera = Join-Path $env:LOCALAPPDATA 'BayStream'
if (Test-Path -LiteralPath $fuera) {
  robocopy $fuera "$respaldo\fuera\BayStream" /E /R:1 /W:1 /NFL /NDL /NJH
  if ($LASTEXITCODE -ge 8) { throw 'Parar: la copia del almacen de fuera fallo; no se instalo nada' }
  $copiadas++
}
$dentro = Join-Path $env:LOCALAPPDATA "Packages\$($app[0].PackageFamilyName)\LocalCache\Local\BayStream"
if (Test-Path -LiteralPath $dentro) {
  robocopy $dentro "$respaldo\paquete\BayStream" /E /R:1 /W:1 /NFL /NDL /NJH
  if ($LASTEXITCODE -ge 8) { throw 'Parar: la copia del almacen del paquete fallo; no se instalo nada' }
  $copiadas++
}
if ($copiadas -eq 0) { throw 'Parar: no hay almacen de BayStream ni fuera ni dentro del paquete; avisar antes de instalar' }
Anotar "4.3 Copia de los datos en $respaldo ($copiadas carpetas). Se instala la 1.0.2.0 encima de la $instalada"
try { Add-AppxPackage -Path $msix -ErrorAction Stop } catch { throw "Parar: no se instalo la 1.0.2.0 ($_); la $instalada sigue instalada" }
$ahora = @(Get-AppxPackage | Where-Object Name -like '*baystream*')
Anotar "4.3 Instalada: $($ahora[0].Name) $($ahora[0].Version)"
}
```

La última línea tiene que mostrar la 1.0.2.0. La copia queda en
`C:\Proyectos\respaldo-almacen-<fecha>\`, con `fuera\` y `paquete\`. Actualizar una MSIX no
borra los datos del paquete; solo los borra desinstalarla (10.144). Si el bloque se detiene
porque la instalada no es la 1.0.1.0, la línea dice cuál es.

### 4.4 La sesión de oficina

Abrir BayStream desde Inicio:
- Configuración → Aplicaciones dice **BayStream 1.0.2.0**;
- la app abre con los datos de siempre: los mismos viajes en «Recientes en este dispositivo» y
  los mismos perfiles;
- «Nube y cuenta» dice el nombre, «Oficina» y **«Cuenta autorizada»**, sin volver a iniciar
  sesión.

Si pide iniciar sesión, se inicia y se anota. Si faltan viajes o perfiles, parar y avisar: la
copia de 4.3 los tiene. Un viaje de «Recientes» que venga de un plan con «NO» abre como lo
guardó la 1.0.1, con las celdas «NO» como contenedores: se vuelve a abrir el archivo.

---

## 5. La Web, al final (Hosting)

### 5.1 Compilar, comprobar y publicar

```powershell
& {
$registro = 'C:\Proyectos\baystream-rediseno\build\t147\publicacion\registro.txt'
New-Item -ItemType Directory -Force -Path (Split-Path -Parent $registro) | Out-Null
function Anotar([string]$texto) { $linea = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')  $texto"; Add-Content -LiteralPath $registro -Value $linea -Encoding UTF8; $linea }
foreach ($herramienta in 'git', 'flutter', 'dart', 'firebase') { if (-not (Get-Command $herramienta -ErrorAction SilentlyContinue)) { throw "Parar: no esta $herramienta en el PATH de esta terminal" } }
Set-Location -LiteralPath C:\Proyectos\proyecto-baystream
if ((git describe --tags --exact-match HEAD 2>$null) -ne 'v1.0.2') { throw 'No publicar: la carpeta no esta en v1.0.2' }
$publico = (Get-Content -LiteralPath firebase.json -Raw | ConvertFrom-Json).hosting.public
if ($publico -ne 'build/web') { throw "No publicar: firebase.json publica '$publico' y tiene que ser build/web" }
$destino = 'C:\Proyectos\proyecto-baystream\build\web'
if (Test-Path -LiteralPath $destino) { Remove-Item -LiteralPath $destino -Recurse -Force }
flutter build web --release --output=build/web --build-name=1.0.2 --build-number=11 --dart-define-from-file=C:\Proyectos\baystream-privado\firebase-prod.json
if ($LASTEXITCODE -ne 0) { throw 'No publicar: build fallido' }
if (-not (Select-String -LiteralPath build\web\main.dart.js -Pattern 'flutter-fire-auth' -SimpleMatch -Quiet)) { throw 'No publicar: la Web salio sin Firebase Auth' }
$ver = Get-Content -LiteralPath build\web\version.json -Raw | ConvertFrom-Json
if ($ver.version -ne '1.0.2' -or [string]$ver.build_number -ne '11') { throw "No publicar: version.json dice $($ver.version) ($($ver.build_number))" }
$sdkWeb = @(Get-ChildItem -LiteralPath build\web\vendor\firebase -Directory | ForEach-Object { $_.Name })
if ($sdkWeb.Count -ne 1 -or $sdkWeb[0] -ne '12.19.0') { throw "No publicar: en vendor\firebase hay '$($sdkWeb -join ', ')' y tiene que estar solo la 12.19.0" }
dart run tool/t92_verify.dart build/web
if ($LASTEXITCODE -ne 0) { throw 'No publicar: verificacion fallida' }
foreach ($archivo in 'version.json', 'main.dart.js', 'flutter_bootstrap.js') {
  $huella = (Get-FileHash -LiteralPath (Join-Path $destino $archivo) -Algorithm SHA256).Hash
  Anotar "5.1 Web 1.0.2 (11), antes de publicar: $archivo $huella"
}
firebase deploy --only hosting --project baystream-app
if ($LASTEXITCODE -ne 0) { throw 'Parar: firebase deploy fallo; la Web publicada sigue siendo la de antes. Avisar' }
Anotar '5.1 Web publicada con firebase deploy --only hosting --project baystream-app'
}
```

**Nunca `firebase deploy` a secas.** El bloque comprueba que `firebase.json` publica
`build/web`, `version.json`, que solo vaya el SDK web 12.19.0 (T-92) y `t92_verify`, y anota las
tres huellas antes de publicar (10.115). Las cabeceras de seguridad van en `firebase.json`, que
no cambia desde la 10.116. Si `firebase deploy` dice que falta la sesión, `firebase login` y
repetir el bloque: compila otra vez, y valen las huellas de la última corrida.

### 5.2 En vivo

```powershell
& {
$registro = 'C:\Proyectos\baystream-rediseno\build\t147\publicacion\registro.txt'
New-Item -ItemType Directory -Force -Path (Split-Path -Parent $registro) | Out-Null
function Anotar([string]$texto) { $linea = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')  $texto"; Add-Content -LiteralPath $registro -Value $linea -Encoding UTF8; $linea }
if (-not (Get-Command curl.exe -ErrorAction SilentlyContinue)) { throw 'Parar: no esta curl.exe en el PATH de esta terminal' }
foreach ($url in 'https://baystream-app.web.app/', 'https://baystream-app.web.app/privacidad.html') {
  $cabeceras = @(curl.exe -sI $url)
  foreach ($nombre in 'content-security-policy', 'x-content-type-options', 'x-frame-options', 'referrer-policy', 'permissions-policy') {
    if (-not ($cabeceras | Select-String -Pattern "^${nombre}:" -Quiet)) { throw "Parar: falta la cabecera $nombre en $url" }
  }
  $hsts = @($cabeceras | Select-String -Pattern '^strict-transport-security:').Count
  if ($hsts -ne 1) { throw "Parar: Strict-Transport-Security sale $hsts veces en $url" }
  Anotar "5.2 En vivo, las cinco cabeceras y un solo HSTS en $url"
}
$vivo = (curl.exe -s https://baystream-app.web.app/version.json) -join '' | ConvertFrom-Json
if ($vivo.version -ne '1.0.2' -or [string]$vivo.build_number -ne '11') { throw "Parar: en vivo, version.json dice $($vivo.version) ($($vivo.build_number))" }
Anotar "5.2 En vivo, version.json dice $($vivo.version) ($($vivo.build_number))"
}
```

Después, en una ventana de incógnito de Chrome, `https://baystream-app.web.app`: iniciar sesión
con la cuenta de oficina y ver «Cuenta autorizada». Quien ya visitó el sitio puede ver una vez
la versión anterior por el *service worker*: recargar. En el Honor y en Safari se espera en la
consola la línea `Refused to load the script 'https://apis.google.com/js/api.js…'`, que no
detiene nada si la sesión se inicia con normalidad (10.115). Yov coteja desde el equipo las
huellas en vivo con las del registro.

---

## 6. El iPhone, el Honor y la prueba corta

**El iPhone** usa la Web. En Safari, `https://baystream-app.web.app/version.json` tiene que
decir `"version":"1.0.2","build_number":"11"`; si dice 1.0.1, recargar la app, o cerrarla y
abrirla, hasta que cambie. La sesión sigue iniciada.

**El Honor.** Actualizar por el enlace de la prueba interna, o en Play Store → BayStream →
«Actualizar». Puede tardar unos minutos en ofrecerla. En Ajustes → Aplicaciones → BayStream, la
versión es la **1.0.2**. La sesión de muelle sigue iniciada, con «Cuenta autorizada».

**La prueba corta, contra Firebase de verdad, con el caso del piloto 4.** Es el caso A09, ya
anonimizado: BUQUE HOTEL · VIAJE009A · GTSTC, con 271 celdas «NO». Es una operación de prueba,
que el paso 11 cierra. Los archivos están en el escritorio, en la carpeta
`BayStream_1.0.2_prueba_corta`, copiados del corpus, con un `LEEME.txt`:

| Archivo | Qué es | SHA-256 |
|---|---|---|
| `CORPUS_A09.edi` | El plan de carga, como vino: 709 posiciones, 271 con «NO» | `450219FE01C62E0C33E946C9D73C17F5765917376C74CCCE3636200E76E0F07E` |
| `LISTADO_A09.xlsx` | El listado de la agencia: 448 filas, con POT y POD | `DF40CD6FA1D58794016ACBC2B9CFE8C0B7127012124E434C57CC18BA369DAAD0` |

La laptop va con la MSIX 1.0.2.0 y la sesión de oficina; el iPhone, con la Web 1.0.2; el Honor,
con la 1.0.2 de Play. **Los tres ya en la 1.0.2 antes del paso 2:** es un plan con «NO».

| Paso | Dónde | Qué hacer | Lo que se tiene que ver |
|---|---|---|---|
| 1 | Laptop | «Seleccionar archivo» → `CORPUS_A09.edi`. En previo: «Confirmar» → «Parámetros del buque», con GTSTC en «Puerto de esta escala» y, si lo pide, «No lo tengo» → «Confirmar y ver el plano». Después, «Lista» | En previo, «Plano sin confirmar: perfil propuesto desde el archivo. Escala propuesta GTSTC.». En «Lista», la franja «Celdas sin matrícula en EQD: «NO» en 271 celdas · se leyeron como celdas reservadas» y, en la tarjeta, **«438 contenedores · 271 celdas reservadas»** y «Se cargan 137 contenedores y 271 reservas (408 movimientos)» |
| 2 | Laptop | «Nube y cuenta» → «Publicar operación» | «Operación publicada.»; la cabecera, «Publicada» |
| 3 | Laptop | «Más» → «Listado de la agencia» → «Elegir listado (.xlsx)» → `LISTADO_A09.xlsx` | «448 filas en 5 agencias · 172 llenos · 276 vacíos»; «202 filas traen POT y POD distintos: el cruce con el plan usa el POT, donde el contenedor baja del buque.»; «Todas las filas se entendieron.»; **ningún puerto pendiente** |
| 4 | Laptop | Los nueve tipos, uno por uno: 20ST → 22G1, 20TK → 22K2, 40HC → 45G1, 45HC → L5G1, 20OT → 22U1, 40FF → 42P3, 40HF → 45P3, 40OT → 42U1, 40RF → 42R1. Después, «Confirmar e importar» | Antes de confirmar: «135 de 172 llenos cruzan con el plan», «0 contenedores del plan no están en el listado» y **«276 de 276 vacíos en 23 grupos de reservas»**. Al confirmar: «Listado guardado en la operación publicada de GTSTC: 448 filas, revisión 1. El muelle lo recibe solo.» |
| 5 | iPhone | «Nube y cuenta» → «Operaciones abiertas en la nube» → la de BUQUE HOTEL → «Unirse» → abrir su plano → «Lista» | «Te uniste a la operación. Abre su plano para trabajar.»; la misma franja de «NO» en 271 celdas y **«438 contenedores · 271 celdas reservadas»**. Si dice 709 contenedores, el iPhone sigue en la 1.0.1: recargar |
| 6 | iPhone | «Carga» → bahía 18 → tocar una celda reservada de arriba (fila 10, nivel 88) | **La hoja «Vacíos del listado» sale al tocar, sin esperar.** En la 1.0.1 tardaba unos 6 segundos. La primera fila, «OR 250 · XYRU4882688», «L5G1 · COTRB · LNH». **Anotar cuánto tarda, a ojo** |
| 7 | iPhone | Tocar «OR o últimos dígitos», para que suba el teclado, y escribir `250` | La lista se queda con el OR 250. **Anotar si al subir el teclado la pantalla se queda pegada, y cuánto:** es lo que queda de O-147-1, y es la primera vez que se mira en un teléfono |
| 8 | iPhone | Elegir «OR 250 · XYRU4882688» → «Confirmar carga» | En «Asignar vacío», «Revisado: tipo, celda y grupo coinciden con el plan.». Después, «Carga registrada · OR 250» y, debajo del plano (hay que deslizar), «Carga: 407 pendientes, 135 llenos, 272 vacíos» |
| 9 | Honor | «Nube y cuenta» → «Operaciones abiertas en la nube» → «Unirse» → abrir su plano → «Carga» → bahía 18 → tocar la celda «OR 446» (fila 02, nivel 82) → «Confirmar carga» | En el diálogo, **«POT JMKIN · POD BSNAS»** y «Posición planificada: 018-02-82». Después, «Carga registrada · OR 446» y «Carga: 406 pendientes, 134 llenos, 272 vacíos». La carga del iPhone ya está en el plano |
| 10 | Honor | Tocar otra celda reservada de la bahía 18 y cerrar la hoja sin elegir nada | La hoja sale al tocar, igual que en el iPhone. Dentro del grupo, el orden puede no ir por OR: es O-147-3, conocida |
| 11 | Laptop | «Avance», y después «Nube y cuenta» → «Cerrar operación» → en «Cerrar la operación», «Cerrar operación» | «Avance» cuenta las dos cargas. «Operación cerrada.»; la cabecera, «Cerrada». En el iPhone y en el Honor, sin tocar nada: «La oficina cerró la operación de GTSTC. Lo que registres desde ahora se rechazará.» |

**Si falla:**
- paso 2, «Ya hay una operación publicada y abierta de …»: queda abierta una de BUQUE HOTEL
  (0.5);
- paso 3 o 4, si algún tipo ya sale como «Guardada en este dispositivo»: es lo que se eligió en
  el piloto (10.85). Se comprueba que diga lo mismo que la lista y, si no, se cambia;
- paso 4, si el cruce no dice 276 de 276: revisar los nueve tipos contra la lista, uno por uno;
- pasos 5 y 9, si la operación no aparece en un minuto: «Nube y cuenta» → «Reintentar», y se
  anota cuánto tardó (O-134-5);
- **paso 6, si la hoja tarda más de dos segundos en salir: es lo que esta versión tenía que
  arreglar.** Anotar cuánto, en qué teléfono y qué dice `version.json`, y avisar antes de seguir;
- cualquier otro: anotar el paso y el texto exacto, y avisar. Los otros clientes no se tocan.

Lo que esta prueba no repite, porque ya lo hizo la aceptación con sondas: el BAPLIE de salida
del caso (sin `EQD+CN+NO` y sin `LOC+13`), el vacío en una celda de otro grupo con su motivo, y
la matrícula repetida.

---

## 7. El asistente, en «BayStream Prueba»

Es la condición del asistente, no de toda la versión (10.138, decisión 5). El guion es el de la
1.0.1, que ya pasó su recorrido completo el 17-nov (10.145): ahora basta con actualizar y abrir.
En la cuenta estándar «BayStream Prueba», sin la MSIX:

1. Configuración → Aplicaciones dice «BayStream · 1.0.1.10».
2. Abrir `C:\Users\Public\BayStream-1.0.2\BayStream_Setup_1.0.2.11.exe` e instalarlo
   **encima**. «Qué se instala» dice 1.0.2.11. Si Windows pregunta si instalar en una carpeta que
   ya existe, sí.
3. Aplicaciones dice «BayStream · 1.0.2.11».
4. Abrir BayStream desde Inicio: abre, sin sesión.

Si pasa, el asistente se puede repartir con su `.sha256` y su manifiesto. Si no, se anota qué
salió y el asistente no se reparte; Android, la Web y la MSIX no dependen de él.

---

## 8. Al terminar

### 8.1 Lo que hace Yov

Carlos le dice a Yov que está publicada y cuenta lo que no salió como dice la lista, con lo que
anotó en los pasos 6, 7 y 10 de la prueba corta. Yov:
1. lee el registro y coteja la Web en vivo con sus tres huellas;
2. anota la publicación en la decisión siguiente de `SPRINT-4.md`: el AAB, las huellas de la
   MSIX, del asistente y de la Web, las horas y la prueba corta;
3. pone 17.6 en `DESIGN.md` (9.3 de `docs/T147-RESULTADOS.md`) y el manual al día, en sus siete
   secciones: 3.2, 5.2, 7.8, 7.9, 8.2, 10 y el glosario;
4. pone el tablero al día.

Lo que se queda en el disco: `C:\Proyectos\baystream-publicaciones\` (`build-hasta-1.0.0` y
`build-1.0.1`, con las MSIX de la vuelta atrás) y la copia de los datos de 4.3. No se borran.

### 8.2 `sprint-4` al día (desde `C:\Proyectos\baystream-rediseno`)

Con la 1.0.2 publicada, `master` se mezcla en `sprint-4`, para que el trabajo que sigue (T-120 y
la entrega 2 de T-147) parta de lo publicado. Desde la 1.0.1, `sprint-4` y la entrega 1 de T-147
no cambiaron ninguna ruta en común (Yov lo comparó el 20-nov, sobre `87fd712` y `57497db`), así
que la mezcla no tiene dónde chocar.

```powershell
& {
if (-not (Get-Command git -ErrorAction SilentlyContinue)) { throw 'Parar: no esta git en el PATH de esta terminal' }
Set-Location -LiteralPath C:\Proyectos\baystream-rediseno
if ((git branch --show-current) -ne 'sprint-4') { throw 'Parar: la carpeta no esta en sprint-4' }
git fetch origin
if ($LASTEXITCODE -ne 0) { throw 'Parar: git fetch fallo; revisar la red' }
git pull --ff-only origin sprint-4
if ($LASTEXITCODE -ne 0) { throw 'Parar: sprint-4 no se pudo poner al dia con GitHub; avisar' }
if ((git describe --tags --exact-match origin/master 2>$null) -ne 'v1.0.2') { throw 'Parar: en GitHub, master no esta en v1.0.2' }
git merge --no-ff --no-commit origin/master
if ($LASTEXITCODE -ne 0) { throw 'Parar: la mezcla no salio limpia; no resolver nada y avisar' }
git commit -m "Sprint 4: mezcla de master a sprint-4, con la 1.0.2"
if ($LASTEXITCODE -ne 0) { throw 'Parar: el commit de la mezcla no salio' }
git push origin sprint-4
if ($LASTEXITCODE -ne 0) { throw 'Parar: sprint-4 no subio; repetir solo git push origin sprint-4' }
git log --oneline -1
}
```

La última línea tiene que mostrar «Sprint 4: mezcla de master a sprint-4, con la 1.0.2». **La
suite no se corrió todavía con T-120 y T-147 juntos:** es el paso 0 del siguiente prompt de
programación, antes de tocar nada.

---

## 9. Volver a la 1.0.1

Cliente por cliente, solo en el que falle, y siempre desde `C:\Proyectos\proyecto-baystream`.
La 1.0.1 es `v1.0.1` (`37be8a5`).

**La regla entre versiones también vale al volver:** con un cliente en la 1.0.1 y otro en la
1.0.2, no puede quedar abierta ninguna operación de un plan que traiga «NO». La 1.0.1 abre sin
romperse lo que guardó la 1.0.2: el listado da los mismos grupos (aceptación de T-147, punto 16)
y los avisos nuevos se guardan aparte.

- **Android.** Play no deja bajar de versión, así que se sube el código de la 1.0.1 con un
  número mayor: con `git checkout v1.0.1`,

  ```powershell
  flutter build appbundle --release --build-name=1.0.1 --build-number=12 --dart-define-from-file=C:\Proyectos\baystream-privado\firebase-prod.json
  ```

  y ese AAB, a la prueba interna. Después, `git checkout master`. Desde ahí, la siguiente
  versión de Android lleva el `versionCode` 13 o más.
- **Windows, la MSIX.** La 1.0.1.0 es menor que la 1.0.2.0. El bloque copia primero las dos
  carpetas de datos y después instala la 1.0.1.0 encima, sin desinstalar, con
  `-ForceUpdateFromAnyVersion`. **Ese camino no está probado en este proyecto:** el parámetro
  existe en la documentación de Microsoft de `Add-AppxPackage`, que no dice qué pasa con los
  datos, y por eso la copia va antes.

  ```powershell
  & {
  $registro = 'C:\Proyectos\baystream-rediseno\build\t147\publicacion\registro.txt'
  New-Item -ItemType Directory -Force -Path (Split-Path -Parent $registro) | Out-Null
  function Anotar([string]$texto) { $linea = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')  $texto"; Add-Content -LiteralPath $registro -Value $linea -Encoding UTF8; $linea }
  if (-not (Get-Command robocopy -ErrorAction SilentlyContinue)) { throw 'Parar: no esta robocopy en el PATH de esta terminal' }
  if (Get-Process -Name baystream -ErrorAction SilentlyContinue) { throw 'Parar: cierra BayStream antes de seguir' }
  $msix = 'C:\Proyectos\baystream-publicaciones\build-1.0.1\t93\BayStream_1.0.1.0.msix'
  if (-not (Test-Path -LiteralPath $msix)) { throw "Parar: falta $msix" }
  if ((Get-FileHash -LiteralPath $msix -Algorithm SHA256).Hash -ne 'CBB75D003742F025DEE662CF7C1605AD474818B09C6AABDD63D2A2C541222DCE') { throw 'Parar: la MSIX 1.0.1.0 no tiene la huella anotada' }
  if (-not (Get-Command Add-AppxPackage).Parameters.ContainsKey('ForceUpdateFromAnyVersion')) { throw 'Parar: este Windows no tiene -ForceUpdateFromAnyVersion; no se cambio nada. Avisar' }
  $app = @(Get-AppxPackage | Where-Object Name -like '*baystream*')
  if ($app.Count -ne 1) { throw "Parar: hay $($app.Count) paquetes de BayStream instalados y tiene que haber 1" }
  $instalada = [version]$app[0].Version
  $respaldo = "C:\Proyectos\respaldo-almacen-$(Get-Date -Format yyyyMMdd-HHmm)"
  $copiadas = 0
  $fuera = Join-Path $env:LOCALAPPDATA 'BayStream'
  if (Test-Path -LiteralPath $fuera) {
    robocopy $fuera "$respaldo\fuera\BayStream" /E /R:1 /W:1 /NFL /NDL /NJH
    if ($LASTEXITCODE -ge 8) { throw 'Parar: la copia del almacen de fuera fallo; no se cambio nada' }
    $copiadas++
  }
  $dentro = Join-Path $env:LOCALAPPDATA "Packages\$($app[0].PackageFamilyName)\LocalCache\Local\BayStream"
  if (Test-Path -LiteralPath $dentro) {
    robocopy $dentro "$respaldo\paquete\BayStream" /E /R:1 /W:1 /NFL /NDL /NJH
    if ($LASTEXITCODE -ge 8) { throw 'Parar: la copia del almacen del paquete fallo; no se cambio nada' }
    $copiadas++
  }
  if ($copiadas -eq 0) { throw 'Parar: no hay almacen de BayStream ni fuera ni dentro del paquete; avisar' }
  Anotar "9 Vuelta de la MSIX: copia de los datos en $respaldo ($copiadas carpetas). Se instala la 1.0.1.0 encima de la $instalada"
  try { Add-AppxPackage -Path $msix -ForceUpdateFromAnyVersion -ErrorAction Stop } catch { throw "Parar: no se instalo la 1.0.1.0 ($_); la $instalada sigue instalada. No desinstalar: avisar" }
  $ahora = @(Get-AppxPackage | Where-Object Name -like '*baystream*')
  Anotar "9 Vuelta de la MSIX, instalada: $($ahora[0].Name) $($ahora[0].Version)"
  }
  ```

  Si ese bloque no instala, **no se desinstala la MSIX por cuenta propia:** desinstalar borra
  los datos que viven dentro del paquete (10.144). Se hace con Yov, con la copia a la vista.
  Para volver después a la 1.0.2.0, se instala encima, como en 4.3.
- **Windows, el asistente.** Desinstalar, que conserva los datos, e instalar el 1.0.1.10:
  `C:\Users\Public\BayStream-1.0.1\BayStream_Setup_1.0.1.10.exe`
  (`d9174a1d9b95fdb194aef99aff39c5e051b9dc68f0b61b16d261f3b507b808aa`).
- **La Web.** En la consola de Firebase, Hosting → el historial de versiones → **la del 17-nov,
  15:46**, que es la 1.0.1, y la opción de volver a esa versión (*Rollback*). Hay además una
  copia de esa Web en `C:\Proyectos\baystream-publicaciones\build-1.0.1\web\`.
- `git checkout v1.0.1` deja la carpeta en la etiqueta, sin rama («detached HEAD»): es lo
  esperado. No se hace ningún commit ahí.

---

## Lo que esta lista no cubre

- **Pasar la laptop de la MSIX al asistente.** Sigue como un paso aparte, con su propia copia y
  su propia prueba (10.144).
- **Producción en Play.** Android sigue en la prueba interna.
- **Otras PC con la MSIX.** Reciben `BayStream_1.0.2.0.msix` y su `.sha256`, y la instalan
  encima; quien no tiene el certificado importado usa el asistente.
- **El manual de la 1.0.2.** Lo pone al día Yov después de publicar (8.1).
