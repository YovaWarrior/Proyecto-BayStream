# T-99 · Aceptación cruzada de la Fase B

Capitán Codex · 21-oct-2026 · Rama `sprint-3` · Entrega de Timonel `d2910ff`.

**Dictamen: ACEPTADA con observaciones.** Se sostienen los cuatro dictámenes globales
de **no cumple**. La aceptación valida las mediciones y sus límites; no declara que
el producto cumpla los RNF. Las salvedades de documentación, de anchos y del
instrumento de PowerShell se detallan abajo. No se corrigió el producto ni el informe
de Timonel.

## 1. Base y aislamiento

- `git log --oneline -3` mostró `8ee8144`, con las decisiones 10.104 y **10.105**,
  seguido de `b19744a` y `0cb1c48`. Se cumplió la condición de entrada de Carlos.
- Se leyeron `AGENTS.md`, las fichas y decisiones solicitadas de `SPRINT-3.md`,
  `T63-CRITERIOS-RNF.md`, las decisiones de T-63 y la Fase B de `T99-RESULTADOS.md`.
- Copia nueva en `%TEMP%\t99acc-33404a5-21oct\app`, mediante `git archive` de
  `sprint3-cierre-2`: **33404a5804be4fad85aab80dd923a7ae9e878ee9**. Sus **745 archivos**
  se cotejaron por hash de blob con el árbol Git: **0 diferencias** antes de preparar
  el banco. No se copió el trabajo sin commit del árbol.
- Se tomaron del commit `d2910ff` los instrumentos de Fase B necesarios. Solo en la
  copia, el namespace de los almacenes y el nombre de la app de Firebase pasaron a
  **`t99acc`**, y `pubspec.yaml` declaró los assets de prueba. Se agregó al conductor
  una espera por archivo para iniciar el recorrido después de maximizar la ventana.
- Almacén efectivo: **`%TEMP%\t99acc-33404a5-21oct\store-b`**, namespace `t99acc`.
  No se abrió ni se contó el almacén real. Firebase se inicializó únicamente para
  la RAM, con su configuración por ruta privada, en la app aparte y sin sesión;
  el arranque conserva el guard que detiene la app si encuentra un usuario.
  Esto no es una comprobación de cero tráfico de RNF-004.
- Windows 11 Home, compilación 26300; Flutter **3.38.9**, Dart **3.10.8**. Producto
  release abierto mediante `explorer.exe` y cerrado por PID. Sin otra BayStream,
  emulador ni otro comando de Flutter durante los muestreos.
- Los **12 entornos propios** de RAM registran ventana maximizada, pantalla
  **1920×1080**, escala **125 %**, cliente **1920×991 físicos**. La escala recomendada
  del monitor activo tiene `DpiValue=0`. Los **24 entornos originales** de Timonel
  también tienen esas cuatro condiciones.
- Los **137 archivos de `lib/` de la copia** siguen iguales al cierre. Un cotejo de
  **266 huellas protegidas del árbol de trabajo** dio 0 diferencias: incluye `lib/`,
  `test/`, `pubspec.*`, los acuerdos y la configuración local protegida.

## 2. Auditoría de la evidencia de Timonel

La evidencia original se consultó en `%TEMP%\t99-fase-b-33404a5\`. Se inventariaron
404 archivos de resultados, resúmenes y capturas con sus hashes. No se sustituyó
ninguna corrida original por una propia.

| RNF | Evidencia contrastada | Resultado de la revisión |
|---|---|---|
| 001 · Rendimiento | CSV de RAM de Windows y Honor; los seis JSON de tiempos de `rendimiento-b`; resúmenes con y sin traza | El recálculo de RAM reproduce las cifras publicadas. Regenerar los seis resúmenes desde sus JSON produce CSV **idénticos byte por byte**. RAM, tablero, navegación del Honor y scroll de Lista del Honor con 5000 sostienen **no cumple** |
| 007 · Escalabilidad | RAM y tiempos de A06, 5000 y 10000; `modulos/modulos.json`, fuentes del módulo y registro de análisis | La curva y las cifras concuerdan. Retrospectivo: T-85 toca 5 existentes, T-95 1, T-96 2 y T-73 8. Prospectivo: 1 existente para enganchar el módulo. Con umbral 0 y los límites de RNF-001, **no cumple** |
| 005 · Mantenibilidad | Clasificación documental, imports, registro de `analyze` y eventos de reconstrucción | Se verifican 225 sin documentar de 549, 11 dependencias de presentación hacia datos y el registro «No issues found!» de 14.0 s. Los cinco chips reconstruyen la rejilla y sus hijos; la búsqueda registra 134/133/133 reconstrucciones, solo en el buscador, con Lista montada. **No cumple** por documentación y capas |
| 003 · Portabilidad | Código compartido, capturas de Windows/Web, recorridos y límites de B.7/B.8 | 25784 líneas compartidas de 26081: **98.86 %**. Las capturas muestran la superposición a 360 y 600 dp. Windows 10 sigue **no probado**, no se sustituye por Windows 11. El criterio responsivo sostiene **no cumple**, con la observación de los dictámenes positivos de anchos |

La RAM original recalculada, estable mediana / máximo en MB del SI, fue:

| Cliente | A01 | 5000 | A06 | 10000 |
|---|---:|---:|---:|---:|
| Windows | 466.3 / 473.8 | 1854.5 / 1856.8 | 363.3 / 400.8 | 3580.8 / 3588.0 |
| Honor | 454.8 / 455.3 | 1520.8 / 1536.3 | No medido | No medido |

**Sesgos y ausencias conservados:**

- **10.97:** los tiempos de Windows salen del arnés sin redimensionar, con
  **1582×853 físicos / 1266×682 lógicos**, aproximadamente 71 % de la superficie del
  producto maximizado. Según esa decisión, sus «no cumple» son firmes y los
  «cumple» conservan la advertencia; no se extrapolan a una ventana mayor sin ella.
  La ventana corrida al redimensionar es un defecto del **arnés**, no del producto.
- **10.86:** la RAM se dictamina con el **producto release maximizado**, inicializando
  Firebase aparte y sin sesión. El scroll se dictamina con **FrameTiming sin traza**;
  el build inflado por `traceAction` queda como referencia.
- En el Honor faltan las cinco trazas del tablero de A01, dos del tablero de 5000
  y una búsqueda de cada archivo. Los resúmenes conservan «sin dato». El tablero
  usa las cinco lecturas completas sin traza: 2205.9 y 12038.7 ms, por encima de 1 s.
- La corrida con T-98 abierta y las ventanas mal dibujadas están descartadas.
  Se preservan las salvedades del asset frente al selector nativo, de `SendKeys`,
  de las reconstrucciones sin la interfaz de DevTools y de los tamaños no probados
  en el Honor. No se repitió aquí la batería completa ni el Honor.

## 3. Repetición independiente de una fila de cada RNF

### 3.1 RNF-001 · RAM de A01 en Windows

Se regeneró y comprobó la carga de 5000 con el lector del cierre, y A01 se tomó por
su hash, sin modificarlo:

- A01: **977 contenedores**, SHA-256
  `3d793f8056a3d8b96140e681b6c468ea49922658afdea4f7416a169a60a8ce5b`.
- Sintético: **5000 contenedores**, 5000 posiciones únicas, geometría suficiente y
  cero avisos. SHA-256
  `1af59932dc36620ec0206d311c5843d0f617cd10fac400f3f642d589700f2224`.

El escenario de T-63 fue completo: cargar, Plano, todas las bahías, Estadísticas,
buscar un ID y volver a Lista. Carga desde asset, declarada. Se recorrieron las
**34 bahías de A01 y las 72 del sintético**, sin chips faltantes.

Por archivo: un proceso nuevo por corrida, una primera corrida descartada y cinco
válidas; cinco lecturas de `WorkingSet64`, separadas 0.5 s, después de al menos
cinco segundos de reposo por paso. Se guardó también inicio, excluido del pico.
El control independiente del CSV encontró **420 lecturas**, **84 grupos de cinco**,
**0 lecturas fuera de su paso** y reposo mínimo hasta la primera de **5.03 s**.
La pausa del conductor fue de 12 s con A01 y de 9 s con 5000; ninguna altera el
reposo mínimo del muestreador. MB = 10⁶ bytes.

| Fila repetida | Estable mediana | Estable máximo | Pico mediana | Pico máximo | Umbral | Dictamen de la fila |
|---|---:|---:|---:|---:|---|---|
| RNF-001 · A01 | 551.1 MB | 556.1 MB | 551.1 MB | 556.2 MB | < 200 MB | **No cumple** |
| RNF-007 · 5000 | 2059.9 MB | 2087.6 MB | 2059.9 MB | 2127.0 MB | < 200 MB, criterio 7.1(a) | **No cumple** |

Las cinco medianas estables de A01 fueron 556.1, 551.1, 553.2, 550.5 y 536.3 MB;
las de 5000, 2059.9, 2051.7, 2059.4, 2080.2 y 2087.6 MB. Las primeras descartadas
dieron 528.2 y 2046.0 MB estables. **Se reproduce el dictamen, no la magnitud exacta
de Timonel**: mis medianas son mayores que 466.3 y 1854.5 MB. No se determinó la
causa de esa diferencia ni se reemplazó su serie por esta.

Los hashes completos de exe y `data/app.so` de cada compilación están en
`build/t99acc/mediciones.json`. La huella de `app.so` de A01 es
`c395f4f142eedb7cbb2e4cfef9ab67b8e713ccaa467d206e909336b33eb906d3`.

### 3.2 RNF-007 · RAM de 5000

La segunda fila de la tabla anterior es la repetición del punto de capacidad de
5000, generada nuevamente con `tool/t99_sintetico.dart` sobre la copia limpia.
El archivo coincide con el hash original y el umbral es el de RNF-001, según
7.1(a). Sus cinco corridas válidas incumplen. No se infiere de esta repetición un
resultado nuevo para A06, 10000 ni para el Honor.

### 3.3 RNF-005 · Capas, con un método propio

Un script Python independiente recorrió los Dart de `lib/`, resolvió cada URI
`package:baystream/` y relativa a una ruta canónica, y clasificó ambos extremos por
sus segmentos `domain`, `data` y `presentation`. Revisó `import` y `export`;
excluyó `*.g.dart` —no había ninguno—. El dominio no puede depender de Flutter,
datos o presentación, y presentación no puede depender de datos.

**137 archivos: 46 dominio, 28 datos, 52 presentación y 11 otros.** Resultado:
dominio **0**; presentación → datos **11**, en **7 archivos**:

| Archivo bajo `lib/features/vessel/presentation/` | Dependencias prohibidas |
|---|---:|
| `pages/departure_baplie_page.dart` | 1 |
| `pages/vessel_overview_page.dart` | 2 |
| `providers/export_list_providers.dart` | 1 |
| `providers/movement_log_provider.dart` | 1 |
| `providers/sync_providers.dart` | 1 |
| `providers/vessel_providers.dart` | 3 |
| `providers/voice_recognizer_provider.dart` | 2 |

El detalle de URI y línea está en `mediciones.json`. Con umbral **0**, la fila
**no cumple**, coincidiendo con Timonel. No se modificó ninguna dependencia.

### 3.4 RNF-003 · Windows a 360 dp

Otra compilación release, sin Firebase, con el mismo producto, namespace y almacén,
ejecutó el conductor de anchos con **360×800 lógicos**. Es un área impuesta mediante
constraints y `MediaQuery` dentro de la ventana de Windows, como el instrumento
de Timonel; no se presenta como una pantalla física de 360 píxeles. Se revisaron
las cuatro capturas nuevas: Lista, Plano, Estadísticas y búsqueda.

**Resultado: no cumple 3.3(a).** En Plano, «100 %» tapa el título de la bahía y la
leyenda corta «Refrigerado». El resumen de pendientes se trunca. En Lista y
Estadísticas hay acciones de la barra fuera del borde. El registro da cero errores
de Flutter, pero eso no elimina los cortes y la superposición visibles.

## 4. Observaciones para Yov

1. **Anchos amplios:** «cumple por el conductor» no demuestra por sí solo que no
   haya controles tapados; el propio zoom de 360 no fue detectado automáticamente.
   B.8 también exceptúa el desplazamiento horizontal del selector de bahías,
   aunque 3.3(a) solo exceptúa la rejilla. **No certifico los dictámenes positivos
   de adaptación completa de 840 dp en adelante bajo la lectura literal de ese
   criterio.** Las capturas originales se revisaron en hojas de contacto y no se
   vio allí otra superposición evidente, pero no se recorrió todo su contenido
   desplazable. Corresponde precisar esas filas como evidencia parcial; esto no
   cambia el «no cumple» global de RNF-003 ni pide corregir la interfaz.
2. **Denominador documental:** el instrumento cuenta 196 clases, 304 métodos,
   48 `enum` y una `extension`. Conviene explicitarlo al citar el **59.02 %**.
   Si se toman solo las categorías `clase` y `metodo`, quedan 500 declaraciones,
   206 sin documentar: **58.80 %**. En ambas lecturas se incumple el 80 %.
3. **PowerShell del muestreador:** debe fijarse **Windows PowerShell 5.1** para el
   instrumento actual. En PowerShell 7, `ConvertFrom-Json` ya produce un `DateTime`
   UTC y `[DateTime]::Parse($registro.ts)` pierde esa zona: en esta máquina una
   marca `20:28Z` pasó a `02:28Z` del día siguiente. El filtro aceptó registros de
   procesos anteriores. La corrida afectada se descartó y se repitió en 5.1,
   como el procedimiento original de Timonel. No se alteró el script versionado.
4. **Descartes propios:** la primera apertura empezó a recorrer antes de estar
   maximizada y se descartó. El conductor temporal incorporó la puerta de inicio.
   La primera corrida completa posterior es la fría descartada de cada archivo;
   el CSV final conserva solo esas dos y las diez válidas. Una apertura adicional
   detenida antes de liberar la puerta no produjo mediciones válidas.

No hay un cambio de dictamen global ni una corrección de producto solicitada por
esta aceptación. Se conservan los límites aprobados en 10.86 y 10.97, y la regla
de no corregir antes del cierre. La cabecera «en curso» de T-99 es histórica;
para esta revisión se usaron las tablas completas de B.10.

## 5. Evidencia, validaciones y archivos

**Validaciones ejecutadas:** cotejo de los 745 blobs; regeneración del sintético y
lectura exacta; regeneración de seis resúmenes originales; recálculo independiente
de CSV; comprobación propia de capas; compilaciones Windows release; dos series
de RAM completas y su sincronía; cuatro capturas propias a 360 dp; cotejos de
`lib/` y del árbol protegido. Las compilaciones dan exit 0. Se conservó la
advertencia nativa **MSB8029** por compilar en `%TEMP%`; no se tocó el proyecto para
silenciarla. No se ejecutó una suite nueva ni `flutter analyze` sobre el árbol:
el registro de análisis original fue auditado, no presentado como ejecución propia.

**Archivo versionable creado:** `docs/T99-ACEPTACION-RESULTADOS.md`.
No se modifican `pubspec.yaml`, `pubspec.lock`, `lib/`, `test/`, los acuerdos ni
los documentos originales de Timonel. No se ejecutó Git de escritura ni se usó
la consola de Firebase o se publicó nada. El Honor no se usó.

**Evidencia local creada bajo `build/t99acc/`** —ignorada por `/build/`, sin incluir
en los comandos de Git—:

- `MANIFIESTO.json`: lista exacta y hashes de los otros siete archivos;
- `mediciones.json`: las 420 lecturas, entornos, métricas, hashes de binarios,
  imports con línea y auditorías de originales;
- `ram.csv`;
- `anchos.jsonl`;
- `360x800_lista.png`;
- `360x800_bay_plan.png`;
- `360x800_estadisticas.png`;
- `360x800_busqueda.png`.

Las capturas de esta aceptación usan A01 y no forman parte del manual. Los
generadores, logs, descartes y copia completa quedan en
`%TEMP%\t99acc-33404a5-21oct\`. El banco de Windows quedó cerrado por PID al
terminar T-99; la aceptación del manual empieza después, con otro namespace.

## 6. Git para Carlos

`--only` limita el commit al informe aun si hay otras rutas preparadas en el índice.

```powershell
git add -- docs/T99-ACEPTACION-RESULTADOS.md
git commit --only -m "Sprint 3: aceptacion cruzada de T-99 con observaciones" -- docs/T99-ACEPTACION-RESULTADOS.md
git push
```

## 7. Tres líneas y mensaje para Yov

Se auditó la evidencia de Fase B y se repitió una fila de cada RNF sobre el cierre.
RAM, capas y el ancho de 360 dp confirman los incumplimientos observados.
Se documentaron límites del instrumento y del alcance de los dictámenes positivos.

> Yov: T-99 queda ACEPTADA con observaciones. Repetí A01 y 5000 en Windows
> maximizado con t99acc, Firebase aparte y sin sesión: estables 551.1 y 2059.9 MB;
> capas da 11 y a 360 dp se repite el título tapado. Los cuatro RNF siguen no
> cumpliendo. Los seis resúmenes originales se regeneran idénticos. Dejo salvedades
> sobre los «cumple» de anchos amplios, el denominador documental y el muestreador
> en PowerShell 7; el original se sostiene con su uso de 5.1. No corregí producto,
> instrumentos versionados ni tu documentación. Informe: T99-ACEPTACION-RESULTADOS.md.
