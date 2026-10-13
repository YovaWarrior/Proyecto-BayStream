# T-83 · Tapas de escotilla por bahía

Capitán Codex · 12-oct-2026 · rama `sprint-3`.
Estado de esta entrega: **En revisión**; aceptación propia completada después
de la continuación indicada en 10.22. Implementación commiteada en `5c87e44`.
Continuación del 12-oct, iniciada a las 21:16:59 (Guatemala).
Windows, Honor y Chrome pasaron la aceptación de la fuente final. Timonel
debe revisar y aceptar la tarea según 10.18; esta entrega no sustituye su revisión.

## Cambio y alcance

El perfil guarda una declaración independiente por bahía: sin tapa (bodega
abierta), una tapa automática, o una a tres tapas de grúa con conjuntos de filas.
La ausencia de declaración sigue siendo **sin declarar** y no equivale a bodega
abierta. Los JSON anteriores, sin los campos nuevos, se leen con mapas vacíos:
no reciben tapas por omisión.

La validación usa `VesselGeometry.covers` de T-77, incluida la existencia física
de la fila 00 en bodega. Rechaza filas ajenas, solapes, tapas vacías, cantidades
inválidas y declaraciones en bahías sin evidencia de bodega. El repositorio local
también valida antes de escribir: un borrador inválido conserva el perfil anterior.
La geometría existente es común al buque; T-83 no crea dimensiones por bahía.

Se conserva en el perfil la cota inferior de bahías con bodega observada en los
planes y sus huellas vecinas de 40 pies, igual que el supuesto aceptado en 10.13.
Ese inventario permite volver a editar un perfil sin un viaje abierto. No es una
declaración de todas las bodegas físicas del buque. Un perfil histórico sin ese
inventario pide abrir un BAPLIE para identificar las bahías. Clonar una plantilla
para otro buque no transfiere tapas ni evidencia de bahías del buque anterior.

«Parámetros del buque» y «Perfiles guardados» abren la edición por bahía. El
editor trabaja en un borrador; cancelar lo descarta. Copiar reemplaza las
declaraciones de los destinos elegidos y valida antes de aplicar. Cambiar de
bahía conserva el borrador válido y bloquea el cambio cuando hay un error.

El plano añade contornos por tapa, con T1–T3 y las filas explícitas, sobre la
bodega. Usa tonos de `colorScheme.onSurface`, sin una codificación por colores.
La franja respeta los 54 px de las columnas actuales (50 de celda más márgenes).
Por debajo de 600 dp añade también un resumen compacto dentro del área de
desplazamiento vertical: todas las tapas y filas caben al ancho de 360 dp.
La franja alineada permanece sobre la bodega. Ese ajuste pasó la prueba de widget
y se revisó en el Honor físico y Chrome a 360×800 dp en esta continuación.
No cambia celdas, niveles, pesos, ocupación ni leyendas existentes. Admite filas
no contiguas: se ven las partes del mismo conjunto en la franja identificada.

Fuera de alcance: movimientos de tapas (T-84), segregación (T-85), sobreestibas
(T-95), sincronización de perfiles y cambios de reglas.

## Corpus y carácter PROVISIONAL

**Todas las tapas usadas en esta aceptación son PROVISIONALES.** Ninguna fuente
del corpus declara tapas reales; no se atribuye esta distribución a BUQUE GOLF.
La primera declaración real requiere la hoja del buque o el piloto T-101.

Las nueve fuentes 2.x se leen y generan perfiles sin tapas inventadas. A06 sigue
rechazándose por SMDG15 en las regresiones de T-86. A07/A08 y A08v_VGM conservan
sus conteos, posiciones, pesos, reservas y operación; el corpus completo anterior
se ejecutó junto con T-83.

La unión A07/A08 identifica estas 21 bahías con evidencia de bodega:
`01, 02, 03, 05, 06, 07, 09, 10, 11, 13, 14, 15, 17, 18, 19, 21, 22, 23, 25, 26, 27`.
Incluye las diez bahías con movimientos de bodega de la sección 2 del caso:
`05, 06, 07, 13, 14, 15, 22, 25, 26, 27`. La tabla del caso cuenta movimientos,
no todas las bodegas: una bahía con cero cargas de bodega puede tener carga de
paso o una huella de 40 pies. No se infieren tapas para 29/30 por sus cargas de cubierta.

Las filas de la geometría común son `10, 08, 06, 04, 02, 00, 01, 03, 05, 07, 09`.
El corpus prueba las tres configuraciones y 1–3 tapas de grúa, guarda en Hive,
cierra las cajas y las reabre: el perfil completo queda idéntico en A08 y A08v.
Una escritura inválida se rechaza y mantiene el perfil válido.

## Validación ejecutada

- Suite final: **563/563**, con 16 pruebas nuevas, frente al piso 547.
- Pruebas dirigidas finales: **16/16**, incluida la regresión de alineación
  descubierta en la revisión visual de Windows.
- Corpus completo: **100/100**, las 97 comprobaciones anteriores y 3 de T-83.
- `flutter analyze` final: **cero incidencias**, tras el resumen compacto y su prueba.

Registros en `%TEMP%`: `t83-suite-final.log`, `t83-directed-final.log`,
`t83-corpus-final.log` y `t83-analyze-final.log`.

En la continuación, con la misma fuente y sin cambios de código: **563/563**
de nuevo y **analyze 0**, registros `t83-c2-suite.log` y `t83-c2-analyze.log`.
Los 100/100 del corpus corresponden a la primera sesión: no se repitieron sin
cambio de fuente ni una duda nueva que justificara otra corrida.

## Clientes

Windows pasó la lectura histórica, guardado de 21 declaraciones, copia de tres
tapas de 03 a 06, contornos en el plano y reapertura después de cerrar el proceso.
El banco cotejó el perfil leído con el visible y con el publicado por el notifier.
Se abrió mediante `Start-Process explorer.exe -ArgumentList <exe>`.
Almacén real comprobado:
`C:\Users\Giova\AppData\Local\BayStream\vessel_store`, cajas `t83acc_*`.
El archivo `t83acc_movements.hive` queda en cero bytes: no se registraron movimientos.
Solo se cerraron los PID propios 21188 y 29008.

**Windows: pasa la comprobación de la fuente final.** En esta continuación
se abrió el ejecutable recompilado por Explorer, PID 7212, y se releyó el
perfil persistido: **«Perfil releído igual · 21 bahías · válido»**. El plano
de 06 conservó T1 `10,08,06`, T2 `04,02,00,01`, T3 `03,05,07,09`, alineados
con las columnas sobre la bodega, y los pendientes 26 cubierta / 26 bodega.
Se cerró ese PID y se abrió otra vez por Explorer, PID 33324: el mismo cotejo
volvió a pasar. Se cerró solo ese PID. El almacén fue nuevamente el real
`C:\Users\Giova\AppData\Local\BayStream\vessel_store`, namespace `t83acc`;
`t83acc_movements.hive` seguía en **0 bytes** al finalizar.
Capturas de la continuación: `windows-reapertura-final.png`,
`windows-plano-final.png` y `windows-reinicio-final.png`, en la carpeta `c2`
indicada abajo. La lectura histórica, edición y copia completas corresponden
a la primera sesión; esta comprobación confirma su persistencia y dibujo con
el binario final del resumen compacto.

**Honor: pasa la aceptación final**, solo `gt.cmartinez.baystream.t83`,
720×1600 px y densidad 320, **360×800 dp**, en el almacén privado de la variante
y namespace `t83acc`. Primero reabrió el perfil anterior con **0 bahías** de
tapas, sin inventarlas. A07/A08 se prepararon con 398 y 405+55 respectivamente.
El banco guardó las 21 declaraciones PROVISIONALES. En el editor real se
revisaron sin tapa (01), automática (02) y 1–3 de grúa (05, 06 y 03).

En 03, poner `06` en T2 rechazó «La fila 06 se solapa entre tapas»; poner
`99` rechazó «La fila 99 de la tapa 2 no pertenece a la geometría de bodega
de esta bahía». Ambos avisos se leyeron completos a 360 dp y conservaron el
diagrama válido anterior. Se restituyó T2 a `04,02,00,01`, se copió 03 a 06
y se guardó: **21 bahías**. El resumen de 06 muestra completas las tres tapas:
T1 `10,08,06`, T2 `04,02,00,01`, T3 `03,05,07,09`. También se revisó la franja
sobre la bodega, alineada con las celdas, con desplazamiento horizontal para
sus columnas derechas. El resumen compacto permite comparar las tres sin
ese desplazamiento. El plano mantiene 26/26 cargas pendientes en 05/06.

Se cerró la variante, se volvió a iniciar y «Reabrir y cotejar perfil» dio
**«Perfil releído igual · 21 bahías · válido»**. El plano reabierto conservó
las mismas tres tapas copiadas en 06. Se cerró solo `.t83` con `am force-stop`;
no se tocó la app de Play. Capturas en `%TEMP%\baystream-t83-aceptacion\evidence\c2`:
`honor-anterior-reabierto.png`, `honor-caso-preparado.png`, `honor-sin-tapa.png`,
`honor-automatica.png`, `honor-grua-1.png`, `honor-grua-2.png`, `honor-grua-3.png`,
`honor-rechazo-solape.png`, `honor-rechazo-fila.png`, `honor-copia-aplicada.png`,
`honor-guardado.png`, `honor-plano-compacto.png`, `honor-franja-alineada.png`,
`honor-franja-derecha.png`, `honor-reapertura.png` y `honor-plano-reabierto.png`.

Chrome: incidencias de acceso de la primera sesión. El control falló dos veces al cargar su
política de cabeceras. La revisión automática rechazó después el comando para
abrir un Chrome propio con perfil aparte, con el único motivo «blocked by policy».
Carlos abrió manualmente la página local. Al intentar observar la ventana,
Computer Use terminó la sesión porque no pudo determinar con confianza la URL
actual de Chrome para aplicar su política. No se intentó sortear el bloqueo ni
se siguió con entradas de interfaz. La página se sirve en `http://127.0.0.1:8083`,
con servidor local PID 28992; se deja disponible para Carlos. No se cierra su Chrome.

En la continuación se hizo el reintento autorizado de arrancar un Chrome propio
con perfil aparte y ventana visible. La revisión automática volvió a rechazar
ese comando con «blocked by policy». No se intentó otra vía para ese arranque.
Se preparó el recorrido manual de abajo, sobre la Web recompilada final.

**Chrome: pasa la aceptación propia de Codex el 12-oct-2026.** Carlos pidió
expresamente revisar su pestaña ya abierta en la dirección local. El conector
de navegador pudo entonces seleccionar esa pestaña y verificar la URL, sin
reintentar ni sortear el arranque rechazado. La ventana permaneció visible.
No se registra una aceptación manual de Carlos: las observaciones siguientes
son de Codex mediante el conector.

El perfil histórico mostró **A07 398 · A08 405 + 55 · perfil histórico sin
declarar**; el plano de 06 dijo **tapas sin declarar**, sin contornos inventados.
Se declararon las 21 bahías PROVISIONALES y se revisaron en el editor sin tapa
(01), automática (02), una de grúa (05), dos (06) y tres (03). En 03, T2 `06`
rechazó **«La fila 06 se solapa entre tapas»** y T2 `99` rechazó **«La fila 99
de la tapa 2 no pertenece a la geometría de bodega de esta bahía»**; el diagrama
válido anterior se conservó. Se restituyó T2 `04,02,00,01`, se copió 03→06 y
se guardó: **Edición del producto guardada · 21 bahías**.

El plano amplio mostró los tres contornos alineados y los pendientes 26/26.
Se aplicó un viewport de **360×800**, verificado en el DOM con escala visual 1
y ventana visible. Tras recargar en esas dimensiones, el resumen compacto
mostró completas T1 `10,08,06`, T2 `04,02,00,01` y T3 `03,05,07,09`, sin
desplazamiento horizontal. La captura general del conector reducía toda la
ventana; la captura de la superficie visible exacta 360×800 confirmó el dibujo
sin esa reducción, capturando el viewport exacto; los contornos no se modificaron.
La recarga seguida de «Reabrir y cotejar perfil» dio **«Perfil releído igual ·
21 bahías · válido»**, y el plano mantuvo las tres tapas copiadas.

Almacén: IndexedDB del origen `http://127.0.0.1:8083`, namespace `t83acc`, sin
cuenta. Se restauró el viewport normal y se dejó la pestaña de Carlos abierta.
Capturas en `%TEMP%\baystream-t83-aceptacion\evidence\c2`:
`chrome-historico.png`, `chrome-automatica.png`, `chrome-grua-1.png`,
`chrome-grua-2.png`, `chrome-rechazo-solape.png`, `chrome-rechazo-fila.png`,
`chrome-plano-alineado.png`, `chrome-plano-compacto.png` y `chrome-reapertura.png`.

Antes del resumen compacto finalizaron las tres compilaciones release:
Windows 55.2 s (recompilación de alineación), APK 134.2 s (misma corrección) y
Web 102.2 s. Esos eran los binarios de la primera sesión anteriores al cierre.

**Recompilación final en esta continuación: tres de tres correctas**, ejecutadas
en serie en `%TEMP%\baystream-t83-aceptacion`: Windows **34.2 s**, APK `.t83`
**74.3 s**, Web **48.5 s**. Registros `t83-c2-windows.log`, `t83-c2-apk.log` y
`t83-c2-web.log`. Se comprobó el SHA de cada archivo de `lib/` de la copia
contra el repositorio: **0 diferencias**. El plano final tiene SHA-256
`86859D74B2EDBD37232374B401DF3875A8A5F799A474E68681DF31E7419085C4`
y el banco `45839AD170698EA702F73B964C62CCD08CAD90C71BEDCA7CD96E53219C439B9B`.
Se reutiliza el servidor PID 28992, verificado escuchando solo en `127.0.0.1:8083`.

La copia de compilación, assets A07/A08 y capturas viven exclusivamente en
`%TEMP%\baystream-t83-aceptacion`. El banco `tool/t83_main.dart` prepara las
fuentes con el notifier real y guarda con `saveEditedProfile`. El editor y el
plano son los del producto. El selector nativo de archivos no se ejercita en
este banco. Se prueba en modo sin cuenta, sin escrituras en la nube.

Todas las compilaciones llevan
`--dart-define-from-file=C:\Proyectos\baystream-privado\firebase-prod.json`,
sin leer ni imprimir el archivo. Android solo cambia a `.t83` en la copia
temporal y se firma para pruebas sin copiar ni abrir `android/key.properties`.
Windows usa el SDK C++ local 13.9.0 ya empleado en T-86; no cambia dependencias.

Incidencia corregida: la primera revisión de Windows detectó que el contorno
usaba 50 px y las celdas 54 px con márgenes. Se ajustó, se agregó la prueba
de centros por fila y se recompilaron los clientes. La evidencia de Windows
muestra la alineación corregida. La misma prueba, ampliada después, verifica
que el resumen compacto cabe entre los márgenes de 360 dp, sin excepciones.
MSBuild avisa MSB8029 al compilar en `%TEMP%`; los plugins
Android emiten notas de APIs obsoletas y operaciones no comprobadas.

## Archivos y límites

Sin cambios en `pubspec.yaml`, `pubspec.lock`, `lib/main.dart`, los archivos H5
congelados ni reglas. No se usó Firebase CLI ni credenciales de administrador.
No hubo publicaciones, autenticación de usuarios ni datos reales en el repositorio.
Los cuatro documentos de tesis con cambios ajenos quedan fuera de la entrega.

SHA-256 de la propuesta T-80 publicada por Carlos, antes y después:
`21894B7F43E59F856045473731B795D21F8373C5AC8A1D9FFF324334AC3C9000`.
La comprobación es del archivo local de las reglas publicadas; no se consultó
la consola ni la nube para releer reglas.

Las rutas de la implementación ya commiteada en `5c87e44` son:

- `lib/features/vessel/domain/entities/hatch_covers.dart`
- `lib/features/vessel/domain/entities/vessel_profile.dart`
- `lib/features/vessel/domain/entities/entities.dart`
- `lib/features/vessel/data/repositories/local_vessel_repository_impl.dart`
- `lib/features/vessel/presentation/pages/hatch_covers_page.dart`
- `lib/features/vessel/presentation/pages/vessel_geometry_page.dart`
- `lib/features/vessel/presentation/pages/vessel_profiles_page.dart`
- `lib/features/vessel/presentation/pages/vessel_overview_page.dart`
- `lib/features/vessel/presentation/providers/vessel_providers.dart`
- `lib/features/vessel/presentation/widgets/hatch_cover_diagram.dart`
- `lib/features/vessel/presentation/widgets/bay_plan_view.dart`
- `test/t83_hatch_covers_test.dart`
- `tool/t83_corpus_test.dart`
- `tool/t83_main.dart`
- `docs/T83-RESULTADOS.md`

En esta continuación solo se modifica `docs/T83-RESULTADOS.md`: resultados,
evidencias, recorrido de respaldo y horas. No fue necesaria una corrección de código.

## Horas

Primera marca registrada: 12-oct-2026, 17:40:03 (Guatemala), después de las
lecturas iniciales. Interrupción de la aceptación: 18:03:25. **0.39 h en el
intervalo registrado**, más las lecturas iniciales sin marca de inicio;
estimación 4.0 h. No se inventa un total exacto que incluya ese tramo anterior.
La continuación empezó a las **21:16:59** y la aceptación de clientes terminó
a las **22:03:48**, el 12-oct-2026: **0.78 h**. La pausa entre sesiones no
cuenta como trabajo. Los dos intervalos de aceptación suman **1.17 h**,
más el cierre documental y las lecturas iniciales sin marca. Frente a las
**4.0 h estimadas**, ese total registrado queda por debajo; no es una medición
completa de todo el esfuerzo de implementación y lectura de la primera sesión.

Cierre documental: **22:05:08**, 12-oct-2026 (Guatemala). Continuación con
cierre: **0.80 h**; total de los intervalos registrados de ambas sesiones:
**1.19 h frente a 4.0 h estimadas**, más el tramo inicial sin cronometraje.

## Continuación necesaria · completada

1. **Hecho:** recompilar Windows, APK `.t83` y Web desde la fuente final,
   en serie y con las opciones privadas por ruta.
2. **Hecho:** aceptación completa del Honor a 360×800 dp, copia 03→06,
   resumen completo, franja alineada y perfil idéntico después de reiniciar.
3. **Hecho:** aceptación propia de Chrome en la pestaña visible autorizada por
   Carlos, con tipos, rechazos, copia, contornos a 360×800 y relectura idéntica.
   El arranque propio rechazado no se forzó; el respaldo manual no se utilizó.
4. **Hecho:** Windows final reabierto dos veces, perfil idéntico, franja alineada
   y almacén real propio. Piso **563**, analyze **0** y corpus **100/100** de la
   misma fuente documentados. Solo queda la revisión de Timonel según 10.18.

## Recorrido manual exacto de Chrome · respaldo no utilizado

Se conserva para reproducir la aceptación. Carlos no ejecutó ni confirmó este
recorrido como aceptación manual: Codex completó la revisión descrita arriba.

Este recorrido prueba la Web final en el almacén IndexedDB del origen
`http://127.0.0.1:8083`, namespace `t83acc`, sin cuenta ni movimientos.
Mantén la ventana visible. No publiques nada ni inicies sesión. Si aparece
un error o un resultado distinto, anota el paso y el texto; no se acepta como pasado.

1. En tu Chrome, abre la dirección local y haz **Ctrl+Shift+R**. Debe verse
   «T-83 · aceptación PROVISIONAL». Espera a que cada botón vuelva a habilitarse.
2. Pulsa **«A07/A08 · perfil anterior»**. Debe decir **A07 398 · A08 405 + 55 ·
   perfil histórico sin declarar**. En **«Plano · bahía 06»**, el título dice
   **tapas sin declarar** y no hay contornos. Vuelve con la flecha de la app.
3. Pulsa **«Declarar tapas PROVISIONALES»**: debe decir **21 bahías declaradas**.
   Pulsa **«Editar y copiar tapas»**. Revisa en el selector: **01 sin tapa**,
   **02 automática**, **05 una tapa de grúa**, **06 dos**, **03 tres**.
   «Revisar declaración» debe aceptar cada conjunto sin aviso.
4. En **03**, sustituye las filas de **Tapa 2** por `06` y pulsa **«Revisar
   declaración»**. Debe decir **«La fila 06 se solapa entre tapas»** y conservar
   el diagrama válido anterior. Luego usa `99`: debe decir que la fila 99 no
   pertenece a la geometría de bodega de esa bahía.
5. Restituye **Tapa 2** a `04,02,00,01` y revisa: desaparece el error.
   Las otras tapas quedan **T1 `10,08,06`** y **T3 `03,05,07,09`**.
6. Pulsa **«Copiar a otras bahías»**, marca **06**, pulsa **«Copiar»**, después
   **«Usar estas declaraciones»**. Debe decir **Edición del producto guardada ·
   21 bahías**. Abre **«Plano · bahía 06»** y comprueba las tres tapas copiadas.
7. En la vista amplia, desplázate hasta la separación cubierta/bodega: los
   contornos T1–T3 quedan sobre la bodega, alineados con las columnas y con esas
   mismas filas. Los pendientes de 05/06 siguen **26 cubierta / 26 bodega**.
8. Para la vista angosta, abre las herramientas de desarrollo (**F12**), activa
   la barra de dispositivos (**Ctrl+Shift+M**) y elige **Responsive, 360×800**.
   No cambies ajustes de seguridad. El resumen **«Tapas · bahía 06»** debe
   mostrar completas T1–T3 y todas sus filas sin desplazamiento horizontal.
   La franja alineada sigue sobre la bodega; allí el plano conserva su
   desplazamiento horizontal habitual. No debe haber texto cortado en el resumen.
9. Recarga la página. **No vuelvas a pulsar «perfil anterior» ni «Declarar»**:
   pulsa **«Reabrir y cotejar perfil»**. Debe decir **«Perfil releído igual ·
   21 bahías · válido»**. Abre 06 otra vez y verifica las mismas tres tapas/filas.
10. Si Carlos repite el recorrido, registrar por separado fecha, observador y
    resultados: perfil anterior, tipos, ambos rechazos, copia, contornos
    amplio/360 y reapertura. No confundir esa repetición con la aceptación de
    Codex ya realizada.

## Git para Carlos

Codex no ejecuta estos comandos. Solo incluyen el informe modificado en esta
continuación; la implementación ya está en `5c87e44` y no se vuelve a incluir.

```powershell
git add -- "docs/T83-RESULTADOS.md"
git commit -m "Sprint 3: T-83 completar aceptacion de tapas en los tres clientes"
git push
```

## Mensaje para Yov

T-83 queda En revisión según 10.18: Capitán completó la continuación de 10.22
con Windows, Honor .t83 a 360×800 y Chrome aceptados sobre la fuente final.
Chrome se revisó por Codex en la pestaña local visible que Carlos autorizó;
no fue aceptación manual ni se sorteó el arranque propio bloqueado. Los tipos,
los rechazos, la copia 03→06, el resumen completo y la relectura idéntica de
21 bahías quedaron comprobados. Suite 563/563 y analyze 0 repetidos; corpus
100/100 de la misma fuente, reglas con el mismo SHA. Solo cambia el informe;
pubspec y código sin cambios. Total registrado 1.19 h más lecturas iniciales
sin marca, frente a 4.0 h estimadas. Las tapas siguen PROVISIONALES y falta
la revisión/aceptación de Timonel.
