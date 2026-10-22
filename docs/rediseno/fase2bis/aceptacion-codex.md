# T-114 · Aceptación de la corrección 10.15 y las Fases 1 bis y 2 bis

**Dictamen conjunto: NO PASA.** Capitán Codex · 22-oct-2026.

**La corrección 10.15 queda ACEPTADA:** se cierran el H1 anterior y O1–O3. La fundación de «Puente de mando» tiene un hallazgo nuevo: la celda recién movida salta directamente a su posición final, sin la salida progresiva de 150 ms que declara DESIGN.md 13.3. La suite entregada pasa, pero la reproducción adicional de ese requisito falla. Hay que corregir esta pieza y su prueba antes de integrarla en el plano. No se corrigió código del producto.

Copia: `C:\Proyectos\baystream-qa-r4`. HEAD: `c2877923e46ff925342926883fb7321e72171c07` (decisión 10.16). Entregas examinadas: corrección `3144b64` y fases `36f5784`. Comparación: `e22e400`, la aceptación anterior. Se leyeron AGENTS.md, las restricciones vigentes de Sprint 3 y 4, SPRINT-4.md 10.14–10.16, DESIGN.md 13, las tres secciones solicitadas de REDISENO-RESULTADOS.md y la aceptación de Fase 3 entrega 1.

Evidencia propia: `build/t114-fase2bis-aceptacion/`. Todos los nombres de registros abreviados de este informe parten de esa carpeta. Flutter **3.38.9**, Dart **3.10.8**. Carlos dio luz verde expresa antes del primer comando Flutter. Cada comando terminó antes de empezar el siguiente; no hubo ventanas de medición de tiempos operativos. Se liberó el semáforo al terminar. Sin Git de escritura, sin `git status`, sin abrir sesiones ni operar Firebase, Honor, emulador o la app instalada. Las capturas nuevas proceden del motor de pruebas, con datos sintéticos.

## 1. Resultado de los trece puntos

| Punto | Resultado y evidencia |
|---|---|
| **1. H1 anterior: «No lo tengo»** | **Pasa.** Repetí el diagnóstico anterior desde inicio → archivo → previo → Confirmar. Propuesta y plantilla de BUQUE BETA para BUQUE ALFA empiezan sin marcar, con el botón deshabilitado; el perfil propio declarado sin límite empieza marcado y permite confirmar. Tres pruebas propias pasan: `no_lo_tengo_test.dart`, `no-lo-tengo.txt`. Las cuatro pruebas nuevas entregadas también pasan dentro de la suite. |
| **2. O1: evidencia Web e instrumento** | **Pasa.** Los cinco archivos de `con-perfil/` están en HEAD y en disco, con contenido coincidente con Git; hashes y tamaños en `correccion-evidencia.json`. Registro y resumen coinciden: 3 pasos, 2.612 s de primer cuadro + 0.303 s hasta rejilla = **2.915 s**, publicado, condición informativa. La captura de rejilla muestra `T99_SINTETICO_977.edi`. No regeneré la medición. Ejecuté las funciones puras del instrumento: **66 rechazos** (22 nombres reservados, en minúsculas, mayúsculas y con extensión); acepta `con-perfil` y produce las tres carpetas de condición correctas. |
| **3. O2: perfil completo** | **Pasa.** `_mismoPerfil` compara los ocho campos sustantivos de `VesselProfile`: identidad, nombre, geometría, tapas, bahías observadas, tomas y ambos orígenes; excluye únicamente `updatedAt`. La geometría incluye el límite y sus anclas. Se usa después de resolver identidad, después de confirmar y después de reabrir; también compara el único perfil persistido. `profile_loading_test.dart`: **8/8**. |
| **4. O3: referencia de censos** | **Pasa.** `5406e20` está declarado en 3.4 del informe y en la ayuda de `--antes` de `tool/t112_censos.py`. Se inspeccionó el cambio, sin repetir censos ajenos a esta entrega. |
| **5. Alcance** | **Pasa.** `git diff --stat=350 e22e400..HEAD`: **39 rutas**, 7007 inserciones y 336 eliminaciones. Son las **11** de `3144b64`, las **27** de `36f5784` y **SPRINT-4.md** de Yov; los grupos no se solapan. Ningún cambio en `domain/`, `data/`, `lib/main.dart`, `pubspec.*` o los congelados. La única ruta de `presentation/` modificada es `vessel_geometry_page.dart`, exclusivamente la condición de la corrección. `alcance-stat.txt`, `alcance.json` y `diff-correccion-y-pruebas.txt`. |
| **6. Suite y análisis** | **Pasa.** `flutter pub get`; `flutter test --no-pub --reporter=json`: **1223 éxitos, 0 fallos y 0 omitidas**. `flutter analyze --no-pub`: **No issues found**. Registros: `pub-get.txt`, `suite.jsonl`, `suite-resumen.json`, `analyze.txt`. Esta cifra corresponde a la suite entregada; no incluye las pruebas propias ni oculta el fallo adicional descrito abajo. |
| **7. Color** | **Pasa.** `python -X utf8 -I tool/rediseno_contraste.py`: **0 pares bajos**. Recalculé por separado luminancia WCAG, composición y seis fichas OKLCH, sin importar ese instrumento. Resultados en las tablas de la sección 4 y `calculo-independiente.json`; los seis pares de fichas coinciden con Dart. |
| **8. Tabla reordenada** | **Pasa.** Dart y Python tienen `[11, 6, 3, 9, 1, 8, 4, 0, 10, 5, 2, 7]`. Los cinco primeros puertos ocupan 345°, 195°, 105°, 285° y 45° en la rueda uniforme; calculé las diez distancias y el mínimo es **60°**. En los matices OKLCH el mínimo es **55°** (uva/rosa), como advierte 13.4. Comparación textual contra `e22e400`: tablas de códigos, FNV-1a, multiplicación por mitades y asignación de reserva intactos. |
| **9. Nueve piezas** | **No pasa completo: H1 nuevo.** Las 39 pruebas entregadas de piezas pasan; también las 16 comprobaciones propias de inmovilidad con `disableAnimations`. Hay ocho vistas previas, que cubren las nueve piezas mediante agrupaciones, y 16 PNG propios con fuentes reales. La salida normal de la celda no cumple los 150 ms: `salida-celda.txt` y `salida-celda.json`. Véanse las secciones 2 y 5. |
| **10. Tema** | **Pasa según 10.16.** Las **7 pruebas de T-90** pasan, incluido el selector real que responde a cambios de brillo del sistema y respeta elecciones explícitas. `AppThemePreference.system` resuelve `ThemeMode.system`. `bayStreamTemaPorOmision` está preparado y no gobierna `BayStreamApp`; no se conectó ni se alteraron dominio o datos. La propuesta que aún cuenta DESIGN.md 13.5 queda subordinada a la decisión posterior de Carlos. |
| **11. Auditoría flutter-ui `--all`** | **Pasa en hallazgos accionables, con precisión O4.** 165 archivos; global: **17 críticos, 272 avisos y 19 informativos**. En `lib/core/design/` y `lib/core/app.dart`, fuera de los dos archivos de tokens: **0 críticos y 1 aviso automático**, no cero literal. Es `ANIM_ZERO_DURATION` en `bs_movimiento.dart:58`, el mismo falso positivo previo del interruptor de accesibilidad. Los dos tokens concentran **201 avisos** de hexadecimales (159 + 42). `flutter-ui-audit.txt`, `auditoria-resumen.json`. |
| **12. DESIGN.md 13 contra decisión y código** | **Con discrepancias.** Diez comprobaciones concretas en la sección 6. Se separan el H1 nuevo, los desajustes documentales y el naranja de «Más» ya observado en 10.16. |
| **13. Web sin conexión** | **Pasa la verificación solicitada.** `flutter build web --release --output=build/qa-r4-web` termina correctamente. Después, `dart run tool/t92_verify.dart build/qa-r4-web`: **verificador correcto, 56 archivos, 37,823,330 bytes**. `build-web.txt`, `t92-verify.txt`. Verifica recursos locales, procedencia, hashes y service worker; no se afirma haber ejecutado una nueva sesión de navegador sin red. |

La compilación conserva el aviso de fuente `packages/cupertino_icons/CupertinoIcons` ausente; el mismo texto ya está en `build/t114-entrega1-aceptacion/build-web.txt:70`. No es una incidencia nueva del análisis ni de estas fases. No se agregaron dependencias ni cambiaron `pubspec.yaml` o `pubspec.lock`.

## 2. H1 nuevo · La celda salta; no realiza la salida de 150 ms

**Ubicación:** `lib/core/design/componentes/bs_celda.dart:369–391`, especialmente la creación condicional de `AnimatedSlide` en la línea 385.

DESIGN.md 13.3 exige que la celda recién movida salga media celda hacia arriba mediante una transición de 150 ms. Antes del cambio de estado no existe `AnimatedSlide`; cuando aparece, se crea directamente con `offset: Offset(0, -0.5)`. Su traslación comienza ya en el destino, sin un valor previo de cero que interpolar.

La reproducción propia monta la celda en `porBajarCubierta`, espera la estabilización y cambia la misma celda a `recienMovido`, con **`disableAnimations: false` explícito**. Lee la posición efectiva del `SlideTransition` y captura los píxeles:

| Instante desde el cambio | Posición efectiva | SHA-256 de los píxeles |
|---:|---|---|
| 0 ms | `Offset(0.0, -0.5)` | `07b20e50e5b910c60d8d0cc92350bcf986e24de1dfb588e9fb3c932a1964e3bd` |
| 75 ms | `Offset(0.0, -0.5)` | Igual |
| 150 ms | `Offset(0.0, -0.5)` | Igual |

La prueba falla al exigir un fotograma intermedio diferente del inicial. Se repitió con la reducción de movimiento forzada a falso y el resultado fue el mismo. Que haya un ticker activo no demuestra desplazamiento: aquí las posiciones y los píxeles permanecen iguales.

La prueba entregada «recién movido sale de su celda…» comprueba que existe `AnimatedSlide`, que su destino es `BsCelda.salida`, la etiqueta y el tamaño; no mide un valor intermedio. Por eso pasa y no detecta el defecto.

**Corrección propuesta, sin implementarla:** conservar una transición capaz de interpolar desde cero al destino, o iniciar explícitamente la traslación después del primer estado, manteniendo el diseño basado en `Transform` y la ruta estática para movimiento reducido. Añadir una prueba que cambie de estado y compruebe posición inicial, intermedia y final, además de la inmovilidad accesible. Reaceptar esta pieza antes de su integración; no hace falta rehacer la medición histórica RNF-002 por este hallazgo.

Reproducción desde la raíz de esta copia, bajo el semáforo de Carlos:

```powershell
flutter test --no-pub build/t114-fase2bis-aceptacion/salida_celda_test.dart --reporter=expanded
```

## 3. Corrección 10.15: cierre separado

La condición nueva de `vessel_geometry_page.dart:176–181` exige perfil propio, origen `declaredByUser` y límite nulo. Sin viaje, editar únicamente el perfil conserva la declaración previa. Con viaje, la clave del perfil debe coincidir con la del buque. Ni la geometría inicial por sí sola ni el origen plantilla bastan.

Leí las cuatro pruebas de `test/t114_fase3_correccion_test.dart`: plantilla clonada de BETA para ALFA sin marcar y sin confirmar hasta elegir; propuesta sin marcar que se habilita escribiendo un límite; perfil propio declarado sin límite marcado, también al editar solo el perfil; perfil declarado de otro buque sin marcar. Todas pasan. La repetición del diagnóstico anterior añade el recorrido real desde `VesselOverviewPage` y comprueba explícitamente el botón en los tres casos.

Los cinco archivos recuperados son `con00-publicado.png`, `con01-inicio.png`, `con01-registro.json`, `con01-rejilla.png` y `resumen.json`. La trazabilidad actual demuestra su presencia en Git y su coherencia con la medición informativa de 2.915 s; no constituye una nueva medición ni una comparación forense con una carpeta histórica no versionada. Los JSON se compararon normalizando CRLF/LF y los PNG por sus bytes.

O2 ya no reduce la comparación a la clave. Se contrastó el ayudante con todos los campos de `VesselProfile`, incluidos los derivados almacenados dentro de `geometry`; los únicos datos omitidos son los temporales de `updatedAt`. O3 declara correctamente `5406e20`; la ayuda ya explica por qué `sprint3-cierre` no reproduce las decisiones por línea.

## 4. Cálculos independientes de color

Se usó sRGB lineal, luminancia `0.2126 R + 0.7152 G + 0.0722 B` y `(Lmayor + 0.05)/(Lmenor + 0.05)`. Cálculo propio en `inspeccion.py`, resultados sin redondear en `calculo-independiente.json`. Las tablas muestran dos decimales.

| Tinta | Sobre noche `#07111F` | Sobre panel `#0C1A31` |
|---|---:|---:|
| `#EAF0F9` | 16.53:1 | 15.18:1 |
| Suave `#A9B9D2` | 9.52:1 | 8.74:1 |

| «Por bajar» | Relleno | Texto | Contraste |
|---|---|---|---:|
| Día, cubierta | `#0D47A1` | `#FFFFFF` | 8.63:1 |
| Día, bodega | `#1F5FD6` | `#FFFFFF` | 5.73:1 |
| Noche, cubierta | `#F5F8FC` | `#07111F` | 17.78:1 |
| Noche, bodega | `#6E9DE6` | `#07111F` | 6.88:1 |

Fichas recalculadas desde OKLCH: suaves, relleno L 0.34 C 0.075 y texto/contorno L 0.84 C 0.12; intensas, L 0.44 C 0.12 y L 0.93 C 0.06. Matices: hierba 145°, cielo 230°, rosa 10°. Se aplicó la reducción de croma de 0.002 del instrumento, conservando L y h; los seis pares resultantes coinciden con las constantes Dart.

| Ficha de noche | Relleno | Código y contorno | Texto/relleno | Contorno/peor fondo nocturno |
|---|---|---|---:|---:|
| Hierba suave | `#1B421E` | `#98DF9A` | 7.24:1 | 10.08:1 |
| Hierba intensa | `#1A6323` | `#D0F3D0` | 6.10:1 | 13.15:1 |
| Cielo suave | `#003E55` | `#84D7FE` | 7.21:1 | 9.92:1 |
| Cielo intensa | `#005B7A` | `#CCEEFF` | 6.21:1 | 13.02:1 |
| Rosa suave | `#58252F` | `#FFB2BD` | 7.18:1 | 9.33:1 |
| Rosa intensa | `#873043` | `#FFDFE2` | 6.67:1 | 12.76:1 |

Celda atenuada: composición del relleno al 35 % sobre el papel, redondeada aquí a sRGB de 8 bits. El código del producto calcula con `Color` y la suite comprueba el contraste compuesto, sin alfa en el texto.

| Modo y estado | Fondo compuesto | Contraste con tinta suave | Texto elegido por la regla | Contraste final |
|---|---|---:|---|---:|
| Día, cubierta | `#A4BADC` | 3.50:1 | Tinta `#10243F` | 7.90:1 |
| Día, bodega | `#AAC2EF` | 3.85:1 | Tinta `#10243F` | 8.67:1 |
| Noche, cubierta | `#5A626C` | 3.11:1 | Tinta `#EAF0F9` | 5.39:1 |
| Noche, bodega | `#2B4265` | 5.10:1 | Suave `#A9B9D2` | 5.10:1 |

Se confirma el respaldo a tinta cuando la suave no llega a 4.5:1. Los valores aproximados 3.5 y 3.1 de la decisión son los casos de cubierta, no todos los rellenos. En 13.4, «recorte de gama» incluye una tolerancia de ±0.002 en RGB lineal y posterior limitación al rango sRGB; por eso no se sustituyó la receta por otra conversión arbitraria.

## 5. Piezas, pruebas y vistas previas

`t114_fase2bis_test.dart` aporta **24 pruebas**: noche y tema M3, roles, atenuación, permutación, distancias, 24 fichas de cada modo, preferencia de tema y contraste compuesto de los estados de celda. `t114_piezas_test.dart` aporta **39**. Junto con las cuatro de corrección, el piso pasa de 1156 a **1223**. Los cambios en `t114_fundacion_test.dart` y `t114_fase3_inicio_test.dart` solo renombraron una prueba cada uno; sus aserciones no se debilitaron.

| Pieza | Qué comprueban las pruebas entregadas | Vista previa propia |
|---|---|---|
| `BsMarca` | Tres variantes, tamaño, pintura aislada, etiqueta y espera con reducción de movimiento | `marca-dia.png`, `marca-noche.png` |
| `BsSiluetaBuque` | Bahías y niveles, etiquetas, selección, toque, ancho real de 56 dp, progreso y destello | `silueta-dia.png`, `silueta-noche.png` |
| `BsCascoBodega` | Pintura detrás de las filas y `RepaintBoundary` | Incluido en `celdas-dia.png` y `celdas-noche.png` |
| Estados y curva de `BsCelda` | Prioridad del estado, radios 8/18, palomita, punteado, etiquetas y destino del desplazamiento; falta comprobar el desplazamiento intermedio (H1) | `celdas-dia.png`, `celdas-noche.png`, `celdas-muelle-dia.png`, `celdas-muelle-noche.png` |
| `BsTarjetaCifra` | Cifra, rótulo, detalle, rol, etiqueta compuesta y toque | `cifras-dia.png`, `cifras-noche.png` |
| `BsAnilloAvance` | Tamaño, porcentaje, aislamiento de pintura e inclusión en la tarjeta | Incluido en las dos vistas de cifras |
| `BsPanelEnVivo` | Rol, acción, resumen, estado vacío y región en vivo únicamente en el evento más reciente | `en-vivo-dia.png`, `en-vivo-noche.png` |
| `BsBandaMuelle` | Marca sin recuadro, viaje, nube y selección Descarga/Carga | `banda-muelle-dia.png`, `banda-muelle-noche.png` |
| `BsFondoDePlano` | Rejilla solo de noche y papel de día | `fondo-dia.png`, `fondo-noche.png` |

Las tres pautas se ejecutan en **7 agrupaciones × 2 temas = 14 casos**, con tres aserciones por caso: `textContrastGuideline`, `androidTapTargetGuideline` y `labeledTapTargetGuideline`. Casco/celdas y tarjeta/anillo comparten agrupaciones; son nueve piezas cubiertas, no nueve casos individuales por pauta. Las ocho vistas previas también se construyen en ambos temas. Se inspeccionaron los PNG propios con Plex, Roboto y Material Icons cargados expresamente; no son capturas de Windows, Android o Chrome, ni una aceptación de las pantallas futuras.

**Movimiento reducido, comprobación propia:** cuatro piezas (marca en espera, `BsPulso`, destello de silueta y celda recién movida) × dos temas × dos entradas (reducción activada desde el inicio o durante el movimiento) = **16 casos**. Se compararon píxeles a los 100, 600 y 2200 ms acumulados, se comprobó ausencia de animaciones en marcha y de `AnimatedSlide`/`TweenAnimationBuilder` activos en esas rutas. Todos pasan. El destello permanece como anillo fijo; la celda queda naranja en su sitio. Registros: `comprobacion_propia_test.dart`, `movimiento-y-previas.txt`. Sus 17 pruebas pasan (16 de inmovilidad y una que captura las vistas); la captura se repitió aparte con espera de pintura de 50 ms: `capturas-con-fuentes.txt`.

**Datos no inventados:** el actor de `BsEventoEnVivo` es `final BsEquipo quien`, limitado a `muelle` y `oficina`; no hay parámetro de nombre ni identificador de actor. El panel sigue aceptando textos de evento, contenedor, posición y resumen: el enum no es un sanitizador general de esos textos. Leí el pintor completo de `BsSiluetaBuque`: dibuja casco, flotación, tapas, pilas, marcos y destello; **no dibuja superestructura ni grúa**.

## 6. Diez afirmaciones concretas de DESIGN.md 13

| N.º | Afirmación contrastada | Código y decisión | Coincidencia |
|---:|---|---|---|
| 1 | Noche `#07111F`, panel `#0C1A31`, panel alto `#11223F`; tinta `#EAF0F9` y suave `#A9B9D2` | `BsPaleta.oscuro`, tema y 10.14 | Sí; contrastes recalculados. |
| 2 | Marca de noche como superficie `#0D47A1`, `primary #4F8EF7`; segmentos/chips seleccionados invertidos | `bs_tema.dart`; dos decisiones aceptadas en 10.16 | Sí. |
| 3 | «Por bajar» nocturno: cubierta blanca y bodega acero con texto noche; bajado vacío y punteado | Roles y `BsCelda`; 10.14 | Sí. |
| 4 | Atenuada al 35 %, texto suave y respaldo a tinta bajo 4.5:1 | `BsRol.atenuado` y llamada de `BsCelda`; regla nueva de 10.16 | Sí. |
| 5 | Radio celda 8; panel y esquina de casco 18; casco contorno 1.5 dp | Ambas densidades de `BsMedidas`, `BsCascoBodega` | Sí. |
| 6 | Rejilla de 32 dp, acero al 5 %, solo de noche | `BsFondoDePlano`, `pasoRejilla` | Sí. |
| 7 | Fichas intensas L 0.44/C 0.12 y código L 0.93/C 0.06; permutación sin cambiar códigos/FNV | Constantes de colores y script; 10.14 y 10.16 | Sí; seis fichas recalculadas y sección de tablas/FNV idéntica a la base. |
| 8 | Salida de celda 150 ms, estado/destello 1500 ms, espera 1200 ms y pulso 2200 ms; nada se mueve con reducción | Constantes coinciden; los bucles de espera/pulso usan `repeat(reverse: true)` (la duración del controlador corresponde a cada sentido). La pantalla debe retirar el estado de celda a los 1500 ms | **Parcial: falla la salida de 150 ms, H1.** Reducción pasa; el destello se extingue con su tween. La celda no tiene reloj, por contrato. |
| 9 | API de silueta con `alto = 112` y botones de 48 dp | Constructor sin `alto`, altura calculada por niveles y escala tipográfica; `anchoBahia = 56` | **No: desajuste documental O1 nuevo.** El informe de Timonel sí describe 56 dp y altura adaptable. |
| 10 | Cifra grande a 40/600 tabular en la tarjeta, radio 18 | `BsEscala.cifraGrande = 34`, `BsTextos.cifraGrande` a 600 con cifras tabulares; radio 18 | **No en tamaño: O2 nuevo.** Código e informe conservan 34, coherente con 13.10 que dice no cambiar la tipografía. |

El naranja de «Más» en 13.3.6 contradice la regla general de 10.14 y el wireframe de 13.8, que pone alertas en aviso. **Ya está resuelto como criterio en 10.16:** alertas en aviso o error; hay que actualizar ese párrafo, no implementarlo literalmente. La declaración histórica «tema por equipo propuesto» de 13.5 tampoco abre una autorización nueva: manda «seguir al sistema», como decidió Carlos en 10.16.

## 7. Observaciones y criterio de reaceptación

- **H1 nuevo, bloquea la Fase 2 bis:** salida instantánea de la celda. Corregir la transición y probar fotogramas intermedios; conservar inmovilidad accesible. La suite de 1223 no cubre este defecto visual.
- **O1 nuevo, documentación:** actualizar DESIGN.md 13.6 a la API real de la silueta: sin `alto`, altura adaptable y ancho 56. No se propone reducir el objetivo táctil para hacer coincidir un documento atrasado.
- **O2 nuevo, documentación:** resolver 40 frente a 34 en la cifra; la corrección coherente con el código, el informe y la conservación de tipografía de 13.10 es documentar 34.
- **O3, pendientes ya declarados en 10.16:** corregir el naranja de «Más» y la prueba frágil de procedencia de `LICENSE-IBMPlex.txt`. Esta copia CRLF pasa; la prueba aún compara tamaño y SHA de bytes sin normalizar el texto. No se alteró la licencia ni se debilitó su comprobación.
- **O4, precisión de auditoría:** no informar «cero avisos automáticos» fuera de los tokens: existe uno por `Duration.zero`, preexistente y justificado. Son cero hallazgos accionables en ese ámbito. No se debe eliminar el interruptor de accesibilidad para silenciarlo.

La corrección `3144b64` puede darse por cerrada independientemente. El bloqueo nuevo queda limitado a la fundación `36f5784`; no invalida los contrastes, las mediciones históricas ni la decisión de tema. Después del arreglo se necesita una prueba de salida que falle con esta versión y pase con la corregida, conservar el piso completo y el análisis limpio, y repetir los casos de movimiento reducido de la pieza.

## 8. Archivos, integridad y entrega

**Único archivo nuevo para versionar en esta aceptación:** `docs/rediseno/fase2bis/aceptacion-codex.md` (este informe). No se modificó ningún archivo del producto, prueba entregada, herramienta entregada ni documento de Carlos/Yov. `pubspec.yaml` y `pubspec.lock`: **sin cambios**.

Se comprobó el contenido de **495 archivos versionados** de `lib/`, `test/`, `tool/` y `pubspec.*` frente a HEAD, normalizando exclusivamente CRLF/LF: ninguna diferencia. `git diff --name-only HEAD` tampoco muestra diferencias de contenido versionado; los regenerados de Windows solo producen avisos de conversión de fin de línea. `alcance.json` y `diff-trabajo-final.txt` guardan esas comprobaciones.

Los archivos propios de diagnóstico son `build/t114-fase2bis-aceptacion/inspeccion.py`, `no_lo_tengo_test.dart`, `comprobacion_propia_test.dart` y `salida_celda_test.dart`. Los registros, JSON, capturas y su inventario con SHA-256 quedan junto a ellos en `inventario-evidencia.json`. La compilación solicitada queda en `build/qa-r4-web/`. Son salidas bajo `/build/`, ignoradas por `.gitignore`; se conservan localmente y no se propone forzar su incorporación a Git.

**Tres líneas:**

La corrección 10.15 queda aceptada: «No lo tengo», evidencia Web, comparación de perfiles y referencia cerrados.
La suite entregada da 1223/1223, análisis y contraste limpios, movimiento reducido verificado y T-92 correcto.
La Fase 2 bis NO PASA por la salida instantánea de la celda; quedan precisiones documentales y los pendientes ya declarados.

**Mensaje para Yov:**

> Yov: Capitán Codex terminó la aceptación en `C:\Proyectos\baystream-qa-r4`, HEAD `c287792`, contra `e22e400`. Corrección `3144b64` ACEPTADA: repetí el diagnóstico original (3/3), pasaron las cuatro nuevas; O1–O3 cerrados. La fundación `36f5784` NO PASA por H1 nuevo: `BsCelda` crea `AnimatedSlide` directamente en `Offset(0,-0.5)` y salta, sin recorrer los 150 ms de DESIGN.md 13.3. Prueba propia con movimiento permitido: posiciones y píxeles iguales a 0/75/150 ms; reproducción y JSON en `build/t114-fase2bis-aceptacion/salida_celda_test.dart` y `salida-celda.json`. La prueba entregada solo comprueba el destino. Lo demás: alcance 11+27+SPRINT=39; suite 1223/1223 sin omitidas; analyze 0; contraste 0 bajos y cálculo independiente correcto; 16 casos propios de inmovilidad pasan; T-90 sigue al sistema, función por equipo sin conectar; T-92 correcto (56 archivos). Observaciones: DESIGN 13.6 dice silueta 48/alto112 y cifra40, código 56/altura adaptable y cifra34; auditoría tiene un aviso automático preexistente por Duration.zero fuera de tokens, cero accionables. Siguen los pendientes de 10.16 sobre «Más» y licencia LF/CRLF. No corregí producto ni ejecuté Git de escritura. Informe: `docs/rediseno/fase2bis/aceptacion-codex.md`. El arreglo de la pieza va antes de su integración.

**Git para Carlos, desde esta copia; un solo informe y un solo commit:**

```powershell
git add -- docs/rediseno/fase2bis/aceptacion-codex.md
git commit -m "Sprint 4: aceptacion de correccion y fase 2 bis, salida de celda pendiente"
git push
```
