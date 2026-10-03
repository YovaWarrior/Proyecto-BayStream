# BayStream · Sprint 2 — instrucciones de implementación

**Ventana:** 19 de septiembre → 17 de octubre de 2026 · **26 tareas · 35.0 h netas**
**Entrega del curso:** 17-oct, Presentación del Incremento 2 + Seguridad y calidad (10 pts).

Este archivo es la fuente de verdad del sprint en curso. Sustituye a `SPRINT-1.md`
como brief activo; `SPRINT-1.md` queda como bitácora cerrada y se conserva.

Los acuerdos permanentes están en `AGENTS.md` y siguen vigentes sin repetirse aquí.
Lo que sigue son las restricciones y el alcance **de este sprint**.

---

## 1. Contexto del proyecto en diez líneas

1. BayStream lee archivos **BAPLIE/EDIFACT** y dibuja el plano de estiba de un buque portacontenedores.
2. Flutter, una sola base de código para **Windows, Android y Web**. Ese ahorro es la hipótesis H4 de la tesis.
3. Arquitectura limpia bajo `lib/features/vessel/` (domain · data · presentation) con **Riverpod**.
4. El Sprint 1 cerró el 25 de agosto: 18 tareas, 5 requerimientos, 7 commits.
5. Entre el 31 de agosto y el 9 de septiembre se corrigieron **siete defectos de fondo** (C‑1 … C‑7) detectados al contrastar el plano de BayStream contra el plano impreso real del buque MIZAR. Están documentados en `docs/HALLAZGOS-PLANO-REAL.md`.
6. Hoy la aplicación **parametriza la geometría del buque**: propone una rejilla deducida del archivo y el usuario la confirma o la corrige antes de dibujar.
7. Las pruebas pasaron de 21 a **138**. Ese crecimiento es evidencia de tesis; no se retrocede.
8. Lo que falta es lo que este sprint ataca: **la geometría confirmada se olvida al cerrar el viaje**.
9. El repositorio es evidencia de las hipótesis H4 y H5. El historial lo firma el autor, no una herramienta.
10. Flutter **no está instalado** en el contenedor del agente. Compilar y correr pruebas es trabajo del autor, en Windows.

---

## 2. Restricciones duras — leer antes de tocar nada

Estas no son preferencias de estilo. Romper cualquiera daña la tesis.

### 2.1 Archivos congelados — NO TOCAR

```
lib/latency_test_screen.dart          ← instrumentación de la hipótesis H5
lib/c3_reconciliation_screen.dart     ← instrumentación de la hipótesis H5
```

Su contenido está congelado en la etiqueta `m2-baseline`, el estado sobre el que se
ejecutó el conteo de `cloc` que sostiene H4. **No las muevas, no las renombres, no las
borres, no las refactorices.** Si te estorban, ignóralas.

### 2.2 Credenciales de Firebase — esta es la única restricción que se levanta

En `SPRINT-1.md` estaban intocables. **En este sprint sí se tocan, pero solo en T‑47**,
y bajo tres condiciones que no son negociables:

1. **El proyecto temporal `baystream-h5-temporal-20260814` no se borra ni se vacía.**
   Ahí viven los 99 documentos de la colección `latency_test` que sostienen H5. Si en la
   defensa piden repetir C1/C2, ese proyecto tiene que seguir en pie. El proyecto de
   producción es **otro** proyecto, no una migración del anterior.
2. **Las pantallas congeladas siguen escribiendo donde escriben hoy.** Si la creación del
   proyecto de producción obliga a cambiar `lib/main.dart`, el cambio no puede alterar el
   comportamiento de `latency_test_screen.dart` ni de `c3_reconciliation_screen.dart`.
   Si descubres que sí lo altera, **detente y repórtalo** antes de escribir una línea.
3. **Tú no creas el proyecto ni publicas nada en la consola de Firebase.** Redactas lo
   que hay que hacer; el autor lo ejecuta. Igual que con git.

### 2.3 Las pruebas deben seguir en verde — 169 al 23-sep

```
test/baplie_parser_test.dart          40      test/export_service_test.dart          9
test/vessel_geometry_test.dart        42      test/vessel_geometry_page_test.dart   20
test/bay_plan_grid_test.dart          17      test/baplie_reefer_parser_test.dart    3
test/pdf_report_service_test.dart      3      test/vessel_profile_view_test.dart     3
test/container_search_delegate_test.dart 1    test/widget_test.dart                  1
```

**El piso sube y nunca baja.** 138 al abrir el sprint, 139 tras T‑51, **169 tras el
bloque 2**. El piso de cada tarea es el número con que cerró la anterior.

**El piso es el que imprime `flutter test`, no el que cuenta un `grep`.** Hoy hay 164
ocurrencias estáticas de `test(`/`testWidgets(` en catorce archivos y la corrida reporta
169: la diferencia son pruebas registradas dentro de un bucle, que existen en ejecución y
no en el texto. La cifra de la tesis es la de la corrida.

Si una prueba se rompe, el arreglo es parte de la tarea que la rompió — no se comenta ni
se marca como `skip`. **Ojo con `vessel_geometry_test.dart`: 42 pruebas sobre la entidad
que este sprint modifica más.** Si una de ellas deja de tener sentido porque el contrato
cambió, se reescribe y se dice explícitamente en el reporte cuál y por qué. Borrar una
aserción sin decirlo es el defecto 15 del cruce de auditorías otra vez.

### 2.4 Arquitectura limpia — con una regla nueva

```
lib/core/                          utilidades, constantes, errores
lib/features/vessel/domain/        entidades y contratos            ← sin imports de Flutter
lib/features/vessel/data/          parser, Firestore, almacén local
lib/features/vessel/presentation/  páginas, widgets, providers
```

- La presentación **no accede a fuentes de datos**; pasa por el repositorio.
- El dominio **no importa `package:flutter/*`**. Es Dart puro con `equatable`.
- **Regla nueva de este sprint:** el motor de almacenamiento local que elija T‑35 vive en
  `data/`, detrás de un contrato declarado en `domain/repositories/`. `VesselProfile` es
  una entidad de dominio y **no puede importar el paquete de almacenamiento**. Si la
  entidad necesita una anotación del paquete para serializarse, el paquete está mal
  elegido: vuelve a T‑35.

### 2.5 Convenciones

- **Todo en español**: interfaz, comentarios, mensajes de commit y nombres de prueba.
  Identificadores de código en inglés, como está hoy.
- **Material 3**, tema oscuro. `Theme.of(context).colorScheme`, nunca colores literales.
- **Una sola dependencia nueva autorizada en todo el sprint**: la de almacenamiento local
  de T‑35. Ninguna más, por ningún motivo. Cada dependencia que no agregas es evidencia a
  favor de H4.
- `flutter analyze` sin advertencias **nuevas** hasta T‑43; a partir de T‑43, sin
  advertencias.

### 2.6 Git: tú redactas los comandos, **no los ejecutas**

Sin cambios respecto al Sprint 1. **No ejecutes `git add`, `git commit`, `git push`,
`git tag`, `git checkout`, `git restore` ni `git status`.** Escribe el código, deja los
archivos en el árbol de trabajo y detente. Entrega el bloque de la sección 9.2 para que
el autor lo ejecute.

Lecturas permitidas: `git log --oneline -5`, `git diff --stat`, `git show --stat`.
**Nunca `git status`**: en este repositorio deja un `index.lock` que después no se limpia.

### 2.7 La consola de Firebase tampoco se toca

Las reglas de Firestore se **redactan** en `firestore.rules` y las **publica el autor**
desde la consola. T‑45 escribe reglas; no las despliega. Y antes de proponer cualquier
regla nueva, contrástala contra el código que va a gobernar: la lección de T‑23 es que una
cláusula general de denegación puede inhabilitar funcionalidad legítima **en silencio**,
sin error de compilación ni prueba fallida.

---

## 3. Objetivo del sprint

> Que la aplicación deje de **inferir** el buque y pase a **conocerlo**: que la geometría
> real se declare una vez, se recuerde entre viajes, y sirva de base para validar la
> posición antes de que la grúa coloque el contenedor.

Si el tiempo se agota, ese enunciado decide qué se sacrifica. Lo que no sirva a recordar
el buque ni a validar la posición, se corta.

---

## 4. Alcance: 6 elementos, 26 tareas, 35.0 horas

| Elemento | Nombre | Prio. | Pts | Horas | Tareas |
|---|---|---|---|---|---|
| **RF-036** | Perfil de buque persistente *(nuevo)* | SHOULD | 21 | 13.0 | T-24 … T-34 |
| **RF-031+** | Almacén local propio, independiente de la caché | SHOULD | 5 | 3.0 | T-35 … T-37 |
| **RF-027** | Validación de reglas de estiba | COULD | 13 | 8.0 | T-38 … T-42 |
| **TC-01** | Revisión de características de calidad | MUST | 5 | 3.0 | T-43, T-44 |
| **TC-03** | Pruebas finales de seguridad | MUST | 5 | 3.0 | T-45, T-46 |
| **TC-04** | Despliegue en la nube o tienda de aplicaciones | MUST | 8 | 5.0 | T-47 … T-49 |
| | **Total comprometido** | | **57** | **35.0** | **26 tareas** |
| ~~RF-028~~ | ~~Planificación de secuencia de descarga~~ | COULD | 8 | 5.0 | **diferido** |

Capacidad declarada: 27 h por semana × 4 semanas = **108 h brutas**. Descontando
documentación, revisiones y la preparación de la entrega del 17-oct quedan **53 h** para el
backlog de producto, contra 35.0 h comprometidas: **34 % de holgura**. Esa holgura no es
grasa — está reservada para lo que la verificación contra archivos reales destape, que en
este proyecto ya ocurrió siete veces.

### Por qué existe RF-036 y no está en el ERS aprobado

No es alcance nuevo. Es un **habilitante declarado**: la ficha aprobada de RF‑027 dice en
sus observaciones *«Requiere definición de parámetros del buque»*. RF‑036 es esa
definición. Además corrige un defecto en funcionalidad **MUST ya entregada** — el plano
inventaba niveles que el buque no tiene — así que no incorporarlo dejaría un defecto
conocido en producción.

Pertenece a la épica **E5 · Muelle y Planificación**, señalada en el Product Backlog como
la innovación central del proyecto.

### Qué ya está hecho y NO hay que rehacer

Antes de escribir una línea, esto ya funciona y está verificado contra el corpus:

- **La geometría se parametriza por viaje.** `VesselGeometry.proposeFrom` deduce una cota
  inferior desde el archivo y `VesselGeometryPage` deja al usuario confirmarla o corregirla.
- **`deckTiers` y `holdTiers` son `List<int>` editables** con chips quitables (`17d9d49`).
- **La frontera de zona (80) está separada del ancla de cubierta (82)** (`757fb46`), y un
  nivel 80 real ya no se clasifica como bodega (`df0c35b`).
- **Los refrigerados se detectan** por segmento `TMP` y por tipo ISO (`206545c`).
  `ContainerUnit.isReefer` existe (`container_unit.dart:61`).
- **Las mercancías peligrosas se parsean**: `_parseDGS` en
  `baplie_parser_service.dart:755`, y `ContainerUnit` ya lleva `isDangerous`, `imdgClass`
  y `unNumber` (`container_unit.dart:52-58`).
- **`VesselGeometry` ya serializa**: `toJson`/`fromJson` en `vessel_geometry.dart:250-265`.

**Lo que NO existe es la permanencia.** La geometría vive en `VesselVoyage.geometry`
(`vessel_voyage.dart:68`), muere con el viaje, y el siguiente archivo del mismo buque
vuelve a proponer desde cero y a preguntar otra vez. Ese es todo el hueco de RF‑036.

---

## 5. Las tareas

Cada tarea indica el archivo que toca, qué hacer y cuándo está terminada. La «h» es
estimación de codificación neta; sirve para dimensionar, no para cronometrar.

---

### RF-036 · Perfil de buque persistente (13.0 h · T-24 … T-34)

> **Como** planificador de estiba **quiero** declarar una sola vez la geometría real de
> cada buque y que la aplicación la recuerde, **para que** el plano deje de inventar
> niveles que el buque no tiene.

El modelo es el de la industria: el sistema del muelle trae un **perfil por defecto** que
se va moldeando con lo que declara el capitán, y a partir de ahí ese buque ya se conoce.
No es una idea nuestra — el grupo de trabajo **SMDG Vessel Profile** lo declaró como
problema abierto del sector en abril de 2025: no existe formato estándar y las terminales
arman los perfiles a mano desde PDF. El respaldo documental está en el documento de
investigación del proyecto.

**Separación conceptual que gobierna todo el requerimiento:**

| | Vive en | Dura |
|---|---|---|
| **Perfil del buque** — geometría, límite de apilamiento, tomas de reefer | `VesselProfile` | permanece entre viajes |
| **Carga de este viaje** — contenedores, pesos, puertos | `VesselVoyage` | muere con el archivo |

El BAPLIE transmite lo segundo. Lo primero **nunca lo transmite**, y esa es la causa raíz
única de C‑3, C‑4, el nivel 80, los pisos por columna y el `kStackWeightLimitKg`
provisional. Un solo arreglo cierra los cinco.

---

#### T-24 · Entidad `VesselProfile` y su serialización · 1.50 h

**Archivo nuevo:** `lib/features/vessel/domain/entities/vessel_profile.dart`
**Toca:** `entities.dart` (export).

Entidad de dominio con: identidad del buque (ver T‑25), `VesselGeometry`, límite de
apilamiento por pila (T‑29), conjunto de posiciones con toma de reefer (T‑30), origen del
perfil (`plantilla` · `propuesto del archivo` · `declarado por el usuario`) y fecha de
última modificación.

`Equatable`, `copyWith`, `toJson`, `fromJson`, siguiendo exactamente el patrón de
`vessel_geometry.dart:250-265`. Dart puro; sin `package:flutter`, sin anotaciones del
paquete de almacenamiento (regla 2.4).

**El campo de origen no es decorativo.** Es lo que permite decirle al usuario «esta
geometría la propuso el archivo, confírmala» frente a «esta geometría la declaraste tú el
12 de septiembre». Sin él, un perfil propuesto y uno confirmado son indistinguibles, y el
usuario pierde la única señal de cuánto puede confiar en la rejilla que está viendo.

**Terminada cuando:** `toJson` → `fromJson` devuelve una entidad igual (`==`) al original,
con y sin los campos opcionales, y hay prueba de ida y vuelta para ambos casos.

---

#### T-25 · Identificar el buque desde el segmento TDT · 1.00 h

**Toca:** `lib/features/vessel/domain/entities/vessel.dart`,
`lib/features/vessel/data/services/baplie_parser_service.dart:225-250`.

**Esta es la tarea de mayor riesgo del bloque de dominio. Léela entera antes de tocar nada.**

Hoy `Vessel.id` se asigna con `_uuid.v4()` en el parser
(`baplie_parser_service.dart:243`): **un identificador aleatorio nuevo en cada parseo.** El
mismo buque, leído dos veces, produce dos identidades distintas. Con eso, ningún perfil se
puede recuperar jamás. No es un detalle a pulir: es el bloqueo duro de todo RF‑036.

Hace falta una **clave natural**, derivada del contenido del TDT. Verificado sobre los seis
archivos del corpus (`C:\Users\Giova\...\Archivos .EDI\Anonimizados\files\`):

| Archivo | Identificador en el TDT | Calificador | Nombre |
|---|---|---|---|
| A01 | `9000003` | `146` (IMO) | BUQUE ALFA |
| A02 | `9000015` | `146` (IMO) | BUQUE BRAVO |
| A03 | `ZZAB1` | `103` (indicativo) | BUQUE CHARLIE |
| A04 | `9000027` | `146` (IMO) | BUQUE DELTA |
| A05 | `ZZC5603` | `103` (indicativo) | BUQUE ECO |
| A06 | `9000039` | `146` (IMO) | BUQUE ECO |

Dos hechos que salen de esa tabla y que el diseño tiene que resolver:

1. **El IMO no siempre está.** Dos de seis archivos traen solo indicativo de llamada.
   La clave tiene que ser una cadena de preferencias: **IMO → indicativo → nombre
   normalizado**, guardando cuál se usó.
2. **A05 y A06 se llaman igual y traen identificadores distintos.** Mismo nombre, claves
   distintas. Puede ser el mismo buque anonimizado dos veces o dos buques homónimos — y
   **la aplicación no puede saberlo**.

Por (2), la regla es: **coincidencia por identificador = mismo buque, automático.
Coincidencia solo por nombre = se le pregunta al usuario.** Nunca fusionar dos perfiles en
silencio porque el nombre coincide; nunca crear un perfil duplicado en silencio tampoco.
Un buque mal identificado significa dibujar el plano de otro barco, que es peor defecto
que el que este sprint viene a corregir.

**No borres el `uuid`.** `Vessel.id` sigue siendo la identidad interna del objeto; lo que
se agrega es la clave de perfil, que es otra cosa y se guarda aparte.

**Terminada cuando:** hay pruebas con los seis segmentos TDT reales de la tabla, incluida
una que confirme que A05 y A06 **no** se resuelven a la misma clave automáticamente.

---

#### T-26 · Frontera cubierta/bodega declarada en el perfil · 1.00 h

**Toca:** `vessel_geometry.dart:51` (`deckTierFloor`), `vessel_geometry.dart:57`
(`isDeckTier`).

Hoy `deckTierFloor = 80` es una **constante de clase**. La numeración ISO reserva la banda
de los 80 para lo que va sobre la tapa de escotilla, y eso es estándar — pero *dónde
termina la bodega de un buque concreto* es del buque. El commit `1637dd1` ya dejó
registrado el hallazgo: «la frontera cubierta/bodega es del buque, no una constante».

Pasa a ser un campo del perfil, **con 80 como valor por defecto** para que ningún buque ya
cargado cambie de comportamiento. `isDeckTier` deja de ser `static` y pasa a consultar el
perfil.

**Cuidado:** `isDeckTier` es la definición única de clasificación en todo el proyecto
(ver el comentario de `vessel_geometry.dart:53-56`, que documenta que antes convivía con
un `tier >= 80` suelto en `ContainerSlot`). Al dejar de ser `static`, cada punto de
llamada necesita el perfil a mano. Recorre las llamadas una por una; si alguna no puede
alcanzarlo, **detente y repórtalo** en vez de reintroducir una constante suelta por la
puerta de atrás.

**Terminada cuando:** las 42 pruebas de `vessel_geometry_test.dart` siguen en verde sin
tocar sus aserciones, y hay una nueva con una frontera declarada distinta de 80.

---

#### T-27 · Pisos de cubierta y de bodega declarados · 1.25 h

**Toca:** `vessel_geometry.dart:22` (`firstHoldTier`), `:35` (`firstDeckTier`), `:211`
(`_anchoredRun`).

Mismo movimiento que T‑26 con las dos anclas: de constantes a campos del perfil, con 02 y
82 por defecto. La evidencia del corpus que fijó el 82 sigue siendo válida y se queda
escrita donde está (`vessel_geometry.dart:29-34`): de 4 584 slots ocupados, el nivel 80 no
aparece **ni una vez**, y el más bajo con carga es el 82 en 45 bahías.

Lo que cambia es de dónde sale el número: del perfil del buque, no de una constante que
vale para todos los buques del mundo.

**Terminada cuando:** un perfil con ancla de cubierta 84 produce una corrida que arranca
en 84, y el descenso por carga observada de `_anchoredRun` sigue funcionando sobre esa
ancla (la prueba de `PRUEBA_NIVEL_80.edi` no puede romperse).

---

#### T-28 · `proposeFrom` pasa a sembrar el perfil, no a ser la geometría · 1.25 h

**Toca:** `vessel_geometry.dart:159-193`, `vessel_overview_page.dart:330`,
`vessel_providers.dart:123`.

Hoy `proposeFrom` produce **la** geometría. Después de esta tarea produce **la primera
versión de un perfil**, que se guarda y a partir de ahí se recupera en vez de recalcularse.

El flujo de `vessel_overview_page.dart:294-330` cambia de:

```
archivo → proposeFrom → pantalla de parámetros → dibujar
```

a:

```
archivo → identificar buque (T-25)
        ├─ perfil guardado  → dibujar directo, con aviso si el archivo no cabe
        └─ sin perfil       → selector de plantilla (T-33) o proposeFrom → confirmar → guardar
```

**El invariante `coversAll` (`vessel_geometry.dart:147`) manda igual que antes, pero ahora
puede fallar con un perfil guardado**, no solo con uno recién propuesto: el viaje nuevo
puede traer carga donde el perfil declarado no llega. Ese caso **no se resuelve
ensanchando el perfil en silencio** — se le muestra al usuario qué posiciones quedan
fuera y se le ofrece ampliar el perfil. Ampliar en silencio reintroduce exactamente el
defecto que RF‑036 viene a cerrar, solo que con más pasos.

**Terminada cuando:** cargar dos veces el mismo archivo pregunta una sola vez; cargar un
archivo con carga fuera del perfil guardado avisa y ofrece ampliar, sin ampliar solo.

---

#### T-29 · Límite de apilamiento por pila en el perfil · 1.00 h

**Toca:** `vessel_geometry.dart:87` (`stackWeightLimitKg`).

El campo ya existe, ya es `double?` y ya está bien documentado: *«es el único parámetro que
no se deduce del archivo: viene del manual de estabilidad del buque. `null` significa que
el usuario declaró no tenerlo, y entonces no se muestra ninguna alerta de peso — antes que
inventar un umbral.»* Esa política se conserva íntegra.

Lo único que hace T‑29 es **mudarlo al perfil** para que se declare una vez por buque y no
una vez por viaje. **No mata ningún supuesto:** la constante global `kStackWeightLimitKg`
ya no existe — se retiró en C‑7 (`71ad205`), dieciséis días antes de abrir el sprint. Lo
que T‑29 aporta es permanencia por buque a un parámetro que hoy se vuelve a preguntar en
cada viaje, y que a lo sumo una plantilla puede sugerir, etiquetado como tal.

**Terminada cuando:** el valor sobrevive al cierre del viaje, y con `null` no aparece
ninguna alerta de peso en ninguna vista.

---

#### T-30 · Conjunto de posiciones con toma de reefer · 1.00 h

**Archivo:** `vessel_profile.dart` (T‑24).

Un conjunto de posiciones de estiba que tienen toma eléctrica. Es información del **buque**,
no del viaje: un enchufe existe esté o no ocupado hoy.

Guárdalo en la forma más compacta que siga siendo legible al serializar — el corpus llega a
4 584 slots por archivo y un perfil no debería pesar más que el viaje que describe. Si al
medirlo resulta que sí, dilo en el reporte antes de seguir.

**Terminada cuando:** el conjunto sobrevive al ciclo `toJson`/`fromJson` y la consulta
«¿esta posición tiene toma?» es O(1).

---

#### T-31 · Proponer las tomas de reefer desde el archivo como cota inferior · 1.00 h

**Toca:** el parser (ya detecta reefers desde `206545c`) y `vessel_profile.dart`.

Mismo razonamiento que `proposeFrom`, aplicado a los enchufes: **donde hoy hay un
refrigerado estibado, esa posición tiene toma.** Es una deducción segura, y es una cota
**inferior**: el buque tiene al menos esas, probablemente más.

Por eso lo propuesto se marca como propuesto y **nunca se presenta como declarado**. La
diferencia importa en T‑39: avisar «refrigerado en posición sin toma» apoyado en una cota
inferior produce falsos positivos, y un panel de alertas que se equivoca seguido deja de
leerse. Con el origen marcado, T‑39 puede bajar la severidad cuando la información es
propuesta y no declarada.

El corpus da con qué probar: 327 contenedores con tipo ISO de refrigerado y 238 segmentos
`TMP` (tabla completa en `docs/HALLAZGOS-PLANO-REAL.md`, sección 3).

**Terminada cuando:** sobre `CORPUS_A01` el conjunto propuesto contiene exactamente las
posiciones de sus refrigerados, ni una más, y todas quedan marcadas como propuestas.

---

#### T-32 · Clonar un perfil existente como plantilla · 1.00 h

**Archivo:** `vessel_profile.dart` + contrato de repositorio.

Un buque nuevo de la misma clase se parece a uno ya declarado. Clonar un perfil y cambiarle
la identidad ahorra la declaración completa.

**El clon arranca con origen `plantilla`, nunca `declarado por el usuario`.** Heredar el
origen del perfil fuente convertiría una suposición en un hecho declarado sin que nadie
declarara nada, y eso es precisamente el defecto de fondo que este sprint corrige.

**Terminada cuando:** el clon no comparte estado mutable con el original (prueba explícita:
modificar el clon no altera la fuente) y su origen es `plantilla`.

---

#### T-33 · Selector de plantilla al cargar un buque sin perfil · 1.50 h

**Toca:** `vessel_overview_page.dart:294-330`.

Cuando T‑25 no encuentra perfil, ofrecer las dos salidas que se decidieron para este sprint:

- **Partir de una plantilla** (un perfil ya declarado, T‑32), si hay alguno guardado.
- **Partir de lo que propone el archivo** (`proposeFrom`), que es lo que hace hoy.

Si no hay ningún perfil guardado, la primera opción no se muestra: el selector no puede
tener opciones vacías. En ambos casos se pasa por la pantalla de confirmación de T‑34 — no
se guarda nada sin que el usuario lo vea.

**Terminada cuando:** con cero perfiles guardados el flujo es idéntico al de hoy, y con uno
o más aparece la opción de plantilla.

---

#### T-34 · Pantalla de Parámetros convertida en editor de perfil persistido · 1.50 h

**Toca:** `lib/features/vessel/presentation/pages/vessel_geometry_page.dart` (708 líneas).

La pantalla ya hace casi todo: chips editables de niveles (`:368`), validación por
`coversAll` (`:146`) y confirmación (`:163`). Lo que le falta es que **lo confirmado se
guarde en el perfil del buque** en vez de en el viaje, y que la pantalla se pueda abrir
también para editar un perfil existente, no solo al cargar un archivo.

Agrega los campos nuevos del perfil (frontera, anclas, límite de apilamiento, tomas de
reefer) respetando el escalonamiento visual y el patrón de chips ya establecido.

**Trampa conocida, documentada en `HALLAZGOS-PLANO-REAL.md` §4 — no repetirla.** Al pasar
`deckTiers` de `int` a `List<int>`, la pantalla rotulaba «geometría corregida por el
usuario» sin que nadie tocara nada, porque comparaba las listas con `==`, que en Dart
compara **identidad de referencia**, no contenido. Se corrigió con `_sameTiers`. Cada campo
nuevo que agregues aquí y que sea colección tiene el mismo riesgo, y el compilador no avisa.

**Terminada cuando:** abrir la pantalla sin tocar nada no marca el perfil como modificado
(hay dos pruebas de eso en `vessel_geometry_page_test.dart`, extiéndelas a los campos
nuevos), y lo confirmado se recupera tras reiniciar la aplicación.

---

### RF-031+ · Almacén local propio (3.0 h · T-35 … T-37)

> **Como** planificador **quiero** que la aplicación recuerde los viajes recientes sin
> depender de la caché del proveedor de nube, **para** reabrirlos sin volver a procesar el
> archivo.

Comparte infraestructura con RF‑036 a propósito: **un solo almacén guarda perfiles y
viajes.** Duplicar el mecanismo costaría el doble y arrastraría H‑02 —el acceso anónimo
abierto de Firestore— a una colección nueva. Todo lo que viva en el disco del usuario es
una colección menos que endurecer.

---

#### T-35 · Incorporar el motor de almacenamiento local · 1.00 h

**Toca:** `pubspec.yaml`. **Es la única dependencia nueva autorizada del sprint.**

**Va primero en el orden de ataque** por la misma razón que T‑08 fue primero en el
Sprint 1: es la única decisión que, si sale mal, obliga a replanificar. Se verifica en las
tres plataformas **antes** de que nada dependa de ella.

La ficha aprobada de RF‑031 nombra dos candidatos: **SharedPreferences o Hive**. Elige con
una medición, no con una preferencia:

1. Exporta `CORPUS_A01` a JSON con la función de exportación que ya tiene la aplicación
   (`export_service.dart`, entregada en el Sprint 1) y **mide el archivo**. Son 977
   contenedores: es el caso grande real, no uno inventado.
2. Multiplica por el número de viajes recientes que se quiera conservar.
3. Si el total cabe holgado en el presupuesto de `localStorage` del cliente Web (~5 MB, que
   es el techo más bajo de las tres plataformas), **`shared_preferences` gana**: es la
   opción de menor costo para H4.
4. Si no cabe, **`hive_ce`** (el sucesor mantenido de Hive; en Web va sobre IndexedDB y no
   tiene ese techo).
5. Si no cabe con ninguno, la palanca es **limitar cuántos viajes se conservan**, no
   agregar un segundo motor.

**Reporta la medición con el número antes de fijar la dependencia.** Ese número es
argumento de defensa: muestra que la dependencia se eligió midiendo.

**Terminada cuando:** el paquete compila y guarda/lee en **Windows, Android y Web**, las
tres verificadas. La Web es la que falla; no la dejes para el final.

---

#### T-36 · Esquema y serialización de viajes y perfiles · 1.00 h

**Archivo nuevo:** `lib/features/vessel/data/datasources/` (fuente de datos local) +
contrato en `domain/repositories/`.

Un esquema, dos colecciones: **perfiles por clave de buque** (T‑25) y **viajes por id**.
Las entidades ya serializan (`VesselVoyage.toJson` en `vessel_voyage.dart:297`,
`VesselProfile` en T‑24); esta tarea les da dónde vivir.

**Incluye un número de versión del esquema desde el primer día.** Un perfil guardado hoy
tiene que poder leerse cuando el esquema cambie en octubre, y el único momento barato de
agregar el campo es antes de que exista el primer dato guardado.

**Terminada cuando:** guardar y recuperar un viaje completo de `CORPUS_A01` devuelve los
977 contenedores intactos, y un registro sin número de versión se trata como versión 1 en
vez de reventar.

---

#### T-37 · Listado de viajes recientes con apertura y eliminación · 1.00 h

**Toca:** `vessel_overview_page.dart`, `vessel_providers.dart`.

Lista de lo guardado, con abrir y eliminar. Reutiliza `empty_state_widget.dart` para el
caso sin viajes.

**Eliminar un viaje no elimina el perfil de su buque.** Son dos cosas distintas y esa es
justamente la separación que sostiene el requerimiento: el viaje es de hoy, el buque
sigue existiendo mañana.

**Terminada cuando:** abrir un viaje guardado no vuelve a leer el archivo `.edi` y funciona
**sin conexión** — que es la razón de ser del requerimiento.

---

### RF-027 · Validación de reglas de estiba (8.0 h · T-38 … T-42)

> **Como** operador de muelle **quiero** que la aplicación valide la posición antes de
> colocar el contenedor, **para** evitar una restiba.

Es la innovación central del proyecto. **No puede empezar antes de que RF‑036 esté cerrado**:
las cuatro validaciones consultan el perfil, y validar contra una geometría inferida es
exactamente lo que produce la alerta falsa.

Las cinco tareas comparten un mismo contrato de resultado: **severidad, descripción,
posición**. Defínelo en T‑38 y reúsalo en las demás; no inventes cuatro formas distintas de
decir «esto está mal».

---

#### T-38 · Validar el peso por pila contra el límite del perfil · 1.50 h

**Toca:** `bay.dart` (el peso por pila ya se calcula desde `71ad205`), perfil de T‑29.

Con `stackWeightLimitKg` en `null` **no hay alerta**. Es la política ya establecida en
`vessel_geometry.dart:83-86` y no se negocia: antes que inventar un umbral, no avisar.

**Terminada cuando:** una pila que excede el límite declarado produce alerta; la misma pila
sin límite declarado no produce ninguna.

---

#### T-39 · Validar refrigerado en posición sin toma eléctrica · 1.00 h

**Toca:** `container_unit.dart:61` (`isReefer`), perfil de T‑30 y T‑31.

**La severidad depende del origen del dato** (ver T‑31): si las tomas fueron **declaradas**
por el usuario, un refrigerado fuera de ellas es un error. Si fueron **propuestas** desde el
archivo —una cota inferior—, es un aviso, porque la posición podría tener toma y BayStream
no tener forma de saberlo.

Sin esa distinción el panel se llena de falsos positivos el primer día y el usuario aprende
a ignorarlo, que es la peor forma de fallar de una alerta.

**Terminada cuando:** las dos severidades se ejercitan en pruebas separadas.

---

#### T-40 · Validar el apilamiento de 20 pies sobre 40 pies · 1.50 h

**Toca:** `container_slot.dart`, `bay.dart`, `iso_coordinate_parser.dart`.

Un 20 pies no se apila sobre un 40 pies sin equipo especial. La mitad del trabajo ya está:
`15cf140` marca los huecos que ocupa un 40 pies vecino (`neighborOccupiedSlots()`), que es
justo la relación geométrica que hace falta.

**Terminada cuando:** la regla se verifica contra un archivo real del corpus que tenga
ambos tamaños, no solo contra un caso sintético.

---

#### T-41 · Separación de mercancías peligrosas desde los segmentos DGS · 2.00 h

**Toca:** `baplie_parser_service.dart:755` (`_parseDGS`, ya existe),
`container_unit.dart:52-58` (`isDangerous`, `imdgClass`, `unNumber`, ya existen).

**El parseo ya está hecho. Lo que falta es la regla de separación.** Es la tarea más larga
del bloque y por una razón que no es de código: las distancias de segregación IMDG son
**normativas**, dependen del par de clases, y no se inventan.

**Implementa solo los pares que puedas sustentar con la fuente citada, y declara
explícitamente los que no cubres.** Una matriz de segregación incompleta pero honesta es
defendible; una matriz inventada que parezca completa no lo es, y es exactamente el tipo de
afirmación que hunde una defensa.

Si la fuente normativa no está a mano, **detente y repórtalo** antes de codificar la
matriz. Esta es la tarea con más probabilidad de consumir holgura del sprint.

**Terminada cuando:** cada par implementado cita su fuente en un comentario, y los pares no
cubiertos aparecen en la interfaz como «no evaluado», no como «conforme».

---

#### T-42 · Panel de alertas con severidad, descripción y posición · 2.00 h

**Archivo nuevo:** `lib/features/vessel/presentation/widgets/`.

Reúne las cuatro validaciones. Ordenado por severidad; tocar una alerta lleva a la posición
en el plano — el patrón ya existe: T‑19 conectó el perfil longitudinal con el Bay Plan vía
`selectedBayProvider` + `TabController.animateTo(1)`. Reúsalo.

Escalas de color de un solo tono por severidad, **nunca arcoíris** — la decisión de T‑18
sigue en pie: un arcoíris no tiene orden perceptual, y aquí el orden es el dato.

**Terminada cuando:** sobre `CORPUS_A01` con un perfil declarado completo el panel muestra
alertas reales y ninguna alerta cuyo origen no se pueda explicar.

**Criterio redefinido el 30-sep (10.24), sin inventar datos:**

- Sobre `CORPUS_A01`, con el perfil que el planificador puede declarar:
  - fila 00 ausente en cubierta y en bodega;
  - límite de apilamiento marcado como «No lo tengo»;
  - tomas propuestas desde el archivo.

  Con ese perfil, el panel no muestra ninguna alerta cuyo origen no se pueda explicar.
- Las **alertas reales** se demuestran sobre `CORPUS_A03`, con los dos pares de segregación que
  Carlos validó (10.20).
- Se comprueba en los tres clientes, después de T‑58.

---

### TC-01 · Revisión de características de calidad (3.0 h · T-43, T-44)

#### T-43 · Retirar las 49 advertencias preexistentes de `flutter analyze` · 1.50 h

Vienen declaradas y diferidas desde el Sprint 1. Aquí se cierran.

**Ninguna se silencia con `// ignore:`.** Una advertencia silenciada sigue estando, y el
número que se reporta en la tesis dejaría de significar lo que dice. Si alguna no se puede
arreglar sin cambiar comportamiento, **no la toques y repórtala**: una advertencia
justificada es un dato; una ocultada es una afirmación falsa.

**Terminada cuando:** `flutter analyze` sale limpio, o las que quedan están listadas con su
razón.

---

#### T-44 · Medir los ocho requerimientos no funcionales sobre la versión a liberar · 1.50 h

Se mide sobre el binario que se va a publicar en TC‑04, no sobre una compilación de
desarrollo. Registra el commit exacto y la plataforma de cada medición.

**El dispositivo Android cambió** (POCO X3 NFC → Honor X5d / Android 15, ver 10.11). Toda
medición de T‑44 se hace en el Honor y **se rotula con ese dispositivo**: no es el mismo en
el que se cerró el ANR de T‑50 ni en el que se tomó la serie de H5.

**Si un requerimiento no se cumple, el número se reporta como salió.** Este proyecto ya
tiene seis casos documentados en que un segundo revisor encontró algo que el primero dio
por bueno, y ese patrón es material del apartado de método. Maquillar una medición lo
desperdicia y es la clase de cosa que se detecta en la defensa.

---

### TC-03 · Pruebas finales de seguridad (3.0 h · T-45, T-46)

#### T-45 · Cerrar H-02: autenticación y reglas de acceso por usuario · 2.00 h — ✓ CERRADA (B publicada)

**Redacción y contraste hechos (Timonel, 23-sep).** Dos variantes contrastadas contra todo
el código que gobiernan. **Se publica B, sin autenticación; §2.5 queda intacta y H‑02 se
re‑acota en vez de cerrarse — ver 10.10.** La segunda mitad (cableado de autenticación) no
se ejecuta en este sprint.

**Toca:** `firestore.rules`. **Redactas; el autor publica** (regla 2.7).

H‑02 es el último hallazgo crítico abierto: creación y actualización anónimas.

**Antes de escribir una sola cláusula, contrasta la regla contra todo el código que va a
gobernar.** La lección de T‑23 está documentada y costó una corrección: la primera
redacción de la regla de `latency_test` habría inhabilitado la medición de H5 por completo,
en silencio, sin error de compilación ni prueba fallida. **Las dos pantallas congeladas
escriben en Firestore y no se pueden modificar: la regla se acomoda al código, nunca al
revés.**

La regla vigente de `latency_test` permite `update` solo si `respondido == false`, solo si
pasa a `true`, solo si `proceso_b_ms is number` y solo si
`affectedKeys().hasOnly(['respondido','proceso_b_ms'])`. **Esas cuatro condiciones se
conservan íntegras**: dejan `t0`, `condicion` y `evento` inmutables desde su creación, que
es lo que impide **editar** una medición ya tomada. **No impedían fabricarla:** ver 10.10.
Se conservan íntegras de todos modos, y la variante publicada cierra además el `create`.

**Terminada cuando:** el bloque de reglas está listo para publicar **y** viene acompañado
del procedimiento de verificación empírica —dos clientes, receptor activo, serie corta de
3-4 eventos, confirmar que cierran en vez de agotar el tiempo de espera. Una regla que se
lee bien puede comportarse distinto; eso ya pasó aquí.

---

#### T-46 · Registro de eventos y análisis de dependencias (H-06 y H-07) · 1.00 h — ✓ CERRADA (alertas: limitación declarada, 10.44)

Los dos hallazgos de severidad baja que quedan. **Sin dependencias nuevas** (regla 2.5): el
análisis de dependencias se resuelve con lo que el SDK ya trae.

---

### TC-04 · Despliegue (5.0 h · T-47 … T-49)

**Este bloque arranca el día uno pese a ir último en la lista**, porque es el único cuya
duración no la decide el equipo. Ver sección 6.

#### T-47 · Proyecto de producción y retiro de credenciales del código (H-04) · 1.50 h

Lee la restricción **2.2** completa antes de empezar. Las tres condiciones de ahí gobiernan
esta tarea: el proyecto temporal de H5 **sobrevive**, las pantallas congeladas siguen
funcionando, y el proyecto lo crea el autor, no tú.

**Terminada cuando:** existe el proyecto de producción, `lib/main.dart` no lleva claves de
producción escritas en duro, y la instrumentación de H5 sigue midiendo.

**Decisión del 1-oct (10.32), opción B:** `main.dart` inicializa Firebase contra el proyecto de
producción con opciones leídas por `--dart-define-from-file` desde un archivo fuera del repositorio.
H5 corre por `tool/h5_main.dart` (T‑62). En la misma pasada se cambia el identificador con el
inventario de `docs/T62-RESULTADOS.md`. Se prueba el arranque en frío sin red en los tres clientes;
si Web falla, se reporta y se decide aparte.

---

#### T-48 · Publicar el cliente Web en una dirección accesible · 1.50 h

`flutter build web` y publicación. Verifica que el almacén local de T‑35 sigue funcionando
**en la versión publicada** — el comportamiento de `localStorage`/IndexedDB cambia entre
servir en local y servir desde un dominio real. Es un fallo clásico y aparece tarde.

---

#### T-49 · Firmar y publicar el paquete Android · 2.00 h

Clave de firma, `build appbundle`, publicación.

**La clave de firma se genera una sola vez y si se pierde no hay forma de volver a publicar
una actualización de esa aplicación, nunca.** Respáldala fuera del repositorio antes de
seguir, y **jamás la commitees** — `.gitignore` ya cubre el patrón de secretos, pero
verifícalo tú.

**Terminada cuando:** la aplicación se instala desde el canal público en un dispositivo
real, no en un emulador.

**Criterio redefinido el 1-oct (10.28):** el paquete firmado (`.aab`), con el identificador
definitivo, se sube a la **prueba interna** de Google Play y se instala en el Honor desde Play,
no por cable. La publicación en producción queda fuera del sprint, detrás de la prueba cerrada
de 14 días que Google exige a las cuentas personales nuevas (10.25).

---

### Trabajo del segundo programador (Timonel) — fuera del compromiso, contra holgura

Estas tareas **no cuentan contra los 57 pts / 35.0 h** del documento entregado el
19-sep. Salen de las 18 h de holgura, que existen justamente para esto. Van aparte porque
tocan archivos que ningún bloque de RF‑036 toca, así que pueden avanzar sin chocar con el
programador de turno.

---

#### T-50 · Reconciliar y cerrar la detención (ANR) en Android · 2.00 h — ✓ CERRADA

**✓ CERRADA el 19 de septiembre (Timonel) — no era un defecto del producto. Sin cambio de código.**

No reproduce en el **POCO X3 NFC real** en `713da5a` debug, `713da5a` release ni
`a3dbc99` release. **La elección de commits es lo que hace válida la conclusión:**
`713da5a` es de diez commits **antes** de `3f2ced5`, es decir el estado donde el defecto
tenía más probabilidad de aparecer, y tampoco reprodujo ahí.

La única observación original fue en **emulador API 36 con APK debug** — compilación JIT,
no AOT. Nadie había abierto el plano en dispositivo real hasta hoy: la auditoría de Codex
anota que MIUI bloquea la inyección de eventos.

La «confirmación» del 4 de septiembre era una **frase de estado** del propio Timonel
—«el de Android sigue vivo», dentro de una lista de qué seguía abierto— **sin reproducción
detrás**, que se leyó como evidencia. Queda como **corrección 7** del registro de
`docs/HALLAZGOS-PLANO-REAL.md`.

**T‑49 y el bloque 9 quedan desbloqueados.** Lo único que hereda T‑44: la ausencia de
reproducción **no es una medición**. El tiempo de apertura del plano de bahía con el
corpus completo en dispositivo real entra ahí como número. «Abrió en X ms» vale más ante
el tribunal que «no reprodujo».

**Toca:** `lib/features/vessel/presentation/widgets/bay_plan_view.dart`.

**Hay dos afirmaciones en la documentación del proyecto que no encajan, y nadie las ha
reconciliado:**

| Fuente | Dice |
|---|---|
| `docs/HALLAZGOS-PLANO-REAL.md` §4 | «ANR verificado **sin reproducir** en emulador API 36, APK release, bahía 038, dieciocho cambios rápidos» tras cerrar C‑4 (`3f2ced5`) |
| `CLAUDE.md` §«Estado al cerrar el Sprint 1» | «Timonel confirmó el **4 de septiembre** que el problema **sigue vivo**» |

El propio `CLAUDE.md` deja la pregunta abierta: *«alguien tiene que reconciliarlas
—¿reprodujo en dispositivo real y no en emulador? ¿volvió a aparecer después de otro
cambio?— antes de dar esto por entendido, no solo por cerrado.»*

**Por qué sube de prioridad ahora:** **T‑49 publica el paquete Android.** Una aplicación
que se cuelga al abrir el plano de bahía con un archivo real no se puede publicar, y TC‑04
es **MUST**. Mientras esto no se cierre, el bloque 9 del sprint no tiene salida.

Empieza por **diagnosticar, no por corregir** — esa mitad no escribe una línea de código y
por tanto no interfiere con nadie:

1. Reproducir en **dispositivo real** (el POCO X3 NFC), no solo en emulador, con
   `CORPUS_A01` completo. El fixture de `test/` tiene 7 contenedores y **no sirve** para
   esto.
2. Determinar si la diferencia es emulador/dispositivo, o si reapareció después de un
   cambio posterior a `3f2ced5`.
3. Reportar el diagnóstico con el commit exacto donde reproduce y donde no.

**Terminada cuando:** las dos afirmaciones de la tabla quedan reconciliadas con evidencia
—no con una suposición— y, si el defecto sigue vivo, corregido y verificado en dispositivo
real. Actualiza las **dos** fuentes; dejar una al día y la otra no es cómo se llegó aquí.

---

#### T-51 · Retirar `maxRows` y `maxTiers` de `Bay` · 0.50 h — ✓ CERRADA

**✓ CERRADA el 19 de septiembre (Timonel, `aa27781`).** Fuera de la entidad, `props`,
`copyWith`, `toJson` y `fromJson`, con prueba de que un documento con la forma exacta
anterior abre igual, y verificación de punta a punta con `CORPUS_A01` serializado con los
campos metidos en las 27 bahías. **139/139 · `analyze` 49.** T‑36 puede entrar sin heredar
el esquema viejo.

**Toca:** `lib/features/vessel/domain/entities/bay.dart:24-34, 67-68, 195, 207, 218,
257-258, 280-281`.

**El propio código fija la condición para retirarlos** y esa condición ya se cumplió. El
comentario de `bay.dart:24-30` dice: *«Se conservan porque los documentos de Firestore ya
escritos los traen; se retiran cuando C‑2, C‑4 y C‑5 hayan aterrizado, no antes.»*
**C‑2, C‑4 y C‑5 están los tres cerrados.**

Hoy son código muerto: nada en `lib/` los asigna nunca, y `occupancyRate`
(`bay.dart:92`) ya calcula contra `geometry!.slotsPerBay`. Lo único que sostiene su
existencia es la compatibilidad con documentos de Firestore ya escritos, que `fromJson`
resuelve con un valor por omisión — y ese valor por omisión puede quedarse aunque el campo
desaparezca de la entidad.

**Esto retira el último de los dos supuestos provisionales declarados.** El otro,
`kStackWeightLimitKg`, ya había muerto en C‑7 (`71ad205`). Al cerrar esta tarea **BayStream
no calcula nada contra una constante inventada** — frase que se puede decir entera, sin
asterisco.

**No los confundas con las anclas de nivel (02, 82, 80)** que T‑26 y T‑27 mueven al perfil:
esas **no son supuestos provisionales**. Salen de la numeración ISO y están respaldadas por
el corpus. T‑26/T‑27 hacen otra cosa: convierten una constante correcta-en-general en un
parámetro declarado por buque.

**Corrige también `CLAUDE.md` §«Sobre umbrales y datos que el archivo no trae»**, que
sigue afirmando que «toda la ocupación se calcula contra 120 huecos ficticios». Dejó de
ser cierto en C‑3. Y su §«Estado al cerrar el Sprint 1» dice **135 pruebas**; hoy son
**138**. Un `CLAUDE.md` desactualizado manda al siguiente programador a cazar defectos que
ya no existen — ya pasó una vez, el 4 de septiembre.

**Terminada cuando:** `flutter test` sigue en verde, un documento de Firestore escrito
antes del cambio se sigue leyendo sin error, y las dos secciones de `CLAUDE.md` dicen la
verdad.

---

#### T-53 · Dibujar en el PDF los huecos ocupados por un 40 pies vecino · 1.00 h

**Toca:** `lib/features/vessel/data/services/pdf_report_service.dart`.

Hallazgo de Codex al cerrar T‑52 (`docs/T52-RESULTADOS.md`, «Hallazgo fuera del alcance»).
La pantalla marca los huecos que ocupa un contenedor de 40 pies de la bahía vecina
(`bay_plan_view.dart:814-815`, dibuja `40'`); **el PDF no consulta
`slotsOccupiedByNeighbors` en ningún punto.** En `CORPUS_A01` las bahías 005, 013, 015,
035, 039, 043 y 045 salen vacías en el PDF aunque están físicamente tomadas, y el defecto
también alcanza huecos de bahías con carga propia.

**No es cosmético.** Un planificador que lee el PDF ve libre una posición que no lo está.

**Alcance, el que propuso Codex:** representar y rotular esos huecos con la misma prioridad
que la pantalla (carga propia primero), incluirlos en la leyenda y comprobarlo contra A01.
**No** sumarlos como contenedores, ni alterar pesos, la tabla o el número de páginas.

**Y en la misma leyenda: `Vacío` y `OOG` comparten color.** Observación de Timonel al
verificar el bloque 4 en Android: `pdf_report_service.dart:430` y `:433` usan exactamente
`orange100` / `orange` para las dos entradas, así que el PDF las separa en la leyenda pero
no en las celdas. Como T‑53 ya abre esa leyenda, se corrige aquí: un color propio para cada
una, que se distinga también en claridad y no solo en tono.

**Terminada cuando:** las siete bahías de A01 muestran sus huecos tomados, `Vacío` y `OOG`
se distinguen en la celda y en la leyenda, y el conteo de contenedores y las 62 páginas no
cambian.

---

#### T-54 · Mostrar el límite de apilamiento igual en las tres plataformas · 0.25 h

**Toca:** `lib/features/vessel/presentation/pages/vessel_geometry_page.dart:129`.

Observación de Timonel en el recorrido a mano del bloque 5: el editor muestra `75000.0` en
Windows y Android, y `75000` en Web. La línea 129 usa `stackWeightLimitKg!.toString()`, y
**`double.toString()` no imprime igual en la máquina virtual de Dart que en JavaScript**,
donde un número entero no lleva `.0`.

Es solo de presentación, pero vale como dato para H4: **una sola base de código no garantiza
una sola salida**; el entorno de ejecución de cada plataforma se cuela en el texto. El arreglo
es formatear el número explícitamente, con el mismo criterio en los tres clientes.

**Terminada cuando:** el mismo perfil muestra el mismo texto del límite en Windows, Web y
Android, con y sin decimales.

---

#### T-55 · Revisión cruzada de RF-027 contra su fuente y contra el corpus · 1.50 h

**No toca `lib/`.** Lectura, pruebas existentes y scripts en `tool/`. Informe en
`docs/T55-RESULTADOS.md`.

**Por qué.** Codex escribió RF‑027 entero, de T‑38 a T‑42, y Timonel armó la fuente de T‑41
(`docs/T41-SEGREGACION-FUENTE.md`). Nadie fuera del autor ha contrastado el código con esa
fuente. Es el patrón de la doble prueba del Sprint 1: este proyecto ya tiene seis casos en que
el segundo revisor encontró algo que el primero dio por bueno.

**Qué revisar, en este orden:**

1. **Una fila central que el buque puede no tener.** `VesselGeometry.orderedRows` incluye
   siempre la fila 00 («Existe siempre, aunque el viaje no la cargue»), y
   `DangerousGoodsValidator` mide la separación transversal por índice en esa lista
   (`dangerous_goods_validator.dart:168-169`). En un buque sin fila 00, las filas 01 y 02 son
   vecinas, pero el índice las separa por un hueco inexistente, y un par de código 2 en 01/02
   podría salir **conforme**. Es una hipótesis por lectura de código, no un defecto
   confirmado. Comprobar con un caso controlado si pasa, y en el corpus si algún archivo tiene
   carga en 01 y 02 en la misma bahía y nivel sin usar nunca la 00.
2. **Tomas de reefer y paridad de bahía.** `ReeferSocketValidator` busca la posición exacta
   del contenedor (`profile.hasReeferSocket(p.toIsoCode())`). Un 40 pies llega en bahía par
   (`0260184`) y un 20 pies en la impar vecina (`0250184` o `0270184`). Si el inventario se
   declara en una notación y la carga llega en la otra, sale una alerta «sin toma» que el
   criterio de T‑42 no admite. Contar cuántas de las 50 tomas propuestas de A01 vienen de un
   40 y cuántas de un 20, y describir qué pasa si el mismo hueco físico recibe un 20 en otro
   viaje.
3. **Tabla de segregación contra su fuente.** Cada entrada de `segregation_rules.dart` contra
   `docs/T41-SEGREGACION-FUENTE.md` y la edición 2024 de §176.83 (enlace en
   `docs/BLOQUE7B-RESULTADOS.md`). Revisar los riesgos subsidiarios por (a)(6), las unidades
   cerradas por (f)(3), y que ningún caso sin regla salga como conforme.
4. **Un caso trazado a mano por validador** (T‑38, T‑39, T‑40 y T‑41) sobre `CORPUS_A01` o
   `CORPUS_A03`, comparado con lo que muestra el panel de T‑42.

Cada hallazgo se clasifica como **defecto confirmado** (con reproducción: archivo y posición,
o script), **duda** (qué haría falta para resolverla) o **conforme**. **No se corrige nada**:
según 9.1, un defecto se anota y se decide dónde entra. Las reproducciones van como scripts en
`tool/`; no se agregan pruebas en rojo a `test/`.

**Terminada cuando:** los cuatro puntos tienen veredicto y cada defecto confirmado tiene su
reproducción.

---

#### T-56 · Declarar el inventario de tomas de reefer por rangos · 1.50 h

**Pasa al Sprint 3 (10.24).** Su especificación es la sección 3 de `docs/T59-RESULTADOS.md`:
celda más extremo, tabla de pares en el perfil y validación por celda física.

**Toca:** la sección de tomas de `vessel_geometry_page.dart` y, si hace falta, una función
pura en `domain/services/` con su prueba.

**Por qué.** El criterio de T‑42 pide un perfil declarado completo, y hoy la única forma de
declarar tomas es una a una: un campo de siete dígitos y «Agregar toma». Un inventario real de
cientos de tomas no se carga así, o se carga con atajos que invalidan la declaración.

**No empieza hasta que se cumplan dos condiciones.** Primero, que Codex entregue T‑44: esta
tarea cambia `lib/`, y si Codex tuviera que recompilar, contaminaría la versión candidata. Segundo, que
T‑55 y Carlos resuelvan el punto 2, es decir, qué número de bahía lleva una toma. El rango
genera los códigos que el validador va a buscar; con la convención equivocada, cada toma sale
como alerta falsa.

**Aviso de T‑55:** qué impares cubre cada bahía par depende del buque; ALFA tiene contenedores de
40 pies en la bahía 044. La correspondencia sale de la numeración del buque, no de una fórmula.

**Qué:** agregar por rango (bahías desde–hasta, filas, niveles desde–hasta), con vista previa
de cuántas tomas se agregarán y cuántas se descartan por caer fuera de la geometría
declarada; y pegar una lista de códigos separados por comas o saltos de línea. Cargar por
rango **no declara**: la declaración sigue exigiendo marcar la casilla que ya existe.

**Terminada cuando:** se carga un inventario de al menos cien tomas en menos de un minuto en
los tres clientes, y el conteo de la vista previa coincide con el del perfil guardado.

---

#### T-57 · Mensajes de error en español, con causa y acción sugerida · 1.00 h

**Toca:** `lib/features/vessel/presentation/providers/vessel_providers.dart`, las páginas de
`presentation/pages/` que interpolan `$error`, y `data/repositories/vessel_repository_impl.dart`.

**Por qué.** T‑44 encontró dos incumplimientos con la misma raíz. RNF‑002 pide la interfaz en
español, y RNF‑006 pide mensajes «100% descriptivos con causa y acción sugerida». Hoy los fallos
se envuelven en `StateError` y la presentación interpola `$error`, así que el usuario lee
«Bad state: …» y ninguna acción (captura `build/t44/honor-invalid-result.png`).

**Qué:**

- Ningún mensaje visible muestra el `toString()` de una excepción de Dart.
- Cada fallo conocido lleva causa y acción. Ejemplo: «El archivo no trae el nombre del buque
  en el segmento TDT. Revisa que sea un BAPLIE completo o pide una nueva exportación.»
- Un fallo desconocido lleva un mensaje genérico en español con acción. El detalle técnico va
  al registro de depuración, no a la pantalla.

No cambia la lógica del parser ni la de los validadores.

**Terminada cuando:** el archivo inválido de T‑44 (`T44_INVALID.edi`) y un BAPLIE sin nombre de
buque muestran causa y acción, sin «Bad state», en los tres clientes, y una prueba impide que
vuelva a aparecer un prefijo de excepción en los mensajes de carga.

---

#### T-58 · Fila 00 declarada por zona, y dos ajustes de segregación · 2.00 h

**Toca:** `vessel_geometry.dart`, `dangerous_goods_validator.dart`, la sección de geometría de
`vessel_geometry_page.dart` y sus pruebas. **Empieza cuando se entregue T‑57**, porque las dos
tocan `lib/`.

**Por qué.** T‑55 confirmó que la geometría supone siempre una fila 00, y que un par de código 2
en 02/01 sale **conforme** en un buque que no la tiene. Carlos aceptó además corregir la
precedencia del «\*» y tratar los tanques como unidad cerrada (10.23).

**Qué:**

1. **Fila 00 por zona.** La geometría gana dos campos, `centerRowOnDeck` y `centerRowInHold`, de
   tipo `bool?`: `true` si el buque la tiene, `false` si no la tiene, `null` si no está
   declarado.
   - `proposeFrom` pone `true` en la zona donde el viaje trae carga en la fila 00 (eso es
     evidencia), y `null` donde no la trae (la ausencia no prueba nada).
   - La separación transversal cuenta la fila 00 como hueco **solo si esa zona la declara
     `true`**. Con `false` o `null`, las filas 01 y 02 son vecinas. Es la dirección
     conservadora: una alerta de más, nunca un conforme de más.
   - El editor muestra y guarda las dos declaraciones.
   - Los perfiles ya guardados se abren con `null`: el valor por omisión va en el borde de
     `fromJson`, igual que las anclas de nivel.
   - El dibujo del plano y el del PDF no cambian: Baplie Viewer también dibuja la columna 00.
2. **Precedencia del «\*».** La compatibilidad de §176.144 aplica solo al par 1.x/1.x. Si otra
   combinación de clase o de etiqueta da código 2, gana el 2.
3. **Tanques.** Se tratan como unidad cerrada. La inferencia y su fuente (§176.2) se escriben en
   el comentario de `_problem`, y una prueba la fija.

**Terminada cuando:**

- Los casos de `tool/t55_fila_central.dart` y `tool/t55_tabla_segregacion.dart` pasan a ser
  pruebas en `test/`, con el resultado corregido:
  - 02/01 sin fila 00 declarada da posible incumplimiento;
  - 02/01 con la fila 00 declarada da conforme;
  - UN0012 con etiqueta 3 junto a UN0303 da posible incumplimiento.
- Los totales del panel para A03 (2/100/151 en el bloque 7b) y para A01 no cambian, o se
  explica por qué cambian.
- Un perfil guardado antes de T‑58 abre sin error en los tres clientes.

---

#### T-59 · Averiguar cómo se documentan las tomas de reefer y qué bahía lleva una toma · 1.00 h

**No toca `lib/`.** El informe va en `docs/T59-RESULTADOS.md` y los scripts en `tool/t59_*.dart`.
Puede correr en paralelo con T‑57 y con T‑58.

**Por qué.** T‑56 necesita una convención para el inventario de tomas, y Carlos no tiene la
documentación de tomas de ALFA (10.23). El validador compara el código exacto de posición, y un
mismo hueco físico cambia de número según llegue un 20 o un 40.

**Qué:**

1. **Fuentes públicas.** Cómo documenta la industria las tomas de reefer: planos de estiba,
   perfiles de buque en el software de planificación, recomendaciones SMDG, literatura académica
   sobre estiba. La pregunta concreta tiene dos partes:
   - ¿La toma pertenece a un hueco de 20 (bahía impar), a un hueco de 40 (bahía par) o a un
     extremo?
   - ¿De qué extremo toma corriente un refrigerado de 40?

   Cada afirmación lleva su fuente. Lo que no tenga fuente se marca como inferencia.
2. **Corpus.** Para los cinco buques:
   - dónde van los refrigerados de 20 dentro de cada par de bahías, y si es siempre el mismo
     extremo;
   - qué bahías impares cubre cada bahía par, derivado de las posiciones reales. Incluye la 044
     de ALFA y las 50 posiciones de DELTA que salen del patrón.
3. **Propuesta.** Una convención para el inventario de BayStream y una regla de búsqueda para el
   validador que funcionen con cualquiera de las respuestas posibles. También qué dato tendría
   que confirmar Carlos para ALFA.

No cambia código. Decide Carlos.

**Terminada cuando:** la pregunta tiene respuesta con fuentes, o queda declarado que no tiene
respuesta pública; hay una tabla de correspondencia de bahías por buque; y hay una propuesta
concreta para T‑56.

---

#### T-60 · La fila 00 que el propio viaje ocupa cuenta como existente · 0.50 h

**Toca:** `dangerous_goods_validator.dart` y su prueba.

**Por qué.** T‑58 cuenta la fila 00 como hueco solo si el perfil la declara `true`. Un perfil
guardado antes, o uno propuesto desde un viaje sin carga en la 00, queda en `null`. Si después
llega un viaje con contenedores **físicamente** en la 00, el validador sigue tratando 01 y 02
como vecinas. Así salen las dos alertas nuevas del A03 histórico (10.27): la 0260084 está
ocupada, así que el hueco existe y lleva carga. Es el escenario normal de RF‑036, un perfil que
persiste entre viajes.

**Qué:** cuando la declaración de la zona es `null`, la fila 00 cuenta como existente si **este
viaje** tiene carga en la fila 00 de esa zona y en alguna de las bahías que ocupan los dos
contenedores del par. La evidencia es por bahía, y no por zona, porque las bahías de proa
pueden no tener fila central. Si el perfil declara un valor, `true` o `false`, se respeta. La
descripción del resultado dice de dónde salió el hueco: «fila 00 declarada» o «fila 00 ocupada
en este viaje».

**Terminada cuando:**

- El A03 histórico vuelve a 2/100/151, con su perfil todavía en `null`.
- A01 sigue en 47/0/6.
- Una prueba controlada con el perfil en `null` y carga en la 00 de la misma bahía da conforme
  para el par 02/01.
- La misma prueba sin carga en la 00 da posible incumplimiento, como en T‑58.

---

#### T-61 · Al reabrir un viaje, los datos del buque salen del perfil vigente · 1.00 h

**Toca:** la apertura de viajes guardados en `vessel_providers.dart` (alrededor de la línea 412),
una función pura de combinación en el dominio y sus pruebas.

**Por qué.** En la aceptación de T‑42, Timonel encontró que al reabrir un viaje guardado, los
datos del buque salen de la copia de la geometría que se guardó con el viaje: el límite de
apilamiento, la fila 00 por zona, la frontera cubierta/bodega y las anclas de nivel. Las tomas,
en cambio, sí salen del perfil vigente. Si el planificador corrige el perfil desde «Perfiles
guardados», un viaje viejo sigue validando con datos que ya borró. Carlos decidió que se use el
perfil vigente (10.29).

**Qué:**

- Al reabrir se conservan las **dimensiones** del viaje: filas y niveles que su carga necesita.
  La regla «la geometría histórica no se ensancha» sigue en pie.
- Los **parámetros del buque** se toman del perfil guardado vigente: `stackWeightLimitKg`,
  `centerRowOnDeck`, `centerRowInHold`, `deckTierFloor`, `firstHoldTier` y `firstDeckTier`.
- Si aplicar un parámetro vigente dejaría algún contenedor del viaje fuera de la geometría (por
  ejemplo, la fila 00 declarada `false` en un viaje con carga en la 00), se conserva el valor
  guardado de ese parámetro y la interfaz lo dice. No se oculta carga.
- Sin perfil guardado, no cambia nada.

**Terminada cuando:**

1. Con el perfil de ALFA editado desde «Perfiles guardados» (fila 00 «No existe» ×2, límite
   «No lo tengo»), A01 reabierto desde Recientes sin haberlo abierto antes muestra esas
   declaraciones y da 0/0/6.
2. Con el límite cambiado a 62 500.5 kg en el perfil, el mismo viaje reabierto da 47/0/6.
3. Una prueba cubre el caso en que un parámetro vigente dejaría carga fuera.
4. A03 sigue en 2/100/151.

Se verifica en los tres clientes.

---

#### T-62 · Preparar T-47: separar H5 de `main.dart` y analizar qué usa el producto de Firebase · 1.00 h

**No toca `lib/`, `main.dart` ni los archivos congelados.** Informe en `docs/T62-RESULTADOS.md`,
punto de entrada y script en `tool/`.

**Por qué.** T‑47 es MUST y espera la consola. Al prepararla, Yov encontró tres cosas en el
repositorio que conviene resolver antes de que Carlos termine el bloque 0:

1. **Las pantallas de H5 no tienen punto de entrada versionado.** `LatencyTestScreen` y
   `C3ReconciliationScreen` no se referencian desde ningún archivo, y `lib/main.dart` nunca las
   tuvo en git (`git log -S`). La condición de 2.2, «la instrumentación de H5 sigue midiendo»,
   hoy no tiene un procedimiento reproducible.
2. **El producto casi no usa Firebase.** Fuera de los congelados, lo único que toca Firestore es
   `vessel_repository_impl.dart`, y el producto solo llama a `parseBaplieFile`, que no va a la
   red. Pero el constructor pide `FirebaseFirestore.instance`, así que el producto necesita
   Firebase inicializado aunque nunca lo use. Eso cambia qué tiene que hacer T‑47 y si el
   proyecto de producción necesita Firestore o solo Hosting.
3. **El identificador `com.example.baystream`** aparece en `android/app/build.gradle.kts`, en la
   ruta y el paquete de `MainActivity.kt` y en `windows/runner/Runner.rc`. Hay que confirmar la
   lista completa.

**Qué:**

1. **Punto de entrada de H5 en `tool/`** que lance las dos pantallas congeladas sin modificarlas
   e inicialice Firebase con opciones leídas de `--dart-define-from-file`, desde un archivo
   **fuera** del repositorio (`C:\Proyectos\baystream-privado\h5-temporal.json`). Así H5 deja de
   depender de `main.dart`, y T‑47 puede cambiarlo sin riesgo.
2. **Verificar que abre** en Chrome contra el proyecto temporal. Antes de tocar nada, leer las dos
   pantallas para saber qué escribe cada acción. **No ejecutar nada que agregue o borre documentos
   en `latency_test`.** Si no queda claro, solo abrir las pantallas y comprobar la conexión con una
   lectura.
3. **Análisis para T‑47**, sin decidir: qué usa el producto de Firebase, las opciones posibles para
   `main.dart` con sus consecuencias (RNF‑004, H‑04, H‑06, las pruebas existentes), y si el
   proyecto de producción necesita Firestore. Decide Carlos.
4. **Inventario del identificador:** cada archivo y línea que cambia cuando Carlos lo elija, para
   que el cambio de T‑47 sea mecánico.

**Terminada cuando:** el punto de entrada de H5 abre las dos pantallas contra el proyecto temporal
sin alterar `latency_test`, y el informe trae las opciones de T‑47 y el inventario del
identificador.

---

#### T-63 · Proponer el criterio operativo de cada RNF a partir de las dos mediciones · 1.00 h

**No toca código, `docs/` ajenos ni el ERS aprobado.** Informe en `docs/T63-CRITERIOS-RNF.md`.

**Por qué.** T‑44 midió dos veces (10.22 y 10.39) y ningún RNF queda aprobado tal como está
escrito: tres no cumplen y cinco no se pueden medir. 10.22 dejó el paso siguiente: proponer en el
documento el criterio operativo de cada uno, sin reescribir el ERS. Timonel hizo la segunda
medición y sabe de primera mano dónde se rompe cada RNF.

**Qué**, para cada uno de los ocho RNF:

1. El texto literal (de la matriz de `docs/T44-RESULTADOS.md`) y por qué hoy no cumple o no se
   puede medir.
2. Una definición operativa: métrica, instrumento, condición (plataforma, dispositivo, tamaño de
   ventana, archivo del corpus, estado del perfil) y un procedimiento que otro pueda repetir.
3. El umbral. **Se conserva el del ERS.** Donde el ERS no da número o usa un término sin definir
   («sin degradación», el denominador del 95 % o del 80 %), se proponen opciones con su fuente, y
   decide Carlos.
4. Qué dictaría ese criterio con los datos que ya existen, y qué medición nueva haría falta, con
   su estimación.
5. Si cabe en el Sprint 3 o queda fuera del alcance de la tesis.

**Regla contra el sesgo.** Un criterio operativo define *cómo* se mide, no *cuánto* se exige.
Ninguna propuesta puede bajar un umbral del ERS ni elegir una condición porque con ella el
producto pasa. Si un criterio cambia un dictamen de T‑44, el informe lo dice en una línea propia y
justifica la condición sin apoyarse en el resultado. Ejemplo: en RNF‑001, el tamaño de ventana de
Windows se fija por el uso real del planificador, y lo decide Carlos; no por cuál da menos de
200 MB.

**Terminada cuando:** los ocho RNF tienen su propuesta, cada umbral nuevo trae fuente o queda
marcado como decisión de Carlos, y una tabla final dice qué dictamen daría cada criterio con los
datos actuales.

---

#### T-64 · Preparar las declaraciones de Play para la prueba cerrada, comprobadas contra el código · 1.00 h

**Solo documentos. No toca el producto, no compila y no entra a la consola.** Informe en
`docs/T64-DECLARACIONES-PLAY.md`.

**Por qué.** La prueba interna no espera las declaraciones de la app (10.40); la prueba cerrada sí,
y sus 14 días con 12 probadores son lo más lento que queda antes de producción. Si las respuestas
están listas y comprobadas cuando Google apruebe la identidad, Carlos las llena en una sola sesión.

**Qué:**

1. **Inventario de lo que la app hace con datos**, comprobado y no supuesto:
   - los permisos del manifiesto fusionado del APK de T‑44 (`build/app/outputs/flutter-apk/`), leídos
     con las herramientas del SDK de Android, sin compilar;
   - las dependencias que podrían enviar datos (`firebase_core`, `cloud_firestore`), según la
     página oficial de Firebase sobre la sección de Seguridad de los datos de Google Play;
   - lo que mostró RNF‑004 en `docs/T44-FINAL-RESULTADOS.md`.
2. **Una respuesta por declaración** de la sección Contenido de la app: anuncios, acceso a la app,
   clasificación de contenido, público objetivo, Seguridad de los datos, y las que no apliquen, con
   la razón. Cada respuesta cita el dato del inventario que la sostiene.
3. **Política de privacidad.** Verificar con fuente oficial si es obligatoria para esta app.
   Redactar el texto en español, corto y verdadero, con lo que muestra el inventario. Dónde
   publicarla lo decide Carlos; no se crea ninguna página ni se despliega nada.
4. **Lista ordenada de lo que Carlos hará en la consola**, y de lo que falta que no es código: la
   ficha de la tienda (descripción, icono, capturas), el correo de contacto y los probadores.

**Regla.** Nada se declara por suposición. Si una respuesta depende de algo que no se puede
comprobar desde el repositorio, se marca como verificación pendiente. Ante la duda, se escribe la
duda; no se elige la respuesta más cómoda.

**Terminada cuando:** cada declaración tiene una respuesta propuesta con su evidencia, o una
verificación pendiente marcada, y existe el borrador de la política de privacidad.

---

#### T-65 · Cerrar V1 y V2 de T-64: dependencias reales y red del Honor en todas las operaciones básicas · 1.25 h

**No toca código.** Mide sobre el APK ya instalado en el Honor (`C9A91F86`, el de T‑44). Informe
en `docs/T65-RESULTADOS.md`.

**Por qué.** La respuesta de Seguridad de los datos que sostiene la evidencia es «no recopila ni
comparte», pero T‑64 no la declara mientras V1 y V2 sigan abiertas. V2 es además la mitad Android
de la medición que le falta a RNF‑004 según T‑63.

**Qué:**

1. **V1.** Leer el árbol de dependencias de la configuración release con Gradle, sin compilar la
   app ni cambiar archivos versionados. Decir si aparece Firebase Installations, Analytics o
   cualquier biblioteca que transmita por su cuenta.
2. **V2.** En el Honor, con la sonda de T‑44 (`tool/t44_honor_red.ps1`) y además con los
   contadores de tráfico por UID del sistema, que sí cuentan UDP, medir antes y después de cada
   operación básica:
   - abrir un viaje desde Recientes;
   - la búsqueda y las estadísticas;
   - el panel de validación;
   - editar el perfil del buque;
   - exportar el PDF;
   - eliminar un viaje guardado de prueba;
   - dejar la app unos minutos en segundo plano.
3. Si aparece cualquier tráfico, se reporta con su destino y su momento, y se dice qué cambia en
   T‑64.

**Terminada cuando:** V1 tiene el árbol con su conclusión, y V2 cubre todas las operaciones de la
lista con los dos instrumentos, con el resultado tal como salga.

---

## 6. Orden de ataque — por riesgo, no por número

El orden numérico no es el orden de ejecución. En el Sprint 1 atacar primero lo más
riesgoso evitó dos replanificaciones; aquí se repite el criterio.

| # | Bloque | Tareas | h | Por qué va ahí |
|---|---|---|---|---|
| **0** | **Trámites de despliegue** | parte de T-47, T-49 | — | **Empieza el día uno.** Crear el proyecto de producción y abrir el canal de publicación dependen de **terceros**, y un tercero no se apura. Es lo único del sprint cuya duración no la decide el equipo. Lo hace el autor, en paralelo. |
| **1** | **Motor de almacenamiento** | T-35 | 1.0 | La única dependencia nueva del sprint. Si falla en Web, replanifica todo lo que viene después. Mismo criterio que T-08 en el Sprint 1: la decisión de dependencia se verifica antes de que algo dependa de ella. |
| **2** | **Identidad y entidad** | **T-25 → T-24 → T-36** | 3.5 | `Vessel.id` es un UUID aleatorio por parseo: sin clave natural, **ningún perfil se recupera jamás**. Es el bloqueo duro. **La clave va primero** (ver 10.6): su forma decide el campo de identidad de T-24 y la clave de colección de T-36. |
| **3** | **Geometría declarada** | T-26, T-27, T-28 | 3.5 | Toca `vessel_geometry.dart`, el archivo con 42 pruebas encima. Cuanto antes se rompa, más tiempo queda para arreglarlo. |
| **4** | **Parámetros del buque** | T-29, T-30, T-31 | 3.0 | Campos nuevos del perfil. Riesgo bajo: se apoyan en el bloque 3 ya cerrado. |
| **5** | **Interfaz del perfil** | T-32, T-33, T-34 | 4.0 | La pantalla ya existe y funciona; adaptarla es lo mejor entendido del sprint. |
| **6** | **Viajes recientes** | T-37 | 1.0 | Cierra RF-031+. Independiente del resto. |
| **7** | **Validaciones** | T-38 … T-42 | 8.0 | **No puede empezar antes del bloque 5.** T-41 es la de mayor riesgo de desborde: la matriz IMDG es normativa. |
| **8** | **Calidad y seguridad** | T-43 … T-46 | 6.0 | Se mide sobre la versión a liberar; necesita que el producto esté quieto. |
| **9** | **Publicación** | T-48, resto de T-47 y T-49 | 5.0 | Último. Pero el bloque 0 ya dejó los trámites listos hace semanas. |
| **T** | **Lane del segundo programador** | T-50, T-51 (T-53 va detrás del bloque 5, ver 10.14) | 2.5 | **Fuera del compromiso, contra holgura.** Tocan `bay_plan_view.dart`, `bay.dart` y `CLAUDE.md`: ningún bloque de RF-036 los toca, así que avanzan en paralelo. T-50 ✓ cerrada el 19-sep sin cambio de código: el bloque 9 ya no está bloqueado. |

**Regla de detención:** si una tarea pasa del doble de su estimación, **para y repórtalo**.
La holgura del sprint es de 18 h sobre 53 disponibles; una sola tarea desbordada se come un
tercio. T‑41 es la candidata número uno a desbordarse, y hay un plan para ella en su ficha.

---

## 7. Definición de Terminado

Una tarea no está hecha hasta que cumple **todo** esto:

- [ ] Satisface sus criterios de aceptación en los **tres clientes** soportados.
- [ ] Respeta la separación de capas: la presentación no accede a datos, el dominio no
      importa Flutter **ni el paquete de almacenamiento**.
- [ ] `flutter test` en verde. Piso vigente: **169 pruebas** (138 al abrir el sprint).
- [ ] `flutter analyze` sin advertencias nuevas (sin advertencias, a partir de T-43).
- [ ] **Verificada contra al menos un archivo real del corpus**, no solo con datos
      sintéticos. Seis archivos disponibles en la carpeta de archivos anonimizados.
- [ ] Funciona **sin conexión** cuando la historia lo exige — RF-031+ y RF-036 completos.
- [ ] Ninguna prueba existente se borró ni se marcó `skip`. Si una se reescribió, el reporte
      dice cuál y por qué.
- [ ] **Bloque de commit entregado al autor** con el formato de 9.2 — tú no ejecutas git.
- [ ] El mensaje propuesto va en español, **sin acentos** (la terminal del autor corrompe la
      codificación) y referencia el requerimiento:
      `RF-036: añadir perfil` → escribir `RF-036: anadir perfil`.

---

## 8. Qué NO hacer en este sprint

- ❌ **Implementar RF-028** (planificación de secuencia de descarga). Está **diferido** en
  este sprint por decisión registrada. No lo adelantes ni parcialmente.
- ❌ Tocar `latency_test_screen.dart` ni `c3_reconciliation_screen.dart`.
- ❌ **Borrar o vaciar el proyecto Firebase `baystream-h5-temporal-20260814`.** Ahí vive la
  evidencia de H5.
- ❌ Publicar reglas de Firestore o crear proyectos en la consola. Las redactas; el autor
  publica.
- ❌ Mover archivos fuera de `lib/` ni reorganizar carpetas: altera el conteo de `cloc` de H4.
- ❌ **Agregar dependencias** más allá de la de almacenamiento de T-35. Ninguna. Cada
  dependencia que no agregas es evidencia a favor de H4.
- ❌ Silenciar advertencias con `// ignore:` en T-43.
- ❌ Inventar pares de la matriz de segregación IMDG que no puedas sustentar (T-41).
- ❌ Ensanchar un perfil guardado en silencio cuando un viaje no cabe (T-28). Se avisa y se
  pregunta.
- ❌ Fusionar dos perfiles porque el nombre del buque coincide (T-25). Se pregunta.
- ❌ Rediseñar la vista de estadísticas ni el perfil longitudinal. Están cerrados.
- ❌ Modelar las anotaciones a mano del planificador —secuencia de grúa, flechas, `26 MOVS`—.
  Es información valiosa, no está en el EDI, y se discute como alcance nuevo.
- ❌ Refactorizar código que funciona «de paso». El sprint dura cuatro semanas y tiene 26
  tareas.
- ❌ **Ejecutar cualquier comando de git.** Los redactas para el autor; él los corre.

---

## 9. Cómo reportar el avance

### 9.1 · Al terminar cada tarea

Una línea:

```
T-24 hecha · vessel_profile.dart +96 líneas · ida y vuelta toJson/fromJson ✓ · 140/140
```

Si una tarea se desvía **más del doble** de su estimación, detente y repórtalo.

Si encuentras que **algo ya estaba implementado**, repórtalo antes de tocarlo. En este
proyecto ya pasó con RF-020, y el ERS todavía marca RF-011 y RF-014 como propuestos cuando
el código demuestra lo contrario.

Si encuentras un defecto **fuera del alcance** de tu tarea, anótalo y sigue. No lo arregles
de paso: se decide dónde entra.

### 9.2 · Bloque de commit — el formato exacto

Cuando termines una tarea (o un grupo pequeño del mismo requerimiento), entrega **esto y
nada más**, listo para copiar y pegar. No lo ejecutes.

```
──────────── PARA CARLOS · ejecutar en PowerShell ────────────
cd C:\Proyectos\proyecto-baystream

git add lib/features/vessel/domain/entities/vessel_profile.dart
git add lib/features/vessel/domain/entities/entities.dart
git add test/vessel_profile_test.dart

git commit -m "RF-036: entidad VesselProfile con serializacion e ida y vuelta"

git push
──────────────────────────────────────────────────────────────
Qué cambió: entidad de dominio VesselProfile con identidad de buque,
geometria, limite de apilamiento, tomas de reefer y origen del perfil.
Serializacion siguiendo el patron de VesselGeometry.
Archivos: 3 · +118 / -2 lineas · flutter test 140/140 verde
```

Reglas del bloque:

- **Rutas explícitas en `git add`**, nunca `git add .` ni `git add -A`. El repositorio
  arrastra ruido CRLF que ensuciaría el commit con decenas de archivos sin cambios reales.
- **Un commit por requerimiento**, no uno por tarea suelta.
- **Nunca incluyas** en el `git add`: `lib/latency_test_screen.dart`,
  `lib/c3_reconciliation_screen.dart`, `lib/main.dart`, ni nada bajo `docs/`.
- Si el cambio toca `pubspec.yaml` o `pubspec.lock`, **dilo explícitamente** en «Qué
  cambió». Son los archivos que más se revisan, y en este sprint `pubspec.yaml` solo debería
  cambiar **una vez**, en T-35.
- Espera la confirmación del autor antes de empezar otra tarea que toque los mismos archivos.

---

## 10. Decisiones tomadas durante el sprint

*(Se llena conforme avanza. Cada entrada: qué se decidió, por qué, y qué se descartó.)*

### 10.1 · T-50 — el ANR era del emulador, no del producto (19-sep)

**Qué se decidió.** El ANR de Android se cierra como **no defecto**, sin cambio de código.
No bloquea T‑49 ni TC‑04, y el bloque 9 del orden de ataque queda libre.

**Qué se descartó.** La afirmación de `CLAUDE.md` de que el problema seguía vivo. No tenía
reproducción detrás: era una frase de estado que se leyó como evidencia.

**Por qué la evidencia alcanza.** Tres puntos de compilación en dispositivo real, e
incluyen deliberadamente `713da5a`, diez commits **anterior** a la corrección de C‑4
(`3f2ced5`) — el estado donde el defecto tenía más probabilidad de aparecer. Y la única
observación original fue en emulador con APK **debug**, que es JIT: un atasco en debug que
desaparece en release es un fenómeno conocido de Flutter, no una casualidad.

**Lo que queda abierto y a quién.** La no reproducción es evidencia negativa. **T‑44**
hereda la obligación de producir el número positivo: tiempo de apertura del plano de bahía
con el corpus completo, en dispositivo real, sobre el binario a liberar.

**La lección, que es de método y no de código.** Es la **corrección 7** del registro y
pertenece a una categoría distinta de las seis anteriores: esas fueron hechos equivocados
—una cifra, un denominador, un supuesto—; esta es **una frase de estado que se leyó como
evidencia**. La documentación del proyecto fabricó un bloqueador que no existía y estuvo a
punto de detener una tarea MUST.

**Tiene un segundo caso, y es mío.** Al redactar la ficha de T‑50, horas antes, puse
las dos afirmaciones en una tabla como si tuvieran el mismo peso. No lo tenían: un lado
nombraba commit, tipo de compilación, dispositivo, bahía y número de interacciones; el
otro era una aseveración desnuda. **La asimetría de especificidad era, ella sola, la
señal**, y no la leí — la escalé a «bloquea un MUST». La regla que queda: antes de
declarar contradicción entre dos fuentes, comparar qué tan específica es cada una. La que
no nombra condiciones de reproducción no es evidencia, es una nota.

### 10.2 · T-35 — `hive_ce` elegido por medición (19-sep)

**Qué se decidió.** `hive_ce: 2.20.0`, con presupuesto de cinco viajes recientes.

**El número que lo decidió.** `CORPUS_A01` exportado a JSON con `ExportService` mide
**1 788 129 bytes**; cinco viajes proyectan **8 940 645 bytes**. El techo de
`localStorage` del cliente Web es de unos 5 MB y los navegadores lo contabilizan en
UTF‑16, así que el presupuesto real se agota todavía antes.

**Qué se descartó.** `shared_preferences`, que era la opción de **menor** costo para H4 y
la que la ficha aprobada de RF‑031 nombraba primero. Se descartó por medición, no por
preferencia — y eso es precisamente lo que hace defendible la dependencia.

**Orden de verificación.** Web primero, después Windows y Android, con reinicios. Es el
orden correcto: la Web es la que falla, y dejarla para el final habría destapado el
problema con todo lo demás ya construido encima.

**Es la segunda dependencia del proyecto entero**, después de `pdf: 3.12.0`. Las dos
elegidas con criterio escrito y descarte documentado. Para H4 el argumento no es que no se
agregaran dependencias: es que cada una tuvo que ganarse el lugar.

---

### 10.3 · Dos hallazgos que amplían el alcance de T-36 (19-sep)

Salen de revisar el cierre de T‑35. El primero lo señaló Codex; el segundo sale de su
propio número.

**1 · `slotsOccupiedByNeighbors` se pierde al deserializar — y ya está vivo en Firestore.**

`VesselVoyage.fromJson` (`vessel_voyage.dart:301`) reinyecta la **geometría** en cada
bahía, pero **nunca vuelve a llamar a `neighborOccupiedSlots()`**. Todo viaje
deserializado regresa con ese conjunto vacío. Tres consecuencias, todas silenciosas —
ni excepción ni prueba en rojo:

- `occupancyRate` (`bay.dart:92`) une ese conjunto en `occupiedSlotKeys`: la **ocupación
  se sub‑reporta** en cualquier viaje reabierto.
- Las siete bahías impares que C‑5b rescató —sin carga propia, tomadas por un 40 pies
  vecino— vuelven con cero contenedores y cero vecinos, así que `occupancyRate` devuelve
  **0.0** en vez de su ocupación real.
- `bay_plan_view.dart:815` pinta las sombras del 40 pies desde ese conjunto: **desaparecen
  del plano** al reabrir.

**No lo introduce T‑36: ya está en el código entregado.** `VesselRepositoryImpl` guarda
con `voyage.toJson()` y lee con `VesselVoyage.fromJson`, así que cualquier viaje que
vuelva de Firestore lo arrastra hoy. Lo que hace T‑36 es volverlo visible, porque RF‑031+
convierte reabrir un viaje guardado en el flujo principal.

**Y el comentario de `bay.toJson` (`bay.dart:250-251`) afirma lo contrario** — *«son datos
derivados que `VesselVoyage` recalcula»*. Recalcula la geometría; los vecinos no. Ese
comentario equivocado es, con toda probabilidad, la razón de que nadie lo notara. Se
corrige en la misma tarea.

**2 · El 1.79 MB está inflado unas tres veces.** Cada contenedor se serializa **tres
veces**: en `VesselVoyage.toJson` → `containers`, otra vez en el `containers` de su bahía,
y una tercera dentro de `slots` → `ContainerSlot.toJson` → `container`. Son ~1 830 bytes
por contenedor; deduplicado ronda los 610, que es lo realista.

**La decisión de T‑35 no cambia** —comprobado: deduplicado, cinco viajes siguen rondando
los 3 MB, que en UTF‑16 pasan del techo de la Web— *(esta frase quedó desmentida por la
medición real: ver **10.7**. Se conserva tal cual porque la entrada está fechada y el
registro de decisiones no se reescribe hacia atrás.)*, así que no hay que rehacer nada. Pero
**el esquema de T‑36 no tiene por qué heredar la triplicación** del documento de Firestore.

Los dos hallazgos son el mismo principio visto por dos lados: `bays`, `slots` y
`slotsOccupiedByNeighbors` son datos **derivados** de `containers`. Hoy dos se guardan
duplicados y el tercero se pierde — lo peor de las dos opciones. T‑36 los trata a los tres
igual: se guardan los contenedores una vez y lo derivado se reconstruye al leer.

---

### 10.4 · T-51 se adelanta a T-36 (19-sep)

`Bay.toJson` todavía serializa `maxRows` y `maxTiers` (`bay.dart:257-258`). Si T‑36 entra
primero, esos dos campos muertos quedan escritos **dentro del esquema nuevo de Hive**, y
T‑51 deja de ser un borrado de media hora para convertirse en una migración de esquema con
cambio de versión. Orden: **T‑51 → T‑36.**

---

### 10.5 · Dos correcciones a este brief, de Timonel (19-sep)

Las dos ciertas, verificadas contra el código antes de aplicarlas.

**1 · La ficha de T‑29 afirmaba algo falso.** Decía que con T‑29 «muere el
`kStackWeightLimitKg = 90000` provisional como supuesto global». **Ya estaba muerto**: se
retiró en C‑7 (`71ad205`), el 3 de septiembre, dieciséis días antes de abrir el sprint.
`grep` sobre `lib/` y `test/` no devuelve una sola aparición. **La tarea sigue en pie; la
premisa no.** T‑29 no mata un supuesto: le da permanencia por buque a un parámetro que hoy
se vuelve a preguntar en cada viaje.

**Y el brief se contradecía a sí mismo.** El documento de ejecución del Sprint 2 ya decía,
correctamente, que ese supuesto global había muerto; la ficha de T‑29 decía que moriría.
Las dos frases mías, en el mismo cuerpo de documentos. Es la misma clase de defecto que
vengo auditando en los demás: una afirmación que nadie volvió a contrastar contra el
código.

**El recuento correcto, que además favorece más al proyecto.** Los supuestos provisionales
**declarados al tribunal eran dos**, no tres: `kStackWeightLimitKg` y `maxRows`/`maxTiers`.
Los dos están fuera — uno en C‑7, el otro en T‑51, hoy. **BayStream ya no calcula nada
contra una constante inventada**, y eso se puede decir entero, sin asterisco, desde el
segundo día del sprint.

Las anclas de nivel (02, 82, 80) **no eran supuestos provisionales** y no hay que contarlas
ahí: salen de la numeración ISO y están respaldadas por el corpus — 4 584 slots, el nivel
80 sin una sola aparición. Lo que hacen T‑26 y T‑27 es otra cosa: convertir una constante
correcta-en-general en un parámetro declarado por buque.

**2 · El conteo de pruebas.** `baplie_parser_test.dart` pasó de 39 a 40 con la prueba de
compatibilidad de T‑51: **139**. §2.3 y §7 quedan actualizadas, con la regla explícita de
que ese piso sube y nunca baja.

---

### 10.6 · El bloque 2 se reordena a T-25 → T-24 → T-36 (19-sep)

El brief listaba el bloque como «T‑24, T‑36, T‑25», que no es el orden de dependencias.
**La clave natural del buque es la raíz de las tres:** T‑24 declara un campo de identidad
en `VesselProfile` cuya forma sale de T‑25, y T‑36 indexa la colección de perfiles por esa
misma clave. Hacer T‑25 al final obliga a rehacer las otras dos.

Se corrigió al preparar la entrada del bloque, no en ejecución: nadie había empezado.

---

### 10.7 · Bloque 2 cerrado, y una corrección a 10.3 que debilita mi propio argumento (23-sep)

**T‑25 → T‑24 → T‑36 implementadas** (`a0edffa`, `69afd4e`). Claves naturales verificadas
contra los seis TDT, con A05/A06 sin fusionarse. `VesselProfile` es dominio puro: importa
`equatable` y dos entidades, nada de Flutter ni de `hive_ce`. Los vecinos se reconstruyen
en `fromJson`, así que las siete bahías impares —05, 13, 15, 35, 39, 43 y 45— conservan su
ocupación al releer, y el comentario que mentía en `Bay.toJson` quedó corregido. Cinco
viajes completos sobreviven al reinicio en Web, Windows y el POCO.

**La medición real de A01, por representación:**

| Representación | Bytes UTF‑8 |
|---|---:|
| `ExportService`, JSON legible | 1 786 695 |
| Documento completo, JSON compacto | 1 068 938 |
| Esquema local v1, JSON legible | 514 285 |
| **Registro local v1 compacto — lo que se guarda** | **326 442** |
| Cinco registros locales de viaje | **1 632 210** |

Compacto contra compacto, la reducción es del **69,5 %**.

**Lo que esto le hace a 10.3.** Escribí ahí: *«comprobado: deduplicado, cinco viajes siguen
rondando los 3 MB, que en UTF‑16 pasan del techo de la Web»*. **No pasan.** Medidos, los
cinco registros son 1 632 210 bytes — 3 264 420 en UTF‑16, **por debajo** de los ~5 MB. Mi
estimación de ~610 bytes por contenedor era casi el doble de los 334 reales, y toda la
cadena se movió con ella.

**Y la palabra «comprobado» era falsa.** No comprobé: hice aritmética sobre una estimación
y la reporté con la confianza de una medición. Es la tercera vez en este sprint —van la
corrección 7, la premisa de T‑29 y esta— y es exactamente el defecto que la corrección 7
describe. Con un agravante: aquí el error estaba en **mi** argumento y a favor de **mi**
conclusión, que es cuando menos uno lo revisa.

**Qué justifica `hive_ce` ahora, dicho sin adorno.** El tamaño **ya no fuerza la decisión**.
Lo que queda es un juicio sobre margen, y hay que declararlo como juicio:

- **Margen, no imposibilidad.** 1,5× por debajo de un techo que depende del navegador, para
  una retención de exactamente cinco viajes que elegimos nosotros. Seis o siete lo cruzan, y
  la cuota se comparte con todo lo demás que el origen guarde.
- **Forma de acceso.** `shared_preferences` lee una cadena entera; Hive lee un registro. Con
  cinco viajes de ~326 KB, abrir uno obligaría a deserializar los cinco — en el hilo
  principal, en un proyecto que ya tuvo un susto de ANR.
- **Modo de falla.** Exceder `localStorage` lanza excepción: no hay escritura parcial ni
  degradación elegante.

**Ante el tribunal esto se dice así, no de otra forma:** la medición no obliga a Hive; el
margen nos pareció demasiado delgado para construir encima, y esa es una decisión de
ingeniería declarada. Un examinador con calculadora puede rehacer la aritmética, y tiene
que encontrar lo mismo que decimos nosotros.

**Un crédito que NO hay que atribuirle a Hive.** El 69,5 % de reducción, la eliminación de
la triplicación y la reconstrucción de vecinos son propiedades **del esquema**, no del
motor. Con `shared_preferences` se habrían obtenido igual. La tesis no debe presentarlas
como beneficio de la dependencia.

---

### 10.8 · T-45 se parte en dos mitades (23-sep)

La redacción de las reglas y su contraste contra el código van ahora, en la lane del
segundo programador: son la única parte sustancial de TC‑03 que no toca los archivos del
bloque 3, y las reglas las publica Carlos desde la consola, así que necesitan anticipación.
El cableado de autenticación espera a que el árbol vuelva.

*(Nota: esta entrada se anunció como escrita el 23-sep y no se había escrito. Se registra
al detectarlo, no se antedata.)*

---

### 10.9 · El reporte PDF nunca recibió C-2 ni C-4 · nace T-52 (23-sep)

**Cómo salió.** La instrucción de T‑26 —«si algún punto de llamada no puede alcanzar el
perfil, detente y repórtalo»— hizo que Codex parara en
`pdf_report_service.dart:243`. Paró bien. Pero el síntoma que encontró no es el problema.

**Lo que hay de verdad.** `pdf_report_service.dart` menciona la geometría **una sola vez en
todo el archivo**, y solo para llamar a la función estática. **Nunca lee
`voyage.geometry`.** Su rejilla sale de `_orderedRows(rowValues)` y `_tierRange(...)`, que
recorren *lo observado en los contenedores cargados* — mínimo a máximo.

Es exactamente el método anterior a C‑2 y C‑4. `bay_plan_view.dart:432-455` hace lo
contrario desde `3f2ced5`: lee `bay.geometry` y dibuja con `orderedRows`,
`deckTierNumbers` y `holdTierNumbers`.

**Consecuencia:** para el mismo viaje, **la pantalla y el PDF exportado dibujan rejillas
distintas.** La pantalla muestra la geometría declarada —con la fila 00 siempre presente y
los niveles que el buque tiene—; el PDF muestra solo lo que trae el archivo. C‑2 y C‑4 se
cerraron para la pantalla y **el exportador se quedó atrás**, sin que nadie lo notara.

Es un defecto en funcionalidad **MUST ya entregada** (RF‑025, Sprint 1), y del tipo que
aparece en una demostración: se enseña el plano, se exporta el PDF, y no coinciden.

**Nace T‑52 · Migrar el reporte PDF a la geometría declarada · 1.50 h**, fuera del
compromiso, contra holgura, como T‑50 y T‑51. **No se mete dentro de T‑26**: T‑26 mueve una
constante al perfil, no reescribe un exportador.

**Veredicto sobre las cuatro propuestas de Codex.** Tres se aceptan y una no:

- ✅ *Clasificar por la frontera declarada cuando hay geometría.* Es el punto de T‑26.
- ❌ *Sin geometría, rotular «Geometría no declarada» y no calcular pesos por zona.*
  **Resuelve un estado que producción no puede producir.** `confirmGeometry`
  (`vessel_providers.dart:150`) es, según su propio comentario, «el único punto donde un
  viaje pasa a estado publicado», y siempre llama a `withGeometry`. Un viaje publicado
  siempre trae geometría. Rotular el caso imposible lo **tapa**: si alguna vez ocurre es
  una violación de invariante y tiene que ser ruidosa, no cortés. **La salida correcta es
  volverlo imposible en la firma:** que `PdfReportService.generate` exija la geometría, y
  que el estado inválido deje de compilar en vez de manejarse.
- ✅ *Inyectar geometría explícita en las cuatro pruebas C‑7, conservando sus aserciones.*
  Sí — y es el defecto 15 del cruce de auditorías otra vez: cuatro pruebas construyen un
  `Bay` que la aplicación nunca construye, y pasarían igual con el código mal.
- ✅ *Aplicar 80/02/82 al crear perfiles y al leer geometrías antiguas, sin respaldos
  ocultos en los consumidores.* **Sí, y es lo más importante de las cuatro.** El valor por
  omisión vive en el borde —construcción y deserialización—, nunca como un `?? 80` repartido
  por los consumidores. Ese reparto es literalmente cómo apareció el `tier >= 80` suelto en
  `ContainerSlot` que la documentación de `vessel_geometry.dart:53-56` registra.

**Lo que Codex no vio y T‑52 sí debe cubrir:** el problema no es solo la clasificación
cubierta/bodega. `_orderedRows` también se queda con las filas observadas, así que **la
fila 00 desaparece del PDF cuando va vacía** — que es C‑2, no C‑4.

---

### 10.10 · T-45 · se publica la variante B, sin autenticación · §2.5 intacto (23-sep)

**Qué se decidió.** Se publica la variante **B**, sin identidad. **No se autoriza
`firebase_auth`**: §2.5 queda intacta y `hive_ce` sigue siendo la única dependencia nueva
del sprint.

**El dato que lo decide, verificado por los dos.** **El producto no usa Firestore.** El
único llamador de `VesselRepositoryImpl.saveVoyage` es `c3_reconciliation_screen.dart`, que
es pantalla congelada y no es alcanzable desde ninguna ruta de la aplicación. Los otros
`saveVoyage` del árbol son el de Hive y el de `ExportService`, que guarda archivos.

**Por qué B y no A:**

- Meter autenticación protegería una base que **solo toca la instrumentación de H5**.
- **TC‑04 crea el proyecto de producción y ahí se deniega todo.** El producto sale seguro
  con independencia de esta decisión. Ese es el punto más importante del reporte.
- El cableado tendría que rodear archivos congelados, con una sesión que no sobrevive entre
  corridas de `flutter run -d chrome`.
- **La autenticación no haría más confiable la evidencia de H5.** Las mediciones ya están
  tomadas; lo que sí afecta la afirmación probatoria es el hueco del `create`, y eso lo
  cierra B.
- Una tercera dependencia por una razón que no es del producto es difícil de sostener en H4.

**H‑02 no queda abierto: queda re-acotado.** Su enunciado era «creación y actualización
anónimas». Medido lo que de verdad usa Firestore, lo que resta es escritura sobre un
proyecto temporal de instrumentación. B quita la enumeración, deja un solo documento de
viajes y obliga a que las mediciones nazcan abiertas.

**Residual que se declara y no se entierra.** Con B, cualquiera con la clave pública del
proyecto puede leer las colecciones y crear una medición **abierta y bien formada**. Un
tercero podría inyectar ruido en una corrida futura. Se mitiga porque las corridas están
acotadas en ventana y contadas documento a documento — nunca porque sea imposible.

**Corrección a la ficha de T‑45, mía.** Escribí que las cuatro condiciones «impiden falsear
una latencia» y que eran «argumento fuerte para la defensa». **Inmutable después de crearse
no es lo mismo que no fabricable:** `create: if true` permitía crear una medición **nacida
cerrada**, con el `proceso_b_ms` que se quisiera, sin pasar jamás por la transición que las
cuatro condiciones protegen. Hallazgo de Timonel.

El matiz que él aporta se conserva porque acota el daño: **el tiempo de ida y vuelta no se
guarda en Firestore** — lo calcula el emisor con su reloj local y va al CSV. Lo que se
debilitaba era la colección **como registro** —el «99 de 99 cerrados» que citamos como
corroboración independiente—, no las latencias medidas.

**Es la cuarta vez en este sprint que cometo la misma falla, y ya tiene forma
reconocible: verifico la regla que está escrita y no pregunto qué otro camino llega al
mismo estado.** Idéntica a los vecinos —`fromJson` reinyecta la geometría y nadie preguntó
por el otro derivado— e idéntica al ANR —una fuente afirma y nadie preguntó qué la
respalda—. Se nombra aquí porque nombrar la forma es lo que la corta.

**Conteo de `latency_test`, para que siga cuadrando.** La verificación empírica agrega
cuatro documentos: la colección pasa de **99 a 103**, y la cuenta es **66 + 3 + 30 + 4**.
Los cuatro nuevos se anotan como verificación de T‑45, no como corrida de medición.

**Trazabilidad.** La variante A se conserva en `docs/firestore.rules.A-con-identidad` como
registro de la decisión, encabezada por la razón de no haberse publicado. `firestore.rules`
del repositorio se reemplaza con B **en el mismo commit en que B se publique**, para que el
árbol y la consola no diverjan — que es H‑01 otra vez.

---

### 10.11 · T-45 publicada · y el cambio de dispositivo parte la serie de H5 en dos (25-sep)

**B publicada el 25-sep a las 12:33**, `firestore.rules` byte a byte igual a lo publicado
(`8f0d39d`), variante A conservada en `docs/`. Playground 6/6 con el caso de la medición
nacida cerrada rechazado, latencia 4/4, C3 6/6, `latency_test` en **103 documentos, cero
abiertos**, cuadrando 66 + 3 + 30 + 4.

**Los cuatro `PERMISSION_DENIED` son evidencia a favor, no un defecto.** El receptor
congelado intenta un segundo cierre sobre cada documento que acaba de cerrar porque no mira
el tipo de cambio; lo rechaza la condición `respondido == false`. Es la garantía de «se
cierra una sola vez» **funcionando en uso real y con traza** — y es mejor evidencia que las
denegaciones de agosto, porque de estas se conoce la causa. Timonel se negó explícitamente
a extender la conclusión a aquellas, que cayeron sobre documentos históricos. Esa
abstención es correcta y se registra.

---

#### Lo que nadie había mirado: la serie de H5 quedó repartida entre dos teléfonos

La verificación corrió en un **Honor X5d con Android 15**, que reemplazó al **POCO X3
NFC**. Tres consecuencias que no estaban en el reporte:

1. **Los 99 documentos de la serie de H5 —66 + 3 + 30— se tomaron en el POCO.** Los cuatro
   nuevos, en el Honor. La colección mezcla dos dispositivos, dos versiones de Android y dos
   pilas de red.
2. **El esquema no puede registrar cuál.** La regla publicada exige
   `hasOnly(['t0','condicion','evento','respondido'])`: un campo de dispositivo **no se
   puede añadir sin cambiar la regla**. La procedencia de cada medición vive únicamente en
   el registro escrito, no en el dato. Quien calcule estadísticas sobre los 103 documentos
   sin leer este párrafo mezcla dos poblaciones.
3. **La conclusión de T‑50 es evidencia del POCO.** «No reproduce en dispositivo real» se
   midió ahí. Si el POCO ya no está, esa medición no se puede repetir en el mismo hardware,
   y **T‑44 medirá en el Honor** — distinto dispositivo del que sostiene el cierre del ANR.

**Qué hacer, y es barato:** los cuatro documentos del 25-sep quedan etiquetados en el
registro como **verificación de T‑45 en Honor X5d / Android 15**, nunca como parte de la
serie de medición. La serie de H5 sigue siendo **N = 30 en POCO X3 NFC**, y así se reporta.
Si la defensa pide reproducir C1/C2, se reproduce en el Honor y se declara como réplica en
dispositivo distinto, no como continuación de la serie.

**Desviación declarada del procedimiento.** La fase 0 se corrió el **23** y la publicación
fue el **25**, no «justo antes» como se instruyó. Se acepta: la sonda demostró que
discrimina, porque «listar viajes» pasó de 200 a 403 con la misma petición. El residuo es
que cualquier otro cambio en esas 48 horas queda sin atribuir; como el delta observado es
exactamente el que B predice, no hay nada huérfano.

**Pendiente de aclaración.** La sonda final se reporta con **cinco** valores
—`200 · 403 · 403 · 200 · 403`— y la sonda de la fase 0 tiene **cuatro** rutas; la
predicción escrita para B era `200 403 200 403`. Presumo que se añadió `voyages/otro-id`,
lo que es consistente con B, pero **presumir no es evidencia**: cada valor tiene que quedar
rotulado con su ruta en el reporte antes de que esto entre a un documento de tesis.

---

### 10.12 · T-41 · se acepta 49 CFR como fuente, y la evaluación pasa a número ONU (25-sep)

**Qué se decidió.** La matriz de segregación se sustenta en **49 CFR Parte 176**, texto
oficial del eCFR, de dominio público. **No es el Código IMDG y no se afirma equivalencia.**

**Qué se descartó, y por quién.** Timonel encontró copias de terceros del capítulo 7.2 del
IMDG (enmiendas 35‑10 y 40‑20) y **no las usó ni las descargó**, por procedencia, vigencia
y citabilidad. Se detuvo y preguntó en vez de resolverlo solo.

**Por qué 49 CFR es la mejor opción disponible y no una conformidad.** Una fuente que el
tribunal **puede abrir y verificar** vale más que una que no puede. El eCFR tiene texto
oficial y dirección estable; una copia del IMDG de procedencia incierta no es verificable
por un examinador, y eso la hace **peor evidencia** aunque sea la norma que gobierna.

**Lo que va escrito sin ambigüedad**, en el código y en el documento: las reglas
implementadas son 49 CFR Parte 176; **no son el Código IMDG**; no se afirma equivalencia;
para operación real gobierna el IMDG; y la alerta es **apoyo a la decisión, no verificación
de cumplimiento**.

---

#### El hallazgo del número ONU es estructural, no de implementación

La matriz **por clase** falla en `CORPUS_A03` **en los dos sentidos**, con instancias reales
verificadas en el archivo crudo:

| Segmento en A03 | Lo que declara | Por qué falla por clase |
|---|---|---|
| `DGS+IMD+8+3084++I` | clase 8 | UN3084 lleva **5.1 subsidiario**, que **no viaja en el segmento**: junto a clase 3 da un falso **«conforme»** |
| `DGS+IMD+2.1+1950` | clase 2.1 | UN1950 **se segrega como clase 9**: sobre UN3085 da una **falsa alarma** |

**Por eso T‑41 evalúa por número ONU, no por clase**, con tres estados y sin que nada salga
«conforme» por omisión.

**Y es el mismo hallazgo estructural que RF‑036, por otra puerta.** RF‑036 existe porque el
BAPLIE **no transmite el buque**; la evaluación por ONU existe porque el BAPLIE **no
transmite suficiente del perfil de peligro de la carga**. Dos instancias independientes de
la misma limitación del formato, encontradas por rutas distintas y por agentes distintos.
Eso refuerza el argumento central de la tesis y debe decirse así en el documento, no como
dos detalles sueltos.

**Ácidos contra álcalis no se decide desde el BAPLIE.** La norma de EE. UU. remite al IMDG
3.1.4, y en las entradas «n.e.p.» decide el embarcador. Sale como **no evaluado**.

**Alcance sostenible.** De los 28 pares: 9 de código 2, 4 de código 1, 1 de «\*» y 14 de
«X». **Ninguno de código 3 o 4**, que exigirían mamparos. La 1.4 se sostiene, pero **solo
por número ONU** — 1.4S y 1.4G, que §176.144 deja ir juntos.

---

#### Corrección a mi conteo del corpus

Dije **57** segmentos `DGS`. Son **34**, en 30 contenedores. Los 57 incluían
`CORPUS_A03v_VGM`, cuyos 23 segmentos son **byte a byte** los de `CORPUS_A03`. Clases
reales: 3 (14) · 9 (6) · 8 (6) · 1.4 (4) · 2.1 (2) · 5.1 (1) · 4.1 (1).

Las siete clases estaban bien; el conteo no. **Apareció porque la instrucción decía
explícitamente que verificara mi número antes de fiarse de él** — es el control funcionando,
no un accidente. Conviene conservar esa cláusula en las instrucciones futuras.

---

### 10.13 · T-41 y T-46 entregados · el hueco del formato tiene dos formas distintas (25-sep)

**T‑41** en `docs/T41-SEGREGACION-FUENTE.md`: 28 pares con su sección de 49 CFR, 17 números
ONU, ácidos contra álcalis como **no evaluado**, tres estados, y las cuatro frases de
postura en recuadro al principio.

#### El matiz de Timonel afina el paralelo con RF-036

El hueco del formato **no es uno, son dos, y conviene no mezclarlos** porque un examinador
puede empujar justo ahí:

| Forma | Caso | Qué se puede responder |
|---|---|---|
| **El campo existe y viene vacío** | la etiqueta secundaria del `DGS`: el segmento puede llevarla, en `CORPUS_A03` viene vacía | es calidad del dato: a veces se puede leer, en este corpus no está |
| **No hay campo, punto** | las disposiciones de la sustancia (columna 10B) no caben en el formato | es **límite duro**: ninguna implementación lo resuelve leyendo mejor |

**RF‑036 es del segundo tipo**: el BAPLIE no tiene dónde poner la geometría del buque. La
evaluación por número ONU responde a los dos a la vez. Decirlo así —y no «el BAPLIE no
trae la información»— es lo que aguanta la repregunta.

#### T-46 · H-07 cerrado, H-06 bloqueado por una consecuencia de 10.10

**H‑07.** 117 paquetes, **cero vulnerabilidades** en OSV sobre versiones exactas, **con
control positivo** — el control es lo que hace válida la ausencia de hallazgos, igual que
la sonda de T‑45. Licencias permisivas salvo `dbus` (MPL‑2.0), verificado que no entra en
Web ni en Android.

**Tres dependencias directas de producción no se usan en ningún archivo de `lib/`:**
`riverpod_annotation`, `intl` y `cupertino_icons`. Timonel reporta seis declaradas sin uso
contando las de desarrollo. **No se tocan ahora:** cualquier cambio en `pubspec.yaml` obliga
a repetir las tres compilaciones, y Codex tiene el árbol. **Se retiran en la ventana de
T‑43**, que es cuando las tres builds se vuelven a verificar de todos modos.

Retirarlas **fortalece H4**, no lo debilita: cargar dependencias muertas es lo contrario de
la economía de dependencias que la hipótesis afirma, y si en la defensa alguien pregunta
qué hace `intl` en el proyecto, la respuesta honesta hoy es «nada».

**H‑06 · la variante B dejó inservible el registro de consola, y eso no lo previmos.**
Cloud Audit Logs **no registra accesos a recursos alcanzables sin iniciar sesión**, y con B
todo acceso es anónimo. La página de Firestore no lo aclara; Timonel no lo dio por hecho y
dejó un procedimiento con control positivo y regla de decisión: **si solo aparece el
control, H‑06 va a la ventana de T‑47.**

**Es un costo de la decisión 10.10 que se descubre después, no uno que se pesó al
decidir.** No la revierte —H‑06 es severidad **Baja**, y cerrar una Baja agregando una
dependencia y cableando alrededor de archivos congelados es mala economía—, pero se declara
como tal y no como si lo hubiéramos anticipado.

#### Segunda corrección de conteo a este brief, mía

Listé **10** dependencias directas de producción; son **12**. Omití `riverpod_annotation` y
`cupertino_icons`. Es el segundo conteo mío que Timonel corrige, después de los 57 `DGS`
que eran 34.

Las dos veces el error tiene la misma causa mecánica: **enuncié una cifra de memoria en vez
de generarla del archivo en el mismo acto.** Regla operativa que queda: una cifra que entra
a este brief se produce leyendo la fuente en ese momento, nunca recordándola de una lectura
anterior.

#### Convención de dónde viven los informes

**Resuelto: todos los informes van a `docs/`.** La raíz queda para `SPRINT-N.md`,
`AGENTS.md`, `CLAUDE.md` y `README.md`, los cuatro que un agente lee al llegar.

Dos correcciones de Timonel a lo que escribí aquí. **Eran cinco informes en la raíz, no
tres:** a `T35`, `BLOQUE2` y `BLOQUE3` —ya movidos con `git mv`, con la referencia de
`tool/prepare_t35.ps1` corregida— se suman `BLOQUE4` y `T52`, que todavía no están
versionados. Y la regla **no basta en este brief**: los informes de Codex nacen donde
`AGENTS.md` diga, porque es el archivo que Codex lee. Quedó escrita allí.

**Y al escribirla apareció un choque con una regla anterior.** `AGENTS.md` prohíbe incluir
archivos bajo `docs/` en el bloque de git; si los informes nacen ahí, las dos reglas se
contradicen. Resuelto con un recorte explícito: **el propio informe de la tarea en curso es
la única excepción permanente**, por su nombre exacto y nunca por comodín. La prohibición
existe para proteger los entregables de tesis, no para impedir versionar lo que el agente
acaba de escribir.

---

### 10.14 · El hueco del bloque 4 era Android, no Chrome · nace T-53 · orden de la semana (27-sep)

**Corrección mía.** El tablero entregado el 26-sep dice, para T‑29, T‑30, T‑31 y T‑52,
«falta la prueba de ejecución en Chrome». **Es falso.** Los informes de Codex
(`docs/BLOQUE4-RESULTADOS.md` y `docs/T52-RESULTADOS.md`) documentan una ejecución en
**Chrome 154 real**, release, con perfiles guardados en IndexedDB, recarga de la página,
50 tomas recuperadas y el PDF de 62 páginas generado dentro del navegador. Windows también
se ejercitó. **Lo que falta es Android:** el APK compiló, pero no se instaló en el teléfono,
y el informe lo dice expresamente. La columna «En revisión» sigue siendo correcta —a las
cuatro les falta uno de los tres clientes—, pero el motivo estaba mal.

La causa es la misma de siempre: repetí el resumen de una línea («Chrome no quedó
verificado por fallo del ejecutor», que se refería al ejecutor de `flutter test`) sin leer
el informe que lo precisaba. **Lo que no se completa en Chrome es la suite de
`flutter test --platform chrome`, por una ruta del SDK — un problema del ejecutor, no del
producto.** Tampoco se recorrieron a mano el menú de exportación ni el diálogo de descarga.

**Orden para cerrar el hueco sin chocar:** Timonel compila el APK y el cliente Web **desde el
árbol limpio de hoy, antes de que Codex empiece el bloque 5**, y avisa. Con lo compilado
verifica en el Honor X5d y recorre a mano la exportación en Chrome mientras Codex trabaja.
Construir desde un árbol que otro programador está editando probaría una mezcla.

**Nace T‑53**, fuera del compromiso y contra la holgura, detrás del bloque 5. Con ella, la
holgura usada fuera del compromiso llega a 5.0 h (T‑50 2.0 · T‑51 0.5 · T‑52 1.5 · T‑53 1.0)
de 18.0.

---

### 10.15 · T-29, T-30, T-31 y T-52 cerradas en los tres clientes · regla de trabajo en curso (28-sep)

**Android cerrado por Timonel** (`5ec3d82`, `docs/BLOQUE4-ANDROID-RESULTADOS.md`). APK y
Web release compilados desde una copia exacta de `711c79c`, **antes** de que Codex abriera
el bloque 5, con el hash del APK verificado. En el **Honor X5d (NAA‑LX3) / Android 15**
—no es el POCO de la serie de H5—: cargar y confirmar con 75 000 kg (17:53:34); cierre
forzado, reapertura y recarga con el perfil recuperado **sin** pantalla de geometría, con
75 000 kg y «50 posiciones propuestas del archivo» (17:54:47 y 17:55:09); PDF desde el menú
con el diálogo de guardado de Android, 62 páginas, fila 00 en 34 de 34, sin desbordes
(17:56:15). **Chrome 154, a mano por Carlos:** PDF desde el menú, descarga directa
(18:00:30), texto idéntico página por página al del Honor.

Con eso las cuatro tareas cumplen la Definición de Terminado en Windows, Web y Android, y
pasan a Terminado en el tablero.

**Trabajo en curso: límite 1, como fijó Carlos.** Con Codex abriendo T‑32, **T‑46 vuelve a
«Por hacer» marcada como bloqueada**: H‑07 está hecho y H‑06 espera un paso de consola que
no depende de ningún agente. Una tarea detenida por un tercero no debe ocupar la única
plaza de trabajo en curso. Vuelve a «En curso» cuando la consola esté lista y la plaza
libre.

---

### 10.16 · Bloque 5 y T-53 commiteados · falta recorrer la interfaz a mano · T-43 antes que T-37 (28-sep)

**Commiteados:** `b28e7d2` (T‑32, T‑33, T‑34) y `1fa28cc` (T‑53). 202 pruebas, `analyze`
en 49. Codex separó por cliente lo que se **ejecutó** y lo que solo **compiló**, como se
le pidió: sondas con lógica y persistencia reales en Chrome, Windows y Android (APK de QA
con identificador separado, en el Honor X5d). **Dos límites que él mismo declara:** la
interfaz nueva se verificó con pruebas de widgets y no recorriéndola a mano, y el último
ajuste visual se recompiló en los tres clientes **sin reinstalar el APK**. En A01, T‑53
dibuja 1 698 huecos de vecinos verificados por coordenada, sin mover los 977 contenedores
ni las 62 páginas.

**Por eso T‑32, T‑33, T‑34 y T‑53 quedan en revisión** hasta que Timonel recorra las
pantallas nuevas a mano en los tres clientes, con el APK final instalado.

**Orden:** T‑43 va **antes** que T‑37. T‑43 toca muchos archivos y retira seis dependencias
de `pubspec.yaml`; T‑37 toca `vessel_overview_page.dart` y los providers. Con Codex fuera
de sesión, el árbol está quieto: es el momento de T‑43. Codex retoma con T‑37 solo después
de que T‑43 esté commiteada. El bloque 7 (RF‑027) no arranca hasta que RF‑036 esté cerrado
en Terminado, por la precedencia escrita en el tablero.

**La evidencia de Chrome del bloque 4 no estaba en git.** Las secciones del 25-sep en
`docs/BLOQUE4-RESULTADOS.md` y `docs/T52-RESULTADOS.md`, y los scripts
`tool/prepare_block4_web_probe.ps1` y `tool/verify_block4_web.py` que esos informes citan
para reproducirla, existían solo en disco. Se commitean ahora.

**Nota para cualquier agente que lea diferencias con git:** el repositorio guarda los 170
archivos de texto con LF, y el Git de Carlos en Windows los saca con CRLF. Un Git **sin**
conversión de fin de línea verá unos 62 archivos «modificados» que en la máquina de Carlos
están limpios. Usar `git diff --stat --ignore-cr-at-eol` antes de concluir que algo cambió.
El `.gitattributes` pendiente desde agosto eliminaría esa diferencia entre clientes.

---

### 10.17 · RF-036 cerrado · T-43 hecha pero sin ejecutar · Codex toma el resto de la semana (28-sep)

**RF‑036 cerrado.** Timonel recorrió a mano los seis puntos del bloque 5 y T‑53 sobre
`c1199fb` —idéntico en código a `1fa28cc`—, en el Honor X5d con el APK release (SHA‑256
`009d9e7a…`), Windows release y Chrome 154 con la Web release (`dd9bdaa`,
`docs/BLOQUE5-MANUAL-RESULTADOS.md`). **Los tres PDF de A01 coinciden entre sí:** 62 páginas,
1 698 huecos de vecino, 977 celdas propias y el mismo texto. Es la igualdad entre
plataformas que H4 afirma, medida sobre la salida y no sobre el código. T‑32, T‑33, T‑34 y
T‑53 pasan a Terminado, y **el bloque 7 queda destrabado** por la precedencia del tablero.

**Límites declarados:** la celda OOG no se puede ver con datos reales, porque el corpus no
trae segmentos `DIM`, así que solo la cubre el PDF sintético de Codex. En Chrome, Carlos
eligió los archivos en el cuadro de Windows.

**T‑43, hecha por Timonel** (`5c024eb`, `docs/T43-RESULTADOS.md`): `flutter analyze` de 49
incidencias a **cero**, sin un solo `// ignore:`, y las seis dependencias sin uso fuera —
**21 paquetes menos** en el árbol resuelto. Se revisó que el cero sea legítimo: el cambio en
`analysis_options.yaml` quita tres reglas **retiradas en Dart 3.3**
(`avoid_returning_null_for_future`, `iterable_contains_unrelated_type`,
`list_remove_unrelated_type`), que ya no revisaban nada y solo producían el aviso
`removed_lint`; la regla vigente `collection_methods_unrelated_type` cubre las dos de
colecciones. **Queda en revisión:** compila en los tres clientes, pero la aplicación no se
ejecutó con ese build. Su primera ejecución será la verificación de T‑37.

**Timonel queda fuera hasta el miércoles** por créditos. Codex toma las tareas que siguen.
Hasta entonces, **los recorridos a mano de pantallas nuevas los hace Carlos**, con una lista
corta que prepara Codex.

**El presupuesto de cinco viajes nunca se implementó.** T‑35 lo decidió y su informe dejó
la retención para las tareas siguientes; T‑36 no la incluyó y no existe en `lib/`. Le toca a
T‑37. Importa más allá de la interfaz: el argumento de margen que justifica `hive_ce`
(10.7) se apoya en una retención de exactamente cinco viajes.

**Nace T‑54** (0.25 h, contra holgura): el límite se muestra `75000.0` en los clientes
nativos y `75000` en Web. Holgura usada fuera del compromiso: 5.25 h de 18.0.

---

### 10.18 · T-37 y T-54 commiteadas, en revisión · T-43 cerrada · falta el arranque en frío sin conexión (29-sep)

**Commiteadas:** `411ee7c` (T‑37) y `ae72611` (T‑54). 209 pruebas, `analyze` en cero.

**T‑43 pasa a Terminado.** Faltaba ejecutarla y ya se ejecutó: Codex corrió el build posterior
a T‑43 en los tres clientes — Chrome con el build Web final, el APK release final
**instalado y ejecutado** en el Honor X5d, y Windows cargando A01 y reabriéndolo desde
Recientes.

**T‑37 queda en revisión.** Ejecutada en Chrome con el recorrido completo (A01 a A06, cinco
viajes, A01 fuera, seis perfiles conservados, homónimo ECO resuelto) y en Windows. **Falta el
recorrido a mano en el Honor**, que hace Carlos mientras Timonel no está.

**T‑54 queda en revisión.** El formateador da el mismo resultado en la VM de Dart y en
JavaScript, y Chrome lo mostró bien con `75000` y `62500.5`. **Faltan dos cosas:** la
inspección visual en Windows, que se interrumpió al perder el control de la ventana, y ver un
límite fraccionario en el Honor.

**Decisión de producto registrada: la retención es por orden de incorporación, no por uso.**
Guardar el sexto viaje saca el que entró primero; abrir o actualizar uno no lo vuelve el más
reciente. El orden persiste en `savedOrder` y no depende de la fecha del mensaje BAPLIE ni del
orden de los UUID; las escrituras se serializan, probado con ocho concurrentes. Es la opción
determinista; si en la operación real conviene que un viaje abierto se quede, se cambia a
orden por uso. **Decide Carlos.**

**Límite declarado:** los registros guardados antes de T‑37 no tienen ordinal, así que su
orden original de incorporación no se puede reconstruir. Solo afecta datos de prueba.

**Lo que nadie ha probado: el arranque en frío sin conexión.** La prueba sin red de Codex se
hizo con la aplicación **ya cargada**, y el propio informe lo declara. Pero el caso de uso del
proyecto es el muelle: un teléfono sin señal que se abre desde cero. RF‑031+ promete reabrir
viajes sin conexión, y eso incluye arrancar la aplicación sin red. Se agrega al recorrido de
Carlos en el Honor: modo avión, forzar la detención, abrir y reabrir un viaje desde Recientes.
Si falla, es un hallazgo real sobre RF‑031+, no un detalle.

**El bloque 7 queda libre para Codex.** Orden por riesgo: **T‑38 primero**, porque define el
contrato de resultado que reúsan las demás (severidad, descripción, posición); **luego T‑41**,
la candidata número uno a desbordarse; después T‑39, T‑40 y T‑42.

---

### 10.19 · RF-031+ completo · T-38 y T-41 cerradas · A03 tiene 2 posibles incumplimientos reales para revisar (30-sep)

**T‑37 y T‑54 pasan a Terminado** (`46a136e`, `docs/RECORRIDO-CLIENTES-RESULTADOS.md`). Las
nueve comprobaciones se hicieron **sobre la interfaz real de la aplicación de producción,
conducida por Codex**: ADB en el Honor X5d y control de ventanas en Windows, leyendo
controles y capturas. El informe lo dice expresamente: **no fue una revisión hecha por
Carlos en persona.** Se registra así, sin llamarlo «a mano».

**El arranque en frío sin conexión pasó, con rigor:** modo avión, Wi‑Fi apagado, sin red
predeterminada (`Active default network: none`), detención forzada verificada sin proceso
vivo; la aplicación arrancó y A06 abrió desde Recientes con su plano y sus sombras de 40 pies.
Es el caso del muelle, y con él **RF‑031+ queda completo** (T‑35, T‑36 y T‑37).

**T‑38 y T‑41 pasan a Terminado** (`50d4793`, `ea6daad`, `docs/BLOQUE7A-RESULTADOS.md`). 237
pruebas, `analyze` en cero. Sondas ejecutadas en los tres clientes; la pantalla de
segregación de A03 se revisó en Chrome, y en el Honor y Windows dentro del recorrido.

- **T‑38 define `StowageValidationResult`:** regla, estado de evaluación, severidad,
  descripción, posición y fuente, con estado y severidad independientes. Con el límite en
  `null` da cero alertas; en A01, con 75 000 kg de prueba, 33 pilas lo exceden.
- **T‑41 evalúa por número ONU con 49 CFR Parte 176**, cada par con su sección citada en la
  interfaz. La pantalla abre con el descargo: «Apoyo a la decisión, no verificación de
  cumplimiento… No es el Código IMDG ni se afirma equivalencia». Sin pares, dice «Esto no
  declara el viaje conforme».
- **Los dos casos obligatorios:** UN3084 incorpora su 5.1 subsidiario y exige código 2
  frente a las cuatro clases 3 de su nivel. En las posiciones reales de A03 la separación
  transversal alcanza un hueco completo, así que no alerta, y una prueba controlada con los
  contenedores contiguos demuestra que sí alerta. UN1950 sobre UN3085 no da la falsa alarma
  vertical y queda **no evaluado**, sin convertirse en conformidad.

**Resultado sobre el corpus real:** A01 6 conformes; A02 3; A04 1; A05 y A06 un no evaluado
cada uno; **A03, 253 pares: 151 conformes en las reglas evaluadas, 100 no evaluados y 2
posibles incumplimientos.** Que el 40 % de A03 salga «no evaluado» no es una falla: el sistema
dice lo que no puede decidir en vez de declararlo conforme, que es la postura escrita desde
10.12.

**Los 2 posibles incumplimientos son el dato más valioso del bloque y todavía nadie los
revisó.** Son un hallazgo en un plano de carga real anonimizado. Si son reales, BayStream
encontró algo que un plano en papel dejó pasar; si son falsos positivos, T‑41 tiene un
defecto. **Lo decide Carlos como planificador**, con los dos pares listados por Codex.

**Para T‑42:** hoy la pantalla lista los 253 resultados en orden de cálculo, y lo primero
que se ve es «Conforme». El panel debe ordenar por severidad y poner los posibles
incumplimientos arriba.

---

### 10.20 · T-39 y T-40 cerradas · T-42 espera un perfil real · las dos alertas de A03 son válidas (30-sep)

**Commiteadas:** `d045e55` (T‑39), `39bc24b` (T‑40) y `3318da4` (T‑42),
`docs/BLOQUE7B-RESULTADOS.md`. 260 pruebas, `analyze` en cero, sin dependencias nuevas. El
panel se ejecutó y recorrió en los tres clientes, con el APK final instalado en el Honor.

**T‑39 pasa a Terminado.** Una toma ausente en un inventario **declarado** es error; en uno
**propuesto** es aviso, porque una cota inferior no prueba que falte el enchufe. Retirar solo
la toma `0210804` del inventario de prueba produce exactamente una alerta, con la severidad
según el origen.

**T‑40 pasa a Terminado.** Los seis archivos del corpus tienen contenedores de 20 y de 40
pies, y **ninguno produce un positivo**. No se fabricó uno: los casos positivos se cubren con
pruebas controladas. Cero en datos reales es un resultado, no una ausencia de prueba.

**Defecto real encontrado y corregido:** Riverpod 3 consideraba igual el viaje cuando solo
cambiaban las tomas o su origen, que pertenecen al perfil, y el panel no se actualizaba.
`VoyageNotifier.updateShouldNotify` ahora notifica cada instantánea nueva. Lo detectó una
prueba adicional de actualización, no el usuario, y la regresión comprobó aviso → error al
declarar el inventario.

**T‑42 queda en revisión.** Ordena por severidad (error, aviso, información), conserva los no
evaluados con su razón y su contador, lleva la severidad escrita además del tono, y tocar
una alerta abre el plano en la posición correcta: verificado con `0030586` en A03 en los tres clientes, y con `0020108`
en A01 en Windows y Honor; en Chrome, A01 corrió con límite nulo y dio 0/0/6. **Lo que falta es su criterio de terminado literal:** «sobre `CORPUS_A01` con un perfil
declarado completo el panel muestra alertas reales y ninguna alerta cuyo origen no se pueda
explicar». Todos los límites usados son **de prueba** (con 75 000 kg A01 da 33 excesos;
con 62 500.5 kg, 47), y las 50 tomas vienen de la propuesta del archivo. El perfil completo de ALFA
se le pidió a Carlos y no se ha recibido. **Al declararlo hay que decir a qué caso corresponde
el límite:** el perfil guarda un solo límite de peso por pila para todo el buque
(`geometry.stackWeightLimitKg`), y el manual de un buque real normalmente lo da por zona y por
tamaño de contenedor. Esa simplificación va a las limitaciones de la tesis.

**Las dos alertas de A03 son válidas, según Carlos como planificador.** Las dos están en
cubierta, en filas contiguas:

| Par | Carga A | Carga B | Posiciones | Regla |
|---|---|---|---|---|
| 1 | UN1170, clase 3, 40 pies | UN0012, clase 1.4S, 20 pies | 0020386 / 0030586 | código 2, §176.83(b) y (f)(3)-(4) |
| 2 | UN3085, 5.1 con subsidiario 8, 40 pies | UN0303, clase 1.4G, 20 pies | 0260184 / 0270384 | código 2, §176.83(b), (a)(6) y (f)(3)-(4) |

**Es el resultado más fuerte del sprint para la tesis:** un motor de validación encontró dos
alertas de segregación en un plano de carga real, anonimizado, y un planificador de estiba
profesional las juzgó válidas. Se reporta con los mismos límites que declaró Codex: **se
aceptan como alertas de apoyo a la decisión, no como prueba de que el buque real incumplió
el IMDG**; la separación se mide en huecos, no en metros, porque ni el EDI ni el perfil dan
el paso entre huecos; la geometría usada es la propuesta mínima de A03; y las reglas se
contrastaron con la edición oficial 2024 de §176.83 en GovInfo, sin certificar su vigencia a
2026.

**El camino crítico del sprint ya no son los agentes: es Carlos.** De lo comprometido que
falta, casi todo espera una acción suya: el perfil real para aceptar T‑42, los pasos de
consola de H‑06 para T‑46, y el proyecto de producción y la cuenta de tienda para TC‑04.
Lo único que Codex puede avanzar solo es T‑44, **con una condición:** su ficha pide medir sobre
el binario a liberar, y ese binario cambia en T‑47. Se mide ahora sobre la versión candidata,
rotulada con su commit, y después de T‑47 se repiten las mediciones que pasan por Firebase. Si
la aceptación de T‑42 obliga a cambiar código, se repiten también las que ese cambio toque.

---

### 10.21 · T-55 y T-56 para Timonel · dos hipótesis sobre RF-027 (30-sep)

**Timonel vuelve con créditos.** Lo comprometido que queda sin bloquear es solo T‑44, que
tiene Codex. Timonel recibe dos tareas fuera del compromiso, contra holgura, como T‑50 a T‑54:

- **T‑55**: revisión cruzada de RF‑027, sin tocar `lib/`. Puede correr en paralelo con
  T‑44.
- **T‑56**: carga de tomas por rangos. Espera a que Codex entregue T‑44 y a que se resuelva
  la convención de bahía.

La holgura gastada pasa de 5.25 h a 8.25 h, de 18 h.

**Dos hipótesis por lectura de código, que T‑55 debe confirmar o descartar.** Aparecieron al
preparar la aceptación de T‑42, preguntando qué otro camino llega a «conforme» o a «sin toma»:

1. La geometría supone siempre una fila 00. En un buque sin fila central, la separación
   transversal entre 01 y 02 se contaría con un hueco que no existe, y un par de código 2
   podría salir conforme. Es la clase de error que T‑41 prometió no cometer: nada conforme
   por omisión.
2. El validador de tomas compara el código exacto de posición, y un mismo hueco físico
   cambia de número de bahía según llegue un 20 o un 40. Si no se fija la convención, el
   inventario declarado de ALFA produciría alertas falsas.

Ninguna de las dos se da por defecto hasta que tenga reproducción. Las dos preguntas tienen
además respuesta de planificador, que Carlos conoce sin mirar el código: si el buque de ALFA
tiene fila 00, y cómo lista su documentación las tomas.

**Trabajo en paralelo.** Carlos decide que los dos programadores trabajen a la vez. El límite
de trabajo en curso pasa de una tarea a **una tarea por programador**. Las reglas para no
chocar quedaron en `AGENTS.md`, en la sección «Trabajo en paralelo», que leen los dos al
llegar. Lo esencial:

- nunca dos tareas sobre el mismo archivo;
- `lib/`, `test/` y `pubspec.*` son de una sola tarea a la vez;
- un comando de Flutter a la vez;
- mientras uno mide tiempos, el otro no ejecuta nada en esa máquina;
- Carlos hace de semáforo.

De paso, `AGENTS.md` dejó de mandar a leer `SPRINT-1.md` y de prohibir adelantar RF‑027, que
ya está casi cerrado.

---

### 10.22 · T-44 y T-55 entregadas: ningún RNF queda aprobado tal como está escrito, y dos defectos latentes del modelo (30-sep)

**T‑44 (`c966fae`), medida sobre la versión candidata `1607263`.** Los tres binarios release
tienen los mismos hashes que los del bloque 7b. De los ocho RNF del ERS aprobado, **ninguno
queda aprobado**:

- **No cumplen (4):**
  - RNF‑001: 314.8 MB de memoria residente en Windows con A01, contra menos de 200 MB.
  - RNF‑002: seis pasos hasta el plano en la primera carga, contra tres como máximo, y un
    texto en inglés.
  - RNF‑006: el mensaje de error da la causa pero no la acción sugerida.
  - RNF‑008: pide el Código IMDG, y la segregación declara 49 CFR 176.
- **No se pueden medir tal como están escritos (4):** RNF‑003, 004, 005 y 007. Les faltan
  definiciones operativas (qué es «sin degradación», el denominador del 95 % o del 80 %) o
  pruebas fuera del alcance (Android 8.0, pantallas de 27", 10 000 contenedores).

Para la tesis esto es un resultado, no algo que esconder. Los RNF se escribieron en el Primer
Entregable, antes de existir la forma de medirlos, y medirlos de verdad muestra cuáles no eran
verificables. El paso siguiente es proponer en el documento el criterio operativo de cada uno,
sin reescribir el ERS aprobado.

**El número que T‑44 le debía a 10.1.** Se hicieron 35 aperturas del plano de bahía en el
Honor: siete archivos, cinco repeticiones cada uno, APK release. Todas quedaron **por debajo de
0.91 s**. Es una cota superior: la captura ADB tarda de 610 a 797 ms, así que el tiempo real es
menor, aunque no alcanza a resolver los 100 ms de RNF‑001. Frente a los 5 s que Android da a un
evento de entrada antes de declarar ANR, el cierre de T‑50 ya no descansa solo en «no se
reprodujo».

**Matices que quedan anotados.**

- **Memoria.** El RNF no dice qué métrica usar. En Windows se midió el conjunto de trabajo, que
  incluye páginas compartidas; en el Honor, PSS 164 MB y RSS 209 MB. Con la métrica comparable
  (RSS), las dos plataformas pasan de 200 MB; con PSS, Android cumple.
- **Los seis pasos vienen de RF‑036.** La primera carga de un buque sin perfil pregunta la
  plantilla y el límite; con el perfil guardado, esas preguntas desaparecen. Se reporta como
  incumplimiento literal y se explica como costo de una decisión de diseño.

**Corrección al informe de T‑44: el error de Chrome en el puerto 8787 es de la sonda, no del
producto.** El texto `BLOCK7_ERROR` solo existe en el manejador de errores de
`tool/prepare_block7_probe.ps1`, y el `singleWhere` que lanza «Too many elements» está en
`tool/block7_checks.dart:69`. El producto muestra sus errores como «No se pudo cargar el viaje:
…». Lo que corrió en 8787, un origen de QA del bloque 7a, fue la sonda, no el binario
candidato. No se probó el mecanismo (lo más probable es la caché del service worker de Flutter),
pero el hallazgo se cierra: no hay un defecto del producto detrás.

**El inglés de RNF‑002 sí es del producto.** La captura `build/t44/honor-invalid-result.png`
muestra «No se pudo cargar el viaje: Bad state: No se encontró el nombre del buque en el
segmento TDT». El «Bad state:» es el `toString()` de un `StateError` de Dart. El patrón aparece
en más de quince lugares de `lib/`: los fallos se envuelven en `StateError` y la
presentación interpola `$error`. Se abre **T‑57**, contra holgura.

**T‑55 (`ceaf4c6`), 2.0 h de 1.5 estimadas.** Las dos hipótesis de 10.21 quedan confirmadas como
**defectos del modelo**, con reproducción en `tool/t55_*.dart`. **Ninguna cambia hoy un
resultado del corpus.**

1. **Fila 00.** Un par de código 2 en las filas 02/01 sale conforme. ALFA, BRAVO y DELTA nunca
   cargan la fila 00; CHARLIE y ECO la usan solo en cubierta. Si el perfil llega a declararla,
   tiene que ser por zona.
2. **Tomas de reefer.** Con el inventario marcado como declarado, que el mismo hueco físico
   reciba el otro tamaño produce 91 errores en A01 (82 más 9). Además, qué impares cubre cada
   bahía par depende del buque: ALFA tiene contenedores de 40 pies en la bahía 044. Por eso
   T‑56 no puede calcular esa correspondencia con aritmética.

La tabla de segregación coincide con la fuente y con la edición 2024 de §176.83 en los 28 pares
y los 17 números ONU. Quedan un defecto de severidad baja (el código «\*» de 1.4/1.4 le gana al
código 2 cuando hay una etiqueta C236) y una duda (los tanques se tratan como unidad cerrada).
Las trazas a mano de T‑38 a T‑41 coinciden con el panel. Sale una duda nueva para las
limitaciones de la tesis: el peso por pila parte en dos las 42 columnas mixtas de A01.

Las hipótesis salieron de preguntar qué otro camino llega a «conforme»; la confirmación vino de
un revisor que no escribió el código. Es el patrón de la doble prueba, otra vez.

**Tablero.**

- T‑55 pasa a Terminado.
- T‑44 pasa a En revisión: está medida y reportada, pero su ficha pide el binario que se
  publica, y lo que pasa por Firebase se repite después de T‑47.
- T‑57 entra en Por hacer.
- No queda nada en curso.

**Cuatro decisiones de Carlos que salen de T‑55:**

1. ¿ALFA tiene fila 00, y en qué zonas?
2. ¿Las tomas se listan por hueco de 20, por hueco de 40 o por extremo? Esta es la que
   destraba T‑56.
3. ¿Se corrige la precedencia del «\*»?
4. ¿Se aceptan los tanques como unidad cerrada?

---

### 10.23 · Respuestas de Carlos a T-55: ALFA no tiene fila 00; T-58 y T-59 (30-sep)

**1. Fila 00: ALFA no la tiene, ni en cubierta ni en bodega.** Carlos mandó capturas de Baplie
Viewer con `CORPUS_A01.edi` cargado. La conclusión es de Yov, con esta evidencia, y Carlos puede
confirmarla a primera vista:

- **Bahía 009/010 en cubierta.** Las filas 12 a 02 y 01 a 11 están ocupadas en los niveles 82 a
  88, y la columna 00 está vacía en los cuatro niveles. Son seis filas por banda, doce en total.
- **Bahía 009/010 en bodega.** Las filas 10 a 02 y 01 a 09 están ocupadas en los niveles 02 a
  12, y la 00 está vacía en todos. Son cinco filas por banda, diez en total.
- Nadie deja vacía la pila central de una bahía estibada por completo en todos sus niveles. Con
  un número par de filas, la numeración no tiene fila central: la 00 solo existe cuando el
  número de filas es impar.
- T‑55 ya había contado cero posiciones en la fila 00 entre las 977 de A01.

**Baplie Viewer también dibuja la columna 00** («0.0» de peso en las dos zonas). La columna vacía
en el dibujo es una convención de presentación, así que el plano de BayStream no está mal por
mostrarla. El error estaba solo en que el validador la contaba como hueco. Por eso T‑58 corrige
la segregación y no toca el dibujo.

**2. Convención de tomas: Carlos no la conoce.** Se delega a T‑59, una investigación sin tocar
`lib/`, con fuentes públicas y con el corpus. La respuesta que valdría para ALFA sigue siendo la
documentación de tomas del buque real; T‑59 propone una convención que resista cualquiera de las
respuestas.

**3. Precedencia del «\*»: se corrige** en T‑58.

**4. Tanques como unidad cerrada: se aceptan.** La inferencia se escribe con su fuente, §176.2,
en T‑58.

**Orden por la regla de `lib/` (una tarea a la vez):**

- Codex hace T‑57 y después T‑58.
- Timonel hace T‑59 en paralelo, sin tocar `lib/`.
- T‑56 espera a T‑59 y a la decisión de Carlos sobre la convención.

El trabajo fuera del compromiso ya usa 12.75 h de las 18 de holgura: 12.25 h estimadas de T‑50
a T‑59, más la media hora que T‑55 pasó de su estimación.

---

### 10.24 · T-59 cerrada · T-56 pasa al Sprint 3 · el criterio de T-42 se redefine sin inventar datos (30-sep)

**T‑59 (`40fba22`), 1.1 h de 1.0.** No hay respuesta pública sobre en qué extremo de la celda va
la toma de reefer. Yov contrastó las fuentes en el original:

- **SMDG #79** (abril de 2025) dice textualmente: *«There is no standard for vessel profiles,
  profile depends on software of owner»*.
- El **survey de van Twiller et al.** (arXiv 2307.07573) solo dice *«Some cells have power plugs
  for refrigerated containers»*.
- Los códigos **RFA** y **RFF** de SMDG muestran que el motor del reefer se orienta a proa o a
  popa según el embarque.

Yov también verificó el corpus contra `CORPUS_A01.edi`:

- Los pares con carga de 40 son 002 a 038 de cuatro en cuatro, más la 044.
- La 041 va sola, con un contenedor de 20.
- La 044 lleva 25 contenedores de 40.
- Los nueve reefers de 20 están en la 021, y en la 023, a popa en la misma fila y el mismo
  nivel, hay nueve 22G1 secos.

**Decisiones de Carlos:**

1. **T‑56 pasa al Sprint 3.** La sección 3 de `docs/T59-RESULTADOS.md` queda como su
   especificación: guardar cada toma como celda más extremo, con la tabla de pares del buque en
   el perfil, y validar por celda física. Hoy no hay un inventario real que cargar, y la holgura
   que queda se reserva para el despliegue (T‑47 a T‑49, que son MUST).
   - **Limitación documentada:** con un inventario **declarado**, que el mismo hueco físico
     reciba el otro tamaño produce errores falsos (91 en el escenario de T‑55). Con el inventario
     **propuesto**, que es el único que existe hoy, produce avisos con su origen explicado.
   - Sin T‑56, el trabajo fuera del compromiso baja a **11.25 h de 18**.
2. **El criterio de T‑42 se redefine, sin inventar datos.** El criterio original pedía A01 «con
   un perfil declarado completo». Cumplirlo al pie de la letra obligaba a inventar el límite de
   apilamiento y el plano de tomas de ALFA: Carlos no tiene esa documentación, y T‑59 mostró que
   no es pública. El criterio nuevo está en la ficha de T‑42. Se acepta después de T‑58, porque
   la declaración de la fila 00 no existe hasta entonces.

---

### 10.25 · Guía del bloque 0: dos hallazgos que cambian T-47 y T-49 (30-sep)

Carlos tiene una guía paso a paso del bloque 0: la cuenta de Google Play, el proyecto de
Firebase de producción, la clave de subida y la prueba de H‑06. Es un artefacto aparte, con
casillas que recuerdan su avance. Al prepararla contra las fuentes oficiales aparecieron dos
cosas que el brief no tenía.

**1. El identificador de la app es `com.example.baystream`, y Google Play lo rechaza.** Play no
admite identificadores que empiecen con `com.example`. Además, el identificador no se puede
cambiar después de registrar la app Android en Firebase ni después de la primera subida a Play
(documentación de Firebase y de Flutter). Carlos lo elige antes de crear el proyecto de
producción. En código, el cambio va en T‑47: `applicationId`, `namespace` y el paquete de
`MainActivity`. Para Android será otra app, así que los datos de prueba del Honor no pasan.

**2. El criterio de T‑49, «se instala desde el canal público», no cabe antes del 17-oct.**
Una cuenta personal de Play creada después del 13 de noviembre de 2023 necesita, antes de
publicar en producción:

- una prueba cerrada con al menos 12 testers inscritos durante 14 días seguidos;
- una revisión de la solicitud de acceso, que suele tardar siete días o menos.

El reloj arranca cuando el paquete ya está en la pista cerrada, y para eso hace falta T‑49.
Aun con verificación rápida, producción queda hacia el 26-oct. Lo que sí cabe es instalar la
app en el Honor desde la prueba interna o cerrada de Google Play. **Queda para que decida
Carlos** si el criterio de T‑49 se redefine así en este sprint, con producción después.

**Corrección mía a la ficha de T‑49.** Escribí que, si se pierde la clave de firma, «no hay
forma de volver a publicar una actualización de esa aplicación, nunca». Con Play App Signing,
que es lo predeterminado en apps nuevas, Google guarda la clave con la que firma lo que instalan
los usuarios, y **una clave de subida perdida se puede reemplazar** con una solicitud desde Play
Console. La instrucción de respaldarla fuera del repositorio sigue en pie; la frase era
exagerada.

---

### 10.26 · T-57 commiteada, en revisión: falta Chrome con el binario final (1-oct)

**T‑57 (`7a034ee`).** 262 pruebas y `analyze` en cero.

- Los fallos conocidos llegan tipados hasta la presentación (`VesselOperationFailure`).
- Cada mensaje lleva causa y acción, en `presentation/formatters/vessel_error_message.dart`.
- Lo desconocido muestra un texto genérico en español con acción, y el detalle va a
  `debugPrint`.
- La prueba nueva falla si un mensaje trae «Bad state», «Exception» o «FormatException». Cubre
  también la carga real del `VoyageNotifier`.
- Las únicas interpolaciones de excepciones que quedan en `lib/` están en
  `c3_reconciliation_screen.dart`, que está congelado.

**Queda en revisión** por la Definición de Terminado de los tres clientes. Con el binario final
hay evidencia del Honor (los dos casos) y de Windows (el segundo caso). En Chrome los dos casos
se vieron bien **antes** de la última recompilación; con el binario final, la automatización del
selector de archivos no terminó, y Codex lo declara así. Lo cierra Carlos en dos minutos:
eligiendo a mano los dos archivos en Chrome con el build Web de T‑57, antes de que T‑58 lo
recompile.

**Dos notas menores.**

- El hash que el informe da para Windows es el de `baystream.exe`, el lanzador, y es idéntico
  al de T‑44: el código Dart vive en `data/app.so`. Ese hash no prueba que se compiló de nuevo.
  En adelante se reporta el de `app.so`.
- Codex editó `docs/T44-RESULTADOS.md` dentro de T‑57 para aplicar la corrección de 10.22. Es su
  propio informe y lo declaró; se acepta.

**Mejora para el Sprint 3, no defecto:** un archivo que no es BAPLIE, como
`T44_INVALID.edi`, recibe el mensaje de «no trae el nombre del buque en el segmento TDT». La
acción sirve, pero la causa sería más exacta como «el archivo no es un BAPLIE».

---

### 10.27 · T-57 y T-58 cerradas · el A03 histórico revela un hueco en mi especificación de T-58 · nace T-60 (1-oct)

**T‑57 pasa a Terminado.** Carlos cargó a mano en Chrome los dos archivos con el build Web final
de T‑57 (`main.dart.js` SHA‑256 `50CD6971…`, servido en el puerto 8801), y los dos mostraron
causa y acción sin «Bad state».

**T‑58 (`3e721c9`) pasa a Terminado.** 272 pruebas y `analyze` en cero.

- La fila 00 se declara por zona: `true`, `false` o `null`. La propuesta pone `true` solo donde
  el archivo trae carga en la 00.
- Con `null`, las filas 01 y 02 son vecinas. En bodega, el par queda «no evaluado», porque el
  mamparo podría dar la separación.
- El «\*» ya no le gana al código 2.
- La inferencia sobre los tanques queda escrita con §176.2.
- Los casos de las sondas de T‑55 pasaron a pruebas.
- El perfil de ALFA guardado antes de T‑58 abrió sin error en los tres clientes y muestra
  «No declarada» en las dos zonas.
- Los totales: A01 queda en 47/0/6, y A03 con una propuesta nueva en 2/100/151.

**El A03 histórico pasa a 4/98/151, y el defecto está en mi especificación, no en el código.**
Los dos pares que se suman, `0260184 / 0260284` y `0260286 / 0260184`, cruzan 01/02 en la
cubierta de la bahía 026, donde **la 0260084 está ocupada**. El hueco existe y tiene un
contenedor dentro: son alertas falsas. El perfil histórico abre en `null`, y la especificación
que escribí solo tomaba la evidencia del archivo al momento de proponer el perfil, no al
validar. Pasa lo mismo con cualquier perfil que persiste entre viajes, el caso central de
RF‑036, cuando un viaje posterior ocupa una 00 que el primero no tocó. Codex lo explicó como
pedía la ficha; la corrección es mía.

**Nace T‑60** (0.5 h, contra holgura): durante la validación, la 00 que el propio viaje ocupa
cuenta como existente cuando la declaración es `null`, con evidencia por bahía. El trabajo fuera
del compromiso queda en **11.75 h de 18**.

**Para vigilar:** una corrida de la suite terminó con `pumpAndSettle timed out` en
`recent_voyages_test.dart`, un archivo que T‑58 no tocó, y la repetición pasó. Es la primera
señal de una prueba inestable. Si vuelve a pasar, se investiga antes de seguir sumando pruebas
de interfaz.

---

### 10.28 · T-60 cerrada · el criterio de T-49 se redefine a la prueba interna de Google Play · T-42 lista para aceptación (1-oct)

**T‑60 (`5e67522`) pasa a Terminado.** 273 pruebas y `analyze` en cero.

- El validador junta la ocupación de la fila 00 de **todos** los contenedores del viaje,
  separada por zona y por bahía. Un 40 cuenta también para sus dos impares.
- Con la declaración en `null`, la fila 00 solo cuenta como hueco si hay carga en la 00 de la
  misma zona y en alguna bahía que ocupa el par.
- La descripción dice de dónde salió el hueco.
- En Windows release, el A03 histórico, con su perfil todavía en `null`, vuelve a **2/100/151**,
  y A01 sigue en **47/0/6**.
- Los hashes son de `app.so`, `main.dart.js` y el APK, como se pidió.

**El criterio de T‑49 se redefine (decisión de Carlos, por recomendación de Yov).** El criterio
anterior era «la aplicación se instala desde el canal público en un dispositivo real». El nuevo
está en la ficha de T‑49. Las razones:

- **Restricción externa con fuente oficial.** Una cuenta personal nueva de Google Play necesita
  14 días de prueba cerrada con 12 testers, y una revisión de hasta 7 días, antes de producción
  (10.25). Eso no cabe antes del 17-oct.
- **El MUST no depende de la tienda.** TC‑04 dice «Despliegue en la nube **o** tienda de
  aplicaciones», y T‑47 con T‑48, el cliente Web publicado, ya lo cumplen. T‑49 agrega el canal
  Android.
- **Se elige la interna y no la cerrada** porque la interna no tiene requisitos previos. La
  cerrada exige completar la ficha de la tienda y pasar una revisión.

En paralelo y **fuera del sprint**, el mismo paquete se sube a la prueba cerrada con 12 a 15
testers, para que corran los 14 días. Producción queda para finales de octubre o inicios de
noviembre. **Si Google no verifica la identidad de Carlos a tiempo**, T‑49 queda en revisión con
esa causa escrita, sin evidencia sustituta.

**T‑42 queda lista para su aceptación.** T‑58 y T‑60 dieron la declaración de la fila 00 que el
criterio redefinido (10.24) necesitaba. La hace Timonel, que no escribió T‑42, sobre los binarios
de T‑60 sin recompilar.

---

### 10.29 · T-42 aceptada y cerrada · al reabrir, los viajes usarán el perfil vigente (T-61) (1-oct)

**T‑42 pasa a Terminado** (`1487048`, `docs/T42-ACEPTACION-RESULTADOS.md`). La aceptación la hizo
Timonel, que no escribió T‑42, sobre los binarios de T‑60 sin recompilar. Verificó los hashes,
incluido el del APK ya instalado en el Honor. Con el criterio redefinido (10.24):

- **A01**, con lo que el planificador puede declarar (fila 00 «No existe» en las dos zonas,
  límite «No lo tengo» y tomas propuestas), da **0/0/6 en Windows, Honor y Chrome**. Son seis
  pares conformes entre las cuatro unidades peligrosas, y no hay alertas de peso, de toma ni de
  apilamiento. Cada tarjeta lleva su descripción y su fuente.
- **A03** da **2/100/151 en los tres clientes**. Los dos pares que validó Carlos quedan arriba, y
  el plano abre en 0020386 y en 0260184.
- De los 100 «no evaluados», 99 son por grupos de segregación (§176.83(m)) y 1 por la excepción
  de (a)(8). **Ninguno queda sin motivo.**
- Las sondas de T‑55 confirman corregidos los dos defectos.

**Límites que Timonel declara:**

- No es el perfil real de ALFA. La regla de peso con un límite declarado quedó cubierta por el
  bloque 7b, no por esta aceptación.
- En Chrome leyó una sola tarjeta de «no evaluado». La muestra de diez la hizo en Windows y el
  Honor, y la sonda revisó los 100.
- El A03 del Honor es la variante `A03v_VGM`. Repite los mismos 23 DGS, así que el panel da lo
  mismo.

**Hallazgo: al reabrir un viaje guardado, los datos del buque salen de la copia guardada con el
viaje, no del perfil vigente.** Yov lo verificó en el código: `vessel_providers.dart:412` toma el
perfil guardado pero le reemplaza la geometría por la histórica del viaje. Como desde T‑29 el
límite y, desde T‑58, la fila 00 viven **dentro** de la geometría, quedan congelados con el viaje.
Las tomas, que viven en el perfil, sí se actualizan. Es una inconsistencia de diseño que nadie
había medido. **Carlos decide usar el perfil vigente.** Nace **T‑61** (1.0 h, contra holgura). El
trabajo fuera del compromiso queda en **12.75 h de 18**.

**Para el Sprint 3, solo redacción:** varias tarjetas «No evaluado» empiezan con «Código 2:
separación satisfecha en el modelo de huecos…» antes de la cláusula de los grupos. Quien lea solo
el cuerpo puede quedarse con «satisfecha».

**Estado del compromiso:**

- **Terminado:** 21 tareas, 27.5 h.
- **En revisión:** T‑44, que repite tras T‑47 lo que pasa por Firebase.
- **Por hacer:** T‑46, T‑47, T‑48 y T‑49, las cuatro detrás de pasos de consola de Carlos (la
  guía del bloque 0).

---

### 10.30 · T-61 cerrada · dos hallazgos del entorno de prueba · lo comprometido que falta depende de la consola (1-oct)

**T‑61 (`5df7e16`) pasa a Terminado.** 281 pruebas (273 más 8 nuevas) y `analyze` en cero.

- Al reabrir desde Recientes, el viaje conserva sus dimensiones y toma del perfil vigente los
  seis parámetros del buque.
- La combinación es una función pura de dominio, `current_profile_parameters.dart`. Aplica los
  parámetros uno por uno, empezando por la frontera, y conserva el valor guardado de cualquiera
  que dejaría carga fuera del plano. Recientes lo avisa.
- Una prueba comprueba que el panel se recalcula al reabrir después de editar solo el perfil,
  que es la clase de defecto de Riverpod del bloque 7b.
- Aceptada en los tres clientes con A01 editado solo desde «Perfiles guardados»: **47/0/6** con
  62 500.5 kg y **0/0/6** con «No lo tengo». El editor del viaje reabierto muestra la fila 00 del
  perfil, y A03 sigue en **2/100/151**.
- **Una prueba se reescribió.** `recent_voyages_test.dart` afirmaba el contrato anterior: que
  reabrir conservaba toda la geometría histórica. Ahora afirma el que pidió Carlos. Timonel
  declara que ninguna aserción se borró sin reemplazo; se acepta porque el cambio de contrato
  está decidido y escrito en 10.29.

**Dos hallazgos del entorno de prueba, no del producto.**

1. **Windows: la app lanzada por Codex usaba un almacén virtualizado.** Codex de escritorio es una
   app empaquetada, y lo que lanza hereda la virtualización de archivos de Windows: el almacén
   local quedaba en `%LOCALAPPDATA%\Packages\OpenAI.Codex_…\LocalCache\Local\BayStream`, no en el
   `%LOCALAPPDATA%\BayStream` real. La lógica probada es la misma. Pero las pruebas de
   persistencia en Windows que lanzó Codex (T‑37, T‑58) pudieron usar ese almacén y no el de
   Carlos. No se comprobó caso por caso, y la tesis lo dice así. En adelante, cada informe dice qué almacén usó (regla agregada en
   `AGENTS.md`).
2. **Chrome: con la ventana minimizada, Flutter se congela.** Con la pestaña oculta, el navegador
   detiene los cuadros de animación: los menús no abren y las capturas expiran. Explica los
   tropiezos de T‑42 en Chrome. La ventana controlada tiene que quedar visible (regla agregada en
   `AGENTS.md`).

**Estado.** Lo comprometido va en **27.5 de 35 h**: 21 tareas terminadas y T‑44 en revisión. Las
cuatro que faltan (T‑46, T‑47, T‑48 y T‑49) esperan pasos de consola de Carlos, todos en la guía
del bloque 0. Fuera del compromiso, de T‑50 a T‑61 (sin T‑56), van **12.75 h de 18** estimadas.
Los agentes no tienen nada comprometido sin bloquear: descansan hasta que avance la consola.

---

### 10.31 · T-62 para Timonel: preparar T-47 mientras la consola avanza (1-oct)

Con lo comprometido esperando la consola, Timonel prepara T‑47 sin tocar `lib/`. Yov encontró
en el repositorio tres cosas que la ficha de T‑47 no contemplaba: las pantallas de H5 no tienen
un punto de entrada versionado, el producto inicializa Firebase sin usarlo más que para crear una
instancia de Firestore, y el identificador `com.example` aparece también en el recurso de
Windows. El detalle está en la ficha de T‑62.

Ningún cambio en `main.dart` ni en los congelados. El punto de entrada lee las opciones de un
archivo fuera del repositorio; Carlos lo autoriza al mandar la tarea.

El trabajo fuera del compromiso sube a **13.75 h de 18**. Quedan 4.25 h de holgura para lo que
destape el despliegue.

---

### 10.32 · T-62 cerrada · Carlos elige la opción B para T-47 (1-oct)

**T‑62 (`318fcbd`) pasa a Terminado.** No tocó `lib/`, `main.dart` ni los congelados.

- **H5 ya no depende de `main.dart`.** `tool/h5_main.dart` abre las dos pantallas congeladas con
  opciones leídas por `--dart-define-from-file` desde
  `C:\Proyectos\baystream-privado\h5-temporal.json`, fuera del repositorio. Ese archivo lo generó
  `tool/t62_h5_opciones.ps1` sin imprimir los valores.
- **Verificado en Chrome** contra `baystream-h5-temporal-20260814`, solo con lecturas:
  `latency_test` tiene 103 documentos (99 de H5 más 4 de T‑45, como dice 10.10), y el documento de
  C3 existe. Las dos pantallas abren, y no se ejecutó ninguna acción que escriba.
- **Lo que el producto usa de Firebase:** nada más que `FirebaseFirestore.instance` en el
  constructor de `VesselRepositoryImpl`. El producto solo llama a `parseBaplieFile`, que no va a
  la red, y ninguna prueba inicializa Firebase. La pantalla C3 congelada usa la misma clase, así
  que cualquier cambio va en el proveedor, no en la clase.
- **Inventario del identificador:**
  - `android/app/build.gradle.kts`, líneas 9 y 24;
  - `MainActivity.kt`, línea 1, y además hay que mover la carpeta al paquete nuevo;
  - `windows/runner/Runner.rc`, líneas 92 y 96, solo metadatos («com.example»).

  No aparece en ningún otro archivo.
- **Hallazgo para T‑49:** el `release` de Android hoy se firma con la clave de depuración
  (`build.gradle.kts:34-36`).

**Decisión de Carlos: opción B.** El producto inicializa Firebase contra el **proyecto de
producción**, con las opciones leídas de un archivo fuera del repositorio. Yov había recomendado la
opción A (el producto sin Firebase); la decisión es de Carlos. Lo que implica:

- **H‑04 se cierra en el código fuente.** El binario Web sigue llevando las opciones, como
  cualquier cliente de Firebase; no son secretas.
- **El proyecto de producción necesita las apps Web y Android registradas, pero no Firestore.**
  Crear una instancia de Firestore no contacta al servidor, y el producto no lee ni escribe nada.
  Con eso, el paso de la guía del bloque 0 que crea la base de datos se puede omitir.
- **RNF‑004:** en Web, la app sigue bajando el SDK de Firebase al iniciar, sin transmitir datos
  del usuario. La medición de T‑44, cuando se repita, tiene que distinguir esa descarga.
- **Riesgo que T‑47 debe medir:** en Web, `initializeApp` baja el SDK desde `gstatic` antes de
  `runApp`. Sin conexión, el arranque en frío podría fallar. En Android el SDK es nativo y no se
  descarga. T‑47 prueba el arranque en frío sin red en los tres clientes; si Web falla, lo reporta
  sin corregirlo, y se decide aparte.
- **H‑06** se queda en el proyecto temporal: el producto no usa Firestore, y Cloud Audit Logs no
  registraría nada suyo. La prueba de consola de la guía sigue en pie para la evidencia de H5.

**Antes de T‑47, Carlos respalda `h5-temporal.json`.** Después de T‑47, `main.dart` ya no tendrá
esos valores. Siempre se pueden volver a copiar de la configuración del proyecto temporal en la
consola, pero conviene no depender de eso.

**Lo comprometido sigue esperando la consola.** T‑47 se hace en una sola pasada cuando estén el
identificador y el proyecto de producción con sus dos apps. El trabajo fuera del compromiso queda
en **13.75 h de 18**.

---

### 10.33 · Identificador definitivo: `gt.cmartinez.baystream` (1-oct)

Carlos elige el identificador de la app: **`gt.cmartinez.baystream`**. Queda fijo para siempre al
registrar la app Android en Firebase y en la primera subida a Google Play. T‑47 lo aplica con el
inventario de `docs/T62-RESULTADOS.md`:

- `applicationId` y `namespace` en `android/app/build.gradle.kts`;
- el paquete de `MainActivity.kt`, cuya carpeta pasa a `kotlin/gt/cmartinez/baystream/`;
- los metadatos de `windows/runner/Runner.rc`.

Carlos sigue con la guía del bloque 0: primero la cuenta de Google Play, porque es lo que más tarda
en resolverse por terceros.

---

### 10.34 · Bloque 0, primera sesión: cuenta de Play, proyecto de producción, clave de subida y H-06 verificado (1-oct, noche)

Carlos hizo el bloque 0 guiado por Yov, con las páginas abiertas en su navegador. Él completó
cada pantalla, aceptó los términos e hizo el pago y la verificación. Yov solo leyó las pantallas.

**Google Play Console.**

- Cuenta personal creada y pagada (25 USD), a nombre de **Carlos G. Martínez**, con el perfil
  de pagos a su nombre legal tal como figura en el DPI.
- Dispositivo Android verificado, con la app Play Console en el Honor.
- **Pendiente de Google:** la verificación de identidad (el DPI ya está subido) y, después, la del
  teléfono. Hasta entonces el botón «Crear aplicación» queda bloqueado. Es el plazo externo que
  10.25 y 10.28 anticipaban.

**Firebase de producción.**

- Proyecto **`baystream-app`** en el plan Spark, sin Google Analytics y sin Gemini. La versión Web
  se publicará en `baystream-app.web.app`.
- Dos apps registradas: **Web**, con Hosting vinculado, y **Android**, con el paquete
  `gt.cmartinez.baystream`.
- Firestore no se creó, como dice 10.32.
- La configuración Web y `google-services.json` están en `C:\Proyectos\baystream-privado\`,
  fuera del repositorio. Ningún valor pasó por el chat.

**Clave de subida de Android.** `upload-keystore.jks` (RSA de 2048 bits, alias `upload`, validez
de 10 000 días) quedó en la carpeta privada. Está respaldada junto con los demás archivos privados
en el Google Drive personal de Carlos, y la contraseña está guardada aparte.

**H‑06 se cierra desde la consola, sin código.** Se siguió el procedimiento de
`docs/T46-DEPENDENCIAS-Y-REGISTRO.md` en el proyecto temporal:

1. **Paso 0.** Los cambios de reglas ya quedaban auditados sin configurar nada: `CreateRuleset` a
   las 12:33:32 y `UpdateRelease` a las 12:33:33 del 25-sep, con la cuenta de Carlos, 24 segundos
   antes de la sonda de T‑45.
2. **Paso 1.** Carlos activó la lectura y la escritura de datos para «Firestore/Datastore API».
   No pidió facturación.
3. **Paso 2, control positivo.** Las lecturas de Carlos desde la consola aparecen como `Listen`,
   con su correo. La primera apertura, a las 19:49, no quedó registrada, porque la configuración
   tarda uno o dos minutos en propagarse.
4. **Paso 3, la prueba.** La sonda anónima de las 19:51 devolvió dos 200 y **quedó registrada**:
   `GetDocument` sobre `voyages/c3-measurement-voyage` y `ListDocuments` sobre `latency_test`. Las
   dos entradas están atribuidas a la cuenta de servicio de Firebase Rules, con `auth` vacío, la
   **IP de origen**, el agente (`curl`) y el documento leído.

**La sospecha de T‑46 era falsa para Firestore.** La regla general de Cloud Audit Logs dice que
los recursos accesibles sin iniciar sesión no generan registros, pero un acceso anónimo a Firestore
sí se registra, porque pasa por Firebase Rules. Timonel no lo dio por hecho y dejó una prueba con
control positivo y una regla de decisión: eso permitió llegar a esta respuesta en lugar de
diferirla a T‑47. No se probaron `Write` anónimo ni `Listen` anónimo: haría falta escribir en el
proyecto de la evidencia, y la lectura basta para la decisión.

**Queda la mitad de alertas de H‑06**, que son alertas en Cloud Monitoring sobre estos registros.
No se investigó. Los registros quedan activos: en el plan Spark no hay cobro posible, y el volumen
es mínimo.

---

### 10.35 · H-06, mitad de alertas: la política está bien configurada, pero no se disparó (1-oct, noche)

Carlos creó en Cloud Monitoring, sobre el proyecto temporal, la política de alertas basada en
registros **«BayStream H5 · Acceso anónimo a Firestore»**. Yov verificó su detalle en la consola:

- **Consulta:** `protoPayload.serviceName="firestore.googleapis.com"` y
  `protoPayload.authenticationInfo.principalEmail` igual a la cuenta de servicio de Firebase
  Rules. Atrapa solo los accesos anónimos; las lecturas de Carlos con su cuenta quedan fuera.
- **Gravedad:** Advertencia.
- **Frecuencia:** una notificación cada 5 minutos como máximo.
- **Cierre automático:** a los 30 minutos.
- **Canal:** correo de Carlos.
- **Documentación:** dice qué revisar (IP de origen y documento) y cita H‑06 y T‑46.
- **Costo:** ninguno. Las alertas de registros no se cobran; el cobro de alertas que Google
  anunció para septiembre de 2027 no las incluye.

**Control positivo de la alerta: falló.** Se hicieron tres lecturas anónimas, a las 19:51, a las
20:15 y a las 20:22. El detalle de la política muestra las seis entradas que coinciden con su
consulta. Aun así, a las 20:29 Monitoring no tenía **ninguna alerta abierta**, y el Gmail de
Carlos no tenía ningún correo de alerta, ni en Spam. Se descartaron las causas de la guía oficial
de solución de problemas:

- los registros no están excluidos;
- la consulta encuentra las entradas;
- no se extraen etiquetas;
- no se alcanzó el límite diario.

**La causa no está confirmada.** La hipótesis principal es que el proyecto temporal está en el
plan Spark, sin cuenta de facturación. No se encontró una fuente que lo afirme para las alertas
de registros en general.

**T‑46 sigue en revisión.** H‑07 está cerrado. La mitad de registro de H‑06 está verificada
(10.34). La mitad de alertas está configurada, pero su funcionamiento no se ha comprobado, y no se
reporta como cerrada mientras ningún disparo llegue al correo.

**Siguiente intento:**

1. Revisar si la alerta se abrió tarde.
2. Si no, probar el otro camino de Cloud Monitoring: una métrica basada en registros que cuente
   los accesos anónimos, más una alerta de umbral sobre esa métrica.
3. Si tampoco se dispara sin facturación, H‑06 cierra la mitad de alertas como limitación
   declarada.

---

### 10.36 · T-47 cerrada · la Web requiere conexión para arrancar en el Sprint 2 (1-oct, noche)

**T‑47 (`ba7353a`) pasa a Terminado.** Yov la verificó contra el repositorio:

- `lib/main.dart` lee seis opciones Web y cinco Android con `String.fromEnvironment`. No tiene
  valores en duro ni de respaldo.
- Si falta una opción, la app muestra un aviso en español y no inicializa Firebase. Una prueba
  nueva lo fija: **282 pruebas**, `analyze` en cero.
- El identificador **`gt.cmartinez.baystream`** está en `namespace`, en `applicationId` y en el
  paquete de `MainActivity.kt`, que se movió a su carpeta nueva. Los metadatos de `Runner.rc`
  también se ajustaron.
- `.gitignore` protege `*.jks`, `*.keystore`, `key.properties` y `firebase-prod*.json`.
- El commit no trae ninguna clave de producción. Las únicas claves que aparecen en el diff son
  las del proyecto temporal, y aparecen como líneas eliminadas.
- Ningún archivo privado está versionado. `pubspec.*` no cambió y no se agregó el plugin de
  Gradle de Google Services.

**Los tres criterios de la ficha se cumplen:**

1. **Existe el proyecto de producción:** `baystream-app` (10.34).
2. **`main.dart` no lleva claves escritas en duro.**
3. **H5 sigue midiendo.** `tool/h5_main.dart`, recompilado sin cambios, abre las dos pantallas
   congeladas, y la comprobación de solo lectura da `latency_test` = 103 antes y después.

Con los binarios finales, A01 da 0/0/6 y A03 da 2/100/151 en los tres clientes. **Windows y el
Honor arrancan sin red.** Codex declaró que el almacén de Windows fue el virtualizado de su
paquete, como pide la regla de 10.30, y que en el Honor la app nueva convive con la vieja
`com.example.baystream`, con su almacén aparte.

**La Web no arranca sin red ni caché.** Carlos lo confirmó a mano: la página queda en blanco
porque no puede bajar CanvasKit ni la fuente Roboto desde `gstatic`. El riesgo de Firebase que
anticipó 10.32 no se pudo aislar, porque el arranque falla antes, al cargar el motor.

**Decisión de Carlos: en el Sprint 2, la Web requiere conexión para arrancar.** Queda documentado
como limitación:

- El caso del muelle sin señal lo cubre Android, que sí arranca sin red.
- Que la Web arranque sin red exigiría servir CanvasKit, Roboto y el SDK de Firebase desde el
  propio Hosting, y eso pasa al Sprint 3.
- La prueba se hizo con la caché desactivada. Es el peor caso: no dice qué pasa con un navegador
  que ya abrió la app antes.

**Para la tesis, sobre H‑04:** el repositorio es público, y las opciones del proyecto temporal
siguen en el historial de git. Sacarlas de `main.dart` no las borra de ahí. Las claves web de
Firebase no son secretas: lo que protege los datos son las reglas.

**Lo que sigue en TC‑04:**

- **T‑48** (publicar la Web) puede empezar ya.
- **T‑49** se divide en dos partes:
  - la **firma**: configurar `key.properties` y Gradle, y compilar el `.aab` firmado. Puede
    empezar ya.
  - la **subida a la prueba interna**: espera a que Google apruebe la identidad de Carlos.

---

### 10.37 · T-49, parte 1: el `.aab` queda firmado con la clave de subida · Timonel repite T-44 mientras Google responde (1-oct, noche)

**T‑49, parte 1 (`b93027f`), verificada por Yov contra el repositorio.**

- `android/app/build.gradle.kts` carga `android/key.properties` con `java.util.Properties` y crea
  `signingConfigs.release` solo si el archivo existe. Sin él, firma con la clave de depuración y
  Gradle avisa que Play lo rechazará. Es el patrón de la guía oficial de Flutter.
- `android/key.properties.example` lleva marcadores, sin contraseña real.
- El commit trae solo `build.gradle.kts`, la plantilla y el informe. `key.properties` está ignorado
  (`android/.gitignore:12`); ni él ni el `.jks` están versionados. `lib/`, `test/` y `pubspec.*` no
  cambiaron.
- Ni el informe ni los registros de `build/t49/` contienen la contraseña.

**Resultado.** El `.aab` pesa 47 027 711 bytes (SHA‑256 `C60FFF0C…679D`) y está firmado por
`CN=Carlos Martinez, OU=BayStream` (`jarsigner`: `jar verified`), con `versionCode` 1 y
`versionName` 1.0.0 tomados de `pubspec.yaml`. Certificado de subida: SHA‑1
`D7:69:20:6A:…:94:F9`, SHA‑256 `4C:C0:F6:B1:…:20:C4`. Son públicos, y la consola de Play debe
mostrar los mismos al recibir el primer paquete.

**Hallazgo: el archivo de Carlos se llamaba `key.properties.txt`.** Es la segunda vez que Windows
esconde una extensión; la primera fue `firebase-prod-web.txt.txt` (10.34). Con ese nombre, Gradle
habría firmado con la clave de depuración y `.gitignore` no lo cubría: un archivo con la contraseña
quedaba a un `git add` de distancia. Timonel lo renombró sin leerlo. Dos medidas:

- Carlos activa en el Explorador *Vista → Mostrar → Extensiones de nombre de archivo*.
- Cuando cierre T‑48, `.gitignore` pasa a cubrir `key.properties*` (con excepción para la
  plantilla) y la carpeta `.firebase/` que crea el despliegue. Se deja para después de T‑48 para
  no cruzarse con Codex, que puede estar tocando `.gitignore`.

**T‑49 sigue En curso.** Falta la parte 2, que es el criterio de la ficha: subir el `.aab` a la
prueba interna e instalarlo en el Honor desde Play. Espera a que Google apruebe la identidad de
Carlos.

**T‑44 se repite, ahora con Timonel.** Desde la medición sobre `1607263` cambió el código del
producto (T‑57, T‑58, T‑60, T‑61 y T‑47). Por eso se repiten los ocho RNF, no solo lo que pasa por
Firebase:

- **Windows y Honor**, sobre el código de `b93027f`.
- **Web**, sobre la versión publicada por T‑48 en `baystream-app.web.app`.
- **En Android se mide un APK release** firmado con la misma clave de subida y compilado del mismo
  código que el `.aab`. El APK que entrega Play lo genera Google desde el `.aab` y lo firma con su
  propia clave; esa diferencia se declara. Cuando el Honor instale desde Play (T‑49, parte 2), se
  repite una cifra de control.

Que la mida un programador distinto del que la midió primero es, otra vez, la doble prueba.
Timonel queda con dos tarjetas porque T‑49 espera a un tercero; T‑44 sigue En revisión hasta que
entregue.

**Estado.** Lo comprometido sigue en **29.0 de 35 h**: T‑48 y T‑49 en curso, T‑44 y T‑46 en
revisión.

---

### 10.38 · T-48 cerrada · la Web está publicada en `baystream-app.web.app` (1-oct, noche)

**T‑48 (`080d589`) pasa a Terminado.** Yov la verificó contra el repositorio y el informe:

- `firebase.json` solo configura Hosting: publica `build/web` y reescribe toda ruta a
  `/index.html`. No trae Firestore, y `firestore.rules`, que es del proyecto temporal, no se
  desplegó. `.firebaserc` apunta a `baystream-app`.
- El `main.dart.js` publicado tiene el mismo SHA‑256 que el local y que el de T‑47
  (`4939E264…2C38`): `lib/` no cambió desde `ba7353a`. 282 pruebas en verde y `analyze` en cero.
- Lo desplegó Carlos con `firebase deploy --only hosting --project baystream-app`. Codex no
  desplegó.

**El criterio de la ficha se cumple en el dominio real.** En `https://baystream-app.web.app`, A01
da 0/0/6 y A03 da 2/100/151. Después de recargar la página, Recientes conserva los dos viajes y
Perfiles guardados conserva ALFA y CHARLIE: el almacén local de T‑35 funciona en la versión
publicada.

**Red.** En la sesión que Carlos observó con DevTools, ninguna petición fue a
`firestore.googleapis.com`. Sí se descargan los scripts `firebase-app.js` y
`firebase-firestore-pipelines.js`: es descarga de código, no envío de datos del usuario, y la
repetición de T‑44 tiene que separar las dos cosas (RNF‑004). Hubo además una petición fallida del
service worker a la raíz del sitio, sin efecto visible; si se repite en T‑44, se registra.

**Caché.** Hosting sirve todo con `no-cache, max-age=0, must-revalidate`. Una versión nueva llega
en la siguiente visita, sin quedarse atrapada en caché; el costo es una revalidación por archivo
al abrir. Es coherente con 10.36: la Web requiere conexión.

**Sobre el método.** La automatización de Codex se detuvo cuando no pudo confirmar con certeza la
URL de Chrome, y no intentó eludir el aviso; Carlos hizo esa comprobación a mano. El informe dice
que la evidencia cubre esa sesión, no todos los flujos posibles.

**`.gitignore` (lo que dejó pendiente 10.37).** Ahora cubre `.firebase/`, la caché que crea el
despliegue, y `key.properties*` con excepción para `key.properties.example`. Comprobado con
`git check-ignore`: `key.properties.txt` queda ignorado y la plantilla no.

**Estado.** Lo comprometido va en **30.5 de 35 h**, con 23 tareas terminadas. Faltan:

- **T‑44** (en revisión): Timonel la repite, y la Web ya se puede medir sobre el dominio real.
- **T‑46** (en revisión): la mitad de alertas de H‑06, con Carlos en la consola.
- **T‑49** (en curso): la subida a la prueba interna espera a Google.

Codex queda sin tarea comprometida.

---

### 10.39 · T-44 cerrada: tres RNF no cumplen y cinco no se pueden medir tal como están escritos (1-oct, noche)

**T‑44 (`d805443`), repetida por Timonel sobre `3ac98f6`, pasa a Terminado.** Yov la verificó
contra el repositorio:

- `lib/` es idéntico al de `ba7353a`. `analyze` está en cero y las 282 pruebas pasan.
- Se midieron los binarios que publica TC‑04:
  - `app.so` `C3097007…`, el mismo de T‑47;
  - el `main.dart.js` publicado, `4939E264…`, el mismo de T‑48;
  - un APK, `C9A91F86…`, firmado con el mismo certificado de subida que el `.aab` de T‑49.
- El commit trae el informe, la variable `T44_OUT` en `tool/t44_honor_bay_plan.dart` (sin cambiar
  el método) y la sonda nueva `tool/t44_honor_red.ps1`, que solo lee `/proc/net/tcp` por ADB.

**Resultado frente a `1607263`.** RNF‑001, 002 y 008 siguen sin cumplirse. RNF‑003, 004, 005, 006
y 007 no se pueden medir tal como están escritos. El único dictamen que cambia es el de
**RNF‑006**, que pasa de «no cumple» a «no medible»: gracias a T‑57, el mensaje del archivo
inválido ya trae causa y acción, y la app se recupera sin reiniciar. Pero un solo tipo de archivo
corrupto no demuestra el «100 %» que pide el RNF.

**Lo que esta medición agrega para la tesis:**

- **La RAM de Windows depende del tamaño de la ventana.**
  - Maximizada, 416.7–422.0 MB.
  - A 1280×720, 209.0 MB recién restaurada y 199.4 MB después de navegar.
  - Codex no registró el tamaño de la ventana, así que sus 314.8 MB no se comparan de forma
    estricta. Un criterio operativo de RNF‑001 tiene que fijar esa condición.
- **Los pasos dependen del contexto.** En la primera carga de un buque sin perfil hay 6 pasos en
  la Web, porque ya existían otros perfiles y aparece el diálogo de plantilla, y 5 en el Honor
  recién instalado. Con el perfil guardado hay 3 pasos, dentro del límite. Es el costo de RF‑036
  que ya anotaba 10.22.
- **RNF‑004 tiene evidencia propia por primera vez.**
  - **Web.** Al arrancar hay 13 peticiones, todas `GET`: la propia app, el motor y el SDK de
    Firebase desde `www.gstatic.com`, y las fuentes. Al cargar A01 y A02 y al usar el plano, las
    estadísticas y la búsqueda no hubo **ninguna petición**, y ninguna fue a
    `firestore.googleapis.com`.
  - **Honor.** **0 conexiones TCP** durante el arranque en frío (120 s) y la carga de A01 (180 s).
    El control positivo con GMS demuestra que la sonda sí ve conexiones.
  - **Límites declarados:** la sonda no ve UDP ni QUIC, muestrea cada 250 ms y no ve las
    peticiones del service worker.
- **La memoria del Honor subió.** PSS pasó de 164 a 180 MB y RSS de 209 a 228 MB, tras los siete
  archivos y A06. Queda reportado, sin explicar.

**Dos cosas que quedan anotadas:**

1. **El Honor perdió los datos de `gt.cmartinez.baystream`.** Para instalar el APK con la clave
   de subida, Timonel desinstaló, con autorización de Carlos, la versión firmada con depuración de
   T‑47. **Lo mismo pasará en T‑49, parte 2:** Play entrega la app firmada con la clave de Google,
   así que antes de instalar desde Play hay que desinstalar la actual. Son datos de prueba.
2. **El informe tiene una frase cortada** en la observación sobre las bahías de RNF‑007 («El parser
   auxiliar cuenta posiciones de»). Timonel la corrige. La diferencia de bahías (27 contra 34 en
   A01) viene desde `1607263` y queda anotada sin diagnosticar.

**Queda para T‑49, parte 2:** la cifra de control sobre el APK que entrega Play (memoria y apertura
del plano con A01), como prometía 10.37.

**Para el Sprint 3:**

- A 360 px de ancho, el título se trunca y la pastilla de vacíos queda cortada (RNF‑003).
- La diferencia de bahías.

**Estado.** Lo comprometido va en **32.0 de 35 h**, con 24 tareas terminadas. Faltan T‑46 (la
alerta de H‑06, mañana con Carlos en la consola) y T‑49, parte 2 (espera a Google). El paso que
sigue para la tesis es el que dejó 10.22: proponer en el documento el criterio operativo de cada
RNF, sin reescribir el ERS aprobado.

---

### 10.40 · Sin correo de la alerta y sin respuesta de Google · el producto queda quieto · T-63 para Timonel (2-oct)

**T‑46.** La alerta de registros de 10.35 no envió ningún correo en toda la noche. Se pasa al
paso 2 de 10.35: una métrica basada en registros que cuente los accesos anónimos, más una alerta
de umbral sobre esa métrica. La guía oficial de solución de problemas de alertas basadas en
registros no menciona la facturación entre sus causas, así que la hipótesis del plan Spark sigue
sin confirmar.

**T‑49, parte 2.** Google aún no aprueba la identidad de Carlos. La ayuda de Play Console dice que
la prueba interna puede empezar antes de completar la configuración de la app, y que las apps en
pistas de prueba interna están exentas de la sección de Seguridad de los datos. Cuando llegue la
aprobación, la subida no espera esas declaraciones; sí las pedirá la prueba cerrada del Sprint 3.

**El producto queda quieto.** T‑44 midió los binarios finales, los mismos que publicaron T‑47 y
T‑48. Cualquier cambio en `lib/` de aquí al cierre obligaría a repetir esas tres verificaciones.
Por eso lo que queda del sprint para los programadores es análisis, no código. Los defectos de
interfaz que encontró T‑44 a 360 px van al Sprint 3.

**Nace T‑63** (1.0 h, contra holgura), para Timonel: proponer el criterio operativo de cada RNF a
partir de las dos mediciones, con una regla explícita contra el sesgo. Con ella, el trabajo fuera
del compromiso sube a **14.75 h de 18**.

**Estado.** Lo comprometido sigue en **32.0 de 35 h**.

---

### 10.41 · T-63 cerrada: 22 decisiones de Carlos y unas 57 h de medición pendiente · nace T-64 (2-oct)

**T‑63 (`33c3c34`) pasa a Terminado.** Yov la revisó contra su ficha:

- Los ocho RNF tienen definición operativa: métrica, instrumento, condición y procedimiento.
- Los umbrales del ERS se conservan. Donde el ERS no define algo, hay opciones con fuente enlazada;
  son **22 decisiones de Carlos**.
- Cada opción que cambiaría un dictamen tiene su línea propia. Ninguna recomendación convierte un
  «no cumple» en «cumple». En RNF‑002, Timonel recomienda la lectura literal del ERS aunque la otra
  opción haría cumplir el RNF.
- Los dictámenes de T‑44 siguen vigentes.

**Una corrección.** El informe dice que el Honor X5d está «declarado por Carlos como dispositivo
de referencia del usuario objetivo». Carlos no lo declaró. Se corrige: es el único dispositivo
Android con el que se midió, y si representa la gama media del planificador lo decide Carlos (1.1).

**Lo que más pesa para la planificación.** La medición nueva suma **unas 57 h** sin la prueba con
usuarios ni IMDG, y unas 66 h con usuarios. Es más que la capacidad entera de un sprint (53 h en
el Sprint 2). La planificación del Sprint 3 tiene que elegir qué RNF se miden y cuáles quedan como
limitación declarada. Las 22 decisiones se toman ahí, empezando por las de los RNF elegidos, no
ahora.

**Dos hallazgos que van al Sprint 3**, porque el producto queda quieto (10.40):

1. En la Web, «Confirmar y ver el plano» abre en la pestaña Lista, no en el plano.
2. El corpus anonimizado puede tener dígitos de control ISO 6346 rotos. Las pruebas de RNF‑008
   tienen que usar identificadores de prueba propios, no el corpus.

**Nace T‑64** (1.0 h, contra holgura), para Timonel: preparar las declaraciones de Play para la
prueba cerrada, comprobadas contra el código. El trabajo fuera del compromiso sube a
**15.75 h de 18**.

**Estado.** Lo comprometido sigue en **32.0 de 35 h**.

---

### 10.42 · T-64 cerrada: «no recopila ni comparte» todavía no se puede declarar · nace T-65 (2-oct)

**T‑64 (`ca1a3ab`) pasa a Terminado.** La corrección de T‑63 entró en el mismo commit. Yov la
revisó:

- **El inventario se leyó del binario, no se supuso.** El APK `C9A91F86` y, por cadenas, el
  `.aab` piden solo `INTERNET` y `ACCESS_NETWORK_STATE`, sin `AD_ID`.
- **Dos afirmaciones del borrador de la política, comprobadas por Yov en el repositorio.** El
  manifiesto no fija `allowBackup`, así que el respaldo automático queda activo por omisión. La
  app sí permite eliminar un viaje guardado.
- **Cada declaración tiene una respuesta** con su evidencia y su fuente. Lo que no se puede
  comprobar desde el repositorio está marcado de V1 a V9.
- **La política de privacidad se trata como obligatoria.** Las páginas oficiales de Google se
  contradicen, y el informe cita las dos versiones. Manda el formulario de Seguridad de los datos,
  que la prueba cerrada exige y que pide el enlace a la política.

**Lo que queda abierto:**

- **Seguridad de los datos.** La evidencia sostiene «no recopila ni comparte», pero no se declara
  hasta cerrar tres dudas:
  - V1: las dependencias reales;
  - V2: la red en todas las operaciones de Android;
  - V3: el respaldo automático, que decide Carlos (D3).
- **La política tiene que estar también dentro de la app**, y la app no la tiene. Es un cambio en
  `lib/`, así que va al Sprint 3 (D4).
- **El ícono de la app es el de Flutter** (D5). Cambiarlo toca `android/`, así que va al Sprint 3.
- **Nueve decisiones de Carlos, D1 a D9.** Ninguna bloquea el Sprint 2: hacen falta cuando se abra
  la prueba cerrada.

**Nace T‑65** (1.25 h, contra holgura), para Timonel: cerrar V1 y V2 sin tocar código. El trabajo
fuera del compromiso sube a **17.0 h de 18**; queda 1 h de holgura.

**Estado.** Lo comprometido sigue en **32.0 de 35 h**.

---

### 10.43 · T-65 cerrada: la app no usó la red en ninguna operación medida · la holgura queda en 17.0 de 18 h (2-oct)

**T‑65 (`e76fe06`) pasa a Terminado.** Yov la verificó contra el repositorio: `lib/` sigue igual
que en `ba7353a`, y `android/` solo tiene los cambios de T‑49.

**V1, cerrada.** El árbol de dependencias release tiene 103 artefactos. No incluye Firebase
Installations, Analytics, Crashlytics, Messaging, Remote Config, Performance ni anuncios. La única
biblioteca capaz de transmitir por su cuenta es Cloud Firestore, y solo cuando el código la usa;
el flujo del usuario no la usa.

**V2, cerrada para las operaciones de la lista.** Se midió en el Honor con el APK `C9A91F86`:
arranque en frío y siete operaciones, de abrir desde Recientes a 5 minutos en segundo plano. Se
usaron cuatro instrumentos:

- la sonda de T‑44;
- un sondeo de sockets TCP y UDP;
- los contadores del sistema por UID, que cuentan cada paquete, UDP incluido;
- el historial de esos contadores.

El resultado fue **cero en todo**. Los controles positivos demuestran que los instrumentos sí ven
tráfico real.

**Hallazgo de método.** En segundo plano, Android bloquea la red de la app
(`blocked=APP_BACKGROUND`), así que un cero en ese tramo no prueba nada por sí solo. Timonel lo
notó y agregó 5 minutos en primer plano y en reposo, con la red permitida, y también dio cero. Es
un ejemplo de por qué un cero se reporta junto con lo que cada instrumento no puede ver.

**Lo que cambia:**

- **Seguridad de los datos.** «No recopila ni comparte» sigue siendo la respuesta, y de sus tres
  dudas solo queda V3: el respaldo automático, que decide Carlos (D3).
- **RNF‑004** gana la mitad Android que le faltaba según T‑63.
- **Nace V10**, unos 0.5 h: lo que no entró en la lista (Perfiles guardados, exportar CSV y JSON,
  Limpiar datos, otros archivos). No se hace en este sprint y pasa a la medición de RNF‑004 del
  Sprint 3.
- **El Honor quedó como estaba,** salvo un viaje duplicado de A01 que se eliminó de Recientes
  (de 5 pasan a 4).

**Holgura.** El trabajo fuera del compromiso va en **17.0 h de 18**. Timonel no toma más tareas
extra en el Sprint 2; la hora que queda se reserva para imprevistos de T‑49, parte 2.

**Estado.** Lo comprometido sigue en **32.0 de 35 h**. Faltan T‑46, la alerta de H‑06 con Carlos
en la consola, y T‑49 parte 2, que espera a Google.

---

### 10.44 · T-46 cerrada: la alerta automática queda como limitación declarada, con revisión manual (2-oct)

**Lo que se comprobó hoy, con Carlos en la consola y Yov leyendo:**

1. **La política de alertas de 10.35 nunca abrió una alerta**, ni siquiera tarde. La lista de
   Monitoring, con las alertas cerradas a la vista, está vacía.
2. **El otro camino tampoco se puede usar.** Al crear la métrica basada en registros, la consola
   avisa: «Las métricas basadas en registros no se admiten sin una cuenta de facturación asociada a
   este proyecto». El proyecto temporal está en el plan Spark, sin facturación.

Para las métricas, la causa queda **confirmada por la consola**. Para la política de alertas
basada en registros, la falta de facturación es la explicación más probable, pero ninguna fuente
oficial la confirma: la guía de solución de problemas no la menciona.

**Decisión de Carlos: declarar la limitación y no activar facturación.** Activarla exigiría
asociar una tarjeta al proyecto temporal solo para esto. H‑06 queda así:

- **Registro: cumple.** Cloud Audit Logs registra cada acceso anónimo a Firestore, con su método y
  su IP de origen (10.34).
- **Alertas automáticas: no disponibles en el plan gratuito.** Es una limitación declarada.
- **Control que la reemplaza:** la consulta guardada **«H‑06 · accesos anonimos a Firestore»** en
  el Explorador de registros del proyecto temporal, que es privada.

**Procedimiento de revisión manual:**

- **Cuándo:** antes y después de cada sesión de medición de H5, y una vez por semana mientras
  exista el proyecto temporal.
- **Cómo:** Explorador de registros → Biblioteca de consultas → Guardado → «H‑06 · accesos
  anonimos a Firestore» → Ejecutar, con los últimos 7 días.
- **Qué se busca:** cada entrada tiene que corresponder a una sesión conocida. Si alguna no
  corresponde, se abre y se anotan la IP de origen (`callerIp`) y el documento. Después se
  comprueba que `latency_test` siga en 103, y se revisan las reglas.

**Primera revisión, 2‑oct.** Hubo 12 entradas en 7 días, todas conocidas:

- 6 de las tres lecturas de prueba de Carlos del 1‑oct, a las 19:51, 20:15 y 20:22 (`GetDocument`
  y `ListDocuments`);
- 6 de las 21:10 y 21:12 (`RunAggregationQuery` y `Listen`), que coinciden en hora y tipo con la
  comprobación de solo lectura de H5 en T‑47 (`latency_test` = 103).

La política de alertas de 10.35 se deja activa. No estorba, deja constancia del intento y
funcionaría si el proyecto llegara a tener facturación.

**T‑46 pasa a Terminado.** H‑07 se cerró antes. En H‑06, el registro está verificado y las
alertas quedan como limitación declarada, con un control manual que las reemplaza.

**Para la tesis:** es el segundo caso del sprint en que el plan gratuito de Firebase decide el
alcance de un control. El primero es que el proyecto de producción no tiene Firestore (10.32). Se
reporta tal cual: el control que se pudo verificar, y el que no.

**Estado.** Lo comprometido va en **33.0 de 35 h**, con 25 tareas terminadas. Solo falta T‑49,
parte 2, que espera a que Google apruebe la identidad de Carlos.

---

### 10.45 · T-49, parte 2: BayStream publicada en la prueba interna de Google Play · falta instalarla en el Honor (3-oct)

**Lo que pasó en la consola.** Google verificó la identidad de Carlos el 2-oct, y el 3-oct Carlos
verificó su teléfono de contacto. Con eso se desbloqueó la creación de apps. Yov fue leyendo cada
pantalla desde Chrome; las aceptaciones, la lista de *testers* y la publicación las hizo Carlos.

- **App creada:** «BayStream», paquete **`gt.cmartinez.baystream`**, Español (Latinoamérica),
  gratuita. El formulario de Play ahora pide el nombre del paquete al crear la app, y ese nombre ya
  no se puede cambiar.
- **Lista de *testers*:** «Equipo BayStream», con un usuario, el Gmail de Carlos.
- **Versión 1 (1.0.0)** con el `.aab` de T‑49. Antes de subirlo, Yov verificó en disco que su
  SHA‑256 seguía siendo `C60FFF0C…679D` y que `lib/` no había cambiado desde `ba7353a`.
- **Lo que mostró Play:** API 24 y posteriores, SDK objetivo 36, tres ABI y una descarga de 10.2 MB.
  La revisión dio «Ya se puede publicar», sin errores ni advertencias.
- **Publicada el 3-oct.** El canal de prueba interna queda **Activo**.
- **Enlace para unirse:** `https://play.google.com/apps/internaltest/4700137266943390078`.
- Mientras no se complete la ficha de la tienda, Play muestra el nombre temporal
  «gt.cmartinez.baystream (unreviewed)». Es lo esperado en una prueba interna.

**T‑49 sigue En curso.** Le falta su criterio de terminado (10.28): instalar la app en el Honor
desde Play, arrancarla sin red y cargar A01. Antes hay que desinstalar la versión firmada con la
clave de subida (10.39). Son unos minutos que Carlos dejó para después. Cuando llegue la evidencia,
T‑49 pasa a Terminado y se toma la cifra de control sobre el APK que entrega Play (10.37).

**Un aviso de la consola para revisar.** La lista de apps muestra un aviso sobre la verificación de
desarrolladores de Android: Play intentó registrar automáticamente las apps de la cuenta. Hay que
confirmar en «Verificación de desarrolladores de Android» que BayStream quedó registrada.

**La entrega del 17-oct se actualizó con corte al 3-oct:** el documento, la presentación y el
tablero.

**Estado.** Lo comprometido sigue en **33.0 de 35 h**, con 25 tareas terminadas. De T‑49 solo falta
comprobar la instalación desde Play.
