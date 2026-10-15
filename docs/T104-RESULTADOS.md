# T-104 · Deudas del lote del 15-oct

Capitán Codex · 15-oct-2026, Guatemala · rama `sprint-3`, base `5163654` (10.38).
Alcance ampliado por 10.39: cinco suites completas en verde y clientes revisados.
En revisión para la aceptación cruzada de Timonel.

## Resultado

- `block3_corpus_test.dart` usa también una bitácora Hive temporal, compartida
  entre sus dos contenedores de providers y cerrada antes de borrar el temporal.
- En Windows, `localStoreDirectory()` lanza un `StateError` antes de consultar
  `LOCALAPPDATA` o crear carpetas si `FLUTTER_TEST=true`. El mensaje pide
  sobrescribir los dos providers con un directorio temporal. No afecta a la app
  ni a los bancos compilados, que no corren bajo `flutter test`.
- Recientes y el editor de tapas usan `operationCount`, de T-97: «1 bahía» y
  «Copiado a 1 bahía».
- El inicio explica la validación por contenido y BAPLIE 2.x; deja de enumerar
  extensiones. Reserva espacio al final para que el botón flotante no tape
  el texto inferior a 200 %. El selector y el lector de T-89 no cambian.
- Las pestañas se desplazan horizontalmente y su altura considera el tamaño
  escalado del rótulo. A letra grande en ancho estrecho, los indicadores de
  Lista y las etiquetas del contenedor disponen de todo el ancho. Los encabezados
  y los contadores pueden envolver sus elementos completos.
- Se eliminan los dos `print` de depuración de la leyenda, junto con sus
  supresiones. `rg -n '// ignore' lib` no devuelve coincidencias.
- El `LEEME` del SDK aclara que la sustitución afecta a los imports y a dos
  literales de código (`name$q` y `Logger`). Los tres módulos, la licencia y
  `provenance.json` mantienen sus cinco SHA, registrados en
  `vendor-antes-1039.json` y `vendor-despues-1039.json`.

La implementación real tiene tres pestañas: Lista, Bay Plan y Estadísticas.
Avance es una pantalla separada; se conserva su acceso y su título de T-97.
No se añade una cuarta pestaña. La prueba de las 21 bahías sigue fuera de esta
tarea, en T-56.

## Pruebas y almacén real

| Control ejecutado | Resultado | Registro bajo `%TEMP%/baystream-t104-20261015/` |
| --- | --- | --- |
| Pruebas nuevas dirigidas con escala medida | 13/13 | `dirigidas-reales.log` |
| Suite completa final, cinco corridas consecutivas | 685/685 cada una, piso 668 + 17; sin omitidas | `suite-1039-final-1.log` a `-5.log`, `suite-1039-serie.json` |
| Repositorio y salvaguardas, pruebas dirigidas | 17/17 | `dirigidas-1039.log` |
| Analyze final de 10.39 | 0 incidencias | `analyze-1039-final.log` |
| Corpus completo final, primera corrida | 116/116 en 31 archivos de pruebas | `corpus-1039-1.log` |
| Corpus completo final, segunda corrida consecutiva | 116/116 en 31 archivos de pruebas | `corpus-1039-2.log` |
| Huella real final antes/después de las dos corridas | 313 archivos, cero diferencias | `almacen-antes-1039.json`, `almacen-despues-1039.json` |

Las dos corridas usan el entorno normal; no se redirigió `LOCALAPPDATA`. El
corpus se lee de la carpeta externa autorizada. Sus entradas no se versionan y
los registros quedan en TEMP. `block3` guarda sus cajas de viajes/perfiles y
bitácora en el directorio temporal de `testProfileStore()`. Ninguna otra prueba
existente necesitó corregirse por la salvaguarda.

**Primera huella del almacén real**, tomada con `fingerprint.ps1`, invocado por dos
`.bat` abiertos con `Start-Process explorer.exe -ArgumentList <bat>`:

- Ruta obtenida por el proceso externo:
  `C:/Users/Giova/AppData/Local/BayStream`.
- Antes: 00:37:01, 299 archivos. Padres: PowerShell 34632 → cmd 30740 → explorer
  32584; este último procede de explorer 2368.
- Después: 00:38:24, 299 archivos. Padres: PowerShell 34808 → cmd 18760 → explorer
  34528; este último procede de explorer 2368.
- Ambas huellas:
  `C5862797416C3802D263C57A6DF9E20459417E6BA457C3B6E4FA7BC004DD8152`.
- Se compararon rutas relativas, longitud y SHA-256 de cada archivo, incluidas
  las cajas del namespace por defecto. **Cero archivos distintos**.
- No se abrió ninguna app Windows ni se realizaron otras acciones sobre el
  almacén entre las dos huellas. Los `.bat`, el script y los manifiestos quedan
  exclusivamente en TEMP. No se sustituyeron ni apartaron carpetas reales.

**Repetición final tras 10.39:** se reservó de nuevo Windows mediante Carlos,
sin abrir la app. Otros dos `.bat`, con `fingerprint-1039.ps1`, repiten la misma
medición externa sobre la misma ruta real. Antes, 01:41:07: PowerShell 34344 →
cmd 32236 → explorer 35496 → explorer 2368. Después, 01:42:25: PowerShell 35816 →
cmd 33628 → explorer 30520 → explorer 2368. Las dos corridas consecutivas dieron
116/116 cada una. Ambas huellas tienen **313 archivos** y SHA-256
`E9E51423260CEEB021FD409E69C204D4C050F44A3C64F15D24370A550B4BEB3A`:
**cero diferencias de ruta, tamaño y hash**. Los catorce archivos añadidos desde
la primera ventana pertenecen al namespace de la aceptación Windows descrita
abajo, no a estas corridas del corpus.

Las doce pruebas visuales nuevas usan 360 × 800 dp y los tamaños obtenidos de
`MediaQuery.textScalerOf(context)` en el Honor real con `font_scale=2.0`.
La aproximación heredada de T-97 no era la curva del teléfono: por ejemplo,
14 puntos pasan a 26 (no a 28) y 16 pasan a 28 (no a 20.8).
Se midieron 20 tamaños entre 8 y 100 puntos; todos los tamaños Material usados
en las comprobaciones tienen su muestra y se interpola entre muestras.
Evidencia: `honor-escala-real-2.xml` y PNG; el banco conserva el diagnóstico.
Valores de referencia: 12→24, 14→26, 16→28, 18→30, 20→34, 22→35, 24→36,
28→37.333 y 32→39.771. Cubren los seis puntos en ambos temas.
La selección de glifos comprueba una
sola línea para rótulos y peso, sin truncamiento y con tolerancia inferior a un
dp para el redondeo de métricas. La prueba restante llama a la factoría real
en Windows bajo `flutter test` y exige el `StateError` y el mensaje de aislamiento.

**Ajustes de las pruebas durante el desarrollo:** se retiró un `const` inválido
en el fixture y se corrigió la tolerancia de redondeo de glifos (diferencias
inferiores a 0.3 dp). Al introducir las muestras se corrigió también el tipo de
clave del mapa constante: Dart no admite allí claves `double`; se usan enteros.
No se borraron ni omitieron pruebas preexistentes.

## Clientes y aceptación

**Compilaciones finales tras 10.39:** APK release 86.2 s (61.7 MB), Windows
release 44.3 s y Web release 64.0 s. Las tres usan la misma copia
en TEMP, con **0 diferencias de SHA en los 125 archivos de `lib/`** respecto
del repositorio (`integridad-1039-final.json`). SHA-256 del APK:
`F7149D4120C4CAF47101E3BB31967466309638885835546021C139AC72F63913`.
SHA-256 del AOT de Windows (`data/app.so`):
`3B026E21E164A830943862B2CA4F34FF3620D218E30F376684ED54D920DF206E`.
Web (`main.dart.js`):
`71E323FD0AAE9AADC26CE90EE44AEB6A44A4DB4F3DD5E15137AB83AD2B07556B`.
Registros: `apk-1039-final.log`, `windows-1039-final.log`, `web-1039-final.log`.

Las revisiones visuales descritas abajo se hicieron antes del añadido de 10.39.
El Honor y Chrome ya incluían el espacio final del inicio; en Windows ese último
ajuste de espacio se cubre con las pruebas de widget. Tras 10.39 se recompilan
los clientes sin volver a ocupar los dispositivos cedidos. La corrección de
compactación solo cambia el comportamiento ante error de Windows y los dos
registros retirados no cambian la interacción de la leyenda.

Los avisos de Java de las dependencias, MSB8029 por compilar en TEMP y la fuente
CupertinoIcons de Web se conservan como en las entregas anteriores. El dry run
de WASM pasó. Ninguno es una incidencia de `flutter analyze`.

**Windows:** PID 33200 (primera compilación, cerrado antes de recompilar),
31844 (revisión de las pantallas) y 9020 (reapertura del banco). Todas abiertas
con `explorer.exe` y cerradas
por PID y ruta verificada. En claro se revisaron Lista, Bay Plan, la barra
plegada/desplegada, Recientes y la copia de tapas; en oscuro, Lista, la tarjeta
del contenedor y el inicio. A07: 398/21/6940.6 t y 114/0/284 en GTSTC.
Recientes dice «1 bahía» y el editor «Copiado a 1 bahía». La posición completa
se conserva en la tarjeta. El inicio explica contenido compatible BAPLIE 2.x.

Almacén **real**, `C:/Users/Giova/AppData/Local/BayStream/vessel_store`,
namespace `t104acc`. Una tercera huella externa tras cerrar las apps dio
313 archivos: **cero diferencias fuera de `t104acc_*`** respecto de la huella
posterior al corpus. `t104acc_movements.hive`: **0 bytes** (SHA del archivo
vacío `E3B0C44298FC1C149AFBF4C8996FB92427AE41E4649B934CA495991B7852B855`).
El manifiesto `almacen-clientes.json` registra PowerShell 19260 → cmd 12076 →
explorer 34648 → explorer 2368. Esta huella adicional no sustituye la prueba
decisiva antes/después del corpus.

**Honor final `.t104`:** 720 × 1600 px, densidad 320, **360 × 800 dp y letra
2.0**. A07 y el plan de carga de «PRUEBA T-84» se revisaron en los dos temas.
Las pestañas tienen desplazamiento horizontal: se pudo mostrar Estadísticas
completa, además de Lista y Bay Plan; el contenido fuera del viewport se
alcanza desplazando la tira. Los contadores y el peso de Lista no parten las
palabras. «Posición» y «Destino» se leen completos; también la posición puede
envolver a una segunda línea en lugar de acabar en puntos suspensivos.

Carlos inició la sesión en `.t104`; la actualización con `adb install -r` la
conservó. Codex abrió el plan de carga de la operación existente mediante la
app y, tras actualizar, desde Recientes. Esa fuente muestra **3 contenedores,
2 bahías, 15.0 t, 0/2/1 en GTSTC** y «Al día». No son las cifras del plano de
llegada (4/3/20.0 t), que no es la fuente revisada aquí.
Avance, en ambos temas: 3 pendientes de descarga (1 en cubierta/2 en bodega),
2 pendientes de carga, 0 conflictos; tapas 3 declaradas/0 quitadas/2 repuestas.
El último movimiento sigue siendo «Reponer tapa T:3-2», del 13-oct a las 00:16.
No se registraron movimientos. XML sanitizados de Avance, sin nombre del autor;
se descartó el PNG que lo incluía. No se vio ni registró correo, UID o contraseña.

Almacén del Honor: directorio privado de la variante,
`/data/user/0/gt.cmartinez.baystream.t104/files/vessel_store`, namespace
`t104acc`, según la factoría Android; no se inspeccionaron sus cajas privadas.

En ambos temas se comprobó «1 bahía» en Recientes y «Copiado a 1 bahía» en
el borrador del editor, cancelado sin guardar un perfil. El inicio se verificó
sin la lista de extensiones. La revisión visual encontró un solapamiento del
botón flotante sobre el texto inferior; corregido y comprobado en el APK final,
en ambos temas. Las pruebas del inicio incluyen el botón real y comprueban que el
texto inferior quede por encima de él al desplazar el contenido.
La prueba reprodujo el problema en ambos temas antes del ajuste (registro
`regresion-inicio-sin-espacio.log`); la suite final vuelve a 681/681 tras reservar
128 dp al final del contenido desplazable.

**Chrome visible:** revisión local en `http://127.0.0.1:8115/`, con IndexedDB
del origen y namespace `t104acc`; sin iniciar sesión ni usar la nube. A07 conserva
398/21/6940.6 t y 114/0/284 en GTSTC. Lista, la tarjeta y sus etiquetas se ven
completas en claro y oscuro. Bay Plan y la barra plegada/desplegada funcionan.
Recientes muestra «1 bahía» y la copia local «Copiado a 1 bahía» en ambos temas;
el borrador se canceló sin guardar el perfil. El inicio muestra validación por
contenido y BAPLIE 2.x sin enumerar extensiones en ambos temas. Capturas finales:
`chrome-claro-lista-final.jpg`, `chrome-claro-inicio-final.jpg` y
`chrome-oscuro-inicio-final.jpg`; árbol accesible del inicio en TXT.
Las primeras capturas expiraron con la ventana oculta; Carlos la puso visible
y se completó la revisión. Se cerraron la pestaña propia y el servidor PID 22436.

Banco propio `tool/t104_main.dart`, namespace `t104acc`. Compila en
`%TEMP%/baystream-t104-clientes`; A07 se copia exclusivamente como asset de esa
copia. Incluye accesos a las pantallas reales, temas, un caso sintético de una
bahía para Recientes y el editor de tapas con borrador local. La nube se habilita
solo con `BAYSTREAM_T104_REAL_CLOUD=true`; Carlos inicia las sesiones y solo se
abre una operación de prueba ya existente. No se registran movimientos.

El Honor se reservó a través de Carlos. Al inicio de la sesión estaba en escala
1.0, en contradicción con 10.38. Después de T-94, Carlos autorizó ponerlo por adb
en 2.0; se verificó `font_scale=2.0`. Se mantiene la densidad de 320: 360 dp.

## Ampliación 10.39: guardados simultáneos

La evidencia original permite precisar la hipótesis de Yov: en
`build/tlote92/suite-expanded.log`, líneas 130–167, el fallo es
`PathAccessException`, errno 5, al renombrar el archivo `.hivec` a `.hive`
durante la compactación. No falla una comparación de orden. El origen ya
serializa los guardados y persiste un ordinal entero `savedOrder`, sin reloj.
Las dos corridas completas de diagnóstico propias dieron 681/681; no se
presentan como una reproducción propia del fallo registrado por Timonel.

Se corrige en `HiveVesselDataSource`, donde está la compactación. En Windows,
solo un `FileSystemException` de código 5 permite hasta cinco intentos de
compactar, con esperas de 25/50/100/200 ms (375 ms como máximo). Hive reabre el
archivo original al fallar el renombrado; se vuelve a compactar esa caja.
No se repite el guardado ni se omite la compactación. Si el error persiste,
se propaga el mismo objeto; otros errores no se reintentan. Android conserva
una sola llamada y Web usa una implementación sin `dart:io`.

La prueba original conserva `Future.wait` con ocho viajes y la expectativa
exacta `v7, v6, v5, v4, v3`. Además cierra/reabre Hive, vuelve a exigir ese
orden y comprueba que `v0`, `v1` y `v2` no existen. Su directorio ahora nace
en `Directory.systemTemp`, fuera del árbol del proyecto. Cuatro pruebas
nuevas comprueban recuperación transitoria, límite del error persistente y
propagación inmediata de otro error de disco y de un error ajeno a archivos.
Pruebas dirigidas: **17/17**, incluidas las doce existentes del repositorio,
en `dirigidas-1039.log`. La aceptación requiere cinco suites completas
consecutivas: **5/5, cada una 685/685, sin omitidas**. Registros:
`suite-1039-final-1.log` a `-5.log` y `suite-1039-serie.json`.
Duraciones del runner: 36/33/34/34/28 s. `analyze` final: cero incidencias.

## Integridad y límites

Sin dependencias nuevas. **No cambian `pubspec.yaml` ni `pubspec.lock`** del
repositorio. Los assets de aceptación solo se añaden al pubspec de la copia
temporal. No se abrió `android/key.properties` ni el archivo privado de opciones
de Firebase. Cada compilación usa
`--dart-define-from-file=C:/Proyectos/baystream-privado/firebase-prod.json`.
No se usó la CLI de Firebase, credenciales de administrador ni el proyecto H5.

Referencia local de reglas T-80, SHA-256:
`21894B7F43E59F856045473731B795D21F8373C5AC8A1D9FFF324334AC3C9000`.
Reglas del repositorio:
`0112510984D9A16364F9752E243999C47306E0BCF82766E380DB380E8FE8E60A`.
Los ocho SHA iniciales/finales coinciden: ambas reglas, `firebase.json`,
`main.dart`, los dos congelados y ambos `pubspec.*`. Registros `sha-antes.json`
y `sha-despues.json`. No se afirma una nueva ejecución de las 69 pruebas del
emulador ni una consulta a las reglas publicadas.

SHA-256 del SDK servido, todos idénticos antes/después de corregir el `LEEME`:

| Archivo en `web/vendor/firebase/12.17.0/` | SHA-256 |
| --- | --- |
| `firebase-app.js` | `750889F0C0A8D6558366119DC014B7FD589BD5F6289F84151ADE0C057CECD0E6` |
| `firebase-auth.js` | `656B0AB2EC1A1BC6DD7FBEA4A9027BBA883A037D755D68B6758752C60BC2AF0B` |
| `firebase-firestore-pipelines.js` | `96FDA45F41DF884489A568820E8F7910DB9176C0D70825B71913C30C23C9B1C6` |
| `provenance.json` | `6727C1E5BF29CCFB491A51ED1509674BD0D816EC10D84BA37C33E672055CC4D7` |

Las siete pruebas de T-92 siguen pasando dentro de cada suite completa.

**Hallazgo fuera de alcance:** durante las primeras pruebas, al abrir el cuerpo
de Estadísticas con el fixture sintético y la aproximación no lineal heredada
de T-97, las columnas de un gráfico desbordaron 13 px
verticales (`voyage_stats_view.dart`, alrededor de la línea 864). Se documenta;
no se modifica esa pantalla. La prueba de pestañas comprueba sus rótulos y
desplazamiento, sin atribuir una corrección a los gráficos de Estadísticas.
No se presenta ese valor de 13 px como una medición del Honor.
El caso sintético de un contenedor también permite ver el texto preexistente
«1 contenedores» en Recientes: la corrección solicitada aquí es el singular
de bahía. No se amplió el catálogo a ese otro contador.

## Horas, archivos y Git para Carlos

Inicio registrado en `%TEMP%/baystream-t104-20261015/inicio.txt`.
La estimación vigente es **2.5 h**, tras sumar 0.5 h en 10.39.
Inicio 00:31:45; cierre 01:46:27 (`cierre-1039.txt`): **≈1.25 h frente a 2.5 h**.
Es tiempo transcurrido de trabajo y coordinación, incluidas las compilaciones,
las aceptaciones con Carlos, la ampliación y las corridas repetidas; no una
medición aislada de tiempo de tecleo. La primera ventana había cerrado a
01:33:07 y se reabrió al recibir 10.39; está incluida en el total, sin sumarla
dos veces.

Las diecinueve rutas propias de T-104 están enumeradas en este bloque. No incluye
las tres de la corrección de T-94, que tiene su commit independiente. Las rutas
no están ignoradas por las reglas actuales de `.gitignore`; no requieren `-f`.

```powershell
git add -- lib/features/vessel/data/datasources/local_store_directory_io.dart
git add -- lib/features/vessel/data/datasources/hive_vessel_data_source.dart
git add -- lib/features/vessel/data/datasources/local_store_compaction.dart
git add -- lib/features/vessel/data/datasources/local_store_compaction_io.dart
git add -- lib/features/vessel/data/datasources/local_store_compaction_stub.dart
git add -- tool/block3_corpus_test.dart
git add -- lib/features/vessel/presentation/pages/recent_voyages_page.dart
git add -- lib/features/vessel/presentation/pages/hatch_covers_page.dart
git add -- lib/features/vessel/presentation/pages/vessel_overview_page.dart
git add -- lib/features/vessel/presentation/widgets/empty_state_widget.dart
git add -- lib/features/vessel/presentation/widgets/containers_list_view.dart
git add -- lib/features/vessel/presentation/widgets/voyage_summary_card.dart
git add -- lib/features/vessel/presentation/widgets/bay_plan_view.dart
git add -- test/local_vessel_repository_test.dart
git add -- test/t104_local_store_test.dart
git add -- test/t104_text_test.dart
git add -- tool/t104_main.dart
git add -- web/vendor/firebase/12.17.0/LEEME.md
git add -- docs/T104-RESULTADOS.md
git commit -m "Sprint 3: T-104 aisla el corpus y corrige las deudas del lote"
git push
```

El corpus usa bitácora temporal y Windows bloquea el almacén real bajo flutter test.
Se corrigen compactación, singular e interfaz a letra grande; se retiran los print.
685/685 en cinco suites, analyze 0 y dos corpus 116/116 con almacén idéntico.

**Mensaje para Yov:** T-104, incluido 10.39, queda En revisión. Son 17 pruebas
nuevas sobre el piso de T-94: cinco suites consecutivas 685/685, analyze 0 y
dos corpus finales 116/116. El almacén real conserva sus 313 archivos y su SHA
externo `E9E51423260CEEB021FD409E69C204D4C050F44A3C64F15D24370A550B4BEB3A`.
El fallo intermitente era acceso denegado al renombrar el compacto de Hive;
el orden ya usaba ordinales. Se reintenta ese error de Windows con límite y
se mantiene la expectativa exacta, ahora también al reabrir. Sin `// ignore`
en lib; `LEEME` corregido y módulos/procedencia intactos. Honor a 360 dp/2.0 con
curva medida, A07 y PRUEBA T-84 en ambos temas; Windows y Chrome revisados.
Los tres clientes se recompilaron tras 10.39; la revisión visual precede a ese
añadido, como se precisa arriba. ≈1.25 h frente a 2.5 h. Sin dependencias nuevas,
movimientos ni cambios en reglas o protegidos. Los hallazgos fuera de alcance
del gráfico y «1 contenedores» quedan documentados. Commit propuesto:
`Sprint 3: T-104 aisla el corpus y corrige las deudas del lote` (19 rutas propias).
