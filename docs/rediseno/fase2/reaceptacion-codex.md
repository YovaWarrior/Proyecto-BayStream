# T-114 · Fase 2 · Reaceptación de Capitán Codex

**Dictamen: ACEPTADA con observaciones.** 22-oct-2026, Guatemala.

La corrección resuelve H1 y H2. Pasan la suite **1143/1143, sin omitidas**, el
análisis sin incidencias y las verificaciones adicionales de contraste, insignias,
segunda línea y tablas. Las observaciones precisan la compatibilidad del auxiliar
anterior y el alcance del contraste del contorno y de la letra a 2.0; no se encontró
un nuevo defecto que bloquee esta corrección.

Revisión de **HEAD `5406e20`**, implementación `0361181`, contra **`fe70acf`**.
Se leyeron `AGENTS.md`, `SPRINT-4.md` 10.7–10.8, «Fase 2 · Corrección» del informe,
los archivos corregidos y las reglas actualizadas de `DESIGN.md`. Se mantuvo la luz
verde de Carlos y un comando de Flutter a la vez, empezando por `flutter pub get`.
No hubo escrituras Git, `git status`, cambios de rama, correcciones del producto,
sesiones de aplicación, Firebase, Honor ni emulador. Evidencias de esta revisión:
`build/t114-reaceptacion/`.

## Resultado por punto

| Punto | Qué se hizo | Qué salió | Evidencia |
|---|---|---|---|
| 1. Alcance | `git diff --stat=300 fe70acf..HEAD`; comparación de rutas con 2c.4 y lectura mediante `git show`. | **PASA.** 17 archivos exactos: los 16 de 2c.4 más `SPRINT-4.md`, sin faltantes ni extras. `pubspec.yaml` y `pubspec.lock` no cambian. Los 132 archivos cotejados de presentación, dominio, datos, app, main, congelados y pubspec coinciden entre base y HEAD; también con la copia actual normalizando EOL. Ninguna pantalla cambia. | `alcance-stat.txt`, `cotejo.json`, sección `protected`. |
| 2. Suite y análisis | `flutter test --no-pub --reporter=json`; conteo de resultados visibles; `flutter analyze --no-pub`, con auxiliares de QA archivados como texto. | **PASA.** 1143 éxitos, 0 fallos, 0 omitidas; 80 casos T-114. Análisis: **«No issues found!»**, salida 0. Se conserva por separado el primer análisis, que recogió auxiliares propios de QA. | `test.jsonl`, `suite-resumen.json`, `analyze.txt`, `analyze-con-auxiliares.txt`. |
| 3. H1 y prueba nueva | Repetición compatible de mis seis casos originales; lectura completa de `t114_celda_contraste_test.dart`; dos estados adicionales montados y medidos por cuenta propia. | **PASA funcionalmente, con observación de compatibilidad.** Los seis casos compatibles pasan. La prueba entregada toma `Container` y `RichText` reales, compone mediante `Color.alphaBlend` sobre papel, cubierta y bodega y compara directamente luminancias; no invoca `textContrastGuideline`. Ejecuta 900 combinaciones en cuatro pruebas, más dos reproducciones H1. Los dos estados adicionales pasan texto/iconos y contorno exterior; valores abajo. | `diagnostico-original.txt`, `diagnosticos.txt`; `test/t114_celda_contraste_test.dart:125`, `:179`, `:217`; O1 y O2. |
| 4. Línea fuerte e insignias | Recálculo independiente de los ocho pares de línea fuerte; barrido propio de las tres insignias sobre los 24 rellenos categóricos oscuros en ambas densidades. | **PASA.** `#6D809F` y `#6983A3` superan 3:1 sobre los cuatro fondos. Las 144 combinaciones de insignias superan 3:1; mínimo **3.1196:1**, refrigerado sobre ranura 5. | `cotejo.json`, `strong_line`; `diagnosticos.txt`, prueba de insignias; tabla abajo. |
| 5. H2 | Lectura de condición de densidad, zoom y alto disponible; pruebas entregadas y matriz independiente de 60 combinaciones de tema/densidad/zoom/letra. | **PASA.** En muelle la segunda línea no aparece aunque se pase. En oficina aparece con zoom ≥1.0 si cabe; no aparece con zoom 0.75/0.99 ni con letra 2.0. No se registran desbordes de layout. Las pruebas entregadas cubren también marcas y resaltado a 2.0. El código completo a 2.0 sigue siendo una obligación de Fase 3 conforme a 10.8, no queda aceptado por estas pruebas. | `bs_celda.dart:198–209`; `test/t114_componentes_test.dart:88`; `diagnosticos.txt`; O3. |
| 6. Tablas | Extracción independiente de los mapas Dart y de las listas Python mediante AST; cotejo de claves, orden, valores, ausencia de XXVSL y valores por omisión del tema. | **PASA.** 15 puertos en 0–14, 13 tipos en 0–12, sin asignaciones fijas en 15–23; Dart y script idénticos. Las fábricas semánticas y ambos temas usan `tablaFijaConfirmada` por omisión; un mapa vacío permite desactivarla. | `cotejo.json`, `tables`; `bs_categorico.dart:12,36,57`; `bs_tema.dart:21,33`; pruebas de tablas dentro de la suite. |
| 7. T-100 | Comparación del contenido completo contra `fe70acf` con `difflib`. | **PASA.** Único cambio: eliminación de `import 'dart:convert';`, antigua línea 21. Ninguna otra línea cambia. | `cotejo.json`, `t100_diff`. |
| 8. Contraste y auditoría | Script de contraste con UTF-8; auditoría global `flutter-ui --all`; comparación de regla/ruta/línea por severidad con la línea base, normalizando el prefijo de carpeta. | **PASA.** Contraste: **0 pares bajos**, salida 0. Auditoría: **18 críticos, 235 avisos, 19 informativos**. Críticos e informativos idénticos a la línea base; 161 avisos nuevos frente a ella: **128 + 32 + 1**. Ninguno en la celda, tablas o tema. | `contraste.txt`, `flutter-ui-audit.txt`, `cotejo.json`, `audit`. La auditoría sale con 1 por sus críticos preexistentes. |

## Contraste independiente y estados adicionales

La línea fuerte se recalculó en Python desde los hexadecimales del archivo actual,
con transformación sRGB, luminancia relativa y `(Lmax+0.05)/(Lmin+0.05)`, sin llamar
a las funciones del script de contraste del proyecto:

| Token | Papel | Hoja | Hoja alta | Acero tenue |
|---|---:|---:|---:|---:|
| Claro `#6D809F` | 3.7635 | 4.0087 | 3.4655 | 3.3927 |
| Oscuro `#6983A3` | 4.6466 | 4.0802 | 3.5349 | 3.4392 |

Los dos estados adicionales se midieron desde los widgets construidos, con
`Color.alphaBlend` para fondo, tinta, iconos y contorno, sin depender de una pauta
basada en semántica:

| Estado y superficie | Texto/relleno | Icono/relleno | Contorno/fondo exterior |
|---|---:|---:|---:|
| `marca: reestiba`, atenuada, sobre bodega, oscuro | 4.9365 | 4.9365 | 3.4392 |
| Reservada, sobre cubierta, claro | 6.9189 | No hay icono | 4.0087 |

La primera queda con relleno opaco `#603922`; la reserva, `#FFFFFF`. Ambas siguen
siendo tocables. El texto del caso GTSTC atenuado del diagnóstico original pasa a
**6.2040:1 en claro y 6.3809:1 en oscuro**, bajo la tabla fija actual (ranura 2).

La prueba propia de insignias cubrió peligrosa, refrigerado y OOG, cada una sobre
las 24 ranuras, en oficina y muelle oscuros: **144/144**. La tinta se leyó del `Icon`
real y se compuso sobre el relleno real. Mínimo: **3.1196:1**, refrigerado/ranura 5.
Esto amplía la prueba entregada, que verifica las insignias sobre USHOU dentro de
sus 75 estados, además de recorrer las 24 ranuras sin insignia.

## Observaciones y alcance de lo aceptado

**O1 · El diagnóstico anterior necesita compatibilidad con la nueva firma.**
El archivo original de QA no pasa literalmente sin cambios: falla al compilar en
su línea 36, `rol.atenuado(0.35)`, porque `BsRol.atenuado` recibe ahora parámetros
nombrados obligatorios (`bs_colores_semanticos.dart:34`). No es un fallo funcional
de H1 ni un archivo entregado por Timonel. Se preservó y ejecutó primero ese
original, dejando el error en `diagnostico-original.txt`.

La copia compatible sustituye aquel cálculo por la lectura del relleno del
`Container` realmente construido. Conserva las expectativas de contraste y segunda
línea; ajusta también la etiqueta del registro a la ranura de la tabla fija actual.
Sus seis casos pasan. Junto con las cuatro pruebas adicionales, el resultado es
**10/10**, salida 0, en `diagnosticos.txt`. No se cambió el producto para adaptar
el diagnóstico.

**O2 · El contraste del contorno se exige contra el fondo exterior.**
La prueba entregada compone el borde sobre el relleno, pero exige 3:1 comparando
ese borde compuesto con el fondo exterior (`t114_celda_contraste_test.dart:199–208`).
Se aceptó ese mismo criterio para la delimitación de la celda. No se declara 3:1
simultáneamente a ambos lados del borde: en el caso de movimiento atenuado sobre
bodega oscura, el contorno da **3.4392:1 hacia la bodega** y **2.5481:1 hacia su
relleno interior**. El código y el icono sí superan sus umbrales sobre el relleno.

**O3 · Sin desborde no equivale a código íntegro a 2.0.**
La segunda línea y el icono de marca se omiten cuando no caben en alto. Las pruebas
confirman que no se produce un desborde de layout. El texto principal conserva
`TextOverflow.ellipsis`; no se afirma que las cinco letras sean visibles a 2.0.
`SPRINT-4.md` 10.8 y `DESIGN.md:684–687` lo reservan expresamente para la rejilla
adaptable de la Fase 3, cuya aceptación deberá comprobar el código completo a 1.0,
1.45 y 2.0 mediante capturas.

**Preparación del análisis y pruebas exploratorias.** El primer `flutter analyze`
recogió auxiliares propios bajo `build/`: el diagnóstico antiguo incompatible y
avisos de los scripts de QA. Se archivaron **cuatro** auxiliares Dart como
`.dart.txt`, con igualdad SHA-256 comprobada, para que el análisis del proyecto
actual quede limpio también después de esta entrega. Las rutas y huellas constan
en `auxiliares-archivados.json`. Esto incluye el antiguo `formatos.dart`; no se
reejecutaron sus verificaciones.

Una primera ejecución exploratoria propia exigía también 3:1 al borde interior
y comprobaba la densidad durante la animación implícita entre temas. Se conservaron
el código y el registro de esa ejecución en `verificacion-exploratoria.txt` y
`diagnosticos-exploratorio.txt`. La ejecución final usa el criterio exterior de la
batería entregada y espera `pumpAndSettle()` al cambiar de tema; no se modificó
código de Timonel.

## Comprobación opcional de CupertinoIcons

**El aviso también se reproduce en v3.0.** Se compiló una sola vez cada versión,
con el mismo SDK local:

| Fuente | Comando, después de pub get | Resultado |
|---|---|---|
| HEAD `5406e20`, copia QA | `flutter build web --release --output=build/qa-r4-web-reaceptacion` | Salida 0; aparece el aviso CupertinoIcons. |
| Tag `v3.0`, commit `f509c3010ec99fc8a8f031f0712b68a8b811fb27` | `flutter build web --release --no-pub --output=build/qa-v3-web` | Salida 0; aparece el mismo aviso. |

La segunda compilación usó una exportación temporal de 166 archivos obtenidos
únicamente con `git show`: `lib/`, `assets/`, `web/`, pubspec, análisis y metadatos.
No se hizo checkout ni se usó otra carpeta de trabajo existente. La exportación
quedó en `C:\Users\Giova\AppData\Local\Temp\baystream-t114-v3-pv3acboz`; su
`pubspec.lock` conserva la misma huella antes y después de `pub get` y del build.

Ambos registros contienen:

```text
Expected to find fonts for (MaterialIcons, packages/cupertino_icons/CupertinoIcons), but found (MaterialIcons).
```

Evidencia: `build-web-actual.txt`, `build-web-v3.txt`, `pub-get-v3.txt`,
`v3-exportacion.json` y `cupertino-comparacion.json`. La conclusión es que el aviso
ya existe al construir el código de v3.0 con este SDK; no es una regresión de esta
corrección. No se afirma haber recuperado un registro histórico de compilación.
No se repitieron T-92 ni las verificaciones específicas de fuentes, formatos o FNV.

## Entrega y archivos

Único archivo de entrega creado:
`docs/rediseno/fase2/reaceptacion-codex.md`.

**`pubspec.yaml` y `pubspec.lock` no cambian**, ni como parte de la corrección ni
por esta aceptación. No se tocaron `lib/`, `test/`, `tool/`, las pantallas o los
documentos de Yov/Timonel. En `build/t114-reaceptacion/` se crearon los scripts de
cotejo y exportación, los diagnósticos auxiliares y los registros; `/build/` está
ignorado, y no se propone forzar su inclusión. Los cuatro auxiliares Dart propios
se conservan como texto según O1. La aceptación anterior permanece como evidencia
histórica y no se reescribió.

Carlos copia este informe a la carpeta del rediseño y, allí, puede versionarlo:

```powershell
git add -- docs/rediseno/fase2/reaceptacion-codex.md
git commit -m "Sprint 4: reaceptacion de la correccion de fase 2"
git push
```

## Tres líneas

Se documentaron los ocho puntos de la reaceptación con comprobaciones independientes.
H1 y H2 quedan resueltos: 1143/1143, análisis limpio y 10 diagnósticos compatibles en verde.
No se corrigió código; la lectura íntegra del código a 2.0 queda para la Fase 3 según 10.8.

## Mensaje para Yov

Yov: la corrección de T-114 Fase 2 queda ACEPTADA con observaciones; H1 y H2 están resueltos.
Suite 1143/1143 sin omitidas, analyze sin incidencias, contraste 0 y auditoría 18/235/19 con reparto 128+32+1.
Pasan los dos estados adicionales, las 144 combinaciones de insignias y las 60 combinaciones de segunda línea.
El aviso CupertinoIcons también se reproduce en v3.0; el informe aclara el auxiliar antiguo y el contorno exterior, y el código íntegro a 2.0 sigue para Fase 3.
Informe: docs/rediseno/fase2/reaceptacion-codex.md; no corregí código ni ejecuté escrituras Git.
