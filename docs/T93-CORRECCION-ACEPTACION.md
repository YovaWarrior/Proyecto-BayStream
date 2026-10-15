# Verificación de la corrección de T-93

Timonel · 15-oct-2026 · rama `sprint-3`, HEAD `842dcb8` (decisión 10.43), con la
corrección en `f52570b`.

**Veredicto: PASA.** Las cuatro sondas dan 0 / 1 / 1 / 1 con el script commiteado y
cada error dice qué falló. Queda un matiz del punto 4, que es una observación y no
bloquea: con la raíz del `.cer` fuera de los almacenes de confianza, Windows da
`UnknownError`, no `NotTrusted`, y el mensaje de «importa primero `BayStream.cer`»
no saldría.

## 1. La rama

`git log --oneline -3`: `842dcb8` (10.43), `f52570b` (la corrección de T-93) y
`3696930` (T-103). Correcto.

## 2. El cambio, contra la ficha

Solo cambian `tool/t93_msix.ps1` (+62/−12), la prueba `test/t93_msix_config_test.dart`
(+1) y el informe de Codex. Ni `lib/` ni `pubspec.*`. El script del árbol es el
mismo de HEAD (blob `c8694f7`) y está todo en ASCII (5 701 bytes, 0 bytes por encima
de 127).

| La ficha pide | El script | Cumple |
|---|---|---|
| Una sola función de verificación | `Test-PaqueteMsix -Ruta -HuellaEsperada` | Sí |
| SHA-256 igual al del `.sha256` | Lee el `.sha256`, exige una sola línea con 64 hexadecimales y compara; también falla si falta | Sí |
| `Status` igual a `Valid` | `if ($firma.Status -ne 'Valid')` | Sí |
| Firmante con la huella de `-Huella` | `Thumbprint -ne $HuellaEsperada`; sin firmante también falla | Sí |
| Error que dice qué falló, con `Status` y `StatusMessage` | Junta todos los fallos en un `throw` y añade `$detalle` | Sí |
| `HashMismatch` → paquete alterado, no se distribuye | «El paquete esta alterado o danado; no se distribuye.» | Sí |
| Sin confianza → importar `BayStream.cer` | Solo con `NotTrusted` (ver el punto 4) | Con matiz |
| El armado termina con esa función | La última línea es `Test-PaqueteMsix -Ruta $msix`; el control anterior se retiró | Sí |
| Modo `-Verificar` sin Flutter ni opciones de Firebase | Su conjunto de parámetros no lleva `-Opciones`, y retorna antes de `Set-Location`, la versión, las opciones y Flutter | Sí |
| La prueba existente exige `Valid` | `contains(r"if ($firma.Status -ne 'Valid')")`; no hay pruebas nuevas | Sí |
| Textos en ASCII | 0 bytes no ASCII | Sí |

## 3. Las cuatro sondas

Se usaron copias propias en `%TEMP%\baystream-t93-timonel\{original,bit,sha,huella}\` de
`%TEMP%\baystream-t93acc\head\build\t93\BayStream_1.0.2.0.msix` (SHA-256
`E0F94823DC7D15611866ECAC4DEF4D21DEECA8D961EEEA75F6A25AC6A0E5D3A3`, el mismo que
registró Codex) y de su `.sha256`. **Ninguna copia se instaló.**

**Cómo se corrió.** Con Windows PowerShell 5.1, en un proceso hijo
`C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -NoProfile
-ExecutionPolicy Bypass -File tool\t93_msix.ps1 -Huella … -Verificar …`.
- `PSModulePath` contenía solo `C:\Program Files\WindowsPowerShell\Modules` y
  `C:\Windows\System32\WindowsPowerShell\v1.0\Modules`.
- El hijo informó **PS 5.1.26100.9711 Desktop**, con `Get-AuthenticodeSignature` de
  `…\v1.0\Modules\Microsoft.PowerShell.Security\Microsoft.PowerShell.Security.psd1`:
  el módulo nativo, no el de PowerShell 7.
- El código es el `$LASTEXITCODE` del proceso.

| Sonda | Entrada | Código | Mensaje del script |
|---|---|---:|---|
| Original | `.msix` y `.sha256` originales, huella de Carlos | **0** | `Firma: Valid \| CN=BayStream \| 60BEF8F4D26ECF7AD25CC478E715CF9B26A278EC` · `Status: Valid. StatusMessage: Firma comprobada.` |
| Un bit cambiado | Byte 12 739 729 de 25 479 458 con XOR 0x01; `.sha256` recalculado (`5AC1E184…ACE7721`), así el SHA coincide | **1** | `Verificacion MSIX fallo: El paquete esta alterado o danado; no se distribuye. Status: HashMismatch. StatusMessage: Es posible que un proceso o usuario no autorizado haya modificado el contenido del archivo … porque el hash del archivo no coincide con el hash almacenado en la firma digital…` |
| SHA que no coincide | Original con un `.sha256` de 64 hexadecimales válidos, pero otros (`0123…CDEF`) | **1** | `Verificacion MSIX fallo: El SHA-256 del paquete no coincide con su .sha256. Status: Valid. StatusMessage: Firma comprobada.` |
| Otra huella | Original y `.sha256` correctos, `-Huella ABCDEF0123456789ABCDEF0123456789ABCDEF01` | **1** | `Verificacion MSIX fallo: La huella del firmante no coincide con -Huella. Status: Valid. StatusMessage: Firma comprobada.` |

La copia con el bit cambiado conserva `CN=BayStream` y la huella de Carlos: la detiene
la firma, no el SHA ni la huella. Mi sonda de huella usa un valor distinto del de Codex
(él usó 40 ceros). Registro completo: `%TEMP%\t93-timonel-sondas.log`.

`-SinCompilar` no se repitió: la ficha me pide las cuatro sondas, y es un comando de la
cadena de Flutter, cuyo semáforo tiene Codex.

## 4. ¿Qué estado da una raíz que no es de confianza?

**`UnknownError`, no `NotTrusted`.** Fuente: el código de PowerShell,
`src/System.Management.Automation/security/MshSignature.cs`, rama `master` del repositorio
`PowerShell/PowerShell`, función `GetSignatureStatusFromWin32Error`.
- Empieza con `SignatureStatus.UnknownError` y solo cambia en seis casos:
  - `NO_ERROR` → `Valid`;
  - `NTE_BAD_ALGID` → `Incompatible`;
  - `TRUST_E_NOSIGNATURE` → `NotSigned`;
  - `TRUST_E_BAD_DIGEST` y `CRYPT_E_BAD_MSG` → `HashMismatch`;
  - `TRUST_E_PROVIDER_UNKNOWN` → `NotSupportedFileFormat`;
  - `TRUST_E_EXPLICIT_DISTRUST` (0x800B0111) → `NotTrusted`.
- **`NotTrusted` sale solo con la desconfianza explícita**, es decir, un certificado puesto
  en «Certificados que no son de confianza».
- Una raíz que no está en ningún almacén de confianza hace que WinVerifyTrust devuelva
  `CERT_E_UNTRUSTEDROOT` (0x800B0109). Ese código no está en el `switch`, así que **el
  estado queda en `UnknownError`**. El `StatusMessage` sale del texto de Windows para ese
  código: que la cadena termina en una raíz en la que no se confía.

**Dos salvedades de la fuente:**
- La documentación del enum (`SignatureStatus`, Microsoft Learn, que se aplica también a
  `Microsoft.PowerShell.5.1.ReferenceAssemblies`) describe `NotTrusted` como «firmado por
  un editor que no es de confianza en el sistema». Eso suena al caso del `.cer`
  sin importar, pero el código no lo asigna así.
- El código consultado es el de PowerShell abierto (7.x). El de Windows PowerShell 5.1 no
  es público. `SignatureStatus` y su mapeo vienen de la misma base, y el enum es idéntico en
  el paquete de referencia 5.1, pero que 5.1 mapee igual es una inferencia, no algo que
  vi en su código. **No toqué ningún almacén de certificados para provocarlo.**

**Consecuencia para T-93.** En un equipo de COMAR sin `BayStream.cer` importado,
`-Verificar` termina **con error, como debe**, pero con «La firma no es Valid; no se
distribuye.» en vez de «Primero importe BayStream.cer…». El `StatusMessage` que se imprime
sí explica la causa. Para que salga la indicación correcta bastaría tratar `UnknownError`
igual que `NotTrusted`, o mirar el `StatusMessage`. **No lo corregí**: lo decide Yov
(10.43).

## Horas

Inicio 12:09:38, cierre 12:15 (15-oct, Guatemala): **≈ 0.10 h**. Sin Flutter, sin la app,
sin el almacén y sin el Honor. Git: solo `log`, `show` y `diff --stat --ignore-cr-at-eol`.
