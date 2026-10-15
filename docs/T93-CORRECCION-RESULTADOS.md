# T-93 · Corrección de la verificación del MSIX

Fecha: 15-oct-2026, hora de Guatemala. Responsable: Capitán Codex.
Base: `0b7f539f292c5166a020b716df0c751159fee1ac`, rama `sprint-3`, decisión 10.42.

## Resultado

Corrección implementada y comprobada. El original válido termina con código **0**; la firma alterada, el SHA incorrecto y la huella incorrecta terminan con **1** y explican el fallo. `-SinCompilar` termina con **0** usando la misma función de verificación. Suite **685/685**, T-93 **5/5**, analyze **0**.

**T-93 sigue En revisión:** Timonel repetirá las cuatro sondas con el script commiteado cuando entregue T-103. Este informe no sustituye esa aceptación cruzada.

## 1. Cambio

`tool/t93_msix.ps1` contiene una sola función, `Test-PaqueteMsix`, que exige simultáneamente:

1. SHA-256 del MSIX igual al registrado en el archivo adyacente `<paquete>.msix.sha256`.
2. `Get-AuthenticodeSignature` con `Status` igual a `Valid`.
3. Huella del firmante igual a la recibida por `-Huella`.

El verificador también rechaza un `.sha256` ausente, vacío o con formato inválido. Admite la línea que ya genera el armado, `SHA256  nombre.msix`, o el hash solo. Muestra `Status` y `StatusMessage`; si falla alguna condición, reúne los motivos y lanza un error. Para `HashMismatch` dice que el paquete está alterado o dañado y no se distribuye. Para `NotTrusted`, indica importar primero `BayStream.cer` en «Personas de confianza» del equipo local. Esta rama se revisó en el código, sin alterar almacenes de certificados para provocarla.

El armado conserva sus pasos de compilación, empaquetado y escritura del `.sha256`, y termina llamando a esa función. Se eliminó el control anterior que solo comparaba la huella.

El nuevo modo `-Verificar <ruta>` llama a la misma función y retorna antes de cambiar de directorio, validar la versión, comprobar las opciones de Firebase o invocar Flutter/Dart. Sus rutas relativas se resuelven desde el directorio de quien lo ejecuta. Los conjuntos de parámetros separan este modo del armado.

En la prueba existente «T-93 el script compila con Firebase y firma por huella» se añadió una sola exigencia: que esté presente la condición `if ($firma.Status -ne 'Valid')`. No se añadieron casos: siguen siendo cinco pruebas T-93 y 685 en la suite.

El script contiene **0 bytes fuera de ASCII** y el analizador de PowerShell encuentra **0 errores sintácticos y 1 función**.

## 2. Base y convivencia con T-103

Antes de editar, `git log --oneline -3` mostró:

```text
0b7f539 Sprint 3: decision 10.42, T-93 no pasa por el control de firma y Codex lo corrige
0cd6074 T-93: registrar aceptacion y fallo de validacion de firma
bd09a4d Sprint 3: decision 10.41, T-94 y T-104 terminadas, T-103 adelantada y el repositorio privado
```

Se leyeron `AGENTS.md`, la decisión 10.42 y la corrección completa al final de la ficha T-93. Se exportaron los objetos de HEAD con `git show` a `%TEMP%\baystream-t93correccion\head\`: **556 archivos**, con un manifiesto SHA-256. Los cambios concurrentes de Timonel no entraron en la copia.

Para `-SinCompilar` se copió la carpeta Release de la aceptación anterior, situada en `%TEMP%\baystream-t93acc\head\build\windows\x64\runner\Release\`. Antes se comprobó que `lib/`, `windows/`, `assets/` y `pubspec.*` de ambas bases eran idénticos. Los **18 archivos** de Release también coincidieron por SHA-256 tras copiarlos. No se recompiló ni se usaron los binarios del árbol de trabajo.

Carlos dio el semáforo. La preparación de dependencias, el empaquetado, la suite, T-93, analyze y formato se ejecutaron en secuencia. Se liberó la cadena con `SEMÁFORO:` antes de redactar y entregar. El corpus no se repitió: la ficha lo excluye porque `lib/` no cambia.

## 3. Las cuatro sondas reales

Fuente: `%TEMP%\baystream-t93acc\head\build\t93\BayStream_1.0.2.0.msix` y su `.sha256`, de la aceptación. Su SHA-256 es `E0F94823DC7D15611866ECAC4DEF4D21DEECA8D961EEEA75F6A25AC6A0E5D3A3`.

Las sondas usan copias bajo `%TEMP%\baystream-t93correccion\sondas\`. Se invocó el modo `-Verificar` del script corregido en **Windows PowerShell 5.1**, desde fuera de la copia del proyecto, con un `PATH` que contiene solo herramientas de Windows: **sin Flutter ni Dart**. El script no compiló ni empaquetó durante estas sondas. Ninguna copia se instaló.

| Sonda | Preparación | Código | Mensaje emitido y estado |
| --- | --- | ---: | --- |
| Original válido | Copia idéntica y `.sha256` coincidente; huella autorizada | **0** | `Firma: Valid` con `CN=BayStream` y la huella autorizada. `Status: Valid. StatusMessage: Firma comprobada.` |
| Firma alterada | Un bit cambiado en el desplazamiento 4096; `.sha256` recalculado y coincidente | **1** | `Verificacion MSIX fallo: El paquete esta alterado o danado; no se distribuye.` `Status: HashMismatch`; se muestra el `StatusMessage` completo de Windows |
| SHA incorrecto | MSIX original intacto; `.sha256` con 64 ceros | **1** | `Verificacion MSIX fallo: El SHA-256 del paquete no coincide con su .sha256.` `Status: Valid. StatusMessage: Firma comprobada.` |
| Huella incorrecta | MSIX original y `.sha256` correcto; `-Huella` con 40 ceros, formato válido | **1** | `Verificacion MSIX fallo: La huella del firmante no coincide con -Huella.` `Status: Valid. StatusMessage: Firma comprobada.` |

La huella autorizada es `60BEF8F4D26ECF7AD25CC478E715CF9B26A278EC`. Los ceros son entradas deliberadas de las sondas, no certificados nuevos.

El MSIX alterado tiene SHA-256 `4A9E8E40CB1CBE9E767DB57524A52B9ED8C8CCD90568BFE785BAEB83A7DBF709`, igual al de su `.sha256`: el rechazo procede de la firma, no del archivo de hash. Su firmante conserva `CN=BayStream` y la huella autorizada.

El `StatusMessage` de `HashMismatch` explica que un proceso o usuario pudo modificar el contenido y que el hash del archivo no coincide con el almacenado en la firma digital. Los mensajes íntegros, incluidas las rutas y la salida de error, están en `sondas/<sonda>/salida.txt`; `sondas.json` registra también los códigos y los hashes. La tabla separa el motivo y los datos de firma para facilitar la lectura.

**Incidencia del lanzador de pruebas:** el primer intento desde Python heredó el directorio de módulos de PowerShell 7, y PowerShell 5.1 no cargó `Microsoft.PowerShell.Security`. Ese intento no se cuenta como resultado de las sondas. Se conservó su evidencia en `sondas-entorno-anterior*`; el lanzador final fija los módulos nativos de Windows PowerShell y la codificación de salida. Las cuatro ejecuciones válidas terminaron después con los códigos de la tabla, sin cambiar el script por esa incidencia.

## 4. Armado con `-SinCompilar`

Desde la copia temporal se ejecutó:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File tool\t93_msix.ps1 -Huella 60BEF8F4D26ECF7AD25CC478E715CF9B26A278EC -Version 1.0.2.0 -SinCompilar
```

Código de salida: **0**. El modo reempaquetó la compilación Release ya validada, mantuvo `--build-windows false` e `--install-certificate false` y terminó llamando a `Test-PaqueteMsix`.

```text
SHA-256: AA39928EA0ACEC0A94F11E3E2F79234166004BC4426E99E4A74004E7B54EC8DC
Firma:   Valid | CN=BayStream | 60BEF8F4D26ECF7AD25CC478E715CF9B26A278EC
Status: Valid. StatusMessage: Firma comprobada.
```

Paquete y `.sha256`: `%TEMP%\baystream-t93correccion\head\build\t93\BayStream_1.0.2.0.msix`. Una comprobación independiente confirmó firma válida, huella correcta y coincidencia del SHA. Evidencia: `sin-compilar.log`, `sin-compilar-codigo.txt` y `sin-compilar-paquete.json`.

La ruta predeterminada de opciones se dejó opaca al script, como en la aceptación. No se abrió ni copió su contenido ni se accedió a Firebase. No se crearon, importaron ni exportaron certificados.

## 5. Validaciones en la copia corregida

| Comando o revisión | Resultado |
| --- | --- |
| `flutter pub get --offline` | Código 0; sin cambios en `pubspec.*` |
| `flutter test --no-pub --reporter expanded` | **685/685**, código 0; 39 s en la salida del ejecutor |
| `flutter test test/t93_msix_config_test.dart --no-pub --reporter expanded` | **5/5**, código 0 |
| `flutter analyze --no-pub` | **No issues found**, código 0; 7.1 s |
| `dart format --output=none --set-exit-if-changed test/t93_msix_config_test.dart` | Código 0; 0 archivos cambiados |
| Manifiesto de los 556 archivos de HEAD, después de verificar | Solo difieren `tool/t93_msix.ps1` y `test/t93_msix_config_test.dart` |
| Script ASCII y sintaxis PowerShell | 0 bytes no ASCII; 0 errores; 1 función |

El informe se añadió después de esas comprobaciones. Las evidencias y los paquetes quedan en `%TEMP%\baystream-t93correccion\`. No se modificaron `lib/`, `web/`, `windows/`, `pubspec.yaml`, `pubspec.lock` ni otras pruebas. No hay dependencias nuevas.

## 6. Línea para las instrucciones de oficina de T-100

Con `t93_msix.ps1`, el MSIX y su archivo `.msix.sha256` en la misma carpeta, ejecutar antes de llevar o instalar el paquete; no requiere Flutter, el repositorio ni opciones de Firebase:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\t93_msix.ps1 -Huella 60BEF8F4D26ECF7AD25CC478E715CF9B26A278EC -Verificar .\BayStream_1.0.2.0.msix
```

Solo se distribuye si termina con código 0. Si Windows informa falta de confianza, el mensaje indica importar primero la parte pública `BayStream.cer` en «Personas de confianza» del equipo local; el script no la importa.

## 7. Entrega y horas

Los tres archivos se colocan juntos en el repositorio al final, tras comprobar que sus rutas no han cambiado desde la lectura inicial:

- `tool/t93_msix.ps1`.
- `test/t93_msix_config_test.dart`.
- `docs/T93-CORRECCION-RESULTADOS.md`.

No se instaló software, no se abrió BayStream y no se consultó ni modificó el almacén real o el Honor. No se usaron la CLI de Firebase, el proyecto H5 ni operaciones de escritura de Git. No se ejecutaron `git status` ni `rev-parse`.

**Horas:** 0.16 h de pared, del 15-oct-2026 11:54:58 al 12:04:35, hora de Guatemala; incluye lectura, copia, implementacion, sondas, validaciones y redaccion. Sin estimacion nueva: se carga a T-93 (10.42).

## Mensaje para Yov

Capitán corrigió T-93 según 10.42 sobre una copia exacta de 0b7f539. Una sola función exige SHA-256 coincidente, firma Valid y huella; el armado y el modo -Verificar la comparten. Las cuatro sondas reales dieron 0/1/1/1: original válido, firma HashMismatch con SHA recalculado, SHA incorrecto y otra huella. Los errores explican el motivo y muestran Status y StatusMessage. -SinCompilar terminó en 0 con la verificación en verde. Suite 685/685, T-93 5/5, analyze 0 y script ASCII. No hay pruebas nuevas, dependencias ni cambios de pubspec.*. No se instaló nada ni se tocó el almacén real o el Honor. Solo se entregan los dos archivos de código autorizados y docs/T93-CORRECCION-RESULTADOS.md. T-93 sigue En revisión para que Timonel repita las sondas con el script commiteado al entregar T-103.
