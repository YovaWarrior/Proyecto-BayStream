# PASA · T-123: la 3.1.1 dentro del rediseño

**Capitán Codex · aceptación de las decisiones 10.63 y 10.64.** Se acepta el comportamiento de la 3.1.1 integrado en el rediseño. No encontré un defecto nuevo del producto que bloquee T-123. La ficha de la bahía queda como **P2 de T-124**, expresamente fuera de esta aceptación.

Trabajé en `C:\Proyectos\baystream-qa-r4`, con HEAD separado en **b6a8d9597cf450a6722c2576cf36378023287f2e**. Debajo está la mezcla **169fd9c**, con padres **e4156ad** y **34d8838**; base común **38965b8**. Leí AGENTS completo, las decisiones indicadas y los informes T-123 y T-122. Git se usó únicamente para lecturas; no se ejecutó `git status` ni se añadió nada a Git. No corregí el producto.

La evidencia propia está en [build/t123-aceptacion](C:/Proyectos/baystream-qa-r4/build/t123-aceptacion), con [resumen.json](C:/Proyectos/baystream-qa-r4/build/t123-aceptacion/resumen.json) y [manifest.json](C:/Proyectos/baystream-qa-r4/build/t123-aceptacion/manifest.json). Los registros fallidos del instrumento se conservan y se distinguen de las comprobaciones finales.

## 1. Identidad, copia limpia y comprobaciones obligatorias

Antes de Flutter tomé huellas de **1885 archivos** del árbol, con las exclusiones de artefactos que declara `preparar.py`. Copié **777 archivos** de fuente y configuración a `C:\Users\Giova\AppData\Local\Temp\t123-codex-b6a8d95\copia`. Antes de resolver paquetes, los 777 coincidían. Después de resolverlos y **antes de la primera corrida**, solo había cambiado el registrador Java generado; fuentes, pruebas, identidad Android y pubspec conservaban el original. Esto queda en [cotejo-antes-pub.json](C:/Proyectos/baystream-qa-r4/build/t123-aceptacion/cotejo-antes-pub.json) y [cotejo-antes-suite.json](C:/Proyectos/baystream-qa-r4/build/t123-aceptacion/cotejo-antes-suite.json).

| Comprobación propia | Resultado |
|---|---|
| Suite del producto, una sola ejecución | **1821/1821**, cero fallos, cero omitidas, cero eventos de error; exit 0 |
| Análisis de la copia limpia, antes de instrumentarla | **Cero problemas**, exit 0 |
| Casos propios de la 3.1.1 y la mezcla | **31 únicos**: 30 funcionales y una observación del T-124 excluido |
| Estadísticas, matriz y oráculos propios | **93/93**, sin omitidas; incluye la matriz de 80 combinaciones |

La corrida conjunta propia terminó con 27 éxitos y cuatro fallos de preparación de H7 de oficina. Esos cuatro casos se comprobaron después con el origen descubierto y un destino compatible de 40 pies: **4/4**, con ocho gestos, dedo/mouse × zoom 100/150 × eje horizontal/vertical. No presento la corrida conjunta como aprobada ni esos intentos como una repetición de la suite del producto. No se modificaron sus 1821 pruebas.

Evidencia: [suite-resumen.json](C:/Proyectos/baystream-qa-r4/build/t123-aceptacion/suite-resumen.json), `suite.jsonl`, [analyze.txt](C:/Proyectos/baystream-qa-r4/build/t123-aceptacion/analyze.txt), `propias-conteo.json`, `h7-verificado-conteo.json`, `estadisticas-conteo.json` y los cinco archivos `codex_*_test.dart` guardados en la evidencia. La adaptación de montaje y sus intentos están documentados en `adaptaciones-pruebas.json` y los registros `propias-intento*` y `h7-*`.

## 2. Revisión de la mezcla y las reglas

Revisé las **45 rutas** de `git diff e4156ad HEAD~1`, individualmente; sus diffs están en `diff-mezcla/`. Para los cinco archivos tocados por ambos lados conservé y contrasté `git diff 38965b8 34d8838` y `git diff 38965b8 e4156ad`, en `dos-lados/`.

Las dos importaciones conviven en `vessel_overview_page.dart`. `loading_controls.dart` conserva las fichas y `soloIcono`, con la disponibilidad por plan leído. `resumen_del_modo.dart` expresa la regla nueva: los llenos se cargan por número sin listado y los vacíos esperan su fila. Las llamadas de la franja y la tira conservan ese comportamiento. H6 mantiene el resaltado del vacío asignado. H7 usa el desplazable vertical de la columna completa en oficina y los de la rejilla en el teléfono.

Los **nueve archivos de domain/data que entran coinciden exactamente con master 34d8838**. No aparece dominio adicional. `lib/main.dart`, los dos congelados, la lista del piloto y `pubspec.lock` no cambian respecto de e4156ad; no entran opciones de Firebase ni reglas, ni se agrega ningún `// ignore:` en Dart. Estadísticas conserva el código aceptado en 10.55.

Las pruebas de pantalla de T-122 solo incorporan la vista de **360 × 800**, DPR 1 y su restauración; siguen comprobando el muelle y conservan sus expectativas. T-123 agrega la oficina. Revisé también las expectativas de T-68, T-76, T-78, T-82 y T-93 que trajo master: conservan casos negativos y comprobaciones de la regla nueva; no se sustituyen por aserciones débiles. En particular, T-78 conserva el caso de 40 pies solo en llegada y T-82 rechaza el vacío sin fila.

La versión es **3.1.1+5** y la configuración MSIX es **3.1.1.0**. Tanto `version.json` de mi banco Web como el del control T-99 dicen **3.1.1 / 5**. No compilé ni instalé un MSIX. El APK aislado confirma versionName 3.1.1 y versionCode 5. Evidencia: [revision-codigo.json](C:/Proyectos/baystream-qa-r4/build/t123-aceptacion/revision-codigo.json), `head.json`, `rutas-mezcla.txt`, `comparacion-master-*.diff`, `version-web.json`, `version-web-t99.json` y `apk-identidad.txt`.

## 3. Matriz funcional propia

| Criterio | Oráculo y resultado | Evidencia propia principal |
|---|---|---|
| **H1 · PASA** | LOC+61 no impone el puerto operativo. GTSTC ofrece **7** descargas, CRPMN 4 y USHOU 2; la historia confirmada propone GTSTC al reimportar. «Descarga» aparece. En Windows descargué un contenedor de esa escala y deshice: volvió de 1/7 a 0/7. | `propias/pruebas-propias.json`; `windows/h1-*`; `web/llegada-claro-resultados.json`; `android/h1_*` y `h1-descarga-gtstc.png` |
| **H3 · PASA** | El XLSX de 14 filas produce **AGENCIA A: 9, AGENCIA B: 3, AGREGADOS: 2**. **Acepto contar las dos filas en AGREGADOS y no sumarlas a la última agencia**: el encabezado separa esa sección. | `propias/pruebas-propias.json`; `windows/h3-*`; `android/h3-*`; recorrido Web de carga |
| **H4 y correcciones 1/2 · PASA** | Sin listado se ofrece y carga el lleno, por celda o número, sin OR. Vacío numerado y estado desconocido quedan fuera de búsqueda, su celda avisa que espera el listado y el borrador los rechaza incluso con una fila falsa de lleno. La sonda usa el **MNLU0000811 de T100**. Con listado, ese vacío se carga por OR 28 y tara **3900 kg**. Oficina solo muestra el detalle pendiente; no confirma una carga. | `propias/a1-resultados.json`; `codex_a1_test.dart`; `windows/vacio-*`, `sin-estado-*`, `lleno-sin-fila-confirmacion.*`, `oficina-no-registra-carga.*`; `web/t100-claro-1-resultados.json`; `android/vacio-*`, `sin-estado-*` |
| **H4 · salida y regla publicada · PASA** | El lleno sin fila sale en su **celda real**, conserva el grupo EDIFACT del plan —incluidos textos y medidas— salvo la posición que corresponde al movimiento. El caso con WT y sin VGM mantiene **VGM nulo**. El movimiento y su codificación remota **no contienen la clave `order`**. La página avisa que TSTU0220071 usa los datos del plan. | `propias/salida-sin-fila.edi`; oráculos en `codex_t122_test.dart`; `windows/matriz-salida-datos-del-plan.*`; `android/salida-lleno-sin-fila.png`; salida Web |
| **H5 · PASA** | Silueta del plano y Avance usan la referencia **22**, sin duplicar 21/23. El caso P3 de 10.57 conserva 21, 22 y 23 **sin emparejar** cuando los 40 pies solo están en llegada; no se inventa la relación a partir de ese plano. | `propias/pruebas-propias.json`, campo H5P3; `windows/h5-*`; `android/propio_h5_*`; recorrido Web |
| **H6 · PASA** | OR 12, TSTU0012123, asignado a **021-00-84**, aparece como cargado en «OR / últimos dígitos», en búsqueda general con esa celda y en la Lista de 26; al elegirlo resalta la reserva. La tarjeta de Lista conserva tara/peso bruto **2185 kg**. | `windows/h6-*`; `android/h6-busqueda-celda.png`, `h6-resaltado.png`, `h6-lista-vacio-celda.png`, `lista_fin-resultados.json`; recorrido Web |
| **H7 · PASA** | El borde desplaza el plano mientras se sostiene el contenedor y la confirmación usa la celda bajo el puntero al soltar. Se verificó con dedo y mouse, ambos sentidos, con/sin zoom; en oficina el vertical más cercano es **columna-del-plano**. | `propias/arrastre-propio.json`; [h7-verificado/mezcla-propia.json](C:/Proyectos/baystream-qa-r4/build/t123-aceptacion/h7-verificado/mezcla-propia.json); matriz nativa de la sección 4 |

H2 continúa sin implementarse. La comprobación propia de inmutabilidad de las fuentes y la lectura del código concuerdan con el diagnóstico aceptado de T-122; esta mezcla no cambia las reglas ni resuelve ese flujo por otra vía.

La regresión propia importa **las tres fuentes sintéticas**, descarga 30, carga, deshace y vuelve a cargar, asigna un vacío, registra una **solicitud pendiente** y genera el BAPLIE. Resultado: **32 contenedores exactos en la salida, dos cargas netas, 28 pendientes de carga y cero conflictos**. La solicitud no se aplica como movimiento confirmado. Se verifica la lista exacta de números y el grupo de salida, además de las cuentas. Evidencia: `codex_t122_test.dart`, `propias/pruebas-propias.json` y [regresion-salida.edi](C:/Proyectos/baystream-qa-r4/build/t123-aceptacion/propias/regresion-salida.edi). Los recorridos nativos complementan esa regresión; no se atribuye al clic de «Guardar» un archivo que no se haya guardado.

## 4. Los tres clientes y el rediseño

| Cliente propio | Verificación directa |
|---|---|
| **Windows** | Banco abierto mediante `explorer.exe`, separado de la app instalada. H1, H3, H4/A1, H5, H6, salida y Estadísticas; Oficina sin registrar cargas. H7 mouse a **100 y 125 %**, levantamiento visible, desplazamiento al borde y confirmación exacta **022-10-82 → 022-09-82**; cancelado. También observé el desplazamiento vertical de la columna completa manteniendo el contenedor levantado; solté fuera de celda en esa observación. |
| **Web · Chrome visible** | Perfiles temporales, localhost. H1 y recorrido H3/H4/H5/H6/salida completados; T100 A1 completo con/sin listado. H7 en perfiles independientes a **100 y 150 %**, oficina 800 × 600: el extremo desplaza y confirma **022-09-82** bajo el mouse; cancelado. El control propio T-99 importa el 977 y abre Estadísticas sin errores JS. |
| **Android · emulator-5554** | Paquete propio `gt.cmartinez.baystream.t123acc`, **360 dp**, sin tocar el Honor. H1, H3, A1, H4/H5/H6, Lista, salida y Estadísticas. H7 dedo a **100 % hacia la derecha** confirma 022-09-82 y a **150 % hacia la izquierda** confirma 022-10-82; levantamiento y destino visibles, liberación en finally y cancelación. |

Las fichas conservan cifras y el aviso nuevo. A 1366 con letra 1.45 aparece la variante **solo icono**, disponible y con su descripción. En Windows «Acciones» tiene nombre de botón también al reducir la vista y abre el menú; véase `windows/oficina-corta-acciones-icono.*`. Los casos propios montan la página completa con el tema y las fuentes del producto, además del plano del muelle.

**Estadísticas conserva «El buque en corte».** La matriz propia combina cuatro datasets, cinco anchos **1920/1366/960/700/360**, letra **1/2** y los dos temas. Los oráculos adicionales comprueban tres/cuatro bahías, geometría, pie en su eje, navegación y leyenda como texto. Con nueve bahías ocupa el ancho útil sin desplazamiento; con pocas llega al tope y centra el casco. La altura amplia crece hasta 1.5 veces; el teléfono y el caso largo mantienen el mínimo escalado y el desplazamiento con barra. Las 72 bahías del 977 siguen desplazándose. La regla de agrupación de Estadísticas se deja para T-124.

Miré las pantallas, incluida la Web T-99 con T100 a 1920 y 1366 y el 977: **la protagonista cumple «en grande»**. La franja vacía sobre el casco sigue visible cuando cubierta lleva poca carga; corresponde a la escala común de DESIGN 15.4 y no reduce el ancho ocupado por la silueta. La muestra de la leyenda se reconoce como pila y conserva semántica de texto. Evidencia numérica y capturas en `estadisticas/`, `web-t99/`, `windows/estadisticas-*`, `android/propio_estadisticas.png` y `android/oscuro_estadisticas.png`.

## 5. Hallazgos y límites del instrumento

### T124 · P2 · Rótulo de la ficha con cifras de otra bahía · fuera de T-123

**Reproducción:** importar el plan sintético T-122, entrar en Carga y elegir **21**. La ficha dice «Bahía 22: **7 contenedores, 1 celda reservada, 57.7 t**…; por cargar cub. 27». Esas primeras cifras pertenecen a 21; la bahía física 22 tiene 11 contenedores. Confunde la identidad de la cifra operativa y merece **P2 antes de 3.2.0**. Está expresamente asignado a T-124 en 10.64, por lo que no bloquea este dictamen. Evidencia: caso propio T124 en `propias/mezcla-propia.json` y `windows/h6-vacio-resaltado.*`.

### O1 · P3 · El conductor de arrastre puede dejar el contacto activo

**Reproducción del defecto de instrumento:** hacer DOWN con trackingId 1, abortar antes de UP y volver a mandar DOWN con ese mismo identificador. Mi control negativo en emulator-5554 no levanta la celda; después de liberar el contacto, los gestos completos a 100/150 sí la levantan y confirman el destino correcto.

Los registros de Timonel muestran un aborto en **09c antes de `dedo_arriba`**; su conductor no garantiza la liberación con `finally` y reutiliza el identificador. Ese mecanismo explica por qué **09d/09e no bastan para demostrar un fallo del producto**. No aislé la causa inicial del aborto 09c. La evidencia propia demuestra el problema del instrumento y verifica el producto por separado; no atribuyo al producto las dos corridas sin levantamiento. Recomendación para el conductor: liberar siempre, comprobar la celda completa y exigir feedback antes de evaluar el borde. No modifiqué su código.

Evidencia: `referencia-timonel/09c-android-claro-desde-h4.log`, `09d-android-claro-h7.log`, `09e-android-oscuro.log`, las sondas de referencia, `android/control-contacto-repetido-no-levanta.png` y [android/h7-comprobado.json](C:/Proyectos/baystream-qa-r4/build/t123-aceptacion/android/h7-comprobado.json).

### O2 · P3 · Error inicial del panel de prueba T-122

**Reproducción:** abrir el banco Web T-122 con un perfil temporal nuevo: registra un `Error` inicial. Mi control **T-99 compilado con este mismo producto**, sin el panel T-122 y sin Firebase, registra **cero errores JS y cero solicitudes externas a Firebase**, e importa el 977. Concuerda con O2 de la reaceptación anterior; no es evidencia de un fallo nuevo del producto. No aislé aquí la instrucción exacta del panel que lo dispara.

Evidencia: los campos `erroresJs` de `web/*-resultados.json` frente a [web-t99/resultado-977.json](C:/Proyectos/baystream-qa-r4/build/t123-aceptacion/web-t99/resultado-977.json). En el primer control, el filtro llamó «Firebase» a un archivo JavaScript **vendor servido por localhost**; la segunda comprobación distingue esos recursos locales de llamadas externas.

### Transparencia de los intentos propios

Los fallos de montaje de mis pruebas, los destinos de 40 pies incompatibles con contenedores de 20 y las celdas tapadas se conservan en los registros; los casos finales exigen hit test, levantamiento y destino válido. En Chrome, un intento de preparación envió rueda horizontal negativa en el extremo y navegó a **about:blank**: se verificó la URL y se retiró ese gesto del conductor. Los casos finales de H7 se hicieron en perfiles nuevos y terminaron con exit 0. El recorrido Web de carga anterior terminó con exit 1 en esa preparación, después de completar H3/H4/H5/H6 y salida.

En Android, el conductor necesitó continuar tras cerrar el teclado/modal y desplazar la Lista para ver la tarjeta; el resultado final conserva la celda del vacío. La preparación fija de 150 % apuntaba a una altura incorrecta: se completó sobre la fila visible y en sentido inverso. No se omite ese sentido del resultado.

Al retomar después del límite de sesión hice un **gesto adicional de solicitud en Windows** que no mostró levantamiento ni diálogo. Está conservado en `windows/solicitud-*` y `gesto-solicitud.json`, con UP garantizado. No lo cuento como aprobado ni le atribuyo una causa no aislada. La solicitud pendiente está comprobada en la regresión propia; la aceptación nativa de H7 se apoya en los gestos anteriores con levantamiento y confirmación documentados, no en este intento adicional.

El primer APK falló por el registrador generado de integration_test; el build posterior regeneró ese archivo y terminó correctamente. Se conservan ambos registros. Hay advertencias de herramientas de compilación; **analyze en cero no significa ausencia de advertencias del compilador**. No se repitieron suite ni análisis por estos preparativos.

## 6. Aislamiento, conservación y entrega

Los dos bancos de Windows usan **namespace `t123acc`**, con rutas explícitas dentro de TEMP: `...\t123-codex-b6a8d95\almacen` y `...\almacen-matriz`. Ambos se abrieron con Explorer; no usan `%LOCALAPPDATA%\BayStream` de la app instalada. Se preservó la primera compilación antes de crear la segunda; esta solo cambió el define del almacén. `windows-compilacion1.json` y `windows-compilacion2.json` anotan rutas y huellas. El rol, publicación y sesión son simulados **solo localmente**. No se envió nada a Firebase.

Los fixtures son únicamente T-122, T100 y T99_SINTETICO_977; su procedencia está en `fixtures-origen.json`. Las capturas muestran los bancos sintéticos, sin abrir «Nube y cuenta» ni exponer cuentas reales. No se tocaron Honor, apps instaladas, piloto, corpus real, las carpetas excluidas ni lo publicado. El APK aislado queda instalado y detenido en emulator-5554; fuente y densidad del emulador se conservaron. Chrome de prueba, el banco Windows y los dos servidores locales propios quedaron cerrados. TEMP y la evidencia se conservan para revisar.

El [cotejo-final.json](C:/Proyectos/baystream-qa-r4/build/t123-aceptacion/cotejo-final.json) exige que los **1885 archivos originales sigan intactos**. Fuera de build solo se agrega **`docs/t123/aceptacion-codex.md`**. Codex no modificó `pubspec.yaml` ni `pubspec.lock`; los cambios del banco están exclusivamente en la copia TEMP. No hay bloque de Git: Carlos pidió mover el informe personalmente y no añadirlo.

**Mensaje para Yov:** «T-123 PASA sobre b6a8d95: suite propia 1821/1821 una vez, sin omitidas, y análisis cero en copia cotejada. La 3.1.1 conserva H1/H3/H4 y sus correcciones/H5/H6/H7 en el rediseño; tres clientes y regresión sintética comprobados. H7 tiene un defecto demostrable del conductor, sin reproducir un fallo del producto en los gestos válidos; el aborto inicial no quedó aislado. Ficha 21/22: P2 de T-124. Informe y manifiesto listos, sin cambios del producto ni Git.»

ALTO: Carlos decide
