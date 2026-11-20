# Caso real A09: un plan de carga con «NO» en lugar de matrícula y un listado con POT

Yov · 19-nov-2026 · Material entregado por Carlos durante la cuarta prueba piloto (18-nov). Los archivos originales traen el buque, el viaje, las matrículas, las líneas y las agencias reales: **no entran al repositorio**. Este documento usa solo posiciones, códigos y conteos. Las líneas se nombran `LNH`, `LNJ` y `LNK` en el plan, y `LGH` y `LNJ` en el listado.

Es el caso con el que se reproducen los hallazgos de la decisión 10.151 de `SPRINT-4.md` y con el que se acepta T-147.

## 1. Los dos archivos

| Archivo | Qué es | Tamaño | SHA-256 |
|---|---|---:|---|
| `CORPUS_A09.edi` | Plan de carga, BAPLIE 2.0 con cabecera SMDG20, 709 posiciones | 123 619 bytes | `450219fe01c62e0c33e946c9d73c17f5765917376c74ccce3636200e76e0f07e` |
| `LISTADO_A09.xlsx` | Listado de exportación, dos hojas («OPS» y «CUADRE») | 64 524 bytes | `df40cd6fa1d58794016acbc2b9cfe8c0b7127012124e434c57cc18ba369daad0` |

Viven en la carpeta del corpus, fuera del repositorio:

```
C:\Users\Giova\OneDrive\Documentos\OneDrive\Desktop\Archivos .EDI\Anonimizados\files\
```

**Cómo se anonimizaron.**
- **El plan** conserva todos sus segmentos, su orden y sus saltos de línea. Cambian el emisor y el receptor, las referencias de `UNH`, `BGM`, `UNT` y `UNZ`, la fecha, el buque («BUQUE HOTEL»), el viaje («VIAJE009A»), la señal de llamada, las 438 matrículas, las tres líneas y 36 descripciones de mercancía (`FTX+AAA`), que pasan a «GENERAL CARGO». No cambian las posiciones, los pesos, los puertos, los tipos ISO, las temperaturas ni las mercancías peligrosas. **Los 271 «NO» quedan como vinieron.**
- **El listado** es el libro original, con sus cadenas compartidas, sus estilos, sus fórmulas y sus celdas combinadas. Cambian las 448 matrículas (con la misma correspondencia que en el plan), el título con el buque y el viaje, la fecha de la E.T.A., el nombre y el código de las dos agencias, y las dos líneas. Se conserva que una agencia dice «COD.» y la otra «CODIGO», con sus espacios. Se quitaron las imágenes, los ajustes de impresora, la ruta donde se guardó el libro y el autor.
- Las matrículas nuevas tienen el dígito de control correcto, como las originales.
- Yov comprobó que el par anonimizado da las mismas cuentas que el real, fila por fila y posición por posición, y que ninguna matrícula, nombre ni código real queda en ninguna parte de los dos archivos.

## 2. El plan

- **709 posiciones en 24 bahías:** 376 en cubierta y 333 en bodega. Hay 9 en el nivel 80.
- Por puerto de carga: GTSTC 408, HNPCR 190 y USHOU 111.
- **En la escala, GTSTC, se cargan 408: 135 llenos y 273 vacíos.**
- De los 273 vacíos, **271 traen «NO» como matrícula** (`EQD+CN+NO+<ISO>+++4`) y 2 traen su número. Ningún grupo trae el número en blanco.
- Descarga de lo que se carga en la escala: COTRB 213, JMKIN 123, COCTG 66 y COBAQ 6.
- Líneas de lo que se carga en la escala: `LNH` 359 y `LNJ` 49.
- Cada grupo viene en este orden: `LOC+147`, `MEA+VGM`, `LOC+9`, `LOC+11`, `LOC+83` y `LOC+76` (no siempre), `RFF+BM`, `EQD`, `NAD+CA` y, después, `FTX`, `TMP`, `RNG` y `DGS` cuando los hay. Trae 55 `TMP` y 15 `DGS` en 14 grupos.
- Los 271 «NO» traen un peso nominal por tipo, de 2 100 a 4 700 kg. 188 están en cubierta y 83 en bodega.

**Por bahía:**

| Bahía | Contenedores con matrícula | De paso | Llenos que se cargan | Vacíos con matrícula | Con «NO» |
|---|---:|---:|---:|---:|---:|
| 01 | 4 | 4 | 0 | 0 | 3 |
| 02 | 10 | 3 | 7 | 0 | 4 |
| 03 | 12 | 12 | 0 | 0 | 4 |
| 05 | 2 | 1 | 1 | 0 | 1 |
| 06 | 51 | 41 | 10 | 0 | 3 |
| 07 | 11 | 9 | 2 | 0 | 0 |
| 10 | 32 | 0 | 32 | 0 | 23 |
| 11 | 2 | 0 | 2 | 0 | 0 |
| 13 | 21 | 12 | 9 | 0 | 0 |
| 14 | 39 | 27 | 12 | 0 | 6 |
| 15 | 21 | 11 | 9 | 1 | 0 |
| 17 | 3 | 0 | 3 | 0 | 9 |
| 18 | 9 | 0 | 9 | 0 | 73 |
| 19 | 5 | 0 | 4 | 1 | 7 |
| 21 | 18 | 18 | 0 | 0 | 0 |
| 22 | 30 | 27 | 3 | 0 | 43 |
| 23 | 18 | 18 | 0 | 0 | 0 |
| 25 | 11 | 11 | 0 | 0 | 0 |
| 26 | 47 | 37 | 10 | 0 | 23 |
| 27 | 11 | 11 | 0 | 0 | 0 |
| 29 | 1 | 0 | 1 | 0 | 0 |
| 30 | 20 | 0 | 20 | 0 | 57 |
| 34 | 42 | 42 | 0 | 0 | 3 |
| 38 | 18 | 17 | 1 | 0 | 12 |
| **Total** | **438** | **301** | **135** | **2** | **271** |

## 3. El listado

**La hoja «OPS».**
- Título en las filas 1 a 3 y encabezado en la fila 4: `OR`, `CONTENEDOR`, `TIPO`, `POT`, `POD`, `TARA`, `PESO NETO`, `PESO VGM`, `REEFER TEMP`, `ORIG`, `F`, `E`, `CONTENIDO`, `HORA`, `MARCHAMO` y `OPR`. «CONTENIDO» lleva un espacio al final.
- **448 filas,** con el OR del 1 al 448, entre las filas 6 y 459: **172 llenos y 276 vacíos.**
- Líneas: `LGH` 395 (153 llenos y 242 vacíos) y `LNJ` 53 (19 y 34).
- `PESO NETO` trae un valor en 153 filas y una fórmula (`=H343-F343`) en 19. `HORA` viene vacía.
- `CONTENIDO` trae cinco textos: «VACIO EN PATIO» (268), «GENERAL CARGO» (163), «DANGEROUS CARGO … IMO 3 UN 1170» (8), «VACIO (LIMPIO)» (8) y «REEFER CARGO» (1).

**Las siete filas sin OR:**

| Fila | Texto | Filas que le siguen | Llenos | Vacíos | OR |
|---:|---|---:|---:|---:|---|
| 5 | «AGENCIA 1 S.A. … COD. 00-000-001» | 141 | 141 | 0 | 1 a 141 |
| 147 | «TRANSBORDOS» | 6 | 6 | 0 | 142 a 147 |
| 154 | «VACIOS» | 187 | 0 | 187 | 148 a 334 |
| 342 | «AGENCIA 2 S.A. … CODIGO 00-000-002» | 53 | 19 | 34 | 335 a 387 |
| 396 | «AGREGADOS» | 58 | 3 | 55 | 388 a 445 |
| 455 | «AGREGADOS» | 1 | 1 | 0 | 446 |
| 457 | «AGREGADOS» | 2 | 2 | 0 | 447 y 448 |

**POT y POD.** El listado trae las dos columnas, llenas en las 448 filas.
- `POT` trae cuatro códigos, los mismos cuatro puertos a los que carga el plan: COTRB 231, JMKIN 123, COCTG 88 y COBAQ 6.
- `POD` trae 36 códigos: es el destino final.
- Son distintos en 202 filas.
- **De los 137 contenedores que están en el plan con su matrícula, el POT coincide con la descarga del plan en los 137; el POD, en 28.**

| POD del listado | Filas | Llenos | Vacíos | POT de esas filas | Descarga en el plan de los que cruzan |
|---|---:|---:|---:|---|---|
| COTRB | 161 | 0 | 161 | COTRB 161 | — |
| JMKIN | 58 | 3 | 55 | JMKIN 58 | JMKIN 5 |
| CNTAO | 52 | 0 | 52 | JMKIN 52 | — |
| INMUN | 33 | 33 | 0 | COCTG 23, COTRB 10 | COCTG 5, COTRB 4 |
| COCTG | 21 | 21 | 0 | COCTG 21 | COCTG 17 |
| BRPNG | 8 | 0 | 8 | COCTG 8 | — |
| Los otros 30 | 115 | 115 | 0 | uno solo por código | el mismo que su POT |

**Los tipos.** La columna de la derecha reparte las 271 celdas con «NO» por su tipo ISO.

| Tipo en el listado | Filas | Llenos | Vacíos | ISO en el plan de los que cruzan | Celdas con «NO», por ISO |
|---|---:|---:|---:|---|---|
| 40HC | 156 | 98 | 58 | 45G1 60, 45G0 10 | 45G1 52, 45G0 3 |
| 40ST | 64 | 1 | 63 | 42G1 1 | 42G1 62, 42G0 1 |
| 45HC | 64 | 0 | 64 | — | L5G1 61, L5G0 3 |
| 40RH | 62 | 19 | 43 | 45R1 14 | 45R1 43 |
| 20ST | 31 | 21 | 10 | 22G1 19, 22G0 1 | 22G1 10 |
| 20TK | 19 | 11 | 8 | 22K2 5, 22T1 3, 22T0 2, 22T6 1 | 22K2 4, 22T4 2, 22T0 1, 22T1 1 |
| 40RC | 13 | 13 | 0 | 45R5 13 | — |
| 40RA | 9 | 9 | 0 | 45R4 6 | — |
| 40RF | 9 | 0 | 9 | — | 42R1 6, 42R0 3 |
| 40OT | 8 | 0 | 8 | — | 42U1 8 |
| 20OT | 6 | 0 | 6 | — | 22U1 5, 22U0 1 |
| 40FF | 3 | 0 | 3 | — | 42P3 3 |
| 40HF | 2 | 0 | 2 | — | 45P3 1, 45P4 1 |
| 20FF | 1 | 0 | 1 | 22P3 1 | — |
| 20RF | 1 | 0 | 1 | 22R1 1 | — |

**Las filas canceladas.** La columna `MARCHAMO` no trae marchamos: trae 40 notas, y esas filas llevan además un relleno de color.

| Nota en `MARCHAMO` | Filas | Llenos | Vacíos | OR |
|---|---:|---:|---:|---|
| «ROLEADO - CANCEL» | 24 | 24 | 0 | 22, 23, 24, 26, 27, 29, 30, 31, 32, 34, 37, 44, 46, 47, 48, 49, 51, 53, 67, 69, 71, 79, 83 y 88 |
| «YA EMBARCADO -CANCEL» | 7 | 7 | 0 | 64, 96, 98, 101, 115, 127 y 128 |
| «CANCELADO» | 7 | 4 | 3 | 156, 168, 182, 339, 348, 349 y 352 |
| «REEMPLAZO - CANCEL» | 2 | 2 | 0 | 120 y 126 |

- **Ninguno de los 37 llenos con nota está en el plan,** y todos los llenos que no están en el plan llevan nota.
- **Los 3 vacíos con nota son 40HC a COTRB,** el único grupo donde el listado trae más vacíos que celdas tiene el plan.
- Sin las 40 filas, el listado trae 135 llenos y 273 vacíos: lo mismo que carga el plan.

**La hoja «CUADRE»** repite 135 filas, los llenos que están en el plan, ordenados por matrícula. La app leyó «OPS».

## 4. Lo que hace la 1.0.1 con el caso

Es lo que pasó en el piloto. Las cifras de 4.2 a 4.4 son las que Carlos vio en la pantalla, y coinciden con el cálculo de Yov.

**4.1 · El plan, como vino.** 709 contenedores y ninguna celda reservada: 271 se llaman «NO». En la operación de la escala, los 271 quedan en una sola pieza (`C:NO`).

**4.2 · El plan, con el número en blanco en esas 271 líneas** (el rodeo del piloto).
- «438 contenedores · 271 celdas reservadas».
- En Carga: «408 pendientes: 135 llenos, 273 vacíos».
- Bahía 01: «4 contenedores · 3 celdas reservadas · 116.0 t».

**4.3 · El listado, al importarlo.**
- «448 filas en 3 agencias · 172 llenos · 276 vacíos» y «3 filas sin entender»: la 5, la 147 y la 154.
- **Trece equivalencias pendientes,** y «Confirmar e importar» apagado:

| Tipo o puerto | Filas | Lo que ofrece la pantalla |
|---|---:|---|
| Tipo 20ST | 31 | 22G1 (19), 22G0 (1) |
| Tipo 20TK | 19 | 22K2 (5), 22T1 (3), 22T0 (2), 22T6 (1) |
| Tipo 40HC | 156 | 45G1 (60), 45G0 (10) |
| Tipos 45HC, 20OT, 40FF, 40HF, 40OT y 40RF | 64, 6, 3, 2, 8 y 9 | los veinte códigos que el plan carga y nadie más explica |
| Puerto INMUN | 33 | COCTG (5), COTRB (4) |
| Puertos COTRB, CNTAO y BRPNG | 161, 52 y 8 | solo «Otro código…» |

- Deducidas sin preguntar: 40ST → 42G1, 40RA → 45R4, 40RC → 45R5, 40RH → 45R1, 20FF → 22P3, 20RF → 22R1, la línea `LGH` → `LNH` y 29 puertos de destino final hacia su puerto de trasbordo.

**4.4 · El cruce, con las trece elegidas** (20ST → 22G1, 20TK → 22K2, 40HC → 45G1, 45HC → L5G1, 20OT → 22U1, 40FF → 42P3, 40HF → 45P3, 40OT → 42U1, 40RF → 42R1; INMUN → COCTG, COTRB → COTRB, CNTAO → JMKIN y BRPNG → COCTG).
- 135 de 172 llenos cruzan con el plan.
- 0 contenedores del plan no están en el listado.
- 276 de 276 vacíos en 23 grupos de reservas.
- Llenos del listado que no están en el plan: 37.
- Llenos con datos distintos: 20 (17 por el tipo y 4 por el puerto; uno, por los dos).
- 94 llenos con VGM distinto del plan: el plan suma 4.6 t menos, porque trae cada peso truncado a la centena.

| Grupo (ISO · descarga · línea) | Vacíos del listado | Celdas |
|---|---:|---:|
| 42G1 · COTRB · LNH | 63 | 62 |
| L5G1 · COTRB · LNH | 64 | 61 |
| 45R1 · JMKIN · LNH | 43 | 43 |
| 45G1 · COTRB · LNH | 34 | 28 |
| 45G1 · JMKIN · LNJ | 24 | 24 |
| 22G1 · JMKIN · LNJ | 10 | 10 |
| 42U1 · JMKIN · LNH | 8 | 8 |
| 42R1 · JMKIN · LNH | 9 | 6 |
| 22U1 · JMKIN · LNH | 6 | 5 |
| 22K2 · COCTG · LNH | 8 | 4 |
| 42P3 · JMKIN · LNH | 3 | 3 |
| 42R0 · JMKIN · LNH | 0 | 3 |
| 45G0 · COTRB · LNH | 0 | 3 |
| L5G0 · COTRB · LNH | 0 | 3 |
| 22T4 · COCTG · LNH | 0 | 2 |
| 22P3 · JMKIN · LNH | 1 | 1 (ya con número en el plan) |
| 22R1 · JMKIN · LNH | 1 | 1 (ya con número en el plan) |
| 22T0 · COCTG · LNH | 0 | 1 |
| 22T1 · COCTG · LNH | 0 | 1 |
| 22U0 · JMKIN · LNH | 0 | 1 |
| 42G0 · COTRB · LNH | 0 | 1 |
| 45P3 · JMKIN · LNH | 2 | 1 |
| 45P4 · JMKIN · LNH | 0 | 1 |
| **Total** | **276** | **273** |

Cuadran 7 de los 23 grupos. Hay 16 celdas con otro código ISO del mismo tipo (42R0, 45G0, L5G0, 22T4, 22T0, 22T1, 22U0, 42G0 y 45P4), que piden motivo al cargar.

**4.5 · En el muelle.** Al tocar una celda reservada, la hoja «Vacíos del listado» tarda unos 6 segundos en un iPhone y después sigue trabada. Es el hallazgo H1 de la 10.151: 276 vacíos por 271 celdas.

## 5. Lo que debe dar con T-147

Calculado por Yov con un programa que imita las reglas de la 10.151 sobre los dos archivos. **Si el código da otra cifra, quien la encuentre se detiene y lo dice:** puede estar mal el cálculo.

**5.1 · Entrega 1: «NO» como celda reservada, el cruce por POT y los separadores.**
- El plan, como vino: 438 contenedores y 271 celdas reservadas, con un solo aviso que dice cuántas traían «NO». En Carga, 408 pendientes: 135 llenos y 273 vacíos.
- El listado: 448 filas, ninguna «sin entender». Las siete filas sin OR se reconocen.
- **Ningún puerto pendiente.** Los cuatro salen por identidad, con respaldo: COTRB, JMKIN, COCTG y COBAQ.
- Siguen pendientes los nueve tipos de 4.3.
- Con los nueve tipos de 4.4, el cruce da lo mismo que en 4.4, salvo «Llenos con datos distintos», que baja a 17, todos por el tipo.
- La hoja «Vacíos del listado» abre sin trabarse desde cualquier celda reservada.

**5.2 · Entrega 2, si Carlos aprueba la regla de las filas canceladas.**
- 408 filas para cargar, 135 llenos y 273 vacíos, y 40 canceladas en el listado, 37 llenos y 3 vacíos.
- 135 de 135 llenos cruzan con el plan, y ningún lleno del listado queda fuera del plan.
- 273 vacíos para 273 celdas. El grupo 45G1 · COTRB · LNH baja de 34 a 31 vacíos, para 28 celdas.
- Los tipos pasan a 20ST 30, 40HC 125, 40RA 6 y 40RH 57 filas.
