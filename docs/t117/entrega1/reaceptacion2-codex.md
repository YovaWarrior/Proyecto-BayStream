# PASA — Segunda reaceptación de T-117 y T-118, entrega 1, H4

Capitán Codex · 25 de octubre de 2026 · decisiones 10.44 y 10.45.

**H4 queda cerrado.** En Windows, «Acciones» tiene nombre único, rol de botón y activación por UIA, tanto con ícono como con rótulo y con la cuenta del distintivo. MSAA coincide. El resumen del teléfono también es un botón operable. **No se encontraron hallazgos nuevos.**

## Candidata y alcance

HEAD separado **`09494881788584caab7d175f88f68374a23cf4e1`**, decisión 10.45; base **`916bf2b`**. `git log --oneline -3` devolvió `0949488`, `6de49aa`, `41f458d` (`historial.txt`).

Se leyeron AGENTS, 10.44–10.45, «Corrección 2 de la entrega 1», DESIGN 13.11 y 14.8, y los cuatro diffs de `lib/`, `test/` y `tool/`. En producto solo cambian `loading_plan_controls.dart` y `loading_controls.dart`: la semántica de Acciones y del resumen. El catálogo y el diff completo están en `revision-codigo.json` y `diff-base.patch`.

Esta revisión se limita a H4 y al resumen. O1, O2 y O3 conservan lo decidido en 10.44–10.45. No se repitieron matriz, RNF-002 ni H1–H3; tampoco se abrieron Android, el emulador, el Honor o la Web.

La evidencia propia está en **`C:\Proyectos\baystream-qa-r4\build\t117-entrega1-reaceptacion2\`**. Las rutas siguientes son relativas a esa carpeta. `resumen.json` contiene los resultados y `manifest.json` los SHA-256, incluida la huella de este informe. El manifiesto se excluye de su propia huella.

## Windows real: H4

Banco nuevo **`%TEMP%\t117-codex-c2-0949488\copia`**, abierto mediante **explorer.exe**, namespace **`t117c2codex`**. Almacén del recorrido del producto:

`C:\Users\Giova\AppData\Local\Temp\t117-codex-c2-0949488\store-windows`

Se copiaron únicamente los datos sintéticos del banco propio anterior, con namespace distinto. El recorrido usa T100_LLEGADA publicado en GTSTC. El banco compila desde el árbol; sus **543 fuentes originales de `lib/`, `test/` y `tool/` coinciden por SHA-256** con qa-r4.

La entrada de evidencia `codex_c2_main.dart` delega en `t99_main.dart` para el producto. Añade exclusivamente un escenario aislado de Acciones para comprobar cuentas positivas, con T100_LLEGADA/T100_CARGA, datos en memoria, sin cuenta real, sin Firebase y sin persistir movimientos. Estos dos archivos de instrumentación se añadieron solo a `tool/` de la copia TEMP; están conservados en la evidencia. `lanzamiento.json` identifica el EXE, su huella y el almacén.

Se utilizó el instrumento auditado `tool/t117_correccion2_windows.ps1` para leer **UIA y MSAA**, con el conductor propio `windows_propias.py` y aserciones independientes sobre sus resultados. Todo se restringió al PID y ruta del EXE del banco. Los anchos son clientes reales, a **120 DPI**, no tamaños simulados con MediaQuery.

| Estado | Cliente dp | UIA | MSAA | Evidencia base |
|---|---|---|---|---|
| Contenido, ícono | 700 × 682,4 | botón **Acciones**, Invoke | botón de comando **Acciones** | `windows/02-700-contenido.*` |
| Descarga, ícono | 700 × 682,4 | botón **Acciones**, Invoke | botón de comando **Acciones** | `windows/04b-700-descarga-sin-tooltip.*` |
| Descarga, rótulo | 600 × 682,4 | botón **Acciones**, Invoke | botón de comando **Acciones** | `windows/06-600-descarga.*` |
| Teléfono en Windows, ícono | 560 × 682,4 | botón **Acciones**, Invoke | botón de comando **Acciones** | `windows/08-560-descarga.*` |
| Una solicitud, ícono, escenario aislado | 700 × 682,4 | botón **Acciones, 1 solicitud pendiente** | mismo nombre, botón de comando | `windows/11-cuenta-1-icono.*` |
| Dos solicitudes, rótulo, escenario aislado | 600 × 682,4 | botón **Acciones, 2 solicitudes pendientes** | mismo nombre, botón de comando | `windows/13-cuenta-2-rotulo.*` |

En cada árbol estable hay **un solo control Acciones**, su nombre contiene esa palabra una sola vez y el campo de ayuda no añade una segunda copia. Las cuentas visibles 1 y 2 se incluyen en el nombre con singular y plural correctos.

**Activación:** Invoke de UIA abrió el menú en los seis estados de la tabla. Los volcados y capturas **03, 05, 07, 10, 12 y 14** muestran sus entradas; `windows/acciones.jsonl` registra qué control se activó y con qué API. Los menús se cerraron con Esc sobre el banco, sin activar «Cerrar» de la barra de título.

**Tooltip con el mouse:** aparece «Acciones» en la variante con ícono de 700 dp, con rótulo de 600 dp, en el teléfono de 560 dp y en los dos escenarios de cuenta. Capturas `windows/*-tooltip.png`. El nombre accesible del botón permanece en su etiqueta; no se exige que la descripción emergente forme parte de ese nodo.

`verificacion-nativa.json` conserva las seis comprobaciones de nombre/rol/Invoke en ambos árboles, los menús y las del resumen.

## El resumen del teléfono

**PASA a 560 dp en Windows.** Recogido, UIA lo expone como botón con el texto del resumen y «Ver el resumen completo», e Invoke lo abre. Abierto, «Recoger el resumen» es botón e Invoke lo recoge. MSAA informa botón de comando en ambos estados. Las instrucciones aparecen una vez en el nombre correspondiente.

Evidencia: `windows/08-560-descarga.json`, `09-560-resumen-abierto.json`, sus capturas y las activaciones del registro. Mi prueba de widgets también verifica rol, acción semántica y ambas transiciones a 560 dp.

## Comparación con mis árboles anteriores

`comparar_arboles.py` compara los archivos solicitados de la primera reaceptación con los nuevos. Se normalizan espacios, identificadores y geometría; el tipo genérico que Sky llamaba «grupo» se equipara al tipo sin nombre localizado del instrumento actual, confirmado como agrupación en MSAA. Se excluye únicamente la envoltura nativa `FLUTTERVIEW` y la anotación del valor del deslizador que el nuevo instrumento no vuelca como nombre.

| Antes | Ahora | Diferencias de nombres/roles del producto |
|---|---|---|
| `windows-real/18-h3-700-semantica.json` | `windows/02-700-contenido.json` | Se añade **botón Acciones** |
| `windows-real/24-600-acciones-con-rotulo.json` | `windows/06-600-descarga.json` | **texto Acciones. Acciones** pasa a **botón Acciones** |

**Los demás nombres y roles, y su orden, son idénticos** en ambas comparaciones. Resultado reproducible en `comparacion-arboles.json`. Los archivos históricos no tienen un volcado MSAA independiente; la comparación histórica utiliza el árbol que contienen y los dos lectores nativos actuales se validan por separado. Para el resumen de 560 dp se contrastaron el diff y los estados actuales recogido/abierto, además de la prueba propia; no se inventa un árbol histórico de ese ancho.

## Pruebas propias, suite y análisis

Mi `nombre_acciones_test.dart` se ajustó a **10.45**: comprueba etiqueta, rol de botón, acción de toque, nombre único y tooltip con un mouse real de WidgetTester. **Ya no pide `tooltip: Acciones` dentro del nodo.** Las nueve pruebas propias cubren:

- 700 dp en Contenido y Descarga, 600 dp con rótulo y 560 dp como teléfono: semántica, apertura del menú por acción semántica y tooltip por hover;
- una y dos solicitudes pendientes, con ícono y con rótulo: distintivo visible y nombre completo sin repetición;
- resumen a 560 dp: botón con acción semántica que abre y recoge, con su instrucción una sola vez.

Todas usan fuentes reales y T100_LLEGADA/T100_CARGA. Los datos de solicitudes son sintéticos y permanecen en memoria. Resultados: `propias.jsonl` y `widgets-resultados.json`.

| Validación | Resultado propio |
|---|---|
| Suite completa, **una sola ejecución** | **1685 aprobadas, 0 fallidas, 0 omitidas**, 113,024 s; piso 1677 |
| Pruebas propias | **9/9**, sin omitidas, 5,652 s |
| `flutter analyze --no-pub`, copia limpia | **0 incidencias**, salida 0, 15,9 s |
| Compilación propia Windows release | Salida 0, 165,7 s |

La suite corre en qa-r4 y el análisis en la copia limpia, antes de añadir las entradas propias del banco. No se repitió la suite ni hubo reintentos u omitidas. Los logs y códigos de salida están en `suite*`, `propias*`, `analyze-banco*` y `build-windows*`. Los avisos MSB8029 de compilar en TEMP se conservan en el log.

Dos incidencias del instrumento quedan registradas: el primer volcado produjo JSON, pero el registro propio falló al serializar un `WindowsPath`; se corrigió solo ese registro. Otro volcado se tomó con el tooltip todavía visible tras el hover, por lo que incluía un nodo de texto del tooltip además del botón. Se apartó el mouse para leer los árboles estables. **El nombre del botón no estaba repetido**; no se confunde un tooltip visible separado con un nombre duplicado del control. Ambos registros iniciales se conservan.

## Integridad y entrega

Las **628 huellas iniciales** siguen intactas y no hay fuentes nuevas fuera de la evidencia. `domain/`, `data/`, **pubspec.yaml y pubspec.lock**, `lib/main.dart`, los dos congelados y `docs/piloto/LISTA-PILOTO.md` no cambian contra `916bf2b`. El diff revisado tiene cuatro rutas: dos de producto, una prueba y un instrumento. Los bancos quedaron cerrados; el almacén del producto se mantuvo en TEMP.

Archivos escritos en qa-r4: **`docs/t117/entrega1/reaceptacion2-codex.md`** y los archivos propios enumerados en **`build/t117-entrega1-reaceptacion2/manifest.json`**. No se corrigió producto, no hubo escrituras de Git ni publicaciones. **El informe no se añade a Git; Carlos lo mueve al rediseño.**

## Mensaje para Yov

Yov: segunda reaceptación **PASA**. H4 cerrado en UIA y MSAA a 700, 600 y 560 dp; nombre único, cuenta del distintivo, activación y tooltip comprobados. El resumen del teléfono es botón y funciona. Solo cambia Acciones en los dos árboles históricos comparados. Suite única 1685/1685, propias 9/9 y analyze cero. Sin hallazgos nuevos; O1–O3 conservan lo decidido. Producto intacto; informe y evidencia con SHA-256 listos.

ALTO: Carlos decide
