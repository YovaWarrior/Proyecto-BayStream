# BayStream · Sprint 3 — instrucciones de implementación

**Ventana:** 7 → 24 de octubre de 2026 · **42 tareas · ≈ 155.0 h estimadas** (al 15-oct, 10.40) · rama **`sprint-3`**
**Entrega del curso:** 24-oct, calidad, manual, pruebas de seguridad, despliegue y presentación final (10 pts).
El 17-oct se presenta el Incremento 2 con la versión congelada de la rama principal.

Este archivo es la fuente de verdad del sprint en curso. Sustituye a `SPRINT-2.md` como brief
activo; `SPRINT-2.md` queda como bitácora cerrada (decisiones 10.1 … 10.49) y se conserva.

Los acuerdos permanentes están en `AGENTS.md` y siguen vigentes sin repetirse aquí. Lo que
sigue son las restricciones y el alcance **de este sprint**.

---

## 1. Contexto del proyecto en diez líneas

1. BayStream lee archivos **BAPLIE/EDIFACT** y dibuja el plano de estiba de un buque portacontenedores. Flutter, una sola base de código para **Windows, Android y Web**; arquitectura limpia bajo `lib/features/vessel/` con **Riverpod**.
2. El Sprint 2 cerró el 6-oct con **26 de 26 tareas y 35.0 h**: perfil de buque persistente (RF-036), almacén local propio (RF-031+), validación de estiba con tres estados (RF-027), calidad, seguridad y despliegue. Bitácora: `SPRINT-2.md`.
3. **282 pruebas** en verde y `flutter analyze` en **cero**. Es el piso.
4. La Web está publicada en `baystream-app.web.app` y la app Android está en la **prueba interna de Google Play**, instalada en el Honor desde la tienda.
5. El 5 y 6 de octubre Carlos usó la app con los archivos de **una escala real** del buque que el corpus llama BUQUE GOLF. Salieron **cuatro defectos** (10.46–10.49 de `SPRINT-2.md`). Tres se podían ver con el corpus y nadie los buscó: la aceptación miraba las reglas, no lo que el planificador lee en pantalla.
6. La misma escala documentó **cómo se trabaja hoy en el muelle**, con papel: listado impreso, plano impreso, número de orden escrito a mano en cada celda. Está en `docs/S3-CASO-MAGELLAN-STAR.md`.
7. El centro de la tesis es un **módulo de muelle** (objetivo OE4, hipótesis H3, casos de uso CU04 y CU10) que ningún requerimiento recogió. **Este sprint lo construye** como RF-037.
8. La oficina y el muelle deben ver lo mismo **en tiempo real**: entra la sincronización (RF-032), con cuentas (RF-034) y roles (RF-035).
9. Hay más alcance que horas. El orden de prioridad de la sección 4 decide qué se corta.
10. Flutter **no está instalado** en el entorno de Yov. Compilar, probar y medir es trabajo de los programadores en la máquina de Carlos, con el semáforo de `AGENTS.md`.

---

## 2. Restricciones duras — leer antes de tocar nada

Estas no son preferencias de estilo. Romper cualquiera daña la tesis o el producto.

### 2.1 Archivos congelados — NO TOCAR

```
lib/latency_test_screen.dart          ← instrumentación de la hipótesis H5
lib/c3_reconciliation_screen.dart     ← instrumentación de la hipótesis H5
```

Siguen congelados en la etiqueta `m2-baseline`. Tampoco se toca `lib/main.dart` salvo en la
tarea que lo autorice por escrito en esta ficha.

### 2.2 Rama `sprint-3` y producto congelado hasta el 17-oct

- **Todo el Sprint 3 se trabaja en la rama `sprint-3`.** La rama principal queda congelada
  hasta la presentación del 17-oct (10.40 de `SPRINT-2.md`): es la versión que se midió.
- Tú no cambias de rama ni mezclas: no ejecutas git. Si `git log --oneline -3` no muestra
  el commit de apertura del Sprint 3, **detente y avisa**: estás en la rama equivocada.
- **Nada se publica antes del 17-oct**: ni la Web ni una versión nueva en Google Play. Y
  después tampoco lo publicas tú: lo hace Carlos.
- Después del 17-oct Carlos mezcla `sprint-3` en la rama principal. Esa decisión y su
  momento quedan en la sección 10.

### 2.3 Firebase: lo que se levanta y lo que no

- **El proyecto temporal `baystream-h5-temporal-20260814` no se toca.** Ni lectura de
  prueba, ni escritura, ni reglas. Ahí vive la evidencia de H5 (`latency_test`, 103
  documentos).
- El proyecto de producción `baystream-app` recibirá en la ola 3 **Authentication y
  Firestore**. Crear la base de datos, activar proveedores y publicar reglas lo hace
  **Carlos** desde la consola. Tú redactas `firestore.rules` y los pasos.
- **La espiga T-70 usa solo el emulador local de Firebase.** Ningún proyecto en la nube.
- Las opciones de Firebase siguen fuera del código (T-47). No crees `firebase_options.dart`.
- **Nada de listas dentro de listas en lo que viaja a Firestore** (10.33). Firestore no las admite, y en Windows
  tumbaron la app al publicar las tapas (T-84). Si el dominio necesita una, el codec de `data/` la convierte en
  mapa al viajar, como `FirestoreProfileCodec`; el dominio y Hive no cambian.

### 2.4 Datos reales: nunca en el repositorio

El repositorio es **público**. Los archivos reales de la escala (BAPLIE, listado, fotos)
**no entran**. El corpus anonimizado vive fuera del árbol:

```
C:\Users\Giova\OneDrive\Documentos\OneDrive\Desktop\Archivos .EDI\Anonimizados\files\
```

Desde el 6-oct trae el caso de la escala real, anonimizado por Yov:

| Archivo | Qué es | Contenido |
|---|---|---|
| `CORPUS_A07.edi` | Plano de llegada (BAPLIE 2.0, SMDG22) | 398 contenedores; 333 con peso solo `VGM`; `LOC+5` HNPCR, `LOC+61` GTSTC |
| `CORPUS_A08.edi` | Plan de carga del planificador (SMDG20, peso `WT`) | 460 posiciones: 405 contenedores y **55 celdas reservadas** sin número |
| `CORPUS_A08v_VGM.edi` | El mismo plan con el peso como `VGM` | Igual que A08, sin un solo `WT` |
| `LISTADO_A08.xlsx` | Listado de exportación, como lo imprime la agencia | 176 filas en 4 agencias, número de orden 1 a 176 |
| `CASO_A08_EVENTOS.json` | Los 177 eventos de la operación | 120 llenos, 56 vacíos asignados y 1 intercambio |
| `CASO_A08_ESTADO_FINAL.csv` | El plano como quedó al terminar | 460 posiciones, todas con contenedor |

Los números de contenedor son ficticios con dígito de control ISO 6346 válido y son los
mismos en los cuatro archivos. Líneas y agencias van como LNA … LNG y AGENCIA 1 … 4; la línea B conserva la rareza real: LNB en el listado y LINB en el plan. Las
pruebas del repositorio usan **fixtures sintéticos mínimos**; las pruebas contra el corpus
leen la carpeta por `--dart-define=BAYSTREAM_CORPUS_DIRECTORY=...`, como en el Sprint 2.

**Volcados y capturas del Honor, siempre sanitizados** (10.33, nace en T-89). Solo con
`adb exec-out uiautomator dump /dev/tty`, capturado en memoria y con los identificadores de cuenta ocultos
antes de mostrar o guardar nada. Si aparece un diálogo del sistema con datos de cuenta (guardar contraseña,
selector de Drive), no se captura: se descarta y se declara en el informe.

### 2.5 Las pruebas deben seguir en verde — 282 al abrir el sprint

**El piso sube y nunca baja.** El piso de cada tarea es el número con que cerró la
anterior, contado en la salida de `flutter test`, no con `grep`. Si una prueba se rompe, el
arreglo es parte de la tarea que la rompió. Si una deja de tener sentido porque el contrato
cambió, se reescribe y el informe dice cuál y por qué. Ninguna se borra ni se marca `skip`.

`flutter analyze` en **cero**, sin `// ignore:`.

### 2.6 Arquitectura limpia

```
lib/core/                          utilidades, constantes, errores
lib/features/vessel/domain/        entidades y contratos            ← sin Flutter, sin Firebase
lib/features/vessel/data/          parser, almacén local, Firestore
lib/features/vessel/presentation/  páginas, widgets, providers
```

- La presentación no accede a fuentes de datos; pasa por el repositorio.
- El dominio es Dart puro con `equatable`. **No importa Flutter, ni Hive, ni Firebase.**
- La sincronización vive en `data/`, detrás de un contrato en `domain/repositories/`.
  La operación en muelle tiene que funcionar **sin conexión** y sincronizar al volver.
- Si una función nueva cabe en un archivo existente sin volverlo ilegible, va ahí. No se
  reorganizan carpetas: altera el conteo de `cloc` de H4.

### 2.7 Dependencias autorizadas en este sprint

Carlos autorizó el 5-oct las que hacen falta para las funciones nuevas:

- `firebase_auth`, para las cuentas de RF-034 (`cloud_firestore` y `firebase_core` ya están);
- un paquete de reconocimiento de voz, para RF-041;
- un lector de Excel, para importar el listado (RF-038), si hace falta. Es `excel_community 1.0.10`, con versión fija (T-73).
- `crypto` como dependencia directa, para la huella de las fuentes publicadas (10.3; ya era transitiva).
- `archive` como dependencia directa (T-73; Carlos, 7-oct; ya era transitiva en 4.0.9 y no se mueve). Sirve para corregir las rutas absolutas de `workbook.xml.rels` que `excel_community` no resuelve.
- `msix` como dependencia de desarrollo, para el instalador de Windows (T-93; Carlos, 14-oct, 10.36). Con versión fija y sin mover ningún paquete existente.
- **La copia del SDK JS de Firebase sigue a `firebase_core_web`** (T-92; Carlos, 14-oct, 10.36). Vive en `web/vendor/firebase/<versión>/`. Si `pubspec.lock` cambia `firebase_core_web`, la misma tarea actualiza la copia, con su procedencia y su licencia. La prueba de T-92 hace fallar `flutter test` si se olvida.

Ninguna otra sin preguntar. Cada dependencia nueva se declara en el informe y en el bloque
de commit, con su versión y por qué esa.

### 2.8 Convenciones

- **Todo en español**: interfaz, comentarios, nombres de prueba y mensajes de commit (sin
  acentos). Identificadores de código en inglés, como hoy.
- **Material 3** con `Theme.of(context).colorScheme`, nunca colores literales. El modo
  claro llega en T-90; desde ya, nada de colores que solo funcionen en oscuro.
- Lo que no venga de una especificación real del buque o la terminal se marca
  **PROVISIONAL**, como siempre.

### 2.9 Git y consolas: tú redactas, no ejecutas

Sin cambios: no ejecutas `git add`, `commit`, `push`, `tag`, `checkout`, `restore`,
`switch` ni `status`. Lecturas permitidas: `git log --oneline -5`, `git diff --stat`,
`git show --stat`. La consola de Firebase y Google Play los opera Carlos.

### 2.10 Un carril de `lib/` a la vez

`AGENTS.md`, «Trabajo en paralelo», sigue vigente: **`lib/`, `test/` y `pubspec.*` son de
una tarea a la vez.** En este sprint el carril de `lib/` pasa de un programador al otro
según la sección 6, y quien no lo tiene trabaja en algo que no los toca: una espiga en
otra carpeta, una aceptación, una medición o un informe. Un comando de Flutter a la vez en
la máquina, con `SEMÁFORO:` cuando alguien mide. Vale también entre agentes (10.33): mientras uno compila o
prueba, el otro no corre Flutter, y Carlos da el semáforo.

---

## 3. Objetivo del sprint

> Que BayStream **reemplace el papel en la operación del buque**: que el muelle marque lo
> que baja y registre lo que sube contra el plan, que la oficina lo vea en vivo, y que al
> terminar salga el BAPLIE sin volver a digitar nada.

Si el tiempo se agota, ese enunciado decide qué se sacrifica. Lo que no sirva a operar el
buque con la app, a sincronizar muelle y oficina, o a la entrega del 24-oct, se corta.

---

## 4. Alcance: elementos, prioridad y olas

### 4.1 Elementos

| Elemento | Nombre | Origen | Horas | Tareas |
|---|---|---|---:|---|
| **DEF** | Defectos de la prueba de campo y caso real | 10.46–10.49 | 13.5 | T-66 … T-71 |
| **RF-037** | Operación en muelle *(nuevo)* | OE4, H3, CU04, CU10 | 18.0 | T-72, T-75 … T-78 |
| **RF-038** | Plan de carga y cambios de oficina *(nuevo)* | Pedido de Carlos, 5-oct | 11.5 | T-73, T-74, T-81 |
| **RF-032+ · RF-034 · RF-035** | Sincronización, cuentas y roles | ERS (COULD) · CU05 | 18.0 | T-79, T-80 |
| **RF-039** | BAPLIE de salida *(nuevo)* | Pedido de Carlos, 5-oct | 10.0 | T-82 |
| **RF-040** | Tapas de escotilla *(nuevo)* | Pedido de Carlos, 5-oct | 8.0 | T-83, T-84 |
| **RF-027+** | Segregación con el Código IMDG 42-24 | ERS · 10.49 | 10.0 | T-85 |
| **BAP** | Versiones de BAPLIE (2.x y 3.1) | Pedido de Carlos, 5-oct | 13.0 | T-86, T-87 |
| **USO** | Uso fuera del aula: Play, iPhone, tema, barra, Web sin conexión, instalador, peso en el PDF | Prueba de campo · Play | 13.5 | T-88 … T-93, T-102 |
| **RF-041** | Búsqueda por voz *(nuevo)* | Pedido de Carlos, 5-oct | 4.5 | T-94 |
| **ERS** | RF-028, RF-029, T-56 y el título a 360 px | ERS · Sprint 2 | 17.0 | T-95, T-96, T-56, T-97 |
| **TC** | RNF (T-63), manual (TC-02), presentación final (TC-05) | Curso | 63.0 | T-98 … T-100 |
| **PIL** | Prueba piloto en una escala real | Permiso de COMAR | 4.0 | T-101 |
| | **Total** | | **≈ 204.0** | **38 tareas** |

Las horas con ≈ son estimación; se corrigen al abrir cada ola. RF-028 y RF-029 completan
funciones COULD del ERS que el Sprint 2 dejó fuera.

### 4.2 Prioridad para recortar

Si un día no rinde, **se corta desde abajo**. Lo de arriba no se toca.

1. Entregables del 24-oct: RNF primera parte (T-98: 004, 006, 008 y 002), manual y presentación (T-100).
2. Defectos de campo y caso real (T-66 … T-71).
3. RF-037, operación en muelle.
4. Sincronización, cuentas y roles.
5. RF-040, tapas de escotilla.
6. RF-038, plan de carga y cambios de oficina.
7. RF-039, BAPLIE de salida.
8. Versiones de BAPLIE.
9. RF-027+, IMDG.
10. Uso fuera del aula.
11. RF-041, voz.
12. RF-028, RF-029, T-56, título y RNF segunda parte (T-99).
13. Prueba piloto.

El **orden de ataque** (sección 6) sigue las dependencias; este orden decide qué se corta.
RF-038 va antes que la carga de RF-037 en el tiempo porque la carga necesita el listado.

### 4.3 Qué ya está hecho y NO hay que rehacer

- **El lector conserva la estructura de cada grupo de contenedor.** Los `MEA`, `LOC+9/11`,
  `TMP` y `NAD` se acumulan por `LOC+147` y se reinician en el siguiente. Yov verificó que
  un `EQD` sin número **no contamina** al contenedor vecino: el grupo se descarta entero.
  Ese es el defecto de T-69, no otro.
- **`ContainerUnit` ya trae `grossWeight`, `vgmWeight` y `tareWeight`**, cada uno desde su
  `MEA`. Lo que falla es que todo lo demás usa solo `grossWeight` (T-66).
- **`VesselVoyage.portOfOrigin` (`LOC+5`)** y la propuesta de escala con confirmación del
  usuario existen desde el Sprint 2. Lo que falta es `LOC+61` y la descarga (T-68).
- **El panel de validación con tres estados** (conforme, posible incumplimiento, no
  evaluado) existe. T-67 lo usa, no lo rehace.
- **El almacén local** (Hive, detrás de un contrato) guarda viajes recientes y perfiles.
  Lo nuevo se persiste por el mismo camino.

---

## 5. Las tareas

Cada ficha dice qué tocar, qué hacer y cuándo está terminada. La «h» es estimación de
codificación neta. **Las fichas de la ola 1 están completas; las demás son breves** y se
completan al abrir su ola, con lo que la ola anterior enseñe.

### Ola 1 · Defectos de campo, caso real y riesgo de sincronización (7–9 oct)

#### T-66 · Mostrar y sumar el peso aunque el archivo solo traiga VGM · 1.5 h · Timonel

**El defecto.** `_parseMEA` guarda `WT` en `grossWeight` y `VGM` en `vgmWeight`, y todo lo
demás lee solo `grossWeight`: el detalle («Peso Bruto»), la lista, la búsqueda, el PDF, los
totales de `Bay` y de `VesselVoyage`, y las pilas. En `CORPUS_A07`, 333 de 398 contenedores
salen «N/A kg»; en `CORPUS_A05` y `CORPUS_A08v_VGM`, todos.

**Qué hacer.**
1. En `ContainerUnit`, un peso efectivo: **`vgmWeight` si existe, si no `grossWeight`**,
   y de qué fuente vino. Se prefiere el VGM porque es la masa bruta verificada que el
   Convenio SOLAS exige para el plan de estiba. En el corpus ningún contenedor trae los
   dos, así que ningún número existente cambia por esta preferencia.
2. Usarlo en todo lo que hoy lee `grossWeight` para mostrar o sumar. `netWeight` se calcula
   sobre el peso efectivo. **La exportación CSV/JSON no cambia**: sigue entregando las tres
   columnas crudas.
3. El detalle dice de dónde viene el peso: «Peso (VGM)» o «Peso bruto». Si vienen los dos,
   muestra los dos.
4. **La celda del plano muestra el peso en toneladas con un decimal**, como el plano
   impreso («28.7»). Carlos lo pidió en la prueba de campo: «los pesos no salen en los
   contenedores en ninguna plataforma». Si a 360 px no cabe sin tapar el tipo y la línea,
   se ve al ampliar y siempre en el detalle; el informe dice qué pasó en cada ancho.

**Terminada cuando:**
- [ ] Pruebas nuevas: solo `VGM`, solo `WT`, los dos, ninguno.
- [ ] Peso total del viaje, comprobado en la app:

| Archivo | Contenedores | Peso total esperado | Hoy |
|---|---:|---:|---:|
| `CORPUS_A07` | 398 | **6 940 578 kg** | 213 310 kg |
| `CORPUS_A05` | 736 | **11 210 489 kg** | 0 kg |
| `CORPUS_A08` | 405 | **6 899 700 kg** | igual |
| `CORPUS_A08v_VGM` | 405 | **6 899 700 kg** | 0 kg |
| `CORPUS_A01` | 977 | **8 366 089 kg** | igual (no regresa) |

- [ ] Ningún contenedor de esos archivos muestra «N/A kg».
- [ ] El peso se ve en las celdas en Windows, Android y Web.

#### T-67 · Peso por pila: contar el VGM y declarar «no evaluado» si falta un peso · 1.5 h · Timonel

**El defecto.** `StackWeightValidator` suma `deckWeightByRow` / `holdWeightByRow`, donde un
contenedor sin peso cuenta como 0, y solo reporta cuando la suma supera el límite. Una pila
con un contenedor sin peso puede estar excedida y la regla calla, contra el diseño de tres
estados del Sprint 2.

**Qué hacer.**
1. Las pilas suman el peso efectivo de T-66.
2. Si en una pila **algún contenedor no trae ningún peso**:
   - si la suma conocida ya supera el límite → **posible incumplimiento**, como hoy;
   - si no → **no evaluado**, con la razón: «N contenedores de esta pila no traen peso».
3. Sin límite declarado en el perfil, la regla sigue sin producir nada (decisión C-7).

**Terminada cuando:**
- [ ] Pruebas nuevas para los tres casos: excedida con pesos completos, excedida con un peso
      faltante, no excedida con un peso faltante.
- [ ] Con `CORPUS_A08v_VGM` y un límite de prueba, el panel da **las mismas alertas** que
      con `CORPUS_A08` y el mismo límite. Hoy da cero.
- [ ] El informe dice qué límite de prueba usó y cuántas alertas salieron con cada archivo.

#### T-68 · Puerto de escala y «de paso» en planos de llegada · 3.0 h · Codex, después de T-67

**El defecto.** La escala se propone desde `LOC+5`, el puerto de salida del mensaje, y «de
paso» se decide solo por el puerto de carga. Un plano de llegada se emite al salir del
puerto anterior: en `CORPUS_A07` el `LOC+5` es HNPCR y la escala real es GTSTC (`LOC+61`).
Los 114 contenedores que se descargan en GTSTC salen como de paso. `LOC+61` hoy no se lee.

**Qué hacer.**
1. **Leer `LOC+61`** de la cabecera, antes del primer `LOC+147`, igual que `LOC+5`, en un
   campo nuevo de `VesselVoyage` (persistido, retrocompatible). Solo vale un código con
   forma de UN/LOCODE (`^[A-Z]{2}[A-Z0-9]{3}$`): `CORPUS_A04` y `CORPUS_A06` traen
   `LOC+61+*****` por la anonimización, y eso es «sin declarar».
2. **Propuesta de escala.** Un mismo archivo sirve para la salida de `LOC+5` y para la
   llegada a `LOC+61`; solo el usuario sabe dónde está. Por eso:
   - si el archivo declara los dos, el diálogo los muestra primero, con una frase:
     «El archivo se emitió al salir de HNPCR rumbo a GTSTC: para la salida, la escala es
     HNPCR; para la llegada, GTSTC»;
   - se preselecciona el que coincida con **el último puerto de escala confirmado en este
     dispositivo** (dato nuevo del almacén local); si ninguno coincide, `LOC+5`, como hoy;
   - sin `LOC+61`, nada cambia.
3. **«De paso»** pasa a ser: hay escala, hay puerto de carga, y **ni el de carga ni el de
   descarga** son la escala. Un contenedor que se descarga en la escala se opera.
4. El resumen del diálogo y de la vista general dice **cuántos se descargan, cuántos se
   cargan y cuántos van de paso**, no solo «se operan».

**Terminada cuando:**
- [ ] Pruebas nuevas: `LOC+61` válido, ausente y enmascarado; la preselección con y sin
      historial; «de paso» con carga, con descarga y con ninguno.
- [ ] Cifras comprobadas en la app:

| Archivo | Escala | Se cargan | Se descargan | De paso | Hoy de paso |
|---|---|---:|---:|---:|---:|
| `CORPUS_A07` | GTSTC | 0 | **114** | **284** | 398 |
| `CORPUS_A02` | GTSTC | 0 | **303** | **503** | 806 |
| `CORPUS_A08` | GTSTC | 121 | 0 | 284 | 284 |
| `CORPUS_A01` | GTPBR | 325 | 0 | 652 | 652 (no regresa) |

- [ ] Abrir `CORPUS_A08` (salida de GTSTC) y luego `CORPUS_A07` en el mismo dispositivo
      preselecciona GTSTC en el segundo sin que el usuario lo elija.

#### T-69 · Celdas reservadas: conservar el EQD sin número · 3.0 h · Timonel, después de T-68

**El defecto.** El plan de carga del planificador reserva celdas para vacíos que todavía no
tienen número (`EQD+CN++22G1+++4`). `_parseEQD` devuelve `null` sin número y el grupo
desaparece: `CORPUS_A08` muestra 405 de 460 posiciones. Son justo las celdas que el muelle
tiene que llenar (RF-038 y RF-037).

**Qué hacer.**
1. **Entidad nueva de dominio, `ReservedSlot`**, separada de `ContainerUnit`: posición,
   tipo ISO, lleno o vacío, puerto de carga, puerto de descarga, línea, peso nominal y, si
   vienen, temperatura y peligrosas. No se fabrica un número de contenedor: todo el código
   que usa `containerId` como clave seguiría contándolas como contenedores. Si encuentras
   una razón fuerte para otro diseño, **detente y explícala antes de escribirlo**.
2. `VesselVoyage.reservedSlots`, persistido y retrocompatible: los viajes guardados antes
   se leen con lista vacía.
3. **El plano las dibuja** distintas de un contenedor (contorno, sin relleno de línea),
   con tipo y puerto, y con la misma lógica de 20 y 40 pies que los contenedores. Al
   tocarlas: «Celda reservada · 22G1 · PAMIT · LNC · vacío · 2.1 t nominal».
4. La lista y la vista general las cuentan **aparte**: «405 contenedores · 55 celdas
   reservadas».
5. **No suman peso ni ocupación todavía.** Su peso nominal se reemplaza por la tara real
   cuando el muelle asigne el contenedor (T-76); esa decisión se toma ahí, con el caso real
   a la vista. Se declara en el informe.

**Terminada cuando:**
- [ ] Prueba con fixture sintético: una reserva entre dos contenedores; los vecinos quedan
      intactos y la reserva aparece con sus datos.
- [ ] `CORPUS_A08` y `CORPUS_A08v_VGM`: **405 contenedores y 55 reservas**, en las posiciones
      de la tabla de la sección 4 de `docs/S3-CASO-MAGELLAN-STAR.md`, salvo 006-02-04, que
      ya trae número.
- [ ] El corpus anterior no cambia: A01 … A07 con **cero** reservas.
- [ ] Las reservas se ven en los tres clientes y sobreviven a cerrar y reabrir el viaje.

#### T-70 · Espiga: cuentas y Firestore en Windows, Android y Web, con el emulador · 2.0 h · Codex

**Por qué.** La sincronización (ola 3) es el riesgo más grande del sprint. Si
`firebase_auth` o `cloud_firestore` no funcionan bien en **Windows de escritorio**, hay que
saberlo el día 2, no el 14.

**Qué hacer**, **fuera del repositorio** (por ejemplo `C:\Proyectos\espiga-sync\`):
1. Un proyecto Flutter mínimo con `firebase_core`, `firebase_auth` y `cloud_firestore`, en
   versiones que **resuelvan junto con las del repositorio** (`firebase_core ^4.4.0`,
   `cloud_firestore ^6.1.2`).
2. El **Firebase Local Emulator Suite** (Auth y Firestore). Ningún proyecto en la nube. Si
   falta Java o la CLI, dilo y propón cómo instalarlo; no instales nada global sin el OK de
   Carlos.
3. En cada cliente (Windows, Android en el Honor, Web en Chrome): crear cuenta con correo,
   iniciar sesión, escribir un documento, recibirlo en otro cliente con un listener,
   escribir sin red y ver que sube al reconectar.
4. Medir de forma simple el tiempo de escritura a recepción entre dos clientes (10
   repeticiones). Es orientativo: no es H5 y no se reporta como tal.

**Terminada cuando:**
- [ ] `docs/T70-RESULTADOS.md` con una matriz plataforma × (cuenta, escribir, escuchar,
      sin conexión, reconexión), las versiones exactas y lo que falló, con el mensaje.
- [ ] Una recomendación para T-79: qué funciona igual en los tres, qué no y qué alternativa
      propones donde falle.
- [ ] El repositorio no cambió salvo ese informe.

#### T-71 · Caso real anonimizado y salida esperada · 2.5 h · Yov · **hecha (6-oct)**

Los seis archivos de la tabla 2.4. Detalle de la operación en
`docs/S3-CASO-MAGELLAN-STAR.md`. Es la prueba de aceptación de RF-037, RF-038 y RF-039.

### Ola 2 · Operación en muelle y plan de carga, en un dispositivo (9–13 oct)

#### T-73 · Importar el listado de la agencia, con equivalencias y peligrosas · 4.5 h · Timonel (ficha completa, 7-oct)

**Para qué.** El muelle trabaja con el listado de la agencia: el número de orden, el contenedor, su tara real y su VGM exacto. Hoy ese listado existe solo en papel y en un Excel. T-73 lo convierte en la tercera fuente de la operación (`OperationSourceKind.exportList` de T-72), ya normalizado contra el plan.

**El archivo** (`LISTADO_A08.xlsx` es el modelo; el de la agencia real tiene la misma forma):
- **Cabecera.** Unas filas de título, luego la fila de encabezados: OR, CONTENEDOR, TIPO, POT, POD, TARA, PESO NETO, PESO VGM, REEFER TEMP, ORIG, F, E, CONTENIDO, HORA, MARCHAMO, OPR. Las columnas se ubican **por su encabezado**, no por su posición.
- **Separadores de agencia.** Son filas de texto combinado con «CODIGO»; no son contenedores. Cada contenedor guarda a qué agencia pertenece.
- **Lleno o vacío** se marca con una X en F o en E.
- **PESO NETO** es una fórmula (VGM − TARA). En `LISTADO_A08.xlsx` la fórmula **no tiene valor guardado**, porque la anonimización reescribió el archivo: se **recalcula**, no se lee.
- **HORA y MARCHAMO** pueden venir vacías.

**Qué hacer.**
1. **Leer el Excel** con un paquete autorizado en 2.7. Tiene que ser **Dart puro**, que funcione en Web, Windows y Android sin código nativo. Se declara en el informe con su versión y su licencia, y por qué ese.
2. **Normalizar cada fila:** número de orden, contenedor, tipo, puertos, tara, VGM exacto (sin truncar), lleno o vacío, contenido, reefer, hora, marchamo, línea y agencia. Una fila que no se entienda se reporta con su número de fila; no se descarta en silencio.
3. **Peligrosas desde CONTENIDO.** Leer la clase y los números ONU del texto libre: «IMO 9 UN 3082, 3077» da clase 9 y UN 3082 y 3077. Si el plan trae otros números para ese contenedor, **avisarlo**. En el caso, el OR 127 declara UN 3082 y 3077, y el plan solo trae 3077.
4. **Tabla de equivalencias editable y persistente**, en el almacén local, para tipos, puertos y códigos de línea.
   - **Se propone sola** a partir de los contenedores que están en el listado y en el plan a la vez. En el caso: 40HC → 45G1, 20ST → 22G1, 40ST → 42G1, COMNG → COSPC y LNB → LINB.
   - Lo que no se puede inferir, porque ningún contenedor de ese tipo está en los dos, **se pide al usuario**. En el caso, 40RF → 45R1. El usuario confirma o corrige antes de aplicar.
5. **Cruce con el plan.**
   - Cada lleno del listado se busca en el plan por su número.
   - Cada vacío se asigna a su **grupo** de reservas (tipo, puerto de descarga y línea, ya traducidos).
   - Lo que no cruza se informa: llenos del listado que no están en el plan, llenos del plan que no están en el listado, y vacíos sin grupo.
6. **Guardar el listado normalizado** como fuente `exportList` de la operación, con las equivalencias ya aplicadas, como pide T-79a, 2.1.
7. **Una pantalla de importación sencilla.** Elegir el archivo, ver el resumen y las equivalencias, confirmar. La operación en el muelle llega en T-74 a T-76.

**Terminada cuando:**
- [ ] `LISTADO_A08.xlsx` contra `CORPUS_A08` da:
  - **176 filas en 4 agencias;**
  - **120 llenos que cruzan uno a uno** con el plan;
  - **56 vacíos en los 6 grupos de reservas** (20, 17, 9, 7, 2 y 1);
  - cero filas sin entender.
- [ ] Las cinco equivalencias se proponen solas, y 40RF → 45R1 se pide.
- [ ] El OR 127 trae clase 9 y UN 3082 y 3077, con el aviso de que el plan no trae 3082.
- [ ] El VGM se guarda exacto. Ejemplo: el OR 130 da **7 266.59 kg**, no los 7 200 del plan.
- [ ] Las equivalencias confirmadas sobreviven al cierre de la app, y una segunda importación ya no las pide.
- [ ] Se importa y se ve en los tres clientes.

#### T-74 · El plan de carga en el plano: número de orden en cada celda y pendientes por bahía · 3.0 h · Codex (ficha completa, 7-oct)

**Para qué.** Hoy el planificador busca cada contenedor en el listado impreso y escribe su número de orden en el plano. Con T-73 la app ya sabe qué OR le toca a cada contenedor y a qué grupo pertenece cada vacío. T-74 pone esa información en el plano y cuenta lo que falta por bahía.

**Qué hacer.**
1. **Las fuentes completas de la operación.**
   - Al confirmar la escala de un BAPLIE, se guarda su texto en la operación de T-72 y T-73. La operación se identifica por buque, viaje y escala (`docs/T73-RESULTADOS.md`, 3.4).
   - Si la operación ya existe, se conservan su `id`, su `createdAt` y sus otras fuentes, y solo se reemplaza la fuente de ese tipo. Si no existe, se crea.
   - **El tipo de fuente sale de los conteos de T-68** en la escala confirmada: si solo hay cargas, es `loading_baplie`; si solo hay descargas, `arrival_baplie`; si hay las dos cosas o ninguna, se pregunta al usuario.
   - **En el caso**, A07 (114 descargas en GTSTC) y A08 (121 cargas en GTSTC) tienen el mismo buque, BUQUE GOLF, y el mismo viaje, VIAJE007A. Por eso quedan en **una sola operación**, con tres fuentes: `arrival_baplie`, `loading_baplie` y `export_list`.
2. **El número de orden en la celda**, como lo escribe hoy el planificador en el papel. Se elige con un modo de vista «Número de orden», junto a los que el plano ya tenga.
   - **Lleno planificado:** muestra el OR del listado, cruzado por número de contenedor. Esto incluye el **OR 85**, un vacío que el plan ya trae con su número.
   - **Reserva:** muestra su grupo en corto (tipo, puerto y línea), sin OR. El OR del vacío llega cuando se asigna, en T-76.
   - **Celda de carga sin cruce:** muestra «—» y aparece en el resumen.
   - El PDF no cambia en esta tarea.
3. **Pendientes por bahía.** Se calculan con el **estado derivado de T-72**, no solo con el plan.
   - Se separan por bahía, por cubierta y bodega, y por llenos y vacíos.
   - Lleno o vacío se decide **por el listado** (F o E). Por eso el OR 85 cuenta como vacío.
   - Se ven en el resumen de cada bahía y en una tabla de la operación.
4. **Sin listado.** Si la operación todavía no tiene `export_list`, el modo «Número de orden» lo dice y ofrece importarlo (T-73). Los pendientes se calculan igual, solo con el plan.

**Terminada cuando:**
- [ ] A07, A08 y `LISTADO_A08.xlsx` quedan en una sola operación con sus tres fuentes. Reabrir la app no crea otra, y volver a leer A08 solo reemplaza `loading_baplie`.
- [ ] Con A08 y el listado, los 121 contenedores por cargar muestran su OR (120 llenos y el OR 85), y las 55 reservas muestran su grupo. Ninguna celda de carga queda con «—».
- [ ] Al empezar, los pendientes reproducen la tabla de la sección 2 del caso: las 9 bahías, 82 en cubierta y 94 en bodega, 120 llenos y 56 vacíos.
- [ ] Al reproducir `CASO_A08_EVENTOS.json` en la bitácora de T-72, los pendientes bajan con cada evento y terminan en cero. Si el intercambio deja algo en 014-01-02 y 014-01-08, el informe explica qué queda; eso lo resuelve T-80.
- [ ] El OR se lee en la celda a 360 dp. La tarea se acepta en Windows, en el Honor y en Chrome.
- [ ] Piso de 405 pruebas, `analyze` en cero y los corpus de T-68, T-69, T-72 y T-73 en verde.

#### T-75 · Descarga: marcar en el plano lo que baja, con re-estiba y deshacer · 4.0 h · Timonel (ficha completa, 7-oct)

**Para qué.** Es lo que Carlos pidió como lo más importante: «chibolear» en el plano de llegada cada contenedor conforme baja. Hoy se hace con lapicero sobre el plano impreso. En BayStream, un toque lo marca, queda en la bitácora con quién y cuándo, y se puede deshacer sin borrar nada.

**Qué hacer.**
1. **Un modo «Descarga»** en el plano de llegada, la fuente `arrival_baplie` de la operación de T-74. Fuera de ese modo, tocar una celda sigue abriendo el detalle, como hoy. Dentro del modo, un toque registra un movimiento `discharge` con su posición (T-79a, 2.4).
   - **Si el contenedor se descarga en esta escala**, se marca directo.
   - **Si es de paso**, porque su puerto no es esta escala, aparece un aviso de re-estiba. Si se confirma, el movimiento lleva `restow: true` y un motivo opcional. Cuenta aparte, como re-estiba, no entre los 114.
   - **Si la celda está vacía o es una reserva**, no pasa nada.
2. **La marca se ve en la celda.** Descargado, pendiente y de paso se distinguen a 360 dp y en los dos temas, y no solo por el color.
3. **Deshacer** con un movimiento `annul` (T-72), nunca borrando.
   - Justo después de marcar, «Deshacer» queda a la vista unos segundos. Más tarde, se hace desde el detalle de la celda.
   - `annul` exige motivo (T-79a): «Marcado por error» con un toque, o texto libre.
4. **Pendientes de descarga por bahía**, calculados con el estado derivado de T-72. Se separan en cubierta y bodega, como los de carga de T-74, y las re-estibas van aparte.
5. **Quién y cuándo**, en el detalle de la celda: la hora del movimiento y su autor, el que T-72 ya registra. Las cuentas llegan en T-79.
6. **Deuda pequeña, de la incidencia de 10.10.** Los scripts de corpus de T-72 y T-73 crean sus almacenes temporales en el `build/` del repo. Hay que pasarlos al directorio temporal del sistema, como ya hace `tool/t74_corpus_test.dart`.

**Terminada cuando:**
- [ ] Con A07 confirmada en GTSTC, el modo Descarga muestra **114 pendientes: 66 en cubierta y 48 en bodega**, agrupados como el plano agrupa sus bahías. Por bahía del BAPLIE (cubierta/bodega): 003 3/0, 014 19/16, 021 0/12, 022 20/8, 023 0/12 y 030 24/0.
- [ ] Marcar los 114 deja cero pendientes. Deshacerlos todos devuelve 114, y la bitácora conserva los 228 movimientos. En pantalla basta con una bahía completa; los 114 los cubre el corpus.
- [ ] Un contenedor de paso pide confirmar la re-estiba. Confirmado, queda con `restow: true` y cuenta como re-estiba, no entre los 114.
- [ ] Después de cerrar y reabrir la app, las marcas y los pendientes siguen iguales.
- [ ] La tarea se acepta en Windows, en el Honor a 360 dp y en Chrome.
- [ ] Piso de 412 pruebas, `analyze` en cero, los corpus de T-68 a T-74 en verde y el nuevo de T-75.

#### T-76 · Carga: confirmar llenos y asignar vacíos desde el listado, con hora, marchamo y deshacer · 5.0 h · Codex (ficha completa, 7-oct)

**Para qué.** Es la otra mitad de lo que Carlos pidió como lo más importante.
- **Hoy, con un vacío,** el planificador busca el contenedor en el listado impreso, lee su número de orden, escribe ese número en la celda del plano donde lo cargan y revisa que el tipo, el puerto y la línea correspondan.
- **Con un lleno,** el plano ya trae su posición y se marca al subir.

T-76 hace lo mismo en BayStream con la bitácora de T-72, el listado de T-73 y el plano de T-74.

**Qué hacer.**
1. **Un modo «Carga»** en el plano de carga. Usa el **plan combinado**, el de llegada más el de carga, como la descarga de T-75. Así las cargas y las descargas conviven en la misma vista.
2. **Confirmar un lleno**, que registra `load_full` con su `position`, su `order` y los datos opcionales.
   - Se puede tocar la celda planificada, o buscar el contenedor por su **número de orden** o por **los últimos dígitos del contenedor**. La búsqueda resalta la celda y pide confirmar.
   - Un lleno en una celda distinta de la planificada no se registra en T-76: eso es T-77, con motivo, o T-80.
3. **Asignar un vacío**, que registra `assign_empty` con el `container`, la `tareKg` y el `order`.
   - Se elige el OR del vacío en el listado. La app ya sabe su contenedor, tipo, puerto, línea y tara real.
   - **Solo ofrece las celdas reservadas libres de su grupo**, primero las de la bahía que se está viendo. Una celda de otro grupo no se ofrece; elegirla con motivo es T-77.
   - Ejemplo del caso: el **OR 12** va a `R:0030984`, con tara de **2 185 kg**.
4. **Hora y marchamo**, los dos opcionales.
   - La hora va en `payload.operatedAt` y por omisión es la de registro.
   - El marchamo va en `seal`.
5. **Deshacer y corregir.**
   - Deshacer es un `annul`, como en T-75: un «Deshacer» inmediato y, después, desde el detalle, con motivo.
   - Corregir es **un movimiento nuevo con `payload.corrects`**, que deja sin efecto al corregido en la misma escritura (T-79a, 2.5). No se hace con `annul` más una carga nueva: serían dos escrituras, y si a la nube solo llegara la primera, la oficina vería un hueco. Es lo que T-72 ya implementa.
   - `cancel_item` es de la oficina, en T-81. No va aquí.
6. **La descarga del ocupante libera la celda, sin importar el orden.**
   - **Por qué:** 54 de las 176 celdas de carga de A08 son celdas que A07 descarga, y T-75 lo midió. Hoy, una carga registrada antes que la descarga de su celda sale «celda ocupada».
   - **La regla, en el derivador de T-72:** una celda queda libre para cargar si la bitácora tiene una descarga vigente de su ocupante de llegada, aunque esa descarga se haya registrado **después** de la carga. Es lo que pide T-79a: el estado no depende del orden de llegada, y dos dispositivos pueden registrar la descarga y la carga en cualquier orden.
   - Si la descarga no está, la carga queda en conflicto «celda ocupada». T-77 avisará antes de confirmar y ofrecerá registrar esa descarga.
7. **Pendientes y avance.** Los pendientes de carga de T-74 y los de descarga de T-75 bajan con cada movimiento en la misma pantalla.

**Terminada cuando:**
- [ ] Reproducir los 176 eventos de `CASO_A08_EVENTOS.json`, sin el intercambio (que es de T-80), deja en las 460 posiciones el contenedor de `CASO_A08_ESTADO_FINAL.csv`. Las únicas diferencias son 014-01-02 y 014-01-08, como en T-72.
- [ ] Con las **114 descargas de A07 mezcladas en cualquier orden** con esas 176 cargas, el resultado es el mismo y no queda ninguna «celda ocupada». El corpus lo prueba con al menos tres órdenes distintos, entre ellos todas las cargas primero.
- [ ] Una carga sin la descarga de su ocupante queda «celda ocupada», y se resuelve sola al registrar esa descarga.
- [ ] En pantalla:
  - un lleno se confirma por OR y por los últimos dígitos del contenedor;
  - el OR 12 se asigna a `R:0030984`, con 2 185 kg de tara;
  - un vacío no se ofrece en una celda de otro grupo;
  - deshacer y corregir dejan la bitácora completa;
  - después de cerrar y reabrir, todo sigue igual.
- [ ] La tarea se acepta en Windows, en el Honor a 360 dp y en Chrome. En Windows, la aceptación usa un namespace propio del almacén (`AGENTS.md`).
- [ ] Piso de 420 pruebas, `analyze` en cero, los corpus de T-68 a T-75 en verde y el nuevo de T-76.

#### T-77 · Validación antes de confirmar, con motivo escrito · 3.0 h · Timonel (ficha completa, 8-oct)

**Para qué.** En el papel, el planificador revisa a ojo que en cada celda vaya el tipo, el puerto y la carga correctos. T-77 hace esa revisión **antes** de escribir en la bitácora. Lo que se puede justificar pide motivo escrito; lo que es físicamente imposible no se registra.

**Qué hacer.**

La validación se hace contra el **estado derivado del propio dispositivo** (T-79a): plan combinado, bitácora y perfil del buque. Va en los diálogos de confirmar de T-76.

1. **No se puede registrar:**
   - **20/40:** un contenedor de 40 pies en una posición de 20, o al revés, según la bahía par o impar de la posición.
   - **Una celda que no existe** en la geometría del buque.
2. **Se registra solo con motivo escrito**, que viaja en `payload.reason` y deja el conflicto a la vista (T-79a, tabla de conflictos):
   - **Un lleno fuera de su posición planificada:** queda «fuera de plan».
   - **Un vacío en una reserva de otro grupo** (tipo, puerto o línea distintos): queda «vacío de otro grupo».
   - **El peso de la pila supera el límite del perfil**, con el cálculo de T-67 y el peso del listado. Se muestra el peso resultante contra el límite. Sin límite en el perfil, sale «no evaluado» y no se bloquea.
3. **Celda ocupada por un contenedor que baja aquí y no se ha marcado.** Esto viene de 10.11.
   - El aviso dice qué contenedor ocupa la celda y ofrece **«Marcar su descarga y cargar»**. Eso registra dos movimientos, `discharge` y luego la carga, con un solo toque.
   - O se puede cancelar.
   - Si el ocupante **no** baja en esta escala, la celda está ocupada de verdad: se trata como «fuera de plan» y pide motivo.
4. **Los avisos se leen a 360 dp.** El campo de motivo es obligatorio para continuar en los casos del punto 2.

**Terminada cuando:**
- [ ] **Ningún falso aviso.** Validar los 176 eventos de carga del caso contra A08 da **exactamente 2 avisos**, los «fuera de plan» del OR 128 y el OR 145: el intercambio de 014-01-02 y 014-01-08 que resuelve T-80. Ningún otro.
- [ ] **El grupo.** El OR 12 en una reserva de otro grupo no se confirma sin motivo. Con motivo, queda registrado y en conflicto.
- [ ] **20/40.** Un 40 pies en una posición de 20 no se registra, ni con motivo.
- [ ] **La celda ocupada.** Cargar en una de las 54 celdas que A07 descarga, sin marcar antes su descarga, ofrece «Marcar su descarga y cargar». Al aceptar quedan los dos movimientos y ningún conflicto.
- [ ] **El peso de la pila.** En un namespace de prueba, con un límite de prueba de 90 000 kg en el perfil, cargar en la pila 014, bodega, fila 01 avisa con el peso resultante. Sin límite, sale «no evaluado».
- [ ] La tarea se acepta en Windows (namespace propio), en el Honor a 360 dp y en Chrome.
- [ ] Piso de 437 pruebas, `analyze` en cero, los corpus de T-68 a T-76 en verde y el nuevo de T-77.

#### T-78 · El avance de la operación, para la oficina · 3.0 h · Codex (ficha completa, 8-oct)

**Para qué.** Hoy la oficina se entera del avance cuando el muelle le lleva el plano anotado. T-78 arma la pantalla que la oficina mirará cuando llegue la sincronización de T-79. Por ahora funciona en un solo dispositivo, con la bitácora local.

**Qué hacer.**
1. **Una pantalla «Avance de la operación»**, calculada solo con el **estado derivado** de T-72, sin contadores paralelos. Muestra una fila por bahía, agrupada como el plano agrupa sus bahías, y una fila de totales. Las columnas:
   - **Descarga:** descargados y pendientes, más las re-estibas aparte.
   - **Carga:** llenos cargados y pendientes, vacíos asignados y pendientes.
   - **Cancelados:** los `cancel_item` de T-81. Ya se cuentan aunque hoy den cero.
   - **Conflictos:** cuántos hay, con una lista que lleva a la celda.
   - **El último movimiento**, con su hora y su autor.
2. **Pilas sobre su límite**, evaluadas sobre el estado derivado. El peso de pila no es un conflicto de la bitácora (decisión de 10.13), pero la oficina tiene que ver qué pilas lo pasan después de lo que ya se cargó. Sin límite en el perfil, «no evaluado».
3. **Pensada para la laptop de la oficina**, a 1920×1080, y legible también a 360 dp.
4. **Un rótulo pequeño, de 10.13.** Tras una corrección, el botón dice «Deshacer corrección», porque al deshacer vuelve la carga anterior (regla 2.5 ampliada), y no «Deshacer carga».

**Terminada cuando:**
- [ ] **Al empezar**, con A07, A08 y el listado y la bitácora vacía, dice: descarga 114 pendientes (66/48), carga 176 pendientes (120 llenos y 56 vacíos), cero hechos y cero conflictos.
- [ ] **Al reproducir las 114 descargas y las 176 cargas del caso**, en los órdenes del corpus de T-76:
  - en **cada uno de los 290 pasos**, los números de la pantalla son iguales a un conteo independiente hecho directamente sobre la bitácora (en el corpus);
  - al final quedan 0 pendientes, 114 descargados, 120 llenos cargados y 56 vacíos asignados;
  - quedan **2 conflictos**, los «fuera de plan» de 014-01-02 y 014-01-08.
- [ ] Con un límite de prueba de 90 000 kg en un namespace de prueba, la pila 014, bodega, fila 01, sale sobre su límite al final.
- [ ] La tarea se acepta en Windows a 1920×1080 (namespace propio), en el Honor a 360 dp y en Chrome.
- [ ] Piso de 449 pruebas, `analyze` en cero, los corpus de T-68 a T-77 en verde y el nuevo de T-78.


| Tarea | Elemento | h | Qué | Terminada cuando |
|---|---|---:|---|---|
| **T-72** | RF-037 | 3.0 | Estado operativo de cada contenedor y reserva (planificado, movido, cancelado) y bitácora de movimientos: qué, cuándo, quién | Persistente y sin conexión; cada cambio queda en la bitácora con su hora |
| **T-73** | RF-038 | 4.5 | Importar el listado Excel de la agencia, con tabla de equivalencias editable (tipos, puertos, códigos de línea) y lectura de peligrosas desde CONTENIDO | `LISTADO_A08.xlsx`: 176 filas, 120 llenos que cruzan con A08 y 56 vacíos en 6 grupos; LNB ↔ LINB, COMNG ↔ COSPC · **ficha completa arriba** |
| **T-74** | RF-038 | 3.0 | Plan de carga: cruzar listado y plan; número de orden en cada celda; pendientes por bahía. **Desde T-73** la operación puede existir solo con la fuente `export_list`, porque el texto del BAPLIE no se conserva después de leerlo: T-74 guarda ese texto como fuente `loading_baplie` (y `arrival_baplie` si aplica) **en la misma operación**, no en una nueva · **ficha completa arriba** | Los 9 conteos por bahía de la sección 2 del caso, en cubierta y bodega; la operación queda con sus fuentes completas |
| **T-75** | RF-037 | 4.0 | Descarga: tocar el contenedor y queda marcado; aviso de re-estiba si su puerto no es este; deshacer | Los 114 de `CORPUS_A07` se marcan y se deshacen sin perder la bitácora · **ficha completa arriba** |
| **T-76** | RF-037 | 5.0 | Carga: confirmar un lleno por número de orden o de contenedor; asignar un vacío solo a una celda libre de su grupo; hora y marchamo; cancelar y corregir | Reproducir `CASO_A08_EVENTOS.json` deja en las 460 posiciones el contenedor de `CASO_A08_ESTADO_FINAL.csv` · **ficha completa arriba** |
| **T-77** | RF-037 | 3.0 | Validación preventiva antes de confirmar: celda, 20/40, peso de la pila, posición del planificador para los llenos, grupo para los vacíos | Un vacío en una celda de otro grupo no se confirma sin motivo escrito · **ficha completa arriba** |
| **T-78** | RF-037 | 3.0 | Vista de avance para la oficina: descargados, cargados, pendientes y cancelados, por bahía | Cuadra con la bitácora en cada momento del caso · **ficha completa arriba** |

### Ola 3 · Sincronización, cuentas y roles (13–17 oct)

#### T-79 · Sincronización: cuentas, Firestore, reglas y cola sin conexión · 10.0 h (12.0, de las que T-79a ya gastó 2.0) · Timonel (ficha completa, 9-oct)

**Para qué.** Es lo que Carlos declaró obligatorio: el muelle marca y la oficina ve el avance en tiempo real. **El diseño ya está hecho y probado** en `docs/T79a-DISENO.md`, con su contrato, su cola, sus colecciones, sus reglas (51 de 51 en el emulador) y su plan de pruebas. T-79 lo construye con los cambios que se decidieron después:
- **Windows sincroniza (10.8).** T-70c pasó contra Auth real. La fábrica de 3.4 da a Windows `FirestoreOperationSync` y `FirebaseSessionRepository`, como a Android y la Web, y el apéndice 3.4-A ya no aplica. La cola en Hive sigue siendo la fuente de verdad.
- **La salvaguarda de 5 minutos (4.5, PROVISIONAL)** va en los tres clientes. Si un movimiento lleva más de 5 minutos pendiente con el listener recibiendo, la pantalla dice «sin confirmar desde las HH:MM · inicia sesión de nuevo».
- **La huella SHA-256 de las fuentes** se calcula sobre el texto publicado tal cual (10.11). Ningún dispositivo vuelve a serializar una fuente antes de comprobarla.
- **El autor deja de ser «Muelle (sin cuenta)»** (10.11). Con sesión, el autor es el `Operator` de `authorized/{uid}`.
- **Sin cuenta, la app sigue funcionando en un solo dispositivo**, como hoy, y esos movimientos no se suben. Es el respaldo del punto de control del 14-oct. Los movimientos que ya existen sin cuenta se quedan locales, y la pantalla lo dice.

**Qué hacer**, en el orden de T-79a, 8:
1. **Sesión e inicio de sesión** (`SessionRepository`):
   - correo y contraseña, y recuperar contraseña;
   - el operador sale de `authorized/{uid}` (rol, nombre y `active`);
   - se recuerda el último operador para arrancar sin red;
   - sin registro abierto en la app: las cuentas las crea Carlos en la consola.
2. **Publicar, unirse y cerrar** (`OperationSyncRepository`):
   - la oficina publica la operación con sus fuentes en un solo lote;
   - el muelle ve las operaciones abiertas, se une y verifica la huella;
   - la oficina cierra la operación.
3. **El motor de la cola** (`sync_engine.dart`, en Dart puro), según T-79a 4.1 a 4.6:
   - idempotente: reenvía los mismos ids sin duplicar;
   - confirma por el `set` y por el eco;
   - maneja los estados de 3.3.
4. **El estado en pantalla:** al día, enviando, sin red, sesión vencida, no autorizado y rechazados, con cuántos pendientes hay.
5. **Las reglas.** El archivo final queda en `docs/T79a-firestore.rules.propuesta`, y `tool/t79_reglas.mjs` vuelve a pasar la batería de 5.4 en el emulador. **Las publica Carlos desde la consola** (T-79a, 6.4). Nunca con `firebase deploy`.
6. **`lib/main.dart`.** Esta ficha lo autoriza **solo** para montar la sesión y los proveedores de sincronización, si no hay otra forma. Cada línea que cambie se declara en el informe. Los archivos congelados de H5 no se tocan.

**Terminada cuando:**
- [ ] **La suite (T-79a, 7.1)** pasa con el motor contra un `RemoteMovementStore` falso: sin red, reinicio sin duplicar, cuenta inactiva, sesión vencida, operación cerrada, cambio de usuario y el falso que deja de confirmar sin dar error.
- [ ] **Las reglas** pasan en el emulador con la batería entera.
- [ ] **Dos dispositivos contra el emulador** (T-79a, 7.3):
  - C1, C2 y C4 a C7 pasan;
  - en C2 caben los 177 eventos con modo avión y cierre forzado: 178 documentos, cada id una sola vez, y las 460 posiciones del CSV en los dos dispositivos;
  - **C8 cambia:** Windows, como oficina, publica, ve el avance del Honor en tiempo real y no muestra los errores de hilo de `firebase_auth` de T-70.
- [ ] **En producción** (T-79a, 7.4), después de los pasos de consola de Carlos: C9 con dos cuentas reales, la oficina en Windows y el muelle en el Honor, sobre una operación «PRUEBA T-79». C10 anota las lecturas y escrituras. Nada se publica en la Web antes del 17-oct.
- [ ] **El modo de un solo dispositivo** sigue igual sin cuenta: los corpus de T-68 a T-78 dan lo mismo que hoy.
- [ ] Piso de 459 pruebas, `analyze` en cero, los corpus en verde y el nuevo de T-79.

#### T-80 · Roles: el muelle pide un cambio y la oficina lo aprueba o lo rechaza · 6.0 h · Codex (ficha completa, 9-oct)

**Para qué.** Carlos lo pidió así: los llenos los posiciona el planificador de la línea, y el muelle tiene que pedir permiso a la oficina para cambiar algo. En el caso real pasó con el intercambio de los OR 128 y 145 en la bahía 14. Hoy la bitácora ya los registra, pero salen como dos «fuera de plan» (T-72 a T-79), porque nadie aprobó el cambio. **El diseño está en T-79a:** 2.4 (los tres tipos), 2.7.2 (las dos pasadas del derivador) y las reglas de 5.2. Las reglas de los dos roles ya se probaron en T-79.

**Qué hacer.**
1. **Cada pantalla según el rol.** El rol sale de `authorized/{uid}`, por el `Operator` de T-79.
   - El **muelle** pide cambios.
   - La **oficina** aprueba o rechaza.
   - Sin cuenta, el modo de un solo dispositivo sigue como hoy y no ofrece nada de esto.
2. **El muelle pide** con un `request_change`:
   - de uno a cuatro cambios `{target, from, to}`, con motivo escrito;
   - desde el detalle de una celda, o eligiendo dos contenedores para intercambiarlos;
   - la solicitud se ve como **pendiente** en el muelle.
3. **La oficina tiene una bandeja de solicitudes.** Ahí aprueba con un `change_position` que cita la solicitud en `request`, o rechaza con un `reject_change`, siempre con motivo.
4. **El derivador hace sus dos pasadas** (T-79a, 2.7.2).
   - Primero aplica los cambios vigentes sobre el plan publicado y obtiene el **plan efectivo**.
   - Después evalúa las cargas y descargas contra ese plan.
   - Así, una carga registrada antes de que llegue la aprobación deja de estar en conflicto cuando la aprobación llega.
   - Un cambio cuyo `from` ya no coincide queda en conflicto.
5. **T-77 valida contra el plan efectivo.** Un contenedor con cambio aprobado ya no pide motivo por ir a su posición nueva.
6. **Las reglas** (decisión de 10.15).
   - Se parte `validPayload` por tipo, para que una denegación corte pronto y no agote las 1 000 expresiones.
   - Se agregan los casos de T-80, entre ellos `changes[]` con 4 elementos (permitido) y con 5 (negado).
   - La batería pasa entera en el emulador.
   - **Si el archivo cambia, Carlos lo vuelve a publicar desde la consola** y lo comprueba en el simulador, como el 9-oct. Nunca con `firebase deploy`.

**Terminada cuando:**
- [ ] **El caso completo cuadra.** Los 177 eventos del caso, con la solicitud y la aprobación, dan las 460 posiciones del CSV con **cero conflictos**, donde hoy salen 2. Pasa igual en al menos tres órdenes, incluida la aprobación después de las cargas.
- [ ] **El rechazo.** Si la oficina rechaza, las cargas de 128 y 145 vuelven a salir «fuera de plan».
- [ ] **Las reglas** pasan la batería entera, con los casos nuevos, en el emulador.
- [ ] **En producción**, en `baystream-app` y sobre una operación «PRUEBA T-80»:
  - el muelle en el Honor pide el intercambio 128 ↔ 145;
  - la oficina en Windows lo aprueba;
  - los dos ven el plan efectivo y cero conflictos;
  - un segundo pedido se rechaza;
  - Chrome muestra lo mismo.
- [ ] Piso de 485 pruebas, `analyze` en cero, los corpus en verde y el nuevo de T-80.

#### T-81 · La oficina mueve o cancela, y el muelle lo ve sin recargar · 4.0 h · Codex (ficha completa, 12-oct)

**Para qué.** Carlos lo contó así: su jefe a veces mueve o cancela llenos desde la oficina, y esos cambios tienen que llegar al muelle. T-80 ya hizo el camino con permiso: el muelle pide y la oficina aprueba. T-81 hace el camino directo: **la oficina cambia el plan por su cuenta**. El diseño ya existe en T-79a, 2.4: `change_position` **sin** `request` y `cancel_item`. Las reglas publicadas el 11-oct ya los permiten solo a la oficina, y el derivador de T-80 ya aplica el plan efectivo.

**Qué hacer.**
1. **«Mover» en la oficina.** Desde el detalle de un contenedor o de una reserva **pendiente** del plan de carga:
   - se elige la posición nueva, o se intercambian dos objetos;
   - el motivo es obligatorio;
   - se registra un `change_position` sin `request`, con 1 a 4 cambios.
   - Antes de confirmar, valida igual que T-77, contra el plan efectivo: 20/40, celda ocupada y grupo en las reservas.
   - Un objeto ya cargado no se ofrece para mover.
2. **«Cancelar» en la oficina.** Para un contenedor o una reserva pendiente que ya no embarca: un `cancel_item` con motivo.
   - En el plano queda marcado como **cancelado**: deja de contar como pendiente y aparece en la columna «Cancelados» de T-78.
3. **Deshacer, desde la oficina.** Con `annul`, como en T-75. Anular una cancelación devuelve el objeto a pendiente, y anular un movimiento restaura la posición anterior.
4. **El muelle lo ve en tiempo real, sin recargar el archivo.**
   - El plano, el modo «Número de orden» y los pendientes cambian solos.
   - Si el muelle intenta cargar algo cancelado, T-77 lo avisa («cancelado por la oficina») y no lo registra sin motivo.
5. **El muelle no puede.** La pantalla del muelle no ofrece mover ni cancelar. Forzado, la nube lo niega: la regla ya existe y solo se comprueba.
6. **Solo el plan de carga.** Cancelar o mover una descarga queda fuera de esta tarea.

**Terminada cuando:**
- [ ] **El corpus**, sobre el caso:
  - cancelar el OR 5 deja 175 cargas pendientes, y su celda vacía al final;
  - mover el OR 1 a una celda libre compatible deja su carga allí sin conflicto;
  - anular las dos cosas devuelve el estado de hoy, con 460/460;
  - todo da lo mismo en al menos tres órdenes.
- [ ] **En producción**, sobre una operación «PRUEBA T-81»:
  - la oficina en Windows mueve un contenedor y cancela otro;
  - el Honor y Chrome lo ven sin recargar, con los pendientes y «Cancelados» correctos;
  - el muelle intenta cargar el cancelado y T-77 lo frena;
  - la oficina anula la cancelación y vuelve a pendiente;
  - un `cancel_item` forzado desde el muelle sale PERMISSION_DENIED.
- [ ] Las reglas no cambian. Si hiciera falta cambiarlas, Codex se detiene y avisa: Carlos las publica.
- [ ] Piso de 498 pruebas, `analyze` en cero, los corpus en verde y el nuevo de T-81.


| Tarea | Elemento | h | Qué | Terminada cuando |
|---|---|---:|---|---|
| **T-79** | RF-032+ · RF-034 | 12.0 | Cuentas con correo y lista de autorizados; Firestore en `baystream-app`; reglas; cola sin conexión en el muelle | Dos dispositivos ven el mismo avance; uno sin red sube al volver; reglas verificadas en uso real · **ficha completa arriba** |
| **T-80** | RF-035 | 6.0 | Roles muelle y oficina; el muelle pide un cambio y la oficina lo aprueba | El intercambio 128 ↔ 145 del caso se pide desde el muelle y se aprueba desde la oficina · **ficha completa arriba** |
| **T-81** | RF-038 | 4.0 | Cambios desde la oficina: mover o cancelar contenedores, sincronizados al muelle | El muelle ve el cambio sin recargar el archivo · **ficha completa arriba** |

**Punto de control del 14-oct.** Si la sincronización no funciona para esa fecha, el
módulo de muelle se entrega **en un solo dispositivo**, con exportación de la bitácora. Así
el 24-oct siempre hay algo que funciona.

### Ola 4 · Salida, tapas, IMDG y versiones (17–21 oct)

#### T-82 · BAPLIE de salida: lo que zarpa, en la misma versión en que llegó · 10.0 h · Codex (ficha completa, 11-oct)

**Para qué.** Hoy, operaciones digita contenedor por contenedor en otro programa para mandar el BAPLIE con lo cargado y lo cancelado. Desde T-74 a T-81, BayStream ya sabe qué queda a bordo; T-82 lo escribe.

**Qué construye.**

1. **Un escritor en el dominio, en Dart puro y sin Flutter.**
   - Toma el estado que deriva `OperationStateDeriver`
     (`lib/features/vessel/domain/services/operation_state_deriver.dart`): el plan
     efectivo más los movimientos.
   - Produce el BAPLIE de lo que zarpa:
     - los ocupantes de llegada que no se descargaron, incluidos los de paso: las
       **284 posiciones que siguen a bordo salen sin re-estibar**, y sus declaraciones
       —puertos, línea, peso, peligrosas— salen del **plan de carga** (fuente
       `loading_baplie`), que es la información vigente al zarpar; la llegada queda
       como respaldo de lo que el plan no declare. El caso real lo pide: A07 y A08
       discrepan en esos campos en buena parte de los de paso y el CSV final trae los
       valores del plan (decisión de Carlos, 11-oct);
     - los llenos cargados en su celda efectiva;
     - los vacíos asignados a reservas, con los datos del contenedor que sacó del
       listado;
     - las re-estibas y los `change_position` vigentes.
   - Los cancelados y los pendientes no van.
2. **La misma versión 2.x del archivo con que se armó la operación.**
   - La cabecera, la versión de mensaje y el código de asociación salen de la fuente
     `loading_baplie`: la salida describe la misma zarpada que el plan de carga. Si la
     operación no tiene esa fuente, la acción lo dice y no genera.
   - Copia los datos del buque y del viaje.
   - Genera referencias de control nuevas, y los conteos de `UNT`/`UNZ` deben ser
     correctos.
   - Si la versión no se reconoce, no genera y lo dice. T-86 amplía después la detección.
3. **Por contenedor**, la posición, los puertos, el tipo ISO, lleno o vacío y las
   peligrosas. Para lo cargado, las peligrosas y **el VGM y la tara exactos del
   listado** (con las equivalencias de T-73). Para lo que sigue a bordo, lo que declara
   el plan de carga, con la llegada como respaldo.
   - Caso de control: el OR 12 va a `R:0030984`, con tara 2 185 kg.
4. **La lista de cancelados.** Junto al archivo, la app muestra los cancelados vigentes
   con su motivo y deja copiarla, para reportarla aparte. Decisión de Carlos, 11-oct
   (10.19).
5. **La acción «Generar BAPLIE de salida»** queda en la oficina y en el modo sin cuenta,
   no en el muelle.
   - Si quedan pendientes, avisa cuántos hay y deja generar igual.
   - Guarda con el mecanismo que ya usa la exportación a PDF
     (`pdf_report_service.dart`): guardar en Windows, compartir o guardar en Android,
     descargar en la Web.
   - **Sin dependencias nuevas.** Si hace falta una, Codex se detiene y avisa a Carlos.

**Fuera de alcance:** BAPLIE 3.1 (T-87), la detección de versión más allá de lo que ya
lee el lector (T-86), la comparación entre llegada y salida (T-96), enviarlo por correo
y cualquier cambio de reglas. La generación es local y no escribe en Firestore.

**Terminada cuando:**

- [ ] **Corpus, tanto A08 como A08v_VGM:**
  - se reproducen los 177 eventos sobre A07, A08 y `LISTADO_A08.xlsx`;
  - se genera el BAPLIE de salida;
  - el lector de BayStream (`baplie_parser_service.dart`) lo relee;
  - coincide con `CASO_A08_ESTADO_FINAL.csv` en **460/460 posiciones**, comparando
    posición, contenedor, tipo ISO, puertos, línea y peso; el lleno o vacío y las
    peligrosas coinciden con el listado en lo cargado y con el plan de carga en lo que
    sigue a bordo.
- [ ] **Ida y vuelta estable:** generar → leer → generar da el mismo texto con el reloj
      fijo.
- [ ] **La versión de cabecera** sale igual que la de la fuente `loading_baplie`,
      comprobado con cada versión 2.x que haya en A01–A08.
- [ ] **OR 12:** tara 2 185 kg en `R:0030984`.
- [ ] **Cancelación:** el OR 5 cancelado con T-81 no aparece en el EDI y la lista
      copiable lo muestra con su motivo; anulado, vuelve al EDI y la lista queda vacía.
- [ ] **Tres clientes** (Windows de oficina, Honor y Chrome): el archivo se guarda y
      BayStream lo abre.
- [ ] **Las salidas del corpus van a `%TEMP%`**, nunca al repo.
- [ ] **Calidad:** suite ≥ 508, analyze 0, corpus completo y reglas sin cambio (mismo
      SHA).

#### T-86 · La versión por la cabecera: toda la familia 2.x se lee, el resto se rechaza con mensaje claro · 3.0 h · Codex (ficha completa, 11-oct)

**Para qué.** Hoy el lector no mira la versión: abre cualquier archivo que estructure
como BAPLIE, y una 1.x o una 3.x puede entrar a medias y confundir. T-82 le puso el
control al escritor —admite SMDG20, SMDG21 y SMDG22, y rechaza lo demás—; T-86 le pone
el mismo criterio a la entrada.

**Qué construye.**

1. **Detectar la versión en la cabecera, antes de parsear contenedores**: el `UNH` con
   su versión, su liberación y su código de asociación (S009). La familia 2.x es la que
   ya admite el escritor de T-82: **SMDG20, SMDG21 y SMDG22**
   (`departure_baplie_writer.dart`).
2. **Toda la familia 2.x se lee igual que hoy.** Las nueve fuentes 2.x del corpus
   (A01–A08 salvo A06, más las variantes) siguen dando las mismas cifras de conteos y
   pesos. SMDG21 no tiene espécimen en el corpus y se prueba con fixture sintético.
3. **Lo demás se rechaza con un mensaje claro, antes de parsear.** El aviso dice el
   archivo, la versión que trae y que la app lee la familia 2.x; no es un error genérico
   de parseo. **A06 del corpus es SMDG15 (1.x) y pasa a rechazarse**: es el espécimen
   real del rechazo. Las pruebas y los corpus que hoy la leen se reescriben para esperar
   ese rechazo, y el informe dice cuáles.
4. **Casos sintéticos, TSTU:** una cabecera 3.x y una sin `UNH` reconocible se rechazan
   con el mismo mensaje. La 3.1 real la trae T-87, que necesita un archivo real.
5. **Sin tocar:** el escritor de T-82 (ya hace su propio control), la persistencia, las
   reglas y `lib/main.dart`.

**Fuera de alcance:** leer BAPLIE 3.1 (T-87), admitir asociaciones 2.x más allá de las
tres dichas sin un espécimen que las justifique, y cualquier cambio de reglas o
Firebase.

**Terminada cuando:**

- [ ] Las fuentes 2.x del corpus leen igual que hoy: las mismas cifras de conteos y
      pesos que los informes de T-66 y T-68, sin diferencias.
- [ ] A06 (SMDG15) se rechaza con el mensaje claro antes de parsear; las pruebas y
      corpus que la leían quedan reescritas y el informe las lista.
- [ ] Los fixtures sintéticos: una cabecera 3.x y una sin `UNH` reconocible se rechazan;
      un SMDG21 sintético se lee completo.
- [ ] En los tres clientes, abrir A07 sigue igual y una 1.x o 3.x sintética muestra el
      aviso (Windows, Honor a 360 dp y Chrome).
- [ ] Piso de 524 pruebas, `analyze` en cero, corpus completo en verde y reglas sin
      cambio (mismo SHA).

#### T-83 · Tapas de escotilla en el perfil del buque, por bahía · 4.0 h · Codex (ficha completa, 12-oct)

**Para qué.** RF-040, pedido de Carlos del 5-oct: por bahía hay 1, 2 o 3 tapas de grúa;
hay buques sin tapa (bodega abierta) y algunos con una sola tapa automática. Hoy el
perfil (`VesselProfile`) no declara tapas: la app no sabe qué bodega está cerrada ni
qué filas cubre cada tapa, y T-84 (quitar y reponer en la operación) y T-95
(sobreestibas por tapa) lo necesitan. Con las tapas se revisa también el supuesto de
10.13: las bahías se siguen deduciendo de los planes, pero lo que el plano no puede
deducir —qué cierra cada tapa— pasa a declararlo el perfil.

**Qué construye.**

1. **Declaración por bahía de bodega en el perfil**, una de estas configuraciones:
   - **sin tapa** (bodega abierta);
   - **una tapa automática**;
   - **de una a tres tapas de grúa**, cada una con las filas que cubre.
   - Validez: las filas cubiertas de una bahía no se solapan y pertenecen a esa bahía
     según la geometría con la que T-77 ya valida celdas y 20/40
     (`vessel_geometry.dart`); una bahía sin bodega no declara tapas.
2. **Persistencia retrocompatible:** los perfiles guardados hoy se leen sin tapas y la
   app lo dice («sin declarar»); ninguna tapa se inventa por omisión.
3. **Pantalla de edición en el perfil**, bahía por bahía, legible a 360 dp, con
   **copiar a otras bahías**: se declara una vez por buque y se copia, como pide la
   fila de la tabla.
4. **El plano lo muestra:** en la vista de bahía, el contorno de cada tapa con sus
   filas, en escala monocromática, distinguible a 360 dp, sin cambiar lo que hoy dibuja
   el plano.
5. **PROVISIONAL:** ningún buque del corpus declara tapas reales. Toda configuración de
   prueba se marca como tal en el informe; la primera declaración real vendrá del buque
   del piloto (T-101) o de la hoja de perfil que traiga Carlos.

**Fuera de alcance:** quitar y reponer tapas como movimientos (T-84; el tipo
`hatch_cover` ya existe en `movement.dart`), la segregación IMDG bajo tapa (T-85), las
sobreestibas por tapa (T-95) y cualquier cambio de reglas o Firebase.

**Terminada cuando:**

- [ ] Un perfil con tapas se guarda, se reabre y queda igual en los tres clientes.
- [ ] Las configuraciones se validan: sin tapa, automática y 1–3 de grúa con filas se
      declaran; un solape de filas o una fila ajena a la bahía se rechaza con mensaje
      claro.
- [ ] Copiar la declaración de una bahía a otras funciona y se ve en el plano.
- [ ] Un perfil guardado antes de T-83 se lee sin tapas y la app lo dice; ninguna
      aparece inventada.
- [ ] En el caso: BUQUE GOLF con A07/A08, tapas de prueba (PROVISIONAL) en las bahías
      con bodega del caso, visibles en el plano en Windows, Honor a 360 dp y Chrome.
- [ ] Piso de 547 pruebas, `analyze` en cero, corpus completo en verde y reglas sin
      cambio (mismo SHA).

#### T-84 · Tapas en la operación: quitar y reponer como movimientos, con aviso bajo tapa cerrada · 4.0 h · Codex (ficha completa, 12-oct)

**Para qué.** RF-040, la otra mitad: las tapas que T-83 puso en el perfil se usan
durante la operación. En el papel, el planificador sabe qué tapas están puestas y en
qué orden se quitan para trabajar la bodega. T-84 lo registra en la bitácora con el
tipo `hatch_cover` —que existe desde T-72 y cuya clave natural es `T:` (T-79a)—, lo
sincroniza y lo cuenta en el avance.

**Qué construye.**

1. **Quitar y reponer tapas como movimientos** `hatch_cover` en la bitácora, con
   bahía, tapa (T1–T3 o la automática) y acción (quitar o reponer).
   - El estado de cada tapa **se deriva** de la bitácora, como todo lo demás: no se
     guarda.
   - Quitar una tapa ya quitada queda en conflicto; reponer una tapa que no está
     quitada, igual. Deshacer es `annul`, como siempre.
   - Lo registra **quien opera**, muelle u oficina: es un hecho observado, no un
     cambio de plan; no hay solicitud ni aprobación.
2. **El aviso bajo tapa cerrada.** Al confirmar una descarga o una carga en una celda
   de bodega cuya tapa declarada cubre esa fila y sigue puesta, un aviso nombra la
   tapa y ofrece **«Quitar tapa y continuar»**, que registra el `hatch_cover` y el
   movimiento en un solo toque, como el par de T-77; o se sigue sin quitarla.
   - **Nunca bloquea:** las declaraciones de tapas son PROVISIONALES (T-83) y un dato
     provisional no puede frenar la operación.
   - Las bahías «sin declarar» no avisan; las celdas de cubierta tampoco.
3. **El avance de T-78 suma las tapas:** por bahía, cuántas tapas tiene declaradas,
   cuántas quitadas y cuántas repuestas, aparte de descarga y carga; el último
   movimiento ya las incluye.
4. **Sincronizado:** los movimientos de tapa suben por la cola de T-79 como los demás
   y llegan al otro cliente sin recargar. En modo sin cuenta quedan locales.
5. **Las reglas no cambian:** `hatch_cover` es uno de los nueve tipos de T-79a. Si el
   payload no pasa las reglas publicadas, Codex se detiene y avisa a Carlos.

**Fuera de alcance:** sobreestibas por tapa (T-95), segregación IMDG bajo tapa
(T-85), declarar tapas (T-83, ya hecho) y cualquier cambio de reglas.

**Terminada cuando:**

- [ ] **Corpus:** con tapas PROVISIONALES declaradas en las bahías con bodega del
      caso, reproducir el caso intercalando quitar tapa → trabajar la bahía →
      reponer tapa da el mismo **460/460** del CSV; los movimientos de tapa no
      alteran contenedores. En al menos tres órdenes.
- [ ] **El aviso:** marcar una descarga de bodega con su tapa puesta avisa y ofrece
      «Quitar tapa y continuar»; con la tapa quitada, no avisa; una bahía «sin
      declarar» no avisa; nunca bloquea.
- [ ] **Conflictos:** quitar dos veces o reponer sin haber quitado queda en conflicto;
      `annul` restaura.
- [ ] **Avance:** las tapas cuentan por bahía (declaradas, quitadas, repuestas) y
      cuadran con la bitácora en cada paso, como en T-78.
- [ ] **Sincronización:** en producción, sobre una operación «PRUEBA T-84», el muelle
      quita una tapa y la oficina lo ve sin recargar, y al revés.
- [ ] **Tres clientes:** Windows, Honor a 360 dp y Chrome.
- [ ] Piso de 563 pruebas, `analyze` en cero, corpus completo en verde y reglas sin
      cambio (mismo SHA).

| Tarea | Elemento | h | Qué | Terminada cuando |
|---|---|---:|---|---|
| **T-82** | RF-039 | 10.0 | BAPLIE de salida en la misma versión 2.x en que llegó, con lo cargado, re-estibado y cancelado; VGM y tara exactos del listado | Releído por el propio lector, coincide con `CASO_A08_ESTADO_FINAL.csv` en las 460 posiciones · **ficha completa arriba** |
| **T-83** | RF-040 | 4.0 | Tapas en el perfil del buque, por bahía: sin tapa, una automática, o 1–3 de grúa con las filas que cubre cada una | Se declaran una vez por buque y se copian a otras bahías · **ficha completa arriba** |
| **T-84** | RF-040 | 4.0 | Tapas en la operación: quitar y reponer como movimientos; aviso al marcar bodega bajo tapa cerrada | Los movimientos de tapa cuentan en el avance · **ficha completa arriba** |
| **T-85** | RF-027+ | 10.0 | Segregación por clase con las tablas 7.2.4 y 7.4.3.2 del IMDG 42-24, que Yov transcribe y verifica | Los casos sintéticos de la transcripción dan lo que dice la tabla; la clase 9 sale «no evaluado» |
| **T-86** | BAP | 3.0 | Detectar la versión por la cabecera y leer toda la familia 2.x; si llega otra, decirlo | A01 … A08 siguen igual; una 1.x o una 3.x se rechaza con un mensaje claro · **ficha completa arriba** |
| **T-87** | BAP | 10.0 | Leer BAPLIE 3.1 | Necesita un archivo real; sin él, se declara y no se empieza |
| **T-103** | BAP | 1.0 | Leer la 1.5 (SMDG15) con aviso visible; el resto de la 1.x y la 3.x se siguen rechazando (10.35) | A06 abre con sus cifras de antes de T-86 y el aviso; los corpus esperan la lectura con aviso |

### Ola 5 · Uso fuera del aula y voz

#### T-89 · Que el archivo entre aunque no se llame .edi: sin filtro por extensión y validación por contenido · 1.0 h · Codex (ficha completa, 13-oct)

**Para qué.** USO. En el iPhone (Safari, la Web publicada), el selector con filtro
por extensión deja gris un archivo que no termina en `.edi`, y desde Mail o Archivos
los BAPLIE llegan sin la extensión correcta: el usuario no puede ni elegirlos.
BayStream ya valida el contenido por la cabecera desde T-86; el filtro por nombre
estorba más de lo que ayuda.

**Qué construye.**

1. **Quitar el filtro por extensión del selector** en las tres plataformas: se puede
   elegir cualquier archivo.
2. **Validar por contenido.** Un archivo sin `UNB`/`UNH` legibles se rechaza con un
   mensaje claro («este archivo no parece un BAPLIE»), sin crear viaje ni tocar el
   almacén; el rechazo conserva el viaje anterior, como el de T-86. Si la cabecera
   existe pero la versión no es de la familia 2.x, manda el aviso de T-86.
3. **Sin tocar** el lector, el escritor ni las reglas.

**Fuera de alcance:** BAPLIE 3.1 (T-87), cualquier cambio en la nube y el resto de la
Ola 5.

**Terminada cuando:**

- [ ] En la Web (Chrome), un BAPLIE renombrado sin extensión y otro como `.txt` se
      eligen, se validan y se abren igual que un `.edi` (A07 con sus cifras).
- [ ] Un archivo de texto sin `UNB`/`UNH` se rechaza con el mensaje claro, sin crear
      viaje; una 1.x o 3.x sintética sigue dando el aviso de T-86.
- [ ] Regresión en los tres clientes: abrir un `.edi` normal sigue igual.
- [ ] Si Carlos tiene un iPhone a mano, una comprobación manual suya con un archivo
      sin extensión; si no, el informe lo declara y la primera comprobación real es
      del piloto (T-101).
- [ ] Piso de 580 pruebas, `analyze` en cero, corpus completo en verde y reglas sin
      cambio (mismo SHA).

#### T-102 · El peso en el PDF como en el plano impreso, y las pilas incompletas marcadas · 1.0 h · Codex (ficha completa, 13-oct)

**Para qué.** USO. Nace en 10.2 y pasa a T-102 en 10.13. En pantalla, las celdas
muestran el peso con un decimal desde T-66 («28.7»), pero el PDF no lo trae, y el
planificador imprime el PDF para trabajar. Y la cabecera de peso por pila no marca
las pilas donde falta algún peso: una pila incompleta se ve igual que una completa.

**Qué construye.**

1. **Peso en las celdas del PDF**, en toneladas con un decimal, como el plano
   impreso y como la celda de la app desde T-66: el **peso efectivo** (VGM si existe,
   si no bruto). En el estilo monocromático del PDF actual, sin tocar lo demás.
2. **«28.7+?» en la cabecera de peso por pila, en pantalla:** si algún contenedor de
   la pila no trae ningún peso, la cabecera muestra la suma conocida en toneladas con
   un decimal y el sufijo **«+?»**. Una pila completa sigue igual («28.7»). Las
   reservas no cuentan para el «+?»: no suman peso desde T-69.
3. **Sin cambios** en reglas, nube ni almacenamiento; el PDF se exporta por el mismo
   camino de siempre.

**Fuera de alcance:** el resto de la Ola 5, la comparación llegada/salida (T-96) y el
IMDG (T-85).

**Terminada cuando:**

- [ ] El PDF de A07 muestra en cada celda el peso con un decimal, y el peso total del
      viaje sigue siendo el del oráculo (A07: 6 940 578 kg).
- [ ] En pantalla, una pila con un contenedor sin peso muestra «…+?» y una completa
      no. En A07 y A08 no aparece «+?» (todos sus contenedores traen peso); la prueba
      del caso usa fixtures sintéticos con y sin peso.
- [ ] Los tres clientes exportan y abren el PDF, y la pantalla no se rompe a 360 dp.
- [ ] Piso de 592 pruebas, `analyze` en cero, corpus completo en verde y reglas sin
      cambio (mismo SHA).

#### T-91 · Barra superior plegable: los iconos se esconden mientras se ve el plano · 1.5 h · Codex (ficha completa, 13-oct)

**Para qué.** USO, de la prueba de campo. En el plano, los iconos de acciones junto al
título quitan espacio justo donde hace falta ver bahías y celdas, y a 360 dp la barra
llega apretada: con un viaje abierto desborda (observado en T-89 y T-102). La barra se
pliega mientras se trabaja el plano y se despliega cuando se necesita.

**Qué construye.**

1. **Un estado plegado de la barra superior en la vista del plano:** solo el título y
   el botón de desplegar; los iconos de acciones quedan ocultos.
2. **Desplegar y plegar con un toque**, sin recargar el plano ni perder el estado de
   la vista (bahía, modo, zoom). La elección se recuerda por dispositivo, en el
   almacén de ajustes, como el último puerto de escala de T-68.
3. **Al plegar no se pierde ninguna acción:** se recuperan al desplegar. Los modos de
   operación (Descarga, Carga, Tapas, Número de orden) y sus controles no cambian.
4. **A 360 dp y en los dos temas:** plegada, la barra no desborda. El título cortado y
   los demás textos de la barra siguen siendo deuda de T-97 y no se tocan aquí.

**Fuera de alcance:** los textos de T-97 (título sin truncar, fila del detalle,
«1 cargados», «(0 cub. / 0 bod.)», punto doble, «Conectando…»), las demás pantallas
que no molesten y cualquier cambio de reglas o Firebase.

**Terminada cuando:**

- [ ] En el plano de A07, en los tres clientes: plegada muestra solo el título y el
      botón; desplegada, todas las acciones; alternar no recarga el plano ni pierde la
      vista.
- [ ] El desborde observado a 360 dp con viaje abierto desaparece al menos plegada;
      lo que quede expandido se declara para T-97, no se arregla de paso.
- [ ] La preferencia sobrevive cerrar y reabrir la app en cada cliente.
- [ ] Los dos temas, con colores de `colorScheme`, sin literales.
- [ ] Piso de 599 pruebas, `analyze` en cero, corpus completo en verde y reglas sin
      cambio (mismo SHA).

#### T-90 · Interruptor de tema claro y oscuro, con barrido en claro · 2.0 h · Codex (ficha completa, 13-oct)

**Para qué.** USO, de la prueba de campo. La app sigue el tema del sistema y las dos
paletas existen desde la convención 2.8 (nada de colores que solo funcionen en
oscuro). Falta elegir el tema desde la app: en el muelle, con sol, el modo claro
ayuda; en la oficina de noche, el oscuro. Y el modo claro tiene que estar a la altura
en todas las pantallas.

**Qué construye.**

1. **El interruptor de tema en «Parámetros», con tres estados:** claro, oscuro y
   **seguir al sistema** (por omisión). Persistido por dispositivo en la caja de
   ajustes, como `planToolbarCollapsed` de T-91 y el último puerto de T-68; no se
   sincroniza.
2. **El barrido en claro de las pantallas principales:** viajes recientes, plano con
   A07 (plegada y desplegada, de T-91), detalle de contenedor y de reserva, modo
   Número de orden, avance de la operación, importación del listado y perfil con
   tapas. Lo que solo se lea bien en oscuro se corrige aquí, con `colorScheme`, sin
   literales.
3. **Sin cambios** en reglas, nube ni almacenamiento del viaje.

**Fuera de alcance:** los textos de T-97, nuevos temas o colores de marca, y
cualquier cambio de reglas o Firebase.

**Terminada cuando:**

- [ ] El interruptor funciona en los tres clientes: claro, oscuro y sistema, con
      persistencia tras cerrar y reabrir, y el sistema manda mientras no se elija.
- [ ] El barrido en claro pasa por las pantallas listadas sin textos ilegibles ni
      elementos invisibles; el informe dice qué se corrigió.
- [ ] Ambos temas a 360 dp en el Honor, con la barra plegada y desplegada.
- [ ] Piso de 605 pruebas, `analyze` en cero, corpus completo en verde y reglas sin
      cambio (mismo SHA).

#### T-94 · Búsqueda por voz: dictar el contenedor, o sus últimos dígitos, y encontrarlo · 4.5 h · Codex (ficha completa, 13-oct)

**Para qué.** RF-041, pedido de Carlos del 5-oct. En el muelle, con las manos
ocupadas, teclear los últimos dígitos es lento: la voz convierte la búsqueda de T-76
(OR o últimos dígitos) en un dictado. **El paquete autorizado es `speech_to_text`
(Carlos, 13-oct)**; es la primera dependencia nueva desde T-79.

**Qué construye.**

1. **Un botón de micrófono junto a la búsqueda del muelle** (la de T-76: OR o
   últimos dígitos). Al pulsar, escucha; el transcript llega al campo **como
   borrador**: el usuario confirma y nada se ejecuta solo con el reconocimiento.
2. **Normalización del transcript, en el dominio:** dígitos (palabras 0–9 y
   secuencias), las letras de los prefijos de contenedor con los nombres que produce
   el reconocedor en español, y espacios y puntuación fuera. Lo que no normalice
   queda como vino, editable a mano.
3. **El reconocedor detrás de un contrato**, con una implementación falsa para las
   pruebas: la suite no depende de micrófono ni de red.
4. **Soporte real por plataforma:** la voz es del muelle. Donde la versión de
   `speech_to_text` no tenga soporte (Windows y, si aplica, la Web), el botón no
   aparece o se muestra «no disponible» sin romper nada; el informe documenta la
   matriz de soporte de la versión usada.
5. **Permiso de micrófono:** esta ficha autoriza añadir `RECORD_AUDIO` al manifest
   de Android, cambio mínimo y declarado. La política de privacidad que lo menciona
   es parte de T-88, de Yov.
6. **Sin red, sin drama:** la búsqueda manual nunca depende de la voz. Si el
   reconocimiento no está disponible sin conexión, la app lo dice y el micrófono
   falla con claridad; nada de fingir fuera de línea.

**Fuera de alcance:** dictar comandos de operación (cargar, descargar), idiomas que
no sean español, subir el transcript a la nube (la búsqueda es local) y cualquier
cambio de reglas.

**Terminada cuando:**

- [ ] **Pruebas automatizadas con recognizer falso:** la normalización cubre dígitos,
      secuencias, letras de prefijo y ruido; el borrador llega al campo y no busca
      hasta confirmar; sin soporte, el botón no aparece.
- [ ] **Dictado real en el Honor (`.t94`), con la voz de Carlos:** un contenedor
      completo del caso y otro por sus últimos dígitos; ambos quedan como borrador y
      la búsqueda existente los encuentra. Codex documenta lo observado; la
      aceptación del dictado es manual de Carlos.
- [ ] **Sin soporte:** en Windows y, si aplica, Chrome, el botón no aparece o dice
      «no disponible», y la búsqueda manual sigue igual.
- [ ] **Modo avión en el Honor:** si el reconocimiento no está disponible, la app lo
      dice y la búsqueda manual funciona igual.
- [ ] **El permiso** `RECORD_AUDIO` queda en el manifest, declarado en el informe y
      en el bloque de commit, con la implicación para T-88 anotada.
- [ ] **La dependencia** `speech_to_text`, versión fijada, se declara con su versión
      y por qué; `pubspec.yaml` y `pubspec.lock` cambian y se declara.
- [ ] Piso del momento (el vigente tras T-90), `analyze` en cero, corpus completo en
      verde y reglas sin cambio (mismo SHA).

**Corrección de T-94 (15-oct, 10.38) · Codex · sin estimación nueva: es parte de T-94.**

**Qué falla.** En el lote, con el Honor en modo avión, el micrófono se activó y se apagó
sin decir nada, 3 de 3 intentos. La búsqueda manual siguió bien, y lo demás de T-94 pasó.
Yov lo vio en el código:
- `speech_to_text_recognizer.dart` llama a `onDone` al recibir el estado `done`;
- `voice_search_field.dart` responde a `onDone` con `_cancel()`, que sube la sesión y deja
  sin destino a `_failure`;
- si el plugin manda `done` antes que `onError`, el error se pierde y no aparece ningún aviso.

El 13-oct Carlos sí vio el aviso: el orden de los dos eventos no es fijo.

**Qué construye.**
1. **Un error que llega justo antes o justo después de `done` siempre se muestra.** El
   cierre de la sesión espera ese error un momento breve, o deja que el error mande. El
   mecanismo lo elige Codex, y lo declara.
2. **Una escucha que termina sin texto y sin error también avisa**, con el mismo tono que
   los otros mensajes de voz: que no se reconoció nada y que se puede escribir la búsqueda.
   Nunca hay silencio.
3. **Lo demás de T-94 no cambia:**
   - el texto dictado sigue entrando como borrador;
   - no se busca solo;
   - se cancela al salir de la pantalla;
   - sin dependencias nuevas.

**Terminada cuando:**
- [ ] **Hay pruebas de widget con el reconocedor falso para los tres órdenes:** error y
      después `done`, `done` y después error, y `done` sin texto ni error. En los tres
      aparece un aviso, y nada se busca solo.
- [ ] **Honor sin red** (`.t94` o una variante nueva, en modo avión; Carlos habla): 3 de 3
      intentos muestran el aviso, y la búsqueda manual encuentra el OR 3.
- [ ] **Honor con red:** el OR 1 completo y un sufijo siguen entrando como borrador.
- [ ] **Validaciones:** piso de 660 más las nuevas, `analyze` en cero, corpus 116/116 con
      242/242 de T-94, y las reglas sin cambio.
- [ ] **Antes de correr el corpus completo**, Codex aplica la regla nueva de 10.38: el
      corpus `block3` escribe en el almacén real de Windows.

#### T-92 · La Web arranca sin conexión: motor, fuentes y SDK de Firebase servidos desde el propio sitio · 3.0 h · Codex (ficha completa, 14-oct)

**Para qué.** USO. Cierra la limitación de 10.36 de `SPRINT-2.md`: sin red, la Web
queda en blanco porque baja de Google lo que necesita para arrancar. El muelle sin
señal lo cubre Android, pero la Web es la del iPhone (T-89) y la de una laptop de
oficina sin la app de Windows. Sirve también a T-88: con todo servido desde el sitio,
la Web deja de pedir código y fuentes a terceros, y solo los servicios de datos de
Firebase hablan con fuera.

**Lo que hay hoy (Yov lo revisó en el repo, 14-oct).**

- Se compila con `flutter build web --release --no-pub
  --dart-define-from-file=…\firebase-prod.json` (T-48), con Flutter 3.38.9 (motor
  `587c18f8…`). Hosting publica `build/web` con `no-cache` en todo y la reescritura
  `** → /index.html`.
- `web/` es la plantilla de `flutter create`. `index.html` solo carga
  `flutter_bootstrap.js` y no hay plantilla propia de ese archivo. El título y el
  manifiesto dicen «baystream» y «A new Flutter project.».
- **Al arrancar, la página pide tres cosas a Google:**
  1. **CanvasKit**, a `www.gstatic.com/flutter-canvaskit/<motor>/`, aunque la
     compilación ya deja una copia en `build/web/canvaskit/`.
  2. **Roboto**, a `fonts.gstatic.com`. El motor la baja cuando `FontManifest.json`
     no declara una familia «Roboto», y hoy solo declara `MaterialIcons`. Los
     `assets/fonts/Roboto-*.ttf` son del PDF: no están declarados como familia.
  3. **El SDK JS de Firebase**, a `www.gstatic.com/firebasejs/<versión>/`.
     `firebase_core_web 3.10.0` inyecta `firebase-app.js`, `firebase-auth.js` y,
     para Firestore, `firebase-firestore-pipelines.js` (T-48 vio el primero y el
     último).
- **El tercero es el que 10.36 no alcanzó a aislar, y es el que más pesa.**
  `lib/main.dart` espera a `Firebase.initializeApp` antes de `runApp`. Si el SDK no
  carga, la app nunca se dibuja, aunque CanvasKit y la fuente estén. Por eso no basta
  con `--no-web-resources-cdn`.
- **El service worker de Flutter ya existe** (`flutter_service_worker.js`).
  - Al instalarse, guarda `main.dart.js`, `index.html`, `flutter_bootstrap.js` y los
    dos manifiestos.
  - Después guarda lo demás del propio origen a medida que se pide.
  - Lo de otros dominios nunca lo guarda. Servir todo desde el sitio es lo que lo
    vuelve útil.
- `build/web` trae además `t54-format.html` y `t54-format.js`, de una tarea vieja.
  Hosting los publicaría tal cual.

**Qué construye.**

1. **CanvasKit desde el sitio.** Se configura en el cargador (`canvasKitBaseUrl`),
   dentro de una plantilla propia `web/flutter_bootstrap.js`, para que el comando de
   T-48 no dependa de recordar una bandera. Se sigue compilando con dart2js, sin
   `--wasm`.
2. **Las fuentes desde el sitio.**
   - `fontFallbackBaseUrl` apunta a una carpeta propia que replica las rutas que pide
     el motor: Roboto y las fuentes de reserva que pida el recorrido completo de la
     app (primer criterio de «Terminada cuando»).
   - La ruta exacta de Roboto se toma del motor de la 3.38.9, no de memoria.
   - **La tipografía de Android y Windows no cambia.** Nada de declarar una familia
     «Roboto» en `pubspec.yaml`: en Android reemplazaría la fuente del sistema.
3. **El SDK de Firebase desde el sitio**, en la versión exacta que pide
   `firebase_core_web 3.10.0` (`supportedFirebaseJsSdkVersion`):
   - Los módulos que hoy inyecta se bajan de `gstatic`, con su SHA-256, junto con
     cualquier módulo que importen, recursivamente.
   - Sus `import` absolutos a `https://www.gstatic.com/firebasejs/…` pasan a
     relativos, para que haya **una sola instancia** de `firebase-app`. Es el defecto
     conocido de servirlos tal cual (flutterfire #12204).
   - La plantilla los importa y deja puestos `window.firebase_core`,
     `window.firebase_auth` y `window.firebase_firestore` **antes de arrancar el
     motor** (en `onEntrypointLoaded`, antes de `initializeEngine`). Al ver
     `firebase_core`, `firebase_core_web` no inyecta nada.
   - Así el orden no depende de una carrera, y los módulos se piden cuando el service
     worker ya controla la página.
   - El mecanismo se confirma en el código de la 3.10.0 del caché de pub, servicio
     por servicio.
4. **El service worker de Flutter, tal cual,** con la versión que pasa la plantilla
   (`{{flutter_service_worker_version}}`). Nada de un service worker propio ni de
   Workbox. El informe mide cuántas visitas con red hacen falta para arrancar sin
   red. La meta es **una**.
5. **Licencia y procedencia junto a cada archivo de terceros:** el SDK (Apache 2.0) y
   las fuentes. Un `LEEME` dice la versión, la URL de origen, el SHA-256 antes y
   después de reescribir los `import`, y cómo se actualiza cuando cambie
   `firebase_core_web`.
6. **El nombre en la Web:** «BayStream» en el título de la pestaña, en
   `apple-mobile-web-app-title` y en `name` y `short_name` del manifiesto, con la
   descripción en español y `lang="es"`. Los íconos no se tocan (T-88).
7. **Dos herramientas de la tarea, sin dependencias nuevas:**
   - Un servidor local para las pruebas (`tool/t92_*`). Sirve la compilación en
     `localhost` con los tipos MIME correctos: el servidor de Python por defecto, en
     Windows, puede servir `.js` como `text/plain`, y el navegador rechaza los
     módulos.
   - Un verificador del sitio compilado. Comprueba que CanvasKit y las fuentes salen
     de rutas propias y que la ruta de Roboto es la del motor. También, que el SDK
     está y figura en la lista del service worker, que no queda ningún `import`
     absoluto y que no sobra ningún archivo.
8. **Pruebas en `test/`, que dependen solo del repo y de los paquetes resueltos:**
   - la versión servida del SDK es la que pide `firebase_core_web`;
   - ningún módulo servido importa por URL absoluta;
   - la plantilla toma CanvasKit, las fuentes y Firebase de rutas propias, y fija los
     módulos antes de arrancar el motor;
   - cada archivo de terceros trae su licencia.
   - Lo que depende del SDK de Flutter o de la compilación va al verificador, no a la
     suite.

**Carril.**
- La tarea toca `web/`, `test/t92_*`, `tool/t92_*` y `docs/T92-RESULTADOS.md`.
- **No toca `lib/`, `lib/main.dart` ni `pubspec.*`:** lo que está en `web/` entra en
  la compilación sin declararse.
- `firebase.json`, solo si una prueba demuestra que hace falta, y declarado.
- Compila hacia `build/t92/…`, no hacia `build/web`.
- **No es una dependencia nueva:** el SDK, CanvasKit y Roboto ya los usa la app.
  Cambia de dónde llegan.

**Una consecuencia aceptada.** Con la base de fuentes propia, un carácter que no
cubra ninguna fuente servida sale como un recuadro, también con red: hoy lo bajaría
de Google. Un ejemplo es un emoji escrito en un motivo. La app está en español, y el
recorrido fija qué se sirve. El informe lo declara para T-98.

**Detente y avisa si:**
- arrancar sin red exige tocar `lib/`;
- el SDK servido no replica la inicialización: un servicio «no disponible» o dos
  instancias de la app;
- las fuentes exigen cambiar la tipografía de Android o Windows;
- hace falta un service worker propio o una herramienta nueva;
- el motor de la 3.38.9 no admite las rutas propias como las describe esta ficha.

**Fuera de alcance:**
- publicar: lo hace Carlos después del 17-oct;
- los íconos y lo de Play (T-88);
- un aviso de «instalar la app» y precargar el sitio entero;
- el iPhone: no hay uno, y queda para el piloto;
- cualquier cambio de reglas o de `lib/`;
- los clientes de Windows y Android, que no se recompilan.

**Terminada cuando:**

- [ ] **El inventario, antes y después**, con el mismo recorrido, en `localhost`, con
      Chrome visible y con red. El recorrido abre A07 y pasa por el plano, Lista,
      Estadísticas y Avance, en los dos temas, y exporta el PDF.
  - Antes, con la compilación de HEAD: las peticiones a `gstatic` y a
    `fonts.gstatic.com`.
  - Después: **ninguna petición de código ni de fuentes fuera del sitio**.
  - Las que quedan son de datos (Auth, Firestore) u otras de Firebase, cada una
    clasificada en el informe.
- [ ] **Arranque sin red tras una visita, en el Chrome de la laptop:**
  - Perfil limpio, una visita con red y A07 abierto.
  - Después, el servidor detenido y los dominios externos bloqueados, sin cortar la
    red de la máquina: por ejemplo, un Chrome propio con `--host-resolver-rules`.
  - Al recargar, la app abre y A07 se reabre desde Recientes con sus cifras: 398
    contenedores, 21 bahías, 6 940 578 kg y 0/114/284 en GTSTC.
  - El texto se ve completo, y la consola no avisa de fuentes ni de caracteres sin
    fuente.
  - Si hacen falta dos visitas, el informe dice por qué.
- [ ] **Lo mismo en el Chrome del Honor:** `adb reverse` al mismo servidor, una visita
      con red, y después modo avión con el servidor detenido.
- [ ] **La sincronización sigue igual con el SDK servido:**
  - Con red, Carlos inicia la sesión de muelle en la Web local.
  - «PRUEBA T-84» llega a «Al día» con los mismos conteos que con la compilación de
    HEAD.
  - Sin red, la sesión se conserva y el estado dice «Conectando…» (10.32). Al volver
    la red, dice «Al día».
  - Sin publicar nada.
- [ ] **Una versión nueva reemplaza a la guardada.** Se recompila con otro número de
      compilación. Una visita con red deja la nueva (`version.json`), y sin red abre
      la nueva.
- [ ] El verificador pasa sobre la compilación final. El informe da el tamaño que se
      suma al repo y lo que baja la primera visita, antes y después.
- [ ] **El bloque de publicación para Carlos**, para después del 17-oct:
  - compilar limpio en `build/web`, sin los `t54-format.*`;
  - correr el verificador;
  - el `firebase deploy --only hosting` de T-48, que corre él;
  - una comprobación de cinco minutos sobre `baystream-app.web.app`, en la laptop y
    en el Honor.
- [ ] Piso de **648** más las nuevas, `analyze` en cero y corpus **116/116**. Mismo
      SHA de las reglas, de `lib/`, de `pubspec.*` y de los dos congelados de H5.

#### T-93 · El instalador de Windows: BayStream como paquete MSIX firmado, para la oficina y el piloto · 2.5 h · Timonel (ficha completa, 14-oct)

**Para qué.** USO. La oficina sincroniza en la app de Windows (10.8), y el piloto
(T-101) la necesita instalada en una PC de COMAR. Hoy se copia a mano la carpeta
`Release`. T-93 la entrega como un paquete MSIX:
- se instala con doble clic;
- aparece en el menú Inicio;
- se actualiza instalando la versión siguiente;
- se desinstala desde Configuración.

**Carlos eligió MSIX con el paquete `msix` (10.36).**

**Lo que hay hoy (Yov lo revisó en el repo, 14-oct).**

- El proyecto de Windows se llama `baystream` (`windows/CMakeLists.txt`). Se
  compila con `flutter build windows --release
  --dart-define-from-file=…\firebase-prod.json`. Sin esas definiciones, la app
  abre en «Falta la configuración de Firebase» (`lib/main.dart`).
- El almacén local vive en `%LOCALAPPDATA%\BayStream\vessel_store`
  (`local_store_directory_io.dart`).
  - En una app empaquetada, Windows redirige las escrituras en `AppData` a la
    carpeta privada del paquete (`%LOCALAPPDATA%\Packages\<familia>\LocalCache\…`),
    y puede dejar leer lo que ya existía en la ubicación real. Es lo que vio 10.9
    con la app lanzada desde Codex.
  - En la laptop de Carlos, el almacén real trae datos de prueba (BUQUE GOLF y los
    namespaces de las aceptaciones). El lote de Timonel, que viene después de
    esta tarea, lo usa con `tloteacc`.
- El identificador de la app es `gt.cmartinez.baystream` (Android, Play y
  Firebase).

**Antes de empezar: el certificado, que crea Carlos una sola vez.**

1. En PowerShell normal (sin administrador), Carlos crea un certificado
   autofirmado en su almacén de usuario. La clave **no se puede exportar**: no hay
   `.pfx` ni contraseña. Solo se exporta la parte pública (`.cer`) a
   `baystream-privado`:

   ```powershell
   $cert = New-SelfSignedCertificate -Type Custom -Subject "CN=BayStream" -FriendlyName "BayStream MSIX" -KeyUsage DigitalSignature -KeyExportPolicy NonExportable -CertStoreLocation "Cert:\CurrentUser\My" -NotAfter (Get-Date).AddYears(3) -TextExtension @("2.5.29.37={text}1.3.6.1.5.5.7.3.3", "2.5.29.19={text}")
   New-Item -ItemType Directory -Force -Path C:\Proyectos\baystream-privado\msix | Out-Null
   Export-Certificate -Cert $cert -FilePath C:\Proyectos\baystream-privado\msix\BayStream.cer | Out-Null
   $cert.Thumbprint
   ```

2. En PowerShell **como administrador**, para que su laptop acepte el paquete:

   ```powershell
   Import-Certificate -FilePath C:\Proyectos\baystream-privado\msix\BayStream.cer -CertStoreLocation Cert:\LocalMachine\TrustedPeople
   ```

3. Carlos le pasa a Timonel la **huella** (`Thumbprint`), que no es secreta.
   - Timonel firma con `signtool /sha1 <huella>`, que toma la clave del almacén de
     Carlos sin exportarla.
   - El `.cer` es público y viaja con el `.msix` a cada PC.

**Qué construye.**

1. **`msix` como dependencia de desarrollo**, con versión fija.
   - Tiene que ser compatible con Dart 3.9 y Flutter 3.38.9, y no mover ningún
     paquete que ya esté en el lock.
   - `pubspec.yaml` y `pubspec.lock` cambian, y se declara con las versiones.
2. **`msix_config` en `pubspec.yaml`, sin secretos:**
   - `display_name: BayStream` y `publisher_display_name: Carlos Martínez`;
   - `identity_name: gt.cmartinez.baystream`;
   - `publisher: CN=BayStream`, exactamente el sujeto del certificado;
   - `msix_version: 1.0.0.0`;
   - `capabilities: internetClient` y nada más. Sin micrófono: en Windows no hay
     voz (T-94);
   - el ícono actual de Windows (`windows/runner/resources/app_icon.ico`). El ícono
     propio es de T-88;
   - **`build_windows: false`:** el paquete se arma siempre sobre la compilación
     Release hecha antes con las definiciones de Firebase, nunca con una compilación
     propia del paquete sin ellas;
   - **`install_certificate: false`:** la herramienta no toca los almacenes de
     certificados; eso lo hace Carlos;
   - la firma, con `signtool_options` (`/fd SHA256 /sha1 <huella>`). La huella llega
     por la línea de comandos, no por `pubspec.yaml`.
   - Los nombres de las opciones se confirman en la documentación y el código de la
     versión fijada del paquete, no de memoria.
3. **`tool/t93_msix.ps1`**, que hace las dos cosas en orden y no imprime nada
   privado:
   1. `flutter build windows --release`, con `--dart-define-from-file`;
   2. `dart run msix:create`, con la huella y la versión como parámetros.
   - Se detiene si la compilación falla.
   - Deja el `.msix` en `build/t93/` y escribe su SHA-256.
4. **Una prueba en `test/t93_*`** que fija lo que protege `msix_config`:
   - `build_windows: false` e `install_certificate: false`;
   - el `publisher` igual a `CN=BayStream`;
   - ninguna contraseña ni ruta de certificado en `pubspec.yaml`.
5. **Las instrucciones para una PC de oficina**, en el informe, para T-100 y el
   piloto:
   - importar el `.cer` en «Personas de confianza» del equipo local, como
     administrador y una sola vez;
   - doble clic al `.msix` y abrir desde Inicio;
   - cómo actualizar y cómo desinstalar;
   - **sincronizar hasta «Al día» antes de desinstalar**, porque desinstalar borra
     el almacén del paquete, con los movimientos que no hayan subido.

**Carril.**
- La tarea toca `pubspec.yaml`, `pubspec.lock`, `tool/t93_*`, `test/t93_*` y
  `docs/T93-RESULTADOS.md`.
- **No toca `lib/`, `lib/main.dart` ni `windows/`.**
- `flutter build windows` escribe en `build/windows`. Timonel hace T-93 antes del
  lote; el lote empieza cuando Carlos commitee T-93. Si Codex corre Flutter
  mientras tanto, Carlos da el semáforo: un comando de Flutter a la vez, y nadie
  pisa los binarios del otro.
- **La aceptación cruzada de T-93 la hace Codex**, después.

**El almacén, que es lo delicado.**
- Antes de instalar, Timonel toma el SHA-256 de cada archivo del almacén real
  `%LOCALAPPDATA%\BayStream`, sin abrirlos. Después de todas las pruebas, la huella
  tiene que ser la misma. La app instalada no puede alterar el almacén real ni los
  namespaces del lote.
- El informe dice dónde escribe la app instalada, y si ve o no lo que ya había en
  el almacén real.
- No se registra ningún movimiento. La sesión y la sincronización son solo de
  lectura, sobre «PRUEBA T-84».

**Detente y avisa si:**
- el paquete exige tocar `lib/`, `windows/` o `main.dart`;
- `msix` mueve algún paquete existente del lock, o no hay una versión compatible;
- la app instalada no sincroniza o no encuentra su almacén;
- el almacén real cambia;
- firmar exige un `.pfx`, una contraseña o abrir algo de `baystream-privado`.

**Fuera de alcance:**
- Microsoft Store y un certificado comercial;
- la actualización automática (`.appinstaller`) y un acceso directo en el
  escritorio;
- el ícono propio (T-88);
- Windows 10 en una PC de COMAR: queda para el piloto;
- distribuir el `.msix`, que lo hace Carlos.

**Terminada cuando:**

- [ ] **Instalación.** El `.msix` firmado se instala en la laptop de Carlos, con
      doble clic o con `Add-AppxPackage`.
  - «BayStream» aparece en Inicio con su ícono.
  - La app abre con las opciones de Firebase, no en «Falta la configuración de
    Firebase».
- [ ] **El plano.** La app instalada abre A07 con sus cifras: 398 contenedores, 21
      bahías, `6940.6 t` y 0/114/284 en GTSTC. Lo guarda en Recientes y lo conserva
      al cerrarla por PID y volver a abrirla.
- [ ] **La sincronización.** Con la sesión que inicia Carlos, «PRUEBA T-84» llega a
      «Al día» con sus conteos: 4 contenedores, 3 bahías, 20.0 t y 0/3/1 en GTSTC.
      Sin registrar movimientos.
- [ ] **La actualización.** Un segundo paquete, con una versión mayor (por ejemplo
      `1.0.1.0`), se instala encima y conserva el viaje, Recientes y la sesión.
- [ ] **La desinstalación.** Se desinstala desde Configuración o con
      `Remove-AppxPackage`, y el informe dice qué queda y qué se borra. Al terminar,
      Carlos decide si deja instalada la versión final.
- [ ] **El almacén real** `%LOCALAPPDATA%\BayStream` tiene la misma huella antes y
      después de todo.
- [ ] **En el informe,** las instrucciones para una PC de oficina y el bloque con el
      que Carlos regenera el paquete.
- [ ] **Piso de 655** más las nuevas, `analyze` en cero y corpus **116/116**.
  - Mismo SHA de las reglas, de `lib/` y de los congelados.
  - `pubspec.*` solo cambia por `msix` y sus transitivas nuevas, declaradas con
    sus versiones.

| Tarea | Elemento | h | Qué |
|---|---|---:|---|
| **T-88** | USO | 2.5 | Requisitos de Play: política de privacidad nueva (con sincronización sí salen datos; micrófono opcional y voz del servicio del sistema, 10.31), enlace en la app, ícono propio, decisión D3 (10.34) |
| **T-89** | USO | 1.0 | iPhone acepta .edi: sin filtro por extensión y validación por contenido (`UNB`/`UNH`) · **ficha completa arriba** |
| **T-90** | USO | 2.0 | Modo claro y oscuro con interruptor, en los tres clientes · **ficha completa arriba** |
| **T-91** | USO | 1.5 | Barra superior plegable: ocultar los iconos junto al título mientras se ve el plano · **ficha completa arriba** |
| **T-92** | USO | 3.0 | Web sin conexión: servir el motor de dibujo, las fuentes y el SDK de Firebase desde el propio sitio · **ficha completa arriba** |
| **T-93** | USO | 2.5 | Instalador de Windows: paquete MSIX firmado con el paquete `msix` (Carlos, 10.36) · **ficha completa arriba** |
| **T-94** | RF-041 | 4.5 | Dictar el número de contenedor, o sus últimos dígitos, y buscarlo · **ficha completa arriba** |
| **T-102** | USO | 1.0 | Peso en las celdas del PDF, como en el plano impreso (nace en 10.2). Incluye que la cabecera de peso por pila marque una pila con pesos faltantes («28.7+?», de 10.2; pasa aquí en 10.13) · **ficha completa arriba** |

### Ola 6 · Resto del ERS

#### T-97 · El título sin truncar y los textos acumulados del sprint · 1.0 h · Codex (ficha completa, 13-oct)

**Para qué.** ERS y RNF-003. Son los textos que el sprint fue anotando decisión tras
decisión: el título que se corta a 360 px y siete deudas más de palabras y
disposición. Cada una es chica; juntas son la letra pequeña que el planificador lee
todo el día.

**Qué construye.** El catálogo completo, con su origen:

1. **El título de la pantalla se lee completo a 360 dp** (RNF-003): sin «…». El
   mecanismo lo elige el diseño (hasta dos líneas, tamaño adaptable). Con la barra
   desplegada de T-91 también debe quedar espacio visible para él.
2. **«Total Contenedores» no se corta a 360 dp** (10.2).
3. **La fila del detalle se adapta** cuando el texto no cabe, incluso con la letra
   del sistema muy grande (10.11): envolver o reducir, sin recortar.
4. **Los contadores concuerdan en singular y plural** — hoy «1 cargados» (10.14).
5. **«(0 cub. / 0 bod.)» dice que son pendientes** — por ejemplo «(0 pend. en
   cubierta / 0 pend. en bodega)» o la forma que quede igual de clara (10.14).
6. **El punto doble al final de un rechazo desaparece** (10.16).
7. **En la Web, al abrir un plano, el estado dice «Conectando…» mientras averigua,**
   y «Sin conexión» solo cuando lo sabe (10.16).
8. **El selector de bahía no desborda con el texto al 200 %** (observado en T-102).

Es todo presentación: sin cambios en reglas, nube ni almacenamiento.

**Fuera de alcance:** textos o pantallas nuevas, el resto de la Ola 6 y cualquier
cambio de reglas o Firebase.

**Terminada cuando:**

- [ ] Cada punto del catálogo se ve corregido, en los dos temas, con A07 abierto.
- [ ] A 360 dp en el Honor: el título completo, «Total Contenedores» completo, la
      fila del detalle con letra al 200 % sin cortar y el selector de bahía sin
      desborde, con prueba de widget a escala 2.0 incluida.
- [ ] La Web abre un plano y muestra «Conectando…» al empezar y «Sin conexión» solo
      cuando lo confirma.
- [ ] Los tres clientes muestran las pantallas tocadas, sin regresiones en la barra
      de T-91 ni en los temas de T-90.
- [ ] Piso de 635 pruebas, `analyze` en cero, corpus completo en verde y reglas sin
      cambio (mismo SHA).

#### T-104 · Las deudas del lote: el corpus que escribe en el almacén real y los textos a 200 % · 2.5 h · Codex (ficha completa, 15-oct; añadido en 10.39)

**Para qué.** Nace en 10.38, del lote de Timonel. Son cuatro cosas chicas del mismo
carril, juntas para no multiplicar entregas:
- una prueba que ensucia el almacén real de Windows en cada corrida;
- dos plurales mal hechos;
- un texto que contradice a T-89;
- tres pantallas que se cortan con la letra al 200 %.

Las dos primeras importan para medir los RNF (T-98 y T-99) y para el piloto; las otras,
para RNF-003.

**Qué construye.**

1. **`tool/block3_corpus_test.dart` deja de escribir en el almacén real.**
   - Hoy sobrescribe `localVesselRepositoryProvider`, pero no
     `movementLogRepositoryProvider`.
   - Como `confirmGeometry` guarda la operación, cada corrida suma ≈ 173 KB a
     `%LOCALAPPDATA%\BayStream\vessel_store\baystream_operations.hive`, en el namespace por
     defecto.
   - Se sobrescribe con un almacén en un directorio temporal, como el resto.
2. **Una salvaguarda en `localStoreDirectory()`:** bajo `flutter test`
   (`FLUTTER_TEST=true`), en Windows, no devuelve el almacén real. Falla con un mensaje
   claro, para que ninguna prueba, presente o futura, lo toque.
   - Si alguna prueba existente dependía de eso sin saberlo, se corrige en esta tarea y el
     informe dice cuál.
   - La app y los bancos `tool/tNN_main.dart` no corren bajo `flutter test` y no cambian.
3. **«1 bahías» en singular,** con el formateador común de T-97, en dos sitios: en
   Recientes («6 contenedores · 1 bahía») y en el editor de tapas («Copiado a 1 bahía»).
4. **La pantalla inicial deja de listar extensiones** (observación de T-89):
   - hoy dice «Seleccione un archivo .edi o .txt…» y «Formatos soportados: .edi, .txt,
     .baplie»;
   - desde T-89 cualquier archivo entra y se valida por su contenido, y el texto lo dice
     así.
5. **A 200 %, en el Honor, nada se corta:**
   - las pestañas (Bay Plan, Lista, Estadísticas, Avance);
   - la tarjeta de Lista, sin partir palabras («Contenedores», «6940.6 t»);
   - las etiquetas de la tarjeta de cada contenedor («Posición», «Destino»).
   - El mecanismo lo elige el diseño: desplazar, envolver o dos líneas.
   - Las pruebas de widget usan la escala no lineal real del Honor, la lección de T-97.

**Fuera de alcance:**
- la prueba de las 21 bahías: va en T-56, que es la siguiente que toca el perfil (10.33);
- textos o pantallas nuevas;
- cualquier cambio de reglas, nube o almacenamiento, salvo la salvaguarda del punto 2.

**Terminada cuando:**

- [ ] **El almacén real queda igual con el corpus completo:** dos corridas seguidas de los 31
      corpus, con la misma huella antes y después. La huella se toma fuera del paquete del
      agente (`AGENTS.md`). Y 116/116.
- [ ] **La salvaguarda tiene su prueba:** bajo `flutter test`, pedir el almacén real en
      Windows falla con el mensaje.
- [ ] **El Honor a 360 dp con la letra en 2.0**, que pone Carlos, en los dos temas y con A07
      y «PRUEBA T-84» abiertos:
  - las pestañas, la tarjeta de Lista y la del contenedor, sin cortes;
  - Recientes y el editor de tapas, sin «1 bahías»;
  - la pantalla inicial, sin la lista de extensiones.
- [ ] Windows y Chrome muestran las mismas pantallas sin regresiones en la barra de T-91, los
      temas de T-90 ni los textos de T-97.
- [ ] **Validaciones:** el piso de la corrección de T-94 más las nuevas, `analyze` en cero, las
      reglas sin cambio y sin dependencias nuevas.

**Añadido a T-104 (15-oct, 10.39), de la aceptación de T-92. Suma 0.5 h, y la tarea queda en 2.5 h.**

6. **Una prueba intermitente.** `test/local_vessel_repository_test.dart`, «guardar viajes
   simultáneamente también respeta cinco», falla 1 de cada 3 corridas en la suite completa
   y pasa 10 de 10 sola.
   - Usa un directorio temporal, así que no es el almacén real.
   - Lo probable es un empate en el orden de los recientes cuando ocho guardados caen en
     el mismo instante.
   - Se busca la causa y se corrige sin debilitar lo que la prueba exige. Si el defecto
     está en el repositorio, se corrige ahí.
   - **Pasa cuando** la suite completa da 5 de 5 corridas seguidas en verde.
7. **Los dos `print` con `// ignore: avoid_print`** de `bay_plan_view.dart` (líneas 343 y 348,
   desde `bb28784`, de mayo) se quitan. Son registros de depuración de la leyenda.
   - `analyze` queda en cero sin un solo `// ignore:` en `lib/`, como dice la línea base
     de `CLAUDE.md`.
   - **Pasa cuando** una búsqueda de `// ignore` en `lib/` no devuelve nada.
8. **Una frase del `LEEME` del SDK de Firebase** (`web/vendor/firebase/12.17.0/LEEME.md`).
   - Dice que la URL también se reemplazó «en comentarios». En `firebase-app.js` esas dos
     apariciones son literales de código (`name$q` y `Logger`).
   - La frase se corrige. Los módulos y su procedencia no cambian, y las pruebas de T-92
     siguen en verde.

| Tarea | Elemento | h | Qué |
|---|---|---:|---|
| **T-95** | RF-028 | 7.5 | Orden de descarga sugerido, con sobreestibas por columna y por tapa |
| **T-96** | RF-029 | 6.0 | Comparación llegada contra salida |
| **T-56** | ERS | 2.5 | Tomas de reefer por celda y por rangos (diferida del Sprint 2). Incluye la prueba de corpus que afirma las 21 bahías de A07 ∪ A08 (10.33, 10.38) |
| **T-97** | ERS | 1.0 | Título sin truncar a 360 px (RNF-003). Incluye los textos de 10.11 a 10.16: la fila del detalle que no se adapta con letra grande, «1 cargados» en singular, «(0 cub. / 0 bod.)», que debe decir que son pendientes, el punto doble al final de un rechazo y «Conectando…» en lugar de «Sin conexión» al abrir un plano en la Web · **ficha completa arriba** |
| **T-104** | ERS | 2.5 | Deudas del lote de Timonel: aislar `block3` del almacén real, «1 bahías», las extensiones de la pantalla inicial y los cortes a 200 % (10.38); la prueba intermitente, los dos `print` y el `LEEME` del SDK (10.39) · **ficha completa arriba** |

### Cierre · Calidad, entregables y piloto (21–24 oct)

| Tarea | Elemento | h | Qué |
|---|---|---:|---|
| **T-98** | TC | 26.0 | RNF primera parte sobre los binarios de cierre: 004 (con TLS y sesión), 006, 008 y 002 (SUS en el piloto), según `docs/T63-DECISIONES-RNF.md` |
| **T-99** | TC | 31.0 | RNF segunda parte: 001 y 007 (sintéticos de 5 000 y 10 000), 005 y 003 |
| **T-100** | TC | 6.0 | Manual de usuario con el anexo de geometría a mano (TC-02) y presentación final (TC-05) |
| **T-101** | PIL | 4.0 | Prueba piloto: BayStream en paralelo al papel en una escala real, con permiso de COMAR |

---

## 6. Orden de ataque — quién lleva el carril de `lib/`

| Paso | Carril de `lib/` | En paralelo, sin tocar `lib/` |
|---|---|---|
| 1 | **Timonel:** T-66 y T-67 | **Codex:** T-70, espiga fuera del repositorio |
| 2 | **Codex:** acepta T-66/T-67 y hace T-68 | **Timonel:** informe y espera; Yov transcribe el IMDG |
| 3 | **Timonel:** acepta T-68 y hace T-69 | **Codex:** cierra T-70 si quedó algo |
| 4 | Ola 2, en el orden de su tabla | El otro acepta la anterior y prepara la siguiente |

**Aceptación cruzada.** El programador que no escribió una tarea la acepta antes de tomar
el carril: carga el archivo del corpus, comprueba las cifras de la ficha y lo anota en su
propio informe. Si no cuadran, se detiene y avisa: no lo arregla de paso.

**El paso del carril lo anuncia Carlos.** Nadie empieza a tocar `lib/` hasta que Carlos
confirme que el commit anterior está hecho.

**Un segundo carril de `lib/`** con otra carpeta de trabajo (`git worktree`) haría
paralelas las olas 2 y 3, a cambio de que Carlos mezcle. Se decide al terminar la ola 1,
con lo que hayan costado los cuatro defectos.

---

## 7. Definición de Terminado

Una tarea no está hecha hasta que cumple **todo** esto:

- [ ] Satisface sus criterios en los **tres clientes** cuando toca la interfaz.
- [ ] Capas respetadas: la presentación no accede a datos; el dominio no importa Flutter,
      Hive ni Firebase.
- [ ] `flutter test` en verde con el piso vigente (282 al abrir) y `flutter analyze` en cero.
- [ ] **Verificada contra el corpus**, incluidos A07/A08 cuando aplica, con las cifras de la
      ficha. Las cifras son la aceptación.
- [ ] **Revisada en pantalla**: lo que el planificador lee —pesos, conteos, rótulos— se
      mira, no se supone. Es la lección de la prueba de campo.
- [ ] Funciona **sin conexión** cuando la historia lo exige; la operación en muelle siempre.
- [ ] Ningún dato real en el repositorio.
- [ ] Informe en `docs/<TAREA>-RESULTADOS.md` y bloque de commit para Carlos.

---

## 8. Qué NO hacer en este sprint

- ❌ Tocar `latency_test_screen.dart`, `c3_reconciliation_screen.dart` o el proyecto
  Firebase de H5.
- ❌ Publicar la Web o una versión de Play, o ejecutar `firebase deploy`. Lo hace Carlos.
- ❌ Copiar al repositorio un archivo del corpus, una foto o el listado real.
- ❌ Tocar `lib/`, `test/` o `pubspec.*` sin tener el carril (sección 6).
- ❌ Agregar dependencias fuera de las de 2.7.
- ❌ Transcribir tablas del IMDG de memoria o de una fuente distinta de la edición 42-24
  que entrega Yov.
- ❌ Arreglar de paso un defecto fuera de tu tarea. Anótalo en el informe.
- ❌ Inventar un número de contenedor para una celda reservada (T-69).
- ❌ Decidir por el usuario dónde está el buque: la escala se propone y se confirma (T-68).
- ❌ Ejecutar cualquier comando de git que no sea de lectura.

---

## 9. Cómo reportar el avance

### 9.1 · Al terminar cada tarea

Una línea:

```
T-66 hecha · container_unit.dart +18 · bay.dart +6 · A07 6 940 578 kg ✓ · 290/290
```

Si una tarea se desvía **más del doble** de su estimación, detente y repórtalo. Si algo ya
estaba implementado, repórtalo antes de tocarlo.

### 9.2 · Bloque de commit

Igual que en el Sprint 2 (`SPRINT-2.md`, 9.2): rutas explícitas, un commit por tarea o por
requerimiento, mensaje en español sin acentos, `git push` al final. **En la rama
`sprint-3`**: el bloque no cambia de rama; si Carlos está en otra, lo ve en el primer
`git log`. Tu informe va por su nombre exacto. Si cambia `pubspec.yaml` o `pubspec.lock`,
dilo en «Qué cambió».

### 9.3 · Mensaje para Yov

Al final de cada entrega, un mensaje listo para que Carlos me lo pase: tarea, commit
propuesto, cifras obtenidas contra las de la ficha y lo que quedó fuera.

---

## 10. Decisiones tomadas durante el sprint

### 10.1 · Apertura del Sprint 3 (6-oct)

- **Opción A** (5-oct): el Sprint 3 se trabaja en la rama `sprint-3` desde que cerró T-49.
  La rama principal queda congelada hasta el 17-oct.
- **Alcance completo** (5-oct): Carlos decidió meter todo y dedicar más horas. El orden de
  4.2 decide qué se corta si no alcanza. Punto de control el 14-oct.
- **Dependencias autorizadas** (5-oct): las de 2.7.
- **RNF** (6-oct): decididos por Yov por delegación de Carlos en
  `docs/T63-DECISIONES-RNF.md`; pantallas de laptop a 1920×1080 y Windows 11, con una
  prueba corta en Windows 10 si se consigue una máquina.
- **Caso real** (6-oct): anonimizado por Yov en la carpeta del corpus (T-71). Los
  originales no salen de la sesión de Yov ni de las carpetas de Carlos.
- **IMDG 42-24** (6-oct): las páginas de la edición de 2024 están fuera del repositorio,
  en `baystream-privado`. Yov transcribe las tablas para T-85.
- **Ola 1**: Timonel lleva T-66 y T-67 en el carril de `lib/`; Codex hace la espiga T-70
  fuera del repositorio. Luego el carril pasa como dice la sección 6.
- **Estimación corregida**: T-69 sube de 1.5 a 3.0 h (entidad nueva, persistencia y
  dibujo), y la espiga T-70 suma 2.0 h. El total pasa de ≈ 199.5 a ≈ 203.0 h.

### 10.2 · T-66 y T-67 entregadas, en revisión · T-70 cerrada: Firebase no está hecho para producción en Windows (6-oct, noche)

**T-66 (`86bc491`) y T-67 (`77e5880`), de Timonel, pasan a En revisión.**
- Las cinco cifras de T-66 cuadran: A07 6 940 578 kg, A05 11 210 489 kg, A08 y A08v 6 899 700 kg, A01 8 366 089 kg sin cambio. Ningún contenedor queda sin peso.
- T-67: con un límite de prueba de 90 000 kg, A08 y A08v dan las mismas 10 alertas (antes 10 y 0). También coinciden entre 50 y 80 t. El «no evaluado» se probó con fixtures sintéticos, porque el corpus no trae contenedores sin peso.
- Yov revisó el código: peso efectivo `vgmWeight ?? grossWeight`, con su fuente; `netWeight` sobre el peso efectivo; la exportación sigue con sus tres columnas crudas; el validador sigue la ficha.
- **300 pruebas** (282 + 18) y `analyze` en cero, sin dependencias nuevas. **El piso pasa a 300.**
- Revisado en pantalla en Windows y en la Web a 800 y 360 px. A 360 px el peso de Estadísticas salía cortado y se corrigió dentro de T-66.
- **Falta Android.** El Honor estaba reservado para T-70. Lo cierra Codex en la aceptación cruzada, antes de T-68. Con eso pasan a Terminado.

**Lo que Timonel anotó fuera de alcance y adónde va.**
- La cabecera de pesos por pila no marca una pila incompleta («28.7+?») → con T-77.
- `ContainerSlot.canAccept` compara `grossWeight` y nadie la llama → si T-77 la usa, con `effectiveWeight`.
- Las celdas del PDF no muestran el peso → **nace T-102** (1.0 h, ola 5): peso en las celdas del plano impreso, como en el papel.
- El rótulo «Total Contenedores» se corta a 360 px → con T-97.

**T-70 (`65ee908`), de Codex, pasa a Terminado.**
- En el emulador local, Windows, el Honor y Chrome pasaron los 9 controles: cuenta, sesión, escritura, escucha, escritura sin conexión y reconexión, con los mismos 16 documentos confirmados en cada uno.
- Versiones que resuelven junto con BayStream: `firebase_core` 4.13.0, `firebase_auth` 6.5.7 y `cloud_firestore` 6.8.0.
- Diez escrituras locales, solo orientativas (no es H5): de Windows a Chrome, mediana 24.45 ms; de Windows al Honor, 69.62 ms.
- **Windows mostró errores nativos:** Auth envía mensajes desde un hilo que no es el de la plataforma, y Firestore recibió un `too_many_pings`.
- Yov confirmó en la guía oficial de Firebase para Flutter: «Firebase on Windows is not intended for production use cases, only local development workflows».
- La cola probada era en memoria. **Que una escritura sobreviva a cerrar la app no se probó.**

**Decisión pendiente de Carlos: la oficina en Chrome.**
- **Recomendación de Codex y de Yov:**
  - la sincronización corre en Android (muelle) y en la Web (oficina, en Chrome);
  - la app de Windows sigue funcionando sin sincronizar: abre el BAPLIE, dibuja, valida y exporta;
  - la Web ya está publicada y no necesita instalador.
- **Lo que cambia:** T-93 (instalador de Windows) baja de importancia, y H4 declara la limitación de Windows con su fuente.
- Un adaptador propio para Windows (un servidor intermedio) no cabe en el sprint.

**Para T-79, desde ya.**
- Cada movimiento se guarda primero en el almacén local, con un identificador estable, y queda pendiente hasta que Firestore lo confirme.
- Se reintenta sin duplicar.
- Se prueba cerrar y reiniciar sin red, el rechazo por permisos, la sesión vencida y las escrituras concurrentes.

**Nace T-79a** (2.0 h, dentro de las 12.0 de T-79), para Timonel mientras Codex tiene el carril:
- es el diseño escrito del registro de movimientos y su sincronización, solo documentos;
- T-72 implementa la bitácora local con ese modelo y T-79 la sincroniza, así que el diseño va antes que las dos.

**Siguiente.**
- Codex: aceptación cruzada de T-66 y T-67 (con Android), luego T-68.
- Timonel: T-79a, sin tocar `lib/`, `test/` ni `pubspec.*`.
- El total sube a ≈ 204.0 h por T-102.

### 10.3 · T-79a cerrada · Carlos decide: la oficina sincroniza también en Windows, Firestore en Querétaro, cuentas desde la consola y `crypto` autorizada (7-oct)

**T-79a (`3488237`), de Timonel, pasa a Terminado.**

Yov revisó el diseño contra el código y lo acepta como base de T-72, T-79, T-80 y T-81. Lo esencial:
- **La unidad que se sincroniza es la operación** (la escala), y la publica la oficina con sus fuentes.
- **La bitácora es solo de anexar**, con nueve tipos de movimiento. Corregir reemplaza en una sola escritura.
- **El estado no se guarda: se deriva** con una función pura del dominio. Los choques entre dispositivos salen como conflictos que la oficina ve.
- **La cola vive en cajas propias de Hive**, fuera del límite de cinco viajes recientes, y el reenvío es idempotente.
- **Las reglas propuestas** pasaron 51 de 51 casos en el emulador.
- **Dos hallazgos del código que el diseño ya resuelve:**
  - el `id` de cada contenedor es un UUID nuevo en cada lectura, así que la bitácora usa claves naturales (`C:` número, `R:` posición, `T:` tapa);
  - el límite de cinco viajes podría borrar una bitácora si viviera dentro del viaje.
- **Prueba central de T-79:** los 177 eventos del caso entre dos dispositivos dejan 178 documentos (la solicitud y la aprobación del intercambio son dos) y las 460 posiciones del estado final en los dos.
- **Advertencia que se adopta:** las reglas de producción no se publican con `firebase deploy` mientras `firestore.rules` de la raíz sea el de H5. Se publican pegando la propuesta en la consola.

**Decisiones de Carlos (7-oct):**

1. **La oficina sincroniza también en la app de Windows.** No se adopta la recomendación de 10.2.
   - Firebase dice que en Windows no es para producción, y T-70 vio dos errores nativos. Por eso **Windows usa el mismo adaptador de Firestore que Android y Web**, con tres condiciones:
     - la cola propia en Hive de T-79a, que protege lo que se escribe aunque el plugin falle;
     - **una prueba de resistencia antes de construir T-79 (T-70b)**, con criterios fijados de antemano;
     - un respaldo si no pasa: la oficina usa la Web instalada desde Chrome o Edge como aplicación de Windows, con ventana e ícono propios.
   - Un cliente REST propio para Windows (cuentas y Firestore por HTTP, consultando cada pocos segundos) queda como alternativa. Cuesta unas 5 h y no se empieza sin otra decisión.
   - El adaptador sin sincronización de T-79a se conserva para el modo de un solo dispositivo.
   - **T-93 (instalador de Windows) sube de importancia:** la oficina lo necesita para la prueba piloto.
2. **Firestore en `northamerica-south1` (Querétaro).** Yov confirmó en la lista de ubicaciones de Firestore que existe. No se cambia después.
3. **Las cuentas las crea Carlos en la consola** y las autoriza por UID con su rol. La app no tiene registro abierto.
4. **`crypto` autorizada** como dependencia directa (2.7).

**Horas.**
- T-79 pasa de 12.0 a ≈ 14.0: 1.0 h que faltaba según T-79a y 1.0 h por Windows con cuentas.
- T-80 baja a ≈ 5.5 y T-81 a ≈ 2.5, como propone T-79a.
- **Nace T-70b** (1.5 h, contra las 2.0 que ahorran T-80 y T-81).
- El total sigue en ≈ 204.0 h.

**T-70b · Resistencia de Firebase en Windows · 1.5 h · Timonel, fuera del repositorio, en paralelo a T-68.**

Se prueba sobre una copia de la espiga de T-70, con el emulador.

| Criterio | Pasa si |
|---|---|
| Sesión larga | **60 min seguidos** con el listener abierto en Windows; escrituras del Honor o de Chrome cada 30 s; **0 documentos perdidos** y la app no se cae |
| Renovación del token | **50 renovaciones forzadas** del token en Windows sin caída ni error que corte la sesión |
| Cierre con pendientes | Una escritura hecha sin red, con la app cerrada a la fuerza, **llega al reabrir y reconectar**. Vale por la persistencia del SDK o por la cola en Hive del diseño; el informe dice cuál |
| Memoria | El consumo al final de la hora no crece sin límite; se informa al inicio, a los 30 y a los 60 min |

Si pasa, T-79 construye Windows con Firestore. Si no, la oficina usa la Web instalada y Carlos decide si se paga el cliente REST.

### 10.4 · T-66 y T-67 terminadas · T-68 en revisión · T-69 pasa a Codex y T-72 a Timonel (7-oct)

**T-66 y T-67 pasan a Terminado.** Codex las aceptó en el Honor a 360 dp antes de tocar código:
- A07 da 6 940 578 kg y A08v_VGM 6 899 700 kg, con el peso visible en las celdas.
- Con 90 000 kg, A08 y A08v_VGM dan las mismas 10 alertas.
- No cambió su código durante la aceptación.

**T-68 (`b2f3190`), de Codex, pasa a En revisión.**
- Las cuatro filas de la ficha cuadran en Windows, en el Honor a 360 dp y en Chrome: A07 0/114/284, A02 0/303/503, A08 121/0/284 y A01 325/0/652.
- El último puerto confirmado sobrevive al reinicio en los tres clientes, en una caja de ajustes aparte de los cinco viajes recientes.
- En el Honor se usó una variante de prueba (`gt.cmartinez.baystream.t68`), sin tocar la app que vino de Play.
- **320 pruebas** y `analyze` en cero, sin cambios en `pubspec`. **El piso pasa a 320.**
- **Revisión de Yov.**
  - `LOC+61` solo se acepta con forma de UN/LOCODE y solo en la cabecera.
  - La preselección por historial solo elige entre `LOC+5` y `LOC+61`.
  - «De paso» excluye ahora lo que se descarga en la escala.
  - Un detalle menor: el calificador `'61'` va escrito a mano en lugar de una constante de `BaplieConstants`. Se ordena cuando otra tarea toque ese archivo; no justifica abrir otra.
- **Falta la aceptación cruzada de Timonel**, después de T-70b.

**El carril de `lib/` cambia de dueño.**
- Timonel está en T-70b, fuera del repositorio. Para no detener el carril, **T-69 pasa a Codex**.
- Timonel, al terminar T-70b, acepta T-68 y T-69 juntas, y toma **T-72**: la bitácora local que él mismo diseñó en T-79a.
- La aceptación de T-68 sobre un árbol que ya incluye T-69 sigue valiendo: T-69 no cambia los conteos de contenedores.

**Aclaración para T-69: las reservas en los conteos de T-68.**
- En la escala, una reserva se cuenta por sus propios puertos, pero **aparte de los contenedores**: «Se cargan 121 contenedores y 55 reservas (176 movimientos)».
- Los 121 de la tabla de T-68 no cambian.

**Ola 2, orden del carril:**
1. T-69 (Codex).
2. T-72 (Timonel).
3. T-73 (Codex).

Después se sigue en el orden de su tabla, alternando, y cada programador acepta la tarea anterior antes de tomar el carril. El segundo carril de `lib/` (sección 6) no hace falta por ahora: mientras uno programa, el otro adelanta diseño o pruebas fuera del carril. Se vuelve a ver en el punto de control del 14-oct.

### 10.5 · T-70b no pasa: Windows no renovó la sesión contra el emulador · Carlos pide la prueba con el proyecto real (T-70c) (7-oct)

**T-70b (`71eaa14`), de Timonel, pasa a Terminado con resultado «no pasa»: 3 de 4 criterios.**

| Criterio | Resultado |
|---|---|
| Sesión larga | **Pasa:** 60.5 min, 120 de 120 escrituras de Chrome recibidas en Windows, mediana de 209 ms |
| Cierre con pendientes | **Pasa,** por la persistencia del SDK: al reabrir, la escritura llegó en 2 s |
| Memoria | **Pasa:** 90.3, 97.1 y 101.1 MB al inicio, a los 30 y a los 60 min |
| Renovación del token | **No pasa:** 50 de 50 fallos con `[firebase_auth/unknown-error] An internal error has occurred.` |

- **Qué pasó con el token.** En la hora no hubo renovación automática. Pasado el vencimiento, una escritura de Windows quedó pendiente y, al reabrir, Windows no reconectó hasta volver a iniciar sesión. Al hacerlo llegó todo: **no se perdió nada**.
- **Causa probable:** Windows manda la renovación a `securetoken.googleapis.com` y no al emulador. Chrome, con el mismo emulador, renovó 3 de 3. En producción podría funcionar; T-70b no podía probarlo.
- **Otros mensajes.** El `too_many_pings` apareció una vez, sin pérdidas. No hubo errores de hilo de Auth en la compilación de lanzamiento.
- **Hallazgo para todos los clientes:** cuando el token no se renueva, el SDK no avisa a la app.

**Falta de proceso.**
- Timonel ejecutó `git status --porcelain` por descuido, y lo declaró.
- Yov comprobó que no quedó `.git/index.lock`.
- La regla de `.claude/settings.json` (`Bash(git status:*)`) no lo detuvo; es probable que entrara por otra herramienta o con otra forma del comando.
- La prohibición sigue igual: la configuración no es la frontera, la regla sí (`CLAUDE.md`).

**Decisión de Carlos: probar con el proyecto real antes de decidir Windows → nace T-70c.**
- **Qué es:** 1.0 h, de Codex, después de T-69 y fuera del repositorio.
- **Pasos previos de Carlos** en la consola de `baystream-app`, que T-79 necesita de todos modos:
  - activar **Correo electrónico/contraseña** (T-79a, 6.2);
  - crear **una cuenta de prueba**.
  - No hace falta crear Firestore para esta prueba.
- **La contraseña la escribe Carlos** en la app de la espiga. Ningún agente la ve, la escribe ni la guarda.
- **Las opciones de producción** se pasan con `--dart-define-from-file` y la ruta del archivo privado, como en T-47: sin abrirlo ni imprimir su contenido.
- **Pasa si:**
  - **50 de 50 renovaciones forzadas** salen bien contra el servicio real;
  - una sesión de **75 minutos** cruza el vencimiento con la renovación automática y sin error.
- **Si pasa:** Windows sincroniza con Firestore en T-79, con la salvaguarda de abajo. Las pruebas largas de Windows en T-79 necesitarán la nube, porque el emulador no sirve para sesiones de más de una hora.
- **Si no pasa:** la oficina usa la Web instalada, como dice 10.3.

**Nuevo requisito de T-79, en los tres clientes.**
- Si un movimiento lleva más de **5 minutos** pendiente con red disponible (umbral **PROVISIONAL**), la pantalla dice «sin confirmar desde las HH:MM» y ofrece volver a iniciar sesión.
- La app no se fía solo de los errores del SDK.

**Siguiente.**
1. Termina T-70b: Flutter, la app de Windows y el Honor quedan libres. Codex cierra T-69.
2. Con T-69 en un commit, Timonel acepta T-68 y T-69 y toma **T-72**.
3. Codex hace T-70c en cuanto Carlos haga los pasos de consola.

T-70c suma 1.0 h: el total queda en ≈ 205.0 h y 40 tareas.

### 10.6 · T-69 entregada, en revisión (7-oct)

**T-69 (`8a87219`), de Codex, pasa a En revisión.**

- **Cifras de la ficha.** A08 y A08v_VGM dan **405 contenedores y 55 reservas**, y de A01 a A07 hay cero reservas. Comprobado en Windows, en el Honor a 360 dp y en Chrome.
- **Resumen de la escala.** Con GTSTC dice «Se cargan 121 contenedores y 55 reservas (176 movimientos)». Los conteos de T-68 no cambian.
- **Lo que no hacen las reservas.** No suman peso ni ocupación.
- **Revisión de Yov.**
  - `ReservedSlot` es una entidad de dominio aparte, sin número inventado.
  - Su identidad es `R:` más la posición, como fijó T-79a.
  - Guarda tipo, estado, puertos, línea, peso nominal, reefer y peligrosas.
- **Pruebas.** **360 pruebas** y 31 de 31 contra el corpus, con `analyze` limpio y las tres compilaciones correctas. **El piso pasa a 360.**
- **Lo que quedó pendiente.** No se pudo volver a abrir el detalle de una reserva después de recargar Chrome: la herramienta de control del navegador detuvo la acción porque no pudo confirmar la URL. Las 55 reservas sí se recuperaron. Esa comprobación pasa a la aceptación cruzada de Timonel.

### 10.7 · T-68 y T-69 terminadas · T-72 entregada · T-73 pasa a Timonel (7-oct)

**T-68 y T-69 pasan a Terminado.** Timonel las aceptó en Windows, en el Honor a 360 dp (variante `.t72`) y en Chrome.
- T-68: las cuatro filas cuadran. GTSTC sale preseleccionado después de A08, y HNPCR como control cuando el último puerto era GTPBR.
- T-69: 405 contenedores y 55 reservas en A08 y A08v, y cero de A01 a A07. El resumen dice «121 contenedores y 55 reservas (176 movimientos)».
- **Se cerró lo pendiente de 10.6:** en Chrome, el detalle completo de una reserva sigue ahí después de recargar.

**T-72, de Timonel, pasa a En revisión** (commit propuesto: «Sprint 3: T-72 bitacora local de movimientos y estado derivado, con la aceptacion de T-68 y T-69»).
- **Lo construido.**
  - Bitácora local solo de anexar en tres cajas de Hive.
  - Plan combinado con claves `C:` y `R:`.
  - Estado derivado que no depende del orden de llegada: descarga, carga, vacío, cancelar, anular y corregir, con seis tipos de conflicto.
  - Exportación de la bitácora en JSON.
- **El caso real.** Los 176 eventos, sin el intercambio, dan las 460 posiciones de `CASO_A08_ESTADO_FINAL.csv`. Solo 014-01-02 y 014-01-08 salen «fuera de plan», a la espera de T-80. Cuadran los nueve conteos por bahía (82 en cubierta y 94 en bodega).
- **Revisión de Yov.** El bloque de commit incluye todo lo nuevo y lo modificado, y `main.dart` no se tocó. `Operation` guarda sus fuentes, con `exportList` lista para T-73.
- **Validaciones.** **383 pruebas**, `analyze` en cero, 22 de 22 contra el corpus y sin dependencias nuevas. **El piso pasa a 383.**
- **Horas.** ≈ 4.0 en lugar de 3.0, sin contar la aceptación. El total sube a ≈ 206 h.
- **Incidencias que declaró Timonel.**
  - Cerró con `/IM` dos instancias de BayStream, casi seguro abiertas por su propia herramienta.
  - `flutter test --platform chrome` se colgó y lo reemplazó por la comprobación en Chrome.
  - **El límite de prueba de 90 000 kg de T-66 quedó en el perfil BUQUE GOLF** del Windows de Carlos. **Timonel lo quita** desde «Perfiles guardados» al empezar la aceptación de T-73 en Windows. Carlos no pudo hacerlo a mano: la compilación de depuración que abrió no traía el archivo de opciones y se quedó en «Falta la configuración de Firebase», como corresponde desde T-47. Esa aceptación dejó además perfiles y viajes recientes del corpus (BUQUE ALFA a ECO), que pueden quedarse.
- **Falta la aceptación cruzada de Codex**, después de T-70c.

**El carril de `lib/` sigue con Timonel y T-73 pasa a él.** El plan de 10.4 era que T-73 fuera de Codex, pero Codex está en T-70c. Para no detener el carril, Timonel toma T-73, con la ficha completa en la sección 5. Codex, al terminar T-70c, acepta T-72 y T-73 juntas y toma **T-74**.

**Pasos de consola que ya hizo Carlos** (no quedaron en 10.6). Activó correo y contraseña en `baystream-app` y creó una cuenta de prueba, que luego servirá como usuario de oficina. Firestore todavía no está creado.

**Timonel abre un chat nuevo**, porque el anterior llegó a su límite de contexto. Su primer mensaje lo pone al día con este archivo.

### 10.8 · T-70c pasa: la oficina sincroniza en la app de Windows · T-73 pasa en el Honor (7-oct)

**T-70c, de Codex, pasa a Terminado.** El commit propuesto es «Sprint 3: T-70c renovacion de sesion Windows validada contra Auth real», y su único archivo es `docs/T70c-RESULTADOS.md`.
- **Dónde se probó.** Contra Auth real de `baystream-app`, en Windows release, con `firebase_core` 4.13.0 y `firebase_auth` 6.5.7.
- **Los dos criterios de 10.5 pasan.**
  - 50 de 50 renovaciones forzadas, sin error.
  - Una sesión de 75 min 2 s. La renovación automática llegó a las 13:43:12, dos minutos antes del vencimiento de las 13:45:11.
  - Cero errores en las dos.
- **Cómo se hizo.** Carlos escribió la contraseña. No se tocó Firestore ni H5. La espiga y su evidencia quedan fuera del repo.
- **Revisión de Yov.** El informe no trae correo, UID, tokens ni opciones privadas.
- **Lo que no prueba.**
  - No prueba Firestore en Windows.
  - No anula la advertencia de Firebase de que Windows no es para producción.
  - El fallo de T-70b contra el emulador no se repitió contra la nube, pero su causa no quedó demostrada.

**Decisión: la oficina sincroniza en la app de Windows**, como Carlos fijó en 10.3 y 10.5 para el caso de que T-70c pasara. T-79 construye Windows con el adaptador previsto, y conserva:
- la cola local durable de T-79a;
- la salvaguarda en los tres clientes. Si un movimiento lleva más de 5 minutos pendiente con red, se muestra «sin confirmar desde las HH:MM» y se ofrece volver a iniciar sesión. El umbral sigue PROVISIONAL;
- las pruebas largas de Windows contra la nube, no contra el emulador.

**Respaldo y riesgo.**
- Si Firestore falla en Windows durante T-79, la oficina usa la Web instalada desde Chrome o Edge.
- El documento del 24-oct declara como riesgo que Firebase no da Windows por plataforma de producción.

**T-73 avanza.**
- **Carlos autorizó `archive`** como dependencia directa (2.7). `excel_community` no resuelve las rutas absolutas de `workbook.xml.rels`, como las que escribe openpyxl.
- **Formas de Excel cubiertas.** Un segundo fixture tiene la forma de un archivo guardado desde Excel: `sharedStrings`, números double y el neto con valor en caché. `LISTADO_A08.xlsx` no se tocó.
- **El Honor a 360 dp pasa** (variante `.t73`), con todas las cifras de la ficha:
  - 4 agencias de 40, 18, 27 y 91 filas;
  - 40RF → 45R1 pedida;
  - el OR 127 con su aviso;
  - el OR 130 con 7 266.59 kg de VGM y 3 366.59 kg de neto;
  - las equivalencias guardadas, que ya no se piden en una segunda importación.
- **Faltan:**
  - repetir `analyze` y la suite, porque cambiaron tres textos después de la corrida de 405 de 405;
  - Windows, empezando por quitar el límite de 90 000 kg;
  - Chrome.

**Codex espera.** Cuando Timonel entregue T-73, Codex abre un **chat nuevo**, porque el actual viene desde T-70. Ahí hace la aceptación cruzada de T-72 y T-73, y luego T-74.

### 10.9 · T-73 entregada y commiteada, en revisión · T-74 pasa a Codex con ficha completa (7-oct)

**T-73, de Timonel, pasa a En revisión.** El commit es `04ecbab`, «Sprint 3: T-73 importar el listado de la agencia con equivalencias, peligrosas y cruce con el plan».
- **Las cifras de la ficha cuadran.** Pasan en los tres clientes, con la persistencia probada en cada uno:
  - en **Windows**, sobre el almacén real;
  - en el **Honor** a 360 dp, con la variante `.t73`;
  - en **Chrome**, en un origen local nuevo.
- **Antes, en Windows, Timonel quitó el límite de prueba de 90 000 kg** de BUQUE GOLF. Después de reiniciar, sigue sin límite.
- **Validaciones.** **405 pruebas** (el piso nuevo), `analyze` en cero, el corpus de T-73 en 2 de 2 y el de T-68, T-69 y T-72 en 22 de 22.
- **Dependencias.** `excel_community 1.0.10` y `archive 4.0.9` directas, las dos con versión fija. En el lock solo cambian esas dos entradas.
- **Revisión de Yov sobre el commit.** Toca 23 archivos y ninguno es `main.dart` ni los congelados de H5. Los únicos números de contenedor son de prueba (TSTU) o del corpus anonimizado (XQ). Los fixtures son sintéticos.
- **La identidad de la operación** queda en `docs/T73-RESULTADOS.md`, 3.4: buque, viaje y escala. Cuadra con T-79a, donde el `operationId` es un UUID v4 que crea quien publica.
- **Horas.** ≈ 6.0 en lugar de 4.5, sin medir con precisión. El total sube a ≈ 207.5 h.
- **Detalles menores, para T-77, T-78 o si sobra tiempo:**
  - la lista de 176 filas se pliega cuando sale de la vista;
  - en Android, esas filas forman un solo nodo de accesibilidad.

**Regla nueva en `AGENTS.md`.** La app de Windows se abre con `Start-Process explorer.exe -ArgumentList <exe>`, no con `Start-Process <exe>`.
- Lanzada desde el PowerShell de un agente empaquetado, la app usa el almacén redirigido del paquete y no el real.
- A Timonel le pasó en esta aceptación. Lo corrigió cerrando por PID.

**El carril de `lib/` pasa a Codex**, en un chat nuevo:
1. Primero, la aceptación cruzada de T-72 y T-73 (sección 6).
2. Después, T-74 con su ficha completa de la sección 5. La ficha agrega guardar los BAPLIE como fuentes de la operación, en la misma operación.
- Timonel queda en pausa. Cuando Codex entregue T-74, Timonel la acepta y toma T-75, también en un chat nuevo.

**El segundo carril** (`git worktree`, sección 6) **no se abre por ahora.** Duplicaría el gasto de tokens de Carlos y lo obligaría a mezclar. Se vuelve a evaluar al terminar T-76, contra el punto de control del 14-oct.

### 10.10 · T-72 y T-73 terminadas · T-74 entregada, en revisión · T-75 pasa a Timonel (7-oct)

**T-72 y T-73 pasan a Terminado.** Codex las aceptó en Windows, en el Honor y en Chrome (`docs/T74-RESULTADOS.md`, sección 2), en 0.45 h.

**T-74, de Codex, pasa a En revisión** (commit `23525ae`).
- **Las fuentes.** A07, A08 y el listado quedan en una sola operación con tres fuentes. Volver a leer A08v solo reemplaza `loading_baplie`, y se conservan el id, la fecha y la bitácora.
- **El tipo de la fuente** sale de los conteos de T-68. Si es ambiguo, se pregunta: «Llegada» o «Carga».
- **El modo «Número de orden»** muestra los 121 OR, incluido el OR 85, y las 55 reservas con su grupo. No queda ninguna celda de carga sin cruce.
- **Los pendientes por bahía** reproducen la tabla de la sección 2 del caso en los tres clientes (82/94, 120/56). Bajan de 176 a 0 al aplicar la bitácora.
  - Lleno o vacío se decide por el listado, y el OR 85 cuenta como vacío.
  - 014-01-02 y 014-01-08 siguen en conflicto «fuera de plan» hasta T-80, sin carga pendiente.
- **Validaciones.** **412 pruebas** (el piso nuevo), `analyze` en cero y los corpus en 26 de 26.
- **Horas registradas.** 0.86 en lugar de 3.0. El total baja a ≈ 205.4 h.
- **Revisión de Yov.**
  - El commit no toca `main.dart` ni los congelados, y solo trae contenedores de prueba.
  - El banco de aceptación (`lib/t74_client_acceptance.dart`) quedó en la copia privada, fuera del repo.
  - **Tres pruebas existentes cambiaron** (perfiles, viajes recientes y escala). Ahora usan un repositorio en memoria, para no abrir el almacén real durante la suite, y la de borrar un viaje espera al proveedor. **Timonel confirma en su aceptación que ninguna perdió lo que comprobaba.**
- **Incidencia que declaró Codex.** En su primera corrida, los scripts de corpus de T-72 y T-73 crearon almacenes temporales con contenido del corpus en el `build/` del repo. Los propios scripts los borraron, `build/` está fuera de Git y Codex repitió la corrida fuera del repo. **La causa se corrige en T-75**: los scripts pasan al directorio temporal del sistema.

**El carril de `lib/` pasa a Timonel**, en un chat nuevo:
1. Primero, la aceptación cruzada de T-74.
2. Después, T-75 con su ficha completa de la sección 5.
- Codex queda en pausa. Cuando Timonel entregue T-75, Codex la acepta y toma T-76.

### 10.11 · T-74 terminada · T-75 entregada, en revisión · T-76 pasa a Codex (7-oct)

**T-74 pasa a Terminado.** Timonel la aceptó en Windows, en el Honor y en Chrome, en 0.32 h: una operación con tres fuentes, los 121 OR, las 55 reservas con su grupo, la tabla de 9 bahías y los pendientes de 176 a 0.
- **Las tres pruebas existentes que cambió Codex** no pierden nada. La de viajes recientes quedó más estricta.
- **Una observación, que no es defecto.** La fuente `export_list` mide 51 775 caracteres en la Web y 52 547 en Windows y Android, porque la Web escribe `3900` donde las otras escriben `3900.0`. El contenido es el mismo.
- **Nota para T-79:** la huella SHA-256 de las fuentes se calcula sobre el texto publicado tal cual. Ningún dispositivo vuelve a serializar la fuente antes de comprobarla.

**T-75, de Timonel, pasa a En revisión** (commit `4bfa268`).
- **Las cifras.** A07 en GTSTC da 114 pendientes (66/48), con el conteo por bahía de la ficha.
- **En los tres clientes pasan** una bahía completa, el «Deshacer» inmediato y desde el detalle, la re-estiba aparte y la reapertura. El tema claro se vio en Chrome y el oscuro en Windows y en el Honor.
- **El corpus** marca los 114 (quedan 0), los anula (vuelven a 114, con 228 movimientos) y registra una re-estiba (229 movimientos).
- **Validaciones.** **420 pruebas** (el piso nuevo), `analyze` en cero, los corpus en 28 de 28 y sin dependencias.
- **Horas.** 0.46 en lugar de 4.0. El total baja a ≈ 201.9 h.
- **La deuda de 10.10 queda pagada.** Los scripts de corpus de T-72 y T-73 usan ahora el directorio temporal del sistema.
- **Decisiones de Timonel, aceptadas.**
  - El autor es «Muelle (sin cuenta)» hasta T-79.
  - La descarga se deriva sobre el plan combinado.
  - La vista de carga de T-74 deja fuera las descargas, para no contarlas como conflictos.
- **Para T-97:** la fila del detalle no se adapta si el texto no cabe, por ejemplo con letra del sistema muy grande.

**El almacén real de Windows ya tiene movimientos de prueba.**
- **Lo que hay.** La operación de BUQUE GOLF guarda las 176 cargas de la aceptación de Codex y 7 movimientos de T-75. Además existe el namespace `t75acc`.
- **No se pueden borrar desde la app**, porque la bitácora es solo de anexar.
- **Regla nueva en `AGENTS.md`:** toda aceptación que registre movimientos en Windows usa un namespace propio del almacén real (`tNNacc`), como hizo Timonel.
- **Antes de la prueba piloto (T-101)**, el almacén de Carlos tiene que quedar limpio. Cómo se hace se decide con T-78 o T-79.

**T-76 trae una regla nueva para el derivador.**
- **El problema.** 54 de las 176 celdas de carga de A08 son celdas que A07 descarga. Una carga registrada antes que la descarga de su celda sale «celda ocupada».
- **La regla.** La descarga vigente del ocupante de llegada libera la celda, aunque se haya registrado después de la carga. Así el estado no depende del orden de registro, como exige T-79a.
- **Si falta la descarga**, sigue el conflicto, y T-77 ofrecerá registrarla.
- La ficha completa está en la sección 5.

**El carril de `lib/` pasa a Codex**, en un chat nuevo:
1. Primero, la aceptación cruzada de T-75.
2. Después, T-76.
- Timonel queda en pausa. Cuando Codex entregue T-76, Timonel la acepta y toma T-77.

**Corrección a la ficha de T-76.** Codex señaló que la ficha decía «corregir es anular y registrar de nuevo», y eso contradice T-79a 2.5 y el código de T-72. Queda así: **corregir usa `payload.corrects`, en una sola escritura, y deshacer usa `annul`**.

### 10.12 · T-75 terminada · T-76 aceptada en Windows; el Honor y Chrome pasan a la aceptación de Timonel · T-77 a Timonel (8-oct)

**T-75 pasa a Terminado.** Codex la aceptó en los tres clientes (`docs/T76-RESULTADOS.md`, sección 1):
- 114 pendientes (66/48), con el conteo por bahía de la ficha;
- en el corpus, 114 a 0, de vuelta a 114 con 228 movimientos, y 229 con la re-estiba;
- 420 pruebas y `analyze` en cero.
- La aceptación tomó ≈ 0.40 h.

**T-76, de Codex, queda En revisión** (commit `21d73ab`, que Carlos ya subió). El commit no lleva el prefijo «Sprint 3:» de los demás; no se reescribe.
- **El corpus.** Con A08 y A08v pasan cuatro escenarios: solo cargas, cargas antes de las descargas, descargas antes y todo intercalado.
  - En todos dan las 460 posiciones del CSV, cero «celda ocupada» y cero pendientes.
  - El OR 12 queda en `R:0030984` con 2 185 kg.
  - Quedan los 2 «fuera de plan» del intercambio.
- **Validaciones.** **437 pruebas** (el piso nuevo), `analyze` en cero y los corpus en 36 de 36.
- **Windows, aceptado** en el namespace `t76acc`, con 14 movimientos después de reabrir:
  - búsqueda por OR y por sufijo del contenedor;
  - hora y marchamo;
  - deshacer inmediato y desde el detalle;
  - corrección con `corrects`;
  - el OR 12 con sus cinco reservas libres, primero las de la bahía que se ve.
- **El Honor quedó a medias. Chrome, sin hacer.**
  - En el Honor apareció de pronto la pantalla de «Opciones del desarrollador». Codex detuvo los toques.
  - En Chrome, la herramienta de pantalla de Codex se negó a seguir porque no pudo confirmar la URL. Codex no intentó saltarse el bloqueo.
  - Además, Codex se quedó dos veces sin créditos.
- **Horas.** ≈ 0.73 de trabajo activo en lugar de 5.0. El total baja a ≈ 197.6 h.

**Dos reglas del derivador cambian con T-76.**
1. **La descarga libera la celda en cualquier orden** (10.11). Si falta la descarga, sigue la «celda ocupada». Dos cargas en la misma celda siguen en conflicto.
2. **Una corrección sustituye toda su cadena.** Carlos la autorizó durante T-76.
   - Con la regla de T-79a 2.5, corregir A→B→C podía revivir A.
   - Ahora C queda vigente, anular C restaura B y anular esa anulación restaura C.
   - Se anotó en `docs/T79a-DISENO.md`, 2.5.

**Incidencia que declaró Codex.** Una salida del corpus de T-72, con identificadores anonimizados, cayó en `build/t76/` del repo. Codex la movió de inmediato al directorio temporal del sistema. `build/` está fuera de Git.

**Decisión: la aceptación de Timonel completa el Honor y Chrome.** Timonel hace la aceptación cruzada de T-76 en un chat nuevo. Además de comprobar lo de Windows, hace completos en el Honor y en Chrome los recorridos que faltan:
- opcionales, corrección y deshacer desde el detalle;
- el OR 12;
- la reapertura.

En Chrome usa su método de T-75: un Chrome propio con perfil aparte, servido en local y con la ventana visible. Así no se gasta otra sesión de Codex y el carril no se detiene.
- **Si todo cuadra, T-76 pasa a Terminado**, con la aceptación en los tres clientes repartida entre los dos programadores.
- **Si algo no cuadra**, Timonel se detiene y avisa. Codex lo arregla.

**Después, Timonel toma T-77** (ficha completa en la sección 5). Codex queda en pausa hasta aceptar T-77 y tomar T-78.

### 10.13 · T-76 terminada · T-77 entregada, en revisión · T-78 pasa a Codex (8-oct)

**T-76 pasa a Terminado.** Timonel completó lo que faltaba (`docs/T77-RESULTADOS.md`).
- **Pasa en los tres clientes:**
  - en Windows, en el namespace `t77acc`;
  - en el Honor a 360 dp, con la variante `.t77`;
  - en Chrome, en una ventana propia y visible.
- **Lo que comprobó:**
  - búsqueda por OR y por sufijo;
  - hora y marchamo;
  - deshacer inmediato y desde el detalle;
  - corregir con `corrects`;
  - el OR 12 en `R:0030984` con 2 185 kg, ofreciendo solo las 9 reservas libres de su grupo;
  - la reapertura.
- **Revisó en el código las dos reglas nuevas del derivador**, y cuadran.
- La aceptación tomó ≈ 0.63 h.

**T-77, de Timonel, pasa a En revisión** (commit `01721dd`).
- **Ningún falso aviso.** Los 176 eventos del caso dan exactamente 2 avisos, el OR 128 y el OR 145.
- **Celda ocupada.** Las 54 celdas ofrecen «Marcar su descarga y cargar».
- **Grupo.** El OR 12 en otro grupo solo entra con motivo, y queda en conflicto «vacío de otro grupo».
- **20/40.** Un 40 pies en una posición de 20 queda bloqueado.
- **Peso.** Con un límite de prueba de 90 t, la pila 014, bodega, fila 01 avisa con 90.9 y con 121.2 t. Sin límite, «no evaluado».
- **Validaciones.** **449 pruebas** (el piso nuevo), `analyze` en cero, los corpus en 42 de 42 y sin dependencias.
- **Horas.** ≈ 0.53 en lugar de 3.0. El total baja a ≈ 195.1 h.

**Decisiones de Yov sobre lo que Timonel dejó para decidir.**
1. **El peso de pila sobre el límite no es un conflicto de la bitácora.** T-79a no lo pone en su tabla, y está bien así: el conflicto es de un movimiento, y el peso es de una pila. T-78 lo evalúa sobre el estado derivado, así que la oficina ve las pilas pasadas de peso sin importar qué dispositivo cargó.
2. **Las bahías que existen se deducen de los dos planes.** Se acepta como supuesto. Se revisa en T-83, cuando el perfil declare las bahías con sus tapas.
3. **El rótulo «Deshacer carga» después de una corrección** pasa a «Deshacer corrección», en T-78.
4. **La cabecera «28.7+?» de 10.2** no se metió en la ficha de T-77. Fue un descuido de Yov. Pasa a T-102, junto con el peso en el PDF.

**Incidencias, sin daño.**
- **La copia privada del corpus.** El clasificador de permisos no dejó copiar el corpus a `baystream-privado`, así que la copia privada quedó en el temporal del sistema. Nada entró al repo.
- **Una segunda instancia de Windows.** La herramienta de pantalla abrió otra instancia y Timonel la cerró por PID.
- **El Honor seguía en «Opciones del desarrollador»** desde la sesión de Codex. Timonel no tocó esos ajustes.

**El almacén limpio para la prueba piloto (pendiente de 10.11).** Se resuelve sin código:
- antes del piloto, Carlos cierra la app y renombra la carpeta `%LOCALAPPDATA%\BayStream` a `BayStream-pruebas`;
- la app crea un almacén nuevo;
- los perfiles de buque se vuelven a cargar desde el archivo.
- En el Honor, la app de Play nunca se usó para pruebas: sus variantes `.t68` a `.t77` son apps aparte.

**El carril de `lib/` pasa a Codex.**
1. Primero, la aceptación cruzada de T-77.
2. Después, T-78 con su ficha completa de la sección 5. Con ella **termina la Ola 2**, cinco días antes de lo previsto (13-oct).
- Timonel queda en pausa.
- **Después viene T-79**, la sincronización. Antes, Carlos crea Firestore en `baystream-app`.

### 10.14 · T-77 terminada · T-78 entregada: la Ola 2 queda completa en código · T-79 pasa a Timonel (9-oct)

**T-77 pasa a Terminado.** Codex la aceptó en Windows, en el Honor y en Chrome (`docs/T78-RESULTADOS.md`, sección 1), en ≈ 0.50 h:
- exactamente dos avisos;
- el par descarga y carga;
- motivo para un vacío de otro grupo;
- el bloqueo 20/40;
- el límite de prueba de la pila;
- los corpus en 42 de 42.

**T-78, de Codex, pasa a En revisión** (commit `1880266`).
- **Una pantalla «Avance de la operación»** con el total y una fila por bahía, agrupadas como el plano. Muestra:
  - descarga, con las re-estibas aparte;
  - llenos y vacíos;
  - cancelados y conflictos, con enlace a la celda;
  - el último movimiento.
- **Sale del estado derivado**, sin contadores paralelos.
- **Las pilas sobre su límite** van aparte de los conflictos (10.13).
- **El rótulo «Deshacer corrección».**
- **El corpus compara los 290 prefijos** del caso en 6 corridas, 1 740 pasos, contra un conteo independiente que no usa el derivador. Al final: 114, 120 y 56 hechos, cero pendientes y los 2 conflictos.
- **Validaciones.** **459 pruebas** (el piso nuevo), `analyze` en cero y los corpus en 48 de 48.
- **Horas.** ≈ 0.58 en lugar de 3.0. El total baja a ≈ 192.7 h.
- **Revisión de Yov sobre la captura de Windows.**
  - Los números de cada bahía cuadran con la tabla del caso y con A07.
  - Dos textos menores pasan a T-97: «1 cargados» en singular, y «(0 cub. / 0 bod.)», que no dice que son pendientes.

**La Ola 2 queda completa en código el 8-oct**, cinco días antes de lo previsto. Se cierra cuando Timonel acepte T-78. Lo que tiene:
- la descarga, la carga desde el listado y la validación;
- el avance para la oficina;
- todo en un dispositivo, con bitácora y deshacer.

Ese es el respaldo del punto de control del 14-oct.

**La Ola 3 se abre con T-79, de Timonel, en un chat nuevo**, con la ficha completa en la sección 5.
1. Primero, la aceptación cruzada de T-78.
2. Después, T-79, sobre el diseño de T-79a, con cuatro cambios decididos después:
   - Windows sincroniza (10.8);
   - la salvaguarda de 5 minutos;
   - la huella sobre el texto publicado;
   - sin cuenta, el modo de un solo dispositivo sigue.
- **Las horas.** Las 12.0 de T-79 incluían las 2.0 de T-79a, así que la ficha cuenta 10.0.
- **`lib/main.dart`.** La ficha lo autoriza solo para montar la sesión, y cada cambio se declara.
- **Codex queda en pausa.** Después toma T-80, los roles y el intercambio 128 ↔ 145, que necesita la sincronización.

**Lo que hace Carlos para T-79**, en la consola de `baystream-app` (T-79a, sección 6). Antes de cada paso, comprueba en el selector que el proyecto es `baystream-app`, nunca el de H5.
- **6.1, Firestore:** edición Standard, `(default)`, `northamerica-south1` y modo de producción, si todavía no la creó.
- **6.3, las cuentas:** dos, una de oficina y una de muelle, y un documento en `authorized/{uid}` por cuenta. Los correos y los UID nunca entran al repo.
- **6.4, las reglas:** se publican desde la consola cuando Timonel las entregue probadas. Nunca con `firebase deploy`.

### 10.15 · T-78 terminada: la Ola 2 queda cerrada · T-79 pasa contra el emulador; falta producción (9-oct)

**T-78 pasa a Terminado y la Ola 2 queda cerrada.** Timonel la aceptó en ≈ 0.32 h:
- en Windows a 1920×1080, en el namespace `t79acc`;
- en el Honor a 360 dp, con la variante `.t79`;
- en Chrome.

Lo que comprobó:
- **Al empezar:** 114 por descargar (66/48) y 176 por cargar (120/56), con cero hechos.
- **Al final:** 0 pendientes y 2 conflictos.
- **Lo demás:** las 11 pilas sobre el límite de prueba van aparte, y aparece «Deshacer corrección».
- **Corpus y suite:** 48 de 48 y 459 de 459.

**T-79, de Timonel, queda En curso:** la parte del emulador está hecha y commiteada (`f959024`), y falta producción.
- **Construido según T-79a**, con los cambios de esta ficha:
  - sesión con `authorized/{uid}`;
  - publicar, unirse y cerrar, con la huella SHA-256;
  - el motor de la cola en Dart puro;
  - el estado en pantalla con texto e icono, incluida la salvaguarda de 5 minutos;
  - la pantalla «Nube y cuenta»;
  - Windows con los adaptadores de Firestore.
- **`lib/main.dart` no se tocó.** El archivo de reglas no cambió.
- **Dependencias:** `firebase_auth 6.5.7` (la de T-70 y T-70c) y `crypto 3.0.7`, las dos ya autorizadas y con versión fija.
- **Validaciones:**
  - **485 pruebas**, el piso nuevo: 459 y 26 nuevas;
  - `analyze` en cero;
  - las reglas en el emulador, 54 de 54: los 51 de T-79a y 3 nuevos;
  - los corpus, 50 de 50.
- **Dos dispositivos contra el emulador:**
  - **C1:** el Honor dibuja 405 contenedores y 55 reservas sin tener el archivo.
  - **C2:** con un corte de red real y un cierre forzado, quedan 178 documentos con 178 ids distintos y las 460 posiciones en el Honor y en Windows.
  - **C5 a C7 pasan.** C4 pasa en su primera parte.
  - **C8:** Windows como oficina publica, ve el avance del Honor en tiempo real y cierra la operación, sin errores de hilo en su salida.
- **La corrección que salió de C7.** El cierre y la autorización se leían de la caché del SDK. Ahora se leen del servidor, y sin red el movimiento sigue pendiente.
- **Horas.** ≈ 1.5 en lugar de 10.0, sin C9 ni C10. Con ≈ 0.5 h estimadas para ellas, el total baja a ≈ 184.7 h.

**Tres puntos abiertos y lo que se decide.**
1. **Las denegaciones agotan el máximo de 1 000 expresiones** del motor de reglas.
   - El resultado es el correcto, «denegado», y ninguna escritura válida se negó: entraron 13 en la batería y 182 del SDK real.
   - **Decisión: Carlos publica las reglas tal como están.** El emulador aplica el mismo límite y las escrituras válidas pasaron.
   - **En T-80**, que de todos modos agrega casos a las reglas, se parte `validPayload` por tipo de movimiento, para que una denegación corte pronto. La batería sirve de red.
2. **Windows se quedó «Sin conexión» más de dos minutos** después de vaciar el emulador, sin ningún error.
   - Puede ser la caché del SDK frente a un emulador vaciado, algo que en producción no pasa.
   - **C9 lo comprueba de verdad:** se corta la red de Windows un minuto, se devuelve, y Windows tiene que volver a «Al día» en menos de un minuto.
   - **Si no vuelve, T-79 no se cierra hasta corregirlo.**
3. **C4 con dos pestañas** no se pudo probar en la Web contra el emulador, por el orden de arranque de Auth. Pasa a C9, en Chrome compilado en local contra `baystream-app`. Nada se publica en la Web antes del 17-oct.

**Revisión de Yov sobre el commit `f959024`.**
- No toca `main.dart`, las reglas ni los congelados.
- No trae claves, correos ni opciones privadas.
- Los contenedores son de prueba (TSTU) o del corpus anonimizado.
- Las reglas propuestas niegan todo lo que no está listado (`match /{document=**}` en `false`).

**Lo que sigue.**
1. **Carlos**, en la consola de `baystream-app` (T-79a, sección 6):
   - crear Firestore, si no lo hizo;
   - crear la cuenta de muelle y los dos documentos `authorized/{uid}`;
   - publicar las reglas desde la pestaña Reglas y comprobarlas en el simulador.
2. **Timonel hace C9 y C10.** Con eso, T-79 pasa a En revisión.
3. **Codex** acepta T-79 y toma T-80, con su ficha completa, que Yov escribe al cerrar C9.

### 10.16 · T-79 pasa en producción y queda En revisión · T-80 pasa a Codex (9-oct)

**Los pasos de consola de Carlos quedaron hechos el 9-oct**, en `baystream-app`, con Yov guiándolos con capturas:
- Firestore en `northamerica-south1`, en edición Standard y modo de producción.
- Dos cuentas, una de oficina y una de muelle, cada una con su `authorized/{uid}`.
- Las reglas de `docs/T79a-firestore.rules.propuesta`, publicadas sin cambios desde la consola.
- **El simulador comprueba las reglas:**
  - un `get` sin sesión sale denegado;
  - con el UID de la oficina sale autorizado, y lo mismo con el de muelle;
  - el detalle confirma que la regla lee `authorized` y que `active` es `true`.

**T-79, de Timonel, pasa a En revisión** (commit `f098e58`, `docs/T79-RESULTADOS.md`, sección 7).
- **C9 pasa.** Participaron cuatro clientes:
  - la oficina en Windows, con el almacén real y el namespace `t79prod`;
  - el muelle en el Honor, con la variante `.t79`;
  - dos pestañas de Chrome compiladas en local. Nada se publicó.
- **La operación «PRUEBA T-79»** tiene 20 movimientos con 20 ids distintos, todos confirmados en los cuatro clientes.
- **El muelle no puede aprobar.** La pantalla no lo ofrece y, si se fuerza, la nube responde PERMISSION_DENIED.
- **Una cuenta fuera de la lista** solo se probó en el simulador, por decisión de Carlos. Sale denegada.
- **El corte de red de Windows (10.15).** Vuelve a «Al día» 36 s después de que regresa la red, sin cambios de código. Lo de 6.5 era cosa del emulador.
- **Chrome.** La sesión sobrevive a recargar, y las dos pestañas no pierden ni duplican nada; registraron por turnos.
- **C10.** 23 escrituras, exactas (1 operación, 2 fuentes y 20 movimientos), y 103 lecturas. Para el caso entero queda muy por debajo de la cuota gratuita.
- **Un archivo nuevo, `tool/t79_c9_main.dart`.** Arranca Firebase igual que `lib/main.dart`, pero con un namespace propio, para no anexar movimientos de prueba en el almacén de Carlos.
- **Horas.** ≈ 2.5 en total, en lugar de 10.0. El total queda en ≈ 185.2 h.

**Abierto: las 48 eliminaciones de la pestaña Uso.**
- Las reglas niegan `delete` en todo, y una denegación no cuenta como eliminación: la métrica es de borrados exitosos.
- Ningún cliente puede borrar. Solo pueden hacerlo la consola o credenciales de administrador, y en el repo no hay rastro de la CLI de Firebase.
- **Carlos comprueba en la consola** que los datos siguen completos: 2 documentos en `authorized`, y en «PRUEBA T-79» 2 fuentes y 20 movimientos. También mira a qué hora marca las eliminaciones la gráfica de Uso.
- **Si falta algo, se detiene todo y se investiga antes de T-80.** Si no falta nada, se anota como observación del tablero de uso.
- **Resultado de la revisión (11-oct).**
  - **Los datos están completos.** Carlos lo comprobó en la consola: 2 documentos en `authorized`, y en «PRUEBA T-79» 2 fuentes y 20 movimientos.
  - **Las horas, en Cloud Monitoring** (Firestore Instance → Document Deletes, hora de Guatemala):
    - ≈ 48 borrados el **9-oct a las 9:25 a.m.**, mientras Carlos creaba Firestore y la colección `authorized` en la consola. Ningún agente usaba producción a esa hora: C9 empezó a las 12:20;
    - ≈ 2 más a la **1:10 p.m.**, al final de C9. Con eso la pestaña Uso suma 50.
  - **Ningún documento falta**, y las reglas no dejan borrar a ningún cliente. Se anota como observación, y T-80 sigue.
  - **Para saber quién borra, si vuelve a pasar:** activar los registros de auditoría de escritura de datos de Firestore en IAM. Es un ajuste de Carlos, y opcional.

**Otras decisiones.**
- **Dos textos pasan a T-97:** el punto doble al final de un rechazo, y «Conectando…» en lugar de «Sin conexión» al abrir un plano en la Web.
- **La operación «PRUEBA T-79» se queda abierta en la nube.** Sirve de dato de prueba y no estorba al piloto, que usará otra operación.
- **El código viejo de `voyages`.** `VesselRepositoryImpl.deleteVoyage` sigue intentando borrar en esa colección de la nube, que en producción está cerrada. No borra nada, porque las reglas lo niegan. Se anota para revisar en T-96 o en el cierre.

**El carril de `lib/` pasa a Codex**, en un chat nuevo.
1. Primero, la aceptación cruzada de T-79: la suite, las reglas en el emulador, los corpus y una sincronización corta en producción.
2. Después, **T-80**, con su ficha completa en la sección 5.
- Timonel queda en pausa. Después acepta T-80 y toma T-81.

### 10.17 · El tablero Kanban del Sprint 3 (11-oct)

**Carlos pidió el tablero, como en los sprints anteriores.** Está en `docs/BayStream_Tablero_Kanban_Sprint3.html`. Yov lo publica también como página («BayStream Kanban Sprint 3») y lo actualiza con cada decisión.
- **Lleva el formato del Sprint 2:**
  - cuatro columnas: Por hacer, En curso, En revisión y Terminado;
  - las tareas, agrupadas por elemento;
  - la capa de cada tarea;
  - en las terminadas, el commit y la cifra del caso real que la aceptó.
- **Al 11-oct:**
  - 15 tareas terminadas, con 41.5 h estimadas;
  - T-79 en revisión;
  - T-80 en curso;
  - 23 por hacer.
- **Dos sumas distintas, y las dos son correctas.**
  - **206.5 h:** el tablero suma las estimaciones de las 40 tarjetas, con las horas de las tablas de la sección 5 más T-70b y T-70c.
  - **≈ 185.2 h:** el encabezado de este archivo cambia la estimación de cada tarea terminada por sus horas reales.
  - El tablero muestra la estimación en cada tarjeta, y las horas reales van en la nota.

### 10.18 · T-79 terminada · T-80 en revisión · Timonel se ausenta tres días y Codex sigue solo · T-81 a Codex (12-oct)

**Las reglas de T-80 están publicadas** (11-oct, 4:08 p.m.).
- Carlos las publicó desde la consola.
- Yov revisó antes el archivo: solo cambia `validPayload`, partido por tipo, y la validación de cada elemento de `changes[]`. El bloque final sigue negando todo lo demás.
- Yov las comprobó en el simulador desde el Chrome de Carlos: leer sin sesión sale rechazado, y con la cuenta de muelle y con la de oficina sale autorizado.

**T-79 pasa a Terminado.** Codex la aceptó en ≈ 0.29 h, con la suite, las reglas, los corpus y una sincronización corta en producción.

**T-80, de Codex, pasa a En revisión** (commit `058847b`).
- **En producción, sobre «PRUEBA T-80»:**
  - el Honor pidió el intercambio 128 ↔ 145 y Windows lo aprobó;
  - un segundo pedido se rechazó;
  - el intento forzado del muelle de aprobar salió PERMISSION_DENIED, y el documento no existe en la nube.
- **El estado final en Windows, el Honor y Chrome:** 180 movimientos confirmados, 460/460 posiciones y cero conflictos.
- **Validaciones.** **498 pruebas** (el piso nuevo), `analyze` en cero, las reglas 69 de 69 y los corpus 54 de 54.
- **Horas.** 0.56 en lugar de 6.0. El total queda en ≈ 179.8 h.
- **Una precisión al diseño, aceptada.** Una aprobación que llega después de la carga **regulariza** esa carga, como piden la ficha y T-79a 2.7.2. La fila «cambio sobre algo ya movido» de la tabla de T-79a ya no se usa para ese caso.

**Timonel no está disponible unos tres días**, hasta el 15-oct aproximadamente, según Carlos. Mientras tanto:
- **Codex lleva el carril de `lib/` solo**, tarea tras tarea. No hay choque, porque es un solo programador.
- **Sus tareas quedan En revisión.** Timonel hace la aceptación cruzada de todas juntas cuando vuelva, empezando por T-80.
- **Yov revisa cada commit en cuanto llega:** el contenido, que no haya datos reales, `main.dart`, las dependencias y las cifras del informe.
- Codex sigue aceptando cada tarea en los tres clientes, y en producción cuando aplique.
- **Lo que sigue para Codex:** T-81 (ficha completa en la sección 5) y después la Ola 4, empezando por T-82 (el BAPLIE de salida).
- **Yov empieza la transcripción del IMDG para T-85**, para que no frene la Ola 4.

### 10.19 · T-81 entregada, en revisión · T-82 pasa a Codex con ficha completa (11-oct, noche)

**T-81, de Codex, pasa a En revisión** (commit `c31055d`), como fija 10.18 mientras Timonel no está.

- **El corpus, en A08 y A08v_VGM.** Cancelar el OR 5 deja **175 cargas pendientes** y 1 cancelado, con su celda vacía al final; mover el OR 1 a una celda libre compatible deja su carga allí **sin conflicto**; anular ambos cambios antes de las cargas devuelve el caso a **460/460** posiciones, 0 pendientes, 0 cancelados y 0 conflictos. Todo en orden cronológico, inverso y mezclado con semilla fija.
- **Una precisión al diseño, aceptada.** Anular un cambio **después** de registrada la carga restaura el plan y no mueve la carga física: el OR 1 queda «fuera de plan» y el OR 5 vuelve a pendiente; cargar el OR 5 y corregir el OR 1 con `corrects` devuelve 460/460. Es la semántica de T-79a vista al revés de la regularización de 10.18.
- **Producción, sobre «PRUEBA T-81»:** la oficina en Windows movió el OR 1 (022-04-02 → 006-10-02) y canceló el OR 5; el Honor y Chrome lo recibieron sin recargar, con los pendientes y «Cancelados» correctos; el muelle no pudo cargar el cancelado (bloqueo de T-77); un `cancel_item` forzado desde el muelle dio **PERMISSION_DENIED**, sin documento en la nube ni registro local; la oficina anuló ambos y los tres clientes terminaron con 4 registros confirmados y 4 ids distintos; Windows los conservó al reabrir.
- **Validaciones.** **508 pruebas** (el piso nuevo), `analyze` en cero y los corpus en 56 de 56. Las reglas no cambian: el informe confirma el SHA publicado el 11-oct a las 4:08 p. m.
- **Horas.** 2.14 h transcurridas frente a las 4.0 estimadas, de las que 0.84 h de trabajo activo quedaron documentadas; el total del encabezado lo recalcula Yov el miércoles (10.17).
- **Revisión del commit.** Los 14 archivos son los de la ficha: sin `main.dart`, sin congelados, sin `pubspec.*` ni reglas. El diff no trae claves, correos ni UID: las menciones de `apiKey` son lecturas de `String.fromEnvironment` del banco de aceptación, sin valores. `git ls-files` no rastrea ningún `.edi`, `.xlsx` ni `.csv` del corpus; los que hay son fixtures sintéticos y los registros de H5.
- **La fecha del informe (11-oct) es correcta:** sus marcas de tiempo van de 18:09 a 20:18 y el commit es del 11-oct a las 20:20. No se edita el informe de Codex.
- **Incidencias que declaró Codex, sin daño.** Lanzó una prueba de Flutter mientras Windows todavía compilaba, contra la regla de un comando a la vez; desde entonces los corre en serie. Y durante una inspección del Honor el aviso de guardar contraseña mostró un correo en la salida de la herramienta: se informó a Carlos, se borró el temporal y no entró al repo ni al informe.
- **Esperan la aceptación en lote de Timonel:** T-80 y T-81 (10.18).
- **Los cancelados del BAPLIE de salida, decidido por Carlos (11-oct):** no van en el EDI, porque no están a bordo. La app muestra los cancelados vigentes con su motivo y deja copiar la lista, para reportarla aparte si la agencia la pide.
- **T-82 pasa a Codex** con ficha completa (sección 5, Ola 4), en cuanto Carlos commitee esta decisión. La ficha precisa tres cosas sobre el borrador: la cabecera y la versión salen de la fuente `loading_baplie`; los pesos exactos del listado aplican a lo cargado y los de la llegada a lo que sigue a bordo; y la comparación con `CASO_A08_ESTADO_FINAL.csv` usa las columnas que ese CSV trae.

### 10.20 · T-82 entregada, en revisión · Los de paso salen con los datos del plan de carga · T-86 a Codex (11-oct, noche)

**T-82, de Codex, pasa a En revisión** (commit `98e94bd`), como fija 10.18.

- **La contradicción y la decisión.** Contra el CSV, A07 difiere de los 284 de paso en POL de 127 contenedores, en POD de 189, en línea de 58 y en peso de 113 (grupos solapados; 256 con algún puerto distinto; posiciones, ISO y lleno/vacío sin diferencias). Ejemplo: 0020310 pesa 24 260 kg en A07 y 24 200 en el CSV. **Decisión de Carlos: el plan de carga (`loading_baplie`) manda en los de paso en todos los campos —POL, POD, línea, peso y peligrosas—, y la llegada queda como respaldo de lo que el plan no declare. El CSV no se toca**: es el plano real como quedó al terminar. La instrucción anterior de conservar los pesos de A07 quedó retirada, y la ficha se corrigió en el commit `667a045`. Antes de tocar el escritor, Codex verificó que A08 coincide con el CSV en **284/284 de paso y siete campos**, sin diferencias.
- **El corpus, en A08 y A08v_VGM.** Reproducidos los 177 eventos y las 114 descargas, el BAPLIE generado se relee con el propio lector y da **460/460 en siete campos** (posición, contenedor, ISO, POL, POD, línea y peso); los de paso se cotejan además en WT/VGM, tara, lleno/vacío, peligrosas y temperatura contra el plan, y las 176 cargas contra el listado, incluidos los dos ONU del OR 127. El OR 12 queda en `R:0030984` con tara 2 185 kg. El OR 5 cancelado deja 459, no sale en el EDI y figura en la lista copiable con su motivo; `annul` devuelve 460 y vacía la lista. Texto idéntico en tres órdenes y en generar → leer → generar con reloj fijo. **Las nueve fuentes 2.x del corpus conservan su UNH; A06, que es SMDG15, se rechaza** — dato que aprovecha T-86.
- **Defecto propio hallado y corregido:** el recorte de segmentos quitaba el espacio reservado de UNA; se conservó y quedó prueba de regresión.
- **Clientes.** Windows de oficina, el Honor (`.t82`, modo sin cuenta) y Chrome visible guardaron y releyeron 460/460, con el portapapeles comprobado en Windows. La acción quedó en la pestaña de contenedores: en los controles del plano desplazaba una celda de la aceptación de T-75 a 360 dp, y se retiró esa integración sin editar las pruebas de T-75.
- **Validaciones.** **524 pruebas** (el piso nuevo; 16 nuevas), `analyze` en cero, corpus 68/68 de T-68 a T-82 y **79/79 del sprint en dos corridas**. Las reglas no cambian: mismo SHA publicado el 11-oct.
- **Horas.** 0.87 h transcurridas (≈0.80 documentadas) frente a 10.0 estimadas. El total lo recalcula Yov el miércoles (10.17); todas las tareas del sprint van muy por debajo de su estimación.
- **Revisión del commit.** Los 11 archivos son los del informe, y solo `vessel_overview_page.dart` es un archivo tocado (+3 líneas); `loading_plan_controls.dart` no queda en el commit, como dice el informe. Sin `main.dart`, congelados, `pubspec.*` ni reglas. El diff no trae claves, correos ni UID, y `git ls-files` sigue sin rastrear nada del corpus.
- **Incidencias declaradas, sin daño.** Chrome descargó primero en Descargas por su configuración; se comprobó fecha y tamaño, se movió a `%TEMP%` y no pasó por el repo. Una captura nativa tomó una ventana ajena con la app sin activar, y se descartó. **Observación para T-96:** el detalle del plano de llegada muestra las declaraciones de A07 (0020310: 24 260 kg) mientras la salida trae las vigentes del plan (24 200); la pantalla no se cambió.
- **Esperan la aceptación en lote de Timonel:** T-80, T-81 y T-82.
- **T-86 pasa a Codex** con ficha completa (sección 5, Ola 4). Con lo aprendido en T-82: **A06 del corpus es SMDG15 (1.x) y pasa a ser el espécimen real del rechazo**; las pruebas y corpus que hoy la leen se reescriben para esperar ese rechazo.

### 10.21 · T-86 entregada, en revisión · T-83 pasa a Codex con ficha completa (12-oct)

**T-86, de Codex, pasa a En revisión** (commit `1b1be4b`), como fija 10.18.

- **Cómo se aseguró la no-regresión.** Antes de editar el parser, Codex guardó en `%TEMP%` una referencia JSON de las nueve fuentes 2.x y después cotejó cada viaje completo —bahías, contenedores, reservas y metadatos—, excluyendo solo los UUID de cada lectura: **nueve de nueve, sin diferencias**. Los oráculos de T-66 y T-68 se repiten: A07 0/114/284, A02 0/303/503, A08 121/0/284 y A01 325/0/652.
- **A06 declara `BAPLIE:1:911:UN:SMDG15`** y se rechaza en el `UNH`, antes de interpretar su TDT o su carga. El aviso dice el archivo, la versión que trae y que BayStream lee SMDG20, SMDG21 y SMDG22. Un rechazo conserva el viaje anterior y no llega al almacén.
- **La adaptación fue grande y está documentada.** El commit toca 43 rutas porque A06 la leían pruebas y corpus desde los bloques históricos: la identidad del buque y los TDT de A01–A06 pasan a probarse dentro de mensajes sintéticos 2.x; los corpus y auxiliares históricos pasan a exigir el rechazo tipado (`requireA06Rejection`); el bloque 7 queda con 33 DGS y 29 unidades peligrosas de las cinco fuentes compatibles (A06 aportaba una declaración en una unidad). De paso, y declarado: las salidas de los corpus históricos de bloques 2/4/7 y T-37/52/53 pasan al temporal del sistema, y el fixture de T-68 usa Roboto porque Ahem desbordaba con los metadatos nuevos.
- **Fixtures sintéticos nuevos:** `t86_smdg21.edi` se lee completo (con reefer y dos peligrosas); `t86_smdg31.edi` (una 3.x) y `t86_sin_unh.edi` se rechazan.
- **Clientes.** Windows (`t86acc`), el Honor (`.t86`, 360×800 dp) y Chrome visible: A07 abre igual y los rechazos 1.x y 3.x muestran el aviso completo conservando el plano.
- **Validaciones.** **547 pruebas** (el piso nuevo; 23 nuevas), `analyze` en cero, **97/97 corpus** (79 del sprint, 10 de T-86 y 8 históricos) y 6/6 auxiliares. El escritor de T-82, `lib/main.dart`, `pubspec.*` y las reglas no cambian: mismo SHA, y el informe lo prueba con los SHA de escritor, `main.dart` y `pubspec`.
- **Horas.** 0.67 h transcurridas frente a 3.0 estimadas.
- **Revisión del commit.** Las 43 rutas son las del informe y en `lib/` los cambios son quirúrgicos: el parser (+38), el repositorio (+1), el mensaje de error (+1) y los providers (+8). El diff no trae claves, correos ni UID, y los tres `.edi` nuevos rastreados son fixtures sintéticos TSTU.
- **Incidencias declaradas, sin daño.** La descarga del SDK de C++ para Windows se quedó sin avanzar; se detuvo solo su CMake, con el PID comprobado como de la copia T-86, y se recompiló con el SDK 13.9.0 ya presente en la copia de T-82 —la misma versión que pide `firebase_core`—, sin cambiar dependencias. Un ADB emitió `FORTIFY` una vez sin perder la pantalla; la evidencia del aviso de Chrome se repitió porque el SnackBar caducaba.
- **Esperan la aceptación en lote de Timonel:** T-80, T-81, T-82 y T-86.
- **T-83 pasa a Codex** con ficha completa (sección 5, Ola 4): las tapas de escotilla en el perfil del buque, por bahía.

### 10.22 · T-83 implementada y commiteada; queda En curso: falta la aceptación del ajuste compacto y de Chrome (12-oct, noche)

**T-83, de Codex, queda En curso** (commit `5c87e44`). El encabezado de su informe dice «En revisión», pero el propio informe declara después que no se cumple «Terminada cuando»: prevalece eso. Es el caso de T-79 en 10.15: lo hecho está commiteado y falta su aceptación.

- **Lo que ya está.** El perfil declara tapas por bahía de bodega —sin tapa, una automática o 1–3 de grúa con sus filas—, valida contra la geometría de T-77 (filas ajenas, solapes, tapas vacías, bahías sin bodega) y el repositorio rechaza el borrador inválido sin tocar el perfil vigente. Retrocompatible: los perfiles viejos se leen sin tapas, «sin declarar» no equivale a bodega abierta y nada se inventa por omisión. El plano dibuja los contornos T1–T3 con sus filas, monocromáticos; una desalineación de 54 px hallada en la revisión de Windows quedó corregida con prueba de regresión. **Todas las tapas de la aceptación son PROVISIONALES**, como pide la ficha.
- **El supuesto de 10.13 quedó revisado como preveía la ficha:** las bahías se siguen deduciendo de los planes —la unión A07/A08 da 21 bahías con evidencia de bodega, incluidas las diez del caso— y el perfil guarda ese inventario para poder editarse sin un viaje abierto; no es una declaración de todas las bodegas físicas del buque.
- **Windows pasó completo:** 21 declaraciones guardadas, copia de 03 a 06, contornos en el plano y reapertura tras cerrar el proceso, con namespace `t83acc` y la caja de movimientos en cero bytes.
- **Honor a medias.** La vista a 360 dp reveló que hacía falta un resumen compacto; se añadió y pasó su prueba de widget y `analyze`, pero falta recompilar y revisar en el propio Honor la versión final, con declaración, copia y reapertura.
- **Chrome sin aceptar.** La automatización de Codex quedó bloqueada por la política de su herramienta de navegador: dos fallos al cargar la política y el rechazo del Chrome propio con perfil aparte («blocked by policy»). No intentó saltárselo. La página quedó servida en local para Carlos.
- **Validaciones locales.** **563 pruebas** (16 nuevas; el piso pasa a 563 cuando la tarea cierre), `analyze` en cero y **corpus 100/100**. Reglas, `lib/main.dart`, `pubspec.*` y congelados sin cambios.
- **Horas.** 0.39 h registradas antes de la interrupción, más lecturas sin marca inicial; la aceptación restante queda por contabilizar.
- **Revisión del commit.** Las 15 rutas son las del informe y todas del carril de la ficha; el diff no trae claves, correos ni UID, y no se rastreó ningún archivo nuevo del corpus.
- **Cómo sigue.** Codex continúa T-83 en otra sesión con la lista de «Continuación necesaria» de su informe: recompilar los tres clientes desde la fuente final, completar el Honor y aceptar Chrome —primero con su Chrome propio de perfil aparte; si el bloqueo persiste, prepara el recorrido manual exacto para que Carlos lo haga, y queda en el informe como aceptación manual de Carlos. Con «Terminada cuando» cumplido, la tarea pasa a En revisión y se escribe la ficha de T-84.
- **Esperan la aceptación en lote de Timonel:** T-80, T-81, T-82 y T-86.

### 10.23 · T-83 terminó su aceptación y pasa a En revisión · T-84 a Codex con ficha completa (12-oct, noche)

**T-83, de Codex, pasa a En revisión** (commits `5c87e44` la implementación y `19ef763` el cierre de la aceptación; este último solo modifica el informe).

- **La continuación de 10.22 se cumplió entera.** Los tres clientes pasaron desde la fuente final recompilada —Windows 34.2 s, APK `.t83` 74.3 s, Web 48.5 s, en serie—, y el SHA de cada archivo de `lib/` de la copia se cotejó contra el repositorio: **0 diferencias**. Con la misma fuente se re-corrieron la suite (**563/563**) y `analyze` (**0**); el corpus **100/100** de la primera sesión sigue valiendo porque la fuente no cambió.
- **Honor, completo:** el perfil anterior reabrió con 0 bahías sin inventar ninguna; se revisaron sin tapa (01), automática (02) y 1–3 de grúa (03, 05, 06); los dos rechazos se leyeron completos a 360 dp («La fila 06 se solapa entre tapas»; «La fila 99 de la tapa 2 no pertenece a la geometría de bodega de esta bahía»), conservando el diagrama válido; la copia 03→06 guardó las 21 bahías; el resumen compacto mostró las tres tapas sin desplazamiento, y la reapertura cotejó «Perfil releído igual · 21 bahías · válido».
- **Chrome, con un precedente de proceso.** El reintento del Chrome propio volvió a quedar «blocked by policy» y no se intentó saltárselo; **Carlos autorizó expresamente revisar su pestaña ya abierta** en la dirección local, el conector la seleccionó con la URL verificada y la ventana visible. El informe atribuye la aceptación a Codex mediante el conector y **no** la registra como aceptación manual de Carlos. Queda como método si el bloqueo reaparece. El recorrido fue completo: perfil histórico sin declarar, 21 bahías PROVISIONALES, rechazos, copia, resumen compacto a 360×800 verificado en el DOM y reapertura igual.
- **Windows:** el binario recompilado re-verificado con dos reaperturas (PIDs 7212 y 33324) y el plano de 06 con T1 `10,08,06`, T2 `04,02,00,01` y T3 `03,05,07,09` alineados; `t83acc_movements.hive` terminó en 0 bytes.
- **Horas.** 1.19 h registradas entre las dos sesiones frente a 4.0 estimadas, más el tramo inicial sin cronometraje declarado.
- **Revisión del commit.** `19ef763` toca solo el informe; el diff no trae claves, correos ni UID. Las tapas siguen **PROVISIONALES**.
- **Esperan la aceptación en lote de Timonel:** T-80, T-81, T-82, T-83 y T-86. El piso pasa a **563**.
- **T-84 pasa a Codex** con ficha completa (sección 5, Ola 4). Dos decisiones de diseño que lleva la ficha: el aviso de tapa cerrada **nunca bloquea** —las declaraciones son PROVISIONALES y un dato provisional no frena la operación— y los movimientos de tapa los registra **quien opera**, muelle u oficina, porque es un hecho observado, no un cambio de plan.

### 10.24 · T-84 entregada, en revisión: las tapas se operan y sincronizan · Hallazgo: el perfil de T-83 no viajaba en Firestore · T-89 a Codex (13-oct)

**T-84, de Codex, pasa a En revisión** (commit `7c845ba`).

- **Las tapas como movimientos.** `hatch_cover` con `target: T:bahía-número` y `action: remove|replace`, la clave `T:` de T-79a; el estado se deriva de la bitácora, tras resolver anulaciones y correcciones. Quitar dos veces o reponer sin quitar queda en conflicto; `annul` deshace respetando el rol del movimiento anulado. Lo registran muelle y oficina: hecho observado, sin solicitud ni aprobación, como fijó la ficha.
- **El aviso nunca bloquea.** Nombra la tapa y la bahía, marca PROVISIONAL y ofrece «Quitar tapa y continuar» o «Seguir sin quitarla». El toque combinado anexa tapa → (descarga) → carga como escrituras consecutivas durables, como el par de T-77, y el deshacer inmediato anula en orden inverso. No avisa en cubierta, en filas no cubiertas, con la tapa ya quitada, en bodega abierta ni en bahía sin declarar.
- **El avance suma tapas** por bahía: declaradas, quitadas y repuestas. «Repuesta» cuenta tapas cuyo último movimiento aplicado es reponer; una tapa inicial puesta no cuenta. El corpus coteja el avance en cada prefijo.
- **Corpus.** A08 y A08v_VGM dan **460/460** con tapas PROVISIONALES en las 21 bahías de bodega, tres órdenes de trabajo por bahía y tres de llegada de la bitácora; cada retirada y reposición conserva la ocupación anterior. Corpus completo **102/102**.
- **Producción, «PRUEBA T-84»:** seis movimientos compartidos entre la oficina en Windows y el muelle en el Honor, en las dos direcciones y sin recargar; ambos terminan Al día y sin conflictos, con el avance de tapas **3/0/2** coincidente. Windows conservó aparte sus cinco movimientos locales previos, y el informe no los presenta como enviados.
- **El hallazgo, para la revisión de Timonel y de Yov.** Publicar una operación con el perfil de tapas de T-83 tiraba Windows: dos caídas nativas (Event 1000, `KERNELBASE.dll`), porque Firestore Standard no admite arrays dentro de arrays y el JSON llevaba `covers: [[filas], [filas]]`. Era un defecto latente de T-83, cuya aceptación nunca publicó una operación. **Corrección en `data/`:** `FirestoreProfileCodec` convierte `covers` en un mapa por número solo al viajar y lo reconstruye al recibir; el JSON de Hive, el editor de T-83 y el dominio no cambian su representación, y los perfiles históricos se siguen leyendo. Con el codec, Windows publicó y quedó Al día sin repetir la caída; no se obtuvo pila nativa, así que el informe no lo presenta como traza de causa definitiva. Las operaciones publicadas antes de T-83 no traían tapas y no están afectadas.
- **Reglas.** La batería de T-80 pasó **69/69** sin cambios y con el mismo SHA; las reglas ya exigían `profile is map` y admiten la representación nueva.
- **Una prueba de T-72 se reescribió**, declarada: la tapa sin declarar ahora produce `invalidHatchCover` en vez de quedar sin derivar; la comprobación del cambio inválido se conserva y ninguna prueba se borró.
- **Validaciones.** **580 pruebas** (el piso nuevo; 17 nuevas), `analyze` en cero, corpus 102/102 y el SHA de cada archivo de `lib/` cotejado entre repo y copia: 0 diferencias.
- **Clientes.** Windows (`t84acc`), el Honor `.t84` a 360×800 dp y Chrome visible, esta vez sin bloqueo de política. El APK final se instaló con `-r` después de la entrada manual de Carlos y conservó sesión y almacén. El «Deshacer» fugaz no se alcanzó a probar en el teléfono y el informe no lo atribuye; la prueba de widget lo cubre.
- **Incidencia recurrente declarada.** Durante la entrada de Carlos, un diálogo de Google para guardar contraseña entró en un volcado y mostró identificadores de cuenta. Codex informó, descartó el guardado, borró el temporal y no copió identificadores al informe. Es la segunda vez (T-81); queda anotada para que Yov valore un mitigamiento sistémico.
- **Horas.** 1.12 h de pared frente a 4.0 estimadas.
- **Revisión del commit.** Las 21 rutas son las del informe; sin `main.dart`, `pubspec.*`, reglas ni congelados; el diff no trae claves, correos ni UID, y no se rastrearon archivos del corpus.
- **Esperan la aceptación en lote de Timonel:** T-80, T-81, T-82, T-83, T-84 y T-86.
- **T-89 pasa a Codex** con ficha completa (sección 5, Ola 5, abierta por tiempo sobrante): sin filtro por extensión y validación por contenido. Con T-84, la **RF-040 queda completa en código**.

### 10.25 · T-89 entregada, en revisión · El peso llega al PDF: T-102 a Codex (13-oct)

**T-89, de Codex, pasa a En revisión** (commit `3963098`).

- **Qué cambió.** El selector BAPLIE comparte `FileType.any`, sin `allowedExtensions`: cualquier archivo se puede elegir en las tres plataformas. La validación sigue siendo la de T-86; su rechazo «sin UNH/S009» se traduce en presentación a un mensaje claro («Este archivo no parece un BAPLIE…»). **Una precisión aceptada:** se admite por `UNH`, que es lo que el lector ya exige; no se añadió un segundo analizador ni se exige `UNB` aparte.
- **La Web, con el selector real.** Chrome eligió A07 sin extensión, como `.txt` y como `.edi`, con las cifras intactas (398 contenedores, 21 bahías, 6 940 578 kg y 0/114/284 en GTSTC); el almacén terminó con 3 viajes y 1 perfil, conservados tras los tres rechazos. Windows y el Honor abrieron un `.edi` con su diálogo nativo; los otros nombres quedan cubiertos por las pruebas de entrada, y el informe no los presenta como recorridos nativos.
- **Los rechazos conservan todo:** texto sin cabecera y 1.x y 3.x sintéticas, sin crear viaje ni tocar el almacén, con los avisos de T-86 íntegros.
- **iPhone.** Carlos no tiene uno: la comprobación queda para el piloto (T-101), y el informe no se atribuye una aceptación de Safari/iOS.
- **Validaciones.** **592 pruebas** (el piso nuevo; 12 nuevas), `analyze` en cero, corpus **105/105** (los tres nombres de A07) y SHA idénticos de lector, escritor, reglas, `main.dart` y `pubspec.*`.
- **La mitigación que faltaba.** El primer volcado del selector del Honor incluyó identificadores de cuenta de Drive —la tercera incidencia de esta clase, tras T-81 y T-84—. Codex informó, borró los temporales y cambió el método: `adb exec-out uiautomator dump /dev/tty`, capturado en memoria y con los identificadores ocultos antes de mostrar o guardar nada; las lecturas siguientes mostraron «cuenta oculta». **Queda como práctica estándar** para los volcados del Honor; Yov la confirma el miércoles.
- **Observación para T-97:** la barra de acciones existente desborda a 360 dp con un viaje abierto (`RenderFlex`) y en el Honor la cabecera va apretada. No se cambió la pantalla.
- **Horas.** 0.48 h de pared frente a 1.0 estimada.
- **Revisión del commit.** Las 7 rutas son las del informe; sin `main.dart`, `pubspec.*`, reglas, lector ni escritor; el diff no trae claves, correos ni UID, y no se rastreó nada del corpus.
- **Esperan la aceptación en lote de Timonel:** T-80, T-81, T-82, T-83, T-84, T-86 y T-89.
- **T-102 pasa a Codex** con ficha completa: el peso en las celdas del PDF como en el plano impreso y la marca «+?» en las pilas con pesos faltantes — las dos deudas de 10.2 y 10.13.

### 10.26 · T-102 implementada y commiteada; queda En curso por las aperturas visuales · El PDF pasa a monocromático completo por decisión de Carlos (13-oct)

**T-102, de Codex, queda En curso** (commit `fd87b66`), por el precedente de 10.22: la implementación y las validaciones están hechas y commiteadas; falta la apertura visual de los PDF en lectores reales.

- **Decisión de Carlos durante la sesión:** el PDF completo monocromático —portada, rejilla, leyenda, tabla y pie en grises—, conservando los rótulos de tipo y las diferencias de rellenos y contornos. La app no se recolorea. Amplía el «estilo monocromático» que la ficha pedía conservar.
- **Lo implementado.** Peso efectivo (`VGM ?? bruto`) por celda del PDF, en toneladas con un decimal; sin peso no se imprime `0.0` y un cero declarado sí; las sombras de 40 pies no llevan peso. En pantalla, la cabecera de pila agrega **«+?»** cuando un contenedor propio de esa fila y zona carece de peso efectivo; cubierta y bodega se separan; reservas y sombras no cuentan; las sumas y los avisos de exceso no cambian.
- **Verificación del PDF con herramienta propia:** `tool/t102_verify_pdf.py` (Python, en `tool/`, sin tocar `pubspec`) localiza cada celda por sus rótulos de fila y nivel, comprueba el peso dentro del rectángulo, que ningún texto sale de la celda y que todos los trazos, rellenos y textos son grises; la portada muestra el total redondeado `6940.6 t` y el dominio conserva el exacto **6 940 578 kg**. Los tres clientes exportaron A07: **398/398 celdas y 33 páginas**; A08 y A08v: **405/405 y 36 páginas**, con 6 899 700 kg. El fixture sintético cubre VGM, bruto, ambos, cero y faltantes, sin cifras inventadas.
- **Pantalla.** `28.7+?` y `0.0+?` en el fixture incompleto; las pilas completas sin marca; una reserva sin peso conserva `21.0`. A07, A08 y A08v recorren todas sus bahías a 360 dp sin «+?» ni excepciones de layout. La barra de acciones apretada y el selector de bahía con texto al 200 % siguen siendo deuda declarada de T-97.
- **Validaciones.** **599 pruebas** (7 nuevas; el piso pasa a 599 al cerrar la tarea), `analyze` en cero, corpus **108/108**, y SHA idénticos de reglas, lector, escritor, `main.dart`, `pubspec.*` y los dos congelados de H5.
- **Por qué falta la aceptación.** Computer-use detuvo el control al pedir capturar el PDF abierto en Edge, por no poder confirmar la URL para su política; Codex no lo sorteó ni se atribuyó aperturas no observadas. El informe propone que **Carlos abra los tres PDF y compruebe** —portada (`6940.6 t`), página 2 y bahía 022 en la página 15: peso por celda con un decimal, grises, 33 páginas— y quede registrado como aceptación manual de Carlos; o continuar en otro turno con un conector que pueda observar el visor.
- **Incidencias declaradas.** Un build se inició sin esperar el fin del corpus, contra la regla de un comando de Flutter a la vez —segunda vez en el sprint, tras T-81—; falló sin daño y lo siguiente corrió en serie; la limpieza quedó bloqueada por política y se usó otra copia. Los volcados del Honor ya salen sanitizados con el método de T-89 («cuenta oculta»). Un evento de descarga de Chrome venció y el archivo se comprobó por fecha, tamaño y contenido, sin presentarlo como éxito del conector.
- **Horas.** 0.56 h de pared frente a 1.0; la aceptación restante se cuenta al hacerla.
- **Revisión del commit.** Las 8 rutas son las del informe; el diff no trae claves, correos ni UID, y no se rastreó nada del corpus.
- **Esperan la aceptación en lote de Timonel:** T-80, T-81, T-82, T-83, T-84, T-86 y T-89; T-102 se suma al cerrar su aceptación.

### 10.27 · T-102: Carlos acepta los pesos a la vista y revoca el monocromático completo (13-oct)

- **La aceptación visual de los pesos, hecha por Carlos.** Abrió los PDF exportados y comprobó la portada —`6940.6 t`, 398 contenedores, 290 llenos, 108 vacíos, 12 reefer y 14 IMO— y la página 2, la bahía 001, con los pesos por celda a un decimal (`2.3` y `6.9`, que suman los `9.2 t` del encabezado; una primera lectura dijo `8.9` por error y Codex la corrigió contra la suma). Es aceptación manual de Carlos; que quede registrada con fecha y hora en el informe de Codex.
- **La decisión de sesión se revoca.** El PDF monocromático completo, pedido por Carlos durante la sesión de T-102, no le gustó al verlo: con todo en grises, la leyenda (lleno, vacío, IMO, reefer, OOG, vecino de 40 pies, sin contenedor) casi no distingue categorías. **El PDF vuelve a la paleta de colores que traía antes de T-102**, conservando el peso efectivo por celda y el «+?» en pantalla. La comprobación de grises del verificador se adapta: siguen los pesos y la geometría, no la monocromía.
- **T-102 sigue En curso** hasta el recolor, la re-verificación y una mirada rápida de Carlos a la portada y a una bahía cargada (la 022, página 15). Con eso pasa a En revisión.
- **Cómo llegó a pasar esto, para el registro:** la ficha decía «estilo monocromático del PDF actual» por suponer que ya lo era; el PDF real traía paleta, en sesión se pidió todo gris, y visto el resultado se revoca. La regla de la app (escalas monocromáticas en pantalla) no cambia: esto es solo del PDF.

### 10.28 · T-102 en revisión: el PDF volvió al color y Carlos lo aceptó · T-91 a Codex con ficha completa (13-oct)

**T-102, de Codex, pasa a En revisión** (commits `fd87b66` la implementación y `4c41f67` el recolor y el cierre de la aceptación).

- **El recolor de 10.27, cumplido.** El PDF volvió a su paleta anterior en portada, rejilla, leyenda, tabla y pie, con los pesos por celda intactos; el verificador dejó de exigir grises y siguió comprobando pesos, posiciones y que ningún texto sale de la celda. **Tres exportaciones verificadas tras el cambio:** 398/398 celdas, 33 páginas y `6940.6 t` de portada.
- **Las dos aceptaciones manuales de Carlos** constan en el informe con sus horas: la de los pesos —portada y bahía 001: `2.3` y `6.9`, que suman los `9.2 t` del encabezado— y la de la paleta restaurada, con portada y bahía 022. La corrección del `6.9` quedó registrada en 10.27 y en el informe.
- **Validaciones finales.** **599 pruebas**, `analyze` en cero y corpus **108/108**; reglas, `lib/main.dart` y `pubspec.*` sin cambios.
- **Horas.** 0.94 h de pared en total frente a 1.0 estimada.
- **El piso pasa a 599.** **Esperan la aceptación en lote de Timonel:** T-80, T-81, T-82, T-83, T-84, T-86, T-89 y T-102.
- **T-91 pasa a Codex** con ficha completa (sección 5, Ola 5): la barra superior plegable. El desborde de la barra a 360 dp con viaje abierto, observado en T-89 y T-102, debe desaparecer al menos plegada; el texto que quede cortado con la barra expandida sigue siendo deuda de T-97.

### 10.29 · T-91 entregada, en revisión: la barra del plano se pliega · T-90 a Codex con ficha completa (13-oct)

**T-91, de Codex, pasa a En revisión** (commit `d836132`).

- **Lo construido.** En Bay Plan, con un viaje abierto, la barra empieza plegada si no hay elección previa: solo «BayStream» y «Desplegar acciones». Un toque alterna; la elección se guarda como `planToolbarCollapsed` en la caja de ajustes, junto al último puerto de T-68, por dispositivo y sin sincronizarse. Desplegada devuelve las ocho acciones originales, con el botón de plegar fijo y una tira desplazable —necesaria en el Honor a 360 dp, donde la primera implementación dejaba el botón fuera de pantalla y se corrigió—. Fuera de Bay Plan la barra no cambia, y los modos de operación quedan intactos.
- **La vista se conserva al alternar**, y no de oído: identidad del `State` y del `AsyncValue` del viaje, bahía, modo y posiciones de desplazamiento antes y después de dos toques, y **cero diferencias de píxeles** del cuerpo del plano en el Honor y en Chrome.
- **Una precisión honesta:** la ficha mencionaba el zoom; Bay Plan no tiene zoom ni `InteractiveViewer`, y el informe no finge haberlo probado.
- **La deuda de la barra, pagada donde tocaba:** plegada ya no desborda a 360 dp, en claro y en oscuro —era la observación de T-89 y T-102—. El título desplegada y los demás textos siguen siendo deuda de T-97, declarada.
- **Validaciones.** **605 pruebas** (el piso nuevo; 6 nuevas), `analyze` en cero, corpus **110/110** (+2), y SHA idénticos de reglas, `lib/main.dart`, `pubspec.*`, lector, escritor y los dos congelados de H5. Sin dependencias nuevas.
- **Clientes.** Windows (almacén real, `t91acc`, sin movimientos), Honor `.t91` a 360×800 y Chrome visible; ambos temas, ambas preferencias tras reapertura. Carlos ayudó a poner Chrome visible cuando la ventana dejó de dibujar, y quedó declarado.
- **Horas.** 3.06 h de pared con una interrupción de sesión de 2.03 h (la ventana entre 13:19 y 15:21); descontada, ≈1.03 h más la redacción, frente a 1.5 estimadas.
- **Revisión del commit.** Las 10 rutas son las del informe; el diff no trae claves, correos ni UID, y no se rastreó nada del corpus.
- **Esperan la aceptación en lote de Timonel:** T-80, T-81, T-82, T-83, T-84, T-86, T-89, T-91 y T-102.
- **T-90 pasa a Codex** con ficha completa: el interruptor de tema claro/oscuro. La app ya sigue el tema del sistema y las dos paletas existen desde la convención 2.8; T-90 pone el interruptor propio y barre las pantallas en claro.

### 10.30 · T-90 entregada, en revisión: claro, oscuro y sistema · T-94 a Codex (13-oct, noche)

**T-90, de Codex, pasa a En revisión** (commit `fd4352d`).

- **Lo construido.** «Parámetros» ofrece claro, oscuro y **seguir al sistema** —la elección inicial y la recuperación ante valor desconocido—; `themePreference` persiste en la caja de ajustes junto a la barra de T-91 y el último puerto; `BayStreamApp` aplica el `ThemeMode`; el enum vive en el dominio sin Flutter, y un fallo de guardado se informa sin afirmar persistencia.
- **El barrido en claro, con tabla de correcciones:** celdas del plano emparejadas (llenos, vacíos, IMO, reefer, OOG, desconocido, tránsito), el OR y el resaltado con contenedores del esquema, la rejilla y la leyenda, la lista y el detalle, y la pantalla principal. Sin literales RGB y `pubspec` sin cambios. **Contraste ≥ 4.5:1 comprobado en 803 pesos por tema (1 606 comprobaciones)**, declarado como esa muestra y no como auditoría general de accesibilidad.
- **Aceptación en los tres clientes** con selectores reales y A07/A08 con sus cifras: las tres elecciones persisten tras reaperturas, el barrido pasó por las pantallas de la ficha —con el OR 123 visible en Número de orden y el listado importado 120/120 y 56/56— y la barra de A07 a 360 dp en claro y oscuro en el Honor. Honradez declarada: la alternancia del tema del sistema se probó en el widget del `BayStreamApp` real y no cambiando el sistema operativo; en Chrome la confirmación de la importación no se alcanzó por desplazamiento y se usó el importador desde el banco, sin atribuirse una confirmación manual; dos capturas de Chrome quedaron fuera de la evidencia por un viewport equivocado y las negras de Windows no se usaron.
- **Dos fallos corregidos antes de la corrida final:** el estilo de estado desconocido coincidía con tránsito (regresión C5a) y el banco reutilizaba un árbol con un `ProviderScope` ya dispuesto.
- **Validaciones.** **612 pruebas** (el piso nuevo; 7 nuevas), corpus **112/112** en 29 archivos, incluidos los PDF —patrón `*corpus*test.dart`—, `analyze` en cero, y SHA idénticos de reglas, `lib/main.dart`, `pubspec.*`, lector, escritor y los dos congelados de H5.
- **Horas.** ≈1.6 h activas frente a 2.0 estimadas, con una interrupción de sesión de ≈3.1 h descontada y declarada —la tercera interrupción larga del sprint: patrón conocido del límite de chat—.
- **T-97 conserva sus deudas** de disposición (recortes de títulos y textos, espacio del título con la barra expandida); no son de contraste y no se arreglaron de paso.
- **Revisión del commit.** Las 17 rutas son las del informe; el diff no trae claves, correos ni UID, y no se rastreó nada del corpus.
- **Esperan la aceptación en lote de Timonel:** T-80, T-81, T-82, T-83, T-84, T-86, T-89, T-90, T-91 y T-102. El piso pasa a **612**.
- **T-94 pasa a Codex** con la ficha completa de la sección 5: la búsqueda por voz con `speech_to_text`, confirmado por Carlos. Es la primera dependencia nueva desde T-79: `pubspec.yaml` y `pubspec.lock` cambian y se declara, y la ficha autoriza `RECORD_AUDIO` en el manifest de Android, con la implicación para la política de privacidad de T-88 anotada.

### 10.31 · T-94 entregada, en revisión: la voz llega al muelle · La lista del relevo queda completa (13-oct, noche)

**T-94, de Codex, pasa a En revisión** (commit `6322d96`).

- **El diseño seguro.** El micrófono va junto a la búsqueda de T-76 —también en «Asignar vacío», que comparte selector— y solo se inicializa tras pulsarlo. El transcript normalizado entra **como borrador editable** y las coincidencias quedan suspendidas hasta pulsar Buscar: reconocer voz no busca, no selecciona fila, no cambia bahía ni registra nada. La normalización, en Dart puro: palabras 0–9, grupos con sus ceros, nombres españoles de letras y variantes («doble uve», «i griega», «be larga»…), espacios y puntuación fuera, y lo desconocido queda para corregir a mano. Ejemplo del informe: «te ese te u cero cero cero uno dos tres cuatro» → `TSTU0001234`.
- **El contrato `VoiceRecognizer`** con un adaptador por sesión: cancela al cerrar, editar, confirmar o abandonar; descarta callbacks tardíos y corta a los 35 segundos un servicio que no contesta. Los fallos avisan en español y la búsqueda manual sigue.
- **La dependencia, primera desde T-79:** `speech_to_text 7.2.0` —compatible con el Flutter instalado sin el soporte inicial de Windows de la 7.3; la 7.5 exigiría Flutter 3.44—. El lock añade solo esa directa y dos transitivas (`speech_to_text_platform_interface 2.5.0` y `pedantic 1.11.1`), sin mover nada preexistente. **Cambian `pubspec.yaml` y `pubspec.lock`, declarados.**
- **El manifest, lo autorizado y nada más:** `RECORD_AUDIO` y la consulta de `RecognitionService` (necesaria desde SDK 30), sin Bluetooth. **Para T-88, de Yov:** la política de privacidad debe explicar el micrófono opcional y que el servicio de voz del sistema o del navegador puede procesar audio remotamente; BayStream no guarda audio ni sube el transcript.
- **Matriz de soporte, comprobada por plataforma:** Android sí, con dictado real; Web sí donde exista `SpeechRecognition` (se pide `es-GT` explícito y sin API el botón se oculta); Windows sin implementación nativa y botón oculto, con la app compilando y abriendo; iOS/macOS/Linux fuera de los clientes de la tarea.
- **La aceptación humana, bien atribuida.** Los dos dictados del Honor final (el OR 1 completo y el sufijo del OR 3) y el modo avión —la voz falló con aviso y la búsqueda manual encontró el OR 3— los aceptó **manualmente Carlos** (~21:20–21:25, repetidos sobre el APK final ~21:34); Codex no se atribuye la voz ni el aviso literal, y la evidencia son los mensajes de Carlos. Windows sin micrófono, con las búsquedas manuales hechas por Carlos cuando la automatización no llegó al campo; Chrome con OR y sufijo verificados por Codex. `t94acc_movements.hive` terminó en 0 bytes.
- **Validaciones.** **635 pruebas** (el piso nuevo; 23 nuevas), corpus **114/114** (30 archivos, con los PDF) y `analyze` en cero. El corpus convierte a palabras los 121 números de cada variante de A08 y coteja **242 completos y 242 sufijos** contra la búsqueda manual original. Reglas con SHA idéntico; `main.dart` y congelados intactos.
- **Incidencias declaradas.** Pub falló tres veces al descargar el paquete: se verificó el SHA-256 contra el publicado, se extrajo al caché y `flutter pub get` resolvió el lock, sin overrides ni modificaciones del paquete. La automatización de Windows no llegó al campo y las búsquedas las hizo Carlos; una captura tomó otra ventana y se descartó.
- **Horas.** ≈0.60 h de pared frente a 4.5 estimadas.
- **Revisión del commit.** Las 19 rutas son las del informe: el manifest suma exactamente lo autorizado y ambos `pubspec` lo declarado; sin `main.dart`, reglas ni congelados; el diff no trae claves, correos ni UID, y no se rastreó nada del corpus.
- **Esperan la aceptación en lote de Timonel:** once tareas — T-80, T-81, T-82, T-83, T-84, T-86, T-89, T-90, T-91, T-94 y T-102. El piso pasa a **635**.
- **Con T-94, la lista de tareas encomendadas al relevo queda completa.** Lo que sigue — T-92, T-93, T-88 (que ahora también explica el micrófono), T-97, la Ola 6 y el cierre — lo decide y ordena Yov desde el miércoles.

### 10.32 · T-97 entregada, en revisión: los textos completos y un estado de conexión veraz · Carlos extendió el relevo con esta tarea (14-oct)

**T-97, de Codex, pasa a En revisión** (commit `c3dedc5`).

- **El catálogo, completo y con ubicaciones.** El título se lee completo a 360 dp —hasta dos líneas, con la tira de acciones reservándole espacio—, también en Lista, Estadísticas y Avance; «Total Contenedores» sin elipsis; la fila del detalle pasa a columna cuando falta ancho, incluso al 200 %; los contadores concuerdan con un formatter común (`1 cargado`); las zonas dicen pendientes («(66 pendientes en cubierta / 48 pendientes en bodega)»); el punto doble del rechazo se corrigió en el motor sin reescribir registros; y el selector de bahía al 200 % no desborda —donde el Honor destapó que su escala de fuente es **no lineal**: la prueba lineal pasaba y la real desbordaba; se corrigió el cálculo y quedaron dos pruebas que lo reproducen—.
- **La ampliación autorizada, ejecutada y delimitada.** Decisión de Carlos del 13-oct por la noche, ante la pregunta de Codex: el contrato gana `SyncState.connecting` y el motor distingue conexión desconocida de caída confirmada; la caché inicial no confirma caída y no se puso temporizador que adivine. Son las dos rutas no de presentación declaradas (`operation_sync_repository.dart` +2 y `sync_engine.dart` +16), sin cambios en el adaptador Firestore, reglas, protocolo de envío, orden ni almacén. **La frase «es todo presentación» de la ficha queda corregida por esta decisión.**
- **La transición se vio en la nube real,** sobre la operación existente «PRUEBA T-84» (TSTU) y con la sesión de muelle iniciada personalmente por Carlos: «Conectando…» al abrir, luego «Al día», «Sin conexión» tras cortar el SDK desde el banco y recuperación al devolver la red. No se publicó nada para fabricar la prueba.
- **Validaciones.** **648 pruebas** (el piso nuevo; 13 nuevas: diez de texto y tres del motor), `analyze` en cero, corpus **116/116** en 31 archivos, y SHA idénticos de reglas, `lib/main.dart`, `pubspec.*`, lector, escritor y los dos congelados. Las pruebas de T-74 y T-75 solo actualizaron palabras corregidas y desplazamientos, con los asserts funcionales conservados.
- **Clientes:** el Honor `.t97` a 360×800 con letra al 200 % real en ambos temas; Windows con el almacén real `t97acc` y la caja de movimientos en 0 bytes; Chrome con el plano, el detalle y Avance en ambos temas, y la transición de nube descrita arriba.
- **Horas.** ≈1.65 h frente a 1.0, con el desvío explicado (la escala no lineal del Honor, la transición del motor, el ajuste final de Avance y la repetición de los tres builds) y el apagón de la laptop excluido y declarado.
- **Revisión del commit.** Las 21 rutas son las del informe; el diff no trae claves, correos ni UID, y no se rastreó nada del corpus.
- **Esperan la aceptación en lote de Timonel: doce tareas** — T-80, T-81, T-82, T-83, T-84, T-86, T-89, T-90, T-91, T-94, T-97 y T-102. El piso pasa a **648**.
- **Cierre del relevo.** El relevo termina el 14-oct a las 13:00. Quedan en mesa de Yov: T-92, T-93, T-88 (que ahora también explica el micrófono opcional y el posible procesamiento remoto del servicio de voz), T-56 y T-95/T-96 de la Ola 6, el IMDG (T-85, con la transcripción), T-87 (archivo 3.1 real), T-101 (COMAR) y el cierre del curso (T-98 a T-100).

### 10.33 · Yov vuelve y ratifica el relevo · Horas, tablero y dos reglas nuevas (14-oct)

**El relevo de GLM 5.3 terminó** el 14-oct a las 13:00. Corrió del 11-oct por la noche al 14-oct. Yov leyó entera su bitácora (`docs/RELEVO-Yov-GLM.md`, que no se commitea) y las decisiones 10.19 a 10.32, y revisó en el código los dos puntos de motor.

**Se ratifican las decisiones 10.19 a 10.32**, con estas precisiones:
- **10.20, los de paso salen con el plan de carga: ratificada.** El BAPLIE de salida continúa el plan del planner de la línea, que es la declaración vigente de lo que zarpa; la llegada es información más vieja. Las diferencias entre A07 y el plan son datos reales, no errores, y T-96 las tiene que mostrar: 127 en POL, 189 en POD, 58 en línea y 113 en peso.
- **10.21, A06 rechazada: ratificada tal como se construyó, con una decisión pendiente de Carlos.** Rechazar la 1.x cumple la fila de T-86. Pero A06 se leía antes, y Carlos dijo que no hay que descartar versiones anteriores. Yov propone leer la SMDG15 con un aviso visible y seguir rechazando el resto de la 1.x y la 3.x (10.34).
- **El origen de los criterios de T-86, precisado a pedido del propio relevo:**
  - leer toda la familia 2.x y rechazar con mensaje claro vienen de la fila de T-86, escrita en la apertura;
  - A06 como espécimen real nace del hallazgo de T-82;
  - los fixtures sintéticos vienen de la fila y de la ficha.
  - Una frase del resumen del relevo en el chat («los tres criterios nacieron de la ficha de T-82») era imprecisa. No está en ningún archivo, y 10.20 y 10.21 son correctas.
- **10.23, el aviso de tapa cerrada nunca bloquea: ratificada.** Las tapas son PROVISIONALES, y un dato provisional no frena la operación. Si un día el perfil se toma de los documentos del buque, se reconsidera.
- **10.23, la pestaña de Chrome autorizada por Carlos: ratificada solo como último recurso.** Aplica a la app en la dirección local, con la autorización de Carlos en ese momento y la URL verificada.
- **10.24, el codec de Firestore: ratificada.**
  - Firestore no admite listas dentro de listas.
  - `FirestoreProfileCodec`, en `firestore_operation_sync.dart`, convierte `covers` en un mapa numerado solo al viajar y valida la numeración al recibir. El dominio y Hive no cambian.
  - Queda como regla en 2.3.
  - El derivador trata `hatch_cover` en el mismo `switch` que descargas, cargas y correcciones. El tipo existe desde T-72 (`08a7dfa`, y 10.3).
- **10.32, `connecting` y `offline`: ratificada, con una observación para Timonel.**
  - El motor muestra «Sin conexión» solo después de haber visto el servidor una vez (`_connectionKnown`).
  - Un teléfono que arranca ya en modo avión muestra «Conectando…» mientras no llegue al servidor. Si tiene escrituras propias, pasa a «sin confirmar» a los 5 minutos.
  - Es veraz y no hay temporizador que adivine. Timonel lo observa en el Honor y, si se queda así, se declara como comportamiento conocido en T-98.

**Dos reglas nuevas en la sección 2:**
- **Nada de listas dentro de listas en lo que viaja a Firestore** (2.3). T-56 lo respeta si guarda las tomas por rangos como pares.
- **El volcado sanitizado del Honor es la práctica estándar** (2.4): `adb exec-out uiautomator dump /dev/tty`, en memoria y con los identificadores ocultos, como en T-89.
  - Responde a cuatro incidencias de la misma clase: T-81, T-84, T-89 y el diálogo de guardar contraseña.
  - Opcional para Carlos: que en el Honor de pruebas desactive él mismo la oferta de Google de guardar contraseñas.

**Tres reglas se reafirman:**
- **«Un comando de Flutter a la vez» sigue siendo regla dura.** Hubo dos avisos en el relevo (T-81 y T-102), sin daño. Con Timonel de vuelta, vale también entre agentes (2.10).
- **Las interrupciones largas de sesión no cambian nada.** Hubo cuatro: T-81, T-91, T-90 y el apagón de T-97. Las horas se descuentan como lo hizo el relevo.
- **El encabezado y el tablero son de Yov.** El relevo no los tocó, como estaba previsto.

**Horas.**
- Las once tareas del relevo suman ≈ 12.3 h de pared frente a 36.0 estimadas.
- Con la regla de 10.17, el encabezado baja de ≈ 179.8 a **≈ 156.1 h**.
- De esas, **111.0 h** son estimaciones de las doce tareas por hacer. 57 corresponden a la medición de RNF (T-98 y T-99), que no se comprime como el código.

**El Kanban se regeneró al 14-oct.** Se publicó en la misma página y se copió en `docs/`.

| Columna | Tareas | Horas estimadas |
|---|---:|---:|
| Terminado | 16 | 53.5 |
| En revisión | 12 | 42.0 |
| En curso | 0 | 0.0 |
| Por hacer | 12 | 111.0 |

El piso de pruebas es 648.

**Un endurecimiento que salió de la auditoría del relevo.**
- Las «21 bahías» de T-83 son un conteo verificado en pantalla en los tres clientes, pero ninguna prueba lo afirma.
- Timonel lo anota en su aceptación sin arreglarlo de paso.
- Se suma como caso de corpus, sobre A07 ∪ A08, en la próxima tarea que toque el perfil.

### 10.34 · La recta al 17-oct y el lote de Timonel · Tres decisiones abiertas de Carlos (14-oct)

**El 17-oct se presenta el Incremento 2 del Sprint 2,** con la rama principal congelada (2.2).
- **Los entregables ya existen,** con corte al 6-oct:
  - `docs/BayStream_Incremento2_Seguridad_Calidad.docx` (42 páginas, Tablas 77–90);
  - `docs/BayStream_Incremento2_Presentacion.pptx` (14 diapositivas).
- **Lo que falta:**
  - la revisión final de Yov;
  - la decisión de Carlos de abajo sobre el avance del Sprint 3;
  - el índice, que Carlos genera en Word.

**El orden de trabajo:**
1. **14-oct, tarde y noche: Codex hace T-92** (la Web sin conexión), con ficha completa que escribe Yov antes.
2. **15-oct: Timonel hace la aceptación en lote de las doce,** con el contexto y el prompt de `docs/LOTE-TIMONEL.md`. Mientras Timonel corre Flutter, Codex no.
3. **16-oct:**
   - **Codex:** T-93, el instalador de Windows (la herramienta la autoriza Carlos antes), y la parte de código de T-88: el enlace a la política, el ícono propio y D3 en el manifest.
   - **Yov:** el texto de la política de privacidad y las declaraciones de Play, sobre `docs/T64-DECLARACIONES-PLAY.md` y `docs/T65-RESULTADOS.md`. Tienen que cubrir la sincronización, el micrófono opcional, la voz que procesa el servicio del sistema o del navegador, y D3. Además, la revisión final del Incremento 2.
4. **17-oct: la presentación.** Nada se publica antes.
5. **Del 18 al 21-oct:**
   - Carlos mezcla `sprint-3` en la rama principal cuando el lote de Timonel esté aceptado, y publica la Web (con T-92) y la prueba interna de Play (con T-88).
   - Yov transcribe las tablas 7.2.4 y 7.4.3.2 del IMDG 42-24 y T-85 pasa a Codex.
   - La Ola 6: T-56, T-96 y T-95, y T-103 si Carlos la aprueba.
6. **Del 21 al 24-oct, el cierre:**
   - T-98 y T-99, los RNF;
   - T-100, el manual y la presentación final;
   - T-101, si COMAR da permiso;
   - la entrega del 24-oct.

**Si falta tiempo, se corta desde abajo (4.2):** primero el piloto, después RF-028 y RF-029, y luego la segunda parte de RNF.

**Tres decisiones de Carlos, abiertas.** Yov las preguntó el 14-oct y quedan escritas con su recomendación:
- **A06, que es SMDG15:**
  - leerla con un aviso visible: «Versión 1.5, leída con las reglas de 2.x; revisa pesos y peligrosas». Sería T-103, de ≈ 1 h, después del 17-oct (recomendado);
  - o mantener el rechazo.
- **D3, el respaldo automático de Android:**
  - desactivarlo (recomendado). La nube ya respalda lo publicado, se evita restaurar una sesión o una bitácora vieja en otro teléfono, y la política queda más simple. Es una línea del manifest dentro de T-88;
  - o dejarlo activo y declararlo.
- **El Incremento 2:**
  - sumar una diapositiva final y un párrafo en Conclusiones con lo que ya funciona en `sprint-3`, como trabajo en curso y sin tocar resultados ni tablas medidas (recomendado);
  - o dejarlo como está.

**Siguen bloqueadas:** T-87 espera un BAPLIE 3.1 real, y T-101 el permiso de COMAR.

**Yov sigue en un chat nuevo.** Su arranque está en `docs/ARRANQUE-YOV.md`.

### 10.35 · Carlos decide A06, D3 y el Incremento 2 · Nace T-103 · La transcripción del IMDG, precisada (14-oct)

**Las tres decisiones abiertas de 10.34, tomadas por Carlos con la recomendación de Yov:**
- **A06 (SMDG15) se lee con aviso. Nace T-103** (BAP, 1.0 h, Codex, después del 17-oct).
  - El lector acepta `SMDG15` además de la familia 2.x y muestra un aviso visible: «Versión 1.5, leída con las reglas de 2.x; revisa pesos y peligrosas».
  - El resto de la 1.x y la 3.x se siguen rechazando como en T-86, que se acepta tal como se construyó.
  - **Terminada cuando** A06 vuelve a abrir con sus cifras de antes de T-86 y con el aviso, y los corpus que hoy exigen su rechazo pasan a exigir la lectura con aviso.
- **D3: el respaldo automático de Android se desactiva.** Va dentro de T-88: `android:allowBackup="false"` y las reglas de extracción de datos que pida el SDK de destino, sin respaldo en la nube ni transferencia entre dispositivos. Las declaraciones de Play y la política dicen que el almacén local no se respalda.
- **El Incremento 2 suma el avance del Sprint 3:** una diapositiva final y un párrafo en Conclusiones con lo que ya funciona en `sprint-3`, declarado como trabajo en curso, sin tocar resultados, tablas ni cifras medidas. Lo hace Yov el 16-oct.

**La transcripción del IMDG todavía no existe y es tarea de Yov.** Lo verificó el relevo: ni el repositorio ni `baystream-privado` tienen un archivo del IMDG ni de transcripción.
- **La fuente.** En `C:\Proyectos\baystream-privado\` hay dos archivos del IMDG: el extracto Word de la edición 2012, descartado (sección 9 del caso), y el **PDF de 18 páginas en imagen de la Enmienda 42-24**, que es de donde se transcribe.
- **Se transcribe de esas páginas,** nunca de memoria ni de otra edición (sección 8).
- **La transcripción vive en `baystream-privado`, no en el repo.** El repositorio es público, y las tablas 7.2.4 y 7.4.3.2 son material con derechos de la OMI. Al repo solo entran los casos sintéticos de prueba que derive T-85, igual que las páginas originales nunca entraron.
- **Cómo la lee Yov sin abrir lo demás de esa carpeta.** Carlos copia el PDF a una subcarpeta propia (por ejemplo `baystream-privado\imdg\`) y conecta solo esa, o lo adjunta al chat. La transcripción se guarda en esa misma subcarpeta.
- **Una pregunta de diseño para la ficha de T-85:** cómo llega la matriz al código sin publicarla en el repo. Puede ser un archivo privado que se lee al compilar, como las opciones de Firebase, aunque entonces viaja dentro de la app publicada; o puede bastar con los códigos de segregación como dato funcional. Yov la propone en la ficha y decide Carlos.

**El sprint pasa a 41 tareas y ≈ 157.1 h.** El tablero suma T-103 en Por hacer, con 207.5 h estimadas.

### 10.36 · T-92 entregada, en revisión: la Web arranca sin red tras una visita · Carlos acepta las dos decisiones de su ficha · Carlos elige MSIX para T-93 (14-oct)

**T-92, de Codex, pasa a En revisión** (commit `26bbfca`). Su aceptación cruzada la hace Timonel aparte, después del lote.

- **Lo construido.**
  - Una plantilla propia, `web/flutter_bootstrap.js`, toma CanvasKit y las fuentes de rutas propias, relativas a `<base>`.
  - Firebase JS **12.17.0**, la versión que exige `firebase_core_web 3.10.0`, se sirve desde `web/vendor/firebase/12.17.0/`. El `import` absoluto de `firebase-app.js` pasó a relativo.
  - Los tres globales quedan puestos antes de `initializeEngine`.
  - El service worker de Flutter va tal cual.
  - Las fuentes servidas son las que pidió el recorrido completo: Roboto v32, Noto Sans Symbols v43 y Noto Sans Symbols 2 v24.
  - «BayStream» y `lang="es"` en `index.html` y en el manifiesto.
- **Un defecto propio, hallado y corregido en la aceptación.**
  - El primer intento en el Honor no recargó sin servidor. El worker de Flutter guarda `index.html`, pero su `onlineFirst` busca la raíz `/`, y la primera navegación todavía no tenía controlador.
  - La corrección: la plantilla hace una sola petición a `./` cuando el worker ya controla la página, y el mismo worker la guarda. No se tocó el worker ni se precarga el sitio.
- **El inventario, en Chrome visible y con el mismo recorrido** (A07, los dos temas y el PDF):
  - HEAD pidió **ocho recursos de código o fuentes** fuera del sitio: CanvasKit, tres fuentes y los tres módulos de Firebase. T-92 no pidió **ninguno**.
  - Con la sesión de muelle abierta, solo quedan los servicios de datos: `identitytoolkit.googleapis.com` y `firestore.googleapis.com`.
- **Arranque sin red tras una visita.** El servidor se detuvo y una CSP del servidor de prueba bloqueó a los terceros, sin tocar la red de la máquina.
  - Pasó en tres casos: Chrome de la laptop en un origen nuevo, Chrome en incógnito (manual de Carlos) y Chrome del Honor en modo avión y con el Wi-Fi apagado.
  - En los tres, A07 se reabre desde Recientes con 398 contenedores, 21 bahías, `6940.6 t` en pantalla (6 940 578 kg en el corpus) y 0/114/284 en GTSTC, sin recuadros.
- **La sincronización con el SDK servido**, sobre «PRUEBA T-84» y con la sesión de muelle que inició Carlos:
  - los mismos conteos que con HEAD: 4 contenedores, 3 bahías, 20.0 t y 0/3/1 en GTSTC;
  - «Al día», luego «Conectando…» al bloquear a Firebase, y otra vez «Al día» al quitar el bloqueo;
  - sin movimientos y sin publicar nada.
- **La actualización:** la compilación 93 reemplazó a la 92 con una visita con red, y sin servidor abrió la 93.
- **Validaciones.** **655 pruebas** (el piso nuevo; 7 nuevas), `analyze` en cero, corpus **116/116** y los verificadores del sitio compilado en verde.
  - **126 archivos protegidos** guardan el mismo SHA-256: los 122 de `lib/`, `pubspec.*`, la propuesta de reglas y `firebase.json`.
  - Sin dependencias nuevas: el verificador usa `crypto`, que ya era directa.
- **La revisión del commit.**
  - Las 21 rutas son las del informe, y todas están en el carril de la ficha: `web/`, `test/t92_web_test.dart`, `tool/t92_server.dart`, `tool/t92_verify.dart` y el informe.
  - No toca `lib/`, `main.dart`, `pubspec.*`, las reglas, `firebase.json` ni los congelados.
  - El diff no trae claves, correos ni UID, y en los módulos servidos no queda ninguna URL `gstatic.com/firebasejs`.
  - El servidor de prueba escucha solo en `127.0.0.1`.
  - No se rastreó nada del corpus. La copia de A07 en el teléfono se borró, y se comprobó.
- **Horas.** ≈ 1.2 h activas frente a 3.0, descontando una pausa por el límite de sesión. El encabezado baja de ≈ 157.1 a **≈ 155.3 h** (regla de 10.17).
- **Observaciones, que no son defectos:**
  - En la primera visita, el favicon y el manifiesto se piden antes de que el worker controle la página, y no quedan guardados. Sin red dan un error de consola, y la app abre igual. No se promete instalarla como PWA sin red.
  - Si un navegador no activa el worker, la plantilla espera hasta 4 s antes de seguir, y sin red esa página no arranca: queda en blanco, como antes de T-92. Va a T-98 como límite declarado, junto con «la primera visita necesita red».
  - La consola del Honor no se pudo inspeccionar con estas herramientas, y el informe no la da por revisada.
  - La pérdida de conexión de Firebase se simuló bloqueando a los terceros con la CSP de prueba, no cortando la red. El arranque lo cubre el Honor en modo avión.

**Carlos acepta las dos decisiones de diseño de la ficha (14-oct, 14:48):**
- **El SDK de Firebase entra al repo público**, con su licencia Apache 2.0 y su origen.
  - **Su condición:** cada vez que se actualice `firebase_core_web`, se actualiza también la copia.
  - La prueba «T-92 SDK servido coincide con los paquetes resueltos» ya lo hace cumplir: si `pubspec.lock` trae otra versión del paquete y falta su carpeta en `web/vendor/firebase/`, `flutter test` falla.
  - Queda como regla en 2.7.
- **Un carácter fuera de las fuentes servidas, como un emoji, sale como un recuadro**, también con red. Los acentos y la «ñ» están en Roboto, y en una app de operación los emojis son raros. Va a T-98 como límite declarado.

**La publicación de la Web** sigue en manos de Carlos, después del 17-oct y del lote de Timonel, con el bloque y la comprobación de cinco minutos del informe de T-92. El bloque compila limpio en `build/web`, así que desaparecen los `t54-format.*` viejos.

**Carlos elige MSIX, con el paquete `msix`, para el instalador de Windows de T-93 (14-oct).**
- Yov recomendaba Inno Setup y advirtió del almacén aislado. Carlos eligió MSIX sabiéndolo.
- **Queda autorizada la dependencia de desarrollo `msix`**, con versión fija y sin mover ningún paquete existente (2.7).
- **Lo que trae MSIX, y que la ficha de T-93 resuelve:**
  - el paquete se firma;
  - cada PC confía una vez en el certificado;
  - el almacén local de la app instalada vive en la carpeta privada del paquete: se conserva al actualizar y se borra al desinstalar.
- **El certificado lo crea Carlos**, autofirmado y en su almacén de usuario de Windows, con la clave no exportable. Al repo no entra ningún secreto.

**El lote de Timonel parte del piso del último informe** (`docs/LOTE-TIMONEL.md`): 655 con T-92, o el de T-93 cuando esté commiteada. La aceptación de T-92 va aparte, después del lote.

**Timonel vuelve antes de lo previsto (14-oct, 18:00), y Carlos le da T-93.**
- **T-93 pasa a Timonel** con ficha completa (sección 5, Ola 5), en cuanto Carlos cree el certificado. Su aceptación cruzada la hace Codex, después.
- **Después de T-93, Timonel hace el lote de las doce** (`docs/LOTE-TIMONEL.md`), y por separado la aceptación de T-92.
- **Codex queda libre del carril esta noche.** El 16-oct toma la parte de código de T-88, con su ficha, y acepta T-93.

### 10.37 · T-93 entregada, en revisión: el instalador MSIX firmado · Dónde guarda los datos la app instalada depende de si la carpeta ya existía · Corrección de 10.36 (14-oct)

**T-93, de Timonel, pasa a En revisión** (commit `25dbee5`). La acepta Codex, después del lote.

- **Lo construido.**
  - `msix 3.18.0`, fija, como dependencia de desarrollo. El lock suma solo `msix`, `cli_util 0.5.0`, `console 4.1.0` y `get_it 9.3.0`, sin mover nada existente.
  - `msix_config`, sin secretos: `CN=BayStream`, `gt.cmartinez.baystream`, solo `internetClient`, `build_windows: false` e `install_certificate: false`.
  - `tool/t93_msix.ps1` compila Release con las opciones de Firebase, arma el paquete y lo firma por la huella (`/fd SHA256 /sha1`). Falla si la firma no es de esa huella.
  - Cinco pruebas fijan esa configuración.
- **La aceptación**, sobre un almacén limpio salvo el primer arranque:
  - el paquete 1.0.0.0 se instala y abre desde Inicio con Firebase;
  - A07 da 398/21/`6940.6 t`/0-114-284 y se conserva al cerrar por PID;
  - «PRUEBA T-84» llega a «Al día» con 4/3/`20.0 t`/0-3-1, sin movimientos;
  - la 1.0.1.0 se instala encima y conserva el viaje, Recientes y la sesión;
  - la desinstalación quedó documentada.
  - Se instaló con `Add-AppxPackage`. El doble clic con App Installer no se probó.
- **Un criterio no pasa tal como estaba escrito: «el almacén real con la misma huella».**
  - El primer arranque escribió en `%LOCALAPPDATA%\BayStream`, en el namespace por defecto `baystream`, que pasó de 283 a 288 archivos: la operación y el viaje de A07, el perfil, los ajustes, la copia local del operador y cuatro `.lock`. A07 desplazó de Recientes al viaje más viejo de BUQUE GOLF.
  - Los namespaces de las aceptaciones quedaron idénticos.
  - Timonel se detuvo y avisó. Con el método que indicó Yov (copia en `%TEMP%`, renombre y devolución), hizo el resto sobre un almacén limpio. El real quedó idéntico a como estaba después del primer arranque (`6F6E95EB…`).
  - **El criterio y su supuesto eran de Yov, no un defecto de T-93.**
- **La causa, comprobada:** la regla de Windows 1903+ para el `AppData` de las apps empaquetadas. Solo se redirige lo que se crea nuevo; lo que ya existe se lee y se modifica en la ubicación real. El manifiesto no trae `unvirtualizedResources`.
- **Corrección de 10.36, y de lo que Yov dijo en el chat a las 18:26:**
  - **En una PC sin BayStream previo**, como la de la oficina y la del piloto, el almacén vive en la carpeta privada del paquete (`…\Packages\gt.cmartinez.baystream_…\LocalCache\Local\BayStream`). Se conserva al actualizar y **se borra al desinstalar**: antes de desinstalar hay que sincronizar hasta «Al día».
  - **En una PC que ya tenía `%LOCALAPPDATA%\BayStream`**, por una copia de `Release` como en la laptop de Carlos, el paquete usa esa carpeta, la modifica y no la borra.
  - La caché de Firestore (`%LOCALAPPDATA%\firestore`) sigue la misma regla.
  - La sesión de Firebase vive en el Administrador de credenciales de Windows. La comparten la app instalada y la sin instalar, y queda después de desinstalar.
  - Las instrucciones para una PC de oficina del informe (sección 7) ya lo dicen, y pasan al manual (T-100).
- **Un hallazgo de proceso.**
  - La consola de un agente empaquetado (Claude Code o Codex de escritorio) ve el almacén mezclado con la copia de su propio paquete: Timonel contó 297 archivos donde había 283.
  - Por eso las huellas del almacén real se toman fuera del paquete, con un `.bat` lanzado por `explorer.exe`.
  - **Queda como regla en `AGENTS.md`**, junto a la de abrir la app con `explorer.exe` (10.9).
- **En la laptop de Carlos, la app quedó desinstalada.** Si la instala, va a usar y modificar su almacén real. Para usarla, mejor una PC sin la app previa, o apartar antes la carpeta.
- **Los cinco archivos del primer arranque** se quedan en el almacén real. Carlos decide antes del piloto si limpia ese almacén (10.13).
- **Fuera de la tarea, para el piloto (T-101) y el manual:**
  - el doble clic con App Installer;
  - Windows 10 en una PC de COMAR;
  - el sello de tiempo de la firma. Sin él, el paquete se instala mientras el certificado esté vigente, que son tres años.
- **Validaciones.** **660 pruebas** (el piso nuevo; 5 nuevas), `analyze` en cero y corpus **116/116**.
  - 124 archivos protegidos guardan el mismo SHA-256: los 122 de `lib/`, `firestore.rules` y `firebase.json`.
  - Los congelados no difieren de `m2-baseline`.
- **La revisión del commit.**
  - Las 5 rutas son las de la ficha: `pubspec.yaml`, `pubspec.lock`, `tool/t93_msix.ps1`, `test/t93_msix_config_test.dart` y el informe.
  - No toca `lib/`, `windows/`, `main.dart`, las reglas ni los congelados.
  - No hay `.pfx`, contraseña ni ruta de certificado. La huella del certificado está en el informe y no es secreta.
  - El `.msix` y las evidencias quedan en `build/t93/`, que no se versiona.
- **Horas.** ≈ 0.9 h frente a 2.5. El encabezado baja de ≈ 155.3 a **≈ 153.7 h**.

**El orden desde aquí:**
1. **Timonel hace el lote de las doce** en un chat nuevo (`docs/LOTE-TIMONEL.md`, piso 660). Mientras corre, nadie más usa la app de Windows ni aparta el almacén real.
2. Después, Timonel acepta T-92 por separado.
3. **Codex acepta T-93 después del lote,** con el almacén real apartado, y toma la parte de código de T-88 (16-oct).

### 10.38 · El lote de Timonel: once tareas a Terminado y T-94 no pasa · Un corpus escribía en el almacén real · Nace T-104 (15-oct)

**Timonel cerró la aceptación en lote** (commit `c1e31ea`, `docs/LOTE-TIMONEL-RESULTADOS.md`).
- Trabajó en dos sesiones, el 14-oct de 18:43 a 19:58 y del 14-oct a las 23:38 al 15-oct a las 00:15, sin contar la pausa por el límite de uso: ≈ 1.9 h de pared.
- **Las comprobaciones globales,** al empezar y al terminar:
  - **660/660**, `analyze` en cero, corpus **116/116** y reglas **69/69** con el mismo SHA;
  - las dependencias, las que se esperaban;
  - los congelados, iguales a `m2-baseline`.

**Pasan a Terminado once tareas:**
- **Aceptadas sin observación: T-80, T-81, T-82, T-84, T-86, T-90, T-91 y T-102.**
  - **T-82** con un cotejo independiente en Python, sin el lector de BayStream: 460/460 en siete campos.
  - **T-84:** el codec funciona en Windows, el Honor y Chrome, con las tapas en 3/0/2.
  - **T-102:** 398 celdas y 33 páginas, en color.
- **Aceptadas con observación:**
  - **T-83:** ninguna prueba afirma las 21 bahías (el endurecimiento de 10.33 pasa a T-56), y el editor dice «Copiado a 1 bahías» (T-104).
  - **T-89:** la pantalla inicial todavía lista extensiones (T-104).
  - **T-97:** los ocho puntos pasan con la letra al 2.0, pero fuera del catálogo se cortan las pestañas y las tarjetas, y aparece «1 bahías» en Recientes (T-104).
- **La observación de 10.33, en el Honor:** arrancado ya sin red, muestra «Conectando…» durante 40 s sin pasar a «Sin conexión», y «Al día» unos 3 s después de devolver el Wi-Fi.
  - Es el comportamiento que describió 10.33: veraz y sin temporizador que adivine.
  - Queda declarado como comportamiento conocido para T-98.

**T-94 no pasa por un criterio: sin red, la voz se apaga sin avisar** (3 de 3 intentos en modo avión). Todo lo demás pasa: el borrador, la búsqueda manual, 242/242 y el manifiesto.
- Yov lo confirmó en el código: `onDone` cierra la sesión con `_cancel()` y deja sin destino a `_failure`. Si el plugin manda `done` antes que el error, el aviso se pierde.
- **T-94 vuelve a En curso,** para una corrección de Codex que está al final de su ficha. Timonel vuelve a comprobar solo ese criterio.

**En producción:** con la autorización de Carlos en ese momento, la oficina registró dos movimientos en «PRUEBA T-81», el `cancel_item` y el `annul` del OR 5. Su efecto neto es cero, y la operación queda con 6 registros. No se publicó nada.

**Un hallazgo que cambia una práctica: `tool/block3_corpus_test.dart` escribe en el almacén real de Windows** en cada corrida.
- Suma ≈ 173 KB a `baystream_operations.hive` del namespace por defecto.
- Timonel lo aisló corriendo los 31 corpus uno a uno: solo cambia con `block3`.
- **La consecuencia:** una huella «antes» del almacén real tomada después de correr el corpus no sirve.
  - Las conclusiones de T-93 siguen en pie, porque la prueba decisiva fue la del almacén apartado.
  - Pero el salto de 283 a 288 archivos pudo incluir una corrida del corpus.
- **Regla, hasta que T-104 lo corrija:** quien tome una huella del almacén real no corre el corpus completo entre el «antes» y el «después». Si lo corre, la toma de nuevo.

**Nace T-104** (2.0 h, Codex, ficha completa en la Ola 6). Junta las deudas del lote:
- aislar `block3`, con una salvaguarda: bajo `flutter test`, Windows nunca devuelve el almacén real;
- «1 bahías» en dos sitios;
- la pantalla inicial que lista extensiones;
- los cortes a 200 % en las pestañas y las tarjetas.

**El sprint pasa a 42 tareas y ≈ 155.7 h.** El tablero suma T-104 en Por hacer: 42 tarjetas y 209.5 h.

**Una incidencia menor, de Timonel:** ejecutó `git rev-parse --abbrev-ref HEAD`, que no está entre las lecturas permitidas. Solo lee y no toca el índice. La lista no cambia.

**El Honor quedó con la letra en 2.0.** Conviene dejarla así hasta que Codex termine T-104, que la necesita, y después devolverla a 1.0.

**El orden desde aquí:**
1. **Codex:** la corrección de T-94 y después T-104, con dos commits. El 16-oct, la aceptación cruzada de T-93 y la parte de código de T-88.
2. **Timonel:** la aceptación de T-92. Después vuelve a comprobar la corrección de T-94 y acepta T-104.
3. Un comando de Flutter a la vez, y el Honor y la app de Windows por turnos: Carlos da el semáforo.

### 10.39 · T-92 terminada: Timonel la acepta con una observación · Tres cosas más para T-104 · El modo avión del Honor no siempre apaga el Wi-Fi (15-oct)

**T-92 pasa a Terminado.** Timonel la aceptó con una observación (commit `f313be0`, `docs/T92-ACEPTACION-RESULTADOS.md`).
- Trabajó sobre una copia exacta de HEAD (`5163654`), porque Codex tenía cambios a medias en `lib/` y `test/`. Es la práctica correcta.
- **El verificador,** sobre una compilación limpia: 48 archivos y 35 680 304 bytes.
- **El inventario,** con A07 en los dos temas y el PDF: 18 URL y **ninguna externa**. Lo confirma también el registro de red de Chrome.
- **Sin red, tras una visita:**
  - en la laptop, con la CSP de prueba y el servidor detenido;
  - en el Honor, en modo avión, con el Wi-Fi apagado y sin red comprobada;
  - en los dos, 398 contenedores, 21 bahías, `6940.6 t` y 0/114/284, sin recuadros.
- **«PRUEBA T-84»:** «Al día» → «Conectando…» → «Al día», con 4/3/`20.0 t`/0-3-1 y sin movimientos. Carlos inició la sesión y autorizó el «Unirse».
- **Las pruebas:** 660/660, con las 7 de T-92, y `analyze` en cero.
- **El SDK:** la versión 12.17.0 es la que pide `firebase_core_web`. Los módulos son los originales de `gstatic` con una sola sustitución, comprobado con SHA y byte a byte.
- **La observación:** el `LEEME` del SDK dice que la URL se reemplazó «en comentarios», y en `firebase-app.js` son dos literales de código (`name$q` y `Logger`). El efecto es nulo; la frase se corrige en T-104.

**Dos hallazgos fuera de T-92, que pasan a T-104** (suma 0.5 h y queda en 2.5 h):
- **Una prueba intermitente:** «guardar viajes simultáneamente también respeta cinco» falla 1 de 3 en la suite completa y pasa 10 de 10 sola.
  - Usa un directorio temporal, así que no es el almacén real.
  - Una prueba intermitente amenaza el piso: se corrige, nunca se marca `skip`.
- **Dos `// ignore: avoid_print`** en `bay_plan_view.dart`, desde `bb28784` (mayo). Contradicen la línea base de `CLAUDE.md` («sin ningún `// ignore:`»). El lote también los había visto.
  - Se quitan los dos `print`, que son registros de depuración de la leyenda.
- **Codex ya estaba con T-104** cuando nació esto. Carlos le pasa el añadido, que está al final de la ficha de T-104.

**Una regla nueva de prueba, en `AGENTS.md`:**
- En el Honor, el modo avión puede dejar el Wi-Fi encendido (`wifi_on=2`).
- Una prueba sin red comprueba que de verdad no hay red: el Wi-Fi apagado y un `ping` que falla. Y lo anota.

**Un choque de proceso, sin daño:** Codex usó el Honor durante la prueba de Timonel, y se lo cedieron. El Honor es de un solo usuario a la vez (`AGENTS.md`, «Trabajo en paralelo», regla 5): el turno lo da Carlos con el semáforo.

**El sprint queda en 42 tareas y ≈ 156.2 h,** por la media hora que suma T-104. El tablero suma 210.0 h: 28 terminadas, T-93 en revisión, T-94 en curso y 12 por hacer.

**Lo que sigue:**
- **Codex:** termina la corrección de T-94 y T-104, con el añadido. El 16-oct, acepta T-93 y hace la parte de código de T-88.
- **Timonel:** vuelve a comprobar el criterio de T-94 y acepta T-104.

### 10.40 · La corrección de T-94 y T-104, entregadas y en revisión · La regla del corpus de 10.38 se levanta · Una falla real de Windows al compactar (15-oct)

**La corrección de T-94, de Codex** (commit `cae798e`, sección «Corrección del 15-oct» de `docs/T94-RESULTADOS.md`). **T-94 vuelve a En revisión.**
- **El mecanismo:**
  - al recibir `done`, el campo apaga el indicador y conserva 500 ms los avisos de esa escucha;
  - un error que llegue antes o durante ese intervalo muestra su aviso;
  - si la escucha termina sin texto y sin error, dice «No se entendió el dictado. Reintenta o escribe la búsqueda.»;
  - editar, confirmar, cerrar o empezar otra escucha anula los avisos viejos;
  - nada se busca solo.
- **Las pruebas:** 8 nuevas, que cubren los tres órdenes y los avisos tardíos. **668/668**, `analyze` en cero, corpus **116/116** y 242/242.
- **El Honor sin red** (modo avión, Wi-Fi apagado y un `ping` sin red), 3 de 3: el aviso aparece debajo de Buscar.
  - Carlos lo tomó al principio por ausencia de aviso, porque esperaba una ventana emergente; el XML muestra el texto.
  - Con red, los dos dictados quedan como borrador.
- **Una observación, sin defecto:** sin red, el aviso a veces dice «Reconocimiento en español no disponible…» en vez de «…sin conexión…».
  - Es lo que informa el reconocedor de Android cuando no tiene el idioma sin conexión, y el texto invita a escribir.
  - Queda declarado; no se cambia.
- **Timonel vuelve a comprobar solo este criterio.**

**T-104, de Codex, pasa a En revisión** (commit `bf3a2cf`, `docs/T104-RESULTADOS.md`).
- **`block3` aislado:**
  - `tool/block3_corpus_test.dart` usa también una bitácora temporal;
  - bajo `flutter test`, `localStoreDirectory()` en Windows falla con un mensaje claro antes de tocar `LOCALAPPDATA`;
  - ninguna otra prueba dependía del almacén real;
  - dos corridas seguidas de los 31 corpus dejan la huella del almacén real idéntica: 313 archivos, tomada fuera del paquete con `.bat` lanzados por `explorer.exe`.
- **Los textos:**
  - «1 bahía» en Recientes y en el editor de tapas;
  - el inicio explica que se valida por contenido, sin listar extensiones;
  - las pestañas se desplazan;
  - las tarjetas de Lista y del contenedor no se cortan a 200 %, con pruebas a la escala medida en el Honor.
  - **Una precisión de la ficha:** son tres pestañas (Lista, Bay Plan y Estadísticas); Avance es una pantalla aparte.
- **La prueba intermitente era una falla real de Windows:** el sistema puede negar un instante el renombrado con que Hive compacta un archivo (error 5, acceso denegado).
  - `compactLocalStore` reintenta solo la compactación, hasta cinco veces y con espera creciente. En otras plataformas no cambia nada.
  - El orden de los recientes ya era correcto.
  - **Cinco suites seguidas en verde.** Arreglarlo también protege a la app de oficina, que pudo fallar al guardar un viaje.
- **Lo demás:**
  - los dos `print` de `bay_plan_view.dart` se quitaron, y no queda ningún `// ignore` en `lib/`;
  - el `LEEME` del SDK quedó corregido, sin cambios en los módulos ni en su procedencia.
- **Validaciones.** **685 pruebas** (el piso nuevo; 17 nuevas), `analyze` en cero y corpus 116/116 en dos corridas.
  - Las reglas, el SDK, `main.dart`, `pubspec.*` y los congelados no cambian.
  - Sin dependencias ni movimientos.
  - Los clientes revisados son el Honor `.t104` a 360 dp con la letra en 2.0, Windows y Chrome.
- **La revisión del commit.**
  - Las 19 rutas son las del informe.
  - Los cambios en `data/` son la salvaguarda y el reintento de compactación, ambos dentro del carril que autoriza la ficha («si el defecto está en el repositorio, se corrige ahí»).
  - No hay claves, correos ni UID.
- **Horas.** ≈ 1.25 h frente a 2.5. El encabezado baja de ≈ 156.2 a **≈ 155.0 h**.

**La regla de 10.38 se levanta:** con `block3` aislado y la salvaguarda, correr el corpus ya no toca el almacén real. Lo que sigue en pie son las huellas fuera del paquete del agente (`AGENTS.md`).

**El Honor** puede volver a la letra 1.0 cuando Timonel termine de aceptar T-104.

**El orden desde aquí, sin solaparse, porque los dos tocan el almacén real de Windows:**
1. **Timonel:** vuelve a comprobar la voz sin red de T-94 y acepta T-104.
2. **Codex:** después, la aceptación cruzada de T-93, apartando el almacén real como en 10.37. Luego, la parte de código de T-88, con su ficha.
