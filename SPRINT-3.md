# BayStream · Sprint 3 — instrucciones de implementación

**Ventana:** 7 → 24 de octubre de 2026 · **40 tareas · ≈ 201.9 h estimadas** (al 7-oct, 10.11) · rama **`sprint-3`**
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
la máquina, con `SEMÁFORO:` cuando alguien mide.

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
   - Corregir es anular con motivo y registrar de nuevo, en un solo paso.
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


| Tarea | Elemento | h | Qué | Terminada cuando |
|---|---|---:|---|---|
| **T-72** | RF-037 | 3.0 | Estado operativo de cada contenedor y reserva (planificado, movido, cancelado) y bitácora de movimientos: qué, cuándo, quién | Persistente y sin conexión; cada cambio queda en la bitácora con su hora |
| **T-73** | RF-038 | 4.5 | Importar el listado Excel de la agencia, con tabla de equivalencias editable (tipos, puertos, códigos de línea) y lectura de peligrosas desde CONTENIDO | `LISTADO_A08.xlsx`: 176 filas, 120 llenos que cruzan con A08 y 56 vacíos en 6 grupos; LNB ↔ LINB, COMNG ↔ COSPC · **ficha completa arriba** |
| **T-74** | RF-038 | 3.0 | Plan de carga: cruzar listado y plan; número de orden en cada celda; pendientes por bahía. **Desde T-73** la operación puede existir solo con la fuente `export_list`, porque el texto del BAPLIE no se conserva después de leerlo: T-74 guarda ese texto como fuente `loading_baplie` (y `arrival_baplie` si aplica) **en la misma operación**, no en una nueva · **ficha completa arriba** | Los 9 conteos por bahía de la sección 2 del caso, en cubierta y bodega; la operación queda con sus fuentes completas |
| **T-75** | RF-037 | 4.0 | Descarga: tocar el contenedor y queda marcado; aviso de re-estiba si su puerto no es este; deshacer | Los 114 de `CORPUS_A07` se marcan y se deshacen sin perder la bitácora · **ficha completa arriba** |
| **T-76** | RF-037 | 5.0 | Carga: confirmar un lleno por número de orden o de contenedor; asignar un vacío solo a una celda libre de su grupo; hora y marchamo; cancelar y corregir | Reproducir `CASO_A08_EVENTOS.json` deja en las 460 posiciones el contenedor de `CASO_A08_ESTADO_FINAL.csv` · **ficha completa arriba** |
| **T-77** | RF-037 | 3.0 | Validación preventiva antes de confirmar: celda, 20/40, peso de la pila, posición del planificador para los llenos, grupo para los vacíos | Un vacío en una celda de otro grupo no se confirma sin motivo escrito |
| **T-78** | RF-037 | 3.0 | Vista de avance para la oficina: descargados, cargados, pendientes y cancelados, por bahía | Cuadra con la bitácora en cada momento del caso |

### Ola 3 · Sincronización, cuentas y roles (13–17 oct)

| Tarea | Elemento | h | Qué | Terminada cuando |
|---|---|---:|---|---|
| **T-79** | RF-032+ · RF-034 | 12.0 | Cuentas con correo y lista de autorizados; Firestore en `baystream-app`; reglas; cola sin conexión en el muelle | Dos dispositivos ven el mismo avance; uno sin red sube al volver; reglas verificadas en uso real |
| **T-80** | RF-035 | 6.0 | Roles muelle y oficina; el muelle pide un cambio y la oficina lo aprueba | El intercambio 128 ↔ 145 del caso se pide desde el muelle y se aprueba desde la oficina |
| **T-81** | RF-038 | 4.0 | Cambios desde la oficina: mover o cancelar contenedores, sincronizados al muelle | El muelle ve el cambio sin recargar el archivo |

**Punto de control del 14-oct.** Si la sincronización no funciona para esa fecha, el
módulo de muelle se entrega **en un solo dispositivo**, con exportación de la bitácora. Así
el 24-oct siempre hay algo que funciona.

### Ola 4 · Salida, tapas, IMDG y versiones (17–21 oct)

| Tarea | Elemento | h | Qué | Terminada cuando |
|---|---|---:|---|---|
| **T-82** | RF-039 | 10.0 | BAPLIE de salida en la misma versión 2.x en que llegó, con lo cargado, re-estibado y cancelado; VGM y tara exactos del listado | Releído por el propio lector, coincide con `CASO_A08_ESTADO_FINAL.csv` en las 460 posiciones |
| **T-83** | RF-040 | 4.0 | Tapas en el perfil del buque, por bahía: sin tapa, una automática, o 1–3 de grúa con las filas que cubre cada una | Se declaran una vez por buque y se copian a otras bahías |
| **T-84** | RF-040 | 4.0 | Tapas en la operación: quitar y reponer como movimientos; aviso al marcar bodega bajo tapa cerrada | Los movimientos de tapa cuentan en el avance |
| **T-85** | RF-027+ | 10.0 | Segregación por clase con las tablas 7.2.4 y 7.4.3.2 del IMDG 42-24, que Yov transcribe y verifica | Los casos sintéticos de la transcripción dan lo que dice la tabla; la clase 9 sale «no evaluado» |
| **T-86** | BAP | 3.0 | Detectar la versión por la cabecera y leer toda la familia 2.x; si llega otra, decirlo | A01 … A08 siguen igual; una 1.x o una 3.x se rechaza con un mensaje claro |
| **T-87** | BAP | 10.0 | Leer BAPLIE 3.1 | Necesita un archivo real; sin él, se declara y no se empieza |

### Ola 5 · Uso fuera del aula y voz

| Tarea | Elemento | h | Qué |
|---|---|---:|---|
| **T-88** | USO | 2.5 | Requisitos de Play: política de privacidad nueva (con sincronización sí salen datos), enlace en la app, ícono propio, decisión D3 |
| **T-89** | USO | 1.0 | iPhone acepta .edi: sin filtro por extensión y validación por contenido (`UNB`/`UNH`) |
| **T-90** | USO | 2.0 | Modo claro y oscuro con interruptor, en los tres clientes |
| **T-91** | USO | 1.5 | Barra superior plegable: ocultar los iconos junto al título mientras se ve el plano |
| **T-92** | USO | 3.0 | Web sin conexión: servir el motor de dibujo y la fuente desde el propio sitio |
| **T-93** | USO | 2.5 | Instalador de Windows |
| **T-94** | RF-041 | 4.5 | Dictar el número de contenedor, o sus últimos dígitos, y buscarlo |
| **T-102** | USO | 1.0 | Peso en las celdas del PDF, como en el plano impreso (nace en 10.2) |

### Ola 6 · Resto del ERS

| Tarea | Elemento | h | Qué |
|---|---|---:|---|
| **T-95** | RF-028 | 7.5 | Orden de descarga sugerido, con sobreestibas por columna y por tapa |
| **T-96** | RF-029 | 6.0 | Comparación llegada contra salida |
| **T-56** | ERS | 2.5 | Tomas de reefer por celda y por rangos (diferida del Sprint 2) |
| **T-97** | ERS | 1.0 | Título sin truncar a 360 px (RNF-003) |

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
