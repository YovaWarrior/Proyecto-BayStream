# Aceptación de la candidata 0.4.2 · Capitán Codex

**Dictamen: ACEPTADA con reservas.** Pasan la suite completa, analyze, las
reglas, la fidelidad del piloto, las tres compilaciones y el recorrido de
negocio T-130/T-129 en Chrome. Las reservas son de validación: el banco Android
no permite completar la integración nativa y hubo un incidente de aislamiento
del lanzador de Windows. No se encontró un P1 ni se reprodujo un P2 del código
de producto. Se conserva el aviso P3 preexistente del nombre de archivo nulo.
Esta aceptación no acredita publicación ni ensayo contra Firebase real.
Carlos decide, ejecuta Git y publica.

3-nov-2026, hora de Guatemala. Carpeta de aceptación:
`C:\Proyectos\baystream-qa-r4`. HEAD separado:
`15ef04b5c388a9e4c3666353643dd7f58175b259` (10.96), precedido inmediatamente
por `9087372` (T-134). Candidata declarada: `0.4.2+8`, MSIX `0.4.2.0`.

## Paso 0 y aislamiento

- Las lecturas de Git confirman los dos commits exigidos. No se ejecutó
  `git status`, ninguna escritura de Git ni cambios de rama.
- El diff inicial no lista cambios de contenido. Emite únicamente los tres
  avisos previstos de LF/CRLF de los generados de `windows/flutter/`.
  No se tocaron esos archivos del árbol de aceptación.
- El inventario inicial de ADB no mostró ningún dispositivo. El Honor queda
  fuera del encargo y no recibe comandos de instalación ni de ejecución.
- Carlos creó `BayStream_Tablet`: Pixel Tablet, API 36, imagen
  `google_apis_playstore/x86_64`, 2560 × 1600 y 320 dpi. Arrancó con la luz
  verde individual de Carlos. ADB la identifica como `emulator-5554`;
  `emu avd name`, API y `sys.boot_completed=1` comprobados. Todos los comandos
  ADB de esta aceptación llevan `-s emulator-5554`.
- La copia limpia se reconstruyó exclusivamente con lecturas `git show` de
  HEAD: 809 archivos de código, pruebas, herramientas, assets, diseño y
  plataformas. No contiene claves privadas ni datos reales del piloto.
  Después de la suite, los 809 SHA-256 siguen idénticos a los blobs de HEAD.
  La diferencia física del pubspec respecto del árbol es solo CRLF/LF.
  Al finalizar las compilaciones y los bancos privados, una nueva comprobación
  de los **809 archivos** vuelve a dar **cero diferencias** de SHA-256.
  Evidencia: `build/t134acc/integridad-final-copia.json`.
- Prerrequisito T-124 copiado desde la carpeta autorizada del rediseño:
  `build/t124/entradas/t124_entradas.dart`, SHA-256
  `d4384834fb9fc9cb18632b87180a7998cc3f91109edcbd33dbbf9787542d1162`.
  Es generado e ignorado; no entra a Git.
- Las pruebas automatizadas usan únicamente copia limpia, TEMP y emuladores.
  **La preparación manual tuvo el incidente O-134-1 descrito abajo:** no se
  puede certificar aislamiento total de la sesión respecto de la app instalada.
  Las fuentes y salidas reales del piloto permanecen exclusivamente en `%TEMP%`.

## Suite y analyze

Cada corrida tuvo autorización individual y líneas SEMÁFORO de inicio y fin.
Se aplicó el flujo de lectura de diagnósticos de `dart-run-static-analysis`,
conservando la prohibición del encargo de modificar producto.

| Comprobación ejecutada | Resultado |
|---|---|
| `flutter test --reporter json`, una sola corrida | **2097/2097**, cero fallos, cero omitidas; salida 0 |
| T-130, dentro de esa corrida | **37/37**: dominio/motor 18, pantallas 10, adaptador 9 |
| T-129, dentro de esa corrida | **7/7** |
| T-132, dentro de esa corrida | **36/36**: fidelidad 24, página 11, repositorio 1 |
| T-133, dentro de esa corrida | **46/46**: marcas 35, capturas 11 |
| T-93, dentro de esa corrida | **5/5** |
| `flutter analyze`, proyecto completo de la copia limpia | **Cero incidencias**, salida 0 |

La suite corrió de 11:02:58 a 11:05:15 (tiempo total del comando, incluida la
resolución de paquetes); el reportero registra 127745 ms. Analyze informó
14.1 s. Son tiempos de ejecución informativos, no mediciones RNF.
`pubspec.lock` de la copia conserva su contenido de HEAD.

Registros: `build/t134acc/suite.jsonl`, `suite-resumen.json`,
`suite-ejecucion.json`, `analyze.log` y `analyze-ejecucion.json`.

## Reglas de T-130

Las ocho corridas del lanzador autorizado se ejecutaron secuencialmente en
`127.0.0.1:8282`, proyecto `demo-t130`. Se comprobaron libres los puertos
de Firebase y Expo antes de comenzar; el emulador se cerró al terminar.

| Batería | Reglas T-130 | Reglas T-127 |
|---|---|---|
| T-80 | **69/69** | **69/69** |
| T-113 | **25/25** | **25/25** |
| T-127 | **31/31** | **31/31** |
| T-130 | **38/38** | **27/38**, once fallos esperados |

Los once rojos coinciden con la sección 9 de T-130: dos adiciones; viaje válido
y su lectura; trozo sin entrada; dos trozos; trozo suelto con otra huella;
trozo que completa el manifiesto cuyo id quedó ocupado; adición de cuatro
trozos; lectura de fuentes; intento de actualizar el trozo agregado que nunca
se creó. El rojo esperado no se contabiliza como defecto de la candidata.

Evidencia: `build/t134acc/reglas/`, `baterias-lanzador.log` y
`baterias-ejecucion.json`. Ninguna respuesta mencionó el límite de accesos a
documentos. Eso no acredita que el emulador los cuente como producción;
se conserva el límite de la evidencia explicado en la sección 9 de T-130.

## Tres clientes de la candidata

Las tres compilaciones desde `lib/main.dart` original terminaron con salida 0,
con autorización individual y sin instalar, abrir ni publicar las salidas.

| Cliente | Metadatos comprobados |
|---|---|
| Windows Release | FileVersion y ProductVersion **0.4.2+8** |
| Web Release | `version.json`: **0.4.2**, compilación **8** |
| AAB Release | Manifiesto protobuf dentro del AAB: **versionName 0.4.2**, **versionCode 8** |

Se conservaron las salidas en `build/t134acc/candidata/`. El AAB tiene firma
**Android Debug**, verificada con `jarsigner`; no hay `android/key.properties`
en la copia. Acredita compilación y versión; no es el AAB de publicación de
Carlos. No se leyó su configuración privada.

El aviso de fuente `packages/cupertino_icons/CupertinoIcons` de la Web ya
estaba en `build/t128-aceptacion/candidata-web.log`. Android informa uso de API
obsoleta y operaciones sin comprobar en dependencias; no se corrigió producto
ni dependencias durante esta aceptación.

## T-132 con el estado real del piloto

Banco aislado en `%TEMP%\t134acc-banco`, paquete con baystream por path a la
copia limpia. Entradas reales, salidas, código y registros de ese banco quedan
en TEMP. La prueba de widgets ejecuta la página real y su botón de guardado;
un selector privado escribe los bytes exclusivamente en TEMP. No se toman
capturas con datos reales.

Se cargó solo el plan y el listado: **sin plano de llegada**. Las **145 cargas**
se reconstruyeron desde la ocupación final de referencia, cada una en su celda;
los **358 grupos de paso** proceden del plan. Las equivalencias se dedujeron
del plan para el tipo de cada lleno y de la referencia para los demás códigos:
**5 de tipo, 5 de puerto y 5 de línea**, sin ninguna correspondencia ambigua.

La página pidió exactamente **3 decisiones**, todas de **Mercancías
peligrosas**, por **UN 2902 en el plan frente a UN 2903 en el listado**.
No pidió decisiones de temperatura ni de otra clase. Guardar estaba
deshabilitado; se eligió **Usar el plan** en las tres y se habilitó. La página
guardó una vez. Resultado: **cero errores**, **cero avisos** y **5 filas no
cargadas**.

El cotejo independiente, escrito en Python y ejecutado fuera del repositorio,
confirma:

| Criterio | Resultado |
|---|---|
| Ocupación final | **503/503 celdas**, mismo contenedor en cada una que la salida anterior |
| Grupos que siguen a bordo | **358/358 idénticos byte a byte** al plan |
| DGS de llenos cargados que lo declaran | **4/4 grupos completos iguales** a los del plan |
| TMP, LOC+83 y FTX en llenos cargados | El piloto no trae ninguno en esos llenos; cero diferencias. Los casos con esos datos quedan cubiertos por la suite sintética de T-132 |
| Pesos expresados con decimales | **0** |
| LOC+13 con POT igual a POD | **0** |
| UNT | **4117 declarados y 4117 contados** |
| Referencias de control | UNH/UNT y UNB/UNZ coinciden |
| FTX Latin-1 de la bahía 26 | Bytes conservados dentro de los grupos idénticos del plan |

Contra la copia corregida por Yov, excluyendo UNB, UNH, BGM, DTM, UNT y UNZ:
**cero diferencias en los segmentos de los 503 grupos**. La única diferencia
de cabecera es **TDT: 26043X frente a 26043S**, la edición manual esperada de
Yov. No hay ninguna otra diferencia que atribuir al escritor o a la copia
manual. El cotejo privado conserva ambas secuencias completas; el resumen
publicable contiene únicamente conteos, etiquetas de segmento y celdas.
Los **503 grupos de la salida guardada desde la página** son idénticos a los
de la salida del escritor cotejada; sus diferencias de reloj y referencia
pertenecen a la envoltura excluida del cotejo.
Las versiones de los **118 paquetes** de la candidata se contrastaron con
las resueltas en el banco: **cero versiones distintas**. Evidencia segura:
`build/t134acc/t132-dependencias.json`, `t132-resumen-seguro.json` y
`t132-cotejo-seguro.json`; los archivos con segmentos reales siguen en TEMP.

## Lista del piloto y datos reales: comprobaciones iniciales

- Los **diez bloques PowerShell** pasan `Parser.ParseInput` con **cero errores**.
  Ningún bloque de publicación, instalación, Git o vuelta atrás se ejecutó.
- `PSScriptAnalyzer` no está instalado: no se presenta el parser como sustituto
  de sus reglas. Evidencia: `build/t134acc/piloto-powershell.json`.
- `git diff --stat be532ab HEAD -- '*.docx' '*.pdf' '*.pptx' '*.xlsx'` no devuelve
  cambios. El criterio documental de 4.1 cumple para esta candidata.
- Las **cinco huellas** de `%TEMP%\t134acc-piloto` coinciden con su LEEME.
  No se copiaron fuentes reales al repositorio. El registro de huellas contiene
  solamente nombres de archivo y SHA-256.
- Los textos compuestos de `dialogo_agregar_plan.dart`, `aviso_del_plan.dart`
  y `aviso_del_listado.dart` contienen las formas pedidas. El recorrido de
  punta a punta contrasta después las cifras y las frases observadas.
- Los sintéticos de T-100 se generaron en `%TEMP%\t134acc-sinteticos` con el
  generador autorizado y el Excel con Python. Se ejecutó **únicamente el bloque
  «Datos»** de la lista, sustituyendo solo `$carpeta`: produjo las cuatro líneas
  **Listo** esperadas y verificó las cuatro huellas.
- `T100_CARGA_M100N.edi` se derivó del original con una sola sustitución de TDT
  y escritura Latin-1. SHA-256:
  `511B3CF52139F1FD597462E14E90F87FEA648924848AB2EDFE973386888A73AE`.

### Rótulos nuevos: cotejo de código

Se revisó la composición de los textos, además de la existencia de sus
fragmentos. Este cotejo estático no se presenta como un recorrido en pantalla.

| Lista del piloto | Fuente en `lib/` | Resultado estático |
|---|---|---|
| 0.8, banda de plan pendiente | `plan_attach_provider.dart`, `textoDeLaBusqueda` | Viaje, escala, tipo que falta y acción de confirmar coinciden |
| 0.8, diálogo | `dialogo_agregar_plan.dart`, `confirmarAgregarPlan` | Fecha de publicación, viaje de archivo/operación y cifras compuestas coinciden; P130/P130N sustituyen M100/M100N |
| 0.8 y 2.16, avisos del plan | `aviso_del_plan.dart`, `textoDelPlanAgregado` | Se distingue oficina/muelle y llegada/carga; el aviso de carga usa contenedores y reservas |
| 0.8 y 1.17, listado | `export_list_providers.dart`, `aviso_del_listado.dart` | Filas, revisión y aviso automático coinciden |
| 1.13 | `departure_baplie_page.dart` | Datos por confirmar, dos elecciones, avisos, errores, filas no cargadas y copia coinciden |
| 1.14 | `departure_export_repository_impl.dart` | Nombre del archivo con viaje de salida, diálogo y bytes originales coinciden |
| 1.15 | `cloud_page.dart`, `firestore_operation_sync.dart` | Operación cerrada, estado cerrado y los dos mensajes de fallo coinciden |
| 1.16 | `vessel_overview_page.dart`, presentación de Estadísticas | El resumen de vacíos asignados y la agrupación de bahías siguen vigentes |
| 1.17 | `export_list_import_page.dart` | Elegir/importar otro listado, tarjeta Lo ya operado y Confirmar e importar existen |
| 1.18 | `plan_attach_provider.dart`, `operation_sources.dart` | Los tres casos de banda y el rechazo de reemplazo están compuestos como los cita la lista |
| 1.19 | `firestore_operation_sync.dart`, `cloud_page.dart` | Negativa de publicación duplicada, fecha y Unirse coinciden |
| 2.2 | `_TituloDelViaje`, `_BandaDelMuelle` y `bs_distintivo_de_rol.dart` | Distintivo completo/compacto y apertura de Nube y cuenta conectados |
| 2.3 y 2.7 | `bs_celda.dart` | Código grande; Baja, Hecho, Revisar y Cancel. como segunda línea; prioridad del código cuando falta sitio |

## Preparación manual T-119

Banco Windows y Web compilados con autorización individual desde la misma
punta. La entrada privada cambia únicamente el namespace del banco T-100 a
**r4**; Firebase queda desactivado y Windows recibe explícitamente
`%TEMP%\t134acc-r4`. No modifica `lib/main.dart` ni otro archivo de producto.
Salidas: `build/t134acc/r4/windows/` y `build/t134acc/r4/web/`.
La Web local en `http://127.0.0.1:5944/` declara **0.4.2 (8)**.

Carlos confirmó el 3-nov que terminó la prueba manual: **«Terminé: pellizco y
Ctrl + rueda pasan en los tres»**, en respuesta a la instrucción de abrir el
`.exe` desde el Explorador y la Web local en Chrome y Edge, usando el sintético
T-100 y confirmando GTSTC y el perfil.

| Cliente | Pellizco | Ctrl + rueda | Fuente de evidencia |
|---|---|---|---|
| Windows, banco r4 | Pasa | Pasa | Testimonio manual de Carlos |
| Chrome, banco r4 | Pasa | Pasa | Testimonio manual de Carlos |
| Edge, banco r4 | Pasa | Pasa | Testimonio manual de Carlos |

No se presenta ese testimonio como una medición automatizada ni como una
repetición del caso de pérdida de foco sin evento final de O-128-4. Se mantuvo
libre Flutter durante la prueba; Carlos ya confirmó su terminación. El incidente
previo del lanzador se declara abajo y no se oculta con este resultado.

## Alcance del dictamen y reservas

| Prioridad | Hallazgo o límite | Consecuencia |
|---|---|---|
| P1 | Ninguno encontrado | No se observó pérdida de datos ni fallo bloqueante del producto en los recorridos ejecutados |
| P2 de validación, O-134-1 | El helper de Windows abrió la app instalada | No se puede certificar aislamiento total de esa sesión; detalle y contención abajo |
| P2 de validación, O-134-2 | Arranque original del banco Android y bloqueo de HTTP del banco privado | El E2E se acredita en Chrome; no se acredita autenticación, sincronización ni distintivos de cuentas en Android nativo |
| P3 conocido | «Archivo "null" cargado correctamente» desde Parámetros | Rótulo preexistente, observado por Carlos en los tres clientes; no se modificó producto |
| P3 de validación | Indicador de desconexión y recepción del plan tras restituir la conexión superaron la espera inicial de 35 s | No se presenta una garantía de latencia; el plan terminó llegando automáticamente y no se pulsó Reintentar |

La banda del teléfono y RNF-002 con T-133 quedan para el Honor con la 0.4.2
de Play, en 0.8 y en el ensayo. Son límites expresos del encargo corregido,
no pruebas aprobadas por inferencia. `PSScriptAnalyzer` no estaba instalado.

**Único archivo previsto para Git:** `docs/t134/aceptacion-codex.md`.
Las evidencias están en `build/t134acc/`, ignoradas. **No cambian
`pubspec.yaml` ni `pubspec.lock` del árbol de aceptación.**

## O-134-1 · P2 de validación: el lanzador abrió la app instalada

Al preparar la prueba manual de Windows se invocó `sky.launch_app` con la
ruta absoluta `build/t134acc/r4/windows/baystream.exe`. El helper abrió en
cambio el AppID instalado `gt.cmartinez.baystream_bq33510ehc1x4!baystream`.
La comprobación posterior de procesos identifica la ruta de WindowsApps de
la **0.4.0.0**, no la ruta del banco. Antes de esa llamada no había ninguna
ventana de BayStream; después apareció ese único proceso.

No se hizo ninguna interacción de negocio, importación, registro, exportación
ni captura dentro de la app instalada. Se avisó a Carlos y se cerró la ventana
recién abierta con Alt+F4. Una comprobación posterior confirma que no queda
ninguna ventana ni proceso `baystream.exe`.

**Límite:** el inicio de la app instalada pudo acceder automáticamente a su
almacén o a Firebase. No se inspeccionaron esos datos ni se dispone de una
traza que permita descartar el acceso. Por tanto, no se afirma que el almacén
real o Firebase permanecieran sin acceso durante toda la sesión. Es un
incidente del instrumental y del aislamiento de la aceptación, no un defecto
reproducido de la candidata. No afecta a las salidas de la copia limpia ni al
banco privado T-132 ya cotejado.

El `.exe` del banco existe y sigue aislado por namespace `r4` y ruta TEMP;
la Web `r4` está servida en `http://127.0.0.1:5944/`. Su apertura para la
prueba manual queda en manos de Carlos, desde el Explorador y los navegadores.
No se repetirá el lanzamiento con ese helper.

## O-134-2 · P2 de validación: el banco Android exige la app Firebase por defecto

El APK original de `tool/t130_emu_main.dart` compila y se instala únicamente
en `BayStream_Tablet`, pero queda en la pantalla de inicio de Android sin
dibujar la interfaz Flutter. La traza registra `[core/no-app] No Firebase App
'[DEFAULT]' has been created`, desde `FirebaseFirestorePlatform.instance`,
al ejecutar `useFirestoreEmulator` en la línea 77 del banco. El punto de entrada
crea una app Firebase con nombre, pero no la app por defecto que pide ese
delegado del SDK. No es una prueba de fallo del main de la candidata.

Se conserva el diagnóstico y una captura de esa pantalla de inicio, sin cuenta,
en `build/t134acc/`. El APK original se detuvo; no se cambió `android/`.
Inicialmente se preparó la alternativa autorizada de Chrome a 360 × 800.

Carlos pidió intentar la tablet y autorizó expresamente otra compilación.
Se preparó `build/t134_tablet_emu_main.dart` dentro de la copia de aceptación:
añade la inicialización de `[DEFAULT]` **con el mismo `demo-t130-e2e`**, después
de las guardas y antes de la app con nombre. No modifica `lib/`, `android/` ni
el banco original de `tool/`.

La primera variante tampoco creó `[DEFAULT]`: el SDK 4.13.0 usa el ID del
proyecto como nombre cuando se pasa `demoProjectId` sin nombre explícito.
Se conservó ese intento y, con otra luz verde de Carlos, se compiló la variante
con `Firebase.initializeApp(name: '[DEFAULT]', demoProjectId: project)`.
**Esta sí dibuja la interfaz.** Se comprobó el inicio amplio de la tablet,
la selección de un BAPLIE sintético, su apertura en previo y la entrada a
Parámetros, con selección de GTSTC. La confirmación local se completó en la
segunda ventana, como se documenta en la inspección visual más adelante.

La sesión nativa del muelle no pudo iniciarse: el SDK devuelve **«Cleartext
HTTP traffic to 127.0.0.1 not permitted»**. Se conserva el código de error y
el mensaje de la app. No se alteró `android/`, el cortafuegos ni ninguna
política de red. La distribución amplia está observada, pero **no se acredita
el distintivo de una cuenta autorizada ni la sincronización nativa de la
tablet**. La alternativa de Chrome sigue siendo necesaria para el E2E.

## O-134-3 · Contradicción de alcance resuelta por Carlos y Yov

El recorrido se detuvo al contrastar las capturas con el requisito de ver la
banda azul de muelle en la Web a 360 × 800. El código de `lib/core/app.dart`
(líneas 13 a 15) define `bayStreamEsMuelle` con **`!kIsWeb`**: toda Web usa
densidad de oficina, con independencia del ancho y del rol autorizado.
En `vessel_overview_page.dart`, la banda exige `medidas.esMuelle && enOperacion`.

La captura `e2e/muelle/02-descarga-antes-muelle.png` confirma el comportamiento:
cuenta de muelle, viewport 360 × 800 y modo Descarga, con **distintivo compacto
en la barra blanca** y selector de modo desplegable. No es la banda azul con
segmentos que describe el encargo. Las marcas Baja/Hecho de la densidad de
muelle tampoco pueden acreditarse con esa Web sin adaptar el banco.

Se detuvo el recorrido y se avisó. Carlos eligió **aceptar la Web estrecha de
oficina y continuar el E2E**. Después, Yov corrigió expresamente el punto 4:
la densidad de muelle es de Android/iOS; la banda exige además teléfono sin
riel, por debajo de 600 dp. La tablet usa distribución de oficina ancha y
densidad de muelle; la Web estrecha conserva densidad de oficina. **No se
compiló ningún banco de densidad forzada.**

La primera ventana quedó parcial y se cerró. El recorrido completo se retomó
en una segunda ventana con contextos nuevos, como se documenta más adelante.
La contradicción de alcance queda resuelta; no se clasifica como defecto de
la candidata.

### Cierre de la primera ventana E2E

Final: **3-nov-2026, 12:09:51, Guatemala (UTC−6)**. Se cerraron los contextos
propios de Chrome y sus proxies; se apagó el árbol del emulador propio
`demo-t130-e2e`; se quitaron `adb -s emulator-5554 reverse` de **8383 y 9399**;
se detuvo el banco de la tablet y se cerraron los dos servidores Web E2E.
La verificación final no encontró escuchas en 8383, 9399, 4498, 4598, 9150,
8384 ni 9398, y `reverse --list` no lista túneles. Firebase escuchó únicamente
en **127.0.0.1** durante toda la ventana; no se usó 0.0.0.0 ni se modificó el
cortafuegos. Evidencia: `e2e-cierre-ventana1.json`.

## Observación P3 preexistente · aviso con nombre de archivo nulo

Carlos informó que, en su prueba manual de la candidata en **Edge, Chrome y
Windows**, al confirmar desde «Parámetros» un BAPLIE recién abierto, vio
**«Archivo "null" cargado correctamente»**. La nota de Yov la identifica como
anterior a la 0.4.2, procedente de la 10.32. No se reproduce otra vez, conforme
a la instrucción de Carlos.

La lectura del código concuerda: las llamadas desde el ícono de Parámetros
invocan `_askForGeometry(context)` sin el `fileName` opcional; el aviso de
confirmación interpola ese argumento nullable. La confirmación de la banda
pasa el nombre. Es un rótulo incorrecto, no evidencia de pérdida del archivo.
Queda como **P3 conocido**, no como regresión nueva. No se recibió una apertura
de T-135 durante esta aceptación; no hubo un cambio de esa tarea que revisar.

## T-130 y T-129: segunda ventana de punta a punta

Banco Web compilado de `tool/t130_emu_main.dart`, proyecto
`demo-t130-e2e`, Auth **9399** y Firestore **8383**, con las reglas de T-130.
Todos los servicios Firebase escucharon únicamente en **127.0.0.1**.
La Expo estaba apagada. Solo se usaron cuentas sintéticas sembradas y T-100.
Chrome **156.0.8078.80**, visible, con contextos separados para oficina y
muelle. No se ejecutó `flutter test --platform chrome`.

La tablet tuvo `adb -s emulator-5554 reverse` en 8383 y 9399. Por el bloqueo
de HTTP explicado en O-134-2, el muelle del recorrido fue el segundo contexto
de Chrome a **360 × 800**, alternativa autorizada. Para cortar sus canales
abiertos se usaron proxies exclusivos de bucle local **8384 → 8383** y
**9398 → 9399**, que cierran conexiones y rechazan las nuevas. La copia servida
al muelle cambia solo las llamadas compiladas de configuración de esos dos
puertos, documentadas en `muelle-proxy-configuracion.json`; no cambia lógica
del producto ni `android/`.

Durante el paso 3 también se quitaron los dos reverse de la tablet; se
restituyeron en el paso 7. **No se usó modo avión** como prueba de corte de
ADB, ni `T130_HOST=10.0.2.2`. En la alternativa Web, el corte efectivo es el
del proxy, no la retirada de los túneles de un dispositivo distinto.

| Paso de 3.10 | Resultado observado |
|---|---|
| 1 | Llegada confirmada para GTSTC; operación M100 publicada, Al día |
| 2 | Muelle unido; dos descargas en **002-01-82** y **002-02-82**; Avance de oficina cuenta **2 descargados, 28 pendientes** |
| 3 | Corte real de canales; finalmente Sin conexión. El indicador mantuvo Al día durante la espera inicial de 35 s |
| 4 | Previo M100N con la banda de operación M100 sin plan de carga |
| 5 | Diálogo con publicación **3-nov, 12:18**, viaje M100N y cifras **30/0/0**; adición a M100; aviso exacto de oficina |
| 6 | Sin conexión: Carga con **0 pendientes**, sin plan nuevo; Nube y cuenta solo ofrece la llegada |
| 7 | Reconexión: llega el plan automáticamente y aparece Abrir plan de carga. Las dos descargas permanecen. La espera inicial de 35 s venció; cuando se buscó Reintentar, ya no estaba porque había sincronizado: no se ejecutó un reintento |
| 8 | Una carga de lleno buscada por últimos dígitos y registrada en **002-01-82**. La lectura remota confirma el tercer movimiento; Avance se revisó otra vez al final: **2 descargados, 1 cargado**, más **19 llenos y 10 vacíos pendientes** |
| 9 | Listado de **30 filas**, revisión **1**, guardado; muelle recibe el aviso exacto y los datos del listado. El analizador señala el pie sintético de totales de la fila 39; las 30 filas se importan |
| 10 | Otro texto del mismo tipo se rechaza; no sustituye la fuente ni sube nuevos trozos |
| 11 | Página de salida: **59 a bordo, 29 cargas pendientes y 28 descargas pendientes**, comparación con llegada disponible y aviso de viaje M100N. Descarga EDI de **7960 bytes**, **59 EQD**, nombre y TDT con M100N |
| 12 | **«Operación cerrada.» al primer intento**, motor siguiendo la operación y después del listado; Publicada y cerrada. **O-128-2/T-129 pasa** |
| 13 | Archivo posterior de la misma escala recibe la negativa de operación cerrada; no agrega fuentes |
| 14 | Operación M100 cerrada; llegada, carga con voyage M100N y listado revisión 1; tres trozos esperados, huellas y longitudes correctas; los tres movimientos originales permanecen |
| 15, opcional | Banco conservado **0.4.1 (7)**: se une a la operación de la variante con el mismo viaje M100, ofrece ambos planos y abre la llegada |

El cierre principal quedó en el emulador a las **12:34:17, Guatemala**.
No se borró ni reescribió ningún movimiento de ese recorrido.
Los estados de conflicto y cancelación usados después pertenecen a otra
operación auxiliar, no a la principal cerrada.

### Textos y cifras contrastados

- Diálogo: **«Se cargan 30 contenedores y 0 celdas reservadas; se descargan 0.»**
- Oficina: **«Plan de carga agregado a la operación publicada de GTSTC: 30
  contenedores y 0 reservas. El muelle lo recibe solo.»**
- Muelle: **«Plan de carga agregado por la oficina: 30 contenedores y 0
  reservas.»** La notificación transitoria del paso 7 no quedó capturada en
  el primer recorrido; se repitió la adición en otra operación sintética,
  con el muelle conectado, y se capturó ese texto exacto sin Reintentar.
- Listado en oficina: **«Listado guardado en la operación publicada de GTSTC:
  30 filas, revisión 1. El muelle lo recibe solo.»**
- Listado en muelle: **«Listado actualizado por la oficina: 30 filas.»**
- Cerrada: **«La operación de esta escala ya está cerrada y sus BAPLIE no
  cambian. Para trabajar con este archivo, ábrelo como una operación nueva.»**

Son las cifras y las formas de la lista 0.8 con **M100/M100N** en lugar de
**P130/P130N**. Las capturas y sus árboles semánticos conservan los literales
completos, sin inferirlos del código.

### Variantes y compatibilidad

La variante inversa publicó primero la carga M100 y agregó la llegada M100.
El diálogo declara **0 contenedores, 0 celdas reservadas y 30 descargas**,
con la fecha de esa publicación. El muelle recibió automáticamente
**«Plano de llegada agregado por la oficina: 30 se descargan.»**, con
**Abrir**. Se verificó después Abrir plano de llegada y Descarga con
**30 por bajar**. La notificación llegó dentro de la espera de 30 s.

La variante de otro equipo se comprobó inicialmente en ese orden inverso:
banda que nombra la operación publicada que ese equipo no tiene, Unirse,
apertura de la fuente publicada y diálogo de adición con su fecha. Se canceló
el diálogo: no subió una fuente por cancelar. La publicación de una copia
local preparada antes de la publicación ajena fue rechazada con el buque,
viaje, puerto, fecha y **Unirse**; el emulador contenía solo una operación
**abierta** de esa terna. Las cerradas de recorridos anteriores permanecen.

Después se repitió la variante en el sentido original con
`T100_CARGA_M100N.edi`: el contexto tenía perfil y última escala GTSTC ya
confirmados, pero no la operación publicada ajena. La banda **«que este
equipo no tiene»** apareció; tras Unirse, descartar el previo y abrir la
llegada publicada, se volvió a abrir M100N. El diálogo mostró la publicación
**3-nov, 12:57**, el contraste M100N/M100 y **30/0/0**. Se pulsó Cancelar.
La lectura final conserva **solo la llegada**, sin fuente de carga agregada.
La copia local de carga preparada antes de esa publicación ajena también
recibió la negativa de publicación duplicada: es la carrera equivalente que
se ejercitó, en lugar de cambiar PAMIT → GTSTC en el mismo formulario.

Un contexto totalmente vacío, sin perfil previo, muestra primero la banda
de perfil propuesto: `_useProfile` solo busca la banda de operación publicada
en la ruta de perfil y escala ya confirmados. La confirmación de Parámetros
vuelve a consultar la nube. No se confunde ese requisito de preparación con
la ausencia de la guarda. Evidencia adicional:
`e2e/ajustes-duplicada-v2/ajustes-banda-M100N-nube.{png,json}` y
`ajustes-dialogo-M100N-fecha.{png,json}`.

El banco antiguo procede del artefacto conservado de T-128; solo se adaptó
el proyecto demo y la base de la URL local, sin recompilarlo ni cambiar su
lógica. Su `version.json` confirma 0.4.1/7. Mostró las dos acciones de abrir y
abrió la llegada de M100. Esto acredita el caso compatible de **mismo viaje**;
no extiende la compatibilidad antigua al viaje distinto M100N.

Evidencia principal: `e2e/oficina-v2/`, `e2e/muelle-v2/`,
`e2e/inversa-oficina-v2/`, `e2e/inversa-muelle-v2/`,
`e2e/duplicada-v2/`, `e2e/compat041-v2/`,
`e2e/aviso-muelle-v2/aviso-carga-exacto.{png,json}`,
`e2e/remoto-resumen-14-cerrada.json`, `compat041-preparacion.json` y
`web-comandos-t130-e2e-v2.json`, bajo `build/t134acc/`.

## T-131 y T-133: inspección visual con el alcance corregido

| Superficie | Observación y límite |
|---|---|
| Chrome, oficina, **1280 × 800** | Distintivo dorado **Oficina** a la derecha del título; posición observada con la operación abierta |
| Chrome, oficina, **1920 × 1080** | Distintivo dorado a la derecha del título; se pulsó y abrió Nube y cuenta |
| Chrome, cuenta de muelle, **360 × 800** | Oficina estrecha: distintivo compacto cobrizo en la barra superior blanca; selector desplegable, sin banda azul; densidad de oficina |
| Tablet nativa, **1280 × 800 dp** | Distribución ancha, riel y panel lateral; densidad de muelle. Se confirmó la llegada para GTSTC y se abrió Descarga local. Código grande con **Baja** debajo; celdas pintadas **56 × 48 dp**, rótulo **11** según tema y código, coincidentes con la captura a escala 2 |

En la tablet, los nodos táctiles medidos son **120 × 104 píxeles** a 320 dpi:
**60 × 52 dp**, incluidos los márgenes; no se confunden con la caja pintada
de 56 × 48. El plano muestra las 30 descargas pendientes y 0 hechas. No se
registró ninguna operación nativa autenticada. **No se comprobaron en nativo
los distintivos cobrizo/dorado de cuentas autorizadas ni Hecho/Revisar/Cancel.**
El bloqueo del banco ya descrito impide acreditarlos en esta aceptación.

Para observar Revisar y Cancel. se sembraron **7 eventos sintéticos** en la
operación auxiliar de la variante inversa, después de terminar el recorrido
funcional y la compatibilidad. Es una **fixture administrativa**, con motivos
y celdas sintéticas, no una prueba de que la UI o las reglas acepten esas
acciones. No se tocó la operación principal. La evidencia declara esta
procedencia en `e2e/fixture-marcas.json`.

En Descarga, **002-01-82** muestra código y **Cancel.** debajo;
**002-01-06**, código y **Revisar** debajo; **002-02-82**, la palomita de
descargado. En Carga se ven cancelación, conflicto y **Cargado**. La oficina
en vista Estado usa palomita para descargado y segunda línea Cargado para
cargado; no se la presenta como la densidad nativa de muelle.
En las capturas estrechas estos rótulos no tapan el código.

Capturas identificadas, todas fuera de Nube y cuenta y sin correos ni UID:

- `e2e/oficina-v2/01-publicada-oficina-1280.png`.
- `e2e/oficina-v2/oficina-1920-distintivo.png`.
- `e2e/inversa-muelle-v2/t133-descarga-fixture-360.png`.
- `e2e/inversa-muelle-v2/t133-carga-fixture-360.png`.
- `e2e/tablet/tablet-descarga-local-56x48.png`.

Las pruebas T-131/T-133 de la suite conservan la cobertura de la banda del
teléfono. **No se toma aquí una captura de esa banda ni se mide RNF-002**.

## Cierre, integridad y entrega

La segunda ventana terminó el **3-nov-2026 a las 13:03:35, Guatemala (UTC−6)**;
la comprobación final de todos los puertos terminó a las **13:03:48**.
Se apagó el árbol propio de Firebase, se cerraron Chrome y sus proxies,
se retiraron los reverse de **8383 y 9399**, se detuvo la app del banco en la
tablet y se cerraron los servidores locales **5942, 5943 y 5944**. La tablet
permanece encendida. No quedan escuchas de esos bancos ni túneles ADB.
La comprobación previa al apagado confirma **127.0.0.1** en todos los puertos
Firebase; no se abrió el cortafuegos. Evidencia:
`build/t134acc/e2e-cierre-ventana2.json`.

Antes del apagado, las **4 operaciones sintéticas** de la segunda ventana
quedaron cerradas. La principal conserva **3 movimientos** y sus **3 fuentes**;
la fixture visual está en otra operación, con **7 eventos**. Las otras dos
tienen **0 movimientos**; la que ejercita Cancelar conserva **1 fuente**.
Todas las comprobaciones de huella y longitud de fuentes siguen en verde.
Evidencia: `e2e/remoto-resumen-cierre-final.json`.

La revisión final de Git conserva el HEAD exigido y no muestra diferencias
de contenido de los archivos ya versionados; solo los avisos previstos de
fin de línea de `windows/flutter/`. Este informe es nuevo. **No se ejecutó
ninguna escritura de Git, instalación de la candidata original ni publicación.**
Los APK instalados fueron exclusivamente bancos de depuración en la tablet.

**Único archivo para versionar:** `docs/t134/aceptacion-codex.md`.
El instrumental, las compilaciones, las capturas y los registros están en
`build/t134acc/`, ignorado por `/build/`. Los datos reales y sus salidas están
solo en `%TEMP%`. **No cambian `pubspec.yaml` ni `pubspec.lock`.**
La revisión final indexa **39 capturas** con SHA-256; sus árboles semánticos
no contienen correos, UID ni páginas de cuenta. El informe no contiene
identificadores de contenedor. Resumen verificable:
`build/t134acc/entrega-verificacion.json`.

Bloque para que Carlos lo ejecute desde la carpeta de aceptación, con HEAD
separado; Codex no lo ejecutó:

```powershell
git add -- docs/t134/aceptacion-codex.md
git commit -m "Sprint 4: aceptacion de la candidata 0.4.2"
git push origin HEAD:sprint-4
```

Tres líneas:

1. **ACEPTADA con reservas**: 2097/2097, analyze cero, ocho baterías y tres clientes 0.4.2 (8).
2. Piloto: 503 celdas y 358 grupos idénticos; T-130/T-129 pasan en Chrome, con límites nativos declarados.
3. Solo se entrega este informe a Git; Firebase y túneles cerrados, sin publicación.

Mensaje para Yov:

> Yov: aceptación 0.4.2 terminada, ACEPTADA con reservas. Suite 2097/2097,
> analyze cero, reglas y tres compilaciones correctas; piloto 503/358 fiel y
> cierre T-129 al primer intento. E2E y variantes en Chrome; tablet comprobada
> localmente, integración de cuentas bloqueada por HTTP del banco. Quedan
> declarados el incidente del lanzador de Windows y el P3 del archivo null.
> Firebase y reverse cerrados a las 13:03:48. Informe en
> docs/t134/aceptacion-codex.md; banda del teléfono y RNF-002 van al ensayo.
