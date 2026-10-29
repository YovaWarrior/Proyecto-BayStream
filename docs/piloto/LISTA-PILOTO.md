# Lista de comprobación · Ensayo y prueba piloto con COMAR (la 0.4.1, 10.76 y 10.80)

**Para quién.** Carlos publica la 0.4.1 y corre el ensayo y el piloto; Yov revisa esta
lista y los comandos antes. La lista va por rol: **el muelle con el Honor** y **la oficina con la
laptop**. Cada paso dice qué hay que ver en pantalla y qué hacer si algo falla. Los textos
entre comillas son los rótulos exactos de la app.

**Qué es la 0.4.1.** La versión de la presentación final del 7-nov, publicada a más tardar
el 4-nov (10.76 y 10.80). Es `sprint-4` mezclado en `master` (4.1): la 0.4.0, publicada el
28-oct (10.75), y encima de ella:
- **T-119, el mouse y el touchpad** (10.77 y 10.80): la rueda mueve la silueta del buque;
  Ctrl + rueda y el pellizco del touchpad amplían el plano, con la celda bajo el puntero
  quieta; y la rejilla lleva una barra horizontal cuando la bahía no cabe;
- **T-127, el listado en una operación publicada** (10.79): mientras la operación esté
  abierta, la oficina agrega o reemplaza el listado de la agencia (1.17) y el muelle lo recibe
  solo (2.15). Cierra H2 (10.50). Necesita las reglas de T-127, que se publican antes que los
  clientes (4.0).

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

Lo demás sigue siendo la 3.1.1 que ya se probó en campo. **Si el ensayo falla en algo
serio, se vuelve a la 0.4.0** (4.5), que sigue en Git como `v0.4.0` y con su MSIX en
`build\t93`. Las reglas de T-127 no le estorban: la 0.4.0 trabaja igual con ellas.

**Datos.** En el ensayo, los sintéticos de T-100 (`T100_CARGA.edi`, `T100_LISTADO.xlsx`
y `T100_LLEGADA.edi`: BUQUE MANUAL, viaje M100, escala GTSTC; se generan con
`dart tool/t100_sintetico.dart <salida en %TEMP%>` y `python -I tool/t100_listado.py
<esa salida>`). Para 1.17 y 2.15, una copia del listado con la fila del OR 1 borrada en
Excel y guardada como `T100_LISTADO_v2.xlsx` (sección 8 de `docs/T127-RESULTADOS.md`). En el
piloto, los archivos reales de la escala, que **no salen de la laptop ni del teléfono y no
entran al repositorio**. Ninguna captura muestra «Nube y cuenta», un correo ni un nombre
de cuenta.

---

## 0. Antes del ensayo (Carlos, con la laptop)

| # | Qué hacer | Qué hay que ver | Si falla |
|---|---|---|---|
| 0.1 | Publicar las reglas de T-127 (4.0) y después mezclar `sprint-4` en `master` y publicar los tres clientes, con los comandos de la sección 4 | El cotejo de 4.0 dice que lo publicado son las reglas de T-127 (`FC17842C…`). La Web en `https://baystream-app.web.app/version.json` dice `"version": "0.4.1"` y `"build_number": "7"`; Windows instaló `BayStream_0.4.1.0.msix` (Configuración → Aplicaciones → BayStream 0.4.1.0); Play tiene el AAB 7 (0.4.1) en la prueba interna y el Honor lo actualizó por el enlace de prueba | No sigas con una versión a medias: los tres clientes tienen que ser la 0.4.1. Si una compilación no sale, el ensayo se hace con la 0.4.0 y se anota; las reglas de T-127 se pueden quedar |
| 0.2 | Guardar lo de la 0.4.0 para poder volver: `build\t93\BayStream_0.4.0.0.msix` (y su `.sha256`) en `C:\Proyectos\proyecto-baystream`, la etiqueta `v0.4.0` en Git y, de 4.0, la copia de las reglas de antes, `build\t127\reglas-antes.txt` en `C:\Proyectos\baystream-rediseno` | Los tres existen antes de instalar ningún cliente (`git tag --list v0.4.0` muestra la etiqueta) | Sin el MSIX, volver a Windows 0.4.0 exige recompilarlo desde `v0.4.0` con `tool\t93_msix.ps1 -Version 0.4.0.0`, como en 4.2 |
| 0.3 | Comprobar las cuentas en Firebase (consola, no desde la app): la de oficina y la de muelle existen y están **autorizadas**; las reglas publicadas son las de T-127, cotejadas en 4.0 (no se vuelve a publicar nada) | En la app, al iniciar sesión, «Cuenta autorizada» y el rol correcto («Oficina» o «Muelle») | «Cuenta sin autorizar: …»: el responsable la activa en la consola; la app no lo puede hacer |
| 0.4 | En el Honor: letra del sistema en 1.0 (o la que use el planificador, pero anotada), brillo alto, Wi-Fi o datos encendidos, la app actualizada | El inicio con «Abre un plano de estiba» y «Seleccionar archivo»; la travesía no se dibuja en el teléfono (no sobra sitio): es lo esperado. Con un plano abierto, «Estad.» muestra «contenedores a bordo» y «Carga por bahía, de proa a popa» (desde la 0.4.0), y en Ajustes → Aplicaciones → BayStream la versión es la 0.4.1 | Si la versión no es la 0.4.1, no se actualizó: Play → prueba interna → actualizar |
| 0.5 | En la laptop: Windows con el MSIX 0.4.1.0 abierto una vez (tema «Seguir al sistema» o «Oscuro» en Parámetros; la oficina trabaja de noche) | El inicio con la marca, «Abre un plano de estiba» y, si sobra alto debajo, el buque navegando al pie | Si el instalador dice «Publisher: Unknown» o `0x800B010A`, el MSIX no se firmó con `CN=BayStream`: repetir 4.2 con la huella |
| 0.6 | Tener a mano en la laptop el plan de carga, el listado de la agencia (`.xlsx`) y el plano de llegada de la escala; en el Honor no hace falta ningún archivo: se une a la operación publicada | | |
| 0.7 | Después de 0.1, la prueba de punta a punta de la sección 8 de `docs/T127-RESULTADOS.md`: la oficina en la laptop y el muelle en el Honor, con los sintéticos de T-100 y `T100_LISTADO_v2.xlsx`. Es una operación de prueba, el viaje M100, que se cierra al terminar | Los 14 pasos dan lo que dice su tabla: el listado llega al muelle en la revisión 1 y en la 2, sin red el muelle espera, y los movimientos no cambian | Si un paso falla, anotar cuál y con qué texto, y en el piloto no usar 1.17: el listado se importa antes de publicar (1.5), como en la 0.4.0 |

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
| 1.5 | «Confirmar e importar», en el pie fijo de la página. No hace falta esperar a que se apague el aviso «Archivo "<nombre>" cargado correctamente»: flota por encima del pie. **Lo normal es antes de publicar (1.7)**; después, ver 1.17 | «Listado guardado en la operación de <escala>: N filas.» y el aviso «Listado importado.» En el Plano, en «Orden» y en «Carga», cada celda de carga lleva su OR | Si el botón está apagado, falta una equivalencia: ver 1.4. Si dice «Fila N: …», corregir el Excel y volver a importar. Con la operación ya publicada, el listado también entra: ver 1.17 |
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
| 1.17 | Con la operación ya publicada y abierta, si la agencia manda el listado tarde o corregido: «Lista» → «Listado de la agencia» → «Elegir listado (.xlsx)» (o «Importar otro listado (.xlsx)») → el listado nuevo. Las equivalencias y el cruce, como en 1.4 | Si ya hay movimientos, antes de confirmar sale la tarjeta «Lo ya operado con el listado nuevo»: «N contenedores ya cargados no están en el listado nuevo» y «M vacíos asignados cambian de grupo», con la lista de cada uno. Los movimientos no se pierden ni cambian. «Confirmar e importar» → «Listado guardado en la operación publicada de <escala>: N filas, revisión R. El muelle lo recibe solo.» (T-127) | «La nube no aceptó el listado: …» no cambia nada local: revisar la cuenta (0.3) y que las reglas sean las de T-127 (4.0), y volver a intentar. «Sin conexión con la nube: …»: esperar la red. Con la operación cerrada (1.15), el listado ya no cambia |

---

## 2. Ensayo · El muelle (Honor, Android)

| # | Qué hacer | Qué hay que ver | Si falla |
|---|---|---|---|
| 2.1 | Icono de la nube → «Nube y cuenta» → iniciar sesión con la cuenta de muelle | Rol «Muelle», «Cuenta autorizada». En el inicio, «Operaciones abiertas en la nube (1)» | Ver 0.3. Sin red: «Sin conexión con la nube: unirse requiere red. Conéctate e inténtalo de nuevo.» |
| 2.2 | «Operaciones abiertas en la nube» → «Unirse» → «Abrir plano de llegada» | El plano **sin elegir ningún archivo**: la banda azul de la marca arriba con el buque, «Viaje <n> · <escala>», el chip «Al día» y los segmentos «Descarga / Carga»; abajo la barra Plano · Lista · Avance · Estad. · Más | Si no aparece la operación, la oficina no publicó (1.7). Si el plano abre en previo, la operación trae un perfil distinto: anotar y usar «Confirmar» |
| 2.3 | «Descarga» → tocar una celda que dice **«Baja»** | La celda sale de su sitio en **naranja** («Bajando») y abajo, sobre las cifras de la franja, el aviso «Descargado · <contenedor> · <celda>» con «Deshacer» durante 6 s (con la letra grande, «Descargado · <contenedor>»); después la celda queda «Hecho» con la palomita. En la laptop, «Avance» y «En vivo» lo muestran en segundos | Si no registra: «No se registró: …» dice la causa (operación cerrada, sesión); con la letra grande sale «No se registró.» y «Ver» la muestra. Si el aviso pisa una celda o un control, anotarlo como fallo (que tape las cifras es lo esperado, 10.30). Si la celda no es «Baja» sino «Paso», es carga de paso: ver 2.5 |
| 2.4 | Tocar «Deshacer» en el aviso | La celda vuelve a «Baja»; el movimiento queda anulado «Marcado por error» (no se borra). Pasado el aviso: tocar la celda → «Deshacer la descarga» en el detalle | |
| 2.5 | Tocar una celda **«Paso»** | La pregunta «Re‑estiba»: «<contenedor> no se descarga en <escala>: va a <puerto>…» con «Registrar re‑estiba». Al confirmar, la celda queda «Re‑est.» y el aviso «Re‑estiba registrada · …» | Si fue un toque por error: «Cancelar» |
| 2.6 | «Carga» → «Acciones» (⋮) → «Asignar vacío» | «Vacíos del listado»: «OR N · <contenedor>» con tipo, destino, línea y tara. Al tocar uno, el formulario «Asignar vacío» propone la celda (primero las de su grupo en la bahía) y pide tara real, hora y marchamo opcionales | Sin listado, «Asignar vacío» está apagado y la línea del resumen dice «Sin listado de agencia: los llenos se cargan por su número; los vacíos esperan el listado»: falta el listado en la oficina, 1.5 antes de publicar o 1.17 después, y llega solo (2.15) |
| 2.7 | «Confirmar carga» | «Carga registrada · OR N» con «Deshacer»; la celda sale en naranja y queda cargada con su OR | Si la celda sigue ocupada por el de llegada: «Marcar su descarga y cargar» → «Descarga y carga registradas · OR N» |
| 2.8 | Cargar un lleno: «OR / últimos dígitos» (en la tira del pie) → escribir el OR o los últimos dígitos → «Confirmar carga» | La búsqueda «Confirmar carga por OR o contenedor»; después, igual que 2.7. Un lleno del plan sin fila en el listado sale como «<contenedor> · sin OR en el listado» y se carga por su número («Carga registrada · <contenedor>», H4). El detalle de una celda cargada ofrece «Deshacer carga» con motivo | «No hay coincidencias disponibles.»: el OR no está en el listado o ya se cargó. Un vacío sin fila no se ofrece: espera el listado |
| 2.9 | «Deshacer» en el aviso de una carga | El OR vuelve a estar pendiente y la celda, vacía con su contorno | |
| 2.10 | «Acciones» (⋮) → «Solicitudes de cambio (0)» → «Pedir cambio» | El formulario: «Objeto 1: OR, contenedor o reserva», «Intercambiar dos contenedores» (viene activado) o «Destino BBB-RR-TT», y «Motivo obligatorio» → «Enviar solicitud». La solicitud queda «Pendiente» y la celda destino lleva un borde punteado con el icono de pedir cambio (el lector dice «Solicitud pendiente en <celda>») | «Se necesita una cuenta autorizada y una operación publicada.»: la sesión del teléfono o la publicación (1.7). El objeto sigue en su celda hasta que la oficina apruebe |
| 2.11 | Cuando la oficina decida (1.12) | La solicitud pasa a «Aprobada» o «Rechazada» sin recargar; si se aprobó, el OR cambia de celda en «Carga» | |
| 2.12 | Atrás (el botón del sistema) en el plano | **Un toque**: arriba, sobre el plano, la advertencia «Toca Atrás otra vez para volver al inicio.» durante 2 s, aunque abajo siga el aviso de un movimiento; el plano sigue. **Dos toques seguidos**, dentro de esos 2 s: el inicio, con el viaje en los recientes. Tocar el reciente lo reabre publicado, con la operación | Un toque nunca saca del plano: si sale, anotarlo como fallo. Con una hoja abierta («Más», el detalle), Atrás solo la cierra, y el siguiente Atrás vuelve a advertir |
| 2.13 | Sin red: modo avión **con el Wi-Fi apagado** (10.39) → registrar una descarga | El chip de la banda pasa a «Sin conexión» y la app sigue registrando. Al volver la red, «Enviando» y después «Al día»; la oficina lo recibe. Cuántos esperan lo dice «Nube y cuenta» | Si al volver la red el chip dice «Revisar», mirar «Nube y cuenta»: con «Sesión vencida: …», iniciar sesión otra vez; la cola se envía sola |
| 2.14 | «Más» | «Alertas de estiba» (con su cuenta), «Tapas en la operación», «Orden de descarga», «Listado de la agencia», «Comparar con otro BAPLIE…», «Exportar PDF», «Exportar CSV» y «Exportar JSON», «Nube y cuenta», «Parámetros», «Cargar archivo BAPLIE», «Viajes recientes», «Perfiles guardados» y «Cerrar el plano» | «Cerrar el plano» con el viaje publicado limpia este dispositivo; se vuelve a entrar desde los recientes o uniéndose |
| 2.15 | Cuando la oficina agregue o reemplace el listado (1.17), con red y sin tocar nada | El aviso «Listado actualizado por la oficina: N filas.» durante 6 s; los OR aparecen en las celdas y «OR / últimos dígitos» los ofrece. Lo ya cargado sigue en su celda: un lleno cuya fila ya no está se queda cargado, sin OR, y en la salida va con los datos del plan (1.13) | Sin red, el muelle sigue con el listado anterior y lo baja al volver la red (2.13). Si en medio minuto no llega, «Nube y cuenta» → «Reintentar», o cerrar y abrir el plano, y anotarlo. Un muelle con la 0.4.0 no lo recibe (5) |

---

## 3. El día del piloto

1. **Antes de zarpar nada:** 0.3 a 0.6 repetidos esa mañana; en la laptop, 1.1 a 1.8 con
   los archivos reales; en el Honor, 2.1 y 2.2. Si 2.2 no muestra el plano con la banda
   y «Al día», el piloto se hace con la 0.4.0 (4.5) y se anota por qué.
2. **Durante la descarga:** el muelle hace 2.3 a 2.5 con cada contenedor; la oficina
   mira 1.9 y 1.10. Un toque por error se deshace con «Deshacer» (6 s) o desde el
   detalle; nada se borra.
3. **Durante la carga:** 2.6 a 2.9 y, si hace falta, 2.10 y 1.11 a 1.12; la oficina mira
   1.9 y 1.16. Si el listado llega tarde o corregido: 1.17 en la oficina y 2.15 en el
   muelle.
4. **Si se cae la red** en el muelle: seguir registrando (2.13); «Nube y cuenta» dice
   cuántos esperan. No cerrar sesión ni la app.
5. **Al terminar:** 1.13 a 1.15. El BAPLIE de salida se guarda en la laptop.
6. **Qué anotar para Yov** (sin capturas de cuentas ni datos reales): la hora de cada
   paso, cualquier texto en rojo (con su frase exacta), cualquier toque que no hizo lo
   esperado, el tiempo que tardó la primera visualización en el Honor (RNF-002: tres
   pasos, menos de 30 s), y si la letra del teléfono era 1.0 u otra.

---

## 4. Compilación y publicación (Carlos; Yov revisa antes)

Las versiones de la 0.4.1, una por cliente. Lo publicado antes, la 0.4.0 de 10.75, es Web
0.4.0+6, MSIX 0.4.0.0 y AAB 6:

| Cliente | Versión | Por qué |
|---|---|---|
| Android (AAB, prueba interna de Play) | `0.4.1`, `versionCode` **7** | Play exige que el `versionCode` suba: el 6 ya se usó |
| Windows (MSIX) | **0.4.1.0** | Es mayor que la 0.4.0.0, así que se instala encima, sin desinstalar (4.2) |
| Web (Hosting) | `0.4.1`, compilación **7** | `version.json` lo deja visible |

`pubspec.yaml` dice `version: 0.4.1+7` y `msix_version: 0.4.1.0` (T-128); los comandos
lo repiten en la línea de comandos para no depender de ello. `pubspec.lock` no cambia.

**El orden importa:** primero las reglas de T-127 (4.0), después la mezcla (4.1) y los tres
clientes (4.2 a 4.4). Con las reglas de antes, la 0.4.1 no puede agregar ni reemplazar el
listado (1.17), y lo dice sin cambiar nada; la 0.4.0 trabaja igual con las nuevas.

**Los bloques con comprobaciones van dentro de `& { … }`** (los cotejos de 4.0, 4.1, la
instalación de 4.2, 4.4 y la vuelta de Windows en 4.5). Según cómo se peguen, PowerShell
puede correr cada línea por su cuenta, y entonces un `throw` no detiene las que siguen.
Dentro de las llaves, el bloque entero se detiene en la primera comprobación que falle: en
4.4, por ejemplo, ya no llega a `firebase deploy`.

### 4.0 Las reglas de T-127, antes que los clientes (desde `C:\Proyectos\baystream-rediseno`)

Se publican **desde la consola, nunca con `firebase deploy`** (sección 7 de
`docs/T127-RESULTADOS.md`). El cotejo es `tool/t113_reglas.mjs`: sale con 0 si lo publicado es
idéntico a la propuesta, sin contar el fin de línea ni los espacios al final de cada línea.

1. En Chrome, `https://console.firebase.google.com` → **baystream-app** → **Firestore
   Database** → pestaña **Reglas**.
2. **El respaldo de lo publicado:** en el editor de reglas, Ctrl + A y Ctrl + C, y pegarlo en
   un archivo nuevo, `C:\Proyectos\baystream-rediseno\build\t127\reglas-antes.txt` (VS Code,
   «Guardar como», UTF-8). Cotejarlo con las de T-80, que son las publicadas desde 10.108 de
   `SPRINT-3.md`:

   ```powershell
   & {
   Set-Location -LiteralPath C:\Proyectos\baystream-rediseno
   node tool/t113_reglas.mjs build/t127/reglas-antes.txt build/t127
   if ($LASTEXITCODE -ne 0) { throw 'Parar: lo publicado no son las reglas de T-80; no publicar nada y avisar' }
   'Lo publicado son las reglas de T-80: se puede seguir'
   }
   ```

   La salida dice `"equal": true`, con la huella normalizada de T-80, que empieza por
   `7E57F227`.
3. Abrir `docs\T127-firestore.rules.propuesta` en VS Code, Ctrl + A y Ctrl + C. En el editor de
   la consola, Ctrl + A y pegar encima. No debe quedar ninguna marca roja, y la primera línea
   sigue siendo `rules_version = '2';`. **Publicar.**
4. **El cotejo de lo publicado:** en la consola, Ctrl + A y Ctrl + C, y pegarlo en
   `build\t127\reglas-publicadas.txt` (UTF-8). Después:

   ```powershell
   & {
   Set-Location -LiteralPath C:\Proyectos\baystream-rediseno
   node tool/t113_reglas.mjs build/t127/reglas-publicadas.txt build/t127 docs/T127-firestore.rules.propuesta
   if ($LASTEXITCODE -ne 0) { throw 'Parar: lo publicado no es identico a la propuesta de T-127; corregir en la consola y cotejar otra vez' }
   'Publicadas y cotejadas: las reglas de T-127'
   }
   ```

   La huella normalizada tiene que ser
   `FC17842C227120C8F5AF6AAF732E306290A4071B0383E2BA14455E2F13E566DB`. No hace falta tocar
   índices: la consulta nueva usa el de un solo campo, que Firestore crea solo.

Si algo falla con las reglas nuevas, se vuelve atrás con `reglas-antes.txt` (4.5).

### 4.1 La mezcla (desde `C:\Proyectos\proyecto-baystream`, la carpeta de siempre)

`master` está en `be532ab` («Sprint 4: la 0.4.0, mezcla de sprint-4 a master», con la
etiqueta `v0.4.0`), con el mismo árbol que `7647741` de `sprint-4`.
`C:\Proyectos\baystream-rediseno` es otro árbol de trabajo del mismo repositorio, así que
`sprint-4` es la misma rama local. La mezcla no puede tener conflictos: **si Git marca alguno,
parar y avisar antes de resolver nada.** Los documentos de Carlos modificados en esa carpeta
(hoy, cuatro `.docx` y un `.pdf` de `docs/`) no los toca `sprint-4` y se quedan como están.

```powershell
& {
Set-Location -LiteralPath C:\Proyectos\proyecto-baystream
if ((git branch --show-current) -ne 'master') { throw 'Parar: la carpeta no esta en master' }
if ((git rev-parse HEAD) -notlike 'be532ab*') { throw 'Parar: master no esta en be532ab' }
if (-not (git show sprint-4:pubspec.yaml | Select-String -Pattern '^version: 0\.4\.1\+7' -Quiet)) { throw 'Parar: sprint-4 todavia no trae la 0.4.1' }
git merge --no-ff --no-commit sprint-4
if ($LASTEXITCODE -ne 0) { throw 'Parar: la mezcla no salio limpia; no resolver nada' }
git commit -m "Sprint 4: la 0.4.1, mezcla de sprint-4 a master"
if ($LASTEXITCODE -ne 0) { throw 'Parar: el commit de la mezcla no salio' }
git tag -a v0.4.1 -m "BayStream 0.4.1, el mouse y el touchpad y el listado en una operacion publicada (Sprint 4)"
git push origin master
git push origin v0.4.1
git log --oneline -1
}
```

Las tres comprobaciones del principio detienen el bloque si la carpeta no está en `master`,
si `master` no está en `be532ab` o si `sprint-4` todavía no trae la 0.4.1. La mezcla se
detiene antes del commit («stopped before committing as requested»): es lo esperado, y el
`git commit` la cierra. La última línea tiene que mostrar «Sprint 4: la 0.4.1, mezcla de
sprint-4 a master». Después, la carpeta queda en `master` con la 0.4.1, y `v0.4.0` sigue en
Git para volver (4.5). El rediseño sigue en `C:\Proyectos\baystream-rediseno`, en
`sprint-4`.

### 4.2 Windows (MSIX), desde esa carpeta en `master`

La 0.4.1.0 se instala **encima de la 0.4.0.0, sin desinstalar**: Windows actualiza el paquete,
y los datos siguen en `%LOCALAPPDATA%\BayStream`, fuera de él (10.75). El bloque comprueba lo
instalado, compila, verifica la firma y copia los datos, y solo entonces instala; si algo falla
antes, no toca nada. Va con la app cerrada:

```powershell
& {
Set-Location -LiteralPath C:\Proyectos\proyecto-baystream
if (Get-Process -Name baystream -ErrorAction SilentlyContinue) { throw 'Parar: cierra BayStream antes de seguir' }
$h = @(Get-ChildItem Cert:\CurrentUser\My | Where-Object Subject -eq 'CN=BayStream')
if ($h.Count -ne 1) { throw "Parar: hay $($h.Count) certificados CN=BayStream y tiene que haber 1" }
$app = @(Get-AppxPackage | Where-Object Name -like '*baystream*')
if ($app.Count -ne 1) { throw "Parar: hay $($app.Count) paquetes de BayStream instalados y tiene que haber 1" }
if ([version]$app[0].Version -ne [version]'0.4.0.0') { throw "Parar: la instalada es la $($app[0].Version) y no la 0.4.0.0" }
powershell -NoProfile -ExecutionPolicy Bypass -File tool\t93_msix.ps1 -Huella $h[0].Thumbprint -Version 0.4.1.0
if ($LASTEXITCODE -ne 0) { throw 'Parar: el MSIX no salio o no paso la verificacion; no se instalo nada' }
$msix = 'C:\Proyectos\proyecto-baystream\build\t93\BayStream_0.4.1.0.msix'
$respaldo = "C:\Proyectos\respaldo-almacen-$(Get-Date -Format yyyyMMdd-HHmm)"
robocopy "$env:LOCALAPPDATA\BayStream" "$respaldo\BayStream" /E /R:1 /W:1 /NFL /NDL /NJH
if ($LASTEXITCODE -ge 8) { throw 'Parar: la copia del almacen fallo; no se instalo nada' }
"Se instala la 0.4.1.0 encima de la $($app[0].Version); la copia esta en $respaldo"
try { Add-AppxPackage -Path $msix -ErrorAction Stop } catch { throw "Parar: no se instalo la 0.4.1.0 ($_); la 0.4.0.0 sigue instalada" }
Get-AppxPackage | Where-Object Name -like '*baystream*' | Select-Object Name, Version
}
```

El script de T-93 compila Release con la configuración privada (`-Opciones` apunta a
`C:\Proyectos\baystream-privado\firebase-prod.json` por omisión, sin abrirla) y termina
verificando la firma `Valid`, la huella y el `.sha256`. No borra los paquetes anteriores:
`BayStream_0.4.0.0.msix` sigue en `build\t93` para volver (4.5). La última línea tiene que
mostrar la 0.4.1.0, y la app tiene que abrir con los datos de siempre.

Con la 0.4.0 (28-oct) hubo que quitar antes la 3.1.1, una sola vez, porque 0.4.0.0 era menor
que 3.1.1.0. La copia quedó en `C:\Proyectos\respaldo-almacen-20261028-1300` (592 archivos
del almacén; la carpeta del paquete no tenía ninguno), y la app abrió con los datos de
siempre (10.75).

### 4.3 Android (prueba interna de Play)

```powershell
flutter build appbundle --release --build-name=0.4.1 --build-number=7 --dart-define-from-file=C:\Proyectos\baystream-privado\firebase-prod.json
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
flutter build web --release --output=build/web --build-name=0.4.1 --build-number=7 --dart-define-from-file=C:\Proyectos\baystream-privado\firebase-prod.json
if ($LASTEXITCODE -ne 0) { throw 'No publicar: build fallido' }
if (-not (Select-String -LiteralPath build\web\main.dart.js -Pattern 'flutter-fire-auth' -SimpleMatch -Quiet)) { throw 'No publicar: la Web salio sin Firebase Auth' }
dart run tool/t92_verify.dart build/web
if ($LASTEXITCODE -ne 0) { throw 'No publicar: verificacion fallida' }
firebase deploy --only hosting --project baystream-app
}
```

**Nunca `firebase deploy` a secas** (publicaría las reglas de H5 sobre producción).
Después, abrir `https://baystream-app.web.app` en una ventana de incógnito, comprobar
`version.json` (0.4.1, 7) e iniciar sesión con la cuenta de oficina. Quien ya visitó el
sitio puede ver una vez la versión anterior por el *service worker*: recargar. La primera
línea con `$viejo` ya no hace nada: esa caché se apartó el 2-oct y no ha vuelto (T-125 lo
comprobó); se queda porque es la guía del cierre.

### 4.5 Volver a la 0.4.0 si el ensayo falla

La 0.4.0 es `v0.4.0` (`be532ab`), la publicada el 28-oct (10.75). Se vuelve cliente por
cliente, solo en el que falle, y siempre desde `C:\Proyectos\proyecto-baystream`.

- **Las reglas:** no hace falta volver, porque la 0.4.0 trabaja igual con las de T-127 (sección 4
  de `docs/T127-RESULTADOS.md`). Solo si fallan las reglas mismas: pegar
  `build\t127\reglas-antes.txt` en la consola y publicar. Después, copiar lo publicado a
  `build\t127\reglas-vuelta.txt` y cotejarlo como en el paso 2 de 4.0, con ese archivo en vez
  de `reglas-antes.txt`. Con las reglas de T-80, la 0.4.1 vuelve a decir «La nube no aceptó el
  listado: …» al revisarlo, y no cambia nada local.
- **Windows:** 0.4.0.0 es menor que 0.4.1.0, así que hay que desinstalar antes. Los datos
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
  try { Add-AppxPackage -Path $msix -ErrorAction Stop } catch { throw "Parar: no se instalo la 0.4.0.0 ($_); reinstalar BayStream_0.4.1.0.msix" }
  Get-AppxPackage | Where-Object Name -like '*baystream*' | Select-Object Name, Version
  }
  ```

  Para volver después a la 0.4.1, se instala encima, como en 4.2.
- **Web:** con `git checkout v0.4.0`, el bloque completo de 4.4, sin quitarle ninguna
  comprobación y cambiando solo `--build-name=0.4.0 --build-number=6`. Termina igual que
  4.4, con `firebase deploy --only hosting --project baystream-app`, y se publica una sola
  vez. Después, `git checkout master`.
- **Android:** Play no deja bajar de versión, así que se sube la 0.4.0 con un número mayor:
  con `git checkout v0.4.0`,

  ```powershell
  flutter build appbundle --release --build-name=0.4.0 --build-number=8 --dart-define-from-file=C:\Proyectos\baystream-privado\firebase-prod.json
  ```

  y se sube ese AAB, el código de la 0.4.0 con su nombre y el `versionCode` 8, a la prueba
  interna; el Honor lo actualiza por el enlace. Después, `git checkout master`. Desde ahí,
  la siguiente versión de Android lleva el `versionCode` 9 o más.
- `git checkout v0.4.0` deja la carpeta en la etiqueta, sin rama («detached HEAD»): es lo
  esperado. Los documentos modificados de Carlos no cambian entre las dos versiones y se
  quedan como están. No se hace ningún commit ahí.
- **La 3.1.1** sigue en Git como `v3.1.1` y con su MSIX en `build\t93`, por si hubiera que ir
  más atrás. Sus pasos están en la sección 4.5 de la lista de la 0.4.0:
  `git show cce3c4c:docs/piloto/LISTA-PILOTO.md`.

---

## 5. Lo que la 0.4.1 no cubre y hay que mirar en el ensayo

- **Lo que necesita Firebase** no se recorrió con los bancos (10.28, y T-125 tampoco): unirse,
  publicar, pedir y decidir cambios, sincronizar y, desde la 0.4.1, agregar o reemplazar el
  listado. Está probado en memoria (`t80_requests_widget_test`, `t81_office_widget_test`,
  `t79_sync_engine_test` y las de T-127), con las reglas de T-127 en el emulador, en la v3.0
  en campo y en el piloto del ECO BORA con la 3.1.0 (10.47). El ensayo (1.6, 1.7, 1.11,
  1.12, 1.17, 2.1, 2.2, 2.10, 2.11, 2.13 y 2.15) y la prueba de 0.7 lo comprueban contra
  Firebase de verdad.
- **Un cliente 0.4.0 frente a un listado revisado** (sección 4 de `docs/T127-RESULTADOS.md`):
  si se une a una operación cuyo listado ya se reemplazó, falla con «La fuente «listado de la
  agencia» llegó incompleta o distinta de la publicada. No se guardó nada: vuelve a
  intentarlo»; si ya estaba unido, sigue con el listado viejo, y sus movimientos se aceptan
  igual. Ninguno daña la operación, pero la laptop y el Honor pasan a la 0.4.1 antes de usar
  1.17.
- **El mouse y el touchpad (T-119)** los probó Carlos a mano en Windows, Chrome y Edge
  (10.80). **O-040-1** sigue abierto: en la Web, deslizar dos dedos de lado sobre la silueta
  puede regresar el navegador a la página anterior. Sobre la silueta bastan la rueda o los dos
  dedos hacia arriba y abajo; en la oficina, la app de Windows no tiene ese gesto.
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
