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

### 2.3 Las pruebas deben seguir en verde — 139 al 19-sep

```
test/baplie_parser_test.dart          40      test/export_service_test.dart          9
test/vessel_geometry_test.dart        42      test/vessel_geometry_page_test.dart   20
test/bay_plan_grid_test.dart          17      test/baplie_reefer_parser_test.dart    3
test/pdf_report_service_test.dart      3      test/vessel_profile_view_test.dart     3
test/container_search_delegate_test.dart 1    test/widget_test.dart                  1
```

**El piso sube y nunca baja.** Al abrir el sprint eran 138; T‑51 dejó 139. El piso de
cada tarea es el número con que cerró la anterior.

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

**Si un requerimiento no se cumple, el número se reporta como salió.** Este proyecto ya
tiene seis casos documentados en que un segundo revisor encontró algo que el primero dio
por bueno, y ese patrón es material del apartado de método. Maquillar una medición lo
desperdicia y es la clase de cosa que se detecta en la defensa.

---

### TC-03 · Pruebas finales de seguridad (3.0 h · T-45, T-46)

#### T-45 · Cerrar H-02: autenticación y reglas de acceso por usuario · 2.00 h

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
es lo que impide falsear una latencia. Es un argumento fuerte para la defensa y no se toca.

**Terminada cuando:** el bloque de reglas está listo para publicar **y** viene acompañado
del procedimiento de verificación empírica —dos clientes, receptor activo, serie corta de
3-4 eventos, confirmar que cierran en vez de agotar el tiempo de espera. Una regla que se
lee bien puede comportarse distinto; eso ya pasó aquí.

---

#### T-46 · Registro de eventos y análisis de dependencias (H-06 y H-07) · 1.00 h

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

---

### Trabajo del segundo programador (Timonel) — fuera del compromiso, contra holgura

Estas dos tareas **no cuentan contra los 57 pts / 35.0 h** del documento entregado el
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

## 6. Orden de ataque — por riesgo, no por número

El orden numérico no es el orden de ejecución. En el Sprint 1 atacar primero lo más
riesgoso evitó dos replanificaciones; aquí se repite el criterio.

| # | Bloque | Tareas | h | Por qué va ahí |
|---|---|---|---|---|
| **0** | **Trámites de despliegue** | parte de T-47, T-49 | — | **Empieza el día uno.** Crear el proyecto de producción y abrir el canal de publicación dependen de **terceros**, y un tercero no se apura. Es lo único del sprint cuya duración no la decide el equipo. Lo hace el autor, en paralelo. |
| **1** | **Motor de almacenamiento** | T-35 | 1.0 | La única dependencia nueva del sprint. Si falla en Web, replanifica todo lo que viene después. Mismo criterio que T-08 en el Sprint 1: la decisión de dependencia se verifica antes de que algo dependa de ella. |
| **2** | **Identidad y entidad** | T-24, T-36, T-25 | 3.5 | `Vessel.id` es un UUID aleatorio por parseo: sin clave natural, **ningún perfil se recupera jamás**. Es el bloqueo duro. |
| **3** | **Geometría declarada** | T-26, T-27, T-28 | 3.5 | Toca `vessel_geometry.dart`, el archivo con 42 pruebas encima. Cuanto antes se rompa, más tiempo queda para arreglarlo. |
| **4** | **Parámetros del buque** | T-29, T-30, T-31 | 3.0 | Campos nuevos del perfil. Riesgo bajo: se apoyan en el bloque 3 ya cerrado. |
| **5** | **Interfaz del perfil** | T-32, T-33, T-34 | 4.0 | La pantalla ya existe y funciona; adaptarla es lo mejor entendido del sprint. |
| **6** | **Viajes recientes** | T-37 | 1.0 | Cierra RF-031+. Independiente del resto. |
| **7** | **Validaciones** | T-38 … T-42 | 8.0 | **No puede empezar antes del bloque 5.** T-41 es la de mayor riesgo de desborde: la matriz IMDG es normativa. |
| **8** | **Calidad y seguridad** | T-43 … T-46 | 6.0 | Se mide sobre la versión a liberar; necesita que el producto esté quieto. |
| **9** | **Publicación** | T-48, resto de T-47 y T-49 | 5.0 | Último. Pero el bloque 0 ya dejó los trámites listos hace semanas. |
| **T** | **Lane del segundo programador** | T-50, T-51 | 2.5 | **Fuera del compromiso, contra holgura.** Tocan `bay_plan_view.dart`, `bay.dart` y `CLAUDE.md`: ningún bloque de RF-036 los toca, así que avanzan en paralelo. T-50 ✓ cerrada el 19-sep sin cambio de código: el bloque 9 ya no está bloqueado. |

**Regla de detención:** si una tarea pasa del doble de su estimación, **para y repórtalo**.
La holgura del sprint es de 18 h sobre 53 disponibles; una sola tarea desbordada se come un
tercio. T‑41 es la candidata número uno a desbordarse, y hay un plan para ella en su ficha.

---

## 7. Definición de Terminado

Una tarea no está hecha hasta que cumple **todo** esto:

- [ ] Satisface sus criterios de aceptación en los **tres clientes** soportados.
- [ ] Respeta la separación de capas: la presentación no accede a datos, el dominio no
      importa Flutter **ni el paquete de almacenamiento**.
- [ ] `flutter test` en verde. Piso vigente: **139 pruebas** (138 al abrir el sprint).
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
los 3 MB, que en UTF‑16 pasan del techo de la Web—, así que no hay que rehacer nada. Pero
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
