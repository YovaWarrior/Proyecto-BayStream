# DESIGN.md · El sistema de diseño de BayStream

Fase 1 del rediseño (T-114, Sprint 4). Timonel, 21-oct-2026. **Borrador para que Carlos
elija**: dos direcciones completas, lo que las dos comparten, el flujo nuevo de la
primera visualización con las capas que toca, la navegación adaptable y los wireframes
de las cinco pantallas clave. Cuando Carlos elija, este archivo se reduce a la dirección
elegida y pasa a mandar sobre el código de `lib/features/vessel/presentation/`,
`lib/core/app.dart` y `lib/core/design/`: ninguna decisión estética entra al código sin
estar escrita aquí.

La evidencia de contraste está en `docs/rediseno/fase1/contraste.md`, generada con
`tool/rediseno_contraste.py` (todas las parejas de texto cumplen AA 4.5:1 y los bordes
esenciales 3:1, en claro y en oscuro). Material 3 sigue siendo la base: las dos
direcciones son tokens, un `ColorScheme` ajustado, una `ThemeExtension` semántica y
componentes propios, no otra biblioteca.

---

## 1. Para quién se diseña y qué tiene que sentirse

| | El muelle | La oficina |
|---|---|---|
| Quién | El supervisor de operaciones en Puerto Santo Tomás de Castilla | El agente naviero u operaciones |
| Dónde | Honor a 360 dp, al sol, a veces con guantes, siempre con prisa | Laptop de 14 a 17" a 1920×1080, Windows 11 (y la Web) |
| Qué hace | Marca cada contenedor que baja, carga llenos y vacíos por número de orden, pide cambios | Sigue el avance en tiempo real, aprueba cambios, genera el BAPLIE de salida |
| Lo que ya sabe | El plano impreso de memoria: bahías de proa a popa, filas desde el centro (impares a estribor, pares a babor), niveles 02… en bodega y 82… en cubierta, colores por puerto, el 40 que ocupa dos bahías | Lo mismo, más el listado de la agencia y el BAPLIE |
| Necesita | Objetivos grandes, una acción por pantalla, confirmación inmediata, luz | Densidad, pocos clics, todo a la vista, el estado de la nube |

**Cómo tiene que sentirse:** el plano de papel, pero vivo. Serio sin ser frío, denso
donde la oficina lo necesita y despejado donde el muelle lo necesita, sin adorno. Que
alguien que ha leído planos toda la vida reconozca el suyo en la pantalla, y que la
única cosa que se mueve sea la que acaba de cambiar.

## 2. El mundo del producto (de dónde salen las decisiones)

- **El dominio:** bahía, fila, nivel; cubierta y bodega; la tapa de escotilla; la celda y
  la sombra del 40; el puerto de destino; lleno y vacío; el número de orden del listado;
  el VGM; la re‑estiba; las peligrosas (IMDG) y los refrigerados; la grúa pórtico que
  mueve una caja a la vez.
- **El mundo de color:** el azul del casco y del agua; el blanco papel del plano impreso;
  el naranja de los chalecos y de las grúas; el gris del hormigón del muelle y del acero
  de los contenedores; los lápices de colores con que el planificador pinta los destinos;
  el amarillo de las líneas de seguridad.
- **La firma de BayStream:** la rejilla de una bahía con la línea de la tapa de escotilla
  entre cubierta y bodega, y el contenedor «fuera de celda» del ícono (el naranja) como
  la marca de lo que está en movimiento. Las dos direcciones la usan; cada una la dibuja
  distinto.
- **Los defaults que se rechazan:** (1) `fromSeed` y tarjetas iguales en todas partes, por
  tokens y superficies por zona; (2) el arcoíris de Estadísticas, por una escala
  monocromática de marca y un color categórico solo donde identifica algo; (3) las
  pestañas superiores y una barra con ocho acciones, por una barra inferior o un riel
  con cinco destinos y acciones según la pantalla; (4) la «consola oscura» por defecto,
  porque al sol lee mejor el papel claro: el oscuro existe, pero no manda.

## 3. Lo que ya está decidido (10.2 de `SPRINT-4.md`) y las dos direcciones cumplen

1. **Ver primero, confirmar después:** abrir la app, «Seleccionar archivo» y elegirlo son
   los tres pasos; el plano abre con el perfil propuesto y un aviso visible con la
   escala propuesta; para operar se confirman la escala y el límite; «No lo tengo» no
   se marca por omisión; el peso por pila sale «sin evaluar» mientras tanto (sección 8).
2. **«Colorear por»** con tres vistas (destino, tipo de vacío, estado de la operación),
   cada una con su leyenda; el mismo puerto o tipo tiene el mismo color en todos los
   clientes y viajes; la celda lleva además el código (sección 6).
3. Al confirmar se abre «Plano»; los viajes recientes van en el inicio; la matriz de
   segregación se alcanza desde «Alertas de estiba».
4. **Una fuente empaquetada** como asset, con licencia OFL o equivalente, cifras
   tabulares y cobertura de `· ‑ … × •`; `▲ ▼ → ↔` pasan a iconos (sección 7).
5. **Una sola hoja de detalle** del contenedor y **una sola unidad de peso** en
   pantalla: «28.7 t», con los kilos exactos del VGM en el detalle.
6. El conductor de T-99 y los instrumentos de T-98 se actualizan antes de medir.

---

## 4. Dirección A · «Plano de a bordo»

**La idea.** La pantalla es la hoja del plano: papel claro, tinta azul marino, contornos
finos y una sola tinta de acento, el naranja de la grúa, reservada a lo que se está
moviendo o espera una decisión. La densidad es la de un documento técnico bien
compuesto: mucho dato, poco ruido. La firma: la tira de bahías es la silueta del buque
(el perfil longitudinal que hoy vive en Estadísticas, convertido en selector) y la
leyenda es una **cartela**, como el cajetín de un plano.

### 4.1 Paleta

Seis colores con nombre. Lo que cambia entre claro y oscuro es la luminosidad; el tono
es el mismo. Todos los pares están verificados en `contraste.md`.

| Nombre | Rol | Claro | Oscuro | De dónde sale |
|---|---|---|---|---|
| Papel | Fondo de la app (`surface`) | `#F5F8FC` | `#0B1626` | Las celdas de cubierta del ícono (`#F5F8FC`) |
| Hoja | Superficies que se apoyan en el papel: tarjetas, hojas, paneles (`surfaceContainerLowest` / `surfaceContainer`) | `#FFFFFF` | `#13223A` | El papel blanco del plano impreso |
| Tinta | Texto, iconos, bordes fuertes (`onSurface`) | `#10243F` | `#E6EEF8` | Tinta azul marino sobre papel |
| Marca | Acción principal, selección, pestaña activa (`primary`) | `#0D47A1` | `#8FB4F2` | La semilla del ícono |
| Acero | Bodega, superficies de la zona inferior, segundo plano (`secondary`) | `#6E9DE6` | `#6E9DE6` | La bodega del ícono |
| Grúa | Lo que se mueve o espera decisión: celda en movimiento, aviso de «sin confirmar», conflicto en curso (`tertiary`) | texto `#C2410C`, relleno `#FF7A1A` | texto `#FF9A4D`, relleno `#FF7A1A` | El contenedor en movimiento del ícono |

Derivados: tinta suave `#4A5B73` / `#A9B8CC` (texto secundario, 6.5:1 y 9:1); línea
`#C9D3E0` / `#2E4260` (separadores, sin exigencia de contraste); línea fuerte `#7A8DA6` /
`#5C7392` (bordes esenciales de celda, 3.2:1 y 3.7:1); marca tenue `#DCE7F8` /
`#1E3A66`; acero tenue `#E3EDFB` / `#1C2F4D`. Regla fija: **sobre el relleno naranja y
sobre el acero el texto es siempre tinta oscura** (`#10243F` claro, `#0B1626` oscuro),
porque el texto claro no llega a 4.5:1 en ninguno de los dos.

Distribución: unos 60 % papel, 30 % hoja y tenues, 10 % marca y grúa. La grúa aparece a
lo sumo en un elemento por pantalla.

### 4.2 Tipografía

**IBM Plex Sans** para la interfaz y **IBM Plex Mono** para números de contenedor y
posiciones. Licencia SIL Open Font License 1.1 (IBM). Se empaquetan como assets, con
su `LICENSE` y un `provenance.json` como el de `web/fonts/` (URL de origen, SHA-256 del
archivo servido). Por qué Plex: es una grotesca humanista de documento técnico, con
cifras tabulares (`tnum`), pesos 400/500/600 suficientes y una mono de la misma familia
para que «MSCU 123456 7» se lea como un dato y no como un título. Archivos propuestos:
Sans Regular, Medium y SemiBold; Mono Regular y Medium (cinco TTF; el peso en bytes se
mide al empaquetar).

Escala: base 14, razón 1.2, redondeada a enteros.

| Rol | Tamaño / peso / interlínea | Dónde |
|---|---|---|
| Cifra grande | 34 / 600 / 1.1, tabular | KPI de avance, totales |
| Titular | 28 / 600 / 1.2 | Nombre del buque en el inicio |
| Título de pantalla | 22 / 600 / 1.25 | Barra superior, cabecera de bahía |
| Título de bloque | 16 / 600 / 1.3 | Secciones, cartela |
| Cuerpo | 14 / 400 / 1.5 | Texto corriente, listas |
| Cuerpo secundario | 12 / 400 / 1.4, tinta suave | Metadatos, ayudas |
| Rótulo | 12 / 500 / 1.2 | Chips, pestañas, leyenda |
| Dato mono | 14 / 400 Mono, tabular | Número de contenedor, posición en listas y detalle |
| Celda | 11 / 600, tabular | Código en la celda del plano (`FittedBox` solo reduce) |
| Celda, línea 2 | 10 / 500, tabular | Peso o tipo en la celda, solo en oficina y con zoom ≥ 100 % |

Nada por debajo de 10; en el muelle, nada por debajo de 11. Los pesos, las cifras y los
porcentajes van siempre con `FontFeature.tabularFigures()`.

### 4.3 Tokens

| Grupo | Valores |
|---|---|
| Espacio (base 4) | 4 · 8 · 12 · 16 · 24 · 32 · 40. Densidad: oficina 12 dentro de bloques y 24 entre bloques; muelle 16 y 24 |
| Radios | celda 2 · control 6 · hoja y tarjeta 10 · diálogo 16 (el radio interior es el exterior menos el relleno) |
| Elevación | **Solo contornos** en claro: línea 1 dp para separar, línea fuerte 1 dp en celdas; sin sombras. En oscuro, desplazamiento de superficie (papel → hoja → hoja alta `#1B2D4A`) y la misma línea. Hojas modales: 1 dp de línea y papel atenuado al 32 % detrás |
| Alturas de control | Oficina: botón 40, campo 48, fila de lista 56, chip 32 con zona táctil 48. Muelle: botón principal 56, botón 48, campo 56, fila 64, chip 40 con zona táctil 48 |
| Celda del plano | Muelle 56 × 44, hueco 4; oficina 52 × 44, hueco 4; etiqueta de nivel 40; columna de pesos 72 |
| Estructura | Barra superior 56 · barra de navegación 80 · riel 80 (ancho) · panel lateral 360 · ancho máximo del contenido 1440, centrado |
| Objetivos táctiles | 48 × 48 mínimo en todo lo que se toca; en el muelle, 56 para la acción principal |

Componentes propios de la Fase 2 (todos con vista previa, doc y prueba): `BsCelda`
(la celda del plano con sus estados), `BsTiraDeBahias` (silueta del buque como
selector), `BsCartela` (leyenda y cifras de la bahía), `BsBanda` (aviso de «sin
confirmar» y otros avisos con icono y acción), `BsCifra` (KPI con rótulo),
`BsHojaDeDetalle` (la única hoja de detalle), `BsBarraDeOperacion` (muelle),
`BsNumeroDeContenedor` (formato «MSCU 123456 7»).

### 4.4 Movimiento

Poco y con sentido. Microacciones 150 ms, hojas y diálogos 220 ms (opacidad y 8 dp de
desplazamiento con `Transform`), cambio de bahía 120 ms de fundido en la oficina y
**sin animación en el muelle** (se repite cien veces por turno). Un solo momento
orquestado: cuando un plano abre, la rejilla «asienta» una vez (opacidad 0 → 1 y escala
0.98 → 1 en 250 ms). Curvas `easeOutCubic` al entrar, `easeInOutCubic` al moverse. Si
`MediaQuery.disableAnimationsOf(context)` es verdadero, todas las duraciones son cero.
Solo se animan `Transform` y `opacity`; nunca anchos, altos ni márgenes.

### 4.5 Texto

Las reglas de la sección 13, con la voz de A: frases de documento, sin exclamaciones,
los números como protagonistas.

---

## 5. Dirección B · «Consola de muelle»

**La idea.** La pantalla es el instrumento del supervisor: superficies tonales sin
contornos, una tipografía condensada que mete más dato en menos ancho, objetivos de 56
dp y el naranja del chaleco como relleno de lo que pide una acción. La oficina recibe
la misma consola en denso: un panel de turno a la derecha con el avance en vivo. La
firma: la **barra de operación**, siempre al pie en el teléfono, con las dos cifras que
importan y la acción principal, y los números condensados en negrita.

### 5.1 Paleta

| Nombre | Rol | Claro | Oscuro | De dónde sale |
|---|---|---|---|---|
| Hormigón | Fondo (`surface`) | `#FFFFFF` | `#061120` | El blanco del muelle al sol; la noche del muelle |
| Losa | Superficies tonales: bloques, barra de operación, panel (`surfaceContainer`) | `#EDF2FA` | `#0E1B30` | Una losa más clara u oscura que el fondo, sin línea |
| Tinta | Texto e iconos (`onSurface`) | `#0A1A33` | `#F2F6FB` | Casi negro azulado |
| Marca | Acción principal, selección (`primary`) | `#0D47A1` | `#7FAAF0` | La semilla del ícono |
| Acero | Bodega, segundo plano (`secondary`) | `#6E9DE6` | `#6E9DE6` | La bodega del ícono |
| Chaleco | Relleno de la acción pendiente y de lo que se mueve (`tertiaryContainer`), siempre con tinta oscura encima | relleno `#FF7A1A`, texto `#B83D00` | relleno `#FF7A1A`, texto `#FFA366` | El chaleco y la grúa |

Derivados: tinta suave `#3F5473` / `#B5C3D6`; línea fuerte `#5F7694` / `#6B84A8` (solo en
celdas, 2 dp); marca tenue `#D6E3F7` / `#1B3561`; acero tenue `#DCE6F5` / `#162844`; losa
alta `#DCE6F5` / `#162844`. La misma regla que en A: sobre el chaleco y sobre el acero, el
texto es tinta oscura.

### 5.2 Tipografía

**Fira Sans** para la interfaz, **Fira Sans Condensed** para cifras grandes y celdas, y
**Fira Mono** para números de contenedor. Licencia SIL Open Font License 1.1 (Mozilla y
Carrois). Por qué Fira: cobertura muy amplia de glifos, cifras tabulares, una
condensada de la misma familia que resuelve el problema real de B (más texto en 56 dp
de celda y en 360 dp de pantalla) y una mono hermana. Archivos: Sans Regular, Medium y
SemiBold; Sans Condensed Medium y SemiBold; Mono Regular (seis TTF).

Escala: base 14, razón 1.25.

| Rol | Tamaño / peso | Dónde |
|---|---|---|
| Cifra grande | 44 / 600 Condensed, tabular | Barra de operación, KPI |
| Titular | 28 / 600 | Inicio |
| Título de pantalla | 22 / 600 | Barra superior |
| Título de bloque | 18 / 600 | Secciones |
| Cuerpo | 14 / 400 / 1.5 | Texto |
| Cuerpo secundario | 12 / 400 | Metadatos |
| Rótulo | 12 / 500 | Chips, leyenda, navegación |
| Dato mono | 14 / 400 Mono, tabular | Números de contenedor |
| Celda | 12 / 600 Condensed, tabular | Código en la celda |
| Celda, línea 2 | 11 / 500 Condensed | Peso o tipo |

### 5.3 Tokens

| Grupo | Valores |
|---|---|
| Espacio (base 4, ritmo de 8) | 4 · 8 · 16 · 24 · 32 · 48. Densidad: oficina 8 dentro de bloques y 16 entre bloques; muelle 16 y 32 |
| Radios | 4 en controles y chips · 8 en hojas y bloques · 12 en diálogos · 2 en celdas |
| Elevación | **Superficies tonales**: hormigón → losa → losa alta, sin líneas ni sombras; el único contorno es el de la celda (2 dp) y el foco (2 dp de marca) |
| Alturas de control | Oficina: botón 44, campo 48, fila 56, chip 40. Muelle: botón principal 56, botón 52, campo 56, fila 72, chip 48 |
| Celda del plano | Muelle 60 × 48, hueco 4; oficina 52 × 44 |
| Estructura | Barra superior 56 · barra de navegación 80 · riel 96 con rótulos · panel de turno 400 · ancho máximo 1600 |
| Objetivos táctiles | 48 mínimo; 56 en lo principal; en el muelle los chips de leyenda miden 48 |

Componentes propios: los mismos nombres que en A con otra piel, más `BsPanelDeTurno`
(oficina) y `BsContador` (cifra condensada con rótulo y barra de progreso).

### 5.4 Movimiento

Solo respuesta a la mano: pulsación con escala 0.97 en 100 ms, hojas 180 ms, nada
decorativo y nada al abrir. Cambio de bahía inmediato en los dos usuarios. Reducción de
movimiento del sistema respetada igual que en A.

### 5.5 Texto

Las reglas de la sección 13 con la voz de B: más corto todavía, el verbo primero, la
cifra antes que el rótulo («18 por bajar», «6 hechos»).

---

## 6. Lo que las dos direcciones comparten: roles semánticos y «Colorear por»

### 6.1 Roles semánticos (la `ThemeExtension`)

Cada rol tiene relleno, texto sobre el relleno y contorno, en claro y en oscuro
(valores y contraste en `contraste.md`). **El color nunca va solo**: cada rol lleva su
icono o su rótulo en la celda, en la leyenda y en las listas.

| Rol | Señal además del color | Claro (relleno / contorno) | Oscuro (relleno / contorno) |
|---|---|---|---|
| Pendiente (por hacer) | icono de flecha abajo o arriba, «Baja» / «Sube» | `#DCE7F8` / `#0D47A1` | `#1E3A66` / `#8FB4F2` |
| Hecho | icono de palomita, «Hecho» | `#D3EFDB` / `#1E6B43` | `#1D4A33` / `#6FCF97` |
| Cancelado | icono de bloqueo, «Cancelado», texto en tinta suave | `#E4E8EE` / `#7A8DA6` | `#2A3850` / `#8A9DB8` |
| Revisar (conflicto, aviso) | icono de aviso, «Revisar» | `#FBE7B5` / `#8A5A00` | `#5C4300` / `#E0B23F` |
| Error | icono de error y mensaje con causa y acción | `#F9D9D6` / `#B3261E` | `#601410` / `#F2B8B5` |
| Peligrosa (IMO) | icono de rombo y la clase | `#F9D9D6` / `#B3261E` | `#601410` / `#F2B8B5` |
| Refrigerado | icono de copo y la temperatura | `#C4E3EE` / `#1F6F8B` | `#1E4A5C` / `#7FC6DD` |
| OOG | icono de flechas hacia fuera | `#E3C4EE` / `#6B2E8A` | `#4A2A5E` / `#C9A0DE` |
| De paso | sin relleno, texto en tinta suave, «Paso» | papel / `#7A8DA6` | papel / `#5C7392` |
| Reservado | contorno discontinuo, sin relleno | hoja / `#7A8DA6` | hoja / `#8A9DB8` |
| Cubierta y bodega | rótulo de zona con icono; bodega en acero tenue | — | — |
| En movimiento (arrastre, sin confirmar) | el naranja grúa o chaleco con icono | según la dirección | según la dirección |

La carga especial (peligrosa, refrigerado, OOG) se señala **siempre** con una insignia
de icono en la esquina de la celda, en cualquiera de las tres vistas de color. Así el
relleno queda libre para la categoría y nunca se pierde la señal de seguridad.

### 6.2 La paleta categórica: destino y tipo de vacío

Doce tonos a 30° (arcilla, ámbar, oliva, hierba, verde mar, turquesa, cielo, cobalto,
índigo, uva, magenta, rosa), **los mismos tonos en claro y en oscuro**; lo que cambia es
la luminosidad: en claro, rellenos a 85 % con tinta oscura encima (9.5 a 12.9 : 1) y
contornos a 32 % (4.0 a 11.5 : 1 sobre el papel); en oscuro, rellenos a 30 % con texto
claro (5.1 a 11.1 : 1) y contornos a 68 % (5.6 a 11.8 : 1). Los doce hexadecimales están en
`contraste.md` y entran al código como constantes de la `ThemeExtension`, no como
`Colors.*`.

**Asignación estable.** Un puerto o un tipo recibe el tono `hash(código) mod 12`, con
FNV-1a de 32 bits sobre el código en mayúsculas (UN/LOCODE para el destino, el código
ISO de tamaño y tipo, como `45G1`, para el tipo de vacío). Es una función pura de la
capa de presentación: ni almacena nada ni depende del viaje, así que GTSTC se ve del
mismo color en la oficina, en el muelle, en la Web y en cualquier viaje. Con doce tonos,
dos códigos de un mismo viaje pueden compartir tono: lo resuelven el código escrito en
la celda y la leyenda, que ordena por cantidad. Si Carlos prefiere menos colisiones, la
alternativa son 24 ranuras (los mismos doce tonos en dos luminosidades); es una decisión
del ALTO.

**Qué colorea cada vista.**

| Vista | Qué pinta el relleno | Qué pasa con lo demás | Leyenda |
|---|---|---|---|
| Destino | El puerto de descarga de cada contenedor | Reservas con contorno y su puerto; de paso en tinta suave | Puertos del viaje con su cuenta, ordenados por cantidad |
| Tipo de vacío | El código ISO de tamaño y tipo de los **vacíos** y de las reservas | Los llenos en papel con el código, para que los vacíos resalten | Tipos presentes con su cuenta, de mayor a menor |
| Estado de la operación | Pendiente, hecho, cancelado, revisar, de paso | — | Los estados con su cuenta |

**Vista por omisión según el modo.** Contenido (mirar el plano): por destino. Número de
orden: por tipo de vacío. Carga: por tipo de vacío. Descarga: por estado. El cambio de
modo propone la vista; el planificador puede cambiarla y la app recuerda la última
elección por modo en el dispositivo (misma persistencia que la barra plegada de T-91).

**Resaltar.** Los filtros de la leyenda de hoy (lleno, vacío, IMO, refrigerado, OOG, de
paso) pasan a chips de «Resaltar» debajo de la leyenda: atenúan lo que no coincide (color
con alfa, no un `Opacity` por celda) y no cambian el relleno.

### 6.3 Estadísticas y avance: monocromo

Los gráficos usan una sola escala secuencial de la marca (`#D9E7FC → #95BBF6 → #518FF1 →
#1365E5 → #0D47A1`, generada en `contraste.md`); las barras por puerto llevan una muestra
pequeña del color categórico del puerto para enlazar con el plano, pero la barra es de
marca. Ningún `Colors.*`.

## 7. La fuente, las cifras y los símbolos

- **Familia:** A propone IBM Plex (Sans y Mono); B propone Fira (Sans, Sans Condensed y
  Mono). Las dos son OFL 1.1, tienen cifras tabulares por `tnum` (en Flutter,
  `FontFeature.tabularFigures()`) y cubren el español completo. La cobertura exacta de
  `· ‑ … × •` (U+00B7, U+2011, U+2026, U+00D7, U+2022) se **comprueba con el archivo TTF al
  empaquetar en la Fase 2**, con `fontTools`, y queda en el informe; el guion que no parte
  (U+2011) es el único que no doy por hecho en ninguna de las dos.
- **Qué se declara en `pubspec.yaml`:** la familia bajo `fonts:` (es un asset, no una
  dependencia; autorizado en 10.2). Windows, Android y la Web pasan a dibujar con la misma
  letra; la Web deja de depender de Roboto y Noto para la interfaz (las conserva para lo
  que ya sirve).
- **Números:** contenedor «MSCU 123456 7» (propietario, serie y dígito de control
  separados por un espacio fino, en mono); posición «002-01-82» en celdas y listas, y
  «Bahía 002, Fila 01, Nivel 82» en el detalle (el formato de T-112, que las pruebas
  comprueban); peso «28.7 t» en pantalla y «VGM 28 650 kg» en el detalle; porcentajes
  «91 %» con espacio.
- **Iconos en vez de símbolos:** «▲ CUBIERTA» y «▼ BODEGA» pasan a rótulos «Cubierta» y
  «Bodega» con `Icons.vertical_align_top` y `Icons.vertical_align_bottom`; `→` en los
  movimientos pasa a `Icons.arrow_forward` (y «de … a …» en el texto accesible); `↔` a
  `Icons.swap_horiz`; la viñeta de la política se dibuja como lista. Se conservan
  `· ‑ … ×` en los textos de T-112 que las pruebas comprueban.

## 8. El flujo «ver primero, confirmar después» y las capas que toca

### 8.1 Los estados del viaje en la interfaz

Hoy el `VoyageNotifier` tiene un viaje pendiente invisible y un viaje publicado visible.
El flujo nuevo añade un estado visible intermedio y lo escribe como `sealed class` en
`presentation/` (dart-use-pattern-matching):

| Estado | Qué se ve | Qué se puede hacer |
|---|---|---|
| `SinViaje` | El inicio: «Seleccionar archivo», recientes, perfiles | Abrir |
| `Leyendo` | Indicador con el nombre del archivo | Nada |
| `Previo(viaje, perfil propuesto, escala propuesta, motivo)` | **El plano**, la lista y las estadísticas, con la **banda de «sin confirmar»** | Mirar, buscar, colorear, exportar, confirmar o descartar |
| `Publicado(viaje, perfil, escala)` | Lo de hoy | Todo: operar, publicar, listado, salida |
| `Fallo(mensaje)` | El error con causa y acción y «Intentar de nuevo» | Volver a abrir |

El motivo del `Previo` escribe la banda: *buque nuevo* («Perfil propuesto desde el
archivo»), *homónimo* («Hay perfiles con el mismo nombre: confirma el buque»), *fuera
del perfil* («El perfil guardado no cubre esta carga: revisa la ampliación») o *escala
por decidir* («El archivo sale de PAMIT rumbo a GTSTC: confirma la escala»).

### 8.2 El recorrido

1. Inicio → «Seleccionar archivo» → el selector del sistema. **Tres pasos**, y el plano
   abre en `Previo` con el perfil que propone el archivo (`VesselProfile.proposeFrom`) y
   la escala propuesta (`suggestPortOfCall`), sin guardar nada: no entra en Recientes, no
   crea operación, no toca el almacén.
2. Si ya hay un perfil guardado que cubre la carga y la escala no admite duda, el viaje
   abre **publicado** directamente, como hoy (`_useProfile` ya lo hace): también tres
   pasos, y se puede operar de una vez. Desde Recientes, dos toques.
3. En `Previo`, la banda muestra la escala propuesta y «Confirmar». Confirmar abre
   «Parámetros del buque» (S09) con la propuesta cargada; «No lo tengo» sin marcar; al
   confirmar, el viaje se publica y **se queda en el Plano** (decisión a de 10.2).
4. Mientras no se confirme: los modos Carga y Descarga no aparecen (ya los gobierna
   `portOfCall == null`), «Publicar operación» y el listado dicen que falta confirmar, y
   los pesos por pila, las tomas y las alertas de peso salen «sin evaluar» (hoy ya pasa
   cuando `publishedProfile` es nulo: `stack_weight_provider.dart:13`,
   `stowage_validation_provider.dart:14`). Las alertas de apilamiento 20 sobre 40 y la
   segregación sí se evalúan, porque solo necesitan la geometría.
5. Abrir otro archivo o un reciente en `Previo` descarta el previo (una pregunta corta:
   «¿Descartar el plano sin confirmar?»); hoy `loadVesselFromFile` se niega mientras hay
   un pendiente, así que la interfaz descarta antes.

### 8.3 Las capas que toca (verificado en el código)

| Capa | Archivo | Qué cambia |
|---|---|---|
| presentation/providers | `vessel_providers.dart` (`VoyageNotifier`) | `parseBaplieContent` publica el **previo** en `state` en vez de dejarlo invisible; nuevos `isPreview`, `previewPortOfCall`, `previewReason`, `discardPreview`; `confirmGeometry` sigue igual (lee `_pendingVoyage`); `_publish` sigue siendo el único punto que guarda y crea la operación |
| presentation/providers | nuevo `voyage_ui_state.dart` | La `sealed class` de 8.1 derivada del notifier |
| presentation/pages | `vessel_overview_page.dart` | Deja de empujar «Parámetros del buque» al cargar; muestra la banda; «Confirmar» abre S09; al confirmar, `animateTo` del Plano; descartar |
| presentation/widgets | `bay_plan_view.dart`, `loading_plan_controls.dart` | La banda y los rótulos «sin evaluar»; nada en los modos (ya dependen de `portOfCall`) |
| presentation/pages | `recent_voyages_page.dart`, `empty_state_widget.dart` | Recientes en el inicio |
| test/ | las pruebas de carga y perfil (`profile_loading_page_test`, `t63_*`, `t68_*`, `t103_*`, `t107_*`…) | Esperan que la página de parámetros se abra sola: se actualizan y se declaran |
| tool/ | `t99_conductor.dart`, `t98_primera_*` | Los pasos de la primera visualización |
| **domain/** | — | **Nada.** Se usan `VesselProfile.proposeFrom`, `VesselVoyage.withGeometry`, `suggestPortOfCall`, `cargoCountsFor`, que ya existen |
| **data/** | — | **Nada.** El previo no se guarda |

Lo que confirma que cabe en presentación: `_publish` (`vessel_providers.dart:312-345`) es
la única escritura (operación, almacén, recientes); los validadores de peso y tomas usan
`publishedProfile`, nulo en el previo (0.9 de la Fase 0); `activeOperationProvider`
(`sync_providers.dart:41-54`) devuelve nulo sin escala, así que el chip de nube dice «Solo
este dispositivo» y nada intenta sincronizar; `offersDischarge` y el modo Carga exigen
`portOfCall`. **No hace falta T-115.** Dos riesgos declarados: un consumidor que dé por
publicado lo que ve (`CloudPage.«Publicar»` ya responde con mensaje si falta el perfil) y
las pruebas de T-63 y T-98 que cuentan pasos.

## 9. Navegación adaptable

Las clases de ventana de Material 3 deciden la estructura; el contenido es el mismo.

| Ancho | Estructura | Destinos |
|---|---|---|
| < 600 dp (teléfono) | `NavigationBar` de 80 dp con cinco destinos; barra superior de 56 con el título y dos acciones como máximo | Plano · Lista · Avance · Estadísticas · Más |
| 600 – 1199 dp (tableta, ventana media) | `NavigationRail` de 80 dp (A) o 96 con rótulos (B); contenido a todo el ancho | Los mismos cinco; Nube y Parámetros al pie del riel |
| ≥ 1200 dp (oficina) | Riel + contenido + **panel lateral** (A 360, B 400) con el detalle de la celda, la leyenda o el avance | Igual; Alertas también en el riel |

«Más» abre una hoja con Alertas de estiba (con su insignia de cuenta), Comparar con otro
BAPLIE, BAPLIE de salida, Listado de la agencia, Orden de descarga, Tapas, Nube y cuenta,
Parámetros y «Cerrar plano». Sin viaje no hay barra: el inicio es una pantalla sola.
Las ocho acciones de la barra de hoy se reparten: Recientes y Perfiles van al inicio;
Buscar vive en Plano y Lista; Exportar, Parámetros y Limpiar van a «Más»; Nube es un chip
en la cabecera y un destino del riel; Cargar archivo vuelve al inicio.

Atrás (Android): cierra primero hojas y paneles; en la raíz del viaje pregunta «¿Cerrar el
plano?» solo si hay un previo sin confirmar; con el viaje publicado vuelve al inicio.
GoRouter no hace falta para esto (`NavigationBar`, `NavigationRail` y `Navigator` bastan);
se reconsidera solo si la Web pide enlaces profundos por bahía.

## 10. Wireframes de las cinco pantallas clave

Lienzos: 360 dp (un carácter ≈ 9 dp) y 1920 px (un carácter ≈ 17 px). Las letras de las
celdas son códigos de puerto abreviados (GT = GTSTC, US = USHOU, PA = PAMIT); la insignia
`!` es peligrosa, `❄` refrigerado. `⌂` es el icono de inicio del riel.

### 10.1 Inicio

**A · 360 dp**
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
│ │ MAGELLAN STAR  0123W         ›   │ │ fila 72
│ │ 977 contenedores, 27 bahías      │ │ 12, suave
│ │ Escala GTSTC, hoy 14:08          │ │
│ ├──────────────────────────────────┤ │
│ │ BUQUE MANUAL  M100           ›   │ │
│ │ 60 contenedores, 4 bahías        │ │
│ │ Escala GTSTC, ayer               │ │
│ └──────────────────────────────────┘ │
│ Perfiles guardados (3)             › │ fila 56
│ Operaciones abiertas en la nube    › │ solo con cuenta
└──────────────────────────────────────┘
```

**A · 1920 px**
```
┌────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│ ▮ BayStream                                                                       Parámetros   Nube ☁  │ 56
├────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                                        │
│    Abre un plano de estiba                        Recientes en este equipo                             │
│    Lee un BAPLIE 2.x; la 1.5 se lee con aviso.    ┌──────────────────────────────────────────────────┐ │
│                                                   │ MAGELLAN STAR 0123W   977 contenedores  27 bahías│ │
│    ┌─────────────────────────────┐                │ Escala GTSTC, publicada, hoy 14:08             › │ │
│    │ ▣   Seleccionar archivo     │  56            ├──────────────────────────────────────────────────┤ │
│    └─────────────────────────────┘                │ BUQUE MANUAL M100      60 contenedores   4 bahías│ │
│                                                   │ Escala GTSTC, solo aquí, ayer                  › │ │
│    Perfiles guardados                             └──────────────────────────────────────────────────┘ │
│    MAGELLAN STAR    imo 9…    23 col × 8 niv   ✎                                                       │
│    BUQUE MANUAL     imo 9…     2 col × 1 niv   ✎  Operaciones abiertas en la nube                      │
│                                                   ┌──────────────────────────────────────────────────┐ │
│                                                   │ MAGELLAN STAR 0123W, GTSTC          [ Unirse ]   │ │
│                                                   └──────────────────────────────────────────────────┘ │
└────────────────────────────────────────────────────────────────────────────────────────────────────────┘
```
Dos columnas de 1/3 y 2/3 sobre 1440 de ancho máximo; alineación a la izquierda; la
acción única es el botón de 56 dp.

**B · 360 dp**
```
┌──────────────────────────────────────┐
│ BayStream                   ⚙    ☁   │ 56
├──────────────────────────────────────┤
│ ┌──────────────────────────────────┐ │
│ │ ▣                                │ │ bloque chaleco (naranja, tinta oscura)
│ │ Abrir plano BAPLIE               │ │ 22/600 · 96 dp de alto
│ │ 2.x; la 1.5 con aviso            │ │
│ └──────────────────────────────────┘ │
│ ┌──────────────────────────────────┐ │
│ │ ☁  Unirse a una operación        │ │ losa, 64 dp (con cuenta)
│ └──────────────────────────────────┘ │
│ Recientes                            │ 18/600
│ ┌──────────────────────────────────┐ │
│ │ MAGELLAN STAR 0123W              │ │ losa, 88 dp
│ │ 977 cont. · 27 bahías            │ │ 12 condensed
│ │ ● Publicada     GTSTC     14:08  │ │ estado con icono
│ ├──────────────────────────────────┤ │
│ │ BUQUE MANUAL M100                │ │
│ │ 60 cont. · 4 bahías              │ │
│ │ ○ Solo aquí     GTSTC     ayer   │ │
│ └──────────────────────────────────┘ │
│ Perfiles (3)                       › │
└──────────────────────────────────────┘
```

**B · 1920 px**
```
┌────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│ ▮ BayStream                                                                       Parámetros   Nube ☁  │
├────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│  ┌───────────────────────────┐  ┌───────────────────────────┐  ┌───────────────────────────────────┐   │
│  │ ▣                         │  │ ☁                         │  │ Perfiles guardados (3)            │   │
│  │ Abrir plano BAPLIE        │  │ Unirse a una operación    │  │ MAGELLAN STAR   23 col × 8 niv  ✎ │   │
│  │ 2.x; la 1.5 con aviso     │  │ 2 abiertas en la nube     │  │ BUQUE MANUAL     2 col × 1 niv  ✎ │   │
│  └───────────────────────────┘  └───────────────────────────┘  └───────────────────────────────────┘   │
│  Recientes                                                                                             │
│  ┌──────────────────────────────┐ ┌──────────────────────────────┐ ┌──────────────────────────────┐    │
│  │ MAGELLAN STAR 0123W          │ │ BUQUE MANUAL M100            │ │ T99 SINTÉTICO 5000           │    │
│  │ 977 cont. · 27 bahías        │ │ 60 cont. · 4 bahías          │ │ 5000 cont. · 40 bahías       │    │
│  │ ● Publicada  GTSTC  14:08    │ │ ○ Solo aquí  GTSTC  ayer     │ │ ○ Solo aquí  —  20-oct       │    │
│  └──────────────────────────────┘ └──────────────────────────────┘ └──────────────────────────────┘    │
└────────────────────────────────────────────────────────────────────────────────────────────────────────┘
```

### 10.2 Plano por bahía (vista «Contenido», previo sin confirmar)

**A · 360 dp**
```
┌──────────────────────────────────────┐
│ ‹ MAGELLAN STAR 0123W        🔍   ⋮  │ 56
├──────────────────────────────────────┤
│ ⓘ Plano sin confirmar. Escala        │ banda marca tenue
│   propuesta GTSTC.      [Confirmar]  │ 2 líneas, botón 40
├──────────────────────────────────────┤
│ Bahía 02        63 cont.    416.8 t  │ 22/600 + cifras tabulares
│ ‹ ▁▂▆█▇▃▁▂ silueta ▂▃▁ ›  02 ▲       │ tira de bahías = perfil (48 dp)
│ Colorear por  (Destino ▾)   Resaltar │ chips 40
├──────────────────────────────────────┤
│       04   02   00   01   03  cub.   │ cabecera de filas, 12/500
│ 84  ┌──┐ ┌──┐ ┌──┐ ┌──┐ ┌──┐  12.3   │ celda 56×44, hueco 4
│     │GT│ │GT│ │US│ │  │ │PA│   t     │ relleno = destino, texto 11/600
│ 82  └──┘ └──┘ └──┘ └──┘ └──┘         │
│ ════════════ tapa ═══════════        │ línea de tapa, 2 dp, tinta
│ 06  ┌──┐ ┌──┐ ┌──┐ ┌──┐ ┌──┐  bod.   │ zona bodega sobre acero tenue
│     │GT│ │!GT│ │GT│ │❄US│ │PA│  38.1 │ insignias de carga especial
│ 04  └──┘ └──┘ └──┘ └──┘ └──┘   t     │
│ 02  …                                │ (se desplaza en las dos direcciones;
│                                100 % │ pellizco para ampliar; chip de zoom)
├──────────────────────────────────────┤
│ ■ GTSTC 120  ■ USHOU 55  ■ PAMIT 30  │ cartela: chips 40, Wrap
│ ! IMO 3   ❄ Refrigerado 12   ⬚ OOG 1 │ resaltar
├──────────────────────────────────────┤
│  ▦ Plano   ☰ Lista   ✓ Avance   ⫶ Estadísticas   ⋯ Más │ 80
└──────────────────────────────────────┘
```

**A · 1920 px**
```
┌────┬───────────────────────────────────────────────────────────────────────────────────┬─────────────────┐
│ ⌂  │ MAGELLAN STAR 0123W   ⓘ Plano sin confirmar · escala propuesta GTSTC  [Confirmar] │ 🔍 ☁ Solo aquí  │ 56
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
│ ⚠  │                                                                          100 %  │ Leyenda         │
│ Al │                                                                                  │ ■ GTSTC 120     │
│    │                                                                                  │ ■ USHOU 55      │
│ ☁  │                                                                                  │ ■ PAMIT 30      │
│ ⚙  │                                                                                  │ ! IMO 3 ❄ Ref 12│
└────┴───────────────────────────────────────────────────────────────────────────────────┴─────────────────┘
```
Riel de 80; rejilla de 52 × 44 con 23 columnas (1 432 px con rótulos y pesos); panel de 360
con el detalle de la celda seleccionada y la leyenda. El zoom amplía la rejilla dentro de
su lienzo; el chip «100 %» vive en la esquina inferior derecha del lienzo, nunca sobre el
título.

**B · 360 dp**
```
┌──────────────────────────────────────┐
│ ‹ MAGELLAN STAR 0123W        🔍   ⋮  │ 56
│ ⚠ Sin confirmar · escala GTSTC [Confirmar] │ banda chaleco (naranja, tinta oscura) 48
├──────────────────────────────────────┤
│ ┌────┐  Bahía 02                     │ paso de bahía 56 dp: botones ‹ ›
│ │ ‹  │  63 cont.  416.8 t    ┌────┐  │ cifras 44/600 condensed
│ └────┘                        │ ›  │  │
│ Destino | Tipo | Estado   (segmentos)│ SegmentedButton 48, siempre a la vista
├──────────────────────────────────────┤
│ 84 ┌───┐┌───┐┌───┐┌───┐┌───┐   cub.  │ celda 60×48, texto 12/600 condensed
│    │GTS││GTS││USH││   ││PAM│   12.3  │ contorno 2 dp línea fuerte
│ 82 └───┘└───┘└───┘└───┘└───┘         │
│ ▬▬▬▬▬▬▬▬▬ tapa ▬▬▬▬▬▬▬▬▬▬            │ losa alta
│ 06 ┌───┐┌───┐┌───┐┌───┐┌───┐   bod.  │
│    │GTS││!GT││GTS││❄US││PAM│   38.1  │
│ 04 └───┘└───┘└───┘└───┘└───┘         │
│ 02 …                           100 % │
├──────────────────────────────────────┤
│ ■ GTSTC 120 ■ USHOU 55 ■ PAMIT 30 ›  │ leyenda en chips de 48
├──────────────────────────────────────┤
│  ▦ Plano  ☰ Lista  ✓ Avance  ⫶ Est.  ⋯ Más │ 80
└──────────────────────────────────────┘
```

**B · 1920 px**
```
┌──────┬──────────────────────────────────────────────────────────────────────────────┬──────────────────┐
│ ⌂    │ MAGELLAN STAR 0123W      ⚠ Sin confirmar · escala GTSTC   [ Confirmar ]       │ 🔍  ☁ Solo aquí  │
│      ├──────────────────────────────────────────────────────────────────────────────┼──────────────────┤
│ ▦    │ ‹ 02 ›   01 02 03 05 06 07 09 10 11 13 14 … 38      63 cont.   416.8 t       │ PANEL DE TURNO   │
│ Plano│ Destino | Tipo de vacío | Estado           Resaltar: ! IMO  ❄ Ref  ⬚ OOG  ~ Paso│ (no es texto en  │
│      ├──────────────────────────────────────────────────────────────────────────────┤  mayúsculas: es  │
│ ☰    │      22 20 18 16 14 12 10 08 06 04 02 00 01 03 05 07 09 11 13 15 17 19 21    │  el título 18)   │
│ Lista│ 86   ┌┐ ┌┐ ┌┐ ┌┐ ┌┐ ┌┐ ┌┐ ┌┐ ┌┐ ┌┐ ┌┐ ┌┐ ┌┐ ┌┐ ┌┐ ┌┐ ┌┐ ┌┐ ┌┐ ┌┐ ┌┐ ┌┐ ┌┐  8.2 │ Descarga         │
│      │ 84   GT GT US US GT GT PA PA GT GT GT GT GT US US GT GT PA GT GT US GT GT 12.3 │ 120 de 150  80 % │
│ ✓    │ 82   GT GT US US GT GT PA PA GT !GT GT GT GT US US GT GT PA GT GT US GT GT 14.0 │ ████████░░       │
│ Avan.│ ▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬ tapa ▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬ │ Carga            │
│      │ 08   GT GT GT GT GT GT ❄US ❄US GT GT GT GT GT GT GT GT GT GT GT GT GT GT GT 38.1 │ 52 de 529   10 % │
│ ⫶    │ 06   GT GT GT GT GT GT GT GT GT GT GT GT GT GT GT GT GT GT GT GT GT GT GT  40.5 │ █░░░░░░░░░       │
│ Estad│ 04   GT GT GT GT GT GT GT GT GT GT GT GT GT GT GT GT GT GT GT GT GT GT GT  41.2 │ ───────────────  │
│      │ 02   GT GT GT GT GT GT GT GT GT GT GT GT GT GT GT GT GT GT GT GT GT GT GT  39.8 │ 14:08 Descarga   │
│ ⚠    │                                                                        100 % │  MSCU 123456 7   │
│ Alert│                                                                              │ 14:05 Re‑estiba  │
│ ☁  ⚙ │                                                                              │  TSTU 000012 3   │
└──────┴──────────────────────────────────────────────────────────────────────────────┴──────────────────┘
```
Riel de 96 con rótulos; panel de turno de 400 con los contadores y los últimos
movimientos (en el previo, el panel muestra la leyenda y «Confirma la escala para
operar»).

### 10.3 Muelle: carga y descarga (el plano en modo Operar, viaje publicado)

**A · 360 dp, modo Descarga**
```
┌──────────────────────────────────────┐
│ ‹ MAGELLAN STAR 0123W      ☁ Al día  │
├──────────────────────────────────────┤
│ Operar   ◉ Descarga    ○ Carga       │ SegmentedButton 48
│ Bahía 02    18 por bajar   6 hechas  │ 16/600 + cifras
│ ‹ ▁▂▆█▇▃▁▂ silueta ▂▃▁ ›  02 ▲       │
│ Colorear por (Estado ▾)              │
├──────────────────────────────────────┤
│ 84  ┌──┐ ┌──┐ ┌──┐ ┌──┐ ┌──┐         │
│     │⬇ │ │✓ │ │~ │ │⬇ │ │  │         │ icono grande + rótulo corto
│     │Baja││Hecho││Paso││Baja│         │ relleno = estado
│ 82  └──┘ └──┘ └──┘ └──┘ └──┘         │
│ ════════════ tapa ═══════════        │
│ 06  ┌──┐ ┌──┐ ┌──┐ ┌──┐ ┌──┐         │
│ …                                    │
├──────────────────────────────────────┤
│ ✓ Descarga registrada                │ aviso 6 s, 56 dp
│   MSCU 123456 7 · 002-01-82 [Deshacer]│
├──────────────────────────────────────┤
│ ┌──────────────────────────────────┐ │
│ │ ☰  Pendientes por bahía          │ │ barra de operación: acción secundaria 48
│ └──────────────────────────────────┘ │
│  ▦ Plano   ☰ Lista   ✓ Avance   …    │ 80
└──────────────────────────────────────┘
```
Un toque sobre «Baja» registra, como hoy (T-75), y el aviso ofrece «Deshacer» 6 s; el
detalle (toque largo o desde la Lista) también deshace. En **Carga**, la barra de
operación lleva el campo «OR o últimos dígitos» de 56 dp con el micrófono y «Asignar
vacío»; el diálogo «Confirmar carga» pasa a hoja inferior a toda la altura con los
mismos campos y un solo botón principal que dice lo que hace.

**A · 1920 px, modo Carga (oficina viendo lo mismo)**
```
┌────┬───────────────────────────────────────────────────────────────────────────────────┬─────────────────┐
│ ⌂  │ MAGELLAN STAR 0123W · GTSTC        Operar  ○ Descarga ◉ Carga      ☁ Al día       │ Carga           │
│ ▦  │ ‹ silueta › 02 ▲      Bahía 02   18 pendientes (3 llenos, 15 vacíos)    Colorear  │ 52 de 529       │
│ ☰  │                                                              por (Tipo de vacío ▾) │ ██░░░░░░░░ 10 % │
│ ✓  ├───────────────────────────────────────────────────────────────────────────────────┤ llenos 40 de 62 │
│ ⫶  │ 84   ⬆45 ⬆45 ⬆22 ⬆22 ✓45 ✓45 ⬆22 ⬆22 …                                           │ vacíos 12 de 467│
│ ⚠  │ 82   ⬆45 ⬆45 ✓22 ✓22 …                                                            │ ─────────────── │
│    │ ══════════════════════ tapa ═════════════════════                                 │ OR o últimos    │
│    │ 08   …                                                                            │ dígitos  [ 🔍 ] │
│    │                                                                                   │ Asignar vacío   │
│ ☁  │ ■ 45G1 vacío 210  ■ 22G1 vacío 180  ■ 42G1 vacío 77   (llenos en papel)           │ Solicitudes (2) │
└────┴───────────────────────────────────────────────────────────────────────────────────┴─────────────────┘
```

**B · 360 dp, modo Descarga**
```
┌──────────────────────────────────────┐
│ ‹ MAGELLAN STAR 0123W      ☁ Al día  │
│ Descarga | Carga              (48)   │ SegmentedButton a todo el ancho
├──────────────────────────────────────┤
│ ┌────┐  Bahía 02              ┌────┐ │
│ │ ‹  │                        │ ›  │ │
│ └────┘  Estado ▾              └────┘ │
├──────────────────────────────────────┤
│ 84 ┌───┐┌───┐┌───┐┌───┐┌───┐         │ celda 60×48
│    │ ⬇ ││ ✓ ││ ~ ││ ⬇ ││   │         │ icono 20 + rótulo 11 condensed
│    │BAJA││HECHO││PASO││BAJA│          │ (rótulo en tipo oración: «Baja», «Hecho», «Paso»)
│ 82 └───┘└───┘└───┘└───┘└───┘         │
│ ▬▬▬▬▬▬▬▬▬ tapa ▬▬▬▬▬▬▬▬▬▬            │
│ …                                    │
├──────────────────────────────────────┤
│  18             6          3         │ BARRA DE OPERACIÓN (losa alta, 112 dp)
│  por bajar      hechas     re‑estibas│ cifras 44/600 condensed + rótulo 12
│ ┌──────────────────────────────────┐ │
│ │ ✓ Descarga registrada  [Deshacer]│ │ el aviso vive dentro de la barra
│ └──────────────────────────────────┘ │
│  ▦ Plano  ☰ Lista  ✓ Avance  …       │ 80
└──────────────────────────────────────┘
```
En **Carga**, la barra de operación muestra «18 pendientes · 3 llenos · 15 vacíos» y el
campo de OR de 56 dp con el micrófono como acción principal.

**B · 1920 px** igual que 10.2 con el panel de turno en modo operación (contadores,
campo de OR, últimos movimientos, solicitudes pendientes con insignia).

### 10.4 Avance en la oficina

**A · 1920 px**
```
┌────┬──────────────────────────────────────────────────────────────────────────────────────────────────────┐
│ ⌂  │ Avance · MAGELLAN STAR 0123W · GTSTC                      ☁ Al día 14:08     Tapas    Exportar       │
│ ▦  ├──────────────────────────────────────────────────────────────────────────────────────────────────────┤
│ ☰  │  Descarga             Carga de llenos        Carga de vacíos         Re‑estibas      Conflictos      │
│ ✓  │  120 de 150           40 de 62               12 de 467               3               2  ▸ ver        │
│ ⫶  │  ████████░░  80 %     ██████░░░░  65 %       █░░░░░░░░░   3 %                                        │
│ ⚠  ├──────────────────────────────────────────────────┬───────────────────────────────────────────────────┤
│    │  Por bahía                                       │  Últimos movimientos                              │
│    │  Bahía  Descarga          Carga         Último   │  14:08  Descarga   MSCU 123456 7   002-01-82  Ana │
│    │  02     12/18 ██████░░    0/18 ░░░░░░   14:08    │  14:05  Re‑estiba  TSTU 000012 3   002-05-84  Ana │
│    │  06     30/30 ████████    4/20 ██░░░░   13:55    │  13:58  Carga      OR 7 MNLU 000070 3  002-02-82 Luis│
│    │  10      0/24 ░░░░░░░░      —           —        │  13:52  Tapa T1 quitada, bahía 06            Ana  │
│    │  14     18/18 ████████    2/16 █░░░░░   13:40    │  …                                                │
│ ☁  │  …                                               │  Peso de las pilas: sin evaluar (sin límite)      │
│ ⚙  │  Conflictos (2)   002-01-82 dos registros…  [Ir] │  Movimientos repetidos: 0                         │
└────┴──────────────────────────────────────────────────┴───────────────────────────────────────────────────┘
```
Los KPI son cifras de 34/600 con barra de 8 dp de marca; la tabla por bahía es una lista
densa (filas de 40) con barras en línea; la columna de movimientos es un flujo que se
actualiza con la sincronización.

**A · 360 dp**
```
┌──────────────────────────────────────┐
│ ‹ Avance · GTSTC           ☁ Al día  │
├──────────────────────────────────────┤
│ Descarga          Carga de llenos    │ 2 KPI por fila
│ 120 de 150        40 de 62           │ 34/600
│ ████████░░ 80 %   ██████░░░░ 65 %    │
│ Carga de vacíos   Re‑estibas  Confl. │
│ 12 de 467   3 %   3           2 ▸    │
├──────────────────────────────────────┤
│ Por bahía                            │
│ 02  Descarga 12/18 ██████░░          │ fila 56, toca → plano
│     Carga 0/18  ·  14:08 Ana       › │
│ 06  Descarga 30/30 ████████          │
│     Carga 4/20  ·  13:55 Ana       › │
│ …                                    │
├──────────────────────────────────────┤
│ Últimos movimientos                  │
│ 14:08 Descarga MSCU 123456 7 002-01-82│
│ …                                    │
│  ▦ Plano   ☰ Lista   ✓ Avance   …    │
└──────────────────────────────────────┘
```

**B · 1920 px**
```
┌──────┬─────────────────────────────────────────────────────────────────────────────────────────────────┐
│ ⌂    │ Avance de la operación   MAGELLAN STAR 0123W   GTSTC              ☁ Al día 14:08   Tapas  Exportar│
│ ▦    ├──────────────┬──────────────┬──────────────┬──────────────┬──────────────┬─────────────────────────┤
│ ☰    │  120 / 150   │   40 / 62    │   12 / 467   │      3       │      2       │  Último: 14:08         │
│ ✓    │  descargados │ llenos carg. │ vacíos asig. │  re‑estibas  │  conflictos  │  Descarga MSCU 123456 7│
│ ⫶    │ ████████░░80%│ ██████░░░░65%│ █░░░░░░░░░ 3%│              │   ▸ ver      │  002-01-82 · Ana       │
│ ⚠    ├──────────────┴──────────────┴──────────────┴──────────────┴──────────────┴─────────────────────────┤
│      │  Por bahía (toca una fila para abrirla en el plano)                 │ Flujo de movimientos        │
│      │  02  descarga ██████░░ 12/18   carga ░░░░░░ 0/18   14:08  Ana       │ 14:08 Descarga MSCU 123456 7│
│      │  06  descarga ████████ 30/30   carga ██░░░░ 4/20   13:55  Ana       │ 14:05 Re‑estiba TSTU …      │
│ ☁  ⚙ │  10  descarga ░░░░░░░░  0/24   carga —            —                 │ 13:58 Carga OR 7 MNLU …     │
└──────┴─────────────────────────────────────────────────────────────────────┴─────────────────────────────┘
```
Cifras de 44/600 condensadas en losas; filas de 48; sin líneas, solo losas.

**B · 360 dp**: las cinco losas apiladas de dos en dos (cifra 44, rótulo 12), después la
lista por bahía (filas de 64) y el flujo.

### 10.5 Estadísticas

**A · 1920 px**
```
┌────┬──────────────────────────────────────────────────────────────────────────────────────────────────────┐
│ ⌂  │ Estadísticas · MAGELLAN STAR 0123W                                                      Exportar     │
│ ▦  ├──────────────────────────────────────────────────────────────────────────────────────────────────────┤
│ ☰  │  977 contenedores   27 bahías   7 419.5 t   612 llenos   365 vacíos   12 refrigerados   3 IMO   1 OOG│ cifras 28/600, rótulo 12
│ ✓  ├─────────────────────────────────────────────────┬────────────────────────────────────────────────────┤
│ ⫶  │  Por puerto de descarga                         │  Por tamaño                                        │
│ ⚠  │  ■ GTSTC  ████████████████████████  520  53 %   │  20'  ███████████████  410  42 %                   │
│    │  ■ USHOU  ████████████  245  25 %               │  40'  ██████████████████  487  50 %                │
│    │  ■ PAMIT  ██████  130  13 %                     │  45'  ███  80  8 %                                 │
│    │  ■ MXVER  ████  82  8 %                         │  Llenos y vacíos  ██████████████░░░░░░░░ 612 / 365 │
│    ├─────────────────────────────────────────────────┴────────────────────────────────────────────────────┤
│    │  Perfil longitudinal   ○ Ocupación  ● Peso         proa ▸ popa                                       │
│    │  ▁▂▃▆█▇▆▅▃▂▁▂▃▅▆▇█▆▃▂▁▂▃▅▆▇  (toca una bahía para abrirla)                                          │
│    ├──────────────────────────────────────────────────────────────────────────────────────────────────────┤
│ ☁  │  Por bahía        02    06    10    14    18    22    26    30    34    38                            │
│ ⚙  │  contenedores     63    58    61    44    52    49    38    41    29    21   (barras con la cifra)   │
│    │  peso, t        416.8 380.2 402.1 …                                                                  │
└────┴──────────────────────────────────────────────────────────────────────────────────────────────────────┘
```
Barras horizontales con la cifra al final (sin texto rotado ni cifras en el borde); la
muestra de color categórico del puerto enlaza con el plano; el resto en la escala de
marca.

**A · 360 dp**: la fila de cifras pasa a una cuadrícula de 2 × 4 (cifra 28, rótulo 12, sin
`GridView` con `shrinkWrap`: una `Wrap` con ancho fijo por token), después cada bloque a
todo el ancho; las barras por bahía son horizontales y desplazables en vertical.

**B · 1920 px**: la misma estructura con cifras 44/600 condensadas en losas y barras más
gruesas (24 dp); **B · 360 dp**: losas de dos en dos y barras a todo el ancho.

## 11. Cómo resuelve cada dirección los objetivos (sección 3 del encargo)

| Objetivo | Dirección A · Plano de a bordo | Dirección B · Consola de muelle |
|---|---|---|
| **RNF-002**, primera visualización en ≤ 3 pasos y < 30 s | Los tres pasos de la sección 8; desde Recientes, dos. El botón de 56 dp es lo único que pide el inicio | Igual; el bloque chaleco de 96 dp hace la acción inconfundible al sol |
| **RNF-003**, nada cortado ni tapado a 360 y 600 dp con letra 1.0, 1.45 y 2.0 | Leyenda en `Wrap` de chips (no scroll horizontal); zoom en la esquina inferior del lienzo; banda de dos líneas que crece; pestañas sustituidas por `NavigationBar`, cuyas etiquetas siempre caben; título con elipsis y ancho fijo; el resumen del modo en la cabecera de bahía con cifras tabulares, no en una frase larga; nada por debajo de 10 sp y el `FittedBox` solo en el código de la celda | Lo mismo, con dos ventajas: la condensada mete los códigos de tres letras a 12 sp y la barra de operación saca las cifras de la cabecera. Con letra 2.0, las losas crecen en alto y se apilan |
| **RNF-001 y 007**, Lista y rejilla perezosas, tablero < 1 s | La Lista pasa a `CustomScrollView` con `SliverList` y filas de 56 dp (de 977 tarjetas de 160 dp a unas 15 en pantalla); la rejilla usa `RepaintBoundary` por zona (cubierta y bodega), celdas sin `FittedBox` y sin `Opacity` (alfa en el color), y un modelo de celda precalculado por bahía; se mide antes y después con T-99 | Igual en el árbol de widgets; las celdas más grandes no cambian la cuenta de widgets |
| **Pendientes de 10.91 y T-111** | Tarjeta del viaje: la cartela con las etiquetas escritas una vez y el singular; barra de pestañas a 2.0: desaparece; cifras del borde de los gráficos: barras horizontales con la cifra al final; desborde de 0.23 dp: `Wrap` con ancho por token en vez de `GridView` calculado; Mayús + rueda en la matriz: `ScrollConfiguration`; matriz desde Alertas; todas las bahías del buque: la silueta deja hueco para las bahías sin carga cuando exista el inventario (10.87) | Igual; el paso de bahía ‹ › también admite bahías vacías |
| **Sin retroceder en T-112** | Los 218 mensajes no cambian; lo nuevo nace en español y en tipo oración; `NavigationBar`, `SegmentedButton`, `Badge`, `SearchBar`, `DropdownMenu` y `NavigationRail` son Material 3; los censos `t98c_*` se repiten por pantalla | Igual |
| **Claro y oscuro** en los tres clientes | Dos juegos de tokens verificados en `contraste.md`; en oscuro cambia la luminosidad, no el tono | Igual |
| **Impacto** (el pedido del tutor) | Lo memorable: la silueta del buque como selector y la rejilla que parece la hoja impresa; el naranja aparece una vez | Lo memorable: la barra de operación con cifras de 44 y los códigos condensados en negrita; el chaleco naranja como acción |

## 12. Movimiento (lo común)

- Solo `Transform` y `opacity`; nunca ancho, alto, margen ni relleno. `RepaintBoundary`
  en la rejilla (por zona), en el perfil longitudinal, en el donut y en el contorno de
  arrastre.
- Duraciones: pulsación 100–150 ms; chips y segmentos 150; hojas y diálogos 180–250;
  nunca más de 300. Curvas `easeOutCubic` al entrar y `easeInOutCubic` al moverse.
- Lo que se repite cien veces por turno (cambiar de bahía en el muelle, marcar una
  celda) no se anima: cambia y ya; la confirmación es el icono y el aviso.
- `MediaQuery.disableAnimationsOf(context)` verdadero → todas las duraciones a cero,
  conservando los cambios de color y opacidad. Hoy no se consulta en ningún sitio.
- Los `SnackBar` de registro duran 6 s con «Deshacer» (como hoy); el de «Generando PDF»
  pasa a un indicador en el botón, no a un aviso de dos minutos.

## 13. Reglas de texto (las dos direcciones)

1. Frases cortas, voz activa, tipo oración; se tutea («Toca una celda»), nunca «Seleccione».
2. **El botón dice lo que pasa y el aviso lo repite:** «Registrar descarga» → «Descarga
   registrada»; «Confirmar y ver el plano» → el plano; «Enviar solicitud» → «Solicitud
   enviada».
3. Nada en mayúsculas sostenidas: «Bahía 02», «Cubierta», «Baja», «Hecho», «Total». Las
   abreviaturas de celda llevan tipo oración y, si caben, la palabra entera. El rótulo de
   la tira de bahías que el conductor de T-99 busca («BAHÍA nn (») cambia con el
   conductor, en la misma entrega.
4. Sin «N/A»: «sin dato», «no declarado», «sin posición».
5. Los números son el dato principal: tabulares, agrupados («MSCU 123456 7», «28 650 kg»),
   una sola unidad en pantalla («28.7 t»), porcentaje con espacio («91 %»), posiciones
   «002-01-82» en celdas y listas y «Bahía 002, Fila 01, Nivel 82» en el detalle.
6. En las pantallas nuevas, los datos de una fila van en líneas o separados por comas, no
   en cadenas con punto medio; los mensajes de T-112 se conservan tal cual.
7. Singular y plural concuerdan siempre (`operationCount`), también en 1.
8. Un error dice qué pasó y qué hacer, sin disculpas; un estado vacío invita a actuar
   («Todavía no hay viajes: abre un BAPLIE»).
9. Cada pantalla tiene un título de dos o tres palabras; los metadatos técnicos
   («Mensaje», «Tipo») salen de la tarjeta principal y van al detalle.

## 14. Comprobaciones hechas sobre este documento

- **Intercambio:** con otra tipografía y la plantilla de Material de fábrica, A perdería
  la cartela y la silueta, y B la barra de operación y los códigos condensados: no son
  intercambiables.
- **Entrecerrar los ojos:** en los dos wireframes de 1920 la jerarquía queda (riel, cabecera,
  rejilla, panel); en A no salta nada; en B salta el chaleco, que es lo único que debe
  saltar.
- **Firma, cinco sitios:** A: silueta-selector, línea de tapa, cartela, naranja único,
  mono para los números. B: barra de operación, chaleco, paso de bahía ‹ ›, códigos
  condensados, losas sin líneas.
- **Tokens:** «papel, hoja, tinta, marca, acero, grúa» y «hormigón, losa, chaleco» dicen de
  qué producto son.
- **Defaults rechazados:** arcoíris, pestañas superiores, `fromSeed` a secas, consola
  oscura por defecto, rótulos en mayúsculas, tarjetas iguales.

## 15. Mi recomendación

**A · «Plano de a bordo».** El plano impreso es el referente común de los dos usuarios y
A lo honra mejor; el papel claro y los contornos finos leen bien al sol; la mono para los
números y la cartela ordenan la oficina sin pedir más clics. De B tomaría una sola cosa,
compatible con A: la barra de operación de 56 dp en el modo muelle (ya está dibujada en
10.3). B es la alternativa si Carlos prefiere más impacto visual y menos documento.

---

## ALTO: Carlos elige

Lo que Carlos decide (Yov revisa antes):

1. **La dirección:** A «Plano de a bordo» o B «Consola de muelle».
2. **La familia tipográfica** de la dirección elegida (IBM Plex o Fira), que se empaqueta
   en la Fase 2 con su licencia y procedencia.
3. **La paleta categórica:** 12 tonos (colisiones posibles, resueltas por el código) o 24
   ranuras (dos luminosidades).
4. **La vista por omisión de «Colorear por» en cada modo** (propuesta en 6.2).
5. **Descarga con un toque** (como hoy, con «Deshacer») o con una hoja de confirmación.
6. **Los cinco destinos de la barra inferior** (Plano, Lista, Avance, Estadísticas, Más) o
   Alertas en lugar de Estadísticas.

Hasta que elija, no se escribe código del producto.
