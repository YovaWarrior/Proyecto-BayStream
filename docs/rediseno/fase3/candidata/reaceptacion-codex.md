# BayStream · Reaceptación de la candidata del piloto (10.29–10.30)

**Dictamen: NO PASA.** Capitán Codex, 23-oct-2026, Guatemala. H1 queda cerrado y el recorrido funciona en ambos bancos. Persiste un incumplimiento de H2: a 360 × 640 y letra 2.0, el aviso de 6 s invade **4 dp de tres celdas visibles**, tanto en Descarga como en Carga. La autorización de la 10.30 permite tapar las cifras de la franja, pero exige dejar libres las celdas. No extiendo esa autorización a la rejilla.

Trabajo en `C:\Proyectos\baystream-qa-r4`, sin cambiar de carpeta ni de revisión. Evidencia propia: `build/t114-candidata-reaceptacion/` (en adelante, **E/**). Se leyeron AGENTS.md, las decisiones 10.28–10.30, el dictamen anterior, la sección de corrección de REDISENO-RESULTADOS y DESIGN.md 8 y 13.8.

## Paso 0 y aislamiento

- HEAD separado: `90156622677f3d4ca21510d2c10e2bf93e5f4920` (`9015662`), decisión 10.30.
- Padre: `270d1a88f46578315bfd9b8a51f93e0d9a65510a`, corrección de Timonel.
- `git diff --stat 3fb6d4c HEAD`: **60 archivos, 1566 inserciones, 116 eliminaciones**; el padre aporta 59 archivos y HEAD agrega SPRINT-4.md. Coincide con el encargo. **E/paso0.txt**.
- Sin diferencias de esa corrección en dominio, datos, `lib/main.dart`, los dos congelados ni `pubspec.yaml`/`pubspec.lock`. La comprobación final tampoco muestra cambios locales en las fuentes del producto.
- Banco propio en `%TEMP%\t114-reaceptacion-9015662\banco`: **316 archivos Dart de lib/test idénticos byte a byte** al árbol auditado. Su pubspec solo agrega los assets sintéticos `t99_inputs/`; el lock es idéntico. Namespace `r4`, aplicación Android `gt.cmartinez.baystream.r4`, sin activar Firebase. Windows usa exclusivamente `%TEMP%\t114-reaceptacion-9015662\store-windows`, iniciado por Explorer. **E/banco-huellas.json**, **E/resumen-final.json**.

No hubo escrituras de Git ni `git status`, acceso a cuentas, Firebase CLI/consola, Honor, aplicaciones de producción, PRUEBA T-105 o demo17. No se abrió ni modificó `android/key.properties`; se excluyó de la copia. Los comandos de ADB llevaron `-s emulator-5554`. Flutter se ejecutó de uno en uno y los bancos se recorrieron en plataformas separadas. No se firmó una distribución de publicación ni se publicó nada.

## H1 · Atrás: cerrado

En `navegacion_del_viaje.dart:170–229`, el `Timer` comienza con el primer toque, vence a los 2 s y se cancela al salir y en `dispose`. La advertencia conserva `aviso-de-atras`, es una tarjeta propia arriba, con `IgnorePointer` y región en vivo, fuera de `ScaffoldMessenger`. Atrás no llama a `close()` ni a `hideCurrentSnackBar()`. El previo pregunta antes de consultar la ventana; el doble toque gobierna únicamente el viaje publicado en Android.

**13 pruebas de Atrás aprobadas** y **5 de la corrección aprobadas**, ejecutadas juntas: **E/pruebas-18.txt**. Se volvió a generar en TEMP la reproducción anterior con la copia de `preparar_prueba_atras.py`, aplicada al código actual y sin exigir que la advertencia sea un SnackBar: **1 aprobada**, dos toques separados por 3 s con avisos en cola ya no cierran el viaje ni lanzan la aserción. **E/reproduccion-h1.txt**, **E/atras-cola_test.dart.txt**.

**O1 · P3, observación: una interacción intermedia no cancela la ventana.** Primera pulsación en la raíz; abrir el zoom o seleccionar una celda con detalle lateral; Atrás cierra ese elemento; otra pulsación antes de vencer el plazo inicial vuelve al inicio. Dos pruebas adicionales lo confirman: **E/h1-intermedio-quieto.txt**, **E/h1-intermedio_test.dart.txt**. No lo considero un fallo bloqueante: no amplía ni renueva los 2 s, y la advertencia sigue visible durante ese plazo. Conviene valorar reiniciarla al interactuar con otro elemento para evitar una salida que sorprenda al operador.

El emulador confirma la corrección real: **p23** muestra simultáneamente la advertencia arriba y el aviso de Baja con Deshacer abajo; **p24** vuelve a advertir tras más de 2 s sin salir; **p25–p26** muestran el inicio después de dos toques seguidos y el reciente reabierto. **E/recorrido-android/**.

## H2 · P2: el aviso invade celdas con letra 2.0

Se revisaron `avisos_del_viaje.dart`, `bay_plan_view.dart`, `vessel_overview_page.dart` y `export_list_import_page.dart`. La medida de la fila protege sus controles y el pie fijo del listado protege sus botones. Las cinco pruebas entregadas pasan; su cobertura no incluye una bahía con varios niveles y letra 2.0.

La prueba adicional usa la app completa, fuentes reales Plex/Roboto/iconos, vista de **360 × 640**, escala **1.0, 1.45 y 2.0**, aviso de **6 s con Deshacer**, y planes sintéticos de 24 contenedores: filas 02/04/06/08, niveles 82/84/86/88/90/92. En Carga el listado sintético corresponde a los contenedores del plan. Se desplaza el plano 350 dp hacia arriba para tener varias filas de celdas visibles. La comprobación intersecta sus rectángulos con los recortes de los desplazables y de la ventana; no cuenta celdas fuera de pantalla. En Carga incluye las claves `plan-cell-*` y `loading-C:*`, además de `cell-*` en Descarga.

| Letra | Aviso Descarga, intervalo vertical | Aviso Carga, intervalo vertical | Celdas invadidas | Controles / Deshacer |
|---|---|---|---|---|
| 1.0 | 422–492 dp | 422–492 dp | Ninguna | Libres / responde |
| 1.45 | 374–492 dp | 404–492 dp | Ninguna | Libres / responde |
| 2.0 | **296–492 dp** | **296–492 dp** | **Tres por modo, 4 dp** | Libres / responde |

Con letra 2.0, las tres celdas del nivel 88 terminan su parte visible en **y=300**, mientras el aviso comienza en **y=296**. En Descarga son `cell-8-88`, `cell-6-88` y `cell-4-88`; en Carga, posiciones `0030888`, `0030688` y `0030488`. Las intersecciones son **116 × 4**, **116 × 4** y **56 × 4 dp**. El aviso mide **328 × 196 dp**. La fila de controles está entre **y=500 y 548**: queda a 8 dp del aviso y no se invade. Deshacer responde en las seis configuraciones.

**Resultado: 4 configuraciones aprobadas y 2 fallidas**, ambas por celdas tapadas, no por excepción de dibujo. **E/geometria-final-pruebas.txt** (salida 1), **E/geometria-final-{descarga,carga}-{1.0,1.45,2.0}.json/.png** y fuente reproducible **E/geometria-final_test.dart.txt**. Las pruebas iniciales con una sola fila pasaban: se amplió el banco para evitar una comprobación vacía cuando las celdas no llegaban a la zona del aviso.

Reproducción desde qa-r4, sin modificar test/:

```powershell
Copy-Item -LiteralPath build/t114-candidata-reaceptacion/geometria-final_test.dart.txt -Destination "$env:TEMP/t114-reaceptacion-9015662/geometria-final_test.dart" -Force
flutter test --no-pub "$env:TEMP/t114-reaceptacion-9015662/geometria-final_test.dart" --plain-name 'letra 2.0' --reporter expanded
```

**La medida vieja no produjo un aviso visible mal colocado en los casos probados.** Se forzó una medida previa demasiado grande (180 dp) al abrir otro viaje y demasiado pequeña (12 dp) al regresar de Lista al Plano. Se observó el primer aviso durante 24 cuadros de 16 ms por caso. El primer cuadro aún usa el margen viejo, pero tiene **opacidad 0**; desde el segundo usa el actual, y todos los cuadros visibles terminan en **y=492**, con provider **60 dp**. Una prueba aprobada: **E/medida-visible-pruebas.txt**, **E/medida-vieja.json**, **E/medida-visible_test.dart.txt**. No confundo el rectángulo de una tarjeta invisible con una obstrucción visible.

## Recorridos propios

**Android:** APK r4 compilado de este commit e instalado solo en `t99_api26`, `emulator-5554`: 1080 × 1920 físicos, densidad 480, **360 × 640 lógicos**, letra **1.0**, muelle de día. **27 pasos completos y una captura auxiliar**, salida 0, en una invocación completa desde datos limpios del banco. Abrir/confirmar, importar listado, llegada publicada, dos Baja y Deshacer, Paso/reestiba, OR 16, otra carga OR 17 con el aviso presente y Deshacer, Avance, Atrás, reciente y Más. En esta configuración no se observó una celda ni un control tapado por el aviso. **E/recorrido-android/registro.tsv**, **E/recorrido-android-final.txt**, **E/adb-comandos.json**. Los tres archivos usados son los sintéticos T100_CARGA.edi, T100_LLEGADA.edi y T100_LISTADO.xlsx; sus huellas están en el resumen final.

**O2 · P3, cobertura del instrumento.** `con_aviso()` refuerza H2: exige Deshacer antes de abrir Acciones, y p19 permite ver el aviso detrás del menú. Sin embargo, quitar `esperar('Toca Atrás otra vez')` debilita la comprobación automática de H1: `sin_inicio()` solo descarta el inicio, no exige positivamente el plano ni la advertencia, y puede aceptar un árbol sin nodos. La captura inmediata evita llegar tarde a los 2 s; aquí se compensa con revisión visual positiva de p23/p24 y las pruebas de widget. Recomiendo conservar una verificación positiva en futuras versiones del instrumento. Copia utilizada: **E/piloto_android.py.txt**, con adaptación únicamente para captura auxiliar y serial explícito.

**Windows:** banco Release nuevo; conductor copiado en TEMP con los **dos primeros `_sinAvisos()` retirados** y el tercero conservado antes del BAPLIE en Lista. Se añadió una exigencia de SnackBar presente antes de los dos controles y al abrir la segunda hoja: **3 comprobaciones satisfechas**. Escenario piloto a **1920 × 1080**, letra **1.0**, oficina de noche: **26 capturas numeradas y una auxiliar**, final `fin`, **0 errores de Flutter, 0 textos truncados y 0 esperas vencidas**, sin reiniciar ni retomar el escenario. Confirmar/importar responde (p06→p07); Asignar vacío responde con el aviso de OR 16 presente (p18→aux→p19). Se completan Avance, En vivo, alertas, BAPLIE de salida y comparación (p21–p25). **E/recorrido-windows/pasos.jsonl**, **E/recorrido-windows.txt**, **E/t99_conductor-temporal.dart.txt**.

**O3 · P3, oficina:** en **p18_vacio-asignado.png** el aviso cruza el espacio inferior vacío del riel y filas del panel En vivo. No cubre la leyenda, ninguna celda de esta rejilla ni un control. La ocultación temporal de actividad del panel es una observación; no bloqueó el escenario. La clasificación se hizo sobre los PNG de 1920 × 1080. Los registros auxiliares `qa-regiones` mezclan origen global con tamaño local bajo el escalado del arnés: **no se usan como medición de intersecciones**. Las medidas del hallazgo H2 proceden de la prueba de widget, sin ese escalado.

**Rectificación del dictamen anterior sobre la hoja:** Timonel tiene razón. Es una ruta modal por encima del aviso. Su pie «Cerrar» queda libre en Android (**aux-hoja-con-aviso.png**) y Windows (**aux_hoja-con-aviso.png**); esta última se tomó después de exigir que el aviso siguiera presente detrás. La prueba entregada también toca Cerrar y comprueba que la hoja se cerró y el aviso continuó. El conductor apartaba el aviso para acceder a la franja, no porque este cubriera el pie de la hoja. Retiro esa atribución de mi dictamen anterior.

La Web no se repitió, según la instrucción de Carlos; queda para su ensayo del sábado.

## Pantallas y verificaciones generales

Revisadas visualmente las cinco rehechas: `perfiles-guardados_360_claro_letra1.0`, `viajes-recientes_360_claro_letra1.0` y `tapas-en-la-operacion_360_claro_letra1.0` muestran contenido; `comparar_1920_oscuro_letra1.0` tiene el chip legible; `parametros_360_claro_letra1.0` muestra el desplegable cargado. **Las otras 49 son idénticas byte a byte a 3fb6d4c**. Son **54 PNG**, porque las tres configuraciones de la página de cuenta no se capturan.

`registro.tsv`: **57 configuraciones, 0 excepciones, 0 indicadores de carga, contraste 55/57**. Los dos «no pasa» siguen siendo los falsos positivos de 9.5, «Tapas: sin declarar» y «BUQUE MANUAL · V114», a 360; sus PNG no cambiaron. No presento esto como una medición nueva del contraste: se verificaron el registro y las huellas, más las cinco imágenes cambiadas. **E/pantallas-huellas.json**.

| Comprobación ejecutada | Resultado | Evidencia |
|---|---|---|
| `flutter test --no-pub --reporter expanded`, suite del repo | **1338 aprobadas, 0 fallos, 0 omitidas**, 2 min 20 s | E/suite-1338.txt; salida 0 |
| Dos archivos t114 de Atrás/corrección | **13 + 5 aprobadas** | E/pruebas-18.txt; salida 0 |
| Reproducción anterior de H1 en TEMP | **1 aprobada** | E/reproduccion-h1.txt; salida 0 |
| Ventana de Atrás e interacción intermedia | **2 aprobadas** | E/h1-intermedio-quieto.txt |
| Geometría final con varias filas y fuentes reales | **4 aprobadas / 2 fallidas** | E/geometria-final-pruebas.txt; salida 1 |
| Primer aviso con medida vieja, solo cuadros visibles | **1 aprobada**, dos casos | E/medida-visible-pruebas.txt; salida 0 |
| `flutter analyze --no-pub`, banco limpio antes de instrumentarlo | **0 incidencias** | E/analisis.txt; salida 0 |
| `flutter analyze --no-pub lib test tool integration_test`, qa-r4 | **0 incidencias** | E/analisis-fuentes.txt; salida 0 |
| Compilaciones de los bancos actuales | APK y Windows satisfactorios | E/compilacion-android-final.txt; E/compilacion-windows.txt |

El análisis completo se hizo en el banco limpio para no incorporar instrumentos históricos conservados bajo build/ de qa-r4; además se analizaron las cuatro carpetas de fuentes directamente en qa-r4. No se ejecutó `flutter test --platform chrome`. Las advertencias nativas de MSBuild sobre compilar dentro de TEMP quedan en el log de compilación; no se confunden con el resultado de `flutter analyze`.

**Incidencias propias del instrumento, conservadas y descartadas como aceptación:** la primera compilación Android encontró un nombre de método erróneo que yo había añadido al conductor TEMP; se corrigió únicamente esa copia antes de compilar el APK utilizado. La primera invocación Android se detuvo en p13 por `UnicodeEncodeError` de la consola al imprimir el guion de re‑estiba: queda en **E/android-incompleta-consola/** y **E/recorrido-android.txt**. Se repitió entera con UTF‑8 en salida nueva; solo la corrida final de 27 pasos acredita el recorrido. En la exploración de Atrás se eliminó del instrumento una espera de la animación decorativa mediante movimiento reducido. La comprobación preliminar de medida vieja contó un cuadro invisible como obstrucción; la prueba final registra opacidad y exige el anclaje correcto en todos los cuadros visibles. Ninguna de estas adaptaciones cambió el producto ni convirtió en aprobadas las dos pruebas fallidas de letra 2.0.

## Entrega y mensaje para Yov

Único archivo entregable añadido al repo: **`docs/rediseno/fase3/candidata/reaceptacion-codex.md`**, sin seguimiento. Evidencia local en **E/**, con fuentes de las pruebas/copias, logs, PNG, huellas y `manifest.json`. No cambian `pubspec.yaml` ni `pubspec.lock` del repo. No se entrega bloque de Git: lo prepara Yov en la copia correspondiente.

**Para Yov:** Reaceptación de `9015662`: **NO PASA** por H2 P2 a letra 2.0, 360 × 640: el aviso invade 4 dp de tres celdas en Descarga y Carga. A 1.0/1.45 deja libres las celdas; controles y Deshacer responden. H1 cerrado; emulador 27 pasos y Windows 26 más auxiliar, sin fallos en las corridas válidas. Suite 1338, análisis cero, cinco capturas corregidas y otras 49 idénticas. La hoja de vacíos sí queda por encima del aviso: rectifico mi informe anterior. Carlos decide el siguiente paso; no se corrigió ni publicó el producto.

**ALTO: Yov revisa la reaceptación**
