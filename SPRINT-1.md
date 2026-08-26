# BayStream · Sprint 1 — instrucciones de implementación

> **Para el agente de código.** Este archivo es la fuente de verdad del sprint en curso.
> Ventana: **22 → 29 de agosto de 2026**. Compromiso: **18 tareas · 9.75 h netas** sobre 12 h de capacidad.
> Léelo completo antes de escribir código. Las secciones 2 y 7 son restricciones duras.
> **La 2.6 en particular: no ejecutas git, lo dictas.**

---

## 1. Contexto del proyecto en diez líneas

**BayStream** es una aplicación Flutter multiplataforma (Windows, Android, Web) que lee archivos **BAPLIE** —el formato EDIFACT con que las navieras comunican el plano de estiba de un buque portacontenedores— y lo convierte en un plano visual e interactivo. Es el proyecto de graduación de Ingeniería en Sistemas de Carlos Martínez, que además trabaja como *ship planner* de profesión.

Conceptos del dominio que aparecen por todas partes en el código:

- **Coordenada BBBRRTT**: 7 dígitos = bahía (3) + fila (2) + nivel (2). `0180506` = bahía 018, fila 05, nivel 06.
- **Nivel ≥ 80 = cubierta** (deck) · **nivel < 80 = bodega** (hold).
- **Reefer** = contenedor refrigerado · **IMDG/IMO** = mercancía peligrosa · **OOG** = carga sobredimensionada.
- **Restiba** = mover un contenedor ya colocado por un error de posición. Es el costo que el producto busca evitar.

**El producto ya funciona.** Los 18 requerimientos de prioridad MUST están implementados y validados con 12 usuarios reales. Este sprint no agrega capacidades nuevas: **cierra brechas** entre lo que el producto hace y lo que el ERS especificó.

---

## 2. Restricciones duras — leer antes de tocar nada

Estas no son preferencias de estilo. Romper cualquiera daña la tesis.

### 2.1 Archivos congelados — NO TOCAR

```
lib/latency_test_screen.dart          ← instrumentación de la hipótesis H5
lib/c3_reconciliation_screen.dart     ← instrumentación de la hipótesis H5
```

Son pantallas de medición usadas para contrastar H5. Están **dentro de `lib/` a propósito** y su contenido está congelado en la etiqueta de git `m2-baseline`, que es el estado sobre el que se ejecutó el conteo de `cloc` que sostiene la hipótesis H4 (4,953 líneas compartidas). **No las muevas, no las renombres, no las borres, no las refactorices.** Si te estorban, ignóralas.

### 2.2 Credenciales de Firebase en `lib/main.dart`

Las claves están escritas en duro y apuntan al proyecto **temporal** `baystream-h5-temporal-20260814`. Está declarado y es deliberado: ese proyecto se creó para la medición de H5. **No las cambies, no las muevas a variables de entorno, no crees `firebase_options.dart`.** La migración al proyecto de producción es la tarea TC-04 del sprint de cierre (octubre), no de este sprint.

### 2.3 Las 21 pruebas deben seguir en verde

```
test/baplie_parser_test.dart   20 test()
test/widget_test.dart           1 testWidgets()
```

La cifra «21/21 pruebas pasando» aparece en el documento de tesis. Si una prueba se rompe, el arreglo es parte de la tarea que la rompió — no se comenta ni se marca como `skip`.

### 2.4 Arquitectura limpia

```
lib/core/                        utilidades, constantes, errores
lib/features/vessel/domain/      entidades y contratos de repositorio  ← sin imports de Flutter
lib/features/vessel/data/        parser BAPLIE e implementación Firestore
lib/features/vessel/presentation/ páginas, widgets y providers Riverpod
```

- La capa de **presentación no accede a fuentes de datos**; pasa por el repositorio.
- La capa de **dominio no importa `package:flutter/*`**. Es Dart puro con `equatable`.
- El estado va en **Riverpod** (`vessel_providers.dart`), no en `setState` cuando sea compartido.

### 2.5 Convenciones

- **Todo en español**: textos de interfaz, comentarios, mensajes de commit y nombres de prueba. Los identificadores de código en inglés, como está hoy.
- **Material 3**, tema oscuro. Reutiliza `Theme.of(context).colorScheme`, nunca colores literales.
- **No agregues dependencias** salvo la de generación de PDF, que es la tarea T-08 y está autorizada.
- `flutter analyze` debe salir sin advertencias nuevas (`flutter_lints` 6.0).

### 2.6 Git: tú redactas los comandos, **no los ejecutas**

**No ejecutes `git add`, `git commit`, `git push`, `git tag`, `git checkout`, `git restore` ni `git status` en este repositorio.** Ninguno. Escribe el código, deja los archivos modificados en el árbol de trabajo y **detente ahí**.

Cuando una tarea quede terminada, entrega un bloque como el de la sección 9.2 para que **el autor lo ejecute él mismo** en su terminal. Él confirma y te avisa.

Por qué, para que no parezca capricho:

1. **El repositorio es evidencia de la tesis.** Los commits y la etiqueta `m2-baseline` sostienen las hipótesis H4 y H5. La autoría del historial tiene que ser del autor del trabajo, no de una herramienta.
2. **Ya hubo dos bloqueos de `.git/index.lock`** en este repositorio por accesos concurrentes al índice. Un proceso que corre `git` mientras el editor del autor también lo hace vuelve a dejar el repositorio trabado.
3. **El autor revisa el diff antes de firmarlo.** Es su trabajo de graduación; tiene que poder explicar cada línea en la defensa.

Si necesitas saber en qué estado está el árbol, usa `git log --oneline -5`, `git diff --stat` o `git show --stat` — solo lectura, sin tocar el índice. Nunca `git status`: en este repositorio crea un `index.lock` que después no se puede limpiar.

---

## 3. Objetivo del sprint

> Cerrar las brechas funcionales que separan al producto mínimo viable de lo especificado en el ERS, de modo que el planificador pueda **extraer el viaje en los formatos que su operación exige** y **leer la carga del buque completo de un vistazo**.

Si el tiempo se agota, ese enunciado decide qué se sacrifica: lo que no sirva a la exportación ni a la vista panorámica, se corta.

---

## 4. Alcance: 4 elementos, 18 tareas, 9.75 horas

| Elemento | Nombre | Prioridad | Pts | Horas | Tareas |
|---|---|---|---|---|---|
| **RF-012** | Indicadores de peso por nivel (tier) | SHOULD | 3 | 1.5 | T-01 … T-04 |
| **RF-025** | Exportación de reporte en PDF | SHOULD | 5 | 3.0 | T-08 … T-12 |
| **RF-033** | Exportación de datos en formatos estándar | SHOULD | 3 | 2.0 | T-13 … T-16 |
| **RF-026+** | Completar el perfil longitudinal del buque | SHOULD | 5 | 3.0 | T-17 … T-20 |
| RF-020 | Ajuste de frecuencia en el estado vacío (detectado en revisión) | COULD | 0 | 0.25 | T-21 |
| | **Total** | | **16** | **9.75** | **18 tareas** |

### Por qué faltan T-05, T-06 y T-07

Correspondían a **RF-020** (estado vacío del buscador con estadísticas). Al revisar el código antes de abrir el sprint se comprobó que **ya está implementado** desde el commit `cb1861f` del 2 de febrero de 2026: `container_search_delegate.dart` → `_buildEmptyState()` muestra el total de contenedores, las navieras del viaje como chips tocables con su conteo y los puertos de descarga, y al tocarlos rellena la búsqueda y muestra resultados. Los tres criterios de aceptación se cumplen.

**No lo reimplementes.** La numeración de tareas conserva los huecos a propósito, para que coincida con el documento de Sprint Backlog ya entregado.

---

## 5. Las tareas

Cada tarea indica el archivo que toca, qué hacer y cuándo está terminada. El campo «h» es la estimación en horas netas de codificación; sirve para dimensionar, no para cronometrar.

---

### RF-012 · Indicadores de peso por nivel (1.5 h)

> **Historia.** Como planificador quiero ver el peso acumulado por nivel para vigilar la estabilidad de la pila.
> **Criterios de aceptación (del ERS).** Cada nivel muestra su peso total y se resalta cuando supera el límite configurado de la pila.

#### T-01 · Cálculo de peso acumulado por nivel — 0.5 h · Dominio

**Archivo:** `lib/features/vessel/domain/entities/bay.dart`

Añade a la clase `Bay` un getter que agrupe los contenedores por nivel y sume su peso:

```dart
/// Peso bruto acumulado por nivel (tier), en kilogramos.
/// Clave: número de nivel. Valor: suma de grossWeight de los contenedores de ese nivel.
Map<int, double> get weightByTier { … }
```

Usa `containers` y `container.stowagePosition?.tier`. Ignora los contenedores sin posición y trata `grossWeight` nulo como cero. Sigue el estilo de `totalWeight` (línea ~59), que ya hace un `fold` equivalente sobre toda la bahía.

**Terminada cuando:** el getter existe, es puro, no importa Flutter, y la suma de todos sus valores iguala `totalWeight`.

#### T-02 · Renderizar el indicador junto a cada nivel — 0.5 h · Interfaz

**Archivo:** `lib/features/vessel/presentation/widgets/bay_plan_view.dart`

En `_BayGridWidget`, el método `_buildTierRow(...)` (línea ~584) dibuja cada fila de nivel de la rejilla. Añade al final de la fila una etiqueta con el peso del nivel, en toneladas con un decimal, alineada con las celdas.

Consulta `bay.weightByTier[tier]`. Si el nivel está vacío, no muestres nada — un cero es ruido visual.

**Terminada cuando:** cada fila con contenedores muestra su peso y la rejilla no se desalinea en las tres plataformas.

#### T-03 · Resaltar el nivel que supera el límite — 0.25 h · Interfaz

**Archivos:** `lib/core/constants/baplie_constants.dart` y `bay_plan_view.dart`

⚠️ **El límite de apilamiento no existe en el código ni viene en el archivo BAPLIE.** Créalo como constante en `baplie_constants.dart`:

```dart
/// Límite de peso por nivel usado para la alerta visual de apilamiento, en kg.
/// PROVISIONAL: el límite real depende del buque y de la terminal, y no viene
/// declarado en el archivo BAPLIE. Se expone como constante configurable
/// mientras no exista una fuente autorizada.
const double kStackWeightLimitKg = 90000;
```

**No presentes el valor como si fuera una norma.** El comentario de arriba es obligatorio: en la defensa de la tesis, inventar un umbral normativo sería un error grave. Al superarlo, aplica el color de advertencia del `colorScheme`.

**Terminada cuando:** la constante está documentada como provisional y el nivel que la supera se distingue visualmente.

#### T-04 · Prueba unitaria del cálculo — 0.25 h · Prueba

**Archivo:** `test/baplie_parser_test.dart` (grupo `Bay`, ya existe)

Añade un `test()` que construya una bahía con contenedores en al menos dos niveles distintos —uno de cubierta (≥ 80) y uno de bodega (< 80)— y verifique `weightByTier`. Mantén el estilo: nombres en español, `expect` explícitos.

**Terminada cuando:** `flutter test` reporta 22/22.

---

### RF-025 · Exportación de reporte en PDF (3.0 h)

> **Historia.** Como planificador quiero exportar el reporte del viaje en PDF para adjuntarlo al expediente de la operación.
> **Criterios de aceptación (del ERS).** Genera un PDF con portada, resumen, plano por bahía y tabla de contenedores; permite compartir el archivo.

#### T-08 · Incorporar y verificar el paquete de PDF — 0.5 h · Infraestructura

> 🔴 **EMPIEZA POR AQUÍ.** Es el riesgo de mayor impacto del sprint.

**Archivo:** `pubspec.yaml`

Agrega el paquete de generación de PDF y **verifica que compila en las tres plataformas antes de escribir una línea del contenido del reporte**. Si falla en alguna, detente y repórtalo: la decisión de recortar alcance se toma en ese momento, no la víspera de la entrega.

```
flutter build windows --debug
flutter build apk --debug
flutter build web
```

**Terminada cuando:** las tres compilaciones pasan, o está documentado cuál falla y por qué.

#### T-09 · Portada y resumen del viaje — 0.5 h · Interfaz

Buque, número de viaje, puertos, total de contenedores, TEU, peso total y conteo de carga especial. Los datos ya están en `VesselVoyage` (getters `totalContainers`, `fullContainers`, `emptyContainers`, `totalGrossWeight`, `totalVgmWeight`) y en `voyageStatsProvider`.

#### T-10 · Plano de cada bahía dentro del PDF — 1.0 h · Interfaz

Reutiliza el **mismo esquema cromático** que el bay plan en pantalla y **respeta la separación cubierta/bodega en el nivel 80**. Un PDF que coloree distinto que la pantalla es un PDF que confunde.

#### T-11 · Tabla de contenedores paginada — 0.5 h · Interfaz

Encabezado repetido en cada página, ordenada por coordenada de estiba.

#### T-12 · Compartir y guardar en las tres plataformas — 0.5 h · Infraestructura

> ✅ **DECIDIDO: usar `file_picker`, que ya está en el proyecto. NO se autoriza `printing`.** Ver sección 10.1.

`file_picker` 10.3.10 —ya presente y ya validado en las tres plataformas desde enero— resuelve el guardado con una sola llamada:

```dart
final ruta = await FilePicker.platform.saveFile(
  dialogTitle: 'Guardar reporte del viaje',
  fileName: 'BayStream_${voyage.vessel.name}_${voyage.voyageNumber}.pdf',
  type: FileType.custom,
  allowedExtensions: ['pdf'],
  bytes: pdfBytes,          // OBLIGATORIO en Web: sin bytes lanza ArgumentError
);
```

Comportamiento por plataforma, según la documentación de la versión 10.3.10:

| Plataforma | Qué hace | Retorna |
|---|---|---|
| Windows | Diálogo nativo de guardado | ruta absoluta |
| Android | Guarda el archivo vía el selector del sistema | ruta absoluta |
| Web | Dispara la descarga del archivo | siempre `null` |

⚠️ **Verifica las tres plataformas ANTES de dar la tarea por terminada**, igual que hiciste en T-08. En Web, `bytes` y `fileName` son obligatorios. Si alguna falla, detente y repórtalo: ahí se activa el plan B de la sección 10.1.

---

### RF-033 · Exportación en formatos estándar (2.0 h)

> **Historia.** Como planificador quiero exportar el viaje en CSV o JSON para analizarlo en otras herramientas.
> **Criterios de aceptación (del ERS).** Exporta la lista completa con todas las columnas del modelo; el CSV abre correctamente en Excel con codificación UTF-8.

#### T-13 · Serializar a CSV — 0.75 h · Datos

**Archivo nuevo sugerido:** `lib/features/vessel/data/services/export_service.dart`

Todas las columnas de `ContainerUnit`. **Antepón la marca de orden de bytes UTF-8 (`﻿`)** o Excel en Windows mostrará los acentos rotos — es el detalle que hace fallar el criterio de aceptación. Escapa comillas y separadores dentro de los campos.

#### T-14 · Serializar a JSON — 0.5 h · Datos

**Reutiliza `VesselVoyage.toJson()` y `ContainerUnit.toJson()`**, que ya existen. No escribas una serialización paralela: si el modelo cambia, la exportación debe cambiar con él.

#### T-15 · Selector de formato y diálogo de guardado — 0.5 h · Interfaz

**Un solo punto de entrada** que ofrezca PDF, CSV y JSON, compartido con RF-025. No pongas dos botones de exportar en la interfaz.

#### T-16 · Verificar el CSV en Excel — 0.25 h · Prueba

Con un archivo del corpus real (`corpus_m1/`). Comprueba acentos, separador de columnas y formato numérico.

---

### RF-026+ · Perfil longitudinal del buque (3.0 h)

> **Contexto.** El tablero de estadísticas ya tiene `_BayOccupancyChart` y `_BayWeightChart` (`voyage_stats_view.dart`, líneas ~700 y ~795), que muestran la distribución **por bahía en formato de barras**. Falta la vista panorámica: el buque completo en un solo perfil navegable. Eso es lo que este elemento cierra.

#### T-17 · Construir el perfil longitudinal — 1.0 h · Interfaz

**Archivo nuevo sugerido:** `lib/features/vessel/presentation/widgets/vessel_profile_view.dart`

Todas las bahías en secuencia de proa a popa, una celda por bahía, sobre `CustomPainter`. El archivo `voyage_stats_view.dart` ya usa ese patrón en `_PieChartPainter` (línea ~901) — sigue ese estilo.

#### T-18 · Gradientes por ocupación y por peso — 0.75 h · Interfaz

Dos modos conmutables, cada uno con **una escala de un solo tono** y su leyenda. No uses arcoíris: la escala tiene que leerse como una magnitud, y un arcoíris no tiene orden perceptual.

#### T-19 · Navegación del perfil al detalle de la bahía — 0.75 h · Interfaz

Al tocar una bahía se abre su rejilla en la pestaña Bay Plan. Ya existe `selectedBayProvider` (`vessel_providers.dart`, línea ~234) y el `TabController` está en `vessel_overview_page.dart` (línea ~28, 3 pestañas). Reutiliza ambos.

#### T-20 · Ajustar a las tres plataformas — 0.5 h · Prueba

Desplazamiento horizontal en tablet, redimensionado en escritorio y navegador.

---

### RF-020 · Ajuste menor detectado en revisión (0.25 h)

#### T-21 · Ordenar las navieras y los puertos por frecuencia — 0.25 h · Interfaz

**Archivo:** `lib/features/vessel/presentation/widgets/container_search_delegate.dart`, método `_buildEmptyState()`

El criterio de aceptación del ERS dice «navieras **frecuentes**», pero el código actual hace `.take(5)` sobre un `Set` sin ordenar, de modo que muestra las cinco primeras en orden de aparición, no las cinco con más carga. Es un defecto menor pero real: el criterio no se cumple literalmente.

Cuenta los contenedores por naviera y por puerto, ordena de mayor a menor y **después** toma cinco. El conteo ya se calcula más abajo para el `avatar` de cada `ActionChip`; súbelo antes del `.take(5)` y reutilízalo en vez de recorrer la lista dos veces.

**Terminada cuando:** las cinco navieras y los cinco puertos mostrados son los de mayor conteo, en orden descendente.

---

## 6. Orden de ataque recomendado

No es el orden numérico. Está ordenado por riesgo decreciente: lo que puede fallar debe fallar el primer día, no el último.

1. **T-08** — verifica el paquete de PDF en las tres plataformas. Si falla, todo RF-025 se replantea.
2. **T-17, T-18** — el perfil longitudinal es render geométrico sin precedente en el código.
3. **T-01 → T-04** — RF-012 completo. Es el más acotado y da una victoria temprana.
4. **T-13 → T-16** — RF-033. Serialización directa, bajo riesgo.
5. **T-09 → T-12** — contenido del PDF, ya con el paquete verificado.
6. **T-19, T-20** — integración y ajuste multiplataforma.

---

## 7. Definición de Terminado

Una tarea no está hecha hasta que cumple **todo** esto:

- [ ] Satisface sus criterios de aceptación en los tres clientes soportados.
- [ ] Respeta la separación de capas: la presentación no accede a datos, el dominio no importa Flutter.
- [ ] `flutter test` en verde (21 pruebas, 22 tras T-04).
- [ ] `flutter analyze` sin advertencias nuevas.
- [ ] Verificada contra al menos un archivo BAPLIE real de `corpus_m1/`, no solo con datos sintéticos.
- [ ] Funciona sin conexión cuando la historia lo exige.
- [ ] **Bloque de commit entregado al autor** con el formato de la sección 9.2 — tú no ejecutas git (ver 2.6).
- [ ] El mensaje que propones va en español, **sin acentos** (la terminal del autor corrompe la codificación) y referencia el requerimiento: `RF-012: añadir peso por nivel` → escribir `RF-012: anadir peso por nivel`.

---

## 8. Qué NO hacer en este sprint

- ❌ Reimplementar RF-020 (ya está hecho, ver sección 4).
- ❌ Tocar `latency_test_screen.dart` ni `c3_reconciliation_screen.dart`.
- ❌ Mover archivos fuera de `lib/` o reorganizar carpetas: alteraría el conteo de `cloc` de la hipótesis H4.
- ❌ Cambiar las credenciales de Firebase ni crear `firebase_options.dart`.
- ❌ Implementar RF-027 (validación de reglas de estiba). Es la innovación central de la tesis y tiene **el sprint 2 completo reservado** (19 sep → 17 oct). No lo adelantes ni siquiera parcialmente.
- ❌ Agregar autenticación, roles, comparación entre viajes o sincronización en Windows: están **diferidos** fuera del alcance del curso.
- ❌ Agregar dependencias más allá de la de PDF autorizada en T-08.
- ❌ Refactorizar código que funciona «de paso». El sprint dura ocho días.
- ❌ **Ejecutar cualquier comando de git.** Los redactas para el autor (secciones 2.6 y 9.2); él los corre.

---

## 9. Cómo reportar el avance

### 9.1 · Al terminar cada tarea

Una línea:

```
T-01 hecha · bay.dart +18 líneas · weightByTier suma igual a totalWeight ✓
```

Si una tarea se desvía más del doble de su estimación, **detente y repórtalo** en vez de seguir. La holgura del sprint es de 2.25 h sobre una capacidad de 12 h; una sola tarea desbordada se la come entera.

Si encuentras que **otro requerimiento ya estaba implementado** —como pasó con RF-020— repórtalo antes de tocarlo. Es el tercer caso en este proyecto: el ERS también marca RF-011 y RF-014 como propuestos cuando el código demuestra lo contrario.

### 9.2 · Bloque de commit — el formato exacto

Cuando termines una tarea (o un grupo pequeño de tareas del mismo requerimiento), entrega **esto y nada más**, listo para copiar y pegar. No lo ejecutes.

```
──────────── PARA CARLOS · ejecutar en PowerShell ────────────
cd C:\Proyectos\proyecto-baystream

git add lib/features/vessel/domain/entities/bay.dart
git add test/baplie_parser_test.dart

git commit -m "RF-012: anadir peso acumulado por nivel en la entidad Bay"

git push
──────────────────────────────────────────────────────────────
Qué cambió: Bay.weightByTier calcula el peso por tier reutilizando
el patron de totalWeight. Prueba nueva que verifica que la suma de
weightByTier es igual a totalWeight.
Archivos: 2 · +34 / -2 lineas · flutter test 22/22 verde
```

Reglas del bloque:

- **Rutas explícitas en `git add`**, nunca `git add .` ni `git add -A`. El repositorio arrastra ruido de fin de línea CRLF que ensuciaría el commit con decenas de archivos sin cambios reales.
- **Un commit por requerimiento**, no uno por tarea suelta. T-01 a T-04 son un solo commit de RF-012.
- **Nunca incluyas** en el `git add`: `lib/latency_test_screen.dart`, `lib/c3_reconciliation_screen.dart`, `lib/main.dart` (credenciales), ni nada bajo `docs/`.
- Si el cambio toca `pubspec.yaml` o `pubspec.lock`, dilo explícitamente en la línea «Qué cambió» — son los archivos que más se revisan.
- Espera la confirmación del autor antes de empezar la siguiente tarea que toque los mismos archivos.


---

## 10. Decisiones tomadas durante el sprint

### 10.1 · `printing` NO se autoriza — T-12 usa `file_picker`

**Pregunta:** el paquete `pdf` genera los bytes pero no la hoja de compartir de Android. ¿La autorización de «dependencia PDF» cubre también `printing 5.14.3`?

**Respuesta: no, y no hace falta.** Cuatro razones:

1. **`file_picker` 10.3.10 ya resuelve las tres plataformas.** Su método `saveFile(bytes:)` abre el diálogo nativo en Windows, guarda vía el selector del sistema en Android y dispara la descarga en Web. Es un solo punto de entrada, que es justo lo que T-15 pide.
2. **`pdf` es Dart puro; `printing` es un plugin con código nativo.** La verificación de T-08 no dice nada sobre `printing`: habría que repetir las tres compilaciones y volver a abrir el riesgo que acabas de cerrar.
3. **Conflicto de resolución.** `printing 5.15.0` depende de `pdf ^3.13.0`, que es exactamente la versión descartada por exigir Dart 3.12. Entrar ahí es pelearse con el resolvedor sin necesidad.
4. **`file_picker` ya está validado en producción** desde enero: es lo que usa `vessel_providers.dart` para cargar el BAPLIE. Cero riesgo nuevo.

Sobre el criterio del ERS —«permite compartir el archivo»—: guardar mediante el diálogo nativo del sistema operativo lo satisface para el propósito declarado, que es adjuntar el reporte al expediente de la operación. No exige la hoja de compartir de Android.

**Y hay un argumento de tesis:** resolver el guardado en tres plataformas con una dependencia que ya estaba, en lugar de añadir un plugin nativo, es evidencia adicional a favor de la hipótesis H4, que postula que el enfoque multiplataforma reduce el esfuerzo de desarrollo. Añadir `printing` debilitaría ese argumento en la defensa.

**Plan B, autorizado solo si `saveFile` falla** en alguna plataforma durante T-12: entonces sí se autoriza `printing 5.14.3`, con la condición de repetir `flutter build` en Windows, Android y Web antes de continuar, y de reportarlo.

### 10.2 · Bloques confirmados

**T-17 y T-18 — cerradas.** `vessel_profile_view.dart`, `CustomPainter` con todas las bahías en secuencia de proa a popa, dos modos conmutables (Ocupación y Peso) con escala monocromática propia por modo y leyenda propia. Integrado en la pestaña Estadísticas vía `voyage_stats_view.dart`. Validado contra `CORPUS_A01.edi` real anonimizado. Cero avisos nuevos, 21/21 pruebas.

**T-01 a T-04 — cerradas.** `Bay.weightByTier` (getter puro, agrupa por tier, acumula `grossWeight` en kg; contenedores sin posición se ignoran, pesos nulos cuentan como cero; suma verificada contra `Bay.totalWeight`). El Bay Plan muestra el peso acumulado por nivel ocupado (toneladas, un decimal), oculta el cero en niveles vacíos, reserva ancho fijo para no desalinear la tabla y añade scroll horizontal en pantallas angostas. Alerta visual con los colores semánticos del `ColorScheme` cuando un nivel supera `kStackWeightLimitKg = 90000` — **constante marcada como PROVISIONAL en el código**, porque el límite real de apilamiento depende del buque y la terminal y no viene en el BAPLIE (ver 10.4). Probado en 360×640 sin overflow, 22/22 pruebas.

**T-13 a T-16 — cerradas.** `export_service.dart` nuevo: CSV con las 24 propiedades de `ContainerUnit`, BOM UTF-8 (`EF BB BF`) para compatibilidad con Excel en Windows, escapado correcto de comas/comillas/saltos de línea/nulos, decimales estables. JSON reutiliza `VesselVoyage.toJson()`/`ContainerUnit.toJson()` directamente — sin serialización paralela. Nombres de archivo normalizados para Windows. Un solo menú «Exportar viaje» con PDF/CSV/JSON; **PDF queda visible pero deshabilitado**, marcado como pendiente de RF-025 — T-09…T-12 solo conecta sus bytes, no crea otro botón. Validado contra `CORPUS_A01.edi` real: 977 contenedores, 24 columnas, rango `A1:X978`; textos con acentos y comillas («Ciudad de Panamá», «Línea "Águila", S.A.») conservados correctamente en una sola celda. 25/25 pruebas.

**T-09 a T-12 — cerradas.** `pdf_report_service.dart` nuevo: portada con buque/viaje/puertos/dirección/bahías/contenedores/TEU/peso bruto/VGM/llenos/vacíos/carga especial (puertos derivados de los contenedores cuando faltan los generales; TEU por tamaño ISO); una página horizontal por bahía con el mismo esquema cromático de la pantalla (lleno verde, vacío naranja, IMO rojo, reefer cian, OOG naranja, posiciones vacías gris) y separación visual cubierta/bodega en el tier 80; tabla ordenada por coordenada de estiba con encabezado repetido por página; numeración y pie en todas las páginas. Botón PDF del menú «Exportar viaje» habilitado — mismo punto de entrada que CSV/JSON. Guarda con `FilePicker.platform.saveFile(bytes:)`; **`printing` no hizo falta, el Plan B de la sección 10.1 no se activó.** Helvetica se descartó por no garantizar Unicode; se embebieron `Roboto-Regular.ttf`/`Roboto-Medium.ttf` del SDK de Flutter como asset (no como dependencia — `pubspec.lock` no cambió). Validado contra `CORPUS_A01.edi` real: 977 contenedores, 27 bahías, 55 páginas, inspección visual de portada/bahías densas/tabla/última página sin recortes ni solapamientos, acentos confirmados por extracción («Dirección», «Bahías», «gálibo»). 27/27 pruebas.

Con esto, **RF-025 queda funcionalmente completo** (verificación de plataforma en T-08, contenido y guardado en T-09…T-12).

**T-19 y T-20 — cerradas.** Navegación perfil → Bay Plan: cada celda longitudinal con `InkWell`, `Tooltip` y `Semantics` con el número de bahía; `VesselProfileView` propaga la selección a `VoyageStatsView`, `VesselOverviewPage` escribe en `selectedBayProvider` y salta de pestaña con `TabController.animateTo(1)`. `BayPlanView` respeta una selección hecha antes de construirse y escucha las posteriores. Los `FilterChip` también escriben en `selectedBayProvider`, de modo que el estado visual y el compartido no se desincronizan; al navegar desde el perfil se limpia el resaltado viejo de una búsqueda de contenedor. Ajuste multiplataforma con `ScrollController` y `Scrollbar` horizontal interactivo, sin overflow en 360/800/1440 px lógicos. Las tres compilaciones en verde. Sin dependencias nuevas (`pubspec.yaml`/`pubspec.lock` sin cambios). 30/30 pruebas, 3 de ellas nuevas — incluida una de integración completa perfil → provider → pestaña → FilterChip.

Con esto, **RF-026+ queda funcionalmente completo** y el sprint llega a 9.5 h de 9.75 h.

**T-21 — cerrada.** `_buildEmptyState()` cuenta navieras y puertos en dos mapas durante un único recorrido, ordena por conteo descendente antes del `.take(5)` y desempata alfabéticamente para que el resultado sea determinista. Los `ActionChip` reutilizan `entry.value` para sus avatares, eliminando los `containers.where(...).length` repetidos. Prueba nueva con siete navieras y siete puertos en orden de inserción distinto al de frecuencia, que verifica los diez chips esperados, los conteos `[6, 5, 5, 4, 3]`, la exclusión de los dos menos frecuentes y el desempate alfabético — **y que falla contra la implementación anterior**, que es lo que la hace una prueba de regresión real. 31/31 pruebas.

---

## ✅ SPRINT 1 COMPLETO — 29/08/2026

**18 tareas · 9.75 h netas sobre 12 h de capacidad · 7 commits · 31/31 pruebas.**

| Requerimiento | Estado | Commit |
|---|---|---|
| RF-012 · Indicadores de peso por nivel | ✅ completo | `5b260d8` |
| RF-020 · Estado vacío por frecuencia | ✅ completo | `80dde67` |
| RF-025 · Exportación de reporte en PDF | ✅ completo | `52ec4da` + `c9e48b2` |
| RF-026+ · Perfil longitudinal del buque | ✅ completo | `f5c84fb` + `51e8bb6` |
| RF-033 · Exportación en formatos estándar | ✅ completo | `e0f41a6` |

Ninguna tarea se desvió del doble de su estimación. No se añadió ninguna dependencia más allá de `pdf: 3.12.0` (autorizada en T-08); `printing` se evaluó y se rechazó. Las pruebas pasaron de 21 a 31. Los archivos congelados de instrumentación H5 y las credenciales de Firebase quedaron intactos.

### 10.5 · Al cerrar T-21 — preparar la entrega del 29 de agosto

El sprint termina con T-21, pero el **entregable del 29-ago no es código**: es «Presentación del Incremento 1 + Seguridad y calidad del Sprint» (5 pts). Lo que hay que tener listo ese día:

1. **El incremento funcionando**, demostrable en vivo: peso por nivel, perfil longitudinal con navegación, exportación PDF/CSV/JSON.
2. **El tablero Kanban con las tarjetas movidas** — es la evidencia de que el marco se ejecutó, no solo se planificó.
3. **Tres cosas que Carlos debe disclosurar él mismo**, no esperar a que se las pregunten: el `kStackWeightLimitKg` provisional (ver 10.4), las tres discrepancias ERS/código (RF-011, RF-014, RF-020) y el ajuste de alcance del sprint (RF-020 ya estaba hecho → entró T-21 en su lugar).
4. **Las 49 advertencias preexistentes de `flutter analyze`**, declaradas y diferidas a TC-01 con justificación.

### 10.3 · Bitácora del sprint

| Tarea | Estado | Commit | Nota |
|---|---|---|---|
| T-08 | ✅ hecha | `52ec4da` | `pdf: 3.12.0` fijado. 3.13.0 descartado por exigir Dart 3.12 (proyecto en 3.10.8). Windows, Android y Web compilan. 21/21 pruebas. |
| T-17, T-18 | ✅ hechas | `f5c84fb` | `vessel_profile_view.dart` nuevo (`CustomPainter`), modos Ocupación/Peso, sin arcoíris. 2 archivos, +381/-16. Cero avisos nuevos en el archivo nuevo; 14 preexistentes sin tocar en `voyage_stats_view.dart`. 21/21 pruebas. |
| T-01…T-04 | ✅ hechas | `5b260d8` | `Bay.weightByTier` + indicadores en Bay Plan. 4 archivos, +119/-10. Cero avisos nuevos; 4 preexistentes de `withOpacity` sin tocar. 22/22 pruebas. |
| T-13…T-16 | ✅ hechas | `e0f41a6` | `export_service.dart` nuevo. CSV+BOM+JSON validados contra CORPUS_A01.edi (977 contenedores/24 col.). Menú unico "Exportar viaje", PDF deshabilitado hasta T-09…T-12. Cero avisos nuevos; 2 preexistentes de `withOpacity` sin tocar. 25/25 pruebas. |
| T-09…T-12 | ✅ hechas | `c9e48b2` | `pdf_report_service.dart` nuevo. Fuentes Roboto embebidas por Unicode. 977 contenedores/27 bahias/55 paginas validado contra CORPUS_A01.edi. Plan B (printing) no se activo. Cero avisos nuevos; 2 preexistentes sin tocar. 27/27 pruebas. |
| T-19, T-20 | ✅ hechas | `51e8bb6` | Navegacion perfil → Bay Plan via `selectedBayProvider` + `TabController`. Scrollbar horizontal interactivo, sin overflow en 360/800/1440 px. Sin dependencias nuevas. 30/30 pruebas (3 nuevas, una de integracion completa). |
| T-21 | ✅ hecha | `80dde67` | `_buildEmptyState()` ordena por conteo descendente antes del `.take(5)`, con desempate alfabetico. Prueba de regresion que falla contra la implementacion anterior. 31/31 pruebas. |
| T-22 | ✅ hecha | `89bdb2c` | `firestore.rules` versionado. `voyages`: read/create/update si, delete no. Resto denegado. Sin cambios en Dart, 31/31 pruebas. **Detecto que bloquea `latency_test` → T-23.** |
| T-23 | ✅ hecha | `8bc1bf0` | Regla de `latency_test` con la transicion del protocolo C1/C2 y las cuatro condiciones integras. `t0`, `condicion` y `evento` inmutables. Archivos congelados intactos. 31/31 pruebas. |

### 10.6 · T-22 · Endurecimiento posterior al sprint (derivado de la auditoría)

**No forma parte del alcance comprometido del Sprint 1.** Surge de la auditoría de seguridad del 25 de agosto (`docs/AUDITORIA-SEGURIDAD-SPRINT1.md`, hallazgos H-01 y H-02) y se ejecuta antes de abrir el Sprint 2.

**T-22 · Crear `firestore.rules` versionado.** 0.25 h. Tipo: Infraestructura.

Hoy no existe ningún archivo de reglas en el repositorio: el único control de autorización de la aplicación vive solo en la consola de Firebase, sin versionar. Y como no hay autenticación en el alcance del curso, la colección `voyages` acepta borrado anónimo — `vessel_repository_impl.dart` línea 96 expone `.delete()`.

Crear `firestore.rules` en la raíz del repositorio con exactamente este contenido:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // PROVISIONAL - Proyecto de Graduacion II, sin autenticacion en alcance.
    // Permite lectura y escritura de viajes, pero NUNCA borrado.
    // El borrado es la operacion irreversible y no la necesita ningun
    // requerimiento del ERS.
    match /voyages/{voyageId} {
      allow read, create, update: if true;
      allow delete: if false;
    }
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

**Criterios de aceptación:**

- [ ] El archivo existe en la raíz y está versionado.
- [ ] El comentario que declara la regla como PROVISIONAL se conserva textualmente — es lo que la hace defendible ante el tribunal.
- [ ] **No se despliegan las reglas desde aquí.** Codex no ejecuta `firebase deploy`, igual que no ejecuta git. Carlos las publica desde la consola de Firebase o con su propio CLI.
- [ ] No se toca `lib/main.dart` ni ninguna credencial (restricción 2.2).
- [ ] No se elimina la llamada `.delete()` del repositorio: la regla la bloquea del lado del servidor, que es donde corresponde. Quitarla del cliente daría una falsa sensación de control.
- [ ] `flutter test` sigue en 31/31 — este cambio no toca código Dart.

---

### 10.7 · T-23 · Regla de la colección de mediciones de H5 (CORREGIDA)

> **Corrección.** La primera redacción de esta sección especificaba `allow update: if false`. **Era incorrecta** y el agente hizo bien en detenerse antes de implementarla. Se escribió asumiendo que una medición se registra de una sola vez, sin verificar el protocolo real de `latency_test_screen.dart`. La versión de abajo es la autorizada.

**Por qué la primera versión rompía la medición.** El protocolo C1/C2 es un intercambio en dos fases sobre un mismo documento:

1. **Emisor** (`_ejecutarEmisor`, líneas 61-68): crea el documento con `t0`, `condicion`, `evento` y `respondido: false`.
2. **Receptor** (`_activarReceptor`, líneas 32-45): escucha los documentos con `respondido == false` y **actualiza** el documento poniendo `respondido: true` y añadiendo `proceso_b_ms`.
3. **Emisor** (línea 71): su listener espera `respondido == true` para calcular la latencia de ida y vuelta.

Con `update` denegado, el paso 2 falla, el paso 3 nunca se completa y cada evento termina por tiempo de espera agotado. Y como `latency_test_screen.dart` es **archivo congelado** (restricción 2.1), el protocolo no se puede cambiar: la regla es la que tiene que acomodarse.

**T-23 · Añadir la regla de `latency_test`.** 0.25 h. Tipo: Infraestructura.

Insertar este bloque en `firestore.rules`, **antes** de la regla general `match /{document=**}`:

```javascript
    // Instrumentacion de la hipotesis H5 (pantallas de medicion C1 y C2).
    // El protocolo es un intercambio en dos fases sobre un mismo documento:
    // el emisor lo crea con respondido:false y el receptor lo cierra
    // poniendo respondido:true. Se permite ESA transicion y ninguna otra.
    // t0, condicion y evento son inmutables desde su creacion, y una
    // medicion ya cerrada no se puede volver a tocar.
    match /latency_test/{medicionId} {
      allow read, create: if true;
      allow update: if resource.data.respondido == false
        && request.resource.data.respondido == true
        && request.resource.data.proceso_b_ms is number
        && request.resource.data.diff(resource.data).affectedKeys()
          .hasOnly(['respondido', 'proceso_b_ms']);
      allow delete: if false;
    }
```

**Esta regla es más defendible que la que yo había escrito, no menos.** La versión original solo podía afirmar «las mediciones no se modifican». Esta afirma algo más preciso y más fuerte:

- **`t0`, `condicion` y `evento` son inmutables desde su creación.** Son justamente los tres campos que habría que tocar para falsear un resultado de latencia: el instante de emisión, la condición experimental y el número de evento. La cláusula `hasOnly` los blinda.
- **Una medición se cierra exactamente una vez.** La guarda `resource.data.respondido == false` impide reabrir un documento ya cerrado, así que no se puede reintentar hasta obtener una cifra favorable.
- **El campo de respuesta tiene que ser numérico.** `proceso_b_ms is number` descarta escrituras mal formadas.

Vale la pena que Carlos tenga esto listo para la defensa: ante «¿pudo usted alterar sus mediciones?», la respuesta deja de ser su palabra y pasa a ser una regla de autorización verificable.

**Criterios de aceptación:**

- [ ] El bloque queda **antes** de `match /{document=**}`.
- [ ] Las cuatro condiciones del `allow update` se conservan íntegras. Quitar cualquiera debilita la garantía.
- [ ] `allow delete: if false`.
- [ ] El comentario se conserva textualmente: es lo que explica por qué la regla tiene esa forma y no otra.
- [ ] No se toca `latency_test_screen.dart` — archivo congelado (restricción 2.1).
- [ ] Sin cambios en código Dart; `flutter test` sigue en 31/31.
- [ ] Codex no ejecuta `firebase deploy`.

---

### 10.9 · Resultado de la verificación (25 de agosto) — ✅ superada

**Reglas publicadas y contrastadas contra el protocolo real.** Android (POCO X3 NFC) como receptor, Chrome Web como emisor, condición C1, tres eventos.

| Evento | Ida y vuelta | Proceso B | Cerrado |
|---|---|---|---|
| 1 | 1 323 ms | 2.614 ms | ✅ |
| 2 | 803 ms | 0.110 ms | ✅ |
| 3 | 965 ms | 0.086 ms | ✅ |

**3/3.** La instrumentación de H5 queda operativa y reproducible.

#### Lo que se descubrió al abrir la consola

Las reglas vigentes decían `if request.time < timestamp.date(2026, 8, 17)`. **Habían expirado ocho días antes.** La sincronización llevaba ocho días caída sin que nadie lo notara, porque ninguna de las cinco funcionalidades del incremento usa Firestore.

Y la auditoría del 25-ago tenía **dos errores de hecho**, ambos por haber tenido que inferir las reglas en lugar de leerlas:

| Lo que afirmó la auditoría | La realidad |
|---|---|
| «Admite borrado anónimo» | Falso: `allow delete: if false` ya estaba en ambas colecciones. H-02 baja de Crítica a Alta. |
| «Caducan ~13 de septiembre» | Falso: caducaron el 17 de agosto. H-03 sube de Alta a Crítica. |

**H-01 se demostró a sí mismo:** el hallazgo era que las reglas no eran revisables, y la consecuencia fue exactamente una auditoría que no pudo revisarlas. Ya está documentado en los cuatro entregables del 29.

#### Pendiente operativo antes de una corrida real de medición *(cerrado — ver actualización)*

Al activar el receptor se produjeron tres `PERMISSION_DENIED` sobre documentos históricos con `respondido: false`. No afectaron la prueba. **Purgar esos documentos desde la consola antes de ejecutar una serie completa de C1/C2** — con tres eventos la ráfaga es inocua, con treinta conviene no depender de que el listener la absorba.

**Actualización, mismo día:** Carlos revisó la colección `latency_test` completa desde la consola. 66 documentos en total, los 66 con `respondido: true`. Cero documentos colgados en `respondido: false` — no hay nada que purgar. Los tres `PERMISSION_DENIED` no dejaron rastro en el estado final. Pre-vuelo cerrado sin ninguna acción manual pendiente antes de la corrida de 30 eventos.

Dato aprovechable para la defensa: sobre 66 escrituras históricas del protocolo de dos fases (emisor crea → receptor cierra), el cierre fue 100% — ni un documento quedó a medias. Es evidencia adicional, independiente de los tres eventos de la tabla de arriba, de que la instrumentación de H5 es confiable.

---

### 10.8 · Lo único que quedaba sin verificar empíricamente *(superado — ver 10.9)*

**Las reglas estaban escritas y confirmadas, pero no publicadas ni probadas contra Firestore.**

Todo lo demás de este sprint se verificó ejecutándolo: las pruebas corren, las tres plataformas compilan, el PDF se generó contra un BAPLIE real. Las reglas de autorización son la excepción — se verificaron **leyéndolas**, no ejecutándolas. Y una regla declarativa que se lee bien puede comportarse distinto de lo previsto: no hay compilador que la valide ni prueba unitaria que la cubra.

**Procedimiento de verificación, después de publicar desde la consola:**

1. Abrir la pantalla de medición de latencia en dos clientes.
2. Activar el receptor en uno.
3. Lanzar **una** serie corta desde el otro — tres o cuatro eventos bastan.
4. Confirmar que los eventos se **cierran** en lugar de agotar el tiempo de espera.

Si se cierran, la regla funciona y H5 sigue siendo reproducible. Si se agotan, la regla rechaza la actualización de cierre y hay que revisarla **antes** de seguir — no en la defensa.

Conviene hacerlo el mismo día de publicar las reglas, mientras el contexto está fresco.

---

### 10.4 · Hallazgos registrados, sin acción en este sprint

- **`flutter analyze` reporta 49 advertencias preexistentes.** T-08 no añadió ninguna. No se tocan ahora: la Definición de Terminado exige «sin advertencias **nuevas**», no cero absoluto. Quedan registradas para **TC-01**, la revisión de calidad de octubre, donde habrá que reportarlas o reducirlas.
- **RF-020 encontrado ya implementado** en el commit `cb1861f` del 2 de febrero. Se cierra con el ajuste menor T-21 y se reporta en la revisión del 29 de agosto.
- **`kStackWeightLimitKg = 90000` es un supuesto, no un dato del BAPLIE.** El formato no transmite el límite estructural de apilamiento del buque ni de la terminal — eso vive en el *lashing plan* o en el manual de estabilidad, fuera del alcance del proyecto. El valor quedó documentado como PROVISIONAL en el propio código. **Carlos debe disclosurarlo en la revisión del 29 de agosto** como una limitación conocida del alcance (no como un defecto): el indicador es una alerta orientativa con un umbral de ejemplo, no un cálculo de ingeniería estructural certificado.
- **`export_service.dart` no añadió dependencias nuevas.** CSV y JSON se resuelven con lo ya presente en el proyecto (serialización propia de las entidades más `file_picker` para el guardado), reforzando el mismo argumento de H4 registrado en 10.1 para T-12.
- **Fuentes Roboto embebidas como asset (T-09…T-12), no como dependencia.** Se tomaron del SDK local de Flutter porque la fuente por defecto (Helvetica) no garantiza Unicode, y el reporte necesita acentos y ñ del español. `pubspec.yaml` solo declara los dos archivos `.ttf` como `assets`; `pubspec.lock` no cambió. Vale la pena que Carlos lo tenga listo para explicar en la defensa si preguntan por qué el PDF embebe tipografía.

---

### 10.10 · Corrida real de medición H5 — 30 eventos ✅ completada (25 de agosto, hora de Guatemala)

**Objetivo.** Ejecutar la serie real de medición de H5 contra las reglas ya publicadas y verificadas (§10.9): 30 eventos, condición **C1**, mismo par de clientes que la verificación — Android (POCO X3 NFC, por depuración USB) como receptor, Chrome Web como emisor.

> Si el instrumento aprobado de la tesis exige repartir estos 30 eventos entre C1 y C2 (o correr ambas condiciones hoy), Carlos debe decírselo a Codex explícitamente antes de empezar — esta sección asume solo C1 porque es la condición ya verificada, no una decisión metodológica tomada por el agente.

**Pre-requisitos ya cumplidos, no repetir:**
- Reglas publicadas y verificadas contra el protocolo real (§10.9): 3/3 eventos cerraron correctamente.
- Colección `latency_test` limpia: 66/66 documentos históricos con `respondido: true`, cero pendientes. No hace falta purgar nada antes de correr.

**Tarea para Codex, en orden:**

1. **Inspeccionar `lib/latency_test_screen.dart`** (archivo congelado, no modificar) para confirmar si ya existe un mecanismo en la UI para disparar una ráfaga de N eventos, o si cada evento requiere una interacción manual por evento en cada cliente.
2. **Si no hay automatización nativa en la UI**, proponer un mecanismo externo que no toque el archivo congelado — por ejemplo, un script que dirija `adb shell input tap` a las coordenadas del botón de emitir evento en el cliente Android, corrido en bucle con una pausa de 2-3 segundos entre disparos para no encimar eventos ni saturar el listener del receptor. Si el script se guarda como archivo nuevo en el repo (recomendable para que la corrida sea reproducible ante la defensa), Codex lo redacta y entrega a Carlos el bloque de comandos de `git add`/`commit` de siempre — no lo ejecuta él.
3. **Dry run de 2-3 eventos primero**, igual que se hizo para verificar la regla — confirmar que cierran (`respondido: true`) antes de lanzar los 30 completos.
4. **Correr los 30 eventos reales de condición C1.**
5. **Registrar localmente**: hora de inicio y fin de la corrida, y cuántos de los 30 cerraron exitosamente contra cuántos quedaron en `respondido: false` o dieron error.

**Restricciones que se mantienen (no son nuevas, ya rigen desde el inicio del sprint):**
- No modificar `latency_test_screen.dart` ni `firestore.rules`.
- No ejecutar `firebase deploy`.
- No ejecutar `git add`/`commit`/`push` — solo redactar el bloque para Carlos.
- No reintentar un evento ya cerrado (la regla lo bloquea de todas formas: `resource.data.respondido == false` es requisito para el `update`).

**Formato de reporte esperado:** igual que los bloques anteriores del sprint — qué se hizo, con qué mecanismo se disparó cada evento, el conteo de éxitos/fallos de los 30, el rango de timestamps de la corrida, y si hubo o no cambios de archivos (y por tanto si hay o no un bloque de commit que darle a Carlos).

**Verificación posterior (la hace Carlos, no Codex):** entrar a la consola de Firestore → `latency_test` → confirmar que aparecen 30 documentos nuevos con `respondido: true` y marca de tiempo de hoy, antes de registrar esta corrida como cerrada.

#### Resultado ✅

**La pantalla ya traía automatización nativa** — un campo N que dispara un bucle secuencial, esperando el cierre de cada evento antes de lanzar el siguiente, con 5 segundos entre disparos. No hizo falta `adb shell input tap` ni ningún script nuevo; no hay archivos ni commit pendientes de esta tarea.

| | |
|---|---|
| Topología | POCO X3 NFC (`5d0750b5`) receptor · Chrome Web emisor · condición C1 |
| Dry run | 3/3 cerrados |
| Corrida real | **30/30 cerrados, 0 fallos** — los 30 con `t1_ms`, `proceso_b_ms` y `respondido:true` completos |
| Ventana | 25/08/2026, 18:35:56.414 a 18:38:44.116, hora de Guatemala · 167.702 s hasta el último cierre |
| RTT observado | 514 a 1570 ms — los 30 por debajo de 3 s |

**Nota de fecha:** el encabezado de esta sección decía 26 de agosto porque así marcaba el reloj de la sesión en UTC; la corrida ocurrió el 25 de agosto en hora de Guatemala. Verificado contra los timestamps crudos del log (`LATENCY_CSV:30,C1,1787704723422,1787704724116,0.067,1`): `1787704724116` ms convierte exactamente a `2026-08-25T18:38:44.116-06:00`, coincide al milisegundo con el cierre reportado. El detalle lo señaló el propio Codex antes de que Carlos lo reportara — buena señal de que está leyendo sus propios logs con cuidado.

Hubo rechazos sobre estados históricos de la caché local del receptor durante la corrida; ninguno correspondió a los 30 eventos nuevos y no hubo timeouts.

**Verificación independiente (Carlos, en consola, 25-ago):** contó los documentos de `latency_test` uno por uno. **99 en total, los 99 con `respondido:true`** — exactamente 66 (histórico) + 3 (dry run) + 30 (corrida real). Cuadra.

La instrumentación de H5 tiene ahora una serie real de N=30 bajo C1, además de las 3 de la verificación de reglas. Queda pendiente, para un incremento futuro, correr la condición C2 si el instrumento de la tesis la requiere — no se ejecutó en esta corrida.
