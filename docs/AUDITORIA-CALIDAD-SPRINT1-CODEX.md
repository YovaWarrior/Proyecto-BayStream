# Auditoría de calidad del Sprint 1 — Codex

**Auditor:** Capitán Codex  
**Fecha:** 27 de agosto de 2026  
**Base auditada:** commit `713da5a`, worktree separado y detached  
**Modalidad:** doble prueba ciega; no se consultó la auditoría de Yov  
**Alcance:** los cinco elementos del Sprint 1, T-22, T-23 y las comprobaciones transversales del checklist

## Método y entorno

- Flutter 3.38.9; Dart 3.10.8.
- Corpus real: `CORPUS_A01.edi`, SHA-256 `3D793F8056A3D8B96140E681B6C468EA49922658AFDEA4F7416A169A60A8CE5B`, 164,310 bytes, 8,459 líneas, 977 contenedores y 27 bahías.
- Plataformas dinámicas: Windows 11, Web local compilada y Android (emulador Pixel 8 Pro, API 36.1). También se confirmó el arranque en un POCO X3 NFC con Android 12; MIUI bloqueó la inyección de eventos ADB, por lo que las interacciones reproducibles se hicieron en el emulador.
- No se modificó código, no se publicó en Firebase y no se corrigieron hallazgos.
- El PDF real generado tiene 55 páginas y 217,226 bytes. Se renderizaron y revisaron las 55 páginas.

## Resultado ejecutivo

Resultado de las 78 comprobaciones: **39 CUMPLE, 17 CUMPLE CON RESERVA, 21 NO CUMPLE y 1 NO DETERMINABLE**. El Sprint 1 compila en Windows, Android y Web y sus 31 pruebas pasan. Sin embargo, la auditoría encontró incumplimientos materiales: la igualdad exigida entre `weightByTier` y `totalWeight` no es universal, la rejilla de pantalla acumula desalineación, el PDF no reproduce toda la información/lógica visual del plano, el CSV no neutraliza fórmulas, el parser carece de límites y diagnóstico robusto, y el plano con el corpus real provoca un ANR en Android API 36. El análisis confirma 49 *issues* (4 `warning` y 45 `info`), no 49 advertencias de severidad `warning`.

## Bloque 1 — Peso por nivel y límite provisional

| ID | Veredicto | Evidencia (archivo:línea) | Nota |
|---|---|---|---|
| 1.1 | CUMPLE | `lib/features/vessel/domain/entities/bay.dart:1-3,64-75` | `weightByTier` es un getter puro del dominio y el archivo no importa Flutter. |
| 1.2 | NO CUMPLE | `lib/features/vessel/domain/entities/bay.dart:59-60,66-72`; `test/baplie_parser_test.dart:308-327` | `totalWeight` suma todos los contenedores; `weightByTier` solo los posicionados. La prueba usa un contenedor sin posición pero sin peso, por lo que no demuestra la igualdad universal. |
| 1.3 | CUMPLE CON RESERVA | `lib/features/vessel/presentation/widgets/bay_plan_view.dart:612-613,645-657`; `lib/features/vessel/domain/entities/bay.dart:69-72` | Se muestra tonelada con un decimal para niveles ocupados y peso positivo; un nivel ocupado con peso cero/sin dato queda sin etiqueta. |
| 1.4 | CUMPLE CON RESERVA | `lib/features/vessel/domain/entities/bay.dart:67-73`; `lib/features/vessel/presentation/widgets/bay_plan_view.dart:645-649`; `test/baplie_parser_test.dart:303-307` | El nivel vacío no muestra cero, pero uno ocupado sin peso queda visualmente indistinguible respecto del dato de peso ausente. |
| 1.5 | CUMPLE | `lib/features/vessel/presentation/widgets/bay_plan_view.dart:113-117` | El umbral de 90,000 kg conserva íntegro el comentario `PROVISIONAL`. |
| 1.6 | CUMPLE | `lib/features/vessel/presentation/widgets/bay_plan_view.dart:612-614,649-664` | El exceso usa `colorScheme.errorContainer` y `onErrorContainer`. |
| 1.7 | NO CUMPLE | `lib/features/vessel/presentation/widgets/bay_plan_view.dart:583-600,616-646,703-716,752-755` | La etiqueta mide 50 px; cada celda mide 50 px más márgenes horizontales de 2 px por lado. La diferencia de 4 px por columna acumula desalineación. |
| 1.8 | NO CUMPLE | `docs/qa-sprint1/capturas/windows-bay-plan-bay01.jpg`; `docs/qa-sprint1/capturas/web-bay-plan.png`; `docs/qa-sprint1/capturas/android-anr-bay-plan.png`; `docs/qa-sprint1/capturas/android-anr-bay-plan-after-wait.png` | Windows y Web muestran la columna; en Android API 36, al abrir Bay Plan con el corpus real aparece un ANR persistente incluso después de elegir “Wait”. No se puede considerar correcta en las tres plataformas. |
| 1.9 | CUMPLE | `docs/qa-sprint1/capturas/windows-bay-plan-bay01.jpg`; corpus `CORPUS_A01.edi:412-415,3342-3345,4015-4018,7606-7609` | Bay 01: 21,210 + 16,411 + 21,210 + 21,210 = 80,041 kg, presentado como 80.0 t; las etiquetas 21.2, 16.4, 21.2 y 21.2 t coinciden. |

## Bloque 2 — Búsqueda y fichas sugeridas

| ID | Veredicto | Evidencia (archivo:línea) | Nota |
|---|---|---|---|
| 2.1 | CUMPLE | `lib/features/vessel/presentation/widgets/container_search_delegate.dart:131-146` | Orden descendente antes de `.take(5)`. |
| 2.2 | CUMPLE | `lib/features/vessel/presentation/widgets/container_search_delegate.dart:131-137` | El desempate usa la clave alfabética; es determinista, aunque sensible a mayúsculas/minúsculas. |
| 2.3 | CUMPLE | `lib/features/vessel/presentation/widgets/container_search_delegate.dart:109-129,201-210,234-243` | Un recorrido construye mapas de conteo y el avatar reutiliza esos valores. |
| 2.4 | CUMPLE CON RESERVA | `lib/features/vessel/presentation/widgets/container_search_delegate.dart:111-128,188-222` | Excluye `null` y cadena vacía; una cadena compuesta solo por espacios puede sobrevivir. |
| 2.5 | CUMPLE | `test/container_search_delegate_test.dart:31-55,61-68,87-92` | Verifica orden y desempate. |
| 2.6 | CUMPLE CON RESERVA | `docs/qa-sprint1/capturas/windows-busqueda-sugerencias.jpg`; `lib/features/vessel/presentation/widgets/container_search_delegate.dart:131-146` | Con A01 aparecen correctamente NV1 (945) y NV6 (32). El corpus solo contiene dos navieras, así que no permite observar cinco. Los puertos fueron USHOU 907, USMSY 40 y XXVSL 30. |
| 2.7 | CUMPLE | `docs/qa-sprint1/capturas/windows-busqueda-ficha-nv6.jpg` | Al tocar NV6 se rellenó la consulta y se mostraron sus resultados. |

## Bloque 3 — Reporte PDF

| ID | Veredicto | Evidencia (archivo:línea) | Nota |
|---|---|---|---|
| 3.1 | CUMPLE | `lib/features/vessel/presentation/widgets/bay_plan_view.dart:705-746`; `lib/features/vessel/data/services/pdf_report_service.dart:424-438` | Los colores base de las celdas coinciden. |
| 3.2 | NO CUMPLE | `lib/features/vessel/presentation/widgets/bay_plan_view.dart:168-194,518-568`; `lib/features/vessel/data/services/pdf_report_service.dart:272-282,331-343,440-469` | Etiquetas cubierta/bodega y leyenda difieren; solo el separador mantiene equivalencia. |
| 3.3 | CUMPLE | `lib/features/vessel/presentation/widgets/bay_plan_view.dart:474-483`; `lib/features/vessel/data/services/pdf_report_service.dart:239-248` | Ambos separan cubierta en `tier >= 80`. |
| 3.4 | CUMPLE | `lib/features/vessel/data/services/pdf_report_service.dart:473-518`; `docs/qa-sprint1/capturas/pdf-tabla-pagina-02-global-30.png`; `docs/qa-sprint1/capturas/pdf-tabla-pagina-03-global-31.png` | El encabezado se repite en cada página de tabla. |
| 3.5 | CUMPLE CON RESERVA | `lib/features/vessel/data/services/pdf_report_service.dart:46-55`; `lib/features/vessel/data/parsers/iso_coordinate_parser.dart:60-65,79-113` | Compara el código de estiba como cadena. Funciona por el invariante ISO de siete dígitos con relleno; entidades construidas fuera del parser podrían romperlo. |
| 3.6 | CUMPLE | `pubspec.yaml:9-34`; `pubspec.lock:579-619`; `lib/features/vessel/data/services/pdf_report_service.dart:1-8` | `printing` no aparece; se usa `pdf: 3.12.0`. |
| 3.7 | CUMPLE | `lib/features/vessel/data/services/pdf_report_service.dart:15-21`; `pubspec.yaml:45-47` | Fuentes cargadas de forma asíncrona con `rootBundle`, sin `dart:io` ni rutas absolutas. |
| 3.8 | NO CUMPLE | `lib/features/vessel/presentation/widgets/bay_plan_view.dart:612-667`; `lib/features/vessel/data/services/pdf_report_service.dart:201-208,346-373` | El PDF omite los pesos por nivel y no conserva las mismas señales/semántica visual de exceso. |
| 3.9 | NO CUMPLE | `lib/features/vessel/presentation/widgets/bay_plan_view.dart:415-484`; `lib/features/vessel/data/services/pdf_report_service.dart:223-249,298-310` | Pantalla dibuja rangos completos; PDF solo niveles ocupados y divide rangos de otra forma. El efecto visible es la ausencia de filas vacías/intermedias. |
| 3.10 | CUMPLE CON RESERVA | `lib/features/vessel/data/services/pdf_report_service.dart:46-70,129-137,693-701`; `lib/features/vessel/data/parsers/baplie_parser_service.dart:49-57` | Hay guardas para listas y divisiones; el nombre podría quedar vacío en una entidad creada manualmente, aunque el parser real lo exige. |
| 3.11 | NO CUMPLE | `lib/features/vessel/data/services/pdf_report_service.dart:63-70,129-137,693-701`; `lib/features/vessel/data/parsers/baplie_parser_service.dart:49-57,325-329`; corpus `CORPUS_A01.edi:15-16,34,148,284,417` | La portada usa singular, pero concatena todos los POL/POD. A01 produjo tres orígenes (GTPBR, HNPCR, PAMIT) y tres destinos (USHOU, USMSY, XXVSL), no un origen/destino inequívoco del viaje. |
| 3.12 | CUMPLE | `docs/qa-sprint1/capturas/windows-dialogo-guardar-pdf.jpg` | Generación en frío: 5.464 s hasta el diálogo; repetición caliente: 1.473 s. PDF: 55 páginas, 217,226 bytes. |
| 3.13 | NO CUMPLE | `docs/qa-sprint1/capturas/windows-bay-plan-bay06.jpg`; `docs/qa-sprint1/capturas/pdf-bahia-006-pagina-05.png` | Revisión de las 55 páginas: el PDF omite pesos por nivel y filas vacías; además difieren etiquetas/leyenda. No reproduce pantalla página a página. |
| 3.14 | CUMPLE | `docs/qa-sprint1/capturas/pdf-tabla-pagina-01-global-29.png`; `docs/qa-sprint1/capturas/pdf-tabla-pagina-02-global-30.png`; `docs/qa-sprint1/capturas/pdf-tabla-pagina-03-global-31.png` | La tabla comienza en la página global 29 y repite encabezado en 29, 30, 31 y las restantes hasta 55. |
| 3.15 | CUMPLE | `docs/qa-sprint1/capturas/windows-dialogo-guardar-pdf.jpg`; `docs/qa-sprint1/capturas/android-selector-pdf.png`; `docs/qa-sprint1/capturas/web-descarga-pdf.png` | Se observó diálogo nativo Windows, selector del sistema Android y “Exportación PDF completada” tras la descarga Web. |
| 3.16 | CUMPLE CON RESERVA | `docs/qa-sprint1/capturas/pdf-portada-accentos.png` | Acentos como Dirección, Bahías y Vacíos renderizan correctamente. A01 es ASCII y el documento generado no ejercita una `ñ` proveniente del corpus. |
| 3.17 | CUMPLE CON RESERVA | `lib/features/vessel/presentation/pages/vessel_overview_page.dart:224-248`; `docs/qa-sprint1/capturas/web-generando-pdf.png`; `docs/qa-sprint1/capturas/android-selector-pdf.png` | En Windows una interacción con Lista fue atendida durante la generación caliente y Android llegó al selector. La generación corre en el isolate de UI y no garantiza respuesta con cargas mayores. |

## Bloque 4 — Perfil longitudinal

| ID | Veredicto | Evidencia (archivo:línea) | Nota |
|---|---|---|---|
| 4.1 | CUMPLE | `lib/features/vessel/presentation/widgets/vessel_profile_view.dart:42-43,148-173,362-380` | Orden numérico de bahías de proa a popa. |
| 4.2 | CUMPLE | `lib/features/vessel/presentation/widgets/vessel_profile_view.dart:54-61,137-145,189-194,247-250,316-319` | Cada modo usa una escala monocromática. |
| 4.3 | CUMPLE CON RESERVA | `lib/features/vessel/presentation/widgets/vessel_profile_view.dart:137-145,189-194,247-250` | Color y etiqueta parten del mismo valor; el relleno se limita a `[0,1]` pero la etiqueta no, por lo que datos fuera de rango pueden divergir visualmente. |
| 4.4 | NO CUMPLE | `lib/features/vessel/presentation/widgets/vessel_profile_view.dart:189-194,247-250` | El texto usa `onSurface` para toda la escala, no un color adaptado al fondo (`onPrimary`/`onTertiary`), sin garantía de contraste en ambos extremos. |
| 4.5 | CUMPLE CON RESERVA | `lib/features/vessel/presentation/widgets/vessel_profile_view.dart:54-61,247-250,316-319` | La escala es relativa a la bahía más pesada; la leyenda muestra extremos, pero no dice literalmente “máximo del viaje”. |
| 4.6 | CUMPLE | `lib/features/vessel/presentation/widgets/vessel_profile_view.dart:20-22,130-132`; `lib/features/vessel/presentation/pages/vessel_overview_page.dart:216-222` | Callback selecciona con `selectedBayProvider` y anima el `TabController` a Bay Plan. |
| 4.7 | NO CUMPLE | `lib/features/vessel/presentation/widgets/vessel_profile_view.dart:113-126` | La capacidad es fija (12 filas × 10 niveles); no procede de capacidad real del buque ni se asigna por bahía. |
| 4.8 | CUMPLE | `docs/qa-sprint1/capturas/web-perfil-360.png`; `docs/qa-sprint1/capturas/web-perfil-800.png`; `docs/qa-sprint1/capturas/web-perfil-1440.png` | A 360, 800 y 1440 px el perfil conserva desplazamiento horizontal y no mostró desbordes. |
| 4.9 | CUMPLE CON RESERVA | `docs/qa-sprint1/capturas/windows-perfil-ocupacion.jpg`; `docs/qa-sprint1/capturas/windows-bay-plan-bay01.jpg`; `docs/qa-sprint1/capturas/windows-bay-plan-bay06.jpg` | Se tocaron B003, B022 y B044 y se observaron los títulos correctos. No se guardó una captura individual de cada una, por lo que la evidencia gráfica no cubre literalmente las tres selecciones. |
| 4.10 | CUMPLE | `docs/qa-sprint1/capturas/windows-perfil-ocupacion.jpg`; `docs/qa-sprint1/capturas/windows-perfil-peso.jpg` | Ambos modos se capturaron con A01. |

## Bloque 5 — Exportaciones CSV y JSON

| ID | Veredicto | Evidencia (archivo:línea) | Nota |
|---|---|---|---|
| 5.1 | CUMPLE | `lib/features/vessel/data/services/export_service.dart:52-56,98-106` | El CSV antepone BOM UTF-8. |
| 5.2 | CUMPLE | `lib/features/vessel/data/services/export_service.dart:58-96`; `lib/features/vessel/domain/entities/container_unit.dart:1-96` | 24 columnas, una por cada campo serializado del modelo. |
| 5.3 | CUMPLE | `lib/features/vessel/data/services/export_service.dart:108-114` | Escapa comillas, comas, CR y LF. |
| 5.4 | NO CUMPLE | `lib/features/vessel/data/services/export_service.dart:108-114` | No neutraliza prefijos `=`, `+`, `-` o `@`; Excel puede interpretar datos externos como fórmulas. |
| 5.5 | CUMPLE | `lib/features/vessel/data/services/export_service.dart:40-50` | JSON usa `voyage.toJson()`. |
| 5.6 | CUMPLE | `lib/features/vessel/presentation/pages/vessel_overview_page.dart:57-88,224-269` | Un único menú y método compartido para PDF, CSV y JSON. |
| 5.7 | CUMPLE CON RESERVA | `lib/features/vessel/data/services/export_service.dart:116-125` | Reemplaza varios caracteres inválidos, pero no cubre nombres reservados de Windows, punto/espacio final ni longitud extrema. |
| 5.8 | CUMPLE CON RESERVA | `docs/qa-sprint1/capturas/windows-csv-excel.jpg` | Excel detectó UTF-8 y, tras elegir explícitamente coma en el asistente regional, mostró 24 columnas y datos numéricos. A01 no contiene acentos en valores de contenedor. |
| 5.9 | CUMPLE | `lib/features/vessel/data/services/export_service.dart:40-50` | `python -m json.tool` terminó correctamente y el JSON contiene 977 contenedores. |
| 5.10 | CUMPLE | `lib/features/vessel/data/services/export_service.dart:52-106` | BOM `EF BB BF`, 24 columnas y exactamente 977 filas de datos. |

## Bloque 6 — Robustez del parser y entrada inválida

| ID | Veredicto | Evidencia (archivo:línea) | Nota |
|---|---|---|---|
| 6.1 | CUMPLE | `lib/features/vessel/data/parsers/baplie_parser_service.dart:85-333`; `lib/features/vessel/data/parsers/iso_coordinate_parser.dart:45-113` | Conversiones numéricas provenientes del archivo están protegidas con `tryParse`/validación. |
| 6.2 | CUMPLE | `lib/features/vessel/data/parsers/baplie_parser_service.dart:85-333`; `lib/features/vessel/data/parsers/iso_coordinate_parser.dart:45-113` | Los índices y substrings revisados tienen guardas de longitud. |
| 6.3 | NO CUMPLE | `lib/features/vessel/data/parsers/baplie_parser_service.dart:31-333` | No existe límite de bytes, segmentos ni contenedores. |
| 6.4 | NO CUMPLE | `lib/features/vessel/presentation/providers/vessel_providers.dart:315-321` | Convierte bytes con `String.fromCharCodes`, no con `utf8.decode`; no valida UTF-8 real. |
| 6.5 | NO CUMPLE | `lib/features/vessel/data/parsers/baplie_parser_service.dart:31-74`; `docs/qa-sprint1/capturas/windows-error-pdf-renombrado-edi.jpg` | Vacío, binario o sin separador terminan en errores estructurales genéricos. Un PDF renombrado informó que faltaba TDT/nombre del buque, no que el archivo era binario o no BAPLIE. |
| 6.6 | NO CUMPLE | `lib/features/vessel/data/parsers/baplie_parser_service.dart:83-333` | Hay caminos con `continue` y sobrescrituras de mapa que descartan unidades/valores sin diagnóstico al usuario. |
| 6.7 | NO CUMPLE | `lib/features/vessel/presentation/providers/vessel_providers.dart:315-325` | Lectura y parseo síncronos en el isolate de interfaz. |
| 6.8 | NO CUMPLE | `lib/features/vessel/presentation/providers/vessel_providers.dart:329-333`; `lib/features/vessel/presentation/pages/vessel_overview_page.dart:188-205` | El texto crudo de la excepción se propaga a la interfaz; H-05 sigue vigente. |
| 6.9 | NO CUMPLE | `docs/qa-sprint1/capturas/windows-error-pdf-renombrado-edi.jpg`; `lib/features/vessel/data/parsers/baplie_parser_service.dart:49-57` | Mensaje observado: “No se encontró el nombre del buque en el segmento TDT”; es engañoso para un PDF renombrado. |
| 6.10 | NO CUMPLE | `lib/features/vessel/presentation/providers/vessel_providers.dart:315-325`; `docs/qa-sprint1/capturas/windows-lista-corpus-a01.jpg` | Desde Abrir hasta vista cargada: 3.111 s. No se observó “Procesando archivo BAPLIE...” y el parser corre en UI. |

## Bloque 7 — Reglas de Firebase

| ID | Veredicto | Evidencia (archivo:línea) | Nota |
|---|---|---|---|
| 7.1 | CUMPLE | `firestore.rules:8-10`; `SPRINT-1.md:529-535` | `voyages` permite read/create/update y niega delete como la regla autorizada. |
| 7.2 | CUMPLE | `firestore.rules:8-10,27-28` | `voyages` niega delete y el comodín final niega lo no declarado. |
| 7.3 | CUMPLE | `firestore.rules:1-30` | No hay fecha ni cláusula de expiración. |
| 7.4 | CUMPLE CON RESERVA | `firestore.rules:18-25`; `lib/latency_test_screen.dart:31-45,61-68` | El update permite únicamente pasar `responded` de false a true y escribir `proceso` numérico, modificando solo esos campos. La creación queda abierta (`allow create: if true`), por lo que puede sembrarse un documento ya respondido o mal formado y el “solo esa” no es absoluto extremo a extremo. |
| 7.5 | NO DETERMINABLE | `docs/CHECKLIST-DOBLE-PRUEBA-SPRINT1.md:139` | Requiere comparar la consola publicada. Es comprobación exclusiva de Carlos; Codex no accedió ni publicó Firebase. |

## Bloque 8 — Pruebas, arquitectura, dependencias y compilación

| ID | Veredicto | Evidencia (archivo:línea) | Nota |
|---|---|---|---|
| 8.1 | CUMPLE | `test/baplie_parser_test.dart:1-327`; `test/container_search_delegate_test.dart:1-93`; `test/export_service_test.dart:1-146`; `test/pdf_report_service_test.dart:1-66`; `test/vessel_profile_view_test.dart:1-108`; `test/widget_test.dart:1-25` | Conteo declarado: 21 parser/dominio, 1 búsqueda, 3 exportación, 2 PDF, 3 perfil y 1 widget = 31. |
| 8.2 | CUMPLE CON RESERVA | mismos archivos de `test/` citados en 8.1 | Faltan, entre otros: contenedor sin posición con peso, cero/sin peso, umbral y alineación visual; cinco fichas reales y toque; equivalencia completa pantalla/PDF, 55 páginas, acentos/ñ y respuesta; capacidad real/contraste/responsive; fórmula CSV y saneo límite; entradas grandes/binarias/UTF-8/diagnóstico; reglas Firebase. |
| 8.3 | NO CUMPLE | `test/pdf_report_service_test.dart:17-66`; `test/export_service_test.dart:1-146`; `test/baplie_parser_test.dart:303-327` | PDF comprueba principalmente bytes/encabezado y usa entrada ya ordenada; CSV compara contra la misma forma esperada; el contenedor sin posición no tiene peso; varias pruebas solo esperan cualquier `Exception`. |
| 8.4 | NO CUMPLE | `lib/features/vessel/presentation/providers/vessel_providers.dart:1-16,303-333`; `lib/features/vessel/domain/entities/bay.dart:1-3` | Dominio sí está libre de Flutter, pero presentación importa implementaciones de datos/parser y servicios directamente; la condición conjunta falla. |
| 8.5 | CUMPLE CON RESERVA | `pubspec.yaml:9-34`; `pubspec.lock:579-619` | Estado actual: `pdf: 3.12.0` y no `printing`. Sin comparar un árbol anterior dentro de esta auditoría no se prueba literalmente que haya sido la única dependencia añadida. |
| 8.6 | CUMPLE | `lib/latency_test_screen.dart:1`; `lib/c3_reconciliation_screen.dart:1`; `lib/main.dart:1` | La inspección histórica previa del worktree situó los dos H5 y `main.dart` antes del Sprint 1; no apareció `firebase_options.dart`. No se tocaron durante esta auditoría. |
| 8.7 | CUMPLE | salida completa en “Anexo B” | `flutter test --reporter expanded`: exit 0, 31 pruebas, `All tests passed!`. |
| 8.8 | CUMPLE CON RESERVA | salida completa en “Anexo A”; `analysis_options.yaml:9,21-22`; `test/widget_test.dart:1` | Se confirman 49 *issues*, sin aumento numérico frente a la bitácora. Son 4 `warning` y 45 `info`; sin una salida basal serializada no puede atribuirse individualmente “ninguna nueva”. |
| 8.9 | CUMPLE | comandos ejecutados en este worktree | `flutter build windows --debug`, `flutter build apk --debug` y `flutter build web` terminaron con exit 0. Windows emitió avisos LNK4099 de PDB; APK emitió nota Java de operaciones no comprobadas. |
| 8.10 | CUMPLE | `docs/qa-sprint1/capturas/windows-lista-corpus-a01.jpg`; `docs/qa-sprint1/capturas/windows-bay-plan-bay01.jpg`; `docs/qa-sprint1/capturas/windows-estadisticas-resumen.jpg` | En Windows se recorrieron Lista, Bay Plan y Estadísticas con A01. El ANR Android se registra separadamente en 1.8. |

## Hallazgos dinámicos adicionales

- Android API 36.1: tocar Bay Plan con A01 produjo un ANR persistente. Elegir “Wait” y esperar otros 8 segundos no recuperó la interfaz (`docs/qa-sprint1/capturas/android-anr-bay-plan.png` y `docs/qa-sprint1/capturas/android-anr-bay-plan-after-wait.png`).
- El selector PDF de Android sí apareció tras aproximadamente 12 segundos y propuso `BayStream_BUQUE ALFA_V01N.pdf` (`docs/qa-sprint1/capturas/android-selector-pdf.png`).
- Web: PDF completado en aproximadamente 4.2 segundos en una ejecución medida; el navegador mostró la confirmación de exportación.
- Excel con configuración regional en español abrió el asistente de importación; hubo que desmarcar tabulación y seleccionar coma. Tras ello mostró 24 columnas y 977 filas.

## Anexo A — Salida completa de `flutter analyze`

```text
Resolving dependencies...
Downloading packages...
  _fe_analyzer_shared 91.0.0 (105.0.0 available)
  _flutterfire_internals 1.3.76 (1.3.77 available)
  analyzer 8.4.1 (14.1.0 available)
  analyzer_buffer 0.1.11 (0.3.3 available)
  archive 4.0.9 (4.2.0 available)
  async 2.13.0 (2.13.1 available)
  build 4.0.4 (4.0.10 available)
  build_config 1.2.0 (1.3.2 available)
  build_daemon 4.1.1 (4.1.5 available)
  build_runner 2.10.5 (2.16.0 available)
  built_value 8.12.3 (8.12.7 available)
  characters 1.4.0 (1.4.1 available)
  cloud_firestore 6.8.0 (6.9.0 available)
  cloud_firestore_platform_interface 8.0.6 (8.0.7 available)
  cloud_firestore_web 5.7.2 (5.7.3 available)
  coverage 1.15.0 (1.15.1 available)
  cross_file 0.3.5+2 (0.3.5+5 available)
  cupertino_icons 1.0.8 (1.0.9 available)
  dart_style 3.1.3 (3.1.12 available)
  dbus 0.7.11 (0.7.15 available)
  equatable 2.0.8 (2.1.0 available)
  ffi 2.1.5 (2.2.0 available)
  file_picker 10.3.10 (12.1.0 available)
  firebase_core 4.13.0 (4.14.0 available)
  firebase_core_platform_interface 8.1.0 (8.1.1 available)
  firebase_core_web 3.10.0 (3.11.0 available)
  flutter_plugin_android_lifecycle 2.0.33 (2.0.35 available)
  flutter_riverpod 3.1.0 (3.4.2 available)
  intl 0.20.2 (0.20.3 available)
  json_annotation 4.10.0 (4.12.0 available)
  matcher 0.12.17 (0.12.20 available)
  material_color_utilities 0.11.1 (0.13.1 available)
  meta 1.17.0 (1.19.0 available)
  mockito 5.6.3 (5.8.1 available)
  package_config 2.2.0 (3.0.0 available)
  pdf 3.12.0 (3.13.0 available)
  petitparser 7.0.1 (7.0.2 available)
  qr 3.0.2 (4.0.0 available)
  riverpod 3.1.0 (3.4.2 available)
  riverpod_analyzer_utils 1.0.0-dev.8 (1.0.0-dev.11 available)
  riverpod_annotation 4.0.0 (4.0.6 available)
  riverpod_generator 4.0.0+1 (4.0.8 available)
  source_gen 4.2.0 (4.3.0 available)
  source_maps 0.10.13 (0.10.14 available)
  source_span 1.10.1 (1.10.2 available)
  test 1.26.3 (1.31.2 available)
  test_api 0.7.7 (0.7.13 available)
  test_core 0.6.12 (0.6.19 available)
  uuid 4.5.2 (4.6.0 available)
  vector_math 2.2.0 (2.4.2 available)
  vm_service 15.0.2 (15.3.0 available)
  win32 5.15.0 (6.4.0 available)
  xml 6.6.1 (7.0.1 available)
Got dependencies!
53 packages have newer versions incompatible with dependency constraints.
Try `flutter pub outdated` for more information.
Analyzing baystream-qa-codex...                                 

warning - 'avoid_returning_null_for_future' was removed in Dart '3.3.0' - analysis_options.yaml:9:7 - removed_lint
warning - 'iterable_contains_unrelated_type' was removed in Dart '3.3.0' - analysis_options.yaml:21:7 - removed_lint
warning - 'list_remove_unrelated_type' was removed in Dart '3.3.0' - analysis_options.yaml:22:7 - removed_lint
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\features\vessel\presentation\pages\vessel_overview_page.dart:396:22 - deprecated_member_use
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\features\vessel\presentation\pages\vessel_overview_page.dart:398:41 - deprecated_member_use
   info - Statements in an if should be enclosed in a block - lib\features\vessel\presentation\providers\vessel_providers.dart:350:25 - curly_braces_in_flow_control_structures
   info - Statements in an if should be enclosed in a block - lib\features\vessel\presentation\providers\vessel_providers.dart:351:30 - curly_braces_in_flow_control_structures
   info - Statements in an if should be enclosed in a block - lib\features\vessel\presentation\providers\vessel_providers.dart:352:30 - curly_braces_in_flow_control_structures
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\features\vessel\presentation\widgets\bay_plan_view.dart:299:46 - deprecated_member_use
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\features\vessel\presentation\widgets\bay_plan_view.dart:521:36 - deprecated_member_use
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\features\vessel\presentation\widgets\bay_plan_view.dart:558:37 - deprecated_member_use
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\features\vessel\presentation\widgets\bay_plan_view.dart:766:40 - deprecated_member_use
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\features\vessel\presentation\widgets\container_search_delegate.dart:158:51 - deprecated_member_use
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\features\vessel\presentation\widgets\container_search_delegate.dart:290:67 - deprecated_member_use
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\features\vessel\presentation\widgets\container_search_delegate.dart:303:73 - deprecated_member_use
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\features\vessel\presentation\widgets\container_search_delegate.dart:414:53 - deprecated_member_use
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\features\vessel\presentation\widgets\container_search_delegate.dart:441:30 - deprecated_member_use
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\features\vessel\presentation\widgets\container_search_delegate.dart:470:46 - deprecated_member_use
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\features\vessel\presentation\widgets\containers_list_view.dart:73:40 - deprecated_member_use
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\features\vessel\presentation\widgets\containers_list_view.dart:103:56 - deprecated_member_use
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\features\vessel\presentation\widgets\containers_list_view.dart:105:75 - deprecated_member_use
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\features\vessel\presentation\widgets\containers_list_view.dart:137:45 - deprecated_member_use
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\features\vessel\presentation\widgets\containers_list_view.dart:139:64 - deprecated_member_use
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\features\vessel\presentation\widgets\containers_list_view.dart:164:46 - deprecated_member_use
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\features\vessel\presentation\widgets\containers_list_view.dart:166:65 - deprecated_member_use
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\features\vessel\presentation\widgets\containers_list_view.dart:189:42 - deprecated_member_use
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\features\vessel\presentation\widgets\containers_list_view.dart:191:61 - deprecated_member_use
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\features\vessel\presentation\widgets\containers_list_view.dart:315:22 - deprecated_member_use
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\features\vessel\presentation\widgets\containers_list_view.dart:317:41 - deprecated_member_use
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\features\vessel\presentation\widgets\empty_state_widget.dart:28:53 - deprecated_member_use
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\features\vessel\presentation\widgets\empty_state_widget.dart:62:60 - deprecated_member_use
   info - Use 'const' with the constructor to improve performance - lib\features\vessel\presentation\widgets\voyage_stats_view.dart:42:11 - prefer_const_constructors
   info - Use 'const' with the constructor to improve performance - lib\features\vessel\presentation\widgets\voyage_stats_view.dart:52:11 - prefer_const_constructors
   info - Use 'const' with the constructor to improve performance - lib\features\vessel\presentation\widgets\voyage_stats_view.dart:59:13 - prefer_const_constructors
   info - Use 'const' with the constructor to improve performance - lib\features\vessel\presentation\widgets\voyage_stats_view.dart:67:13 - prefer_const_constructors
   info - Use 'const' with the constructor to improve performance - lib\features\vessel\presentation\widgets\voyage_stats_view.dart:80:13 - prefer_const_constructors
   info - Use 'const' with the constructor to improve performance - lib\features\vessel\presentation\widgets\voyage_stats_view.dart:107:13 - prefer_const_constructors
   info - Use 'const' with the constructor to improve performance - lib\features\vessel\presentation\widgets\voyage_stats_view.dart:115:13 - prefer_const_constructors
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\features\vessel\presentation\widgets\voyage_stats_view.dart:244:39 - deprecated_member_use
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\features\vessel\presentation\widgets\voyage_stats_view.dart:253:30 - deprecated_member_use
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\features\vessel\presentation\widgets\voyage_stats_view.dart:567:20 - deprecated_member_use
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\features\vessel\presentation\widgets\voyage_stats_view.dart:570:39 - deprecated_member_use
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\features\vessel\presentation\widgets\voyage_stats_view.dart:636:30 - deprecated_member_use
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\features\vessel\presentation\widgets\voyage_stats_view.dart:696:38 - deprecated_member_use
   info - Unnecessary use of string interpolation - lib\features\vessel\presentation\widgets\voyage_stats_view.dart:862:43 - unnecessary_string_interpolations
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\features\vessel\presentation\widgets\voyage_summary_card.dart:21:43 - deprecated_member_use
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\features\vessel\presentation\widgets\voyage_summary_card.dart:25:38 - deprecated_member_use
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss - lib\features\vessel\presentation\widgets\voyage_summary_card.dart:195:26 - deprecated_member_use
warning - Unused import: 'package:flutter/material.dart' - test\widget_test.dart:1:8 - unused_import

49 issues found. (ran in 5.9s)
```

## Anexo B — Salida completa de `flutter test --reporter expanded`

```text
Resolving dependencies...
Downloading packages...
  _fe_analyzer_shared 91.0.0 (105.0.0 available)
  _flutterfire_internals 1.3.76 (1.3.77 available)
  analyzer 8.4.1 (14.1.0 available)
  analyzer_buffer 0.1.11 (0.3.3 available)
  archive 4.0.9 (4.2.0 available)
  async 2.13.0 (2.13.1 available)
  build 4.0.4 (4.0.10 available)
  build_config 1.2.0 (1.3.2 available)
  build_daemon 4.1.1 (4.1.5 available)
  build_runner 2.10.5 (2.16.0 available)
  built_value 8.12.3 (8.12.7 available)
  characters 1.4.0 (1.4.1 available)
  cloud_firestore 6.8.0 (6.9.0 available)
  cloud_firestore_platform_interface 8.0.6 (8.0.7 available)
  cloud_firestore_web 5.7.2 (5.7.3 available)
  coverage 1.15.0 (1.15.1 available)
  cross_file 0.3.5+2 (0.3.5+5 available)
  cupertino_icons 1.0.8 (1.0.9 available)
  dart_style 3.1.3 (3.1.12 available)
  dbus 0.7.11 (0.7.15 available)
  equatable 2.0.8 (2.1.0 available)
  ffi 2.1.5 (2.2.0 available)
  file_picker 10.3.10 (12.1.0 available)
  firebase_core 4.13.0 (4.14.0 available)
  firebase_core_platform_interface 8.1.0 (8.1.1 available)
  firebase_core_web 3.10.0 (3.11.0 available)
  flutter_plugin_android_lifecycle 2.0.33 (2.0.35 available)
  flutter_riverpod 3.1.0 (3.4.2 available)
  intl 0.20.2 (0.20.3 available)
  json_annotation 4.10.0 (4.12.0 available)
  matcher 0.12.17 (0.12.20 available)
  material_color_utilities 0.11.1 (0.13.1 available)
  meta 1.17.0 (1.19.0 available)
  mockito 5.6.3 (5.8.1 available)
  package_config 2.2.0 (3.0.0 available)
  pdf 3.12.0 (3.13.0 available)
  petitparser 7.0.1 (7.0.2 available)
  qr 3.0.2 (4.0.0 available)
  riverpod 3.1.0 (3.4.2 available)
  riverpod_analyzer_utils 1.0.0-dev.8 (1.0.0-dev.11 available)
  riverpod_annotation 4.0.0 (4.0.6 available)
  riverpod_generator 4.0.0+1 (4.0.8 available)
  source_gen 4.2.0 (4.3.0 available)
  source_maps 0.10.13 (0.10.14 available)
  source_span 1.10.1 (1.10.2 available)
  test 1.26.3 (1.31.2 available)
  test_api 0.7.7 (0.7.13 available)
  test_core 0.6.12 (0.6.19 available)
  uuid 4.5.2 (4.6.0 available)
  vector_math 2.2.0 (2.4.2 available)
  vm_service 15.0.2 (15.3.0 available)
  win32 5.15.0 (6.4.0 available)
  xml 6.6.1 (7.0.1 available)
Got dependencies!
53 packages have newer versions incompatible with dependency constraints.
Try `flutter pub outdated` for more information.
00:00 +0: loading C:/Proyectos/baystream-qa-codex/test/baplie_parser_test.dart
00:00 +0: C:/Proyectos/baystream-qa-codex/test/baplie_parser_test.dart: IsoCoordinateParser debe parsear coordenada ISO válida 0120006
00:00 +1: C:/Proyectos/baystream-qa-codex/test/baplie_parser_test.dart: IsoCoordinateParser debe parsear coordenada 0010102
00:00 +2: C:/Proyectos/baystream-qa-codex/test/baplie_parser_test.dart: IsoCoordinateParser debe parsear coordenada con valores máximos 9999999
00:00 +3: C:/Proyectos/baystream-qa-codex/test/baplie_parser_test.dart: IsoCoordinateParser debe lanzar excepción para coordenada muy corta
00:00 +4: C:/Proyectos/baystream-qa-codex/test/baplie_parser_test.dart: IsoCoordinateParser debe lanzar excepción para coordenada con letras
00:00 +5: C:/Proyectos/baystream-qa-codex/test/baplie_parser_test.dart: IsoCoordinateParser tryParse debe retornar null para coordenada inválida
00:00 +6: C:/Proyectos/baystream-qa-codex/test/baplie_parser_test.dart: IsoCoordinateParser isValid debe validar correctamente
00:00 +7: C:/Proyectos/baystream-qa-codex/test/baplie_parser_test.dart: IsoCoordinateParser fromValues debe crear coordenada correctamente
00:00 +8: C:/Proyectos/baystream-qa-codex/test/baplie_parser_test.dart: IsoCoordinateParser displayFormat debe mostrar formato legible
00:00 +9: C:/Proyectos/baystream-qa-codex/test/baplie_parser_test.dart: BaplieParserService debe parsear archivo BAPLIE básico
00:00 +10: C:/Proyectos/baystream-qa-codex/test/baplie_parser_test.dart: BaplieParserService debe organizar contenedores en bahías
00:00 +11: C:/Proyectos/baystream-qa-codex/test/baplie_parser_test.dart: BaplieParserService debe calcular estadísticas correctamente
00:00 +12: C:/Proyectos/baystream-qa-codex/test/baplie_parser_test.dart: BaplieParserService debe lanzar excepción para contenido vacío
00:00 +13: C:/Proyectos/baystream-qa-codex/test/baplie_parser_test.dart: BaplieParserService debe lanzar excepción si no encuentra TDT
00:00 +14: C:/Proyectos/baystream-qa-codex/test/baplie_parser_test.dart: ContainerUnit debe calcular tamaño en pies correctamente
00:00 +15: C:/Proyectos/baystream-qa-codex/test/baplie_parser_test.dart: ContainerUnit debe identificar tipo de contenedor
00:00 +16: C:/Proyectos/baystream-qa-codex/test/baplie_parser_test.dart: ContainerUnit debe identificar altura correctamente
00:00 +17: C:/Proyectos/baystream-qa-codex/test/baplie_parser_test.dart: ContainerUnit debe calcular peso neto
00:00 +18: C:/Proyectos/baystream-qa-codex/test/baplie_parser_test.dart: Bay debe agregar contenedor y actualizar slot
00:00 +19: C:/Proyectos/baystream-qa-codex/test/baplie_parser_test.dart: Bay debe calcular ocupación correctamente
00:00 +20: C:/Proyectos/baystream-qa-codex/test/baplie_parser_test.dart: Bay debe acumular el peso bruto por nivel
00:00 +21: C:/Proyectos/baystream-qa-codex/test/container_search_delegate_test.dart: muestra las cinco navieras y puertos más frecuentes en orden
00:00 +22: C:/Proyectos/baystream-qa-codex/test/container_search_delegate_test.dart: muestra las cinco navieras y puertos más frecuentes en orden
00:00 +23: C:/Proyectos/baystream-qa-codex/test/container_search_delegate_test.dart: muestra las cinco navieras y puertos más frecuentes en orden
00:00 +24: C:/Proyectos/baystream-qa-codex/test/container_search_delegate_test.dart: muestra las cinco navieras y puertos más frecuentes en orden
00:00 +25: C:/Proyectos/baystream-qa-codex/test/container_search_delegate_test.dart: muestra las cinco navieras y puertos más frecuentes en orden
00:00 +26: C:/Proyectos/baystream-qa-codex/test/container_search_delegate_test.dart: muestra las cinco navieras y puertos más frecuentes en orden
00:02 +27: C:/Proyectos/baystream-qa-codex/test/vessel_profile_view_test.dart: al tocar una bahía informa su número
00:02 +28: C:/Proyectos/baystream-qa-codex/test/widget_test.dart: BayStreamApp debe mostrar título correctamente
00:02 +29: C:/Proyectos/baystream-qa-codex/test/widget_test.dart: BayStreamApp debe mostrar título correctamente
00:02 +30: C:/Proyectos/baystream-qa-codex/test/vessel_profile_view_test.dart: selecciona la bahía y abre su rejilla en Bay Plan
00:03 +31: All tests passed!
```
