# T-58 · Fila 00 por zona y segregación

Base de trabajo: HEAD `d0850c2` al cierre de la implementación; cambios de T-58 aún sin commit. 1-oct-2026. Se ejecutó sin modificar `lib/main.dart`, los dos archivos H5 congelados ni `pubspec.yaml`/`pubspec.lock`; no hay dependencias nuevas.

## Paso 0 · cierre de la revisión Chrome de T-57

Se sirvió el build Web de T-57 en `http://127.0.0.1:8801/` antes de recompilar. `main.dart.js` conservaba SHA-256 `50CD6971D967C30B0A35487C87160C7DAD262DFC2E98E16A67EB49DA1DBFF4B0`. Carlos cargó manualmente `T44_INVALID.edi` y `T57_A01_SIN_NOMBRE_TDT.edi` en Google Chrome y confirmó que ambos mostraron el mensaje en español con causa y acción, sin «Bad state». También aportó dos capturas del mismo resultado en el navegador integrado de Codex. T-57 puede salir de revisión; esta confirmación no modifica su commit `7a034ee`.

## Cambio aplicado

- `VesselGeometry` guarda `centerRowOnDeck` y `centerRowInHold` como `bool?`: `true` existe, `false` no existe, `null` no declarada. `fromJson` lee claves ausentes como `null`, y `copyWith`, igualdad, JSON y copia sin límite conservan las dos declaraciones. `proposeFrom` solo pone `true` en la zona con carga observada en 00. La ausencia de carga deja `null`. Una declaración `false` impide cubrir una posición real en 00.
- El editor permite declarar cada zona por separado. Si este viaje ocupa la 00 en una zona, la opción «No existe» queda deshabilitada. La columna 00 del plano, el cálculo de huecos del dibujo y el PDF permanecen como estaban.
- La segregación solo cuenta la 00 como hueco transversal si ambas zonas implicadas la declaran `true`. Con `false` o `null`, 01 y 02 son vecinas. Una 00 ocupada conserva su posición física en el orden.
- §176.144 se aplica cuando todas las clases y etiquetas del par son 1.x. Para una etiqueta de otra clase se usa la regla más restrictiva; un código 2 gana al `*`. Los tanques ISO `T` siguen como unidades cerradas. La inferencia queda explícita en `_problem`: [49 CFR §176.2, edición oficial 2024](https://www.govinfo.gov/content/pkg/CFR-2024-title49-vol2/pdf/CFR-2024-title49-vol2-sec176-2.pdf) incluye el tanque portátil como unidad de transporte y define «cerrada» por el contenido encerrado en estructuras permanentes; **no afirma expresamente que todo tanque ISO T sea cerrado**. La prueba fija la decisión aceptada por Carlos.

## Sondas T-55 y regresiones

Se ejecutaron los dos scripts originales, sin modificarlos, antes y después, con los seis archivos del corpus en `build/t44/`; salidas comparables en `build/t58/fila_antes.json`, `fila_despues.json`, `tabla_antes.json` y `tabla_despues.json`.

| Caso | Antes | Después |
|---|---|---|
| Cubierta 02/01, fila 00 no declarada | conforme | **posible incumplimiento** (`nonConforming`) |
| Bodega 02/01, fila 00 no declarada | conforme | **no evaluado** (`notEvaluated`): la distancia falta, pero el mamparo podría aportar separación |
| UN0012 con etiqueta 3 / UN0303 | conforme | **posible incumplimiento** |
| UN0012 con etiqueta 5.1 / UN0303 | conforme | **posible incumplimiento** |

La sonda antigua aún calcula `lateralGapCalculado` usando `orderedRows`, que siempre contiene 00 para el dibujo. Ese campo intermedio queda en 1; el **estado del validador** es el resultado corregido y las pruebas nuevas verifican el hueco efectivo. La tabla de 28 pares y las 17 entradas ONU conserva cero discrepancias; el barrido 17 × 17 en cinco configuraciones tiene cero conformes indebidos y los 15 casos sin regla, cero aprobaciones indebidas. Esos casos controlados, tablas y barrido ahora tienen pruebas en `test/`.

## Corpus y panel

| Caso | Resultado T-58 | Comparación |
|---|---|---|
| A01, propuesta del archivo | Segregación: 0 posibles incumplimientos / 0 no evaluados / 6 conformes | Sin cambio en ambas ejecuciones de `t55_fila_central.dart`. |
| A01, viaje histórico de Windows, límite guardado 62 500.5 kg | Panel: **47/0/6** | Igual al bloque 7b. Los 47 son peso por pila. |
| A03, propuesta nueva desde el archivo | Panel de reglas: **2/100/151** | Sin cambio en ambas ejecuciones de `t55_fila_central.dart`. El archivo observa la 00 en cubierta, por lo que la propuesta declara `centerRowOnDeck=true`. |
| A03, viaje y perfil históricos abiertos en Chrome | Panel: **4/98/151** | Cambia respecto a 2/100/151: dos pares pasan de no evaluados a posibles incumplimientos porque el perfil anterior abre con `null`, sin declaración de la 00. |

Los dos pares adicionales del A03 histórico son `PRBU3657820 / WLDU0343265` (`0260184 / 0260284`) y `BYSU8281331 / PRBU3657820` (`0260286 / 0260184`). Ambos cruzan 01/02 en cubierta. Antes, la 00 supuesta aportaba un hueco y los grupos pendientes dejaban el resultado «no evaluado». Ahora no se presume ese hueco y la falta de separación produce el posible incumplimiento. La carga real de A03 sí ocupa la 00 en cubierta; su **propuesta nueva** la declara `true` y conserva 2/100/151. El perfil histórico requiere que el usuario haga esa declaración, como pide la compatibilidad con `null`.

## Compatibilidad de perfiles y binarios

Se abrió el perfil **BUQUE ALFA imo:9000003** guardado antes de T-58 en los tres clientes release, conservando sus almacenes locales. En Windows y Chrome/8786, el editor mostró «Fila 00 en cubierta: No declarada» y «Fila 00 en bodega: No declarada», sin error. En **Honor X5d / Android 15**, el APK se instaló con `adb install -r` (`Success`) y el mismo perfil abrió con ambas declaraciones «No declarada»; evidencia `build/t58/honor-profiles.png` y `build/t58/honor-alfa-profile.png`. No se guardó una modificación sobre esos perfiles.

Compilaciones release completadas sobre el mismo código de producto (después solo cambiaron pruebas):

| Cliente | Binario medido | SHA-256 |
|---|---|---|
| Windows | `build/windows/x64/runner/Release/data/app.so` | `BB35E721AFD9DA14E8E467885B9F95FDF0BB23078EF2A9CB7EEA303831B1D536` |
| Web | `build/web/main.dart.js` | `D590B282D1523FCF87447B2ACE15DE95976DC3FBA9F5C017A25A9ED99305632B` |
| Android | `build/app/outputs/flutter-apk/app-release.apk` | `3D6625FBBDA6AF1D2F9CB2E79A385B0FAC177E5AF7FF7E5CAF853135782869CA` |

## Pruebas y análisis

- Última suite completa: `00:11 +272: All tests passed!` (`flutter test --no-pub --reporter expanded`). Una corrida previa terminó con un `pumpAndSettle timed out` intermitente en `recent_voyages_test.dart`, archivo no modificado; la repetición completa pasó.
- Último análisis: `No issues found! (ran in 4.8s)` (`flutter analyze --no-pub`).
- La compilación Web emitió las advertencias habituales del ensayo Wasm y de `CupertinoIcons`; `flutter analyze` quedó en cero.

Archivos de T-58: `lib/features/vessel/domain/entities/vessel_geometry.dart`, `lib/features/vessel/domain/services/dangerous_goods_validator.dart`, `lib/features/vessel/presentation/pages/vessel_geometry_page.dart`, `test/vessel_geometry_test.dart`, `test/dangerous_goods_validator_test.dart`, `test/vessel_geometry_page_test.dart` y este informe. No se crearon scripts `tool/t58_*.dart`; se reutilizaron, sin editarlos, las dos sondas T-55.
