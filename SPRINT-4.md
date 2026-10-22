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
