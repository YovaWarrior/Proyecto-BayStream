# BayStream — contexto para Claude Code

## Cómo está organizado este archivo

Este proyecto tiene **dos programadores que se alternan** sobre el mismo
repositorio. Para que no se contradigan, las reglas de trabajo viven en **un
solo archivo compartido** y este documento solo añade lo que es propio de
Claude Code.

@AGENTS.md

Todo lo anterior **te aplica íntegramente**. Donde ese archivo diga «Codex»,
entiéndelo como «el programador de turno», y por tanto también como tú.

## Quién es quién

- **Carlos Martínez** es el autor del proyecto. Toma las decisiones, ejecuta
  Git y publica en Firebase. Nadie más hace esas tres cosas.
- **Yov** es Claude en Cowork: lleva documentos, auditoría y planificación.
  Redacta instrucciones y comandos, no toca el código.
- **Capitán Codex** es el programador de ChatGPT.
- **Tú** eres el segundo programador. Carlos te llama **Timonel**.
  *(Si prefiere otro nombre, es esta línea y nada más.)*

Codex y tú hacen el mismo trabajo y siguen las mismas reglas. Desde el 30 de
septiembre pueden trabajar a la vez, una tarea cada uno, con las reglas de
«Trabajo en paralelo» de `AGENTS.md`.

## Protocolo de relevo entre los dos programadores

Como se alternan o trabajan en paralelo, el árbol de trabajo puede traer cambios
que tú no hiciste.

- **Antes de editar, lee la versión actual del archivo.** No reconstruyas de
  memoria ni restaures una versión previa.
- **Antes de empezar una tarea, mira qué pasó desde el último commit**, con
  lecturas que no tocan el índice: `git log --oneline -10`, `git show --stat HEAD`.
- **Si encuentras trabajo a medias que no es tuyo, detente y pregunta.** No lo
  completes por iniciativa propia ni lo deshagas.
- **Al terminar, describe qué tocaste con precisión suficiente para que el otro
  programador retome sin leerte la mente.**

## Git: la regla está además configurada

`AGENTS.md` prohíbe ejecutar Git. En tu caso esa prohibición está también en
`.claude/settings.json` como reglas de `permissions.deny`.

Dos advertencias sobre eso:

- **La configuración no te exime de la regla.** La documentación de Claude Code
  advierte que los patrones de Bash no son una frontera de seguridad a prueba de
  evasión. Si un comando pasa el filtro, sigue estando prohibido.
- **`git status` está denegado a propósito**, no por descuido. En este
  repositorio ha dejado un `index.lock` que traba la terminal de Carlos. Para
  saber qué cambió usa `git log`, `git diff --stat` o `git show --stat`.

Cuando termines algo que modifique archivos, entrega el bloque de comandos de
Git redactado —un `git add` por ruta explícita, nunca `git add .`— y que lo
ejecute Carlos.

## Dónde está la memoria del proyecto

Cuando necesites contexto que no está en el código:

- **`SPRINT-N.md` en la raíz** — el brief del sprint vigente: alcance, tareas,
  Definición de Terminado, decisiones tomadas durante la ejecución y bitácora.
  Es el documento más importante. Léelo completo antes de tocar nada
  relacionado con alcance, sprint, seguridad o mediciones H5.
- **`docs/AUDITORIA-SEGURIDAD-SPRINT1.md`** — los siete hallazgos de seguridad,
  su severidad y su tratamiento.
- **`docs/CRUCE-DOBLE-PRUEBA-SPRINT1.md`** — los quince defectos de calidad
  confirmados por dos auditores independientes, con su prioridad y a qué tarea
  de cierre está asignado cada uno. **Si vas a corregir un defecto, búscalo
  aquí primero:** puede que ya esté diagnosticado, con su causa y su
  reproducción escritas.
- **`docs/CHECKLIST-DOBLE-PRUEBA-SPRINT1.md`** — el instrumento de 78
  comprobaciones. Útil como plantilla para verificar trabajo nuevo.
- **`README.md`** — arquitectura y puesta en marcha.

## El corpus de prueba no está en el repositorio

Los archivos BAPLIE reales están anonimizados y viven fuera del árbol:

```
C:\Users\Giova\OneDrive\Documentos\OneDrive\Desktop\Archivos .EDI\Anonimizados\files\
```

`CORPUS_A01.edi` es el de referencia: **977 contenedores en 27 bahías**,
verificado por conteo directo de segmentos. El fixture de `test/` tiene 7
contenedores, todos en bodega y en niveles pares: **no sirve para validar nada
que dependa de cubierta, de paridad de niveles o de escala.**

Desde el 6 de octubre la carpeta trae también **el caso de una escala real**,
anonimizado por Yov: `CORPUS_A07.edi` (plano de llegada, 398 contenedores),
`CORPUS_A08.edi` y `CORPUS_A08v_VGM.edi` (plan de carga, 460 posiciones con 55
celdas reservadas), `LISTADO_A08.xlsx` (el listado de la agencia) y la operación
completa en `CASO_A08_EVENTOS.json` y `CASO_A08_ESTADO_FINAL.csv`. Qué es cada uno
y cómo se usa: `SPRINT-3.md`, 2.4, y `docs/S3-CASO-MAGELLAN-STAR.md`. **Nada de esa
carpeta se copia al repositorio**, que es público.

## Estado al abrir el Sprint 3 (6 de octubre)

El Sprint 2 cerró con **26 de 26 tareas**: perfil de buque persistente, almacén
local propio, validación de estiba con tres estados, calidad, seguridad y
despliegue. **282 pruebas** en verde y `flutter analyze` en **cero**, sin ningún
`// ignore:`: esa es la línea base, no introduzcas ninguna incidencia. La Web está
publicada y Android está en la prueba interna de Google Play.

La primera prueba de campo con una escala real encontró **cuatro defectos** que
abren el Sprint 3 (T-66 … T-69): pesos que solo vienen como VGM, peso por pila que
calla cuando falta un peso, la escala mal propuesta en planos de llegada y las
celdas reservadas que el lector descarta. Tres se podían ver con el corpus y nadie
los buscó, porque la aceptación revisaba las reglas y no lo que el planificador lee
en pantalla. **Mira la pantalla.**

Los defectos de fondo del Sprint 1 (lleno/vacío, refrigerados, el ANR que era del
emulador) están cerrados; su historia está en `docs/HALLAZGOS-PLANO-REAL.md`.

## Sobre umbrales y datos que el archivo no trae

El formato BAPLIE no transmite la geometría del buque, y el proyecto arrancó
con dos constantes inventadas para suplirla. **Las dos ya no existen:**

- `kStackWeightLimitKg` (90 000 kg) se retiró en C‑7 (`71ad205`). El límite de
  apilamiento es `VesselGeometry.stackWeightLimitKg`, un `double?` que el
  usuario declara desde el manual de estabilidad; `null` significa que no lo
  tiene, y entonces no hay alerta de peso — antes que inventar un umbral.
- `maxRows` y `maxTiers` de `Bay` (12 y 10) se retiraron en T‑51 (19 de
  septiembre). Desde C‑3 la ocupación se calcula contra
  `geometry.slotsPerBay`, la geometría declarada, y sin geometría devuelve
  `null`, no un número de respaldo. Los documentos de Firestore escritos antes
  traen todavía esos dos campos; `Bay.fromJson` los ignora a propósito.

Lo que sigue siendo un **supuesto declarado** son las anclas de nivel de
`VesselGeometry` —bodega en 02, cubierta en 82, frontera de zona en 80—, que
salen de la numeración ISO y del corpus, no del buque concreto. T‑27 las
mueve al perfil. Si tocas algo que dependa de ellas, **mantén el comentario
que explica de dónde sale cada número.** Es un compromiso con el tribunal, no
un `TODO`.
