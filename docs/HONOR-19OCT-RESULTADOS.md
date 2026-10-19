# Ronda del Honor del 19-oct · T-85, T-108, T-109 y T-110 — resultados (Timonel)

**Dictamen del Honor: las cuatro PASAN.** T-85, a letra 2.0, en lo que el producto muestra («Alertas de estiba»); T-108, a 1.0; T-109, a 1.45 y 2.0, y T-110, a 1.0, todo a 360 dp. Con esto se cierra lo que mis aceptaciones dejaron pendiente para el Honor (10.85 y 10.88).

**Un hallazgo nuevo, anterior a estas tareas** (sección 7): a 360 dp, con letra 1.0 y 1.45, la tarjeta del viaje parte «Contenedores» a mitad de palabra. Con 1.45 también parte «7419.5 t» y «Peso Total».

Timonel (Claude Code), 19-oct-2026, de 13:47 a 14:09, solo y con los permisos de 10.88. No inicié sesión en nada, no toqué Firebase, «PRUEBA T-105», demo17, el almacén real ni las BayStream ya instaladas.

## 1. La app de prueba: `honor19`

**De dónde sale:**
- La copia es `%TEMP%\baystream-honor19-8d1bbb8\app`, de `8d1bbb8`: 714 archivos, verificados byte a byte con su manifiesto. Su código es el mismo de HEAD (`9728900`).
- En esa copia, y solo ahí, cambié la identidad Android, como `t106cx`:
  - `applicationId` pasa a `gt.cmartinez.baystream.honor19` (`android/app/build.gradle.kts`);
  - la etiqueta, a «BayStream Honor19» (`AndroidManifest.xml`).
- No hay `key.properties` en la copia, así que Gradle firma el release con la clave de depuración (`build.gradle.kts`, la rama sin clave de subida). No abrí ni copié `android/key.properties`. No pude confirmar el certificado con `apksigner`, porque en esta consola no hay Java en el PATH.

**La entrada,** `tool/honor19_main.dart`:
- Es el mismo arranque de `lib/main.dart`, con la misma `BayStreamApp`. Solo cambian los tres almacenes locales (viajes y perfiles, bitácora y sesión), que van al namespace `honor19`.
- Inicializa Firebase con la configuración por `--dart-define-from-file=C:\Proyectos\baystream-privado\firebase-prod.json`, sin abrir el archivo, y exige `projectId == baystream-app`, como `t106cx`.
- **Inicializa Firebase porque el lector del producto lo pide**: `VesselRepositoryImpl` toma `FirebaseFirestore.instance` al construirse (`vessel_repository_impl.dart:19`).
- **No hubo lecturas ni escrituras remotas, por el código:**
  - nadie inició sesión, y sin usuario `FirebaseSessionRepository` no consulta Firestore;
  - una operación local no publicada no arranca el motor de sincronización (`firestore_operation_sync.dart`, `if (!operation.published)`).
  - La página «Nube y cuenta» no se abrió nunca.

**El APK:**
- Release, sin `--no-pub` (10.86): código 0, 69 s.
- 66 298 035 bytes, SHA-256 `0f56621409d77350a745ea425b9ca296e5b69c282deebbf921d4759a21b7f187`.
- `aapt` confirma el paquete `gt.cmartinez.baystream.honor19` y la etiqueta «BayStream Honor19». No es `debuggable`: sus banderas son `HAS_CODE ALLOW_CLEAR_USER_DATA`.

**Antes hubo un primer APK sin Firebase** (65 233 075 bytes, `3301dac9…a8aa`). Lo instalé, pero no llegué a abrirlo: el banco de Windows mostró que sin Firebase el producto no puede leer archivos. Lo reemplacé con `install -r` por el definitivo antes del primer arranque.

## 2. El Honor: qué cambié y cómo quedó

| Ajuste | Antes | Durante | Al final |
|---|---|---|---|
| `wm size` | Physical 720x1600 | **sin cambios** | Physical 720x1600 |
| `wm density` | Physical 320 | **sin cambios** | Physical 320 |
| `font_scale` | 1.0 | 2.0 (13:58:22), 1.45 (14:01:21), 1.0 (14:02:20), 1.45 (14:08:07, para la sección 7) | **1.0** (14:08:56), leído con `settings get` |

- **No hizo falta tocar `wm`:** el Honor (NAA-LX3, Android 15) ya da 360 dp (720 px a densidad 320), como en T-106. No hay ningún *override* que restablecer.
- **Los archivos:** pasé `CORPUS_A07.edi`, `CORPUS_A03.edi`, `ACC1.edi` y `ACC2.edi` por `adb push` a `/sdcard/Download/honor19/`. El selector del sistema mostraba «Sin elementos» porque `adb push` no indexa, así que los indexé con `MEDIA_SCANNER_SCAN_FILE`, uno por uno. **Ahí siguen:** son copias, los originales no se tocaron, y lo que se haga con ellas lo decide Carlos.
- **La app:** `honor19` queda instalada y cerrada (`am force-stop`, sin PID), con sus datos en el namespace `honor19`: 4 viajes y sus perfiles.
- **Las otras 44 BayStream del Honor**, incluida demo17, tienen el mismo `lastUpdateTime` antes y después (`paquetes-antes.txt` y `paquetes-despues.txt`). Ninguna se abrió.

**Cómo lo manejé:**
- Toques y deslizamientos con `adb shell input`.
- Los archivos se eligieron con el **selector real del sistema** (DocumentsUI): Descargas → `honor19` → archivo. Lo navegué con volcados filtrados a mis cuatro archivos, sin capturar sus pantallas.
- Ayudante: `tool/honor19_capturas.py`.
  - **La captura** sale de `adb exec-out screencap -p`, se le recorta la barra de estado (80 px) en memoria y solo entonces se guarda.
  - **El volcado** sale de `adb exec-out uiautomator dump /dev/tty`, se queda solo con los nodos de la app y oculta los correos.
- Ninguna captura tiene datos de cuenta. En la barra de la app y en el encabezado del plano se ve el ícono de «Nube y cuenta», sin texto ni cuenta, porque es parte de la interfaz; su página no se abrió.

**Las capturas** van a `%TEMP%\baystream-honor19-8d1bbb8\evidencia\` (720 × 1520, ya sin la barra de estado), junto con `cambios-del-honor.txt`.

## 3. T-110 · Las mismas bahías al leer y al reabrir, y los dos textos — **PASA** (letra 1.0)

| Comprobación | Resultado | Captura |
|---|---|---|
| A07 al leerlo, por el selector y confirmando el perfil propuesto («No lo tengo» para el límite de apilamiento) | **21 bahías**, 398 contenedores, 6940.6 t, sin avisos de lectura | `t110-01-a07-leer-21-bahias.png` |
| La 27 | chip «BAY 27 (11%) · 0»; 0 contenedores; rejilla de cubierta (90–80) | `t110-02-a07-bahia27-cubierta.png` |
| La 27, en bodega | las marcas «40'» de la 026 en las filas 01–07 (el volcado ve 11 en pantalla, y la 07 sigue al borde) | `t110-03-a07-bahia27-bodega-marcas40.png` |
| Recientes | «BUQUE GOLF · VIAJE007A · 398 contenedores · 21 bahías» | `t110-04-recientes-21-bahias.png` |
| A07 al reabrirlo desde Recientes | **21 bahías**, sin avisos | `t110-05-a07-reabierto-21-bahias.png` |
| Los kilos enteros (ACC1, en el nativo, donde antes salía «.0») | «VGM en TNE convertido a **23457 kg**» y «WT en LBR convertido a **24000 kg**», también al reabrir | `t110-06-acc1-pesos-kg-enteros.png` |
| El singular (ACC2) | «Archivo posiblemente incompleto: **falta 1 segmento (UNZ)**» | `t110-07-acc2-falta-1-segmento.png` |
| El plural (ACC1) | «**faltan 2 segmentos (UNB, BGM)**» | `t108-01-acc1-cuatro-lineas-letra10.png` |
| La reserva de 40 (ACC2, 10.88) | la tarjeta da 7 bahías y Estadísticas, **4 ocupadas** (leído en el volcado) | — |
| A03 | **27 bahías** (14 → 27, como en el cotejo) | — |

## 4. T-85 · La segregación con el IMDG 42-24 — **PASA** (letra 2.0, A03)

**Lo que ve el usuario del producto es «Alertas de estiba».** Desde T-42 (`3318da4`, 30-sep), el producto ya no abre `SegregationPage`: esa pantalla, con la matriz de 17 clases, solo se monta en el banco `tool/t85_main.dart`. Por eso en el Honor revisé «Alertas de estiba» de A03, que es la pantalla de resultados con la fuente nueva. **La matriz a 2.0 no la vi en el Honor**, porque haría falta el banco de T-85; queda en la observación 1 de la sección 7.

| Comprobación a 2.0 | Resultado | Captura |
|---|---|---|
| La fuente | «Fuente: Código IMDG, Enmienda 42-24 (7.2.4 y 7.4.3.2). Apoyo a la decisión, no verificación de cumplimiento. No se evalúa la columna 16b…», completa y en varias líneas | `t85-01-a03-alertas-letra20-fuente.png` |
| El resumen | «**4** posibles incumplimientos · **154** no evaluados · **95** conformes en las reglas evaluadas» | `t85-02-a03-alertas-letra20-4-154-95.png` |
| La primera alerta | «Error · Posible incumplimiento · Segregación · IMDG 42-24», PLNU9223134 / HXTU0749681, UN1170 (clase 3) / UN0012 (clase 1.4), «Exigencia 2 de la matriz por clase», sin cortes | `t85-03-a03-alertas-letra20-primer-error.png` |
| El pie de la alerta | las tres citas de IMDG, cada una en su línea; «Ver 0020386» y «Ver 0030586» apilados, sin desborde | `t85-04-a03-alertas-letra20-botones.png` |

A 1.0, el volcado da la misma fuente y el mismo 4 / 154 / 95.

## 5. T-109 · Estadísticas sin desbordes a 360 dp — **PASA** (A07, letra 2.0 y 1.45)

**A 2.0** (`t109-20-01` … `t109-20-13`, el recorrido completo):
- las seis métricas, en una columna: 398, **21** bahías ocupadas, 6940.6 t, 290, 108 y 12;
- los títulos, en dos líneas;
- **«Llenos» se ve entero**, con «290 (72.9%)» debajo, y lo mismo «Vacíos», con «108 (27.1%)». En el padre de T-109, a 360 dp y 2.0, «Llenos» se partía letra por letra (mi aceptación de T-109, en Windows y Chrome; el padre no lo instalé en el Honor);
- los tamaños, la carga especial (12 Reefer y 14 IMO/DG), las 7 navieras y los 6 puertos, completos;
- el perfil longitudinal y los dos gráficos de bahías van con desplazamiento horizontal.

**El FittedBox:** no vi ninguna cifra achicada. Las cifras de las leyendas, de las barras de navieras y puertos y de los gráficos salen con el mismo tamaño de letra, y las más largas («115 (28.9%)», «125 (31.4%)») caben enteras.

**A 1.45** (`t109-145-01` … `t109-145-10`), lo mismo, y las tres pestañas caben enteras.

**Lo que se ve y no es un defecto de T-109:**
- En los gráficos desplazables, la cifra del borde queda a medias hasta desplazar: «13» en contenedores y «15…» del 1575 t de la 14. Es la observación 2 de mi aceptación de T-109.
- A 2.0, la barra de pestañas se desplaza: con «Estadísticas» elegida, «Lista» queda cortada a la izquierda. Se alcanza desplazando.
- A 2.0, el rótulo «Bahías ordenadas de proa…» del perfil sigue fuera de la vista, dentro del mismo desplazamiento horizontal.

## 6. T-108 · Los avisos de lectura — **PASA** (letra 1.0)

| Comprobación | Resultado | Captura |
|---|---|---|
| ACC1 al leerlo | las cuatro líneas: «Pesos revisados: 4 contenedores», «Posiciones mal formadas: 2 contenedores», «Dígito de control inválido: 2 contenedores» y «Archivo posiblemente incompleto: faltan 2 segmentos (UNB, BGM)» | `t108-01-acc1-cuatro-lineas-letra10.png` |
| Los detalles | posiciones «CSQU3045383: -120082» y «CSQU3054383: 016008»; pesos 23457 kg (TNE), 24000 kg (LBR), «unidad desconocida XYZ; sin ese peso» y «sin unidad; se tomó como kg» | `t110-06-acc1-pesos-kg-enteros.png` |
| ACC1 reabierto desde Recientes | las mismas cuatro líneas y los mismos detalles | `t108-02-acc1-reabierto-cuatro-lineas.png`, `t110-08-recientes-tres-viajes.png` |
| A07, al leer y al reabrir | **sin avisos** | `t110-01`, `t110-05` |

## 7. Hallazgo y observaciones

**Hallazgo (no es de estas cuatro tareas): la tarjeta del viaje parte las palabras a 360 dp.**
- **A 1.0** (A07 y ACC2): «Contenedore / s» (`t110-01`, `t110-07`).
- **A 1.45** (A03): «Contene / dores», «7419.5 / t» y «Peso / Total» (`obs-tarjeta-contenedores-letra145.png`).
- **A 2.0** no pasa, porque los indicadores se apilan.
- **Por qué:** `voyage_summary_card.dart:127–130` solo apila cuando `textScaler.scale(12) > 18`, es decir, por encima de 1.5. Por debajo reparte el ancho en tres (`(ancho − 32) / 3`, unos 85 dp en el Honor), y una sola palabra de `bodySmall` no cabe.
- La regla viene de T-104 (`bf3a2cf`, «los textos a 200 %»), y la fila de indicadores es de la tarjeta original.
- **Para Yov:** es lo primero que el planificador ve al abrir un viaje en el teléfono. Va al rediseño o a una tarea chica antes del cierre: apilar también por ancho, o dejar que la etiqueta se ajuste sin partir palabras.

**Observaciones:**
1. **La matriz de segregación no tiene entrada en el producto** desde T-42 (`3318da4`). La ficha de T-85 pide la pantalla con la matriz; el usuario solo llega a «Alertas de estiba». Lo decide Yov: dar entrada a `SegregationPage`, o revisar la matriz a 2.0 en el Honor con el banco de T-85.
2. **«1 celdas reservadas»** en la tarjeta de ACC2 (`voyage_summary_card.dart:161–162`, de T-69). Es el mismo tipo de arreglo que «faltan 1 segmentos».
3. **El lector del producto pide Firebase inicializado** (`vessel_repository_impl.dart:19`). Por eso `honor19` inicializa Firebase. No afecta al producto, porque `lib/main.dart` siempre lo inicializa, pero el comentario de `operation_sync_factory.dart:13–15` promete un modo de un solo dispositivo que, para leer archivos, no existe.
4. **El selector del sistema no ve lo que entra por `adb push`** hasta indexarlo. Para la próxima ronda: `am broadcast -a android.intent.action.MEDIA_SCANNER_SCAN_FILE -d file:///storage/emulated/0/Download/<carpeta>/<archivo>`.

## 8. Archivos de esta ronda

**Nuevos:**
- `docs/HONOR-19OCT-RESULTADOS.md` (este informe)
- `tool/honor19_main.dart`: la entrada de la app de prueba. Se compila desde una copia en TEMP con el `applicationId` cambiado.
- `tool/honor19_capturas.py`: capturas y volcados sanitizados. Usa Pillow, que ya está en esta máquina; no es dependencia del proyecto.

No cambia `lib/`, `test/`, `pubspec.yaml` ni `pubspec.lock`.
