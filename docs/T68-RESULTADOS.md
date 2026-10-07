# T-68 · Puerto de escala y carga de paso en planos de llegada

**Responsable:** Capitán Codex. **Fecha:** 6-oct-2026.
**Estado:** implementada y verificada; pendiente del commit de Carlos y de la aceptación cruzada de Timonel.

## 1. Resultado

Se lee el próximo puerto de la cabecera (`LOC+61`) y se conserva en los viajes guardados. El usuario distingue la salida de la llegada y confirma la escala. Si el último puerto confirmado en este dispositivo coincide con una de esas dos opciones, se propone ese; en otro caso se conserva la propuesta desde `LOC+5`.

Los contenedores descargados en la escala dejan de clasificarse como de paso. El diálogo y la ficha muestran por separado cargas, descargas y tránsito. Las cuatro filas de aceptación coinciden en Windows, Honor y Chrome.

Se leyó la decisión 10.2: el piso vigente es 300 pruebas. La suite quedó en **320/320** y `flutter analyze` en **cero incidencias**. Los cambios posteriores concurrentes de planificación, incluida la decisión 10.3 y el commit `3488237` de T-79a, se conservaron; no forman parte de esta entrega.

## 2. Aceptación de T-66 y T-67

Aceptación cruzada ejecutada **antes de modificar el código de T-68**, sobre los commits `86bc491` y `77e5880`. Se usó el Honor X5d, con pantalla física 720 × 1600 y densidad 320: **360 dp de ancho**.

| Comprobación | Resultado observado | Aceptación |
|---|---|---|
| A07: peso total | 6 940 578 kg exactos en la prueba de corpus; ficha del Honor 6940.6 t, con su redondeo habitual | PASA |
| A07: detalle | «Peso (VGM)», 19 700 kg en XSOU9524030 | PASA |
| A07: celdas | Pesos visibles en toneladas, por ejemplo 2.3 y 6.9; se desplazó horizontalmente el plano a 360 dp | PASA |
| A08v_VGM: peso total | 6 899 700 kg exactos en corpus; ficha del Honor 6899.7 t | PASA |
| A08v_VGM: detalle | «Peso (VGM)», 3 700 kg en XQNU0333380 | PASA |
| A08v_VGM: celdas | Peso 30.3 visible en las celdas de la bahía 014 | PASA |
| A08 y A08v_VGM: límite de prueba 90 000 kg | Las dos pantallas muestran 10 posibles incumplimientos; la prueba compara también las diez alertas completas y coinciden | PASA |

Los 90 000 kg son **un límite de prueba**, no un límite operativo del buque. En las dos pantallas se observaron también cero pilas no evaluadas y una conforme. Las primeras alertas coinciden: bahía 014, bodega, filas 01 y 03, 121 200 kg frente a 90 000 kg.

La comprobación adicional `tool/t66_corpus_test.dart` + `tool/t67_corpus_test.dart` terminó con **11/11** pruebas. Confirma 398 celdas con peso en A07 y 405 en A08v_VGM, además de las mismas alertas para A08/A08v entre 50 y 90 t.

**Conclusión:** T-66 y T-67 aceptadas, incluida la revisión Android pendiente en 10.2. No se corrigió ni amplió su código durante esta aceptación.

Evidencia local, ignorada por Git, en `build/t68/`: `cross-corpus-tests.txt`, `a07-detail.png`, `a07-plan-right.png`, `a08vgm-detail.png`, `a08vgm-plan.png`, `a08vgm-alerts.png`, `a08-alerts.png` y sus XML disponibles.

## 3. Matriz de T-68

Los conteos siguientes se observaron en la ficha de cada aplicación. También se verificaron en el diálogo con el corpus externo y en pruebas de widgets a 360 dp. Los números corresponden a contenedores con número; las reservas sin número pertenecen a T-69.

| Archivo | Escala | Se cargan | Se descargan | De paso | Windows | Honor 360 dp | Chrome |
|---|---|---:|---:|---:|---|---|---|
| CORPUS_A07 | GTSTC | 0 | 114 | 284 | PASA | PASA | PASA |
| CORPUS_A02 | GTSTC | 0 | 303 | 503 | PASA | PASA | PASA |
| CORPUS_A08 | GTSTC | 121 | 0 | 284 | PASA | PASA | PASA |
| CORPUS_A01 | GTPBR | 325 | 0 | 652 | PASA | PASA | PASA |

En A07 y A02 el diálogo ofrece primero HNPCR y GTSTC, con esta explicación:

> El archivo se emitió al salir de HNPCR rumbo a GTSTC: para la salida, la escala es HNPCR; para la llegada, GTSTC.

En los tres clientes se confirmó GTSTC con A08 y después se abrió A07: **GTSTC aparece preseleccionado sin pulsar su opción**. Si A08 utiliza un perfil conocido y abre automáticamente, se confirmó expresamente desde «Parámetros del buque»: una propuesta automática no se convierte en confirmación del usuario.

También se verificó la persistencia fuera de la memoria de la pantalla:

| Cliente | Procedimiento y resultado | Almacén utilizado |
|---|---|---|
| Windows | Cerrar la aplicación, abrirla de nuevo y cargar A07: GTSTC preseleccionado, 114/0/284 | `C:\Users\Giova\AppData\Local\BayStream\vessel_store`, caja `baystream_settings.hive`; en esta ejecución no fue el directorio redirigido de Packages |
| Honor | Confirmar GTSTC y esperar la ficha publicada; detener la variante de prueba, abrirla de nuevo y cargar A07: GTSTC seleccionado, 114/0/284 | Directorio privado de `gt.cmartinez.baystream.t68`, `/data/user/0/gt.cmartinez.baystream.t68/files/vessel_store` según el contrato Android existente |
| Chrome | Confirmar GTSTC en A08, recargar la Web y cargar A07: GTSTC preseleccionado, 114/0/284 | Hive sobre IndexedDB del origen local `http://127.0.0.1:8878` |

El reinicio del Honor se hizo después de observar la ficha publicada; no se atribuye garantía de persistencia a matar el proceso mientras aún está confirmando. La preferencia es independiente de los cinco viajes recientes: la prueba del almacén real cierra/reabre, borra el viaje y conserva el puerto; confirmar «Sin declarar» borra la preferencia y la escala del viaje.

Los flujos probados leen archivos y escriben en el almacén local, sin sincronización ni publicación. El Honor mostraba modo avión con Wi-Fi activo; no se afirma una desconexión física completa. No se hicieron mediciones H5 ni accesos a su proyecto.

Evidencia de pantalla en `build/t68/`: `honor-a01.png`, `honor-a02.png`, `honor-a07.png`, `honor-a08.png`, `honor-a07-preselect.png`, `honor-a07-restart.png`; los XML correspondientes; `windows-a01.png`, `windows-a02.png`, `windows-a02-dialog.png`, `windows-a07.png`, `windows-a08.png`, `windows-a07-preselect.png`, `windows-a07-restart.png`. Chrome se revisó visible mediante el navegador conectado; sus capturas y lecturas accesibles están en la conversación, no se guardaron como archivos del repositorio.

## 4. Implementación y retrocompatibilidad

- `VesselVoyage.portOfNextCall` es opcional y viaja por `toJson`/`fromJson`. Los registros anteriores sin el campo siguen abriendo.
- El parser busca `LOC+61` únicamente antes del primer `LOC+147`. Exige `^[A-Z]{2}[A-Z0-9]{3}$`; A04 y A06 enmascarados quedan en `null`. No interpreta ese código como comprobación de que el puerto exista en un catálogo.
- El dominio calcula los tres conteos. De paso exige escala y puerto de carga declarados, y que ni carga ni descarga coincidan con la escala.
- La preferencia se expone por `LocalVesselRepository`, se implementa en el repositorio local y se guarda con `put`/`delete` y `flush` en una caja de ajustes del mismo motor Hive. La presentación no accede directamente a Hive.
- Con `LOC+61` válido se vuelve a pedir la escala incluso con un perfil de casco conocido. Sin `LOC+61` se conserva el flujo anterior.
- Solo la confirmación escribe el último puerto. Cancelar o abrir un viaje reciente no lo reemplaza. Un viaje reciente mantiene su propia escala guardada.

**No cambiaron `pubspec.yaml` ni `pubspec.lock`.** No se agregaron dependencias. Tampoco se modificaron `lib/main.dart`, opciones de Firebase, pantallas H5, archivos de planificación ni documentos de tesis.

## 5. Validaciones ejecutadas

| Validación | Resultado | Evidencia local |
|---|---|---|
| Suite completa | 320/320; piso anterior 300 | `build/t68/full-tests.txt` |
| T-68: pruebas nuevas + corpus externo | 26/26: 20 de la suite y seis del corpus | `build/t68/t68-corpus-tests.txt` |
| Aceptación cruzada T-66/T-67 | 11/11 | `build/t68/cross-corpus-tests.txt` |
| `flutter analyze` | No issues found | `build/t68/analyze-final.txt` |
| Windows release configurado | Compilación correcta, 35.1 s; pantalla revisada | `build/t68/windows-build.txt` |
| Web release | Compilación correcta, 55.3 s; Chrome visible revisado | `build/t68/web-build.txt` |
| Android arm64 release, variante de prueba | BUILD SUCCESSFUL, 44 s; Honor revisado | `build/t68/android-build.txt` |
| Diff de código | Sin errores de espacios en `git diff --check` | Consulta de lectura |

Las pruebas cubren LOC+61 válido, ausente, enmascarado y situado dentro de la carga; JSON antiguo; historial coincidente, ausente o ajeno; carga, descarga y tránsito; confirmación/cancelación/reapertura; persistencia real de Hive y la interfaz a 360 dp.

Comandos principales reproducibles desde el repositorio, con la ruta local del corpus sustituible:

```powershell
flutter test --reporter expanded
flutter analyze
flutter test test/t68_port_of_call_test.dart tool/t68_corpus_test.dart --dart-define="BAYSTREAM_CORPUS_DIRECTORY=C:/Users/Giova/OneDrive/Documentos/OneDrive/Desktop/Archivos .EDI/Anonimizados/files" --reporter expanded
flutter test tool/t66_corpus_test.dart tool/t67_corpus_test.dart --dart-define="BAYSTREAM_CORPUS_DIRECTORY=C:/Users/Giova/OneDrive/Documentos/OneDrive/Desktop/Archivos .EDI/Anonimizados/files" --reporter expanded
```

Las compilaciones de Windows y Web utilizaron el archivo privado de configuración ya existente mediante `--dart-define-from-file`; su contenido no se copió al informe. La prueba Android cambió el applicationId y la firma únicamente mediante un script Gradle de prueba bajo `build/t68/`. La app de Play `gt.cmartinez.baystream` se conservó; se instaló la variante separada `gt.cmartinez.baystream.t68`. Para el selector Android se usaron copias `.txt` de contenido idéntico en `Download/T68`, externas al repositorio.

### Mensajes y límites de la prueba

El primer ejecutable de Windows se compiló sin los defines privados y presentó exactamente:

```text
Falta la configuración de Firebase
Esta versión de BayStream no tiene todas las opciones necesarias para iniciar. Solicita una compilación configurada al responsable.
```

Se cerró ese ejecutable y se recompiló con la configuración existente. La versión configurada abrió y pasó la matriz. No fue necesario modificar el arranque ni instalar herramientas globales.

La compilación Web mantuvo el aviso de fuentes existente:

```text
Expected to find fonts for (MaterialIcons, packages/cupertino_icons/CupertinoIcons), but found (MaterialIcons).
```

Gradle avisó de funciones obsoletas incompatibles con Gradle 9.0; la compilación terminó correctamente. No se cambió ninguna dependencia para limpiar esos avisos. Las pruebas de widgets del corpus cargan la Roboto existente para comprobar el ancho real, en vez de la tipografía cuadrada Ahem del runner.

## 6. Archivos de esta entrega

| Ruta | Cambio |
|---|---|
| `lib/features/vessel/domain/entities/vessel_voyage.dart` | Próximo puerto persistido, propuesta, conteos y tránsito |
| `lib/features/vessel/data/services/baplie_parser_service.dart` | LOC+61 de cabecera validado |
| `lib/features/vessel/domain/repositories/local_vessel_repository.dart` | Contrato de último puerto confirmado |
| `lib/features/vessel/data/repositories/local_vessel_repository_impl.dart` | Adaptación del contrato local |
| `lib/features/vessel/data/datasources/hive_vessel_data_source.dart` | Caja de ajustes y persistencia |
| `lib/features/vessel/presentation/providers/vessel_providers.dart` | Lectura de historial y confirmación explícita |
| `lib/features/vessel/presentation/pages/vessel_geometry_page.dart` | Dos puertos y los tres conteos |
| `lib/features/vessel/presentation/pages/vessel_overview_page.dart` | Paso del viaje y la propuesta al diálogo |
| `lib/features/vessel/presentation/widgets/voyage_summary_card.dart` | Escala y reparto en la ficha |
| `test/profile_loading_page_test.dart` | Fake adaptado al contrato |
| `test/vessel_geometry_page_test.dart` | Expectativas de los nuevos rótulos |
| `test/t68_port_of_call_test.dart` | Pruebas nuevas de T-68 |
| `tool/t68_corpus_test.dart` | Prueba reproducible del corpus externo |
| `docs/T68-RESULTADOS.md` | Este informe y la aceptación cruzada |

Las capturas, binarios, scripts de instalación y registros bajo `build/t68/` son evidencia local ignorada por `/build/` en `.gitignore`; no se propone forzar su inclusión. Ningún archivo del corpus se añadió al control de versiones.

## 7. Tres líneas de cambios

1. LOC+61 permite distinguir la llegada y propone la última escala confirmada, persistida por el contrato local.
2. La descarga deja de contarse como tránsito; diálogo y ficha muestran los tres conteos de la tabla.
3. T-66/T-67 aceptadas en Honor; T-68 revisada en los tres clientes, con 320 pruebas y análisis en cero.

## 8. Commit para Carlos

Codex no ejecutó operaciones de escritura de Git. Este bloque incluye solo las catorce rutas de T-68; se ejecuta en la rama `sprint-3`, sin cambiar de rama:

```powershell
git add -- lib/features/vessel/domain/entities/vessel_voyage.dart
git add -- lib/features/vessel/data/services/baplie_parser_service.dart
git add -- lib/features/vessel/domain/repositories/local_vessel_repository.dart
git add -- lib/features/vessel/data/repositories/local_vessel_repository_impl.dart
git add -- lib/features/vessel/data/datasources/hive_vessel_data_source.dart
git add -- lib/features/vessel/presentation/providers/vessel_providers.dart
git add -- lib/features/vessel/presentation/pages/vessel_geometry_page.dart
git add -- lib/features/vessel/presentation/pages/vessel_overview_page.dart
git add -- lib/features/vessel/presentation/widgets/voyage_summary_card.dart
git add -- test/profile_loading_page_test.dart
git add -- test/vessel_geometry_page_test.dart
git add -- test/t68_port_of_call_test.dart
git add -- tool/t68_corpus_test.dart
git add -- docs/T68-RESULTADOS.md
git commit -m "Sprint 3: T-68 puerto de escala, descarga y transito con historial local"
git push
```

## 9. Mensaje para Yov

> Yov: Capitán Codex terminó la implementación y verificación de T-68; Carlos tiene el bloque de commit «Sprint 3: T-68 puerto de escala, descarga y transito con historial local». La aceptación cruzada previa de T-66/T-67 pasó en el Honor a 360 dp: A07 6 940 578 kg, A08v 6 899 700 kg, pesos en celdas y detalle VGM; A08 y A08v dan las mismas diez alertas con el límite de prueba de 90 000 kg. T-68 coincide en Windows, Honor y Chrome: A07 GTSTC 0/114/284; A02 GTSTC 0/303/503; A08 GTSTC 121/0/284; A01 GTPBR 325/0/652 (carga/descarga/paso). LOC+61 es opcional y retrocompatible; el último puerto confirmado se guarda detrás del contrato local, en Hive, y sobrevive al reinicio. Suite 320/320, corpus T-68 26/26 y analyze en cero, sin cambios de pubspec ni dependencias. Informe: docs/T68-RESULTADOS.md, con la sección de aceptación de T-66 y T-67. Queda la aceptación cruzada de Timonel para T-68 después del commit y del aviso de Carlos; T-69 no se inició.
