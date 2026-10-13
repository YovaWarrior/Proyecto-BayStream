# T-102 · Peso en PDF y pilas incompletas

Capitán Codex · 13-oct-2026 · rama `sprint-3`, sobre `42e9a30`.

**Estado: En curso; implementación y validaciones completas, aceptación de
apertura en visores pendiente.** No se marca En revisión todavía: se aplica el
precedente de 10.22. Después de completar la aceptación propia pasa a En revisión
para Timonel, conforme a 10.18. No se ejecutó Git de escritura.

## Qué cambió y decisión de Carlos

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

## Resultados de PDF y pantalla

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

## Clientes, compilación y límites

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

## Incidencias declaradas y aceptación que falta

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

Para completar «Terminada cuando», Carlos puede abrir los tres PDF indicados
en su lector local y comprobar portada (6940.6 t), página 2 y bahía 022 en
página 15: peso de cada celda con un decimal, grises y 33 páginas. En el Honor
el archivo está en `Download/t102/BayStream_BUQUE GOLF_VIAJE007A.pdf`; elegir
el lector local y **Solo una vez**, sin cambiar el predeterminado. Registrar
quién hizo la comprobación; no atribuirla a Codex si la hace Carlos.
Alternativamente, continuar en otro turno con la apertura por el conector
autorizado que pueda observar ese visor. No hace falta cambiar reglas ni publicar.

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

## Archivos exactos

1. `lib/features/vessel/data/services/pdf_report_service.dart`
2. `lib/features/vessel/presentation/widgets/bay_plan_view.dart`
3. `test/t102_weight_display_test.dart` (nuevo)
4. `tool/t102_fixtures.dart` (nuevo)
5. `tool/t102_corpus_test.dart` (nuevo)
6. `tool/t102_main.dart` (nuevo)
7. `tool/t102_verify_pdf.py` (nuevo)
8. `docs/T102-RESULTADOS.md` (nuevo, este informe)

## Horas

Inicio registrado: **13-oct-2026 11:33:38, Guatemala**.
Cierre registrado: ****13-oct-2026 12:07:15, Guatemala****.
**0.56 h de pared frente a 1.0 h estimada**, incluyendo lectura,
implementación, pruebas, builds, recorridos y este informe. La aceptación
restante se contabiliza al completarla. No es una medición de latencia H5.

## Git para Carlos

Ocho rutas propias. Se puede guardar la implementación como en el precedente
10.22; el commit no significa que se hayan aceptado las aperturas pendientes.
El informe se incluye por su nombre exacto, autorizado para esta tarea.

```powershell
git add -- "lib/features/vessel/data/services/pdf_report_service.dart"
git add -- "lib/features/vessel/presentation/widgets/bay_plan_view.dart"
git add -- "test/t102_weight_display_test.dart"
git add -- "tool/t102_fixtures.dart"
git add -- "tool/t102_corpus_test.dart"
git add -- "tool/t102_main.dart"
git add -- "tool/t102_verify_pdf.py"
git add -- "docs/T102-RESULTADOS.md"
git commit -m "Sprint 3: T-102 peso efectivo en PDF monocromatico y pilas incompletas"
git push
```

## Tres líneas

PDF completo monocromático por decisión de Carlos, con peso efectivo por celda.
Pilas con faltantes muestran +?; reservas, cero y zonas independientes cubiertos.
599 pruebas, analyze 0, corpus 108/108; falta aceptar aperturas en visores.

## Mensaje para Yov

T-102 implementada; queda En curso por apertura visual pendiente, conforme al
precedente 10.22. Carlos amplió expresamente el alcance a todo el PDF
monocromático. Windows, Honor .t102 y Chrome exportaron A07 por el camino normal:
398/398 celdas con peso efectivo, 33 páginas, grises, total 6 940 578 kg. Los
fixtures muestran 28.7+? y 0.0+? y las pilas completas no llevan marca; reservas
y cero declarado no la producen. A07/A08/A08v recorren todas sus bahías a 360 dp
sin +?. Suite 599/599 (+7), analyze 0, corpus 108/108; reglas con SHA publicado
sin cambio, main, pubspec y congelados intactos. Ocho rutas; commit propuesto
«Sprint 3: T-102 peso efectivo en PDF monocromatico y pilas incompletas».
Computer-use detuvo el control al no confirmar la URL del visor Edge: no se
sortearon políticas ni se atribuyeron aperturas visuales no observadas. Falta
aceptar los tres lectores y después pasa En revisión para Timonel. T-97 conserva
las deudas previas de barra y texto al 200 %. Las horas registradas constan arriba.
