# T-119 · El mouse y el touchpad · Resultados

Timonel (Claude Code, Claude Opus 5.5). Rama `sprint-4`, carpeta del rediseño
(`C:\Proyectos\baystream-rediseno`), punta `9ef19f0` («Sprint 4: decisiones 10.75 y 10.76…»).
Es la primera parte de la 0.4.1 (10.74 a 10.76 de `SPRINT-4.md`), con el diseño de la sección 0.7
de `docs/T117-T121-RESULTADOS.md` y las respuestas P4 y P7 de 10.38. Lo que se construyó está en
`DESIGN.md` 16; este informe dice qué se hizo, cómo se comprobó y qué falta.

## 1. Resultado en tres líneas

- **La rueda mueve la silueta** (O-040-2): hacia abajo avanza a la popa y hacia arriba regresa, con
  100 ms de animación; en un extremo pasa a la columna, y el pestillo de 300 ms evita que la
  silueta se robe la rueda al bajar la página.
- **El zoom responde al touchpad y a Ctrl + rueda, también con el mouse** (P4), entre 75 y 300 %,
  sin desplazar nada mientras dura el pellizco y con el punto bajo el puntero quieto, también
  cuando la bahía pasa de caber centrada a no caber.
- **La rejilla tiene barra horizontal** abajo de la columna, encima de la franja de cifras, solo
  cuando la bahía no cabe: se arrastra, un clic en la pista avanza una página y deja 14 dp de
  aire. `web/index.html` no se tocó: falta la prueba de P7 de Carlos en Chrome y Edge (sección 6).

## 2. Base, luz verde y lo que se corrió

- **Leí** `CLAUDE.md` con `AGENTS.md`; de `SPRINT-4.md`, la sección 2 y las decisiones 10.36 a
  10.38, 10.74, 10.75 y 10.76; de `docs/T117-T121-RESULTADOS.md`, 0.5.3 y 0.7; y `DESIGN.md` 13 y
  14.
- **La punta** era `9ef19f0`, la de 10.75 y 10.76. El árbol traía cuatro archivos marcados por
  `git diff --stat` (`test/t114_fase3_correccion_test.dart` y tres de `windows/flutter/`), que solo
  difieren en el fin de línea, como anotó Yov en 10.37, y las carpetas sin seguimiento de
  `docs/t117/entrega1/`, evidencia de la entrega 1. No son míos, no los toqué y no van en el bloque.
- **Flutter**, con la luz verde de Carlos (28-oct, noche), de a un comando: las pruebas nuevas
  hasta que pasaron, las mismas contra el código de antes en una copia en `%TEMP%`, la suite
  completa en una sola corrida y `analyze`. No medí tiempos ni abrí la app.
- **No corrí** la app en Windows ni en la Web: las pruebas con mouse y touchpad de verdad son de
  Carlos (sección 7). Tampoco el corpus.

## 3. Lo hecho

### 3.1 La rueda en la silueta (`DESIGN.md` 16.1)

- `BsRuedaHorizontal` (`lib/core/design/componentes/bs_rueda_horizontal.dart`, nuevo) envuelve el
  desplazable horizontal de `BsSiluetaBuque` y le da su controlador: el de la pantalla o uno
  propio. Con la rueda vertical se registra en `GestureBinding.instance.pointerSignalResolver` y
  anima el desplazable 100 ms (`BsMovimiento.rueda`, nuevo), o salta si el sistema reduce el
  movimiento. Cada paso suma al destino del anterior.
- En un extremo no se registra y la rueda pasa a la columna. No toma la rueda con más componente
  horizontal (el touchpad en la Web), ni Mayús + rueda (la del desplazable), ni Ctrl + rueda.
- `BsPestilloDeLaRueda` envuelve la columna de la oficina y anota la hora de cada paso de la rueda
  que la columna se lleva. Si el último fue hace menos de 300 ms, la silueta no toma la rueda.

### 3.2 El zoom (16.2)

- En `PlanZoomViewport` (`plan_drag_confirmation.dart`): `onPointerPanZoomStart`, `Update` y `End`
  (la escala del inicio por `event.scale`, pasado el 1 %); `onPointerSignal` con Ctrl + rueda
  (por e^(−dy/200)) y con `PointerScaleEvent` (su escala). Ctrl + rueda se registra aunque la
  escala esté en el tope, para que la columna no se desplace.
- Mientras dura el pellizco del touchpad, la rejilla y la columna quedan con
  `NeverScrollableScrollPhysics`: la rejilla desde el lienzo y la columna por
  `pellizcoDelPlanoProvider` (nuevo, en `plano_providers.dart`).
- La escala sigue acotada por `planZoomProvider` y el chip no cambia. En el teléfono también
  amplían, desde la esquina; el pellizco de dos dedos sobre la pantalla es el de siempre.

### 3.3 El punto bajo el puntero (16.3)

- Antes del cuadro con la escala nueva se corren la columna y la rejilla: la columna, lo que crece
  la rejilla por encima del foco; la rejilla, contando su aire de 16 dp y, si la bahía no llena la
  vista, que va centrada. Su ancho natural lo mide `PlanZoomContenido` (nuevo).
- El foco se calcula desde la posición en la pantalla en cada evento: el gesto del touchpad guarda
  la posición del lienzo al empezar, y el lienzo se mueve con la columna mientras se pellizca.

### 3.4 La barra horizontal (16.4)

- En la oficina, el desplazamiento horizontal de la rejilla va por fuera de la escala
  (`rejilla-horizontal`), con la rejilla ampliada en los dos ejes (`_TamanoAmpliado`, antes
  `_AltoAmpliado`).
- `BarraDeLaRejilla` (`barra_de_la_rejilla.dart`, nuevo) envuelve la columna con la `Scrollbar` de
  Material sobre el controlador de la rejilla, abajo, y solo escucha ese desplazamiento. Se ve con
  su pista cuando la bahía no cabe, y entonces la columna deja 14 dp de aire.

## 4. Lo que cambió respecto del diseño (también en `DESIGN.md` 16.6)

1. **La rueda va alrededor del desplazable de la silueta, como decía 0.7.2.** Una primera versión
   iba dentro, sin controlador, y la prueba de dos pasos seguidos la tumbó: mientras el desplazable
   anima, su contenido no recibe el puntero, y el segundo paso se iba a la columna.
2. **Mayús + rueda sigue siendo del desplazable,** y Ctrl + rueda fuera de la rejilla hace lo de
   antes; 0.5.3 decía «nada» para la silueta.
3. **El punto fijo cuenta el aire de 16 dp y el centrado,** que la fórmula de 0.7.2 no contaba, y
   mira el lienzo de ahora y no el del inicio del gesto.
4. **La columna se congela durante el pellizco con un proveedor:** está fuera del lienzo y la
   `ScrollConfiguration` de dentro no la alcanza.
5. **Ctrl + rueda se registra también en el tope.**
6. **La barra de Material sirvió fuera de su desplazable:** no hizo falta una propia.
7. **La tableta del muelle también tiene la barra** cuando la bahía no cabe: es la misma columna.

## 5. Las pruebas (`test/t119_mouse_touchpad_test.dart`, 11)

Con eventos sintéticos por `tester.sendEventToBinding`, en Windows (`TargetPlatformVariant`), con
las fuentes del producto y el plano sintético de T-117 (BUQUE MANUAL; para la silueta, con 30
bahías más). Solo usan claves y piezas que ya existían, así que compilan también contra el código
de antes.

| Prueba | Qué comprueba | Contra el código de antes |
|---|---|---|
| La rueda la avanza hacia la popa y la regresa, y la columna no se mueve | 100 dp por paso, con animación, dos pasos seguidos suman, la columna quieta | Falla: la silueta no se mueve (0, se esperaba 100) |
| Sin animación si el sistema reduce el movimiento | El paso llega en el mismo cuadro | Falla: 0, se esperaba 100 |
| En un extremo la rueda pasa a la columna; del otro lado, no | En la popa hacia abajo, la columna; hacia arriba, la silueta; en la proa hacia arriba, la columna | Falla: hacia arriba la silueta no se mueve |
| El pestillo | Dentro de 300 ms, la columna; a los 300, la silueta; lo que toma la silueta no alarga el pestillo | Falla: la silueta nunca toma la rueda |
| Ctrl + rueda acerca y aleja | e^(−dy/200), 75 y 300 %, la columna no se desplaza, también en el tope; la rueda sola sigue desplazando | Falla: la escala no cambia (1.0) |
| El pellizco del touchpad | El umbral de 1 %, 200, el tope y el piso; durante el pellizco ni la rejilla ni la columna se mueven; al terminar, los dos dedos desplazan | Falla: la escala no cambia |
| El pellizco de la Web (`PointerScaleEvent`) | ×1.5 | Falla: 1.0 |
| El punto quieto con Ctrl + rueda | La celda bajo el puntero, a menos de 1 dp, al pasar de caber centrada a no caber, y al alejar | Falla: la escala no cambia |
| El punto quieto con el pellizco | Con la rejilla y la columna ya desplazadas, en tres pasos | Falla: la escala no cambia (1.5) |
| La barra aparece solo cuando hace falta | Oculta al 100 %, visible al 300 %, pegada a la franja de cifras, 14 dp de aire, el controlador de la rejilla | Falla: no hay barra |
| Arrastrar el pulgar y un clic en la pista | El arrastre mueve la rejilla; el clic, el 80 % de la vista | Falla: no hay barra |

**Cómo se comprobó que fallan antes:** una copia del árbol en `%TEMP%\t119-antes`, con los seis
archivos de `lib/` que cambian devueltos a su versión de `HEAD` (`git show HEAD:<ruta>`, que solo
lee) y sin los dos nuevos, con la prueba nueva. Las 11 fallan, cada una en su comprobación, no al
compilar. La salida está en `build/t119/pruebas-nuevas-contra-HEAD.txt`.

**Lo que destaparon al escribirlas,** antes de la primera corrida en verde:
- el escucha de la rueda dentro del desplazable (sección 4, punto 1);
- el evento que cada escucha recibe es una copia transformada: el pestillo comparaba por identidad
  y anotaba como de la columna lo que tomó la silueta; ahora compara el original;
- el foco del pellizco con `localPosition` derivaba 3.7 dp en el segundo paso (sección 4, punto 3).

## 6. La Web y la página entera (P7)

- **No toqué `web/index.html`.** La prueba de si el pellizco o Ctrl + rueda amplían la página entera
  es de Carlos, con su touchpad, en Chrome y en Edge (sección 7, Web, pasos 5 y 6).
- **Lo que dice el código del motor web de Flutter 3.38.9** (`pointer_binding.dart`; es una lectura,
  no una medida): la rueda con Ctrl llega a Flutter como `PointerScaleEvent` con escala
  e^(−deltaY/200), y el motor llama a `preventDefault()` en toda rueda que no le devuelve el
  permiso el marco, y las de escala no lo piden nunca. Si eso se cumple en el navegador, la página
  no se amplía en ninguna parte de la app, tampoco hoy, y P7 no hace falta.
- **Si la página se amplía sobre el plano,** Carlos me lo dice y hago lo de P7: en `web/index.html`,
  un escucha no pasivo que cancela Ctrl + rueda solo con el puntero sobre el plano.

## 7. Para Carlos: la prueba con su mouse y su touchpad (unos 10 + 10 minutos)

Con un almacén aparte en `%TEMP%` (`tool/t100_main.dart`, namespace `t100`, sin Firebase) y el plano
sintético `T100_LLEGADA` (`tool/t100_sintetico.dart`). Nada toca el almacén real ni el corpus. Un
comando de Flutter a la vez.

**Preparar, una sola vez** (PowerShell, en la carpeta del rediseño):

```powershell
dart tool/t100_sintetico.dart "$env:TEMP\t119-manual\plano"
```

**Windows** (unos 10 min):

```powershell
flutter build windows --release -t tool/t100_main.dart --dart-define=T100_WINDOWS_STORE="$env:TEMP\t119-manual\almacen"
Start-Process explorer.exe -ArgumentList "C:\Proyectos\baystream-rediseno\build\windows\x64\runner\Release\baystream.exe"
```

Abrir `T100_LLEGADA.edi` de `%TEMP%\t119-manual\plano`, elegir GTSTC en «Puerto de esta escala»
(el previo propone el puerto de salida), publicarlo y entrar al Plano. Con la ventana a media pantalla (Win + ←), para que la silueta no quepa:

1. **Rueda sobre la silueta:** hacia abajo avanza a la popa, hacia arriba regresa. En la popa, la
   rueda hacia abajo baja la página.
2. **El pestillo:** con la rueda sobre la rejilla, bajar la página hasta que la silueta quede bajo el
   mouse y seguir: la página sigue bajando. Parar un momento y girar sobre la silueta: se mueve ella.
3. **Ctrl + rueda con el mouse sobre una celda:** acerca y aleja, y la celda se queda bajo el
   puntero; el chip dice el porcentaje, entre 75 y 300 %. La página no se desplaza.
4. **Pellizco del touchpad sobre una celda:** acerca y aleja; mientras se pellizca nada se
   desplaza; la celda se queda bajo los dedos.
5. **Dos dedos sin pellizcar:** sube y baja la página, y a los lados la rejilla.
6. **La barra:** con el zoom a 200 % aparece abajo, encima de la franja de cifras, sin tapar celdas.
   Arrastrar el pulgar; clic en la pista a la derecha del pulgar: avanza una página. Al 100 % y con
   la ventana maximizada, si la bahía cabe, la barra no está.

**Chrome y Edge** (unos 10 min):

```powershell
flutter build web --release --no-web-resources-cdn -t tool/t100_main.dart -o C:\Proyectos\baystream-rediseno\build\t119\web
python -m http.server 5919 --bind 127.0.0.1 --directory build\t119\web
```

Abrir `http://127.0.0.1:5919` en Chrome y después en Edge (una ventana visible, no minimizada), con
el mismo archivo y la ventana a media pantalla. Los pasos 1 a 6 de Windows, y además:

7. **P7, la página entera:** Ctrl + rueda y el pellizco **sobre el plano** amplían el plano y **no**
   la página (el zoom del navegador, a la derecha de la barra de direcciones, sigue en 100 %).
8. **Lo mismo fuera del plano** (la cabecera, el panel lateral): anotar qué pasa. Si el navegador
   amplía la página en algún lado, decirme dónde.
9. **Ctrl + «+» y Ctrl + «−»** siguen ampliando la página del navegador.

Lo que se anota: cliente, paso, «pasa» o «no pasa» y, si no pasa, qué se vio. Al terminar, cerrar la
app y el servidor (Ctrl + C); `%TEMP%\t119-manual` y `build\t119\web` se pueden borrar.

## 8. Validaciones y cifras

- **Las pruebas nuevas:** 11 de 11 en verde (`flutter test test/t119_mouse_touchpad_test.dart`).
- **Contra el código de antes:** 11 de 11 fallan, cada una en su comprobación.
- **La suite, en una sola corrida:** 1852 pruebas (las 1841 del piso y las 11 nuevas), **1851 en
  verde, 1 fallida y ninguna omitida** (`build/t119/suite.txt`).
- **La fallida no es de T-119:** `test/t93_msix_config_test.dart` («identifica la app con el sujeto
  del certificado») espera `msix_version` `3.2.0.0`, y `pubspec.yaml` dice `0.4.0.0` desde 10.74
  (`7647741` cambió el pubspec y no la prueba). Falla igual en la copia con el código de `HEAD`
  (`build/t119/t93-en-HEAD.txt`). No la toqué: ni la prueba ni el pubspec son de esta tarea. El
  arreglo es una línea en la prueba (`'3.2.0.0'` → `'0.4.0.0'`), y la candidata de la 0.4.1 la
  tendrá que llevar a `0.4.1.0`. Lo decide Carlos.
- **`analyze`** en `lib/`, `test/` e `integration_test/`: **cero** (`build/t119/analyze.txt`). O-126-1
  de `tool/` sigue anotado y no es de esta tarea.
- `pubspec.yaml` y `pubspec.lock` **no cambian**. Tampoco `domain/`, `data/`, `lib/main.dart`, las
  opciones de Firebase, `web/index.html` ni los congelados.

## 9. Archivos

**Cambiados:**
- `lib/core/design/bs_movimiento.dart`: `BsMovimiento.rueda`.
- `lib/core/design/design.dart`: exporta `bs_rueda_horizontal.dart`.
- `lib/core/design/componentes/bs_silueta_buque.dart`: el desplazable dentro de `BsRuedaHorizontal`.
- `lib/features/vessel/presentation/providers/plano_providers.dart`: `pellizcoDelPlanoProvider`.
- `lib/features/vessel/presentation/widgets/plan_drag_confirmation.dart`: `PlanZoomViewport` con el
  touchpad, Ctrl + rueda, el punto fijo y el desplazamiento horizontal por fuera;
  `PlanZoomContenido`; `_TamanoAmpliado`.
- `lib/features/vessel/presentation/widgets/bay_plan_view.dart`: la columna con la barra, el
  pestillo y la física del pellizco; la rejilla de la oficina sin su desplazamiento horizontal.
- `DESIGN.md`: la sección 16 y una línea en el estado de arriba.

**Nuevos:**
- `lib/core/design/componentes/bs_rueda_horizontal.dart`
- `lib/features/vessel/presentation/widgets/barra_de_la_rejilla.dart`
- `test/t119_mouse_touchpad_test.dart`
- `docs/T119-RESULTADOS.md` (este informe)

**Evidencia** (fuera de Git, en `build/t119/`): `pruebas-nuevas-contra-HEAD.txt`, `suite.txt`,
`t93-en-HEAD.txt` y `analyze.txt`. La copia de `%TEMP%\t119-antes` se borró al terminar.

## 10. Lo que no se hizo y queda anotado

- **La prueba con mouse y touchpad de verdad** (sección 7) y **P7** (sección 6): son de Carlos.
- **O-040-1**, el gesto del touchpad que regresa el navegador sobre la silueta: para después (10.76).
- **T-120, H2 (T-127), O1 y O2 de la entrega 1, el arrastre entre dos monitores y la versión:** fuera
  de esta tarea; `pubspec.*` no cambia.
- **El punto fijo con el chip:** el chip sigue ampliando desde la esquina, como antes. Con la rueda y
  el touchpad el punto queda quieto; con el chip no hay puntero.
- **En el teléfono** (ventanas de menos de 600 dp), Ctrl + rueda y el touchpad amplían desde la
  esquina, sin punto fijo ni barra: el teléfono lleva los dos desplazamientos dentro del zoom.

## 11. Git

Para que lo ejecute Carlos. Fuera quedan los cuatro archivos que solo cambian el fin de línea
(`test/t114_fase3_correccion_test.dart` y tres de `windows/flutter/`) y `docs/t117/entrega1/`.
`pubspec.yaml` y `pubspec.lock` no cambian.

```powershell
git add -- DESIGN.md
git add -- lib/core/design/bs_movimiento.dart
git add -- lib/core/design/design.dart
git add -- lib/core/design/componentes/bs_rueda_horizontal.dart
git add -- lib/core/design/componentes/bs_silueta_buque.dart
git add -- lib/features/vessel/presentation/providers/plano_providers.dart
git add -- lib/features/vessel/presentation/widgets/barra_de_la_rejilla.dart
git add -- lib/features/vessel/presentation/widgets/bay_plan_view.dart
git add -- lib/features/vessel/presentation/widgets/plan_drag_confirmation.dart
git add -- test/t119_mouse_touchpad_test.dart
git add -- docs/T119-RESULTADOS.md
git commit -m "Sprint 4: T-119, el mouse y el touchpad (10.76): la rueda en la silueta con su pestillo, el zoom con el pellizco del touchpad y Ctrl + rueda con el punto bajo el puntero quieto, y la barra horizontal de la rejilla"
git push
```

## 12. Mensaje para Yov

> Yov, T-119 está hecha (`docs/T119-RESULTADOS.md`, `DESIGN.md` 16). La rueda mueve la silueta, con
> el pestillo de 300 ms; el pellizco del touchpad y Ctrl + rueda amplían entre 75 y 300 % con el
> punto bajo el puntero quieto; y la rejilla tiene su barra horizontal abajo de la columna, solo
> cuando la bahía no cabe. Son 11 pruebas nuevas que fallan las 11 contra `HEAD` (en una copia) y
> pasan con el cambio. La suite da 1852 en una corrida, 1851 en verde y una fallida que no es de
> T-119: `t93_msix_config_test.dart` espera el MSIX 3.2.0.0 y el pubspec dice 0.4.0.0 desde 10.74;
> falla igual en `HEAD`. `analyze` en cero. No toqué `web/index.html`: leyendo el motor web de
> Flutter 3.38, Ctrl + rueda llega como escala y el motor cancela el evento del navegador, pero
> eso lo confirma Carlos en Chrome y Edge con la lista de la sección 7. Los cambios respecto de
> 0.7.2 están en la sección 4; el bloque de Git tiene 11 rutas y no cambia el pubspec.

## 13. El arreglo de la prueba de T-93 (10.77, 29-oct)

Sobre `83d7b85` (10.77), en un commit aparte del de T-119, con la luz verde de Carlos.

- **El arreglo:** en `test/t93_msix_config_test.dart`, «identifica la app con el sujeto del
  certificado» ya no fija `'3.2.0.0'`. Lee la línea `version: x.y.z+n` del pubspec y comprueba que
  `msix_version` sea `x.y.z.0`; si falta esa línea, falla diciéndolo. Hoy da `0.4.0.0`, y la
  candidata de la 0.4.1 (`0.4.1+7` y `0.4.1.0`) ya no la rompe. Las demás comprobaciones del archivo
  no cambian. Solo cambia ese archivo; `pubspec.*` no cambia.
- **Cifras:**
  - el archivo, 5 de 5 (`build/t119/t93-arreglada.txt`);
  - la suite, en una sola corrida, **1852 de 1852, sin omitidas** («All tests passed!»,
    `build/t119/suite-10.77.txt`);
  - `analyze` en `lib/`, `test/` e `integration_test/`: **cero** (`build/t119/analyze-10.77.txt`).
- **Git:** si Carlos sube primero el bloque de T-119 (sección 11), este bloque solo agrega la prueba y
  esta sección del informe. Si lo sube después, el informe de T-119 ya llevaría esta sección.

```powershell
git add -- test/t93_msix_config_test.dart
git add -- docs/T119-RESULTADOS.md
git commit -m "Sprint 4: la prueba de T-93 sigue a la version del pubspec (10.77)"
git push
```

ALTO: Yov revisa.
