# T-82 · BAPLIE de salida desde el estado derivado

Capitán Codex · 11-oct-2026, hora de Guatemala · rama indicada `sprint-3`.

**Estado: En revisión para Timonel**, según la decisión 10.18. Implementación,
corpus y aceptación en Windows de oficina, Honor y Chrome completados. Carlos
resolvió la contradicción inicial: para los de paso manda loading_baplie en todos
los campos, con llegada como respaldo de lo no declarado. El CSV no se modifica.

## 1. Contradicción encontrada

La primera comparación estricta falló porque el borrador conservaba los datos de
A07 para los de paso, como pedía la ficha inicial. Se detuvo el trabajo y se presentó
la evidencia, conforme a AGENTS.md. Las diferencias eran reales, no un fallo del CSV.

Una inspección independiente de los segmentos de A07 contra las 284 filas
`a_bordo` de CASO_A08_ESTADO_FINAL.csv encontró:

| Campo | Contenedores de paso distintos entre A07 y CSV |
|---|---:|
| Posición | 0 |
| ISO | 0 |
| Lleno/vacío | 0 |
| Puerto de carga | 127 |
| Puerto de descarga | 189 |
| Línea | 58 |
| Peso efectivo, VGM o WT | 113 |

Los conjuntos se solapan. **256 de los 284** tienen al menos un puerto diferente.
Los cambios de puerto son CRMOB → CRPMN (127 POL), JMKCT → JMKIN (125 POD)
y PACCT → PAONX (64 POD). Los ejemplos se obtienen del corpus anonimizado,
no de archivos originales:

| Posición | A07 | CSV final |
|---|---|---|
| 0010782 | POD JMKCT | POD JMKIN |
| 0020310 | 24 260 kg | 24 200 kg |
| 0090806 | POL CRMOB, POD PACCT, línea LNB, 2 390 kg | POL CRPMN, POD PAONX, línea LNE, 2 300 kg |

**Decisión directa de Carlos, 11-oct, indicada para 10.20:** el plan de carga es la
información vigente al zarpar. Para los 284 de paso declara POL, POD, línea, peso y
peligrosas de loading_baplie; A07 respalda únicamente lo que el plan no declare.
Carlos retiró expresamente su instrucción anterior de conservar los pesos de A07.
La ficha del repositorio ya estaba corregida al reanudar; al corte de verificación
todavía no figuraba un apartado titulado 10.20. No se editaron SPRINT-3.md ni el CSV.

**Verificación previa solicitada:** A08 y A08v_VGM coinciden con el CSV en
**284/284 contenedores de paso y siete campos**, sin diferencias: posición,
contenedor, ISO, POL, POD, línea y peso. Se comprobó primero con una inspección
independiente de segmentos, antes de modificar el escritor. El script T-82 vuelve
a exigir esas mismas coincidencias con el lector de BayStream, antes de generar.

## 2. Código construido

- Escritor de dominio en Dart puro, sin Flutter, Firebase, almacén ni dependencias
  nuevas. Usa el plan efectivo y los ocupantes físicos del estado derivado.
- Cabecera de loading_baplie con el identificador completo de UNH conservado,
  buque/viaje conservados, controles UNB/UNH/BGM nuevos, fecha de preparación nueva
  y UNT/UNZ calculados. Rechaza la ausencia de fuente, versiones desconocidas,
  mensajes múltiples y separadores no reconocidos. Admite las asociaciones 2.x
  SMDG20, SMDG21 y SMDG22; el corpus ejercita SMDG20/SMDG22 y rechaza A06/SMDG15.
- Lo que sigue a bordo conserva los segmentos del plan vigente, incluidos FTX,
  temperaturas, declaraciones peligrosas y campos no modelados por el lector.
  Llegada respalda declaraciones ausentes por campo. WT/VGM forman una familia:
  un VGM viejo no se añade encima de un WT vigente; la tara se respalda aparte.
  La posición procede del estado físico, incluida una re-estiba.
- Los cargados se escriben desde el listado normalizado: ISO, puertos de descarga
  y transbordo, línea, lleno/vacío, peligrosas, VGM y tara exactos. POL es la escala
  en la que se cargaron. Los vacíos sin VGM llevan WT igual a su tara y MEA+T.
- La pantalla está accesible desde la pestaña de contenedores, para oficina
  autorizada y modo sin cuenta. Muestra pendientes de carga/descarga, permite
  generar parcial y muestra/copia cancelados con motivo. Toma el estado vigente
  al pulsar Guardar; el muelle no ofrece la acción.
- El guardado pasa por un contrato de dominio y usa FilePicker.saveFile con bytes
  UTF-8, igual que el mecanismo existente de exportación a PDF. Los tres clientes
  guardaron y reabrieron su archivo mediante el selector y lector reales.

## 3. Validaciones ejecutadas

| Comprobación | Resultado |
|---|---|
| Suite completa final | **524/524**, salida 0; piso 508 preservado |
| Pruebas nuevas | 16: diez de escritor y seis de pantalla |
| Analyze | **0 incidencias**, salida 0 |
| Corpus T-68 a T-82 | **68/68**, salida 0: 56 anteriores y 12 de T-82 |
| Corpus T-66 y T-67 adicional | **11/11**, salida 0; total Sprint 3 **79/79** en dos corridas |
| A08 y A08v_VGM | **460/460 en siete campos**, en cada variante |
| Versiones de A01–A08 y variantes | Nueve fuentes 2.x conservan UNH; A06/1.5 se rechaza |
| Reglas publicadas | SHA-256 sin cambio |
| Windows oficina, Honor y Chrome | Guardado y relectura **460/460** en cada cliente |

Las diez pruebas sintéticas comprueban conservación de declaraciones vigentes, VGM
7 266.59 kg sin truncar, tara 2 185 kg del OR 12 en 0030984, dos números ONU,
controles y conteos, pendientes excluidos de carga, descarga pendiente a bordo,
cancelación/annul, re-estiba, change_position/corrects, orden de recepción estable,
ida y vuelta con reloj fijo y errores sin inventar datos. Se añadieron prioridad
del plan con respaldo por campo y conservación del espacio reservado de UNA.

Las seis pruebas de pantalla verifican los roles y el modo sin cuenta, 360 dp
en ambos temas, guardar parcial mediante el contrato, copiar el motivo de OR 5,
recibir annul sin recargar y el mensaje por falta de loading_baplie.

**Corpus, en ambas variantes:** se reproducen los 177 eventos de carga/intercambio
y las 114 descargas de llegada; se genera en TEMP y se relee. Coinciden las 460
posiciones en contenedor, ISO, POL, POD, línea y peso. En los 284 de paso se cotejan
también WT/VGM, tara, lleno/vacío, DGS y temperatura con el plan de carga. En las
176 cargas se cotejan tara/VGM, lleno/vacío y todas las peligrosas con el listado,
incluidos los dos ONU del OR 127. OR 12 queda en R:0030984 con tara 2 185 kg.
OR 5 cancelado deja 459, desaparece del EDI y figura con motivo; annul devuelve
460 y deja vacía la lista. Texto idéntico en orden cronológico, inverso y mezclado
con semilla fija, y en generar → leer → generar con reloj fijo.

La primera suite dio 514 éxitos y dos fallos: el botón añadido al panel del plano
desplazaba una celda de la aceptación T-75 a 360 dp detrás de un aviso. Se retiró
esa integración y se colocó en la pestaña de contenedores; T-75 y la suite completa
volvieron a pasar. No se editaron sus pruebas. Analyze detectó llaves ausentes en
cuatro condiciones de la pantalla y una del test nuevo; se corrigieron, sin ignores.
Al ejecutarse por primera vez el criterio de ida y vuelta del corpus, apareció un
defecto propio: el recorte de segmentos quitaba el espacio reservado de UNA. Se
conservó ese espacio y se agregó la prueba de regresión; ambas variantes pasaron.
El banco nuevo tenía una llamada `bump` inexistente y avisos de llaves: se corrigió
a `changed`, se compiló y analyze final quedó en cero.

Evidencias locales de código: `build/t82/test-inicial.log`, `build/t82/widget.log`,
`build/t82/suite-final.log` y `build/t82/analyze-final.log`.
Evidencias de corpus fuera del repositorio: `%TEMP%\t82-corpus-completo.log`,
`%TEMP%\t82-corpus-pesos.log`, `%TEMP%\t82-corpus-vigente.log` y carpetas
`%TEMP%\baystream-t82-*` con A08-salida.edi y A08v_VGM-salida.edi. Las primeras
corridas fallidas quedan en `%TEMP%\t82-corpus.log`. No se copiaron fuentes ni
salidas al repo.

Las reglas `docs/T80-firestore.rules.propuesta` conservan el SHA-256 publicado:
`21894B7F43E59F856045473731B795D21F8373C5AC8A1D9FFF324334AC3C9000`.
No se modificaron reglas ni se usó Firebase CLI, credenciales de administrador,
H5 o consolas externas. Carlos realizó el acceso manual de oficina. No se
mostraron ni registraron correos, UID, contraseñas, tokens ni opciones privadas.

## 4. Aceptación de clientes

Banco propio `tool/t82_main.dart`: prepara una operación **local, sin publicar**,
con las fuentes anonimizadas y el OR 5 cancelado antes de las cargas. Omite esa
carga; después anexa annul y la carga del OR 5. Las pantallas de salida, el
guardado, la bitácora y el lector son los del producto. La comparación al abrir
el archivo usa el CSV externo empaquetado solo en la copia privada.

| Cliente | Recorrido observado |
|---|---|
| Windows, oficina autorizada | 459 a bordo y OR 5 con motivo; texto copiado comprobado en clipboard; annul/carga devuelve 460 y cero cancelados; guarda en TEMP y abre el archivo: 460/460 |
| Honor, modo sin cuenta, variante .t82 | 459 y motivo con copia confirmada por aviso; guarda cancelado en selector Android; annul/carga deja 460 y lista vacía; guarda completo y lo selecciona desde BayStream: 460/460 |
| Chrome visible, modo sin cuenta | 459 y OR 5 con motivo; annul/carga deja 460 y lista vacía; descarga completa y selección mediante filechooser: 460/460 |

Las compilaciones Windows, APK y Web release terminaron con salida 0 y opciones
`--dart-define-from-file=C:\Proyectos\baystream-privado\firebase-prod.json`, sin
abrir ni imprimir ese archivo. Copia externa: `C:\Proyectos\baystream-privado\t82-aceptacion`.
Solo esa copia declara los assets del corpus y cambia applicationId a
`gt.cmartinez.baystream.t82`; no se copiaron archivos de firma. Sin publicación
Web ni Play. Chrome se sirvió solo en `http://127.0.0.1:8085`.

Windows abrió mediante explorer.exe, PID **14208**, y se cerró normalmente por
ese PID. Almacén real comprobado: `C:\Users\Giova\AppData\Local\BayStream\vessel_store`,
cajas `t82acc_*.hive`, incluidas operación y movimientos. No se usó LocalCache.
La cuenta de oficina se confirmó como autorizada en la pantalla existente;
la operación no se publicó y la generación no escribe en Firestore.

Archivos de clientes: `%TEMP%\t82-windows-salida.edi`, `%TEMP%\t82-chrome-salida.edi`
y `%TEMP%\t82-honor-salida.edi`; cancelado Android extraído a
`%TEMP%\t82-honor-cancelados.edi`. En el Honor quedan los originales en
`/sdcard/Download/T82/`. **Incidencia declarada:** Chrome descargó inicialmente
en Descargas por su configuración habitual; al no notificarse el evento a la
herramienta, se comprobó la fecha/tamaño del archivo y se movió inmediatamente
a TEMP. No pasó por el repositorio. Los scripts de corpus siempre escribieron
directamente en TEMP.

Evidencia privada, en `t82-aceptacion/evidence`: Windows `windows-cancelado.png`,
`windows-restaurado.png`, `windows-relectura.png`; Chrome `chrome-cancelado.png`,
`chrome-restaurado.png`, `chrome-relectura.png`; Honor pares XML/PNG
`honor-cancelado`, `honor-guardado-cancelado`, `honor-restaurado`,
`honor-guardado-final`, `honor-relectura-final`. Logs de compilación en esa copia:
`windows-build.log`, `apk-build.log`, `web-build.log`.

La primera captura nativa devolvió una ventana ajena porque BayStream no estaba
activada; no se guardó esa captura como evidencia. Las siguientes observaciones
se hicieron activando explícitamente la app. Los índices accesibles de Flutter
caducaban y se usaron capturas actuales y coordenadas; los diálogos nativos se
inspeccionaron por sus campos. Durante el acceso de Carlos se omitieron los
contenidos de autenticación. Windows, la variante Honor, la pestaña Chrome y
el servidor local quedaron cerrados; semáforo liberado.

**Observación para T-96, de inspección de código:** BayPlanView abre el detalle
del contenedor del viaje visible. Si se abrió A07, ese detalle conserva sus
declaraciones, mientras la salida T-82 usa las vigentes de A08. El ejemplo de
0020310 es 24 260 frente a 24 200 kg. No se cambió esa pantalla ni se afirma
una aceptación manual específica del detalle de esa celda.

## 5. Horas

Estimación de la ficha: **10.0 h**. No se inició un cronómetro al primer mensaje.
La primera marca explícita fue **22:14:26** y el corte de entrega es
**23:06:42**, el 11-oct, hora de Guatemala: **52 min 16 s (0.87 h transcurridas)**,
incluidas compilaciones y espera de Carlos. No equivale a trabajo activo exacto.
La ventana anterior quedó documentada hasta aproximadamente 22:27, y se reanudó
a las 22:30:55. Sumarlas hasta la entrega da unos **0.80 h documentados**, más
las lecturas iniciales no cronometradas. La tarea queda por debajo de 10.0 h;
no se inventa una cifra exacta de horas activas. Pendiente solo la aceptación
cruzada de Timonel, conforme a 10.18.

## 6. Archivos propios

```text
lib/features/vessel/domain/services/departure_baplie_writer.dart
lib/features/vessel/domain/repositories/departure_export_repository.dart
lib/features/vessel/data/repositories/departure_export_repository_impl.dart
lib/features/vessel/presentation/pages/departure_baplie_page.dart
lib/features/vessel/presentation/pages/vessel_overview_page.dart
test/support/t82_fixture.dart
test/t82_departure_baplie_test.dart
test/t82_departure_widget_test.dart
tool/t82_corpus_test.dart
tool/t82_main.dart
docs/T82-RESULTADOS.md
```

**pubspec.yaml y pubspec.lock no cambian.** No se modificaron main.dart, opciones
Firebase, archivos congelados, AGENTS.md, SPRINT-3.md ni documentos de tesis ajenos.
loading_plan_controls.dart tuvo una integración temporal del botón que fue retirada;
no conserva cambios de contenido frente al commit de entrada.

## 7. Git para Carlos

Codex no ejecuta estos comandos. La única ruta bajo docs es el informe propio
exacto. No se incluyen los cuatro documentos de tesis que ya tenían cambios al entrar.

```powershell
git add -- lib/features/vessel/domain/services/departure_baplie_writer.dart
git add -- lib/features/vessel/domain/repositories/departure_export_repository.dart
git add -- lib/features/vessel/data/repositories/departure_export_repository_impl.dart
git add -- lib/features/vessel/presentation/pages/departure_baplie_page.dart
git add -- lib/features/vessel/presentation/pages/vessel_overview_page.dart
git add -- test/support/t82_fixture.dart
git add -- test/t82_departure_baplie_test.dart
git add -- test/t82_departure_widget_test.dart
git add -- tool/t82_corpus_test.dart
git add -- tool/t82_main.dart
git add -- docs/T82-RESULTADOS.md
git commit -m "Sprint 3: T-82 generar BAPLIE de salida desde el estado derivado"
git push
```

## 8. Tres líneas y mensaje para Yov

Escritor puro: declaraciones vigentes del plan, cargas exactas del listado y cancelados copiables.
A08 y A08v_VGM 460/460; OR 12=2 185 kg; cancelación 459 y annul 460; suite 524, analyze 0, corpus 79.
Windows oficina, Honor y Chrome guardan y releen 460/460; T-82 En revisión para Timonel.

**Mensaje para Yov:** T-82 quedó En revisión según 10.18. A08 y A08v_VGM pasan
460/460 en los siete campos sin tocar el CSV, con los 177 eventos y 114 descargas.
Se aplicó la decisión directa de Carlos indicada para 10.20: todos los datos de
paso proceden de loading_baplie, con llegada como respaldo. Antes se verificó que
el plan coincide en 284/284 y siete campos; el informe conserva las divergencias
127/189/58/113 y 0020310: 24 260 en llegada, 24 200 en CSV. OR 12 lleva tara 2 185;
OR 5 cancelado no sale, figura con motivo y vuelve al anular; reloj fijo estable.
Windows con oficina autorizada, Honor .t82 y Chrome visible guardaron y releyeron
460/460. Suite 524, analyze cero, corpus Sprint 3 79/79 en dos corridas. Reglas,
main.dart, H5 y dependencias intactos. Observación de código para T-96 sobre
detalles del plano de llegada, e incidencias de captura/descarga declaradas.
Informe y bloque Git: docs/T82-RESULTADOS.md.
