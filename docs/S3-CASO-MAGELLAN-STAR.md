# Caso real MAGELLAN STAR, viaje 26039S: la carga completa como prueba de aceptación del Sprint 3

Yov · 6-oct-2026, con las respuestas de Carlos de la noche del 6-oct · Material entregado por Carlos el 5 y el 6-oct. Los archivos originales traen números de contenedor, líneas y agencias reales: **no entran al repositorio**. Este documento usa solo números de orden del listado, posiciones y conteos. Las líneas se nombran A, B, C y D.

## 1. Las cuatro fuentes

| Fuente | Formato | Contenido |
|---|---|---|
| Plano de llegada | BAPLIE 2.0, cabecera SMDG22 | 398 contenedores |
| Plan de carga (pre-estiba) | BAPLIE 2.0, cabecera SMDG20, en dos variantes: peso como `WT` o como `VGM` | 460 posiciones: 176 cargas en GTSTC y 284 que siguen a bordo |
| Listado de exportación | Excel, una hoja, agrupado por agencia | 176 filas, número de orden (OR) 1 a 176 |
| Plano final anotado a mano | 9 fotos del plano impreso | 9 bahías, 176 movimientos, operación del 4 al 5-oct |

## 2. Todo cuadra

Movimientos anotados a mano en cada bahía contra cargas en GTSTC del plan:

| Bahía | Cubierta | Bodega | Total | Llenos | Vacíos |
|---|---:|---:|---:|---:|---:|
| 03 | 5 | 0 | 5 | 1 | 4 |
| 05/06 | 26 | 26 | 52 | 30 | 22 |
| 07 | 0 | 11 | 11 | 6 | 5 |
| 13/14 | 14 | 18 | 32 | 32 | 0 |
| 15 | 0 | 4 | 4 | 4 | 0 |
| 22 | 6 | 16 | 22 | 22 | 0 |
| 25/26 | 13 | 17 | 30 | 7 | 23 |
| 27 | 0 | 2 | 2 | 0 | 2 |
| 29/30 | 18 | 0 | 18 | 18 | 0 |
| **Total** | **82** | **94** | **176** | **120** | **56** |

Las nueve bahías coinciden con el plan en cubierta, en bodega y en total.

- **Llenos:** los 120 del listado están en el plan con su número, y el plan no trae ningún lleno que no esté en el listado.
- **Vacíos:** los 56 del listado corresponden a 56 celdas reservadas del plan. 55 vienen sin número de contenedor (`EQD+CN++22G1+++4`) y una ya trae el número asignado (OR 85).

## 3. Cómo se registra hoy en papel

Esto es lo que la app reemplaza:

- **Lleno cargado.** Se encierra en un círculo su número de orden, en el listado y sobre su celda del plano.
- **Vacío cargado.** Se escribe su número de orden en la celda reservada donde quedó. Cada grupo se marca con un color de resaltador y una leyenda, por ejemplo «17×40'HC VACÍOS» y la línea.
- **Conteos.** Al margen de cada sección se anota cuántos movimientos tiene (cubierta y bodega), y al pie de la bahía el total («30 MOVS»).
- **Lo que no se usa.** Las secciones sin movimiento se tachan con una X grande. Las X pequeñas en celdas sueltas (bahía 29/30) marcan contenedores de paso que no se tocan (Carlos, 6-oct). El plano impreso solo muestra lo que se carga en el puerto (viene filtrado por puerto de carga), así que el tarjador tacha a mano las celdas que ocupa la carga de paso. En la app esas celdas salen ocupadas desde el BAPLIE, marcadas como «a bordo», y el tarjador no tiene que tacharlas.
- **Correcciones.** Se hacen con corrector líquido y se reescribe encima.

## 4. Vacíos: una regla que la app puede aplicar sola

Cada celda reservada pertenece a un grupo: tipo, puerto de descarga y línea. Los grupos del listado y los del plan son idénticos:

| Tipo en el listado | ISO en el plan | Descarga | Línea | Vacíos | Celdas reservadas |
|---|---|---|---|---:|---:|
| 20ST | 22G1 | JMKWL | A | 9 | 9 |
| 40HC | 45G1 | JMKWL | A | 20 | 20 |
| 20ST | 22G1 | PAMIT | C | 7 | 7 |
| 40HC | 45G1 | PAMIT | C | 17 | 17 |
| 40RF | 45R1 | PAMIT | C | 2 | 2 |
| 40ST | 42G1 | PAMIT | C | 1 | 1 |

**Lo que muestra el plano final.**
- Los 56 vacíos quedaron cada uno en una celda de su grupo, sin excepción.
- Dentro de un grupo, el orden en que se llenan las celdas no sigue el número de orden: los vacíos se colocan en el orden en que llegan del patio.

**Lo que la app debe hacer.** Cuando el tarjador escribe o dicta el número de un vacío, la app:
1. lo busca en el listado y deduce su grupo;
2. le ofrece las celdas libres de ese grupo en la bahía en operación;
3. registra el número de contenedor y su tara real.

Si el tarjador elige una celda de otro grupo, es un error que la validación preventiva debe atajar.

Asignación observada (número de orden → celda, en formato bahía-fila-nivel):

| Tipo | Descarga | Línea | n | Asignación |
|---|---|---|---:|---|
| 20ST | JMKWL | A | 9 | 12 → 003-09-84, 13 → 003-10-82, 14 → 025-08-04, 15 → 027-08-06, 16 → 027-06-04, 17 → 025-06-04, 18 → 003-09-82, 19 → 003-10-84, 20 → 025-08-06 |
| 40HC | JMKWL | A | 20 | 21 → 026-06-06, 22 → 026-10-82, 23 → 026-02-84, 24 → 026-04-84, 25 → 026-06-08, 26 → 026-04-08, 27 → 026-04-86, 28 → 026-08-82, 29 → 026-10-84, 30 → 026-04-82, 31 → 026-08-10, 32 → 026-08-84, 33 → 026-02-86, 34 → 026-06-86, 35 → 026-06-82, 36 → 026-02-08, 37 → 026-02-82, 38 → 026-06-84, 39 → 026-08-08, 40 → 026-06-10 |
| 20ST | PAMIT | C | 7 | 59 → 007-02-02, 60 → 005-02-02, 61 → 007-04-02, 62 → 007-06-04, 63 → 007-04-04, 64 → 007-08-08, 65 → 005-04-04 |
| 40HC | PAMIT | C | 17 | 66 → 006-02-84, 67 → 006-10-84, 68 → 006-02-86, 69 → 006-02-10, 70 → 006-06-08, 71 → 006-08-10, 72 → 006-04-82, 73 → 006-02-82, 74 → 006-10-82, 75 → 006-06-10, 76 → 006-06-82, 77 → 006-04-84, 78 → 006-06-84, 79 → 006-04-10, 80 → 006-08-84, 81 → 006-04-86, 82 → 006-08-82 |
| 40RF | PAMIT | C | 2 | 83 → 006-02-08, 84 → 006-04-08 |
| 40ST | PAMIT | C | 1 | 85 → 006-02-04 (ya venía asignado en el plan) |

La tabla se transcribió de las fotos. La comprobación por programa confirma tres cosas: las 56 celdas son distintas, son exactamente las 56 reservadas del plan y cada una corresponde al grupo de su vacío.

## 5. Dos eventos reales que el módulo de muelle debe soportar

**Intercambio de dos llenos (bahía 14, bodega).**

| | Número de orden 128 | Número de orden 145 |
|---|---|---|
| Plan | 014-01-02 | 014-01-08 |
| Dónde quedó | 014-01-08 | 014-01-02 |

- Los dos son 45G1, del mismo puerto de descarga y la misma línea, y pesan 30.3 t cada uno.
- **En papel:** corrector sobre la celda 014-01-08 y «128» reescrito; en 014-01-02 el número tachado y «145» anotado fuera de la celda.
- **En la app:** es un cambio de posición pedido desde el muelle y aprobado por la oficina. Queda en la bitácora, y el BAPLIE de salida debe llevar las dos posiciones intercambiadas.

**Corrección en 007-08-08.** Carlos había escrito mal el número de orden del vacío y lo corrigió a 64 con corrector (6-oct). En la app es corregir una asignación: se cancela la primera y se registra la buena, con los dos pasos en la bitácora.

## 6. Diferencias entre el listado y el plan

**Códigos.**
- **Tipos:** 40HC → 45G1 (137), 20ST → 22G1 (36), 40RF → 45R1 (2) y 40ST → 42G1 (1).
- **Puertos:** el listado dice COMNG donde el plan dice COSPC, en 22 contenedores.
- **Líneas:** una línea usa en el listado un código de tres letras y en el plan uno de cuatro.

**Pesos de los llenos.**
- El plan trae el VGM del listado **truncado a la centena de kilos**. La regla se cumple en los 120 llenos.
- 47 de ellos difieren, hasta por 98 kg. En total el plan suma 2.4 t menos que el listado.
- La diferencia siempre va hacia abajo, que es el lado inseguro del cálculo de peso por pila.

**Pesos de los vacíos.**
- Las celdas reservadas traen una tara nominal: 2.1–2.2 t los de 20 pies, 3.7–3.8 t los de 40, 4.5–4.6 t los reefer.
- El listado trae la tara real de cada contenedor: en total, 186.7 t contra 185.5 t en el plan.

**Columnas del Excel.**
- PESO NETO es una fórmula (VGM − TARA). La importación debe leer el valor calculado o recalcularlo.
- HORA y MARCHAMO están vacías: hoy se llenan a mano en el listado impreso.
- REEFER TEMP está vacía: los dos reefer cargados van vacíos.
- Las filas de encabezado de cada agencia separan los grupos; no son contenedores.

**Peligrosas.**
- En el listado solo aparecen como texto libre en CONTENIDO: «DANGEROUS CARGO IMO 9 UN 3082, 3077».
- El plan trae un solo `DGS` para ese contenedor (UN 3077).
- La importación necesita leer clase y números ONU de ese texto, y la app puede avisar la diferencia.

## 7. Qué cambia en el Sprint 3

- **Defecto 4.** Las 55 celdas reservadas se cargan como reservas con su grupo (ISO, puerto y línea) y su peso nominal.
- **RF-038, importar el listado.**
  - Lectura del Excel: filas de agencia como separadores y el peso neto calculado.
  - Tabla de equivalencias editable para tipos, puertos y códigos de línea.
  - Lectura de clase y números ONU desde CONTENIDO.
- **RF-037, operación en muelle.**
  - Confirmar un lleno por número de orden, número de contenedor o voz.
  - Asignar un vacío solo a una celda libre de su grupo.
  - Intercambio y cambio de posición con permiso de la oficina.
  - Cancelar con bitácora.
  - Conteo por sección y por bahía como en el papel.
- **RF-039, BAPLIE de salida.**
  - Los 55 números completados, con la tara real.
  - El VGM exacto del listado, sin truncar.
  - El intercambio aplicado.
  - Las 284 posiciones que siguen a bordo, sin cambios.
- **RF-027+, segregación.** El caso real solo tiene clase 9 (una carga y una a bordo), así que no ejercita la tabla de segregación. Las pruebas de IMDG necesitan casos sintéticos.

## 8. Prueba de aceptación propuesta

Para usar el caso como prueba, primero hay que anonimizar las cuatro fuentes, con el mismo procedimiento del corpus A01–A06:
- números de contenedor ficticios con dígito de control válido, iguales en las cuatro fuentes;
- líneas y agencias reemplazadas por A–D.

Con el plan y el listado anonimizados, se reproducen los 176 eventos:
- 120 confirmaciones de llenos;
- 56 vacíos con la asignación de la sección 4;
- el intercambio de la sección 5.

El resultado esperado:

1. Los conteos por bahía y por sección de la tabla de la sección 2.
2. Ninguna violación de grupo.
3. Un BAPLIE de salida igual al esperado: 460 posiciones, 55 números completados, el intercambio aplicado y los pesos del listado.
4. Con sincronización, la oficina ve los 176 movimientos.

## 9. Código IMDG: la edición vigente (42-24)

**Qué se recibió.**
- El 6-oct llegó primero un extracto de los capítulos 7.2 y 7.4 en Word. Su pie dice «Enm. 36-12»: la edición de 2012. Ya no hace falta.
- Esa misma noche llegaron las páginas de la **Enmienda 42-24 (edición de 2024)**, obligatoria desde el 1-ene-2026: un PDF de 18 páginas, hecho de imágenes y sin texto. Contiene:
  - el capítulo 7.2 completo: tabla de segregación 7.2.4, códigos de grupo SGG (7.2.5.2), cuadros de exenciones (7.2.6.3), clase 1 (7.2.7), códigos de segregación SG1–SG78 (7.2.8) y el diagrama de decisión del anexo;
  - el capítulo 7.4: estiba (7.4.2) y las tablas de buques portacontenedores 7.4.3.2 (con bodegas cerradas por tapas) y 7.4.3.3 (sin tapas).
- RF-027+ se implementa directamente con la 42-24.

**Cómo se usa.**
- RF-027 pasa de 49 CFR §176.83 a una revisión por clase.
- El `DGS` del BAPLIE da la clase (y los peligros secundarios, si vienen). La tabla 7.2.4 da el nivel de segregación: 1 a 4, X o \*. La tabla 7.4.3.2 traduce el nivel a distancias en espacios de contenedor (6 m en longitudinal, 2.4 m en transversal), en vertical y en horizontal, en cubierta y bajo cubierta.
- Si el contenedor es cerrado o abierto se deduce del código ISO.
- **X** significa «consultar la Lista de Mercancías Peligrosas»: sin la Lista se declara «no evaluado».
- La clase 9 tiene X en toda su fila y su columna. Por eso el caso real, que solo trae clase 9, sale «no evaluado» y no «sin requisito».

**Qué falta.**
- Los niveles 3 y 4 piden mamparos (qué bahías forman cada bodega) y, para el 4, una distancia de 24 m. Los dos tienen que estar en el perfil del buque.
- Los códigos SG y SGG se asignan por número ONU en la columna 16b de la Lista. Las definiciones están en las páginas recibidas; la asignación por número ONU no. Quedan como «no evaluado».

**Transcripción.** Las páginas son imágenes. Yov transcribe las tablas 7.2.4 y 7.4.3.2 antes de pasarlas a los programadores, y la transcripción se verifica dos veces:
- la tabla 7.2.4 debe salir simétrica;
- un programador vuelve a leer la transcripción contra la página, como doble prueba.

**Licencia.** Las páginas son de la OMI y dicen «Contenido reservado exclusivamente para fines no comerciales», y el repositorio es público. El PDF se guarda en `C:\Proyectos\baystream-privado\` y nunca se versiona. El código lleva solo los valores de las tablas, con la referencia al capítulo.
