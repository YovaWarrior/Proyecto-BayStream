# T-83 · Tapas de escotilla por bahía

Capitán Codex · 12-oct-2026 · rama `sprint-3`.
Estado de entrega: **En revisión**, pendiente de aceptación cruzada de Timonel (10.18).
**Aceptación propia incompleta:** no se declara cumplido «Terminada cuando».
Quedan Chrome y la revisión del último ajuste compacto en el Honor.

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
La franja alineada permanece sobre la bodega. Ese último ajuste pasó la prueba
de widget a 360 dp, pero todavía requiere recompilación y revisión en clientes.
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

## Clientes

Windows pasó la lectura histórica, guardado de 21 declaraciones, copia de tres
tapas de 03 a 06, contornos en el plano y reapertura después de cerrar el proceso.
El banco cotejó el perfil leído con el visible y con el publicado por el notifier.
Se abrió mediante `Start-Process explorer.exe -ArgumentList <exe>`.
Almacén real comprobado:
`C:\Users\Giova\AppData\Local\BayStream\vessel_store`, cajas `t83acc_*`.
El archivo `t83acc_movements.hive` queda en cero bytes: no se registraron movimientos.
Solo se cerraron los PID propios 21188 y 29008.

Honor: instalado solo `gt.cmartinez.baystream.t83`, 720×1600 px y densidad 320,
**360×800 dp**. A07/A08 se prepararon y el perfil histórico se leyó sin declarar;
el plano mantuvo 405 contenedores y 55 reservas, con 26/26 cargas pendientes en
05/06. La vista angosta reveló la necesidad del resumen compacto. Se añadió
después de esta observación; falta recompilar y revisar su versión final,
declaración/copia y reapertura en el Honor. La variante se cerró mediante
`adb shell am force-stop gt.cmartinez.baystream.t83`; no se tocó la app de Play.

Chrome: **sin aceptar**. El control de navegador falló dos veces al cargar su
política de cabeceras. La revisión automática rechazó después el comando para
abrir un Chrome propio con perfil aparte, con el único motivo «blocked by policy».
Carlos abrió manualmente la página local. Al intentar observar la ventana,
Computer Use terminó la sesión porque no pudo determinar con confianza la URL
actual de Chrome para aplicar su política. No se intentó sortear el bloqueo ni
se siguió con entradas de interfaz. La página se sirve en `http://127.0.0.1:8083`,
con servidor local PID 28992; se deja disponible para Carlos. No se cierra su Chrome.

Antes del resumen compacto finalizaron las tres compilaciones release:
Windows 55.2 s (recompilación de alineación), APK 134.2 s (misma corrección) y
Web 102.2 s. **Esos binarios no se dan como compilaciones finales del último
ajuste compacto**. Pendientes: recompilar la fuente final y completar los
recorridos de los clientes; Windows conserva la evidencia ya obtenida sobre
guardado, copia y reapertura, pero no se verificó ahí la rama compacta nueva.

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

Las rutas propias son:

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

## Horas

Primera marca registrada: 12-oct-2026, 17:40:03 (Guatemala), después de las
lecturas iniciales. Interrupción de la aceptación: 18:03:25. **0.39 h en el
intervalo registrado**, más las lecturas iniciales sin marca de inicio;
estimación 4.0 h. No se inventa un total exacto que incluya ese tramo anterior.
La aceptación restante no se ha contabilizado.

## Continuación necesaria

1. Recompilar Windows, APK `.t83` y Web desde la fuente final en la copia temporal,
   un comando de Flutter a la vez y con las opciones privadas por ruta.
2. Honor: declarar los tres tipos, editar/copiar 03 a 06, mirar el resumen completo
   a 360 dp y la franja alineada, cerrar la variante y releer el perfil idéntico.
3. Chrome visible: perfil histórico, declaraciones/copia, plano y recarga con
   perfil idéntico. La automatización quedó bloqueada; Carlos puede realizar
   el recorrido manual o retomarlo en otra sesión si la herramienta recupera su acceso.
4. Completar este informe con evidencia y horas restantes. No bajar el piso 563.

## Git para Carlos

Codex no ejecuta estos comandos. Solo incluyen las 15 rutas propias.

```powershell
git add -- "lib/features/vessel/domain/entities/hatch_covers.dart"
git add -- "lib/features/vessel/domain/entities/vessel_profile.dart"
git add -- "lib/features/vessel/domain/entities/entities.dart"
git add -- "lib/features/vessel/data/repositories/local_vessel_repository_impl.dart"
git add -- "lib/features/vessel/presentation/pages/hatch_covers_page.dart"
git add -- "lib/features/vessel/presentation/pages/vessel_geometry_page.dart"
git add -- "lib/features/vessel/presentation/pages/vessel_profiles_page.dart"
git add -- "lib/features/vessel/presentation/pages/vessel_overview_page.dart"
git add -- "lib/features/vessel/presentation/providers/vessel_providers.dart"
git add -- "lib/features/vessel/presentation/widgets/hatch_cover_diagram.dart"
git add -- "lib/features/vessel/presentation/widgets/bay_plan_view.dart"
git add -- "test/t83_hatch_covers_test.dart"
git add -- "tool/t83_corpus_test.dart"
git add -- "tool/t83_main.dart"
git add -- "docs/T83-RESULTADOS.md"
git commit -m "Sprint 3: T-83 declarar tapas por bahia y mostrarlas en el plano"
git push
```
