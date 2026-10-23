# BayStream · Aceptación de la candidata del piloto (10.28)

**Dictamen: NO PASA.** Capitán Codex, 23-oct-2026, Guatemala. Candidata `e78035d`, comparada contra `25b8cf7`. El recorrido principal funciona en Windows y Web, pero Atrás en Android falla al coincidir con un aviso de movimiento. El fallo se reprodujo dos veces con una prueba adicional y debe corregirse antes del piloto con COMAR del 25 o 26-oct.

Trabajo realizado desde `C:\Proyectos\baystream-qa-r4`. Evidencia en `build/t114-candidata-aceptacion/`. No se corrigió código. No se ejecutaron escrituras de Git ni `git status`; tampoco firma, publicación, inicio de sesión, acceso a Firebase, Honor o emulador. La compilación de producción recibió exclusivamente `--dart-define-from-file`; no se abrió el archivo privado. No se leyó ni modificó `android/key.properties`.

Se leyeron AGENTS.md; SPRINT-4.md, restricciones y decisiones 10.20–10.28; DESIGN.md 8, 10 y 13; la sección de la candidata de REDISENO-RESULTADOS; LISTA-PILOTO; CIERRE-DESPLIEGUE y las restricciones y decisiones 10.111–10.113 de SPRINT-3. Se aplicaron las skills flutter-ui y computer-use. Timonel estaba detenido y Carlos autorizó Flutter.

**H1 · Prioridad alta, bloquea la aceptación: Atrás usa la cola de avisos como reloj.**

En `lib/features/vessel/presentation/widgets/navegacion_del_viaje.dart:178`, `_aviso != null` permite salir. El primer toque guarda inmediatamente el controlador devuelto por `showSnackBar`, aunque haya otro aviso mostrándose; solo lo olvida cuando ese controlador termina. Por tanto, los 2 s de `duration` no son una ventana independiente contada desde el primer toque.

Reproducción, con el notifier del producto, el almacén temporal de las pruebas y plataforma Android:

1. Abrir y publicar el viaje sintético.
2. Mostrar un SnackBar de 6 s, equivalente al aviso de descarga del muelle.
3. Pulsar Atrás mediante `handlePopRoute`.
4. Esperar 3 s y pulsar Atrás otra vez.

**Esperado:** el viaje sigue publicado; el segundo toque, fuera de los 2 s, inicia otra advertencia. **Observado:** `pendiente.close()` en la línea 181 intenta cerrar un controlador que sigue detrás del primer aviso. Flutter lanza `_snackBars.first == controller` desde `scaffold.dart:340`. La prueba adicional falla en dos ejecuciones: `atras-cola-test.txt` y `atras-cola-repeticion.txt`, ambas con salida 1. Las nueve pruebas entregadas no incluyen un aviso previo en esa cola.

La aserción observada es del modo de pruebas. **Inferencia para Release, comprobada contra el SDK local instalado:** la clausura del controlador llama a `hideCurrentSnackBar()` y después el código de BayStream llama a `onVolverAlInicio()`. Al omitirse la aserción, esta ruta puede cerrar el viaje con dos toques separados por más de 2 s y ocultar el aviso de movimiento. No afirmo haber ejecutado este caso en un Android Release: Carlos prohibió tocar el emulador y el Honor.

Propuesta para la corrección: contar la ventana desde el primer toque, hacer visible la advertencia sin dejarla detrás de los avisos de registro y resolver su cierre sin actuar sobre un controlador que no es el primero de la cola. Conservar Deshacer y agregar el caso de aviso previo de 4/6 s, dos toques dentro de 2 s y dos separados por más de 2 s, sin excepciones. La prueba reproducible está en `atras-cola_test.dart.txt`; `preparar_prueba_atras.py` la genera en TEMP a partir de las nueve pruebas existentes, sin alterar `test/`.

```powershell
python build/t114-candidata-aceptacion/preparar_prueba_atras.py
flutter test --no-pub "$env:TEMP/t114-candidata-aceptacion/atras-cola_test.dart" --plain-name 'QA: la ventana' --reporter expanded
```

**H2 · Interrupción del trabajo del muelle: corregir los avisos antes del piloto.**

Sí estorban lo suficiente para corregirlos. El de 4 s tapa «Confirmar e importar»: ocurre una vez al preparar el listado y la propia lista pide esperar. El de 6 s tapa «Acciones», «OR / últimos dígitos» y el pie de la hoja de vacíos: vuelve a aparecer con cada registro y obliga a pausar el siguiente contenedor o cambiar de recorrido. Las capturas de emulador p14, p15, p18 y p19 muestran esa obstrucción; p20 deja ver los controles al desaparecer el aviso. En Windows el conductor la evita mediante `_sinAvisos()` antes de confirmar/importar y de continuar con vacíos. Por eso un recorrido automático completo no acredita que el ritmo continuo del muelle esté resuelto.

Propuesta: ubicar el aviso fuera de la franja de operación y del pie de las hojas, manteniendo Deshacer disponible durante su plazo. Repetir dos cargas consecutivas por OR sin esperar a que desaparezca el aviso. Esta conclusión es de interacción y geometría observada; no es una medición inventada de productividad.

**Comprobación de los ocho puntos del encargo.**

| Punto | Resultado y evidencia |
|---|---|
| 1. Alcance | **Pasa.** `git diff --stat 25b8cf7..HEAD`: 158 archivos, 2474 inserciones y 17 eliminaciones. Ninguno en domain/, data/, main.dart o los congelados. `pubspec.yaml` cambia exclusivamente `version: 3.1.0+4` y `msix_version: 3.1.0.0`; `pubspec.lock` idéntico. `alcance-stat.txt`, `alcance-rutas.txt`, `pruebas-pubspec.diff`, `resumen-estatico.json`. |
| 2. Suite y análisis | **Suite entregada: 1329/1329, cero fallos y omitidas**, 2 min 42 s, después de `flutter pub get` satisfactorio. El análisis de `lib test tool integration_test` da cero; también `flutter analyze --no-pub` completo en el banco limpio da «No issues found». La prueba adicional H1 falla; no pertenece al conteo de la suite entregada. Logs y salidas de cada comando conservados. |
| 3. Correcciones | Las nueve pruebas existentes de Atrás pasan: Más, detalle inferior, zoom y su registro, detalle lateral, previo y diálogo, publicado/doble toque y vencimiento, cierre inmediato, inicio y Windows. El caso combinado H1 impide aceptar Atrás globalmente. Chips: pruebas de FilterChip, ChoiceChip e InputChip en cuatro temas y contraste nocturno de comparación en verde. «Re‑est.» conserva icono y etiqueta completa de reestiba en la celda; el formateador de descarga sigue diciendo «re‑estiba». `loadingOperationProvider` comprueba `ref.mounted` después de sus cuatro esperas previas a leer providers; el cierre temprano de las pruebas pasa. |
| 4. Recorrido | **Pasa el núcleo repetido**, con las salvedades H1/H2. Windows: 26 capturas, cero errores Flutter, textos fuera o esperas vencidas. Web: 27 capturas y descarga. Ambos: abrir en previo, confirmar perfil/escala, importar listado, llegada publicada, Baja, otra Baja y Deshacer, Paso/reestiba, vacío por OR, otro vacío y Deshacer, Avance, En vivo, alertas y salida/comparación. Windows guardó además mediante el diálogo nativo. Ambas salidas de 7849 bytes fueron releídas por `BaplieParserService`: 58 contenedores, BUQUE MANUAL/M100, SMDG22. `windows-recorrido/`, `web-recorrido/`, `windows-guardado.png`, `salidas-releidas.json`. |
| 5. Avisos | **Requiere corrección antes del piloto**, por H2 y su interacción con H1. El tramo que registra un contenedor tras otro no debe depender de esperar 6 s para recuperar controles. |
| 6. Pantallas sin rediseñar | Suite actual: las tres configuraciones pasan e incluyen ausencia de spinner y de excepciones. Revisión visual de los 54 PNG existentes, más sus 57 registros: hay límites y tres capturas inconclusas que se detallan abajo. Los dos falsos positivos de contraste se verificaron por píxeles. |
| 7. Versiones/publicación | Versiones superiores a las publicadas en 10.113; mezcla 4.1 correcta con los supuestos de las referencias locales. Compilación Web de producción, Auth, T-92 y uso sin red satisfactorios. **Observación documental:** 4.5 omite el proyecto explícito en su comando de retorno a v3.0. No se firma ni publica. |
| 8. Auditoría/censos | Auditoría `--all`: **17 críticos, 248 avisos y 20 informativos heredados**, iguales a la base; cero hallazgos nuevos por regla/archivo y ninguno nuevo en líneas tocadas. No es cero absoluto de críticos en todo el producto. Censos: 1951 visibles, 1820 español + 131 siglas/nombres/unidades, cero inglés; M3 250 incluidos/7 excluidos/3 excepciones heredadas; 217/217 mensajes con causa y acción, 12/12 errores de parseo con segmento. |

**Aserciones de las pruebas modificadas.** Se comparó el antes y después completo, no solo el conteo:

| Archivo | `expect` antes/después | Evaluación |
|---|---:|---|
| `test/t114_componentes_test.dart` | 71/71 | El rótulo completo se sustituye por la abreviatura; se conserva la comprobación del icono. |
| `test/t75_discharge_test.dart` | 54/54 | Cambia el rótulo de la celda; la aserción de tabla se restringe al DataTable para distinguirla de la celda situada detrás. Conserva resumen, movimiento y ausencia de excepción. |
| `test/t93_msix_config_test.dart` | 27/27 | Reemplaza la versión por 3.1.0.0; conserva identidad, publisher, capacidades y demás controles. |

Ninguna aserción perdida sin reemplazo. `aserciones-conteo.json` y `pruebas-pubspec.diff` permiten contrastarlo.

**Precisión del análisis y del banco.** El primer `flutter analyze --no-pub` en la raíz recogió fuentes de instrumentos bajo `build/`, incluidos los de aceptaciones anteriores y la copia del banco que yo estaba preparando: dio 88 incidencias. Es un resultado real conservado en `flutter-analyze.txt`, no un cero. Moví únicamente mi banco a `%TEMP%\t114-candidata-aceptacion\banco`, sin tocar evidencia ajena. El análisis explícito de las cuatro carpetas de fuentes en la copia de Carlos dio cero (`flutter-analyze-fuentes.txt`), y el análisis completo sin argumentos en el banco limpio dio cero (`flutter-analyze-banco-limpio.txt`). Los 179 archivos de lib son idénticos byte a byte, según `banco-manifiesto.json`; el banco incorpora las mismas pruebas e instrumentos. El pubspec del banco solo agrega los tres assets sintéticos para el recorrido.

El banco r4 anterior de Timonel difería en dos archivos finales de navegación/zoom (`banco-comparacion.json`). No lo usé para emitir el recorrido repetido: compilé un banco nuevo desde esta candidata. Windows y Web usan namespace r4, sin Firebase. Windows usa exclusivamente `%TEMP%\t114-candidata-aceptacion\store-windows`; se lanzó mediante explorer.exe. No abrió el almacén real ni su copia virtualizada del paquete. La reapertura del reciente y el guardado nativo se comprobaron sobre ese mismo almacén temporal. No se midieron RNF ni tiempos de muelle durante esta aceptación.

**Lo que las imágenes sí acreditan y sus límites.** Se inspeccionaron las 132 imágenes entregadas: 26 de Windows, 27 de Web, 25 de emulador y 54 de pantallas. `revision-imagenes.csv` registra cada archivo, SHA-256, lámina y observación.

- Los registros de los recorridos concuerdan con sus estados funcionales. El PNG p22 del emulador demuestra que el plano sigue; no muestra el aviso de 2 s, ya desaparecido. Lo complementan las pruebas y el registro, sin atribuirle una imagen que no contiene. p23 muestra inicio/reciente y p24 reapertura. p25 solo muestra la parte superior de Más: la última opción requiere desplazar.
- **Hay 57 configuraciones, no 57 capturas.** Nube y cuenta se revisó sin capturarla, en las tres configuraciones. No se generaron capturas de cuentas en esta aceptación.
- **Tres capturas antiguas de 360/letra 1.0 no acreditan pantalla terminada:** Perfiles guardados, Viajes recientes y Tapas en la operación muestran un spinner y su registro dice `pumpAndSettle timed out`. La frase «ninguna lanza, 57/57» del informe anterior es más amplia que esa evidencia. La suite actual sí exige que no haya spinner y pasa; también son visibles los contenidos en las otras configuraciones. Conviene sustituir esos tres PNG y corregir su registro.
- El PNG nocturno de Comparar es anterior al arreglo y todavía muestra «Solo con cambios» invisible. Los p25 de los recorridos y la prueba actual acreditan la corrección; conviene actualizar la captura antigua.
- **Dos falsos positivos confirmados:** en «Tapas: sin declarar» y «BUQUE MANUAL · V114», las regiones reales de texto contienen tinta `#10243F` sobre papel `#F5F8FC`, contraste **14.65:1**. Las cajas semánticas citadas por la pauta corresponden a otra altura. `falsos-positivos-pixeles.json` conserva las frecuencias de píxeles de ambos textos. El fallo nocturno de chip sí era real y está corregido.

**Publicación y regreso a v3.0.** La candidata propone Web/Android 3.1.0 (4) y MSIX 3.1.0.0, por encima de Web 3.0.0 (3), AAB 3 y MSIX 3.0.0.0 publicados. 4.2 conserva t93_msix.ps1, huella y validación de firma; 4.3 conserva el AAB sin `--no-pub`; 4.4 conserva el control de caché, Auth, T-92 y publicación exclusiva de Hosting con proyecto explícito. Ningún comando de la lista solicita tocar key.properties.

La corrección de 4.1 evita pasar directamente al master antiguo: en las referencias de esta copia, master=`468a003`, sprint-3=origin/master=`063d2ae`, sprint-4=`e78035d`; ambas relaciones de ascendencia comprobadas devolvieron 0. El bloque es coherente con esos supuestos. Carlos debe detenerlo si sus referencias cambian o Git informa un conflicto; no ejecuté sus operaciones.

**Observación para Yov:** en LISTA-PILOTO.md:189, el comando abreviado del regreso a v3.0 debe conservar `--project baystream-app`, igual que 4.4. Además, para volver a Web 3.0 debe ejecutarse el bloque que falla temprano de 4.4, con la versión anterior, sin convertirlo en una publicación de la candidata seguida de otra publicación. Se conserva la regla de nunca ejecutar `firebase deploy` a secas.

Compilación ejecutada, sin firma ni publicación:

```powershell
flutter build web --release --output=build/qa-r4-web --build-name=3.1.0 --build-number=4 --dart-define-from-file=C:\Proyectos\baystream-privado\firebase-prod.json
dart run tool/t92_verify.dart build/qa-r4-web
```

Resultado: salida 0; version.json 3.1.0/4, Auth presente; T-92 correcto, 57 archivos y 37,995,501 bytes. Persiste el aviso de compilación sobre CupertinoIcons ya documentado; no se añadió una dependencia para ocultarlo. Prueba Web sin red en Chrome visible, contexto nuevo, sin cuenta, externos bloqueados y después `set_offline(true)`: service worker activado y controlador presente; `navigator.onLine=false`, fetch externo fallido, BAPLIE abierto sin red y recarga sin red, cero errores de página. `web-sin-red-validada/resultado.json` y sus dos PNG. El primer ensayo de ese instrumento usó erróneamente APIRequestContext como sonda de red; ese canal no representa el modo sin conexión de la página. Se conserva el intento y se sustituyó la sonda por fetch dentro de la página en la ejecución válida.

**Censos e incidencias de instrumentos.** Los 218 mensajes históricos ya eran 217 en la base aceptada: al retirar la barra T-91 se retiró su aviso de no poder guardar la preferencia (`tool/t112_censos.py:335`). La candidata agrega un texto visible en español; no pierde otro mensaje. La auditoría completa sigue en 17/248/20, con delta vacío (`auditoria-delta.json`); los críticos antiguos de vessel_overview_page pertenecen a las mismas listas existentes, fuera de las líneas cambiadas.

La primera auditoría Python y la primera repetición Web se detuvieron por la codificación cp1252 de la consola al imprimir Unicode. Se repitieron con `PYTHONIOENCODING=utf-8`; la repetición Web válida tiene 27 pasos y salida 0 (`web-recorrido-2-log.txt`). El intento previo quedó conservado. No se atribuyen esos fallos a BayStream. Los errores de compilación del primer montaje de la prueba adicional se corrigieron en el instrumento antes de las dos reproducciones válidas de H1.

**Qué queda para Carlos y Yov.** Corregir H1 y la obstrucción H2 en una tarea nueva de presentación, agregar los casos combinados y repetir la aceptación del muelle. Yov corrige la omisión del proyecto y las afirmaciones/capturas antiguas indicadas. Mantener las comprobaciones reales de cuentas, publicación, unión, sincronización, solicitudes, cola sin red y TalkBack en el ensayo de Carlos: esta aceptación local no las acredita. Si el ensayo falla seriamente, sigue vigente el regreso a v3.0 de 10.28.

**Archivos de esta aceptación.** Único archivo versionable creado: `docs/rediseno/fase3/candidata/aceptacion-codex.md`. No se modificaron lib/, test/, tool/ ni `pubspec.yaml` o `pubspec.lock` del proyecto. La evidencia y los instrumentos de aceptación están bajo `build/t114-candidata-aceptacion/`, ignorado por .gitignore; su inventario exacto y sus huellas están en `evidencia-manifiesto.json`. No se propone forzar build a Git. Los bancos y sus almacenes temporales son exclusivos de esta aceptación.

**Tres líneas.**

La candidata NO PASA: Atrás falla con un aviso previo; los avisos también interrumpen la carga consecutiva del muelle.
Suite entregada 1329/1329, análisis de fuentes y banco limpio en cero; Windows y Web completos, ambas salidas releídas y Web sin red verificada.
Solo se agrega este informe; no cambia código ni pubspec, y no se firma, publica ni toca Firebase o dispositivos.

**Mensaje para Yov.** Yov: Capitán Codex revisó e78035d contra 25b8cf7 en la copia limpia. Dictamen NO PASA por H1: con un SnackBar de movimiento de 6 s, Atrás, espera de 3 s y otro Atrás, se intenta cerrar un controlador en cola y Flutter lanza `_snackBars.first == controller`; dos reproducciones, prueba adicional y logs en build/t114-candidata-aceptacion. La ventana depende del cierre del aviso y no del tiempo desde el toque; en Release esa rama puede sacar al inicio fuera de los 2 s. Las nueve pruebas entregadas pasan, pero no cubren esa cola. También recomiendo corregir antes del piloto los avisos que tapan el pie de operación/vacíos. Lo demás comprobado: 158 archivos y alcance correcto; suite 1329/1329; análisis de fuentes y banco limpio en cero; recorrido Windows 26/Web 27; BAPLIE guardado nativamente en Windows y descargado en Web, ambos releídos con 58 contenedores SMDG22; producción Web 3.1.0(4), Auth, T-92 y sin red correctos. Auditoría heredada 17/248/20 sin nuevos; censos sin inglés y 217/217 mensajes por retirada previa de T-91. La mezcla 4.1 es coherente; falta --project baystream-app en el regreso Web de 4.5. Hay 54 PNG de pantallas para 57 configuraciones, tres con spinner/timeout y uno de contraste anterior al arreglo; suite actual sí pasa. No corregí código ni publiqué. El informe está en docs/rediseno/fase3/candidata/aceptacion-codex.md.

**Git para Carlos, únicamente el informe:**

```powershell
git add -- docs/rediseno/fase3/candidata/aceptacion-codex.md
git commit -m "Sprint 4: aceptacion de candidata del piloto, no pasa por Atras con avisos"
git push
```
