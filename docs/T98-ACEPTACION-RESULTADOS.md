# T-98 · Aceptación cruzada (Timonel)

Timonel · 21-oct-2026 · Base `sprint3-cierre-2` (`33404a5804be4fad85aab80dd923a7ae9e878ee9`) ·
entrega de Codex `f9a0096`, decisión 10.101 (`0af8da5`).

**Dictamen (actualizado con la 10.104): ACEPTADA con observaciones**, con RNF-006 en
**«cumple»** por la medición limpia de Windows (sección 5).

La primera versión de este informe (`0cb1c48`) decía **NO PASA por RNF-006**, porque los videos
de Windows de Codex mostraban el error más de 3 s después de cerrarse el selector. Esa lectura de
sus cuadros era correcta, pero el retraso **no es del producto**: en una medición limpia no se
reproduce en ninguna de 32 cargas rechazadas (sección 5).

1. **Mis cuatro filas reproducen lo que dice Codex.** Honor sin sesión: 11/11 operaciones sin un
   byte del paquete. Recuperación en el Honor: 2.079 s (caso 01) y 2.076 s (caso 05). Batería de
   RNF-008: CSV idéntico byte a byte, y `ZZZZZ` se acepta en silencio también en el cliente.
   Primera visualización sin perfil: 6 pasos, en 15.5 s con el selector en la carpeta recordada y
   en 20.1 s navegando desde las raíces.
2. **RNF-006 cumple (10.104).** Medí la recuperación de Windows en una copia limpia, sin agente:
   - el aviso de error aparece **0.29–0.52 s** después de cerrarse el selector, en las 32 cargas
     rechazadas de las tomas 1 a 4, 6 y 8;
   - con la sonda a espera fija, igual que en el Honor, del cierre al selector reabierto pasan
     **1.754–2.206 s** en 14 casos, y la **cota más alta es 2.267 s**, con la espera incluida.

   Por la regla de la 10.104 (cota < 3 s), Windows cumple, y RNF-006 queda en «cumple»: mensajes
   218/218, disponibilidad sin red 33/33 y recuperación por debajo de 3 s en los tres clientes.
3. **RNF-004 sigue en «no medible», pero sus razones hay que corregirlas.** El Honor tiene control
   positivo atribuible (el inicio de sesión de la tanda dejó 2 buckets del paquete), y con mi fila
   el Honor cumple la condición A. El defecto del banco de Windows no afecta a la condición A,
   porque sin sesión ninguna operación básica usa Firestore. Lo que sigue sin demostrarse es la
   Web (sin NetLog en A) y Windows (muestreo de sockets, sin bytes).
4. **RNF-008 y RNF-002:** dictámenes confirmados. La corrección del banco de Windows no toca
   `lib/`, pero deja el único `// ignore_for_file` del código Dart del repositorio. El contraste
   de rol del informe es coherente.

**Lo que queda por corregir** en el informe de T-98 y en la 10.101 es de texto: RNF-006 pasa de
«no medible» a «cumple» con la medición de la sección 5, y las razones de RNF-004 cambian como
dice la sección 1. Las observaciones están en la sección 4.

## Base, permisos y aislamiento

- `git log --oneline -3` al empezar: `0af8da5` (10.101) arriba y `f9a0096` debajo. Se cumple la
  condición de arranque. Se leyeron `AGENTS.md`, la ficha de T-98, las decisiones 10.73, 10.82,
  10.88, 10.90, 10.92, 10.93, 10.99 y 10.101, `docs/T63-CRITERIOS-RNF.md` y el informe de T-98
  completo, con énfasis en «Cierre de Fase B · 21-oct-2026» y «Autorización Windows y límite del
  diagnóstico».
- **Copia limpia:** `git -c core.autocrlf=false archive` de `33404a5` en
  `%TEMP%\t98acc-33404a5-21oct\app`, extraída con `tarfile`. 745 archivos. Los 139 archivos de
  producto (137 Dart de `lib/` y los dos `pubspec`) se cotejaron contra los blobs del commit
  (`git cat-file`): **0 diferencias**.
  - Nota: esta laptop tiene `core.autocrlf=true` en la configuración del sistema, y un
    `git archive` sin más escribe CRLF. Así son las copias de Codex: su «139 idénticos» es
    contra su propio archivo, no contra los blobs. La batería da el mismo CSV byte a byte en las
    dos copias, así que no tiene efecto en los resultados.
- **Superposiciones:** solo mis dos instrumentos, `tool/t98acc_main.dart` y
  `tool/t98acc_sinteticos.dart`. La batería, el catálogo y `t98_support.dart` son los de la
  etiqueta: no cambian hasta HEAD.
- **Validación de la copia:** `flutter pub get --offline` (sin cambiar los `pubspec`), suite
  **1063/1063** en 1 min 20 s y `flutter analyze` **sin incidencias**, con mi banco incluido.
- **APK `t98acc`:** `applicationId` `gt.cmartinez.baystream.t98acc` y etiqueta «BayStream T98acc»,
  cambiadas solo en la copia. Release, sin `debuggable`, firmado con el certificado «Android Debug»
  porque la copia no tiene `key.properties`. 68 477 327 bytes, SHA-256
  `9e60db08feebe063ad4b5a9090af93868175ad4608b77753ae326d3eaf7d7f58`.
  - Firebase va configurado por `--dart-define-from-file`, sin abrir el archivo. En Android el
    banco usa la app `[DEFAULT]`, como `lib/main.dart`: el paquete es nuevo y su carpeta privada
    no trae sesión. El banco de Codex usa una app con nombre, y por eso en Android tiene la misma
    trampa de `no-app` que tuvo en Windows (observación 4).
  - Hive con el namespace `t98acc`, en la carpeta privada del paquete.
- **Honor:** NAA-LX3, Android 15, 720×1600 a densidad 320 (360 dp), letra 1.0.
- **Lo que no se hizo:** no se inició sesión. Firebase solo se inicializó en mi app, sin sesión.
  Sin Git de escritura ni `git status`. No se tocaron `lib/`, `test/` ni `pubspec.*`, ni
  «PRUEBA T-105», «PRUEBA T-98», la demo17 o el almacén real. La red de la laptop no se tocó, y
  en el Honor no hizo falta el modo avión.
- **El cliente Windows de Codex sigue abierto:** `baystream.exe` del banco `t98`, PID 35788,
  desde las 10:18. No lo cerré. Tampoco abrí ninguna BayStream en Windows, para no tener dos a
  la vez (10.76).

## 1. Revisión de las cuatro tablas

Cada fila se contrastó con la evidencia que cita, en `%TEMP%\t98-b-33404a5-20oct\`.

### RNF-004 · Seguridad: «no medible» se sostiene, pero dos razones están mal

| Lo que dice el informe | Lo que muestra su evidencia | Juicio |
|---|---|---|
| «Falta de control atribuible Android» impide probar cero bytes | `tanda/honor-sesion/inicio_sesion-despues.json`: tras el inicio de sesión de Carlos en `.t98`, la misma sonda encuentra **2 buckets del paquete** (UID stats rb 7 801 B / tb 4 269 B; una etiqueta de sistema, `0xffffff82`, rb 192 B / tb 64 B) y 1 fila TCP. Antes: 0 buckets. | **Rebajado sin razón.** Ese es el control positivo que pedía 10.90. El de «reabrir con red» no lo era, porque esa operación no transmite. Con el control, el silencio de las 22 lecturas del Honor cuenta, y mi fila lo confirma: **el Honor cumple la condición A**. |
| El defecto de arranque del banco Windows «refuerza esa limitación» | El `no-app` salta al primer uso de Firestore. Sin sesión, ninguna operación básica lo usa: `FirebaseSessionRepository._onUser(null)` no abre el listener de `authorized`, `FirestoreOperationSync` solo toca `operations` al publicar, cerrar o sincronizar, y la presentación usa `VesselRepositoryImpl` solo para `parseBaplieFile`. | **No es así.** El defecto no afecta a la condición A. Windows queda sin demostrar por su instrumento: un muestreo de sockets, sin bytes. |
| HAR sin cobertura probada del worker | En la condición A no hubo NetLog. T-63 pide comprobar con él la actividad del service worker. | Correcto: la Web no se demuestra con el instrumento que fija el criterio. |
| TLS: «cumple las seis conexiones de Chrome auxiliar; conjunto no medible» | `tanda/tls-02/netlog-tls-final.json`: seis sesiones QUIC v1 con saludo completo (3 Firestore, 2 Identity Toolkit, 1 Secure Token), en la partición local. Que QUIC v1 implica TLS 1.3 sale de RFC 9001, §4.2. | Correcto, y consistente con 10.82: Windows, sin ServerHello atribuible; el Honor, como limitación. |
| Credenciales: no medible | Inventario por fuentes, sin abrir secretos. | Correcto: T-63 prohíbe abrir el contenido. |

**El dictamen «no medible» sigue en pie**, porque el 100 % se exige en cada plataforma y ni la Web
ni Windows tienen un instrumento que mida bytes. Lo que el informe tiene que decir es: el Honor
cumple la condición A; la Web y Windows no se pueden demostrar.

### RNF-006 · Tolerancia a fallos: lo que mostraban los videos de Windows de Codex

> **Corregido por la sección 5 (10.104).** La relectura de abajo es fiel a los videos de Codex,
> pero su retraso de más de 3 s no se reproduce en una medición limpia: allí el aviso sale en
> 0.29–0.52 s. La conclusión «no cumple» de la primera versión queda retirada.

**Mensajes (218/218)** y **disponibilidad sin red (33/33):** consistentes con lo citado. Los dos
mensajes que vi en el Honor nombran causa, segmento y acción. **Honor y Web:** las cotas cuadran
con `recuperacion/honor/recuperacion-anotada.json` (2.551, 2.074, 2.230, 2.197, 2.214 y 2.079 s)
y con `recuperacion/web/recuperacion-anotada.json` (de 0.822 a 1.310 s).

**Windows.** El informe lo deja en «no medible» porque la sonda del botón llegó tarde, entre 31.8
y 50.3 s después. Pero el criterio pide, además, que el error esté visible. Con los cuadros que el
propio Codex anotó (`ultimoSelectorVisibleCuadro` y `primerErrorVisibleCuadro`), releídos en sus
videos (PTS estrictamente crecientes, a unos 30 cuadros por segundo):

| Caso | Último cuadro con el selector | Primer cuadro sin él | Último sin error | Primer cuadro con error | Del cierre al error |
|---|---|---|---|---|---|
| 01 bytes | 2247 · 74.975537 | 2248 · 75.005367 | 2350 · 78.403385 | 2351 · 78.434848 | **> 3.398 s** |
| 02 texto | 585 · 19.546182 | 586 · 19.592372 | 690 · 23.037325 | 691 · 23.068891 | **> 3.445 s** |
| 05 sin TDT | 970 · 32.335292 | 971 · 32.381938 | 1079 · 35.971167 | 1080 · 36.002182 | **> 3.589 s** |
| 06 COPRAR | 461 · 15.378493 | 462 · 15.409543 | 526 · 17.546547 | 527 · 17.578752 | > 2.137 s |
| 07 versión | 435 · 14.510603 | 436 · 14.541704 | 542 · 18.082331 | 543 · 18.114200 | **> 3.541 s** |
| 08 vacío | 439 · 14.648507 | 440 · 14.678986 | 492 · 16.411037 | 493 · 16.442118 | > 1.732 s |

- **La lectura.** La confirmación ocurre antes de que el selector se cierre. Por eso el tiempo
  desde la confirmación hasta el error es mayor que el que va del primer cuadro sin selector al
  último cuadro sin error.
  - En 01, 02, 05 y 07 eso ya supera 3 s, antes de exigir que el botón responda: esos cuatro
    rechazos **no cumplen**.
  - En 06 y 08 el error aparece 2.2 y 1.8 s después del cierre. Esos dos quedan sin decidir,
    porque falta la confirmación exacta y la respuesta del botón.
  - «El cierre visible del selector es un proxy» juega a favor de esta cota, no en contra.
- **Lo que se ve en los cuadros.** El selector desaparece en un cuadro, y la app queda quieta,
  con el viaje anterior, hasta que aparece el aviso. El puntero se mueve una vez y se queda
  quieto: el agente no interviene. Las hojas de cuadros están en
  `%TEMP%\t98acc-33404a5-21oct\revision-windows\`, con las cotas en `cotas-cierre-error.json`.
- **No es la primera vez.** En el primer cierre (`90dce4b`, tabla «Windows · Catálogo grabado»),
  del inicio conservador al error pasaban 3.10 s (02), 3.13 s (05) y 3.19 s (07).
- **Lo que no se sabe:** la causa. Puede estar en el regreso del diálogo nativo, en el selector
  de archivos o en la app. El criterio mide lo que espera el usuario, así que cuenta igual.
  - La captura es GDI. No hay indicio de que congelara el contenido de Flutter: el puntero se
    actualiza en todos los cuadros, y Codex vio la animación de la rejilla con el mismo
    grabador.

**Conclusión de la primera versión, retirada:** decía que la cota inferior de esos videos daba
«no cumple». Esa cota valía para esos videos, pero no para el producto. La medición limpia de la
sección 5 da menos de 3 s, y con ella RNF-006 queda en «cumple».

### RNF-008 · Estándares: «no cumple», confirmado

- La batería de mi copia produce el **mismo CSV byte a byte** que la de Codex (SHA-256
  `f3d34a4720465a28e64b87fd791686385cef24711ce777037a1fe7f4eb3d43c4`): 31 filas, 11/11
  positivos aceptados y 18/19 negativos detectados. Solo `ZZZZZ` pasa en silencio, y el control
  SMDG15 avisa.
- La exclusión de la cobertura del IMDG está escrita en la propia pantalla de Alertas: «No se
  evalúa la columna 16b… que tiene prioridad (7.2.3.1)».

### RNF-002 · Usabilidad: «no cumple», confirmado

- 6 pasos sin perfil en los tres clientes, y en mi fila del Honor.
- El tiempo de Windows queda en «no medible» por las pausas del agente. Es razonable: el
  dictamen ya cae por los pasos.
- Idioma y Material 3 salen de mis censos y de T-112, así que no cuentan como fila mía.

### La corrección del banco de Windows

- **No toca `lib/`.** `git show --stat f9a0096`: el informe y seis archivos de `tool/`.
  `git diff --stat 33404a5 HEAD -- lib/ pubspec.yaml pubspec.lock` sale vacío.
- **La causa está bien identificada.** En `cloud_firestore_platform_interface` 8.0.6,
  `FirebaseFirestorePlatform.instance` construye `MethodChannelFirebaseFirestore(app:
  Firebase.app())`. `lib/main.dart` inicializa `[DEFAULT]`; el banco, solo `t98`. No es un
  defecto del producto.
- Dos observaciones sobre el banco van en la sección 4: el `// ignore_for_file` y Android.

### El contraste de rol (muelle en Windows, oficina en la Web): la evidencia es coherente

- **Lo que dice cada pieza:**
  - el «Cuenta sin comprobar · Muelle» del 20-oct es el estado provisional `_unknown` (muelle
    y sin autorizar), que queda cuando no se puede leer `authorized/{uid}`, y eso cuadra con el
    `no-app`;
  - después de la corrección, la sonda lee del servidor `role=dock`, `active=true` para la
    cuenta guardada del banco `t98`;
  - la Web muestra «Oficina autorizada» y publicó. `CloudPage` solo ofrece publicar con
    `authorized` y `role=office`, y la escritura pasó.
- **Lo que se deduce.** Los dos clientes leen el mismo documento, `authorized/{uid}`, con el mismo
  código de `lib/`. Si las dos lecturas son correctas, eran **dos cuentas distintas**. La
  alternativa sería que alguien cambió el rol entre una lectura y otra.
- **Cómo lo trata el informe.** Coherente y prudente: no supone la causa y deja a Carlos
  revisar con qué cuenta entró. Las dos limitaciones están declaradas:
  - «la misma cuenta» es la palabra de Carlos, porque no se compararon identificadores;
  - nunca se vio el cliente de Windows ya corregido con una entrada nueva.

  El contraste no cambia ningún dictamen: la condición B es informativa.

## 2. Mis cuatro filas

| RNF | Fila repetida | Resultado | Dictamen de la fila |
|---|---|---|---|
| 004 | Condición A en el Honor, sin sesión y con red | 11/11 sin transmisión. 19 lecturas forzadas de netstats en 0 bytes, y 1 827 barridos de sockets sin una fila del UID. | **Cumple** en el Honor |
| 006 | Recuperación de los casos 01 y 05 en el Honor | Cotas superiores de 2.079 y 2.076 s | **Cumple** (< 3 s) |
| 008 | `ZZZZZ` y la batería | CSV idéntico al de Codex. `ZZZZZ` aceptado sin aviso en la batería y en el Honor | **No cumple**, confirmado |
| 002 | Primera visualización sin perfil en el Honor | 6 pasos, [15.49, 15.65] s y [19.89, 20.09] s | **No cumple** por pasos; tiempo ≤ 30 s |

### RNF-004 · La condición A en el Honor

**Instrumento** (`tool/t98acc_honor.py red`): fuerza `dumpsys netstats --poll` y suma los buckets
del UID del paquete en «UID stats» y «UID tag stats», nunca el mapa BPF. Además cuenta las filas
del UID en `/proc/net/{tcp,tcp6,udp,udp6}`, y comprueba el modo avión, el Wi-Fi y que el `ping`
responda. No guarda el UID, las direcciones ni la red. Mientras duraron las operaciones, un bucle
en el propio Honor (`muestreo`) barrió las cuatro tablas de `/proc/net` cada 0.2 s.

**Control positivo del instrumento:** 5 `ping` de 1 000 bytes desde el UID del shell suman
exactamente **+5 140 B y +5 paquetes** en cada sentido tras el sondeo forzado
(`honor/control-positivo-shell.json`). El control del paquete es el de la tanda de Codex (arriba).

**Las once operaciones** (avión 0, Wi-Fi 1, `ping` responde, ninguna sesión; lectura tras cada una):

| # | Operación | Lo comprobado |
|---|---|---|
| 1 | Cargar un BAPLIE | A01 desde el selector: se abre «Parámetros del buque» |
| 2 | Confirmar el perfil | «No lo tengo» y «Confirmar y ver el plano»: BUQUE ALFA, 977 / 34 / 8366.1 t |
| 3 | Ver el Plano | La rejilla de la bahía 01 |
| 4 | Navegar bahías | El chip «BAHÍA 03»: la cabecera pasa a «Bahía 03» |
| 5 | Lista y filtros | NV6 → 32; Todas → 977 |
| 6 | Búsqueda | Un ID anonimizado del corpus: 1 resultado |
| 7 | Estadísticas | 977 / 34 / 8366.1 t; 242 llenos, 735 vacíos, 50 refrigerados |
| 8 | Alertas de estiba | 0 posibles incumplimientos · 6 no evaluados · 0 conformes |
| 9 | Exportar | CSV en `Descargas/t98acc`: 115 114 B, 978 filas (cabecera y 977) × 24 columnas |
| 10 | Reabrir un viaje reciente | BUQUE ALFA · V01N: 977 / 34 |
| 11 | Parámetros del buque | Se abre la geometría y se sale con «Cancelar», sin cambios |

**Resultado:**
- las 19 lecturas, desde la instalación hasta el final de la sesión, dan **0 buckets, 0 bytes y
  0 sockets** del paquete;
- la sesión duró unos 25 minutos e incluye el ensayo, las dos primeras visualizaciones, las
  recuperaciones y las cargas de `ZZZZZ` y del caso 03;
- el muestreo hizo 1 827 barridos en 380.4 s, a 0.208 s de media, sin una sola fila del UID.

Como netstats acumula por UID todo el tráfico IP del paquete, con sus etiquetas de sistema,
«0 buckets» al final quiere decir que el paquete no transmitió desde que se instaló.

**Límites:**
- netstats no ve el tráfico local (loopback);
- el muestreo de sockets podría perder conexiones de menos de 0.2 s, pero netstats no, porque
  acumula.

### RNF-006 · La recuperación en el Honor

**El procedimiento** (`tool/t98acc_honor.py recuperacion`):
- A01 queda a la vista.
- «Cargar archivo BAPLIE», el selector, y un toque de 200 ms sobre el caso.
- Una espera fija de 1 s, que queda dentro de la medición, y otro toque en «Cargar archivo
  BAPLIE».
- A 360 dp esa acción está al final de la tira desplazable de la barra (hallazgo 3 del manual).
  La desplacé antes de grabar.

**La anotación:**
- **inicio:** el primer cuadro con la onda del toque sobre el archivo, que es anterior a soltarlo
  y más conservador que el de Codex;
- **fin:** el primer cuadro igual al selector ya asentado, con diferencia media menor de 0.1 en
  gris contra el último cuadro;
- **PTS:** los del video, variables (`screenrecord`), sin suponer cuadros por segundo.

| Caso | Contacto (último sin onda / primero con onda) | Error con el viaje anterior | Selector completo | Cota superior |
|---|---|---|---|---|
| 01 bytes aleatorios | 4.918867 / 4.935156 | cuadro 72 · 5.852122 | cuadro 140 · 6.998000 | **2.079 s** |
| 05 sin TDT | 4.913356 / 4.926744 | cuadro 94 · 6.014833 | cuadro 140 · 6.989822 | **2.076 s** |

**Los mensajes:**
- 01: «Archivo «01_bytes_aleatorios.edi»: Este archivo no parece un BAPLIE: no se reconoce su
  cabecera UNH/S009. Selecciona una exportación BAPLIE completa.»
- 05: «El archivo no trae el nombre del buque en el segmento TDT. Revisa que sea un BAPLIE
  completo o pide una nueva exportación.»

En los dos se ven BUQUE ALFA, 34 bahías y 8366.1 t detrás del aviso. Los videos tienen 149 y 146
cuadros, a 17.2 y 20.5 cuadros por segundo de media. Las cifras de Codex para el mismo cierre
son 2.551 s (01) y 2.230 s (05).

### RNF-008 · El caso `ZZZZZ` y la batería

- **La batería** (`tool/t98_estandares_test.dart`, con `T98_FASE=B` y la base completa): el
  registrador termina con código 0 y su CSV es idéntico al de Codex (arriba).
- **La lista:** la edición UNECE 2025-1 tiene 116 100 códigos en sus tres partes, con las mismas
  huellas del informe (`a578f1ca…`, `b63c997f…` y `65898aef…`). `ZZZZZ` no está; GTSTC y PAMIT
  sí.
- **En el cliente:** `T98ACC_PUERTO_ZZZZZ.edi` es exactamente el caso de la batería (SHA-256
  `c5d19b2a…`, igual a su `fuente_sha256`).
  - Abre en el Honor como BUQUE PRUEBA / T98 / GTSTC: 1 contenedor, 1 bahía y 24.0 t, con la
    tarjeta sin un solo aviso. El contenedor muestra «Destino ZZZZZ».
  - Su gemelo válido (`7c8ba87e…`) se ve igual, con «Destino PAMIT».
  - La app no distingue un puerto inexistente.

### RNF-002 · La primera visualización sin perfil en el Honor

**El procedimiento** (`tool/t98acc_honor.py primera`):
- `pm clear` solo de mi paquete;
- el launcher se lleva a la página del ícono y se comprueba antes de grabar;
- toques a tiempos fijos, sin volcados durante la corrida;
- **inicio:** el toque en el ícono, entre el último cuadro sin pulsar y el primero pulsado;
- **fin:** el primer cuadro con la rejilla en la pestaña «Plano».

**Pasos (6):**
1. ícono;
2. «Seleccionar archivo»;
3. A01 en el selector;
4. «No lo tengo»;
5. «Confirmar y ver el plano», que abre Lista;
6. «Plano».

Los desplazamientos no cuentan.

| Corrida | Selector | Inicio | Rejilla (último sin / primero con) | Duración |
|---|---|---|---|---|
| `sin01` | — | — | — | Descartada: el launcher volvió a su primera página y el toque cayó en la barra de Google. Se abrió la portada de Google, sin búsqueda ni escritura, y se cerró con Inicio |
| `sin02` | Abrió en `Descargas/t98acc`, recordada del ensayo | 2.226844 / 2.266489 | 17.760178 / 17.872833 | **[15.49, 15.65] s** |
| `sin03` | Navegación desde las raíces (raíces → Descargas → t98acc → A01) | 2.275000 / 2.296122 | 22.186633 / 22.368911 | **[19.89, 20.09] s**; ≤ 22.37 s aun desde el cuadro 0 |

- Los videos tienen 376 y 453 cuadros, a 19.8 y 18.9 cuadros por segundo de media.
- En `sin03`, el cuadro de 2.275 s sale negro: es el cuadro que `screenrecord` emite al tocar,
  como en `sin02`. Por eso se da también la cota estricta desde el cuadro 0.
- Las cifras de Codex en el Honor, del primer cierre, eran de 29.0 a 29.6 s, con sus volcados
  dentro del tiempo.

## 3. Repetición y evidencia

Evidencia en `%TEMP%\t98acc-33404a5-21oct\` (privada, no se versiona):
- **la copia y sus registros:** `app\`, `preparacion.json`, `manifiesto-original.json`,
  `pub-get.log`, `suite.log`, `analyze.log`, `conformidad.log` y `build-android.log`;
- **lo generado:** `conformidad\` (CSV y MD), `catalogo\` (8/8 huellas iguales a las de Codex) y
  `sinteticos\`;
- **el Honor:** `honor\red-*.json` (19 lecturas), `honor\muestreo-*.json`,
  `honor\control-positivo-shell.json`, `honor\primera-*.json`, `honor\recuperacion-*.json`,
  `honor\video\*.mp4` y `honor\rev\` (PTS y hojas de cuadros);
- **las capturas:** `honor\condicionA\*.png`, `honor\zzzzz\` y `honor\caso03\`;
- **el resumen:** `resumen-aceptacion.json`;
- **la relectura de Windows:** `revision-windows\`.

El volcado crudo de netstats se borró, porque trae la identidad de la red Wi-Fi. El video
descartado `sin01` muestra la portada de la app de Google, sin texto de la cuenta.

Para repetirlo:

```powershell
git -c core.autocrlf=false archive --format=tar --output=$env:TEMP\t98acc-33404a5-21oct\cierre.tar 33404a5
# extraer con tarfile en ...\app y cotejar lib/ y pubspec.* con `git cat-file blob 33404a5:<ruta>`
cd $env:TEMP\t98acc-33404a5-21oct\app
flutter pub get --offline
flutter test --no-pub
flutter analyze --no-pub
flutter test --no-pub tool/t98_estandares_test.dart --dart-define=T98_FASE=B --dart-define=T98_BASE=33404a5804be4fad85aab80dd923a7ae9e878ee9 --dart-define=T98_SALIDA=$env:TEMP\t98acc-33404a5-21oct\conformidad
# identidad .t98acc solo en la copia, y luego:
flutter build apk --release --target=tool/t98acc_main.dart --dart-define-from-file=C:\Proyectos\baystream-privado\firebase-prod.json
python tool/t98acc_honor.py red 00-instalado-sin-abrir
python tool/t98acc_honor.py primera sin02
python tool/t98acc_honor.py recuperacion rec01 01
```

## 4. Observaciones

**La que cambia un dictamen:**

1. **RNF-006 pasa de «no medible» a «cumple».** La medición limpia de Windows (sección 5) da una
   cota de 2.267 s. El retraso de más de 3 s de los videos de Codex no se reproduce, y su causa
   queda sin determinar.

**Las que no cambian dictámenes:**

2. **Las razones de RNF-004:** el Honor tiene control positivo y cumple la condición A. El
   defecto del banco de Windows no afecta a la condición A (sección 1).
3. **`// ignore_for_file: depend_on_referenced_packages, implementation_imports`** en
   `tool/t98_firestore_bootstrap.dart`.
   - Es el único `// ignore` del código Dart del repositorio (`lib/`, `tool/` y `test/`), y la
     línea base de `CLAUDE.md` es «sin ningún `// ignore:`». El «No issues found» de los
     instrumentos de Codex sale con ese silencio.
   - Está fuera del producto, y no afecta a la medición de análisis estático de T-99, que se
     hizo sobre `33404a5`, donde no existe.
   - Yov decide si queda como excepción declarada.
4. **El banco de Android de Codex tiene la misma trampa.** El APK `.t98` no trae
   `google-services.json`, e `initializeCore` de `firebase_core` 4.13.0 solo lista las apps
   nativas. Así que no hay `[DEFAULT]`, y Firestore fallaría con `no-app` al primer uso.
   - Lo sé por lectura del código; no lo probé con sesión.
   - Sin sesión no afecta a nada. Con la sesión de la tanda, el Honor tampoco podía leer la
     autorización, y el informe no lo menciona.
5. **El cliente Windows `t98` de Codex quedó abierto** (PID 35788) después de su entrega, aunque
   las sesiones ya se habían cerrado. Lo cerró Carlos antes de la medición de la 10.104.
6. **El caso 03 se admite con aviso.** Codex lo canceló siempre en Parámetros. Al confirmarlo,
   la app abre «Tipo de BAPLIE» («En GTPBR hay 0 cargas y 0 descargas») y luego muestra
   «Archivo posiblemente incompleto: faltan 2 segmentos (UNT, UNZ)», con 1 contenedor y 4.0 t.
   - Completa el «03 admitido» del informe: no es silencioso.
   - Para el manual (T-100), ese diálogo sí se alcanza con un archivo sintético.
7. **«Siguiente» en el Plano** solo desplaza la fila de chips; no cambia de bahía. Codex ya lo
   vio en la Web y no lo tomó como fallo. Lo anoto por la etiqueta, que se presta a confusión.
8. **«1 llenos»** en el chip de un viaje con un solo contenedor. Es de la misma familia que
   «1 contenedores» (10.91, lista del Sprint 4).

## 5. Recuperación en Windows, medida limpia (10.104)

Timonel · 21-oct-2026, de 13:18 a 14:15. Yov pidió esta medición para decidir RNF-006 con una
regla fija: si la cota pasa de 3 s, Windows no cumple; si queda por debajo, cumple.

**Resultado: la cota más alta es 2.267 s. Windows cumple, y RNF-006 queda en «cumple».**

### Base y aislamiento

- **Copia limpia nueva** de `33404a5` en `%TEMP%\t98rec-33404a5-21oct\app`, hecha igual que la de
  `t98acc`: 139 archivos de producto idénticos a los blobs del commit. El banco es
  `tool/t98acc_main.dart`, ahora con el namespace `t98rec` por `--dart-define`.
- **Binario release de Windows.** `baystream.exe` SHA-256
  `d90fc9dcc9314ebbe85e2e5ec2e085429601b7b3c2e51f3994aa8837121da9e9`; `data/app.so`
  `ea1ba64a87876922ffa10fddf09b5a557c13e9099e2e5f8f38fe4fe9ba9e2cf3`; 18 archivos en el Release.
  - Firebase va configurado y sin sesión, con la app con nombre `t98rec`.
  - El SDK C++ de Firebase 13.9.0 se tomó en solo lectura del que ya estaba extraído en la copia
    de Codex (`FIREBASE_CPP_SDK_DIR`).
- **Una sola BayStream.** Carlos cerró antes el cliente de Codex (PID 35788). Mi cliente se abrió
  con `explorer.exe` (PID 30080), guardó su almacén en TEMP y se cerró por su PID al final.
- **Pantalla:** 1920×1080 al 125 %, como en las mediciones de Codex. La ventana estuvo
  **maximizada**, que es el estándar de Windows de la 10.97. Codex grabó su recuperación con la
  ventana de 1600×900.
- **El viaje anterior** es A01: BUQUE ALFA, 977 contenedores, 34 bahías y 8366.1 t.
- **Los ocho archivos** son los de `catalogo-final` de Codex
  (`%TEMP%\t98-b-90dce4b-19oct\catalogo-final`), con las mismas huellas que su recuperación del
  cierre 2.
- **La grabación** se hizo con el grabador de Codex (`tool/t98_grabar_escritorio.py`): gdigrab
  continuo a unos 30 cuadros por segundo, solo el rectángulo de la ventana (1920×1020), una toma
  sin cortes por tanda.

### Cómo se midió

- **El disparo.**
  - En las tomas 1 a 4 lo hizo Carlos, con el ratón.
  - Desde la toma 6, por decisión de Carlos («hazla tú, hazla solo»), lo hizo un script mío,
    `tool/t98acc_recuperacion_auto.py`. Abre el selector con un clic en «Cargar archivo BAPLIE»,
    escribe la ruta en «Nombre» y confirma «Abrir» por mensaje de Win32.
  - No intervino el agente ni el control de escritorio que paró a Codex.
- **La sonda del botón.** Igual que en el Honor, se hace a espera fija: el script pulsa
  «Cargar archivo BAPLIE» después del cierre del selector, solo si el aviso rojo está a la vista
  y BayStream está al frente y maximizada.
  - La espera pedida es de 1 s. La efectiva fue de 1.15–1.20 s, por las comprobaciones previas al
    clic, y queda dentro de la medición.
  - El botón está en (1764, 65), medido por su resaltado. La X de «Limpiar datos» está en x 1815.
- **La medición** se hizo con `tool/t98_video.py` de Codex:
  - **inicio:** el primer cuadro sin el selector;
  - **fin:** el primer cuadro con el selector reabierto y ya completo, es decir, después del
    marco blanco y del pintado parcial;
  - en ese cuadro se ven a la vez el aviso de error y el viaje anterior;
  - la incertidumbre suma el intervalo de cuadro de los dos extremos, y la cota es la medición
    más esa incertidumbre.
- **La comprobación a ojo** se hizo con `tool/t98_video_cuadros.py`, sobre los casos 01 y 05 de
  la toma 6.
- **Para ubicar los cuadros** se usó un detector propio (`tool/t98acc_recuperacion_windows.py`),
  que propone cuándo aparece y desaparece el selector y el aviso rojo.

### Los ocho casos (tomas 6 y 7)

| # | Caso | Cuadros: cierre / aviso / selector completo | Cierre → aviso | Cierre → selector (`t98_video`) | Cota |
|---|---|---|---|---|---|
| 1 | 01 bytes aleatorios | 178 / 189 / 231 | 0.33–0.41 s | 1.773 ± 0.074 s | 1.847 s |
| 2 | 02 texto sin EDIFACT | 425 / 438 / 479 | 0.40–0.47 s | 1.812 ± 0.073 s | 1.885 s |
| 3 | 05 sin TDT | 669 / 681 / 734 | 0.37–0.44 s | 2.206 ± 0.060 s | **2.267 s** |
| 4 | 06 COPRAR | 915 / 928 / 971 | 0.42–0.45 s | 1.873 ± 0.045 s | 1.918 s |
| 5 | 07 versión no admitida | 1159 / 1171 / 1214 | 0.38–0.44 s | 1.829 ± 0.046 s | 1.876 s |
| 6 | 08 vacío | 1403 / 1413 / 1458 | 0.31–0.37 s | 1.824 ± 0.054 s | 1.878 s |
| 7 | 01, repetición | 1648 / 1660 / 1702 | 0.37–0.43 s | 1.822 ± 0.066 s | 1.888 s |
| 8 | 02, repetición | 1892 / 1904 / 1948 | 0.36–0.44 s | 1.862 ± 0.062 s | 1.925 s |
| 9 | 05, repetición | 2134 / 2147 / 2190 | 0.40–0.46 s | 1.856 ± 0.072 s | 1.928 s |
| 10 | 07, repetición | 2379 / 2392 / 2432 | 0.39–0.47 s | 1.773 ± 0.095 s | 1.868 s |
| — | 03 segmento cortado | — | — | — | No es un rechazo: abre «Parámetros del buque» sin aviso. Al cancelar vuelve BUQUE ALFA intacto, con «Carga cancelada: no se confirmó la geometría del buque» |
| — | 04 sin UNT/UNZ | — | — | — | No es un rechazo: se admite con el aviso rojo «Archivo posiblemente incompleto: faltan 2 segmentos (UNT, UNZ)» y el gris «cargado correctamente», con 977 / 34 / 8366.1 t |

- **Lo que pesa en el intervalo.** Del clic de la sonda al selector completo pasan 0.46–1.04 s.
  El caso 3 es el más lento porque el selector tardó más en terminar de pintarse.
- **Los mensajes** son los del Honor: nombran el archivo, la causa, el segmento (UNH/S009, TDT o
  UNH) y la acción.
- **El viaje anterior** queda a la vista detrás del aviso y del selector en todos los casos.

### La prueba de la carpeta de OneDrive (toma 8)

El selector de Codex mostraba la carpeta del corpus en OneDrive (Escritorio › Archivos .EDI ›
Anonimizados › files, con la columna «Estado»), y su agente escribía la ruta completa. Repetí eso:
el script entra primero a esa carpeta y después escribe la ruta del caso.

| Caso | Cierre → aviso | Cierre → selector (`t98_video`) | Cota |
|---|---|---|---|
| 01 | 0.37–0.44 s | 1.754 ± 0.059 s | 1.813 s |
| 02 | 0.39–0.48 s | 1.801 ± 0.082 s | 1.882 s |
| 05 | 0.42–0.50 s | 1.757 ± 0.080 s | 1.837 s |
| 07 | 0.40–0.47 s | 1.782 ± 0.082 s | 1.864 s |

**El retraso de Codex no se reproduce.** Repetí sus condiciones: la misma base, los mismos
archivos, la misma pantalla, la ruta escrita en «Nombre» y la carpeta de OneDrive.
- Quedan dos diferencias sin controlar:
  - la ventana: mía maximizada, la suya de 1600×900;
  - su sesión: el binario `8944a086…`, compilado antes de la corrección del banco, y su entorno de
    control.
- La causa de sus 3.4–3.7 s queda sin determinar.

### Las tomas con Carlos (1 a 4), como apoyo

| Toma | Lo que se hizo | Del cierre al aviso | Por qué no decide |
|---|---|---|---|
| 1 | 7 rechazos (01 dos veces, 02, 05, 06, 07 y 08) | 0.29–0.40 s | Hacia el segundo 122 se pulsó la X de «Limpiar datos» y los casos se hicieron sin viaje anterior. El botón se pulsó 5–11 s después |
| 2 | Reabrir A01 y el 01 | 0.37–0.44 s | Sin sonda |
| 3 | 01, 02, 05, 06, 07 y 08, con A01 | 0.30–0.51 s | Sin sonda inmediata. Durante el aviso del 02 se abrió la ficha de un contenedor con un clic: la app respondía |
| 4 | 01, 02, 05 y 07, con sonda humana en los tres primeros | 0.39–0.52 s | Del cierre al selector: 01, 2.79–2.89 s; 02, 3.44–3.51 s; 05, 2.69–2.77 s. La reacción de Carlos, del aviso al clic, fue de 1.4–2.2 s, y la app respondió al clic en 0.73–0.93 s |

La toma 4 muestra por qué la sonda tiene que ser a espera fija, como en el Honor y la Web:
con una persona, el 02 pasa de 3 s solo por los 2.2 s de reacción. La toma 5 quedó vacía, porque
Carlos pidió que la hiciera yo solo.

### Incidentes y privacidad

- Una captura inicial de pantalla completa mostraba el navegador de Carlos. **Se borró**, y desde
  entonces solo se grabó el rectángulo de la ventana.
- La toma 1 incluye unos segundos de la ventana de este chat, mientras Carlos leía. Es evidencia
  privada en TEMP.
- La toma 8 muestra los nombres de la carpeta del corpus en OneDrive. También es privada.

### Evidencia

En `%TEMP%\t98rec-33404a5-21oct\`:
- **la copia y su compilación:** `app\`, `preparacion.json`, `build-windows.log` y
  `release-manifiesto.json`;
- **los videos:** `video\toma1.mp4` a `toma8.mp4`, con su `.captura.json`. Las huellas de 16
  caracteres son `bdee9062…`, `47f9abe6…`, `083005df…`, `2a1e5475…`, `0b15c80f…`, `1c4c47e1…`,
  `0a36d895…` y `a717b68f…`;
- **el análisis, en `rev\`:**
  - los PTS de cada toma, los eventos del detector y los casos;
  - la medición de `t98_video.py` (`toma6-medicion\`, `toma8-medicion\`);
  - los cuadros de `t98_video_cuadros.py`;
  - los registros del conductor (`toma6-conductor.json`, `toma8-conductor.json` y
    `toma7-03.json` / `toma7-04.json`).

## Estado final

- **El Honor:** letra **1.0**, avión **0**, Wi-Fi **1**, `show_touches` y `pointer_location` en
  `null`, y la app `t98acc` detenida.
  - Al empezar estaba al frente la `.t98` de Codex. Pasó al fondo con Inicio, sin abrirla ni
    cerrarla. Ahora está al frente el launcher.
  - Quedan instalada la app `gt.cmartinez.baystream.t98acc` (51 BayStream en total) y siete
    archivos en `Descargas/t98acc`: A01 anonimizado, su CSV, los casos 01, 03 y 05, y los dos
    sintéticos UN/LOCODE. Carlos decide si se borran
    (`adb uninstall gt.cmartinez.baystream.t98acc` y `adb shell rm -r /sdcard/Download/t98acc`).
  - En la medición de la 10.104 no se tocó el Honor.
- **La laptop:** mi cliente `t98rec` (PID 30080) se cerró por su PID al terminar. No queda
  ninguna BayStream abierta, ni `ffmpeg`, ni scripts de sonda, ni comandos de Flutter. Carlos ya
  había cerrado el cliente de Codex.

**SEMÁFORO: libre.**

## Archivos de esta aceptación

- `docs/T98-ACEPTACION-RESULTADOS.md`: este informe (nuevo).
- `tool/t98acc_main.dart`: banco del Honor, namespace `t98acc` (nuevo).
- `tool/t98acc_sinteticos.dart`: los dos casos UN/LOCODE de la batería, como archivos (nuevo).
- `tool/t98acc_honor.py`: netstats, muestreo, grabación, primera visualización y recuperación
  (nuevo).

Ya versionados en `0cb1c48`. En la 10.104 se suman:
- `docs/T98-ACEPTACION-RESULTADOS.md`: el resumen corregido y la sección 5 (modificado).
- `tool/t98acc_main.dart`: el namespace por `--dart-define` (`T98ACC_NAMESPACE`); por omisión
  sigue siendo `t98acc` (modificado).
- `tool/t98acc_sonda_windows.py`: las comprobaciones y el clic de la sonda de Windows (nuevo).
- `tool/t98acc_recuperacion_auto.py`: el conductor de los casos sin persona (nuevo).
- `tool/t98acc_recuperacion_windows.py`: el detector de cuadros candidatos (nuevo).

No cambian `lib/`, `test/`, `pubspec.yaml` ni `pubspec.lock`.

## Tres líneas para Carlos

Repetí una fila de cada RNF en una copia limpia de `sprint3-cierre-2`, y las cuatro coinciden con Codex.
Medí la recuperación de Windows sin agente: el aviso sale en 0.29–0.52 s y el selector se reabre con una cota máxima de 2.267 s.
RNF-006 queda en «cumple», y T-98 queda ACEPTADA con observaciones.

## Mensaje para Yov

> Yov: terminé la medición de la 10.104. **La recuperación de Windows cumple, con una cota de
> 2.267 s.** Con tu regla, RNF-006 queda en «cumple», y mi aceptación de T-98 pasa a **ACEPTADA
> con observaciones**. El NO PASA de `0cb1c48` queda retirado.
>
> **Cómo:**
> - copia limpia de `33404a5` con `t98rec`; exe `d90fc9dc…`, app.so `ea1ba64a…`;
> - una sola BayStream, abierta con `explorer.exe` y cerrada por su PID; ventana maximizada a
>   1920×1080 y 125 %; los ocho archivos de `catalogo-final`;
> - gdigrab continuo, medido con `t98_video.py`.
>
> **El resultado:**
> - en 32 rechazos, el aviso aparece 0.29–0.52 s después de cerrarse el selector;
> - con la sonda del botón a espera fija, como en el Honor (1 s pedido, 1.15–1.20 s efectivo y
>   dentro de la medición), del cierre al selector reabierto y completo pasan 1.754–2.206 s en 14
>   casos: los seis rechazos, la repetición de 01, 02, 05 y 07, y otros cuatro con el selector en
>   la carpeta de OneDrive, como lo tenía Codex. La cota más alta es 2.267 s;
> - el 03 abre «Parámetros» sin aviso y cancelar conserva el viaje; el 04 se admite con el aviso
>   de UNT/UNZ.
>
> **Por qué el disparo es del script:** por decisión de Carlos («hazla tú, hazla solo»), desde la
> toma 6 el archivo se confirma por mensaje de Win32, sin el control de escritorio. En la toma 4,
> con sonda humana, el 02 llegó a 3.44–3.51 s solo por 2.2 s de reacción.
>
> **Lo de Codex:** su retraso de 3.4–3.7 s no se reproduce, ni siquiera con su carpeta de
> OneDrive y la ruta escrita. Quedan dos diferencias: su ventana de 1600×900, y su binario
> (`8944a086…`) y su entorno. La causa queda sin determinar.
>
> **Sigue igual:** RNF-004 en «no medible», con el Honor que cumple la condición A; RNF-008 y
> RNF-002 en «no cumple», y las observaciones 2 a 8.
>
> Windows cerrado por PID; no toqué el Honor; SEMÁFORO: libre.

## Git: solo Carlos ejecuta

`pubspec.yaml` y `pubspec.lock` no cambian. El primer bloque ya se ejecutó (`0cb1c48`); este es
el de la 10.104:

```powershell
git add -- docs/T98-ACEPTACION-RESULTADOS.md
git add -- tool/t98acc_main.dart
git add -- tool/t98acc_sonda_windows.py
git add -- tool/t98acc_recuperacion_auto.py
git add -- tool/t98acc_recuperacion_windows.py
git commit -m "Sprint 3: T-98 aceptada, recuperacion de Windows medida sin agente y RNF-006 cumple"
git push
```
