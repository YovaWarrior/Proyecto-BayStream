# T-98 · Aceptación cruzada (Timonel)

Timonel · 21-oct-2026 · Base `sprint3-cierre-2` (`33404a5804be4fad85aab80dd923a7ae9e878ee9`) ·
entrega de Codex `f9a0096`, decisión 10.101 (`0af8da5`).

**Dictamen: NO PASA, por un solo dictamen: RNF-006.**

1. **Mis cuatro filas reproducen lo que dice Codex.** Honor sin sesión: 11/11 operaciones sin un
   byte del paquete. Recuperación en el Honor: 2.079 s (caso 01) y 2.076 s (caso 05). Batería de
   RNF-008: CSV idéntico byte a byte, y `ZZZZZ` se acepta en silencio también en el cliente.
   Primera visualización sin perfil: 6 pasos, en 15.5 s con el selector en la carpeta recordada y
   en 20.1 s navegando desde las raíces.
2. **RNF-006 no es «no medible»: según su propia evidencia, no cumple.** En los videos de Windows
   de Codex, el error aparece más de 3 s después de cerrarse el selector en 4 de los 6 rechazos
   (3.40, 3.44, 3.59 y 3.54 s como mínimo). La confirmación no puede ser posterior a ese cierre,
   así que el intervalo es una cota inferior de la recuperación. La sonda tardía solo impedía dar
   una cota superior; nunca impidió ver que el error ya llegaba tarde.
3. **RNF-004 sigue en «no medible», pero sus razones hay que corregirlas.** El Honor tiene control
   positivo atribuible (el inicio de sesión de la tanda dejó 2 buckets del paquete), y con mi fila
   el Honor cumple la condición A. El defecto del banco de Windows no afecta a la condición A,
   porque sin sesión ninguna operación básica usa Firestore. Lo que sigue sin demostrarse es la
   Web (sin NetLog en A) y Windows (muestreo de sockets, sin bytes).
4. **RNF-008 y RNF-002:** dictámenes confirmados. La corrección del banco de Windows no toca
   `lib/`, pero deja el único `// ignore_for_file` del código Dart del repositorio. El contraste
   de rol del informe es coherente.

**Para que pase** basta una corrección de texto, sin repetir mediciones: RNF-006 en «no cumple»
por la recuperación de Windows, en el informe de T-98 y en la decisión de Yov. Con eso, la
aceptación queda **ACEPTADA con observaciones** (sección 4), y mis cuatro filas siguen valiendo.

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

### RNF-006 · Tolerancia a fallos: la evidencia de Windows da «no cumple»

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

**Conclusión:** el «no medible» no depende solo de que falte el tiempo de Windows. El tiempo de
Windows existe como cota inferior, y da **no cumple**. RNF-006 debería quedar en «no cumple».

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

**La que decide el dictamen:**

1. **RNF-006 en Windows** (sección 1): la cota inferior supera 3 s en 4 de 6 rechazos, así que
   el dictamen correcto es «no cumple». Si Yov prefiere una medición propia de Windows, sin
   agente y con el diálogo guiado por script, cabe aparte. La cota de arriba no depende de
   ella.

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
5. **El cliente Windows `t98` de Codex sigue abierto** (PID 35788), aunque las sesiones ya se
   cerraron. No lo cerré.
6. **El caso 03 se admite con aviso.** Codex lo canceló siempre en Parámetros. Al confirmarlo,
   la app abre «Tipo de BAPLIE» («En GTPBR hay 0 cargas y 0 descargas») y luego muestra
   «Archivo posiblemente incompleto: faltan 2 segmentos (UNT, UNZ)», con 1 contenedor y 4.0 t.
   - Completa el «03 admitido» del informe: no es silencioso.
   - Para el manual (T-100), ese diálogo sí se alcanza con un archivo sintético.
7. **«Siguiente» en el Plano** solo desplaza la fila de chips; no cambia de bahía. Codex ya lo
   vio en la Web y no lo tomó como fallo. Lo anoto por la etiqueta, que se presta a confusión.
8. **«1 llenos»** en el chip de un viaje con un solo contenedor. Es de la misma familia que
   «1 contenedores» (10.91, lista del Sprint 4).

## Estado final

- **El Honor:** letra **1.0**, avión **0**, Wi-Fi **1**, `show_touches` y `pointer_location` en
  `null`, y la app `t98acc` detenida.
  - Al empezar estaba al frente la `.t98` de Codex. Pasó al fondo con Inicio, sin abrirla ni
    cerrarla. Ahora está al frente el launcher.
  - Quedan instalada la app `gt.cmartinez.baystream.t98acc` (51 BayStream en total) y siete
    archivos en `Descargas/t98acc`: A01 anonimizado, su CSV, los casos 01, 03 y 05, y los dos
    sintéticos UN/LOCODE. Carlos decide si se borran
    (`adb uninstall gt.cmartinez.baystream.t98acc` y `adb shell rm -r /sdcard/Download/t98acc`).
- **La laptop:** no queda ningún comando de Flutter, `ffmpeg` ni app mía abierta. La única
  BayStream abierta es la de Codex.

**SEMÁFORO: libre.**

## Archivos de esta aceptación

- `docs/T98-ACEPTACION-RESULTADOS.md`: este informe (nuevo).
- `tool/t98acc_main.dart`: banco del Honor, namespace `t98acc` (nuevo).
- `tool/t98acc_sinteticos.dart`: los dos casos UN/LOCODE de la batería, como archivos (nuevo).
- `tool/t98acc_honor.py`: netstats, muestreo, grabación, primera visualización y recuperación
  (nuevo).

No cambian `lib/`, `test/`, `pubspec.yaml` ni `pubspec.lock`.

## Tres líneas para Carlos

Repetí una fila de cada RNF en una copia limpia de `sprint3-cierre-2` con `t98acc`, y las cuatro coinciden con Codex.
La evidencia de Windows de Codex muestra el error más de 3 s después del selector en 4 de 6 rechazos: RNF-006 no cumple.
NO PASA solo por eso; corrigiendo ese dictamen (y las razones de RNF-004) queda ACEPTADA con observaciones.

## Mensaje para Yov

> Yov: acepté T-98 (Timonel, 21-oct) en una copia limpia de `33404a5` con `t98acc`. Suite
> 1063/1063 y analyze 0. Dictamen: **NO PASA, solo por RNF-006**.
>
> **Mis filas:**
> - 004: Honor sin sesión, 11/11 con 0 bytes en 19 lecturas forzadas de netstats y 1 827 barridos
>   de sockets; control del instrumento +5 140 B.
> - 006: Honor, 01 en 2.079 s y 05 en 2.076 s.
> - 008: CSV de la batería idéntico al de Codex; `ZZZZZ` sin aviso también en el Honor.
> - 002: 6 pasos, 15.5 s con la carpeta recordada y 20.1 s navegando.
>
> **RNF-006:** en los videos de Windows de Codex, con sus propios cuadros anotados, el error
> aparece más de 3.40, 3.44, 3.59 y 3.54 s después del cierre del selector en los casos 01, 02,
> 05 y 07. Eso es una cota inferior: la sonda tardía no la invalida. RNF-006 debería quedar en
> «no cumple». Es una corrección de texto, sin repetir mediciones.
>
> **RNF-004** sigue «no medible», pero:
> - el Honor sí tiene control positivo (la tanda dejó 2 buckets del paquete) y cumple la
>   condición A;
> - el `no-app` de Windows no afecta a la condición A, porque sin sesión no se usa Firestore.
>
> **Otras observaciones:** el `// ignore_for_file` de `t98_firestore_bootstrap.dart` es el único
> del código Dart; el banco Android de Codex tiene la misma trampa de `[DEFAULT]`; el cliente
> Windows de Codex sigue abierto (PID 35788); el caso 03 se admite con aviso de UNT/UNZ.
>
> El contraste de rol es coherente: apunta a dos cuentas distintas, y el informe no lo supone.
> Honor en 1.0 y sin avión. SEMÁFORO: libre.

## Git: solo Carlos ejecuta

`pubspec.yaml` y `pubspec.lock` no cambian.

```powershell
git add -- docs/T98-ACEPTACION-RESULTADOS.md
git add -- tool/t98acc_main.dart
git add -- tool/t98acc_sinteticos.dart
git add -- tool/t98acc_honor.py
git commit -m "Sprint 3: aceptacion cruzada de T-98, cuatro filas repetidas y RNF-006 por corregir"
git push
```
