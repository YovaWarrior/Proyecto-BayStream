# T-49 · Firmar y publicar el paquete Android — parte 1 (firma)

Timonel · 1-oct-2026 (noche) · Base: `b526732` · En paralelo con T-48 (Codex).

**No se tocó `lib/`, `test/` ni `pubspec.*`.** Sin dependencias nuevas. Esta parte llega hasta el
`.aab` firmado y verificado. **Falta la subida a la prueba interna de Play**, que espera la
verificación de identidad de Carlos (10.34).

`android/key.properties` no se abrió ni se leyó: solo lo lee Gradle. Ninguna contraseña aparece
en este informe, en los logs ni en el chat.

## Resultado

| Comprobación | Resultado |
|---|---|
| Firma del `.aab` | **`CN=Carlos Martinez, OU=BayStream`**, no «Android Debug» |
| `jarsigner -verify` | `jar verified.` |
| Advertencia de clave de depuración en el build | ninguna (0 coincidencias en el log) |
| `versionCode` / `versionName` | `1` / `1.0.0`, salen de `pubspec.yaml` (`1.0.0+1`), sin cambiarlo |
| `applicationId` / `namespace` | `gt.cmartinez.baystream` |
| Rama sin `key.properties` | firma con depuración y Gradle avisa con claridad; `BUILD SUCCESSFUL` |

## Certificado de subida (público)

| | |
|---|---|
| Propietario y emisor | `CN=Carlos Martinez, OU=BayStream, O=Unknown, L=Puerto Barrios, ST=Izabal, C=GT` |
| Clave | RSA de 2048 bits, firma `SHA384withRSA` |
| Válido | del 1-oct-2026 19:43 al 16-feb-2054 |
| **SHA-1** | `D7:69:20:6A:9F:7B:FF:A6:69:16:7E:1C:F9:9E:71:81:A5:8C:94:F9` |
| **SHA-256** | `4C:C0:F6:B1:E5:18:BC:5F:20:32:0D:3C:FF:D8:3B:EB:CF:4A:B9:8D:BA:EF:6A:16:93:29:65:A9:A8:30:20:C4` |

## El paquete

`build/app/outputs/bundle/release/app-release.aab` · **47 027 711 bytes**

SHA-256: **`C60FFF0C0C371CEC94F4D65ABAD83BF31303555E9686D00F2EA024E52C15679D`**

Comando, con la salida en `build/t49/build-aab.log` (terminó con código 0, en 17 s, 22:14):

```
flutter build appbundle --release --dart-define-from-file=C:\Proyectos\baystream-privado\firebase-prod.json
```

Ventana de Flutter: avisada con `SEMÁFORO:` antes y después de compilar. Antes de empezar no había
ningún comando de Flutter en curso, solo demonios de Gradle inactivos.

## Qué cambió

**`android/app/build.gradle.kts`** (+34 / −3), según la guía oficial de Flutter, *Sign the app*:

- Carga `rootProject.file("key.properties")` con `java.util.Properties` si existe.
- Crea `signingConfigs.release` con `keyAlias`, `keyPassword`, `storeFile` y `storePassword`, **solo
  si** el archivo existe.
- El `buildType` release usa `release` cuando hay clave. Si no hay `key.properties`, usa `debug` y
  Gradle imprime: *«ADVERTENCIA: no existe android/key.properties; el build release se firma con
  la clave de DEPURACION y Play lo rechazara…»*. Así los builds de desarrollo no se rompen.
- Se quitó el `TODO` de «Add your own signing config» y su comentario, que ya no aplican.

**`android/key.properties.example`** (nuevo): las cuatro claves con marcadores
`CAMBIAR_POR_…`, `keyAlias=upload` y la ruta de la clave fuera del repositorio. Sin contraseña real.

## Hallazgo: el archivo de Carlos se llamaba `key.properties.txt`

Windows ocultó la extensión (como pasó con `firebase-prod-web.txt.txt`). Con ese nombre:

1. **Gradle no lo habría visto** y habría firmado con la clave de depuración, sin avisar de otra
   cosa que la advertencia.
2. **`.gitignore` no lo cubría:** `android/.gitignore` ignora `key.properties` exacto, y
   `git check-ignore` salió con código 1. Un archivo con contraseña quedaba como candidato a
   commitearse con un `git add` descuidado.

**Qué hice:** lo renombré a `android\key.properties`, que sí está ignorado
(`android/.gitignore:12`). Fue solo un cambio de nombre: no abrí ni leí el contenido. Que su
contenido es correcto lo demuestra el resultado: Gradle abrió el almacén y firmó con el
certificado de subida. El cambio de nombre es reversible.

## Prueba de la rama sin clave

Renombré `key.properties` un instante, evalué Gradle sin compilar nada (`gradlew :app:help`, con
`JAVA_HOME` del Android Studio) y lo restauré en un `finally`. Salió la advertencia y
`BUILD SUCCESSFUL in 1s`. Salida en `build/t49/gradle-sin-key.log`. Al terminar, `key.properties`
existe y `key.properties.off` no.

## Lo que esta parte no cubre

- **La subida a Play y la instalación en el Honor desde Play**, que son el criterio de T-49.
- **Que Play acepte este certificado:** se sabrá al subir. Con *Play App Signing*, Google guarda
  la clave de firma definitiva, y esta es la de **subida**; si se pierde, se puede pedir un
  restablecimiento, pero conviene mantener el respaldo del `.jks`, que ya está en el Drive.
- **Que el `.aab` instale y arranque:** no se instaló. Falta además comprobar que arranca sin
  conexión con Firebase de producción (10.36).
- **`flutter analyze` y `flutter test` no se corrieron:** no cambió `lib/` ni `test/`, y el cambio
  es solo de Gradle.

## Archivos

Modificado: `android/app/build.gradle.kts`.
Nuevos: `android/key.properties.example`, `docs/T49-RESULTADOS.md`.
**Nunca** `android/key.properties` ni `upload-keystore.jks`.
Evidencia sin versionar en `build/t49/`.
