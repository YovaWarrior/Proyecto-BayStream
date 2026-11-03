# T-131 · El distintivo de rol en la cabecera · Resultados

- **Quién:** Timonel (Claude Code, Claude Opus 5.5).
- **Dónde:** `C:\Proyectos\baystream-t131`, rama `t131-distintivo`, sobre `733a8ab`.
- **Cuándo:** del 2-nov a las 23:00 al 3-nov a la 01:00, con dos esperas de luz verde.
- **Encargo:** decisión 10.86 de `SPRINT-4.md` (la variante B, «Filo de metal») y 10.90 (el
  ícono `oficina`, el paquete v3 y el orden nuevo). El diseño queda en `DESIGN.md` 13.12.

## 1. En corto

El rol de la cuenta se ve en la cabecera como un distintivo con el metal de la presentación del
7-nov: cobre para el muelle y oro para la oficina, solo en el filo y en el ícono. Va en la banda del
muelle, a la izquierda de Descarga / Carga, y a la derecha del título del viaje, que cubre la barra
superior del teléfono y la cabecera de la oficina. Los permisos no cambian. El ícono `oficina` del
paquete v3 de Nube entra en U+E023 sin mover los 35 glifos de antes. Tocarlo abre «Nube y cuenta».

**Cifras:** la suite, **2012 de 2012** en una corrida, sin omitidas (el piso era
1912); 100 pruebas nuevas; `analyze`, **cero**, sin `// ignore:`; el contraste, 0 pares que no
cumplen. `pubspec.lock` no cambia, y en `pubspec.yaml` cambia solo el comentario del rango.

## 2. Paso 0

- **La punta:** `733a8ab`. Trae T-129 (`2d98f23`), la mezcla de T-132 (`7cb96ec`, con `88eb2e1`) y
  la 10.90 (`fb8be28`): los cuatro son ancestros de la punta (`git merge-base --is-ancestor`).
- **El paquete v3** (`C:\Proyectos\baystream-iconos-paquete-v3.zip`, 86 archivos):
  - las 85 huellas de su tabla «Archivos» coinciden (el LEEME no lleva la suya, como dice él
    mismo);
  - los 73 que «Frente al v2» da por iguales coinciden con los blobs de `HEAD` (73 de 73) y con el
    disco: los textos del árbol tienen CRLF (`core.autocrlf=true`) y, sin los CR, dan la misma
    huella; los dos PNG, directos.
- **`flutter pub get`:** no cambió nada (`git diff --stat` vacío).
- **`flutter analyze`, la línea base:** **3 errores**, todos en `tool/t124_main.dart`. Importa
  `build/t124/entradas/t124_entradas.dart`, que se genera fuera de Git y que esta carpeta nueva no
  tenía; a T-132 le pasó lo mismo en su carpeta (`docs/T132-RESULTADOS.md`, sección 3).
  - **Carlos decidió (3-nov)** copiarlo de `baystream-t132`, que lo regeneró con los generadores
    sintéticos: misma huella en las dos carpetas (`bfb37418…be852`), ignorado por `.gitignore`
    (`/build/`) y fuera del bloque de Git.
  - Con eso, `analyze` da **«No issues found!»** (`build/t131/01-analyze-linea-base.log`), antes de
    tocar nada.

## 3. Lo hecho

### 3.1 El ícono `oficina` (paquete v3)

- Se copiaron los **13** archivos que el LEEME da por cambiados o nuevos, tal cual vienen en el
  paquete:
  - la fuente `assets/fonts/bs_iconos/BayStreamIconos.ttf` (1.2);
  - `design/iconos/`: `codigos.json`, `svg/oficina.svg` (nuevo), `vista-previa.png`,
    `comprobacion-fuente.png`, `comprobacion-skia.md`, `comprobacion-skia.png` y el `LEEME.md`;
  - los cinco cambios del generador: `generar.py`, `fuentes/iconos.py`, `fuentes/fuente.py`,
    `fuentes/comprobar_skia.py` y `fuentes/LEEME.plantilla.md`.
- Las 12 con huella quedaron con la del LEEME, y el LEEME es idéntico al del paquete.
- `BsIconos.oficina` (`0xE023`) va tal como lo trae el LEEME. Se suma al catálogo
  (`BsIconosCatalogo.iconos`, ahora 32 íconos y 36 glifos) y, por el catálogo, a la vista previa de
  íconos.
- `pubspec.yaml`: solo el comentario del rango, que pasa a «U+E000 a U+E023».

### 3.2 Los colores

En `BsPaleta`, dos campos nuevos de tipo `BsMetalDeRol`, `metalMuelle` (el cobre) y
`metalOficina` (el oro). Son el mismo objeto en claro y en oscuro, con los valores de 10.86:

| | Muelle | Oficina |
|---|---|---|
| Fondo, de arriba abajo | `#0B3E93` → `#082F70` | `#16305C` → `#0E2244` |
| Filo, a 135° | `#F8D2B6` → `#E0895A` (55 %) → `#9E5530` | `#FFF0C4` → `#F2C46D` (55 %) → `#A87A2C` |
| Ícono | `#F4B48E` | `#F2C46D` |
| Rótulo | `#FFFFFF` | `#F4F6FB` |
| Brillo y sombra (del lienzo) | blanco al 18 %; `#07111F` al 35 % | blanco al 14 %; negro al 40 % |

`tool/rediseno_contraste.py` lleva los mismos valores (`METALES`) y una sección nueva al final de su
reporte. Una prueba comprueba que el script y `BsPaleta` coinciden.

### 3.3 La pieza `BsDistintivoDeRol`

En `lib/core/design/componentes/bs_distintivo_de_rol.dart`:
`BsDistintivoDeRol({required BsEquipo equipo, bool compacto = false, VoidCallback? onTap})`. No lee
providers.

- **La píldora:** del alto visible de `alturaChip` (40 y 32), con una zona táctil de 48 dp que
  ocupa su sitio y lleva al centro de la píldora los toques del margen, como los chips de Material
  (`_ZonaTactil`).
- **El metal:** un `CustomPainter` dentro de un `RepaintBoundary` pinta el relleno de arriba abajo,
  el filo de 1.5 dp a 135° como el `linear-gradient(135deg)` del lienzo, el brillo de 1 dp arriba
  por dentro y la sombra leve.
- **El brillo sale limpio.** A 3×, en una columna del borde de arriba: el filo (4.5 px), una banda
  de 3 px más clara (`#3761A6` sobre `#0B3D91` en el muelle; `#374D73` sobre `#152F5A` en la
  oficina) y el fondo. No se omitió.
- **El ícono y el rótulo:** el ícono del paquete a 20 dp en el muelle y a 18 en la oficina; el
  rótulo en IBM Plex Sans Condensed 600, con el tamaño de `labelLarge`. Con la letra a 2.0 la
  píldora crece en alto y el rótulo no se corta.
- **La compacta:** el círculo de `alturaChip` con el ícono.
- **Sin animación:** en reposo no hay cuadros ni tickers. El toque, el foco y el mouse se marcan
  con el rótulo al 16 % y al 8 %, sin la onda.
- **La semántica:** un botón con «Rol: Muelle» o «Rol: Oficina» y la pista «Abre Nube y cuenta».
  La descripción emergente dice el rol y queda fuera de la semántica, como la de «Acciones»
  (14.8). Igual en la compacta.
- **Las vistas previas**, en `vistas_previas.dart`: `vistaPreviaDistintivoDeRol` (el día, con la
  banda), `…Oscuro` (la noche) y `…Oficina` (la densidad de la oficina, de noche).

### 3.4 Dónde va

- **El rol:** sale de `rolDelDistintivoProvider`, en `sync_providers.dart`, junto a
  `movementAuthorProvider`. Sigue a `operatorProvider`:
  - con una cuenta autorizada, también la de la copia local, da su rol;
  - sin cuenta o sin autorizar, nada.
  - Va en ese archivo, que la página ya importaba, para no tocar los `import` de
    `vessel_overview_page.dart`.
- **La banda del muelle:** `BsBandaMuelle` recibe `distintivo` (`Widget Function(bool compacto)`)
  y lo pone en la segunda fila, a la izquierda de los segmentos y centrado con ellos.
- **El título del viaje:** `_TituloDelViaje` lo pone a la derecha del bloque nombre + viaje,
  centrado en su alto.
  - **Carlos lo decidió el 2-nov**, en lugar de la línea del nombre. Ahí, la zona de 48 llevaba el
    título de 38 a 65 dp, que la barra de 56 recorta, y la cabecera de la oficina crecía de 64 a
    81 dp.
  - Así va en la barra superior del teléfono y en la cabecera de la oficina, en Windows y en la
    Web.
- **`vessel_overview_page.dart`:** cambian solo `_TituloDelViaje`, `_CabeceraDeOficina` y
  `_BandaDelMuelle` (todos los trozos del diff están entre sus líneas). Sin cuenta, la cabecera
  queda como antes: la prueba compara el alto con y sin cuenta en las cuatro cabeceras.

### 3.5 Cómo cabe

Se mide con `BsPrimeraQueCabe`. En la banda y en la cabecera de la oficina **los controles mandan
y el distintivo cede primero**; ninguna de las dos crece por él (Yov y Carlos, 3-nov):
- **En la barra superior del teléfono:** completo; si no cabe, compacto; y solo después el nombre
  se encoge. La barra mide 56 con o sin distintivo.
- **En la cabecera de la oficina:** la misma que sin cuenta, con la misma forma del selector, las
  mismas líneas y el mismo alto.
  - El selector conserva sus segmentos mientras quepan sin el distintivo. Para cada forma (los
    segmentos y, después, el menú), en una línea: con el completo, con el compacto y sin
    distintivo.
  - En dos líneas, el título va solo en la suya, y el distintivo va solo si no la hace más alta
    (cuando el bloque del título mide 48 dp o más; con la letra a 1.0 mide 38).
  - **Lo decidió Carlos el 3-nov: el alto manda.** El nombre no se encoge para hacerle sitio: la
    regla elegida lo permite solo si el alto no cambia, y en la cabecera eso no se da. En una
    línea, el nombre no se encoge hoy; en dos, el bloque marca el alto cuando el distintivo puede
    ir, y encogerlo lo bajaría (a 1366 con 2.0, de 92 a unos 86 dp).
  - **Esto reemplaza la versión anterior** («menú + completo» antes que «segmentos + compacto», y
    dos líneas si nada cabía), que con la letra a 2.0 llevaba la cabecera de 1366 de 92 a 144 dp.
- **En la banda:**
  - completo solo si Descarga y Carga conservan su rótulo y su ícono enteros; si no, compacto;
  - **si ni así, sin distintivo**, con la banda como antes. **Carlos lo decidió el 3-nov:** a
    360 dp con la letra a 2.0, el compacto partía «Descarga» en dos renglones (104 dp de ancho
    para 119.5) y la banda crecía de 164 a 184 dp.

Lo que sale con el buque sintético (BUQUE MANUAL) está en la tabla de `DESIGN.md` 13.12:

| Dónde y tamaño | Letra 1.0 | Letra 2.0 |
|---|---|---|
| La banda, a 360 | compacto | sin distintivo |
| La barra del muelle, a 360 | completo | compacto |
| La barra de la oficina, a 360 | compacto | compacto |
| La barra de la oficina, a 390 | completo | compacto |
| La cabecera, a 600 | sin distintivo (dos líneas; el título mide 38 dp) | sin distintivo (no cabe junto al título) |
| La cabecera, a 800 y a 1280 | completo | completo |
| La cabecera, a 1366 | completo (una línea, selector en menú, como sin cuenta) | sin distintivo (92 dp, una línea) |
| La cabecera, a 1920 | completo | compacto |

En la cabecera, cada alto es el de sin cuenta: 106, 177, 64, 144, 64, 92, 64 y 92 dp.

En la banda de 360 con la letra a 1.0 va **compacto**: con Descarga y Carga, el completo no deja
los segmentos enteros.

### 3.6 `DESIGN.md`

- **La sección 13.12 nueva:**
  - la pieza;
  - los colores y de dónde salen (la presentación del 7-nov);
  - la regla del metal (solo en el filo y en el ícono, nunca de relleno; la única excepción a la
    escala de un solo tono y a «sin degradados», por decisión de Carlos del 1-nov);
  - el contraste;
  - dónde va y la regla para caber, con lo que sale medido.
- **En 13.11:** el v3 y `oficina`, y la fila «Rol de la cuenta» con `muelle` y `oficina`. `muelle`
  sale de «Sin sitio todavía».
- **En 13.6:** la API de `BsBandaMuelle`, con `distintivo`.

## 4. Las validaciones

| Qué | Resultado | Registro |
|---|---|---|
| `analyze`, línea base | 3 errores (la entrada de T-124 ausente) → 0 tras copiarla | `build/t131/01-analyze-linea-base.log` |
| La pieza, el contraste, la fuente y las dos de T-114 | 57 de 57 | `build/t131/02-pruebas-pieza.log` |
| La pieza y las cabeceras, con la regla de la cabecera de Yov | 89 de 89 (37 + 52) | `build/t131/03-pruebas-cabeceras.log` |
| Las capturas | 11 de 11 | `build/t131/04-capturas.log` |
| **La suite completa** | **2012 de 2012, sin omitidas** | `build/t131/05-suite.log` |
| **`analyze` final** | **No issues found!** | `build/t131/06-analyze-final.log` |
| `tool/rediseno_contraste.py` | 0 pares que no cumplen; el reporte solo suma las 13 líneas del distintivo | `docs/rediseno/fase2bis/contraste.md` |

Antes de la revisión de Yov, la suite dio 2007 de 2008 en una primera corrida y 2008 de 2008 en
la segunda. Falló `t114_fundacion_test` («`tool/rediseno_contraste.py` lleva las mismas
tablas»): al insertar la función del distintivo se perdió el espacio de `TABLA_TIPOS = [`, y la
prueba lee el script como texto. Se repuso; la línea quedó idéntica a la de antes.

**Las pruebas nuevas (100):**
- **`test/t131_distintivo_test.dart` (37):**
  - la pieza: el alto, la zona de 48, el ícono, el rótulo, la compacta, la letra a 2.0, la
    semántica y la descripción emergente, el toque en el margen, sin animación y el metal pintado;
  - las cuatro pautas (`androidTapTargetGuideline`, `iOSTapTargetGuideline`,
    `labeledTapTargetGuideline` y `textContrastGuideline`) en claro y en oscuro, con las dos
    densidades, sobre el papel y sobre la banda;
  - el contraste compuesto desde `BsPaleta`;
  - el script con los mismos colores;
  - las tres vistas previas;
  - la fuente: los 35 códigos del v2 siguen igual, los 35 SVG tienen la huella de «Frente al v2»,
    y los 36 glifos pintados como texto coinciden con su SVG a 16 y a 24 px.
- **`test/t131_cabeceras_test.dart` (52):**
  - la cabecera de la oficina a 600 y a 1366, con la letra a 1.0 y a 2.0, es la misma que sin
    distintivo con cualquiera de las dos cuentas: el alto, las líneas y la forma del selector. A
    1366 con 2.0: 92 dp, en una línea;
  - el rol en las cuatro cabeceras: oficina, muelle, sin autorizar, la copia local y sin cuenta,
    cambiando sin reiniciar y con el alto de antes sin distintivo;
  - tocarlo, completo y compacto, abre «Nube y cuenta»;
  - la forma que cabe, comprobada con los anchos medidos en cada `BsPrimeraQueCabe`;
  - la matriz sin desbordes: 360 × 640, 360 × 800, 600 y 1366 de ancho, con la letra a 1.0 y a
    2.0 y las dos cuentas. El distintivo queda dentro de la pantalla y de su cabecera, sin que la
    barra de 56 lo recorte;
  - las pautas en las cabeceras.
- **`test/t131_capturas_test.dart` (11):** las capturas de la sección 5.

**Las dos pruebas de T-114 puestas al día (no se debilitaron):**
- `t114_iconos_test`: 36 glifos de U+E000 a U+E023 y la huella del TTF v3
  (`c2d8ed7b…f3e61c`, la de la tabla «Archivos» del LEEME).
- `t114_paquete_test`: `muelle` y `oficina` pasan de «sin sitio» a «con sitio», y el censo cuenta
  36.

**La fuente, contra los SVG:** lo peor a 16 px es `segregacion` (16 de 256 píxeles, 6.3 %), y a
24 px, `buque` (63 de 576, 10.9 %, lo mismo que midió T-114). `oficina` da 2 de 256 y 45 de 576.
El tope es el de `t114_iconos_test`: 12 % y un Δ medio de 16.

**El contraste** (la tabla completa, en `DESIGN.md` 13.12):
- el rótulo, a 9.88:1 en el muelle y 12.05:1 en la oficina; el ícono, a 5.54 y 8.00;
- contra cada fondo, compuesto también con la sombra encima: de día cumple el relleno (4.09 y
  4.34); de noche, el filo (13.42 · 7.12 y 16.69 · 11.63);
- sobre la banda, el filo en su claro y su 55 % (6.12 · 3.25 y 7.61 · 5.30). Su extremo oscuro
  (1.56 y 2.25) se informa sin exigirlo, como decidió Carlos el 2-nov.

## 5. La evidencia (`build/t131/`)

**Se queda en el disco y no va al repositorio** (sección 8). Todo con datos sintéticos (BUQUE
MANUAL, TSTU, cuentas sintéticas cuyo nombre no se ve). Ninguna captura muestra «Nube y cuenta», un
correo ni un UID. Salen de la app en pruebas de widgets con las fuentes reales, no del emulador ni
del proyecto real; el Honor no se usó. Se regeneran con:

```powershell
flutter test test/t131_capturas_test.dart --dart-define=T131_CAPTURAS=build/t131
```

| Archivo | Qué |
|---|---|
| `muelle-360x800-claro.png`, `…-oscuro.png` | la banda del muelle, con la cuenta del muelle: el compacto a la izquierda de Descarga / Carga |
| `oficina-telefono-390x844-claro.png`, `…-oscuro.png` | la barra superior de la oficina en un teléfono: el completo a la derecha del título |
| `oficina-1366x768-claro.png`, `…-oscuro.png` | la cabecera de la oficina: el completo, en una línea de 64 dp, con el selector en menú como sin cuenta |
| `oficina-1366x768-letra2-claro.png` | la misma con la letra a 2.0: sin distintivo, en una línea de 92 dp, como sin cuenta (lo pidió Yov) |
| `distintivos-muelle-claro.png`, `…-oscuro.png`, `distintivos-oficina-claro.png`, `…-oscuro.png` | las vistas previas a 3×: los cuatro distintivos y, en el muelle, la banda a 420 dp con el completo |
| `capturas.sha256` | las huellas de las once |
| `01` a `06` `.log` | analyze, las pruebas, las capturas y la suite |

## 6. Lo que no se pudo, y lo que conviene saber

1. **Las pautas de toque en la pantalla entera del teléfono no pasan, por algo anterior a T-131.**
   - La línea del resumen del plano («Bahía 02, carga: nada pendiente / Ver el resumen completo»)
     es un botón de 336 × 21 dp. En la cabecera de la oficina, las cuatro pautas pasan en la
     pantalla entera.
   - En el teléfono, la prueba mide la de toque y la de etiqueta en la cabecera.
   - El contraste se mide en la pantalla entera. De día, en la oficina del teléfono, solo falla el
     peso por pila «110.0+?» de la rejilla (11 px en tinta suave, 4.33:1), y falla igual sin
     cuenta.
   - **Para después del 7-nov:** las dos, sin tocar en T-131 (punto 8).
2. **En la cabecera de la oficina el distintivo puede no ir.** Con la regla nueva, la cabecera
   nunca cambia por él, y donde no cabe con los controles, no va (la tabla de 3.5 dice dónde).
3. **En la banda del Honor (360 dp) el distintivo va compacto** con Descarga y Carga, y sin
   distintivo con la letra a 2.0. Es la regla. Con un solo segmento (un plan de carga sin
   descarga) cabe el completo, como en el lienzo.
4. **Las capturas son de pruebas de widgets.** No se corrió el emulador ni se usó el Honor: no había
   autorización para el Honor y el prompt admite las vistas previas.
5. **La entrada de T-124** (`build/t124/entradas/t124_entradas.dart`) se copió de `baystream-t132`
   para la línea base. Está ignorada y no va en el bloque.
6. **`windows/flutter/`:** `pub get` reescribió el fin de línea de tres archivos generados, sin
   cambiar su contenido (no salen en `git diff --stat`). No van en el bloque.
7. **La mezcla con T-130**, dos puntos de contacto:
   - `vessel_overview_page.dart`: solo las tres funciones, lejos de `_askForGeometry` y de la
     línea de `AvisoDelPlan`;
   - `sync_providers.dart`: el provider nuevo va después de `movementAuthorProvider`.
   Si T-130 toca esas mismas líneas, el conflicto es de quedarse con las dos partes.
8. **Las dos observaciones del punto 1** quedan anotadas para después del 7-nov, sin tocar (Yov,
   3-nov).

## 7. Las horas

Unas 3 h de reloj, con esperas de luz verde:
- el paso 0, las lecturas y el diseño, ≈ 0.75 h;
- el código y las pruebas, ≈ 0.75 h;
- los ajustes, las capturas, `DESIGN.md` y el informe, ≈ 0.5 h;
- los dos ajustes de la revisión de Yov (3-nov), ≈ 0.75 h.

## 8. El bloque de Git (lo ejecuta Carlos)

`pubspec.yaml` cambia una línea (el comentario del rango de la fuente); `pubspec.lock` no cambia.
`docs/rediseno/fase2bis/contraste.md` entra porque Carlos autorizó regenerarlo (2-nov).

**`build/t131/` no va.** La evidencia de `build/` se queda en el disco, como en T-129 y T-132, y
uno de los registros de la suite trae una ruta con el usuario de Windows de Carlos, que no va a un
repositorio público. Las capturas se regeneran con `test/t131_capturas_test.dart` (sección 5).
Tampoco van `build/t124/` ni `windows/flutter/`.

```powershell
Set-Location C:\Proyectos\baystream-t131
git add -- assets/fonts/bs_iconos/BayStreamIconos.ttf
git add -- design/iconos/LEEME.md
git add -- design/iconos/codigos.json
git add -- design/iconos/comprobacion-fuente.png
git add -- design/iconos/comprobacion-skia.md
git add -- design/iconos/comprobacion-skia.png
git add -- design/iconos/fuentes/LEEME.plantilla.md
git add -- design/iconos/fuentes/comprobar_skia.py
git add -- design/iconos/fuentes/fuente.py
git add -- design/iconos/fuentes/iconos.py
git add -- design/iconos/generar.py
git add -- design/iconos/svg/oficina.svg
git add -- design/iconos/vista-previa.png
git add -- lib/core/design/bs_iconos.dart
git add -- lib/core/design/bs_iconos_catalogo.dart
git add -- lib/core/design/bs_paleta.dart
git add -- lib/core/design/componentes/bs_banda_muelle.dart
git add -- lib/core/design/componentes/bs_distintivo_de_rol.dart
git add -- lib/core/design/design.dart
git add -- lib/core/design/vistas_previas.dart
git add -- lib/core/design/vistas_previas_iconos.dart
git add -- lib/features/vessel/presentation/pages/vessel_overview_page.dart
git add -- lib/features/vessel/presentation/providers/sync_providers.dart
git add -- pubspec.yaml
git add -- test/support/t131_cabeceras_support.dart
git add -- test/t114_iconos_test.dart
git add -- test/t114_paquete_test.dart
git add -- test/t131_cabeceras_test.dart
git add -- test/t131_capturas_test.dart
git add -- test/t131_distintivo_test.dart
git add -- tool/rediseno_contraste.py
git add -- DESIGN.md
git add -- docs/rediseno/fase2bis/contraste.md
git add -- docs/T131-RESULTADOS.md
git commit -m "Sprint 4: T-131, el distintivo de rol en la cabecera"
git push -u origin t131-distintivo
```

## 9. En tres líneas

1. El rol de la cuenta se ve en la cabecera: el distintivo «Filo de metal» (cobre para el muelle,
   oro para la oficina) va en la banda del muelle y a la derecha del título del viaje, y abre
   «Nube y cuenta».
2. Entra el paquete v3 de Nube con el ícono `oficina` (U+E023), sin mover los 35 glifos de antes,
   y los metales van en `BsPaleta`, iguales en claro y en oscuro.
3. Va completo si cabe y compacto si no; en la banda, sin distintivo cuando ni el compacto deja
   enteros Descarga y Carga; en la cabecera de la oficina los controles mandan y la cabecera es
   la misma que sin cuenta. Suite 2012 de 2012 y `analyze` en cero.

## 10. Para Yov

> T-131 entregada en `t131-distintivo`, sobre `733a8ab` (informe: `docs/T131-RESULTADOS.md`;
> diseño: `DESIGN.md` 13.12).
> - Va el distintivo B «Filo de metal», con los colores de 10.86 en `BsPaleta`, iguales en los dos
>   temas, y el v3 de Nube: las 85 huellas cuadran, los 73 iguales coinciden con el repo y
>   `oficina` va en U+E023.
> - Cuatro decisiones de Carlos en la tarea:
>   - el distintivo, a la derecha del título y no en la línea del nombre, porque la zona de 48 no
>     cabía en la barra de 56;
>   - en la banda se exige el filo en su tono del 55 %, y el extremo oscuro se informa;
>   - el reporte de contraste, regenerado;
>   - la banda, sin distintivo cuando ni el compacto deja enteros Descarga y Carga (360 dp con la
>     letra a 2.0).
> - Tus dos ajustes, hechos:
>   - En la cabecera de la oficina los controles mandan y el alto manda (Carlos, 3-nov). Es la
>     misma que sin cuenta: el selector, las líneas y el alto. El distintivo va completo,
>     compacto o no va; en dos líneas, solo si no hace más alta la línea del título.
>   - El nombre no se encoge para hacerle sitio: con la letra a 2.0 eso bajaría la cabecera (a
>     1366, de 92 a unos 86 dp).
>   - Queda así: a 1366, completo con la letra a 1.0 y sin distintivo con 2.0 (92 dp, una
>     línea); a 600, sin distintivo; a 800, 1280 y 1920, completo, y compacto a 1920 con 2.0.
>   - `build/t131/` sale del bloque y se queda en el disco.
> - La línea base de `analyze` necesitó la entrada de T-124 copiada de `baystream-t132`.
> - Suite 2012 de 2012 sin omitidas (100 nuevas) y `analyze` en cero.
> - Las dos observaciones anteriores a T-131 (la línea de 21 dp y el «110.0+?» a 4.33:1) quedan
>   para después del 7-nov.
> - Falta: el bloque de Git de Carlos y la aceptación de Codex junto con T-130.
