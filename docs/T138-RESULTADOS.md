# T-138 · «Volver al inicio»

Timonel (Claude Code, Opus 5.5), 3-nov, en `C:\Proyectos\baystream-rediseno`, rama `sprint-4`, sobre `5ab830b` (T-136). La versión sigue en `1.0.0+9`.

**Corregido después de la revisión de Codex** (`docs/t138/revision-codex.md`), que dijo NO PASA por el subtítulo. La primera entrega es `46580f4`; esta corrección cambia una línea de texto en el producto y una en la prueba, sobre `b153048`.

## Resultado

- En «Más», en los tres clientes, «Cerrar el plano» pasa a llamarse «Volver al inicio». La clave `mas-cerrar` y su lugar en la hoja no cambian.
- En Windows y la Web, la marca de arriba del riel es el botón «Volver al inicio», con descripción emergente, etiqueta para el lector de pantalla y foco con el teclado.
- En el teléfono no hay botón suelto, y Atrás dos veces sigue igual.
- Con un plano confirmado o publicado, el subtítulo de «Más» es «Sigue en Recientes; no se borra nada.»
- La suite da **2107 de 2107**, sin omitidas, y `analyze` cero.

**En pantalla:** Timonel no compiló ningún cliente, como pide el encargo. La marca, el hover, Tab y Enter, Recientes, el previo y los subtítulos a 360 los recorrió Codex en Chrome sobre `46580f4`, y pasan. Esta corrección no se volvió a mirar en pantalla: el subtítulo es más corto que el que Codex midió a 360. Windows y Android no se abrieron.

## Paso 0: qué hace volver al inicio

La punta era `5ab830b`, y `lib/`, `test/`, `tool/`, `web/` y `pubspec.*` no tenían cambios.

**No se pierde nada.** `clearVoyage` (`vessel_providers.dart:729`) solo suelta lo que está en memoria:

| Qué | Qué pasa | Dónde se ve |
|---|---|---|
| El plano confirmado | Sigue en el almacén y en «Recientes». Se guarda al confirmar (`:502`), antes de quedar `Publicado` (`:513`), y `clearVoyage` no llama a ningún borrado | `recentVoyagesProvider` lee `getAllVoyages` |
| La bitácora | No se toca: vive en su propio almacén | `clearVoyage` no la nombra |
| Lo que falta por subir | Sigue en la bitácora, y **sube aunque el plano esté cerrado** | Abajo |

**La sincronización sigue con el plano cerrado,** como mostró la revisión de Codex. Con el muelle sin red, registró una descarga y volvió al inicio. Al restituir la red, y sin reabrir el plano, el movimiento llegó al emulador (`createTime` 18:43:56.949, Guatemala). Al reabrir quedó un solo documento, con el mismo Id.

**Lo que esta entrega decía antes era falso.** Decía que la sincronización se detenía y que lo pendiente subía al reabrir. Salió de leer el código hasta `SyncEngine.stop()`, que sí detiene el motor, sin mirar lo que queda por debajo: `stop()` no cancela la escritura que `_send()` ya le entregó al SDK de Firestore, y lo observado es consistente con que el SDK la complete al volver la red. Esa explicación es de Codex. Timonel lo había anotado como «leído, no medido», pero igual lo puso en la pantalla como una promesa, y una lectura de código no bastaba.

**Lo que no se midió:** lo que llega de otros dispositivos con el plano cerrado. Por eso ningún texto de la pantalla habla de la sincronización.

**El subtítulo** dice solo lo comprobado: «Sigue en Recientes; no se borra nada.» Con un previo sigue «Descarta el previo sin guardar nada», con la misma pregunta.

## El cambio

- `RielDelViaje` recibe `onVolverAlInicio`. Sin él, la marca es solo la marca, como antes.
- `_MarcaVolverAlInicio` ocupa los mismos 44 dp que la marca. El contorno de foco y el de hover van por fuera del recuadro y encima, porque la tinta de un `InkWell` queda debajo del azul de la marca y no se vería.
- `Tooltip` con `excludeFromSemantics`: el nombre lo da la etiqueta, y con la descripción se leería dos veces en Windows.
- La página pasa `_clear(context, preview: preview)`, lo mismo que «Más».

## Decisiones y límites

1. **Android con el teléfono acostado.** El riel sale desde 600 dp en cualquier plataforma, y la orientación no está fija: el Honor acostado mide 800 dp. Para cumplir «en Windows y la Web» y «en el teléfono, nada más», la marca solo es botón fuera de Android (`AtrasDelViaje.porOmision`). Una tableta Android tampoco lo lleva.
2. **Un previo encima de un plano abierto.** `discardPreview` vuelve a lo de antes: después de «Descartar» se queda en ese plano, no en el inicio, y hace falta otro toque. Es lo que ya hacía «Más» y el encargo pide lo mismo, así que no cambia.
3. **«Recientes» tiene tope.** `recentVoyageLimit`: al entrar planos nuevos, sale el más viejo. El subtítulo es cierto al volver al inicio, no para siempre. No es de T-138.
4. **Quedan sin pasar al texto nuevo**, porque el encargo se limita a pruebas y comentarios:
   - `DESIGN.md:447`, y `DESIGN.md` 8 dice «Cerrar plano»: le tocan a Yov;
   - cinco conductores de capturas de tareas cerradas: `tool/t114_capturas_android_plano.py`, `t122_capturas_android.py`, `t122_capturas_web.py`, `t123_capturas_web.py` y `t124_capturas_android.py`. Buscan el texto en pantalla y fallarían si se vuelven a correr;
   - `docs/REDISENO-RESULTADOS.md`, que es histórico.
5. `test/t91_plan_toolbar_test.dart` no nombra «Cerrar el plano», solo la clave `mas-cerrar`: no cambia.

## La prueba nueva

`test/t138_volver_al_inicio_test.dart`, 6 casos. Los cuatro del encargo, más dos: teclado y lector de pantalla, y el previo en «Más». Los de la marca corren con `TargetPlatform.windows`.

| Caso | Contra `5ab830b` | Con T-138 |
|---|---|---|
| A 1280, plano confirmado: vuelve al inicio y sigue en Recientes | Rojo: no existe la marca como botón | Verde |
| Con un previo, la marca pregunta y «Seguir mirando» no descarta | Rojo: ídem | Verde |
| Descripción emergente, etiqueta y foco con el teclado (Tab y Enter) | Rojo: ídem | Verde |
| El riel conserva su ancho y sus destinos | Rojo: ídem | Verde |
| «Más» a 360 dice «Volver al inicio», con su subtítulo | Rojo: no encuentra el texto | Verde |
| Con un previo, «Más» conserva su subtítulo y su pregunta | Rojo: ídem | Verde |

El rojo se corrió poniendo en el árbol las tres piezas de `lib/` de `5ab830b`, leídas con `git show`, y restaurándolas después; `cmp` las dio iguales al respaldo.

La prueba del ancho compara el riel con el botón contra el mismo riel con la marca sola, destino por destino.

## Las corridas

Con la luz verde de Carlos. Los registros están en `build/t138/`.

| # | Corrida | Resultado | Tiempo | ¿Vale? |
|---|---|---|---|---|
| 1 | La prueba contra `5ab830b` | 6 de 6 en rojo | 2 s | Sí |
| 2 | La prueba con T-138 | **5 de 6**: mi prueba fijaba 80 de ancho, y con las fuentes del producto el riel mide 98,25, con y sin botón | 3 s | No: error de la prueba, no del producto |
| 3 | La prueba corregida | 6 de 6 | 7 s | Sí |
| 4 | Suite completa | **2107 de 2107**, sin omitidas | 162 s | Sí |
| 5 | `flutter analyze` | **Cero** | 35 s | Sí, para `46580f4` |
| 6 | La prueba, con el subtítulo corregido | 6 de 6 | 12 s | **Sí** |
| 7 | Suite completa | **2107 de 2107**, sin omitidas | 130 s | **Sí** |
| 8 | `flutter analyze` | **Cero** (`No issues found!`) | 42 s | **Sí** |

El rojo de la corrida 1 no se repitió tras corregir la prueba: el caso del ancho ya caía antes de esa línea, al no encontrar la marca. Tampoco se repitió para la corrección: las pruebas buscan el subtítulo por su texto exacto.

Las corridas 1 a 5 son de la primera entrega, y las 6 a 8, de esta corrección.

Sin `// ignore:`, sin dependencias nuevas y sin tocar `lib/main.dart` ni los dos congelados.

## Archivos

`pubspec.yaml` y `pubspec.lock` **no cambian**. Los de esta corrección:

- `lib/features/vessel/presentation/pages/vessel_overview_page.dart`
- `test/t138_volver_al_inicio_test.dart`
- `docs/T138-RESULTADOS.md`

La primera entrega (`46580f4`) cambió además `navegacion_del_viaje.dart`, un comentario de `loading_operation_provider.dart` y un comentario de `test/t114_fase3_inicio_test.dart`.

## Bloque de Git

Para Carlos, en `C:\Proyectos\baystream-rediseno`:

```bash
git add -- lib/features/vessel/presentation/pages/vessel_overview_page.dart
git add -- test/t138_volver_al_inicio_test.dart
git add -- docs/T138-RESULTADOS.md
git commit -m "Sprint 4: T-138, el subtitulo de volver al inicio"
git push
```

## Tres líneas

1. Con un plano confirmado o publicado, el subtítulo de «Volver al inicio» dice «Sigue en Recientes; no se borra nada.»
2. El informe corrige el paso 0: la sincronización sigue con el plano cerrado, como mostró Codex, y la pantalla ya no promete una pausa.
3. Prueba 6 de 6, suite 2107 de 2107 y `analyze` cero; solo cambió ese texto.

## Para Yov

> T-138 corregida: con un plano confirmado o publicado, el subtítulo es «Sigue en Recientes; no se borra nada.», y la prueba comprueba ese texto. Prueba 6/6, suite 2107/2107, `analyze` cero. El informe corrige el paso 0: la sincronización sigue con el plano cerrado, como mostró Codex; la pausa que afirmó Timonel era una lectura de código que no se sostuvo. Lo que llega de otros dispositivos con el plano cerrado no se midió. Sin recorrer otra vez en pantalla. Te siguen tocando `DESIGN.md` 8 (dos menciones). Informe: `docs/T138-RESULTADOS.md`.
