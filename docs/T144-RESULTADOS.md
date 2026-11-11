# T-144 · El lector y el volcado — resultados

Timonel (Claude Code, Opus 5.5), rama `sprint-4`, carpeta `C:\Proyectos\baystream-rediseno`.
Bloque 1 de la 10.117. Sale con T-143 en la versión del bloque 1.

Estado: **fase 1, propuesta escrita. ALTO:** Yov la revisa y Carlos la aprueba antes de tocar `lib/`, `test/` o `tool/`.

---

## 0. Paso 0

| Comprobación | Resultado |
|---|---|
| Punta de `sprint-4` | `7b1c56e` (10.122). Trae `235c7eb` (T-143, corrección 2) y `f445d65` (10.121). |
| Árbol de trabajo | `git diff --stat` sale vacío. Los cuatro archivos que Git marca como modificados (`test/t114_fase3_correccion_test.dart` y los tres `windows/flutter/generated_plugin*`) solo traen el aviso de LF→CRLF: no hay cambio de contenido. No son míos y no los toco. |
| T-145 en paralelo | Va con Codex en `C:\Proyectos\baystream-t137` (10.122) y no toca `lib/`, `test/` ni `pubspec.*`. **Falta que Carlos lo confirme.** |
| `flutter pub get` y `flutter analyze` | **Sin correr.** Esperan la luz verde de Carlos y una línea `SEMÁFORO:`. Esta fase solo escribe en `docs/`. |
| Corpus | La carpeta tiene 8 de los 10 archivos de T-140. Faltan `CORPUS_A07.edi` y `CORPUS_A08.edi`, que ahora están en el escritorio de Carlos. **Carlos tiene que pasarme la ruta.** Las huellas de los otros 8 coinciden con `build/t140/resumen.json`. |

---

## 1. Propuesta

### 1.1 Las fuentes

Leí las dos guías de SMDG, descargadas de smdg.org. Cito la página que imprime cada guía en el encabezado.

- **G221:** *User Manual (Implementation Guide) UN/EDIFACT Bayplan Message BAPLIE, Version 2.2.1*, SMDG, 06/2016. `https://smdg.org/wp-content/uploads/MIGs/BAPLIE/Baplie221-03.pdf`. Es la única de la familia 2.x que publica SMDG; su §3 resume la 2.0, la 2.1 y la 2.1.1.
- **G15:** *EDIFACT Bayplan «BAPLIE» User Manual (Implementation Guide), Version 1.5*, SMDG, 05/1993. `https://smdg.org/wp-content/uploads/MIGs/BAPLIE/Baplie15.pdf`. Corresponde a `BAPLIE:1:911:UN:SMDG15`, lo que trae A06.

Las copias de trabajo están fuera del repositorio, en mi carpeta temporal. Los conteos de esta sección salen de un script de solo lectura sobre la carpeta del corpus, también fuera del repositorio. Aquí no hay ningún dato del corpus, solo cifras.

**Lo que dicen las guías, en corto:**

| Tema | 2.2.1 (G221) | 1.5 (G15) |
|---|---|---|
| Puertos del contenedor (LOC del grupo 2) | p. 21: «"9" = Place/Port of Loading», «"11" = Place/Port of discharge», «"83" = Place of delivery (to be used as final destination…)». También 13, 64, 68, 70, 76, 97 y 152. | p. 20: LOC (1) «Code "6" (Port of Loading)»; LOC (2) «Code "12" (Port of Discharge) or "97"…»; LOC (3) «"83" (Place of delivery)», más 63, 65, 69, 71 y 74. **En la 1.5 no existen el 9 ni el 11.** |
| Código del lugar | p. 21: «UN-Locode or US-Census codes». Lista 139 y agencia 6 (UN/ECE) o 112 (US Census). | p. 20: «UN-Locode of 5 characters according to UN Recommendation No. 16». |
| DIM | p. 18: «"5" = Off-standard dims. (over-length front)»; 6 back, 7 over-width right, 8 over-width left, 9 over-height. Unidad «"CMT" … preferred» o «"INH"». El valor va en el componente del largo, del ancho o del alto, «as qualified». Se repite hasta 9 veces. | p. 17: los mismos 5 a 9 («front», «back», «right», «left», «general (overheight)»), unidad «"CM"». Ejemplo: `DIM+9+CM:::320'`, con el alto en el cuarto componente. |
| Número del contenedor (EQD) | p. 25: «One continuous string… SCXU 2387653 must be transmitted as "SCXU2387653"». | p. 22: «Prefix/Number (PPPPPNNNNNNNNN)… spaces to be added to the right». En la 1.5, **los espacios son de la norma**. |
| DGS | p. 29: grupo DGS‑FTX hasta 999 veces por contenedor; clase en el elemento 2 y número ONU en el 3. | La misma disposición de elementos. |

**Lo que trae el corpus** (conteo directo de segmentos; los 8 archivos que hay en la carpeta):

- **DGS dobles:** A02 tiene 1 grupo con dos DGS, A03 tiene 3 y A03v tiene 3. Con A07 (2, según la 10.112) son **6 contenedores, 9 casos contando las variantes**.
- **LOC+83:** viene en todos los archivos menos en los dos `PRUEBA_NIVEL_*`. A01 lo trae en 648 contenedores, A02 en 481, A03 en 369, A04 en 978, A05 en 736, A06 en 626 y A08v en 185. **En 6 de los 8 archivos, el 83 trae texto libre y no un UN/LOCODE:** un país de tres letras, «país − ciudad», asteriscos o vacío.
- **A06:** los 717 contenedores traen LOC+6 y LOC+12, y ninguno trae LOC+9 ni LOC+11. Los 717 números tienen la forma «4 letras, espacio, 7 cifras», y **los 717 tienen el dígito de control ISO 6346 correcto** una vez quitado el espacio.
- **DIM:** ningún archivo lo trae.
- **Códigos de puerto** (9, 11, 6, 12, 5 y 61): todos tienen la forma de 5 caracteres, con dos excepciones:
  - el LOC+61 de A04 y de A06 vale `*****`, que es relleno;
  - A01 trae `XXVSL` en 30 LOC+11. `XX` no es un país de ISO 3166‑1, pero es el mismo prefijo de convenio que usa la guía para `XXOPT`.

### 1.2 Punto 1 · Todas las peligrosas

**Lector y modelo: no cambian.** `ContainerUnit.dangerousGoods` ya guarda todas las declaraciones, en orden. `imdgClass` y `unNumber` siguen siendo la última declaración, por compatibilidad con lo guardado. La segregación (`dangerous_goods_validator.dart`), el cruce con el listado y la comparación de viajes ya recorren la lista completa, y solo usan esos dos campos como respaldo cuando la lista falta.

**Detalle** (`detalle_contenedor.dart`, la señal «Carga peligrosa»). Sigue lo que ya hace `reserved_slot_details.dart` con las celdas reservadas:

- **Con una declaración, el texto es el de hoy:** «Carga peligrosa · IMO 3» y, debajo, «UN 1993».
- **Con dos o más:** el título dice «Carga peligrosa · 2 declaraciones» y va una línea por declaración, en el orden del archivo: «IMO 3 · UN 1993», «IMO 8 · UN 1760». Si falta un dato, la línea dice «IMO sin clase» o «sin número ONU».
- **Un registro viejo** (`dangerousGoods == null`) se muestra como hoy, con la última declaración.

**CSV.** Propongo una celda con separador, más una columna nueva al final:

- **«Clase IMDG» y «Número ONU» llevan todas las declaraciones, en el orden del archivo, separadas por « | ».** Por ejemplo, `3 | 8` y `1993 | 1760`. Las dos celdas se emparejan por posición, y un dato que falta se escribe «sin dato», así que la posición no se pierde.
- **Al final va una columna nueva, «DGS declarados»,** con el número de declaraciones. Queda vacía en un registro viejo, porque ahí no se sabe.

**Por qué así:**

- **Una fila sigue siendo un contenedor.** En Excel, contar, filtrar por «Peligroso = sí» o buscar «contiene 8» funciona sin rehacer nada.
- **No cambia el orden de ninguna columna.** Lo nuevo va al final, así que un lector posicional de las 24 de hoy, como el cotejo de Yov, sigue leyendo lo mismo en cada posición.
- **No pongo columnas «Clase IMDG 2», «Número ONU 2»…** El número de columnas dependería del archivo, y el corpus permite hasta 999 DGS por contenedor.
- **Por qué « | » y no otro separador:**
  - el «;» lo toma Excel como separador de campo en la configuración regional en español, y el exportador hoy no entrecomilla por «;»;
  - el «/» lo puede leer Excel como fecha («3/8»);
  - la barra vertical no es ni número ni fecha en ninguna configuración regional.

### 1.3 Punto 2 · El destino final (LOC+83)

**Lector.** El LOC+83 del grupo del contenedor pasa a `finalDestination`, en la 2.x y en la 1.5, porque las dos guías usan el mismo calificador. Si viene más de uno, gana el último, como hoy con el 9 y el 11.

**Valor:** el primer componente del C517, recortado y **tal cual viene**. No se interpreta: el corpus trae texto libre en 6 de los 8 archivos, y sacar un UN/LOCODE de «US − USHOU» sería inventar el dato. Si el componente viene vacío, el valor es nulo.

**Detalle.** Una fila nueva, «Destino final», debajo de «Puerto de descarga». Solo sale si el archivo lo declara. No se valida ni se colorea.

**CSV.** La columna «Destino final» ya existe: deja de salir vacía.

**Las celdas reservadas** no ganan el campo. `ReservedSlot` no lo modela, y no entra en el volcado.

### 1.4 Punto 3 · Los puertos de la 1.5

**Lector.** Si el UNH es `smdg15MessageIdentifier`, el grupo del contenedor lee el puerto de carga de **LOC+6** y el de descarga de **LOC+12** (G15, p. 20). En la 2.x se siguen leyendo **LOC+9** y **LOC+11** (G221, p. 21).

- **El calificador va atado a la versión.** Un LOC+6 o un LOC+12 dentro de una 2.x no se lee como puerto: en la 2.x no tienen ese significado.
- **El LOC+97,** puerto de descarga opcional en las dos guías, **sigue sin leerse**. En la 2.2.1 lleva el código convenido `XXOPT` y no es un puerto real. Si algún día aparece, es otra tarea.

**Constantes** (`baplie_constants.dart`). Dos nuevas, `locPortOfLoadingV15 = '6'` y `locPortOfDischargeV15 = '12'`, con la cita de G15 en su comentario. Las reservas de la 1.5 usan las mismas.

**Lo que se ve con A06:**
- los 717 contenedores salen con su puerto de carga y de descarga;
- el resumen de la escala deja de dar 0/0/0 en GTPBR (la observación de T‑56 en la 10.43);
- el aviso de la 1.5 no cambia: «Versión 1.5, leída con las reglas de 2.x; revisa pesos y peligrosas»;
- la salida de T‑82 sigue negada desde una 1.5 (T‑103).

### 1.5 Punto 4 · Las matrículas con espacio

**La regla.** Hay una sola función de dominio, `numeroDeContenedor(String)`, en un archivo nuevo, `domain/services/container_number.dart`:
- quita todo espacio en blanco, incluidos el espacio duro y la tabulación;
- pasa todo a mayúsculas;
- no hace nada más.

Es lo que exige G221 («one continuous string», p. 25) y lo que hacen la 1.5 con su relleno (G15, p. 22) y el ejemplo de la guía, «EU 876» → «EU876». **No recorta ni completa a 11 posiciones:** un número que no es ISO 6346 (EU876) queda como viene, sin espacios. **El dígito de control** se sigue evaluando como hoy, y en A06 da 717 de 717 válidos, así que no sale ningún aviso nuevo.

**Dónde se aplica:**

| Lugar | Cambio |
|---|---|
| El lector (EQD) | `containerId` sale normalizado, así que las claves `C:` del plan, los avisos y el CSV ya nacen sin espacio. |
| `ContainerUnit.fromJson` | Normaliza al leer: los viajes guardados con «BYSU 9672095» se leen como `BYSU9672095`. |
| La búsqueda (`container_search_delegate.dart`, `vessel_repository_impl.searchContainers`) | La consulta pasa por la misma función: «bysu 967» encuentra BYSU9672095. El dictado (`normalizeContainerVoiceQuery`) ya entrega el texto sin espacios: lo compruebo con una prueba y no lo toco. |
| El listado (`export_list_parser_service.dart`) | Ya quita los espacios y pasa a mayúsculas: es lo mismo. No lo toco; una prueba fija que coincide con la función nueva. **El cruce con el plan empieza a encontrar los contenedores de un plano con espacios**: hoy no encuentra ninguno. |
| El BAPLIE de salida (`departure_baplie_writer.dart`, `_groups` y `_rawGroups`) | Hoy quita solo «` `». Pasa a usar la función común, para que la clave sea idéntica a la del plan. **El grupo se sigue copiando byte a byte**, así que la salida conserva el EQD tal como vino en el archivo. |
| La comparación de viajes y el detalle | Comparan `containerId`, que ya viene normalizado. Se ven agrupados como hoy, «BYSU 967209 5» (`formatearContenedor`). |
| El CSV | Escribe el número normalizado. |

**La compatibilidad.** Esto es lo que encontré, y cambia el tamaño del riesgo.

- **Hoy no existe ningún movimiento con una matrícula con espacio, en ningún equipo ni en la nube:**
  - `MovementDraft.validate()` exige `^C:[A-Z0-9]{1,17}$` y rechaza «C:BYSU 9672095» con «Falta el número de contenedor: escríbelo»;
  - todo movimiento pasa por esa validación al anexarse (`movement_log_repository_impl.dart:59`);
  - las reglas publicadas (`docs/T130-firestore.rules.propuesta`, `8B903949…`) exigen la misma forma en `validDischarge`, `validLoadFull` y `validCancel`.

  En la 1.0.0, un contenedor de A06 **no se puede descargar ni cargar**. Por eso no hay que migrar la bitácora ni la nube.

**Cada caso:**

- **Una operación abierta.** Cada cliente vuelve a leer el BAPLIE crudo que guarda la operación (`OperationSource.content`), así que la clave sale de la versión del lector:
  - un cliente nuevo ve `C:BYSU9672095` y puede registrar;
  - uno de la 1.0.0 sigue viendo `C:BYSU 9672095`, no puede registrar sobre él, como hoy, y **no reconoce los movimientos que registre un cliente nuevo**: ese contenedor le queda como pendiente;
  - las fuentes no cambian (la misma huella SHA-256) y las reglas tampoco;
  - **solo pasa con un archivo que traiga espacios**, y en el corpus el único es A06.
- **Los puertos de la 1.5 tienen el mismo efecto.** En una operación con una fuente 1.5, un cliente viejo calcula todo como «de paso», porque no lee el puerto de descarga, y uno nuevo calcula la descarga y la carga. Los dos verían papeles distintos para los mismos contenedores.
- **Los viajes guardados en el almacén.**
  - La matrícula se normaliza al leer (`fromJson`), así que la búsqueda y el cruce funcionan sin volver a abrir el archivo.
  - Los puertos de la 1.5, el LOC+83 y el DIM **no se pueden recuperar**: el almacén guarda el viaje ya leído, no el `.edi`. Se ven como antes hasta que se vuelva a abrir el archivo, y el paso del manual lo dice.
- **Clientes de versiones distintas.** Para evitar que se separen propongo:
  1. **publicar los tres clientes juntos**, como ya decidió la 10.117; la Web se actualiza al recargar;
  2. **antes de publicar, Carlos comprueba que ninguna operación abierta tenga una fuente con matrículas con espacio o en versión 1.5**, y si la hay, la cierra. Con las cuentas de demostración ya se hizo así (10.113);
  3. **no propongo una «versión mínima» por operación:** necesitaría un campo nuevo y un cambio de reglas, y eso queda fuera de T‑144.
- **Volver atrás en un mismo equipo.** Un viaje guardado por la versión nueva con un aviso de un tipo nuevo (1.7) no lo puede leer la 1.0.0, porque `BaplieReadNoticeKind.values.byName` lanza un error. Solo pasa si alguien reinstala la 1.0.0 encima de la nueva, y eso no es un camino que se publique. Queda escrito como riesgo aceptado, salvo que Yov prefiera que esos avisos no se guarden.

### 1.6 Punto 5 · El DIM (RF-005)

**Cómo se lee:**
- **El segmento:** `DIM+<e6145>+<unidad>:<largo>:<ancho>:<alto>`. Se toman los calificadores **5 a 9** (G221, p. 18; G15, p. 17), y cada uno lee **su** componente, como dice la guía:
  - 5 (frente) y 6 (atrás): el largo, componente 2;
  - 7 (derecha) y 8 (izquierda): el ancho, componente 3;
  - 9 (alto): el alto, componente 4.
- **La unidad:** CMT (2.x) o CM (1.5) se leen como centímetros. INH se convierte a centímetros (× 2.54, redondeado) **con aviso**, como el MEA en libras. Sin unidad o con otra, el valor no se toma y sale un aviso.
- **Un valor vacío en su componente** no se busca en otro. El contenedor queda marcado como sobredimensionado, porque el DIM lo declara, y sale el aviso «DIM+7 sin valor en su componente».
- **Un calificador repetido con valores distintos** deja el mayor, con aviso. Es el criterio conservador para la estiba.
- **DIM+1 y DIM+10** son la carga suelta y el equipo fuera de norma, no la sobredimensión: no se leen. Se conservan en la salida porque el grupo se copia entero.
- **Si llega antes del EQD,** se acumula como hoy el MEA y el TMP.

**Cómo se modela: el modelo no cambia.** `ContainerUnit` ya tiene `isOverDimension`, `overLengthFront`, `overLengthRear`, `overWidthLeft`, `overWidthRight` y `overHeight`, en centímetros, con su `toJson` y su `fromJson`. `isOverDimension` pasa a valer `true` cuando hay un DIM de 5 a 9 con un valor mayor que cero, o sin valor legible.

**Cómo se ve:**
- **La celda, la leyenda, la Lista y las estadísticas ya reaccionan a `isOverDimension`:** la insignia OOG con el rol `semanticos.oog`, el filtro «OOG», la etiqueta de la Lista y el conteo «fuera de medida». Hasta hoy siempre daban cero. No cambia el orden de las insignias, que es peligrosa, después refrigerado y después OOG; el detalle muestra las tres.
- **El detalle:** la señal «Sobredimensionado» suma una línea con lo declarado, en el orden frente, atrás, izquierda, derecha y alto. Por ejemplo, «Frente 30 cm · Izquierda 20 cm · Alto 25 cm», con espacio duro antes de la unidad (DESIGN.md 11, regla 5). Si el DIM no trae valores: «Medidas no declaradas».
- **El CSV:** las columnas 19 a 24 ya existen y dejan de salir vacías.
- **El BAPLIE de salida conserva el DIM.** El escritor copia el grupo del plan de carga o de la llegada, y su `replace` ya ordena el DIM (rango 3) sin quitarlo. Lo fijo con una prueba sintética: el DIM de entrada sale idéntico.

**Fuera:** RF‑018, la búsqueda por carga especial, que es del bloque 2. Tampoco entra la validación de estiba de los OOG, es decir, las celdas vecinas que ocupa un sobreancho.

### 1.7 Punto 6 · El UN/LOCODE (RNF-008)

**Qué se valida:**
- **Los puertos que la app usa para operar:** 9 y 11 en la 2.x, 6 y 12 en la 1.5, el 13, y el 5 y el 61 de la cabecera.
- **El 83 y el 76 no se validan:** se guardan y se muestran tal cual. El 83 trae texto libre en 6 de los 8 archivos, y validarlo daría cientos de avisos sin ninguna acción posible para el planificador.

**La regla:**
1. **La forma:** `^[A-Z]{2}[A-Z0-9]{3}$`. Es la misma que ya usan el lector para el LOC+61 y las reglas de Firestore para `portOfCall`, así que no hay dos criterios en la app.
2. **El país:** las dos primeras letras tienen que ser un código alfa‑2 **oficialmente asignado** de ISO 3166‑1, 249 códigos en un `Set` constante. No hay dependencia nueva. La fuente se cita en el comentario: la lista pública de ISO (Online Browsing Platform). Antes de escribirla compruebo la nota de uso de esa página; si no es clara, uso la lista de países que publica UNECE con el UN/LOCODE.
3. **Los casos que no son error:**
   - **`XX…`**, el prefijo de convenio de SMDG (`XXOPT`) y de A01 (`XXVSL`, 30 contenedores): se acepta sin aviso. **Decide Yov:** si prefiere avisarlo, son 30 avisos en A01;
   - **un código de solo asteriscos** (`*****`, el LOC+61 de A04 y de A06) se lee como «sin declarar», sin aviso;
   - **con la agencia 112** (US Census, que la 2.2.1 admite) no se valida.

**Lo que no propongo: la lista completa de UN/LOCODE.** Son unos 116 000 lugares, varios MB, y UNECE la renueva dos veces al año. Haría falta un mecanismo de actualización que hoy no existe. El formato más el país atrapan los códigos mal escritos y los inventados de país. Si Carlos quiere la lista entera, es otra tarea.

**Qué pasa con un código que no cumple:**
- **El archivo no se rechaza** y el código se conserva tal cual: en el modelo, en el detalle, en el CSV y en la salida.
- **Sale un aviso de lectura nuevo,** `BaplieReadNoticeKind.locode`, en el resumen del viaje, como los de T‑108.
  - **La línea de resumen:** «Códigos de puerto que no son UN/LOCODE: 3 contenedores · revisa esos puertos con la agencia».
  - **Al tocarla:** una línea por caso, con la causa:
    - «MSCU1234567: LOC+11 «ZZABC»: el país ZZ no existe en ISO 3166‑1»;
    - «MSCU1234567: LOC+9 «GT-PB»: no tiene la forma de un UN/LOCODE (2 letras de país y 3 de lugar)»;
    - en la cabecera: «Cabecera: LOC+5 «…»: …».
  - **Se guarda como texto,** igual que «incomplete», y no como índice de contenedor, porque un aviso de cabecera no tiene contenedor.
- **El DIM usa el mismo mecanismo:** otro tipo de aviso, `dimension`, con el título «Medidas DIM revisadas» y la acción «revisa esas medidas antes de estibar».

**Qué se espera con el corpus:** ningún aviso de UN/LOCODE, si se acepta la regla de `XX`.

### 1.8 Lo que no entra

- **La columna 16b del IMDG** (la segregación por grupo): sigue fuera.
- **La BAPLIE 3.1** (T‑87): sigue esperando un archivo real.
- **Los puertos opcionales** (63 a 74 en la 1.5; 64, 68, 70, 97 y 152 en la 2.x) y **el puerto original de carga** (76): no se modelan.
- **El LOC+83 en las celdas reservadas.**
- **La validación de estiba de los OOG y la búsqueda por carga especial** (RF‑018).
- **La «versión mínima» por operación** (1.5): necesitaría tocar las reglas.

### 1.9 Las pruebas

**Las sintéticas.** Van en `test/t144_*.dart`, con los BAPLIE escritos dentro de cada prueba. **No agrego `.edi` a `test/fixtures/`,** para que el fuzzing de T‑141 corra sobre los mismos 4 archivos y siga dando 180 mutantes, comparables con los de T‑141.

| Punto | Lo que fija |
|---|---|
| 1 | Dos y tres DGS: el detalle con una línea por declaración y el título «· 2 declaraciones»; el CSV con `3 \| 8`, `1993 \| 1760` y «DGS declarados» = 2; un DGS sin número ONU («sin dato»); un registro viejo con `dangerousGoods == null`; con una sola declaración, el texto de hoy, sin cambios. |
| 2 | LOC+83 con un UN/LOCODE, con texto libre y vacío; en la 2.x y en la 1.5; la fila «Destino final» que sale solo si hay dato; la columna del CSV. |
| 3 | La 1.5 con 6 y 12 → los puertos llenos; una 2.x con LOC+6 y LOC+12 → no se leen como puertos; la 2.x sin cambios; el 97 sin leer. |
| 4 | `numeroDeContenedor` con espacio, espacio duro, tabulación, minúsculas, EU 876 y un número de 11 posiciones; el lector, `fromJson` de un viaje viejo con espacios, la búsqueda «bysu 967», el cruce del listado contra un plano con espacios, las claves del escritor y la equivalencia con el normalizador del listado; un movimiento sobre el contenedor normalizado pasa `validate()`. |
| 5 | DIM 5 a 9, con su componente; CMT, CM e INH (con aviso); sin unidad; el valor en el componente equivocado (aviso, sin tomarlo); repetido (el mayor, con aviso); DIM antes del EQD; DIM+1 y DIM+10 ignorados; la insignia y la leyenda OOG; la línea del detalle; las columnas del CSV; el BAPLIE de salida con el DIM idéntico. |
| 6 | La forma, el país inexistente, `XX…`, `*****` y la agencia 112; el aviso con causa y acción; el aviso de cabecera sin contenedor; el viaje guardado y releído con el aviso nuevo. |

**El mínimo:** el piso es 2155 y solo sube, sin pruebas omitidas, con las de T‑103, T‑112, T‑82, T‑86 y las del lector intactas. Si alguna existente fija el comportamiento que cambia a propósito (por ejemplo, «Destino final» vacío o el resumen 0/0/0 de A06), la cambio y la anoto aquí, con su razón.

**El fuzzing de T‑141 otra vez:** `dart run tool/t141_fuzz_baplie.dart`, que espera 180 mutantes y 0 fallas.

**El volcado de T‑140 otra vez,** con el corpus, en `build/t144/h1/`: un CSV por archivo y `resumen.json`, como T‑140. Sale de un script nuevo, `tool/t144_volcado_test.dart`; `tool/t140_volcado_test.dart` queda como evidencia de la 1.0.0 y no se toca.
- **Antes de leer,** el script compara la huella de cada `.edi` con `build/t140/resumen.json` y se detiene si alguna no coincide.
- **A07 y A08 los lee de la ruta que me dé Carlos.**
- **Lo que espero ver,** para que Yov repita el cotejo de H1:
  - los 6 contenedores con todas sus DGS;
  - A06 con sus puertos y sin espacios;
  - el «Destino final» lleno donde el archivo lo declara;
  - las demás columnas, idénticas a T‑140.

  Yov lo puede comprobar con un `diff` contra `build/t140/`, sin la columna `id`, que es un UUID.

**`flutter analyze`** sobre todo el paquete, que tiene que dar cero, sin `// ignore:`.

### 1.10 Los archivos que voy a tocar

**`lib/`:**
- `lib/core/constants/baplie_constants.dart`: los calificadores 6, 12 y 83 y los de DIM, con su cita;
- `lib/features/vessel/data/services/baplie_parser_service.dart`;
- `lib/features/vessel/domain/services/container_number.dart` (nuevo);
- `lib/features/vessel/domain/services/un_locode.dart` (nuevo, con la lista ISO 3166‑1);
- `lib/features/vessel/domain/entities/container_unit.dart`: solo `fromJson`;
- `lib/features/vessel/domain/entities/vessel_voyage.dart`: los dos tipos de aviso y cómo se guardan;
- `lib/features/vessel/data/services/export_service.dart`;
- `lib/features/vessel/presentation/widgets/detalle_contenedor.dart`;
- `lib/features/vessel/presentation/widgets/voyage_summary_card.dart`: los títulos y las acciones de los avisos nuevos;
- `lib/features/vessel/presentation/widgets/container_search_delegate.dart`;
- `lib/features/vessel/data/repositories/vessel_repository_impl.dart`: solo `searchContainers`;
- `lib/features/vessel/domain/services/departure_baplie_writer.dart`: solo la clave de `_groups` y `_rawGroups`.

**Opcional, si Yov lo aprueba:** `lib/features/vessel/presentation/widgets/containers_list_view.dart`. La etiqueta de la Lista dice «IMO 3»; con varias declaraciones diría «IMO 3 +1».

**`test/`:** `test/t144_*.dart` (nuevos), y las existentes que fijen a propósito lo que cambia, nombradas en el informe.

**`tool/`:** `tool/t144_volcado_test.dart` (nuevo).

**Documentos:** `DESIGN.md`, en las secciones del detalle (8 y 13.8) y de los avisos de lectura, y este informe.

**No cambian:** `pubspec.*`, `lib/main.dart`, los dos congelados, las reglas, `firebase.json` ni nada de `windows/`, `android/` o `web/`.

### 1.11 Los pasos del manual que cambian

Los propongo en la fase 2, con el texto final. Son estos:
- el detalle del contenedor: varias peligrosas, «Destino final» y las medidas del sobredimensionado;
- los avisos de lectura: los códigos de puerto y las medidas DIM;
- la búsqueda: «se puede escribir el número con o sin espacios»;
- una nota para los viajes guardados antes de esta versión: para ver el destino final, los puertos de una 1.5 o las medidas, hay que volver a abrir el archivo.

### 1.12 Lo que decide quién

- **Yov y Carlos:**
  - el CSV con « | » y la columna «DGS declarados» (1.2);
  - la regla de `XX…` (1.7);
  - el riesgo de volver a la 1.0.0 en un mismo equipo (1.5);
  - la etiqueta opcional de la Lista (1.10).
- **Carlos:**
  - la aprobación;
  - la ruta de A07 y A08;
  - que ninguna otra tarea tiene abiertos `lib/`, `test/` ni `pubspec.*`;
  - la luz verde para `flutter pub get` y `flutter analyze`;
  - antes de publicar, que no quede abierta ninguna operación con una fuente 1.5 o con matrículas con espacio (1.5).
