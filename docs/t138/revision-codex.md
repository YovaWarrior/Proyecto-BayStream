# Revisión corta de T-138 · «Volver al inicio» · Capitán Codex

**Dictamen: NO PASA.** La navegación, las seis pruebas, la suite y el análisis
pasan. Falla el criterio 5: el movimiento registrado sin red llegó al emulador
con el muelle todavía en Inicio, antes de reabrir el plano. El subtítulo
**«Lo pendiente sube al reabrirlo»** promete una pausa que no se cumplió.
Esta revisión no cambia la aceptación de T-136 ni acredita una publicación.

3-nov-2026, Guatemala. Carpeta: `C:\Proyectos\baystream-qa-r4`.
HEAD separado: **`46580f46251d914629071107f44b606905c0e298`**,
«Sprint 4: T-138, volver al inicio». Se leyeron 10.101, 10.102,
las restricciones vigentes y `docs/T138-RESULTADOS.md`.

## Paso 0 y alcance

El diff contra **`5ab830b`** contiene exactamente estas cinco rutas de código
y pruebas:

- `lib/features/vessel/presentation/widgets/navegacion_del_viaje.dart`
- `lib/features/vessel/presentation/pages/vessel_overview_page.dart`
- `lib/features/vessel/presentation/providers/loading_operation_provider.dart`: solo un comentario.
- `test/t114_fase3_inicio_test.dart`: solo un comentario.
- `test/t138_volver_al_inicio_test.dart`: nuevo.

Las otras tres rutas son `SPRINT-4.md`, `docs/T138-RESULTADOS.md` y la aceptación
de T-136. Al iniciar y al terminar no hay diferencias de contenido rastreado
respecto de HEAD; solo los avisos LF/CRLF conocidos de tres generados de Windows.
Evidencia: `build/t138rev/head.txt`, `paso0-diff.txt` y `git-final.txt`.

No se modificó código del árbol de trabajo. Las copias independientes se
materializaron mediante `git show`. La verde contiene **812 archivos de HEAD**,
con las 812 huellas idénticas después de pruebas, analyze y compilación.
El prerrequisito generado de T-124 se tomó de la copia anterior conservada
en esta misma carpeta, SHA-256
`d4384834fb9fc9cb18632b87180a7998cc3f91109edcbd33dbbf9787542d1162`.

## Cambio y pruebas

| Criterio revisado | Resultado |
|---|---|
| Marca como botón fuera de Android nativo | Pasa: `onVolverAlInicio` es null en Android nativo, también con el riel ancho |
| Misma acción que «Más» | Pasa: ambos invocan `_clear(context, preview: preview)` |
| Previo | Pasa: conserva la pregunta existente y «Seguir mirando» no descarta |
| Colores nuevos | Pasa: `colorScheme.primary` para foco y `colorScheme.outline` para hover |
| Ancho y destinos | Pasa: cálculo sin cambios; marca de 44 × 44; comparación con marca sola en la prueba |
| Título y subtítulo de previo en «Más» | Pasan |
| Última frase del subtítulo confirmado | **No pasa** la prueba contra el emulador |

En Chrome a 1280 el riel midió **98,25 px**, con Plano, Lista, Avance,
Estadísticas, Más y Alertas; el botón de la marca, **44 × 44 px**.

Un comando de Flutter a la vez, con SEMÁFORO y T-137 en pausa para Flutter.

| Corrida ejecutada | Resultado |
|---|---|
| Seis casos actuales de `t138_volver_al_inicio_test.dart`, copia limpia | **6/6 verdes**, sin omitidas; salida 0 |
| Misma prueba actual con las tres piezas de `lib/` de `5ab830b`, copia separada | **6/6 rojas esperadas**; salida 1 |
| Suite completa, `flutter test --reporter json`, una sola corrida | **2107/2107**, cero fallos, cero omitidas; salida 0 |
| `flutter analyze lib test` | **Cero incidencias**; salida 0 |
| Banco Web release desde la copia limpia | Compila; salida 0 |
| Integridad verde final | **812/812** idénticas a HEAD |
| Integridad roja final | Solo las **3 sustituciones** previstas; prueba actual intacta; cero diferencias adicionales |

Los seis casos cubren: volver y conservar Recientes; pregunta del previo;
descripción/semántica/Tab/Enter; ancho y destinos; texto confirmado a 360;
y texto/pregunta de previo en «Más». Las rojas fallan por ausencia de la marca
o del texto nuevo, con las pruebas compiladas y ejecutadas. El caso del ancho
falla al buscar primero la marca; ese rojo no mide el ancho antiguo.

La suite registró **150369 ms**; el comando duró **153,351 s**. Analyze informó
38,6 s. Son tiempos informativos, no mediciones RNF. Se aplicaron los flujos
de `dart-run-static-analysis` y `webapp-testing`, sin correcciones de producto.

Registros bajo `build/t138rev/`: `t138-verde-resumen.json`,
`t138-rojo-resumen.json`, `rojo-mensajes.json`, `rojo-sustituciones.json`,
`rojo-integridad-final.json`, `suite-resumen.json`, `analyze.log`, sus registros
de ejecución, `copia-manifiesto.json` e `integridad-copia.json`.

## Recorrido en pantalla

Chrome **156.0.8078.80**, visible, contextos nuevos y sintéticos T-100.
El banco deriva de `HEAD:tool/t130_emu_main.dart`: su única adaptación es el
namespace **`t138rev`**, en una entrada privada bajo `build/` de la copia.
Proyecto **`demo-t138-rev`**, Auth **9399**, Firestore **8383**, todos en
**127.0.0.1**. Servidor Web **5942**. Se reutilizaron la configuración local
y las reglas propuestas de T-130 de la aceptación anterior.
Credenciales sintéticas solo en memoria. Sin opciones privadas, Firebase real,
apps instaladas o almacenes reales. No se abrió Windows ni Android.

| Recorrido observado | Resultado y captura |
|---|---|
| Marca a 1280, hover | Nombre accesible de botón, descripción «Volver al inicio» y contorno visibles: `e2e/oficina/02-marca-hover-descripcion.png` |
| Tab y Enter | Un Tab enfocó la marca, con contorno; Enter volvió al inicio: `03-marca-tab.png` y `04-inicio-por-enter-recientes.png` |
| Recientes y reapertura | El mismo BUQUE MANUAL/M100 seguía en Recientes y se reabrió; también volvió al inicio con clic: `05-reabierto-desde-recientes.png` y registro de comandos |
| Previo a 1280 | Pregunta «¿Descartar el plano sin confirmar?»; «Seguir mirando» conservó el previo y Confirmar: `e2e/previo/07-pregunta-previo-1280.png` y `08-seguir-mirando-conserva-previo.png` |
| «Más», confirmado, 360 × 800 | Título y subtítulo completos, sin cortes: `e2e/visual360-confirmado/01-subtitulo-completo-sin-aviso-sdk.png` |
| «Más», previo, 360 × 800 | «Descarta el previo sin guardar nada» completo: `e2e/visual360-previo/01-subtitulo-completo-sin-aviso-sdk.png` |

**Interferencia del banco:** Auth Emulator añade un párrafo HTML fijo de
40 px que tapa el pie a 360. Para comprobar visualmente los dos subtítulos
se ocultó exclusivamente `.firebase-emulator-warning` con un estilo temporal
del navegador. Es externo a Flutter; hay capturas con y sin él. Texto y
rectángulo del botón Flutter son idénticos antes y después: confirmado
**360 × 72**, previo **360 × 57**. No se ocultó ningún elemento ni desbordamiento
del producto ni se editó el build o código. Evidencia: `visual-360-resumen.json`.

Los contornos se inspeccionaron en las capturas originales y se compararon
sus píxeles con el reposo (`marca-contorno-pixeles.json`), sin editar imágenes.
La compilación conserva el aviso preexistente de fuente Cupertino.

## P2 · El movimiento sube antes de reabrir

**Texto nuevo afectado:**
`lib/features/vessel/presentation/pages/vessel_overview_page.dart:613–614`.

La oficina publicó M100/GTSTC. El muelle inició sesión, se unió y abrió
Descarga. Solo el muelle pasó por los proxies **8384→8383** y **9398→9399**.
El corte cerró los dos sockets activos de Firestore y bloqueó nuevas
solicitudes de ese cliente a ambos servicios; la oficina quedó conectada.
El muelle indicó **«Sin conexión»**.

Se registró una descarga en **002-02-82**: **29 por bajar, 1 bajado** y
**1 por enviar**; el emulador seguía con cero movimientos. Se volvió al
inicio mediante «Más»: Seleccionar archivo y Recientes visibles, sin plano
abierto, y todavía cero movimientos remotos. Después se restituyó la red,
sin pulsar Recientes ni reabrir.

| Momento, Guatemala (3-nov) | Evidencia |
|---|---|
| Antes del corte, tras registrar sin red y tras volver al inicio sin red | **0 movimientos** en las tres lecturas independientes |
| 18:43:26.622, primera lectura tras restituir red, con el muelle en Inicio | **0** |
| 18:43:56.612, última lectura de la espera inicial de 30 s | **0**; las 31 muestras fueron cero |
| **18:43:56.949**, `createTime` del documento en el servidor | **El movimiento llegó antes de reabrir** |
| 18:44:37.830, comprobación por el proxy restablecido | HTTP **200**, **1 movimiento**; muelle todavía en Inicio |
| Antes de reabrir | Capturas del muelle en Inicio y de la oficina que ya recibió la descarga; 46 muestras adicionales mantuvieron **1** |
| Tras reabrir | **1 documento, el mismo Id**, en las 13 muestras siguientes; `updateTime` pasó a **18:45:47.186** |

La espera inicial de 30 s por sí sola habría ocultado el fallo. La lectura
posterior y el `createTime` del emulador lo confirman. No se pulsó Reintentar.
Al reabrir se conservó la descarga y el estado pasó a **Al día**. Se observó
un movimiento lógico; el cambio de `updateTime` es compatible con un reenvío
idempotente y no acredita una sola escritura física.

**Explicación apoyada en código:** `clearVoyage` suelta el plano en memoria;
`syncStatusProvider` deja de seguir la operación y `SyncEngine.stop()` cancela
reloj y suscripciones. Pero `_send()` ya pudo llamar a `remote.put()`
(`sync_engine.dart:409–415`), que entrega un `set()` al SDK de Firestore.
`stop()` (`:548–555`) no cancela esa escritura ya iniciada. Lo observado
es consistente con que el SDK la complete al recuperar la red. La lectura
estática de Timonel no bastaba para prometer la pausa.

**Corrección mínima propuesta, sin aplicarla:** dejar el subtítulo confirmado
en **«Sigue en Recientes; no se borra nada.»** y retirar la promesa temporal.
Los botones y los otros textos pasan; el dictamen se mantiene en **NO PASA**
con la frase actual.

Evidencia: `web-comandos-t138-rev.json`, `sin-red-antes-del-corte.json`,
`sin-red-registrado-sin-red.json`, `sin-red-cerrado-sin-red.json`,
`sin-red-red-devuelta-plano-cerrado.json`, `proxy-restablecido.json`,
`subida-antes-de-reabrir.json`, `sin-red-cerrado-red-restablecida-45s-mas.json`,
`sin-red-reabierto.json` y `sin-red-dictamen.json`. Capturas bajo `e2e/muelle/`,
de `12-…` a `16-…` y de `18-…` a `20-…`, y
`e2e/oficina/17-oficina-recibe-con-muelle-en-inicio.png`.

## Cierre y entrega

La operación sintética se cerró desde la oficina al terminar: conserva
**1 movimiento y 1 fuente**, con huella y longitud de fuente correctas.
No se borraron movimientos. Chrome de prueba, Firebase demo, proxies,
conductor y servidor quedaron cerrados. Comprobación final a las
**18:49:08, Guatemala**, sin escuchas en 5941, 5942, 8383, 8384, 9398, 9399,
4498, 4598 o 9150 (`cierre-final.json`, `e2e/remoto-resumen-final.json`).

`evidencia-indice.json` indexa **24 capturas**. La copia verde conserva
**812/812 huellas**. **Único archivo para Git: `docs/t138/revision-codex.md`.**
**No cambian `pubspec.yaml` ni `pubspec.lock`**, ni código de producto,
documentación ajena, configuración privada o archivos H5. Las evidencias
están en **`build/t138rev/`**, ignorado por `/build/`; no se propone forzarlas.
No se ejecutaron escrituras de Git ni publicaciones de Firebase.

Para Carlos, desde `C:\Proyectos\baystream-qa-r4`, con HEAD separado:

```powershell
git add -- docs/t138/revision-codex.md
git commit -m "Sprint 4: revision corta de T-138"
git push origin HEAD:sprint-4
```

Tres líneas:

1. **NO PASA:** el movimiento subió con el plano cerrado; el subtítulo confirmado promete una pausa falsa.
2. Navegación y capturas pasan; 6/6 verdes, 6/6 rojas esperadas, suite 2107/2107 sin omitidas y analyze cero.
3. Se propone retirar «Lo pendiente sube al reabrirlo»; no se modificó código y el banco quedó cerrado.

Mensaje para Yov:

> Yov: T-138 NO PASA por el subtítulo confirmado. El muelle registró una
> descarga sin red, volvió a Inicio y, al restituir la red, el SDK la subió
> antes de reabrir (createTime 18:43:56.949, Guatemala). Al reabrir quedó un
> solo documento con el mismo Id, con updateTime posterior. Marca, hover,
> Tab/Enter, Recientes, previo y subtítulos a 360 pasan; 6/6 verdes, 6/6
> rojas contra las tres piezas de 5ab830b, suite 2107/2107, analyze cero.
> Propongo dejar «Sigue en Recientes; no se borra nada.», sin aplicarlo.
> Informe: docs/t138/revision-codex.md. Solo ese archivo va a Git; Firebase
> demo, Chrome y proxies cerrados; Windows y Android no se abrieron.

## Segunda revisión

**Dictamen vigente: PASA.** La corrección retira la promesa temporal que motivó
el NO PASA anterior. Se conserva arriba la primera revisión como historial;
el P2 de ese subtítulo queda resuelto con el texto actual.

3-nov-2026, Guatemala. Revisión en `C:\Proyectos\baystream-qa-r4`, con HEAD
separado **`32eac61839ac31c9bc22746800b810c6777663af`**, «Sprint 4: decision
10.103 y DESIGN.md con volver al inicio». Inmediatamente debajo está
**`8e364a49b27bff22759e834664134c3e6ce23646`**, «Sprint 4: T-138, el subtitulo
de volver al inicio».

**Paso 0 conforme:** desde `b153048` solo cambian
`vessel_overview_page.dart`, `test/t138_volver_al_inicio_test.dart`,
`docs/T138-RESULTADOS.md`, `SPRINT-4.md` y `DESIGN.md`. No había diferencias
de contenido rastreado respecto de HEAD; permanecían los avisos LF/CRLF
conocidos de los tres generados de Windows.

**Revisión de la corrección:**

- Con un plano confirmado o publicado, el producto dice exactamente
  **«Sigue en Recientes; no se borra nada.»**. La frase sobre subir al reabrir
  ya no está en el producto. Con un previo conserva
  **«Descarta el previo sin guardar nada»**, el mismo `_clear` y su pregunta.
- La prueba usa ambos textos exactos y los busca dentro de `mas-cerrar`;
  conserva las comprobaciones de Recientes y de «Seguir mirando».
- El informe de Timonel atribuye el recorrido, la marca de tiempo y la
  explicación a Codex. Reconoce que su promesa inicial venía de una lectura
  de código y distingue sus propias corridas. No se atribuye nuestra medición
  ni afirma haber repetido el recorrido después de esta corrección.
- La decisión 10.103 y DESIGN, secciones 8 y 13.7, describen la marca del
  riel de oficina, la misma acción de «Más», la pregunta del previo y los
  textos actuales. Son coherentes con el comportamiento revisado. El envío
  observado se refiere a escrituras ya entregadas al SDK que pueden terminar
  con el plano cerrado; la recepción de otros equipos sigue expresamente
  sin medir. La pantalla ya no promete nada de esa sincronización.

**Corridas nuevas, en secuencia y con luz verde/SEMÁFORO de Carlos:**

| Comando, copia limpia de esta punta | Resultado |
|---|---|
| `flutter test test/t138_volver_al_inicio_test.dart --reporter json` | **6/6**, sin fallos ni omitidas; salida 0 |
| `flutter test --reporter json`, suite completa en una corrida | **2107/2107**, cero fallos, cero omitidas; salida 0 |
| `flutter analyze lib test` | **Cero incidencias**, salida 0 |
| Integridad final de la copia | **812/812 archivos** idénticos a HEAD |

La copia se materializó mediante lecturas `git show`, con el mismo
prerrequisito generado de T-124 y su huella ya documentada arriba.
Las evidencias nuevas quedan separadas en **`build/t138rev/segunda/`**:
`head.txt`, `paso0-diff.txt`, `revision-estatica.json`, `t138-resumen.json`,
`suite-resumen.json`, `analyze.log`, sus registros de ejecución,
`copia-manifiesto.json`, `integridad-copia.json` y `pubspecs-integridad.json`.

Conforme al encargo, **no se abrió Chrome ni ningún cliente**, no se compiló
la app ni se levantaron emuladores. No se repitió la revisión visual a 360:
el nuevo subtítulo es más corto que el que ya se vio completo. No se tocaron
apps instaladas, el almacén real ni Firebase. No se modificó código ni se
ejecutaron escrituras de Git. **`pubspec.yaml` y `pubspec.lock` no cambian.**
La única modificación para Git es este anexo en **`docs/t138/revision-codex.md`**.

Para Carlos, desde `C:\Proyectos\baystream-qa-r4`, con HEAD separado:

```powershell
git add -- docs/t138/revision-codex.md
git commit -m "Sprint 4: segunda revision de T-138"
git push origin HEAD:sprint-4
```

Tres líneas:

1. **PASA:** subtítulo corregido, previo conservado y P2 del texto anterior resuelto.
2. **6/6**, suite **2107/2107** sin omitidas y **analyze cero**, en copia limpia.
3. Informe, 10.103 y DESIGN coherentes; solo se anexa este informe, sin abrir clientes ni tocar el almacén real.

Mensaje para Yov:

> Yov: segunda revisión de T-138 PASA, sobre 32eac61/8e364a4. El subtítulo
> confirmado ya dice «Sigue en Recientes; no se borra nada.»; el previo se
> conserva. La prueba exige ambos textos y la documentación atribuye bien
> el hallazgo y su límite. Nuevas corridas: 6/6, 2107/2107 sin omitidas,
> analyze lib/test cero; 812 huellas intactas. Sin Chrome, clientes,
> emuladores ni almacén real. Solo se anexa «Segunda revisión» en
> docs/t138/revision-codex.md; ninguna escritura de Git ni publicación.
