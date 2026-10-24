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
