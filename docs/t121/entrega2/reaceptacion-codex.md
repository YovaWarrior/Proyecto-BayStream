# PASA · T-121 · Entrega 2 · Reaceptación de la corrección 1

26-oct-2026 · Capitán Codex · Carlos Martínez · `C:\Proyectos\baystream-qa-r4`.

**Dictamen: PASA.** H1 (P2) y O1 (P3) quedan cerrados en esta versión. La silueta de nueve bahías cumple con «en grande» en los dos temas y magnitudes, a 1920 y 1366. No encontré hallazgos nuevos de producto en el alcance de esta reaceptación. No corregí el producto.

HEAD **separado** `004ccaaee123ddd1dee7f62003db42e1fd0e5d6d`, decisión 10.54; corrección `c76387a`; base `a5dfc9f`. Comprobado con `git log --oneline -3` y el archivo HEAD del worktree. Leí 10.53–10.54, H1/O1 de mi aceptación anterior, «Entrega 2 · corrección 1» del informe de Timonel, DESIGN 15.4 y los diffs completos. El diff acumulado contiene las **siete rutas de la corrección y SPRINT-4.md**, que incorpora la decisión posterior. No hay contradicción de alcance.

## Hallazgos reaceptados

### H1 · P2 · CERRADO · La silueta aprovecha el panel

**Cómo reproducir:** abrir exclusivamente `T100_LLEGADA.edi`, ir a Estadísticas y usar 1920 × 1080 y 1366 × 768, letra 1.0, claro y oscuro. En cada condición alternar Contenedores y Peso. Después repetir con el sintético de 977 y con el caso derivado de tres bahías.

**Resultado:** las nueve bahías se reparten el ancho interior disponible. El casco se extiende de proa a popa dentro del panel y no requiere desplazamiento horizontal. El pie sigue en el eje de sus columnas. Cambiar a Peso conserva el aprovechamiento del panel. Con tres y cuatro bahías se respeta el tope y el cuerpo queda centrado.

Mediciones propias sobre la página de Estadísticas, sin los paneles exteriores de la aplicación, en dp y letra 1.0; claro y oscuro dieron los mismos valores:

| Vista y datos | Ancho interior del dibujo | Ancho por bahía | Alto de cada zona | Desplazamiento máximo |
|---|---:|---:|---:|---:|
| 1920, llegada, nueve bahías | 1406 | 148.35 | 108 | 0 |
| 1366, llegada, nueve bahías | 1300 | 136.57 | 108 | 0 |
| 1920, tres bahías | 1406 | 168 | 108 | 0 |
| 1920, cuatro bahías | 1406 | 168 | 108 | 0 |
| 1920, 977 y 72 bahías | 1406 | 56 | 72 | 2696.86 |

En tres bahías hay 451 dp a cada lado de las columnas; en cuatro, 367 dp. El tope es tres veces el mínimo, 168 dp con letra 1.0. La zona crece de 72 a un máximo de 108 dp en ancho suficiente. El alto total del dibujo correspondiente pasa de 174 a 246 dp; no debe confundirse con el alto de una zona.

En teléfono, nueve bahías con letra 2.0 mantienen 112 dp por bahía, zonas de 72 dp, dibujo de 174 dp y barra horizontal. Las 72 bahías mantienen 56/112 dp según la letra, alto base y desplazamiento también en pantalla ancha. Cuando no caben con letra 2.0 se conserva esa misma regla. Se alcanzó popa y se abrió la bahía 95 en Windows y Android.

**El punto visual de 10.54:** la franja vacía sobre el casco existe y se ve en las capturas. T100_LLEGADA tiene muy poca carga en cubierta frente a bodega; ambas usan la escala común de 15.4. Mi juicio visual es **sí cumple con «en grande»**: el casco domina el ancho del panel, las pilas y el pie son legibles, y la altura creció hasta el tope previsto. La reserva superior comunica esa diferencia entre zonas. No impide aceptar la protagonista.

**Evidencia propia:** [geometría de los 84 casos](C:/Proyectos/baystream-qa-r4/build/t121-entrega2-reaceptacion/geometria.json), [1920 oscuro, Contenedores, Chrome](C:/Proyectos/baystream-qa-r4/build/t121-entrega2-reaceptacion/web/T100_LLEGADA-1920-oscuro-1.0-inicio.png), [1920 oscuro, Peso, Chrome](C:/Proyectos/baystream-qa-r4/build/t121-entrega2-reaceptacion/web/T100_LLEGADA-1920-oscuro-1.0-peso.png), [1366 claro, Peso, Chrome](C:/Proyectos/baystream-qa-r4/build/t121-entrega2-reaceptacion/web/T100_LLEGADA-1366-claro-1.0-peso.png), [1366 claro, Contenedores, Windows](C:/Proyectos/baystream-qa-r4/build/t121-entrega2-reaceptacion/windows/llegada-1366-dia-limpio/01-contenedores.png), [tres bahías centradas](C:/Proyectos/baystream-qa-r4/build/t121-entrega2-reaceptacion/matriz/tres-1920-dia-1.0-inicio.png), [popa en Android](C:/Proyectos/baystream-qa-r4/build/t121-entrega2-reaceptacion/android/977-popa95.png) y [su rejilla 95](C:/Proyectos/baystream-qa-r4/build/t121-entrega2-reaceptacion/android/977-plano95.png).

### O1 · P3 · CERRADO · La muestra se reconoce como pila

**Cómo reproducir:** en la misma página, observar Cubierta/Bodega en ambos temas; repetir con letra 2.0 y revisar sus roles accesibles.

**Resultado:** la muestra tiene tres segmentos de 10 × 5 dp, separados por 1 dp: conjunto de 10 × 17 dp, sin borde. Visualmente se reconoce como una pila en claro y oscuro. Semánticamente sigue siendo texto: sin acción, casilla ni estado de selección. UIA y MSAA exponen Cubierta/Bodega como texto; los controles Contenedores/Peso conservan un nombre único tanto con rótulos como con iconos. Android los expone como `android.view.View`, no pulsables; Chrome tampoco les asigna rol de botón, casilla o interruptor.

**Evidencia:** [prueba enfocada de semántica y forma](C:/Proyectos/baystream-qa-r4/build/t121-entrega2-reaceptacion/o1-enfocada.jsonl), [verificación UIA/MSAA](C:/Proyectos/baystream-qa-r4/build/t121-entrega2-reaceptacion/windows-verificacion.json), [Chrome y sus roles](C:/Proyectos/baystream-qa-r4/build/t121-entrega2-reaceptacion/web-verificacion.json), [leyenda clara en Android](C:/Proyectos/baystream-qa-r4/build/t121-entrega2-reaceptacion/android/llegada-dia-2-leyenda.png) y [leyenda oscura](C:/Proyectos/baystream-qa-r4/build/t121-entrega2-reaceptacion/android/llegada-noche-2-leyenda.png).

## Validaciones ejecutadas

| Comprobación | Resultado |
|---|---|
| Suite del producto | **1783/1783**, cero fallos y cero omitidas, **una sola invocación**, salida 0 |
| Analyze en copia limpia | **Cero incidencias**, salida 0 |
| Pruebas propias | 93 pruebas distintas resueltas: 91 aprobadas en la primera corrida; las dos O1 se completaron tras corregir el cierre de un manejador del test |
| Matriz propia | **80/80**: cuatro juegos de datos × cinco tamaños × dos letras × dos temas; 168 PNG |
| Geometría adicional | Cuatro casos de cuatro bahías; 84 mediciones contando la matriz |
| Windows nativo | Nueve bahías a 1920/1366, ambos temas y magnitudes; 977 en 72 bahías; teléfono con letra 2.0; UIA/MSAA, tabla, Esc, rejillas 06 y 95 |
| Chrome visible | **60/60**, 240 PNG, cero errores JavaScript registrados; selector, tabla, Esc y apertura de bahía en cada condición |
| Android nativo | **6/6**, 36 PNG; llegada en ambos temas y letras, 977 previo y carga sin escala confirmada; selector, tabla y Atrás; popa y rejilla 95 |
| Restricciones del diff | Sin cambios en dominio, datos, pubspec.*, main.dart, congelados ni lista del piloto; ningún `ignore` en lib/ |

La copia temporal se cotejó **antes de la primera corrida**: 779 archivos copiados, incluidos los manifiestos de diseño, fuentes, pruebas y la identidad Android original. Después de `pub get` se repitió el cotejo: solo difirió el registrador Android generado; `pubspec` e identidad Android seguían originales. Suite y analyze terminaron antes de agregar instrumentación, recursos sintéticos y la identidad aislada del banco. [Cotejo previo a la suite](C:/Proyectos/baystream-qa-r4/build/t121-entrega2-reaceptacion/cotejo-antes-suite.json), [suite](C:/Proyectos/baystream-qa-r4/build/t121-entrega2-reaceptacion/suite-resumen.json) y [analyze](C:/Proyectos/baystream-qa-r4/build/t121-entrega2-reaceptacion/analyze.txt).

La matriz conserva las verificaciones de la aceptación anterior: 1920 × 1080, 1366 × 768, 960 × 800, 700 × 800 y 360 × 800; letras 1.0/2.0; claro/oscuro. Datos: los tres EDI autorizados y un derivado de tres contenedores de T100_LLEGADA, convertido a tres posiciones independientes de 20 pies. T100_CARGA usa escala sin confirmar en la matriz. Además de la geometría se comprueban cifras, agrupaciones, filas de tablas, cortes de texto, mínimo tipográfico, ancho y centrado de página, cambios de magnitud, selección, Esc, Atrás, redimensionado y reentrada. [Matriz](C:/Proyectos/baystream-qa-r4/build/t121-entrega2-reaceptacion/matriz.json), [cifras y comparación 21/22/23](C:/Proyectos/baystream-qa-r4/build/t121-entrega2-reaceptacion/cifras.json).

La regla par/impar no se modificó. La comparación propia conserva estadísticas por posición 21/22/23 = 2/3/1 y `displayBay(22) = 21` en operación; no se convierte esa comparación en un criterio nuevo de aceptación. La corrección no toca el formateador ni los servicios que deciden esa agrupación.

## Bancos, alcance e incidencias del instrumento

Windows se abrió mediante `explorer.exe -> cmd -> exe`, exclusivamente desde `C:\Users\Giova\AppData\Local\Temp\t121-codex-c1-004ccaa\copia`. Usó el almacén **`C:\Users\Giova\AppData\Local\Temp\t121-codex-c1-004ccaa\almacen`**, namespace **`t121racc`**, sin Firebase. Las vistas 1920/1366/teléfono son tamaños lógicos impuestos por el envoltorio de T-99; cada JSON guarda la ventana física y su DPI. Las capturas de widgets son renders de la página y se distinguen de las capturas nativas contra el PID del banco.

Chrome usó perfil temporal `C:\Users\Giova\AppData\Local\Temp\t121-codex-c1-004ccaa\chrome-profile` y origen local `http://127.0.0.1:59122`, siempre visible en las capturas. Android usó exclusivamente **`-s emulator-5554`**, API 26, 1080 × 1920, densidad efectiva 480, ancho lógico 360 dp y paquete **`gt.cmartinez.baystream.t121racc`**. Letra inicial y final: **1.0**. El banco de Windows, Chrome, el servidor local y el paquete Android quedaron cerrados; el emulador quedó encendido como estaba.

Se conservan los tropiezos del instrumento, separados de los hallazgos de producto:

- **I1 · P3, resuelto.** Las dos pruebas O1 propias comprobaron sus expectativas, pero el framework rechazó el cierre tardío de `SemanticsHandle` mediante `addTearDown`. Se movió `dispose` al cuerpo y se repitieron solo esas dos: ambas aprobaron. No se repitió la suite del producto. Se conserva el test exacto de la primera corrida, reconstruido y cotejado con su SHA-256 original.
- **I2 · P3, resuelto.** Al ajustar el gesto Android para comenzar debajo de la cabecera de vista previa, una lectura sin codificación explícita alteró «gráficos». El primer intento del 977 abrió la tabla y esperó una etiqueta incorrecta. Se conservó el intento y se restauró UTF-8; el recorrido completo posterior aprobó. También se restituyó una cadena no ejecutada de la copia del test propio; la matriz original ya había corrido con esa cadena correcta. El test entregado queda reproducible.
- **I3 · P3, resuelto.** Sky no mantuvo disponibles los índices de controles; se usaron coordenadas de capturas recientes del banco. Algunas primeras capturas tuvieron hover o se tomaron durante el cambio de magnitud. Su JSON identifica el estado efectivo; la verificación explica los nombres de archivo ambiguos y se agregó una captura limpia de 1366 claro. Los estados persistidos, no el nombre del PNG, acreditan la magnitud.

[Detalle, reproducción y evidencias de I1–I3](C:/Proyectos/baystream-qa-r4/build/t121-entrega2-reaceptacion/incidencias-instrumento.json). Los avisos de compilación se preservaron: MSB8029 por el banco en TEMP, empaquetado de fuentes y notas Android de dependencias. No se cambió una dependencia para silenciarlos. El build agregó sus metadatos habituales a `android/local.properties` **solo en la copia**; el cotejo final distingue esa generación de una modificación de producto.

La evidencia de Timonel solo se leyó. Su inventario tiene **154 PNG**, conforme a 10.54; la nota histórica de 146 no prevalece sobre esa corrección. El dictamen se apoya en mis pruebas y capturas.

## Entrega e integridad

**Único archivo nuevo fuera de build:** `docs/t121/entrega2/reaceptacion-codex.md`. No se modificaron fuentes del árbol de QA, `pubspec.yaml` ni `pubspec.lock`. El cotejo final verifica las huellas iniciales y que el diff de Git permanezca igual. La evidencia está en `build/t121-entrega2-reaceptacion/`; las compilaciones viven en el banco temporal para no sobrescribir binarios ajenos.

[Resumen verificable](C:/Proyectos/baystream-qa-r4/build/t121-entrega2-reaceptacion/resumen.json), [manifiesto SHA-256](C:/Proyectos/baystream-qa-r4/build/t121-entrega2-reaceptacion/manifest.json), [integridad del árbol](C:/Proyectos/baystream-qa-r4/build/t121-entrega2-reaceptacion/integridad-final.json), [huellas de binarios](C:/Proyectos/baystream-qa-r4/build/t121-entrega2-reaceptacion/binarios.json) y [banco frente al producto](C:/Proyectos/baystream-qa-r4/build/t121-entrega2-reaceptacion/cotejo-producto-banco-final.json). El manifiesto incluye los archivos de evidencia y la huella del informe; excluye su propia huella.

Solo se abrieron datos sintéticos autorizados. Honor, apps del piloto, almacén real de Windows, Firebase, demo17, PRUEBA T-105 y la publicación no se tocaron. No se abrió «Nube y cuenta» ni se capturaron cuentas, correos, UID o contraseñas. Git se usó solo para lecturas; nunca `git status`. **No añado este informe a Git: Carlos lo mueve al rediseño.**

Tres líneas de cierre:

1. H1 queda cerrado: ancho repartido, tope y centrado comprobados; la protagonista cumple «en grande».
2. O1 queda cerrado: muestra de pila y semántica de texto en ambos temas.
3. Suite única 1783/1783, analyze cero, matriz 80/80 y clientes nativos comprobados; producto intacto.

**Mensaje para Yov:** «Capitán Codex reacepta T-121 entrega 2, corrección 1, en 004ccaa: PASA. H1 y O1 cerrados; la franja de cubierta de 15.4 sigue visible y la protagonista cumple en grande. Suite única 1783/1783 sin omitidas, analyze cero, matriz propia 80/80, Chrome 60/60 y Android 6/6. Producto intacto; informe y manifiesto listos para que Carlos los mueva y decida.»

**ALTO: Carlos decide**
