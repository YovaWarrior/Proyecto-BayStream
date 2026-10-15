# T-93 · Aceptación cruzada del instalador MSIX firmado

Fecha: 15-oct-2026, hora de Guatemala. Responsable: Capitán Codex.
Implementación revisada: Timonel. Base: `bd09a4d15fd1b7c1d37357748ae25437375513cd`, rama `sprint-3`, decisión 10.41.

## Veredicto: NO PASA la aceptación completa

Las pruebas de instalación, uso, persistencia, actualización y desinstalación pasan. **No pasa el control de firma de `tool/t93_msix.ps1`: consulta y muestra el estado de la firma, pero solo rechaza una huella distinta; no rechaza `HashMismatch` si el certificado sigue siendo el esperado.** No se corrigió código.

Los dos paquetes originales generados en esta aceptación tienen firma **Valid**, sujeto `CN=BayStream` y huella `60BEF8F4D26ECF7AD25CC478E715CF9B26A278EC`. La falla se comprobó con una copia temporal alterada, que nunca se instaló.

El almacén real quedó devuelto a su sitio, con **316 archivos y la misma huella antes y después**. BayStream quedó desinstalada. Flutter y el almacén se liberaron mediante aviso `SEMÁFORO:`.

| Criterio | Resultado observado |
| --- | --- |
| Script: Release con opciones de Firebase, firma y `.sha256` | Pasa la generación; **no pasa la validación estricta de firma**, sección siguiente |
| Doble clic con App Installer, entrada en Inicio y Firebase | Pasa; instalación inicial sin recurrir a `Add-AppxPackage` |
| A07 y persistencia al cerrar por PID y reabrir | Pasa: 398 / 21 / 6940.6 t / 0-114-284 |
| T-84, inicio de sesión manual de Carlos y «Al día» | Pasa: 4 / 3 / 20.0 t / 0-3-1; sin registrar movimientos |
| Actualización a 1.0.2.0 | Pasa: conserva los dos viajes, Recientes y la sesión |
| Desinstalación y borrado del almacén del paquete | Pasa: desaparecen el paquete, su carpeta privada y la entrada de Inicio |
| Devolución del almacén real con huella idéntica | Pasa: 316 archivos; respaldo, apartado y devolución coinciden |
| Suite y configuración T-93, analyze y `pubspec.*` | Pasa: 685/685; T-93 5/5; analyze 0; sin secretos detectados |

## 1. Control de firma que no pasa

En `tool/t93_msix.ps1`, líneas 70–76 de la base revisada:

```powershell
$firma = Get-AuthenticodeSignature -LiteralPath $msix
# La línea 73 muestra Status, Subject y Thumbprint.
if ($firma.SignerCertificate.Thumbprint -ne $Huella) {
  throw 'El paquete no quedo firmado con el certificado de esa huella.'
}
```

La condición no consulta `$firma.Status`. La sonda de aceptación:

1. Copió el MSIX original 1.0.2.0 a `%TEMP%\baystream-t93acc\sonda-firma-alterada.msix`.
2. Cambió un bit del byte situado en el desplazamiento 4096 de esa copia.
3. Consultó `Get-AuthenticodeSignature` y evaluó exactamente la condición de rechazo de la línea 74.

| Comprobación | Resultado |
| --- | --- |
| Estado de la firma de la copia alterada | `HashMismatch` |
| Sujeto y huella del firmante de esa copia | `CN=BayStream`, la huella autorizada |
| `$firma.SignerCertificate.Thumbprint -ne $Huella` | `False`: el control final no la rechaza |
| Firma del MSIX original, comprobada de nuevo | `Valid` |

Evidencia: `sonda-firma-alterada.json` en la carpeta temporal de aceptación. Se comprobó el predicado de validación; no se ejecutó de nuevo el generador sobre la copia corrupta ni se intentó instalarla.

**Corrección propuesta para Timonel, no implementada:** exigir simultáneamente firma `Valid` y huella esperada, y comprobar que una firma alterada causa error. Las cinco pruebas existentes de T-93 pasan, pero no cubren este rechazo. La aceptación completa queda pendiente de esa corrección y su comprobación.

## 2. Base e aislamiento de T-103

Se leyeron `AGENTS.md`, la ficha T-93, las decisiones 10.36, 10.37, 10.40 y 10.41 de `SPRINT-3.md`, y `docs/T93-RESULTADOS.md`. Se respetó la regla del almacén de 10.37; no se usó el Honor ni se hizo una prueba sin red.

`git log --oneline -3` devolvió:

```text
bd09a4d Sprint 3: decision 10.41, T-94 y T-104 terminadas, T-103 adelantada y el repositorio privado
83b4645 Sprint 3: aceptacion cruzada de la correccion de T-94 y de T-104 por Timonel
7c939e6 Sprint 3: decision 10.40, la correccion de T-94 y T-104 en revision, piso 685
```

La lectura de `.git/HEAD` confirmó `ref: refs/heads/sprint-3`. Carlos dio el semáforo para Flutter y el almacén. No se contactó a Timonel.

La copia se construyó leyendo los objetos de ese commit con `git show`, sin copiar el árbol concurrente ni cambiar de rama. Sus **555 archivos** quedaron en `%TEMP%\baystream-t93acc\head\`. Se registró un manifiesto SHA-256 y, tras compilar, probar y empaquetar, los 555 seguían idénticos a su contenido de HEAD. Incluyen los 125 archivos de `lib/` de esa base. No se sobrescribieron binarios del árbol de trabajo.

La consulta permitida `git diff --stat --ignore-cr-at-eol m2-baseline -- lib/latency_test_screen.dart lib/c3_reconciliation_screen.dart` no devolvió diferencias.

## 3. Generación y paquetes originales

Desde la copia de HEAD se ejecutó el script sin modificarlo:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File tool\t93_msix.ps1 -Huella 60BEF8F4D26ECF7AD25CC478E715CF9B26A278EC -Version 1.0.0.0
powershell.exe -NoProfile -ExecutionPolicy Bypass -File tool\t93_msix.ps1 -Huella 60BEF8F4D26ECF7AD25CC478E715CF9B26A278EC -Version 1.0.2.0 -SinCompilar
```

El primer comando compiló Release con `--dart-define-from-file`, usando la ruta opaca predeterminada del script. No se abrió, listó, copió ni mostró el contenido de `baystream-privado`. El segundo reempaquetó la misma compilación. Ambos terminaron con código 0 y produjeron MSIX y `.sha256` en `head\build\t93\`, dentro de `%TEMP%`.

| Versión | Bytes | SHA-256 del MSIX | Firma comprobada independientemente |
| --- | ---: | --- | --- |
| 1.0.0.0 | 25479458 | `7D8F409758D2D7F2B4D36F92A7B48AF81761769CCDC2F5E06E73553195C6184C` | Valid; CN=BayStream; huella autorizada |
| 1.0.2.0 | 25479458 | `E0F94823DC7D15611866ECAC4DEF4D21DEECA8D961EEEA75F6A25AC6A0E5D3A3` | Valid; CN=BayStream; huella autorizada |

Cada `.sha256` coincide con su paquete. No se crearon ni importaron certificados ni se modificaron sus almacenes. No se exportó la clave ni se usaron PFX o contraseñas.

La compilación de Windows informó 247.8 s. MSBuild emitió `MSB8029` porque los directorios de compilación están en `%TEMP%`, ubicación exigida por 10.41. Se conserva la advertencia en el registro; no se modificó el proyecto para eliminarla.

## 4. Instalación, viajes y actualización

**Instalación inicial:** doble clic real sobre `BayStream_1.0.0.0.msix` en el Explorador. App Installer mostró «Install BayStream?», versión 1.0.0.0, y permitió instalar. Carlos confirmó pulsar `Install`. No hubo error de confianza ni se necesitó el método alternativo.

`Get-AppxPackage` confirmó `gt.cmartinez.baystream`, versión 1.0.0.0 y estado correcto. `Get-StartApps` mostró «BayStream» con AppID `gt.cmartinez.baystream_bq33510ehc1x4!baystream`. La app abrió con Firebase y permitió acceder a producción desde su interfaz.

**A07:** se cargó el archivo del corpus externo, se eligió GTSTC y se marcó «No lo tengo» para el límite de apilamiento. No se inventó un umbral.

| Momento | Contenedores | Bahías | Peso visible | GTSTC: cargan / descargan / de paso |
| --- | ---: | ---: | --- | --- |
| A07 en 1.0.0.0, PID 21092 | 398 | 21 | 6940.6 t | 0 / 114 / 284 |
| A07 desde Recientes tras cerrar y reabrir, PID 13136 | 398 | 21 | 6940.6 t | 0 / 114 / 284 |
| A07 desde Recientes en 1.0.2.0, PID 26268 | 398 | 21 | 6940.6 t | 0 / 114 / 284 |
| T-84 en 1.0.0.0 | 4 | 3 | 20.0 t | 0 / 3 / 1 |
| T-84 desde Recientes en 1.0.2.0 | 4 | 3 | 20.0 t | 0 / 3 / 1 |

A07 también mostró 290 llenos y 108 vacíos. El primer cierre se solicitó con `CloseMainWindow` sobre PID 21092: el proceso no había salido al cumplirse la espera inicial de 5 s; una comprobación posterior confirmó su salida antes de lanzar otro. No se abrió una segunda instancia mientras seguía vivo.

**Sesión y nube:** primero se restauró automáticamente «Carlos Oficina · Oficina». Carlos cerró e inició sesión personalmente y confirmó «Cuenta autorizada». Codex no introdujo ni registró credenciales. Desde la app se usó «Unirse» a «PRUEBA T-84» y «Abrir plano de llegada». Se comprobó «Publicada · Al día» antes y después de actualizar. No se publicaron operaciones, no se registraron movimientos y no se usó la CLI de Firebase ni el proyecto de H5.

**Actualización:** tras cerrar PID 13136, `Add-AppxPackage` instaló 1.0.2.0 sobre 1.0.0.0 en la misma familia. Antes de volver a abrir se compararon los **14 archivos** de `vessel_store`: mismo nombre, tamaño y SHA-256, **0 diferencias**. La versión nueva abrió desde su ruta en `WindowsApps`; Recientes conservó A07 y T-84 y la sesión siguió autorizada.

## 5. Almacén real y desinstalación

Antes de instalar se avisó con `SEMÁFORO:`. Un `.bat` lanzado mediante `explorer.exe` tomó las huellas fuera del paquete de Codex, copió el almacén con `robocopy` a `%TEMP%\baystream-t93acc-respaldo\`, comprobó el respaldo y renombró el original a `%LOCALAPPDATA%\BayStream.t93acc-real`. No había ningún `baystream.exe` abierto.

La huella agrega, para cada archivo, su SHA-256, tamaño y ruta relativa: se ordenan las líneas, se unen con LF y se calcula SHA-256 sobre UTF-8. Los manifiestos y el script quedan como evidencia temporal. No se inspeccionó el contenido de los archivos del almacén.

| Estado | Archivos | Huella agregada SHA-256 |
| --- | ---: | --- |
| Real antes de apartar | 316 | `0ACA4F454596B5F90398911ADDCB934F1FD0B7DCB064885F4F892BEE6D3B1DD8` |
| Respaldo verificado | 316 | La misma |
| Carpeta apartada verificada | 316 | La misma |
| Real devuelto a su sitio | 316 | La misma |

Las dos operaciones registran la cadena de procesos `powershell.exe → cmd.exe → explorer.exe`. La huella inicial se tomó a las **11:22:39** y la final a las **11:38:28**, hora de Guatemala. La devolución terminó con `OK` y se anunció con `SEMÁFORO:`.

Con el real apartado, el almacén de la app instalada vivió en:

```text
%LOCALAPPDATA%\Packages\gt.cmartinez.baystream_bq33510ehc1x4\LocalCache\Local\BayStream\vessel_store
```

Se cerró PID 26268 y se desinstaló con `Get-AppxPackage -Name gt.cmartinez.baystream | Remove-AppxPackage`. La carpeta privada tenía **24 archivos** antes. Después no existían ni el paquete registrado, ni la carpeta de esa familia, ni `vessel_store`, ni la entrada de Inicio. No se consultó el Administrador de credenciales ni se verificó su limpieza: el resultado comprobado es el borrado del almacén privado del paquete.

El respaldo se conserva para Carlos. La app queda desinstalada para evitar un arranque posterior sobre el almacén real ya devuelto.

## 6. Validaciones y evidencia

Todas se ejecutaron en la copia de HEAD y en secuencia, sin `--platform chrome`:

| Validación | Resultado |
| --- | --- |
| `flutter test --no-pub --reporter expanded` | **685/685**, 1 min 43 s |
| `flutter test test/t93_msix_config_test.dart --no-pub --reporter expanded` | **5/5**, corrida específica para identificar la evidencia de T-93 |
| `flutter analyze --no-pub` | **No issues found**, 37.5 s |
| Los 31 scripts del corpus, con `BAYSTREAM_CORPUS_DIRECTORY` externo | **116/116**, 1 min 18 s |
| Copia de HEAD, comparación posterior de 555 archivos | **0 diferencias** |
| Inspección de `pubspec.yaml` y `pubspec.lock` | Sin secretos detectados; configuración T-93 y dependencia fija 3.18.0 verificadas |

La inspección de `pubspec.*` no encontró contraseñas o rutas de certificados, PFX/P12, claves privadas ni credenciales de Firebase. Los SHA de integridad normales de `pubspec.lock` no son secretos. En el árbol original, ambos archivos coinciden con HEAD al normalizar CRLF; `pubspec.yaml` tiene finales CRLF y la copia exacta de HEAD usa LF. **Esta aceptación no modifica `pubspec.yaml` ni `pubspec.lock`, ni añade dependencias.**

Las evidencias están en `%TEMP%\baystream-t93acc\`: manifiesto de HEAD; registros de compilación, suite, analyze y corpus; JSON de los dos paquetes y de la sonda de firma; huellas y cadenas de padres del almacén; registros de instalación, actualización y desinstalación; y capturas de A07, Recientes y T-84 «Al día» antes y después de actualizar. El corpus y sus salidas quedan fuera del repositorio.

## 7. Único archivo añadido por esta aceptación

- `docs/T93-ACEPTACION-RESULTADOS.md`.

No se modificaron los archivos de implementación, pruebas, configuración ni entregables de otros carriles. No se ejecutaron operaciones de escritura de Git, `git status`, publicaciones ni comandos de Firebase.

## Mensaje para Yov

Capitán Codex completó la aceptación cruzada de T-93 sobre una copia exacta de bd09a4d, decisión 10.41. El veredicto completo es NO PASA: el control final de tool/t93_msix.ps1 solo exige la huella; una copia alterada devuelve HashMismatch con esa misma huella y su condición de rechazo resulta falsa. No corregí código. Los paquetes originales sí tienen firma Valid y SHA-256 correcto. Pasaron el doble clic con App Installer, Inicio y Firebase, A07 398/21/6940.6 t/0-114-284 con reapertura por PID, T-84 Al día con 4/3/20.0 t/0-3-1 y sesión iniciada por Carlos, la actualización a 1.0.2.0 con Recientes y sesión conservados, y la desinstalación con borrado del almacén privado. Suite 685/685, T-93 5/5, analyze 0 y corpus 116/116. El almacén real se respaldó y apartó antes de instalar y volvió idéntico: 316 archivos, SHA-256 0ACA4F454596B5F90398911ADDCB934F1FD0B7DCB064885F4F892BEE6D3B1DD8, comprobado fuera del paquete. App desinstalada y semáforo liberado. Informe: docs/T93-ACEPTACION-RESULTADOS.md; única ruta para el commit.
