# T-114 · Reaceptación de la corrección del paquete (10.23)

**Dictamen: ACEPTADA. H1 y O1 quedan cerrados; la etiqueta de la celda del plano también pasa.**

Capitán Codex · 23-oct-2026 · `C:\Proyectos\baystream-qa-r4`.
Commit revisado: **`05dde52`**, contra su padre **`455943c`** (`HEAD~1..HEAD`).

Se revisa exclusivamente la corrección descrita en la decisión 10.23 de `SPRINT-4.md` y en «Fase 3 · Paquete · Corrección tras la aceptación de Codex» de `docs/REDISENO-RESULTADOS.md`, incluida la ampliación autorizada por Carlos para la insignia de la celda. Se leyó también `AGENTS.md` y el diff actual de los archivos de producto y pruebas. No se reabren las partes ya aceptadas del paquete ni se evalúa la travesía del inicio de 10.24.

La evidencia nueva está en **`build/t114-paquete-reaceptacion/`**; las rutas de evidencia que siguen son relativas a esa carpeta. No se modificó código, no se ejecutó Git de escritura ni `git status`, y no se usaron Firebase, el Honor ni el emulador. Los comandos de Flutter se ejecutaron uno a la vez.

## 1 · Alcance

`git diff --stat HEAD~1..HEAD` muestra **14 archivos, 2744 inserciones y 43 eliminaciones**:

- Cinco widgets del producto: `bay_plan_view.dart`, `container_search_delegate.dart`, `containers_list_view.dart`, `detalle_contenedor.dart` e `iconos_del_dominio.dart`.
- Una prueba nueva: `test/t114_paquete_correccion_test.dart`.
- `tool/t112_censos.py`, con las decisiones de los nombres añadidos.
- Siete archivos de documentación/evidencia: `DESIGN.md`, el informe de Timonel, el traspaso y los cuatro archivos bajo `docs/rediseno/fase3/paquete/correccion/`.

**Nada en `domain/`, `data/`, `lib/main.dart`, opciones de Firebase, `pubspec.yaml`, `pubspec.lock` ni los dos archivos congelados. Ninguna dependencia nueva.** No se reescribió ninguna prueba existente en este commit.

Se tomaron huellas de 521 archivos de fuentes/configuración antes y después de la revisión: **cero modificados por Codex**. El cotejo final contra HEAD tampoco muestra diferencias en `lib/`, `test/`, `tool/` ni `pubspec.*`.

Evidencia: `diff-stat.txt`, `rutas-correccion.txt`, `correccion.diff.txt`, `alcance.json`, `fuentes-antes.json`, `integridad-final.json`.

## 2 · H1: el resultado dice la condición una sola vez

Se repitió la comprobación independiente con los cuatro contenedores originales: **mismo ID `TSTU0000011`, mismo ISO `22G1` y sin puertos**, cambiando únicamente peligrosa, refrigerado, fuera de medida o vacío. Se leyó el nodo real de semántica del `ListTile`, no solo `Icon.semanticLabel`.

| Caso | Etiqueta del resultado, con saltos representados por `/` | Veces que dice el nombre |
|---|---|---:|
| Peligrosa | Carga peligrosa / TSTU0000011 / 22G1 | 1 |
| Refrigerado | Refrigerado / TSTU0000011 / 22G1 | 1 |
| Fuera de medida | Fuera de medida / TSTU0000011 / 22G1 | 1 |
| Vacío | Vacío / TSTU0000011 / 22G1 | 1 |

Son **cuatro etiquetas diferentes**, conservando ID e ISO. Se comprobó el número de apariciones del nombre, no solo su presencia. La matriz cubrió **claro y oscuro**, con la configuración de semántica de **Android e iOS** en pruebas de widgets: **16 resultados**, todos con el nombre exactamente una vez. Esto no representa una ejecución en dispositivos físicos.

El `Tooltip` tiene el mismo nombre y `excludeFromSemantics: true`; la etiqueta del glifo permanece en el árbol. Así se aporta la descripción emergente sin duplicar el nombre accesible. El marco de color queda dentro de la descripción emergente.

**Resultado: H1 corregido.** Evidencia: `comprobacion_codex_test.dart`, `comprobacion-codex.txt`, `h1-o1.json`, `semantica-verificada.md`, `comparacion-etiquetas.json`. Esta última conserva el contraste con la reproducción anterior que daba solo ID e ISO.

## 3 · O1: mismo glifo y nombre en las tres pantallas

Con los mismos cuatro contenedores se renderizaron **Lista, búsqueda y detalle**. Se tomó el ícono principal real de cada pantalla y se comprobó su código, familia, etiqueta y descripción emergente. También se verificó que el nombre llega al árbol de semántica de la Lista y del detalle.

| Condición | Lista | Búsqueda | Detalle | Nombre común |
|---|---|---|---|---|
| Peligrosa | U+E005 | U+E005 | U+E005 | Carga peligrosa |
| Refrigerado | U+E004 | U+E004 | U+E004 | Refrigerado |
| Fuera de medida | U+E006 | U+E006 | U+E006 | Fuera de medida |
| Vacío | U+E003 | U+E003 | U+E003 | Vacío |

Los doce íconos de cada combinación de tema/plataforma usan **`BayStreamIconos`**. La matriz independiente suma **48 renderizados de pantalla**: cuatro casos × tres pantallas × dos temas × dos configuraciones de semántica.

La inspección del diff confirma que las tres pantallas usan `IconoDelContenedor`, y que `condicionDelContenedor` concentra la prioridad y el nombre. La Lista ya no elige directamente el tipo para su ícono principal. El detalle lo incorpora en el título, conservando las señales y los datos existentes.

**Resultado: O1 corregido.** El requisito de nombre no duplicado de H1 se comprobó en el resultado de búsqueda; no se confunde con los textos explicativos adicionales de la tarjeta o del detalle.

Evidencia: `h1-o1.json`, `semantica-verificada.md`, `comprobacion_codex_test.dart`, `comprobacion-codex.txt`, `correccion.diff.txt`.

## 4 · La celda del plano dice su condición

Se montó **`VesselOverviewPage` real**, con un viaje sintético de cinco contenedores en la bahía 003: las cuatro condiciones y una celda corriente como control negativo. Los repositorios de pruebas son en memoria; no se abrió el almacén local real.

Se cambió el proveedor de «Colorear por» entre **Estado, Destino y Tipo de vacío** y se leyó desde el árbol de semántica la etiqueta de cada `BsCelda`. Se repitió en claro y oscuro: **30 nodos comprobados**.

| Contenedor | Condición anunciada en las tres vistas y ambos temas | Insignia real |
|---|---|---|
| TSTU0000011 | Carga peligrosa, una vez | peligrosa |
| TSTU0000022 | Refrigerado, una vez | refrigerado |
| TSTU0000033 | Fuera de medida, una vez | oog |
| TSTU0000044 | Vacío, una vez | ninguna |
| TSTU0000055 | Ninguna de las cuatro condiciones anteriores | ninguna |

Cada etiqueta conserva el número y la posición. Ejemplo observado en las tres vistas:

```text
TSTU 000001 1, 003-01-82, Carga peligrosa
TSTU 000002 2, 003-02-82, Refrigerado
TSTU 000003 3, 003-03-82, Fuera de medida
TSTU 000004 4, 003-04-82, Vacío
TSTU 000005 5, 003-05-82
```

Se exigió que cada celda diga solo su condición y que la corriente no adquiera ninguna. La insignia dibujada coincide con la condición especial. «Vacío» se anuncia también en Estado y Destino, como pide la corrección; no se inventa una insignia para el vacío.

La inspección confirma que `bay_plan_view.dart` agrega la condición a la etiqueta que expone `BsCelda`, antes de excluir la semántica interna. No depende de que un test escriba a mano esa etiqueta.

**Resultado: pasa en las tres vistas.** Evidencia: `plano-semantica.json`, `semantica-verificada.md`, `comprobacion_codex_test.dart`, `comprobacion-codex.txt`.

## 5 · Suite y análisis

| Validación ejecutada | Resultado | Evidencia |
|---|---|---|
| `flutter test --no-pub --reporter expanded` en la copia de trabajo | **1297 éxitos, cero fallos y cero omitidas**; siete más que el piso anterior de 1290 | `flutter-test.txt` |
| Diagnóstico independiente de H1/O1 y plano | **2 pruebas correctas**; no se suman al piso del producto | `comprobacion-codex.txt` |
| `flutter analyze --no-pub` sobre la extracción limpia de HEAD | **0 incidencias** | `flutter-analyze.txt` |
| `flutter analyze --no-pub lib test tool integration_test` sobre la copia de trabajo | **0 incidencias** | `flutter-analyze-producto.txt` |

Para el análisis completo se extrajo HEAD mediante `git archive` en `arbol-analisis/`, dentro de esta evidencia, y se ejecutó allí `flutter pub get` seguido de `flutter analyze --no-pub`. Así no se analizan como producto los archivos Dart de antiguas aceptaciones que permanecen en `build/`. **Las 523 fuentes/configuraciones verificadas coinciden con HEAD normalizando únicamente CRLF/LF**. No se alteró `analysis_options.yaml` del proyecto. La exclusión local dentro de la evidencia afecta solo a esa carpeta.

El primer intento del instrumento propio no cargó por un import faltante de `LocalSessionRepository`. Se corrigió únicamente el instrumento bajo `build/` y se conservó esa salida en `comprobacion-codex-instrumento-import-faltante.txt`. La ejecución final de las dos pruebas pasa. No fue un fallo del producto. Se repitió el diagnóstico al retirar los puertos de los cuatro casos de búsqueda para reproducir exactamente los originales; la matriz del plano conserva sus puertos sintéticos.

Evidencia adicional: `analisis-pub-get.txt`, `snapshot-verificacion.json`, `arbol-analisis/`.

## Entrega

Se añade un único archivo para versionar: **`docs/rediseno/fase3/paquete/reaceptacion-codex.md`**. Los instrumentos, registros, JSON y copias de lectura quedan bajo `build/t114-paquete-reaceptacion/`, ignorado por `/build/`. **Esta revisión no cambia `pubspec.yaml` ni `pubspec.lock`.** No quedan correcciones pendientes dentro del alcance revisado.

### Tres líneas

1. ACEPTADA: H1 y O1 corregidos; los cuatro resultados dicen la condición una vez y las tres pantallas comparten glifo y nombre.
2. Las celdas anuncian su condición en Estado, Destino y Tipo de vacío; suite 1297/0/0 y análisis sin incidencias.
3. Solo se añade este informe; producto y pubspec intactos, evidencia en build, sin Git de escritura, Firebase ni dispositivos.

### Mensaje para Yov

Yov: Capitán Codex reaceptó únicamente la corrección 05dde52 contra 455943c (10.23): ACEPTADA. H1: los cuatro casos originales exponen Carga peligrosa, Refrigerado, Fuera de medida y Vacío exactamente una vez desde el árbol de semántica, en claro/oscuro y configuración Android/iOS. O1: Lista, búsqueda y detalle coinciden en código, familia y nombre para los cuatro casos. La celda del plano real anuncia la condición en las tres vistas de Colorear por, comprobada en 30 nodos con control negativo. Suite 1297/0/0, dos diagnósticos propios correctos y análisis completo de HEAD limpio en cero. Alcance de 14 archivos sin áreas restringidas; no modifiqué producto ni pubspec, no ejecuté Git de escritura ni usé Firebase, Honor o emulador. Informe: docs/rediseno/fase3/paquete/reaceptacion-codex.md. Evidencia: build/t114-paquete-reaceptacion/.

### Git para Carlos

Solo el informe de esta reaceptación, por su ruta exacta:

```powershell
git add -- docs/rediseno/fase3/paquete/reaceptacion-codex.md
git commit -m "Sprint 4: reaceptacion de la correccion del paquete de iconos"
git push
```
