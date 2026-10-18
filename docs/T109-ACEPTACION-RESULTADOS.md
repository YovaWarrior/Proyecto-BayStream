# T-109 · Aceptación cruzada de Estadísticas a 360 dp con letra grande y del guion de «re‑estibas» — resultados (Timonel)

**Dictamen: ACEPTADA, con observaciones.** Pasan todos los criterios de «Terminada cuando» que se pueden revisar sin el Honor. A 360×780 dp, con letra 1.0, 1.45 y 2.0, la vista no se desborda y conserva todos sus textos y cifras. A 1280 dp queda igual, píxel por píxel. **El Honor (360 dp y letra 2.0) queda pendiente** hasta que Carlos lo permita; hoy no se usó. Las observaciones están en la sección 7; ninguna es un defecto que impida aceptar.

## 1. Qué se aceptó y sobre qué base

- **Lo entregado por Codex:** `32d9288` (6 archivos). HEAD al aceptar: `2638072`, rama `sprint-3`.
- **Las copias son las mismas que en la aceptación de T-108** (`docs/T108-ACEPTACION-RESULTADOS.md`, sección 1):
  - la de HEAD, `%TEMP%\baystream-t108acc-2638072\head`, con 681 archivos de `git archive` verificados byte a byte;
  - la del padre, `...\base`, de `25b3efd`, sin T-108 ni T-109, a la que solo agregué `test/t109_stats_test.dart` para capturar la referencia de 1280 dp, y mi banco.
- **Sobre el trabajo a medias de T-99:** no lo encontré en el árbol (`pubspec.*` coincide con HEAD; no hay `integration_test/` ni `*t99*`). No toqué nada del árbol salvo los dos informes.
- **No se tocó `lib/`.** Sin Firebase, sin git de escritura, sin demo17, sin el almacén real y sin «PRUEBA T-105».

## 2. Los criterios de «Terminada cuando»

| Criterio | Resultado | Evidencia |
|---|---|---|
| **El diff solo toca su carril** | **PASA** | `voyage_stats_view.dart`, `privacy_policy.dart`, `web/privacidad.html`, `test/t109_stats_test.dart` y su informe; además `tool/t109_main.dart`, el banco, que `AGENTS.md` permite como `tool/<tarea>_*`. Ni las reglas, ni el modelo, ni el codec, ni `pubspec.*`, ni `lib/main.dart` (sección 3) |
| **Pruebas de widget a 360×780** con A07 y letra 1.0, 1.45 y 2.0: sin desbordes, con todos los datos | **PASA** | Pasan con A07 dentro de la suite (994/994). En el padre, las mismas tres fallan con desbordes de hasta 825 dp: el control negativo funciona (sección 4) |
| **A 1280 dp, igual que antes** | **PASA** | Mi referencia, capturada en `25b3efd`, y la de HEAD coinciden en los 5 cuadros RGBA y en la extensión (1900 dp). Los dos desbordes previos de 10.84 aparecen igual en el padre y no cuentan contra T-109 (sección 4) |
| **La política con U+2011,** y `web/privacidad.html` igual a la fuente | **PASA** | Un solo cambio en cada archivo: `re-estibas` pasa a `re‑estibas` (E2 80 91), y nada más. La prueba compara el HTML con el generador (sección 5) |
| **Windows y Chrome, con `t109acc`** | **PASA. El Honor, PENDIENTE** | A07 a 1280, y a 360 con 1.0, 1.45 y 2.0, recorrido completo: sin cortes y con las cifras completas. El padre, a 360 y letra 2.0, parte «Llenos» letra por letra (sección 6) |
| **Validaciones:** piso + nuevas, `analyze` 0 | **PASA** | Suite 994/994, `analyze` 0 y corpus 168/168, en la misma copia y con las mismas corridas que T-108 |

## 3. El diff

`git diff bc7d82a 32d9288` toca exactamente las 6 rutas declaradas por Codex. **En la vista:**

- **Todo lo compacto depende de `_compactStats`,** que es un ancho de pantalla menor de 600 dp:
  - las métricas pasan a una columna con letra grande (más de 14 px sobre 12);
  - el pastel apila el gráfico y la leyenda;
  - la leyenda pone la cifra debajo de la etiqueta con letra grande;
  - la carga especial se apila;
  - las barras horizontales separan etiqueta, cifra y barra;
  - el perfil longitudinal va en un desplazamiento horizontal;
  - los dos gráficos de bahías ganan alto y eje.
- **`_SectionTitle`** envuelve el título en `Expanded`, que en pantalla ancha no cambia nada visible.
- **`_StatsLabel`** da a cada etiqueta de barra su texto completo en `Semantics`, un `Tooltip` y un diálogo «Detalle» a un toque. **También se usa en la rama ancha** (observación 7.1).
- **Los números:** en la leyenda y en las barras compactas van en `FittedBox(scaleDown)` con una sola línea. No se recortan; si no caben, se achican (observación 7.3).
- **Sin datos quitados:** la vista compacta muestra los mismos textos y cifras que la ancha, como exige la prueba de inventario.

## 4. Las pruebas y la referencia de 1280 dp

**La referencia del padre la capturé yo.** En la copia de `25b3efd` corrí `test/t109_stats_test.dart` con A07 y `T109_CAPTURE_BASELINE=true`:
- **La prueba de 1280 dp pasó** y escribió `wide-baseline.json`, con 5 hashes RGBA y una extensión de 1900 dp.
- Registró las dos incidencias previas, «A RenderFlex overflowed by 8.0 pixels on the bottom», con la fuente de pruebas. Son las de 10.84.
- **Las otras 5 fallaron en el padre, como deben:**
  - las tres de 360 dp, con desbordes a la derecha de 6.9 a 825 dp y abajo de 7.2 a 80 dp;
  - la de la etiqueta larga;
  - y la de la política.
- **Mi referencia coincide hash por hash con la de Codex** (`visual-reference\wide-baseline.json` de su TEMP).

**En la copia de HEAD,** la suite completa corre `t109_stats_test.dart` con A07 y contra mi referencia. Pasan las 6, y `wide-final.json` es **idéntico byte a byte** a `wide-baseline.json`: los mismos 5 cuadros y la misma extensión. La vista ancha no cambió ni un píxel.

## 5. La política

Comparé las dos versiones de cada archivo con Python, en UTF-8:

| Archivo | En `25b3efd` | En `2638072` | ¿Igual salvo el guion? |
|---|---|---|---|
| `lib/core/constants/privacy_policy.dart` | 1 `re-estibas` (U+002D) | 1 `re‑estibas` (U+2011, bytes E2 80 91) y 0 con guion normal | **Sí** |
| `web/privacidad.html` | 1 `re-estibas` | 1 `re‑estibas` (U+2011) y 0 con guion normal | **Sí** |

En los dos archivos, reemplazar ese único guion en la versión vieja da exactamente la nueva. La prueba «T109 política con U+2011 y HTML generado desde la fuente» pasa en HEAD y falla en el padre. En `lib/` y `web/` ya no queda ningún «re-estib» con guion normal fuera de comentarios.

## 6. Los clientes, con `t109acc`

El banco es el mismo de la aceptación de T-108 (`tacc_main.dart`, solo en TEMP), en su pestaña «T-109 · t109acc». Monta la `VoyageStatsView` real con A07 y la geometría propuesta, en un marco de 360, 600 o 1280 dp, con `MediaQuery` y letra 1.0, 1.45 o 2.0. Lo compilé sobre el padre y sobre HEAD para ver el antes y el después.

### 6.1 Windows

- **Almacén:** `%TEMP%\baystream-t108acc-2638072\store`, cajas `t109acc_*`. Procesos abiertos por `explorer.exe` y cerrados por PID: el padre fue el 11856, y HEAD el 22824 (su padre era `explorer.exe`, PID 22140).
- **Antes, en el padre, a 360 dp y letra 2.0:** «Llenos» y «Vacíos» se parten letra por letra junto al pastel, y el título se corta en «Distribución por Esta». Captura: `win-padre-360-letra2-leyenda-partida.jpg`.
- **HEAD a 1280 dp:** 398 contenedores, 21 bahías ocupadas, 6940.6 t, 290 llenos, 108 vacíos y 12 reefers. La composición es la misma que en el padre (`win-padre-t109-1280.jpg` frente a `win-head-t109-1280.jpg`).
- **HEAD a 360 dp con letra 2.0, de arriba abajo:**
  - las seis métricas en una columna;
  - los títulos en dos líneas;
  - la leyenda con «290 (72.9%)» y «108 (27.1%)» completas debajo de cada etiqueta;
  - tamaño 105/293 y 0 (0.0%);
  - Reefer 12 e IMO/DG 14 apilados;
  - las 7 navieras y los 6 puertos de descarga, con su cifra completa;
  - el perfil con desplazamiento horizontal;
  - y los dos gráficos de bahías, que se desplazan en horizontal hasta la bahía 31.
  - Ningún texto cortado ni cifra perdida.
- **Con letra 1.45 y 1.0,** lo mismo, y con 1.0 las métricas vuelven a dos columnas.
- **Al tocar la etiqueta «GTSTC»** se abre «Detalle» con el texto completo.
- **Capturas:** `win-head-360-letra2-leyenda.jpg`, `win-head-360-letra2-graficos.jpg`, `win-head-360-letra145-graficos.jpg`, `win-head-360-letra1-arriba.jpg` y `win-head-360-detalle-etiqueta.jpg`; el recorrido completo, en `evidencia\todas\`.

### 6.2 Chrome

- Mismo origen local que en T-108 (`127.0.0.1:8828`), con el build de HEAD y la caja `t109acc_*` en IndexedDB.
- **A 1280 dp:** las mismas cifras y la misma composición.
- **A 360 dp con letra 2.0,** recorrido completo: igual que en Windows, sin cortes. **Con 1.45:** los gráficos de bahías también.
- Chrome se mantuvo visible. Cerré la pestaña propia y detuve el servidor por PID.
- **Capturas:** `web-head-t109-1280.jpg`, `web-head-360-letra2-leyenda.png`, `web-head-360-letra2-barras.png`, `web-head-360-letra145-borde-157.png` y `web-head-360-letra145-1575-completo.png`.

## 7. Observaciones (ninguna impide aceptar)

1. **La etiqueta de barra también es táctil en la vista ancha.** `_StatsLabel` se usa en la rama de 600 dp o más (`voyage_stats_view.dart:839`). Los píxeles a 1280 dp no cambian (sección 4), pero en Windows y en la Web ahora hay un tooltip al pasar el mouse y un diálogo «Detalle» al hacer clic. La ficha dice «la vista queda como hoy». Lo veo como una mejora inofensiva, pero **lo decide Yov:** si la regla es estricta, el `_StatsLabel` de la rama ancha vuelve a ser un `Text`.
2. **En los gráficos desplazables, una cifra puede quedar a medias en el borde.** A 360 dp y letra 1.45, la barra de la bahía 14 mostraba «157» en el borde derecho del gráfico de peso; al desplazarlo se lee **1575** completo. Es el borde del desplazamiento, no un recorte del layout. Con la vista quieta, el eje «788t» también puede quedar pegado a la cifra de la primera barra visible. Va al rediseño (10.80).
3. **Las cifras se achican en vez de cortarse.** `FittedBox(scaleDown)` (`voyage_stats_view.dart:457` y `:808`) cumple con «los números no se recortan». Con A07 no vi ninguna cifra achicada a 360 dp, pero con etiquetas más largas una cifra podría verse más chica que su letra. Va al Honor, para mirarlo con letra 2.0.
4. **A 1.45, las tarjetas de métricas quedan altas,** con aire bajo la etiqueta. Es cosmético.
5. **El desborde previo de 1280 dp (10.84)** se reproduce en el padre con la fuente de pruebas (2 × 8.0 dp). No cuenta contra T-109, como decidió Yov.
6. **Mis tropiezos de proceso,** los mismos de T-108 (sección 6.3 y 7 de ese informe): el `flutter --version` sin luz verde, el primer build de Windows sin metadatos de plugins y el primer banco Web que no leía A07. Ninguno afecta lo medido.
7. **El Honor, pendiente.**

## 8. Evidencia

En `%TEMP%\baystream-t108acc-2638072\`:
- `ref\wide-baseline.json` (el padre) y `ref\wide-final.json` (HEAD), idénticos, y `ref\head-1280-*.png`;
- `logs\f0-base-ref.txt` (el control negativo en el padre), `f1-suite.txt` y `f2-analyze.txt`;
- `evidencia\` con las capturas con nombre, y `evidencia\todas\` con todas.

Nada de esa carpeta entra al repositorio.
