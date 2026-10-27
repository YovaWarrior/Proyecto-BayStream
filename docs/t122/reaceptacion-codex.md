# PASA · T-122 · Reaceptación de la 3.1.1 después de la corrección 2

**Capitán Codex · 26 de octubre de 2026.** HEAD separado `cf07a17`, comprobado con `git log --oneline -3`; base de la corrección `6086bb5`. Se leyeron 10.59 y 10.60 del `SPRINT-4.md` del rediseño, A1/O1/O2 del informe anterior y 8ter de Timonel. Se revisaron las nueve rutas del diff. No se corrigió el producto.

**Dictamen:** A1 queda cerrado en los casos solicitados, O1 está corregido y O2 queda atribuido al banco T122, sin reproducirse en el banco T99 del producto. No hay hallazgos nuevos que impidan aceptar esta corrección. H2 sigue diferido por decisión de Carlos.

Evidencia propia: [resumen](../../build/t122-reaceptacion/resumen.json) y [manifest SHA-256](../../build/t122-reaceptacion/manifest.json). Los nombres de evidencia siguientes se resuelven bajo `build/t122-reaceptacion/`.

## A1 · P2 · Cerrado: sin fila solo se cargan los llenos declarados en el plan

**Cómo reproducir:** importar `T100_CARGA.edi`, confirmar GTSTC y usar muelle local, sin listado. Buscar `811` en «OR / últimos dígitos» y tocar MNLU0000811 en `010-01-06`. Repetir con T122_CARGA: buscar `480` y tocar TSTU0210480, sin estado, en `021-04-84`.

**Resultado:** ni el vacío ni el sin estado se ofrecen. El toque avisa que esperan el listado y no abre «Confirmar carga». El número exacto MNLU0000811 que abrió A1 en la aceptación anterior está probado; no se sustituyó por un objeto unitario parecido.

La sonda ejecutada sobre esta versión da búsqueda 0 y rechazo del borrador para ambos contenedores. Las pruebas propias también pasan una fila armada que **dice lleno**, conservando el número del vacío o del sin estado: el borrador comprueba el estado del plan y la rechaza igualmente. Se conserva la bitácora vacía al tocar las celdas bloqueadas.

**El camino permitido sigue funcionando:** MNLU0000616 se carga sin fila y su movimiento carece de la clave `order`. Después de importar T100_LISTADO, MNLU0000811 se carga con **OR 28 y tara 3900 kg**, como antes. Para un contenedor numerado con fila se conserva el tipo de movimiento legado `load_full`; esto no reabre A1: ahora están presentes la fila, el OR y su tara exacta.

| Cliente | Evidencia y resultado nativo |
|---|---|
| Windows | Bajo `windows/`: `t100-vacio-busqueda-sin-listado.png`, `t100-vacio-celda-espera-listado.png`, `t122-sin-estado-busqueda.png`, `t122-sin-estado-celda-espera-listado.png`: bloqueados. `t100-lleno-sin-fila-*` y `t100-vacio-con-listado-*`: cargas confirmadas. Pendientes 30→29 al cargar el lleno; 29→28 al cargar el vacío con listado, vacíos 10→9. |
| Web | `web/t100-resultados.json` y `web/t122-resultados.json`; PNG/árboles con los mismos nombres de caso. Se verificó también el vacío TSTU0210284 de T122, excluido de búsqueda y bloqueado al tocarlo. El lleno TSTU0220071 se carga sin fila. |
| Android | `android/resultados.json` y PNG de A1: vacío T100 y sin estado bloqueados; lleno sin fila y vacío con listado cargados. Solo `emulator-5554`, paquete `gt.cmartinez.baystream.t122c2acc`, a 360 dp con fuente 1.0 conservada. |

**Evidencia independiente de dominio/widget:** [sonda A1](../../build/t122-reaceptacion/sonda-a1.json), su fuente `probe_a1.dart`, `propias/a1-resultados.json`, `codex_a1_test.dart` y `propias.jsonl`. Las tres pruebas widget propias comprueban las dos celdas sin listado y la confirmación del vacío con listado.

### El lleno sin fila conserva la salida de la corrección 1

Se repitió el oráculo anterior: cargar un lleno T100 en una celda real distinta de la prevista, sin listado, y generar/reinterpretar su BAPLIE. El grupo original del plan se conserva segmento por segmento, incluido un FTX sintético de control; solo cambia LOC+147. Se mantienen WT y ausencia de VGM inventado. Resultado: MNLU0000616 en `0020104`, `withoutRow` contiene ese número y la salida tiene 31 contenedores.

Evidencia: `propias/salida-sin-fila.edi`, `propias/pruebas-propias.json` y el caso H4 c1 en `propias.jsonl`. En la Web se comprobó además la página: `web/t122-c1-salida-con-plan.png` enumera TSTU0220071 como lleno que sale con datos del plan y permite guardar.

## O1 · P3 documental · Cerrado

**Cómo reproducir:** comparar 8.2 y 8.3 del informe de Timonel con `FirestoreOperationSync.join` y el escritor de salida. **Resultado:** 8.2 ahora distingue los trozos de tipos ausentes del manifiesto, que `join` ignora, de los trozos incoherentes de un tipo declarado, que rechaza. En 8.3 ya consta que desde c1 el lleno sin fila sale con el grupo del plan y que el vacío asignado sigue necesitando su fila. El diagnóstico central del manifiesto inmutable permanece correcto.

Evidencia: `diff/docs__T122-RESULTADOS.md.diff` y `revision-codigo.json`; prueba H4 c1. No se editaron el informe de Timonel, las reglas ni H2.

## O2 · P3 del banco · Cerrado para la aceptación del producto

**Cómo reproducir:** abrir cada compilación propia en Chrome visible y perfil temporal nuevo, escuchar `pageerror` y `console.error` durante la navegación y 8 segundos después de cargar, y observar otros 3 segundos tras activar semántica. No se importa ningún plano para esta sonda.

| Compilación propia, release | Resultado |
|---|---|
| Banco T122 actual, con su panel superpuesto | Se reproduce el error inicial de foco/RenderBox del banco. Los recorridos A1 funcionan después. Pila conservada en `web/t100-resultados.json` y `web/t122-resultados.json`. |
| Banco T99 actual (`tool/t99_main.dart`, sin panel T122) | 0 `pageerror`, 0 `console.error`, 0 avisos; portada y semántica verificadas. `o2/t99-head.json` y sus dos PNG. Versión de esta compilación: 3.1.1, build 5. |
| Banco T99 de `7488321` | Igualmente cero errores y avisos, con portada y semántica verificadas. `o2/t99-7488321.json` y sus dos PNG. Versión compilada: 3.1.0, build 4. |

Esto confirma que el error no aparece en el producto sin el panel, en ninguna de las dos versiones, y respalda el aislamiento de Timonel al panel del banco. La identificación con nombres legibles del InkWell de «Banco T122» procede de 8ter; mi comprobación independiente usa las compilaciones y sondas T99 descritas, en release. No se presenta la consola del banco T122 como limpia.

La copia histórica se reconstruyó solo en `C:\Users\Giova\AppData\Local\Temp\t122-c2-codex-cf07a17\t99-7488321`, leyendo blobs con `git show` y la lista con `git diff`. Se recompiló allí; no se abrió ni se alteró la 3.1.0 publicada. Método y 37 rutas de fuentes reconstruidas en `t99-base-historica.json`. Ninguno de los bancos inicia sesión ni usa servicios remotos de Firebase.

## Suite, análisis y regresión propia

Se cotejó una copia nueva de **749 archivos** antes de la primera corrida. Antes de `pub get`, cero faltantes/diferencias. Después, solo cambió `android/app/src/main/java/io/flutter/plugins/GeneratedPluginRegistrant.java`, generado por Flutter; identidad Android, fuentes, pruebas y pubspec seguían originales. Evidencia: `arbol-inicial.json`, `cotejo-antes-pub.json`, `cotejo-antes-suite.json`.

- **Suite del producto: una corrida, 1404/1404**, sin reintentos, fallidas ni omitidas. `suite.jsonl`, `suite-resumen.json`, salida 0.
- **Analyze de toda la copia limpia: cero incidencias**, salida 0, antes de instrumentar. `analyze.txt`.
- **Siete casos propios aprobados en su primera corrida**, sin omitidos: dos de dominio A1, tres widget A1, conservación de salida c1 y regresión T100. `propias-resumen.json`, `propias.jsonl`.
- Sonda A1 independiente ejecutada con Dart, salida 0 (`sonda-a1.*`). Compilaciones release Windows, Android, Web T122, Web T99 actual y Web T99 histórica: salida 0. Logs `build-*` y huellas en `binarios.json`.

**Regresión repetida de la aceptación anterior, sin nube:** importar llegada, plan y listado T100; guardar sus tres fuentes; descargar 30; cargar un lleno, deshacerlo y volver a cargarlo; asignar un vacío a una reserva; pedir un intercambio entre dos pendientes como muelle; generar e interpretar la salida. Se exige el conjunto exacto de números: **32 contenedores**, 0 descargas pendientes, 28 cargas pendientes, solicitud pendiente sin modificar todavía el plan y cero conflictos.

Se conserva la derivación declarada en la aceptación anterior: T100 trae vacíos numerados, por lo que para la rama de asignación se vacía **un solo EQD**, el de MNLU0000811, creando una reserva. El original no cambia. Las equivalencias de tipos del listado se normalizan a sus ISO. Se entregan `sinteticos/T100_CARGA-reserva-derivada.edi`, `propias/regresion-salida.edi` y `propias/pruebas-propias.json`. Esta regresión se ejecuta en dominio con bitácora en memoria; A1 se comprueba adicionalmente en los tres clientes nativos. No se afirma que la secuencia completa se haya repetido nativamente en cada sistema.

## Aislamiento, instrumentos y reglas

Los bancos se prepararon **después** de suite y analyze, solo en TEMP. Windows se abrió mediante `explorer.exe → abrir.cmd → exe del banco`, con almacén explícito `C:\Users\Giova\AppData\Local\Temp\t122-c2-codex-cf07a17\almacen` y namespace `t122c2acc`. Vista lógica 700×800 dentro del cliente nativo. La entrada sintética es la misma del banco anterior, ampliada a T100; el `tool/t122_main.dart` original no cambió entre entregas. Se guardan la entrada instrumentada y sus huellas. Android tiene paquete/almacén propios. Chrome usa perfiles temporales y servidores 127.0.0.1:59125–59127. No hubo nube ni publicación.

Se conservaron los fallos de los controladores: en Chrome, el primer intento no enfocó el campo; el segundo buscó su rótulo en el tipo de nodo equivocado. El recorrido T100 válido completó sus cuatro casos y luego su helper de cierre no llegó a la portada; T122 se verificó en otro perfil limpio. En Android se amplió la espera inicial y se recuperó la prueba desde la pantalla observada; el EditText vacío no tenía texto/content-desc y se enfocó por su clase/bounds. También se corrigieron el inicio del gesto horizontal de la silueta para que cayera dentro de su viewport y la comparación de mayúsculas del aviso compacto. Los logs y capturas de inspección permanecen; son ajustes del banco, sin cambios ni reintentos de la suite del producto. Los intentos incompletos no se cuentan como casos aprobados.

El T100_LISTADO original produce el aviso de una fila de pie «TOTAL 30 CONTENEDORES» sin entender. Se conservó el fixture: se importan sus 30 filas en dos agencias y la propia interfaz propone las equivalencias de tipos con el plan. Ese aviso no se presenta como introducido por c2 ni como ausencia de filas de carga. La carga del vacío con su fila fue confirmada.

**Reglas cotejadas contra `6086bb5`:** sin cambios en `lib/main.dart`, opciones Firebase, reglas, congelados, lista del piloto, `pubspec.yaml` ni `pubspec.lock`; cero directivas Dart `// ignore:` agregadas. Solo nueve rutas de producto/documentación en el diff. `loading_controls.dart` cambia **5 líneas añadidas y 4 retiradas**: base y HEAD tienen solo LF. El archivo de trabajo está en CRLF desde el inventario inicial; se deja idéntico, sin normalizarlo. Conteos de bytes en `fin-de-linea.json`.

Se usaron solo T122/T100 sintéticos y la derivación declarada. No se tocaron Honor, apps instaladas de BayStream, PRUEBA T-105, demo17, proyecto-baystream, Firebase ni la publicación existente. Los PNG muestran el banco y datos sintéticos, sin pantallas de cuenta.

**Entrega:** fuera de `build/t122-reaceptacion/`, el único archivo nuevo es `docs/t122/reaceptacion-codex.md`; ningún archivo preexistente cambia. `integridad-final.json` coteja el árbol y el historial. Informe sin añadir a Git. Bancos Windows y Android cerrados, Chrome cerrado y servidores locales detenidos; copias y almacenes temporales se conservan para revisión.

**Para Yov:** T-122 c2 PASA: A1 cerrado con MNLU0000811 y el sin estado en los tres clientes; lleno sin fila y su salida c1 conservados, vacío con listado a tara 3900 kg. Suite única 1404/1404, analyze cero y siete pruebas propias aprobadas. O1 corregido; T99 actual y 3.1.0 recompilados dan cero errores de arranque, aislando O2 al banco T122. Producto intacto; informe y evidencia listos para Carlos.

ALTO: Carlos decide
