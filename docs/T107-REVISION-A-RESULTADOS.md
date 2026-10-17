# T-107 parte A · Revisión rápida de Capitán Codex

**Resultado: PASA la revisión rápida previa a recompilar la demo.** Base exacta: `24145885d07d1b111c38d59905e4c603097d1571`, padre `b0aac2e882ba7c5f81243c03036ecd3acd516769`. Revisión del 16-oct-2026, según 10.77. **No es la aceptación completa de T-107:** los clientes y la parte B quedan para después de la demo.

## 1. Alcance y aislamiento

- Se leyeron `AGENTS.md`, la sección 2, la ficha de T-107 y las decisiones 10.77–10.78 de `SPRINT-3.md`, además del informe de Timonel.
- Copia nueva fuera del árbol, sin `.git`: `C:\Users\Giova\AppData\Local\Temp\baystream-t107cx-2414588-20261016`, con **650 archivos** obtenidos mediante `git ls-files` y `git show` del commit exacto. No se leyó ni copió `android/key.properties` ni la configuración local de Claude.
- Los casos propios quedaron escritos antes de leer `test/t107_header_test.dart`: `evidence/casos-previos.md`, SHA-256 `8a93b7463d8ff0aec6c0d511c76f801733cb3dc0f59e1b05209723381896de7b`.
- Sin dispositivos, sin abrir Windows, Honor o Web y sin tocar los clientes `demo17`. No se usó Firebase ni su configuración privada. Los datos de widget son sintéticos; no se afirma haber probado A07 en esta revisión rápida.
- Los comandos de Flutter corrieron uno por uno, comprobando antes que no hubiera otro proceso activo. No se forzó ningún bloqueo. **Flutter queda libre.**
- No se corrigió ni modificó código del producto. Las pruebas propias y las copias del padre permanecen fuera del repositorio.

## 2. El diff conserva acciones y reglas

El commit cambia solo **dos archivos de producción**, ambos de presentación: `loading_plan_controls.dart` y `loading_controls.dart`. El resto del diff son pruebas, banco e informe. No cambian dominio, datos, modelo, codec, reglas de Firebase, `lib/main.dart`, los dos congelados ni `pubspec.yaml`/`pubspec.lock`. Sin dependencias nuevas.

La extracción de callbacks conserva sus condiciones, argumentos y destinos:

| Control anterior → entrada compacta | Clave conservada | Acción comprobada |
|---|---|---|
| Pendientes por bahía | Sin clave antes y después | Mismo `_table(context)`, habilitado cuando el progreso está disponible |
| Pendientes de descarga | `discharge-table-button` | Mismo `showDischargeTable(context, voyage)` |
| Avance de la operación | `operation-progress-button` | Misma `OperationProgressPage(voyage: voyage)`; conserva el retorno de `OperationCellLink` y `onOperationCell` |
| Solicitudes / bandeja de cambios | `change-requests-button` | Misma `ChangeRequestsPage(voyage: voyage)`, rol, autorización, operación publicada y cuenta de pendientes |
| Asignar vacío | `empty-search` | Mismo `chooseLoadingRow`, con `selectedBay` y `empties: true`; sigue deshabilitado sin listado |
| Nube, ahora como ícono en estrecho | `sync-status-chip` | Mismo `openCloudPage`; conserva estado, ícono y colores semánticos |
| OR / últimos dígitos, todavía visible | `load-search` | Mismo selector, con `selectedBay` y sin `empties: true` |

Referencias de la base revisada: `loading_plan_controls.dart:53` (pendientes), `:58` (avance), `:307` (permisos), `:328` (menú), `:333`–`:363` (entradas) y `:386` (nube); `loading_controls.dart:73` (U+2011), `:79` (OR) y `:100` (vacíos ancho).

El cuerpo completo de `_table`, el código anterior a `LoadingControls` y **todo el archivo desde `chooseLoadingRow` hasta el final** coinciden exactamente con el padre, normalizando CRLF/LF. La lógica operativa de esos caminos no se reescribió. Los **650 archivos exportados** siguen idénticos byte a byte al commit después de las validaciones; esto incluye dependencias y archivos protegidos.

## 3. Las cinco pruebas ajustadas

En cada archivo se retiró exclusivamente el comentario T-107, el toque en `bay-plan-actions`, su `pumpAndSettle` y, cuando corresponde, la condición que limita ese acceso al menú. **El resultado es idéntico al archivo del padre**, sin ningún otro cambio de clave o assert.

| Archivo | Único acceso añadido | Llamadas `expect` antes / después |
|---|---|---:|
| `test/t74_loading_plan_test.dart` | Abrir menú antes de Pendientes por bahía | 39 / 39 |
| `test/t75_discharge_test.dart` | Abrir menú antes de `discharge-table-button` | 54 / 54 |
| `test/t76_loading_widget_test.dart` | Abrir menú solo si `empty` | 20 / 20 |
| `test/t77_load_check_widget_test.dart` | Abrir menú solo si `empty` | 19 / 19 |
| `test/t78_operation_progress_widget_test.dart` | Abrir menú solo si ancho <600: 360 en sus casos; 1920 sigue directo | 12 / 12 |

Son **144 llamadas `expect` conservadas**; no es el número de pruebas de la suite. Evidencia: `audit.json` y los cinco archivos `*.diff.txt` externos.

## 4. Pruebas propias: 21/21

Se ejecutan con Roboto, Material 3 y repositorios de memoria. Ninguna inicializa Firebase ni lee el almacén real. Las pruebas del padre se instrumentan mediante copias externas de sus dos widgets, cambiando solo las rutas de importación necesarias para compilarlos junto a los actuales.

- **8 casos de geometría:** `BayPlanView` real, a **360×780 dp**, en Contenido, Número de orden, Descarga y Carga, con `TextScaler.linear(1.0)` y `TextScaler.linear(1.45)`. Modo, Acciones y nube comparten la primera fila; resumen y OR comparten la segunda en Carga. Sin desbordes. El resumen se abre y recoge; el plano conserva área útil al abrirlo. «re‑estibas» de Carga ocupa una sola línea con U+2011.
- **4 comparaciones de acciones:** ambos roles, muelle/oficina, y ambas letras. Se pulsa cada botón del padre a 1280 y su equivalente actual a 360; se comprueban claves, destinos y el contenido completo de cada destino a igual ancho. Incluyen pendientes, avance, cambios, vacíos, OR y nube. La cuenta pendiente aparece en Acciones; avance devuelve el mismo enlace a su callback. Ninguna acción agrega movimientos a la bitácora de memoria.
- **2 comparaciones de Descarga:** mismo menú, clave y contenido de la tabla que en el padre, con ambas letras.
- **4 comparaciones a 1280 dp:** los cuatro modos conservan exactamente los rectángulos de los controles, tipos de botones, claves y textos del padre, salvo la sustitución prevista del guion de «re‑estiba» por U+2011. No aparecen Acciones ni resumen plegable.
- **3 casos de condiciones:** sin sesión, operación sin publicar y cuenta no autorizada; el control de cambios sigue ausente y la asignación de vacío sigue deshabilitada cuando falta listado, como en el padre.

Geometría medida con el resumen recogido, en dp:

| Modo | Letra | Alto del encabezado | Alto útil de rejilla |
|---|---:|---:|---:|
| Contenido / orden / Descarga | 1.0 | 76 | 589.8 |
| Carga | 1.0 | 104 | 561.8 |
| Contenido / orden / Descarga | 1.45 | 90 | 552.0 |
| Carga | 1.45 | 109 | 533.0 |

Se supera el mínimo de **390 dp** de rejilla a 1.0 y **260 dp** a 1.45. Son medidas de widget con datos sintéticos y escala lineal; no se atribuyen a un cliente del Honor ni a A07.

**Incidencia propia, corregida solo en la prueba externa:** la primera comparación de destinos encontró distinto orden de textos en Avance porque comparaba su vista responsiva a 1280 con la de 360. Los controles sí abrían la misma pantalla. Se conservó ese registro en `own-first.log`; la prueba final pulsa las acciones a sus anchos originales y compara el destino a un mismo ancho, manteniendo la comparación completa de textos y el retorno del enlace. Resultado final **21/21**, sin skip. No se cambió el producto ni una prueba del repositorio.

## 5. Validaciones ejecutadas

| Comando, en la copia de `2414588` | Resultado |
|---|---|
| `flutter pub get --offline` | Correcto; `pubspec.yaml` y `pubspec.lock` idénticos a la base |
| `flutter test --no-pub --reporter expanded` | **922/922**, sin skip |
| `flutter test --no-pub evidence/t107cx_review_test.dart --reporter expanded` | **21/21**, sin skip |
| `flutter analyze --no-pub` | **0 incidencias**, incluidas las evidencias Dart externas |

No hay `// ignore` ni `skip:` en los Dart de `lib/`, `test/`, `tool/` o las evidencias propias de esta copia. Los registros se conservan en `evidence/{suite,own,analyze}.log`, con `audit.json`, `final-audit.json`, `own-metrics.json` y `validation-*.json`. Todo está en `%TEMP%`; no se incorporan fuentes del corpus ni salidas al repositorio.

**No se ejecutó corpus en esta revisión rápida**, porque no cambian reglas y no lo pide este alcance. Tampoco se compilaron ni abrieron clientes, ni se ejecutó `flutter test --platform chrome`. La aceptación completa con clientes y lo restante de la parte B siguen pendientes según 10.77. No se encontraron defectos de la parte A.

## 6. Entrega y Git para Carlos

**Único archivo propio colocado:** `docs/T107-REVISION-A-RESULTADOS.md`, sin commit. No se edita el informe de Timonel ni se coloca código o evidencias Dart en el repositorio. **`pubspec.yaml` y `pubspec.lock` no cambian.**

```powershell
git add -- docs/T107-REVISION-A-RESULTADOS.md
git commit -m "Sprint 3: revision rapida de T-107 parte A"
git push
```

## 7. Tres líneas

PASA la parte A: presentación compacta y U+2011, con las mismas acciones, condiciones y claves; cinco pruebas previas sin cambios adicionales.
Las propias pasan 21/21; la suite completa 922/922 sin skip y analyze en cero, sobre la copia exacta de `2414588`.
Sin dispositivos ni cambios de producto; Flutter libre y la aceptación completa con clientes pendiente después de la demo.

## 8. Mensaje para Yov

PASA

Revisión rápida de T-107 parte A sobre `2414588`: solo presentación, acciones y claves conservadas, y las cinco pruebas previas solo agregan el acceso a Acciones. Pruebas propias 21/21 a 360×780 con letra 1.0/1.45 y comparación directa con el padre a 1280; suite 922/922 sin skip y analyze 0. La rejilla de Carga deja 561.8/533.0 dp en esos casos. Sin defectos encontrados, sin dispositivos ni cambios de producto. Flutter libre para que Timonel continúe la recompilación según 10.77; los clientes y la aceptación completa van después de la demo. Informe colocado sin commit en `docs/T107-REVISION-A-RESULTADOS.md`.
