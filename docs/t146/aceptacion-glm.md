# T-146 · Aceptación de la candidata 1.0.1 (GLM 5.3 Flash, en Max)

**Aceptador:** GLM 5.3 Flash, con el esfuerzo en Max (10.137), en el papel de Capitán Codex.
**Carpeta:** `C:\Proyectos\baystream-qa-r4`, punta `268e731` («Sprint 4: decision 10.141,
T-146 entregada y revisada»). **Fecha:** 17-nov-2026, de 08:49 a 09:14 (25 minutos de reloj).
**Guion:** sección 7 de `docs/T146-RESULTADOS.md`, con los ajustes de la decisión 10.141.

## Dictamen: **PASA**

Sin hallazgos nuevos. Los siete archivos de código tienen las huellas del informe, `analyze`
da cero en la copia limpia y en el Dart versionado de esta carpeta, la suite da 2227 de 2227
en una sola corrida, el oráculo da los 4 avisos de GLM en `1c40d39` y 0 en la punta, las
pruebas del resaltado fallan 3 contra el código de antes, el resaltado se vio en el banco Web
con las dos búsquedas pedidas, el manual de la 1.0.1 está como se aprobó, y el instalador de
prueba da `5ef28b61…` con su tamaño exacto.

## Paso 0

| Comprobación | Resultado | Evidencia |
|---|---|---|
| La punta, con `git log --oneline -4` | De arriba abajo: `268e731` (10.141), `834af36` (T-146, la candidata), `f50368a` (10.140), `f8d8b49` (10.139). Como pide el encargo | — |
| `git show --stat HEAD~1` | Las 15 rutas de la sección 8.2 del informe, y ninguna más | — |
| Procesos Dart de análisis (`language-server` o `analysis_server`) al empezar | Ninguno (0 procesos) | `build/t146/glm/procesos-inicio.txt` |
| `flutter pub get --offline --enforce-lockfile` en esta carpeta | Salida 0 | `build/t146/glm/pub-get.log` |
| Entrada de T-124 copiada desde `baystream-rediseno` a `build/t124/entradas/` | Huella `d4384834fb9fc9cb…`, la esperada (O-143-3) | — |

## Los puntos de la sección 3

| Punto | Resultado | Evidencia |
|---|---|---|
| 1 · Huellas de los 7 archivos de código | Las 7 coinciden una a una con la sección 7.2 (`pubspec.yaml` `3b0fab24…`, t112 `2258a067…`, t121 `2db270a2…`, buscador `b8bf6499…`, t146 `98bda013…`, oráculo `aaf18c0a…`, `DESIGN.md` `6878c741…`). `pubspec.lock` de HEAD y de `c777c86`: la misma huella (`f45cee7b…`). Calculadas sobre los bytes de Git con `git show … \| sha256sum` en Git Bash | `build/t146/glm/huellas-codigo.txt` |
| 2 · Dos copias limpias en %TEMP% | `git archive --format=tar -o` + `tar -x -f`, sin tuberías: `%TEMP%\t146-glm-despues` (HEAD) y `%TEMP%\t146-glm-antes` (1c40d39). En las dos, la entrada de T-124 con su huella y `pub get --offline --enforce-lockfile`, salida 0 | `build/t146/glm/copia-despues-pubget.log`, `copia-antes-pubget.log`, `semaforo.txt` |
| 3a · `analyze` en la copia del después, todo el paquete | Salida 0, «No issues found!» (51.7 s) | `build/t146/glm/analyze-copia-despues.log` |
| 3b · `analyze` aquí, `lib test tool integration_test` | Salida 0, «No issues found!» (15.3 s) | `build/t146/glm/analyze-carpetas.log` |
| 3c · Repetir con `dart analyze --cache` si salía algo | No hizo falta: no salió ningún aviso en 3a ni en 3b | — |
| 4 · La suite, una sola corrida, en la copia del después | Salida 0, última línea `+2227: All tests passed!` (2 m 21 s), sin omitidas (`~`: 0 líneas) ni fallidas | `build/t146/glm/suite.log` |
| 5 · El oráculo, desde esta carpeta | Antes (`1c40d39`): salida 1, `avisosDeLaRegla: 4` — t112 49:35, 50:47 y 67:7, t121 574:14, las de GLM. Después (punta): salida 0, 0 | `build/t146/glm/oraculo-antes.log`, `oraculo-antes/resumen.json`, `oraculo-despues.log`, `oraculo-despues/resumen.json` |
| 6 · O-144-1 contra el código de antes | `+3 -3`: fallan la 1 («bysu 967»), la 3 («967 2095») y la 4 (espacio duro y tabulación); pasan la 2 (matrícula entera), la 5 (puerto) y la 6 (etiqueta accesible). La prueba se quitó de la copia al terminar | `build/t146/glm/pruebas-resaltado-en-antes.log` |
| 7 · El resaltado a la vista, en la Web del banco | **Pasa las dos búsquedas.** «mnlu 000010 7»: un resultado, MNLU0000107, matrícula entera resaltada. «ushou»: 15 resultados con «POD: USHOU» resaltado y la matrícula sin resaltar. Anfitriones de la página: solo `127.0.0.1:5939` (25 peticiones; sin sesión, no hubo llamadas al emulador); ningún anfitrión externo | `build/t146/glm/banco/` (2 capturas enteras, 2 recortes, `anfitriones-y-recorrido.txt`, `../banco-build.log`) |
| 8 · El manual | `MANUAL-USUARIO-1.0.0.md` idéntico en HEAD y `c777c86` (`3b703699…`). En el de la 1.0.1: 46 marcas y 46 rutas únicas de imagen, las 46 existen; portada «Edición de la versión **1.0.1 (10)**, para los tres clientes…», sin fecha; los pies de las figuras 1 a 4 dicen «La captura es del asistente 1.0.0.9; en la 1.0.1 solo cambia el número»; las 6 figuras de `docs/manual-1.0.1/` con las huellas exactas de la 6.4 | `build/t146/glm/manual-comprobacion.txt`, `manual-imagenes.txt`, `manual-portada-pies.txt`, `manual-figuras-huellas.txt` |
| 9 · El instalador del paso 0 (opcional) | Salida 0: `BayStream_Setup_1.0.0.9_prueba.exe`, SHA-256 `5ef28b613039b81f409b1ebb6e85b4159f45ee54a16451803b47a2f45136cf25`, 18 486 858 bytes. Con el aviso conocido de los dos archivos viejos (10.130) y «Origen verificado sin cambios» | `build/t146/glm/instalador.log`; el arte en `build/t145/glm-t146/` |

## Hallazgos

Ninguno. No hay `T146-ACC-01` ni siguientes.

Las conocidas no contaron y no aparecieron: O-146-1 no se activó (el `analyze` dio cero en
las dos carpetas, así que no hubo que repetir con caché nueva), O-146-2 y O-146-3 son anotadas,
O-143-3 se resolvió copiando la entrada de T-124, y el aviso del cierre sigue sin figura, como
dice el informe.

## Lo que no se pudo, y dos notas de instrumental

No falló nada de lo pedido. Quedan dos notas de cómo se condujo el banco, sin efecto en el
dictamen:

1. **El perfil del banco trae estado de corridas anteriores.** El primer «Seleccionar archivo»
   de `T100_LLEGADA.edi` no abrió el previo: la página cayó directo en la operación M100 que
   el perfil de Chrome del banco tenía almacenada (píldora «Cerrada», del recorrido de las
   capturas del 17-nov). Borré el almacén del navegador de ese cliente del banco
   (IndexedDB y localStorage, todo en `%TEMP%\t139\…`, nada real) y reabrí el archivo: el
   previo salió «Sin confirmar» y el recorrido siguió completo. A anotar para la próxima
   aceptación con banco: partir del almacén del navegador limpio.
2. **Dos clics cayeron bajo el pliegue** (el chip GTSTC y «Confirmar y ver el plano» estaban a
   y≈1100 con viewport de 1080): el control de T-139 cliquea en coordenadas de la vista sin
   bajar la página. Se resolvió bajando la página antes de cliquear. Es del instrumento, no de
   la app.

## Horas del reloj

Del 17-nov a las 08:49 (la primera lectura de Git) a las 09:14 (procesos-fin), unos
**25 minutos** de reloj. Ventanas SEMÁFORO una a una, anotadas en
`build/t146/glm/semaforo.txt`: pub get (08:51), pub get de las dos copias (08:52–08:53),
analyze copia (08:53–08:54), analyze aquí (08:54), suite (08:54–08:57), oráculo antes y
después (08:57–08:58), resaltado contra el antes (08:58–09:01), banco web: build, recorrido y
capturas (09:01–09:10), instalador (09:12–09:13). Nunca hubo dos comandos de Flutter o Dart a
la vez.

## Cómo trabajé

- **Modelo y esfuerzo:** GLM 5.3 Flash, con el esfuerzo en Max (10.137).
- **Desde dónde corre la consola:** la app de escritorio ZCode de Carlos, con
  `baystream-qa-r4` como proyecto (la misma de las aceptaciones anteriores de GLM, 10.139);
  no es un editor tipo VS Code. El shell de los comandos es Git Bash sobre Windows.
- **procesos-inicio.txt y procesos-fin.txt:** los dos dan **cero** procesos de Dart con
  `language-server` o `analysis_server` en su línea de comandos, al empezar y al terminar.
  Ningún otro analizador estuvo mirando estas carpetas durante la sesión.

## Lo que queda en el disco (no se borra)

- Copias limpias: `%TEMP%\t146-glm-despues` (punta, con su `pub get` y el banco compilado en
  su `build/t146/web-emu`) y `%TEMP%\t146-glm-antes` (`1c40d39`, con su `pub get`), más los
  dos `.tar` y el árbol servido `%TEMP%\t146-glm-banco`. Los puede borrar Carlos.
- `%TEMP%\t139\` quedó con las capturas crudas de esta aceptación (`acc-t146-*.png`), los
  perfiles de Chrome del banco y el estado del emulador.
- `%TEMP%\t146-cache-vacia-0108` es de Timonel (10.141); no la toqué.

## Git, para Carlos

Desde esta carpeta (`baystream-qa-r4`, con HEAD separado en la punta de `sprint-4`):

```bash
git add -- docs/t146/aceptacion-glm.md
git commit -m "Sprint 4: aceptacion de T-146"
git push origin HEAD:sprint-4
```

Nada más cambió en el árbol por esta aceptación: `build/` está ignorado y las copias de
trabajo viven en `%TEMP%`.

## En tres líneas

- La candidata 1.0.1 pasa los nueve puntos: huellas exactas, `analyze` en cero aquí y en la
  copia limpia, suite 2227 de 2227 en una sola corrida, y el instalador de prueba da
  `5ef28b61…` con sus 18 486 858 bytes.
- El arreglo de O-144-1 se vio a la vista en el banco: «mnlu 000010 7» resalta MNLU0000107
  entero y «ushou» resalta el puerto sin tocar la matrícula; el oráculo da 4 antes y 0 después,
  y contra `1c40d39` fallan justo las pruebas 1, 3 y 4.
- Sin hallazgos nuevos; dos notas de instrumental para la próxima aceptación con banco: partir
  con el almacén del navegador del banco limpio y bajar la página antes de cliquear lo que está
  bajo el pliegue.

> **Para Yov:** aceptación de T-146 en `docs/t146/aceptacion-glm.md` (qa-r4, sobre `268e731`):
> **PASA**, sin hallazgos nuevos, 25 minutos de reloj, GLM 5.3 Flash en Max. Paso 0 limpio
> (punta correcta, 15 rutas en `834af36`, sin procesos de análisis ajenos, entrada de T-124 con
> su huella). Las 7 huellas de la 7.2 coinciden; `pubspec.lock` igual en HEAD y `c777c86`.
> `analyze` cero en la copia limpia (todo el paquete) y en el Dart versionado de qa-r4, así que
> no hizo falta la repetición con `dart analyze --cache`. Suite 2227/2227 en una corrida, sin
> omitidas. Oráculo: 4 avisos en `1c40d39` (t112 49:35, 50:47, 67:7; t121 574:14) y 0 en la
> punta. Resaltado contra el antes: +3 -3, fallan 1, 3 y 4. A la vista, en la Web del banco con
> `T100_LLEGADA.edi`: «mnlu 000010 7» resalta la matrícula entera y «ushou» resalta solo el
> puerto; la página solo habló con `127.0.0.1:5939`. Manual de la 1.0.1 conforme (46 rutas,
> portada sin fecha, pies 1 a 4 con la nota del 1.0.0.9, las seis huellas de la 6.4). Dos notas
> de instrumental: el perfil del banco traía la M100 almacenada y el primer open cayó en ella
> (se resolvió limpiando el almacén del navegador del banco), y dos clics necesitaron bajar la
> página antes. La evidencia está en `build/t146/glm/`.
