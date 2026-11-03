# T-134 · La candidata 0.4.2 — resultados

Timonel (Claude Opus 5.5), 3-nov. Decisiones: 10.74, 10.81, 10.82 y 10.90 a
10.95 de `SPRINT-4.md`. Es lo mismo que hizo T-128 para la 0.4.1, que se
aceptó (10.83) pero no se publicó: la 0.4.2 la reemplaza. Los registros están
en `build/t134/`, fuera de Git.

## 1. Punto de partida

- `git log --oneline -3` al empezar: `a9bbc05` (10.95), `4b939f3` (T-133) y
  `725a74e` (la mezcla de T-131). La punta trae T-133 y la 10.95.
- En `lib/`, `test/` y `pubspec.*` no había cambios de contenido.
  `test/t114_fase3_correccion_test.dart` y tres archivos de `windows/flutter/`
  figuran como modificados, pero `git diff` no muestra ninguna línea: solo
  difieren en el fin de línea, como en T-128. Tampoco toqué las carpetas sin
  seguimiento de `docs/t117/entrega1/`.

## 2. El cambio

`pubspec.yaml`, dos líneas y nada más (`build/t134/diff-pubspec.txt`):

| Línea | Antes | Ahora |
|---|---|---|
| 4 | `version: 0.4.1+7` | `version: 0.4.2+8` |
| 125 | `msix_version: 0.4.1.0` | `msix_version: 0.4.2.0` |

```diff
-version: 0.4.1+7
+version: 0.4.2+8
@@ msix_config:
-  msix_version: 0.4.1.0
+  msix_version: 0.4.2.0
```

El archivo conserva CRLF. Lo comprobé deshaciendo las dos versiones en una
copia en memoria: sale exactamente la huella original del pubspec,
`6ffe7ced…294e72`, así que no cambió ningún otro byte.

**`pubspec.lock` no cambia.** Su SHA-256 es
`573d596ddce67833d2d1213c8a201be04c01b2e02000cbde5016fd1677202dc1` antes de
editar, después de editar y al terminar las tres validaciones, también después
del `pub get` que corre `analyze` (`antes-`, `despues-edicion-` y
`final-sha256.txt`). Es otra huella que la de T-128 porque T-129 cambió el
lock en una línea (10.90). Al final, `git diff --stat` muestra solo
`pubspec.yaml`.

## 3. Otros lugares que podrían fijar la versión

La misma búsqueda de T-128, fuera de `docs/`: `lib/`, `test/`,
`integration_test/`, `tool/`, Gradle, el runner de Windows y `web/`
(`build/t134/busqueda-version.txt`). Sale lo mismo:

- **Gradle:** `versionCode = flutter.versionCode` y
  `versionName = flutter.versionName`. Salen del pubspec.
- **Runner de Windows:** `CMakeLists.txt` y `Runner.rc` usan `FLUTTER_VERSION*`.
  El `1.0.0` de `Runner.rc` es el respaldo de la plantilla.
- **`web/`:** no lleva versión. `version.json` lo genera la compilación.
- **Dart y pruebas:** solo comentarios que nombran la 0.4.0 o la 0.4.1 como
  cliente viejo. La prueba de T-93 lee la versión del pubspec.
- **`tool/t93_msix.ps1`** sigue con `-Version '1.0.0.0'` por omisión: es
  O-128-1, que la 10.82 dejó para la tarea del banco. No la toqué. Hasta
  entonces, la lista del piloto tiene que llamarlo con `-Version 0.4.2.0`.

## 4. Validaciones

Con la luz verde de Carlos para cada comando, uno a la vez, cada uno con su
aviso «SEMÁFORO:».

| # | Comando | Resultado | Registro |
|---|---|---|---|
| 1 | `flutter test test/t93_msix_config_test.dart` | 5 de 5, «All tests passed!» | `01-t93.log` |
| 2 | `flutter analyze lib test integration_test` | «No issues found!» (42 s) | `02-analyze.log` |
| 3 | `flutter test` (una corrida) | «+2097: All tests passed!», en 2:14; ninguna fallida ni omitida | `03-suite.log` |

La suite da exactamente el piso de 2097 que dejó T-133 (10.95). `analyze` va
sobre las tres carpetas, como en T-128, porque el analizador lee los `.dart`
de `build/` (10.91).

No compilé la candidata ni abrí la app: la compila Codex en la aceptación.

## 5. Git (lo ejecuta Carlos)

```bash
git add -- pubspec.yaml
git add -- docs/T134-RESULTADOS.md
git commit -m "Sprint 4: T-134, la candidata 0.4.2"
git push
```

`pubspec.yaml` cambia; `pubspec.lock` no.
