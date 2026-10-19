# T-110 · Diagnóstico y condición de parada

Capitán Codex · 18-oct-2026 · **Detenida antes de editar código.**
No implementada, no aceptada, sin commit.

## Control previo de HEAD

Se ejecutó primero `git log --oneline -3`, con este resultado:

```text
51c5e8e Sprint 3: T-99 fase A, instrumentos de RNF-001, 007, 005 y 003 con integration_test y emulador API 26
d2095fe Sprint 3: decision 10.86, T-99 fase A entregada, scroll con FrameTiming, Windows a 1920x1080 y Android sin no-pub
d4253ff Sprint 3: decision 10.85, T-108 y T-109 aceptadas salvo el Honor, piso 994 y nace T-110
```

El orden cumple la instrucción de Carlos. Se leyeron AGENTS.md, la ficha
completa de T-110 y las decisiones 10.85 y 10.86. El piso exigido es **1016**,
según la actualización directa de Carlos y 10.86; no 994.

## Condición de parada encontrada

La ficha dice literalmente:

> el perfil de algún buque del corpus no permite saber sus bahías.

El modelo actual no contiene un inventario completo de bahías del buque:

- `lib/features/vessel/domain/entities/vessel_profile.dart:15`: geometría,
  declaraciones de tapas, observaciones de bodega y tomas de reefer. No hay
  lista completa de bahías ni marca que declare completa una lista observada.
- En las líneas 18–19, `observedHoldBayNumbers` se define expresamente como
  **«Cota inferior observada en los planes; no declara tapas ni bodegas vacías»**.
  No permite afirmar que una bahía totalmente vacía exista, ni que todas las
  bahías sobre cubierta tengan bodega.
- `lib/features/vessel/domain/entities/vessel_geometry.dart:67`: la geometría
  guarda filas y niveles, parámetros de zona y límite de peso. No contiene
  números de bahía ni rango longitudinal. `covers()` (línea 136) comprueba
  fila y nivel, sin determinar qué bahías existen.
- `hatchCovers` guarda declaraciones por bahía; no es un inventario completo
  ni existe garantía de que sus claves enumeren todas las bahías del casco.

Confirmar el perfil no añade ese dato ausente. El impedimento afecta al
modelo común de los perfiles, incluidos los que se proponen para el corpus;
no se trata de haber encontrado un dato desconocido en un almacén particular.
No se consultaron perfiles del almacén real ni Firebase.

## De dónde sale el salto de A07: 18 a 21

El origen está en dos reconstrucciones distintas del mismo mapa:

1. `baplie_parser_service.dart:919`, `_organizeBays()`, crea bahías a partir de
   los contenedores con posición. El parser suma además las reservas.
2. `vessel_voyage.dart:195`, `neighborOccupiedSlots()`, proyecta cada 40/45
   de una par B sobre las impares B−1 y B+1.
3. `vessel_voyage.dart:154`, `withGeometry()`, añade al mapa las bahías
   vecinas con esa huella física, aunque no tengan carga propia. Ese camino
   también se usa al publicar un viaje con el perfil confirmado
   (`vessel_providers.dart:310`).
4. Al leer lo guardado, `VesselVoyage.fromJson()` vuelve a crear las bahías
   desde contenedores cuando no hay mapa histórico (línea 435), y añade las
   sombras **incluso sin geometría** (línea 474). Esto sucede antes de que
   `openRecentVoyage()` consulte el perfil vigente.
5. El selector consume las claves de ese mapa, ordenadas por número
   (`bay_plan_view.dart:70`).

Por tanto, el aumento al reabrir procede de **huellas de carga vecina**, no
de una lista completa del perfil. Las cifras 18 y 21 son las documentadas en
10.85 y en la ficha; no se volvieron a medir en esta ronda, al activarse la
condición de parada. No se presentan como una corrida nueva del corpus.

Hay otro conjunto de 21 en `tool/t56_corpus_test.dart:29`: las bahías **con
bodega observada en A07 ∪ A08**, cotejadas con posiciones y sombras. Ese
conjunto tampoco declara todas las bahías del casco y no debe confundirse
con el total longitudinal del selector de un solo archivo.

Estadísticas ya cuenta bahías con carga propia **o sombra física**
(`vessel_providers.dart:632`), excluyendo las que solo tienen reservas.
Ese contrato también debe conservarse; cambiarlo a «solo contenedores
propios» alteraría las cuentas anteriores.

## Decisión necesaria para continuar

No hay una fuente en el perfil que permita construir y probar una bahía del
buque completamente vacía en los archivos. Inventar una secuencia de 1 al
máximo observado no resuelve el problema: asumiría bahías y continuidad que
el perfil no declara.

Hay dos vías concretas para que Carlos y Yov ajusten la ficha:

- **Acotar T-110 a las bahías con evidencia:** carga propia, sombras físicas y
  reservas, aplicando la misma regla al leer y reabrir. Se puede plantear sin
  introducir un inventario nuevo, pero no cumple «todas las bahías del buque».
- **Mantener todas las bahías del buque:** aportar o permitir declarar un
  inventario completo por buque y definir su fuente y conservación. El modelo
  actual no tiene dónde guardarlo; requiere revisar la restricción de «no
  tocar lo guardado» antes de implementar. No se propone cambiar el codec de
  forma implícita ni se ha iniciado ese cambio.

## Qué quedó hecho y qué falta

Hecho: control de commits, lectura de ficha/decisiones y diagnóstico del
origen del mapa al leer, confirmar geometría y reabrir desde Recientes.
Único archivo nuevo de esta tarea: **`docs/T110-RESULTADOS.md`**.

No se modificó `lib/`, `test/`, ningún instrumento ni archivo del producto.
`pubspec.yaml` y `pubspec.lock` **sin cambios de Codex**. La consulta de lectura
`git diff --stat -- lib test pubspec.yaml pubspec.lock` no mostró diferencias.
No se ejecutó Git de escritura.

Quedan sin implementar: regla única y bahía vacía, sus pruebas `test/t110_*`,
los dos textos de T-108 y su prueba de kilos enteros. Se detuvo también ese
trabajo independiente para respetar el «detente y avisa» de la ficha.

**No se ejecutaron suite, analyze, corpus ni clientes en esta ronda.** El piso
1016 es el declarado en 10.86; este informe no lo presenta como una validación
propia ni afirma una suite verde ejecutada. No hubo cambios de código a medio
hacer. No se generaron salidas de corpus ni se incluyeron datos del corpus en
el repositorio.

Windows y Web con namespace t110 quedan pendientes después de resolver la
fuente de bahías. El Honor queda para la ronda de mañana según Carlos; no se
usó. No se abrió ninguna BayStream ni se tocó el almacén real,
«PRUEBA T-105», `C:\Proyectos\baystream-demo17\` o los documentos ajenos.
Sin Firebase, CLI, consola ni lecturas; sin capturas de cuentas ni credenciales.

## Tres líneas para Carlos

El commit de T-99 Fase A existe y está encima de d2095fe.
Las 21 al reabrir proceden de sombras físicas, no de un inventario del perfil.
La ficha exige detenerse: solo se escribió este informe; no hay cambios en lib.

## Git preparado para Carlos

Este bloque versionaría **solo el diagnóstico**, no una implementación de
T-110. No declara terminada la tarea. No requiere `-f`.

```powershell
git add -- docs/T110-RESULTADOS.md
git commit -m "Sprint 3: Documenta impedimento de T-110 en el perfil"
git push
```

## Mensaje para Yov

HEAD cumple: 51c5e8e (T-99 Fase A), d2095fe y d4253ff, en ese orden.
T-110 se detuvo antes de editar código por la tercera condición de su ficha.
Las 21 de A07 al reabrir vienen de neighborOccupiedSlots y fromJson, no de una lista del perfil.
VesselProfile y VesselGeometry no guardan inventario completo de bahías; observedHoldBayNumbers es solo una cota inferior de bodega.
Unificar la evidencia del archivo es posible, pero no equivale a mostrar todas las bahías vacías del casco.
Hace falta acotar la ficha a esa evidencia o definir el inventario completo y revisar cómo se conserva.
Solo se creó docs/T110-RESULTADOS.md; no cambié lib/test/pubspec ni corrí suite, analyze, corpus o clientes.
Windows, Web y Honor pendientes; sin Firebase, almacén real, demo17 ni PRUEBA T-105.
