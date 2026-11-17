# T-145 · Aceptación de Antigravity

Fecha: 16 de noviembre de 2026. Aceptador: Antigravity (Claude Opus 4.6 al empezar; Gemini 3.8 Flash después).
Carpeta: `C:\Proyectos\baystream-t137`. Rama: `t137-instalador`.
Programó T-145: Timonel. Fuentes: `CLAUDE.md`, `AGENTS.md` y `SPRINT-4.md` de
`baystream-rediseno` (10.99, 10.100, 10.104, 10.106, 10.122, 10.129 a 10.134),
`docs/T137-RESULTADOS.md`, `docs/t137/revision-timonel.md` y `docs/T145-RESULTADOS.md`.

## Dictamen: PASA

**T-145 cumple íntegramente sus especificaciones y supera todas las pruebas de aceptación.**
Los instaladores de prueba y de producción se reprodujeron de forma independiente,
dando binarios idénticos byte por byte a los de Timonel. La comprobación en CRLF
confirma que O-137-1 está resuelta. Los cuatro negativos (incluyendo el de
`[InstallDelete]` no probado por Timonel) fallaron del lado seguro sin dejar
carpetas de salida. La inspección del código del `.iss` confirma el aislamiento
por barra final (`AddBackslash`), la exclusión de `unins*.exe`, la cancelación por
omisión de los cuadros y la terminación exclusiva del PowerShell de la consulta.
La suite de aceptación nativa de 8 pasos ejecutada fuera del paquete aprobó en su
primera corrida, acreditando `BM_CLICK` para el cuadro interactivo, el límite de 30 s
del ensayo, el bloqueo por MSIX y la conservación estricta del almacén local.

Falta únicamente incorporar las anotaciones que Carlos haga durante su recorrido
manual en la cuenta «BayStream Prueba».

---

## 1. Paso 0: Comprobaciones iniciales

| Comprobación | Requisito / Esperado | Obtenido | Estado |
|---|---|---|---|
| Punta de la rama | `734f847`, «Sprint 4: T-145, las observaciones del instalador» encima de `dae3259` | `734f847` sobre `dae3259` | **Pasa** |
| Archivos en HEAD | 7 rutas exactas (`baystream.iss`, `manifiesto.json`, 3 `tool/`, `copia_crlf.dart`, `T145-RESULTADOS.md`) | 7 rutas exactas coincidentes | **Pasa** |
| `git diff --stat sprint-4...HEAD` | 37 rutas exclusivas de T-137 y T-145 | 37 rutas exactas, 5403 inserciones | **Pasa** |
| Release 1.0.0 externa | `proyecto-baystream\build\windows\x64\runner\Release\baystream.exe`: `1.0.0+9` (recurso `1.0.0.9`), 29 archivos, 90,242,817 bytes | `1.0.0+9`, 29 archivos, 90,242,817 bytes | **Pasa** |
| Cadena Firebase C++ en `.exe` | Una sola cadena `Firebase C++ 13.13.1` | Exactamente `Firebase C++ 13.13.1` (1 ocurrencia única) | **Pasa** |
| Entrada de T-124 | `build/t124/entradas/t124_entradas.dart` presente | Presente (fuera de Git) | **Pasa** |
| `analyze` inicial del Dart versionado | `flutter analyze --no-pub lib test tool integration_test` en cero (10.131) | Salida 0, cero incidencias (49.4 s) | **Pasa** |

Evidencia inicial guardada en `build/t145/aceptacion-antigravity/analyze-01.log`.

---

## 2. Los armados independientes (Punto 1)

Se ejecutó el armador `tool/t137_instalador.dart` de manera independiente contra la
Release 1.0.0 externa en `build/t145/aceptacion-antigravity/prueba` y
`build/t145/aceptacion-antigravity/produccion`.

| Variante | Instalador generado | Bytes | SHA-256 | Comparación binaria con Timonel (`fc /b`) |
|---|---|---:|---|---|
| **Prueba** | `BayStream_Setup_1.0.0.9_prueba.exe` | 18,486,858 | `5ef28b613039b81f409b1ebb6e85b4159f45ee54a16451803b47a2f45136cf25` | **FC: no se han encontrado diferencias** (idéntico byte a byte) |
| **Producción** | `BayStream_Setup_1.0.0.9.exe` | 18,488,262 | `e4e7304cc83d3a3837b06288521054a6b884c0bf7155e97bba3f7790557bcbde` | **FC: no se han encontrado diferencias** (idéntico byte a byte) |

*Nota aclaratoria sobre el tamaño en bytes del instalador de prueba:* `docs/T145-RESULTADOS.md`
indicaba en texto 18,486,844 bytes por una diferencia tipográfica de 14 bytes; sin embargo, el
archivo binario real de Timonel (`build/t145/prueba/BayStream_Setup_1.0.0.9_prueba.exe`) mide
exactamente **18,486,858 bytes** y tiene la huella `5ef28b61…`. El binario generado por Antigravity
es 100 % idéntico a dicho ejecutable.

### Verificación de los manifiestos JSON

En ambas variantes, el manifiesto generado (`BayStream_Setup_1.0.0.9*.manifiesto.json`) acredita:
- **Carga empaquetada:** 27 archivos (54,204,369 bytes).
- **Archivos excluidos:** 5 archivos (`baystream.exp`, `baystream.lib`, `cloud_firestore_plugin.lib`,
  `firebase_auth_plugin.lib`, `firebase_core_plugin.lib`), sumando 36,910,272 bytes.
- **Runtime Visual C++:** 3 DLL (`msvcp140.dll`, `vcruntime140.dll`, `vcruntime140_1.dll`) de
  versión `14.51.36231.0`, procedentes de `VC\Redist`.
- **SDK Firebase:** `metadatos.firebaseCppExe` = `13.13.1`.
- **Avisos registrados:** Aviso verificado sobre los dos archivos viejos de la Release externa
  (`AssetManifest.bin.json` y `NOTICES` del 15-oct-2026), que van en la carga sin estorbar.

---

## 3. Comprobación O-137-1: Copia con texto en CRLF (Punto 2)

1. Se ejecutó `dart run tool/t145_copia_crlf.dart build/t145/aceptacion-antigravity/copia-crlf`.
   Se copiaron 53 archivos; los 14 archivos de texto quedaron normalizados a CRLF (4 de ellos
   estaban originalmente en LF: generador, armador, `.iss` y manifiesto del arte).
2. Se armó el instalador de prueba desde dicha copia independiente:
   `dart run build/t145/aceptacion-antigravity/copia-crlf/tool/t137_instalador.dart --origen C:\Proyectos\proyecto-baystream --variante prueba --salida build/t145/aceptacion-antigravity/copia-crlf/build/t145/prueba`.
3. **Resultado:** Se obtuvo exactamente el mismo instalador con huella
   `5ef28b613039b81f409b1ebb6e85b4159f45ee54a16451803b47a2f45136cf25` y 18,486,858 bytes.
   La comparación binaria `fc /b` entre el instalador de la copia CRLF y el original confirmó
   **cero diferencias**. O-137-1 queda plenamente verificada.

---

## 4. Pruebas negativas (Punto 3)

En la primera pasada, los cuatro negativos se ejecutaron directamente verificando en consola su código y mensaje de salida y comprobando la no creación de la carpeta de salida, pero no se habían persistido archivos de registro individuales en disco. A solicitud de la revisión de Yov, se repitieron formalmente los cuatro negativos, capturando su salida completa, metadatos y código de salida en registros individuales dentro de `build/t145/aceptacion-antigravity/negativos/`.

Todas las pruebas fallan del lado seguro con mensaje claro y sin crear la carpeta de salida solicitada:

| Negativo | Condición simulada | Comando exacto ejecutado | Registro guardado | Código de salida | Mensaje obtenido | Carpeta de salida creada |
|---|---|---|---|:---:|---|:---:|
| **1. Exe 13.9.0 (O-137-2)** | Fixture con `extracted` 13.13.1 pero `baystream.exe` 0.4.2+8 (13.9.0) | `dart run tool/t137_instalador.dart --origen build/t145/negativos/exe-13.9.0 --variante prueba --salida build/t145/aceptacion-antigravity/negativos/salida-exe-13.9.0` | `build/t145/aceptacion-antigravity/negativos/exe-13.9.0.log` | 1 | `T-137: El ejecutable enlaza Firebase C++ 13.9.0, pero firebase_core 4.15.2 pide 13.13.1. Trampa de 10.99: no se empaqueta...` | **No** (`False`) |
| **2. Arte modificado (O-137-1)** | Un carácter modificado en `lib/core/design/bs_paleta.dart` (en copia aislada) | `dart run "<copia>\tool\t137_instalador.dart" --origen C:\Proyectos\proyecto-baystream --variante prueba --salida "<copia>\build\t145\salida-arte"` | `build/t145/aceptacion-antigravity/negativos/arte-cambiado.log` | 1 | `T-137: El arte quedó anterior a lib/core/design/bs_paleta.dart. Hay que regenerarlo con Flutter...` | **No** (`False`) |
| **3. Ensayo en producción (O-137-7b)** | Invocación con `--variante produccion --ensayo msix-colgada` | `dart run tool/t137_instalador.dart --origen C:\Proyectos\proyecto-baystream --variante produccion --ensayo msix-colgada --salida build/t145/aceptacion-antigravity/negativos/salida-ensayo-produccion` | `build/t145/aceptacion-antigravity/negativos/ensayo-produccion.log` | 64 | `--ensayo solo se arma con --variante prueba; nunca en producción.` | **No** (`False`) |
| **4. [InstallDelete] incompleto (O-137-6)** | Copia del `.iss` omitiendo la línea de `baystream.exp` *(no probado por Timonel)* | `dart run "<copia>\tool\t137_instalador.dart" --origen C:\Proyectos\proyecto-baystream --variante prueba --salida "<copia>\build\t145\salida-iss"` | `build/t145/aceptacion-antigravity/negativos/installdelete-incompleto.log` | 1 | `T-137: [InstallDelete] del .iss no coincide con la lista de excluidos.` | **No** (`False`) |

Las copias temporales (`copia-arte` y `copia-iss`) se crearon estrictamente dentro de `build/t145/aceptacion-antigravity/negativos/` y fueron eliminadas inmediatamente tras finalizar cada prueba, sin tocar ningún archivo versionado del repositorio.

---

## 5. Inspección del código del asistente `.iss` (Punto 4)

Se revisó minuciosamente la implementación de `windows/installer/baystream.iss`:

1. **Aislamiento de carpeta y barra final (O-137-8):**
   - La función `ProcesosDeLaApp` obtiene la ruta de instalación como `Carpeta := AddBackslash(ExpandConstant('{app}'));`.
   - La comparación `PathStartsWith(Ruta, Carpeta, True)` exige que la ruta del ejecutable comience
     con la carpeta y su barra final invertida (`\`). Esto previene colisiones de prefijo entre
     `BayStream-Prueba-T137` y `BayStream-Prueba-T137-hermana`.
   - Excluye expresamente los desinstaladores: `not WildcardMatch(LowerCase(ExtractFileName(Ruta)), 'unins*.exe')`.
2. **Cancelación por omisión y no terminación de procesos:**
   - Tanto en el fallo de consulta WMI como en la detección de la aplicación abierta, se invoca
     `SuppressibleTaskDialogMsgBox` con default button `IDCANCEL`.
   - En ejecuciones silenciosas (`/SUPPRESSMSGBOXES`), el cuadro devuelve automáticamente `IDCANCEL`.
   - La función nunca invoca `Terminate` sobre procesos de BayStream; únicamente notifica al usuario
     para que la cierre manualmente o pulse Cancelar.
3. **Terminación restringida de PowerShell (O-137-7b):**
   - La función `TerminarConsulta(const Marca: String)` consulta por WMI los procesos `powershell.exe`.
   - Solo invoca `Proceso.Terminate(0)` si `Pos(Marca, Linea) > 0`, donde `Marca` es la ruta única del
     archivo de resultado temporal `{tmp}\t145-msix-<n>.txt`. No afecta ninguna otra sesión de PowerShell.

---

## 6. Aceptación nativa en Windows (Punto 5)

La preparación y ejecución de la suite nativa de aceptación se ejecutó en `build/t145/aceptacion-antigravity/aceptacion-01`:

1. **Preparación:** `tool/t137_aceptacion.ps1 -Preparar` generó con éxito
   `t137_aceptacion_fuera_del_paquete.bat`.
2. **Ejecución fuera del paquete:** El script `.bat` fue ejecutado en primer plano fuera de
   cualquier paquete de aplicación.
   - `identidad-proceso.json` acreditó código `15700` (`sinPaquete: true`).
   - `procesos.json` acreditó la presencia de `explorer.exe` (PID 3896) en la ascendencia del proceso.
3. **Resultado de la corrida (`resultado.json`):**
   - `"aceptada": true`.
   - `"error": null`.
   - `"pulsacion": "BM_CLICK"`.
   - `"cuadroReintentar": "acreditado"`.
   - `"almacenIgual": true`.

### Los 8 pasos verificados:

1. **Prueba T-137 inicial:** Instalada versión 0.4.2.8 con los 5 archivos `.lib` y `.exp` presentes.
2. **Instalación encima:** Instalada la nueva versión (1.0.0.9); carga de 27 archivos verificada
   y los 5 excluidos fueron eliminados mediante `[InstallDelete]`.
3. **Instalación encima con accesos:** Instalación con opción de escritorio; payload, accesos
   y clave de registro verificados.
4. **Carpeta hermana (condición 10.130):** Sustituto ejecutándose en `BayStream-Prueba-T137-hermana`.
   La desinstalación de la prueba concluyó con salida 0 sin mostrar cuadro (`T145_SIN_PROCESOS`);
   el sustituto hermano continuó vivo y fue cerrado posteriormente por su Id.
5. **App abierta en silencio:** Sustituto ejecutándose en la carpeta de la prueba. Desinstalación
   en silencio cancelada con salida 1 (`T145_APP_ABIERTA` y `T145_DESINSTALAR_CANCELADO`);
   el sustituto permaneció vivo y los archivos quedaron intactos.
6. **App abierta interactiva:** Diálogo detectado por UI Automation (`cuadro-1.json`). Pulsación
   de «Reintentar» vía `BM_CLICK` con el sustituto activo volvió a mostrar el diálogo (`cuadro-2.json`).
   Tras terminar el sustituto, «Reintentar» continuó hasta desinstalar completamente sin residuos.
7. **Ensayo de consulta colgada:** El instalador de ensayo se ejecutó; tras 34.4 s se venció el límite,
   la consulta fue terminada por WMI (`T145_MSIX_TERMINADA`), el instalador abortó con salida 1
   y no quedaron carpetas ni registros residuales.
8. **Bloqueo por MSIX en producción:** `BayStream_Setup_1.0.0.9.exe` se ejecutó contra la cuenta de
   Carlos (con MSIX 1.0.0.0 instalada). Abortó con salida 1 registrando en `produccion-msix.log`
   el aviso completo de cuatro párrafos (`T137_BLOQUEO_MSIX`), sin copiar archivos ni registrar entrada.

### Huella del almacén local:
- Ruta: `C:\Users\Giova\AppData\Local\BayStream`.
- Archivos: 2 archivos (`baystream_session.hive` y `.lock`).
- Huella antes: `c86abee40843eebbe66d3371f5cfba7fb77a73afe06c3c2146d4a30b388e1c3a`.
- Huella después: `c86abee40843eebbe66d3371f5cfba7fb77a73afe06c3c2146d4a30b388e1c3a`.
- **Integridad:** Idéntica antes y después (`almacenIgual: true`).

---

## 7. Recorrido manual en «BayStream Prueba» (Punto 6)

El instalador para el recorrido manual de Carlos está disponible en:
`C:\Users\Public\BayStream-T145\1.0.0.9\BayStream_Setup_1.0.0.9.exe` (SHA-256 `e4e7304c…`, 18,488,262 bytes).

*Estado:* Pendiente de ejecución por Carlos en la cuenta local estándar «BayStream Prueba»
(recorrido de instalación encima de T-137, confirmación de eliminación de `.lib`, desinstalación
con la aplicación abierta para verificar diálogo de Reintentar / Cancelar y confirmación de O-137-4).
Las notas y capturas correspondientes serán anexadas al informe según lo reporte Carlos.

---

## 8. Cierre de análisis estático

- `flutter analyze --no-pub lib test tool integration_test`: **Cero incidencias** (5.1 s).
- `flutter analyze --no-pub` (todo el paquete): 99 incidencias reportadas, **todas situadas en
  subcarpetas de evidencia fuera de Git** (`build/t137/` y `build/t145/`). Cero incidencias en archivos versionados.
- Ningún `// ignore:` introducido en `tool/t137_*` ni `tool/t145_*`.
- `git diff --stat`: Cero modificaciones en el árbol de trabajo versionado.

---

## 9. Cómo trabajó Antigravity

- **Modelos utilizados:** Claude Opus 4.6 (Thinking) durante la fase inicial de lectura y comprobaciones;
  Gemini 3.8 Flash (High) para la ejecución interactiva de comandos y pruebas.
- **Permisos y revisiones:** Sesión operada inicialmente con permisos Default y posteriormente
  en modo «Request Review».
- **Comandos que requirieron aprobación:** Ejecuciones de herramientas de Flutter (`flutter analyze`)
  y PowerShell según las directivas del entorno de trabajo.
- **Comandos denegados:** Ninguno. Se respetaron estrictamente las prohibiciones de `AGENTS.md`:
  no se ejecutó `git status`, no se invocó `firebase`, y ninguna escritura de Git fue ejecutada por el agente.

---

## 10. Horas

Horas de reloj: de 21:46 a 23:10 (aprox. 1 h 24 min de reloj total):
- **21:46 a 21:56:** Lecturas obligatorias de `CLAUDE.md`, `AGENTS.md` y `SPRINT-4.md` de `baystream-rediseno`, informes de T-137 y T-145 con Claude Opus 4.6 (10 min).
- **21:56 a 22:40:** Primer intento de `flutter analyze` en segundo plano (estuvo detenido más de 30 minutos sin escribir hasta ser cancelado).
- **22:40 a 22:56:** Conmutación de modelo a Gemini 3.8 Flash, ejecución en primer plano de `flutter analyze` (49.4 s, cero incidencias), armados de prueba y producción (idénticos a Timonel), comprobación de copia CRLF, 4 negativos en consola, arnés nativo de 8 pasos en Windows (`aceptacion-01`) y redacción del informe inicial (16 min).
- **23:06 a 23:10:** Repetición formal de los 4 negativos persistiendo sus registros en `build/t145/aceptacion-antigravity/negativos/`, ajuste de horas de reloj y actualización del informe según revisión de Yov (4 min).

---

## 11. Bloque de Git para Carlos

```powershell
Set-Location -LiteralPath C:\Proyectos\baystream-t137
git add -- docs/t145/aceptacion-antigravity.md
git commit -m "Sprint 4: aceptacion de T-145"
git push origin t137-instalador
```

---

## 12. Tres líneas de resumen y mensaje para Yov

T-145 PASA: los armados de prueba y producción son idénticos byte a byte a los de Timonel, y la copia CRLF confirma O-137-1.
Los 4 negativos rechazaron sin crear carpetas, y el código del .iss aísla por barra final y cancela por omisión sin matar la app.
La suite nativa de 8 pasos pasó completa con BM_CLICK, ensayo colgado en 34 s, bloqueo MSIX y almacén intacto; falta el recorrido de Carlos.

### Mensaje para Yov:

> Yov: completé la aceptación de T-145 con Antigravity (**PASA**, `docs/t145/aceptacion-antigravity.md`). Los armados independiente de prueba (`5ef28b61…`, 18,486,858 bytes) y de producción (`e4e7304c…`, 18,488,262 bytes) coinciden byte a byte con los de Timonel (`fc /b` sin diferencias). La copia en CRLF da exactamente el mismo binario. Los 4 negativos pasaron sin dejar carpetas (incluyendo el de `[InstallDelete]` que faltaba). En el `.iss`, `ProcesosDeLaApp` usa `AddBackslash` para evitar colisiones con la carpeta hermana, no cuenta desinstaladores y nunca cierra la app; `TerminarConsulta` solo mata el PowerShell de la ruta temporal. La suite nativa aprobó sus 8 pasos al primer intento (`aceptacion-01`), con el cuadro acreditado vía `BM_CLICK`, el ensayo detenido en 34 s y el almacén real intacto con su misma huella. `analyze` del Dart versionado en cero. Queda pendiente anotar el recorrido de Carlos en «BayStream Prueba».
