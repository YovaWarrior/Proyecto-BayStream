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

Codex y tú hacen el mismo trabajo y siguen las mismas reglas. Se alternan; no
trabajan a la vez.

## Protocolo de relevo entre los dos programadores

Como se alternan, el árbol de trabajo puede traer cambios que tú no hiciste.

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

## Estado al cerrar el Sprint 1

*(Actualizado el 4 de septiembre — Timonel avisó que esta sección se había
quedado atrás y mandaba a buscar dos bugs que ya no existen. Antes de este
párrafo, decía «tres defectos abiertos» con el indicador lleno/vacío y los
refrigerados incluidos; los dos ya están cerrados.)*

Las cinco funcionalidades del sprint están entregadas y verificadas. Compila en
Windows, Android y Web, y las 135 pruebas pasan. `flutter analyze` reporta 49
incidencias: 4 advertencias y 45 avisos informativos. Ese número es la línea
base; **no lo subas.**

Detalle completo de todo lo cerrado —incluido lo de esta sección— en
`docs/HALLAZGOS-PLANO-REAL.md`; esto es solo el resumen para orientarse rápido.

1. **El indicador lleno/vacío se leía mal — ✓ cerrado (`09599c8`).** Se leía
   por valor desde el índice 4 en vez de por posición fija en el 6. Llegó a
   perder 269 de 315 contenedores llenos en `CORPUS_A03`. Corregido y
   verificado contra los seis archivos primarios.
2. **Los refrigerados no se detectaban — ✓ cerrado (`c101fb5`/`206545c`).**
   `TMP` se descartaba en silencio cuando llegaba antes que su `EQD` —pasaba
   en el 100 % de los casos del corpus—, y el tipo ISO con `R` nunca marcaba
   `isReefer`. Corregido y verificado: 327 refrigerados, 238 con temperatura,
   exacto contra el corpus.
3. **Detención en Android — ✓ cerrado (T‑50, 19 de septiembre), sin cambio
   de código.** Verificado en el **POCO X3 NFC real** (Android 12, MIUI 14)
   con `CORPUS_A01` completo, bahía 038 y cambios rápidos de bahía, `logcat`
   en vivo: **sin ANR** en `713da5a` debug —el commit y el modo exactos de la
   auditoría—, en `713da5a` release ni en `a3dbc99` release. El ANR se vio
   una sola vez: emulador Pixel 8 Pro API 36.1, APK debug, por Codex, que
   dejó anotado que en el POCO solo confirmó el arranque porque MIUI bloquea
   la inyección de eventos; nadie había abierto el plano en un dispositivo
   real hasta el 19 de septiembre. **La «confirmación» del 4 de septiembre
   no existió**: fue una frase de Timonel —«el de Android sigue vivo»— en
   una lista de qué seguía abierto, sin reproducción detrás; se leyó como
   evidencia. La matriz completa está en `docs/HALLAZGOS-PLANO-REAL.md`,
   sección 4 y corrección 7 del registro.

Ninguno de los tres se corrigió antes de la revisión del 29 de agosto, por
decisión deliberada: la doble prueba se ejecutó sobre el commit `713da5a` y
tocarlos habría invalidado esa evidencia. Los tres se tomaron después: los
dos primeros en las tareas de cierre de septiembre y el de Android en T‑50
del Sprint 2, donde resultó no ser un defecto del producto sino del emulador.

## Sobre umbrales y datos que el archivo no trae

Dos constantes del código son **supuestos provisionales declarados**, no datos
medidos, porque el formato BAPLIE no transmite la geometría del buque:

- `kStackWeightLimitKg` (90 000 kg) — el límite real depende del buque y de la
  terminal, y vive en el manual de estabilidad.
- `maxRows` y `maxTiers` de `Bay` (12 y 10) — el parser nunca los asigna, así
  que toda la ocupación se calcula contra 120 huecos ficticios.

Si tocas algo que dependa de ellos, **mantén el comentario que los declara
provisionales.** Es un compromiso con el tribunal, no un `TODO`.
