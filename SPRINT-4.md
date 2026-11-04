# BayStream · Sprint 4 — instrucciones de implementación

**Abierto:** 21-oct-2026 · rama **`sprint-4`**, en su propia carpeta (`C:\Proyectos\baystream-rediseno`, un worktree de `master` en `063d2ae`: el código de `v3.0` más los documentos del cierre).
**Alcance hoy:** el rediseño visual (T-114). El resto del sprint (la tabla de pendientes de 10.91 de `SPRINT-3.md`, los «no cumple» de los RNF, T-87, el pentest de `docs/PENTEST-PLAN.md` y las observaciones de T-98, T-99 y T-111) se planifica después de la entrega del 24-oct y del piloto.

Este archivo es la fuente de verdad del Sprint 4. `SPRINT-3.md` queda como bitácora cerrada (decisiones 10.1 … 10.113) y se conserva. Los acuerdos permanentes están en `AGENTS.md`.

---

## 2. Restricciones duras

**Siguen vigentes las de la sección 2 de `SPRINT-3.md`** (archivos congelados, Firebase, datos reales, pruebas, arquitectura, dependencias, convenciones, Git y consolas, un carril de `lib/` a la vez), con estos cambios:

- **Dos carpetas, dos ramas.** El Sprint 4 trabaja en `C:\Proyectos\baystream-rediseno`, rama `sprint-4`. La carpeta de siempre, `C:\Proyectos\proyecto-baystream`, se queda en `sprint-3` con `v3.0`, para el piloto y para cualquier arreglo urgente. Ningún agente del rediseño trabaja en ella, y ningún otro agente trabaja en la del rediseño.
- **Pruebas:** el piso es **1063** y solo sube; `analyze` en cero, sin `// ignore:`.
- **Commits:** empiezan con «Sprint 4:».
- **Clientes del rediseño:** compilaciones aparte con el namespace `r4`. No se tocan las apps instaladas (el MSIX 3.0.0.0 y la de Play en el Honor), «PRUEBA T-105» ni `C:\Proyectos\baystream-demo17\`.
- **Fuente empaquetada:** se autoriza como asset (no es una dependencia), con su licencia y su procedencia, como `web/fonts/`. Carlos aprueba la familia al elegir la dirección de la Fase 1 (10.2).
- **Dependencias nuevas:** ninguna sin la autorización de Carlos. `shadcn_flutter` y `go_router` no se adoptan por defecto (10.1).

---

## 5. Las tareas

### T-114 · Rediseño visual completo

**Lo hace** Timonel (Claude Code, Fable 5.1) en un chat propio, en la carpeta del rediseño. **Lo acepta** Codex, por fase y por pantalla. **Carlos** elige la dirección; **Yov** revisa cada fase.

**El objetivo.** Que la interfaz sea intuitiva y de impacto (el tutor la vio pobre el 17-oct, 10.80 de `SPRINT-3.md`), sin tocar la lógica, y que en el camino se muevan los RNF que no cumplen por la interfaz:
- RNF-002: la primera visualización, de 6 pasos a 3 (10.2);
- RNF-003: ningún texto cortado ni tapado a 360 y 600 dp con letra 1.0, 1.45 y 2.0;
- RNF-001 y RNF-007, en lo que es de la interfaz: la Lista y la rejilla con construcción perezosa, medidas antes y después con los instrumentos de T-99;
- los pendientes de interfaz de 10.91 y de T-111;
- sin retroceder en T-112: idioma 100 %, Material 3 sin excepciones y 218/218 mensajes con causa y acción.

**El alcance.** La capa de presentación (`lib/features/vessel/presentation/**`), el tema en `lib/core/app.dart` y lo nuevo en `lib/core/design/`. `domain/` y `data/` no se tocan: un cambio de comportamiento se propone y espera decisión. Material 3 se queda como base.

**Las fases.**
0. **Inventario**, sin código. Entregada (10.2).
1. **Dirección**, sin tocar `lib/`: `DESIGN.md` con dos direcciones (paleta, tipografía, tokens, movimiento, reglas de texto), wireframes en ASCII de las cinco pantallas clave a 360 dp y a 1920 px, y cómo resuelve cada una los objetivos. Termina en «ALTO: Carlos elige».
2. **Fundación:** tokens, tema claro y oscuro, `ThemeExtension` semántica y biblioteca de componentes, cada uno con vista previa, documentación y prueba (incluidas las de accesibilidad con `meetsGuideline`). Ninguna pantalla cambia. La acepta Codex.
3. **Pantallas, una por entrega:** inicio, plano por bahía (con los modos de carga y descarga), avance en la oficina y estadísticas; después, las demás. Cada una con capturas del antes y del después en los tres clientes, las pruebas, `analyze`, la auditoría de `flutter-ui` y los censos de T-112. La acepta Codex antes de la siguiente.

**Terminada cuando** las cinco pantallas clave y las demás pasaron la Fase 3, la auditoría de `flutter-ui` queda en cero críticos y cero avisos en `presentation/` y `core/`, el piso sube, y RNF-002 y RNF-003 se vuelven a medir.

**El informe:** `docs/REDISENO-RESULTADOS.md`, una sección por fase; las capturas sintéticas en `docs/rediseno/`.

---

## 10. Decisiones tomadas durante el sprint

### 10.1 · Apertura del Sprint 4 con el rediseño visual (21-oct)

**Carlos abre el rediseño la noche del 21-oct,** con el Sprint 3 cerrado y desplegado (10.113 de `SPRINT-3.md`).
- La carpeta y la rama: `C:\Proyectos\baystream-rediseno`, `sprint-4`, desde `origin/master` (`063d2ae`), ya en GitHub.
- **El encargo:** a Timonel en un chat de Fable 5.1, con el prompt que redactaron Carlos y Yov (en el proyecto de Claude, `claude/BayStream_Rediseno_Prompt_Fable.md`). Esfuerzo Max en las Fases 0 y 1, y Ultracode desde la Fase 2.
- **Las skills:** el catálogo global de Carlos. `shadcn-flutter` queda solo como referencia estética, porque es una dependencia nueva y saca la app de Material 3, que RNF-002 mide. GoRouter tampoco va por defecto. Las de React y Vercel no aplican.
- **Los MCP** `flutter-mcp` y `maestro` cuentan en el semáforo como cualquier comando de Flutter. `maestro` trabaja en el emulador; en el Honor, solo con el permiso de Carlos.

### 10.2 · La Fase 0 del rediseño, revisada · Las decisiones para la Fase 1 (21-oct)

**La Fase 0** (Timonel, ≈ 0.4 h, sin tocar `lib/`) está en `docs/REDISENO-RESULTADOS.md`:
- el mapa de 19 pantallas y 9 recorridos, con las 103 capturas del manual;
- los problemas por pantalla, con archivo y línea;
- el inventario de lo escrito a mano: 28 colores, 46 tamaños de letra, 84 estilos, diez radios, y tres letras distintas según el cliente (Segoe UI, Roboto y Roboto con Noto);
- la auditoría de `flutter-ui` como línea base: 18 críticos, 74 avisos y 19 informativos, con cuatro falsos positivos identificados;
- seis causas de raíz, todas en la capa de presentación.

**Yov la revisó** y comprobó tres afirmaciones en el código: el límite obligatorio (`_limitResolved`, `vessel_geometry_page.dart:213`), el `shrinkWrap` de la Lista y de Estadísticas, y el `animateTo(1)` que ya existe en `vessel_overview_page.dart`. Coinciden. **La Fase 0 se acepta.**

**Carlos decide (21-oct, 22:35):**
1. **La primera visualización: ver primero, confirmar después.**
   - El plano abre de una vez con el perfil que propone el archivo: abrir la app, «Seleccionar archivo» y elegirlo son los 3 pasos.
   - Para **operar** (descargar, cargar, publicar) primero se confirman la escala y el límite de apilamiento. Mientras no se confirmen, hay un aviso visible, con la escala propuesta a la vista, y el peso por pila sale «sin evaluar».
   - «No lo tengo» no se marca por omisión: el planificador tiene que ver que el límite no se declaró.
   - El hallazgo 5 del manual (la llegada propone el puerto de salida como escala) hace que la confirmación de la escala importe: el aviso la muestra antes de operar.
   - **El límite de la tarea:** en la Fase 1, Timonel diseña el flujo y anota qué capas toca. Si cabe en la presentación (páginas, widgets y providers), entra en la pantalla de inicio de la Fase 3. Si exige tocar `domain/` o `data/`, se detiene, y Yov escribe una tarea aparte (T-115) para un programador, que acepta Codex.
2. **El color del plano: por destino o por tipo de vacío, con selector.** Como en el plano impreso, que a veces se colorea por el puerto de destino de la carga y a veces por el tipo de vacío (aclaración de Carlos, 22:37). Un control «Colorear por» ofrece:
   - el puerto de destino (descarga);
   - el tipo de vacío (el tamaño y tipo ISO, como los grupos de vacíos del caso MAGELLAN STAR);
   - el estado de la operación (pendiente, hecho, cancelado).
   Cada vista lleva su leyenda. El mismo puerto o tipo tiene el mismo color en la oficina y en el muelle, y en todos los viajes. El color nunca es la única señal: la celda lleva también el código. La Fase 1 propone la paleta categórica (con contraste AA en claro y en oscuro) y qué vista abre por omisión en cada modo.

**Yov decide el resto de 0.9:**
- **(a) Al confirmar, se abre la pestaña «Plano».** El botón dice «Confirmar y ver el plano», así que lo que hoy hace es un defecto (hallazgo 1 del manual). Con el punto 1, queda dentro del flujo nuevo.
- **(c) Los viajes recientes, en el inicio.** Solo presentación. Con perfil, la primera visualización queda en dos toques.
- **(e) La entrada a la matriz de segregación, desde «Alertas de estiba».** Solo navegación (10.89 de `SPRINT-3.md`).
- **(f) La fuente empaquetada:** autorizada como asset (sección 2). La Fase 1 propone la familia, con licencia OFL o equivalente, cifras tabulares y cobertura de `· ‑ … × •`. Las flechas y los triángulos (`▲ ▼ → ↔`) pasan a iconos.
- **(g) Una sola hoja de detalle del contenedor y una sola unidad de peso.** En pantalla, toneladas con un decimal y un espacio («28.7 t»). La hoja de detalle muestra además los kilos exactos del VGM.
- **El conductor de T-99** (`tool/t99_conductor.dart`) y los instrumentos de T-98 se actualizan antes de volver a medir, y el cambio se declara.
- **Los MCP que no conectan** no bloquean: las Fases 2 y 3 van por la CLI con el semáforo de Carlos. Carlos los revisa cuando pueda.
- **Los tres archivos de `windows/flutter/`** con cambios de fin de línea no son del rediseño y no se versionan.

**Siguiente:** Timonel hace la Fase 1 y se detiene en «ALTO: Carlos elige». Yov revisa `DESIGN.md` antes de que Carlos elija.

La siguiente decisión es la **10.3**.

### 10.3 · Los MCP de Flutter y de Maestro, conectados (21-oct, 22:53)

Carlos los dejó funcionando en su configuración de usuario de Claude Code (`claude mcp list`: los dos «Connected»):
- **flutter-mcp:** `cmd /c dart mcp-server`, el servidor que trae el propio Dart 3.10.8. Fallaba porque en Windows `dart` es un `.bat` y Claude Code no lo arranca directamente.
- **maestro:** Maestro 2.11.0 en `C:\maestro`, con Java 21 (Temurin). Se registra con la ruta completa, su propio `JAVA_HOME` y las variables que apagan las estadísticas y el aviso de «Analyze with AI», para que no ensucien el canal del MCP. El `JAVA_HOME` del sistema no se tocó, así que Flutter sigue compilando Android con su Java de siempre.
- **Una trampa de PowerShell:** se come el `--` de `claude mcp add`. Las variables van antes del nombre, como `"--env=CLAVE=valor"`, y sin `--`.
- **Las reglas de 10.1 siguen:** cada compilación o arranque de la app desde estos MCP cuenta en el semáforo, y Maestro instala su controlador en el dispositivo la primera vez, así que trabaja en el emulador; en el Honor, solo con el permiso de Carlos.
- Una sesión de Claude Code abierta antes de esto los toma con `/mcp` y «reconectar».

La siguiente decisión es la **10.4**.

### 10.4 · La Fase 1 del rediseño, revisada · Carlos elige la dirección A con la barra de operación de B (21-oct, 23:20)

**La Fase 1** (Timonel, commit `8c999ec`): `DESIGN.md` con dos direcciones completas, A «Plano de a bordo» y B «Consola de muelle»; lo que comparten (los roles semánticos, la paleta categórica y «Colorear por»); el flujo «ver primero, confirmar después» con la tabla de capas; la navegación adaptable, y 20 wireframes. El contraste se verificó con `tool/rediseno_contraste.py` (`docs/rediseno/fase1/contraste.md`, 0 pares bajos).

**Yov la revisó:**
- **El flujo cabe en la presentación.** Comprobado en el código: `_publish` (`vessel_providers.dart:312`) es la única escritura; los validadores de peso por pila y de tomas no evalúan sin `publishedProfile`, y `activeOperationProvider` (`sync_providers.dart:41`) devuelve nulo sin escala. **No hace falta T-115.**
- **El contraste cuadra:** Yov recalculó once pares a mano y coinciden con el informe.
- **Cinco correcciones, que entran en la Fase 2:**
  1. La celda del muelle de A medía 56×44, por debajo del mínimo de 48 dp que el mismo documento fija para tocar. Pasa a 56×48 como mínimo.
  2. **«Sin evaluar» se dice, no se deja en blanco.** Sin perfil confirmado, los validadores devuelven una lista vacía. Ninguna pantalla puede mostrar eso como «sin alertas»: el peso por pila y las tomas dicen «sin evaluar hasta confirmar el perfil», con su icono.
  3. **En el plano sin confirmar no se exporta** (PDF, CSV ni JSON), para que no circule un documento con una escala y un límite sin confirmar. Exportar cuenta como operar.
  4. Los wireframes usaban el nombre real del buque del caso de campo. Pasan a nombres sintéticos (2.4 de `SPRINT-3.md`).
  5. **La asignación del color por cálculo choca mucho:** con 12 tonos y 6 puertos en un viaje, dos coinciden el 78 % de las veces; con 24, el 49 %. Se cambia por una tabla fija (abajo).
- **Una regla que falta escribir:** cuándo un viaje con perfil guardado abre publicado sin pasar por el previo. Tiene que ser estricto, por el hallazgo 5 del manual: el perfil cubre la carga **y** la escala propuesta coincide con la última confirmada para ese buque. Si no, abre en previo.

**Carlos decide (23:15 a 23:20):**
1. **La dirección A, «Plano de a bordo», con la barra de operación de B en el muelle.** Carlos preguntó cuál tiene más impacto. Yov respondió que la B a primera vista, y la A en lo que dura: es inconfundible (la silueta del buque como selector y la rejilla como la hoja impresa) y es lo que pidió el tutor, que la app sea más intuitiva.
2. **La letra:** IBM Plex Sans y Plex Mono, más **Plex Sans Condensed** para el código de la celda.
3. **El código del puerto en la celda, con sus 5 letras** (USHOU, GTSTC), como en el plano impreso. Por eso la celda usa la condensada.
4. **La paleta: una tabla fija y 24 tonos** (los 12 de la Fase 1 en dos luminosidades). Timonel propone la tabla con los puertos de destino y los tipos ISO de vacío que salen en el corpus: **solo los códigos**, sin cuentas ni viajes. Carlos la confirma o le agrega puertos antes de que entre al código. Lo que no esté en la tabla usa el cálculo, y si choca dentro del viaje, la leyenda y el código escrito lo separan.
5. **La barra inferior del teléfono:** Plano, Lista, Avance, Estadísticas y Más, como la propuso Timonel. Alertas va en «Más», y el botón «Más» lleva un contador cuando hay alertas, para que nunca queden escondidas.

**Yov decide:**
- **La descarga sigue con un solo toque y «Deshacer»,** como hoy (T-75). Se repite cien veces por turno y ya se probó en campo.
- **La vista por omisión de «Colorear por»,** la que propuso Timonel: el destino al mirar el plano; el tipo de vacío en número de orden y en carga; el estado en la descarga.
- **La cobertura de glifos** se comprueba con los TTF al empaquetar. Lo que falte (quizá el U+2011 de «re‑estiba») sale de Roboto, que ya está empaquetada, con `fontFamilyFallback` en el tema.

**Siguiente:** Timonel reduce `DESIGN.md` a la dirección elegida, con estas decisiones y correcciones, y hace la Fase 2 (fundación) con el esfuerzo en Ultracode. Codex la acepta.

La siguiente decisión es la **10.5**.

### 10.5 · La Fase 2 del rediseño, entregada: la fundación · Las tablas de color, para Carlos (22-oct)

**Timonel entregó la Fase 2** (≈ 0.8 h, la noche del 21-oct). Ninguna pantalla cambia:
- **`DESIGN.md`** queda solo con la dirección A y todo lo de 10.4: la celda del muelle de 56×48, «sin evaluar hasta confirmar el perfil», sin exportar en el previo, buques sintéticos y la regla estricta de publicación directa (7.2).
- **`lib/core/design/`** (18 archivos nuevos): la paleta, la tipografía, las medidas, trece roles semánticos, las 24 ranuras categóricas con FNV-1a, los formatos, el movimiento, el tema claro y oscuro con densidad de oficina o de muelle, y ocho componentes, cada uno con su vista previa, su documentación y su prueba.
- **Las fuentes:** siete TTF de IBM Plex (Sans, Sans Condensed y Mono) en `assets/fonts/plex/`, 1.26 MB, con su licencia OFL 1.1 y un `provenance.json` con la URL, el commit de IBM y el SHA-256 de cada una. fontTools comprobó la cobertura: traen `· ‑ … × •` y el español completo; faltan `▲ ▼`, que pasan a iconos. Roboto queda de respaldo.
- **`pubspec.yaml`** suma solo el bloque `fonts:`; `pubspec.lock` no cambia.
- **Pruebas: 1126/1126** (1063 + 63, ninguna omitida), con las tres pautas de accesibilidad de Flutter. El contraste da 0 pares bajos. La auditoría de `flutter-ui` no tiene críticos nuevos; los avisos nuevos son los hexadecimales de los dos archivos de tokens, que son la única fuente de color.
- **Un defecto real que encontró una prueba:** 28 650 kg salían como «28.6 t» por el redondeo binario de `toStringAsFixed`. El formato nuevo redondea la décima hacia arriba.
- **El tema todavía no se conecta** en `lib/core/app.dart`, a propósito: se conecta con la primera pantalla de la Fase 3, para comparar las capturas del antes y del después.

**Yov la revisó** contra los archivos: la licencia y la procedencia de las fuentes, el bloque `fonts:`, el formato de toneladas y la regla de publicación directa. Coinciden con el informe.

**Un aviso de `analyze` que no es del rediseño.** `tool/t100_sintetico.dart:21` tiene un `import 'dart:convert'` sin uso desde `f7e38a3` (T-100, el manual, 21-oct). Entró después de los commits de cierre: `sprint3-cierre` y `sprint3-cierre-2` sí daban cero, y es lo que dice el documento del Incremento 3. `v3.0` lleva ese aviso en `tool/`, no en `lib/`. **Yov autoriza quitar esa línea** en `sprint-4`: lo hace Timonel al empezar la Fase 3, para que `analyze` vuelva a cero absoluto.

**Las tablas fijas de color (5.3 de `DESIGN.md`) esperan a Carlos.** Timonel las sacó del corpus, solo los códigos:
- **16 puertos de destino:** JMKIN, USHOU, GTSTC, JMKCT, PAMIT, COSPC, JMKWL, PACCT, GTPBR, USPEF, PAONX, VEPBL, VELAG, COCTG, USMSY y XXVSL.
- **13 tipos ISO de vacío:** 45G1, 22G1, 45G0, L5G1, 45R1, 42G1, 42U1, 42P3, L5G0, 22K2, 22U1, 22T1 y 45R8.
- **`XXVSL` no es un UN/LOCODE real** (`XX` no es un país). Probablemente es un marcador del corpus. Yov propone sacarlo de la tabla, salvo que Carlos sepa qué es.
- **Carlos confirma** la lista, quita lo que sobre y agrega los puertos frecuentes de COMAR que falten. Las 24 ranuras dan para 8 puertos más. El orden importa poco: las ranuras 0 a 11 son tonos suaves y las 12 a 23, intensos.

**Siguiente:**
1. Carlos versiona la Fase 2.
2. Carlos confirma las tablas.
3. Codex acepta la Fase 2 en una copia limpia: `C:\Proyectos\baystream-qa-r4`, un worktree aparte, porque en la carpeta del rediseño solo trabaja Timonel.
4. Después, la Fase 3, que empieza por el inicio.

La siguiente decisión es la **10.6**.

### 10.6 · Las tablas de color, confirmadas · Las ranuras libres las asigna la oficina (nace T-115) (22-oct, 10:39)

**Carlos confirma las tablas fijas de 10.5, con un cambio:** las ranuras que quedan libres no se dejan solo al cálculo; la oficina decide a mano qué puerto va en cada una.
- **Puertos fijos (15):** JMKIN, USHOU, GTSTC, JMKCT, PAMIT, COSPC, JMKWL, PACCT, GTPBR, USPEF, PAONX, VEPBL, VELAG, COCTG y USMSY. `XXVSL` sale, porque no es un UN/LOCODE (10.5).
- **Tipos de vacío fijos (13):** los de 10.5, sin cambios.
- **Quedan 9 ranuras libres de puertos (15 a 23).** La oficina asigna en ellas los puertos que maneje seguido. Lo que no esté ni en la tabla fija ni en las asignadas usa el cálculo, como antes.

**Por qué es una tarea aparte y no parte del rediseño.** La regla de 10.2 exige que un puerto tenga el mismo color en la oficina y en el muelle. Si la oficina asigna un color, la asignación tiene que viajar al muelle: se guarda en Firestore y en la copia local del dispositivo, y eso toca `data/` y las reglas de Firestore. El rediseño solo toca la presentación.

**Nace T-115 · Colores de puerto asignados por la oficina** (≈ 3 h; la hace un programador, la acepta otro; la ficha completa la escribe Yov al programarla):
- **Dónde vive:** un documento de configuración en Firestore. Lo leen todas las cuentas autorizadas y lo escribe solo el rol de oficina. Hay copia local para trabajar sin red. Cambia `firestore.rules`: lo publica Carlos desde la consola, después de la batería del emulador.
- **Qué ve la oficina:** en Parámetros, las 9 ranuras libres con su color de muestra. A cada una le asigna un puerto con sus 5 letras, validado como UN/LOCODE (con la lista de UNECE, que también resuelve el `ZZZZZ` de 10.92 de `SPRINT-3.md`). También puede liberar una ranura. Los 15 puertos fijos no se reasignan.
- **Qué ve el muelle:** los mismos colores, que llegan por la sincronización como el resto de la operación.
- **Sin cuenta:** solo la tabla fija y el cálculo.
- **Cómo se engancha al rediseño:** la Fase 2 ya deja la tabla como un parámetro del tema (`tablaFija`). T-115 aporta un provider que junta la tabla fija con las asignaciones de la oficina, y la Fase 3 no cambia.

**Para el rediseño:** Timonel pone las tablas fijas confirmadas en el tema al empezar la Fase 3, y `DESIGN.md` 5.3 anota las 9 ranuras de la oficina (T-115).

La siguiente decisión es la **10.7**.

### 10.7 · La Fase 2 no pasa la aceptación: dos defectos de `BsCelda` · La corrección, antes de la Fase 3 (22-oct, 11:00)

**Codex aceptó la Fase 2 con dictamen NO PASA** (`docs/rediseno/fase2/aceptacion-codex.md`, sobre `8c591c8`, en la copia limpia `C:\Proyectos\baystream-qa-r4`).
- **Lo que pasa:**
  - el alcance: 38 archivos exactos;
  - la suite: 1126/1126, sin omitidas, y `analyze` solo con el aviso de T-100;
  - las siete fuentes: idénticas al origen de IBM, descargadas y comparadas byte a byte, con su licencia;
  - los tokens, el contraste de los colores opacos, los formatos y las ranuras FNV-1a (recalculados por su cuenta);
  - la Web sin conexión: `t92_verify` en verde, con las Plex servidas desde el sitio.
- **H1, el defecto que bloquea: la celda atenuada no cumple el contraste.** Con `atenuada: true` (lo que «Resaltar» usa para lo que no coincide), el alfa de 0.35 cae también sobre el texto. El código de la celda queda en **2.08:1 en claro y 2.89:1 en oscuro**, frente a 4.5:1, y la celda sigue siendo tocable.
  - **Peor:** la prueba de accesibilidad lo da por bueno. La celda expone una etiqueta accesible distinta del texto dibujado, así que `textContrastGuideline` no encuentra el código y no lo mide. Las pruebas de contraste de la celda daban una seguridad falsa.
- **H2: la segunda línea de 10 sp se dibuja también en el muelle.** `DESIGN.md` 4.2 la reserva para la oficina con zoom de 100 % o más.
- **O1, la auditoría:** los 161 avisos nuevos son 128 en `bs_colores_semanticos.dart`, 32 en `bs_paleta.dart` y 1 de movimiento reducido (`bs_movimiento.dart:36`, un falso positivo, porque es el interruptor de accesibilidad). El informe de Timonel los atribuía a un solo archivo. Corrige también la frase de 10.5, que olvidó el aviso de movimiento.
- **Una observación:** la compilación Web avisa que falta la familia `CupertinoIcons`. Está por confirmar si viene de antes; se revisa en la Fase 3.

**Yov acepta el dictamen.** Los dos hallazgos están bien reproducidos, y H1 importa más de lo que parece: era un hueco en la forma de probar el contraste, no solo un color.

**La corrección (Timonel, antes de la Fase 3):**
1. **Atenuar sin perder la lectura.** La celda atenuada baja el relleno y el contorno, pero el código queda en una tinta que cumple **4.5:1 sobre el color ya compuesto**, y el contorno, **3:1**. Esto vale para todos los estados de la celda (normal, atenuada, cancelada, de paso, reservada y en movimiento), en claro y en oscuro, y en las dos densidades. No se quita la etiqueta accesible para hacer pasar la prueba.
2. **Una prueba que mida lo que se dibuja.** Para cada estado y tema, calcula con `Color.alphaBlend` el color del texto y del fondo tal como se componen sobre el papel, y exige 4.5:1 y 3:1. No depende de `textContrastGuideline`. Las pruebas de Codex de `diagnostico_test.dart` sirven de punto de partida.
3. **La segunda línea, solo en la oficina.** `BsCelda` la oculta en la densidad de muelle, aunque se la pasen, y en la oficina la muestra solo con zoom de 100 % o más, con un parámetro de zoom explícito. Se ajustan la vista previa y las pruebas.
4. **Las tablas fijas de 10.6, en el tema:** los 15 puertos y los 13 tipos de vacío, con su prueba. `DESIGN.md` 5.3 anota las 9 ranuras de la oficina (T-115) y quita `XXVSL`.
5. **El aviso de T-100:** se borra el `import 'dart:convert'` sin uso de `tool/t100_sintetico.dart` (autorizado en 10.5), para que `analyze` quede en cero absoluto.
6. **El informe:** se corrige el reparto de los avisos de la auditoría (O1).

**Después:** Carlos versiona la corrección y pone la copia limpia en el commit nuevo, y Codex vuelve a aceptar. Basta con repetir los puntos 2, 4, 5, 8 y 10, más los dos hallazgos, con sus pruebas de diagnóstico.

La siguiente decisión es la **10.8**.

### 10.8 · La corrección de la Fase 2, entregada: la prueba nueva encontró dos defectos más (22-oct, 11:40)

**Timonel corrigió lo de 10.7** (≈ 0.6 h; sección «Fase 2 · Corrección» del informe). Ninguna pantalla cambia:
- **H1, la celda atenuada:** ya no pone alfa en el texto. El relleno baja al 35 %, compuesto sobre el papel y opaco; el código va en tinta suave y el contorno en línea fuerte. Vale para todos los estados, en claro y en oscuro, y en las dos densidades. La etiqueta accesible se conserva.
- **La prueba que mide lo que se dibuja** (`test/t114_celda_contraste_test.dart`): compone con `Color.alphaBlend` el relleno sobre el fondo, y el texto, los iconos y el contorno sobre el relleno. Son 75 estados, sobre papel, cubierta y bodega, en dos temas y dos densidades: 900 casos. Exige 4.5:1 al texto y 3:1 a iconos y contorno, sin depender de `textContrastGuideline`.
- **Esa prueba encontró dos defectos más, ya corregidos:**
  - la línea fuerte de la Fase 1 quedaba en 2.87:1 sobre el acero tenue de la bodega; el token pasa a `#6D809F` en claro y `#6983A3` en oscuro (Yov recalculó: 3.76 y 3.39 en claro; 4.65 y 3.44 en oscuro);
  - la insignia de carga especial no llegaba a 3:1 sobre los rellenos intensos en oscuro; ahora toma el primer color de su rol que llega a 3:1.
- **H2:** `BsCelda` recibe un `zoom` explícito. La segunda línea sale solo en la oficina, con zoom de 100 % o más, y si cabe con la escala de letra; en el muelle, nunca.
- **Las tablas de 10.6, en el tema por omisión:** 15 puertos sin `XXVSL` y 13 tipos; las ranuras 15 a 23 quedan para T-115.
- **El aviso de T-100,** quitado: `analyze` da **«No issues found»**.
- **El reparto de la auditoría,** corregido en el informe (128, 32 y 1).
- **Validaciones:** **1143/1143** (1126 + 17, ninguna omitida), el contraste con 0 pares bajos y la auditoría igual a la entrega. La celda de la oficina pasa de 52×44 a 52×48.

**Yov la revisó** contra el informe y `bs_celda.dart`, y recalculó la línea fuerte nueva. Que la prueba nueva encontrara dos defectos más confirma lo de 10.7: la forma de probar era el problema.

**Para la Fase 3, una condición que pasa a ser obligatoria.** El código de cinco letras con la letra del sistema a 2.0 no cabe en una celda de 52 o 56 dp, y se corta con elipsis (`DESIGN.md`, 12). Para RNF-003, un código cortado es un texto cortado. La rejilla del plano tiene que dimensionar la celda según la escala de letra: más ancha, con desplazamiento y zoom, pero con el código completo a 1.0, 1.45 y 2.0. Se comprueba con las capturas.

**Siguiente:** Carlos versiona la corrección y pone la copia limpia en el commit nuevo, y Codex vuelve a aceptar lo que tocó la corrección.

La siguiente decisión es la **10.9**.

### 10.9 · La Fase 2 del rediseño, terminada · La Fase 3 arranca por el inicio (22-oct, 12:15)

**Codex aceptó la corrección: ACEPTADA con observaciones** (`docs/rediseno/fase2/reaceptacion-codex.md`, sobre `5406e20`).
- **Pasa:** el alcance (17 archivos exactos); 1143/1143 y `analyze` limpio; la prueba compuesta (900 casos), más dos estados que Codex probó por su cuenta; la línea fuerte nueva sobre los cuatro fondos; las 144 combinaciones de insignias (la peor, 3.12:1); las 60 de la segunda línea; las tablas, iguales en Dart y en el script; y en T-100, solo la línea del `import`.
- **O1:** su diagnóstico de la primera ronda ya no compila con la firma nueva de `BsRol.atenuado`. Hizo una copia compatible, y pasa 10/10. No es un defecto del producto.
- **O2:** el contorno se exige 3:1 contra el fondo exterior, que es lo que delimita la celda. Hacia su propio relleno puede quedar por debajo (2.55:1 en «en movimiento» atenuada sobre la bodega en oscuro). **Yov acepta ese criterio:** es el de WCAG 1.4.11 para el borde de un componente.
- **O3:** que nada desborde a 2.0 no significa que el código de cinco letras se vea entero. Sigue siendo una obligación de la Fase 3 (10.8).
- **`CupertinoIcons`:** el aviso de la compilación Web también sale en `v3.0`. `lib/` no usa `CupertinoIcons` ni depende de `cupertino_icons`, así que es inofensivo, y se deja.

**T-114, Fase 2: Terminada.** El piso sube a **1143**, con `analyze` en cero absoluto.

**La Fase 3 arranca** con Timonel en Ultracode, una pantalla por entrega y Codex aceptando cada una. **La primera entrega es el inicio, con la primera visualización en tres pasos:**
- el tema conectado en `lib/core/app.dart`;
- el estado de previo («ver primero, confirmar después», `DESIGN.md` 7), con su banda, «sin evaluar hasta confirmar el perfil» y sin exportar;
- los recientes en el inicio, y la regla estricta de publicación directa;
- los instrumentos de T-98 y T-99 actualizados, y RNF-002 medido otra vez.

La navegación adaptable y el plano van en la entrega siguiente, salvo que Timonel justifique que el inicio no se puede entregar sin ellas.

La siguiente decisión es la **10.10**.

### 10.10 · Nace T-116: pruebas automatizadas para la exposición del curso (22-oct, 12:30)

**El encargo del curso.** Hay que exponer la automatización de pruebas aplicada al proyecto: elegir una herramienta distinta de las de los compañeros, explicar sus funciones y mostrar ejemplos de pruebas de requerimientos funcionales, de caja blanca y de interfaz, más un entregable de las pruebas. **Carlos elige el stack del propio proyecto:** `flutter_test`, `integration_test` y `fake_cloud_firestore`, más el emulador de Firebase, que el proyecto ya usa para las reglas (T-113). Firebase Test Lab se presenta como opción y no se usa, porque tocaría Firebase.

**Lo que el proyecto ya tiene** y la exposición aprovecha: 1063 pruebas en `v3.0` (1143 en `sprint-4`); `integration_test` en el arnés de rendimiento de T-99; y la batería de reglas de Firestore en el emulador (69/69 y 25/25 de abuso, T-113).

**T-116 · Pruebas para la exposición** (≈ 2 h; la hace Codex, que está libre mientras Timonel hace la Fase 3; la revisa Yov):
- **Dónde:** una carpeta y una rama propias, `C:\Proyectos\baystream-pruebas` en `pruebas-curso`, desde `origin/master` (el código de `v3.0`, el publicado). Así no se cruza con el rediseño ni con la carpeta del piloto. Después de la exposición, Carlos la mezcla en `sprint-4`.
- **Caja blanca:** `Iso6346CheckDigit.isValid` (`domain/services/iso6346_check_digit.dart`). Hay que cubrir cada camino: el formato que no cumple la expresión regular, la rama de dígitos, la de letras (con el salto de los múltiplos de 11), el residuo 10 que se escribe 0, y el dígito correcto y el incorrecto.
- **Requerimiento funcional:** la sincronización entre la oficina y el muelle (RF-032), con `FakeFirebaseFirestore` inyectado en `FirestoreOperationSync` y `FirestoreRemoteMovementStore`. La oficina publica, el muelle se une y registra una descarga, y la oficina la recibe. Más las reglas de negocio: sin sesión no se publica, y el muelle no publica. El falso no evalúa las reglas de seguridad: eso lo hace la batería de T-113.
- **Interfaz:** el buscador de contenedores (`ContainerSearchDelegate`) dentro de `showSearch`: escribir, ver los resultados, tocar uno, y el caso sin resultados.
- **El entregable:** `flutter test --reporter expanded`, `flutter test --coverage` y un reporte HTML de cobertura hecho con un script de Python sin dependencias en `tool/`, porque en Windows `genhtml` no viene instalado. `/coverage/` entra al `.gitignore`.
- **`fake_cloud_firestore` se autoriza** como dependencia de desarrollo, con versión fija y sin mover ningún paquete existente del `pubspec.lock`. Si para resolverla hay que mover alguno, Codex se detiene y avisa.
- **Reglas:** no se toca `lib/`; solo `test/curso/`, el script, `pubspec.*` y `.gitignore`. Cuenta el semáforo con Timonel, porque comparten la máquina.

**Yov** prepara el contenido de la exposición (la explicación de la herramienta y el guion de las diapositivas) cuando Codex entregue, con los números reales.

La siguiente decisión es la **10.11**.

### 10.11 · T-116: `fake_cloud_firestore` 4.1.1, para no mover `equatable` (22-oct, 12:35)

**Codex se detuvo, como pedía la ficha:** `fake_cloud_firestore` 4.2.0 movía `equatable` de 2.0.8 a 2.1.0. Los otros nueve paquetes eran nuevos, y no tocó ningún archivo.

**Yov no autoriza el cambio.** `equatable` es una dependencia de la app (las entidades del dominio comparan con ella), y una herramienta solo de pruebas no debe cambiar el código que se publica.
- **La alternativa, comprobada en pub.dev:** `fake_cloud_firestore` **4.1.1** pide `equatable ^2.0.5`, `cloud_firestore ^6.4.0` y `cloud_firestore_platform_interface ^8.0.0`. El `pubspec.lock` de `master` trae 2.0.8, 6.8.0 y 8.0.6, así que encaja sin mover nada.
- Codex fija 4.1.1 y repite la resolución en seco. Si aun así se mueve algún paquete existente, se detiene otra vez.

La siguiente decisión es la **10.12**.

### 10.12 · T-116: 4.1.1 no compila; se autoriza `equatable` 2.1.0 con `fake_cloud_firestore` 4.2.0 (22-oct, 12:45)

**Codex comprobó que 4.1.1 no sirve.** Conserva los 117 paquetes, pero no compila con `cloud_firestore` 6.8.0: su `update` de las transacciones tiene la firma vieja (`Map<Object, Object?>`), y 6.8.0 exige `update<T>(DocumentReference<T>, T)`. Codex propuso una copia local de 4.1.1 con esa corrección.

**Yov no recomienda la copia corregida:** sería mantener código de terceros modificado dentro del repo, solo para una prueba. En cambio, revisó qué cambia de `equatable` 2.0.8 a 2.1.0, comparando el código de los dos paquetes de pub.dev:
- **La lógica de igualdad no cambia** (`equatable_utils.dart` solo suma un comentario).
- `Equatable` pasa a ser `abstract mixin class`, y `EquatableMixin` queda obsoleto.
- El proyecto no usa `EquatableMixin` en `lib/`, `test/` ni `tool/`: sus 19 clases usan `extends Equatable`, que sigue igual. No hay aviso nuevo de `analyze`, ni cambio de comportamiento.

**Se autoriza, con la conformidad de Carlos:** `fake_cloud_firestore` **4.2.0**, fija, hecha para `cloud_firestore` ^6.7.1, y con ella `equatable` 2.0.8 → **2.1.0**, el único paquete existente que se mueve.
- **Condiciones:** la resolución en seco no mueve nada más; la suite completa de `master` (1063) sigue en verde; `analyze` no suma avisos (el de T-100 ya es conocido); el informe anota el cambio y por qué.
- Al mezclar `pruebas-curso` en `sprint-4`, se repiten la suite y `analyze`.
- **10.11 queda sustituida.**

La siguiente decisión es la **10.13**.

### 10.13 · T-116, entregada y revisada (22-oct, 13:00)

**Codex terminó T-116** en `pruebas-curso` (`docs/PRUEBAS-CURSO.md`):
- **21 pruebas nuevas en `test/curso/`:**
  - **16 de caja blanca** sobre `Iso6346CheckDigit`, con la tabla de camino → caso y los dígitos calculados por su cuenta (Yov recomprobó el residuo 10 de `AAAU0000060`);
  - **3 funcionales de RF-032** con `FakeFirebaseFirestore`: la oficina publica, el muelle se une y la descarga llega por la escucha; sin sesión, `no_session`; el muelle no publica, `not_office`;
  - **2 de interfaz** sobre el buscador abierto con `showSearch`.
- **La suite:** **1084/1084** (1063 + 21), sin omitidas. `analyze` da solo el aviso conocido de T-100, que en `master` sigue.
- **Las dependencias:** `fake_cloud_firestore` 4.2.0 fija, y entre los 117 paquetes originales solo cambia `equatable` (10.12).
- **La cobertura:** **89.28 % de las líneas instrumentadas.** Son las de los 122 archivos de `lib/` que la suite carga; los otros 15 no entran en el denominador, y así se dice en la exposición. Iso 6346 tiene el 100 %, la sincronización el 62 % y el buscador el 89 %.
- **El reporte HTML** (`tool/cobertura_html.py`) se abre sin red; Codex lo verificó en Edge con la red cortada.
- **La prueba de integración opcional no se hizo:** `main()` exige Firebase, y la ficha decía que entonces no.
- **Los límites, declarados:** el falso no evalúa las reglas de seguridad (eso lo hace la batería de T-113), y la cobertura de LCOV es de líneas, no de ramas.

**Yov la revisó y la acepta** como material del curso. Después de la exposición, Carlos mezcla `pruebas-curso` en `sprint-4`, repitiendo la suite y `analyze` (10.12).

**Yov** prepara el contenido de la exposición: la explicación de la herramienta y el guion de las diapositivas.

La siguiente decisión es la **10.14**.

### 10.14 · El rediseño cambia de dirección: «Puente de mando» (22-oct, 15:51)

**Por qué.** Carlos vio la entrega 1 de la Fase 3 y la sintió pobre y sin impacto. Yov coincide, y una parte es suya: recomendó la dirección A pensando en leer al sol, y el encargo era impacto. Además:
- lo que se vio era el tema nuevo sobre las pantallas de antes; el plano por bahía todavía no se rediseñaba;
- la tabla fija (10.6) da a los cinco primeros puertos (JMKIN, USHOU, GTSTC, JMKCT y PAMIT) cinco tonos seguidos de la rueda, a 30° uno de otro, y en claro casi no se distinguen;
- del ícono se tomaron los colores, no su forma.

**Carlos aprueba el concepto completo (15:51)**, que Yov dibujó en un lienzo de diseño con las siete referencias que reunió Carlos y lo útil de las sugerencias de Google. Las fuentes de sus cuatro mesas (oficina, muelle, inicio y sistema) quedan en `docs/rediseno/concepto/`, con su `LEEME.md`.

**La dirección C, «Puente de mando»: la app es el ícono en grande.**
- **El tema por omisión depende del equipo:** oscuro en Windows y la Web (la oficina) y claro en Android (el muelle). La preferencia de T-90 (claro, oscuro o sistema) sigue igual: solo cambia lo que pasa cuando el usuario nunca eligió.
- **La noche (oscuro):** noche `#07111F`, con la rejilla de plano al 5 % de `#6E9DE6`; panel `#0C1A31`; panel alto `#11223F`; línea `#1E3457`; línea fuerte `#5272A6` (3.6:1 sobre el panel); tinta `#EAF0F9`; tinta suave `#A9B9D2`; tinta tenue `#8DA0BE`; selección `#4F8EF7`; hecho `#3DD68C`; aviso `#F5B83D`; crítico `#F2777A`. La marca `#0D47A1` va como superficie con texto blanco (8.6:1): el riel activo y la banda del muelle. **El día (claro) no cambia:** es el de la Fase 2.
- **El plano se dibuja como el ícono (vista Estado):** por bajar, en el blanco de la cubierta `#F5F8FC` y el acero de la bodega `#6E9DE6`, con tinta oscura (17:1 y 6.6:1); de paso, apagado (panel alto con tinta suave, 7.9:1); bajado, la celda vacía con su contorno punteado y la marca de hecho. La bodega se cierra con la curva del casco, y sus celdas de los extremos llevan esa curva, como en el ícono.
- **El naranja marca solo lo que se acaba de mover.** La celda que otro equipo acaba de bajar o cargar sale de su celda, como el contenedor del ícono, y se apaga en 1.5 s; la bahía donde pasó destella en la silueta. En el muelle, el toque en «Baja» hace lo mismo antes del aviso con «Deshacer». Sin animación si el sistema pide reducir movimiento, y siempre con su anuncio para el lector de pantalla.
- **No se inventan datos.** La app no sabe qué grúa mueve qué ni dónde está la superestructura del buque, y el panel «En vivo» dice el rol (Muelle u Oficina), nunca un nombre ni un identificador. El «Grúa 2» del lienzo es solo ilustración.
- **El muelle:** una banda azul de la marca arriba, con el ícono sin recuadro, el buque, la nube y Descarga o Carga; «Baja» en el azul de la marca con texto blanco; «Hecho» y «Paso» con los roles de la Fase 2.
- **Destino y tipo en oscuro, como fichas:** relleno profundo del tono, y código y contorno en el tono vivo (≈ 7:1). En claro, los rellenos suaves de la Fase 2.
- **La tabla reparte los tonos dando saltos:** ranura k → tono [11, 6, 3, 9, 1, 8, 4, 0, 10, 5, 2, 7][k mod 12], suave hasta la 11 e intensa desde la 12. Los cinco primeros puertos quedan a 60° o más: JMKIN rosa, USHOU cielo, GTSTC hierba, JMKCT uva y PAMIT ámbar. Las tablas de códigos de 10.6 y la ranura de reserva (FNV-1a) no cambian.
- **Piezas nuevas:** la marca en código (con recuadro, sin él y monocroma, y la espera: el contenedor naranja que sube y baja); la silueta del buque de proa a popa, con el avance por bahía; el casco de la bodega; las tarjetas de cifra grande y el anillo de avance; el panel «En vivo»; la banda del muelle.
- **De las sugerencias de Google entra** el mosaico de cifras, el oscuro técnico solo en la oficina, CustomPainter para la silueta y el casco (las celdas siguen siendo widgets, por el toque, el foco y la etiqueta accesible) y el pulso de lo que llega por Firebase. **No entra:** los mapas (no hay geografía en el alcance, y los mapas en línea rompen el trabajo sin conexión), arrastrar contenedores (es una función nueva que toca el dominio), shimmer, hugeicons ni lucide.
- **Ninguna dependencia nueva.** Los íconos del dominio y las ilustraciones los hace el chat de la nube de Carlos, con el prompt de `claude/BayStream_Puente_de_mando.md` (proyecto de Claude): primero tres estilos y después un zip con una fuente empaquetada, sus códigos, los SVG y las ilustraciones como JSON de trazos que la app pinta sola. Lo integra Timonel en una entrega y lo acepta Codex, como el ícono en T-88. Mientras tanto, Material Symbols.

**Lo que se queda:** todo lo de la Fase 2 (tokens, tema, `ThemeExtension`, componentes, Plex y pruebas) y lo funcional de la entrega 1. Cambian valores y se suman piezas. Material 3 sigue de base.

**La entrega 1 de la Fase 3 quedó cerrada en lo funcional** (sección «Fase 3 · Entrega 1» de `docs/REDISENO-RESULTADOS.md` y `docs/rediseno/fase3/traspaso-entrega1.md`): el tema conectado, los estados del viaje en una `sealed class`, «ver primero, confirmar después» y RNF-002 en tres pasos en los tres clientes, antes seis (Windows 1.83–1.90 s, la Web 0.30–0.42 s y el emulador 2.98–3.25 s). El piso sube a **1156**: 13 pruebas nuevas, 19 actualizadas y ninguna omitida. **Yov revisó** que el bloque de git cubre los 190 archivos que cambiaron (fuera quedan solo los `__pycache__` de `tool/`) y una muestra de las capturas, sin datos reales, correos ni el corpus. La acepta Codex en la copia limpia.

**Lo que sigue:**
1. Timonel, en un chat nuevo, porque el anterior se llenó: la Fase 1 bis (`DESIGN.md` con la dirección C, sin tocar `lib/`) y la Fase 2 bis (la noche, la tabla reordenada, las fichas, el tema por equipo y las piezas nuevas, con sus pruebas y sus vistas previas). Se detiene: Codex acepta y Yov revisa `DESIGN.md`.
2. La Fase 3 sigue con el plano por bahía, ya en la dirección C; después, el muelle, el avance, las estadísticas y el inicio, con la ilustración cuando llegue el paquete.

La siguiente decisión es la **10.15**.

### 10.15 · La entrega 1 no pasa la aceptación: «No lo tengo» viene marcado con una plantilla · La corrección va antes de la Fase 2 bis (22-oct, 16:50)

**Codex aceptó la entrega 1 con dictamen NO PASA** (`docs/rediseno/fase3/aceptacion-codex.md`, sobre `16fa15d`, en la copia limpia).
- **Pasa:**
  - el alcance, salvo O1;
  - 1156/1156 sin omitidas, y `analyze` limpio;
  - el previo no guarda nada, `publishedVoyage` no lo ve, no se exporta ni se opera, y descartar pregunta;
  - la regla estricta de 7.2 y el hallazgo 5;
  - RNF-002 en Windows (su corrida: 3 pasos, 2.722 s), en la Web y en el emulador;
  - las 115 capturas, sin correos, cuentas ni corpus (revisadas a mano y con OCR);
  - la auditoría, sin críticos reales ni avisos en lo tocado;
  - los censos (1816 cadenas; M3 259/8/5);
  - la Web sin conexión (T-92).
- **H1, que bloquea:** al confirmar el previo con una plantilla sin límite, «No lo tengo» ya viene marcado. Está en `vessel_geometry_page.dart:171–173`, que lo marca si hay geometría inicial, si es solo el perfil o si el origen es una plantilla, siempre que el límite sea nulo. Eso incumple 10.2: «No lo tengo» no se marca por omisión. La condición es anterior al rediseño, pero el recorrido nuevo la deja a la vista.
  - **La regla:** solo viene marcado si el perfil es del mismo buque, lo declaró el usuario (`declaredByUser`) y no tiene límite. Con una plantilla o con la propuesta del archivo, empieza sin marcar.
- **O1, la evidencia Web «con perfil» no entró a git.** Los cinco archivos existen, pero en una carpeta llamada `con`, que en Windows es un nombre reservado, como `prn`, `aux` o `nul`. Git y las herramientas de Windows no la ven, y por eso fallaron los cinco `git add`; Codex los dio por ausentes y la causa la encontró Yov. Se renombra a `con-perfil`, el instrumento deja de usar nombres reservados y el informe se corrige.
- **O2:** en `test/profile_loading_test.dart:142,147,152` se debilitaron tres comparaciones del perfil: ahora miran solo `.key` o `hasLength(1)`. Vuelven a comparar los campos que importan, salvo `updatedAt`.
- **O3:** los censos se reproducen con la referencia `5406e20`. El informe la declara y se actualiza la ayuda de `tool/t112_censos.py`.
- **O4:** en la copia limpia faltaba en disco `docs/rediseno/fase2/reaceptacion-codex.md`, porque en la Fase 2 el informe se movió a la rama en vez de copiarse. Carlos lo restaura en `qa-r4`, y de aquí en adelante los informes se copian.
- **La incidencia de semáforo** que Codex declaró no afectó ninguna medición: empezó a compilar Windows antes de recoger el fin de `analyze`. Queda anotada.

**Yov acepta el dictamen y los cuatro hallazgos.** La corrección la hace Timonel ahora, antes de seguir con la Fase 2 bis, con su propio bloque de git. Después, Codex vuelve a aceptar solo lo que toque la corrección.

La siguiente decisión es la **10.16**.

### 10.16 · La corrección de la entrega 1 y las Fases 1 bis y 2 bis, entregadas · El tema sigue al sistema (22-oct, 17:30)

**Timonel entregó dos commits:** `3144b64`, con la corrección de 10.15, y `36f5784`, con las Fases 1 bis y 2 bis.
- **La corrección.**
  - «No lo tengo» viene marcado solo si el perfil es del mismo buque, lo declaró el usuario y no tiene límite. Con una plantilla o con la propuesta, empieza sin marcar, y sin elegir no se confirma. Cuatro pruebas lo fijan, incluido el caso de BUQUE BETA como plantilla para BUQUE ALFA.
  - La carpeta `con` pasa a ser `con-perfil`, con los mismos cinco archivos, que ya están en git. El instrumento rechaza los nombres reservados.
  - Las tres aserciones vuelven a comparar el perfil, salvo `updatedAt`.
  - La referencia `5406e20` de los censos queda declarada.
  - El piso sube a 1160.
- **La Fase 1 bis.** `DESIGN.md` 13 es la dirección C, y la A queda como historia. Timonel tomó dos decisiones que el concepto no fijaba, y Yov las acepta:
  - de noche, `primary` es la selección `#4F8EF7`, porque la marca como texto no llega (1.6:1); la marca va como superficie;
  - de noche, la selección de los segmentos y de los chips se invierte.
- **La Fase 2 bis.**
  - Lo hecho: la noche, los roles de la vista Estado, las fichas en OKLCH y la tabla a saltos. Las fichas intensas llevan el relleno en L 0.44 C 0.12, y el código y el contorno en L 0.93 C 0.06.
  - Nueve piezas nuevas: `BsMarca`, `BsSiluetaBuque`, `BsCascoBodega`, los estados y la curva de `BsCelda`, `BsTarjetaCifra`, `BsAnilloAvance`, `BsPanelEnVivo`, `BsBandaMuelle` y `BsFondoDePlano`. Cada una tiene su prueba, su vista previa y las tres pautas, y con `disableAnimations` nada se mueve.
  - Las cifras: **suite 1223**; `analyze` en cero; el contraste, sin pares bajos; la auditoría, sin críticos ni avisos en `lib/core/design/` fuera de los dos archivos de tokens.
  - Ninguna pantalla cambia, y no hay cambios en `domain/`, `data/`, `lib/main.dart` ni `pubspec.*`.
- **Un hallazgo del instrumento.** Con los rellenos de «por bajar», la celda atenuada dejaba el código en 3.5:1 y en 3.1:1. La regla pasa a «tinta suave, y si no llega a 4.5:1, tinta».

**Yov revisó** los dos bloques de git, que cubren los 38 archivos que cambiaron; `DESIGN.md` 13 contra 10.14; y la corrección en el código. Quedan dos observaciones, que se corrigen en la entrega 2:
- **El contador de «Más» en el color de la grúa** (13.3, punto 6) contradice la regla del naranja. Las alertas van en aviso o en error.
- **Una prueba frágil.** `t114_fuentes_test` mide `LICENSE-IBMPlex.txt` con fin de línea CRLF, y falla en una copia con LF, como la que saca `git archive`. La prueba no debe depender del fin de línea.

**El tema por omisión: Carlos decide que siga al sistema (17:30).** `bayStreamTemaPorOmision` queda preparado y sin conectar, y `domain/` y `data/` no cambian. Para ver la noche en Windows o en la Web: Parámetros → Oscuro (T-90). `DESIGN.md` 13.5 lo anota.

**Lo que sigue:**
1. Codex acepta la corrección y la Fase 2 bis en la copia limpia.
2. En paralelo, Timonel empieza la entrega 2 de la Fase 3: el plano por bahía en la dirección C. Si Codex encuentra algo, eso va primero.

La siguiente decisión es la **10.17**.

### 10.17 · La corrección 10.15, aceptada · La Fase 2 bis no pasa: la celda salta en vez de salir (22-oct, 17:45)

**Codex aceptó en la copia limpia, sobre `c287792`** (`docs/rediseno/fase2bis/aceptacion-codex.md`).
- **La corrección 10.15 (`3144b64`): ACEPTADA.** Repitió su diagnóstico: la plantilla y la propuesta empiezan sin marcar, y el perfil propio declarado viene marcado. Pasan las cuatro pruebas nuevas, los cinco archivos de `con-perfil` coinciden con la medición, el instrumento rechaza los 22 nombres reservados, `_mismoPerfil` compara los ocho campos y la referencia `5406e20` está declarada.
- **La Fase 2 bis (`36f5784`): NO PASA por un hallazgo nuevo (H1).** La celda recién movida salta a su sitio final sin recorrer los 150 ms. `AnimatedSlide` se crea ya en `Offset(0, -0.5)` (`bs_celda.dart:369–391`), así que no tiene desde dónde interpolar: a los 0, 75 y 150 ms la posición y los píxeles son iguales. La prueba entregada solo mira el destino. Es justo la firma de la dirección C, el contenedor que sale de su celda.
- **Pasa todo lo demás:** el alcance (11 + 27 + `SPRINT-4.md`); 1223/1223 sin omitidas; `analyze` en cero; el contraste y su cálculo independiente (seis fichas OKLCH recalculadas por su cuenta); la tabla reordenada (60° en la rueda y 55° en OKLCH); 16 casos propios de inmovilidad con reducción de movimiento; T-90 sigue al sistema y el tema por equipo no está conectado; la Web sin conexión (T-92). Tampoco hay datos inventados: `BsPanelEnVivo` solo acepta el rol del equipo, y la silueta no dibuja superestructura ni grúa.
- **O1 y O2, de documentación:** `DESIGN.md` 13.6 dice que la silueta tiene alto 112 y botones de 48 dp, y que la cifra va a 40. El código, que es lo correcto, usa 56 dp de ancho por bahía, una altura que se adapta y la cifra a 34. Se corrige el documento, no el código.
- **O3:** siguen pendientes el naranja de «Más» y la prueba de la licencia, de 10.16.
- **O4, precisión:** fuera de los tokens queda un aviso automático, el `Duration.zero` del interruptor de accesibilidad. Ya se conocía, está justificado y no se quita.

**Yov acepta el dictamen.** Timonel corrige H1 antes de seguir con la entrega 2, en un bloque aparte:
- la celda sale de verdad, de 0 a media celda en 150 ms, con `Transform`, y con reducción de movimiento se queda quieta;
- al volver a «bajado» no se ve regresar;
- una prueba compara el fotograma inicial, uno intermedio y el final, y falla con la versión de `36f5784`.

En el mismo bloque, `DESIGN.md` 13.6 y 13.3 (O1, O2 y el naranja de «Más»). Después, Codex vuelve a aceptar solo la pieza.

La siguiente decisión es la **10.18**.

### 10.18 · Íconos del dominio: estilo B, sólido (22-oct, 17:55)

**Nube entregó los conceptos del encargo 1** (10.14): ocho íconos de muestra en tres estilos, a 16, 20, 24 y 32 px sobre claro y oscuro, más el boceto de la ilustración de inicio. La página es el artefacto «Puente de mando · íconos», privado de Carlos. Nube recomendó B, y Yov revisó la página y el boceto:
- **A, trazo:** el más ligero. A 16 px y al sol, la línea queda en 1.2 px: la descarga parece un monitor y la grúa, un par de letras.
- **B, sólido:** el que mejor se lee a 16 px. Es el más cercano al ícono, que también es de formas llenas (la bahía es el ícono en chico), y es de la familia de los Material que ya usa la app: 186 de sus 224 usos son la variante rellena.
- **C, trazo con pieza maciza:** tiene jerarquía, pero a 16 px el contenedor 40 y la grúa quedan débiles, y los genéricos tendrían que pasar a contorno.

**Carlos elige B.** En el paquete se corrigen cinco íconos:
- la grúa parece una mesa; tiene que leerse como grúa pórtico;
- la re-estiba parece un candado abierto a 16 y 20 px;
- el refrigerado no dice «frío» (hoy la app usa el copo de nieve, `ac_unit`, en 12 lugares);
- la peligrosa queda gris a 16 px;
- la descarga parece «descargar un archivo» y tiene que distinguirse de `baplie_salida`.

**El boceto de inicio se aprueba:** el buque es el ícono ampliado, la grúa pórtico iza el contenedor naranja y su celda queda punteada. Nube lo afina en el paquete, como propuso.

**Además:**
- La carpeta de conceptos no se versiona y la rama del chat de la nube no se sube: ningún agente escribe en git. Nube la entrega en un zip, y Carlos lo guarda fuera del repo, en `C:\Proyectos\`.
- El paquete llega en un zip, como se acordó: Timonel lo integra en una entrega y Codex la acepta, como en T-88. Trae la captura de los tres estilos, para que el repo guarde por qué B.
- Son 31 íconos (10 + 7 + 8 + 6), no los 29 que contó Nube.
- La espera sale del paquete: `BsMarca` ya la anima en código desde la Fase 2 bis.
- En las vistas previas, solo los estados que la app tiene. «En grúa» no existe (10.14).
- El chat de la nube es Nube; Timonel es el agente que integra en el repo.

La siguiente decisión es la **10.19**.

### 10.19 · H1 cerrado · El paquete de íconos, revisado · Cómo se reparten modelos y esfuerzo (22-oct, 21:33)

**Codex volvió a aceptar la corrección de la Fase 2 bis, en `8543cd2`: ACEPTADA con observaciones; H1 queda cerrado** (`docs/rediseno/fase2bis/reaceptacion-codex.md`).
- La celda sale desde su sitio: 0 dp a los 0 ms, −21 dp a los 75 ms y −24 dp a los 150 ms. Con reducción de movimiento se queda quieta, y vuelve a «bajado» sin animación de regreso.
- La prueba nueva falla con la celda de `36f5784` y pasa con la de ahora. Las dos pruebas reescritas conservan sus contratos.
- En un plano de 960 celdas no hay controladores activos en reposo, y todos se liberan.
- Suite 1224/1224 sin omitidas; `analyze` en cero.
- **Observación 1:** el `AnimatedTheme` corre 200 ms de más cada vez que se reconstruye la raíz. Carlos decide corregirlo: Timonel lo hace al cerrar la entrega 2, en un bloque aparte.
- **Observación 2:** el `BadgeThemeData` global usa grúa (`bs_tema.dart`) y el contador de «Acciones» lo hereda (`loading_plan_controls.dart`). Va contra 13.3, punto 6: los contadores van en aviso, o en error si alguna alerta es crítica. Se corrige dentro de la entrega 2.

**El límite de Fable.** A las 20:40 se acabaron el límite semanal de Fable y los créditos. Carlos amplió el plan y los límites volvieron a cero. Desde ahora:
- Timonel: Fable 5.1 en Ultracode para construir la entrega 2; las correcciones, la integración del paquete y los documentos, en Max.
- Nube: Fable 5.1 en Extra o Max.
- Codex: GPT-6 Astra en xhigh para aceptar la entrega 2; GPT-6.1 Sol en high para lo demás.
- Yov: Opus 5.5.
- Al cerrar la entrega 2, Timonel pasa a un chat nuevo con su traspaso. Si la barra semanal de Fable pasa de 75 % antes del lunes, todo baja a Max; si llega a 90 %, Timonel pasa a Opus 5.5 en Alto y Nube espera al miércoles.

**Nube entregó el paquete 1, y Yov lo revisó.**
- Trae 31 íconos y 4 insignias en SVG y en `BayStreamIconos.ttf` (U+E000 a U+E022), seis ilustraciones en SVG claro y oscuro y en JSON de trazos, el generador y un LEEME con la tabla de Material que reemplaza cada ícono.
- Yov comprobó los 84 SHA-256; las métricas de la fuente (em 1024, ascendente 1024, descendente 0 y avance 1024, iguales en hhea, typo y win); que los SVG son de un solo color, sin trazos; y que los JSON solo usan M, L, C y Z, con colores por nombre.
- Las cinco correcciones de 10.18 están hechas.
- **Carlos decide que la descarga y la carga digan lo mismo que los botones:** la descarga con la flecha hacia abajo («Baja», «BAJÓ») y la carga hacia arriba («Sube»). Nube las había dibujado desde el buque: la descarga subía porque sale del casco. Nube las vuelve a dibujar con el buque o el muelle en el dibujo, para que no parezcan «descargar un archivo», y corrige en el LEEME la fecha (22-oct) y la decisión (10.18).
- **Carlos autoriza tocar `pubspec.yaml` solo para declarar la familia `BayStreamIconos`.** No hay dependencias nuevas, y `pubspec.lock` no cambia.
- La integración la hace Timonel después de la entrega 2, con el paquete corregido, y la acepta Codex.

La siguiente decisión es la **10.20**.

### 10.20 · La entrega 2 de la Fase 3, entregada · Lo que decide Carlos (23-oct, 00:23)

**Timonel entregó la entrega 2 de la Fase 3** (`d1ce1db`) y, aparte, el tema en caché (`f62f709`), en ≈ 9.5 h.
- Es el plano por bahía en la dirección C en los tres clientes: navegación adaptable, la silueta como selector, las tarjetas con la operación real, las celdas del ícono con «Colorear por», el detalle en una sola hoja, «En vivo», la banda del muelle con Descarga y Carga, la barra de la operación y el naranja de 1.5 s con datos reales.
- Antes de cerrar corrigió lo que mostraron las capturas: el título de la bahía, que se cortaba a 360 dp, y la rejilla bajo el pliegue a 360 × 640. Con menos de 560 dp de alto útil, la cabecera se va al desplazar (DESIGN.md 13.8).
- Suite 1242 (piso 1224), `analyze` en cero, censos con 1931 textos visibles y 0 en inglés, M3 251/7/3 y la auditoría igual.
- RNF-002 en tres pasos: Windows 1.84–2.19 s; la Web 0.30–0.48 s, y 1.28–1.60 s en la primera visita; el emulador 3.06–3.88 s. La RAM del plano no cambió (≈ 156 MB); la Lista se queda en ≈ 510 MB (RNF-001/007, pendiente).
- El tema en caché cierra la observación 1 de 10.19: se construye una vez por densidad, y un rebuild idéntico ya no anima.

**Yov revisó los commits:**
- `d1ce1db` trae 53 archivos, y ninguno de `domain/`, `data/`, `lib/main.dart`, `pubspec.*` ni los congelados.
- **Faltaban 216 archivos de evidencia del bloque de Timonel:** 147 png, 35 jpg, 28 json, 4 csv y 2 md, con las capturas de los tres clientes, la RAM y RNF-002. Están completos en disco y suben en un commit aparte, por carpeta: cada carpeta tiene exactamente los archivos del bloque, ni uno más.
- En los cuadros de RNF-002 en Android, el selector de archivos aparece a medias y no se lee el nombre de ningún archivo del corpus. Codex los revisa todos.

**Carlos decide:**
- Se retiran la barra de ocho acciones y su plegado (T-91), como pide DESIGN.md 8. Buscar va arriba; Nube y Parámetros, al pie del riel o en «Más»; lo demás, en «Más». Lo que pidió la prueba de campo del 5-oct queda cubierto: en el teléfono, las acciones ya no van junto al título. La preferencia de T-91 queda sin lector. Retirarla toca `domain/` y `data/`, así que va como tarea de limpieza después del rediseño.
- El chip del zoom sale de la rejilla, porque a 360 dp con letra 1.45 y 2.0 tapaba la última columna. Se corrige después de la aceptación, junto con lo que encuentre Codex.
- Se quedan como están: «re-estibas» partida con letra 2.0, «Estad.» en la barra inferior y «BUQUE MAN…» con elipsis en la banda del muelle (DESIGN.md 10).
- La leyenda en el panel lateral a 1920 y Atrás en Android quedan para la siguiente entrega.

Codex acepta la entrega 2 con GPT-6 Astra en xhigh. Después, en un chat nuevo de Timonel, van la corrección y la integración del paquete de íconos (10.19).

La siguiente decisión es la **10.21**.

### 10.21 · La entrega 2 no pasa: cuatro hallazgos · Timonel corrige en un chat nuevo (23-oct, 06:30)

**Codex revisó la copia limpia en `9522794`, contra `ccc8c2f`: NO PASA** (`docs/rediseno/fase3/entrega2/aceptacion-codex.md`).
- **H1 · Buscar queda fuera de la pantalla a 600 dp con letra 2.0.** La cabecera de la oficina pone en una sola fila el título, el estado, Descarga/Carga, Buscar y Nube. A 600 × 960 con letra 2.0, Buscar queda entre 624.9 y 672.9 dp y la fila se desborda 137 px; con 1.45, 31 px. No hay otra entrada a Buscar en «Más» (`_CabeceraDeOficina`, en `vessel_overview_page.dart`).
- **H2 · Una carga real no enciende su celda en naranja.** El proveedor registra el contenedor como recién movido, pero `LoadingCell` no recibe ese estado (`bay_plan_view.dart` y `loading_controls.dart`). La prueba entregada inyecta el proveedor y pasa por otra ruta, así que no detecta el fallo.
- **H3 · A 360 y 600 dp falta el anuncio accesible del movimiento.** La región en vivo solo existe dentro del panel lateral, que aparece desde 1200 dp.
- **H4 · En Android, RNF-002 termina antes de que se vea la rejilla.** Los cinco cuadros finales muestran el previo, los avisos, los controles, la silueta y la leyenda, pero ninguna celda. Las cotas están bien calculadas, pero no miden el hito, y tener que desplazar contaría como un paso más.
- **Pasa lo demás:**
  - 1242/1242 sin omitidas, y `analyze` en cero;
  - el tema en caché;
  - Windows, repetido en 1.929 s y 3 pasos;
  - la Web sin conexión (T-92);
  - las cuatro pruebas del almacén de T-91, idénticas;
  - las 182 imágenes, sin datos personales ni corpus;
  - la RAM y los censos coinciden.
- **Observación:** la auditoría trae un aviso nuevo de `IntrinsicHeight`, en el riel corto de las ventanas bajas. No hay críticos nuevos.

**Yov acepta el dictamen.** Los cuatro hallazgos son reales. Además, H4 muestra que en un teléfono de 360 × 640 el plano no se ve al abrirlo, y eso importa en el muelle. Timonel corrige en un chat nuevo, en Max:
- H1: la cabecera se reparte o se pliega según el ancho y la letra, y Buscar queda siempre al alcance. Se prueba en 600 dp exactos.
- H2: la celda de carga recibe el movimiento real, también en llenos y reservas asignadas. Una prueba lo sigue desde la bitácora hasta la celda. Se mantienen los 1.5 s, y la celda queda quieta con reducción de movimiento.
- H3: el movimiento se anuncia también sin panel lateral, solo con el rol.
- H4: a 360 × 640 la primera rejilla se ve sin desplazar, dentro de los tres pasos. Se repiten las cinco corridas de Android, con cuadros que muestren celdas.
- El aviso de `IntrinsicHeight` se resuelve sin `IntrinsicHeight`.
- El chip del zoom sale de la rejilla (10.20).

Después, Codex acepta solo la corrección, y Timonel integra el paquete de íconos (10.19) en el mismo chat. Mientras Codex revisa, Timonel avanza solo en la base del paquete (archivos nuevos y la línea de `pubspec.yaml`), sin tocar las pantallas.

La siguiente decisión es la **10.22**.

### 10.22 · La corrección de la entrega 2, aceptada · En Carga a 360 × 640, la primera fila puede quedar a un gesto (23-oct, 08:40)

**Codex volvió a revisar sobre `74802b6`, contra `52dd1b6`** (`docs/rediseno/fase3/entrega2/reaceptacion-codex.md`):
- H1 a H3 están corregidos.
  - Buscar queda al alcance a 360, 600 y 1920 dp, con letra 1.0, 1.45 y 2.0.
  - La carga real enciende su celda en naranja 1.5 s, también en llenos y en reservas con vacío asignado.
  - El movimiento se anuncia a 360 y 600 dp con el rol, y a 1920 no se anuncia dos veces.
- RNF-002 en Android queda acreditado: los cinco cuadros finales muestran celdas, en tres pasos. La primera corrida tras instalar tarda 4.91–4.98 s, y las demás 2.85–3.20 s.
- El riel ya no usa `IntrinsicHeight` y el chip del zoom quedó fuera de la rejilla.
- Suite 1260/1260 sin omitidas, `analyze` en cero y ningún aviso nuevo en la auditoría.
- **Lo único pendiente era de alcance.** 10.21 pedía la primera rejilla sin desplazar a 360 × 640, pero DESIGN.md 13.8 deja Carga «a un gesto»: según Timonel faltan 14 dp. Codex no reprodujo esos 14 dp en sus dos casos de Carga, y pidió acreditar el caso o una decisión de Carlos.
- Anota un cambio de comportamiento: el zoom se conserva al cambiar de bahía y vuelve a empezar al cambiar de viaje.

**Carlos acepta la excepción:** en Carga, en un teléfono de 640 dp de alto, la primera fila puede quedar a un deslizamiento. En el previo (la medición de RNF-002) y en Descarga se ve sin desplazar, y en el Honor (360 × 800) se ve todo. **Con eso queda aceptada la entrega 2 de la Fase 3.**

Timonel sigue en su chat con el paquete de íconos (partes B y C, 10.19), y después Codex lo acepta.

La siguiente decisión es la **10.23**.

### 10.23 · El paquete de íconos no pasa por la búsqueda · La Lista sigue la regla única · Los PNG se verifican por píxeles (23-oct, 11:35)

**Codex aceptó en la copia limpia sobre `ac18025`, contra `77f7d1b`: NO PASA** (`docs/rediseno/fase3/paquete/aceptacion-codex.md`).
- **H1 · En la búsqueda, los íconos pierden su significado accesible.** `_buildLeadingIcon` (`container_search_delegate.dart`) dibuja el ícono sin etiqueta ni descripción emergente. Cuatro contenedores que solo difieren en su condición (peligrosa, refrigerado, fuera de medida y vacío) tienen exactamente la misma etiqueta accesible.
- **O1 · La Lista no aplica la regla única.** `iconos_del_dominio.dart` y DESIGN.md 13.11 dicen que la Lista, la búsqueda y el detalle eligen el ícono con la misma prioridad: peligrosa, refrigerado, fuera de medida, vacío, tipo y tamaño. Pero la tarjeta de la Lista llama directamente a `iconoDeTipo` (`containers_list_view.dart`) y dibuja el del 20′ en los cuatro casos. Los chips de la carga especial sí siguen ahí.
- **Salvedad · `generar.py --verificar` da 80 de 84 en Windows.** La fuente, los SVG, los JSON y los códigos se reproducen byte a byte. Las tres imágenes PNG salen con los mismos píxeles, pero comprimidas de otra forma, y el LEEME cambia solo en las filas de sus huellas. Nube ya lo había advertido para otras versiones de las librerías.
- **Pasa lo demás:**
  - 1290/1290 sin omitidas y `analyze` en cero;
  - el alcance (170 archivos, solo la fuente en `pubspec.yaml`, `pubspec.lock` igual);
  - los 84 SHA-256 del paquete;
  - la regla del alto de las ilustraciones;
  - las insignias y los contrastes;
  - Windows y la Web, con la fuente visible en los dos;
  - T-92 sin conexión;
  - las capturas, sin datos personales ni corpus.

**Yov acepta el dictamen y resuelve:**
- H1: cada resultado de la búsqueda dice su condición al lector de pantalla, ya sea en la etiqueta del ícono o en el texto del resultado. Las pruebas leen el árbol de semántica en los cuatro casos.
- O1: la Lista aplica la regla única (`iconoDeContenedor`), como prometen el código y DESIGN.md 13.11, con una prueba de que Lista, búsqueda y detalle dibujan el mismo glifo.
- La salvedad del verificador no bloquea. Para los PNG del paquete vale la igualdad de píxeles, que Codex ya comprobó; los demás archivos se siguen verificando byte a byte.

Timonel corrige H1 y O1 en su chat, en Max, con un bloque aparte, y Codex vuelve a aceptar solo esa pieza.

La siguiente decisión es la **10.24**.

### 10.24 · La travesía del inicio: un buque cruza debajo de los dos bloques (23-oct, 11:40)

**Carlos pide** que en el espacio libre debajo de los dos bloques del inicio («Abre un plano de estiba» y «Recientes») haya una animación: un buque que navega de izquierda a derecha, se desvanece al llegar a la derecha y vuelve a aparecer por la izquierda.

**Yov la define** con lo que ya se tomó de las referencias (10.14): la ilustración de línea, el azul profundo y la silueta del buque como pieza central. Usa el vocabulario del paquete de Nube (10.19), sin dibujo nuevo:
- **Qué se ve:** el mar como en las ilustraciones (el agua y la línea de flotación de `sin_conexion`) y el buque de perfil de esa misma ilustración: casco, cinco contenedores, caseta y puente, sin la nube. Nada es naranja, porque el naranja es solo para lo que se acaba de mover.
- **La proa mira a la derecha**, porque el buque navega hacia allá. Es la única excepción a «proa a la izquierda», que sigue valiendo para todo lo que está quieto.
- **Dónde:** una banda a lo ancho, al pie del inicio, solo en el espacio que sobra debajo de los dos bloques. No empuja ni tapa nada. Si sobran menos de 120 dp, no se pinta (13.11, regla 4).
- **Cómo se mueve**, solo con `Transform` y opacidad:
  - El buque cruza a velocidad constante, en 14 a 40 s según el ancho.
  - Aparece en el primer 10 % del recorrido y se desvanece en el último 12 %. Después quedan 3 s de mar vacío.
  - Sube y baja 1.5 dp cada 3.2 s, y cabecea 0.8° cada 4.4 s. Detrás deja una estela corta.
  - Dos líneas de ola corren hacia la izquierda, a distinta velocidad.
- **Con reducción de movimiento**, el buque queda quieto a un tercio del ancho y las olas no corren.
- **Se detiene** cuando el inicio no se ve: cuando hay otra pantalla encima o la app está en segundo plano.
- **Es decorativa:** no tiene semántica, no recibe el foco y no responde al toque.

La hace Timonel en su chat, en Max, como parte D y en un bloque aparte, después de la corrección del paquete (10.23). Después la acepta Codex.

La siguiente decisión es la **10.25**.

### 10.25 · El paquete de íconos, aceptado (23-oct, 13:01)

**Codex revisó la corrección del paquete sobre `05dde52` y la aceptó** (`docs/rediseno/fase3/paquete/reaceptacion-codex.md`).
- **H1:** cada resultado de la búsqueda dice su condición, una sola vez, desde el árbol de semántica.
- **O1:** la Lista, la búsqueda y el detalle dibujan el mismo glifo y dicen el mismo nombre. La regla única es `CondicionDelContenedor`.
- **La insignia de la celda del plano:** Timonel encontró que la etiqueta de la celda no la decía, y Carlos pidió corregirlo dentro de la misma corrección. Ahora la celda dice su condición en las tres vistas de «Colorear por». «Vacío» se lee en las tres vistas, porque es lo que el contenedor es, y no solo un color.
- Suite 1297/1297 sin omitidas y `analyze` en cero.

**Con esto queda cerrado el paquete de íconos e ilustraciones (10.18, 10.19 y 10.23).** Timonel sigue con la travesía del inicio (10.24).

La siguiente decisión es la **10.26**.

### 10.26 · La travesía no pasa: el cruce mueve el layout y RNF-002 en Windows no quedó acreditado (23-oct, 14:00)

**Codex revisó la travesía sobre `f27de53`: NO PASA** (`docs/rediseno/fase3/travesia/aceptacion-codex.md`).
- **H1 · El cruce y el vaivén cambian `Positioned.left` y `top` en cada cuadro** (`bs_travesia.dart`). Solo el cabeceo y las olas usan `Transform`. Eso contradice «solo `Transform` y opacidad» (10.24 y DESIGN.md 13.11, regla 7). En un segundo, `left` avanzó 48 dp.
- **H2 · RNF-002 en Windows no quedó acreditado.** El detector de `tool/t114_primera_windows.py` busca primero el azul `#0D47A1`, y ese azul ya está en la ilustración del inicio, incluso de noche. Por eso pulsó el muelle del dibujo y no «Seleccionar archivo», y terminó con «Más de 120 s sin rejilla». Con el detector limitado al azul del botón, el clic acertó, pero la corrida volvió a quedarse sin el paso 3, por una causa que no se demostró. Codex no se lo atribuye a la animación: el problema del detector puede venir desde el paquete de íconos.
- **O1 · El conductor de T-99 espera a que el inicio se quede quieto.** `_asentar` (`tool/t99_conductor.dart`) espera mientras haya cuadros programados, hasta 20 s, y después sigue sin avisar. Con la travesía, el inicio nunca se queda quieto. Los scripts de capturas de Windows heredan esa espera.
- **Pasa lo demás:**
  - 1311/1311 sin omitidas y `analyze` en cero;
  - la pintura compartida no altera las seis ilustraciones;
  - el dibujo y los tiempos que pide 10.24;
  - la reducción de movimiento;
  - la travesía se detiene al abrir un plano y vuelve al regresar;
  - no tapa ni empuja nada;
  - los censos.
- **Rendimiento, medido en clientes reales durante 60 s:**
  - Windows: build p99 0.55 ms y raster p99 2.18 ms;
  - la Web: build p99 1.0 ms;
  - el buque no se repintó en todo ese tiempo.

**Yov acepta el dictamen.** Timonel corrige en su chat, en Max, en un bloque aparte:
- H1: el cruce y el vaivén van con `Transform.translate` sobre una caja fija. El buque sigue pintándose una sola vez, y su layout no cambia en cada cuadro.
- H2: los detectores de los instrumentos validan que lo que pulsan es el botón, y no un color que también aparece en un dibujo. Hay que encontrar la causa del segundo bloqueo y repetir RNF-002 en Windows con los tres pasos y la captura de la rejilla. Hay que revisar también los instrumentos de la Web y Android, por si tienen el mismo supuesto, y repetir lo que cambie.
- O1: los instrumentos que necesitan reposo piden reducción de movimiento, o esperan un estado concreto con un tiempo límite que avisa al vencer. Los que miden la animación usan una ventana de cuadros acotada.

Después, Codex vuelve a aceptar solo la corrección.

La siguiente decisión es la **10.27**.

### 10.27 · La travesía del inicio, aceptada (23-oct, 15:05)

**Codex volvió a revisar la corrección sobre `53838d7`: ACEPTADA con observaciones** (`docs/rediseno/fase3/travesia/reaceptacion-codex.md`).
- **H1:** la caja del buque quedó fija durante 3305 cuadros y el buque se pintó una sola vez. El cruce, el vaivén y el cabeceo van en el `Transform`.
- **H2:** el detector de Windows reconoce el botón por el tema, la forma y el rótulo, y ya no pulsa el muelle del dibujo. Timonel encontró la causa del bloqueo: el cursor de la repetición anterior quedaba sobre el botón, que aparecía apagado por el hover. RNF-002 en Windows está acreditado. Las cinco corridas de Timonel dieron entre 1.84 y 1.89 s, y las tres de Codex 1.979, 1.907 y 1.861 s, todas en tres pasos y sin reintentos.
- **O1:** el conductor de T-99 pide reducción de movimiento por omisión y avisa cuando vence la espera.
- Suite 1312/1312 sin omitidas y `analyze` en cero.
- **Observación:** el instrumento sigue contando tres pasos aunque haya reintentos. **Desde ahora, una corrida con reintentos no vale y se repite.** En la siguiente entrega de Timonel, el instrumento la marca él mismo como no válida.

**Con esto queda cerrada la travesía del inicio (10.24 y 10.26).**

La siguiente decisión es la **10.28**.

### 10.28 · La prueba piloto con COMAR va con el rediseño (23-oct, 15:07)

**Carlos decide que la prueba piloto con COMAR, el 25 o el 26-oct, se haga con la versión rediseñada.** `sprint-4` contiene todo `sprint-3` (la v3.0 desplegada) más el rediseño, y `origin/master` está en `063d2ae`, así que el paso a `master` es un avance directo.

Qué está aceptado:
- el inicio y la primera visualización (entrega 1);
- el plano por bahía, con la banda del muelle, la barra de la operación, «En vivo» y la navegación adaptable (entrega 2);
- el paquete de íconos e ilustraciones;
- la travesía.

Las demás pantallas funcionan con el tema nuevo, pero todavía no se rediseñaron.

**El plan hasta el piloto:**
1. **Timonel**, en un chat nuevo y en Max, arma la candidata del piloto. No agrega funciones: recorre el piloto en los tres clientes con datos sintéticos y corrige lo que bloquee o confunda. También hace que Atrás en Android funcione como dice DESIGN.md 8, revisa que las pantallas sin rediseñar no tengan nada roto, propone las versiones de Android, MSIX y la Web según la guía de despliegue del Sprint 3, y escribe la lista de comprobación del piloto.
2. **Codex** acepta la candidata.
3. **Carlos** pasa `sprint-4` a `master`, publica Android (prueba interna de Play), el MSIX de Windows y la Web, y hace un ensayo con el Honor y la laptop contra Firebase de verdad, con la lista de comprobación.
4. Si el ensayo falla en algo serio, el piloto se hace con la v3.0, que sigue instalada y probada.

La siguiente decisión es la **10.29**.

### 10.29 · La candidata del piloto no pasa: Atrás con avisos en cola y avisos que tapan el muelle (23-oct, 17:19)

**Codex revisó la candidata en `e78035d`, contra `25b8cf7`: NO PASA** (`docs/rediseno/fase3/candidata/aceptacion-codex.md`).
- **H1 · Atrás usa la cola de avisos como reloj** (`navegacion_del_viaje.dart`). El primer toque guarda el aviso de «toca otra vez para salir», aunque esté formado detrás de otro, y la ventana de 2 s depende de cuándo cierra ese aviso, no del tiempo desde el toque. La prueba: con un aviso de movimiento de 6 s en pantalla, Atrás, 3 s de espera y Atrás otra vez. En modo de prueba, Flutter falla (`_snackBars.first == controller`), dos veces de dos. En Release, por lo que dice el SDK, esa rama puede sacar del viaje con dos toques separados por más de 2 s y ocultar el aviso de movimiento con su «Deshacer».
- **H2 · Los avisos tapan los controles del muelle.**
  - El de 6 s tapa «Acciones», «OR / últimos dígitos» y el pie de la hoja de vacíos. Sale con cada registro, así que obliga a esperar antes del siguiente contenedor.
  - El de 4 s tapa «Confirmar e importar».
  - El conductor de Windows esperaba a que se fueran, por eso el recorrido automático no lo mostró.
- **Observación de la lista del piloto:** el regreso de la Web a la v3.0 (4.5) no llevaba `--project baystream-app`.
- **También:** el informe de Timonel cuenta 57 capturas de pantallas sin rediseñar, pero hay 54. Tres muestran el indicador de carga y una es de antes de corregir el contraste.
- **Pasa lo demás:**
  - 1329/1329 y `analyze` en cero;
  - el alcance de 158 archivos;
  - el núcleo del recorrido, repetido en Windows y en la Web;
  - el BAPLIE de salida, releído con 58 contenedores;
  - la Web de producción 3.1.0 (4), con Auth, T-92 y uso sin red;
  - la mezcla corregida de 4.1;
  - los censos y la auditoría, sin nada nuevo.

**Yov acepta el dictamen:**
- Corrige 4.5 en `docs/piloto/LISTA-PILOTO.md`: la Web vuelve con el bloque completo de 4.4, con la versión 3.0.0 (3), y con `--project baystream-app`.
- Timonel corrige esta noche, en su chat y en Max:
  - H1: la ventana de 2 s se cuenta desde el primer toque. El aviso de salir se ve aunque haya otro, y nunca se cierra un aviso que no sea el primero de la cola.
  - H2: los avisos salen fuera de la franja de operación y del pie de las hojas, y «Deshacer» sigue a mano durante su plazo.
  - Con pruebas de los casos combinados, y con el informe y las capturas al día.
- Después, Codex vuelve a aceptar el muelle, y el sábado se publica (10.28).

La siguiente decisión es la **10.30**.

### 10.30 · La corrección de la candidata, entregada; el aviso tapa las cifras de la franja y la advertencia de Atrás va arriba (23-oct, 18:52)

**Timonel corrigió H1 y H2 en un chat nuevo, en Extra** (el de la candidata llegó al 94 % del contexto; Extra cuida la semana de Fable). Lo cuenta la sección «Fase 3 · Candidata del piloto · Corrección tras la aceptación de Codex» de `docs/REDISENO-RESULTADOS.md`.
- **H1:** la ventana de Atrás es un `Timer` de 2 s desde el primer toque. La advertencia es una tarjeta propia, arriba y fuera de la cola de avisos: se ve con el aviso de movimiento delante, no cierra ningún aviso ajeno y «Deshacer» sigue. Hay cuatro pruebas nuevas con avisos de 4 y 6 s en cola, entre ellas el caso de Codex.
- **H2:** los avisos de la página del viaje flotan por encima de la fila de controles de la franja, sobre sus cifras, y nunca sobre la rejilla. La fila mide su alto y la página lo pone en el tema de `SnackBar`. En el listado de la agencia, «Descartar» y «Confirmar e importar» van al pie fijo. Hay cinco pruebas nuevas, con las fuentes reales.
- **El primer anclaje no sirvió.** Con el aviso sobre la franja entera, en el teléfono bajo tapaba la única fila de celdas y la segunda «Baja» cayó sobre «Deshacer». El emulador lo mostró y Timonel lo cambió; las capturas quedan en `correccion/emulador-intento-1/`.
- **Capturas:** las 54 se rehicieron y cambian cinco. Ninguna trae el indicador de carga, y el contraste da 55 de 57 (los dos falsos positivos de 9.5). Las 57 configuraciones incluyen las tres de «Nube y cuenta», que no se capturan.
- **Cifras:** suite 1338 (piso 1329), sin omitidas, y `analyze` en cero. El muelle se repitió en el emulador: 27 pasos sin fallos, en el cuarto intento (el primero se detuvo por el anclaje y dos por el instrumento; están anotados).
- **Yov revisó el bloque contra el disco:** 16 archivos cambiados y 43 nuevos, todos en el bloque. Nada en `domain/`, `data/`, `lib/main.dart`, los congelados, `pubspec.*` ni la lista del piloto.

**Carlos decide:**
- **Para el piloto, el aviso tapa las cifras de la franja durante su plazo** (4 o 6 s). Las celdas y los controles quedan libres, y el aviso dice qué pasó. No se reserva sitio fijo: le quitaría 56 dp a la rejilla en el teléfono bajo. Se revisa con lo que diga COMAR.
- **La advertencia de Atrás va arriba**, sobre la cabecera, porque abajo están la franja y los avisos.

**Lo que sigue:** Codex vuelve a aceptar solo esta corrección: H1; H2 en el teléfono bajo con la letra a 1.0, 1.45 y 2.0; los avisos de la oficina en Windows sin los `_sinAvisos()` del conductor; y las capturas. Si pasa, el sábado se publica (10.28).

La siguiente decisión es la **10.31**.

### 10.31 · La reaceptación no pasa: con la letra a 2.0 el aviso pisa tres celdas; Timonel corrige con Claude Opus 5.5 (23-oct, 20:14)

**Codex volvió a aceptar solo la corrección, en `9015662`: NO PASA** (`docs/rediseno/fase3/candidata/reaceptacion-codex.md`).
- **H2 sigue abierto con la letra a 2.0.** En el teléfono bajo (360 × 640), el aviso de 6 s con «Deshacer» mide 328 × 196 dp y va de y=296 a y=492. Las celdas del nivel 88 se ven hasta y=300, así que el aviso pisa 4 dp de tres celdas, en Descarga y en Carga. Con la letra a 1.0 y a 1.45 las celdas quedan libres. La fila de controles (y=500 a 548) queda libre y «Deshacer» responde en las seis configuraciones.
- La 10.30 deja tapar las cifras de la franja, no las celdas. Codex no extiende esa autorización a la rejilla.
- Las cinco pruebas de Timonel pasan, pero tienen una sola fila de celdas, que no llega a la zona del aviso. La de Codex usa planes sintéticos de 24 contenedores en seis niveles, desplaza el plano 350 dp y carga las fuentes reales: pasan 4 configuraciones y fallan 2.
- La medida vieja no deja un aviso visible mal puesto: el primer cuadro es invisible y desde el segundo vale la medida nueva.
- **H1 queda cerrado:** el reloj de 2 s, la advertencia arriba y los avisos en cola. Pasan las 13 + 5 pruebas y la reproducción anterior.
- **Tres observaciones P3, que no bloquean:**
  - **O1:** tras el primer Atrás, si se abre el zoom o el detalle de una celda y Atrás lo cierra, otro toque dentro de los mismos 2 s sale del viaje.
  - **O2:** el instrumento de Android ya no comprueba en positivo el plano ni la advertencia tras el primer Atrás. Lo suplen las capturas p23 y p24 y las pruebas de widget.
  - **O3:** en la oficina, el aviso cruza el espacio vacío del riel y filas del panel En vivo. No tapa la leyenda, celdas ni controles.
- **Codex rectifica la 10.29:** la hoja de vacíos va por encima del aviso y su «Cerrar» queda libre.
- **Pasa lo demás:** suite 1338 y `analyze` en cero; 27 pasos en el emulador; Windows a 1920 con 26 capturas y una auxiliar, sin los dos primeros `_sinAvisos()`; 54 capturas, cinco cambiadas y 49 idénticas. La Web queda para el ensayo del sábado.

**Yov acepta el dictamen.** **Carlos decide** que el siguiente Timonel trabaje en un chat nuevo con Claude Opus 5.5, porque Fable tarda más de una hora por encargo.

**Timonel corrige esta noche:**
- **H2:** ningún aviso pisa celdas ni controles en el teléfono, con la letra a 1.0, 1.45 y 2.0, en Descarga y en Carga, con varios niveles y el plano desplazado. Tiene que cumplirse por construcción, no con unos dp de margen que pasen justo con estas cifras. Las cifras de la franja se pueden tapar (10.30), el texto no se corta y «Deshacer» responde.
- La prueba de Codex entra en la suite, a 360 × 640 y a 412 × 915.
- **O1 y O2, si caben sin crecer:** Atrás que cierra otra cosa reinicia la ventana, y el instrumento vuelve a comprobar en positivo el plano y la advertencia.
- **O3 queda para COMAR.**
- Si la única salida cambia lo decidido en la 10.30 (reservar sitio, llevar el aviso arriba o bajar la letra del aviso), Timonel para y trae opciones.

**Lo que sigue:** Codex acepta solo esta segunda corrección: H2 con las tres letras y los dos teléfonos, O1 y O2 si entraron, la suite y `analyze`. Si pasa, el sábado se publica (10.28).

La siguiente decisión es la **10.32**.

### 10.32 · La segunda corrección, entregada: el aviso elige qué decir y no pasa del borde de arriba de la franja (23-oct, 21:36)

**Timonel corrigió en un chat nuevo, con Claude Opus 5.5 en Extra, en ≈ 1.3 h** (sección «Fase 3 · Candidata del piloto · Segunda corrección (letra 2.0)» de `docs/REDISENO-RESULTADOS.md`, 11.1 a 11.9).
- **La falla era mayor que la que midió Codex.** Con la regla de la 10.29, a 412 × 915 y en el Honor (360 × 800) el aviso ya pisaba celdas con la letra a 1.45. El aviso de T-61 (10 s) subía sobre la rejilla con cualquier letra. Con la letra a 2.0, las cifras dejan 117 dp a 412 × 915, y el aviso de una Baja no cabe ahí con ningún relleno.
- **H2, la regla nueva:**
  - la página mide la barra entera, además de su fila de controles, y le dice al aviso cuánto alto tiene;
  - todos los avisos de la página se hacen con `avisoDelViaje`: compactos, con «Deshacer» al lado y dos textos, el entero y uno corto que sigue diciendo qué pasó («Descargado · MNLU0000107»);
  - se muestra el primero que cabe; los errores y los avisos largos dicen lo esencial y llevan «Ver», que abre el texto entero;
  - si ni el corto cabe (letra mayor que 2.0 o menos de 360 dp, fuera de lo probado), se recorta a su lugar: el tope no se pasa nunca;
  - una prueba-guarda falla si aparece un `SnackBar(` hecho a mano en los cuatro archivos de la página.
- **La 10.30 queda intacta:** letra del sistema, sin sitio reservado y el aviso abajo.
- **O1:** abrir o cerrar otra cosa en medio (el zoom, el detalle, una hoja, un diálogo) cancela la ventana de Atrás. Dos toques seguidos en la raíz siguen saliendo.
- **O2:** tras cada Atrás, el instrumento exige en un mismo volcado, dentro de los 2 s, la advertencia, el plano y «Deshacer».
- **Cifras:** suite 1359 (piso 1338), sin omitidas ni reintentos, y `analyze` en cero. La matriz de 12 casos pasa con el aviso como lo hace la página. La prueba de Codex tal cual sigue fallando, porque pone un `SnackBar` hecho a mano.
- **Emulador:**
  - con la letra a 1.0, 27 pasos sin fallos, en el cuarto intento; los tres primeros los paró O2, porque un volcado de uiautomator tarda 3 s justo después de una Baja;
  - con la letra a 2.0, el instrumento se detiene en el paso 4 («No lo tengo», en «Parámetros del buque», no llega entero a la vista), así que no hay capturas del aviso a 2.0 en el emulador.
- **Queda anotado:**
  - a 360 dp con letra grande, el número del contenedor parte en dos líneas;
  - un aviso de otra página que sigue en pantalla al volver al plano no sabe su lugar;
  - el plano sin operación sigue sin tope arriba;
  - O3 sigue para COMAR.
- **Yov revisó el bloque contra el disco:** 12 archivos cambiados y 59 nuevos, 71 en total, todos en el bloque. Nada en `domain/`, `data/`, `lib/main.dart`, los congelados, `pubspec.*` ni la lista del piloto.

**Yov acepta el enfoque.** Los textos cortos y «Ver» caben en la 10.30: el aviso sigue diciendo qué pasó, y el porqué está a un toque.

**Lo que sigue:** Codex acepta solo esta segunda corrección:
- H2 a 360 × 640, 360 × 800 (el Honor) y 412 × 915, con la letra a 1.0, 1.45 y 2.0, en Descarga y en Carga, con los avisos de verdad;
- los anotados: el plano sin operación, los avisos de otras páginas y «No lo tengo» con la letra a 2.0;
- O1, O2 y el muelle en el emulador;
- la suite y `analyze`.

Si pasa, el sábado se publica (10.28).

La siguiente decisión es la **10.33**.

### 10.33 · La segunda reaceptación no pasa por los avisos hechos a mano; Yov los corrige (23-oct, 22:37)

**Codex volvió a aceptar `6b9d80e`: NO PASA** (`docs/rediseno/fase3/candidata/reaceptacion2-codex.md`).
- **Pasa lo que corrigió Timonel:** la matriz de 18 casos (360 × 640, 360 × 800 y 412 × 915; letra 1.0, 1.45 y 2.0; Descarga y Carga), los registros de verdad a 2.0, «Ver» y «Cerrar», O1 con un diálogo en medio, la suite 1359, `analyze` en cero, el emulador en 27 pasos y la oficina con el aviso compacto.
- **H2-A · P2:** quedaban nueve avisos hechos a mano en ocho archivos, fuera de la guarda de cuatro. A 360 × 640 con la letra a 2.0, el error de Comparar (que se llama desde el plano) y el de Parámetros (al volver) iban de y=128 a y=492 y tapaban nueve celdas.
- **H2-B · P2:** el registro de una tapa, al volver de «Tapas en la operación», pisaba 8 dp del resumen de encima de la barra.
- **Observaciones P3:**
  - T-61 en el plano sin operación tapa 18 celdas durante 10 s, una vez al reabrir;
  - O2 aceptaba un volcado fuera de plazo (prueba con el reloj simulado);
  - «No lo tengo» sí se alcanza a mano con la letra a 2.0: es del instrumento.

**Carlos pide que Yov lo corrija.** Yov lo hizo en su espacio, sobre `6b9d80e` y con el mismo Flutter 3.38.9, y dejó los archivos en la carpeta del rediseño. Git, como siempre, lo hace Carlos. El detalle está en la sección «Fase 3 · Candidata del piloto · Tercera corrección (Yov)» de `docs/REDISENO-RESULTADOS.md` (12.1 a 12.6).
- **Los nueve avisos pasan por `avisoDelViaje`**, con su texto corto: Comparar, Parámetros, Tapas en la operación, Perfiles, BAPLIE de salida, Listado de la agencia, Tapas de escotilla y Viajes recientes (dos). En su página dicen el texto entero; sobre el plano, el que cabe. Los textos, las duraciones y el «Deshacer» no cambian.
- **La guarda revisa todo `lib/`:** falla si aparece un `SnackBar(` hecho a mano fuera de la fábrica.
- **El aviso con fondo de error se lee:** texto y acción en `onError`, con 4,5:1 o más en los dos temas (la tinta y la marca no llegaban a 3:1).
- **O2:** el plazo manda también cuando el volcado ve los tres textos.
- **Con la propia prueba de Codex**, a 360 × 640 y letra 2.0: Comparar y Parámetros pasan de 128–492 a 392–492, y la tapa de 338–492 a 350–492, con la franja desde y=346. Pasa 4 de 4.
- **Pruebas:**
  - 12 nuevas en `test/t114_candidata_correccion3_test.dart`: las tres rutas en tres teléfonos con la letra a 2.0, el fondo de error en los dos temas y la guarda;
  - `analyze` en cero;
  - la suite completa en Linux da +1359 −7, y `6b9d80e` sin cambios da +1347 −7: las 12 de más son las nuevas, y las 7 que fallan en Linux son las mismas antes y después (dibujo, fuentes y rutas de Windows);
  - en Windows se esperan 1371 (1359 + 12).
- **Sin cambios:** `domain/`, `data/`, `lib/main.dart`, los congelados, `pubspec.*` y la lista del piloto.
- **Queda anotado:** T-61 en el plano sin operación (P3) y O3 para COMAR.

**Lo que sigue:** Carlos corre `analyze` y la suite en Windows y sube el bloque. Codex acepta solo esta tercera corrección. Si pasa, el sábado se publica (10.28).

La siguiente decisión es la **10.34**.

### 10.34 · La tercera reaceptación pasa: la candidata del piloto queda aceptada (23-oct, 23:07)

**Codex volvió a aceptar `cc24766`: PASA** (`docs/rediseno/fase3/candidata/reaceptacion3-codex.md`).
- **H2-A y H2-B, cerrados.** Con su propia prueba, no con la de Yov, las tres rutas pasan a 360 × 640, 360 × 800 y 412 × 915 con la letra a 2.0: Comparar desde el plano, Parámetros al volver y la tapa con «Deshacer», que anota la anulación en la bitácora. Ningún aviso pisa celdas, resumen ni controles, y el texto elegido sale entero. A 360 × 640, con la franja desde y=346, Comparar y Parámetros van de y=392 a 492, y la tapa, de 350 a 492.
- **Los demás avisos:** en todo `lib/` queda un solo `SnackBar(`, el de la fábrica. Los de las otras páginas caben al volver al plano: 36 de 36 medidas (doce textos en tres tamaños). Para dejarlos en pantalla, Codex usó una ruta auxiliar; no provocó cada fallo real, y lo dice.
- **El aviso con fondo de error se lee:** 4,96:1 en el tema claro y 4,79:1 en el oscuro.
- **O2:** con el reloj simulado, el sondeo acepta a 1,2 s y rechaza a 3,1 s. Sigue dependiendo de lo que tarda uiautomator, pero ahora un volcado tardío hace fallar la corrida en vez de pasarla.
- **Cifras:** la suite de Windows da 1371 aprobadas (1359 + 12), ninguna omitida, en una sola corrida, y `analyze` da cero. Las 7 que fallan en Linux pasan en Windows. **El piso sube a 1371.**
- **Emulador:** 27 pasos en una sola corrida, desde `pm clear`, a 360 × 640 y letra 1.0, con `-s emulator-5554` en cada llamada. O2 ve la advertencia y el plano a 1,2 s en los dos pasos de Atrás.
- **Dos tropiezos del arnés, antes de medir:** un generador de Codex paró en una aserción, y una compilación apuntó a un archivo sin `main`. Ninguno llegó a correr la suite ni el recorrido, así que no son reintentos (10.27).
- **Siguen como P3, fuera de esta corrección:** T-61 en el plano sin operación (10 s y 18 celdas, una vez al reabrir) y O3 en la oficina, para COMAR.

**Yov revisó contra el disco:**
- `cc24766` trae los 13 archivos de Yov tal como se entregaron;
- contra `6b9d80e` cambian 15 archivos (806 líneas más y 44 menos), y nada en `domain/`, `data/`, `lib/main.dart`, los congelados, `pubspec.*` ni la lista del piloto;
- la carpeta del rediseño es `cc24766` sin cambios, y la de Codex solo añade su informe: Codex no tocó el producto;
- **`cc24766` no está en GitHub:** `origin/sprint-4` sigue en `6b9d80e`. Se sube antes que nada.

**La candidata del piloto queda aceptada (10.28):** `sprint-4` hasta `cc24766`, con este registro encima.

**La lista del piloto, al día** (`docs/piloto/LISTA-PILOTO.md`):
- 1.5: «Confirmar e importar» va en el pie fijo de la página; ya no hay que esperar a que se apague el aviso;
- 2.3: el aviso de la descarga tapa las cifras de la franja, no las celdas, y con la letra grande dice su texto corto; la carga de paso es 2.5, no 2.4;
- 2.12: la advertencia de Atrás sale arriba y dura 2 s;
- 4.1: la mezcla se cierra con `git commit` y las dos líneas de autoría, como los demás commits;
- 5: la letra grande en los avisos y los dos P3, para no anotarlos como fallos nuevos.

**Lo que sigue, el sábado 24:**
- Carlos sube `cc24766` y el bloque de esta decisión.
- Después de la exposición, publica con la sección 4 de la lista: la mezcla, el MSIX 3.1.0.0, el AAB 3.1.0 (4) y la Web.
- Después, el ensayo, secciones 0 a 2. Si falla en algo serio, el piloto del 25 y el 26 se hace con la v3.0.

La siguiente decisión es la **10.35**.

### 10.35 · La candidata del piloto, publicada en los tres clientes (24-oct, 09:42)

**Carlos publicó la 3.1.0 con la sección 4 de la lista del piloto, de las 09:10 a las 09:40.** Yov revisó su terminal y la carpeta.
- **La mezcla:** `7488321` en `master`, con la etiqueta `v3.1`. Une `sprint-3` (`063d2ae`) y `sprint-4` (`38965b8`), y su contenido es idéntico al de `sprint-4`. El commit salió sin las dos líneas de autoría; no se reescribe, porque ya está publicado con su etiqueta.
- **Windows:** `BayStream_3.1.0.0.msix`, con la firma `Valid` de `CN=BayStream` y SHA-256 `E934097F552EC8166A566289535E40FD1DC821A00078DD9A01C07BD4AED69D95`. El MSIX 3.0.0.0 y su `.sha256` siguen en `build\t93`, para volver (4.5).
- **Android:** el AAB 3.1.0 (4), de 51,1 MB, en la prueba interna de Play. Yov propuso el nombre de la versión («4 (3.1.0) · Candidata del piloto») y las notas en español.
- **Web:** la compilación dice 3.1.0 y 4 en `version.json` y trae Firebase Auth. El verificador T-92 pasó con 57 archivos, los mismos que en la aceptación de Codex, y Hosting subió 56: no sube `.last_build_id`, porque `firebase.json` excluye los archivos ocultos. El aviso de `CupertinoIcons` es el conocido desde el Sprint 3 (T-102 y T-103); la app no usa esos íconos.
- **Las compilaciones no cambiaron ningún archivo del repositorio:** la carpeta queda en `master`, con los documentos de Carlos como estaban.
- **Corrección de la 10.34:** su título llevaba la hora UTC del reloj de Yov. Se escribió el 23-oct a las 23:07; quedan corregidos el título y la nota de 4.1 en la lista del piloto.

**Falta comprobar, al empezar el ensayo (0.1):** `version.json` en una ventana de incógnito, Windows con la 3.1.0.0 instalada y el Honor actualizado por el enlace de la prueba.

**Lo que sigue:**
- hoy a las 14:00, la exposición del curso, con la demo en `C:\Proyectos\baystream-pruebas`;
- el ensayo, secciones 0 a 2 de la lista; si falla en algo serio, el piloto se hace con la v3.0 (4.5);
- el piloto con COMAR, el 25 y el 26 (sección 3 de la lista);
- después de la exposición, `pruebas-curso` se mezcla en `sprint-4`, con la suite y `analyze` (10.12). La prueba de muestra de la clase (`test/muestra/`) está sin versionar en esa carpeta: se decide entonces si entra.

La siguiente decisión es la **10.36**.

### 10.36 · Carlos pide más espacio para el plano en la oficina y unas estadísticas de impacto (24-oct, 10:08)

**Carlos lo pidió hoy a las 09:59 y a las 10:01, viendo la 3.1.0 en Windows.** Son cinco tareas nuevas, para Windows y la Web salvo donde se dice:
- **T-117 · Más plano en la oficina:**
  - la parte de arriba (cabecera, selector, resumen, silueta y cifras) se pliega con un botón y se ajusta arrastrando su borde, y la app recuerda cómo la dejó cada usuario;
  - toda la columna central se desplaza, no solo la rejilla: al bajar, lo de arriba sube y el plano usa la pantalla;
  - «En vivo» se oculta y se muestra con un botón y, además, al pasar el mouse por el borde; lo del mouse se apaga en Parámetros;
  - con cualquier tamaño de ventana (maximizada, a media pantalla o arrastrada) nada se deforma ni se corta. Hoy, a 1920 con «En vivo» abierto, la leyenda de abajo no cabe y se corta a la derecha.
- **T-118 · El selector de modo y su resumen, compactos:** el selector de Carga, Descarga y Contenido se ve plano, también al abrirlo; se rediseña, y las líneas de resumen de debajo ocupan menos. En los tres clientes.
- **T-119 · El mouse y el touchpad:**
  - en la silueta del buque, la rueda del mouse avanza a la derecha y regresa a la izquierda, no solo el touchpad;
  - el touchpad acerca y aleja el plano con dos dedos; la rueda sigue moviendo arriba y abajo;
  - el plano muestra también una barra de desplazamiento horizontal abajo, que se arrastra con el mouse, cuando la bahía no cabe a lo ancho.
- **T-120 · Filtrar por destino en la Lista**, junto a «Filtrar por naviera»: cuántos contenedores van a cada puerto y cuáles son. En los tres clientes.
- **T-121 · Las estadísticas, rediseñadas por completo** con la dirección «Puente de mando» (10.14) y lo que se tomó de sus referencias: las cifras grandes en tarjetas (ShipX), el azul profundo y el anillo de avance (OceanView), la silueta del buque y los códigos de puerto en caja (Shipping Logistics Dashboard). Hoy usan violeta y naranja de adorno, que la dirección prohíbe. En los tres clientes.

**Lo que no cambia:**
- La 3.1.0 publicada es la del piloto (10.35) y no se toca.
- Estas tareas van en `sprint-4`, en la carpeta del rediseño, con las reglas de T-114: solo la capa de presentación, ninguna dependencia nueva, el piso de 1371 y `analyze` en cero, y Codex acepta cada entrega.
- Si guardar las preferencias de T-117 exige tocar `domain/` o `data/`, se propone y decide Carlos.

**Yov propone el orden, y lo confirma Carlos:**
1. Ya: Timonel hace el diagnóstico y la propuesta, sin código y sin correr Flutter, para no estorbar al ensayo ni al piloto. Para con «ALTO: Carlos elige».
2. Desde el 27-oct, después del piloto y con lo que diga COMAR, la implementación: T-117, T-118, T-119, T-120 y T-121.
3. Se publica como 3.2.0 antes de la presentación final (7 o 14-nov).

La siguiente decisión es la **10.37**.

### 10.37 · La fase 0 de T-117 a T-121, entregada y revisada: Carlos responde once preguntas (24-oct, 10:57)

**Timonel entregó el diagnóstico y la propuesta** (`docs/T117-T121-RESULTADOS.md`, Claude Opus 5.5 en Extra), sin código y sin correr Flutter.
- **El diagnóstico, con archivo y línea:**
  - lo de arriba ocupa del 40 al 63 % de la ventana, porque la columna central no se desplaza y la rejilla es lo único que cede. En la laptop de Carlos las tarjetas pasan a dos filas (262 dp contra los 161 de la silueta), aunque el código dice que nunca son más altas que ella;
  - la leyenda se corta porque su `Wrap` vive dentro de un desplazamiento horizontal, que en escritorio no tiene barra;
  - «En vivo» no se desplaza y se corta en ventanas de menos de unos 600 dp de alto;
  - la rueda no mueve nada horizontal, el zoom solo escucha dos dedos sobre la pantalla y no hay barra horizontal;
  - el selector de modo es un `DropdownButton` de Material 2 y está repetido en la cabecera;
  - las estadísticas nunca se rediseñaron: 27 `Colors.*`, texto a 9 dp y girado, y el naranja de la grúa como color del peso.
- **La propuesta:**
  - la columna central se desplaza entera. El puente (la silueta y las cifras) tiene tres alturas, que se eligen arrastrando su borde o con un botón. La franja de la bahía queda fija arriba y una franja de cifras fija abajo, donde viven los avisos como en el muelle: eso cierra O3;
  - el panel lateral se fija, se oculta o sale flotante por el borde;
  - un solo selector de modo, en segmentos o en menú, y el resumen en fichas de una línea;
  - la rueda en la silueta, el pellizco y Ctrl + rueda para el zoom, y una barra horizontal pegada abajo;
  - «Filtrar por destino», con la ficha de cada puerto y cuentas cruzadas con la naviera;
  - dos estadísticas: A, «El buque en corte», la que recomienda, y B, «Tablero de destinos». La rampa de azules está validada por script; la de `DESIGN.md` 5.5 no pasa en su paso claro.
- **Horas:** de 47 a 57, en tres entregas: T-117 con T-118, después T-121 y al final T-119 con T-120.

**Yov la revisó contra el código:**
- seis afirmaciones comprobadas en su archivo y línea: el comentario de las tarjetas, la cartela dentro del desplazamiento horizontal, los 27 `Colors.*`, «Filtrar por Naviera», el `DropdownButton` y el zoom de dos dedos;
- el árbol no cambió fuera del informe. Los cuatro archivos que `git diff --stat` marca (`test/t114_fase3_correccion_test.dart` y tres de `windows/flutter/`) solo difieren en el fin de línea y no entran en ningún bloque;
- **una diferencia con lo que pidió Carlos:** él quería ajustar el alto «a su gusto», y Timonel propone tres alturas (P1). Con la columna que se desplaza, el puente sale de la vista tanto como se quiera; las tres alturas evitan que la silueta y las tarjetas se recorten.

**Las once preguntas (sección 0.12), con lo que recomienda Yov:**
- P1, tres alturas; P2, sí al cambio mínimo en `domain/` y `data/` para guardar las preferencias, con sus pruebas; P3, el usuario del equipo;
- P4, Ctrl + rueda también con el mouse; P5, el panel flotante con el detalle; P6, lo del mouse encendido; P7, `web/index.html` solo si la prueba lo exige;
- P8, las estadísticas A; P9, la cifra protagonista a 48 dp;
- P10, cuentas cruzadas, y la Lista perezosa dentro de la tercera entrega, porque ataca la memoria de la Lista (RNF-001 y RNF-007: hoy sube de 190 a 510 MB, con un umbral de 200);
- P11, depende de la fecha de la presentación final.

**Lo que sigue:** Carlos responde, y la implementación arranca el 27-oct con la entrega 1.

La siguiente decisión es la **10.38**.

### 10.38 · Carlos acepta las recomendaciones de Yov para T-117 a T-121 (24-oct, 10:59)

**Carlos lo decidió a las 10:58:**
- **T-117:**
  - el puente tiene tres alturas (P1);
  - se autoriza el cambio mínimo en `domain/` y `data/` de la sección 0.5.7, con sus pruebas, para guardar las tres preferencias (P2). Es una excepción a la regla de T-114, solo para eso;
  - se guardan por equipo, no por cuenta (P3);
  - con el panel oculto, el detalle sale en el panel flotante (P5);
  - mostrar el panel al pasar el mouse viene encendido y se apaga en Parámetros (P6).
- **T-119:**
  - Ctrl + rueda acerca y aleja también con el mouse (P4);
  - si la prueba demuestra que en la Web el pellizco amplía la página, se autoriza tocar `web/index.html`, solo para el plano (P7).
- **T-121:** las estadísticas A, «El buque en corte» (P8), con la cifra protagonista a 48 dp, escrita antes en `DESIGN.md` (P9).
- **T-120:** cuentas cruzadas entre naviera y destino, y la Lista perezosa dentro de la tercera entrega, medida con T-99 (P10).
- **El orden (P11):**
  - entrega 1, T-117 con T-118; entrega 2, T-121; entrega 3, T-119 con T-120;
  - las entregas 1 y 2 van en la 3.2.0. La 3 entra también si la presentación final es el 14-nov; si es el 7, va en una 3.2.1;
  - falta la fecha de la presentación y saber si hay un segundo monitor para probar el arrastre entre pantallas.

**Lo que sigue:** el 27-oct, después del piloto, Timonel arranca la entrega 1 con Claude Opus 5.5. Codex acepta cada entrega antes de la siguiente.

La siguiente decisión es la **10.39**.

### 10.39 · La entrega 1 de T-117 y T-118 empieza hoy, con pausas (24-oct, 11:04)

**Carlos adelanta el arranque, del 27-oct a hoy.** El tiempo hasta la presentación final es corto (47 a 57 h de las tres entregas). Yov había propuesto el 27 solo para no estorbar la exposición, el ensayo y el piloto; con estas condiciones, no los estorba:
- **Timonel no corre Flutter sin la luz verde de Carlos.** No hay luz verde durante la exposición de hoy y el rato antes, ni durante el ensayo, ni en las horas del piloto del 25 y el 26. Mientras tanto escribe `DESIGN.md` y código; las pruebas esperan.
- **Antes de salir con la laptop**, Carlos pausa el chat de Timonel, para que no corra nada en clase ni en el muelle.
- **Nada se publica hasta después del piloto:** la 3.1.0 es la del piloto (10.35). Si el piloto exige arreglar la 3.1.0, se hace aparte, desde `master` y `v3.1`, no desde `sprint-4`.
- **Si COMAR pide algo que cambie esta entrega**, Carlos se lo dice a Timonel y Timonel ajusta.

La siguiente decisión es la **10.40**.

### 10.40 · La entrega 1 de T-117 y T-118, hecha y revisada; faltan RNF-002 y las capturas (24-oct, 15:00)

**Timonel la entregó a las 12:45, con Claude Opus 5.5 en Extra, en unas 1.6 h** (`docs/T117-T121-RESULTADOS.md`, sección «Entrega 1», y `DESIGN.md` 14).
- **T-117:**
  - la columna central se desplaza entera, y el panel del buque tiene tres alturas, con el borde que se arrastra, doble clic, teclado y lector de pantalla;
  - la franja de la bahía va arriba y la de cifras fija abajo, donde viven los avisos, que no salen de la columna: eso cierra O3;
  - el panel lateral va fijo, oculto o flotante, y «En vivo» ya no se corta;
  - las tres preferencias se guardan en el equipo.
- **T-118:** un solo selector de modo (`BsSelectorDeModo`), en segmentos o en menú según el ancho, y el resumen en fichas de una línea. «Colorear por» usa el mismo selector.
- **Cifras:**
  - suite 1627 (piso 1371, más 256), sin fallidas ni omitidas, en una sola corrida, y `analyze` en cero;
  - la matriz de 0.5.5 son 189 casos y pasa, y los avisos en la oficina, 22;
  - la matriz de 18 casos del teléfono y la guarda de `SnackBar(` siguen pasando.
- **La primera suite dio 78 fallos.** Cuatro eran del producto y se corrigieron en el código: un desborde de 44 dp en el teléfono, dos selectores a la vez a 600 dp, el aire negativo de los avisos en las transiciones y el título repetido sin geometría. Las medidas con las fuentes reales destaparon dos más: la franja de la bahía fijada tapaba la rejilla con la letra a 2.0 en ventanas bajas, y la franja de cifras crecía sin tope. Se reescribieron 15 archivos de pruebas, uno por uno en E1.7; ninguna prueba se borró ni se omitió.
- **Falta:** RNF-002 en Windows, las capturas y la ventana real, que piden compilar y abrir la app (unas 3 a 4 h con Flutter).

**Yov la revisó contra el disco:**
- el bloque de git tiene 44 rutas y coincide una a una con lo cambiado: 32 archivos cambiados, 11 nuevos y el informe. Fuera quedan los cuatro que solo cambian el fin de línea;
- `domain/` y `data/` suman 31 líneas, todas nuevas y solo para las preferencias, como autorizó la 10.38: el `enum UiPreference`, leer y guardar en el repositorio, sus dos `_guard` y la clave `ui.<nombre>` en la caja de ajustes;
- no cambian `lib/main.dart`, los congelados, `pubspec.*` ni la lista del piloto.

**Una decisión para Carlos.** Con el panel fijo, en Carga, la franja de la bahía ocupa dos líneas desde 1536 dp hacia abajo, y a la rejilla le quedan 372 dp a 1536 y 269 a 1366 (la fase 0 estimó 445 y 342). Yov recomienda dejarla en una línea con la letra a 1.0 sin esconder «Colorear por»: las cifras de la bahía bajan a la franja de cifras, que ya empieza por la bahía; si aun así no cabe, «OR / últimos dígitos» queda solo con su ícono y su descripción.

**La presentación final es el 7-nov** (Carlos, a las 11:05). La 3.2.0 lleva las entregas 1 y 2, y la 3 va en una 3.2.1 (10.38). Las metas: la entrega 1 aceptada el 29 o el 30-oct, la 2 hacia el 3-nov y la 3.2.0 publicada a más tardar el 4-nov.

**Lo que sigue:**
- Carlos sube el bloque de la entrega 1 tal como está: es un punto seguro, porque la suite pasa.
- Primero, el ensayo del piloto. Después, luz verde a Timonel para el ajuste de la franja, si Carlos lo aprueba, y para RNF-002, las capturas y la ventana real, con su `SEMÁFORO:`.
- Después, Codex acepta la entrega 1.
- La lista del piloto se actualiza al publicar la 3.2.0, no antes: el piloto es con la 3.1.0.

La siguiente decisión es la **10.41**.

### 10.41 · La entrega 1 de T-117 y T-118, completa y revisada: la franja de la bahía en una línea, RNF-002, las capturas y la ventana real; pasa a Codex (24-oct, 17:15)

**Carlos cambió el orden de 10.40:** Timonel siguió primero, con la luz verde para Flutter, y el ensayo y el piloto van después (lo confirmó a las 15:06). Timonel trabajó de ≈ 14:55 a 16:50, un comando de Flutter a la vez (`docs/T117-T121-RESULTADOS.md`, E1.1 a E1.13):
- **El ajuste de la franja (10.40):**
  - las cifras de la bahía abren ahora la franja de cifras: «Bahía 02: 20 contenedores, 244.7 t, tapas sin declarar; …»;
  - con el panel fijo y la letra a 1.0, la franja de la bahía va en una línea (56 dp) de 960 a 1920 dp, y la rejilla gana 52 dp a 1536 × 793 y a 1366 × 690;
  - si aun así no cabe, «OR / últimos dígitos» queda solo con su ícono y su descripción emergente;
  - en la tableta del muelle operando, que no tiene franja de cifras, las cifras siguen junto al título.
- **Lo que se paga:** a 800 × 600 con la letra a 1.0, la franja de cifras pasa a dos líneas (de 64 a 88 dp) y la rejilla pierde 24 dp. Es el tamaño más chico de la matriz, y nada se corta.
- **Cifras:** suite 1629 (piso 1371, más 258), sin fallidas ni omitidas, en una sola corrida, y `analyze` en cero. La matriz de 0.5.5 comprueba la línea única en seis casos, y hay dos pruebas nuevas.
- **RNF-002 en Windows:** 5 de 5 válidas, tres pasos, mediana 2.26 s (de 2.17 a 2.68 s), con su `SEMÁFORO:` al empezar y al terminar. La última medida era 1.87 s (`REDISENO-RESULTADOS.md` 8.3): la oficina arma más piezas y el diálogo de Windows tarda más. Sigue lejos de los 30 s.
  - El primer intento no contó: la ventana del banco nació detrás de la consola y el detector esperó 120 s. Timonel corrigió el instrumento (`al_frente`, en `tool/t114_primera_windows.py`), y el registro dice ahora si la ventana quedó al frente. La imagen final de ese intento no se guardó, porque mostraba la consola con los proyectos de Carlos.
- **Capturas con datos sintéticos:** 72 de Windows (1920 × 1080 y 1366 × 768, claro y oscuro, letra 1.0 y 2.0), sin textos cortados ni errores de Flutter, y 24 de la Web. El conductor de T-99 se amplió para tomar la Carga, el panel del buque compacto y plegado, y el panel lateral oculto y flotante.
- **La ventana real:** maximizar, Win + ← y →, y el borde a 1000, 700, 560 y 1280 dp: nada se corta. No hay segundo monitor, así que el arrastre entre pantallas queda sin probar.

**Yov la revisó contra el disco:**
- el árbol coincide con el bloque: 10 archivos cambiados y uno nuevo (`tool/t117_capturas_web.py`), más la evidencia: 129 archivos en `docs/t117/entrega1/`, ninguno ignorado;
- el código es chico, unas 130 líneas nuevas en cinco archivos de presentación, y hace lo que dice `DESIGN.md` en 14.7, 14.8 y 14.10. La tarde no toca `domain/`, `data/`, `pubspec.*`, `lib/main.dart`, los congelados ni la lista del piloto;
- la evidencia está limpia. Yov pasó las 119 imágenes por OCR y miró una por una las 23 que toman la pantalla o la ventana: solo se ve el banco con datos sintéticos (BUQUE MANUAL y el sintético de 977). No hay correos, ni «Nube y cuenta», ni nada del corpus;
- **dos cosas para la aceptación:**
  - a 700 dp, sin el panel fijo, la franja de la bahía envuelve y el botón del panel queda solo en la segunda línea (`ventana-real/06-borde-875px.png`). No se corta nada; Codex dice si es un defecto;
  - T-118 es para los tres clientes, y Timonel no abrió Android: lo del teléfono solo está en las pruebas de widgets a 360 dp. Codex lo mira en el emulador.

**Carlos decide (17:12):**
- **La evidencia no va a Git.** Se queda sin versionar en `docs/t117/entrega1/`, en la carpeta del rediseño, y el commit lleva solo los 11 archivos.
- **El mouse movido por script queda aceptado.** Para arrastrar el borde, la tarjeta de permiso del control del escritorio llevaba 33 minutos esperando, y Timonel movió el mouse real con un script (`mouse_event`). Carlos lo da por bueno: cuando la tarjeta no responde, un programador puede mover el mouse con un script, pero solo sobre la ventana del banco.

**Entregables del curso de hoy:** los paquetes de los incrementos 2 y 3 están en `docs/` de `proyecto-baystream`, sin versionar. La presentación del Incremento 3 faltaba, y la hizo Yov: 15 diapositivas con notas, con el diseño de la del Incremento 2.

**Lo que sigue:**
- Carlos sube dos bloques: el de Timonel, con los 11 archivos, y el de esta decisión.
- Codex acepta la entrega 1 en `baystream-qa-r4`, con HEAD separado en el commit de esta decisión, fuera de las horas del ensayo y del piloto. La meta no cambia: la entrega 1 aceptada el 29 o el 30-oct.
- El ensayo y el piloto, con la 3.1.0, siguen las secciones 0 a 3 de la lista del piloto.
- Carlos cree que la exposición del curso de SQA pasa a la próxima semana (14:57). La mezcla de `pruebas-curso` (10.35) espera a que pase.
- Con la entrega 1 aceptada, sigue la entrega 2: T-121, las estadísticas A.

La siguiente decisión es la **10.42**.

### 10.42 · La aceptación de la entrega 1 no pasa por dos P2; Timonel corrige (25-oct, 11:25)

**Codex la cerró hoy a las 11:13, sobre `f60d2a8`** (`docs/t117/entrega1/aceptacion-codex.md`, con su evidencia en `build/t117-entrega1-aceptacion/` de `baystream-qa-r4`):
- **H1 · P2 — «Cerrar el panel lateral» lo fija.** Con el panel oculto y el flotante abierto por una celda, el botón de la cabecera dice «Cerrar el panel lateral», pero fija el panel y guarda `visible`. Lo esperado es cerrar el flotante y dejar el panel oculto. La causa está en `vessel_overview_page.dart` (líneas 364 a 382): desde 1200 dp, el botón siempre ejecuta `mostrarPanel(!panelFijo)`. `DESIGN.md` 14.3 no previó ese caso.
- **H2 · P2 — Atrás no cierra el menú del modo en Android.** En el emulador, con el menú abierto, el primer Atrás deja el menú y muestra «Toca Atrás otra vez para volver al inicio»; el segundo saca del plano. El menú de «Acciones» sí se cierra. La causa: el menú de `BsSelectorDeModo` es un `MenuAnchor` que no se anota en `cerrablesDeAtrasProvider`.
  - En la matriz, Esc tampoco lo cerró, aunque `DESIGN.md` 14.6 lo pide. Por eso fallaron dos casos de 800 × 600 con la letra a 2.0, en Descarga: el menú abierto tapaba «Deshacer».
- **H3 · P3 — a 700 dp, el botón del puente queda solo en una segunda línea:** la franja mide 108 dp en vez de 56. Es la observación de Yov en 10.41.
- **A 800 × 600 se puede trabajar,** desplazando la columna o plegando el puente.
- **Lo demás pasa, con pruebas propias:**
  - la suite, 1629 aprobadas, sin fallidas ni omitidas, en una corrida, y `analyze` en cero en una copia limpia;
  - la matriz de 90 combinaciones;
  - en Windows, las tres preferencias sobreviven al reabrir, y la ventana real pasa (el borde, con el script que autorizó la 10.41);
  - la Web y, en el emulador, Android;
  - RNF-002, 5 de 5 válidas, con mediana de 2.80 s; Timonel midió 2.26 s. Varía con el estado del equipo y sigue lejos de los 30 s.
- **Dos salvedades de Codex, correctas:**
  - `analyze` en `qa-r4` da 33 incidencias, todas bajo `build/`: 32 en pruebas guardadas como evidencia de aceptaciones anteriores y una en su propio instrumento, que corrigió. El producto da cero en la copia limpia, con las mismas fuentes, y ese método vale para la reaceptación;
  - la lista del piloto sí difiere de `cc24766`, por 10.34 y 10.35, de antes de la entrega. La frase del prompt de Yov («no cambian contra la base») era inexacta: la entrega no la tocó.

**Yov lo revisó:**
- el informe coincide con la huella de su manifiesto, y las 224 huellas de la evidencia coinciden;
- el árbol de `qa-r4` está intacto: solo se agregó el informe;
- H1 y H2 están en el código como dice Codex, y sus capturas los muestran: el menú sigue abierto tras el primer Atrás, y el panel queda fijo tras «Cerrar».

**Lo que sigue:**
- Carlos mueve el informe a la carpeta del rediseño y lo sube con esta decisión. Tiene que ser antes de mover `qa-r4` otra vez: si el informe queda ahí sin versionar, el cambio de commit se detiene.
- Timonel corrige H1, H2 (con Esc) y H3 en la corrección 1 de la entrega 1, con una prueba que reproduce cada uno, y pone al día `DESIGN.md` 14.3, 14.6 y 14.8. Corre Flutter solo con la luz verde de Carlos, fuera del ensayo y del piloto (10.39).
- Codex reacepta lo corregido, con la suite y `analyze`, H2 en el emulador y los dos casos de 800 × 600 que fallaron.
- La meta sigue: la entrega 1 aceptada el 29 o el 30-oct.

La siguiente decisión es la **10.43**.

### 10.43 · La corrección 1 de la entrega 1, entregada y revisada: pasa a la reaceptación de Codex (25-oct, 12:25)

**Timonel la entregó a las 12:18, con la luz verde de Carlos para Flutter** (`docs/T117-T121-RESULTADOS.md`, «Corrección 1 de la entrega 1», C1.1 a C1.11):
- **H1:** con el panel oculto y el flotante abierto, el botón de la cabecera solo cierra el flotante, en cualquier ancho. El panel sigue oculto y la preferencia no cambia; para fijarlo está «Fijar».
- **H2:**
  - Esc no cerraba el menú porque el foco no entraba en él. Ahora, al abrirse, el foco pasa a la entrada elegida;
  - el menú se anota en `cerrablesDeAtrasProvider` desde el lado del viaje (`SelectorDelModo` y «Colorear por»): el primer Atrás lo cierra, el plano se queda y ese toque no cuenta como el primero del doble Atrás. `BsSelectorDeModo` sigue sin saber nada del viaje;
  - al cerrarse, el foco ya no vuelve al botón a la fuerza, porque en el emulador el botón quedaba sombreado tras Atrás. Según `DESIGN.md` 14.6, si el menú se abrió con el teclado, el foco vuelve solo.
- **H3:** hay una cuarta variante de una línea, con «Acciones» solo con su ícono. A 700 dp, en Contenido y Descarga, la franja va en una línea (56 dp; antes 108). Cuando envuelve, el botón del puente queda al final de la primera línea.
- **Lo que encontró la medida, ya corregido:**
  - con la letra a 2.0, en Carga, un desborde que ya existía y que la matriz de 0.5.5 no veía: 135 dp a 600 y 35 dp a 700;
  - uno de 0.08 dp de la variante nueva a 960 dp. `BsPrimeraQueCabe` mide ahora con la tolerancia de `RenderFlex` y no con medio dp.
- **Cifras:**
  - suite 1677 (piso 1629, más 48), sin fallidas ni omitidas, en una corrida con el código final, y `analyze` en cero. Antes hubo otra suite completa, también 1677, con la versión que devolvía el foco: no es un reintento, porque el código cambió entre las dos;
  - corridas contra `80ae18b`, 38 de las pruebas fallan antes del arreglo, y después pasan todas. Los dos casos de Codex (800 × 600, letra 2.0, Descarga) pasan;
  - en el emulador, H2 pasa en claro y en oscuro.
- **Queda anotado, fuera de 10.42:** a 700 dp en Carga la franja sigue en dos líneas, con el botón en la primera, y a 600 dp va en dos líneas en los tres modos.

**Yov la revisó contra el disco:**
- el árbol coincide con el bloque: 10 archivos cambiados y 2 nuevos (`test/t117_correccion1_test.dart` y `tool/t117_correccion1_android.py`). No cambian `domain/`, `data/`, `pubspec.*`, `lib/main.dart`, los congelados ni la lista del piloto;
- el código hace lo que dice el informe. El cambio en `test/t114_candidata_atras_test.dart` solo agrega una prueba y pone al día el comentario: ninguna prueba vieja se aflojó;
- el instrumento del emulador no corre con otro aparato que `emulator-5554`;
- las capturas del emulador muestran el menú abierto, el menú cerrado sin advertencia tras el primer Atrás y la advertencia con el segundo;
- **dos cosas para la reaceptación:**
  - el foco con el teclado, en Windows y en la Web: si el menú se abrió con el teclado, tras Esc el foco debe volver al botón del modo;
  - `BsPrimeraQueCabe` cambió de tolerancia, y lo usan la cabecera y la franja de la bahía: la matriz de Codex dice si alguna elección cambió.

**Lo que sigue:**
- Carlos sube el bloque de Timonel y el de esta decisión, y mueve `qa-r4` al commit de esta decisión.
- Codex reacepta H1, H2 (Atrás en el emulador y Esc con el teclado) y H3, con su matriz de 92 casos, la suite y `analyze`. RNF-002 no se repite: la corrección no toca la apertura de un plano.
- La meta sigue: la entrega 1 aceptada el 29 o el 30-oct.

La siguiente decisión es la **10.44**.

### 10.44 · La reaceptación de la entrega 1 no pasa por H4: «Acciones» sin nombre accesible en Windows; Timonel corrige (25-oct, 16:40)

**Codex la cerró hoy a las 16:32, sobre `916bf2b`** (`docs/t117/entrega1/reaceptacion-codex.md`, con su evidencia en `build/t117-entrega1-reaceptacion/` de `baystream-qa-r4`):
- **H1 pasa:** el botón cierra el flotante, el panel sigue oculto y la preferencia no cambia, también al cerrar y abrir la app en Windows. Sin flotante, el botón muestra y oculta el fijo, y «Fijar» lo fija.
- **H2 pasa:**
  - en el emulador, en claro y en oscuro, el primer Atrás cierra el menú sin advertencia y el siguiente es el primero del doble Atrás;
  - Esc cierra el menú en Windows y en la Web, abierto con el mouse y con el teclado;
  - abierto con el teclado, tras Esc el foco vuelve al botón del modo: Intro lo reabre y Tab sigue a «Buscar contenedor».
- **La geometría de H3 pasa:** a 700 dp, en Contenido y Descarga, la franja mide 56 dp; cuando envuelve, el botón queda al final de la primera línea. Lo comprobó también en Windows nativo, con el borde a 700 y a 600 dp.
- **H4 · P2 — «Acciones» solo con su ícono no tiene nombre accesible en Windows.** A 700 dp desaparece del árbol accesible, aunque la descripción emergente sí sale. La causa: `_PlanActions` (`loading_plan_controls.dart`) es un `PopupMenuButton` con un hijo propio, que no da nombre ni rol de botón; el motor de Windows toma el nombre de la etiqueta, no de la descripción. En la Web, Chrome sí lo anuncia como botón «Acciones».
- **O1 · P3 — a 800 × 600 con la letra a 2.0, en Contenido, la franja pasa de 126 a 178 dp** y la rejilla pierde 52 dp al abrir. Es el costo del nuevo reparto de la variante que envuelve. Se trabaja desplazando la columna o plegando el puente.
- **El cambio de tolerancia de `BsPrimeraQueCabe` no movió nada más:** solo cambia la elección a 960 × 1000 con la letra a 2.0, en Descarga, donde una variante se pasaba 0.08 dp. Ninguna elección de la cabecera cambia y no hay desbordes nuevos.
- **Cifras:**
  - la suite, 1677 aprobadas, sin fallidas ni omitidas, en una corrida;
  - `analyze` en cero en la copia limpia;
  - la matriz, 92 de 92: los dos casos de 800 × 600 que fallaron cierran el menú con Esc y «Deshacer» responde;
  - la prueba propia de H4, roja.

**Yov lo revisó:**
- el informe coincide con la huella de su manifiesto, y las 238 huellas de la evidencia coinciden. El árbol de `qa-r4` está intacto: solo se agregó el informe;
- H4 está en el código como dice Codex. El árbol accesible de Windows lo muestra: a 700 dp no hay «Acciones» entre «100 %» y «Plegar el panel del buque», y los demás botones de la oficina sí tienen nombre («Mostrar el panel lateral», «Bahía anterior»…);
- **Es más ancho de lo que dice el informe:** a 600 dp, con su rótulo, «Acciones» tampoco es un botón. Windows lo muestra como «texto Acciones. Acciones»: el nombre repetido, sin rol de botón. Viene de antes de T-117; con el ícono solo, el nombre desaparece del todo.

**Lo que sigue:**
- Carlos mueve el informe a la carpeta del rediseño y lo sube con esta decisión.
- Timonel corrige H4 en la corrección 2: «Acciones» como botón con su nombre, en las dos variantes y en los tres clientes, y busca el mismo patrón en lo que tocaron T-117 y T-118.
- **O1 queda anotado como P3 y no se toca ahora.** Arreglarlo cambia otra vez el reparto de la franja y arriesga otra vuelta de aceptación; se puede ver en la entrega 3.
- Codex reacepta solo H4, con la suite y `analyze`.
- La meta sigue: la entrega 1 aceptada el 29 o el 30-oct.

La siguiente decisión es la **10.45**.

### 10.45 · La corrección 2 de la entrega 1, entregada y revisada: «Acciones» ya es un botón con su nombre; pasa a la reaceptación (25-oct, 17:35)

**Timonel la entregó a las 17:27** (`docs/T117-T121-RESULTADOS.md`, «Corrección 2 de la entrega 1»):
- **H4:** «Acciones» es un botón con la etiqueta «Acciones», con el ícono y con el rótulo. Con solicitudes pendientes, el nombre lleva la cuenta («Acciones, 1 solicitud pendiente»). La descripción emergente sigue con el mouse, fuera de la semántica, para que el nombre no se repita.
  - La causa: en Windows, el nombre es la etiqueta más la descripción emergente, y un nodo de texto sin etiqueta se ignora.
- **El mismo patrón, una vez más:** el resumen de una línea del teléfono (`PlanSummaryLine`) era un `InkWell` sin rol de botón; ahora es un botón. No hay otro caso en lo que tocaron T-117 y T-118.
- **El árbol accesible de Windows**, en bancos propios abiertos con `explorer.exe`, antes y después:
  - a 700 dp, «Acciones» no aparecía, y ahora dice «botón Acciones»;
  - a 600 dp decía «texto Acciones. Acciones», y ahora «botón Acciones»;
  - a 560 dp, en el teléfono, igual que a 700.
  En MSAA sale como «botón de comando Acciones», y activado por UIA abre su menú. Nada más cambia en los árboles.
- **Cifras:** suite 1685 (piso 1677, más 8), sin fallidas ni omitidas, en una corrida, y `analyze` en cero. Las 8 pruebas nuevas fallan contra `41f458d` y pasan después.
- **Un tropiezo del instrumento:** al cerrar el menú, activó el «Cerrar» de la barra de título y cerró el banco. El instrumento solo actúa dentro de la ventana del proceso que se le da, así que no podía tocar otra ventana. Timonel repitió 600 y 560 dp.

**Yov la revisó contra el disco:**
- el árbol coincide con el bloque: 4 archivos cambiados y 2 nuevos (`test/t117_correccion2_test.dart` y `tool/t117_correccion2_windows.ps1`). No cambian `domain/`, `data/`, `pubspec.*`, `lib/main.dart`, los congelados ni la lista del piloto;
- el código hace lo que dice el informe: cambia solo la semántica, y las capturas de antes y de después son iguales;
- la comparación de los árboles de Windows coincide: solo cambian «Acciones» y el resumen del teléfono.

**Queda anotado, y no bloquea esta aceptación:**
- **La prueba de Codex que pide la descripción emergente dentro del nodo queda superada.** Con la descripción en la semántica, Windows repite el nombre. Para un botón de ícono se acepta esto: su etiqueta, el rol de botón, que se pueda tocar y la descripción emergente con el mouse.
- **O2 · P3 — los segmentos de `BsSelectorDeModo` repiten el nombre en Windows:** «botón Destino. Destino. El puerto de descarga…». Tienen nombre y rol, pero el lector de pantalla lo dice dos veces.
- **O3 · límite de Flutter:** las entradas de los menús de Flutter se leen como texto y no se activan desde UIA (Invoke); sí se activan con la acción por omisión de MSAA, la que usan los lectores de pantalla. Es del motor, no del producto.
- O1 y O2 se ven en la entrega 3, con lo demás de accesibilidad de la oficina.

**Lo que sigue:**
- Carlos sube el bloque de Timonel y el de esta decisión, y mueve `qa-r4` al commit de esta decisión.
- Codex reacepta solo H4 y el resumen del teléfono, con el árbol de Windows, la suite y `analyze`.
- La meta sigue: la entrega 1 aceptada el 29 o el 30-oct.

La siguiente decisión es la **10.46**.

### 10.46 · La entrega 1 de T-117 y T-118, aceptada; sigue la entrega 2, T-121 (25-oct, 18:10)

**Codex la aceptó hoy a las 17:56, en la segunda reaceptación, sobre `0949488`** (`docs/t117/entrega1/reaceptacion2-codex.md`, con su evidencia en `build/t117-entrega1-reaceptacion2/` de `baystream-qa-r4`):
- **H4 queda cerrado.** En UIA y en MSAA, «Acciones» es un botón con un solo nombre, con el ícono y con el rótulo, y con la cuenta del distintivo en singular y en plural. Invoke abre su menú. El resumen del teléfono también es un botón.
- Sus árboles de Windows, comparados con los de la reaceptación anterior, solo cambian en «Acciones».
- **Cifras:** la suite, 1685 de 1685 en una corrida, sin omitidas; sus pruebas propias, 9 de 9; `analyze` en cero en la copia limpia. No hay hallazgos nuevos.

**Yov lo revisó:** el informe coincide con la huella de su manifiesto, las 85 huellas de la evidencia coinciden, y el árbol de `qa-r4` está intacto.

**La entrega 1 queda aceptada, cuatro días antes de la meta del 29 o el 30-oct.** Pasó por tres rondas de Codex: la aceptación (H1, H2 y H3), la reaceptación (H4) y la segunda reaceptación, que pasa. **El piso de la suite sube a 1685.**

**Queda anotado para la entrega 3:** O1 y O2 (P3), y el arrastre entre dos monitores, que no se pudo probar. O3 es un límite de Flutter.

**Lo que sigue:**
- Carlos mueve el informe a la carpeta del rediseño y lo sube con esta decisión.
- **La entrega 2, T-121: las estadísticas A, «El buque en corte»** (10.37 y 10.38), según la sección 0.9 del informe de la fase 0:
  - Timonel escribe primero `DESIGN.md` (la cifra protagonista a 48 dp y la rampa nueva) y después el código;
  - lleva lo que dejó la entrega 1: cada control con su nombre en el árbol de Windows, y Esc y Atrás para lo que se abre sin ser una ruta;
  - tocar una bahía la abre en el plano. Tocar un puerto para ir a la Lista filtrada va con T-120, en la entrega 3;
  - corre Flutter solo con la luz verde de Carlos.
- Para el ensayo y el piloto con la 3.1.0 sigue la regla de 10.39: no hay Flutter en esas horas, y Carlos pausa a Timonel antes de salir con la laptop.
- Las metas: la entrega 2 hacia el 3-nov, la 3.2.0 publicada a más tardar el 4-nov y la presentación final el 7-nov. La lista del piloto se pone al día al publicar la 3.2.0 (E1.10).

La siguiente decisión es la **10.47**.

### 10.47 · El piloto va hoy en el ECO BORA, con la Web y el Honor; Timonel sigue toda la noche con luz verde (25-oct, 18:55)

**Carlos lo decidió a las 18:44:**
- **El piloto es hoy, en su jornada en el buque ECO BORA,** con un plano real de descarga y uno de carga:
  - la oficina, en la Web, desde su teléfono personal;
  - el muelle, en el Honor, con la app de la prueba interna de Play;
  - las dos con la 3.1.0. La laptop se queda en casa.
- Lo que encuentre (mejoras, cambios y arreglos) se lo pasa a Yov al volver, y Yov lo convierte en tareas.
- **Timonel sigue con la entrega 2 toda la noche, con Fable 5.1 en Ultracode y luz verde para todo lo que la entrega necesita:** Flutter cuantas veces haga falta, siempre un comando a la vez, y abrir y cerrar sus bancos, Chrome con perfil temporal y el emulador. Como la laptop no va al piloto, la regla de 10.39 no lo frena esta vez. Si una tarjeta de permiso no responde, aplica 10.41 o deja el paso anotado para mañana.
- **No cambian:**
  - Git solo de lectura;
  - nada de Firebase ni de publicaciones;
  - el Honor no se toca, porque está en el muelle; las apps instaladas, «PRUEBA T-105» y `baystream-demo17` tampoco;
  - solo datos sintéticos: nada del ECO BORA entra al repositorio ni a las capturas.

La siguiente decisión es la **10.48**.

### 10.48 · La entrega 2, T-121, entregada y revisada: «El buque en corte»; pasa a la aceptación de Codex (25-oct, 20:25)

**Timonel la entregó a las 20:13, con Fable 5.1 en Ultracode, en unas 2 h de reloj** (la fase 0 estimó de 11 a 13 h; `docs/T117-T121-RESULTADOS.md`, «Entrega 2 · T-121», y `DESIGN.md` 15). Corrió Flutter con la luz verde de Carlos (10.47):
- **La página:**
  - la silueta grande (`BsBuqueEnCorte`) con dos pilas por bahía, cubierta y bodega, cuyo alto dice los contenedores o el peso;
  - encima, «N contenedores a bordo» a 48 (`BsEscala.cifraProtagonista`) y la fila de cifras; debajo de cada bahía, su número, su cuenta y su peso, en el mismo eje;
  - cinco paneles: por puerto, llenos y vacíos, por tamaño, carga especial y por naviera;
  - «Ver como tabla», que se cierra con Esc y con Atrás. Tocar una bahía la abre en el plano.
- **La rampa nueva de 0.9.4** entra en `bs_paleta.dart` y sustituye la de `DESIGN.md` 5.5. Se volvió a validar con el script de la skill de dataviz.
- **Cinco componentes nuevos** en `lib/core/design/componentes/`, y las cifras en `estadisticas_del_viaje.dart`, en la capa de presentación. Sale `vessel_profile_view.dart` con su prueba: su casco era otro buque, y lo sustituye la protagonista.
- **Trece desviaciones de 0.9.5,** anotadas en `DESIGN.md` 15.11. Las más visibles:
  - el peso por bahía va como cifra en el pie, no como columna;
  - las pilas van en los dos colores de cubierta y bodega del ícono, con su leyenda;
  - la bahía mide 56 dp por la escala de la letra;
  - «Otros N» sale solo cuando sobran dos o más.
- **Antes de la luz verde,** cuatro revisores sin compilar, con un escéptico por hallazgo, encontraron cinco defectos, ya corregidos: el foco de Esc, la tinta de las bahías bajo la hoja, el selector y la tabla que partían palabras a 360 dp, el anillo con la letra a 2.0 y una prueba de T-97 que buscaba «Total Contenedores».
- **Cifras:**
  - suite 1773 (piso 1685, más 88 netas: 92 nuevas, menos las 3 de la vista borrada, de las que una pasa a T-121, y la referencia de píxeles de T-109), sin fallidas ni omitidas, en una corrida;
  - `analyze` en cero;
  - capturas con datos sintéticos, sin textos cortados ni errores: Windows 58 (el sintético de 977 en 72 bahías y el plano de llegada), la Web 24 y el emulador 24.

**Yov la revisó contra el disco:**
- el árbol coincide con el bloque: 13 archivos cambiados, 10 nuevos y 2 borrados, 25 rutas. `SPRINT-4.md` trae la 10.47 de Yov y no va en el bloque de Timonel. No cambian `domain/`, `data/`, `pubspec.*`, `lib/main.dart`, los congelados ni la lista del piloto;
- en las piezas nuevas no hay `Colors.*` ni naranja; la rampa de `bs_paleta.dart` es la validada, y la cifra protagonista mide 48;
- las pruebas que cambian se ajustan a la vista nueva sin aflojarse:
  - T-97 y T-107 buscan la protagonista en vez de «Total Contenedores»;
  - T-109 deja la referencia de píxeles de la vista vieja y ya no lee el corpus;
  - los censos de T-98c solo dejan de nombrar el archivo borrado;
  - no queda ninguna referencia a `vessel_profile_view.dart`;
- en las capturas, la página es coherente con «Puente de mando», en los dos temas y en los tres clientes;
- **tres cosas para la aceptación:**
  - con pocas bahías (el plano de llegada tiene nueve), la silueta ocupa menos de la mitad del panel, pegada a la izquierda, y la protagonista se ve chica. Con 72 bahías llena el panel y se desplaza;
  - la muestra de «Cubierta» en la leyenda, blanca y con borde, parece una casilla para marcar;
  - el selector «Contenedores / Peso» va solo con íconos cuando no caben los rótulos, y tiene que conservar su nombre en el árbol de Windows (la lección de H4).
- `formatearToneladas` escribe «8366.1 t», sin separador de miles, como en todo el producto; los wireframes de la fase 0 decían «7 419.5 t». Yov recomienda dejarlo así.

**Lo que sigue:**
- Al volver del piloto, Carlos sube el bloque de Timonel y el de 10.47 y 10.48, y mueve `qa-r4` al commit de esta decisión.
- Codex acepta la entrega 2.
- La meta: la entrega 2 aceptada hacia el 3-nov, y la 3.2.0 publicada a más tardar el 4-nov.

La siguiente decisión es la **10.49**.

### 10.49 · Piloto en el ECO BORA, hallazgo 1 (P1): el plano de llegada no deja elegir GTSTC como escala (25-oct, 22:25)

**Carlos lo encontró hoy a las 22:16, en el muelle, con la 3.1.0 en la Web de su teléfono (oficina).** Es el primer defecto del piloto, y lo detectó él mismo.

**Lo que pasó:**
- Abrió el plano de llegada real del ECO BORA. El archivo declara que el buque sale de HNPCR (`LOC+5`) rumbo a JMKWL (`LOC+61`), pero trae contenedores con descarga en GTSTC, el puerto donde opera Carlos.
- La app propuso HNPCR como escala, y quedó confirmada. Con HNPCR, la cuenta dice «0 se descargan»: el menú del modo no ofrece «Descarga», y un contenedor que baja en GTSTC no se puede marcar.
- En «Parámetros del buque» → «Puerto de esta escala», **GTSTC no aparece entre las opciones.** Solo están HNPCR, JMKWL, los puertos de carga (PAMIT, CRPMN, PAONX) y «Sin declarar».

**La causa, en el código de la 3.1.0 (`master`, `v3.1`):**
- `vessel_geometry_page.dart`, `_portOptions`: ofrece el puerto de salida, el siguiente, los puertos de carga de los contenedores y los de las celdas reservadas. **Los puertos de descarga no entran.**
- `vessel_voyage.dart`, `suggestPortOfCall`: la última escala confirmada solo se propone si es la de salida o la siguiente.
- `discharge_provider.dart`, `offersDischarge`: «Descarga» existe solo si algo baja en la escala elegida.
- Resultado: con un archivo cuyo `LOC+61` no es el puerto donde se opera, la descarga, que es la función principal del muelle, no se puede hacer. Es el mismo terreno de T-68 («la escala mal propuesta en planos de llegada»); aquel arreglo se apoyó en `LOC+61`, y este archivo lo trae distinto.

**Esta noche:** la descarga va en papel. Carlos prueba la carga con el `.edi` de carga, si declara GTSTC como salida, e informa cómo se comporta.

**La corrección que propone Yov (decide Carlos):**
- **Una 3.1.1 desde `master` y `v3.1`, no desde `sprint-4`, como dice 10.39:** los puertos de descarga de la carga entran en las opciones de la escala, con su cuenta («GTSTC (n)»). Si la última escala confirmada es uno de ellos, se propone esa.
- La prueba, con un BAPLIE sintético que salga de un puerto A rumbo a C con carga para B: B se puede elegir y «Descarga» aparece. Nada del ECO BORA entra al repositorio.
- El mismo arreglo pasa después a `sprint-4`, para la 3.2.0.

La siguiente decisión es la **10.50**.

### 10.50 · Piloto en el ECO BORA, hallazgos 2 y 3: el listado no entra en una operación publicada, y la fila «AGREGADOS» (25-oct, 22:45)

**Carlos lo encontró a las 22:39, en la Web de su teléfono (oficina).** Con el plan de carga ya funciona la escala GTSTC: la operación quedó publicada en la nube. Después quiso importar el listado de la agencia para ver los números de orden en el plano.

**Hallazgo 2 (P1) — el listado no entra en una operación publicada.**
- La página del listado lo leyó bien (las filas de cada agencia, los llenos y los vacíos, con la equivalencia 40HC → 45G1), pero no lo guarda: «La operación de esta escala ya está publicada y sus fuentes no cambian. Abre la fuente publicada desde «Nube y cuenta»».
- La causa: `operation_sources.dart`, `OperationSources.save`. Una operación publicada solo acepta la misma fuente que ya tiene, con el mismo texto. No acepta una fuente nueva, aunque falte, como el listado.
- En la lista del piloto, el listado entra antes de publicar (1.4 y 1.5, antes de 1.7). Pero en la operación real el listado llega tarde o cambia mientras se carga, como muestra el hallazgo 3. Sin el listado no salen los números de orden en el plano, y «Asignar vacío», que trabaja con los vacíos del listado, no tiene con qué.

**Hallazgo 3 (P2) — la fila «AGREGADOS».**
- La agencia agrega contenedores al final del Excel, debajo de una fila «AGREGADOS». El lector la marca como «1 fila sin entender» y pide corregir el Excel.
- Tiene que entenderla como un encabezado de sección. Falta revisar si las filas de debajo quedaron contadas en la última agencia.

**Esta noche:** se descarta el listado. La carga de llenos sigue por los últimos dígitos del contenedor, y los números de orden y los vacíos van con el listado impreso.

**La corrección que propone Yov para la 3.1.1 (decide Carlos), junto con el hallazgo 1:**
- La oficina puede agregar o reemplazar el listado de una operación publicada, y el muelle lo recibe. Los movimientos registrados no se pierden. Antes hay que revisar cómo viajan las fuentes por la nube y si las reglas publicadas lo permiten, porque las reglas no se tocan sin Carlos.
- El lector entiende «AGREGADOS» como encabezado de sección.
- Las pruebas, con un listado sintético que traiga esa fila. Nada del listado real entra al repositorio.

La siguiente decisión es la **10.51**.

### 10.51 · Piloto en el ECO BORA, hallazgo 4 (P1): sin listado no se registra ninguna carga (25-oct, 22:50)

**Carlos lo encontró a las 22:46, con la cuenta de oficina en la Web.** Al tocar una celda de carga, solo se abre el detalle («Pendiente», con su celda), y «OR / últimos dígitos» sale apagado.
- Que la oficina no registre cargas es el diseño: registra el muelle, y la oficina mira y aprueba cambios.
- **El defecto es otro:** en la 3.1.0, una carga solo se registra a través de su fila del listado. En `loading_controls.dart`, `onLoadingContainerTap`, sin fila la oficina ve el detalle y el muelle recibe «Este contenedor no tiene OR en el listado de la agencia: importa el listado actualizado». «OR / últimos dígitos» se apaga sin listado (`busquedaDeCarga`).
- Con el hallazgo 2, la operación publicada sin listado no admite **ninguna** carga, ni en el Honor ni en la oficina. Un lleno que viene en el plan de carga se tendría que poder cargar por su número de contenedor aunque no haya listado: el número de orden ayuda, pero no es la llave.

**Esta noche:** la carga va en papel. Para probar el flujo del muelle, Carlos puede abrir la Web en una pestaña de incógnito, sin cuenta, como muelle local: el plan de carga con GTSTC y el listado importado. Esas marcas no se sincronizan y se borran al cerrar la pestaña.

**Para la 3.1.1 (decide Carlos), con los hallazgos 1 a 3:** cargar un lleno del plan por su número de contenedor, sin listado. Para los vacíos, sigue haciendo falta el listado (hallazgo 2).

La siguiente decisión es la **10.52**.

### 10.52 · Piloto en el ECO BORA: la carga ya corre; hallazgo 5 (P2), el avance de la bahía 22 sube en la 21 (26-oct, 05:35)

**El camino que funcionó (25-oct, 23:11).** Carlos hizo una copia del plan de carga con otro número de viaje, para tener una operación nueva. En la Web (oficina), eligió GTSTC, importó el listado **antes** de publicar y después publicó; el Honor (muelle) se unió. Con eso:
- salen los números de orden, y «OR / últimos dígitos» funciona;
- se declararon las tapas («Sin tapa · bodega abierta»), y la nube queda al día;
- la carga avanza desde el Honor; a las 05:26 seguía en marcha.

Es la confirmación de los hallazgos 2 y 4: con el listado dentro antes de publicar, la carga funciona.

**Hallazgo 5 (P2) — el avance de la carga se dibuja en la bahía impar.**
- Cargando contenedores de 40 pies en la 22, la barra de avance de la silueta sube bajo la **21**, y la 22, que es la elegida, no muestra avance.
- La causa: `loading_operation.dart`, `displayBay`: una bahía par se cuenta con la impar anterior si esta existe en el plan (22 → 21), y el avance la rotula «21/22» (`operation_progress.dart`).
- En el buque es al revés, como dice Carlos: **la par es la bahía de referencia.** La 22 es la bahía de 40 pies, y la 21 y la 23 son sus dos mitades de 20 pies (lo mismo con 01, 02, 03 o con 17, 18, 19).
- Los movimientos se guardan bien, con su posición en la 22. Lo que está mal es dónde se cuenta y se dibuja el avance.

**La corrección que propone Yov (decide Carlos):** agrupar por la bahía par (21 y 23 → 22) en el avance y en la silueta, con su prueba. Toca `domain/`: en la 3.1.1 es un arreglo de un defecto, así que lo autoriza Carlos.

La siguiente decisión es la **10.53**.

### 10.53 · La aceptación de la entrega 2 no pasa por un P2: con pocas bahías, la silueta queda chica; Timonel corrige (26-oct, 09:40)

**Codex la cerró hoy a las 07:22, sobre `f324499`** (`docs/t121/entrega2/aceptacion-codex.md`, con su evidencia en `build/t121-entrega2-aceptacion/` de `baystream-qa-r4`):
- **H1 · P2 — con pocas bahías, la silueta no es la protagonista «en grande» de 0.9.5.** Con `T100_LLEGADA` (nueve bahías) a 1920, con la letra a 1.0, queda pegada a la izquierda y ocupa menos de la mitad del ancho del panel, en Contenedores y en Peso. Con 72 bahías sí llena el panel y se desplaza. La causa: `BsBuqueEnCorte` arma una fila de ancho intrínseco, con 56 dp por bahía por la escala de la letra, y no reparte el ancho que sobra. Es el primero de los tres puntos de Yov en 10.48.
- **O1 · P3 — la muestra de «Cubierta» parece una casilla para marcar:** blanca, cuadrada, de 12 dp y con borde. En el árbol accesible es texto, no un control. Es el segundo punto de 10.48.
- **Acepta las trece desviaciones de `DESIGN.md` 15.11,** una por una.
- **Lo demás pasa, con pruebas propias:**
  - la suite, 1773 aprobadas, sin fallidas ni omitidas, y `analyze` en cero en la copia limpia;
  - 66 pruebas propias y una matriz de 60 casos: cinco tamaños, dos letras, dos temas y tres juegos de datos;
  - las cifras cuadran con un conteo propio en los tres archivos sintéticos: el total, los llenos y vacíos, los puertos, las navieras, los tamaños y las bahías;
  - en Windows, con UIA y MSAA, «Contenedores» y «Peso» se dicen una vez y con rol de botón, también cuando van solo con íconos (el tercer punto de 10.48). La Web pasa 60 de 60 en Chrome, y Android, seis condiciones en el emulador;
  - la rampa pasa el script de la skill de dataviz en los cuatro fondos de 0.9.4, y la cifra protagonista mide 48.
- **Una salvedad, declarada por Codex:** antes de la corrida válida hubo dos intentos de suite sobre copias mal hechas. A la primera le faltaba `lib/core/design/`; a la segunda, sus manifiestos, y ya llevaba el rótulo del banco. No son reintentos del producto.

**Yov lo revisó:**
- el informe coincide con la huella de su manifiesto, y las 811 huellas de la evidencia coinciden. El árbol de `qa-r4` está intacto: solo se agregó el informe;
- los dos intentos son lo que dice Codex:
  - el primero se cortó al compilar;
  - el segundo falló solo en las pruebas que leen esos manifiestos (`t114_ilustraciones`) y el rótulo (`t88_privacy_policy`);
  - la corrida válida fue sobre una copia cotejada con el árbol, 1 879 archivos, donde solo difiere el registrador de plugins que genera `pub get`.
  
  Vale, y queda una lección: la copia se coteja antes de la primera corrida;
- la captura de la Web a 1920 lo muestra: la silueta de nueve bahías mide menos de 600 de los más de 1 400 px del panel, y a la derecha no hay nada. La muestra de «Cubierta» se ve como una casilla junto al selector.

**La pregunta de 10.52, respondida.** Codex usó un viaje sintético con dos contenedores de 20 pies en la 21, tres de 40 en la 22 y uno de 20 en la 23:
- Estadísticas cuenta cada número por separado: la 21 con 2, la 22 con 3 y la 23 con 1;
- el avance junta la 22 con la 21 («21/22», 5) y deja la 23 sola;
- ninguna de las dos sigue la regla de Carlos, que la bahía de referencia es la par.

Se ve también en `T100_LLEGADA`: Estadísticas dibuja nueve columnas, seis de ellas en cero (las impares vecinas de los de 40). El planificador ahí ve tres bahías: la 02, la 06 y la 10.

**Lo que sigue:**
- Carlos mueve el informe a la carpeta del rediseño y lo sube con esta decisión, antes de mover `qa-r4` otra vez.
- **Timonel corrige H1 y O1** en la corrección 1 de la entrega 2, con una prueba que reproduce cada uno, y pone al día `DESIGN.md` 15.4:
  - cuando las bahías caben, la silueta ocupa el ancho útil del panel: cada bahía crece hasta un tope escrito en 15.4, y si aun así sobra ancho, el casco va centrado;
  - no cambian la escala común de las pilas, el pie en el mismo eje, el desplazamiento cuando no caben ni la página en el teléfono;
  - corre Flutter con la luz verde de Carlos mientras la laptop no vaya al muelle, como en 10.47.
- **La regla de la bahía par no entra en esta corrección:** en Estadísticas, cada bahía sigue siendo su número. Yov propone una sola regla, con la par como referencia, para el avance (la página y la silueta del plano) y para Estadísticas:
  - se escribe una vez en el dominio, en la 3.1.1 (10.52);
  - cuando la 3.1.1 pase a `sprint-4`, Estadísticas la adopta en una tarea propia.
  
  Decide Carlos.
- Codex reacepta H1 y O1, con la suite y `analyze`.
- La meta sigue: la entrega 2 aceptada hacia el 3-nov, y la 3.2.0 a más tardar el 4-nov.

La siguiente decisión es la **10.54**.

### 10.54 · La corrección 1 de la entrega 2, entregada y revisada: con pocas bahías, la silueta llena el panel; pasa a la reaceptación de Codex (26-oct, 11:15)

**Timonel la entregó a las 11:05, con Opus 5.5** (`docs/T117-T121-RESULTADOS.md`, «Entrega 2 · corrección 1», y `DESIGN.md` 15.4):
- **H1:** cuando las bahías caben, se reparten el ancho útil del panel (`BsBuqueEnCorte.repartir`):
  - cada bahía crece hasta un tope de tres veces su mínimo: 168 dp con la letra a 1.0 y 336 a 2.0. Si aun así sobra ancho, el casco va centrado. Con ese tope, desde ocho bahías la silueta llena el panel de 1440;
  - con 600 dp o más de ancho, el alto de las zonas crece en la misma proporción, hasta 1.5 veces: de 72 a 108 dp;
  - no cambian las 72 bahías, el teléfono ni la letra a 2.0 cuando no caben: 56 dp por bahía, el alto base y el desplazamiento.
- **O1:** la muestra de la leyenda es una pila pequeña de tres niveles, de 10 × 17 dp y sin borde. En el árbol accesible sigue siendo texto.
- **Cifras:**
  - 10 pruebas nuevas en `test/t121_entrega2_c1_test.dart`. Contra una copia de `a5dfc9f`, con solo la regla del reparto añadida para que compile, fallan las 8 de H1 y O1, y pasan la regla y la de las 72 bahías;
  - la suite, 1783 de 1783 (antes 1773), sin fallidas ni omitidas, en una corrida, y `analyze` en cero;
  - 154 capturas con datos sintéticos, sin textos cortados ni errores de Flutter: Windows 58, la Web 48 y el emulador 48. En E2C1.6 el informe dice 146; son 154 (26 + 32 + 4 × 24).
- Tras la primera corrida en rojo, Timonel corrigió tres comprobaciones mal planteadas de su prueba: el redondeo de los anchos, las bahías del caso de tres y la medida de la muestra. Ninguna toca lo que miden H1 y O1; por eso el «antes» que cuenta es la corrida contra `a5dfc9f`.

**Yov la revisó contra el disco:**
- el árbol coincide con el bloque: 6 archivos cambiados y 1 nuevo, 7 rutas. No cambian `domain/`, `data/`, `pubspec.*`, `lib/main.dart`, los congelados ni la lista del piloto, y la regla de las bahías pares e impares no se tocó;
- el código hace lo que dice: un `LayoutBuilder` da el ancho del panel y `repartir` lo divide. Si las bahías caben, la silueta va en una caja del ancho del panel, centrada; si no, se desplaza como antes;
- las pruebas miden lo que importa:
  - con nueve bahías, a 1920 y a 1366, las bahías ocupan más del 90 % del panel, sin nada que desplazar, y la proa y la popa quedan a 40 dp o menos del borde;
  - con tres bahías, cada una mide su tope y el casco va centrado;
  - las 72 bahías se desplazan como antes;
- en las capturas, la silueta de nueve bahías va de borde a borde a 1920 y a 1366, en los dos temas. A 1366 con la letra a 2.0 no cabe y se desplaza, como dice la regla. El 977 y el teléfono se ven como antes. La leyenda ya no parece una casilla, y sin el borde la muestra de «Cubierta» se sigue viendo en el tema claro;
- **una cosa para la reaceptación:** en el plano de llegada queda una franja vacía arriba del casco. La cubierta lleva un solo nivel, y su zona reserva el mismo alto que la bodega, ahora de 108 dp. Es la escala común de 15.4, no un defecto; Codex dice si la protagonista cumple con «en grande».

**Lo que sigue:**
- Carlos sube el bloque de Timonel y esta decisión, y mueve `qa-r4` al commit de esta decisión.
- Codex reacepta H1 y O1 en los tres clientes, con la suite y `analyze`, y coteja su copia antes de la primera corrida (10.53). Corre Flutter con la luz verde de Carlos mientras la laptop no vaya al muelle (10.47).
- Siguen abiertas para Carlos dos decisiones de 10.53: la regla de la bahía par y la 3.1.1.
- La meta sigue: la entrega 2 aceptada hacia el 3-nov, y la 3.2.0 a más tardar el 4-nov.

La siguiente decisión es la **10.55**.

### 10.55 · La entrega 2 de T-121, aceptada: las estadísticas ya son «El buque en corte» (26-oct, 13:45)

**Codex la reaceptó a las 13:27, sobre `004ccaa`** (`docs/t121/entrega2/reaceptacion-codex.md`, con su evidencia en `build/t121-entrega2-reaceptacion/` de `baystream-qa-r4`):
- **H1 y O1 quedan cerrados:**
  - con nueve bahías, la silueta se reparte el panel a 1920 (148 dp por bahía) y a 1366 (137), sin nada que desplazar y con zonas de 108 dp;
  - con tres y con cuatro bahías, cada una mide su tope de 168 dp y el casco va centrado;
  - con 72 bahías y en el teléfono, todo sigue como antes;
  - la muestra de la leyenda se reconoce como pila y, en los tres clientes, sigue siendo texto.
- **El punto de 10.54:** la franja vacía arriba del casco se ve, y la protagonista cumple igual con «en grande». Esa reserva dice que la cubierta va casi vacía.
- **Cifras:**
  - la suite, 1783 de 1783, en una sola corrida, sobre una copia cotejada antes de correrla (la lección de 10.53), y `analyze` en cero;
  - su matriz, 80 de 80; Chrome, 60 de 60; Android, 6 de 6; Windows, con UIA y MSAA.
- **Tres tropiezos de su instrumento, declarados y resueltos:**
  - dos pruebas propias de O1 cerraban mal su manejador de semántica; repitió solo esas dos, no la suite;
  - una lectura sin UTF-8 en su recorrido de Android;
  - unas capturas con el puntero encima, que repuso.

**Yov lo revisó:** el informe coincide con la huella de su manifiesto, y las 930 huellas de la evidencia coinciden. El árbol de `qa-r4` está intacto: solo se agregó el informe. El resumen de la suite dice una sola ejecución, con 1783 éxitos y ninguna omitida.

**Con esto:**
- **la entrega 2 de T-117 a T-121 queda aceptada,** una semana antes de la meta del 3-nov. El piso de `sprint-4` sube a **1783**;
- lo que lleva la 3.2.0 ya está hecho: las entregas 1 y 2 (10.38). La entrega 3 va en una 3.2.1, porque la presentación final es el 7-nov. Son T-119 y T-120, con O1 y O2 de la entrega 1 y el arrastre entre dos monitores;
- **siguen abiertas para Carlos** la 3.1.1, con los hallazgos del piloto (10.49 a 10.52), y la regla de la bahía par (10.53).

**Yov propone hacer la 3.1.1 ahora, antes que la entrega 3.** Son defectos P1 de la primera operación real, y la 3.2.0 de la presentación tiene que llevarlos corregidos. La propuesta:
- Timonel trabaja desde `master` y `v3.1`, en la carpeta `proyecto-baystream`, y Codex la acepta;
- entran H1, H3, H4 y H5, con la regla de la par. Tocan `domain/`, y el sí de Carlos es la autorización (10.52);
- H2, el listado que entra en una operación ya publicada, toca cómo viajan las fuentes por la nube y quizá las reglas publicadas: Timonel lo diagnostica y lo propone, y decide Carlos;
- después, el arreglo pasa a `sprint-4`, y de ahí sale la 3.2.0.

**Lo que sigue:**
- Carlos mueve el informe a la carpeta del rediseño y lo sube con esta decisión.
- Carlos decide la 3.1.1 y la regla de la par. Con su sí, Yov escribe el prompt de Timonel.
- La meta sigue: la 3.2.0 publicada a más tardar el 4-nov. La lista del piloto se pone al día al publicarla (E1.10).

La siguiente decisión es la **10.56**.

### 10.56 · La 3.1.1 va (T-122), con dos hallazgos más del piloto: un vacío asignado que ninguna búsqueda encuentra y el arrastre en el teléfono (26-oct, 14:10)

**Carlos aprobó la propuesta de 10.55 a las 13:50:**
- **T-122 · La 3.1.1, con los hallazgos del piloto.** Timonel trabaja desde `master` y `v3.1`, en `proyecto-baystream`; es la excepción a «no cambies de carpeta». Codex la acepta. Entran H1, H3, H4, H5 y los dos hallazgos de abajo; H2 solo se diagnostica y se propone. Las versiones: la 3.1.1 con la compilación 5, y el MSIX 3.1.1.0.
- **La regla de la bahía par es la de Carlos:** la par es la bahía de referencia. Una impar se cuenta con la par vecina que la cubre (21 y 23 con 22), y el grupo se rotula con la par. Se escribe una sola vez en el dominio, en la 3.1.1. Estadísticas la adopta en `sprint-4` cuando la 3.1.1 pase allá.

**Hallazgo 6 (P1) — un vacío asignado a una celda reservada no aparece en ninguna búsqueda.** Carlos lo encontró hoy hacia las 11:17, en el Honor (muelle):
- El supervisor de la portuaria buscaba el OR 48 en su plano de papel y creyó que no se había cargado: lo había anotado en la bahía 26 y lo olvidó. Para ayudarlo, Carlos lo buscó en la app.
- El OR 48 es un vacío del listado que Carlos asignó a las 10:38 a la única celda reservada de la bahía 26. El plano lo muestra cargado, con su OR, y su detalle dice «Cargado», con su celda y su hora.
- Pero la búsqueda general, con el número completo, dice «Sin resultados». «OR / últimos dígitos» tampoco lo ofrece, ni por su OR ni por sus dígitos: con «48» salen dos llenos cuyo número termina en 48. Fue el único contenedor que no apareció.
- **La causa, en la 3.1.0:**
  - la búsqueda general (`container_search_delegate.dart`) solo recorre `voyage.containers`, el BAPLIE, donde la celda reservada no trae número de contenedor (`vessel_overview_page.dart`, línea 462);
  - `LoadingOperation.search` (`loading_operation.dart`, línea 81) solo da las filas del listado cuyo contenedor está numerado en el plan de carga (`numbered`); un vacío asignado a una reserva no lo está;
  - el vacío vive solo como `assignedContainer` en el estado de la operación. De ahí lo leen el plano, su detalle y el BAPLIE de salida (`departure_baplie_writer.dart`); las búsquedas no.
- Por eso fue el único: era el único vacío cargado en una celda reservada.
- **La corrección:** las dos búsquedas encuentran el vacío asignado como a los demás, la general por su número y la de carga por su OR y sus últimos dígitos, con su celda y «Ya cargado». Timonel revisa qué otras vistas que listan contenedores lo pierden.

**Hallazgo 7 (P2) — en el teléfono, el arrastre no llega al otro extremo de la bahía.**
- Al mantener presionado un contenedor, se levanta y sigue al dedo, pero el plano no se desplaza cuando el dedo llega al borde. La celda de destino, fuera de la vista, no se alcanza.
- **La causa:** `PlanDragCell` (`plan_drag_confirmation.dart`) es un `LongPressDraggable` dentro de los dos `SingleChildScrollView` de `PlanZoomViewport` (`bay_plan_view.dart`), y nada desplaza la vista durante el arrastre. Con dos dedos, el gesto se lo lleva el zoom.
- Mientras tanto, el cambio se pide con el formulario de «Pedir cambio».
- **La corrección:** durante el arrastre, el plano se desplaza solo, en los dos ejes, cuando el dedo o el mouse se acercan al borde, también con zoom. Al soltar, cuenta la celda que queda bajo el dedo.

**Lo que sigue:**
- Carlos sube esta decisión.
- Timonel hace T-122 con Flutter, mientras la laptop siga en casa (10.47). Codex la acepta.
- Carlos publica la 3.1.1 con la sección 4 de la lista del piloto cuando el ECO BORA termine, no durante la operación.
- Después, la 3.1.1 pasa a `sprint-4`, y de ahí sale la 3.2.0, a más tardar el 4-nov.

La siguiente decisión es la **10.57**.

### 10.57 · T-122, la 3.1.1, entregada y revisada: seis hallazgos corregidos y una corrección antes de Codex, por el BAPLIE de salida (26-oct, 16:45)

**Timonel la entregó a las 16:32** (`docs/T122-RESULTADOS.md`, en `master` sobre `7488321`):
- **H1:** los puertos de descarga entran en las opciones de la escala con su cuenta («GTSTC (7)»), y se proponen si fueron la última escala confirmada. «Descarga» aparece sola.
- **H3:** «AGREGADOS» es un encabezado de sección. Sus filas se cuentan en «AGREGADOS: n» y no en la última agencia, como pasaba en la 3.1.0.
- **H4:** en el muelle, un lleno del plan sin fila en el listado se carga por su número, tocando su celda o con «OR / últimos dígitos», que ya no se apaga sin listado. La oficina sigue sin registrar cargas, y los vacíos siguen necesitando el listado.
- **H5:** la regla de la par vive en `reference_bay.dart`. La impar va con la par vecina que está en el plano, no con la convención de 02, 06, 10…, porque A01 trae una 044. El avance y la silueta del plano ya suben bajo la 22.
- **H6:** el vacío asignado sale en «OR / últimos dígitos» («Ya cargado»), en la búsqueda general con su celda, y en la Lista. Las alertas, la comparación de viajes y las estadísticas leen el BAPLIE; quedan para `sprint-4`.
- **H7:** durante el arrastre, el plano se desplaza solo en los dos ejes cuando el dedo o el mouse se acercan al borde, también con zoom (`EdgeDraggingAutoScroller`), y al soltar cuenta la celda que queda bajo el dedo.
- **H2, solo diagnóstico** (sección 8): las reglas publicadas no dejan cambiar el manifiesto de las fuentes, y `join` rechazaría trozos nuevos. Hace falta tocar las reglas: el listado con revisión, `replaceSource` en la oficina y el muelle escuchando el documento de la operación. Los movimientos no se pierden. Decide Carlos.
- **La versión:** 3.1.1, compilación 5, y el MSIX 3.1.1.0. `pubspec.lock` no cambia.
- **Cifras:**
  - 25 pruebas nuevas: 14 de los hallazgos, 3 del arrastre y 8 del dominio. El informe dice 26 y 15 en dos lugares; son 25 y 14;
  - contra la 3.1.0, 16 de las 17 de los hallazgos y el arrastre fallan, y una ya pasaba (la impar sola);
  - la suite, 1396 de 1396 en una corrida (el piso de `master` es 1371), y `analyze` de `lib/` y `test/` en cero. El proyecto entero arrastra 13 avisos de copias viejas en `build/t112acc`, fuera de Git;
  - 80 capturas sintéticas en los tres clientes y los dos temas.

**Yov la revisó contra el disco:**
- el árbol coincide con el bloque: 30 rutas, 20 cambiadas y 10 nuevas. Los documentos de Carlos en `docs/` no se tocaron. No cambian `lib/main.dart`, las reglas, los congelados, la lista del piloto ni `pubspec.lock`. En lo cambiado no hay datos del piloto;
- las pruebas viejas que cambian de expectativa siguen la regla nueva, no se aflojan:
  - T-68 cambia su puerto ajeno: PAMIT ahora es puerto de descarga en su archivo;
  - T-76 y T-78 pasan a la par de referencia;
  - T-93 pide el MSIX 3.1.1.0;
- una carga sin OR sube a la nube: el borrador quita los campos vacíos, y las reglas publicadas aceptan `load_full` sin `order`;
- «AGREGADOS» como sección propia no cambia los grupos de los vacíos, que van por tipo, puerto y línea. Yov recomienda dejarlo así: es lo que dice el Excel;
- las capturas del teléfono muestran cada arreglo: las fichas de la escala, «AGREGADOS: 2», «sin OR en el listado», el avance bajo la 22, el vacío en la búsqueda general con su celda y el arrastre que llega al borde;
- **un defecto (P1) que abre H4:** el BAPLIE de salida (`departure_baplie_writer.dart`, líneas 64 a 71) exige la fila del listado de cada lleno cargado que no venía en el plano de llegada. Si falta, se detiene: «El contenedor cargado … no está en el listado». Con H4, un lleno cargado sin fila deja la operación sin BAPLIE de salida, y mientras H2 siga abierto, la oficina tampoco puede importar el listado después. El informe lo nombra en 8.3, pero ninguna prueba lo cubre;
- **una nota (P3):** la par se busca en el plano que se dibuja, el de carga. Si una bahía de 40 solo viene en el plano de llegada, sus mitades de 20 van en filas propias en el avance de la descarga (T-78). No es un error; se vuelve a ver con Estadísticas en `sprint-4`.

**Lo que sigue:**
- Carlos sube T-122 y esta decisión.
- Timonel hace la corrección 1 de T-122 en el mismo chat: el BAPLIE de salida con los llenos cargados sin fila, con los datos del plan de carga y una prueba roja antes.
- Después, Codex acepta T-122 con su corrección, y Carlos publica la 3.1.1 cuando termine la operación del buque.
- H2 espera la decisión de Carlos sobre las reglas; no va en la 3.1.1.

La siguiente decisión es la **10.58**.

### 10.58 · La corrección 1 de T-122, entregada y revisada: el BAPLIE de salida ya lleva los llenos sin fila; la 3.1.1 pasa a la aceptación de Codex (26-oct, 17:10)

**Timonel la entregó a las 16:58, sobre `d05bacf`** (`docs/T122-RESULTADOS.md`, sección «8bis»):
- **El arreglo:** un lleno cargado sin fila en el listado sale en la celda donde quedó, con el grupo de segmentos que le dio el plan de carga: `LOC+147` con la posición real y, tal cual, el peso, los puertos, la línea, la carga peligrosa y lo que el lector no modela. Así ya salía lo que sigue a bordo. Timonel no usó la fila armada desde el plan, porque exigiría un VGM que el plan muchas veces no trae y perdería segmentos: no se inventa nada.
- Con fila, todo sigue igual: los datos exactos salen del listado. Un vacío asignado sin fila sigue pidiendo el listado, ahora con su aviso propio: su tara y su tipo exactos solo están en la fila.
- La página dice «n llenos van con los datos del plan de carga porque no tienen fila en el listado: …».
- **Otras salidas:** ninguna exige la fila. Las exportaciones CSV, JSON y PDF y la comparación leen el viaje; la bitácora se exporta sin listado; el cierre no mira las fuentes; el avance, la validación de carga y la bandeja de cambios usan la fila solo si existe.
- **Cifras:**
  - 5 pruebas nuevas: antes del arreglo, 3 fallan con «no está en el listado»;
  - la suite, 1401 de 1401 en una corrida, y `analyze` de `lib/` y `test/` en cero;
  - la captura de la página, en la Web y en los dos temas.
- T-82 cambia de expectativa: el cargado ausente del listado sale con el plan, sin VGM inventado, y el vacío asignado sin fila sigue deteniéndose.
- Los BAPLIE sintéticos del banco llevan ahora el sobre EDIFACT completo, que la salida exige. Las capturas de T-122 se tomaron sin él y traen el aviso «faltan 4 segmentos»; no cambian el resultado.
- El informe corrige la cuenta de pruebas nuevas de T-122: 25, y 14 en el archivo de los hallazgos.

**Yov la revisó contra el disco:**
- el árbol coincide con el bloque: 8 rutas, 6 cambiadas y 2 nuevas. Lo demás de T-122 no cambia;
- el escritor hace lo que dice:
  - con fila, sale como antes;
  - sin fila, sale el grupo del plan con la posición real, y el contenedor queda en la lista de los sin fila;
  - sin grupo en el plan (un vacío asignado), se detiene con su aviso;
- la prueba de T-82 no se afloja: pide el peso del plan, que no haya VGM y la lista de los sin fila, y sigue exigiendo la detención para el vacío;
- la captura muestra la página con el aviso y «Guardar BAPLIE de salida» activo;
- **una nota (P3, de antes):** la página dice «1 contenedores a bordo en la salida». Se corrige en `sprint-4`.

**Lo que sigue:**
- Carlos sube la corrección y esta decisión, y mueve `qa-r4` al commit de la corrección en `master`.
- Codex acepta T-122 con su corrección, en los tres clientes y con datos sintéticos.
- Si pasa, Carlos publica la 3.1.1 con la sección 4 de la lista del piloto cuando termine la operación del buque.
- Después, la 3.1.1 pasa a `sprint-4`.

La siguiente decisión es la **10.59**.

### 10.59 · La aceptación de T-122 no pasa por un P2: un vacío con número en el plan se carga sin listado y con tara 0; Timonel corrige (26-oct, 18:10)

**Codex la cerró hoy a las 17:55, sobre `aa01c27`** (`docs/t122/aceptacion-codex.md`, con su evidencia en `build/t122-aceptacion/` de `baystream-qa-r4`):
- **A1 · P2 — un vacío con número en el plan de carga se carga sin listado:**
  - sin listado, «OR / últimos dígitos» ofrece un vacío que el plan de carga trae con su número, como «sin OR en el listado». El diálogo dice «Tara real: 0 kg» y deja confirmar, y queda cargado como `load_full`;
  - va contra 10.51 y el encargo de T-122: la excepción sin listado es solo para los llenos, y los vacíos siguen necesitando su fila;
  - la causa: `LoadingOperation.unlistedRows` no mira si el contenedor es lleno, y `ExportListRow.fromPlan` pone la tara en 0 cuando el plan no la trae.
- **Lo demás pasa, con pruebas propias:**
  - H1, H5 y H6;
  - H3, y Codex acepta contar «AGREGADOS» aparte de la última agencia;
  - H4 con los llenos: el movimiento sube sin la clave `order`, que las reglas publicadas aceptan. Pasa también la corrección 1: la salida conserva el grupo del plan y solo cambia `LOC+147`;
  - H7, con dedo y con mouse, con y sin zoom, en los tres clientes;
  - Codex acepta el P3 de 10.57: una bahía de 40 que solo viene en el plano de llegada no empareja las mitades del plan de carga.
- **Cifras:**
  - la suite, 1401 de 1401, en una sola corrida, sobre una copia cotejada antes de correrla;
  - `analyze` en cero en la copia limpia;
  - las compilaciones de Windows, la Web y Android salen bien, y el `version.json` de la Web dice 3.1.1 y 5;
  - una regresión de lo que usa el piloto, con datos sintéticos y sin nube, pasa: descargar, cargar, deshacer, asignar un vacío, pedir un cambio y generar la salida.
- **Dos observaciones (P3):**
  - O1: el diagnóstico de H2 tiene dos matices. `join` ignora los trozos de un tipo que el manifiesto no declara, y la frase de 8.3 de que el escritor exige la fila quedó vieja después de 8bis. El fondo del diagnóstico sigue siendo correcto;
  - O2: la Web del banco lanza un error al arrancar, que viene de leer el tamaño de un `RenderBox` todavía sin dibujar, en el recorrido del foco. La página se dibuja y todo funciona; falta saber si viene del producto o del panel del banco.

**Yov lo revisó:** el informe coincide con la huella de su manifiesto, y las 304 huellas de la evidencia coinciden. El árbol de `qa-r4` está intacto: solo se agregó el informe. A1 está en el código como dice Codex, y su captura de Windows lo muestra: «MNLU0000811 · sin OR en el listado», «Tara real: 0 kg» y «Confirmar carga» activo.

**Yov propone mantener la regla de 10.51:** sin listado, solo se cargan los llenos. Un vacío necesita su fila: de ahí sale su tara exacta, y la salida la necesita. Cargarlo con el peso del plan sería una regla nueva, y la decide Carlos. Lo que de verdad resuelve el listado que llega tarde es H2.

**Lo que sigue:**
- Carlos mueve el informe de Codex a `proyecto-baystream` y lo sube en `master`. Después sube esta decisión.
- Timonel hace la corrección 2 de T-122, en el mismo chat:
  - A1: sin listado, solo se cargan los contenedores que el plan declara llenos. Los vacíos con número y los que no traen estado necesitan su fila, en la búsqueda, en el toque de la celda y en el borrador;
  - O1: corrige 8.2 y 8.3 de su informe;
  - O2: averigua si el error viene del producto y si es nuevo de la 3.1.1. Solo si lo es, lo corrige.
- Codex reacepta A1, con la suite y `analyze`, y mira O2.
- La 3.1.1 se publica cuando pase y la operación del buque haya terminado.

La siguiente decisión es la **10.60**.

### 10.60 · La corrección 2 de T-122, entregada y revisada: sin listado solo se cargan los llenos; pasa a la reaceptación de Codex (26-oct, 18:55)

**Timonel la entregó a las 18:40, sobre `6086bb5`** (`docs/T122-RESULTADOS.md`, sección «8ter»):
- **A1:** la regla de 10.51 sigue. Sin fila en el listado, solo se cargan los contenedores que el plan declara llenos:
  - `unlistedRows` filtra los llenos;
  - `LoadingOperation.needsRow` da el motivo: «El vacío … espera el listado de la agencia: su fila trae la tara y el tipo exactos», o «… no declara lleno ni vacío en el plan»;
  - el borrador rechaza con ese motivo una fila sin OR que no sea de un lleno, aunque alguien la pase;
  - en el muelle, tocar ese vacío no abre «Confirmar carga» y avisa que espera el listado. «OR / últimos dígitos» no lo ofrece.
- **O1:** 8.2 y 8.3 del informe quedan corregidos como dijo Codex. La conclusión de H2 no cambia.
- **O2:** el error de la Web al arrancar es del panel del banco de T-122, no del producto: con nombres legibles, la pila lleva al `InkWell` de la pestaña «Banco T122», que el banco pone encima de la app. El banco de T-99, el producto sin ese panel, da cero errores al arrancar en `master` y en una copia limpia de la 3.1.0. No se toca.
- **Cifras:**
  - 3 pruebas nuevas, las 3 rojas antes del arreglo;
  - la suite, 1404 de 1404 en una corrida, y `analyze` de `lib/` y `test/` en cero;
  - 12 capturas sintéticas de la Web, en los dos temas: el vacío con número y el sin estado dan el aviso, y el lleno se carga.

**Yov la revisó contra el disco:**
- el árbol coincide con el bloque: 9 rutas, 6 cambiadas y 3 nuevas. El código hace lo que dice;
- **una cosa antes del commit:** `loading_controls.dart` quedó entero con fin de línea de Windows (CRLF), y el repositorio lo guarda con LF. El cambio real son 9 líneas, pero así el commit cambiaría las 1028. Carlos lo devuelve a LF con un comando antes de `git add`, y `git diff --stat` lo comprueba.

**Lo que sigue:**
- Carlos sube la corrección 2 y esta decisión, y mueve `qa-r4` al commit de la corrección.
- Codex reacepta A1 en los tres clientes, con la suite, `analyze` y la regresión, y comprueba O2 con su propio banco.
- Si pasa, Carlos publica la 3.1.1 cuando termine la operación del buque.

La siguiente decisión es la **10.61**.

### 10.61 · T-122 aceptada: la 3.1.1 queda lista para publicar (26-oct, 20:00)

**Codex la reaceptó a las 19:39, sobre `cf07a17`** (`docs/t122/reaceptacion-codex.md`, con su evidencia en `build/t122-reaceptacion/` de `baystream-qa-r4`):
- **A1, cerrado en los tres clientes:**
  - sin listado, ni el vacío con número ni el contenedor sin estado se ofrecen, y tocar su celda avisa que esperan el listado;
  - el borrador los rechaza aunque se le pase una fila que diga «lleno»;
  - el lleno sin fila se sigue cargando, sin la clave `order`, y su salida conserva el grupo del plan (corrección 1);
  - con el listado importado, el vacío se carga como antes, con su OR y su tara de 3900 kg.
- **O1, corregido:** 8.2 y 8.3 del informe de Timonel dicen lo que pasa en el código.
- **O2, aislado:** el banco de T-99 compilado con la 3.1.1 y con la 3.1.0 arranca sin errores. El error es del panel del banco de T-122, no del producto.
- **Cifras:**
  - la suite, 1404 de 1404, en una sola corrida, sobre una copia cotejada antes de correrla;
  - `analyze` en cero en la copia limpia;
  - siete pruebas propias, aprobadas en su primera corrida, y la regresión de la aceptación anterior.

**Yov lo revisó:** el informe coincide con la huella de su manifiesto, y las 198 huellas de la evidencia coinciden. El árbol de `qa-r4` está intacto: solo se agregó el informe. El resumen de la suite dice una sola ejecución, con 1404 éxitos y ninguna omitida.

**Una corrección a 10.60:** el commit no habría cambiado las 1028 líneas de `loading_controls.dart`. La carpeta de Codex lo muestra: sus archivos salen con CRLF y en el repositorio están con LF, así que el Git de Carlos convierte el fin de línea al sacar los archivos y al guardarlos. El paso de normalizar no hizo daño: `cf07a17` cambió 9 archivos, con 465 líneas añadidas y 41 quitadas.

**Con esto:**
- **T-122 queda aceptada.** La 3.1.1 es `master` con el informe de Codex encima, y se etiqueta `v3.1.1`.
- **Carlos la publica cuando termine la operación del buque**, con la sección 4 de la lista del piloto y la versión nueva:
  - Windows: el MSIX 3.1.1.0;
  - Android: el AAB 3.1.1 (5), en la prueba interna de Play;
  - la Web: la 3.1.1 (5), con `firebase deploy --only hosting --project baystream-app`.
- **Sigue abierto:**
  - H2, que necesita tocar las reglas: decide Carlos con la propuesta de la sección 8;
  - llevar la 3.1.1 a `sprint-4`, para la 3.2.0;
  - lo anotado para `sprint-4`: la regla de la par en Estadísticas, los vacíos asignados en las alertas, la comparación y las estadísticas, y «1 contenedores» en la salida.
- La meta sigue: la 3.2.0 publicada a más tardar el 4-nov, y la presentación final el 7-nov.

La siguiente decisión es la **10.62**.

### 10.62 · La 3.1.1, publicada en los tres clientes (26-oct, 20:15)

**Carlos la publicó y avisó a las 20:09**, con la sección 4 de la lista del piloto y la versión nueva. Yov revisó la carpeta:
- **Git:** `master` en `34d8838`, igual que `origin/master`, con la etiqueta `v3.1.1` («BayStream 3.1.1, los hallazgos del piloto (T-122)»).
- **Windows:** `BayStream_3.1.1.0.msix`, de 25,3 MB, con la identidad 3.1.1.0 de `CN=BayStream` y el SHA-256 `7617CC8889BCDD44C46964772B2DF48D50D0D8C2EA1E335E5F7E134CCE20D73E`, el mismo de su `.sha256`. El MSIX 3.1.0.0 sigue en `build\t93`, para volver.
- **Android:** el AAB de 51,1 MB, con `versionName` 3.1.1 (compilación 5), para la prueba interna de Play. El Honor se actualiza por el enlace de la prueba.
- **Web:** la compilación dice 3.1.1 y 5 en `version.json`, con 57 archivos, como la 3.1.0.

**Lo que sigue:**
- Llevar la 3.1.1 a `sprint-4`, para la 3.2.0. Carlos mezcla `master` en `sprint-4`; Timonel resuelve lo que choque con el rediseño, y Codex lo acepta.
- H2: decide Carlos, con la propuesta de la sección 8 de `docs/T122-RESULTADOS.md`.
- Lo anotado para `sprint-4` en 10.61.
- La 3.2.0 publicada a más tardar el 4-nov, con la lista del piloto al día, y la presentación final el 7-nov.

La siguiente decisión es la **10.63**.

### 10.63 · T-123: la 3.1.1 entra en `sprint-4` con una mezcla; Timonel resuelve dos conflictos (26-oct, 20:25)

**Carlos lo decidió a las 20:11:** la 3.1.1 pasa a `sprint-4` ya, para que la 3.2.0 de la presentación lleve los arreglos del piloto. Es **T-123**.

**Cómo:**
- Carlos mezcla `master` en `sprint-4` con `git merge --no-ff --no-commit master`, en la carpeta del rediseño. Así la historia queda unida y, cuando la 3.2.0 vuelva a `master`, la 3.1.1 ya estará adentro.
- Timonel resuelve los conflictos y adapta lo de T-122 al rediseño, con Flutter. No ejecuta git que escriba.
- Carlos cierra la mezcla con el commit, y Codex la acepta.

**Lo que Yov vio al simular la mezcla en una copia aparte**, fuera de las carpetas de Carlos:
- la base común es `38965b8`. Desde ahí, `master` cambió 40 archivos y `sprint-4`, 79; los dos tocaron cinco;
- **dos conflictos, de un trozo cada uno:**
  - `vessel_overview_page.dart`: una importación. Cada lado agregó la suya, y quedan las dos;
  - `loading_controls.dart`: el resumen del plan de carga y `busquedaDeCarga`. El rediseño lo hizo en fichas (14.7) y con la variante de solo icono (10.40); la 3.1.1 dejó «OR / últimos dígitos» disponible sin listado y agregó el aviso de que los vacíos esperan el listado. Se queda el diseño del rediseño, con el comportamiento de la 3.1.1;
- **tres archivos se mezclaron solos, pero los dos lados los tocaron:** `bay_plan_view.dart` (H6), `loading_plan_controls.dart` (H4) y `plan_drag_confirmation.dart` (H7). Hay que revisarlos por dentro. En el rediseño la columna central se desplaza entera (T-117), así que H7 se comprueba en esa columna, en el teléfono y en la oficina.

**Lo que no cambia:**
- el comportamiento de la 3.1.1, el aceptado en 10.61, y el rediseño aceptado en 10.46 y 10.55;
- lo de `domain/` y `data/` que entra es el de la 3.1.1, autorizado en 10.52 y 10.56. Nada más del dominio;
- la regla de la par en Estadísticas, y lo demás anotado en 10.61, van en la tarea siguiente, no en esta mezcla.

**Las cifras esperadas:** el piso de `sprint-4` es 1783, y la 3.1.1 trae 33 pruebas más. Se esperan unas 1816.

**Lo que sigue:**
- Carlos sube esta decisión y hace la mezcla.
- Timonel hace T-123 en un chat nuevo en la carpeta del rediseño, con Fable 5.1.
- Codex la acepta.
- Después: la regla de la par en Estadísticas y lo anotado en 10.61, y la 3.2.0 a más tardar el 4-nov.

La siguiente decisión es la **10.64**.

### 10.64 · T-123 entregada y revisada: la 3.1.1 ya está dentro del rediseño; pasa a la aceptación de Codex (26-oct, 21:35)

**Timonel la entregó a las 21:22** (`docs/T123-RESULTADOS.md`), con la mezcla abierta sobre `e4156ad` y `master` en `34d8838`:
- **Los dos conflictos:**
  - en `vessel_overview_page.dart` quedan las dos importaciones;
  - en `loading_controls.dart` se queda el diseño del rediseño (las fichas de 14.7 y la variante de solo icono de 10.40), con el comportamiento de H4: «OR / últimos dígitos» solo espera a que el plan esté leído, nunca al listado. El aviso de H4 pasa a una ficha de revisar en `resumen_del_modo.dart`: «Sin listado de agencia: los llenos se cargan por su número; los vacíos esperan el listado».
- **Lo que se mezcló solo, revisado por dentro:** H6 cayó bien en la rejilla del rediseño, y H4 en la tira del teléfono bajo. H7 encaja con la columna que se desplaza: en la oficina, el desplazable vertical más cercano a la celda es la columna entera, y es lo que se desplaza. Ningún otro choque.
- **Las pruebas:** las de T-122 pasan con un solo cambio. Las de pantalla montan el plano a 360 × 800, el teléfono del muelle, porque a 800 dp el plano suelto del rediseño se arma como oficina. Ninguna prueba del rediseño esperaba la regla vieja, y ninguna se afloja. Una prueba nueva, `t123_mezcla_test.dart`, con 5 casos: H4 en la oficina y en el teléfono, y H7 en la columna de la oficina, con dedo y con mouse.
- **Cifras:**
  - la suite, 1821 de 1821 en una corrida (1783, más 33 de la 3.1.1 y 5 de T-123), y `analyze` en cero;
  - 103 capturas sintéticas en los dos temas: la Web 40, Windows 23 por UIA, sin mouse, y el emulador 40.
- **Dos notas de Timonel:**
  - en el emulador, H7 necesitó tres corridas: en las dos primeras no se levantó la celda, y no aisló la causa;
  - con la 21 elegida, la ficha de la bahía dice «Bahía 22: 7 contenedores, 1 celda reservada, 57.7 t…; por cargar cub. 27». Las cifras son de la 21, y el rótulo y lo pendiente, del grupo de la 22. Lo deja para la tarea siguiente.

**Yov la revisó contra el disco**, comparando la carpeta con la misma mezcla hecha en una copia aparte:
- fuera de lo que la mezcla deja listo solo, cambian exactamente las 10 rutas del bloque: los dos conflictos, cuatro archivos ajustados y cuatro nuevos. No quedan marcas de conflicto, y `SPRINT-4.md` no se tocó;
- la resolución hace lo que dice: el plano y la Lista usan lo que va a bordo con los vacíos asignados, «OR / últimos dígitos» espera solo al plan, y los rótulos de las filas sin OR usan el número;
- el cambio de las pruebas de T-122 es solo el tamaño de la vista: siguen probando el muelle, y la oficina la prueba T-123;
- al cerrarse, el commit de la mezcla tiene que dar, contra `e4156ad`, 45 archivos con 4882 líneas añadidas y 166 quitadas;
- **la nota de la ficha es un P2 de presentación para antes de la 3.2.0:** el rótulo dice una bahía y las cifras son de otra. Va en la tarea siguiente, con la regla de la par en Estadísticas.

**Lo que sigue:**
- Carlos cierra la mezcla con el bloque de Timonel y sube esta decisión, y mueve `qa-r4` al commit de la mezcla.
- Codex acepta T-123: la 3.1.1 dentro del rediseño, en los tres clientes, sin romper las entregas 1 y 2. Mira también si H7 en el emulador falla por el instrumento o por el producto.
- Después, T-124: la regla de la par en Estadísticas y en la ficha de la bahía, y lo anotado en 10.61.

La siguiente decisión es la **10.65**.

### 10.65 · T-123 aceptada: la 3.1.1 ya vive en el rediseño; sigue T-124 y después la 3.2.0 (26-oct, 23:45)

**Codex la aceptó a las 23:29, sobre `b6a8d95`** (`docs/t123/aceptacion-codex.md`, con su evidencia en `build/t123-aceptacion/` de `baystream-qa-r4`):
- la 3.1.1 conserva en el rediseño H1, H3, H4 con sus dos correcciones, H5, H6 y H7, en los tres clientes, y el rediseño de las entregas 1 y 2 no se rompió: las fichas, la variante de solo icono y «Acciones» con su nombre en Windows;
- **H7 pasa**, con y sin zoom. Las dos corridas de Timonel en que la celda no se levantó son del instrumento (O1, P3): su conductor del emulador puede dejar un contacto activo y reutilizar su identificador, y con eso la celda ya no se levanta. Con el contacto liberado, el producto la levanta y suelta en la celda correcta;
- **la ficha de la bahía queda como P2 para T-124**, antes de la 3.2.0: con la 21 elegida dice «Bahía 22» con las cifras de la 21, y la 22 de verdad tiene 11 contenedores;
- O2 (P3): el error de arranque es del panel del banco de T-122, como ya se sabía;
- **cifras:** la suite, 1821 de 1821, en una sola corrida, sobre una copia cotejada; `analyze` en cero.

**Yov lo revisó:** el informe coincide con la huella de su manifiesto, y las 704 huellas de la evidencia coinciden. El árbol de `qa-r4` está intacto: solo se agregó el informe. El resumen de la suite dice una sola ejecución, con 1821 éxitos.

**Con esto:**
- **T-123 queda aceptada.** El piso de `sprint-4` sube a **1821**.
- **T-124 · La regla de la par en la presentación**, con Timonel:
  - P2: la ficha de la bahía dice lo de la bahía que se ve con su número, y lo del grupo con el rótulo de su par;
  - Estadísticas cuenta cada impar con la par que la cubre, con la regla de `reference_bay.dart`, como el avance (10.53 y 10.56);
  - P3: «1 contenedores» en la página del BAPLIE de salida;
  - O1: el conductor del arrastre del emulador suelta siempre el contacto;
  - solo una propuesta, sin código: si las alertas, la comparación de viajes y las estadísticas deben contar los vacíos asignados, como ya lo hacen la Lista y las búsquedas.
- **Después, T-125 · La 3.2.0:**
  - la versión 3.2.0, compilación 6, y el MSIX 3.2.0.0;
  - la lista del piloto al día (E1.10);
  - la mezcla de `sprint-4` en `master`, con la aceptación de Codex;
  - la publicación, a más tardar el 4-nov.
- La entrega 3 (T-119 y T-120) va en la 3.2.1 (10.38), y H2 espera la decisión de Carlos.

La siguiente decisión es la **10.66**.

### 10.66 · T-124 entregada y revisada: la regla de la par llega a la ficha de la bahía y a Estadísticas; pasa a la aceptación de Codex (27-oct, 01:00)

**Timonel la entregó sobre `2cce28f`, y Carlos la pasó a las 00:49** (`docs/T124-RESULTADOS.md`, con la evidencia en `build/t124/`, fuera de Git):
- **P2, la ficha de la bahía:** dice lo de la bahía que se ve con su número, y lo del grupo con el rótulo de su par. Con la 21 elegida: «Bahía 21: 7 contenedores, 1 celda reservada, 57.7 t, tapas sin declarar; grupo 22 (21, 22 y 23), por cargar cub. 27, bod. 0». Una bahía que no se cuenta con otra sigue como antes. El texto de cada caso, en la oficina y en el teléfono, en Carga y en Contenido, está en DESIGN 14.7.
- **Estadísticas con la regla de la par:** cada impar se cuenta con la par vecina que la cubre, con `referenceBay`, como el avance. La silueta y «Ver como tabla» llevan el número de la par, y tocar una columna abre esa bahía en el plano. `T100_LLEGADA` da tres bahías (02, 06 y 10), cada una en su tope y con el casco centrado; el sintético de 977, 24. DESIGN 15 está al día.
- **P3:** «1 contenedor a bordo en la salida».
- **O1:** el conductor del arrastre del emulador usa un contacto nuevo en cada gesto, lo suelta siempre y comprueba que la celda se levantó antes de llevarla al borde.
- **Cifras:**
  - la suite, 1832 de 1832 en una corrida: las 1821 más 11 de `t124_par_test.dart`, 9 rojas antes del arreglo y 2 de guarda. `analyze` en cero;
  - las 3 pruebas del conductor, rojas antes del arreglo;
  - 65 capturas sintéticas en los dos temas: la Web 24, Windows 17 por UIA y el emulador 24.
- **Siete pruebas de T-121 cambian de expectativa**, porque esperaban una columna por número de bahía. Las que medían el ancho y el desplazamiento usan ahora bahías pares sueltas, nueve y 72: con la regla nueva, la llegada son tres columnas y el 977, 24.

**Yov la revisó contra el disco:**
- contra `2cce28f` cambian exactamente las 15 rutas del bloque: 8 modificadas y 7 nuevas. No se tocaron `domain/`, `data/`, `lib/main.dart`, los congelados, `pubspec.*` ni `SPRINT-4.md`;
- lo que Timonel dejó fuera no tiene cambios de contenido: `test/t114_fase3_correccion_test.dart` y tres archivos de `windows/flutter/` son idénticos al commit, y `windows/flutter/CMakeLists.txt` solo difiere en los finales de línea. Se queda fuera;
- las pruebas de T-121 no se aflojaron: siguen comprobando que las bahías suman todo el viaje, y la de T-117 ahora pide la lista exacta (02 y 06), no solo que contenga las vecinas;
- el código hace lo que dice. Estadísticas agrupa con `referenceBay` sobre las bahías del viaje y de las posiciones, y «Bahías con carga» cuenta grupos. La lista del grupo en la ficha sale de las posiciones del plan de carga, que trae también lo que sigue a bordo y las reservas, así que coincide con el agrupamiento del avance.

**El punto 5, la propuesta de los vacíos asignados, lo decide Carlos:**
- Estadísticas: sí, en una tarea propia, con una ficha que diga cuántos vacíos asignados incluye;
- las alertas: no así, porque sumar solo los vacíos mezcla lo planificado con lo hecho. Si se quiere, que evalúen el estado completo de la salida, en una vista aparte;
- la comparación de viajes no cambia: la salida ya trae los vacíos asignados;
- **Yov recomienda dejarlo para después de la 3.2.0**, porque cambia las cifras mientras dura la operación.

**Lo que sigue:**
- Carlos sube el bloque de Timonel y esta decisión, y mueve `qa-r4` al commit de esta decisión.
- Codex acepta T-124 en los tres clientes, sin romper T-123 ni las entregas 1 y 2.
- Después, T-125: la 3.2.0, a más tardar el 4-nov.

La siguiente decisión es la **10.67**.

### 10.67 · T-124 aceptada con observaciones: la regla de la par llega a la 3.2.0; sigue T-125 (27-oct, 13:00)

**Codex la aceptó sobre `e3ce0fc`** (`docs/t124/aceptacion-codex.md`, con su evidencia en `build/t124-aceptacion/` de `baystream-qa-r4`):
- **P2, la ficha de la bahía, pasa** en Carga y en Contenido, en la oficina y en el teléfono. Con la 21, la 22 y la 23 elegidas, la ficha empieza por la bahía que se ve y nombra «grupo 22 (21, 22 y 23)». Las cifras de cada bahía son las suyas: la 21 tiene 7 contenedores, y la 22, 11.
- **La par sin carga propia también pasa:** en un caso sintético, con un 40 de paso en la 22 y carga en la 21 y la 23, el grupo nombra las tres bahías en las 12 escenas de release.
- **Estadísticas pasa:** `T100_LLEGADA` da tres columnas (02, 06 y 10), con 964 950 kg en total, y el sintético de 977, 24 columnas que siguen sumando 977. Codex calculó los grupos esperados por su cuenta, sin el formateador de la app.
- **P3 y O1 pasan:** «1 contenedor a bordo en la salida», y el plural con dos. El conductor nuevo suelta el contacto aunque el gesto falle, y en el emulador H7 levanta y suelta en la celda correcta.
- **Sin regresiones** en los tres clientes: H4, H6 y H7 de T-123, las fichas, la variante de solo icono y «Acciones» con su nombre en Windows. Las siete pruebas de T-121 no se aflojaron.
- **Cifras:** la suite, 1832 de 1832 en una sola corrida, sin omitidas; `analyze` en cero.

**O-124-1 (P3, de antes de T-124):** en la vista de la par, todas las celdas tomadas por veintes de las impares vecinas llevan la misma clave, `ValueKey('neighbor-twenty')`, en `bay_plan_view.dart`. Con dos de esas celdas en la misma fila del dibujo, Flutter avisa en debug de claves duplicadas. Viene de T-106 (Sprint 3) y también está en la 3.1.1 publicada. En release, la escena de Codex pasa sus 12 comprobaciones, pero eso no prueba todas las combinaciones.

**Yov lo revisó:** el informe coincide con la huella de su manifiesto, y las 675 huellas de la evidencia coinciden. El árbol de `qa-r4` está intacto: solo se agregó el informe. El resumen de la suite dice una sola ejecución, con 1832 éxitos y ninguna omitida.

**Con esto:**
- **T-124 queda aceptada.** El piso de `sprint-4` sube a **1832**.
- **Sigue T-125 · La 3.2.0** (10.65), a más tardar el 4-nov. Yov recomienda sumarle O-124-1: una clave distinta por celda, con una prueba roja antes. Decide Carlos.
- El punto 5 de T-124 (los vacíos asignados) sigue esperando la decisión de Carlos. Yov recomienda dejarlo para después de la 3.2.0.

La siguiente decisión es la **10.68**.

### 10.68 · Carlos decide: la 3.2.0 lleva los vacíos asignados en Estadísticas y O-124-1; T-125 va a Timonel (27-oct, 13:10)

**Carlos lo decidió a las 13:05:**
- **El punto 5 de T-124 entra en T-125, antes de publicar.** Estadísticas cuenta los vacíos asignados como la Lista y las búsquedas (`aboardContainersProvider`), con una ficha que dice cuántos incluye. Las alertas y la comparación de viajes no cambian, como propuso Timonel. Yov recomendaba dejarlo para después de la 3.2.0, porque mueve las cifras durante la operación.
- **O-124-1 entra en T-125:** una clave distinta por celda, con una prueba roja antes.

**T-125 · La 3.2.0**, con Timonel, en la carpeta del rediseño:
1. Estadísticas con los vacíos asignados: la fila «Estadísticas» de la sección 5 de `docs/T124-RESULTADOS.md`.
2. O-124-1.
3. La versión 3.2.0, compilación 6, y el MSIX 3.2.0.0.
4. La lista del piloto al día para la 3.2.0 (E1.10): la sección 4 con las versiones nuevas, la mezcla de `sprint-4` en `master` con la etiqueta `v3.2.0`, y la vuelta a la 3.1.1 en 4.5.

**Después:** Codex acepta la candidata en los tres clientes; Carlos mezcla en `master`, etiqueta y publica con la sección 4, a más tardar el 4-nov.

La siguiente decisión es la **10.69**.

### 10.69 · T-125 entregada y revisada: la candidata 3.2.0 pasa a la aceptación de Codex (27-oct, 19:50)

**Timonel la entregó sobre `9738be1`, y Carlos la pasó a las 19:44** (`docs/T125-RESULTADOS.md`, con la evidencia en `build/t125/`, fuera de Git):
- **Estadísticas cuenta los vacíos asignados** como la Lista. Las dos leen un provider nuevo, `assignedEmptiesProvider`, y `aboardContainersProvider` lo suma al archivo. Cada vacío asignado suma un contenedor, con su tara y su tipo, en su bahía de referencia, su puerto y su naviera.
- **La ficha y la fila:** debajo de la protagonista sale «Incluye: 1 vacío asignado a una celda reservada, que el archivo no trae» (con más de uno, «Incluye: N vacíos asignados a celdas reservadas, que el archivo no trae»), y la tabla gana la fila «Vacíos asignados». Sin vacíos asignados, la página es la de antes. Las alertas y la comparación de viajes no cambian, y `domain/` no se tocó. El texto está en DESIGN 15.13.
- **O-124-1:** la clave es `neighbor-twenty-<posición>`. La prueba con el caso de Codex fallaba antes del arreglo con «Duplicate keys found», en Contenido y en Carga.
- **La versión:** `3.2.0+6` y el MSIX `3.2.0.0`. `pubspec.lock` no cambia.
- **La lista del piloto (E1.10):**
  - el encabezado dice qué lleva la 3.2.0;
  - la sección 4 trae las versiones y la mezcla con `v3.2.0`;
  - en 4.5, la vuelta a la 3.1.1: en Android, con un AAB 3.1.2 de `versionCode` 7, porque Play no deja bajar;
  - los rótulos de las secciones 0 a 3 y 5 están cotejados con el código;
  - el paso nuevo 1.16 mira Estadísticas durante la carga.
- **Cifras:**
  - la suite, 1841 de 1841 en una corrida: las 1832, 8 de `t125_320_test.dart` y 1 de T-121. `analyze` en cero;
  - la candidata compila en release con 3.2.0 (6) en los tres clientes, sin la configuración privada;
  - 30 capturas sintéticas: la Web 12 y el emulador 18. De Windows, solo la compilación.

**Yov la revisó contra el disco:**
- contra `9738be1` cambian exactamente las 16 rutas del bloque: 12 modificadas y 4 nuevas. No cambian `pubspec.lock`, `domain/`, `data/`, `lib/main.dart`, los congelados ni `SPRINT-4.md`;
- lo que Timonel deja fuera ya estaba antes de la tarea: `test/t114_fase3_correccion_test.dart` y `windows/flutter/`, solo con finales de línea distintos, y los 129 archivos de evidencia de `docs/t117/entrega1/`, sin versionar;
- el código hace lo que dice, y es corto. El provider nuevo devuelve lo mismo que antes sumaba la Lista. Estadísticas recorre el archivo y los asignados, y `total` es `delArchivo` más `vaciosAsignados`. La clave del plano lleva la posición;
- las pruebas no se aflojaron. La de T-106 sigue pidiendo exactamente tres sombras en la 04, y ahora cada una con su clave y su rótulo. Las de «las cifras cuadran» de T-121 agregan `delArchivo` y `vaciosAsignados`, y un caso con dos vacíos asignados;
- la evidencia cuadra:
  - la última suite (1841, «All tests passed!») corrió después del último cambio de código;
  - los registros rojos dicen «Expected: '3' Actual: '2'» y «Duplicate keys found»;
  - `version.json` dice 3.2.0 y 6, el `.exe` dice 3.2.0+6 y el manifiesto del AAB dice `versionCode` 6 y `versionName` 3.2.0;
  - las huellas coinciden con `build/t125/11-huellas-candidata.txt`;
- **en la pantalla:** en la Web, con un vacío asignado, 26 a bordo y la ficha en singular; con dos, 27, la ficha en plural y la fila «Vacíos asignados» en la tabla. En el teléfono, la ficha cabe en dos líneas, en los dos temas;
- la sección 4 de la lista se puede seguir tal cual:
  - antes de mezclar comprueba la rama, `34d8838`, que `master` está dentro de `sprint-4` y la punta aceptada;
  - la Web se publica solo con `--only hosting --project baystream-app`;
  - la vuelta deja la carpeta en la etiqueta, sin commits.

**Lo que sigue:**
- Carlos sube el bloque de Timonel y esta decisión, y mueve `qa-r4` a la punta de `sprint-4`.
- Codex acepta T-125 y la candidata 3.2.0 en los tres clientes: los vacíos asignados en Estadísticas, O-124-1 y las versiones, sin romper T-124, T-123 ni las entregas 1 y 2.
- Después, Carlos mezcla en `master`, etiqueta `v3.2.0` y publica con la sección 4, a más tardar el 4-nov.

La siguiente decisión es la **10.70**.

### 10.70 · La Expo de pruebas del curso va con la 3.2.0: T-126 a Timonel, en su propia rama (27-oct, 21:00)

**La exposición del curso de Aseguramiento de la Calidad no se hizo el sábado 24: es el sábado 31-oct.** Carlos quiere hacerla mejor, y lo decidió poco antes de las 21:00:
- la app que se ve moverse es la 3.2.0 rediseñada, no la v3.0 de `baystream-pruebas`;
- Firebase en dos niveles: primero la prueba en memoria (`fake_cloud_firestore`) y después el emulador de Firestore con las reglas;
- Yov arma las diapositivas, con los videos de Blender de fondo.

**T-126 · La Expo de pruebas en la 3.2.0**, con Timonel:
- **Dónde:** `C:\Proyectos\baystream-expo`, en la rama `expo-pruebas`, que Carlos crea desde `sprint-4` con T-125 y estas decisiones. Es una excepción a «no cambies de carpeta», como T-122. Nada de esa rama entra en `sprint-4` ni en `master`: es material del curso.
- **1. Las 21 pruebas de T-116,** traídas de `pruebas-curso` a la 3.2.0 sin aflojarlas: `test/curso/` y `tool/cobertura_html.py`. `fake_cloud_firestore` 4.2.0 fija, con `equatable` 2.1.0, como en 10.12; si se mueve otro paquete, Timonel se detiene.
- **2. La prueba que se ve moverse:** con `integration_test`, abre la 3.2.0 completa en Windows, sin nube y con datos sintéticos, y la maneja sola, con pausas que se puedan seguir. Abre el plano, recorre bahías, busca un contenedor, registra descargas, deshace una y mira el avance y Estadísticas. Comprueba cada paso y termina en verde.
- **3. Rojo → verde:** una prueba que falla a propósito solo con un interruptor (`--dart-define`), sin editar archivos en vivo.
- **4. Firebase en dos niveles:** las 3 pruebas de RF-032 en memoria, y el emulador de Firestore con su consola y las baterías de reglas (69 y 25 casos), en un proyecto `demo-` que no existe en la nube.
- **5. Las cifras:** la suite completa, `analyze` y la cobertura con su reporte HTML, sobre la 3.2.0.
- **6. El guion de la demo:** los comandos en orden, cuánto tarda cada uno, qué se ve y qué hacer si algo falla; y capturas para las diapositivas.
- **Reglas:** no toca `lib/` ni `lib/main.dart`, ni Firebase de producción, y no se publica nada. Flutter solo con la luz verde de Carlos: Codex acepta T-125 en `qa-r4`, y en la máquina corre un Flutter a la vez.

**Las diapositivas las arma Yov en PowerPoint**, porque así los videos de Blender corren de fondo sin internet. El guion de 14 diapositivas del 22-oct se pone al día con la 3.2.0 y estas demos.

**El orden de la semana:**
- Codex acepta T-125.
- Timonel escribe T-126 desde ya y corre Flutter cuando Codex termine.
- Carlos ensaya la Expo el viernes y expone el sábado 31-oct.
- La 3.2.0 se publica igual, a más tardar el 4-nov.

La siguiente decisión es la **10.71**.

### 10.71 · T-125 aceptada con observaciones: la 3.2.0 queda lista para la sección 4 de la lista del piloto (28-oct, 03:10)

**Codex la aceptó a las 02:58, sobre `d41ad8c`** (`docs/t125/aceptacion-codex.md`, con su evidencia en `build/t125-aceptacion/` de `baystream-qa-r4`):
- **P1, Estadísticas con los vacíos asignados, pasa** en los tres clientes, en release. Con la entrada de T-122, a bordo pasa de 25 a 26 y a 27, y vuelve a 26 al deshacer la OR 12; la Lista y Estadísticas dicen lo mismo en cada paso. Codex calculó por su cuenta los pesos (380 000, 382 185, 386 085 y 383 900 kg) y los grupos 22 y 26, sin el formateador de la app. La ficha sale en singular y en plural, la fila «Vacíos asignados» dice 1, 2 y 1, y sin asignados no aparece ninguna de las dos. Las dos alertas y la comparación de viajes no cambian.
- **P2, O-124-1, pasa:** en su caso propio, las dos sombras de la 22 llevan cada una su clave (`neighbor-twenty-0220282` y `neighbor-twenty-0220482`), sin «Duplicate keys» en debug ni en release. La prueba de T-106 sigue pidiendo exactamente tres sombras en la 04.
- **P3, las versiones, pasa:** la Web dice 3.2.0 y 6, y T-92 aprueba sus 57 archivos; el `.exe` dice 3.2.0+6, y el manifiesto del AAB, `versionCode` 6 y `versionName` 3.2.0. Las tres se compilaron desde el `lib/main.dart` original, sin la configuración privada. `pubspec.*` no cambia.
- **P4, la lista del piloto, pasa:** Codex revisó la sección 4 comando por comando, sin ejecutarla, y no encontró nada que corregir. `master`, `origin/master` y `v3.1.1` siguen en `34d8838`, y `master` está dentro de `sprint-4`. Los cinco documentos de Carlos no están en lo que entra. Para volver atrás, Windows tiene el MSIX 3.1.1.0 con su huella, y Android pide un AAB 3.1.2 con `versionCode` 7.
- **Sin regresiones** en los tres clientes: T-124, `T100_LLEGADA` (964 950 kg), el sintético de 977 (24 columnas), H4, H6, H7 y las entregas 1 y 2.
- **Cifras:** la suite, 1841 de 1841 en una sola corrida, sin omitidas; `analyze` en cero; y 109 sondas propias más, aprobadas.

**Las dos observaciones son P3:**
- **O1:** el error de arranque del banco de la Web de T-122, el mismo de T-123 y T-124. Es del banco, no del producto.
- **O2:** el alcance de lo nativo. La matriz completa de anchos, temas y letra se corrió en widgets y en Chrome; Windows y Android aportan muestras y las secuencias completas. H7 en Windows lo hizo Carlos con la mano, porque la herramienta no sostiene la pulsación larga: soltó en el nivel 82, y el intercambio se canceló. En el emulador, `altoDp: 800` es una etiqueta vieja del conductor: la pantalla fue de 360 × 640 dp.

**Yov lo revisó:** el informe coincide con la huella de su manifiesto, y las 795 huellas de la evidencia coinciden. El árbol de `qa-r4` está intacto: los 1917 archivos de `d41ad8c` siguen iguales y solo se agregó el informe. El resumen de la suite dice una sola ejecución, con 1841 éxitos y ninguna omitida.

**Con esto:**
- **T-125 queda aceptada, y con ella la candidata 3.2.0.** El piso de `sprint-4` sube a **1841**.
- Carlos mueve el informe a la carpeta del rediseño y lo sube con esta decisión, antes de mover `qa-r4` otra vez.
- **La 3.2.0 se publica con la sección 4 de `docs/piloto/LISTA-PILOTO.md`**, a más tardar el 4-nov: primero la mezcla y la etiqueta `v3.2.0` desde `C:\Proyectos\proyecto-baystream` (4.1), y después Windows, Android y la Web (4.2 a 4.4). Las compilaciones son de Flutter, así que van cuando Timonel no esté corriendo T-126.
- O1 queda para una tarea del banco, después de la 3.2.0.

La siguiente decisión es la **10.72**.

### 10.72 · Una limpieza de disco borró evidencias de `%TEMP%` (28-oct, 03:10)

**Qué pasó.** Para hacer espacio para T-126, Yov le pasó a Carlos una limpieza de `%TEMP%`: borrar lo que tuviera más de 7 días. Carlos la corrió el 27-oct a las 22:41. Además de carpetas viejas, borró los archivos viejos de dentro de carpetas nuevas. Yov no revisó antes qué había ahí. `Remove-Item` no pasa por la papelera, así que no se recupera.

**Lo que se perdió:**
- **T-99, Fase B:** los 404 archivos originales de Timonel en `%TEMP%\t99-fase-b-33404a5\` (20,4 MB): `ram`, `ram-android`, `rendimiento-b`, `anchos-windows`, `anchos-web`, `reconstrucciones`, `capas`, `codigo`, `modulos` y `documentacion-resumen`. Solo quedó el zip del SDK de Firebase.
- **T-98, Fase B:** de `%TEMP%\t98-b-33404a5-20oct\`, lo anterior al 20-oct a las 22:41: `censos\`, `sintetico-tanda\` y el `.etl` original de `tanda\tls-01\`. Quedan el `t98-tls.pcapng` que salió de ese `.etl` y las rondas `sin-red-*` y `tls-02`, que no se tocaron.
- **T-100:** de `%TEMP%\t100-33404a5-20oct\`, los archivos de trabajo del 20-oct. El manual y sus 103 capturas están en el repo.
- Objetos viejos del `.git` de la copia limpia de la aceptación de T-113, que no eran evidencia.
- No se sabe si quedaban carpetas más viejas, del Sprint 3: si las había, se borraron enteras. La limpieza liberó 0,1 GB en total.

**Lo que no cambia:**
- Las cifras, los dictámenes y las aceptaciones de T-98, T-99 y T-100: están en el repo.
- La auditoría de Codex de T-99, en `%TEMP%\t99acc-33404a5-21oct\`: tiene la huella SHA-256 de cada uno de los 404 archivos (`evidencias-timonel-inventario.json`), las lecturas de RAM por corrida, los tiempos recalculados y su repetición de una fila de cada RNF, que también está en `build\t99acc` de `proyecto-baystream`.
- El producto, el repo, las pruebas y los archivos H5 no se tocaron.
- Varias rutas de `%TEMP%` que citan esos informes ya no existen o están incompletas; esta decisión dice por qué.

**Desde ahora:**
- en `%TEMP%` no se borra por fecha: solo lo que se revisó y se sabe qué es;
- Yov propone sacar de `%TEMP%` las evidencias que quedan a `C:\Proyectos\evidencia\`, fuera del repo y con los mismos nombres, cuando termine T-126. Decide Carlos.

La siguiente decisión es la **10.73**.

### 10.73 · T-126 entregada y revisada: la Expo de pruebas corre en la 3.2.0 (28-oct, 10:55)

**Timonel la entregó a las 10:40, sobre `d41ad8c`** (`docs/T126-RESULTADOS.md`, con la evidencia y las capturas en `build/expo/` de `baystream-expo`, fuera de Git):
- **Las 21 pruebas de T-116 corren en la 3.2.0 sin adaptarlas:** los tres archivos de `test/curso/` y `tool/cobertura_html.py` son byte por byte los de `pruebas-curso`. Con la de rojo → verde son 22 de 22.
- **Rojo → verde con un interruptor,** sin editar nada en vivo: con `EXPO_ROJO=true`, la prueba de CSQU305438 falla con «Expected: <4> Actual: <3>» y un motivo que dice que es a propósito; sin él, pasa.
- **La prueba que se ve moverse:** `integration_test/expo_recorrido_test.dart` abre la app del producto en Windows, sin nube y con `T100_LLEGADA.edi` (byte por byte el de `tool/t100_sintetico.dart`), y recorre 8 pasos con `expect`: abrir el plano, confirmar la escala, recorrer bahías, buscar y resaltar, dos descargas, deshacer una, el Avance y Estadísticas. Pasa a 1266 × 682, 1366 × 768 y 1536 × 794. Con `EXPO_PAUSA_MS=1200`, el recorrido tarda unos 50 s, más 20 a 30 de compilación.
- **Firebase en dos niveles:** las 3 de RF-032 con `fake_cloud_firestore`, y el emulador de Firestore con su consola, en el proyecto `demo-expo`: 69 de 69 y 25 de 25 con las reglas de `docs/T80-firestore.rules.propuesta`.
- **Cifras:** la suite, 1863 de 1863 en una corrida (las 1841 de T-125 y las 22 del curso), en 2 min 26 s; la cobertura de líneas, 90.79 %, con ISO 6346 al 100 %, la sincronización al 62.02 % y el buscador al 94.62 %; `analyze`, en cero en `lib/`, `test/`, `integration_test/` y `tool/`, salvo el banco de T-124.
- `fake_cloud_firestore` 4.2.0 entra fija en `dev_dependencies`. El lock suma 9 paquetes y sube `equatable` a 2.1.0, con los mismos bloques que `pruebas-curso` (10.12). `lib/` y `lib/main.dart` no cambian.
- El extra del emulador Android no se hizo.

**Dos hallazgos para el guion:**
- sin historial, el previo propone PAMIT, el puerto de salida, y la escala de llegada se cambia en los parámetros: con PAMIT, «0 se descargan»; con GTSTC, «30 se descargan». Es el mejor momento para la sala;
- la ventana se dibuja corrida si se cambia de tamaño ya visible (10.97 de `SPRINT-3.md`). `expo_ventana.dart` la fija antes del primer cuadro, y en la Expo no se toca la ventana mientras corre.

**O-126-1 (P3, de antes de T-126):** `tool/t124_main.dart` importa `build/t124/entradas/t124_entradas.dart`, que se genera fuera de Git a partir de un sintético que sale del corpus, y solo existe en la carpeta del rediseño. En una copia limpia de `sprint-4` (`qa-r4`, `baystream-expo`), `flutter analyze` completo da 3 errores en ese banco. Las aceptaciones miden `flutter analyze lib test`, que da cero. No toca la app, pero la mezcla lo lleva a `master`.

**Yov lo revisó contra el disco:**
- contra `d41ad8c` cambian exactamente las 13 rutas: 3 modificadas y 10 nuevas. `lib/`, `lib/main.dart` y las opciones de Firebase no cambian;
- los tres archivos del curso y `tool/cobertura_html.py` son iguales byte por byte a `pruebas-curso`. Los 10 bloques nuevos o cambiados del lock son iguales a los de `pruebas-curso`, y la sección `sdks` no cambia;
- los registros dicen lo que dice el informe: 22 de 22, el rojo con su motivo, el verde, 69 de 69 y 25 de 25, «+1863: All tests passed!», los 3 errores de `tool/t124_main.dart` y «No issues found!» sin ese banco, y «8 de 8 pasos comprobados», con pausa y sin ella. La cobertura, recalculada desde `coverage/lcov.info`, da 16 853 de 18 562 líneas: 90.79 %;
- el recorrido usa la sesión local y un almacén nuevo en `%TEMP%\expo`, y el emulador no arranca con un proyecto que no empiece con `demo-`.

**Con esto:**
- **T-126 queda terminada.** Carlos sube el bloque de Timonel en `expo-pruebas`, que no entra en `sprint-4` ni en `master`.
- **La compilación de Windows de `baystream-expo` (11 GB en `build\windows`) se queda hasta el sábado.**
- Yov pasa las cifras y las capturas a las diapositivas. Carlos ensaya el viernes, con el guion de la sección 7 del informe, y expone el sábado 31-oct.
- La punta de `sprint-4` que se mezcla en 4.1 de la lista del piloto es la de esta decisión: después de `d41ad8c` solo cambian `SPRINT-4.md` y el informe de Codex.
- O-126-1 va con O1 de T-125 a una tarea del banco, después de la 3.2.0. Yov propone que el banco lea sus entradas al correr, en vez de importar un archivo generado, para que `analyze` dé cero en una copia limpia.

La siguiente decisión es la **10.74**.

### 10.74 · La numeración va en 0.x hasta la 1.0.0 del examen final: la de hoy es la 0.4.0 (28-oct, 12:50)

**Carlos lo decidió a las 12:34, con la mezcla de 4.1 hecha y antes de compilar nada.** Un 3 dice que el producto ya está establecido, y todavía no lo está. La 1.0.0 queda para la prueba final con el ingeniero, o para más adelante si para entonces no está al 100 %; hasta ahí, todo es 0.x.

**Cómo se leen las versiones.** Lo ya publicado conserva su número en Git y en los paquetes, y los documentos lo leen con esta tabla:

| Antes | En 0.x |
|---|---|
| 3.0 (`v3.0`) | 0.3.0 |
| 3.1 (`v3.1`) | 0.3.1 |
| 3.1.1 (`v3.1.1`, la publicada el 26-oct, 10.62) | 0.3.2 |
| 3.2.0, la de hoy | **0.4.0** |
| la de la entrega 3 | 0.4.1 |
| la del examen final | 1.0.0 |

**Lo que cambia:**
- `pubspec.yaml`: `version: 0.4.0+6` y `msix_version: 0.4.0.0`. Son las dos únicas líneas del código con la versión: la app no la lee ni la muestra.
- **Android:** `versionName` 0.4.0 con el `versionCode` 6. Play solo exige que el código suba; el nombre puede bajar.
- **Windows:** 0.4.0.0 es menor que el 3.1.1.0 instalado, y Windows no instala una versión menor encima. **Una sola vez,** se desinstala la 3.1.1 antes de instalar la 0.4.0.0, con una copia de `%LOCALAPPDATA%\BayStream` antes (4.2 de la lista del piloto). Los datos no se pierden: la app los guarda en esa carpeta, fuera del paquete, y Yov comprobó que las carpetas del paquete (`LocalCache\Local` y `LocalCache\Roaming`) solo tienen la de Microsoft. Desde ahí, la 0.4.x se instala encima.
- **Web:** `version.json` dirá 0.4.0 y 6.
- **Git:** `master` quedó en `5fe823a` con la etiqueta `v3.2.0`, con la que no se publicó nada. Una segunda mezcla trae a `master` el commit de esta decisión; `v3.2.0` se borra, local y en `origin`, y se crea `v0.4.0`. `v3.0`, `v3.1` y `v3.1.1` se quedan.
- **`docs/piloto/LISTA-PILOTO.md`:** las secciones 0, 4 y 5 dicen 0.4.0; 4.1 cuenta la mezcla en dos pasos; 4.2 trae la desinstalación de una vez; y la vuelta de Android de 4.5 se llama 0.3.3, con el `versionCode` 7. Además, los bloques de 4.1, 4.2 y 4.4 van dentro de `& { … }`: según cómo se peguen, PowerShell puede correr cada línea por su cuenta, y un `throw` no detiene las que siguen. En 4.4, eso podía dejar pasar `firebase deploy` después de una comprobación fallida.

**Lo que no cambia:**
- El código de la candidata: entre `56c66c2` y el commit de esta decisión solo cambian las dos líneas del pubspec, la lista del piloto y este archivo. `pubspec.lock` no cambia.
- La aceptación de T-125 vale para la 0.4.0, porque es el mismo código: Codex no la repite. 4.2 a 4.4 comprueban el número en cada cliente.
- Lo ya escrito: 10.65 a 10.73 y los informes de T-123, T-125 y T-126 dicen 3.2.0, y se leen como 0.4.0. No se reescriben.
- La rama `expo-pruebas` sigue con `3.2.0+6` en su pubspec: no se publica, y la app no muestra el número. El deck de la Expo pasa a 0.4.0 en su borrador 3.

**Lo que sigue, en orden:**
1. Carlos cambia las dos líneas del pubspec y sube este bloque a `sprint-4`, con el comando que le pasa Yov.
2. La segunda mezcla y la etiqueta `v0.4.0`, con el bloque de 4.1.
3. Windows, Android y la Web, con 4.2 a 4.4.

La siguiente decisión es la **10.75**.

### 10.75 · La 0.4.0, publicada en los tres clientes, y lo que dejó el día (28-oct, 19:30)

**Carlos la publicó con la sección 4 de la lista del piloto:**
- **Windows:** `BayStream_0.4.0.0.msix`. Por dentro dice versión 0.4.0.0 y firmante `CN=BayStream`, con firma `Valid`, y su SHA-256 (`03AA5A42…71A17F7`) coincide con el `.sha256`. Un solo bloque compiló, verificó, copió los datos y solo entonces quitó la 3.1.1 e instaló la 0.4.0.0. La copia quedó en `C:\Proyectos\respaldo-almacen-20261028-1300`: 592 archivos del almacén (35 MB) y la carpeta del paquete, con 8 carpetas vacías y ningún archivo. Los datos nunca estuvieron dentro del paquete. La app abrió con los datos de siempre (Carlos).
- **Android:** el AAB 6 (0.4.0), firmado con la clave de subida, en la prueba interna como «0.4.0 · Rediseño». El Honor lo actualizó y dice 0.4.0.
- **Web:** la compilación 0.4.0+6. T-92 aprueba 57 archivos y Firebase publica 56: falta `.last_build_id`, que es oculto y Hosting no sube. El `version.json` publicado dice 0.4.0 y 6, y en incógnito la app abre la operación publicada.
- La compilación no tocó el repositorio: `pubspec.lock` y lo que Flutter regenera en `windows/flutter/` siguen iguales a `be532ab`.

**Play muestra un nombre temporal:**
- Hasta la primera revisión de Google, la tienda dice «gt.cmartinez.baystream (unreviewed)», con un ícono genérico. En el teléfono, la app se llama BayStream y lleva su ícono, porque los dos van en el AAB. La prueba interna no pasa por esa revisión.
- **Hoy quedó la ficha de Play Store en borrador:** el nombre, las dos descripciones, el ícono de 512 y el gráfico de 1024 × 500 de `design/icono/play/`, que se hicieron en T-88 y nunca se subieron.
- **La primera revisión va con la prueba cerrada, después de la Expo.** Necesita las dos decisiones de 10.49 (cómo entra el revisor y un archivo de muestra sintético), las declaraciones de `docs/T88-DECLARACIONES-PLAY.md` y dos capturas de teléfono con un plano sintético.

**Lo que Carlos encontró en la Web:**
- **O-040-1:** en la silueta del buque, el deslizamiento horizontal del touchpad hace que Chrome vuelva a la página anterior. Según reportes de otros desarrolladores, la línea de CSS habitual puede no bastar en Chrome de Windows.
- **O-040-2:** la rueda del mouse sobre la silueta no mueve las bahías. Es la primera línea de T-119, que está en la entrega 3 y todavía no se hace.
- **Mientras tanto:** en la oficina, la app de Windows, que no tiene el «atrás» del navegador; en la silueta, Mayús + rueda.

**Dos observaciones más, P3:**
- `test/t102_weight_display_test.dart` crea una carpeta `t102-synthetic-*` en `%TEMP%` en cada corrida y nunca la borra: van 86. Va a la tarea del banco, con O1 de T-125 y O-126-1.
- `build\t93` guarda un `BayStream_1.0.0.0.msix` del 15-oct (T-93). La compilación de la 1.0.0 lo sobrescribiría: ese día, se aparta antes.

**El deck de la Expo:**
- **El borrador 2 no abría en PowerPoint:** al repararlo, dejó en blanco las diapositivas de contenido.
- **La causa:** cuando una línea mezcla dos colores, pptxgenjs repite el formato del párrafo (`a:pPr`) antes de cada parte. Eran 117 errores de esquema en las diapositivas; LibreOffice los tolera y PowerPoint no.
- **La corrección:** `post.py` deja un solo formato por párrafo. Las copias que quita eran iguales a la primera, así que no cambia nada de lo que se ve.
- **El borrador 3 pasa el esquema de PresentationML sin errores en las diapositivas.** Queda uno en `presentation.xml`: el orden que escribe pptxgenjs, que PowerPoint lee bien.
- El borrador 3 dice 0.4.0 donde decía 3.2.0, con el video de la terminal grabado de nuevo. Carlos lo abrió en PowerPoint y se ve bien. Está en `C:\Proyectos\baystream-presentacion\expo\`, y su huella coincide.

**La mudanza de `%TEMP%`, hecha:**
- **75 de 75 entradas,** con 15.99 GB y 65 377 archivos, ya están en `C:\Proyectos\evidencia\`, con los mismos nombres. Se movieron por renombre en el mismo disco, sin copiar ni borrar. El manifiesto es `C:\Proyectos\evidencia\MANIFIESTO-28oct.csv`, y ahí están también el script y su lista.
- Son 45 entradas citadas por nombre en los documentos y 30 del proyecto sin cita exacta. Una ruta de `%TEMP%\<nombre>` en un informe se lee ahora como `C:\Proyectos\evidencia\<nombre>`.
- **No se movieron:** `expo`, que usa el recorrido de la Expo, y las 86 `t102-synthetic-*`. El script cuenta 86 porque su patrón no incluye `expo`.
- De los 173 nombres de `%TEMP%` que citan los documentos, 127 ya no estaban. La limpieza de 10.72 liberó solo 0.1 GB, así que la mayoría se había ido antes; no se puede saber cuáles se llevó.

La siguiente decisión es la **10.76**.

### 10.76 · Carlos decide la 0.4.1: T-119 y el listado en una operación publicada (H2) (28-oct, 19:30)

**Lo decidió a las 19:17:**
- **T-119 va en la 0.4.1,** con el diseño de la sección 0.7 de `docs/T117-T121-RESULTADOS.md` y las respuestas P4 y P7 de 10.38. Son cuatro cosas:
  - la rueda en la silueta, que arregla O-040-2;
  - el pellizco del touchpad y Ctrl + rueda para el zoom;
  - el punto bajo el puntero quieto al ampliar;
  - la barra horizontal.
- **El gesto del touchpad que regresa el navegador (O-040-1) queda para después.** T-119 no toca `web/index.html` por eso; solo por el pellizco, si la prueba lo exige (P7).
- **H2 también va en la 0.4.1, como T-127:** que publicar una operación sin el listado no la deje sin poder importarlo después. Yov propone el diseño de la sección 8.3 de `docs/T122-RESULTADOS.md`, tal cual:
  - los BAPLIE no cambian;
  - el listado se agrega o se reemplaza mientras la operación esté abierta, con un número de revisión;
  - el muelle lo recibe solo y avisa;
  - antes de confirmar, el cruce dice qué contenedores ya cargados no están en el listado nuevo y qué vacíos cambian de grupo.
  - Toca `domain/`, `data/` y las reglas. Las reglas nuevas las redacta Timonel y las prueba en el emulador: las 69, los 25 casos de abuso y los nuevos. Las publica Carlos desde la consola, antes que los clientes de la 0.4.1.
  - **Carlos confirma el diseño antes del prompt de T-127.**
- **T-120 queda para después,** con O1 y O2 de la entrega 1 y el arrastre entre dos monitores.

**El orden:**
1. T-119, con Timonel. Codex la acepta.
2. T-127, con Timonel, mientras Codex acepta T-119. Codex acepta T-127.
3. La candidata: `version: 0.4.1+7`, `msix_version: 0.4.1.0` y el AAB 7. Carlos publica las reglas y los tres clientes, a más tardar el 4-nov.

**Lo que no cambia:**
- `lib/`, `test/` y `pubspec.*` son de una tarea a la vez.
- Flutter corre de a un comando, con la luz verde de Carlos, y nunca durante el repaso técnico, el ensayo del viernes ni la Expo del sábado.

**Las demos de la Expo:** en vivo van la 3 (`integration_test`) y la 2 (el emulador). El emulador se arranca antes de empezar, con la consola abierta en Firestore → Requests, para no esperar sus 33 s en la sala. La demo 1 tarda unos 20 s: va en vivo si sobra tiempo, y si no se muestra con su diapositiva y el respaldo de la 20.

La siguiente decisión es la **10.77**.

### 10.77 · T-119 entregada y revisada: la rueda, el zoom y la barra; y una prueba que rompió 10.74 (29-oct, 00:45)

**Timonel la entregó a las 00:20, sobre `9ef19f0`.** Está en `docs/T119-RESULTADOS.md` y `DESIGN.md` 16, con la evidencia en `build/t119/`.
- **La rueda en la silueta:**
  - hacia abajo avanza a la popa y hacia arriba regresa, con 100 ms de animación, o sin ella si el sistema reduce el movimiento;
  - en un extremo, la rueda pasa a la columna;
  - un pestillo de 300 ms evita que la silueta se robe la rueda al bajar la página;
  - Mayús + rueda sigue siendo del desplazable.
- **El zoom:**
  - el pellizco del touchpad y Ctrl + rueda, también con el mouse (P4), amplían entre 75 y 300 %;
  - mientras dura el pellizco, nada se desplaza;
  - la celda bajo el puntero se queda quieta, también cuando la bahía pasa de caber centrada a no caber;
  - el chip sigue ampliando desde la esquina, y en el teléfono el zoom del touchpad también.
- **La barra horizontal:**
  - va abajo de la columna, encima de la franja de cifras, y solo aparece cuando la bahía no cabe;
  - se arrastra, un clic en la pista avanza una página y deja 14 dp de aire;
  - en la oficina, el desplazamiento horizontal de la rejilla va ahora por fuera del zoom.
- **La Web (P7):** no tocó `web/index.html`. Según el código del motor web de Flutter 3.38.9 (una lectura, no una medida), Ctrl + rueda llega como escala y el motor cancela el evento del navegador. Lo confirma Carlos en Chrome y Edge.
- **Siete diferencias con el diseño de 0.7.2,** explicadas en la sección 4 del informe y en `DESIGN.md` 16.6. Tres salieron de errores que destaparon sus propias pruebas.
- **Cifras:**
  - 11 pruebas nuevas, que fallan las 11 contra el código de antes, cada una en su comprobación;
  - la suite, 1852 en una corrida: 1851 en verde, ninguna omitida y una fallida;
  - `analyze`, en cero.

**La fallida la causó 10.74, no T-119:**
- `test/t93_msix_config_test.dart` fija `msix_version` en `3.2.0.0`, y la numeración nueva cambió el pubspec sin cambiar la prueba. Falla igual en `9ef19f0`.
- 10.74 dijo que no hacía falta repetir nada porque solo cambiaba el pubspec, y esa prueba lee el pubspec: fue un error de Yov.
- Lo publicado no cambia, porque es una prueba y no código de la app. Pero desde `7647741` la suite no cumplía el piso de 1841 sin fallas.
- **El arreglo:** que la prueba compruebe que `msix_version` es la versión del pubspec con `.0` al final, en vez de fijar un número. Así la 0.4.1 no la rompe. Lo hace Timonel, en un commit aparte.

**Yov lo revisó contra el disco:**
- cambian exactamente las 11 rutas del bloque: 7 modificadas y 4 nuevas. No cambian `domain/`, `data/`, `pubspec.*`, `lib/main.dart`, las opciones de Firebase ni `web/index.html`;
- los registros dicen lo que dice el informe:
  - `analyze` da «No issues found!» en los tres directorios;
  - la suite da «+1851 -1», con la única falla en `t93_msix_config_test.dart` («Expected: '3.2.0.0' · Actual: '0.4.0.0'»);
  - las pruebas nuevas contra el código de antes dan «-11»;
- el código hace lo que dice el informe:
  - la rueda se registra en el resolvedor solo cuando la silueta puede moverse en ese sentido;
  - el pestillo distingue el evento original del que toma la silueta;
  - el pellizco se apaga al terminar y al desmontarse el plano.

**Para la aceptación de Codex:**
- Con el desplazamiento horizontal de la oficina fuera del zoom, H7 (el arrastre que desplaza el plano al acercarse al borde, también con zoom) y la prueba de T-105 merecen una pasada a mano en Windows a 200 %.
- Un pellizco que no termina, por ejemplo si la ventana pierde el foco a la mitad, no debería dejar quieta la columna.

**Lo que sigue:**
1. Carlos sube el bloque de Timonel y el de esta decisión.
2. Timonel arregla la prueba de T-93 y corre la suite: 1852 de 1852.
3. Carlos hace la prueba de la sección 7 del informe: unos 10 minutos en Windows y 10 en Chrome y Edge, después del repaso técnico de la Expo.
4. Codex acepta T-119.
5. Con el ok de Carlos al diseño de 8.3, Yov escribe el prompt de T-127.

La siguiente decisión es la **10.78**.

### 10.78 · El arreglo de T-93, revisado; Carlos aprueba el diseño de T-127 y la pone en Fable 5.1 (29-oct, 01:00)

**El arreglo de la prueba de T-93 (10.77), revisado:**
- `test/t93_msix_config_test.dart` lee la línea `version: x.y.z+n` del pubspec y exige que `msix_version` sea `x.y.z.0`. Es lo único que cambió en ese archivo.
- La prueba da 5 de 5; la suite, 1852 de 1852 en una corrida, sin omitidas; y `analyze`, cero. La evidencia está en `build/t119/`.
- Timonel metió `git status` en un comando, por error. La regla de `.claude/settings.json` lo bloqueó y no corrió, y no quedó ningún `index.lock`.

**Carlos aprueba el diseño de T-127 (00:40).** H2 se hace con la sección 8.3 de `docs/T122-RESULTADOS.md`, tal cual:
- **Qué hace:**
  - los BAPLIE de una operación publicada no cambian;
  - el listado se agrega o se reemplaza mientras la operación esté abierta, con un número de revisión;
  - el muelle lo recibe solo y avisa;
  - antes de confirmar, el cruce dice qué contenedores ya cargados no están en el listado nuevo y qué vacíos cambian de grupo.
- **Autoriza** tocar `domain/`, `data/` y `presentation/` para eso, sin dependencias nuevas.
- **Las reglas nuevas** van en un archivo nuevo, `docs/T127-firestore.rules.propuesta`, que Timonel puede incluir en su bloque de Git. `docs/T80-firestore.rules.propuesta` sigue siendo lo publicado hasta que Carlos publique el archivo nuevo desde la consola, después de la aceptación de Codex y antes de los clientes de la 0.4.1. Lo publicado se coteja con el archivo, como en 10.108 de `SPRINT-3.md`.
- **Las baterías** de 69 reglas y 25 abusos tienen que pasar también contra las reglas nuevas, más los casos nuevos de T-127.
- **Compatibilidad:** un cliente 0.4.0 nunca daña una operación con revisión, y el informe dice qué le pasa. La regla de uso: la laptop y el Honor pasan a la 0.4.1 antes de usar la función.
- **El emulador** de T-127 usa un proyecto `demo-` y el puerto 8282, para no chocar con el de la Expo (8181 y 4000).

**Los modelos, desde ahora.** Carlos tiene el semanal de Fable en cero.
- **Fable 5.1** para lo que toca reglas, sincronización o `domain/`, y para los diagnósticos difíciles. T-127 va con Fable 5.1 en Max, en un chat nuevo.
- **Claude Opus 5.5** para lo de presentación y los arreglos chicos, en Extra o en Alto.
- **Codex** sigue con GPT-6.1 Sol, en high, para las aceptaciones.

**Lo que sigue:**
1. Carlos sube T-119, el arreglo de T-93 y esta decisión.
2. T-127 va a Timonel, con Fable 5.1, al despertar. Mientras no haya luz verde, lee, diseña y escribe código.
3. Flutter y el emulador corren con la luz verde de Carlos, y nunca durante el repaso técnico de la Expo, el ensayo del viernes ni la Expo del sábado.
4. Carlos prueba T-119 con su mouse y su touchpad, y después Codex la acepta.

La siguiente decisión es la **10.79**.

### 10.79 · T-127 entregada y revisada: el listado entra en una operación publicada; Yov propone cerrar la 0.4.1 con una sola aceptación (29-oct, 12:30)

**Timonel la entregó con Fable 5.1, sobre `cf7cf3f`.** Está en `docs/T127-RESULTADOS.md`, con la evidencia en `build/t127/`. Es el diseño de 8.3 de T-122, tal cual:
- **La oficina** agrega o reemplaza el listado en una operación publicada y abierta, con `replaceSource`: los trozos de la revisión nueva y el manifiesto van en un solo lote. Si la nube no acepta, nada local cambia. Antes de confirmar, el cruce dice cuántos cargados no están en el listado nuevo y cuántos vacíos asignados cambian de grupo.
- **El muelle** escucha el manifiesto, baja solo la revisión nueva, comprueba las huellas y avisa «Listado actualizado por la oficina: n filas». Sin red, sigue con el anterior hasta reconectar.
- **Lo demás:** los BAPLIE y los movimientos no cambian, y el estado se vuelve a derivar. `join` toma la última revisión, y lo ya publicado se sigue uniendo.
- **Las reglas** van en `docs/T127-firestore.rules.propuesta`: T-80 más las dos cláusulas, con huella `FC17842C…`. Las de T-80 siguen siendo las publicadas.
- **Compatibilidad (sección 4):**
  - un cliente 0.4.0 que se une a una operación revisada falla con `source_mismatch` y un mensaje claro, sin guardar nada;
  - uno que ya estaba unido sigue con el listado viejo, y sus movimientos se aceptan igual;
  - una oficina 0.4.0 no puede revisar.
  - Ninguno daña la operación.
- **Cifras:**
  - 19 pruebas nuevas en verde;
  - la suite, 1871 de 1871 en una corrida, sin omitidas: el piso sube de 1852 a 1871;
  - `analyze`, cero;
  - en el emulador (`demo-t127`, puerto 8282, sin internet): contra las reglas nuevas, 69 de 69, 25 de 25 y 31 de 31; contra las de T-80, 69, 25 y 27 de 31, porque caen justo los cuatro casos que la revisión permite.
- **Para Carlos:** la sección 7 dice cómo publicar las reglas desde la consola, cómo cotejarlas con `tool/t113_reglas.mjs` y el archivo nuevo como tercer argumento, y cómo volver atrás. La sección 8 trae una prueba de punta a punta de 14 pasos con la laptop y el Honor, con los sintéticos de T-100.

**Yov lo revisó contra el disco:**
- **El árbol:** cambian exactamente las 22 rutas del bloque, 14 modificadas y 8 nuevas. No cambian `pubspec.*`, `lib/main.dart`, las opciones de Firebase ni `docs/T80-firestore.rules.propuesta`.
- **Las reglas:** sin contar el fin de línea, el archivo nuevo difiere del de T-80 solo en el encabezado y en las dos cláusulas. En la segunda, `validSource` se parte en el trozo publicado, que es el texto de T-80, y el de revisión.
  - Revisar exige la oficina, la operación abierta y que solo cambie `sources.export_list`, sin poder quitarlo.
  - La revisión sube, o empieza en 1 si no había listado.
  - Cada trozo de revisión lleva la revisión, la huella y el número de trozos del manifiesto, con el tope de tamaño y el autor.
  - Los trozos siguen sin `update` ni `delete`.
- **La vuelta a la 0.4.0:** lo único nuevo que se guarda en el almacén local es el campo `revision` del listado, y la 0.4.0 lo ignora al leer. Si hubiera que volver a la 0.4.0, los datos locales se leen igual.
- **Los registros dicen lo que dice el informe:** «No issues found!» al empezar y al terminar, «+1871: All tests passed!» y las seis baterías con sus resultados.

**Dos observaciones, P3:**
- **O-127-1:** contra `cf7cf3f`, las 19 pruebas nuevas «fallan» porque no compilan: usan el contrato nuevo. No muestran qué comportamiento faltaba, como sí lo mostraron las de T-119. Lo cubre la aceptación, con la app real en el emulador.
- **O-127-2:** el lanzador de las baterías deja que el concentrador del emulador tome el puerto 4400, el mismo de la Expo. Nunca corre a la vez que el emulador de la Expo.

**Primero va la Expo.** El repaso técnico de los diez comandos del guion, en `baystream-expo`, sigue pendiente, y va antes que cualquier cosa de la 0.4.1. Mientras dura, y en el ensayo del viernes y la Expo del sábado, ningún agente corre Flutter ni el emulador.

**Yov propone cerrar la 0.4.1 con una sola aceptación de Codex, como la 3.2.0 en T-125.** 10.76 aceptaba T-119 y T-127 por separado, pero la de T-119 no empezó, y una sola sobre la candidata ahorra una corrida:
1. Carlos sube el bloque de T-127 y el de esta decisión.
2. Después del repaso, Carlos mueve `qa-r4` a la punta de `sprint-4` y hace ahí su prueba de T-119 (sección 7 de su informe).
3. **T-128, la candidata,** con Timonel en Opus 5.5: `version: 0.4.1+7` y `msix_version: 0.4.1.0`, con la suite y `analyze`. Yov pone al día la sección 4 de la lista del piloto: las reglas de T-127 antes que los clientes, la 0.4.1 encima de la 0.4.0 y la vuelta atrás.
4. **Codex acepta la 0.4.1 entera** en `qa-r4`:
   - T-119, con la prueba de Carlos y las dos pasadas de 10.77;
   - T-127, con sus baterías y una prueba de punta a punta en el emulador con la app real: la oficina, el muelle y un cliente 0.4.0 frente a una operación revisada;
   - la candidata, con la lista del piloto.
5. Con la aceptación, Carlos publica las reglas de T-127 y las coteja (sección 7). Después van los tres clientes, con la sección 4 de la lista, a más tardar el 4-nov, y al final la prueba de punta a punta de la sección 8, ya en la nube.

**Decide Carlos.**

La siguiente decisión es la **10.80**.

### 10.80 · Carlos probó T-119 a mano y pasa todo; Codex la repite en los navegadores; Carlos aprueba cerrar la 0.4.1 con una sola aceptación (29-oct, 16:30)

**La prueba de T-119 de Carlos** (sección 7 de `docs/T119-RESULTADOS.md`) fue la tarde del 29-oct, en `qa-r4` a `65db312`, con su mouse y su touchpad, en Windows, Chrome y Edge: «todo pasó».
- Compiló Windows y la Web con `tool/t100_main.dart`, sin Firebase, con el plano sintético de T-100 y un almacén aparte en `%TEMP%`. Nada tocó el almacén real.
- Al mover `qa-r4`, Git marcó tres archivos de `windows/flutter/` que Flutter regenera al compilar. Después de las dos compilaciones quedaron idénticos a los del repositorio.

**T-127 quedó en `cce3c4c`,** encima de `65db312` (10.79): Carlos subió primero el bloque de la decisión y después el de Timonel, con las 22 rutas que revisó Yov. La prueba de Carlos no llevaba T-127, pero T-127 no toca ningún archivo de T-119.

**Codex repite T-119 en Chrome y en Edge, con un conductor.** Es la parte Web de la aceptación de T-119, adelantada:
- los pasos 1 a 9 de la Web, con eventos sintéticos y con números, en `qa-r4` a `cce3c4c`;
- un instrumento calibrado en una página de control: donde no logre el efecto, el paso queda «no concluyente» y rige la prueba de Carlos;
- el rojo: el mismo conductor, contra la Web sin T-119, tiene que fallar en los pasos 1, 2, 3, 4 y 6;
- el informe en `docs/t119/navegadores-codex.md` y la evidencia en `build/t119-navegadores/`.

**Carlos aprueba la propuesta de 10.79 (16:22):** la 0.4.1 se cierra con una sola aceptación de Codex.
1. **T-128, la candidata,** con Timonel en Claude Opus 5.5, en Alto: `version: 0.4.1+7` y `msix_version: 0.4.1.0`, con la prueba de T-93, `analyze` y la suite.
2. **La lista del piloto, al día para la 0.4.1,** por Yov, en el mismo commit que esta decisión:
   - las reglas de T-127 antes que los clientes, en una sección 4.0 nueva;
   - la 0.4.1 encima de la 0.4.0 en Windows, sin desinstalar;
   - el listado en una operación publicada, en la oficina (1.17) y en el muelle (2.15);
   - la vuelta a la 0.4.0.
3. **Codex acepta la 0.4.1 entera** en `qa-r4`, sobre la punta con T-128:
   - T-119, con la prueba de Carlos, su conductor de los navegadores otra vez y las dos pasadas de 10.77;
   - T-127, con sus baterías y una prueba de punta a punta en el emulador con la app real, que incluye un cliente 0.4.0 frente a una operación revisada (O-127-1);
   - la candidata y la lista del piloto.
4. Con la aceptación, Carlos publica las reglas (4.0 de la lista) y los tres clientes, a más tardar el 4-nov, y hace la prueba de punta a punta de la sección 8 de T-127.

**Flutter va de a un comando y con la luz verde de Carlos.** La suite de T-128 nunca corre a la vez que el conductor de Codex, porque el pestillo de 300 ms se mide con tiempos. Y nada corre durante el repaso técnico de la Expo, que sigue pendiente, el ensayo del viernes ni la Expo del sábado.

La siguiente decisión es la **10.81**.

### 10.81 · La parte Web de T-119, aceptada por Codex; T-128 entregada y revisada; la aceptación de la 0.4.1 va a Codex (29-oct, 17:30)

**La parte Web de T-119, adelantada** (Codex, `docs/t119/navegadores-codex.md`, en `af87dd6`), sobre `cce3c4c`, con Chrome 156 y Edge 156:
- **Cumple en los dos navegadores:** la rueda en la silueta, el pestillo, los dos dedos y la barra. En el pestillo, los intervalos medidos quedaron a los dos lados de los 300 ms.
- **Ctrl + rueda amplía el plano** entre 75 y 300 %, con la celda quieta a menos de 0,43 dp. Queda no concluyente que el navegador no amplíe la página con Ctrl + rueda, y lo mismo los atajos Ctrl + «+» y «−»: el instrumento no logró ampliar ni la página de control. Ahí rige la prueba de Carlos (10.80).
- **El pellizco no amplía la página,** ni sobre el plano ni fuera de él. Ya era así antes de T-119: lo hace el motor de Flutter (sección 6 de T-119).
- **El rojo:** el mismo conductor, contra la Web sin T-119, falla en 1, 2, 3, 4 y 6, cada uno en su comprobación.
- **Yov lo revisó contra la evidencia:** la huella del informe y la del conductor coinciden con el manifiesto, y también 80 de sus 1139 archivos, tomados al azar. Los 624 originales siguen intactos, y la matriz final dice lo mismo que el informe.

**Tres observaciones, P3:**
- **O-119-1:** al pellizcar desde el 100 %, justo cuando la bahía deja de caber centrada, la celda se corre hasta 1,9 dp en Chrome y 1,4 en Edge. Ya desbordada, se corre 0,06, y con Ctrl + rueda en el mismo cruce, 0,43. La prueba de T-119 solo cubría el pellizco con la bahía ya desbordada.
  - **Yov propone aceptarla en la 0.4.1 y corregirla en T-120**, con una prueba que pellizque justo en ese cruce. Son unos 2 píxeles que la prueba de Carlos no vio, y corregirla ahora pediría otra entrega y otra aceptación antes del 4-nov.
  - Decide Carlos.
- **O-119-2:** el instrumento no logra el zoom del navegador ni con Ctrl + rueda ni con los atajos (arriba). No es del producto.
- **O-119-3:** las precauciones del instrumento. Entre ellas va una pista para O-040-1: al armar el conductor, la rueda horizontal que se pasaba del borde regresó la pestaña a la página anterior. Codex no lo da por reproducido.

**T-128, la candidata, entregada y revisada** (Timonel, en Claude Opus 5.5; `docs/T128-RESULTADOS.md`):
- `pubspec.yaml` cambia solo dos líneas: `version: 0.4.1+7` y `msix_version: 0.4.1.0`. `pubspec.lock` conserva su huella.
- La prueba de T-93 da 5 de 5; `analyze`, cero; y la suite, 1871 de 1871 en una corrida, sin omitidas. Corrió después de que Codex cerró sus navegadores.
- Fuera de `docs/`, nada más fija la versión: Gradle y el runner de Windows la toman del pubspec, y `version.json` lo genera la compilación.
- **Yov lo revisó contra el disco:** el diff del pubspec, la huella del lock y los tres registros.
- **O-128-1, P3:** `tool/t93_msix.ps1` trae `-Version '1.0.0.0'` por omisión, y eso manda sobre el pubspec.
  - Sin `-Version` sale un `BayStream_1.0.0.0.msix`, y una vez instalado, Windows ya no deja poner una 0.4.x encima.
  - La lista del piloto siempre pasa `-Version`, así que en la 0.4.1 no hace daño.
  - **Yov propone que el script lea `msix_version` del pubspec por omisión**, en la tarea del banco, después de la Expo. Decide Carlos.

**Lo que sigue:**
1. Carlos sube el bloque de T-128 y el de esta decisión, y mueve `qa-r4` a la punta.
2. Codex acepta la 0.4.1 entera (10.80, punto 3) en `docs/t128/aceptacion-codex.md`. Además de lo de 10.80, hace una prueba de punta a punta con la app real contra el emulador, la primera que escribe de verdad contra las reglas de T-127, y compila la candidata en los tres clientes.
3. El repaso técnico de la Expo, que sigue pendiente, va antes de la luz verde de esa aceptación. Mientras tanto, Codex solo lee y prepara.
4. Con la aceptación, la sección 4 de la lista: las reglas (4.0), la mezcla y los tres clientes, a más tardar el 4-nov, y después 0.7.

La siguiente decisión es la **10.82**.

### 10.82 · Carlos aprueba las dos propuestas de 10.81 (29-oct, 17:19)

- **O-119-1** queda como conocida en la 0.4.1 y va a T-120, con una prueba que pellizque justo cuando la bahía deja de caber centrada.
- **O-128-1** va a la tarea del banco, después de la Expo: `tool/t93_msix.ps1` leerá `msix_version` del pubspec cuando no se le pase `-Version`. Hasta entonces, la lista del piloto lo llama siempre con la versión.
- Esta decisión se sube junto con la revisión de la aceptación de la 0.4.1. Así la punta de `sprint-4` no se mueve mientras Codex acepta en `qa-r4`, porque su Paso 0 la fija en `c893687`.

La siguiente decisión es la **10.83**.

### 10.83 · Codex acepta la 0.4.1 con dos reservas (29-oct, 23:50)

**Codex aceptó la 0.4.1 con reservas** (`docs/t128/aceptacion-codex.md`), sobre `c893687`:
- **P1 · T-119:**
  - el código, cotejado; 11 de 11 pruebas en verde, y las 11 en rojo contra `83d7b85`, por comportamiento;
  - en Chrome y en Edge, lo mismo que en la parte Web adelantada (10.81);
  - en Windows a 200 %, el arrastre de T-105 y H7 cumple: Carlos lo hizo y el plano se desplazó hasta el borde.
- **P2 · T-127:**
  - 19 de 19 pruebas, y las seis baterías como se esperaba;
  - los 14 pasos de la sección 8 de T-127, con la app real contra el emulador. La oficina y el muelle fueron dos contextos de Chrome, el muelle a 360 × 800: no cubre el Honor ni Android, que van en 0.7;
  - la compatibilidad con la 0.4.0 en sus cinco casos, también la vuelta del almacén local.
- **P3 · T-128:** la candidata compila en los tres clientes, y cada uno dice 0.4.1 (7). El AAB lleva la firma de depuración: acredita la compilación, pero no es el que va a Play.
- **P4 · La lista del piloto:**
  - los rótulos que cita existen;
  - los ocho bloques de PowerShell pasan el analizador;
  - cuadran las huellas, la mezcla y el `.sha256`.
- **La suite:** 1871 de 1871 en una sola corrida, sobre una copia limpia, y `analyze` en cero. Las regresiones con el banco de T-100 cumplen en los tres clientes.

**El paso 6 necesitó una reserva.** `T100_CARGA.edi` no trae ninguna, porque sus diez vacíos llevan número.
- Con el visto bueno de Carlos, Codex usó una copia en la que el OR 16, que es un vacío, pierde su número: `EQD+CN+MNLU0000827+45R1++2+4` pasa a `EQD+CN++45R1++2+4`. Su celda, 010-01-04, queda como reserva.
- Lo mismo les pasa a 0.7 y 2.6 de la lista del piloto: Yov los corrige.

**Las dos reservas, P2:**
- **O-128-2:** después de revisar el listado, el primer «Cerrar operación» de la oficina cierra la operación en la nube, pero dice «No se encontró la operación para cerrarla en este dispositivo o en la nube…» y deja la copia local abierta.
  - Al volver a abrir «Nube y cuenta» y repetirlo, dice «Operación cerrada.» y la cierra también en el dispositivo.
  - No se pierde ningún movimiento, y la nube rechaza otra revisión de la operación cerrada.
  - `close` no cambió en T-127, y la causa no está aislada. Se vio con la oficina en Chrome.
- **O-128-4:** no se logró provocar a mano un pellizco que pierda el foco sin su evento final, porque los pellizcos de Carlos terminaron antes de perderlo. Es una prueba que falta, no un defecto visto.

**Dos más, P3:** O-128-3, un error al arrancar el banco Web en el navegador integrado, sin atribuir; y O-128-1, ya decidida en 10.82.

**Yov lo revisó contra la evidencia:**
- la huella del informe es la del manifiesto y la del bloque de Codex;
- 100 de los 1189 archivos del manifiesto, tomados al azar, coinciden;
- la suite registra 1871 pruebas aprobadas, sin fallas ni omitidas, y `analyze` dice «No issues found!».

**Yov propone; decide Carlos:**
1. Aceptar las dos reservas y publicar la 0.4.1 después de la Expo. El paso 1.15 de la lista dirá qué hacer si el cierre falla: la nube ya quedó cerrada, y basta repetirlo.
2. **T-129, después de la Expo:** Timonel diagnostica O-128-2 con una prueba roja, en Fable 5.1 porque toca la sincronización.
   - Si el arreglo es chico, entra antes de publicar, con una revisión corta de Codex.
   - Si no, va a la 0.4.2.
3. **O-128-4 va a T-120:** que el plano suelte el pellizco cuando pierda el foco, con su prueba.

La siguiente decisión es la **10.84**.

### 10.84 · Carlos acepta las reservas: la 0.4.1 se publica después de la Expo, y T-129 diagnostica el cierre (29-oct, 23:55)

**Carlos aprueba las tres propuestas de 10.83 (23:49):**
1. **La 0.4.1 se publica después de la Expo, con las dos reservas a la vista.** El paso 1.15 de la lista dice qué hacer si el cierre falla (O-128-2): la nube ya la cerró, y basta repetirlo desde «Nube y cuenta». La sección 5 anota O-128-2 y O-128-4, con lo que hay que hacer mientras tanto.
2. **T-129, después de la Expo:** Timonel diagnostica O-128-2 con una prueba roja, en Fable 5.1. Si el arreglo es chico, entra antes de publicar, con una revisión corta de Codex; si no, va a la 0.4.2.
3. **O-128-4 va a T-120.**

**La lista del piloto queda al día,** en el mismo commit que esta decisión:
- **«Datos»** trae dos copias para el ensayo:
  - `T100_LISTADO_v2.xlsx`, el listado sin la fila del OR 1;
  - `T100_CARGA_RESERVA.edi`, el plan de carga con la reserva del OR 16. Va con un bloque que la deriva de `T100_CARGA.edi` y comprueba las dos huellas. Yov comprobó que el cambio da, byte a byte, la copia de la aceptación de Codex.
  - Los sintéticos se generan en `%TEMP%\t100-ensayo`.
- **0.7:** la oficina abre `T100_CARGA_RESERVA.edi`, porque el paso 6 necesita una reserva. Si en el paso 13 el cierre falla, es O-128-2.
- **2.6:** en el ensayo, el vacío que se asigna es el OR 16, a la reserva 010-01-04.
- **1.15:** qué hacer si el cierre dice «No se encontró la operación…».
- **El encabezado y la sección 5:** la aceptación con sus dos reservas.

**Lo que sigue:**
1. Mañana, primero la Expo: el repaso técnico y el ensayo, sin agentes con Flutter.
2. Después de la Expo:
   - T-129;
   - con lo que salga, la publicación de la 0.4.1 con la sección 4 de la lista (primero las reglas, en 4.0);
   - y la prueba de 0.7, a más tardar el 4-nov.

La siguiente decisión es la **10.85**.

### 10.85 · La tercera prueba piloto, con un buque real: la descarga sale completa, la carga corre con un rodeo y el papel cuadra con la app (1 y 2-nov)

**El piloto (domingo 1-nov):** el MAGELLAN STAR, viaje 26043S, escala GTSTC, con la 0.4.0. La oficina, en la Web del iPhone de Carlos (tema oscuro); el muelle, en el Honor. Los archivos reales (el reporte de MACS3, el plan de carga y el listado de la agencia) no entran al repositorio: aquí van solo números de orden, posiciones, códigos y conteos. El registro hora por hora está en el proyecto de Yov (`BayStream_Piloto3_MAGELLAN_STAR_1nov.md`).
- **La descarga salió completa en la app.** H1 de la 3.1.1 (GTSTC como escala en un plano de llegada) quedó confirmado en una operación real.
- **La carga tropezó tres veces y después corrió:**
  - el plan abierto era el de otro viaje, el 26039S del 5-oct. El cruce con el listado lo avisó antes de cargar nada: 0 de 104 llenos;
  - la operación ya publicada no acepta un plan nuevo (`OperationSources.save`); la 0.4.1 abre esa puerta solo para el listado (T-127);
  - dos equivalencias guardadas en el iPhone desviaban el listado, «Puerto PAMIT → JMKCT» y «Línea CRL → COS», elegidas al importar en el plan equivocado.
- **El rodeo:** otra operación, con una copia del plan de carga que dice 26043X en `TDT` (`RFF+VON` sigue en 26043S), el listado importado antes de publicar y las dos equivalencias corregidas. Desde ahí, el Honor cargó con los números de orden.
- **Al 2-nov, las dos terminaron y siguen abiertas:** la 26043S (descarga) y la 26043X (carga). La 26039S no se usó.

**El cotejo del papel con la app (2-nov).** Carlos mandó seis hojas del plano impreso, anotadas en el muelle (bahías 01/02, 09/10, 11, 14, 18 y 22), y ocho capturas del Honor (bahías 01, 02, 03, 10, 14, 18, 26 y 30). Yov las cruzó con el plan de carga y el listado, con un script que solo lee. Las 145 cargas del plan salen en al menos una foto: 70 en las dos, 32 solo en el papel y 43 solo en la app.
- **Las seis hojas cuentan lo mismo que el plan:** 4, 37, 5, 12, 21 y 23 movimientos.
- **Donde están los dos no hay ninguna contradicción:**
  - 59 celdas iguales, con el OR a la vista;
  - el 17 y el 123 de la bahía 14 cambiaron de celda: el papel lo marca con una flecha, y la app los tiene donde quedaron;
  - 8 celdas de la bahía 10 dicen «Revisar» y no dejan ver el OR (hallazgo 7). Según el papel, son un intercambio de 4 por 4 entre líneas: el 142, el 148, el 138 y el 130 (CRLY) en reservas de ONE, y el 67, el 62, el 63 y el 69 (ONE) en reservas de CRLY. Es lo que el muelle anotó como «30 × 40' HC vacíos (Crowley + ONE)»: el mismo tipo y el mismo destino, PAMIT. Todas las reservas quedaron llenas;
  - en una celda se equivoca el papel y no la app. El papel tiene el OR 136 dos veces, en la 010-04-84 y en la 010-02-08, y el 135 en ninguna; la app tiene el 136 en la 010-04-84 y el 135 en la 010-02-08. Un OR no puede estar en dos celdas: un BAPLIE digitado desde el papel habría repetido un contenedor y dejado fuera otro.
- **En la 010-06-06, el papel tiene el 144 escrito sobre otro número:** se corrigió hasta coincidir con la app, que a las 19:25 del 1-nov ya lo tenía ahí.
- **Lo que sale en una sola foto también cuadra con el plan:** en el papel, las bahías 09, 11 y 22; en la app, la 03, la 26 y la 30.

**Los hallazgos:**
1. **P1 · El plan de carga no entra en una operación ya publicada.** En el buque, la descarga y la carga van a la vez, y el plan de carga llega o se corrige después de publicar. Va a **T-130**: que una operación publicada acepte el plan que le falta, con el mecanismo de T-127. Reemplazar un plan que ya tiene movimientos se decide en el diseño. Plazo de Carlos: antes del 7-nov.
2. **P2 · La lista del piloto cargaba el plano de llegada (1.8) después de publicar (1.7).** Se corrige en este mismo commit: los dos pasos cambian de lugar.
3. **P2 · Una equivalencia elegida en un plan equivocado contamina las importaciones siguientes,** porque lo guardado manda aunque los contenedores la contradigan. Sin la corrección, el BAPLIE de salida habría mandado 40 vacíos a JMKCT con la línea COS. Propuesta: no guardar lo elegido sin respaldo, o atarlo al buque y al viaje, y pedir confirmación cuando el plan dice otra cosa.
4. **P3 · Avisar cuando el viaje del listado no es el del plan.**
5. **Corregido · Un vacío en la reserva de otro grupo ya estaba previsto:** pide un motivo, lo deja cargar y lo marca «Revisar» (`ConflictKind.otherGroup`).
6. **P2 (era P3) · La oficina no tiene cómo dar por buena una desviación justificada.** Solo tiene «Deshacer carga» y «Corregir». El cotejo lo muestra: los 8 «Revisar» de la bahía 10 son correctos y se quedan marcados. Propuesta: «Aceptar con motivo», también para varios a la vez, o declarar antes de operar que los vacíos de dos líneas son intercambiables para el mismo tipo y destino.
7. **P2 · La marca tapa el número de orden.** Los 8 «Revisar» son justo las celdas que había que comparar con el papel. Propuesta de Carlos: el OR sigue siendo el texto grande y la marca va pequeña, con su icono, como segunda línea.
8. **P3 · En un teléfono, la oficina y el muelle se ven iguales.** Va a la 10.86.

**Para la tesis, lo que atrapó el cruce:** el plan de otro viaje (0 de 104); las dos equivalencias (3 llenos con datos distintos y 40 vacíos sin grupo); tres peligrosas con el número ONU distinto en el listado y en el plan (OR 79, 122 y 126: UN 2903 contra 2902); los cancelados del listado (OR 49 y 50, reemplazados por el 149 y el 150); y el OR repetido del papel.

**El cierre, como se lo explicó Yov a Carlos el 2-nov:**
- **El muelle:** «0 pendientes» en su modo y el punto verde «Al día» en cada teléfono. Si dice «Enviando», «Sin conexión» o «Revisar», «Nube y cuenta» → «Reintentar», con red. Avisa a la oficina que terminó. No cierra el plano ni borra nada, y guarda el impreso.
- **La oficina, en este orden, porque cerrar no se deshace:**
  1. confirma con el muelle que todos sus equipos están «Al día»;
  2. en «Avance», 0 pendientes; toca cada conflicto y lee su motivo;
  3. «Lista» → «Generar BAPLIE de salida»: lee el resumen, «Copiar cancelados» y «Guardar BAPLIE de salida»;
  4. «Comparar con otro BAPLIE…» con el archivo guardado. Con el plan de carga abierto, «Cargados» son los vacíos de las reservas, «Descargados» lo que el plan traía y no salió, en «Permanentes» aparecen los que cambiaron de celda, y «Reservas sin número» baja a 0 en el segundo;
  5. en la 26043X, antes de enviarlo, `TDT` vuelve a 26043S;
  6. manda a la línea el BAPLIE de salida y los cancelados;
  7. «Nube y cuenta» → «Cerrar operación». Si dice «No se encontró la operación…», es O-128-2: repetir.
- **Del resultado, la app exporta hoy dos cosas:** el BAPLIE de salida y la lista de cancelados. «Exportar PDF», «CSV» y «JSON» (en «Más») exportan el plan como llegó, sin los OR ni lo cargado.

**Yov propone; decide Carlos:**
1. Antes del 7-nov, solo T-130 y T-131 (10.86). El hallazgo 7, si alcanza el tiempo, en la misma versión; si no, después.
2. Después del 7-nov, hacia la 1.0.0:
   - el informe de cierre en PDF: el plano final por bahía con los OR, los movimientos por bahía, los cancelados, los conflictos con su motivo, las horas y la huella del BAPLIE de salida. Reemplaza las fotos del papel;
   - el cierre guiado: una lista en la oficina antes de «Cerrar operación», y un «Terminé» desde el muelle;
   - exportar los movimientos en CSV: OR, contenedor, celda, hora, quién y motivo;
   - «Aceptar con motivo» (hallazgo 6), y los hallazgos 3 y 4;
   - que las exportaciones del plan digan que son del plan («PDF del plan recibido»), para que nadie las confunda con el resultado.
3. Hoy, Carlos genera el BAPLIE de salida de la 26043X sin cerrar todavía, y Yov lo cruza con el plan, el listado y el papel. La 010-02-08 se verifica con el número del contenedor en el registro de la terminal.

La siguiente decisión es la **10.86**.

### 10.86 · El rol, a la vista: el distintivo B, «Filo de metal», va en T-131 (1-nov, 23:41)

**El hallazgo 8 de la 10.85:** en un teléfono, la oficina y el muelle se ven iguales. El aspecto lo decide el equipo (`bayStreamEsMuelle`), no el rol de la cuenta.
- **Carlos (23:09):** los permisos no cambian; el rol va en la cabecera como un distintivo con diseño, no como texto plano.
- **Yov publicó el lienzo «Distintivo de rol · BayStream»** (artefacto privado de Carlos: https://claude.ai/artifact/L9ajRePXVuWAuXcUPV1V9H), con dos variantes en el Honor, en la Web del iPhone y en la laptop: A, «Ficha», con la paleta actual, y B, «Filo de metal», con el cobre y el oro de la presentación del 7-nov, solo en el filo y en el ícono.
- **Carlos eligió B (23:41).** Es el primer cambio visual del rediseño que viene después y entra ya, en la versión que se presenta el 7-nov. Es la única pieza de la app con los metales antes de esa fecha: la decisión del 27-oct, que deja el 3D y el brillo para después de entregar, sigue para todo lo demás.

**La especificación:**

| | Muelle | Oficina |
|---|---|---|
| Fondo, de arriba abajo | #0B3E93 → #082F70 | #16305C → #0E2244 |
| Filo de 1.5 dp, a 135° | cobre: #F8D2B6 → #E0895A (55 %) → #9E5530 | oro: #FFF0C4 → #F2C46D (55 %) → #A87A2C |
| Ícono | `muelle` (U+E017) en #F4B48E | `oficina` (U+E023, nuevo) en #F2C46D |
| Rótulo | «Muelle» en #FFFFFF | «Oficina» en #F4F6FB |

- Los colores no cambian con el tema y van a `BsPaleta`.
- Es una píldora de `alturaChip` (40 en el muelle, 32 en la oficina) con zona táctil de 48 dp, el rótulo en IBM Plex Sans Condensed 600 y sin animación. La forma compacta es solo el ícono, en un círculo con el mismo relleno y el mismo filo.
- **El metal va solo en el filo y en el ícono, nunca de relleno:** así no se confunde con el naranja de «recién movido» ni con el ámbar de «Revisar». Es la única excepción a la escala de un solo tono y a «sin degradados».
- **El rol sale de `operatorProvider`:** con una cuenta autorizada, también la de la caché; sin cuenta o sin autorizar, no hay distintivo. Al tocarlo se abre «Nube y cuenta».
- **Dónde va:** en la banda del muelle, en la segunda fila, a la izquierda de Descarga / Carga; y en el título del viaje, junto al nombre del buque, que cubre la barra superior del teléfono y la cabecera de la oficina. En la laptop no va a la derecha, como en el lienzo: así es una sola regla.
- **Cómo cabe:** primero completo; si no, compacto; y solo después el nombre se encoge, como hoy.

**El orden:**
1. Nube dibuja el ícono `oficina` (U+E023): primero tres conceptos, Carlos elige y después el paquete v3, con los 35 glifos de antes sin cambios. Carlos lo guarda en `C:\Proyectos\baystream-iconos-paquete-v3.zip`.
2. T-131 va a Timonel, en un chat nuevo con Claude Opus 5.5 en Extra, cuando estén el v3 y `lib/` libre. Puede correr mientras T-130 está en su fase de diseño, que solo escribe en `docs/`; si el diseño de T-130 se aprueba antes, su código espera a que T-131 se entregue.
3. Propuesta: Codex acepta T-130 y T-131 juntas, en la candidata que se publica antes del 7-nov.

Los dos prompts están en el proyecto de Yov (`BayStream_Distintivo_de_rol_T131.md`).

La siguiente decisión es la **10.87**.

### 10.87 · La 26043X, cerrada: el BAPLIE de salida cuadra en contenido, y el cotejo encuentra cinco defectos del archivo (2-nov, 18:31)

**Carlos cerró la carga en la laptop, con la cuenta de oficina:**
- «Avance» y el Plano: «Carga 145 de 145», «Llenos 99 de 99», «Vacíos 46 de 46», 8 conflictos y 0 cancelados. El último movimiento fue una carga, el 2-nov a las 03:11.
- «Generar BAPLIE de salida»: «503 contenedores a bordo en la salida.», «Pendientes: 0 de carga y 0 de descarga.», «8 conflictos vigentes.» y «Cancelados vigentes (0)». Después, «Guardar BAPLIE de salida».
- «Cerrar operación»: «Operación cerrada.» al primer intento. O-128-2 no salió; aquí el listado no se revisó después de publicar, lo que sirve a T-129.

**El cotejo de Yov** cruzó el BAPLIE de salida con el plan de carga, el listado, el papel (102 celdas) y las capturas (113 celdas), con scripts que solo leen.
- **La sintaxis cuadra:**
  - UNT cuenta 4262 segmentos, y las referencias de UNH, UNT, UNB y UNZ coinciden;
  - hay 503 celdas y 503 contenedores, sin repetir;
  - ningún grupo queda sin tipo, POL, POD ni línea.
- **El contenido es correcto:**
  - los 358 que siguen a bordo salen idénticos al plan, byte a byte, salvo tres textos (defecto 2);
  - las 145 cargas, 99 llenos y 46 vacíos, salen cada una en su celda física, con el tipo, el destino, la línea y el peso del listado traducidos con las 15 equivalencias, sin una sola diferencia;
  - los 8 «Revisar» de la bahía 10 son los OR que decía el papel: un intercambio de 4 por 4 entre CRLY y ONE, con el que cada línea conserva sus espacios;
  - el 17 y el 123 salen donde quedaron;
  - el peso, 6868.7 t, es el del plan (6708.6 t) más la tara real de los 45 vacíos (157.4 t) más los VGM del listado (2.7 t).
- **El papel tenía un error que la salida confirma:** en la 010-02-08 va el 135, no el 136, que está en la 010-04-84. Se confirma con el registro de la terminal.
- **Del listado no cargaron cinco llenos:** el 49 y el 50 («REEMPLAZO - CANCEL»), y el 75, el 106 y el 150, que no tenían celda en el plan. Falta confirmar que el 75, el 106 y el 150 no subieron. La página del BAPLIE de salida no los menciona.

**Los defectos del archivo, todos del escritor:**
1. **P1 · Las peligrosas pierden datos.** Un lleno con fila en el listado sale armado solo con la fila (`_loaded`), y el DGS queda en clase y número ONU:
   - el 76 pierde el punto de inflamación y el grupo de embalaje;
   - el 79, el 122 y el 126 pierden el grupo de embalaje y la etiqueta, y su número ONU pasa del 2902 del plan al 2903 del listado sin aviso.
2. **P2 · La codificación.** El plan se lee como Latin-1 (`String.fromCharCodes`) y la salida se escribe en UTF-8 (`utf8.encode`), así que las tildes del FTX de tres contenedores de la bahía 26 salen dobles.
3. **P2 · Los pesos.** `weight()` escribe el número tal cual: 21 VGM salen con decimales, y 3 con restos de coma flotante («18837.129999999997»).
4. **P3 · LOC+13 repite el destino en las 145 cargas.** Sale del POT del listado, que es igual al POD en sus 150 filas, y el archivo dice trasbordo donde no lo hay.
5. **P1, latente · Los refrigerados llenos saldrían sin temperatura.** El mismo `_loaded` no escribe TMP: ni la del plan ni la que trae el listado («REEFER TEMP»). También perdería el LOC+83 y los FTX del plan. En este piloto no pasó, porque el único refrigerado que cargó fue un vacío, el OR 45; en una exportación con refrigerados llenos, la salida no llevaría sus temperaturas.

Aparte de los cinco, `TDT` dice 26043X por el rodeo, y eso lo resuelve T-130.

**La copia corregida y las evidencias:**
- Yov preparó una copia del BAPLIE de salida para enviar:
  - corrige el viaje, las tildes, los pesos al kilo, los DGS completos del plan y los LOC+13; lo demás queda igual;
  - lo que sigue a bordo queda idéntico al plan en sus 358 grupos;
  - en el 79, el 122 y el 126 deja el UN 2902 del plan hasta que la declaración de peligrosas diga cuál es.
- Las evidencias del piloto están en un zip que no va a ningún repositorio: las fuentes, los dos BAPLIE de salida, el informe y el CSV del cotejo, los scripts, y las 40 fotos y capturas, con su LEEME y sus huellas.

**Yov propone; decide Carlos:**
1. **T-132 · El BAPLIE de salida, fiel:**
   - cada carga con fila parte del grupo del plan, con los datos del listado encima;
   - si el listado y el plan no coinciden en una peligrosa, la página lo muestra y no elige sola;
   - la salida se escribe con los mismos bytes que se leyeron;
   - los pesos van al kilo, y LOC+13 solo si el POT no es el POD;
   - la página lista las filas del listado que no cargaron.
   - la temperatura de cada refrigerado lleno: la del plan, o la del listado si el plan no la trae.
   Es P1 por las peligrosas y por los refrigerados. Hasta que esté, un BAPLIE de salida con peligrosas o con refrigerados llenos se revisa a mano.
2. **Carlos confirma tres cosas:** si el 150, el 75 y el 106 subieron; el número ONU del 79, el 122 y el 126; y el contenedor de la 010-02-08.
3. **Cerrar la 26043S.** En la nube siguen abiertas también ECO BORA 26042SB y BUQUE PRUEBA T98.

La siguiente decisión es la **10.88**.

### 10.88 · El orden para empezar los cambios del piloto (2-nov, 18:50)

**Carlos pide los prompts para empezar todos los cambios de la tercera prueba piloto.** Yov los deja en este orden. En la carpeta del rediseño, `lib/`, `test/` y `pubspec.*` siguen siendo de una tarea a la vez.
1. **T-129, las corridas** (Timonel, el mismo chat, en Fable 5.1): las seis de la sección 6 de su informe. Con todo en verde, Carlos confirma su bloque de Git.
2. **La revisión corta de T-129** (Codex, en `baystream-qa-r4`), como manda la 10.84.
3. **El ícono `oficina`** (Nube), en paralelo con todo, porque no toca el repositorio.
4. **T-130, fase 1: el diseño** (Timonel, Fable 5.1). Puede ir en paralelo con los pasos 1 a 3, porque solo escribe en `docs/`. Carlos lo aprueba.
5. **T-131** (Timonel, Opus 5.5), cuando T-129 esté en commits y el paquete v3 de Nube esté en `C:\Proyectos\`.
6. **T-130, fase 2: el código**, cuando T-131 se entregue y Carlos haya aprobado el diseño.
7. **T-132 · El BAPLIE de salida, fiel** (Codex), en su propia carpeta y rama: `C:\Proyectos\baystream-t132`, rama `t132-salida`, desde `sprint-4`, si Carlos la abre. Así corre en paralelo y se mezcla después, como T-126. Si no, va después de T-130, en la carpeta del rediseño.
8. **Nace T-133 · La marca no tapa el número de orden** (el hallazgo 7; Timonel). Va después de T-131, si alcanza antes del 7-nov.

**El semáforo:** un comando de Flutter a la vez en la máquina, también con dos carpetas abiertas. Carlos da la luz verde.

**Lo que escribe Yov cuando lleguen los informes:** las aceptaciones de T-131, T-130, T-132 y T-133, y la candidata que se publica antes del 7-nov, con la 0.4.1 adentro.

Los prompts están en el proyecto de Yov (`BayStream_Prompts_Sprint4_3nov.md`).

La siguiente decisión es la **10.89**.

### 10.89 · T-129: el rojo y el verde salen; para que analyze dé cero, la nube falsa pasa a la capa de plataforma (2-nov, 21:26)

**Timonel corrió T-129 sobre `687d68d`.** Lo hizo en un chat nuevo con Opus 5.5, no en Fable 5.1 como decía la 10.88.
- **El rojo:** con el `close()` de `a52d203`, las pruebas 1 y 2 fallan por comportamiento («not_found: No se encontró la operación…») y las otras tres pasan.
- **El verde:** 5 de 5 con el arreglo.
- **`analyze` no da cero:** salen 4 avisos, todos en `test/support/t129_fake_firestore.dart` (`subtype_of_sealed_class` ×3 y `must_be_immutable`). La nube falsa implementa `DocumentReference`, `DocumentSnapshot` y `Query`, que `cloud_firestore` 6.8.0 marca `@sealed`, y la línea base no admite `// ignore:`.

**Carlos autoriza una dependencia de desarrollo: `cloud_firestore_platform_interface` 8.0.6.** Sirve para rehacer la nube falsa en la capa de plataforma, que sí está hecha para extenderse.
- Ya está en `pubspec.lock` como transitiva, así que no se baja nada nuevo.
- Cambia `pubspec.yaml`, en `dev_dependencies`, y en `pubspec.lock` esa entrada pasa a «direct dev».
- El arreglo y `lib/` no cambian.

Después van el rojo y el verde con la falsa nueva, la suite completa y `analyze` en cero. La revisión corta de Codex (10.88, paso 2) se hace sobre ese commit.

**Una corrección a la 10.87:** que la 26043X cerrara al primer intento no pone a prueba O-128-2. El fallo necesita que la oficina escuche el documento de la operación (T-129, 3.5), y esa escucha llegó con T-127, en la 0.4.1. Si la laptop tenía la 0.4.0, no la había. Carlos confirma qué versión tiene la laptop.

La siguiente decisión es la **10.90**.

### 10.90 · T-129 en commits, T-132 revisada e integrada, el diseño de T-130 aprobado con seis ajustes, el orden nuevo y el ícono `oficina` (2-nov, 22:25)

**T-129 está en `2d98f23`** (22:07). La nube falsa quedó en la capa de plataforma, con `cloud_firestore_platform_interface` 8.0.6 como dependencia de desarrollo (10.89):
- `pubspec.yaml` suma cuatro líneas en `dev_dependencies`, y en `pubspec.lock` cambia una sola, de `transitive` a `"direct dev"`;
- el rojo sale +3 −2 por comportamiento, el verde 5 de 5, la suite 1876 de 1876 sin omitidas y `analyze` en cero;
- la falsa monta la app de Firebase de prueba con `firebase_core`, sin otra dependencia.

Yov lo comprobó en el disco. Codex hace la revisión corta (10.88, paso 2) en `baystream-qa-r4`, sobre `2d98f23`.

**T-132 se entregó en `t132-salida`, sobre `687d68d`** (Codex, 21:51):
- Cubre los seis defectos de la 10.87:
  - los llenos parten del grupo del plan (DGS completo, TMP, LOC+83, FTX y RNG);
  - la oficina elige, contenedor por contenedor, cuando el plan y el listado no coinciden en la peligrosa o en la temperatura;
  - la salida conserva los bytes del plan y los pesos nuevos van al kilo;
  - LOC+13 sale solo si el POT difiere del POD;
  - la página lista y copia las filas que no cargaron.
- Trae 36 pruebas nuevas: la suite da 1907 de 1907 sin omitidas, `analyze` en cero y `pubspec.*` no cambia.
- Yov lo revisó en su carpeta: cambian los 12 archivos de su bloque y solo hay datos sintéticos.
- Una observación menor (P3), para la aceptación: su lista de UNOA deja fuera `! " % & * ; < >`, que la norma admite. Bloquea de más; no corrompe.

Carlos la integra en sprint-4 con una mezcla. El cotejo con los datos reales del piloto va en la aceptación de la candidata.

**Carlos aprueba el diseño de T-130** con las cinco decisiones de su 3.14 y seis ajustes de Yov:
1. **La búsqueda mira también las operaciones abiertas de la nube.** Hoy `find` solo mira el equipo, y desde un equipo que no se unió se puede publicar una segunda operación de la misma escala. Si la operación no está en el equipo, la banda lleva a «Unirse», y «Publicar operación» no publica una segunda del mismo buque, viaje y puerto.
2. **El diálogo dice cuándo se publicó la operación.** Con más de una abierta de ese buque en la escala, la app no elige.
3. **El eco antes que el acuse,** la lección de T-129: la oficina que agrega no se avisa a sí misma ni guarda dos veces. `replaceSource` de T-127 tiene el mismo hueco y se cierra igual.
4. **Las reglas:** las dos cláusulas y el ajuste al trozo publicado con `op.createdAt == request.time`, sin accesos de más, porque un lote tiene 20 y Firestore no promete el caché. La batería mide una publicación de cinco trozos y una adición de cuatro.
5. **El nombre del archivo de salida y la nota del viaje los hace T-130** (`OperationSource.voyage ?? operation.voyageNumber`), porque T-132 entra antes en sprint-4.
6. **El cortafuegos de la prueba de punta a punta** lo abre y lo cierra Carlos, solo en el perfil privado.

Reemplazar un BAPLIE queda primero en la lista de después del 7-nov: el plan de carga suele revisarse durante la escala. Timonel estima la fase 2 en unas 19 h. Si el 4-nov en la noche no va por la mitad, lo primero que espera es el viaje distinto, porque en el piloto los dos planos tenían el mismo.

**El orden cambia.** La fase 2 de T-130 no espera a T-131: empieza en `baystream-rediseno` con T-129 y T-132 en sprint-4, sobre una suite de 1912 y `analyze` en cero. T-131 va en su propia carpeta, `C:\Proyectos\baystream-t131` (rama `t131-distintivo`), y se cruza con T-130 solo en `vessel_overview_page.dart`, en funciones distintas. Un comando de Flutter a la vez en la máquina, y nunca dos suites completas a la vez.

**El ícono `oficina`: Carlos elige la propuesta (a)**, la pantalla con la rejilla del plano calada sobre su pie, que es la elección que le dejaba la 10.86. Yov también votó por la (a): es la que mejor se lee a 18 px, la más cercana al peso de `muelle` (92 frente a 75) y dice «el plano en pantalla». Nube entregó el paquete v3 (22:15) y Yov lo revisó:
- de 86 archivos, 73 son idénticos al v2 del repositorio, 12 cambian y 1 es nuevo (`svg/oficina.svg`), como dice su LEEME;
- en la fuente 1.2, los 35 glifos de antes conservan contorno, avance y código, `oficina` va en U+E023 y las métricas no cambian;
- el SVG es el de la propuesta (a), trazo a trazo, y el nombre de la fuente no trae datos personales.

Además del ícono, cambian cinco fuentes del generador (`generar.py`, `iconos.py`, `fuente.py`, `comprobar_skia.py` y la plantilla del LEEME), declaradas por Nube, para que `oficina` caiga en U+E023 sin mover los 35. T-131 copia los 13 archivos que el LEEME da por cambiados o nuevos. El paquete no se versiona desde la sesión de Nube: entra con T-131.

**Pendiente:** Carlos confirma la versión de BayStream de la laptop (10.89).

La siguiente decisión es la **10.91**.

### 10.91 · La revisión corta de T-129 no pasa por un P2: el plazo del cierre se reinicia (2-nov, 22:45)

**Codex revisó T-129 sobre `2d98f23` (`docs/t129/revision-codex.md`). El dictamen es NO PASA, por un P2.**
- **Lo que sale bien:** las cinco pruebas en verde; el rojo de `a52d203`, +3 −2 por comportamiento; la suite, 1876 de 1876 sin omitidas, y `analyze` en cero. El criterio que acepta la instantánea es correcto, y la falsa usa la capa de plataforma sin clases selladas.
- **El P2:** en `_afterOwnWrite`, `.timeout(_networkTimeout)` va antes de `firstWhere`, y `Stream.timeout` reinicia los 45 s con cada evento, también con los que el filtro descarta. Con instantáneas rechazadas cada 40 s, el cierre sigue esperando a los 160 s. Yov lo comprobó en el código.
- **La corrección:** filtrar antes del plazo (`where(…).timeout(…).first`), con pruebas de silencio y de eventos rechazados sostenidos que exigen el `timeout` a los 45 s y ninguna escucha abierta.
  - La hace el chat de T-129 en `baystream-rediseno`, sobre sprint-4 con T-132.
  - Va antes de que empiece la fase 2 de T-130, que toca el mismo archivo.
  - Codex la vuelve a revisar.
- **El caso del emulador** (O-128-2, la oficina en Chrome) no se corrió. Queda para la revisión de la corrección, si la máquina está libre, o para la aceptación de la candidata.
- **Para después del 7-nov:** `flutter analyze` lee los `.dart` de `build/`. Timonel vio 129 avisos falsos y Codex tuvo que analizar una copia preparada. Conviene excluir `build/` en `analysis_options.yaml`.

La siguiente decisión es la **10.92**.

### 10.92 · La corrección de T-129 y tres definiciones de T-131 (2-nov, 23:20)

**El P2 de T-129 quedó corregido** (10.91), sobre `733a8ab`:
- **El arreglo.** En `_afterOwnWrite`, el filtro va antes del plazo (`where(criterio).timeout(45 s).first`). Las instantáneas descartadas ya no reinician los 45 s, y la escucha se suelta al llegar la buena o al vencer el plazo. Yov lo comprobó en el código.
- **Las pruebas nuevas.** Son dos, con el reloj simulado: una en silencio y otra con rechazos a los 40, 80, 120 y 160 s. En las dos, `timeout` a los 46 s, ninguna escucha abierta y la copia local abierta.
- **La falsa** gana `holdEcho` y `emitRejected`, y las cinco pruebas de siempre no cambian. Carlos autorizó tocarla: el encargo pedía usar la falsa y a la vez no tocar ese archivo, una contradicción de Yov.
- **Las cifras.**
  - El rojo, contra el `lib/` de `2d98f23`: +6 −1, con la falla en la de rechazos sostenidos.
  - El verde, 7 de 7.
  - La suite, 1914 de 1914 sin omitidas, y `analyze` en cero.
  - `pubspec.*` no cambia.
- **El reloj simulado.** La cancelación de `Stream.timeout` termina en la zona raíz, que el reloj simulado no corre. Las pruebas le dan vueltas reales con `tester.runAsync` (6.4 del informe de T-129).

Codex la vuelve a revisar sobre la punta nueva. La fase 2 de T-130 empieza sobre 1914.

**T-131: tres definiciones de Carlos** (23:12 a 23:15):
1. **El distintivo va a la derecha del bloque nombre + viaje**, centrado en su alto, y no en la línea del nombre.
   - Con la zona táctil de 48 dp, el título pasaba de 38 a 65 dp: la barra del teléfono (56) lo recortaba y la cabecera de la oficina crecía de 64 a 81.
   - Así nada crece. Si el viaje es más largo que el nombre, el distintivo queda después del viaje.
2. **El contraste sobre la banda del muelle** (#0D47A1). Ahí el relleno no separa (1.2 a 1.8:1).
   - La prueba exige 3:1 al filo en su tono central (cobre 3.25, oro 5.30) y en el claro.
   - El extremo oscuro (cobre 1.56, oro 2.25) se informa sin exigirse: es la sombra del metal, y el distintivo se reconoce por su ícono (5.5:1) y su rótulo (9.9:1).
   - Corrige la especificación del distintivo (10.86), que daba el filo a 3:1 en toda la banda. En el papel claro y en la noche pasa entero.
3. **El reporte de `tool/rediseno_contraste.py`**, `docs/rediseno/fase2bis/contraste.md`, se regenera con los pares nuevos y va en el bloque por su ruta exacta. Carlos autorizó ese archivo de `docs/`, y solo cambia la sección del distintivo.

**Pendiente:** la versión de BayStream de la laptop (10.89).

La siguiente decisión es la **10.93**.

### 10.93 · T-129 pasa la segunda revisión de Codex y queda cerrada; T-130 arranca sobre 1914 (2-nov, 23:40)

**Codex volvió a revisar T-129 sobre `a18d2d3` (sección 9 de `docs/t129/revision-codex.md`). PASA:** el P2 queda cerrado y no hay hallazgos P1, P2 ni P3 nuevos.
- El cierre responde entre los 44 y los 46 s y cancela la escucha, también con rechazos sostenidos.
- Las 7 pruebas de T-129 y las 3 sondas de Codex salen en verde. La suite da 1914 de 1914 sin omitidas, y `analyze` en cero sobre la copia preparada con fuentes idénticos.
- El emulador quedó fuera; el caso de O-128-2 en Chrome pasa a la aceptación de la candidata.

T-129 entra en la candidata que se presenta el 7-nov (10.84).

**T-130 empezó su fase 2 (23:28).** Su base dio `analyze` en cero y la suite 1914 de 1914. Esa suite corrió a la vez que la ventana exclusiva de Codex, porque el «Listo» de Yov no le recordó pedir la luz verde; Codex repitió sus sondas y `analyze` en otra ventana. Desde ahora, cada programador pide la luz verde a Carlos antes de cada comando de Flutter. El orden de la luz verde es T-130 primero, porque es la tarea que más tiempo necesita para llegar al 7-nov, y después T-131.

La siguiente decisión es la **10.94**.

### 10.94 · T-130 entregada y revisada; dos definiciones más de T-131 (3-nov, 01:10)

**T-130 entregó la fase 2** (Timonel, Fable 5.1, 01:00), sobre `a18d2d3`:
- **Las pruebas.**
  - Las 37 nuevas (dominio 18, pantallas 10, adaptador 9) salen en verde. Contra `a18d2d3` no compilan (254 errores, por el contrato nuevo, como en T-127).
  - La suite da 1951 de 1951 sin omitidas, y `analyze` en cero antes y después.
- **Las reglas en el emulador.**
  - Contra las de T-130: T-80 69 de 69, T-113 25 de 25, T-127 31 de 31 y T-130 38 de 38.
  - Contra las de T-127: las tres de siempre dan lo mismo, y la de T-130 cae en 11, todas donde debe.
  - El emulador no informa el límite de accesos. La cuenta a mano da 3 accesos por trozo: 17 al publicar cinco trozos y 14 al agregar cuatro, bajo el límite de 20.
- **Los seis ajustes de la 10.90 están:**
  1. la búsqueda cruza la nube (5 s; si no responde, lo local) y la banda lleva a «Unirse»;
  2. «Publicar operación» se niega ante otra abierta del mismo buque, viaje y puerto;
  3. el diálogo dice cuándo se publicó la operación y, con varias abiertas, no elige;
  4. el registro de escrituras propias en vuelo, que vale también para `replaceSource` de T-127;
  5. el trozo publicado se ata con `op.createdAt == request.time`;
  6. el nombre del archivo de salida y su nota llevan el viaje del plan de carga.
- **Yov lo revisó.** Cambian exactamente los 27 archivos del bloque. `pubspec.*`, `lib/main.dart`, las reglas de T-80 y T-127 y el escritor de la salida no cambian. En `vessel_overview_page.dart` toca las importaciones, tres líneas de `build()` y `_askForGeometry`. La mezcla de tres vías con T-131 en ese archivo sale sin conflictos.
- **Para la publicación.** Carlos publica las reglas de T-130 desde la consola (sección 10 del informe; huella normalizada `8B903949…`), después de la aceptación de Codex y antes de los clientes de la 0.4.2. La prueba de punta a punta (la laptop y el Honor contra el emulador, 3.10) va en la aceptación.
- Los cambios de la lista del piloto (sección 11 del informe) los integra Yov.

**T-131: dos definiciones más de Carlos (00:15 y 00:39), y lo que Yov pidió antes del commit:**
1. **En la banda del muelle,** si ni el compacto deja enteros «Descarga» y «Carga» (360 dp con la letra a 2.0), va sin distintivo.
2. **En la cabecera, el alto manda.**
   - El selector de modo conserva sus rótulos y el distintivo cede primero: completo; si no, compacto; si no, el nombre encogido, solo si el alto no cambia; y si no, sin distintivo.
   - La cabecera mide lo mismo con distintivo y sin él. A 1366 con la letra a 2.0 va sin distintivo, en 92 dp; antes del ajuste pasaba a dos líneas (144 dp).
3. **La evidencia de `build/t131/` no va a Git,** como en T-129 y T-132. Además, uno de sus registros trae una ruta con el usuario de Windows.

Para la línea base de `analyze`, T-131 copió de `baystream-t132` la entrada generada de T-124 (`build/t124/entradas/t124_entradas.dart`, fuera de Git).

**Para después del 7-nov:**
- Que `tool/t124_main.dart` no dependa de un archivo fuera de Git: toda carpeta nueva da `analyze` con 3 errores, y ya van tres veces.
- Excluir `build/` del analizador (10.91).
- Dos observaciones anteriores a T-131, en el teléfono: la línea «Bahía 02, carga: nada pendiente» mide 21 dp y no pasa la pauta de toque, y el peso por pila «110.0+?» queda a 4.33:1.

La siguiente decisión es la **10.95**.

### 10.95 · T-131 y T-133 en sprint-4; la candidata 0.4.2 queda para el 3-nov; las pruebas de Android, con una tablet en el emulador (3-nov, 01:50)

**T-131 está en sprint-4.** Su rama entró con la mezcla `725a74e` (01:11), sin conflictos. La suite de T-131 dio 2012 de 2012 y `analyze` cero.

**T-133 está en `4b939f3`** (Timonel, Opus 5.5, 01:44):
- **Lo que cambia.** Con marca, `BsCelda` conserva el código como texto grande y pone la marca debajo, con su ícono y su rótulo. Si no caben, gana el código. El relleno, el borde y la etiqueta accesible no cambian.
- **El caso del piloto.** Las 8 reservas de la bahía 10 dicen ahora «OR 130 · Revisar», «OR 148 · Revisar»…
- **Las cifras.**
  - Antes de tocar nada, su paso 0 dio la suite 2051 de 2051 y `analyze` cero, lo que confirma la mezcla de T-131.
  - Al cerrar, la suite da 2097 de 2097: son 46 pruebas nuevas, y se ajustaron 9 que buscaban el rótulo y con la fuente cuadrada de las pruebas ya no cabe.
  - `analyze` en cero; `pubspec.*`, `domain/` y `data/` no cambian.
- **Definiciones de Carlos** (01:15 a 01:45):
  - la marca va a 11 en el muelle, el mínimo de `DESIGN.md` 4.2, y a 10 en la oficina;
  - «Cancelado» pasa a «Cancel.», como «Re‑est.» (10.28);
  - «Bajando» y «Subiendo», que duran 1.5 s, quedan solo con su ícono;
  - en Descarga, el texto grande es ahora el código (en la vista «Destino», el puerto, GTSTC o PAMIT) y el estado va debajo. Carlos lo acepta así.
- **Para la aceptación (RNF-002):** cada celda con marca mide su rótulo al dibujarse, solo en la bahía a la vista, y Timonel no midió ese costo. Se revisa en el Honor con una bahía llena de marcas.

**La candidata 0.4.2 queda para el 3-nov.** Trae T-129, T-130, T-131, T-132 y T-133.
- La aceptación de Codex incluye:
  - la suite y `analyze` en la punta;
  - la prueba de punta a punta de T-130, con la laptop de oficina y el Honor de muelle contra el emulador de Firebase;
  - T-132 con los datos reales del piloto, fuera del repositorio;
  - el cierre de T-129 (O-128-2) en el emulador;
  - el distintivo de T-131 y las marcas de T-133 en el Honor;
  - la prueba del pellizco y Ctrl + rueda de Carlos en el `.exe`, Chrome y Edge.
- Después, Carlos publica las reglas de T-130 desde la consola y, al final, los clientes de la 0.4.2.

**El pellizco del touchpad** (consulta de Carlos, 01:38) no falla: entró con T-119 en la línea de la 0.4.1, y la `v0.4.0` (`be532ab`) no lo trae. La laptop y la Web publicada siguen en la 0.4.0, y por eso ahí no funciona. Carlos ya lo había probado el 29-oct en `qa-r4`: «todo pasó».

**Las pruebas de Android, desde el 3-nov.** El teléfono es el Honor, conectado por depuración USB. Cuando haga falta un emulador de Android, es una tablet, no un teléfono.

Con el Honor por USB, la prueba de punta a punta de T-130 puede llegar al emulador de Firebase de la laptop con `adb reverse` (8383 y 9399). Así no hace falta abrir el cortafuegos ni escuchar en `0.0.0.0` (ajuste 6 de la 10.90).

**Pendiente:** Carlos confirma la versión de BayStream de la laptop (10.89). Todo apunta a la 0.4.0.

La siguiente decisión es la **10.96**.

### 10.96 · T-134 entregada y revisada; la lista del piloto pasa a la 0.4.2; la aceptación de Codex va sin el Honor (3-nov, 10:50)

**T-134 está entregada** (Timonel, Opus 5.5, sobre `a9bbc05`; `docs/T134-RESULTADOS.md`):
- `pubspec.yaml` cambia dos líneas, `version: 0.4.2+8` y `msix_version: 0.4.2.0`, y conserva el CRLF. `pubspec.lock` no cambia.
- La prueba de T-93 da 5 de 5, `analyze` cero y la suite 2097 de 2097, sin omitidas, en 2:14. Timonel no compiló los clientes: los compila Codex en la aceptación.
- **Yov lo revisó contra el disco:**
  - deshechas las dos líneas, `pubspec.yaml` es el de `a9bbc05`, y `pubspec.lock` es el mismo;
  - los otros 694 archivos con seguimiento de `lib/`, `test/`, `tool/`, `integration_test/`, `android/`, `windows/`, `web/` y la configuración coinciden con `a9bbc05`, sin contar el fin de línea; lo que sobra son archivos generados que Git ignora;
  - los registros de `build/t134/` dicen lo mismo que el informe.
- **El 8 y no el 7:** el 7 era de la 0.4.1, que no se subió a Play. Play solo exige que el número suba, y el último subido es el 6.
- **O-128-1 sigue:** `tool/t93_msix.ps1` arma la 1.0.0.0 si no se le pasa `-Version`. La lista lo llama con `-Version 0.4.2.0`.

**La lista del piloto pasa a la 0.4.2** (`docs/piloto/LISTA-PILOTO.md`, Yov):
- las reglas de T-130 en 0.1 y 4.0, con la huella `8B903949…`. El respaldo de 4.0 acepta las de T-80 o las de T-127 y dice cuáles eran: deberían ser las de T-80, porque las de T-127 iban con la 0.4.1;
- 1.18, 1.19 y 2.16 son nuevos, y 1.7 deja de ir solo antes de publicar (sección 11 de T-130);
- 1.13 y 1.14 traen la página de T-132 y el viaje del plan de carga; 1.15, el cierre de T-129; 1.6 y 2.2, el distintivo; 2.3, 2.5 y 2.7, las marcas de T-133;
- la sección 4 es la de la 0.4.2: el AAB 8, el MSIX 0.4.2.0 encima de la 0.4.0.0 o de la 0.4.1.0, y la Web 0.4.2 (8). Si hay que volver a la 0.4.0 en Android, va con el `versionCode` 9;
- la sección 5 trae la regla de uso de T-130 (3.8) y lo que no se midió: el costo de las marcas en el Honor (RNF-002).

**Dos cosas que Yov encontró al leer el código, para la lista:**
1. **0.7: cerrar las operaciones de pruebas y pilotos anteriores que siguen abiertas** (10.87, punto 3).
   - La búsqueda de T-130 es por buque y escala, de cualquier viaje (`OperationSources.lookup`). Con la 26043S abierta, al abrir el plan del próximo MAGELLAN STAR en GTSTC, la banda propondría agregarlo a la 26043S en vez de abrir una operación nueva.
   - Las que se conocen son MAGELLAN STAR 26043S, ECO BORA 26042SB y BUQUE PRUEBA T98. Una operación cerrada no se reabre: Carlos decide cuáles cierra.
2. **Cada corrida contra Firebase de verdad lleva un viaje propio.**
   - Un equipo que ya tiene una operación publicada de un buque, viaje y escala la vuelve a encontrar, aunque esté cerrada (`OperationSources.find`), y no abre otra: «La operación de esta escala ya está cerrada y sus BAPLIE no cambian…».
   - La lista de la 0.4.1 tenía ese choque: su 0.7 cerraba la M100, y el ensayo volvía a usar la M100 en los mismos equipos. En una escala real es lo correcto, así que no es un defecto.
   - Las copias de «Datos» cambian el viaje de `TDT`: P130 y P130N para 0.8, y E042 para el ensayo. Llevan sus huellas, y el listado sirve para cualquier viaje.

**0.8 es la prueba de punta a punta de T-130 contra Firebase de verdad,** con la laptop de oficina y el Honor de muelle: 11 pasos y una mirada a la consola, en lugar de la de T-127. T-127 queda en 1.17 y 2.15 del ensayo.

**Corrección a la 10.95: el Honor no recibe compilaciones locales.**
- Su app es la de Play (`gt.cmartinez.baystream`), firmada con la clave de la app que guarda Play.
- Una compilación local lleva otra firma con el mismo `applicationId`, y no se instala encima. Ante eso, `flutter run` desinstala sola la de Play («Uninstalling old version...») y se lleva el almacén del Honor.
- La regla de la sección 2 sigue: no se tocan las apps instaladas. Por eso, en la aceptación:
  - el muelle contra el emulador de Firebase va en una tablet del emulador de Android;
  - lo propio del teléfono (la banda con el distintivo, las marcas a 360 dp) se mira en la Web del banco a 360 × 800, como en T-128;
  - el Honor se desconecta del USB mientras dura la aceptación. Se prueba con la 0.4.2 de Play, en 0.8 y en el ensayo, con la vuelta de 4.5 si algo falla.
- Con `adb reverse`, el modo avión de la tablet no corta el camino al emulador, que va por adb. La caída de red se simula quitando el túnel, o con `T130_HOST=10.0.2.2`.

**La aceptación de Codex,** en `baystream-qa-r4`, con HEAD separado en el commit de esta decisión. Lo que entra:
1. la suite y `analyze` en una copia limpia;
2. T-130: sus pruebas, las ocho corridas de las baterías y la prueba de punta a punta de 3.10, con la oficina en Chrome y el muelle en la tablet. Su paso 12 es también el cierre de T-129 (O-128-2) con el motor siguiendo la operación;
3. T-132 con los datos reales del piloto, que Yov dejó en `%TEMP%\t134acc-piloto`, fuera de todo repositorio: la salida del escritor nuevo, contra la copia corregida a mano el 2-nov;
4. T-131 y T-133 en la Web a 360 × 800, en la oficina y en la tablet;
5. las compilaciones de los tres clientes de la candidata;
6. los diez bloques de PowerShell de la lista, con el analizador y sin correrlos;
7. el pellizco y Ctrl + rueda, que Carlos prueba a mano en el `.exe`, en Chrome y en Edge, con el namespace `r4`.

El informe es `docs/t134/aceptacion-codex.md`, como el de la 0.4.1.

**Después:** Yov anota en la lista lo que encuentre Codex. Carlos publica las reglas de T-130 desde la consola (4.0), mezcla (4.1) y publica los clientes (4.2 a 4.4). Al final hace 0.7, 0.8 y el ensayo.

La siguiente decisión es la **10.97**.

### 10.97 · Codex acepta la 0.4.2 con reservas; la lista, al día; falta decidir T-135 (3-nov, 13:15)

**Codex aceptó la candidata con reservas** (`docs/t134/aceptacion-codex.md`), sobre `15ef04b` (10.96):
- **Lo que pasa:**
  - la suite da 2097 de 2097 en una corrida, sin omitidas, y `analyze` cero, en una copia limpia de 809 archivos que siguió idéntica a HEAD;
  - las baterías: 69, 25, 31 y 38 contra las reglas de T-130, y la de T-130 cae en sus 11 contra las de T-127;
  - los tres clientes compilan y dicen 0.4.2 (8). El AAB lleva la firma de depuración: acredita la compilación, pero no es el que va a Play;
  - **T-132 con los datos reales del piloto:** 503 de 503 celdas, 358 de 358 grupos de paso byte a byte, 4 de 4 DGS completos, ningún peso con decimales, ningún LOC+13 con el POT igual al POD y UNT con 4117. Contra la copia corregida de Yov no hay ninguna diferencia en los grupos: la única es la de `TDT`, que Yov cambió a mano. La página pidió 3 decisiones, todas de peligrosas (UN 2902 contra 2903), y guardó una vez;
  - **T-130 y T-129:** los 15 pasos de 3.10 y las dos variantes contra el emulador, con la oficina y el muelle en Chrome. El cierre sale al primer intento, después de revisar el listado. Las cifras y los textos de 0.8 son los de la lista, con M100 en vez de P130;
  - **T-131 y T-133:** el distintivo dorado de la oficina a 1280 y a 1920 y, en la Web a 360, el compacto de cobre en la barra de arriba. En la tablet, las marcas con la densidad del muelle: 56 × 48 y el rótulo a 11;
  - los diez bloques de PowerShell pasan el analizador sintáctico (PSScriptAnalyzer no está instalado), y el bloque de «Datos» da sus cuatro «Listo»;
  - Carlos probó a mano el pellizco y Ctrl + rueda en el `.exe`, en Chrome y en Edge, con el namespace `r4`: pasan.
- **Las reservas** son de validación: no hay ningún P1 ni P2 del producto.
  - **O-134-1:** al preparar la prueba de Windows, el ayudante de Codex abrió la app instalada (0.4.0.0) en vez del `.exe` del banco. Codex la cerró sin tocar nada, pero no puede descartar que al abrirse leyera su almacén o la nube; es lo mismo que abrirla a mano. El bloque de 4.2 respalda el almacén antes de instalar. Codex no vuelve a usar ese ayudante: el `.exe` del banco lo abre Carlos desde el Explorador.
  - **O-134-2:** en la tablet, el banco no sincroniza. Primero le faltaba la app `[DEFAULT]` de Firebase, que Codex puso en una entrada privada; después, Android bloqueó el HTTP sin cifrar hacia el emulador («Cleartext HTTP traffic to 127.0.0.1 not permitted»). No se cambió `android/`, y la app publicada va por HTTPS. Android contra la nube se prueba por primera vez con el Honor, en 0.8. Para después del 7-nov: un banco de Android que llegue al emulador, con una configuración de red solo para depuración.
  - **O-134-3:** el punto 4 del encargo pedía la banda del muelle en la Web, pero la Web nunca tiene la densidad del muelle (`bayStreamEsMuelle` exige `!kIsWeb`). Yov lo corrigió: la banda queda para el Honor.
- **Dos P3:**
  - **O-134-4:** «Archivo "null" cargado correctamente», al confirmar un plano en previo desde «Parámetros» y no con la banda. Viene de la 10.32, y Carlos lo vio en los tres clientes. Codex confirmó la causa en el código: ese camino llama a `_askForGeometry` sin `fileName`.
  - **O-134-5:** con un corte de red simulado, el chip tardó más de medio minuto en pasar a «Sin conexión», y el plan agregado llegó solo, pero después de medio minuto de vuelta la red. No es una garantía de latencia: la lista espera un minuto antes de «Reintentar».

**Yov lo revisó contra la evidencia:**
- la huella del informe es la de `entrega-verificacion.json` (`3df4e2b4…`), con sus 39 capturas;
- la suite registra 2097 aprobadas, `analyze` dice «No issues found!», y los resúmenes seguros de T-132 dicen lo mismo que el informe;
- el informe no trae ningún número de contenedor;
- Yov miró cuatro capturas: el diálogo de T-130 con sus cifras y su viaje, el distintivo de la oficina a 1920, las marcas a 360 y la tablet con «Baja» y «Paso» debajo del código.

**La lista del piloto, al día** (`docs/piloto/LISTA-PILOTO.md`):
- el resultado de la aceptación, arriba;
- en 1.2, que el plano se confirma desde la banda;
- en 1.18, que sin el perfil del buque la operación se busca al confirmar los parámetros;
- las esperas de un minuto en 0.8, 2.13, 2.15 y 2.16, y O-134-2, O-134-4 y O-134-5 en la sección 5;
- **en 4.1, una comprobación nueva:** la mezcla se detiene si `sprint-4` trae código distinto del que aceptó Codex (`15ef04b`).

**El commit del informe de Codex** va desde `qa-r4`, con HEAD separado, como en la 0.4.1 y en las revisiones de T-129. Después, la carpeta del rediseño se pone al día con `git pull --ff-only` antes de su propio commit.

**Decide Carlos: T-135, el «null» (O-134-4).**
- **A:** T-135 antes de publicar. Es una línea y su prueba; Codex revisa el cambio corto, y la comprobación de 4.1 pasa al commit revisado.
- **B:** publicar la 0.4.2 como está, y T-135 después del 7-nov. En la presentación, el plano se confirma con la banda.

**Después:** las reglas de T-130 (4.0), la mezcla (4.1) y los clientes (4.2 a 4.4); al final, 0.7, 0.8 y el ensayo.

La siguiente decisión es la **10.98**.

### 10.98 · T-135 pasa la revisión corta de Codex; la 0.4.2 queda lista para publicar (3-nov, 13:55)

**T-135 corrige O-134-4** (Timonel, Opus 5.5; `fd39951`; `docs/T135-RESULTADOS.md`). Carlos eligió la opción A de la 10.97, corregirlo antes de publicar; Timonel ya había empezado.
- Con un plano en previo, `_askForGeometry` usa `fileName ?? notifier.loadedFileName` para «Archivo: …» y para el aviso final. En la edición no cambia nada, y el diálogo de T-130 queda igual.
- La prueba nueva, `test/t135_aviso_archivo_test.dart`, recorre los tres caminos: la banda, «Parámetros» en el riel de la oficina y «Parámetros» en «Más» del teléfono. Contra `15ef04b`, los dos de «Parámetros» fallan por comportamiento y la banda pasa.
- La suite da 2100 de 2100, sin omitidas, y `analyze` cero.
- **Yov lo revisó contra el disco:** solo cambian `vessel_overview_page.dart` (+5 −2) y la prueba, y los registros de `build/t135/` dicen lo mismo que el informe.

**Codex: PASA** (`docs/t135/revision-codex.md`, sobre `fd39951`):
- los 3 casos en verde; el rojo contra `15ef04b`, 1 verde y 2 rojos, por el texto que falta; la suite, 2100 de 2100 sin omitidas, y `analyze` cero, en una copia limpia de 810 archivos;
- Carlos lo confirmó a mano en Windows, Chrome y Edge, con el banco `r4` recompilado: «Archivo: T100_CARGA.edi» en la pantalla y «Archivo "T100_CARGA.edi" cargado correctamente» al confirmar. Abrió el `.exe` desde el Explorador, no con el ayudante (O-134-1);
- O-134-4 queda cerrado. La versión sigue siendo `0.4.2+8`: T-135 entra antes de publicar.

**La lista del piloto:**
- T-135 entra en «Qué es la 0.4.2»;
- 1.2 y la sección 5 ya no avisan del «null»: si vuelve a salir, es un fallo nuevo;
- **la comprobación de 4.1 apunta a `fd39951`,** el último código que revisó Codex: desde ahí, solo pueden cambiar documentos.

**Ahora publica Carlos,** con la sección 4 de la lista:
1. las reglas de T-130 desde la consola (4.0);
2. la mezcla a `master` y la etiqueta `v0.4.2` (4.1);
3. Windows, Android y la Web (4.2 a 4.4).

Después, 0.7, 0.8 y el ensayo.

La siguiente decisión es la **10.99**.

### 10.99 · Se publica la 0.4.2; T-136, el parche de seguridad de Firestore en Windows, es la candidata 1.0.0; Carlos pide un instalador con asistente (3-nov, 14:25)

**El aviso de Firebase** (correo del 3-nov, «[Act Now] Upgrade your Firebase SDKs for Firestore to apply an urgent security patch», proyecto `baystream-app`). Se filtraron las claves de unas CA intermedias de eMudhra, y con ellas se pueden falsificar certificados HTTPS. La guía de Firebase (`compromised-emudhra-intermediate-ca`, actualizada el 3-nov) da las versiones corregidas y dice que actualizar el sistema operativo o el servidor no arregla las compilaciones ya instaladas. Para BayStream:
- **Windows está afectado.** Firestore va por el SDK de C++, que trae sus propias raíces. Con `firebase_core` 4.13.0 el SDK es el 13.9.0, y así lo dicen los `version.h` de `build\windows\x64\extracted` en `proyecto-baystream`, `baystream-rediseno` y `baystream-qa-r4`. Lo llevan la 0.4.0.0 instalada y la 0.4.2.0 que se publica hoy. El arreglo es `cloud_firestore` 6.10.2 con `firebase_core` 4.15.2, que traen el SDK de C++ 13.13.1 (PR #18869 de FlutterFire, publicadas el 23-oct).
- **Android no:** Firestore y las cuentas van por el SDK nativo de Android, que la guía no da por afectado. **La Web tampoco:** el navegador valida con sus propios certificados.
- **Dart.** La guía pide además Flutter 3.47.8 (Dart 3.13.7) en Android, Windows y Linux, porque `dart:io` valida TLS con su propio BoringSSL. En BayStream, `lib/` usa `dart:io` solo para archivos. Yov revisó los 109 paquetes de `pubspec.lock`: fuera de las herramientas de pruebas, lo único que abre HTTPS desde Dart es la política de contraseñas de `firebase_auth`, que solo baja `validatePassword`, y BayStream no la llama. Subir de la 3.38.9 a la 3.47.8 son nueve versiones menores de Flutter: no entra antes del 7-nov (**O-136-1**, para después).
- **Las reglas y el servidor** no cambian.

**Carlos decidió (14:00):**
1. **La 0.4.2 se publica hoy como se aceptó** (10.98): las reglas de T-130 (4.0), la mezcla (4.1) y los tres clientes (4.2 a 4.4); después, 0.7, 0.8 y el ensayo. Mientras Windows lleve el SDK 13.9.0, en una red que no es de Carlos (un Wi-Fi público o el del puerto) los datos reales van por la Web, en Chrome o Edge, y no por el `.exe`. La sección 5 de la lista lo dice.
2. **T-136 queda autorizada como candidata 1.0.0** (la hace Timonel y la acepta Codex), con el cambio de dependencias. Yov lo comprobó en pub.dev:
   - `cloud_firestore: ^6.10.2` y `firebase_core: ^4.15.2`. Las dos piden Flutter 3.27 o posterior y Dart ^3.6.0, así que basta la Flutter de hoy (3.38.9);
   - la fija de desarrollo `cloud_firestore_platform_interface` pasa de 8.0.6 a **8.0.7**, la única versión posible: `cloud_firestore` 6.10.2 pide ^8.0.7, y la 8.0.8 y la 8.1.0 piden `firebase_core` 5;
   - `firebase_auth` se queda en 6.5.7, porque pide `firebase_core` ^4.13.0;
   - en `pubspec.lock` se esperan siete cambios, todos de FlutterFire: `cloud_firestore`, `firebase_core`, `cloud_firestore_platform_interface`, `cloud_firestore_web` (5.7.3), `firebase_core_platform_interface` (8.1.1), `firebase_core_web` (3.11.0 o 3.12.0) y `_flutterfire_internals` (1.3.77). Si cambia cualquier otro, la tarea se detiene;
   - la versión pasa a `1.0.0+9`, con `msix_version: 1.0.0.0`. Si la vuelta de Android de 4.5 llegara a gastar el 9, queda en `1.0.0+10`;
   - si Codex la acepta a más tardar el jueves 5, se publica la 1.0.0 y la demostración va con ella. Si no, la demostración va con la 0.4.2 y la 1.0.0 llega después (10.74).
3. **Carlos pide mejorar el instalador de Windows:** que sea bonito y diga qué instala y qué hay detrás, con lo que den Dart y Flutter. Hoy el MSIX abre el instalador de aplicaciones de Windows con un solo botón. Es **T-137**. La propuesta y lo que elija Carlos van en la 10.100.

**La trampa del SDK de C++** (la encontró Yov en el `windows/CMakeLists.txt` de `firebase_core`; entre la 4.13.0 y la 4.15.2 solo cambia la versión):
- al compilar Windows, CMake descarga `firebase_cpp_sdk_windows_<versión>.zip` en `build\windows\x64`, pero solo lo extrae si `build\windows\x64\extracted` **no existe**. Si existe, dice «Using cached extracted Firebase SDK» y enlaza lo que haya ahí;
- en las tres carpetas, ahí está el 13.9.0 (8,5 GB). Sin apartarlo, una 1.0.0 con `firebase_core` 4.15.2 seguiría enlazando el SDK afectado.

Por eso:
- T-136 aparta `extracted` antes de su primera compilación de Windows y comprueba en `version.h` que queda el 13.13.1;
- desde T-136, `tool/t93_msix.ps1` lo comprueba antes de empaquetar. Si el SDK extraído no es el que pide el `firebase_core` resuelto, lo aparta antes de compilar o, con `-SinCompilar`, se detiene;
- la aceptación de Codex lo comprueba en su copia, y la lista de la 1.0.0 (4.2), en `proyecto-baystream`;
- cada carpeta necesita unos 9,5 GB nuevos, entre el zip y lo extraído, y la laptop tiene 76 GB libres. Las carpetas apartadas con el 13.9.0 las borra Carlos después de publicar la 1.0.0.

**Lo que sigue:**
1. Carlos publica la 0.4.2 (4.0 a 4.4).
2. Timonel empieza T-136 cuando terminen las compilaciones de la 0.4.2. Hasta entonces, solo lee.
3. Codex acepta T-136.
4. Yov escribe la 10.100, con T-137, y prepara la lista de la 1.0.0.

La siguiente decisión es la **10.100**.

### 10.100 · T-137, el instalador de Windows con asistente: Inno Setup 7.1.1, armado con Dart y dibujado con Flutter (3-nov, 14:35)

**Carlos eligió (14:30) la propuesta de Yov.** Flutter no trae un motor para instaladores: su guía de Windows remite a la MSIX (el paquete `msix`) o a un instalador como Inno Setup o WiX. El motor del asistente es **Inno Setup 7.1.1**, la versión recomendada de jrsoftware.org (28-oct), y todo lo demás es Dart y Flutter. Un instalador hecho todo en Flutter tardaría semanas, porque habría que programar lo que Inno Setup ya hace (copiar, los accesos, el desinstalador, instalar encima, detectar la MSIX), y una app de Flutter no es un solo `.exe`. Para el 7-nov queda fuera.

**T-137 · El instalador de Windows con asistente** (lo hace Codex, lo revisa Timonel y Carlos lo recorre a mano):
- **Qué ve quien instala.** Hoy, el instalador de aplicaciones de Windows, con el logo y «Instalar». Con T-137, un asistente en español: bienvenida → «Qué se instala» → «Lo que hay detrás» → carpeta y accesos → instalar → «Abrir BayStream».
  - Sigue el tema claro u oscuro de Windows, con la paleta de BayStream.
  - No pide administrador, y aparece en Configuración → Aplicaciones con su ícono, su versión y su editor.
  - Instala en cualquier Windows 10 u 11 de 64 bits sin importar el certificado, que la MSIX sí pide en un equipo nuevo.
- **Lo que ponen Dart y Flutter:**
  - las imágenes del asistente las dibuja Flutter, con `BsPaleta` clara y oscura, IBM Plex, el ícono y la ilustración `inicio` (`DESIGN.md` 13), a los tamaños que pide Inno Setup para cada escala: la grande, de 202 × 386 a 534 × 1022, y la pequeña, de 58 × 58 a 159 × 159;
  - un programa de Dart, `tool/t137_instalador.dart`, arma el instalador. Lee la versión del `.exe`, las de `pubspec.lock`, la de Flutter y la del SDK de C++, y comprueba que el SDK enlazado es el que pide `firebase_core` (la trampa de la 10.99). Agrega junto al `.exe` el runtime de Visual C++ que pide la guía de Flutter, comprueba las DLL con `dumpbin` y deja el instalador con su huella y su manifiesto.
- **La app no cambia.** Se empaqueta la misma Release que firma la MSIX, y la MSIX sigue de respaldo. Mientras T-136 no esté, Codex empaqueta la Release de la 0.4.2 que Carlos compila hoy en `proyecto-baystream`, sin cambiarla.
- **La MSIX y el asistente no conviven.** Si la cuenta tiene la MSIX, el asistente se detiene antes de copiar nada y explica cómo quitarla. Los datos no corren riesgo: están fuera del paquete, en `%LOCALAPPDATA%\BayStream` (10.75), y el desinstalador no los toca.
- **Dónde:** `C:\Proyectos\baystream-t137`, rama `t137-instalador` desde `sprint-4`, como T-132. Solo toca `windows/installer/`, `tool/t137_*`, `docs/T137-RESULTADOS.md` y `build/t137/`. No toca `lib/`, `test/`, `pubspec.*` ni `tool/t93_msix.ps1`, que son de T-136. Corre a la vez que T-136, con un comando de Flutter a la vez en la máquina.
- **Las pruebas.** Windows 11 Home no trae Sandbox, así que:
  - en la cuenta de Carlos solo se instala, en silencio, una variante de prueba (otro AppId, otro nombre y otra carpeta), sin abrir la app y con la huella del almacén real igual antes y después;
  - en la cuenta de Carlos, la variante de producción tiene que detenerse por la MSIX;
  - el recorrido a mano lo hace Carlos en una cuenta local de prueba de Windows, «BayStream Prueba», sin la MSIX y sin datos: en claro y en oscuro, abrir y desinstalar. Ahí la app abre con Firebase de verdad, pero nadie inicia sesión.
- **Antes de empezar,** Carlos instala Inno Setup 7.1.1 (`winget install --id JRSoftware.InnoSetup.7 -e`) y abre la carpeta de T-137. La cuenta de prueba la crea antes del recorrido a mano. El sitio de Inno Setup pide licencia a quien lo usa comercialmente, y un proyecto de graduación no lo es.
- **Los límites, declarados:**
  - sin un certificado comercial, el instalador no va firmado: si se descarga de internet, Windows avisa «Windows protegió su PC». Copiado a la laptop, no;
  - no hay un Windows limpio, sin el runtime de Visual C++, donde probarlo: lo cubre la comprobación de las DLL.

**Con la 1.0.0.** Si Timonel da por buena T-137 a más tardar el jueves 5, sale junto con la MSIX, de la misma Release. Si no, sale después, sin cambiar la versión de la app. El jueves, con el asistente a la vista, Carlos decide qué instalación lleva la laptop en la demostración. Yov recomienda el asistente si pasa: se quita la MSIX (los datos se quedan) y la MSIX 1.0.0 queda para volver.

La siguiente decisión es la **10.101**.

### 10.101 · T-136 crece: la Web sirve el SDK 12.19.0 y firebase_auth pasa a la 6.7.1; Carlos va por la 1.0.0 cuanto antes; T-138, «Volver al inicio» (3-nov, 16:35)

**Dos cosas que la 10.99 no previó.** Timonel se detuvo las dos veces, y Yov lo comprobó en los paquetes de pub.dev.
1. **El SDK de JavaScript que sirve la Web (T-92).** `web/vendor/firebase/12.17.0/` es la versión que pide `firebase_core_web` 3.10.0. La 3.11.0 pide la 12.18.0 y la 3.12.0, la 12.19.0, y `firebase_core` 4.15.2 exige la 3.11.0 o posterior. Con la copia vieja fallan tres pruebas de `test/t92_web_test.dart`. **Carlos autorizó la copia 12.19.0**, con el procedimiento del LEEME de T-92:
   - los tres módulos (`firebase-app.js`, `firebase-auth.js` y `firebase-firestore-pipelines.js`) se bajan de gstatic, y la huella original de cada uno tiene que ser igual a la del archivo del mismo nombre en el paquete de npm `firebase@12.19.0`. Con la 12.17.0, las huellas de npm son las de su `provenance.json`;
   - sale `web/vendor/firebase/12.17.0/`, para servir un solo SDK, y `tool/t129_evidencia.py` queda como evidencia de T-129;
   - la Web ya compiló como 1.0.0 (9): `build/web` solo trae la 12.19.0, y `t92_verify` pasa.
2. **`firebase_auth` 6.5.7 no compila en Android con `firebase_core` 4.15.2.** La 4.14.0 reescribió en Kotlin la parte de Android de `firebase_core` y movió `customAuthDomain`. La 6.5.7 lo sigue buscando donde estaba, aunque su pubspec acepte la 4.15.2. Desde la 6.6.0, `firebase_auth` ya está en Kotlin, y la 7.x pide `firebase_core` 5. **Carlos autorizó `firebase_auth` 6.7.1, fija:** la que FlutterFire publicó el 23-oct con la línea 4.15.x. Con ella cambian `firebase_auth_platform_interface` (9.0.7 o 9.1.0) y `firebase_auth_web` (6.2.7 o 6.3.0).

**Lo que eso significa: la 1.0.0 ya no cambia solo Windows.** Cambia el código nativo de Firebase en los tres clientes:
- en Android, el de `firebase_core` y el de las cuentas, reescritos en Kotlin;
- en Windows, el SDK de C++ 13.13.1 y el plugin de las cuentas;
- en la Web, el SDK 12.19.0.

Por eso:
- la aceptación de Codex prueba el inicio de sesión y la sincronización en Windows y en la Web, contra el emulador;
- el inicio de sesión de Android no se puede probar antes de Play, porque el banco del emulador no llega a Firebase (O-134-2). Su primera prueba es en el Honor, apenas suba el AAB;
- si Android falla ahí, Android vuelve a la 0.4.2 con el `versionCode` siguiente (4.5), y Windows y la Web se quedan en la 1.0.0.

**Carlos decidió (16:29) ir por la 1.0.0 cuanto antes, si puede ser antes del jueves.** Yov recomendaba hacer la demostración con la 0.4.2, que queda como la vuelta de los tres clientes (4.5).

**T-138 · «Volver al inicio»** (Carlos eligió la opción A, 15:53). Hoy se vuelve al inicio con «Más» → «Cerrar el plano», en los tres clientes, y en Android también con Atrás dos veces. No se borra nada, pero el camino está escondido, y el subtítulo «Limpia los datos cargados en este dispositivo» suena a borrar. T-138:
- en la oficina (Windows y Web), la marca de BayStream de arriba del riel es el botón «Volver al inicio», sin agregar nada al riel;
- en «Más», en los tres clientes, la entrada se llama «Volver al inicio», con un subtítulo que diga lo que de verdad hace;
- en el teléfono no hay un botón suelto, para que nadie lo toque sin querer en el muelle;
- con un previo, pregunta lo de siempre: «¿Descartar el plano sin confirmar?».

Lo hace Timonel después de T-136 y lo revisa Codex. Entra en la 1.0.0 si pasa a tiempo.

**El orden:**
1. Timonel termina T-136, Yov la revisa y Carlos hace el commit.
2. Codex acepta T-136 en `qa-r4`, con T-137 en pausa, mientras Timonel hace T-138.
3. Codex revisa T-138 y Timonel revisa T-137.
4. Yov prepara la lista de la 1.0.0, y Carlos publica: las reglas no cambian; la mezcla, con `v1.0.0`; el MSIX 1.0.0.0 y, si pasó, el asistente; el AAB y la Web. Después, una prueba corta con el Honor, con su propio viaje.

La siguiente decisión es la **10.102**.

### 10.102 · Codex acepta T-136 con reservas: la sesión nativa de Windows y de Android se prueba al publicar (3-nov, 17:40)

**Codex aceptó T-136 con reservas** (`docs/t136/aceptacion-codex.md`, sobre `5ab830b`).
- **Lo que pasa:**
  - entre `8ea84bd` y `5ab830b` cambian 20 rutas: `SPRINT-4.md`, el informe de T-136 y sus 18 archivos;
  - en `pubspec.lock` cambian los diez paquetes de FlutterFire de la 10.101, y ninguno más;
  - la suite da 2101 de 2101, sin omitidas, y `analyze lib test`, cero, en una copia limpia de 811 archivos que siguió idéntica a HEAD;
  - **Windows:** en `qa-r4`, `-Apartar` no movió nada mientras `.dart_tool` resolvía la 4.13.0, como debe; después de `flutter pub get`, apartó el 13.9.0. La compilación extrajo y enlazó el 13.13.1, `-Verificar` pasa y el `.exe` dice 1.0.0+9;
  - **Web:** `build/web` solo trae la 12.19.0, y sus módulos coinciden con npm y con lo que se sirve por HTTP. `t92_verify` pasa. En Chrome, contra el emulador, todo pasa: el arranque sin errores ni avisos de versiones, la sesión de oficina y la de muelle, un movimiento, el plan agregado (30 contenedores), el listado (30 filas, revisión 1) y el cierre al primer intento;
  - **Android:** el AAB release dice 1.0.0 (9), con la firma de depuración. El APK del banco arranca en la tablet sin caerse: `firebase_core` y las cuentas, ya en Kotlin, se registran bien.
- **Las reservas:**
  - **Windows:** el banco dibujó el inicio, pero la sesión contra el emulador dio «No se pudo iniciar sesión: el servicio de cuentas respondió con un error que BayStream no reconoce…», sin el código nativo, porque no había consola. La misma cuenta funciona en el emulador por REST. El banco de Windows nunca había iniciado sesión contra el emulador, tampoco con la 0.4.2: T-129 y T-130 lo probaron en Chrome. No se sabe si la falla es del banco o de la 1.0.0;
  - **Android:** O-134-2 otra vez: «Cleartext HTTP traffic to 127.0.0.1 not permitted».
- **La excepción a O-134-1.** Carlos estaba fuera de casa y autorizó a Codex a abrir el banco de Windows, solo en esta aceptación y con condiciones: la ruta exacta por `explorer.exe`, sin otra instancia abierta, la ruta y el proceso padre comprobados (Id 37176) y el cierre por Id. El ayudante no abrió nada más. El almacén real quedó idéntico: 592 archivos y la misma huella, leída fuera del paquete.

**Yov lo revisó contra la evidencia:** el resumen de la suite (2101, sin errores), `analyze`, la comparación del almacén real, el diagnóstico de la tablet y que el informe no trae números de contenedor.

**Al publicar la 1.0.0, la sesión nativa se prueba contra Firebase de verdad:**
- **Android sube primero.** Mientras Play procesa el AAB, se publica Windows. En el Honor se prueban la sesión de muelle, «Unirse» y un movimiento antes de seguir. Si falla, Android vuelve a la 0.4.2 (4.5);
- **Windows:** lo primero después de instalar el MSIX 1.0.0.0 es la sesión de oficina. Si falla, Windows vuelve a la 0.4.2.0 en minutos, con los datos intactos, porque están fuera del paquete (10.75);
- **la Web, ya probada, va al final.** Después, la prueba corta de punta a punta, con su propio viaje.

**Lo que sigue:** Codex vuelve a T-137; Timonel termina T-138 y Codex lo revisa; Yov prepara la publicación de la 1.0.0.

La siguiente decisión es la **10.103**.

### 10.103 · La 0.8 pasa con la 0.4.2; T-138 corrige su subtítulo y T-137 sus textos (3-nov, 20:00)

**La 0.8 pasó con la 0.4.2 contra Firebase de verdad.** Carlos (19:46): «el paso a paso salió como esperábamos, todo bien». Es la prueba de punta a punta de T-130 con la laptop de oficina y el Honor de muelle, en la operación de prueba BUQUE MANUAL · P130 · GTSTC, publicada a las 19:16. Sus capturas muestran:
- el paso 4, con dos descargas ya registradas desde el Honor («Descarga 2 de 30»);
- el paso 5: el diálogo «Agregar el plan de carga a la operación publicada», con los tres textos de la tabla, y el aviso «Plan de carga agregado a la operación publicada de GTSTC: 30 contenedores y 0 reservas. El muelle lo recibe solo.»;
- el paso 9: 30 filas en 2 agencias, 20 de 20 llenos cruzan con el plan, y la fila «TOTAL» bajo «1 fila sin entender», que es lo normal (1.4);
- el paso 10: las filas que no cargaron y el nombre `BayStream_BUQUE MANUAL_P130N_salida.edi`;
- el paso 11: «Operación cerrada.», «Fuentes: llegada · carga (viaje P130N) · listado r1» y «No hay operaciones abiertas.»

Con eso, 1.18 (agregar el plan después de publicar) queda para el piloto.

**Un texto para después del 7-nov:** con la operación cerrada, «Nube y cuenta» pone «Operación de la escala abierta» encima de «Publicada y cerrada». «Abierta» es la escala del plano en pantalla, pero se lee como si fuera la operación. No entra en la 1.0.0.

**T-138: Codex dijo NO PASA, y Timonel lo corrigió.**
- **Lo que no pasó** (`docs/t138/revision-codex.md`, `b153048`): el subtítulo «Lo pendiente sube al reabrirlo». Con el muelle en el inicio, el movimiento subió antes de reabrir el plano: la sincronización no se pausa. Timonel lo había leído en el código, no lo había medido.
- **Lo que pasó:** la marca, el hover, Tab y Enter, «Recientes», el previo y los subtítulos a 360, en Chrome.
- **La corrección:** con un plano confirmado o publicado, el subtítulo es «Sigue en Recientes; no se borra nada.» La prueba comprueba ese texto y el informe corrige su paso 0. Prueba 6 de 6, suite 2107 de 2107 y `analyze` cero.
- **Yov comparó** el árbol de `baystream-rediseno` con el de `qa-r4` sin contar los finales de línea: solo cambian esos tres archivos. Lo que llega de otros equipos con el plano cerrado no se midió, y ningún texto lo promete.
- Codex vuelve a mirar solo la corrección.
- `DESIGN.md` ya dice «Volver al inicio»: en la sección 8, la entrada de «Más», la pregunta del previo y un párrafo sobre T-138; en 13.7, la marca del riel de la oficina.

**T-137: Codex corrigió los textos del asistente** (`docs/T137-RESULTADOS.md`, «Revisión de textos previa al recorrido»).
- El arte dice «OFICINA Y MUELLE» y «Windows, Android y Web». «Tu carga, a la vista.» se queda. «Puente de mando» es el nombre interno de la dirección de diseño, y la app no lo muestra.
- La bienvenida: «BayStream lee el BAPLIE y muestra el plano de estiba, para la oficina y el muelle.»
- El recorrido normal habla de tú, con `[Messages]` del `.iss`; `Spanish.isl` no cambia.
- El arte y los dos instaladores se regeneraron. La aceptación automática nueva pasó, con el almacén real idéntico (592 archivos). El primer intento se detuvo porque BayStream 0.4.2 estaba abierta, como debía.
- Yov miró tres de las siete capturas nuevas: la bienvenida, «Lo que hay detrás» y la carpeta.
- **Falta:** el recorrido de Carlos en la cuenta «BayStream Prueba», en claro y en oscuro, y la revisión de Timonel, que empieza a la vez que la de Codex.

**La 1.0.0 no espera al asistente.** T-137 no toca la aplicación: son `tool/`, `windows/installer/` y su informe. Si pasa antes de publicar, entra a `sprint-4` y va en la mezcla. Si pasa después, entra como herramienta y empaqueta la misma 1.0.0. Mientras tanto, la laptop sigue con el MSIX.

**El orden:**
1. Codex revisa la corrección de T-138, y Timonel revisa T-137.
2. Carlos recorre el asistente en «BayStream Prueba».
3. Si T-137 pasa, Carlos hace su commit y T-137 entra a `sprint-4`.
4. Carlos publica la 1.0.0 (10.102), esta noche o mañana temprano.

La siguiente decisión es la **10.104**.
