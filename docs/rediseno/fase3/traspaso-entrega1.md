# Traspaso · Fase 3, entrega 1 (Timonel, 22-oct-2026)

Para el chat que sigue. La entrega 1 (el inicio y la primera visualización) quedó cerrada
**solo en lo funcional**, por el alto parcial de Yov del 22-oct: Carlos y Yov revisan una
dirección visual nueva («Puente de mando»). Lo de la Fase 2 (tokens, tema, `ThemeExtension`,
componentes, fuentes, pruebas) se queda; cambiarán valores y se sumarán piezas. **No se
empieza la entrega 2 (el plano por bahía) hasta que Carlos apruebe esa dirección.** La
sección completa, con validaciones, capturas, RNF-002 y el bloque de git, es «Fase 3 ·
Entrega 1» en `docs/REDISENO-RESULTADOS.md`; las decisiones del sprint, en `SPRINT-4.md`
(10.2 a 10.13) y `DESIGN.md` (4.3, 7, 9.1, 12).

## Qué quedó hecho

- Tema claro y oscuro conectado en `lib/core/app.dart` con la preferencia de T-90 y la
  densidad por plataforma (`bayStreamEsMuelle`: muelle en Android/iOS, oficina en Windows/Web).
- Estados del viaje en una `sealed class` (`presentation/providers/voyage_ui_state.dart`:
  `SinViaje`, `Leyendo`, `Previo` con `PreviewReason`, `Publicado`, `Fallo`), derivados del
  notifier por `voyageUiStateProvider`. Los textos de la banda viven ahí.
- «Ver primero, confirmar después» en `vessel_providers.dart`: `_abrirPrevio` muestra el
  plano con la geometría propuesta sin guardar; `isPreview`, `visibleVoyage`, `discardPreview`;
  `publishedVoyage`/`publishedProfile` no ven el previo (peso por pila y tomas: «sin
  evaluar»); `_publish` sigue siendo la única escritura. Regla estricta en `_useProfile`.
- El inicio (`widgets/inicio_view.dart`, `empty_state_widget.dart`) según `DESIGN.md` 9.1; la
  página (`vessel_overview_page.dart`) con el plano como primera pestaña, la banda con
  «Confirmar», «sin evaluar», sin modos ni exportar en previo, descartar con pregunta.
- RNF-002 en tres pasos en Windows, Web y emulador (antes seis), con instrumentos nuevos.

## Archivos tocados

`lib/core/app.dart`; `lib/features/vessel/presentation/providers/{voyage_ui_state (nuevo),
vessel_providers}.dart`; `pages/{vessel_overview_page, stowage_alerts_page}.dart`;
`widgets/{inicio_view (nuevo), empty_state_widget}.dart`; `DESIGN.md`; en `tool/`:
`t99_conductor.dart`, `t99_app.dart`, `t99_plataforma_{io,web}.dart`, `t99_copia.ps1`,
`t112_censos.py` y los nuevos `t114_primera_{windows,android,web}.py`, `t114_primera_web.js`,
`t114_primera_cuadros.py`, `t114_capturas_{windows.ps1,android.py,web.py}`;
`docs/rediseno/fase3/**`. Sin tocar: `domain/`, `data/`, `lib/main.dart`, `pubspec.*`, los
archivos congelados de H5, los instrumentos de T-98.

## Pruebas

Piso **1156** (1143 + 13 en `test/t114_fase3_inicio_test.dart`: tema, inicio, previo,
banda, «sin evaluar», sin exportar, confirmar, descartar, regla estricta, hallazgo 5,
perfil que no cubre, buque nuevo sin escala, homónimo). Actualizadas sin bajar el conteo:
`profile_loading_page_test`, `profile_loading_test`, `profile_persistence_test`,
`recent_voyages_test`, `stowage_alerts_page_test`, `t104_text_test`, `t86_baplie_version_test`,
`t89_file_input_test` (esperaban que «Parámetros del buque» abriera solo). `analyze` en cero.
En las pruebas de página el plano abre primero y pliega la barra: tocar «Lista» antes de
usar la barra; a 360 dp, `scrollUntilVisible`/`ensureVisible` para los controles de abajo.

## Pendiente

- Entrega 2 (plano por bahía con la navegación adaptable), **detenida** hasta la dirección.
- A 360 dp con letra 1.45 y 2.0 el previo recorta «Contenido» y «Número de orden» (controles
  del plano de antes) y el código de cinco letras se corta a escala 2.0 (10.8): van con el plano.
- El Honor no se midió (el emulador hizo de teléfono); queda para cuando Carlos lo autorice.
- Codex acepta la entrega 1 en `C:\Proyectos\baystream-qa-r4`; sus observaciones pueden
  traer una corrección.

## Decisiones mías que no están en SPRINT-4.md

- «La última escala confirmada para ese buque» se lee de los viajes guardados del perfil
  (`_lastConfirmedPortFor`), del almacén que ya existe: `domain/` y `data/` no cambian.
- Un plano de llegada que propone la misma escala que la última confirmada abre
  **publicado** (la regla de 7.2 cumpliéndose): por eso en el emulador el previo se captura
  con `T99_SINTETICO_977.edi` (buque nuevo) y el del hallazgo 5 con el arnés de Windows.
- El getter del notifier se llama `loadedFileName` (los bancos de `tool/` ya tenían `fileName`).
- La Web se mide con el Chrome instalado abierto por Playwright (perfil temporal, ventana
  visible), no con el navegador integrado: oculto no pinta ni corre `requestAnimationFrame`.
- Cancelar en parámetros, identidad o plantilla deja el previo a la vista (antes descartaba).
- De paso en la página, porque la auditoría exige cero avisos en lo tocado: el tamaño de
  letra de los chips pasa al tema y el `Future.delayed(Duration.zero)` de exportar a PDF
  pasa a `endOfFrame`.
- Los MP4 del emulador quedan en `%TEMP%\t114\primera\android` (SHA-256 en cada
  `captura.json`); en `/sdcard/Download` del emulador hay un `CORPUS_A01.edi` de T-99 que no
  debe aparecer en capturas.
