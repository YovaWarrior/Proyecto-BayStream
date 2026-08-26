# Especificacion de formato academico BayStream

Esta referencia destila la guia creada por Carlos. Su objetivo es reproducir el
resultado visual solicitado en Word, no copiar los defectos accidentales del
documento explicativo.

## 1. Orden de autoridad

1. Instruccion actual y explicita del usuario.
2. Plantilla o rubrica oficial de la tarea concreta.
3. Esta especificacion.
4. Guia Word original, para ejemplos no cubiertos aqui.

Cuando dos fuentes se contradigan, conserva la de mayor autoridad y documenta
la desviacion en la entrega.

## 2. Configuracion general

- Papel: carta, 21.59 x 27.94 cm, vertical, una sola cara.
- Margen izquierdo: 3.5 cm.
- Margen derecho: 2.5 cm.
- Margenes superior e inferior: 3 cm.
- Fuente base: Arial, 12 puntos, color negro, peso normal.
- Interlineado: 1.5 en **todo** el documento, incluida la caratula. La plantilla
  trae 1.15 en el bloque de la caratula: hay que corregirlo a 1.5.
- Alineacion del cuerpo: justificada, como muestran los ejemplos visuales.
- Separacion entre parrafos: 12 puntos posteriores; evita acumular parrafos
  vacios manuales.
- Primera linea: sangria configurada de 0.63 cm, equivalente visual a los cinco
  espacios de la guia. No insertes tabuladores o espacios literales.
- **Regla de parrafo subordinado (obligatoria).** El cuerpo se alinea a la
  izquierda con el INICIO DEL TEXTO del titulo que lo gobierna, no con el margen
  ni con el indicador romano, alfabetico o numerico. La sangria de primera linea
  de 0.63 cm se suma encima de esa alineacion. Valores exactos, iguales a los del
  listado multinivel de la seccion 5:

  | Bajo un titulo de nivel | Sangria izquierda del cuerpo |
  |---|---:|
  | 1 (`I.`) | 0.75 cm (425 twips) |
  | 2 (`A.`) | 1.50 cm (850 twips) |
  | 3 (`1.`) | 2.25 cm (1276 twips) |
  | 4 (`a.`) | 2.25 cm (1276 twips) |

  Aplica igual a parrafos, vinetas, rotulos de tabla, la linea `Fuente:` y las
  propias tablas. En las vinetas la sangria del nivel se suma a la francesa de la
  vineta; las lineas de continuacion se alinean con el texto, no con el simbolo.
- Numeracion: arabiga, esquina superior derecha, oculta en caratula e indice.
  Salvo instruccion distinta, el cuerpo inicia en la pagina 1.

## 3. Caratula

La caratula no lleva numero visible y mantiene una composicion limpia en una
sola pagina.

> La caratula de la plantilla es una **tabla de 1x2** (texto a la izquierda,
> logotipo a la derecha). Los marcadores viven dentro de celdas, asi que un
> reemplazo que solo recorra parrafos de primer nivel no los encuentra. Anula
> tambien la sangria de primera linea heredada de `Normal` en la caratula: si no,
> el bloque centrado queda desalineado respecto de su propio eje.

### Bloque superior

Alinea a la izquierda estas cinco lineas, sustituyendo solo los datos variables:

1. Universidad Mariano Galvez de Guatemala
2. Centro Universitario de Puerto Barrios
3. Facultad de Ingenieria en Sistemas
4. Nombre exacto del curso, por ejemplo, Proyecto de Graduacion II
5. Nombre y grado del catedratico

Coloca el logotipo oficial en la zona superior derecha, a 3 cm del borde
superior, con 3.2 x 3.2 cm, sin deformarlo y sin invadir el bloque de texto.

### Centro de la pagina

Situa el inicio de este bloque aproximadamente a 11.5 cm del borde superior.

- Primera linea: nombre o punto exacto de la tarea/entregable, centrado y con su
  punto final cuando forme parte del titulo oficial.
- Linea siguiente: descripcion breve o subtitulo, centrado y en cursiva. Puede
  ocupar dos lineas si es necesario, manteniendo el bloque centrado.

### Tres cuartos de pagina

Situa la linea aproximadamente a 20.5 cm del borde superior.

En una sola linea alineada a la derecha:

`Nombre completo del estudiante CARNET`

Para BayStream, usa los datos confirmados por el usuario; no los tomes de un
ejemplo si el encargo proporciona otros.

### Ultima linea

Situa la linea aproximadamente a 24.0 cm del borde superior, dentro del margen
inferior.

Centra el lugar y la fecha real de entrega:

`Puerto Barrios, Izabal [dia] de [mes] de [anio]`

Usa la fecha de entrega, no automaticamente la fecha de generacion.

## 4. Indice y estructura

- Reserva una pagina de `Indice` inmediatamente despues de la caratula.
- No muestres numero de pagina en el indice.
- Deja la pagina en blanco despues del titulo `Indice` para que Carlos inserte o
  actualice personalmente la tabla de contenido en Word. Solo insertala si el
  usuario lo pide expresamente; nunca escribas un indice manual.
- Usa estilos reales `Titulo 1` a `Titulo 4` o sus equivalentes para alimentar
  el indice.
- **El primer titulo numerado del documento es siempre `I. Introduccion`.** No
  lleva apartado `Resumen` ni ningun otro titulo numerado por delante. Si hace
  falta un resumen, va sin numerar y fuera de la jerarquia.
- **Quita la numeracion del estilo `TOCHeading` antes de entregar.** Al generar la
  tabla de contenido, Word inserta su propio encabezado (`Contenido`) con ese
  estilo; en la plantilla `TOCHeading` esta `basedOn="Heading1"`, de modo que
  **hereda su numeracion y se queda con el `I.`**, empujando `Introduccion` a
  `II.`. La correccion es anadir `<w:numPr><w:ilvl w:val="0"/><w:numId w:val="0"/>
  </w:numPr>` al `pPr` del estilo (`numId=0` significa «sin numeracion»), antes de
  `outlineLvl` para respetar el orden del esquema. El defecto **solo se ve despues
  de generar el indice en Word**, no en el DOCX recien construido.

## 5. Jerarquia de titulos

Los titulos van en negrita. En palabras de contenido usa inicial mayuscula; deja
en minuscula conectores como `de`, `del`, `y`, `a`, `en` y equivalentes, salvo
que inicien el titulo.

Configura una lista multinivel real:

| Nivel | Indicador | Posicion del indicador | Inicio del texto | Estilo |
|---|---|---:|---:|---|
| 1 | Romanos: I., II., III. | 0.00 cm | 0.75 cm | Titulo 1 |
| 2 | Mayusculas: A., B., C. | 0.75 cm | 1.50 cm | Titulo 2 |
| 3 | Arabigos: 1., 2., 3. | 1.50 cm | 2.25 cm | Titulo 3 |
| 4 | Minusculas: a., b., c. | 1.50 cm | 2.25 cm | Titulo 4 |

El cuarto nivel detiene el escalonamiento para evitar una escalera visual
infinita. Los indicadores no se escriben manualmente.

## 6. Parrafos

- Arial 12, interlineado 1.5 y texto justificado.
- Primera linea con sangria de 0.63 cm.
- **Separacion entre bloques.** Debe verse aproximadamente una linea en blanco
  entre un titulo y su primer parrafo, y entre parrafos consecutivos. Consiguelo
  con espaciado configurado, nunca con parrafos vacios ni `Enter` repetidos:
  espaciado posterior de unos 44 pt en los parrafos de cuerpo y de unos 38 pt en
  los titulos, con espaciado anterior 0 en el titulo (el parrafo previo ya aporta
  el suyo). Un parrafo vacio se desalinea en cuanto el texto refluye; el
  espaciado no.
- Evita espacios repetidos para justificar y `Enter` sucesivos para posicionar
  contenido; usa sangrias, espaciado y saltos de pagina configurados.
- Mantén cada titulo junto al primer parrafo que le sigue y evita lineas viudas
  o huerfanas cuando Word lo permita.

## 6.1. Listas dentro de una seccion

Una lista dentro de un apartado **es una lista, no un nivel mas de la jerarquia de
titulos**. Nunca debe salir con los indicadores romanos o alfabeticos de la
seccion 5. Usa vinetas; usa `1.`, `2.`, `3.` solo si el orden o el conteo importan.

> ⚠️ **Trampa verificada, no reutilizar la numeracion de la plantilla.** El nivel de
> vinetas que trae la plantilla lleva `<w:pStyle w:val="ListBullet"/>` dentro de su
> definicion. Si se aplica ese `numId` a un parrafo con otro estilo (por ejemplo
> `ListParagraph`), **Word remapea ese nivel a la lista multinivel de los titulos**:
> las vinetas aparecen como `III.`, `IV.`, `V.` y ademas **consumen numeros de la
> secuencia de titulos**, de modo que el primer titulo deja de ser `I.` y la
> numeracion salta (`Resumen` pasa a `II.`, `Metodo` a `VII.`). El indice generado
> en Word hereda el error.
>
> **LibreOffice no reproduce el fallo**: pinta las vinetas correctamente. Por eso
> revisar el PDF renderizado NO basta para detectarlo; hay que evitarlo por
> construccion.

Como hacerlo bien:

- Declara en `numbering.xml` un `abstractNum` **propio** para las vinetas, con
  `numFmt="bullet"`, fuente Symbol y **sin `pStyle` dentro del nivel**, y un
  `numId` exclusivo que no colisione con los de la plantilla.
- Aplica ese `numId` al parrafo junto con su sangria explicita (izquierda del nivel
  mas la francesa de la vineta). No uses el estilo `ListParagraph`: basta `Normal`
  con sangria e `numPr` propios.
- **Comprobacion objetiva:** en `document.xml` el unico `numId` referenciado debe
  ser el de la lista propia. Los `numId` de los titulos viven en `styles.xml` y no
  deben aparecer nunca en `document.xml`. Si aparecen, hay colision.
- Tras generar el indice en Word, confirma que el primer titulo de nivel 1 es `I.`
  y que la secuencia no salta numeros.

## 7. Tablas, figuras y diagramas

- Ningun elemento puede rebasar el area util delimitada por los margenes de
  3.5 cm y 2.5 cm. Ancho util maximo aproximado: 15.59 cm.
- **Alinea el borde izquierdo del elemento con el inicio del cuerpo del texto**
  de su seccion (regla de parrafo subordinado, seccion 2), no con el margen de
  3.5 cm. El ancho util disponible se reduce en esa misma sangria.
- Cuidado al fijar la sangria de tabla: Word y LibreOffice miden `tblInd` hasta el
  borde del CONTENIDO de la celda, no hasta la linea de la tabla. Hay que sumarle
  el margen interno de celda (108 twips) para que la linea quede realmente
  alineada con el texto del titulo. Verificalo midiendo sobre el render, no a ojo.
- Fija los anchos reales en `tblGrid`, no solo en las celdas: si solo se fijan las
  celdas, el documento se renderiza con todas las columnas iguales.
- **Ninguna palabra ni codigo debe partirse a mitad.** Dimensiona cada columna
  para que quepan en un renglon: la palabra mas larga del encabezado (que va en
  negrita y por tanto es mas ancha) y el contenido completo de las celdas cortas
  (`H-01`, `RF-026+`, `A05:2025`, `T-01 … T-04`). En columnas de prosa el ajuste
  de linea es normal y no hay que forzarlo.
- Sustituye el guion por un **guion de no separacion** (U+2011) dentro de codigos
  cortos como `TC-03`, `17-ago` o `RF-026+`, en tablas y en el cuerpo. Sin esto
  Word los parte al final del renglon (`Diferido a TC-` / `01`).
- Marca las filas como no divisibles entre paginas y repite la fila de encabezado
  cuando la tabla ocupe mas de una pagina.
- Usa numeracion consecutiva independiente por tipo, **en orden de aparicion en
  el documento**. Si se inserta un elemento nuevo en medio, hay que renumerar los
  posteriores: que la Tabla 59 aparezca antes que la 58 es un defecto.
- Antes del elemento, coloca el rotulo en negrita y terminado en punto:
  `Tabla 1.`, `Figura 1.` o `Diagrama 1.`
- En la linea siguiente coloca el titulo descriptivo en cursiva. Entre rotulo y
  descripcion usa interlineado doble, como pide la guia.
- Debajo coloca `Fuente:` en negrita y la procedencia en peso normal, por ejemplo
  `Fuente: Elaboracion propia.` o la cita/URL correspondiente.
- Mantén juntos el rotulo, la descripcion, el elemento y su fuente siempre que
  sea razonable. Repite encabezados si una tabla ocupa varias paginas.
- No deformes imagenes y no reduzcas el texto hasta hacerlo ilegible para que
  quepa.

## 8. Citas en el texto, APA 7

- Cita parentetica: autor y anio entre parentesis: `(Garcia, 2020)`.
- Tres o mas autores: `(Garcia et al., 2021)`.
- Cita narrativa: `Garcia (2020) afirma que...`.
- Cita textual menor de 40 palabras: dentro del parrafo, entre comillas, con
  autor, anio y pagina.
- Cita textual de 40 palabras o mas: bloque separado, sangria de 1.27 cm, sin
  comillas y con la referencia correspondiente.
- No inventes numero de pagina ni datos bibliograficos.

## 9. Referencias bibliograficas

- Comienzan en pagina nueva al final del trabajo.
- Orden alfabetico por apellido del autor o nombre de la entidad.
- Interlineado doble y sangria francesa.
- Libro: `Apellido, A. A. (Anio). Titulo del libro. Editorial.`
- Articulo: `Apellido, A. A. (Anio). Titulo del articulo. Nombre de la revista,
  volumen(numero), paginas.`
- Pagina web: `Autor. (Dia, mes y anio). Titulo de la pagina. Sitio web. URL.`
- En APA 7 no agregues la ciudad de la editorial ni antepongas `Recuperado de` a
  una URL, salvo que el tipo de recurso vigente lo requiera.

## 10. Decisiones de normalizacion

La guia contiene dos ambiguedades que deben resolverse de forma consistente:

- Menciona tanto una sangria configurada equivalente a cinco espacios como
  cinco tabulaciones manuales. Para evitar documentos inestables, conserva el
  aspecto visual mediante una sangria real de primera linea. Solo usa caracteres
  manuales si el usuario lo exige expresamente.
- En una frase asigna las letras minusculas al nivel 3, pero la jerarquia y el
  escalonamiento las definen como nivel 4. Usa `Titulo 4`.
- Los ejemplos alternan Proyecto de Graduacion I y II. Usa siempre el curso
  indicado para el entregable actual.

## 11. Lista de control final

- [ ] Archivo DOCX abre sin reparaciones ni advertencias.
- [ ] Carta y margenes 3.5/2.5/3/3 cm.
- [ ] Arial 12, cuerpo 1.5 y parrafos consistentes.
- [ ] Caratula completa, en una pagina, con logo sin deformar.
- [ ] Indice reservado y encabezados con niveles reales.
- [ ] `TOCHeading` sin numeracion, y el primer titulo numerado es `I. Introduccion`.
- [ ] Numeracion superior derecha; caratula e indice sin numero visible.
- [ ] Titulos multinivel, negrita y sangrias correctas.
- [ ] Cuerpo, vinetas, rotulos y tablas alineados con el texto de su titulo.
- [ ] Separacion visible entre titulo y parrafo, y entre parrafos, hecha con
      espaciado y no con parrafos vacios.
- [ ] Ninguna palabra ni codigo partido a mitad dentro de una tabla.
- [ ] Rotulos de tabla/figura consecutivos en orden de aparicion.
- [ ] Las listas salen como vinetas (o 1., 2., 3.), nunca con los indicadores de
      la jerarquia de titulos, y la secuencia de titulos empieza en `I.` sin saltos.
- [ ] Tablas y figuras dentro de margenes, con rotulo, descripcion y fuente.
- [ ] Citas y referencias coherentes con APA 7; ninguna fuente inventada.
- [ ] Sin texto cortado, solapamientos, paginas casi vacias injustificadas ni
      saltos defectuosos.
- [ ] Todas las paginas renderizadas e inspeccionadas visualmente, o limitacion
      declarada de manera explicita.
