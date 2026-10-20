# T-112 · Aceptación cruzada del cierre nuevo

Capitán Codex · 20-oct-2026 · **Dictamen: ACEPTADA con observaciones.**

1. Suite **1063/1063**, sin omitidas; analyze **0**; corpus **157/157** y datos/codec iguales al padre.
2. Censos repetidos: idioma **100 %**, Material 3 **0 excepciones**, mensajes **218/218** y lectura **12/12** con segmento; muestra independiente **20/20**.
3. Windows, Web en navegador integrado y Honor a 360 dp/letra 1.0 comprobados con t112acc. Se conservan la observación visual de 10.94 y un incidente del motor Windows bajo instrumentación de accesibilidad; no se pide cambiar lib/.

## Base y aislamiento

- Se leyeron AGENTS.md, la ficha T-112 y las decisiones 10.88, 10.93, 10.94 y 10.95 de SPRINT-3.md, además de los informes T112-RESULTADOS y T98-CENSOS-RESULTADOS.
- Historial requerido, verificado antes de trabajar: `33404a5 (HEAD -> sprint-3, tag: sprint3-cierre-2, origin/sprint-3)`, `4f80ac3`, `6a2962d`, `b1a0b5f`. Se cumple la condición de arranque.
- Producto aceptado: `b1a0b5f`; cierre: `33404a5`; referencia anterior: `cdab56b`. El diff entre T-112 y el cierre no cambia lib/, test/ ni pubspec.*.
- Copias creadas mediante `git archive`, sin índice, checkout, worktree ni Git de escritura: `%TEMP%\t112acc-33404a5\cierre` y `padre`. No se incorporó trabajo sin commit de T-98 o T-99.
- Semáforo ocupado durante la aceptación. Un comando Flutter a la vez. No se compiló en los directorios compartidos build/windows, build/web o build/app.
- No se inicializó Firebase, no hubo inicio de sesión ni publicaciones. No se usaron PRUEBA T-105, demo17 ni el almacén real. La ventana anterior de T-98 quedó sin usar.

## Revisión del cambio

Se revisó el diff completo de `b1a0b5f^..b1a0b5f` contra la ficha. Cumple el alcance: traducción de textos y valores del CSV, localización de Flutter y colores del buscador. Los cambios auxiliares de código producen los mensajes pedidos; no alteran las decisiones de negocio ni el contenido guardado.

| Punto | Comprobación independiente |
|---|---|
| Localización | app.dart declara `es`, supportedLocales y GlobalMaterialLocalizations.delegates. pubspec agrega solo flutter_localizations SDK; el lock añade ese paquete e intl 0.20.2 transitiva, sin mover versiones existentes. |
| M001 / M006 | El formateador recibe el nombre de la operación; distingue fallo interno y fallo de lectura/escritura local. El llamador de la versión no admitida conserva su mensaje específico. |
| M004 | El lector anota fase/segmento y orden para envolver fallos inesperados en BaplieParsingException. Los BaplieParsingException existentes se relanzan. El repositorio conserva segmento y orden y registra el detalle; el formateador los presenta en español. Es instrumentación del error autorizada por la ficha. |
| M050 | `_sourceName` traduce los tres tipos de fuente solo en el mensaje. `kind.wire` permanece en la identidad y el formato de las fuentes. |
| M217 / M218 | Los cinco catch de arrastre, carga, oficina y solicitudes, más el estado de error de Tapas, usan vesselErrorMessage. Se conserva el StateError escrito para el usuario; desaparece la conversión técnica no controlada en esos seis sitios. |
| Buscador | Sustituye red/cyan/green/orange/yellow por pares de colorScheme; conserva las condiciones de categoría, sus iconos y la búsqueda. |
| UNKNOWN | La constante mantiene exactamente `UNKNOWN`; voyageNumberLabel traduce solo lo mostrado. Los nombres de archivo siguen usando el número guardado. |
| Persistencia | Codec, claves, reglas, IDs existentes, generación de UUID y serialización JSON no cambian. Los detalles persistidos de avisos BAPLIE y del listado se conservan; las acciones se agregan al mostrarlos. |
| Protegidos | main.dart y los dos congelados son idénticos al padre. No se modificaron opciones Firebase. Los 137 Dart de lib/ en la copia tienen la misma huella normalizada que el árbol y el cierre. |

No hay lector del CSV exportado en el producto. La selección de pestañas conserva sus índices. No apareció un caso que exigiera detenerse según la ficha. El nuevo código `unexpected_segment` agrega contexto al fallo inesperado; no renombra códigos anteriores.

## Las 20 actualizaciones de pruebas

Son **20 archivos existentes**, no veinte casos individuales. Se revisaron sus diff y se contaron las declaraciones test/testWidgets, expect/expectLater y skip antes/después: sin pérdida de pruebas ni aserciones y sin nuevos skip. Esto apoya la lectura manual; el conteo por sí solo no prueba equivalencia.

| Archivo bajo test/ | Cambio observado |
|---|---|
| baplie_parser_test.dart | Expectativa exacta de posición en español. |
| support/t91_toolbar_support.dart | Localizador de pestaña Plano. |
| t103_smdg15_test.dart | Auxiliar `_declared` para construir el texto UNH esperado; conserva código, rechazo, estado previo y ausencia de escritura. |
| t104_text_test.dart | Texto de pestaña; mantiene las comprobaciones de ajuste. |
| t105_drag_widget_test.dart | Mensaje exacto de autorización; mantiene interacción y diálogo. |
| t105_preview_test.dart | Mensaje; mantiene plan y movimientos sin mutación. |
| t106_messages_test.dart | Mensajes completos con acción; mismas entradas y reglas. |
| t106_plan_widget_test.dart | Localizador BAHÍA y rechazo del intercambio; mismas aserciones. |
| t107_tabs_test.dart | Texto Plano en las rutas del gesto; misma matriz. |
| t107_texts_test.dart | Constantes de sufijos para causas y acciones; mismos casos y expectativas exactas. |
| t110_bays_test.dart | Chips BAHÍA; mantiene conteo de bahías. |
| t56_socket_ranges_test.dart | Etiquetas y errores; mantiene rangos, tomas y persistencia. |
| t73_export_list_page_test.dart | Mensaje de plan sin confirmar; mantiene botón ausente. |
| t74_loading_plan_test.dart | `contains('Elige')` pasa a una frase más específica del contrato; conserva las aserciones de no guardar. |
| t79_cloud_page_test.dart | Estados con causa y acción; conserva el estado y contadores esperados. |
| t82_departure_widget_test.dart | Busca el texto español; mantiene la ausencia de exportación. |
| t83_hatch_covers_test.dart | Añade dragUntilVisible por la mayor altura del error; no elimina comprobaciones ni cambia el escenario. |
| t90_theme_test.dart | Prefijo nuevo de error del almacén; mantiene el tema anterior. |
| vessel_geometry_page_test.dart | Mensajes nuevos; mantiene límites y estado del botón. |
| vessel_profile_view_test.dart | Localizadores BAHÍA; mismas selecciones y reapertura. |

No se aflojó una comprobación. La afirmación «solo texto» requiere la precisión de los auxiliares de texto y el desplazamiento añadido en T-83. Los cuatro archivos nuevos aportan 16 pruebas: 1047 + 16 = 1063.

## Ejecución independiente en la copia limpia

Antes de agregar el banco de clientes se ejecutaron pub get offline, suite y analyze. Los resultados se obtienen del protocolo JSON de Flutter, contando solo testDone no ocultos, no cargas ni setUpAll/tearDownAll.

| Validación | Resultado |
|---|---|
| Suite | **1063/1063**, cero fallas, cero omitidas. |
| flutter analyze | **0 incidencias**. |
| Corpus | **36 instrumentos, 157/157**, cero fallas, cero omitidas. Se excluyen los cuatro cotejos y t98_estandares_test.dart. |
| T108, contra referencia propia de cdab56b | **10/10**. Precisión frente al informe de implementación: su hash `_stable` excluye id y readNotices; no demuestra por sí solo identidad de los avisos. Los otros cotejos cubren registros y avisos. |
| T110 | **10/10**: datos, geometría y formato del codec iguales, incluidos los avisos guardados. |
| T110acc | **13/13 casos** dentro de una prueba: sintéticos ACC1–3 y diez archivos; bahías, estadísticas, registro local y publicado iguales. |
| T111acc | **192/192 objetos JSON idénticos**, campo por campo, incluidas huellas RGBA. La invocación comparativa devuelve exit 1 por sus 48 mensajes ACC2: exige el plural anterior a T-111 en la referencia. cdab56b ya tiene el singular. No se alteró ni se silenció esa aserción; se conserva el fallo crudo y el cotejo directo. |

Los datos reales permanecieron fuera del repositorio. Los instrumentos usan TEMP para referencias y almacenes. Las exclusiones de UUID aleatorios son las de los instrumentos versionados; no se reinterpretan como diferencias de producto.

## Censos repetidos y control independiente

Se corrió el t112_censos.py archivado con los cinco tool/t98c_* de la copia, usando `--antes` sobre cdab56b. No se modificó ninguno. Las decisiones trasladadas por línea y las nuevas decisiones explícitas no quedaron pendientes.

| Censo | Resultado repetido |
|---|---|
| Idioma | **1790 visibles: 1657 español y 133 sin idioma; 0 inglés y 0 mixtas**. Se conservan las dos lecturas del censo para siglas, nombres y unidades: 100 % en todos sus alcances. |
| Flutter | 20 grupos en español; localización ejercitada por la suite y Atrás comprobado en clientes. |
| Material 3 | **237 controles, 12 exclusiones y 0 excepciones**. La rejilla y las tarjetas/gráficas no interactivas siguen fuera del denominador, según el método original; no es un certificado de todos los colores de lib/. |
| Mensajes | **218/218** con causa y acción según el inventario; **12/12** de lectura con segmento; 29 envolturas. |

Los juicios semánticos del censo están declarados en una tabla; ejecutar el script confirma correspondencia con el código y conteos, no vuelve a juzgar el significado. Por eso hice el control adicional pedido: `random.Random(11220261020).sample(filas M001..M218, 20)`, sin reemplazos ni selección por resultado. Se abrieron los puntos indicados, sus condiciones y las funciones que completan el texto.

| ID | Causa constatada | Acción constatada | Dictamen |
|---|---|---|---|
| M151 | Plan sin un único BAPLIE con UNB/UNH | Volver a importar el plan | PASA |
| M026 | Error interno al guardar tema o fallo del almacén | Reintentar y reiniciar si se repite | PASA |
| M195 | Aprobación distinta de la solicitud | Revisar bandeja de la oficina | PASA |
| M217 | Error interno de la operación nombrada o fallo local | Reintentar y reiniciar si se repite | PASA |
| M108 | Carga que exige motivo escrito | Escribirlo para registrar | PASA |
| M100 | Escala sin operación guardada | Abrir plan y confirmar escala | PASA |
| M214 | Contenedor en reserva de otro grupo | Deshacer desde el detalle de celda | PASA |
| M019 | Edición que intenta cambiar identidad | Abrir perfil correcto | PASA |
| M014 | Nombre insuficiente para distinguir buques | Pedir exportación con IMO/indicativo | PASA |
| M211 | Asignación de una reserva cancelada | Deshacer registro desde celda | PASA |
| M116 | Peso previsto excede límite del perfil | Escribir motivo o elegir otra pila | PASA |
| M017 | No hay viaje para confirmar | Cargar BAPLIE | PASA |
| M131 | No hay plan de carga confirmado | Abrirlo y confirmar escala | PASA |
| M193 | Rechazo sin solicitud | Revisar bandeja de la oficina | PASA |
| M083 | Requisito de motivo de hasta 300 caracteres | Escribirlo | PASA |
| M129 | Archivo vacío o lectura sin bytes | Volver a elegir Excel | PASA |
| M096 | Colisión con otro objeto | Elegir otra celda | PASA |
| M070 | Anulación que exige motivo | Escribirlo | PASA |
| M165 | No hay códigos pegados | Pegar al menos uno | PASA |
| M102 | Corrección sin movimiento vigente o motivo | Elegir carga vigente y escribir motivo | PASA |

**Resultado propio: 20/20.** Las causas de M026/M217 son generales: nombran error interno o almacén, no la causa técnica raíz. M129 enumera alternativas, no distingue por qué llegaron cero bytes. M083/M070 explicitan el requisito incumplido. Esto cumple la lectura de causa operativa y acción del censo; no prueba que el usuario pueda diagnosticar internamente una excepción. La muestra no sustituye una auditoría semántica exhaustiva de las 218 filas.

## Clientes

**Banco aislado.** tool/t112acc_preparar_clientes.py toma el banco versionado tool/t112_main.dart de la copia y genera allí tool/t112acc_main.dart. Cambia el namespace a `t112acc` y la identidad Android a `gt.cmartinez.baystream.t112acc`; conserva los 137 archivos de lib/. El BAPLIE es el ensayo sintético de Timonel. NoCloud rechaza toda llamada remota y se usan sesión local y sincronización local.

Dos botones exclusivos del banco permiten obtener evidencia sin selectores externos: uno envía un UNH SMDG30 al VoyageNotifier/lector/repositorio reales y muestra el error devuelto; el otro ejecuta ExportService.serializeCsv, guarda sus bytes y los muestra. Por tanto, el diálogo de ensayo no es una pantalla nueva del producto. En Windows se comprobó además el flujo del menú **Exportar viaje → CSV → Guardar**, cuyo archivo es idéntico byte a byte al del botón de ensayo.

| Cliente | Ejecución y almacén usado | Comprobaciones observadas |
|---|---|---|
| Windows | Release de la copia, lanzada con explorer.exe. **`%TEMP%\t112acc-33404a5\windows-store`**, archivos t112acc_*.hive; ninguna lectura ni escritura en el almacén real. Ventana 1267×714 px, incluido el marco. | Pestaña Plano, detalle **Bahía 002, Fila 01, Nivel 82**, tooltip **Atrás** en Parámetros, rechazo UNH con causa/acción y CSV en español. El selector conserva como nombre propuesto **BayStream_BUQUE T112_UNKNOWN.csv**; se guardó en TEMP con nombre de ensayo. |
| Web | Release local en **http://127.0.0.1:8112/**, pestaña visible del **navegador integrado**; IndexedDB de ese origen, namespace t112acc. No se usó el sitio publicado. | Plano y leyenda, posición completa en el detalle, botón semántico Atrás en Parámetros, rechazo UNH y CSV del exportador en español. También se invocó CSV desde el menú del producto; la verificación de contenido usa los bytes que el banco guardó con ese mismo serializador. |
| Honor NAA-LX3 | APK **profile/AOT** con identidad propia, firmado para depuración. **720×1600 px, densidad 320: 360×800 dp; font_scale 1.0**, sin override de tamaño/densidad. Almacén **`/data/user/0/gt.cmartinez.baystream.t112acc/files/vessel_store/t112acc_*`**. | Plano, posición completa en el detalle, tooltip Atrás en Recientes, rechazo UNH con segmento y acción, CSV español y leyenda horizontal, incluido **Refrigerado** entero al desplazar. |

El texto del rechazo real en los tres clientes es: «Versión BAPLIE no admitida: la cabecera UNH declara BAPLIE:D:95B:UN:SMDG30. BayStream lee la familia 2.x (SMDG20, SMDG21 y SMDG22). Pide una exportación compatible.», precedido por el nombre del archivo de ensayo.

**CSV, comprobado leyendo los archivos de los tres clientes:** 24 columnas en el mismo orden, seis contenedores, estados lleno/vacío y banderas sí/no. La prueba nueva de la suite cubre además desconocido. Encabezados y valores categóricos coinciden; los valores numéricos también. No se afirma identidad binaria entre plataformas: los UUID son nuevos y la Web escribe siete números sin el `.0` que conservan Windows/Android (seis pesos y una temperatura). El método preexistente que convierte esos valores a cadena no cambió en T-112. El CSV guardado por el menú Windows tiene **1047 bytes** y coincide con la serialización del mismo viaje de esa instancia.

**Observación visual ya decidida en 10.94:** a 360 dp, Refrigerado queda parcialmente fuera del borde inicial de la leyenda, pero se lee completo al desplazar; también se ve truncado el título largo de la bahía y el resumen compacto. No se alteró la maqueta ni se reabrió la decisión del Sprint 4. Esta aceptación no repite letra 1.45: la solicitud actual pide 1.0; la evidencia de 1.45 de Timonel permanece en su informe.

**Incidente Windows, sin ocultarlo:** la primera variante de mi banco llamaba ensureSemantics también en Windows y la inspeccioné con UI Automation. Tras cerrar un diálogo de ensayo, el PID 33268 terminó: evento Application Error 1000, flutter_windows.dll, excepción **0xc0000005**, desplazamiento **0x37d00**. No ocurrió en los otros clientes. Retiré la activación forzada en Windows **solo del banco**, recompilé y recorrí ventanas mediante capturas y entradas, sin pedir el árbol de accesibilidad Flutter durante el recorrido. Se comprobaron CSV, Parámetros/Atrás, detalle y apertura/cierre del mismo rechazo; el proceso final siguió vivo y el registro mantuvo **un solo incidente** antes del cierre normal. No hay una comparación del motor con el padre que permita atribuir la causa: queda como observación de instrumentación/motor, no como causa demostrada ni corrección de producto. No se afirma que el primer banco pasó sin fallos. La fuente final del banco queda en la evidencia; la variante inicial se reconstruyó de manera determinista desde el generador y su único cambio de activación de semántica, no es una copia registrada antes de compilar.

Los XML del Honor se capturaron en memoria con `adb exec-out uiautomator dump /dev/tty`, se sanitizaron antes de guardarse y solo se tomaron capturas dentro del paquete de ensayo. La ayuda Atrás se capturó inmediatamente tras pulsación prolongada sobre su flecha. No se abrieron selectores de cuentas ni se capturaron diálogos con cuentas.

El Honor queda con **font_scale 1.0, densidad física 320 y sin override**. Se agregó únicamente el paquete t112acc respecto de la lista inicial y quedó detenido. La app Windows de esta aceptación y el servidor local se cerraron al finalizar; no se cerró la app anterior de T-98.

## Dictamen y continuidad de T-98

**ACEPTADA con observaciones.** Cumple los cambios y las comprobaciones solicitadas; no se encontró una alteración de datos, reglas, codec o identificadores que invalide la conservación de filas autorizada en 10.93. Las observaciones son la presentación compacta aceptada en 10.94, el supuesto histórico de T111acc y el incidente de motor del primer banco Windows. No se solicita una corrección en lib/ ni un cierre nuevo.

Para T-98, este informe aporta el control independiente de los censos sobre sprint3-cierre-2 y sus límites: 20/20 de la muestra, sin convertirla en una revisión manual de las 218 filas. T-98 continúa en su chat sobre **33404a5**, con las repeticiones de recuperación y conformidad exigidas por 10.93. No se modificó su informe ni ninguno de sus instrumentos; no se iniciaron aquí nuevas mediciones de T-98.

## Reproducción y evidencia

Los scripts Python usan únicamente la biblioteca estándar. Los cuatro pasan `python -I -m py_compile`. El banco de clientes pasó su analyze específico; el primer borrador tenía un import redundante que se quitó antes de compilar. La compilación Windows emitió la advertencia MSB8029 por usar TEMP; el APK conserva las notas de Java del plugin Firestore. No se cambiaron esos paquetes ni se agregaron supresiones.

```powershell
# preparar exige una carpeta TEMP nueva: se niega a sobrescribir la existente.
python -I tool/t112acc_verificar.py preparar
python -I tool/t112acc_verificar.py pruebas
python -I tool/t112acc_verificar.py cotejos
python -I "$env:TEMP/t112acc-33404a5/cierre/tool/t112_censos.py" "$env:TEMP/t112acc-33404a5/cierre" "$env:TEMP/t112acc-33404a5/censos" --antes "$env:TEMP/t112acc-33404a5/padre"
python -I tool/t112acc_auditoria.py
python -I tool/t112acc_preparar_clientes.py
python -I tool/t112acc_verificar.py clientes
```

Los comandos de Flutter del banco se ejecutaron secuencialmente. El script conserva el exit 1 crudo de T111acc y solo admite su excepción histórica si los 192 objetos completos coinciden. El namespace de aceptación está en el banco generado, no en lib/.

Evidencias principales bajo build/t112acc/:

- registros/suite.log, analyze.log y corpus.log: salida cruda independiente.
- t108/, t110/, t110acc/ y t111acc/: referencias propias del padre y resultados del cierre.
- censos/: CSV y resumen repetidos; muestra-independiente.json: semilla, selección, juicios propios y fragmentos/ubicaciones del código.
- pruebas-actualizadas.json y producto-huellas.json: conteos por archivo y huellas de los 137 Dart.
- windows/, web/ y honor/: capturas, error real y CSV; windows/incidente-motor.json e incidentes-final.json conservan el incidente.
- csv-verificacion.json y binarios.json: comparación de los archivos producidos y huellas/tamaños de los artefactos compilados.
- arbol-antes.json y arbol-cambios-durante.json: la única ruta previamente existente que cambió durante la comprobación fue mi propio tool/t112acc_verificar.py, creado antes de tomar esa foto; los trabajos T-98/T-99 presentes se conservaron.

## Archivos de esta aceptación

- docs/T112-ACEPTACION-RESULTADOS.md
- tool/t112acc_verificar.py
- tool/t112acc_preparar_clientes.py
- tool/t112acc_auditoria.py
- tool/t112acc_honor.py

**pubspec.yaml y pubspec.lock: sin cambios en esta aceptación.** En el commit aceptado sí cambian, exclusivamente por la localización autorizada. lib/, test/ y los instrumentos ajenos se trataron como solo lectura.

Evidencia local en build/t112acc/ (ignorada por `/build/`): registros crudos, censos, cotejos, huellas del producto, conteos de pruebas y muestra independiente con fuentes y líneas. Las copias y los binarios quedan bajo TEMP. No se propone forzar build/ a Git.

## Tres líneas para Carlos

Aceptación independiente de T-112 sobre sprint3-cierre-2, sin cambios de producto.
Suite, analyze, corpus y censos verificados; muestra aleatoria 20/20 y tres clientes comprobados.
Se conservan observaciones de presentación, instrumento T111acc y motor Windows; T-98 continúa en su propio chat.

## Mensaje para Yov

Yov: T-112 (b1a0b5f) queda **ACEPTADA con observaciones** sobre sprint3-cierre-2 (33404a5). Repetí suite 1063/1063 sin omitidas, analyze 0, corpus 157/157 y cotejos propios contra cdab56b: datos y codec iguales. T111acc mantiene su exit 1 por el plural histórico de 48 ACC2; los 192 JSON son idénticos. Censos: idioma 100 %, Material 3 sin excepciones, mensajes 218/218 y lectura 12/12; muestra independiente semilla 11220261020, 20/20. Windows, navegador integrado y Honor 360 dp/letra 1.0 comprobados con t112acc. Conservo lo visual de 10.94 y declaro un cierre de flutter_windows.dll en el primer banco con accesibilidad forzada; el recorrido final sin esa instrumentación no lo repitió. No pido tocar lib/ ni otro cierre. Informe: docs/T112-ACEPTACION-RESULTADOS.md. T-98 sigue en su chat sobre 33404a5; su trabajo y el de T-99 quedaron intactos. SEMÁFORO: libre.

## Git: solo Carlos ejecuta

```powershell
git add -- docs/T112-ACEPTACION-RESULTADOS.md
git add -- tool/t112acc_verificar.py
git add -- tool/t112acc_preparar_clientes.py
git add -- tool/t112acc_auditoria.py
git add -- tool/t112acc_honor.py
git commit -m "Sprint 3: acepta T-112 con observaciones"
git push
```
