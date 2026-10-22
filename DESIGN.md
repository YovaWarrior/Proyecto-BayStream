# DESIGN.md · El sistema de diseño de BayStream

Dirección **A, «Plano de a bordo»**, elegida por Carlos el 21-oct-2026 (10.4 de
`SPRINT-4.md`), con la barra de operación de la dirección B en el muelle. Timonel,
T-114. Este archivo manda sobre el código de `lib/features/vessel/presentation/`,
`lib/core/app.dart` y `lib/core/design/`: ninguna decisión estética entra al código sin
estar escrita aquí, y lo que aquí cambia se cambia antes en este archivo.

Estado: la Fase 2 (fundación) implementa las secciones 4, 5 y 6 en `lib/core/design/`
(sección 13). La tabla fija de la paleta categórica (5.3) espera la confirmación de
Carlos antes de entrar al código. La evidencia de contraste está en
`docs/rediseno/fase2/contraste.md`, generada por `tool/rediseno_contraste.py`.
Material 3 sigue siendo la base: el sistema son tokens, un `ColorScheme` ajustado,
tres `ThemeExtension` y componentes propios, no otra biblioteca.

---

## 1. Para quién se diseña y qué tiene que sentirse

| | El muelle | La oficina |
|---|---|---|
| Quién | El supervisor de operaciones en Puerto Santo Tomás de Castilla | El agente naviero u operaciones |
| Dónde | Honor a 360 dp, al sol, a veces con guantes, siempre con prisa | Laptop de 14 a 17" a 1920×1080, Windows 11 (y la Web) |
| Qué hace | Marca cada contenedor que baja, carga llenos y vacíos por número de orden, pide cambios | Sigue el avance en tiempo real, aprueba cambios, genera el BAPLIE de salida |
| Lo que ya sabe | El plano impreso de memoria: bahías de proa a popa, filas desde el centro (impares a estribor, pares a babor), niveles 02… en bodega y 82… en cubierta, colores por puerto o por tipo de vacío, el 40 que ocupa dos bahías | Lo mismo, más el listado de la agencia y el BAPLIE |
| Necesita | Objetivos grandes, una acción por pantalla, confirmación inmediata, luz | Densidad, pocos clics, todo a la vista, el estado de la nube |

**Cómo tiene que sentirse:** el plano de papel, pero vivo. Serio sin ser frío, denso
donde la oficina lo necesita y despejado donde el muelle lo necesita, sin adorno. Que
alguien que ha leído planos toda la vida reconozca el suyo en la pantalla, y que lo
único que se mueve sea lo que acaba de cambiar.

## 2. El mundo del producto

- **El dominio:** bahía, fila, nivel; cubierta y bodega; la tapa de escotilla; la celda y
  la sombra del 40; el puerto de destino; lleno y vacío; el número de orden del listado;
  el VGM; la re‑estiba; las peligrosas (IMDG) y los refrigerados; la grúa pórtico.
- **El mundo de color:** el azul del casco y del agua; el blanco papel del plano impreso;
  el naranja de los chalecos y de las grúas; el gris del hormigón y del acero de los
  contenedores; los lápices de colores con que el planificador pinta destinos y tipos.
- **La firma:** la rejilla de una bahía con la línea de la tapa entre cubierta y bodega,
  la silueta del buque como selector de bahías, la cartela como leyenda, y el
  contenedor «fuera de celda» del ícono (el naranja) como la marca de lo que se mueve.
- **Los defaults que se rechazan:** `fromSeed` y tarjetas iguales; el arcoíris de
  Estadísticas; las pestañas superiores y una barra con ocho acciones; la consola
  oscura por defecto (al sol lee mejor el papel claro; el oscuro existe, pero no manda);
  los rótulos en mayúsculas sostenidas.

## 3. Lo decidido (10.2 y 10.4 de `SPRINT-4.md`)

1. **Ver primero, confirmar después:** abrir la app, «Seleccionar archivo» y elegirlo son
   los tres pasos; el plano abre con el perfil propuesto y un aviso visible con la escala
   propuesta; para operar se confirman la escala y el límite; «No lo tengo» no se marca
   por omisión; sin perfil confirmado, el peso por pila y las tomas dicen **«sin evaluar
   hasta confirmar el perfil»**, con su icono, nunca «sin alertas» ni un hueco; **en el
   previo no se exporta** (PDF, CSV ni JSON): exportar cuenta como operar (sección 7).
2. **«Colorear por»** con tres vistas (destino, tipo de vacío, estado), cada una con su
   leyenda; **tabla fija y 24 tonos**; el mismo código tiene el mismo color en todos los
   clientes y viajes; **el puerto va en la celda con sus cinco letras** (USHOU, GTSTC) y
   la celda lleva además la insignia de carga especial (sección 5).
3. **La letra:** IBM Plex Sans y Plex Mono, más Plex Sans Condensed para el código de la
   celda; Roboto, ya empaquetada, de respaldo con `fontFamilyFallback` (sección 6).
4. Al confirmar se abre «Plano»; los viajes recientes van en el inicio; la matriz de
   segregación se alcanza desde «Alertas de estiba».
5. **La barra inferior del teléfono:** Plano, Lista, Avance, Estadísticas y Más; Alertas
   va en «Más», y «Más» lleva un contador cuando hay alertas (sección 8).
6. **Una sola hoja de detalle** y **una sola unidad de peso** en pantalla: «28.7 t», con
   los kilos exactos del VGM en el detalle.
7. **La descarga sigue con un toque y «Deshacer»** (T-75): se repite cien veces por turno.
8. **La celda del muelle mide al menos 56 × 48**: nada que se toca baja de 48 dp.
9. En los documentos, nombres sintéticos de buque (BUQUE MANUAL, BUQUE PRUEBA, T99
   SINTÉTICO), nunca el del caso de campo.
10. El conductor de T-99 y los instrumentos de T-98 se actualizan antes de medir.

---

## 4. Dirección A · «Plano de a bordo»

**La idea.** La pantalla es la hoja del plano: papel claro, tinta azul marino, contornos
finos y una sola tinta de acento, el naranja de la grúa, reservada a lo que se mueve o
espera una decisión. La densidad es la de un documento técnico bien compuesto. La tira
de bahías es la silueta del buque; la leyenda es una cartela, como el cajetín de un
plano. En el muelle, al pie, la barra de operación de la dirección B: las dos o tres
cifras que importan, el último registro con «Deshacer» y la acción principal.

### 4.1 Paleta

Seis colores con nombre. Entre claro y oscuro cambia la luminosidad; el tono es el
mismo. Es la única fuente de hexadecimales de la capa de presentación
(`lib/core/design/bs_paleta.dart`).

| Nombre | Rol | Claro | Oscuro | De dónde sale |
|---|---|---|---|---|
| Papel | Fondo (`surface`) | `#F5F8FC` | `#0B1626` | Las celdas de cubierta del ícono |
| Hoja | Superficies que se apoyan en el papel: tarjetas, hojas, paneles (`surfaceContainerLowest` en claro, `surfaceContainerLow` en oscuro) | `#FFFFFF` | `#13223A` | El papel del plano impreso |
| Hoja alta | Barra de operación, fila activa (`surfaceContainerHigh`) | `#E9EFF7` | `#1B2D4A` | — |
| Tinta | Texto, iconos, bordes fuertes (`onSurface`) | `#10243F` | `#E6EEF8` | Tinta azul marino |
| Marca | Acción principal, selección, destino activo (`primary`) | `#0D47A1` | `#8FB4F2` | La semilla del ícono |
| Acero | Bodega, segundo plano (`secondary`) | `#6E9DE6` | `#6E9DE6` | La bodega del ícono |
| Grúa | Lo que se mueve o espera decisión (`tertiary`): texto / relleno | `#C2410C` / `#FF7A1A` | `#FF9A4D` / `#FF7A1A` | El contenedor en movimiento del ícono |

Derivados: tinta suave `#4A5B73` / `#A9B8CC` (texto secundario); línea `#C9D3E0` /
`#2E4260` (separadores); línea fuerte `#7A8DA6` / `#5C7392` (contornos esenciales,
3.2:1 y 3.7:1 sobre el papel); marca tenue `#DCE7F8` / `#1E3A66`; acero tenue `#E3EDFB` /
`#1C2F4D`. **Regla fija:** sobre el relleno naranja y sobre el acero, el texto es siempre
tinta oscura (`#10243F` en claro, `#0B1626` en oscuro), porque el texto claro no llega
a 4.5:1 en ninguno de los dos; y el naranja y el acero nunca van como borde fino sobre
el papel claro (2.5:1): el borde es la grúa `#C2410C` (4.9:1) o la línea fuerte.

Distribución: unos 60 % papel, 30 % hoja y tenues, 10 % marca y grúa. La grúa aparece a
lo sumo en un elemento por pantalla.

### 4.2 Tipografía

**IBM Plex Sans** para la interfaz, **IBM Plex Mono** para números de contenedor y
posiciones, **IBM Plex Sans Condensed** para el código de la celda. SIL Open Font
License 1.1 (IBM). Empaquetadas en `assets/fonts/plex/` con `LICENSE-IBMPlex.txt` y
`provenance.json` (sección 6).

Escala: base 14, razón 1.2, redondeada a enteros (`BsEscala`, en
`bs_tipografia.dart`). Son los únicos tamaños de letra del producto.

| Rol | Tamaño / peso / interlínea | Dónde | En el tema |
|---|---|---|---|
| Cifra grande | 34 / 600 / 1.1, tabular | KPI, contadores, totales | `displayLarge`, `BsTextos.cifraGrande` |
| Titular | 28 / 600 / 1.2 | Nombre del buque en el inicio | `headlineLarge` |
| Título de pantalla | 22 / 600 / 1.25 | Barra superior, cabecera de bahía | `titleLarge` |
| Título de bloque | 16 / 600 / 1.3 | Secciones, cartela | `titleMedium` |
| Cuerpo | 14 / 400 / 1.5 | Texto corriente | `bodyMedium` |
| Cuerpo secundario | 12 / 400 / 1.4, tinta suave | Metadatos, ayudas | `bodySmall` |
| Rótulo | 12 / 500 / 1.2 | Chips, destinos, leyenda, rótulos de cifra | `labelMedium` |
| Rótulo mínimo | 11 / 500 | Sobrelíneas | `labelSmall` |
| Dato mono | 14 / 400 Mono, tabular | Número de contenedor, posición en listas y detalle | `BsTextos.datoMono` |
| Celda | 12 / 600 Condensed, tabular | El código de cinco letras en la celda | `BsTextos.celda` |
| Celda, línea 2 | 10 / 500 Condensed | Peso o tipo en la celda | `BsTextos.celdaLinea2` |

Nada por debajo de 10; en el muelle, nada por debajo de 11 salvo la segunda línea de la
celda, que solo se muestra en la oficina y con zoom. Las cifras van siempre tabulares;
Plex ya trae los dígitos de ancho fijo de serie.

### 4.3 Tokens (`BsMedidas`, en `bs_medidas.dart`)

| Grupo | Oficina | Muelle |
|---|---|---|
| Espacio (base 4) | 4 · 8 · 12 · 16 · 24 · 32 · 40; dentro de un bloque 12, entre bloques 24 | Igual; dentro de un bloque 16, entre bloques 24 |
| Radios | celda 2 · control 6 · hoja y tarjeta 10 · diálogo 16 | Igual |
| Elevación | **Solo contornos** en claro: línea de 1 dp para separar, línea fuerte en celdas; sin sombras. En oscuro, desplazamiento de superficie (papel → hoja → hoja alta) y la misma línea | Igual |
| Botón · acción principal · campo · fila · chip | 40 · 48 · 48 · 56 · 32 (zona táctil 48) | 48 · 56 · 56 · 64 · 40 (zona táctil 48) |
| Celda del plano | **52 × 48**, hueco 4, contorno 1 | **56 × 48**, hueco 4, contorno 2 |
| Rejilla | etiqueta de nivel 40 · columna de pesos 72 | Igual |
| Estructura | barra superior 56 · barra de navegación 80 · riel 80 · panel lateral 360 · ancho máximo 1440 | Barra de operación 112 (cifras, aviso y acción) |
| Objetivos táctiles | 48 × 48 mínimo en todo lo que se toca | 48 mínimo; 56 para la acción principal |

### 4.4 Componentes (`lib/core/design/componentes/`)

Todos con documentación, vista previa (`vistas_previas.dart`) y prueba, incluidas
las tres pautas de accesibilidad de Flutter.

| Componente | Archivo | Qué es |
|---|---|---|
| `BsCelda` | `bs_celda.dart` | La celda del plano: relleno por categoría, código de cinco letras en condensada, insignia de carga especial siempre, marca de operación con icono y rótulo, resaltada, atenuada (alfa, no `Opacity`), reservada (solo contorno), hueco |
| `BsTiraDeBahias` | `bs_tira_de_bahias.dart` | La silueta del buque como selector: una casilla de 48 × 64 por bahía, barra por ocupación o peso, casco pintado detrás |
| `BsCartela` | `bs_cartela.dart` | El cajetín: título, cifras tabulares, leyenda en `Wrap` (nunca scroll horizontal), nota |
| `BsBanda` | `bs_banda.dart` | El aviso que se queda: información, aviso, error o confirmación, con icono, texto que crece y acción con el mismo nombre que lo que hace |
| `BsCifra` | `bs_cifra.dart` | KPI: cifra tabular, rótulo, progreso de 8 dp y detalle |
| `BsHojaDeDetalle` | `bs_hoja_de_detalle.dart` | La única hoja de detalle: título, filas que apilan a 360 dp o con letra grande, secciones, acciones, «Cerrar» |
| `BsBarraDeOperacion` y `BsAvisoDeOperacion` | `bs_barra_de_operacion.dart` | La barra del muelle: contadores, el último registro con «Deshacer», la acción principal |
| `BsNumeroDeContenedor` | `bs_numero_de_contenedor.dart` | «MSCU 123456 7» en mono y tabular |

### 4.5 Movimiento (`BsMovimiento`, en `bs_movimiento.dart`)

Microacciones 150 ms, hojas y diálogos 220 ms (opacidad y 8 dp de `Transform`), cambio
de bahía 120 ms de fundido en la oficina y **sin animación en el muelle**. Un solo
momento orquestado: la rejilla «asienta» una vez al abrir un plano (250 ms). Curvas
`easeOutCubic` al entrar y `easeInOutCubic` al moverse. Si el sistema pide reducir el
movimiento (`MediaQuery.disableAnimationsOf`), todas las duraciones son cero. Solo se
animan `Transform` y `opacity`.

---

## 5. Roles semánticos y «Colorear por» (`BsColoresSemanticos`)

### 5.1 Roles semánticos

Cada rol tiene relleno, texto sobre el relleno y contorno, en claro y en oscuro; **el
color nunca va solo**: cada rol lleva su icono o su rótulo.

| Rol | Señal además del color | Claro (relleno / contorno) | Oscuro (relleno / contorno) |
|---|---|---|---|
| Pendiente | flecha abajo o arriba, «Baja» / «Sube» | `#DCE7F8` / `#0D47A1` | `#1E3A66` / `#8FB4F2` |
| Hecho | palomita, «Hecho» | `#D3EFDB` / `#1E6B43` | `#1D4A33` / `#6FCF97` |
| Cancelado | bloqueo, «Cancelado», texto en tinta suave | `#E4E8EE` / `#7A8DA6` | `#2A3850` / `#8A9DB8` |
| Revisar (conflicto, aviso) | aviso, «Revisar» | `#FBE7B5` / `#8A5A00` | `#5C4300` / `#E0B23F` |
| Error | error y mensaje con causa y acción | `#F9D9D6` / `#B3261E` | `#601410` / `#F2B8B5` |
| Peligrosa (IMO) | rombo y la clase | `#F9D9D6` / `#B3261E` | `#601410` / `#F2B8B5` |
| Refrigerado | copo y la temperatura | `#C4E3EE` / `#1F6F8B` | `#1E4A5C` / `#7FC6DD` |
| OOG | flechas hacia fuera | `#E3C4EE` / `#6B2E8A` | `#4A2A5E` / `#C9A0DE` |
| De paso | sin relleno, tinta suave, «Paso» | papel / `#7A8DA6` | papel / `#5C7392` |
| Reservado | solo contorno | hoja / `#7A8DA6` | hoja / `#8A9DB8` |
| En movimiento, sin confirmar | el naranja de la grúa con icono | `#FF7A1A` / `#C2410C` | `#FF7A1A` / `#FF9A4D` |
| Cubierta y bodega | rótulo con icono; bodega en acero tenue | hoja / línea fuerte; acero tenue / línea fuerte | ídem |

La carga especial (peligrosa, refrigerado, OOG) se señala **siempre** con una insignia
de icono en la esquina de la celda, en cualquiera de las tres vistas de color.

### 5.2 La paleta categórica: 24 ranuras

Doce tonos a 30° (arcilla 15°, ámbar 45°, oliva 75°, hierba 105°, verde mar 135°,
turquesa 165°, cielo 195°, cobalto 225°, índigo 255°, uva 285°, magenta 315°, rosa 345°)
en dos luminosidades, **suave** (ranuras 0 a 11) e **intensa** (12 a 23). En claro, la
intensa es un tinte más oscuro (relleno a 74 % en vez de 85 %); en oscuro es una sombra
más oscura (21 % en vez de 30 %), porque una sombra más clara deja el texto claro por
debajo de 4.5:1 en los verdes. Los 24 hexadecimales están en `contraste.md` y en
`bs_colores_semanticos.dart`; el peor contraste de texto es 5.1:1 y el peor de borde 4.0:1.

### 5.3 Las tablas fijas propuestas (pendientes de Carlos)

Solo códigos, sin cuentas ni viajes, sacados de los archivos del corpus anonimizado.
Las dos tablas son independientes porque sus vistas nunca coinciden en pantalla.
Ranura k → tono k mod 12, suave si k < 12, intensa después.

Puertos de destino: JMKIN 0 · USHOU 1 · GTSTC 2 · JMKCT 3 · PAMIT 4 · COSPC 5 · JMKWL 6 ·
PACCT 7 · GTPBR 8 · USPEF 9 · PAONX 10 · VEPBL 11 · VELAG 12 · COCTG 13 · USMSY 14 · XXVSL 15.

Tipos ISO de vacío: 45G1 0 · 22G1 1 · 45G0 2 · L5G1 3 · 45R1 4 · 42G1 5 · 42U1 6 · 42P3 7 ·
L5G0 8 · 22K2 9 · 22U1 10 · 22T1 11 · 45R8 12.

Lo que no esté en la tabla usa `ranuraCategorica`: FNV-1a de 32 bits del código en
mayúsculas, módulo 24 (MXVER → 21, PABLB → 18, 22P1 → 10, los mismos valores en Dart y en
el script). Si dos códigos de un viaje chocan, el código escrito en la celda y la
leyenda los separan. Hasta que Carlos confirme, el código lleva la tabla vacía y todo
sale por cálculo; la tabla entra como un `Map<String, int>` en `BayStreamTema.claro` y
`.oscuro`.

### 5.4 Las vistas y la vista por omisión

| Vista | Qué pinta el relleno | Lo demás | Por omisión en |
|---|---|---|---|
| Destino | El puerto de descarga, con sus cinco letras en la celda | Reservas con contorno y su puerto; de paso en tinta suave | Contenido (mirar el plano) |
| Tipo de vacío | El código ISO de tamaño y tipo de los vacíos y las reservas | Los llenos en papel con el código, para que los vacíos resalten | Número de orden y Carga |
| Estado de la operación | Pendiente, hecho, cancelado, revisar, de paso | — | Descarga |

El cambio de modo propone la vista; el planificador puede cambiarla y la app recuerda
la última elección por modo en el dispositivo. **Resaltar** (lleno, vacío, IMO,
refrigerado, OOG, de paso) son chips debajo de la leyenda que atenúan lo que no
coincide (alfa en el color) sin cambiar el relleno.

### 5.5 Estadísticas: monocromo

Una sola escala secuencial de la marca (`#D9E7FC → #95BBF6 → #518FF1 → #1365E5 →
#0D47A1`); las barras por puerto llevan una muestra pequeña del color categórico del
puerto para enlazar con el plano. Ningún `Colors.*`.

## 6. La fuente: lo que se empaquetó y lo que se comprobó

Siete TTF del repositorio de IBM (`github.com/IBM/plex`, commit `71f5589`), en
`assets/fonts/plex/`, con `LICENSE-IBMPlex.txt` (SIL OFL 1.1, «Reserved Font Name
"Plex"») y `provenance.json` (URL, commit, bytes y SHA-256 de cada archivo; la prueba
`t114_fuentes_test.dart` los coteja). Plex Sans v3.005 (Regular, Medium, SemiBold), Plex
Sans Condensed v3.000 (Medium, SemiBold), Plex Mono v2.005 (Regular, Medium): 1.26 MB.

Comprobado con fontTools sobre los TTF, al empaquetar:
- **Cobertura:** las siete fuentes traen `· ‑ … × •` (U+00B7, U+2011, U+2026, U+00D7,
  U+2022), el español completo, `« » – — ° ‰` y los espacios U+00A0 y U+202F. **Faltan
  `▲ ▼`** (U+25B2, U+25BC), que pasan a iconos; `→ ↔` sí están, pero igual pasan a iconos
  (10.2).
- **Cifras tabulares de serie:** todos los dígitos miden 600 unidades en Sans y Mono y
  540 en Condensed (de 1000 por eme); el rasgo `tnum` no existe en las fuentes porque no
  hace falta. El tema lo deja declarado como refuerzo para el respaldo.
- **Respaldo:** `fontFamilyFallback: ['Roboto']` en el tema; Roboto Regular y Medium, ya
  empaquetadas para el PDF, quedan declaradas como familia en `pubspec.yaml`.
- `pubspec.yaml` declara las cuatro familias bajo `fonts:`; no cambia `pubspec.lock`.

Iconos en vez de símbolos: «Cubierta» y «Bodega» con `Icons.vertical_align_top` y
`Icons.vertical_align_bottom`; los movimientos con `Icons.arrow_forward` y «de … a …» en
el texto accesible; el intercambio con `Icons.swap_horiz`. Se conservan `· ‑ … ×` en los
textos de T-112 que las pruebas comprueban.

## 7. El flujo «ver primero, confirmar después»

### 7.1 Los estados del viaje en la interfaz

| Estado | Qué se ve | Qué se puede hacer |
|---|---|---|
| `SinViaje` | El inicio: «Seleccionar archivo», recientes, perfiles | Abrir |
| `Leyendo` | Indicador con el nombre del archivo | Nada |
| `Previo(viaje, perfil propuesto, escala propuesta, motivo)` | **El plano**, la lista y las estadísticas, con la **banda de «sin confirmar»** | Mirar, buscar, colorear, confirmar o descartar |
| `Publicado(viaje, perfil, escala)` | Lo de hoy | Todo: operar, publicar, listado, salida, exportar |
| `Fallo(mensaje)` | El error con causa y acción e «Intentar de nuevo» | Volver a abrir |

El motivo del `Previo` escribe la banda: *buque nuevo* («Plano sin confirmar: perfil
propuesto desde el archivo. Escala propuesta GTSTC.»), *homónimo* («Hay perfiles con
el mismo nombre: confirma el buque antes de operar.»), *fuera del perfil* («El perfil
guardado no cubre esta carga: revisa la ampliación.»), *escala por decidir* («El
archivo sale de PAMIT rumbo a GTSTC: confirma la escala.»).

### 7.2 El recorrido y la regla de publicación directa

1. Inicio → «Seleccionar archivo» → el selector del sistema. **Tres pasos**, y el plano
   abre en `Previo` con el perfil que propone el archivo (`VesselProfile.proposeFrom`)
   y la escala propuesta (`suggestPortOfCall`), sin guardar nada: no entra en Recientes,
   no crea operación, no toca el almacén.
2. **Regla estricta de publicación directa** (10.4): un viaje con perfil guardado abre
   publicado sin previo **solo si** el perfil cubre toda la carga **y** la escala
   propuesta coincide con la última confirmada para ese buque. Si falta cualquiera de
   las dos, abre en previo. Es la respuesta al hallazgo 5 del manual: un plano de
   llegada propone como escala el puerto de salida, y sin esa coincidencia el plano no
   opera hasta que el planificador confirme.
3. En `Previo`, la banda muestra la escala propuesta y «Confirmar». Confirmar abre
   «Parámetros del buque» con la propuesta cargada y «No lo tengo» sin marcar; al
   confirmar, el viaje se publica y **se queda en el Plano**.
4. Mientras no se confirme: los modos Carga y Descarga no aparecen; «Publicar
   operación», el listado, la salida y **exportar** dicen que falta confirmar; el peso por
   pila, las tomas y las alertas de peso muestran **«sin evaluar hasta confirmar el
   perfil»** con el icono de aviso, en la cartela, en la columna de pesos de la rejilla,
   en Alertas y en el Avance. Nunca un hueco ni «sin alertas».
5. Abrir otro archivo o un reciente en `Previo` descarta el previo con una pregunta
   corta («¿Descartar el plano sin confirmar?»).

### 7.3 Las capas que toca

| Capa | Archivo | Qué cambia |
|---|---|---|
| presentation/providers | `vessel_providers.dart` (`VoyageNotifier`) | `parseBaplieContent` publica el previo en `state`; nuevos `isPreview`, `previewPortOfCall`, `previewReason`, `discardPreview`; la regla de 7.2; `_publish` sigue siendo la única escritura |
| presentation/providers | nuevo `voyage_ui_state.dart` | La `sealed class` de 7.1 |
| presentation/pages | `vessel_overview_page.dart` | Deja de empujar la geometría al cargar; banda; «Confirmar» abre S09; al confirmar, el Plano; exportar deshabilitado en previo |
| presentation/widgets | `bay_plan_view.dart`, `loading_plan_controls.dart` | La banda y los «sin evaluar» |
| presentation/pages | `recent_voyages_page.dart`, `empty_state_widget.dart` | Recientes en el inicio |
| test/ | las pruebas de carga y perfil | Esperan que la página de parámetros se abra sola: se actualizan y se declaran |
| tool/ | `t99_conductor.dart`, `t98_primera_*` | Los pasos de la primera visualización |
| domain/ y data/ | — | **Nada** (verificado por Yov en 10.4) |

## 8. Navegación adaptable

| Ancho | Estructura | Destinos |
|---|---|---|
| < 600 dp | `NavigationBar` de 80 dp; barra superior de 56 con título y dos acciones | Plano · Lista · Avance · Estadísticas · **Más** |
| 600 – 1199 dp | `NavigationRail` de 80 dp; contenido a todo el ancho | Los mismos cinco; Nube y Parámetros al pie |
| ≥ 1200 dp | Riel + contenido + panel lateral de 360 (detalle de la celda, leyenda o avance) | Igual; Alertas también en el riel |

«Más» abre una hoja con **Alertas de estiba** (primera, con su cuenta), Comparar con
otro BAPLIE, BAPLIE de salida, Listado de la agencia, Orden de descarga, Tapas, Nube y
cuenta, Parámetros y «Cerrar plano». **El destino «Más» lleva un `Badge` con el número
de alertas** (posibles incumplimientos) para que nunca queden escondidas. Sin viaje no
hay barra. Las ocho acciones de la barra de hoy se reparten: Recientes y Perfiles al
inicio; Buscar en Plano y Lista; Exportar, Parámetros y Limpiar a «Más»; Nube como chip
en la cabecera y destino del riel; Cargar archivo al inicio.

Atrás (Android): cierra primero hojas y paneles; en la raíz del viaje pregunta «¿Cerrar
el plano?» solo si hay un previo sin confirmar; con el viaje publicado vuelve al inicio.
GoRouter no hace falta.

## 9. Wireframes de las cinco pantallas clave

Lienzos: 360 dp (un carácter ≈ 9 dp) y 1920 px (un carácter ≈ 17 px). Las celdas
llevan el puerto con sus cinco letras; `!` es peligrosa, `❄` refrigerado. Buques y
viajes sintéticos.

### 9.1 Inicio

**360 dp**
```
┌──────────────────────────────────────┐
│ BayStream                   ⚙    ☁   │ 56
├──────────────────────────────────────┤
│ Abre un plano de estiba              │ 22/600
│ Lee un BAPLIE 2.x; la 1.5 se lee     │ 14, tinta suave
│ con aviso.                           │
│ ┌──────────────────────────────────┐ │
│ │ ▣   Seleccionar archivo          │ │ 56, marca
│ └──────────────────────────────────┘ │
│                                      │
│ Recientes en este teléfono           │ 16/600
│ ┌──────────────────────────────────┐ │
│ │ BUQUE MANUAL  M100           ›   │ │ fila 72
│ │ 60 contenedores, 4 bahías        │ │ 12, suave
│ │ Escala GTSTC, hoy 14:08          │ │
│ ├──────────────────────────────────┤ │
│ │ BUQUE PRUEBA  T98            ›   │ │
│ │ 2 contenedores, 2 bahías         │ │
│ │ Sin escala, ayer                 │ │
│ └──────────────────────────────────┘ │
│ Perfiles guardados (3)             › │ fila 56
│ Operaciones abiertas en la nube    › │ solo con cuenta
└──────────────────────────────────────┘
```

**1920 px**
```
┌────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│ ▮ BayStream                                                                       Parámetros   Nube ☁  │ 56
├────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│    Abre un plano de estiba                        Recientes en este equipo                             │
│    Lee un BAPLIE 2.x; la 1.5 se lee con aviso.    ┌──────────────────────────────────────────────────┐ │
│                                                   │ BUQUE MANUAL M100       60 contenedores  4 bahías│ │
│    ┌─────────────────────────────┐                │ Escala GTSTC, publicada, hoy 14:08             › │ │
│    │ ▣   Seleccionar archivo     │  56            ├──────────────────────────────────────────────────┤ │
│    └─────────────────────────────┘                │ T99 SINTÉTICO 5000    5000 contenedores 40 bahías│ │
│                                                   │ Sin escala, solo aquí, 20-oct                  › │ │
│    Perfiles guardados                             └──────────────────────────────────────────────────┘ │
│    BUQUE MANUAL     imo 9…    23 col × 8 niv   ✎                                                       │
│    BUQUE PRUEBA     imo 9…     2 col × 1 niv   ✎  Operaciones abiertas en la nube                      │
│                                                   ┌──────────────────────────────────────────────────┐ │
│                                                   │ BUQUE MANUAL M100, GTSTC            [ Unirse ]   │ │
│                                                   └──────────────────────────────────────────────────┘ │
└────────────────────────────────────────────────────────────────────────────────────────────────────────┘
```

### 9.2 Plano por bahía (vista «Destino», previo sin confirmar)

**360 dp**
```
┌──────────────────────────────────────┐
│ ‹ BUQUE MANUAL M100          🔍   ⋮  │ 56
├──────────────────────────────────────┤
│ ⓘ Plano sin confirmar. Escala        │ BsBanda, información
│   propuesta GTSTC.      [Confirmar]  │
├──────────────────────────────────────┤
│ Bahía 02        63 cont.    416.8 t  │ 22/600 + cifras tabulares
│ ‹ ▁▂▆█▇▃▁▂ silueta ▂▃▁ ›  02 ▲       │ BsTiraDeBahias (64 dp)
│ Colorear por  (Destino ▾)   Resaltar │
├──────────────────────────────────────┤
│       04    02    00    01    cub.   │ cabecera de filas, 12/500
│ 84  ┌────┐┌────┐┌────┐┌────┐  12.3   │ BsCelda 56×48, hueco 4
│     │GTSTC││GTSTC││USHOU││    │  t    │ código de 5 letras, 12 condensada
│ 82  └────┘└────┘└────┘└────┘         │
│ ════════════ tapa ═══════════        │ línea de tapa, 2 dp
│ 06  ┌────┐┌────┐┌────┐┌────┐  bod.   │ zona bodega sobre acero tenue
│     │GTSTC││!GTSTC││❄USHOU││PAMIT│ ⚠ │ ⚠ = peso por pila sin evaluar
│ 04  └────┘└────┘└────┘└────┘         │
│ 02  …                          100 % │ chip de zoom, abajo a la derecha
├──────────────────────────────────────┤
│ ■ GTSTC 120  ■ USHOU 55  ■ PAMIT 30  │ BsCartela: chips 48, Wrap
│ ! IMO 3   ❄ Refrigerado 12   ⬚ OOG 1 │ resaltar
│ ⚠ Peso por pila: sin evaluar hasta   │ nota
│   confirmar el perfil.               │
├──────────────────────────────────────┤
│ ▦ Plano  ☰ Lista  ✓ Avance  ⫶ Estad. ⋯ Más ●2 │ NavigationBar; Más con contador
└──────────────────────────────────────┘
```

**1920 px**
```
┌────┬───────────────────────────────────────────────────────────────────────────────────┬─────────────────┐
│ ⌂  │ BUQUE MANUAL M100     ⓘ Plano sin confirmar · escala propuesta GTSTC  [Confirmar]  │ 🔍 ☁ Solo aquí  │ 56
│    ├───────────────────────────────────────────────────────────────────────────────────┼─────────────────┤
│ ▦  │ ‹ ▁▂▃▆█▇▆▅▃▂▁▂▃▅▆▇█▆▃▂▁ proa ▸ popa ›   01 02 03 05 06 … 38            02 ▲      │ Bahía 02        │
│ Pl │ Bahía 02    63 contenedores    416.8 t    Colorear por (Destino ▾)   Resaltar (…)  │ 63 cont. 416.8 t│
│    ├───────────────────────────────────────────────────────────────────────────────────┤ cub. 12 · bod. 51│
│ ☰  │      22 20 18 16 14 12 10 08 06 04 02 00 01 03 05 07 09 11 13 15 17 19 21   cub.   │                 │
│ Li │ 86   ┌┐ ┌┐ ┌┐ ┌┐ ┌┐ ┌┐ ┌┐ ┌┐ ┌┐ ┌┐ ┌┐ ┌┐ ┌┐ ┌┐ ┌┐ ┌┐ ┌┐ ┌┐ ┌┐ ┌┐ ┌┐ ┌┐ ┌┐   8.2   │ Celda 002-01-82 │
│    │ 84   GT GT US US GT GT PA PA GT GT GT GT GT US US GT GT PA GT GT US GT GT  12.3   │ MSCU 123456 7   │
│ ✓  │ 82   GT GT US US GT GT PA PA GT !GT GT GT GT US US GT GT PA GT GT US GT GT  14.0  │ 45G1 · lleno    │
│ Av │ ══════════════════════════════ tapa (T1, filas 22–00; T2, 01–21) ═══════════════   │ 28.7 t          │
│    │ 08   GT GT GT GT GT GT ❄US ❄US GT GT GT GT GT GT GT GT GT GT GT GT GT GT GT  38.1  │ VGM 28 650 kg   │
│ ⫶  │ 06   GT GT GT GT GT GT GT GT GT GT GT GT GT GT GT GT GT GT GT GT GT GT GT   40.5  │ POL PAMIT       │
│ Es │ 04   GT GT GT GT GT GT GT GT GT GT GT GT GT GT GT GT GT GT GT GT GT GT GT   41.2  │ POD GTSTC       │
│    │ 02   GT GT GT GT GT GT GT GT GT GT GT GT GT GT GT GT GT GT GT GT GT GT GT   39.8  │ ─────────────── │
│ ⚠  │ ⚠ Peso por pila: sin evaluar hasta confirmar el perfil.                   100 %  │ Leyenda         │
│ Al │                                                                                  │ ■ GTSTC 120     │
│    │                                                                                  │ ■ USHOU 55      │
│ ☁  │                                                                                  │ ■ PAMIT 30      │
│ ⚙  │                                                                                  │ ! IMO 3 ❄ Ref 12│
└────┴───────────────────────────────────────────────────────────────────────────────────┴─────────────────┘
```
Riel de 80; rejilla de 52 × 48 con 23 columnas (1 432 px con rótulos y pesos); panel de 360
con el detalle de la celda seleccionada y la leyenda. En la oficina las celdas dibujan
«GT» solo en el wireframe: la app escribe «GTSTC» (52 dp bastan para cinco letras en
condensada de 12). El zoom amplía la rejilla dentro de su lienzo; el chip «100 %» vive
en la esquina inferior derecha, nunca sobre el título.

### 9.3 Muelle: carga y descarga (el plano en modo Operar, viaje publicado)

**360 dp, modo Descarga**
```
┌──────────────────────────────────────┐
│ ‹ BUQUE MANUAL M100        ☁ Al día  │
├──────────────────────────────────────┤
│ Operar   ◉ Descarga    ○ Carga       │ SegmentedButton 48
│ Bahía 02                             │
│ ‹ ▁▂▆█▇▃▁▂ silueta ▂▃▁ ›  02 ▲       │
│ Colorear por (Estado ▾)              │ por omisión en Descarga
├──────────────────────────────────────┤
│ 84  ┌────┐┌────┐┌────┐┌────┐         │ BsCelda 56×48
│     │ ⬇  ││ ✓  ││ ~  ││ ⬇  │         │ icono 14 + rótulo 12
│     │Baja││Hecho││Paso││Baja│         │ relleno = estado
│ 82  └────┘└────┘└────┘└────┘         │
│ ════════════ tapa ═══════════        │
│ 06  …                                │
├──────────────────────────────────────┤
│  18            6            3        │ BsBarraDeOperacion (hoja alta, 112)
│  por bajar     hechas       re‑estibas│ cifras 34/600 tabulares + rótulo 12
│ ✓ Descarga registrada, MSCU 123456 7 │ BsAvisoDeOperacion, 6 s
│                           [Deshacer] │
│ ┌──────────────────────────────────┐ │
│ │ ☰  Pendientes por bahía          │ │ acción 48
│ └──────────────────────────────────┘ │
├──────────────────────────────────────┤
│ ▦ Plano  ☰ Lista  ✓ Avance  ⫶ Estad. ⋯ Más │ 80
└──────────────────────────────────────┘
```
Un toque sobre «Baja» registra, como hoy (T-75), y el aviso ofrece «Deshacer» 6 s; el
detalle (toque largo o desde la Lista) también deshace. En **Carga**, los contadores son
«18 pendientes · 3 llenos · 15 vacíos», la vista por omisión es el tipo de vacío, y la
acción principal es el campo «OR o últimos dígitos» de 56 dp con el micrófono y
«Asignar vacío»; el diálogo «Confirmar carga» pasa a hoja inferior con los mismos
campos y un solo botón principal que dice lo que hace.

**1920 px, modo Carga (la oficina viendo lo mismo)**
```
┌────┬───────────────────────────────────────────────────────────────────────────────────┬─────────────────┐
│ ⌂  │ BUQUE MANUAL M100 · GTSTC          Operar  ○ Descarga ◉ Carga      ☁ Al día       │ Carga           │
│ ▦  │ ‹ silueta › 02 ▲      Bahía 02   18 pendientes (3 llenos, 15 vacíos)    Colorear  │ 52 de 529       │
│ ☰  │                                                              por (Tipo de vacío ▾) │ ██░░░░░░░░ 10 % │
│ ✓  ├───────────────────────────────────────────────────────────────────────────────────┤ llenos 40 de 62 │
│ ⫶  │ 84   ⬆45G1 ⬆45G1 ⬆22G1 ⬆22G1 ✓45G1 ✓45G1 ⬆22G1 ⬆22G1 …                             │ vacíos 12 de 467│
│ ⚠  │ 82   ⬆45G1 ⬆45G1 ✓22G1 ✓22G1 …                                                    │ ─────────────── │
│    │ ══════════════════════ tapa ═════════════════════                                 │ OR o últimos    │
│    │ 08   …                                                                            │ dígitos  [ 🔍 ] │
│    │                                                                                   │ Asignar vacío   │
│ ☁  │ ■ 45G1 vacío 210  ■ 22G1 vacío 180  ■ 42G1 vacío 77   (llenos en papel)           │ Solicitudes (2) │
└────┴───────────────────────────────────────────────────────────────────────────────────┴─────────────────┘
```

### 9.4 Avance en la oficina

**1920 px**
```
┌────┬──────────────────────────────────────────────────────────────────────────────────────────────────────┐
│ ⌂  │ Avance · BUQUE MANUAL M100 · GTSTC                         ☁ Al día 14:08     Tapas    Exportar       │
│ ▦  ├──────────────────────────────────────────────────────────────────────────────────────────────────────┤
│ ☰  │  Descarga             Carga de llenos        Carga de vacíos         Re‑estibas      Conflictos      │ BsCifra ×5
│ ✓  │  120 de 150           40 de 62               12 de 467               3               2  ▸ ver        │
│ ⫶  │  ████████░░  80 %     ██████░░░░  65 %       █░░░░░░░░░   3 %                                        │
│ ⚠  ├──────────────────────────────────────────────────┬───────────────────────────────────────────────────┤
│    │  Por bahía                                       │  Últimos movimientos                              │
│    │  Bahía  Descarga          Carga         Último   │  14:08  Descarga   MSCU 123456 7   002-01-82  Ana │
│    │  02     12/18 ██████░░    0/18 ░░░░░░   14:08    │  14:05  Re‑estiba  TSTU 000012 3   002-05-84  Ana │
│    │  06     30/30 ████████    4/20 ██░░░░   13:55    │  13:58  Carga      OR 7 MNLU 000070 3  002-02-82 Luis│
│    │  10      0/24 ░░░░░░░░      —           —        │  13:52  Tapa T1 quitada, bahía 06            Ana  │
│    │  14     18/18 ████████    2/16 █░░░░░   13:40    │  …                                                │
│ ☁  │  …                                               │  ⚠ Peso de las pilas: sin evaluar (sin límite)    │
│ ⚙  │  Conflictos (2)   002-01-82 dos registros…  [Ir] │  Movimientos repetidos: 0                         │
└────┴──────────────────────────────────────────────────┴───────────────────────────────────────────────────┘
```

**360 dp**
```
┌──────────────────────────────────────┐
│ ‹ Avance · GTSTC           ☁ Al día  │
├──────────────────────────────────────┤
│ Descarga          Carga de llenos    │ 2 BsCifra por fila
│ 120 de 150        40 de 62           │ 34/600
│ ████████░░ 80 %   ██████░░░░ 65 %    │
│ Carga de vacíos   Re‑estibas  Confl. │
│ 12 de 467   3 %   3           2 ▸    │
├──────────────────────────────────────┤
│ Por bahía                            │
│ 02  Descarga 12/18 ██████░░          │ fila 64, toca → plano
│     Carga 0/18, 14:08 Ana          › │
│ 06  Descarga 30/30 ████████          │
│     Carga 4/20, 13:55 Ana          › │
│ …                                    │
├──────────────────────────────────────┤
│ Últimos movimientos                  │
│ 14:08 Descarga MSCU 123456 7 002-01-82│
│ …                                    │
│ ▦ Plano  ☰ Lista  ✓ Avance  ⫶ Estad. ⋯ Más │
└──────────────────────────────────────┘
```

### 9.5 Estadísticas

**1920 px**
```
┌────┬──────────────────────────────────────────────────────────────────────────────────────────────────────┐
│ ⌂  │ Estadísticas · BUQUE MANUAL M100                                                        Exportar     │
│ ▦  ├──────────────────────────────────────────────────────────────────────────────────────────────────────┤
│ ☰  │  977 contenedores   27 bahías   7 419.5 t   612 llenos   365 vacíos   12 refrigerados   3 IMO   1 OOG│ BsCifra 28/600
│ ✓  ├─────────────────────────────────────────────────┬────────────────────────────────────────────────────┤
│ ⫶  │  Por puerto de descarga                         │  Por tamaño                                        │
│ ⚠  │  ■ GTSTC  ████████████████████████  520  53 %   │  20'  ███████████████  410  42 %                   │
│    │  ■ USHOU  ████████████  245  25 %               │  40'  ██████████████████  487  50 %                │
│    │  ■ PAMIT  ██████  130  13 %                     │  45'  ███  80  8 %                                 │
│    │  ■ JMKIN  ████  82  8 %                         │  Llenos y vacíos  ██████████████░░░░░░░░ 612 / 365 │
│    ├─────────────────────────────────────────────────┴────────────────────────────────────────────────────┤
│    │  Perfil longitudinal   ○ Ocupación  ● Peso         proa ▸ popa                                       │
│    │  ▁▂▃▆█▇▆▅▃▂▁▂▃▅▆▇█▆▃▂▁▂▃▅▆▇  (toca una bahía para abrirla)                                          │ BsTiraDeBahias
│    ├──────────────────────────────────────────────────────────────────────────────────────────────────────┤
│ ☁  │  Por bahía        02    06    10    14    18    22    26    30    34    38                            │
│ ⚙  │  contenedores     63    58    61    44    52    49    38    41    29    21   (barras con la cifra)   │
│    │  peso, t        416.8 380.2 402.1 …                                                                  │
└────┴──────────────────────────────────────────────────────────────────────────────────────────────────────┘
```
Barras horizontales con la cifra al final (sin texto rotado ni cifras en el borde); la
muestra del color categórico enlaza con el plano; el resto en la escala de marca.
**360 dp:** la fila de cifras pasa a una cuadrícula de 2 × 4 (`Wrap` con ancho por token,
no un `GridView` con `shrinkWrap`), cada bloque a todo el ancho y las barras por bahía
en vertical.

## 10. Cómo resuelve los objetivos (sección 3 del encargo)

| Objetivo | Cómo |
|---|---|
| **RNF-002**, ≤ 3 pasos y < 30 s | Los tres pasos de la sección 7; desde Recientes, dos. El botón de 56 dp es lo único que pide el inicio |
| **RNF-003**, nada cortado ni tapado a 360 y 600 dp con letra 1.0, 1.45 y 2.0 | Leyenda en `Wrap` de chips; zoom en la esquina inferior del lienzo; banda que crece; `NavigationBar` en vez de pestañas; título con elipsis; resumen del modo como cifras en la barra de operación y la cartela, no como frase larga; nada por debajo de 10 sp; el `FittedBox` solo en el código de la celda; la hoja de detalle apila con letra grande (probado a 360 dp y 2.0) |
| **RNF-001 y 007**, Lista y rejilla perezosas, tablero < 1 s | La Lista pasa a `CustomScrollView` con `SliverList` y filas de 56 dp; la rejilla usa `RepaintBoundary` por zona, celdas sin `FittedBox` y sin `Opacity`, y un modelo de celda precalculado por bahía; se mide antes y después con T-99 |
| **Pendientes de 10.91 y T-111** | Cartela con las etiquetas escritas una vez y el singular; barra de pestañas a 2.0: desaparece; cifras del borde: barras horizontales con la cifra al final; desborde de 0.23 dp: `Wrap` por token; Mayús + rueda: `ScrollConfiguration`; matriz desde Alertas; todas las bahías del buque: la silueta deja hueco para las bahías sin carga cuando exista el inventario (10.87) |
| **Sin retroceder en T-112** | Los 218 mensajes no cambian; lo nuevo nace en español y en tipo oración; `NavigationBar`, `SegmentedButton`, `Badge`, `SearchBar`, `DropdownMenu` y `NavigationRail` son Material 3; los censos `t98c_*` se repiten por pantalla |
| **Claro y oscuro** | Dos juegos de tokens verificados; en oscuro cambia la luminosidad, no el tono |
| **Impacto** | La silueta del buque como selector, la rejilla que parece la hoja impresa y una sola tinta de acento |

## 11. Reglas de texto

1. Frases cortas, voz activa, tipo oración; se tutea («Toca una celda»), nunca «Seleccione».
2. **El botón dice lo que pasa y el aviso lo repite:** «Registrar descarga» → «Descarga
   registrada»; «Confirmar y ver el plano» → el plano; «Enviar solicitud» → «Solicitud enviada».
3. Nada en mayúsculas sostenidas: «Bahía 02», «Cubierta», «Baja», «Hecho», «Total». El rótulo
   de la tira de bahías que el conductor de T-99 busca («BAHÍA nn (») cambia con el
   conductor, en la misma entrega.
4. Sin «N/A»: «sin dato», «no declarado», «sin posición».
5. Los números son el dato principal: tabulares, agrupados («MSCU 123456 7», «28 650 kg»),
   una sola unidad en pantalla («28.7 t»), porcentaje con espacio («91 %»), posiciones
   «002-01-82» en celdas y listas y «Bahía 002, Fila 01, Nivel 82» en el detalle
   (`bs_formato.dart`).
6. En las pantallas nuevas, los datos de una fila van en líneas o separados por comas, no
   en cadenas con punto medio; los mensajes de T-112 se conservan tal cual.
7. Singular y plural concuerdan siempre, también en 1.
8. Un error dice qué pasó y qué hacer, sin disculpas; un estado vacío invita a actuar.
9. Cada pantalla tiene un título de dos o tres palabras; los metadatos técnicos van al detalle.
10. «Sin evaluar» se dice con esas palabras y con icono: «sin evaluar hasta confirmar el perfil».

## 12. Lo que la Fase 2 dejó en el código y lo que queda para la 3

**Hecho (Fase 2, `lib/core/design/`):** `bs_paleta.dart`, `bs_tipografia.dart` (escala,
familias, `TextTheme`, `BsTextos`), `bs_medidas.dart`, `bs_colores_semanticos.dart` (roles
y 24 ranuras), `bs_categorico.dart` (FNV-1a y la tabla fija), `bs_formato.dart`,
`bs_movimiento.dart`, `bs_tema.dart` (`BayStreamTema.claro` y `.oscuro`, con densidad de
oficina o de muelle), los ocho componentes de 4.4 y `vistas_previas.dart`; las fuentes
Plex en `assets/fonts/plex/`; las pruebas `test/t114_*`. **Ninguna pantalla cambia
todavía:** `lib/core/app.dart` sigue con el tema de v3.0 hasta la primera entrega de la
Fase 3, para que las capturas del antes y el después se comparen pantalla a pantalla.

**Pendiente de Carlos:** confirmar o ampliar las tablas de 5.3; entonces entran como
`tablaFija` en `BayStreamTema`.

**Fase 3, en este orden:** inicio (con el flujo de la sección 7 y el tema aplicado),
plano por bahía con los modos de carga y descarga, avance en la oficina, estadísticas;
después, las demás pantallas.
