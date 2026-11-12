# T-144 · Aceptación de Capitán Codex

**Dictamen: NO PASA.** El paso 0 pasa completo, pero la sonda independiente del punto 4 encuentra un **P2: una consulta de solo espacios devuelve contenedores cuando tienen puerto o naviera**. Se detiene la aceptación al confirmar el primer fallo, conforme al encargo. No se corrigió código.

Fecha: **11-nov-2026**, horario de Guatemala (UTC−06:00). Carpeta: `C:\Proyectos\baystream-qa-r4`, HEAD separado en `2d91c54ae556f6a131c0b5c672b2419d03df1e1a`. Evidencia propia: `build/t144/aceptacion/`, ignorada por `/build/`.

## 1. Lecturas y preparación

Se leyeron los `CLAUDE.md` y `AGENTS.md` vigentes de `C:\Proyectos\baystream-rediseno`; SPRINT-4 10.109, 10.112, 10.117, 10.121, 10.123 y 10.124; y `docs/T144-RESULTADOS.md` completo, incluidas la propuesta y la fase 2. Se consultó la aceptación de T-143 para reproducir su preparación aislada. Se aplicó la skill `dart-run-static-analysis` únicamente para verificar, sin correcciones automáticas, exclusiones ni supresiones nuevas.

Carlos reservó **solo Windows**. El Honor no estaba disponible. No se utilizó ninguno de los dos y la reserva de Windows se liberó al detenerse. Se avisó con líneas `SEMÁFORO:` al ocupar y liberar el carril. Todos los comandos de Flutter/Dart de esta aceptación fueron consecutivos.

La copia nueva está en `build/t144/aceptacion/copia/`: **838/838 archivos cotejados por SHA-256**, con `lib/`, `test/`, `tool/`, integración, plataformas y recursos. Incluye los manifiestos y recursos Android que necesita la suite. Se omiten credenciales y artefactos de compilación anteriores.

Como en T-143, se recuperó la entrada **sintética** generada `build/t124/entradas/t124_entradas.dart` del banco anterior. Su SHA-256 es `d4384834fb9fc9cb18632b87180a7998cc3f91109edcbd33dbbf9787542d1162`. Es la preparación documentada para O-143-3 (10.121), todavía diferida; no se cambió el análisis para ocultarla. `manifiesto.json` identifica origen y huellas. No se reutilizaron resultados de pruebas anteriores.

Dos invocaciones iniciales del registrador tenían los argumentos en orden incorrecto y no llegaron a lanzar Flutter (`FileNotFoundError`). No cuentan como validaciones. La ejecución válida de `pub get` figura como `pub-get` en los registros.

## 2. Paso 0 — PASA

| Comprobación | Resultado propio | Evidencia relativa a `build/t144/aceptacion/` |
|---|---|---|
| `git log --oneline -3` | `2d91c54` (10.124), `35d88db` (T-144), `886fbb0` (10.123), en ese orden | `punta.json` |
| `git show --stat HEAD~1` | Título exacto «Sprint 4: T-144, el lector y el volcado»; 22 archivos, los de §2.7 del informe; 1748 inserciones y 52 eliminaciones | `punta.json` |
| `git show --stat HEAD` | Solo `SPRINT-4.md`, decisión 10.124; 37 inserciones y 1 eliminación | `punta.json` |
| Diff inicial de contenido | `git diff --stat` vacío; solo avisos LF→CRLF en los tres archivos generados de Windows | `punta.json` |
| HEAD separado | El archivo HEAD del worktree contiene el hash, sin referencia de rama | `manifiesto.json` |
| `flutter pub get` | Salida 0; «Got dependencies!»; sin cambios de pubspec | `pub-get.log`, `pub-get-ejecucion.json` |
| `flutter analyze --no-pub` desde la raíz de la copia, todo el paquete | Salida 0; «No issues found!» | `analyze.log`, `analyze-ejecucion.json` |
| `flutter test --no-pub --machine`, suite completa en una sola corrida | **2202 aprobadas, 0 fallidas, 0 omitidas**; salida 0 y evento final `success: true` | `suite.log`, `suite-resumen.json`, `suite-ejecucion.json` |
| `dart run tool/t141_fuzz_baplie.dart` | **180 mutantes, 0 fallas**: 68 leídos y 112 rechazados con mensaje; salida 0 | `fuzz.log`, `fuzz-ejecucion.json`, `copia/build/t141/fuzz-baplie.json` |
| Integridad al cerrar | Origen y copia mantienen los **838/838 archivos** del manifiesto sin diferencias, incluidos ambos pubspec | `integridad.json` |

Las 47 pruebas entregadas de T-144 están incluidas en las 2202; esto no sustituye los recorridos independientes pendientes.

## 3. Puntos de aceptación

Se adelantó la sonda independiente de búsqueda después del paso 0. Al fallar, no se continuó con los demás puntos.

| Punto | Dictamen | Evidencia y límite |
|---|---|---|
| 1. Dos y tres DGS, detalle, Lista y CSV; una DGS como en 1.0.0 | **PENDIENTE** | Las pruebas entregadas pasaron en la suite; no se ejecutó la aceptación propia de este punto. |
| 2. «Destino final» solo con LOC+83, tal cual viene | **PENDIENTE** | Sin recorrido propio; no se acredita por la suite entregada. |
| 3. A06, 717 contenedores, puertos, escala GTPBR y movimientos locales | **PENDIENTE** | No se leyó A06 ni se registraron movimientos. No se abrió ningún almacén de Windows. |
| 4. Búsqueda «bysu 967» y consulta de solo espacios | **NO PASA** | La consulta de matrícula devuelve el contenedor correcto. Tres espacios devuelven 1 resultado en vez de 0: T144-ACC-01. |
| 5. DIM 5 a 9 en CMT e INH, interfaz y salida idéntica | **PENDIENTE** | Sin aceptación propia ni BAPLIE de salida propio. |
| 6. Avisos UN/LOCODE con causa y acción; excepciones XX y asteriscos | **PENDIENTE** | Sin recorrido propio del resumen. |
| 7. Lectura del viaje nuevo y lista de viajes con código v1.0.0 extraído aparte | **PENDIENTE** | No se extrajo v1.0.0 ni se ejecutó la compatibilidad real. La prueba entregada no se presenta como sustituto. |
| 8. Windows r4, Chrome visible y Honor a 360 dp, escalas 1.0/1.45/2.0 y español | **PENDIENTE** | No se compilaron ni abrieron clientes. Honor no disponible; no hay capturas de aceptación. |

## 4. T144-ACC-01 · P2 · Solo espacios encuentra contenedores con puertos

**Requisito incumplido:** punto 4 del encargo: «una consulta de solo espacios no encuentra nada».

**Reproducción independiente:**

1. La sonda `copia/build/t144acc/busqueda_test.dart` escribe dentro del propio archivo un BAPLIE 2.x sintético de un contenedor: `BYSU 9672095`, puerto de carga `GTSTC`, descarga `PAMIT`, buque `BUQUE SINTETICO`. La matrícula procede del ejemplo del encargo, no del corpus.
2. Lo interpreta con `BaplieParserService` real y comprueba matrícula `BYSU9672095` y ambos puertos.
3. Renderiza `ContainerSearchDelegate.buildResults` real, dentro de `ProviderScope` y del tema del producto, con la consulta `bysu 967`: obtiene **1 resultado**, correcto.
4. Renderiza la misma búsqueda con tres espacios ASCII (`[32, 32, 32]`): obtiene **1 resultado**, esperado **0**. No hubo excepción de renderizado; falla la expectativa funcional.

Comando para reproducir, con el carril de Flutter libre:

```powershell
# Desde C:\Proyectos\baystream-qa-r4\build\t144\aceptacion\copia
C:\flutter\bin\flutter.bat test --no-pub --machine build/t144acc/busqueda_test.dart
```

**Resultado ejecutado:** salida 1, un caso aprobado y uno fallido, ninguno omitido. `busqueda.log` contiene:

```text
T144ACC consulta=[98, 121, 115, 117, 32, 57, 54, 55] resultados=1 puertos=GTSTC/PAMIT
T144ACC consulta=[32, 32, 32] resultados=1 puertos=GTSTC/PAMIT
Expected: <0>
  Actual: <1>
Una consulta de solo espacios no debe encontrar nada.
```

**Causa comprobada por lectura:** `lib/features/vessel/presentation/widgets/container_search_delegate.dart:77` solo comprueba `query.isEmpty` antes de normalizar. En las líneas 81–92, la consulta se convierte en `''`; `matchesId` sí exige texto, pero `matchesPod`, `matchesPol` y `matchesOperator` todavía usan `contains(normalizedQuery)` sin esa condición. Cualquier puerto o naviera no nulos coincide con `contains('')` y hace verdadero el filtro.

**Impacto y prioridad:** la búsqueda presenta coincidencias para una consulta que no contiene ningún término. Incumple un criterio explícito de aceptación; **P2**, sin evidencia de pérdida de datos ni de caída de la app. La suite verde no cubre esta condición.

**Corrección propuesta para Timonel, sin implementarla:** impedir la búsqueda con una consulta vacía tras normalizar, antes de evaluar cualquier campo, y fijar el caso con puertos y naviera declarados en una prueba permanente. Mantener el caso positivo de matrícula con espacios. Después, retomar esta aceptación y sus puntos pendientes.

Evidencia: `busqueda.log`, `busqueda-stderr.log`, `busqueda-resumen.json`, `busqueda-ejecucion.json` y la sonda completa citada. Es una prueba de widget ejecutada; no se afirma que sea una captura o un recorrido de Windows, Chrome u Honor.

## 5. Horas y límites de la ejecución

Todas las horas son del **11-nov-2026, Guatemala**; los JSON guardan UTC.

| Actividad | Inicio | Fin |
|---|---|---|
| Primera hora de preinspección registrada | 23:00:48 | — |
| `pub get` válido | 23:02:15 | 23:02:19 |
| Análisis completo | 23:02:25 | 23:03:21 |
| Suite completa | 23:03:32 | 23:07:58 |
| Fuzzing | 23:08:07 | 23:08:09 |
| Sonda independiente de búsqueda | 23:08:13 | 23:08:20 |
| Cotejo final de integridad | 23:08:47 | 23:08:47 |
| Cierre del informe | 23:10:44 | 23:10:44 |

Son horas de ejecución, **no mediciones H5**. La aceptación se detuvo al comprobar la falla de búsqueda; después solo se cerró la evidencia y se redactó este informe.

No se ejecutaron `git status`, escrituras de Git ni publicaciones. No se contactó Firebase real, no se abrió el corpus y no se copió ningún dato del corpus al repositorio. No se usó el almacén predeterminado, el real ni uno con namespace `t144acc`: la prueba fallida no requiere persistencia. No hay movimientos que limpiar. La aceptación de persistencia y su comprobación fuera del paquete siguen pendientes.

## 6. Archivos y Git para Carlos

**Único archivo versionable creado:** `docs/t144/aceptacion-codex.md`.

**Código de producto, pruebas permanentes y configuración:** sin cambios. **`pubspec.yaml` y `pubspec.lock` no cambian**, ni en el origen ni en la copia. No se tocaron los congelados, `lib/main.dart`, opciones Firebase ni `.claude/settings.local.json`.

El instrumental, la sonda, la copia y los registros nuevos están exclusivamente bajo `build/t144/aceptacion/`, excluido por `/build/`. Se conservan localmente para reproducir el hallazgo; no se propone forzar su incorporación a Git. Los manifiestos y registros citados identifican su contenido.

Este bloque versiona **solo el informe de NO PASA**; lo ejecuta Carlos desde `qa-r4`:

```powershell
Set-Location C:\Proyectos\baystream-qa-r4
git add -- docs/t144/aceptacion-codex.md
git commit -m "Sprint 4: aceptacion de T-144"
git push origin HEAD:sprint-4
```

## 7. Tres líneas

1. El paso 0 pasa: punta exacta, análisis cero, suite 2202/2202 sin omitidas y fuzzing 180/0.
2. T144-ACC-01 (P2): una búsqueda de solo espacios aún encuentra contenedores con puertos; no se corrigió código.
3. T-144 NO PASA; quedan pendientes los demás recorridos, la vuelta real a v1.0.0 y los tres clientes.

## 8. Mensaje para Yov

> Yov, T-144 NO PASA sobre 2d91c54 en qa-r4. Paso 0 completo: 22 archivos exactos de 35d88db y solo 10.124 encima; analyze cero, 2202/2202 sin omitidas y fuzzing 180/0. La sonda propia confirma T144-ACC-01, P2: «bysu 967» encuentra BYSU9672095, pero tres espacios devuelven 1 resultado cuando hay puertos, esperado 0; los filtros de puertos/naviera hacen contains('') sin protección. Me detuve sin corregir código ni abrir clientes, corpus o almacenes. Informe: docs/t144/aceptacion-codex.md; evidencia local: build/t144/aceptacion/. Windows liberado; Honor no estaba disponible. Quedan pendientes los demás recorridos y la lectura real con v1.0.0.
