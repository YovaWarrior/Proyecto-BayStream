# Traspaso · Fase 3, entrega 2 (Timonel, 22-oct-2026, en curso)

Para retomar la entrega 2 (el plano por bahía en la dirección C, `SPRINT-4.md` 10.16) si
este chat se llena. La corrección de la Fase 2 bis (10.17) ya está subida y Codex la acepta
aparte; nada de lo de aquí entra en ese bloque. El brief vigente es 10.16 y 10.17 de
`SPRINT-4.md`; la dirección, `DESIGN.md` 8, 9 y 13; el informe, «Fase 3 · Entrega 2» en
`docs/REDISENO-RESULTADOS.md` (todavía sin escribir).

**Estado al escribir esto:** todo el código y las pruebas de abajo están en el árbol;
`flutter analyze` dio cero antes de los últimos retoques (el tema en caché, el conductor,
los rótulos cortos de la barra y las pruebas actualizadas) y **la suite no se ha corrido**
con ellos: Carlos pidió no correr Flutter mientras Codex acepta la corrección. Lo primero
al retomar es `flutter analyze --no-pub` y `flutter test --no-pub test/t114_fase3_plano_test.dart
test/t114_tema_cache_test.dart test/t107_tabs_test.dart test/t91_plan_toolbar_test.dart`, y
después la suite entera.

## Qué está hecho

- **Navegación adaptable** (`pages/vessel_overview_page.dart`, `widgets/navegacion_del_viaje.dart`,
  nuevo): sin `TabBar` ni la barra de ocho acciones de T-91. Con viaje, los destinos Plano ·
  Lista · Avance (solo con escala) · Estadísticas · Más (`DestinoDelViaje`,
  `destinoDelViajeProvider`). Por debajo de 600 dp, `NavigationBar` (`BarraDelViaje`, claves
  `destino-<name>`, rótulo «Estad.», los rótulos escalan hasta 1.3) y la barra superior con el
  buque, el viaje, Buscar y la nube; en el muelle con una escala publicada, en vez de la barra
  superior va `BsBandaMuelle` con Descarga / Carga (`_BandaDelMuelle`, clave `banda-del-muelle`).
  Desde 600 dp, `NavigationRail` con `BsMarca` arriba y, al pie, la nube y Parámetros
  (`RielDelViaje`, clave `riel-del-viaje`), más la cabecera de la oficina (`_CabeceraDeOficina`,
  clave `cabecera-de-oficina`: buque, estado, Descarga / Carga cuando hay operación, Buscar,
  nube). Desde 1200 dp, además el panel de 360 (`_PanelLateral`, clave `panel-lateral`: el
  detalle de la celda elegida y «En vivo») y Alertas en el riel. «Más» es una hoja
  (`_HojaMas`, clave `hoja-mas`) con Alertas (contador `contador-de-alertas` en aviso, o error
  si alguna es crítica: `alertaCriticaProvider`), Tapas, Orden de descarga, Listado, Comparar,
  Exportar (`export-pdf|csv|json`; en previo, `export-preview` avisa), Nube y Parámetros solo
  sin riel (`mas-nube`, `edit-geometry`), Cargar archivo (`mas-cargar`), Viajes recientes
  (`recent-voyages`), Perfiles (`saved-profiles`), Cerrar el plano (`mas-cerrar`).
  `PanelLateralDisponible` (InheritedWidget) le dice al plano si el detalle va al panel.
- **El plano** (`widgets/bay_plan_view.dart`, reescrito): el modo vive en
  `bayPlanModeProvider` (compartido con los segmentos de la banda y la cabecera);
  «Colorear por» (`ColorearPor` estado / destino / tipo, `colorearPorProvider`, por omisión
  según el modo: 10.4) decide código y color de cada celda; la silueta (`SiluetaDelViaje`,
  nuevo, sobre `BsSiluetaBuque`, cada bahía con clave `silueta-bahia-N`) sustituye a los
  FilterChips «BAHÍA nn (p%)»; las tarjetas (`CifrasDelViaje`, nuevo: descarga con anillo,
  por bajar, re‑estibas, alertas; en carga: carga, llenos, vacíos, conflictos; nada sin
  operación; claves `cifra-*`) van a la derecha de la silueta desde 1040 dp o debajo; la
  rejilla usa `BsCelda` (claves `cell-r-t`, `discharge-<mark>` como `KeyedSubtree`,
  `pending-discharge-*`, `reserved-*`, `reserved-shadow-*`, `neighbor-twenty`, `plan-cell-*`,
  `loading-*` se conservan), con la tapa (`linea-de-tapa`), `BsCascoBodega` detrás de la
  bodega y la curva en las celdas de los extremos; en la vista Estado, por bajar en cubierta /
  bodega, de paso, bajado (palomita) y recién movido; la marca de T-75 («Baja», «Hecho»,
  «Paso», «Re‑estiba», «Revisar») se escribe en el muelle y en las vistas que no son Estado.
  La celda se ensancha con la escala de letra (`BsMedidas.copyWith(anchoCelda:)` en un
  `Theme` local) para que el código de cinco letras quepa a 2.0. La leyenda es `BsCartela`
  (`leyenda-del-plano`: fichas con cuenta + «Resaltar» de RF-011); en el muelle operando,
  abajo va `BsBarraDeOperacion` (`barra-de-operacion`). El detalle es `DetalleContenedor`
  (nuevo, `detalle-contenedor`: `BsHojaDeDetalle` con las filas de antes, IMDG, refrigerado,
  OOG, `DischargeDetailSection`, `OfficePlanActions`), en hoja inferior o en el panel
  (`celdaSeleccionadaProvider`). El peso de celda y pilas sigue como el plano impreso
  («28.7», sin unidad); el total de la bahía con `formatearToneladas`.
- **La regla del naranja con datos reales** (`providers/plano_providers.dart`, nuevo):
  `recienMovidoProvider.observar(movimientos)` aprende la bitácora al abrir y marca lo que
  llega después (propio o por la nube) 1.5 s; el plano la alimenta con
  `loadingOperationProvider` (`ref.listen` más una lectura inicial: este Riverpod no tiene
  `fireImmediately`); el toque en Descarga marca la celda antes de registrar
  (`_tocarEnDescarga`); la silueta destella la bahía. `EnVivoDelViaje` (nuevo, `en-vivo`)
  lista los movimientos con `eventosEnVivo` (rol del equipo, nunca nombre).
- **Celdas de carga** (`loading_controls.dart`, `LoadingCell`): `BsCelda` con el OR como código,
  `pendiente` / `hecho` como rol, «Sube» / «Cargado» como segunda línea, conflicto y
  cancelación como marca («Revisar», «Cancelado»); etiqueta accesible de T-107 intacta.
- **Pendientes de 10.8 en código:** el selector de modo ya no recorta «Contenido» ni
  «Número de orden» (`loading_plan_controls.dart`: dos líneas, `itemHeight: null`); la
  acción de `BsBanda` baja a su línea cuando no cabe (`bs_banda.dart`); el código a 2.0
  (arriba). `BsBandaMuelle` admite `mostrarModos`; `BsSiluetaBuque` pone clave a cada
  bahía. `ContainerSearchDelegate` recibe `onIrAlPlano` en vez del `TabController`.
  `OperationProgressBody` (en `operation_progress_page.dart`) es el avance sin barra, con
  `onCelda` para el destino Avance.
- **10.16:** `test/t114_fuentes_test.dart` acepta la licencia en LF o CRLF; `DESIGN.md`
  13.5 anota la decisión (el tema sigue al sistema), 8 y 13.8 anotan lo que el código hace
  distinto del lienzo (T-91 retirada, «Estad.» y la escala 1.3 de la barra, Avance embebido,
  la leyenda, la celda de carga, el ensanche a 2.0).
- **El conductor de T-99** (`tool/t99_conductor.dart`): `_pestana` busca el texto dentro de
  `NavigationBar`/`NavigationRail`; las bahías por la clave `silueta-bahia-N`; escenario
  nuevo `plano` (publica `T99_ARCHIVO`, y por tema, letra y tamaño captura `plano` con la
  bahía más cargada, `lista` y `avance`). Falta parametrizar `-Escenario` en
  `tool/t114_capturas_windows.ps1` (hoy fija `inicio`) y escribir las variantes Web y
  emulador para el plano.
- **El tema en caché (bloque aparte, 10.17):** `BayStreamTema.claro`/`oscuro` devuelven la
  misma instancia por densidad (`bs_tema.dart`); `test/t114_tema_cache_test.dart` comprueba
  la identidad y que un rebuild de `BayStreamApp` no deje animaciones corriendo.
- **Pruebas actualizadas** (sin bajar el conteo): `t91_toolbar_support` (abrir y cerrar
  «Más» en vez de plegar), `t91_plan_toolbar_test`, `t97_text_test` (título = buque,
  destino `destino-estadisticas`, detalle nuevo), `t104_text_test` (rótulos de la barra),
  `t107_tabs_test` (reescrito con `destinoDelViajeProvider`), `t110_bays_test` y
  `vessel_profile_view_test` (silueta por clave y semántica «seleccionada»),
  `t106_plan_widget_test` (título «Bahía 03», «Baja»), `t75_discharge_test` (claves
  `discharge-<mark>`), `recent_voyages_test`, `profile_loading_page_test`,
  `t114_fase3_inicio_test` («Más»), `t102`, `effective_weight_test`, `t90_theme_test`,
  `bay_plan_grid_test` (peso como `linea2` de `BsCelda`; pilas por `peso-pila-*`; marca de
  exceso con radio 6), `t69_reserved_slots_view_test` («40′», relleno papel),
  `t81_office_widget_test` («Cancelado»). Nueva: `test/t114_fase3_plano_test.dart` (13
  pruebas: navegación por ancho, Avance, Más y su contador, silueta, tarjetas, Colorear por,
  recién movido, detalle en panel y hoja, banda del muelle, selector y código a 2.0, banda
  apilada).

## Archivos tocados por la entrega 2 (ninguno de `domain/`, `data/`, `main.dart`, `pubspec.*`)

La lista exacta, un `git add` por ruta, está en el bloque de git de la sección «Fase 3 · Entrega 2»
de `docs/REDISENO-RESULTADOS.md`. En resumen:

- **Nuevos en `lib/`:** `features/vessel/presentation/providers/plano_providers.dart` y, en
  `widgets/`, `navegacion_del_viaje.dart`, `detalle_contenedor.dart`, `cifras_del_viaje.dart`,
  `en_vivo_del_viaje.dart`, `silueta_del_viaje.dart`.
- **Modificados en `lib/`:** `pages/vessel_overview_page.dart`, `pages/operation_progress_page.dart`,
  `widgets/bay_plan_view.dart`, `widgets/loading_controls.dart`, `widgets/loading_plan_controls.dart`,
  `widgets/container_search_delegate.dart`, `widgets/plan_drag_confirmation.dart`;
  `core/design/bs_medidas.dart`, `bs_tema.dart` (el `Badge` global en aviso, 10.17) y, en
  `componentes/`, `bs_banda.dart`, `bs_banda_muelle.dart`, `bs_cartela.dart`,
  `bs_silueta_buque.dart`, `bs_tarjeta_cifra.dart`.
- **Pruebas:** nueva `test/t114_fase3_plano_test.dart` (16); actualizadas `bay_plan_grid_test`,
  `effective_weight_test`, `profile_loading_page_test`, `recent_voyages_test`,
  `support/t91_toolbar_support`, `t102_weight_display_test`, `t104_text_test`,
  `t106_plan_widget_test`, `t107_tabs_test`, `t110_bays_test`, `t114_fase3_inicio_test`,
  `t114_fuentes_test`, `t69_reserved_slots_view_test`, `t75_discharge_test`,
  `t81_office_widget_test`, `t90_theme_test`, `t91_plan_toolbar_test`, `t97_text_test`,
  `vessel_profile_view_test`.
- **Instrumentos (`tool/`):** `t99_conductor.dart`, `t114_capturas_windows.ps1`,
  `t114_capturas_web_plano.py` y `t114_capturas_android_plano.py` (nuevos), `t114_ram_windows.ps1`
  (nuevo), `t114_primera_windows.py` (el color de noche de la marca), `t112_censos.py`.
- **Documentos y evidencia:** `DESIGN.md` (8, 13.5, 13.8), este traspaso,
  `docs/rediseno/fase3/entrega2/` (capturas, `ram/`, `rnf-002/`, `censos/`,
  `flutter-ui-audit.txt`) y la sección en `docs/REDISENO-RESULTADOS.md`.
- **Bloque aparte (tema en caché):** `lib/core/app.dart` y `test/t114_tema_cache_test.dart`.
- **Fuera de todo bloque:** los tres generados de `windows/flutter/` (solo cambia el fin de línea).

## Dónde va (23-oct, 03:00): cerrada, a la espera de Codex

- **Entregada.** La sección «Fase 3 · Entrega 2» está en `docs/REDISENO-RESULTADOS.md`, con los
  dos bloques de git para Carlos (el de la entrega y, aparte, el del tema en caché:
  `lib/core/app.dart` + `test/t114_tema_cache_test.dart`) y el mensaje para Yov. Sigue
  «ALTO: Codex acepta la entrega 2».
- Suite completa **1242** en verde (piso 1224) y `analyze` en cero tras la última corrección.
- Lo que las capturas enseñaron y se corrigió al cerrar: el título de la bahía al ancho de la
  vista (a 360 salía cortado) y, para el teléfono bajo (menos de 560 dp de alto útil para el
  plano, el emulador de 360 × 640), la cabecera del plano (controles y silueta) se va al
  desplazar la rejilla y vuelve (`NestedScrollView`; `alturaParaAnidar` en `bay_plan_view.dart`,
  `DESIGN.md` 13.8, dos pruebas en `t114_fase3_plano_test`). A 360 × 800 no cambia nada.
- Evidencia en `docs/rediseno/fase3/entrega2/`: `despues-windows/` (72), `despues-web/` (40),
  `despues-emulador/` (28, con `*_rejilla` tras desplazar), `ram/` (antes y después, CSV y
  resúmenes), `rnf-002/{windows,web,android}/`, `censos/`, `flutter-ui-audit.txt`.
- Mediciones: RNF-002 en tres pasos en los tres clientes (Windows 1.84–2.19 s; Web 0.30–0.48 s
  y 1.28–1.60 s en primera visita; emulador cotas 3.06–3.88 s). RAM antes/después igual en los
  pasos del plano (≈ 156 MB); el estable de T-99 sigue en ≈ 510 MB por la Lista (RNF-001/007,
  fuera de esta entrega).
- Bancos en `%TEMP%`: `t99-r4-e2\copia` (esta entrega) y `t99-r4-antes\copia` (`HEAD`
  ccc8c2f). El de antes falló una vez al compilar Windows (SDK C++ de Firebase a medio extraer):
  bastó borrar `build/windows` y compilar de nuevo. El servidor de la Web (puerto 5899) puede
  seguir en pie; los MP4 de RNF-002 están en `%TEMP%\t114-e2\primera\android\`.
- Si Codex devuelve hallazgos, el punto de partida es la sección 4.8 del informe (lo que queda
  anotado) y este archivo.

## Decisiones tomadas en el código que el brief no fijaba

- La barra de ocho acciones y el plegado de T-91 se retiran (es lo que `DESIGN.md` 8 pide).
  `planToolbarCollapsedProvider` y su almacén quedan sin lector; retirarlos toca `domain/`
  y `data/`, así que se propone como tarea.
- En la oficina, la vista Estado deja el código y el peso en las celdas por bajar (13.2);
  la marca con rótulo («Baja») va en el muelle y en las vistas Destino y Tipo.
- `BsCelda` no dibuja icono y código a la vez; por eso la celda de carga lleva el OR como
  código y el estado como rol y segunda línea. Si se quiere el icono junto al OR, es un
  cambio de la pieza (`bs_celda.dart`), que hoy está en aceptación.
- En la barra inferior el destino es «Estad.» y los rótulos escalan hasta 1.3: cinco
  destinos en 360 dp dan 72 dp a cada uno. El nombre entero va en la descripción emergente.
- Atrás en Android (cerrar hojas y paneles primero, preguntar si hay un previo) no se tocó.

## Corrección tras la aceptación de Codex (23-oct, 10.21)

Codex devolvió la entrega 2 con cuatro hallazgos (`docs/rediseno/fase3/entrega2/aceptacion-codex.md`)
y la corrección está hecha en un chat nuevo: la sección «Fase 3 · Entrega 2 · Corrección tras la
aceptación de Codex» de `docs/REDISENO-RESULTADOS.md` es el informe, con su bloque de git. En
resumen: la cabecera de la oficina se reparte o se pliega (H1); la celda de carga recibe el
movimiento real, también la reserva con su vacío (H2, `_posicionDe` en `plano_providers.dart`);
el anuncio accesible sin panel es `AnuncioDelMovimiento` (H3, en `en_vivo_del_viaje.dart`); el
teléfono bajo arma el plano con la silueta compacta y los controles al pie (H4,
`ParteDeLosControles` en `loading_plan_controls.dart`, `compacta` en `BsSiluetaBuque` y en
`_BayGridWidget`); el riel va en `CustomScrollView` + `SliverFillRemaining` con su ancho medido
con la fuente; el zoom vive en `planZoomProvider` y su chip (`ZoomDelPlano`) en la línea de los
controles. Las pruebas de la corrección están en `test/t114_fase3_entrega2_correccion_test.dart`
(18); `test/t114_fase3_correccion_test.dart` sigue siendo la de la corrección de la entrega 1 (10.15).
La evidencia nueva va en `docs/rediseno/fase3/entrega2/correccion/`.

## El paquete de íconos e ilustraciones (23-oct, 10.19)

Con la entrega 2 aceptada (10.22), el paquete de Nube quedó integrado en un chat nuevo: la sección
«Fase 3 · Paquete de íconos e ilustraciones (10.19)» de `docs/REDISENO-RESULTADOS.md` es el
informe, con su único bloque de git para la Parte B y la Parte C. Dónde está cada cosa: la fuente
en `assets/fonts/bs_iconos/` y sus constantes en `lib/core/design/bs_iconos.dart` (el catálogo por
nombre, en `bs_iconos_catalogo.dart`); las ilustraciones como datos en `bs_ilustraciones.dart`,
que escribe `tool/bs_ilustraciones_generar.py` desde `design/ilustraciones/*.json` (no se edita a
mano), y la pieza que las pinta en `componentes/bs_ilustracion.dart`; la regla de qué ícono lleva
cada contenedor en `presentation/widgets/iconos_del_dominio.dart`; la tabla de sitios y
colisiones, en `DESIGN.md` 13.11. Las pruebas son `test/t114_iconos_test.dart`,
`test/t114_ilustraciones_test.dart` y `test/t114_paquete_test.dart` (este último censa `lib/`:
si un ícono de la tabla vuelve a Material, falla). La ilustración cede ante la letra grande
(`BsIlustracion.anchoQueCabe`, 13.11 regla 4). La evidencia va en `docs/rediseno/fase3/paquete/`.

## La corrección del paquete (23-oct, 10.23)

Codex no aceptó el paquete por H1 (la búsqueda dibujaba el glifo de la condición sin etiqueta) y O1 (la
Lista no aplicaba la regla única). La corrección está en la sección «Fase 3 · Paquete · Corrección tras la
aceptación de Codex» de `docs/REDISENO-RESULTADOS.md`. Lo que hay que saber para seguir: la regla del ícono
del contenedor es `CondicionDelContenedor` (glifo y nombre) en `iconos_del_dominio.dart`, y el ícono
principal se dibuja con `IconoDelContenedor` (etiqueta accesible y descripción emergente fuera de la
semántica) en la tarjeta de la Lista, el resultado de la búsqueda y el título del detalle. Las pruebas están
en `test/t114_paquete_correccion_test.dart` (suite 1297) y la evidencia en
`docs/rediseno/fase3/paquete/correccion/`. A pedido de Carlos, la celda del plano nombra también su
insignia y el vacío en la etiqueta (`bay_plan_view.dart`, `CondicionDelContenedor.enLaCelda`), en las
tres vistas de «Colorear por».

## La travesía del inicio (23-oct, 10.24)

`BsTravesia` (`lib/core/design/componentes/bs_travesia.dart`) navega al pie del inicio: el buque de
`sin_conexion` reflejado, con la proa a la derecha, sobre el agua y la línea de flotación a todo el
ancho; solo `Transform` y opacidad, pintado una vez. La regla está en `DESIGN.md` 13.11, regla 7, y la
sección «Fase 3 · La travesía del inicio (10.24)» de `docs/REDISENO-RESULTADOS.md`. Lo que hay que
saber: `InicioView` es ahora un `CustomScrollView` y la banda ocupa solo lo que sobra
(`SliverLayoutBuilder`); una prueba que abra el inicio a 840 de ancho o más y use `pumpAndSettle`
tiene que pedir reducir el movimiento (`FakeAccessibilityFeatures(disableAnimations: true)`), porque
la travesía no se asienta nunca. Las pruebas son `test/t114_travesia_test.dart` y las capturas,
`docs/rediseno/fase3/travesia/capturas/` (de prueba de widget, con el reloj parado al 6, 50 y 95 % del
cruce).

## La corrección de la travesía (23-oct, 10.26)

Codex no aceptó la travesía por H1 (el cruce movía `Positioned.left/top`), H2 (el detector de
`t114_primera_windows.py` pulsaba el muelle de la ilustración y RNF-002 no quedó acreditado) y O1
(`_asentar` del conductor esperaba un reposo que el inicio ya no tiene). La corrección está en la sección
«Fase 3 · La travesía · Corrección tras la aceptación de Codex» de `docs/REDISENO-RESULTADOS.md`. Lo que
hay que saber: la caja del buque es fija y lo mueve `BsGeometriaDeTravesia.transformacion`; el instrumento
de Windows valida el botón por tema, forma y rótulo (también con la capa de hover: al repetir, el cursor
quedaba sobre el botón y lo apagaba), aparca el cursor, comprueba el clic y lo reintenta con diagnóstico
(`--detector` sirve para revisar capturas); el conductor de T-99 pide reducción de movimiento
(`T99_MOVIMIENTO=reducido`) y anota `aviso` cuando `_asentar` vence. RNF-002 en Windows: cinco corridas,
tres pasos, entre 1.84 y 1.89 s (`docs/rediseno/fase3/travesia/correccion/rnf-002/`).

## La candidata del piloto (23-oct, 10.28)

Carlos decidió que el piloto con COMAR vaya con el rediseño. La candidata está en la sección
«Fase 3 · Candidata del piloto (10.28)» de `docs/REDISENO-RESULTADOS.md` y la lista de
comprobación del ensayo y del piloto en `docs/piloto/LISTA-PILOTO.md`. Lo que hay que saber para
seguir: Atrás en Android lo gobierna `AtrasDelViaje` (`navegacion_del_viaje.dart`), con
`cerrablesDeAtrasProvider` para lo abierto que no es una ruta (el menú del zoom se anota al abrirse);
`loadingOperationProvider` comprueba `ref.mounted` tras cada `await`; el tema de los chips resuelve
el color del rótulo por estado (`FilterChip` no usa `secondaryLabelStyle`); la celda escribe
«Re‑est.» (la palabra entera no cabe). Los recorridos del piloto son el escenario `piloto` del
conductor de T-99 (Windows; `tool/t114_capturas_windows.ps1 -Escenario piloto -Listado …`),
`tool/t114_piloto_web.py` (Playwright) y `tool/t114_piloto_android.py` (adb); las pantallas sin
rediseñar se revisan con `test/t114_candidata_pantallas_test.dart` y las capturas salen de
`build/t114-candidata/pantallas_test.dart`. Las versiones propuestas: Android 3.1.0 (4), MSIX
3.1.0.0, Web 3.1.0 (4); `pubspec.yaml` ya las lleva. El banco r4 del piloto está en
`%TEMP%\t99-r4-piloto\copia` (Windows, Web en `build/web` servido en 127.0.0.1:5901 con
`t114/` para las entradas, y el APK instalado en `t99_api26`).
