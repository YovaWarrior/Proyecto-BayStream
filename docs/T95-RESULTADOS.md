# T-95 · El orden de descarga sugerido, con las sobreestibas por columna y por tapa

**Estado: EN REVISIÓN, lista para la aceptación de Codex.** Servicio, pantalla, pruebas, corpus y los tres clientes, completos y colocados en el árbol. Una sola salvedad: el Honor se probó con la letra a **1.45**, el máximo de su menú de Ajustes, no a 2.0, por decisión de Carlos (sección 7).

## 1. Base y cómo trabajé

- **Base:** `ff14dc0` (decisión 10.63), confirmada por Carlos. Trabajé en una copia de sus 624 archivos versionados en `%TEMP%\baystream-t95-ff14dc0`, sacada con `git ls-files` y `git show`. El árbol no se tocó.
- **Ficha:** la Ola 6 de `SPRINT-3.md`, con las tres definiciones de Carlos (10.59) y el reparto de 10.61.
- **Flutter:** solo con el turno de Carlos.
  - Durante mis comandos estaba abierto un `flutter run -d chrome` de Capitán para T-56 (puerto 8157, en otra carpeta). Lo avisé, y Carlos me dijo que siguiera.
  - Al terminar avisé que Flutter quedaba libre.
- **Git:** solo `log`, `show`, `diff --stat --ignore-cr-at-eol` y `ls-files`.

## 2. Las decisiones

**De Carlos (10.59), aplicadas tal cual:**
1. **Sobre una tapa van los de cubierta de las filas que la tapa declara.** Las filas de afuera no estorban: se cuentan aparte.
2. **Las celdas van de más a menos movimientos por muelle;** con empate, de proa a popa (la bahía menor primero).
3. **Re-estiba a bordo, 1 movimiento; por muelle, 2.** Cada tapa de grúa cuenta 2, y la automática 0, aunque despeja igual su cubierta.

**De Carlos, durante la tarea:** la ficha ponía las tapas de vuelta antes que las re-estibas de vuelta. Pero una re-estiba **de bodega** tiene que volver antes de reponer la tapa. Carlos eligió este orden:

| Paso | Qué |
|---:|---|
| 1 | la cubierta, de arriba abajo |
| 2 | lo que estorba sobre cada tapa, y la tapa |
| 3 | la bodega, de arriba abajo |
| 4 | las re-estibas de bodega vuelven |
| 5 | las tapas se reponen |
| 6 | las re-estibas de cubierta vuelven |

**Por defecto, sin cambiar la ficha:**
- **Una re-estiba que es de columna y de tapa a la vez** se cuenta una vez, como «por columna», porque sale primero, en la cubierta.
- **Un contenedor con posición y sin puerto de descarga** no baja: puede estorbar, y se cuenta aparte.
- **Una tapa copiada a la 01, la 02 y la 03** se une en una sola tapa física si tiene el mismo tipo y las mismas filas. Se muestra en su bahía par, para que declararla solo en la par o copiarla se vea igual.
- **Una fila de bodega que ninguna tapa cubre** da el mismo aviso que una bodega sin tapa declarada.

## 3. El cambio

- **`domain/services/discharge_sequence.dart`, puro, sin Flutter:**
  - `bayFootprint()` y `footprintsTouch()`: la impar es ella misma y la par son sus dos impares, sin fórmulas;
  - la pila es la misma fila, la misma zona y huellas que se tocan;
  - las tapas físicas, con sus copias unidas;
  - las celdas son los componentes de bahías cuyas huellas se tocan (la par con sus impares; en ALFA, 043/044/045 y la 041 sola);
  - los pasos rotulados de cada celda;
  - los dos totales y los avisos.
- **`presentation/pages/discharge_sequence_page.dart`, «Orden de descarga»:**
  - el puerto (la escala, o cualquier otro puerto de descarga del archivo);
  - el resumen, las zonas y los avisos;
  - las celdas en orden, con sus pasos numerados: «Descarga», «Re-estiba: sale», «Tapa T1: quitar», «Tapa T1: reponer», «Re-estiba: vuelve» (la automática dice «abrir» y «cerrar»). Cada paso lleva texto e ícono, nunca solo color; la línea de abajo da la posición, el contenedor y si es «por columna» o «por tapa»;
  - una lista perezosa.
  - **No lee providers:** recibe las tapas como parámetro.
- **`vessel_overview_page.dart`:** la entrada «Orden de descarga», en la fila de acciones del viaje, justo después de «Comparar con otro BAPLIE…» (10.61). Pasa las tapas del perfil vigente, con la misma regla de clave que el plano.
- **No toca** el plano, el lector, el modelo, el perfil y su JSON, el codec, las reglas, `lib/main.dart`, los congelados ni `pubspec.*`. Sin dependencias nuevas.

## 4. Las pruebas (24 nuevas)

**`test/t95_discharge_sequence_test.dart`, 18 casos, todos sintéticos:**
- la huella;
- un 40 que no baja sobre un 20 que baja (02 sobre 01);
- un 20 en la 03 sobre uno en la 01, que no es la misma pila;
- un 20 que no baja sobre un 40 que baja;
- ALFA;
- una re-estiba que estorba dos veces, y de las dos clases, cuenta una;
- la cubierta sobre su tapa, y la fila de afuera, que se reporta;
- la automática; la bodega abierta; la tapa sin declarar; la fila de bodega sin tapa;
- las copias en la 01, la 02 y la 03 unidas, con el mismo resultado que solo en la par;
- la secuencia completa, con sus diez pasos;
- el orden de las celdas, con el empate;
- los dos totales;
- sin posición y sin puerto de descarga;
- los puertos;
- las reservas, que no entran.

**`test/t95_discharge_sequence_page_test.dart`, 6 casos:**
- el resumen, las celdas en orden y los ocho pasos con sus rótulos;
- cambiar de puerto recalcula;
- sin geometría lo dice;
- legible a 360 dp con la escala real del Honor a 2.0, en claro y en oscuro;
- la entrada, junto a «Comparar con otro BAPLIE…», abre la pantalla.

En la prueba de legibilidad, la comprobación «texto entero» mide carácter por carácter y omite los blancos. El espacio donde se parte una línea medía 0.4 px más que el ancho, sin que se cortara ningún glifo.

## 5. El corpus (`tool/t95_corpus_test.dart`, 12 casos)

- **A07 en GTSTC: 114 descargas, 66 en cubierta y 48 en bodega,** como dice la ficha.
  - **Por columna da 0 re-estibas,** y el cotejo independiente sobre el texto crudo (`LOC+147`, `LOC+11` y `EQD+CN` con número, sin el lector ni la geometría) también da **0**.
  - Las descargas quedan en 4 celdas. Sin tapas, las 48 de bodega avisan «sin tapa declarada».
- **Cada fuente y cada puerto de descarga cumplen los invariantes,** y el cotejo crudo coincide en todas las fuentes 2.x:
  - cada contenedor del puerto baja una sola vez;
  - cada re-estiba no baja, y está sobre una descarga de su pila o sobre una tapa que se quita;
  - ninguna descarga queda bajo algo que no baja y no figura como re-estiba;
  - cada re-estiba sale y vuelve una vez;
  - los totales suman y las celdas van en orden.

| Fuente | Puertos · descargas/re-estibas por columna |
|---|---|
| A01 | USHOU 907/0 · USMSY 40/0 · XXVSL 30/66 |
| A02 | JMKIN 477/12 · GTSTC 303/0 · VEPBL 13/9 · VELAG 11/9 · USPEF 2/3 |
| A03 y A03v_VGM | GTPBR 267/0 · USHOU 102/9 |
| A04 | JMKIN 822/21 · USPEF 148/1 · VEPBL 6/4 · VELAG 2/1 · GTSTC 1/0 |
| A05 | COCTG 482/0 · JMKIN 254/6 |
| A06 | sin puertos de descarga (ver abajo) |
| A07 | JMKCT 125/6 · GTSTC 114/0 · PACCT 64/0 · PAMIT 51/0 · COSPC 33/5 · JMKWL 11/0 |
| A08 y A08v_VGM | JMKIN 125/6 · JMKCT 70/0 · PAONX 64/0 · COSPC 55/5 · PAMIT 55/0 · JMKWL 18/0 · PACCT 18/0 |

- **A06 no tiene puertos de descarga para BayStream.** La 1.5 trae el destino en `LOC+12` (717 veces) y ningún `LOC+11`, y se lee con las reglas 2.x (T-103). Sus 717 contenedores quedan «sin puerto de descarga». La prueba lo fija así; no es un defecto de T-95.
- **Las tapas de A07,** con declaraciones PROVISIONALES en las 21 bahías con bodega del caso (A07 ∪ A08, como T-56), con la geometría de los dos planos:
  - tres tapas de grúa por bahía, de babor a estribor, con las filas de bodega 10, 08, 06, 04, 02, 00, 01, 03, 05, 07 y 09;
  - **declaradas solo en las 7 pares o copiadas a las 21 bahías, dan exactamente lo mismo,** paso por paso; 42 declaraciones se unen;
  - **las cifras:** 114 descargas · 13 re-estibas (0 por columna, 13 por tapa) · 4 tapas de grúa · **135 movimientos a bordo, 148 por muelle** · 0 contenedores en filas fuera de las tapas · 0 descargas en bodega sin tapa;
  - **la primera celda sugerida es la 021/022/023,** con 76 movimientos por muelle.
- **No se cumplió ninguna de las tres condiciones para detenerse:**
  - el cotejo crudo coincide;
  - A07 da 114, 66 y 48;
  - unir las copias no cambia nada.

## 6. Validaciones

| Validación | En la copia | En el árbol, después de colocar | Registro en `build/t95/` |
|---|---|---|---|
| Pruebas de T-95 | **24/24** | dentro de la suite | `t95-pruebas.log` |
| Suite completa | **866/866** (piso 842 de `ff14dc0` + 24) | **866/866** | `suite.log`, `suite-repo.log` |
| `flutter analyze` | **0**, también con el banco | **0** | `analyze-banco.log`, `analyze-repo.log` |
| Corpus completo, 35 archivos | **147/147** (135 + 12) | **147/147** | `corpus.log`, `corpus-repo.log`, `t95-corpus.log` |

- **HEAD avanzó a `6d5f3f7` durante la tarea** (aceptaciones de T-56 y T-96). Solo cambió documentos (`git diff --stat --ignore-cr-at-eol ff14dc0 6d5f3f7 -- lib test tool pubspec.* android web`, vacío). La 10.65 recoge el orden de vuelta que decidió Carlos.
- **Los diez SHA de la tabla de T-96 siguen iguales en el árbol:** las reglas, `main.dart`, `pubspec.yaml`, `pubspec.lock`, los dos congelados, el lector, el codec, `container_unit.dart` y `vessel_voyage.dart`.
- **No cambian frente a HEAD:** `firebase.json`, `hatch_covers.dart`, `vessel_profile.dart`, `vessel_geometry.dart`, `movement.dart`, `bay_plan_view.dart`, `android/` ni `web/`.
- **`pubspec.yaml` y `pubspec.lock` no cambian.**

## 7. Los clientes

**El banco, `tool/t95_main.dart`:**
- modo sin cuenta, namespace `t95acc`;
- A07 como recurso solo de la copia de compilación (`t95_inputs/`, con la entrada en el `pubspec.yaml` de la copia), nunca del repo;
- «Declarar tapas PROVISIONALES»: tres tapas de grúa por bahía con bodega de A07, en las pares y en las impares sin par vecina. Son 6 declaraciones, menos que las 21 del caso porque el banco solo usa las bahías con bodega que observa A07;
- «Quitar las tapas»;
- la entrada es la del producto.

**Compilaciones** con `--dart-define-from-file`, sin abrirlo: Windows 120 s, APK 90 s (`applicationId` `.t95` solo en la copia) y Web 60 s.

**Lo comprobado:**

| | Windows (mouse) | Web, navegador integrado | Honor (dedo, 360 dp) |
|---|---|---|---|
| Tema | claro | oscuro | claro y oscuro |
| La entrada, justo después de «Comparar con otro BAPLIE…» | sí | sí | sí, en otra línea de la fila partida |
| A07 en GTSTC sin tapas: «114 descargas · 0 re-estibas · 0 tapas de grúa · 114 a bordo, 114 por muelle», «66 en cubierta · 48 en bodega · 4 celdas», el aviso de las 48 descargas en bodega sin tapa, la primera celda 021/022/023 y sus pasos numerados | sí | sí | sí |
| Cambiar de puerto recalcula | JMKCT: 125 descargas, 6 re-estibas por columna, 131 / 137; se ven «Re-estiba: sale · 018-06-86 · … · por columna» | COSPC: 33, 5 por columna, 38 / 43, con las re-estibas de bodega antes de lo de abajo | JMKWL: 11 descargas, «1 celda» |
| Con las tapas PROVISIONALES: «13 re-estibas (0 por columna, 13 por tapa) · 4 tapas de grúa · 135 a bordo, 148 por muelle», «Tapa T1: quitar · Bahía 022 · filas 04, 06, 08, 10», las re-estibas «por tapa» y «Tapa T2: quitar» | sí | sí | sí |
| Letra grande | — | — | **1.45**, en claro y en oscuro: el resumen, la celda y los pasos «por tapa» se parten sin cortes |

- **La letra del Honor, a 1.45 y no a 2.0.** Carlos puso el máximo de Ajustes, que en este Honor es 1.45. El 2.0 que había esta madrugada venía de ADB, y no cambio ajustes del sistema. Carlos eligió probar a 1.45 y declararlo. **El 2.0 queda cubierto solo por la prueba de widget**, con la escala real del Honor medida en T-104.
- **El Honor:**
  - **lo encontré** a 1.0, 720×1600 a 320 dpi, con la `.t56cx` de Capitán en primer plano (no la cerré);
  - **queda** a 1.0, que volvió a poner Carlos, solo con `.t95` cerrada con `am force-stop` y sin ningún proceso de BayStream;
  - **los volcados** ocultan cuentas y UID y descartan formularios de acceso.
- **Windows:** abierta con `explorer.exe` (PID 13828, padre `explorer.exe`) y cerrada por PID. **El almacén real, fuera del paquete:** 438 → 450 archivos, los 438 previos idénticos, 0 modificados, 0 borrados, 0 inaccesibles; **los 12 agregados son todos `t95acc_*`** (`store-before.json`, `store-after.json`, `store-comparison.json`).
- **La Web,** servida desde mi copia en `localhost:8195` (PID 20388, detenido al final), en el navegador integrado, como en las tareas anteriores. **Chrome queda sin probar.**

## 8. Observaciones

1. **A 360 dp con letra grande, «re-estibas» se parte en el guion** («10 re- / estibas»). Es cosmético. Un guion que no se parte cambiaría los rótulos exactos de la ficha, así que no lo toqué.
2. **A07 en GTSTC no tiene re-estibas por columna.** El servicio y el cotejo crudo dan 0: las 114 descargas no tienen nada que se quede encima en su pila. Las re-estibas por columna aparecen en otros puertos (JMKCT 6, COSPC 5) y en otras fuentes (A01 XXVSL 66, A04 JMKIN 21).
3. **Con las tapas PROVISIONALES, la fila 00 de cubierta queda dentro de una tapa** (T2: 00, 01, 02, 03), así que no hay «filas de afuera» en A07. El caso de las filas de afuera se prueba con datos sintéticos.

## 9. Incidencias declaradas

- **Durante mis comandos de Flutter,** Capitán tenía abierto un `flutter run -d chrome --release` de T-56 (PID 6660, puerto 8157), en otra carpeta. Mi `pub get` y mi `analyze` ya habían corrido cuando lo vi. Lo avisé, y Carlos me dijo que siguiera.
- **Un error mío de la aceptación de T-105, encontrado aquí.**
  - Dos copias de evidencia, `build/t105tm/t105tm_cruzada_test.dart` y `t105tm_request_previo_test.dart`, hacían que `flutter analyze` **en el repo** diera 20 errores, porque importan un fixture con una ruta que desde `build/` no existe.
  - Las renombré a `.dart.txt`: conservan la evidencia y el analizador ya no las recorre.
  - `t105tm_sombra40_test.dart` es autónoma, pasa limpia y la cita el informe de Capitán, así que queda igual.
  - Las validaciones en copias de `%TEMP%` no se vieron afectadas.
- **Mis propias expectativas de prueba, corregidas antes de entregar:**
  - el resumen de la prueba de pantalla (2 re-estibas, no 3);
  - la comparación de listas dentro de un registro;
  - la fuente A06, que no trae puertos de descarga;
  - la comprobación «texto entero», que contaba el espacio donde se parte una línea.

## 10. Horas

- **≈ 2.3 h de pared,** de 11:05 (copia) a 13:22 (cierre), frente a las 7.5 h de la ficha.
- Incluye las esperas del semáforo mientras Capitán tenía los dispositivos.
- No es un cronómetro de trabajo activo.

## 11. Archivos

**Nuevos:**
- `lib/features/vessel/domain/services/discharge_sequence.dart` (`fcffa33a…`)
- `lib/features/vessel/presentation/pages/discharge_sequence_page.dart` (`77a012ac…`)
- `test/t95_discharge_sequence_test.dart` (`f399f064…`)
- `test/t95_discharge_sequence_page_test.dart` (`65137ae4…`)
- `tool/t95_corpus_test.dart` (`558d0b5b…`)
- `tool/t95_main.dart` (`39ba2392…`)
- `docs/T95-RESULTADOS.md`

**Modificado:**
- `lib/features/vessel/presentation/pages/vessel_overview_page.dart` (`303cf65a…`): la entrada, 21 líneas y dos importaciones. Antes de colocar, el archivo del árbol era igual a HEAD (`19673023…`).

**Lo que no se entrega:**
- `t95_inputs/` y su entrada en el `pubspec.yaml` de la copia;
- el `applicationId` `.t95`;
- las evidencias de `build/t95/`;
- el corpus.

Huellas de la entrega: `build/t95/delivery-sha256.txt`.
