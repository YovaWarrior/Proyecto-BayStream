# T-114 · Fase 2 · Aceptación de Capitán Codex

**Dictamen: NO PASA.** Fecha: 22-oct-2026, Guatemala.

La suite entregada pasa **1126/1126, sin omitidas**, y `analyze` reproduce solamente
el aviso autorizado de T-100. Sin embargo, la comprobación adicional de la celda
encuentra dos defectos reproducibles: contraste insuficiente al atenuar una celda
habilitada y segunda línea de 10 sp visible en el muelle. Las pruebas entregadas no
detectan esos incumplimientos. No se corrigió código.

Trabajo realizado únicamente en `C:\Proyectos\baystream-qa-r4`, sobre **HEAD
`8c591c8`**; implementación de la Fase 2: `5d9aa84`; base de comparación: `7be3fcb`.
Se leyeron `AGENTS.md`, las decisiones 10.1–10.5 de `SPRINT-4.md`, `DESIGN.md` y
«Fase 2» de `docs/REDISENO-RESULTADOS.md`. Carlos dio luz verde para el resto de la
sesión. Se ejecutó primero `flutter pub get` y un solo comando de Flutter a la vez.
Entorno: Flutter 3.38.9, Dart 3.10.8, Windows. No se abrió la aplicación, no se
inició sesión ni se usaron Firebase, Honor, emulador o los otros dos directorios.

## Comprobación de los diez puntos

Las evidencias locales de esta aceptación están en `build/t114-aceptacion/`.
El informe incorpora los datos esenciales para poder trasladarlo por separado.

| Punto | Qué se hizo | Resultado | Evidencia |
|---|---|---|---|
| 1. Alcance | `git diff --stat=300 7be3fcb..HEAD`; cotejo de las rutas con 2.5; comparación mediante `git show` y lectura de los archivos actuales. | **PASA.** Exactamente 38 archivos: los 37 de 2.5 y `SPRINT-4.md`, sin faltantes ni extras. Los 130 archivos inspeccionados de presentación, dominio, datos, `app.dart`, `main.dart` y los dos congelados coinciden entre base y HEAD, y con la copia actual normalizando EOL. `pubspec.yaml` solo añade `fonts:` y sus comentarios; `pubspec.lock` no cambia, tampoco después de las herramientas. | `alcance-stat-completo.txt`, `independiente.json`, `cierre-integridad.json`. |
| 2. Pruebas y análisis | `flutter test --no-pub --reporter=json`; conteo de resultados visibles, omitidas y fallos; `flutter analyze --no-pub`. | **PASA.** 1126 éxitos, 0 fallos y 0 omitidas, incluidas las 63 pruebas T-114. Único aviso: `tool/t100_sintetico.dart:21:8`, `unused_import` de `dart:convert`; `analyze` sale con 1 por ese aviso, como permite 10.5. | `test.jsonl`, `suite-resumen.json`, `analyze.txt`. Las seis comprobaciones adicionales se informan aparte, sin alterar este conteo. |
| 3. Fuentes | SHA-256 y bytes de las siete TTF y la licencia; descarga de una TTF y de la licencia desde las URL de procedencia; fontTools sobre las siete TTF. | **PASA.** 7/7 TTF exactas. Descargas exactas. OFL 1.1 con `Reserved Font Name "Plex"`. Todas cubren `· ‑ … × •` y todas carecen de `▲ ▼`. Dígitos tabulares: 600 unidades en Sans/Mono, 540 en Condensed. | `independiente.json`, copias `origen-IBMPlexSans-Regular.ttf` y `origen-LICENSE-IBMPlex.txt`; tabla de huellas abajo. |
| 4. Tokens y medidas | Cotejo de paleta y roles con DESIGN 4.1/5.1, lectura de medidas/componentes y comprobación adicional de los estilos 4.2 en claro/oscuro. | **NO PASA por H2.** Los colores, los tamaños/pesos/interlíneas definidos, la celda nominal 56×48 y el objetivo táctil 48 coinciden. Los ejemplos tocables pasan las pautas de tamaño. Pero `BsCelda` muestra su línea de 10 sp también en muelle: falta aplicar la restricción de DESIGN 4.2. | `bs_paleta.dart:86`, `bs_colores_semanticos.dart:71`, `bs_medidas.dart:179`, `bs_tipografia.dart:30`; `diagnostico.txt`. |
| 5. Contraste | `python tool/rediseno_contraste.py` con salida UTF-8; cálculo independiente de tres pares mediante luminancia sRGB. | **PASA los cálculos pedidos.** Script: 0 pares que no cumplen, salida 0. Pares independientes: 14.65:1 claro, 15.51:1 oscuro y 10.59:1 categórico. Esto verifica colores opacos; H1 identifica un defecto al componer alfa en el componente. | `contraste.txt`, `independiente.json`; fórmula y pares abajo. |
| 6. Formatos | Ejecución directa de las funciones reales de `bs_formato.dart` con Dart. | **PASA.** 28 650→28.7 t; 0→0.0 t; 50→0.1 t; 149 999→150.0 t; −28 650→−28.7 t. Contenedor, kilos, porcentaje y singular correctos. | `formatos.dart`, `formatos-dart.json`; tabla abajo. |
| 7. Ranuras | FNV-1a independiente en Python, comparado con el script existente y ejecución directa de Dart. | **PASA.** MXVER→21, PABLB→18 y 22P1→10; coinciden tanto los hashes completos como el módulo 24. | `independiente.json`, `formatos-dart.json`; tabla abajo. |
| 8. Componentes y accesibilidad | Revisión de los ocho componentes, documentación, previas, pruebas y uso de las tres pautas; reproducción adicional del estado atenuado con semántica activada antes del montaje. | **NO PASA por H1.** Existen los ocho componentes, sus comentarios y pruebas. Las previas cubren los ocho; el número se incluye dentro de la hoja de detalle. Hay `meetsGuideline` para las tres pautas en claro/oscuro y muelle. No obstante, el matcher de contraste da paso a una celda habilitada cuyo contraste efectivo queda por debajo de 4.5:1. | `vistas_previas.dart`, `t114_componentes_test.dart`, `t114_accesibilidad_test.dart:8–21`; `diagnostico_test.dart`, `diagnostico.txt`. |
| 9. Web sin conexión | `flutter build web --release --output=build/qa-r4-web`; `dart run tool/t92_verify.dart build/qa-r4-web`; inspección de manifiesto/SW y petición HTTP local de las siete TTF. | **PASA la verificación pedida.** Compilación y verificador con salida 0: 56 archivos, 37 789 537 bytes. 7/7 TTF responden HTTP 200 desde el sitio, idénticas al origen local, con rutas relativas y entradas del service worker. Plex no necesita URL externa. | `build-web.txt`, `t92-verify.txt`, `web-fuentes.json`; `build/qa-r4-web/assets/FontManifest.json`. Alcance: verificación del artefacto y servicio local; no se simuló una sesión de navegador sin red. |
| 10. Auditoría flutter-ui | Script global solicitado con `--all`; comparación por severidad, regla, ruta y línea contra `fase0/flutter-ui-audit-linea-base.txt`, normalizando el prefijo del directorio. | **CON OBSERVACIÓN O1.** Exactamente los mismos 18 críticos y 19 informativos. 74→235 avisos: 161 nuevos, distribuidos en 128 de `bs_colores_semanticos.dart`, 32 de `bs_paleta.dart` y 1 de `bs_movimiento.dart:36`. Por tanto, no están todos en los dos archivos de color. | `flutter-ui-audit.txt`, `independiente.json`; detalle O1. El script sale con 1 por los críticos existentes. |

## H1 · Contraste insuficiente de la celda atenuada habilitada

**Defecto que impide aceptar la fase.** Archivo:
`lib/core/design/componentes/bs_celda.dart:131`; aplicación del alfa:
`lib/core/design/bs_colores_semanticos.dart:28–31`.

`atenuada: true` aplica alfa 0.35 al relleno, al texto y al contorno. No deshabilita
el toque. El texto de 12 sp deja de cumplir el mínimo de 4.5:1 que la entrega exige.
La atenuación aparece además en la vista previa de celdas; es un estado previsto.

Para reproducir, montar esta celda sobre el `Scaffold` del tema, con
`BayStreamTema.claro(muelle: true)` y después `.oscuro(muelle: true)`:

```dart
BsCelda(
  codigo: 'GTSTC',
  etiqueta: 'Contenedor fuera del filtro',
  categoria: BsColoresSemanticos.de(context).categorico('GTSTC'),
  atenuada: true,
  onTap: () {},
)
```

GTSTC usa la ranura 6 mientras la tabla fija está vacía. Composición comprobada con
`Color.alphaBlend`, tomando el color del `Text` construido y el papel del `Scaffold`:

| Tema | Fondo compuesto | Tinta compuesta | Contraste | Exigido |
|---|---|---|---:|---:|
| Claro | `#E4F1F7` | `#9AA9B7` | 2.08:1 | 4.5:1 |
| Oscuro | `#162F40` | `#637581` | 2.89:1 | 4.5:1 |

El mismo caso **pasa** `meetsGuideline(textContrastGuideline)`. La prueba aislada
activa semántica antes de `pumpWidget`. La celda excluye la semántica de sus hijos
en `bs_celda.dart:207` y expone una etiqueta descriptiva distinta de `GTSTC`.
El matcher del SDK local (`C:/flutter/packages/flutter_test/lib/src/accessibility.dart`,
`MinimumTextContrastGuideline._evaluateNode`) busca `find.text()` con la etiqueta del
nodo. En este caso no encuentra el texto visible: el resultado favorable no demuestra
el contraste del código dibujado. Las pruebas entregadas tampoco incluyen el estado
atenuado en sus grupos de contraste.

Corrección propuesta para una tarea posterior: conservar contraste suficiente del
texto al atenuar y cubrir el color realmente compuesto en las pruebas. No retirar la
etiqueta accesible descriptiva para hacer pasar el matcher. No se implementó nada.

## H2 · La segunda línea de 10 sp se dibuja también en muelle

**Defecto frente a DESIGN 4.2.** Archivo:
`lib/core/design/componentes/bs_celda.dart:166–169`. El estilo de 10 sp procede de
`lib/core/design/bs_tipografia.dart:61,155`.

`DESIGN.md:137–138` reserva esa segunda línea para oficina con zoom. La condición
actual solo pregunta si `linea2` existe y si no hay marca; no consulta la densidad.
Reproducción, bajo el tema claro y oscuro con `muelle: true`:

```dart
BsCelda(
  codigo: 'GTSTC',
  etiqueta: 'Contenedor de prueba',
  linea2: '28.7',
  categoria: BsColoresSemanticos.de(context).categorico('GTSTC'),
  onTap: () {},
)
```

Resultado observado en ambos temas: `find.text('28.7')` encuentra un `Text` con
`fontSize == 10.0`. La vista previa y la prueba existente también pasan `linea2`
con densidad de muelle. Corrección propuesta: hacer cumplir la regla de densidad y
definir/probar la condición de zoom para oficina antes de integrar pantallas.
No se modificó la celda ni sus pruebas entregadas.

## Prueba adicional de los hallazgos

Se creó un diagnóstico temporal fuera de `lib/` y `test/`:

```powershell
flutter test --no-pub --reporter=expanded build/t114-aceptacion/diagnostico_test.dart
```

Resultado: **6 casos, 2 pasan y 4 fallan**, salida 1. Pasan los cotejos de tokens
tipográficos/táctiles en ambos temas. Fallan las expectativas de ocultar la segunda
línea en muelle y de conservar contraste 4.5:1 en una celda atenuada habilitada,
cada una en claro y oscuro. Registro completo: `build/t114-aceptacion/diagnostico.txt`.
Estas pruebas de aceptación adicionales no forman parte de los 1126 casos entregados.

## O1 · La descripción de la auditoría necesita precisión

No hay críticos ni informativos nuevos. Los 161 avisos nuevos son:

| Regla | Archivo | Nuevos |
|---|---|---:|
| `PERF_HARDCODED_COLOR` | `lib/core/design/bs_colores_semanticos.dart` | 128 |
| `PERF_HARDCODED_COLOR` | `lib/core/design/bs_paleta.dart` | 32 |
| `ANIM_ZERO_DURATION` | `lib/core/design/bs_movimiento.dart:36` | 1 |

`Duration.zero` corresponde a `MediaQuery.disableAnimationsOf(context)`, coherente
con reducir movimiento; este aviso es un falso positivo funcional. No propongo
cambiar ese comportamiento. Sí propongo que Yov precise la excepción al interpretar
el punto 10 y la frase de `SPRINT-4.md:147`. El informe de Timonel, en
`docs/REDISENO-RESULTADOS.md:828`, atribuye los 160 avisos de color a un solo archivo
y afirma que el script no marca los 32 de la paleta; la ejecución actual muestra
128+32. Su línea 829 sí declara el aviso de movimiento. No se editaron esos documentos.

La compilación web emitió también un aviso de familia
`packages/cupertino_icons/CupertinoIcons` ausente (`build-web.txt:70`), aunque terminó
con éxito. Se registra sin atribuirle una línea base no comprobada; las siete Plex
sí están empaquetadas y verificadas. No hubo avisos nuevos de `flutter analyze`.

## Fuentes y cálculos independientes

Todos los tamaños y SHA-256 siguientes coinciden exactamente con `provenance.json`:

| TTF | Bytes | SHA-256 |
|---|---:|---|
| IBMPlexSans-Regular.ttf | 200500 | `975DCDA37D80F038DCD143C22E33CA2D97A0CC5A929AACE1C749153B0FE1AFA5` |
| IBMPlexSans-Medium.ttf | 202460 | `331C8639D7598B2CDE62A911A71DB195E30CB655CD6BDF2E324A7E984955F907` |
| IBMPlexSans-SemiBold.ttf | 202632 | `A20CAF8286023A6A7A85E40B1D2A4AE9FC3E3B1F9EDA8F4C542DD4986AF67BB1` |
| IBMPlexSansCondensed-Medium.ttf | 202500 | `0C6B79EF4A7DE76FFC6BF2091980E5F81A1A87AC3967566BC98AAE0BAA518F54` |
| IBMPlexSansCondensed-SemiBold.ttf | 202624 | `ACC2B1E3B9597EE13B08B767F845BD038FE120CBEE806859AF7C01B60FE6E9E6` |
| IBMPlexMono-Regular.ttf | 173052 | `7C6FBDDCA4B700BE918F5F6183D9BD4464FA427FE435F0B480D77FE2BB8C5A43` |
| IBMPlexMono-Medium.ttf | 174008 | `98FBD727AAE340B236955879DABED4D991AAC9E8E90B3B2A67CE4A59221CC97C` |

Se descargó [Sans Regular desde el commit declarado de IBM](https://raw.githubusercontent.com/IBM/plex/71f558992315a12ca1f06a2215d57962a1992162/packages/plex-sans/fonts/complete/ttf/IBMPlexSans-Regular.ttf)
y [la licencia del mismo commit](https://raw.githubusercontent.com/IBM/plex/71f558992315a12ca1f06a2215d57962a1992162/LICENSE.txt).
Ambas coinciden byte por byte. Licencia: 4456 bytes, SHA-256
`7E6B2818EDBD8F6A01AE80641CC8F16A51080D08FB4E532BE3A0B6F74ADB07DA`.
Se confirmó OFL 1.1 y el nombre reservado en sus líneas 1 y 9, además de comparar
el archivo completo con el origen.

El cálculo independiente de contraste transforma cada canal sRGB normalizado:
`c/12.92` si `c <= 0.04045`; en otro caso, `((c+0.055)/1.055)^2.4`.
Después usa `L=0.2126R+0.7152G+0.0722B` y `(Lmax+0.05)/(Lmin+0.05)`.

| Par | Texto | Fondo | Razón independiente |
|---|---|---|---:|
| Tinta/papel claro | `#10243F` | `#F5F8FC` | 14.65:1 |
| Tinta/papel oscuro | `#E6EEF8` | `#0B1626` | 15.51:1 |
| Ranura categórica 0 clara | `#10243F` | `#EECEC4` | 10.59:1 |

FNV-1a independiente: inicio `2166136261`, por cada byte ASCII del código
`h=((h XOR byte)*16777619) mod 2^32`, después `h mod 24`:

| Código | Hash decimal | Hash hexadecimal | Independiente / script / Dart |
|---|---:|---|---|
| MXVER | 32548437 | `01F0A655` | 21 / 21 / 21 |
| PABLB | 2159132634 | `80B1BFDA` | 18 / 18 / 18 |
| 22P1 | 809043898 | `303907BA` | 10 / 10 / 10 |

Formatos ejecutados con `dart run build/t114-aceptacion/formatos.dart`:

| Entrada | Salida real |
|---|---|
| 28650 kg | `28.7 t` |
| 0 kg | `0.0 t` |
| 50 kg | `0.1 t` |
| 149999 kg | `150.0 t` |
| −28650 kg | `−28.7 t` |
| MSCU1234567 | `MSCU 123456 7` |
| 28650, formato kilos | `28 650 kg` |
| 0.91 | `91 %` |
| 1, contenedor/contenedores | `1 contenedor` |

La unidad usa espacio no separable U+00A0; los miles, espacio fino no separable
U+202F; el negativo usa U+2212. No son errores frente a los espacios de los ejemplos.

## Correspondencia de componentes

Los comentarios de documentación preceden a las clases públicas en sus ocho
archivos. Todos tienen grupo propio en `test/t114_componentes_test.dart`.

| Componente | Referencia de previa en `vistas_previas.dart` | Grupo de prueba, línea |
|---|---|---:|
| BsCelda | 31 y 103, claro y oscuro | 15 |
| BsTiraDeBahias | 112 | 81 |
| BsCartela | 123 | 120 |
| BsBanda | 161 | 157 |
| BsCifra | 191 | 189 |
| BsHojaDeDetalle | 200 | 208 |
| BsBarraDeOperacion / BsAvisoDeOperacion | 220 | 273 |
| BsNumeroDeContenedor | 207, dentro de la hoja | 296 |

`t114_accesibilidad_test.dart` monta ocho grupos en ambos temas, con muelle por
omisión, y un caso adicional de celda de oficina: 17 casos. El grupo de hoja incluye
`BsNumeroDeContenedor`. Aplica `textContrastGuideline`,
`androidTapTargetGuideline` y `labeledTapTargetGuideline`. La construcción de las
ocho funciones de previa también se ejecutó en claro y oscuro dentro de la suite.
Esto acredita su existencia y ejecución, con la limitación de contraste explicada en H1.

## Archivos de esta aceptación y entrega a Carlos

Único archivo de entrega creado:
`docs/rediseno/fase2/aceptacion-codex.md`.

No se modificaron fuentes de implementación, pruebas entregadas ni documentos de
Yov/Timonel. **`pubspec.yaml` y `pubspec.lock` no fueron modificados por esta
aceptación**; el cambio de `fonts:` pertenece al commit evaluado. La comprobación
final no encontró diferencias de contenido en las 38 rutas evaluadas. Los tres
archivos generados de `windows/flutter/` coinciden incluso byte por byte con HEAD;
`git diff --stat` no mostró cambios de archivos versionados antes de crear el informe.

En `build/t114-aceptacion/` se crearon los auxiliares `independiente.py`,
`formatos.dart` y `diagnostico_test.dart`, sus registros/JSON y las dos descargas de
referencia. La salida web está en `build/qa-r4-web/`. Son evidencias locales bajo
`/build/`, ignorado por `.gitignore`; no se propone forzar su inclusión.
Los primeros intentos de los scripts Python fallaron al imprimir símbolos en CP1252;
se repitieron con `$env:PYTHONUTF8='1'`, sin editar los scripts originales.

Esta copia tiene HEAD desprendido. Carlos copia el informe a la carpeta del rediseño
y, **solo allí y después de revisarlo**, puede ejecutar:

```powershell
git add -- docs/rediseno/fase2/aceptacion-codex.md
git commit -m "Sprint 4: aceptacion de fase 2 con hallazgos de contraste y tipografia"
git push
```

## Tres líneas

Se documentaron los diez puntos de aceptación con resultados propios y evidencia.
Se reprodujeron dos defectos de BsCelda; no se cambió la implementación.
La Fase 2 queda NO PASA pese a 1126/1126 y Web verificable; requiere corregir y reaceptar.

## Mensaje para Yov

Yov: Capitán Codex terminó la aceptación de T-114 Fase 2 en la copia QA; dictamen NO PASA.
La suite da 1126/1126 sin omitidas, analyze solo conserva T-100 y la Web pasa T-92 con Plex local.
BsCelda atenuada y habilitada queda en 2.08:1/2.89:1; además muestra la segunda línea de 10 sp en muelle.
La auditoría conserva 18 críticos/19 informativos; los nuevos avisos son 128+32 de color y 1 de movimiento reducido.
Informe: docs/rediseno/fase2/aceptacion-codex.md, con líneas y reproducción; no corregí código ni ejecuté escrituras Git.
