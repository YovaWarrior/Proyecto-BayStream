# T-37 · Viajes recientes y ejecución posterior a T-43

Fecha: 28 de septiembre de 2026. Responsable: Capitán Codex.

## Resultado

Se incorporó el listado de viajes recientes con apertura local y eliminación
confirmada. Se reutiliza `EmptyStateWidget` cuando no hay viajes. La pantalla
explica que se conservan cinco viajes y que los perfiles no se descartan.

La publicación guarda el viaje confirmado antes de mostrarlo. Guardar un sexto
UUID elimina el viaje incorporado más antiguo; actualizar un UUID existente no
lo convierte en el más reciente. Abrir un guardado tampoco cambia su orden.
El orden se conserva al reiniciar y no depende de la fecha del mensaje BAPLIE
ni del orden alfabético de los UUID: Hive ordena sus claves y por eso se añadió
un ordinal `savedOrder` al envoltorio local. Las escrituras se serializan para
evitar que guardados simultáneos dejen más de cinco registros. En disco se
compacta después de sustituir o descartar registros para no acumular sus datos
en el historial interno de Hive.

Los perfiles están en otra caja y no se eliminan con los viajes. El viaje guarda
`vesselProfileKey`, incluida la elección explícita de un homónimo. Al abrirlo se
recupera su geometría histórica, sin volver a leer el EDI ni consultar el parser
o la nube. El plano abierto permanece visible si se elimina su copia local.

El esquema continúa en versión 1: los dos campos nuevos son opcionales y se
mantiene la lectura anterior. Los registros antiguos sin ordinal tienen orden
0 y desempate por clave; su orden original de incorporación no puede recuperarse
porque no estaba registrado. La retención se aplica al guardar.

## Validaciones ejecutadas

- Suite completa: **209/209**, desde el piso de 202. T-37 añade cuatro pruebas y
  T-54 añade tres. No se retiraron aserciones existentes. Se adaptaron los
  llamadores de `resolveIdentity` a su operación asíncrona y el doble del
  repositorio al guardado previo a publicar.
- `flutter analyze`: **cero problemas**.
- Prueba adicional con **CORPUS_A01 real: 1/1**. Guarda seis copias con UUID
  diferentes, cierra y abre Hive, conserva cinco, abre sin parser ni nube y
  recupera **977 contenedores y 34 bahías**. Conserva los huecos ocupados por
  vecinos en las bahías **05, 13, 15, 35, 39, 43 y 45**. Eliminar un viaje
  conserva su perfil.
- Prueba de seis buques distintos: se elimina el más antiguo y permanecen los
  seis perfiles; los identificadores y fechas están deliberadamente fuera de
  orden. Ocho escrituras concurrentes dejan los últimos cinco viajes.
- Prueba de interfaz: listado, apertura, cancelación de eliminación, eliminación
  confirmada y estado vacío. Prueba de homónimos ampliada: al reabrir se conserva
  la clave del perfil elegido explícitamente.

Evidencia local, excluida de Git por estar en `build/`: `build/t37/tests-final.log`,
`analyze-final.log`, `corpus.log` e `identity-reopen.log`.

Reproducción de la prueba real, indicando la carpeta que contiene el EDI:

```powershell
flutter test tool/t37_corpus_test.dart --dart-define="BAYSTREAM_CORPUS_DIRECTORY=<carpeta del corpus>"
```

## Ejecución por cliente: T-43 y T-37

Se verificó código posterior a T-43 sobre la base `e699e5e`, con los cambios
locales de esta sesión. **No se presenta como una ejecución de HEAD limpio**.
El flujo de perfil posterior a la retirada de dependencias sigue funcionando
en los tres clientes. Chrome se comprobó directamente mediante la extensión,
sobre el build final, además de la confirmación manual anterior de Carlos.

| Cliente | Compilación | Ejecución observada |
| --- | --- | --- |
| Windows | Debug compilado, también reconstruido después de T-54. | Codex ejecutó el build posterior a T-43 con T-37: cargó A01 real, confirmó sus parámetros, publicó 977 contenedores/34 bahías, abrió Viajes recientes y volvió a abrir A01. El build final con T-54 se lanzó; no se completó una segunda inspección de su ventana porque el control la reportó minimizada e interrumpida por entrada del usuario. |
| Android · Honor X5d | APK release final compilado. | **Instalado en el teléfono**, sin borrar los datos. Codex cerró y abrió la app final, abrió Perfiles guardados y BUQUE ALFA. Permanecen ALFA, ECO y DELTA; ALFA conserva su geometría, 50 tomas propuestas y límite 80000. Muestra «Perfil sin cambios». No se ejecutó todavía el recorrido manual completo de T-37 en Honor. |
| Web · Chrome | Release Web final compilado y servido en `http://127.0.0.1:8786`. | **Codex ejecutó e inspeccionó la app en Chrome real mediante la extensión**: arranque tras recarga, apertura local de A01 (977/34), edición y persistencia del perfil, cancelar/eliminar viaje, estado vacío, conservación del perfil y carga secuencial de A01→A06. El sexto expulsa A01; quedan cinco tras recargar y se conservan los seis perfiles. **Con Offline activo en DevTools, abrió A01→A06→A01 desde Recientes y dibujó el plano sin seleccionar EDI ni reconfirmar parámetros.** |

APK final instalado, SHA-256:
`52B53CDA64DF0F1D47C865BFCB92EDC4903C428A154D0BB9EE7A016606CE4E4E`.

Evidencia Android final: `build/t37/android-final-start.xml`,
`android-final-profiles.xml`, `android-final-profile-top.xml` y
`android-final-profile-limit.xml`. Los registros de compilación terminan en
`web-final-build.log`, `windows-final-build.log` y `android-final-build.log`.
El compilador Web emitió un diagnóstico de fuente Cupertino no encontrada;
la compilación terminó y no es un aviso de `flutter analyze`. No se añadieron
dependencias para ocultarlo.

### Recorrido ejecutado directamente en Chrome

1. Reapertura de A01 desde Recientes: **977 contenedores / 34 bahías**, sin
   selector de EDI ni nueva confirmación de parámetros.
2. Cancelar la eliminación conserva la fila. Confirmarla elimina el viaje y
   muestra el estado vacío; **ALFA sigue en Perfiles guardados**.
3. Carga real, por el selector de archivos, de A01→A06. Se revisaron las
   propuestas y se dejó el límite desconocido en los perfiles nuevos.
   A06 preguntó por el homónimo ECO; se eligió **«Es otro buque»**.
4. Antes de A06 había cinco viajes, A05→A01. Después quedaron exactamente
   **A06 (717/27), A05 (736/27), A04 (979/34), A03 (369/27), A02 (806/30)**,
   en ese orden; los pares indican contenedores/bahías. **A01 fue descartado**.
5. Recargar Chrome conserva esos cinco y su orden. Perfiles guardados conserva
   **seis**: ALFA, BRAVO, CHARLIE, DELTA y dos ECO con claves diferentes
   (`callSign:ZZC5603` e `imo:9000039`).
6. Se reincorporó A01 para preparar la prueba sin red, recuperando directamente
   su perfil: 977/34. El estado de prueba final queda con A01, A06, A05, A04 y
   A03; A02 salió al incorporar A01 otra vez. No se modificaron datos de Firebase.

7. **Prueba sin conexión ejecutada:** Carlos activó `Offline` en Network de
   DevTools para la pestaña BayStream y aportó una captura donde se ve el ajuste.
   Con la app ya abierta, Codex abrió A01 desde Recientes: **977/34**, y dibujó
   Bay Plan. Después abrió A06: **717/27**, y volvió a A01: **977/34**. Ninguna
   apertura pidió un EDI ni confirmar otra vez los parámetros. El cambio entre
   dos viajes distintos comprueba que se recuperó el viaje seleccionado.
   En A01, BAY 05 mostró **40 % de ocupación**, **0 contenedores propios** y
   las sombras de los vecinos de 40 pies. Se guardó evidencia visual.

Alcance: apertura de viajes persistidos con la aplicación ya cargada y la red
de la pestaña bloqueada por DevTools. No se ensayó un arranque en frío offline
ni se equipara esta prueba a instalar una PWA. Al terminar se indicó a Carlos
volver de `Offline` a `No throttling`.

Evidencia en `build/t37/chrome/` (artefactos locales, no versionados):
`recientes-vacio.png`, `cinco-antes-a06.png`, `cinco-despues-a06.png`,
`cinco-tras-recarga.png`, `seis-perfiles-conservados.png`,
`offline-devtools-carlos.png` (captura aportada por Carlos),
`offline-alfa-lista.png`, `offline-alfa-bay05.png`, `offline-alfa.txt` y
`offline-eco.txt`.
SHA-256 del `build/web/main.dart.js` probado:
`3D3A291C621034A8840EB7429F4BB413DF5F431C14C0D9CE9CD94A359DD3853A`.

El recorrido de Chrome está completado. Pendiente: recorrido manual completo
de Carlos en Honor. El recorrido siguiente queda también como guía reproducible.
No se adelanta RF-027. `pubspec.yaml` y `pubspec.lock` **no cambiaron**.

## Archivos de T-37 y Git para Carlos

El bloque enumera exactamente los archivos de este requerimiento, incluido
este informe. No incluye los documentos de tesis con cambios ajenos.

```powershell
git add -- lib/features/vessel/domain/repositories/local_vessel_repository.dart
git add -- lib/features/vessel/data/datasources/hive_vessel_data_source.dart
git add -- lib/features/vessel/domain/entities/vessel_voyage.dart
git add -- lib/features/vessel/presentation/providers/vessel_providers.dart
git add -- lib/features/vessel/presentation/pages/vessel_overview_page.dart
git add -- lib/features/vessel/presentation/pages/recent_voyages_page.dart
git add -- test/local_vessel_repository_test.dart
git add -- test/profile_loading_test.dart
git add -- test/profile_loading_page_test.dart
git add -- test/recent_voyages_test.dart
git add -- tool/t37_corpus_test.dart
git add -- docs/T37-RESULTADOS.md
git commit -m "RF-031: conservar cinco viajes y reabrirlos sin conexion"
```

Ejecutar a continuación el bloque de T-54; su bloque termina con `git push`.
Codex no ejecutó operaciones de escritura de Git ni publicaciones de Firebase.

## Recorrido manual de Carlos en Chrome y Honor X5d

Repetir los seis pasos en cada cliente con archivos del corpus de pruebas:

1. Abrir el build actual (en Chrome, recargar `http://127.0.0.1:8786`). Cargar
   A01 y confirmar sus parámetros si los solicita. Entrar en Viajes recientes:
   debe figurar ALFA con 977 contenedores/34 bahías y el aviso de cinco viajes.
2. Recargar Chrome o cerrar y abrir la app del Honor. Abrir ALFA desde Recientes;
   no debe pedir seleccionar de nuevo el EDI ni confirmar otra vez el perfil.
3. Con la app ya abierta, desconectar la red y volver a abrir ALFA desde
   Recientes. Debe mostrar el plano. Restaurar la conexión al terminar.
4. Eliminar la copia de A01: cancelar una vez conserva la fila; confirmar después
   la quita. Si era la única, aparece el estado vacío. El plano que ya estaba
   abierto puede seguir visible.
5. Entrar en Perfiles guardados y abrir BUQUE ALFA: sus parámetros deben seguir
   ahí aunque su viaje haya sido eliminado.
6. Cargar A01 a A06 en ese orden. Resolver los homónimos de ECO como buques
   distintos y confirmar los parámetros que correspondan. Recientes debe tener
   cinco viajes, A06 primero y A01 fuera; el perfil de ALFA debe seguir guardado.
