# Bloque 7, primera mitad — T-38 y T-41

Capitán Codex · 29-sep-2026 · Base inspeccionada: 08768b1.

## Resultado y alcance

Implementadas T-38 y T-41. T-39, T-40 y el panel conjunto T-42 no se implementaron.
No se ejecutó Git de escritura ni se publicó Firebase. No cambiaron `pubspec.yaml`,
`pubspec.lock`, `lib/main.dart`, opciones Firebase ni archivos H5 congelados.
Los cuatro entregables de tesis que ya tenían cambios se dejaron intactos.

T-38 establece `StowageValidationResult`: regla, estado de evaluación, severidad,
descripción, posiciones, identificadores de contenedor y referencias. Las listas
del resultado son copias inmutables. Estado y severidad son independientes: no
evaluar no equivale a aprobar. Las próximas validaciones pueden reutilizarlo.

`StackWeightValidator` reutiliza los pesos por fila y zona de `Bay`, con la
frontera del perfil. Solo produce alerta al superar estrictamente el límite;
con `null` devuelve cero alertas. No suma las sombras de 40 pies. El provider
consulta el perfil publicado, nunca el borrador de otro buque, y no depende del
filtro visual de naviera. Los indicadores de peso existentes siguen funcionando;
la presentación conjunta de estos resultados corresponde a T-42.

T-41 implementa los 28 pares y 17 entradas ONU documentados, con citas en cada
entrada. Incorpora secundarios de la tabla ONU y etiquetas C236 recibidas;
UN1950 se trata como clase 9 y los grupos 1.4S/G proceden del ONU. Los desconocidos,
grupos ácido/álcali, unidades no confirmadas como cerradas, posiciones insuficientes
y alternativas estructurales desconocidas salen como **no evaluados**, con motivo.
La pantalla específica de segregación se abre desde el resumen del viaje.

Texto y código declaran **49 CFR Parte 176, apoyo a la decisión, no verificación
de cumplimiento**. No se afirma que sea IMDG ni equivalente. La separación por
huecos se rotula como derivación: no se conocen las distancias reales en metros.
Los resultados «conformes en las reglas evaluadas» no certifican el viaje.

## Corrección necesaria del parser y compatibilidad

Antes solo persistía el último DGS de cada contenedor. Ahora conserva todos,
incluidos duplicados y declaraciones truncadas, además de C236. Se mantienen
`imdgClass` y `unNumber` para no romper consumidores anteriores. El nuevo campo
opcional `dangerousGoods` viaja por el JSON de contenedores existente: sigue
habiendo una sola copia de cada contenedor en Hive.

Un registro peligroso antiguo sin lista completa se abre, pero T-41 devuelve
«no evaluado» y pide reimportar BAPLIE. No se inventa que el último DGS era el
único. Es una extensión compatible del esquema existente, no una migración
destructiva ni un cambio de versión obligatorio.

## Pruebas

- Suite anterior: 209. Suite final: **237/237** (`flutter test --concurrency=1`).
- **28 tests nuevos**: cinco de peso/contrato, diecinueve de segregación/parser
  y cuatro de presentación. Ninguna prueba ni aserción preexistente se eliminó.
- Un test adicional externo en `tool/block7_corpus_test.dart`, ejecutado sobre
  los seis archivos reales: aprobado. No se cuenta dentro de los 237.
- `flutter analyze`: **No issues found**, cero avisos.
- Una corrida intermedia obtuvo 236 aprobados y un timeout de `pumpAndSettle`
  en la prueba existente de Recientes. La corrida completa final sin concurrencia
  pasó 237/237; no se modificó ese test para hacerla pasar. No se estableció la
  causa del timeout.
- Roundtrip JSON/Hive: conserva declaraciones y resultados; cierre y reapertura
  del almacén; providers independientes del filtro; quitar el límite invalida
  los resultados de peso anteriores.

### Corpus real

Se usaron A01–A06 primarios; no se contó A03v_VGM.
Los resultados cuentan **comparaciones entre declaraciones DGS**, no solo pares
de contenedores; también hay resultados individuales de datos no evaluables.

| Archivo | Contenedores | DGS | Unidades peligrosas | Conforme limitado | Posible incumplimiento | No evaluado |
|---|---:|---:|---:|---:|---:|---:|
| A01 | 977 | 4 | 4 | 6 | 0 | 0 |
| A02 | 806 | 3 | 2 | 3 | 0 | 0 |
| A03 | 369 | 23 | 20 | 151 | 2 | 100 |
| A04 | 979 | 2 | 2 | 1 | 0 | 0 |
| A05 | 736 | 1 | 1 | 0 | 0 | 1 |
| A06 | 717 | 1 | 1 | 0 | 0 | 1 |

Total: **34 DGS en 30 contenedores**. A01 conserva sus **977 contenedores y 34
bahías**; con 75000 kg exclusivamente como dato de prueba produce **33 pilas
con exceso**, cero al retirar el límite y cero pilas ficticias por sombras.
Ese número no se propone como límite operativo de ningún buque.

### Los dos casos obligatorios de A03

- **UN3084, 0140784:** hay dos DGS idénticos, ambos sin etiquetas. Se incorpora
  5.1 y se exige código 2 frente a las cuatro unidades clase 3 del mismo nivel
  (0140284, 0140384, 0140484, 0140084). Matiz respecto al diagnóstico: en estas
  posiciones reales la separación transversal alcanza un hueco completo; por
  ello no se fuerza una alarma. La prueba real exige que se aplique 5.1/código 2,
  y una prueba adyacente controlada demuestra el rechazo cuando no hay separación.
  Evaluar solo 8/3 omitiría esa exigencia, aunque aquí el resultado espacial sea
  conforme dentro del modelo. La comparación de los dos UN3084 idénticos no
  supone compatibilidad química: queda no evaluada por §176.83(a)(8).
- **UN1950, 0260186 sobre UN3085, 0260184:** se aplica código 126 y no se emite
  la falsa alarma vertical de 2.1/5.1. El resultado global es **no evaluado** por
  los grupos pendientes de UN3085; no se convierte esa excepción en conformidad
  integral.

## Ejecución por cliente

Se generó una sonda fuera de `lib/`, con namespace aislado `block7_20260929`.
Usa los servicios, Hive y providers reales y embebe los seis archivos para QA.
No es el lanzador de producción y no sustituye una revisión manual completa.

| Cliente | EJECUTADO | COMPILADO adicional / límites |
|---|---|---|
| Chrome real, extensión conectada | Sonda release: `BLOCK7_PASS`; IndexedDB, corpus completo, reapertura, providers. Vista real de segregación de A03 inspeccionada, con 2/100/151 resultados y fuentes. Build final: arranque, carga A03, confirmación del perfil con límite nulo y apertura de segregación; se verificaron los mismos totales y tarjetas «No evaluado» con motivo y fuente. | Sonda y build final release. Orígenes locales de QA 8787 y 8788, separados del 8786 previo. |
| Windows | Sonda release: `BLOCK7_PASS` observado en texto accesible y ventana. Build final: arranque confirmado por árbol accesible de BayStream. | Compilado release final. La inspección visual completa de su flujo no se considera realizada: índices de control caducaban y una captura devolvió otra ventana. |
| Android, Honor X5d | APK sonda release **instalado y ejecutado**: `BLOCK7_PASS` en logcat. APK final **reinstalado y lanzado**, proceso confirmado. | Compilado release final. No se hizo recorrido manual completo de la nueva pantalla en el teléfono. El log Android recorta la línea larga, pero conserva el marcador emitido solo tras completar todas las aserciones. |

En Windows, el primer intento con dos instancias de la sonda chocó con el bloqueo
de Hive; se cerraron las instancias creadas para QA y se repitió. El lanzador de
sonda también se corrigió para tolerar más de un A03 de ensayos previos. La
ejecución que sustenta el resultado es la posterior, con PASS. La instancia
Debug anterior de Carlos no se cerró.

Después de las sondas se añadió la regresión de DGS truncado. Está en la suite
final y en los tres builds finales; la matriz y los datos reales de las sondas
no cambiaron. No se afirma una segunda ejecución de las sondas con ese caso nuevo.

### Evidencia local y reproducción

Los artefactos siguientes están en `build/` (ignorados, no se versionan):

- `build/block7/all-tests-final.log`, `analyze-final.log`, `corpus-results.json`.
- `build/block7/chrome-probe.json`, `chrome-segregation.png`, `windows-probe.txt`,
  `android-probe.log`.
- `build/block7/chrome-final-segregation.png`, `chrome-final-no-evaluado.png`:
  evidencia del recorrido del build final, sin el lanzador de sonda.
- `build/block7/*-build.log`: builds de sondas y app final.
- Sonda generada: `build/block7_probe/probe.dart`; corpus incrustado solo en build.

Preparación reproducible: `tool/prepare_block7_probe.ps1 -CorpusDirectory <ruta>`;
compilar su target `build/block7_probe/probe.dart` en cada cliente. Para el test
de corpus, pasar `--dart-define=BAYSTREAM_CORPUS_DIRECTORY=<ruta>` a
`flutter test tool/block7_corpus_test.dart`. La sonda no requiere Firebase.

SHA-256 de los builds finales verificados (antes del ajuste posterior de
indentación, sin cambio de comportamiento):

- APK: `9B4E56729587D6459DE55F7935338909F24B5104C580631CDB37293163A57689`.
- EXE: `691BA48778FCAE46523617D71D4A4BDCE1B33882DAECC67636C0BC097BAC0822`.
- Web main.dart.js: `0501C51F094E37BD4F6FAA301F83A20979707D454DDE7620B8C1A397550E93D8`.

Fuente de alcance leída completa: `docs/T41-SEGREGACION-FUENTE.md`.
Contraste adicional: edición oficial 2024 de
[49 CFR Parte 176 en GovInfo](https://www.govinfo.gov/content/pkg/CFR-2024-title49-vol2/pdf/CFR-2024-title49-vol2-part176.pdf).
El eCFR vigente no fue accesible desde la herramienta de consulta; no se presenta
ese contraste de 2024 como una verificación independiente de vigencia a 2026.
Las entradas ONU vigentes se toman de la verificación documentada por Timonel.

## Archivos de esta entrega y Git para Carlos

La lista exacta queda en las rutas explícitas de los dos bloques siguientes:
cinco archivos en T-38 y catorce en T-41, incluido este informe. Los archivos
de evidencia generados en build no forman parte de los commits.

```powershell
git add -- lib/features/vessel/domain/entities/stowage_validation_result.dart
git add -- lib/features/vessel/domain/services/stack_weight_validator.dart
git add -- lib/features/vessel/presentation/providers/stack_weight_provider.dart
git add -- lib/features/vessel/presentation/providers/vessel_providers.dart
git add -- test/stack_weight_validator_test.dart
git commit -m "T-38: validar peso por pila contra el perfil y definir contrato comun"

git add -- lib/features/vessel/domain/entities/dangerous_goods.dart
git add -- lib/features/vessel/domain/entities/container_unit.dart
git add -- lib/features/vessel/data/services/baplie_parser_service.dart
git add -- lib/features/vessel/domain/services/segregation_rules.dart
git add -- lib/features/vessel/domain/services/dangerous_goods_validator.dart
git add -- lib/features/vessel/presentation/providers/segregation_provider.dart
git add -- lib/features/vessel/presentation/pages/segregation_page.dart
git add -- lib/features/vessel/presentation/pages/vessel_overview_page.dart
git add -- test/dangerous_goods_validator_test.dart
git add -- test/segregation_page_test.dart
git add -- tool/block7_checks.dart
git add -- tool/block7_corpus_test.dart
git add -- tool/prepare_block7_probe.ps1
git add -- docs/BLOQUE7A-RESULTADOS.md
git commit -m "T-41: evaluar segregacion por ONU con fuente 49 CFR y tres estados"
git push
```

## Recorrido corto pendiente de revisión humana

1. En el Honor con el APK final, importar A03 y confirmar su perfil.
2. Abrir «Revisar segregación · 49 CFR» y comprobar la advertencia y las cifras
   2 posibles incumplimientos, 100 no evaluados y 151 conformes limitados.
3. Revisar un no evaluado: debe mostrar razón, posición y fuente, sin presentarse
   como cumplimiento IMDG. Repetir la inspección visual en Windows.
4. Reabrir A03 desde Recientes y comprobar los mismos resultados; un viaje
   peligroso guardado antes de esta entrega debe pedir reimportación para T-41.

## Tres líneas y mensaje para Yov

T-38 define el contrato común y valida el peso del perfil, con null sin alertas.
T-41 conserva todos los DGS y evalúa por ONU con tres estados y fuente 49 CFR.
237 pruebas, corpus real y analyze cero; sondas ejecutadas en los tres clientes.

Yov: primera mitad del bloque 7 implementada (T-38/T-41), sin adelantar T-39,
T-40 ni T-42. 237/237 pruebas más el test externo del corpus, analyze cero.
A01 real: 33 pilas con exceso a 75000 kg de prueba, cero con null. A03 conserva
23 DGS en 20 unidades: 151 conformes limitados, 2 posibles incumplimientos y
100 no evaluados. Las sondas ejecutaron corpus/Hive/providers en Chrome,
Windows y Honor; el APK final quedó reinstalado y lanzado. Falta revisión manual
completa de la nueva pantalla en Honor y visual en Windows. El informe distingue
los alcances. Revisar el matiz de UN3084: aplica código 2, pero los cuatro pares
reales sí cumplen la separación por huecos; el caso adyacente controlado alerta.
UN1950/UN3085 queda no evaluado por grupos, sin falsa alarma. Fuente 49 CFR,
sin equivalencia IMDG. Comandos de dos commits listos para Carlos en este informe.
