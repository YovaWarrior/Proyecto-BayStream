# T-42 · Aceptación del panel de alertas con el criterio redefinido

Timonel · 30-sep-2026 (reloj de la máquina, noche) · Binarios de T-60 sin recompilar.
No se tocó `lib/` ni `test/`. Un script nuevo, `tool/t42_aceptacion.dart`. Evidencia en
`build/t42/` (ignorada por Git).

## Veredicto

| Cliente | Veredicto | Por qué |
|---|---|---|
| **Windows** (release de T-60) | **Acepta** | A01 declarado: 0 / 0 / 6, sin alertas sin explicar. A03 con perfil histórico: 2 / 100 / 151, con los dos pares de Carlos arriba y el plano abriendo en su posición. |
| **Honor X5d** (APK de T-60) | **Acepta** | Los mismos conteos y las mismas navegaciones. Con una condición de procedimiento: ver el hallazgo 1. |
| **Chrome** (Web de T-60) | **Acepta, con un límite** | Los mismos conteos y navegaciones. De los «no evaluados» solo leí la primera tarjeta; la muestra de diez la hice en los otros dos clientes. |

**Criterio (ficha de T-42, §10.24):** sobre `CORPUS_A01`, con fila 00 ausente en cubierta y bodega,
límite «No lo tengo» y tomas propuestas, el panel no muestra ninguna alerta cuyo origen no se pueda
explicar. Las alertas reales se demuestran sobre `CORPUS_A03`. **Se cumple en los tres clientes.**
Es una recomendación mía; la aceptación la decide Carlos.

## 0. Binarios

SHA-256 verificados antes de usarlos, contra `docs/T60-RESULTADOS.md`:

| Archivo | SHA-256 | Coincide |
|---|---|---|
| `build/windows/x64/runner/Release/data/app.so` | `1077E1D4…3C93` | sí |
| `build/web/main.dart.js` | `9BC86E5D…83D8` | sí |
| `build/app/outputs/flutter-apk/app-release.apk` | `B5B0CA50…D30D` | sí |

`adb install -r` en el Honor: `Success`. Bajé el `base.apk` instalado y su hash **coincide** con el
del archivo verificado. La Web se sirvió con `python -m http.server` sobre `build/web` en un puerto
propio (8791), sin recompilar y sin tocar el servidor de Codex en el 8786. Windows: la ventana ya
abierta era el `baystream.exe` release de Codex.

## 1. A01 con lo que el planificador puede declarar

Perfil de BUQUE ALFA en cada cliente: fila 00 «No existe» en cubierta y en bodega, límite «No lo
tengo», tomas «Propuestas del archivo» (50, sin marcar la declaración).

| Cliente | Antes | Después |
|---|---|---|
| Windows | límite **62500.5**, 47 errores de peso (`win-00-estado-previo-47-0-6.png`) | «No lo tengo», perfil guardado (`win-01-perfil-alfa-declarado.png`) |
| Honor | límite **62500.5** también (la ficha solo mencionaba Windows) | «No lo tengo» |
| Chrome | origen nuevo, sin perfil | declarado en la pantalla de confirmación tras cargar el archivo |

Reproducción de la sonda `tool/t42_aceptacion.dart` (los mismos cuatro validadores que el panel):

| Escenario | Panel (error / no evaluado / conforme) | Peso | Tomas | 20 sobre 40 | Segregación |
|---|---|---:|---:|---:|---:|
| A01 declarado | **0 / 0 / 6** | 0 | 0 | 0 | 6 |
| A01 propuesta pura | 0 / 0 / 6 | 0 | 0 | 0 | 6 |

## 2. El panel de A01, resultado por resultado

**Los tres clientes dan 0 / 0 / 6**, con las mismas seis tarjetas (Honor y Windows las recorrí
completas; en Chrome vi las cuatro primeras y la línea de conteo, que dice 0 / 0 / 6).
Los seis son pares entre las cuatro unidades peligrosas de A01:

| # | Estado | Regla | Contenedores | Posiciones | ¿Se explica? |
|---:|---|---|---|---|---|
| 1 | Conforme | Segregación · 49 CFR | TSTU4419842 / DEMU5237232 | 0010382 / 0110282 | UN3077 / UN1993, sin exigencia adicional; cita §172.101, §176.83(b), (a)(6) |
| 2 | Conforme | Segregación · 49 CFR | TSTU4419842 / TSTU7425411 | 0010382 / 0290982 | UN3077 / UN3077, ídem |
| 3 | Conforme | Segregación · 49 CFR | TSTU4419842 / TSTU4133838 | 0010382 / 0310982 | UN3077 / UN3077, ídem |
| 4 | Conforme | Segregación · 49 CFR | DEMU5237232 / TSTU7425411 | 0110282 / 0290982 | UN1993 / UN3077, ídem |
| 5 | Conforme | Segregación · 49 CFR | DEMU5237232 / TSTU4133838 | 0110282 / 0310982 | UN1993 / UN3077, ídem |
| 6 | Conforme | Segregación · 49 CFR | TSTU7425411 / TSTU4133838 | 0290982 / 0310982 | UN3077 / UN3077, ídem |

Cada tarjeta lleva severidad escrita («Información · Conforme en las reglas evaluadas»), regla, par,
descripción y fuente. Ninguna descripción está vacía (`resultadosSinExplicacion: 0` en la sonda).
**No hay una sola alerta de peso, de toma ni de apilamiento**: el panel lo dice en su encabezado
(«Sin límite de peso en el perfil no se emiten alertas de peso. Las tomas propuestas… no prueban
ausencia de enchufe»). Las cuatro posiciones coinciden con el EDI crudo.

Navegación comprobada en Chrome: tocar la tarjeta 1 abre la bahía 01 en cubierta con **0010382**
resaltada (`chrome-03-a01-navegacion-0010382.jpg`).

## 3. A03 · los dos pares de Carlos y la muestra de «no evaluados»

Conteo **2 / 100 / 151 en los tres clientes**:

| Cliente | Perfil de A03 | Panel |
|---|---|---|
| Windows | histórico (fila 00 en `null`) | 2 / 100 / 151 |
| Honor | histórico (fila 00 en `null`) | 2 / 100 / 151 |
| Chrome | **propuesta nueva** (fila 00 «Sí existe» en cubierta, porque el viaje la ocupa) | 2 / 100 / 151 |

La sonda da lo mismo con las dos variantes. Los dos primeros resultados, en los tres clientes:

| # | Contenedores | Regla | Posiciones | Navegación |
|---|---|---|---|---|
| 1 | PLNU9223134 / HXTU0749681 · UN1170 / UN0012 | código 2, §176.83(b), (f) | 0020386 / 0030586 | Windows ✓ · Honor ✓ · Chrome ✓: bahía **02**, cubierta, columna 03, nivel 86 |
| 2 | PRBU3657820 / PLNU7015358 · UN3085 / UN0303 | código 2, (a)(6), (m)(1)-(2) | 0260184 / 0270384 | Windows ✓ · Honor ✓ · Chrome ✓: bahía **26**, cubierta, columna 01, nivel 84 |

Quedan arriba, como pide §10.19, y los «no evaluados» vienen después de los errores.

**Muestra de «no evaluados» (Honor, leída del árbol de controles; Windows coincide, leída de capturas):**

| # | Contenedores | Pares ONU | Motivo escrito |
|---:|---|---|---|
| 1 | PLNU9223134 / DEMU8028719 | UN1170 / UN2735 | grupos de segregación, código 52 |
| 2 | PLNU9223134 / WLDU5993406 | UN1170 / UN1719 | grupos, código 52 |
| 3 | PLNU9223134 / PRBU3657820 | UN1170 / UN3085 | grupos, códigos 56, 58, 138 |
| 4 | PLNU9223134 / WLDU0343265 | UN1170 / UN3265 | grupos, códigos 53, 58 |
| 5 | DEMU8028719 / PLNU7408822 | UN2735 / UN3175 | grupos, código 52 |
| 6 | DEMU8028719 / PLNU6656315 | UN2735 / UN3082 | grupos, código 52 |
| 7 | DEMU8028719 / MSTU8771789 | UN2735 / UN3082 | grupos, código 52 |
| 8 | DEMU8028719 / HXTU0749681 | UN2735 / UN0012 | grupos, código 52 |
| 9 | BYSU9277423 / WLDU5993406 | UN1993 / UN1719 | grupos, código 52 |
| 10 | BYSU9277423 / PRBU3657820 | UN1993 / UN3085 | grupos, códigos 56, 58, 138 |

Las diez dicen por qué: *«Grupos de segregación no evaluados (códigos …): posible incompatibilidad
ácido/álcali u otros grupos; confirmar con el embarcador. §176.83(m) remite al IMDG 3.1.4; no se
infiere pertenencia al grupo»*, con la cita §176.83(m)(1)-(2).

**Los 100 completos, por la sonda:** 99 son por grupos de segregación y 1 por la excepción de
§176.83(a)(8) (misma clase con secundario). **Ninguno** queda sin motivo. La muestra de diez es
representativa, pero está sesgada hacia los primeros del orden, que son los de tres contenedores.

## 4. Las sondas de T-55 tras T-58 y T-60

Miré el **estado del validador**, no `lateralGapCalculado` (que sigue calculándose con
`orderedRows`):

| Caso | Antes (T-55) | Ahora |
|---|---|---|
| Código 2, cubierta 02/01, sin carga en la 00 | **conforme** | posible incumplimiento |
| Código 2, bodega 02/01 | **conforme** | no evaluado |
| Controles 01/03, 02/04, 00/01 | posible incumplimiento | igual |
| UN0012 con etiqueta 3 / UN0303 | **conforme** | posible incumplimiento |
| UN0012 con etiqueta 5.1 / UN0303 | **conforme** | posible incumplimiento |
| UN0012 / UN0303, control sin etiqueta | conforme | conforme |

**Los dos defectos de T-55 están corregidos.** Además: 0 discrepancias en los 28 pares y en las 17
entradas ONU, 0 violaciones en el barrido de 17×17, y los 15 casos sin regla siguen en «no
evaluado». Las tres unidades en tanque (22T1, 22T0 ×2) se siguen tratando como cerradas, ahora con
su fuente según T-58.

## Hallazgos y observaciones

**1. Duda · Editar el perfil desde «Perfiles guardados» no llega a un viaje guardado que no esté
abierto.** Con el perfil de ALFA ya guardado con fila 00 «No existe» y «No lo tengo», abrí A01 desde
Recientes en el Honor y su editor mostraba **fila 00 «No declarada» y el límite 62500.5**
(`honor-12…` y `honor-13…`). El código lo dice a propósito: «La geometría histórica del viaje no se
ensancha ni se reemplaza al abrir» (`vessel_providers.dart:412`). En Windows no pasó porque el viaje
ya estaba abierto y `saveEditedProfile` lo republica. **Efecto práctico:** un planificador que
corrige el perfil y reabre un viaje anterior puede ver alertas de peso con un límite que ya borró.
Esa consecuencia es una inferencia mía, no la medí. Para resolverla hace falta que Carlos decida
si el viaje debe releer el perfil o si basta avisarlo en la interfaz. Para esta aceptación declaré
en el editor del propio viaje, como lo haría el planificador.

**2. Observación · el A03 del Honor no es el mismo archivo.** Muestra 0 kg y «Mensaje: 20916», que
es `CORPUS_A03v_VGM.edi`; Windows y Chrome muestran 7419.5 t, que es `CORPUS_A03.edi`
(`UNH+1349`, 369 `MEA+WT`). Los dos repiten los 23 DGS, así que el panel da lo mismo; se sabía
desde §10.19.

**3. Observación menor · lectura de los «no evaluados».** Varias tarjetas «No evaluado» empiezan con
frases como *«Código 2: separación satisfecha en el modelo de huecos evaluado»* antes de la cláusula
de los grupos. El título y la cláusula las aclaran, pero quien lea solo el cuerpo puede
quedarse con «satisfecha». Es una opinión de redacción, no un defecto.

## Lo que esta aceptación no prueba

- **No es el perfil real de ALFA:** ni el límite ni el inventario de tomas existen (§10.24). La
  regla de peso con límite no se ejerció aquí; la cubrió el bloque 7b (33 y 47 excesos).
- **Chrome:** de los «no evaluados» solo vi una tarjeta. Los scripts de la herramienta de
  navegador dejaron la pestaña con una escala de pantalla distorsionada hasta que la reabrí; es
  del entorno y no del producto.
- **Windows:** el árbol de accesibilidad no se expone en esta máquina, así que leí capturas.
- **A01 y A03 en Chrome salieron de un origen nuevo** (`127.0.0.1:8791`); no reutilicé el
  almacén de Codex en el 8786.
- No ejecuté `flutter test` ni `flutter analyze` del proyecto: la tarea no cambia código. Sobre mi
  script, `dart analyze tool/t42_aceptacion.dart`: sin incidencias.

## Estado en que quedan los dispositivos

- **Honor:** APK de T-60 instalado, perfil de ALFA con fila 00 «No existe» ×2, límite «No lo
  tengo», A01 declarado y A03 abierto.
- **Windows:** el mismo perfil de ALFA; la ventana, maximizada, con A03 abierto.
- **Chrome:** pestaña cerrada y servidor del 8791 detenido. Copias temporales de los EDI borradas.

## Archivos

Nuevos: `tool/t42_aceptacion.dart`, `docs/T42-ACEPTACION-RESULTADOS.md`.
Evidencia sin versionar en `build/t42/`: capturas `honor-*`, `win-*`, `chrome-*`,
`aceptacion.json` y la salida de las sondas de T-55.
