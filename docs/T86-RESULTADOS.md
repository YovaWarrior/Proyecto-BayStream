# T-86 · Versión BAPLIE en la entrada

Capitán Codex · 12-oct-2026 · rama `sprint-3`.
Estado: **En revisión**, pendiente de aceptación de Timonel (decisión 10.18).

## Cambio

El lector valida UNH/S009 antes de extraer TDT o contenedores. Admite exactamente
`BAPLIE:D:95B:UN:SMDG20`, `SMDG21` y `SMDG22`, el mismo conjunto que el escritor
T-82. Rechaza otras versiones, asociaciones, liberaciones y agencias, cabeceras
incompletas, UNH dentro de la carga y archivos con varios mensajes.

El fallo tipado conserva el identificador declarado. La entrada de archivos añade
su nombre y muestra el aviso en la pantalla existente. Ejemplo:

> Archivo «T86_1x.edi»: Versión BAPLIE no admitida: BAPLIE:1:911:UN:SMDG15.
> BayStream lee la familia 2.x (SMDG20, SMDG21 y SMDG22).
> Pide una exportación compatible.

Un rechazo conserva el viaje anterior y no llega al almacén. El escritor,
las entidades persistidas y los adaptadores de persistencia no cambian.

## Corpus y fixtures

Antes de editar el parser se guardó una referencia de las nueve fuentes 2.x en
`%TEMP%\t86_baseline.json`. Después se cotejó el JSON completo de cada viaje,
incluidas bahías, contenedores, reservas y metadatos, excluyendo únicamente los
UUID generados en cada lectura: **nueve de nueve, sin diferencias**.

| Fuente | Asociación | Contenedores | Reservas | Peso efectivo, kg |
|---|---|---:|---:|---:|
| A01 | SMDG20 | 977 | 0 | 8 366 089.00 |
| A02 | SMDG22 | 806 | 0 | 10 719 976.00 |
| A03 | SMDG20 | 369 | 0 | 7 419 486.99 |
| A03v_VGM | SMDG20 | 369 | 0 | 7 419 486.99 |
| A04 | SMDG20 | 979 | 0 | 12 267 702.00 |
| A05 | SMDG22 | 736 | 0 | 11 210 489.02 |
| A07 | SMDG22 | 398 | 0 | 6 940 578.00 |
| A08 | SMDG20 | 405 | 55 | 6 899 700.00 |
| A08v_VGM | SMDG20 | 405 | 55 | 6 899 700.00 |

Los totales WT y VGM crudos también coinciden con la referencia. A05 conserva
su valor de coma flotante; la tabla lo presenta con dos decimales. Los corpus
T-66 y T-68 conservan sus oráculos: A07 en GTSTC da 0 cargas, 114 descargas y
284 de paso; A02 da 0/303/503; A08 da 121/0/284, con sus 55 reservas aparte;
A01 en GTPBR da 325/0/652.

A06 declara `BAPLIE:1:911:UN:SMDG15` y se rechaza en UNH antes de interpretar
su TDT y su carga. El CSV y el corpus externo no se modifican.

Fixtures nuevos, sintéticos y con TSTU:

- `test/fixtures/t86_smdg21.edi`: lectura completa; posición 0020182,
  ISO 45R1, lleno, GTSTC/PAMIT, línea TEST, WT 24 000 kg, VGM 24 200.5 kg,
  tara 2 185 kg, temperatura −18 °C y dos declaraciones peligrosas, ONU 1993/1760.
  El mismo fixture prueba SMDG20 y SMDG22 cambiando únicamente la asociación.
- `test/fixtures/t86_smdg31.edi`: rechazo de `BAPLIE:D:13B:UN:SMDG31`.
- `test/fixtures/t86_sin_unh.edi`: rechazo «sin UNH/S009 reconocible».
- Casos en `test/t86_baplie_version_test.dart`: 1.x, versión/liberación/agencia
  incorrectas, asociación ausente o desconocida, componentes extra, UNH ambiguo
  o fuera de cabecera, repositorio real sin acceso remoto y aviso a 360 dp.

## Pruebas anteriores adaptadas

No se borraron pruebas ni se marcaron como omitidas.

- `test/profile_loading_test.dart`: A06 ahora se rechaza sin crear ni publicar
  un homónimo; conserva la prueba de confirmación de identidad con el mismo TDT
  anonimizado dentro de un mensaje sintético 2.x.
- `test/vessel_identity_test.dart`: los TDT de A01–A06 se prueban dentro de
  mensajes sintéticos 2.x. Son pruebas del identificador del buque, no una
  afirmación de que el archivo completo A06 sea compatible.
- `test/baplie_parser_test.dart`: las regresiones de TDT abreviado y LOC+5 sin
  componentes opcionales siguen dentro de mensajes 2.x. Se completa S009 en
  sus cabeceras sintéticas y en las pruebas de reefer y peso efectivo.
- Los otros fixtures mínimos afectados reciben UNH 2.x sin cambiar sus
  contenedores ni sus expectativas. La ficha de T-68 usa Roboto como el corpus
  y los clientes: Ahem provocaba un desbordamiento al mostrar los nuevos
  metadatos de su fixture.
- Corpus con A06 adaptados: `tool/block2_corpus_test.dart`,
  `tool/block7_checks.dart` (usado por `block7_corpus_test.dart`),
  `tool/t68_corpus_test.dart`, `tool/t69_corpus_test.dart` y
  `tool/t82_corpus_test.dart`. A06 pasa a exigir el fallo tipado en UNH.
  En bloque 7 quedan 33 DGS/29 unidades peligrosas de las cinco fuentes
  compatibles: A06 aportaba una declaración en una unidad.
- Auxiliares con A06 adaptados: `block7b_corpus.dart`, `t44_corpus_parse.dart`,
  `t55_fila_central.dart`, `t55_tabla_segregacion.dart`,
  `t55_tomas_paridad.dart` y `t59_bahias_tomas.dart`. Los cruces de tomas de
  T-55 usan A01/A05, compatibles, en ambas direcciones; A06 comprueba el rechazo.
- Las salidas de los corpus históricos de bloques 2/4/7 y T-37/52/53 pasan al
  temporal del sistema. El almacén auxiliar compartido de pruebas también usa
  un directorio temporal. Ninguna salida del corpus de esta aceptación entra
  al repositorio.

## Calidad ejecutada

- **547/547 pruebas**, frente al piso 524: 23 nuevas de T-86.
- **`flutter analyze`: cero incidencias**.
- **34/34 pruebas dirigidas finales** de identidad y T-86, tras la corrección
  de los avisos de cadenas adyacentes; mismo total de suite, 547.
- **97/97 comprobaciones de corpus**: las 79 del sprint, 10 de T-86 y 8
  históricas adicionales, en una corrida completa.
- **6/6 scripts auxiliares** terminan con código 0 y verifican el rechazo
  esperado de A06 mediante `requireA06Rejection`.
- T-82 sigue dando 460/460 posiciones, reloj fijo estable, OR 12 con tara
  2 185 kg y exclusión/restitución del cancelado.

Registros de esta sesión, exclusivamente en `%TEMP%`:
`t86-suite-final.log`, `t86-analyze-final.log`, `t86-corpus-final.log` y
`t86-<nombre-del-auxiliar>.json`.

Primero se detectaron y corrigieron el desbordamiento del fixture de T-68,
seis avisos de cadenas adyacentes en su lista de identidad, tres avisos de
llaves en el banco y la expectativa antigua de A06 en T-69. Los resultados
anteriores corresponden a las validaciones finales; el análisis y la corrida
dirigida también verifican las correcciones de estilo posteriores a la suite.

Comandos reproducibles desde la raíz, uno de Flutter a la vez:

```powershell
flutter test --reporter expanded
flutter analyze
$corpusTests = Get-ChildItem tool -File | Where-Object { $_.Name -match 'corpus(_pdf)?_test\.dart$' } | ForEach-Object { 'tool/' + $_.Name }
flutter test @corpusTests '--dart-define=BAYSTREAM_CORPUS_DIRECTORY=C:\Users\Giova\OneDrive\Documentos\OneDrive\Desktop\Archivos .EDI\Anonimizados\files' --reporter expanded
```

La referencia previa es opcional para futuras corridas: la de esta sesión se
usó con `--dart-define=T86_BASELINE=<ruta temporal de t86_baseline.json>`.
Los conteos/pesos fijos y los oráculos T-66/T-68 no dependen de ese archivo.

## Clientes

**Pasa en los tres clientes**, en modo sin cuenta y sin publicar datos:

| Cliente | A07 | Rechazo 1.x | Rechazo 3.x |
|---|---|---|---|
| Windows, `t86acc` | 398 contenedores, 21 bahías, 6 940 578 kg, 114/0/284; plano dibujado | Archivo y SMDG15 completos; conserva A07 | Archivo y SMDG31 completos; conserva A07 |
| Honor, `.t86`, 360 dp | Mismas cifras y plano | Aviso completo, sin desbordamiento; conserva A07 | Aviso completo, sin desbordamiento; conserva A07 |
| Chrome visible | Mismas cifras y plano | Aviso completo; conserva A07 | Aviso completo; conserva A07 |

Windows se abrió con `Start-Process explorer.exe -ArgumentList <exe>`.
El almacén usado fue el real, `C:\Users\Giova\AppData\Local\BayStream\vessel_store`,
comprobado por sus archivos `t86acc_*`. Se cerró solo su PID, **11432**.
El Honor declara 720×1600 px y densidad 320: **360×800 dp**; se instaló solo
`gt.cmartinez.baystream.t86` y se cerró esa variante. Chrome se sirvió en
`http://127.0.0.1:8086`, con `document.visibilityState = visible`, namespace
`t86acc` en el almacén Web de ese origen. La pestaña propia y el servidor
se cerraron después del recorrido y de la captura de evidencia.

Capturas y XML del Honor en
`%TEMP%\baystream-t86-aceptacion\evidence`: `windows-a07.png`,
`windows-a07-plano.png`, `windows-rechazo-1x.png`, `windows-rechazo-3x.png`,
`honor-a07.png`, `honor-a07-plano.png`, `honor-rechazo-1x.png`,
`honor-rechazo-3x.png` y los cuatro equivalentes `chrome-*.png`.

El banco `tool/t86_main.dart` entrega el contenido del fixture al notifier real
en lugar del selector nativo. A07 se prepara y confirma con GTSTC; luego se
abre la pantalla normal de BayStream. Para 1.x/3.x se pulsa en esa pantalla
la acción normal «Cargar archivo BAPLIE»: su SnackBar y la conservación del
plano son los del producto. No se modifica `lib/main.dart` ni la pantalla.

La copia de aceptación y sus assets externos viven en
`%TEMP%\baystream-t86-aceptacion`; solo allí se agrega el asset A07 y se cambia
el applicationId de Android a `.t86`. Todas las compilaciones llevan
`--dart-define-from-file=C:\Proyectos\baystream-privado\firebase-prod.json`,
sin abrir ese archivo ni copiar `android/key.properties`.

El 1.x sintético del banco se obtiene del fixture SMDG21 cambiando su S009
a `BAPLIE:1:911:UN:SMDG15`; el 3.x usa `t86_smdg31.edi`. Ambos assets,
`T86_1x.edi` y `T86_3x.edi`, se prepararon solo en esa copia temporal.
El selector nativo queda fuera de este banco: el recorrido valida el notifier,
el parser, la pantalla del producto y su aviso, sin un cambio al selector.

Las compilaciones release terminaron: Windows **57.5 s** usando el SDK local,
APK **230.0 s**, Web **89.4 s**. La descarga inicial de Windows quedó sin
avanzar y luego empezó lentamente; se detuvo únicamente su CMake, PID 10524,
tras comprobar que pertenecía a esta copia T-86. Se recompiló usando
`FIREBASE_CPP_SDK_DIR` con el SDK 13.9.0 ya disponible en la copia T-82:
misma versión pedida por `firebase_core`, sin cambiar dependencias.
MSBuild avisó MSB8029 por compilar bajo `%TEMP%`; Android emitió notas de
APIs obsoletas/operaciones no comprobadas de plugins; Web emitió el aviso
de fuente CupertinoIcons. Los tres builds finalizaron correctamente.

Incidencias de captura: una llamada ADB emitió `FORTIFY: pthread_mutex_lock`
pero la app conservó su pantalla y todos los recorridos siguientes continuaron.
La primera evidencia guardada de Chrome ya no tenía el SnackBar, por su
duración; se repitieron ambos rechazos y se guardó el mismo fotograma que
mostraba cada aviso. Ninguna incidencia alteró los archivos de entrada.

## Archivos y límites

Sin cambios en `pubspec.yaml`, `pubspec.lock`, `lib/main.dart`, los congelados
H5, la persistencia de producción, las reglas o el escritor de salida.
No se usó la CLI de Firebase ni hubo publicaciones. No se introdujeron ni
inspeccionaron credenciales de usuario. Los cuatro documentos de tesis que ya tenían cambios al comenzar
quedan fuera de la entrega.

SHA-256 anterior y posterior:

| Archivo | SHA-256 |
|---|---|
| Reglas T-80 publicadas | `21894B7F43E59F856045473731B795D21F8373C5AC8A1D9FFF324334AC3C9000` |
| Escritor T-82 | `05EE91981499215E9981094EE3C3230C00AB98C54F4793B8750880D23E656147` |
| `lib/main.dart` | `C5189B1D8711837A05C68306D424C9FDBCC977BA3BBB6C823089FFE4CA5339D5` |
| `pubspec.yaml` | `14916474A1874780E0D5851F9AFB4AE46A4B6B75286D4B497919DE38B7509E9F` |
| `pubspec.lock` | `FAA283751D6D97B1F87059EA683B4CC12ED43DDF6E92A52C1B993A801A510C97` |

Las 43 rutas propias de esta entrega son:

- `lib/features/vessel/data/repositories/vessel_repository_impl.dart`
- `lib/features/vessel/data/services/baplie_parser_service.dart`
- `lib/features/vessel/presentation/formatters/vessel_error_message.dart`
- `lib/features/vessel/presentation/providers/vessel_providers.dart`
- `test/baplie_parser_test.dart`
- `test/baplie_reefer_parser_test.dart`
- `test/current_profile_parameters_test.dart`
- `test/dangerous_goods_validator_test.dart`
- `test/effective_weight_test.dart`
- `test/local_vessel_repository_test.dart`
- `test/profile_loading_test.dart`
- `test/reefer_profile_proposal_test.dart`
- `test/support/local_profile_test_support.dart`
- `test/support/t73_export_list_support.dart`
- `test/t68_port_of_call_test.dart`
- `test/t69_reserved_slots_test.dart`
- `test/t75_discharge_test.dart`
- `test/vessel_identity_test.dart`
- `test/vessel_voyage_persistence_test.dart`
- `test/t86_baplie_version_test.dart`
- `test/fixtures/t86_smdg21.edi`
- `test/fixtures/t86_smdg31.edi`
- `test/fixtures/t86_sin_unh.edi`
- `tool/block2_corpus_test.dart`
- `tool/block4_corpus_test.dart`
- `tool/block7_checks.dart`
- `tool/block7_corpus_test.dart`
- `tool/block7b_corpus.dart`
- `tool/t37_corpus_test.dart`
- `tool/t44_corpus_parse.dart`
- `tool/t52_corpus_pdf_test.dart`
- `tool/t53_corpus_pdf_test.dart`
- `tool/t55_fila_central.dart`
- `tool/t55_tabla_segregacion.dart`
- `tool/t55_tomas_paridad.dart`
- `tool/t59_bahias_tomas.dart`
- `tool/t68_corpus_test.dart`
- `tool/t69_corpus_test.dart`
- `tool/t82_corpus_test.dart`
- `tool/t86_corpus_support.dart`
- `tool/t86_corpus_test.dart`
- `tool/t86_main.dart`
- `docs/T86-RESULTADOS.md`

## Horas

Inicio: 12-oct-2026, 16:52:42 (Guatemala). Cierre del informe: 17:32:51. **0.67 h transcurridas frente a 3.0 h estimadas**. Incluye lecturas, implementación, validaciones, compilaciones, espera del SDK y aceptación en los tres clientes. No se declara una medición separada de trabajo activo.


## Git para Carlos

Codex no ejecutó estos comandos. Solo incluyen las 43 rutas propias.

```powershell
git add -- "lib/features/vessel/data/repositories/vessel_repository_impl.dart"
git add -- "lib/features/vessel/data/services/baplie_parser_service.dart"
git add -- "lib/features/vessel/presentation/formatters/vessel_error_message.dart"
git add -- "lib/features/vessel/presentation/providers/vessel_providers.dart"
git add -- "test/baplie_parser_test.dart"
git add -- "test/baplie_reefer_parser_test.dart"
git add -- "test/current_profile_parameters_test.dart"
git add -- "test/dangerous_goods_validator_test.dart"
git add -- "test/effective_weight_test.dart"
git add -- "test/local_vessel_repository_test.dart"
git add -- "test/profile_loading_test.dart"
git add -- "test/reefer_profile_proposal_test.dart"
git add -- "test/support/local_profile_test_support.dart"
git add -- "test/support/t73_export_list_support.dart"
git add -- "test/t68_port_of_call_test.dart"
git add -- "test/t69_reserved_slots_test.dart"
git add -- "test/t75_discharge_test.dart"
git add -- "test/vessel_identity_test.dart"
git add -- "test/vessel_voyage_persistence_test.dart"
git add -- "test/t86_baplie_version_test.dart"
git add -- "test/fixtures/t86_smdg21.edi"
git add -- "test/fixtures/t86_smdg31.edi"
git add -- "test/fixtures/t86_sin_unh.edi"
git add -- "tool/block2_corpus_test.dart"
git add -- "tool/block4_corpus_test.dart"
git add -- "tool/block7_checks.dart"
git add -- "tool/block7_corpus_test.dart"
git add -- "tool/block7b_corpus.dart"
git add -- "tool/t37_corpus_test.dart"
git add -- "tool/t44_corpus_parse.dart"
git add -- "tool/t52_corpus_pdf_test.dart"
git add -- "tool/t53_corpus_pdf_test.dart"
git add -- "tool/t55_fila_central.dart"
git add -- "tool/t55_tabla_segregacion.dart"
git add -- "tool/t55_tomas_paridad.dart"
git add -- "tool/t59_bahias_tomas.dart"
git add -- "tool/t68_corpus_test.dart"
git add -- "tool/t69_corpus_test.dart"
git add -- "tool/t82_corpus_test.dart"
git add -- "tool/t86_corpus_support.dart"
git add -- "tool/t86_corpus_test.dart"
git add -- "tool/t86_main.dart"
git add -- "docs/T86-RESULTADOS.md"
git commit -m "Sprint 3: T-86 validar version BAPLIE antes de leer la carga"
git push
```
