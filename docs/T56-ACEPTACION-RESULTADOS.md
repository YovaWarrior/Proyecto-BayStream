# T-56 · Aceptación cruzada

Capitán Codex · 16-oct-2026 · Guatemala.

**Estado: puntos 1–3 conformes; aceptación completa pendiente de los clientes y del almacén real (puntos 4–6).** No se declara T-56 aceptada todavía. No se encontró discrepancia en las comprobaciones ejecutadas.

## 1. Base y coordinación

- Base indicada por Carlos: `7a06c5d51377226a7c8e7babbaed5653ddab3756`, HEAD de `sprint-3`.
- Objeto de aceptación: T-56, `5b1d8a1`, y corrección de 10.57, `32a1a94`. La base también incluye T-96 y T-105.
- Referencias leídas: acuerdos de `AGENTS.md`, ficha vigente de T-56 al inicio de la Ola 6, decisiones 10.52/10.57 y contexto posterior de `SPRINT-3.md`, e informe `docs/T56-RESULTADOS.md`, incluida su sección 10.
- Copia de ejecución: `C:\Users\Giova\AppData\Local\Temp\baystream-t56cx-20261016\base`.
- Exportación de solo lectura con `git archive` del SHA indicado. Se cotejaron los 400 archivos de la copia con sus versiones del árbol actual; el contenido coincidía al normalizar CRLF/LF. Se materializaron los bytes actuales para conservar también los SHA de la sección 6 del informe. `git diff --stat --ignore-cr-at-eol` sobre las rutas exportadas no mostró diferencias respecto de la base.
- El repositorio no se utilizó para compilar ni ejecutar pruebas. No se cambió de rama ni se ejecutaron operaciones de escritura de Git.
- Carlos cedió primero Flutter para suite y analyze. Se le notificaron ambos resultados y se liberó el turno antes de pedir otro. Carlos cedió después el turno para corpus y cotejo. Al concluir se volvió a avisar que Flutter quedaba libre.
- Honor y Windows continúan reservados para Timonel, que acepta T-105. No se abrió ninguna app ni se utilizó ningún dispositivo en esta etapa.
- Namespace reservado para los clientes: `t56cx`; applicationId Android: sufijo `.t56cx`. Aún no se compiló ni instaló ese cliente.

## 2. Validaciones ejecutadas

Todos los comandos terminaron con código 0. No se ejecutó `flutter test --platform chrome`.

| Comprobación | Resultado observado | Registro |
|---|---|---|
| Suite completa de HEAD | **799/799**, piso vigente de 799 conservado; salida `00:42 +799: All tests passed!` | `suite.log` |
| `flutter analyze` | **0 incidencias**; `No issues found! (ran in 27.1s)` | `analyze.log` |
| Búsqueda de supresiones | Sin `// ignore:` ni `// ignore_for_file:` en `lib/` y `test/`; búsqueda con salida 1 por ausencia de coincidencias | Inspección con `rg` |
| Corpus completo `tool/*corpus*test.dart` | **135/135 en 34 archivos**; salida `00:47 +135: All tests passed!` | `corpus.log` |
| Sonda propia contra producción | Código 0; sin importar pruebas ni auxiliares de Timonel | `independent-validator.json` |
| Comparación del resultado de producción con el cálculo independiente sobre EDI crudo | Coinciden las 20 combinaciones fuente/origen, los cinco cruces, el escenario A01 y las dos uniones | `t56cx_compare.py` |

Se pasó al corpus `--dart-define=BAYSTREAM_CORPUS_DIRECTORY=<carpeta externa autorizada>`. Los 135 casos corresponden al HEAD actual, que ya incluye T-96; los 129 casos en 33 archivos del informe de T-56 eran su piso histórico.

Los registros y las sondas están fuera del repositorio, en `C:\Users\Giova\AppData\Local\Temp\baystream-t56cx-20261016`. El corpus anonimizado permanece en su carpeta externa; no se copió al repositorio.

## 3. SHA de la sección 6

Los ocho SHA coinciden exactamente con el informe de Timonel, en la copia antes y después de ejecutar las validaciones.

| Archivo | SHA-256 |
|---|---|
| `firestore.rules` | `0112510984D9A16364F9752E243999C47306E0BCF82766E380DB380E8FE8E60A` |
| `lib/features/vessel/domain/entities/vessel_profile.dart` | `70F26644CADDFF4FC2413A133FC3E336AD865EE0CFFB4164F428FF2B1F242EDF` |
| `lib/features/vessel/data/repositories/firestore_operation_sync.dart` | `EA63A21606865495E3B189800184871433F24AC775C0E6D0C044CD7EF4C0E974` |
| `lib/main.dart` | `C5189B1D8711837A05C68306D424C9FDBCC977BA3BBB6C823089FFE4CA5339D5` |
| `pubspec.yaml` | `1B40E5308D3D1594EAFBF48EE578ABB73A39DC2E3FE0A4551F0D1AC6956F38EA` |
| `pubspec.lock` | `577D742E04143131BC02A1BBB6C246D298C90396E08F6C9DFE393637A2617F53` |
| `lib/latency_test_screen.dart` | `599310DB13A713E82FC0D6A411BE2D7757CBC2B803D772C1CAA16C471725CDFF` |
| `lib/c3_reconciliation_screen.dart` | `3AF478364A8C5386E1F921E0142DC4F847594BECA00B6743563CB09A8A4112A5` |

**`pubspec.yaml` y `pubspec.lock` no cambian. No se agregaron dependencias.** No se modificó código de producción, reglas, perfil, codec ni congelados.

## 4. Cotejo independiente del validador

Se escribieron sondas propias **fuera del repositorio**, sin consultar ni reutilizar las pruebas de T-56 de Timonel:

1. `t56cx_raw.py` lee directamente los segmentos `LOC+147`, `EQD` y `TMP` de las diez fuentes. Extrae posiciones, tipos y refrigerados; calcula las bahías de bodega desde el texto crudo.
2. `t56cx_oracle.py` calcula por separado la regla del código exacto y la regla solicitada por celda sobre esa lectura del EDI, sin importar código de BayStream.
3. `t56cx_check.dart` importa exclusivamente código de producción de la copia: lector, entidades y `ReeferSocketValidator`. Construye los escenarios y comprueba los resultados con condiciones que lanzan error si no se cumplen. Se ejecutó con el SDK Dart y el `package_config.json` de la copia, sin incorporar la sonda a `test/` ni `tool/` del repositorio.
4. `t56cx_compare.py` contrasta automáticamente los JSON de ambas lecturas y exige que coincidan sus cifras.

La suite y el corpus completos sí incluyen las pruebas existentes de Timonel, como corresponde a la validación general. El cotejo de esta sección es adicional e independiente de ellas.

### Escenario de T-55 sobre A01

Desde los 50 refrigerados observados en A01 se construyeron 82 refrigerados de 20 pies en las impares vecinas de las tomas de 40, y nueve de 40 pies sobre las tomas de 20, conservando fila y nivel. El inventario se marcó declarado para este escenario de prueba.

| Resultado | Código exacto anterior | Validador de T-56 |
|---|---:|---:|
| Errores | **91** | **0** |
| Avisos de extremo | 0 | **82** |
| Conformes, sin alerta | 0 | **9** |

Los 82 resultados son `notEvaluated` con severidad `warning` y el texto de confirmación del extremo. El cálculo separado sobre el EDI crudo da exactamente las mismas cifras.

### Diez fuentes, cada una con su inventario

Se ejecutó cada fuente con su perfil propuesto y después con el mismo inventario marcado declarado: **20 combinaciones**. En todas, la regla anterior y la actual dan cero alertas; no aparece ninguna nueva. El número de refrigerados coincide también entre el lector de producción y la lectura independiente del EDI.

| Fuente | Refrigerados / tomas | Antes | Después | Nuevas |
|---|---:|---:|---:|---:|
| A01 | 50 / 50 | 0 | 0 | 0 |
| A02 | 14 / 14 | 0 | 0 | 0 |
| A03 | 10 / 10 | 0 | 0 | 0 |
| A03v_VGM | 10 / 10 | 0 | 0 | 0 |
| A04 | 71 / 71 | 0 | 0 | 0 |
| A05 | 91 / 91 | 0 | 0 | 0 |
| A06 | 91 / 91 | 0 | 0 | 0 |
| A07 | 12 / 12 | 0 | 0 | 0 |
| A08 | 8 / 8 | 0 | 0 | 0 |
| A08v_VGM | 8 / 8 | 0 | 0 | 0 |

### Cruces con inventario declarado y geometría de ambos viajes

| Inventario → carga | Antes | Después | Nuevas |
|---|---:|---:|---:|
| A05 → A06 | 0 | 0 | 0 |
| A06 → A05 | 0 | 0 | 0 |
| A07 → A08 | 0 | 0 | 0 |
| **A08 → A07** | **4** | **4** | **0** |
| A07 → A08v_VGM | 0 | 0 | 0 |

## 5. Las 21 bahías de A07 ∪ A08

**01, 02, 03, 05, 06, 07, 09, 10, 11, 13, 14, 15, 17, 18, 19, 21, 22, 23, 25, 26 y 27.**

La sonda de producción propone la geometría desde las posiciones de ambos viajes y une sus `observedHoldBays`. Da exactamente esa lista con A08 y con A08v_VGM.

El cotejo independiente reproduce la lista leyendo el texto EDI: posiciones `LOC+147` por debajo de 80 y, para los tipos de 40/45 pies en bahía par, sus dos impares vecinas. No utiliza el lector ni la función de bahías de BayStream. La comparación automática confirma ambas uniones.

## 6. Clientes y almacén real: pendientes de cesión

Estos resultados **no se sustituyen por las pruebas automatizadas ni por lo observado por Timonel**. Todavía no se ejecutaron en esta aceptación:

- **Windows, Honor y Chrome:** BUQUE GOLF propuesto desde A07, inicialmente 12 tomas; rango `002-026/4`, filas vacías, niveles `82-86, 94`; vista previa 204 / 6 / 70; guardar y reabrir con 216 y «Propuestas del archivo».
- **Honor y Windows con la compilación final:** cronómetro continuo desde abrir el perfil hasta «Perfil guardado», menos de un minuto.
- **Tres clientes:** lista `0020184 0060188, 12345 ABCDEFG 0000182 0021282 0100382`, resultado 1 / 2 / 1 y «No se cargan 3…»; quitar `002-026/4`, nivel 86, deja 147; diálogo con «Quitar no cambia la casilla de declaración.»; solo la casilla declara; la sección conserva su apertura después de alejarse y volver.
- **Honor, 360 dp, letra 2.0:** cinco textos en claro y oscuro, incluido A06 en GTPBR con «717 sin puerto de carga en el archivo»; devolver la letra a 1.0 al terminar.
- **Windows:** huellas anterior y posterior fuera del paquete, con `.bat` lanzado mediante `explorer.exe` y proceso padre documentado; diferencias exclusivamente en `t56cx_*`. La huella anterior se tomará cuando Carlos ceda el cliente, antes de abrirlo.

No se utilizó el navegador integrado. No se abrió el archivo privado de defines. No se accedió a Firebase ni se publicó nada. No se capturaron volcados del Honor ni se lanzó la app de Windows en esta etapa.

## 7. Evidencia y archivos de esta entrega parcial

Carpeta externa: `C:\Users\Giova\AppData\Local\Temp\baystream-t56cx-20261016`.

- Registros: `suite.log`, `analyze.log`, `corpus.log`.
- Sondas propias: `t56cx_raw.py`, `t56cx_oracle.py`, `t56cx_check.dart`, `t56cx_compare.py`.
- Resultados: `raw-corpus.json`, `raw-oracle.json`, `independent-validator.json`, `protected-sha.json`.
- Manifiesto de SHA de registros y sondas: `evidence-sha.json`.
- SHA-256 de la sonda Dart: `0D4FEDDC65E4F3ED0FD3666402E043548F40C45F07AC1E2F979A5A1F8188792D`.

**Único archivo creado o modificado en el repositorio por esta aceptación:** `docs/T56-ACEPTACION-RESULTADOS.md`. Los demás artefactos permanecen en `%TEMP%`.

## 8. Git para Carlos

Bloque exclusivamente para versionar este informe parcial si Carlos decide hacerlo; no implica que T-56 ya esté aceptada.

```powershell
git add -- docs/T56-ACEPTACION-RESULTADOS.md
git commit -m "Sprint 3: documentar validaciones y cotejo independiente de T-56"
git push
```

## 9. Tres líneas

Suite 799/799, analyze en cero, corpus 135/135 y ocho SHA conservados sobre el HEAD indicado.
Cotejo propio sobre A01 y diez fuentes conforme; A08 → A07 permanece en cuatro y las dos uniones dan las 21 bahías.
No cambia el producto; la aceptación completa espera los tres clientes, las mediciones y la huella del almacén real.

## 10. Mensaje para Yov

T-56: puntos 1–3 de la aceptación cruzada conformes sobre 7a06c5d51377226a7c8e7babbaed5653ddab3756, en copia de TEMP. Suite 799/799, analyze cero sin supresiones, corpus completo 135/135 en 34 archivos y ocho SHA de la sección 6 iguales antes y después. Una sonda propia fuera del repo, sin pruebas ni auxiliares de Timonel, ejecutó el validador de producción y coincidió con un cálculo independiente sobre EDI crudo: A01 91 errores → 82 avisos de extremo + 9 conformes; ninguna alerta nueva en las diez fuentes; A08 → A07 sigue en 4; A07 ∪ A08 y su variante VGM dan las 21 bahías exactas. Flutter quedó libre y Carlos fue avisado. Honor y Windows siguen con Timonel; faltan los puntos 4–6, por lo que T-56 todavía no se declara aceptada. Informe parcial: docs/T56-ACEPTACION-RESULTADOS.md. No se modificó producción ni pubspec.*.
