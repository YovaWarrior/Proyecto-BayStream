# Lista de comprobación · Ensayo y prueba piloto con COMAR (la 0.4.2, 10.96 a 10.99)

**Para quién.** Carlos publica la 0.4.2 y corre el ensayo y el piloto; Yov revisa esta
lista y los comandos antes. La lista va por rol: **el muelle con el Honor** y **la oficina con la
laptop**. Cada paso dice qué hay que ver en pantalla y qué hacer si algo falla. Los textos
entre comillas son los rótulos exactos de la app.

**Qué es la 0.4.2.** La versión de la presentación final del 7-nov (10.95). Reemplaza a la
0.4.1, que Codex aceptó (10.83 y 10.84) y que no llegó a publicarse. Es `sprint-4` mezclado en
`master` (4.1): la 0.4.0, publicada el 28-oct (10.75), y encima de ella:
- **lo de la 0.4.1.** T-119, el mouse y el touchpad (10.77 y 10.80): la rueda mueve la silueta
  del buque; Ctrl + rueda y el pellizco del touchpad amplían el plano, con la celda bajo el
  puntero quieta; y la rejilla lleva una barra horizontal cuando la bahía no cabe. Y T-127, el
  listado en una operación publicada (10.79): mientras la operación esté abierta, la oficina
  agrega o reemplaza el listado de la agencia (1.17) y el muelle lo recibe solo (2.15). Cierra
  H2 (10.50);
- **T-129, el cierre al primer intento** (10.84 a 10.93): «Cerrar operación» ya no contesta
  «No se encontró la operación…» cuando la nube sí la cerró (O-128-2, 1.15);
- **T-130, el plan que le falta a una operación publicada** (10.85, hallazgo 1; 10.90 y 10.94):
  con la operación publicada y abierta, la oficina agrega el plano de llegada o el plan de carga
  que no estaba (1.18) y el muelle lo recibe solo (2.16); «Publicar operación» se niega si ya hay
  otra abierta del mismo buque, viaje y escala (1.19). Necesita las reglas de T-130, que se
  publican antes que los clientes (4.0);
- **T-131, el distintivo de rol** (10.86, 10.90 y 10.94): en la cabecera, «Oficina» con filo de
  oro o «Muelle» con filo de cobre; al tocarlo se abre «Nube y cuenta» (1.6 y 2.2);
- **T-132, el BAPLIE de salida fiel** (10.87): lo que sigue a bordo sale con los bytes del plan
  de carga; lo cargado parte de su grupo del plan, con lo del listado encima y los pesos en kilos
  enteros; y si el plan y el listado no dicen lo mismo de las peligrosas o de la temperatura de
  un contenedor, la oficina elige antes de guardar (1.13);
- **T-133, la marca no tapa el código** (10.85, hallazgo 7; 10.95): con marca, la celda sigue
  diciendo en grande su OR, su destino o su tipo, y la marca va debajo, con su ícono y su rótulo
  corto («Baja», «Hecho», «Revisar», «Cancel.»…; 2.3);
- **T-135, el nombre del archivo** (10.98): confirmar un plano en previo desde «Parámetros» ya
  no dice «Archivo "null" cargado correctamente», sino el nombre del archivo (O-134-4, 1.2).

**Codex la aceptó con reservas** (10.97; `docs/t134/aceptacion-codex.md`), sin el Honor: el
Honor tiene la app de Play, y una compilación local no se instala encima sin borrar su almacén.
Pasan la suite (2097 de 2097), `analyze`, las baterías de las reglas y los tres clientes, que
compilan y dicen 0.4.2 (8). Con los datos reales del piloto, la salida de T-132 deja las 503
celdas y los 358 grupos de paso idénticos, y es igual a la copia que Yov corrigió a mano. La
prueba de punta a punta de T-130 y el cierre de T-129 pasan contra el emulador, en Chrome. Lo
que no se pudo probar antes de publicar se prueba aquí, en 0.8 y en el ensayo:
- **Android con la nube.** El banco del emulador no llegó a sincronizar en la tablet (O-134-2):
  el primer Android contra Firebase es el Honor, en 0.8.
- **La banda del muelle con su distintivo** solo sale en un teléfono Android (2.2), y RNF-002
  con las marcas de T-133 se mide en el Honor (3).
- **Las esperas.** En la aceptación, el aviso de un plan agregado y el chip «Sin conexión»
  tardaron más de medio minuto (O-134-5): esta lista espera un minuto antes de «Reintentar».
- **El aviso «Archivo "null" cargado correctamente»** (O-134-4, desde la 3.1.0) lo corrigió
  T-135, y Codex lo revisó a mano en Windows, Chrome y Edge (10.98).

**El piloto del 1-nov (10.85)** encontró que una operación publicada no aceptaba el plan que
llegó después, y la carga se hizo con otra operación. Desde la 0.4.2, el plan que falta entra
después de publicar (1.18). Lo normal sigue siendo cargar los dos planos y el listado antes de
publicar (1.1 a 1.8).

**Lo que ya traía la 0.4.0.** Hasta el 28-oct se llamó 3.2.0: desde 10.74, la numeración va
en 0.x hasta la 1.0.0 del examen final. Lo ya publicado conserva su número en Git y en los
paquetes, y en la numeración nueva se lee así: la 3.0 es la 0.3.0, la 3.1 es la 0.3.1 y la
3.1.1 es la 0.3.2. Encima de la candidata del piloto (la 3.1.0, 10.35), la 0.4.0 lleva:
- **la 3.1.1** (T-122, publicada el 26-oct, 10.62; dentro del rediseño desde T-123, 10.65):
  la escala de un plano de llegada (H1), la sección «AGREGADOS» del listado (H3), la carga
  de un lleno del plan sin fila en el listado (H4), la par como bahía de referencia (H5), el
  vacío asignado en las búsquedas y en la Lista (H6) y el plano que se desplaza durante el
  arrastre (H7);
- **la entrega 1 del rediseño** (T-117 y T-118, aceptada en 10.46): la oficina con más
  plano (la columna central, el panel lateral fijo, oculto o flotante y las preferencias
  del equipo), el selector de modo en la cabecera y el resumen del modo en fichas;
- **la entrega 2** (T-121, aceptada en 10.55): Estadísticas, «El buque en corte»;
- **T-124** (aceptada en 10.67): la ficha de la bahía nombra el grupo de su par, Estadísticas
  cuenta cada impar con su par y «1 contenedor a bordo en la salida»;
- **T-125** (10.68): Estadísticas cuenta los vacíos asignados a una celda reservada, con una
  ficha que dice cuántos son, y cada sombra de 20 del plano lleva su propia clave (O-124-1).

Lo demás sigue siendo la 3.1.1 que ya se probó en campo, y la 0.4.0 es la del piloto del
1-nov. **Si el ensayo falla en algo serio, se vuelve a la 0.4.0** (4.5), que sigue en Git como
`v0.4.0` y con su MSIX en `build\t93`. Las reglas de T-130 no le estorban: la 0.4.0 trabaja
igual con ellas (3.8 de `docs/T130-RESULTADOS.md`; la batería de T-80 da 69 de 69 contra ellas).

**Datos.** En el ensayo y en 0.8, los sintéticos de T-100 (`T100_CARGA.edi`, `T100_LISTADO.xlsx`
y `T100_LLEGADA.edi`: BUQUE MANUAL, viaje M100, escala GTSTC), en copias con otro viaje. Se
generan desde la carpeta del repositorio con `dart tool/t100_sintetico.dart "$env:TEMP\t100-ensayo"`
y `python -I tool/t100_listado.py "$env:TEMP\t100-ensayo"`. En el piloto, los archivos reales de
la escala, que **no salen de la laptop ni del teléfono y no entran al repositorio**. Ninguna
captura muestra «Nube y cuenta», un correo ni un nombre de cuenta.

**Cada corrida contra Firebase de verdad lleva un viaje propio** (10.96). Un equipo que ya tiene
una operación publicada de un buque, viaje y escala la vuelve a encontrar al abrir el plano,
aunque esté cerrada, y no abre otra: «La operación de esta escala ya está cerrada y sus BAPLIE no
cambian. Para trabajar con este archivo, ábrelo como una operación nueva.» En una escala real es
lo correcto; en las pruebas, que repiten el buque, el viaje y la escala en los mismos equipos,
estorba. Por eso las copias cambian el viaje de `TDT`: P130 y P130N para 0.8, y E042 para el
ensayo. El listado sirve para cualquier viaje.

**Las copias** (10.83, 10.84 y 10.96), en la misma carpeta que los sintéticos:
- `T100_LISTADO_v2.xlsx`: el listado con la fila del OR 1 borrada en Excel (sección 8 de
  `docs/T127-RESULTADOS.md`), para 1.17 y 2.15.
- `ENSAYO_CARGA.edi` y `ENSAYO_LLEGADA.edi`, para el ensayo, con el viaje E042. El plan de carga
  trae además una celda reservada. `T100_CARGA.edi` no trae ninguna, porque sus diez vacíos llevan
  número, y «Asignar vacío» (2.6) solo asigna a una reserva. En la copia, el OR 16, que es un
  vacío, pierde su número, y su celda, 010-01-04, queda reservada, como en `T100_CARGA_RESERVA.edi`,
  la copia de la aceptación de la 0.4.1.
- `P130_LLEGADA.edi` y `P130N_CARGA.edi`, para 0.8: el plano de llegada con el viaje P130, y el
  plan de carga con el P130N, que la oficina agrega después de publicar (1.18).

El bloque las arma y comprueba la huella de cada archivo de partida y de cada copia:

```powershell
& {
$carpeta = "$env:TEMP\t100-ensayo"
$latin1 = [Text.Encoding]::GetEncoding(28591)
$fuentes = @{
  'T100_CARGA.edi' = '4ACF7539A1F26F25A73D56F368C979B2DA29DC9A435EF5414C93DACA2AB99E68'
  'T100_LLEGADA.edi' = '9573CFD78DCE494881BCAC0E4112F327F66188A92A236BBB298DEAFD43364D42'
}
$texto = @{}
foreach ($nombre in $fuentes.Keys) {
  $ruta = Join-Path $carpeta $nombre
  if (-not (Test-Path -LiteralPath $ruta)) { throw "Parar: falta $ruta; generar primero los sinteticos" }
  if ((Get-FileHash -LiteralPath $ruta -Algorithm SHA256).Hash -ne $fuentes[$nombre]) { throw "Parar: $nombre no es el sintetico esperado; avisar" }
  $texto[$nombre] = [IO.File]::ReadAllText($ruta, $latin1)
}
$viaje = 'TDT+20+M100+++'
$reserva = 'EQD+CN+MNLU0000827+45R1++2+4'
$copias = @(
  @{ Nombre = 'ENSAYO_CARGA.edi'; Fuente = 'T100_CARGA.edi'; Viaje = 'E042'; Reserva = $true; Huella = '7909D269C1024CB198BEE87781907E446E3E244B890974885E6A0A9C5005952B' }
  @{ Nombre = 'ENSAYO_LLEGADA.edi'; Fuente = 'T100_LLEGADA.edi'; Viaje = 'E042'; Reserva = $false; Huella = 'D17C7B02BA9ADA34C626547B435BDC890EB1455C341601679C586AA0C1BEF1BF' }
  @{ Nombre = 'P130_LLEGADA.edi'; Fuente = 'T100_LLEGADA.edi'; Viaje = 'P130'; Reserva = $false; Huella = '9EC5B815B98BE45E4C1DF08F94DD4315E2795C71D215C9988881FDE0A8C1E30E' }
  @{ Nombre = 'P130N_CARGA.edi'; Fuente = 'T100_CARGA.edi'; Viaje = 'P130N'; Reserva = $false; Huella = '4E12D8B0A36599D7A124E95948D895200425A288E1C8919F1592995F69380AFA' }
)
foreach ($c in $copias) {
  $t = $texto[$c.Fuente]
  if ([regex]::Matches($t, [regex]::Escape($viaje)).Count -ne 1) { throw "Parar: $($c.Fuente) no trae una sola vez el TDT del viaje M100" }
  $t = $t.Replace($viaje, "TDT+20+$($c.Viaje)+++")
  if ($c.Reserva) {
    if ([regex]::Matches($t, [regex]::Escape($reserva)).Count -ne 1) { throw 'Parar: no esta una sola vez el EQD del OR 16' }
    $t = $t.Replace($reserva, 'EQD+CN++45R1++2+4')
  }
  $ruta = Join-Path $carpeta $c.Nombre
  [IO.File]::WriteAllText($ruta, $t, $latin1)
  if ((Get-FileHash -LiteralPath $ruta -Algorithm SHA256).Hash -ne $c.Huella) { throw "Parar: $($c.Nombre) no salio igual a la de Yov; avisar" }
  "Listo: $($c.Nombre), viaje $($c.Viaje)"
}
}
```

La línea de `$carpeta` dice dónde están los sintéticos: si los generaste en otra carpeta, cámbiala.
Tiene que terminar con cuatro líneas «Listo».

---

## 0. Antes del ensayo (Carlos, con la laptop)

| # | Qué hacer | Qué hay que ver | Si falla |
|---|---|---|---|
| 0.1 | Publicar las reglas de T-130 (4.0) y después mezclar `sprint-4` en `master` y publicar los tres clientes, con los comandos de la sección 4 | El cotejo de 4.0 dice que lo publicado son las reglas de T-130 (`8B903949…`). La Web en `https://baystream-app.web.app/version.json` dice `"version": "0.4.2"` y `"build_number": "8"`; Windows instaló `BayStream_0.4.2.0.msix` (Configuración → Aplicaciones → BayStream 0.4.2.0); Play tiene el AAB 8 (0.4.2) en la prueba interna y el Honor lo actualizó por el enlace de prueba | No sigas con una versión a medias: los tres clientes tienen que ser la 0.4.2. Si una compilación no sale, el ensayo se hace con la 0.4.0 y se anota; las reglas de T-130 se pueden quedar |
| 0.2 | Guardar lo de la 0.4.0 para poder volver: `build\t93\BayStream_0.4.0.0.msix` (y su `.sha256`) en `C:\Proyectos\proyecto-baystream`, la etiqueta `v0.4.0` en Git y, de 4.0, la copia de las reglas de antes, `build\t130\reglas-antes.txt` en `C:\Proyectos\baystream-rediseno` | Los tres existen antes de instalar ningún cliente (`git tag --list v0.4.0` muestra la etiqueta) | Sin el MSIX, volver a Windows 0.4.0 exige recompilarlo desde `v0.4.0` con `tool\t93_msix.ps1 -Version 0.4.0.0`, como en 4.2 |
| 0.3 | Comprobar las cuentas en Firebase (consola, no desde la app): la de oficina y la de muelle existen y están **autorizadas**; las reglas publicadas son las de T-130, cotejadas en 4.0 (no se vuelve a publicar nada) | En la app, al iniciar sesión, «Cuenta autorizada», el rol correcto («Oficina» o «Muelle») y su distintivo en la cabecera (1.6 y 2.2) | «Cuenta sin autorizar: …»: el responsable la activa en la consola; la app no lo puede hacer. Sin cuenta autorizada no hay distintivo |
| 0.4 | En el Honor: letra del sistema en 1.0 (o la que use el planificador, pero anotada), brillo alto, Wi-Fi o datos encendidos, la app actualizada | El inicio con «Abre un plano de estiba» y «Seleccionar archivo»; la travesía no se dibuja en el teléfono (no sobra sitio): es lo esperado. Con un plano abierto, «Estad.» muestra «contenedores a bordo» y «Carga por bahía, de proa a popa» (desde la 0.4.0), y en Ajustes → Aplicaciones → BayStream la versión es la 0.4.2 | Si la versión no es la 0.4.2, no se actualizó: Play → prueba interna → actualizar |
| 0.5 | En la laptop: Windows con el MSIX 0.4.2.0 abierto una vez (tema «Seguir al sistema» o «Oscuro» en Parámetros; la oficina trabaja de noche) | El inicio con la marca, «Abre un plano de estiba» y, si sobra alto debajo, el buque navegando al pie | Si el instalador dice «Publisher: Unknown» o `0x800B010A`, el MSIX no se firmó con `CN=BayStream`: repetir 4.2 con la huella |
| 0.6 | Tener a mano en la laptop el plan de carga, el listado de la agencia (`.xlsx`) y el plano de llegada de la escala (en el ensayo y en 0.8, las copias de «Datos»); en el Honor no hace falta ningún archivo: se une a la operación publicada | | |
| 0.7 | Con la cuenta de oficina, en el inicio o en «Nube y cuenta», «Operaciones abiertas en la nube»: anotar cuáles hay y cerrar las de pruebas y pilotos anteriores (10.87, punto 3). Cada una se cierra desde el equipo que la tiene, o con «Unirse» desde la laptop, y después «Cerrar operación» (1.15). Las conocidas: MAGELLAN STAR · 26043S · GTSTC (la descarga del 1-nov; la de la carga, la 26043X, ya está cerrada), ECO BORA · 26042SB y BUQUE PRUEBA · T98 | No queda ninguna de un buque y una escala que se vayan a usar, salvo la de hoy. **Desde la 0.4.2 importa:** con una operación abierta de un buque en una escala, de cualquier viaje, la oficina no publica otra. Al abrir el plano nuevo, la banda propone agregarlo a la abierta («La escala GTSTC ya tiene una operación publicada (viaje 26043S) sin plan de carga: confirma para agregarlo.») o pide cerrar una (1.18) | Una operación cerrada no se reabre: si una no se reconoce, no cerrarla y avisar |
| 0.8 | Después de 0.1 y 0.7, la prueba de punta a punta de T-130 contra Firebase de verdad: la tabla de abajo, con la laptop de oficina y el Honor de muelle | Lo que dice cada paso de la tabla | Si en el paso 1 el plano abre en previo con «La escala GTSTC ya tiene una operación publicada…», o «Publicar operación» dice «Ya hay una operación publicada y abierta…», queda una de BUQUE MANUAL de antes: 0.7. Si en el paso 5 sale «La nube no aceptó el plan: …», las reglas publicadas no son las de T-130: 4.0. Si en el paso 7 el aviso no llega en un minuto, «Nube y cuenta» → «Reintentar», y se anota (en la aceptación tardó más de medio minuto, O-134-5). Si falla otro paso, anotar cuál y con qué texto, y en el piloto no usar 1.18: los dos planos van antes de publicar (1.7), como en la 0.4.0 |

### 0.8 · La prueba de punta a punta de T-130, contra Firebase de verdad

Es la tabla de 3.10 de `docs/T130-RESULTADOS.md`, con los clientes 0.4.2 en vez del banco del
emulador y las copias P130 de «Datos». Es una operación de prueba, BUQUE MANUAL · P130 · GTSTC,
que el paso 11 cierra. Los pasos de T-130 que no dependen de la nube (el plan que ya está y la
operación cerrada) los cubre la aceptación de Codex en el emulador, y aquí no se repiten.

| Paso | Dónde | Qué hacer | Lo que se tiene que ver |
|---|---|---|---|
| 1 | Laptop | «Seleccionar archivo» → `P130_LLEGADA.edi`; confirmar el perfil y la escala GTSTC; «Nube y cuenta» → «Publicar operación» | «Publicada» y «Al día» |
| 2 | Honor | Con la sesión de muelle (2.1): «Operaciones abiertas en la nube» → «Unirse» → «Abrir plano de llegada» → «Descarga» → descargar dos contenedores | «Hecho» en las dos celdas; en la laptop, «Avance» las cuenta |
| 3 | Honor | Modo avión **con el Wi-Fi apagado** (10.39) | «Sin conexión» en la banda; puede tardar más de medio minuto (O-134-5) |
| 4 | Laptop | «Más» → «Cargar archivo BAPLIE» → `P130N_CARGA.edi` | En previo, la banda: «La escala GTSTC ya tiene una operación publicada (viaje P130) sin plan de carga: confirma para agregarlo.» |
| 5 | Laptop | «Confirmar» → «Parámetros del buque» (escala GTSTC) → «Confirmar y ver el plano» | El diálogo «Agregar el plan de carga a la operación publicada», con «BUQUE MANUAL · P130 · GTSTC, publicada el <fecha del paso 1>, abierta, sin plan de carga.», ««P130N_CARGA.edi» declara el viaje P130N. La operación publicada es el viaje P130.» y «Se cargan 30 contenedores y 0 celdas reservadas; se descargan 0.» → «Agregar a la operación P130» → el aviso «Plan de carga agregado a la operación publicada de GTSTC: 30 contenedores y 0 reservas. El muelle lo recibe solo.» |
| 6 | Honor, sin red | Mirar «Carga» y «Nube y cuenta» | Sin aviso; «Carga» sin plan; en «Nube y cuenta», solo «Abrir plano de llegada» |
| 7 | Honor | Quitar el modo avión | «Al día»; el aviso «Plan de carga agregado por la oficina: 30 contenedores y 0 reservas.»; «Carga» muestra el plan; «Nube y cuenta» muestra «Abrir plan de carga»; las dos descargas siguen «Hecho» |
| 8 | Honor | «Carga» → «OR / últimos dígitos» → los últimos dígitos de un lleno → «Confirmar carga» (H4: todavía no hay listado) | «Carga registrada · <contenedor>»; en la laptop, «Avance» suma la carga a las dos descargas |
| 9 | Laptop | «Lista» → «Listado de la agencia» → «Elegir listado (.xlsx)» → `T100_LISTADO.xlsx` → «Confirmar e importar» | «Listado guardado en la operación publicada de GTSTC: 30 filas, revisión 1. El muelle lo recibe solo.»; en el Honor, «Listado actualizado por la oficina: 30 filas.» y los OR en las celdas |
| 10 | Laptop | «Lista» → «Generar BAPLIE de salida» (si sale «Datos por confirmar», «Usar el plan» en cada uno) → «Guardar BAPLIE de salida» | Las cifras de a bordo y de pendientes; «Comparar con la llegada»; «El archivo lleva el viaje P130N, el del plan de carga. La operación es la P130.»; el archivo se llama `BayStream_BUQUE MANUAL_P130N_salida.edi` y dice P130N en `TDT` |
| 11 | Laptop | «Nube y cuenta» → «Cerrar operación» | «Operación cerrada.» al primer intento (T-129) |
| 12 | Consola de Firebase, solo mirar | Firestore → `operations` → la de BUQUE MANUAL · P130 | `voyage: P130`; `sources.arrival_baplie`; `sources.loading_baplie` con `voyage: P130N`; `sources.export_list` con `revision: 1`; en su colección `sources`, `arrival_baplie-0`, `loading_baplie-0` y `export_list-r1-0`; `status: closed`. Nada se toca |

---

## 1. Ensayo · La oficina (laptop, Windows; la Web es igual salvo lo que se indica)

La oficina es la ventana de 600 dp de ancho o más: el riel a la izquierda (Plano, Lista,
Avance, Estadísticas, Más), el selector de modo en la cabecera y «Acciones» (⋮) en la
franja de la bahía (`DESIGN.md` 14). Con la cuenta de oficina, la cabecera lleva además el
distintivo «Oficina» (1.6).

| # | Qué hacer | Qué hay que ver | Si falla |
|---|---|---|---|
| 1.1 | «Seleccionar archivo» → el **plan de carga** (en el ensayo, `ENSAYO_CARGA.edi`) | El plano abre **en previo**: arriba la banda «Plano sin confirmar: perfil propuesto desde el archivo. Escala propuesta <puerto>.» con «Confirmar», y debajo «Peso por pila y tomas de refrigerado: sin evaluar hasta confirmar el perfil.» Son tres pasos y la rejilla ya se ve | Si sale «Este archivo no parece un BAPLIE: …» o «Versión BAPLIE no admitida: …», pedir la exportación 2.x a la agencia. Si no abre nada en 30 s, anotar y reintentar. Si la banda dice «La escala … ya tiene una operación publicada…», hay otra operación abierta de este buque en esta escala: 0.7 |
| 1.2 | «Confirmar» en la banda | Si el equipo ya guarda perfiles de otros buques, primero «Perfil del buque nuevo»: elegir «Proponer desde el archivo». Si ya hay uno con el mismo nombre, «Confirma la identidad del buque»; si la carga excede el perfil guardado, «Revisar ampliación». Después se abre «Parámetros del buque»: filas y niveles propuestos, la escala en «Puerto de esta escala» (la propuesta y, con un plano de llegada, los puertos de descarga con su cuenta, «GTSTC (7)»), el límite de apilamiento. **«No lo tengo» no viene marcado**: hay que escribir el límite del manual de estabilidad o marcarlo a mano | Si la escala propuesta no es la de la operación, elegir la correcta en «Puerto de esta escala» antes de confirmar. También se puede entrar por «Parámetros» (el ícono de la regla) → «Parámetros del buque»: la pantalla dice «Archivo: <nombre>» y el aviso final, el mismo de la banda (T-135). Si un aviso dice «null», anotarlo con el camino |
| 1.3 | «Confirmar y ver el plano» | Vuelve al **Plano** (no a la Lista), la cabecera dice «Publicado» y, a su lado, el selector de modo con «Contenido», «Orden» y «Carga» (el plan de carga no ofrece «Descarga»). Si no caben, van en el menú «Modo del plano: …» | Si vuelve a «Parámetros del buque», algo no cuadra (un mensaje en rojo dice qué): corregir y confirmar otra vez |
| 1.4 | «Lista» → «Listado de la agencia» → «Elegir listado (.xlsx)» → el listado (en el ensayo, `T100_LISTADO.xlsx`) | La página muestra el archivo, «N filas en M agencias · X llenos · Y vacíos», las equivalencias propuestas («Tipo 40ST → 42G1»…) y el cruce «X de X llenos cruzan con el plan». La fila «TOTAL» sale bajo «1 fila sin entender:»: es normal. Las filas bajo «AGREGADOS» se cuentan aparte, como la agencia «AGREGADOS» (H3) | Si a una equivalencia le falta el código («→ ?»), elegirla con el lápiz («Corregir <código>»); el botón lo pide con «Falta elegir N equivalencias antes de importar…». Si «N contenedores del plan no están en el listado» es alto, revisar el listado con la agencia antes de importar |
| 1.5 | «Confirmar e importar», en el pie fijo de la página. No hace falta esperar a que se apague el aviso «Archivo "<nombre>" cargado correctamente»: flota por encima del pie. **Lo normal es antes de publicar (1.8)**; después, ver 1.17 | «Listado guardado en la operación de <escala>: N filas.» y el aviso «Listado importado.» En el Plano, en «Orden» y en «Carga», cada celda de carga lleva su OR | Si el botón está apagado, falta una equivalencia: ver 1.4. Si dice «Fila N: …», corregir el Excel y volver a importar. Con la operación ya publicada, el listado también entra: ver 1.17 |
| 1.6 | Icono de la nube → **«Nube y cuenta»** → iniciar sesión con la cuenta de oficina | Nombre, rol «Oficina» y «Cuenta autorizada». «Operación de la escala abierta» con buque, viaje y puerto, el estado «Solo en este dispositivo» y «Fuentes: carga · listado». En la cabecera, a la derecha del buque y el viaje, el distintivo «Oficina» con filo de oro: completo, solo el círculo con el ícono, o ninguno si no cabe, porque los controles mandan (a 1366 con la letra a 2.0 no va; `DESIGN.md` 13.12). En la Web de un teléfono va en la barra de arriba. Tocarlo abre «Nube y cuenta» | «Sesión vencida: …» o «Tu cuenta no está autorizada…»: ver 0.3. Sin red: «Sin conexión», esperar la red. Si el distintivo dice «Muelle», la sesión es la de muelle: cerrarla y entrar con la de oficina |
| 1.7 | «Más» → «Cargar archivo BAPLIE» → el **plano de llegada** (en el ensayo, `ENSAYO_LLEGADA.edi`). Lo normal es antes de publicar (1.8); si llega después, ver 1.18 | Con la misma escala confirmada, **abre publicado sin previo** (regla 7.2 de `DESIGN.md`): «Publicado», y el selector de modo ofrece «Descarga» y «Carga». La Lista resume «N se descargan · M se cargan · K de paso», y «Nube y cuenta» dice «Fuentes: llegada · carga · listado» | Si abre en previo con «El archivo sale de X rumbo a Y: confirma la escala.», la escala propuesta no es la confirmada: «Confirmar» y elegir la escala de la operación. Si la banda dice «La escala … ya tiene una operación publicada…», hay otra operación abierta de este buque en esta escala: 0.7 |
| 1.8 | «Publicar operación», con los dos planos y el listado ya cargados (lo que falte entra después: 1.17 y 1.18) | El estado pasa a «Publicada»; la nube de la cabecera, a «Nube y cuenta · Al día» (su descripción) y la cabecera de «En vivo», a «Al día». Desde aquí todo lo registrado antes se queda local y lo nuevo sube | Si dice «La nube no aceptó la publicación: revisa que la cuenta sea de oficina y esté activa.», las reglas o la cuenta: consola. **No publicar reglas con `firebase deploy` a secas** (guía del cierre). Si dice «Ya hay una operación publicada y abierta de …», ver 1.19 |
| 1.9 | «Avance» (en el riel) | Descarga, carga de llenos y vacíos, cancelados, conflictos y el último movimiento, por bahía y total; las impares van con su par (la 21 y la 23, en la 22); se actualiza solo cuando el muelle registra | Si no cambia cuando el muelle registra (paso 2.3), mirar el estado de la nube: «Enviando N» o «Sin conexión» en «En vivo» o en la nube de la cabecera, en alguno de los dos |
| 1.10 | «Plano», con la ventana a 1200 de ancho o más | El panel «En vivo» a la derecha, con el estado de la nube arriba («Al día») y una fila por movimiento: «Bajado · Muelle», debajo el contenedor y la celda, y «ahora». Lo que acaba de llegar sale en **naranja** 1.5 s y la bahía destella en la silueta | Con menos ancho no hay panel fijo: el botón del panel lateral de la cabecera («Mostrar el panel lateral») o el borde derecho lo abren flotante. Sin panel a la vista, el anuncio lo da el lector de pantalla. No es un fallo |
| 1.11 | Cuando el muelle pida un cambio (2.10): en el Plano, «Acciones» (⋮) → «Bandeja de cambios (1)» | La solicitud «Pendiente» con quién la pide («Solicita <nombre> · <fecha>»), «OR N · contenedor: celda → celda» y «Motivo: …». «Aprobar» y «Rechazar» piden «Motivo obligatorio» | «Se necesita una cuenta autorizada y una operación publicada.»: la sesión o la publicación (1.6, 1.8) |
| 1.12 | «Aprobar» (o «Rechazar») con motivo | La tarjeta pasa a «Aprobada» (el contenedor cambia de celda en el plan) o «Rechazada»; el muelle lo ve sin recargar | Si queda «En conflicto», la celda ya está ocupada: rechazar y pedir otro cambio |
| 1.13 | Al final de la escala: «Lista» → «Generar BAPLIE de salida» | «N contenedores a bordo en la salida.» («1 contenedor…» si es uno) y «Pendientes: X de carga y Y de descarga.», los cancelados vigentes y «Comparar con la llegada». Si se cargaron llenos sin fila en el listado (2.8), «N llenos van con los datos del plan de carga porque no tienen fila en el listado: …». Si el plan y el listado no dicen lo mismo de las peligrosas o de la temperatura de un contenedor, **«Datos por confirmar»**: por cada uno, «OR N · <contenedor> · Mercancías peligrosas» (o «· Temperatura del refrigerado»), lo que dice cada fuente («El plan dice UN 2902; el listado, UN 2903») y «Usar el plan» / «Usar el listado». Más abajo, «Filas del listado que no cargaron (N)», cada una con su motivo, y «Copiar filas no cargadas». Si el plan de carga declara otro viaje que la operación (1.18): «El archivo lleva el viaje X, el del plan de carga. La operación es la Y.» | Si dice «La escala no tiene una operación guardada…», volver a abrir el plan de carga y confirmar la escala. «Guardar BAPLIE de salida» y «Comparar con la llegada» se quedan apagados hasta elegir en cada «Datos por confirmar»: se elige con la declaración de peligrosas o la orden del refrigerado a la vista. Bajo «Datos que impiden guardar», el texto dice la fila y el campo del listado: corregir el Excel y volver a importarlo (1.17). Los «Avisos de la salida» no impiden guardar, pero las peligrosas se verifican con su declaración |
| 1.14 | «Guardar BAPLIE de salida» | Windows: el diálogo «Guardar BAPLIE de salida» con `BayStream_<buque>_<viaje>_salida.edi`, con el viaje del plan de carga; al guardar, «Exportación BAPLIE completada». En la Web, el navegador lo descarga | Guardar en una carpeta de la laptop; el archivo no se sube a ningún lado. Si el botón está apagado, falta elegir en «Datos por confirmar» o corregir «Datos que impiden guardar» (1.13) |
| 1.15 | «Nube y cuenta» → «Cerrar operación»; en el diálogo «Cerrar la operación», «Cerrar operación» | «Operación cerrada.» al primer intento, y el estado «Publicada y cerrada»; ya no admite movimientos | Solo al terminar de verdad: una operación cerrada no se reabre. Sin red, a los 45 s, «Sin respuesta de la nube: cerrar requiere red. Revisa la red e inténtalo de nuevo.»: repetir con red. Si dice «No se encontró la operación para cerrarla en este dispositivo o en la nube. Vuelve a abrir «Nube y cuenta» e inténtalo de nuevo.», es O-128-2, que la 0.4.2 corrige (T-129): anotarlo con la hora y repetir como antes, cerrando y abriendo «Nube y cuenta» hasta «Operación cerrada.» No se pierde nada |
| 1.16 | Cuando el muelle asigne un vacío (2.6 y 2.7): «Estadísticas» (en el riel) | «N contenedores a bordo» y, debajo, «Incluye: 1 vacío asignado a una celda reservada, que el archivo no trae» (con más, «Incluye: N vacíos asignados a celdas reservadas, …»); la cifra, «vacíos» y la bahía suben con cada vacío asignado. «Carga por bahía, de proa a popa» cuenta cada impar con su par. En «Ver como tabla», la fila «Vacíos asignados». Es lo que cuenta la Lista (T-125) | Si un vacío asignado no sube la cifra o la ficha no sale, anotarlo con la hora. Que las cifras se muevan durante la operación es lo esperado (10.68) |
| 1.17 | Con la operación ya publicada y abierta, si la agencia manda el listado tarde o corregido: «Lista» → «Listado de la agencia» → «Elegir listado (.xlsx)» (o «Importar otro listado (.xlsx)») → el listado nuevo (en el ensayo, `T100_LISTADO_v2.xlsx`). Las equivalencias y el cruce, como en 1.4 | Si ya hay movimientos, antes de confirmar sale la tarjeta «Lo ya operado con el listado nuevo»: «N contenedores ya cargados no están en el listado nuevo» y «M vacíos asignados cambian de grupo», con la lista de cada uno. Los movimientos no se pierden ni cambian. «Confirmar e importar» → «Listado guardado en la operación publicada de <escala>: N filas, revisión R. El muelle lo recibe solo.» (T-127) | «La nube no aceptó el listado: …» no cambia nada local: revisar la cuenta (0.3) y que las reglas sean las de T-130 (4.0), y volver a intentar. «Sin conexión con la nube: …»: esperar la red. Con la operación cerrada (1.15), el listado ya no cambia |
| 1.18 | Con la operación ya publicada y abierta, si el plano de llegada o el plan de carga llega después: «Más» → «Cargar archivo BAPLIE» → el plan que falta | Abre **en previo**, con la banda «La escala <escala> ya tiene una operación publicada (viaje <n>) sin <plan de carga o plano de llegada>: confirma para agregarlo.» Si este equipo todavía no tiene el perfil del buque, la banda es la de siempre («Plano sin confirmar…»), y la operación se busca al confirmar los parámetros. → «Confirmar» → «Parámetros del buque», con la escala de la operación (y «Tipo de BAPLIE», si lo pregunta) → «Confirmar y ver el plano» → el diálogo «Agregar el <plan> a la operación publicada»: «<buque> · <viaje> · <escala>, publicada el <fecha>, abierta, sin <plan>.», las cifras («Se cargan N contenedores y M celdas reservadas; se descargan K.») y, si el archivo declara otro viaje, ««<archivo>» declara el viaje X. La operación publicada es el viaje Y.» → «Agregar a la operación <viaje>» → el aviso «<Plan> agregado a la operación publicada de <escala>: … El muelle lo recibe solo.» Los movimientos ya registrados no cambian, y «Nube y cuenta» dice las fuentes, con el viaje del plan agregado si difiere («Fuentes: llegada · carga (viaje X) · listado r1») | «Cancelar» no agrega nada, y el plano sigue en previo. La llegada y la carga pueden traer viajes distintos: si la operación del diálogo es la de esta escala, «Agregar a la operación <viaje>»; si es de una escala anterior, «Cancelar» y 0.7. Si la banda dice «…que este equipo no tiene. Únete en «Nube y cuenta» y vuelve a abrir el plan para agregarlo.», unirse y repetir; si dice «Hay N operaciones publicadas y abiertas…», cerrar la que no corresponde (0.7) y repetir. «La operación publicada de esta escala ya tiene el <plan> («<archivo>»)…»: ese plan ya está, y un BAPLIE publicado no se reemplaza. «La nube no aceptó el plan: …»: la cuenta (0.3) o las reglas (4.0); nada local cambió |
| 1.19 | «Publicar operación» cuando ya hay otra abierta del mismo buque, viaje y escala (la publicó otro equipo, o quedó de un ensayo) | No publica: «Ya hay una operación publicada y abierta de <buque> · <viaje> · <escala>, publicada el <fecha>. No se publica otra: únete a ella desde «Operaciones abiertas en la nube».» La nube sigue con una sola | Si es la de hoy, «Unirse» a ella en «Operaciones abiertas en la nube» y seguir ahí (1.18 si le falta un plan). Si es de un ensayo, cerrarla (0.7) y publicar otra vez. Una oficina con la 0.4.0 no lo comprueba (5) |

---

## 2. Ensayo · El muelle (Honor, Android)

| # | Qué hacer | Qué hay que ver | Si falla |
|---|---|---|---|
| 2.1 | Icono de la nube → «Nube y cuenta» → iniciar sesión con la cuenta de muelle | Rol «Muelle», «Cuenta autorizada». En el inicio, «Operaciones abiertas en la nube (1)» | Ver 0.3. Sin red: «Sin conexión con la nube: unirse requiere red. Conéctate e inténtalo de nuevo.» Si salen más de una, sobra alguna: 0.7 |
| 2.2 | «Operaciones abiertas en la nube» → «Unirse» → «Abrir plano de llegada» | El plano **sin elegir ningún archivo**: la banda azul de la marca arriba con el buque, «Viaje <n> · <escala>», el chip «Al día», el distintivo del muelle con filo de cobre y los segmentos «Descarga / Carga»; abajo la barra Plano · Lista · Avance · Estad. · Más. Con la letra a 1.0, el distintivo es el círculo con el ícono, a la izquierda de los segmentos; con la letra a 2.0 no va, para que «Descarga» y «Carga» quepan enteros (10.94). Tocarlo abre «Nube y cuenta» | Si no aparece la operación, la oficina no publicó (1.8). Si el plano abre en previo, la operación trae un perfil distinto: anotar y usar «Confirmar». Si con la letra a 1.0 no hay distintivo, la sesión no es una cuenta autorizada: 2.1 |
| 2.3 | «Descarga» → tocar una celda que dice **«Baja»** debajo de su destino o su tipo (T-133) | La celda sale de su sitio en **naranja**, con la flecha (en el muelle, «Bajando» va sin rótulo), y abajo, sobre las cifras de la franja, el aviso «Descargado · <contenedor> · <celda>» con «Deshacer» durante 6 s (con la letra grande, «Descargado · <contenedor>»); después la celda dice su destino, con «Hecho» y la palomita debajo. En la laptop, «Avance» y «En vivo» lo muestran en segundos | Si no registra: «No se registró: …» dice la causa (operación cerrada, sesión); con la letra grande sale «No se registró.» y «Ver» la muestra. Si el aviso pisa una celda o un control, anotarlo como fallo (que tape las cifras es lo esperado, 10.30). Si la celda no es «Baja» sino «Paso», es carga de paso: ver 2.5 |
| 2.4 | Tocar «Deshacer» en el aviso | La celda vuelve a «Baja»; el movimiento queda anulado «Marcado por error» (no se borra). Pasado el aviso: tocar la celda → «Deshacer la descarga» en el detalle | |
| 2.5 | Tocar una celda **«Paso»** | La pregunta «Re‑estiba»: «<contenedor> no se descarga en <escala>: va a <puerto>…» con «Registrar re‑estiba». Al confirmar, la celda queda con «Re‑est.» debajo de su destino y el aviso «Re‑estiba registrada · …» | Si fue un toque por error: «Cancelar» |
| 2.6 | «Carga» → «Acciones» (⋮) → «Asignar vacío» | «Vacíos del listado»: «OR N · <contenedor>» con tipo, destino, línea y tara. Al tocar uno, el formulario «Asignar vacío» propone la celda (primero las de su grupo en la bahía) y pide tara real, hora y marchamo opcionales. En el ensayo con `ENSAYO_CARGA.edi`, el vacío que se asigna es el OR 16, a la reserva 010-01-04: los otros vacíos traen número en el plan | Sin listado, «Asignar vacío» está apagado y la línea del resumen dice «Sin listado de agencia: los llenos se cargan por su número; los vacíos esperan el listado»: falta el listado en la oficina, 1.5 antes de publicar o 1.17 después, y llega solo (2.15) |
| 2.7 | «Confirmar carga» | «Carga registrada · OR N» con «Deshacer»; la celda sale en naranja, con la flecha («Subiendo» va sin rótulo), y queda cargada con su OR. Una celda con conflicto dice su OR y, debajo, «Revisar»; una cancelada, «Cancel.» (T-133) | Si la celda sigue ocupada por el de llegada: «Marcar su descarga y cargar» → «Descarga y carga registradas · OR N» |
| 2.8 | Cargar un lleno: «OR / últimos dígitos» (en la tira del pie) → escribir el OR o los últimos dígitos → «Confirmar carga» | La búsqueda «Confirmar carga por OR o contenedor»; después, igual que 2.7. Un lleno del plan sin fila en el listado sale como «<contenedor> · sin OR en el listado» y se carga por su número («Carga registrada · <contenedor>», H4). El detalle de una celda cargada ofrece «Deshacer carga» con motivo | «No hay coincidencias disponibles.»: el OR no está en el listado o ya se cargó. Un vacío sin fila no se ofrece: espera el listado |
| 2.9 | «Deshacer» en el aviso de una carga | El OR vuelve a estar pendiente y la celda, vacía con su contorno | |
| 2.10 | «Acciones» (⋮) → «Solicitudes de cambio (0)» → «Pedir cambio» | El formulario: «Objeto 1: OR, contenedor o reserva», «Intercambiar dos contenedores» (viene activado) o «Destino BBB-RR-TT», y «Motivo obligatorio» → «Enviar solicitud». La solicitud queda «Pendiente» y la celda destino lleva un borde punteado con el icono de pedir cambio (el lector dice «Solicitud pendiente en <celda>») | «Se necesita una cuenta autorizada y una operación publicada.»: la sesión del teléfono o la publicación (1.8). El objeto sigue en su celda hasta que la oficina apruebe |
| 2.11 | Cuando la oficina decida (1.12) | La solicitud pasa a «Aprobada» o «Rechazada» sin recargar; si se aprobó, el OR cambia de celda en «Carga» | |
| 2.12 | Atrás (el botón del sistema) en el plano | **Un toque**: arriba, sobre el plano, la advertencia «Toca Atrás otra vez para volver al inicio.» durante 2 s, aunque abajo siga el aviso de un movimiento; el plano sigue. **Dos toques seguidos**, dentro de esos 2 s: el inicio, con el viaje en los recientes. Tocar el reciente lo reabre publicado, con la operación | Un toque nunca saca del plano: si sale, anotarlo como fallo. Con una hoja abierta («Más», el detalle), Atrás solo la cierra, y el siguiente Atrás vuelve a advertir |
| 2.13 | Sin red: modo avión **con el Wi-Fi apagado** (10.39) → registrar una descarga | El chip de la banda pasa a «Sin conexión» (puede tardar más de medio minuto, O-134-5) y la app sigue registrando. Al volver la red, «Enviando» y después «Al día»; la oficina lo recibe. Cuántos esperan lo dice «Nube y cuenta» | Si al volver la red el chip dice «Revisar», mirar «Nube y cuenta»: con «Sesión vencida: …», iniciar sesión otra vez; la cola se envía sola |
| 2.14 | «Más» | «Alertas de estiba» (con su cuenta), «Tapas en la operación», «Orden de descarga», «Listado de la agencia», «Comparar con otro BAPLIE…», «Exportar PDF», «Exportar CSV» y «Exportar JSON», «Nube y cuenta», «Parámetros», «Cargar archivo BAPLIE», «Viajes recientes», «Perfiles guardados» y «Cerrar el plano» | «Cerrar el plano» con el viaje publicado limpia este dispositivo; se vuelve a entrar desde los recientes o uniéndose |
| 2.15 | Cuando la oficina agregue o reemplace el listado (1.17), con red y sin tocar nada | El aviso «Listado actualizado por la oficina: N filas.» durante 6 s; los OR aparecen en las celdas y «OR / últimos dígitos» los ofrece. Lo ya cargado sigue en su celda: un lleno cuya fila ya no está se queda cargado, sin OR, y en la salida va con los datos del plan (1.13) | Sin red, el muelle sigue con el listado anterior y lo baja al volver la red (2.13). Si en un minuto no llega, «Nube y cuenta» → «Reintentar», o cerrar y abrir el plano, y anotarlo. Un muelle con la 0.4.0 no lo recibe (5) |
| 2.16 | Cuando la oficina agregue el plan que faltaba (1.18), con red y sin tocar nada | El aviso «Plan de carga agregado por la oficina: N contenedores y M reservas.» durante 6 s; «Carga» muestra lo pendiente del plan, «OR / últimos dígitos» lo ofrece y, con listado, «Asignar vacío» también. Lo ya descargado sigue «Hecho». Si lo agregado es el plano de llegada: «Plano de llegada agregado por la oficina: N se descargan.» con «Abrir», que abre ese plano para «Descarga». En «Nube y cuenta», «Abrir plan de carga» o «Abrir plano de llegada» | Sin red, llega al volver la red (2.13). Si en un minuto no llega, «Nube y cuenta» → «Reintentar», y anotarlo. Un muelle con la 0.4.0 no se entera: sigue con su plano, y sus movimientos se aceptan (5) |

---

## 3. El día del piloto

1. **Antes de zarpar nada:** 0.3 a 0.7 repetidos esa mañana (en 0.7, ninguna operación abierta
   de ese buque en esa escala); en la laptop, 1.1 a 1.8 con los archivos reales; en el Honor,
   2.1 y 2.2. Si 2.2 no muestra el plano con la banda y «Al día», el piloto se hace con la 0.4.0
   (4.5) y se anota por qué. Con la 0.4.0, los dos planos van antes de publicar.
2. **Durante la descarga:** el muelle hace 2.3 a 2.5 con cada contenedor; la oficina
   mira 1.9 y 1.10. Un toque por error se deshace con «Deshacer» (6 s) o desde el
   detalle; nada se borra.
3. **Durante la carga:** 2.6 a 2.9 y, si hace falta, 2.10 y 1.11 a 1.12; la oficina mira
   1.9 y 1.16. Si el listado llega tarde o corregido: 1.17 en la oficina y 2.15 en el
   muelle. Si un plan llega después de publicar: 1.18 en la oficina y 2.16 en el muelle.
4. **Si se cae la red** en el muelle: seguir registrando (2.13); «Nube y cuenta» dice
   cuántos esperan. No cerrar sesión ni la app.
5. **Al terminar:** 1.13 a 1.15. El BAPLIE de salida se guarda en la laptop. Si la página trae
   «Datos por confirmar», se elige con la declaración de peligrosas o la orden del refrigerado.
6. **Qué anotar para Yov** (sin capturas de cuentas ni datos reales): la versión de cada
   equipo, la hora de cada paso, cualquier texto en rojo (con su frase exacta), cualquier toque
   que no hizo lo esperado, el tiempo que tardó la primera visualización en el Honor (RNF-002:
   tres pasos, menos de 30 s), si alguna bahía con muchas marcas se dibujó o se desplazó con
   tirones (T-133), y si la letra del teléfono era 1.0 u otra.

---

## 4. Compilación y publicación (Carlos; Yov revisa antes)

Las versiones de la 0.4.2, una por cliente. Lo publicado antes, la 0.4.0 de 10.75, es Web
0.4.0+6, MSIX 0.4.0.0 y AAB 6; la 0.4.1 (0.4.1+7) se aceptó y no se publicó:

| Cliente | Versión | Por qué |
|---|---|---|
| Android (AAB, prueba interna de Play) | `0.4.2`, `versionCode` **8** | Play exige que el `versionCode` suba: el último subido es el 6. El 7 era de la 0.4.1, que no se subió; no se repite, para que cada número sea una sola compilación |
| Windows (MSIX) | **0.4.2.0** | Es mayor que la 0.4.0.0, así que se instala encima, sin desinstalar (4.2) |
| Web (Hosting) | `0.4.2`, compilación **8** | `version.json` lo deja visible |

`pubspec.yaml` dice `version: 0.4.2+8` y `msix_version: 0.4.2.0` (T-134); los comandos
lo repiten en la línea de comandos para no depender de ello. `pubspec.lock` no cambia.

**El orden importa:** primero las reglas de T-130 (4.0), después la mezcla (4.1) y los tres
clientes (4.2 a 4.4). Con las reglas de antes, la 0.4.2 no puede agregar un plan a una
operación publicada (1.18) y, si las de antes son las de T-80, tampoco revisar el listado
(1.17); lo dice sin cambiar nada. La 0.4.0 trabaja igual con las nuevas.

**4.2, 4.3 y 4.4 corren Flutter:** mientras tanto, ningún agente corre Flutter en la laptop
(`AGENTS.md`, «Trabajo en paralelo», 3).

**Los bloques con comprobaciones van dentro de `& { … }`** (los cotejos de 4.0, la mezcla de
4.1, la instalación de 4.2, 4.4, y la vuelta de las reglas y de Windows en 4.5). Según cómo se
peguen, PowerShell puede correr cada línea por su cuenta, y entonces un `throw` no detiene las
que siguen. Dentro de las llaves, el bloque entero se detiene en la primera comprobación que
falle: en 4.4, por ejemplo, ya no llega a `firebase deploy`.

### 4.0 Las reglas de T-130, antes que los clientes (desde `C:\Proyectos\baystream-rediseno`)

Se publican **desde la consola, nunca con `firebase deploy`** (sección 10 de
`docs/T130-RESULTADOS.md`), después de la aceptación de Codex. Llevan dentro las de T-127 (la
batería de T-127 da 31 de 31 contra ellas). Lo publicado hoy deberían ser todavía las de T-80:
las de T-127 iban con la 0.4.1, que no se publicó. El paso 2 acepta cualquiera de las dos y dice
cuál era. El cotejo es `tool/t113_reglas.mjs`: sale con 0 si lo publicado es idéntico a la
propuesta, sin contar el fin de línea ni los espacios al final de cada línea.

1. En Chrome, `https://console.firebase.google.com` → **baystream-app** → **Firestore
   Database** → pestaña **Reglas**.
2. **El respaldo de lo publicado:** en el editor de reglas, Ctrl + A y Ctrl + C, y pegarlo en
   un archivo nuevo, `C:\Proyectos\baystream-rediseno\build\t130\reglas-antes.txt` (VS Code,
   «Guardar como», UTF-8). Cotejarlo con las de T-80 (publicadas desde 10.108 de `SPRINT-3.md`)
   y con las de T-127:

   ```powershell
   & {
   Set-Location -LiteralPath C:\Proyectos\baystream-rediseno
   if (-not (Test-Path -LiteralPath build\t130\reglas-antes.txt)) { throw 'Parar: falta build\t130\reglas-antes.txt; guardar primero la copia de la consola' }
   node tool/t113_reglas.mjs build/t130/reglas-antes.txt build/t130/cotejo-antes-t80 | Out-Null
   $t80 = $LASTEXITCODE
   node tool/t113_reglas.mjs build/t130/reglas-antes.txt build/t130/cotejo-antes-t127 docs/T127-firestore.rules.propuesta | Out-Null
   $t127 = $LASTEXITCODE
   if ($t80 -ne 0 -and $t127 -ne 0) { throw 'Parar: lo publicado no son las reglas de T-80 ni las de T-127; no publicar nada y avisar' }
   if ($t80 -eq 0) { 'Lo publicado son las reglas de T-80 (7E57F227...): se puede seguir' }
   if ($t127 -eq 0) { 'Lo publicado son las reglas de T-127 (FC17842C...): se puede seguir' }
   }
   ```

   El detalle de cada cotejo queda en `reglas-cotejo.json`, dentro de `build\t130\cotejo-antes-t80`
   y de `build\t130\cotejo-antes-t127`.
3. Abrir `docs\T130-firestore.rules.propuesta` en VS Code, Ctrl + A y Ctrl + C. En el editor de
   la consola, Ctrl + A y pegar encima. No debe quedar ninguna marca roja, y la primera línea
   sigue siendo `rules_version = '2';`. **Publicar.** Rige en menos de un minuto.
4. **El cotejo de lo publicado:** en la consola, Ctrl + A y Ctrl + C, y pegarlo en
   `build\t130\reglas-publicadas.txt` (UTF-8). Después:

   ```powershell
   & {
   Set-Location -LiteralPath C:\Proyectos\baystream-rediseno
   node tool/t113_reglas.mjs build/t130/reglas-publicadas.txt build/t130/cotejo-publicadas docs/T130-firestore.rules.propuesta
   if ($LASTEXITCODE -ne 0) { throw 'Parar: lo publicado no es identico a la propuesta de T-130; corregir en la consola y cotejar otra vez' }
   'Publicadas y cotejadas: las reglas de T-130'
   }
   ```

   La salida dice `"equal": true`, y la huella normalizada tiene que ser
   `8B9039496CCCDA9FBC1412CC1F8610B3183D58FB4BA779EFB0C0C7D920EEFF71`. No hace falta tocar
   índices: las consultas nuevas usan el índice de un solo campo, que Firestore crea solo.

Si algo falla con las reglas nuevas, se vuelve atrás con `reglas-antes.txt` (4.5).

### 4.1 La mezcla (desde `C:\Proyectos\proyecto-baystream`, la carpeta de siempre)

`master` está en `be532ab` («Sprint 4: la 0.4.0, mezcla de sprint-4 a master», con la
etiqueta `v0.4.0`), con el mismo árbol que `7647741` de `sprint-4`; la 0.4.1 no se mezcló.
`C:\Proyectos\baystream-rediseno` es otro árbol de trabajo del mismo repositorio, así que
`sprint-4` es la misma rama local. La mezcla no puede tener conflictos, porque `master` no
cambió desde la 0.4.0: **si Git marca alguno, o dice que la mezcla sobrescribiría cambios
locales, parar y avisar antes de resolver nada.** Desde la 0.4.0, `sprint-4` no toca ningún
`.docx`, `.pdf`, `.pptx` ni `.xlsx`, así que los documentos de Carlos modificados en esa carpeta
se quedan como están.

```powershell
& {
Set-Location -LiteralPath C:\Proyectos\proyecto-baystream
if ((git branch --show-current) -ne 'master') { throw 'Parar: la carpeta no esta en master' }
if ((git rev-parse HEAD) -notlike 'be532ab*') { throw 'Parar: master no esta en be532ab' }
if (-not (git show sprint-4:pubspec.yaml | Select-String -Pattern '^version: 0\.4\.2\+8' -Quiet)) { throw 'Parar: sprint-4 todavia no trae la 0.4.2' }
git diff --quiet fd39951 sprint-4 -- lib test integration_test tool android windows web assets pubspec.yaml pubspec.lock
if ($LASTEXITCODE -ne 0) { throw 'Parar: sprint-4 trae codigo que Codex no reviso (10.98); avisar' }
git merge --no-ff --no-commit sprint-4
if ($LASTEXITCODE -ne 0) { throw 'Parar: la mezcla no salio limpia; no resolver nada' }
git commit -m "Sprint 4: la 0.4.2, mezcla de sprint-4 a master"
if ($LASTEXITCODE -ne 0) { throw 'Parar: el commit de la mezcla no salio' }
git tag -a v0.4.2 -m "BayStream 0.4.2, el plan que falta en una operacion publicada, el distintivo de rol y la salida fiel (Sprint 4)"
git push origin master
git push origin v0.4.2
git log --oneline -1
}
```

Las cuatro comprobaciones del principio detienen el bloque si la carpeta no está en `master`,
si `master` no está en `be532ab`, si `sprint-4` todavía no trae la 0.4.2 o si trae código que
Codex no revisó: desde `fd39951`, T-135, el último código que revisó (10.98), solo pueden cambiar
documentos. La mezcla se
detiene antes del commit («stopped before committing as requested»): es lo esperado, y el
`git commit` la cierra. La última línea tiene que mostrar «Sprint 4: la 0.4.2, mezcla de
sprint-4 a master». Después, la carpeta queda en `master` con la 0.4.2, y `v0.4.0` sigue en
Git para volver (4.5). El rediseño sigue en `C:\Proyectos\baystream-rediseno`, en
`sprint-4`.

### 4.2 Windows (MSIX), desde esa carpeta en `master`

La 0.4.2.0 se instala **encima de la 0.4.0.0, sin desinstalar** (o de la 0.4.1.0, si la
candidata llegó a instalarse): Windows actualiza el paquete, y los datos siguen en
`%LOCALAPPDATA%\BayStream`, fuera de él (10.75). El bloque comprueba lo instalado, compila,
verifica la firma y copia los datos, y solo entonces instala; si algo falla antes, no toca
nada. Va con la app cerrada:

```powershell
& {
Set-Location -LiteralPath C:\Proyectos\proyecto-baystream
if (Get-Process -Name baystream -ErrorAction SilentlyContinue) { throw 'Parar: cierra BayStream antes de seguir' }
$h = @(Get-ChildItem Cert:\CurrentUser\My | Where-Object Subject -eq 'CN=BayStream')
if ($h.Count -ne 1) { throw "Parar: hay $($h.Count) certificados CN=BayStream y tiene que haber 1" }
$app = @(Get-AppxPackage | Where-Object Name -like '*baystream*')
if ($app.Count -ne 1) { throw "Parar: hay $($app.Count) paquetes de BayStream instalados y tiene que haber 1" }
$instalada = [version]$app[0].Version
if ($instalada -ne [version]'0.4.0.0' -and $instalada -ne [version]'0.4.1.0') { throw "Parar: la instalada es la $instalada y no la 0.4.0.0 ni la 0.4.1.0" }
powershell -NoProfile -ExecutionPolicy Bypass -File tool\t93_msix.ps1 -Huella $h[0].Thumbprint -Version 0.4.2.0
if ($LASTEXITCODE -ne 0) { throw 'Parar: el MSIX no salio o no paso la verificacion; no se instalo nada' }
$msix = 'C:\Proyectos\proyecto-baystream\build\t93\BayStream_0.4.2.0.msix'
$respaldo = "C:\Proyectos\respaldo-almacen-$(Get-Date -Format yyyyMMdd-HHmm)"
robocopy "$env:LOCALAPPDATA\BayStream" "$respaldo\BayStream" /E /R:1 /W:1 /NFL /NDL /NJH
if ($LASTEXITCODE -ge 8) { throw 'Parar: la copia del almacen fallo; no se instalo nada' }
"Se instala la 0.4.2.0 encima de la $instalada; la copia esta en $respaldo"
try { Add-AppxPackage -Path $msix -ErrorAction Stop } catch { throw "Parar: no se instalo la 0.4.2.0 ($_); la $instalada sigue instalada" }
Get-AppxPackage | Where-Object Name -like '*baystream*' | Select-Object Name, Version
}
```

El script de T-93 compila Release con la configuración privada (`-Opciones` apunta a
`C:\Proyectos\baystream-privado\firebase-prod.json` por omisión, sin abrirla) y termina
verificando la firma `Valid`, la huella y el `.sha256`. No borra los paquetes anteriores:
`BayStream_0.4.0.0.msix` sigue en `build\t93` para volver (4.5). La última línea tiene que
mostrar la 0.4.2.0, y la app tiene que abrir con los datos de siempre. Si el bloque se detiene
porque la instalada no es la 0.4.0.0 ni la 0.4.1.0, avisar: la línea dice cuál es (10.89).

Con la 0.4.0 (28-oct) hubo que quitar antes la 3.1.1, una sola vez, porque 0.4.0.0 era menor
que 3.1.1.0. La copia quedó en `C:\Proyectos\respaldo-almacen-20261028-1300` (592 archivos
del almacén; la carpeta del paquete no tenía ninguno), y la app abrió con los datos de
siempre (10.75).

### 4.3 Android (prueba interna de Play)

```powershell
flutter build appbundle --release --build-name=0.4.2 --build-number=8 --dart-define-from-file=C:\Proyectos\baystream-privado\firebase-prod.json
```

Sin `--no-pub` (10.86). Firma con la clave de subida de `android\key.properties` (T-49),
que está en esa carpeta y fuera de Git. Subir `build\app\outputs\bundle\release\app-release.aab`
a la **prueba interna**; producción queda fuera. Play volverá a avisar que deja fuera
equipos sin micrófono (el permiso de la voz, 10.112): el Honor lo tiene. Después, en el
Honor, actualizar por el enlace de la prueba interna.

### 4.4 La Web (Hosting), el bloque de la guía del cierre con la versión nueva

```powershell
& {
Set-Location -LiteralPath C:\Proyectos\proyecto-baystream
$viejo = '.dart_tool\flutter_build\c00f0219d5d4c3dd1d45ce8ba5ce2f45'
if (Test-Path -LiteralPath $viejo) { Rename-Item -LiteralPath $viejo -NewName 'c00f0219d5d4c3dd1d45ce8ba5ce2f45-viejo-2oct' }
$destino = [IO.Path]::GetFullPath('C:\Proyectos\proyecto-baystream\build\web')
if ($destino -ne 'C:\Proyectos\proyecto-baystream\build\web') { throw 'Destino de Hosting inesperado' }
if (Test-Path -LiteralPath $destino) { Remove-Item -LiteralPath $destino -Recurse -Force }
flutter build web --release --output=build/web --build-name=0.4.2 --build-number=8 --dart-define-from-file=C:\Proyectos\baystream-privado\firebase-prod.json
if ($LASTEXITCODE -ne 0) { throw 'No publicar: build fallido' }
if (-not (Select-String -LiteralPath build\web\main.dart.js -Pattern 'flutter-fire-auth' -SimpleMatch -Quiet)) { throw 'No publicar: la Web salio sin Firebase Auth' }
dart run tool/t92_verify.dart build/web
if ($LASTEXITCODE -ne 0) { throw 'No publicar: verificacion fallida' }
firebase deploy --only hosting --project baystream-app
}
```

**Nunca `firebase deploy` a secas** (publicaría las reglas de H5 sobre producción).
Después, abrir `https://baystream-app.web.app` en una ventana de incógnito, comprobar
`version.json` (0.4.2, 8) e iniciar sesión con la cuenta de oficina. Quien ya visitó el
sitio puede ver una vez la versión anterior por el *service worker*: recargar. En el
teléfono de la oficina, recargar hasta que `version.json` diga 0.4.2. La primera línea con
`$viejo` ya no hace nada: esa caché se apartó el 2-oct y no ha vuelto (T-125 lo comprobó); se
queda porque es la guía del cierre.

### 4.5 Volver a la 0.4.0 si el ensayo falla

La 0.4.0 es `v0.4.0` (`be532ab`), la publicada el 28-oct (10.75). Se vuelve cliente por
cliente, solo en el que falle, y siempre desde `C:\Proyectos\proyecto-baystream`.

- **Si ya se agregó un plan con otro viaje** (1.18), esa operación se termina con la 0.4.2:
  un cliente 0.4.0 que abre ese plan lo guarda en una operación local nueva, y lo que registre
  ahí no sube (3.8 de `docs/T130-RESULTADOS.md`).
- **Las reglas:** no hace falta volver, porque la 0.4.0 trabaja igual con las de T-130. Solo si
  fallan las reglas mismas: pegar `build\t130\reglas-antes.txt` en la consola y publicar.
  Después, copiar lo publicado a `build\t130\reglas-vuelta.txt` (UTF-8) y cotejarlo con el
  respaldo:

  ```powershell
  & {
  Set-Location -LiteralPath C:\Proyectos\baystream-rediseno
  node tool/t113_reglas.mjs build/t130/reglas-vuelta.txt build/t130/cotejo-vuelta build/t130/reglas-antes.txt
  if ($LASTEXITCODE -ne 0) { throw 'Parar: lo publicado no es identico a reglas-antes.txt; corregir en la consola y cotejar otra vez' }
  'De vuelta en las reglas de antes'
  }
  ```

  Con las reglas de antes, la 0.4.2 dice «La nube no aceptó el plan: …» al agregar un plan y,
  si eran las de T-80, «La nube no aceptó el listado: …» al revisarlo; no cambia nada local.
- **Windows:** 0.4.0.0 es menor que 0.4.2.0, así que hay que desinstalar antes. Los datos
  están fuera del paquete (10.75), y el bloque los copia primero:

  ```powershell
  & {
  Set-Location -LiteralPath C:\Proyectos\proyecto-baystream
  if (Get-Process -Name baystream -ErrorAction SilentlyContinue) { throw 'Parar: cierra BayStream antes de seguir' }
  $msix = 'C:\Proyectos\proyecto-baystream\build\t93\BayStream_0.4.0.0.msix'
  $esperada = ((Get-Content -LiteralPath "$msix.sha256" -Raw).Trim() -split '\s+')[0]
  if ((Get-FileHash -LiteralPath $msix -Algorithm SHA256).Hash -ne $esperada) { throw 'Parar: el MSIX de la 0.4.0.0 no coincide con su .sha256' }
  $app = @(Get-AppxPackage | Where-Object Name -like '*baystream*')
  if ($app.Count -ne 1) { throw "Parar: hay $($app.Count) paquetes de BayStream instalados y tiene que haber 1" }
  $respaldo = "C:\Proyectos\respaldo-almacen-$(Get-Date -Format yyyyMMdd-HHmm)"
  robocopy "$env:LOCALAPPDATA\BayStream" "$respaldo\BayStream" /E /R:1 /W:1 /NFL /NDL /NJH
  if ($LASTEXITCODE -ge 8) { throw 'Parar: la copia del almacen fallo; no se desinstalo nada' }
  "Se desinstala $($app[0].Name) $($app[0].Version); la copia esta en $respaldo"
  try { Remove-AppxPackage -Package $app[0].PackageFullName -ErrorAction Stop } catch { throw "Parar: no se desinstalo ($_)" }
  try { Add-AppxPackage -Path $msix -ErrorAction Stop } catch { throw "Parar: no se instalo la 0.4.0.0 ($_); reinstalar BayStream_0.4.2.0.msix" }
  Get-AppxPackage | Where-Object Name -like '*baystream*' | Select-Object Name, Version
  }
  ```

  Para volver después a la 0.4.2, se instala encima, como en 4.2.
- **Web:** con `git checkout v0.4.0`, el bloque completo de 4.4, sin quitarle ninguna
  comprobación y cambiando solo `--build-name=0.4.0 --build-number=6`. Termina igual que
  4.4, con `firebase deploy --only hosting --project baystream-app`, y se publica una sola
  vez. Después, `git checkout master`.
- **Android:** Play no deja bajar de versión, así que se sube la 0.4.0 con un número mayor:
  con `git checkout v0.4.0`,

  ```powershell
  flutter build appbundle --release --build-name=0.4.0 --build-number=9 --dart-define-from-file=C:\Proyectos\baystream-privado\firebase-prod.json
  ```

  y se sube ese AAB, el código de la 0.4.0 con su nombre y el `versionCode` 9, a la prueba
  interna; el Honor lo actualiza por el enlace. Después, `git checkout master`. Desde ahí,
  la siguiente versión de Android lleva el `versionCode` 10 o más.
- `git checkout v0.4.0` deja la carpeta en la etiqueta, sin rama («detached HEAD»): es lo
  esperado. Los documentos modificados de Carlos no cambian entre las dos versiones y se
  quedan como están. No se hace ningún commit ahí.
- **La 3.1.1** sigue en Git como `v3.1.1` y con su MSIX en `build\t93`, por si hubiera que ir
  más atrás. Sus pasos están en la sección 4.5 de la lista de la 0.4.0:
  `git show cce3c4c:docs/piloto/LISTA-PILOTO.md`.

---

## 5. Lo que la 0.4.2 no cubre y hay que mirar en el ensayo

- **El aviso de seguridad de Firebase** (eMudhra, 3-nov; 10.99): en Windows, la 0.4.2 lleva el
  SDK de C++ de Firebase 13.9.0, que está afectado, igual que la 0.4.0. Lo corrige T-136 en la
  1.0.0. Hasta entonces, en una red que no es tuya (un Wi-Fi público o el del puerto), los datos
  reales van por la Web, en Chrome o Edge, y no por el `.exe`. Android y la Web no están
  afectados, y las reglas no cambian.
- **Lo que necesita Firebase** no se recorrió con los bancos (10.28, y T-125 tampoco): unirse,
  publicar, pedir y decidir cambios, sincronizar y, desde la 0.4.2, revisar el listado (T-127) y
  agregar el plan que falta (T-130). Está probado en memoria (`t80_requests_widget_test`,
  `t81_office_widget_test`, `t79_sync_engine_test`, las de T-127 y las de T-130, con las nubes
  falsas de T-79 y de T-129), con las reglas de T-130 en el emulador (sus cuatro baterías, 10.94,
  y la prueba de punta a punta de la aceptación, en Chrome, 10.97), en la v3.0 en campo y en los
  pilotos del ECO BORA con la 3.1.0 (10.47) y del MAGELLAN STAR con la 0.4.0 (10.85). El ensayo
  (1.6, 1.8, 1.11, 1.12, 1.17 a 1.19, 2.1, 2.2, 2.10, 2.11, 2.13, 2.15 y 2.16) y la prueba de
  0.8 lo comprueban contra Firebase de verdad. **En Android, la 0.4.2 contra la nube se prueba
  por primera vez en 0.8**: en la aceptación, el banco no sincronizó en la tablet (O-134-2).
- **La regla de uso** (3.8 de `docs/T130-RESULTADOS.md`): la laptop, el teléfono de la oficina
  (la Web, recargada hasta la 0.4.2) y el Honor pasan a la 0.4.2 antes de revisar el listado
  (1.17) o de agregar un plan (1.18). Un cliente viejo no daña la operación, pero:
  - un 0.4.0 que se une a una operación cuyo listado ya se reemplazó falla con «La fuente
    «listado de la agencia» llegó incompleta o distinta de la publicada. No se guardó nada:
    vuelve a intentarlo»; si ya estaba unido, sigue con el listado viejo, y sus movimientos se
    aceptan igual (sección 4 de `docs/T127-RESULTADOS.md`);
  - uno que ya estaba unido cuando la oficina agrega un plan no se entera: sigue con su plano,
    y sus movimientos se aceptan;
  - uno que se une después y abre un plan agregado **con otro viaje** lo guarda en una operación
    local nueva («Solo en este dispositivo»), y lo que registre ahí no sube;
  - una oficina 0.4.0 no agrega planes, y puede publicar una segunda operación de la misma
    escala: la negativa de 1.19 es de la 0.4.2.
- **El mouse y el touchpad (T-119)** los probó Carlos a mano en Windows, Chrome y Edge (10.80),
  y la aceptación de la 0.4.2 lo repite. **O-040-1** sigue abierto: en la Web, deslizar dos dedos
  de lado sobre la silueta puede regresar el navegador a la página anterior. Sobre la silueta
  bastan la rueda o los dos dedos hacia arriba y abajo; en la oficina, la app de Windows no tiene
  ese gesto.
- **Un pellizco que pierde el foco sin terminar (O-128-4)** no se pudo provocar en la
  aceptación de la 0.4.1. Si después de un pellizco la columna ya no se desplaza con dos dedos,
  otro pellizco corto, o cerrar y abrir el plano, la sueltan. Va a T-120.
- **El cierre de T-129** está probado contra una nube falsa al nivel del SDK, y pasó en la
  aceptación contra el emulador, en Chrome, al primer intento (10.97); en Windows y contra
  Firebase de verdad lo prueba el paso 11 de 0.8. Si ahí o en el ensayo vuelve a decir «No se
  encontró la operación…», 1.15 lo resuelve como antes, y se anota.
- **El nombre del archivo al confirmar** (T-135, 10.98): por la banda y por «Parámetros», el
  aviso dice «Archivo "<nombre>" cargado correctamente». Hasta la 0.4.0, por «Parámetros» decía
  «null» (O-134-4). Si vuelve a salir, es un fallo nuevo: anotarlo con el camino.
- **Las esperas de la nube** (O-134-5): en la aceptación, con un corte de red simulado, el chip
  tardó más de medio minuto en pasar a «Sin conexión», y el plan agregado llegó solo, pero
  después de medio minuto de vuelta la red. Esta lista espera un minuto antes de «Reintentar»
  (0.8, 2.15 y 2.16); tardar no es un fallo, no llegar sí.
- **Las marcas de T-133** miden su rótulo cada vez que se dibuja la bahía a la vista; Timonel no
  midió el costo (RNF-002, 10.95), y la aceptación no tiene el Honor. En el ensayo y en el
  piloto, si una bahía con muchas marcas tarda en dibujarse o se traba al desplazarla, anotar la
  bahía, la letra del teléfono y la hora. Con la letra a 2.0 ninguna marca lleva rótulo: el código
  va entero, y la marca, en su ícono y su color.
- **El distintivo de T-131 cede el sitio:** en la cabecera de la oficina y en la banda del
  muelle mandan los controles, y según el ancho y la letra va completo, compacto o no va (la
  tabla de `DESIGN.md` 13.12). No es un fallo. Sin cuenta autorizada no hay distintivo.
- **La búsqueda de T-130 en la nube** necesita sesión autorizada y espera hasta 5 s; sin
  respuesta, decide con lo que tiene el equipo (7.3 de `docs/T130-RESULTADOS.md`). Sin red, la
  banda de 1.18 puede no saber de una operación que este equipo no tiene.
- **Las cifras de Estadísticas se mueven durante la operación** (10.68): cuentan los vacíos
  asignados, como la Lista, y lo dice su ficha (1.16). No es un fallo. Las alertas de estiba
  y la comparación de viajes no los suman.
- **TalkBack** no se probó en el Honor: el anuncio del movimiento sin panel es una
  región en vivo sin dibujo (10.21, H3), y el distintivo dice «Rol: Muelle», con la pista «Abre
  Nube y cuenta». Si en el muelle no se oye, anotar.
- **La letra del Honor** distinta de 1.0: las capturas de la candidata son a 1.0; a 1.45
  y 2.0, el plano y la banda están probados en el emulador de 360 × 640, y los avisos, con
  pruebas de widgets a 360 × 640, 360 × 800 (el tamaño del Honor) y 412 × 915 (10.32 a
  10.34); nada de eso en el Honor mismo. Con la letra grande, el aviso dice su texto corto
  y los errores llevan «Ver», que abre el texto entero; la banda va sin distintivo y las
  marcas, sin rótulo.
- **Dos observaciones conocidas del teléfono (P3, 10.94)**, para después del 7-nov, que no se
  anotan como fallos nuevos: la línea «Bahía 02, carga: nada pendiente» mide 21 dp y no pasa la
  pauta de toque, y el peso por pila «110.0+?» queda a 4.33:1.
- **Una observación conocida (P3, 10.34)**, que no se anota como fallo nuevo: al reabrir un
  viaje cuyo perfil vigente dejaría contenedores fuera, el aviso «No se aplicó del perfil
  vigente: …» dura 10 s y, en el plano sin operación, tapa parte de la rejilla una vez:
  esperar a que se apague (T-61). La otra de 10.34 (O3, el aviso que cruzaba el pie del riel
  y «En vivo» a 1920 × 1080) quedó cerrada con la entrega 1: en la oficina los avisos viven
  en la franja de cifras (10.40 y 10.46; `DESIGN.md` 14.5).
- **El micrófono** (`uses-feature android.hardware.microphone required=false`, 10.112)
  sigue sin declararse en el manifiesto: Play deja fuera equipos sin micrófono. No afecta
  al Honor.
