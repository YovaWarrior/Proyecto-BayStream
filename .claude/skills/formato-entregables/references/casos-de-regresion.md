# Casos de regresion del formato UMG

Cada fila es un defecto **real** que se produjo al construir
`BayStream_Incremento1_Seguridad_Calidad.docx` entre el 25 y el 27 de agosto de
2026, con su causa, la regla que lo previene y la comprobacion que lo detecta.

`scripts/verificar_formato.py` implementa las comprobaciones automaticas. Se
ejecuta asi:

```
python scripts/verificar_formato.py documento.docx --render
```

Devuelve codigo 1 si alguna comprobacion falla.

## Por que no basta con mirar el PDF

Dos de los nueve defectos **no son visibles en un render de LibreOffice**: se
manifiestan solo al abrir el archivo en Word. Son los casos 6 y 7. Si la unica
verificacion es visual sobre el PDF, esos dos pasan inadvertidos y llegan al
entregable. Por eso la comprobacion de numeracion es estatica, sobre el XML.

## Tabla de casos

| # | Defecto observado | Causa | Regla | Deteccion |
|---|---|---|---|---|
| 1 | Marcadores `[CURSO]` y `[CATEDRATICO]` sin reemplazar | La caratula de la plantilla es una **tabla 1x2**; el reemplazo recorria solo parrafos de primer nivel, no celdas | Spec §3, nota de la caratula | `check_marcadores` · automatica |
| 2 | Todas las columnas de las tablas con el mismo ancho | Se fijo el ancho en las celdas pero **no en `tblGrid`** | Spec §7 | `check_tablas` · automatica |
| 3 | Tablas alineadas al margen y no al texto de su apartado | Falta `tblInd`; ademas `tblInd` se mide hasta el **contenido** de la celda, hay que sumar 108 twips | Spec §2 y §7 | `check_tablas` · automatica |
| 4 | Palabras partidas a mitad en encabezados de tabla (`Mobil/e`, `Confirmació/n`) | Ancho de columna calculado sin considerar que el encabezado va en **negrita** (mas ancha) | Spec §7 | Visual · el render lo muestra |
| 5 | Codigos partidos al final de renglon (`Diferido a TC-/01`, `17-/ago`) | Guion ASCII normal: Word lo trata como punto de corte valido | Spec §7, guion U+2011 | `check_guiones` · automatica (aviso) |
| 6 | **Las vinetas salian como `III.`, `IV.`, `V.` y consumian numeros de los titulos** | Se reuso el `numId` de vinetas de la plantilla, cuyo nivel lleva `<w:pStyle w:val="ListBullet"/>`. Word remapea ese nivel a la lista multinivel de los titulos | Spec §6.1 | `check_colision_numeracion` · **automatica; invisible en LibreOffice** |
| 7 | **`I. Contenido` se quedaba con el primer numeral y desplazaba todo** | Word inserta su encabezado del indice con el estilo `TOCHeading`, que esta `basedOn="Heading1"` y hereda su numeracion | Spec §4 | `check_tocheading` · **automatica; solo visible tras generar el indice en Word** |
| 8 | La `Tabla 59` aparecia antes que la `58` | Se inserto una tabla nueva en una seccion anterior sin renumerar las posteriores | Spec §7, orden de aparicion | `check_rotulos` · automatica |
| 9 | Bloque centrado de la caratula desalineado respecto de su propio eje | Los parrafos centrados heredaban la **sangria de primera linea** de `Normal` | Spec §3 | Visual · el render lo muestra |

## Defectos de contenido, no de formato

Estos no los detecta el script; requieren lectura critica. Se registran porque
son el tipo de error mas caro: el documento se ve impecable y afirma algo falso.

| Defecto | Como se detecto |
|---|---|
| Conclusiones redactadas **sin tildes**, por inercia de la convencion de mensajes de commit (que si van sin acentos) | Revision de ortografia sobre el texto extraido |
| El reporte declaraba «no se verifico el estado real de las reglas en la consola» cuando ya se habian leido, publicado y probado | Revision independiente de un tercero |
| Recomendaba «purgar documentos pendientes» cuando ya se habia comprobado que no quedaba ninguno | Revision independiente de un tercero |

**Leccion.** Cuando una afirmacion del documento describe el *estado del mundo*
—y no el contenido del propio documento— caduca en cuanto ese estado cambia.
Al corregir un hallazgo hay que buscar **todas** sus menciones, incluidas las
tablas y las notas al pie, no solo el parrafo principal.

## Escenarios que conviene probar antes de dar por buena la skill

- [x] Caratula con logotipo y datos variables
- [x] Indice reservado y generado despues en Word
- [x] Encabezados multinivel `I. / A. / 1.`
- [x] Parrafos largos justificados con sangria
- [x] Tablas anchas, tablas que cruzan pagina, tablas con celdas cortas
- [x] Referencias APA 7 con sangria francesa
- [x] Listas con vinetas dentro de un apartado
- [ ] **Imagenes o figuras dentro del cuerpo** — no probado; el reporte del
      incremento no lleva figuras. La spec §7 las cubre en teoria, pero ningun
      documento real ha ejercitado esa ruta.
- [ ] **Modificacion de un DOCX existente** (no generado desde la plantilla) —
      no probado.
- [ ] **Citas textuales en bloque de 40+ palabras** — no probado.

Las tres casillas vacias son el alcance pendiente de la siguiente ronda.
