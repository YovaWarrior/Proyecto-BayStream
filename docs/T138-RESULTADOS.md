# T-138 · «Volver al inicio»

Timonel (Claude Code, Opus 5.5), 3-nov, en `C:\Proyectos\baystream-rediseno`, rama `sprint-4`, sobre `5ab830b` (T-136). La versión sigue en `1.0.0+9`.

## Resultado

- En «Más», en los tres clientes, «Cerrar el plano» pasa a llamarse «Volver al inicio». La clave `mas-cerrar` y su lugar en la hoja no cambian.
- En Windows y la Web, la marca de arriba del riel es el botón «Volver al inicio», con descripción emergente, etiqueta para el lector de pantalla y foco con el teclado.
- En el teléfono no hay botón suelto, y Atrás dos veces sigue igual.
- La suite da **2107 de 2107**, sin omitidas, y `analyze` cero.

**No se miró en pantalla:** no se compiló ningún cliente, como pide el encargo. El contorno de foco y el de hover solo están probados en el árbol de widgets; su aspecto lo ve la revisión.

## Paso 0: qué hace volver al inicio

La punta era `5ab830b`, y `lib/`, `test/`, `tool/`, `web/` y `pubspec.*` no tenían cambios.

**No se pierde nada.** `clearVoyage` (`vessel_providers.dart:729`) solo suelta lo que está en memoria:

| Qué | Qué pasa | Dónde se ve |
|---|---|---|
| El plano confirmado | Sigue en el almacén y en «Recientes». Se guarda al confirmar (`:502`), antes de quedar `Publicado` (`:513`), y `clearVoyage` no llama a ningún borrado | `recentVoyagesProvider` lee `getAllVoyages` |
| La bitácora | No se toca: vive en su propio almacén | `clearVoyage` no la nombra |
| Lo que falta por subir | Sigue en la bitácora, pendiente | `pendingOf` |
| **La sincronización** | **Se detiene mientras el plano no está abierto** | Abajo |

**La sincronización.** Con el plano cerrado, `activeOperationProvider` da `null` y `syncStatusProvider` pasa a local. Eso cancela `follow`, cuyo `onCancel` llama a `engine.stop()`. El botón de la nube del inicio mantiene activo el provider, así que el cambio ocurre aunque el plano ya no esté en pantalla. Mientras tanto no se sube lo pendiente ni se recibe lo de los demás. Al reabrir, `follow` crea otro motor: `start` escucha la bitácora y `flush` envía lo pendiente, y el envío es idempotente. Lo que iba en camino lo confirma el eco o el reenvío del siguiente arranque.

**Esto se leyó en el código, no se midió:** en las pruebas no hay Firebase y `syncStatusProvider` se queda en local.

**El subtítulo nuevo** lo dice: «Sigue en Recientes; no se borra nada. Lo pendiente sube al reabrirlo». Es más largo que el ejemplo del encargo porque la pausa del envío es lo que más le importa a quien tiene movimientos sin subir. A 360 dp ocupa dos líneas. Con un previo sigue «Descarta el previo sin guardar nada», con la misma pregunta.

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
| 5 | `flutter analyze` | **Cero** | 35 s | Sí |

El rojo de la corrida 1 no se repitió tras corregir la prueba: el caso del ancho ya caía antes de esa línea, al no encontrar la marca.

Sin `// ignore:`, sin dependencias nuevas y sin tocar `lib/main.dart` ni los dos congelados.

## Archivos

`pubspec.yaml` y `pubspec.lock` **no cambian**.

- `lib/features/vessel/presentation/widgets/navegacion_del_viaje.dart`
- `lib/features/vessel/presentation/pages/vessel_overview_page.dart`
- `lib/features/vessel/presentation/providers/loading_operation_provider.dart` (solo un comentario)
- `test/t114_fase3_inicio_test.dart` (solo un comentario)
- `test/t138_volver_al_inicio_test.dart` (nuevo)
- `docs/T138-RESULTADOS.md` (nuevo)

## Bloque de Git

Para Carlos, en `C:\Proyectos\baystream-rediseno`:

```bash
git add -- lib/features/vessel/presentation/widgets/navegacion_del_viaje.dart
git add -- lib/features/vessel/presentation/pages/vessel_overview_page.dart
git add -- lib/features/vessel/presentation/providers/loading_operation_provider.dart
git add -- test/t114_fase3_inicio_test.dart
git add -- test/t138_volver_al_inicio_test.dart
git add -- docs/T138-RESULTADOS.md
git commit -m "Sprint 4: T-138, volver al inicio"
git push
```

## Tres líneas

1. En Windows y la Web, la marca del riel es el botón «Volver al inicio»; en «Más», en los tres clientes, la entrada se llama igual.
2. No se borra nada: el plano sigue en Recientes, y lo pendiente sube al reabrirlo, porque el envío se detiene con el plano cerrado.
3. Suite 2107 de 2107 y `analyze` cero; falta que la revisión lo vea en pantalla.

## Para Yov

> T-138 lista para la revisión de Codex: marca del riel como «Volver al inicio» en Windows y la Web, «Más» renombrado en los tres clientes, suite 2107/2107, `analyze` cero, rojo 6/6 contra `5ab830b`. El paso 0 confirma que no se borra nada, pero el envío a la nube se detiene mientras el plano no está abierto y sigue al reabrirlo (leído en el código, no medido); el subtítulo lo dice: «Sigue en Recientes; no se borra nada. Lo pendiente sube al reabrirlo». En Android no hay botón, tampoco acostado ni en tableta. Con un previo encima de un plano abierto, descartar vuelve a ese plano, igual que «Más». Te tocan `DESIGN.md` 8 (dos menciones). Informe: `docs/T138-RESULTADOS.md`.
