# T-128 · La candidata 0.4.1 — resultados

Timonel (Claude Opus 5.5), 29-oct. Decisiones: 10.74, 10.77, 10.79 y 10.80 de
`SPRINT-4.md`. Los registros están en `build/t128/`.

## 1. Punto de partida

- `git log --oneline -3` al empezar: `cce3c4c` (T-127), `65db312` (10.79) y
  `cf7cf3f` (10.78). Durante la tarea, Yov subió `c628068` (10.80) encima,
  con `SPRINT-4.md` y `docs/piloto/LISTA-PILOTO.md`.
- En el árbol solo había lo esperado: esos dos archivos, que Yov estaba
  escribiendo; `test/t114_fase3_correccion_test.dart` y tres archivos de
  `windows/flutter/`, que solo difieren en el fin de línea; y las carpetas sin
  seguimiento de `docs/t117/entrega1/`. No toqué ninguno de ellos.

## 2. El cambio

`pubspec.yaml`, dos líneas y nada más (`build/t128/diff-pubspec.txt`):

| Línea | Antes | Ahora |
|---|---|---|
| 4 | `version: 0.4.0+6` | `version: 0.4.1+7` |
| 121 | `msix_version: 0.4.0.0` | `msix_version: 0.4.1.0` |

El archivo conserva CRLF. **`pubspec.lock` no cambia:** su SHA-256,
`d43dbd7c…98472bbf`, es el mismo antes de editar, después de editar y al
terminar las tres validaciones (`antes-`, `despues-edicion-` y
`final-sha256.txt`). Al final, `git diff --stat` muestra solo `pubspec.yaml`.

## 3. Otros lugares que podrían fijar la versión

Busqué fuera de `docs/` en `lib/`, `test/`, `integration_test/`, `tool/`,
Gradle, el runner de Windows y `web/` (`build/t128/busqueda-version.txt`):

- **Gradle:** `versionCode = flutter.versionCode` y
  `versionName = flutter.versionName`. Salen del pubspec.
- **Runner de Windows:** `CMakeLists.txt` y `Runner.rc` usan `FLUTTER_VERSION*`,
  que Flutter toma del pubspec. El `1.0.0` de `Runner.rc` es el respaldo de la
  plantilla, para cuando Flutter no la define.
- **`web/`:** `index.html` y `manifest.json` no llevan versión. `version.json`
  lo genera la compilación.
- **Dart y pruebas:** solo comentarios que nombran «la 0.4.0» o «la 3.2.0» como
  el cliente viejo. Se quedan como están. La prueba de T-93 lee la versión del
  pubspec desde 10.77.
- **Un hallazgo, sin tocar:** `tool/t93_msix.ps1` declara
  `[string]$Version = '1.0.0.0'` (línea 19) y lo pasa a
  `dart run msix:create --version`, que manda sobre el `msix_version` del
  pubspec.
  - Hoy no hace daño: la sección 4.2 de la lista del piloto llama al script con
    `-Version 0.4.1.0`.
  - Pero corrido sin `-Version`, arma un `BayStream_1.0.0.0.msix`. Instalado
    eso, Windows ya no acepta una 0.4.x encima sin desinstalar.
  - Lo propongo como observación P3 (O-128-1). Hay dos arreglos posibles: que el
    script lea `msix_version` del pubspec, o que `-Version` sea obligatorio.
    Lo decide Carlos.

## 4. Validaciones

Con la luz verde de Carlos, después de que Codex terminara en `qa-r4`. Corrió
un comando a la vez, cada uno con su aviso «SEMÁFORO:».

| # | Comando | Resultado | Registro |
|---|---|---|---|
| 1 | `flutter test test/t93_msix_config_test.dart` | 5 de 5, «All tests passed!» | `01-t93.log` |
| 2 | `flutter analyze lib test integration_test` | «No issues found!» | `02-analyze.log` |
| 3 | `flutter test` (una corrida) | «+1871: All tests passed!», en 2:35; ninguna fallida ni omitida | `03-suite.log` |

La suite cumple el piso de 1871 de 10.79.

No compilé la candidata ni abrí la app: la compilan Codex en la aceptación y
Carlos al publicar.
