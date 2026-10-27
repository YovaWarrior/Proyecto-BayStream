# NO PASA · T-122 · Aceptación de la 3.1.1 con corrección 1

**Capitán Codex · 26 de octubre de 2026.** Base `7488321`; HEAD separado `aa01c27eca3bb7e092006b16e50a7aec2e5a3979`, después de `d05bacf`. Se revisaron las 35 rutas del diff y las decisiones 10.49–10.52 y 10.55–10.58 del `SPRINT-4.md` del rediseño. Es una aceptación: no se corrigió el producto.

**Motivo del dictamen:** H4 permite registrar también un **vacío numerado del plan sin listado**. La decisión 10.51 y el encargo reservan esa excepción a los llenos. Se reprodujo mediante dominio y en Windows, llegando a registrar la carga en el almacén aislado. La corrección 1 de la salida del lleno sí funciona.

Evidencia propia: [resumen](../../build/t122-aceptacion/resumen.json), [manifest con SHA-256](../../build/t122-aceptacion/manifest.json). No se reutilizan como resultados propios las capturas de Timonel.

## 1. Hallazgo que impide aceptar

### A1 · P2 · H4: un vacío numerado se carga sin listado y con tara 0

**Reproducción:** abrir `T100_CARGA.edi` en el banco, elegir la escala GTSTC y actuar como muelle local, sin importar el listado. En «OR / últimos dígitos», buscar `811` o `MNLU0000811`. Elegir ese contenedor y confirmar la carga en `010-01-06`.

**Esperado:** ese vacío sigue necesitando su fila del listado. La excepción sin OR se aplica al lleno del plan.

**Observado:** se ofrece «sin OR en el listado», el diálogo muestra «Tara real: 0 kg» y deja confirmar. Tras confirmar queda «cargado»: los pendientes bajan de 30 a 29 y los vacíos de 10 a 9. El propio plano conserva el aviso de que los vacíos esperan el listado. No es una reserva sin número: el BAPLIE sintético declara este contenedor como `empty`.

El oráculo de dominio confirma `listado: null`, búsqueda disponible, `validate: null` y borrador `load_full` con solo `position`. `LoadingOperation.unlistedRows` no filtra `container.isEmpty`; `ExportListRow.fromPlan` contempla expresamente el vacío numerado. No hace falta nube ni un listado incompleto para reproducirlo.

**Evidencia:** [dominio](../../build/t122-aceptacion/vacio-sin-listado.json), [sonda ejecutada](../../build/t122-aceptacion/probe_vacio_sin_listado.dart), [búsqueda Windows](../../build/t122-aceptacion/windows/h4-vacio-sin-listado-busqueda.png), [confirmación](../../build/t122-aceptacion/windows/h4-vacio-sin-listado-confirmar.png), [carga registrada](../../build/t122-aceptacion/windows/h4-vacio-sin-listado-registrado.png), junto con sus árboles accesibles `.txt`.

**Para Carlos:** devolver para corrección del filtro y de la validación del borrador, o decidir explícitamente si cambia la regla para los vacíos numerados. No se modificó ninguna de esas rutas durante esta aceptación.

## 2. Resultado por hallazgo solicitado

| Caso y prioridad original | Resultado y reproducción propia | Evidencia |
|---|---|---|
| H1 · P1 | **PASA.** Importar la llegada T122, abrir parámetros y elegir GTSTC (7), aunque LOC+61 sea otro puerto: aparece Descarga. Oráculo independiente: GTSTC 7, CRPMN 4, USHOU 2; historial de descarga propuesto; puerto ajeno descartado; se conserva la regla sin LOC+61. Diálogo probado a 360 dp. | `pruebas-propias.json`, `propias-final.jsonl`; Web `claro/oscuro-h1_*`; Android `emulador_claro_h1_*`. |
| H3 · P2 | **PASA. Acepto contar en «AGREGADOS», separado de la última agencia.** Importar el XLSX T122: 14 filas, A=9, B=3, AGREGADOS=2. Se comprueban también los OR 21 y 22 en esa sección y OR 14 en B; ninguna fila se pierde. | Oráculo XLSX en `codex_t122_test.dart`, `pruebas-propias.json`; Web y Android `h3_agregados` y `h3_importado`. |
| H4 · P1 | **PARCIAL; NO PASA por A1.** El lleno TSTU0220071 sin fila se confirma desde su celda y se registra sin clave `order`. La oficina abre detalle y no confirma carga. El selector de vacíos sin listado no ofrece reservas para asignar; esa restricción se elude por el vacío numerado de A1. | Dos casos widget de rol, caso de serialización en `propias-final.jsonl`; Web y Android `h4_*`; A1 Windows. |
| H4 corrección 1 · P1 | **PASA para el lleno.** Cargar un lleno T100 sin fila en una celda distinta de la prevista y generar salida: se conserva el grupo EDIFACT del plan (incluido un FTX sintético añadido como oráculo), cambiando solo LOC+147 a la celda real; peso WT conservado y VGM ausente. La página enumera TSTU0220071 como lleno que sale con datos del plan y permite guardar. | `salida-sin-fila.edi`, `pruebas-propias.json` H4c1; Web `claro/oscuro-c1-salida-con-datos-plan.*`; Android `emulador_claro_c1_salida_con_plan.*`. |
| H5 · P2 | **PASA.** Cargar OR 1 en la 22: el avance y la silueta suben bajo la par. El oráculo agrupa 21/22/23 en 22 conservando la posición física. **Acepto el P3 de 10.57:** una par de 40 solo en llegada no basta para emparejar las dos mitades del plan de carga; el caso derivado exige filas 21,22,23 independientes. | `pruebas-propias.json` H5P3, casos widget/dominio; Web y Android `h5_silueta_22` y `h5_avance_22`; diff T-76 y T-78. |
| H6 · P1 | **PASA.** Asignar OR 12 / TSTU0012123 a 021-00-84; buscar `123` en OR/dígitos y el número completo en búsqueda general: aparece cargado, con posición, se selecciona la bahía y se resalta. La Lista derivada lo incluye. Deshacer elimina el vacío derivado y vuelve a dejar la reserva. | Dos casos propios en `propias-final.jsonl`; Web y Android `h6_*`; Web `claro/oscuro-h6-lista-con-vacio.*`. |
| H7 · P2 | **PASA en los casos verificados.** Mantener un contenedor pendiente, llevar el puntero al borde, esperar sin moverlo y soltar en una celda del extremo que apareció. El diálogo coincide con la celda observada. Pruebas a 360 dp con touch/mouse, zoom 100/150 %, ambos sentidos; nativos detallados debajo. Los gestos nativos se cancelaron. | `foco-oraculos/arrastre-propio.json` (8 sentidos), `foco-oraculos.jsonl`, carpetas `windows/`, `web/`, `android/`. |
| H2 · P1 diferido | **NO IMPLEMENTADO, conforme al alcance.** El bloqueo local y el manifiesto inmutable explican el problema del listado posterior a publicar. No se probó ni cambió Firebase. La propuesta necesita decisión de Carlos; dos precisiones documentales se indican en la sección 5. | Prueba propia de `OperationSources.save`, `revision-codigo.json`, lectura de sección 8 y `docs/T80-firestore.rules.propuesta`. |

Los nombres relativos de evidencia de esta tabla se resuelven bajo `build/t122-aceptacion/`; el manifest enumera cada archivo y su huella.

## 3. Ejecución y regresión

**Copia cotejada antes de la primera corrida.** Se copiaron 746 archivos de fuentes, pruebas, recursos y configuración a `C:\Users\Giova\AppData\Local\Temp\t122-codex-aa01c27\copia`, sin instrumentar el banco todavía. El primer cotejo dio cero faltantes/diferencias; después de `pub get`, solo difería `GeneratedPluginRegistrant.java`, generado por Flutter. Identidad Android y pubspec seguían originales. Constan exclusiones y huellas en `arbol-inicial.json`, `cotejo-antes-pub.json` y `cotejo-antes-suite.json`.

- **Suite del producto: una corrida, 1401/1401, cero fallidas y cero omitidas**, sin reintentos. Piso de master 1371; incremento 30 (25 de T122 + 5 de c1). `suite.jsonl`, `suite-resumen.json`, salida 0.
- **Analyze de toda la copia limpia: cero incidencias**, salida 0 (`analyze.txt`). Se ejecutó antes de añadir las pruebas propias y la instrumentación.
- **17 casos propios con resultado válido aprobado:** 12 de dominio/widget del primer recorrido, 4 de arrastre en el recorrido específico y 1 de regresión al terminar de ajustar su oráculo. No hubo una corrida única final de esos 17 casos: se preservan los intentos y su procedencia en `pruebas-ejecuciones.json`.
- Compilaciones release de Windows, Web y Android, secuenciales, con salida 0. Binarios y huellas en `binarios.json`; logs `build-*.txt`. Ningún comando Flutter simultáneo.

**Regresión T100 sin nube:** leer llegada, carga y listado sintéticos; guardar las tres fuentes; descargar 30; cargar un lleno, deshacerlo y volver a cargarlo; asignar un vacío; pedir un cambio entre dos pendientes como muelle; generar y volver a interpretar la salida. El cambio queda solicitado, sin alterar todavía el plan. Resultado: 32 contenedores (30 de tránsito + lleno + vacío), cero descargas pendientes, 28 cargas pendientes y ningún conflicto. Se exige el conjunto exacto de números, no solo la cantidad.

El T100 original trae vacíos **numerados**, no reservas sin número. Para la rama de asignación se derivó una sola reserva dejando vacío el EQD del primer vacío; se conserva el original intacto y se entrega `T100_CARGA-reserva-derivada.edi`. La conversión de tipos del listado a sus ISO se declara en la prueba. Esto evita fingir que el fixture original contenía una reserva. Evidencia: `regresion-final-valida.jsonl`, `regresion-final-valida/pruebas-propias.json` y `regresion-final-valida/regresion-salida.edi`.

**Intentos propios conservados:** hubo un error de compilación por nulabilidad en mi prueba; cuatro oráculos de arrastre inicialmente buscaron una celda en el margen exterior; la regresión supuso una reserva inexistente en T100, luego consultó la posición del estado en vez de la del plan y finalmente necesitó crear la carpeta de salida. Se corrigieron solo las pruebas/instrumentos propios y se ejecutaron los casos afectados. Los logs rojos no se borraron ni se contabilizan como fallos de la suite del producto.

## 4. Clientes y aislamiento

| Cliente | Verificación nativa propia |
|---|---|
| Windows | Exe del banco abierto mediante `explorer.exe → abrir.cmd → exe`, almacén explícito `C:\Users\Giova\AppData\Local\Temp\t122-codex-aa01c27\almacen`, namespace `t122acc`. Se registró A1 con T100 y se importó T122 para H7. Mouse al 100 %, derecha: 022-10-82 → 022-09-84; al 125 %, izquierda: 022-04-82 → 022-10-84. Vista lógica de banco 700×800 dentro del cliente físico 1582×853. `windows-verificacion.json`. |
| Web | Chrome visible, perfiles temporales distintos bajo la carpeta del banco, almacenamiento aislado y servidor 127.0.0.1:59123. H1/H3/H4/H5/H6 y página c1 en claro/oscuro a 1920×1080. Mouse a 700×800, 100 % en ambos temas y 125 % en recorrido específico: 022-10-82 → 022-09-84. `web/zoom125-resultado.json`, capturas y `web-verificacion.json`. |
| Android | Solo `adb -s emulator-5554`; paquete exclusivo `gt.cmartinez.baystream.t122acc`, etiqueta BayStream T122 ACC. 1080 px / densidad 480 = **360 dp**, fuente 1.0, conservada. H1/H3/H4/H5/H6, página c1 y touch H7: al 100 %, derecha, 022-10-82 → 022-09-84; al 125 %, izquierda, 022-09-82 → 022-10-84. `android-verificacion.json`, `android/zoom125-estable-resultado.json`. |

Las pruebas de rol de oficina, codec sin `order`, deshacer y solicitud de cambio también están cubiertas de manera independiente en dominio/widget; no se presenta esa regresión en memoria como una secuencia nativa completa repetida en cada sistema.

La instrumentación vive solo en la copia temporal: entrada del banco, selector sintético ampliado a T100, repositorios locales con almacén explícito y paquete Android propio. No inicializa Firebase. El panel puede marcar una operación como «publicada» **solo localmente**, para habilitar cambios con actores sintéticos. No hubo publicación remota. Se conservan `t122_main-instrumentado.dart`, scripts y `instrumentacion.json`.

El control de escritorio alternativo no pudo inicializar sus assets. Para el gesto largo de Windows se usó la excepción 10.41 autorizada: script de mouse que comprueba PID/ruta exacta del banco, limita coordenadas a su cliente y libera siempre el mouse. La exploración y los árboles se tomaron con el control de ventanas. No se controló ninguna app instalada de BayStream.

Los primeros intentos de Chrome no levantaron el gesto; otro intentó reutilizar un perfil y otro seleccionó un ancestro semántico en vez del botón de zoom. En Android, dos intentos de zoom colocaron el dedo también en la franja del autoscroll vertical, de modo que una coordenada anterior dejó de ser una celda al soltar. El recorrido válido mantiene origen/destino fuera de esa franja vertical y coteja la celda inmediatamente antes de soltar. Estos intentos permanecen en los logs; no se califican como regresiones de H7.

## 5. Observaciones sin cambio de producto

### O1 · P3 documental · Matices del diagnóstico H2

**Reproducir:** comparar 8.2 con `FirestoreOperationSync.join`, y 8.3 punto 4 con el escritor después de c1. `join` itera los tipos del manifiesto: los trozos de un tipo que no figura allí se ignoran. Para un tipo declarado sí se rechazan cantidades/huellas incompatibles. Por tanto, no todo trozo huérfano rechaza la operación entera. El manifiesto sigue siendo inmutable según las reglas leídas, así que el diagnóstico central y la necesidad de un diseño de revisión siguen correctos.

8.3 también conserva «departure_baplie_writer.dart exige la fila» para el lleno: esa frase quedó anterior a 8bis. C1 permite su grupo original del plan. Evidencia: `revision-codigo.json`, diff de `departure_baplie_writer.dart` y prueba propia H4c1. No se editaron el informe de Timonel ni las reglas.

### O2 · P3 · Excepción inicial del banco Web, sin bloqueo visible

**Reproducir:** abrir el banco release Web servido localmente en un perfil temporal nuevo de Chrome y escuchar `pageerror`, sin importar archivos. Se recibe `Error`; la pila lleva a la lectura de tamaño de un RenderBox sin layout y al recorrido de foco. Se aisló con y sin activación de semántica: aparece antes de activarla en ambos casos. La portada se dibuja y los recorridos posteriores funcionan.

Evidencia: `web/error-inicial-aislado.json`, `web/arranque-sin-semantica.png`, `web/arranque-con-semantica.png`, `web/zoom125-errores.json`. No se atribuye a una ruta concreta del cambio T122 ni se afirma que la consola Web esté libre de errores; falta aislar su relación con el panel del banco. No es el motivo de NO PASA.

## 6. Reglas, pruebas antiguas y estado entregado

- T-68 ahora acepta el puerto de descarga del historial y sigue rechazando el ajeno; conserva el caso sin LOC+61. T-76 exige referencia par para 03/04, manteniendo posición física. T-78 exige tres filas sin emparejar cuando el 40 solo está en llegada y conserva pesos por pila. T-82 exige peso del plan, VGM ausente y `withoutRow`, y conserva el rechazo del vacío asignado sin fila. T-93 cambia solo la versión esperada del MSIX, manteniendo identidad y permisos. No se sustituyen controles por aserciones más débiles.
- Una carga del lleno sin OR carece de la clave `order` en borrador, JSON de movimiento y codec de Firestore: no se envía `null`. Se contrastó con `validPayload` de las reglas locales, sin contactar Firebase.
- `pubspec.yaml`: cambios de producto limitados a **3.1.1+5** y MSIX **3.1.1.0**. `pubspec.lock` no cambia contra la base. El `version.json` de **mi compilación Web** declara `3.1.1` y `5` (`version-web.json`). No se construyó ni instaló un MSIX sobre la app de oficina.
- Sin diff contra la base en `lib/main.dart`, opciones Firebase, reglas, congelados ni lista del piloto. Ninguna directiva Dart `// ignore:` agregada. `revision-codigo.json` y los 35 diffs entregados permiten repetir la revisión.
- Solo sintéticos T122/T100 y la derivación declarada. No se usaron datos reales, Honor, apps instaladas de BayStream, PRUEBA T-105, demo17, proyecto-baystream ni Firebase. Se usaron únicamente los helpers de memoria de pruebas anteriores, sin sus datos operativos.
- Árbol original cotejado al terminar: ningún archivo preexistente alterado; fuera de `build/t122-aceptacion/`, solo nace **`docs/t122/aceptacion-codex.md`**. Cotejo final y diferencias de la copia en `integridad-final.json`. Informe sin añadir a Git. Windows y el banco Android quedan cerrados; perfiles y almacenes aislados quedan en temporal para revisión. Servidor local detenido al cerrar la aceptación.

**Mensaje para Yov:** T-122 c1 NO PASA por A1/P2: el vacío numerado de T100 MNLU0000811 se carga sin listado, como `load_full` y con tara 0. El lleno sin fila y su salida c1 pasan; H1/H3/H5/H6/H7 también en los casos documentados. Suite única 1401/1401 y analyze cero. Acepto AGREGADOS aparte y el P3 de la par solo en llegada. H2 sigue diferido, con dos precisiones documentales. Producto intacto; informe y evidencia listos para Carlos.

ALTO: Carlos decide
