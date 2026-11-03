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
   /// Iconos del dominio de BayStream (fuente BayStreamIconos, area de uso privado).
   /// Generado por design/iconos/generar.py a partir de design/iconos/codigos.json; no editar a mano.
   import 'package:flutter/widgets.dart';

   abstract final class BsIconos {
     static const String familia = 'BayStreamIconos';

     static const IconData contenedor20 = IconData(0xE000, fontFamily: familia);
     static const IconData contenedor40 = IconData(0xE001, fontFamily: familia);
     static const IconData contenedor45 = IconData(0xE002, fontFamily: familia);
     static const IconData vacio = IconData(0xE003, fontFamily: familia);
     static const IconData refrigerado = IconData(0xE004, fontFamily: familia);
     static const IconData peligrosa = IconData(0xE005, fontFamily: familia);
     static const IconData fueraDeMedida = IconData(0xE006, fontFamily: familia);
     static const IconData tanque = IconData(0xE007, fontFamily: familia);
     static const IconData plataforma = IconData(0xE008, fontFamily: familia);
     static const IconData techoAbierto = IconData(0xE009, fontFamily: familia);
     static const IconData buque = IconData(0xE00A, fontFamily: familia);
     static const IconData bahia = IconData(0xE00B, fontFamily: familia);
     static const IconData tapaEscotilla = IconData(0xE00C, fontFamily: familia);
     static const IconData pesoPila = IconData(0xE00D, fontFamily: familia);
     static const IconData limiteApilamiento = IconData(0xE00E, fontFamily: familia);
     static const IconData vgm = IconData(0xE00F, fontFamily: familia);
     static const IconData segregacion = IconData(0xE010, fontFamily: familia);
     static const IconData descarga = IconData(0xE011, fontFamily: familia);
     static const IconData carga = IconData(0xE012, fontFamily: familia);
     static const IconData reestiba = IconData(0xE013, fontFamily: familia);
     static const IconData pedirCambio = IconData(0xE014, fontFamily: familia);
     static const IconData orden = IconData(0xE015, fontFamily: familia);
     static const IconData grua = IconData(0xE016, fontFamily: familia);
     static const IconData muelle = IconData(0xE017, fontFamily: familia);
     static const IconData escala = IconData(0xE018, fontFamily: familia);
     static const IconData baplie = IconData(0xE019, fontFamily: familia);
     static const IconData compararBaplie = IconData(0xE01A, fontFamily: familia);
     static const IconData baplieSalida = IconData(0xE01B, fontFamily: familia);
     static const IconData listadoAgencia = IconData(0xE01C, fontFamily: familia);
     static const IconData alDia = IconData(0xE01D, fontFamily: familia);
     static const IconData soloAqui = IconData(0xE01E, fontFamily: familia);
     static const IconData insigniaRefrigerado = IconData(0xE01F, fontFamily: familia);
     static const IconData insigniaPeligrosa = IconData(0xE020, fontFamily: familia);
     static const IconData insigniaFueraDeMedida = IconData(0xE021, fontFamily: familia);
     static const IconData insigniaVacio = IconData(0xE022, fontFamily: familia);
     static const IconData oficina = IconData(0xE023, fontFamily: familia);
   }
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

| Glifo | Código |
|---|---|
| `contenedor_20` | U+E000 |
| `contenedor_40` | U+E001 |
| `contenedor_45` | U+E002 |
| `vacio` | U+E003 |
| `refrigerado` | U+E004 |
| `peligrosa` | U+E005 |
| `fuera_de_medida` | U+E006 |
| `tanque` | U+E007 |
| `plataforma` | U+E008 |
| `techo_abierto` | U+E009 |
| `buque` | U+E00A |
| `bahia` | U+E00B |
| `tapa_escotilla` | U+E00C |
| `peso_pila` | U+E00D |
| `limite_apilamiento` | U+E00E |
| `vgm` | U+E00F |
| `segregacion` | U+E010 |
| `descarga` | U+E011 |
| `carga` | U+E012 |
| `reestiba` | U+E013 |
| `pedir_cambio` | U+E014 |
| `orden` | U+E015 |
| `grua` | U+E016 |
| `muelle` | U+E017 |
| `escala` | U+E018 |
| `baplie` | U+E019 |
| `comparar_baplie` | U+E01A |
| `baplie_salida` | U+E01B |
| `listado_agencia` | U+E01C |
| `al_dia` | U+E01D |
| `solo_aqui` | U+E01E |
| `insignia_refrigerado` | U+E01F |
| `insignia_peligrosa` | U+E020 |
| `insignia_fuera_de_medida` | U+E021 |
| `insignia_vacio` | U+E022 |
| `oficina` | U+E023 |

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

| Pareja | 16 px: píxeles que cambian de estado · % | 20 px | Se distinguen a 16 px |
|---|---|---|---|
| `contenedor_20` · `contenedor_40` | 40 · 15.6 % | 77 · 19.2 % | sí |
| `contenedor_40` · `contenedor_45` | 46 · 18.0 % | 51 · 12.8 % | sí |
| `contenedor_20` · `contenedor_45` | 86 · 33.6 % | 108 · 27.0 % | sí |
| `vacio` · `contenedor_40` | 16 · 6.2 % | 22 · 5.5 % | sí |
| `refrigerado` · `contenedor_40` | 64 · 25.0 % | 101 · 25.2 % | sí |
| `tanque` · `contenedor_40` | 76 · 29.7 % | 99 · 24.8 % | sí |
| `plataforma` · `techo_abierto` | 24 · 9.4 % | 37 · 9.2 % | sí |
| `fuera_de_medida` · `contenedor_40` | 28 · 10.9 % | 36 · 9.0 % | sí |
| `bahia` · `tapa_escotilla` | 78 · 30.5 % | 107 · 26.8 % | sí |
| `peso_pila` · `limite_apilamiento` | 58 · 22.7 % | 60 · 15.0 % | sí |
| `peso_pila` · `vgm` | 63 · 24.6 % | 96 · 24.0 % | sí |
| `limite_apilamiento` · `vgm` | 95 · 37.1 % | 118 · 29.5 % | sí |
| `bahia` · `buque` | 87 · 34.0 % | 110 · 27.5 % | sí |
| `descarga` · `carga` | 40 · 15.6 % | 50 · 12.5 % | sí |
| `descarga` · `reestiba` | 90 · 35.2 % | 134 · 33.5 % | sí |
| `carga` · `reestiba` | 90 · 35.2 % | 130 · 32.5 % | sí |
| `descarga` · `baplie_salida` | 113 · 44.1 % | 160 · 40.0 % | sí |
| `carga` · `baplie` | 103 · 40.2 % | 129 · 32.2 % | sí |
| `pedir_cambio` · `reestiba` | 70 · 27.3 % | 87 · 21.8 % | sí |
| `grua` · `muelle` | 83 · 32.4 % | 116 · 29.0 % | sí |
| `baplie` · `comparar_baplie` | 83 · 32.4 % | 141 · 35.2 % | sí |
| `baplie` · `baplie_salida` | 66 · 25.8 % | 115 · 28.8 % | sí |
| `comparar_baplie` · `baplie_salida` | 67 · 26.2 % | 106 · 26.5 % | sí |
| `baplie` · `listado_agencia` | 70 · 27.3 % | 129 · 32.2 % | sí |
| `al_dia` · `solo_aqui` | 22 · 8.6 % | 30 · 7.5 % | sí |
| `oficina` · `muelle` | 92 · 35.9 % | 144 · 36.0 % | sí |
| `oficina` · `bahia` | 110 · 43.0 % | 165 · 41.2 % | sí |
| `oficina` · `baplie` | 93 · 36.3 % | 135 · 33.8 % | sí |
| `oficina` · `al_dia` | 119 · 46.5 % | 142 · 35.5 % | sí |
| `oficina` · `solo_aqui` | 121 · 47.3 % | 140 · 35.0 % | sí |
| `oficina` · `contenedor_40` | 90 · 35.2 % | 121 · 30.2 % | sí |
| `oficina` · `plataforma` | 102 · 39.8 % | 138 · 34.5 % | sí |
| `oficina` · `listado_agencia` | 109 · 42.6 % | 146 · 36.5 % | sí |

Ninguna pareja de los 32 queda por debajo del umbral (se midieron las 496 combinaciones; las 465 de los 31 de siempre y las 31 de `oficina`). Lo que conviene saber:

- `contenedor_20` / `contenedor_40` / `contenedor_45`: el 20 se distingue por el largo (12 frente a 18) y el 45 por la altura (14 frente a 12) y el ancho a sangre; el largo extra del 45 son 1.3 px a 16 px y no se ve solo.
- `descarga` / `carga`: cambian el sentido de la flecha y el sitio del contenedor, bajo la tapa o sobre el muelle (16 % de píxeles distintos a 16 px). Un espejo exacto, con el contenedor en el mismo sitio, se confundía.
- `al_dia` / `solo_aqui`: es la misma nube cambiando solo el estado, a propósito (9 % / 22 px a 16 px, sobre el umbral).
- `descarga` / `baplie_salida`: uno es vertical con el casco del buque, el otro horizontal con la hoja; no se parecen.
- `oficina` (v3): sus ocho parientes son los de la fila de la propuesta (a) en la página de propuestas: `muelle` (su pareja en el distintivo), `bahia`, `baplie`, `al_dia` y `solo_aqui`, que pedía el encargo, y `contenedor_40`, `plataforma` y `listado_agencia`, añadidos por si la pantalla maciza se parecía a una caja. El más cercano de todos los 31 es `descarga` (58 px · 22.7 % a 16 px), lejos del umbral. Su peso, el área de tinta en píxeles de 16: `oficina` 92.4, `muelle` 75.0, `baplie` 93.0, `bahia` 97.1, `al_dia` 106.5. Una pantalla maciza pesa más que `muelle` aunque se cale; (a) era la más ligera de las tres propuestas y queda en el peso de `baplie`.

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

| Ilustración | Claro: píxeles distintos (de los totales) · Δ máx | Oscuro |
|---|---|---|
| `inicio` | 0 de 256 000 · 14 | 0 de 256 000 · 0 |
| `vacio_recientes` | 0 de 64 000 · 0 | 0 de 64 000 · 0 |
| `vacio_busqueda` | 0 de 64 000 · 29 | 0 de 64 000 · 31 |
| `sin_conexion` | 0 de 64 000 · 14 | 0 de 64 000 · 14 |
| `descarga_completa` | 0 de 64 000 · 30 | 0 de 64 000 · 31 |
| `sin_alertas` | 0 de 64 000 · 11 | 0 de 64 000 · 10 |

## La fuente coincide con los SVG

Cada glifo de la TTF se comprueba a 16 y 24 px de dos maneras: el contorno TrueType (cuadrático y
redondeado a la unidad de fuente) vuelto a SVG y rasterizado por resvg frente al SVG original; y el glifo
dibujado por FreeType sin hinting (lo más parecido a Skia, el motor de Flutter) frente al SVG. Se cuentan
los píxeles que cambian de estado y la diferencia media de alfa (0–255). Coincide si el contorno tiene
≤ 4 píxeles con |Δ| ≥ 96 y Δ medio ≤ 2 (resvg cuantiza la cobertura en pasos de 64 y un borde que cae justo
en un subpíxel salta un paso sin que cambie la forma), y FreeType cambia ≤ 4 % de los píxeles o tiene Δ medio ≤ 12 (los bordes
que caen a medio píxel parpadean en el umbral de 128 sin que cambie la forma). `comprobacion-fuente.png` lo muestra.

| Glifo | Código | Contorno 16 px (Δ medio · cambian) | FreeType 16 px (cambian · %) | Contorno 24 px | FreeType 24 px | Coincide |
|---|---|---|---|---|---|---|
| `contenedor_20` | U+E000 | 0.0 · 0 | 0 · 0.0 % | 0.0 · 0 | 0 · 0.0 % | sí |
| `contenedor_40` | U+E001 | 0.25 · 0 | 8 · 3.1 % | 1.22 · 0 | 0 · 0.0 % | sí |
| `contenedor_45` | U+E002 | 0.75 · 2 | 2 · 0.8 % | 0.0 · 0 | 0 · 0.0 % | sí |
| `vacio` | U+E003 | 0.5 · 0 | 0 · 0.0 % | 0.0 · 0 | 0 · 0.0 % | sí |
| `refrigerado` | U+E004 | 1.31 · 4 | 0 · 0.0 % | 0.17 · 1 | 1 · 0.2 % | sí |
| `peligrosa` | U+E005 | 0.19 · 0 | 0 · 0.0 % | 0.17 · 2 | 4 · 0.7 % | sí |
| `fuera_de_medida` | U+E006 | 0.75 · 0 | 0 · 0.0 % | 0.0 · 0 | 0 · 0.0 % | sí |
| `tanque` | U+E007 | 0.06 · 0 | 0 · 0.0 % | 0.72 · 6 | 2 · 0.3 % | sí |
| `plataforma` | U+E008 | 0.0 · 0 | 0 · 0.0 % | 0.0 · 0 | 0 · 0.0 % | sí |
| `techo_abierto` | U+E009 | 0.25 · 0 | 4 · 1.6 % | 0.56 · 0 | 0 · 0.0 % | sí |
| `buque` | U+E00A | 0.38 · 0 | 1 · 0.4 % | 0.0 · 0 | 43 · 7.5 % | sí |
| `bahia` | U+E00B | 0.19 · 0 | 8 · 3.1 % | 0.33 · 0 | 14 · 2.4 % | sí |
| `tapa_escotilla` | U+E00C | 0.31 · 0 | 6 · 2.3 % | 0.0 · 0 | 16 · 2.8 % | sí |
| `peso_pila` | U+E00D | 0.38 · 0 | 2 · 0.8 % | 0.03 · 1 | 34 · 5.9 % | sí |
| `limite_apilamiento` | U+E00E | 0.25 · 0 | 2 · 0.8 % | 0.06 · 0 | 8 · 1.4 % | sí |
| `vgm` | U+E00F | 0.31 · 0 | 3 · 1.2 % | 0.11 · 1 | 20 · 3.5 % | sí |
| `segregacion` | U+E010 | 0.49 · 2 | 11 · 4.3 % | 0.08 · 0 | 4 · 0.7 % | sí |
| `descarga` | U+E011 | 0.25 · 0 | 4 · 1.6 % | 0.27 · 0 | 30 · 5.2 % | sí |
| `carga` | U+E012 | 0.44 · 0 | 4 · 1.6 % | 0.3 · 0 | 28 · 4.9 % | sí |
| `reestiba` | U+E013 | 0.49 · 0 | 1 · 0.4 % | 0.0 · 0 | 11 · 1.9 % | sí |
| `pedir_cambio` | U+E014 | 0.31 · 0 | 2 · 0.8 % | 0.44 · 1 | 0 · 0.0 % | sí |
| `orden` | U+E015 | 0.62 · 0 | 2 · 0.8 % | 0.28 · 0 | 16 · 2.8 % | sí |
| `grua` | U+E016 | 0.31 · 0 | 4 · 1.6 % | 0.11 · 0 | 9 · 1.6 % | sí |
| `muelle` | U+E017 | 0.25 · 0 | 2 · 0.8 % | 0.17 · 0 | 20 · 3.5 % | sí |
| `escala` | U+E018 | 0.38 · 0 | 2 · 0.8 % | 0.56 · 0 | 0 · 0.0 % | sí |
| `baplie` | U+E019 | 0.0 · 0 | 2 · 0.8 % | 0.03 · 0 | 4 · 0.7 % | sí |
| `comparar_baplie` | U+E01A | 0.37 · 2 | 4 · 1.6 % | 0.22 · 2 | 13 · 2.3 % | sí |
| `baplie_salida` | U+E01B | 0.0 · 0 | 0 · 0.0 % | 0.08 · 1 | 6 · 1.0 % | sí |
| `listado_agencia` | U+E01C | 0.0 · 0 | 2 · 0.8 % | 0.0 · 0 | 17 · 3.0 % | sí |
| `al_dia` | U+E01D | 0.44 · 1 | 3 · 1.2 % | 0.14 · 0 | 0 · 0.0 % | sí |
| `solo_aqui` | U+E01E | 0.44 · 1 | 3 · 1.2 % | 0.14 · 0 | 4 · 0.7 % | sí |
| `insignia_refrigerado` | U+E01F | 0.0 · 0 | 6 · 2.3 % | 0.42 · 0 | 2 · 0.3 % | sí |
| `insignia_peligrosa` | U+E020 | 0.31 · 0 | 0 · 0.0 % | 0.39 · 2 | 10 · 1.7 % | sí |
| `insignia_fuera_de_medida` | U+E021 | 0.19 · 0 | 2 · 0.8 % | 0.14 · 0 | 0 · 0.0 % | sí |
| `insignia_vacio` | U+E022 | 0.5 · 0 | 0 · 0.0 % | 0.0 · 0 | 0 · 0.0 % | sí |
| `oficina` | U+E023 | 0.37 · 0 | 3 · 1.2 % | 0.03 · 0 | 14 · 2.4 % | sí |

### Y con Skia, el motor de Flutter

`comprobacion-skia.md` (y `.png`) es la misma comprobación hecha con Chromium por Playwright: cada glifo como texto de la fuente y el mismo SVG en línea, los dos pintados por Skia, frente al SVG de resvg. Es la mejor aproximación disponible fuera de Flutter a lo que verá la app.

| Glifo | 16 px: texto vs SVG en Chromium (cambian · % · Δ medio) | 16 px: texto vs resvg | 24 px: texto vs SVG en Chromium | 24 px: texto vs resvg | Coincide |
|---|---|---|---|---|---|
| `contenedor_20` | 3 · 1.2 % · 0.55 | 3 · 1.2 % · 0.89 | 0 · 0.0 % · 0.22 | 0 · 0.0 % · 0.88 | sí |
| `contenedor_40` | 3 · 1.2 % · 0.65 | 11 · 4.3 % · 1.92 | 0 · 0.0 % · 0.41 | 0 · 0.0 % · 1.92 | sí |
| `contenedor_45` | 0 · 0.0 % · 0.89 | 2 · 0.8 % · 2.31 | 0 · 0.0 % · 0.66 | 0 · 0.0 % · 2.72 | sí |
| `vacio` | 3 · 1.2 % · 0.62 | 3 · 1.2 % · 1.03 | 0 · 0.0 % · 0.1 | 0 · 0.0 % · 0.32 | sí |
| `refrigerado` | 3 · 1.2 % · 1.15 | 6 · 2.3 % · 4.0 | 0 · 0.0 % · 1.5 | 0 · 0.0 % · 2.08 | sí |
| `peligrosa` | 2 · 0.8 % · 1.32 | 2 · 0.8 % · 1.66 | 15 · 2.6 % · 0.85 | 12 · 2.1 % · 1.37 | sí |
| `fuera_de_medida` | 3 · 1.2 % · 0.7 | 3 · 1.2 % · 1.2 | 0 · 0.0 % · 0.15 | 0 · 0.0 % · 0.39 | sí |
| `tanque` | 0 · 0.0 % · 1.48 | 0 · 0.0 % · 2.67 | 36 · 6.2 % · 0.93 | 30 · 5.2 % · 0.75 | sí |
| `plataforma` | 0 · 0.0 % · 0.05 | 0 · 0.0 % · 0.07 | 0 · 0.0 % · 0.06 | 0 · 0.0 % · 0.17 | sí |
| `techo_abierto` | 3 · 1.2 % · 0.64 | 7 · 2.7 % · 1.28 | 0 · 0.0 % · 0.33 | 0 · 0.0 % · 1.03 | sí |
| `buque` | 2 · 0.8 % · 0.77 | 1 · 0.4 % · 3.33 | 58 · 10.1 % · 0.8 | 26 · 4.5 % · 0.99 | sí |
| `bahia` | 3 · 1.2 % · 1.73 | 10 · 3.9 % · 4.45 | 37 · 6.4 % · 1.18 | 39 · 6.8 % · 1.23 | sí |
| `tapa_escotilla` | 5 · 2.0 % · 0.94 | 8 · 3.1 % · 4.04 | 29 · 5.0 % · 1.11 | 11 · 1.9 % · 1.02 | sí |
| `peso_pila` | 0 · 0.0 % · 1.06 | 2 · 0.8 % · 2.07 | 50 · 8.7 % · 0.6 | 17 · 3.0 % · 0.63 | sí |
| `limite_apilamiento` | 0 · 0.0 % · 0.85 | 2 · 0.8 % · 2.07 | 29 · 5.0 % · 0.54 | 20 · 3.5 % · 0.53 | sí |
| `vgm` | 1 · 0.4 % · 1.78 | 4 · 1.6 % · 2.61 | 25 · 4.3 % · 0.85 | 10 · 1.7 % · 1.52 | sí |
| `segregacion` | 0 · 0.0 % · 1.21 | 12 · 4.7 % · 4.54 | 1 · 0.2 % · 0.94 | 11 · 1.9 % · 2.41 | sí |
| `descarga` | 2 · 0.8 % · 1.21 | 2 · 0.8 % · 1.21 | 60 · 10.4 % · 0.64 | 30 · 5.2 % · 0.69 | sí |
| `carga` | 2 · 0.8 % · 1.2 | 2 · 0.8 % · 1.3 | 60 · 10.4 % · 0.68 | 32 · 5.6 % · 0.72 | sí |
| `reestiba` | 1 · 0.4 % · 1.23 | 0 · 0.0 % · 3.13 | 27 · 4.7 % · 1.46 | 14 · 2.4 % · 1.4 | sí |
| `pedir_cambio` | 0 · 0.0 % · 1.22 | 1 · 0.4 % · 1.52 | 3 · 0.5 % · 1.1 | 1 · 0.2 % · 1.12 | sí |
| `orden` | 1 · 0.4 % · 1.14 | 3 · 1.2 % · 2.22 | 27 · 4.7 % · 0.8 | 16 · 2.8 % · 0.95 | sí |
| `grua` | 2 · 0.8 % · 1.06 | 2 · 0.8 % · 3.38 | 39 · 6.8 % · 0.72 | 38 · 6.6 % · 1.14 | sí |
| `muelle` | 2 · 0.8 % · 1.33 | 0 · 0.0 % · 2.72 | 34 · 5.9 % · 0.96 | 20 · 3.5 % · 1.07 | sí |
| `escala` | 3 · 1.2 % · 2.04 | 4 · 1.6 % · 2.79 | 14 · 2.4 % · 2.93 | 12 · 2.1 % · 2.32 | sí |
| `baplie` | 1 · 0.4 % · 0.42 | 3 · 1.2 % · 0.68 | 41 · 7.1 % · 0.6 | 45 · 7.8 % · 1.1 | sí |
| `comparar_baplie` | 1 · 0.4 % · 0.73 | 4 · 1.6 % · 0.73 | 54 · 9.4 % · 0.88 | 53 · 9.2 % · 1.31 | sí |
| `baplie_salida` | 0 · 0.0 % · 0.53 | 0 · 0.0 % · 1.19 | 11 · 1.9 % · 0.45 | 13 · 2.3 % · 0.95 | sí |
| `listado_agencia` | 1 · 0.4 % · 0.46 | 3 · 1.2 % · 0.61 | 38 · 6.6 % · 0.6 | 26 · 4.5 % · 1.04 | sí |
| `al_dia` | 2 · 0.8 % · 1.91 | 3 · 1.2 % · 2.55 | 2 · 0.3 % · 1.04 | 4 · 0.7 % · 1.52 | sí |
| `solo_aqui` | 2 · 0.8 % · 1.42 | 1 · 0.4 % · 1.59 | 30 · 5.2 % · 0.83 | 27 · 4.7 % · 1.01 | sí |
| `insignia_refrigerado` | 4 · 1.6 % · 1.52 | 8 · 3.1 % · 2.54 | 0 · 0.0 % · 1.04 | 2 · 0.3 % · 1.77 | sí |
| `insignia_peligrosa` | 2 · 0.8 % · 1.96 | 2 · 0.8 % · 3.03 | 13 · 2.3 % · 0.89 | 6 · 1.0 % · 1.48 | sí |
| `insignia_fuera_de_medida` | 0 · 0.0 % · 1.55 | 2 · 0.8 % · 3.02 | 2 · 0.3 % · 0.51 | 4 · 0.7 % · 0.94 | sí |
| `insignia_vacio` | 0 · 0.0 % · 0.59 | 0 · 0.0 % · 1.8 | 0 · 0.0 % · 0.23 | 0 · 0.0 % · 0.43 | sí |
| `oficina` | 4 · 1.6 % · 1.49 | 0 · 0.0 % · 2.5 | 36 · 6.2 % · 0.61 | 30 · 5.2 % · 0.89 | sí |

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
85 de 85 comprobaciones correctas.
```

## Frente al v2

73 archivos con la misma huella que en el v2, 11 cambian, 1 nuevo (`design/iconos/LEEME.md` cambia y no lleva huella).

Cambian: `assets/fonts/bs_iconos/BayStreamIconos.ttf`, `design/iconos/codigos.json`, `design/iconos/comprobacion-fuente.png`, `design/iconos/comprobacion-skia.md`, `design/iconos/comprobacion-skia.png`, `design/iconos/fuentes/LEEME.plantilla.md`, `design/iconos/fuentes/comprobar_skia.py`, `design/iconos/fuentes/fuente.py`, `design/iconos/fuentes/iconos.py`, `design/iconos/generar.py`, `design/iconos/vista-previa.png`.

Nuevo: `design/iconos/svg/oficina.svg`.

| Archivo igual al v2 | SHA-256 (la misma en v2 y v3) |
|---|---|
| `design/iconos/conceptos.png` | `2f3d0e3037ef8950cf939227bf60ab75509ffbb01aad90c860f8d9b61862db2d` |
| `design/iconos/fuentes/ayudantes.py` | `b271e2814a92b030568ffc92f826be2e67d48601d7b7f2dbf87ca1650d73bb6d` |
| `design/iconos/fuentes/comprobar_skia.js` | `4feb12127319affa62e7543e67911cc2da61e19648110a3febddcd06ca05e656` |
| `design/iconos/fuentes/dsl.py` | `dd1a13a0ee0f345f4b46bbc6598fc53b9867f95c3fd8996f577718b71f838cfb` |
| `design/iconos/fuentes/exportar_json.py` | `bc8ce5388a459901b4a9859f500736e67f984d39a42975a46353bafcbc64880a` |
| `design/iconos/fuentes/geom.py` | `b6d905a78b12d288bf6c398c12733d96329d814a8336452c2d136a93cfaa7529` |
| `design/iconos/fuentes/insignias.py` | `6810f972d0a7fc7848e04b217be13f44800ccb770b80906136a7beab25095dc7` |
| `design/iconos/fuentes/parejas.py` | `8da277c067e558a12872e9422bba1bcb5a9c1f6cbdc709bd165f6e9564f6ea5a` |
| `design/iconos/fuentes/verificar_fuente.py` | `a69b7f7826ab3b81176735dfac6d78da74114133068185a15f9a6cc4ec9ade20` |
| `design/iconos/fuentes/vista_previa.py` | `affb38a08196c08b3ec8abe09fda437891675f38f73529af862cb4eaeb9d9e23` |
| `design/iconos/svg/al_dia.svg` | `22a9637123c9670546b500400cd24a811122dc7d16815f0c498b858419fc01b6` |
| `design/iconos/svg/bahia.svg` | `9a8b6e6b9954ab46546157cb6ad84db782da00afbf16143ddba1714c04216808` |
| `design/iconos/svg/baplie.svg` | `0513e11727c0469bab491d5700727c1ef3c3056bd3e26866cc96ae668b6c40ed` |
| `design/iconos/svg/baplie_salida.svg` | `d3ffdd439fea0a6c42b54c8e4a3216bda6a3fb815ddded7867bddb3a19319b0d` |
| `design/iconos/svg/buque.svg` | `fc82753b5c888a4417805c6657596597d84424480a1e8e929ee54eaf2ce3ae2b` |
| `design/iconos/svg/carga.svg` | `a6ec8a53684ce04b13d6332cd195c5444f7b751714282d4c4fa6fa79e8dfe066` |
| `design/iconos/svg/comparar_baplie.svg` | `b14da614e0fcd2cabe691d4aa0db0bd98e4d37df625b6eb631946e8d1f3671e4` |
| `design/iconos/svg/contenedor_20.svg` | `d28640992e28539b88ae5318ff6a6d5c82b17473153eaf627b20591ff19c9a0a` |
| `design/iconos/svg/contenedor_40.svg` | `c19a4adf1456b9d515a6bd4ec8a22e9103e2ad3c37879430195092b4bff3b183` |
| `design/iconos/svg/contenedor_45.svg` | `93e301b450c33e83e53abbc55a58850dcb81168fb7cc221e2620a91bba9dcdfe` |
| `design/iconos/svg/descarga.svg` | `b5d13ffd7169ac499f462ba0dc7c8bd5cbaa02d2d07e0eb7a83164970ffa7fc4` |
| `design/iconos/svg/escala.svg` | `a00c79293eeee80e7bd653b0fcf2d0259f4a95f313829d5a8370212ebd8421c6` |
| `design/iconos/svg/fuera_de_medida.svg` | `00a5b867402285a8a7e346e280332cda6c8e8329cf9e2d198858ac329772e244` |
| `design/iconos/svg/grua.svg` | `b23897b646de4f1feade75d1cb0dd8037ee06d0685db5fc2a91c4fd9497c19b7` |
| `design/iconos/svg/limite_apilamiento.svg` | `04d5afc4bc73d253c01c4c04e4978f4db9b1c7125f57643d6219d0db8be0c5f2` |
| `design/iconos/svg/listado_agencia.svg` | `312e5943ee8cfa13cf70a0dc0dd551c3807391dfaa847e6e838d03eeca38ffe7` |
| `design/iconos/svg/muelle.svg` | `06239e59338282b26a571a4d1bcc727d003edeca9849c5739ab0cdab2340e701` |
| `design/iconos/svg/orden.svg` | `1870f55e7a9cfd764954b45075a24f0ab778b45f96e7ffcda36a017d930ac6c1` |
| `design/iconos/svg/pedir_cambio.svg` | `76e47e7a2128ceb2a63229587431cc90065ab81184b32d35ef1cb1d37ef0a8be` |
| `design/iconos/svg/peligrosa.svg` | `ab0fb8f2afa666e04ef75f2f77ed91b611531d27e515fa0fcd4944d931f7c551` |
| `design/iconos/svg/peso_pila.svg` | `8f68a719b52c006e5faa564960c58d2b94df5b01bb9e32d3ef860ad888e0efe2` |
| `design/iconos/svg/plataforma.svg` | `a74d32d27ab10d4062446cf72d35c6bb8dd97ae607967c86cb104d99537452c1` |
| `design/iconos/svg/reestiba.svg` | `d860291d21c2d9d9165d108b1722f983a8210fb02956703f14460c0aa9dabb8c` |
| `design/iconos/svg/refrigerado.svg` | `a166d93a1528dfbb6fef82eef67277cead31293832ef1b53f74a8f66e7def3b6` |
| `design/iconos/svg/segregacion.svg` | `c0f7f1de4f56899bcee3cab099ba5310df720dcd9803f0c551e2b0d45356a0fd` |
| `design/iconos/svg/solo_aqui.svg` | `dc6d4ae7f02103523c5d2a2445dc05ebef998f15d21de1af4dd8ed288a6920d4` |
| `design/iconos/svg/tanque.svg` | `78e1af21aa0fdc9a2e357d19e3d376ac9f483baf45087e0cb722924ed41a18e4` |
| `design/iconos/svg/tapa_escotilla.svg` | `c73200aa3a5e731012dc688e4673d125161d859164211d9c2ab2035ffd6697e0` |
| `design/iconos/svg/techo_abierto.svg` | `2d38c6f38ead85195757d3834bb721534d7b8794a8b4cdcb4bb856939361ad9c` |
| `design/iconos/svg/vacio.svg` | `49caf59f172edb0afbf74ead8543f804025fb613c5c5a2e742ddcf9bfb8deb86` |
| `design/iconos/svg/vgm.svg` | `9090a24771b435546d90b23420e464ba1052a25f46fa0f329805e3a23b989612` |
| `design/iconos/svg_insignias/fuera_de_medida.svg` | `c7a3c7541fb3ded71b8fac61c7ee144320483b2e74a1e8cdbeaaab34b9e8d338` |
| `design/iconos/svg_insignias/peligrosa.svg` | `40a4e73433cdc4b169eaf6e856c7630b1ede5b053d3fb6d6fa1ec9be031fa195` |
| `design/iconos/svg_insignias/refrigerado.svg` | `b4507f95c1a3375803b28ebf70cf2009b511bb8ff16e9119e1e20caf10ed7f0c` |
| `design/iconos/svg_insignias/vacio.svg` | `9bd8fa12915aee865a02721aa6478eb50cf1e7b7bea65d6228fbfbd3e1c3ee63` |
| `design/ilustraciones/descarga_completa.json` | `fd986e230704e8961ea72881abaa9b5f1b3b54cc1d1f30d975571ebe010d1c84` |
| `design/ilustraciones/descarga_completa_claro.svg` | `fdf6b176c0c65a4728444334f6cec50d5b806c401e3541b2f4c2f7e36c208156` |
| `design/ilustraciones/descarga_completa_oscuro.svg` | `f0f1c8242ad9dc6d3acffcd0e34cddb9df98220e44a5f0239b4f3642d8080989` |
| `design/ilustraciones/fuentes/descarga_completa.py` | `9955a2c0901ee6368aa3a5e3fc1add6abfe4385c3a98adbd9d125fd60734fb8d` |
| `design/ilustraciones/fuentes/geom.py` | `b6d905a78b12d288bf6c398c12733d96329d814a8336452c2d136a93cfaa7529` |
| `design/ilustraciones/fuentes/ilus.py` | `20c4875226a09c04fe1a1c53ada33fe9222be15fa92b9c3a4e573cac5b871580` |
| `design/ilustraciones/fuentes/inicio.py` | `4b374e5177353a139b897a19f2729ae9f56a9d5a763c671fe83da659957e05af` |
| `design/ilustraciones/fuentes/plantilla.py` | `d3ce8cc1601ee9f980b0c94873dd4562512c3d6807c5395d82a9e1e043e120ea` |
| `design/ilustraciones/fuentes/sin_alertas.py` | `8207a185d9c8cff9cc026070a833eae31750d697f30ec44ce34483cc2785766b` |
| `design/ilustraciones/fuentes/sin_conexion.py` | `f021215b8cbaea79bccd93f64415ce7127c89198d2a1800d615bf96da4be138b` |
| `design/ilustraciones/fuentes/vacio_busqueda.py` | `7bb47631a8499ac6c7d0cfc1af618db1b2f33a107b1b20614809c30055656f86` |
| `design/ilustraciones/fuentes/vacio_recientes.py` | `8ee0b41f70ffdbdb18dfdf7e0ec2c73d31f152c9a800a548b492f2cd98de6071` |
| `design/ilustraciones/inicio.json` | `8c332a5e7d5de83e7c897c185e68b0738048580fad08ff762e02f1686ddafb71` |
| `design/ilustraciones/inicio_claro.svg` | `5ce64222a2e3c66254c750330ddd78fe04aa8658b781e654ad28d0979798c10c` |
| `design/ilustraciones/inicio_oscuro.svg` | `3feeaa16a7490a696a43f429c6504bdcf0dc516b0d8a3cd3ebcfc85f06545799` |
| `design/ilustraciones/sin_alertas.json` | `c62b199958e426b6281d46f2255c641629e62b5a3fb40e90f4929258b5dc5598` |
| `design/ilustraciones/sin_alertas_claro.svg` | `f6ee7c859449bb10cb0b4a118b58eb0f08abee576874bb5a1826dc3e7873c88b` |
| `design/ilustraciones/sin_alertas_oscuro.svg` | `96220ad037ae7ede8896bf7909823f420483ed36a81eae8b3916b803beac7387` |
| `design/ilustraciones/sin_conexion.json` | `d98c3a1dcb76c77367c1373389b6f7e90e619130f6a09190dfe4841df285f748` |
| `design/ilustraciones/sin_conexion_claro.svg` | `c68cae697ed77043f57b147b20139977d78b1004535d6013c4627fc36856cdc2` |
| `design/ilustraciones/sin_conexion_oscuro.svg` | `21254aa5baf8dfa88f3d15d78bbe9a5a73c750bf46c8f81e11790fea5b302821` |
| `design/ilustraciones/vacio_busqueda.json` | `66ac232176ce34269c6685029893683dad1f887771e3107a35ec649891ad45c3` |
| `design/ilustraciones/vacio_busqueda_claro.svg` | `d6b1889e931ba9558ce3a13e012d70dc4b1b0a3d4445d942fa753f8892de2c1a` |
| `design/ilustraciones/vacio_busqueda_oscuro.svg` | `df4cc405cd7db79574f2210d15513534db5ebb5059c5708c96f6887482e604b2` |
| `design/ilustraciones/vacio_recientes.json` | `deddb15ac9e7dd54812a362a9cae7240fa8bc08cbd9ab042f234df1f72406666` |
| `design/ilustraciones/vacio_recientes_claro.svg` | `c0136029ea285266d5cc80b97c10291cf6f493032f868a6ae1567a2f73190d9d` |
| `design/ilustraciones/vacio_recientes_oscuro.svg` | `8a5e7bad076450f76b54f37fb56048dc76b6da3abf34edf8c850aacd1efbf5b0` |
| `design/ilustraciones/vista-previa.png` | `e16763153cf69010d1619bef2771b7b95560a9ca21cc94caff1854d122c0585d` |

## Archivos

| Archivo | Bytes | SHA-256 |
|---|---:|---|
| `assets/fonts/bs_iconos/BayStreamIconos.ttf` | 9 212 | `c2d8ed7b8acfb7d88ca75e483ecf1e03c95f18b35c4ac43d3445cfd68bf3e61c` |
| `design/iconos/codigos.json` | 1 101 | `4f676978ee07ad2737a6d432c6caee840cc0e7639f0d7b0b19ba772f5f75eb83` |
| `design/iconos/comprobacion-fuente.png` | 115 864 | `63224b6a85784a38f34cad349a7f3ffdd18e5ad63bd3f6dc5fbf36c722f92554` |
| `design/iconos/comprobacion-skia.md` | 4 089 | `1025bd9bb3afd389934a1fd5aabb047f4c50a338d5262d5df51cb2b0bc78e301` |
| `design/iconos/comprobacion-skia.png` | 128 487 | `95ac9b9c3f2f469583a8bda4e1995106a5cbb8e47d7a90db36644fe32f36b324` |
| `design/iconos/conceptos.png` | 950 325 | `2f3d0e3037ef8950cf939227bf60ab75509ffbb01aad90c860f8d9b61862db2d` |
| `design/iconos/fuentes/LEEME.plantilla.md` | 28 344 | `76f54feaa0504dfc9db7a1f3a2d98b0309a98b8191cf74b1b09bfedec891c8b9` |
| `design/iconos/fuentes/ayudantes.py` | 9 575 | `b271e2814a92b030568ffc92f826be2e67d48601d7b7f2dbf87ca1650d73bb6d` |
| `design/iconos/fuentes/comprobar_skia.js` | 974 | `4feb12127319affa62e7543e67911cc2da61e19648110a3febddcd06ca05e656` |
| `design/iconos/fuentes/comprobar_skia.py` | 6 692 | `9c2806f8a2bbb87423689993c10b3df0367e9ea32bfa52bd84c980cd81a4e0ce` |
| `design/iconos/fuentes/dsl.py` | 8 498 | `dd1a13a0ee0f345f4b46bbc6598fc53b9867f95c3fd8996f577718b71f838cfb` |
| `design/iconos/fuentes/exportar_json.py` | 4 472 | `bc8ce5388a459901b4a9859f500736e67f984d39a42975a46353bafcbc64880a` |
| `design/iconos/fuentes/fuente.py` | 8 179 | `60248f2d5b544ccabe9629f2a81f76e3a737c76a12d94aba8a360bc925139366` |
| `design/iconos/fuentes/geom.py` | 9 345 | `b6d905a78b12d288bf6c398c12733d96329d814a8336452c2d136a93cfaa7529` |
| `design/iconos/fuentes/iconos.py` | 16 936 | `0ffae19fd758a387222f654d5db13f524b997e66aa75eca1cf991617f9307213` |
| `design/iconos/fuentes/insignias.py` | 1 849 | `6810f972d0a7fc7848e04b217be13f44800ccb770b80906136a7beab25095dc7` |
| `design/iconos/fuentes/parejas.py` | 1 892 | `8da277c067e558a12872e9422bba1bcb5a9c1f6cbdc709bd165f6e9564f6ea5a` |
| `design/iconos/fuentes/verificar_fuente.py` | 5 810 | `a69b7f7826ab3b81176735dfac6d78da74114133068185a15f9a6cc4ec9ade20` |
| `design/iconos/fuentes/vista_previa.py` | 3 558 | `affb38a08196c08b3ec8abe09fda437891675f38f73529af862cb4eaeb9d9e23` |
| `design/iconos/generar.py` | 26 187 | `cc887e2d3c312dcf358789a7e637bf0a799611fc0813c565a7c992b16d6ef58e` |
| `design/iconos/svg/al_dia.svg` | 920 | `22a9637123c9670546b500400cd24a811122dc7d16815f0c498b858419fc01b6` |
| `design/iconos/svg/bahia.svg` | 1 011 | `9a8b6e6b9954ab46546157cb6ad84db782da00afbf16143ddba1714c04216808` |
| `design/iconos/svg/baplie.svg` | 1 168 | `0513e11727c0469bab491d5700727c1ef3c3056bd3e26866cc96ae668b6c40ed` |
| `design/iconos/svg/baplie_salida.svg` | 1 008 | `d3ffdd439fea0a6c42b54c8e4a3216bda6a3fb815ddded7867bddb3a19319b0d` |
| `design/iconos/svg/buque.svg` | 1 388 | `fc82753b5c888a4417805c6657596597d84424480a1e8e929ee54eaf2ce3ae2b` |
| `design/iconos/svg/carga.svg` | 976 | `a6ec8a53684ce04b13d6332cd195c5444f7b751714282d4c4fa6fa79e8dfe066` |
| `design/iconos/svg/comparar_baplie.svg` | 1 098 | `b14da614e0fcd2cabe691d4aa0db0bd98e4d37df625b6eb631946e8d1f3671e4` |
| `design/iconos/svg/contenedor_20.svg` | 487 | `d28640992e28539b88ae5318ff6a6d5c82b17473153eaf627b20591ff19c9a0a` |
| `design/iconos/svg/contenedor_40.svg` | 841 | `c19a4adf1456b9d515a6bd4ec8a22e9103e2ad3c37879430195092b4bff3b183` |
| `design/iconos/svg/contenedor_45.svg` | 841 | `93e301b450c33e83e53abbc55a58850dcb81168fb7cc221e2620a91bba9dcdfe` |
| `design/iconos/svg/descarga.svg` | 930 | `b5d13ffd7169ac499f462ba0dc7c8bd5cbaa02d2d07e0eb7a83164970ffa7fc4` |
| `design/iconos/svg/escala.svg` | 1 467 | `a00c79293eeee80e7bd653b0fcf2d0259f4a95f313829d5a8370212ebd8421c6` |
| `design/iconos/svg/fuera_de_medida.svg` | 615 | `00a5b867402285a8a7e346e280332cda6c8e8329cf9e2d198858ac329772e244` |
| `design/iconos/svg/grua.svg` | 914 | `b23897b646de4f1feade75d1cb0dd8037ee06d0685db5fc2a91c4fd9497c19b7` |
| `design/iconos/svg/limite_apilamiento.svg` | 762 | `04d5afc4bc73d253c01c4c04e4978f4db9b1c7125f57643d6219d0db8be0c5f2` |
| `design/iconos/svg/listado_agencia.svg` | 1 306 | `312e5943ee8cfa13cf70a0dc0dd551c3807391dfaa847e6e838d03eeca38ffe7` |
| `design/iconos/svg/muelle.svg` | 935 | `06239e59338282b26a571a4d1bcc727d003edeca9849c5739ab0cdab2340e701` |
| `design/iconos/svg/oficina.svg` | 1 489 | `470bb78a6001e2887bd80bba90e7c55982ae78e02e88dcb315e21056cc2ac625` |
| `design/iconos/svg/orden.svg` | 1 056 | `1870f55e7a9cfd764954b45075a24f0ab778b45f96e7ffcda36a017d930ac6c1` |
| `design/iconos/svg/pedir_cambio.svg` | 788 | `76e47e7a2128ceb2a63229587431cc90065ab81184b32d35ef1cb1d37ef0a8be` |
| `design/iconos/svg/peligrosa.svg` | 721 | `ab0fb8f2afa666e04ef75f2f77ed91b611531d27e515fa0fcd4944d931f7c551` |
| `design/iconos/svg/peso_pila.svg` | 808 | `8f68a719b52c006e5faa564960c58d2b94df5b01bb9e32d3ef860ad888e0efe2` |
| `design/iconos/svg/plataforma.svg` | 378 | `a74d32d27ab10d4062446cf72d35c6bb8dd97ae607967c86cb104d99537452c1` |
| `design/iconos/svg/reestiba.svg` | 1 018 | `d860291d21c2d9d9165d108b1722f983a8210fb02956703f14460c0aa9dabb8c` |
| `design/iconos/svg/refrigerado.svg` | 2 277 | `a166d93a1528dfbb6fef82eef67277cead31293832ef1b53f74a8f66e7def3b6` |
| `design/iconos/svg/segregacion.svg` | 1 614 | `c0f7f1de4f56899bcee3cab099ba5310df720dcd9803f0c551e2b0d45356a0fd` |
| `design/iconos/svg/solo_aqui.svg` | 834 | `dc6d4ae7f02103523c5d2a2445dc05ebef998f15d21de1af4dd8ed288a6920d4` |
| `design/iconos/svg/tanque.svg` | 634 | `78e1af21aa0fdc9a2e357d19e3d376ac9f483baf45087e0cb722924ed41a18e4` |
| `design/iconos/svg/tapa_escotilla.svg` | 541 | `c73200aa3a5e731012dc688e4673d125161d859164211d9c2ab2035ffd6697e0` |
| `design/iconos/svg/techo_abierto.svg` | 1 001 | `2d38c6f38ead85195757d3834bb721534d7b8794a8b4cdcb4bb856939361ad9c` |
| `design/iconos/svg/vacio.svg` | 441 | `49caf59f172edb0afbf74ead8543f804025fb613c5c5a2e742ddcf9bfb8deb86` |
| `design/iconos/svg/vgm.svg` | 1 171 | `9090a24771b435546d90b23420e464ba1052a25f46fa0f329805e3a23b989612` |
| `design/iconos/svg_insignias/fuera_de_medida.svg` | 670 | `c7a3c7541fb3ded71b8fac61c7ee144320483b2e74a1e8cdbeaaab34b9e8d338` |
| `design/iconos/svg_insignias/peligrosa.svg` | 766 | `40a4e73433cdc4b169eaf6e856c7630b1ede5b053d3fb6d6fa1ec9be031fa195` |
| `design/iconos/svg_insignias/refrigerado.svg` | 1 039 | `b4507f95c1a3375803b28ebf70cf2009b511bb8ff16e9119e1e20caf10ed7f0c` |
| `design/iconos/svg_insignias/vacio.svg` | 486 | `9bd8fa12915aee865a02721aa6478eb50cf1e7b7bea65d6228fbfbd3e1c3ee63` |
| `design/iconos/vista-previa.png` | 130 117 | `dd7fe29862b6a2110e652efdcce231309e565fcdf80f22f4190e1d93fffd81d0` |
| `design/ilustraciones/descarga_completa.json` | 10 304 | `fd986e230704e8961ea72881abaa9b5f1b3b54cc1d1f30d975571ebe010d1c84` |
| `design/ilustraciones/descarga_completa_claro.svg` | 8 804 | `fdf6b176c0c65a4728444334f6cec50d5b806c401e3541b2f4c2f7e36c208156` |
| `design/ilustraciones/descarga_completa_oscuro.svg` | 8 721 | `f0f1c8242ad9dc6d3acffcd0e34cddb9df98220e44a5f0239b4f3642d8080989` |
| `design/ilustraciones/fuentes/descarga_completa.py` | 2 468 | `9955a2c0901ee6368aa3a5e3fc1add6abfe4385c3a98adbd9d125fd60734fb8d` |
| `design/ilustraciones/fuentes/geom.py` | 9 345 | `b6d905a78b12d288bf6c398c12733d96329d814a8336452c2d136a93cfaa7529` |
| `design/ilustraciones/fuentes/ilus.py` | 8 404 | `20c4875226a09c04fe1a1c53ada33fe9222be15fa92b9c3a4e573cac5b871580` |
| `design/ilustraciones/fuentes/inicio.py` | 2 727 | `4b374e5177353a139b897a19f2729ae9f56a9d5a763c671fe83da659957e05af` |
| `design/ilustraciones/fuentes/plantilla.py` | 26 373 | `d3ce8cc1601ee9f980b0c94873dd4562512c3d6807c5395d82a9e1e043e120ea` |
| `design/ilustraciones/fuentes/sin_alertas.py` | 1 626 | `8207a185d9c8cff9cc026070a833eae31750d697f30ec44ce34483cc2785766b` |
| `design/ilustraciones/fuentes/sin_conexion.py` | 1 625 | `f021215b8cbaea79bccd93f64415ce7127c89198d2a1800d615bf96da4be138b` |
| `design/ilustraciones/fuentes/vacio_busqueda.py` | 1 603 | `7bb47631a8499ac6c7d0cfc1af618db1b2f33a107b1b20614809c30055656f86` |
| `design/ilustraciones/fuentes/vacio_recientes.py` | 1 734 | `8ee0b41f70ffdbdb18dfdf7e0ec2c73d31f152c9a800a548b492f2cd98de6071` |
| `design/ilustraciones/inicio.json` | 21 008 | `8c332a5e7d5de83e7c897c185e68b0738048580fad08ff762e02f1686ddafb71` |
| `design/ilustraciones/inicio_claro.svg` | 17 293 | `5ce64222a2e3c66254c750330ddd78fe04aa8658b781e654ad28d0979798c10c` |
| `design/ilustraciones/inicio_oscuro.svg` | 16 568 | `3feeaa16a7490a696a43f429c6504bdcf0dc516b0d8a3cd3ebcfc85f06545799` |
| `design/ilustraciones/sin_alertas.json` | 1 145 | `c62b199958e426b6281d46f2255c641629e62b5a3fb40e90f4929258b5dc5598` |
| `design/ilustraciones/sin_alertas_claro.svg` | 766 | `f6ee7c859449bb10cb0b4a118b58eb0f08abee576874bb5a1826dc3e7873c88b` |
| `design/ilustraciones/sin_alertas_oscuro.svg` | 683 | `96220ad037ae7ede8896bf7909823f420483ed36a81eae8b3916b803beac7387` |
| `design/ilustraciones/sin_conexion.json` | 4 705 | `d98c3a1dcb76c77367c1373389b6f7e90e619130f6a09190dfe4841df285f748` |
| `design/ilustraciones/sin_conexion_claro.svg` | 3 059 | `c68cae697ed77043f57b147b20139977d78b1004535d6013c4627fc36856cdc2` |
| `design/ilustraciones/sin_conexion_oscuro.svg` | 2 640 | `21254aa5baf8dfa88f3d15d78bbe9a5a73c750bf46c8f81e11790fea5b302821` |
| `design/ilustraciones/vacio_busqueda.json` | 3 010 | `66ac232176ce34269c6685029893683dad1f887771e3107a35ec649891ad45c3` |
| `design/ilustraciones/vacio_busqueda_claro.svg` | 1 967 | `d6b1889e931ba9558ce3a13e012d70dc4b1b0a3d4445d942fa753f8892de2c1a` |
| `design/ilustraciones/vacio_busqueda_oscuro.svg` | 1 548 | `df4cc405cd7db79574f2210d15513534db5ebb5059c5708c96f6887482e604b2` |
| `design/ilustraciones/vacio_recientes.json` | 6 070 | `deddb15ac9e7dd54812a362a9cae7240fa8bc08cbd9ab042f234df1f72406666` |
| `design/ilustraciones/vacio_recientes_claro.svg` | 4 677 | `c0136029ea285266d5cc80b97c10291cf6f493032f868a6ae1567a2f73190d9d` |
| `design/ilustraciones/vacio_recientes_oscuro.svg` | 4 681 | `8a5e7bad076450f76b54f37fb56048dc76b6da3abf34edf8c850aacd1efbf5b0` |
| `design/ilustraciones/vista-previa.png` | 76 125 | `e16763153cf69010d1619bef2771b7b95560a9ca21cc94caff1854d122c0585d` |

`design/iconos/LEEME.md` es este archivo; no lleva su propio SHA-256.

## Para versionar

Carlos ejecuta Git. Un `git add` por ruta, sin comodines:

```
git add -- assets/fonts/bs_iconos/BayStreamIconos.ttf
git add -- design/iconos/codigos.json
git add -- design/iconos/comprobacion-fuente.png
git add -- design/iconos/comprobacion-skia.md
git add -- design/iconos/comprobacion-skia.png
git add -- design/iconos/fuentes/LEEME.plantilla.md
git add -- design/iconos/fuentes/comprobar_skia.py
git add -- design/iconos/fuentes/fuente.py
git add -- design/iconos/fuentes/iconos.py
git add -- design/iconos/generar.py
git add -- design/iconos/svg/oficina.svg
git add -- design/iconos/vista-previa.png
git add -- design/iconos/LEEME.md
git commit -m "Suma el icono oficina (U+E023) al paquete de iconos, v3"
git push
```

No cambian `pubspec.lock` ni `lib/`; `pubspec.yaml` solo cuando Timonel declare la fuente.

— Nube
