# T-129 · Revisión corta de Capitán Codex

Fecha: 2-nov-2026, hora de Guatemala. Carpeta: `C:\Proyectos\baystream-qa-r4`.

## Dictamen: NO PASA

Un hallazgo **P2** impide dar por cumplida la espera acotada del cierre. El arreglo
corrige O-128-2 en las cinco pruebas entregadas y respeta la hora del servidor,
pero el temporizador actual limita el silencio entre eventos, no la espera de una
instantánea aceptable. Eventos que el filtro descarta pueden mantener el cierre
pendiente más allá de los 45 segundos anunciados.

No modifiqué código del producto ni sus pruebas. La corrección queda para Timonel
y una comprobación posterior. No hay hallazgos P1 ni otros hallazgos P3 en esta
revisión. La prueba opcional de Chrome contra el emulador no se ejecutó.

## 1. Base y alcance

- Paso 0 confirmado con `git log -1 --format="%H%n%s"`:
  `2d98f23d26e43170038c47e342c2bb764dcb1af0`,
  «Sprint 4: T-129, el cierre que falla despues de revisar el listado (O-128-2)».
  Confirmado también al terminar.
- Leídos `AGENTS.md`, `CLAUDE.md`, las decisiones 10.83, 10.84, 10.87, 10.88 y
  10.89 de `SPRINT-4.md`, y `docs/T129-RESULTADOS.md` completo, incluidas 6.1–6.3.
  Las notas iniciales del informe son históricas: las corridas y la autorización
  de la dependencia se valoran según sus correcciones posteriores.
- Inspeccionados el cambio del commit, `close()`, sus ayudantes y su llamador,
  las cinco pruebas, la nube falsa y las interfaces de plataforma instaladas.
- Solo consultas de Git de lectura: `log`, `show` y `diff --stat`. Nunca
  `git status`, escrituras de Git ni publicaciones.
- Los tres generados de `windows/flutter/` quedaron intactos. La comparación
  SHA-256 antes/después confirma que no los escribí.
- Un comando de Flutter a la vez. Se anunció el inicio y el fin de la ventana.
  La inspección de procesos previa solo mostró los servidores MCP de Dart y su
  servidor de lenguaje; no otra suite ni compilación.

## 2. Corridas propias

Evidencia local: `C:\Proyectos\baystream-qa-r4\build\t129-revision\`.
Los JSON del reportero y `resumen-final.json` permiten cotejar las cifras.

| Comprobación | Resultado | Registro |
|---|---|---|
| `flutter pub get --offline` | Correcto; sin cambios adicionales de manifiesto o lock | `pub-get.log` |
| Cinco pruebas actuales, `flutter test --no-pub test/t129_cierre_test.dart` | **5 aprobadas, 0 fallas, 0 omitidas** | `verde.log`, `verde.json` |
| Mismas pruebas con el repositorio de `a52d203`, en copia temporal | **3 aprobadas y 2 fallas por comportamiento** | `rojo-real.log`, `rojo-real.json` |
| Suite completa, una sola corrida, `flutter test --no-pub` con reportero JSON | **1876 aprobadas, 0 fallas, 0 omitidas**, incluidas las cinco de T-129 | `suite.log`, `suite.json`, `suite-resumen.json` |
| `flutter analyze --no-pub`, sobre copia de fuentes idénticos y con la entrada generada de T-124 preparada | **No issues found!** | `analyze-final.log` |
| Tres sondas adicionales de revisión, fuera del árbol de fuentes | **2 aprobadas y 1 falla**, la reproducción de P2 | `sondas.log`, `sondas.json` |

La suite terminó con `success: true` a los 117953 ms del reportero. No se sumaron
corridas parciales para llegar a 1876. Las sondas adicionales no forman parte de
ese conteo ni se incorporaron a `test/`.

El rojo usa una copia temporal del paquete. Solo su
`lib/features/vessel/data/repositories/firestore_operation_sync.dart` proviene de
`git show a52d203:<ruta>`; las pruebas y la falsa son las actuales. Las pruebas
1 y 2 fallan respectivamente en `Expected: not null / Actual: <null>` y
`Expected: true / Actual: <false>`, ambas con `not_found: No se encontró la
operación para cerrarla en este dispositivo o en la nube…`. Las pruebas 3–5
pasan. No se sustituyó ni restauró ningún fuente del árbol de aceptación.

### Preparación y límites del análisis

Interrumpí mi primera invocación de `analyze` en la raíz, que seguía sin
resultado. Esta carpeta conserva 7450 archivos Dart bajo `build/`, incluidas
muchas copias de aceptaciones anteriores; pasé a una copia preparada para
separar los fuentes vigentes de esos bancos. No se cuenta la invocación
interrumpida como un resultado aprobado ni se atribuye su demora a T-129.

Preparé una copia temporal con `lib/`, `test/`, `tool/`, `integration_test/`,
assets, manifiesto, lock y configuración del analizador. Se cotejaron **628
archivos idénticos**, incluidos **481 fuentes Dart**. Allí aparecieron tres
errores por la ausencia de la entrada generada que importa `tool/t124_main.dart`:
`build/t124/entradas/t124_entradas.dart`. Se generó únicamente en esa copia con
el `tool/t124_entradas.py` existente, usando `T100_LLEGADA.edi` del banco T-128
y `T99_SINTETICO_977.edi` del banco T-125, ambos sintéticos y validados por el
generador. La corrida final dio cero sin editar configuración, silenciar avisos
ni cambiar fuentes. El cero corresponde a esa copia preparada, no a una
corrida final en la raíz con todos sus bancos históricos.

En la preparación del rojo faltó inicialmente copiar `package_graph.json`;
ese intento no llegó a las pruebas y no se usa como evidencia roja. Las primeras
sondas tampoco se usaron como hallazgos: fue necesario ajustar la espera de
continuaciones asíncronas fuera del reloj simulado. Los registros definitivos
son los identificados en la tabla.

## 3. Revisión del arreglo y de la nube falsa

**El criterio de aceptación de la instantánea es correcto:**
`includeMetadataChanges: true`, `!hasPendingWrites` y `!isFromCache`. La lectura
de `Source.server` por sí sola no descarta la compensación local de una escritura
pendiente; el contrato instalado de `GetOptions` lo declara. Usar la hora
resuelta evita guardar una estimación del reloj del cliente.

El único cambio de comportamiento del producto está después del `update` propio
de `close()`: se espera esa instantánea en lugar de hacer otro `_serverGet`.
La escritura y el manejo de la operación ya cerrada permanecen iguales. Las
pruebas 3–5 confirman el cierre sin escucha previa, el segundo intento y la
operación local ausente. Sin escucha previa se agrega una escucha temporal,
pero el resultado y la hora local siguen siendo los del servidor.

**Cuando no llega nada más**, la sonda de silencio confirma que se cancela la
escucha al vencer los 45 segundos, devuelve el código `timeout` y conserva la
copia local abierta. El texto es:

> Sin respuesta de la nube: cerrar requiere red. Revisa la red e inténtalo de nuevo.

La tercera sonda entrega una vista pendiente, después una hora resuelta pero
`isFromCache: true`, y finalmente el eco limpio. El cierre sigue esperando las
dos primeras, acepta la tercera, guarda el cierre local y cancela su escucha.

**La falsa usa la capa apropiada.** Extiende `FirebaseFirestorePlatform`,
`CollectionReferencePlatform` y `DocumentReferencePlatform`, y construye
`DocumentSnapshotPlatform`. Solo implementa `FirebaseApp`, que no está sellada.
Las referencias, instantáneas y `FieldValue` usados por el repositorio son los
reales de `cloud_firestore`. No implementa las clases selladas ni añade
supresiones de diagnóstico.

El orden que modela es el pertinente: vista local con hora nula y escritura
pendiente; aplicación en el servidor y resolución del `update`; eco posterior
que limpia los metadatos y entrega la hora. Sin escucha, `get()` lee el servidor.
Sus simplificaciones están declaradas: no simula red ni caché, trata los
`FieldValue` como horas del servidor y fuerza el orden acuse-antes-del-eco.
Por tanto, demuestra la regresión en ese modelo; no mide los canales del SDK
real ni acredita Windows o Android. Las cinco pruebas originales tampoco
cubren silencio, caché o eventos rechazados prolongados; las sondas de esta
revisión examinan esos bordes sin incorporarse al proyecto.

La dependencia autorizada está exclusivamente en `dev_dependencies`:
`cloud_firestore_platform_interface: 8.0.6`. El commit cambia solo su categoría
del lock de transitiva a `direct dev`, manteniendo versión y SHA-256.
**Esta revisión no cambia `pubspec.yaml` ni `pubspec.lock`.**

## 4. Hallazgo P2 · El plazo se reinicia con instantáneas rechazadas

Ubicación: `lib/features/vessel/data/repositories/firestore_operation_sync.dart`,
líneas 84–91; en concreto, `.timeout(_networkTimeout)` en la línea 88, antes de
`firstWhere`.

`Stream.timeout` reinicia el temporizador con cada evento de datos, antes de que
`firstWhere` decida si sirve. Esto se comprobó también en la implementación del
SDK local de Dart, `lib/async/stream.dart`. Una instantánea pendiente o de caché
no representa la respuesta que necesita el cierre, pero vuelve a darle 45
segundos al temporizador. No existe un plazo total para conseguir el eco válido.

**Reproducción controlada con el repositorio del commit sin modificar:**

1. Usar la misma operación publicada y la misma bitácora de las pruebas T-129.
2. En una copia de la falsa de plataforma, retener el eco posterior al acuse.
   La escritura se aplica y la nube queda cerrada; el documento escuchado
   conserva la vista pendiente.
3. Llamar una vez a `close()` y avanzar el reloj simulado. Emitir una
   instantánea con `hasPendingWrites: true` a los 40, 80, 120 y 160 segundos.
4. A los **160 segundos** todavía hay **una escucha activa** y el cierre sigue
   esperando. La aserción que exige que ya haya terminado falla:
   `Expected: <0> / Actual: <1>`.
5. Dejar de emitir: al superar los 45 segundos desde el último evento, la
   llamada finalmente devuelve `timeout`. Mantener eventos rechazados con
   separaciones menores de 45 segundos permite prolongarla sin un límite total.

La prueba de silencio pasa, y la de filtro de caché/eco pasa. La prueba de plazo
falla: `sondas.log` termina **+2 −1**. Los fuentes exactos de las sondas están
archivados como `sondas_test.dart.txt` y `sondas_fake.dart.txt`; el repositorio
probado conserva el SHA-256 `0ae183822a89fde7d0eb22ce157befbc2eee8e241c33480bfd867c1d9464b0c7`.
`bancos.json` identifica la copia temporal donde se ejecutó:

```powershell
flutter test --no-pub test/t129_cierre_test.dart --plain-name 'REVISION:' --reporter expanded
```

**Impacto y alcance de la evidencia:** incumple la garantía de una espera máxima
del eco y puede mantener ocupada la acción de cierre mientras llegan eventos
que no sirven. La repetición sostenida fue inyectada en la plataforma; no afirmo
haber observado ese patrón ni un bloqueo en producción o en el emulador. La
semántica del temporizador y la ausencia de un plazo total sí están reproducidas.

**Corrección recomendada, sin implementarla:** filtrar primero las instantáneas
válidas y aplicar el plazo antes de tomar la primera, por ejemplo con
`snapshots(...).where(criterio).timeout(_networkTimeout).first`. Así los eventos
rechazados no reinician el plazo y la cancelación de la suscripción permanece
ligada a la resolución o al error. Añadir una prueba de silencio y otra de
eventos rechazados sostenidos, incluida la cancelación de la escucha. Volver a
ejecutar las cinco originales, esas pruebas, la suite completa y `analyze`.

## 5. Emulador y archivos entregados

El caso opcional de oficina en Chrome revisando el listado y cerrando al primer
intento queda **sin ejecutar**. Se inspeccionó el banco T-128, pero no se inició
un emulador ni se abrió una app. Se solicitó el permiso explícito previsto en el
encargo y no se recibió respuesta durante esta revisión. No se accedió a
Firebase real. Esta revisión no levanta O-128-2 mediante una medición E2E nueva.

**Único archivo nuevo a versionar:** `docs/t129/revision-codex.md`.

Las evidencias y scripts auxiliares propios quedan bajo `build/t129-revision/`,
ignorado por `/build/`; no se propone forzarlos a Git. Las copias de contraste y
las sondas están en un directorio temporal identificado en `bancos.json`.
`lib/`, `test/`, `pubspec.yaml`, `pubspec.lock` y los tres generados de Windows
conservan las huellas iniciales. Los datos de persistencia de las pruebas son
de la bitácora en memoria; no se abrió ningún almacén de BayStream de Windows.

## 6. Git para Carlos

Este bloque copia y versiona únicamente el informe en la carpeta donde avanza
`sprint-4`. Versionar el dictamen **no significa aceptar el arreglo**.

```powershell
New-Item -ItemType Directory -Force -Path 'C:\Proyectos\baystream-rediseno\docs\t129' | Out-Null
Copy-Item -LiteralPath 'C:\Proyectos\baystream-qa-r4\docs\t129\revision-codex.md' -Destination 'C:\Proyectos\baystream-rediseno\docs\t129\revision-codex.md'
Set-Location -LiteralPath 'C:\Proyectos\baystream-rediseno'
git add -- docs/t129/revision-codex.md
git commit -m "Sprint 4: revision corta de T-129"
git push origin sprint-4
```

## 7. Tres líneas

T-129 corrige el cierre en sus cinco pruebas; el rojo confirma las dos regresiones por comportamiento.
Suite completa: 1876/1876 sin omitidas; analyze: cero en la copia preparada con fuentes idénticos.
NO PASA por P2: los eventos rechazados reinician el plazo; código intacto y emulador no ejecutado.

## 8. Mensaje para Yov

> Revisé T-129 en `2d98f23`, sin cambiar código. Cinco verdes, rojo de `a52d203`
> +3 −2 por `not_found`, suite única 1876/1876 sin omitidas y analyze cero sobre
> copia idéntica con la entrada sintética de T-124 generada. Dictamen NO PASA:
> P2 en `_afterOwnWrite`, porque `Stream.timeout` antes del filtro reinicia los
> 45 s con eventos rechazados. La sonda mantiene la espera a los 160 s; silencio
> y rechazo de caché/aceptación del eco sí pasan. Recomiendo filtrar antes del
> plazo y probar silencio y eventos sostenidos con cancelación. No ejecuté el
> emulador. Informe: `docs/t129/revision-codex.md`; bloque para copiarlo y
> versionarlo en `baystream-rediseno` dentro del informe. `pubspec.*` intactos.


## 9. Segunda revisión corta · Corrección del P2 (2-nov-2026)

**Dictamen vigente sobre la corrección: PASA.** El P2 de la sección 4 queda
**cerrado**. No encontré hallazgos P1, P2 ni P3 nuevos en el alcance revisado.
Las secciones anteriores conservan el resultado histórico sobre `2d98f23`.

### 9.1 Base y alcance

Revisión sobre `a18d2d3d9c6d326a1f5aa59d76ec81879bc5a9c0`, «Sprint 4: T-129, el
plazo del cierre no se reinicia con instantaneas rechazadas», confirmado al
empezar y al terminar. Se revisó exclusivamente la corrección del plazo, los dos
controles de la falsa y las dos pruebas nuevas, con las regresiones solicitadas.

Leí la 10.91 de `SPRINT-4.md` y la sección 6.4 de `docs/T129-RESULTADOS.md`.
En esta punta todavía no existe la 10.92: el sprint termina anunciándola como
siguiente decisión. Carlos confirmó que está escrita pero sin commit, que solo
resume la corrección y que debía continuar con su encargo, la 10.91 y la 6.4.
No se modificó el documento del sprint.

### 9.2 Código, pruebas y cancelación

- `_afterOwnWrite` (líneas 86–94) usa exactamente
  `snapshots(includeMetadataChanges: true).where(criterio).timeout(_networkTimeout).first`.
  El criterio conserva `!hasPendingWrites && !isFromCache`. Los eventos
  descartados ya no llegan al temporizador; la primera instantánea aceptada
  termina la espera. No cambian la escritura, la hora del servidor ni las demás
  ramas de `close()`.
- `.first` cancela la suscripción al recibir el dato y usa `cancelOnError` para
  el error del plazo. La cancelación se comprobó en las sondas, tanto al llegar
  el eco limpio como al vencer el plazo: **cero escuchas abiertas**.
- `holdEcho` vale `false` por omisión. Activarlo retiene el eco, conservando la
  aplicación de la escritura en el servidor y la resolución del acuse.
  `emitRejected()` emite la vista pendiente; `emitRejected(fromCache: true)`
  emite el documento con `isFromCache: true` y sin escrituras pendientes. Son
  controles de prueba en la capa de plataforma; no incorporan clases selladas
  ni afectan el camino normal mientras no se usan.
- Las **cinco pruebas anteriores y sus auxiliares son idénticos** a los de
  `2d98f23`, normalizando únicamente CRLF/LF para comparar la lectura de Git.
  El cotejo está en `cotejo-cinco-originales.json`.
- Las dos pruebas nuevas comprueban silencio y rechazos sostenidos: a los
  **44 s** el resultado sigue pendiente; a los **46 s** ya es `timeout`, con la
  nube cerrada, la copia local abierta y **cero escuchas**. En la segunda llega
  un rechazo a los 40 s y se siguen emitiendo rechazos a los 80, 120 y 160 s:
  no queda ninguna suscripción y el resultado no cambia.
- El ayudante `pasa()` combina `tester.pump` con vueltas reales mediante
  `tester.runAsync`. Permite terminar las continuaciones de la cancelación
  registradas fuera de la zona del reloj simulado, como explica la 6.4. No
  modifica el plazo del producto ni sustituye el resultado de `close()`.

Los segundos citados son del reloj simulado; no constituyen mediciones de red.
La prueba acota la respuesta entre 44 y 46 s desde el inicio de la espera.

### 9.3 Corridas propias y evidencia

Evidencia definitiva: `build/t129-revision/segunda/`, con `resumen-final.json`.

| Comprobación | Resultado | Registro |
|---|---|---|
| `flutter test --no-pub test/t129_cierre_test.dart` | **7/7**, sin fallas ni omitidas | `t129.log`, `t129.json` |
| Las tres sondas exactas de la primera revisión contra el repositorio corregido | **3/3**, sin fallas ni omitidas | `sondas-exclusivas.log`, `sondas-exclusivas.json` |
| Suite completa, una sola corrida con reportero JSON | **1914/1914**, cero fallas y cero omitidas; incluye las siete de T-129 | `suite.log`, `suite.json` |
| `flutter analyze --no-pub`, copia preparada con fuentes idénticos | **No issues found!** | `analyze-exclusivo.log` |

La suite tiene `success: true` y terminó a los 131326 ms del reportero. No se
sumaron corridas parciales. El conteo de T-129 se obtuvo por la ruta de su suite
en el JSON, que incluye tanto los cinco `test` como los dos `testWidgets`.

Mis tres sondas conservaron exactamente el archivo de pruebas y la falsa
archivados en la primera revisión. Solo el repositorio probado procede de la
punta corregida; `sondas-integridad.json` verifica ese contraste. Pasan los tres
casos: silencio, rechazos pendientes a los 40/80/120/160 s y caché seguida del eco
limpio. La sonda de rechazos que antes fallaba a los 160 s ahora pasa; las dos
pruebas nuevas anteriores acreditan además la respuesta cerca de los 45 s.

Para `analyze` usé una copia temporal con **633 archivos idénticos**, incluidos
**486 fuentes Dart**, la misma configuración y el mismo lock. Como en la
primera revisión, preparé allí la entrada sintética de T-124 con el generador
existente y los sintéticos T-100/T-99. No se alteraron fuentes, configuración ni
supresiones para obtener el cero. `bancos.json` identifica las copias y su cotejo.

**Semáforo.** Carlos autorizó la ventana exclusiva. Mi suite completa terminó
antes de que otro programador iniciara una suite: 23:28:24 frente a 23:28:35.
Detecté posteriormente que ese otro comando sí se había superpuesto con el
tramo de sondas/análisis. No se tocó su proceso. Carlos reservó una segunda
ventana exclusiva y repetí únicamente esas dos verificaciones: **3/3 y cero**,
de 23:33:28 a 23:33:51. Esas repeticiones son las definitivas de la tabla. No
se repitió la suite completa, que no había coincidido con la otra.

### 9.4 Entrega y límites

Solo se añadió esta sección a `docs/t129/revision-codex.md`, manteniendo intacto
el contenido anterior. No modifiqué código del producto ni pruebas del proyecto.
Antes de anexarla se cotejaron **375 archivos** y no había cambios: `lib/`,
`test/`, manifiesto, lock, configuración, informe y los tres generados de Windows.
**`pubspec.yaml` y `pubspec.lock` no cambian.** Las evidencias y los scripts propios
quedan bajo `build/t129-revision/segunda/`, ignorado por `/build/`; no van a Git.

El emulador queda fuera por decisión expresa de Carlos. No se abrió Chrome,
no se inició una app ni se accedió a Firebase real o a los almacenes de Windows.
Los fakes usan bitácora en memoria. El dictamen cierra el P2 de la primera
revisión mediante código y pruebas; el caso E2E del SDK real queda sin medir aquí.

### 9.5 Git para Carlos

```powershell
New-Item -ItemType Directory -Force -Path 'C:\Proyectos\baystream-rediseno\docs\t129' | Out-Null
Copy-Item -LiteralPath 'C:\Proyectos\baystream-qa-r4\docs\t129\revision-codex.md' -Destination 'C:\Proyectos\baystream-rediseno\docs\t129\revision-codex.md'
Set-Location -LiteralPath 'C:\Proyectos\baystream-rediseno'
git add -- docs/t129/revision-codex.md
git commit -m "Sprint 4: segunda revision corta de T-129"
git push origin sprint-4
```

### 9.6 Tres líneas

PASA: el filtro precede al plazo y el P2 queda cerrado, con cancelación de la escucha.
Siete pruebas T-129 y tres sondas verdes; suite única 1914/1914 sin omitidas y analyze cero.
Solo se amplió este informe; código y pubspec intactos, emulador fuera del alcance.

### 9.7 Mensaje para Yov

> Segunda revisión de T-129 sobre `a18d2d3`: PASA, P2 cerrado, sin hallazgos P1/P2/P3
> nuevos. Siete pruebas y mis tres sondas verdes; a los 44 s sigue pendiente y a los
> 46 s devuelve timeout sin escuchas, aunque haya rechazos. Suite única 1914/1914
> sin omitidas y analyze cero en copia preparada con fuentes idénticos. Repetí
> sondas/analyze en una nueva ventana exclusiva tras detectar una superposición
> de comandos; las suites completas no coincidieron. Código y pubspec intactos,
> emulador fuera. Sección 9 de `docs/t129/revision-codex.md`, con el bloque de Git.
