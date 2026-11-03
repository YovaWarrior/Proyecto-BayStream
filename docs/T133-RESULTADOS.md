# T-133 · La marca no tapa el número de orden · Resultados

- **Quién:** Timonel (Claude Code, Claude Opus 5.5).
- **Dónde:** `C:\Proyectos\baystream-rediseno`, rama `sprint-4`, sobre `725a74e` (la mezcla de T-131).
- **Cuándo:** 3-nov, con tres luces verdes de Carlos: el paso 0, una ventana de trabajo y la suite
  de cierre.
- **Encargo:** el hallazgo 7 de la 10.85 de `SPRINT-4.md` (P2), que la 10.88 abre como T-133. El
  diseño queda en `DESIGN.md` 13.13.

## 1. En corto

Con marca, la celda ya no cambia el código por el rótulo de la marca. El OR (o el destino, o el
tipo) sigue siendo el texto grande, y la marca va debajo, como segunda línea, con su ícono y su
rótulo corto. El relleno y el borde siguen siendo los de la marca, así que la celda salta a la vista
igual que antes. Las 8 reservas de la bahía 10 del piloto ahora dicen «OR 142 · Revisar», no solo
«Revisar». Si no caben las dos líneas, gana el código y la marca queda en su color y en su ícono. La
etiqueta accesible no cambia.

**Cifras:** la suite da **2097 de 2097**, en una corrida y sin omitidas (el piso era 2051); hay **46
pruebas nuevas** (35 en `test/t133_marca_test.dart` y 11 de capturas); `analyze` da **cero**, sin
`// ignore:`. `pubspec.*` no cambia. Solo cambia la capa de presentación: `domain/` y `data/` no se
tocan.

## 2. Paso 0

- **La punta:** `725a74e` («Sprint 4: integra T-131, …»). Trae T-130 (`9dc1c60` es su ancestro,
  `git merge-base --is-ancestor`) y la mezcla de T-131 (`3f67f50`).
- **Sin cambios a medias en `lib/`, `test/` ni `pubspec.*`:** `git diff --numstat` sale vacío. El
  `M` de `test/t114_fase3_correccion_test.dart` en la foto inicial del árbol era solo el fin de
  línea: el contenido es el de `HEAD`. Los tres de `windows/flutter/` son los generados de siempre,
  y no entran.
- **Con la luz verde de Carlos:**
  - `flutter analyze` da «No issues found!»;
  - la suite, **2051 de 2051** («All tests passed!», sin omitidas), es decir, las 1951 de T-130 más
    las 100 de T-131. La mezcla quedó bien;
  - `flutter pub get` no cambió `pubspec.*`.

## 3. Lo hecho

### 3.1 Dos decisiones de Carlos antes de empezar (3-nov)

El encargo chocaba con dos cosas que ya existían. Las presenté con las medidas de la fuente real
(IBM Plex Sans Condensed Medium, el avance de sus glifos), y Carlos eligió las dos recomendadas:

1. **La marca va a 11 en el muelle y a 10 en la oficina.** El encargo pedía «el tamaño de la segunda
   línea» (10), pero `DESIGN.md` 4.2 dice «en el muelle, nada por debajo de 11».
2. **«Cancelado» pasa a «Cancel.»,** como «Re‑est.» (10.28). Con el ícono, «Cancelado» necesita 58 dp
   en la oficina (la celda tiene 50 por dentro) y 62 en el muelle (tiene 52). Antes ya salía cortado,
   «Cancela…», como muestra la captura del antes. «Cancel.» mide 31 dp a 10 y 34 a 11. La etiqueta
   accesible sigue diciendo «cancelado».

### 3.2 `BsCelda` (`lib/core/design/componentes/bs_celda.dart`)

- **El texto grande es siempre `codigo`.** Antes, con marca, era el rótulo de la marca.
- **Debajo va una fila** con el ícono de la marca (`tamanoIconoDeMarca`, que baja de 14 a 12: el
  tamaño de la insignia, la rejilla de 13.11), 2 dp de aire (`separacionDeMarca`) y el rótulo, en
  `celdaLinea2`. El rótulo va a 10, o a `BsEscala.rotuloMinimo` (11) en el muelle, en el color del
  texto del rol, el mismo del código.
- **Qué se dibuja, de mayor a menor:**
  - el ícono y el rótulo, si el código y la línea de la marca caben en el alto interior, si el ícono,
    el aire y el rótulo caben en el ancho interior y si el zoom es de 100 % o más;
  - si no, solo el ícono, mientras quepa debajo del código;
  - si ni el ícono cabe, solo el color.
  El rótulo se mide con un `TextPainter`, igual que lo dibuja `Text`: sobre el estilo heredado, con
  la letra del sistema y en la dirección del texto.
- **No cambian:**
  - el relleno, el borde y el contorno punteado;
  - el estado de la vista Estado, que manda en el relleno, y la salida de la recién movida;
  - la insignia y la etiqueta accesible;
  - la segunda línea sin marca. Con marca, la `linea2` sigue sin dibujarse: su lugar es de la marca.
- **La palomita** de la celda bajada sin marca conserva sus 18 dp, ahora en la constante
  `tamanoPalomita`; antes salían de 14 + `espacioXs`.
- **Lo que se ve a 1.0, en la celda sin ensanchar** (lo comprueban las pruebas, con la fuente
  real):

  | Marca | Oficina (52 × 48, rótulo a 10) | Muelle (56 × 48, rótulo a 11) |
  |---|---|---|
  | «Revisar», «Cancel.», «Hecho», «Paso», «Re‑est.», «Baja», «Sube» | ícono y rótulo | ícono y rótulo |
  | «Bajando» (recién movida) | ícono y rótulo | solo la flecha |
  | «Subiendo» (recién movida) | solo la flecha | solo la flecha |

  A 2.0 no cabe ningún rótulo: queda el código, entero en la celda que la rejilla ensancha, y el
  ícono. A 1.45 caben los dos.

### 3.3 Dónde se ve

`BsCelda` es la única pieza que cambia, así que el cambio llega a todo lo que la usa:
- **Carga** (`LoadingCell`): el conflicto («Revisar») y la cancelación («Cancel.») van debajo del
  OR. La vista de «Colorear por» no cambia esta celda.
- **Descarga** (`BayPlanView`): debajo del destino o del tipo, en las tres vistas, van las marcas
  del muelle («Baja», «Hecho», «Paso», «Re‑est.») y las de la oficina en Destino y Tipo; en la vista
  Estado de la oficina, solo el conflicto, la cancelación y la re‑estiba, como antes.
- **La vista previa nueva,** `vistaPreviaCeldasConMarca` («Celdas · la marca debajo del código»):
  las reservas del caso, un cancelado y una recién movida.

`bay_plan_view.dart` y `loading_controls.dart` no cambian.

### 3.4 Las pruebas que ya existían

Nueve pruebas de cinco archivos buscaban el rótulo de la marca con la fuente cuadrada de las
pruebas, con la que cada letra mide lo que su tamaño. Con la medida nueva, ahí ningún rótulo cabe
junto al código. Se ajustaron así, sin quitar ninguna:
- **`t114_componentes_test.dart` y `t114_piezas_test.dart`,** las pruebas de la pieza: cargan las
  fuentes del producto (`setUpAll(t117CargarFuentes)`, como `t114_fase3_plano_test.dart`) y
  comprueban lo nuevo:
  - el código queda con la marca;
  - a 2.0 queda el código y no el rótulo. La prueba pasa de «el rótulo queda» a «el código
    queda», y además cuenta la insignia y el ícono;
  - la recién movida deja el código y la flecha. En el muelle «Bajando» no cabe, y «Subiendo» no
    cabe en ninguna celda.
- **`t75_discharge_test.dart`, `t106_plan_widget_test.dart` y `t81_office_widget_test.dart`,** las
  pantallas: buscan el ícono de la marca dentro de su celda («Re‑est.», «Baja» y el bloqueo). En
  T-81 se agrega que la celda cancelada conserva su «OR 2». Siguen con la fuente cuadrada, como
  antes.

### 3.5 Las pruebas nuevas

**`test/t133_marca_test.dart`** (35), con las fuentes del producto:
- **La pieza.**
  - En las dos densidades, cada marca va debajo del código, en su tamaño (12 el código; 10 u 11 la
    marca) y con el ícono en la línea del rótulo, sin nada cortado.
  - El relleno, el borde y el color del texto son los del rol de la marca, en claro y en oscuro.
  - Con la letra a 2.0 y con el zoom a 75 %, en las dos densidades y con las siete marcas, queda el
    código entero con el ícono y la insignia.
  - A 1.45, en la celda ensanchada, caben los dos.
  - La etiqueta accesible no cambia, también recién movida, y el código y el rótulo no se leen por
    separado.
  - Con «recién movido», en las dos densidades, quieta y en movimiento: «Bajando», «Subiendo»,
    «Revisar» y «Cancel.», con el código a la vista y el relleno naranja.
  - El contraste compuesto: el código y el rótulo a 4.5:1 y el ícono a 3:1, para las siete marcas,
    sola, sobre la categoría, atenuada y recién movida, sobre el papel, la cubierta y la bodega, en
    claro y en oscuro y en las dos densidades (336 celdas medidas).
  - `meetsGuideline` sobre el muestrario: `textContrastGuideline`, `androidTapTargetGuideline`,
    `iOSTapTargetGuideline` y `labeledTapTargetGuideline`, en los dos temas y las dos densidades.
  - La vista previa se construye de día y de noche.
- **El caso del piloto,** con datos sintéticos (`test/support/t133_marca_support.dart`):
  - Son ocho reservas de 45G1 a PAMIT en la bahía 10: cuatro de CRLY en el nivel 82 y cuatro de ONE
    en el 84. Los vacíos van cruzados (OR 142, 148, 138 y 130 en las de ONE; 67, 62, 63 y 69 en las
    de CRLY), cada uno con su motivo. Quedan llenas, en conflicto `otherGroup` y con su OR.
  - Cada una dice «OR n» y «Revisar», con el ícono, en el muelle y en la oficina, y su etiqueta es
    la de T-107.
  - El cancelado (OR 49) dice «OR 49» y «Cancel.», con el bloqueo, y su etiqueta dice
    «…, cancelado».
  - Recién movida, sigue diciendo su OR y «Revisar», y su etiqueta añade «se acaba de mover».
  - El plano de carga a 360 × 640: con la letra a 1.0, las 8 con su OR y «Revisar»; a 2.0, con su OR
    entero y el ícono. En ninguna se corta nada.
  - Las tres vistas de «Colorear por» en Carga dan la misma celda. En la oficina a 1280 × 720, las 8
    con su OR y «Revisar».
- **La descarga:**
  - en las tres vistas, en el muelle a 360 × 640 y en la oficina a 1280 × 720, el conflicto (un
    contenedor de paso bajado sin re‑estiba) dice su destino, o su tipo en «Tipo de vacío», con
    «Revisar» debajo, y el cancelado dice el suyo con «Cancel.»;
  - a 2.0, el código entero con el ícono.

**`test/t133_capturas_test.dart`** (11) saca las capturas de la sección 5.

### 3.6 `DESIGN.md`

- **13.13, nueva:** el porqué, la regla en seis puntos, los rótulos («Cancel.») con la tabla de lo
  que se ve y las pruebas.
- **Cuatro frases se ajustan a ella:**
  - 4.2: la marca va en el lugar de la segunda línea, a 10 en la oficina y a 11 en el muelle;
  - 4.4: la fila de `BsCelda`;
  - 5.1: el rol cancelado dice «Cancel.»;
  - 13.8: la nota de que `BsCelda` «no dibuja icono y código a la vez», que desde T-133 ya no vale.

## 4. Las validaciones

| Qué | Resultado |
|---|---|
| `flutter analyze`, línea base | «No issues found!» |
| Suite, línea base | 2051 de 2051, sin omitidas |
| `test/t133_marca_test.dart` | 35 de 35 |
| Los archivos tocados y los que dibujan la celda, con T-133 y las capturas (14 archivos) | 263 de 263 |
| `flutter analyze`, al cierre | «No issues found!» (una importación sobrante en la prueba nueva, quitada) |
| Suite, al cierre | 2097 de 2097 |

Los catorce archivos de la penúltima fila son T-75, T-106, T-107, T-81, los siete de T-114 que
tocan la celda (componentes, fase 3 del plano, piezas, contraste de la celda, fase 2 bis,
accesibilidad y paquete), la fundación de T-114 y los dos de T-133.

## 5. La evidencia (`build/t133/`)

Son datos sintéticos (los OR del caso, contenedores `TSTU`, «BUQUE PRUEBA»). Las mismas 11 capturas
están en `antes/` (con el `lib/` de `725a74e`, sacadas antes de tocarlo) y en `despues/`:
- `celdas-{muelle,oficina}-{claro,oscuro}.png`: el muestrario de cerca, a 3×: «Revisar» y
  «Cancelado» sobre un OR, «Baja», «Hecho», «Paso», «Re‑est.», las dos recién movidas y una
  atenuada. En el antes no se ve ningún código y «Cancelado» sale «Cancela…».
- `carga-muelle-360x640.png`, `-oscuro.png` y `-letra2.png`, y `carga-oficina-1280x720.png`: el
  plano de carga de la bahía 10. En el antes, las 8 dicen «Revisar»; en el después, «OR 130
  · Revisar», «OR 148 · Revisar»…
- `descarga-muelle-360x640-{estado,destino,tipo}.png`: la descarga en las tres vistas.

Una salvedad: **`antes/carga-muelle-360x640-letra2.png` no muestra la rejilla.** A 2.0 queda bajo
el pliegue del plano suelto, y la prueba de capturas aprendió a traerla a la vista después de sacar
el antes. El después sí la muestra: «OR 130», «OR 148», «OR 69» y «OR 62», con el ícono debajo. Para
rehacer el antes habría que volver al `lib/` de `725a74e`, que no toco sin Git.

Se regeneran con:

```powershell
flutter test test/t133_capturas_test.dart --dart-define=T133_CAPTURAS=build/t133/despues
```

`build/t133/` no va a Git (10.94).

## 6. Lo que conviene saber

- **«Bajando» en el muelle y «Subiendo» en las dos densidades quedan sin rótulo.** Es la regla 2
  aplicada: no caben junto al ícono en la celda de 56 o de 52. La celda recién movida se reconoce
  por el naranja, por salir de su sitio y por la flecha, y dura 1.5 s. Si Carlos los quiere con
  rótulo, la salida es abreviar, como «Cancel.».
- **A 2.0 la marca va sin rótulo en todas las celdas.** Antes, a 2.0, la celda mostraba el ícono y
  el rótulo, y no el código. Ahora es al revés, que es lo que pide el encargo: el código gana.
- **El costo:** cada celda con marca mide su rótulo con un `TextPainter` en cada `build`, solo en
  la bahía que está a la vista. No medí el tiempo de RNF-002 con este cambio. Si la aceptación ve
  algo, se puede guardar la medida por rótulo, estilo y escala.
- **En el muelle, la vista Estado de la descarga cambia de aspecto:** cada celda por bajar dice
  ahora el destino con «Baja» debajo, en vez de la flecha arriba y «Baja» en grande. Es la misma
  regla, y el encargo la pide para todas las marcas.

## 7. El bloque de Git (lo ejecuta Carlos)

`pubspec.yaml` y `pubspec.lock` no cambian. No van `build/t133/` (10.94), `windows/flutter/` ni
`build/t124/`.

```powershell
Set-Location C:\Proyectos\baystream-rediseno
git add -- lib/core/design/componentes/bs_celda.dart
git add -- lib/core/design/vistas_previas.dart
git add -- test/support/t133_marca_support.dart
git add -- test/t133_marca_test.dart
git add -- test/t133_capturas_test.dart
git add -- test/t114_componentes_test.dart
git add -- test/t114_piezas_test.dart
git add -- test/t75_discharge_test.dart
git add -- test/t106_plan_widget_test.dart
git add -- test/t81_office_widget_test.dart
git add -- DESIGN.md
git add -- docs/T133-RESULTADOS.md
git commit -m "Sprint 4: T-133, la marca no tapa el numero de orden"
git push
```

## 8. En tres líneas

1. Con marca, la celda conserva su código (el OR, el destino o el tipo) como texto grande, y la
   marca va debajo con su ícono y su rótulo: a 10 en la oficina y a 11 en el muelle.
2. Si no caben las dos, gana el código y la marca queda en su color y en su ícono. El relleno, el
   borde y la etiqueta accesible no cambian, y «Cancelado» pasa a «Cancel.».
3. Las 8 reservas de la bahía 10 del piloto dicen ahora «OR n · Revisar», en Carga y en Descarga y
   en las tres vistas. Suite 2097 de 2097 y `analyze` en cero.

## 9. Para Yov

> T-133 entregada en `sprint-4`, sobre `725a74e` (informe: `docs/T133-RESULTADOS.md`; diseño:
> `DESIGN.md` 13.13).
> - Paso 0: T-130 y la mezcla de T-131 están en la punta; la suite dio 2051 de 2051 y `analyze`
>   cero.
> - Con marca, `BsCelda` conserva el código como texto grande y pone la marca debajo, con su ícono y
>   su rótulo. Si no caben, gana el código y la marca queda en su color y en su ícono. El relleno,
>   el borde y la etiqueta accesible no cambian.
> - Dos decisiones de Carlos (3-nov):
>   - la marca va a 11 en el muelle (4.2 no deja bajar de 11) y a 10 en la oficina;
>   - «Cancelado» pasa a «Cancel.»: con el ícono no cabía, y antes ya salía «Cancela…».
> - «Bajando» en el muelle y «Subiendo» en las dos densidades quedan sin rótulo (solo la flecha),
>   por la regla 2.
> - 46 pruebas nuevas, con el caso de las 8 reservas cruzadas CRLY/ONE (sintético). Se ajustaron
>   9 pruebas de cinco archivos que buscaban el rótulo con la fuente cuadrada.
> - Suite 2097 de 2097 y `analyze` en cero. `pubspec.*`, `domain/` y `data/` no cambian.
> - Capturas del antes y del después en `build/t133/`, fuera de Git.
> - Falta: el bloque de Git de Carlos y la aceptación de Codex.
