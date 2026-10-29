# DESIGN.md · El sistema de diseño de BayStream

Dirección **C, «Puente de mando»**, aprobada por Carlos el 22-oct-2026 (10.14 de
`SPRINT-4.md`): la app es el ícono en grande (sección 13). Sustituye a la dirección A
«Plano de a bordo» (10.4), que queda en la sección 4 como historia: Carlos vio la entrega
1 de la Fase 3 y la sintió pobre y sin impacto, y la A se había pensado para leer al sol
cuando el encargo era impacto. Lo que la A dejó en el código se queda (tokens, tema,
`ThemeExtension`, componentes, Plex y pruebas); cambian valores y se suman piezas.
Timonel, T-114. Este archivo manda sobre el código de `lib/features/vessel/presentation/`,
`lib/core/app.dart` y `lib/core/design/`: ninguna decisión estética entra al código sin
estar escrita aquí, y lo que aquí cambia se cambia antes en este archivo.

Estado: la Fase 2 (fundación) implementó las secciones 4, 5 y 6 en `lib/core/design/`
(sección 12), con la corrección de 10.7; la Fase 3, entrega 1, conectó el tema y el
inicio (7 y 9.1). La Fase 1 bis escribe la dirección C (sección 13) y la Fase 2 bis la
lleva a `lib/core/design/` y a `lib/core/app.dart`: la noche, los estados de la vista
Estado, las fichas y la tabla reordenada, el tema por omisión según el equipo y las
piezas nuevas. Donde la sección 13 y las secciones 4 y 5 digan cosas distintas, manda
la 13. T-117 y T-118 (10.36 a 10.39) suman la sección 14: la oficina con más plano, el
panel lateral que se oculta y el selector de modo único. T-119 (10.76) suma la sección 16: la rueda en la silueta, el zoom con el touchpad y Ctrl + rueda, y la barra horizontal de la rejilla. La evidencia de contraste está en `docs/rediseno/fase2bis/contraste.md`, generada
por `tool/rediseno_contraste.py`, y la del contraste compuesto de la celda en
`test/t114_celda_contraste_test.dart` y `test/t114_fase2bis_test.dart`.
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
  oscura en el muelle (al sol lee mejor el papel claro: el muelle abre de día y la
  oficina de noche, 13.5); los rótulos en mayúsculas sostenidas; los mapas y el
  arrastrar contenedores (13.9).

## 3. Lo decidido (10.2, 10.4, 10.6, 10.7 y 10.14 de `SPRINT-4.md`)

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
11. **Las tablas fijas, confirmadas** (10.6): 15 puertos en las ranuras 0 a 14 y 13 tipos
    de vacío en las 0 a 12; `XXVSL` sale, porque no es un UN/LOCODE. Las ranuras 15 a 23
    de puertos las asigna la oficina en T-115, fuera del rediseño (sección 5.3).
12. **Atenuar sin perder la lectura** (10.7): la celda fuera del filtro baja el relleno al
    35 %, compuesto sobre el papel para que no dependa de lo que haya detrás, y pone el
    código en tinta suave y el contorno en línea fuerte, que cumplen 4.5:1
    y 3:1 sobre el color ya compuesto, en todos los estados, en claro y en oscuro y en las
    dos densidades. Nunca alfa en el texto, y la etiqueta accesible no se toca para que
    pase una prueba (sección 5.1).
13. **La segunda línea de la celda, solo en la oficina** (10.7): con zoom de 100 % o más
    y un parámetro de zoom explícito; en el muelle no se dibuja aunque venga (sección 4.2).
14. **La dirección C, «Puente de mando»** (10.14): el tema por omisión según el equipo
    (oscuro en Windows y la Web, claro en Android); la noche nueva y el día de la Fase 2;
    el plano dibujado como el ícono en la vista Estado, con el casco de la bodega; el
    naranja solo para lo que se acaba de mover, 1.5 s, quieto si el sistema reduce el
    movimiento y anunciado al lector de pantalla; destino y tipo como fichas de noche; la
    tabla que reparte los tonos a saltos; ninguna dependencia nueva, ningún dato
    inventado, y los íconos del dominio y las ilustraciones en un paquete aparte
    (sección 13).

---

## 4. Dirección A · «Plano de a bordo» (historia; la activa es la 13)

Elegida en 10.4 y superada el 22-oct por la C (10.14): se sintió pobre y sin impacto, y
tomaba del ícono los colores pero no la forma. Sus tokens y componentes siguen en el
código con los valores de la sección 13; lo que sigue es el texto de la Fase 2, que se
conserva porque 4.2, 4.3 y 4.5 siguen vigentes en lo que la 13 no cambia.

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
`#2E4260` (separadores); línea fuerte `#6D809F` / `#6983A3` (contornos esenciales:
3.8:1 y 4.7:1 sobre el papel y 3.4:1 sobre el acero tenue de la bodega; la prueba
compuesta de la celda encontró que los valores de la Fase 1, `#7A8DA6` / `#5C7392`,
quedaban en 2.9:1 y 2.8:1 sobre la bodega); marca tenue `#DCE7F8` / `#1E3A66`; acero tenue `#E3EDFB` /
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
`bs_tipografia.dart`), más la cifra protagonista de 48, fuera de la razón y una sola vez
por vista (15.2). Son los únicos tamaños de letra del producto.

| Rol | Tamaño / peso / interlínea | Dónde | En el tema |
|---|---|---|---|
| Cifra protagonista | 48 / 600 / 1.05, tabular | La única cifra que encabeza Estadísticas, una vez por vista (15.2; 10.38, P9) | `BsTextos.cifraProtagonista` |
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
| Celda, línea 2 | 10 / 500 Condensed | Peso o tipo en la celda, solo en la oficina con zoom ≥ 100 % y si cabe | `BsTextos.celdaLinea2` |

Nada por debajo de 10; en el muelle, nada por debajo de 11: la segunda línea de la celda
(10) se dibuja solo en la oficina, con zoom de 100 % o más (`BsCelda.zoom`) y si cabe con
la escala de letra del sistema; en el muelle no se dibuja aunque la celda la reciba
(10.7). Las cifras van siempre tabulares; Plex ya trae los dígitos de ancho fijo de serie.

### 4.3 Tokens (`BsMedidas`, en `bs_medidas.dart`)

La densidad la decide la plataforma (`lib/core/app.dart`, `bayStreamEsMuelle`): el
muelle en Android e iOS, la oficina en Windows y en la Web. El tema de la app lleva la
que toca, en claro y en oscuro, con la preferencia de tema de T-90.

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
| `BsCelda` | `bs_celda.dart` | La celda del plano: relleno por categoría, código de cinco letras en condensada, insignia de carga especial siempre, marca de operación con icono y rótulo, resaltada, atenuada (relleno al 35 % sin `Opacity`, código en tinta suave y contorno en línea fuerte: 5.1), reservada (solo contorno), hueco; la segunda línea solo en la oficina con `zoom` ≥ 1.0; con la letra a 2.0 nada desborda, lo que no cabe no se dibuja |
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
color nunca va solo**: cada rol lleva su icono o su rótulo. Los valores de claro son los
vigentes; **los de oscuro de esta tabla son los de la dirección A y quedaron sustituidos
por la noche de 13.1**, que suma además el rol «información» y los cinco estados de la
vista Estado (13.2).

| Rol | Señal además del color | Claro (relleno / contorno) | Oscuro (relleno / contorno) |
|---|---|---|---|
| Pendiente | flecha abajo o arriba, «Baja» / «Sube» | `#DCE7F8` / `#0D47A1` | `#1E3A66` / `#8FB4F2` |
| Hecho | palomita, «Hecho» | `#D3EFDB` / `#1E6B43` | `#1D4A33` / `#6FCF97` |
| Cancelado | bloqueo, «Cancelado», texto en tinta suave | `#E4E8EE` / `#6D809F` | `#2A3850` / `#8A9DB8` |
| Revisar (conflicto, aviso) | aviso, «Revisar» | `#FBE7B5` / `#8A5A00` | `#5C4300` / `#E0B23F` |
| Error | error y mensaje con causa y acción | `#F9D9D6` / `#B3261E` | `#601410` / `#F2B8B5` |
| Peligrosa (IMO) | rombo y la clase | `#F9D9D6` / `#B3261E` | `#601410` / `#F2B8B5` |
| Refrigerado | copo y la temperatura | `#C4E3EE` / `#1F6F8B` | `#1E4A5C` / `#7FC6DD` |
| OOG | flechas hacia fuera | `#E3C4EE` / `#6B2E8A` | `#4A2A5E` / `#C9A0DE` |
| De paso | sin relleno, tinta suave, «Paso» | papel / `#6D809F` | papel / `#6983A3` |
| Reservado | solo contorno | hoja / `#6D809F` | hoja / `#8A9DB8` |
| En movimiento, sin confirmar | el naranja de la grúa con icono | `#FF7A1A` / `#C2410C` | `#FF7A1A` / `#FF9A4D` |
| Cubierta y bodega | rótulo con icono; bodega en acero tenue | hoja / línea fuerte; acero tenue / línea fuerte | ídem |
| Atenuada (fuera del filtro de «Resaltar») | el código, el rótulo y la insignia se conservan | relleno del rol al 35 % compuesto sobre el papel, opaco (peor caso, el naranja: 4.98:1); texto `#4A5B73`; contorno `#6D809F` | relleno al 35 % sobre el papel; texto `#A9B8CC`; contorno `#6983A3` |

La carga especial (peligrosa, refrigerado, OOG) se señala **siempre** con una insignia
de icono en la esquina de la celda, en cualquiera de las tres vistas de color, en el
color de su rol cuando llega a 3:1 sobre el relleno; sobre los rellenos donde no llega
(los intensos en oscuro, el naranja) toma el texto del rol o la tinta de la celda; y
atenuada pasa a tinta suave, no a alfa.

**Lo que se dibuja se verifica compuesto** (10.7, H1): para cada estado de la celda,
tema, densidad y fondo (papel y bodega), `test/t114_celda_contraste_test.dart` compone con
`Color.alphaBlend` el relleno sobre el fondo, el texto y los iconos sobre el relleno
compuesto y el contorno sobre el relleno, y exige 4.5:1 al texto y 3:1 a iconos y
contorno. La pauta `textContrastGuideline` de Flutter no mide la celda: busca el texto
por su etiqueta accesible, y la celda expone una etiqueta descriptiva distinta del
código. El hueco lleva la línea de separación de 1 dp (4.3), que no es un contorno
esencial, y queda fuera de la exigencia de 3:1.

### 5.2 La paleta categórica: 24 ranuras

De día siguen estos valores; de noche las ranuras son fichas en OKLCH (13.4). Doce tonos a 30° (arcilla 15°, ámbar 45°, oliva 75°, hierba 105°, verde mar 135°,
turquesa 165°, cielo 195°, cobalto 225°, índigo 255°, uva 285°, magenta 315°, rosa 345°)
en dos luminosidades, **suave** (ranuras 0 a 11) e **intensa** (12 a 23). En claro, la
intensa es un tinte más oscuro (relleno a 74 % en vez de 85 %); en oscuro es una sombra
más oscura (21 % en vez de 30 %), porque una sombra más clara deja el texto claro por
debajo de 4.5:1 en los verdes. Los 24 hexadecimales están en `contraste.md` y en
`bs_colores_semanticos.dart`; el peor contraste de texto es 5.1:1 y el peor de borde 4.0:1.

### 5.3 Las tablas fijas (confirmadas en 10.6)

Solo códigos, sin cuentas ni viajes, sacados de los archivos del corpus anonimizado y
confirmados por Carlos. Las dos tablas son independientes porque sus vistas nunca
coinciden en pantalla. Desde 10.14 la ranura k pinta el tono
`[11, 6, 3, 9, 1, 8, 4, 0, 10, 5, 2, 7][k mod 12]`, suave si k < 12, intensa después
(13.4); antes era k mod 12, y los cinco primeros puertos quedaban a 30° uno de otro.

Puertos de destino (15): JMKIN 0 · USHOU 1 · GTSTC 2 · JMKCT 3 · PAMIT 4 · COSPC 5 ·
JMKWL 6 · PACCT 7 · GTPBR 8 · USPEF 9 · PAONX 10 · VEPBL 11 · VELAG 12 · COCTG 13 ·
USMSY 14. `XXVSL` salió: no es un UN/LOCODE. **Las ranuras 15 a 23 de puertos quedan
libres y las asigna la oficina** (T-115, fuera del rediseño: la asignación tiene que
viajar al muelle por Firestore y su copia local); los 15 fijos no se reasignan.

Tipos ISO de vacío (13): 45G1 0 · 22G1 1 · 45G0 2 · L5G1 3 · 45R1 4 · 42G1 5 · 42U1 6 ·
42P3 7 · L5G0 8 · 22K2 9 · 22U1 10 · 22T1 11 · 45R8 12.

Están en `bs_categorico.dart` (`tablaFijaDePuertos`, `tablaFijaDeTipos` y las dos juntas
en `tablaFijaConfirmada`, que `BayStreamTema.claro` y `.oscuro` usan por omisión), con su
prueba, y `tool/rediseno_contraste.py` lleva las mismas listas. Lo que no esté en la tabla
ni en las ranuras de la oficina usa `ranuraCategorica`: FNV-1a de 32 bits del código en
mayúsculas, módulo 24 (MXVER → 21, PABLB → 18, 22P1 → 10, los mismos valores en Dart y
en el script). Si dos códigos de un viaje chocan, el código escrito en la celda y la
leyenda los separan. T-115 junta la tabla fija con las asignaciones de la oficina en un
provider; la Fase 3 no cambia por eso.

### 5.4 Las vistas y la vista por omisión

| Vista | Qué pinta el relleno | Lo demás | Por omisión en |
|---|---|---|---|
| Destino | El puerto de descarga, con sus cinco letras en la celda | Reservas con contorno y su puerto; de paso en tinta suave | Contenido (mirar el plano) |
| Tipo de vacío | El código ISO de tamaño y tipo de los vacíos y las reservas | Los llenos en papel con el código, para que los vacíos resalten | Número de orden y Carga |
| Estado de la operación | Pendiente, hecho, cancelado, revisar, de paso | — | Descarga |

El cambio de modo propone la vista; el planificador puede cambiarla y la app recuerda
la última elección por modo en el dispositivo. **Resaltar** (lleno, vacío, IMO,
refrigerado, OOG, de paso) son chips debajo de la leyenda que atenúan lo que no
coincide (relleno al 35 %, código en tinta suave y contorno en línea fuerte: 5.1) sin
cambiar el tono.

### 5.5 Estadísticas: monocromo

Una sola rampa de un tono, el azul de la marca, para las magnitudes, y ningún `Colors.*`.
**La rampa de la Fase 1** (`#D9E7FC → #95BBF6 → #518FF1 → #1365E5 → #0D47A1`) **no pasaba
el validador de la skill de dataviz en su paso claro** (1.25:1 sobre la hoja; 0.9.4 de
`docs/T117-T121-RESULTADOS.md`) y queda sustituida por la de 15.3: de día `#88B0F5 →
#518FF1 → #1365E5 → #0D47A1`, de noche `#2C5BA8 → #4F8EF7 → #95BBF6 → #D9E7FC`
(`BsPaleta.rampaDeMagnitud`); `#D9E7FC` pasa a ser la pista de las barras de día
(`BsPaleta.pistaDeMagnitud`). El puerto se enlaza con el plano por la caja de su código
(su rol categórico, con el código escrito), no por una muestra en la barra: las barras de
una sola serie van en la marca. Lo demás, en la sección 15.

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
| `Leyendo` | Indicador con el nombre del archivo («Leyendo A01.edi…») | Nada |
| `Previo(viaje, perfil propuesto, escala propuesta, motivo)` | **El plano**, la lista y las estadísticas, con la **banda de «sin confirmar»** | Mirar, buscar, colorear, confirmar o descartar |
| `Publicado(viaje, perfil, escala)` | Lo de hoy | Todo: operar, publicar, listado, salida, exportar |
| `Fallo(mensaje)` | El error con causa y acción e «Intentar de nuevo» | Volver a abrir |

El motivo del `Previo` escribe la banda: *buque nuevo* («Plano sin confirmar: perfil
propuesto desde el archivo. Escala propuesta GTSTC.»; sin escala en el archivo, «… El
archivo no declara la escala.»), *homónimo* («Hay perfiles con el mismo nombre: confirma
el buque antes de operar.»), *fuera del perfil* («El perfil guardado no cubre esta carga:
revisa la ampliación.»), *escala por decidir* («El archivo sale de PAMIT rumbo a GTSTC:
confirma la escala.»; sin las dos escalas, «Plano sin confirmar. Escala propuesta GTSTC:
confírmala para operar.»). La banda lleva un solo botón, «Confirmar». Están en
`presentation/providers/voyage_ui_state.dart` (`Previo.texto`), con el resto de los
textos del previo: «Peso por pila y tomas de refrigerado: sin evaluar hasta confirmar el
perfil.» y «Para exportar, confirma el perfil del buque.».

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
5. Abrir otro archivo, un reciente o «Limpiar datos» en `Previo` descarta el previo con
   una pregunta corta («¿Descartar el plano sin confirmar?», «Seguir mirando» /
   «Descartar»). Cancelar en los parámetros, en la identidad o en la plantilla no
   descarta nada: el plano sigue a la vista, sin operar.
6. **La última escala confirmada para ese buque** se lee del almacén que ya existe: la
   del viaje guardado más reciente de ese perfil con escala. No hay dato nuevo que
   guardar y `domain/` y `data/` no cambian.

### 7.3 Las capas que toca

| Capa | Archivo | Qué cambia |
|---|---|---|
| presentation/providers | `vessel_providers.dart` (`VoyageNotifier`) | `parseBaplieContent` publica el previo en `state` (`_abrirPrevio`); nuevos `isPreview`, `previewReason`, `previewPortOfCall`, `visibleVoyage`, `discardPreview`; `publishedVoyage` y `publishedProfile` no ven el previo; la regla de 7.2 en `_useProfile`; `_publish` sigue siendo la única escritura |
| presentation/providers | `voyage_ui_state.dart` | La `sealed class` de 7.1, `voyageUiStateProvider` derivado del notifier y los textos del previo |
| presentation/pages | `vessel_overview_page.dart` | `switch` sobre el estado; el plano es la primera pestaña; la banda con «Confirmar»; el aviso «sin evaluar» en todas las pestañas; exportar avisa en previo; la pregunta al descartar; el inicio sin barra de acciones duplicadas |
| presentation/widgets | `inicio_view.dart` (nuevo), `empty_state_widget.dart` | El inicio de 9.1: cabecera, recientes, perfiles y nube |
| presentation/pages | `stowage_alerts_page.dart` | «Sin evaluar» en lugar de «no hay resultados» |
| presentation/widgets | `bay_plan_view.dart`, `loading_plan_controls.dart` | Con la entrega del plano: el «sin evaluar» en la cartela y en la columna de pesos |
| test/ | `t114_fase3_inicio_test.dart` (nuevo) y las pruebas de carga y perfil | Las que esperaban que la página de parámetros se abriera sola se actualizaron y se declaran en el informe |
| tool/ | `t99_conductor.dart`, `t98_primera_*` | Los pasos de la primera visualización: tres, y termina en la rejilla |
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

**Lo que el código hace (candidata del piloto, 10.28).** `AtrasDelViaje`
(`navegacion_del_viaje.dart`) envuelve la página del viaje, y solo gobierna Atrás en
Android, donde hay un botón Atrás del sistema; en la Web el navegador manda y en
Windows no hay botón. En orden: las hojas («Más», el detalle en el teléfono), los
diálogos y la búsqueda son rutas y las cierra el `Navigator` por su cuenta; el menú del
zoom no es una ruta, así que mientras está abierto se anota en
`cerrablesDeAtrasProvider` y Atrás lo cierra antes que nada; con panel lateral, Atrás
cierra el detalle de la celda. En la raíz del viaje, con un previo, pregunta lo mismo
que «Más → Cerrar el plano», «¿Descartar el plano sin confirmar?», con «Seguir mirando»
y «Descartar» (Atrás sobre la pregunta es seguir mirando); con el viaje publicado,
vuelve al inicio solo con **dos toques seguidos**: el primero advierte «Toca Atrás otra
vez para volver al inicio» durante 2 s, contados desde ese toque con su propio reloj, y
el segundo, dentro de esos 2 s, vuelve. **La advertencia es una tarjeta propia** (los
colores, el borde y la letra del tema de `SnackBar`), centrada arriba bajo la barra de
estado, que no recibe toques y se anuncia al lector de pantalla; no entra en la cola de
avisos del `ScaffoldMessenger`, así que se ve aunque esté el aviso de 6 s de un registro,
y ese aviso, con su «Deshacer», sigue su curso (corrección de 10.29, H1: antes la
advertencia era un aviso más, quedaba formada detrás del de movimiento, la ventana
dependía de cuándo se apagaba y el segundo toque intentaba cerrar un aviso que no era el
primero de la cola). El viaje publicado sigue guardado y se reabre desde los recientes
con un toque. En el muelle, un toque por error no saca a nadie del plano. En el inicio,
Atrás sale de la app como siempre. **La ventana es solo para dos toques seguidos en la
raíz** (10.31, O1): si en medio se abre otra cosa (el menú del zoom, el menú del modo o de
«Colorear por», el detalle de una celda, una hoja, un diálogo) o Atrás cierra otra cosa, la
ventana se cancela y la advertencia se va; el siguiente Atrás en la raíz vuelve a advertir.
Los menús del modo y de «Colorear por» no son rutas: Atrás los cierra primero porque se
anotan en `cerrablesDeAtrasProvider` (10.42, H2; 14.6).

**Lo que la entrega 2 dejó en el código (22-oct, 10.16):** la barra de ocho acciones y su
plegado (T-91) se retiran: Buscar va en la barra superior o en la cabecera de la oficina
(que desde la corrección de 10.21 se reparte o se pliega según el ancho y la letra: el
título a la izquierda y el estado con Descarga / Carga a la derecha mientras caben en una
línea, y si no, los controles bajan a una segunda línea; Buscar y la nube quedan siempre en
el borde derecho, al alcance, también a 600 dp con la letra a 2.0);
Nube y Parámetros, al pie del riel desde 600 dp y en «Más» en el teléfono; y lo demás en
«Más», que lleva también Cargar archivo, Viajes recientes, Perfiles guardados y «Cerrar el
plano». «Avance» muestra el avance de la operación embebido, sin barra propia, y solo existe
con una escala confirmada. En la barra inferior el destino se escribe «Estad.» y los rótulos
crecen con la letra del sistema hasta 1.3 (cinco destinos en 360 dp dan 72 dp a cada uno;
más allá se recortarían); el nombre entero va en la descripción emergente y para el lector de
pantalla. Atrás en Android se resolvió en la candidata del piloto (arriba). La preferencia de T-91
(`planToolbarCollapsedProvider` y su almacén) queda sin lector; retirarla toca `domain/` y
`data/` y se propone como tarea.

**T-117 (24-oct, sección 14):** desde 1200 dp el panel lateral se puede ocultar con un botón de
la cabecera y sale flotante por el borde derecho o al tocar una celda; de 600 a 1199 dp, donde no
hay panel fijo, el detalle también sale en el panel flotante y no en la hoja de abajo (14.3).

## 9. Wireframes de las cinco pantallas clave

Lienzos: 360 dp (un carácter ≈ 9 dp) y 1920 px (un carácter ≈ 17 px). Las celdas
llevan el puerto con sus cinco letras; `!` es peligrosa, `❄` refrigerado. Buques y
viajes sintéticos.

### 9.1 Inicio

Hecho en la entrega 1 de la Fase 3 (`inicio_view.dart`): la cabecera («Abre un plano de
estiba», la validación por contenido y «Seleccionar archivo» a 56 dp) y, debajo, los
recientes de este dispositivo (hasta cinco, con «Ver todos» hacia la pantalla que los
borra), «Perfiles guardados (N)» y, con cuenta autorizada, «Operaciones abiertas en la
nube (N)». La barra superior lleva solo Parámetros y Nube; no hay botón flotante ni
acciones repetidas (T-98, `con01`). Desde 840 dp la cabecera va a la izquierda y las
listas a la derecha, dentro del ancho máximo de 1440.

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

El lienzo de 1920 px de esta sección quedó sustituido por el de 13.8 (de noche, con la
silueta, las tarjetas y «En vivo»); el de 360 dp sigue, con los valores de 13.1.

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
condensada de 12). El zoom amplía la rejilla dentro de su lienzo; el chip «100 %» iba en
la esquina inferior derecha del lienzo, y desde la corrección de 10.21 va **fuera de la
rejilla, en la línea de los controles del plano** (10.20: a 360 dp con la letra a 1.45 y
2.0 tapaba la última columna); un toque abre un menú anclado con alejar, «Restablecer» y
acercar, el chip sigue mostrando el porcentaje vigente y el pellizco sigue funcionando
sobre la rejilla.

### 9.3 Muelle: carga y descarga (el plano en modo Operar, viaje publicado)

El lienzo de 360 dp en modo Descarga quedó sustituido por el de 13.8 (la banda de la
marca, «Baja» en el azul de la marca, la celda que sale de su sitio); el de 1920 px sigue.

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

**Corrección de la Fase 2 (10.7, 22-oct):** la celda atenuada legible en todos los
estados (5.1), la prueba del contraste compuesto (`test/t114_celda_contraste_test.dart`),
la segunda línea solo en la oficina con `zoom` (4.2), las tablas fijas de 10.6 en el tema
(5.3) y el aviso de `tool/t100_sintetico.dart` quitado: `analyze` en cero absoluto.

**Queda para la Fase 3, con el plano:** el código de cinco letras no cabe en 52 ni en
56 dp con la letra del sistema a 2.0 (24 sp en condensada) y hoy se corta con elipsis;
lo resuelve la rejilla con el zoom y el tamaño de la celda, y se comprueba con las
capturas a 1.45 y 2.0 de esa entrega. **Fuera del rediseño:** las 9 ranuras de puertos
que asigna la oficina (T-115).

**Fase 3, entrega 1 (22-oct):** el tema conectado en `lib/core/app.dart` (4.3), el
inicio (9.1), el previo con su banda, «sin evaluar» y sin exportar (7), la regla estricta
de publicación directa (7.2) y el plano como primera pestaña (10.2 a). La navegación
adaptable (8) no hizo falta para entregar el inicio: va con el plano.

**Fase 1 bis y Fase 2 bis (22-oct, 10.14):** la dirección C en la sección 13 y su
fundación en el código: la noche en `bs_paleta.dart` y en `BayStreamTema.oscuro`; los
estados de la vista Estado, el rol «información», la tinta tenue y las fichas de noche en
`bs_colores_semanticos.dart`; la tabla reordenada en `bs_categorico.dart` y en el script;
el tema por omisión según el equipo en `lib/core/app.dart`; y las piezas nuevas de 13.6,
con sus pruebas y sus vistas previas. Ninguna pantalla cambia todavía.

**Fase 3, en este orden:** plano por bahía con los modos de carga y descarga (ya en la
dirección C: la silueta, el casco, la vista Estado, la navegación adaptable, la cartela y
el código íntegro a 2.0); después el muelle, el avance, las estadísticas y el inicio con
la ilustración cuando llegue el paquete; después, las demás pantallas.

## 13. Dirección C · «Puente de mando» (activa desde el 22-oct, 10.14)

**La idea.** La app es el ícono en grande. Del ícono salen el azul de la marca, el blanco
de la cubierta, el acero de la bodega, el contenedor naranja que sale de su celda y la
curva del casco que cierra la bodega. La oficina trabaja de noche: un fondo técnico con la
rejilla del plano al 5 %, paneles que se apoyan en él y cifras grandes; la bahía
seleccionada se dibuja como el ícono (blanco arriba, acero abajo) y lo único naranja en
pantalla es lo que se acaba de mover. El muelle sigue de día, con el papel de la Fase 2 y
una banda azul de la marca arriba. Lo que había en la A se queda (tokens, tema, extensiones,
componentes, Plex y pruebas): cambian valores y se suman piezas.

**Por qué cambió (10.14).** Carlos vio la entrega 1 de la Fase 3 y la sintió pobre y sin
impacto. La A se pensó para leer al sol y el encargo era impacto; además la tabla fija daba
a los cinco primeros puertos cinco tonos seguidos de la rueda, y del ícono se habían tomado
los colores, no su forma. Yov dibujó el concepto en un lienzo (las cuatro mesas están en
`docs/rediseno/concepto/`) y Carlos lo aprobó completo a las 15:51.

### 13.1 La noche y el día

El día es el de la Fase 2 (4.1), sin cambios. La noche es nueva. Los dos son la única
fuente de hexadecimales de la presentación (`bs_paleta.dart`); cada pareja está verificada
con `tool/rediseno_contraste.py` (`docs/rediseno/fase2bis/contraste.md`): 4.5:1 el texto y
3:1 los bordes e iconos. Entre el día y la noche cambia la luminosidad, no el tono, salvo
en la marca: de noche el azul del ícono deja de ser texto (no llega a 3:1 sobre la noche) y
pasa a ser **superficie** con texto blanco; el texto y la selección de marca pasan al azul
de selección.

| Nombre | Rol de M3 | Día | Noche | Qué es |
|---|---|---|---|---|
| Papel / noche | `surface`, `scaffoldBackgroundColor` | `#F5F8FC` | `#07111F` | El fondo. De noche lleva la rejilla de plano: líneas cada 32 dp en acero al 5 % (`BsFondoDePlano`), solo en oscuro |
| Hoja / panel | `surfaceContainerLowest` (día), `surfaceContainerLow` (noche) | `#FFFFFF` | `#0C1A31` | Tarjetas, paneles, hojas, el casco de la silueta |
| Hoja alta / panel alto | `surfaceContainerHigh` | `#E9EFF7` | `#11223F` | Fila activa, chips de estado («Publicado»), la celda de paso, la banda de información |
| Tinta | `onSurface` | `#10243F` | `#EAF0F9` | Texto, iconos, cifras |
| Tinta suave | `onSurfaceVariant` | `#4A5B73` | `#A9B9D2` | Texto secundario, rótulos, el código de la celda atenuada |
| Tinta tenue | `BsColoresSemanticos.tintaTenue` | `#566986` | `#8DA0BE` | Metadatos terciarios: el momento de un evento, «18 en la bahía 14», los números de bahía no seleccionados |
| Línea | `outlineVariant` | `#C9D3E0` | `#1E3457` | Separadores y la pista de las barras de avance |
| Línea fuerte | `outline` | `#6D809F` | `#5272A6` | Contornos esenciales: celda, casco, bordes de campo (3.6:1 sobre el panel) |
| Marca (texto y selección) | `primary` | `#0D47A1` | `#4F8EF7` | Texto e iconos de marca, foco, el marco de la celda y de la bahía seleccionadas, el avance en curso |
| Sobre marca | `onPrimary` | `#FFFFFF` | `#07111F` | Texto sobre un botón de marca |
| Marca tenue / marca como superficie | `primaryContainer` | `#DCE7F8` | `#0D47A1` | De día un tinte (chip seleccionado, indicador del riel); de noche la marca como superficie: el riel activo, el chip seleccionado y el botón tonal, con texto en tinta (7.5:1) |
| Marca superficie | `BsPaleta.marcaSuperficie` | `#0D47A1` | `#0D47A1` | La banda del muelle y el recuadro de la marca, iguales en los dos modos; texto blanco (8.6:1), frase `#BCD2F7` (5.6:1) y el chip de la nube en marca profunda `#0A3A85` (blanco 10.7:1) |
| Acero | `secondary` | `#6E9DE6` | `#6E9DE6` | La bodega del ícono: por bajar en bodega, los datos de segundo plano de la silueta |
| Acero tenue | `secondaryContainer` | `#E3EDFB` | `#11213A` | La zona de bodega de la rejilla; de noche, acero al 5 % sobre el panel |
| Grúa (texto) | `tertiary` | `#C2410C` | `#FF9A4D` | Texto e iconos naranja; «ahora» en el panel «En vivo» va en `#FFB27A`, el contorno de la celda recién movida |
| Grúa (relleno) | `tertiaryContainer` | `#FF7A1A` | `#FF7A1A` | Solo lo que se acaba de mover; texto encima siempre en tinta oscura (6.0:1 y 7.3:1) |
| Hecho | contorno del rol `hecho` | `#1E6B43` | `#3DD68C` | Palomitas, el avance terminado, el punto de «Al día» |
| Aviso | contorno del rol `revisar` | `#8A5A00` | `#F5B83D` | Alertas de estiba, la tarjeta de alertas, «Revisar» |
| Crítico | `error`, contorno de `error` y `peligrosa` | `#B3261E` | `#F2777A` | Errores con causa y acción, el rombo de IMDG |

**Los pares de la noche** (los del día están en 4.1 y no cambian): tinta sobre noche
16.5, sobre panel 15.2, sobre panel alto 13.8; tinta suave 9.5 · 8.7 · 8.0; tinta tenue
7.1 · 6.5 · 6.0; selección sobre noche 5.9, sobre panel 5.4, sobre panel alto 4.9; noche
sobre selección 5.9; blanco sobre la marca 8.6; frase sobre la marca 5.6; blanco sobre la
marca profunda 10.7; tinta sobre acero tenue 14.1; noche sobre acero 6.9; noche sobre
grúa 7.3; grúa texto sobre noche 9.0; línea fuerte sobre noche 3.9, panel 3.6, panel alto
3.3 y acero tenue 3.3; hecho sobre noche 10.1; aviso 10.7; crítico 6.9.

**Los roles semánticos de noche** (relleno / texto / contorno; el texto sobre el relleno
y el contorno sobre el peor fondo del modo): pendiente `#1E3A66` / `#EAF0F9` / `#4F8EF7`
(9.9 · 4.9); hecho `#1D4A33` / `#EAF0F9` / `#3DD68C` (8.8 · 8.5); cancelado `#2A3850` /
`#A9B9D2` / `#8A9DB8` (5.9 · 5.7); revisar `#5C4300` / `#F2F6FB` / `#F5B83D` (8.6 · 8.9);
error y peligrosa `#601410` / `#F2F6FB` / `#F2777A` (12.1 · 5.8); refrigerado `#1E4A5C` /
`#F2F6FB` / `#7FC6DD` (8.8 · 8.3); OOG `#4A2A5E` / `#F2F6FB` / `#C9A0DE` (10.9 · 7.2); de
paso `#11223F` / `#A9B9D2` / `#5272A6` (8.0 · 3.3); reservado `#0C1A31` / `#A9B9D2` /
`#8A9DB8` (8.7 · 5.7); en movimiento `#FF7A1A` / `#07111F` / `#FF9A4D` (7.3 · 7.5);
cubierta (zona) `#0C1A31` / `#EAF0F9` / `#5272A6` (15.2 · 3.3); bodega (zona) `#11213A` /
`#EAF0F9` / `#5272A6` (14.1 · 3.3); información (banda) `#11223F` / `#EAF0F9` / `#4F8EF7`
(13.8 · 4.9). Los de día son los de 5.1, más «información» `#DCE7F8` / `#10243F` /
`#0D47A1`, que la banda ya usaba desde el esquema.

**La selección de noche se invierte:** el segmento y el chip seleccionados van en tinta
`#EAF0F9` con texto noche (16.5:1), como el «Descarga» y el «Estado» del concepto, en vez
del tinte de marca del día. El indicador del riel y de la barra de navegación sí usa la
marca como superficie.

### 13.2 El plano se dibuja como el ícono

**La celda** tiene las esquinas del ícono: radio 8 (el 17 % del lado, como 1.9 de 11 en el
SVG); antes 2. En la vista **Estado** los rellenos son los del ícono:

| Estado | Día (el muelle) | Noche (la oficina) | Señal además del color |
|---|---|---|---|
| Por bajar en cubierta | marca `#0D47A1`, texto blanco, contorno marca (8.6) | cubierta `#F5F8FC`, texto noche, contorno cubierta (17.8) | Flecha abajo y «Baja» en el muelle; el código y el peso en la oficina |
| Por bajar en bodega | `#1F5FD6`, texto blanco (5.7; 4.9 sobre el papel) | acero `#6E9DE6`, texto noche (6.9) | Igual |
| De paso | papel, tinta suave, línea fuerte (la Fase 2) | panel alto `#11223F`, tinta suave `#A9B9D2` (8.0), línea fuerte | «Paso» y el código |
| Bajado | el rol hecho de la Fase 2: `#D3EFDB`, tinta, `#1E6B43` (12.7) | la celda vacía (relleno noche) con contorno **punteado** en línea fuerte (3.3 sobre el panel) y la palomita en hecho `#3DD68C` (10.1) | Palomita y «Hecho» |
| Recién movido | grúa `#FF7A1A`, tinta, contorno `#C2410C` (6.0) | grúa `#FF7A1A`, texto noche, contorno `#FFB27A` (7.3) | Sale de su celda (13.3), icono de flecha y «Bajando» o «Subiendo» |

Los demás estados de la celda (categoría, insignias, marcas, resaltada, atenuada,
reservada, hueco) siguen como en 5.1, con los valores de noche de 13.1. **Atenuada:** el
código va en tinta suave sobre el relleno al 35 % compuesto sobre el papel; con los
rellenos de «por bajar» la tinta suave queda en 3.5:1 de día y 3.1:1 de noche, así que la
regla pasa a ser «tinta suave, y si no llega a 4.5:1 sobre lo compuesto, tinta», decidida
por el rol en el tema y verificada compuesta (`test/t114_celda_contraste_test.dart` y
`test/t114_fase2bis_test.dart`). Nunca alfa en el texto.

**La bodega se cierra con la curva del casco.** `BsCascoBodega` pinta detrás de las filas
de bodega un casco: los costados rectos que bajan desde la tapa y el fondo que se curva
hacia la quilla, relleno en acero tenue y contorno en línea fuerte de 1.5 dp; de noche el
relleno es acero al 5 % sobre el panel. Las celdas de los extremos de cada fila de bodega
llevan esa curva en su esquina exterior inferior (`BsCelda.curva`: babor, estribor o las
dos en la fila más baja; radio `radioCasco` 18), como los bloques exteriores del ícono. La
tapa de escotilla sigue siendo la línea de 2 dp entre cubierta y bodega; de día en tinta,
de noche en cubierta `#DCE5F3`.

### 13.3 La regla del naranja

El naranja de la grúa marca **solo lo que se acaba de mover**:

1. Una celda que otro equipo acaba de bajar o cargar entra en el estado «recién movido»:
   toma el relleno de grúa, sale de su celda media celda hacia arriba (`Transform.translate`
   de 150 ms, **desde donde estaba esa misma celda, de 0 a media celda**; al dejar el estado
   vuelve a su sitio de golpe, sin que se vea regresar: 10.17, H1) y deja en su sitio el
   hueco con contorno punteado en grúa texto, como el contenedor del ícono. En el muelle, el
   toque en «Baja» hace lo mismo antes del aviso con «Deshacer».
2. **Dura 1.5 s** (`BsMovimiento.recienMovido`). La pantalla, no la celda, apaga el estado:
   la celda es un widget sin reloj y el plano decide cuándo vuelve a «bajado» o «hecho».
3. **La bahía donde pasó destella en la silueta**: un anillo en grúa alrededor de su pila
   que se apaga en los mismos 1.5 s (`BsSiluetaBuque.recienMovida`).
4. **Si el sistema pide reducir el movimiento** (`MediaQuery.disableAnimationsOf`), nada se
   mueve: la celda se dibuja en naranja en su sitio, sin salir ni volver, y el destello es
   un anillo fijo mientras el estado dure. La prueba de la Fase 2 bis lo exige.
5. **Siempre se anuncia** para el lector de pantalla: el panel «En vivo» es una región en
   vivo (`liveRegion`) y su evento más reciente lleva la etiqueta completa («Bajado, Muelle,
   TSTU 000110 8, 014-01-86, ahora»). La celda recién movida también cambia su etiqueta.
   Donde no hay panel lateral (el teléfono y la oficina de 600 a 1199 dp), el anuncio lo da
   una región en vivo sin dibujo (`AnuncioDelMovimiento`) con el mismo texto que esa fila:
   qué pasó, el rol, el contenedor y la celda, «ahora»; nunca un nombre (10.21, H3). El
   panel de escritorio no se lleva al teléfono: solo el anuncio.
6. Fuera de esto, el naranja aparece solo en el contenedor del ícono; nunca como relleno
   de fondo, y a lo sumo en un elemento por pantalla, además de la marca. **El contador de
   «Más» (las alertas de estiba) va en aviso, o en error si alguna es crítica, nunca en
   grúa** (10.16): el naranja es de lo que se mueve, no de lo que hay que revisar.

### 13.4 Las fichas en oscuro y la tabla reordenada

**De noche, destino y tipo son fichas:** relleno profundo del tono, y código y contorno
en el tono vivo, sin tinta clara encima. Se calculan en OKLCH con los tonos del concepto
(arcilla 35°, ámbar 75°, oliva 110°, hierba 145°, verde mar 170°, turquesa 195°, cielo
230°, cobalto 262°, índigo 285°, uva 315°, magenta 345°, rosa 10°): las **suaves** con
relleno L 0.34 C 0.075 y código y contorno L 0.84 C 0.12 (código sobre relleno de 7.1 a
7.4, contorno sobre los fondos de la noche de 9.2 a 10.2); las **intensas**, separadas de
las suaves por luminosidad, con relleno L 0.44 C 0.12 y código y contorno L 0.93 C 0.06
(6.1 a 6.7 y 12.7 a 13.3). Donde un tono se sale de la gama sRGB, el script baja el croma
hasta que quepa, sin tocar el tono ni la luminosidad: por eso cielo y rosa difieren por
unas unidades de los valores del lienzo. **De día, los rellenos suaves e intensos de la
Fase 2** (5.2) no cambian.

**La tabla reparte los tonos dando saltos:** ranura k → tono
`[11, 6, 3, 9, 1, 8, 4, 0, 10, 5, 2, 7][k mod 12]`, suave hasta la 11 e intensa desde la
12 (`tonoDeRanura` en `bs_categorico.dart` y `TONO_DE_RANURA` en el script). En la rueda
de doce tonos a 30°, los cinco primeros puertos quedan a 60° o más (345°, 195°, 105°, 285°
y 45°; antes a 30°): JMKIN rosa, USHOU cielo, GTSTC hierba, JMKCT uva y PAMIT ámbar. En los
matices OKLCH de las fichas, que no van a pasos iguales, el par más cercano es uva y rosa,
a 55°. Las tablas de códigos de 10.6 (5.3) y la ranura de reserva (FNV-1a) no cambian:
cambia lo que cada ranura pinta.

| Ranura | Tono | Día: relleno / contorno | Noche: relleno / código y contorno |
|---:|---|---|---|
| 0 | rosa suave | `#EEC4CE` / `#832139` | `#58252F` / `#FFB2BD` |
| 1 | cielo suave | `#C4E3EE` / `#216A83` | `#003E55` / `#84D7FE` |
| 2 | hierba suave | `#CEEEC4` / `#398321` | `#1B421E` / `#98DF9A` |
| 3 | uva suave | `#E3C4EE` / `#6A2183` | `#462B52` / `#E7B3FF` |
| 4 | ámbar suave | `#EEE3C4` / `#836A21` | `#4E3100` / `#F8BF6C` |
| 5 | índigo suave | `#CEC4EE` / `#392183` | `#34315D` / `#C4C4FF` |
| 6 | verde mar suave | `#C4EECE` / `#218339` | `#004332` / `#6FE4BF` |
| 7 | arcilla suave | `#EECEC4` / `#833921` | `#58281C` / `#FFB6A3` |
| 8 | magenta suave | `#EEC4E3` / `#83216A` | `#522641` / `#FEADDB` |
| 9 | turquesa suave | `#C4EEE3` / `#21836A` | `#004142` / `#55E3E3` |
| 10 | oliva suave | `#E3EEC4` / `#6A8321` | `#3B3B00` / `#CFD271` |
| 11 | cobalto suave | `#C4CEEE` / `#213983` | `#22375E` / `#AFCBFE` |
| 12 | rosa intensa | `#DE9CAC` / `#6A1B2E` | `#873043` / `#FFDFE2` |
| 13 | cielo intensa | `#9CCDDE` / `#1B566A` | `#005B7A` / `#CCEEFF` |
| 14 | hierba intensa | `#ACDE9C` / `#2E6A1B` | `#1A6323` / `#D0F3D0` |
| 15 | uva intensa | `#CD9CDE` / `#561B6A` | `#6B3A7F` / `#F4DFFF` |
| 16 | ámbar intensa | `#DECD9C` / `#6A561B` | `#704A00` / `#FEE3BF` |
| 17 | índigo intensa | `#AC9CDE` / `#2E1B6A` | `#4D4691` / `#E5E5FE` |
| 18 | verde mar intensa | `#9CDEAC` / `#1B6A2E` | `#00624B` / `#C1F6E2` |
| 19 | arcilla intensa | `#DEAC9C` / `#6A2E1B` | `#88341F` / `#FFE0D8` |
| 20 | magenta intensa | `#DE9CCD` / `#6A1B56` | `#7E3261` / `#FFDDEF` |
| 21 | turquesa intensa | `#9CDECD` / `#1B6A56` | `#005F5F` / `#B9F5F4` |
| 22 | oliva intensa | `#CDDE9C` / `#566A1B` | `#565700` / `#EAECBE` |
| 23 | cobalto intensa | `#9CACDE` / `#1B2E6A` | `#2C4F94` / `#DCE9FE` |

La leyenda dibuja la muestra con el mismo relleno y contorno que la celda; de noche la
insignia de carga especial se lee sobre la ficha con la regla de 5.1 (el primer color del
rol que llega a 3:1, y si ninguno, el código de la ficha).

### 13.5 El tema por omisión según el equipo

Oscuro en Windows y en la Web (la oficina), claro en Android e iOS (el muelle), **cuando el
usuario nunca eligió un tema**. La preferencia de T-90 (claro, oscuro o seguir al sistema)
sigue igual. `lib/core/app.dart` tiene `bayStreamTemaPorOmision` (el tema del equipo) y
`bayStreamThemeMode` (la preferencia → `ThemeMode`).

**Un límite que la presentación no puede resolver sola, y por eso el tema por equipo queda
preparado y no conectado.** El almacén guarda la preferencia como `system`, `light` o
`dark`, y devuelve `system` tanto cuando el usuario nunca eligió como cuando eligió «Seguir
al sistema» (`hive_vessel_data_source.dart:117`). T-90 exige, con su prueba, que «Seguir al
sistema» siga al sistema operativo; resolver `system` por equipo la rompería y cambiaría la
preferencia, que 10.14 dice que no cambia. Como la regla del rediseño es no tocar `domain/`
ni `data/`, la Fase 2 bis deja `system` → `ThemeMode.system` y **propone el cambio mínimo**,
que decide Carlos y escribe Yov como tarea: que el almacén distinga «no elegido». La forma
más limpia es un cuarto valor, `AppThemePreference.equipo` («Según el equipo»), que el
almacén devuelva cuando no hay nada guardado (`_ => equipo` en vez de `_ => system`) y que
Parámetros ofrezca como opción; con eso `bayStreamThemeMode(equipo)` devuelve
`bayStreamTemaPorOmision`, quien eligió «Seguir al sistema» conserva su elección y quien
nunca eligió abre con el tema del equipo. Son dos líneas en `domain/` y `data/`, una en
`app.dart` y una opción en Parámetros (Fase 3).

**Decisión 10.16 (22-oct):** Carlos decidió que el tema **siga al sistema**:
`bayStreamTemaPorOmision` queda preparado y sin conectar, y `domain/` y `data/` no cambian.
Para ver la noche en Windows o en la Web: Parámetros → Oscuro (T-90). La propuesta del cuarto
valor queda escrita por si se retoma.

### 13.6 Las piezas nuevas y su API

Todas en `lib/core/design/componentes/`, con documentación, vista previa, prueba de
contraste compuesto y las tres pautas de accesibilidad. Solo se animan `Transform` y
`opacity`; cada `CustomPainter` va dentro de un `RepaintBoundary`; con
`disableAnimations` nada se mueve. Las celdas siguen siendo widgets (toque, foco y
etiqueta); la silueta, el casco, la marca y el anillo se pintan con `CustomPainter`.

| Pieza | API | Qué hace |
|---|---|---|
| `BsMarca` | `BsMarca({tamano = 40, variante = conRecuadro \| sinRecuadro \| monocroma, color?, espera = false, etiqueta = 'BayStream'})` | El ícono pintado desde la geometría de `design/icono/baystream.svg` (módulo de 13.8 en un lienzo de 100; recuadro de 126.6 con esquinas de 27). `monocroma` tiñe todo con `color` (por omisión `onSurface`) y el contenedor se reconoce por estar fuera de la cuadrícula. `espera: true` es la espera de la app: el contenedor naranja sube y baja medio módulo (6.9 unidades) en un bucle de 1.2 s con `easeInOut`, solo `Transform`; quieto si se reduce el movimiento. Etiqueta accesible; con `espera`, «BayStream, leyendo» |
| `BsSiluetaBuque` | `BsSiluetaBuque({bahias: List<BsBahiaDeSilueta>, onSeleccion, seleccionada?, recienMovida?, controlador?, rotuloDeAvance?, compacta = false})` con `BsBahiaDeSilueta({numero, nivelesCubierta = 0, nivelesBodega = 0, avance?, conTrabajo = false})` | Evoluciona `BsTiraDeBahias`: el casco con la proa a la izquierda y la línea de flotación, sin superestructura; cada bahía es una pila (los niveles ocupados de cubierta encima de la línea de la tapa y los de bodega debajo); las bahías con trabajo en esta escala van más claras y las demás apagadas; la seleccionada en cubierta `#F5F8FC` y acero `#6E9DE6` con su marco en marca; bajo cada número, la barra de avance (hecho si llegó a 1, marca si va, línea si no empezó); el destello de la bahía recién movida (13.3). Cada bahía es un botón de **56 dp de ancho** (`anchoBahia`) con etiqueta («Bahía 14, 4 niveles en cubierta y 4 en bodega, avance 25 %, seleccionada»); **el alto no es un parámetro: sale de los niveles que se pintan (hasta 6 por zona, a 9 dp) y de la escala de letra del número y la barra** (10.17, O1). Con `compacta`, la silueta del teléfono bajo (13.8): la misma información, el mismo botón de 56 dp y la misma etiqueta, pero cada nivel a 4 dp (3 pintados) y menos aire arriba y abajo: con seis y seis niveles mide unos 90 dp en vez de 161 (10.21, H4) |
| `BsCascoBodega` | `BsCascoBodega({child, radio = 48})` | El casco detrás de las filas de bodega (13.2) |
| `BsCelda` | nuevos: `estado = BsEstadoDeCelda.ninguno \| porBajarCubierta \| porBajarBodega \| dePaso \| bajado \| recienMovido`, `curva = BsCurvaDeCelda.ninguna \| babor \| estribor \| ambas` | Los estados de 13.2 y la curva del casco. `recienMovido` sale de su celda (13.3); `bajado` de noche va punteado (`BsRol.punteado`) |
| `BsTarjetaCifra` | `BsTarjetaCifra({valor, rotulo, detalle?, rol?, anillo?, onTap?})` | La tarjeta de cifra grande del mosaico: rótulo arriba (tinta suave), la cifra a **34 / 600 tabular** (`BsTextos.cifraGrande`, la escala de 4.2, que 13.10 no cambia; el lienzo la dibujaba a 40: 10.17, O2), el detalle abajo (tinta tenue); con `rol` (revisar para alertas) la cifra y el rótulo toman el contorno del rol y el borde se tiñe; con `anillo`, un `BsAnilloAvance` a la izquierda de la cifra. Panel con radio 18 y borde en línea. Etiqueta: «Por bajar: 30, 18 en la bahía 14» |
| `BsAnilloAvance` | `BsAnilloAvance({fraccion, tamano = 52, grosor = 9, color?, etiqueta?})` | El anillo: pista en línea, arco desde las 12 en el color (hecho por omisión), extremos redondeados; sin animación (es un dato, no un movimiento). Etiqueta «80 por ciento» |
| `BsPanelEnVivo` | `BsPanelEnVivo({eventos: List<BsEventoEnVivo>, resumen?, enLinea = true, titulo = 'En vivo'})` con `BsEventoEnVivo({que, quien: BsEquipo.muelle \| oficina, detalle, tipo: BsTipoDeEvento.movido \| hecho \| aviso \| aprobado, momento?, accion?, onAccion?})` | La actividad en tiempo real: punto verde con pulso de opacidad (2.2 s, quieto si se reduce el movimiento), el resumen (p. ej. «Oficina y 2 teléfonos del muelle»), y una fila por evento: cuadrado de 9 dp del color del tipo (grúa, hecho, aviso, acero), «Bajado · Muelle» (el rol del equipo, nunca un nombre: la API solo admite el enum), el detalle en mono y el momento o la acción («Revisar»). Región en vivo para el lector de pantalla |
| `BsBandaMuelle` | `BsBandaMuelle({buque, viaje?, nube?, modo?, onModo?, acciones = const []})` | La banda de la marca arriba del muelle: `BsMarca.sinRecuadro` de 44, el nombre del buque (17 / 600 blanco) y el viaje y la escala (`#BCD2F7`), el chip de la nube (marca profunda, punto en hecho) y, debajo, el `SegmentedButton` Descarga / Carga de 48 dp (seleccionado blanco con texto marca). Fondo `marcaSuperficie` en los dos temas |
| `BsFondoDePlano` | `BsFondoDePlano({child})` | De noche, la rejilla de plano: líneas cada 32 dp (`pasoRejilla`) en acero al 5 % sobre la noche; de día, solo el papel |

`BsTiraDeBahias`, `BsCifra` y los demás componentes de 4.4 se quedan como están; la Fase 3
cambia la tira por la silueta y las cifras del avance por tarjetas donde el wireframe lo
pide.

### 13.7 Dónde va la marca

| Dónde | Pieza | Tamaño |
|---|---|---|
| Arriba del riel, en la oficina | `BsMarca` con recuadro | 44 |
| La banda del muelle | `BsMarca` sin recuadro, sobre el azul | 44 |
| El inicio, junto a «BayStream» | `BsMarca` con recuadro | 40 |
| La espera («Leyendo A01.edi…», publicar, unirse) | `BsMarca(espera: true)` dentro de un recuadro de 72 con radio 16 | 52 |
| Las pantallas vacías | `BsIlustracion` con el dibujo del paquete (13.11) y la frase de siempre: «todavía no hay viajes» (`vacio_recientes`), «ningún contenedor coincide» (`vacio_busqueda`), «trabajando solo en este equipo» (`sin_conexion`), «descarga completa» (`descarga_completa`) y «sin posibles incumplimientos» (`sin_alertas`); el inicio lleva `inicio` sobre «Abre un plano de estiba» | 320 de ancho (240 en la búsqueda y en las alertas, hasta 480 en el inicio); la proporción es la del lienzo. Cada dibujo ocupa como máximo tres décimas del alto de la ventana entre la escala de la letra, y bajo 120 dp no se pinta (13.11, regla 4) |
| La celda que se mueve | `BsCelda(estado: recienMovido)`: el contenedor fuera de su celda, como en el ícono |  |
| El pie del inicio | `BsTravesia` (13.11, regla 7): el buque de `sin_conexion`, con la proa a la derecha, navegando sobre el mar en el espacio que sobra debajo de los dos bloques | A todo el ancho; el alto es lo que sobra, y bajo 120 dp no se pinta |
| Íconos temáticos y lanzadores | Los de `design/icono/` (T-88), sin cambios |  |

### 13.8 Los wireframes que cambian

Sustituyen a 9.2 (1920 px) y a 9.3 (360 dp). Los demás de la sección 9 siguen en pie con
los valores de 13.1. Buques y números sintéticos (TSTU con dígito de control).

**9.2 bis · Plano por bahía a 1920 px, de noche (la oficina)**
```
┌─────┬────────────────────────────────────────────────────────────────────────────────┬────────────────────┐
│ [▣] │ BUQUE MANUAL  (Publicado)   Viaje M100 · Escala GTSTC     ◉ Descarga ○ Carga   │ ● Al día 3 equipos │ 56
│     │                                                           [ Número, OR o celda 🔍 ] │                    │
│ ⌂   ├────────────────────────────────────────────────────────────────────────────────┴────────────────────┤
│ In  │ ┌ Bahías de proa a popa ─ avance de la descarga en GTSTC bajo cada bahía ──────┐ ┌──────┐ ┌──────┐ │
│ ▦   │ │ ╭─────────────────────────────────────────────────────────────────────╮     │ │ ◔ 80 %│ │Por   │ │
│ Pl  │ │ │  ▪▪  ▪▪▪ ▪▪▪▪ [████] ▪▪▪▪ ▪▪▪▪ ▪▪▪▪ ▪▪  ▪▪  ▪▪▪                    │     │ │120 de│ │bajar │ │
│ ═   │ │ ╰──────────────── ▪▪▪  ▪▪▪  ▪▪▪  [████] ▪▪▪ ▪▪▪ ▪▪▪ ▪▪▪ ──────────────╯     │ │150   │ │  30  │ │
│ ☰   │ │ Proa  02  06  10   14   18   22   26   30   34   38                   Popa │ └──────┘ └──────┘ │
│ Li  │ │       ━━  ━━  ━━   ▬    ━─   ─    ─    ─    ─    ─      (avance bajo cada n.º)│ ┌──────┐ ┌──────┐ │
│ ◔   │ └───────────────────────────────────────────────────────────────────────────────┘ │Re‑est.│ │Alertas│ │
│ Av  │ ┌ ‹  Bahía 14   36 contenedores · 712.4 t · cubierta 18 · bodega 18  ›   Colorear por (Estado)(Destino)(Tipo) ┐
│ ⫶   │ │        10   08   06   04   02   00   01   03   05   07   09           Babor … Estribor         │
│ Es  │ │ 88    ┌╌╌┐ ┌╌╌┐ ┌╌╌┐ ┌╌╌┐ ┌╌╌┐ ┌╌╌┐ ┌╌╌┐                    ← bajados: vacías punteadas + ✓ │
│ ⚠ 2 │ │ 86         ▓GTSTC▓ ▓GTSTC▓ ▓GTSTC▓ ┌─▲─┐ ▓GTSTC▓ ┌╌╌┐ ▓GTSTC▓ ▓GTSTC▓ ░USHOU░                 │
│ Al  │ │ 84    ░USHOU░ ▓GTSTC▓ ▓GTSTC▓ ▓GTSTC▓ ░JMKCT░ ▓GTSTC▓ ▓GTSTC▓ ▓GTSTC▓ ░USHOU░ ░PAMIT░ ░USHOU░ │
│ ☁   │ │ 82    ░USHOU░ ░USHOU░ ░PAMIT░ ░PAMIT░ ░JMKCT░ ░JMKCT░ ░USHOU░ ░USHOU░ ░PAMIT░ ░PAMIT░ ░USHOU░ │
│ Nu  │ │ Tapa  ══════════════════════ tres tapas ═══════════════════════                               │
│ ⚙   │ │ 10  ╭ ▒GTSTC▒ ▒GTSTC▒ ░USHOU░ ▒GTSTC▒ … ▒GTSTC▒ ░PAMIT░ ╮        ▓ = por bajar en cubierta   │
│ Pa  │ │ 08  │ ░USHOU░ ░USHOU░ ░JMKCT░ ░JMKCT░ … ░PAMIT░ ░PAMIT░ │         ▒ = por bajar en bodega     │
│     │ │ 06  │   ░USHOU░ ░USHOU░ ░JMKCT░ … ░PAMIT░ ░PAMIT░      │         ░ = de paso (panel alto)    │
│     │ │ 04  ╰╮   ░USHOU░ ░JMKCT░ … ░PAMIT░ ░PAMIT░        ╭╯        ┌─▲─┐ = recién movido, fuera   │
│     │ │ 02   ╰───╮  ░JMKCT░ ░PAMIT░ ░PAMIT░ ░PAMIT░  ╭───╯              de su celda, 1.5 s          │
│     │ │ Peso por pila en cubierta · límite 90 t  ▂▃▅▆▇▆▅▃▂ (barra por pila, aviso si ≥ 90 %)         │
│     │ │ (Por bajar 18) (Bajando 1) (Bajados 8) (De paso 9) (❄ Refrigerado) (◆ Peligrosa IMDG)        │
│     │ └──────────────────────────────────────────────────────────────────────────────────────────────┘
│     │ ┌ Contenedor ───────────── (Bajando ahora) ┐ ┌ ● En vivo ─── Oficina y 2 teléfonos del muelle ┐
│     │ │ TSTU 000110 [8]   45G1 · 40′ HC · lleno  │ │ ▪ Bajando · Muelle     TSTU 000110 8 · 014-02-86  ahora │
│     │ │ Celda 014-02-86   Destino ■ GTSTC        │ │ ▪ Bajado · Muelle      TSTU 004218 0 · 014-01-86  hace 1 min │
│     │ │ Origen USHOU      Peso 24.1 t            │ │ ▪ Cambio pedido · Muelle  TSTU 020493 3 · 014-03-84 [Revisar] │
│     │ │ VGM 24 100 kg     Carga especial Ninguna │ │ ▪ Re‑estiba aprobada · Oficina  018-07-84 → 018-05-86 │
│     │ │ [Pedir cambio]  Historial                │ └───────────────────────────────────────────────────┘
└─────┴──────────────────────────────────────────┴──────────────────────────────────────────────────────┘
```
El riel de 80 lleva la marca con recuadro arriba y el destino activo en la marca como
superficie con texto blanco; Alertas con su contador en aviso. El fondo es la noche con la
rejilla al 5 %; cada bloque es un panel (hoja, radio 18, borde en línea). La silueta y las
cuatro tarjetas van arriba; el plano de la bahía en el centro con «Colorear por» como
segmentos (el seleccionado en tinta); a la derecha el detalle del contenedor y «En vivo».
«Grúa 2» del lienzo no existe en la app: el panel dice «Muelle» u «Oficina».

**9.3 bis · Muelle a 360 dp, de día, modo Descarga**
```
┌──────────────────────────────────────┐
│ ▣  BUQUE MANUAL          ● Al día    │ banda de la marca #0D47A1, blanco
│    Viaje M100 · GTSTC                │ frase #BCD2F7
│ ┌────────────────┬─────────────────┐ │
│ │ ⬇ Descarga     │   ⬆ Carga       │ │ SegmentedButton 48; seleccionado blanco
│ └────────────────┴─────────────────┘ │
├──────────────────────────────────────┤
│ ‹  Bahía 14   3 por bajar a la vista │ panel: cabecera + silueta compacta
│    ▁▂▃[█]▃▃▃▂▂▁                 Popa │ seleccionada en marca con el naranja
├──────────────────────────────────────┤
│ Babor · filas 04 a 00   Estribor 01–03│
│       04    02    00    01    03     │
│ 88  ┌╌╌╌┐┌╌╌╌┐┌╌╌╌┐┌╌╌╌┐┌╌╌╌┐        │ bajados: vacías con ✓ en hecho
│ 86  │⬇  ││ ▲ ││⬇  ││ ✓ ││⬇  │        │ Baja = marca con blanco; ▲ = bajando
│     │Baja││Baj.││Baja││Hecho│Baja│    │
│ 84  │vac.││PASO││⬇  ││⬇  ││❄  │      │ Paso = papel con el código, tinta suave
│     │Baja││JMKCT│Baja││Baja││Baja│    │
│ 82  │PASO││PASO││PASO││PASO││PASO│    │
│     │PAMIT│JMKCT│JMKCT│USHOU│USHOU│   │
│ ━━━━━━━━━━━━ tapa ━━━━━━━━━━━━━      │ tinta, 8 dp
│ 10 ╭│⬇  ││❄  ││⬇  ││⬇  ││⬇  │╮      │ bodega: #1F5FD6 con blanco, casco
│    ╰│Baja││Baja││Baja││Baja││Baja│╯   │
├──────────────────────────────────────┤
│ ✓ Descarga registrada                │ aviso en tinta sobre tinta (BsAviso)
│   TSTU 004218 0 · 014-01-86 [Deshacer]│ 6 s
├──────────────────────────────────────┤
│ ████████░░ Descarga 80 %             │
│  30          120          3          │ cifras 32/600 tabulares
│  por bajar   hechas    re‑estibas    │ hechas en hecho
├──────────────────────────────────────┤
│ ▦ Plano  ☰ Lista  ◔ Avance  ⫶ Est. ⋯ Más ●2 │ NavigationBar 72–80
└──────────────────────────────────────┘
```
La celda del muelle sigue en 56 × 48 (más alta si la letra lo pide), con el icono y el
rótulo; «Hecho» y «Paso» con los roles de la Fase 2; «Baja» en la marca con texto blanco y,
en bodega, en `#1F5FD6`. Un toque sobre «Baja» registra y la celda sale de su sitio en
naranja antes del aviso con «Deshacer» (13.3).

**Lo que la entrega 2 hizo distinto del lienzo (22-oct):** en la oficina, la vista Estado deja
el código y el peso en las celdas por bajar, como dice 13.2; la marca con rótulo («Baja»,
«Hecho», «Paso») va en el muelle y en las vistas Destino y Tipo. La leyenda es `BsCartela`
con las fichas de la vista y su cuenta más «Resaltar» (RF-011), debajo de la rejilla; en el
muelle operando, en su lugar va `BsBarraDeOperacion`. Las tarjetas de cifra van a la derecha
de la silueta desde 1040 dp de ancho útil y debajo con menos; sin operación no hay tarjetas.
La celda de carga lleva el OR como código y el estado como rol y segunda línea, porque
`BsCelda` no dibuja icono y código a la vez. El peso de la celda y de las pilas se escribe
como el plano impreso («28.7», sin unidad); el total de la bahía, con `formatearToneladas`.
La celda se ensancha con la letra del sistema para que el código de cinco letras quepa
entero a 2.0 (`BsMedidas.copyWith(anchoCelda:)`). El detalle es una sola hoja
(`DetalleContenedor`) en el panel lateral o en una hoja inferior. El título y el resumen de
la bahía van al ancho de la vista, no al de la rejilla (a 360 dp, centrados sobre una
rejilla más ancha que la pantalla, salían cortados). En el teléfono bajo (menos de 560 dp
de alto útil para el plano: 360 × 640 dp sí, 360 × 800 no), los controles del modo y la
silueta se van hacia arriba al desplazar la rejilla y vuelven al desplazarla hacia abajo
(`NestedScrollView`); la banda, la barra de la operación o la leyenda y la barra inferior no
se mueven: en 360 × 640 dp la rejilla no cabía debajo de la banda, la silueta y la leyenda,
y así se ve entera con un gesto.

**El teléfono bajo tras la corrección de 10.21 (23-oct): lo primero es la rejilla.** La
aceptación de Codex (H4) midió que a 360 × 640 dp ni el primer nivel de la rejilla se veía
al abrir el plano: la fila de controles (77 dp) y la silueta (173 dp) se comían los 234 dp
del área del plano, y desplazar cuenta como un paso más de RNF-002. Con menos de 560 dp de
alto útil para el plano (el emulador de 360 × 640, y también el previo a 360 × 800, que
trae sus dos avisos encima) el plano se arma así:
- **La silueta va compacta** (`BsSiluetaBuque(compacta: true)`, 13.6): los mismos niveles,
  números, barras de avance y botones de 56 dp, a 4 dp por nivel, unos 90 dp en vez de 161.
  Es lo único que queda arriba de la rejilla, y sigue yéndose al desplazarla y volviendo
  (`NestedScrollView`).
- **Los controles del plano bajan al pie**, al principio de la línea que ya se desplaza: la
  leyenda, o la barra de la operación en el muelle operando (`ParteDeLosControles.barra`).
  Son los mismos controles de T-107, uno tras otro a su ancho: el modo, el chip del zoom,
  «Acciones» solo con su icono (su nombre va en la descripción emergente) y, en Carga, «OR /
  últimos dígitos», que así queda al alcance del pulgar. La nube no se repite: ya está en la
  barra superior o en la banda.
- **El resumen del modo** (la línea de T-107) va justo encima del pie
  (`ParteDeLosControles.resumen`). Sin escala no se escribe «Confirma la escala para ver el
  plan de carga»: la banda del previo ya dice qué falta.
- **En la rejilla,** el margen de arriba es de 8 dp y los dos renglones del peso por pila
  (C-7) van debajo de la bodega, como los dibuja 9.2 bis, en vez de encima de la cubierta.
- Con eso, a 360 × 640 dp con la barra de estado del sistema **la primera fila de la
  cubierta se ve sin desplazar**: en el previo (la medición de RNF-002) y en Descarga; en
  Carga, con la línea del resumen, queda a un gesto, como antes. A 360 × 800 publicado
  (el Honor) nada cambia: los controles siguen sobre la silueta normal.

**Los avisos del muelle tras la aceptación de la candidata (23-oct, 10.29, H2).** El aviso
del registro sigue siendo el flotante de T-75 (6 s, con «Deshacer»), pero ya no cae sobre
los controles de la franja de la operación: **flota por encima de la fila de controles de la
barra** (el modo, el zoom, «Acciones», «OR / últimos dígitos», la acción), sobre las cifras,
que no se tocan, y nunca sobre la rejilla. Esa fila mide su alto, más el aire de abajo de la
barra (`MideElPieDelPlano` anota en `pieDelPlanoProvider`, en `avisos_del_viaje.dart`; sin
operación se mide la leyenda entera, que es toda controles), y la página del viaje lo pone
como aire de abajo del tema de `SnackBar` (`AvisosSobreElPie`, solo con el Plano a la
vista): vale para todo aviso de la página (el registro, «cargado correctamente», los
errores), sin tocar cada uno. Así todo lo que se toca en el muelle sigue tocable mientras
dura el aviso, «Deshacer» queda a mano todo su plazo y, esos segundos, las cifras de la barra
quedan debajo del aviso que las explica. El primer intento lo puso por encima de la barra
entera: en el teléfono bajo, con la silueta a la vista, cubría la única fila de celdas y la
siguiente «Baja» caía sobre el aviso (la corrección lo midió en el emulador y lo cambió). Las
hojas (los vacíos, el detalle) y los diálogos son rutas y quedan por encima de los avisos:
su pie nunca se tapa. En el listado de la agencia, «Descartar» y «Confirmar e importar» van
al pie fijo de la página (`persistentFooterButtons`), siempre a la vista, y el aviso flota
por encima. La barra de 4.3 («112, cifras, aviso y acción») y la ranura `aviso` de
`BsBarraDeOperacion` siguen disponibles; la candidata no las usa porque el aviso dentro de
la barra la haría crecer y mover la rejilla bajo el dedo.

**El borde de arriba del aviso (23-oct, 10.31, H2).** Con la letra a 2.0 el aviso de 6 s
crecía hacia arriba más que las cifras y pisaba la última fila de celdas: la regla de 10.29
acotaba el borde de abajo y nada acotaba el de arriba. **La regla completa: en el muelle
operando, el aviso de la página vive en la franja, entre el borde de arriba de la barra de
la operación (donde termina la rejilla) y su aire sobre la fila de controles; puede tapar
las cifras durante su plazo (10.30); la rejilla, el resumen de encima de la barra y los
controles, nunca.**
- **La página mide los dos bordes.** La barra entera se mide (`MideLaFranja` →
  `franjaDelPlanoProvider`), además de su fila de controles; `AvisosSobreElPie` resta el
  aire de abajo y dice a los avisos cuánto alto tienen (`LugarDelAviso`). Sin franja (la
  leyenda, la Lista, la oficina) no hay tope y nada cambia.
- **El aviso cabe por construcción.** Todos los avisos que pueden verse sobre el plano se
  hacen con `avisoDelViaje` (`avisos_del_viaje.dart`): compactos (4 dp de aire arriba y
  abajo, «Deshacer» al lado del texto con 8 dp a los lados) y con dos textos, el entero y uno
  corto que sigue diciendo qué pasó. El aviso mide los dos al ancho que tiene y muestra el
  primero que cabe en su alto; si ni el corto cabe (fuera de lo que se prueba: letra mayor
  que 2.0 o pantallas de menos de 360 dp), se recorta a su lugar: el tope no se pasa nunca.
  La letra del aviso es la del sistema y no se reserva sitio.
- **Los textos cortos.** El registro en Descarga pierde la celda («Descargado ·
  MNLU0000107»): la celda ya está en naranja (13.3) y el número del contenedor no se ve en
  la rejilla. En Carga, «Descarga y carga · OR 16», «Cargado · OR 16», «Corregido · OR 16».
  Un error o un aviso largo sin acción dice qué pasó («No se registró.», «No se aplicó todo
  el perfil vigente.») y lleva **«Ver»**, que abre el texto entero en un diálogo.
- **Las cifras de 10.31** (fuentes reales, 24 contenedores, el plano desplazado): el alto
  para el aviso va de 64 dp con la letra a 1.0 a 117–146 dp con la letra a 2.0. Con la letra
  a 1.0 el texto entero cabe en los dos teléfonos (360 × 640 y 412 × 915); con 1.45 y 2.0,
  según el ancho, sale el corto. El aviso de T-61 (10 s), el más largo de la página, sale
  corto con «Ver» a 2.0.
- **Todos los avisos de la app (23-oct, 10.33).** No solo los de la página se ven sobre el
  plano: Comparar se llama desde el plano, y los avisos de otras páginas (Parámetros, Tapas
  en la operación, Perfiles, BAPLIE de salida, Listado de la agencia, Tapas de escotilla y
  Viajes recientes) siguen en pantalla al volver mientras dura su plazo. Todos se hacen con
  `avisoDelViaje`: en su página, sin franja, dicen el texto entero; sobre el plano, el que
  cabe. Una guarda falla si aparece un `SnackBar(` hecho a mano en `lib/` fuera de
  `avisos_del_viaje.dart`. Sobre el fondo de error, el texto y la acción van en `onError`:
  la tinta y la marca no llegaban a 3:1 sobre el rojo.

### 13.9 Lo que no se toma y los datos que no se inventan

- **No se inventan datos.** La app no sabe qué grúa mueve qué contenedor ni dónde está la
  superestructura del buque, y no conoce nombres ni identificadores de equipos. La silueta
  no dibuja superestructura ni grúa; el panel «En vivo» dice el rol (Muelle u Oficina) y
  su API solo admite ese enum; «Grúa 2», «Muelle 1» y «Muelle 2» del lienzo son ilustración.
  El «Bajando» del lienzo es, en la app, la celda recién movida de 13.3.
- **De las sugerencias de Google entra** el mosaico de cifras, el oscuro técnico solo en la
  oficina, `CustomPainter` para la silueta, el casco y la marca (las celdas siguen siendo
  widgets por el toque, el foco y la etiqueta accesible) y el pulso de lo que llega por
  Firebase. **No entra:** mapas (no hay geografía en el alcance y los mapas en línea rompen
  el trabajo sin conexión), arrastrar contenedores (función nueva que toca el dominio),
  shimmer, hugeicons ni lucide.
- **Ninguna dependencia nueva.** La marca, la silueta, el casco y el anillo se pintan a mano.
  Los íconos del dominio y las ilustraciones llegaron en el paquete de Nube (10.14, 10.18 y
  10.19) y están integrados (13.11): la fuente `BayStreamIconos` es un asset y las
  ilustraciones son datos que la app pinta sola. Lo genérico sigue en Material Symbols.
- Material 3 sigue de base; `shadcn_flutter` y `go_router` no entran (10.1).

### 13.10 Lo que cambia en los tokens y el movimiento de la Fase 2

| Token | Antes | Ahora | Por qué |
|---|---|---|---|
| `BsMedidas.radioCelda` | 2 | 8 | Las esquinas del ícono (13.2) |
| `BsMedidas.radioPanel` (nuevo) | — | 18 | Los paneles del puente de mando (tarjetas de cifra, silueta, «En vivo») |
| `BsMedidas.radioCasco` (nuevo) | — | 18 | La esquina exterior de las celdas de los extremos de la bodega |
| `BsMedidas.pasoRejilla` (nuevo) | — | 32 | La rejilla de plano del fondo de noche |
| `BsMovimiento.recienMovido` (nuevo) | — | 1 500 ms | Cuánto dura el naranja (13.3) |
| `BsMovimiento.salida` (nuevo) | — | 150 ms | La celda sale de su sitio |
| `BsMovimiento.espera` (nuevo) | — | 1 200 ms | El bucle del contenedor en la marca |
| `BsMovimiento.pulso` (nuevo) | — | 2 200 ms | El pulso de «Al día» y de «En vivo» |
| `BsRol.punteado` (nuevo) | — | `false` | El contorno punteado de «bajado» de noche |
| `BsRol.atenuado` | tinta suave | tinta suave, o tinta si no llega a 4.5:1 | 13.2 |

Los radios de control (6), hoja (10) y diálogo (16) no cambian; el radio 18 es solo para
los paneles nuevos. Las alturas, los espacios, la celda de 56 × 48 y de 52 × 48 y la
tipografía de 4.2 y 4.3 no cambian.

### 13.11 Los íconos del dominio, las insignias y las ilustraciones (10.18, 10.19)

El paquete de Nube (`design/iconos/LEEME.md`, v2, 84 archivos con su SHA-256) trae **31 íconos
del dominio** en el estilo **B · Sólido** que eligió Carlos (10.18), **4 insignias** de 12 px y
**6 ilustraciones**, todo dibujado para BayStream desde la geometría del ícono (la celda, la tapa,
el casco, el hueco, la pieza que se mueve). Lo integró Timonel (Parte B y C) y lo acepta Codex.

**Cómo llega a la app.**
- La fuente `assets/fonts/bs_iconos/BayStreamIconos.ttf` (área de uso privado U+E000 a U+E022,
  em 1024, ascendente 1024, descendente 0, avance 1024: cada glifo ocupa el cuadrado del em,
  como Material Icons) se declara en `pubspec.yaml` como la familia `BayStreamIconos`. Es un
  asset, no una dependencia.
- `BsIconos` (`bs_iconos.dart`, copiado tal cual del LEEME) da una constante por glifo;
  `BsIconosCatalogo` los recorre por su nombre del paquete (31 íconos y 4 insignias) para las
  pruebas, los censos y las vistas previas. Los SVG quedan en `design/iconos/` para documentos.
- Las ilustraciones viajan como datos (`BsIlustraciones`, generado por
  `tool/bs_ilustraciones_generar.py` desde `design/ilustraciones/*.json`) y las pinta
  `BsIlustracion`: `CustomPainter` dentro de un `RepaintBoundary`, rutas de solo `M`, `L`, `C` y
  `Z`, trazos con puntas y uniones redondas, punteado como `stroke-dasharray`, y una etiqueta
  accesible como imagen (la descripción de cada dibujo, o la que dé la pantalla). Los colores van
  **por nombre** (los de 13.1) y se resuelven con los tokens del tema, nunca con los hex del JSON:
  `marca` es la marca como superficie en los dos temas; `cubierta` es el blanco del ícono (el
  papel de día, el relleno de «por bajar en cubierta» de noche); `bodega` es el acero; `grua` el
  relleno de grúa; `hecho`, el contorno del rol; `frase`, `fondo`, `hoja`, `panel`, `panel_alto`,
  `tinta`, `tinta_suave` y `linea`, sus tokens. La prueba comprueba que cada nombre da el mismo
  hex que el bloque `paleta` del paquete, en claro y en oscuro, y que los trazos quedan a 3:1 o
  más sobre el fondo.

**Dónde va cada ícono (la tabla del LEEME, con las colisiones resueltas por Carlos).**

| Concepto | Ícono | Dónde | Lo que sigue en Material |
|---|---|---|---|
| Contenedor | `contenedor20`, `contenedor40`, `contenedor45` según `sizeInFeet`; `refrigerado`, `tanque`, `plataforma`, `techoAbierto` según el tipo ISO; `vacio` para el vacío; `peligrosa` y `fueraDeMedida` mandan sobre el tipo (`condicionDelContenedor`, que da el glifo y su nombre) | la tarjeta de la Lista, el resultado de la búsqueda, el detalle, los chips de carga especial, las tarjetas de Estadísticas, «Asignar vacío», «Vacío» en la leyenda; el modo Contenido del selector lleva `contenedor40` (14.6) | `inventory_2` para el total de contenedores y para «Lleno»; `check_box` para «Llenos» |
| Peligrosa (IMDG) | `peligrosa` | la insignia (como `insigniaPeligrosa`), los chips IMO / IMDG, el detalle, «Carga especial» | el aviso genérico sigue en `warning_amber` |
| Buque | `buque` | «Paso» / sigue a bordo en la celda y en la marca de descarga, los recientes, «Perfiles guardados», el resumen del viaje, «Perfil longitudinal» | |
| Bahía | `bahia` | el destino «Plano» (en reposo y activo), «Posición», «Bahías», «Contenedores por bahía», «Ocupación», «Ir a» | |
| Tapa de escotilla | `tapaEscotilla` | «Tapas en la operación», «Editar tapas por bahía», los pasos de quitar / reponer y abrir / cerrar de la secuencia | |
| Descarga y carga | `descarga` («Baja», flecha hacia abajo) y `carga` («Sube», hacia arriba) | los segmentos de la banda del muelle, las marcas de la celda, la secuencia de descarga («Re‑estiba: sale» es `descarga` y «vuelve» es `carga`), la comparación, el panel de la carga | el hecho sigue en `check_circle` |
| Re‑estiba y pedir cambio | `reestiba`; `pedirCambio` | la marca de la celda y la marca de descarga; «Pedir cambio», «Bandeja de cambios», «Solicitudes de cambio» y la solicitud pendiente sobre la celda | |
| Peso | `pesoPila` en la línea del peso por pila del panel de carga; `vgm` en «Peso (VGM)» de la tarjeta | | `scale` es el peso genérico |
| Archivos | `baplie` («Seleccionar archivo», «Cargar archivo BAPLIE»), `compararBaplie`, `baplieSalida`, `listadoAgencia` («Listado de la agencia», «Elegir listado») | | el CSV de exportar sigue en `table_view`; PDF y JSON, en los suyos |
| Nube | `alDia` (al día) y `soloAqui` (solo este dispositivo, sin conexión) | el chip de estado y la barra superior | `cloud` para «Nube y cuenta» sin cuenta; `cloud_sync`, `cloud_upload`, `lock_clock`, `block` y `warning_amber` para los demás estados |
| Número de orden | `orden` | el modo Número de orden del selector (14.6); hasta T-118 no tenía sitio | |
| Sin sitio todavía | `limiteApilamiento`, `segregacion`, `grua`, `muelle`, `escala` | la tabla del LEEME los da como «ninguno hoy»: su concepto es texto o no tiene ícono; quedan en la fuente para cuando una pantalla los pida | |

**Reglas de uso.**
1. Los íconos del dominio se dibujaron en la rejilla de 24 y se usan a **16, 20 o 24 px**; las
   insignias, en la rejilla de 12, **a 12 px** en la esquina de la celda (`BsCelda.tamanoInsignia`).
   A otro tamaño se escalan enteros, nunca se recortan.
2. **Los genéricos siguen siendo Material** (buscar, cerrar, micrófono, parámetros, historia,
   descargar, más). Junto a los íconos nuevos, los genéricos que iban en `_outlined` pasan a su
   variante rellena (hecho, revisar, alertas, nube, tabla, avance, paleta, ocupado por 40 pies),
   porque la familia es sólida y a 16 px un contorno al lado de un macizo se lee más débil. La
   barra inferior y el riel llevan el mismo glifo relleno en reposo y activo: la selección la dice
   el indicador de Material 3.
3. Un mismo concepto lleva el mismo glifo en todas las pantallas (la regla que `condicionDelContenedor`
   fija para los contenedores), y el aviso genérico no se confunde con la carga peligrosa. El ícono
   principal del contenedor (`IconoDelContenedor`: la tarjeta de la Lista, el resultado de la
   búsqueda y el título del detalle) lleva el nombre de su condición como etiqueta accesible y como
   descripción emergente: «Carga peligrosa», «Refrigerado», «Fuera de medida», «Vacío», «Tanque»,
   «Plataforma», «Techo abierto» o «Contenedor de 20, 40 o 45 pies». La descripción emergente queda
   fuera de la semántica, para que el lector de pantalla no diga el nombre dos veces. Un ícono que
   va junto a su texto, o dentro de un botón con rótulo o con descripción emergente, no lleva
   etiqueta propia. La celda del plano nombra en su etiqueta lo que su insignia señala y lo que su
   color dice, «Carga peligrosa», «Refrigerado», «Fuera de medida» o «Vacío», con esos mismos nombres
   y en las tres vistas de «Colorear por» (`CondicionDelContenedor.enLaCelda`). Lo fijó la
   aceptación del paquete (10.23): la búsqueda dibujaba el glifo sin nombre, la Lista no aplicaba la
   regla y la celda no nombraba su insignia.
4. Las ilustraciones van en los estados que la tabla de 13.7 nombra, con la frase de siempre al
   lado: no reemplazan el texto, lo acompañan. Se apoyan en el fondo de la pantalla (sin pintar su
   propio fondo), a 320 de ancho (240 en la búsqueda y en las alertas, hasta 480 en el inicio).
   El dibujo acompaña a la frase y cede ante la letra: ocupa como máximo **tres décimas del alto
   de la ventana divididas por la escala de la letra** (`BsIlustracion.parteDelAlto`), y si con
   eso no llega a 120 dp de alto no se pinta (`altoMinimo`). Así, en el teléfono bajo (360 × 640)
   el inicio lleva su dibujo a 192 dp con la letra a 1.0 y a 132 dp con 1.45, y con 2.0 va sin
   dibujo, para que «Abre un plano de estiba» y «Seleccionar archivo» sigan en la primera
   pantalla. Lo encontró la captura de Android con la letra a 2.0 (Parte C).
   El naranja aparece solo en el contenedor izado de `inicio` (13.3).
5. Nada se inventa: ni grúas con nombre, ni buques reales, ni personas, ni cifras en los dibujos.
6. El censo de `test/t114_paquete_test.dart` comprueba que ningún concepto de la tabla sigue en
   Material (salvo lo que esta sección deja ahí a propósito), y `meetsGuideline` que las pantallas
   con ilustración conservan el contraste y los objetivos táctiles.
7. **La travesía del inicio** (`BsTravesia`, decisión 10.24). Un buque navega de izquierda a derecha
   por una banda de mar al pie del inicio, se desvanece al llegar a la derecha y vuelve a salir por la
   izquierda.
   - *Sin arte nuevo.* El buque son los grupos `casco_perfil`, `perfil_0_0` a `perfil_0_4`, `caseta` y
     `puente` de `sin_conexion`, sin la nube ni la pausa; el mar es el agua y la línea de flotación de
     esa misma ilustración, a todo el ancho; las olas y la estela llevan el trazo de esa línea. Los
     colores van por nombre y salen de los tokens del tema, como en `BsIlustracion`. Nada es naranja.
   - *La proa hacia donde va.* El buque que navega va reflejado, con la proa a la derecha. Es la única
     excepción a «la proa a la izquierda» (13.6), que sigue valiendo para todo lo que está quieto: la
     silueta, las ilustraciones y los íconos.
   - *Dónde y cuánto.* Una banda a todo el ancho, solo en el espacio que sobra debajo de los dos
     bloques del inicio (un `SliverLayoutBuilder` después de los bloques): no empuja ni tapa nada; si
     cambian la ventana o la letra, la que cede es la banda, y con menos de 120 dp libres no se pinta
     (regla 4). El agua ocupa el tercio de abajo, con un mínimo de 32 dp; el buque mide la mitad del
     alto de la banda, entre 56 y 120 dp.
   - *El movimiento*, solo con `Transform` y opacidad: el buque y las tiras de las olas se pintan una
     sola vez, cada uno dentro de su `RepaintBoundary`, en cajas que no cambian de sitio ni de tamaño
     en ningún cuadro; el cruce, el vaivén y el cabeceo son un solo `Transform` sobre la caja fija del
     buque (lo fijó la aceptación 10.26, H1). El cruce va a velocidad constante: el
     recorrido (el ancho de la banda más el del buque, que entra desde fuera y sale del todo) entre
     48 dp/s, acotado entre 14 y 40 s. Aparece en el primer 10 % del recorrido y se desvanece en el
     último 12 %; después quedan 3 s de mar vacío y vuelve a empezar. Sobre la línea de flotación sube
     y baja 1.5 dp cada 3.2 s y cabecea ±0.8° cada 4.4 s, alrededor del centro del casco. Detrás de la
     popa deja una estela corta: tres trazos que se apagan. Dos líneas de ola corren hacia la
     izquierda, a 8 y a 16 dp/s, en tiras que se repiten cada 48 dp sin costura.
   - *Cuándo se para.* Con reducción de movimiento el buque queda quieto a un tercio del ancho, las
     olas no corren y no hay ningún ticker activo. Con otra pantalla encima (`TickerMode`) y con la
     app en segundo plano (`AppLifecycleState`) se detiene, y al volver sigue desde donde iba.
   - *Es decorativa.* `ExcludeSemantics`, sin foco y sin toque: no anuncia nada y no estorba a nada.
   - *Las pruebas* (`test/t114_travesia_test.dart`): sin tickers ni movimiento con reducción de
     movimiento; sin cuadros con otra ruta encima ni en segundo plano; nada con menos de 120 dp; la
     opacidad 0 al empezar y al terminar el cruce y 1 a la mitad; el buque pintado una sola vez en 60
     cuadros; sin desbordes ni empujones a 360, 600, 1280 × 720 y 1920 × 1080 con la letra a 1.0,
     1.45 y 2.0; y `meetsGuideline` igual que antes.

## 14. La oficina con más plano (T-117) y el selector de modo (T-118)

Decisiones 10.36 a 10.39 de `SPRINT-4.md`. La propuesta, con sus medidas y sus wireframes, está
en `docs/T117-T121-RESULTADOS.md` (0.5, 0.6 y 0.5.9) y Carlos la aceptó con las recomendaciones
de Yov (10.38). Esta sección manda sobre la propuesta donde dicen cosas distintas; 14.10 dice qué
cambió y por qué. La regla: **el plano manda; lo demás cede y nunca se corta.**

### 14.1 La columna central de la oficina

Desde 600 dp (Windows, la Web y, con la densidad del muelle, una tableta Android), la columna
central se arma así, de arriba abajo:

| Pieza | Se queda o se desplaza | Alto con la letra a 1.0 | Clave |
|---|---|---:|---|
| La cabecera (14.8) | fija | 64 | `cabecera-de-oficina` |
| El puente: la silueta y las tarjetas cortas (14.2) | se desplaza | 173, 98 o 0 | `puente-del-plano` |
| El borde del puente | se desplaza con el puente | 12 | `borde-del-puente` |
| La franja de la bahía (14.8) | fijada arriba al desplazar, si cabe | 56 | `franja-de-la-bahia` |
| La rejilla, a su alto natural por el zoom | se desplaza | el de la bahía | `plan-zoom-NN` |
| La leyenda, que envuelve | se desplaza | el que pida | `leyenda-del-plano` |
| La franja de cifras (14.7), donde viven los avisos (14.5) | fija abajo | de 64 a un cuarto de la ventana | `franja-de-cifras` |

- La columna es un `CustomScrollView` (`columna-del-plano`) y la franja de la bahía se fija arriba
  (`FranjaFijadaSiCabe`, que hace lo de un `PinnedHeaderSliver`) **solo si mide un tercio de la
  columna o menos**; si no (la letra a 2.0 en una ventana baja), se va con el panel del buque,
  porque fijada taparía la rejilla entera: a 800 × 600 con la letra a 2.0 mide 224 dp y a la
  columna le quedan 306. La rueda sobre cualquier parte de la columna la desplaza: la silueta y la
  rejilla solo se desplazan en horizontal y no se la roban (la rueda en la silueta es T-119).
- **La rejilla ya no tiene desplazamiento vertical propio:** `PlanZoomViewport(alturaNatural:
  true)` la amplía y le dice a la columna su alto ampliado. Conserva el horizontal por dentro (su
  barra es T-119) y el pellizco de dos dedos.
- El título y el resumen de la bahía salen de la rejilla y van a la franja de la bahía.
- Desplazar no cambia la altura elegida del puente: se va de la vista y vuelve al subir. Cambiar
  de bahía no mueve la columna; si la bahía nueva es más baja, la columna se acomoda a su largo.
- En el muelle operando (una tableta Android), el pie sigue siendo la barra de la operación con
  las reglas de 13.8; la franja de cifras es de la oficina.
- **El teléfono no cambia** (13.8): el `NestedScrollView` del teléfono bajo, la banda y la barra
  de la operación. Solo cambian el selector de modo (14.6) y el resumen (14.7).
- **Oficina o teléfono lo decide la página**, por el ancho de la ventana (600 dp): con la ventana
  entre 600 y unos 720 dp el plano mide menos de 600, y si lo decidiera él se armaría como
  teléfono dentro de la oficina, con un segundo selector de modo. El plano suelto (sin la
  página) mide su ancho.

### 14.2 El puente en tres alturas

| Altura | Qué muestra | Alto (letra 1.0, 6 y 6 niveles) |
|---|---|---:|
| **Completo** (por omisión) | La silueta normal y, a su derecha, las tarjetas cortas en una fila o en dos (2 × 72 + 12 = 156, menos que la silueta) | 4 + 161 + 8 = 173 |
| **Compacto** | La silueta compacta (`compacta: true`, 13.6) y las tarjetas cortas que quepan en una fila | 4 + 90 + 4 = 98 |
| **Plegado** | Nada: quedan el borde y la franja de la bahía, y las cifras siguen en la franja de cifras | 0 |

- **La tarjeta corta** es `BsTarjetaCifra(corta: true)`: 12 dp de aire, el anillo de 40 (grosor
  7), el rótulo (`labelMedium`) y la cifra a **28 / 600 tabular**, el tamaño del titular de 4.2
  (no hay tamaño nuevo). El detalle no se dibuja: va en su etiqueta y en su descripción
  emergente. Mide 72 dp de alto (12 + 48 + 12: el rótulo y la cifra, más altos que el anillo) y
  **224 dp de ancho por la escala de la letra**, lo que pide «120 de 150» junto al anillo.
- **Cuántas caben:** junto a una silueta de al menos 400 dp. Caben por fila las que entren en el
  ancho que queda; van en una fila si caben todas y, si no, en dos, repartidas. Más de dos filas
  no: las que no caben se quedan en la franja de cifras, y si no caben dos por fila no va
  ninguna. A 1920 × 1000 con el panel fijo van en una fila; en la laptop de Carlos (1707 × 996),
  a 1536 × 793, a 1366 × 690 y a 960 × 1000, en dos; a 1280 × 720 y a 800 × 600, ninguna.
- **El alto no se fija: se mide.** Cada altura mide lo que mide su contenido con la letra del
  sistema, así que nada se recorta ni se estira. Por eso son tres alturas y no un alto libre (P1).
- **El borde** (12 dp, debajo del puente): una línea en `outlineVariant` y una agarradera de 32 × 4
  en línea fuerte, con el cursor de redimensionar fila.
  - *Arrastrar:* el borde sigue al puntero entre 0 y el alto de «completo». Mientras dura, el
    puente muestra **la altura más grande que cabe** en el alto arrastrado, arriba y entera
    (nunca recortada ni encogida), con el hueco debajo. Al soltar, se queda en la altura más
    cercana. El cambio no se anima: 4.5 solo anima `Transform` y opacidad.
  - *Doble clic:* pliega, o devuelve la última altura abierta.
  - *Teclado:* el borde recibe el foco, con el anillo de foco en marca; ↑ baja una altura, ↓ sube
    una, Intro o Espacio pliega o despliega.
  - *Lector de pantalla:* un control ajustable, «Alto del panel del buque», con su valor
    («completo», «compacto» o «plegado») y las acciones de subir y bajar.
- **El botón** de la franja de la bahía (`boton-del-puente`): «Plegar el panel del buque» (⌃) o
  «Desplegar el panel del buque» (⌄), que devuelve la última altura abierta (completo si no hubo
  otra).
- La app recuerda la altura (14.4).

### 14.3 El panel lateral: fijo, oculto o flotante

- **Fijo** (por omisión desde 1200 dp): 360 dp a la derecha, como hasta ahora.
- **El botón de la cabecera** (`boton-del-panel`, junto a Buscar y la nube): desde 1200 dp oculta
  o muestra el panel fijo, y la app lo recuerda (14.4); de 600 a 1199 dp, donde no hay panel fijo,
  abre o cierra el flotante. **Con el flotante abierto dice «Cerrar el panel lateral» y hace eso,
  en cualquier ancho** (10.42, H1): cierra el flotante, el panel sigue oculto y la preferencia no
  cambia. Para dejarlo fijo desde el flotante está «Fijar».
- **El borde del panel guardado.** Con el panel oculto, y siempre de 600 a 1199 dp, queda en el
  borde derecho de la ventana una franja de 12 dp (`borde-del-panel`) con una línea y una
  agarradera. **Va fuera de la columna**, para no tapar la barra de desplazamiento de la columna,
  que vive en su borde. Si el mouse se queda 250 ms en ella, el panel sale **flotante**; un clic o
  un toque también lo abre. Lo del mouse viene encendido y se apaga en Parámetros con «Mostrar el
  panel lateral al pasar el mouse por el borde» (P6); apagado, la franja no está y queda el botón.
  Solo el mouse abre por el paso; un dedo, solo con el toque.
- **El panel flotante** (`panel-flotante`): por encima de la rejilla, sin moverla, pegado a la
  franja del borde; desde debajo de la cabecera hasta encima de la franja de cifras (así ni tapa
  la franja ni lo tapa un aviso); 360 dp, o menos en una ventana angosta (la columna conserva 48).
  Panel alto, borde en línea y radio de panel a la izquierda. En su cabecera, «Fijar» (desde 1200
  dp: lo deja fijo y lo recuerda) y «Cerrar».
  - Abierto por el mouse, se va 400 ms después de que el mouse sale de él y de la franja.
  - Abierto por el botón, por la franja o por una celda, se va con «Cerrar», con Esc, con un clic
    fuera o con Atrás en Android (lo anota en `cerrablesDeAtrasProvider`, 8).
- **El detalle con el panel oculto** (P5): al tocar una celda, el panel sale flotante con el
  detalle (`DetalleContenedor`, la única hoja de detalle, 3.6); al cerrarlo, la selección se
  limpia. De 600 a 1199 dp pasa lo mismo: la hoja de abajo queda para el teléfono.
- **«En vivo» no se corta:** el panel reparte su alto. Con una celda elegida, el detalle se queda
  con lo que sobra y «En vivo» con hasta la mitad; sin celda, la frase «Toca una celda…» y «En
  vivo» con el resto. «En vivo» se desplaza por dentro.
- **Fuera del Plano** (Lista, Avance, Estadísticas) el panel lleva solo «En vivo», sin la frase de
  la celda; sin escala no hay «En vivo» y el panel dice la frase.

### 14.4 Las preferencias del equipo (0.5.7; 10.38, P2 y P3)

| Preferencia | Clave en el almacén | Valores | Sin valor |
|---|---|---|---|
| El alto del puente | `ui.bridgeHeight` | `completo`, `compacto`, `plegado` | completo |
| El panel lateral | `ui.sidePanel` | `visible`, `oculto` | visible |
| Mostrar el panel al pasar el mouse | `ui.sidePanelOnHover` | `si`, `no` | sí |

- Se guardan **por equipo**, en la caja de ajustes del almacén local: en Windows vive en el
  `%LOCALAPPDATA%` de la cuenta y en la Web en el perfil del navegador. No viajan a la nube.
- **Es la única excepción a «`domain/` y `data/` no se tocan»** (10.38): en `LocalVesselRepository`,
  `enum UiPreference { bridgeHeight, sidePanel, sidePanelOnHover }` con
  `getUiPreference(UiPreference key)` → `Either<Failure, String?>` y
  `setUiPreference(UiPreference key, String? value)` (null la borra); en `HiveVesselDataSource`, la
  clave `ui.<nombre>` en la caja de ajustes, por la misma cola de escrituras que el tema; en
  `LocalVesselRepositoryImpl`, dos `_guard`. Sin migración: sin valor, la presentación usa el de
  omisión. Tiene sus pruebas propias del almacén y del repositorio.
- La presentación (`preferenciasDeLaOficinaProvider`) lee las tres al abrir la oficina; un fallo
  de lectura cuenta como «sin valor». Un fallo al guardar deja la elección en memoria hasta cerrar
  la app; en Parámetros, además, lo dice un aviso.

### 14.5 Los avisos en la oficina (10.30 a 10.33; cierra O3)

- **La franja de cifras se mide como la franja del muelle** (`MideLaFranja`), y la columna central
  dice su ancho (`MideLosLados`); la página dice lo que tiene a la derecha (el panel fijo o el borde
  del panel guardado). `AvisosSobreElPie` pone el aire de los avisos para que vivan **dentro de la
  franja**: no pasan de su borde de arriba (`LugarDelAviso`) y a los lados no salen de la columna,
  así que no cruzan el riel ni el panel. Se mide un ancho y no una posición: una transición de
  página que escala la vista deja posiciones negativas, y el aire de un aviso no puede serlo. Pueden tapar sus cifras durante su plazo
  (10.30); la rejilla, la franja de la bahía, la leyenda y los controles, nunca, y **por
  construcción**, con el texto corto de `avisoDelViaje`.
- La franja de cifras **no lleva controles**: el aviso no tapa nada que se toque, y debajo del
  aviso queda solo el aire de 13.8 (8 dp).
- **Mide al menos 64 dp:** el aviso compacto pide 48 + 4 + 4, más esos 8 de aire. Con la letra
  grande crece con sus fichas, hasta **un cuarto del alto de la ventana**; si las fichas no caben,
  se desplazan por dentro. El aviso elige el texto que cabe en lo que mida.
- Fuera del Plano (Lista, Avance, Estadísticas) no hay franja: el aviso va al pie, como antes, pero
  a lo ancho de la columna central.
- El panel flotante termina encima de la franja: el aviso no lo tapa.
- En el muelle y en el teléfono no cambia nada (13.8). La matriz de 18 casos del teléfono se
  repite, la de avisos se extiende a la oficina y la guarda de `SnackBar(` sigue en todo `lib/`.

### 14.6 El selector de modo, `BsSelectorDeModo`

`BsSelectorDeModo<T>({required List<BsEntradaDeModo<T>> entradas, required T? elegido, required
ValueChanged<T> onElegir, BsFormaDelSelector forma = BsFormaDelSelector.segunElAncho, String nombre
= 'Modo del plano', ValueChanged<VoidCallback>? alAbrirElMenu, ValueChanged<VoidCallback>?
alCerrarElMenu})`, con `BsEntradaDeModo<T>({required valor, required rotulo, rotuloCorto,
icono, cuenta, cuentaCorta, ayuda})`, en `lib/core/design/componentes/bs_selector_de_modo.dart`.
**Un solo selector:** sustituye al `DropdownButton` de Material 2 del plano y al `SegmentedButton`
Descarga / Carga de la cabecera de la oficina, y sirve también para «Colorear por» (14.8).

- **Segmentos:** un `SegmentedButton` con el icono, el rótulo corto («Orden») y, con operación,
  la cuenta corta en tinta suave y cifras tabulares («Descarga 28»); el elegido va invertido
  (13.1: tinta con texto noche de noche, marca tenue de día). Mide 40 dp en la oficina y 48 en el
  muelle. El nombre entero y la ayuda van en la descripción emergente.
- **Menú:** un botón con el icono, el nombre del elegido y ⌄, que abre un `MenuAnchor` de Material
  3 con la superficie de panel, el borde en línea y el radio de hoja (10). Cada entrada mide 56 dp
  o más: el icono, el nombre, una línea con su cuenta o su ayuda en tinta suave y, en la elegida,
  la palomita en marca. Con flechas, Intro y Esc, y para el lector de pantalla, como todo
  `MenuAnchor`; con la letra a 2.0 cada entrada crece con su texto y el menú se desplaza dentro de
  la pantalla.
- **Esc y Atrás cierran el menú** (10.42, H2). `MenuAnchor` atiende Esc solo con el foco dentro del
  menú, y al abrirse con el mouse o el dedo el foco no entraba: al abrirse, el foco pasa a la
  entrada elegida (o a la primera), como en un menú del sistema. En Windows y en la Web, Esc lo
  cierra. Al cerrarse no se le devuelve el foco al botón a la fuerza: en el emulador, tras Atrás,
  el botón quedaba con el sombreado del foco (Android pinta el foco después de una tecla); abierto
  con el teclado, el foco vuelve a él por su cuenta. El menú no es una ruta, así que Atrás de Android no
  lo cerraba: el selector da a quien lo usa lo que lo cierra (`alAbrirElMenu`, `alCerrarElMenu`) y,
  del lado del viaje, `SelectorDelModo` y «Colorear por» lo anotan en `cerrablesDeAtrasProvider`
  (8): el primer Atrás cierra el menú, el plano se queda y ese toque no cuenta como el primero del
  doble Atrás. El componente no sabe nada del viaje.
- **La forma la elige el ancho medido** (`segunElAncho`): los segmentos si caben enteros en el
  ancho que hay; si no, el menú. Lo mide `BsPrimeraQueCabe` (14.11).
- **Los modos:**

| Modo | Icono | Cuenta en el menú | Ayuda |
|---|---|---|---|
| Contenido | `contenedor40` | — | El destino de cada contenedor |
| Número de orden («Orden» en segmentos) | `orden` | «30 OR del listado» | Los OR del listado de la agencia |
| Descarga | `descarga` | «28 por bajar en GTSTC» | Toca un contenedor para marcarlo como descargado |
| Carga | `carga` | «29 pendientes: 20 llenos, 9 vacíos» | Toca un contenedor o busca su OR para cargarlo |

  En segmentos, la cuenta corta es solo el número de pendientes.
- **Dónde va:**
  - en la oficina, en la cabecera (14.8), con el Plano a la vista: en la Lista, el Avance y las
    estadísticas el modo no cambia nada;
  - en el teléfono, como menú, en la línea de los controles del plano (o en la tira del pie del
    teléfono bajo, 13.8). Con la banda del muelle (operando) el menú ofrece Contenido, Número de
    orden y el modo vigente: Descarga y Carga ya están en la banda (0.6.2). En esa línea
    «Acciones» va solo con su icono (⋮, como en la tira y en el wireframe de 0.6.2), y el nombre
    del modo envuelve en dos líneas si no cabe: el menú con su icono es más ancho que el
    desplegable de antes.
- **Conserva** la clave `bay-plan-display-mode` (en el selector entero) y los textos «Contenido»,
  «Número de orden», «Descarga» y «Carga».

### 14.7 El resumen del modo en fichas

- **La ficha** (`BsFichaDeCifra({required rotulo, required valor, rol})`): el rótulo en tinta suave
  y el dato en tinta con cifras tabulares, en una línea que envuelve si no cabe, nunca con elipsis;
  con `rol` (revisar), en el contorno del rol.
- **En la oficina, en la franja de cifras,** tres fichas a lo sumo, en este orden: la bahía (lo que
  las tarjetas no dicen), el modo y el otro modo. **La ficha de la bahía empieza por sus cifras**
  (10.40: bajan de la franja de la bahía para que esta quepa en una línea) y sigue, tras un punto y
  coma, con lo que la operación dice de la bahía:

| Modo | La bahía | El modo | El otro modo |
|---|---|---|---|
| Carga | «Bahía 10: 20 contenedores, 231.9 t; por cargar cub. 2, bod. 7» | «Carga: 29 pendientes, 20 llenos, 9 vacíos» (`loading-operation-totals`) | «Descarga: 28 pendientes, 1 re‑estiba» |
| Descarga | «Bahía 14: 36 contenedores, 712.4 t; 3 por bajar en cub., 5 en bod., 2 bajados» (`bay-discharge-pending`) | «GTSTC: 30 por bajar, 120 bajados, 3 re‑estibas» (`operation-discharge-totals`) | «Carga: 29 pendientes» |
| Contenido o Número de orden, con escala | «Bahía 10: 20 contenedores, 231.9 t; carga: cub. 2 (1 lleno, 1 vacío), bod. 7 (5 llenos, 2 vacíos)» (`bay-loading-pending`) | En Número de orden, «Listado: 3 celdas de carga sin cruce» o «Sin listado de la agencia» | — |
| Sin escala | «Bahía 10: 20 contenedores, 231.9 t» (`cifras-de-la-bahia`) | «Viaje: 977 contenedores, 27 bahías, 7 419.5 t» | — |

- **La bahía que se ve y el grupo de su par** (T-124, P2 de 10.65). En Carga y en Contenido
  lo pendiente es del grupo de 40 pies (H5, `reference_bay.dart`: la 21 y la 23 se cuentan
  con la 22). La ficha dice **lo de la bahía que se ve, con su número**, y **lo del grupo, con
  el rótulo de su par** y las bahías que cuenta. Antes, con la 21 elegida, decía «Bahía 22: 7
  contenedores, 1 celda reservada, 57.7 t…; por cargar cub. 27»: las cifras eran de la 21 y el
  rótulo de la 22, que tiene 11.

| Dónde | Bahía sola (no cuenta otra) | Bahía de un grupo (la 21, la 22 o la 23; el banco de T-122) |
|---|---|---|
| Oficina, Carga | «Bahía 10: 20 contenedores, 231.9 t; por cargar cub. 2, bod. 7» (como antes) | «Bahía 21: 7 contenedores, 1 celda reservada, 57.7 t, tapas sin declarar; grupo 22 (21, 22 y 23), por cargar cub. 27, bod. 0» |
| Oficina, Contenido u Orden | «Bahía 10: …; carga: cub. 2 (1 lleno, 1 vacío), bod. 7 (…)» | «Bahía 23: …; carga del grupo 22 (21, 22 y 23): cub. 27 (…), bod. 0 (…)» |
| Teléfono, Carga (sin las cifras) | «Bahía 10: cub. 2, bod. 7» | «Bahía 21: grupo 22 (21, 22 y 23), cub. 27, bod. 0» |
| Teléfono, Contenido (sin las cifras) | «Bahía 10, carga: cub. 2 (…), bod. 7 (…)» | «Bahía 21, carga del grupo 22 (21, 22 y 23): cub. 27 (…), bod. 0 (…)» |

  - El rótulo de la ficha es siempre la bahía elegida (`rotuloDeBahia`); el grupo se nombra
    con «grupo» y el número de la par, entre paréntesis las bahías del plan de carga que
    cuenta, más la elegida si es una mitad de 20 sin carga propia («grupo 02 (01 y 02)»).
  - Se nombra cuando la bahía elegida no es la par o cuando la par cuenta alguna impar
    (`BayLoadingPending.paired`); una bahía sola sigue como antes, sin «grupo».
  - En Descarga no hay grupo: lo pendiente de bajar es de cada bahía (`DischargeProgress`).
  - Las claves no cambian (`loading-bay-pending`, `bay-loading-pending`).
- Las cifras de la bahía son las de antes: los contenedores, las celdas reservadas si hay, el peso y
  «tapas sin declarar» si faltan. Mientras se lee la operación, o si falla, van en su ficha propia
  (`cifras-de-la-bahia`) delante de la que lo dice. En el teléfono no cambian: el resumen no las
  lleva, y en la tableta del muelle operando, sin franja de cifras, siguen en la franja de la bahía.

- Lo que el resumen avisaba sigue, como ficha en revisar: «Importa el listado de agencia para
  operar por OR.» y «Esta escala todavía no tiene operación guardada: …». También «Leyendo el estado
  de la operación…» y los errores con su causa.
- **Las fichas envuelven:** lo que no cabe en la línea pasa a la siguiente y la franja crece, hasta
  el tope de 14.5. No hay «⌄ más» (14.10).
- **La instrucción** «Toca un contenedor para marcarlo como descargado» deja de estar fija: es la
  ayuda de Descarga en el selector.
- **Los botones del resumen** van a la franja de la bahía: «OR / últimos dígitos» a la vista en
  Carga, y «Asignar vacío», «Pendientes…», «Avance de la operación», las solicitudes de cambio e
  «Importar listado» en «Acciones». El chip de la nube del resumen sale: está en la cabecera.
- **En el teléfono**, la misma línea de T-107 (`PlanSummaryLine`), con las mismas fichas una debajo
  de otra; con la barra de la operación del muelle (13.8), solo la bahía y los avisos de arriba,
  porque la barra ya cuenta el modo. Recogida sigue midiendo una línea: las medidas de los avisos
  del teléfono no cambian.

### 14.8 La cabecera y la franja de la bahía, medidas

- **La cabecera** (`cabecera-de-oficina`): el buque y el viaje, el estado («Publicado» o «Sin
  confirmar») y el selector de modo; siempre en el borde derecho, Buscar, la nube y el botón del
  panel. Con `BsPrimeraQueCabe`: en una línea con los segmentos; si no caben, en una línea con el
  menú; si tampoco, en dos líneas, el título arriba y el estado con el menú abajo (la regla de la
  corrección de 10.21).
- **La franja de la bahía** (`franja-de-la-bahia`): ‹ y › (la bahía anterior y la siguiente,
  `bahia-anterior` y `bahia-siguiente`); el título «Bahía 10», que abre la lista de bahías
  (`bahia-elegir`); a la derecha «Colorear por» (`colorear-por`), el zoom (`ZoomDelPlano`), «OR /
  últimos dígitos» en Carga, «Acciones» (`bay-plan-actions`) y el botón del puente. Las cifras de
  la bahía no van aquí: abren la franja de cifras (14.7, 10.40). En una línea con «Colorear por» en
  segmentos; si no cabe, con el menú; si tampoco, con «OR / últimos dígitos» solo con su icono y el
  rótulo en la descripción emergente; si tampoco, además con «Acciones» solo con su icono (⋮, como
  en el teléfono, 14.6); si tampoco, envuelve en las líneas que pida: nada se corta.
- **El botón del puente no queda solo en una línea** (10.42, H3). A 700 dp, sin el panel fijo, en
  Contenido, la franja iba en dos líneas (108 dp) solo porque el botón no cabía al final de la
  primera. Con «Acciones» solo con su icono va en una (56 dp), también en Descarga. En Carga, con
  el OR, a 700 dp no cabe ni así y va en dos líneas, con el botón al final de la primera. Y cuando
  la franja envuelve de verdad (la letra grande, o de 600 a 700 dp), el botón va fuera de lo que
  envuelve, arriba a la derecha, al final de la primera línea: la franja no crece por él.
- **Lo que envuelve no se desborda nunca** (10.42). Al medir la corrección, la matriz angosta (600,
  700, 800 y 960 dp; letra 1.0, 1.45 y 2.0; los tres modos) encontró que con la letra a 2.0, en
  Carga, los controles con sus rótulos no cabían en una línea entera y se desbordaban (35 dp a 700,
  135 a 600), algo que ya pasaba antes y que la matriz de 0.5.5 no veía. En la variante que
  envuelve, «Colorear por» puede partirse de su menú, y los controles van con rótulos solo si caben
  en una línea entera; si no, el OR y después «Acciones» quedan solo con su icono.
- **«Acciones» es un botón con su nombre, con el icono o con el rótulo** (10.44, H4). Para el
  lector de pantalla es el botón «Acciones», dicho una vez, y con la cuenta del distintivo cuando
  la muestra («Acciones, 2 solicitudes pendientes»). La descripción emergente sigue al pasar el
  mouse, fuera de la semántica (la regla de los iconos del contenedor, 13.11): Windows toma el
  nombre de la etiqueta y le suma la descripción emergente, en UIA y en MSAA. Por eso
  `PopupMenuButton`, con un hijo propio, no basta: no da el rol de botón. Solo con el icono, el nodo
  quedaba sin nombre y fuera del árbol; con el rótulo, salía «texto Acciones. Acciones». En el
  teléfono, el resumen de una línea que se abre y se recoge (`PlanSummaryLine`) es también un
  botón por la misma razón.
- **Con el panel fijo y la letra a 1.0 va en una línea** a 1920 × 1000, 1707 × 996, 1536 × 793 y
  1366 × 690, en los cuatro modos (56 dp, con «Colorear por» a la vista; la matriz lo comprueba a
  1536 y a 1366). Medido con las fuentes reales: a 1536 caben los segmentos; a 1366, en Carga, el
  menú. El icono solo del OR entra con la letra a 1.45 a 1366 × 690. Con la letra a 1.45 a 1280 y
  con 2.0 puede ir en dos líneas (62 a 126 dp).
- **En la tableta del muelle operando** no hay franja de cifras (va la barra de la operación,
  13.8): ahí las cifras siguen junto al título, como antes.
- **«Colorear por»** usa el mismo selector, sin iconos: Destino y Tipo de vacío siempre, y Estado
  solo en Descarga, la única vista que lo pinta. La elección sigue en memoria por modo (5.4).
- La franja de la bahía lleva el papel de fondo y una línea abajo: la rejilla pasa por debajo sin
  verse a través.

### 14.9 Con cualquier tamaño de ventana

- La leyenda envuelve dentro de la columna y nunca va en un desplazamiento horizontal: a 1920 con
  el panel abierto ya no se corta «Celda reservada».
- El puente solo cambia con el ancho en cuántas tarjetas lleva, y nunca se corta por el alto: si la
  ventana es más baja que lo que se ve a la vez, la columna se desplaza.
- **La matriz de pruebas** (`test/t117_oficina_test.dart`): 1920 × 1000, 1707 × 996, 1536 × 793,
  1366 × 690, 1280 × 720, 960 × 1000 y 800 × 600; letra 1.0, 1.45 y 2.0; panel fijo, flotante y
  oculto; Contenido, Descarga y Carga. Sin desbordes, con la leyenda, las franjas y las tarjetas
  enteras y la rejilla a la vista.
- **En la ventana real:** maximizar, ajustar con Win + ← y →, redimensionar con el borde y, si hay
  un segundo monitor, arrastrar de uno al otro.

### 14.10 Lo que cambió respecto de la propuesta

1. **Sin «⌄ más» en la franja de cifras** (0.6.2): la franja no lleva controles (0.5.6), porque el
   aviso la tapa durante su plazo. Las fichas envuelven.
2. **La franja de cifras mide al menos 64 dp, no 56** (0.5.6): el aviso compacto (56) más los 8 dp
   de aire de abajo de 13.8.
3. **La franja del borde del panel va fuera de la columna** (0.5.4): dentro tapaba la barra de
   desplazamiento de la columna, que vive en su borde derecho.
4. **El detalle de 600 a 1199 dp va al panel flotante** (0.5.4 lo decía del panel oculto, y ese
   tamaño no tiene panel fijo): una sola forma del detalle en la oficina.
5. **Sin escala, la franja de cifras dice el viaje** («977 contenedores, 27 bahías, 7 419.5 t»):
   así siempre hay franja y los avisos tienen su lugar.
6. **«Colorear por» usa el mismo selector**, sin iconos, con Estado solo en Descarga.
7. **El cambio de altura del puente no se anima** (la propuesta decía 150 ms): 4.5 solo anima
   `Transform` y opacidad, y animar un alto mueve el layout cuadro a cuadro.
8. **El selector de modo de la cabecera solo va con el Plano a la vista:** en las demás pestañas el
   modo no cambia nada de lo que se ve.
9. **En el teléfono, «Acciones» va solo con su icono** en la línea de los controles (14.6).
10. **Oficina o teléfono lo decide la página** y no el ancho del plano (14.1).
11. **Las variantes de una línea no llevan `Wrap`** (14.11): el ancho intrínseco de un `Wrap` no
    suma su `spacing`, y la cabecera medida así se desbordaba 7.4 dp a 1366 × 690.
12. **La franja de la bahía se fija solo si cabe y la de cifras tiene tope** (14.1 y 14.5): con la
    letra a 2.0, a 800 × 600 y a 1280 × 720, la franja fijada era más alta que el hueco de la
    columna y la rejilla no llegaba a verse; la de cifras llegaba a 239 dp.
13. **Las cifras de la bahía bajan a la franja de cifras** (10.40): con ellas en la franja de la
    bahía, con el panel fijo y la letra a 1.0, la franja iba en dos líneas (108 dp) a 1536 × 793 y
    a 1366 × 690. Ahora va en una (56 dp) y la ficha de la bahía empieza por ellas. Si aun así no
    cabe, «OR / últimos dígitos» queda solo con su icono.
14. **La corrección 1 de la entrega 1** (10.42): con el flotante abierto, el botón de la cabecera
    cierra el flotante y no fija el panel (14.3); Esc y Atrás cierran el menú del selector, y ese
    Atrás no cuenta como el primero del doble Atrás (14.6); y el botón del puente no queda solo en
    una segunda línea de la franja de la bahía (14.8).
15. **La corrección 2 de la entrega 1** (10.44): «Acciones» es un botón con su nombre para el
    lector de pantalla, con el icono o con el rótulo, y el resumen de una línea del teléfono
    también es un botón (14.8).

### 14.11 Las piezas nuevas y su API

Las de `lib/core/design/componentes/`, con documentación, vista previa y prueba, como las de 13.6.

| Pieza | API | Qué hace |
|---|---|---|
| `BsSelectorDeModo` | 14.6 | El selector de modo, en segmentos o en menú |
| `BsPrimeraQueCabe` | `BsPrimeraQueCabe({required List<Widget> variantes})` | Mide cada variante a su ancho natural y pone la primera que cabe en el ancho que hay; si ninguna cabe, la última, con el ancho que hay (se espera que envuelva). Solo la elegida se dibuja, se toca y se anuncia, como en un `IndexedStack`. «Cabe» es con la tolerancia con que `RenderFlex` avisa de un desborde (`precisionErrorTolerance`): con medio dp de gracia, a 960 dp con la letra a 2.0 entraba una variante 0.08 dp más ancha (10.42) |
| `BsFichaDeCifra` | 14.7 | La ficha del resumen |
| `BsTarjetaCifra` | nuevo `corta = false` | La tarjeta corta del puente (14.2) |

Y en la presentación: `PuenteDelPlano` y su borde (`puente_del_plano.dart`), la columna de la
oficina (`bay_plan_view.dart`), la franja de la bahía y la de cifras (`franjas_del_plano.dart`), el
panel lateral y el flotante (`panel_lateral_del_viaje.dart`) y las preferencias
(`providers/oficina_providers.dart`).

## 15. Las estadísticas: «El buque en corte» (T-121)

Decisiones 10.36 a 10.38 y 10.46 de `SPRINT-4.md`. La propuesta A, con su inventario, lo
que se toma de cada referencia, lo común a las dos propuestas, la paleta validada y los
wireframes de la fase 0, está en `docs/T117-T121-RESULTADOS.md` (0.9); Carlos la eligió en
10.38 (P8) con la cifra protagonista a 48 (P9). Esta sección manda sobre la propuesta donde
dicen cosas distintas; 15.11 dice qué cambió y por qué. La regla: **Estadísticas es el mismo
buque del plano, visto entero, y todo número tiene su tabla.**

### 15.1 Qué cambia y por qué

La vista de T-109 era una columna de tarjetas iguales, con 27 `Colors.*`, violeta y naranja de
adorno, la cifra en el color del dato, texto a 9 dp y girado, «62.6%» sin espacio y un casco
que no era el de la silueta (0.9.1). Pasa a ser una sola página con una protagonista, la
silueta grande del buque con la carga de cada bahía, y cinco paneles debajo; todo sale del tema
y de `BsColoresSemanticos`, ningún texto lleva el color del dato, nada se gira y nada baja de
11 en el teléfono. Es la cuarta pantalla clave de la Fase 3 (T-114).

### 15.2 La cifra protagonista

**«977 contenedores a bordo»**, la única cifra que encabeza la vista: **48 / 600 / 1.05,
tabular**, en Plex Sans como todo lo demás (`BsEscala.cifraProtagonista`,
`BsTextos.cifraProtagonista`). Está por encima de la escala de razón 1.2 de 4.2, que termina
en los 34 de la cifra grande; es el tamaño que la skill de dataviz pide para la cifra que
encabeza un tablero, y Carlos lo aprobó en 10.38 (P9). **Una sola vez por vista**: las demás
cifras de la cabecera (el peso total, las bahías con carga, los llenos, los vacíos y, si los
hay, los sin estado) van a 28 / 600 tabular, el titular de 4.2, con su rótulo debajo en
tinta suave. La fila de cifras envuelve: a 360 dp con la letra a 2.0 van una por línea.
En un plan de carga con vacíos asignados a una celda reservada, la protagonista los cuenta y
**una ficha debajo dice cuántos son** (15.13).

### 15.3 La rampa de magnitudes y los demás colores

**La rampa de 5.5 de la Fase 1 no pasaba el validador** en su paso claro (`#D9E7FC` a 1.25:1
sobre la hoja; 0.9.4). La sustituye esta, de un solo tono (el azul de la marca), validada con
`validate_palette.js --ordinal` de la skill de dataviz sobre las tres superficies de cada modo
(`BsPaleta.rampaDeMagnitud`):

| | Paso 1 (menos) | Paso 2 | Paso 3 | Paso 4 (más) | Paso extremo sobre la hoja / el papel |
|---|---|---|---|---|---|
| Día | `#88B0F5` | `#518FF1` | `#1365E5` | `#0D47A1` (la marca) | 2.19:1 / 2.06:1 |
| Noche | `#2C5BA8` | `#4F8EF7` (la selección) | `#95BBF6` | `#D9E7FC` | 2.62:1 (panel) / 2.86:1 (noche) |

De noche la rampa se invierte: sobre la noche, «más» tiene que ser más luminoso. `#88B0F5` es
un valor nuevo del producto y entra en `bs_paleta.dart` con la rampa. De día, `#D9E7FC` deja de
ser dato y queda como **pista de las barras** (`BsPaleta.pistaDeMagnitud`); de noche sigue
siendo dato, el paso 4 de la rampa, y la pista es la línea `#1E3457`: un paso más del mismo
tono, para que la barra se lea entera.

Dónde va cada color:

| Qué | Color | Por qué |
|---|---|---|
| Una sola serie (las barras por puerto y por naviera) | `primary`: la marca de día, la selección de noche | Una serie, un color (0.9.3). El puerto no colorea la barra: lo identifica su caja |
| Lo ordenado (20, 40 y 45 pies) | los pasos 2, 3 y 4 de la rampa; «Otro», si lo hay, el paso 1 | Van en orden, y la rampa lo dice; el paso 1 queda bajo 3:1 y por eso solo va con su rótulo al lado |
| La caja del código de puerto | el rol categórico del puerto (5.3 y 13.4): relleno, código y contorno | Enlaza con el plano. Es el único sitio del color del puerto; el validador rechaza las fichas como relleno de serie (0.9.4) |
| La pila de cubierta de cada bahía | `porBajarCubierta.relleno`: la marca de día, la cubierta del ícono de noche | El buque se pinta como el ícono (13.2): 8.6:1 sobre la hoja de día, 17.8:1 sobre el panel de noche |
| La pila de bodega | `porBajarBodega.relleno`: `#1F5FD6` de día, el acero de noche | 5.7:1 sobre la hoja y 4.9:1 sobre el casco de día; 6.9:1 y 6.0:1 de noche. Es el azul de bodega de la vista Estado, no la pintura apagada de la silueta del plano, porque aquí la pila es el dato |
| El anillo de llenos | `primary` sobre la pista en línea | Un medidor de una razón; el anillo de avance es de la operación, este no |
| La carga especial | el rol de 5.1: peligrosa, refrigerado y OOG, con relleno, contorno e icono | El uva de OOG es su rol, no un adorno. El contorno sobre el relleno llega a 4.2:1 o más en los dos modos |
| El texto | tinta, tinta suave o tinta tenue; dentro de la caja del código y de la tarjeta de rol, el texto del rol sobre su relleno (13.4), a 4.5:1 | El texto nunca lleva el color del dato: el texto de un rol es el que el rol define para leerse sobre su relleno (de día la tinta, de noche el tono vivo), no el color de la barra ni de la pila |

**El naranja no aparece:** en Estadísticas no hay nada que se acabe de mover (13.3). Ningún
`Colors.*` en la capa de presentación; una prueba-censo (`test/t121_estadisticas_test.dart`)
falla si vuelve uno.

### 15.4 El buque en corte, `BsBuqueEnCorte`

La protagonista. El casco de `BsSiluetaBuque` (la proa a la izquierda, la línea de
flotación, sin superestructura; 13.6) en grande, y en cada bahía **dos pilas que son el
dato**: la de cubierta crece hacia arriba desde la tapa y la de bodega hacia abajo, dentro
del casco; su alto dice los contenedores de esa zona o su peso, según el selector. Las dos
pilas comparten la escala (la zona más cargada de todo el buque llena su alto de 72 dp), y
cada pila lleva un separador de 1 dp en el color de su fondo cada 9 dp (la hoja del panel en
cubierta, el casco en bodega), el paso de los niveles de la silueta: se lee como una pila de
contenedores y mide como una barra.

- **Cada columna es una bahía de referencia** (T-124; 10.53, 10.56 y 10.65): la regla de
  Carlos, la misma del avance y de la silueta del plano. **La par es la bahía de
  referencia**: cada impar se cuenta con la par vecina que la cubre si esa par es una bahía
  del viaje (`referenceBay`, con las bahías de `voyage.bays` y las de las posiciones), y el
  grupo lleva el número de la par. La 21 y la 23 van en la columna de la 22, zona por zona y en
  peso; una impar sin par vecina en el viaje queda sola. **Tocar la columna abre la par en el
  plano.** Con `T100_LLEGADA` son tres columnas (02, 06 y 10), cada una en su tope y con el casco
  centrado; el sintético de 977, que trae 72 números de bahía, son 24 (de la 02 a la 94). Antes
  cada número era una columna y la mitad de 20 sin carga salía en cero (seis de nueve en
  `T100_LLEGADA`, 10.53).
- **Medidas** (dp, con la letra a 1.0): 8 de aire arriba; 72 la zona de cubierta; 4 de
  holgura; la tapa de 2 a la altura 84; 4 de holgura; 72 la zona de bodega; 10 de fondo; el
  casco termina en 170 y la línea de flotación va 3 debajo. **Cada bahía mide al menos 56 de
  ancho por la escala de la letra** (`anchoBahia`), y nunca menos que el rótulo más ancho de
  su pie más 8: a 2.0 son 112, y con 72 bahías la silueta mide 8 064 y se desplaza. La pila
  mide 12 menos que la bahía. Los márgenes de proa y popa miden al menos 28: lo que midan
  «Proa» y «Popa» con la letra del sistema, más 8.
- **Cuando las bahías caben, la silueta ocupa el ancho útil del panel** (`repartir`; corrección
  1 de la entrega 2, H1 de 10.53). Las bahías se reparten por igual lo que deja el panel
  después de los dos márgenes, y **cada una crece hasta un tope de tres veces su mínimo**: 168
  con la letra a 1.0, 336 a 2.0. Si aun así sobra ancho, **el casco va centrado** en el panel,
  con la proa y la popa a la misma distancia de los bordes. Por qué tres veces:
  - a 168 la pila mide 156, apenas una vez y media el alto de su zona crecida (108): sigue
    leyéndose como una pila de contenedores y no como una losa. De costado, una bahía de 40
    pies mide casi cinco veces el alto de un contenedor (12.2 m contra 2.6), y la pila de 56,
    con niveles de 9, ya la dibuja más ancha de lo que es; más allá del triple, una sola bahía sería una barra y el casco un rectángulo;
  - con ese tope, **desde ocho bahías la silueta llena el panel de 1440** (el de la página a
    1920, 1 406 de ancho útil). Con la regla de la par (T-124) el plano de llegada son tres
    bahías de referencia y va centrado, cada una en su tope; un alimentador de tres o cuatro
    bahías, igual, sin estirarse.
- **En pantalla ancha, el alto de las zonas crece con la bahía:** en la misma proporción que
  su ancho sobre el mínimo, hasta 1.5 veces (de 72 a 108 cada zona; el dibujo pasa de 174 a
  246). El paso de los separadores sigue en 9: una zona crecida lleva más niveles dibujados,
  no niveles más gruesos. **Solo crece si el ancho disponible es de 600 o más:** en el
  teléfono la página no cambia. Allí, con los archivos reales, las bahías no caben y la
  silueta se desplaza como antes; si un viaje trae tan pocas que caben, se reparten el ancho,
  pero el alto queda en 72.
- **Lo que no cambia:** la escala común de las pilas (la zona más cargada llena el alto de su
  zona, el que sea), el pie en el mismo eje de su pila, el mínimo de 56 por la escala de la
  letra, el desplazamiento con su barra cuando no caben (72 bahías, el teléfono, la letra a
  2.0 en una ventana angosta), tocar una bahía y las etiquetas accesibles.
- **El pie, en el mismo eje y nunca girado:** debajo de cada bahía, en columnas alineadas con
  su pila, el número (mono, 11, tinta tenue), **la cuenta** (12 / 500 tabular, tinta) y **el
  peso** («416.8 t», 11 tabular, tinta suave). Las tres van siempre, cualquiera que sea la
  magnitud del selector: nada se esconde detrás del selector.
- **«Contenedores / Peso»** (`BsSelectorDeModo` no: es un `SegmentedButton` de dos valores,
  `estadisticas-magnitud`, con el nombre «Qué dice la altura de la pila») cambia lo que
  dice el alto de la pila. Va con sus rótulos si caben enteros en el ancho que hay y, si no
  (`BsPrimeraQueCabe`), solo con los iconos y el nombre en la descripción emergente: en el
  teléfono, un segmento de media pantalla partía «Contenedores» a media palabra desde la letra
  a 1.1. Sin ningún peso en el archivo, «Peso» va deshabilitado: la pila no diría nada. Al lado, la leyenda de las dos zonas (una muestra y «Cubierta»,
  «Bodega») y la frase «Toca una bahía para abrirla en el plano». **La muestra es una pila
  pequeña** en el color de su zona: tres niveles de 10 × 5 con un separador de 1 en el color
  de la hoja, como las pilas de la silueta; mide 10 × 17, sin borde. Antes era un cuadro de
  12 con borde, y la de «Cubierta», blanca de noche, parecía una casilla para marcar (O1 de
  10.53). En el árbol accesible sigue siendo su rótulo, texto: ni botón ni casilla.
- **Tocar una bahía la abre en el plano** (`_openBayPlan`, como antes): cada bahía es un
  botón de la columna entera, con la etiqueta «Bahía 14, 36 contenedores, 712.4 t, 18 en
  cubierta y 18 en bodega» y la pista «Abre la bahía en el plano»; la descripción emergente
  («Abrir la bahía 14 en el plano») va fuera de la semántica (13.11, regla 3), para que
  Windows no la diga dos veces (10.44).
- **Se desplaza a lo ancho con su barra visible** (`Scrollbar` abajo, con el pulgar siempre
  a la vista cuando no cabe), sobre la hoja del panel. La rueda del mouse sobre la silueta es
  T-119 (entrega 3).
- La silueta entera es un contenedor accesible: «El buque en corte, 27 bahías de proa a popa;
  la altura de cada pila dice los contenedores en cubierta y en bodega».
- Sin bahías con posición no se dibuja: en su lugar, la frase «El archivo no trae posiciones
  de estiba».

### 15.5 Los cinco paneles

Todos son `BsPanel`: hoja, radio de panel (18) y borde en línea, con su título (`titleMedium`,
tipo oración, encabezado para el lector de pantalla) y 16 dp de aire.

| Panel | Qué lleva | Reglas |
|---|---|---|
| **Por puerto de descarga** | Una `BsBarraDeMagnitud` por puerto: **la caja del código** (`BsCajaDeCodigo`: el rol categórico, Plex Mono), la barra en `primary` sobre su pista, la cifra y «53 %» | Ordenados de más a menos; **pasados siete, «Otros N puertos»** con la suma (si sobra uno solo, se muestra él: 15.11, punto 9). Los contenedores sin puerto, «Sin puerto», sin caja. Tocar un puerto para ir a la Lista es T-120 (entrega 3) |
| **Llenos y vacíos** | **El anillo de llenos** (`BsAnilloAvance` de 112 con la letra a 1.0, grosor 12, en `primary`) con «63 %» en el centro y, al lado, «612 llenos», «365 vacíos» y, si los hay, «N sin estado» | Un medidor de una razón, no una dona de dos porciones. El anillo lleva la etiqueta «63 % llenos». Su diámetro crece con la letra para que «100 %» quepa en el hueco: con 2.0 mide lo que pide el texto más el grosor y el aire |
| **Por tamaño** | 20, 40 y 45 pies en los pasos 2, 3 y 4 de la rampa; «Otro» en el paso 1 si el tipo ISO no dice el largo | Van en orden; los rótulos dicen «20 pies», como la Lista |
| **Carga especial** | Tarjetas de su rol (`BsTarjetaDeRol`): «Peligrosa IMDG» (`peligrosa`), «Refrigerado» (`refrigerado`) y «Fuera de medida» (`oog`), con el icono del paquete (13.11), la cifra a 28 y el rótulo en el texto del rol | Solo las que tienen carga; sin ninguna, «Sin carga especial». Los mismos nombres que el plano y la Lista: ya no «IMO / DG» ni «OOG» |
| **Por naviera** | Barras en `primary`, el código en Plex Mono; **las ocho primeras y «Otras N navieras»** | Sin caja: las navieras no tienen rol de color. Los contenedores sin código, «Sin naviera» |

**La barra de magnitud** (`BsBarraDeMagnitud`): 12 dp de alto (nunca más de 24), el extremo
del dato redondeado (4) y la base cuadrada, sobre la pista; en una línea (el rótulo o la caja,
la barra, la cifra y el porcentaje) si la barra dispone de 400 dp por la escala de la letra o
más (un panel de 432, con sus 16 de aire a cada lado); si no, **la etiqueta va encima de su
barra**, con la cifra y el porcentaje a la derecha, y la barra a todo el ancho. Sin un ancho
acotado (una fila sin `Expanded`), la barra se da el de una línea. Cada barra lleva su descripción emergente con el mouse y su etiqueta
para el lector de pantalla («GTSTC: 520 contenedores, 53 %»), la misma frase.

### 15.6 «Ver como tabla»

El botón de la cabecera (`estadisticas-ver-tabla`, con el icono de tabla) cambia los
gráficos por **las mismas cifras en tablas**, un panel por sección: el resumen (con la fila
«Vacíos asignados» si los hay, 15.13), por bahía
(número de la bahía de referencia, contenedores, cubierta, bodega y peso, con la regla de la par
de 15.4: la fila «22» suma la 21 y la 23; una fila «Sin posición» si el archivo trae
contenedores sin estiba), por puerto (todos, no solo siete), llenos y vacíos, por tamaño,
carga especial y por naviera (todas). Las celdas de la cabecera son encabezados para el
lector de pantalla, las cifras van tabulares y alineadas a la derecha y el texto envuelve, pero
**ninguna palabra se parte:** cada columna de cifras mide lo que su texto más ancho pide y la
primera se queda con el resto; si ni con la primera al mínimo (120 dp por la escala de la
letra) cabe, la tabla se desplaza a lo ancho con su barra visible (las cinco columnas de «Por
bahía» a 360 dp con la letra a 2.0). Nada se corta. La cabecera con la protagonista se queda. El botón
pasa a decir «Ver como gráficos».

**La tabla no es una ruta, así que se cierra con Esc y con Atrás** (10.42, H2): mientras se
ve, se anota en `cerrablesDeAtrasProvider` (8); el primer Atrás de Android vuelve a los
gráficos y no cuenta como el primero del doble Atrás; Esc, con el foco dentro de la tabla,
hace lo mismo: la tabla pide el foco a propósito al abrirse (`FocusNode.requestFocus` tras el
cuadro), porque `autofocus` se descarta cuando el botón que la abrió, activado con el teclado,
ya tiene el foco. Al volver a los gráficos el foco no se devuelve al
botón a la fuerza (14.6).

### 15.7 Con cualquier tamaño de ventana

- **Ancho máximo de 1 440, centrado** (`BsMedidas.anchoMaximo`), sobre `BsFondoDePlano`: de
  noche la rejilla de plano al 5 % detrás y los paneles encima (la referencia de Maestro,
  0.9.2); de día, el papel. Es la primera pantalla que lleva el fondo.
- **Los paneles se reparten por el ancho del contenido:** con 1 100 dp o más
  (`anchoDeTresColumnas`), una fila en cuatro partes (por puerto a lo ancho de dos, llenos y
  vacíos en la tercera y carga especial en la cuarta) y debajo por naviera y por tamaño a la
  mitad cada uno; de 720 a 1 099 (`anchoDeDosColumnas`), dos columnas (por puerto junto a
  llenos y vacíos con por tamaño debajo; después carga especial junto a por naviera); con menos,
  **todo apila a todo el ancho**, en el orden por puerto, llenos y vacíos, por tamaño, carga
  especial y por naviera.
- **A 360 dp con la letra a 2.0:** la protagonista y «Ver como tabla» envuelven; las cifras
  van una por línea; la silueta se desplaza a lo ancho con su barra visible y sus bahías de
  112 dp; cada barra lleva su etiqueta encima; nada se corta ni se desborda. La matriz de
  pruebas lo comprueba a 360 × 800, 360 × 640 y 600 × 960 con la letra a 1.0, 1.45 y 2.0,
  y en la oficina a 1920 × 1000, 1707 × 996, 1536 × 793, 1366 × 690, 1280 × 720, 960 × 1000,
  800 × 600 y, además, a 600, 700, 800 y 960 dp de ancho (10.42), en los dos temas.
- **En la oficina, el panel lateral lleva solo «En vivo», o va oculto** (14.3): la
  cabecera de la oficina no muestra el selector de modo en Estadísticas (14.10, punto 8).
- El teléfono no cambia de barra: Estadísticas sigue siendo un destino de la barra inferior.

### 15.8 Las reglas de texto, aplicadas

Tipo oración en todo («Por puerto de descarga», «contenedores a bordo»); «53 %» con espacio
duro (`formatearPorcentaje`); «7 419.5 t» con `formatearToneladas`; Plex Mono para los
códigos de puerto y de naviera; `formatearCuenta` donde una palabra concuerda («1 contenedor»,
«Otros 3 puertos»). Nada por debajo de 11 en el teléfono (`labelSmall`); nada girado; ningún
«N/A» ni mayúsculas sostenidas («Sin puerto», «Sin naviera»).

### 15.9 Wireframes

**1920 × 1080 · la oficina de noche, el panel lateral oculto; contenido a 1 440, centrado**
```
┌─────┬──────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│[▣]  │ BUQUE MANUAL  (Publicado)   Viaje M100 · Escala GTSTC                            Buscar · Nube · Panel   │
│ ⌂   ├──────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│ ▦   │   977                                                                         [ ▦ Ver como tabla ]       │
│ ☰   │   contenedores a bordo                                                                                   │
│ ◔   │   7 419.5 t      27                 612           365                                                    │
│ ⫶   │   peso total     bahías con carga   llenos        vacíos                                                 │
│ ⚠   │ ┌ Carga por bahía, de proa a popa ─────────────────────────────────────────────────────────────────────┐ │
│     │ │        ▌▌   ▌▌▌  ▌▌▌▌  ▌▌▌▌  ▌▌▌▌  ▌▌▌   ▌▌    ▌▌    ▌▌▌  ▌▌▌▌  ▌▌▌▌  ▌▌▌   ▌▌        (cubierta)     │ │
│     │ │   ╭────▌▌───▌▌▌──▌▌▌▌──▌▌▌▌──▌▌▌▌──▌▌▌───▌▌────▌▌────▌▌▌──▌▌▌▌──▌▌▌▌──▌▌▌───▌▌────╮  (la tapa)       │ │
│     │ │   │    ▓▓   ▓▓▓  ▓▓▓▓  ▓▓▓▓  ▓▓▓▓  ▓▓▓   ▓▓    ▓▓    ▓▓▓  ▓▓▓▓  ▓▓▓▓  ▓▓▓   ▓▓        │  (bodega)    │ │
│     │ │   ╰─────────────────────────────────────────────────────────────────────────────────╯                │ │
│     │ │ Proa   02   06    10    14    18    22    26    30    34    38    42    46    50     Popa            │ │
│     │ │        63   58    61    44    52    49    38    41    29    21    33    40    18         (la cuenta) │ │
│     │ │     416.8 380.2 402.1 290.5 343.0 323.4 250.8 270.6 191.4 138.6 217.8 264.0 118.8 t     (el peso)    │ │
│     │ │ ══════════════════════════════════════════════════════════════════════════▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬    │ │
│     │ │ [ ■ Contenedores | Peso ]    ▌ Cubierta   ▓ Bodega        Toca una bahía para abrirla en el plano    │ │
│     │ └──────────────────────────────────────────────────────────────────────────────────────────────────────┘ │
│     │ ┌ Por puerto de descarga ────────────────────────────┐ ┌ Llenos y vacíos ───┐ ┌ Carga especial ──┐       │
│     │ │ [GTSTC] ████████████████████████████░░░  520  53 % │ │   ╭───╮            │ │ ◆  3  Peligrosa  │       │
│     │ │ [USHOU] ████████████░░░░░░░░░░░░░░░░░░░  245  25 % │ │  │63 %│  612 llenos│ │       IMDG       │       │
│     │ │ [PAMIT] ██████░░░░░░░░░░░░░░░░░░░░░░░░░  130  13 % │ │   ╰───╯  365 vacíos│ │ ❄ 12  Refrigerado│       │
│     │ │ [JMKIN] ██░░░░░░░░░░░░░░░░░░░░░░░░░░░░░   42   4 % │ │                    │ │ ⇔  1  Fuera de   │       │
│     │ │ Otros 3 puertos ██░░░░░░░░░░░░░░░░░░░░░   40   4 % │ │                    │ │       medida     │       │
│     │ └────────────────────────────────────────────────────┘ └────────────────────┘ └──────────────────┘       │
│     │ ┌ Por naviera ───────────────────────────────────────┐  ┌ Por tamaño ──────────────────────────────┐     │
│     │ │ LNA  ████████████████████░░░░░░░░░░░░░░  412  42 % │  │ 20 pies  ▒▒▒▒▒▒▒▒▒▒▒▒▒▒░░░░░░  410  42 % │     │
│ ☁   │ │ LNB  ███████████████░░░░░░░░░░░░░░░░░░░  301  31 % │  │ 40 pies  ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓░░░  487  50 % │     │
│ ⚙   │ │ Otras 4 navieras ████░░░░░░░░░░░░░░░░░░  264  27 % │  │ 45 pies  ███░░░░░░░░░░░░░░░░░░   80   8 %│     │
│     │ └────────────────────────────────────────────────────┘  └──────────────────────────────────────────┘     │
└─────┴──────────────────────────────────────────────────────────────────────────────────────────────────────────┘
```
`[GTSTC]` es la caja del código con la ficha del puerto (13.4); `█` la barra en `primary`;
`░` su pista; `▒ ▓ █` los pasos 2, 3 y 4 de la rampa; `▌` la pila de cubierta y `▓` la de
bodega. Las cifras son las de ejemplo de 9.5 y cuadran (977 = 612 + 365 = la suma de los
puertos = la suma de los tamaños).

**360 × 800 · el muelle de día, con la letra a 2.0**
```
┌──────────────────────────────────────┐
│ BUQUE MANUAL · M100     Buscar · Nube│
├──────────────────────────────────────┤
│ 977                                  │ la protagonista, a 96 dp
│ contenedores a bordo                 │
│ [ ▦ Ver como tabla ]                 │ envuelve debajo
│ 7 419.5 t                            │ las cifras, una por
│ peso total                           │ línea
│ 27                                   │
│ bahías con carga                     │
│ 612                                  │
│ llenos                               │
│ 365                                  │
│ vacíos                               │
│ ┌ Carga por bahía, de proa a popa ─┐ │
│ │      ▌▌    ▌▌▌    ▌▌▌▌    ▌▌▌▌   │ │ la silueta se
│ │ ╭────▌▌────▌▌▌────▌▌▌▌────▌▌▌▌── │ │ desplaza a lo ancho:
│ │ │    ▓▓    ▓▓▓    ▓▓▓▓    ▓▓▓▓   │ │ bahías de 112 dp
│ │ ╰────────────────────────────────│ │
│ │ Proa 02    06     10      14     │ │
│ │      63    58     61      44     │ │
│ │   416.8 380.2  402.1   290.5 t   │ │
│ │ ═══════════▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬│ │ con su barra visible
│ │ [ Contenedores | Peso ]          │ │
│ │ ▌ Cubierta  ▓ Bodega             │ │
│ │ Toca una bahía para abrirla en   │ │
│ │ el plano                         │ │
│ └──────────────────────────────────┘ │
│ ┌ Por puerto de descarga ──────────┐ │
│ │ [GTSTC]                520  53 % │ │ la caja arriba, la
│ │ ████████████████████████████░░░░ │ │ cifra a la derecha y
│ │ [USHOU]                245  25 % │ │ la barra a todo el
│ │ ███████████████░░░░░░░░░░░░░░░░░ │ │ ancho
│ │ [PAMIT]                130  13 % │ │
│ │ ████████░░░░░░░░░░░░░░░░░░░░░░░░ │ │
│ │ [JMKIN]                 42   4 % │ │
│ │ ███░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ │ │
│ │ Otros 3 puertos         40   4 % │ │
│ │ ██░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ │ │
│ └──────────────────────────────────┘ │
│ ┌ Llenos y vacíos ─────────────────┐ │ y así los demás
│ │   ╭───╮   612 llenos             │ │ paneles, apilados
│ │  │63 %│   365 vacíos             │ │
│ │   ╰───╯                          │ │
│ └──────────────────────────────────┘ │
├──────────────────────────────────────┤
│  Plano   Lista   Avance  Estad.  Más │
└──────────────────────────────────────┘
```

### 15.10 Las piezas nuevas y su API

En `lib/core/design/componentes/`, con documentación, vista previa y prueba, como las de 13.6
y 14.11. Son widgets y `CustomPainter`: ninguna dependencia nueva.

| Pieza | API | Qué hace |
|---|---|---|
| `BsBuqueEnCorte` | `BsBuqueEnCorte({bahias: List<BsBahiaEnCorte>, onSeleccion, magnitud = BsMagnitudDeLaPila.contenedores, controlador?})` con `BsBahiaEnCorte({numero, contenedoresCubierta = 0, contenedoresBodega = 0, pesoCubiertaKg = 0, pesoBodegaKg = 0})` y `enum BsMagnitudDeLaPila { contenedores, peso }` | 15.4: el casco, las dos pilas por bahía con separadores de nivel, el pie en tres filas, el botón por bahía con su etiqueta y la barra de desplazamiento. `anchoBahia(TextScaler, …)` dice el ancho de la columna |
| `BsBarraDeMagnitud` | `BsBarraDeMagnitud({rotulo, valor, total, maximo, color?, caja?, enMono = false, singular = 'contenedor', plural = 'contenedores'})` | 15.5: la barra de 12 dp con pista, la cifra y el porcentaje; en una línea o con la etiqueta encima; la etiqueta accesible y la descripción emergente, con la misma frase |
| `BsCajaDeCodigo` | `BsCajaDeCodigo({codigo, rol})` | La caja del código de puerto: el relleno, el código en Plex Mono y el contorno del rol categórico |
| `BsTarjetaDeRol` | `BsTarjetaDeRol({rol, icono, valor, rotulo})` | La tarjeta de carga especial: relleno y contorno del rol, el icono en el contorno, la cifra a 28 y el rótulo en el texto del rol. Etiqueta «Peligrosa IMDG: 3» |
| `BsPanel` | `BsPanel({titulo, child, accion?})` | El panel de Estadísticas: hoja, radio 18, borde en línea, el título como encabezado y, a la derecha, una acción opcional |

Y en la presentación: la página (`voyage_stats_view.dart`, `VoyageStatsView`, con la misma
firma de antes y, desde T-125, `vaciosAsignados` opcional) y las cifras derivadas del viaje
(`formatters/estadisticas_del_viaje.dart`, `EstadisticasDelViaje.de(voyage, asignados: …)`,
Dart puro: el total, lo del archivo y los vacíos asignados, los llenos, los vacíos y los sin
estado, el peso, las bahías con carga, cada bahía con sus dos zonas, los puertos, las
navieras, los tamaños y la carga especial, con los contenedores sin posición aparte). Los
providers de T-109 (`voyageStatsProvider` y los demás) no cambian. `vessel_profile_view.dart`
sale: su casco era otro buque (0.9.1) y lo sustituye la protagonista.

### 15.11 Lo que cambió respecto de la propuesta

1. **El peso por bahía va como cifra, no como columna dibujada** (0.9.5 lo mostraba como
   «▂▃▅»): la pila ya dice el peso al elegir «Peso», y una segunda columna debajo dibujaba el
   mismo dato dos veces. Las tres filas del pie (número, cuenta y peso) van siempre, con
   cualquier magnitud, para que el selector no esconda nada.
2. **Las pilas van en los colores del ícono, no en «un solo color»** (0.9.3 lo decía de las
   barras de una serie): cubierta y bodega son dos zonas de la misma bahía y se pintan como
   la vista Estado (13.2), que ya está verificada en los dos modos; la silueta del plano las
   pinta apagadas porque ahí la pila es un selector, y aquí es el dato. Por eso la leyenda de
   las dos zonas va junto al selector.
3. **La bahía mide 56 dp por la escala de la letra**, no 56 fijos: con la letra a 2.0 el peso
   («416.8 t») no cabía en 56, y la regla es que nada se corte. La silueta del plano no
   cambia (su pie es solo el número).
4. **«20 pies», «40 pies» y «45 pies»**, no «20'»: es como la Lista nombra el contenedor
   (13.11). «Otro» aparece solo si algún tipo ISO no dice el largo.
5. **«Sin estado», «Sin puerto», «Sin naviera», «Sin posición»**: las cifras cuadran por
   construcción (el total es la suma de los llenos, los vacíos y los sin estado; de los
   puertos; de los tamaños; de las bahías más los sin posición) y la tabla las muestra.
   Antes, «N/A» y «SIN NAVIERA».
6. **La carga especial muestra solo las tarjetas con carga** y dice «Sin carga especial» si
   no hay ninguna: una tarjeta de rol con un cero es color sin dato.
7. **«Ver como tabla» es un estado de la página, no una ruta,** anotado en
   `cerrablesDeAtrasProvider` para Esc y Atrás (15.6): una ruta encima taparía el riel y el
   panel de la oficina.
8. **La fila de cifras va a 28, no en tarjetas:** junto a la protagonista a 48, una tarjeta
   por cifra competía con ella; las cifras con su rótulo debajo (ShipX) son más calladas.
9. **«Otros N puertos» solo cuando sobran dos o más** (`EstadisticasDelViaje.conElResto`): con
   ocho puertos se muestran los ocho, porque «Otros 1 puertos» no se escribe y «Otro puerto»
   escondería un código que cabe. Lo mismo con «Otras N navieras» pasadas las ocho.
10. **En la variante apilada de la barra, la cifra y el porcentaje van a la derecha de la caja,
    en su misma línea** (el wireframe de 360 de 0.9.5 los ponía debajo): ahorra una línea por
    barra con la letra a 2.0 y la cifra queda alineada con las demás.
11. **La silueta va en un panel con título** («Carga por bahía, de proa a popa»), como los demás
    paneles, y con la leyenda de las dos zonas junto al selector: el color nunca va solo.
12. **La tabla se desplaza a lo ancho cuando no cabe** y el selector va solo con iconos cuando
    sus rótulos no caben (15.4 y 15.6): lo encontró la revisión sin compilar, que calculó los
    anchos con la letra a 2.0 en 360 dp; antes el texto se partía a media palabra.
13. **El anillo de llenos crece con la letra** (15.5): fijo en 112 dp, «53 %» a 2.0 se montaba
    sobre el arco.
14. **Las bahías siguen la regla de la par** (T-124, 10.65; 15.4): la propuesta dibujaba cada
    número de bahía, y con un plano de llegada la mitad de las columnas eran mitades de 20 en
    cero. Ahora cuenta como el avance; «Bahías con carga» cuenta bahías de referencia.
15. **En un plan de carga, Estadísticas cuenta lo que va a bordo como la Lista** (T-125, 10.68;
    15.13): la propuesta leía solo el archivo, y un vacío asignado a una celda reservada, que el
    archivo trae sin número, no salía en ninguna cifra aunque la Lista lo trajera.

### 15.12 Las pruebas (`test/t121_estadisticas_test.dart`)

El contraste compuesto de todo lo que se pinta, en los dos temas (la rampa y su pista, las
pilas sobre la hoja y el casco, las cajas de los quince puertos fijos, las tarjetas de rol,
el texto); `meetsGuideline` (contraste del texto, objetivos táctiles y etiquetas) en los dos
temas, y además, porque la pauta de contraste no mide los textos con etiqueta compuesta, que
**todo texto con color propio lleva una tinta o el texto de su rol**; la página a 360 dp con
la letra a 2.0 sin desbordes, sin textos cortados y **sin palabras partidas** (un texto sin
espacio normal, un código o una cifra, en más de una línea), con la silueta desplazable y su
barra siempre a la vista; la matriz de tamaños y letras de 15.7; el censo sin `Colors.*`; la
tabla con los mismos números que los gráficos; el sintético de 977 contenedores en 72 bahías,
que con la regla de la par son 24 (la silueta mide 24 y se recorre entera sin cortarse); las cifras que cuadran entre sí
sobre el sintético y sobre el plano de dos bahías de T-117; «Otros N puertos» y «Otras N
navieras»; Esc y Atrás cierran la tabla, también abierta con el teclado (Tab e Intro); y tocar
una bahía la abre en el plano, como la prueba de T-109 que sustituye.

La corrección 1 de la entrega 2 añade `test/t121_entrega2_c1_test.dart`: con nueve bahías
de referencia (desde T-124, nueve pares sueltas: las del plano de llegada son tres), a 1920 en los dos temas y en Contenedores y en Peso, a 1366 y con la
letra a 2.0, la silueta ocupa el ancho útil del panel, sin nada que desplazar; con tres bahías,
cada una en su tope y el casco centrado; el alto que crece 1.5 veces en pantalla ancha y no en
el teléfono; con 72 bahías de referencia, 56 de ancho, el desplazamiento y la popa al
alcance; la regla de `repartir`; y la muestra de la leyenda, una pila de tres niveles sin borde, más alta que ancha,
que en el árbol accesible no es botón ni casilla.

T-124 añade `test/t124_par_test.dart`: la forma del plano de llegada da tres bahías (02, 06 y
10) con las tres de cada grupo sumadas, a 1920 en su tope y con el casco centrado, sin las
impares en la silueta ni en la tabla, y tocar la 02 la abre; el 977 da 24; las impares vacías
de T-117 van con su par; una impar sin par vecina queda sola.

T-125 añade `test/t125_320_test.dart` (grupo 1): en la página de la oficina, con la operación
en una bitácora en memoria, asignar el vacío OR 12 a la reserva 003‑08‑82 sube la protagonista
de 2 a 3, la bahía, el puerto, la naviera y «vacíos», y saca la ficha; deshacerlo con
«Marcado por error» devuelve las cifras del archivo, también el peso (su tara, 2 185 kg), y
quita la ficha. La ficha se lee entera en los dos temas, a 360 con la letra a 2.0 y a 1920, y
la tabla trae su fila; sin vacíos asignados no hay ni ficha ni fila. Las pruebas de «las cifras
cuadran» de `t121_estadisticas_test.dart` distinguen lo del archivo (`delArchivo`) de lo
asignado (`vaciosAsignados`), con un caso de dos vacíos asignados sobre el plano de T-117.

### 15.13 Los vacíos asignados (T-125, 10.68)

En un plan de carga con operación, **Estadísticas cuenta lo que va a bordo como la Lista y las
búsquedas** (`aboardContainersProvider`, H6 de 10.56): lo que trae el archivo y los vacíos que el
muelle asignó a una celda reservada (`LoadingOperation.assignedEmpties`), que el archivo trae
sin número. La página los recibe de `assignedEmptiesProvider`, el mismo del que lee la Lista.

- **Cada vacío asignado suma un contenedor:** a la protagonista, a «vacíos» y al anillo de
  llenos, a su tamaño (el tipo de su fila del listado o, sin ella, el de la reserva), a su
  puerto, a su naviera y a su bahía de referencia (15.4), en su zona y con su tara como peso.
- **La ficha** (`BsFichaDeCifra`, clave `estadisticas-vacios-asignados`) va debajo de la
  protagonista, antes de la fila de cifras, y dice cuántos vacíos asignados incluyen las cifras:

| Vacíos asignados | La ficha |
|---|---|
| Ninguno | No sale. La página es la de antes |
| 1 | «Incluye: 1 vacío asignado a una celda reservada, que el archivo no trae» |
| 2 o más | «Incluye: 2 vacíos asignados a celdas reservadas, que el archivo no trae» |

  «Incluye» es el rótulo, en tinta suave, y el resto el dato, en tinta (14.7). Sin rol: no es un
  aviso ni algo que revisar, sino de dónde sale la cifra. Es de la cabecera, así que se queda con
  «Ver como tabla».
- **«Ver como tabla»:** el resumen lleva la fila «Vacíos asignados», con la cuenta, debajo de
  «Contenedores a bordo»; solo si hay alguno.
- **Las cifras se mueven mientras dura la operación:** al asignar un vacío suben y al deshacer la
  asignación bajan, como en la Lista. Carlos lo decidió sabiéndolo (10.66, punto 5, y 10.68).
- **Lo que no cambia:** las alertas de estiba (evalúan el viaje leído: sumar solo los vacíos
  mezclaría lo planificado con lo hecho) y la comparación de viajes (el BAPLIE de salida ya
  escribe los vacíos asignados). Un plano de llegada, o un plan de carga sin vacíos asignados,
  queda como antes.
- **Las cifras siguen cuadrando por construcción** (15.11, punto 5): `delArchivo` dice lo que trae
  el archivo, `vaciosAsignados` lo asignado, y `total` es su suma.

## 16. El mouse y el touchpad (T-119)

Decisiones 10.36, 10.38 (P4 y P7) y 10.76 de `SPRINT-4.md`. El diagnóstico y el diseño están en
`docs/T117-T121-RESULTADOS.md` (0.7 y la tabla de 0.5.3); esta sección manda donde dicen cosas
distintas, y 16.6 dice qué cambió. En Windows y en la Web. **El teléfono y la tableta conservan el
pellizco de dos dedos sobre la pantalla**, que no cambia.

| Dónde está el puntero | Rueda | Mayús + rueda | Ctrl + rueda o pellizco | Touchpad, dos dedos |
|---|---|---|---|---|
| Silueta | Avanza o regresa la silueta; en un extremo, la columna | La silueta, como antes | Como antes (16.6, punto 2) | Horizontal: la silueta; vertical: la columna |
| Rejilla | La columna | La rejilla en horizontal | El zoom, con el punto bajo el puntero quieto | Desplazar: la columna y la rejilla; pellizco: el zoom |
| La barra de abajo | La rejilla en horizontal | — | — | — |
| Lo demás de la columna | La columna | — | Como antes | La columna |

### 16.1 La rueda en la silueta, `BsRuedaHorizontal`

- `BsRuedaHorizontal({ScrollController? controlador, required constructor})`, en
  `lib/core/design/componentes/bs_rueda_horizontal.dart`, va **alrededor** del desplazable horizontal
  de `BsSiluetaBuque`, que arma `constructor(context, controlador)` con el controlador de la
  pantalla o, si no hay, con uno propio. Dentro no sirve: mientras el desplazable anima, su
  contenido no recibe el puntero, y el segundo paso de la rueda se iba a la columna.
- Con la rueda vertical se registra en `GestureBinding.instance.pointerSignalResolver`, donde gana el
  primero que se registra: está más adentro que la columna, así que la columna no se mueve a la vez.
  Hacia abajo avanza hacia la popa y hacia arriba regresa hacia la proa, con
  **`BsMovimiento.rueda` (100 ms, nuevo)** y `BsMovimiento.entrada`; cero si el sistema reduce el
  movimiento. Cada paso suma al destino del anterior, aunque la animación no haya llegado.
- **En un extremo,** si la silueta no puede moverse en ese sentido, no se registra y la rueda pasa
  a la columna.
- **No toma lo que ya tiene dueño:** la rueda con más componente horizontal que vertical (el
  touchpad en la Web) es del desplazable; Mayús + rueda también, porque invierte los ejes del
  mouse; y Ctrl + rueda no es de la silueta.
- **El pestillo,** `BsPestilloDeLaRueda`, envuelve la columna de la oficina: anota la hora de cada
  paso de la rueda vertical que llega a la columna sin que nadie de dentro lo tome (Ctrl + rueda no
  cuenta). Si el último fue hace menos de **300 ms** (`BsPestilloDeLaRueda.plazo`), la silueta no
  toma la rueda y la columna sigue: al bajar, la silueta llega bajo el mouse y no se la roba. Lo que
  toma la silueta no alarga el pestillo. Usa la hora del evento, no la del reloj.

### 16.2 El zoom con el touchpad y con Ctrl + rueda

En `PlanZoomViewport`, además de los dos contactos de la pantalla:

- **El pellizco del touchpad** (`PointerPanZoomStart`, `Update` y `End`; en Windows, el touchpad de
  precisión): la escala del inicio por `event.scale`, en cuanto se aparta más de un 1 % de 1.0
  (`PlanZoomViewport.umbralDelPellizco`); antes, los dos dedos solo desplazan. **Mientras dura el
  pellizco no se desplaza nada:** la rejilla, como con dos dedos en la pantalla, y la columna, que
  lee `pellizcoDelPlanoProvider` y queda con `NeverScrollableScrollPhysics` hasta que el gesto
  termina.
- **Ctrl + rueda, también con el mouse** (P4): la escala por e^(−dy/200)
  (`PlanZoomViewport.pasoDeLaRueda`), registrado en el resolvedor para que la columna no se mueva.
  Se registra aunque la escala ya esté en su tope: Ctrl + rueda sobre la rejilla nunca desplaza.
- **El pellizco de la Web:** el motor web de Flutter 3.38 entrega el pellizco y Ctrl + rueda como
  `PointerScaleEvent` con escala e^(−dy/200) (`pointer_binding.dart`); se multiplica por su escala.
- La escala sigue acotada entre **75 y 300 %** por `planZoomProvider`, y el chip del zoom no cambia.
- En el teléfono (el lienzo sin `alturaNatural`) también amplían Ctrl + rueda y el touchpad, desde
  la esquina, como el chip: ahí no hay punto fijo ni barra.

### 16.3 El punto bajo el puntero se queda quieto

En la oficina, al ampliar con el touchpad o con Ctrl + rueda, se corren los dos desplazamientos
para que lo que está bajo el puntero quede donde estaba:

- **En vertical** (la columna): nuevo = actual + (foco − 16) × (escala nueva ÷ escala vieja − 1),
  con el foco medido desde el borde de arriba de la rejilla y los 16 dp de su aire
  (`PlanZoomViewport.margen`), que no se amplían. Lo de arriba de la rejilla no cambia de alto.
- **En horizontal** (la rejilla): si la bahía no llena la vista, va centrada, y su ancho natural lo
  mide `PlanZoomContenido`. Con *inicio(e)* = 16 + máx(0, (vista − 32 − ancho × e) ÷ 2), el punto
  bajo el foco es (actual + foco − inicio(vieja)) ÷ vieja, y el desplazamiento nuevo, inicio(nueva) +
  punto × nueva − foco, acotado a lo que se puede desplazar.
- Los dos se mueven **antes** del cuadro que dibuja la escala nueva, así que se ven juntos. Si una
  cuenta pasa del borde nuevo, la física lo acota al medirse.
- Cuando la bahía vuelve a caber, la centra el ancho mínimo y el punto ya no puede quedarse:
  la bahía entera está a la vista.
- Con el chip, el zoom sigue ampliando desde la esquina de arriba a la izquierda.

### 16.4 La barra horizontal de la rejilla, `BarraDeLaRejilla`

- **El desplazamiento horizontal va por fuera de la escala:** en la oficina, `PlanZoomViewport` lleva
  un `SingleChildScrollView` horizontal (`rejilla-horizontal`) con la rejilla ampliada dentro
  (`_TamanoAmpliado`, que mide lo que el hijo por la escala en los dos ejes); la rejilla ya no lleva
  el suyo. Así la barra no se amplía con la rejilla.
- `BarraDeLaRejilla` (`barra_de_la_rejilla.dart`, clave `barra-de-la-rejilla`) envuelve la columna:
  es la `Scrollbar` de Material con el controlador de la rejilla, que la rejilla toma con
  `BarraDeLaRejilla.controladorDe`, `scrollbarOrientation: bottom` y un `notificationPredicate` que
  solo escucha ese controlador (la silueta y la columna llevan los suyos).
- **Va pegada al borde de abajo de la columna, encima de la franja de cifras,** aunque el pie de la
  rejilla esté más abajo, como en una hoja de cálculo.
- **Solo aparece cuando la bahía no cabe a lo ancho.** Entonces se ve siempre, con su pista
  (`thumbVisibility` y `trackVisibility`), y la columna deja **14 dp de aire** abajo
  (`BarraDeLaRejilla.aire`: los 12 de la barra de escritorio con pista y sus 2 de margen): la barra
  vive en ese aire y nunca tapa celdas. Sin barra, sin aire.
- **El pulgar se arrastra** con el mouse y **un clic en la pista avanza una página**: el 80 % de la
  vista, lo que hace cualquier barra de Flutter. La rueda sobre la barra mueve la rejilla.
- En la tableta del muelle, la columna es la misma: la barra sale igual cuando la bahía no cabe.

### 16.5 La Web y la página entera

- **La prueba de P7 la hace Carlos** con su touchpad, en Chrome y en Edge: si el pellizco o
  Ctrl + rueda amplían la página entera sobre el plano. Lo que dice el código del motor (no es una
  medida): con Ctrl, la rueda llega a Flutter como `PointerScaleEvent`, y el motor cancela el
  evento del navegador (`preventDefault`) en todo lo que dibuja Flutter. Si la prueba lo confirma,
  `web/index.html` no se toca.
- Si la página se amplía, P7 autoriza en `web/index.html` un escucha no pasivo que cancele
  Ctrl + rueda **solo con el puntero sobre el plano**. Ctrl + «+» y Ctrl + «−» nunca se tocan.
- **O-040-1,** el gesto del touchpad que regresa el navegador al deslizar sobre la silueta, queda
  para después (10.76).

### 16.6 Lo que cambió respecto de la propuesta (0.7.2)

1. **La rueda va alrededor del desplazable, como decía la propuesta, y le da el controlador:**
   `BsSiluetaBuque` no siempre recibe uno, así que `BsRuedaHorizontal` pone el suyo. Una primera
   versión iba dentro, sin controlador, y la prueba de dos pasos seguidos la tumbó: durante la
   animación el contenido ignora el puntero.
2. **Mayús + rueda sigue siendo del desplazable,** y Ctrl + rueda fuera de la rejilla hace lo de
   antes (en Windows desplaza la columna; en la Web no hace nada, porque llega como escala): la
   silueta solo toma la rueda vertical sin modificadores. La propuesta decía «nada».
3. **El punto fijo cuenta el centrado y mira el lienzo de ahora:** la propuesta daba nuevo = (actual + foco) × razón − foco,
   que solo vale si la rejilla llena la vista y no tiene aire. Con el aire de 16 dp y una bahía que
   cabe centrada, `PlanZoomContenido` mide su ancho natural (16.3). Y el foco se calcula desde la
   posición en la pantalla en cada evento, no con `localPosition`: el gesto del touchpad guarda
   la posición del lienzo al empezar, y el lienzo sube o baja con la columna mientras se pellizca.
4. **La columna se congela durante el pellizco** con un proveedor (`pellizcoDelPlanoProvider`): la
   columna está fuera de `PlanZoomViewport`, y la `ScrollConfiguration` de dentro no la alcanza.
5. **Ctrl + rueda se registra también en el tope:** si no, al llegar a 300 % la rueda con Ctrl
   desplazaba la columna.
6. **La barra de Material sirvió fuera de su desplazable**, como pedía la propuesta probarlo: no hizo
   falta una propia.
