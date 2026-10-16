# T-85 · Segregación con el Código IMDG 42-24

**Estado: IMPLEMENTADA, EN REVISIÓN.** Implementación versionada por Carlos en ac72849. Antes de aceptar, **Gru debe revisar los datos contra el PDF y después Timonel hace la aceptación cruzada**, como manda 10.69. La revisión visual Web quedó completada en el **navegador integrado de Codex**, autorizado por Carlos en 10.70; se documenta en 6.1, sin afirmar una prueba en Chrome. Sigue pendiente la observación de repintado de la matriz en Windows descrita en la sección 6.

## 1. Base, aislamiento y alcance

16-oct-2026. Base **`93dc695662686d53cb9a09c161f5d4ae4bb4e896`**, copia nueva de 631 archivos versionados en `%TEMP%\baystream-codex-20261016\t85acc`, obtenida con `git ls-files` y `git show`. Independiente de la aceptación T-95; no se esperó un commit. Leídos AGENTS completo, restricciones/definición de terminado, decisiones 10.55 y 10.59–10.69, fichas T-85/T-95 y docs/T95-RESULTADOS.md.

Solo se leyeron los dos CSV IMDG autorizados, para generar y cotejar **códigos funcionales**. Ningún CSV, PDF o pasaje del IMDG entra al repositorio. Las salidas completas del corpus, las transcripciones, los bancos con assets, APK, ejecutable, Web, XML y capturas se mantienen en TEMP. **No se abrió firebase-prod.json ni key.properties.** Las compilaciones reciben el primero por `--dart-define-from-file`.

**pubspec.yaml y pubspec.lock del árbol no cambian; no hay dependencias nuevas.** Assets de A03, su entrada pubspec y applicationId `.t85acc` son exclusivos de la copia. Namespace `t85acc`, sesión local sin cuenta. No se usaron Firebase CLI/consola, cuentas, reglas desplegadas ni publicaciones.

## 2. Implementación

- `imdg_42_24_data.dart`: 17 clases, 289 códigos de 7.2.4; 12 reglas verticales y 48 horizontales de 7.4.3.2. Solo códigos, enums y referencias. La .3 vertical abierta/abierta usa cubierta separadora, conforme a la resolución de Carlos en 10.60.
- `segregation_rules.dart`: desaparecen los perfiles ONU y sus excepciones de 49 CFR. La clase procede de DGS. Agrupa 1.1/1.2/1.5, 1.3/1.6 y 1.4, con o sin letra de compatibilidad. X nunca declara conformidad; * remite a 7.2.7.1.
- `dangerous_goods_validator.dart`: toma el riesgo principal y un secundario declarado, escoge la exigencia numérica más alta (7.2.3.3), y trata un secundario de clase 1 como 1.3. Dos secundarios distintos requieren la Lista/16b (7.2.3.4). Una combinación X junto con otra numérica conserva el aviso de la Lista al evaluar el número. Los permisos de grupos, secundarios y excepciones no se deducen del número ONU. Dos sustancias de la misma unidad con exigencia numérica fallan (7.2.3.2).
- Posición: misma vertical por fila y huellas que se tocan, reutilizando la función pura de T-95, sin calcular pares. Conserva longitudinalGap/lateralGap del modelo de huecos; 00 solo declarada u observada en la bahía y zona del par. Basta uno de los ejes permitidos. Las alternativas de mamparo sin dato quedan NE. La exigencia 4 no permite resolver por el transversal.
- Supuestos 10.67: G/R/T/B/V/H cerradas, U/P abiertas, tercer carácter de ISO leído en el servicio; otros tipos o sin tipo quedan NE. También se conserva un diagnóstico individual de tipo desconocido aunque solo haya una DGS (A05/A06, 22K2). Tapa como cubierta entre zonas para 1/2, con el supuesto y la cita 7.4.2.2 escritos en el resultado; 3/4 entre zonas quedan NE. Bodega abierta no separa y se remite al caso fuera de alcance 7.4.3.3. 24 m se rotulan como aproximación de cuatro huecos longitudinales.
- Presentación: fuente IMDG 42-24 en segregación y alertas; matriz expandible de 17 clases con leyenda y desplazamiento horizontal; cada resultado conserva sus apartados. Material 3 y colores del tema. Listas de resultados perezosas.

**Integración necesaria que no estaba nombrada en la lista de la ficha:** `segregation_provider.dart` pasa las tapas del **perfil publicado** al validador. Antes solo pasaba contenedores y geometría, por lo que una bodega abierta no podía llegar al servicio desde las pantallas. Es el único puente añadido; una prueba exige recalcular cuando cambian solo las tapas y conservar la instantánea visible. No se cambian modelo, lector, codec, ni proveedores de viaje. También se actualizan las expectativas de fuente en las dos pruebas de pantalla existentes.

## 3. Datos y comprobador privado

**Resultado final: 289/289 y 60/60, salida 0.** Registro `t85-private-check-final.log` en TEMP. Se ejecutó al construir los datos y al terminar; no hubo discrepancias del comprobador.

`tool/t85_tabla_privada.dart` recibe ambas rutas como argumentos, lee CSV con comillas/BOM/CRLF, verifica cabeceras, coordenadas, duplicados y tamaño completo. Compara cada celda. Traduce las prescripciones mediante una **tabla cerrada de catorce huellas SHA-256 del texto normalizado a códigos**: texto desconocido falla. Las huellas permiten que el propio comprobador no publique pasajes del IMDG. No lee notas privadas ni forma parte de flutter test.

Datos entregados, SHA-256 **`6fc226831e9a23b202a20ecc302d28515c01bf6e84719a35846d5b6992e1b899`**. Reglas, SHA-256 **`99085f2ed738b7ec3fd3d5519af89e6e29540fb4cf124583dd1065cba9e613e4`**. Gru debe revisar el significado de estos códigos contra el PDF; este cotejo de CSV no sustituye esa tercera lectura.

Reproducción del comprobador, con salida fuera del repo:

```powershell
dart run tool/t85_tabla_privada.dart C:\Proyectos\baystream-privado\imdg\yov_7-2-4.csv C:\Proyectos\baystream-privado\imdg\yov_7-4-3-2.csv > "$env:TEMP\t85-tabla-privada.log"
```

Las búsquedas exigidas en lib/test/tool no encuentran ninguna de las dos frases prohibidas; `t85-forbidden-search.log` está vacío, rg sale 1. También sin `// ignore:`. No quedan perfiles ONU de la fuente anterior en el validador ni en su herramienta de tabla. docs/T41-SEGREGACION-FUENTE.md queda intacto como historia.

## 4. Pruebas y compilaciones ejecutadas

**Todas en la copia aislada, no en el árbol compartido.** Lo colocado tiene exactamente los mismos SHA que la copia validada.

| Comprobación | Resultado | Registro en TEMP |
|---|---|---|
| Suite completa, base 866 + 28 nuevas | **894/894** | `t85-suite-final.log` |
| Casos IMDG nuevos | 25 de dominio + 3 de interfaz/proveedor, dentro de la suite | `test/t85_*` |
| Matriz/pantalla tras el último ajuste de recorte | **3/3**, claro/oscuro, 360 dp, 1.45 | `t85-page-final.log` |
| Analyze final | **0 incidencias**, sin ignore | `t85-analyze-final.log` |
| Corpus completo, 36 archivos | **157/157**: 147 previas + 10 de T-85 | `t85-corpus-final.log` |
| Comprobador privado | **289/289; 60/60**, salida 0 | `t85-private-check-final.log` |
| Windows / Android / Web release | **0 / 0 / 0** | `t85-build-*-final.log` |
| Herramientas históricas | salida 0 en tabla, fila central, T-42, block7b y trazas | `t85-t55-tabla.json`, `t85-fila-central.json`, `t85-t42.json`, `t85-block7b.json`, `t85-trazas.json` |

Se conservan las **26 pruebas** de dangerous_goods_validator_test: dos de lector/codec se conservan y 24 se adaptan al contrato nuevo. Se reemplazan las expectativas de perfiles ONU, grupos S/G, aerosol como clase 9 y secundarios inferidos; no se borra ni se omite ninguna prueba. Las cuatro pruebas de segregación y seis de alertas siguen dentro del piso, con la fuente nueva. Las 28 nuevas comprueban los casos de la ficha, todos los tipos, datos completos/simetría, prioridad con X/*, secundarios, huecos/huellas, 24 m, mamparos y tapas. Una cubre el ISO desconocido solitario para que no desaparezca el aviso de A05/A06.

`block7_checks.dart` pasa a exigir 3/8 = X para UN3084 sin 5.1 declarado, y la exigencia 2 para UN1950/UN3085 en vertical. `t55_tabla_segregacion.dart` ahora barre por 17 clases y tres disposiciones (**867 evaluaciones**), sin perfiles ONU; el cotejo de datos fuente es el comprobador privado. `block7b_corpus.dart` y `t55_trazas.dart` no necesitaban cambios de código: sus salidas se recalculan con el servicio y se ejecutaron.

Advertencias de compilación conservadas en logs: MSBuild por TEMP y deprecaciones Android/Web; sin errores. No se ejecutó flutter test para Chrome ni se alteraron binarios del build del repositorio. Las primeras iteraciones ajustaron expectativas antiguas y errores propios del banco de pruebas; los resultados de arriba son los finales ejecutados.

## 5. Corpus: cada cambio explicado

`tool/t85_corpus_diff.dart` exportó primero el validador de HEAD sin modificar a `t85-before.json`, y después la implementación final a `t85-after.json`. Las dos salidas están en TEMP. El cruce usa identidad/posición, distingue diagnóstico individual de par y conserva la multiplicidad de los DGS repetidos. A03v_VGM y A08v_VGM se listan por separado, aunque repitan resultado.

**650 resultados anteriores trazados; 640 resultados finales.** Todos cambian al menos su explicación/fuente. **313 cambian de estado o de emisión; 337 conservan estado.** Los diez retirados son diagnósticos de ONU antes fuera del subconjunto, todos de A07; sus pares permanecen. **0 cambios sin explicar.** A05/A06 conservan NE por 22K2. No hubo que cambiar el modelo DGS.

Orden de las ternas: **(NC, NE, C)**; C significa exclusivamente conforme en las reglas evaluadas.

| Fuente | 49 CFR anterior | IMDG 42-24 final |
|---|---|---|
| A01 | (0, 0, 6) | (0, 6, 0) |
| A02 | (0, 0, 3) | (0, 1, 2) |
| A03 | (2, 100, 151) | (4, 154, 95) |
| A03v_VGM | (2, 100, 151) | (4, 154, 95) |
| A04 | (0, 0, 1) | (0, 1, 0) |
| A05 | (0, 1, 0) | (0, 1, 0) |
| A06 | (0, 1, 0) | (0, 1, 0) |
| A07 | (0, 115, 15) | (0, 120, 0) |
| A08 | (0, 0, 1) | (0, 1, 0) |
| A08v_VGM | (0, 0, 1) | (0, 1, 0) |

En A03 los dos incumplimientos anteriores siguen: 0020386/0030586 y 0260184/0270384. Se añaden dos por conservar la clase 2.1 declarada de UN1950: 0260184/0260186 (vertical) y 0260186/0270384 (sin hueco); la variante VGM repite esos dos. No se importó la excepción ONU de la fuente anterior.

La leyenda siguiente es la razón concreta de **cada fila** del anexo. No se agrupan ni descartan los pares repetidos: cada índice anterior aparece una vez. Los textos completos, clases, ISO, ONU, referencias y magnitudes de los huecos permanecen en las exportaciones de TEMP para el cotejo.

| Código | Razón del resultado nuevo frente al anterior | Filas |
|---|---|---|
| X | 7.2.4 da X: requiere la Lista y su columna 16b (7.2.3.1); la posición no basta. Se deja de aprobar X por un perfil ONU de 49 CFR. | 426 |
| A | 7.2.4 da *: la compatibilidad de clase 1 se remite a 7.2.7.1. No se deduce un permiso S/G por número ONU. | 12 |
| D | Se retira el diagnóstico individual de ONU fuera del subconjunto anterior: su clase declarada existe en 7.2.4. Sus pares permanecen listados; no se pierde ningún DGS ni se infiere un riesgo por número ONU. | 10 |
| U | Tipo ISO 22K2 desconocido según 10.67: se conserva un diagnóstico individual no evaluado aunque sea la única DGS. Cita 7.4.3.2. | 2 |
| C2 | Exigencia 2 entre cubierta y bodega: satisfecha con el supuesto explícito de tapa de 10.67 y la cita 7.4.2.2. | 2 |
| V2 | Exigencia 2 en una misma pila y zona: falta cubierta separadora (7.4.3.2). UN1950 usa su 2.1 declarada, sin la excepción ONU anterior. | 2 |
| F2 | Exigencia 2: ninguno de los sentidos aporta un hueco completo entre huellas (7.4.3.2). UN1950 conserva 2.1; no se agregan secundarios o grupos por ONU. | 6 |
| H1L | Exigencia 1, unidades cerradas: la alternativa longitudinal no impone separación (7.4.3.2). Solo clase y secundarios declarados, sin añadir perfiles o grupos ONU; la Lista 16b sigue fuera de alcance. | 28 |
| H2L | Exigencia 2 satisfecha por un hueco longitudinal entre huellas (7.4.3.2). Solo riesgos declarados; no se infiere 5.1 de UN3084 ni grupos por ONU. La Lista 16b sigue fuera de alcance. | 134 |
| H2T | Exigencia 2 satisfecha por un hueco transversal (7.4.3.2), incluyendo 00 solo declarada u observada. Solo riesgos declarados; sin inferencias de perfiles ONU. La Lista 16b sigue fuera de alcance. | 28 |

## 6. Clientes y cierre

**Windows:** banco local t85acc abierto siempre mediante Explorer, una instancia a la vez, y cerrado por PID. A03 abre con 369 contenedores. La pantalla de segregación muestra la fuente nueva, **4 posibles incumplimientos / 154 no evaluados / 95 conformes evaluados**, la leyenda, matriz y X de clase 9. Las tarjetas muestran la razón y sus apartados. Alertas de estiba muestra la misma fuente y los cuatro incumplimientos primero, incluidos los dos pares de UN1950. Capturas `windows-t85-final-source.jpg`, `windows-t85-final-alerts.jpg` y `windows-t85-*matrix*.jpg`.

**Observación visual Windows, NO resuelta:** al usar la rueda horizontal de la automatización en la matriz, la captura deja rastros de algunos glifos; un desplazamiento vertical los limpia. Ocurrió incluso con aislamiento/recorte de la tabla y fondo opaco. No se aisló si el origen es la captura o el repintado de la app, y no se declara corregido. La matriz inicial y las tarjetas se leen; los 289 datos coinciden y el Honor desplaza la matriz sin reproducir el rastro. Timonel debe verificarlo con el mouse en la aceptación. No es una discrepancia de las tablas ni exige cambiar DGS.

**Honor, 360 dp:** 720×1600, densidad 320. Letra **1.45**, autorizada por ADB en el modo siesta, en claro y oscuro. Fuente, resumen 4/154/95 y tarjetas con referencias legibles, sin cortes. Matriz expandida y desplazada con el dedo hasta la columna 9, con X en todas sus filas visibles; captura limpia en `honor-t85-light-matrix-class9.png`. Evidencias de fuente/resultados `honor-t85-light-*` y `honor-t85-dark-*`. XML sanitizado en memoria; no apareció ni se guardó un formulario de acceso. Se restaura a **1.0** y se detienen `.t85acc` y `.t95cx`; los pidof quedan vacíos.

**Web:** revisión visual completada por autorización 10.70, en el integrado de Codex. La limitación inicial de acceso al integrado de Claude queda superada por esta autorización; detalles en 6.1.

**Almacén real Windows:** `C:\Users\Giova\AppData\Local\BayStream`. Huellas tomadas fuera del paquete por BAT lanzados con Explorer, con cadena de padres en el JSON. **462 → 474; los 462 anteriores idénticos, 0 modificados, 0 borrados, 0 errores; solo 12 nuevos `t85acc_*`** (seis parejas hive/lock en vessel_store). Se incluyen los 12 t95cx previos entre los preservados. Evidencias `store-t85-before.json`, `store-t85-after.json`, `t85-store-comparison.json`, PIDs en `t85-windows-process-*.json` y cierre en `cleanup.json`. Ningún almacén ajeno se borró.

### 6.1. Revisión visual Web · decisión 10.70

16-oct-2026, 15:23–15:24, Guatemala. Se sirvió **la compilación existente de la copia t85acc**, base 93dc695 con la implementación entregada en ac72849, en `http://127.0.0.1:8185/`, mediante Python limitado a loopback. Se utilizó el **navegador integrado de Codex**, visible, contenido 1092×871, tema claro y modo sin cuenta. Es la sustitución autorizada por Carlos en 10.70, con la regla de 10.55; **no es una aceptación en Chrome**.

El banco abrió **A03, 369 contenedores**, y la pantalla del producto mostró:

- Título «Segregación · IMDG» y fuente **Código IMDG, Enmienda 42-24 (7.2.4 y 7.4.3.2)**, con el alcance, la prioridad de la Lista/16b (7.2.3.1) y la explicación de distancias derivadas de huecos.
- **4 posibles incumplimientos / 154 no evaluados / 95 conformes en las reglas evaluadas**, coincidentes con el corpus y los otros clientes.
- Leyenda de códigos y entrada «Ver matriz de 17 clases»; tarjetas legibles con posición, clase, razón y apartados. Las primeras muestran X como «No evaluado: consultar la Lista de mercancías peligrosas», con referencias 7.2.4 y 7.2.3.1.

Evidencia en `%TEMP%\baystream-codex-20261016\web-1070\`: `t85-a03-source-results.png` y `t85-a03-source-results-ax.txt`. SHA-256 de `t85acc/build/web/main.dart.js`: `d2562678efd24825e184974c35928816d4a1c584d5e8d82539041fc96969f184`.

**Sin cambios de código ni comandos Flutter en esta continuación**, sin dispositivos ni app Windows. La guardia de 338 archivos de lib/test/tool, pubspec.* y configuración pública no registra diferencias (`source-before.json`, `source-after.json`, `web-close-and-guard.json`). Las cifras de suite, corpus y comprobador de las secciones anteriores corresponden a las validaciones originales, no se volvieron a ejecutar para esta revisión visual. Pestaña cerrada y servidor detenido; puertos 8185 y 8195 sin escucha al cerrar ambas revisiones.

La Web solicitada queda comprobada. **No se reevaluó el desplazamiento de la matriz en Windows**: esa observación sigue abierta para Timonel. También siguen pendientes Gru contra el PDF y la aceptación cruzada posterior; esta revisión Web no los sustituye.

## 7. Archivos exactos y guardia SHA

**19 rutas de código/bancos/pruebas + este informe = 20 archivos de T-85.** Doce rutas versionadas modificadas y siete nuevas; este informe es nuevo. `t85-delivery-placed.json` exige igualdad byte a byte entre lo probado y lo colocado. Los cuatro documentos binarios que ya aparecen modificados en git diff --stat eran cambios previos: su huella se conserva y no entran en esta entrega ni en sus comandos.

| Ruta entregada | SHA-256 |
|---|---|
| `lib/features/vessel/domain/services/dangerous_goods_validator.dart` | `0495b9a98716b26184a1df84d4812c5b0da8c8d4eaaa01987938d5cc59ec9a06` |
| `lib/features/vessel/domain/services/segregation_rules.dart` | `99085f2ed738b7ec3fd3d5519af89e6e29540fb4cf124583dd1065cba9e613e4` |
| `lib/features/vessel/presentation/pages/segregation_page.dart` | `97f141694162141908658f9d4cd17e30502c7bca22b0b5faa8cbadfd197eb476` |
| `lib/features/vessel/presentation/pages/stowage_alerts_page.dart` | `4732fe60fef7558b42df68fbafdf7d715b61ed1b9f42fdfd0e5384e28c5bbab9` |
| `lib/features/vessel/presentation/providers/segregation_provider.dart` | `c390dba89e3a605505b661e5dc6fd49299e75efea7c361b4c1dc96721d88b49f` |
| `test/dangerous_goods_validator_test.dart` | `8cc866a3398158643368c7fa4917149268ade59f69ac4a998100adb0d81a0907` |
| `test/segregation_page_test.dart` | `617a1a4fc4956abe22399a874d2a4a47885845e0e07c3b4aefeaf8721b926955` |
| `test/stowage_alerts_page_test.dart` | `7df8ea54cb8d98a5f3b9121e0dad1e918bebf9f8e09de2277d1cc8bcfabf62b3` |
| `tool/block7_checks.dart` | `0e0a0ab5769539e49f3912a7cd6a6f37f10d789eb09875a739ccfcb92321bbb8` |
| `tool/t42_aceptacion.dart` | `f861e331ef7021442e93c34327c3e503385a09cae7d244da5e8c1e9446aa07bd` |
| `tool/t55_fila_central.dart` | `177b08e46481e10e7dd2a752502aadcda08b1f8c083c770154d8f9b9ab3fe882` |
| `tool/t55_tabla_segregacion.dart` | `5c1d6098529ad1776b7a1aa48881a4b9a02a057b10569f33bb3050fc9a2f2817` |
| `lib/features/vessel/domain/services/imdg_42_24_data.dart` | `6fc226831e9a23b202a20ecc302d28515c01bf6e84719a35846d5b6992e1b899` |
| `test/t85_imdg_test.dart` | `5cc5b161e0aa93cb08f3f88bad835b331f0372283e5ea88d12efe448ec03e6cf` |
| `test/t85_segregation_page_test.dart` | `056df1c3c3add770a70a4da4b64e5507e76d46d875b02e4a8231a7ddb4a50139` |
| `tool/t85_corpus_diff.dart` | `a4396001a6ba15cc082d644bb2fd0ab770b4a10ef6c5635df1f551089e6c66f0` |
| `tool/t85_corpus_test.dart` | `36c6c60a1c18d9e15f85f358a5a85e2883f91d8bf4c9bd1d948fd0242dea3552` |
| `tool/t85_main.dart` | `4150c66d3f3658b51cf903b8e0ceb5a0c64299d06117eaafeb3384d7952e28b5` |
| `tool/t85_tabla_privada.dart` | `29364a57656872c9042d1879964df6626dc5cda8df569555f35c146e107ab4c5` |
| `docs/T85-RESULTADOS.md` | Informe de esta entrega; su huella queda en `delivery-final.json` fuera del repo |

**Los catorce protegidos permanecen iguales a la llegada** (SHA del árbol; los CRLF pueden diferir del blob Git). Perfil y codec JSON incluidos. Además, las tres rutas de T-106 —bay_plan_view.dart, plan_drag_confirmation.dart y change_requests.dart— conservan sus SHA de llegada. No se toca ningún otro archivo versionado desde el inicio de la sesión.

| Ruta protegida | SHA-256 antes = después |
|---|---|
| `firestore.rules` | `0112510984d9a16364f9752e243999c47306e0bcf82766e380db380e8fe8e60a` |
| `firebase.json` | `9bcfd4d9b5a717bd4f044c0e67440c7a81d9858edb1363cbd2cba695d30852e9` |
| `lib/main.dart` | `c5189b1d8711837a05c68306d424c9fdbcc977ba3bbb6c823089ffe4ca5339d5` |
| `pubspec.yaml` | `1b40e5308d3d1594eafbf48ee578abb73a39dc2e3fe0a4551f0d1ac6956f38ea` |
| `pubspec.lock` | `577d742e04143131bc02a1bbb6c246d298c90396e08f6c9dfe393637a2617f53` |
| `lib/latency_test_screen.dart` | `599310db13a713e82fc0d6a411be2d7757cbc2b803d772c1caa16c471725cdff` |
| `lib/c3_reconciliation_screen.dart` | `3af478364a8c5386e1f921e0142dc4f847594beca00b6743563cb09a8a4112a5` |
| `lib/features/vessel/domain/entities/vessel_profile.dart` | `70f26644caddff4fc2413a133fc3e336ad865ee0cffb4164f428ff2b1f242edf` |
| `lib/features/vessel/domain/entities/hatch_covers.dart` | `321a3787e81a31754ebdee3eebc174b3669ce0ee06e86b066aca462e46fb413d` |
| `lib/features/vessel/domain/entities/vessel_geometry.dart` | `8c3a42ce7788d8315fcb8d9a863e6a5ecede7a7f2df08c91acb5adfba1551915` |
| `lib/features/vessel/data/datasources/local_vessel_codec.dart` | `c7bc2eea8cc2b8eb4b7c2f7d225c95fde17159e65fdb2216a0f79ff02c9d146a` |
| `lib/features/vessel/domain/entities/container_unit.dart` | `6daf61cd1c5eef19711e80fd910b56a63c7412e902594b36f117971de65c32ec` |
| `lib/features/vessel/domain/entities/dangerous_goods.dart` | `b1a5433c5b62df220f597e3bd5ea31aeb5c7a75879a6a66d02e5b0d93b6aeedb` |
| `lib/features/vessel/data/services/baplie_parser_service.dart` | `d34fe7f5d12aabd25119382305315747601d6ac77ac97cfd817911e02ff94b7c` |

## 8. Comandos para Carlos y mensaje de entrega

Bloque de la entrega original, no ejecutado por Codex y **ya versionado por Carlos en ac72849**; se conserva como registro, no se debe repetir. Ninguna ruta requiere git add -f según .gitignore:

```powershell
git add -- lib/features/vessel/domain/services/dangerous_goods_validator.dart
git add -- lib/features/vessel/domain/services/segregation_rules.dart
git add -- lib/features/vessel/presentation/pages/segregation_page.dart
git add -- lib/features/vessel/presentation/pages/stowage_alerts_page.dart
git add -- lib/features/vessel/presentation/providers/segregation_provider.dart
git add -- test/dangerous_goods_validator_test.dart
git add -- test/segregation_page_test.dart
git add -- test/stowage_alerts_page_test.dart
git add -- tool/block7_checks.dart
git add -- tool/t42_aceptacion.dart
git add -- tool/t55_fila_central.dart
git add -- tool/t55_tabla_segregacion.dart
git add -- lib/features/vessel/domain/services/imdg_42_24_data.dart
git add -- test/t85_imdg_test.dart
git add -- test/t85_segregation_page_test.dart
git add -- tool/t85_corpus_diff.dart
git add -- tool/t85_corpus_test.dart
git add -- tool/t85_main.dart
git add -- tool/t85_tabla_privada.dart
git add -- docs/T85-RESULTADOS.md
git commit -m "Aplicar segregacion IMDG 42-24 por clase y posicion"
git push
```

Para versionar **solo esta continuación Web**, Carlos puede ejecutar este bloque independiente del cierre T-95; Codex no lo ejecutó:

```powershell
git add -- docs/T85-RESULTADOS.md
git commit -m "Sprint 3: documentar revision Web de T-85"
git push
```

Tres líneas:
- La segregación deja perfiles de 49 CFR y usa clases, secundarios y posición del IMDG 42-24.
- Comprobador 289/289 y 60/60; suite 894/894, analyze 0, corpus 157/157; 650 filas trazadas sin cambio inexplicado.
- Windows, Honor y Web revisados; sigue la observación de repintado de Windows. Gru revisa datos y Timonel acepta; servidores Web detenidos.

**Mensaje para Yov:** Completada la Web de T-85 (ac72849, copia base 93dc695) con la autorización 10.70: navegador integrado de Codex, declarado como sustituto, sin afirmar Chrome. A03 abre con 369 contenedores y la pantalla muestra fuente IMDG 42-24, apartados 7.2.4/7.4.3.2, resumen 4/154/95 y tarjetas X no evaluadas con remisión a la Lista/16b. Captura y estado accesible en TEMP/web-1070; main.dart.js SHA-256 d2562678efd24825e184974c35928816d4a1c584d5e8d82539041fc96969f184. Datos IMDG SHA-256 6fc226831e9a23b202a20ecc302d28515c01bf6e84719a35846d5b6992e1b899; siguen vigentes las validaciones originales: comprobador 289/289 y 60/60, suite 894/894, analyze 0, corpus 157/157 y 650 resultados anteriores explicados, 0 sin razón. Esta continuación solo actualiza informes: 338 archivos de código/configuración sin cambios, pubspec.* intactos, ningún comando Flutter ni dispositivos. Pestañas cerradas y servidores detenidos. Sigue EN REVISIÓN: Gru coteja datos con el PDF y después Timonel acepta, incluida la observación de rastros en la matriz de Windows, que no se declara resuelta. T-95 queda aceptada en su informe separado tras completar también su Web.

## 9. Anexo: lista completa de los 650 resultados anteriores

Índices basados en la salida ordenada del validador, desde 1. C = conforme en reglas evaluadas; NC = posible incumplimiento; NE = no evaluado; — = diagnóstico individual retirado. La posición se muestra sin números de contenedor. Los DGS repetidos permanecen en filas diferentes.


### A01

| Índice anterior → nuevo | Posición o par | Estado anterior → nuevo | Razón |
|---|---|---|---|
| 1 → 1 | 0010382 / 0110282 | C → NE | X |
| 2 → 2 | 0010382 / 0290982 | C → NE | X |
| 3 → 3 | 0010382 / 0310982 | C → NE | X |
| 4 → 4 | 0110282 / 0290982 | C → NE | X |
| 5 → 5 | 0110282 / 0310982 | C → NE | X |
| 6 → 6 | 0290982 / 0310982 | C → NE | X |

### A02

| Índice anterior → nuevo | Posición o par | Estado anterior → nuevo | Razón |
|---|---|---|---|
| 1 → 1 | 0020684 | C → NE | X |
| 2 → 2 | 0020684 / 0030512 | C → C | C2 |
| 3 → 3 | 0020684 / 0030512 | C → C | C2 |

### A03

| Índice anterior → nuevo | Posición o par | Estado anterior → nuevo | Razón |
|---|---|---|---|
| 1 → 1 | 0140284 / 0140384 | C → NE | X |
| 2 → 2 | 0140284 / 0140384 | C → NE | X |
| 3 → 3 | 0140284 / 0140484 | C → NE | X |
| 4 → 4 | 0140284 / 0140484 | C → NE | X |
| 5 → 5 | 0140284 / 0140084 | C → NE | X |
| 6 → 6 | 0140284 / 0140784 | C → NE | X |
| 7 → 7 | 0140284 / 0140784 | C → NE | X |
| 8 → 8 | 0140284 / 0260286 | NE → NE | X |
| 9 → 9 | 0140284 / 0020386 | C → NE | X |
| 10 → 10 | 0140284 / 0260184 | NE → C | H2L |
| 11 → 11 | 0140284 / 0180484 | NE → NE | X |
| 12 → 12 | 0140284 / 0260186 | C → C | H2L |
| 13 → 13 | 0140284 / 0020486 | NE → NE | X |
| 14 → 14 | 0140284 / 0030186 | C → NE | X |
| 15 → 15 | 0140284 / 0020686 | C → NE | X |
| 16 → 16 | 0140284 / 0250384 | C → NE | X |
| 17 → 17 | 0140284 / 0030586 | C → C | H2L |
| 18 → 18 | 0140284 / 0260284 | NE → NE | X |
| 19 → 19 | 0140284 / 0270384 | C → C | H2L |
| 20 → 20 | 0140284 / 0270584 | C → C | H2L |
| 21 → 21 | 0140284 / 0270784 | C → C | H2L |
| 22 → 22 | 0140284 / 0030286 | C → NE | X |
| 23 → 23 | 0140384 | C → NE | X |
| 24 → 24 | 0140384 / 0140484 | C → NE | X |
| 25 → 25 | 0140384 / 0140484 | C → NE | X |
| 26 → 26 | 0140384 / 0140084 | C → NE | X |
| 27 → 27 | 0140384 / 0140784 | C → NE | X |
| 28 → 28 | 0140384 / 0140784 | C → NE | X |
| 29 → 29 | 0140384 / 0260286 | NE → NE | X |
| 30 → 30 | 0140384 / 0020386 | C → NE | X |
| 31 → 31 | 0140384 / 0260184 | NE → C | H2L |
| 32 → 32 | 0140384 / 0180484 | NE → NE | X |
| 33 → 33 | 0140384 / 0260186 | C → C | H2L |
| 34 → 34 | 0140384 / 0020486 | NE → NE | X |
| 35 → 35 | 0140384 / 0030186 | C → NE | X |
| 36 → 36 | 0140384 / 0020686 | C → NE | X |
| 37 → 37 | 0140384 / 0250384 | C → NE | X |
| 38 → 38 | 0140384 / 0030586 | C → C | H2L |
| 39 → 39 | 0140384 / 0260284 | NE → NE | X |
| 40 → 40 | 0140384 / 0270384 | C → C | H2L |
| 41 → 41 | 0140384 / 0270584 | C → C | H2L |
| 42 → 42 | 0140384 / 0270784 | C → C | H2L |
| 43 → 43 | 0140384 / 0030286 | C → NE | X |
| 44 → 44 | 0140384 / 0140484 | C → NE | X |
| 45 → 45 | 0140384 / 0140484 | C → NE | X |
| 46 → 46 | 0140384 / 0140084 | C → NE | X |
| 47 → 47 | 0140384 / 0140784 | C → NE | X |
| 48 → 48 | 0140384 / 0140784 | C → NE | X |
| 49 → 49 | 0140384 / 0260286 | NE → NE | X |
| 50 → 50 | 0140384 / 0020386 | C → NE | X |
| 51 → 51 | 0140384 / 0260184 | NE → C | H2L |
| 52 → 52 | 0140384 / 0180484 | NE → NE | X |
| 53 → 53 | 0140384 / 0260186 | C → C | H2L |
| 54 → 54 | 0140384 / 0020486 | NE → NE | X |
| 55 → 55 | 0140384 / 0030186 | C → NE | X |
| 56 → 56 | 0140384 / 0020686 | C → NE | X |
| 57 → 57 | 0140384 / 0250384 | C → NE | X |
| 58 → 58 | 0140384 / 0030586 | C → C | H2L |
| 59 → 59 | 0140384 / 0260284 | NE → NE | X |
| 60 → 60 | 0140384 / 0270384 | C → C | H2L |
| 61 → 61 | 0140384 / 0270584 | C → C | H2L |
| 62 → 62 | 0140384 / 0270784 | C → C | H2L |
| 63 → 63 | 0140384 / 0030286 | C → NE | X |
| 64 → 64 | 0140484 | C → NE | X |
| 65 → 65 | 0140484 / 0140084 | C → NE | X |
| 66 → 66 | 0140484 / 0140784 | C → NE | X |
| 67 → 67 | 0140484 / 0140784 | C → NE | X |
| 68 → 68 | 0140484 / 0260286 | NE → NE | X |
| 69 → 69 | 0140484 / 0020386 | C → NE | X |
| 70 → 70 | 0140484 / 0260184 | NE → C | H2L |
| 71 → 71 | 0140484 / 0180484 | NE → NE | X |
| 72 → 72 | 0140484 / 0260186 | C → C | H2L |
| 73 → 73 | 0140484 / 0020486 | NE → NE | X |
| 74 → 74 | 0140484 / 0030186 | C → NE | X |
| 75 → 75 | 0140484 / 0020686 | C → NE | X |
| 76 → 76 | 0140484 / 0250384 | C → NE | X |
| 77 → 77 | 0140484 / 0030586 | C → C | H2L |
| 78 → 78 | 0140484 / 0260284 | NE → NE | X |
| 79 → 79 | 0140484 / 0270384 | C → C | H2L |
| 80 → 80 | 0140484 / 0270584 | C → C | H2L |
| 81 → 81 | 0140484 / 0270784 | C → C | H2L |
| 82 → 82 | 0140484 / 0030286 | C → NE | X |
| 83 → 83 | 0140484 / 0140084 | C → NE | X |
| 84 → 84 | 0140484 / 0140784 | C → NE | X |
| 85 → 85 | 0140484 / 0140784 | C → NE | X |
| 86 → 86 | 0140484 / 0260286 | NE → NE | X |
| 87 → 87 | 0140484 / 0020386 | C → NE | X |
| 88 → 88 | 0140484 / 0260184 | NE → C | H2L |
| 89 → 89 | 0140484 / 0180484 | NE → NE | X |
| 90 → 90 | 0140484 / 0260186 | C → C | H2L |
| 91 → 91 | 0140484 / 0020486 | NE → NE | X |
| 92 → 92 | 0140484 / 0030186 | C → NE | X |
| 93 → 93 | 0140484 / 0020686 | C → NE | X |
| 94 → 94 | 0140484 / 0250384 | C → NE | X |
| 95 → 95 | 0140484 / 0030586 | C → C | H2L |
| 96 → 96 | 0140484 / 0260284 | NE → NE | X |
| 97 → 97 | 0140484 / 0270384 | C → C | H2L |
| 98 → 98 | 0140484 / 0270584 | C → C | H2L |
| 99 → 99 | 0140484 / 0270784 | C → C | H2L |
| 100 → 100 | 0140484 / 0030286 | C → NE | X |
| 101 → 101 | 0140084 / 0140784 | C → NE | X |
| 102 → 102 | 0140084 / 0140784 | C → NE | X |
| 103 → 103 | 0140084 / 0260286 | NE → NE | X |
| 104 → 104 | 0140084 / 0020386 | C → NE | X |
| 105 → 105 | 0140084 / 0260184 | NE → C | H2L |
| 106 → 106 | 0140084 / 0180484 | NE → NE | X |
| 107 → 107 | 0140084 / 0260186 | C → C | H2L |
| 108 → 108 | 0140084 / 0020486 | NE → NE | X |
| 109 → 109 | 0140084 / 0030186 | C → NE | X |
| 110 → 110 | 0140084 / 0020686 | C → NE | X |
| 111 → 111 | 0140084 / 0250384 | C → NE | X |
| 112 → 112 | 0140084 / 0030586 | C → C | H2L |
| 113 → 113 | 0140084 / 0260284 | NE → NE | X |
| 114 → 114 | 0140084 / 0270384 | C → C | H2L |
| 115 → 115 | 0140084 / 0270584 | C → C | H2L |
| 116 → 116 | 0140084 / 0270784 | C → C | H2L |
| 117 → 117 | 0140084 / 0030286 | C → NE | X |
| 118 → 118 | 0140784 | NE → NE | X |
| 119 → 119 | 0140784 / 0260286 | NE → NE | X |
| 120 → 120 | 0140784 / 0020386 | C → NE | X |
| 121 → 121 | 0140784 / 0260184 | NE → C | H2L |
| 122 → 122 | 0140784 / 0180484 | NE → NE | X |
| 123 → 123 | 0140784 / 0260186 | C → C | H1L |
| 124 → 124 | 0140784 / 0020486 | NE → NE | X |
| 125 → 125 | 0140784 / 0030186 | C → NE | X |
| 126 → 126 | 0140784 / 0020686 | C → C | H1L |
| 127 → 127 | 0140784 / 0250384 | C → NE | X |
| 128 → 128 | 0140784 / 0030586 | C → C | H2L |
| 129 → 129 | 0140784 / 0260284 | NE → NE | X |
| 130 → 130 | 0140784 / 0270384 | C → C | H2L |
| 131 → 131 | 0140784 / 0270584 | C → C | H2L |
| 132 → 132 | 0140784 / 0270784 | C → C | H2L |
| 133 → 133 | 0140784 / 0030286 | C → NE | X |
| 134 → 134 | 0140784 / 0260286 | NE → NE | X |
| 135 → 135 | 0140784 / 0020386 | C → NE | X |
| 136 → 136 | 0140784 / 0260184 | NE → C | H2L |
| 137 → 137 | 0140784 / 0180484 | NE → NE | X |
| 138 → 138 | 0140784 / 0260186 | C → C | H1L |
| 139 → 139 | 0140784 / 0020486 | NE → NE | X |
| 140 → 140 | 0140784 / 0030186 | C → NE | X |
| 141 → 141 | 0140784 / 0020686 | C → C | H1L |
| 142 → 142 | 0140784 / 0250384 | C → NE | X |
| 143 → 143 | 0140784 / 0030586 | C → C | H2L |
| 144 → 144 | 0140784 / 0260284 | NE → NE | X |
| 145 → 145 | 0140784 / 0270384 | C → C | H2L |
| 146 → 146 | 0140784 / 0270584 | C → C | H2L |
| 147 → 147 | 0140784 / 0270784 | C → C | H2L |
| 148 → 148 | 0140784 / 0030286 | C → NE | X |
| 149 → 149 | 0260286 / 0020386 | NE → NE | X |
| 150 → 150 | 0260286 / 0260184 | NE → C | H2T |
| 151 → 151 | 0260286 / 0180484 | NE → NE | X |
| 152 → 152 | 0260286 / 0260186 | NE → C | H1L |
| 153 → 153 | 0260286 / 0020486 | NE → NE | X |
| 154 → 154 | 0260286 / 0030186 | NE → NE | X |
| 155 → 155 | 0260286 / 0020686 | NE → C | H1L |
| 156 → 156 | 0260286 / 0250384 | NE → NE | X |
| 157 → 157 | 0260286 / 0030586 | NE → C | H2L |
| 158 → 158 | 0260286 / 0260284 | NE → NE | X |
| 159 → 159 | 0260286 / 0270384 | NE → C | H2T |
| 160 → 160 | 0260286 / 0270584 | NE → C | H2T |
| 161 → 161 | 0260286 / 0270784 | NE → C | H2T |
| 162 → 162 | 0260286 / 0030286 | NE → NE | X |
| 163 → 163 | 0020386 / 0260184 | NE → C | H2L |
| 164 → 164 | 0020386 / 0180484 | NE → NE | X |
| 165 → 165 | 0020386 / 0260186 | C → C | H2L |
| 166 → 166 | 0020386 / 0020486 | NE → NE | X |
| 167 → 167 | 0020386 / 0030186 | C → NE | X |
| 168 → 168 | 0020386 / 0020686 | C → NE | X |
| 169 → 169 | 0020386 / 0250384 | C → NE | X |
| 170 → 170 | 0020386 / 0030586 | NC → NC | F2 |
| 171 → 171 | 0020386 / 0260284 | NE → NE | X |
| 172 → 172 | 0020386 / 0270384 | C → C | H2L |
| 173 → 173 | 0020386 / 0270584 | C → C | H2L |
| 174 → 174 | 0020386 / 0270784 | C → C | H2L |
| 175 → 175 | 0020386 / 0030286 | C → NE | X |
| 176 → 176 | 0260184 / 0180484 | NE → C | H2L |
| 177 → 177 | 0260184 / 0260186 | NE → NC | V2 |
| 178 → 178 | 0260184 / 0020486 | NE → C | H2L |
| 179 → 179 | 0260184 / 0030186 | NE → NE | X |
| 180 → 180 | 0260184 / 0020686 | NE → C | H1L |
| 181 → 181 | 0260184 / 0250384 | NE → NE | X |
| 182 → 182 | 0260184 / 0030586 | NE → C | H2L |
| 183 → 183 | 0260184 / 0260284 | NE → C | H2T |
| 184 → 184 | 0260184 / 0270384 | NC → NC | F2 |
| 185 → 185 | 0260184 / 0270584 | NE → C | H2T |
| 186 → 186 | 0260184 / 0270784 | NE → C | H2T |
| 187 → 187 | 0260184 / 0030286 | NE → NE | X |
| 188 → 188 | 0180484 / 0260186 | NE → C | H1L |
| 189 → 189 | 0180484 / 0020486 | NE → NE | X |
| 190 → 190 | 0180484 / 0030186 | NE → NE | X |
| 191 → 191 | 0180484 / 0020686 | NE → C | H1L |
| 192 → 192 | 0180484 / 0250384 | NE → NE | X |
| 193 → 193 | 0180484 / 0030586 | NE → C | H2L |
| 194 → 194 | 0180484 / 0260284 | NE → NE | X |
| 195 → 195 | 0180484 / 0270384 | NE → C | H2L |
| 196 → 196 | 0180484 / 0270584 | NE → C | H2L |
| 197 → 197 | 0180484 / 0270784 | NE → C | H2L |
| 198 → 198 | 0180484 / 0030286 | NE → NE | X |
| 199 → 199 | 0260186 / 0020486 | NE → C | H1L |
| 200 → 200 | 0260186 / 0030186 | C → NE | X |
| 201 → 201 | 0260186 / 0020686 | C → C | H1L |
| 202 → 202 | 0260186 / 0250384 | C → NE | X |
| 203 → 203 | 0260186 / 0030586 | C → C | H2L |
| 204 → 204 | 0260186 / 0260284 | NE → C | H1L |
| 205 → 205 | 0260186 / 0270384 | C → NC | F2 |
| 206 → 206 | 0260186 / 0270584 | C → C | H2T |
| 207 → 207 | 0260186 / 0270784 | C → C | H2T |
| 208 → 208 | 0260186 / 0030286 | C → NE | X |
| 209 → 209 | 0020486 / 0030186 | NE → NE | X |
| 210 → 210 | 0020486 / 0020686 | NE → C | H1L |
| 211 → 211 | 0020486 / 0250384 | NE → NE | X |
| 212 → 212 | 0020486 / 0030586 | NE → C | H2T |
| 213 → 213 | 0020486 / 0260284 | NE → NE | X |
| 214 → 214 | 0020486 / 0270384 | NE → C | H2L |
| 215 → 215 | 0020486 / 0270584 | NE → C | H2L |
| 216 → 216 | 0020486 / 0270784 | NE → C | H2L |
| 217 → 217 | 0020486 / 0030286 | NE → NE | X |
| 218 → 218 | 0030186 / 0020686 | C → NE | X |
| 219 → 219 | 0030186 / 0250384 | C → NE | X |
| 220 → 220 | 0030186 / 0030586 | C → NE | X |
| 221 → 221 | 0030186 / 0260284 | NE → NE | X |
| 222 → 222 | 0030186 / 0270384 | C → NE | X |
| 223 → 223 | 0030186 / 0270584 | C → NE | X |
| 224 → 224 | 0030186 / 0270784 | C → NE | X |
| 225 → 225 | 0030186 / 0030286 | C → NE | X |
| 226 → 226 | 0020686 / 0250384 | C → NE | X |
| 227 → 227 | 0020686 / 0030586 | C → C | H2T |
| 228 → 228 | 0020686 / 0260284 | NE → C | H1L |
| 229 → 229 | 0020686 / 0270384 | C → C | H2L |
| 230 → 230 | 0020686 / 0270584 | C → C | H2L |
| 231 → 231 | 0020686 / 0270784 | C → C | H2L |
| 232 → 232 | 0020686 / 0030286 | C → NE | X |
| 233 → 233 | 0250384 / 0030586 | C → NE | X |
| 234 → 234 | 0250384 / 0260284 | NE → NE | X |
| 235 → 235 | 0250384 / 0270384 | C → NE | X |
| 236 → 236 | 0250384 / 0270584 | C → NE | X |
| 237 → 237 | 0250384 / 0270784 | C → NE | X |
| 238 → 238 | 0250384 / 0030286 | C → NE | X |
| 239 → 239 | 0030586 / 0260284 | NE → C | H2L |
| 240 → 240 | 0030586 / 0270384 | C → NE | A |
| 241 → 241 | 0030586 / 0270584 | C → NE | A |
| 242 → 242 | 0030586 / 0270784 | C → NE | A |
| 243 → 243 | 0030586 / 0030286 | C → NE | X |
| 244 → 244 | 0260284 / 0270384 | NE → C | H2T |
| 245 → 245 | 0260284 / 0270584 | NE → C | H2T |
| 246 → 246 | 0260284 / 0270784 | NE → C | H2T |
| 247 → 247 | 0260284 / 0030286 | NE → NE | X |
| 248 → 248 | 0270384 / 0270584 | C → NE | A |
| 249 → 249 | 0270384 / 0270784 | C → NE | A |
| 250 → 250 | 0270384 / 0030286 | C → NE | X |
| 251 → 251 | 0270584 / 0270784 | C → NE | A |
| 252 → 252 | 0270584 / 0030286 | C → NE | X |
| 253 → 253 | 0270784 / 0030286 | C → NE | X |

### A03v_VGM

| Índice anterior → nuevo | Posición o par | Estado anterior → nuevo | Razón |
|---|---|---|---|
| 1 → 1 | 0140284 / 0140384 | C → NE | X |
| 2 → 2 | 0140284 / 0140384 | C → NE | X |
| 3 → 3 | 0140284 / 0140484 | C → NE | X |
| 4 → 4 | 0140284 / 0140484 | C → NE | X |
| 5 → 5 | 0140284 / 0140084 | C → NE | X |
| 6 → 6 | 0140284 / 0140784 | C → NE | X |
| 7 → 7 | 0140284 / 0140784 | C → NE | X |
| 8 → 8 | 0140284 / 0260286 | NE → NE | X |
| 9 → 9 | 0140284 / 0020386 | C → NE | X |
| 10 → 10 | 0140284 / 0260184 | NE → C | H2L |
| 11 → 11 | 0140284 / 0180484 | NE → NE | X |
| 12 → 12 | 0140284 / 0260186 | C → C | H2L |
| 13 → 13 | 0140284 / 0020486 | NE → NE | X |
| 14 → 14 | 0140284 / 0030186 | C → NE | X |
| 15 → 15 | 0140284 / 0020686 | C → NE | X |
| 16 → 16 | 0140284 / 0250384 | C → NE | X |
| 17 → 17 | 0140284 / 0030586 | C → C | H2L |
| 18 → 18 | 0140284 / 0260284 | NE → NE | X |
| 19 → 19 | 0140284 / 0270384 | C → C | H2L |
| 20 → 20 | 0140284 / 0270584 | C → C | H2L |
| 21 → 21 | 0140284 / 0270784 | C → C | H2L |
| 22 → 22 | 0140284 / 0030286 | C → NE | X |
| 23 → 23 | 0140384 | C → NE | X |
| 24 → 24 | 0140384 / 0140484 | C → NE | X |
| 25 → 25 | 0140384 / 0140484 | C → NE | X |
| 26 → 26 | 0140384 / 0140084 | C → NE | X |
| 27 → 27 | 0140384 / 0140784 | C → NE | X |
| 28 → 28 | 0140384 / 0140784 | C → NE | X |
| 29 → 29 | 0140384 / 0260286 | NE → NE | X |
| 30 → 30 | 0140384 / 0020386 | C → NE | X |
| 31 → 31 | 0140384 / 0260184 | NE → C | H2L |
| 32 → 32 | 0140384 / 0180484 | NE → NE | X |
| 33 → 33 | 0140384 / 0260186 | C → C | H2L |
| 34 → 34 | 0140384 / 0020486 | NE → NE | X |
| 35 → 35 | 0140384 / 0030186 | C → NE | X |
| 36 → 36 | 0140384 / 0020686 | C → NE | X |
| 37 → 37 | 0140384 / 0250384 | C → NE | X |
| 38 → 38 | 0140384 / 0030586 | C → C | H2L |
| 39 → 39 | 0140384 / 0260284 | NE → NE | X |
| 40 → 40 | 0140384 / 0270384 | C → C | H2L |
| 41 → 41 | 0140384 / 0270584 | C → C | H2L |
| 42 → 42 | 0140384 / 0270784 | C → C | H2L |
| 43 → 43 | 0140384 / 0030286 | C → NE | X |
| 44 → 44 | 0140384 / 0140484 | C → NE | X |
| 45 → 45 | 0140384 / 0140484 | C → NE | X |
| 46 → 46 | 0140384 / 0140084 | C → NE | X |
| 47 → 47 | 0140384 / 0140784 | C → NE | X |
| 48 → 48 | 0140384 / 0140784 | C → NE | X |
| 49 → 49 | 0140384 / 0260286 | NE → NE | X |
| 50 → 50 | 0140384 / 0020386 | C → NE | X |
| 51 → 51 | 0140384 / 0260184 | NE → C | H2L |
| 52 → 52 | 0140384 / 0180484 | NE → NE | X |
| 53 → 53 | 0140384 / 0260186 | C → C | H2L |
| 54 → 54 | 0140384 / 0020486 | NE → NE | X |
| 55 → 55 | 0140384 / 0030186 | C → NE | X |
| 56 → 56 | 0140384 / 0020686 | C → NE | X |
| 57 → 57 | 0140384 / 0250384 | C → NE | X |
| 58 → 58 | 0140384 / 0030586 | C → C | H2L |
| 59 → 59 | 0140384 / 0260284 | NE → NE | X |
| 60 → 60 | 0140384 / 0270384 | C → C | H2L |
| 61 → 61 | 0140384 / 0270584 | C → C | H2L |
| 62 → 62 | 0140384 / 0270784 | C → C | H2L |
| 63 → 63 | 0140384 / 0030286 | C → NE | X |
| 64 → 64 | 0140484 | C → NE | X |
| 65 → 65 | 0140484 / 0140084 | C → NE | X |
| 66 → 66 | 0140484 / 0140784 | C → NE | X |
| 67 → 67 | 0140484 / 0140784 | C → NE | X |
| 68 → 68 | 0140484 / 0260286 | NE → NE | X |
| 69 → 69 | 0140484 / 0020386 | C → NE | X |
| 70 → 70 | 0140484 / 0260184 | NE → C | H2L |
| 71 → 71 | 0140484 / 0180484 | NE → NE | X |
| 72 → 72 | 0140484 / 0260186 | C → C | H2L |
| 73 → 73 | 0140484 / 0020486 | NE → NE | X |
| 74 → 74 | 0140484 / 0030186 | C → NE | X |
| 75 → 75 | 0140484 / 0020686 | C → NE | X |
| 76 → 76 | 0140484 / 0250384 | C → NE | X |
| 77 → 77 | 0140484 / 0030586 | C → C | H2L |
| 78 → 78 | 0140484 / 0260284 | NE → NE | X |
| 79 → 79 | 0140484 / 0270384 | C → C | H2L |
| 80 → 80 | 0140484 / 0270584 | C → C | H2L |
| 81 → 81 | 0140484 / 0270784 | C → C | H2L |
| 82 → 82 | 0140484 / 0030286 | C → NE | X |
| 83 → 83 | 0140484 / 0140084 | C → NE | X |
| 84 → 84 | 0140484 / 0140784 | C → NE | X |
| 85 → 85 | 0140484 / 0140784 | C → NE | X |
| 86 → 86 | 0140484 / 0260286 | NE → NE | X |
| 87 → 87 | 0140484 / 0020386 | C → NE | X |
| 88 → 88 | 0140484 / 0260184 | NE → C | H2L |
| 89 → 89 | 0140484 / 0180484 | NE → NE | X |
| 90 → 90 | 0140484 / 0260186 | C → C | H2L |
| 91 → 91 | 0140484 / 0020486 | NE → NE | X |
| 92 → 92 | 0140484 / 0030186 | C → NE | X |
| 93 → 93 | 0140484 / 0020686 | C → NE | X |
| 94 → 94 | 0140484 / 0250384 | C → NE | X |
| 95 → 95 | 0140484 / 0030586 | C → C | H2L |
| 96 → 96 | 0140484 / 0260284 | NE → NE | X |
| 97 → 97 | 0140484 / 0270384 | C → C | H2L |
| 98 → 98 | 0140484 / 0270584 | C → C | H2L |
| 99 → 99 | 0140484 / 0270784 | C → C | H2L |
| 100 → 100 | 0140484 / 0030286 | C → NE | X |
| 101 → 101 | 0140084 / 0140784 | C → NE | X |
| 102 → 102 | 0140084 / 0140784 | C → NE | X |
| 103 → 103 | 0140084 / 0260286 | NE → NE | X |
| 104 → 104 | 0140084 / 0020386 | C → NE | X |
| 105 → 105 | 0140084 / 0260184 | NE → C | H2L |
| 106 → 106 | 0140084 / 0180484 | NE → NE | X |
| 107 → 107 | 0140084 / 0260186 | C → C | H2L |
| 108 → 108 | 0140084 / 0020486 | NE → NE | X |
| 109 → 109 | 0140084 / 0030186 | C → NE | X |
| 110 → 110 | 0140084 / 0020686 | C → NE | X |
| 111 → 111 | 0140084 / 0250384 | C → NE | X |
| 112 → 112 | 0140084 / 0030586 | C → C | H2L |
| 113 → 113 | 0140084 / 0260284 | NE → NE | X |
| 114 → 114 | 0140084 / 0270384 | C → C | H2L |
| 115 → 115 | 0140084 / 0270584 | C → C | H2L |
| 116 → 116 | 0140084 / 0270784 | C → C | H2L |
| 117 → 117 | 0140084 / 0030286 | C → NE | X |
| 118 → 118 | 0140784 | NE → NE | X |
| 119 → 119 | 0140784 / 0260286 | NE → NE | X |
| 120 → 120 | 0140784 / 0020386 | C → NE | X |
| 121 → 121 | 0140784 / 0260184 | NE → C | H2L |
| 122 → 122 | 0140784 / 0180484 | NE → NE | X |
| 123 → 123 | 0140784 / 0260186 | C → C | H1L |
| 124 → 124 | 0140784 / 0020486 | NE → NE | X |
| 125 → 125 | 0140784 / 0030186 | C → NE | X |
| 126 → 126 | 0140784 / 0020686 | C → C | H1L |
| 127 → 127 | 0140784 / 0250384 | C → NE | X |
| 128 → 128 | 0140784 / 0030586 | C → C | H2L |
| 129 → 129 | 0140784 / 0260284 | NE → NE | X |
| 130 → 130 | 0140784 / 0270384 | C → C | H2L |
| 131 → 131 | 0140784 / 0270584 | C → C | H2L |
| 132 → 132 | 0140784 / 0270784 | C → C | H2L |
| 133 → 133 | 0140784 / 0030286 | C → NE | X |
| 134 → 134 | 0140784 / 0260286 | NE → NE | X |
| 135 → 135 | 0140784 / 0020386 | C → NE | X |
| 136 → 136 | 0140784 / 0260184 | NE → C | H2L |
| 137 → 137 | 0140784 / 0180484 | NE → NE | X |
| 138 → 138 | 0140784 / 0260186 | C → C | H1L |
| 139 → 139 | 0140784 / 0020486 | NE → NE | X |
| 140 → 140 | 0140784 / 0030186 | C → NE | X |
| 141 → 141 | 0140784 / 0020686 | C → C | H1L |
| 142 → 142 | 0140784 / 0250384 | C → NE | X |
| 143 → 143 | 0140784 / 0030586 | C → C | H2L |
| 144 → 144 | 0140784 / 0260284 | NE → NE | X |
| 145 → 145 | 0140784 / 0270384 | C → C | H2L |
| 146 → 146 | 0140784 / 0270584 | C → C | H2L |
| 147 → 147 | 0140784 / 0270784 | C → C | H2L |
| 148 → 148 | 0140784 / 0030286 | C → NE | X |
| 149 → 149 | 0260286 / 0020386 | NE → NE | X |
| 150 → 150 | 0260286 / 0260184 | NE → C | H2T |
| 151 → 151 | 0260286 / 0180484 | NE → NE | X |
| 152 → 152 | 0260286 / 0260186 | NE → C | H1L |
| 153 → 153 | 0260286 / 0020486 | NE → NE | X |
| 154 → 154 | 0260286 / 0030186 | NE → NE | X |
| 155 → 155 | 0260286 / 0020686 | NE → C | H1L |
| 156 → 156 | 0260286 / 0250384 | NE → NE | X |
| 157 → 157 | 0260286 / 0030586 | NE → C | H2L |
| 158 → 158 | 0260286 / 0260284 | NE → NE | X |
| 159 → 159 | 0260286 / 0270384 | NE → C | H2T |
| 160 → 160 | 0260286 / 0270584 | NE → C | H2T |
| 161 → 161 | 0260286 / 0270784 | NE → C | H2T |
| 162 → 162 | 0260286 / 0030286 | NE → NE | X |
| 163 → 163 | 0020386 / 0260184 | NE → C | H2L |
| 164 → 164 | 0020386 / 0180484 | NE → NE | X |
| 165 → 165 | 0020386 / 0260186 | C → C | H2L |
| 166 → 166 | 0020386 / 0020486 | NE → NE | X |
| 167 → 167 | 0020386 / 0030186 | C → NE | X |
| 168 → 168 | 0020386 / 0020686 | C → NE | X |
| 169 → 169 | 0020386 / 0250384 | C → NE | X |
| 170 → 170 | 0020386 / 0030586 | NC → NC | F2 |
| 171 → 171 | 0020386 / 0260284 | NE → NE | X |
| 172 → 172 | 0020386 / 0270384 | C → C | H2L |
| 173 → 173 | 0020386 / 0270584 | C → C | H2L |
| 174 → 174 | 0020386 / 0270784 | C → C | H2L |
| 175 → 175 | 0020386 / 0030286 | C → NE | X |
| 176 → 176 | 0260184 / 0180484 | NE → C | H2L |
| 177 → 177 | 0260184 / 0260186 | NE → NC | V2 |
| 178 → 178 | 0260184 / 0020486 | NE → C | H2L |
| 179 → 179 | 0260184 / 0030186 | NE → NE | X |
| 180 → 180 | 0260184 / 0020686 | NE → C | H1L |
| 181 → 181 | 0260184 / 0250384 | NE → NE | X |
| 182 → 182 | 0260184 / 0030586 | NE → C | H2L |
| 183 → 183 | 0260184 / 0260284 | NE → C | H2T |
| 184 → 184 | 0260184 / 0270384 | NC → NC | F2 |
| 185 → 185 | 0260184 / 0270584 | NE → C | H2T |
| 186 → 186 | 0260184 / 0270784 | NE → C | H2T |
| 187 → 187 | 0260184 / 0030286 | NE → NE | X |
| 188 → 188 | 0180484 / 0260186 | NE → C | H1L |
| 189 → 189 | 0180484 / 0020486 | NE → NE | X |
| 190 → 190 | 0180484 / 0030186 | NE → NE | X |
| 191 → 191 | 0180484 / 0020686 | NE → C | H1L |
| 192 → 192 | 0180484 / 0250384 | NE → NE | X |
| 193 → 193 | 0180484 / 0030586 | NE → C | H2L |
| 194 → 194 | 0180484 / 0260284 | NE → NE | X |
| 195 → 195 | 0180484 / 0270384 | NE → C | H2L |
| 196 → 196 | 0180484 / 0270584 | NE → C | H2L |
| 197 → 197 | 0180484 / 0270784 | NE → C | H2L |
| 198 → 198 | 0180484 / 0030286 | NE → NE | X |
| 199 → 199 | 0260186 / 0020486 | NE → C | H1L |
| 200 → 200 | 0260186 / 0030186 | C → NE | X |
| 201 → 201 | 0260186 / 0020686 | C → C | H1L |
| 202 → 202 | 0260186 / 0250384 | C → NE | X |
| 203 → 203 | 0260186 / 0030586 | C → C | H2L |
| 204 → 204 | 0260186 / 0260284 | NE → C | H1L |
| 205 → 205 | 0260186 / 0270384 | C → NC | F2 |
| 206 → 206 | 0260186 / 0270584 | C → C | H2T |
| 207 → 207 | 0260186 / 0270784 | C → C | H2T |
| 208 → 208 | 0260186 / 0030286 | C → NE | X |
| 209 → 209 | 0020486 / 0030186 | NE → NE | X |
| 210 → 210 | 0020486 / 0020686 | NE → C | H1L |
| 211 → 211 | 0020486 / 0250384 | NE → NE | X |
| 212 → 212 | 0020486 / 0030586 | NE → C | H2T |
| 213 → 213 | 0020486 / 0260284 | NE → NE | X |
| 214 → 214 | 0020486 / 0270384 | NE → C | H2L |
| 215 → 215 | 0020486 / 0270584 | NE → C | H2L |
| 216 → 216 | 0020486 / 0270784 | NE → C | H2L |
| 217 → 217 | 0020486 / 0030286 | NE → NE | X |
| 218 → 218 | 0030186 / 0020686 | C → NE | X |
| 219 → 219 | 0030186 / 0250384 | C → NE | X |
| 220 → 220 | 0030186 / 0030586 | C → NE | X |
| 221 → 221 | 0030186 / 0260284 | NE → NE | X |
| 222 → 222 | 0030186 / 0270384 | C → NE | X |
| 223 → 223 | 0030186 / 0270584 | C → NE | X |
| 224 → 224 | 0030186 / 0270784 | C → NE | X |
| 225 → 225 | 0030186 / 0030286 | C → NE | X |
| 226 → 226 | 0020686 / 0250384 | C → NE | X |
| 227 → 227 | 0020686 / 0030586 | C → C | H2T |
| 228 → 228 | 0020686 / 0260284 | NE → C | H1L |
| 229 → 229 | 0020686 / 0270384 | C → C | H2L |
| 230 → 230 | 0020686 / 0270584 | C → C | H2L |
| 231 → 231 | 0020686 / 0270784 | C → C | H2L |
| 232 → 232 | 0020686 / 0030286 | C → NE | X |
| 233 → 233 | 0250384 / 0030586 | C → NE | X |
| 234 → 234 | 0250384 / 0260284 | NE → NE | X |
| 235 → 235 | 0250384 / 0270384 | C → NE | X |
| 236 → 236 | 0250384 / 0270584 | C → NE | X |
| 237 → 237 | 0250384 / 0270784 | C → NE | X |
| 238 → 238 | 0250384 / 0030286 | C → NE | X |
| 239 → 239 | 0030586 / 0260284 | NE → C | H2L |
| 240 → 240 | 0030586 / 0270384 | C → NE | A |
| 241 → 241 | 0030586 / 0270584 | C → NE | A |
| 242 → 242 | 0030586 / 0270784 | C → NE | A |
| 243 → 243 | 0030586 / 0030286 | C → NE | X |
| 244 → 244 | 0260284 / 0270384 | NE → C | H2T |
| 245 → 245 | 0260284 / 0270584 | NE → C | H2T |
| 246 → 246 | 0260284 / 0270784 | NE → C | H2T |
| 247 → 247 | 0260284 / 0030286 | NE → NE | X |
| 248 → 248 | 0270384 / 0270584 | C → NE | A |
| 249 → 249 | 0270384 / 0270784 | C → NE | A |
| 250 → 250 | 0270384 / 0030286 | C → NE | X |
| 251 → 251 | 0270584 / 0270784 | C → NE | A |
| 252 → 252 | 0270584 / 0030286 | C → NE | X |
| 253 → 253 | 0270784 / 0030286 | C → NE | X |

### A04

| Índice anterior → nuevo | Posición o par | Estado anterior → nuevo | Razón |
|---|---|---|---|
| 1 → 1 | 0050982 / 0050782 | C → NE | X |

### A05

| Índice anterior → nuevo | Posición o par | Estado anterior → nuevo | Razón |
|---|---|---|---|
| 1 → 1 | 0250784 | NE → NE | U |

### A06

| Índice anterior → nuevo | Posición o par | Estado anterior → nuevo | Razón |
|---|---|---|---|
| 1 → 1 | 0250784 | NE → NE | U |

### A07

| Índice anterior → nuevo | Posición o par | Estado anterior → nuevo | Razón |
|---|---|---|---|
| 1 → — | 0220408 | NE → — | D |
| 2 → — | 0220608 | NE → — | D |
| 3 → — | 0220208 | NE → — | D |
| 4 → — | 0220808 | NE → — | D |
| 5 → — | 0220210 | NE → — | D |
| 6 → — | 0220482 | NE → — | D |
| 7 → — | 0220482 | NE → — | D |
| 8 → — | 0220484 | NE → — | D |
| 9 → — | 0220484 | NE → — | D |
| 10 → — | 0140188 | NE → — | D |
| 11 → 1 | 0220408 / 0220608 | NE → NE | X |
| 12 → 2 | 0220408 / 0220208 | NE → NE | X |
| 13 → 3 | 0220408 / 0220808 | NE → NE | X |
| 14 → 4 | 0220408 / 0220210 | NE → NE | X |
| 15 → 5 | 0220408 / 0220482 | NE → NE | X |
| 16 → 6 | 0220408 / 0220482 | NE → NE | X |
| 17 → 7 | 0220408 / 0220882 | NE → NE | X |
| 18 → 8 | 0220408 / 0220484 | NE → NE | X |
| 19 → 9 | 0220408 / 0220484 | NE → NE | X |
| 20 → 10 | 0220408 / 0220884 | NE → NE | X |
| 21 → 11 | 0220408 / 0220886 | NE → NE | X |
| 22 → 12 | 0220408 / 0010782 | NE → NE | X |
| 23 → 13 | 0220408 / 0140588 | NE → NE | X |
| 24 → 14 | 0220408 / 0140188 | NE → NE | X |
| 25 → 15 | 0220408 / 0140388 | NE → NE | X |
| 26 → 16 | 0220608 / 0220208 | NE → NE | X |
| 27 → 17 | 0220608 / 0220808 | NE → NE | X |
| 28 → 18 | 0220608 / 0220210 | NE → NE | X |
| 29 → 19 | 0220608 / 0220482 | NE → NE | X |
| 30 → 20 | 0220608 / 0220482 | NE → NE | X |
| 31 → 21 | 0220608 / 0220882 | NE → NE | X |
| 32 → 22 | 0220608 / 0220484 | NE → NE | X |
| 33 → 23 | 0220608 / 0220484 | NE → NE | X |
| 34 → 24 | 0220608 / 0220884 | NE → NE | X |
| 35 → 25 | 0220608 / 0220886 | NE → NE | X |
| 36 → 26 | 0220608 / 0010782 | NE → NE | X |
| 37 → 27 | 0220608 / 0140588 | NE → NE | X |
| 38 → 28 | 0220608 / 0140188 | NE → NE | X |
| 39 → 29 | 0220608 / 0140388 | NE → NE | X |
| 40 → 30 | 0220208 / 0220808 | NE → NE | X |
| 41 → 31 | 0220208 / 0220210 | NE → NE | X |
| 42 → 32 | 0220208 / 0220482 | NE → NE | X |
| 43 → 33 | 0220208 / 0220482 | NE → NE | X |
| 44 → 34 | 0220208 / 0220882 | NE → NE | X |
| 45 → 35 | 0220208 / 0220484 | NE → NE | X |
| 46 → 36 | 0220208 / 0220484 | NE → NE | X |
| 47 → 37 | 0220208 / 0220884 | NE → NE | X |
| 48 → 38 | 0220208 / 0220886 | NE → NE | X |
| 49 → 39 | 0220208 / 0010782 | NE → NE | X |
| 50 → 40 | 0220208 / 0140588 | NE → NE | X |
| 51 → 41 | 0220208 / 0140188 | NE → NE | X |
| 52 → 42 | 0220208 / 0140388 | NE → NE | X |
| 53 → 43 | 0220808 / 0220210 | NE → NE | X |
| 54 → 44 | 0220808 / 0220482 | NE → NE | X |
| 55 → 45 | 0220808 / 0220482 | NE → NE | X |
| 56 → 46 | 0220808 / 0220882 | NE → NE | X |
| 57 → 47 | 0220808 / 0220484 | NE → NE | X |
| 58 → 48 | 0220808 / 0220484 | NE → NE | X |
| 59 → 49 | 0220808 / 0220884 | NE → NE | X |
| 60 → 50 | 0220808 / 0220886 | NE → NE | X |
| 61 → 51 | 0220808 / 0010782 | NE → NE | X |
| 62 → 52 | 0220808 / 0140588 | NE → NE | X |
| 63 → 53 | 0220808 / 0140188 | NE → NE | X |
| 64 → 54 | 0220808 / 0140388 | NE → NE | X |
| 65 → 55 | 0220210 / 0220482 | NE → NE | X |
| 66 → 56 | 0220210 / 0220482 | NE → NE | X |
| 67 → 57 | 0220210 / 0220882 | NE → NE | X |
| 68 → 58 | 0220210 / 0220484 | NE → NE | X |
| 69 → 59 | 0220210 / 0220484 | NE → NE | X |
| 70 → 60 | 0220210 / 0220884 | NE → NE | X |
| 71 → 61 | 0220210 / 0220886 | NE → NE | X |
| 72 → 62 | 0220210 / 0010782 | NE → NE | X |
| 73 → 63 | 0220210 / 0140588 | NE → NE | X |
| 74 → 64 | 0220210 / 0140188 | NE → NE | X |
| 75 → 65 | 0220210 / 0140388 | NE → NE | X |
| 76 → 66 | 0220482 | NE → NE | X |
| 77 → 67 | 0220482 / 0220882 | NE → NE | X |
| 78 → 68 | 0220482 / 0220484 | NE → NE | X |
| 79 → 69 | 0220482 / 0220484 | NE → NE | X |
| 80 → 70 | 0220482 / 0220884 | NE → NE | X |
| 81 → 71 | 0220482 / 0220886 | NE → NE | X |
| 82 → 72 | 0220482 / 0010782 | NE → NE | X |
| 83 → 73 | 0220482 / 0140588 | NE → NE | X |
| 84 → 74 | 0220482 / 0140188 | NE → NE | X |
| 85 → 75 | 0220482 / 0140388 | NE → NE | X |
| 86 → 76 | 0220482 / 0220882 | NE → NE | X |
| 87 → 77 | 0220482 / 0220484 | NE → NE | X |
| 88 → 78 | 0220482 / 0220484 | NE → NE | X |
| 89 → 79 | 0220482 / 0220884 | NE → NE | X |
| 90 → 80 | 0220482 / 0220886 | NE → NE | X |
| 91 → 81 | 0220482 / 0010782 | NE → NE | X |
| 92 → 82 | 0220482 / 0140588 | NE → NE | X |
| 93 → 83 | 0220482 / 0140188 | NE → NE | X |
| 94 → 84 | 0220482 / 0140388 | NE → NE | X |
| 95 → 85 | 0220882 / 0220484 | NE → NE | X |
| 96 → 86 | 0220882 / 0220484 | NE → NE | X |
| 97 → 87 | 0220882 / 0220884 | C → NE | X |
| 98 → 88 | 0220882 / 0220886 | C → NE | X |
| 99 → 89 | 0220882 / 0010782 | C → NE | X |
| 100 → 90 | 0220882 / 0140588 | C → NE | X |
| 101 → 91 | 0220882 / 0140188 | NE → NE | X |
| 102 → 92 | 0220882 / 0140388 | C → NE | X |
| 103 → 93 | 0220484 | NE → NE | X |
| 104 → 94 | 0220484 / 0220884 | NE → NE | X |
| 105 → 95 | 0220484 / 0220886 | NE → NE | X |
| 106 → 96 | 0220484 / 0010782 | NE → NE | X |
| 107 → 97 | 0220484 / 0140588 | NE → NE | X |
| 108 → 98 | 0220484 / 0140188 | NE → NE | X |
| 109 → 99 | 0220484 / 0140388 | NE → NE | X |
| 110 → 100 | 0220484 / 0220884 | NE → NE | X |
| 111 → 101 | 0220484 / 0220886 | NE → NE | X |
| 112 → 102 | 0220484 / 0010782 | NE → NE | X |
| 113 → 103 | 0220484 / 0140588 | NE → NE | X |
| 114 → 104 | 0220484 / 0140188 | NE → NE | X |
| 115 → 105 | 0220484 / 0140388 | NE → NE | X |
| 116 → 106 | 0220884 / 0220886 | C → NE | X |
| 117 → 107 | 0220884 / 0010782 | C → NE | X |
| 118 → 108 | 0220884 / 0140588 | C → NE | X |
| 119 → 109 | 0220884 / 0140188 | NE → NE | X |
| 120 → 110 | 0220884 / 0140388 | C → NE | X |
| 121 → 111 | 0220886 / 0010782 | C → NE | X |
| 122 → 112 | 0220886 / 0140588 | C → NE | X |
| 123 → 113 | 0220886 / 0140188 | NE → NE | X |
| 124 → 114 | 0220886 / 0140388 | C → NE | X |
| 125 → 115 | 0010782 / 0140588 | C → NE | X |
| 126 → 116 | 0010782 / 0140188 | NE → NE | X |
| 127 → 117 | 0010782 / 0140388 | C → NE | X |
| 128 → 118 | 0140588 / 0140188 | NE → NE | X |
| 129 → 119 | 0140588 / 0140388 | C → NE | X |
| 130 → 120 | 0140188 / 0140388 | NE → NE | X |

### A08

| Índice anterior → nuevo | Posición o par | Estado anterior → nuevo | Razón |
|---|---|---|---|
| 1 → 1 | 0140384 / 0010782 | C → NE | X |

### A08v_VGM

| Índice anterior → nuevo | Posición o par | Estado anterior → nuevo | Razón |
|---|---|---|---|
| 1 → 1 | 0140384 / 0010782 | C → NE | X |

