# Recorrido de clientes: Honor, Windows y revisión visual de T-41

Capitán Codex · 29-sep-2026 · HEAD inspeccionado: `ea6daad`.

## Resultado

Pasaron las nueve comprobaciones solicitadas por Carlos: ocho en el Honor X5d
y una en Windows. También se ejecutó el recorrido de A03 y su pantalla de
segregación en ambos clientes, incluida la reapertura desde Recientes.

Se operó la interfaz real de la aplicación de producción mediante ADB en Android
y la skill Computer Use en Windows, leyendo los controles y revisando capturas.
No se sustituyó este recorrido por una sonda, un test unitario o una compilación.
No fue una revisión realizada personalmente por Carlos.

## Qué se ejecutó por cliente

| Cliente | Ejecución de esta sesión | Compilación de esta sesión |
| --- | --- | --- |
| Honor X5d, Android 15 | APK release final ya instalado: corpus A01–A06, perfiles, eliminación, persistencia, modo avión y arranque en frío; pantalla T-41 con A03 | Ninguna; se utilizó el APK final existente |
| Windows | EXE release final: límite entero y decimal, guardar/reabrir perfil; A03, confirmación de perfil, segregación y reapertura | Ninguna; se utilizó el EXE final existente |
| Chrome | No se repitió en esta sesión | Ninguna |

Los binarios corresponden a la entrega posterior a T-43 y a T-38/T-41. Sus
SHA-256 coinciden con los del informe `BLOQUE7A-RESULTADOS.md`:

- APK: `9B4E56729587D6459DE55F7935338909F24B5104C580631CDB37293163A57689`.
- EXE: `691BA48778FCAE46523617D71D4A4BDCE1B33882DAECC67636C0BC097BAC0822`.

La PC se apagó por falta de carga después de completar las nueve comprobaciones,
durante la confirmación pendiente de A03 en Windows. Las capturas se conservaron.
Se relanzó el mismo EXE y se repitió la carga de A03 para terminar su revisión.

## Las nueve comprobaciones

| Nº | Comprobación | Resultado observado |
| --- | --- | --- |
| 1 | Honor: cargar A01 y revisar Recientes | ALFA, 977 contenedores / 34 bahías; aviso visible de cinco viajes. ALFA ya tenía perfil confirmado y se reutilizó automáticamente. |
| 2 | Detener completamente, relanzar y abrir ALFA | Se forzó la detención de la app. Tras abrirla, ALFA se recuperó de Recientes sin selector EDI ni reconfirmación del perfil. |
| 3 | Quitar red con la app abierta y reabrir ALFA | Plano visible. Se verificó modo avión y `Active default network: none`; no se dependió solamente del icono de Wi-Fi. |
| 4 | Eliminar ALFA: cancelar y confirmar | Cancelar conservó la fila; confirmar eliminó la elegida y mostró que el perfil se conserva. Había dos importaciones de ALFA: cancelar dejó dos, confirmar dejó una. No se confundió la otra importación con un fallo de eliminación. |
| 5 | Perfil tras borrar el viaje | ALFA siguió en Perfiles guardados con filas 6/6, cinco niveles de cubierta, siete de bodega, 50 tomas propuestas y límite previo 80000. |
| 6 | Importar A01–A06 en orden | Quedaron exactamente cinco: A06, A05, A04, A03 y A02. A01 salió; su perfil continuó guardado. A06 pidió resolver el nombre ECO y se eligió «Es otro buque». |
| 7 | Arranque en frío sin conexión | Modo avión habilitado, Wi-Fi apagado, sin red predeterminada. Se forzó la detención y se comprobó que no quedaba PID. La app arrancó; A06 abrió desde Recientes con su plano y sombras de 40 pies. |
| 8 | Honor: límite 62500.5 | Se cambió ALFA de 80000 a 62500.5, se guardó, se salió y se reabrió. Mostró `62500.5` y «Perfil sin cambios». También lo conservó después de expulsar A01 por el presupuesto. |
| 9 | Windows: entero y decimal | Se guardó 75000 y al reabrir mostró `75000`, sin `.0`. Después se guardó 62500.5 y al reabrir mostró `62500.5` y «Perfil sin cambios». |

En el paso 6, la lista final fue:

| Orden | Archivo | Buque / viaje | Contenedores | Bahías |
| --- | --- | --- | ---: | ---: |
| 1 | A06 | ECO / VIAJE004A | 717 | 27 |
| 2 | A05 | ECO / UNKNOWN | 736 | 27 |
| 3 | A04 | DELTA / VIAJE002A | 979 | 34 |
| 4 | A03 | CHARLIE / VIAJE003A | 369 | 27 |
| 5 | A02 | BRAVO / VIAJE001A | 806 | 30 |

Los seis perfiles permanecieron. ECO quedó separado como `callSign:ZZC5603`
y `imo:9000039`. ALFA conservó `imo:9000003` y el límite de prueba `62500.5`.
La reapertura intermedia de A03 no alteró el orden de incorporación.

## Revisión visual de T-41

En Honor y Windows se cargó el A03 real, se propuso su perfil desde el archivo,
se eligió «No lo tengo» para el límite y se confirmó. La pantalla mostró:

- **2 posibles incumplimientos**.
- **100 no evaluados**.
- **151 conformes en las reglas evaluadas**.

Se leyó la advertencia de apoyo a la decisión, fuente 49 CFR Parte 176 y ausencia
de equivalencia con el Código IMDG. Se recorrieron tarjetas y se comprobó que
los motivos, identificadores, posiciones y referencias resultan legibles.
Ejemplo revisado en Windows: UN1993 / UN2794, posiciones 0140284 / 0260286,
«No evaluado» por grupos de segregación y referencia a §176.83(m)(1)-(2).
En Honor también se revisó UN1993 / UN3085 con sus secundarios y el motivo de
grupos no evaluados. No se observó texto desbordado en esas tarjetas.

Se salió, se reabrió A03 desde Recientes y se volvió a entrar a segregación en
ambos clientes: las tres cifras permanecieron iguales, sin pedir el EDI ni
reconfirmar el perfil.

Alcance preciso: esta revisión visual cubre A03 recién importado y recuperado.
No se fabricó un registro antiguo incompleto para repetir manualmente el aviso
de reimportación; ese caso mantiene la cobertura automatizada documentada en
la entrega T-41. Tampoco se presenta esta inspección como auditoría normativa
ni como revisión individual de las 253 tarjetas.

## Estado final y evidencia

La conectividad del Honor se restauró después del paso 7: modo avión `0`,
Wi-Fi `1`, datos móviles `1` y red predeterminada disponible. Tras el apagado
de la PC se volvió a verificar: modo avión desactivado, Wi-Fi activo y red
predeterminada disponible. Los límites de ALFA quedaron en `62500.5` en ambos
clientes, tal como se solicitó para la prueba; son valores de ensayo, no una
especificación obtenida del buque.

Las capturas y árboles de controles están en `build/recorrido-clientes/`, ignorado
por Git. Evidencias principales (PNG y, en Honor, XML del mismo recorrido):

- `paso1-recientes`, `paso2-abierto`, `paso3-avion-plano`.
- `paso4-cancelado.xml`, `paso4-eliminado`, `paso5-parametros-abajo`.
- `a06-identidad`, `paso6-cinco-viajes`, `paso6-perfiles`, `paso6-alfa-conservado`.
- `paso7-arranque-frio`, `paso7-plano-frio`, `paso8-confirmado`.
- `windows-75000-reabierto.png`, `windows-62500-reabierto.png`.
- `honor-segregacion.png`, `honor-segregacion5.png`, `honor-segregacion-recuperado.png`.
- `windows-segregacion.png`, `windows-no-evaluado.png`, `windows-segregacion-recuperado.png`.

Estas evidencias locales no se incluyen en el commit; pueden perderse al limpiar
`build/`. El helper temporal de ADB también está allí, sin cambios de producto.

## Archivos y validación

Único archivo nuevo para versionar: `docs/RECORRIDO-CLIENTES-RESULTADOS.md`.
No cambió código de aplicación, `pubspec.yaml` ni `pubspec.lock`.
Los cuatro entregables de tesis con cambios preexistentes se dejaron intactos.
No se ejecutaron Git de escritura ni publicaciones de Firebase.

No se volvió a correr la suite ni analyze: esta sesión valida la interfaz del
build ya entregado. Los 237 tests, el test externo del corpus y analyze cero
son resultados previos del bloque 7A, no nuevas ejecuciones de este recorrido.

## Git para Carlos

```powershell
git add -- docs/RECORRIDO-CLIENTES-RESULTADOS.md
git commit -m "Documentar recorrido Honor y Windows de T-37 T-54 y T-41"
git push
```

## Tres líneas

Honor completó el recorrido de viajes y perfiles, incluida la retención de cinco.
El arranque en frío sin red y los límites decimales pasaron; la red se restauró.
A03 mostró los mismos resultados de segregación al cargar y reabrir en ambos clientes.

## Mensaje para Yov

Yov: Capitán Codex completó por interfaz las nueve comprobaciones pendientes de
Honor/Windows. Pasaron la eliminación con cancelación, conservación de perfiles,
A01–A06 con cinco viajes finales y ECO separado, y el arranque en frío del Honor
en modo avión sin red predeterminada. El plano abrió desde Recientes. Honor guardó
62500.5 y reabrió con «Perfil sin cambios»; Windows mostró 75000 sin .0 y conservó
62500.5. También quedó ejecutado el recorrido visual de A03 en Honor y Windows:
2 posibles incumplimientos, 100 no evaluados y 151 conformes limitados, iguales
tras reabrir desde Recientes; motivos, posiciones y fuente legibles. No cambió
código ni dependencias, y no se repitieron suite/analyze. La PC se apagó durante
la revisión de Windows; se recuperó y se terminó. Informe y límites del alcance
en docs/RECORRIDO-CLIENTES-RESULTADOS.md. La red del Honor quedó restaurada.
