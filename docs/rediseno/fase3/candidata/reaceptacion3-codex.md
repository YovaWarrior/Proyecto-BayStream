# PASA · Tercera reaceptación de la candidata del piloto (10.33)

Capitán Codex · 23-oct-2026, Guatemala · **HEAD `cc24766`**, separado, sobre `6b9d80e`.

**H2-A y H2-B quedan cerrados.** Las tres rutas que fallaron pasan en los tres tamaños a letra 2.0; no quedan avisos manuales fuera de la fábrica. O2 rechaza el resultado simulado a 3,1 s y el recorrido real completa sus 27 pasos en una sola corrida, con ambas comprobaciones a 1,2 s. La suite de Windows da **1371 aprobadas, ninguna omitida**, y el análisis, cero. No aparecen hallazgos nuevos P1 ni P2. Se conservan los P3 anteriores de T-61 sin operación y O3 en la oficina, fuera de esta corrección.

Evidencia propia: **`build/t114-candidata-reaceptacion3/`**, abreviada **E/**. `resumen.json` reúne las cifras y `manifest.json` identifica los archivos mediante SHA-256. No se corrigió el producto; este es el único informe nuevo bajo docs/, sin añadirlo a Git.

## Paso 0, lectura y alcance

`git log -2 --oneline`: **`cc24766`**, tercera corrección de Yov y decisión 10.33; debajo, **`6b9d80e`**, decisión 10.32. `git diff --stat 6b9d80e HEAD`: **15 archivos, 806 inserciones y 44 eliminaciones**. HEAD separado, según el formato de referencias de log. **E/paso0.txt**.

Se leyeron AGENTS.md, SPRINT-4 10.31–10.33, el dictamen anterior, REDISENO-RESULTADOS 12.1–12.6, DESIGN 13.8 y el diff completo del código, las pruebas nuevas y el instrumento. La modificación de presentación alcanza nueve archivos: la fábrica y los ocho archivos productores restantes. El censo anterior tenía nueve construcciones manuales en esos ocho productores.

El diff contra la base está vacío para **domain/, data/, lib/main.dart, los dos congelados, pubspec.yaml, pubspec.lock y LISTA-PILOTO.md**. Tampoco hay cambios locales en lib/, test/, tool/ ni en los documentos de control consultados. **E/alcance-restringidos.txt**, **E/fuentes-locales-final.txt**. No se ejecutó Git de escritura ni `git status`; no se entrega bloque de Git.

## H2-A y H2-B: reproducción independiente

Se adaptó **mi prueba anterior**, conservando sus rutas y aserciones geométricas, y se amplió a **360 × 640, 360 × 800 y 412 × 915**, letra **2.0**, fuentes reales Plex/Roboto/iconos, plan sintético de **24 contenedores en seis niveles** y plano desplazado. No se sustituyó por el nuevo test entregado por Yov. Se añadió la comprobación del resumen y se mantuvieron las de celdas recortadas por sus desplazables, controles y texto completo, sin elipsis ni desbordamiento. **E/preparar.py**, **E/rutas_test.dart.txt**.

Las **nueve pruebas reales pasan**:

1. Desde el Plano, `compareWithAnotherBaplie` con el selector sustituido por el sintético vacío **T100_SINTETICO_VACIO.edi**. Se ejecutan el parseo y el aviso del producto.
2. Abrir Parámetros, cambiar el tema con un fallo sintético de escritura inyectado en su proveedor y volver mientras sigue el aviso. No se falla el almacén de Carlos.
3. Abrir Tapas en la operación, registrar Quitar y volver con el aviso activo. **Deshacer responde y añade la anulación a la bitácora en memoria**, en los tres tamaños.

| Ventana, letra 2.0 | Inicio de franja, y | Comparar / Parámetros, y | Tapa con Deshacer, y |
|---|---:|---:|---:|
| 360 × 640 | 346 | 392–492 | 350–492 |
| 360 × 800 | 506 | 552–652 | 510–652 |
| 412 × 915 | 650 | 709–767 | 667–767 |

**Cero celdas visibles, resúmenes o controles invadidos.** El texto elegido se muestra entero. A 360 × 640, la tapa deja 4 dp entre su tarjeta y el borde de arriba de la franja; los controles comienzan en y=500, 8 dp después de la tarjeta. Las cifras pueden quedar cubiertas según 10.30. **E/pruebas-propias.txt**, **E/rutas-resumen.json**, **E/real-*.json/.png**.

Las nueve comprobaciones de rutas de `test/t114_candidata_correccion3_test.dart` pasan también dentro de la suite: incluyen Ver/Cerrar en Comparar y el texto entero del error en la página real de Parámetros. No se conserva el SnackBar fabricado a mano como productor de una prueba positiva de la API nueva.

## Censo, otros avisos y contraste

El censo de todo **lib/** encuentra **una sola construcción de SnackBar**, en `avisos_del_viaje.dart`; **cero fuera**. Se revisaron también sus llamadas y la guarda nueva de todo lib/, que pasa. **E/censo.txt**, **E/censo-productores.txt**.

Se hicieron **36 mediciones adicionales**: doce textos/variantes en los tres tamaños, a letra 2.0, con la misma fábrica y los argumentos presentes en los productores migrados. Cubren Perfiles (éxito/error), BAPLIE de salida (exportación, comparación fallida, generación fallida y cancelados copiados), Listado de la agencia (éxito/error), Tapas de escotilla (copia) y Viajes recientes (borrado y errores de abrir/eliminar). **Todos caben al volver al Plano**, sin invadir celdas, resumen o controles; también sus errores largos.

Estas mediciones usan una **ruta auxiliar** para conservar el aviso al regresar: no se afirma haber provocado todos los fallos reales de exportación o persistencia de cada página. Antes de volver, se comprueba el texto entero, su altura intrínseca y su pertenencia a la tarjeta: **36/36 textos completos, sin Ver ni tope de franja**. La lectura de los productores confirma que usan esa misma fábrica; las tres rutas anteriores sí se ejecutan de verdad. **E/externos_test.dart.txt**, **E/externo-*.json/.png**, **E/externo-*-origen.json**.

En el aviso con fondo de error, la implementación pasa `onError` al texto y a la acción. Las dos pruebas de renderizado de la suite comprueban ambos párrafos, incluido Ver. El cálculo independiente con los colores efectivos del tema confirma:

| Tema | Fondo / texto y acción | Contraste |
|---|---|---:|
| Claro | #B3261E / #F9D9D6 | **4,96:1** |
| Oscuro | #F2777A / #601410 | **4,79:1** |

Superan 4,5:1. **E/contraste.json**, **E/suite-unica.txt**; captura real del widget en **E/real-parametros-error-360x640.png**.

## O2 y emulador

**Mi sondeo aislado** devuelve un árbol positivo con advertencia, Plano y Deshacer y sustituye solo el reloj: **acepta a 1,2 s y rechaza a 3,1 s**. No llama a ADB. La comprobación del plazo ahora precede al retorno de éxito. **E/sondeo_o2.py**, **E/o2-sondeo.json**.

Se actualizó mi banco TEMP anterior con las fuentes de este HEAD: **318 archivos Dart de lib/test idénticos byte a byte**. Se recompiló la entrada correcta `tool/t99_main.dart`, namespace **r4**, sin inicializar Firebase. Se conserva la separación Android `.r4` y solo los tres archivos sintéticos **T100_CARGA.edi, T100_LLEGADA.edi y T100_LISTADO.xlsx**. **E/banco-huellas.json**, **E/compilacion-android-main.txt**, **E/resumen.json** (huella del APK).

Banco: `%TEMP%\t114-reaceptacion2-6b9d80e\banco`, actualizado a `cc24766`; los instrumentos propios de esta revisión están en `%TEMP%\t114-reaceptacion3-cc24766`. El nombre del directorio del banco conserva su origen; no se ejecutó el APK antiguo.

Instrumento actual del repo, **una invocación desde `pm clear` del paquete r4**, en **t99_api26 / emulator-5554**, 1080 × 1920 físicos, densidad 480 (**360 × 640 lógicos**), letra 1.0: **27 pasos, salida 0**, sin reiniciar ni retomar el recorrido. El envoltorio TEMP añade y verifica **`-s emulator-5554` en cada llamada ADB**, incluidas las de los ayudantes importados; conserva **189 comandos del instrumento**. **E/ejecutar_android.py.txt**, **E/adb-comandos.json**, **E/emulador-entorno.txt**.

O2 ve en el mismo volcado la advertencia y el Plano a **1,2 s en ambos pasos**; el primero exige además Deshacer. Las capturas p23/p24 y su registro concuerdan. **E/emulador/registro.tsv**, **E/emulador-salida.txt**, **E/emulador/p23-atras-con-aviso.png**, **E/emulador/p24-atras-tras-la-ventana.png**. La comprobación **sigue dependiendo del tiempo de uiautomator**; ahora esa dependencia hace fallar un volcado tardío, en lugar de aceptarlo. Esta corrida satisface el plazo estricto.

El instrumento restauró letra 1.0; se consultó su valor final y se detuvo únicamente el paquete r4. No se usó el Honor ni otra app del proyecto.

## Observaciones P3 conservadas, fuera de esta corrección

**T-61 sin operación · P3.** Reproducción: reabrir un viaje cuyo perfil vigente dejaría carga fuera; modo Contenido, sin franja, 360 × 640 y letra 2.0. El aviso dura 10 s una vez y sigue ocupando **328 × 394 dp, y=84–478**, con **18 celdas visibles tapadas** y parte de la cabecera. La medición JSON es **idéntica** a la anterior. No se presenta como corregido ni se extiende a él la autorización de cubrir cifras. **E/sin-operacion-t61.json/.png**, **E/t61_test.dart.txt**; comparación en **E/cerrar.py**.

**O3, oficina · P3.** Se conserva lo observado al registrar y deshacer en el banco Windows a **1920 × 1080/1.0**: el aviso cruza espacio inferior del riel y una zona de En vivo, sin tapar leyenda, celdas o controles. **No se repitió Windows en esta revisión.** El diff de la fábrica no cambia la geometría del aviso normal sin fondo de error; no hay modificación de la oficina en este bloque. La evidencia nativa sigue en **build/t114-candidata-reaceptacion2/oficina/p06_aviso-compacto-oficina.png** y **p07_deshecho-oficina.png**. Queda para COMAR según 10.31/10.33.

## Validaciones, límites y entrega

| Comprobación propia | Resultado | Evidencia |
|---|---|---|
| `flutter test --no-pub --reporter expanded`, Windows | **1371 aprobadas, 0 omitidas, una única corrida, sin reintentos**, 1 min 16 s | E/suite-unica.txt; salida 0 |
| `flutter analyze --no-pub` | **0 incidencias**, 22,6 s, en el banco con las fuentes actuales | E/analisis.txt; salida 0 |
| Pruebas TEMP independientes | **46 aprobadas**: nueve rutas reales, 36 variantes externas y una medición de T-61; esta última conserva su obstrucción P3 | E/pruebas-propias.txt; salida 0 |
| Instrumento Android | **27 pasos**, una corrida válida; O2 **1,2 / 1,2 s** | E/emulador/; salida 0 |

El análisis se ejecutó en el banco para excluir los instrumentos históricos de build/ de qa-r4, con lib/test/tool actuales; no se silenció ninguna incidencia. Las siete fallas conocidas de Linux no aparecen en esta corrida de Windows. No se ejecutó `flutter test --platform chrome` ni se repitió la suite para obtener verde.

**Incidencias del arnés:** el generador TEMP se detuvo inicialmente en una aserción de sustitución de texto, antes de ejecutar pruebas; se corrigió solo ese generador. La primera compilación apuntó a `t99_app.dart`, auxiliar sin main, y falló antes de instalar nada; su log queda en **E/compilacion-android.txt**. Después se compiló `t99_main.dart` correctamente. Ninguna incidencia se cuenta como falla del producto, ni como intento del recorrido o de la suite. Fuentes finales y generadores reproducibles en E/.

No se abrieron ni copiaron key.properties o firebase-prod.json, no se usó Firebase CLI/consola/deploy, cuentas, datos reales del piloto, apps de producción, PRUEBA T-105 ni demo17. El banco usa la clave de depuración automática, sin claves de distribución ni publicación. No se abrió ni capturó la página de cuenta. No se modificaron pubspec.yaml ni pubspec.lock del repo. El único archivo de entrega bajo docs/ es **docs/rediseno/fase3/candidata/reaceptacion3-codex.md**, sin seguimiento; las pruebas y evidencias nuevas quedan en TEMP/build/.

## Mensaje para Yov

**Yov: PASA `cc24766`.** H2-A y H2-B pasan con mis tres rutas reales en los tres tamaños a 2.0; Deshacer anula la tapa. Cero SnackBar manuales fuera de la fábrica; los avisos externos caben al volver y el contraste de error supera 4,5:1 en ambos temas. Suite Windows 1371 sin omitidas ni reintentos, análisis cero; emulador 27 pasos en una corrida, O2 a 1,2 s y el sondeo rechaza 3,1 s. T-61 sin operación y O3 siguen P3, fuera del bloque. Carlos conserva la decisión de publicar; no se corrigió ni publicó el producto.

ALTO: Yov revisa la tercera reaceptación
