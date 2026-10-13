# T-102 · Peso en PDF y pilas incompletas

Capitán Codex · 13-oct-2026 · rama `sprint-3`. Primera sesión sobre `42e9a30`;
continuación 10.27 sobre `cd90409`, con T-102 inicial guardada en `fd87b66`.

**Estado: En revisión para Timonel (10.18).** Carlos aceptó manualmente la
paleta restaurada el 13-oct, con registro de recepción a las **12:45:07 de
Guatemala**. No se marca Terminada hasta que Timonel la acepte. No se ejecutó
Git de escritura.

## Aceptación manual de Carlos y continuación 10.27

Carlos confirmó el **13-oct-2026**, con revisión realizada **poco antes de las
12:30 de Guatemala** (hora aproximada declarada por él), que abrió los PDF
exportados y comprobó la portada: **6940.6 t, 398 contenedores, 290 llenos,
108 vacíos, 12 reefer y 14 IMO**. Comprobó también la página 2, bahía 001:
**2.3 + 6.9 = 9.2 t**. Es **aceptación manual de Carlos**, no de Codex.

La aclaración se recibió y registró a las **12:28:15 de Guatemala del 13-oct**;
esta marca corresponde al registro de la confirmación, no a una hora exacta
inventada para la revisión. Carlos corrigió expresamente la lectura `8.9` que
figuraba en el primer mensaje y en 10.27: la celda es `6.9`. El PDF previo y el
re-exportado coinciden en ese dato; no se cambió el corpus ni el peso.

En esta continuación Carlos **revocó el monocromático completo**. El PDF vuelve
a la paleta anterior a T-102, contrastada con `3963098`: **53/53 tokens de
color iguales**, excluyendo el nuevo texto oscuro del peso. El peso efectivo,
el layout y el `+?` de pantalla se conservan. El verificador mantiene peso,
posición y contención del texto; se retira solamente la exigencia de grises.

Tras las tres re-exportaciones, Carlos respondió **«Sí, acepto la paleta
restaurada»** a la comprobación de portada y bahía 022 (página 15), con
categorías distinguibles y pesos legibles. **Aceptación manual de Carlos del
13-oct-2026; recepción registrada a las 12:45:07 de Guatemala (UTC−6).** Esta
hora corresponde a la recepción, no a una medición independiente del instante
en que miró el PDF. Se le mostró el PDF nuevo de Windows y sus páginas
renderizadas; la verificación técnica se hizo por separado en los tres PDF.

Los resultados y las incidencias de los apartados siguientes documentan la
**primera sesión** y sus PDF en grises. El cierre de esta continuación se
registra al final; la decisión vigente es **10.27: paleta original**.

## Primera sesión: qué cambió y decisión entonces vigente

- Las celdas del PDF muestran el peso efectivo (`VGM ?? bruto`) en toneladas
  con un decimal. Sin peso no se imprime `0.0`; un cero declarado sí se imprime.
  Las sombras de 40 pies no reciben peso. Un ajuste que solo reduce mantiene
  el texto dentro de la celda, incluidos los tamaños compactos.
- **Carlos pidió expresamente todo el PDF monocromático** durante esta sesión,
  después de contrastar la ficha con la paleta de colores existente. Portada,
  rejilla, leyenda, tabla y pie usan grises. Se conservan los rótulos de tipo y
  la diferencia de rellenos y contornos. No se recolorea la app.
- La cabecera de cada pila en pantalla agrega `+?` cuando un contenedor propio
  de esa fila y zona carece de peso efectivo. Cubierta y bodega se separan;
  reservas y sombras vecinas no cuentan. Las sumas y el aviso de exceso no cambian.
- El PDF sale por el mismo menú de `VesselOverviewPage`, `PdfReportService` y
  `ExportService`. No cambian almacenamiento, nube, reglas ni el dominio.
- **`pubspec.yaml` y `pubspec.lock` no cambian; no hay dependencias nuevas.**

## Primera sesión: resultados de PDF y pantalla

| Comprobación | Windows | Honor `.t102` | Chrome visible |
|---|---|---|---|
| Fixture incompleto | `28.7+?` en cubierta y `0.0+?` en bodega | Igual, 360×800 dp | Igual, viewport 360×800 |
| Fixture completo | `29.7`, `2.0`, sin `+?` | Igual | Igual |
| Reserva sin peso | La pila conserva `21.0` | Igual | Igual |
| A07 por selector real | 398 contenedores, 21 bahías, 6 940 578 kg | Igual | Igual |
| Exportación por menú normal | Guardado nativo a TEMP y aviso de éxito | Guardado nativo en Download/t102 y aviso de éxito | Descarga comprobada por fecha, tamaño y contenido |
| PDF exportado verificado | 398/398 celdas, 33 páginas, grises | 398/398 celdas, 33 páginas, grises | 398/398 celdas, 33 páginas, grises |
| Apertura visual en visor | Explorer abrió Edge; captura bloqueada por la política de computer-use | Intent y vista previa llegaron a «Abrir con»; no se aceptó el render de un lector | Archivo exportado íntegro; falta abrir y observar en el lector |

Los PDF de Windows y Honor pesan 140 689 bytes; el de Chrome, 141 967 bytes.
La diferencia de bytes entre plataformas no se presenta como una diferencia de
contenido: cada PDF se verificó por separado contra las mismas 398 posiciones y
sus pesos efectivos, incluidos los que solo traen VGM.

El verificador `tool/t102_verify_pdf.py` localiza cada celda mediante los rótulos
de fila y nivel y comprueba su peso dentro del rectángulo. También comprueba que
los textos no salen de la celda, todos los trazos, rellenos y textos son grises,
y la portada muestra el total redondeado `6940.6 t`. El total exacto de dominio
sigue siendo **6 940 578 kg**, sin sumar cifras ya redondeadas para el PDF.

Se generaron además PDF de A08 y A08v_VGM: **405/405 celdas** y **36 páginas** en
cada uno, con **6 899 700 kg**. El PDF sintético comprueba seis celdas: VGM, bruto,
ambos con preferencia por VGM, cero y dos faltantes sin cifra inventada.
Se observaron los PNG de la bahía 022 de A07 (página 15, la más cargada) y del
fixture sintético: pesos, tipo y línea caben sin superponerse.

**360 dp:** el corpus recorre todas las bahías de A07, A08 y A08v_VGM a ese ancho,
sin `+?` ni excepciones de layout. Los fixtures también pasan con texto al 130 %.
No equivale a declarar reparada toda la pantalla: la barra de acciones de T-89
sigue apretada, y el selector de bahía desborda con texto al 200 %. Es deuda
preexistente de **T-97**, fuera de esta tarea; no se ocultó ni se cambió.
El plano conserva su desplazamiento horizontal para rejillas amplias.

## Pruebas y corpus

- **Suite: 599/599**, frente al piso 592: siete pruebas nuevas de T-102.
- **`flutter analyze` final: 0 incidencias**, sin nuevas supresiones.
- **Corpus completo: 108/108**, los 105 anteriores y tres casos de T-102.
- Las pruebas sintéticas cubren suma conocida y VGM, pila completa, pila sin
  ningún peso, reserva, cero declarado, separación por zona y fila, 360 dp y
  texto al 130 %, además de generar el PDF sintético.
- No se borraron, omitieron ni modificaron pruebas anteriores.
- A06 conserva el rechazo de T-86; los casos operativos conservan 460/460.

Registros fuera del repo: `%TEMP%/t102-suite.log`, `t102-analyze-final.log`,
`t102-corpus.log` y `t102-directed3.log`. Las salidas de corpus y sus manifest
viven en carpetas `%TEMP%/t102-A07-*`, `t102-A08-*` y `t102-A08v_VGM-*`.

```powershell
flutter test --reporter expanded
flutter analyze
$t102corpusTests = Get-ChildItem tool -File | Where-Object { $_.Name -match 'corpus(_pdf)?_test\.dart$' } | ForEach-Object { 'tool/' + $_.Name }
flutter test @t102corpusTests '--dart-define=BAYSTREAM_CORPUS_DIRECTORY=C:\Users\Giova\OneDrive\Documentos\OneDrive\Desktop\Archivos .EDI\Anonimizados\files' --reporter expanded
# Con los PDF y manifest producidos en TEMP:
python tool/t102_verify_pdf.py RUTA_PDF RUTA_MANIFEST
```

## Primera sesión: clientes, compilación y límites

Banco `tool/t102_main.dart`: selector real, notifier y pantalla del producto,
fixtures TSTU y sesión local sin cuenta, con namespace **t102acc**. No incluye
el corpus como asset. Solo confirma la geometría propuesta y GTSTC para A07;
los fixtures no declaran escala. Las lecturas de almacén son del banco.

Builds release en serie, en `%TEMP%/baystream-t102-clientes`, con
`--dart-define-from-file=C:\Proyectos\baystream-privado\firebase-prod.json`.
No se abrió ese archivo ni `android/key.properties`. La copia excluye claves,
archivos de firma y directorios generados. Solo la copia cambia el applicationId
a `.t102`; el APK usa la firma de depuración, sin publicación.

| Build final | Resultado | Tiempo del compilador |
|---|---|---:|
| Windows | Correcto | 40.4 s |
| APK `.t102` | Correcto, instalado con `-r` | 36.3 s |
| Web | Correcto, servido solo en local | 69.4 s |

Las primeras compilaciones válidas fueron 57.8 s de Windows y 111.6 s de APK.
Se repitieron tras ajustar solo la sangría de los dos archivos de producción.
Los SHA de **todos los archivos de lib/** entre repo y copia final dan **0
diferencias**. Windows reutiliza el SDK C++ 13.9.0 ya disponible en la copia
privada T-82. Avisos conocidos: MSB8029 por TEMP, APIs Android obsoletas y
CupertinoIcons ausente en Web. El análisis quedó en cero.

Windows se abrió con Explorer. Almacén real comprobado:
`C:\Users\Giova\AppData\Local\BayStream\vessel_store`, cajas `t102acc_*`.
No se registraron movimientos. Se cerraron solo los PIDs propios 22672 y 2640.
El binario del repo conserva su fecha del 1-oct; las compilaciones válidas se
hicieron en la copia. El Honor declaró 720×1600 px, densidad 320: **360×800 dp**;
solo se instaló y se cerró `gt.cmartinez.baystream.t102`.

Chrome: `http://127.0.0.1:8102/`, IndexedDB t102acc, sin Hosting. El archivo
descargado a Descargas se copió a TEMP para comprobarlo, sin pasar por el repo.
El servidor local PID **3932** queda disponible para la aceptación pendiente.
La app de Windows y la variante del Honor quedaron cerradas; el selector del
lector de Android puede seguir visible. No se cerraron procesos ajenos.

Evidencia en `%TEMP%/baystream-t102-clientes/evidence`: PDF `windows-A07.pdf`,
`honor-A07.pdf`, `chrome-A07.pdf`, sus páginas renderizadas y capturas
`windows-incompleta.png`, `windows-completa.png`, `honor-incompleta.png`,
`honor-completa.png`, `chrome-incompleta-360.png`, `chrome-completa-360.png`.
Ninguna salida del corpus ni captura entró al repositorio.

## Primera sesión: incidencias y aceptación entonces pendiente

1. El fixture inicial declaraba un UNH no admitido; se corrigió a
   `BAPLIE:D:95B:UN:SMDG22`, sin cambiar el lector. Un FittedBox sobre una celda
   totalmente vacía falló por ancho cero; se corrigió antes de las corridas
   finales. La creación temporal de PDF en widget se movió a `runAsync`.
2. Se inició el primer build sin esperar la confirmación final del proceso de
   corpus, contra el acuerdo de un Flutter a la vez. El build falló por enlaces
   de plugins copiados en la primera carpeta temporal. La limpieza propuesta
   fue **rechazada automáticamente con «blocked by policy»**, sin razón más
   específica. No se forzó: se creó otra copia excluyendo lo generado. El
   corpus terminó 108/108 y los builds siguientes se ejecutaron en serie.
   Otro lanzamiento se interrumpió antes de compilar al detectar que el
   directorio de trabajo seguía siendo la raíz; no produjo registro de build.
3. Los volcados del Honor usan `adb exec-out uiautomator dump /dev/tty`, capturados
   en memoria y sanitizados antes de mostrarlos o guardarlos. Las cuentas de
   Drive se mostraron únicamente como **«cuenta oculta»**. Una captura de XML
   llegó vacía durante una transición: se volvió a observar, sin mostrar el
   original ni inventar un resultado.
4. La espera del evento de descarga de Chrome venció y reinició el conector.
   El archivo sí se descargó: fecha 13-oct 11:58:30, tamaño y contenido fueron
   comprobados. No se presenta el evento vencido como éxito del conector.
5. **Computer-use detuvo el control de este turno** al pedir una captura del
   PDF abierto en Edge: no pudo determinar la URL con confianza suficiente
   para aplicar su política. Se detuvieron las acciones de interfaz; no se
   intentó sortear el bloqueo. Por eso las aperturas visuales quedan pendientes.

Las aperturas pendientes al terminar aquella sesión quedaron cubiertas por
la revisión manual de Carlos registrada arriba. El monocromático de aquella
sesión fue revocado; los PDF vigentes son los re-exportados en color que se
detallan a continuación. No se atribuye a Codex la aceptación de los lectores.

## Continuación 10.27: resultados finales con la paleta restaurada

Se recompilaron los tres clientes release en serie en la misma copia temporal,
con el archivo privado pasado solo como argumento. Windows tardó **33.4 s**,
APK `.t102` **60.8 s** y Web **63.9 s**. No hubo cambios de layout ni de app;
las palabras y sus coordenadas de las **33 páginas** de Windows y Honor son
idénticas a las de sus PDF anteriores en grises. Los **53 tokens** de la paleta
anterior a T-102 coinciden con `3963098`; el peso nuevo conserva su gris oscuro.

| A07 final, exportado por el menú normal | Windows | Honor `.t102` | Chrome visible |
|---|---:|---:|---:|
| Celdas con peso y posición verificados | 398/398 | 398/398 | 398/398 |
| Páginas | 33 | 33 | 33 |
| Portada | 6940.6 t | 6940.6 t | 6940.6 t |
| Total exacto del viaje | 6 940 578 kg | 6 940 578 kg | 6 940 578 kg |
| Paleta restaurada, textos dentro de celda | Correcto | Correcto | Correcto |
| Tamaño | 144 253 bytes | 144 253 bytes | 145 775 bytes |
| Fecha y hora del archivo, Guatemala, 13-oct | 12:34:48 | 12:36:26 | 12:41:55 |

Salidas finales: `%TEMP%/baystream-t102-clientes/evidence-color/windows-A07.pdf`,
`honor-A07.pdf` y `chrome-A07.pdf`, con portada, página 2 y página 15 renderizadas
por el verificador. Capturas de éxito: `honor-exportado.png` y
`chrome-exportado-final.png`. En el Honor queda
`Download/t102/T102_A07_color.pdf`, separado del PDF anterior.

Windows se abrió mediante Explorer en `t102acc`, con el mismo almacén real
`%LOCALAPPDATA%/BayStream/vessel_store`; se cerró solo el PID propio **15828**.
Se usó únicamente la variante `.t102` del Honor, cerrada después de exportar.
Sus volcados se capturaron en memoria y sanitizaron antes de mostrar o guardar.
La pestaña propia de Chrome se cerró y el servidor local **3932** se detuvo
por PID tras comprobar su línea de comando y su directorio temporal. No se
cerraron procesos ajenos. El binario de Windows del repo conserva su fecha
del 1-oct.

La pantalla conserva las comprobaciones de la primera sesión: fixtures
incompletos `28.7+?` y `0.0+?`, completos sin sufijo y reservas sin marca;
A07/A08/A08v sin `+?` y recorrido de todas sus bahías a 360 dp. Se volvieron
a ejecutar esas pruebas dentro de la suite y del corpus. El SHA de
`bay_plan_view.dart` es idéntico al de entrada de esta continuación; el recolor
solo afecta al PDF.

**Verificación repetida final:** suite **599/599** (piso 592), analyze **0**,
corpus completo **108/108**. A08 y A08v_VGM re-verificados: **405/405 celdas,
36 páginas** cada uno. Registros: `%TEMP%/t102-color-suite.log`,
`t102-color-analyze.log`, `t102-color-corpus.log` y los tres
`t102-color-*-build.log`. Manifest de A07:
`%TEMP%/t102-A07-76411b88/manifest.json`. Ninguna salida se copió al repo.

La primera descarga de Chrome conservó la Web anterior en caché: sus pesos
pasaban, pero seguía en grises. Se detectó comprobando los colores de página
15 y se descartó como evidencia final. La recarga completa del navegador
produjo el PDF final en color de las **12:41:55**, verificado de nuevo.
El intento de iniciar un segundo servidor local fue **rechazado por la revisión
automática con «blocked by policy»**, sin motivo más específico; no se forzó.
Se completó la exportación mediante el servidor existente y una recarga normal
completa del navegador. No hay aceptación pendiente de Carlos; queda la de
Timonel, según 10.18.

## Integridad

SHA-256 anterior y posterior iguales:

| Archivo | SHA-256 |
|---|---|
| Reglas T-80 publicadas, propuesta local | `21894B7F43E59F856045473731B795D21F8373C5AC8A1D9FFF324334AC3C9000` |
| Lector | `5D8C843E54D94250E5AE716B839C3000B9A8F7BD4760A5092DD6DC0EFFC4802F` |
| Escritor | `05EE91981499215E9981094EE3C3230C00AB98C54F4793B8750880D23E656147` |
| main.dart | `C5189B1D8711837A05C68306D424C9FDBCC977BA3BBB6C823089FFE4CA5339D5` |
| pubspec.yaml | `14916474A1874780E0D5851F9AFB4AE46A4B6B75286D4B497919DE38B7509E9F` |
| pubspec.lock | `FAA283751D6D97B1F87059EA683B4CC12ED43DDF6E92A52C1B993A801A510C97` |

Los dos archivos congelados de H5 también conservan su SHA. La comparación de
reglas es sobre la propuesta local que Carlos publicó: no se consultó producción
con CLI o administrador ni se repitió su batería, porque no cambian payloads.
Sin Firebase CLI, deploy, publicación Web/Play, credenciales ni acciones contra
H5. Los cuatro documentos con cambios ajenos al comenzar quedaron intactos.

## Archivos de la primera sesión, ya guardados en fd87b66

1. `lib/features/vessel/data/services/pdf_report_service.dart`
2. `lib/features/vessel/presentation/widgets/bay_plan_view.dart`
3. `test/t102_weight_display_test.dart` (nuevo)
4. `tool/t102_fixtures.dart` (nuevo)
5. `tool/t102_corpus_test.dart` (nuevo)
6. `tool/t102_main.dart` (nuevo)
7. `tool/t102_verify_pdf.py` (nuevo)
8. `docs/T102-RESULTADOS.md` (nuevo, este informe)

## Archivos exactos de esta continuación

1. `lib/features/vessel/data/services/pdf_report_service.dart`: paleta original.
2. `tool/t102_verify_pdf.py`: conserva pesos, posiciones y contención; retira grises.
3. `docs/T102-RESULTADOS.md`: resultados y aceptaciones manuales, este informe.

`pubspec.yaml` y `pubspec.lock` no cambian. No se incluyen las cuatro rutas
de documentos ajenos presentes al comenzar ni las otras cinco rutas de la
implementación inicial que no cambiaron en esta continuación.

## Horas

Todas las marcas son del **13-oct-2026, Guatemala (UTC−6)**.

- Primera sesión: **11:33:38–12:07:15**, 33 min 37 s, **0.56 h**.
- Continuación 10.27: **12:24:46–12:47:34**, 22 min 48 s, **0.38 h**.
- **Total: 56 min 25 s, 0.94 h frente a 1.0 h estimada** (0.06 h por debajo).
- El intervalo entre sesiones se excluye; cada sesión incluye lectura,
  implementación, pruebas, builds, recorridos, espera de aceptación e informe.
  No es una medición de latencia H5.

## Git para Carlos

Solo las tres rutas modificadas en esta continuación; el informe está autorizado
por su nombre exacto. El estado queda En revisión para Timonel.

```powershell
git add -- "lib/features/vessel/data/services/pdf_report_service.dart"
git add -- "tool/t102_verify_pdf.py"
git add -- "docs/T102-RESULTADOS.md"
git commit -m "Sprint 3: T-102 restaurar paleta del PDF y cerrar aceptacion visual"
git push
```

## Tres líneas

Paleta original del PDF restaurada; peso efectivo y +? conservados.
A07 re-exportado en tres clientes: 398/398 celdas, 33 páginas, 6940.6 t.
599 pruebas, analyze 0, corpus 108/108; Carlos acepta y T-102 queda En revisión.

## Mensaje para Yov

T-102 queda En revisión para Timonel (10.18), tras la continuación 10.27.
Carlos aceptó los PDF iniciales poco antes de las 12:30 del 13-oct; confirmó
**2.3 + 6.9 = 9.2 t** en bahía 001, con registro a las 12:28:15 Guatemala.
Corregir en 10.27 la lectura histórica 8.9 por **6.9**. Se revocó el gris total
y se restauró la paleta anterior, conservando pesos y +?. Windows, Honor .t102
y Chrome re-exportaron A07: 398/398 celdas, 33 páginas, 6940.6 t; total exacto
6 940 578 kg. Carlos aceptó la portada y bahía 022 con colores distinguibles
y pesos legibles; recepción registrada **13-oct 12:45:07 Guatemala**.
Suite 599/599, analyze 0, corpus 108/108; reglas con el mismo SHA, main,
pubspec y congelados intactos. Solo tres rutas en el bloque Git. Total de ambas
sesiones **0.94 h frente a 1.0 h estimada**. Windows y Honor libres, pestaña
propia y servidor local cerrados.
