# Lista de comprobación · Ensayo y prueba piloto con COMAR (candidata del rediseño, 10.28)

**Para quién.** Carlos corre el ensayo y el piloto; Yov revisa esta lista y los comandos
antes. La lista va por rol: **el muelle con el Honor** y **la oficina con la laptop**.
Cada paso dice qué hay que ver en pantalla y qué hacer si algo falla. Los textos entre
comillas son los rótulos exactos de la app.

**Qué se prueba.** La candidata del piloto es `sprint-4` con el rediseño (el inicio, el
plano por bahía, la banda del muelle, «En vivo», el paquete de íconos y la travesía) y
las demás pantallas con el tema nuevo. Codex la aceptó en `cc24766`, con los avisos
corregidos (10.34). Lo que no cambió sigue siendo la v3.0 que ya se probó en campo. La
regla de 10.28: **si el ensayo falla en algo serio, el piloto se hace con la v3.0**, que
sigue instalada y probada.

**Datos.** En el ensayo, los sintéticos de T-100 (`T100_CARGA.edi`, `T100_LISTADO.xlsx`
y `T100_LLEGADA.edi`: BUQUE MANUAL, viaje M100, escala GTSTC; se generan con
`dart tool/t100_sintetico.dart <salida en %TEMP%>` y `python -I tool/t100_listado.py
<esa salida>`). En el piloto, los archivos reales de la escala, que **no salen de la
laptop ni del teléfono y no entran al repositorio**. Ninguna captura muestra «Nube y
cuenta», un correo ni un nombre de cuenta.

---

## 0. Antes del ensayo (Carlos, con la laptop)

| # | Qué hacer | Qué hay que ver | Si falla |
|---|---|---|---|
| 0.1 | Mezclar `sprint-4` en `master` y publicar los tres clientes con los comandos de la sección 4 | La Web en `https://baystream-app.web.app/version.json` dice `"version": "3.1.0"` y `"build_number": "4"`; Windows instaló `BayStream_3.1.0.0.msix` (Configuración → Aplicaciones → BayStream 3.1.0.0); Play tiene el AAB 4 (3.1.0) en la prueba interna y el Honor lo actualizó por el enlace de prueba | No sigas con una versión a medias: los tres clientes tienen que ser la 3.1.0. Si una compilación no sale, el ensayo se hace con la v3.0 y se anota |
| 0.2 | Guardar los artefactos de la v3.0 para poder volver: `build\t93\BayStream_3.0.0.0.msix` (y su `.sha256`) y la carpeta `C:\Proyectos\proyecto-baystream` en `sprint-3`, que no se toca | Los dos existen antes de instalar nada nuevo | Sin ellos, volver a Windows 3.0 exige recompilar desde `sprint-3` |
| 0.3 | Comprobar las cuentas en Firebase (consola, no desde la app): la de oficina y la de muelle existen y están **autorizadas**; las reglas publicadas son las de 10.108 (no se vuelve a publicar nada) | En la app, al iniciar sesión, «Cuenta autorizada» y el rol correcto («Oficina» o «Muelle») | «Cuenta sin autorizar»: el responsable la activa en la consola; la app no lo puede hacer |
| 0.4 | En el Honor: letra del sistema en 1.0 (o la que use el planificador, pero anotada), brillo alto, Wi-Fi o datos encendidos, la app actualizada | El inicio con «Abre un plano de estiba» y «Seleccionar archivo»; la travesía no se dibuja en el teléfono (no sobra sitio): es lo esperado | Si el Honor muestra el inicio viejo (botón flotante, barra con ocho acciones), no se actualizó: Play → prueba interna → actualizar |
| 0.5 | En la laptop: Windows con el MSIX 3.1.0.0 abierto una vez (tema «Seguir al sistema» o «Oscuro» en Parámetros; la oficina trabaja de noche) | El inicio con la marca, «Abre un plano de estiba» y, con la ventana a 1280 de ancho o más, el buque navegando al pie | Si el instalador dice «Publisher: Unknown» o `0x800B010A`, el MSIX no se firmó con `CN=BayStream`: repetir 4.2 con la huella |
| 0.6 | Tener a mano en la laptop el plan de carga, el listado de la agencia (`.xlsx`) y el plano de llegada de la escala; en el Honor no hace falta ningún archivo: se une a la operación publicada | | |

---

## 1. Ensayo · La oficina (laptop, Windows; la Web es igual salvo lo que se indica)

| # | Qué hacer | Qué hay que ver | Si falla |
|---|---|---|---|
| 1.1 | «Seleccionar archivo» → el **plan de carga** | El plano abre **en previo**: arriba la banda «Plano sin confirmar: perfil propuesto desde el archivo. Escala propuesta <puerto>.» con «Confirmar», y debajo «Peso por pila y tomas de refrigerado: sin evaluar hasta confirmar el perfil.» Son tres pasos y la rejilla ya se ve | Si sale «Este archivo no parece un BAPLIE…» o «Versión BAPLIE no admitida», pedir la exportación 2.x a la agencia. Si no abre nada en 30 s, anotar y reintentar |
| 1.2 | «Confirmar» en la banda | Se abre «Parámetros del buque»: filas y niveles propuestos, la escala (la propuesta, con «elige tu puerto» si el archivo sale de otro), el límite de apilamiento. **«No lo tengo» no viene marcado**: hay que escribir el límite del manual de estabilidad o marcarlo a mano | Si la escala propuesta es el puerto de salida (hallazgo 5), elegir la escala correcta en la segunda ficha antes de confirmar |
| 1.3 | «Confirmar y ver el plano» | Vuelve al **Plano** (no a la Lista), el chip dice «Publicado», en la cabecera aparece el segmento «Carga» (el plan de carga no ofrece Descarga) | Si vuelve a «Parámetros», algo no cuadra (un mensaje en rojo dice qué): corregir y confirmar otra vez |
| 1.4 | «Lista» → «Listado de la agencia» → «Elegir listado (.xlsx)» → el listado | La página muestra el archivo, «N filas en M agencias · llenos · vacíos», las equivalencias propuestas (40ST → 42G1…) y el cruce «X de X llenos cruzan con el plan». La fila «TOTAL» sale como «1 fila sin entender»: es normal | Si una equivalencia queda «pendiente», elegirla con el lápiz. Si «llenos del plan no están en el listado» es alto, revisar el listado con la agencia antes de importar |
| 1.5 | «Confirmar e importar», en el pie fijo de la página. No hace falta esperar a que se apague el aviso «Archivo … cargado correctamente»: flota por encima del pie | «Listado guardado en la operación de <escala>: N filas.» y el aviso «Listado importado.» En el Plano, «Contenido → Carga» muestra el OR en cada celda | Si el botón está apagado, queda una equivalencia «pendiente»: ver 1.4. Si dice «Fila N: …», corregir el Excel y volver a importar |
| 1.6 | Icono de la nube → **«Nube y cuenta»** → iniciar sesión con la cuenta de oficina | Nombre, rol «Oficina» y «Cuenta autorizada». «Operación de la escala abierta» con buque, viaje y puerto, estado «Solo en este dispositivo» | «Sesión vencida» o «Tu cuenta no está autorizada»: ver 0.3. Sin red: «Sin conexión», esperar la red |
| 1.7 | «Publicar operación» | El estado pasa a «Publicada»; el chip del plano, a «Al día». Desde aquí todo lo registrado antes se queda local y lo nuevo sube | Si «Publicar» falla con «permission-denied», las reglas o la cuenta: consola. **No publicar reglas con `firebase deploy` a secas** (guía del cierre) |
| 1.8 | «Más» → «Cargar archivo BAPLIE» → el **plano de llegada** | Con la misma escala confirmada, **abre publicado sin previo** (regla 7.2 de `DESIGN.md`): «Publicado», y la cabecera ofrece «Descarga» y «Carga». La Lista resume «N se descargan · M se cargan · K de paso» | Si abre en previo con «El archivo sale de X rumbo a Y: confirma la escala», la escala propuesta no es la confirmada: «Confirmar» y elegir la escala de la operación |
| 1.9 | «Avance» (en el riel) | Descarga, carga de llenos y vacíos, cancelados, conflictos y el último movimiento, por bahía y total; se actualiza solo cuando el muelle registra | Si no cambia cuando el muelle registra (paso 2.3), mirar el chip: «Enviando N» o «Sin conexión» en alguno de los dos |
| 1.10 | «Plano», con la ventana a 1200 de ancho o más | El panel «En vivo» a la derecha: «Oficina y N teléfonos del muelle», y una fila por movimiento («Bajado · Muelle · <contenedor> · <celda> · ahora»). Lo que acaba de llegar sale en **naranja** 1.5 s y la bahía destella en la silueta | Con menos ancho no hay panel: el anuncio lo da el lector de pantalla. No es un fallo |
| 1.11 | Cuando el muelle pida un cambio (2.5): en el Plano, «Acciones» (⋮) → «Bandeja de cambios (1)» | La solicitud «Pendiente» con quién la pide, «OR N · contenedor: celda → celda» y el motivo. «Aprobar» y «Rechazar» piden un motivo obligatorio | «Se necesita una cuenta autorizada y una operación publicada»: la sesión o la publicación (1.6, 1.7) |
| 1.12 | «Aprobar» (o «Rechazar») con motivo | La tarjeta pasa a «Aprobada» (el contenedor cambia de celda en el plan) o «Rechazada»; el muelle lo ve sin recargar | Si queda «En conflicto», la celda ya está ocupada: rechazar y pedir otro cambio |
| 1.13 | Al final de la escala: «Lista» → «Generar BAPLIE de salida» | «N contenedores a bordo en la salida. Pendientes: X de carga y Y de descarga.», los cancelados vigentes y «Comparar con la llegada» | Si dice «La escala no tiene una operación guardada…», volver a abrir el plan de carga y confirmar la escala |
| 1.14 | «Guardar BAPLIE de salida» | Windows: el diálogo «Guardar» con `BayStream_<buque>_<viaje>_salida.edi`; al guardar, «Exportación BAPLIE completada». En la Web, el navegador lo descarga | Guardar en una carpeta de la laptop; el archivo no se sube a ningún lado |
| 1.15 | «Nube y cuenta» → «Cerrar operación» | «Publicada y cerrada»; ya no admite movimientos | Solo al terminar de verdad: una operación cerrada no se reabre |

---

## 2. Ensayo · El muelle (Honor, Android)

| # | Qué hacer | Qué hay que ver | Si falla |
|---|---|---|---|
| 2.1 | Icono de la nube → «Nube y cuenta» → iniciar sesión con la cuenta de muelle | Rol «Muelle», «Cuenta autorizada». En el inicio, «Operaciones abiertas en la nube (1)» | Ver 0.3. Sin red: «Sin conexión con la nube: unirse requiere red. Conéctate e inténtalo de nuevo.» |
| 2.2 | «Operaciones abiertas en la nube» → «Unirse» → «Abrir plano de llegada» | El plano **sin elegir ningún archivo**: la banda azul de la marca arriba con el buque, «Viaje <n> · <escala>», el chip «Al día» y los segmentos «Descarga / Carga»; abajo la barra Plano · Lista · Avance · Estad. · Más | Si no aparece la operación, la oficina no publicó (1.7). Si el plano abre en previo, la operación trae un perfil distinto: anotar y usar «Confirmar» |
| 2.3 | «Descarga» → tocar una celda que dice **«Baja»** | La celda sale de su sitio en **naranja** y abajo, sobre las cifras de la franja, el aviso «Descargado · <contenedor> · <celda>» con «Deshacer» durante 6 s (con la letra grande, «Descargado · <contenedor>»); después la celda queda «Hecho» con la palomita. En la laptop, «Avance» y «En vivo» lo muestran en segundos | Si no registra: «No se registró: …» dice la causa (operación cerrada, sesión); con la letra grande sale «No se registró.» y «Ver» la muestra. Si el aviso pisa una celda o un control, anotarlo como fallo (que tape las cifras es lo esperado, 10.30). Si la celda no es «Baja» sino «Paso», es carga de paso: ver 2.5 |
| 2.4 | Tocar «Deshacer» en el aviso | La celda vuelve a «Baja»; el movimiento queda anulado «Marcado por error» (no se borra). Pasado el aviso: tocar la celda → «Deshacer la descarga» en el detalle | |
| 2.5 | Tocar una celda **«Paso»** | La pregunta «Re‑estiba»: «<contenedor> no se descarga en <escala>: va a <puerto>…» con «Registrar re‑estiba». Al confirmar, la celda queda «Re‑estiba» y el aviso «Re‑estiba registrada · …» | Si fue un toque por error: «Cancelar» |
| 2.6 | «Carga» → «Acciones» (⋮) → «Asignar vacío» | «Vacíos del listado»: «OR N · <contenedor>» con tipo, destino, línea y tara. Al tocar uno, el formulario propone la celda (primero las de su grupo en la bahía) y pide tara real, hora y marchamo opcionales | «Importa el listado de agencia para operar por OR»: falta 1.5 en la oficina (viaja con la operación publicada) |
| 2.7 | «Confirmar carga» | «Carga registrada · OR N» con «Deshacer»; la celda sale en naranja y queda «Cargado» con el OR | Si la celda sigue ocupada por el de llegada: «Marcar su descarga y cargar» → «Descarga y carga registradas · OR N» |
| 2.8 | Cargar un lleno: «OR / últimos dígitos» (en la tira del pie) → escribir el OR o los últimos dígitos → «Confirmar carga» | Igual que 2.7. El detalle de una celda cargada ofrece «Deshacer carga» con motivo | «No hay coincidencias disponibles»: el OR no está en el listado o ya se cargó |
| 2.9 | «Deshacer» en el aviso de una carga | El OR vuelve a estar pendiente y la celda, vacía con su contorno | |
| 2.10 | «Acciones» (⋮) → «Solicitudes de cambio (0)» → «Pedir cambio» | El formulario: «Objeto 1: OR, contenedor o reserva», «Intercambiar dos contenedores» (viene activado) o «Destino BBB-RR-TT», y «Motivo obligatorio» → «Enviar solicitud». La solicitud queda «Pendiente» y la celda destino lleva un borde punteado con un reloj («Solicitud pendiente en <celda>») | «Se necesita una cuenta autorizada y una operación publicada»: la sesión del teléfono o la publicación (1.7). El objeto sigue en su celda hasta que la oficina apruebe |
| 2.11 | Cuando la oficina decida (1.12) | La solicitud pasa a «Aprobada» o «Rechazada» sin recargar; si se aprobó, el OR cambia de celda en «Carga» | |
| 2.12 | Atrás (el botón del sistema) en el plano | **Un toque**: arriba, sobre el plano, la advertencia «Toca Atrás otra vez para volver al inicio.» durante 2 s, aunque abajo siga el aviso de un movimiento; el plano sigue. **Dos toques seguidos**, dentro de esos 2 s: el inicio, con el viaje en los recientes. Tocar el reciente lo reabre publicado, con la operación | Un toque nunca saca del plano: si sale, anotarlo como fallo. Con una hoja abierta («Más», el detalle), Atrás solo la cierra, y el siguiente Atrás vuelve a advertir |
| 2.13 | Sin red: modo avión **con el Wi-Fi apagado** (10.39) → registrar una descarga | El chip pasa a «Sin conexión · 1 por enviar» y la app sigue registrando. Al volver la red, «Enviando 1» y después «Al día»; la oficina lo recibe | Si al volver la red queda «Sesión vencida…», iniciar sesión otra vez: la cola se envía sola |
| 2.14 | «Más» | Alertas de estiba (con su cuenta), Tapas en la operación, Orden de descarga, Listado de la agencia, Comparar, Exportar, Nube y cuenta, Parámetros, Cargar archivo BAPLIE, Viajes recientes, Perfiles guardados y «Cerrar el plano» | «Cerrar el plano» con el viaje publicado limpia este dispositivo; se vuelve a entrar desde los recientes o uniéndose |

---

## 3. El día del piloto

1. **Antes de zarpar nada:** 0.3 a 0.6 repetidos esa mañana; en la laptop, 1.1 a 1.8 con
   los archivos reales; en el Honor, 2.1 y 2.2. Si 2.2 no muestra el plano con la banda
   y «Al día», el piloto se hace con la v3.0 (10.28, punto 4) y se anota por qué.
2. **Durante la descarga:** el muelle hace 2.3 a 2.5 con cada contenedor; la oficina
   mira 1.9 y 1.10. Un toque por error se deshace con «Deshacer» (6 s) o desde el
   detalle; nada se borra.
3. **Durante la carga:** 2.6 a 2.9 y, si hace falta, 2.10 y 1.11 a 1.12.
4. **Si se cae la red** en el muelle: seguir registrando (2.13); el chip dice cuántos
   esperan. No cerrar sesión ni la app.
5. **Al terminar:** 1.13 a 1.15. El BAPLIE de salida se guarda en la laptop.
6. **Qué anotar para Yov** (sin capturas de cuentas ni datos reales): la hora de cada
   paso, cualquier texto en rojo (con su frase exacta), cualquier toque que no hizo lo
   esperado, el tiempo que tardó la primera visualización en el Honor (RNF-002: tres
   pasos, menos de 30 s), y si la letra del teléfono era 1.0 u otra.

---

## 4. Compilación y publicación (Carlos; Yov revisa antes)

Las versiones de la candidata (una por cliente, por encima de las publicadas en 10.113:
Web 3.0.0+3, MSIX 3.0.0.0, AAB 3):

| Cliente | Versión | Por qué |
|---|---|---|
| Android (AAB, prueba interna de Play) | `3.1.0`, `versionCode` **4** | Play rechaza un número repetido: el 3 ya se usó |
| Windows (MSIX) | **3.1.0.0** | Windows solo instala encima si la versión sube |
| Web (Hosting) | `3.1.0`, compilación **4** | `version.json` lo deja visible |

`pubspec.yaml` ya dice `version: 3.1.0+4` y `msix_version: 3.1.0.0` (10.112 pedía
alinearlo); los comandos lo repiten en la línea de comandos para no depender de ello.
`pubspec.lock` no cambia.

### 4.1 La mezcla (desde `C:\Proyectos\proyecto-baystream`, la carpeta de siempre)

Codex aceptó la candidata en `cc24766` (10.34); `sprint-4` se sube antes, con el bloque de
esa decisión. El `master` local de esa carpeta está atrasado (sigue en el cierre del
Sprint 2), así que primero se mueve a `origin/master`, que es el mismo commit que
`sprint-3`. Así `git checkout master` no cambia ningún archivo, y los documentos
modificados de la carpeta se quedan como están (Yov, 23-oct; comprobado otra vez el 24).

```powershell
Set-Location -LiteralPath C:\Proyectos\proyecto-baystream
git fetch origin
git branch -f master origin/master
git checkout master
git merge --no-ff --no-commit sprint-4
git commit -m "Sprint 4: candidata del piloto, mezcla a master" --trailer "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>" --trailer "Claude-Session: https://claude.ai/code/session_019U7Cj6wx9Yu57ybB9qzdcL"
git tag -a v3.1 -m "BayStream 3.1.0, candidata del piloto (Sprint 4)"
git push origin master
git push origin v3.1
git log --oneline -1
```

`sprint-3` está contenido en `sprint-4`, así que la mezcla no puede tener conflictos; si
Git marca alguno, parar y avisar antes de resolver. La mezcla se detiene antes del commit
(«stopped before committing as requested»): es lo esperado, y el `git commit` la cierra
con su mensaje y las dos líneas de autoría (10.34). La última línea tiene que mostrar
«Sprint 4: candidata del piloto, mezcla a master». Después, la carpeta queda en `master`
con el código del piloto, y `sprint-3` sigue en Git por si hay que volver. El rediseño
sigue en `C:\Proyectos\baystream-rediseno`, en `sprint-4`.

### 4.2 Windows (MSIX), desde esa carpeta en `master`

```powershell
$h = @(Get-ChildItem Cert:\CurrentUser\My | Where-Object Subject -eq 'CN=BayStream')
$h.Count   # tiene que dar 1
powershell -NoProfile -ExecutionPolicy Bypass -File tool\t93_msix.ps1 -Huella $h[0].Thumbprint -Version 3.1.0.0
```

Sale `build\t93\BayStream_3.1.0.0.msix`; el script compila Release con la configuración
privada (`-Opciones` apunta a `C:\Proyectos\baystream-privado\firebase-prod.json` por
omisión, sin abrirla) y termina verificando la firma `Valid`. Instalarlo encima del
3.0.0.0 y abrir la app una vez.

### 4.3 Android (prueba interna de Play)

```powershell
flutter build appbundle --release --build-name=3.1.0 --build-number=4 --dart-define-from-file=C:\Proyectos\baystream-privado\firebase-prod.json
```

Sin `--no-pub` (10.86). Subir `build\app\outputs\bundle\release\app-release.aab` a la
**prueba interna**; producción queda fuera. Play volverá a avisar que deja fuera equipos
sin micrófono (el permiso de la voz, 10.112): el Honor lo tiene. Después, en el Honor,
actualizar por el enlace de la prueba interna.

### 4.4 La Web (Hosting), el bloque de la guía del cierre con la versión nueva

```powershell
Set-Location -LiteralPath C:\Proyectos\proyecto-baystream
$viejo = '.dart_tool\flutter_build\c00f0219d5d4c3dd1d45ce8ba5ce2f45'
if (Test-Path -LiteralPath $viejo) { Rename-Item -LiteralPath $viejo -NewName 'c00f0219d5d4c3dd1d45ce8ba5ce2f45-viejo-2oct' }
$destino = [IO.Path]::GetFullPath('C:\Proyectos\proyecto-baystream\build\web')
if ($destino -ne 'C:\Proyectos\proyecto-baystream\build\web') { throw 'Destino de Hosting inesperado' }
if (Test-Path -LiteralPath $destino) { Remove-Item -LiteralPath $destino -Recurse -Force }
flutter build web --release --output=build/web --build-name=3.1.0 --build-number=4 --dart-define-from-file=C:\Proyectos\baystream-privado\firebase-prod.json
if ($LASTEXITCODE -ne 0) { throw 'No publicar: build fallido' }
if (-not (Select-String -LiteralPath build\web\main.dart.js -Pattern 'flutter-fire-auth' -SimpleMatch -Quiet)) { throw 'No publicar: la Web salio sin Firebase Auth' }
dart run tool/t92_verify.dart build/web
if ($LASTEXITCODE -ne 0) { throw 'No publicar: verificacion fallida' }
firebase deploy --only hosting --project baystream-app
```

**Nunca `firebase deploy` a secas** (publicaría las reglas de H5 sobre producción).
Después, abrir `https://baystream-app.web.app` en una ventana de incógnito, comprobar
`version.json` (3.1.0, 4) e iniciar sesión con la cuenta de oficina. Quien ya visitó el
sitio puede ver una vez la versión anterior por el *service worker*: recargar.

### 4.5 Volver a la v3.0 si el ensayo falla

- **Windows:** desinstalar BayStream y volver a instalar `build\t93\BayStream_3.0.0.0.msix`
  (Windows no instala una versión menor encima).
- **Web:** desde `C:\Proyectos\proyecto-baystream`, con `git checkout sprint-3` (o `v3.0`),
  el bloque completo de 4.4, sin quitarle ninguna comprobación y cambiando solo
  `--build-name=3.0.0 --build-number=3`. Termina igual que 4.4, con
  `firebase deploy --only hosting --project baystream-app`, y se publica una sola vez.
  Después, `git checkout master` (Yov, 23-oct).
- **Android:** Play no admite bajar de versión: o se compila desde `sprint-3` un AAB con
  `--build-name=3.0.1 --build-number=5` y se sube a la prueba interna, o en el Honor se
  desinstala la app y se instala a mano el APK 3.0 (se pierde el almacén local del
  teléfono; la operación está en la nube).

---

## 5. Lo que esta candidata no cubre y hay que mirar en el ensayo

- **Lo que necesita Firebase** no se recorrió con los bancos (10.28): unirse, publicar,
  pedir y decidir cambios, sincronizar. Está probado en memoria (`t80_requests_widget_test`,
  `t81_office_widget_test`, `t79_sync_engine_test`) y en la v3.0 en campo; el ensayo
  (1.6, 1.7, 1.11, 1.12, 2.1, 2.2, 2.10, 2.11, 2.13) lo comprueba contra Firebase de
  verdad.
- **TalkBack** no se probó en el Honor: el anuncio del movimiento sin panel es una
  región en vivo sin dibujo (10.21, H3). Si en el muelle no se oye, anotar.
- **La letra del Honor** distinta de 1.0: las capturas de la candidata son a 1.0; a 1.45
  y 2.0, el plano y la banda están probados en el emulador de 360 × 640, y los avisos, con
  pruebas de widgets a 360 × 640, 360 × 800 (el tamaño del Honor) y 412 × 915 (10.32 a
  10.34); nada de eso en el Honor mismo. Con la letra grande, el aviso dice su texto corto
  y los errores llevan «Ver», que abre el texto entero.
- **Dos observaciones conocidas (P3, 10.34)**, que no se anotan como fallos nuevos:
  - al reabrir un viaje cuyo perfil vigente dejaría contenedores fuera, el aviso «No se
    aplicó del perfil vigente: …» dura 10 s y, en el plano sin operación, tapa parte de la
    rejilla una vez: esperar a que se apague (T-61);
  - en la laptop a 1920 × 1080, el aviso de un registro cruza el pie del riel y una parte
    de «En vivo», sin tapar la leyenda, las celdas ni los controles (O3): preguntar a COMAR
    si le estorba.
- **El micrófono** (`uses-feature android.hardware.microphone required=false`, 10.112)
  sigue sin declararse en el manifiesto: Play deja fuera equipos sin micrófono. No afecta
  al Honor.
