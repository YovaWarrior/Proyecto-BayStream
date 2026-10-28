# Lista de comprobación · Ensayo y prueba piloto con COMAR (la 0.4.0, 10.68 y 10.74)

**Para quién.** Carlos publica la 0.4.0 y corre el ensayo y el piloto; Yov revisa esta
lista y los comandos antes. La lista va por rol: **el muelle con el Honor** y **la oficina con la
laptop**. Cada paso dice qué hay que ver en pantalla y qué hacer si algo falla. Los textos
entre comillas son los rótulos exactos de la app.

**Qué es la 0.4.0.** La versión de la presentación final del 7-nov, publicada a más tardar
el 4-nov (10.65 y 10.68). Hasta el 28-oct se llamó 3.2.0: desde 10.74, la numeración va en
0.x hasta la 1.0.0 del examen final. Lo ya publicado conserva su número en Git y en los
paquetes, y en la numeración nueva se lee así: la 3.0 es la 0.3.0, la 3.1 es la 0.3.1 y la
3.1.1 es la 0.3.2. Es `sprint-4` mezclado en `master` (4.1), y lleva, encima de la
candidata del piloto (la 3.1.0, 10.35):
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

Lo demás sigue siendo la 3.1.1 que ya se probó en campo. **Si el ensayo falla en algo
serio, se vuelve a la 3.1.1** (4.5), que sigue en Git como `v3.1.1` y con su MSIX en
`build\t93`.

**Datos.** En el ensayo, los sintéticos de T-100 (`T100_CARGA.edi`, `T100_LISTADO.xlsx`
y `T100_LLEGADA.edi`: BUQUE MANUAL, viaje M100, escala GTSTC; se generan con
`dart tool/t100_sintetico.dart <salida en %TEMP%>` y `python -I tool/t100_listado.py
<esa salida>`). En el piloto, los archivos reales de la escala, que **no salen de la
laptop ni del teléfono y no entran al repositorio**. Ninguna captura muestra «Nube y cuenta», un correo
ni un nombre de cuenta.

---

## 0. Antes del ensayo (Carlos, con la laptop)

| # | Qué hacer | Qué hay que ver | Si falla |
|---|---|---|---|
| 0.1 | Mezclar `sprint-4` en `master` y publicar los tres clientes con los comandos de la sección 4 | La Web en `https://baystream-app.web.app/version.json` dice `"version": "0.4.0"` y `"build_number": "6"`; Windows instaló `BayStream_0.4.0.0.msix` (Configuración → Aplicaciones → BayStream 0.4.0.0); Play tiene el AAB 6 (0.4.0) en la prueba interna y el Honor lo actualizó por el enlace de prueba | No sigas con una versión a medias: los tres clientes tienen que ser la 0.4.0. Si una compilación no sale, el ensayo se hace con la 3.1.1 y se anota |
| 0.2 | Guardar lo de la 3.1.1 para poder volver: `build\t93\BayStream_3.1.1.0.msix` (y su `.sha256`) en `C:\Proyectos\proyecto-baystream`, y la etiqueta `v3.1.1` en Git | Los dos existen antes de instalar nada nuevo (`git tag --list v3.1.1` la muestra) | Sin el MSIX, volver a Windows 3.1.1 exige recompilarlo desde `v3.1.1` con 4.2 |
| 0.3 | Comprobar las cuentas en Firebase (consola, no desde la app): la de oficina y la de muelle existen y están **autorizadas**; las reglas publicadas son las de 10.108 (no se vuelve a publicar nada) | En la app, al iniciar sesión, «Cuenta autorizada» y el rol correcto («Oficina» o «Muelle») | «Cuenta sin autorizar: …»: el responsable la activa en la consola; la app no lo puede hacer |
| 0.4 | En el Honor: letra del sistema en 1.0 (o la que use el planificador, pero anotada), brillo alto, Wi-Fi o datos encendidos, la app actualizada | El inicio con «Abre un plano de estiba» y «Seleccionar archivo»; la travesía no se dibuja en el teléfono (no sobra sitio): es lo esperado. Con un plano abierto, «Estad.» muestra «contenedores a bordo» y «Carga por bahía, de proa a popa» (la 0.4.0) | Si «Estad.» muestra la vista de tarjetas de antes, no se actualizó: Play → prueba interna → actualizar |
| 0.5 | En la laptop: Windows con el MSIX 0.4.0.0 abierto una vez (tema «Seguir al sistema» o «Oscuro» en Parámetros; la oficina trabaja de noche) | El inicio con la marca, «Abre un plano de estiba» y, si sobra alto debajo, el buque navegando al pie | Si el instalador dice «Publisher: Unknown» o `0x800B010A`, el MSIX no se firmó con `CN=BayStream`: repetir 4.2 con la huella |
| 0.6 | Tener a mano en la laptop el plan de carga, el listado de la agencia (`.xlsx`) y el plano de llegada de la escala; en el Honor no hace falta ningún archivo: se une a la operación publicada | | |

---

## 1. Ensayo · La oficina (laptop, Windows; la Web es igual salvo lo que se indica)

La oficina es la ventana de 600 dp de ancho o más: el riel a la izquierda (Plano, Lista,
Avance, Estadísticas, Más), el selector de modo en la cabecera y «Acciones» (⋮) en la
franja de la bahía (`DESIGN.md` 14).

| # | Qué hacer | Qué hay que ver | Si falla |
|---|---|---|---|
| 1.1 | «Seleccionar archivo» → el **plan de carga** | El plano abre **en previo**: arriba la banda «Plano sin confirmar: perfil propuesto desde el archivo. Escala propuesta <puerto>.» con «Confirmar», y debajo «Peso por pila y tomas de refrigerado: sin evaluar hasta confirmar el perfil.» Son tres pasos y la rejilla ya se ve | Si sale «Este archivo no parece un BAPLIE: …» o «Versión BAPLIE no admitida: …», pedir la exportación 2.x a la agencia. Si no abre nada en 30 s, anotar y reintentar |
| 1.2 | «Confirmar» en la banda | Si el equipo ya guarda perfiles de otros buques, primero «Perfil del buque nuevo»: elegir «Proponer desde el archivo». Si ya hay uno con el mismo nombre, «Confirma la identidad del buque»; si la carga excede el perfil guardado, «Revisar ampliación». Después se abre «Parámetros del buque»: filas y niveles propuestos, la escala en «Puerto de esta escala» (la propuesta y, con un plano de llegada, los puertos de descarga con su cuenta, «GTSTC (7)»), el límite de apilamiento. **«No lo tengo» no viene marcado**: hay que escribir el límite del manual de estabilidad o marcarlo a mano | Si la escala propuesta no es la de la operación, elegir la correcta en «Puerto de esta escala» antes de confirmar |
| 1.3 | «Confirmar y ver el plano» | Vuelve al **Plano** (no a la Lista), la cabecera dice «Publicado» y, a su lado, el selector de modo con «Contenido», «Orden» y «Carga» (el plan de carga no ofrece «Descarga»). Si no caben, van en el menú «Modo del plano: …» | Si vuelve a «Parámetros del buque», algo no cuadra (un mensaje en rojo dice qué): corregir y confirmar otra vez |
| 1.4 | «Lista» → «Listado de la agencia» → «Elegir listado (.xlsx)» → el listado | La página muestra el archivo, «N filas en M agencias · X llenos · Y vacíos», las equivalencias propuestas («Tipo 40ST → 42G1»…) y el cruce «X de X llenos cruzan con el plan». La fila «TOTAL» sale bajo «1 fila sin entender:»: es normal. Las filas bajo «AGREGADOS» se cuentan aparte, como la agencia «AGREGADOS» (H3) | Si a una equivalencia le falta el código («→ ?»), elegirla con el lápiz («Corregir <código>»); el botón lo pide con «Falta elegir N equivalencias antes de importar…». Si «N contenedores del plan no están en el listado» es alto, revisar el listado con la agencia antes de importar |
| 1.5 | «Confirmar e importar», en el pie fijo de la página. No hace falta esperar a que se apague el aviso «Archivo "<nombre>" cargado correctamente»: flota por encima del pie. **Antes de publicar (1.7)** | «Listado guardado en la operación de <escala>: N filas.» y el aviso «Listado importado.» En el Plano, en «Orden» y en «Carga», cada celda de carga lleva su OR | Si el botón está apagado, falta una equivalencia: ver 1.4. Si dice «Fila N: …», corregir el Excel y volver a importar. Con la operación ya publicada el listado nuevo no entra (H2, 10.50, sigue abierto): importarlo antes de 1.7 |
| 1.6 | Icono de la nube → **«Nube y cuenta»** → iniciar sesión con la cuenta de oficina | Nombre, rol «Oficina» y «Cuenta autorizada». «Operación de la escala abierta» con buque, viaje y puerto, estado «Solo en este dispositivo» | «Sesión vencida: …» o «Tu cuenta no está autorizada…»: ver 0.3. Sin red: «Sin conexión», esperar la red |
| 1.7 | «Publicar operación» | El estado pasa a «Publicada»; la nube de la cabecera, a «Nube y cuenta · Al día» (su descripción) y la cabecera de «En vivo», a «Al día». Desde aquí todo lo registrado antes se queda local y lo nuevo sube | Si dice «La nube no aceptó la publicación: revisa que la cuenta sea de oficina y esté activa.», las reglas o la cuenta: consola. **No publicar reglas con `firebase deploy` a secas** (guía del cierre) |
| 1.8 | «Más» → «Cargar archivo BAPLIE» → el **plano de llegada** | Con la misma escala confirmada, **abre publicado sin previo** (regla 7.2 de `DESIGN.md`): «Publicado», y el selector de modo ofrece «Descarga» y «Carga». La Lista resume «N se descargan · M se cargan · K de paso» | Si abre en previo con «El archivo sale de X rumbo a Y: confirma la escala.», la escala propuesta no es la confirmada: «Confirmar» y elegir la escala de la operación |
| 1.9 | «Avance» (en el riel) | Descarga, carga de llenos y vacíos, cancelados, conflictos y el último movimiento, por bahía y total; las impares van con su par (la 21 y la 23, en la 22); se actualiza solo cuando el muelle registra | Si no cambia cuando el muelle registra (paso 2.3), mirar el estado de la nube: «Enviando N» o «Sin conexión» en «En vivo» o en la nube de la cabecera, en alguno de los dos |
| 1.10 | «Plano», con la ventana a 1200 de ancho o más | El panel «En vivo» a la derecha, con el estado de la nube arriba («Al día») y una fila por movimiento: «Bajado · Muelle», debajo el contenedor y la celda, y «ahora». Lo que acaba de llegar sale en **naranja** 1.5 s y la bahía destella en la silueta | Con menos ancho no hay panel fijo: el botón del panel lateral de la cabecera («Mostrar el panel lateral») o el borde derecho lo abren flotante. Sin panel a la vista, el anuncio lo da el lector de pantalla. No es un fallo |
| 1.11 | Cuando el muelle pida un cambio (2.10): en el Plano, «Acciones» (⋮) → «Bandeja de cambios (1)» | La solicitud «Pendiente» con quién la pide («Solicita <nombre> · <fecha>»), «OR N · contenedor: celda → celda» y «Motivo: …». «Aprobar» y «Rechazar» piden «Motivo obligatorio» | «Se necesita una cuenta autorizada y una operación publicada.»: la sesión o la publicación (1.6, 1.7) |
| 1.12 | «Aprobar» (o «Rechazar») con motivo | La tarjeta pasa a «Aprobada» (el contenedor cambia de celda en el plan) o «Rechazada»; el muelle lo ve sin recargar | Si queda «En conflicto», la celda ya está ocupada: rechazar y pedir otro cambio |
| 1.13 | Al final de la escala: «Lista» → «Generar BAPLIE de salida» | «N contenedores a bordo en la salida.» («1 contenedor…» si es uno) y «Pendientes: X de carga y Y de descarga.», los cancelados vigentes y «Comparar con la llegada». Si se cargaron llenos sin fila en el listado (2.8), «N llenos van con los datos del plan de carga porque no tienen fila en el listado: …» | Si dice «La escala no tiene una operación guardada…», volver a abrir el plan de carga y confirmar la escala |
| 1.14 | «Guardar BAPLIE de salida» | Windows: el diálogo «Guardar BAPLIE de salida» con `BayStream_<buque>_<viaje>_salida.edi`; al guardar, «Exportación BAPLIE completada». En la Web, el navegador lo descarga | Guardar en una carpeta de la laptop; el archivo no se sube a ningún lado |
| 1.15 | «Nube y cuenta» → «Cerrar operación»; en el diálogo «Cerrar la operación», «Cerrar operación» | «Publicada y cerrada»; ya no admite movimientos | Solo al terminar de verdad: una operación cerrada no se reabre |
| 1.16 | Cuando el muelle asigne un vacío (2.6 y 2.7): «Estadísticas» (en el riel) | «N contenedores a bordo» y, debajo, «Incluye: 1 vacío asignado a una celda reservada, que el archivo no trae» (con más, «Incluye: N vacíos asignados a celdas reservadas, …»); la cifra, «vacíos» y la bahía suben con cada vacío asignado. «Carga por bahía, de proa a popa» cuenta cada impar con su par. En «Ver como tabla», la fila «Vacíos asignados». Es lo que cuenta la Lista (T-125) | Si un vacío asignado no sube la cifra o la ficha no sale, anotarlo con la hora. Que las cifras se muevan durante la operación es lo esperado (10.68) |

---

## 2. Ensayo · El muelle (Honor, Android)

| # | Qué hacer | Qué hay que ver | Si falla |
|---|---|---|---|
| 2.1 | Icono de la nube → «Nube y cuenta» → iniciar sesión con la cuenta de muelle | Rol «Muelle», «Cuenta autorizada». En el inicio, «Operaciones abiertas en la nube (1)» | Ver 0.3. Sin red: «Sin conexión con la nube: unirse requiere red. Conéctate e inténtalo de nuevo.» |
| 2.2 | «Operaciones abiertas en la nube» → «Unirse» → «Abrir plano de llegada» | El plano **sin elegir ningún archivo**: la banda azul de la marca arriba con el buque, «Viaje <n> · <escala>», el chip «Al día» y los segmentos «Descarga / Carga»; abajo la barra Plano · Lista · Avance · Estad. · Más | Si no aparece la operación, la oficina no publicó (1.7). Si el plano abre en previo, la operación trae un perfil distinto: anotar y usar «Confirmar» |
| 2.3 | «Descarga» → tocar una celda que dice **«Baja»** | La celda sale de su sitio en **naranja** («Bajando») y abajo, sobre las cifras de la franja, el aviso «Descargado · <contenedor> · <celda>» con «Deshacer» durante 6 s (con la letra grande, «Descargado · <contenedor>»); después la celda queda «Hecho» con la palomita. En la laptop, «Avance» y «En vivo» lo muestran en segundos | Si no registra: «No se registró: …» dice la causa (operación cerrada, sesión); con la letra grande sale «No se registró.» y «Ver» la muestra. Si el aviso pisa una celda o un control, anotarlo como fallo (que tape las cifras es lo esperado, 10.30). Si la celda no es «Baja» sino «Paso», es carga de paso: ver 2.5 |
| 2.4 | Tocar «Deshacer» en el aviso | La celda vuelve a «Baja»; el movimiento queda anulado «Marcado por error» (no se borra). Pasado el aviso: tocar la celda → «Deshacer la descarga» en el detalle | |
| 2.5 | Tocar una celda **«Paso»** | La pregunta «Re‑estiba»: «<contenedor> no se descarga en <escala>: va a <puerto>…» con «Registrar re‑estiba». Al confirmar, la celda queda «Re‑est.» y el aviso «Re‑estiba registrada · …» | Si fue un toque por error: «Cancelar» |
| 2.6 | «Carga» → «Acciones» (⋮) → «Asignar vacío» | «Vacíos del listado»: «OR N · <contenedor>» con tipo, destino, línea y tara. Al tocar uno, el formulario «Asignar vacío» propone la celda (primero las de su grupo en la bahía) y pide tara real, hora y marchamo opcionales | Sin listado, «Asignar vacío» está apagado y la línea del resumen dice «Sin listado de agencia: los llenos se cargan por su número; los vacíos esperan el listado»: falta 1.5 en la oficina (viaja con la operación publicada) |
| 2.7 | «Confirmar carga» | «Carga registrada · OR N» con «Deshacer»; la celda sale en naranja y queda cargada con su OR | Si la celda sigue ocupada por el de llegada: «Marcar su descarga y cargar» → «Descarga y carga registradas · OR N» |
| 2.8 | Cargar un lleno: «OR / últimos dígitos» (en la tira del pie) → escribir el OR o los últimos dígitos → «Confirmar carga» | La búsqueda «Confirmar carga por OR o contenedor»; después, igual que 2.7. Un lleno del plan sin fila en el listado sale como «<contenedor> · sin OR en el listado» y se carga por su número («Carga registrada · <contenedor>», H4). El detalle de una celda cargada ofrece «Deshacer carga» con motivo | «No hay coincidencias disponibles.»: el OR no está en el listado o ya se cargó. Un vacío sin fila no se ofrece: espera el listado |
| 2.9 | «Deshacer» en el aviso de una carga | El OR vuelve a estar pendiente y la celda, vacía con su contorno | |
| 2.10 | «Acciones» (⋮) → «Solicitudes de cambio (0)» → «Pedir cambio» | El formulario: «Objeto 1: OR, contenedor o reserva», «Intercambiar dos contenedores» (viene activado) o «Destino BBB-RR-TT», y «Motivo obligatorio» → «Enviar solicitud». La solicitud queda «Pendiente» y la celda destino lleva un borde punteado con el icono de pedir cambio (el lector dice «Solicitud pendiente en <celda>») | «Se necesita una cuenta autorizada y una operación publicada.»: la sesión del teléfono o la publicación (1.7). El objeto sigue en su celda hasta que la oficina apruebe |
| 2.11 | Cuando la oficina decida (1.12) | La solicitud pasa a «Aprobada» o «Rechazada» sin recargar; si se aprobó, el OR cambia de celda en «Carga» | |
| 2.12 | Atrás (el botón del sistema) en el plano | **Un toque**: arriba, sobre el plano, la advertencia «Toca Atrás otra vez para volver al inicio.» durante 2 s, aunque abajo siga el aviso de un movimiento; el plano sigue. **Dos toques seguidos**, dentro de esos 2 s: el inicio, con el viaje en los recientes. Tocar el reciente lo reabre publicado, con la operación | Un toque nunca saca del plano: si sale, anotarlo como fallo. Con una hoja abierta («Más», el detalle), Atrás solo la cierra, y el siguiente Atrás vuelve a advertir |
| 2.13 | Sin red: modo avión **con el Wi-Fi apagado** (10.39) → registrar una descarga | El chip de la banda pasa a «Sin conexión» y la app sigue registrando. Al volver la red, «Enviando» y después «Al día»; la oficina lo recibe. Cuántos esperan lo dice «Nube y cuenta» | Si al volver la red el chip dice «Revisar», mirar «Nube y cuenta»: con «Sesión vencida: …», iniciar sesión otra vez; la cola se envía sola |
| 2.14 | «Más» | «Alertas de estiba» (con su cuenta), «Tapas en la operación», «Orden de descarga», «Listado de la agencia», «Comparar con otro BAPLIE…», «Exportar PDF», «Exportar CSV» y «Exportar JSON», «Nube y cuenta», «Parámetros», «Cargar archivo BAPLIE», «Viajes recientes», «Perfiles guardados» y «Cerrar el plano» | «Cerrar el plano» con el viaje publicado limpia este dispositivo; se vuelve a entrar desde los recientes o uniéndose |

---

## 3. El día del piloto

1. **Antes de zarpar nada:** 0.3 a 0.6 repetidos esa mañana; en la laptop, 1.1 a 1.8 con
   los archivos reales; en el Honor, 2.1 y 2.2. Si 2.2 no muestra el plano con la banda
   y «Al día», el piloto se hace con la 3.1.1 (4.5) y se anota por qué.
2. **Durante la descarga:** el muelle hace 2.3 a 2.5 con cada contenedor; la oficina
   mira 1.9 y 1.10. Un toque por error se deshace con «Deshacer» (6 s) o desde el
   detalle; nada se borra.
3. **Durante la carga:** 2.6 a 2.9 y, si hace falta, 2.10 y 1.11 a 1.12; la oficina mira
   1.9 y 1.16.
4. **Si se cae la red** en el muelle: seguir registrando (2.13); «Nube y cuenta» dice
   cuántos esperan. No cerrar sesión ni la app.
5. **Al terminar:** 1.13 a 1.15. El BAPLIE de salida se guarda en la laptop.
6. **Qué anotar para Yov** (sin capturas de cuentas ni datos reales): la hora de cada
   paso, cualquier texto en rojo (con su frase exacta), cualquier toque que no hizo lo
   esperado, el tiempo que tardó la primera visualización en el Honor (RNF-002: tres
   pasos, menos de 30 s), y si la letra del teléfono era 1.0 u otra.

---

## 4. Compilación y publicación (Carlos; Yov revisa antes)

Las versiones de la 0.4.0, una por cliente (hasta el 28-oct se llamaba 3.2.0; 10.74). Lo
publicado antes, la 3.1.1 de 10.62, es Web 3.1.1+5, MSIX 3.1.1.0 y AAB 5:

| Cliente | Versión | Por qué |
|---|---|---|
| Android (AAB, prueba interna de Play) | `0.4.0`, `versionCode` **6** | Play solo exige que el `versionCode` suba (el 5 ya se usó); el nombre puede «bajar» |
| Windows (MSIX) | **0.4.0.0** | Windows solo instala encima si la versión sube, y 0.4.0.0 es menor que 3.1.1.0: **una sola vez**, se desinstala la 3.1.1 antes (4.2). Después, la 0.4.x actualiza normal |
| Web (Hosting) | `0.4.0`, compilación **6** | `version.json` lo deja visible |

`pubspec.yaml` dice `version: 0.4.0+6` y `msix_version: 0.4.0.0` (10.74); los comandos
lo repiten en la línea de comandos para no depender de ello. `pubspec.lock` no cambia.

**Los bloques con comprobaciones van dentro de `& { … }`** (4.1, la instalación de 4.2 y
4.4). Según cómo se peguen, PowerShell puede correr cada línea por su cuenta, y entonces un
`throw` no detiene las que siguen. Dentro de las llaves, el bloque entero se detiene en la
primera comprobación que falle: en 4.4, por ejemplo, ya no llega a `firebase deploy`.

### 4.1 La mezcla (desde `C:\Proyectos\proyecto-baystream`, la carpeta de siempre)

**Se hizo en dos pasos el 28-oct.** La primera mezcla, con el nombre de entonces, dejó
`master` en `5fe823a` («Sprint 4: la 3.2.0, mezcla de sprint-4 a master»), con la etiqueta
`v3.2.0`; antes se comprobó que `master` estaba en `34d8838` (`v3.1.1`) y dentro de
`sprint-4`. Con 10.74 cambió el número: `sprint-4` lleva el commit de la numeración, y una
segunda mezcla lo trae a `master`. La etiqueta `v3.2.0` se borra, porque no se publicó nada
con ella, y queda `v0.4.0`. `C:\Proyectos\baystream-rediseno` es otro árbol de trabajo del
mismo repositorio, así que `sprint-4` es la misma rama local. La mezcla no puede tener
conflictos: **si Git marca alguno, parar y avisar antes de resolver nada.** Los documentos
de Carlos modificados en esa carpeta (hoy, cuatro `.docx` y un `.pdf` de `docs/`) no los toca
`sprint-4` y se quedan como están.

```powershell
& {
Set-Location -LiteralPath C:\Proyectos\proyecto-baystream
if ((git branch --show-current) -ne 'master') { throw 'Parar: la carpeta no esta en master' }
if ((git rev-parse HEAD) -notlike '5fe823a*') { throw 'Parar: master no esta en 5fe823a' }
if (-not (git show sprint-4:pubspec.yaml | Select-String -Pattern '^version: 0\.4\.0\+6' -Quiet)) { throw 'Parar: sprint-4 todavia no trae la 0.4.0' }
git merge --no-ff --no-commit sprint-4
if ($LASTEXITCODE -ne 0) { throw 'Parar: la mezcla no salio limpia; no resolver nada' }
git commit -m "Sprint 4: la 0.4.0, mezcla de sprint-4 a master"
if ($LASTEXITCODE -ne 0) { throw 'Parar: el commit de la mezcla no salio' }
git tag -d v3.2.0
git push origin :refs/tags/v3.2.0
git tag -a v0.4.0 -m "BayStream 0.4.0, el rediseno con los arreglos del piloto (Sprint 4)"
git push origin master
git push origin v0.4.0
git log --oneline -1
}
```

Las tres comprobaciones del principio detienen el bloque si la carpeta no está en `master`,
si `master` no está en `5fe823a` o si `sprint-4` todavía no trae la 0.4.0. La mezcla se
detiene antes del commit («stopped before committing as requested»): es lo esperado, y el
`git commit` la cierra. La última línea tiene que mostrar «Sprint 4: la 0.4.0, mezcla de
sprint-4 a master». Después, la carpeta queda en `master` con la 0.4.0; `v3.1.1` sigue en
Git para volver (4.5). El rediseño sigue en `C:\Proyectos\baystream-rediseno`, en
`sprint-4`.

### 4.2 Windows (MSIX), desde esa carpeta en `master`

```powershell
$h = @(Get-ChildItem Cert:\CurrentUser\My | Where-Object Subject -eq 'CN=BayStream')
$h.Count   # tiene que dar 1
powershell -NoProfile -ExecutionPolicy Bypass -File tool\t93_msix.ps1 -Huella $h[0].Thumbprint -Version 0.4.0.0
```

Sale `build\t93\BayStream_0.4.0.0.msix` con su `.sha256`; el script compila Release con la
configuración privada (`-Opciones` apunta a `C:\Proyectos\baystream-privado\firebase-prod.json`
por omisión, sin abrirla) y termina verificando la firma `Valid` y la huella. No borra los
paquetes anteriores: `BayStream_3.1.1.0.msix` sigue en `build\t93`.

**Instalarlo, esta vez quitando antes la 3.1.1:** 0.4.0.0 es menor que 3.1.1.0 y Windows no
lo instala encima. Los datos no se pierden, porque la app los guarda en
`%LOCALAPPDATA%\BayStream`, fuera del paquete; igual se copian antes, con la app cerrada:

```powershell
& {
if (Get-Process -Name baystream -ErrorAction SilentlyContinue) { throw 'Parar: cierra BayStream antes de seguir' }
$respaldo = "C:\Proyectos\respaldo-almacen-$(Get-Date -Format yyyyMMdd-HHmm)"
robocopy "$env:LOCALAPPDATA\BayStream" $respaldo /E /R:1 /W:1 /NFL /NDL /NJH
if ($LASTEXITCODE -ge 8) { throw 'Parar: la copia del almacen fallo; no se desinstalo nada' }
$app = @(Get-AppxPackage | Where-Object Name -like '*baystream*')
if ($app.Count -ne 1) { throw "Parar: hay $($app.Count) paquetes de BayStream instalados y tiene que haber 1" }
"Se desinstala $($app[0].Name) $($app[0].Version); la copia del almacen esta en $respaldo"
try { Remove-AppxPackage -Package $app[0].PackageFullName -ErrorAction Stop } catch { throw "Parar: no se desinstalo ($_)" }
try { Add-AppxPackage -Path C:\Proyectos\proyecto-baystream\build\t93\BayStream_0.4.0.0.msix -ErrorAction Stop } catch { throw "Parar: no se instalo la 0.4.0.0 ($_)" }
Get-AppxPackage | Where-Object Name -like '*baystream*' | Select-Object Name, Version
}
```

La última línea tiene que decir `0.4.0.0`. Si el bloque para antes de «Se desinstala…», no
se tocó nada; si para al instalar, BayStream quedó desinstalado: instalar otra vez
`BayStream_3.1.1.0.msix` (4.5) y avisar. Si la copia no encuentra `%LOCALAPPDATA%\BayStream`,
el bloque para ahí, y es lo correcto: los datos estarían en otro lado y no se desinstala.
Abrir la app una vez: tiene que abrir con los datos de siempre; si pide iniciar sesión otra
vez, es normal. Desde aquí, la 0.4.x se instala encima.

### 4.3 Android (prueba interna de Play)

```powershell
flutter build appbundle --release --build-name=0.4.0 --build-number=6 --dart-define-from-file=C:\Proyectos\baystream-privado\firebase-prod.json
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
flutter build web --release --output=build/web --build-name=0.4.0 --build-number=6 --dart-define-from-file=C:\Proyectos\baystream-privado\firebase-prod.json
if ($LASTEXITCODE -ne 0) { throw 'No publicar: build fallido' }
if (-not (Select-String -LiteralPath build\web\main.dart.js -Pattern 'flutter-fire-auth' -SimpleMatch -Quiet)) { throw 'No publicar: la Web salio sin Firebase Auth' }
dart run tool/t92_verify.dart build/web
if ($LASTEXITCODE -ne 0) { throw 'No publicar: verificacion fallida' }
firebase deploy --only hosting --project baystream-app
}
```

**Nunca `firebase deploy` a secas** (publicaría las reglas de H5 sobre producción).
Después, abrir `https://baystream-app.web.app` en una ventana de incógnito, comprobar
`version.json` (0.4.0, 6) e iniciar sesión con la cuenta de oficina. Quien ya visitó el
sitio puede ver una vez la versión anterior por el *service worker*: recargar. La primera
línea con `$viejo` ya no hace nada: esa caché se apartó el 2-oct y no ha vuelto (T-125 lo
comprobó); se queda porque es la guía del cierre.

### 4.5 Volver a la 3.1.1 si el ensayo falla

La 3.1.1 es `v3.1.1` (`34d8838`), la publicada el 26-oct (10.62). Se vuelve cliente por
cliente, solo en el que falle, y siempre desde `C:\Proyectos\proyecto-baystream`.

- **Windows:** instalar `build\t93\BayStream_3.1.1.0.msix` (y comprobar su `.sha256`). Como
  3.1.1.0 es mayor que 0.4.0.0, se instala encima; desinstalar antes también sirve. Para
  volver después a la 0.4.x, hay que desinstalar otra vez la 3.1.1, como en 4.2.
- **Web:** con `git checkout v3.1.1`, el bloque completo de 4.4, sin quitarle ninguna
  comprobación y cambiando solo `--build-name=3.1.1 --build-number=5`. Termina igual que
  4.4, con `firebase deploy --only hosting --project baystream-app`, y se publica una sola
  vez. Después, `git checkout master`.
- **Android:** Play no deja bajar de versión, así que se sube la 3.1.1 con un número mayor:
  con `git checkout v3.1.1`,

  ```powershell
  flutter build appbundle --release --build-name=0.3.3 --build-number=7 --dart-define-from-file=C:\Proyectos\baystream-privado\firebase-prod.json
  ```

  y se sube ese AAB, el código de la 3.1.1 (la 0.3.2 en la numeración nueva) con el nombre
  0.3.3 y el `versionCode` 7, a la
  prueba interna; el Honor lo actualiza por el enlace. Después, `git checkout master`. Desde
  ahí, la siguiente versión de Android lleva el `versionCode` 8 o más.
- `git checkout v3.1.1` deja la carpeta en la etiqueta, sin rama («detached HEAD»): es lo
  esperado. Los documentos modificados de Carlos no cambian entre las dos versiones y se
  quedan como están. No se hace ningún commit ahí.

---

## 5. Lo que la 0.4.0 no cubre y hay que mirar en el ensayo

- **Lo que necesita Firebase** no se recorrió con los bancos (10.28, y T-125 tampoco): unirse,
  publicar, pedir y decidir cambios, sincronizar. Está probado en memoria
  (`t80_requests_widget_test`, `t81_office_widget_test`, `t79_sync_engine_test`), en la v3.0
  en campo y en el piloto del ECO BORA con la 3.1.0 (10.47); el ensayo (1.6, 1.7, 1.11,
  1.12, 2.1, 2.2, 2.10, 2.11, 2.13) lo comprueba contra Firebase de verdad.
- **El listado que llega tarde (H2, 10.50)** sigue abierto: con la operación ya publicada, un
  listado nuevo no entra. Importarlo antes de publicar (1.5). Decide Carlos, con la propuesta
  de la sección 8 de `docs/T122-RESULTADOS.md`.
- **Las cifras de Estadísticas se mueven durante la operación** (10.68): cuentan los vacíos
  asignados, como la Lista, y lo dice su ficha (1.16). No es un fallo. Las alertas de estiba
  y la comparación de viajes no los suman.
- **TalkBack** no se probó en el Honor: el anuncio del movimiento sin panel es una
  región en vivo sin dibujo (10.21, H3). Si en el muelle no se oye, anotar.
- **La letra del Honor** distinta de 1.0: las capturas de la candidata son a 1.0; a 1.45
  y 2.0, el plano y la banda están probados en el emulador de 360 × 640, y los avisos, con
  pruebas de widgets a 360 × 640, 360 × 800 (el tamaño del Honor) y 412 × 915 (10.32 a
  10.34); nada de eso en el Honor mismo. Con la letra grande, el aviso dice su texto corto
  y los errores llevan «Ver», que abre el texto entero.
- **Una observación conocida (P3, 10.34)**, que no se anota como fallo nuevo: al reabrir un
  viaje cuyo perfil vigente dejaría contenedores fuera, el aviso «No se aplicó del perfil
  vigente: …» dura 10 s y, en el plano sin operación, tapa parte de la rejilla una vez:
  esperar a que se apague (T-61). La otra de 10.34 (O3, el aviso que cruzaba el pie del riel
  y «En vivo» a 1920 × 1080) quedó cerrada con la entrega 1: en la oficina los avisos viven
  en la franja de cifras (10.40 y 10.46; `DESIGN.md` 14.5).
- **El micrófono** (`uses-feature android.hardware.microphone required=false`, 10.112)
  sigue sin declararse en el manifiesto: Play deja fuera equipos sin micrófono. No afecta
  al Honor.
