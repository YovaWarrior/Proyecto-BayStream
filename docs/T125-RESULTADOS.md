# T-125 · La 3.2.0 — Resultados

**Programador:** Timonel (Claude Code). **Fecha:** 27 de octubre de 2026.
**Base:** `sprint-4` en `9738be1` (la aceptación de T-124 con las decisiones 10.67 y 10.68),
en `C:\Proyectos\baystream-rediseno`.
**Decisiones:** `SPRINT-4.md` 10.63 a 10.68; la propuesta de la sección 5 de
`docs/T124-RESULTADOS.md` (fila «Estadísticas») y O-124-1 de `docs/t124/aceptacion-codex.md`
(sección 7).

**Paso 0.** `git log --oneline -3` da `9738be1` (aceptación de T-124 y 10.67) encima de
`e3ce0fc`; la 10.68 está en ese commit (`git show HEAD:SPRINT-4.md`). Seguí.

Datos sintéticos en todo: el buque de T-76 (`BUQUE PRUEBA`, `FULL…`, `EMPTY…`), el plan de
carga de T-122 (`BUQUE PRUEBA T122`, `TSTU…`) y el plano de T-117. Nada del piloto ni del
corpus. Evidencia en `build/t125/` (fuera de Git).

## 0. Resumen

| Punto | Qué cambia | Dónde | Prueba (roja antes) |
|---|---|---|---|
| 1 · Estadísticas con los vacíos asignados | En un plan de carga, cuenta lo que va a bordo como la Lista: cada vacío asignado suma un contenedor, con su tara y su tipo, en su bahía de referencia, su puerto y su naviera; una ficha dice cuántos son | `loading_operation_provider.dart`, `estadisticas_del_viaje.dart`, `voyage_stats_view.dart`, `vessel_overview_page.dart`; `DESIGN.md` 15.13 | `t125_320_test.dart`, grupo 1: asignar sube y saca la ficha, deshacer baja (roja antes) |
| 2 · O-124-1 | Cada sombra de 20 de las impares vecinas lleva su clave, `neighbor-twenty-<posición>` | `bay_plan_view.dart` | grupo 2: el caso de Codex en la oficina, en Contenido y en Carga (las dos rojas antes, con «Duplicate keys») |
| 3 · La versión | `version: 3.2.0+6` y `msix_version: 3.2.0.0` | `pubspec.yaml` (`pubspec.lock` no cambia) | `t93_msix_config_test.dart` pide 3.2.0.0 |
| 4 · La lista del piloto (E1.10) | El encabezado con lo que lleva la 3.2.0; la sección 4 con las versiones, la mezcla y `v3.2.0`, y la vuelta a la 3.1.1; las secciones 0 a 3 y 5 con los rótulos de la 3.2.0 | `docs/piloto/LISTA-PILOTO.md` | cotejo de cada rótulo contra `lib/` y de cada comando contra el repositorio (sección 4 de este informe) |

**Cifras:** la suite completa, **1841 de 1841** en una sola corrida, sin reintentos ni omitidas (el piso era 1832); `flutter analyze lib test` en **cero**. La
candidata compila en release con 3.2.0 (6) en los tres clientes, en `build/t125/`. Capturas:
**30** PNG sintéticos en los dos temas (la Web 12 y el emulador 18, de ellas 12 de
Estadísticas).

## 1. Estadísticas cuenta los vacíos asignados (10.68)

**Lo que pasaba.** Estadísticas leía `voyage.containers`, el archivo. Un vacío que el muelle
asigna a una celda reservada no tiene número en el plan de carga, así que no salía en ninguna
cifra, aunque la Lista y las dos búsquedas lo traían desde H6 (`aboardContainersProvider`).

**El arreglo.**
- `loading_operation_provider.dart`: `assignedEmptiesProvider` da los vacíos asignados
  (`LoadingOperation.assignedEmpties`) cuando la escala carga algo, y
  `aboardContainersProvider` pasa a sumarlo al archivo. Es la misma fuente para la Lista y
  para Estadísticas: lo que daba antes `aboardContainersProvider` no cambia.
- `estadisticas_del_viaje.dart`: `EstadisticasDelViaje.de(voyage, asignados: …)` recorre el
  archivo y los asignados. Dos campos nuevos dicen de dónde sale cada contenedor,
  `delArchivo` y `vaciosAsignados`, y `total` es su suma, así que las cifras siguen cuadrando
  por construcción. `fichaDeLosAsignados` da el texto de la ficha, o `null` sin ninguno.
- `voyage_stats_view.dart`: `VoyageStatsView` gana `vaciosAsignados` (opcional, vacío por
  omisión: los bancos de T-109 y T-110 y las pruebas de T-121 no cambian). La ficha va debajo
  de la protagonista y la tabla del resumen gana la fila «Vacíos asignados», las dos solo si
  hay alguno.
- `vessel_overview_page.dart`: Estadísticas recibe `ref.watch(assignedEmptiesProvider)`.

**La ficha** (`BsFichaDeCifra`, clave `estadisticas-vacios-asignados`, sin rol), escrita en
`DESIGN.md` 15.13:

| Vacíos asignados | La ficha |
|---|---|
| Ninguno | No sale; la página es la de antes |
| 1 | «Incluye: 1 vacío asignado a una celda reservada, que el archivo no trae» |
| 2 o más | «Incluye: 2 vacíos asignados a celdas reservadas, que el archivo no trae» |

«Celda reservada» es como la app las llama en la ficha de la bahía («1 celda reservada»).
**No cambian** las alertas de estiba ni la comparación de viajes (10.66, punto 5). `domain/`
no se tocó: `assignedEmpties` ya existía desde T-122.

**Pruebas.**
- `test/t125_320_test.dart`, grupo 1. **La que pide el encargo:** la página entera en la
  oficina (1920 × 1000), con la operación del plan de T-76 en una bitácora en memoria. Sin
  asignar, la protagonista dice 2, sin ficha, «0 vacíos». El muelle asigna el OR 12
  (`EMPTY0000012`, tara 2 185 kg) a la reserva 003‑08‑82: la protagonista sube a 3, la bahía
  03 a 3 contenedores, PAMIT y TEST a 3, «1 vacío», y sale la ficha en singular. Se deshace
  con «Marcado por error»: todo vuelve a 2, el peso de la bahía baja exactamente 2 185 kg y la
  ficha se va. **Antes del arreglo falla** en la primera subida: «Expected: '3' Actual: '2'»
  (`build/t125/01-rojo-antes-del-arreglo.log`).
- Además, la ficha con el vacío asignado que da el dominio, en los dos temas, a 360 × 800 con
  la letra a 2.0 y a 1920: se lee entera, sin textos cortados ni palabras partidas, cumple el
  contraste del texto, y «Ver como tabla» conserva la ficha y trae la fila (4 casos). Y la
  guarda: sin vacíos asignados, ni ficha ni fila (1 caso).
- **«Las cifras cuadran»** de `t121_estadisticas_test.dart` distinguen el archivo de lo
  asignado: el 977, el plano de T-117 y el viaje sin posiciones afirman `delArchivo` igual al
  total y `vaciosAsignados` en 0, sin ficha. Un caso nuevo asigna dos vacíos sobre el plano de
  T-117 (uno de 20 en cubierta de la 01, que va con la 02, y uno de 40 en bodega de la 06):
  `delArchivo` 14, `vaciosAsignados` 2, total 16; llenos igual, vacíos +2, 20 y 40 pies +1
  cada uno, USHOU 5 y PAMIT 2, «Sin naviera 14» y «TEST 2», la 02 con 13 en su cubierta y
  202 000 + 2 185 kg, la 06 con uno más en bodega y 37 000 + 3 900 kg; y las sumas por estado,
  puerto, naviera, tamaño y bahía siguen dando el total. Los textos de la ficha, en singular y
  plural.
- `test/support/t121_estadisticas_support.dart`: `t121Pump` acepta `vaciosAsignados`.

## 2. O-124-1 · Una clave por celda de los veintes vecinos

**La causa.** `_hueco` envolvía cada celda tomada por veintes de las impares vecinas en
`KeyedSubtree(key: ValueKey('neighbor-twenty'))`. En Carga, con la operación ya leída, cada
celda va dentro de su `PlanDragCell` y las claves no son hermanas; pero fuera de Carga (y en
el primer cuadro de Carga, antes de leer la operación) las celdas de un nivel son hijas
directas de la misma fila, y dos sombras en ella chocan.

**El arreglo.** `ValueKey('neighbor-twenty-$position')`, con la posición de la celda en la
par (`0220282`). Un comentario dice por qué.

**Pruebas.** `test/t125_320_test.dart`, grupo 2, con el caso de Codex: 20 por cargar en
0210282 y 0230482 y un 40 de paso en 0220682, la página de la oficina a 1920 × 1080 en debug,
la 22 elegida, en Contenido y en Carga. Recoge lo que llega a `FlutterError.onError` al montar
y al desmontar. **Antes del arreglo, las dos fallan** con el aviso de Flutter: «Duplicate keys
found. … Row(…) has multiple children with key [<'neighbor-twenty'>]»
(`build/t125/02-rojo-o124-claves-duplicadas.log`). Ahora no hay ningún error, y cada sombra
lleva su clave con su «20′».

**`test/t106_plan_widget_test.dart`, al día sin aflojarla:** sigue pidiendo exactamente tres
sombras en la 04 (ahora las que tienen clave `neighbor-twenty-…`), y además que cada una tenga
**su** clave en su celda con su rótulo («2×20′», «2×20′», «20′»); las impares 03 y 05 siguen
sin ninguna.

## 3. La versión

`pubspec.yaml`: `version: 3.2.0+6` y `msix_version: 3.2.0.0`. `pubspec.lock` es idéntico
byte a byte al de antes (comparado con una copia). `test/t93_msix_config_test.dart` pasa a
pedir 3.2.0.0. `pubspec.yaml` y esa prueba estaban con fin de línea CRLF en la carpeta y así
quedan; el cambio son tres líneas.

## 4. La lista del piloto al día (E1.10)

`docs/piloto/LISTA-PILOTO.md`, con la autorización de Carlos (10.65 y 10.68):

- **El encabezado** dice qué lleva la 3.2.0 encima de la 3.1.0: la 3.1.1 (H1, H3 a H7), la
  entrega 1 (T-117 y T-118, 10.46), la entrega 2 (T-121, 10.55), T-124 (10.67) y T-125
  (10.68); y que si el ensayo falla en algo serio se vuelve a la 3.1.1.
- **La sección 4:** la tabla de versiones (Android 3.2.0 con `versionCode` 6, el MSIX
  3.2.0.0 y la Web 3.2.0, compilación 6) y los comandos de 4.2 a 4.4 con esas versiones.
  - **4.1:** la mezcla desde `C:\Proyectos\proyecto-baystream`, con cuatro comprobaciones
    de solo lectura antes (la rama, `34d8838`, `git merge-base --is-ancestor master
    sprint-4` y la punta de `sprint-4`), `git merge --no-ff --no-commit sprint-4`, el commit
    con su mensaje y su línea de autoría, la etiqueta `v3.2.0` y los dos `push`. Si Git marca
    un conflicto, se para y se avisa.
  - **4.5:** volver a la 3.1.1 cliente por cliente: Windows reinstalando
    `BayStream_3.1.1.0.msix`; la Web con `git checkout v3.1.1` y el bloque de 4.4 con
    3.1.1 (5); Android con un AAB **3.1.2, `versionCode` 7**, compilado desde `v3.1.1`,
    porque Play no deja bajar; y que la siguiente versión de Android lleva el 8 o más.
- **Las secciones 0 a 3 y 5,** con los rótulos de la 3.2.0 donde cambiaron. Cada rótulo se
  cotejó contra `lib/` (un agente de solo lectura buscó cada texto entre comillas y yo revisé
  los que cambiaban). Lo que cambió:
  - 0.1, 0.2, 0.4 y 0.5: las versiones y los artefactos de la 3.1.1 para volver; en el Honor,
    la 3.2.0 se reconoce por «Estad.» con «Carga por bahía, de proa a popa»; la travesía, «si
    sobra alto debajo» (el código no tiene la condición de 1280 de ancho);
  - 1.2: «Perfil del buque nuevo» → «Proponer desde el archivo», «Confirma la identidad del
    buque» y «Revisar ampliación» antes de «Parámetros del buque»; «elige tu puerto» ya no
    existe: la escala va en «Puerto de esta escala», con los puertos de descarga y su cuenta
    («GTSTC (7)», H1);
  - 1.3 y 1.8: el selector de modo de la cabecera («Contenido», «Orden», «Carga» y, con un
    plano de llegada, «Descarga»; en menú, «Modo del plano: …»);
  - 1.4 y 1.5: «Tipo 40ST → 42G1», «1 fila sin entender:», «→ ?» y «Falta elegir N
    equivalencias…» en vez de «pendiente», «N contenedores del plan no están en el listado»,
    las filas de «AGREGADOS» (H3) y el aviso con el nombre entre comillas; importar el listado
    **antes** de publicar, porque H2 sigue abierto;
  - 1.7, 1.9 y 1.10: la oficina no tiene chip de texto en el plano (la nube de la cabecera y
    la cabecera de «En vivo» dicen «Al día»); «En vivo» ya no dice «Oficina y N teléfonos del
    muelle», sino el estado de la nube; el panel flotante con «Mostrar el panel lateral»;
    «permission-denied» es ahora «La nube no aceptó la publicación: …»;
  - 1.13 a 1.15: la frase en dos líneas, el singular de T-124, el aviso de los llenos sin fila
    (H4), el diálogo «Guardar BAPLIE de salida» y el de «Cerrar la operación»;
  - **1.16, nueva:** Estadísticas con la ficha de los vacíos asignados, y la sección 3 la
    nombra durante la carga;
  - 2.5: la celda queda «Re‑est.», no «Re‑estiba»; 2.6: sin listado, «Asignar vacío» está
    apagado y la línea dice «Sin listado de agencia: …» («Importa el listado de agencia para
    operar por OR» solo existe en el catálogo de diseño); 2.8: «Confirmar carga por OR o
    contenedor» y el lleno «· sin OR en el listado» (H4); 2.10: el borde punteado lleva el
    icono de pedir cambio, no un reloj; 2.13: el chip de la banda dice «Sin conexión»,
    «Enviando», «Al día» o «Revisar», sin cuentas; 2.14: «Más» con sus rótulos exactos;
  - 3: si 2.2 falla, el piloto se hace con la 3.1.1 (4.5);
  - 5: H2 y el movimiento de las cifras de Estadísticas; O3 quedó cerrada con la entrega 1
    (10.40 y 10.46) y sigue la de T-61.

**Cada comando, contra el repositorio, sin publicar nada:**

| Comando | Comprobado |
|---|---|
| 4.1, la mezcla | `baystream-rediseno` es un árbol de trabajo del repositorio de `proyecto-baystream` (`git worktree list`), así que `sprint-4` es la misma rama local; `proyecto-baystream` está en `master`, `34d8838`, igual a `v3.1.1`; `git merge-base --is-ancestor master sprint-4` da 0, así que no puede haber conflictos; los cinco documentos modificados de esa carpeta no los cambia `sprint-4` (`git diff --name-only master sprint-4`). No ejecuté la mezcla |
| 4.2, `tool\t93_msix.ps1 -Huella … -Version 3.2.0.0` | Parámetros `-Huella`, `-Version` (forma `x.y.z.0`), `-Opciones` por omisión en `C:\Proyectos\baystream-privado\firebase-prod.json` (existe; no lo abrí); escribe `build\t93\BayStream_<versión>.msix` y su `.sha256` sin borrar los anteriores: `BayStream_3.1.1.0.msix` está ahí. No lo ejecuté |
| 4.3, `flutter build appbundle --release --build-name=3.2.0 --build-number=6 …` | Corrido aquí **sin** la configuración privada: sale el AAB con `versionCode` 6 y `versionName` 3.2.0 (manifiesto combinado). `build.gradle.kts` toma `flutter.versionCode`; la firma de subida sale de `android\key.properties`, que está en `proyecto-baystream` y no en esta carpeta (aquí firmó con la de depuración) |
| 4.4, la Web | Corrido aquí **sin** la configuración privada y con otra salida (`build/t125/web`): `version.json` dice 3.2.0 y 6, `main.dart.js` trae `flutter-fire-auth` y `dart run tool/t92_verify.dart` pasa con **57 archivos**, como la 3.1.0 en 10.35. `firebase.json` publica `build/web` y `.firebaserc` apunta a `baystream-app`. La caché `c00f0219…` ya está apartada (`…-viejo-2oct` existe y la original no): esa línea hoy no hace nada. No ejecuté `firebase deploy` |
| 4.5 | `v3.1.1` existe y es `34d8838`; el MSIX 3.1.1.0 y su `.sha256` están en `build\t93`; entre `master` y `v3.1.1` no cambian los documentos modificados de Carlos |

## 5. Las validaciones

**La suite y `analyze`.**

| Corrida | Resultado | Registro |
|---|---|---|
| T-125 antes del arreglo (3 casos) | 3 rojos | `build/t125/01-rojo-antes-del-arreglo.log` |
| O-124-1 antes, con la prueba reordenada (2 casos) | 2 rojos, «Duplicate keys found» | `build/t125/02-rojo-o124-claves-duplicadas.log` |
| T-125, T-121 y T-106 después | 106 de 106 | `build/t125/03-verde-despues.log` |
| La suite completa | 1841 de 1841 | `build/t125/05-suite-completa.log` |
| `flutter analyze lib test` | 5 avisos de llaves de más en mi prueba; corregidos, **cero**; otra vez cero sobre el árbol final | `build/t125/06-analyze.log`, `build/t125/19-analyze-final.log` |
| **La suite completa, sobre el árbol final** | **1841 de 1841**, sin omitidas | `build/t125/18-suite-final.log` |

1832 del piso más 9: las 8 de `t125_320_test.dart` y el caso nuevo de
`t121_estadisticas_test.dart`. Ninguna omitida, ningún `// ignore:`. Rojas antes del arreglo:
la de la página (grupo 1) y las dos de O-124-1; las cuatro de la ficha en los dos temas y el
caso nuevo de T-121 usan la API nueva (`vaciosAsignados`, `asignados:`) y antes no compilarían;
la guarda pasaba antes, como debe.

**La candidata en release, 3.2.0 (6), en los tres clientes** (sin la configuración privada,
que es de Carlos; `lib/main.dart`):

| Cliente | Comando | Resultado | SHA-256 |
|---|---|---|---|
| Web | `flutter build web --release --output=build/t125/web --build-name=3.2.0 --build-number=6` | `version.json`: 3.2.0, 6; T-92 correcto, 57 archivos | `main.dart.js` `4f71ce83…15a8` |
| Windows | `flutter build windows --release --build-name=3.2.0 --build-number=6`, copiado a `build/t125/windows` | `baystream.exe` con `FileVersion` y `ProductVersion` 3.2.0+6 | `154baae8…7f4d` |
| Android | `flutter build appbundle --release --build-name=3.2.0 --build-number=6`, copiado a `build/t125/android/app-release-3.2.0-6.aab` | 51,3 MB; `versionCode` 6, `versionName` 3.2.0 | `cf029f67…9859` |

Las huellas completas están en `build/t125/11-huellas-candidata.txt`. Firmar el MSIX y
publicar le tocan a Carlos.

## 6. Capturas con datos sintéticos, en los dos temas

**30 PNG** en `build/t125/capturas/`. Banco `tool/t124_main.dart` tal cual (el plan de carga
de T-122 y su listado), compilado con la 3.2.0: la Web en `build/t125/banco-web`, servida en
127.0.0.1:5905, y un APK de depuración (`build/t125/banco-apk`) en el emulador.

| Cliente | Cómo | Claro | Oscuro |
|---|---|---:|---:|
| Web (1920 × 1080, la oficina; `tool/t125_capturas_web.py`, Playwright, un perfil nuevo por tema) | automático | 6 | 6 |
| Emulador (`emulator-5554`, `t99_api26`, 360 × 640 dp; `tool/t125_capturas_android.py`, adb + uiautomator, almacén limpio por tema) | automático | 9 | 9 |

En cada tema: el plan de carga con su listado y Estadísticas **sin vacíos asignados** (sin
ficha: 25 a bordo); **el OR 12** asignado a la 021‑00‑84 (26 a bordo, «Incluye: 1 vacío
asignado a una celda reservada, que el archivo no trae», 2 vacíos); y **el OR 13** en la
022‑00‑84 (27, la ficha en plural, 3 vacíos, la 22 con 23 contenedores). De cada una, los
gráficos y «Ver como tabla», con la fila «Vacíos asignados». Los nombres:
`<cliente>_<tema>_estadisticas_{0_asignados,1_asignado,2_asignados}[_tabla].png`. En el
emulador, el paso del listado de T-123 deja además `…_h3_agregados`, `…_h3_importado` y
`…_plano_contenido`.

**Lo que hay que saber del instrumento:**
- La primera corrida de la Web se detuvo en el OR 13: el formulario no propuso celda y
  «Confirmar carga» seguía apagado. El conductor elige ahora la 022‑00‑84, como la 021‑00‑84
  para el OR 12. Sus 4 capturas y el error quedan en `build/t125/capturas/web-intento1/`.
- En el teléfono, la tabla queda bajo el pliegue: la toma `…_tabla` muestra la cabecera con
  «Ver como gráficos» y la ficha; la fila de la tabla se ve en la Web.
- En una toma del teléfono, la pestaña naranja del panel del banco tapa la primera letra de
  «Incluye»: es el banco, no el producto.
- **No hice capturas de Windows:** Windows se validó compilando en release (sección 5).
- El emulador se apagó sin guardar estado y el servidor de la Web se cerró por su PID.

## 7. Archivos tocados

**Presentación:**
- `lib/features/vessel/presentation/providers/loading_operation_provider.dart` — `assignedEmptiesProvider` (punto 1).
- `lib/features/vessel/presentation/formatters/estadisticas_del_viaje.dart` — los asignados, `delArchivo`, `vaciosAsignados` y la ficha (punto 1).
- `lib/features/vessel/presentation/widgets/voyage_stats_view.dart` — la ficha y la fila (punto 1).
- `lib/features/vessel/presentation/pages/vessel_overview_page.dart` — Estadísticas recibe los asignados (punto 1).
- `lib/features/vessel/presentation/widgets/bay_plan_view.dart` — la clave por celda (punto 2).

**Versión:** `pubspec.yaml`. **Diseño:** `DESIGN.md` 15.2, 15.6, 15.10, 15.11, 15.12 y 15.13
(nueva). **Lista del piloto:** `docs/piloto/LISTA-PILOTO.md`.

**Pruebas:** `test/t125_320_test.dart` (nueva, 8 casos); `test/t121_estadisticas_test.dart`,
`test/support/t121_estadisticas_support.dart`, `test/t106_plan_widget_test.dart` y
`test/t93_msix_config_test.dart`.

**Herramientas (nuevas):** `tool/t125_capturas_web.py` y `tool/t125_capturas_android.py`.

**No se tocó:** `domain/`, `data/`, `lib/main.dart`, los congelados, las opciones de
Firebase, las reglas, las dependencias ni `pubspec.lock`. Ningún `// ignore:`.

## 8. Bloque de Git para Carlos

Desde `C:\Proyectos\baystream-rediseno`, en `sprint-4`. Un `git add` por ruta.
**`pubspec.yaml` cambia** (la versión); **`pubspec.lock` no cambia.** Nada de `build/` entra.
`test/t114_fase3_correccion_test.dart` y tres archivos de `windows/flutter/` ya estaban
modificados antes de esta tarea, solo en los finales de línea, y no son míos: no van. Tampoco
`docs/t117/entrega1/`, que no es mío.

```powershell
Set-Location -LiteralPath C:\Proyectos\baystream-rediseno
git add -- lib/features/vessel/presentation/providers/loading_operation_provider.dart
git add -- lib/features/vessel/presentation/formatters/estadisticas_del_viaje.dart
git add -- lib/features/vessel/presentation/widgets/voyage_stats_view.dart
git add -- lib/features/vessel/presentation/pages/vessel_overview_page.dart
git add -- lib/features/vessel/presentation/widgets/bay_plan_view.dart
git add -- pubspec.yaml
git add -- DESIGN.md
git add -- docs/piloto/LISTA-PILOTO.md
git add -- test/t125_320_test.dart
git add -- test/t121_estadisticas_test.dart
git add -- test/support/t121_estadisticas_support.dart
git add -- test/t106_plan_widget_test.dart
git add -- test/t93_msix_config_test.dart
git add -- tool/t125_capturas_web.py
git add -- tool/t125_capturas_android.py
git add -- docs/T125-RESULTADOS.md
git commit -m "Sprint 4: T-125, la 3.2.0 (10.68): Estadisticas cuenta los vacios asignados con su ficha, una clave por celda en las sombras de 20 (O-124-1), version 3.2.0+6 y MSIX 3.2.0.0, y la lista del piloto al dia" --trailer "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
git push origin sprint-4
git log --oneline -1
```

## 9. Tres líneas

1. Estadísticas cuenta los vacíos asignados como la Lista, con la ficha «Incluye: N vacíos asignados…», y cada sombra de 20 del plano lleva su clave (O-124-1).
2. La versión es 3.2.0+6 con el MSIX 3.2.0.0; la candidata compila en release en los tres clientes y la suite da 1841 de 1841.
3. La lista del piloto queda al día para la 3.2.0: versiones, la mezcla con `v3.2.0`, la vuelta a la 3.1.1 y los rótulos cotejados con el código.

## 10. Mensaje para Yov

«T-125 entregada sobre 9738be1. Estadísticas cuenta los vacíos asignados como la Lista
(assignedEmptiesProvider), con la ficha "Incluye: 1 vacío asignado a una celda reservada, que
el archivo no trae" (plural "…a celdas reservadas…"), y la fila "Vacíos asignados" en la
tabla; alertas y comparación sin cambios. O-124-1: neighbor-twenty-<posición>. Las dos pruebas
pedidas estaban rojas antes (2 en vez de 3; Duplicate keys en Contenido y Carga). Suite
1841 de 1841 en una corrida, analyze 0; versión 3.2.0+6 / MSIX 3.2.0.0, pubspec.lock igual;
release 3.2.0 (6) en Web, Windows y AAB; 30 capturas sintéticas (Web 12, emulador 18), sin
Windows. La lista del piloto: encabezado, sección 4 (mezcla con v3.2.0, vuelta con AAB 3.1.2
(7)) y rótulos de 0 a 3 y 5 cotejados con lib/, más 1.16 de Estadísticas. Informe:
docs/T125-RESULTADOS.md.»

ALTO: Codex acepta
