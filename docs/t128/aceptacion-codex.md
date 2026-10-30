# Aceptación de la candidata 0.4.1 · Capitán Codex

**Dictamen: aceptación con reservas; no certifico una aceptación limpia de toda la 0.4.1.** La candidata supera la suite, las baterías de reglas, las compilaciones y las regresiones descritas. La prueba real descubre un cierre remoto correcto que deja el estado local abierto hasta repetirlo (**O-128-2, P2**). Además, la interrupción física de un pellizco sin recibir su evento final queda **no concluyente** (**O-128-4, P2, límite de validación**). Carlos decide si acepta esas reservas para publicar.

Trabajo del 29-oct-2026, hora de Guatemala; parte de los registros lleva fecha UTC del 30-oct. Carpeta fija `C:\Proyectos\baystream-qa-r4`, HEAD separado `c89368786b31e2f38475ea3bdfb42fc3e8b4ed48`, base `v0.4.0` / `be532ab`. El paso 0 cumple: `c893687`, `472064e`, `af87dd6`, `c628068`, `cce3c4c`, `65db312`, en ese orden. No se cambió de commit.

Se leyeron AGENTS.md y las fuentes pedidas en el orden solicitado. Carlos autorizó la ejecución con «listo luz verde para todo», la copia sintética derivada y el navegador integrado como alternativa. Se anunciaron las ventanas con SEMÁFORO. No hubo Git de escritura, despliegues ni Firebase real. Los artefactos de producción se compilaron y **no se abrieron**.

## Dictamen por bloque

| Bloque | Resultado y números |
|---|---|
| P1 · T-119 | **Parcial, con reserva física.** Seis archivos existentes y dos nuevos cotejados; 11/11 pruebas verdes y 11/11 rojas de comportamiento contra `83d7b85`. Chrome/Edge: 1, 2, 5 y 6 cumplen; 4 reproduce O-119-1; 3, 7 y 9 no concluyentes por calibración; 8 informativo. Arrastre físico al 200 % cumple. Pellizco real y desplazamiento posterior observados, pero no se acreditó la pérdida de foco antes de `PanZoomEnd`. |
| P2 · T-127 | **Con reserva de cierre.** 19/19 pruebas. Reglas nuevas: 69/69, 25/25 y 31/31; reglas T-80: 69/69, 25/25 y 27/31, exactamente los cuatro rojos previstos. Recorridos de los 14 pasos con app real; incidencia en el paso 13. Cinco comprobaciones de compatibilidad cubiertas, con el alcance de vuelta local explicado abajo. |
| P3 · T-128 | **Conforme en compilación y metadatos.** Dos líneas del pubspec, lock sin cambio; T-93 5/5. Windows, Web y AAB compilados: 0.4.1, compilación 7. T-92 verifica 57 archivos Web. O-128-1 confirmada sin modificar el script. |
| P4 · Piloto | **Conforme en revisión estática.** Rótulos de las seis ubicaciones cotejados, incluidos 29 fragmentos y textos compuestos. Ocho bloques PowerShell: cero errores de análisis; ninguno ejecutado. Scripts, parámetros, rutas, mezcla, huellas y formato `.sha256` coherentes. |
| Regresiones y suite | **Conformes en el alcance ejecutado.** Suite completa válida, en una sola corrida: 1871/1871, cero fallos y cero omitidas. Analyze de `lib`, `test` e `integration_test`: cero incidencias. Pasada local sin Firebase en Windows, Android y Web por plano, toque, zoom, arrastre, Lista, listado previo a publicar, Estadísticas y salida BAPLIE; se conserva un error de arranque del banco Web integrado como O-128-3. |

## P1 · Código, navegadores y gestos físicos

`revision-codigo.md` y `t119.diff` conservan el cotejo con T-119 §3 y DESIGN §16. Se revisaron `bs_movimiento.dart`, `bs_silueta_buque.dart`, `design.dart`, `plano_providers.dart`, `bay_plan_view.dart` y `plan_drag_confirmation.dart`, y los nuevos `bs_rueda_horizontal.dart` y `barra_de_la_rejilla.dart`. Se contrastaron acumulación y animación de rueda, cesión en extremos, exclusiones de modificadores, pestillo de 300 ms, umbral del pellizco, límites del zoom, foco y centrado, horizontal exterior al zoom, barra Material y resolución del destino del arrastre. El código de la copia de pruebas procede de la punta; los rojos anteriores fallan por aserciones de conducta, sin error de compilación.

El conductor de `build/t119-navegadores/` se copió sin cambios y se repitió contra la Web del banco T-100 compilada desde HEAD, sin Firebase. Chrome 156.0.8078.79 y Edge 156.0.4314.50, visibles y con perfiles temporales. Pasadas válidas: `t119-chrome/` y `t119-edge-validado/`; cero errores JS y cero peticiones externas en esas pasadas.

El paso 2 inicial de Chrome separó los eventos 304,8 ms: quedó fuera de los 300 ms y su aserción roja no acredita un defecto del pestillo. La repetición enfocada `t119-chrome-pestillo/` midió 89,1 ms dentro y 515,5 ms después, con todas sus comprobaciones ciertas, también al cruzar la silueta bajo un puntero quieto. Edge cumple el paso 2 directamente.

O-119-1 persiste: al pasar de bahía centrada a desbordada, deriva máxima de 1,901775 dp en Chrome y 1,632119 dp en Edge; con la rejilla ya desbordada, alrededor de 0,059 dp. No aparece un cambio sustancial respecto del informe anterior. Ctrl + rueda y Ctrl + Equal no ampliaron la página de control; el pellizco sí. Por ello 3, 7 y 9 siguen no concluyentes para zoom de página, y 8 sigue informativo. O-119-2 y O-119-3 conservan su alcance; la prueba manual de Carlos de 10.80 es evidencia independiente.

En Windows se usó el banco nativo de la punta, abierto con `explorer.exe`, almacén `C:\Users\Giova\AppData\Local\Temp\t128acc-store`, namespace `t128acc`. El registro posterior del proceso conserva PID y ruta; su proceso padre ya no pudo resolverse y no se presenta como una verificación independiente del padre Explorer.

**Arrastre al 200 %: conforme.** Carlos mantuvo OR 7 / MNLU0000703 en el borde derecho y lo soltó. La traza registra horizontal de 0 a 266,651968 dp; el diálogo propone `002-02-82 → 002-05-82`, celda bajo el puntero en la captura. Carlos confirmó «Listo: se desplazó». Se canceló el diálogo para no anexar un movimiento. Evidencia: `windows/carlos-arrastre-traza.json`, `carlos-arrastre-despues.png` y `resumen-validado.json`.

**Pellizco interrumpido: no concluyente.** La primera pasada solo produjo escalas 1. La repetición sí produjo pellizco real, escalas entre 0,494251 y 1,227388, cambios de zoom y desplazamiento posterior. Carlos confirmó que cambió el zoom, que la columna se mueve al volver y que el primer desplazamiento la mueve. Sin embargo, los `PanZoomEnd` registrados preceden a la pérdida de foco: el último fue a las 05:20:34,430 UTC y `inactive` a las 05:20:35,608. La espera asistida posterior no detectó un pellizco activo dentro de su ventana y no cambió el foco. Ese testimonio no demuestra el caso exigido de perder el foco **sin** evento final. La lectura del código tampoco lo sustituye. Evidencia: `windows/carlos-pellizco*-traza.json` y sus marcadores de inicio.

## P2 · Reglas y aplicación real contra el emulador

Se cotejaron dominio, datos, presentación y reglas con T-122 §8.3 y T-127 §3. Se verificaron revisión opcional en `OperationSource`, reemplazo exclusivo del listado en operación publicada abierta, cruce de movimientos, trozos rN, huella del texto, lote de trozos y manifiesto, guardado local tras éxito, rechazo de unión incompleta y recepción automática sin alterar movimientos. Las reglas restringen oficina autorizada, revisión creciente y trozos ligados al manifiesto; no validan por sí solas toda la semántica del Excel o BAPLIE. Detalle en `revision-codigo.md` y `t127.diff`.

Las seis baterías se ejecutaron completas; los cuatro rojos contra T-80 son el control negativo esperado de T-127. No hubo errores por límite de 1000 expresiones en esos registros. Hub propio fijo **4498**, Firestore **8383**, Auth **9399**, logging **4598** y websocket **9150**. Se evitó 8181, 4000, 4400 y 5919. O-127-2 queda mitigada mediante esos puertos, sin modificar el emulador de la Expo.

Proyecto `demo-t128-acc`. Cuentas sintéticas de oficina y muelle creadas y autorizadas como en T-79; claves y tokens solo en memoria. La app real hizo las escrituras de negocio. Las lecturas administrativas finales comprobaron los documentos. El muelle usó proxies 8384/9398 que cortan conexiones y reconexiones exclusivamente a los emuladores. El conductor abortó las sondas externas del SDK a `www.google.com/images/cleardot.gif`; no se dejó salir ninguna a Firebase real.

### Datos y plataformas

T-100 original tiene 60 contenedores numerados y cero reservas: no permite el paso 6 tal cual. Ante la contradicción se detuvo ese caso y Carlos autorizó la copia derivada. `T100_CARGA_RESERVA_T128.edi` quita exclusivamente MNLU0000827 del EQD de OR 16: parser real con 59 numerados y una reserva en `0100104`, tipo 45R1, destino USMSY y agencia MNA. Los originales y el generador permanecen intactos. `reserva-autorizada-manifiesto.json` conserva sus huellas; original `4ACF7539A1F26F25A73D56F368C979B2DA29DC9A435EF5414C93DACA2AB99E68`, derivado `95D925927D4344E97D00897C01278E6EDC3DBD32A88661C199C782DFBB3097FE`. Excel inicial de 30 filas; v2 elimina solo OR 1 y tiene 29.

Oficina: Chrome sobre Windows, 1200 × 700. Muelle: otro contexto de Chrome sobre Windows, 360 × 800. Es una simulación de tamaño móvil; **no cubre Android ni Honor en esta prueba de sincronización**. Laptop y Honor en la nube siguen correspondiendo a 0.7 del piloto.

### Los 14 pasos

Operación final `6d79750f-f698-48ba-acb3-a328b1ec1bd3`. Registro en `web-comandos-e2e-final.json`, capturas y estados en `e2e/oficina-f/` y `e2e/muelle-f/`; aserciones resumidas en `e2e/resumen-validado.json`.

| Paso | Resultado observado |
|---|---|
| 1 | Oficina publica sin listado desde la interfaz real. |
| 2 | Muelle se une sin archivos locales; todavía no hay OR del listado. |
| 3 | Carga por dígitos 621 de MNLU0000621 en `0020104`, confirmada. |
| 4 | Oficina importa 30 filas: cruce 0 cargados ausentes / 0 vacíos reagrupados; revisión 1 aceptada. |
| 5 | Muelle recibe aviso automático de 30 filas, aparecen los OR y se conserva el primer lleno. |
| 6 | OR 16 / MNLU0000827 ocupa la reserva `0100104`, tara del listado 4530 kg; confirmado. |
| 7 | Corte solo de puertos del emulador: canales cerrados y estado Sin conexión. |
| 8 | Oficina importa v2: 1 cargado ausente, 0 vacíos que cambian grupo; revisión 2, 29 filas. |
| 9 | Muelle sin red conserva r1 / 30 filas; carga OR 2 / MNLU0000637 en `0020206`, un pendiente. Remoto conserva dos movimientos. |
| 10 | Reconexión automática: aviso de 29 filas y Al día, tres movimientos confirmados, sin pulsar Reintentar; posiciones conservadas y 621 sin OR. |
| 11 | Oficina muestra Plano / En vivo / Avance con dos llenos y un vacío, posiciones y cuentas correctas. |
| 12 | BAPLIE real descargado, 33 EQD. 621 usa WT 14500 del plano; 637 usa VGM 15000 del listado; 827 usa tara 4530. Aviso de un lleno sin fila. |
| 13 | Primer cierre deja cerrado Firestore, devuelve `not_found` y conserva abierto el estado local. Revisión posterior rechazada. Reabrir Nube y cuenta y repetir cierre recupera el estado local. **O-128-2.** |
| 14 | Manifiesto en revisión 2; `loading_baplie-0`, `export_list-r1-0` y `export_list-r2-0` conservados, con sus huellas verificadas. |

### Compatibilidad con 0.4.0

Se compiló `be532ab` en otra copia obtenida con lecturas de Git, contra los mismos emuladores y reglas nuevas:

1. Una unión nueva después de r2 falla con «La fuente «listado de la agencia» llegó incompleta o distinta de la publicada. No se guardó nada: vuelve a intentarlo.» La sonda local devuelve `operations=[]`.
2. Un muelle unido antes de r2 conserva las 30 filas y registra OR 3 / dígitos 642, aceptado por el servidor. Es un cuarto movimiento añadido después de comprobar los tres del recorrido.
3. La oficina antigua rechaza revisar las fuentes de una operación publicada; sí cierra local y remotamente la operación auxiliar.
4. La operación auxiliar `4126b4b8-6ba7-4b41-b274-3cf91493ad98`, publicada por 0.4.1 con listado inicial sin revisión, se une desde 0.4.0 y muestra sus 30 filas.
5. Vuelta local Windows: 0.4.1 escribe la operación revisada mediante Hive real en el almacén TEMP, namespace `t128rollback`; se cierra y 0.4.0 abre el mismo almacén sin error, conserva el JSON de las 29 filas y abre el plano con 29 OR. Se transfirió la operación y sus fuentes al banco local, **no** toda la bitácora de movimientos de la sesión Web. Evidencia en `rollback/resultado.json` y `windows/rollback-*.png`.

Estos resultados confirman el límite de O-127-1, no una compatibilidad total de unión vieja después de revisar.

## P3 · La candidata compilada

T-128 cambia exactamente `version: 0.4.1+7` y `msix_version: 0.4.1.0`. El lock conserva el contenido anterior; las diferencias físicas LF/CRLF de las copias no son cambios de dependencias. **No se modificaron `pubspec.yaml` ni `pubspec.lock` del árbol original.**

`candidata/` conserva las tres salidas del main original. Windows: FileVersion y ProductVersion `0.4.1+7`. Web: `version.json` con versión `0.4.1` y build `7`; T-92 aprobado, 57 archivos. AAB: `versionName=0.4.1` y `versionCode=7` extraídos del manifiesto protobuf dentro del propio AAB. Detalles y huellas en `candidata-metadatos.json`.

Ninguna candidata se abrió. No se generó MSIX, no se usó el certificado de Carlos y no se subió nada. El AAB usa la firma de depuración prevista por Gradle cuando no hay `key.properties` en la copia: acredita compilación y metadatos, **no es el AAB firmado de publicación de Carlos**. Los bancos ejecutados son otras salidas, con aislamiento local o emulador.

O-128-1 confirmada por lectura: `tool/t93_msix.ps1` toma `Version=1.0.0.0` por omisión y la pasa a `--version`, pudiendo prevalecer sobre pubspec. La lista 4.2 pasa expresamente `-Version 0.4.1.0`. Script intacto y sin ejecutar.

## P4 · Lista del piloto

Rótulos de 0.7, 1.5, 1.17, 2.6, 2.15 y sección 5 cotejados con `lib/`, también singular/plural y textos parametrizados o compuestos. El índice de 29 fragmentos no se toma por sí solo como prueba de interacción; la composición se revisó aparte. Por ejemplo, «Sin listado de agencia: los llenos se cargan por su número; los vacíos esperan el listado» se forma con título y valor en la ficha. Detalle en `piloto-revision.md` y `rotulos-fragmentos.json`.

Los ocho bloques PowerShell pasan el analizador de PowerShell 5.1 con cero errores; no se ejecutó su contenido. La excepción de política usada para cargar el analizador fue limitada a ese proceso, sin cambiar la política persistente. Se cotejaron scripts, parámetros, rutas y destinos de salida.

`master`, `origin/master` y `v0.4.0` apuntan a `be532ab`; su árbol coincide con `7647741`, ancestro de HEAD. En las referencias inspeccionadas no hay contenido divergente que produzca conflictos de mezcla. No se ejecutó ninguna mezcla. Las huellas normalizadas con `tool/t113_reglas.mjs` son:

- T-80: `7E57F227BADC118F823265B0CFE9FF0E9A067F39F5AD387C932AD901F894F125`.
- T-127: `FC17842C227120C8F5AF6AAF732E306290A4071B0383E2BA14455E2F13E566DB`.

T-93 escribe `.sha256` ASCII con huella, dos espacios y nombre del MSIX. El lector de 4.5 toma el primer token: formatos compatibles. Las instrucciones de publicar reglas antes de clientes, mezclar, firmar, instalar y volver atrás son para Carlos; esta revisión no las ejecuta ni acredita el estado actual de la nube.

## Regresiones locales y suite

Suite válida sobre copia limpia: **1871 aprobadas**, cero fallos, cero omitidas, una sola corrida en `suite-valida.log`. Analyze de `lib`, `test` e `integration_test`: **cero incidencias**. Pruebas focalizadas: T-119 11/11, T-127 19/19 y T-93 5/5. Se conservan los resultados completos y un resumen compacto.

Los tres bancos sin Firebase importan T-100 original: plano de 60 contenedores, perfil GTSTC, listado de 30 filas antes de publicar, Lista y Estadísticas con 3 bahías / 60 contenedores / 866,7 t. Se verificaron detalle al tocar, chip de zoom al 200 % y diálogo de arrastre; los arrastres de regresión se cancelaron.

| Cliente | Aislamiento y evidencia |
|---|---|
| Windows | Banco v2 en TEMP / `t128acc`, abierto con Explorer. Toque y Estadísticas capturados; salida real guardada con diálogo nativo, `windows/salida-local.edi`, 30 EQD. Arrastre físico de borde descrito en P1. |
| Android | Solo `emulator-5554`, AVD `t99_api26`, paquete `gt.cmartinez.baystream.t128acc`, versión 0.4.1/7; vista 360 × 640 dp. Toque, zoom, Lista, importación previa y Estadísticas comprobados. Arrastre OR 7 `002-02-82 → 002-04-82`, diálogo correcto. Salida de 30 contenedores generada y previsualizada; no se acredita guardado externo Android. `android/resumen-validado.json`. |
| Web | Banco v3 en navegador integrado autorizado, origen fresco 5937, 1280 × 720. Toque, zoom 200 %, arrastre OR 7 `002-02-82 → 002-04-82`, Lista, listado previo y Estadísticas; BAPLIE real descargado y copiado a `iab/salida-local.edi`, 30 EQD. Capturas y `iab/resumen-validado.json`. Un error de consola al arranque: O-128-3. |

El Honor, las apps del piloto y el corpus no se tocaron. Los bancos, navegadores y emuladores propios se cerraron. La aplicación Android aislada queda instalada en el AVD, sin alterar el paquete de Carlos.

## Observaciones y límites

| ID | Prioridad | Reproducción, efecto y alcance |
|---|---|---|
| O-128-1 | P3 | Omitir `-Version` al usar `t93_msix.ps1` deja 1.0.0.0 como argumento del empaquetador. La lista lo evita con 0.4.1.0 explícito. Observación de Timonel confirmada, script intacto. |
| O-128-2 | P2 | Oficina 0.4.1, operación r2 con movimientos, Cerrar operación y confirmar: remoto cerrado, mensaje «No se encontró la operación para cerrarla en este dispositivo o en la nube…», local `closed=false`. Reabrir Nube y cuenta y repetir: «Operación cerrada.», local `closed=true`. No hubo pérdida de movimientos ni revisión aceptada tras cierre. El método `close` ya existía antes de T-127; causalidad no aislada. |
| O-128-3 | P3 | Primer arranque del banco Web v3 en el navegador integrado, origen 5937: error JS minificado conservado en `iab/errores-final.json`, con primer dibujo incompleto. La sesión luego permite completar las regresiones. Atribución al producto, al banco o al navegador sin aislar; no se afirma que falle la candidata de producción ni que esta sesión tenga cero errores. |
| O-128-4 | P2 | Falta de evidencia del caso físico de foco perdido sin `PanZoomEnd`. Las pasadas registradas terminan el pellizco antes de `inactive`; la asistencia posterior no llegó a interrumpir un pellizco activo. Carlos confirma desplazamiento posterior, pero no acredita la condición de interrupción. **Es una reserva de validación, no un defecto reproducido del producto.** |

Se mantienen O-119-1 (P3, deriva), O-119-2 (P3, calibración) y O-119-3 (P3, instrumento); no se renumeran. O-127-1 queda comprobada con clientes antiguos y O-127-2 se evita usando hub propio. No se eleva una limitación del instrumento a defecto del producto.

## Preparación descartada y trazabilidad

Se preservan los intentos inválidos para que no se confundan con pruebas aprobadas:

- La primera copia de suite omitió `design/`: 1862 éxitos y tres errores por archivos ausentes. Se agregaron 98 blobs originales y se ejecutó la suite completa válida una sola vez. `suite-unica.log` y `suite-intento-incompleto.json` son preparación fallida, no defectos del producto.
- El helper HTTP inicial dejó hijos propios y produjo intentos Edge blancos / `ERR_EMPTY_RESPONSE`. Se cerraron esos procesos y se repitió con servidor registrado y cierre explícito.
- El primer recorrido con reserva se cortó porque el guardia de red abortaba una sonda externa y además lanzaba una excepción. Se corrigió solo el conductor, se reinició limpio el emulador y se repitieron los 14 pasos.
- El banco local inicial sustituía el selector sin delegar `saveFile`. Se corrigió solo ese adaptador y se recompilaron Windows, Web y APK v2; el producto permaneció intacto. Web v3 añade `container:true` al control semántico privado del banco.
- Los intentos Web con origen anterior conservaban un service worker viejo y un viewport escalado; no se usan para declarar fallos de toque o arrastre. La pasada válida usa origen fresco y tamaño normal. Los primeros arrastres Android usaron modo o coordenadas anteriores al cambio de vista; la evidencia válida es el diálogo posterior estable.

Todo queda en `build/t128-aceptacion/`: copias, fuentes instrumentadas, conductores, binarios, registros, capturas y resúmenes. `manifest.json` inventaría SHA-256 de la evidencia y de **este informe**; excluye copias de trabajo, cachés y perfiles según su lista explícita. Las referencias y listas de blobs permiten reconstruir las copias con lecturas de Git. El manifiesto no se incluye a sí mismo.

El cotejo final conserva los 682 archivos originales inventariados sin cambios; `lib` de las copias se coteja con HEAD o `be532ab`, normalizando solo finales de línea. Las tres advertencias de archivos generados de `windows/flutter/` no son cambios de producto y no se incluyen en la entrega. Único archivo para Git: **`docs/t128/aceptacion-codex.md`**. `pubspec.yaml` y `pubspec.lock` permanecen intactos. No se corrigió producto alguno.

La publicación y la aceptación de las reservas corresponden a Carlos. **ALTO: Carlos decide.**
