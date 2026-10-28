# NO PASA · T-121 · Entrega 2 · Aceptación de Capitán Codex

26-oct-2026 · Carlos Martínez · `C:\Proyectos\baystream-qa-r4`.

**Dictamen:** no acepto todavía la entrega completa. La silueta con nueve bahías no cumple el papel de protagonista «en grande» de 0.9.5. Las trece desviaciones documentadas son aceptables individualmente; ninguna documenta ni justifica ese aprovechamiento del panel. La muestra de «Cubierta» merece un ajuste menor. No corregí el producto.

Base aceptada `6be78e7`; entrega `ce33a16`; HEAD **separado** `f324499e99eb2853c00b446c222e84406b5b3ef9`. Comprobado con `git log --oneline -3` y lectura del archivo HEAD del worktree. Las decisiones 10.49–10.52 no se usan como criterios; de 10.52 solo se responde la comparación solicitada entre bahías pares e impares.

## Hallazgos

### H1 · P2 · La protagonista queda pequeña con nueve bahías

**Reproducción:** abrir `T100_LLEGADA.edi`, ir a Estadísticas, vista de 1920 × 1080, letra 1.0 y tema oscuro. Observar «Carga por bahía, de proa a popa» y cambiar a Peso. Repetir con el EDI de 977 para comparar la adaptación a la cantidad de bahías.

**Resultado:** el dibujo de nueve bahías queda pegado a la izquierda y ocupa menos de la mitad del ancho interior del panel. El resto es un vacío grande; la silueta no domina la página como pide la propuesta A. Cambiar la magnitud conserva ese problema. Con 72 bahías el dibujo llena el espacio disponible y continúa mediante desplazamiento horizontal.

**Causa comprobada:** `BsBuqueEnCorte` construye una fila de ancho intrínseco (`mainAxisSize: MainAxisSize.min`), con una columna por bahía, de 56 dp por la escala de letra —o más si lo necesita el pie— y márgenes. El desplazamiento horizontal no reparte el ancho que sobra entre las bahías. El panel sí ocupa toda la fila.

**Evidencia propia:** [captura de nueve bahías a 1920, noche, 1.0](C:/Proyectos/baystream-qa-r4/build/t121-entrega2-aceptacion/matriz/llegada-1920-noche-1.0-inicio.png), [la misma condición en Chrome](C:/Proyectos/baystream-qa-r4/build/t121-entrega2-aceptacion/web/T100_LLEGADA-1920-oscuro-1.0-inicio.png), y el diff de `bs_buque_en_corte.dart` en `build/t121-entrega2-aceptacion/diff/`.

**Corrección propuesta para que Carlos decida:** cuando las bahías caben, repartir el ancho útil o ampliar el dibujo para dar a la silueta el protagonismo acordado; conservar la escala común de alturas, el pie alineado y el desplazamiento para muchas bahías. No propongo cambiar conteos ni dominio.

### O1 · P3 · La muestra de «Cubierta» parece una casilla sin marcar

**Reproducción:** la misma vista, tema oscuro, junto a «Contenedores / Peso».

**Resultado:** la muestra blanca, cuadrada y con borde se parece a una casilla de selección. El árbol la expone como texto «Cubierta», no como un control. Es una ambigüedad visual de la leyenda.

**Evidencia:** la captura de H1 y [el selector de iconos en Windows](C:/Proyectos/baystream-qa-r4/build/t121-entrega2-aceptacion/windows/llegada-360-noche-2/01-selector-iconos.png), con su JSON UIA/MSAA. `_Muestra` usa 12 × 12 dp, radio 2 y borde.

**Propuesta:** una muestra alargada o con los separadores de la pila, manteniendo el color y el rótulo. Observación menor; H1 es el hallazgo que impide aceptar el resultado visual.

## Validaciones ejecutadas

| Comprobación | Resultado y evidencia |
|---|---|
| Suite sobre fuentes originales | **1773 aprobadas, 0 fallidas, 0 omitidas**, una corrida válida completa; `suite.jsonl`, `suite-resumen.json`, salida 0 |
| Analizador en la copia limpia | **Cero incidencias**; `analyze.txt`, salida 0 |
| Pruebas propias | **66 aprobadas**, sin fallidas ni omitidas; `propias.jsonl`, `propias-resumen.json` |
| Matriz propia de widgets | **60/60**: cinco tamaños × dos letras × dos temas × tres juegos de datos; 126 PNG y `matriz.json` |
| Windows nativo | Banco propio compilado desde `tool/t99_main.dart`; rótulos e iconos con nombre único en UIA y MSAA; cambio de magnitud, tabla, Esc y apertura de la bahía 06 comprobados; `windows-verificacion.json` |
| Web nativa | **60/60 condiciones** en Chrome visible, cero errores JavaScript; cambio de magnitud, tabla, Esc y apertura de bahía; 240 PNG, `web/resultados.json`, salida 0 |
| Android nativo | **6 condiciones**, 32 PNG: llegada en claro/oscuro, letra 1.0/2.0; 977 en previo y carga sin escala confirmada, noche/1.0; tabla, Atrás y selector; popa y apertura de bahía 95; `android-verificacion.json` |
| Rampa, script original de dataviz | **4/4 corridas con salida 0**, `--ordinal`, los cuatro fondos de 0.9.4; `paleta-skill.json` y cuatro salidas `paleta-skill-*.txt` |
| Restricciones de fuentes | Sin cambios en dominio, datos, dependencias, `main.dart`, congelados ni lista del piloto; ningún `// ignore:` en `lib/`; ningún `Colors.*` de código en presentación; `revision-codigo.json` |

### Integridad de la corrida y tropiezos del instrumento

**No se cumplió literalmente la petición de una sola invocación de la suite:** hubo dos intentos inválidos de preparación y después una corrida válida. Los declaro para que no se confundan con fallos del producto ni con una suite aprobada al reintentar pruebas fallidas:

1. Mi primera copia excluyó por nombre `design` a cualquier profundidad y omitió `lib/core/design/`. Aborté ese intento por errores de compilación. Registro: `suite-intento-invalido-copia.jsonl`.
2. La segunda copia todavía omitía los manifiestos de `design/` y ya llevaba el rótulo Android del banco. Eso rompió pruebas que leen esos manifiestos y exigen el rótulo original. Registro: `suite-intento-invalido-identidad.jsonl`.
3. Restituí **solo la copia**, incluí los manifiestos, cotejé las fuentes con el árbol y corrí la suite completa sobre las fuentes originales: 1773/1773. Luego corrí `analyze`, también antes de instrumentar. No hubo otro reintento de esa suite ni se omitió una prueba. `verificacion-copia-limpia.json` distingue el registrador Android generado por `pub get` de las fuentes.

La instrumentación y la identidad del banco se agregaron después, exclusivamente en `%TEMP%`. El analizador en cero corresponde a la copia limpia, no a una mezcla con el test de aceptación.

Los recorridos de clientes también requirieron ajustes propios: ampliar la espera inicial del conductor; no usar `networkidle` como única señal de reposo de Flutter Web; comprobar que el centro del control está dentro de la vista antes de pulsarlo; quitar el salto de línea inicial de las etiquetas Android; y comenzar el gesto de volver arriba dentro del contenido, debajo de la cabecera. La última bahía sí abrió su plano; un sondeo posterior esperaba el rótulo exacto «Bahía 95» y recibió «Bahía 95 · tapas sin declarar». Se comprobó la apertura mediante ese rótulo y las celdas `095-…`, y se guardó la captura. Se conservan los registros de esos intentos. El primer estado visual de la herramienta de escritorio mostraba la ventana que tapaba el banco; se descartó y se activó el banco por su ruta exacta. Las capturas de evidencia de Windows se hicieron contra el PID del banco con `PrintWindow`.

Las advertencias de compilación se conservaron: MSB8029 por compilar en `%TEMP%`, notas de API obsoleta/operaciones sin comprobar en dependencias Android y avisos del empaquetado de fuentes. No se cambió una dependencia para silenciarlas.

## La matriz propia

Tamaños: **1920 × 1080, 1366 × 768, 960 × 800, 700 × 800 y 360 × 800**. Letras **1.0 y 2.0**; claro y oscuro. Tres juegos de datos:

- `T99_SINTETICO_977.edi`, 977 contenedores y 72 bahías.
- `T100_LLEGADA.edi`, 60 contenedores y nueve bahías visibles, tres con carga.
- `T100_CARGA.edi` con `portOfCall` sin confirmar, como plano sin escala, en la matriz de widgets.

Es una matriz de la página de Estadísticas con las fuentes y temas del producto. Cada caso recorre gráficos y tablas, verifica texto cortado y palabras partidas, mínimo 11, techo 1440 y centrado, cifra de 48, selección de bahía, cambio de magnitud, correspondencia de filas y valores, Esc y registro de Atrás. Las pruebas adicionales recuperan el redimensionado con desplazamiento de la vista borrada y la apertura del plano con varias selecciones y reentrada.

Los recorridos nativos prueban además la página dentro de la aplicación completa. En Windows se impusieron tamaños lógicos con el envoltorio de T-99; el tamaño físico y DPI de la ventana se guardan en cada JSON. Las capturas de widgets son imágenes a su tamaño lógico, sin ese ajuste a la ventana física. No se presentan como capturas nativas.

## Las cifras

Oráculo propio: se cuentan directamente los contenedores leídos por el parser, se agrupan por puerto/naviera/posición y se suman pesos efectivos. Se comparan esos resultados con `EstadisticasDelViaje` y las filas concretas de cada tabla. No basta con que una cifra aparezca en alguna celda.

| Datos | Total | Llenos | Vacíos | Sin estado | 20 / 40 / 45 / otro | Peso exacto, kg |
|---|---:|---:|---:|---:|---|---:|
| T99, 977 | 977 | 242 | 735 | 0 | 128 / 827 / 22 / 0 | 8 366 089 |
| T100 llegada | 60 | 54 | 6 | 0 | 0 / 60 / 0 / 0 | 964 950 |
| T100 carga sin escala, matriz | 60 | 44 | 16 | 0 | 0 / 60 / 0 / 0 | 866 700 |

- T99: puertos **907 + 40 + 30 = 977**; navieras **945 + 32 = 977**.
- Llegada: puertos **30 + 15 + 15 = 60**; navieras **35 + 25 = 60**.
- Carga: puertos **35 + 25 = 60**; navieras **42 + 18 = 60**.
- En los tres: total = llenos + vacíos + sin estado = suma por puerto = suma por naviera = suma por tamaño = suma de bahías más sin posición. Los pesos también cuadran.
- La suite del producto añade los casos con estado, puerto, naviera o posición ausentes y «Otros N»; el EDI de T99 es distinto del sintético de 977 construido dentro de `test/support/t121_estadisticas_support.dart`. No se mezclan sus cifras.

Detalle completo: [cifras.json](C:/Proyectos/baystream-qa-r4/build/t121-entrega2-aceptacion/cifras.json). `formatearToneladas` muestra el redondeo a una decimal, con espacio duro antes de «t» y sin separador de miles, como observó Yov. No lo considero un defecto nuevo de esta entrega.

## Las trece desviaciones de DESIGN 15.11

| N.º | Decisión de Codex | Motivo |
|---:|---|---|
| 1 | **Acepto** el peso como cifra en el pie | Peso cambia la altura; número, cuenta y peso siguen disponibles y alineados |
| 2 | **Acepto** dos colores para cubierta/bodega | Son dos zonas identificadas por leyenda; no sustituyen la rampa de tamaños |
| 3 | **Acepto** 56 dp por la escala de letra y ajuste al pie | Conserva la legibilidad; a 2.0 la silueta se recorre horizontalmente |
| 4 | **Acepto** «20/40/45 pies» | Consistente con la Lista; un 45G1 sigue contando como 40 pies |
| 5 | **Acepto** las categorías «Sin…» | Conservan el universo del total y aparecen en la tabla cuando corresponde |
| 6 | **Acepto** ocultar tarjetas especiales en cero | «Sin carga especial» explicita la ausencia; la tabla conserva los ceros |
| 7 | **Acepto** tabla como estado, sin ruta nueva | Esc y Atrás la cierran y dejan disponible la navegación del cliente |
| 8 | **Acepto** cifras de 28 con rótulo, sin tarjetas | La cifra de 48 conserva la jerarquía; los valores se ajustan sin cortes |
| 9 | **Acepto** mostrar el único código sobrante | Evita esconder un código bajo «Otro»; la suma se conserva |
| 10 | **Acepto** cifra y porcentaje a la derecha de la caja | La variante apilada mantiene las cifras enteras a 360 y 2.0 |
| 11 | **Acepto** panel con título y leyenda | La estructura es coherente; H1 y O1 evalúan el dibujo y la muestra concretos |
| 12 | **Acepto** tabla horizontal e iconos cuando no caben rótulos | Los números siguen en sus filas; Windows conserva nombre y rol de cada segmento |
| 13 | **Acepto** anillo que crece con la letra | Conserva el porcentaje en el hueco sin invadir el arco |

Aceptar estas desviaciones no sustituye el criterio de protagonismo visual de la propuesta A.

## Lo común de 0.9.3 y la rampa

**Pasa:** colores del tema y roles; ningún `Colors.*` en presentación; color de puerto contenido en su caja; ausencia del naranja de la grúa en los gráficos; texto en tintas o texto de su rol sobre su relleno, sin pintar cifras con el color de la barra; tipo oración, porcentajes con espacio duro, Plex Mono para códigos y mínimo 11 en el teléfono. Techo 1440 centrado, tabla con correspondencia de cifras y desplazamientos explícitos para lo que no cabe. Los recorridos de 360 × 2.0 no detectaron cortes del contenido de Estadísticas.

La cifra protagonista es **48 / 600 / 1.05**, una por vista; está documentada en 4.2 y 15.2 y definida en `BsEscala.cifraProtagonista`. 5.5 remite a la rampa nueva de 15.3. El color del texto de un rol es el definido para leerse sobre su relleno; no es una barra convertida en texto.

Ejecuté el **script original** `validate_palette.js --ordinal`, hallado en las skills empaquetadas de Claude en `%TEMP%`. Se guardan ruta, SHA-256, argumentos, salidas y comparación de las tres copias encontradas en `paleta-skill.json`. El directorio empaquetado conservaba scripts y referencias, sin `SKILL.md`; usé las instrucciones de ejecución del propio script, sin modificarlo.

| Tema y fondo | Extremo cercano al fondo | Resultado del script |
|---|---:|---|
| Día, hoja `#FFFFFF` | 2.19:1 | PASS, salida 0 |
| Día, papel `#F5F8FC` | 2.06:1 | PASS, salida 0 |
| Noche, panel `#0C1A31` | 2.62:1 | PASS, salida 0 |
| Noche, papel `#07111F` | 2.86:1 | PASS, salida 0 |

Las cuatro corridas pasan monotonicidad, separación de luminosidad y un solo tono. Mi cálculo independiente coincide. `paleta-exploratoria.json` conserva una comprobación adicional sobre superficies altas: la rampa de día no llega allí al umbral del paso claro, pero **esas superficies no son el fondo de las barras de T-121**. La aceptación aplica los cuatro fondos de 0.9.4; no extiendo el resultado a superficies donde no se usa.

## Accesibilidad y clientes aislados

**Windows:** EXE propio de `%TEMP%\t121-codex-f324499\copia\build\windows\x64\runner\Release\baystream.exe`, compilado con `tool/t99_main.dart`, `T99_ALMACEN=…\t121-codex-f324499\almacen` y namespace **t121acc**. Se abrió mediante `explorer.exe` y un lanzador propio con las variables de T-99. Hay doce archivos del almacén propio, con nombres y huellas en `windows-verificacion.json`. No se abrió el almacén instalado de BayStream.

A 700, claro y 1.0, y a 360, oscuro y 2.0, los árboles **UIA y MSAA** dicen «Contenedores» y «Peso» una sola vez, con rol de botón; UIA ofrece Invoke. Las bahías tienen número, cuenta, peso y zonas en el nombre, una vez. «Ver como tabla»/«Ver como gráficos» conservan nombre y rol. El cambio a Peso se observa en el nombre del contenedor del buque; Esc devuelve los gráficos; tocar la 06 abre la rejilla de la 06. Los JSON y PNG están en `windows/`.

**Web:** Chrome visible con perfil temporal propio, servidor limitado a `127.0.0.1:59121`, sin Firebase. La escala de letra se impone mediante el envoltorio de prueba de T-99; no se presenta como un cambio de letra del sistema de Chrome. La identidad del cliente y sus almacenes son los del banco.

En las 60 condiciones se usaron los cinco tamaños, dos letras, dos temas y los tres EDI. Cada condición abrió una tabla, la cerró con Esc, cambió a Peso y abrió una bahía en el plano. Se exigió `document.visibilityState == visible` antes de cada captura. Los 45 avisos de `networkidle` de la corrida final son del instrumento: se esperó el árbol semántico y se comprobaron los estados de la interfaz; no se contabilizan como errores JavaScript ni como mediciones de latencia.

**Android:** solo `adb -s emulator-5554`; resolución 1080 × 1920, densidad 480, equivalentes a 360 × 640 dp con las barras del sistema. Paquete exclusivo **gt.cmartinez.baystream.t121acc**, firmado para desarrollo en la copia. Las etiquetas de los iconos conservan el nombre y su rol de opción; el salto de línea inicial que devuelve Android se normaliza en el instrumento. Atrás cierra la tabla y deja Estadísticas abierta. Las capturas se guardan solo después de comprobar el paquete visible y descartar texto de cuenta.

También se abrieron los EDI de 977 y carga desde la carpeta exclusiva `/sdcard/Download/t121acc/`, dejándolos en previo. El de carga mostraba «confirma la escala», sin escala confirmada. Se recorrieron sus gráficos y tablas; la silueta de 72 bahías llegó a la 95 y tocarla mostró sus celdas en el plano. El emulador termina con la letra **1.0**, como al inicio, y el banco cerrado; el paquete de prueba queda instalado. No se cambió la densidad ni se tocó otro dispositivo.

En los bancos que publican la llegada mediante T-99 la escala elegida por su propuesta fue PAMIT. No la presento como una operación de descarga aceptada en GTSTC: esta aceptación compara Estadísticas, y la matriz aislada fuerza explícitamente la condición sin escala. No se prueban ni corrigen los hallazgos del piloto.

## La pregunta de 10.52: 21, 22 y 23

Usé un viaje sintético con **dos contenedores de 20 pies en 21, tres de 40 pies en 22 y uno de 20 pies en 23**, todos a 10 000 kg, en bodega. No hay datos de una operación real.

| Proyección | 21 | 22 | 23 | Total |
|---|---:|---:|---:|---:|
| Estadísticas T-121 | 2, 20 t | 3, 30 t | 1, 10 t | 6, 60 t |
| Avance actual | «21/22»: 5 pendientes | Dentro de «21/22» | «23»: 1 pendiente | 6 pendientes |

**Cómo dibuja T-121:** tres columnas distintas en el orden 21, 22, 23, con la cuenta y el peso de la posición física. Las pilas se normalizan al mismo máximo de todo el buque. Las sombras de los de 40 en las impares vecinas no se vuelven a contar como contenedores. Tocar cada columna selecciona su número físico.

**No coincide con la agrupación de Avance:** `LoadingOperation.displayBay(22)` devuelve 21 cuando existe la 21, y `OperationProgress` rotula ese grupo «21/22». La prueba propia produce exactamente los dos grupos de la tabla. T-121 tampoco agrupa las dos mitades bajo la par como propone Carlos: conserva las tres posiciones por separado.

Evidencia: caso propio «21 22 23», `propias.jsonl`, `cifras.json` (`comparacion212223`), y lectura de `estadisticas_del_viaje.dart`, `loading_operation.dart` y `operation_progress.dart`. **Es información para una sola regla futura; no afecta este dictamen ni autoriza un cambio de dominio.**

## Revisión del diff y protección del árbol

Guardé un diff por cada una de las **23 rutas** de `lib/`, `test/` y `tool/` contra `6be78e7`, incluidos los dos borrados. `revision-codigo.json` enumera cada ruta, su huella y el juicio de la revisión. Los otros dos archivos de la entrega son `DESIGN.md` y `docs/T117-T121-RESULTADOS.md`, leídos como contrato y evidencia de Timonel.

- T-97 conserva la comprobación de texto entero y añade el rótulo «contenedor a bordo»; T-107 conserva la navegación y el objetivo visible, con la clave de la protagonista.
- T-109 retira la referencia de píxeles de una pantalla sustituida; mantiene paridad de datos ancho/teléfono y fortalece el control de cifras enteras. La etiqueta larga pasa del diálogo antiguo a texto y semántica en la página; la excepción de palabra única artificialmente larga está expresamente escrita en esa prueba. No se utiliza para exceptuar los datos de la matriz propia.
- Los censos de T-98c solo retiran las entradas de `vessel_profile_view.dart`.
- Las tres pruebas borradas de la vista vieja se revisaron junto con T-121. Las nuevas cubren callback, recorrido de la silueta y apertura del plano; mis dos pruebas adicionales comprueban ajuste de desplazamiento al redimensionar y selección con reentrada.
- Los componentes nuevos, la derivación de cifras, las exportaciones, previews y los tres instrumentos de captura se revisaron por archivo. El código de producción cambiado permanece en presentación/diseño. Los números salen del `voyage` recibido por la página.

**No cambian `pubspec.yaml` ni `pubspec.lock` del repositorio.** Tampoco dominio, datos, `lib/main.dart`, las dos pantallas congeladas, Firebase, la lista del piloto, AGENTS, CLAUDE ni README. No se usó el Honor, la app instalada de Windows, «PRUEBA T-105» ni `baystream-demo17`; no se abrió un archivo del corpus ni se publicó nada. La evidencia de Timonel se leyó; no se modificó.

El único archivo persistente nuevo fuera de `build/` es **este informe**, `docs/t121/entrega2/aceptacion-codex.md`. Los instrumentos propios y la evidencia están en `build/t121-entrega2-aceptacion/`, ignorado por Git; su lista exacta y huellas quedan en `manifest.json`. La comprobación final del árbol se guarda en `arbol-final.json` y `integridad-final.json`.

**No incluyo comandos para añadir ni publicar el informe:** Carlos pidió moverlo personalmente al rediseño y no añadirlo a Git desde esta carpeta. Git se utilizó solo para lecturas; no se ejecutó `git status`.

## Tres líneas

Las cifras, las tablas, los tamaños y la accesibilidad comprobada sostienen la implementación.
La silueta de nueve bahías sigue sin cumplir el protagonismo «en grande»; la muestra de cubierta parece una casilla.
El producto queda intacto; Carlos recibe el informe, las salidas y las huellas para decidir la corrección visual.

## Mensaje para Yov

> Yov: T-121, entrega 2, **NO PASA** por la silueta pequeña y pegada a la izquierda con nueve bahías (P2). Acepto las trece desviaciones de 15.11; dejo la muestra de Cubierta como P3. Suite válida 1773/1773, analyze en cero y 66 pruebas propias; UIA/MSAA conserva nombres únicos incluso con iconos, y la rampa pasa las cuatro corridas del script original. Declaro en el informe los dos intentos inválidos de preparación de la suite. La comparación 21/22/23 es informativa: Estadísticas separa 2/3/1; Avance agrupa 5 bajo 21/22 y 1 en 23. Informe en `docs/t121/entrega2/aceptacion-codex.md`; evidencia y manifiesto en `build/t121-entrega2-aceptacion/`. No corregí ni publiqué el producto.

ALTO: Carlos decide
