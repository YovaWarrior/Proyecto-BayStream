# T-116 · Pruebas automatizadas para el curso

**Resultado al 22 de octubre de 2026:** 21 pruebas nuevas aprobadas; suite completa de **1084 pruebas aprobadas y cero omitidas**; cobertura instrumentada **89.28 %**. `flutter analyze` conserva únicamente el aviso conocido de master. No se modificó `lib/`, no se usó Firebase real y no se ejecutaron escrituras de Git.

## Entorno, herramienta y alcance

- Trabajo en `C:\Proyectos\baystream-pruebas`, rama `pruebas-curso`, commit de partida `063d2ae`, también apuntado por `origin/master` al inspeccionar.
- Flutter **3.38.9** estable; Dart **3.10.8**; Python **3.14.3**.
- `flutter_test` e `integration_test`: incluidos en ese SDK; el lock los identifica con `0.0.0`, no como versiones independientes del SDK.
- `fake_cloud_firestore` **4.2.0**, fija, en `dev_dependencies`. El generador HTML usa exclusivamente la biblioteca estándar de Python.
- Ficha T-116 adjunta y autorización posterior de Carlos, comunicada desde Yov como decisión 10.12 de Sprint 4. `SPRINT-4.md` no está en esta carpeta; no se accedió a las otras carpetas de trabajo.
- Luz verde de Carlos recibida en este chat. Los comandos de Flutter se ejecutaron uno a la vez. No se abrieron BayStream, el Honor ni el almacén operativo de Windows. Las pruebas nuevas usan bitácoras y Firestore en memoria.
- Se conservaron los 137 archivos de `lib/`: sus huellas SHA-256 antes y después son idénticas.

## Dependencias: por qué 4.2.0 y verificación de Equatable

Se usa **4.2.0 sin `^`**, la versión autorizada que corrige la incompatibilidad observada. **4.1.1 resolvía las restricciones, pero no compilaba con `cloud_firestore 6.8.0`**. La sonda mínima ejecutada falló antes de correr pruebas: `MockWriteBatch.update` no declaraba el parámetro genérico `<T>` requerido por `WriteBatch.update<T>`. La evidencia corresponde específicamente a los **lotes de escritura (`WriteBatch`)**, no a una llamada a `Transaction` desde nuestra prueba. El [changelog oficial de 4.2.0](https://pub.dev/packages/fake_cloud_firestore/versions/4.2.0/changelog) registra la actualización de esa firma. La sonda fue reemplazada por las tres pruebas funcionales finales; no quedó código de terceros copiado ni modificado.

La versión más reciente consultada era 4.4.0; se prefirió la **4.2.0 expresamente autorizada**, suficiente para corregir la compilación y comprobada con el stack existente. No se añadieron overrides.

Antes de resolver efectivamente se ejecutó:

```powershell
flutter pub add --dev fake_cloud_firestore:4.2.0 --dry-run
```

Comparación de los bloques completos de `pubspec.lock` con la copia original tomada de master al iniciar: **117 paquetes originales, 116 intactos y un único cambio: `equatable 2.0.8 → 2.1.0`**, autorizado por Carlos. Ningún paquete original fue retirado. `cloud_firestore 6.8.0`, su interfaz `8.0.6` y los demás paquetes Firebase no cambiaron. La restricción de Equatable en YAML sigue siendo `^2.0.5`.

Los nueve paquetes nuevos respecto a master son:

| Paquete | Versión final |
|---|---|
| antlr4 | 4.13.2 |
| cel | 0.5.6 |
| fake_cloud_firestore | 4.2.0 |
| fake_firebase_security_rules | 0.5.4 |
| logger | 2.8.0 |
| mock_exceptions | 0.8.2 |
| more | 4.7.0 |
| rx | 0.5.0 |
| rxdart | 0.28.0 |

La salida de esta segunda resolución mostró `Would change 3 dependencies.` y luego `Changed 3 dependencies!` porque se comparaba con el intento local anterior: `equatable 2.0.8 → 2.1.0`, `fake_cloud_firestore 4.1.1 → 4.2.0` y `rx 0.4.0 → 0.5.0`. Estos dos últimos son dependencias de desarrollo **nuevas de T-116**, ausentes en master.

Se compararon `lib/src/equatable.dart` y `lib/src/equatable_utils.dart` de ambas versiones instaladas en la caché, en lectura: al excluir comentarios y el cambio de declaración `abstract class` a `abstract mixin class`, su código coincide. La búsqueda sobre el `lib/` actual encontró **cero usos de `EquatableMixin`** y 41 declaraciones `extends Equatable`. La aceptación se verificó además con las 1084 pruebas y el análisis descritos abajo; no hizo falta cambiar las entidades.

## Caja blanca: 16 pruebas y tabla de caminos

Archivo: `test/curso/caja_blanca_iso6346_test.dart`. Cada caso usa comentarios `// Arrange`, `// Act`, `// Assert`, entradas constantes y resultados esperados independientes del método evaluado.

El cálculo independiente usó la tabla alfabética explícita `A…Z = [10,12,13,14,15,16,17,18,19,20,21,23,24,25,26,27,28,29,30,31,32,34,35,36,37,38]` y pesos `[1,2,4,8,16,32,64,128,256,512]`. Se sumaron los diez productos y se obtuvo el residuo de dividir entre 11; solo el residuo 10 se representó con 0. Los resultados quedaron escritos como literales, sin pedir al código probado que calcule su propia expectativa.

| Camino o condición del código | Entrada de la prueba | Cálculo independiente | Resultado |
|---|---|---|---|
| La expresión regular falla: minúsculas | `csqu3054383` | No aplica | `null` |
| La expresión regular falla: 10 caracteres | `CSQU305438` | No aplica | `null` |
| La expresión regular falla: 12 caracteres | `CSQU30543833` | No aplica | `null` |
| La expresión regular falla: dígito en prefijo | `CS1U3054383` | No aplica | `null` |
| La expresión regular falla: letra en serie | `CSQU30A4383` | No aplica | `null` |
| La expresión regular falla: cadena vacía | `''` | No aplica | `null` |
| Rama letras, A=10; rama dígitos `code <= 57` | `AAAU1234566` | Suma 5462; residuo 6 | `true` |
| Rama letras, B=12, salto del 11; dígitos | `BAAU1234568` | Suma 5464; residuo 8 | `true` |
| Rama letras, K=21; dígitos | `KAAU1234566` | Suma 5473; residuo 6 | `true` |
| Rama letras, L=23, salto del 22; dígitos | `LAAU1234568` | Suma 5475; residuo 8 | `true` |
| Rama letras, U=32; dígitos | `UAAU1234566` | Suma 5484; residuo 6 | `true` |
| Rama letras, V=34, salto del 33; dígitos | `VAAU1234568` | Suma 5486; residuo 8 | `true` |
| Formato válido, bucle completo y comparación verdadera | `CSQU3054383` | Suma 6185; residuo 3 | `true` |
| Mismo prefijo y serie, comparación falsa | `CSQU3054384` | Dígito correcto 3, recibido 4 | `false` |
| Residuo 10 representado como 0 | `AAAU0000060` | Suma 3398; residuo 10 → 0 | `true` |
| Residuo 10 con dígito recibido 1 | `AAAU0000061` | Dígito correcto 0, recibido 1 | `false` |

Ejemplo desarrollado: `CSQU305438` produce `13×1 + 30×2 + 28×4 + 32×8 + 3×16 + 0×32 + 5×64 + 4×128 + 3×256 + 8×512 = 6185`. Para `AAAU000006`, `10×1 + 10×2 + 10×4 + 32×8 + 6×512 = 3398`. Esta tabla documenta los caminos ejercitados; el LCOV de Flutter mide líneas, no certifica cobertura de ramas.

## Requerimiento funcional RF-032: tres pruebas

Archivo: `test/curso/funcional_sincronizacion_test.dart`. Una única `FakeFirebaseFirestore` por caso se inyecta en dos `FirestoreOperationSync`, con sesiones falsas de oficina y muelle y sendas `T75MemoryLog`. Se siembra `authorized/{uid}` para ambas cuentas. Las fuentes y el perfil proceden de los fixtures sintéticos T-82; no se copió el corpus real.

| Prueba | Qué verifica |
|---|---|
| Publica, se une y recibe una descarga por la escucha remota | La oficina publica; el muelle recupera identificación, perfil y fuentes iguales; anexa la descarga de `TSTU0000110` en `0030984`; `FirestoreRemoteMovementStore.put` la envía y otra instancia de ese adaptador la recibe por `watch`. Se verifica id, operación, tipo, objetivo, posición, payload, autor y sello de recepción. Ambos derivan el estado `discharged`. |
| Sin sesión publicar falla con `no_session` y no escribe | El resultado es `Left` con ese código; ni Firestore ni la bitácora local reciben una operación. |
| El muelle no publica: falla con `not_office` y no escribe | Una cuenta de muelle autorizada sigue sin poder publicar; el código es `not_office` y no hay escrituras de operación. |

**Límite explícito:** este falso no evalúa las reglas reales de seguridad de Firestore. La batería del emulador `tool/t113_*` verifica esas reglas por separado; no se ejecutó aquí. Sembrar autorizados permite verificar la lectura del adaptador, no prueba que el servidor rechace una escritura prohibida.

El envío se invoca explícitamente en la prueba mediante el adaptador real `FirestoreRemoteMovementStore`. Se verifica publicación/unión y recepción por stream, **no la cola automática de `SyncEngine`**, que tiene su batería existente en `test/t79_sync_engine_test.dart`. Así se reutiliza T75MemoryLog sin inventarle métodos de cola que no implementa. Las escuchas se cancelan al terminar; se usa un timeout de 5 segundos para detectar una recepción ausente, no como medición de latencia. Con 4.2.0 no hizo falta adaptar el SDK falso ni modificar `lib/`.

## Interfaz: dos pruebas

Archivo: `test/curso/interfaz_buscador_test.dart`. Se monta un botón real en `MaterialApp`/Riverpod y se abre el delegado con `showSearch`.

| Prueba | Qué verifica |
|---|---|
| Abre el buscador, filtra por número y devuelve el contenedor | `tester.tap` abre, `tester.enterText('305438')` y `tester.pump` filtran; aparece CSQU3054383 y desaparece la otra unidad. Tocar el resultado devuelve exactamente la unidad esperada, cierra la búsqueda, selecciona la bahía 3 y resalta ese contenedor en los providers. |
| Muestra en español que la búsqueda no tiene resultados | Se escribe `999999`; aparecen `Sin resultados para "999999"` e `Intenta con otro término de búsqueda`; no hay filas ni selección devuelta. |

No duplica `test/container_search_delegate_test.dart`: aquella prueba comprueba las frecuencias de chips llamando a `buildSuggestions`; estas recorren la apertura, entrada, selección y devolución mediante la navegación real de `showSearch`.

## Arranque opcional

No se creó `integration_test/curso_arranque_test.dart`: el `main()` actual exige opciones Firebase y después llama a `Firebase.initializeApp`; sin opciones muestra «Falta la configuración de Firebase» en lugar de «Seleccionar archivo». La ficha indicaba no hacerlo si requería Firebase o sesión. No se añadió ninguna prueba con `skip`.

## Validaciones ejecutadas y salidas

| Comando | Resultado |
|---|---|
| `flutter --version` | Flutter 3.38.9, Dart 3.10.8 |
| `python --version` | Python 3.14.3 |
| `flutter pub add --dev fake_cloud_firestore:4.2.0 --dry-run` | Solo Equatable cambia respecto al master original |
| `flutter pub get` | Resuelve 4.2.0 y Equatable 2.1.0; comparación completa del lock conforme |
| `dart format test/curso` | Tres archivos revisados; formato aplicado a dos |
| `flutter test test/curso --reporter expanded` | Código 0; `00:04 +21: All tests passed!` |
| `flutter test --reporter expanded` | Código 0; `01:24 +1084: All tests passed!`; cero omitidas |
| `flutter analyze` | Código 1 por el único aviso conocido; `1 issue found. (ran in 24.8s)` |
| `flutter test --coverage` | Código 0; `01:29 +1084: All tests passed!`; cero omitidas |
| `python tool/cobertura_html.py` | Genera `coverage/html/index.html` y una página por fuente |

El aviso conservado del análisis es exactamente:

```text
warning - Unused import: 'dart:convert' - tool\t100_sintetico.dart:21:8 - unused_import
```

No se presenta `flutter analyze` como cero incidencias. No se modificó el archivo del aviso. Las 1063 pruebas originales más 21 nuevas explican el total 1084; ambas ejecuciones completas finalizaron sin fallos ni omitidas. Los tiempos anteriores son los mostrados por el runner, no mediciones de rendimiento de la app.

## Cobertura y reporte HTML

| Archivo o conjunto | Líneas instrumentadas | Cubiertas | Porcentaje |
|---|---:|---:|---:|
| Total instrumentado de `lib/` | 13234 | 11815 | **89.28 %** |
| `lib/features/vessel/domain/services/iso6346_check_digit.dart` | 8 | 8 | **100.00 %** |
| `lib/features/vessel/data/repositories/firestore_operation_sync.dart` | 287 | 178 | **62.02 %** |
| `lib/features/vessel/presentation/widgets/container_search_delegate.dart` | 225 | 200 | **88.89 %** |

Estas cifras proceden de **toda la suite con cobertura**, no exclusivamente de las pruebas del curso. Hay 122 archivos instrumentados de los 137 Dart de `lib/`; los otros 15 se muestran como «Sin datos» y no aportan líneas al denominador. Se cuentan líneas únicas `DA` con al menos una ejecución; no líneas físicas ni ramas. No se estableció un umbral mínimo de cobertura para esta tarea.

`tool/cobertura_html.py` genera un índice con los 137 archivos y el total, y 137 páginas de código: **138 páginas HTML** en conjunto. Usa verde para líneas cubiertas, rojo para las no cubiertas y gris para las no instrumentadas, con etiquetas de texto además del color. Escapa el código fuente, fusiona registros LCOV repetidos, admite rutas de Windows y relativas, y enlaza las páginas sin recursos externos. `/coverage/` queda ignorado en Git.

Comprobaciones adicionales ejecutadas:

- Fixtures temporales de LCOV: combinación de registros repetidos, total 1/2 = 50.00 %, código con `<`, `>` y `&` escapado, líneas verdes/rojas, archivo sin datos, rutas y enlace de retorno. Rechazo de DA inválidos y de LCOV que apunta más allá del código actual. Todo aprobado.
- Validación estructural de las 138 páginas: **30577 enlaces y anclas locales válidos**, sin scripts ni recursos externos.
- Edge visible mediante Playwright, con la red desactivada en el contexto: índice de 137 filas, navegación a fuentes y regreso al resumen, conteos de verde/rojo y página ISO verificados. Cero solicitudes externas. Las tres capturas se abrieron para inspección visual.

Evidencia local generada, ignorada y fuera del commit:

- `build/t116/curso.log`, `build/t116/suite-completa.log`, `build/t116/analisis.log`, `build/t116/cobertura.log`.
- `build/t116/dependencias-420.log`: resolución final. `dependencias.log` y `compatibilidad.log` conservan los intentos previos con 4.1.1 y su error real.
- `build/t116/cobertura-resumen.png`, `build/t116/cobertura-fuente.png`, `build/t116/cobertura-iso.png`.
- `coverage/lcov.info` y `coverage/html/`: reproducibles con los comandos siguientes.

## Comandos para Carlos y capturas de la exposición

Ejecutar cuando Flutter esté libre, desde PowerShell; cada comando termina antes de empezar el siguiente. Los comandos de pruebas se ejecutan directamente en la terminal para conservar el registro de aprobación que se capturará.

```powershell
Set-Location 'C:\Proyectos\baystream-pruebas'
flutter pub get
flutter test test/curso --reporter expanded
flutter test --reporter expanded
flutter analyze
flutter test --coverage
python tool/cobertura_html.py
Start-Process (Resolve-Path 'coverage/html/index.html').Path
```

Capturas sugeridas: (1) final de `test/curso` con `+21` aprobado; (2) final de la suite con `+1084`; (3) encabezado del HTML con el total 89.28 %; (4) enlace `iso6346_check_digit.dart`, con sus ocho líneas en verde y 100.00 %; (5) fuente de sincronización, que permite mostrar también líneas no cubiertas en rojo. El aviso conocido de `flutter analyze` está documentado y no debe confundirse con una prueba fallida.

## Archivos modificados

1. `.gitignore`: ignora `/coverage/`.
2. `pubspec.yaml`: añade fake_cloud_firestore 4.2.0 fija solo a desarrollo, con comentario de autorización.
3. `pubspec.lock`: añade nueve paquetes respecto a master y cambia únicamente Equatable entre los originales.
4. `test/curso/caja_blanca_iso6346_test.dart`: 16 pruebas.
5. `test/curso/funcional_sincronizacion_test.dart`: tres pruebas.
6. `test/curso/interfaz_buscador_test.dart`: dos pruebas.
7. `tool/cobertura_html.py`: generador sin dependencias.
8. `docs/PRUEBAS-CURSO.md`: este informe.

**Sí cambian `pubspec.yaml` y `pubspec.lock`.** Los informes y herramientas de otras tareas permanecen intactos; no hay cambios de producción en `lib/`. Los archivos nuevos anteriores están dentro de las rutas autorizadas y no requieren `git add -f`. Los artefactos generados de `build/` y `coverage/` no se versionan.

## Git: comandos para que Carlos los ejecute

Un solo commit para T-116, estando en `pruebas-curso`:

```powershell
git add -- .gitignore
git add -- pubspec.yaml
git add -- pubspec.lock
git add -- test/curso/caja_blanca_iso6346_test.dart
git add -- test/curso/funcional_sincronizacion_test.dart
git add -- test/curso/interfaz_buscador_test.dart
git add -- tool/cobertura_html.py
git add -- docs/PRUEBAS-CURSO.md
git commit -m "Sprint 4: agrega pruebas automatizadas del curso y cobertura HTML"
git push origin pruebas-curso
```

## Tres líneas de entrega

Se añadieron 21 pruebas con AAA, datos sintéticos y recorridos de caja blanca, sincronización e interfaz.

La suite alcanza 1084 aprobadas sin omitidas; el análisis conserva solo el aviso conocido y Equatable es el único paquete original actualizado.

El reporte HTML funciona sin red y muestra 89.28 % de cobertura instrumentada; `lib/` permanece idéntico.

## Mensaje para Yov

T-116 implementada en pruebas-curso: 21 pruebas nuevas y 1084 aprobadas en la suite completa y con cobertura, sin omitidas.

fake_cloud_firestore 4.2.0 fija; respecto a master solo cambia Equatable 2.0.8 → 2.1.0, con igualdad/hash revisados y sin avisos nuevos.

Cobertura instrumentada 89.28 %; ISO 100.00 %, sincronización 62.02 % y buscador 88.89 %; HTML sin red verificado.

Informe, tabla de caminos, límites del falso y comandos de capturas/Git en docs/PRUEBAS-CURSO.md; no se tocó lib/ ni Firebase real.
