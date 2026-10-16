# T-96 · Aceptación cruzada

Capitán Codex · 16-oct-2026 · Guatemala.

**Veredicto: T-96 aceptada.** Suite **842/842**, analyze **0**, corpus **135/135**. El cotejo independiente coincide por número y por cada campo; aviso de buque conforme. Honor, Windows y Web verifican las cuentas, el ejemplo, el filtro y la comparación con la llegada de T-82. El archivo comparado no se guarda; la huella real solo añade `t96cx_*`. Honor termina en letra **1.0**. Web en el integrado autorizado, con dos desplazamientos manuales de Carlos declarados abajo.

## 1. Objeto, base y aislamiento

Se aceptan T-96 de Timonel, commit `0011882`, y la corrección del aviso de buque de 10.61, `adc9ea4`. Se leyeron la ficha de Ola 6 y las decisiones vigentes de `SPRINT-3.md`, el informe `docs/T96-RESULTADOS.md`, incluida su sección 9, y los cambios de ambos commits. Se respetó el orden: T-56 se cerró primero, con los 56 s manuales de Carlos y la reapertura de 216 tomas.

Base: **`f59afafc801e2b2c4699f2c0c47111545f6bf77a`**, HEAD de `sprint-3`. Copia en `C:\Users\Giova\AppData\Local\Temp\baystream-t96cx-f59afaf\base`; evidencias en su carpeta superior, en adelante **E**. Exportación mediante Git de solo lectura; 402 archivos coincidentes al normalizar finales de línea y materializados con los mismos bytes del árbol para cotejar los SHA. La guardia final confirma esos 402 archivos idénticos al repositorio y el mismo HEAD.

Carlos cedió Flutter y los dispositivos. Se ejecutó un comando de Flutter cada vez, sin interferir con las mediciones. No se modificó producción ni se ejecutó Git de escritura, `git status` o publicaciones.

Clientes: namespace **`t96cx`**, Android **`gt.cmartinez.baystream.t96cx`**. Solo en TEMP se adaptó `tool/t96_main.dart` para el namespace y la sincronización local, el applicationId y los assets del corpus en `pubspec.yaml`. El banco conserva `LocalSessionRepository`, sustituye únicamente el selector de comparación y prepara la operación de prueba; lector, comparación, pantallas y escritor son los del producto. No se copian estas adaptaciones al repositorio.

El banco preexistente inicializa el SDK de Firebase; no se inició sesión ni se hicieron operaciones de Firebase, autenticación, sincronización o publicación. Se impuso `LocalOnlyOperationSync`. El archivo de `--dart-define-from-file` se pasó a las compilaciones sin abrirlo ni volcarlo.

## 2. Validaciones del HEAD, antes de adaptar el banco

| Validación | Resultado | Evidencia en E |
|---|---:|---|
| Suite completa | **842/842**, piso de HEAD | `suite.log` |
| Analyze | **0 incidencias** | `analyze.log` |
| Directivas `// ignore:` en lib/test | **ninguna** | `no-ignores.json` |
| Corpus completo, 34 archivos | **135/135** | `corpus.log`, `corpus-file-count.txt` |

Compilaciones finales Android, Windows y Web: salida 0, registros `build-android.log`, `build-windows.log`, `build-web.log`. No se ejecutó `flutter test --platform chrome`. Las advertencias de compilación sobre deprecaciones Android, ruta TEMP de MSBuild y fuentes Web se conservan en los registros; no hubo errores.

## 3. SHA protegidos

Los once coinciden exactamente con la sección 5 del informe de Timonel, antes y después de las validaciones, y en la guardia final del repositorio. Registros: `protected-sha-baseline.json`, `protected-sha-after-validations.json`, `final-source-guard.json`.

| Archivo | SHA-256 |
|---|---|
| `firestore.rules` | `0112510984D9A16364F9752E243999C47306E0BCF82766E380DB380E8FE8E60A` |
| `lib/main.dart` | `C5189B1D8711837A05C68306D424C9FDBCC977BA3BBB6C823089FFE4CA5339D5` |
| `pubspec.yaml` | `1B40E5308D3D1594EAFBF48EE578ABB73A39DC2E3FE0A4551F0D1AC6956F38EA` |
| `pubspec.lock` | `577D742E04143131BC02A1BBB6C246D298C90396E08F6C9DFE393637A2617F53` |
| `lib/latency_test_screen.dart` | `599310DB13A713E82FC0D6A411BE2D7757CBC2B803D772C1CAA16C471725CDFF` |
| `lib/c3_reconciliation_screen.dart` | `3AF478364A8C5386E1F921E0142DC4F847594BECA00B6743563CB09A8A4112A5` |
| Lector `baplie_parser_service.dart` | `D34FE7F5D12AABD25119382305315747601D6AC77AC97CFD817911E02FF94B7C` |
| Escritor `departure_baplie_writer.dart` | `05EE91981499215E9981094EE3C3230C00AB98C54F4793B8750880D23E656147` |
| Codec `firestore_operation_sync.dart` | `EA63A21606865495E3B189800184871433F24AC775C0E6D0C044CD7EF4C0E974` |
| Modelo `container_unit.dart` | `6DAF61CD1C5EEF19711E80FD910B56A63C7412E902594B36F117971DE65C32EC` |
| Modelo `vessel_voyage.dart` | `2F527E1952BB425667020E923043736955A47208CDFB945740C7D0D691BEE1D9` |

**`pubspec.yaml` y `pubspec.lock` del repositorio no cambian. Sin dependencias nuevas.**

## 4. Cotejo independiente del texto crudo

Se volvió a ejecutar el script externo de preparación `C:\Users\Giova\AppData\Local\Temp\baystream-t96cx-preparacion-20261016\t96cx_raw_comparison.py`, SHA-256 **`c77be42c1e38f523e45e8a587ec56039003712bede26be4aac098fd92c679b5d`**. Usa solo Python estándar y segmentos EDIFACT crudos, incluidos escapes y UNA; no importa el lector ni las pruebas de BayStream. Agrupa LOC/EQD, identifica contenedores por número y trata separadamente los EQD sin número. Peso efectivo: VGM cuando existe; en otro caso WT, con `Decimal`.

Entradas: corpus anonimizado local, con SHA registrados en `client-input-sha.json`. Salidas completas por número y campo en `raw-independent/`, resumen en `raw-independent.log`.

| Comparación | Descargados | Cargados numerados | Reservas primero/segundo | Permanentes | Con cambios | POL | POD | Línea | Peso |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| A07 → A08 | **114** | **121** | **0/55** | **284** | **262** | **127** | **189** | **58** | **113** |
| A07 → A08v_VGM | 114 | 121 | 0/55 | 284 | 262 | 127 | 189 | 58 | 113 |
| A08 → A07 | **121** | **114** | **55/0** | 284 | 262 | 127 | 189 | 58 | 113 |

No hay cambios de posición, ISO, estado, mercancía peligrosa ni temperatura entre los permanentes. A08 y A08v tienen los mismos 405 números, 55 reservas y pesos efectivos: **cero diferencias**.

Una sonda externa de Dart, `production-probe.dart`, ejecutó lector y comparador reales del HEAD. Python cotejó **todos los números**, las tres clasificaciones y **cada valor antes/después de los 262 permanentes con cambios** contra el cálculo crudo, también en sentido inverso. Todo coincide: `independent-vs-production.json`, `raw-independent/reverse-verification.json` y los detalles correspondientes. La sonda de producción se usa para contrastar, no para construir el resultado independiente.

## 5. Aviso de buque de 10.61

La sonda propia y las pruebas incluidas en la suite confirman:

- **A07 → A08:** sin aviso; mismo indicativo.
- **A05 → A06:** «No se puede confirmar que sea el mismo buque: BUQUE ECO se identifica por indicativo ZZC5603 y BUQUE ECO, por IMO 9000039. Confirma que es el mismo buque antes de usar la comparación.» Se nombran el tipo y el valor en palabras.
- **Dos IMO distintos con el mismo nombre:** «No parece el mismo buque: BUQUE AUDITORIA (imo:9000001) y BUQUE AUDITORIA (imo:9000002).» No se confunden con las claves de distinto tipo.

No hay botón ni estado de aprobación del buque: «pide confirmar» es el aviso textual acordado en 10.61. Evidencia: `production-probe.json`, `independent-vs-production.json` y los casos T-96 de la suite/corpus.

## 6. Clientes, sin cuenta

| Caso | Honor | Windows | Web |
|---|---|---|---|
| A07 abierto → Comparar con otro BAPLIE, A08 | Conforme | Conforme | Conforme |
| 114 / 121 / 284; 262 con cambios; reservas 0/55 | Conforme | Conforme | Conforme |
| POL 127, POD 189, línea 58, peso 113 | Conforme | Conforme | Conforme |
| 0020310, XSPU8166070: «Peso 24 260 → 24 200 kg» | Visible | Visible | Visible |
| Solo con cambios | Conforme | Conforme | Conforme; desplazamiento asistido |
| Recientes después de comparar | Solo A07, 398 | Solo A07, 398 | Solo A07, 398 |
| T-82 → Comparar con la llegada | Conforme | Conforme | Conforme |

Se vio XQFU3540645 · 0150606 con «Sin cambios» al quitar el filtro, y se volvió a activar «Solo con cambios». Capturas y árboles `honor-*`, `windows-*`, `web-*`. La búsqueda del ejemplo se hizo en los tres clientes, incluido el Honor.

La Web se probó en el **navegador integrado, autorizado expresamente por Carlos**, visible, servido por HTTP local; **no se declara una aceptación en Chrome**. El integrado no permitió al agente desplazar la lista interna con sus controles disponibles. Carlos hizo únicamente los dos desplazamientos hasta XQFU3540645 y XSPU8166070; Capitán observó y guardó ambos resultados. No se atribuye al agente ese gesto manual.

Para T-82, el banco preparó una operación local con A07 como llegada conservada, A08 como plan, listado y los 177 eventos del caso. En **los tres clientes**, la salida del escritor real muestra **460 a bordo, 0 pendientes**, y «Comparar con la llegada» da **114 / 176 / 284, 262 con cambios**, reservas 0/0 y los mismos 127/189/58/113. Los 176 son 121 números del plan más las 55 reservas ya asignadas; coincide con la ficha y el informe. Se comparó en memoria, **sin pulsar Guardar BAPLIE de salida**. Evidencia `honor-departure-comparison.*`, `windows-departure-comparison.*`, `web-departure-comparison.*`.

## 7. Honor a 360 dp, letra 2.0

Honor AJ5TBB6531101024: 720 × 1600, densidad 320, equivalente a **360 × 800 dp**. Se comprobaron encabezado, cuentas, reservas, resumen por campo y el ejemplo desplazándose en **claro y oscuro, letra 2.0**. Texto legible y distribuido en varias líneas; no se pierde información al desplazarse. La barra de pestañas es horizontalmente desplazable.

Evidencias `honor-header-{claro,oscuro}-2.*`, `honor-fields-{claro,oscuro}-2.*`, `honor-example-{claro,oscuro}-2.*`. Volcados XML sanitizados en memoria antes de imprimir o guardar; contraseñas y formularios de cuenta se descartan. **Letra restaurada a 1.0**, verificada por ADB: `honor-font-final.json`.

## 8. Almacén real de Windows

Las dos instancias sucesivas del ejecutable final se abrieron con **`explorer.exe`**. La segunda, PID **24792**, se cerró por ese PID después de comprobar la ruta completa; no se abrieron dos instancias a la vez. Almacén real: **`C:\Users\Giova\AppData\Local\BayStream`**.

Huella mediante BAT lanzado con `explorer.exe`, fuera del paquete, con ascendencia anotada:

| Momento | Archivos | Proceso padre ← abuelo |
|---|---:|---|
| Antes | **426** | cmd 15396 ← explorer 26524 |
| Después de comparar A08, antes de preparar operación | **438** | cmd 25632 ← explorer 18116 |
| Final, tras T-82 y cerrar | **438** | cmd 23868 ← explorer 20532 |

**Los 426 anteriores conservan su SHA; no hay bajas ni modificaciones. Solo se añaden 12 `t96cx_*`**, seis cajas y sus locks. Evidencia `store-before.json`, `store-after-compare.json`, `store-final.json`, `store-comparison.json`, BAT y script de huella.

Antes de preparar deliberadamente el plan de A08 para T-82, un segundo BAT externo copió las seis cajas `t96cx_*.hive`. La auditoría se ejecutó **solo sobre esas copias**: un único viaje **A07, 398 contenedores**, todos sus números coinciden con A07, cero reservas y cero movimientos; **ningún rastro de CORPUS_A08 en ninguna caja**. Recientes también mostraba únicamente A07. Así se distingue comparar transitoriamente un archivo de la posterior preparación intencional de la operación. Registros `snapshot-compared-store.json`, `store-audit-after-comparison.json`, `audit-store-copy.dart`, `store-audit.log`.

## 9. Incidencias de instrumentación y límites

- Un control externo del filtro esperaba inicialmente un permanente sin cambios entre las primeras filas; el cotejo crudo mostró que el primero ocupa el índice 19. Se corrigió la búsqueda de evidencia, sin modificar producto ni pruebas.
- En Windows hubo índices de accesibilidad caducados y capturas de la ruta anterior durante transiciones. Se volvió a observar la ventana y se usaron coordenadas de la captura vigente. No se interpretaron esos fallos como un resultado del producto.
- La asistencia manual de Carlos en los dos desplazamientos Web queda declarada en la sección 6.
- No se arregló ningún defecto de paso, ni se tocaron las áreas protegidas. Las evidencias y adaptaciones permanecen en TEMP.

## 10. Entrega

Único archivo de esta aceptación en el repositorio: **`docs/T96-ACEPTACION-RESULTADOS.md`**. La tarea anterior modifica únicamente su propio informe `docs/T56-ACEPTACION-RESULTADOS.md`, con cierre manual aceptado. Producción y `pubspec.*` del repositorio intactos.

**Veredicto definitivo: T-96 aceptada**, incluidos `0011882` y `adc9ea4`. No se detectó discrepancia del producto respecto de los criterios solicitados. Se cerraron Windows por PID, la app de prueba del Honor, la pestaña y el servidor local. Honor conserva letra 1.0.

**SEMÁFORO:** terminadas T-56 y T-96; Honor, Windows y Flutter quedan libres para Timonel. Carlos transmite el aviso.

Tres líneas:

- El cálculo crudo confirma 114 / 121 + 55 / 284, 262 con cambios, y 127 / 189 / 58 / 113; VGM e inversa coinciden.
- Los tres clientes y el aviso corregido pasan; Windows conserva sus 426 archivos previos y solo añade 12 `t96cx_*`.
- T-96 aceptada con 842 pruebas, analyze cero y corpus 135; solo cambia este informe.

**Mensaje para Yov:** T-96 aceptada sobre HEAD f59afaf, incluidos 0011882 y adc9ea4. Suite 842/842, analyze 0 y corpus completo 135/135. Los once SHA protegidos siguen exactos, incluido el escritor T-82 05EE9198… El cotejo Python externo, sin lector de BayStream, coincide por todos los números y valores: A07→A08 y A08v, 114 descargados / 121 cargados + 55 reservas / 284 permanentes, 262 con cambios, POL 127, POD 189, línea 58, peso efectivo 113; la inversa intercambia las clases y valores. Avisos: A07→A08 ninguno; A05→A06 pide confirmar con indicativo e IMO en palabras; dos IMO distintos con el mismo nombre dicen «No parece el mismo buque». Los tres clientes muestran el ejemplo 0020310 y el filtro; T-82 compara la llegada con la salida de 460 a bordo: 114/176/284 y los mismos cambios. El archivo comparado no entra a Recientes ni al almacén, comprobado antes de preparar deliberadamente la operación de T-82. Huella real externa 426→438, los 426 intactos y solo 12 t96cx_* nuevos. Honor 360 dp, letra 2.0, claro/oscuro, restaurada a 1.0. Web en integrado autorizado: Carlos hizo dos desplazamientos de lista y Capitán verificó las capturas. Producción y pubspec.* del repo intactos. T-56 ya aceptada con 56 s manuales de Carlos y 216 propuestas al reabrir. Informes docs/T96-ACEPTACION-RESULTADOS.md y docs/T56-ACEPTACION-RESULTADOS.md. Dispositivos y Flutter libres; Carlos pasa el semáforo a Timonel.

Comandos para Carlos, solo este requerimiento:

```powershell
git add -- docs/T96-ACEPTACION-RESULTADOS.md
git commit -m "Sprint 3: aceptar T-96 con cotejo independiente y tres clientes"
git push
```
