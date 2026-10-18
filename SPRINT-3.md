# BayStream · Sprint 3 — instrucciones de implementación

**Ventana:** 7 → 24 de octubre de 2026 · **47 tareas · ≈ 168.0 h estimadas** (al 17-oct, 10.81) · rama **`sprint-3`**
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

#### T-103 · Leer la 1.5 (SMDG15) con un aviso visible · 1.0 h · Timonel (ficha completa, 15-oct; adelantada en 10.41)

**Para qué.** BAP. Carlos decidió en 10.35 no descartar las versiones anteriores, porque
alguna línea todavía puede mandar una 1.x. A06 del corpus es una SMDG15 real
(`BAPLIE:1:911:UN:SMDG15`):
- hasta T-86 se leía;
- desde T-86 se rechaza en el `UNH`;
- T-103 la vuelve a leer, avisando que se interpretó con las reglas de 2.x.

**Lo que hay hoy.**
- T-86 (`1b1be4b`) rechaza toda versión fuera de SMDG20, 21 y 22.
- Para eso adaptó 43 rutas: las pruebas y los corpus que leían A06 pasaron a exigir el
  rechazo tipado (`requireA06Rejection`), y el bloque 7 pasó a 33 DGS y 29 unidades
  peligrosas sin A06.
- El detalle está en `docs/T86-RESULTADOS.md`.

**Qué construye.**
1. **El lector acepta `SMDG15`** además de la familia 2.x. El resto de la 1.x, la 3.x y lo
   que no tiene `UNH` se siguen rechazando como en T-86, con el mismo mensaje.
2. **Un aviso visible**, mientras ese viaje esté abierto: «Versión 1.5, leída con las reglas
   de 2.x; revisa pesos y peligrosas».
   - Va en el resumen del viaje, no solo en un aviso pasajero.
   - Si el viaje se reabre desde Recientes, el aviso sigue ahí.
3. **El BAPLIE de salida de T-82 no se genera desde una fuente 1.5.** La acción lo dice con
   claridad: escribir una 1.5 con reglas de 2.x no sería fiel a lo que llegó.
4. **Las pruebas y los corpus que hoy exigen el rechazo de A06 pasan a exigir la lectura con
   aviso**, con las cifras de antes de T-86.
   - Esas cifras se toman de la historia (`1b1be4b^`), no de memoria.
   - El bloque 7 vuelve a contar la declaración DGS que aportaba A06, si así era.
   - Las pruebas de rechazo pasan a una 1.x sintética distinta de la 1.5.

**Fuera de alcance:**
- leer la 3.1 (T-87);
- cambiar las reglas de interpretación;
- cualquier cambio de nube o reglas de Firestore.

**Terminada cuando:**
- [ ] **A06 abre con las cifras de antes de T-86 y con el aviso** en los tres clientes, y lo
      conserva al reabrirla desde Recientes.
- [ ] **Una 1.x sintética distinta de la 1.5**, `t86_smdg31` y `t86_sin_unh` se siguen
      rechazando con el mensaje de T-86, y conservan el viaje anterior.
- [ ] **Las nueve fuentes 2.x salen idénticas**, con la referencia completa de T-86: bahías,
      contenedores, reservas y metadatos.
- [ ] **Desde una fuente 1.5, la salida de T-82 se niega** con un mensaje claro.
- [ ] **Validaciones:** piso de 685 más las nuevas, `analyze` en cero, corpus completo en verde
      con los conteos declarados, y las reglas sin cambio.

#### T-85 · La segregación con el Código IMDG 42-24: el cuadro de 7.2.4 por clase y las distancias de 7.4.3.2 a bordo · 10.0 h · Timonel (ficha completa, 15-oct)

**Para qué.** ERS, RF-027. Hoy la segregación usa un subconjunto de 49 CFR Parte 176 (T-41): 18 números ONU y 7 clases, y declara que no es el IMDG. La transcripción del IMDG 42-24 ya existe y está verificada (10.60): dos lecturas a ciegas, de Yov y de Gru, coinciden en 348 de 349 celdas, y Carlos resolvió la única diferencia mirando el PDF. T-85 pasa el validador a la norma que gobierna la operación real.

**Las decisiones de Carlos (10.60):**
- **Solo los códigos van al código.** La matriz de 7.2.4 (1 a 4, X y \*) y las exigencias de 7.4.3.2 entran como datos en Dart, sin copiar texto del IMDG. Los mensajes van en palabras de BayStream y citan el apartado («IMDG 42-24, 7.2.4»). Las pruebas corren sin archivos privados.
- **La transcripción vive en `C:\Proyectos\baystream-privado\imdg\`,** nunca en el repo: `yov_7-2-4.csv`, `yov_7-4-3-2.csv`, `yov_notas.txt` y `cotejo_imdg_yov_gru.txt`. Un comprobador fuera de la suite la compara con los datos del código.

**Lo que hay hoy (Yov lo revisó en el repo, 15-oct):**
- **`segregation_rules.dart`** es 49 CFR:
  - 18 números ONU con su perfil (`unProfiles`), 7 clases y 4 códigos (`substance`, `away`, `separated` y `compatibility`), con una cita por par;
  - y el aviso `SegregationRules.disclaimer`.
- **`dangerous_goods_validator.dart`** recorre las DGS de cada contenedor (`ContainerUnit.dangerousGoods`, con clase, número ONU y etiquetas) y evalúa cada par.
  - **Mide por huecos, no en metros:** en sentido longitudinal, huecos de 20 pies por número de bahía (`longitudinalGap`); en sentido transversal, filas (`lateralGap`), con la fila 00 solo si se declara o se observa.
  - **Lo que no sabe,** como los mamparos o la resistencia de las cubiertas, lo deja en «no evaluado».
- **`ContainerUnit.containerType`** sale del tercer carácter del ISO: G, R, U (techo abierto), P (plataforma), T (tanque) y B.
- **Lo muestran** `segregation_page.dart` y `stowage_alerts_page.dart`.
- **Dependen de esto:**
  - `test/dangerous_goods_validator_test.dart`;
  - en `tool/`: `block7b_corpus.dart`, `block7_checks.dart`, `t42_aceptacion.dart`, `t55_fila_central.dart`, `t55_tabla_segregacion.dart` y `t55_trazas.dart`.

**Qué construye.**

1. **Los datos del IMDG, como códigos,** en un archivo de dominio propio:
   - **7.2.4:** las 17 filas de la tabla (1.1/1.2/1.5, 1.3/1.6, 1.4, 2.1, 2.2, 2.3, 3, 4.1, 4.2, 4.3, 5.1, 5.2, 6.1, 6.2, 7, 8 y 9) y una matriz simétrica de 1 a 4, X y \*.
   - **7.4.3.2:** para cada exigencia, de 1 a 4:
     - la regla vertical por par de unidades: cerrada/cerrada, cerrada/abierta o abierta/abierta;
     - la horizontal por sentido (longitudinal o transversal), par de unidades y zona (en cubierta o bajo cubierta).
     - **Los valores posibles:** sin restricción; n espacios; n espacios o un mamparo; n mamparos; 24 m; un mamparo y 24 m; o prohibido.
   - **Sin texto del IMDG.** Solo códigos y la cita del apartado.
2. **La clase de cada sustancia:**
   - **Las divisiones de la clase 1,** con o sin grupo de compatibilidad, caen en su fila: 1.1, 1.2 y 1.5 juntas; 1.3 y 1.6 juntas; 1.4 sola.
   - **Las etiquetas de peligro secundario** que declare el archivo se aplican como dice 7.2.3.3: manda la exigencia más rigurosa entre la del peligro principal y la del secundario. Un secundario de clase 1 se toma como 1.3.
   - **Con dos o más secundarios** (7.2.3.4), la exigencia está en la columna 16b de la Lista, que BayStream no tiene: «no evaluado».
3. **El resultado de un par:**
   - **Un número (1 a 4):** se evalúa la posición con 7.4.3.2, como dice el punto 4.
   - **Una X:** «no evaluado: consultar la Lista de mercancías peligrosas». Así sale toda la clase 9.
   - **El asterisco** (clase 1 contra clase 1): «no evaluado: ver 7.2.7.1».
   - **Si un par de etiquetas da X y otro da un número,** se evalúa el número y se agrega el aviso de consultar la Lista.
   - **Dos sustancias en el mismo contenedor** que exigen segregación entre sí: «no conforme», como hoy (7.2.3.2).
4. **La posición, con 7.4.3.2,** sobre el modelo de huecos de hoy, sin medir metros:
   - **Cerrada o abierta,** por el tercer carácter de `isoSizeType`, leído en el servicio de T-85, sin cambiar el modelo:
     - son cerradas G, R, T, B, V y H;
     - son abiertas U y P;
     - sin tipo, o con otro, da «no evaluado» (10.67).
   - **En la misma vertical** quiere decir misma pila: misma fila y huellas que se tocan, como en T-95.
     - «Separados por una cubierta» es uno en cubierta y el otro en bodega.
     - Una bahía declarada como bodega abierta (T-83) no tiene tapa, así que no separa.
     - **El mensaje dice el supuesto:** «se considera la tapa como cubierta resistente al fuego y a los líquidos (IMDG 7.4.2.2)» (10.67).
   - **Horizontal:**
     - **Los espacios.** Un espacio para contenedor es un hueco completo, y dos o tres espacios son dos o tres huecos. 7.4.3.1.1 lo define como 6 m por 2,4 m; aquí se cuenta en huecos, y se rotula como derivación, igual que hoy.
     - **Los 24 m** son cuatro huecos longitudinales de 20 pies, rotulados como aproximación.
     - **Los mamparos** no los conoce BayStream: dan «no evaluado», salvo que se cumpla la alternativa «o un espacio».
     - **Basta uno de los dos sentidos.** En la exigencia 4, el transversal está prohibido: solo vale el longitudinal.
   - **La zona:** cuando las dos unidades están en la misma zona, se usa la columna de esa zona.
     - Si una va en cubierta y la otra en bodega, la tabla no da una columna directa.
     - Para 1 y 2, la cubierta entre ellas cumple.
     - Para 3 y 4: «no evaluado», porque hacen falta los límites de la bodega.
5. **El aviso de la fuente cambia,** con esta idea:
   - «Fuente: Código IMDG, Enmienda 42-24 (7.2.4 y 7.4.3.2). Apoyo a la decisión, no verificación de cumplimiento.»
   - «No se evalúan la columna 16b de la Lista de mercancías peligrosas, que tiene prioridad (7.2.3.1), ni los mamparos, ni la resistencia de las cubiertas.»
   - **49 CFR deja de usarse,** y sus datos (`unProfiles` y sus pares) salen del código. `docs/T41-SEGREGACION-FUENTE.md` queda como historia.
6. **La pantalla de segregación** muestra la matriz por clase con una leyenda en palabras de BayStream, y cada resultado con su apartado.

**El comprobador privado,** `tool/t85_tabla_privada.dart`:
- recibe las rutas de `yov_7-2-4.csv` y `yov_7-4-3-2.csv` como argumentos;
- compara los datos del código con la transcripción verificada, celda por celda: 289 y 60;
- traduce los textos de 7.4.3.2 a sus códigos con una tabla cerrada, y un texto desconocido falla;
- sale con 0 si coinciden.
- **No entra a `flutter test`.** Ningún CSV entra al repo, y sus salidas van a `%TEMP%`.
- **Lo corren** el que implementa y el que acepta.

**Carril.**
- **Toca:** `segregation_rules.dart`, `dangerous_goods_validator.dart`, el archivo nuevo de datos, los textos de `segregation_page.dart` y `stowage_alerts_page.dart`, `test/t85_*`, `tool/t85_*`, y las pruebas y herramientas de segregación de arriba que fijan resultados de 49 CFR.
- **No toca:** el lector, el modelo (`DangerousGoods` y `ContainerUnit`), el codec, las reglas, `lib/main.dart`, los congelados ni `pubspec.*`. Sin dependencias nuevas.

**Detente y avisa si:**
- el comprobador privado no da 289/289 y 60/60;
- un resultado del corpus cambia y no se explica por las tablas del IMDG;
- hace falta cambiar el modelo de DGS.

**Fuera de alcance:**
- la Lista de mercancías peligrosas, su columna 16b y los códigos SG;
- la estiba mixta de la clase 1 (7.2.7.1.4);
- 7.4.3.3, los buques sin tapas;
- declarar mamparos o bodegas;
- las prescripciones de estiba de 7.4.2, como la ventilación o el punto de inflamación en cubierta;
- las cantidades limitadas y exceptuadas.

**Terminada cuando:**
- [ ] **El comprobador privado** da 289/289 y 60/60 contra la transcripción verificada.
- [ ] **Una prueba exige la simetría** de la matriz.
- [ ] **Los casos sintéticos** cubren al menos:
  - 3 contra 5.1 (2): pegados en cubierta, no conforme; con un hueco, conforme;
  - 2.1 contra 4.1 (1): cerrados y pegados en cubierta, conforme;
  - una exigencia 1 entre dos abiertas pegadas: falta un espacio;
  - 1 en vertical: una abierta sobre una cerrada, permitido;
  - 1.4 contra 6.2 (4):
    - con cuatro huecos longitudinales, conforme;
    - con tres, no conforme;
    - separadas solo en sentido transversal, no conforme;
  - bajo cubierta, una exigencia de mamparo: no evaluado;
  - una en cubierta y otra en bodega, para 2 y para 3;
  - la clase 9, el asterisco, un secundario declarado y dos secundarios;
  - dos sustancias en un mismo contenedor.
- [ ] **El corpus:** cada resultado que cambia frente a 49 CFR se lista en el informe con su razón, y ninguno queda sin explicar.
- [ ] **Ningún texto del IMDG en el repo:** una búsqueda de «Prohibido en la misma línea vertical» y «compartimiento intermedio» en `lib/`, `test/` y `tool/` no devuelve nada.
- [ ] **En los tres clientes,** con un namespace propio (`t85acc`), la pantalla de segregación de un archivo del corpus con peligrosas muestra la fuente nueva y sus resultados. En el Honor, a 360 dp y letra 2.0.
- [ ] **Validaciones:**
  - el piso de HEAD más las nuevas, y `analyze` en cero;
  - el corpus completo en verde;
  - las reglas, `lib/main.dart`, `pubspec.*` y los congelados sin cambio.

| Tarea | Elemento | h | Qué | Terminada cuando |
|---|---|---:|---|---|
| **T-82** | RF-039 | 10.0 | BAPLIE de salida en la misma versión 2.x en que llegó, con lo cargado, re-estibado y cancelado; VGM y tara exactos del listado | Releído por el propio lector, coincide con `CASO_A08_ESTADO_FINAL.csv` en las 460 posiciones · **ficha completa arriba** |
| **T-83** | RF-040 | 4.0 | Tapas en el perfil del buque, por bahía: sin tapa, una automática, o 1–3 de grúa con las filas que cubre cada una | Se declaran una vez por buque y se copian a otras bahías · **ficha completa arriba** |
| **T-84** | RF-040 | 4.0 | Tapas en la operación: quitar y reponer como movimientos; aviso al marcar bodega bajo tapa cerrada | Los movimientos de tapa cuentan en el avance · **ficha completa arriba** |
| **T-85** | RF-027+ | 10.0 | Segregación por clase con las tablas 7.2.4 y 7.4.3.2 del IMDG 42-24, transcritas a ciegas por Yov y Gru y verificadas (10.60). La hace Timonel y la acepta Codex · **ficha completa arriba** | Los casos sintéticos de la transcripción dan lo que dice la tabla; la clase 9 sale «no evaluado» |
| **T-86** | BAP | 3.0 | Detectar la versión por la cabecera y leer toda la familia 2.x; si llega otra, decirlo | A01 … A08 siguen igual; una 1.x o una 3.x se rechaza con un mensaje claro · **ficha completa arriba** |
| **T-87** | BAP | 10.0 | Leer BAPLIE 3.1 | Necesita un archivo real; sin él, se declara y no se empieza |
| **T-103** | BAP | 1.0 | Leer la 1.5 (SMDG15) con aviso visible; el resto de la 1.x y la 3.x se siguen rechazando (10.35; adelantada a Timonel en 10.41; terminada en 10.45) · **ficha completa arriba** | A06 abre con sus cifras de antes de T-86 y el aviso; los corpus esperan la lectura con aviso |

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

**Corrección de T-93 (15-oct, 10.42) · Codex · sin estimación nueva: es parte de T-93.**

**Qué falla.** En la aceptación, Codex cambió un bit de una copia del paquete. La firma
quedó `HashMismatch`, con la huella de Carlos, y el control final de `tool/t93_msix.ps1`
no la rechazó:
- solo compara la huella (`$firma.SignerCertificate.Thumbprint -ne $Huella`);
- muestra `$firma.Status`, pero no lo mira.

Windows no instalaría ese paquete, así que el riesgo es bajo. Pero un script que imprime
«Firma: HashMismatch» y termina bien da una confianza que no merece.

**Qué construye.**
1. **Una sola función de verificación en el script,** que exige tres cosas:
   - el SHA-256 del `.msix` coincide con el de su `.sha256`;
   - `Get-AuthenticodeSignature` da `Status` igual a `Valid`;
   - el firmante tiene la huella que se pasó con `-Huella`.
   - Si falla alguna, termina con error y dice cuál falló, con el estado y el
     `StatusMessage` de la firma.
   - Con `HashMismatch`, el mensaje dice que el paquete está alterado o dañado y que no
     se distribuye.
   - Si el estado no es `Valid` porque el `.cer` no es de confianza en ese equipo, el
     mensaje dice que primero se importe `BayStream.cer` en «Personas de confianza».
2. **El armado termina llamando a esa función** sobre el paquete que acaba de crear. Ya no
   usa el control de hoy.
3. **Un modo `-Verificar <ruta del .msix>`,** que solo corre esa función sobre un paquete
   que ya existe:
   - no compila, no empaqueta y no necesita Flutter;
   - no pide el archivo de opciones de Firebase, ni comprueba que exista;
   - sirve para probar el control sobre un archivo real, y para que Carlos revise una
     copia antes de llevarla a COMAR.
4. **La prueba que ya existe,** «T-93 el script compila con Firebase y firma por huella»,
   exige además que el script consulte el estado `Valid`. No hay pruebas nuevas, y la suite
   sigue en 685.
5. **Los textos del script siguen en ASCII,** sin tildes, como el resto.

**Carril.**
- Toca solo `tool/t93_msix.ps1`, `test/t93_msix_config_test.dart` y
  `docs/T93-CORRECCION-RESULTADOS.md`.
- No toca `lib/`, `pubspec.*` ni las demás pruebas: Timonel está en T-103.
- Trabaja en una copia exacta de HEAD en `%TEMP%`, y pone sus archivos en el repo solo al
  final, juntos.
- No instala nada, no abre la app y no toca el almacén real.

**Terminada cuando.** Las sondas usan los paquetes de la aceptación, que siguen en
`%TEMP%\baystream-t93acc\`, o uno recién armado. Ninguna copia alterada se instala.
- [ ] **El original pasa:** `-Verificar` sobre el `.msix` 1.0.2.0 con su `.sha256`
      termina con código 0, y muestra `Valid`, `CN=BayStream` y la huella.
- [ ] **La firma alterada no pasa:** una copia con un bit cambiado, con su `.sha256`
      recalculado para que el SHA no la detenga antes, termina con error y dice
      `HashMismatch`.
- [ ] **El SHA no pasa:** el original con un `.sha256` que no coincide termina con error,
      y lo dice.
- [ ] **Otra huella no pasa:** el original con una huella que no es la de Carlos (40
      hexadecimales válidos) termina con error, y lo dice.
- [ ] **El armado usa la misma función:** `-SinCompilar` sobre la compilación Release de
      la copia termina con la misma verificación en verde. Es un comando de la cadena de
      Flutter, así que va con el semáforo de Carlos.
- [ ] **Validaciones en la copia con los dos archivos:**
  - suite 685/685, T-93 5/5 y `analyze` en cero;
  - el corpus no hace falta, porque `lib/` no cambia.
- [ ] **El informe** explica cómo se usa `-Verificar`, en una línea lista para las
      instrucciones de oficina de T-100.

**La verificación la hace Timonel** cuando entregue T-103:
- revisa el cambio;
- repite las cuatro sondas con el script commiteado.
- Si pasan, T-93 queda Terminado.

#### T-88 · Lo que pide Play: la política de privacidad dentro de la app y en la Web, sin respaldo de Android, y el ícono propio · 2.5 h · Timonel (ficha completa, 15-oct)

**Para qué.** USO. Abre la prueba de Play después del merge (18 al 21-oct).
- `docs/T64-DECLARACIONES-PLAY.md` (Sprint 2) dejó tres huecos:
  - la política de privacidad tiene que estar **dentro de la app** y en una dirección pública (D4 y D1);
  - el respaldo automático de Android (D3);
  - el ícono de Flutter (D5).
- Desde entonces la app cambió lo que hace con los datos: cuentas (T-70c), sincronización con Firestore (T-79), dictado por voz (T-94) y la Web servida desde su sitio (T-92). El borrador de T-64 dice «no tiene cuentas» y «no envía nada», y **ya no es verdad**.

**Decisiones que ya están.**
- **D3 (10.35):** el almacén local no se respalda ni pasa a otro teléfono.
- **D4:** el texto va dentro de la app, sin enlace externo. No hace falta `url_launcher`.
- **D1:** la versión pública es `web/privacidad.html`, que se publica con la Web en Firebase Hosting cuando Carlos publique (T-92). Su dirección es la que va en Play.
- **D2, el correo de contacto,** lo escribe Carlos en el prompt de Timonel.
  - Es público por definición: sale en la política y en la ficha de Play. Por eso es la única dirección de correo autorizada en el repo.
  - Yov recomienda una dirección del proyecto, no la personal.
- **D9, el nombre bajo el ícono:** «BayStream», como en Windows (T-93) y en la interfaz. Hoy el manifest dice `baystream`.

**Qué construye.**

1. **Una sola fuente para el texto,** en Dart puro dentro de `lib/`. Timonel elige el lugar según la arquitectura y lo declara.
   - Lleva la fecha de actualización, las secciones con título y párrafos, y el correo como constante.
   - **El texto es el de abajo, palabra por palabra.**
   - **Si una frase es falsa frente al código,** Timonel no la arregla por su cuenta: se detiene en esa frase, la reporta con la evidencia, y Yov corrige el texto. Por ejemplo, si un dato que dice que se guarda no se guarda, o lo que se exporta no coincide.
2. **Una pantalla «Política de privacidad»** que muestra ese texto completo.
   - Se llega sin abrir un viaje y sin iniciar sesión: desde Parámetros, junto al tema (T-90), y desde la pantalla de inicio de sesión. Timonel declara las rutas exactas.
   - Se lee bien a 360 dp, en claro y en oscuro, y a letra 2.0.
3. **`web/privacidad.html`, generado desde la misma fuente** por `tool/t88_privacidad.dart`. La función que arma el HTML vive en `lib/`, para que la herramienta y la prueba usen la misma.
   - Un archivo autocontenido, con `lang="es"` y `viewport`, en claro y oscuro con `prefers-color-scheme`.
   - Sin JavaScript y sin recursos externos: ni fuentes de Google ni CDN.
   - Lo carga la Web servida (T-92) en `/privacidad.html`, directo, sin pasar por la app.
4. **D3 en Android.**
   - `android:allowBackup="false"`.
   - `android:dataExtractionRules`, con un XML que excluye todos los dominios en `cloud-backup` y en `device-transfer`. Con `targetSdk` 31 o mayor, `allowBackup="false"` solo no detiene la transferencia entre dispositivos.
   - Timonel confirma el mecanismo en la documentación oficial de Android para el `targetSdk` actual, y cita la fuente en el informe.
5. **D9:** `android:label="BayStream"`. Si la Web o Windows dicen otra cosa, se reporta y no se cambia.
6. **El inventario para las declaraciones de Play,** como T-64 en 1.2 y 1.3, pero sobre un APK release de hoy:
   - los permisos del manifiesto fusionado: se espera `INTERNET`, `ACCESS_NETWORK_STATE` y `RECORD_AUDIO`, más la consulta de `RecognitionService`;
   - `allowBackup` y `dataExtractionRules` en el manifiesto fusionado;
   - del árbol de dependencias release, los artefactos de Firebase y de Play services, y si aparece alguno que transmita por su cuenta: Installations, Analytics, Crashlytics, Messaging, App Check, anuncios.
   - **Si aparece Installations, analítica o anuncios, se detiene y avisa:** la política dice que no los hay.
   - Con este inventario, Yov escribe después las declaraciones de Play.
7. **De paso, la observación de T-93 (10.44).** En `tool/t93_msix.ps1`, el estado `UnknownError` también da la indicación de importar `BayStream.cer`, porque es lo que devuelve Windows cuando la raíz no es de confianza.
   - El mensaje no afirma la causa: «La firma no es de confianza en este equipo o no se pudo validar. Si no ha importado BayStream.cer en Personas de confianza del equipo local, importelo primero.» El `StatusMessage` sigue saliendo.
   - En ASCII, como el resto del script.
   - Las cuatro sondas de 10.42 siguen dando 0 / 1 / 1 / 1.
8. **El ícono propio (D5), si Carlos ya decidió.** Si no, queda para una segunda entrega de T-88, y lo anterior se entrega igual.
   - Las dos opciones: un logo que dé Carlos, o uno sencillo y original que proponga Yov.
   - Generarlo con `flutter_launcher_icons` como dependencia de desarrollo requiere que Carlos la autorice. Sin ella, no se agrega ninguna.
   - Abarca Android (adaptativo y los tamaños antiguos), la Web (`favicon` e íconos del manifiesto) y Windows (`app_icon.ico`, que usa el MSIX), además del PNG de 512×512 para la ficha de Play.

**El texto de la política (fuente única; los títulos van en negrita).**

> **Política de privacidad de BayStream**
> Última actualización: 15 de octubre de 2026
>
> **Quién la publica.** BayStream es una aplicación para ver y operar el plano de estiba de un buque portacontenedores. La desarrolla Carlos Giovanni Martínez Aldana, en Puerto Barrios, Guatemala, como proyecto de graduación de Ingeniería en Sistemas. Esta política explica qué datos usa la aplicación en Android, Windows y la Web, dónde quedan y qué decides tú.
>
> **Sin cuenta, todo se queda en tu dispositivo.** Puedes usar BayStream sin iniciar sesión. Así, los archivos que abres y lo que haces con ellos se procesan y se guardan solo en tu dispositivo, y la aplicación no los envía a ningún servidor.
>
> **Los archivos que abres.** La aplicación lee los archivos que tú eliges: planos BAPLIE y listados de exportación en Excel. Contienen información comercial del buque, del viaje y de la carga, como números de contenedor, puertos, pesos, refrigerados y mercancías peligrosas. No están pensados para contener datos personales.
>
> **Con cuenta, la operación se sincroniza.** Las cuentas las crea el administrador de BayStream para el personal de una operación portuaria: la aplicación no permite crearlas por tu cuenta.
> - **Tu cuenta.** Tu correo y tu contraseña los gestiona Firebase Authentication, de Google. BayStream no guarda tu contraseña. Al iniciar sesión, Firebase Authentication recibe también la dirección IP de tu conexión y datos técnicos de la aplicación, para proteger las cuentas contra el abuso, como lo describe Google. El administrador registra además tu nombre, tu rol (muelle u oficina) y si la cuenta está activa.
> - **Lo que se envía a la nube.** Al publicar una operación, o al unirte a ella, se guardan en Cloud Firestore, de Google: los archivos de la operación, el perfil del buque y cada movimiento que registras, como descargas, cargas, re-estibas, tapas, solicitudes y aprobaciones. Cada movimiento lleva el identificador de tu cuenta, tu nombre, tu rol, la hora y un identificador aleatorio de la instalación de la aplicación, que no identifica tu teléfono ni tu computadora. La operación guarda también qué cuenta la publicó y cuál la cerró.
> - **Quién lo ve.** Solo las cuentas autorizadas de BayStream y el administrador. Todas las cuentas autorizadas pueden ver las operaciones; el rol decide lo que cada una puede registrar o aprobar. Las reglas de la base de datos lo exigen.
> - **Dónde se guarda.** Los datos de la operación, en la región de Firebase en México (northamerica-south1); los de la cuenta, en Firebase Authentication. Las conexiones van cifradas.
> - **Sin conexión.** Los movimientos esperan en tu dispositivo y se envían cuando vuelve la red.
>
> **El micrófono, solo si lo usas.** La búsqueda de contenedores se puede dictar. El micrófono se pide únicamente cuando pulsas su botón, y puedes negarlo: escribir la búsqueda siempre funciona. El dictado lo hace el servicio de reconocimiento de voz de tu sistema, en Android, o de tu navegador, en la Web. Ese servicio puede enviar el audio a los servidores de su proveedor, como Google, según la política de ese proveedor. BayStream no graba ni guarda el audio, y el texto reconocido solo llena el campo de búsqueda: no se guarda ni se envía. En Windows no hay dictado.
>
> **Lo que se guarda en tu dispositivo.** Los viajes recientes, los perfiles de buque, la operación con su cola de movimientos, los datos de tu cuenta y tu preferencia de tema se guardan en tu dispositivo: en Android, en el almacenamiento privado de la aplicación; en Windows, en la carpeta de datos de tu usuario; en la Web, en el almacenamiento del navegador para el sitio de BayStream. Firebase guarda además tu sesión, para no pedirte la contraseña cada vez, y en Android y en Windows, una copia de la operación para trabajar sin conexión.
> - En Android, estos datos no entran en la copia de seguridad de Google ni pasan a otro teléfono en una transferencia.
> - Puedes borrar un viaje desde Recientes.
> - En Android, lo demás se borra al desinstalar la aplicación o al borrar sus datos desde los ajustes; en la Web, al borrar los datos del sitio en el navegador.
> - En Windows, desinstalar puede dejar en tu carpeta de usuario los datos de BayStream y la copia de Firebase. Para quitarlos, cierra sesión antes de desinstalar y borra las carpetas `AppData\Local\BayStream` y `AppData\Local\firestore\[DEFAULT]\baystream-app`.
> - Cerrar sesión quita tu sesión del dispositivo. Tu nombre y tu rol se quedan guardados con lo demás, y se borran de la misma forma.
>
> **Exportar.** Cuando exportas un reporte (PDF, CSV o JSON) o el BAPLIE de salida, el archivo se guarda: en Android y en Windows, donde tú decides con el selector de archivos del sistema; en la Web, como una descarga del navegador. Lo que hagas con él después queda fuera de BayStream.
>
> **La Web.** La versión Web se sirve desde el sitio de BayStream en Firebase Hosting, de Google, incluidos el motor de dibujo, las fuentes y el SDK de Firebase: no carga código de otros sitios. Como cualquier servidor web, el alojamiento puede registrar datos técnicos de cada conexión, como la dirección IP.
>
> **Lo que BayStream no hace.** No muestra anuncios, no usa herramientas de analítica ni de seguimiento, y no vende ni cede tus datos. Las bibliotecas de Firebase envían con cada petición el nombre y la versión de la plataforma, como lo describe Google.
>
> **Cuánto tiempo se guardan.** Los datos de una operación se conservan en la nube mientras el administrador la mantenga. Los movimientos registrados conservan el nombre con que se firmaron, porque son el registro de la operación. Si dejas de trabajar con BayStream, puedes pedir que se borre tu cuenta.
>
> **Menores.** BayStream es una herramienta de trabajo para adultos y no está dirigida a menores de 18 años.
>
> **Cambios.** Si esta política cambia, la nueva versión se publica en la aplicación y en el sitio, con su fecha.
>
> **Contacto.** Para preguntas sobre esta política, o para pedir que se borre tu cuenta, escribe a [correo de D2].

**Carril.**
- Toca:
  - `lib/`, solo para la fuente del texto, la función del HTML, la pantalla y sus dos entradas;
  - `test/t88_*`, `tool/t88_privacidad.dart`, `web/privacidad.html` y `tool/t93_msix.ps1`;
  - en Android: `AndroidManifest.xml` y un XML nuevo en `res/xml/`;
  - si hay ícono, los recursos de ícono de Android, la Web y Windows.
- **No toca** `lib/main.dart`, los congelados, las reglas ni `pubspec.*`. La excepción es `flutter_launcher_icons`, solo si Carlos la autoriza, y se declara con su versión.
- Codex acepta T-103 al mismo tiempo, desde una copia de HEAD, así que nadie pisa a nadie. Un comando de Flutter a la vez, con el semáforo de Carlos.

**Detente y avisa si:**
- una frase del texto es falsa frente al código;
- el inventario encuentra Installations, analítica o anuncios;
- D3 exige más que el manifest y un XML;
- llegar a la pantalla sin sesión exige tocar `lib/main.dart`.

**Fuera de alcance:**
- las declaraciones de Play, que escribe Yov con el inventario;
- publicar la Web o subir algo a Play, que lo hace Carlos;
- la ficha de la tienda: descripciones, gráfico y capturas;
- el iPhone, que entra por la Web.

**Terminada cuando:**
- [ ] **La pantalla** muestra el texto completo en los tres clientes, con el correo de D2. Se llega desde Parámetros y desde el inicio de sesión, sin viaje y sin sesión. En el Honor `.t88`, a 360 dp, en claro y en oscuro, y a letra 2.0.
- [ ] **`/privacidad.html`** abre directo en Chrome desde la Web servida (`build/web`), sin recursos externos, y su texto es el de la app.
- [ ] **Una prueba exige que `web/privacidad.html` sea igual a lo que genera la fuente,** byte a byte salvo los finales de línea. Otra pide que el texto nombre el micrófono, la sincronización, la falta de respaldo y el contacto.
- [ ] **D3:** el manifiesto fusionado del APK release tiene `allowBackup="false"` y `dataExtractionRules` con las dos exclusiones. Si `bmgr` lo permite en el Honor sin root, el informe muestra que el paquete no es elegible para respaldo; si no, basta el manifiesto.
- [ ] **El nombre** «BayStream» bajo el ícono en el Honor.
- [ ] **El inventario** de los puntos de arriba, con sus fuentes, en el informe.
- [ ] **El script de T-93:** las cuatro sondas siguen en 0 / 1 / 1 / 1, y el mensaje de `UnknownError` es el de arriba.
- [ ] **Validaciones:**
  - piso de 697 más las nuevas, y `analyze` en cero;
  - el corpus completo en verde con los conteos declarados;
  - las reglas, `lib/main.dart` y los congelados sin cambio;
  - `pubspec.*` sin cambio, salvo la dependencia del ícono si Carlos la autoriza.
- [ ] **Si hubo ícono:** se ve en el lanzador del Honor, en la pestaña de Chrome y en Windows, y está el PNG de 512×512 para Play.

#### T-105 · Mover un contenedor arrastrándolo en el plano · 3.5 h · Codex (ficha completa, 15-oct)

**Para qué.** RF-038, con la interacción de RF-037. Carlos lo pide para mostrarlo el 17-oct (10.54). Hoy, mover o intercambiar un objeto del plan de carga es un formulario (`change_requests_page.dart`): se escribe el contenedor, la orden o la reserva, y la celda de destino. En el plano, lo natural es tomarlo y soltarlo donde va.

**La idea central: arrastrar es otra forma de escribir el mismo cambio.**
- No hay un tipo de movimiento nuevo, ni otra regla, ni otra sincronización.
- Al soltar, se arma la misma `PositionChange`, y pasa por el mismo `ChangeRequests`:
  - **la oficina** registra `changePosition`: el cambio es directo, y se deshace como hoy;
  - **el muelle** registra `requestChange`, y la oficina la aprueba o la rechaza, como en T-80.
- **Por eso hereda todo lo que ya está probado:** el motivo obligatorio, la sincronización, el deshacer, los permisos por rol y las reglas de Firestore.

**Lo que hay hoy (Yov lo revisó en el repo, 15-oct):**
- **`ChangeRequests.review()`** rechaza:
  - un objeto que no está en el plan, o cuyo origen cambió;
  - una celda fuera de la geometría;
  - un 40 en bahía impar o un 20 en par;
  - una celda prevista para otro objeto, salvo que ese objeto entre en el intercambio.
- **`move()`** exige además:
  - que el objeto esté **pendiente de carga** (`PlanRole.load` y `ItemState.planned`);
  - que la celda no esté ocupada a bordo;
  - que, en un intercambio de reservas, sean del mismo grupo.
- **`request()`** es lo mismo para el muelle. Un lote lleva de uno a cuatro cambios.
- **El plano** (`bay_plan_view.dart`, `_BayGridWidget`) muestra una bahía a la vez. Tiene los modos Contenido, Carga, Orden y Descarga, y en el modo Carga recibe el `LoadingOperation` y abre los detalles al tocar una celda.

**Qué construye.**
1. **Una vista previa pura en el dominio:** `ChangeRequests.preview(data, actor, changes)`.
   - Devuelve si el cambio es válido, si es un intercambio, o el mensaje de error.
   - Usa las mismas comprobaciones de `move()` y `request()`, sin copiarlas en la vista: las tres llaman a la misma función.
2. **Qué se arrastra:**
   - **solo en el modo Carga,** con una operación abierta y una sesión con rol;
   - **solo objetos pendientes de carga,** contenedores o reservas.
   - Lo que ya se cargó, lo que descarga o va de paso, y todo lo que hay en los demás modos, no se arrastra.
   - Sin rol, una pulsación larga sobre un objeto pendiente dice «Inicia sesión para mover».
3. **El gesto:**
   - **`LongPressDraggable`,** para que el toque siga abriendo los detalles y el desplazamiento y el zoom del plano sigan funcionando. En Android vibra al empezar.
   - **Lo que se arrastra** es una copia de la celda (contenedor u orden), un poco por encima del dedo para que no la tape.
   - **Solo dentro de la bahía que se ve.** Para otra bahía queda el formulario.
4. **Mientras se arrastra,** cada celda bajo el dedo muestra el resultado de `preview()`:
   - **verde,** si el movimiento es válido;
   - **ámbar,** si es un intercambio, porque la celda está prevista para otro objeto pendiente;
   - **rojo,** si no se puede.
   - El color no es la única señal: lleva también un borde o un ícono.
5. **Al soltar no se registra nada todavía.** Se abre una hoja de confirmación:
   - «Mover TSTU 123456-7 de 14 01 02 a 14 01 08», o «Intercambiar A ↔ B»;
   - el motivo, obligatorio, con sugerencias rápidas (peso, segregación, acceso de grúa) y texto libre;
   - **«Confirmar»:** la oficina mueve. El muelle «Envía la solicitud», y el objeto no se mueve hasta que la oficina la apruebe.
   - Soltar en rojo no abre la hoja: un aviso dice por qué.
   - Cancelar no registra nada.
6. **La solicitud pendiente se ve en el plano** (Carlos, 10.54). El muelle arrastra igual que la oficina, en el teléfono y en la Web, pero su cambio espera la confirmación.
   - Mientras está pendiente, la celda de destino lleva un borde punteado y un reloj, en el plano del muelle y en el de la oficina. El objeto sigue en su celda.
   - La oficina la aprueba o la rechaza en su lista de solicitudes, como en T-80. Al aprobarla, el objeto pasa a la celda nueva en las dos pantallas, sin recargar. Al rechazarla, la marca desaparece.
7. **El formulario de hoy se queda** para mover a otra bahía y para el teclado.

**Carril, en paralelo con T-56.**
- **Toca:**
  - `bay_plan_view.dart`;
  - `change_requests.dart` (solo para agregar `preview` y que `move` y `request` la usen);
  - un widget nuevo para la hoja de confirmación;
  - `test/t105_*`.
- **Puede reutilizar** de `change_requests_page.dart` lo que ya resuelve el guardado.
- **Timonel está en T-56** con otros archivos de `lib/`:
  - Codex trabaja en una copia exacta de HEAD en `%TEMP%` y pone sus archivos en el repo solo al final, juntos;
  - si alguno cambió en el árbol mientras tanto (su SHA ya no es el de HEAD), se detiene y avisa.
- **No toca** el modelo de movimientos, el codec de Firestore, las reglas, `lib/main.dart`, los congelados ni `pubspec.*`. Sin dependencias nuevas.

**Detente y avisa si:**
- el gesto rompe el toque, el desplazamiento o el zoom del plano;
- `preview` no se puede compartir sin cambiar el comportamiento de `move` o `request`;
- hace falta otro tipo de movimiento.

**Fuera de alcance:**
- arrastrar entre bahías;
- arrastrar lo que ya está a bordo: re-estibar es descargar y volver a cargar (T-75);
- el desplazamiento automático en los bordes;
- deshacer desde la misma hoja (el deshacer de la oficina queda donde está).

**Terminada cuando:**
- [ ] **Pruebas de widget** con el repositorio falso:
  - un pendiente soltado en una celda libre y válida de su bahía, confirmado, deja un `changePosition` con la `PositionChange` correcta (oficina);
  - soltado sobre otro pendiente, arma el intercambio de dos cambios;
  - un 40 sobre una bahía impar, o fuera de la geometría, se rechaza con el mensaje de `review`;
  - con el rol de muelle, el mismo gesto deja un `requestChange`;
  - cancelar no deja nada;
  - lo cargado, lo que descarga y lo que va de paso no se pueden arrastrar;
  - el toque sigue abriendo los detalles.
- [ ] **Una prueba del dominio** exige que `preview`, `move` y `request` den el mismo resultado sobre los mismos casos.
- [ ] **En los tres clientes,** sobre una operación de prueba (namespace `t105acc`):
  - el Honor, con el dedo, a 360 dp;
  - Windows, con el mouse;
  - Chrome.
  - En cada uno se hace un movimiento y un intercambio como oficina, y una solicitud como muelle.
  - La solicitud se ve pendiente, con el borde punteado y el reloj, en las dos pantallas.
  - Una solicitud aprobada mueve el objeto, y una rechazada quita la marca.
  - El muelle arrastra en el Honor y en la Web.
  - La otra pantalla los ve sincronizados sin recargar.
  - El desplazamiento y el zoom siguen funcionando.
- [ ] **Validaciones:**
  - el piso vigente más las nuevas, y `analyze` en cero;
  - el corpus completo en verde;
  - las reglas, `lib/main.dart` y los congelados sin cambio.

#### T-106 · Pulido del arrastre y del zoom: avisos en palabras, el zoom a 300 % y lo que el plano no dibuja · 2.0 h · Timonel (ficha completa, 16-oct; pasa de Codex a Timonel en 10.69)

**Para qué.** RF-038. Son las observaciones de la aceptación de T-105 (sección 12 de `docs/T105-ACEPTACION-RESULTADOS.md`; 10.64 y 10.66), más una de T-95. Ninguna rompe una regla. Todas son lo que el planner ve mal o no ve.

**Lo que hay hoy (Yov lo revisó en el repo, 16-oct):**
- **`ChangeRequests.review()`** (`change_requests.dart`) arma sus avisos con la clave interna del objeto: «C:TSTU0000017 no cabe en la bahía 5.».
  - `_collision` (10.63) siempre agrega una segunda frase, «marca primero su descarga» o «inclúyelo en el intercambio», aunque no aplique.
- **El zoom de T-105** está en `bay_plan_view.dart` y `plan_drag_confirmation.dart`.
  - A 300 %, con una ventana ancha de Windows, el plano abre en blanco: la rejilla queda centrada en un lienzo tan ancho como la vista.
  - El margen de 16 dp también se escala.
  - La copia que se arrastra no lleva la escala.
- **El modo Carga** no dibuja la descarga pendiente, que viene de T-76: la celda se ve vacía.
- **La vista de una bahía par** no dibuja los 20 de sus impares vecinas, así que el choque de 10.63 no se ve, aunque el rojo sí lo dice.
- **En T-95,** «re-estibas» se parte en el guion a 360 dp con letra grande.

**Qué construye.**
1. **Los avisos, en palabras.**
   - El objeto se nombra como lo ve el planner: «OR 7 · TSTU0000017», o «la reserva 005 02 82», nunca `C:` ni `R:`. Vale para todos los avisos de `review()`.
   - **La segunda frase, solo si aplica:**
     - si choca con un objeto de otro tamaño: «Un 20 y un 40 no se intercambian.»;
     - si choca con carga de paso a bordo: «Es carga de paso: no se descarga aquí.»;
     - si choca con una descarga pendiente: «marca primero su descarga.»;
     - si choca con otro objeto pendiente del mismo tamaño: «inclúyelo en el intercambio.».
   - Las reglas no cambian, solo el texto.
2. **El zoom a 300 %:**
   - al ampliar, la rejilla queda a la vista, sin lienzo en blanco, en cualquier ancho de ventana;
   - el margen de 16 dp no se escala;
   - la copia que se arrastra se dibuja a la escala del zoom.
3. **El modo Carga dibuja la descarga pendiente:** la celda se ve ocupada, con la marca de T-75. Soltar ahí sigue dando el rojo.
4. **La vista de una bahía par dibuja los 20 de sus impares vecinas** como sombra.
   - Es la misma huella física de T-95 y de 10.63, sin calcular pares.
   - Es solo dibujo: no se arrastra ni se toca.
5. **«re-estiba» no se parte en el guion:** se escribe con un guion que no parte línea (U+2011) en la pantalla de T-95. Las pruebas que fijan el texto se ajustan.

**Carril.**
- **Toca:**
  - los textos de los avisos en `change_requests.dart`, sin cambiar ninguna regla;
  - `bay_plan_view.dart`, `plan_drag_confirmation.dart` y la pantalla de T-95;
  - `test/t106_*`, y las pruebas que fijan los textos que cambian.
- **No toca:** el modelo, el codec, las reglas, `lib/main.dart`, los congelados ni `pubspec.*`. Sin dependencias nuevas.
- **La demo del 17:** no se coloca nada en el árbol hasta que Carlos confirme que compiló los clientes de la demo.

**Detente y avisa si:**
- un aviso nuevo exige cambiar una regla de `review()`;
- dibujar la sombra de los 20 cambia lo que se arrastra o se toca.

**Fuera de alcance:**
- tocar la sombra de un 40 para ver detalles;
- el error que salió una vez en la consola de la Web;
- arrastrar entre bahías.

**Terminada cuando:**
- [ ] **Pruebas de widget y de dominio:**
  - cada aviso en palabras, con su segunda frase según el caso;
  - el zoom a 300 % con un ancho de 1600 px muestra la rejilla;
  - la copia escalada;
  - la descarga pendiente dibujada en Carga;
  - los 20 vecinos dibujados en la par, sin arrastre ni toque;
  - «re-estibas» sin partirse a 360 dp y 2.0.
- [ ] **En los tres clientes,** sobre una operación de prueba propia:
  - Windows con la ventana ancha a 300 %;
  - el Honor con pellizco;
  - en los dos, los avisos y lo que ahora se dibuja.
- [ ] **Validaciones:**
  - el piso de HEAD más las nuevas, y `analyze` en cero;
  - el corpus completo en verde;
  - las reglas, `lib/main.dart`, `pubspec.*` y los congelados sin cambio.

#### T-107 · El encabezado del plano, compacto en el teléfono, y los últimos textos internos · 3.0 h · Timonel (ficha completa, 16-oct; la acepta Codex)

**Para qué.** Carlos lo encontró en el Honor la víspera de la demo (10.76). A 360 dp, con A07 en el modo Carga, los controles de arriba del plano ocupan casi toda la pantalla, y la rejilla queda en una franja donde no se ve el plano. Además se cierran los tres textos que T-106 dejó fuera (sección 7 de `docs/T106-RESULTADOS.md`). T-98 y T-99 miden RNF-002 y RNF-003 a 360 dp, así que la tarea entra antes del commit de cierre.

**Dos partes (10.77).** La parte A, antes de la demo: el encabezado y «re-estibas» en el resumen de Carga. La parte B, después: la etiqueta de accesibilidad, los avisos del deriver y U+2011 en lo demás.

**Lo que hay hoy (Yov lo revisó en el repo, 16-oct):**
- **`bay_plan_view.dart` arma una columna fija:** `LoadingPlanControls`, el selector de bahías, la rejilla en un `Expanded` y la leyenda. Los controles no se desplazan, y la rejilla se queda con lo que sobra.
- **`LoadingPlanControls`** (`loading_plan_controls.dart`) pone en un `Wrap`:
  - el desplegable de modo;
  - «Pendientes por bahía» o «Pendientes de descarga»;
  - «Avance de la operación»;
  - el chip de la nube;
  - «Solicitudes de cambio» o «Bandeja de cambios».
  - A 360 dp, cada botón cae en su propia línea.
- **Debajo va el resumen del modo:** en Carga, `LoadingControls` (el resumen, «OR / últimos dígitos» y «Asignar vacío»); en Descarga, `DischargeSummary`.
- **Los textos:**
  - la etiqueta de accesibilidad de las celdas de carga lleva `C:` (`loading_controls.dart`, `label: '$itemKey, …'`);
  - «re-estibas» se parte en el guion en el resumen de Carga (`loading_controls.dart`), y usa el guion normal también en `discharge_controls.dart`, `operation_progress_page.dart` y el aviso del deriver;
  - los avisos de conflicto de `operation_state_deriver.dart` muestran la clave con `C:`.

**Qué construye.**
1. **En pantallas angostas, de menos de 600 dp de ancho, el encabezado cabe en dos líneas:**
   - **la primera:** el desplegable de modo, un segundo desplegable, **«Acciones»**, a su lado, y el chip de la nube como ícono;
   - **«Acciones»** lleva lo que hoy son botones: los pendientes por bahía o de descarga, el avance de la operación, las solicitudes o la bandeja con su cuenta, y «Asignar vacío» en Carga. La cuenta de solicitudes pendientes también se ve en el propio «Acciones»;
   - **la segunda:** el resumen del modo en una línea; con un toque se ve el detalle completo;
   - **«OR / últimos dígitos»** sigue a la vista en Carga, porque es lo que más usa el muelle.
2. **En pantallas de 600 dp o más no cambia nada:** Windows y la Web se quedan como están.
3. **Ninguna acción se pierde:**
   - todo lo que hoy se toca queda, como mucho, a un toque más;
   - el control que lo abre conserva sus claves de prueba (`ValueKey`).
4. **Los textos:**
   - la etiqueta de accesibilidad nombra el objeto como lo ve el planner, igual que los avisos de T-106: «OR 3 · TSTU0000003, sube»;
   - «re-estiba» lleva U+2011 en todos los lugares visibles que quedan;
   - los avisos del deriver no muestran `C:` y usan el formato de T-106.

**Carril.**
- **Toca:**
  - `loading_plan_controls.dart`, `loading_controls.dart`, `discharge_controls.dart` y `operation_progress_page.dart`;
  - los textos de `operation_state_deriver.dart`;
  - `test/t107_*`, y las pruebas que fijan los textos que cambian.
- **`bay_plan_view.dart`,** solo si hace falta para pasar el ancho, y se declara.
- **No toca:** las reglas, el modelo, el codec, `lib/main.dart`, los congelados ni `pubspec.*`. Sin dependencias nuevas.
- **La demo del 17:**
  - el Honor no se usa hasta que Carlos diga que terminó la demo;
  - después de la demo, el Honor va por turnos: primero Codex termina su parte de la aceptación de T-106;
  - el código y las pruebas pueden avanzar antes, en una copia.

**Detente y avisa si:**
- compactar exige cambiar qué hace un botón o una regla;
- una prueba existente necesita otra clave para encontrar un control.

**Fuera de alcance:**
- que el muelle vea la vista previa del aviso antes de enviar: queda anotado (10.75);
- los rastros de la matriz del IMDG en Windows, que son de T-85.

**Terminada cuando:**
- [ ] **Pruebas de widget a 360×780 dp,** con A07 en Carga y en Descarga, y con letra 1.0 y 1.45:
  - el encabezado ocupa como mucho dos líneas, más el selector de bahías;
  - la rejilla tiene al menos la mitad del alto con 1.0, y un tercio con 1.45;
  - cada entrada de «Acciones» abre lo mismo que el botón de antes;
  - a 1280 dp, el encabezado es el de hoy;
  - las etiquetas y los avisos no muestran `C:`, y «re-estibas» no se parte a 360 dp.
- [ ] **En el Honor, después de la demo,** con A07 y con una operación de prueba: el plano se ve y se arrastra, y las acciones se alcanzan.
- [ ] **En Windows:** el encabezado sin cambios.
- [ ] **Validaciones:**
  - el piso (914) más las nuevas, y `analyze` en cero;
  - el corpus completo en verde.

#### T-108 · El lector avisa lo que no cumple el estándar: unidades de peso, posiciones mal formadas, dígito de control y archivo incompleto · 2.5 h · Codex (ficha completa, 17-oct; la acepta Timonel)

**Para qué.** La batería de conformidad de T-98 (RNF-008) encontró que el lector acepta en silencio cuatro tipos de casos que no cumplen el estándar (10.81). Uno da un dato equivocado: un peso en libras o en toneladas se toma como kilos. Los otros pueden pasar sin que nadie lo note. T-98 mide RNF-008 sobre el commit de cierre, así que la tarea va antes.

**Lo que hay hoy (Yov lo revisó en el repo, 17-oct):**
- `_parseMEA` (`baplie_parser_service.dart`) toma el número del peso y no mira la unidad (`KGM`, `LBR` o `TNE`).
- La posición de `LOC+147` pasa por `IsoCoordinateParser.tryParse`. Si no es un BBBRRTT válido, la coordenada queda nula y el lector no avisa.
- El lector no valida el dígito de control ISO 6346.
- `parse()` revisa la versión en `UNH` (`_validateVersion`), pero no que existan `UNB`, `BGM`, `UNT` y `UNZ`.
- El único aviso de lectura que llega a la pantalla es el de la 1.5 (T-103): `smdg15Notice`, en `voyage_summary_card.dart`.

**Qué construye.**
1. **Pesos:** `KGM` queda igual. `LBR` se convierte a kg (× 0.45359237) y `TNE` a kg (× 1000), redondeados al kilo. Sin unidad, se toma como kg, como hoy, y hay aviso. Una unidad distinta: el contenedor queda sin ese peso, y hay aviso.
2. **Posición mal formada:** el contenedor no se coloca en ninguna celda, y el aviso dice cuántos y cuáles, con la posición tal como vino.
3. **Dígito de control ISO 6346:** se calcula para cada número con el formato de 4 letras y 7 dígitos. Si no coincide, el contenedor se lee igual y el aviso dice cuántos y cuáles. Los números con otro formato no se evalúan.
4. **Archivo incompleto:** si faltan `UNB`, `BGM`, `UNT` o `UNZ`, el archivo abre igual, y el aviso dice cuáles faltan y que puede venir incompleto.
5. **Dónde se ven:** en la tarjeta de resumen del viaje, con el estilo del aviso de la 1.5: una línea por tipo, con la cuenta, y el detalle a un toque. Sin avisos, la tarjeta queda como hoy.
6. **La batería de T-98** (`tool/t98_estandares_test.dart`, tras la corrección de 10.81) marca los 13 casos negativos como detectados.

**Carril.**
- **Toca:** `baplie_parser_service.dart`; un servicio puro nuevo en `domain/services/` para el dígito de control; la entidad del viaje, solo si hace falta para llevar los avisos; `voyage_summary_card.dart`, y `test/t108_*`.
- **No toca:** las reglas, `lib/main.dart`, los congelados ni `pubspec.*`. Sin dependencias nuevas. Firestore no cambia.

**Detente y avisa si:**
- algún archivo del corpus cambia de peso, de número de contenedores o de posiciones: solo pueden aparecer avisos;
- el dígito de control da aviso en más del 1 % de los contenedores del corpus, que está anonimizado y podría no respetar el dígito;
- llevar los avisos, también al reabrir desde Recientes, exige cambiar el codec local o Firestore.

**Fuera de alcance:** UN/LOCODE (T-98 lo mide aparte), rechazar archivos completos, y los avisos en el PDF o en la comparación de viajes.

**Terminada cuando:**
- [ ] **Pruebas en `test/t108_*`:**
  - `LBR` y `TNE` convertidos a kg; una unidad desconocida y un peso sin unidad, con su aviso;
  - posiciones mal formadas (corta, larga, con letra y con signo) fuera de la rejilla y en el aviso;
  - tres números con el dígito alterado en el aviso, y tres válidos sin aviso;
  - un archivo sin `UNT` ni `UNZ` y otro sin `UNB` ni `BGM`, con su aviso;
  - un archivo limpio, sin avisos.
- [ ] **`tool/t98_estandares_test.dart`:** los 13 casos negativos salen «detectado».
- [ ] **El corpus:** 157/157, con todos sus resultados idénticos; el informe lista los archivos que ahora tienen algún aviso, y cuál.
- [ ] **Windows y la Web:** A07 sin avisos nuevos, o con los declarados, y un archivo sintético con los cuatro tipos muestra sus cuatro líneas. El Honor, cuando Carlos lo permita.
- [ ] **Validaciones:** el piso vigente más las nuevas, y `analyze` en cero.

#### T-109 · Estadísticas sin desbordes a 360 dp con letra grande, y el último guion de «re-estibas» · 1.0 h · Codex (ficha completa, 17-oct; la acepta Timonel)

**Para qué.** Timonel lo anotó en T-107 parte B (sección 10 de `docs/T107-RESULTADOS.md`): a 360 dp, con la letra lineal en 1.45 y en 2.0, la vista de estadísticas (`voyage_stats_view.dart`) se desborda. T-98 y T-99 miden a 360 dp y con letra grande, así que la tarea va antes del commit de cierre. Además, «re-estibas» sigue con guion normal en `privacy_policy.dart:70`.

**Qué construye.**
1. **Estadísticas a 360×780 dp, con letra 1.0, 1.45 y 2.0, sin desbordes:** las tarjetas pasan a una columna si no caben; los textos largos se parten en líneas o se recortan con «…», con el texto completo a un toque y en la etiqueta de accesibilidad. Los números no se recortan.
2. **A 600 dp o más, y en Windows,** la vista queda como hoy.
3. **La política:** «re-estibas» con U+2011, y `web/privacidad.html` igual a la fuente única, como lo dejó T-88, con su prueba.

**Carril.**
- **Toca:** `voyage_stats_view.dart`, `privacy_policy.dart`, `web/privacidad.html` y `test/t109_*`.
- **No toca:** las reglas, el modelo, el codec, `lib/main.dart`, los congelados ni `pubspec.*`. Sin dependencias nuevas.

**Detente y avisa si:**
- quitar un desborde exige quitar un dato de la vista;
- la política cambia más allá del guion.

**Terminada cuando:**
- [ ] **Pruebas de widget a 360×780 dp** con A07 y letra 1.0, 1.45 y 2.0: sin errores de desborde, y con todos los datos de hoy presentes.
- [ ] **A 1280 dp,** la vista igual que hoy.
- [ ] **La política** con U+2011, y `web/privacidad.html` igual a la fuente.
- [ ] **Windows sin cambios;** el Honor (360 dp y letra 2.0), cuando Carlos lo permita.
- [ ] **Validaciones:** el piso vigente más las nuevas, y `analyze` en cero.

| Tarea | Elemento | h | Qué |
|---|---|---:|---|
| **T-88** | USO | 2.5 | Requisitos de Play: política de privacidad nueva (con sincronización sí salen datos; micrófono opcional y voz del servicio del sistema, 10.31), enlace en la app, ícono propio, decisión D3 (10.34). La hace Timonel y la acepta Codex (10.43) · **ficha completa arriba** |
| **T-89** | USO | 1.0 | iPhone acepta .edi: sin filtro por extensión y validación por contenido (`UNB`/`UNH`) · **ficha completa arriba** |
| **T-90** | USO | 2.0 | Modo claro y oscuro con interruptor, en los tres clientes · **ficha completa arriba** |
| **T-91** | USO | 1.5 | Barra superior plegable: ocultar los iconos junto al título mientras se ve el plano · **ficha completa arriba** |
| **T-92** | USO | 3.0 | Web sin conexión: servir el motor de dibujo, las fuentes y el SDK de Firebase desde el propio sitio · **ficha completa arriba** |
| **T-93** | USO | 2.5 | Instalador de Windows: paquete MSIX firmado con el paquete `msix` (Carlos, 10.36) · **ficha completa arriba**, con su corrección (10.42) |
| **T-94** | RF-041 | 4.5 | Dictar el número de contenedor, o sus últimos dígitos, y buscarlo · **ficha completa arriba** |
| **T-102** | USO | 1.0 | Peso en las celdas del PDF, como en el plano impreso (nace en 10.2). Incluye que la cabecera de peso por pila marque una pila con pesos faltantes («28.7+?», de 10.2; pasa aquí en 10.13) · **ficha completa arriba** |
| **T-105** | RF-038 | 3.5 | Mover un contenedor arrastrándolo en el plano: el mismo cambio de T-80 y T-81, con vista previa por celda y una hoja de confirmación con motivo. Lo hace Codex y lo acepta Timonel (10.54); entregada con zoom autorizado por Carlos (10.62); terminada con la corrección de la sombra del 40 (10.63) · **ficha completa arriba** |
| **T-106** | RF-038 | 2.0 | Pulido del arrastre y del zoom (10.66): el aviso rojo sin claves internas ni frases que no aplican, el zoom a 300 % sin lienzo en blanco ni margen escalado, la descarga pendiente en el modo Carga, los 20 de las impares vecinas en la vista de una par y la copia que se arrastra a escala. Después de la demo; la hace Timonel y la acepta Codex (10.69); entregada sin colocar en 10.72; colocada en `ce13547` (10.74); terminada en 10.78 · **ficha completa arriba** |
| **T-107** | RF-038 | 3.0 | El encabezado del plano, compacto en pantallas angostas (el modo y un desplegable «Acciones» en una línea, el resumen en otra; Windows y la Web sin cambios), y los tres textos que dejó T-106: la etiqueta de accesibilidad y los avisos del deriver sin `C:`, y «re-estiba» sin partirse. Lo encontró Carlos en el Honor (10.76); la hace Timonel y la acepta Codex, antes del commit de cierre · **ficha completa arriba** |
| **T-108** | BAP | 2.5 | El lector avisa lo que no cumple el estándar (10.81): pesos en LBR y TNE a kg, posiciones mal formadas, dígito de control ISO 6346 y archivo incompleto, con aviso en la tarjeta del viaje. La hace Codex y la acepta Timonel, antes del commit de cierre · **ficha completa arriba** |
| **T-109** | TC | 1.0 | Estadísticas sin desbordes a 360 dp con letra 1.45 y 2.0, y el último guion de «re-estibas» en la política (10.81). La hace Codex y la acepta Timonel, antes del commit de cierre · **ficha completa arriba** |

### Ola 6 · Resto del ERS

#### T-56 · Las tomas de reefer: cargarlas por rangos y validarlas por celda, más siete arreglos pendientes · 3.5 h · Timonel (ficha completa, 15-oct)

**Para qué.** ERS, RF-027 (T-55, T-59). Viene del Sprint 2 (10.24 de `SPRINT-2.md`). Hoy las tomas se declaran una a una, con un campo de siete dígitos y «Agregar toma». Un inventario real de cientos de tomas no se carga así. Y el validador busca el código exacto, así que con un inventario **declarado** el mismo hueco físico con el otro tamaño da errores falsos: 91 en el escenario de T-55.

**Lo que hay hoy (Yov lo revisó en el repo, 15-oct):**
- **El modelo:** `VesselProfile.reeferSlots` es un `Set<String>` de códigos `BBBRRTT`, con `reeferSlotsOrigin`, que puede ser plantilla, propuesto o declarado.
  - Viaja a Firestore como una lista de cadenas, sin listas dentro de listas (2.3).
- **El validador,** `reefer_socket_validator.dart`, busca `hasReeferSocket(p.toIsoCode())`, el código exacto.
  - Sin toma, da error si el inventario está declarado y aviso si no.
- **La pantalla,** la sección de tomas de `vessel_geometry_page.dart`, tiene un chip por toma, el campo «Posición BBBRRTT», «Agregar toma» y la casilla «Declaro este conjunto de tomas para el buque».
- **La geometría no lista bahías.** `covers()` mira solo la fila y el nivel. Las bahías con bodega se deducen de los planes (`observedHoldBayNumbers`, T-83).

**Qué construye.**

1. **Validar por celda física, sin cambiar el modelo.** El código de siete dígitos ya dice todo lo que T-59 propuso guardar: una impar es un extremo, una par es la celda sin extremo, y una impar sola es la celda entera.
   - **Un reefer de 40, en la par E:** hay toma si existe el código de E, de E−1 o de E+1, con la misma fila y el mismo nivel. Un 40 se orienta hacia su toma (T-59).
   - **Un reefer de 20, en la impar b:**
     - hay toma si existe el código de b;
     - si solo existe el de una par vecina (b−1 o b+1), da **aviso** «La celda tiene toma, pero no consta en qué extremo: confírmalo», nunca error;
     - si solo existe el del otro extremo, sigue la regla de hoy: error con inventario declarado, aviso sin él.
   - **No se calcula «la par de una impar»:** se miran las dos vecinas. T-55 mostró que esa correspondencia es del buque. En ALFA, la 044 cubre a la 043 y a la 045, y la 041 va sola.
   - **La severidad no cambia** (T-39): error solo con inventario declarado.
   - Los textos dicen qué código se encontró, para que el usuario lo vea.
2. **Cargar por rangos.** Un formulario en la sección de tomas, con tres campos:
   - **bahías:** una lista de números y rangos con paso, por ejemplo `002-038/4, 041, 044`;
   - **filas:** `01-10`, todas las de la geometría o una lista;
   - **niveles:** por ejemplo `82-88` o `02-08`, de dos en dos por omisión.
   - **Genera los códigos de las bahías tal como se escriben,** sin calcular pares. Quien sabe el extremo escribe las impares, y quien no, las pares.
   - **Una vista previa,** antes de aplicar, dice cuántos códigos se agregan, cuántos ya estaban y cuántos se descartan porque su fila o su nivel caen fuera de la geometría. Muestra ejemplos de cada grupo.
   - **«Quitar por rango»** usa el mismo formulario, para corregir.
3. **Pegar una lista:** códigos separados por comas, espacios o saltos de línea. Los que no son de siete dígitos se reportan, y los que caen fuera de la geometría, se descartan con su cuenta.
4. **Cargar no declara.** La declaración sigue exigiendo la casilla que ya existe. Un inventario propuesto que se edita no pasa a declarado por sí solo.
5. **La prueba de las 21 bahías** (10.33, 10.38): un corpus nuevo que propone el perfil desde A07 ∪ A08 y afirma las 21 bahías con bodega, con su lista exacta. Es el conteo que T-83 verificó en pantalla en los tres clientes.
6. **Cinco textos y diseños pendientes:**
   - «1 contenedores» en Recientes pasa a «1 contenedor» (10.41);
   - el desplegable de tapas ya no corta «abierta» a 360 dp y letra 2.0 (10.41);
   - el chip del viaje no se sale de su fondo a letra 2.0 (10.41, 10.43);
   - la pantalla vacía dice «Contenido compatible: BAPLIE 2.x, y la 1.5 con aviso.» (10.43);
   - **el resumen de la escala cuenta los contenedores sin puerto de carga** (10.43). Hoy A06 da «0 se descargan · 0 se cargan · 0 de paso» en GTPBR con 717 a bordo, porque no trae `LOC+9` y `cargoCountsFor` no los cuenta en ninguna parte.
     - Cuando hay alguno, el resumen agrega «· N sin puerto de carga en el archivo»;
     - con reservas, una línea más.
     - Las demás cuentas no cambian.

**Carril.**
- Toca `lib/` (el validador, la sección de tomas, el resumen de la escala y los cinco textos), `test/t56_*` y `tool/t56_*`. Puede tocar las pruebas que fijan los textos que cambian.
- **No toca:**
  - el modelo del perfil ni su JSON;
  - el codec de Firestore ni las reglas;
  - `lib/main.dart`, los congelados ni `pubspec.*`.
- Sin dependencias nuevas.

**Detente y avisa si:**
- validar por celda exige cambiar el modelo o el JSON del perfil;
- el corpus da una alerta nueva que no se explica por la regla de celda;
- las 21 bahías no salen de A07 ∪ A08.

**Fuera de alcance:**
- guardar el extremo aparte;
- la tabla de pares en el perfil (T-59; queda para cuando haya un plano de tomas real);
- importar el plano de tomas desde un archivo.

**Terminada cuando:**
- [ ] **Las pruebas del validador** cubren:
  - el 40 en 022/07/04 con toma en 021, 022 o 023: conforme; sin ninguna: error con inventario declarado, aviso sin él;
  - el 20 en 021: conforme con 021; aviso «confirmar extremo» con solo 022; error con solo 023 si está declarado;
  - el 20 en la 041 sola: conforme con 041;
  - y el escenario de T-55 reproducido con datos sintéticos: los 82 errores pasan a avisos de extremo y los 9 a conformes.
- [ ] **El corpus:**
  - la regla de tomas, corrida antes y después sobre las fuentes con perfil propuesto, no da ninguna alerta nueva, y las que desaparecen se explican todas por la regla de celda;
  - las 21 bahías de A07 ∪ A08, con su lista.
- [ ] **En los tres clientes,** con un namespace propio (`t56acc`):
  - se cargan al menos cien tomas por rango en menos de un minuto;
  - la vista previa coincide con el conteo guardado;
  - pegar una lista con códigos inválidos los reporta;
  - quitar por rango funciona;
  - y la casilla de declaración sigue siendo la única que declara.
- [ ] **Los cinco textos** se ven en el Honor a 360 dp y letra 2.0, en claro y oscuro. A06 en GTPBR dice «717 sin puerto de carga en el archivo».
- [ ] **Validaciones:**
  - piso de 710 más las nuevas, y `analyze` en cero;
  - el corpus completo en verde, con los conteos declarados;
  - las reglas, el JSON del perfil, `lib/main.dart` y los congelados sin cambio.

#### T-96 · Comparar la llegada con la salida: qué bajó, qué subió y qué cambió en lo que sigue a bordo · 6.0 h · Timonel (ficha completa, 15-oct)

**Para qué.** ERS, RF-029 (COULD), diferido del Sprint 2. El planner recibe el BAPLIE de llegada y el plan de salida del planner de la línea, y hoy los compara a ojo. El caso ya trae la diferencia real (10.20, ratificada en 10.33): entre A07 y el plan, los 284 de paso difieren en POL (127), POD (189), línea (58) y peso (113). El detalle del plano de llegada muestra solo lo de la llegada (0020310: 24 260 kg en A07 y 24 200 en el plan).

**Lo que hay hoy (Yov lo revisó en el repo, 15-oct):**
- **El lector:** `VesselRepository.parseBaplieFile(content)` devuelve un `VesselVoyage`, con la 1.5 leída con aviso (T-103).
- **Abrir un archivo** pasa por `loadVesselFromFile` y `parseBaplieContent`, que confirman identidad y perfil y **publican** el viaje. Comparar no puede usar ese flujo.
- **`ContainerUnit`** trae `containerId`, `stowagePosition`, `isoSizeType`, `status` (lleno o vacío), `grossWeight`, `vgmWeight`, `portOfLoading`, `portOfDischarge`, `operatorCode`, las peligrosas (`dangerousGoods`, `unNumber`, `imdgClass`) y `temperature`.
- **Las reservas** (un `EQD` sin número, T-69) van en `reservedSlots`.
- **La identidad del buque** ya existe: `VesselIdentity`, por IMO, indicativo o nombre.
- **T-82** genera el BAPLIE de salida de una operación (`departure_baplie_page.dart`), y su corpus ya lo relee con el mismo lector.
- **Las cifras del caso:** A07 tiene 398 contenedores, 114 que se descargan en GTSTC y 284 de paso. A08 tiene 405: 121 que se cargan en GTSTC y 284 de paso, más 55 reservas.

**Qué construye.**

1. **Un servicio puro de comparación,** `domain/services/voyage_comparison.dart`. Recibe dos `VesselVoyage`, el primero y el segundo, y clasifica por número de contenedor:
   - **descargados:** solo en el primero;
   - **cargados:** solo en el segundo;
   - **permanentes:** en los dos.
     - De cada uno dice qué campos cambiaron: posición, ISO, lleno o vacío, POL, POD, línea, peso, peligrosas (números ONU y clases) y temperatura.
     - **El peso** es el efectivo de T-66 (`effectiveWeight`: el VGM si lo hay, si no el WT), el mismo que usa la app. En el detalle se muestran también el WT y el VGM cuando difieren.
     - Un campo que falta en uno de los dos archivos cuenta como cambio, y se muestra como «sin dato».
   - **Las reservas** no se comparan por número, porque no lo tienen. Se cuentan aparte, en cada archivo.
   - **Un número repetido dentro de un archivo** no se clasifica. Se reporta con su cuenta.
   - **Distinto buque:** si `VesselIdentity` no coincide, se compara igual, con un aviso visible arriba: «No parece el mismo buque: …».
   - **Es simétrico:** comparar B con A intercambia descargados y cargados, con los mismos cambios en los permanentes.
2. **Dos entradas:**
   - **Desde el viaje abierto,** en la barra: «Comparar con otro BAPLIE…».
     - Elige el archivo con el mismo selector, y lo lee con el lector **sin pasar por el flujo de carga**.
     - No confirma identidad ni perfil, no entra a Recientes, no se guarda ni sube.
     - El primero es el viaje abierto; el segundo, el archivo elegido.
   - **Desde el BAPLIE de salida de T-82:** «Comparar con la llegada».
     - Relee en memoria el texto generado y lo compara con la llegada de la operación. Así se ve lo que cambió en la escala.
3. **La vista comparativa,** una pantalla nueva:
   - **arriba, las cuentas:** por ejemplo, «114 descargados · 121 cargados · 284 permanentes, 256 con cambios», y las reservas aparte;
   - **un resumen por campo:** «POL 127 · POD 189 · Línea 58 · Peso 113…»;
   - **tres secciones,** cada una con su color **y con su rótulo o ícono**: el color nunca va solo (RNF-003);
   - **en los permanentes,** un filtro «Solo con cambios» y, por cada campo cambiado, «antes → después», por ejemplo «Peso 24 260 → 24 200 kg»;
   - **listas perezosas,** porque son cientos de filas;
   - **legible** a 360 dp y letra 2.0, en claro y oscuro.
4. **La observación de 10.20 queda resuelta aquí.** El detalle del plano de llegada sigue mostrando la llegada, que es lo correcto, y la diferencia con el plan se ve en la comparación.

**Las cifras que tiene que dar el caso** (un corpus nuevo, `tool/t96_corpus_test.dart`):
- **A07 → A08:**
  - 114 descargados;
  - 121 cargados, más 55 reservas en el segundo;
  - 284 permanentes, con POL 127, POD 189, línea 58 y peso 113, y 0 en posición, ISO y lleno o vacío. Son las cifras de 10.20, medidas contra el CSV, y A08 coincide con el CSV en 284/284 y siete campos. Si el 113 no sale con el peso efectivo, el informe dice con cuál sale.
- **A08 → A07:** lo mismo, intercambiado.
- **A07 → A08v_VGM:** la misma clasificación. El informe da las diferencias de VGM.
- **La operación de A07 con sus 177 eventos,** como en T-82: la salida generada contra la llegada da 114 descargados, 176 cargados (121 llenos y 55 vacíos asignados) y 284 permanentes, con las diferencias de 10.20.
- **Un archivo consigo mismo:** 0 descargados, 0 cargados y todos permanentes, sin cambios.
- **A05 → A06** (mismo buque, otro viaje; A06 es la 1.5): solo cuentas, sin cifra esperada. El informe las da, y el aviso de la 1.5 se ve.

**Carril.**
- **Nuevo:** el servicio, la pantalla, `test/t96_*` y `tool/t96_*`.
- **Toca:** `vessel_overview_page.dart` (la entrada) y `departure_baplie_page.dart` (la segunda entrada).
- **Codex está en T-105,** en `bay_plan_view.dart` y `change_requests*`. Antes de colocar, compara cada archivo que tocas con tu base: si alguno cambió en HEAD, te detienes y avisas.
- **No toca:** el lector, el escritor de T-82, el modelo, el codec, las reglas, `lib/main.dart`, los congelados ni `pubspec.*`. Sin dependencias nuevas.

**Detente y avisa si:**
- A07 → A08 no da 114, 121 y 284, o las diferencias no dan 127, 189, 58 y 113, y no puedes explicar por qué;
- comparar exige cambiar el lector o el modelo;
- la segunda entrada obliga a tocar el escritor de T-82.

**Fuera de alcance:**
- comparar más de dos archivos;
- exportar o guardar la comparación;
- el código viejo de `voyages` en `deleteVoyage` (10.18), que queda para el cierre.

**Terminada cuando:**
- [ ] **Las pruebas del servicio** cubren la clasificación, cada campo de cambio, el «sin dato», las reservas aparte, los repetidos, el distinto buque y la simetría.
- [ ] **El corpus** da las cifras de arriba, incluida la operación de 177 eventos.
- [ ] **En los tres clientes,** con un namespace propio (`t96acc`) y en modo sin cuenta:
  - con A07 abierto, comparar con A08 da las cuentas y el resumen por campo;
  - se ve un ejemplo: 0020310, peso 24 260 → 24 200 kg;
  - «Comparar con la llegada», desde la salida de T-82, da la misma clasificación;
  - el archivo comparado no aparece en Recientes ni en el almacén. En Windows, la huella antes y después, tomada fuera del paquete, suma solo `t96acc_*`.
- [ ] **En el Honor,** la pantalla a 360 dp y letra 2.0, en claro y oscuro.
- [ ] **Validaciones:**
  - el piso de HEAD más las nuevas, y `analyze` en cero;
  - el corpus completo en verde;
  - las reglas, `lib/main.dart`, `pubspec.*` y los congelados sin cambio.

#### T-95 · El orden de descarga sugerido, con las sobreestibas por columna y por tapa · 7.5 h · Timonel (ficha completa, 15-oct; pasa de Codex a Timonel en 10.61)

**Para qué.** ERS, RF-028 (COULD), diferido del Sprint 2. Dice: filtrar lo que se descarga en el puerto elegido, agrupar por bahía, ordenar cubierta antes que bodega y por nivel, y dar la secuencia con una estimación de movimientos. Lo que el planner necesita además, y la fila de T-95 lo pide, son **las sobreestibas**: lo que sigue a bordo y estorba. Hay dos clases:
- **por columna:** lo que va encima de un contenedor que baja, en la misma pila;
- **por tapa:** lo que va en cubierta sobre la tapa que hay que quitar para llegar a la bodega.

**Las tres definiciones de dominio, de Carlos (10.59):**
1. **Sobre una tapa van los de cubierta de las mismas filas que la tapa declara.** Las filas de afuera, sin bodega abajo, no estorban: se cuentan aparte, sin suponer.
2. **Las bahías se sugieren de la de más movimientos a la de menos.** Con empate, de proa a popa (el número de bahía, de menor a mayor).
3. **La estimación muestra las dos re-estibas:** a bordo, de celda a celda (1 movimiento), y por muelle, que sale y vuelve (2 movimientos, como registra hoy T-75). Cada tapa de grúa cuenta 2: quitar y reponer.

**Un supuesto de Yov, que Carlos puede corregir:** la tapa automática se abre sin grúa. Cuenta 0 movimientos, pero igual exige despejar la cubierta que va encima. La bodega abierta no tiene tapa.

**Lo que hay hoy (Yov lo revisó en el repo, 15-oct):**
- **El puerto:** el viaje ya usa la escala confirmada, `portOfCall` (T-68), para sus cuentas (`cargoCountsFor`). El puerto de descarga de cada contenedor es `portOfDischarge`.
- **La geometría:** `isDeckTier(tier)` separa cubierta de bodega, y `orderedRows` da las filas en orden.
- **Las tapas:** `VesselProfile.hatchCovers` es un `Map<int, HatchCoverDeclaration>` por bahía del BAPLIE (T-83).
  - Cada declaración es `openHold`, `automatic` (una tapa) o `crane` (de una a tres), con las filas que cubre cada tapa.
  - T-84 las identifica como `T:<bahía>-<número>` y las opera; `closedCoverAt` busca por bahía exacta.
  - **Ningún buque del corpus declara tapas reales.** Todas las de prueba son PROVISIONALES (T-83).
- **Los proveedores de descarga y carga** ya leen las tapas del perfil vigente (`discharge_provider.dart`, `loading_operation_provider.dart`).
- **El caso:** A07 tiene 114 descargas en GTSTC, 66 en cubierta y 48 en bodega (T-75).

**Qué construye.**

1. **La celda física, sin calcular pares** (la lección de T-55 y T-56).
   - **La huella de una bahía:** la de una impar b es {b}, y la de una par E es {E−1, E+1}.
   - **Dos posiciones están en la misma pila** si tienen la misma fila, la misma zona (cubierta o bodega) y huellas que se tocan.
   - Así, un 40 en la 02 va sobre los 20 de la 01 y la 03; un 20 en la 03 no va sobre uno en la 01; y en ALFA, la 044 va sobre la 043 y la 045, y la 041 queda sola. No hace falta ninguna fórmula.
2. **Un servicio puro,** `domain/services/discharge_sequence.dart`. Recibe el viaje, el puerto, la geometría y las tapas del perfil:
   - **Las descargas** son los contenedores con `portOfDischarge` igual al puerto. Los que no tienen posición o no tienen puerto de descarga se cuentan aparte. Las reservas no son contenedores y no entran.
   - **La sobreestiba por columna:** todo lo que no baja y está más arriba en la misma pila que una descarga.
   - **La sobreestiba por tapa:**
     - **Qué tapa hay que quitar.** Para cada descarga en bodega, la tapa que declara su fila, en una bahía cuya huella toca la suya.
     - **Qué la estorba.** Todo lo que no baja, está en cubierta, en una fila de esa tapa, y en una bahía cuya huella toca la de la tapa.
     - **Una misma tapa física, declarada varias veces.** Si se copió a la 01, la 02 y la 03, con las mismas filas y huellas que se tocan, se une en una sola, para no contarla tres veces. El reporte dice cuántas se unieron.
     - **Una descarga en bodega sin tapa declarada** da un aviso, sin movimientos de tapa.
   - **Una re-estiba se cuenta una sola vez,** aunque estorbe a varias descargas o sea de las dos clases.
   - **La secuencia, por celda física** (la par con sus impares):
     1. la cubierta, de nivel en nivel, de arriba abajo, y dentro del nivel por `orderedRows`. Cada re-estiba sale en su lugar, antes de lo que tiene debajo;
     2. lo que estorba sobre cada tapa, y después la tapa;
     3. la bodega, de arriba abajo;
     4. las re-estibas de bodega de vuelta, de abajo arriba;
     5. las tapas de vuelta;
     6. las re-estibas de cubierta de vuelta, de abajo arriba (10.65, a pregunta de Timonel: es el único orden físico posible).
   - **La estimación,** por celda y en total: descargas, más re-estibas (×1 a bordo y ×2 por muelle), más tapas de grúa ×2. Da los dos totales.
   - **El orden de las celdas:** de más a menos movimientos, con el total por muelle; con empate, de proa a popa.
3. **La pantalla «Orden de descarga»,** desde el viaje abierto:
   - **El puerto** es la escala confirmada, y se puede elegir otro de los puertos de descarga del archivo.
   - **Arriba, el resumen.** Por ejemplo, con cifras inventadas: «114 descargas · 9 re-estibas (6 por columna, 3 por tapa) · 4 tapas de grúa · 131 movimientos a bordo, 140 por muelle».
   - **Las celdas, en el orden sugerido.** Cada una con sus movimientos y sus pasos, y cada paso con su número, su posición y su rótulo: «Descarga», «Re-estiba: sale», «Tapa T1: quitar», «Tapa T1: reponer» o «Re-estiba: vuelve». El rótulo nunca va solo con color.
   - **Los avisos:** bodega sin tapa declarada, filas de cubierta fuera de las tapas y contenedores sin posición.
   - Listas perezosas, legible a 360 dp y letra 2.0, en claro y oscuro.
   - **La entrada:** en la fila de acciones del viaje, junto a «Comparar con otro BAPLIE…» de T-96 (10.61).

**Las cifras que tiene que dar el caso** (un corpus nuevo, `tool/t95_corpus_test.dart`):
- **A07 en GTSTC:** 114 descargas, 66 en cubierta y 48 en bodega.
  - Las re-estibas por columna las da el corpus, y las confirma **un cotejo independiente sobre el texto crudo**: `LOC+147` y `LOC+11` de cada grupo, sin el lector de BayStream, como el de T-56.
- **Cada fuente del corpus y cada puerto de descarga que traiga**, con estos invariantes:
  - cada contenedor de ese puerto aparece una sola vez como descarga;
  - cada re-estiba no baja, y está sobre una descarga de su pila o sobre una tapa que se quita;
  - ninguna descarga queda debajo de algo que no baja y no figura como re-estiba;
  - los totales suman.
- **Las tapas de A07,** con declaraciones PROVISIONALES en las 21 bahías con bodega:
  - las mismas tapas declaradas solo en las pares, o copiadas a las impares, dan el mismo resultado;
  - el informe da las cifras.

**Carril.**
- **Nuevo:** el servicio, la pantalla, `test/t95_*` y `tool/t95_*`.
- **Toca:** la entrada en `vessel_overview_page.dart`. T-96 la toca antes, así que la base es el HEAD con T-96.
- **No toca:**
  - el plano (`bay_plan_view.dart`): ver el orden en las celdas queda fuera;
  - el lector, el modelo, el perfil y su JSON, el codec y las reglas;
  - `lib/main.dart`, los congelados ni `pubspec.*`.
- Sin dependencias nuevas.

**Detente y avisa si:**
- el cotejo crudo no da las mismas re-estibas por columna que el servicio;
- A07 no da 114 descargas, 66 en cubierta y 48 en bodega;
- unir las tapas copiadas cambia el resultado frente a declararlas solo en las pares.

**Fuera de alcance:**
- el orden en las celdas del plano;
- las grúas y el reparto entre ellas;
- seguir el avance en vivo, que ya hace T-75: la secuencia es del archivo;
- la estabilidad y la escora;
- guardar o exportar la secuencia.

**Terminada cuando:**
- [ ] **Las pruebas del servicio,** con datos sintéticos, cubren:
  - un 40 que no baja sobre un 20 que baja (02 sobre 01): re-estiba por columna;
  - un 20 en la 03 sobre un 20 en la 01: no es la misma pila;
  - un 20 que no baja sobre un 40 que baja: re-estiba;
  - ALFA, sin fórmula: la 044 sobre la 043 y la 045, y la 041 sola;
  - una descarga en bodega con cubierta de paso sobre su tapa: re-estibas por tapa. La misma cubierta en una fila de afuera no cuenta, y se reporta;
  - la tapa automática: despeja la cubierta y cuenta 0. La bodega abierta: sin tapa. La tapa sin declarar: aviso;
  - las copias en la 01, la 02 y la 03 unidas en una tapa;
  - una re-estiba que estorba dos veces cuenta una;
  - el orden de las celdas por movimientos, con el empate de proa a popa;
  - los dos totales.
- [ ] **El corpus** da las cifras y los invariantes de arriba, con el cotejo crudo.
- [ ] **En los tres clientes,** con un namespace propio (`t95acc`) y en modo sin cuenta:
  - A07 en GTSTC muestra el resumen, las celdas en orden y sus pasos;
  - cambiar de puerto recalcula;
  - con las tapas PROVISIONALES, se ven las re-estibas por tapa.
- [ ] **En el Honor,** la pantalla a 360 dp y letra 2.0, en claro y oscuro.
- [ ] **Validaciones:**
  - el piso de HEAD más las nuevas, y `analyze` en cero;
  - el corpus completo en verde;
  - las reglas, el perfil y su JSON, `lib/main.dart`, `pubspec.*` y los congelados sin cambio.

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
| **T-95** | RF-028 | 7.5 | Orden de descarga sugerido, con sobreestibas por columna y por tapa, con las tres definiciones de Carlos (10.59). La hace Timonel y la acepta Codex (10.61); entregada en 10.69; terminada con la Web en 10.71 · **ficha completa arriba** |
| **T-96** | RF-029 | 6.0 | Comparación llegada contra salida: descargados, cargados y permanentes, con lo que cambió en cada campo. La hace Timonel y la acepta Codex (10.58) · **ficha completa arriba** |
| **T-56** | ERS | 3.5 | Tomas de reefer por celda y por rangos (diferida del Sprint 2). Incluye la prueba de corpus que afirma las 21 bahías de A07 ∪ A08 (10.33, 10.38); tres textos de la aceptación de T-104 (10.41): «1 contenedores» en Recientes, «abierta» cortado en el desplegable de tapas y el chip del viaje que se sale de su fondo; y dos de T-103 (10.43): «Contenido compatible: BAPLIE 2.x.» en la pantalla vacía, y el resumen 0/0/0 de A06 en GTPBR, que no trae `LOC+9`. La hace Timonel y la acepta Codex (10.52); entregada en 10.57, con una corrección antes de la aceptación · **ficha completa arriba** |
| **T-97** | ERS | 1.0 | Título sin truncar a 360 px (RNF-003). Incluye los textos de 10.11 a 10.16: la fila del detalle que no se adapta con letra grande, «1 cargados» en singular, «(0 cub. / 0 bod.)», que debe decir que son pendientes, el punto doble al final de un rechazo y «Conectando…» en lugar de «Sin conexión» al abrir un plano en la Web · **ficha completa arriba** |
| **T-104** | ERS | 2.5 | Deudas del lote de Timonel: aislar `block3` del almacén real, «1 bahías», las extensiones de la pantalla inicial y los cortes a 200 % (10.38); la prueba intermitente, los dos `print` y el `LEEME` del SDK (10.39) · **ficha completa arriba** |

### Cierre · Calidad, entregables y piloto (21–24 oct)

#### T-98 · RNF primera parte: seguridad, tolerancia a fallos, estándares y usabilidad, medidos sobre los binarios de cierre · 26.0 h · Codex (ficha completa, 16-oct; la acepta Timonel)

**Para qué.** Es lo primero de la lista de 4.2: lo que se entrega el 24-oct. Mide RNF-004, 006, 008 y 002 con los criterios de `docs/T63-CRITERIOS-RNF.md` y las decisiones de `docs/T63-DECISIONES-RNF.md`, que Carlos confirmó el 5 y el 6-oct.
- Los criterios ya están decididos y **no se ajustan después de ver los datos**.
- Si uno no se puede aplicar tal como está, se declara cuál y por qué.

**Lo que hay hoy (Yov lo revisó en el repo, 16-oct):**
- **T-44** (`docs/T44-FINAL-RESULTADOS.md`) dejó:
  - 004 y 006, «no medibles»;
  - 008, «no cumple» por IMDG;
  - 002, «no cumple» por pasos: 5 y 6 sin perfil.
- **Lo que cambió desde entonces:**
  - la sincronización y las cuentas (T-79, T-80 y T-81), así que TLS y credenciales aplican (4.3);
  - la versión por la cabecera y el rechazo con mensaje (T-86 y T-103);
  - la validación por contenido (T-89);
  - la Web sin conexión (T-92);
  - el IMDG 42-24 (T-85, en revisión).
- **Las sondas que ya existen:** `tool/t44_honor_red.ps1`, para el TCP del Honor. No hay sonda de Windows.
- **`integration_test/` no existe.** Agregarlo cambia `pubspec.yaml`, así que no se usa sin autorización de Carlos.

**Dos fases.**
- **Fase A: los instrumentos, desde ya y sin binarios de cierre.**
  - Se arman los scripts, el catálogo y la batería, y se ensayan sobre HEAD.
  - Lo que salga del ensayo no es un resultado y no se informa como tal.
  - **No usa el Honor antes de que termine la demo del 17.**
- **Fase B: la medición, sobre los binarios de cierre.**
  - Carlos anuncia el commit de cierre cuando T-85 y T-106 estén terminadas, y también T-107 si Carlos la crea. La meta es el 19-oct.
  - Se compila en una copia limpia de ese commit, con el namespace `t98`, y se mide.

**Qué construye y qué mide.**

1. **RNF-004 · Seguridad de los datos.**
   - **Las operaciones básicas (4.1):**
     - cargar un BAPLIE y confirmar el perfil;
     - ver el Bay Plan y navegar las bahías;
     - Lista y filtros, y la búsqueda;
     - Estadísticas y Alertas de estiba;
     - exportar;
     - reabrir un viaje reciente;
     - Parámetros del buque.
   - **Dos condiciones:**
     - **(A) sin sesión:** rige el 100 %;
     - **(B) con sesión y fuera de una operación compartida:** solo informativa.
     - La sincronización de una operación transmite por diseño y se mide solo con TLS.
   - **Los instrumentos:**
     - **Web:** HAR, y `chrome://net-export`. Hay que comprobar si el NetLog incluye al service worker, y decirlo.
     - **Android:** `dumpsys netstats detail` por UID, antes y después de cada operación. La sonda TCP de T-44 queda como segunda fuente.
     - **Windows:** una sonda nueva, `tool/t98_sonda_red_windows.ps1`, que muestrea `Get-NetTCPConnection` y `Get-NetUDPEndpoint` filtrados por el PID.
   - **Qué es transmitir (4.2):** toda petición que lleve contenido del archivo o derivado de él, o que escriba en un servicio remoto. Las descargas del sitio, del motor y de las fuentes no cuentan.
   - **TLS:**
     - la versión negociada, en el panel Security de Chrome;
     - `openssl s_client -tls1_1` contra los hosts que usa la app (Firestore, Identity Toolkit y Secure Token), que tiene que fallar;
     - es solo el saludo TLS: sin credenciales ni datos.
   - **Credenciales:**
     - el inventario de qué guarda la app y dónde, en cada plataforma, con la fuente de cada afirmación;
     - sin abrir ningún contenido;
     - con su dictamen contra «mecanismos nativos seguros».

2. **RNF-006 · Tolerancia a fallos.**
   - **El catálogo** lo genera `tool/t98_catalogo_invalidos.dart` a partir del corpus. La salida va a %TEMP%, nunca al repo. Lleva un caso de cada uno:
     - bytes aleatorios;
     - texto sin estructura EDIFACT;
     - A01 cortado a mitad de un segmento;
     - A01 sin `UNT`/`UNZ`;
     - A01 sin `TDT`;
     - un `COPRAR` sintético;
     - un BAPLIE de una versión no admitida;
     - un archivo vacío.
   - **El inventario de todos los mensajes de error que `lib/` puede mostrar:**
     - cada mensaje lleva la marca de si dice la causa y la acción y, si es de parseo, el segmento;
     - el script va en `tool/` y la tabla en el informe.
   - **La recuperación, < 3 s:**
     - desde que se confirma el archivo hasta que el error se ve con la app operativa: el viaje anterior a la vista y el botón de carga que responde;
     - en video, cuadro a cuadro, con la tasa real de cuadros de cada video;
     - una medición por archivo y por cliente.
   - **La disponibilidad (6.1 a):** las operaciones básicas sin red, con el modo avión en el Honor, y con la red desconectada en Windows y en la Web después de cargarla.

3. **RNF-008 · Estándares.**
   - **La batería, en `test/t98_estandares_test.dart`,** con casos sintéticos positivos y negativos:
     - BBBRRTT;
     - ISO 6346, con dígitos de control calculados, válidos y alterados;
     - el peso en `KGM` y en otra unidad, y el VGM;
     - la estructura de BAPLIE 2.2.1 según la guía de SMDG.
   - **Contra el corpus, en `tool/t98_estandares_corpus.dart`:**
     - que cada segmento y cada grupo de la guía aparezca en algún archivo;
     - que toda posición se descomponga en BBBRRTT;
     - que los puertos estén en la lista UN/LOCODE;
     - aparte, el porcentaje de IDs con dígito válido, con la advertencia de que el corpus está anonimizado.
   - **La lista UN/LOCODE** es la oficial de UNECE, con su edición anotada. Vive fuera del repo, en `C:\Proyectos\baystream-privado\unlocode\`. Si la red del agente no llega, la descarga Carlos.
   - **El IMDG:**
     - se citan el comprobador de T-85 (289/289 y 60/60) y sus pruebas;
     - las disposiciones especiales por número ONU siguen «no evaluadas», así que 008 queda en «no cumple» (8.1).
   - **Si la app acepta sin aviso un caso negativo,** es un caso fallido: se informa y no se corrige.

4. **RNF-002 · Usabilidad.**
   - **Pasos y tiempo:**
     - las condiciones (i) sin perfil, que es la que rige, y (ii) con perfil;
     - en los tres clientes, con cinco repeticiones grabadas por condición;
     - el inicio es el toque en el ícono y el fin, el primer cuadro con la rejilla del Bay Plan (2.2 a);
     - un paso es cada toque o clic en un control propio, o cada decisión en un diálogo. El selector de archivos cuenta como uno.
   - **El idioma:**
     - el inventario de las cadenas visibles de `lib/`, con un script en `tool/`, y el recorrido de las rutas de error;
     - métrica: cadenas en español / cadenas visibles.
   - **Material 3 (2.4 a):**
     - una lista, pantalla por pantalla, de los controles interactivos: si cada uno es un componente de la biblioteca Material y si su color sale de `colorScheme`;
     - se cuentan las excepciones;
     - la rejilla se excluye, y se dice por qué.
   - **Para el piloto (T-101):**
     - la lista fija de tareas: cargar A01, ver una bahía, encontrar un contenedor por ID, identificar un refrigerado y leer una alerta;
     - la hoja de tiempos;
     - el cuestionario SUS en español, con su fuente.
     - Los aplica Carlos con cinco participantes de COMAR. T-98 deja lista la sección del informe para sus resultados.

**El informe: `docs/T98-RESULTADOS.md`.**
- Una tabla por RNF, con la submétrica, el umbral, la medición y el dictamen.
- El dictamen del RNF completo: cumple, no cumple o no medible.
- Donde una decisión de T-63 no se pudo aplicar, se dice cuál y por qué.
- La evidencia (videos, HAR, NetLog, netstats y capturas) va en %TEMP%, sanitizada, y el informe cita la ruta.

**Carril.**
- **No toca** `lib/`, el codec, las reglas, `lib/main.dart`, los congelados ni `pubspec.*`. Sin dependencias nuevas.
- **Toca:** `test/t98_*`, `tool/t98_*` y `docs/T98-RESULTADOS.md`.
- **Puede ir en paralelo** con T-107 y con la aceptación de T-85, porque no toca `lib/`, pero respeta el semáforo de Flutter.
- **Los clientes:**
  - namespace `t98`, sin tocar las apps reales ni las `demo17`;
  - Windows, abierta con `explorer.exe` y cerrada por PID;
  - el Honor, en 1.0 al terminar y con volcados sanitizados.
- **Firebase:** las mediciones con sesión usan una operación de prueba, «PRUEBA T-98», que crea Carlos. Nada por CLI ni por consola.
- **Si no hay con qué grabar la pantalla de Windows,** avisa antes de instalar nada.

**Detente y avisa si:**
- una medición exige cambiar `lib/`;
- una operación básica transmite en la condición A. Es un resultado, pero Yov tiene que verlo antes de seguir;
- no se consigue la lista UN/LOCODE;
- un criterio de T-63 no se puede aplicar tal como está.

**Fuera de alcance:**
- 6.1 (b), la disponibilidad a lo largo de semanas;
- RNF-001, 003, 005 y 007, que son de T-99;
- corregir cualquier defecto que aparezca: se anota para Yov.

**Terminada cuando:**
- [ ] **Fase A:**
  - los scripts y la batería existen y pasan sobre HEAD, con `analyze` en cero;
  - el piso de pruebas sube con la batería.
- [ ] **Fase B:** las cuatro tablas, con evidencia en los tres clientes y sobre los binarios de cierre.
- [ ] **El informe,** con dictámenes y limitaciones, y la sección del piloto lista para el SUS.
- [ ] **La aceptación de Timonel:** repite por su cuenta una fila de cada RNF y lo anota.

| Tarea | Elemento | h | Qué |
|---|---|---:|---|
| **T-98** | TC | 26.0 | RNF primera parte sobre los binarios de cierre: 004 (con TLS y sesión), 006, 008 y 002 (SUS en el piloto), según `docs/T63-DECISIONES-RNF.md`. La hace Codex y la acepta Timonel (10.73), en dos fases · **ficha completa arriba** |
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

### 10.41 · T-94 y T-104 terminadas · T-103 se adelanta para Timonel · El repositorio pasa a privado (15-oct)

**Timonel aceptó las dos** (commit `83b4645`, `docs/T94-T104-ACEPTACION-RESULTADOS.md`), sobre una copia exacta de `7c939e6`, en ≈ 0.55 h.
- **T-94 pasa a Terminado.**
  - Sin red, con modo avión, el Wi-Fi apagado y un `ping` que falla, y con la voz de Carlos: 3 de 3 intentos muestran «Reconocimiento en español no disponible. Puedes escribir la búsqueda.» debajo de Buscar.
  - «5568» encuentra el OR 3 sin red, y con red el dictado queda como borrador.
- **T-104 pasa a Terminado, aceptada con observación.**
  - **El almacén real:** la huella queda idéntica tras dos corridas de los 31 corpus (316 archivos, 116/116 en cada una), tomada fuera del paquete.
  - **La salvaguarda** pasa 5 de 5, más una sonda propia 3 de 3.
  - **La suite** da 685/685 tres veces seguidas, con la prueba de los guardados simultáneos en verde.
  - **El reintento de compactación,** revisado contra `hive_ce` 2.20.0: acotado a 5 intentos y 375 ms, solo para el error 5 en Windows, sin repetir ni perder guardados.
  - **El Honor a 2.0,** en los dos temas: pasan las pestañas, las tarjetas, «1 bahía» y el inicio.
- **Tres observaciones fuera del catálogo, que pasan a T-56** (suma 0.5 h y queda en 3.0 h):
  - «1 contenedores» en Recientes;
  - el desplegable de tapas, que corta «abierta»;
  - el chip «VIAJE007A», que se sale de su fondo.
- **Una incidencia menor:** Timonel volvió a ejecutar `git rev-parse`, que solo lee. Queda anotado y la lista no cambia.

**T-103 se adelanta** (ficha completa en la Ola 4). 10.35 la había dejado para después del 17-oct, por carga.
- Timonel está libre, y la rama principal sigue congelada para la presentación (2.2), así que trabajar en `sprint-3` no la toca.
- **Va a Timonel ahora.** Su aceptación cruzada la hace Codex.
- **Al mismo tiempo, Codex acepta T-93.** Para no cruzarse:
  - Codex compila y prueba desde una copia exacta de HEAD, porque Timonel va a tocar `lib/` y `test/`;
  - Timonel no abre la app de Windows mientras Codex tenga apartado el almacén real;
  - un comando de Flutter a la vez, con el semáforo de Carlos.

**El repositorio de código pasa a privado** (Carlos, 15-oct, 02:07), para que no copien la idea.
- **Las reglas de 2.4 no cambian:** nada de datos reales ni del corpus en el repo. La historia estuvo pública semanas, y el repo podría volver a abrirse.
- Ningún entregable del curso enlaza al repo, así que el 17-oct no se rompe nada.
- **Carlos creó aparte un repo público de portafolio,** `YovaWarrior/BayStream`, sin licencia y sin código. Tiene el README que escribió Yov, con cuatro capturas de A07 y A08, que son datos anonimizados. Su enlace va en LinkedIn.
- **Queda pendiente:**
  - la alerta de «Security and quality» (1) del repo privado. Probablemente es la clave web de Firebase del proyecto de H5 en la historia (10.36 del Sprint 2); Carlos la revisa;
  - agregar al tutor como colaborador de lectura, si va a revisar el código.

**El sprint queda en 42 tareas y ≈ 155.5 h.** El tablero suma 210.5 h:
- 30 terminadas;
- T-93 en revisión;
- T-103 en curso;
- 10 por hacer.

### 10.42 · T-93 no pasa la aceptación por el control de firma del script · Codex lo corrige ahora y Timonel lo verifica al entregar T-103 (15-oct)

**Codex aceptó T-93** (commit `0cd6074`, `docs/T93-ACEPTACION-RESULTADOS.md`) sobre una copia exacta de `bd09a4d`: 555 archivos, idénticos a HEAD también al terminar. Veredicto: **no pasa**, por un solo punto.
- **Pasa todo lo que pide la ficha:**
  - el doble clic con App Installer, la entrada en Inicio y Firebase;
  - A07 con 398 / 21 / 6940.6 t / 0-114-284, también al reabrir por PID y después de actualizar;
  - «PRUEBA T-84» en «Al día», con 4 / 3 / 20.0 t / 0-3-1, con la sesión que inició Carlos y sin movimientos;
  - la actualización a 1.0.2.0, que conserva los dos viajes, Recientes y la sesión;
  - la desinstalación, que borra el paquete, su carpeta privada y la entrada de Inicio;
  - el almacén real, apartado antes de instalar y devuelto con la misma huella (316 archivos), tomada fuera del paquete;
  - 685/685, T-93 5/5, `analyze` en cero y corpus 116/116.
  - Los dos paquetes originales tienen firma `Valid`, con `CN=BayStream` y la huella de Carlos.
- **No pasa el control de firma de `tool/t93_msix.ps1`.**
  - Muestra el estado de la firma, pero solo se detiene si la huella es otra.
  - Codex cambió un bit de una copia del paquete: la firma quedó `HashMismatch` con la misma huella, y la condición del script no la rechazó.
  - La copia nunca se instaló.

**La lectura de Yov.**
- **La ficha no pedía ese control,** y el informe de Timonel describe el script tal como es: «termina con error si la firma no es de esa huella». Ningún criterio de la ficha falla.
- **Aun así, Codex tiene razón.** Un script que imprime «Firma: HashMismatch» y termina bien da una confianza que no merece. Windows no instalaría ese paquete, así que el riesgo es bajo, y la corrección cuesta poco.
- **T-93 sigue En revisión** hasta que se corrija y se verifique, como T-94 en 10.38.

**Quién la corrige: Codex, ahora, porque está libre** (la ficha va al final de la de T-93).
- Toca solo `tool/t93_msix.ps1` y la prueba que ya existe en `test/t93_msix_config_test.dart`. No hay pruebas nuevas: la suite sigue en 685.
  - Ninguno de los dos archivos es de T-103, así que no se cruza con Timonel.
  - Trabaja en una copia de HEAD en `%TEMP%`, y pone sus archivos en el repo solo al final.
  - No instala nada ni toca el almacén real.
- **Timonel la verifica** cuando entregue T-103. La corrección no es suya, así que la aceptación sigue siendo cruzada. Después, Codex acepta T-103.
- **Sin estimación nueva:** es parte de T-93, igual que la corrección de T-94.

**Dos notas.**
- **El commit `0cd6074` salió sin el prefijo «Sprint 3:».** Ya está en el remoto y no se reescribe. El próximo bloque de Codex lo lleva.
- **El respaldo del almacén de la aceptación** sigue en `%TEMP%\baystream-t93acc-respaldo\`. Carlos lo borra cuando T-93 quede terminada.

**El sprint sigue en 42 tareas y ≈ 155.5 h.** El tablero mantiene sus 210.5 h:
- 30 terminadas;
- T-93 en revisión;
- T-103 en curso;
- 10 por hacer.

### 10.43 · T-103 entregada, en revisión: A06 vuelve a abrir con su aviso · La corrección de T-93, entregada · Dos observaciones más para T-56 · T-88 pasa a Timonel (15-oct)

**Timonel entregó T-103** (commit `3696930`, `docs/T103-RESULTADOS.md`), en ≈ 0.75 h de 1.0. Queda **En revisión**: la acepta Codex.
- **El lector acepta exactamente `BAPLIE:1:911:UN:SMDG15`,** con las mismas condiciones de cabecera que T-86.
  - Cualquier otra 1.x, la 3.x, las variantes de la 1.5 con otra versión o liberación y lo que no trae UNH se rechazan con el mensaje de T-86, sin cambiarlo.
- **A06 vuelve a abrir con sus cifras de `1b1be4b^`:** 717 contenedores, 27 bahías, 10 766 933 kg y 1 DGS.
  - Timonel no las tomó solo de los informes de entonces: ejecutó el lector de `1b1be4b^` y el viaje completo sale igual, salvo los UUID.
- **El aviso** «Versión 1.5, leída con las reglas de 2.x; revisa pesos y peligrosas» va fijo arriba del resumen del viaje y se conserva desde Recientes.
  - Sale de la versión del UNH que ya se guardaba (`messageVersion`): no hay campo nuevo ni cambio de esquema.
- **La salida de T-82 se niega** desde una fuente 1.5, sea el plan de carga o la llegada, con un mensaje que dice por qué. El escritor no cambia: mismo SHA.
- **Las pruebas que exigían el rechazo de A06 exigen ahora la lectura con aviso.** Las de rechazo usan una 1.x sintética, `SMDG10`, y el bloque 7 vuelve a 34 DGS en 30 unidades.
- **Las nueve 2.x salen idénticas** a la referencia tomada antes de tocar el lector.
- **Validaciones:**
  - **697/697, el piso nuevo** (12 nuevas), dos veces;
  - `analyze` en cero;
  - corpus 118/118 en 32 archivos;
  - reglas, `lib/main.dart`, `pubspec.*`, el escritor y los congelados sin cambio.
- **Los clientes:**
  - la Web, en el navegador integrado de la app (Chromium);
  - Windows, con `t103acc` sobre el almacén real: 316 archivos antes y 328 después, y los 12 nuevos son solo `t103acc_*`;
  - el Honor `.t103` a 360 dp.

**La revisión de Yov.**
- **El código es corto y está donde debe:** cuatro rutas de `lib/`, sin tocar el escritor.
- **Un borde que la aceptación debe mirar, no corregir:**
  - el aviso se decide con `messageVersion == '1'`;
  - un viaje guardado antes de T-86 desde otra 1.x mostraría el aviso de la 1.5;
  - es un aviso de más, no de menos, y en los almacenes solo hay datos de prueba.
- **La Web se probó en el navegador integrado, no en Chrome.** Vale como cliente Web, y la aceptación de Codex la hace en Chrome, para cubrir los dos.
- **Una incidencia que Timonel declaró:** le pidió a Carlos bajar la letra del Honor sin que hiciera falta. Volvió a 2.0. Carlos la deja en 1.0, su valor normal, antes de la aceptación.

**Dos observaciones más, que pasan a T-56** (suma 0.5 h y queda en 3.5 h):
- **La pantalla vacía dice «Contenido compatible: BAPLIE 2.x.»** Ahora la 1.5 también se lee, con aviso.
- **A06 da «0 se descargan · 0 se cargan · 0 de paso» en GTPBR,** con 717 a bordo.
  - No trae `LOC+9`, así que la escala no clasifica sus contenedores.
  - Ya pasaba antes de T-86.
  - Yov lo revisa al escribir la ficha de T-56: si el resumen tiene que decir algo en vez de 0/0/0, va ahí.
- **El chip del viaje que se sale de su fondo a letra 2.0** ya estaba en T-56 (10.41).

**La corrección de T-93 llegó mientras se escribía esta decisión** (commit `f52570b`, `docs/T93-CORRECCION-RESULTADOS.md`). Codex la hizo en ≈ 0.16 h, sobre una copia exacta de `0b7f539`.
- **Una sola función, `Test-PaqueteMsix`,** exige el SHA igual al del `.sha256`, la firma `Valid` y la huella. El armado y el modo `-Verificar` la comparten.
- **Las cuatro sondas dan 0 / 1 / 1 / 1,** en Windows PowerShell 5.1, sin Flutter en el `PATH`: el original pasa, y fallan la firma alterada, el SHA que no coincide y la otra huella. `-SinCompilar` termina en 0 con la verificación en verde.
- **Validaciones:** 685/685, T-93 5/5, `analyze` en cero y el script en ASCII. El prefijo «Sprint 3:» ya va en el commit.
- **La revisión de Yov:** el cambio es correcto. Le queda un matiz.
  - El mensaje de «importa primero `BayStream.cer`» solo sale con el estado `NotTrusted`.
  - En un equipo sin el `.cer`, Windows probablemente da `UnknownError`, que cae en el mensaje genérico, aunque el `StatusMessage` que se imprime sí lo explica.
  - Timonel lo comprueba en la documentación o el código de PowerShell, sin tocar almacenes de certificados. Con eso, Yov decide si es una observación o una línea más.

**El orden desde aquí:**
1. **Al mismo tiempo:**
   - Timonel verifica la corrección de T-93 con el script commiteado. No necesita Flutter, la app ni el almacén.
   - Codex acepta T-103 desde una copia exacta de HEAD, con su propio namespace, `t103cx`.
2. **T-88 pasa a Timonel,** porque es el primero que queda libre. La acepta Codex. Yov escribe ahora su ficha, y la parte del ícono espera la respuesta de Carlos.

**El sprint queda en 42 tareas y ≈ 156.0 h.** El tablero suma 211.0 h:
- 30 terminadas;
- 2 en revisión: T-93 y T-103;
- 0 en curso;
- 10 por hacer.

### 10.44 · T-93 terminada · La ficha de T-88, completa, para Timonel · El correo de la política, la única dirección autorizada en el repo (15-oct)

**Timonel verificó la corrección de T-93** (commit `140129b`, `docs/T93-CORRECCION-ACEPTACION.md`), en ≈ 0.10 h. Pasa.
- **El cambio cumple la ficha punto por punto.**
- **Repitió las cuatro sondas** con el script commiteado, en Windows PowerShell 5.1 con su módulo nativo: 0 / 1 / 1 / 1. Ninguna copia se instaló.
- **El matiz de 10.43, confirmado en el código de PowerShell** (`GetSignatureStatusFromWin32Error`):
  - `NotTrusted` solo sale con una desconfianza explícita;
  - una raíz que no está en ningún almacén queda en `UnknownError`;
  - en una PC sin el `.cer`, el script falla bien, pero con el mensaje genérico.
  - Que la 5.1 haga lo mismo es inferencia, porque su código no es público. Timonel lo declara así.

**T-93 pasa a Terminado, aceptada con observación.**
- La observación es una línea: que `UnknownError` también dé la indicación de importar `BayStream.cer`, sin afirmar la causa. Va dentro de T-88, de paso, y la acepta Codex.
- **Horas reales:** ≈ 0.9 h de Timonel, 0.16 h de la corrección de Codex y 0.10 h de la verificación. Unas 1.2 h, frente a 2.5.
- Carlos ya puede borrar el respaldo de `%TEMP%\baystream-t93acc-respaldo\`.

**La ficha completa de T-88** está en la Ola 5. Va a Timonel ahora, y la acepta Codex.
- **El texto de la política lo escribió Yov,** y va palabra por palabra en una sola fuente de `lib/`. De ahí salen la pantalla y `web/privacidad.html`, y una prueba exige que no se separen. Cubre:
  - el uso sin cuenta;
  - las cuentas y la sincronización con Firestore;
  - el micrófono opcional y el servicio de voz;
  - la falta de respaldo (D3);
  - la Web servida desde su sitio;
  - el contacto.
  - Si una frase resulta falsa frente al código, Timonel se detiene y Yov la corrige.
- **D1:** la dirección pública es `/privacidad.html` de la Web, que Carlos publica con T-92.
- **D2, el correo de contacto:** lo escribe Carlos directamente en el prompt de Timonel.
  - **Es la única dirección de correo autorizada en el repo,** porque es pública por definición: sale en la política y en la ficha de Play.
  - Yov recomienda una dirección del proyecto, no la personal.
- **D9:** «BayStream» bajo el ícono, como en Windows y en la interfaz.
- **T-88 incluye además el inventario del APK release de hoy:** permisos, respaldo y dependencias de Firebase. Con él, Yov escribe después las declaraciones de Play.
- **El ícono (D5) espera a Carlos:** su logo o uno original de Yov, y si autoriza `flutter_launcher_icons` como dependencia de desarrollo. Si no llega a tiempo, va en una segunda entrega de T-88.

**El sprint sigue en 42 tareas y ≈ 156.0 h.** El tablero suma 211.0 h:
- 31 terminadas;
- T-103 en revisión;
- T-88 en curso;
- 9 por hacer.

### 10.45 · T-103 terminada · El ícono lo diseña una sesión aparte de Claude en la nube, y entrega todos los tamaños sin dependencia nueva (15-oct)

**Codex aceptó T-103** (commit `7952c0f`, `docs/T103-ACEPTACION-RESULTADOS.md`) sobre `842dcb8`, en ≈ 0.60 h.
- Trabajó desde una copia de 562 archivos de ese commit, con sus propias referencias.
- **Pasan:**
  - las referencias históricas;
  - las validaciones;
  - los tres clientes: Chrome, Windows con `t103cx` y el Honor.
- **El detalle de cada cliente:**
  - A06 conserva su aviso al reabrir desde Recientes, después de reiniciar cada cliente. En el Honor, también sin red.
  - En Windows, el almacén real conserva sus 328 archivos y suma solo los 12 de `t103cx`, con los movimientos en cero bytes.
  - La salida se niega desde una 1.5, como plan o como llegada, y los tres rechazos conservan A06.
- **El borde de 10.43** (`messageVersion == '1'`) queda documentado, sin corregir.

**T-103 pasa a Terminado.** Horas reales: ≈ 0.75 h de Timonel y 0.60 h de la aceptación, frente a 1.0.

**El ícono (D5).** Carlos quiere uno bonito, original y que dé la mejor impresión. Lo diseña **una sesión aparte de Claude en la nube**, pagada con los créditos de sesiones en la nube de Carlos, que vencen el 5-nov.
- **Trabaja sin acceso al repo:** su prompt trae todo el contexto, y Yov lo escribe.
- **Primero entrega tres conceptos,** en una página con cada uno a todos los tamaños, sobre claro y oscuro, en las máscaras de Android y en monocromo. Carlos elige uno.
- **Después entrega el paquete completo:**
  - el SVG maestro;
  - el ícono adaptativo de Android, con su capa monocroma, y los PNG antiguos;
  - los íconos de la Web, incluidos los `maskable`;
  - el `.ico` de Windows;
  - el PNG de 512×512 para Play y, si da tiempo, el gráfico de 1024×500;
  - un `LEEME.md` con los tamaños y los SHA-256.
  - Va en un zip con las rutas del repo, y el script que lo genera queda en el paquete.
- **Como el paquete trae todos los tamaños, no hace falta `flutter_launcher_icons`:** no hay dependencia nueva.
- **Carlos guarda el zip en `C:\Proyectos\baystream-icono\`,** fuera del repo y fuera de `baystream-privado`.
- **Timonel lo integra en una segunda entrega de T-88** y lo comprueba en el Honor, en Chrome, en Windows y en el MSIX. La acepta Codex.
- **Las horas del diseño se anotan en el informe de T-88.** La estimación no cambia.

**El sprint sigue en 42 tareas y ≈ 156.0 h.** El tablero suma 211.0 h:
- 32 terminadas;
- T-88 en curso;
- 9 por hacer.

### 10.46 · Tres frases de la política, corregidas para Windows y la Web (15-oct)

**Timonel se detuvo,** como pide la ficha de T-88: tres frases de la política son falsas en Windows o en la Web. Sigue con lo que no depende de ellas.

**Yov las corrigió en la ficha,** contra el código:
- **Dónde se guarda:**
  - en Windows, el almacén está en la carpeta de datos del usuario, que no es un almacenamiento privado de la app (10.37);
  - en la Web, Firestore no guarda copia sin conexión, porque no se activa la persistencia;
  - el texto ahora distingue las tres plataformas.
- **Cómo se borra:**
  - en Windows, desinstalar puede dejar la carpeta de BayStream y la caché de Firebase (10.37);
  - el texto dice cómo quitarlas, y pide cerrar sesión antes de desinstalar.
- **Exportar:**
  - en la Web, `FilePicker.saveFile` no abre un selector: el navegador lo descarga.
- **Timonel solo puede ajustar** los dos nombres de carpeta de Windows, tras verificarlos sin abrir su contenido, y lo declara.
- Si alguna de sus tres frases era otra, no la toca: la reporta con su evidencia.

**El sprint sigue en 42 tareas y ≈ 156.0 h.** El tablero no cambia.

### 10.47 · T-88 entregada sin el ícono · Cinco cambios a la política y el título de la ventana de Windows, antes de la aceptación (15-oct)

**Timonel entregó T-88 sin el ícono** (commit `b9eb72d`, `docs/T88-RESULTADOS.md`), en ≈ 1.0 h. Lo que entregó:
- **La fuente única del texto** está en `lib/core/constants/privacy_policy.dart`, y el HTML lo arma `lib/core/utils/privacy_policy_html.dart`.
- **`tool/t88_privacidad.dart`** escribe `web/privacidad.html`, y con `--comprobar` solo los compara.
- **Las dos entradas:** Parámetros → «Política de privacidad», y Nube y cuenta → inicio de sesión → «Política de privacidad». Ninguna pide viaje ni sesión.
- **Usó el texto de 10.46 palabra por palabra.** Solo ajustó la ruta de la caché de Firestore en Windows, después de verificarla sin abrir su contenido.
- **D3:**
  - `allowBackup="false"` y `dataExtractionRules`, que excluyen los nueve dominios en la nube y en la transferencia. Cita la documentación de Android.
  - En el Honor, el paquete ya no tiene `ALLOW_BACKUP`.
  - `bmgr` no sirve como prueba en ese teléfono, así que basta el manifiesto, como permite la ficha.
- **D9:** «BayStream» bajo el ícono del Honor. La ventana de Windows todavía dice «baystream».
- **Los clientes:** el Honor `.t88` a 360 dp, en claro y oscuro, a letra 1.0 y 2.0; Chrome con `/privacidad.html`; y Windows con `t88acc`. El almacén real conserva sus 340 archivos y suma solo los 14 de `t88acc`. Cerrar sesión en Windows sí quita la credencial guardada.
- **Validaciones:** **709/709, el piso nuevo**; `analyze` en cero; corpus 118/118; y las sondas de T-93 en 0/1/1/1.
- **El inventario del APK release:**
  - no hay Installations, analítica, anuncios, informes de fallos ni mensajería;
  - pero `firebase-auth 24.2.0` trae reCAPTCHA 18.6.1, que pide `READ_GSERVICES`, Play Integrity 1.3.0 y las bibliotecas de inicio de sesión con Google, que la app no usa;
  - según Google, Authentication recopila la dirección IP;
  - si el proyecto protege Authentication con reCAPTCHA Enterprise, lo confirma Carlos en la consola, sin cambiar nada.

**Seis observaciones de Timonel, que Yov resuelve así:**
1. **Los movimientos llevan el UID de la cuenta,** y la operación, quién la publicó y quién la cerró. Se agrega a la política.
2. **Las dos cuentas leen lo mismo;** el rol solo limita lo que escriben. «Quién lo ve» se reescribe.
3. **El selector de tema se desborda 2.5 px solo en `flutter test`.** En el Honor no pasa. Se anota, sin tarea.
4. **El nombre y el rol se quedan después de cerrar sesión.** La política lo dice.
5. **Authentication recibe la IP al iniciar sesión.** La política lo dice, en «Tu cuenta».
6. **reCAPTCHA, Play Integrity y las bibliotecas de inicio de sesión de Google** van a las declaraciones de Play, que escribe Yov.

**Además,** la ruta de Windows nombra directamente `baystream-app`, como sugirió Timonel.

**Los cinco cambios ya están en la ficha de T-88.** Antes de la aceptación:
- **Timonel los aplica,** junto con el título de la ventana de Windows y el nombre del ejecutable: «BayStream» en `windows/runner/main.cpp` y en `Runner.rc`.
- **Después, Codex acepta T-88 completa,** salvo el ícono.
- **El ícono** llega en una segunda entrega: lo integra Timonel y lo revisa Codex.

**El correo de contacto (D2)** quedó en la fuente, como decidió Carlos. Es la dirección autorizada en 10.44.

**El sprint sigue en 42 tareas y ≈ 156.0 h.** El tablero no cambia: T-88 sigue en curso hasta su segunda entrega.

### 10.48 · La corrección de T-88, aplicada · El paquete del ícono, listo · Una sola aceptación de T-88, con el ícono (15-oct)

**Timonel aplicó la corrección de 10.47** (commit `9cc6e9e`), en ≈ 0.5 h. T-88 suma ≈ 1.5 h, sin el ícono.
- **Las cinco frases, palabra por palabra:** el cotejo con la ficha da cero diferencias, y ninguna es falsa frente al código.
- **«BayStream»** en la ventana de Windows, en `FileDescription` y en `ProductName`. `InternalName` y `baystream.exe` no cambian.
- **710/710, el piso nuevo:** una prueba nueva para Windows y una reescrita. `analyze` en cero.
- **Los clientes:** el Honor `.t88` a 360 dp y letra 2.0, en los dos temas; Chrome con `/privacidad.html`; Windows sin cambios en el almacén real (354 archivos).
- **El matiz que declaró:** la copia del operador guarda también el uid. La política ya dice que «los datos de tu cuenta» se guardan en el dispositivo y se borran con lo demás, así que el texto no cambia.

**Una limitación conocida, para T-99 y el manual (T-100).**
- El service worker de la Web (T-92) entregó primero la política vieja desde su caché, y la nueva después de actualizarse.
- Quien ya visitó el sitio puede ver la versión anterior la primera vez después de una publicación. Es el comportamiento normal del service worker de Flutter.
- A Play no le afecta: lee la dirección sin service worker. Y en la app, la política va compilada.

**reCAPTCHA y App Check (Carlos, consola, sin cambiar nada):**
- **App Check no tiene ninguna app registrada,** ni la de Android ni la Web, así que no está en uso.
- **La protección de Authentication con reCAPTCHA** es otro ajuste, en la configuración de Authentication. Carlos lo revisa ahí. Se espera que esté apagada, porque hay que activarla a propósito.

**El ícono.** El diseñador entregó el paquete v1 (concepto «Bahía»), que pasó sus 52 comprobaciones.
- **El concepto:** el contenedor naranja levantado de su celda, la bodega como casco y versiones dibujadas a píxel para 32, 24, 20 y 16 px.
- **El tamaño:** en la segunda ronda, el dibujo creció cerca de un 11 % en las versiones a sangre. El adaptativo de Android queda dentro de sus 66 dp.
- **Lo que trae:** 25 archivos y un `LEEME.md` con los SHA-256.
  - las fuentes SVG y `generar.py`;
  - Android: el adaptativo, el monocromo y los PNG antiguos;
  - la Web: el favicon y los íconos del manifiesto, también los `maskable`;
  - Windows: un `.ico` con nueve tamaños;
  - Play: el ícono de 512 y el gráfico de 1024×500.

**El orden: una sola aceptación de T-88, ya con el ícono.**
1. **Timonel integra el paquete,** como segunda entrega de T-88:
   - `design/` queda en el repo, con `play/` dentro de `design/icono/`;
   - `web/manifest.json` cambia sus colores a `#0D47A1`, para que coincidan con el ícono;
   - no instala el MSIX: revisa sus imágenes abriéndolo como zip.
2. **Después, Codex acepta T-88 completa,** ícono incluido.

**El sprint sigue en 42 tareas y ≈ 156.0 h.** El tablero no cambia: T-88 sigue en curso.

### 10.49 · reCAPTCHA no está activo · Las declaraciones de Play, escritas (15-oct)

**Carlos revisó la consola de Firebase, sin cambiar nada:**
- **App Check:** ninguna app registrada.
- **Authentication → Configuración → Fraud Defense** (antes reCAPTCHA Enterprise): pide «configurar reCAPTCHA para crear claves de sitio» primero. No hay claves ni protección activa.
- **Conclusión:** la biblioteca de reCAPTCHA viene con `firebase-auth`, pero no se usa. No hay token de reCAPTCHA que declarar.

**Yov escribió `docs/T88-DECLARACIONES-PLAY.md`,** que reemplaza las respuestas de T-64 con la app de hoy:
- **Seguridad de los datos:** recopila, no comparte, y todo es opcional, porque sin cuenta nada sale del dispositivo.
  - Se declaran el correo, el nombre, el ID de usuario, los archivos, los movimientos (contenido del usuario) y el ID de la instalación con la IP de Authentication.
  - La voz no se declara: la procesa el servicio del sistema o del navegador. Es un criterio de Yov, explicado en el documento.
- **Cifrado en tránsito:** sí. **Pedir que se borren los datos:** sí, por el contacto. **Crear cuentas dentro de la app:** no.
- **Cambia «Acceso a la app»:** la sincronización necesita una cuenta.
- **Dos decisiones de Carlos para la prueba cerrada, no para la interna:**
  - cómo entra el revisor de Play. Con las reglas de hoy, cualquier cuenta lee todas las operaciones;
  - un archivo de muestra sintético para el revisor.

**El sprint sigue en 42 tareas y ≈ 156.0 h.**

### 10.50 · El ícono, integrado · Los mosaicos del MSIX salen pixelados y se corrigen con un PNG de 512 · Después, la aceptación de T-88 (15-oct)

**Timonel integró el ícono** (commit `1f2b909`), en ≈ 0.5 h. T-88 suma ≈ 2.0 h frente a 2.5, sin contar la sesión del diseñador.
- **El zip estaba en Descargas,** no en `C:\Proyectos\baystream-icono\`. Lo usó sin modificarlo, y los 36 SHA del `LEEME.md` coinciden.
- **`play/` quedó en `design/icono/play/`,** y `web/manifest.json` usa `#0D47A1`. No queda ningún ícono de Flutter sin usar.
- **El Honor** muestra el ícono nuevo con «BayStream» debajo. El APK lleva el adaptativo con su capa monocroma, pero el lanzador de MagicOS no ofrece íconos temáticos, así que el monocromo no se pudo ver.
- **Chrome:** el favicon y los cuatro íconos del manifiesto son los nuevos, comprobado desde la página. La pestaña y el panel Manifest los revisa Codex, porque Carlos no autorizó mirar su ventana de Chrome.
- **Windows:** el `.exe` muestra el ícono nuevo en el Explorador y en la barra de tareas. `t93_msix.ps1` firmó el MSIX 1.0.3.0 con firma `Valid`, y no se instaló.
- **Validaciones:** 710/710 y `analyze` en cero. `pubspec.*`, las reglas, `lib/` y el almacén real sin cambio.

**El hallazgo: los mosaicos del MSIX salen pixelados.**
- `msix 3.18.0` lee el `.ico` de `logo_path` con el paquete `image`, que devuelve primero el tamaño de 16 px, y lo amplía para las 82 imágenes del paquete.
- **Decisión de Yov:** `logo_path` pasa a `web/icons/Icon-512.png`, el PNG de 512 con la forma propia del ícono.
  - No hace falta otra vuelta del diseñador.
  - No depende del orden de los tamaños dentro del `.ico`.
  - El `.ico` sigue siendo el del `.exe`.
- **Lo hace Timonel,** como corrección de T-88:
  - el cambio en `pubspec.yaml`, que solo toca `msix_config`, sin dependencias;
  - la prueba de T-93 que fija `logo_path`;
  - el MSIX de nuevo, con imágenes nítidas comprobadas.

**Dos notas.**
- **Para T-100, el manual:** una compilación incremental de Windows no tomó el `.ico` nuevo hasta tocar `Runner.rc`. Antes de armar un paquete con cambios de recursos, `flutter clean`.
- **`design/icono/generar.py` todavía escribe `play/` en la raíz del paquete.**
  - No se modifica, para que siga coincidiendo con su SHA del `LEEME.md`.
  - Quien lo vuelva a correr mueve `play/` a `design/icono/play/`.

**Después de la corrección, Codex acepta T-88 completa,** con el prompt de 10.48, más una línea: las imágenes del MSIX son nítidas y salen del PNG de 512.

**El sprint sigue en 42 tareas y ≈ 156.0 h.** T-88 sigue en curso.

### 10.51 · T-88 completa, en revisión: los mosaicos del MSIX, nítidos (15-oct)

**Timonel aplicó la corrección de 10.50** (commit `1e872af`), en ≈ 0.2 h. T-88 suma ≈ 2.2 h frente a 2.5, sin contar la sesión del diseñador.
- **`msix_config.logo_path`** apunta a `web/icons/Icon-512.png`, y su comentario se actualizó. `pubspec.lock` no cambia, y la prueba de T-93 espera la ruta nueva.
- **El MSIX 1.0.4.0,** rearmado con `-SinCompilar`, tiene firma `Valid` con la huella de Carlos, y no se instaló.
- **Las 82 imágenes son nítidas:** por ejemplo `Square150x150Logo.scale-400` de 600×600, `LargeTile.scale-100` de 310×310 y `Square44x44Logo.targetsize-48` de 48×48.
- **Validaciones:** 710/710 y `analyze` en cero.
- **El matiz:** los tamaños chicos del paquete se reducen desde el 512 y no usan los dibujos a píxel del `.ico`. A 48 px se lee bien, y el `.exe` conserva su `.ico`. Queda así.

**T-88 pasa a En revisión.** La acepta Codex con el prompt de 10.48 y los dos cambios de 10.50.

**El sprint sigue en 42 tareas y ≈ 156.0 h.** El tablero: 32 terminadas, T-88 en revisión y 9 por hacer.

### 10.52 · La ficha de T-56, completa: validar las tomas por celda sin cambiar el modelo, y cargarlas por rangos (15-oct)

**T-56 va a Timonel ahora** (ficha completa al inicio de la Ola 6). La acepta Codex, que está aceptando T-88.

**La idea central de la ficha:** la propuesta de T-59 (celda más extremo, con la tabla de pares) se puede validar **sin cambiar el modelo**.
- El código de siete dígitos ya lleva el extremo: una impar es un extremo, una par es la celda sin extremo, y una impar sola es la celda entera.
- **Un 40 en la par E** acepta la toma de E, E−1 o E+1.
- **Un 20 en la impar b** acepta la de b, y con solo una par vecina da aviso de «confirmar el extremo», no error.
- **No se calcula la par de una impar,** porque esa correspondencia es del buque (T-55).
- **Así,** el escenario de T-55 pasa de 91 errores falsos a 82 avisos de extremo y 9 conformes.
- **El perfil, su JSON, Firestore y las reglas no cambian.**
- **Queda fuera** guardar el extremo aparte y la tabla de pares, hasta que haya un plano de tomas real.

**Además:**
- **la carga por rangos,** con vista previa, pegar una lista y quitar por rango. Cargar no declara;
- **la prueba de las 21 bahías;**
- **los cinco textos pendientes,** incluido «N sin puerto de carga en el archivo» en el resumen de la escala, que deja de mostrar 0/0/0 para A06.

**Las horas no cambian:** 3.5 h.

**El tablero:** 32 terminadas, T-88 en revisión, T-56 en curso y 8 por hacer.

### 10.53 · El Incremento 2 suma el avance del Sprint 3: un párrafo en Conclusiones y una diapositiva final (15-oct)

**Yov hizo lo que decidió 10.35,** un día antes de lo previsto. No se tocan resultados, tablas ni cifras medidas del Incremento 2.

**El documento,** `docs/BayStream_Incremento2_Seguridad_Calidad.docx` (SHA-256 `63017b15…`):
- **un párrafo nuevo en V. Conclusiones,** después del de la prueba de campo y antes de «Por último»;
- **lo que dice:**
  - el Sprint 3 ya corrigió los cuatro defectos de campo y llevó a la aplicación el procedimiento de muelle;
  - se informa como avance, no como resultado, porque no se midió con el protocolo del reporte;
  - lo que funciona al 15-oct, con aceptación cruzada: muelle, sincronización con cuentas, roles y cola sin conexión, tapas, BAPLIE de salida, voz, instalador de Windows y la Web sin conexión;
  - lo que queda para la entrega final: IMDG, orden de descarga, medición de los RNF y la prueba piloto;
- **el formato:** el párrafo copia el formato de sus vecinos (nivel 1: 0.75 cm, 44 pt). El verificador da 0 fallas y 0 avisos, con las Tablas 77–90 intactas, y siguen siendo 42 páginas;
- **la revisión visual:** Yov comparó las páginas 36 a 38. Referencias sigue empezando en página nueva.

**La presentación,** `docs/BayStream_Incremento2_Presentacion.pptx` (SHA-256 `165be843…`):
- **la diapositiva 15, «Avance del Sprint 3, en curso»,** con el diseño de la Retrospectiva:
  - tres tarjetas: «Ya funciona», «Por cerrar» y «Falta para el 24-oct»;
  - una línea al pie: «Al 15 de octubre: 32 de 42 tareas terminadas, 710 pruebas automáticas y 118 de corpus»;
  - y sus notas para el orador.
- **La revisión visual:** renderizada, sin cortes.

**Los originales del 6-oct** quedan en git (`468a003`), y los dos archivos se reemplazan en `docs/`.

**Para Carlos, antes del 17:**
- si generó el índice en Word, lo actualiza; las páginas de los títulos no cambian;
- si Codex acepta T-88 antes de presentar, la línea al pie de la diapositiva 15 pasa a «33 de 42».

**El sprint sigue en 42 tareas y ≈ 156.0 h.**

### 10.54 · Nace T-105: mover un contenedor arrastrándolo en el plano, para el 17-oct (15-oct)

**Carlos lo pide para mostrarlo el sábado 17:** tomar un contenedor en el plano y soltarlo donde va.

**La decisión de diseño: arrastrar es otra forma de escribir el mismo cambio** (ficha completa en la Ola 5).
- Al soltar se arma la misma `PositionChange` de T-80 y T-81, y pasa por `ChangeRequests`:
  - la oficina mueve directo (`changePosition`);
  - el muelle pide (`requestChange`), y la oficina aprueba. **El muelle también arrastra, en el teléfono y en la Web** (Carlos): su cambio queda pendiente, marcado en el plano con borde punteado y reloj, hasta que la oficina lo apruebe o lo rechace.
- No hay un tipo de movimiento nuevo. Hereda el motivo obligatorio, la sincronización, el deshacer, los roles y las reglas de Firestore.
- **Una sola fuente de verdad para la vista previa:** `ChangeRequests.preview()`, que usan también `move()` y `request()`. La vista no copia reglas.
- **Lo que entra:**
  - solo en el modo Carga, solo objetos pendientes y solo dentro de la bahía que se ve;
  - `LongPressDraggable`, para no romper el toque, el desplazamiento ni el zoom;
  - colores con borde o ícono mientras se arrastra;
  - y una hoja de confirmación con motivo antes de registrar.
- **Lo que queda fuera:** arrastrar entre bahías, arrastrar lo que ya está a bordo (re-estibar es descargar y cargar) y el desplazamiento automático.

**Quién y cuándo:**
- **Codex** la hace cuando termine la aceptación de T-88, en una copia de HEAD, en paralelo con T-56. Los dos tocan archivos distintos de `lib/`.
- **La acepta Timonel** cuando entregue T-56.
- **Para el 17,** se muestra con una compilación de `sprint-3` sobre una operación de prueba. La rama principal sigue congelada para la presentación (10.40).

**El sprint pasa a 43 tareas y ≈ 159.5 h.** El tablero suma 214.5 h:
- 32 terminadas;
- T-88 en revisión;
- T-56 en curso;
- T-105 y 8 más por hacer.

### 10.55 · T-88 terminada, aceptada con una sustitución autorizada · La diapositiva 15, al día (15-oct)

**Codex aceptó T-88 completa** (commits `bbb2692` y `b874ceb`, `docs/T88-ACEPTACION-RESULTADOS.md`), sobre la copia de producto de `d6c0228`.
- **Pasan completos el Honor y Windows.** El almacén real conserva sus 354 archivos y suma solo los de `t88cx`.
- **También pasan:**
  - 710/710, `analyze` en cero y corpus 118/118;
  - los 36 SHA del ícono;
  - el MSIX nítido;
  - las sondas de T-93 en 0/1/1/1;
  - el cotejo exacto de la política, con el correo único y `--comprobar` en 0.
- **Chrome:** pasaron las dos entradas y `/privacidad.html` directo.
- **La sustitución autorizada por Carlos.** Las tres comprobaciones que faltaban en Chrome (la pestaña, el panel Manifest y la red) se hicieron en el navegador integrado:
  - el favicon descargado, con el SHA correcto;
  - el manifiesto servido, con BayStream y `#0D47A1`;
  - las cuatro imágenes, a su tamaño;
  - la política, sin recursos de otro origen.
  - El informe declara que no se vio la pestaña ni el panel de Chrome, ni se generó un HAR.
- **Queda como precedente:** cuando Carlos no autoriza mirar su Chrome, el navegador integrado sustituye la comprobación, solo con su autorización expresa y declarado en el informe.
- **Sin cambios de producto.**

**T-88 pasa a Terminado, aceptada con observación** (la sustitución). Horas reales: ≈ 2.2 h de Timonel y ≈ 0.43 h de comprobaciones instrumentadas de Codex, frente a 2.5. No cuentan la sesión del diseñador.

**La diapositiva 15 del Incremento 2, al día:**
- «Política de privacidad e ícono propio» pasa a «Ya funciona»;
- «Arrastrar un contenedor en el plano, con confirmación» entra a «Por cerrar»;
- el pie dice «33 de 43 tareas terminadas»;
- las notas mencionan el arrastre.
- **Revisada renderizada,** sin desbordes. SHA-256 `7d0d02cc…`.

**El sprint sigue en 43 tareas y ≈ 159.5 h.** El tablero:
- 33 terminadas;
- T-56 en curso;
- 9 por hacer, con T-105.

### 10.56 · Un cuarto agente: Gru (Gemini 4 Argon, en una Gem), solo de lectura (15-oct)

**Carlos suma un agente:** Gemini 4 Argon, que llegó a la app de Gemini para los planes AI Pro y AI Ultra el 13-oct. Trabaja en una Gem, en la Web. Carlos lo llama **Gru**.

**Lo que puede y lo que no**, verificado en la ayuda de Google:
- **Importa el repo solo para leerlo.** Es un repositorio por chat, de hasta 5 000 archivos y 100 MB; el nuestro tiene 601 archivos y 22.6 MB.
- **Es una foto del momento:** no se sincroniza, no escribe en el repo y no ve la historia.
- **No corre Flutter, ni las pruebas, ni los clientes.**
- **Conclusión:** no programa ni hace aceptaciones. Es un lector y revisor independiente, con mucha capacidad de lectura y de texto largo.

**Sus tareas, por valor:**
1. **La segunda lectura del IMDG (T-85).** Transcribe por su cuenta las tablas 7.2.4 y 7.4.3.2 del PDF de la Enmienda 42-24, sin ver la de Yov. Después se cotejan celda por celda, y Carlos resuelve las diferencias mirando el PDF.
   - Es la verificación doble que pide el plan (simetría y segunda lectura), y desbloquea T-85, la tarea de dominio más grande que queda.
   - La transcripción se guarda en `baystream-privado`, nunca en el repo.
2. **Una auditoría de seguridad independiente** para la entrega del 24-oct: las reglas de Firestore, el acceso a los datos y OWASP Mobile, desde el código. Cada hallazgo lleva su evidencia; los agentes y Carlos lo comprueban.
3. **El borrador del manual de usuario** (T-100, TC-02), leyendo el código y las fichas. Yov lo revisa y le da el formato UMG.
4. **Cuando Yov lo pida,** una revisión adicional del diff de una entrega antes de su aceptación cruzada. No reemplaza a la aceptación.

**Sus reglas** (van en las instrucciones de la Gem):
- solo lectura: no pide a Carlos comandos de git que escriban ni nada de Firebase;
- nunca recibe el corpus, `firebase-prod.json`, `key.properties` ni otro archivo de `baystream-privado`, salvo el PDF del IMDG para su tarea;
- dice siempre qué commit o rama importó;
- cada afirmación lleva su archivo y su línea, o se declara como hipótesis;
- no reescribe el plan: propone, y Yov decide;
- entrega en español, con un «Mensaje para Yov».

**El sprint sigue en 43 tareas y ≈ 159.5 h.** Las horas de Gru se anotan en la tarea que apoya.

### 10.57 · T-56 entregada, en revisión: las tomas por celda y por rangos · Una corrección chica antes de la aceptación · T-105, en curso con Codex (15-oct)

**Timonel entregó T-56** (commit `5b1d8a1`, base `35f0058`, `docs/T56-RESULTADOS.md`). Yov revisó el diff y cumple la ficha.
- **El validador busca por celda física, sin cambiar el modelo.**
  - Un 40 en la par E acepta la toma de E, E−1 o E+1.
  - Un 20 en la impar b acepta la de b. Con solo una par vecina da un aviso de extremo que nombra el código encontrado, nunca un error.
  - No calcula pares.
- **La carga por rangos** está en un servicio puro, `reefer_socket_ranges.dart`:
  - con vista previa, quitar por rango y pegar una lista;
  - con un tope de 20 000 códigos por operación y errores legibles;
  - **cargar no declara:** solo la casilla declara.
- **Las cifras:**
  - 745/745 (35 nuevas), `analyze` en cero y corpus 129/129 en 33 archivos;
  - el escenario de T-55 pasa de 91 errores a 82 avisos de extremo y 9 conformes, sintético y sobre A01;
  - en las 10 fuentes, 0 → 0. En los cruces del mismo buque, A08 → A07 sigue en 4 → 4, y no aparece ninguna alerta nueva;
  - las 21 bahías de A07 ∪ A08, con su lista y un cotejo sobre el texto crudo;
  - en los tres clientes:
    - 204 se agregan, 6 ya estaban y 70 se descartan;
    - se guardan 216 y quedan 147 al quitar;
    - solo la casilla declara;
  - Windows tardó 41 s y la Web 22 s. El Honor no tiene un tiempo limpio.
- **Los cinco textos** se vieron en el Honor a 2.0, en claro y oscuro. A06 en GTPBR dice «717 sin puerto de carga en el archivo».
- **No cambian** el modelo y el JSON del perfil, el codec, las reglas, `lib/main.dart`, `pubspec.*` ni los congelados. Los SHA están en el informe.
- **Windows** sumó al almacén real solo archivos `t56acc_*` (362 → 374).

**La pregunta de Timonel, confirmada por Yov:** un contenedor sin `LOC+9` que se descarga en la escala ya va en «se descargan», y no se repite en «sin puerto de carga». Así, las cuatro cifras suman el total.

**Una corrección antes de la aceptación,** para que Codex acepte una sola vez. La hace Timonel ahora, sin dispositivos:
1. **El diálogo de quitar** cerraba con «Cargar no declara…». Ahora dirá «Quitar no cambia la casilla de declaración.».
2. **La sección de tomas** ya no se pliega cuando la lista la desecha al desplazarse.
3. **Las cuatro líneas del resumen con reservas** concuerdan en singular y plural. La prueba nueva fijaba «1 reservas» y «1 contenedores».

**Observaciones que quedan anotadas:**
- Windows se probó con la compilación anterior a la corrección de dos detalles de la vista previa. Codex lo ve con la final.
- Al usar el Honor se recreó la actividad de `.t105` de Codex. Su almacén no se tocó.
- Un `%TEMP%` limpiado a mitad de la tarea obligó a rehacer la copia de compilación.
- «Usar estas declaraciones», pegado al borde de su botón a 2.0, queda para la pasada de textos del cierre.

**La acepta Codex cuando entregue T-105,** sobre la corrección:
- cronometra en el Honor, de un tirón, la carga de al menos cien tomas por rango, en menos de un minuto;
- repite Windows con la compilación final.

**T-105 está en curso:** Codex la está haciendo (el Honor ya tiene su `.t105`). La acepta Timonel.

**Horas:** ≈ 1.3 h de Timonel frente a 3.5, sin contar la corrección.

**El sprint sigue en 43 tareas y ≈ 159.5 h.** El tablero:
- 33 terminadas;
- T-56 en revisión;
- T-105 en curso;
- 8 por hacer.

### 10.58 · La ficha de T-96, completa, para Timonel · T-95 espera tres definiciones de dominio de Carlos (15-oct)

**T-96 va a Timonel ahora,** mientras Codex termina T-105 (ficha completa en la Ola 6, después de T-56). La acepta Codex, después de T-56.
- **La idea central:** comparar es un servicio puro sobre dos `VesselVoyage` ya leídos, por número de contenedor.
- **El segundo archivo** se lee con el mismo lector y **no pasa por el flujo de carga:** no se publica, no entra a Recientes, no se guarda ni sube.
- **Dos entradas:** «Comparar con otro BAPLIE…», desde el viaje abierto, y «Comparar con la llegada», desde el BAPLIE de salida de T-82.
- **El peso** que se compara es el efectivo de T-66, el mismo que usa la app.
- **Las cifras del caso:**
  - A07 → A08 da 114 descargados, 121 cargados más 55 reservas y 284 permanentes, con las diferencias de 10.20: POL 127, POD 189, línea 58 y peso 113;
  - al revés, se intercambian;
  - la salida de la operación de 177 eventos contra A07 da 114, 176 y 284.
- **Resuelve la observación de 10.20:** el detalle de la llegada sigue mostrando la llegada, y la diferencia con el plan se ve en la comparación.
- **El carril:** archivos nuevos más dos entradas, en `vessel_overview_page.dart` y `departure_baplie_page.dart`. Si T-105 cambió alguno de los dos antes de colocar, Timonel se detiene y avisa.

**T-96 se adelanta a T-95** porque su especificación está completa y el caso trae las cifras. T-95, el orden de descarga con sobreestibas por columna y por tapa, necesita tres definiciones de dominio que solo puede dar Carlos como planner:
- qué contenedores de cubierta van sobre cada tapa;
- en qué orden se sugieren las bahías;
- cuántos movimientos cuenta una re-estiba.

Yov se las pregunta y escribe la ficha con sus respuestas.

**El tablero muestra dos tareas en curso,** una por programador y en archivos distintos, como ya permitió 10.54.

**Las horas no cambian:** 6.0 h. **El sprint sigue en 43 tareas y ≈ 159.5 h.** El tablero:
- 33 terminadas;
- T-56 en revisión;
- T-105 y T-96 en curso;
- 7 por hacer.

### 10.59 · Carlos define el dominio de T-95 · Su ficha, completa, para Codex (15-oct)

**Las tres definiciones de Carlos,** como planner, para las sobreestibas y la estimación:
1. **Sobre una tapa van los de cubierta de las mismas filas que la tapa declara** (lo que recomendó Yov). Las filas de afuera, sin bodega abajo, no estorban: se cuentan aparte.
2. **Las bahías van de la de más movimientos a la de menos.** Yov había recomendado de proa a popa; Carlos eligió otra cosa. Con empate, se ordenan de proa a popa.
3. **La estimación muestra las dos re-estibas:** a bordo (1 movimiento) y por muelle (2). Cada tapa de grúa cuenta 2, quitar y reponer.

**Un supuesto de Yov, anotado para que Carlos lo corrija si no aplica:** la tapa automática se abre sin grúa. Cuenta 0 movimientos, pero igual exige despejar la cubierta que va encima.

**La ficha de T-95, completa** (Ola 6, después de T-96):
- **La celda física, sin calcular pares.** La huella de una impar es ella misma, y la de una par son sus dos impares vecinas. Dos posiciones están en la misma pila si tienen la misma fila, la misma zona y huellas que se tocan. Así, ALFA (la 041 sola, y la 044 sobre la 043 y la 045) no necesita fórmula.
- **Un servicio puro,** `discharge_sequence.dart`, con las sobreestibas por columna y por tapa.
  - Una re-estiba se cuenta una sola vez.
  - Las tapas copiadas entre bahías de la misma celda, con las mismas filas, se unen en una.
- **Una pantalla nueva,** «Orden de descarga»: el resumen, las celdas en el orden sugerido con sus pasos rotulados, y los avisos.
- **El caso:** A07 en GTSTC da 114 descargas, 66 en cubierta y 48 en bodega. Las re-estibas por columna las confirma un cotejo sobre el texto crudo, y cada fuente y cada puerto cumplen los invariantes.
- **Las tapas siguen siendo PROVISIONALES:** ningún buque del corpus las declara (T-83).
- **Queda fuera:** el orden en las celdas del plano, las grúas, el avance en vivo, la estabilidad y exportar.

**Quién y cuándo:**
- **Codex** la hace después de aceptar T-56, sobre el HEAD con T-96.
- **La acepta Timonel.**
- **Codex acepta T-96.**
- **El orden:**
  - **Codex:** T-105, después la aceptación de T-56, y después T-95.
  - **Timonel:** la corrección de T-56, T-96 y la aceptación de T-105, que se adelanta a T-96 en cuanto llegue.

**Las horas no cambian:** 7.5 h. **El sprint sigue en 43 tareas y ≈ 159.5 h.** El tablero no cambia: T-95 sigue por hacer, con su ficha.

### 10.60 · La transcripción del IMDG, verificada por dos lecturas a ciegas · Carlos decide cómo llega al código · La ficha de T-85, completa (15-oct)

**La transcripción existe y está verificada.** Yov y Gru leyeron por separado, sin ver la otra lectura, las dos tablas del PDF de la Enmienda 42-24 (`baystream-privado`):
- **7.2.4,** el cuadro de segregación por clase (página 2 del PDF, 536 impresa): **289 de 289 celdas iguales.** La lectura de Yov es además simétrica en sus 136 parejas.
- **7.4.3.2,** los portacontenedores con bodegas cerradas (página 16, 557 impresa, girada): **59 de 60 iguales en el contenido,** más una diferencia de forma, un punto contra una barra.
- **La única diferencia de contenido:** la .3, vertical, abierta/abierta.
  - Yov leyó «prohibido en la misma vertical salvo que los separe una cubierta»; Gru, «prohibido».
  - Yov midió las líneas de la tabla sobre la imagen: en esa columna no hay ninguna entre la .1, la .2 y la .3, así que es una sola celda combinada, y el «prohibido» es solo de la .4.
  - **Carlos lo confirmó mirando el PDF:** vale la lectura de Yov.
- **Los archivos** (`yov_7-2-4.csv`, `yov_7-4-3-2.csv`, `yov_notas.txt` y `cotejo_imdg_yov_gru.txt`) están en `C:\Proyectos\baystream-privado\imdg\`, junto a los de Gru. **Nunca en el repo** (10.35).
- **Es la verificación doble que pide el plan,** con evidencia de cada paso. Gru cumplió su primera tarea: 348 de 349 celdas.

**Carlos decide cómo llega la tabla al código** (la pregunta de 10.35): **solo los códigos.**
- La matriz de 1 a 4, X y \*, y las exigencias de 7.4.3.2, van como datos en Dart, sin copiar texto del IMDG.
- Los mensajes van en palabras de BayStream, citando el apartado.
- La app igual lleva la tabla dentro, y las pruebas corren sin archivos privados.
- Un comprobador fuera de la suite compara los datos con la transcripción verificada.
- Era la opción que recomendó Yov.

**La ficha de T-85, completa** (Ola 4, después de T-103):
- **El cambio de fuente:** el validador deja 49 CFR y pasa al IMDG 42-24. La clase sale del archivo, con las etiquetas secundarias según 7.2.3.3.
- **Los resultados:**
  - la X da «no evaluado: consultar la Lista», y así sale toda la clase 9;
  - el asterisco remite a 7.2.7.1.
- **La posición** se evalúa con 7.4.3.2 sobre el modelo de huecos que ya existe.

**Supuestos de Yov que Carlos puede corregir antes de que empiece T-85:**
- un tanque (T) es una unidad cerrada, como G, R y B; U y P son abiertas;
- la tapa de escotilla cuenta como la cubierta que separa en vertical, y una bodega abierta (T-83) no separa;
- 24 m son cuatro huecos longitudinales de 20 pies, rotulados como aproximación;
- entre una unidad en cubierta y otra en bodega, para las exigencias 1 y 2 basta la cubierta; para la 3 y la 4, «no evaluado».

**Quién y cuándo:**
- **Timonel** la hace después de T-96 y de aceptar T-105.
- **Antes de la aceptación, Gru revisa** los datos del código contra el PDF, como tercera lectura.
- **La acepta Codex.**

**Las horas no cambian:** 10.0 h. **El sprint sigue en 43 tareas y ≈ 159.5 h.**

### 10.61 · T-96 entregada, en revisión: comparar la llegada con la salida · Un aviso de buque que asusta de más · T-95 pasa a Timonel (15-oct)

**Timonel entregó T-96** (commit `0011882`, `docs/T96-RESULTADOS.md`), sobre `32a1a94`. Yov revisó las dos entradas y el informe, y cumple la ficha.
- **El servicio:** `voyage_comparison.dart`, puro. Clasifica por número de contenedor y compara nueve campos con el peso efectivo y el «sin dato». Además:
  - cuenta las reservas aparte;
  - reporta los repetidos;
  - es simétrico.
- **Las cifras del caso:**
  - **A07 → A08:** 114 descargados, 121 cargados más 55 reservas y 284 permanentes, con POL 127, POD 189, línea 58 y peso 113, como 10.20; 262 tienen algún cambio;
  - **al revés,** las cifras se intercambian campo por campo;
  - **A08v_VGM** da lo mismo, porque su VGM es igual al WT de A08;
  - **la salida de los 177 eventos** da 114, 176 y 284. Los 176 son 121 + 55 por origen y 120 llenos + 56 vacíos por estado, como los eventos.
- **Las validaciones:**
  - 764/764, `analyze` en cero y corpus 135/135;
  - el lector, el escritor de T-82 (`05EE9198…`), el codec, el modelo, las reglas, `main.dart`, `pubspec.*` y los congelados siguen con el mismo SHA.
- **Los clientes:**
  - **Windows:** solo `t96acc_*` en el almacén real (388 → 400). Una segunda instancia que se abrió por error se cerró por PID, y está declarada;
  - **el Honor:** a 2.0, en claro y oscuro;
  - **la Web,** en el navegador integrado, con autorización de Carlos (10.55).
- **Horas:** ≈ 0.75 h frente a 6.0.

**La entrada se queda donde la puso Timonel:** en la fila de acciones del viaje, junto a «Alertas de estiba». La barra superior de T-91 tiene su lista fijada en una prueba, y la fila está a la vista. La entrada de T-95 va en la misma fila.

**Un aviso que asusta de más, a corregir antes de la aceptación.** A05 → A06 dice «No parece el mismo buque», y los dos son BUQUE ECO. Uno se identifica por IMO y el otro por indicativo, y T-96 compara la clave entera.
- Ya existe `Vessel.matchIdentity`, que distingue tres casos.
- **La corrección:**
  - con identidad automática, no hay aviso;
  - con el mismo nombre y claves de distinto tipo, el aviso dice que no se puede confirmar que sea el mismo buque, y pide confirmarlo;
  - si no hay coincidencia, se queda «No parece el mismo buque».
- La hace Timonel ahora, sin dispositivos.

**T-95 pasa de Codex a Timonel.**
- **Por qué:** Codex sigue en T-105 y después tiene dos aceptaciones, la de T-56 y la de T-96. Timonel está libre y entrega rápido.
- **La ficha no cambia,** salvo la entrada, que va en la fila de acciones.
- **La acepta Codex.**

**El orden queda así:**
- **Timonel:** la corrección de T-96, después T-95 y después T-85. La aceptación de T-105 pasa adelante en cuanto llegue.
- **Codex:** T-105, la aceptación de T-56, la de T-96, la de T-95 y la de T-85.

**El sprint sigue en 43 tareas y ≈ 159.5 h.** El tablero:
- 33 terminadas;
- T-56 y T-96 en revisión;
- T-105 y T-95 en curso;
- 6 por hacer.

### 10.62 · T-105 entregada, en revisión: arrastrar con confirmación, y un zoom que no existía · `request()` gana los tres controles que le faltaban · Timonel la acepta ya (16-oct)

**Codex entregó T-105** (commit `3473e10`, `docs/T105-RESULTADOS.md`). Partió de `5fba2f2`, y antes de colocar la comprobó contra `f6bac1f`, con T-56 y T-96 dentro. Yov revisó el informe y el cambio de dominio.
- **`ChangeRequests.preview()` es la única revisión.** `move()` y `request()` la usan, y el gesto la consulta mientras se arrastra.
- **Un hallazgo real de T-80.** `request()` no tenía tres controles que sí tenía `move()`:
  - que el objeto esté pendiente de carga;
  - que la celda no esté ocupada a bordo;
  - que un intercambio de reservas sea del mismo grupo.
  - **Lo que significaba:** el muelle podía pedir un cambio que la oficina no habría podido hacer.
  - **Carlos autorizó unificarlos,** y también ajustar las dos variantes de `test/t80_requests_widget_test.dart`, que ahora parten de la descarga del ocupante. No se borró ni se omitió ninguna prueba.
- **El zoom, que el plano no tenía.** La ficha suponía que existía, y solo había un comentario.
  - **Carlos autorizó agregarlo:** pellizco y controles de 75 a 300 %. Un dedo sigue desplazando y la pulsación larga sigue arrastrando, y cambiar de bahía reinicia el zoom.
  - Es alcance agregado con autorización, y queda anotado.
- **El gesto:**
  - `LongPressDraggable` solo en Carga, solo pendientes y dentro de la bahía que se ve;
  - colores con ícono;
  - una hoja con motivo obligatorio;
  - la solicitud del muelle, con borde punteado y reloj hasta que la oficina decide.
- **Las validaciones:**
  - 799/799, `analyze` en cero y corpus 135/135;
  - el modelo de movimientos, el codec, las reglas, `main.dart`, `pubspec.*` y los congelados siguen con el mismo SHA.
- **Los clientes,** sobre la operación de prueba «PRUEBA T-105» en `baystream-app`, con el namespace `t105acc` y datos sintéticos:
  - Windows y el Honor completos: movimiento, intercambio y solicitud, con aprobación y rechazo sin recargar;
  - **la Web,** en el navegador integrado con la autorización de Carlos (10.55). Su conector no arrancó, así que las acciones allí son manuales de Carlos, contrastadas desde los otros clientes. **Chrome no se da por probado.**
- **Una confusión, recuperada sin borrar nada.** Carlos mezcló una secuencia y quedaron una carga y una cancelación accidentales.
  - Se anularon como dice T-81, con «Marcado por error» y una anulación con motivo.
  - **La bitácora se conservó:** 22 registros, 0 solicitudes pendientes y 0 conflictos.
- **El almacén real de Windows:** los 374 archivos previos quedan idénticos. Se agregan solo 14 de `t105acc` y los 12 de `t96acc`, que son de T-96.
- **Incidencias declaradas, sin daño:**
  - una lectura de accesibilidad devolvió el formulario de acceso con un identificador de cuenta. Se descartó y no se guardó;
  - un build de Windows se lanzó a la vez que el corpus, y se detuvo por PID;
  - la ventana equivocada salió en dos capturas, que se descartaron.
- **El Honor:** Codex lo encontró con la letra en 2.0 y lo dejó así. La regla es 1.0, salvo que haga falta; Timonel lo deja en 1.0 al aceptar.
- **Horas:** ≈ 1.56 h por huellas, frente a 3.5.

**La operación «PRUEBA T-105»** se queda en Firestore como operación de prueba, y sirve para mostrar el arrastre el 17. Borrarla después es de Carlos, desde la consola.

**Timonel la acepta ahora,** antes de seguir con la corrección de T-96 y con T-95, porque es la del 17. Si pasa, la diapositiva 15 del Incremento 2 sube el arrastre a «Ya funciona» y actualiza la cuenta.

**El sprint sigue en 43 tareas y ≈ 159.5 h.** El tablero:
- 33 terminadas;
- T-56, T-96 y T-105 en revisión;
- T-95 en curso;
- 6 por hacer.

### 10.63 · La sombra del 40: un hallazgo de Timonel, corregido por Codex · T-105 terminada para el 17 · La corrección de T-96, entregada (16-oct)

**El hallazgo, al aceptar T-105:**
- `review()` no veía que un 40 en una bahía par ocupa la misma fila y el mismo nivel en sus dos impares vecinas. Un 20 soltado bajo la sombra de un 40 salía en verde, y un 40 encima de dos 20 también.
- **Viene desde T-80 y T-81:** el formulario y la solicitud ya lo tenían. El arrastre solo lo dejó a la vista.
- **Lo reprodujo una prueba de dominio de Timonel:** 4 conflictos fallaban y 2 controles pasaban.

**La corrección de Codex** (`3086db2`):
- **La celda física por huellas,** la misma regla de T-95, sin calcular pares. La huella de una impar es ella misma, y la de una par son sus dos impares vecinas. Dos posiciones chocan si comparten fila, nivel y huella.
- **`review()` revisa** lo que hay a bordo, lo previsto en el plan y los destinos del mismo lote.
- **Cubre todos los caminos:** el arrastre, el formulario, la solicitud y también la aprobación.
- **Las pruebas:** 834/834, con las 6 pruebas de Timonel intactas y 29 de Codex; `analyze` en cero y corpus 135/135.

**Timonel aceptó T-105 con la corrección** (`docs/T105-ACEPTACION-RESULTADOS.md`):
- **Las validaciones:** 799/799 sobre `7a06c5d`, con los SHA de Codex iguales. Junto con la corrección de T-96 da 842/842, `analyze` en cero y corpus 135/135.
- **El dominio:**
  - `preview`, `move` y `request` coinciden en 18 casos suyos;
  - los tres controles nuevos de `request()` fallan con el código anterior, así que el hallazgo de 10.62 es real;
  - el ajuste de T-80 solo cambia el estado de partida.
- **Los tres clientes,** sobre «PRUEBA T-105 TM» (con dos 40, uno incoherente a propósito y PROVISIONAL):
  - la matriz completa, con 7 registros y 0 conflictos;
  - la solicitud desde la Web la hizo Carlos con el mouse;
  - la 10.63 en Windows: rojo y sin hoja, en los dos sentidos.
- **Lo que no se tocó:** «PRUEBA T-105», la de la demo, quedó igual. El almacén real conservó sus 400 archivos idénticos, más 14 `t105tm_*`.
- **El Honor** quedó en 1.0.
- **Chrome queda sin probar,** por Codex y por Timonel.
- **Incidencias declaradas, sin daño:**
  - dos instancias extra de Windows, cerradas por PID en menos de un minuto;
  - dos `git diff --no-index` de solo lectura, fuera de la lista permitida.

**T-105 pasa a Terminado, aceptada con observación:** Chrome sin probar, y el zoom agregado con autorización (10.62). Horas reales:
- ≈ 1.56 h de Codex, más la corrección;
- ≈ 1.2 h de la aceptación de Timonel.

**Nueve observaciones de Timonel, que no son defectos de T-105.** Yov las decide el 16-oct. Para la demo pesan dos:
- a 300 %, con la ventana de Windows ancha, el plano abre en blanco: en la demo, mejor no pasar de 200 %;
- en el modo Carga, la descarga pendiente no se dibuja (viene de T-76).

Las demás son textos y cosméticas, entre ellas:
- el aviso rojo muestra la clave interna `C:`;
- la segunda frase del aviso no siempre aplica;
- la vista de una bahía par no dibuja los 20 de las impares vecinas.

**La corrección de T-96, entregada** (`adc9ea4`):
- **El aviso de buque sigue a `Vessel.matchIdentity` y al tipo de clave,** como decidió Carlos.
- **A05 → A06 pide confirmar.** Dos IMO distintos siguen siendo dos buques.
- **Las pruebas:** 842/842, `analyze` en cero y corpus 135/135.
- **T-96 sigue En revisión,** y la acepta Codex.

**Las operaciones de prueba en Firestore,** para que Carlos las borre después desde la consola:
- «PRUEBA T-105 TM»;
- «PRUEBA T-105», después de la demo.

**El sprint sigue en 43 tareas y ≈ 159.5 h.** El tablero:
- 34 terminadas;
- T-56 y T-96 en revisión;
- T-95 por empezar con Timonel;
- 6 por hacer.

### 10.64 · La diapositiva 15, al día para el 17 · Las nueve observaciones de Timonel, clasificadas (16-oct)

**La diapositiva 15 del Incremento 2, al 16-oct** (`docs/BayStream_Incremento2_Presentacion.pptx`, SHA-256 `b0646dc8…`):
- **«Ya funciona»** suma «Arrastrar un contenedor en el plano» (T-105). Para que entre sin desbordar:
  - tapas y la lectura de 1.5 a 2.2 quedan juntas;
  - la voz, la Web sin conexión, el instalador y la privacidad van en un solo punto.
- **«Por cerrar»:**
  - las tomas de reefer (T-56);
  - comparar la llegada con la salida (T-96);
  - las declaraciones de Play.
- **«Falta para el 24-oct»:**
  - la segregación IMDG, «con sus tablas ya verificadas» (10.60);
  - el orden de descarga, con sobreestibas;
  - la medición de los RNF;
  - el manual y el piloto.
- **El pie:** «Al 16 de octubre: 34 de 43 tareas terminadas, 842 pruebas automáticas y 135 de corpus.»
- **Las notas para el orador** dicen que el arrastre ya funciona y que conviene mostrarlo, y que las tablas del IMDG se verificaron con dos lecturas independientes.
- **El campo del número de diapositiva** tenía 12 en caché, porque se copió de la 12, y ahora dice 15.
- **La revisión:** el validador pasa y la diapositiva renderizada no tiene cortes. Si Codex acepta T-56 o T-96 antes de la presentación, Yov sube la cuenta del pie.

**Las nueve observaciones de la aceptación de T-105** (sección 12 de `docs/T105-ACEPTACION-RESULTADOS.md`). Yov las clasifica:
- **Para una tarea chica, después de la demo:** T-106, «Pulido del arrastre y del zoom», de unas 2 h, que **propone Yov y confirma Carlos**. Junta:
  - el aviso rojo sin la clave interna `C:` (1);
  - el aviso sin una segunda frase que no aplica (8);
  - el zoom a 300 %, que no abra en blanco ni desperdicie el margen (2 y 3);
  - la descarga pendiente dibujada en el modo Carga (4);
  - los 20 de las impares vecinas dibujados en la vista de una bahía par (5);
  - la copia que se arrastra, a la escala del zoom (6).
- **Solo anotadas:**
  - el error que salió una vez en la consola de la Web (7), sin efecto visible;
  - que tocar la sombra de un 40 no abra detalles (9).
- **Para la demo del 17:** en Windows, no pasar de 200 % de zoom.

**El sprint sigue en 43 tareas y ≈ 159.5 h** mientras Carlos no confirme T-106. El tablero no cambia.

### 10.65 · T-95 empieza con Timonel sobre `ff14dc0` · El orden de vuelta de las re-estibas, corregido en la ficha (16-oct)

**Timonel empieza T-95** sobre `ff14dc0`, con la confirmación de Carlos.

**Un error de la ficha, encontrado por Timonel antes de programar.**
- **Lo que decía la ficha:** las tapas volvían antes que todas las re-estibas. Así, una re-estiba de bodega tendría que volver con la tapa ya cerrada.
- **El orden físico, que confirmó Carlos:**
  1. las re-estibas de bodega vuelven, de abajo arriba;
  2. se reponen las tapas;
  3. las re-estibas de cubierta vuelven, de abajo arriba.
- **La ficha de T-95 queda corregida** en los pasos 4 a 6 de la secuencia.

**El sprint sigue en 43 tareas y ≈ 159.5 h.** El tablero: T-95 pasa a En curso.

### 10.66 · Nace T-106: el pulido del arrastre y del zoom, después de la demo (16-oct)

**Carlos confirma T-106**, la tarea que propuso Yov en 10.64, con siete observaciones de la aceptación de T-105.
- **Elemento:** RF-038.
- **Estimación:** 2.0 h.
- **Quién y cuándo:** después de la demo del 17. La hace Codex, que escribió T-105, y la acepta Timonel.
- **Lo que entra:**
  1. el aviso rojo, sin la clave interna `C:`, con el contenedor o la orden en palabras (observación 1);
  2. el aviso, sin una segunda frase que no aplica: un 20 no se intercambia con un 40, y un tránsito no se descarga (8);
  3. el zoom a 300 %, que no abra en blanco con la ventana ancha y no escale el margen (2 y 3);
  4. la descarga pendiente, dibujada en el modo Carga (4, que viene de T-76);
  5. los 20 de las impares vecinas, dibujados en la vista de una bahía par, para que el choque de 10.63 se vea (5);
  6. la copia que se arrastra, a la escala del zoom (6).
- **Queda fuera:**
  - el error que salió una vez en la consola de la Web (7);
  - el toque sobre la sombra de un 40 (9).
- **La ficha completa** se escribe al tomarla.

**El sprint pasa a 44 tareas y ≈ 161.5 h.** El tablero suma 216.5 h:
- 34 terminadas;
- T-56 y T-96 en revisión;
- T-95 en curso;
- 7 por hacer, con T-106.

### 10.67 · Carlos confirma los cuatro supuestos de T-85, con dos ajustes de Yov (16-oct)

**La regla con que se revisaron:** cuando BayStream no puede saber algo, el resultado es «no evaluado». Nunca da «conforme» por un supuesto a su favor.

**Los cuatro supuestos, confirmados por Carlos con los ajustes que recomendó Yov:**

1. **Cerrada o abierta, por el tercer carácter del ISO.**
   - **Son cerradas** G, R, T (tanque), B, y además V (ventilado) y H (aislado), porque encierran la carga con una estructura rígida y permanente.
   - **Son abiertas** U (techo abierto) y P (plataforma).
   - **Cualquier otro tipo, o uno que falte,** da «no evaluado».
   - T-85 lee el carácter de `isoSizeType` en su propio servicio, sin cambiar `ContainerUnit.containerType`, que es del modelo.
   - **Una nota:** la definición de unidad cerrada está en una parte del IMDG que no está en el PDF transcrito. El supuesto se apoya en la práctica de Carlos.
2. **La tapa de escotilla cuenta como la cubierta que separa en vertical, y el mensaje lo dice.**
   - El texto lleva la idea «se considera la tapa como cubierta resistente al fuego y a los líquidos (IMDG 7.4.2.2)».
   - **La razón:** una tapa parcialmente estanca sin canales de drenaje eficaces no cuenta, y BayStream no sabe qué tapas tiene el buque. Suponer lo contrario daría falsas alarmas en casi todos los buques normales.
   - **La bodega abierta** (T-83) nunca separa.
   - **Queda fuera:** declarar en el perfil las tapas parcialmente estancas.
3. **Los 24 m son cuatro huecos longitudinales de 20 pies.**
   - Es la propia definición de 7.4.3.1.1: un espacio para contenedor mide al menos 6 m a lo largo.
   - Es conservador, porque no cuenta los mamparos ni los huecos entre bahías.
4. **Una unidad en cubierta y otra en bodega:**
   - **para 1 y 2,** la cubierta entre ellas cumple, con el supuesto 2;
   - **para 3 y 4,** «no evaluado», porque hacen falta los límites de la bodega.

**La ficha de T-85 queda ajustada** en el punto 4 de «Qué construye». Ya no quedan supuestos abiertos: Timonel la toma después de T-95.

**El sprint sigue en 44 tareas y ≈ 161.5 h.**

### 10.68 · T-56 y T-96 terminadas: Codex acepta las dos · La medición de Windows la hace Carlos a mano (16-oct)

**T-56 pasa a Terminado** (`be85e4c`, `docs/T56-ACEPTACION-RESULTADOS.md`):
- **Lo que confirmó Codex en las validaciones:**
  - 799/799, `analyze` en cero y corpus 135/135;
  - los ocho SHA iguales;
  - su cotejo independiente del validador sobre el EDI crudo: 91 errores pasan a 82 avisos y 9 conformes, sin alertas nuevas;
  - las 21 bahías.
- **En los tres clientes:**
  - 204 / 6 / 70, con 216 al reabrir;
  - la lista pegada da 1 / 2 / 1, con los tres inválidos;
  - quitar deja 147;
  - solo la casilla declara;
  - la sección no se pliega.
- **Los cinco textos,** en el Honor a 2.0, en claro y oscuro. El Honor queda en 1.0.
- **El almacén real de Windows:** solo `t56cx_*`.
- **El cronómetro:**
  - el Honor, 27.9 s;
  - **Windows, 56 s, medidos a mano por Carlos** (decisión de Yov). El intento del agente dio 96 s, pero medía la latencia de la herramienta, porque escribía carácter por carácter. El criterio de «menos de un minuto» es para una persona. Después de la medición de Carlos, Codex verificó las 216 tomas al reabrir.
- **La Web,** en el navegador integrado con autorización de Carlos (10.55). Chrome no se da por probado.
- **Queda como precedente:** cuando un criterio mide la operación de una persona y la herramienta del agente lo distorsiona, la medición la hace Carlos a mano, declarada en el informe.

**T-96 pasa a Terminado** (`6d5f3f7`, `docs/T96-ACEPTACION-RESULTADOS.md`), con la corrección del aviso de buque (`adc9ea4`):
- **Las validaciones:** 842/842, `analyze` en cero y corpus 135/135.
- **El cotejo independiente de Codex,** preparado sin el lector, coincide por número y por cada campo con 114 / 121 + 55 / 284 y 127 / 189 / 58 / 113.
- **El aviso de buque:** A07 → A08 no tiene aviso, A05 → A06 pide confirmar, y dos IMO distintos dicen «No parece el mismo buque».
- **En los tres clientes:**
  - las cuentas, el ejemplo de 0020310 y el filtro «Solo con cambios»;
  - «Comparar con la llegada» desde T-82;
  - el archivo comparado no se guarda: solo se agregan archivos `t96cx_*`.
- **La Web,** en el integrado autorizado, con dos desplazamientos manuales de Carlos, declarados.

**El sprint sigue en 44 tareas y ≈ 161.5 h.** El tablero:
- 36 terminadas;
- 0 en revisión;
- T-95 en curso;
- 7 por hacer.

**La diapositiva 15** pasa a «36 de 44». Las tomas de reefer y la comparación entre la llegada y la salida suben a «Ya funciona».

### 10.69 · T-95 entregada, en revisión: el orden de descarga sugerido · Codex la acepta y después hace T-85 · T-106 pasa a Timonel, con ficha completa (16-oct)

**Timonel entregó T-95** (commit `6b209f1`, `docs/T95-RESULTADOS.md`), sobre `ff14dc0`.
- **El servicio:** `discharge_sequence.dart`, puro.
  - La celda física va por huellas, sin calcular pares.
  - Hay re-estibas por columna y por tapa; las tapas copiadas se unen, y cada re-estiba se cuenta una sola vez.
  - Las celdas van de más a menos movimientos por muelle; con empate, de proa a popa.
  - La vuelta va en el orden bodega, tapas y cubierta (10.65).
- **La pantalla «Orden de descarga»** está junto a «Comparar con otro BAPLIE…».
- **Las cifras:**
  - **A07 en GTSTC:** 114 descargas (66 en cubierta y 48 en bodega) y 0 re-estibas por columna, confirmadas por un cotejo sobre el texto crudo que coincide en todas las fuentes 2.x. A06 no trae `LOC+11`.
  - **Otros puertos sí las tienen:** JMKCT 6, COSPC 5, A01 XXVSL 66 y A04 JMKIN 21.
  - **Con tapas PROVISIONALES** en las 21 bahías: 13 re-estibas por tapa, 4 tapas de grúa, 135 movimientos a bordo y 148 por muelle. Dan igual declaradas solo en las pares o copiadas.
- **Las validaciones:** 866/866, `analyze` en cero y corpus 147/147.
- **Los clientes:**
  - Windows;
  - la Web, en el navegador integrado;
  - el Honor, a 1.45, en claro y oscuro.
    - Es el máximo de Ajustes de ese teléfono. **Carlos decidió probar así** y no cambiar la letra del sistema por ADB, y el 2.0 queda cubierto por la prueba de widget.
    - Queda en 1.0.
  - El almacén real tiene solo `t95acc_*`. Chrome sin probar.
- **Un error propio de Timonel, encontrado y corregido.** Dos evidencias `.dart` de su aceptación de T-105, guardadas en `build/`, rompían `analyze` en el repo. Quedaron como `.dart.txt`, sin perder la evidencia.
- **Horas:** las del informe.

**El orden queda así** (Carlos prefirió esperar a que Timonel terminara):
1. **Codex acepta T-95.**
2. **Después Codex hace T-85.** Antes de que Timonel la acepte, Gru revisa sus datos contra el PDF.
3. **T-106 pasa de Codex a Timonel** (antes, 10.66). La ficha está completa en la Ola 5, después de T-105, y la acepta Codex.
   - **Suma** la observación 1 de T-95: «re-estiba» con un guion que no parte línea.
   - **No se coloca nada** hasta que Carlos confirme que compiló los clientes de la demo.

**El sprint sigue en 44 tareas y ≈ 161.5 h.** El tablero:
- 36 terminadas;
- T-95 en revisión;
- T-106 en curso;
- 6 por hacer.

### 10.70 · Codex acepta T-95, salvo la Web · T-85 entregada: el IMDG en el código · El navegador integrado de Codex también sustituye a Chrome (16-oct)

**Codex trabajó de corrido durante la siesta de Carlos,** con las autorizaciones dadas de antemano por Yov.

**T-95, aceptada salvo la Web** (`722a55c`, `docs/T95-ACEPTACION-RESULTADOS.md`):
- **Las validaciones:** 866/866, `analyze` en cero y corpus 147/147, con los 14 SHA protegidos intactos.
- **El cotejo crudo de Codex,** independiente, coincide en 10 fuentes y 39 puertos.
- **Con las tapas:** 13 re-estibas, 4 tapas y 135/148 movimientos.
- **Los clientes:**
  - Windows y el Honor pasan;
  - el almacén real queda en 450 → 462 archivos, y los nuevos son solo `t95cx_*`;
  - el Honor queda en 1.0.
- **Lo que falta:** la revisión visual de la Web. El conector de Codex ofrece su propio navegador integrado, Chrome y Edge, pero no el de la app de Claude que autorizó 10.55, y Codex no cambió de navegador sin permiso.
- **Un solapamiento de Flutter** al empezar quedó declarado, y Codex repitió las validaciones en secuencia.

**T-85, entregada** (`ac72849`, `docs/T85-RESULTADOS.md`):
- **Los datos:**
  - `imdg_42_24_data.dart` (SHA-256 `6fc22683…`) guarda solo códigos: enumeraciones para 7.4.3.2 y la matriz de 7.2.4;
  - en `lib/`, `test/` y `tool/` no hay ningún texto del IMDG.
- **El comprobador privado da 289/289 y 60/60** contra la transcripción verificada (10.60).
- **Las validaciones:** 894/894, `analyze` en cero y corpus 157/157.
- **El corpus:**
  - los 650 resultados anteriores quedan listados con su razón: 640 finales, 313 con cambio de estado o de emisión, 337 iguales y 0 sin explicar;
  - diez diagnósticos de número ONU de A07 se retiran, pero sus pares siguen;
  - A05 y A06 conservan el «no evaluado» por el tipo 22K2.
- **Un paso mínimo, fuera de la lista de la ficha:** `segregation_provider.dart` pasa las tapas del perfil publicado, para respetar la bodega abierta (10.67). Una prueba lo exige.
- **Los clientes:** A03 da 4/154/95 en Windows y en el Honor (360 dp, a 1.45, en claro y oscuro), y el almacén real suma solo 12 `t85acc`.
- **Pendiente:**
  - la Web visual;
  - una observación de Windows sin resolver: al desplazar la matriz de lado con la rueda quedan rastros de algunos glifos, que se limpian con un desplazamiento vertical. En el Honor no pasa, y no se sabe si es la captura o la app. Timonel lo verifica con el mouse al aceptar.

**El navegador integrado de Codex también sustituye a Chrome** para las revisiones visuales de la Web, con la misma regla de 10.55: con la autorización de Carlos y declarado en el informe. Con él, Codex cierra la Web de T-95 y de T-85.

**Dos commits sin el prefijo «Sprint 3:»** (`722a55c` y `ac72849`). No se reescriben: queda anotado.

**Lo que sigue con T-85:** Gru revisa los datos del código contra el PDF; después Timonel la acepta y verifica los rastros con el mouse.

**El sprint sigue en 44 tareas y ≈ 161.5 h.** El tablero:
- 36 terminadas;
- T-95 y T-85 en revisión;
- T-106 en curso;
- 5 por hacer.

### 10.71 · T-95 terminada, con la Web en el navegador integrado de Codex · T-85 pasa la Web y sigue en revisión · La demo, de `ab67fcb` (16-oct)

**T-95, terminada** (`2f0c152`, `docs/T95-ACEPTACION-RESULTADOS.md`). Codex revisó la Web en su navegador integrado, con la autorización de 10.70, declarado y sin afirmar Chrome:
- **A07 en GTSTC, sin tapas:** 114 descargas (66 en cubierta y 48 en bodega), 0 re-estibas y 114/114 movimientos. La primera celda, 021/022/023, da 52/52.
- **JMKCT:** 125 descargas, 6 re-estibas por columna y 131/137.
- **Con tapas PROVISIONALES, en GTSTC:** 13 re-estibas por tapa, 4 tapas de grúa y 135/148. La primera celda da 66/76, con 52 descargas, 10 re-estibas y 2 tapas.
- **Yov rehízo las cuentas** con la regla de 10.59 (re-estiba ×1 a bordo y ×2 por muelle; tapa de grúa ×2), y todas cuadran:
  - 125 + 6 = 131 y 125 + 12 = 137;
  - 114 + 13 + 8 = 135 y 114 + 26 + 8 = 148;
  - 52 + 10 + 4 = 66 y 52 + 20 + 4 = 76.
- **Lo revisado:** la compilación de su copia t95cx (base `93dc695` con `6b209f1`), con `main.dart.js` SHA-256 `9cb58cb7…`. No corrió Flutter ni usó dispositivos, y 338 archivos de código y configuración quedaron sin cambios.
- **Queda la observación cosmética** de «re-/estibas» partida en el resumen de celda, que ya está en T-106.
- **Horas reales:** ≈ 2.3 h de pared, según el informe de Timonel.

**T-85 pasa la Web** (`ab67fcb`, sección 6.1 de `docs/T85-RESULTADOS.md`):
- A03 abre con 369 contenedores. La pantalla muestra la fuente «Código IMDG, Enmienda 42-24 (7.2.4 y 7.4.3.2)» y el resumen 4/154/95, igual que el corpus, Windows y el Honor.
- `main.dart.js` SHA-256 `d2562678…`. Los datos siguen en `6fc22683…`, sin cambios de código.
- **Sigue en revisión:** Gru coteja los datos con el PDF; después Timonel la acepta y revisa con el mouse los rastros de la matriz en Windows.

**Los dos commits de Codex de hoy llevan el prefijo «Sprint 3:».**

**La demo del 17: Yov recomienda compilarla de `ab67fcb`,** lo que hoy está en GitHub, con T-95 terminada y T-85 en revisión:
- T-85 pasó los tres clientes, y sus tablas pasan el comprobador contra la transcripción verificada (10.60);
- la diapositiva 15 la presenta «por cerrar», no terminada;
- si Gru encuentra una diferencia, se corrige después de la demo, y no hay nada publicado.
- **Si Carlos prefiere dejar fuera T-85,** el commit es `722a55c`, que ya trae todo el código de T-95.
- **En la demo, con Windows:** no pasar de 200 % de zoom (10.63) ni desplazar de lado la matriz del IMDG con la rueda del mouse.
- **T-106 sigue sin colocarse** hasta que Carlos confirme que compiló los clientes de la demo.

**La diapositiva 15:**
- **«Ya funciona»** suma el orden de descarga junto con la llegada contra salida, y junta en una línea reefer, tapas, BAPLIE de salida, voz, instalador y privacidad;
- **«Por cerrar»:** la segregación IMDG, el pulido del arrastre y del zoom, y las declaraciones de Google Play;
- **«Falta para el 24-oct»:** la auditoría y la presentación final, la medición de los RNF, y el manual y la prueba piloto;
- **el pie:** «37 de 44 tareas terminadas, 894 pruebas automáticas y 157 de corpus»;
- **las notas del orador,** al mismo estado.

**El sprint sigue en 44 tareas y ≈ 161.5 h.** El tablero (v36), con el piso de pruebas en 894:
- 37 terminadas;
- T-85 en revisión;
- T-106 en curso;
- 5 por hacer.

### 10.72 · T-106 entregada sin colocar · Los clientes de la demo, aparte, con el namespace `demo17` · Tres textos internos quedan fuera (16-oct)

**T-106 está entregada en la copia de Timonel, sin colocar** (regla de 10.69):
- **Validaciones sobre `ab67fcb`:** 914/914 (894 + 20), `analyze` en cero y corpus 157/157. Sobre `93dc695` da 886/886 y 147/147.
- **El control:**
  - sobre HEAD fallan 16 de las 20 pruebas nuevas;
  - con el guion normal, «re-estibas» se parte en 22 anchos, de 378 a 420 dp; con U+2011 no se parte en ninguno.
- **Los clientes,** sobre «PRUEBA T-106» con el namespace `t106acc`:
  - Windows, como oficina, con el mouse y a 300 % con la ventana ancha;
  - el Honor, como muelle, con el pellizco de Carlos a 300 %;
  - se ven la rejilla, la copia a escala, «BAJA» en Carga, las sombras «20'» y «2×20'» sin tocarse, y los cuatro avisos en palabras;
  - 0 registros; el almacén real de Windows suma 14 archivos, todos `t106acc_*`;
  - el Honor queda en 1.0.
- **La Web no se probó,** por decisión de Carlos. Queda para la aceptación de Codex, en su navegador integrado (10.70).

**Yov acepta las cuatro decisiones de Timonel:**
- la reserva se nombra por su celda del BAPLIE, como en T-80;
- la descarga pendiente también se ve en «Número de orden»;
- la leyenda «Ocupado por 20 pies» es nueva, y la de C-5b no cambia;
- «inclúyelo» solo aparece en el formulario de la oficina, donde sí hay intercambio. Con eso se cierra la cola del aviso que quedó de 10.63. **(Mal escrito: lo corrige la 10.75.)**

**Quedan fuera del carril tres textos:**
- las etiquetas de accesibilidad que todavía llevan `C:`;
- los avisos del deriver con `C:`;
- «re-/estibas» partida en el resumen del modo Carga.

Yov propone juntarlos en una **T-107** de ≈ 1 h, después de la demo. Carlos confirma.

**La demo del 17 se compila ahora, sin T-106:**
- T-106 toca el arrastre y el plano, que es justo lo que se presenta, y todavía le falta la aceptación de Codex. Va después, como se acordó en 10.66.
- **Los clientes de la demo son compilaciones aparte, con el namespace `demo17`,** como las de aceptación. No tocan la app real de Windows ni la del Honor, ni el MSIX instalado, así que no hace falta subir versión ni revisar firmas.
- **La base es `bd02328`,** el mismo código que `ab67fcb`.
- **La compilación de Windows se guarda fuera del repo,** en `C:\Proyectos\baystream-demo17\`, para que ninguna compilación posterior la pise.
- **«PRUEBA T-105» no se modifica antes de la demo.** La prueba de humo arrastra en «PRUEBA T-106».
- **Lo hace Timonel.** Capitán está libre, así que no hay choque de Flutter.
- **Después:** Carlos confirma, Timonel coloca T-106 sin commit, Carlos la versiona y Codex la acepta, con la Web.

**El sprint sigue en 44 tareas y ≈ 161.5 h** mientras Carlos no confirme T-107. El tablero (v37):
- 37 terminadas;
- T-85 y T-106 en revisión;
- 5 por hacer.

### 10.73 · La ficha de T-98, en dos fases · El commit de cierre · Quién hace qué hasta el 24 (16-oct)

**La ficha de T-98 está completa** (sección 5, «Cierre»). Mide 004, 006, 008 y 002 con los criterios de T-63, que ya están decididos, en dos fases:
- **Fase A, los instrumentos:** empieza ya. No toca `lib/` y no usa el Honor hasta después de la demo.
- **Fase B, la medición:** sobre los binarios de cierre.

**El commit de cierre:**
- Lo anuncia Carlos cuando T-85 y T-106 estén terminadas, y también T-107 si la crea. La meta es el lunes 19-oct.
- Después de ese commit solo entran en `lib/` las correcciones de defectos que salgan de la medición, con la decisión de Yov y de Carlos.
- Cada corrección obliga a repetir las filas de la medición que toque, y el informe lo dice.

**Quién hace qué hasta el 24.** Es una propuesta de Yov; Carlos confirma.
- **Codex:**
  - la Fase A de T-98, desde ya, en un chat nuevo;
  - la aceptación de T-106 cuando esté versionada;
  - después, la Fase B de T-98.
- **Timonel:**
  - coloca T-106;
  - acepta T-85 después de Gru;
  - hace T-107, si Carlos la crea;
  - después, T-99.
- **Gru:** revisa los datos de T-85 contra el PDF.
- **Yov:** las fichas de T-99, T-100 y T-101, y después la revisión de los informes.
- **Carlos:**
  - el commit de cierre;
  - la operación «PRUEBA T-98»;
  - la lista UN/LOCODE, si la red del agente no llega;
  - la fecha del piloto con cinco participantes de COMAR, que es donde se miden el SUS y la curva de aprendizaje de 002.

**La prioridad para recortar no cambia** (4.2): T-98 va primero y T-99 casi al final. Si falta tiempo, lo que no se mida se declara.

**El sprint sigue en 44 tareas y ≈ 161.5 h.** T-98 pasa a «En curso» cuando Codex empiece.

### 10.74 · Los clientes de la demo pasan la prueba de humo · T-106 versionada (`ce13547`) · En la demo, Windows hasta 150 % (16-oct)

**Los clientes de la demo pasan los seis puntos.** Los hizo Timonel en `C:\Proyectos\baystream-demo17\`, desde `bd02328` y con el namespace `demo17`.
- **Los binarios:**
  - `baystream.exe` `e2930351…` y el APK `a6564096…`, que es el mismo instalado en el teléfono;
  - Android va en release, sin `debuggable`, y firmado con la clave de depuración porque la copia no tiene `key.properties`. Como es una app aparte, no importa.
- **Solo cambian dos líneas de `android/`, en la copia:** el `applicationId` `.demo17` y el nombre «BayStream demo», que pidió Carlos porque el Honor tiene 42 apps llamadas «BayStream».
- **La prueba de humo,** con las sesiones de Carlos:
  1. la oficina movió OR 1 con motivo, y el Honor lo vio sin recargar;
  2. el muelle pidió mover OR 2, la oficina lo aprobó, y quedó igual en las dos pantallas;
  3. «PRUEBA T-105» abre con 3 contenedores, 1 bahía y 15.0 t, sin cambios;
  4. el orden de descarga abre (PAMIT, 5 descargas, 5/5);
  5. «Segregación · IMDG» abre con la fuente 42-24;
  6. el zoom de Windows (ver abajo).
- **Un hallazgo para la demo:** en Windows con la ventana maximizada, a 200 % la rejilla queda corrida a la derecha y hay que desplazarla; a 150 % se ve entera.
  - Lo corrige T-106, que no está en la demo.
  - **En la demo, Windows llega hasta 150 %.** Reemplaza el límite de 200 % de 10.63 y 10.71.
- **Las sesiones quedan iniciadas:** la oficina en Windows y el muelle en el Honor.
- **El almacén real** suma 14 archivos, todos `demo17_*`.

**T-106, colocada y versionada** (`ce13547`, por Carlos):
- HEAD seguía en `bd02328`, y las cinco bases no habían cambiado.
- Lo colocado es byte a byte lo probado.
- `analyze` en cero y 914/914 sobre el árbol, con 5 archivos modificados y 5 nuevos.
- **El piso de pruebas sube a 914.**

**La aceptación de Codex** es sobre `ce13547`:
- Windows y la Web, ya.
- **El Honor espera a que termine la demo,** porque es el teléfono de la presentación.
- «PRUEBA T-106» lleva ahora los dos movimientos de la prueba de humo.
- **El orden de Codex:** si ya empezó la Fase A de T-98, la aceptación va después; si no, va primero, porque desbloquea el commit de cierre.

**El sprint sigue en 44 tareas y ≈ 161.5 h.** El tablero (v39), con el piso de pruebas en 914:
- 37 terminadas;
- T-85 y T-106 en revisión;
- 5 por hacer.

### 10.75 · D1 de la aceptación de T-106 no es un defecto: Yov escribió mal la 10.72 · Codex sigue con el Honor después de la demo (16-oct)

**La aceptación parcial de Codex** (`611ac25`, `docs/T106-ACEPTACION-RESULTADOS.md`):
- reglas intactas, 914/914, corpus 157/157 y `analyze` en cero;
- Windows y la Web pasan: en la Web integrada, a 300 %, con la copia a escala y el rojo;
- el almacén real suma solo 14 `t106cx_*`;
- **el veredicto es EN REVISIÓN por D1,** y falta el Honor.

**Qué es D1.** En «Pedir cambio» del muelle, con «Intercambiar dos contenedores» apagado, se envía un objeto a una celda prevista para otro pendiente del mismo tamaño. El rechazo dice «La celda está prevista para otro objeto; inclúyelo en el intercambio.». Codex lo marcó como defecto porque la 10.72 decía que «inclúyelo» solo aparece en el formulario de la oficina.

**Yov lo revisó en el código, y D1 no es un defecto. El error fue de Yov, al escribir la 10.72:**
- **El formulario del muelle sí tiene el intercambio.** Es más: abre con «Intercambiar dos contenedores» encendido (`swap = !widget.direct`, `change_requests_page.dart`). Así que el consejo es correcto y el muelle puede seguirlo.
- **Lo que Timonel describió era una observación, no un cambio.** El formulario del muelle no muestra la vista previa de `review()`, solo el error al enviar. Esa guarda (`widget.direct &&`) viene de T-81 (`c31055d`), y T-106 no toca ese archivo.
- **La 10.72 queda corregida:** «inclúyelo» sale en los dos formularios cuando aplica, porque los dos tienen intercambio. Lo que T-106 cerró de la 10.63 es que la frase ya no sale cuando no aplica, por ejemplo entre un 20 y un 40.

**Una observación, no un defecto de T-106:** el muelle ve el aviso solo después de enviar, y la oficina lo ve antes. Es una candidata para T-107, si Carlos la crea.

**Codex sigue:**
- el Honor, después de la demo;
- su prueba propia del muelle se invierte: «inclúyelo» debe aparecer cuando el intercambio está apagado y aplica;
- **el veredicto puede quedar en ACEPTADA si el Honor pasa.**

**El sprint sigue en 44 tareas y ≈ 161.5 h.** El tablero no cambia de columnas.

### 10.76 · Nace T-107: el encabezado del plano, compacto en el teléfono, con los textos que dejó T-106 · No entra en la demo (16-oct)

**Carlos lo encontró en el Honor** (16-oct, 20:45), con A07 en el modo Carga en «BayStream demo»:
- los controles de arriba del plano ocupan casi toda la pantalla;
- la rejilla queda en una franja abajo, y no deja ver el plano;
- pidió ordenarlos, con otro desplegable al lado si no caben, sin cambiar cómo funciona nada.

**Por qué pasa:** la vista del plano es una columna fija. Los controles van en un `Wrap`, y a 360 dp cada botón cae en su propia línea. La rejilla se queda con lo que sobra.

**Nace T-107**, de ≈ 3.0 h (ficha completa en la Ola 5, después de T-106):
- **Junta dos cosas:**
  - el encabezado compacto en pantallas angostas: el modo y un desplegable «Acciones» en una línea, el resumen en otra, y Windows y la Web sin cambios;
  - los tres textos que T-106 dejó fuera, que eran la T-107 que Yov propuso en 10.72.
  - Con este pedido, Carlos la confirma.
- **La hace Timonel,** que conoce esos archivos por T-106, y la acepta Codex.
- **Entra antes del commit de cierre,** porque T-98 y T-99 miden RNF-002 y RNF-003 a 360 dp. La meta del 19-oct se mantiene; si no alcanza, el cierre pasa al 20.

**No entra en la demo de mañana.** Los clientes de la demo ya están compilados y probados, y cambiar el encabezado la víspera es más riesgo que ayuda. Para la demo, en el Honor:
- «PRUEBA T-105» tiene una sola bahía con tres contenedores, así que cabe en la franja; así arrastró Timonel en la prueba de humo, sobre «PRUEBA T-106»;
- si hace falta, se pellizca la rejilla para alejarla.

**El orden en el Honor después de la demo:** primero Codex termina su parte de la aceptación de T-106, y después Timonel prueba T-107. El código y las pruebas de T-107 pueden avanzar antes, en una copia.

**El sprint pasa a 45 tareas y ≈ 164.5 h.**
- La diapositiva 15 dice «37 de 45».
- El tablero (v41):
  - 37 terminadas;
  - T-85 y T-106 en revisión;
  - 6 por hacer.

### 10.77 · Carlos decide que T-107 entre en la demo: la parte A esta noche, con un corte a medianoche y la versión de hoy como respaldo (16-oct)

**Carlos decide que el encabezado se arregla antes de la demo presencial.** Reemplaza el «No entra en la demo» de la 10.76.

**Para que quepa esta noche, T-107 se parte en dos:**
- **Parte A, antes de la demo:** el encabezado compacto en pantallas angostas, y «re-estibas» sin partirse en el resumen de Carga. Es lo que se ve en la demo.
- **Parte B, después de la demo:** la etiqueta de accesibilidad y los avisos del deriver sin `C:`, y U+2011 en los demás lugares.
- **Las dos son T-107,** con la misma ficha.

**La base es HEAD, que ya trae T-106.** Así la demo también gana:
- el zoom de Windows sin correrse a 200 %;
- los avisos en palabras, sin `C:`.

Timonel ya validó T-106 en el Honor, y Codex hace su parte del Honor esta noche.

**El orden de esta noche.** El Honor se usa por turnos y Flutter, un comando a la vez.
1. **Codex:** la parte del Honor de la aceptación de T-106. Va primero, mientras Timonel programa en su copia sin el Honor.
2. **Timonel:** T-107 parte A sobre HEAD, con pruebas de widget, Windows y el Honor. La coloca sin commit, y Carlos la versiona.
3. **Codex:** una revisión rápida de la parte A: el diff, sus propias pruebas a 360 dp, la suite y `analyze`. La aceptación completa, con los clientes, va después de la demo.
4. **Timonel:** recompila los clientes `demo17` desde el nuevo HEAD.
   - Antes guarda los de hoy en `C:\Proyectos\baystream-demo17-bd02328\`, con su APK, como respaldo.
   - Repite la prueba de humo con Carlos, y le suma el encabezado en el Honor y Windows a 200 %.

**El corte es a medianoche** (Carlos puede moverlo). Si a esa hora la prueba de humo nueva no pasó, se presenta con los clientes de hoy, que ya pasaron la suya (10.74), y la guía de la demo sigue como está.

**El sprint sigue en 45 tareas y ≈ 164.5 h.** T-107 pasa a «En curso». El tablero (v42):
- 37 terminadas;
- T-85 y T-106 en revisión;
- T-107 en curso;
- 5 por hacer.

### 10.78 · T-106 terminada: Codex completa el Honor esta noche · Timonel avanza con T-107 parte A (16-oct)

**T-106 está aceptada** (`80b8954`, `docs/T106-ACEPTACION-RESULTADOS.md`), sobre `ce13547`.
- **El Honor:** el pellizco de Carlos a 300 %, «BAJA» y las sombras en «Número de orden», la pantalla de T-95 y los cuatro avisos en palabras, a 1.45.
- **A 1.0:** Carga, el arrastre rojo sobre «BAJA», la copia a escala a 300 % y la sombra, que no responde a gestos.
- **D1 no es defecto** (10.75), y la prueba propia invertida pasa 1/1.
- **Lo demás:**
  - reglas intactas, 914/914, corpus 157/157 y `analyze` en cero;
  - el almacén real de Windows solo suma 14 `t106cx_*`;
  - `demo17` conserva su huella, y el Honor queda libre y en 1.0.
- **Una observación, la O2, que ya es de T-107:** a 1.45, el encabezado de Carga ocupa toda la pantalla. Por eso Carga y el arrastre se comprobaron a 1.0. La ficha de T-107 ya exige que la rejilla tenga un tercio del alto a 1.45.
- **Horas reales:** ≈ 2.5 h de pared (Timonel).

**T-107 parte A va bien.** En la copia de Timonel pasan 922/922 pruebas, `analyze` en cero y el corpus 157/157, y Windows ya pasó. Ahora sigue el Honor, con una app aparte (`.t107`).

**La diapositiva 15:**
- el pie dice «38 de 45»;
- en «Por cerrar», el pulido del arrastre se cambia por el encabezado del plano en el teléfono;
- las notas del orador, al mismo estado.

**El sprint sigue en 45 tareas y ≈ 164.5 h.** El tablero (v43):
- 38 terminadas;
- T-85 en revisión;
- T-107 en curso;
- 5 por hacer.

### 10.79 · La demo va con T-106 y T-107 parte A: los clientes nuevos pasan la prueba de humo a las 22:09 (16-oct)

**T-107 parte A, versionada** (`2414588`):
- **Lo que entrega:** por debajo de 600 dp, el encabezado va en dos líneas: el modo, «Acciones» (con el globo de las solicitudes) y la nube, y debajo el resumen en una línea con «OR / últimos dígitos». A 600 dp o más sigue el `Wrap` de antes.
- **Las validaciones:** 922/922 (914 + 8), `analyze` en cero y corpus 157/157.
- **El control:** sobre HEAD fallan 7 de las 8 pruebas nuevas.
- **Los clientes:** Windows sin cambios; en el Honor, a 1.0 y a 1.45, la rejilla empieza a unos 300 dp de 800.
- **Cinco pruebas existentes** (t74 a t78) agregan solo el toque previo en «Acciones» a 360 dp. Yov lo acepta: es el «un toque más» de la ficha.
- **La revisión rápida de Codex: PASA.** Presentación y acciones equivalentes a las del padre, sus pruebas propias 21/21 y la suite 922/922. La aceptación completa, con los clientes, va después de la demo, junto con la parte B.
- **El piso de pruebas sube a 922.**

**Los clientes de la demo, recompilados desde `2414588`** (Timonel), con el mismo `.bat` y el namespace `demo17`:
- `baystream.exe` `f7605d03…` y el APK `75491db1…`, que es el mismo instalado en el teléfono.
- El APK se instaló encima del anterior, así que la sesión de muelle se conservó. Windows abrió sin sesión, y Carlos la volvió a iniciar.
- **La prueba de humo pasa los siete puntos a las 22:09:**
  1. la oficina movió OR 3;
  2. el muelle pidió mover OR 2, con el globo en «Acciones», y la oficina lo aprobó;
  3. «PRUEBA T-105» abre sin cambios;
  4. el orden de descarga abre;
  5. el IMDG abre;
  6. Windows a 200 % muestra la bahía centrada y entera;
  7. en el Honor, «PRUEBA T-105» en Carga muestra el encabezado en dos líneas y los tres contenedores a la vista.
- **El respaldo,** con los clientes de las 19:00, está en `C:\Proyectos\baystream-demo17-bd02328\`.
- **Un hallazgo de Windows:** el banco de T-107 se cayó una vez al arrancar (`0xe06d7363`) mientras otra BayStream estaba abierta. **En la demo va una sola BayStream a la vez.** La causa no se investigó y queda anotada para T-98.

**La guía de la demo queda al día:**
- Windows puede llegar a 200 %;
- los avisos rojos ya salen en palabras;
- en el Honor, los botones están en «Acciones»;
- si falla Windows, se usa el respaldo, que sigue limitado a 150 %.

**La diapositiva 15** dice 922 pruebas.

**El sprint sigue en 45 tareas y ≈ 164.5 h.** El tablero (v44), con el piso de pruebas en 922:
- 38 terminadas;
- T-85 en revisión;
- T-107 en curso, por la parte B;
- 5 por hacer.

### 10.80 · Revisión del tutor del 17-oct: una sola hipótesis con seis indicadores, título resumido y rediseño visual después del cierre (17-oct)

**La presentación del proyecto** (5 a 7 min, con el video de 60 s y el logo de BayStream) se mostró al tutor el 17-oct. Los archivos viven fuera del repo, en `C:\Proyectos\baystream-presentacion\`; el vigente es el borrador 10.

**Lo que pidió el tutor y lo que se decidió:**
1. **Una sola hipótesis.** Las seis metas que eran H1 a H6 pasan a ser **indicadores** de una hipótesis de investigación única, numerados del 1 al 6:
   - **Hi:** «El uso de BayStream reduce el tiempo de interpretación de los planos de estiba, previene los errores de posición de contenedores y mejora el acceso a la información en la oficina y el muelle, frente a la lectura manual de archivos BAPLIE y los listados impresos».
   - **Indicadores y metas:** 1) precisión del lector ≥ 98 %; 2) tiempo para localizar un contenedor −60 %; 3) errores de posición de 1 % a 0.2 %; 4) esfuerzo −50 % frente a tres apps nativas; 5) latencia oficina–muelle ≤ 3 s; 6) SUS ≥ 68.
   - La presentación ya lo tiene. **Falta** alinear el Documento Completo de Investigación: el capítulo de hipótesis y la operacionalización de variables. Carlos lo edita; Yov puede redactar los párrafos.
2. **Variables e indicadores** sin las H: van numerados del 1 al 6.
3. **Título resumido.** Carlos eligió: «Ecosistema multiplataforma para la planificación de estiba de portacontenedores en tiempo real». Sale «optimización», porque BayStream no planifica la estiba de forma automática; eso está entre los límites. La presentación ya lo usa, y el documento y los entregables siguientes lo adoptan.
4. **La pregunta de Android.** BayStream no guarda en SQLite: usa Hive, en la carpeta privada de la app (`files/vessel_store`). La caché sin conexión del SDK de Firestore es aparte y la maneja el SDK.
5. **La interfaz.** El tutor la vio pobre: debe ser más intuitiva y de impacto. Carlos decide hacerlo **todo después del commit de cierre**:
   - primero, el sistema de diseño sacado del ícono (`#0D47A1`, `#FF7A1A`, `#6E9DE6`) y las maquetas de las cinco pantallas clave: inicio, plano por bahía, muelle de carga y descarga, estadísticas y avance en la oficina;
   - después, la implementación como tema y componentes, sin tocar la lógica y con el piso de pruebas intacto.
   - La tarea se abre al cerrar lo funcional. El tablero no cambia hoy.

**El sprint sigue en 45 tareas y ≈ 164.5 h.**

### 10.81 · T-98 Fase A, por corregir: la batería de conformidad va a `tool/` · T-107 parte B, en revisión · Timonel acepta T-85 sin el Honor · Nacen T-108 y T-109 (17-oct)

**Sin el Honor por ahora (Carlos, 17-oct).** Se avanza con lo que no lo necesita. Las comprobaciones en el teléfono de T-107, T-85 y T-98 se hacen cuando Carlos lo permita.

**T-98 Fase A, entregada** (Codex). Carlos la versionó en `194f140`, sin el prefijo «Sprint 3:»; no se reescribe.
- **Son 17 archivos:** los scripts de `tool/t98_*`, la batería y las autopruebas de `test/t98_*`, y `docs/T98-RESULTADOS.md`. Lo ensayado sobre HEAD no es una medición.
- **La suite quedó en rojo: 948/962.** Fallan 13 casos de la batería de conformidad de RNF-008, porque el lector acepta en silencio BBBRRTT mal formados, dígitos ISO 6346 alterados, pesos en LBR y TNE, y archivos sin UNB, BGM, UNT o UNZ. Falla también la prueba de T-92.
- **Decisiones de Yov:**
  1. **La suite por defecto queda en verde.** La batería de conformidad es un instrumento de medición: pasa a `tool/t98_estandares_test.dart`, como el corpus, y registra por caso qué hace el lector (acepta en silencio, avisa o rechaza). Para un caso negativo, «detectado» es rechazar o avisar de forma visible. En `test/` quedan las 12 autopruebas.
  2. **El fallo de T-92 no es del producto.** Al sacar una copia con git en Windows, los `.js` servidos pasan a CRLF y la huella no cuadra. Se agrega `web/vendor/**/*.js -text` a `.gitattributes`, autorizado fuera del carril de T-98. Hace falta antes de la Fase B, que compila desde una copia limpia.
  3. **El TLS negativo** se hace con el módulo `ssl` de Python, sin instalar OpenSSL.
  4. **Los mensajes de commit** empiezan con «Sprint 3:».
- La corrección va a Codex ahora. **T-98 pasa a «En curso».**

**T-107 parte B, en revisión** (Timonel, `b862b15`):
- La etiqueta de las celdas de carga y los 19 avisos del deriver nombran el objeto como en T-106, sin `C:` ni `R:`. «re‑estiba» lleva U+2011 en los 15 textos visibles que quedaban.
- Yov revisó el commit: solo toca el carril, y en el deriver solo cambian los textos.
- 952/952 (922 + 30) en una copia limpia, `analyze` en cero y corpus 157/157. Windows a 1280 dp, sin cambios. **Falta el Honor.** La acepta Codex.
- **«Estadísticas» que lleva a «Bay Plan»:** no se reproduce en 16 casos a 360 dp ni en Windows. La hipótesis de Timonel es un toque sobre el perfil longitudinal (`vessel_profile_view.dart:171`). Se revisa en el Honor.
- **Anotado:** los desbordes de Estadísticas a 360 dp con letra 1.45 y 2.0, y «re-estibas» con guion normal en `privacy_policy.dart:70`. Pasan a T-109.

**T-85: la acepta Timonel ahora, sin el Honor.** La revisión de Gru deja de ser requisito: los datos se verificaron dos veces a ciegas (10.60), y el comprobador privado da 289/289 y 60/60. Si Gru logra importar el repo, su revisión suma.

**Nacen dos tareas antes del commit de cierre (Carlos, 17-oct).** Fichas completas en la Ola 5:
- **T-108 · El lector avisa lo que no cumple el estándar** (≈ 2.5 h, Codex; la acepta Timonel): pesos en LBR y TNE a kg, posiciones mal formadas, dígito de control ISO 6346 y archivo incompleto, con aviso en la tarjeta del viaje.
- **T-109 · Estadísticas sin desbordes a 360 dp con letra grande** (≈ 1.0 h, Codex; la acepta Timonel), más el último guion de «re-estibas».

**El orden:**
- **Codex:** la corrección de T-98, después T-108 y T-109. El carril de `lib/` pasa a Codex.
- **Timonel:** la aceptación de T-85; después acepta T-108 y T-109.
- **Codex acepta T-107** con el Honor, cuando se pueda.
- **El commit de cierre** llega cuando T-85, T-107, T-108 y T-109 estén terminadas. Meta: 19 o 20-oct.

**El piso de pruebas sigue en 922** hasta las aceptaciones. Con T-107 B y las autopruebas de T-98 serían 964.

**El sprint pasa a 47 tareas y ≈ 168.0 h.** El tablero (v45) suma 223.0 h:
- 38 terminadas;
- T-85 y T-107 en revisión;
- T-98 en curso;
- 6 por hacer: T-108, T-109, T-87, T-99, T-100 y T-101.

### 10.82 · La corrección de T-98 queda versionada · El TLS de RNF-004 se mide en las conexiones de BayStream, no en la política del servidor (18-oct)

**La corrección de 10.81** (Codex; versionada por Carlos en `46202d7`):
- `.gitattributes` con `web/vendor/**/*.js -text`. En un clon nuevo, los `.js` salen con LF y T-92 pasa 7/7.
- La batería de conformidad está en `tool/t98_estandares_test.dart` y deja una tabla con 29 observaciones, sin dictamen por caso. Los 13 negativos siguen aceptados en silencio; los corrige T-108.
- La suite por defecto da 934/934 y `analyze` en cero, **sobre un clon de `194f140`**, sin T-107 parte B. Sobre HEAD tienen que ser 964 (922 + 30 + 12). Codex lo confirma antes de empezar T-108, y entonces el piso sube a 964.
- El TLS negativo, con el módulo `ssl` de Python (OpenSSL 3.0.18), sin instalar nada.
- **La Fase A queda hecha,** salvo los ensayos en el Honor y con la sesión de «PRUEBA T-98». T-98 sigue «En curso» por la Fase B.

**El hallazgo del TLS.** Los tres servidores de Firebase (`firestore`, `identitytoolkit` y `securetoken.googleapis.com`) **aceptan TLS 1.1** cuando un cliente lo pide. El criterio de T-63 pedía que ese intento fallara.

**Yov decide cómo se mide** (T-63 delegó los RNF en Yov):
- El ERS pide «TLS 1.2+ para sincronización en la nube». Es una propiedad de **las conexiones de BayStream**, y la política de los servidores de Google no la controla el proyecto.
- **El dictamen** se toma de la versión que negocian los clientes de BayStream en conexiones reales con sesión:
  - **Web:** el panel Security de Chrome y el NetLog, conexión por conexión;
  - **Windows:** el saludo TLS capturado con `pktmon`, que viene con Windows, con los permisos de administrador que da Carlos; si no alcanza, se declara;
  - **Android:** sin root no se ve el saludo. Se declaran la versión de Android del Honor y lo que documenta la plataforma, como limitación.
- **El intento con TLS 1.1** queda como observación del proveedor: se informa con su fecha, sin dictamen sobre BayStream.
- **Si un cliente de BayStream negocia menos de 1.2,** eso sí es un incumplimiento: Codex se detiene y avisa.

**Sigue igual:** Codex hace T-108 y T-109; Timonel acepta T-85 y después las dos nuevas. El sprint, en 47 tareas y ≈ 168.0 h; el tablero, en v45.
