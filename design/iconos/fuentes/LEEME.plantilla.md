# Íconos e ilustraciones de BayStream · paquete 1 (v3)

Estilo **B · Sólido**, elegido por Carlos Martínez el 22 de octubre de 2026 (decisión 10.18) sobre la página
de conceptos (`design/iconos/conceptos.png`). Todo es vectorial, dibujado para BayStream y original; nada deriva de
Material, Lucide ni otro juego. Los íconos genéricos de la app (buscar, cerrar, micrófono) siguen siendo
de Material. Firma: **Nube**. Integra: **Timonel**.

v2 (23-oct): `descarga` y `carga` con las flechas en el sentido de la app («Baja» / «Sube»), fuente 1.1 con los
mismos códigos; fecha y número de la decisión corregidos. El resto del paquete es idéntico a la v1.

v3 (2-nov): se suma `oficina`, el ícono del rol de oficina para el distintivo de la cabecera: la propuesta (a), la
pantalla con la rejilla del plano calada sobre su pie, elegida por Carlos el 2 de noviembre (decisión 10.86) sobre la
página de tres propuestas. Va en U+E023, después de las insignias; fuente 1.2 con las mismas métricas. Los 35 glifos
anteriores no cambian ni de dibujo ni de código, y el resto del paquete es idéntico al v2 byte a byte: la sección
«Frente al v2» lo demuestra con las huellas.

## Qué trae el paquete

- **32 íconos del dominio** en `design/iconos/svg/` (rejilla de 24, margen de 2, un solo color:
  `currentColor`) y en la fuente `assets/fonts/bs_iconos/BayStreamIconos.ttf`, con sus códigos en
  `design/iconos/codigos.json` desde U+E000 (`oficina`, el de la v3, en U+E023, después de las insignias).
- **4 insignias de 12 px** para la esquina de la celda (refrigerado, peligrosa, fuera_de_medida y vacio) en
  `design/iconos/svg_insignias/` (rejilla de 12) y en la misma fuente, como `insignia_<nombre>`.
- **6 ilustraciones** en `design/ilustraciones/`: `<nombre>_claro.svg`, `<nombre>_oscuro.svg` y
  `<nombre>.json` (los trazos que la app pinta con su propio código).
- `design/iconos/generar.py`, que rehace todo desde las fuentes (`design/iconos/fuentes/` y
  `design/ilustraciones/fuentes/`) y lo verifica; `design/iconos/vista-previa.png`,
  `design/ilustraciones/vista-previa.png`, `design/iconos/comprobacion-fuente.png` y
  `design/iconos/comprobacion-skia.md` / `.png`.

Sin dependencias nuevas en la app: la fuente es un asset y las ilustraciones son SVG más JSON.

## Para Timonel: cómo se integra

1. **La fuente.** En `pubspec.yaml`, junto a las fuentes Plex:
   ```yaml
   fonts:
     - family: BayStreamIconos
       fonts:
         - asset: assets/fonts/bs_iconos/BayStreamIconos.ttf
   ```
   Cada glifo ocupa el cuadrado del em (unitsPerEm 1024, ascendente 1024, descendente 0, avance 1024),
   como en Material Icons, así que `Icon(BsIconos.grua, size: 24)` dibuja exactamente el SVG de 24 y no se
   corre. Las insignias se usan con `size: 12`.
2. **Las constantes** (generadas desde `codigos.json`; van donde Timonel decida, por ejemplo
   `lib/core/design/bs_iconos.dart`):
   ```dart
{{DART}}
   ```
3. **Las ilustraciones.** El SVG sirve para documentos y para la Web; la app pinta el JSON con un
   `CustomPainter`: por cada forma, `Path` desde `ruta` (solo `M`, `L`, `C` y `Z` absolutos), relleno
   y trazo por nombre de color de la paleta (un nombre, o `{claro, oscuro}` cuando cambia con el tema),
   `grosor` del trazo (puntas y uniones redondas) y `punteado` opcional. El bloque `paleta` del JSON trae
   los nombres ya resueltos a hex por tema para que la app no tenga que conocer la tabla; si prefiere usar
   sus tokens, los nombres son los de `DESIGN.md` 13.1 (marca, cubierta, bodega, grua, frase, fondo,
   hoja, papel, panel, panel_alto, tinta, tinta_suave, linea, hecho). El lienzo es `ancho × alto`; se
   escala con `FittedBox` o con un `Transform.scale` uniforme.
4. **Lo que no cambia**: `lib/main.dart`, `domain/` y `data/` no se tocan; el paquete no suma paquetes.

## Los códigos

{{TABLA_CODIGOS}}

## Los 32 íconos: qué es cada uno y cómo se dibujó

| Ícono | Qué es | Cómo se dibujó (rejilla de 24) |
|---|---|---|
| `contenedor_20` | contenedor de 20′ | caja corta de 12 en la banda (x 6–18) con una ranura; la única que no llega a 16 de eje: un 20′ ocupa media celda de 40 |
| `contenedor_40` | contenedor de 40′ | caja 18×12 (x 3–21, y 6–18) con tres ranuras caladas de corrugado y esquineros anchos |
| `contenedor_45` | contenedor de 45′ high-cube | 20 de ancho y más alta (y 5–19); a 16 px lo que se ve es la altura extra |
| `vacio` | contenedor vacío | la caja del 40 vista por dentro: marco de 3 con el hueco de 12×6 |
| `refrigerado` | reefer | el copo propio: tres barras cruzadas con ramas a ±60°, sin caja, para decir «frío» tan rápido como el `ac_unit` que la app usa hoy |
| `peligrosa` | mercancía peligrosa (IMDG) | rombo macizo (celda girada 45°) con el «!» calado; pesa como los demás |
| `fuera_de_medida` | fuera de medida (OOG) | marco de 3 y la carga maciza que atraviesa el techo: lo que no cabe |
| `tanque` | tanque, ISO T | el cilindro (píldora 11×8) entre dos postes, con luz 2 |
| `plataforma` | plataforma / flat rack, ISO P | el piso macizo y dos testeros delgados, nada encima |
| `techo_abierto` | open top, ISO U | la caja del 40 sin techo: muesca calada entre dos postes, ranuras cortas abajo |
| `buque` | perfil del buque, proa a la izquierda | casco con la roda recta, cuatro contenedores en cubierta y la superestructura a popa con el puente calado |
| `bahia` | el corte de la bahía | el ícono de la app en un color: tres celdas de cubierta, la tapa-píldora y la bodega en tres columnas con la curva del casco |
| `tapa_escotilla` | hatch cover | la tapa-píldora levantada (luz 3) sobre la bodega de `bahia`, sin celdas de cubierta |
| `peso_pila` | peso de una pila | dos celdas apiladas sobre la báscula (viga-píldora sobre un fulcro macizo) |
| `limite_apilamiento` | límite de apilamiento | la pila de dos celdas bajo el tope ⊓: lo que no puede subir más |
| `vgm` | peso verificado | el contenedor que se pesa sobre la báscula y, a su lado, el visto bueno macizo |
| `segregacion` | matriz de segregación | fila y columna de cabecera como celdas macizas y el rombo IMDG en el cuerpo de la tabla |
| `descarga` | «Baja»: sacar un contenedor del buque al muelle | la tapa de escotilla arriba (el buque), el contenedor ya suelto bajo ella, la flecha hacia abajo y el muelle al pie |
| `carga` | «Sube»: meter un contenedor del muelle al buque | la misma escena con la flecha hacia arriba y el contenedor todavía sobre el muelle |
| `reestiba` | mover un contenedor de celda | la celda vacía (marco con hueco), la celda ocupada (maciza) y la flecha recta de una a otra |
| `pedir_cambio` | pedir un cambio | el gancho del «?» macizo y, como punto, el contenedor |
| `orden` | número de orden del listado | tres filas (dos barras y el contenedor con su ranura) y la punta que señala «esta posición» |
| `grua` | grúa pórtico del muelle | mástil-pata de tierra, pluma y tirante fundidos en cuña sobre el agua, pata de mar, muelle y el contenedor colgando |
| `muelle` | el muelle | la barra-píldora gruesa con dos bolardos en seta |
| `escala` | puerto de escala | el ancla, con el vocabulario del juego: arganeo calado, caña, cepo, brazos en arco y uñas |
| `baplie` | el archivo EDI del plano | la hoja con doblez y, calado, el corte de la bahía: dos celdas, la tapa como pared y dos columnas de bodega con casco |
| `comparar_baplie` | comparar dos BAPLIE | dos hojas enfrentadas con los dobleces hacia fuera; la celda está en otro sitio en la derecha |
| `baplie_salida` | BAPLIE de salida | la hoja estrecha con sus celdas y la flecha maciza que sale a la derecha; horizontal y con hoja, no es `descarga` |
| `listado_agencia` | el listado de la agencia | la hoja apaisada (hoja de cálculo) con la tabla calada: columna del orden y columna del contenedor |
| `al_dia` | sincronizado con la nube | la nube propia (base de celda y dos lomos) con el visto bueno calado |
| `solo_aqui` | trabajando solo en este equipo | la misma nube con la pausa calada en el sitio del visto bueno |
| `oficina` | el rol de oficina: operaciones o la agencia frente a su pantalla (v3) | la pantalla maciza (19 × 12) con la rejilla del plano calada (3 × 2 celdas de 3.5 × 3), el cuello y el pie-barra de la familia con la base en 22: el mismo pie y la misma base que `muelle`, su pareja en el distintivo de rol |

## Las cuatro insignias

| Insignia | Marca que hereda | A 12 px |
|---|---|---|
| `refrigerado` | el copo, sin ramas: tres barras cruzadas de 3.5 | un asterisco de seis brazos de 1.75 px |
| `peligrosa` | el rombo IMDG con el «!» calado (barra 4×7, punto 4×3) | rombo con el «!» de 2 px |
| `fuera_de_medida` | el marco y la carga que atraviesa el techo | marco de 2 px con la pieza que asoma |
| `vacio` | el marco hueco | marco de 2 px con nada dentro |

Se usan a 12 px en la esquina de la celda (`BsCelda`); como glifos de la fuente son `insignia_<nombre>`.

## Qué ícono de Material reemplaza cada uno en la app

Inventario sobre `lib/` de la rama `sprint-4` (`c287792`), por nombre de archivo y de widget. Donde dice
«ninguno hoy», el concepto es texto en la app o no tiene representación.

| Ícono nuevo | Material hoy | Dónde | Nota |
|---|---|---|---|
| contenedor_20 | ninguno hoy | el tamaño es texto («Tipo: 22G1 (20ft)») en `_ContainerCard` (`containers_list_view.dart`) y en el detalle de `_BayPlanViewState` (`bay_plan_view.dart`) | el contenedor genérico es `inventory_2` |
| contenedor_40 | ninguno hoy | texto «40' reserva» en `_ReservedCell` y la leyenda «Ocupado por 40 pies» en `bay_plan_view.dart` | |
| contenedor_45 | ninguno hoy | cae en el texto «Tipo: …ft» | |
| vacio | `check_box_outline_blank` · `inventory_2_outlined` · `add_box_outlined` | «Vacíos» en `_SummaryGrid` (`voyage_stats_view.dart`); avatar del vacío en `_ContainerSearchResultTile` (`container_search_delegate.dart`); «Asignar vacío» en `LoadingControls` y `_CompactPlanBar` | tres glifos para un concepto |
| refrigerado | `ac_unit` (12 usos) | `BsCelda._iconoDeInsignia`; `_ContainerCell` y el detalle en `bay_plan_view.dart`; chips y detalle de `_ContainerCard`; `_ContainerSearchResultTile`; «Refrigerados» en `voyage_stats_view.dart`; `vistaPreviaCartela` | el único concepto con un solo glifo consistente |
| peligrosa | `warning_amber` · `warning_amber_rounded` · `warning` | `_ContainerCell` y detalle «CARGA PELIGROSA - IMO» (`bay_plan_view.dart`); chip «IMO» y hoja de `_ContainerCard`; `_ContainerSearchResultTile`; «Carga Especial» en `voyage_stats_view.dart`; `BsCelda._iconoDeInsignia` y `vistaPreviaCartela` (rounded); chip «IMDG» (`warning`) | `warning_amber` es además el aviso genérico en ocho sitios: la colisión más seria |
| fuera_de_medida | `open_in_full` | `BsCelda._iconoDeInsignia` (oog); `_ContainerCell`; chip «OOG» de `_ContainerCard`; `_SpecialCard` «OOG» en `voyage_stats_view.dart` | la leyenda del plano lo mezcla con vacío («Vacío / OOG») |
| tanque | `local_gas_station` | `_ContainerCard._getContainerIcon` para `ContainerType.tank` | solo ahí; en celda y detalle el tipo es texto ISO |
| plataforma | `view_agenda` | `_ContainerCard._getContainerIcon` para `ContainerType.flatRack` | solo ahí |
| techo_abierto | `open_in_browser` | `_ContainerCard._getContainerIcon` para `ContainerType.openTop` | `bulk` y `other` caen en `inventory_2` |
| buque | `directions_boat` · `directions_boat_outlined` | relleno: `VoyageSummaryCard` y «Perfil longitudinal» en `VoyageStatsView`; outlined: «Perfiles guardados» en `_VesselOverviewPageState`, `_FilaDeReciente` (`inicio_view.dart`), `_RecentVoyagesPageState` | `directions_boat_outlined` también es «Paso / sigue a bordo» en `BsCelda._iconoDeMarca` y `dischargeMarkIcon` |
| bahia | `view_module` · `view_column` · `grid_view` | «Bahías» en `VoyageSummaryCard` y `_SummaryGrid`; «Contenedores por Bahía» en `VoyageStatsView`; pestaña «Plano» en `_VesselOverviewPageState`; «Posición» en `_ContainerCard`; «Ocupación» en `_VesselProfileViewState`; «Ir a» en `OperationProgressPage` | el corte se dibuja con `BsCascoBodega` y `BsFondoDePlano`, sin ícono |
| tapa_escotilla | `layers_outlined` · `view_column_outlined` · `expand_less`/`expand_more` | «Tapas en la operación» en `_BayPlanViewState._buildBaySelector` y en `OperationProgressPage`; «Editar tapas por bahía» en `_VesselGeometryPageState`; pasos «Tapa: quitar/reponer» en `_DischargeSequencePageState` | `HatchCoverDiagram`, `HatchCoversPage` y `HatchOperationPage` no usan ícono |
| peso_pila | `scale_outlined` | línea `load-stack` en `_LoadCheckPanel` (`loading_controls.dart`) | la columna de pesos por pila del plano es texto; `scale` (relleno) es el peso genérico en `_ContainerCard`, `VoyageSummaryCard`, `_SummaryGrid`, `VoyageStatsView` y `_VesselProfileViewState` |
| limite_apilamiento | ninguno hoy | `_VesselGeometryPageState._buildStackLimitSection` sin ícono; al excederse, `_LoadCheckPanel` usa `block` o `warning_amber` genéricos | |
| vgm | ninguno hoy | «Peso (VGM)» con el `scale` genérico en `_ContainerCard`; filas de texto en los detalles; texto en `VoyageComparisonPage` | |
| segregacion | ninguno hoy | `SegregationPage` sin ícono; `StowageAlertsPage` muestra las reglas como texto | |
| descarga | `south` | `BsModoDeOperacion.descarga` (`bs_banda_muelle.dart`); `BsCelda._iconoDeMarca` (baja); `dischargeMarkIcon` (pending); `_DischargeSequencePageState`; `_VoyageComparisonPageState` (descargados); `_LoadCheckPanel` | el «hecho» de la descarga es `check_circle` / `check_circle_outline`; «Pendientes de descarga» usa `table_chart_outlined` |
| carga | `north` · `arrow_upward` | `BsModoDeOperacion.carga`; `BsCelda._iconoDeMarca` (sube); `_VoyageComparisonPageState` (cargados); celda pendiente en `LoadingCell` | `north` también es «Re-estiba: sale» en `_DischargeSequencePageState` |
| reestiba | `swap_vert` | `BsCelda._iconoDeMarca` (reestiba); `dischargeMarkIcon` (restowed); en la secuencia se parte en `north` («sale») y `undo` («vuelve») | `swap_vert` es a la vez «Pedir cambio» |
| pedir_cambio | `swap_vert` · `inbox_outlined` · `schedule` | «Pedir cambio» en `_ChangeRequestsPageState` y `ChangeRequestsButton` (`change_requests_page.dart`) y en `_CompactPlanBar`; «Bandeja de cambios» (oficina) en los mismos; «Solicitud pendiente» sobre la celda en `PlanDragCell` | mismo glifo que re-estiba |
| orden | ninguno hoy | el OR es texto en `_LoadingPickerState`, `_LoadingEntryState`, `showLoadingDetails`, `_ContainerCell` y `_ReservedCell` | `low_priority` es «Orden de descarga» (la secuencia), otro concepto |
| grua | ninguno hoy | texto «Tapas de grúa» en `_HatchCoversPageState` y «n tapas de grúa» en `_DischargeSequencePageState` | `BsSiluetaBuque` se dibuja sin grúa a propósito |
| muelle | ninguno hoy | `BsBandaMuelle` es la banda, sin ícono propio | |
| escala | ninguno hoy | texto «Escala: X» en `VoyageSummaryCard` y `_FilaDeReciente`; `_buildPortOfCallSection` sin ícono | vecinos: `location_on` es «Destino» y «Puerto de Descarga»; `flag` es la bandera |
| baplie | `upload_file` · `folder_open` | «Cargar archivo BAPLIE» en `_VesselOverviewPageState`; «Seleccionar archivo» en `EmptyStateWidget` | exportar usa `download` con `picture_as_pdf` / `table_view` / `data_object` |
| comparar_baplie | `compare_arrows` | «Comparar con otro BAPLIE…» en `_VesselOverviewPageState`; «Comparar con la llegada» en `_DepartureBapliePageState` | pestañas de la comparación: `south`, `north`, `sync_alt` |
| baplie_salida | `save_alt` | «Generar BAPLIE de salida» en `DepartureBaplieButton`; «Guardar BAPLIE de salida» en `_DepartureBapliePageState` | |
| listado_agencia | `table_view` | «Listado de la agencia» en `_VesselOverviewPageState`; «Elegir listado (.xlsx)» en `_ExportListImportPageState` | `table_view` es también «CSV» en exportar |
| al_dia | `cloud_done_outlined` | `syncStatusIcon` para `SyncState.upToDate` (`sync_status_chip.dart`) → `SyncStatusChip` y `SyncAppBarButton` | otros estados: `cloud_sync_outlined`, `cloud_upload_outlined`, `lock_clock_outlined`, `block`, `warning_amber_outlined`; `cloud_outlined` es «Nube y cuenta» |
| solo_aqui | `phone_android` · `cloud_off_outlined` | `SyncState.localOnly` «Solo este dispositivo» y `SyncState.offline` «Sin conexión» en `syncStatusIcon` | dos estados con glifos distintos; en la barra superior `localOnly` se muestra con `cloud_outlined` |
| oficina | ninguno hoy | el rol es texto («nombre · Oficina») en `_account` de `cloud_page.dart`; `BsEquipo.oficina` (`bs_panel_en_vivo.dart`) es un rótulo | va con `muelle` en el distintivo de rol de la cabecera (10.86); inventario de la rama `master` del 2-nov |

Conceptos del dominio que hoy tienen ícono de Material y no están en el encargo (para que Carlos decida si entran en una segunda tanda):

- Hecho / descargado / cargado: `check_circle_outline` (`BsCelda`, `BsAvisoDeOperacion`, `LoadingCell`, `_LoadCheckPanel`, `BsBanda`), `check_circle` (`dischargeMarkIcon`, `PlanDragCell`) y `check` (la palomita de la celda bajada de noche en `BsCelda`).
- Paso / sigue a bordo: `directions_boat_outlined` (`BsCelda`, `dischargeMarkIcon`); choca con «buque».
- Cancelado / bloqueado: `block` (`BsCelda`, `dischargeMarkIcon`, `LoadingCell`, `_LoadCheckPanel`, `PlanDragCell`, `SyncState.notAuthorized`).
- Revisar / conflicto: `error_outline` (`BsCelda`, `dischargeMarkIcon`, `BsBanda`, pantalla de fallo).
- Aviso genérico: `warning_amber` y variantes (`_LoadCheckPanel`, `LoadingCell`, `voyage_summary_card.dart`, `BsBanda`, `StowageAlertsPage`), `report_outlined` (carga fuera de la geometría).
- Alertas de estiba: `fact_check_outlined`; «Ver posición» con `location_on_outlined`.
- Orden de descarga (la secuencia): `low_priority`.
- Celda reservada: `crop_square` en `ReservedSlotsListView`.
- Lleno: `check_box` («Llenos») e `inventory_2` (contenedor lleno, total de contenedores, `generalPurpose`).
- Intercambio / equivalencia: `swap_horiz` y `help_outline`.
- Pendientes y avance: `table_chart_outlined`, `assignment_outlined`.
- Parámetros del buque: `straighten`; editar perfil: `edit_outlined`; tomas de reefer y niveles: `playlist_add`, `playlist_remove`, `content_paste`, `add`.
- Viaje, bandera, naviera, puerto: `tag`, `flag`, `business`, `location_on`.

Colisiones que conviene decidir antes de integrar: `warning_amber` = peligrosa y aviso; `swap_vert` = re-estiba y pedir cambio; `directions_boat_outlined` = buque y «Paso»; `north` = carga y «Re-estiba: sale»; `table_view` = listado y CSV; `inventory_2` = contenedor genérico, lleno y varios tipos.

Recuento en `lib/` de `origin/sprint-4`: 224 usos de `Icons.` (98 íconos distintos, 34 archivos); 167 de la variante rellena y 57 `_outlined`/`_outline`. Ningún ícono propio hoy (no hay `IconData(` a mano); lo que no es Material se pinta con `CustomPainter`.

## Parientes: lo que se distingue a 16 px

Medido con `design/iconos/fuentes/parejas.py` sobre los SVG rasterizados por resvg: píxeles que cambian de
estado (tinta/no tinta) entre los dos íconos. Regla práctica: por debajo de 8 píxeles o del 6 % a 16 px,
dos íconos se confunden de un vistazo.

{{TABLA_PAREJAS}}

Ninguna pareja de los 32 queda por debajo del umbral (se midieron las 496 combinaciones; las 465 de los 31 de siempre y las 31 de `oficina`). Lo que conviene saber:

- `contenedor_20` / `contenedor_40` / `contenedor_45`: el 20 se distingue por el largo (12 frente a 18) y el 45 por la altura (14 frente a 12) y el ancho a sangre; el largo extra del 45 son 1.3 px a 16 px y no se ve solo.
- `descarga` / `carga`: cambian el sentido de la flecha y el sitio del contenedor, bajo la tapa o sobre el muelle (16 % de píxeles distintos a 16 px). Un espejo exacto, con el contenedor en el mismo sitio, se confundía.
- `al_dia` / `solo_aqui`: es la misma nube cambiando solo el estado, a propósito (9 % / 22 px a 16 px, sobre el umbral).
- `descarga` / `baplie_salida`: uno es vertical con el casco del buque, el otro horizontal con la hoja; no se parecen.
- `oficina` (v3): sus ocho parientes son los de la fila de la propuesta (a) en la página de propuestas: `muelle` (su pareja en el distintivo), `bahia`, `baplie`, `al_dia` y `solo_aqui`, que pedía el encargo, y `contenedor_40`, `plataforma` y `listado_agencia`, añadidos por si la pantalla maciza se parecía a una caja. El más cercano de todos los 31 es `descarga` (58 px · 22.7 % a 16 px), lejos del umbral. Su peso, el área de tinta en píxeles de 16: {{PESOS}}. Una pantalla maciza pesa más que `muelle` aunque se cale; (a) era la más ligera de las tres propuestas y queda en el peso de `baplie`.

## Decisiones

- **Estilo B · Sólido** (decisión 10.18 de Carlos, 22-oct): todo macizo o calado, luz ≥ 2 unidades (1.3 px a 16), esquinas con la proporción de la celda, un solo contorno por ícono. Las dos excepciones de esquina son la píldora de las barras (r = h/2, como la tapa del ícono maestro) y la hoja de los archivos (R_HOJA = R_CELDA × 8 ≈ 1.38: con la proporción del lado menor la hoja se volvía tarjeta).
- **Las cinco correcciones de Carlos** a la muestra: `grua` toma la composición del estilo C en macizo; `reestiba` es una flecha recta de celda a celda; `refrigerado` es el copo sin caja; `peligrosa` es el rombo macizo con el «!» calado; `descarga` y `carga` llevan el buque (la tapa) y el muelle (la barra) en el dibujo.
- **`contenedor_20` es corto a propósito**: 12 de ancho, la única excepción a la regla de «un eje a 16–20». `verificar.py --permitir-pequeno contenedor_20` la declara.
- **Peso parejo**: a 16 px la tinta de cada ícono queda entre ~56 (`contenedor_20`) y ~106 píxeles (`al_dia`, heredado de la muestra); los bordes de las cajas caen en píxel entero a 16, 20 y 24 px (múltiplos de 1.5).
- **Originalidad**: ninguno deriva de Material, Lucide, Phosphor ni Tabler; donde el concepto coincide (nube con check, flecha), la construcción es la del ícono de la app (celda, tapa, casco, hueco, pieza que se mueve).
- **Cómo se decidió**: cada grupo lo dibujaron dos diseñadores con ángulos distintos (silueta y detalle calado), lo juzgaron jueces con lentes de legibilidad a 16 px, sistema y semántica, y Nube fusionó e integró los 31 aplicando los veredictos. En operación no hubo jurado (se cortó por el límite de uso): la base es el candidato de silueta, con el `orden` del otro.
- **El sentido de las flechas** (Carlos, 23-oct): las flechas dicen lo mismo que la app. En `descarga` la flecha baja («Baja», «BAJÓ»): el contenedor sale del buque hacia el muelle; en `carga` sube («Sube»): del muelle al buque. Coincide con `south`/`north`, que la app usa hoy. La tapa arriba y el muelle abajo son lo que evita que parezcan «descargar un archivo».
- **Lo que no se dibujó**: nada de personas, grúas con nombre, buques reales ni cifras; `orden` señala una posición sin número.
- **`oficina`** (Carlos, 2-nov, decisión 10.86): tras la tercera prueba piloto, el rol de la cuenta («Muelle» / «Oficina») se muestra en la cabecera como un distintivo con diseño, porque en un teléfono los dos roles se veían iguales. `muelle` ya existía; `oficina` se eligió entre tres propuestas (a: la pantalla con la rejilla del plano calada sobre su pie; b: la pantalla con el corte de la bahía calado, como `baplie`; c: la pantalla y el teclado, sin plano) vistas junto a `muelle` a 16, 20, 24 y 32 px, sobre claro y oscuro y dentro del distintivo a 16, 18 y 20 px. Ganó la (a): la que mejor sobrevive a 16 px y la más ligera. Va al final de la fuente, en U+E023, para no mover los 35 glifos anteriores.

## Las ilustraciones

| Ilustración | Tamaño | Qué muestra | Para qué pantalla |
|---|---|---|---|
| `inicio` | 640 × 400 | el corte de la bahía (el ícono ampliado: cuatro columnas, celda 11 : 1.9, tapa-píldora, bodega 4 + 4 + 2 con la curva del casco) junto al muelle; la grúa pórtico con el contenedor naranja izado y su celda vacía, punteada | inicio |
| `vacio_recientes` | 320 × 200 | el muelle sin buque, con la grúa en reposo (sin carga, carro recogido) | «todavía no hay viajes» |
| `vacio_busqueda` | 320 × 200 | una fila de celdas de cubierta sobre la tapa, con un hueco punteado | «ningún contenedor coincide» |
| `sin_conexion` | 320 × 200 | el buque de perfil, proa a la izquierda, con la nube en pausa | «trabajando solo en este equipo» |
| `descarga_completa` | 320 × 200 | la bahía vacía (celdas punteadas), la tapa cerrada y el check en hecho | «descarga completa» |
| `sin_alertas` | 320 × 200 | la tapa de escotilla con el check en hecho | «sin posibles incumplimientos» |

Las seis salen de la misma plantilla (`design/ilustraciones/fuentes/plantilla.py`: muelle, grúa, buque en corte, celda, tapa, perfil, nube, check y agua), con las mismas proporciones de celda y grosores de línea.

Reglas que cumplen las seis: línea de plano técnico con rellenos planos de la paleta; sin degradados, sin
texto, sin personas, sin buques ni marcas reales; la proa a la izquierda; trazos a 3:1 o más contra el
fondo en claro y en oscuro (medido por `verificar_ilus.py`); el naranja solo en el contenedor izado de
`inicio`. La animación de espera no va en el paquete: la app la anima en código desde la geometría del ícono.

### El JSON reproduce el SVG

Cada JSON se vuelve a pintar como lo haría la app y se compara, píxel a píxel, con el SVG del mismo tema
(diferencias ≥ 32 de 255 en algún canal; el Δ máximo viene de los arcos convertidos en curvas).

{{TABLA_JSON}}

## La fuente coincide con los SVG

Cada glifo de la TTF se comprueba a 16 y 24 px de dos maneras: el contorno TrueType (cuadrático y
redondeado a la unidad de fuente) vuelto a SVG y rasterizado por resvg frente al SVG original; y el glifo
dibujado por FreeType sin hinting (lo más parecido a Skia, el motor de Flutter) frente al SVG. Se cuentan
los píxeles que cambian de estado y la diferencia media de alfa (0–255). Coincide si el contorno tiene
≤ 4 píxeles con |Δ| ≥ 96 y Δ medio ≤ 2 (resvg cuantiza la cobertura en pasos de 64 y un borde que cae justo
en un subpíxel salta un paso sin que cambie la forma), y FreeType cambia ≤ 4 % de los píxeles o tiene Δ medio ≤ 12 (los bordes
que caen a medio píxel parpadean en el umbral de 128 sin que cambie la forma). `comprobacion-fuente.png` lo muestra.

{{TABLA_FUENTE}}

### Y con Skia, el motor de Flutter

`comprobacion-skia.md` (y `.png`) es la misma comprobación hecha con Chromium por Playwright: cada glifo como texto de la fuente y el mismo SVG en línea, los dos pintados por Skia, frente al SVG de resvg. Es la mejor aproximación disponible fuera de Flutter a lo que verá la app.

{{SKIA_TABLA}}

## Cómo regenerar y verificar

Desde la raíz del repositorio:

```
python -m pip install resvg-py==0.5.0 Pillow fonttools skia-pathops freetype-py
python design/iconos/generar.py              # escribe todo y verifica
python design/iconos/generar.py --verificar  # regenera en una carpeta temporal y compara byte a byte
```

`generar.py` escribe los SVG, la fuente, `codigos.json`, los JSON, las vistas previas, la comprobación de
la fuente y este LEEME (desde `fuentes/LEEME.plantilla.md`). Dos corridas dan archivos idénticos (Python
3.13, Pillow 12.3, resvg-py 0.5.0, fontTools 4.67, skia-pathops 0.8, freetype-py 2.13); con otras versiones
los PNG pueden comprimirse distinto sin cambiar un píxel. `comprobacion-skia.md` lo produce aparte
`fuentes/comprobar_skia.py`, que necesita Node con Playwright y Chromium; no hace falta para regenerar.

El v3 se generó y verificó con Python 3.13.18, Pillow 12.3.0, resvg-py 0.5.0, fontTools 4.68.0, skia-pathops 0.9.2 y
freetype-py 2.5.1; con ellas `generar.py --verificar` sobre el v2 también daba 84 de 84. Salida de `generar.py --verificar`
sobre el v3:

```
{{VERIFICAR}}
```

## Frente al v2

{{TABLA_V2}}

## Archivos

{{TABLA_SHA}}

`design/iconos/LEEME.md` es este archivo; no lleva su propio SHA-256.

## Para versionar

Carlos ejecuta Git. Un `git add` por ruta, sin comodines:

{{GIT}}

No cambian `pubspec.lock` ni `lib/`; `pubspec.yaml` solo cuando Timonel declare la fuente.

— Nube
