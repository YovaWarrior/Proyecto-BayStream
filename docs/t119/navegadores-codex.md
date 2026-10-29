# T-119 · Chrome y Edge · Aceptación Web adelantada de Capitán Codex

**Dictamen: aceptación Web parcial; no certifico 9/9.** La rueda, el pestillo, el desplazamiento y la barra cumplen en los dos navegadores. Las conductas sintéticas nuevas se distinguen del control anterior a T-119, que falla en 1, 2, 3, 4 y 6, cada una en sus aserciones y sin fallar al compilar. El pellizco gradual presenta una pequeña deriva al pasar de bahía centrada a desbordada (**O-119-1, P3**). Ctrl + rueda como gesto de zoom de página y los atajos de navegador quedan **NO CONCLUYENTES**: no consiguieron ampliar el control local. La prueba manual de Carlos del 29-oct es evidencia independiente y rige esas partes.

29 de octubre de 2026, Guatemala. `C:\Proyectos\baystream-qa-r4`, HEAD separado `cce3c4c`. Esta entrega adelanta exclusivamente los pasos Web 1–9. No cierra T-119 ni la 0.4.1; quedan para la aceptación que decida Carlos el código, la suite, Windows a 200 % con H7/T-105 y el pellizco interrumpido de 10.77.

## 1. Base, autorización y aislamiento

Se leyó primero AGENTS.md y después, en el orden pedido, SPRINT-4 10.76/10.77/10.79, T119-RESULTADOS 3–9, DESIGN 16, las claves y cifras de `t119_mouse_touchpad_test.dart`, los dos bancos T100, T114 Web, los conductores T122–T125 y la aceptación T125. El log da `cce3c4c`, `65db312`, `cf7cf3f`. `git diff --stat 65db312 cce3c4c` enumera las 22 rutas de T-127 y ninguna de las ocho rutas de lib/ de T-119. `fuentes-T119.json` coteja esas ocho fuentes con `git show cce3c4c:<ruta>`.

Carlos dio «Luz verde ahora» antes de usar Flutter o abrir navegadores. Se anunciaron inicio y cierre de ventana con SEMÁFORO. Se ejecutó Flutter de uno en uno, en copias bajo `build/t119-navegadores/`, con `pub get --offline` y `build web --release --no-web-resources-cdn --no-pub -t tool/t100_main.dart`. Ambas compilaciones dieron exit 0; no hizo falta recurrir al árbol completo de 83d7b85. Se conservan sus avisos de fuentes y Wasm en los logs. La primera llamada a Flutter dentro del aislamiento, sin salida ni proceso Dart visible, se interrumpió; la preparación efectiva se ejecutó con la autorización del entorno. No se borraron ni forzaron bloqueos.

Las copias nacieron sin .git, build ni .dart_tool. Flutter creó sus cachés nuevas dentro de ellas. La anterior reemplaza exactamente los seis blobs por sus versiones de `83d7b85`, obtenidos con git show, y excluye los dos archivos nuevos de lib/; `copias.json` identifica rutas y huellas. La Web actual y la anterior se sirven únicamente en `127.0.0.1:5927` y `127.0.0.1:5928`. No se tocaron `build/t119/web`, Windows, los puertos reservados ni el emulador de la Expo.

El banco es `tool/t100_main.dart` sin T100_FIREBASE: Firebase no se inicializa y el almacén Web es IndexedDB del contexto/origen local, namespace t100. T100_LLEGADA fue generado por `tool/t100_sintetico.dart` en TEMP y copiado al mismo origen (`/t114/T100_LLEGADA.edi`). El manifiesto sintético y su salida verifican 60 contenedores, 30 de descarga GTSTC y 30 de paso. El conductor usa «Seleccionar archivo», t114Preparar, la elección real de GTSTC y «Confirmar y ver»; las capturas muestran «Publicado» y «Viaje M100 · Escala GTSTC». Perfiles/contextos temporales nuevos, sin cuentas ni extensiones; sin datos del corpus, piloto, Honor ni apps instaladas.

| Entorno | Chrome | Edge |
|---|---|---|
| Instalado, canal Playwright | chrome **156.0.8078.73** | msedge **156.0.4314.50** |
| Playwright | 1.62.0 | 1.62.0 |
| Ventana efectiva, CSS px | 731 × 700 | 731 × 700 |
| innerWidth × innerHeight | 716 × 606 | 708 × 610 |
| Completa: ventana / vista | 1536 × 816 / 1536 × 730 | 1536 × 816 / 1528 × 732 |
| Windows / DPR inicial / visualViewport.scale | 125 % / 1,25 / 1 | 125 % / 1,25 / 1 |

Windows declara AppliedDPI=120. La consulta GetDpiForSystem desde el proceso no consciente de DPI devuelve 96; no se tomó ese valor virtualizado como escalado efectivo. Se solicitó ventana de 730 × 700 (aproximadamente media pantalla), ajustada para que los 560 dp de silueta no cupieran. Las capturas y métricas registran `visibility=visible` y foco; los navegadores se ejecutaron secuencialmente y se cerraron. No se minimizaron ni ocultaron deliberadamente.

## 2. Calibración e instrumento

`control.html` es una página local sin Flutter, sin escuchas que cancelen rueda/teclado y sin recursos externos. Cada evento se aplicó con el mismo canal de entrada que en el producto, guardando capturas y métricas antes/después. No se sustituyeron los eventos fallidos por un mecanismo que los hiciera aprobar.

| Evento en control | Chrome | Edge |
|---|---|---|
| Ctrl + rueda, mouse.wheel −140 con Control | DPR 1,25, ancho 716, escala visual 1: sin cambio; **no calibrado** | DPR 1,25, ancho 708, escala visual 1: sin cambio; **no calibrado** |
| CDP Input.synthesizePinchGesture, mouse, ×1,5 | Escala visual 1 → 1,5; **calibrado** | Escala visual 1 → 1,5; **calibrado** |
| Control+Equal, atajo habitual de + | Sin cambio en DPR/anchura/escala; **no calibrado** | Sin cambio en DPR/anchura/escala; **no calibrado** |

El pellizco usa `gestureSourceType: mouse`, `relativeSpeed: 400`. En el plano se envían ×1,8 y ×(1/1,2); Flutter muestra aproximadamente 134 y 122 %, porque CDP los traduce a una secuencia de ruedas Ctrl que el motor convierte a escala. Se registran sus deltas, coordenadas y `isTrusted`. La prueba adicional desde 150 % usa ×1,4. Mouse.wheel horizontal/vertical representa aquí dos dedos sin pellizcar; no son contactos físicos.

**Lectura semántica calibrada:** el motor local Flutter 3.38.9, `semantics/scrollable.dart`, escribe scrollTop también para desplazables horizontales y compensa su scrollLeft. El DOM acumula así un desplazamiento vertical ajeno a la pintura. En intentos iniciales, la celda parecía derivar 131 dp en DOM mientras la captura la conservaba. El conductor definitivo guarda `rawY`, `correctionY` y el rectángulo corregido: suma solo el scrollTop de ancestros horizontales, identificados por el indicador `flt-semantics-scroll-overflow` de altura 1. No escribe esas posiciones ni modifica escuchas del producto. La lectura y SHA del motor están en `motor-semantica.json`. El mismo cálculo se aplica a actual y anterior. Los rectángulos pueden recortarse al quedar parcialmente fuera: en la pista se sigue el borde derecho aún visible de la celda, no su borde izquierdo recortado.

El contraste auxiliar `validar_pixeles.py` busca el borde de la celda vacía en las PNG y conserva sus coordenadas y diferencia con la semántica; es diagnóstico con antialias, no reemplaza las aserciones. Se inspeccionaron además las capturas de celda y barra. Los cuadros de pellizco se muestrean con requestAnimationFrame y guardan centro de celda y métricas de página.

## 3. Pasos 1–9 sobre la Web actual

Los números son CSS px/dp de la semántica; 1 dp corresponde a 1,25 píxeles físicos en estas ventanas. Las pequeñas diferencias por navegador se conservan. «CumpleConducta» del JSON no es el dictamen: requiere calibración positiva, y en el paso 8 su valor vacío no constituye aprobación.

| Paso | Chrome | Edge |
|---|---|---|
| 1 | **CUMPLE.** Silueta 532,737 < 560 dp; X de bahía 06: 363,252 → 347,252 → 363,252; en popa, celda Y 305,2 → 289,2. | **CUMPLE.** Silueta 524,737 < 560 dp; X de bahía 06: 363,252 → 347,252 → 363,252; en popa, celda Y 305,2 → 289,2. |
| 2 | **CUMPLE.** Y 305,2 → 297,2 → 289,2 → 289,2; tras 380 ms, X 363,252 → 355,252. Puntero quieto: X 343,252 → 343,252 → 347,252; Y 289,2 → 293,2 → 293,2. | **CUMPLE.** Y 305,2 → 297,2 → 289,2 → 289,2; tras 380 ms, X 363,252 → 355,252. Puntero quieto: X 343,252 → 343,252 → 347,252; Y 289,2 → 293,2 → 293,2. |
| 3 | **NO CONCLUYENTE por calibración.** Conducta Flutter sí cumple: chip 100 → 165 → 149 → 300 → 75 %; deriva 0,426 → 0,323 dp, tope quieto; DPR/anchura/escala visual constantes. | **NO CONCLUYENTE por calibración.** Conducta Flutter sí cumple: chip 100 → 165 → 149 → 300 → 75 %; deriva 0,427 → 0,323 dp, tope quieto; DPR/anchura/escala visual constantes. |
| 4 | **NO CUMPLE el anclaje <1 dp al cruce.** Chip 100 → 134 → 122 %; deriva 1,885 → 1,694 dp; máximo entre cuadros 1,885 dp. Ya desbordada desde 150 %: final 0,059, máximo 0,059 dp. | **NO CUMPLE el anclaje <1 dp al cruce.** Chip 100 → 134 → 122 %; deriva 0,771 → 0,689 dp; máximo entre cuadros 1,358 dp. Ya desbordada desde 150 %: final 0,059, máximo 0,059 dp. |
| 5 | **CUMPLE.** Centros (X,Y): (603,252; 413,2); (603,252; 385,2); (603,252; 413,2); (555,252; 413,2); (603,252; 413,2); chip 200 % constante. | **CUMPLE.** Centros (X,Y): (603,252; 413,2); (603,252; 385,2); (603,252; 413,2); (555,252; 413,2); (603,252; 413,2); chip 200 % constante. |
| 6 | **CUMPLE.** Aire 14 dp; arrastre 115,222 dp; pista 352,053, esperado 352,042 dp (limitado por el extremo). Ventana completa al 100 %: hueco a texto de franja 22,013 dp, igual a base 22; sin barra. | **CUMPLE.** Aire 14 dp; arrastre 116,766 dp; pista 358,509, esperado 358,497 dp (limitado por el extremo). Ventana completa al 100 %: hueco a texto de franja 22 dp, igual a base 22,013; sin barra. |
| 7 | **NO CONCLUYENTE en conjunto.** Pellizco: página quieta, cumple su parte calibrada; chip 100 → 135 → 148 %. Ctrl + rueda sin calibración positiva. DPR/innerWidth/visualScale sin cambio. | **NO CONCLUYENTE en conjunto.** Pellizco: página quieta, cumple su parte calibrada; chip 100 → 135 → 148 %. Ctrl + rueda sin calibración positiva. DPR/innerWidth/visualScale sin cambio. |
| 8 | **NO CONCLUYENTE / informativo, sin aprobación ni rechazo.** Cabecera y panel lateral: chip 100 → 100 %; DPR, innerWidth y escala visual sin cambio con ambos eventos. | **NO CONCLUYENTE / informativo, sin aprobación ni rechazo.** Cabecera y panel lateral: chip 100 → 100 %; DPR, innerWidth y escala visual sin cambio con ambos eventos. |
| 9 | **NO CONCLUYENTE por instrumento.** +, − y 0 no cambian las métricas; el + tampoco amplió el control. Rige la evidencia manual de Carlos. | **NO CONCLUYENTE por instrumento.** +, − y 0 no cambian las métricas; el + tampoco amplió el control. Rige la evidencia manual de Carlos. |

En el paso 2 se hicieron dos comprobaciones: rejilla → silueta dentro de 300 ms, como la sonda de widget, y cruce con puntero inmóvil. En el segundo, eventos negativos hacen descender el contenido y entrar la silueta —situada antes de la rejilla— bajo el puntero; un paso inmediato sigue con la columna y otro después de 380 ms mueve la silueta. `eventos-rueda.json` conserva los timestamps para comprobar los intervalos.

Los 380 ms son la pausa solicitada al conductor. Los intervalos reales entre eventos, tomados de sus timestamps, fueron **210,2 y 549,4 ms en Chrome**, y **115,8 y 513,9 ms en Edge** para la comprobación directa. En el cruce con puntero inmóvil fueron **131,3 y 486,0 ms**, y **128,9 y 474,4 ms**, respectivamente: el primer intervalo queda dentro de 300 ms y el segundo fuera. `intervalos-pestillo.json` conserva también los del control rojo.

En el paso 3, el desplazamiento interno que conserva el foco es deliberado: se comprueba la celda quieta y el tope sin desplazamiento residual, junto con las métricas de página. No se exige que los controladores internos queden iguales cuando el anclaje necesita compensarlos.

En el paso 6, el clic en pista alcanza el extremo antes de completar el 80 % de la vista. Se contrasta con `min(tope, posición + 0,8 × vista)`; el tope se obtiene del indicador semántico horizontal. La barra queda en el aire inferior de 14 dp: el área de contenido termina antes de su pista y la franja de cifras queda debajo. Al maximizar y volver al 100 %, la separación semántica hasta el texto de la franja es 22 dp, igual a la base sin barra. A 200 % maximizado, Edge todavía desborda unos píxeles y Chrome cabe; se registra esa diferencia sin exigir que ambos oculten la barra al 200 %.

P7 se observa con números en el producto y en el control rojo: el pellizco calibrado no altera DPR, innerWidth ni visualViewport.scale sobre el plano. Para Ctrl + rueda no se certifica la cancelación del zoom de navegador porque ese canal tampoco lo consiguió en el control. La evidencia manual de Carlos conserva su valor para ese gesto y para los atajos.

## 4. Control rojo sin T-119

Las cuatro corridas definitivas ejecutaron el mismo SHA-256 de `conductor.py`, identificado en `matriz-definitiva.json` y copiado como `conductor-ejecutado.py` en cada salida. La copia anterior compila y abre por el mismo flujo. Las aserciones no dependen de la versión.

| Paso | Chrome anterior | Edge anterior |
|---|---|---|
| 1 | Falla: X 363,252 → 363,252 → 363,252; abajoAvanza, arribaRegresa, columnaQuietaDuranteSilueta, extremoPasaColumna. | Falla: X 363,252 → 363,252 → 363,252; abajoAvanza, arribaRegresa, columnaQuietaDuranteSilueta, extremoPasaColumna. |
| 2 | Falla: después de pausa X 363,252 → 363,252; trasPausaMueveSilueta, conPunteroQuietoTrasPausaSilueta. | Falla: después de pausa X 363,252 → 363,252; trasPausaMueveSilueta, conPunteroQuietoTrasPausaSilueta. |
| 3 | Falla al ampliar: chip 100 → 100 → 100 → 100 → 100 %. Sin calibración positiva del zoom de página para Ctrl. | Falla al ampliar: chip 100 → 100 → 100 → 100 → 100 %. Sin calibración positiva del zoom de página para Ctrl. |
| 4 | Falla al ampliar: chip 100 → 100 → 100 %. El pellizco del control sí amplía la vista visual. | Falla al ampliar: chip 100 → 100 → 100 %. El pellizco del control sí amplía la vista visual. |
| 5 | NO CUMPLE: (603,252; 413,2); (603,252; 413,2); (603,252; 413,2); (507,252; 413,2); (603,252; 413,2). | NO CUMPLE: (603,252; 413,2); (603,252; 413,2); (603,252; 413,2); (507,252; 413,2); (603,252; 413,2). |
| 6 | Falla: aire 0, arrastre 0, pista 0 dp. | Falla: aire 0, arrastre 0, pista 0 dp. |
| 7 | Página sin cambio; chip 100 → 100 → 100 %. La cancelación del pellizco de página ya existía, pero el plano no amplía. Ctrl: NO CONCLUYENTE por control. | Página sin cambio; chip 100 → 100 → 100 %. La cancelación del pellizco de página ya existía, pero el plano no amplía. Ctrl: NO CONCLUYENTE por control. |
| 8 | Registro: cabecera/panel, chip 100 %, DPR/anchura/escala visual constantes; sin dictamen. | Registro: cabecera/panel, chip 100 %, DPR/anchura/escala visual constantes; sin dictamen. |
| 9 | NO CONCLUYENTE: atajo sin efecto también en el control. | NO CONCLUYENTE: atajo sin efecto también en el control. |

Los fallos de 1, 2, 3, 4 y 6 son de conducta, no de preparación, compilación ni excepciones JS. No se interpreta que 7 deba «ponerse rojo» por amplificar el navegador: el motor ya cancelaba el pellizco de página, como anticipa T119-RESULTADOS 6. Las mediciones distinguen esa cancelación previa del zoom de plano nuevo.

## 5. Observaciones y límites

**O-119-1 · P3 · Pequeña deriva al pellizcar gradualmente desde una bahía que cabe centrada.** Reproducción: banco T100, GTSTC publicado, bahía 02, ventana estrecha, chip 100 %, foco en «Celda 002-00-82, libre», CDP mouse ×1,8 y después ×(1/1,2). El chip sí cambia y la página queda quieta, pero el centro se aparta más de 1 dp en ambos navegadores (tabla 3 y p4-cuadros.json). Desde 150 %, ya desbordada, el anclaje permanece por debajo de 1 dp. Las corridas de construcción del instrumento también conservan el síntoma, con distinta cuantización temporal. La explicación compatible con las medidas es que el centrado y el límite cero del desplazamiento horizontal restringen la compensación durante los primeros incrementos; es una inferencia del código y las medidas, no una prueba con touchpad físico. No se modificó el producto ni se aumentó la tolerancia. Propuesta para Carlos: decidir en la 0.4.1 si acepta ese límite de centrado o pide reproducirlo físicamente y corregirlo; no se propone código aquí.

**O-119-2 · P3 · Instrumento sin calibración positiva para Ctrl + rueda y el atajo de navegador.** La página de control permanece en DPR 1,25 / escala 1 / anchura inicial. Los pasos afectados se dejan NO CONCLUYENTES y rige la prueba manual de Carlos. No se atribuye al producto la incapacidad de este canal de Playwright para ejecutar el zoom de página.

**O-119-3 · P3 · Precauciones de lectura semántica y construcción del banco.** Se conservan todos los intentos: controles fuera del pliegue antes de reutilizar el desplazamiento del ayudante T114, rectángulos DOM desplazados por el motor y sobrepasos horizontales que regresaron al historial de la pestaña. El conductor final mantiene los reinicios dentro del recorrido medido y separa el historial del control. La primera matriz completa también tenía una aserción errónea: suponía que al 200 % maximizado cabía en Edge. Se sustituyó por la medición directa al 100 % y se repitieron las cuatro corridas con la misma revisión final. Ninguna de esas fallas iniciales se presenta como defecto de T-119 ni se suma como caso distinto.

Los eventos sintéticos no son el touchpad. CDP mouse ofrece una secuencia de escala, sin contacto/pan simultáneo ni ciclo nativo PointerPanZoomStart/End verificable: el anclaje y las métricas se midieron durante el gesto, pero la congelación ante un desplazamiento físico simultáneo queda NO CONCLUYENTE. No se probó pérdida de foco ni pellizco que no termina; corresponde a 10.77 en la aceptación completa. **O-040-1, el gesto físico que regresa el navegador, no se puede reproducir y atribuir con este conductor**. Las navegaciones accidentales de las ruedas de reinicio excesivas no acreditan esa reproducción. No se probaron pantallas táctiles.

## 6. Red, integridad y evidencia

| Corrida definitiva | Peticiones registradas | Host externo | Errores JS |
|---|---:|---:|---:|
| actual-chrome | 26 | 0 | 0 |
| actual-edge | 26 | 0 | 0 |
| antes-chrome | 26 | 0 | 0 |
| antes-edge | 26 | 0 | 0 |

Se interceptaron y registraron las peticiones del contexto y sus recursos. La guarda aborta cualquier HTTP(S)/WS(S) cuyo host no sea 127.0.0.1 y detiene la matriz; no se observó ninguno. Se bloquearon service workers para que no eludieran la guarda. Esto acredita el tráfico de las páginas/contextos de prueba, no una captura de todo el tráfico del sistema operativo. Firebase se mantuvo desactivado y los recursos Web se compilaron locales. Los perfiles temporales nunca son los de Carlos.

`cotejo-originales.json`: **624 archivos originales al inicio y 624 al cierre; 0 cambios** en lib/, test/, tool/, web/, assets/ y pubspec.*. Las ocho fuentes T-119 de la copia actual son idénticas byte por byte al original. Frente a cce3c4c coinciden al normalizar CRLF a LF: el árbol de Windows tiene CRLF y los blobs Git tienen LF. `fuentes-T119.json` conserva ambas huellas y el cotejo normalizado; `verificacion-fines-linea.json` registra esa diferencia de formato, que hizo fallar la primera aserción demasiado estricta de identidad con el blob. Las huellas de pubspec de ambas copias son idénticas a las originales. Los tres regenerados de windows/flutter/ ajenos a producto no se tocaron ni se cuentan. No se ejecutaron Git de escritura, git status, Firebase, suite, analyze, Windows ni Honor.

La evidencia vive exclusivamente en `build/t119-navegadores/`, ignorada por /build/ de .gitignore. `LEEME.md` explica cómo repetir contra otra URL local; `conductor.py` es reutilizable y `repetir_matriz.py` secuencia ambos canales y versiones. `resumen.json`, `matriz-definitiva.json`, las cuatro carpetas `aceptacion-*`, sus capturas/eventos/peticiones/cuadros, los registros de compilación, las huellas de fuentes y los intentos previos quedan conservados. `manifest.json` incluye SHA-256 y tamaño de cada evidencia seleccionada y **la huella de este informe**. Excluye copias de compilación, cachés, perfiles y su propia autorreferencia; no fuerza nada de build/ a Git.

## 7. Entrega y decisión

Único archivo para Git: **docs/t119/navegadores-codex.md**. No cambian **pubspec.yaml ni pubspec.lock**, ni lib/, test/, web/, tool/, Firebase o archivos congelados del árbol original. Scripts, copias y evidencias quedan bajo build/t119-navegadores/.

Carlos mueve primero el informe a su árbol sprint-4; estos comandos son para él y no fueron ejecutados por Codex. La guarda evita reemplazar un informe existente:

```powershell
$destinoT119 = 'C:\Proyectos\baystream-rediseno\docs\t119\navegadores-codex.md'
if (Test-Path -LiteralPath $destinoT119) { throw 'Ya existe el informe de destino; revisar antes de mover' }
New-Item -ItemType Directory -Path 'C:\Proyectos\baystream-rediseno\docs\t119' -Force | Out-Null
Move-Item -LiteralPath 'C:\Proyectos\baystream-qa-r4\docs\t119\navegadores-codex.md' -Destination $destinoT119
Set-Location -LiteralPath 'C:\Proyectos\baystream-rediseno'
git add -- docs/t119/navegadores-codex.md
git commit -m "Sprint 4: aceptacion Web adelantada de T-119 en Chrome y Edge"
git push origin sprint-4
```

Tres líneas para Carlos:

1. Chrome y Edge: rueda, pestillo, desplazamiento y barra cumplen; hay pequeña deriva del pellizco al salir del centrado.
2. El rojo falla en 1, 2, 3, 4 y 6; Ctrl y atajos de página quedan NO CONCLUYENTES por calibración, con la prueba manual de Carlos aparte.
3. Producto intacto, evidencia y conductor con SHA-256; la aceptación completa de 0.4.1 sigue pendiente.

Mensaje para Yov: «Capitán Codex terminó la parte Web adelantada de T-119 sobre cce3c4c, en Chrome 156.0.8078.73 y Edge 156.0.4314.50, Playwright 1.62.0, con T100 y sin Firebase. Dictamen parcial: rueda, pestillo —también a puntero quieto—, desplazamiento y barra cumplen. O-119-1 P3: pequeña deriva >1 dp al pellizcar gradualmente desde 100 % al salir del centrado; desde 150 % desbordado queda <1 dp. Ctrl + rueda y atajos del navegador no ampliaron el control local y quedan NO CONCLUYENTES; rige la prueba manual de Carlos. El mismo conductor da rojo en 1, 2, 3, 4 y 6 contra los seis blobs de 83d7b85 sin los dos nuevos, con ambas Web compiladas. P7 del pellizco ya cancelaba la página antes. Informe único docs/t119/navegadores-codex.md; build/t119-navegadores/ contiene conductor reutilizable, LEEME y manifiesto con huella del informe. Producto y pubspec.* intactos; sin Git de escritura ni publicaciones. La aceptación completa de 0.4.1 queda para Carlos».

**ALTO: Carlos decide**
