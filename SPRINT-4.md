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
