# T-114 · Reaceptación de la salida de BsCelda (10.17)

**Dictamen: ACEPTADA con observaciones. H1 queda cerrado.** Capitán Codex · 22-oct-2026.

La celda sale desde su posición real, recorre la transición de 150 ms, respeta la reducción de movimiento y vuelve a «bajado» sin animación de regreso. La prueba nueva discrimina la versión defectuosa de la corregida. La suite da **1224/1224**, sin omitidas, y el análisis final queda en cero. Se confirma, sin corregirlo, el trabajo adicional de `AnimatedTheme` al reconstruir la raíz.

Copia inspeccionada: `C:\Proyectos\baystream-qa-r4`. HEAD **`8543cd24b51dbe90914c89beaae352abae654f15`**; base de alcance **`39bfd56`**; celda defectuosa de comparación **`36f5784`**. Se leyeron AGENTS.md, SPRINT-4.md 10.17 y la sección «Fase 2 bis · Corrección tras la aceptación de Codex» de REDISENO-RESULTADOS.md. Esta revisión se limita a la corrección; no vuelve a aceptar el plano ni otras entregas.

Evidencia: **`build/t114-fase2bis-reaceptacion/`**. Los registros abreviados de este informe parten de esa carpeta. Carlos dio luz verde expresa; todos los comandos Flutter fueron secuenciales y se liberó el semáforo al terminar. No se ejecutaron escrituras de Git ni `git status`, no se cambió de carpeta o rama, no se abrió la app instalada ni se tocó Firebase, Honor o emulador. Las pruebas usan widgets y datos sintéticos; los tiempos de fotogramas son del reloj de pruebas, no mediciones de latencia operativa.

## 1. Alcance

`git diff --stat=350 39bfd56..HEAD` devuelve exactamente **4 archivos**, 365 inserciones y 55 eliminaciones:

| Ruta | Cambio revisado |
|---|---|
| `lib/core/design/componentes/bs_celda.dart` | `_Salida` estable, controlador explícito, traslación y parada sin regreso |
| `test/t114_piezas_test.dart` | Una prueba nueva, dos reescritas y temas conservados entre montajes |
| `DESIGN.md` | Salida desde cero, regla de «Más» y cifras corregidas de silueta/tarjeta |
| `docs/REDISENO-RESULTADOS.md` | Entrega y evidencia declarada de la corrección |

No hay cambios en `domain/`, `data/`, `lib/main.dart`, `pubspec.*`, los congelados o las pantallas. Evidencia: `alcance-stat.txt`, `diff-producto-y-test.txt`, `alcance-e-integridad.json`. Se compararon **497 archivos versionados** de código, pruebas, herramientas y documentos objetivo contra HEAD, normalizando solo CRLF/LF: ninguna diferencia. La consulta final de diferencias del árbol tampoco muestra cambios versionados de contenido; los generados de Windows emiten únicamente avisos de fin de línea.

## 2. H1: reproducción y posición real

Ejecuté literalmente `build/t114-fase2bis-aceptacion/salida_celda_test.dart`. El arnés antiguo se detiene con **`Bad state: No element`** porque busca un `SlideTransition`, que ya no existe. Ese resultado está conservado en `reproduccion-original.txt`; no se interpreta como un fallo de la celda nueva ni se modifica la reproducción histórica.

La continuación de esa reproducción conserva la captura de píxeles y sustituye la lectura del widget interno por la **posición pintada del cuerpo**, usando `getTopLeft(Container)`. Así sirve tanto para `AnimatedSlide` como para `Transform.translate`. Se usa el mismo elemento con clave estable, pasando de `porBajarCubierta` a `recienMovido`. El tema se conserva entre montajes para aislar la animación de la pieza.

En **los dos temas y las dos densidades**, el origen fue y = 276 dp y el resultado fue idéntico en posición:

| Tiempo desde el cambio | Posición y | Traslación desde el origen |
|---:|---:|---:|
| 0 ms | 276.000 dp | 0.000 dp |
| 75 ms | 254.997 dp | −21.003 dp |
| 150 ms | 252.000 dp | −24.000 dp |
| Primer fotograma de «bajado» | 276.000 dp | 0.000 dp |
| 75 ms después de «bajado» | 276.000 dp | 0.000 dp |

Los 75 ms están **estrictamente entre** inicio y destino; no son 12 dp porque la curva no es lineal. Las tres huellas de píxeles son distintas en cada caso. A los 150 ms se alcanza media celda de 48 dp; después de un fotograma adicional no queda la animación en marcha. Al volver a «bajado» se restablece la posición inmediatamente, sin hueco de salida ni recorrido visible de regreso.

**Reducción de movimiento:** ocho casos propios (dos temas × dos densidades × activación desde el inicio o durante una salida). La posición permanece en su origen a 0 y 250 ms, el relleno sigue naranja, no aparece el hueco y no queda animación activa. Pasan los ocho.

Evidencia: `comprobacion_propia_test.dart`, `comprobacion-propia.txt`, `comprobacion-propia.json`. El archivo contiene **14 pruebas propias**, todas en verde: cuatro de trayectoria/regreso, ocho de reducción, una de costo y una del tema de la raíz.

La implementación coincide con lo observado: `_Salida` existe en todos los estados; `initState`/`didUpdateWidget` arrancan `forward(from: 0)` al entrar en salida; al dejarla se ejecutan `stop()` y `value = 0`; el cuerpo usa `Transform.translate`. La decisión de retirar el estado naranja a los 1500 ms sigue perteneciendo a la pantalla, como antes; esta corrección no introduce ese temporizador en la celda.

## 3. Prueba de Timonel y comparación de aserciones

Se extrajeron con **`git show`** los archivos de pruebas de `36f5784` y de HEAD, conservados en `piezas-36f5784.dart.txt` y `piezas-HEAD.dart.txt`. La comparación está en `diff-producto-y-test.txt`.

Para la contraprueba no se sustituyó ningún archivo de `lib/`: se copió la celda de `36f5784` a la carpeta de evidencia y se cambiaron únicamente sus imports relativos a imports `package:`. Una copia del archivo de pruebas actual importa esa celda y oculta sus seis nombres públicos en el barrel actual. Todo el resto de la aplicación sigue en HEAD. El código original extraído, su SHA-256 y el mecanismo de aislamiento quedan en `celda-36f5784.dart.txt`, `alcance-e-integridad.json` y `preparar_evidencia.py`.

| Ejecución | Resultado |
|---|---|
| Pruebas actuales de piezas con la celda vieja aislada | **39 éxitos, 1 fallo esperado, 0 omitidas** |
| Las mismas 40 pruebas de piezas con la celda actual, dentro de la suite | **40 éxitos, 0 fallos, 0 omitidas** |

El único fallo con la celda vieja es «la celda sale de verdad: de 0 a media celda en 150 ms desde su estado anterior, y vuelve de golpe»: en el primer fotograma espera **92 dp** y obtiene **68 dp**, exactamente el salto de 24 dp. Las dos pruebas reescritas pasan en ambas versiones; la nueva es la que detecta la regresión. Registros: `timonel-con-celda-vieja.jsonl`, `suite.jsonl`, `resumen-pruebas.json`.

**No se perdió una aserción de comportamiento sin reemplazo:**

| Prueba reescrita | Antes | Ahora y cobertura conservada |
|---|---|---|
| «recién movido sale de su celda, dice “Bajando” y cambia su etiqueta» | Exigía un `AnimatedSlide` y su destino `BsCelda.salida` | Comprueba la posición efectiva final, media celda arriba, en lugar del tipo interno. Conserva «Bajando», el pintor del hueco, la etiqueta completa, ausencia de animación tras asentarse y altura 52 dp. La prueba nueva añade los fotogramas intermedios y el regreso. |
| «con reducción de movimiento, recién movido se queda quieta y naranja» | Exigía que no hubiera `AnimatedSlide` | Comprueba desplazamiento cero y estabilidad de posición después de un segundo. Conserva «Subiendo», ausencia de `CustomPaint` del hueco, relleno naranja y ausencia de animación. |

Se abandonaron dos detalles de implementación obsoletos (presencia/ausencia de `AnimatedSlide`), reemplazados por geometría observable más fuerte. La caché de temas del arnés elimina una animación ajena a la pieza; no cambia sus colores ni reduce la cobertura de accesibilidad.

## 4. Costo con un plano lleno y liberación

Se montó un plano sintético de **24 filas × 40 columnas = 960 celdas**, visibles en una superficie de pruebas de 2400 × 1500 dp, con tema estable. Se inspeccionaron los controladores usados por los `AnimatedBuilder` de las celdas.

| Estado | Resultado |
|---|---|
| 960 celdas quietas | **0 controladores animando; 0 callbacks transitorios** |
| Una celda entra en salida | **1 controlador animando**, los otros 959 quietos; se conserva el mismo controlador |
| Salida terminada | **0 controladores animando** |
| Desmontaje durante otra salida | Los **960 controladores están liberados**; intentar `forward()` en cada uno produce la aserción esperada de controlador dispuesto; sin errores pendientes ni callbacks transitorios |

El código llama a `_controlador.dispose()` en `_SalidaState.dispose`. **Hay 960 controladores creados**, aunque estén quietos: la comprobación confirma ausencia de tickers activos y liberación, no ausencia de asignaciones ni un costo nulo de memoria. No es un benchmark de rendimiento del plano de producción. Evidencia de resultados y prueba: campo `costo` de `comprobacion-propia.json` y `comprobacion_propia_test.dart`.

## 5. Suite y análisis

- `flutter test --no-pub --reporter=json`: **1224 éxitos, 0 fallos, 0 omitidas**, incluidos los 40 de piezas. Registro completo y conteo de eventos: `suite.jsonl`, `resumen-pruebas.json`.
- `flutter analyze --no-pub`: **No issues found**, código de salida 0. Registro final: `analyze.txt`.

El primer análisis encontró dos incidencias exclusivamente en **mis arneses ignorados de `build/`**: una importación sin uso en `build/t114-fase2bis-aceptacion/no_lo_tengo_test.dart` y una recomendación de `const` en el arnés nuevo que fuerza el rebuild de `BayStreamApp`. Preservé la copia íntegra anterior del primer arnés en `no_lo_tengo_previo.dart.txt` y retiré solo esa importación; las aserciones y la lógica permanecen iguales (`limpieza-arnes.json`). En el segundo utilicé una factoría de constructor constante que sigue creando una instancia de app nueva en cada llamada. La comprobación propia se repitió: **14/14**. No se agregó ningún `ignore`, no se cambió configuración de análisis y no se corrigió producto para obtener el resultado limpio. El diagnóstico inicial se conserva en `analyze-inicial-arneses.txt`.

## 6. DESIGN.md: coincidencias y límite de la regla de «Más»

- **13.6, silueta:** coincide con `BsSiluetaBuque.anchoBahia = 56`. El constructor no recibe `alto`; `_Geometria` calcula la altura desde niveles de cubierta/bodega (hasta 6 por zona, paso 9 dp), márgenes y pie escalado. Se cierra O1 documental de la aceptación anterior.
- **13.6, cifra:** coincide con `BsEscala.cifraGrande = 34` y `BsTextos.cifraGrande` a peso 600 con cifras tabulares, usados por `BsTarjetaCifra`. Se cierra O2 documental.
- **13.3.1:** coincide con la salida real desde cero y la vuelta sin animación de regreso, verificadas en esta reaceptación.
- **13.3.6:** ahora manda el contador de «Más» a aviso o error, nunca grúa, coherente con 10.16/10.17. **La regla del futuro contador está corregida en el documento; no hay una implementación nueva de ese contador en este commit que permita dar su integración por aceptada.**

Precisión pendiente para la entrega del plano: el `BadgeThemeData` global aún tiene `backgroundColor: paleta.grua` en `bs_tema.dart:266–268`; el menú existente «Acciones» en `loading_plan_controls.dart:374–377` tiene un `Badge` sin color explícito y hereda ese naranja. Es código anterior y ajeno a las cuatro rutas de esta corrección. Por tanto, no afirmo que todos los contadores existentes ya cumplan la regla nueva; el contador de «Más» deberá usar el rol adecuado al integrarse. Esta observación no reabre H1 ni autoriza ampliar esta corrección.

## 7. Hallazgo de ThemeData/AnimatedTheme: confirmado

`BayStreamApp.build` sigue construyendo `BayStreamTema.claro(...)` y `BayStreamTema.oscuro(...)` en cada reconstrucción. La comprobación propia usa **la app real**, con `themePreferenceProvider` sustituido por una preferencia local fija en claro; no inicializa Firebase ni usa el almacén. Tras estabilizar la app, fuerza una nueva construcción de la raíz sin cambiar la preferencia ni el contenido visible.

Resultado:

| Comprobación | Resultado |
|---|---|
| Misma instancia de `ThemeData` | No |
| Igualdad por `ThemeData.operator ==` | No |
| Igualdad de `ColorScheme` | Sí |
| Duración del `AnimatedTheme` real | **200 ms** |
| Animación a 0, 150 y 199 ms | Activa |
| Tras el fotograma de 216 ms | Inactiva |

La evidencia confirma una transición extra en una reconstrucción con los mismos colores. **No se deduce solo de que la instancia sea nueva:** también se comprobó desigualdad por valor para estos temas y un ticker real de `AnimatedTheme`. No significa que cada celda reconstruya la raíz; el costo aparece cuando se reconstruye `BayStreamApp`. Se deja como observación confirmada, sin modificar `app.dart`, temas o proveedores. Evidencia: prueba «BayStreamApp: rebuild identico inicia AnimatedTheme de 200 ms» y campo `tema` de `comprobacion-propia.json`.

## 8. Entrega e integridad

**Único archivo nuevo para versionar:** `docs/rediseno/fase2bis/reaceptacion-codex.md` (este informe).

No se modificaron archivos versionados de producto, pruebas, documentación de Yov o herramientas entregadas. **`pubspec.yaml` y `pubspec.lock`: sin cambios.** Las fuentes y resultados propios están en `build/t114-fase2bis-reaceptacion/`, con inventario exacto y SHA-256 en `inventario-evidencia.json`; la única limpieza fuera de esa carpeta fue la importación sin uso del arnés propio anterior, preservada y documentada arriba. `/build/` está ignorado por `.gitignore`: la evidencia se conserva localmente y no se propone `git add -f`.

Se cierra el bloqueo de la Fase 2 bis. Permanecen como observaciones el trabajo extra del tema de la raíz y la aplicación futura de la regla de contadores; esta aceptación no modifica el alcance de la entrega 2 ni afirma resolver la fragilidad LF/CRLF de la licencia, que no formaba parte de este bloque.

**Tres líneas:**

H1 queda cerrado: salida real a 0/75/150 ms, reducción de movimiento y regreso sin animación comprobados.
La prueba de Timonel falla con la celda vieja y pasa con la actual; suite 1224/1224 y análisis limpio.
ACEPTADA con observaciones: se confirma el AnimatedTheme extra de 200 ms y queda la integración del contador conforme a la regla documental.

**Mensaje para Yov:**

> Yov: Capitán Codex reaceptó solo la corrección de BsCelda en `C:\Proyectos\baystream-qa-r4`, HEAD `8543cd2`, contra `39bfd56`: **ACEPTADA con observaciones; H1 cerrado**. Trayectoria propia en ambos temas y densidades: 0 dp a 0 ms, −21.003 dp a 75 ms y −24 dp a 150 ms; reducción quieta y vuelta inmediata a bajado. La prueba nueva con la celda aislada de `36f5784` da 39 éxitos y el fallo esperado (92 frente a 68 dp); con la actual pasan las 40. Las dos reescritas conservan los contratos. Plano de 960 celdas: cero controladores activos en reposo, uno al salir y los 960 liberados al desmontar. Suite 1224/1224, sin omitidas; analyze final 0. DESIGN 13.6 corregido. El tema extra de raíz queda confirmado: rebuild con igual ColorScheme crea ThemeData desigual y activa AnimatedTheme de 200 ms, sin corregirlo. La regla de «Más» está escrita; el BadgeTheme global todavía es naranja y la integración del contador corresponde al plano. Informe: `docs/rediseno/fase2bis/reaceptacion-codex.md`; evidencia: `build/t114-fase2bis-reaceptacion/`. Sin cambios de producto ni Git de escritura.

**Git para Carlos, desde esta copia:**

```powershell
git add -- docs/rediseno/fase2bis/reaceptacion-codex.md
git commit -m "Sprint 4: reaceptacion de salida de celda, H1 cerrado con observaciones"
git push
```
