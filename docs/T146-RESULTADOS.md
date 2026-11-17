# T-146 · La 1.0.1, la versión del bloque 1

**Lo hace** Timonel (Claude Code, Claude Opus 5.5, en Alto), en `C:\Proyectos\baystream-rediseno`,
rama `sprint-4`. **Lo acepta** GLM 5.3 Flash en Max (10.137), o quien diga Carlos. **Estado:
fase 1 entregada; ALTO: Yov revisa y Carlos aprueba.** No se tocó `lib/`, `test/`, `tool/`
ni `pubspec.*`: lo único nuevo en el repositorio es este informe. La evidencia está en
`build/t146/` y `build/t145/t146-paso0/`, fuera de Git.

---

## 0. Paso 0

| Comprobación | Resultado | Evidencia |
|---|---|---|
| La punta | `1c40d39` («decision 10.137»), sobre `2ac872b` («integra T-137 y T-145»), que es la mezcla de `d10a83a` (10.136) y `2df2423`. La 10.137 solo cambia `SPRINT-4.md`. `git diff --stat` solo da los cuatro avisos de fin de línea de siempre | — |
| Carriles | Carlos confirmó (23:24) que ninguna otra tarea tiene abiertos `lib/`, `test/` ni `pubspec.*`, y que nadie corría Flutter | — |
| `flutter pub get --offline --enforce-lockfile` | Salida 0, 7 s. `pubspec.yaml` y `pubspec.lock` con la misma huella antes y después | `build/t146/pub-get-01.log`, `pubspec-antes.sha256` |
| `flutter analyze --no-pub`, todo el paquete | **Salida 0, «No issues found!»**, 7.5 s | `build/t146/analyze-01.log` |
| **O-137-1 en la carpeta real:** `dart run tool/t137_instalador.dart --origen C:\Proyectos\proyecto-baystream --variante prueba --salida build/t145/t146-paso0` | Salida 0, 17 s. **`5ef28b613039b81f409b1ebb6e85b4159f45ee54a16451803b47a2f45136cf25`, 18 486 858 bytes**: el mismo de Timonel, Antigravity y la copia en CRLF. «Origen verificado sin cambios», 27 archivos en la carga, 5 fuera, y el aviso conocido de los dos archivos viejos (10.130) | `build/t146/armado-prueba-01.log`, `build/t145/t146-paso0/` |

La Release de `proyecto-baystream` solo se leyó: su `baystream.exe` sigue con la fecha del
3-nov, 21:03. **Un detalle mío:** antes de anunciar el SEMÁFORO corrí `flutter --version`, que
también cuenta (unos segundos, a las 23:25).

---

## 1. Propuesta

### 1.1 La versión

**`pubspec.yaml`, dos líneas:**

| Línea | Antes | Después |
|---|---|---|
| 4 | `version: 1.0.0+9` | `version: 1.0.1+10` |
| 128 | `  msix_version: 1.0.0.0` | `  msix_version: 1.0.1.0` |

`pubspec.lock` no cambia: la versión del paquete raíz no está en él.

**La prueba de T-93 que lo comprueba** es «T-93 msix_config identifica la app con el sujeto del
certificado» (`test/t93_msix_config_test.dart`). Desde la 10.77 no fija el número: lee
`version: x.y.z+n` y exige `msix_version` = `x.y.z.0`. Con las dos líneas de arriba pasa sin
tocarla; si solo cambiara una, falla. No hace falta otra prueba.

**Lo que se ve con 1.0.1+10:**
- Android: `versionName` 1.0.1, `versionCode` 10. El último subido a Play es el 9 (la 1.0.0,
  10.105); el 10 estaba reservado para volver a la 0.4.2, y no se usó (Android no volvió).
  La lista lo comprueba en Play Console antes de compilar (1.6).
- Windows: la MSIX 1.0.1.0; el asistente y Configuración → Aplicaciones, 1.0.1.10 (el recurso
  del `.exe`, como el 1.0.0.9 de hoy).
- La Web: `version.json` con 1.0.1 y 10.

### 1.2 O-144-2 · Los avisos de `analyze` en dos pruebas

**La regla y el código.** `use_build_context_synchronously` está en `analysis_options.yaml`.
Marca un valor de tipo `BuildContext` que se usa después de un `await` en la misma función
`async`. Los cuatro avisos que vio GLM (sus registros en `baystream-qa-r4`, `analyze.log` y
`analyze-bisect-lib.log`):

| Aviso | El código |
|---|---|
| `t112_localization_test.dart:49:35` | `final context = await _pushed(tester);` y después `Localizations.localeOf(context)` |
| `t112_localization_test.dart:50:47` | `MaterialLocalizations.of(context)` |
| `t112_localization_test.dart:67:7` | `showDatePicker(context: context, …)`, en la segunda prueba, con el mismo `await _pushed` |
| `t121_estadisticas_test.dart:574:14` | `await tester.pump();` → `final conFoco = …primaryFocus?.context;` → `expect(conFoco, isNotNull)` y `conFoco!.widget` |

En las dos pruebas el contexto se usa justo después de `pumpAndSettle` o `pump`, con la ruta
montada: no hay riesgo real. Lo que pasa es que la forma del código es la que la regla describe.

**Por qué salen en una copia y no en otra.** Lo investigué con once corridas de `analyze` en
`%TEMP%` (el detalle y el código de las sondas: `build/t146/sondas/SONDAS.md`):
- **Aquí y en una copia limpia de la punta, cero.** También con las dos pruebas en CRLF, con el
  conjunto de archivos de la copia de GLM, con una copia anidada dentro de `build/` de otro
  paquete (como la de GLM) y con la ruta en minúsculas. El SDK es el mismo que el de GLM:
  Dart 3.10.8 de Flutter 3.38.9, `flutter_lints` 6.0.0 y `lints` 6.1.0.
- **En esta máquina la regla corre en `lib/`, pero no en `test/`.** El caso de manual (un
  parámetro `BuildContext` usado después de un `await`) se marca en `lib/` y no en `test/`;
  en el mismo archivo de `test/`, `prefer_final_locals` sí se marca. La forma de `t112` (el
  `await` en la declaración) también se marca en `lib/`.
- **En las corridas de GLM la regla sí corrió en `test/`,** y solo marcó esas cuatro líneas.
  No encontré qué hace que el analizador evalúe esta regla en `test/` en unas corridas y en
  otras no. **No lo adivino:** lo dejo como causa abierta, y el arreglo no depende de ella.

**El oráculo: una forma determinista de ver lo que marcaría la regla.** Copio `test/` y `tool/`
dentro de `lib/zz_oraculo/` de la copia, donde la regla corre siempre, y corro `analyze`:
- en la punta da **exactamente las cuatro líneas de GLM**, las mismas columnas, y ninguna más en
  todo `test/` ni en `tool/` (`oraculo-02-antes.log`). El resto son avisos que salen por mover
  las pruebas a `lib/` (`depend_on_referenced_packages` y los imports de `tool/t124_main.dart`);
- con el cambio de abajo, **cero** (`oraculo-03-despues.log`).

**El cambio.** Las pruebas siguen haciendo las mismas llamadas y comprobando lo mismo; solo
cambia dónde se usa el contexto: en funciones síncronas, sin un `await` entre obtenerlo y
usarlo. Así la regla no tiene nada que marcar, corra o no en `test/`. Sin `// ignore:` ni
cambios en `analysis_options.yaml`.

`test/t112_localization_test.dart`:
- `_pushed` devuelve `_RutaEmpujada`, una clase de una línea con el contexto de la ruta
  (`late BuildContext context`), en vez del `BuildContext` suelto. El constructor de la ruta
  guarda ahí su contexto, como hoy guarda `pushed`.
- Dos funciones síncronas nuevas: `_esperarEspanol(ruta)`, con las ocho comprobaciones de hoy
  (`localeOf` y los siete textos de `MaterialLocalizations`), y `_abrirSelectorDeFecha(ruta)`,
  con la misma llamada a `showDatePicker` y las mismas fechas.
- Las dos pruebas quedan así:

  ```dart
  final ruta = await _pushed(tester);

  _esperarEspanol(ruta);
  // El botón de volver automático ya no dice «Back» (F01 del censo).
  expect(find.byTooltip('Atrás'), findsOneWidget);
  expect(find.byTooltip('Back'), findsNothing);
  ```

  ```dart
  final ruta = await _pushed(tester);

  _abrirSelectorDeFecha(ruta);
  await tester.pumpAndSettle();
  // … las mismas comprobaciones del selector
  ```

`test/t121_estadisticas_test.dart`: las cinco líneas de `conFoco` pasan a una función síncrona,
`_esperarElFocoEn(tester, boton, reason: …)`, con las mismas dos comprobaciones, y la prueba la
llama con `_verTabla` y el mismo `reason`, «el primer Tab enfoca «Ver como tabla»».

El cambio completo, como prototipo, está en `build/t146/prototipo/` (`t112.diff`, `t121.diff`).
**En la copia, las dos pruebas pasan con él: 95 de 95** (`prototipo-pruebas-01.log`).

**Cómo compruebo el cero en las dos carpetas** (fase 2):
1. aquí, `flutter analyze --no-pub` de todo el paquete;
2. una copia limpia nueva en `%TEMP%`: `git -c core.autocrlf=false archive HEAD`, encima los
   archivos que cambió T-146 (con su huella, en un manifiesto) y la entrada de T-124 fuera de
   Git (O-143-3); `pub get --offline --enforce-lockfile` y `analyze` de todo el paquete;
3. **el oráculo en esa copia: cero `use_build_context_synchronously`.** Es lo que de verdad
   prueba el arreglo, porque los puntos 1 y 2 daban cero también antes.

Para que quien acepte lo repita igual, propongo `tool/t146_oraculo.dart` (Dart estándar, sin
paquetes): recibe una copia, se niega a escribir dentro del repositorio, copia `test/` y `tool/`
a `lib/zz_oraculo/`, corre `flutter analyze --no-pub`, cuenta los avisos de la regla por archivo
y escribe un `resumen.json`. Si Carlos prefiere no sumar una herramienta, dejo los comandos en
el informe.

### 1.3 O-144-1 · El resaltado de la búsqueda con espacios

**Qué pasa hoy.** En `container_search_delegate.dart` el buscador ya filtra bien: la matrícula
se compara con `numeroDeContenedor(query)` («bysu 967» → `BYSU967`). Pero el resultado se dibuja
con `normalizedQuery` (`query.toUpperCase().trim()`, que conserva el espacio), y
`_buildHighlightedText` busca «BYSU 967» dentro de `BYSU9672095`: no lo encuentra y dibuja la
matrícula sin resaltar.

**Qué cambia, solo en ese archivo y solo en la presentación.** En `_ContainerSearchResultTile`,
el título (la matrícula) se resalta con `numeroDeContenedor(query)`; el puerto de descarga
(«POD: …») se sigue resaltando con la consulta como hoy. Es una línea, y no toca el filtro, el
dominio ni la lista de resultados.

**Cómo se ve.** Igual que la figura 21 del manual: con «bysu 967», el resultado dice
**`BYSU967`**`2095`, con el tramo en `tertiaryContainer` y negrita. Con «0004», «BYSU9672095» o
un puerto, nada cambia. La etiqueta accesible del título sigue siendo la matrícula entera.

**Las pruebas,** en un archivo nuevo, `test/t146_resaltado_busqueda_test.dart`, con el
contenedor sintético de T-144 (`BYSU 9672095`, GTSTC → PAMIT, naviera LINEA):
1. «bysu 967» resalta `BYSU967`;
2. «BYSU9672095» resalta la matrícula entera (como hoy);
3. «967 2095» resalta `9672095`;
4. con el espacio duro (U+00A0) y con la tabulación entre «bysu» y «967», resalta `BYSU967`;
5. «gtstc» no resalta la matrícula y resalta `GTSTC` en «POD: …» (como hoy);
6. la etiqueta accesible del título es `BYSU9672095`.

Las 1, 3 y 4 fallan contra el código de hoy; las 2, 5 y 6 cuidan que no cambie lo demás.
`DESIGN.md` (17.5, el párrafo de la matrícula) suma: «y resalta la parte que coincide, con o
sin espacios».

**Si Carlos decide dejarlo,** no se toca `lib/`: el manual dice «El número se puede escribir
con o sin espacios; con espacios, el resultado no resalta la parte que coincide», y O-144-1
queda abierta para el frente de usabilidad. La recomendación de Yov y la mía es arreglarlo
aquí: es una línea, con sus pruebas, y el manual queda sin excepción.

### 1.4 El manual

**Propongo un archivo nuevo, `docs/MANUAL-USUARIO-1.0.1.md`,** y dejar el de la 1.0.0 como
está. El de la 1.0.0 es la edición de lo que se publicó el 3-nov y se entregó con los documentos
del 7-nov, que no se corrigen (10.117); el de la 1.0.1 dice lo que hace la 1.0.1. Arranca como
copia del de la 1.0.0, usa las mismas imágenes de `docs/manual-1.0.0/` y solo las que cambian van
en `docs/manual-1.0.1/`. Si Carlos prefiere un solo archivo, aplico los mismos cambios sobre el
de la 1.0.0 y le cambio el título.

**Los pasos que cambian, con el texto de antes y el de después.** Los de T-143 salen de su
sección 7, y los de T-144 de su 2.6, con los textos comprobados en el código.

| Dónde | Antes (1.0.0) | Después (1.0.1) | De |
|---|---|---|---|
| Portada | «Edición de la versión **1.0.0 (9)**, publicada el 3 de noviembre…» | «Edición de la versión **1.0.1 (10)**, publicada el … en los tres clientes.» Y una línea: «Lo nuevo frente a la 1.0.0: los estados de la operación, el aviso del cierre en el muelle, todas las peligrosas, el destino final, las medidas del sobredimensionado, los puertos de la 1.5, las matrículas con espacio y el desinstalador que pide cerrar BayStream.» | — |
| 2.1, el nombre | `BayStream_Setup_1.0.0.9.exe` | `BayStream_Setup_1.0.1.10.exe` | — |
| 2.1, desinstalar | «La confirmación dice que tus datos en `%LOCALAPPDATA%\BayStream` se conservan. Cierra BayStream antes de desinstalar.» | «La confirmación dice que tus datos en `%LOCALAPPDATA%\BayStream` se conservan. Si BayStream está abierta, el desinstalador lo dice: «BayStream está abierta», con «Reintentar» y «Cancelar». Ciérrala y pulsa «Reintentar»; «Cancelar» no quita nada.» | T-145, O-137-8 |
| 2.1, la MSIX | El párrafo de hoy | Depende de 1.5: con la opción C, «Windows tiene dos instaladores de la misma app: el asistente y la MSIX. Si ya tienes la MSIX, actualízala con la MSIX 1.0.1.0; si no tienes ninguno, usa el asistente.» y el párrafo de hoy | 1.5 |
| 2.2, figura 5 | `![Figura 5 · pendiente: la toma Carlos en su teléfono]…` y «*Figura 5. BayStream en la prueba interna de Google Play. (Captura pendiente, la toma Carlos.)*» | `![Figura 5]…` y «*Figura 5. La ficha de BayStream en la prueba interna de Google Play, con «Abrir» y las novedades.*» | 10.122 |
| 2.3, figura 6 | `![Figura 6 · pendiente: la toma Carlos en su navegador]…` y «*Figura 6. La Web de BayStream en Chrome. (Captura pendiente, la toma Carlos.)*» | `![Figura 6]…` y «*Figura 6. La Web de BayStream en Chrome, todavía sin viajes guardados.*» | 10.122 |
| 3.3, paso 7 | Termina en «…«Confirmar y ver el plano» queda apagado.» | Suma: «Si el perfil guardado del buque ya lo tiene resuelto, viene resuelto y lo dice: «Del perfil guardado: …», con el límite o con «No lo tengo». Lo puedes cambiar.» | T-143 |
| 3.3, paso 9 | «…se crea la operación de la escala y el plano queda **«Publicado»**. «Cancelar la carga» vuelve al previo sin guardar nada. **«Publicado» en la cabecera quiere decir confirmado en este equipo**, no que esté en la nube: mientras el chip de la nube diga «Solo este dispositivo», la operación sigue solo aquí. Subirla a la nube es «Publicar operación», en «Nube y cuenta» (7.3), y entonces la operación aparece como «Publicada».» | «…se crea la operación de la escala y la cabecera dice **«Confirmado»**: confirmado en este equipo, todavía no en la nube. «Cancelar la carga» vuelve al previo sin guardar nada. Subirla a la nube es «Publicar operación», en «Nube y cuenta» (7.3); desde entonces la cabecera dice «Publicada».» | T-143 |
| Figura 13 | «*Figura 13. El plano confirmado: «Publicado», la escala GTSTC en la cabecera…*» | «*Figura 13. El plano confirmado: «Confirmado», la escala GTSTC en la cabecera…*» (con la captura nueva, 1.4.1) | T-143 |
| 4.1, la cabecera | «el estado («Publicado» o «Sin confirmar»)» | «el estado («Sin confirmar», «Confirmado», «Publicada» o «Cerrada»)». Con un nombre o un viaje largos, la cabecera puede ir en dos líneas | T-143 |
| 4.3, el detalle | «…el refrigerado con su temperatura o la mercancía peligrosa con su clase, y lo que la escala dice de él…» | «…el refrigerado con su temperatura o la mercancía peligrosa con su clase IMO y su número ONU, y lo que la escala dice de él… Si el contenedor declara varias mercancías peligrosas, el detalle muestra una línea por cada una. Si el archivo trae el destino final, va en la fila «Destino final», tal como lo escribió la naviera. Un contenedor sobredimensionado muestra cuánto sobresale por el frente, atrás, a cada lado y por arriba. La matrícula nunca se corta: si no cabe junto a la naviera, la naviera baja.» | T-144 |
| 5.1, paso 2 | «…La lista se filtra mientras escribes y resalta la parte que coincide. También vale un puerto o una naviera.» | «…La lista se filtra mientras escribes y resalta la parte que coincide. El número se puede escribir con o sin espacios. También vale un puerto o una naviera.» (Si O-144-1 queda abierta: «…con o sin espacios; con espacios, el resultado no resalta la parte que coincide.») | T-144, O-144-1 |
| 5.2, la Lista | «…Si el archivo trae avisos de lectura (pesos revisados, posiciones mal formadas, dígitos de control inválidos, segmentos que faltan)…» | «…«IMO 3 +1» quiere decir clase 3 y una declaración más; el detalle las muestra todas. Si el archivo trae avisos de lectura (pesos revisados, posiciones mal formadas, dígitos de control inválidos, segmentos que faltan, códigos de puerto que no son UN/LOCODE o medidas DIM revisadas)…» y, al final: «Para ver el destino final, los puertos de una BAPLIE 1.5 o las medidas de sobredimensión de un viaje guardado antes de la 1.0.1, vuelve a abrir el archivo.» | T-144 |
| 7.3 | «…el estado pasa a «Publicada» con «Al día», y la operación aparece en «Operaciones abiertas en la nube»…» | «…el estado pasa a «Publicada» con «Al día», la cabecera también dice «Publicada», y la operación aparece en «Operaciones abiertas en la nube»…» | T-143 |
| 7.7 | «revisa los parámetros (la escala ya viene en GTSTC)» | «revisa los parámetros (la escala ya viene en GTSTC y el límite, del perfil guardado)» | T-143 |
| 7.10, la tabla | — | Una fila más: «N rechazados: la operación ya estaba cerrada» · «La oficina cerró la operación antes de esos movimientos: no se registran de nuevo» | T-143 |
| 7.11, el muelle | «En el muelle, el cierre no se anuncia solo: … **(no recorrido en esta edición)**; el chip «Revisar · N rechazados por la nube»…» | «En el muelle, el cierre llega solo: sale el aviso «La oficina cerró la operación de GTSTC. Lo que registres desde ahora se rechazará.», «Nube y cuenta» dice «Publicada y cerrada» y el chip «Al día · operación cerrada». Sin red, el muelle se entera al volver la red. Lo registrado antes del cierre sube igual; lo registrado después se rechaza: «1 rechazado: la operación ya estaba cerrada».» | T-143 |
| 10, mensajes | — | Tres filas: «La oficina cerró la operación de … Lo que registres desde ahora se rechazará.» · «Ya no registres en esa operación»; «Códigos de puerto que no son UN/LOCODE: … revisa esos puertos con la agencia» · «El archivo se abre igual; confirma esos puertos»; «Medidas DIM revisadas: … revisa esas medidas antes de estibar» · «El archivo se abre igual; confirma las medidas» | T-143, T-144 |
| 11, glosario | — | «**Destino final**: el puerto donde termina el viaje del contenedor (LOC+83), que puede no ser el de descarga de este buque.» «**DIM**: las medidas con que un contenedor sobredimensionado sobresale por cada lado.» «**UN/LOCODE**: el código de cinco letras de un puerto: dos del país y tres del lugar.» | T-144 |
| Lo no recorrido | «…Las capturas de la instalación en Android y en la Web (figuras 5 y 6) las toma Carlos.» | Se quita esa frase. Lo que no se recorra en esta edición se marca como en la 1.0.0 | 10.122 |

La 5.2 de T-143 («LLENO» → «Lleno»): el texto del manual ya dice «lleno o vacío»; cambia la
figura 23.

**Los pies de las figuras 5 y 6.** Las dos capturas están desde el 4-nov y las miré: la 5 es la
ficha de Play («gt.cmartinez.baystream (unreviewed)», «Desinstalar» y «Abrir», y las novedades de
la 1.0.0); la 6 es la Web en Chrome en incógnito, con el inicio sin viajes. Los pies de arriba
dicen lo que se ve. La 5 muestra las novedades de la 1.0.0: no estorba, y Carlos la puede volver
a tomar con la 1.0.1 si quiere.

#### 1.4.1 Las capturas

Muestran algo que cambia, así que no deberían quedar como están:

| Figura | Qué cambia | Quién |
|---|---|---|
| 13 | La píldora «Publicado» → «Confirmado» | Timonel |
| 23 | La tarjeta del viaje: «LLENO»/«VACÍO» → «Lleno»/«Vacío», «Peso total» | Timonel |
| 24 | La píldora de la cabecera, en Estadísticas | Timonel |
| 28 | La cabecera de la oficina publicada: «Publicada» | Timonel |
| 41 | La cabecera cerrada: «Cerrada» | Timonel |
| 1 a 4 | El asistente dice 1.0.0.9; en la 1.0.1, 1.0.1.10 | Carlos, en su recorrido de «BayStream Prueba» (1.6), si quiere |

**Timonel las toma en la fase 2** con el banco Web de T-139 (`t130_emu_main` contra el emulador
local, 1920 × 1080 a escala 2, tema claro, datos de BUQUE MANUAL), como las 45 de la 1.0.0. Es
una compilación del banco, no una Release, y nunca toca Firebase real. Unas 1.5 h, con un
SEMÁFORO por ventana. **Opcional:** una figura nueva del aviso del cierre en el muelle, para que
7.11 quede recorrido.

**Si Carlos prefiere no gastar ese tiempo,** se quedan las de la 1.0.0 y cada pie dice qué cambió
(«en la 1.0.1 la píldora dice «Confirmado»»).

### 1.5 El instalador y Windows

**Cómo se arma el asistente de la 1.0.1.** Desde `proyecto-baystream`, después de mezclar la
1.0.1 en `master`: ahí está la Release que se publica, y desde la mezcla, también el armador
(`tool/t137_instalador.dart`, `windows/installer/`). El paso 0 mostró que O-137-1 está resuelto
fuera de `baystream-t137`.
1. Se compila la Release una sola vez, con `tool\t93_msix.ps1 -Version 1.0.1.0`, que deja la MSIX.
2. Sobre la misma Release, sin compilar otra vez:
   `dart run tool/t137_instalador.dart --origen C:\Proyectos\proyecto-baystream --variante produccion --salida build/t137/v1.0.1`.
3. Lo que tiene que decir: 1.0.1.10, `firebaseCppExe` 13.13.1, 27 archivos en la carga, 5 fuera,
   las DLL de `VC\Redist`, y **ningún aviso de archivos viejos**. Ese aviso es la prueba de que la
   compilación limpia sirvió (10.130). Si sale, no se publica.
4. Se copia con su `.sha256` y su manifiesto a `C:\Users\Public\BayStream-1.0.1\`.

El arte no cambia: sus fuentes son las fuentes tipográficas, `lib/core/design/`, el ícono y dos
archivos de pruebas y de herramientas, y T-146 no toca ninguno. `pubspec.yaml` no está entre
ellas.

**Cómo se reparte Windows.** La MSIX y el asistente no conviven en una cuenta (10.100): el
asistente se detiene si encuentra la MSIX. Hoy hay dos casos conocidos: la laptop de Carlos, con
la **MSIX 1.0.0.0** (10.130), y la cuenta «BayStream Prueba», con el **asistente 1.0.0.9**
(T-137).

| Opción | Quien tiene la MSIX 1.0.0.0 | Quien tiene el asistente 1.0.0.9 | Una PC nueva | Lo que cuesta |
|---|---|---|---|---|
| **A · Solo la MSIX 1.0.1.0** | Se instala encima, como la 1.0.0 (10.102): los datos se quedan donde estén | Se queda en la 1.0.0.9, o tiene que desinstalar el asistente e importar el certificado para la MSIX | Importa el certificado | Lo de siempre. T-137 y T-145 quedan sin uso |
| **B · Solo el asistente 1.0.1.10** | Tiene que cambiar: el asistente se detiene. Hay que dejar cada operación «Al día», copiar los datos, desinstalar la MSIX e instalar el asistente. **En la laptop no se sabe dónde están los datos** (10.132): si viven dentro del paquete, desinstalar la MSIX los borra, y la app instalada por el asistente los busca en `%LOCALAPPDATA%\BayStream` | Se instala encima | Sin certificado | Una migración de datos durante la publicación, sin resolver la 10.132 |
| **C · Los dos, de la misma Release** | Actualiza con la MSIX 1.0.1.0, encima | Actualiza con el asistente 1.0.1.10, encima | Usa el asistente | Dos paquetes que verificar y dos vueltas atrás. Nadie migra hoy |

**Recomiendo C.** Cada cuenta se actualiza por su camino, encima y sin tocar sus datos. Nadie
desinstala nada mientras la 10.132 siga abierta, y lo nuevo sale con el asistente, que es lo que
pidió Carlos (10.99). Pasar la laptop de la MSIX al asistente queda como un paso aparte, después
de publicar y de saber dónde viven sus datos, con su propia copia y su propia prueba. La MSIX
queda de respaldo, como dijo la 10.100.

### 1.6 La lista de publicación: lo que cambia frente a la 1.0.0

La base es la de la 1.0.0 (10.102 y 10.105) con la forma de la sección 4 de
`docs/piloto/LISTA-PILOTO.md` (la de la 0.4.2). Lo que cambia, punto por punto:

**Antes de empezar**
1. **El recorrido de Carlos de T-145 en «BayStream Prueba»** es condición para publicar (10.136).
   Propongo hacerlo con el asistente de producción 1.0.1.10, recién armado y antes de repartirlo:
   prueba a la vez lo de T-145 y la actualización de 1.0.0.9 a 1.0.1.10. Si encuentra algo, se
   corrige en `sprint-4` y no se publica Windows.
2. **Ninguna operación abierta con una fuente 1.5 o con matrículas con espacio** (10.123). En
   «Operaciones abiertas en la nube», con la cuenta de oficina, cada operación abierta tiene que
   ser de un BAPLIE 2.x sin espacios en las matrículas (la operación de prueba S100 lo es). Si hay
   duda, se cierra antes. Una 1.0.0 y una 1.0.1 en la misma operación de ese tipo verían papeles
   distintos.
3. **Play:** en Play Console, el último `versionCode` subido tiene que ser el **9**. Si alguien
   usó el 10, la versión pasa a `1.0.1+11` y vuelve a la aceptación.
4. **Windows, dónde viven los datos de la laptop** (10.132), visto desde fuera del paquete:
   `%LOCALAPPDATA%\BayStream` y `%LOCALAPPDATA%\Packages\gt.cmartinez.baystream_*\LocalCache\Local\BayStream`.
   La copia de 4.2 copia **las dos** carpetas, no solo la primera.
5. **Las reglas no cambian:** T-143 y T-144 no las tocan, y la última que cambió fue T-130
   (`9dc1c60`). No hay paso 4.0; se coteja que lo publicado siga siendo `8B903949…`.

**La mezcla.** `master` está en `8f2505e` (10.116). La guardia compara contra el commit que
acepte GLM, como la de la 0.4.2 contra `fd39951`, y la etiqueta es `v1.0.1`. T-142 ya está en los
dos lados (`df15047` en `sprint-4` y `8f2505e`, su cherry-pick, en `master`): Git ve el mismo
cambio en `firebase.json` y no hay conflicto, pero si aparece uno, se para. Con la mezcla entran
también T-137 y T-145 (`windows/installer/`, `tool/t137_*`, `tool/t145_*`).

**La compilación limpia (10.130) y la trampa que trae.** `flutter clean` borra toda la carpeta
`build/`, y en `proyecto-baystream` ahí viven cosas que hacen falta:
- `build\t93\`: **las MSIX de la vuelta atrás**, la 1.0.0.0 (`BA01DED7…`) y la 0.4.2.0
  (`D57F8E50…`), con sus `.sha256`;
- `build\web\`: la Web 1.0.0 publicada, la de las huellas de la 10.115;
- `build\windows\x64\extracted` y el `.zip` del SDK 13.13.1 (920 MB). Después de limpiar, la
  compilación lo baja otra vez y lo extrae (8.5 GB). No es la trampa de la 10.99, porque baja la
  versión correcta, pero cuesta tiempo y red.

Propongo: **antes de `flutter clean`, mover `build\t93` a `C:\Proyectos\baystream-publicaciones\t93`**
(fuera de `build/`), comprobar las huellas de las dos MSIX allí, y que las vueltas atrás apunten a
esa carpeta. `build\web` no hace falta guardarlo: la vuelta de la Web es el historial de Hosting.
Los dos archivos viejos también están en `build\flutter_assets\`, no solo en la Release, y
`flutter clean` los quita de los dos lados. El aviso del armador (1.5, paso 3) comprueba que ya
no están.

**Un nombre que choca:** en `build\t93` ya hay un `BayStream_1.0.1.0.msix`, del 14-oct, de las
pruebas de T-93 del Sprint 3. `t93_msix.ps1 -Version 1.0.1.0` escribe con ese mismo nombre. Antes
de compilar, se renombra a `BayStream_1.0.1.0-t93-14oct.msix` (con su `.sha256`), como ya se hizo
con `BayStream_1.0.0.0-t93-15oct.msix`, para que nadie instale el viejo creyendo que es el nuevo.
Mover `build\t93` antes de `flutter clean` ya lo resuelve, si se renombra al moverlo.

**La trampa del SDK de C++ (10.99).** Con `build/` limpio no hay `extracted`, así que no hay nada
viejo que enlazar. Las comprobaciones siguen: `t93_msix.ps1` con `-Apartar` y `-Verificar`; antes
de instalar, dentro del `.exe`, `1.0.1+10` y una sola `Firebase C++ 13.13.1`; y el armador del
asistente se detiene si no coincide (O-137-2, de T-145).

**Windows** (con la opción C):
- **MSIX:** `t93_msix.ps1 -Huella … -Version 1.0.1.0`. En la laptop se instala encima de la 1.0.0.0;
  la comprobación de «lo instalado» acepta solo la 1.0.0.0. El valor por omisión del script sigue
  siendo `1.0.0.0`: el bloque pasa `-Version` siempre. Antes, la copia de las dos carpetas de datos.
- **Asistente:** 1.5. Antes de instalar, la huella contra su `.sha256`.
- **Después:** «Cuenta autorizada» con la sesión de oficina, en la MSIX de la laptop, como en la 1.0.0.

**Android:** `--build-name=1.0.1 --build-number=10`. Sube primero, como en la 1.0.0 (10.102).

**La Web:**
- `--build-name=1.0.1 --build-number=10`; `version.json`, solo la carpeta `web/vendor/firebase/12.19.0/`
  (T-92) y `t92_verify`, como en la 1.0.0;
- **las huellas de `version.json`, `main.dart.js` y `flutter_bootstrap.js`, anotadas antes de
  publicar** (la propuesta de la 10.115);
- **las cabeceras (10.115 y 10.116):** `firebase.json` ya las lleva en `master` y en `sprint-4`.
  Después de publicar, `curl -sI` a `/` y a `/privacidad.html`: la CSP, `X-Content-Type-Options`,
  `X-Frame-Options`, `Referrer-Policy`, `Permissions-Policy` y un solo HSTS. En el Honor y en Safari
  se espera la línea `Refused to load the script 'https://apis.google.com/js/api.js…'`, que no
  detiene nada (10.115);
- nunca `firebase deploy` a secas: `--only hosting --project baystream-app`.

**El Honor (10.126, 10.133 y 10.118):** lo que no se pudo ver con la 1.0.0 en el teléfono real.
Con la 1.0.1 de Play:
- la sesión de muelle, «Unirse» y un movimiento (como en la 1.0.0);
- T-144: el detalle con la letra a 2.0, con la matrícula entera y la naviera abajo si no cabe
  (T144-ACC-02 se cerró en el emulador, Android 8); la búsqueda «bysu 967» o una equivalente, que
  encuentre y, con O-144-1, que resalte;
- T-143: con la operación de prueba, la oficina cierra y el Honor muestra el aviso, «Publicada y
  cerrada» y «Al día · operación cerrada»; un movimiento después del cierre da «1 rechazado: la
  operación ya estaba cerrada».

**La prueba corta de punta a punta,** como la del S100 (10.105), con un viaje propio (por ejemplo
S101, sacado igual de las P130). Al final, la operación queda cerrada, y eso ya prueba el aviso
del cierre en el Honor.

**La vuelta atrás a la 1.0.0, cliente por cliente:**
- **Android:** Play no deja bajar, así que se sube el código de `v1.0.0` con
  `--build-name=1.0.0 --build-number=11`, porque el 10 es de la 1.0.1. Desde ahí, la siguiente
  versión lleva el 12 o más.
- **Windows, la MSIX:** la 1.0.0.0 es menor que la 1.0.1.0. Hoy la vuelta de la lista desinstala y
  reinstala, y **en la laptop eso puede borrar los datos, si viven dentro del paquete** (10.132).
  Por eso:
  - primero, la copia de las dos carpetas;
  - después, intentar la vuelta sin desinstalar: `Add-AppxPackage` tiene un parámetro para instalar
    una versión menor encima, `-ForceUpdateFromAnyVersion`. **Lo cito de memoria:** Yov lo comprueba
    en la documentación de Microsoft antes de escribir el bloque;
  - si no sirve, desinstalar y reinstalar, y devolver los datos desde la copia.
  
  La MSIX 1.0.0.0 sale de `C:\Proyectos\baystream-publicaciones\t93`, con su huella `BA01DED7…`.
- **Windows, el asistente:** el `.iss` no impide instalar una versión menor encima, así que el
  1.0.0.9 de T-145 (`e4e7304c…`, en `C:\Users\Public\BayStream-T145\1.0.0.9\`) se instala sobre el
  1.0.1.10, y los datos no se tocan. **No lo probé:** la aceptación lo prueba con la variante de
  prueba, o se anota como no comprobado.
- **La Web:** en el historial de Hosting, **la versión del 10-nov, 20:09**, la 1.0.0 con las
  cabeceras de T-142. No la del 3-nov, que no las trae.
- **La regla de la 10.123 también vale al volver:** si un cliente vuelve a la 1.0.0, ninguna
  operación abierta con una fuente 1.5 o con matrículas con espacio puede quedar entre clientes de
  versiones distintas. La 1.0.0 lee sin romperse lo que guardó la 1.0.1 (GLM, 2.6 de su
  aceptación).

**Lo que hay que comprobar, cliente por cliente:**

| Cliente | Antes | Después |
|---|---|---|
| Android | Último `versionCode` en Play = 9; el AAB dice 1.0.1 (10) | El Honor se actualiza a la 1.0.1; sesión, «Unirse», un movimiento; lo de T-143 y T-144 de arriba |
| Windows, MSIX | La laptop tiene la 1.0.0.0; la copia de las dos carpetas; el `.exe` con `1.0.1+10` y una sola `Firebase C++ 13.13.1`; la firma `Valid`; el `.sha256` | Configuración dice 1.0.1.0; «Cuenta autorizada» con la cuenta de oficina; la app abre con sus datos |
| Windows, asistente | El manifiesto: 1.0.1.10, 13.13.1, 27 + 5, sin aviso de archivos viejos; el recorrido de Carlos | En «BayStream Prueba», 1.0.1.10 en Aplicaciones, la app abre y la carpeta no tiene los cinco `.lib`/`.exp` |
| Web | `version.json` 1.0.1 (10); `t92_verify`; las tres huellas anotadas | `version.json` en vivo; las cinco cabeceras y un solo HSTS; la sesión de oficina en incógnito |

### 1.7 Las pruebas

**Lo nuevo:**
- O-144-1: `test/t146_resaltado_busqueda_test.dart`, 6 pruebas (1.3). Las 1, 3 y 4 fallan contra
  el código de hoy;
- O-144-2: ninguna prueba nueva. Las dos pruebas cambiadas siguen comprobando lo mismo. Lo que
  prueba el arreglo es el oráculo (1.2), en `tool/t146_oraculo.dart` si Carlos lo aprueba;
- la versión: la prueba de T-93 que ya existe.

**La suite completa,** en una sola corrida: **2227 de 2227** (2221 más 6), sin omitidas. Sin
O-144-1, 2221. `flutter analyze` en cero en todo el paquete, aquí y en la copia limpia, sin
`// ignore:`; el oráculo en cero.

**Lo que repite quien acepte:**
1. Su copia limpia de la punta: `pub get --offline --enforce-lockfile`, `analyze` de todo el
   paquete en cero y la suite en 2227, sin omitidas.
2. **El oráculo en su copia: cero.** Y, contra `1c40d39`, las cuatro líneas de GLM. Eso muestra que
   el oráculo ve lo que vio GLM, y que el arreglo lo quita.
3. Las 1, 3 y 4 de `t146_resaltado_busqueda_test.dart` contra el `container_search_delegate.dart`
   de `1c40d39`: tienen que fallar.
4. A la vista, en la Web y en Windows, contra el emulador: «bysu 967» resalta `BYSU967`.
5. Si quiere, el armado de prueba del paso 0: `5ef28b61…`.

### 1.8 Los archivos

**Fase 2, si Carlos aprueba todo:**
- `pubspec.yaml`: las dos líneas de 1.1;
- `test/t112_localization_test.dart` y `test/t121_estadisticas_test.dart`: 1.2;
- `lib/features/vessel/presentation/widgets/container_search_delegate.dart`: 1.3;
- `test/t146_resaltado_busqueda_test.dart` (nuevo): 1.3;
- `DESIGN.md`: la frase de 1.3;
- `tool/t146_oraculo.dart` (nuevo, si se aprueba): 1.2;
- `docs/MANUAL-USUARIO-1.0.1.md` (nuevo) y `docs/manual-1.0.1/` con las cinco capturas: 1.4;
- `docs/T146-RESULTADOS.md`.

**No se tocan:** `pubspec.lock`, `lib/main.dart`, los dos congelados, `docs/MANUAL-USUARIO-1.0.0.md`
(con la opción del archivo nuevo), `tool/t93_msix.ps1`, `windows/installer/`, `tool/t137_*`,
`docs/piloto/LISTA-PILOTO.md` (la escribe Yov), `SPRINT-4.md`, `AGENTS.md`, `CLAUDE.md` ni
`README.md`. No se compila ninguna Release ni se publica nada.

---

## 2. Lo que decide Carlos

1. **La versión:** `1.0.1+10` y `1.0.1.0` (1.1). Si en Play ya se usó el 10, pasa a +11.
2. **O-144-2:** el cambio de las dos pruebas (1.2) y si se suma `tool/t146_oraculo.dart`.
3. **O-144-1:** arreglarlo aquí (1.3) o dejarlo para el frente de usabilidad.
4. **El manual:** un archivo nuevo para la 1.0.1 o el mismo (1.4), y si Timonel vuelve a tomar
   las cinco capturas (1.4.1).
5. **Windows:** la opción A, B o C (1.5). Recomiendo C.
6. **La lista:** lo de 1.6 lo escribe Yov. Dos cosas piden decisión: mover `build\t93` fuera de
   `build/` antes de `flutter clean`, y la vuelta de la MSIX sin desinstalar.

## 3. Observaciones

- **O-146-1 (P3), la causa de O-144-2 queda abierta.** No encontré por qué el analizador evalúa
  `use_build_context_synchronously` en `test/` en unas corridas y en otras no. El arreglo no
  depende de ello, y el oráculo lo vuelve comprobable. Si vuelve a pasar con otro archivo, el
  oráculo lo encuentra antes.
- **O-146-2 (P3):** `tool/t93_msix.ps1` tiene `-Version 1.0.0.0` por omisión. Si alguien lo
  olvida, sale una MSIX 1.0.0.0 con el código de la 1.0.1. Para después: que lo lea de
  `msix_version`. En T-146 no se toca; el bloque de la lista pasa `-Version` siempre.

## 4. Horas

Fase 1, por el reloj de las corridas: del 16-nov a las 23:22 (la primera lectura de Git) a las
23:43, unos **20 minutos**. El paso 0 corrió de 23:25 a 23:26; la investigación de O-144-2 (once
`analyze`, el oráculo y el prototipo), de 23:26 a 23:36.

## 5. ALTO

Me detengo aquí. Yov revisa la propuesta y Carlos la aprueba. Hasta entonces no toco `lib/`,
`test/`, `tool/` ni `pubspec.*`.

**Git, para Carlos:** solo este informe, si quiere guardar la fase 1. El commit de la tarea va al
final de la fase 2.

```powershell
Set-Location -LiteralPath C:\Proyectos\baystream-rediseno
git add -- docs/T146-RESULTADOS.md
git commit -m "Sprint 4: T-146, la propuesta de la 1.0.1"
git push origin sprint-4
```

**En tres líneas:**
- La punta trae la mezcla del instalador, `analyze` da cero, y el armado de prueba desde esta carpeta da `5ef28b61…`: O-137-1 queda comprobada en la carpeta real.
- O-144-2 no se reproduce en ninguna copia de esta máquina, pero un oráculo determinista da exactamente las cuatro líneas de GLM, y el cambio propuesto las deja en cero, con las pruebas en verde.
- La propuesta lleva la versión, el resaltado con espacios, un manual nuevo para la 1.0.1, Windows con la MSIX y el asistente a la vez, y la lista con dos trampas nuevas: `flutter clean` borra las MSIX de la vuelta, y ya existe un `BayStream_1.0.1.0.msix` viejo.

> **Para Yov:** T-146, fase 1, en `docs/T146-RESULTADOS.md` (sin commit, sobre `1c40d39`). Paso 0:
> `analyze` cero, y el asistente de prueba armado desde `baystream-rediseno` da `5ef28b61…`
> (18 486 858 bytes): O-137-1 comprobada. O-144-2 no sale aquí ni en ninguna copia limpia, tampoco
> con los archivos de GLM: en esta máquina la regla no evalúa `test/` y en las corridas de GLM sí.
> Copiando `test/` y `tool/` dentro de `lib/` de una copia, `analyze` da exactamente las cuatro
> líneas de GLM, y con el cambio propuesto (el contexto en funciones síncronas, sin `// ignore:`),
> cero; las dos pruebas pasan, 95 de 95. Propongo: O-144-1 arreglado (una línea y 6 pruebas), un
> `MANUAL-USUARIO-1.0.1.md` nuevo con cinco capturas retomadas, y Windows con la MSIX y el asistente
> a la vez (opción C), para que nadie migre mientras la 10.132 siga abierta. Para la lista, dos
> trampas: `flutter clean` borra `build\t93` con las MSIX de la vuelta atrás, y ahí ya hay un
> `BayStream_1.0.1.0.msix` del 14-oct. La vuelta de la Web es la versión de Hosting del 10-nov, con
> las cabeceras, y la de Android usa el `versionCode` 11.
