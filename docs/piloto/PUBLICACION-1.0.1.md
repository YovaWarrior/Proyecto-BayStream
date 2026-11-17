# Publicación de la 1.0.1 · Lista de comprobación (10.142)

La sigue Carlos, que es quien mezcla, compila y publica. La escribió Yov el 17-nov, con el
dictamen de la aceptación de T-146 (GLM 5.3 Flash, en Max: PASA) ya comprobado contra la
carpeta. Todo se hace desde **`C:\Proyectos\proyecto-baystream`**, en `master`, como la 0.4.2 y
la 1.0.0: publicar desde `baystream-rediseno` pondría en producción otra compilación con el
mismo número (10.115).

**Lo que se publica.** La candidata es `834af36` («Sprint 4: T-146, la candidata 1.0.1»), y la
aceptación se hizo sobre `268e731`. Desde ahí, `sprint-4` solo puede traer documentos: la
mezcla lo comprueba (1).

| Cliente | Versión | Sobre qué |
|---|---|---|
| Android (AAB, prueba interna de Play) | `1.0.1`, `versionCode` **10** | El último subido es el 9 (Carlos, 17-nov) |
| Windows, MSIX | **1.0.1.0** | Encima de la 1.0.0.0, sin desinstalar |
| Windows, asistente | **1.0.1.10** | Encima del 1.0.0.9, o en una PC nueva. Sale de la misma Release que la MSIX |
| Web (Hosting) | `1.0.1`, compilación **10** | `version.json` lo deja visible |

`pubspec.yaml` dice `version: 1.0.1+10` y `msix_version: 1.0.1.0`, y los comandos lo repiten.
`pubspec.lock` es el de la 1.0.0.

**El orden** (10.102 y 10.123): la mezcla (1), apartar `build` y limpiar (2), Android (3),
Windows (4), la Web (5), el Honor con la prueba corta (6) y el recorrido del asistente (7). Los
tres clientes salen el mismo día.

**Lo que cambia frente a la 1.0.0:**
- antes de compilar se aparta toda la carpeta `build\` y se compila en limpio (10.130 y 10.138);
- Windows sale dos veces, la MSIX y el asistente, de la misma Release (opción C de la 10.138);
- la copia de los datos de Windows cubre las dos carpetas, la de fuera y la del paquete (10.132
  y 10.140);
- las huellas de la Web se anotan antes de publicar (10.115);
- las reglas de Firestore no cambian: siguen las de T-130.

**Cómo se usan los bloques.** Cada bloque va dentro de `& { … }` y se pega entero. Se detiene
en la primera comprobación que falle, con una línea que empieza con «Parar:» (en la Web, «No
publicar:») y dice qué pasó. Si un bloque se detiene, no se sigue con el siguiente: esa línea
se le pasa a Yov. Mientras corren 2, 3, 4 y 5, ningún agente corre Flutter ni Dart en la laptop
(`AGENTS.md`, «Trabajo en paralelo», 3).

**El registro.** Los bloques anotan las huellas, los tamaños y las horas en
`C:\Proyectos\baystream-rediseno\build\t146\publicacion\registro.txt`, fuera de Git. Yov lo lee
al final desde el equipo: no hace falta copiarle nada, salvo lo que se detenga.

---

## 0. Antes de empezar

| # | Qué | Lo que se tiene que ver |
|---|---|---|
| 0.1 | El bloque de Git de la 10.142 ya corrió: el informe de GLM, `SPRINT-4.md` y esta lista | En `baystream-rediseno`, `git log --oneline -1` muestra «Sprint 4: decision 10.142, …» |
| 0.2 | Ningún agente trabaja: Timonel, GLM y Antigravity, cerrados o en espera | Nadie corre Flutter ni Dart |
| 0.3 | Play Console: el último `versionCode` subido sigue siendo el **9** | Si alguien subió el 10, parar: la versión pasa a `1.0.1+11` y vuelve a la aceptación |
| 0.4 | Las reglas publicadas siguen siendo las de T-130 (bloque 0.4). Si nadie las tocó en la consola desde el 4-nov, se puede saltar | «Lo publicado son las reglas de T-130» |
| 0.5 | Con la cuenta de oficina, «Operaciones abiertas en la nube»: mirar cuáles hay | Ninguna de BUQUE MANUAL: son de prueba y se cierran. Ninguna que venga de una BAPLIE 1.5 o que traiga matrículas con espacio (10.123). Con una operación real a medias, se publica cuando cierre |
| 0.6 | Dónde están hoy los datos de Windows (bloque 0.6; solo lee) | Cada carpeta `BayStream*`, con sus archivos y su último cambio. Es lo que quedó sin aclarar en la 10.132 |
| 0.7 | En la laptop, BayStream cerrada. El Honor, con batería y con red | |

**0.5, el porqué.** Una 1.0.0 y una 1.0.1 en la misma operación de una BAPLIE 1.5, o con
matrículas con espacio, verían papeles distintos (10.123). Además, con una operación abierta de
BUQUE MANUAL en GTSTC, la prueba corta de 6 no puede publicar la suya. Una operación se cierra
desde el equipo que la tiene, o con «Unirse» desde la laptop y después «Cerrar operación». Una
operación cerrada no se reabre: si una no se reconoce, no se cierra, y se le avisa a Yov.

### 0.4 · El cotejo de las reglas (desde `C:\Proyectos\baystream-rediseno`)

1. En Chrome, `https://console.firebase.google.com` → **baystream-app** → **Firestore
   Database** → pestaña **Reglas**. En el editor, Ctrl + A y Ctrl + C. No se cambia nada.
2. Pegarlo en un archivo nuevo,
   `C:\Proyectos\baystream-rediseno\build\t146\publicacion\reglas-publicadas.txt` (VS Code,
   «Guardar como», UTF-8). La carpeta ya existe.
3. El bloque:

```powershell
& {
Set-Location -LiteralPath C:\Proyectos\baystream-rediseno
if (-not (Test-Path -LiteralPath build\t146\publicacion\reglas-publicadas.txt)) { throw 'Parar: falta build\t146\publicacion\reglas-publicadas.txt; guardar primero la copia de la consola' }
node tool/t113_reglas.mjs build/t146/publicacion/reglas-publicadas.txt build/t146/publicacion/cotejo-reglas docs/T130-firestore.rules.propuesta | Out-Null
if ($LASTEXITCODE -ne 0) { throw 'Parar: lo publicado no son las reglas de T-130; no publicar nada y avisar' }
'Lo publicado son las reglas de T-130 (8B903949...): se puede seguir'
}
```

El detalle queda en `build\t146\publicacion\cotejo-reglas\reglas-cotejo.json`, con la huella
normalizada `8B9039496CCCDA9FBC1412CC1F8610B3183D58FB4BA779EFB0C0C7D920EEFF71`.

### 0.6 · Dónde están los datos de Windows (solo lee)

```powershell
& {
$registro = 'C:\Proyectos\baystream-rediseno\build\t146\publicacion\registro.txt'
New-Item -ItemType Directory -Force -Path (Split-Path -Parent $registro) | Out-Null
function Anotar([string]$texto) { $linea = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')  $texto"; Add-Content -LiteralPath $registro -Value $linea -Encoding UTF8; $linea }
$carpetas = @(Get-ChildItem -LiteralPath $env:LOCALAPPDATA -Directory -Filter 'BayStream*' -ErrorAction SilentlyContinue)
foreach ($p in @(Get-ChildItem -LiteralPath (Join-Path $env:LOCALAPPDATA 'Packages') -Directory -Filter 'gt.cmartinez.baystream_*' -ErrorAction SilentlyContinue)) {
  $carpetas += @(Get-ChildItem -LiteralPath (Join-Path $p.FullName 'LocalCache\Local') -Directory -Filter 'BayStream*' -ErrorAction SilentlyContinue)
}
Anotar "0.6 Datos de Windows: $($carpetas.Count) carpetas BayStream*, contando fuera y dentro del paquete"
foreach ($c in $carpetas) {
  $archivos = @(Get-ChildItem -LiteralPath $c.FullName -Recurse -File -Force -ErrorAction SilentlyContinue)
  $bytes = [long](($archivos | Measure-Object -Property Length -Sum).Sum)
  $ultimo = 'sin archivos'
  if ($archivos.Count -gt 0) { $ultimo = ($archivos | Sort-Object LastWriteTime | Select-Object -Last 1).LastWriteTime.ToString('yyyy-MM-dd HH:mm') }
  Anotar "0.6   $($c.FullName) -> $($archivos.Count) archivos, $bytes bytes, ultimo cambio $ultimo"
}
}
```

No cambia nada. Lo que se espera, por la 10.135 y la 10.140:
- `%LOCALAPPDATA%\BayStream`, con dos archivos vacíos de la sesión: los dejó el banco de GLM el
  15-nov;
- `%LOCALAPPDATA%\BayStream_respaldo_<número>`: los datos de antes del 6-nov, si
  `BayStream_almacen_limpio.bat` se corrió para la presentación;
- dentro del paquete, `…\Packages\gt.cmartinez.baystream_…\LocalCache\Local\BayStream`: los datos
  del 7-nov en adelante. **Es la carpeta que se borra si se desinstala la MSIX.**

Si sale otra cosa, no detiene la publicación: 4.3 copia las dos carpetas vivas antes de
instalar, y la MSIX se instala encima, sin desinstalar.

---

## 1. La mezcla (desde `C:\Proyectos\proyecto-baystream`)

`master` está en `8f2505e` (T-142, 10.116), con la etiqueta `v1.0.0` un commit antes.
`C:\Proyectos\baystream-rediseno` es otro árbol de trabajo del mismo repositorio, así que
`sprint-4` es la misma rama local. Yov simuló la mezcla el 17-nov: entra sin conflictos, con 164
archivos, y el árbol que queda es el de `sprint-4`. `firebase.json` es igual en los dos lados.
Los cinco documentos de Carlos modificados en esa carpeta no cambian con la mezcla, y ninguno de
sus archivos sin seguimiento choca con los que entran. **Si Git marca un conflicto, o dice que
la mezcla sobrescribiría cambios locales, parar y avisar antes de resolver nada.**

```powershell
& {
$registro = 'C:\Proyectos\baystream-rediseno\build\t146\publicacion\registro.txt'
New-Item -ItemType Directory -Force -Path (Split-Path -Parent $registro) | Out-Null
function Anotar([string]$texto) { $linea = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')  $texto"; Add-Content -LiteralPath $registro -Value $linea -Encoding UTF8; $linea }
Set-Location -LiteralPath C:\Proyectos\proyecto-baystream
if ((git branch --show-current) -ne 'master') { throw 'Parar: la carpeta no esta en master' }
if ((git rev-parse HEAD) -notlike '8f2505e*') { throw 'Parar: master no esta en 8f2505e' }
git fetch origin
if ($LASTEXITCODE -ne 0) { throw 'Parar: git fetch fallo; revisar la red' }
if ((git rev-parse sprint-4) -ne (git rev-parse origin/sprint-4)) { throw 'Parar: sprint-4 local no es igual a origin/sprint-4; falta el bloque de Git de la 10.142' }
if (-not (git show sprint-4:pubspec.yaml | Select-String -Pattern '^version: 1\.0\.1\+10' -Quiet)) { throw 'Parar: sprint-4 todavia no trae la 1.0.1' }
git diff --quiet '268e731' sprint-4 -- lib test integration_test tool android windows web assets pubspec.yaml pubspec.lock firebase.json
if ($LASTEXITCODE -ne 0) { throw 'Parar: sprint-4 trae codigo que GLM no acepto (10.142); avisar' }
git merge --no-ff --no-commit sprint-4
if ($LASTEXITCODE -ne 0) { throw 'Parar: la mezcla no salio limpia; no resolver nada y avisar' }
git commit -m "Sprint 4: la 1.0.1, mezcla de sprint-4 a master"
if ($LASTEXITCODE -ne 0) { throw 'Parar: el commit de la mezcla no salio' }
git tag -a v1.0.1 -m "BayStream 1.0.1, los estados de la operacion, el lector y el volcado, y el instalador con asistente (Sprint 4)"
if ($LASTEXITCODE -ne 0) { throw 'Parar: la etiqueta v1.0.1 no salio; avisar antes de subir nada' }
git push origin master
if ($LASTEXITCODE -ne 0) { throw 'Parar: master no subio; revisar la red y repetir solo los dos git push' }
git push origin v1.0.1
if ($LASTEXITCODE -ne 0) { throw 'Parar: la etiqueta no subio; repetir solo git push origin v1.0.1' }
Anotar "1 Mezcla: master en $(git rev-parse --short HEAD), con la etiqueta v1.0.1"
git log --oneline -1
}
```

Las comprobaciones del principio detienen el bloque si la carpeta no está en `master`, si
`master` no está en `8f2505e`, si `sprint-4` no es el de GitHub, si todavía no trae la 1.0.1 o
si trae código que GLM no aceptó: desde `268e731` solo pueden cambiar documentos. La mezcla se
detiene antes del commit («stopped before committing as requested»): es lo esperado, y el
`git commit` la cierra. La última línea tiene que mostrar «Sprint 4: la 1.0.1, mezcla de
sprint-4 a master». Con la mezcla entran también T-137 y T-145: `windows/installer/` y sus
herramientas. `v1.0.0` sigue en Git para volver (9).

---

## 2. Apartar `build` y limpiar (desde esa carpeta, ya en `v1.0.1`)

`flutter clean` borra toda la carpeta `build\`, y en `proyecto-baystream` ahí viven cosas que
no se pueden perder: las MSIX de la vuelta atrás, 56 carpetas de evidencia de los Sprints 2 y 3,
la Web 1.0.0 publicada y el `.zip` del SDK de C++ de Firebase. Por eso la carpeta entera se
renombra a `C:\Proyectos\baystream-publicaciones\build-hasta-1.0.0`, que es instantáneo y no
pierde nada, y después se limpia. La compilación limpia es la que quita los dos archivos viejos
de la Release (10.130). Ningún editor ni otra terminal tiene abierta esa carpeta.

```powershell
& {
$registro = 'C:\Proyectos\baystream-rediseno\build\t146\publicacion\registro.txt'
New-Item -ItemType Directory -Force -Path (Split-Path -Parent $registro) | Out-Null
function Anotar([string]$texto) { $linea = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')  $texto"; Add-Content -LiteralPath $registro -Value $linea -Encoding UTF8; $linea }
Set-Location -LiteralPath C:\Proyectos\proyecto-baystream
if (Get-Process -Name baystream -ErrorAction SilentlyContinue) { throw 'Parar: cierra BayStream antes de seguir' }
if ((git describe --tags --exact-match HEAD 2>$null) -ne 'v1.0.1') { throw 'Parar: la carpeta no esta en v1.0.1; primero la mezcla (1)' }
if ($env:FIREBASE_CPP_SDK_DIR) { throw 'Parar: la variable FIREBASE_CPP_SDK_DIR tiene valor y CMake usaria ese SDK; avisar' }
if ((Get-PSDrive -Name C).Free -lt 20000000000) { throw 'Parar: quedan menos de 20 GB libres en C:' }
$publicaciones = 'C:\Proyectos\baystream-publicaciones'
$apartado = Join-Path $publicaciones 'build-hasta-1.0.0'
if (Test-Path -LiteralPath $apartado) {
  if (Test-Path -LiteralPath build) { throw 'Parar: este bloque ya corrio: hay un build apartado y otro nuevo. No se repite; seguir con Android (3)' }
  "build ya estaba apartado en $apartado. Sigo con las comprobaciones"
} else {
  if (-not (Test-Path -LiteralPath build)) { throw 'Parar: no hay carpeta build que apartar; avisar' }
  New-Item -ItemType Directory -Force -Path $publicaciones | Out-Null
  try { [IO.Directory]::Move('C:\Proyectos\proyecto-baystream\build', $apartado) } catch { throw "Parar: no se pudo apartar build ($($_.Exception.Message)). No se movio nada: cerrar lo que la tenga abierta (el Explorador, un editor, otra terminal) y repetir" }
}
$t93 = Join-Path $apartado 't93'
$esperadas = @{
  'BayStream_1.0.0.0.msix' = 'BA01DED75EB1E0DA80B1B30D9CE9B8649167683994B583683398A889246E764B'
  'BayStream_0.4.2.0.msix' = 'D57F8E5032379AF87D9272ED2AA372AF093E6818C152BD0CDFB84FCA1C83C85F'
}
foreach ($nombre in $esperadas.Keys) {
  $ruta = Join-Path $t93 $nombre
  if (-not (Test-Path -LiteralPath $ruta)) { throw "Parar: falta $ruta, una MSIX de la vuelta atras" }
  if ((Get-FileHash -LiteralPath $ruta -Algorithm SHA256).Hash -ne $esperadas[$nombre]) { throw "Parar: $nombre no tiene la huella anotada; avisar" }
}
$vieja = Join-Path $t93 'BayStream_1.0.1.0.msix'
if (Test-Path -LiteralPath $vieja) {
  if ((Get-FileHash -LiteralPath $vieja -Algorithm SHA256).Hash -ne 'ABBCD33BD8ACFD2B80E785381207FCB1C340DA53963FFF94018BFD8703F7CA0B') { throw 'Parar: el BayStream_1.0.1.0.msix apartado no es el del 14-oct; avisar' }
  Rename-Item -LiteralPath $vieja -NewName 'BayStream_1.0.1.0-t93-14oct.msix'
  if (Test-Path -LiteralPath "$vieja.sha256") { Rename-Item -LiteralPath "$vieja.sha256" -NewName 'BayStream_1.0.1.0-t93-14oct.msix.sha256' }
}
$zip = Join-Path $apartado 'windows\x64\firebase_cpp_sdk_windows_13.13.1.zip'
$huellaZip = '061508DE65535EF11E47DD7D0F1DE5780AED58D19865B71504F70F66FD3F9954'
if (-not (Test-Path -LiteralPath $zip)) { throw "Parar: falta $zip; avisar" }
if ((Get-FileHash -LiteralPath $zip -Algorithm SHA256).Hash -ne $huellaZip) { throw 'Parar: el .zip del SDK de C++ no tiene la huella anotada; no se copia. Avisar' }
flutter clean
if ($LASTEXITCODE -ne 0) { throw 'Parar: flutter clean fallo' }
New-Item -ItemType Directory -Force -Path build\windows\x64 | Out-Null
Copy-Item -LiteralPath $zip -Destination build\windows\x64
if ((Get-FileHash -LiteralPath build\windows\x64\firebase_cpp_sdk_windows_13.13.1.zip -Algorithm SHA256).Hash -ne $huellaZip) { throw 'Parar: la copia del .zip no salio igual; borrarla y avisar' }
Anotar "2 build apartado en $apartado, con las MSIX 1.0.0.0 y 0.4.2.0 en sus huellas; flutter clean; el .zip del SDK 13.13.1, copiado"
}
```

Lo que deja:
- `C:\Proyectos\baystream-publicaciones\build-hasta-1.0.0\`: el `build\` de antes, entero. En
  su `t93\` están `BayStream_1.0.0.0.msix` (`BA01DED7…`) y `BayStream_0.4.2.0.msix`
  (`D57F8E50…`), para volver (9); el `BayStream_1.0.1.0.msix` del 14-oct, que era una prueba de
  T-93, queda como `BayStream_1.0.1.0-t93-14oct.msix`, para que nadie lo confunda con el nuevo;
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
$registro = 'C:\Proyectos\baystream-rediseno\build\t146\publicacion\registro.txt'
New-Item -ItemType Directory -Force -Path (Split-Path -Parent $registro) | Out-Null
function Anotar([string]$texto) { $linea = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')  $texto"; Add-Content -LiteralPath $registro -Value $linea -Encoding UTF8; $linea }
Set-Location -LiteralPath C:\Proyectos\proyecto-baystream
if ((git describe --tags --exact-match HEAD 2>$null) -ne 'v1.0.1') { throw 'Parar: la carpeta no esta en v1.0.1' }
if (-not (Test-Path -LiteralPath android\key.properties)) { throw 'Parar: falta android\key.properties; el AAB saldria con la firma de depuracion' }
flutter build appbundle --release --build-name=1.0.1 --build-number=10 --dart-define-from-file=C:\Proyectos\baystream-privado\firebase-prod.json
if ($LASTEXITCODE -ne 0) { throw 'Parar: el AAB no salio; no subir nada' }
$aab = 'C:\Proyectos\proyecto-baystream\build\app\outputs\bundle\release\app-release.aab'
if (-not (Test-Path -LiteralPath $aab)) { throw "Parar: no esta $aab" }
$bytes = (Get-Item -LiteralPath $aab).Length
$huella = (Get-FileHash -LiteralPath $aab -Algorithm SHA256).Hash
Anotar "3 AAB 1.0.1 (10): $bytes bytes, SHA-256 $huella"
}
```

Sin `--no-pub` (10.86). Firma con la clave de subida de `android\key.properties` (T-49), que
está en esa carpeta y fuera de Git; el bloque solo comprueba que el archivo existe. Después:

1. Play Console → BayStream → **Prueba interna** → crear una versión → subir
   `build\app\outputs\bundle\release\app-release.aab`. Play tiene que decir **10 (1.0.1)**.
   Producción queda fuera.
2. Las novedades de la versión:

   ```
   BayStream 1.0.1
   - La cabecera dice el estado de la operación: Confirmado, Publicada o Cerrada.
   - Cuando la oficina cierra la operación, el muelle recibe un aviso.
   - El detalle muestra todas las mercancías peligrosas, el destino final y las medidas del sobredimensionado.
   - Lee los puertos de una BAPLIE 1.5.
   - La búsqueda acepta el número con o sin espacios.
   ```
3. Guardar, revisar e iniciar el lanzamiento en la prueba interna. Play volverá a avisar que
   deja fuera los equipos sin micrófono: el Honor lo tiene.
4. Seguir con Windows. El Honor se actualiza en 6. **Al Honor nunca se le manda una compilación
   local:** ni `flutter run`, ni `flutter install`, ni `adb install` (10.96).

---

## 4. Windows

Una sola compilación Release, y de ella salen los dos paquetes: la MSIX 1.0.1.0 (4.1) y el
asistente 1.0.1.10 (4.2). La laptop de Carlos tiene la MSIX 1.0.0.0 y se actualiza con la MSIX
(4.3): nadie cambia de la MSIX al asistente en esta publicación.

### 4.1 La Release y la MSIX

```powershell
& {
$registro = 'C:\Proyectos\baystream-rediseno\build\t146\publicacion\registro.txt'
New-Item -ItemType Directory -Force -Path (Split-Path -Parent $registro) | Out-Null
function Anotar([string]$texto) { $linea = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')  $texto"; Add-Content -LiteralPath $registro -Value $linea -Encoding UTF8; $linea }
Set-Location -LiteralPath C:\Proyectos\proyecto-baystream
if ((git describe --tags --exact-match HEAD 2>$null) -ne 'v1.0.1') { throw 'Parar: la carpeta no esta en v1.0.1' }
if ($env:FIREBASE_CPP_SDK_DIR) { throw 'Parar: la variable FIREBASE_CPP_SDK_DIR tiene valor y CMake usaria ese SDK; avisar' }
$h = @(Get-ChildItem Cert:\CurrentUser\My | Where-Object Subject -eq 'CN=BayStream')
if ($h.Count -ne 1) { throw "Parar: hay $($h.Count) certificados CN=BayStream y tiene que haber 1" }
powershell -NoProfile -ExecutionPolicy Bypass -File tool\t93_msix.ps1 -Huella $h[0].Thumbprint -Version 1.0.1.0
if ($LASTEXITCODE -ne 0) { throw 'Parar: el MSIX no salio o no paso la verificacion; no se instalo nada' }
$exe = 'C:\Proyectos\proyecto-baystream\build\windows\x64\runner\Release\baystream.exe'
$v = [Diagnostics.FileVersionInfo]::GetVersionInfo($exe)
$numero = '{0}.{1}.{2}.{3}' -f $v.FileMajorPart, $v.FileMinorPart, $v.FileBuildPart, $v.FilePrivatePart
if ($numero -ne '1.0.1.10' -or $v.ProductVersion -ne '1.0.1+10') { throw "Parar: el .exe dice $numero y $($v.ProductVersion), y tiene que decir 1.0.1.10 y 1.0.1+10" }
$texto = [Text.Encoding]::GetEncoding(28591).GetString([IO.File]::ReadAllBytes($exe))
$sdk = @([regex]::Matches($texto, 'Firebase C\+\+ (\d+\.\d+\.\d+)') | ForEach-Object { $_.Groups[1].Value } | Sort-Object -Unique)
if ($sdk.Count -ne 1 -or $sdk[0] -ne '13.13.1') { throw "Parar: el .exe enlaza Firebase C++ '$($sdk -join ', ')' y tiene que ser solo el 13.13.1 (10.99)" }
$msix = 'C:\Proyectos\proyecto-baystream\build\t93\BayStream_1.0.1.0.msix'
$bytes = (Get-Item -LiteralPath $msix).Length
$huella = (Get-FileHash -LiteralPath $msix -Algorithm SHA256).Hash
Anotar "4.1 Release 1.0.1.10 (1.0.1+10) con Firebase C++ 13.13.1. MSIX 1.0.1.0: $bytes bytes, SHA-256 $huella"
}
```

El script de T-93 corre `flutter pub get`, comprueba el SDK de C++ («no hay extracted. La
compilacion extrae el 13.13.1.»), compila Release con la configuración privada (`-Opciones`
apunta a `C:\Proyectos\baystream-privado\firebase-prod.json` por omisión, sin abrirla) y
termina verificando la firma `Valid`, la huella del certificado (`60BEF8F4…`) y el `.sha256`.
**`-Version` va siempre:** el valor por omisión del script sigue siendo `1.0.0.0` (O-146-2).
Después, el bloque mira dentro del `.exe`: la versión `1.0.1.10` y `1.0.1+10`, y una sola
`Firebase C++ 13.13.1` (O-137-2). El aviso LNK4078 del enlazador es el de la 1.0.0 (10.105) y
no detiene nada. Queda `build\t93\BayStream_1.0.1.0.msix` con su `.sha256`: es lo que recibe
quien ya tiene la MSIX.

### 4.2 El asistente 1.0.1.10, de la misma Release

Sin compilar otra vez. Es el primer armado de producción desde `proyecto-baystream` con el
armador ya en `master`: si se detiene, dice por qué, y la MSIX no depende de él.

```powershell
& {
$registro = 'C:\Proyectos\baystream-rediseno\build\t146\publicacion\registro.txt'
New-Item -ItemType Directory -Force -Path (Split-Path -Parent $registro) | Out-Null
function Anotar([string]$texto) { $linea = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')  $texto"; Add-Content -LiteralPath $registro -Value $linea -Encoding UTF8; $linea }
Set-Location -LiteralPath C:\Proyectos\proyecto-baystream
if ((git describe --tags --exact-match HEAD 2>$null) -ne 'v1.0.1') { throw 'Parar: la carpeta no esta en v1.0.1' }
dart run tool/t137_instalador.dart --origen C:\Proyectos\proyecto-baystream --variante produccion --salida build/t137/v1.0.1
if ($LASTEXITCODE -ne 0) { throw 'Parar: el asistente no se armo. La MSIX no depende de el: avisar con el mensaje y seguir con 4.3' }
$base = 'C:\Proyectos\proyecto-baystream\build\t137\v1.0.1\BayStream_Setup_1.0.1.10'
$partes = '.exe', '.exe.sha256', '.manifiesto.json', '.inno-manifiesto.txt'
foreach ($parte in $partes) { if (-not (Test-Path -LiteralPath ($base + $parte))) { throw "Parar: falta ${base}${parte}" } }
$m = Get-Content -LiteralPath ($base + '.manifiesto.json') -Raw -Encoding UTF8 | ConvertFrom-Json
if ($m.variante -ne 'produccion' -or $m.publicable -ne $true) { throw 'Parar: el manifiesto no es de produccion' }
if ($m.version -ne '1.0.1.10') { throw "Parar: el manifiesto dice la version $($m.version)" }
if ($m.metadatos.firebaseCppExe -ne '13.13.1') { throw "Parar: el manifiesto dice Firebase C++ $($m.metadatos.firebaseCppExe) dentro del .exe" }
$excluidos = @($m.excluidos).Count
if ($excluidos -ne 5) { throw "Parar: hay $excluidos excluidos y tienen que ser 5" }
$avisos = @($m.avisos)
if ($avisos.Count -ne 0) { throw "Parar: el armado dejo avisos y no se reparte: $($avisos -join ' / ')" }
$huella = (Get-FileHash -LiteralPath ($base + '.exe') -Algorithm SHA256).Hash
if ($huella -ne ([string]$m.instalador.sha256).ToUpperInvariant()) { throw 'Parar: el instalador no coincide con su manifiesto' }
$destino = 'C:\Users\Public\BayStream-1.0.1'
New-Item -ItemType Directory -Force -Path $destino | Out-Null
foreach ($parte in $partes) { Copy-Item -LiteralPath ($base + $parte) -Destination $destino -Force }
if ((Get-FileHash -LiteralPath (Join-Path $destino 'BayStream_Setup_1.0.1.10.exe') -Algorithm SHA256).Hash -ne $huella) { throw 'Parar: la copia en Public no salio igual' }
$bytes = (Get-Item -LiteralPath ($base + '.exe')).Length
$carga = @($m.archivos).Count
Anotar "4.2 Asistente 1.0.1.10: $bytes bytes, SHA-256 $huella. Carga de $carga archivos (se esperan 25), 5 excluidos, sin avisos. Copiado a $destino"
}
```

Lo que tiene que decir el armador:
- «T-137: Release 1.0.1.10 · produccion · 27 archivos de origen, 5 fuera de la carga.»;
- «Origen verificado sin cambios. 25 archivos en la carga; 5 módulos PE.»;
- ninguna línea de avisos. El aviso de los dos archivos viejos (`NOTICES` y
  `AssetManifest.bin.json`, del 15-oct) era la marca de la Release de la 1.0.0: si vuelve a
  salir, la compilación no fue limpia, y el bloque se detiene.

La carga de **25** la calculó Yov y no está medida: la Release de la 1.0.0 trae 29 archivos, y
sin los dos viejos quedan 27; menos los 5 excluidos, más las tres DLL de Visual C++. El «27» de
1.5 de `docs/T146-RESULTADOS.md` es la carga de la 1.0.0, con sus dos archivos viejos. Si no
son 25, no detiene: queda en el registro y Yov lo mira antes de que el asistente se reparta.

El asistente queda en `C:\Users\Public\BayStream-1.0.1\`, con su `.sha256` y sus dos
manifiestos. **No se reparte hasta que pase el recorrido de 7** (10.138, decisión 5).

### 4.3 La copia de los datos y la MSIX en la laptop

Con BayStream cerrada. Verifica el paquete, copia las dos carpetas de datos y solo entonces
instala; si algo falla antes, no toca nada.

```powershell
& {
$registro = 'C:\Proyectos\baystream-rediseno\build\t146\publicacion\registro.txt'
New-Item -ItemType Directory -Force -Path (Split-Path -Parent $registro) | Out-Null
function Anotar([string]$texto) { $linea = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')  $texto"; Add-Content -LiteralPath $registro -Value $linea -Encoding UTF8; $linea }
Set-Location -LiteralPath C:\Proyectos\proyecto-baystream
if (Get-Process -Name baystream -ErrorAction SilentlyContinue) { throw 'Parar: cierra BayStream antes de seguir' }
$h = @(Get-ChildItem Cert:\CurrentUser\My | Where-Object Subject -eq 'CN=BayStream')
if ($h.Count -ne 1) { throw "Parar: hay $($h.Count) certificados CN=BayStream y tiene que haber 1" }
$msix = 'C:\Proyectos\proyecto-baystream\build\t93\BayStream_1.0.1.0.msix'
powershell -NoProfile -ExecutionPolicy Bypass -File tool\t93_msix.ps1 -Huella $h[0].Thumbprint -Verificar $msix
if ($LASTEXITCODE -ne 0) { throw 'Parar: la MSIX 1.0.1.0 no pasa la verificacion; no se instalo nada' }
$app = @(Get-AppxPackage | Where-Object Name -like '*baystream*')
if ($app.Count -ne 1) { throw "Parar: hay $($app.Count) paquetes de BayStream instalados y tiene que haber 1" }
$instalada = [version]$app[0].Version
if ($instalada -ne [version]'1.0.0.0') { throw "Parar: la instalada es la $instalada y no la 1.0.0.0; avisar" }
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
Anotar "4.3 Copia de los datos en $respaldo ($copiadas carpetas). Se instala la 1.0.1.0 encima de la $instalada"
try { Add-AppxPackage -Path $msix -ErrorAction Stop } catch { throw "Parar: no se instalo la 1.0.1.0 ($_); la $instalada sigue instalada" }
$ahora = @(Get-AppxPackage | Where-Object Name -like '*baystream*')
Anotar "4.3 Instalada: $($ahora[0].Name) $($ahora[0].Version)"
}
```

La última línea tiene que mostrar la 1.0.1.0. La copia queda en
`C:\Proyectos\respaldo-almacen-<fecha>\`, con `fuera\` y `paquete\`. Actualizar una MSIX no
borra los datos del paquete; solo los borra desinstalarla. Si el bloque se detiene porque la
instalada no es la 1.0.0.0, la línea dice cuál es.

### 4.4 La sesión de oficina

Abrir BayStream desde Inicio:
- Configuración → Aplicaciones dice **BayStream 1.0.1.0**;
- la app abre con los datos de siempre: los mismos viajes en «Recientes en este dispositivo» y
  los mismos perfiles;
- «Nube y cuenta» dice el nombre, «Oficina» y **«Cuenta autorizada»**, sin volver a iniciar
  sesión.

Si pide iniciar sesión, se inicia y se anota: puede venir de los dos archivos vacíos que dejó
el banco de GLM en `%LOCALAPPDATA%\BayStream\vessel_store` (10.135), y no de la versión. Si
faltan viajes o perfiles, parar y avisar: la copia de 4.3 los tiene.

---

## 5. La Web, al final (Hosting)

### 5.1 Compilar, comprobar y publicar

```powershell
& {
$registro = 'C:\Proyectos\baystream-rediseno\build\t146\publicacion\registro.txt'
New-Item -ItemType Directory -Force -Path (Split-Path -Parent $registro) | Out-Null
function Anotar([string]$texto) { $linea = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')  $texto"; Add-Content -LiteralPath $registro -Value $linea -Encoding UTF8; $linea }
Set-Location -LiteralPath C:\Proyectos\proyecto-baystream
if ((git describe --tags --exact-match HEAD 2>$null) -ne 'v1.0.1') { throw 'No publicar: la carpeta no esta en v1.0.1' }
$destino = [IO.Path]::GetFullPath('C:\Proyectos\proyecto-baystream\build\web')
if ($destino -ne 'C:\Proyectos\proyecto-baystream\build\web') { throw 'No publicar: destino de Hosting inesperado' }
if (Test-Path -LiteralPath $destino) { Remove-Item -LiteralPath $destino -Recurse -Force }
flutter build web --release --output=build/web --build-name=1.0.1 --build-number=10 --dart-define-from-file=C:\Proyectos\baystream-privado\firebase-prod.json
if ($LASTEXITCODE -ne 0) { throw 'No publicar: build fallido' }
if (-not (Select-String -LiteralPath build\web\main.dart.js -Pattern 'flutter-fire-auth' -SimpleMatch -Quiet)) { throw 'No publicar: la Web salio sin Firebase Auth' }
$ver = Get-Content -LiteralPath build\web\version.json -Raw | ConvertFrom-Json
if ($ver.version -ne '1.0.1' -or [string]$ver.build_number -ne '10') { throw "No publicar: version.json dice $($ver.version) ($($ver.build_number))" }
$sdkWeb = @(Get-ChildItem -LiteralPath build\web\vendor\firebase -Directory | ForEach-Object { $_.Name })
if ($sdkWeb.Count -ne 1 -or $sdkWeb[0] -ne '12.19.0') { throw "No publicar: en vendor\firebase hay '$($sdkWeb -join ', ')' y tiene que estar solo la 12.19.0" }
dart run tool/t92_verify.dart build/web
if ($LASTEXITCODE -ne 0) { throw 'No publicar: verificacion fallida' }
foreach ($archivo in 'version.json', 'main.dart.js', 'flutter_bootstrap.js') {
  $huella = (Get-FileHash -LiteralPath (Join-Path $destino $archivo) -Algorithm SHA256).Hash
  Anotar "5.1 Web 1.0.1 (10), antes de publicar: $archivo $huella"
}
firebase deploy --only hosting --project baystream-app
if ($LASTEXITCODE -ne 0) { throw 'Parar: firebase deploy fallo; la Web publicada sigue siendo la de antes. Avisar' }
Anotar '5.1 Web publicada con firebase deploy --only hosting --project baystream-app'
}
```

**Nunca `firebase deploy` a secas.** El bloque comprueba `version.json`, que solo vaya el SDK
web 12.19.0 (T-92) y `t92_verify`, y anota las tres huellas antes de publicar (10.115). Las
cabeceras de seguridad van en `firebase.json`, que es el mismo de la 10.116. Si
`firebase deploy` dice que falta la sesión, `firebase login` y repetir el bloque: compila otra
vez, y valen las huellas de la última corrida.

### 5.2 En vivo

```powershell
& {
$registro = 'C:\Proyectos\baystream-rediseno\build\t146\publicacion\registro.txt'
New-Item -ItemType Directory -Force -Path (Split-Path -Parent $registro) | Out-Null
function Anotar([string]$texto) { $linea = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')  $texto"; Add-Content -LiteralPath $registro -Value $linea -Encoding UTF8; $linea }
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
if ($vivo.version -ne '1.0.1' -or [string]$vivo.build_number -ne '10') { throw "Parar: en vivo, version.json dice $($vivo.version) ($($vivo.build_number))" }
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

## 6. El Honor y la prueba corta

**El Honor.** Actualizar por el enlace de la prueba interna, o en Play Store → BayStream →
«Actualizar». Puede tardar unos minutos en ofrecerla. En Ajustes → Aplicaciones → BayStream, la
versión es la **1.0.1**. La sesión de muelle sigue iniciada, con «Cuenta autorizada».

**La prueba corta, de punta a punta, contra Firebase de verdad.** Es la del viaje S100 (10.105)
con un viaje propio, **S101**, y con lo nuevo de la 1.0.1. Los archivos están en el escritorio,
en la carpeta `BayStream_1.0.1_prueba_corta`. Yov los sacó de los sintéticos de T-100 cambiando
solo el viaje en `TDT`:

| Archivo | Qué es | SHA-256 |
|---|---|---|
| `S101_LLEGADA.edi` | El plano de llegada, viaje S101 | `8762E850AFED4FC95062427E17233B706B464F5DD8CB793907ABCBAB1315ABBE` |
| `S101N_CARGA.edi` | El plan de carga, viaje S101N | `48747ABE16CF46DA7A16D7D8A77A82F754B8402BE21D2A28AEF66DF2BBBB52B6` |
| `T100_LISTADO.xlsx` | El listado de la agencia, 30 filas | `FEB12A909B7B590F36A58A6B47CE26ACAC0027839DA9D8BA3C1C9AA1367AE073` |

Es una operación de prueba, BUQUE MANUAL · S101 · GTSTC, que el paso 10 cierra. La laptop va
con la MSIX 1.0.1.0 y la sesión de oficina; el Honor, con la 1.0.1 de Play y la sesión de
muelle.

| Paso | Dónde | Qué hacer | Lo que se tiene que ver |
|---|---|---|---|
| 1 | Laptop | «Seleccionar archivo» → `S101_LLEGADA.edi`. Si abre en previo: «Confirmar» → «Parámetros del buque», con GTSTC en «Puerto de esta escala» y, si lo pide, «No lo tengo» → «Confirmar y ver el plano» | La cabecera dice **«Confirmado»**: ya no dice «Publicado» antes de la nube (T-143) |
| 2 | Laptop | «Nube y cuenta» → «Publicar operación» | «Operación publicada.»; el estado, «Publicada», con «Al día»; la cabecera, **«Publicada»** |
| 3 | Honor | «Nube y cuenta» → «Operaciones abiertas en la nube» → «Unirse» → «Abrir plano de llegada» → «Descarga» → tocar dos celdas por bajar | «Te uniste a la operación. Abre su plano para trabajar.»; «Descargado · …» en cada una; en la laptop, «Avance» las cuenta |
| 4 | Laptop | «Más» → «Cargar archivo BAPLIE» → `S101N_CARGA.edi` → «Confirmar» → «Parámetros del buque» → «Confirmar y ver el plano» → «Agregar a la operación S101» | En previo, la banda «La escala GTSTC ya tiene una operación publicada (viaje S101) sin plan de carga: confirma para agregarlo.»; en el diálogo, «Se cargan 30 contenedores y 0 celdas reservadas; se descargan 0»; el aviso «Plan de carga agregado a la operación publicada de GTSTC: 30 contenedores y 0 reservas. El muelle lo recibe solo.» |
| 5 | Honor | Sin tocar nada, esperar el aviso. Después, «Carga» → «OR / últimos dígitos» → los últimos dígitos de un lleno → «Confirmar carga» | «Plan de carga agregado por la oficina: 30 contenedores y 0 reservas.»; «Carga registrada · …» |
| 6 | Laptop | «Más» → «Listado de la agencia» → «Elegir listado (.xlsx)» → `T100_LISTADO.xlsx` → «Confirmar e importar» | «30 filas en 2 agencias · 20 llenos · 10 vacíos»; «Listado guardado en la operación publicada de GTSTC: 30 filas, revisión 1. El muelle lo recibe solo.»; en el Honor, «Listado actualizado por la oficina: 30 filas.» |
| 7 | Laptop y Honor | «Buscar contenedor» → `mnlu 000010 7`, con los espacios; después, `ushou` | Un resultado, con MNLU0000107 **entero resaltado** (O-144-1, de T-146). Con `ushou`, se resalta el puerto en «POD: USHOU», y la matrícula no |
| 8 | Honor | Con la letra del sistema al máximo que dé el teléfono, abrir el detalle de un contenedor; después, devolver la letra | La matrícula se lee entera; si no cabe junto a la naviera, la naviera baja de línea (T-144). Anotar el tamaño de letra |
| 9 | Laptop | La marca de arriba del riel, «Volver al inicio»; después, reabrir el viaje desde «Recientes en este dispositivo» | El subtítulo «Sigue en Recientes; no se borra nada.»; el plano reabre, y la cabecera sigue en «Publicada» |
| 10 | Laptop | «Nube y cuenta» → «Cerrar operación» → en «Cerrar la operación», «Cerrar operación» | «Operación cerrada.» al primer intento; el estado, **«Publicada y cerrada»**; la cabecera, **«Cerrada»** |
| 11 | Honor | Sin tocar nada, mirar el plano y «Nube y cuenta» | El aviso «La oficina cerró la operación de GTSTC. Lo que registres desde ahora se rechazará.»; «Publicada y cerrada»; el chip, «Al día · operación cerrada» |
| 12 | Honor | Registrar una descarga más | La descarga se rechaza, la celda vuelve a quedar por bajar y el chip dice «1 rechazado: la operación ya estaba cerrada» |
| 13 | Web | En incógnito, con la cuenta de oficina: «Operaciones abiertas en la nube» | La S101 ya no aparece |

Los pasos 11 y 12 son los que el manual de la 1.0.1 marca «(no recorrido en esta edición)» en
7.11: aquí se ven por primera vez en el teléfono de verdad.

**Si falla:**
- paso 1, la banda dice «La escala GTSTC ya tiene una operación publicada…»: queda abierta una
  de BUQUE MANUAL de antes (0.5);
- paso 2, «Ya hay una operación publicada y abierta de …»: la S101 ya existe. Avisar: Yov
  prepara otro viaje;
- paso 4, «La nube no aceptó el plan: …»: las reglas publicadas no son las de T-130 (0.4);
- pasos 5, 6 y 11, si el aviso no llega en un minuto: «Nube y cuenta» → «Reintentar», y se
  anota cuánto tardó (O-134-5);
- cualquier otro: anotar el paso y el texto exacto, y avisar. Los otros clientes no se tocan.

---

## 7. El recorrido del asistente, en «BayStream Prueba»

Es la condición del asistente, no de toda la versión (10.138, decisión 5): si encuentra algo,
Android, la Web y la MSIX ya salieron, y el asistente espera. Es el recorrido corto de T-145
(sección 13 de `docs/T145-RESULTADOS.md`), con el instalador de producción de la 1.0.1. Va en
la cuenta estándar «BayStream Prueba», sin la MSIX, con capturas, como en T-137.

1. Configuración → Aplicaciones: tiene que estar «BayStream 1.0.0.9». **Si no está,** instalar
   primero el de T-137, `C:\Users\Public\BayStream-T137\1.0.0.9\BayStream_Setup_1.0.0.9.exe`
   (`ef8f2bbb…`), para probar la actualización.
2. Abrir `C:\Users\Public\BayStream-1.0.1\BayStream_Setup_1.0.1.10.exe` e instalarlo
   **encima**. Las páginas son las de T-137, y «Qué se instala» dice 1.0.1.10. Si Windows
   pregunta si instalar en una carpeta que ya existe, sí.
3. Aplicaciones dice «BayStream · 1.0.1.10». En `%LOCALAPPDATA%\Programs\BayStream` no tienen
   que estar `baystream.lib`, `baystream.exp` ni los tres `*_plugin.lib`.
4. Abrir BayStream desde Inicio y **dejarla abierta**, sin iniciar sesión. Desinstalar desde
   Configuración → Aplicaciones:
   - tiene que salir **«BayStream está abierta»**, con «Reintentar» y «Cancelar». Anotar si
     sale antes o después de la confirmación;
   - «Reintentar» con BayStream abierta: vuelve a preguntar;
   - cerrar BayStream y «Reintentar»: sigue;
   - la confirmación dice «¿Seguro que quieres desinstalar BayStream? Tus datos en
     %LOCALAPPDATA%\BayStream se conservan.»;
   - al final, «BayStream se desinstaló correctamente», **no** «Windows no pudo quitar algunos
     archivos», y la carpeta de la aplicación ya no está.
5. Instalarlo otra vez, para que la cuenta quede en la 1.0.1.10. Si se quiere, abrir BayStream y
   desinstalar con «Cancelar»: no tiene que quitar nada.

Si pasa, el asistente se puede repartir con su `.sha256` y su manifiesto. Si no, se anota qué
salió, se corrige en `sprint-4` y el asistente no se reparte.

---

## 8. Al terminar

Carlos le dice a Yov que está publicada y cuenta lo que no salió como dice la lista. Yov:
1. lee el registro y coteja la Web en vivo con sus tres huellas;
2. anota la publicación en la decisión siguiente de `SPRINT-4.md`: el AAB, las huellas de la
   MSIX, del asistente y de la Web, las horas, la prueba corta y el recorrido;
3. pone en el manual de la 1.0.1 la fecha de publicación, la línea que falta en los pies de las
   figuras 41 y 42 (O-146-3) y las dos palabras de O-146-4;
4. pone el tablero al día.

Lo que se queda en el disco: `C:\Proyectos\baystream-publicaciones\build-hasta-1.0.0\` (las MSIX
de la vuelta atrás y la evidencia de los Sprints 2 y 3) y la copia de los datos de 4.3. No se
borran.

---

## 9. Volver a la 1.0.0

Cliente por cliente, solo en el que falle, y siempre desde `C:\Proyectos\proyecto-baystream`.
La 1.0.0 es `v1.0.0` (`eddc388`); la Web publicada lleva además las cabeceras de T-142
(`8f2505e`).

**La regla de la 10.123 también vale al volver:** con un cliente en la 1.0.0 y otro en la
1.0.1, no puede quedar abierta ninguna operación de una BAPLIE 1.5 ni con matrículas con
espacio. La 1.0.0 lee sin romperse lo que guardó la 1.0.1 (aceptación de T-144).

- **Android.** Play no deja bajar de versión, así que se sube el código de la 1.0.0 con un
  número mayor: con `git checkout v1.0.0`,

  ```powershell
  flutter build appbundle --release --build-name=1.0.0 --build-number=11 --dart-define-from-file=C:\Proyectos\baystream-privado\firebase-prod.json
  ```

  y ese AAB, a la prueba interna. Después, `git checkout master`. Desde ahí, la siguiente
  versión de Android lleva el `versionCode` 12 o más.
- **Windows, la MSIX.** La 1.0.0.0 es menor que la 1.0.1.0. El bloque copia primero las dos
  carpetas de datos y después instala la 1.0.0.0 encima, sin desinstalar, con
  `-ForceUpdateFromAnyVersion`. **Ese camino no está probado en este proyecto:** el parámetro
  existe en la documentación de Microsoft de `Add-AppxPackage`, que no dice qué pasa con los
  datos, y por eso la copia va antes.

  ```powershell
  & {
  $registro = 'C:\Proyectos\baystream-rediseno\build\t146\publicacion\registro.txt'
  New-Item -ItemType Directory -Force -Path (Split-Path -Parent $registro) | Out-Null
  function Anotar([string]$texto) { $linea = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')  $texto"; Add-Content -LiteralPath $registro -Value $linea -Encoding UTF8; $linea }
  if (Get-Process -Name baystream -ErrorAction SilentlyContinue) { throw 'Parar: cierra BayStream antes de seguir' }
  $msix = 'C:\Proyectos\baystream-publicaciones\build-hasta-1.0.0\t93\BayStream_1.0.0.0.msix'
  if (-not (Test-Path -LiteralPath $msix)) { throw "Parar: falta $msix" }
  if ((Get-FileHash -LiteralPath $msix -Algorithm SHA256).Hash -ne 'BA01DED75EB1E0DA80B1B30D9CE9B8649167683994B583683398A889246E764B') { throw 'Parar: la MSIX 1.0.0.0 no tiene la huella anotada' }
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
  Anotar "9 Vuelta de la MSIX: copia de los datos en $respaldo ($copiadas carpetas). Se instala la 1.0.0.0 encima de la $instalada"
  try { Add-AppxPackage -Path $msix -ForceUpdateFromAnyVersion -ErrorAction Stop } catch { throw "Parar: no se instalo la 1.0.0.0 ($_); la $instalada sigue instalada. No desinstalar: avisar" }
  $ahora = @(Get-AppxPackage | Where-Object Name -like '*baystream*')
  Anotar "9 Vuelta de la MSIX, instalada: $($ahora[0].Name) $($ahora[0].Version)"
  }
  ```

  Si ese bloque no instala, **no se desinstala la MSIX por cuenta propia:** desinstalar borra
  los datos que vivan dentro del paquete (0.6). Se hace con Yov, con la copia a la vista. Para
  volver después a la 1.0.1.0, se instala encima, como en 4.3.
- **Windows, el asistente.** Desinstalar, que conserva los datos, e instalar el 1.0.0.9 de
  T-145: `C:\Users\Public\BayStream-T145\1.0.0.9\BayStream_Setup_1.0.0.9.exe`
  (`e4e7304cc83d3a3837b06288521054a6b884c0bf7155e97bba3f7790557bcbde`).
- **La Web.** En la consola de Firebase, Hosting → el historial de versiones → **la del 10-nov,
  20:09**, que es la 1.0.0 con las cabeceras de T-142, y la opción de volver a esa versión
  (*Rollback*). No la del 3-nov, que no las trae. Hay además una copia de esa Web en
  `C:\Proyectos\baystream-publicaciones\build-hasta-1.0.0\web\`.
- `git checkout v1.0.0` deja la carpeta en la etiqueta, sin rama («detached HEAD»): es lo
  esperado. No se hace ningún commit ahí.

---

## Lo que esta lista no cubre

- **Pasar la laptop de la MSIX al asistente.** Queda como un paso aparte, después de publicar y
  de saber dónde viven sus datos (0.6), con su propia copia y su propia prueba.
- **Producción en Play.** Android sigue en la prueba interna.
- **Otras PC con la MSIX.** Reciben `BayStream_1.0.1.0.msix` y su `.sha256`, y la instalan
  encima; quien no tiene el certificado importado usa el asistente.
