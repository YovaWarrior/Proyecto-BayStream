# BayStream · Sprint 3 — instrucciones de implementación

**Ventana:** 7 → 24 de octubre de 2026 · **37 tareas · ≈ 203 h estimadas** · rama **`sprint-3`**
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
- un lector de Excel, para importar el listado (RF-038), si hace falta.

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
| **USO** | Uso fuera del aula: Play, iPhone, tema, barra, Web sin conexión, instalador | Prueba de campo · Play | 12.5 | T-88 … T-93 |
| **RF-041** | Búsqueda por voz *(nuevo)* | Pedido de Carlos, 5-oct | 4.5 | T-94 |
| **ERS** | RF-028, RF-029, T-56 y el título a 360 px | ERS · Sprint 2 | 17.0 | T-95, T-96, T-56, T-97 |
| **TC** | RNF (T-63), manual (TC-02), presentación final (TC-05) | Curso | 63.0 | T-98 … T-100 |
| **PIL** | Prueba piloto en una escala real | Permiso de COMAR | 4.0 | T-101 |
| | **Total** | | **≈ 203.0** | **37 tareas** |

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

| Tarea | Elemento | h | Qué | Terminada cuando |
|---|---|---:|---|---|
| **T-72** | RF-037 | 3.0 | Estado operativo de cada contenedor y reserva (planificado, movido, cancelado) y bitácora de movimientos: qué, cuándo, quién | Persistente y sin conexión; cada cambio queda en la bitácora con su hora |
| **T-73** | RF-038 | 4.5 | Importar el listado Excel de la agencia, con tabla de equivalencias editable (tipos, puertos, códigos de línea) y lectura de peligrosas desde CONTENIDO | `LISTADO_A08.xlsx`: 176 filas, 120 llenos que cruzan con A08 y 56 vacíos en 6 grupos; LNB ↔ LINB, COMNG ↔ COSPC |
| **T-74** | RF-038 | 3.0 | Plan de carga: cruzar listado y plan; número de orden en cada celda; pendientes por bahía | Los 9 conteos por bahía de la sección 2 del caso, en cubierta y bodega |
| **T-75** | RF-037 | 4.0 | Descarga: tocar el contenedor y queda marcado; aviso de re-estiba si su puerto no es este; deshacer | Los 114 de `CORPUS_A07` se marcan y se deshacen sin perder la bitácora |
| **T-76** | RF-037 | 5.0 | Carga: confirmar un lleno por número de orden o de contenedor; asignar un vacío solo a una celda libre de su grupo; hora y marchamo; cancelar y corregir | Reproducir `CASO_A08_EVENTOS.json` deja en las 460 posiciones el contenedor de `CASO_A08_ESTADO_FINAL.csv` |
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
