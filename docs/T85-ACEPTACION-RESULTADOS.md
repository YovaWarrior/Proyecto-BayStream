# T-85 · Aceptación cruzada de la segregación con el IMDG 42-24 — resultados (Timonel)

**Dictamen: ACEPTADA, con observaciones.** Pasan todos los criterios de «Terminada cuando» que se pueden revisar sin el Honor, sin ningún defecto en `lib/`. **Queda pendiente el Honor, a 360 dp y letra 2.0,** hasta que Carlos lo permita (10.81). Las observaciones están en la sección 9; ninguna es un defecto de T-85.

## 1. Qué se aceptó y sobre qué base

- **Lo entregado por Codex:** `ac72849`, con 20 archivos (19 de código, pruebas y bancos, más su informe), y la revisión Web en `ab67fcb` (10.70 y 10.71).
- **HEAD al aceptar:** `3d5c83a`. El prompt citaba `b862b15`; el commit siguiente, `3d5c83a`, solo trae documentos (la 10.81 y el tablero).
  - `git diff --stat ac72849 HEAD` sobre los 19 archivos de código, pruebas y bancos no da ninguna diferencia.
  - Tampoco `git diff --stat 93dc695 ac72849` sobre `lib/main.dart`, `pubspec.*`, `firestore.rules`, los dos congelados, `domain/entities/` y `data/`: T-85 no tocó nada protegido.
- **Los SHA del informe de Codex** se tomaron en el árbol, con CRLF. Los blobs de Git están en LF; convertidos a CRLF coinciden: los datos dan `6fc22683…` y el validador `0495b9a9…`.
- **La copia de aceptación:** `%TEMP%\baystream-t85acc-3d5c83a`, con los 486 archivos de `git ls-tree -r HEAD` fuera de `docs/`, sacados con `git show`.
  - **No se validó en el árbol** porque Codex trabaja allí en paralelo en la corrección de T-98 (`test/`, `tool/` y `.gitattributes`).
- **La copia del padre,** `%TEMP%\baystream-t85acc-93dc695` (49 CFR), solo para exportar el corpus «antes».
- **No se tocó `lib/`.** No hubo Firebase ni git de escritura. Nada de `baystream-privado` entró al repo ni a este informe: solo se citan los códigos (1 a 4, X, \*) de cinco celdas, que ya están en el código.

## 2. Los criterios de «Terminada cuando»

| Criterio | Resultado | Evidencia |
|---|---|---|
| **Comprobador privado** 289/289 y 60/60 | **PASA** | Salida 0: «7.2.4 289/289; 7.4.3.2 60/60. COINCIDEN.» Con datos alterados falla (control negativo, 3.2) |
| **Una prueba exige la simetría** | **PASA** | `t85_imdg_test.dart`, «datos completos y simetricos» (líneas 31–42). Mi lectura aparte con Python: 17×17, 0 asimetrías |
| **Los casos sintéticos** de la ficha | **PASA** | Los 9 grupos de la ficha están en `t85_imdg_test.dart` (tabla de 4); 64/64 en las pruebas de T-85 y de segregación |
| **El corpus:** cada cambio frente a 49 CFR, con su razón | **PASA** | Mi cotejo independiente da 640/640 iguales; el anexo de Codex, 650/650 filas verificadas, con 0 sin explicar (sección 5) |
| **Ningún texto del IMDG** en `lib/`, `test/` y `tool/` | **PASA** | Las dos frases de la ficha, y tres variantes, dan 0 en la copia de HEAD y también en el árbol |
| **Los clientes,** con `t85acc` y A03 | **PASA en Windows y en la Web (Chrome). El Honor, PENDIENTE** | Fuente nueva y 4 / 154 / 95 en los dos (sección 7) |
| **Validaciones:** piso + nuevas, `analyze` 0, corpus verde, lo protegido igual | **PASA,** con la salvedad de T-98 | Suite 979/992: los 13 fallos son de la batería de T-98 (10.81). `analyze` 0, corpus 157/157 (sección 8) |

## 3. El comprobador privado

### 3.1 La corrida

- **Desde la copia de HEAD:**

  ```
  dart run tool/t85_tabla_privada.dart C:\Proyectos\baystream-privado\imdg\yov_7-2-4.csv C:\Proyectos\baystream-privado\imdg\yov_7-4-3-2.csv
  ```

- **Salida 0:** «IMDG 42-24: 7.2.4 289/289; 7.4.3.2 60/60. COINCIDEN.»
- El registro va en `%TEMP%\t85acc-evidencia\tabla-privada.log`, y solo trae esa línea.
- **Leí el comprobador:**
  - imprime solo coordenadas y códigos;
  - traduce los textos de 7.4.3.2 con una tabla cerrada de huellas SHA-256, y un texto desconocido falla;
  - exige cabeceras, la forma 17×17, que no haya coordenadas repetidas, y los totales exactos.

### 3.2 El control negativo

Lo hice para comprobar que el comprobador no da verde siempre. Fue solo en mi copia, y el archivo se restauró.

| Alteración | Resultado |
|---|---|
| La celda 1.1/1.2/1.5 contra 2.1, de 4 a 3 | **Falla,** salida 255: «Diferencia 7.2.4 fila 1, columna 4.» |
| La exigencia 4, longitudinal, cerrada/cerrada en cubierta, de `meters24` a `space3` | **Falla,** salida 255: «Diferencia 7.4.3.2 4/h/0/0/0» |
| El archivo restaurado (SHA del blob `a9c25402…`, igual que antes) | Otra vez 289/289 y 60/60 |

## 4. La simetría y los casos sintéticos

**La simetría.**
- La prueba recorre las 289 celdas, exige `matrix[i][j] == matrix[j][i]` y solo los símbolos `1234X*`, y cuenta 12 reglas verticales y 48 horizontales.
- **Mi lectura aparte** del archivo de datos, con Python:
  - 17 clases, 17 filas, 289 celdas y 0 asimetrías;
  - la clase 9 es toda X, en su fila y en su columna;
  - el bloque de la clase 1 contra la clase 1 es todo `*`.

**Los casos sintéticos.** Cada uno, contra su prueba y mi revisión del dato y de la posición:

| Caso de la ficha | Prueba (`t85_imdg_test.dart`) | Revisión |
|---|---|---|
| 3 contra 5.1 (2): pegados en cubierta, no conforme; con un hueco, conforme | líneas 43–48 | 3/5.1 = 2. Bahías 01 y 03: hueco 0. Bahías 01 y 05: hueco 1 |
| 2.1 contra 4.1 (1), cerrados y pegados en cubierta: conforme | 49–52 | 2.1/4.1 = 1. Exigencia 1, cerrada/cerrada, longitudinal: sin restricción |
| Exigencia 1 entre dos abiertas pegadas: falta un espacio | 53–60 | U y P pegadas: no conforme; con un hueco: conforme |
| 1 en vertical, una abierta sobre una cerrada: permitido | 61–68 | Abierta sobre cerrada: conforme. Al revés: no conforme |
| 1.4 contra 6.2 (4): 4 huecos conforme, 3 no, solo transversal no | 69–79 | 1.4/6.2 = 4. Bahías 01–11: 4 huecos. Bahías 01–09: 3. Filas 02 y 11 en la misma bahía: el transversal está prohibido |
| Bajo cubierta, una exigencia de mamparo: no evaluado | 80–85, más 86–92 | 3/6.2 = 3, con mamparo bajo cubierta: no evaluado. «Hueco o mamparo» se cumple con hueco; sin hueco queda no evaluado |
| Una en cubierta y otra en bodega, para 2 y para 3 | 93–106 | 1 y 2 conformes, con el supuesto de la tapa y la cita 7.4.2.2. 3 y 4: no evaluado |
| La clase 9, el asterisco, un secundario y dos secundarios | 114–122, 132–148 | Las 17 combinaciones con la clase 9 dan «consultar la Lista». 1.1D/1.6N remite a 7.2.7.1. El secundario impone la exigencia mayor, y un secundario de clase 1 se toma como 1.3. Con dos: 7.2.3.4 |
| Dos sustancias en un mismo contenedor | 153–162 y 200–207 | No conforme, con la cita 7.2.3.2 |

**Además leí el validador completo** (`dangerous_goods_validator.dart`, 356 líneas) y las reglas, y no encontré defectos:
- **«Misma vertical»** exige que las huellas se solapen (`footprintsTouch`, de T-95), no que sean contiguas: dos 20 en 01 y 03 no son una pila.
- **Una X junto a un número:** se evalúa el número y se conserva el aviso de la Lista.
- **Los mamparos** que no se conocen dan «no evaluado». Si un sentido es «no conforme» y el otro «no evaluado», queda «no evaluado». Nunca da «conforme» por un supuesto (10.67).
- **En la exigencia 4** el transversal es `forbidden`, así que no la resuelve.
- **La bodega abierta** (T-83) da «no evaluado» entre zonas.
- **El tipo de unidad** sale del tercer carácter ISO (G R T B V H cerradas, U P abiertas, lo demás «no evaluado»), sin tocar `ContainerUnit`.

## 5. El corpus, cambio por cambio

**Las exportaciones,** con el mismo `tool/t85_corpus_diff.dart` en las dos copias:
- **antes,** en `93dc695` (49 CFR): 650 resultados;
- **después,** en HEAD: 640.
- Están en `%TEMP%\t85acc-evidencia\before.json` y `after.json`.

**Mi cotejo independiente** (`t85_cotejo.py`, en el scratchpad de la sesión, fuera del repo):
- **Cómo trabaja:** lee los códigos de `imdg_42_24_data.dart` y las posiciones de cada EDI, para la geometría propuesta y la fila 00 por zona. Aplica las reglas de la ficha y de la 10.67 por su cuenta y reevalúa cada resultado: los diagnósticos individuales y todos los pares.
- **Resultado: 640 de 640 iguales, 0 diferencias.** Reproduce las ternas (no conformes, no evaluados, conformes) de las 10 fuentes:

| Fuente | 49 CFR (`93dc695`) | IMDG 42-24 (HEAD) | Codex | Mi cotejo |
|---|---|---|---|---|
| A01 | (0, 0, 6) | (0, 6, 0) | igual | igual |
| A02 | (0, 0, 3) | (0, 1, 2) | igual | igual |
| A03 | (2, 100, 151) | (4, 154, 95) | igual | igual |
| A03v_VGM | (2, 100, 151) | (4, 154, 95) | igual | igual |
| A04 | (0, 0, 1) | (0, 1, 0) | igual | igual |
| A05 | (0, 1, 0) | (0, 1, 0) | igual | igual |
| A06 | (0, 1, 0) | (0, 1, 0) | igual | igual |
| A07 | (0, 115, 15) | (0, 120, 0) | igual | igual |
| A08 | (0, 0, 1) | (0, 1, 0) | igual | igual |
| A08v_VGM | (0, 0, 1) | (0, 1, 0) | igual | igual |

**El anexo de Codex (sección 9 de `T85-RESULTADOS.md`), fila por fila:**
- **650 filas.** En cada una coinciden con mis exportaciones el estado anterior, el nuevo y las posiciones.
- **La razón que da Codex** concuerda con lo que calculó mi cotejo para ese resultado. Por ejemplo, H2L es exigencia 2 cumplida por el sentido longitudinal, y V2 es exigencia 2 en la misma pila.
- **0 filas con problema.**
- **313 cambian de estado o se retiran, y 337 lo conservan,** como dice el informe.
- **Los conteos por razón** coinciden: X 426, H2L 134, H1L 28, H2T 28, A 12, D 10, F2 6, C2 2, V2 2 y U 2.
- **Las 10 retiradas (D)** son todas de A07 y todas diagnósticos individuales: «número ONU fuera del subconjunto» de 49 CFR. Las posiciones de cada una siguen en 15 o 28 pares del resultado nuevo, así que no se pierde ninguna peligrosa.

## 6. Cinco resultados revisados a mano

**Cómo los elegí.** Combiné cinco tipos de resultado distintos, incluido uno «no evaluado» por X y uno con asterisco. Revisé la celda de 7.2.4 **directamente en la transcripción privada** (solo su código) y la posición a mano.

| # | Resultado de la app | Par | Revisión a mano | ¿Coincide? |
|---|---|---|---|---|
| 1 | **A03 #14 · no evaluado** | 0140284 (clase 3, 45G1) / 0030186 (clase 9, 22G1) | En la transcripción, 3/9 = **X** (simétrica). Sin exigencia numérica: «consultar la Lista», citando 7.2.4 y 7.2.3.1 | Sí |
| 2 | **A03 #240 · no evaluado, con asterisco** | 0030586 (1.4) / 0270384 (1.4) | En la transcripción, 1.4/1.4 = **\***. Remite a 7.2.7.1 y no se resuelve | Sí |
| 3 | **A03 #177 · no conforme** | 0260184 (5.1, 45G1, fila 01, nivel 84) / 0260186 (2.1, 45G1, fila 01, nivel 86) | 2.1/5.1 = **2**. Misma bahía, misma fila y niveles seguidos en cubierta: es la misma pila. Para la exigencia 2, cerrada/cerrada, la vertical pide una cubierta entre ellas, y las dos van en cubierta. Antes, 49 CFR daba conforme por la excepción ONU de UN1950; ahora se usa la clase 2.1 declarada | Sí |
| 4 | **A03 #150 · conforme** | 0260286 (8, fila 02, nivel 86) / 0260184 (5.1, fila 01, nivel 84) | 8/5.1 = **2**. No es la misma pila: las filas son distintas. Longitudinal: misma bahía, hueco −2. Transversal: entre la 02 y la 01 está la 00, que A03 trae ocupada en cubierta, así que el hueco es 1. Basta un espacio transversal: conforme | Sí |
| 5 | **A02 #2 · conforme** | 0020684 (3, cubierta) / 0030512 (2.1, bodega) | 3/2.1 = **2**. Una en cubierta y otra en bodega: para 1 y 2 basta la tapa, con el supuesto 2 de la 10.67 y la cita 7.4.2.2 | Sí |

Las cinco celdas de la transcripción son simétricas (X, \*, 2, 2 y 2) y coinciden con la matriz del código y con lo que muestra la app.

## 7. Los clientes, con el namespace `t85acc`

**El banco:** `tool/t85_main.dart`, compilado en `%TEMP%\baystream-t85acc-build`.
- `CORPUS_A03.edi` y su línea de recurso en `pubspec.yaml` están **solo en esa copia**; el cambio de `pubspec` está en `build/t85acc/variante-compilacion.diff`.
- `--dart-define-from-file`, sin abrirlo.
- **Windows release:** `data/app.so` `903e49c3…`.
- **Web release:** `main.dart.js` `d2562678…`, **el mismo SHA que dio Codex el 16-oct.**
  - El banco solo importa las pantallas de segregación y de alertas, y dart2js es determinista.
  - Lo que cambió en `lib/` después (T-106 y T-107) no entra a esa compilación; `bay-plan-actions` no aparece en el `.js`.
  - Es una reproducción independiente de la compilación de Codex.

**Windows (oficina, sin cuenta):**
- **Abierta con `explorer.exe`** como `baystream_t85acc.exe` (PID 8512), a 1280 × 900 dp medidos (1920 × 1350 px a 144 ppp), y después a 800 dp.
- **Cerrada por PID.** No había otra BayStream abierta; no se tocaron las apps de `demo17` ni «PRUEBA T-105».
- **A03 abre con 369 contenedores.**
- **La pantalla de segregación** muestra la fuente «Código IMDG, Enmienda 42-24 (7.2.4 y 7.4.3.2). Apoyo a la decisión, no verificación de cumplimiento…», el resumen **4 posibles incumplimientos · 154 no evaluados · 95 conformes en las reglas evaluadas**, la leyenda y la matriz de 17 clases.
- **«Alertas de estiba»** muestra la misma fuente, 4 / 154 / 95, y los incumplimientos primero, con sus apartados.
- **El almacén real, fuera del paquete** (`.bat` con `explorer.exe`, padre `cmd.exe`): **544 archivos antes y 544 después**.
  - Ninguno agregado ni borrado, y ninguno inaccesible.
  - **Cambiaron 2,** `vessel_store\t85acc_voyages.hive` y `t85acc_operations.hive`.
  - Los 12 `t85acc_*` ya existían, de la entrega de Codex.

**La Web, en Chrome** (Claude in Chrome, la pestaña propia de la extensión):
- La compilación se sirvió en `http://127.0.0.1:8285/`, con Python limitado a loopback.
- **El primer intento no conectó;** funcionó cuando Carlos abrió Chrome.
- **A03 abre con 369 contenedores.**
- **La segregación** muestra la misma fuente y **4 / 154 / 95**.
- **La matriz completa** entra en el ancho de la ventana, con la columna 9 toda en X.
- **Pestaña cerrada y servidor detenido;** el puerto 8285 quedó sin escucha.

**Capturas** (recortadas a la app), en `%TEMP%\t85acc-evidencia\`:
- `windows-segregacion-fuente-4-154-95.jpg`
- `windows-matriz-800dp-desplazada.jpg`
- `windows-alertas.jpg`
- `chrome-segregacion-fuente-4-154-95.jpg`
- `chrome-matriz-17-clases.jpg`

### 7.1 Los rastros de glifos en Windows (10.70)

**No se reproducen.**
- **Con eventos de rueda horizontal** sobre la matriz, en la app de Windows en release, a 1280 dp y a 800 dp:
  - 15 desplazamientos de ida y vuelta en 4 tandas, de 1 a 6 pasos, con y sin espera;
  - 12 ampliaciones revisadas.
  - En todas, cada celda visible coincide con la matriz. Por ejemplo, en la fila 1.1/1.2/1.5, de la columna 3 a la 9: 4 4 4 4 4 4 2 4 2 4 X.
  - No quedó ningún glifo duplicado ni fantasma, ni antes ni después de un desplazamiento vertical.
- **Una apariencia que no es un rastro:** al desplazar, el borde izquierdo de una columna sale de la vista. El rótulo largo de su cabecera deja ver el final («1/1.2/1.5»), y el glifo de un carácter de cada celda, alineado a la izquierda, se recorta. Es el recorte normal.
- **Lo que hay en el código:** la matriz usa solo widgets estándar, `ListView.builder` › `ExpansionTile` › `SingleChildScrollView` horizontal › `RepaintBoundary` › `DataTable` (`segregation_page.dart`, líneas 45–52), sin pintado propio.
- **Mi conclusión:**
  - con mi método y en esta máquina, el defecto no existe;
  - **no viene de T-85,** porque no hay lógica de dibujo propia que pueda dejarlo;
  - si aparece de nuevo, sería del motor de dibujo de Flutter o del método de captura de la automatización de Codex.
  - No lo puedo afirmar con certeza, porque no vi el rastro.

## 8. Validaciones (en la copia de HEAD)

| Validación | Resultado |
|---|---|
| Comprobador privado | **289/289 y 60/60,** salida 0, con el control negativo |
| Pruebas de T-85 y de segregación (5 archivos) | **64/64** |
| Suite completa | **979/992:** fallan 13, todos en `t98_estandares_test.dart` |
| `flutter analyze` | **0,** sin `// ignore` en `lib/` |
| Corpus completo (`tool/`, la carpeta por `--dart-define`, salidas en `%TEMP%`) | **157/157,** con las 10 ternas de T-85 |
| `t85_corpus_diff.dart`, antes y después | 650 → 640 |
| Las búsquedas de texto del IMDG | **0** en la copia de HEAD y en el árbol |
| Lo protegido | `ac72849` no tocó `lib/main.dart`, `pubspec.*`, `firestore.rules`, los congelados, `domain/entities/` ni `data/` |

**La suite en rojo no es de T-85:**
- Los 13 son la batería de conformidad de T-98 (BBBRRTT, ISO 6346, pesos en LBR y TNE, segmentos obligatorios). La 10.81 la manda a `tool/`, y Codex la está corrigiendo.
- **Las cuentas:** 922 + 30 (T-107 B) + 40 de los `t98_*` = 992.
- **La prueba de T-92** pasa en mi copia, porque `git show` da los `.js` en LF; su fallo en la 10.81 venía del CRLF.
- Ningún otro caso falla.

## 9. Observaciones (ninguna es un defecto de T-85)

1. **El Honor, pendiente.** La ficha pide 360 dp y letra **2.0**; la revisión de Codex en el Honor fue a **1.45** (sección 6 de su informe). Queda abierto hasta que Carlos lo permita.
2. **Mayús + rueda desplaza la página, no la matriz,** en Windows.
   - Un mouse sin rueda inclinable no mueve la matriz de lado con la rueda (`segregation_page.dart`, líneas 48–50).
   - No comprobé si aparece una barra de desplazamiento al pasar el mouse.
   - A 1280 dp la tabla casi cabe entera. Es una mejora de uso para el rediseño posterior al cierre (10.80), no un criterio de la ficha.
3. **Dos de los cuatro incumplimientos de A03 son pares de UN1950** (2.1, aerosoles) que 49 CFR aprobaba por excepción ONU.
   - Con la clase declarada y sin inferir nada del número ONU, la exigencia 2 en la misma pila es «no conforme».
   - Es lo que pide la ficha. La Lista (columna 16b) queda fuera de alcance y lo dice la fuente en pantalla.
   - Conviene que el planner lo sepa al ver la pantalla.
4. **El informe de Codex se quedó atrás en dos cosas:**
   - su estado dice que Gru debe revisar antes, y la 10.81 lo dejó como opcional;
   - sus SHA son del árbol en CRLF (sección 1).
   - No cambia nada del código.

## 10. Pendiente

- **El Honor (criterio de la ficha):** la pantalla de segregación de A03 con `t85acc`, a 360 dp y letra 2.0, con la fuente nueva y 4 / 154 / 95.
- **Si Gru logra importar el repo,** su tercera lectura suma (10.81). No es requisito.

## 11. Incidencias declaradas

- **Mi primera sustitución de rutas** para los `.bat` del almacén (con `sed`) no cambió las rutas. Los rehíce con PowerShell antes de usarlos; ningún `.bat` mal formado llegó a ejecutarse.
- **Claude in Chrome no estaba conectado** en el primer intento. No cambié de navegador sin preguntar, y la Web se revisó en Chrome cuando Carlos lo abrió.
- **El aviso «exit 127» del servidor Web** es su cierre por `Stop-Process`, no un fallo.

## 12. Horas

- **Los comandos de Flutter y dart,** de 13:41 a 13:53. **Los clientes,** hasta las 14:04.
- La lectura de la ficha, del informe y del código fue antes de pedir la luz verde.
- No es un cronómetro de trabajo activo.

## 13. Archivos

**Nuevo:**
- `docs/T85-ACEPTACION-RESULTADOS.md` (este informe)

**No se modificó ningún archivo de `lib/`, `test/`, `tool/` ni `pubspec.*`.** Las evidencias quedan en `%TEMP%`, fuera del repo:
- `t85acc-evidencia\`
- `baystream-t85acc-3d5c83a\`
- `baystream-t85acc-93dc695\`
- `baystream-t85acc-build\`
