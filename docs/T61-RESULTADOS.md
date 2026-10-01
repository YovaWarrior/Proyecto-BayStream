# T-61 · Al reabrir un viaje, los datos del buque salen del perfil vigente

Timonel · 30-sep y 1-oct-2026 · Base: `811cdc4` · Codex fuera de sesión; `lib/`
y la máquina para esta tarea.

## Resultado

- Al reabrir desde Recientes, el viaje conserva sus **dimensiones** (filas y niveles) y toma del
  **perfil guardado vigente** los seis parámetros del buque: `stackWeightLimitKg`,
  `centerRowOnDeck`, `centerRowInHold`, `deckTierFloor`, `firstHoldTier` y `firstDeckTier`.
- Si un parámetro vigente dejaría carga fuera de la geometría, **se conserva el valor guardado de
  ese parámetro** y Recientes lo dice con un aviso. No se oculta carga.
- **Sin perfil guardado, no cambia nada**: el viaje se publica intacto.
- **Riverpod:** reabrir publica una instantánea nueva, y `updateShouldNotify` (que compara por
  identidad desde el bloque 7b) notifica. Una prueba lo comprueba con el panel de peso escuchando.

## Cómo está hecho

**Dominio, función pura** — `lib/features/vessel/domain/services/current_profile_parameters.dart`
(82 líneas, nuevo). `applyCurrentProfileParameters(voyageGeometry, profileGeometry, positions)`
parte de la geometría guardada con el viaje y aplica los seis parámetros **uno por uno**. Para
cada uno comprueba `coversAll` contra la carga del viaje; si falla, lo deja como estaba y lo
anota en `keptFromVoyage`. El orden empieza por `deckTierFloor`, porque la frontera decide a qué
zona —y a qué declaración de fila 00— responde cada nivel. Quitar el límite («No lo tengo») va por
`withoutStackWeightLimit()`, porque `copyWith` trata `null` como «sin cambio».

En la práctica, solo la frontera y la fila 00 pueden dejar carga fuera. Las anclas y el límite no
intervienen en `covers`, así que se aplican siempre.

**Proveedor** — `vessel_providers.dart`: `openRecentVoyage` usa la función cuando encuentra perfil,
publica `voyage.withGeometry(efectiva)` si cambió algo (si no, el mismo objeto) y expone
`reopenKeptParameters`. Se limpia en cada publicación y al cerrar el viaje.

**Interfaz** — `recent_voyages_page.dart`: si hay parámetros conservados, muestra *«No se aplicó
del perfil vigente: fila 00 en bodega. Dejaría contenedores de este viaje fuera del plano; se
conserva el valor guardado con el viaje. Revisa el perfil del buque.»* (10 s, antes de cerrar la
pantalla, en el `ScaffoldMessenger` raíz).

**No cambia:** `saveEditedProfile` (con el viaje abierto ya republicaba), la carga desde archivo,
las validaciones ni el dibujo.

## Pruebas

| Corrida | Resultado |
|---|---|
| `flutter test --no-pub` (suite completa) | **`00:09 +281: All tests passed!`** (273 + 8 nuevas) · `build/t61/tests.log` |
| `flutter analyze --no-pub` | **`No issues found!`** · `build/t61/analyze.log` |

**Nuevas** (`test/current_profile_parameters_test.dart`, 8):

1. toma los seis parámetros del perfil y conserva las dimensiones;
2. un límite declarado en el perfil reemplaza el guardado;
3. **la fila 00 declarada inexistente no oculta carga en la 00**: se conserva y se informa
   (criterio 3 de la ficha);
4. una frontera que cambia de zona un nivel con carga se conserva;
5. sin diferencias, devuelve la misma geometría;
6. sin perfil guardado, el viaje se reabre intacto;
7. **el panel se recalcula al reabrir tras editar solo el perfil**: con 20 000 kg aparecen 2
   excesos, la 00 de bodega se conserva, y al volver a «No lo tengo» el panel vuelve a cero;
8. Recientes muestra el aviso con «fila 00 en bodega» y no oculta los dos contenedores.

**Reescrita, por cambio de contrato** (`test/recent_voyages_test.dart`): *«publicar guarda y
reabrir conserva geometría histórica…»* afirmaba que, con el perfil cambiado a 75 000 kg, el viaje
reabierto conservaba **toda** su geometría. Ahora se llama *«…conserva dimensiones y aplica el perfil
vigente…»* y afirma lo que pide T-61: mismo id, misma carga, mismo puerto, la geometría original
con el límite de 75 000 kg, ningún parámetro conservado, y el perfil publicado igual a esa
geometría. **No se borró ninguna aserción sin reemplazo**: las tres sobre la geometría histórica
pasaron a afirmar lo contrario, que es el cambio pedido.

## Compilaciones release

| Cliente | Archivo | SHA-256 |
|---|---|---|
| Windows | `build/windows/x64/runner/Release/data/app.so` | `83A52EC984A90C0C2FC932D16293C7AAF323AD36E87FD8F98304BD6415B48587` |
| Web | `build/web/main.dart.js` | `1ED4CA395F49C87AF6238DC7335A4E6C927195C2B4F532B9DC98B2AAEF3A338E` |
| Android | `build/app/outputs/flutter-apk/app-release.apk` | `FE1E9A4738E341B19054A836D378B7F305C8A767B7AF61B53C5A6117B60B32D1` |

Los tres terminaron con código 0 (`build/t61/build-*.log`). El APK instalado en el Honor tiene el
mismo hash. El `main.dart.js` que sirvió Chrome se comprobó dentro del navegador con
`crypto.subtle`: coincide.

## Aceptación por cliente

### Honor X5d — acepta

El perfil de ALFA venía de T-42 («No existe» ×2, «No lo tengo»), y el A01 guardado también. Para
que la prueba demuestre algo, el perfil tiene que diferir del viaje guardado. Todo se editó desde
«Perfiles guardados» **con A03 a la vista**, para que la edición no tocara A01:

| Paso | Perfil de ALFA | A01 reabierto desde Recientes | Editor del viaje reabierto |
|---|---|---|---|
| 1 | límite 62 500.5 y fila 00 de cubierta «No declarada» | **47 / 0 / 6** (`honor-04…`) | cubierta «No declarada», bodega «No existe», 62500.5 (`honor-05…`) |
| 2 | «No existe» ×2 y «No lo tengo» | **0 / 0 / 6** (`honor-07…`) | «No existe» ×2, «No lo tengo» marcado, «Perfil sin cambios» (`honor-08…`, `honor-09…`) |

A03 reabierto: **2 / 100 / 151** (`honor-01…`).

### Windows — acepta

**Hallazgo de entorno:** la instancia que usé en T-42 la había lanzado Codex, y su almacén vivía en
el directorio virtualizado de su paquete
(`%LOCALAPPDATA%\Packages\OpenAI.Codex_…\LocalCache\Local\BayStream`). La que lanzo yo usa el
`%LOCALAPPDATA%\BayStream` real, que no tenía viajes y solo perfiles del 27-sep. No toqué el almacén
de Codex: cargué A01 y A03 desde el corpus.

- A01 se publicó solo con el perfil de ALFA del 27-sep: fila 00 «No declarada» ×2 y **80 000 kg**.
- Con A03 a la vista, el perfil se editó a «No existe» ×2 y 62500.5. A01 reabierto: **47 / 0 / 6**
  (`win-03…`). Su editor muestra «No existe» ×2 (`win-04…`), aunque el viaje guardado tenía
  «No declarada».
- Perfil a «No lo tengo», A01 reabierto: **0 / 0 / 6** (`win-05…`).
- A03, cargado y luego reabierto: **2 / 100 / 151** (`win-01…`).

### Chrome — acepta

Con el `main.dart.js` verificado, en un origen nuevo (`127.0.0.1:8792`):

- A01 se cargó con la propuesta: fila 00 «No declarada» y «No lo tengo». A03 se cargó y dio
  **2 / 100 / 151** (`chrome-01…`); reabierto desde Recientes, también 2 / 100 / 151.
- Con A03 a la vista, ALFA se editó a «No existe» ×2 y 62500.5. A01 reabierto: **47 / 0 / 6**
  (`chrome-02…`). Su editor muestra «No existe» ×2 (`chrome-03…`), aunque el viaje guardado tenía
  «No declarada».
- Perfil a «No lo tengo», A01 reabierto: **0 / 0 / 6** (`chrome-04…`).

**Incidencia de entorno, no del producto:** la ventana de Chrome que controla la extensión estaba
**minimizada** (`document.visibilityState = "hidden"`). Con la pestaña oculta, Chrome detiene los
cuadros de animación y Flutter no avanza: los menús no abren y las capturas expiran. Lo mismo
explica las capturas que expiraban en T-42. Carlos restauró la ventana y la prueba se completó.
Al restaurarse, Chrome recargó la pestaña; no se perdió nada guardado (IndexedDB).

## Archivos

Nuevos: `lib/features/vessel/domain/services/current_profile_parameters.dart`,
`test/current_profile_parameters_test.dart`, `docs/T61-RESULTADOS.md`.
Modificados: `lib/features/vessel/presentation/providers/vessel_providers.dart`,
`lib/features/vessel/presentation/pages/recent_voyages_page.dart`, `test/recent_voyages_test.dart`.
Sin cambios en `pubspec.yaml`, `pubspec.lock`, `lib/main.dart` ni en los archivos congelados.
Evidencia sin versionar en `build/t61/`.
