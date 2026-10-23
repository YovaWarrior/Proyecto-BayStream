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
la 13. La evidencia de contraste está en `docs/rediseno/fase2bis/contraste.md`, generada
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
condensada de 12). El zoom amplía la rejilla dentro de su lienzo; el chip «100 %» vive
en la esquina inferior derecha, nunca sobre el título.

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

### 13.6 Las piezas nuevas y su API

Todas en `lib/core/design/componentes/`, con documentación, vista previa, prueba de
contraste compuesto y las tres pautas de accesibilidad. Solo se animan `Transform` y
`opacity`; cada `CustomPainter` va dentro de un `RepaintBoundary`; con
`disableAnimations` nada se mueve. Las celdas siguen siendo widgets (toque, foco y
etiqueta); la silueta, el casco, la marca y el anillo se pintan con `CustomPainter`.

| Pieza | API | Qué hace |
|---|---|---|
| `BsMarca` | `BsMarca({tamano = 40, variante = conRecuadro \| sinRecuadro \| monocroma, color?, espera = false, etiqueta = 'BayStream'})` | El ícono pintado desde la geometría de `design/icono/baystream.svg` (módulo de 13.8 en un lienzo de 100; recuadro de 126.6 con esquinas de 27). `monocroma` tiñe todo con `color` (por omisión `onSurface`) y el contenedor se reconoce por estar fuera de la cuadrícula. `espera: true` es la espera de la app: el contenedor naranja sube y baja medio módulo (6.9 unidades) en un bucle de 1.2 s con `easeInOut`, solo `Transform`; quieto si se reduce el movimiento. Etiqueta accesible; con `espera`, «BayStream, leyendo» |
| `BsSiluetaBuque` | `BsSiluetaBuque({bahias: List<BsBahiaDeSilueta>, onSeleccion, seleccionada?, recienMovida?, controlador?, rotuloDeAvance?})` con `BsBahiaDeSilueta({numero, nivelesCubierta = 0, nivelesBodega = 0, avance?, conTrabajo = false})` | Evoluciona `BsTiraDeBahias`: el casco con la proa a la izquierda y la línea de flotación, sin superestructura; cada bahía es una pila (los niveles ocupados de cubierta encima de la línea de la tapa y los de bodega debajo); las bahías con trabajo en esta escala van más claras y las demás apagadas; la seleccionada en cubierta `#F5F8FC` y acero `#6E9DE6` con su marco en marca; bajo cada número, la barra de avance (hecho si llegó a 1, marca si va, línea si no empezó); el destello de la bahía recién movida (13.3). Cada bahía es un botón de **56 dp de ancho** (`anchoBahia`) con etiqueta («Bahía 14, 4 niveles en cubierta y 4 en bodega, avance 25 %, seleccionada»); **el alto no es un parámetro: sale de los niveles que se pintan (hasta 6 por zona, a 9 dp) y de la escala de letra del número y la barra** (10.17, O1) |
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
| Las pantallas vacías | Un dibujo de línea del muelle en acero y una frase que dice qué hacer; el dibujo llega en el paquete de íconos (10.14). Mientras, el estado vacío de hoy con el texto nuevo |  |
| La celda que se mueve | `BsCelda(estado: recienMovido)`: el contenedor fuera de su celda, como en el ícono |  |
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
  Los íconos del dominio y las ilustraciones (la grúa del inicio, el muelle de las pantallas
  vacías) llegan en un paquete aparte (10.14) y los integra una entrega propia; mientras
  tanto, Material Symbols, y no se hacen provisionales que luego se tiren.
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
