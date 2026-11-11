# Revisión independiente de los dos documentos del 7 de noviembre

Revisor independiente (Claude Code), 4 de noviembre de 2026. Hallazgos, no correcciones: no se tocó ningún `.docx` ni `.md`.

## 1. Resumen

**Documento 1, Investigación: 53 hallazgos.** 23 bloqueantes, 22 importantes y 8 menores.
Lo más grave: el «código abierto» no existe hoy, la causa de las discrepancias de H1 está mal atribuida y la evidencia de H3 usa un denominador equivocado.
Dictamen: **no imprimir todavía.** Carlos tiene que decidir primero sobre «código abierto», los resultados retirados del Entregable 2 y las cifras del escenario de referencia.

**Documento 2, Técnico: 52 hallazgos.** 32 bloqueantes, 8 importantes y 12 menores.
Lo más grave: T-115 figura como hecha y no existe, el recuento de requisitos no cuadra y varias afirmaciones sobre el lector, la salida y las versiones no coinciden con el código.
Dictamen: **imprimir después de corregir los bloqueantes.** Casi todos son correcciones de texto; R2-01, R2-03 y R2-06 dependen de una decisión de Carlos.

**Cómo leer las tablas.** «l.» es la línea en `fuentes/DOC1.md` o `fuentes/DOC2.md`. No hay columna de página: el `.docx` no guarda saltos calculados y el verificador se corrió sin `--render`, como se pidió. Dentro de cada severidad, el orden va de mayor a menor gravedad. «Sin fuente a la vista» no significa que sea falso.

## 2. Hallazgos del Documento 1

| Id | Capítulo y apartado | Severidad | Lo que dice | Lo que debería decir | Evidencia |
|---|---|---|---|---|---|
| R1-01 | I; II.D, objetivo general (l. 86); IV.C.3 (l. 467); IV.E (l. 493) | Bloqueante | «de código abierto»; «repositorio público»; «cualquier tercero que clone el repositorio» | El repositorio es privado desde el 15-oct y no tiene licencia. O se abre con licencia antes del 7-nov, o se retira «código abierto» y la reproducibilidad por terceros, y se declara como cambio frente a PG I | `SPRINT-3.md:4418-4421`; `README.md:128-130`; no hay `LICENSE` en la raíz; Doc 2, l. 1130 |
| R1-02 | V.B H1 (l. 666); VI.1 (l. 790); VII.3 (l. 802) | Bloqueante | «el lector conserva solo la última» | El lector conserva todas las declaraciones en `dangerousGoods`. Solo la última llega a `imdgClass` y `unNumber`, que son las columnas del CSV. Las nueve discrepancias son del volcado, no de la lectura. La recomendación 3 debe pedir que el CSV exporte todas | `baplie_parser_service.dart:619-623` y `664-666`; `container_unit.dart:64`; `export_service.dart:75-76`; `test/dangerous_goods_validator_test.dart:299` |
| R1-03 | V.B H3, Tabla 15 (l. 708); l. 721; Anexo C (l. 1000) | Bloqueante | «1 de 145 (0.69 %)»; «registro por registro»; «exportado desde la oficina» | El papel cubre 102 de las 145 cargas: 1 de 102 (0.98 %). Solo 70 cargas están en el papel y en la app. La app se cotejó con ocho capturas del Honor (113 celdas), no con una exportación: las exportaciones no traen los OR | `SPRINT-4.md:2357-2358`, `2389`, `2442` |
| R1-04 | V.B H3, Tabla 15 (l. 710); l. 702 y 712 | Bloqueante | «El contenido coincide con el plan, el listado, el papel y la aplicación» | Coinciden celdas, tipos, destinos, líneas y pesos de las cargas. El archivo tuvo cinco defectos, entre ellos tres números ONU cambiados sin aviso, y el viaje 26043X del rodeo. Se preparó una copia corregida para enviar. La carga corrió en una segunda operación, con un plan alterado y la versión 0.4.0. T-132 lo corrigió después. Hay que decirlo | `SPRINT-4.md:2348`, `2354`, `2456-2471`, `2763` |
| R1-05 | V.C (l. 786) | Bloqueante | «La hipótesis nula general se rechaza en los componentes medidos» | La Tabla 19 no dictamina H3 y la accesibilidad no tiene indicador propio. Solo cabe decir que hay evidencia parcial a favor; la nula general no se rechaza | Tabla 19, fila H3; l. 721 |
| R1-06 | IV.H (l. 520) | Bloqueante | «trabajaron tres asistentes» | Declarar también a Gru (Gemini 4 Argon: segunda lectura del IMDG, 348 de 349 celdas), a GLM 5.3 (relevo del asistente de planificación, 11 a 14-oct) y a Nube (íconos). La sección promete decir «qué hizo cada uno» | `SPRINT-3.md:4012`, `4879-4893`, `5027`; `SPRINT-4.md:435`, `455` |
| R1-07 | V.B H2 (l. 674 y 698); H6 (l. 769) | Bloqueante | «por encima del umbral de 60 %»; «por encima del umbral de 68»; «el resumen por participante» | Quitar la comparación con el umbral y decir «por caso». La 10.108 pide nota neutra y sin dictamen. El resto cumple: sin pruebas estadísticas y «pendiente» en la Tabla 19 | `SPRINT-4.md:3125-3128`, `3180` |
| R1-08 | III.F.3 (l. 342) | Bloqueante | «un color que la oficina asigna» | El color sale de una tabla fija de 15 puertos y, para el resto, de un cálculo. La asignación por la oficina (T-115) no se construyó | `bs_categorico.dart:35-39`; `bs_tema.dart:19`; `DESIGN.md:288`; `SPRINT-4.md:178-183` |
| R1-09 | III.H.2 (l. 378) | Bloqueante | «resolución por orden de llegada con marcas de tiempo del servidor» | El orden sale de la hora del dispositivo, el dispositivo y la secuencia. La hora del servidor es informativa y no entra en el orden | `movement.dart:99-100`, `136-144` |
| R1-10 | II.E.3 (l. 113) | Bloqueante | «genera el BAPLIE de salida y los reportes de la operación a partir de lo registrado» | De lo registrado salen el BAPLIE de salida y la lista de cancelados. PDF, CSV y JSON exportan el plan como llegó, sin OR ni lo cargado | `SPRINT-4.md:2389`; `export_service.dart:105-112` |
| R1-11 | IV.D Tabla 4 (l. 451); IV.E (l. 493); V.B Tabla 16; Anexo C (l. 1004) | Bloqueante | «con `cloc`»; «sin contar las plantillas» | La línea base es `cloc` de directorios completos, con plantillas (E = 1 145). La 3.0 se contó con `tool/t99_codigo_compartido.dart`, sin plantillas (E = 297). No son la misma medida. Con las 650 de plantilla, la 3.0 da 65.9 %: sigue sobre el umbral | `docs/T99-RESULTADOS.md:206-208`, `633`, `823-827`; hoja `M2_Codigo` del registro de mediciones |
| R1-12 | II.A.4 (l. 35-36); Referencias (l. 811 y 865); citas en l. 209, 211, 241, 243 y 247 | Bloqueante | «Bilican, M. S., Evren, R., y Karatas, M.»; «Van Twiller, J., Grbic, D., y Jensen, R. M.» | Bilican, Karatas, Zheng, Turan y Deveci (2024). Van Twiller, Sivertsen, Pacino y Jensen (2024). Hay que corregir las citas en el texto y ver si «Evren» viene del artículo de IEEE Access de 2020 | Crossref, DOI `10.1016/j.eswa.2024.124408` y `10.1016/j.ejor.2023.12.018`; los otros ocho DOI cuadran |
| R1-13 | V.B H1 (l. 666) | Bloqueante | «son cinco contenedores distintos» | Seis: A02 1, A03 3 y A07 2; 5 387 − 5 381 = 6. Esos tres archivos no comparten matrículas. El error viene de la 10.109 | Tablas 11 y 12; `build/t140/*.csv`; `SPRINT-4.md:3156` |
| R1-14 | V.B H3 (l. 717) | Bloqueante | «los contenedores cancelados del listado y sus reemplazos quedaron identificados y fuera» | Fuera quedaron los OR 49 y 50. El reemplazo 149 no figura entre los que no cargaron. El 150, el 75 y el 106 no tenían celda y falta confirmar que no subieron. La app marcó 0 cancelados vigentes | `SPRINT-4.md:2377`, `2439`, `2454`, `2483` |
| R1-15 | IV.E (l. 485) | Bloqueante | «instrumento de precisión definido en el anteproyecto» | Los nueve campos vienen del protocolo M1 del Entregable 2, no de PG I. Ese protocolo pide coincidencia exacta de once caracteres (véase R1-28) | PG I, Tabla 2 y «Precisión del Parser»; Entregable 2, Anexo D, 3.1, Tabla 2 |
| R1-16 | IV.E (l. 497); Tabla 4 (l. 452); Tabla 17 (l. 748); Anexo C (l. 1008) | Bloqueante | «Cada condición comprende treinta mediciones»; «los datos crudos [...] se conservan» | C3 son diez ciclos. La hoja guarda solo el 14-ago. De la serie oficial del 25-ago no hay crudos en el repositorio, y por eso faltan la mediana y el P95 que promete l. 516 | `outputs/latencia-h5-20260814/`; `SPRINT-1.md:668-670` |
| R1-17 | IV.F (l. 504) | Bloqueante | «22 al 25 de agosto: [...] conteo de líneas de la línea base» | El conteo es anterior al 14-ago (etiqueta `m2-baseline`) | Entregable 2, Tabla 28; `SPRINT-1.md:36` |
| R1-18 | V.C (l. 786); VI.6 (l. 795) | Bloqueante | «un instrumento validado»; «una línea base en la encuesta» | El protocolo está diseñado, pero no tiene ninguna aplicación válida. La encuesta da línea base de tiempo, no de usabilidad | l. 512; Anexo A, preguntas 6 y 7 |
| R1-19 | VI.7 (l. 796) | Bloqueante | «lo publicó tres veces en tres plataformas» | Seis publicaciones en los tres clientes: 3.0, 3.1.0, 3.1.1, 0.4.0, 0.4.2 y 1.0.0 | `SPRINT-3.md`, 10.113; `SPRINT-4.md:851`, `1643`, `1999`, `2826`, `3033` |
| R1-20 | IV.I Tabla 5 (l. 532) | Bloqueante | «Julio a 14 de agosto [...] Backlog de 46 elementos» | El Backlog es del 23-ago | Portada del Entregable #3; Doc 2, l. 941 |
| R1-21 | Anexo E (l. 1038, 1057 y 1058) | Bloqueante | RF-002 «Hecho; 2.x y 1.5 con aviso»; RF-021 y RF-022 con OE3 | Igual que el Doc 2: RF-002 «Hecho, redefinido»; o los dos con OE3 o los dos con OE2 | Doc 2, l. 150, 709, 728 y 729 |
| R1-22 | I (l. 13) | Bloqueante | «en ocho apartados» | Nueve, de A a I | Títulos del capítulo III |
| R1-23 | II.E.1 (l. 129) | Bloqueante | «guías de implementación SMDG 2.0 y 2.2» | «2.0, 2.1 y 2.2», como en l. 269 y en el código. El corpus solo ejercita 2.0 y 2.2 | `baplie_parser_service.dart:157` |
| R1-24 | IV.F (l. 512); VI.7 (l. 796) | Importante | «se preparó para el 4 de noviembre»; «retirar del documento mediciones» | Declarar que los entregables del 14 y del 23-ago reportaron 12 participantes (−74.6 %, −83.3 %, SUS 86.25) y una precisión de 98.9 %, y decir por qué se retiraron. La hoja de mediciones rotula esos cotejos como sintéticos | Entregable 2, cap. XVII, Tablas 22 a 25 y 27; Entregable #3, Tablas 38 a 40; hojas `M1_Detalle` y `VERIFICACION_M1` |
| R1-25 | V.B Tablas 13, 14 y 18; IV.H (l. 522) | Importante | «construido para ensayar el protocolo»; «se tomaron de archivos de datos» | Decir quién construyó los valores y con qué base, o dejar las tablas en blanco. Hoy son cifras por caso sin archivo de origen, bajo una regla que prohíbe inventar datos | Sin fuente a la vista en el repositorio; `SPRINT-4.md:3105`, `3125-3130`; `AGENTS.md` |
| R1-26 | II.D OE1 (l. 90); IV.B H1 (l. 431); VI.1 (l. 790) | Importante | OE1 promete «puertos, pesos, metadatos del buque»; la conclusión da 99.85 % | El dictamen usa nueve campos sin puertos ni metadatos. Con puertos da 88.22 %. La conclusión debe decir que OE1 se cumple en esos nueve campos, no en todo lo que promete | Tabla 11; `build/t140/CORPUS_A06.csv` (0 de 717 con puertos) |
| R1-27 | IV.C.3 (l. 467); V.B; VI.1 | Importante | «diez archivos de ocho operaciones reales»; 6 161 | A06 repite las 717 matrículas de A05, 687 en la misma celda y 707 con el mismo peso. A07 y A08 comparten 284. Son 4 386 matrículas distintas. Con 6 fallas sobre 4 386 da 99.86 % (IC 99.70–99.94), que sigue cumpliendo, pero hay que declararlo | Cálculo sobre `build/t140/*.csv`; `SPRINT-2.md:281`; `SPRINT-3.md:2471` |
| R1-28 | V.B H1 (l. 668); Anexo C (l. 996) | Importante | «tres limitaciones» | Cuatro. Los 717 contenedores de A06 conservan el espacio en la matrícula y el cotejo lo quita. El protocolo pedía coincidencia exacta y el Entregable 2 contaba ese caso como error. El buscador no las encuentra escritas sin espacio | `SPRINT-4.md:3159-3161`; `CORPUS_A06.csv`; `container_search_delegate.dart:84` |
| R1-29 | V.B Tabla 12 (l. 657, 658 y 662) | Importante | A07 «99.50 %» | 396 de 398 es 99.497 %. A03, A03v y A07 quedan bajo 99.5 % por archivo: conviene decirlo | Tabla 12 |
| R1-30 | IV.E (l. 489); V.B (l. 712-721); VI.4 | Importante | «Errores de posición»; «se habrían descubierto durante o después de la carga» | El error del papel es un número mal anotado, no un contenedor mal colocado. Las cuatro advertencias son cruces de datos. Las equivalencias erradas las causó la propia app. El contrafactual no tiene fuente | `SPRINT-4.md:2363`, `2370`, `2377` |
| R1-31 | II.E.5 (l. 133); VI.4 (l. 793) | Importante | «cuando una regla de estiba se incumple» | Antes de confirmar una carga, la app revisa tamaño, celda, plan, grupo, ocupación y peso de pila. Segregación, tomas y 20 sobre 40 solo están en «Alertas» | `load_check.dart:7-29` |
| R1-32 | IV.B H5 (l. 435); IV.G (l. 516); V.C | Importante | «Se acepta H5» | Declarar la regla de decisión, que falta: PG I decía «latencia máxima» y el Entregable 2, mediana y P95. Decir que se midió en agosto, en el proyecto temporal, de Chrome a Android, sin Windows, sin movimientos reales y sin C2 oficial | PG I, H5; Entregable 2, Anexo D 5.4 y Limitaciones; `SPRINT-1.md:632`, `676`; `docs/CIERRE-DESPLIEGUE.md:12-14` |
| R1-33 | V.B H4 (l. 734) | Importante | «solo agregó código Dart compartido, por lo que la proporción no puede haber bajado» | Es una suposición. El sprint no fue solo visual y `lib/` pasó de 137 a 203 archivos. Contar con `tool/t99_codigo_compartido.dart` o decir solo que no se contó | `docs/T99-RESULTADOS.md:199`; conteo de `lib/` |
| R1-34 | V.B; VI | Importante | «versión 3.0» y «versión 1.0.0», sin explicar | Agregar qué versión midió cada indicador: H5, agosto; H4, 3.0; H3, 0.4.0 (y 3.1.0 en el piloto 2); H1, 1.0.0. Explicar por qué tras la 3.0 viene la 1.0.0: solo lo dice el Doc 2 | `SPRINT-4.md:1195-1198`, `1963-1975`, `2348` |
| R1-35 | IV.B (l. 429); II.D (l. 97) | Importante | «Dos umbrales cambiaron» | Reunir en una tabla todo lo que cambió: título, OE2, OE4 (tablet y listado de secuencia), OE5 (WiFi), H3, H4 (de horas y COCOMO a líneas), H5, Puerto Quetzal y periodo. El Entregable 2 además usó H1 ≥ 95 y H6 ≥ 80, y la ERS fija SUS 75 | PG I, hipótesis y Tabla 2; Entregable 2, cap. XVII; `SPRINT-4.md:3123` |
| R1-36 | IV.B (l. 429) | Importante | «conserva la nomenclatura H1 a H6» | Confirmarlo con el tutor: el 17-oct pidió una sola hipótesis con indicadores numerados, y el cambio quedó pendiente en el documento | `SPRINT-3.md:5731-5741` |
| R1-37 | VI | Importante | Conclusiones por OE y por método | Falta la conclusión general y la respuesta a la pregunta general y a las seis específicas. La tercera («más efectiva») no tiene comparación | II.C frente a VI |
| R1-38 | IV.A (l. 415-417); V.C | Importante | «no experimental»; «Se acepta H4 y se rechaza su nula» | La comparación de H2 manipula el método (el Entregable 2 la llamó cuasiexperimental). La hipótesis es causal y el diseño no. H4 y H5 no tienen prueba inferencial: conviene «cumple el umbral» | Entregable 2, Tabla 22 y Anexo D 4.1 |
| R1-39 | IV.B (l. 438) | Importante | «así se declara en las limitaciones» | Ese apartado no existe. Reunir las limitaciones, incluida la que se perdió del Entregable 2: participantes colegas del autor y deseabilidad social | l. 139-151; Entregable 2, «Limitaciones del estudio» |
| R1-40 | IV.C.3 y 4 (l. 467 y 471); Anexo D (l. 1025) | Importante | «valores ficticios» y «MAGELLAN STAR, viaje 26039S [...] 398» | El nombre real, el viaje y la cuenta identifican a A07. Usar un alias o tener el permiso por escrito. El Doc 2 ya evita los nombres | `SPRINT-4.md:2346-2348`; `docs/S3-CASO-MAGELLAN-STAR.md:1-8` |
| R1-41 | VI.6 (l. 795) | Importante | «que los errores de posición son frecuentes» | Es una percepción: 12 personas por conveniencia, siete en grupo. El propio documento admite que no tiene tasa medida | l. 438, 463 y 721 |
| R1-42 | VII.4, 5 y 7 | Importante | «cuando aparezca»; «Atender los requisitos no funcionales» | Darles criterio verificable: qué umbral, con qué instrumento y qué producto se espera | VII |
| R1-43 | II.D (l. 97) | Importante | «por indicación del catedrático» | Sin fuente a la vista. El 17-oct la meta seguía en 98 %. Debería estar en un correo o acta del catedrático | `SPRINT-3.md:5738`; `SPRINT-4.md:3132` |
| R1-44 | IV.C.4 (l. 471); IV.E (l. 485); V.B (l. 702) | Importante | «123 descargas»; el script «se conserva como evidencia» | Sin fuente a la vista. El registro del piloto y `h1_cotejo.py` están en el proyecto de Yov, no en el repositorio | `SPRINT-4.md:2348`, `3147` |
| R1-45 | IV.C.3 (l. 467); Anexo D (l. 1020) | Importante | «dos líneas navieras, una terminal y un exportador» | Sin fuente a la vista. La hoja `M1_Corpus` da NV1, NV3, NAVE5 y Exportador A. Debería confirmarse con las cabeceras UNB | Hoja `M1_Corpus` |
| R1-46 | III.D.1 a 3 (l. 261, 269 y 290) | Menor | «Shipping Message Development Group»; «la más reciente»; «desde 1987» | SMDG es Ship-planning o Shipping Message Design Group. SMDG ya publica 3.2 sobre D.21A y 2.3. «Mantenido desde 1987» por UN/CEFACT: sin fuente a la vista | smdg.org (véase la sección 5) |
| R1-47 | III.B.3 (l. 211) | Menor | «sobre-estiba o re-estiba» | No son lo mismo: el Doc 2 las separa | Doc 2, l. 415 y 1959 |
| R1-48 | Tabla 9 (l. 613 y 617); Anexo A (l. 918) | Menor | Enunciados entre comillas con otro texto; pregunta 17 sin el límite | Citar literal: la 16 decía «mediante una tableta». La 17 tenía «máximo de tres opciones» | l. 915-918; Entregable 2, Anexo A |
| R1-49 | I; IV.F; VII | Menor | «prueba de campo» | Se usa para el 5-oct y para lo pendiente. Usar otro nombre para lo pendiente | l. 11, 505 y 806 |
| R1-50 | Tablas 4, 22 y 23; III.E.4 | Menor | «T-140», «T-99», «ERS v2», «dp» | Definirlos: este documento no los explica | l. 324, 448, 451 y 1033 |
| R1-51 | II y III | Menor | Párrafos casi repetidos | Unir o abreviar: l. 25 y 251; l. 29 y 255; l. 130 y 791 | Comparación por script |
| R1-52 | Referencias | Menor | «Google LLC», «Supabase, Inc.» | APA pide la misma forma en el texto y en la lista: en el texto dice «Google» y «Supabase» | l. 348, 388, 819 y 857 |
| R1-53 | Índice y metadatos | Menor | Página de índice vacía; título interno «Plantilla de entregables» | Generar el índice en Word antes de imprimir, como pide la plantilla, y repasar la numeración. Corregir el título del archivo | `formato-academico.md`, apartado 4; `docProps/core.xml` |

## 3. Hallazgos del Documento 2

| Id | Capítulo y apartado | Severidad | Lo que dice | Lo que debería decir | Evidencia |
|---|---|---|---|---|---|
| R2-01 | IV Tabla 67 (l. 1081); RF-008 (l. 209 y 212); RNF-008 (l. 638); Tabla 55 (l. 715) | Bloqueante | T-115 «Hecha»; «asigna la oficina»; «se validan contra la lista de la UNECE» | T-115 no se hizo: no hay informe, ni pantalla, ni datos en Firestore, ni lista UN/LOCODE en `lib/`. Son dos tareas sin hacer en el Sprint 4, no una. Corregir RF-008 y RNF-008 | `bs_categorico.dart:38-39`, `84`; `DESIGN.md:87`, `288`; `SPRINT-4.md:178-183` |
| R2-02 | II.F (l. 750) | Bloqueante | «31 están hechos (8 de ellos [...])»; «los 14 requisitos MUST están hechos» | 32 hechos (7 redefinidos), 2 parciales y 1 no: suman 35. Los MUST son 18 y 17 están hechos; RF-005 es MUST y está parcial | ERS v2, Tabla 6 (18 MUST); Tabla 55; Doc 1, Anexo E |
| R2-03 | IV.E.2 (l. 1130); II.A (l. 21); II.B (l. 91); II.D.3 (l. 654); IV (l. 1106) | Bloqueante | «privado desde el Sprint 2»; «los datos reales nunca entraron»; «de código abierto» | Privado desde el 15-oct, en el Sprint 3, y sin licencia. Dos números reales de contenedor quedaron en la historia del commit `92c321d`. «Código abierto» contradice el estado actual | `SPRINT-3.md:4418-4421`; `SPRINT-2.md:3477`; `README.md:128-130` |
| R2-04 | RF-002 (l. 147); II.D.1 (l. 646) | Bloqueante | «respetando el carácter de escape» | El lector no trata el carácter `?`: divide con `split` y la constante `releaseCharacter` no se usa. Solo el escritor de salida lo respeta | `baplie_parser_service.dart:121-136`; `baplie_constants.dart:20`; `departure_baplie_writer.dart:642` |
| R2-05 | RF-004 (l. 170) | Bloqueante | «con dos segmentos DGS conserva solo el último»; «en la versión 1.5 no toma [...] ni el destino final» | Conserva todos en `dangerousGoods`; el CSV solo muestra el último. LOC+83 no se extrae en ninguna versión | Igual que R1-02; columna «Destino final» vacía en los diez CSV |
| R2-06 | II.A.1 (l. 23); RF-001, RF-009, RF-016 y RF-021 | Bloqueante | «no se reescribió ningún requisito para hacerlo coincidir con el producto» | Sí se reescribieron criterios. RF-001 quitó el filtro por extensión. RF-009 hace lo contrario de la ERS. RF-016 ya no distingue carga de descarga. RF-021 quitó el desplazamiento fluido con miles. Esos cuatro deben quedar como «Hecho, redefinido» o declarar el criterio original | ERS v2, criterios de cada RF; fichas en l. 138, 219-220, 292 y 344; `docs/T99-RESULTADOS.md:509` |
| R2-07 | RF-033 (l. 468) | Bloqueante | «El JSON es válido y reimportable»; estado «Hecho» | La app no reimporta JSON: solo abre BAPLIE. La prueba solo decodifica el texto. Declararlo como parcial o redefinido | `export_service.dart:105`; `test/export_service_test.dart:163-165` |
| R2-08 | RF-039 (l. 533); l. 646; CU12 (l. 834); manual (l. 1817) | Bloqueante | «(SMDG 2.2)» | La salida conserva la cabecera del plan de carga: puede ser SMDG 2.0, 2.1 o 2.2 | `departure_baplie_writer.dart:5`, `601-605`; `docs/T82-RESULTADOS.md:57-60` |
| R2-09 | RF-039 (l. 534 y 536) | Bloqueante | «cuadró en contenido con el plan y con el papel» | Cuadró en celdas y datos de carga, pero el archivo tuvo cinco defectos y se preparó una copia corregida. T-132 los corrigió y se comprobó con los datos del piloto | `SPRINT-4.md:2456-2471`, `2763` |
| R2-10 | III.E (l. 880) y Figura 8 | Bloqueante | «el BAPLIE de salida ya se puede generar» | Solo si la operación tiene plan de carga: sin él, el escritor se detiene | `departure_baplie_writer.dart:20-25` |
| R2-11 | IV Tabla 67 (l. 1091); Tabla 68 (l. 1120) | Bloqueante | 0.4.1 «publicada después de la exposición»; lista 3.1.1, 0.4.0, 0.4.1, 0.4.2 y 1.0.0 | La 0.4.1 nunca se publicó: entró en la 0.4.2. Falta la 3.1.0, publicada el 24-oct y usada en el piloto 2 | `SPRINT-4.md:851`, `1198`, `2692`, `2711`, `2718` |
| R2-12 | II.B.5 Tabla 3 (l. 100-112); l. 96 | Bloqueante | `fake_cloud_firestore` 4.2.0; equatable 2.1.0; uuid 4.3.3; «todas fijadas» | Ya no está `fake_cloud_firestore`. El lock dice equatable 2.0.8 y uuid 4.5.2. Falta `cloud_firestore_platform_interface` 8.0.7. Ocho paquetes van con `^`, no fijos | `pubspec.yaml`; `pubspec.lock:203`, `827` |
| R2-13 | RF-041 (l. 553-554); l. 47 y 120 | Bloqueante | «En Windows y en la Web, donde no hay dictado» | La Web sí dicta en navegadores con Web Speech, como Chrome. Solo Windows no tiene dictado | `voice_recognizer_provider.dart:12-15`; `browser_voice_support_web.dart`; `docs/T94-RESULTADOS.md:50` |
| R2-14 | I (l. 9); II.B.2 (l. 53); módulo 8 (l. 496); IV.B (l. 994) | Bloqueante | Los seis RF «nacieron de las pruebas piloto» | RF-036 es del Sprint 2, antes de la primera prueba (l. 1022). RF-037 viene de OE4. RF-038 a RF-041 son pedidos de Carlos del 5-oct. Ninguno nació de los pilotos 2 y 3 | `SPRINT-3.md:183-192`; Doc 2, l. 1022 |
| R2-15 | IV (l. 1106) | Bloqueante | «la operación completa de la primera escala»; «seis hallazgos que se corrigieron» | Fue otro viaje del mismo buque: 26043S, no 26039S. El piloto 2 dio siete hallazgos: seis se corrigieron en la 3.1.1 y H2 llegó con T-127 | `SPRINT-4.md:2348-2351`, `1477-1486`; `docs/T122-RESULTADOS.md:17-23`; Doc 1, l. 471 |
| R2-16 | II.E.2 Tabla 54 (l. 687-689); III.B (l. 844) | Bloqueante | Tipos con «re-estiba»; «cuenta que la publicó»; `ExportList` con «la revisión» | Los nueve tipos son los de l. 844: la re-estiba es una descarga con `restow`, y falta el rechazo. `Operation` no guarda la cuenta. La revisión está en `OperationSource` | `movement.dart:13-26`, `212-221`; `operation.dart:21-32`, `157`; `export_list.dart:281-293` |
| R2-17 | RF-030 (l. 438); RNF-006 (l. 618) | Bloqueante | «en el teléfono [...] 33 de 33 funciones» | Son 11 operaciones por cliente; 33 son las comprobaciones de los tres clientes. En el teléfono, 11 de 11 | `docs/T98-RESULTADOS.md:11`; `SPRINT-3.md:6542` |
| R2-18 | RNF-002 (l. 577); RNF-006 (l. 617) | Bloqueante | Fila «Umbral del ERS» sin dos umbrales | Falta «usuario productivo en menos de 10 minutos» (RNF-002), sin medir, y «disponibilidad 99.9 %» (RNF-006) | ERS v2, RNF-002 y RNF-006; `SPRINT-3.md:6544` |
| R2-19 | III.C (l. 858) | Bloqueante | MSIX firmado «sin permisos de administrador» | El certificado es propio y un equipo nuevo debe confiar en él una vez, como administrador. Solo el asistente evita ese paso | `docs/T93-RESULTADOS.md:322`; `SPRINT-4.md:2871` |
| R2-20 | IV.D Tabla 66 (l. 1053) | Bloqueante | RF-037, «T-75 a T-78» | Falta T-72, la bitácora de movimientos. Con ella la tabla lista 50 tareas, no 49: hay que reconciliarla con el tablero | `SPRINT-3.md:184`; `docs/T72-RESULTADOS.md` |
| R2-21 | IV.A.1 (l. 910); IV.B (l. 941) | Bloqueante | «de enero a junio»; «se explica en el apartado B»; «al abrir Proyecto de Graduación II» | Las iteraciones van del 20-ene al 14-ago, y Doc 1 dice que PG I fue de febrero a mayo. El apartado B no explica la correspondencia. PG II abrió antes del 23-ago | Entregable #3, Tabla 36; Doc 1, l. 526; Entregable 2 (14-ago) |
| R2-22 | IV.A.5 (l. 937); IV.B (l. 941) | Bloqueante | «35.0 horas medidas» | Contradice al Doc 1, que descarta esa reconstrucción (l. 493). Son horas reconstruidas de 10 commits. Usar la misma palabra en los dos | Doc 1, l. 493; hoja `M2_Bitacora` |
| R2-23 | IV.B (l. 994) | Bloqueante | «los 17 elementos abiertos se entregaron» | RF-035 quedó parcial | Tabla 63, l. 984 |
| R2-24 | IV.A.3 (l. 929) | Bloqueante | «282 decisiones [...] (10, 49, 113 y 110)» | 281: en el Sprint 3 no existe la 10.104, así que son 112 | `SPRINT-3.md`, títulos 10.n |
| R2-25 | IV.E.2 (l. 1130) | Bloqueante | «13 hallazgos [...] (uno medio [...], cinco bajos y seis informativos)» | Suman 12. El 13.º es T113-01, una falta de evidencia ya resuelta | `docs/T113-SEGURIDAD-RESULTADOS.md:244`, `260` |
| R2-26 | II.B.2 Tabla 1 (l. 66) | Bloqueante | Módulo 8, épicas «E5 y E6» | E5 y E3: RF-041 es E3 y ninguno es E6 | Fichas, l. 505 a 555 |
| R2-27 | II.B.4 (l. 90); RNF-002 (l. 578-579) | Bloqueante | «Material Design 3 sin excepciones» | El último censo del rediseño da 251 controles, 7 exclusiones y 3 excepciones. No hay censo sobre la 1.0.0 | `docs/REDISENO-RESULTADOS.md:1291-1293`; `SPRINT-4.md:491` |
| R2-28 | RNF-003 (l. 588) | Bloqueante | «a 1.0, 1.45 y 2.0, verificada en T-131» | T-131 probó las cabeceras con el distintivo, a 1.0 y 2.0. La condición general viene de T-114 | `docs/T131-RESULTADOS.md:215-217` |
| R2-29 | III.B (l. 838) | Bloqueante | «avisos de lectura con los que se dictaminó la hipótesis H1» | H1 se dictaminó con el CSV y el cotejo. Los avisos de los diez archivos salieron vacíos | `build/t140/resumen.json` |
| R2-30 | II.E.3 (l. 698) | Bloqueante | «Dos colecciones más» | Esas colecciones están en el proyecto temporal de H5. En producción están cerradas | `docs/T130-firestore.rules.propuesta:478`; `docs/CIERRE-DESPLIEGUE.md:12-14` |
| R2-31 | IV.A.2 (l. 914); Tabla 62 | Bloqueante | Dos programadores y un asistente de planificación | Agregar a Gru, GLM 5.3 y Nube, igual que en R1-06 | `SPRINT-3.md:4012`, `4879`; `SPRINT-4.md:435` |
| R2-32 | I (l. 13) | Bloqueante | Cuatro valores de estado; «hecho» exige los tres clientes | Las tablas usan «Hecho, PROVISIONAL» y «Parcial, redefinido». RF-041 no aplica en Windows | l. 492, 546 y 554 |
| R2-33 | RNF-002 (l. 578) | Importante | «Versión 1.0.0: 3 pasos, con 2.26 s» | Se midió del 22 al 24-oct, no sobre la 1.0.0. Android fue el emulador. Codex midió 2.80 s y la primera corrida tras instalar tardó 4.91–4.98 s | `SPRINT-4.md:492`, `546`, `1010`, `1051` |
| R2-34 | RNF-004 (l. 598); II.E.3 (l. 696) | Importante | «TLS 1.3 observado»; «byte a byte» (T-113) | TLS ≥ 1.3 se infirió de QUIC en Chrome. T-113 cotejó las reglas de T-80, y en la 1.0.0 rigen las de T-130, con baterías 69, 25, 31 y 38. El cotejo de T-130 no está a la vista | `SPRINT-3.md:6541`; `SPRINT-4.md:2761`, `2835` |
| R2-35 | I (l. 9); IV (l. 1110 y 1134); manual (l. 1180) | Importante | Instalador con asistente como parte de la 1.0.0 | Sigue en la rama `t137-instalador`, fuera de `master`, y no va firmado: si se descarga, Windows avisa. El manual no lo menciona | `SPRINT-4.md:2884`, `3020`, `3036`, `3091` |
| R2-36 | IV.C (l. 1016) | Importante | «dos auditores independientes» | Fueron Codex y Yov, dos asistentes bajo la dirección del autor. Decirlo | `docs/AUDITORIA-CALIDAD-SPRINT1-CODEX.md`; `-YOV.md` |
| R2-37 | IV.E.2 (l. 1130) | Importante | Sin mención del pentest | Se planificó y no hay resultados. Declararlo como pendiente junto con las cabeceras de Hosting | `SPRINT-3.md:6600`; `SPRINT-4.md:4`; `docs/PENTEST-PLAN.md`; `docs/T113-SEGURIDAD-RESULTADOS.md:247` |
| R2-38 | RF-011 (l. 239); manual (l. 1419-1420 y 1530) | Importante | Categorías OOG y «fuera de medida» | Con un archivo real siempre dan 0, porque el lector no las asigna (RF-005). Decirlo en la ficha y en el manual | `baplie_parser_service.dart` (sin `isOverDimension`) |
| R2-39 | RF-028 (l. 418); RF-040 (l. 546); RF-041 (l. 556); l. 1880 | Importante | «descrito en el manual de la versión 3.0» | Ese manual no se entrega y es anterior al rediseño. El lector no tiene dónde ver esas funciones | `docs/MANUAL-USUARIO.md` |
| R2-40 | IV Tabla 68; l. 1016 | Importante | «≈ 28» commits y «7 commits de código» | Sin fuente a la vista: no se ejecutó Git. Aclarar la diferencia entre los dos conteos | `SPRINT-1.md` (7 commits) |
| R2-41 | Referencias | Menor | 18 entradas | 13 no tienen cita de autor y año en el texto: Brooke, Google (2), IMO, ISO (3), Lewis, Martin, OWASP (2), Rousselet, Schwaber y W3C | Comparación por script |
| R2-42 | Glosario | Menor | Faltan siglas | dp, MSIX, AAB, ANR, TLS, OWASP, UML, C-3 y H-02, H-06 y H-07 | l. 222, 272, 1034 y 1036 |
| R2-43 | Manual (l. 1199 y 1366) | Menor | «BAPLIE/EDIFACT 2.2.1»; «Volver al Inicio» | El asistente aún dice 2.2.1, que la ficha RF-002 redefinió. El rótulo de la app es «Volver al inicio» | l. 150 y 1384; `docs/MANUAL-USUARIO-1.0.0.md` |
| R2-44 | Manual (l. 1137 y 1139) | Menor | «Todos los datos [...] son sintéticos»; «tema claro» | Las figuras 15 y 16 son de Play y de la Web de producción, y la 54 es oscura | l. 1235 y 1247; Figura 54 |
| R2-45 | IV (l. 1106) | Menor | «ninguna contradicción donde los dos registros coincidían» | Es una tautología: decir «donde están los dos» | `SPRINT-4.md:2359` |
| R2-46 | IV Tabla 62; l. 21 y 1068 | Menor | «catedrático», «asesor», «tutor» | Parecen varias personas. Según las portadas es el Ing. Escobar: unificar | l. 925; portadas |
| R2-47 | IV.A.3 (l. 929) | Menor | Tablero Kanban «de cada sprint» en el repositorio | En `docs/` hay tablero de los sprints 1, 2 y 3; del 4 no | `docs/` |
| R2-48 | RF-007 y RF-012 | Menor | «Manual, "El Plano", figura 23» | La figura 23 está en «Parámetros del Buque» | l. 1337-1339 |
| R2-49 | RF-027 (l. 404); RF-028 | Menor | «restiba», «sobreestibas», «re-estiba» | Usar un término por concepto, igual que el Doc 1 | Glosario, l. 1959 |
| R2-50 | II.B.4 (l. 88) | Menor | «Android 8.0 o superior (API 26)» | El paquete declara `minSdk` 24. Lo probado es API 26: decirlo así | `SPRINT-3.md`, 10.112 |
| R2-51 | RF-037 (l. 516); Tabla 55 (l. 744) | Menor | «T-122, T-124, T-125» y «T-122 a T-125» | Usar la misma lista | l. 516 y 744 |
| R2-52 | Índice y metadatos | Menor | Página de índice vacía; título interno «Plantilla de entregables» | Igual que R1-53 | `formato-academico.md`, apartado 4 |

## 4. Las diez preguntas más probables de la terna

1. **«En agosto reportó 12 participantes, 74.6 % de reducción y SUS 86.25. ¿Qué pasó con eso?»**
   - Hoy responden: nada directo. La conclusión 7 dice que se retiraron «mediciones que no cumplían las condiciones».
   - Flaquea: el texto solo habla de una sesión del 4-nov, y la hoja de agosto dice «sintéticos». Es la pregunta más peligrosa (R1-24).

2. **«Si la regla es no inventar datos, ¿de dónde salen P1 a P5?»**
   - Hoy responden: es un escenario de referencia para ensayar el protocolo y no es evidencia.
   - Flaquea: no dicen quién hizo esas cifras ni con qué base, y dos frases las comparan con el umbral (R1-07 y R1-25).

3. **«Dicen código abierto. ¿Dónde está el repositorio y con qué licencia?»**
   - Hoy responden: el Doc 1 dice que es público y el Doc 2, que es privado.
   - Flaquea: es una contradicción entre documentos en el objetivo general, y no hay licencia (R1-01 y R2-03).

4. **«¿El 99.85 % incluye los puertos y la carga sobredimensionada?»**
   - Hoy responden: no incluye puertos (88.22 % si se incluyen), y OOG coincide de forma trivial.
   - Flaquea: OE1 promete puertos y el lector no lee DIM. Además, la causa declarada de las nueve fallas es incorrecta y el corpus repite contenedores (R1-02, R1-26 y R1-27).

5. **«¿Qué error detectó la app antes de que la grúa se moviera?»**
   - Hoy responden: ninguno en sentido estricto. Dan 0 errores frente a 1 del papel y cuatro advertencias del cruce.
   - Flaquea: el error del papel es de anotación, el denominador es 102 y no 145, y la nula general se da por rechazada sin dictaminar H3 (R1-03, R1-05 y R1-30).

6. **«¿La latencia medida es la de la versión 1.0.0, en Windows, con movimientos reales?»**
   - Hoy responden: la serie oficial cumple 30 de 30, de 0.257 a 0.785 s en un sentido.
   - Flaquea: es de agosto, en un proyecto temporal, de Chrome a Android, sin Windows ni mediana oficial (R1-16 y R1-32).

7. **«¿Por qué miden esfuerzo con líneas de código, y son comparables sus dos cifras?»**
   - Hoy responden: es una medida reproducible y la bitácora de horas se descartó.
   - Flaquea: las dos cifras usan instrumentos y bases distintas, nadie puede clonar el repositorio y el Doc 2 llama «medidas» a las horas descartadas (R1-11, R1-33 y R2-22).

8. **«Solo un RNF de ocho cumple. ¿Por qué se llama 1.0.0?»**
   - Hoy responden: los «no cumple» se presentan tal cual y la versión se numeró para el examen final.
   - Flaquea: la memoria pasa de 450 MB contra un umbral de 200, T-120 se difirió y los RNF no se repitieron sobre la 1.0.0 (R2-33). Además, el recuento de requisitos publicado está mal (R2-02).

9. **«¿Qué cambió desde el anteproyecto?»**
   - Hoy responden: dos umbrales y la redacción de H3.
   - Flaquea: cambiaron también el título, OE2, OE4, OE5, H4, H5, el alcance y el periodo. El tutor pidió una sola hipótesis y el documento conserva seis (R1-35 y R1-36).

10. **«¿Qué hizo cada inteligencia artificial, y quién verificó que no inventara nada?»**
    - Hoy responden: tres asistentes, con reglas escritas, pruebas y huellas SHA-256.
    - Flaquea: faltan Gemini, GLM y Nube, y los «auditores independientes» son los mismos asistentes (R1-06, R2-31 y R2-36).

## 5. Alcance de la revisión

**Lo que sí cuadra.** No hace falta volver a revisarlo:
- los cuatro intervalos de Wilson;
- la Tabla 17, recalculada desde el registro crudo;
- la aritmética de las Tablas 13, 14, 16 y 18;
- la encuesta frente al Entregable 2;
- los 46 elementos, 209 puntos y 99.5 horas del Backlog, y sus subtotales;
- las horas de los sprints 1, 2 y 3;
- las cifras de RNF contra T-98 y T-99;
- los números cruzados de tablas y figuras;
- el título idéntico en los dos documentos;
- los `.docx` frente a sus `.md`, sin diferencias de texto;
- las 45 capturas;
- el manual frente a `docs/MANUAL-USUARIO-1.0.0.md`, más su sección de T-119;
- `verificar_formato.py`: 0 fallas y 0 avisos en los dos documentos, sin marcadores pendientes.

**Lo que no se pudo verificar.**
- No se repitió el cotejo de 6 152 de 6 161, porque el corpus no se tocó y `h1_cotejo.py` no está en el repositorio. Se revisaron la aritmética y los volcados de `build/t140`.
- No se contaron commits, porque no se ejecutó Git. Tampoco se ejecutaron Flutter, Dart ni el emulador.
- No se revisó el render de las páginas ni de los diagramas: solo sus fuentes.
- `python-docx` solo funciona sin `-I` y `pandoc` no está instalado. Los `.docx` se leyeron con un extractor propio en Python, solo de lectura.

**Fuentes externas de las referencias.** [Crossref, Bilican](https://api.crossref.org/works/10.1016/j.eswa.2024.124408); [Crossref, van Twiller](https://api.crossref.org/works/10.1016/j.ejor.2023.12.018); [EconPapers, van Twiller](https://econpapers.repec.org/RePEc:eee:ejores:v:317:y:2024:i:3:p:841-857); [SMDG, guías de BAPLIE y MOVINS](https://smdg.org/documents/edifact-migs-message-implementation-guidelines/ship-planning); [SMDG, actas de la plenaria 68](https://smdg.org/wp-content/uploads/Plenary_Meetings/68th_meeting/Presentations/SMDG68-Plenary-and-process-Minutes-meetings-final.pdf).
