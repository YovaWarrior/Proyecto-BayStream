# T-98 · Instrumentos RNF-004, 006, 008 y 002

Capitán Codex · 17-oct-2026 · Fase A · base `9ae744a` de `sprint-3`.

**Vigencia:** la sección «Fase B · Cierre 90dce4b», al final, registra el
trabajo actual del 19-oct. Prevalece sobre los pendientes y bloques Git
históricos de las secciones anteriores, que se conservan como trazabilidad.
La corrección 10.81 fue versionada en `46202d7` (decisión 10.82).

## Corrección 10.81

Capitán Codex · 18-oct-2026 · base solicitada `194f140`.

### Cambios y criterio de conformidad

- Se trasladó `test/t98_estandares_test.dart` a
  `tool/t98_estandares_test.dart`. Es un instrumento que se ejecuta a mano,
  fuera de la suite por defecto, con un único `testWidgets` para alojar el
  registro. No hay aprobados/reprobados por caso ni se invierte ninguna
  expectativa para declarar conforme al producto.
- Conserva los 28 especímenes sintéticos y agrega un control SMDG15 del
  detector de aviso visible: **29 filas de observaciones**, sin añadir
  pruebas a `test/`. Para cada una registra caso, norma, tipo, comportamiento,
  aviso visible, datos sintéticos leídos, huella de fuente, fase y base.
- **Negativo detectado = «rechaza» o «avisa» de forma visible**. Una
  advertencia almacenada en el modelo o una validación del oráculo de pruebas
  no bastan. Para la observación «avisa» se renderiza `VoyageSummaryCard` real
  y se recoge el texto de avisos dentro del área visible. No sustituye los
  recorridos en Windows, Web y Honor de la Fase B.
- `.gitattributes` incorpora exactamente `web/vendor/**/*.js -text`, por la
  autorización específica de 10.81. No se editaron los JS ni sus huellas.
- `tool/t98_tls.py` usa `ssl` de Python. El antiguo `.ps1` queda como
  envoltorio compatible de entrada, sin instalar ni invocar OpenSSL externo.
  Se añaden cuatro autopruebas Python de TLS: **10 en total**, fuera del
  cómputo de pruebas Dart.

No se modificaron `lib/`, el codec, reglas, congelados, clientes reales ni
`pubspec.yaml`/`pubspec.lock`. Los 12 casos de
`test/t98_instrumentos_test.dart` permanecen sin cambios. No se utilizó el
Honor ni ninguna sesión Firebase.

### Copia nueva y T-92

El árbol de trabajo ya está en `3d5c83a`, con T-107 B y la decisión 10.81.
Para respetar la base pedida se creó un **clone nuevo de la revisión exacta
`194f1401d01217d3cbf1126aa099cb6948eb0df3`** en
`%TEMP%\t98-correccion-1081-194f140\clone`.
Se usó `git clone --revision`, autorizado expresamente en esta corrección,
sin cambiar la rama ni el índice del repositorio de Carlos. No se reescribió
`194f140` y no se ejecutó `git status`.

La copia aplica `core.autocrlf=true` y
`core.attributesFile=C:/Proyectos/proyecto-baystream/.gitattributes` durante la
extracción inicial: esto permite ensayar la regla aún sin commit. Después se
copió también `.gitattributes` a la raíz del clone. Se superpusieron solamente
las rutas de esta corrección. Las dependencias instaladas se reutilizaron con
`package_config.json` y `package_graph.json`; sin `pub get` ni dependencias nuevas.

La inspección binaria de los archivos recién extraídos registró:

| JS servido en `web/vendor/firebase/12.17.0/` | CRLF | LF | SHA-256 coincide con `servedSha256` |
|---|---:|---:|---|
| `firebase-app.js` | 0 | 2850 | Sí |
| `firebase-auth.js` | 0 | 3 | Sí |
| `firebase-firestore-pipelines.js` | 0 | 3 | Sí |

Evidencia: `%TEMP%\t98-correccion-1081-194f140\js-copia.json` y `clone.txt`.
El fallo anterior de T-92 era una conversión de finales de línea al extraer
la copia en Windows, **no un defecto del producto**.

**T-92 pasa 7/7 en esta copia nueva**, con código de salida 0. Se ejecutó
`flutter test --no-pub test/t92_web_test.dart --reporter expanded`, tras
comprobar que los procesos Dart previos habían terminado y con luz verde de
Carlos. Registro: `%TEMP%\t98-correccion-1081-194f140\t92-correccion.txt`.

### Tabla del ensayo del lector

Corrida manual sobre la copia de `194f140`, con luz verde individual de Carlos.
Se generaron **29 filas**: los 28 especímenes anteriores y un control de
aviso visible. El único `testWidgets` terminó con código 0 porque el
instrumento produjo su salida, **no porque los casos sean conformes**.

| Caso | Norma | Tipo | Qué hace el lector hoy | Aviso visible |
|---|---|---|---|---|
| BBBRRTT 0010002 | BBBRRTT | positivo | acepta en silencio |  |
| BBBRRTT 0020182 | BBBRRTT | positivo | acepta en silencio |  |
| BBBRRTT 9999999 | BBBRRTT | positivo | acepta en silencio |  |
| BBBRRTT 01234 | BBBRRTT | negativo | acepta en silencio |  |
| BBBRRTT 01200000 | BBBRRTT | negativo | acepta en silencio |  |
| BBBRRTT 012A082 | BBBRRTT | negativo | acepta en silencio |  |
| BBBRRTT -120082 | BBBRRTT | negativo | acepta en silencio |  |
| Dígito válido CSQU305438 | ISO 6346 | positivo | acepta en silencio |  |
| Dígito alterado CSQU305438 | ISO 6346 | negativo | acepta en silencio |  |
| Dígito válido TSTU000098 | ISO 6346 | positivo | acepta en silencio |  |
| Dígito alterado TSTU000098 | ISO 6346 | negativo | acepta en silencio |  |
| Dígito válido ABCU123456 | ISO 6346 | positivo | acepta en silencio |  |
| Dígito alterado ABCU123456 | ISO 6346 | negativo | acepta en silencio |  |
| WT KGM 24000 | KGM / SOLAS | positivo | acepta en silencio |  |
| VGM KGM 24000 | KGM / SOLAS VGM | positivo | acepta en silencio |  |
| WT LBR 24000 | KGM / SOLAS | negativo | acepta en silencio |  |
| WT TNE 24000 | KGM / SOLAS | negativo | acepta en silencio |  |
| SMDG22 grupos 1, 2 y 3 | BAPLIE 2.2.1 | positivo | acepta en silencio |  |
| Grupo 4 clase 3 ONU 1993 | BAPLIE 2.2.1 | positivo | acepta en silencio |  |
| Sin UNB | BAPLIE 2.2.1 | negativo | acepta en silencio |  |
| Sin UNH | BAPLIE 2.2.1 | negativo | rechaza |  |
| Sin BGM | BAPLIE 2.2.1 | negativo | acepta en silencio |  |
| Sin TDT | BAPLIE 2.2.1 | negativo | rechaza |  |
| Sin UNT | BAPLIE 2.2.1 | negativo | acepta en silencio |  |
| Sin UNZ | BAPLIE 2.2.1 | negativo | acepta en silencio |  |
| Cabecera COPRAR:D:95B:UN:SMDG22 | BAPLIE 2.2.1 | negativo | rechaza |  |
| Cabecera BAPLIE:D:13B:UN:SMDG31 | BAPLIE 2.2.1 | negativo | rechaza |  |
| Cabecera TDT+99+ | BAPLIE 2.2.1 | negativo | rechaza |  |
| Control SMDG15 con aviso | Control del instrumento | control | avisa | Versión 1.5, leída con las reglas de 2.x; revisa pesos y peligrosas |

La tabla se copió de la salida real, sin dictamen RNF: 23 aceptaciones
silenciosas (incluyen los positivos), cinco rechazos y un aviso visible
de control. Los 13 negativos conocidos siguen aceptados en silencio en
esta base; se conservan como observaciones para T-108 y Fase B.
Ningún dato de este ensayo se presenta como medición del cierre.

Evidencia: `%TEMP%\t98-correccion-1081-194f140\conformidad\conformidad.csv`,
`conformidad.md` y `conformidad-correccion.txt`.

Para ejecutarlo a mano desde la copia nueva, **con su propio semáforo**:

```powershell
flutter test --no-pub tool/t98_estandares_test.dart --reporter expanded --dart-define=T98_BASE=194f140 --dart-define=T98_FASE=A --dart-define=T98_SALIDA="$env:TEMP/t98-correccion-1081-194f140/conformidad"
```

Produce `conformidad.csv` y `conformidad.md` en esa carpeta TEMP y se niega a
sobrescribir una corrida. En Fase B se declara `T98_FASE=B` y el hash completo
del commit de cierre en `T98_BASE`; la tabla sirve para dictaminar RNF-008
entonces, sin dictámenes automáticos en la Fase A.

### TLS con Python, sin instalaciones

Se usan límites mínimo y máximo de TLS 1.1 para el negativo, con
`DEFAULT:@SECLEVEL=0` **solo en ese contexto de cliente de prueba**. Hay un
saludo de control TLS 1.2 por host. `ssl.MemoryBIO` comprueba que el cliente
puede generar el ClientHello; la conexión real registra si envió bytes del
saludo antes de recibir una alerta. No se envía HTTP ni se usan credenciales.

El instrumento separa negociación, alerta recibida del servidor, error del
cliente, fallo de validación de certificado y transporte inconcluso.
EOF/reset/timeout y protocolos/cifrados no disponibles localmente nunca se
presentan como rechazo del servidor. Una alerta remota tampoco certifica por
sí sola su política mínima. La versión de las conexiones del SDK sigue
pendiente de Chrome Security en la Fase B.

Ejercitación realizada, **no medición de cierre ni dictamen RNF**:

| Host | Control TLS 1.2 | Intento TLS 1.1 |
|---|---|---|
| `firestore.googleapis.com` | Negocia TLS 1.2 | Negocia TLS 1.1 |
| `identitytoolkit.googleapis.com` | Negocia TLS 1.2 | Negocia TLS 1.1 |
| `securetoken.googleapis.com` | Negocia TLS 1.2 | Negocia TLS 1.1 |

No se fuerza ni se inventa el rechazo esperado. Este comportamiento queda
anotado para corroborarlo en el entorno de Fase B; no se cambia el umbral.
Salida sanitizada: `%TEMP%\t98-correccion-1081-194f140\tls-python.json`.
La biblioteca disponible de Python es `OpenSSL 3.0.18`; no se instaló una
herramienta OpenSSL ni una dependencia de producción.

```powershell
python tool/t98_tls.py --salida "$env:TEMP/t98-correccion-1081-194f140/tls-otra-corrida.json" --fase A --base 194f140
# Alternativa mediante el punto de entrada PowerShell:
./tool/t98_tls.ps1 -Base 194f140 -Fase A -Salida "$env:TEMP/t98-correccion-1081-194f140/tls-wrapper.json"
```

### Validaciones de la corrección

| Verificación | Estado |
|---|---|
| Clone nuevo de base exacta con JS LF y huellas correctas | Comprobado |
| `flutter test --no-pub test/t92_web_test.dart --reporter expanded` en el clone | **7/7**, código 0; `t92-correccion.txt` |
| Suite por defecto de la base corregida | **934/934**, código 0; `suite-correccion.txt` |
| `flutter analyze --no-pub` | **0 incidencias**, sin `// ignore` nuevos; `analyze-correccion.txt` |
| Instrumento manual y tabla CSV/MD | **29 observaciones**, un registrador completado, código 0; `conformidad-correccion.txt` |
| Autopruebas Python | **10/10**, `python-autopruebas.txt` en TEMP |
| Wrapper PowerShell TLS | Sintaxis validada |
| TLS Python | Seis saludos ejercitados, sin sesión ni datos de la app |

No se atribuyen a esta corrección las 30 pruebas de T-107 B que están en el
HEAD actual: se valida la base pedida `194f140`. En el árbol con T-107 B el
total esperado tras el traslado sería 964 = 922 + 30 + 12; no se ha ejecutado
allí una suite ni se modifica su trabajo concurrente.

**Piso verificado de esta base: 934/934 = 922 + 12.** Los 28 casos trasladados
dejan de formar parte de la suite por defecto. El control visible adicional
solo agrega una fila al instrumento manual, no una prueba unitaria. Las diez
autopruebas Python se informan aparte. No hay saltos de conteo ni pruebas
omitidas mediante `skip` para obtener el verde.

Carlos autorizó individualmente T-92, la suite, el registrador y el análisis.
Al reanudar había tres procesos Dart activos; se esperó a que terminaran antes
de iniciar Flutter y se ejecutó un único comando a la vez. Los registros
están en `%TEMP%\t98-correccion-1081-194f140\`; no se sobrescribieron binarios
ni almacenes de las apps reales o de demo17. No se abrió ningún cliente ni
se consultó «PRUEBA T-105».

### Archivos y Git de la corrección

Rutas exactas: `.gitattributes` (nuevo), `tool/t98_estandares_test.dart`
(traslado y adaptación), `test/t98_estandares_test.dart` (retirado),
`tool/t98_tls.py` (nuevo), `tool/t98_tls.ps1` (modificado),
`test/t98_auxiliares_test.py` (modificado) y este informe (modificado).
`pubspec.yaml` y `pubspec.lock` **sin cambios**.

Bloque para Carlos, con las verificaciones de la corrección completadas.
El traslado se registra con ambas rutas; no se usa `git mv` ni se reescribe
el commit anterior. El prefijo «Sprint 3:» rige el commit nuevo.

```powershell
git add -- .gitattributes
git add -- tool/t98_estandares_test.dart
git add -- test/t98_estandares_test.dart
git add -- tool/t98_tls.py
git add -- tool/t98_tls.ps1
git add -- test/t98_auxiliares_test.py
git add -- docs/T98-RESULTADOS.md
git commit -m "Sprint 3: corrige instrumentos de T-98 segun decision 10.81"
git push
```

Tres líneas de la corrección:

La conformidad se registra manualmente en tool/ y deja la suite unitaria separada.
La regla -text preserva los JS servidos y TLS usa exclusivamente Python instalado.
La copia de 194f140 da 934/934, T-92 7/7 y analyze cero; la tabla real tiene 29 filas.

Mensaje para Yov:

La corrección 10.81 de T-98 está verificada, sin commit y sin cambios en lib/.
La batería pasó a tool/ y registra silencio, aviso visible o rechazo, sin dictamen por caso.
Clone nuevo de 194f140: JS con LF y huellas correctas; T-92 7/7, suite 934/934 y analyze cero.
El instrumento generó CSV/MD con 29 filas: los 28 especímenes y el control visible SMDG15.
Los 13 negativos siguen aceptados en silencio en esa base; quedan registrados para T-108/Fase B.
TLS Python ejercitado sin instalaciones; los tres hosts negociaron 1.1 en el ensayo.
Python 10/10; Honor, sesión y mediciones de cierre siguen pendientes.

## Fase A · Entrega histórica del 17-oct (194f140)

Las instrucciones de ejecución, el bloqueo y el bloque Git de esta sección
son históricos: para el estado actual y los comandos vigentes, ver
«Corrección 10.81» arriba. No ejecutar su bloque Git ni reinstalar instrumentos.

**Instrumentos preparados; no se declara cerrada la Fase A mientras la batería
de conformidad conserve casos fallidos. No se ha realizado la Fase B.**
Los ensayos de este documento verifican los instrumentos sobre HEAD; no son
mediciones RNF, ni cambian los dictámenes históricos. No hay tiempos de respuesta,
tasas de transmisión, porcentajes de idioma/M3 ni SUS nuevos.

Se leyeron la ficha completa de T-98, las decisiones 10.73 y 10.80 y ambos
documentos de T-63. Se mantienen los criterios confirmados por Carlos.
La hipótesis es única: SUS pertenece al **indicador 6**, no a una «H6».

### Base, aislamiento y límites del ensayo

- Las fuentes se extrajeron de HEAD con `git archive`, operación de lectura,
  a `%TEMP%\t98-fase-a-9ae744a\head`. Se incorporaron exclusivamente los
  instrumentos T-98 del árbol. Así no se incorporan cambios concurrentes de
  Timonel en T-107 parte B.
- Se reutilizaron las dependencias instaladas mediante `package_config.json`
  con rutas resueltas y `package_graph.json`. No hubo `pub get`, dependencias
  nuevas ni cambios de `pubspec.yaml` o `pubspec.lock`.
- Toda ejecución de Flutter tuvo autorización individual de Carlos. Los
  comandos fueron secuenciales y usaron el `build/` de la copia temporal.
- No se abrió ninguna app BayStream, ningún cliente demo17 ni ninguna sesión.
  No ejecuté comandos ADB ni operé el Honor. No se accedió a «PRUEBA T-105».
- No se compiló ningún cliente: el arranque real de `t98_main.dart`, el aislamiento
  efectivo del SDK y la apertura/cierre por PID quedan sin ensayar.
- La evidencia de los ensayos reside en `%TEMP%\t98-fase-a-9ae744a\`.
  El informe no contiene datos del corpus, cuentas, credenciales ni volcados de sesión.

### Instrumentos y ejecución

Los ejemplos se ejecutan desde una copia de las fuentes. Para Flutter, pedir
antes **SEMÁFORO** a Carlos. Los ejemplos de compilación son preparación para
Fase B; **no se ejecutaron hoy**. Nunca compilar sobre los binarios de otra tarea.

| Archivo | Función | Ensayo de Fase A |
|---|---|---|
| `tool/t98_support.dart` | TEMP, SHA-256, separación EDIFACT, CSV UNECE, oráculo del dígito ISO 6346 y mensaje sintético | Usado por catálogo, corpus y autopruebas |
| `tool/t98_catalogo_invalidos.dart` | Ocho entradas, semilla 98, manifiesto con clase y huellas; no sobrescribe casos | Generado desde A01 real anonimizado |
| `tool/t98_ensayo_invalidos.dart` | Comprueba la ejercitación del catálogo sin cronometrar ni volcar excepciones | Ejecutado; no equivale a probar recuperación UI |
| `tool/t98_estandares_corpus.dart` | Lectura del corpus, cobertura por contexto/grupo, posiciones, lista UNECE e IDs anonimizados | Ejecutado con los diez archivos A01–A08 y las dos variantes VGM |
| `test/t98_estandares_test.dart` | 28 casos sintéticos de conformidad, positivos y negativos, sobre funciones reales | Ver registro de la suite; los negativos fallidos no se ocultan |
| `test/t98_instrumentos_test.dart` | 12 autopruebas de catálogo, oráculos, CSV, TEMP, SHA y cobertura contextual | Incluidas en la suite |
| `test/t98_auxiliares_test.py` | Seis autopruebas de sanitización, extracción, PTS y hojas vacías | 6/6 |
| `tool/t98_inventario.py` | Censo de literales y controles, ubicación/huella, indicios de causa/acción/segmento y columnas de revisión | Ejecutado sobre las fuentes de HEAD |
| `tool/t98_preparar.py` | Protocolo fijo, hojas vacías de operaciones, recuperación, primera visualización, piloto y SUS | Ejecutado; 24 filas de recuperación y 30 de primera visualización vacías |
| `tool/t98_sonda_red_windows.ps1` | TCP y UDP por PID, tiempo real de consulta, errores separados de «cero sockets» | Autoprueba con el propio proceso de consola, sin BayStream |
| `tool/t98_honor_red.ps1` | netstats antes/después, filtrado por UID en memoria, comprobación de avión/Wi-Fi/ping | Preparado; sin ejecutar por la reserva del Honor |
| `tool/t98_tls.ps1` | Saludo TLS 1.2 de control y negativo 1.1 a tres hosts; distingue fallos del cliente | Sintaxis validada; no se encontró OpenSSL instalado, no se instaló |
| `tool/t98_sanitizar.py` | Resúmenes por lista permitida de HAR/NetLog; omite consultas, rutas, headers y cuerpos | CLI con entradas sintéticas y autopruebas de no filtración |
| `tool/t98_video.py` | Diferencias de PTS reales entre cuadros anotados, tasa/intervalos e incertidumbre | Video negro sintético con FFmpeg/ffprobe; sin medir UI |
| `tool/t98_clientes_windows.ps1` | Abrir por Explorer, cerrar por PID, grabar a TEMP; rechaza apps ajenas/demo17 | Sintaxis validada; apertura/cierre/captura de escritorio sin ejecutar |
| `tool/t98_main.dart` | UI real con repositorios Hive `t98`, FirebaseApp `t98` y Auth/Firestore explícitos | Análisis estático; clientes sin compilar/abrir |

Ejercitación de scripts (Dart directo no invoca Flutter):

```powershell
$r = Join-Path $env:TEMP 't98-nuevo-ensayo'
$corpus = 'C:\Users\Giova\OneDrive\Documentos\OneDrive\Desktop\Archivos .EDI\Anonimizados\files'
$unece = 'C:\Proyectos\baystream-privado\unlocode\2025-1\release\csv'
dart tool/t98_catalogo_invalidos.dart "$corpus/CORPUS_A01.edi" "$r/catalogo"
dart tool/t98_ensayo_invalidos.dart "$r/catalogo" "$r/invalidos"
dart tool/t98_estandares_corpus.dart $corpus $unece 2025-1 "$r/corpus"
python tool/t98_inventario.py . "$r/inventario"
python tool/t98_preparar.py "$r/hojas" --commit 9ae744a --fase A
python test/t98_auxiliares_test.py
```

Para repetir la suite y el análisis, **cada comando requiere su propio semáforo**:

```powershell
flutter analyze --no-pub
flutter test --no-pub --reporter expanded
```

Para compilar los clientes en Fase B: copia limpia del commit que anuncie Carlos,
`--target tool/t98_main.dart`, y configuración privada habitual solo cuando
corresponda. `T98_FIREBASE=false` (predeterminado) sirve para ensayos sin SDK;
**no es la condición A válida de RNF-004**. La condición A requiere Firebase
configurado con `--dart-define=T98_FIREBASE=true`, pero ninguna sesión iniciada.
En Android debe prepararse la identidad `.t98` exclusivamente en la copia de
compilación, sin cambiar el Android del árbol compartido. En Web, perfil/origen
exclusivo y ventana visible. Validar la instancia Firebase nombrada en cada
plataforma antes de iniciar sesión; el namespace Hive por sí solo no aísla Auth.

Ejemplos de instrumentos de Fase B, **sin ejecutar**:

```powershell
./tool/t98_clientes_windows.ps1 -Accion abrir -Exe '<copia t98>/build/windows/x64/runner/Release/baystream.exe'
./tool/t98_sonda_red_windows.ps1 -AppPid <PID-reservado> -Operacion cargar_baplie -Condicion A -Salida "$env:TEMP/t98-b/red-carga.json"
./tool/t98_clientes_windows.ps1 -Accion grabar -Segundos 30 -Salida "$env:TEMP/t98-b/recuperacion-01.mkv"
./tool/t98_clientes_windows.ps1 -Accion cerrar -AppPid <PID-reservado>
./tool/t98_honor_red.ps1 -Momento antes -Operacion cargar_baplie -Salida "$env:TEMP/t98-b/honor"
./tool/t98_honor_red.ps1 -Momento despues -Operacion cargar_baplie -Salida "$env:TEMP/t98-b/honor"
./tool/t98_tls.ps1 -OpenSsl '<ruta existente a openssl.exe>' -Salida "$env:TEMP/t98-b/tls.json"
python tool/t98_sanitizar.py har "$env:TEMP/t98-b/original.har" "$env:TEMP/t98-b/har"
python tool/t98_sanitizar.py netlog "$env:TEMP/t98-b/netlog.json" "$env:TEMP/t98-b/netlog"
python tool/t98_video.py "$env:TEMP/t98-b/recuperacion-01.mkv" "$env:TEMP/t98-b/video-01" --tipo recuperacion --inicio <cuadro> --fin <error-visible> --viaje-anterior <cuadro> --boton-responde <cuadro>
```

Los valores entre `<...>` se sustituyen por observaciones reales; no son datos.
La medición de video usa índices de cuadro desde cero, no segundos divididos
por fps nominales. Para primera visualización se usa
`--tipo primera_visualizacion --inicio <icono> --fin <rejilla> --pasos <conteo>`.
El analista debe confirmar los hitos en los cuadros; el script no reconoce la UI.

### RNF-004 · Hoja de medición de Fase B

| Submétrica | Umbral/condición fijada | Medición | Dictamen |
|---|---|---|---|
| Operaciones básicas locales | 100% sin transmisión en A; 11 operaciones desglosadas de 4.1 por cliente | Pendiente | Pendiente Fase B |
| Con sesión, fuera de compartida | Informativa; mismo recorrido | Espera a Carlos y «PRUEBA T-98» | Sin dictamen normativo |
| TLS real y negativo | TLS 1.2+; Security de Chrome y rechazo remoto de 1.1 | Pendiente OpenSSL y sesión | Pendiente Fase B |
| Credenciales | Mecanismos nativos seguros; inventario sin abrir contenido | Inspección de fuentes, tabla siguiente | Sin dictamen de medición |

Los sockets TCP/UDP no indican payload ni bytes y pueden perder conexiones
breves. La sonda de Windows es exactamente un instrumento de muestreo, no una
prueba de ausencia de transmisión. NetLog debe comprobarse con actividad real
originada por el worker, correlacionada en la traza global. Un nombre de evento
o la ausencia de eventos no demuestran cobertura. Los resúmenes sanitizados
requieren clasificación humana privada antes de eliminar los originales
transitorios. No registrar el inicio de sesión en video ni capturar payloads
de autenticación. El TLS negativo sin control positivo o que falla por protocolos
deshabilitados en el propio OpenSSL es inconcluso.

Inventario de sesión por fuentes, **sin leer archivos de credenciales**:

| Plataforma/capa | Qué guarda y dónde | Fuente | Estado para «nativos seguros» |
|---|---|---|---|
| Común, caché propia | Último operador: identificador, nombre, rol y autorización en `${namespace}_session`; no contraseña ni correo en esa caché | `firebase_session_repository.dart`, `session_repository.dart` | Hive sin cifrado explícito en `open`; es metadato de operador, no sustituye el almacén de Auth |
| Windows, datos propios | `%LOCALAPPDATA%/BayStream/vessel_store`, sujeto a virtualización del agente | `local_store_directory_io.dart` | No se abrió ni contó el almacén; en B usar Explorer y helper externo para identificar el real |
| Windows, Auth | SDK C++: Firebase documenta Credential Management API | Plugin Windows de `firebase_auth` 6.5.7 y [Firebase C++](https://firebase.google.com/docs/auth/cpp/manage-users#persist_a_users_credential) | Mecanismo documentado; aislamiento y persistencia del cliente t98 pendientes, sin inspeccionar secretos |
| Android, datos propios | Hive en carpeta privada `files/vessel_store` del paquete | `local_store_directory_io.dart` y decisión 10.80 | No es SQLite. No demuestra por sí solo la protección de credenciales del SDK |
| Android, Auth | Lo administra Firebase Auth nativo; ruta y mecanismo efectivos por corroborar con fuentes de la versión instalada y metadatos permitidos | Plugin Android de `firebase_auth`; sin inspección del Honor | Pendiente; no se atribuye Android Keystore solo por usar Firebase |
| Web, datos propios | Hive en IndexedDB del origen | `local_store_directory_web.dart`, `hive_vessel_data_source.dart` | Persistencia de datos propios, separada de Auth |
| Web, Auth | Orden predeterminado del adaptador: IndexedDB, almacenamiento local, almacenamiento de sesión | `firebase_auth_web` 6.2.6, `src/interop/auth.dart:22`; [persistencia de Auth](https://firebase.google.com/docs/auth/web/auth-state-persistence) | No prueba una bóveda nativa cifrada. Validación contra el criterio pendiente |

La caché sin conexión de Firestore es otra capa y no se presenta como almacén
de contraseñas ni como el almacén Hive del producto.

### RNF-006 · Catálogo y hoja de medición de Fase B

| Caso | Clase ERS | Construcción |
|---|---|---|
| 01 | Corrupto | 256 bytes pseudoaleatorios, semilla 98 |
| 02 | Corrupto | Texto sin EDIFACT |
| 03 | Incompleto | A01 cortado dentro del primer EQD, sin completar el segmento |
| 04 | Incompleto | A01 sin UNT/UNZ |
| 05 | Incompleto | A01 sin TDT |
| 06 | No soportado | COPRAR sintético |
| 07 | No soportado | BAPLIE D.13B/SMDG31 sintético |
| 08 | No soportado | Archivo vacío |

Son cargas sintéticas, no viajes. Salida: `catalogo/`, con manifiesto, tamaños
y huellas. La ejercitación detectó aceptaciones del lector en 03 y 04. Se
comunica como **hallazgo de ensayo que revisar en la UI**, sin medir recuperación,
sin asignar dictamen RNF y sin cambiar `lib/`.

| Submétrica | Umbral | Medición | Dictamen |
|---|---|---|---|
| Recuperación | <3 s; error visible + viaje anterior + botón que responde | Pendiente, 8 casos × 3 clientes | Pendiente Fase B |
| Mensajes | 100% causa y acción; segmento cuando es parseo | Inventario generado, revisión y recorrido pendientes | Pendiente Fase B |
| Disponibilidad funcional | 99.9%; operaciones básicas sin dependencias externas | Pendiente desconexión verificada de los tres clientes | Pendiente Fase B |

### Inventarios de errores, idioma y Material 3

`inventario/cadenas.csv` conserva todos los literales como candidatos, también
dominio, constantes indirectas y pantallas H5. `errores.csv` incorpora indicios
léxicos de causa, acción y segmento; `material3.csv` registra controles por
archivo/pantalla. Cada fila incluye la huella de la fuente y columnas explícitas
de revisión. **No es todavía el inventario validado de todas las cadenas
visibles**: el extractor no resuelve semánticamente interpolaciones, composición,
controles propios ni mensajes que devuelven los plugins. Esa revisión y los
recorridos son trabajo pendiente; no se ha calculado ningún porcentaje.

Tabla de arranque de la revisión manual de mensajes centrales, por lectura de
fuentes; no es una muestra extrapolada al «100%» ni sustituye `errores.csv`:

| Mensaje/rama de fuente | Causa | Acción | Segmento si parseo |
|---|---|---|---|
| `notBaplieFileMessage`: cabecera no reconocida; seleccionar exportación completa | Sí | Sí | UNH/S009 |
| Versión no admitida de `_validateVersion`: pedir exportación compatible | Sí | Sí | UNH en excepción; comprobar texto visible en B |
| TDT sin nombre: revisar BAPLIE completo o pedir nueva exportación | Sí | Sí | TDT |
| Interpretación genérica: revisar formato o pedir exportación | Parcial: no precisa fallo concreto | Sí | No explícito |
| `unknownVesselErrorMessage`: error inesperado; reintentar/reiniciar | Genérica | Sí | No aplica |
| Acceso al almacén local: reintentar/reiniciar | Genérica | Sí | No aplica |
| Perfil con mismo nombre: confirmar identidad | Sí | Sí | No aplica |
| Correo o contraseña incorrectos (`signInMessage`) | Sí | No explícita | No aplica |
| Correo inválido (`signInMessage`) | Sí | No explícita | No aplica |
| Cuenta deshabilitada: hablar con responsable | Sí | Sí | No aplica |
| Demasiados intentos: esperar | Sí | Sí | No aplica |
| Sin conexión: iniciar sesión requiere red | Sí | No imperativa explícita | No aplica |
| Inicio de sesión genérico con código | Código, sin explicación concreta | No explícita | No aplica |
| No se pudo cerrar sesión | Genérica | No explícita | No aplica |
| No se pudo enviar el correo, con código | Código, sin explicación concreta | No explícita | No aplica |

Fuentes de la tabla: `vessel_error_message.dart`, `_validateVersion` del lector,
`FirebaseSessionRepository.signInMessage`, `signOut` y `sendPasswordReset`.
Se preservan los textos del producto. En B hay que revisar el conjunto completo,
incluidos parámetros, exportación, comparación, muelle y mensajes de plugins.

### RNF-008 · Hoja de medición de Fase B

| Submétrica | Umbral/fuente | Medición | Dictamen |
|---|---|---|---|
| BAPLIE 2.2.1 | 0 casos fallidos; guía SMDG | Batería preparada; hallazgos del ensayo separados de la medición | Pendiente Fase B |
| BBBRRTT | 0 casos fallidos | Batería y barrido de posiciones preparados | Pendiente Fase B |
| ISO 6346 | 0 casos fallidos, IDs sintéticos con dígito calculado/alterado | Oráculo contrastado con CSQU3054383; no certifica registro del propietario | Pendiente Fase B |
| UN/LOCODE | Puertos contra lista oficial con edición identificada | Lista obtenida y lector ensayado | Pendiente Fase B |
| KGM y VGM | 0 casos fallidos | Casos KGM/LBR/TNE, VGM y variantes reales preparados | Pendiente Fase B |
| IMDG 42-24 | T-85; disposiciones especiales por ONU | Se remite a T-85, no se repitió su comprobador | Limitación fijada por 8.1: no evaluadas; no declarar RNF completo conforme |

Guía: [SMDG BAPLIE 2.2.1](https://smdg.org/wp-content/uploads/MIGs/BAPLIE/Baplie221-03.pdf),
capítulos 4, 5.2 y 7. El barrido separa cabecera, SG1, SG2, SG3 y SG4 para no
confundir etiquetas repetidas. El corpus actual no aporta ejemplares de
`SG2/GID`, `SG2/DIM` ni `SG3/EQA`; **no se inventa su cobertura**. Presencia de
segmentos no certifica orden, cardinalidades ni semántica de toda la guía.
A06 se trata como 1.5 admitida con aviso (T-103), nunca como prueba de 2.2.1.
El porcentaje de dígitos válidos del corpus queda aparte, con la advertencia
de anonimización, y no se toma como porcentaje de conformidad del validador.

La [publicación oficial UNECE](https://unlocode.unece.org/publications/) enlaza
la edición **2025-1** descargada. La lista permanece exclusivamente en
`C:\Proyectos\baystream-privado\unlocode\2025-1\release\csv\`.
ZIP: SHA-256 `ad409fc7149b10f98d61190c34d9daf78b78bb8b31464cc66de1a89d09b01b5d`.
Procedencia anotada fuera del repo en `fuente-2025-1.json`; las huellas de las
tres partes CSV constan en la salida del instrumento.

T-85 se cita mediante `docs/T85-RESULTADOS.md`, `tool/t85_tabla_privada.dart`,
`test/t85_imdg_test.dart` y `test/t85_segregation_page_test.dart`. Los cotejos
**289/289 y 60/60 son evidencia previa de T-85**, no nuevas ejecuciones de
T-98. No se abrieron los documentos privados ni se copiaron pasajes del IMDG.

### RNF-002 · Hoja de medición y piloto

| Submétrica | Umbral/condición | Medición | Dictamen |
|---|---|---|---|
| Primera visualización | ≤3 pasos **y** ≤30 s; sin perfil rige, fin en rejilla | Pendiente, 5 repeticiones × 2 condiciones × 3 clientes | Pendiente Fase B |
| Con perfil | Misma instrumentación, informativa | Pendiente | Sin dictamen normativo separado |
| Aprendizaje | Las cinco tareas sin ayuda en <10 min, sin capacitación | Hoja vacía para cinco participantes COMAR | Pendiente piloto de Carlos |
| Material 3 | 100% de controles interactivos; origen Material y colorScheme | Censo por archivo generado; revisión de componentes y excepciones pendiente | Pendiente Fase B |
| Idioma | Español; cadenas visibles en español / visibles totales | Censo generado; denominador validado pendiente | Pendiente Fase B |
| SUS, indicador 6 | Meta ≥68 de 10.80 | Cuestionario y hoja vacía | Pendiente piloto de Carlos |

La rejilla se excluye del denominador M3 porque no hay un componente equivalente
en Material. Sus controles externos sí se revisan. Tener `useMaterial3: true`
no demuestra conformidad de todos los controles ni de sus colores.

El protocolo completo y el cuestionario en español se generan en
`hojas/protocolo.md`. Es una traducción de trabajo explícita del SUS de Brooke,
con [fuente primaria alojada por AHRQ](https://digital.ahrq.gov/sites/default/files/docs/survey/systemusabilityscale%2528sus%2529_comp%255B1%255D.pdf);
no se presenta como traducción validada. Alterna cinco ítems positivos y cinco
negativos, escala 1–5; impares respuesta−1, pares 5−respuesta, suma ×2.5.
No imputar ausentes ni expresar el SUS como porcentaje.

Para Carlos: aplicar a P1–P5 de operaciones COMAR, sin registrar nombres ni
cuentas. Tareas fijas: cargar A01, ver una bahía, encontrar un ID, identificar un
refrigerado y leer una alerta. Las hojas están en `piloto_tiempos.csv` y
`piloto_sus.csv`. Registrar ayudas, tareas incompletas, cinco puntajes, media y
limitaciones. **No hay participantes observados ni respuestas recogidas hoy.**

### Verificaciones ejecutadas

| Verificación técnica (no medición RNF) | Resultado observado | Registro bajo `%TEMP%\t98-fase-a-9ae744a\` |
|---|---|---|
| Análisis estático final sobre HEAD + instrumentos | **0 incidencias**, sin `// ignore` nuevos | `analyze-4.txt` |
| Suite completa sobre copia de HEAD + T-98 | **948 aprobadas, 14 fallidas, 962 ejecutadas**, código 1 | `suite-3.txt` |
| Batería T-98 dentro de esa suite | **27 aprobadas y 13 fallidas**, 40 nuevas en total | Casos T98 de `suite-3.txt` |
| Autopruebas Dart de instrumentos | **12/12**, incluidas en los 27 aprobados de T-98 | `suite-3.txt` |
| Auxiliares Python | **6/6** | `python-autopruebas.txt` |
| Catálogo, ensayo del catálogo y barrido del corpus | Scripts ejecutados; salidas sanitizadas/agregadas, sin cronometrar UI | `catalogo/`, `invalidos/`, `corpus/` |
| Censo y protocolo | CSV/JSON y hojas vacías generados; no auditoría de conformidad | `inventario/`, `hojas/` |
| Sonda Windows sobre consola propia | Consultas TCP/UDP ejercitadas; sin cliente BayStream | `sonda-autoprueba.json` |
| Video y sanitización | Video negro sintético analizado por PTS; HAR/NetLog sintéticos reducidos | `video/`, `har/`, `netlog/` |

Los **13 fallos nuevos** pertenecen a `test/t98_estandares_test.dart`:

| Grupo | Casos del ensayo que no satisficieron el rechazo exigido |
|---|---|
| BBBRRTT | Cuatro: longitud corta/larga, letra y signo; el lector no lanza rechazo |
| ISO 6346 | Tres IDs sintéticos cuyo dígito se alteró; el lector los acepta |
| Unidades | LBR y TNE; el lector no rechaza la unidad ajena a KGM |
| Estructura | Ausencia de UNB, BGM, UNT y UNZ; el lector no rechaza |

Las expectativas no están invertidas, omitidas ni marcadas `skip`.
Esto identifica rutas para revisar con Yov y en la UI; no constituye un nuevo
dictamen RNF-008 ni una medición de los binarios de cierre.

El **fallo restante es T-92**, anterior a estos instrumentos: la prueba de
huellas espera los bytes de `servedSha256`, pero los tres módulos JS extraídos
de HEAD tienen CRLF. Los archivos actuales del árbol tienen LF y coinciden con
los de HEAD al normalizar únicamente los finales de línea. Ocurre en
`firebase-app.js`, `firebase-auth.js` y `firebase-firestore-pipelines.js`, bajo
`web/vendor/firebase/12.17.0/`. No se modificó ninguno de ellos ni su manifiesto.
Por tanto, de los 922 casos anteriores, esta copia ejecutó 921 aprobados y ese
fallo reproducible de procedencia. Conviene revisar con Yov la política de
finales de línea y huellas **antes de compilar la copia limpia de Fase B**;
no corresponde corregirla dentro del carril T-98.

**Piso:** se incorporan 40 pruebas Dart (total 962), pero **no se anuncia un
piso verde nuevo**: el piso confirmado sigue siendo el 922 previo de Carlos.
La condición de «batería pasa sobre HEAD» de Fase A permanece sin cumplir.

Los registros iniciales se conservan para trazabilidad: el primer analyze
detectó tres indicaciones de llaves; la ampliación de aislamiento detectó una
importación sobrante y otras llaves. Se corrigió exclusivamente el código T-98.
La primera suite no inició por faltar `package_graph.json`. La siguiente mostró
10 fallos por plataformas omitidas del snapshot y uno de mi autoprueba de TEMP;
se completó el snapshot de HEAD y se corrigió la autoprueba. No son defectos
atribuidos al producto ni evidencia de medición.

FFmpeg y ffprobe ya estaban instalados; se comprobó el dispositivo `gdigrab`.
No se instaló ninguna herramienta. Los cuatro scripts PowerShell pasaron la
validación sintáctica. La sonda Windows se ejercitó con el propio proceso de
consola y separó consultas válidas de errores; eso no prueba el cliente BayStream.
El análisis de video se ejercitó con una fuente negra sintética, sin grabar la
pantalla ni medir interfaz. Sanitización HAR/NetLog: entradas sintéticas y
canarios de prueba que no aparecen en los resúmenes.

### Qué queda para Fase B y qué impide cerrar A

1. Resolver con Yov/Carlos el tratamiento de los negativos de conformidad
   fallidos y la discrepancia de huellas/finales de línea de T-92: no cambié
   `lib/`, los umbrales, ni convertí el rechazo exigido en una
   expectativa de aceptación. **No puede afirmarse «batería pasa» ni elevar el
   piso verde mientras la suite conserve esos fallos.** Cualquier corrección de
   producto requiere otra autorización/tarea y repetición sobre el cierre.
2. Carlos anuncia el commit de cierre. Copia limpia y binarios t98, huellas,
   versiones, entorno y procedencia del almacén real de Windows documentados.
3. Honor: todos los instrumentos quedan sin ensayar en el dispositivo; reservarlo
   con Carlos en B, comprobar paquete .t98, netstats y su frescura/atribución,
   segunda fuente TCP, grabación, modo avión + Wi-Fi apagado + ping fallido.
   No sumar secciones duplicadas ni interpretar buckets ausentes como cero.
4. Sesión: esperar a que Carlos cree **«PRUEBA T-98»**. No reutilizar T-105 ni
   sesiones reales. Las condiciones con sesión, TLS efectivo y persistencia no
   se ensayaron. OpenSSL requiere una ruta a una instalación disponible; no se
   instaló ni se sustituyó el negativo 1.1 por otra prueba.
5. Recorridos Windows/Web/Honor, HAR y NetLog con cobertura del worker comprobada,
   clasificación de transmisiones y detención inmediata si ocurre una en A.
   Red físicamente desconectada/verificada para disponibilidad funcional.
6. Videos y selección humana de hitos: 24 recuperaciones y 30 repeticiones de
   primera visualización. Inventarios revisados de todos los errores visibles,
   idioma y controles M3; completar las tablas anteriores sin extrapolar el censo.
7. Carlos aplica el piloto y entrega observaciones/respuestas sanitizadas;
   Timonel acepta por su cuenta una fila de cada RNF. No se hizo hoy.

No se aplicaron criterios alternativos de T-63. Donde falta evidencia se declara
pendiente. La disponibilidad longitudinal 6.1(b), RNF-001/003/005/007 y corregir
defectos del producto continúan fuera de esta tarea.

### Archivos de esta entrega

Solo se crearon los 16 archivos `tool/t98_*` y `test/t98_*` enumerados en la
tabla de instrumentos y este informe: 17 rutas exactas en el bloque siguiente.
`lib/`, codec, reglas, congelados, `lib/main.dart`, `pubspec.yaml` y
`pubspec.lock` **sin cambios de Codex**. Los cambios ajenos se conservaron.
No se modificaron archivos rectores ni `.claude/settings.local.json`.
No hubo Git de escritura, publicaciones ni Firebase CLI/consola.

### Git para Carlos

Versiona los instrumentos; **no declara cerrada la Fase A ni T-98**.
Todas las rutas propias están autorizadas y no requieren `-f`; el resto de
evidencias/listas permanece fuera del repositorio.

```powershell
git add -- tool/t98_support.dart
git add -- tool/t98_catalogo_invalidos.dart
git add -- tool/t98_ensayo_invalidos.dart
git add -- tool/t98_estandares_corpus.dart
git add -- tool/t98_main.dart
git add -- tool/t98_inventario.py
git add -- tool/t98_preparar.py
git add -- tool/t98_sanitizar.py
git add -- tool/t98_video.py
git add -- tool/t98_sonda_red_windows.ps1
git add -- tool/t98_honor_red.ps1
git add -- tool/t98_tls.ps1
git add -- tool/t98_clientes_windows.ps1
git add -- test/t98_estandares_test.dart
git add -- test/t98_instrumentos_test.dart
git add -- test/t98_auxiliares_test.py
git add -- docs/T98-RESULTADOS.md
git commit -m "Prepara instrumentos de T-98 fase A y documenta hallazgos del ensayo"
git push
```

### Tres líneas para Carlos

Instrumentos T-98 preparados y ensayados sobre una copia de HEAD, con evidencia en TEMP.
Los negativos detectados se conservan; no se modificó el producto ni se midieron RNF.
Honor, sesión PRUEBA T-98, recorridos y piloto quedan pendientes del cierre y de Carlos.

### Mensaje para Yov

T-98 Fase A: instrumentos en tool/t98_*, test/t98_* y docs/T98-RESULTADOS.md, sin commit.
Ensayados sobre copia temporal de HEAD 9ae744a; no son mediciones ni dictámenes RNF.
La batería conserva negativos de conformidad fallidos: hace falta tu revisión para cerrar A.
Suite: 948 aprobadas/14 fallidas de 962; analyze final cero; el fallo ajeno es T-92 (CRLF/LF).
No toqué lib/, codec, reglas, congelados ni pubspec.*; Flutter siempre con semáforo de Carlos.
UN/LOCODE oficial 2025-1 fuera del repo; FFmpeg disponible, OpenSSL no localizado.
Honor y sesión PRUEBA T-98 sin ensayar; T-105 y demo17 no se tocaron.
Hojas del piloto/SUS listas, sin datos; SUS es el indicador 6 de la hipótesis única.

## Ensayo en el Honor, 19-oct

Capitán Codex · 19-oct-2026 · **Ensayo de instrumentos, sin dictamen RNF.**
Esta sección actualiza exclusivamente el ensayo del Honor: conserva las
entregas históricas anteriores. «PRUEBA T-98», su sesión, los binarios de
cierre y las mediciones de Fase B siguen pendientes de Carlos.

### Autorización, app y aislamiento

Carlos autorizó esta sesión en solitario, el Honor, ADB, modo avión, Wi-Fi y
cambio de letra. Se anunciaron el inicio y fin de la ventana con `SEMÁFORO:`;
no se compiló ni se ejecutó Flutter durante ella.

Base: `83d0dc1d55358e66d5bc23ccc0b59a284327f8be`, **más la tarjeta de T-111**.
Se reutilizó el APK propio de T-111 y T-107, no un binario de cierre:

- Paquete nuevo `gt.cmartinez.baystream.t111.t98`, etiqueta «BayStream T111 Codex».
- Namespace `t111`, en la carpeta privada de esa app; ninguna app previa se abrió.
- Banco `tool/t111_main.dart`: UI y lector reales, sin inicializar Firebase,
  con sesión local y adaptador que falla ante cualquier acceso remoto.
- Compilado release sin `--no-pub`, con la configuración por
  `--dart-define-from-file` sin abrirla; firma Android Debug verificada con
  `apksigner`. No se abrió ni copió `android/key.properties`.
- SHA-256 APK: `bb60ab9b5750704bf6e5bb3727524340a2545f35e5a1ee5498a24ca6f9f30213`.

El namespace y la identidad se declaran expresamente: **no es la condición A
de medición del cierre con Firebase configurado**. Este ensayo comprueba la
sonda, la atribución al paquete propio y la carga de un BAPLIE sin red.
No mide transmisión de datos del producto, TLS, recuperación, tiempos ni SUS.

Evidencia raíz: `%TEMP%\baystream-19oct-codex-83d0dc1\`.
Las salidas de esta sección están bajo `t98/`; no contienen identificadores
de cuenta, extremos de red, credenciales ni volcados crudos.

### Fallos encontrados y correcciones en la sonda

**1. La sonda original no obtenía el UID.**
`dumpsys package` de este Honor Android 15 usa `appId=`, y el instrumento
buscaba exclusivamente `userId=`. La primera ejecución se detuvo con
«No se obtuvo el UID reservado», antes de generar evidencia.

Ahora consulta `pm list packages -U` y exige una única coincidencia del
**nombre completo** del paquete. Obtiene el UID completo, sin confundirlo con
un appId o con otro paquete de prefijo parecido. El valor queda solo en memoria.
Una atribución ausente o ambigua detiene la captura; no se transforma en cero.

**2. Se contaba un registro BPF como si fuera tráfico.**
Al resolver la atribución, la versión intermedia guardó
`bucketsEncontrados: 1`, cuyo único contenido era `set=1`.
Esa fila estaba en **BPF map content**, no en un historial de tráfico.
Se conserva en `t98/corregido/carga_reserva19-antes.json` como evidencia del fallo,
no como una medición válida.

Ahora `Select-T98Buckets`:

- admite únicamente `UID stats` y `UID tag stats`, conservando su nombre;
- exige un inicio de bucket `st=` y campos de bytes para contarlo;
- conserva duración, set, tag y un ordinal de contexto, sin guardar la
  identidad de la red;
- corta la atribución al cambiar de UID, contexto de red o sección;
- nunca suma ambas secciones ni incluye encabezados o mapas BPF.

**3. Metadatos y segunda fuente.**
La captura registra `-Fase A|B`, `-Base`, paquete y método de atribución en
lugar del texto provisional «completar fase al ejecutar».
Comprueba errores reconocibles al solicitar el poll, aunque el código de
salida sea 0; esto no certifica frescura del historial.
Añade una consulta **puntual** de `/proc/net/tcp` y `tcp6`, con estado válido/
inválido y número de filas del paquete, sin guardar sus extremos ni el UID.
Un fallo de consulta no se presenta como cero sockets.

### Antes y después de cargar el BAPLIE

Se activó avión con `cmd connectivity airplane-mode enable` y se apagó Wi-Fi
con `svc wifi disable`. Se cargó `T111_1.edi`, sintético completo del banco,
desde `Descargas/t111codex` mediante el selector real, y se confirmó el perfil.
Mostró el viaje, `7419.5 t` y «1 celda reservada» sin error. No se registraron
movimientos. Las copias habían sido indexadas con `MEDIA_SCANNER_SCAN_FILE`.

| Dato observado | Antes | Después |
|---|---|---|
| Hora local (Guatemala, UTC−6), 19-oct | 15:24:18 | 15:25:32 |
| `airplane_mode_on` | 1 | 1 |
| `wifi_on` | 0 | 0 |
| Ping a 1.1.1.1 | Falla | Falla |
| `sinRedVerificada` | true | true |
| Solicitud de poll aceptada | true | true |
| Buckets de historial atribuibles | Ninguno | Ninguno |
| Consulta TCP puntual | Válida, 0 filas del paquete | Válida, 0 filas del paquete |

Archivos válidos:

- `t98/final/carga_reserva19-antes.json`
- `t98/final/carga_reserva19-despues.json`

El ping observado devuelve **«Network is unreachable»**, código 2.
**Ausencia de historial no equivale a cero tráfico.** Tampoco dos consultas
TCP puntuales descartan conexiones entre ellas. No se hizo una transferencia
de control ni se acreditó frescura/contabilidad de bytes del servicio; eso
sigue pendiente antes de dictaminar en Fase B. No se calcula un delta ficticio.

### Verificaciones del instrumento

| Verificación | Resultado |
|---|---|
| `-Autoprueba`, datos sintéticos | **5 comprobaciones pasan**: atribución, separación de secciones, duración, sanitización y descarte BPF |
| Las mismas en Windows PowerShell 5 | **Pasan**; no son cinco casos adicionales |
| Análisis sintáctico PowerShell | Sin errores |
| Guarda de paquete no aislado | Rechazado antes de consultar el dispositivo |
| Guarda de salida fuera de TEMP | Rechazada antes de consultar el dispositivo |
| Dos JSON finales contra el identificador real en memoria | Sin identificador persistido; red desconectada verificada |

Registro resumido: `t98/validacion-final.json`.
Las autopruebas están en el propio script; no agregan pruebas Dart ni cambian
el piso de 1047 que dejó T-111. No hubo modificaciones de `lib/` por T-98.

Repetición autorizada del ensayo, desde el repositorio, con su semáforo:

```powershell
./tool/t98_honor_red.ps1 -Momento antes -Operacion autoprueba -Autoprueba
# Para una nueva pareja, usar un nombre de operacion nuevo: no sobrescribe.
./tool/t98_honor_red.ps1 -Momento antes -Operacion nuevo_ensayo -Paquete gt.cmartinez.baystream.t111.t98 -Fase A -Base 83d0dc1 -Salida "$env:TEMP/t98-nuevo-ensayo"
# Cargar y confirmar un BAPLIE en la app propia, con la red comprobada.
./tool/t98_honor_red.ps1 -Momento despues -Operacion nuevo_ensayo -Paquete gt.cmartinez.baystream.t111.t98 -Fase A -Base 83d0dc1 -Salida "$env:TEMP/t98-nuevo-ensayo"
```

### Restauración y entrega

Se desactivó avión, se restauró Wi-Fi activado como estaba y se dejó letra
**1.0**; la app propia terminó detenida. No se tocó `wm`.
`honor-final.json`: avión 0, Wi-Fi 1, letra 1.0, app sin PID;
45 paquetes BayStream previos y ninguno con `lastUpdateTime` cambiado.
Solo se añadió la app de prueba. Las copias de archivos quedan en
`Descargas/t111codex`, y la app propia queda instalada y cerrada.

No hubo Firebase, cuentas, publicaciones, acceso al almacén real, demo17 o
«PRUEBA T-105», ni Git de escritura. No se capturó «Nube y cuenta» ni el
selector del Honor. Capturas y volcados de la app se sanitizaron en memoria.
**`pubspec.yaml` y `pubspec.lock` sin cambios.**

Archivos de este requerimiento:

- `tool/t98_honor_red.ps1` — modificado.
- `docs/T98-RESULTADOS.md` — esta sección añadida, sin reemplazar lo anterior.

```powershell
git add -- tool/t98_honor_red.ps1
git add -- docs/T98-RESULTADOS.md
git commit -m "Sprint 3: ensaya y corrige sonda del Honor T-98"
git push
```

Tres líneas:

El Honor ejecutó la sonda antes/después de cargar un BAPLIE sin red, sin sesión.
Se corrigieron atribución Android 15 y falsos buckets BPF; cinco autopruebas pasan.
No hay dictamen RNF; Fase B, frescura y transferencia de control siguen pendientes.

Mensaje histórico para Yov (ensayo del Honor):

Ensayo T-98 en Honor completado, sin dictamen ni sesión, sobre el APK aislado
HEAD 83d0dc1 + tarjeta T-111. El original falló por userId/appId; después se
detectó que un set del mapa BPF contaba como bucket. La sonda ahora atribuye
por paquete exacto con pm -U, separa UID stats/tag, descarta BPF y registra
fase/base y una segunda fuente TCP puntual, todo sanitizado. Cinco autopruebas
pasan también en PowerShell 5, más sintaxis, guardas y auditoría de los JSON.
Antes/después: avión 1, Wi-Fi 0, ping fallido; ningún historial atribuible,
no «cero tráfico». Fase B y transferencia de control pendientes. Honor restaurado
a avión 0, Wi-Fi 1, letra 1.0 y app detenida. Commit propuesto
«Sprint 3: ensaya y corrige sonda del Honor T-98».

## Fase B · Cierre 90dce4b

Capitán Codex · 19–20-oct-2026 · **En curso; entrega parcial reanudable.**
Las tablas de esta sección son las vigentes. Un pendiente no equivale a una
medición aprobada. Carlos autorizó la sesión en solitario, Flutter secuencial,
Honor, Chrome y modo avión; las cuentas y `pktmon` siguen a cargo de Carlos.

### Procedencia y aislamiento

- `git log --oneline --decorate -3` confirmó en primer lugar la decisión
  10.91, HEAD de `sprint-3` y etiqueta `sprint3-cierre`.
- SHA completo: `90dce4bf09ab57e16a937460854c4a6d2b4034e5`.
- `git archive sprint3-cierre`, sin modificar rama, índice ni repositorio.
  Copia: `%TEMP%\t98-b-90dce4b-19oct\app\`.
- Se verificaron **726 archivos** byte a byte por SHA-256 antes de compilar:
  `manifiesto-original.json` y `preparacion.json`, bajo esa raíz TEMP.
- Los cambios funcionales Android, en la copia, son `applicationId`
  `gt.cmartinez.baystream.t98` y etiqueta «BayStream T98». No se copió
  `android/key.properties`. Android se compila **sin `--no-pub`**.
- Entrada `tool/t98_main.dart`, `T98_FIREBASE=true`, proyecto autorizado,
  FirebaseApp `t98`, Auth y Firestore explícitos. Configuración pasada con
  `--dart-define-from-file`, sin abrirla ni imprimir sus valores.
- **Corrección preventiva del banco:** antes de abrir Windows, se detectó
  que sus cajas `t98` aún apuntaban al directorio real. Se añadió
  `T98_WINDOWS_STORE` obligatorio en TEMP, como en el banco T-111.
  No se abrió el primer binario; se recompiló el banco antes del arranque.
  No cambia `lib/` ni el comportamiento del producto.
- Almacén Windows efectivo: `%TEMP%\t98-b-90dce4b-19oct\store-windows\`.
  Se abrió mediante `explorer.exe`, mostró Inicio y creó cajas
  `t98_profiles`, `t98_settings` y `t98_voyages`. PID 12596, cerrado por PID.
  `smoke-windows.json` registra esta comprobación. No se examinó ni contó
  el almacén real, y no se abrieron otras apps BayStream.
- Honor antes: Android 15, NAA-LX3, 720×1600, densidad 320 (360 dp), letra
  1.0, avión 0, Wi-Fi 1. **46 paquetes previos** inventariados mediante
  nombre y `lastUpdateTime`, sin UID: `honor-paquetes-antes.json`.
- Flutter **3.38.9**, Dart **3.10.8**. Sin dependencias nuevas. Se comprobó
  que `pubspec.yaml` y `pubspec.lock` de la copia conservan su huella original.

La copia superpone exclusivamente instrumentos `tool/t98_*` corregidos en
esta sesión. El manifiesto original permite distinguirlos del código de
producto congelado. No se atribuye a esta medición la evidencia de Fase A.

Comprobación final `procedencia-20oct.json`: los **136 archivos de `lib/`**
de la copia conservan exactamente sus huellas. Los tres archivos generados
de Windows solo cambiaron finales de línea. Las superposiciones de herramientas
sin corrección también difieren únicamente por finales de línea. Al preparar
el manifiesto Android se dañaron acentos de tres comentarios XML; se restauraron
desde los bytes del archivo original, conservando la etiqueta T98. El APK medido
se compiló antes de restaurar esos comentarios: no cambian configuración ni
código ejecutable y no se recompiló ni sustituyó el binario medido.
`AndroidManifest-t98.xml` conserva la fuente usada y `manifest-comentarios.json`
sus huellas. `pubspec.*` de la copia conserva sus bytes originales; en el repo,
`pubspec.lock` solo difiere del archivo archivado por CRLF y no tiene diff Git.

### Estado de binarios y evidencias

Raíz de evidencia: `%TEMP%\t98-b-90dce4b-19oct\`.

| Cliente | Estado | SHA-256 |
|---|---|---|
| Windows release, banco con almacén TEMP | Compilado, arranque comprobado | `596db54f24bee78cf23b28249aca2ebf6f75ef25e31c5c5f572977c3002be359` |
| Android release `.t98`, 66,314,415 bytes | Compilado e instalado; Firebase activo y sesión inicial ausente | `8c59cabbd239998ada0de3ef6d19c4a06b9b196027adb58a40cbd343b9017cd9` |
| Web release, `main.dart.js`, 4,991,653 bytes | Origen exclusivo `http://127.0.0.1:5898`, visible; Firebase activo y sin sesión | `94802e9dc3b985f11f17be8e2fdf50c78fb012272c6e7c0bcca0e9388bb100f3` |

Windows: `build-windows-aislado.txt`, código 0, 32.1 s. Se conservan los
avisos MSB8029 de MSBuild por compilar en TEMP. El primer build (161.3 s) se
conserva en `build-windows.txt`, pero **no se usó para medición ni se abrió**.

Android: `build-android.txt`, código 0, Gradle 103.4 s. Web:
`build-web.txt`, código 0, 49.2 s; conserva el aviso de CupertinoIcons.
`binarios.json` y `web-manifiesto.json` contienen tamaños y huellas. El
manifiesto Web agregado tiene SHA-256
`44757b4543d20155cbc6a9531cdd25ae42059efc0365404bdbdea4f70ddfca3e`.

**Verificaciones antes de medir:** `flutter analyze --no-pub`: **0
incidencias**, 36.1 s (`analyze.txt`). La primera suite sobre la copia de
medición dio 1046 aprobadas y 1 fallo: T-88 exige la etiqueta «BayStream»,
pero la copia Android tiene «BayStream T98». Se repitió con los bytes del
manifiesto original de `cierre.tar`, sin cambiar la prueba: **1047/1047**, sin
omitidas, código 0, 47 s (`suite-manifiesto-original.txt`). Se repuso después
la identidad de la copia de medición; ningún binario cambió por esta prueba.
Es una diferencia del banco, no un defecto atribuido al producto. Python:
**10/10** autopruebas; sonda Honor: cinco autocomprobaciones correctas.

### RNF-004 · Tabla vigente

| Submétrica | Umbral | Medición de cierre | Dictamen |
|---|---|---|---|
| Operaciones locales A | 100% de 11 operaciones por cliente sin transmisión T63 4.2, Firebase activo y sin sesión | 11/11 operaciones funcionales observadas en cada cliente; límites instrumentales abajo | No medible para el 100% sin transmisión |
| Condición B, fuera de compartida | Informativa | Pendiente Carlos; nadie ha iniciado sesión | No medible; informativa |
| TLS real | TLS ≥1.2; 10.82 | Pendiente sesión y aprobación de `pktmon`; Android se declarará con su limitación | No medible |
| Credenciales | Mecanismos nativos seguros por plataforma | Inventario histórico por fuentes; corroboración de versiones y mecanismos pendiente | No medible |

**RNF-004: no medible** en este corte. No hay un resultado de transmisión
en A. El muestreo de sockets no certifica ausencia de contenido transmitido.
La ausencia de historial Android tampoco demuestra cero tráfico.
TLS 1.1 del proveedor es observación, sin dictamen BayStream (10.82).

**Recorrido común:** A01 abre el perfil; se declara «No lo tengo» para el
límite, sin inventar un umbral. Viaje: 977 contenedores, 34 bahías, 8366.1 t.
Bay Plan 01 y 02 (esta última: 4 unidades, 97.3 t); filtro NV6: 32, Todas:
977; búsqueda por un ID anonimizado; Estadísticas; Alertas (0 posibles
incumplimientos, 6 no evaluados, 0 conformes en las reglas evaluadas); CSV;
Recientes restaura 977/34; Parámetros y geometría accesibles sin modificarlos.

| Cliente | Evidencia y observación | Límite |
|---|---|---|
| Web | `web/operaciones-a.json`, `web/condicion-a-sanitizado.har`, `web/bay-plan-a.png`. 20 GET: 19 recursos locales y 1 recurso de la extensión; 0 peticiones HTTP externas, 0 cuerpos ni escrituras observadas. Durante carga, confirmación, filtros y búsqueda no hubo peticiones nuevas. El GET posterior fue una fuente pública local. | CDP de la pestaña; NetLog global bloqueado. 19 respuestas indican `fromServiceWorker`, lo que prueba intermediación, no cobertura de toda su actividad. No se pudo adjuntar automáticamente el worker con la API disponible. |
| Honor | `honor-operaciones-a.json` y 22 JSON en `honor-red/` (antes/después de cada operación). Sin historial atribuible en los 22; 22 consultas TCP válidas, 0 filas; poll aceptado. Avión 0, Wi-Fi 1, ping responde. `honor/bay-plan-a.png`, recortada sin barra de estado. | Sin control positivo de contabilización, no calcular delta cero ni certificar ausencia de tráfico. |
| Windows | `windows/operaciones-a.json`, `windows-red-a-valido.json`, `windows/parametros-a.png`. PID 5796; 1788 consultas TCP/UDP válidas en 300.225 s, 0 errores, 0 sockets observados. CSV de 122,773 bytes en TEMP. Cerrado por PID al terminar el bloque. | Muestreo, sin payload ni bytes, puede perder conexiones breves. El intervalo solicitado de 200 ms no es el intervalo efectivo de todas las consultas. |

**NetLog bloqueado:** la revisión automática de seguridad rechazó abrir
`chrome://net-export` por el protocolo/superficie del navegador. No se intentó
eludirlo mediante comandos ni otra superficie. Carlos tendría que iniciar
manualmente el NetLog requerido. La limitación no se sustituye por un HAR.

Web exportó realmente `BayStream_BUQUE ALFA_V01N (2).csv`, 120,730 bytes,
19-oct 19:48, en Descargas; se copió a `web-export-a.csv` en TEMP. El evento
`download` de la API expiró. El archivo sin sufijo era del 27-ago y **no es
evidencia**: su copia inicial se apartó como `descartado-export-preexistente.csv`.
Los archivos anteriores no se tocaron. Honor mostró «Exportación CSV
completada» y guardó en `Descargas/t98b/`. No se compara el contenido de los
CSV entre clientes, ya que incorporan identificadores internos del viaje.

El primer intento Windows abrió el selector incorrectamente; no cargó un
viaje. Se conserva `windows-red-a.json` (818 consultas, 147.661 s, sin
sockets) como **intento descartado**, no como recorrido. Se cerró su PID y
se repitió con el campo Nombre del selector. La sonda corregida añade UTC
de inicio/fin para próximas corridas; no se inventan esas marcas en las
salidas anteriores. El primer intento de «Siguiente» en Web desplazó el
selector; se repitió seleccionando BAY 02 directamente. No es un fallo de
navegación del producto. Nadie inició sesión durante estos recorridos.

### RNF-006 · Tabla vigente

| Submétrica | Umbral | Medición de cierre | Dictamen |
|---|---|---|---|
| Recuperación | <3 s; error visible, viaje anterior y carga operativa | Honor: cuatro casos con cota <3 s; 02 inconcluso, 01 sin inicio inequívoco; 03/04 admitidos. Windows/Web pendientes | No medible para el conjunto |
| Mensajes | 100% causa y acción; segmento si parseo | Hay mensajes alcanzables sin acción sugerida, por lectura de fuentes; censo completo pendiente | No cumple |
| Disponibilidad funcional | ≥99.9% de operaciones básicas sin red | Honor: 11/11 (100%) con avión 1, Wi-Fi 0 y ping fallido antes/después; Windows/Web pendientes | Cumple el recorrido del Honor; conjunto no medible |

**RNF-006: no cumple** por los mensajes sin acción sugerida. Recuperación y
disponibilidad conservan su estado pendiente; no se inventa un porcentaje
del inventario incompleto. Catálogo final en
`catalogo-final/`: ocho entradas, semilla 98, clases, tamaños y SHA-256 en
`catalogo.json`. La copia de A01 para control válido está en `control/`.
El corpus se entrega al programa mediante una definición de compilación
`BAYSTREAM_CORPUS_DIRECTORY` (`dart --define`, equivalente de Dart a
`flutter --dart-define`); no queda una ruta de corpus incrustada en el código.
La sonda del Honor pasó sus **cinco autocomprobaciones**, no son mediciones.

**Mensajes revisados por fuente del cierre, sin iniciar sesión:**

| Mensaje | Causa | Acción sugerida | Ruta visible corroborada |
|---|---|---|---|
| «Correo o contraseña incorrectos.» | Sí | No | `firebase_session_repository.dart:170` → `CloudPage._signIn` → `_run` → `Text(_message)` |
| «El correo no es válido.» | Sí | No | `firebase_session_repository.dart:171` y `:199`, misma salida de `_run` |
| «Esta cuenta está deshabilitada. Habla con el responsable.» | Sí | Sí | `firebase_session_repository.dart:172`, misma salida |
| «Demasiados intentos. Espera un momento.» | Sí | Sí | `firebase_session_repository.dart:173`, misma salida |
| «Sin conexión: iniciar sesión requiere red.» | Sí | No explícita | `firebase_session_repository.dart:174`, misma salida |
| «No se pudo cerrar la sesión.» | Genérica | No | `firebase_session_repository.dart:186`, misma salida |

`operation_text.dart:9`, `rejectionText`, solo normaliza puntos al final;
no añade instrucciones. Se revisó la composición completa de estos mensajes,
no únicamente su literal. Los contraejemplos bastan para descartar el 100%,
pero **no sustituyen la revisión de los 804 candidatos** ni el recorrido de
todas las rutas. No se provocaron fallos de cuenta ni se escribieron credenciales.

**Control con red del Honor (10.90):** `reabrir_reciente_a-antes.json` y
`-despues.json` corresponden a reabrir el viaje con avión 0, Wi-Fi 1 y ping
que responde. No hay historial atribuible en ninguno. La sonda no acredita
contabilización; su silencio sin red será referencia, y la disponibilidad se
juzgará por el recorrido funcional con la red caída y verificada.

**Grabación del catálogo, en curso:** se grabaron los ocho casos del Honor.
El 03 entra en Parámetros; el 04 se admite con el aviso visible
«Archivo posiblemente incompleto: faltan 2 segmentos (UNT, UNZ)». No se
convierten esas rutas en un rechazo ni se les asigna un tiempo de error
recuperado sin satisfacer los hitos del criterio. El perfil del 03 se canceló.
El 04 conserva los datos de A01 (977/34), con su aviso, y pasa a ser el viaje
anterior de las capturas siguientes.

**Incidencia del instrumento de video:** el primer recorte con FFmpeg
(`-fps_mode passthrough` sin base explícita del codificador) cuantizó PTS en
varios clips y produjo marcas repetidas. Los ocho clips de
`recuperacion-honor-final/` quedan **descartados para medición temporal**;
no son ocho recuperaciones aprobadas. El ensayo anterior de
`recuperacion-honor/` tampoco se presenta como una medición.

Se corrigió el banco para tomar `time_base` del video original, pasarlo a
`-enc_time_base`, conservar el video original hasta comparar todos los PTS y
exigir igualdad y crecimiento estricto antes de retirar el transitorio propio.
No se deduplican cuadros ni se reconstruyen marcas perdidas. El intento con
`-1` fue rechazado por el FFmpeg que ejecuta Python y conservó el transitorio;
se reprocesó ese original con su proporción explícita.

En `recuperacion-honor-pts/rec01-corregido.mp4`, **132/132 PTS** coinciden con
el original y son estrictamente crecientes. `rec01-conservacion-pts.json`
conserva ambas listas, tasas, bases temporales y huellas de origen/salida.
El original transitorio se retiró después de esa comprobación. Se completaron
los ocho clips de esa serie con la corrección, sin modificar el producto.
Los seis rechazos se volvieron a grabar con indicador de toque en
`recuperacion-honor-marcada/`; ambas listas PTS coinciden cuadro por cuadro
y son estrictamente crecientes. Los casos 03/04 conservan evidencia cualitativa
en `recuperacion-honor-pts/`.

El arnés espera **1 s fijo solicitado** entre confirmar el archivo y tocar
de nuevo la posición de carga observada antes del selector. Ese retraso y
las marcas ADB no son la medición y no se restan. El evaluador debe ver en
el video el error/aviso, el viaje anterior y el selector reabierto. No basta
que el script termine sin error. La barra de estado se recorta 80 px;
no se grabaron pantallas de cuenta. Los cuadros se anotan con índice desde
cero y PTS del video, mediante `t98_video_cuadros.py` y `t98_video.py`.

**Anotación revisada del Honor, 20-oct:** la pulsación estacionaria de 120 ms
hace visible el contacto. Se usó conservadoramente el primer cuadro con
puntero activo, anterior a soltar el archivo; no se descuentan esos 120 ms
ni la espera solicitada de 1 s. El final es un cuadro comprobado con el
selector completamente reabierto, después de ver el mensaje y el viaje
anterior (977/34). No se afirma que sea el primer cuadro posible de respuesta.
La incertidumbre suma los intervalos anteriores a inicio y final; se compara
su cota superior con 3 s. El largo intervalo inicial de estos videos variables
se conserva, sin sustituirlo por 1/fps.

| Caso | Cuadros inicio / error y viaje / selector | Diferencia PTS (s) | Incertidumbre (s) | Cota superior (s) | Dictamen de la observación |
|---|---|---|---|---|---|
| 02 texto sin EDIFACT | 52 / 102 / 147 | 2.039 | 0.995 | 3.034 | No medible frente a 3 s: intervalo cruza el umbral |
| 05 sin TDT | 52 / 96 / 140 | 1.956 | 0.976 | 2.932 | Cumple |
| 06 COPRAR | 53 / 98 / 143 | 1.975 | 0.976 | 2.951 | Cumple |
| 07 versión no admitida | 55 / 100 / 144 | 1.923 | 0.994 | 2.917 | Cumple |
| 08 vacío | 52 / 84 / 134 | 1.892 | 0.988 | 2.879 | Cumple |

Las tasas medias reales respectivas son 22.312, 20.942, 21.784, 21.868 y
20.987 fps, con PTS variables. Las fracciones exactas, índices y marcas
están en `recuperacion-honor-anotada/casoNN/video-anotado.json` y `resumen.json`.
El 01 muestra la selección y el rechazo, pero el indicador no ofrece un
inicio inequívoco: **no se publica un tiempo**. El 02 no demuestra lentitud
del producto: la incertidumbre impide decidir. Los mensajes 06/07 explican
la versión y sugieren pedir una exportación compatible, pero no nombran
explícitamente UNH; esto tampoco satisface el criterio de segmento del parseo.

**Disponibilidad del Honor, 20-oct:** entre 06:39:43Z y 06:45:19Z, las sondas
anterior y posterior comprobaron avión 1, Wi-Fi 0 y ping fallido. Se recorrieron
las once operaciones y se guardaron observaciones sanitizadas en
`honor-offline/01-carga.json` a `15-confirmado.json`, con `resultado.json`.
La carga reutilizó el perfil guardado; la confirmación se probó además desde
el editor, sin cambiar geometría ni inventar un límite. NV6 filtró 977 a 32,
la búsqueda encontró el ID anonimizado, las estadísticas conservaron
977/34/8366.1 t y las alertas 0/6/0. El CSV propio
`Descargas/t98b/t98b_offline.csv` quedó comprobado por tamaño (122,725 bytes).
Recientes reabrió A01 y los parámetros siguieron accesibles. **11/11 funcional**
en este recorrido; no se estima disponibilidad longitudinal. El control con
red no demostró historial atribuible, por lo que no se afirma cero bytes.
`restauracion.json` verifica avión 0, Wi-Fi 1, letra 1.0 y puntero `null`.

### RNF-008 · Tabla vigente

| Submétrica | Umbral | Medición de cierre | Dictamen |
|---|---|---|---|
| BAPLIE 2.2.1 | 0 negativos aceptados sin aviso, guía SMDG | 2 positivos y 9 negativos resueltos en batería; cobertura contextual 21/24 rutas no X del corpus, con límites declarados | Cumple batería acotada; conformidad completa no medible |
| BBBRRTT | 0 casos fallidos | 3 positivos conservados; 4 negativos con aviso visible; 6,271 posiciones del corpus bien formadas | Cumple casos medidos de formato |
| ISO 6346 | 0 casos fallidos con sintéticos; corpus anonimizado aparte | 3 dígitos válidos y 3 alterados: 0 fallos; corpus contado aparte | Cumple casos sintéticos medidos |
| UN/LOCODE | Lista oficial con edición y 0 casos fallidos | UNECE 2025-1: GTSTC/PAMIT presentes; ZZZZZ ausente y aceptado sin aviso | No cumple |
| KGM y VGM | 0 casos fallidos | WT/VGM 24,000 kg leídos en campos distintos; LBR/TNE convertidos con aviso; corpus y reservas cotejados | Cumple casos medidos; no certifica SOLAS documental |
| IMDG 42-24 | 8.1, incluye disposiciones por ONU | T-85: cotejos previos 289/289 y 60/60; columna 16b no evaluada | No cumple |

**RNF-008: no cumple**, por UN/LOCODE y la limitación IMDG fijada en 8.1.
No se ejecutó de nuevo el cotejo privado de T-85. No se corrige el producto.

**Batería del cierre:** `conformidad-cierre/conformidad.csv` y `.md` contienen
31 observaciones: 30 casos de norma y un control SMDG15 con aviso visible.
La prueba manual es un registrador, no una aserción automática de conformidad:
su `+1` no significa que 31 casos cumplan. La revisión encuentra 29/30 casos
de norma satisfactorios y **uno fallido**, el puerto inexistente ZZZZZ.
Se renderizó `VoyageSummaryCard` real a 1280×900; no sustituye el recorrido
visual de los tres clientes. Los 13 negativos cubiertos por T-108 avisan
(posiciones, dígitos, unidades y ausencia de UNB/BGM/UNT/UNZ); los cinco
negativos restantes de cabecera/TDT se rechazan. El nuevo negativo de puerto
se acepta en silencio. La pertenencia a UNECE se comprobó desde sus tres
partes oficiales, no por el formato de cinco caracteres.

Los positivos BBBRRTT comprueban forma y conservación del valor, incluido
9999999; no certifican que ese hueco exista en un buque. WT y VGM conservan
24,000 kg en sus campos respectivos. LBR 24,000 se convierte a 10,886 kg y
TNE 24,000 a 24,000,000 kg, ambos con «Pesos revisados». Es lectura y aviso,
sin demostrar verificación física ni documentación SOLAS de esa masa.

**Barrido agregado:** `corpus-cierre-reservas/estandares-corpus.json` conserva
SHA-256 por archivo, edición y huellas de los CSV. Los diez archivos se
admiten; A06 activa la lectura 1.5 con aviso. Hay 6,271 posiciones, ninguna
mal formada; 6,161 identificadores no vacíos, de los que 5,444 pasan el dígito
y los 717 de A06 no lo pasan. Los otros nueve archivos tienen el 100% de sus
IDs no vacíos con dígito válido. Estos datos son de un corpus **anonimizado**;
no se usan como certificación ISO del producto ni de números reales.
A08 y A08v_VGM contienen además 55 EQD sin identificador cada uno: son
reservas y se cuentan aparte, fuera del porcentaje de IDs.

Hay 16,452 ocurrencias de puerto cotejadas y 2,563 ausentes de la edición;
son ocurrencias, no códigos distintos. No se atribuyen automáticamente a
defectos ni se revelan códigos del corpus: pueden depender de la
anonimización y la edición. El fallo reproducible se apoya en el sintético
ZZZZZ, cuya ausencia se verificó. Las huellas de las tres partes oficiales
son `a578f1caa76850f0d46ff7dab71bed53be84f8a0b0b3b6157e7de6d169ba37f2`,
`b63c997fd42acfffbc8b3d8dd4ad6d97182dd8a0f123f6fa29bad41219b68dcc` y
`65898aef20602d63b5394af4ebb2ddb1f0d0ad2ee0841c07040046b111a9371d`.
La edición se conserva intencionalmente fija en 2025-1; no se afirma que sea
la publicación más reciente. [Publicaciones UNECE](https://unlocode.unece.org/publications/).

Todas las MEA WT/VGM/T encontradas llevan KGM con valor comparable; no hay
taras T en este corpus. Los totales por calificador coinciden entre fuente
y modelo en ocho archivos. En A08/A08v_VGM la fuente suma 7,081,500 kg y
los 405 contenedores suman 6,899,700 kg: los 181,800 kg restantes coinciden
con el peso nominal de las 55 reservas del modelo. No son pesos perdidos.
Las variantes VGM preservan su calificador y sus sumas; los datos completos
están en JSON, sin fragmentos comerciales.

**Cobertura SMDG:** la presencia por contexto alcanza 21 de las 24 rutas
no X del instrumento; faltan SG2/GID, SG2/DIM y SG3/EQA. Los cuatro grupos
aparecen en los diez archivos. RNG solo aparece en A04. Los tres contextos
X (RFF/NAD de cabecera y FTX de SG1) no se exigen. Esto es cobertura de
presencia, sin validar cada cardinalidad, dato ni orden. No demuestra
conformidad integral, y las tres ausencias se declaran sin ocultarlas.
La referencia es la [guía SMDG BAPLIE 2.2.1](https://smdg.org/wp-content/uploads/MIGs/BAPLIE/Baplie221-03.pdf),
capítulos 4, 5.2 y 7: se cotejaron estructura por grupos, BBBRRTT, KGM y VGM.

**Incidencia de ejecución:** `conformidad-b/` fue ejecutada por error desde
el repositorio de trabajo y queda descartada como medición de cierre. La
corrida válida `conformidad-cierre/` se repitió desde la copia limpia de
TEMP y su registro identifica esa ruta. No se cambió código de producto.

### RNF-002 · Tabla vigente y piloto

| Submétrica | Umbral | Medición de cierre | Dictamen |
|---|---|---|---|
| Primera visualización sin perfil, rige | ≤3 pasos y ≤30 s hasta rejilla; 5 repeticiones por cliente | 15 filas vacías preparadas; sin videos medidos todavía | No medible |
| Con perfil | Informativa, 5 repeticiones por cliente | 15 filas vacías preparadas | No medible; informativa |
| Idioma | Español / total de cadenas visibles | 4,997 literales candidatos; revisión pendiente | No medible |
| Material 3 | 100% controles interactivos; Material y colorScheme | 210 controles candidatos; revisión pendiente | No medible |
| Aprendizaje | Cinco tareas sin ayuda en <10 min | Piloto pendiente de Carlos, cinco participantes COMAR | No medible |
| SUS, indicador 6 | Meta ≥68 | Sin participantes ni respuestas | No medible |

**RNF-002: no medible** en este corte. No se extrapolan los dictámenes de
T-44 al cierre. La rejilla queda excluida del denominador M3 por carecer de
equivalente Material; sus controles externos sí cuentan.

El recorrido del Honor devuelve «Back» para el control de retroceso de
Alertas, Recientes y Parámetros (`honor-offline/04-alertas.json`,
`10-recientes.json`, `12-parametros.json`). Es una etiqueta de accesibilidad
observada, sin captura del tooltip desplegado ni censo completo. Se registra
como hallazgo para la revisión de idioma, sin convertir 4,997 candidatos en
un denominador revisado. `BayStreamApp` activa Material 3 en ambos temas;
la lectura de selector de bahías, leyenda y Alertas comprobó componentes
Material y colores derivados de `colorScheme`. Eso tampoco certifica el
100% de los 210 candidatos, que incluye entradas H5 ajenas a rutas de producto.

`hojas/` contiene el protocolo vigente con el SHA completo, las 99 filas de
operaciones (11×3×3), 24 recuperaciones y 30 primeras visualizaciones; también
25 filas de tareas P1–P5 y cinco cuestionarios SUS vacíos. Las tareas fijas y
la fuente SUS constan en la sección histórica «Hoja de medición y piloto» y
en `hojas/protocolo.md`. No hay nombres, correos, respuestas ni datos inventados.

### Pendientes para reanudar

1. RNF-004 A: las 11 operaciones por cliente ya se recorrieron. Falta el NetLog
   global que Carlos debe iniciar manualmente y verificar frente al service
   worker; el HAR limitado no lo sustituye. El Honor no demuestra control
   positivo de contabilización. Conservar esos límites al dictaminar.
2. RNF-006: completar videos y anotación de los ocho casos en Windows/Web,
   repetir Honor 01/02 con inicio e incertidumbre suficientes, revisar el censo
   completo de mensajes y medir disponibilidad con red realmente desconectada
   en Windows/Web. Los casos admitidos 03/04 no se convierten en rechazos.
3. RNF-008: revisar independientemente las tablas y completar la cobertura
   normativa faltante si corresponde. Conservar el fallo ZZZZZ y la limitación
   IMDG, sin arreglar el producto ni afirmar conformidad integral por presencia.
4. RNF-002: grabar las 30 primeras visualizaciones y anotar sus pasos/PTS;
   completar censos revisados de idioma y controles. Piloto/SUS preparado,
   todavía sin participantes.
5. Al final, una tanda con Carlos: crear «PRUEBA T-98» desde la app con un
   BAPLIE sintético, iniciar él mismo las sesiones `t98` y aprobar `pktmon`.
   Chrome Security y NetLog requieren su intervención manual; no capturar el
   inicio de sesión ni «Nube y cuenta». TLS real antes de sincronizar; condición
   B informativa. Carlos cierra las sesiones al terminar.
6. Aceptación cruzada por Timonel de una fila de cada RNF. No realizada;
   Capitán no contactó ni delegó en otro programador.

**Punto de suspensión de interfaz:** al intentar activar la ventana Chrome
de T98 con Computer Use, la herramienta detuvo automáticamente el control
porque no pudo determinar la URL actual con confianza suficiente para aplicar
su política. No se intentó la misma interacción mediante otra superficie.
Antes ya había rechazado abrir `chrome://net-export` porque solo admite
HTTP/HTTPS; no se buscó un rodeo por shell/CDP. Estos son límites de la
automatización, no fallos de BayStream. La siguiente sesión debe recuperar
el control permitido antes de nuevas mediciones visuales. El origen local es
`http://127.0.0.1:5898/`; el servidor propio quedó disponible (PID 31172),
y el almacén Web del origen se conserva aunque se cierre su pestaña.

### Validación final de este corte

- `flutter analyze --no-pub` en la copia: **0 issues**, 46.5 s,
  `analyze-20oct.txt`.
- Suite por defecto en la copia: **1047/1047, sin omisiones**, código 0,
  43 s, `suite-20oct.txt`. Se usó el manifiesto original únicamente durante
  la suite para la aserción de etiqueta de T-88 y se restauró el T98 en
  `finally`; no se recompilaron los binarios medidos.
- Batería manual: registrador **1/1** y 31 observaciones revisadas aparte;
  el caso UN/LOCODE fallido no se oculta detrás de ese verde.
- Auxiliares Python: **10/10**, `python test/t98_auxiliares_test.py`.
  La invocación previa con `python -m unittest test/t98_auxiliares_test.py`
  falló al importar el módulo; se corrigió la invocación y se ejecutaron los
  diez casos. Compilación sintáctica de los tres nuevos Python correcta.
- Sonda Honor: **5/5** autocomprobaciones. Honor restaurado: avión 0,
  Wi-Fi 1, letra 1.0, indicador de puntero `null`. No se alteró densidad.
- Sin Windows BayStream ni FFmpeg activos al cerrar la verificación.
- La inspección Git de solo lectura muestra documentos de tesis ajenos
  modificados: no se tocaron y no se incluyen en los comandos de esta tarea.

No se cambian criterios T63. Sin Git de escritura, publicaciones, Firebase
CLI/consola, acceso a T-105, demo17, archivos de producto o almacén real.
`pubspec.yaml` y `pubspec.lock` **sin cambios**.

### Archivos de este corte y entrega a Carlos

Modificados: `docs/T98-RESULTADOS.md`, `tool/t98_main.dart`,
`tool/t98_catalogo_invalidos.dart`, `tool/t98_estandares_corpus.dart`,
`tool/t98_estandares_test.dart` y `tool/t98_sonda_red_windows.ps1`.
Nuevos: `tool/t98_honor_ui.py`, `tool/t98_recuperacion_honor.py` y
`tool/t98_video_cuadros.py`. No se modificó `test/`, `lib/` ni `pubspec.*`.
Ninguna de estas nueve rutas está ignorada; la evidencia en TEMP no se versiona.

Tres líneas de resumen:

1. Condición A recorrida en tres clientes, con límites de captura de red explícitos.
2. Honor sin red 11/11; recuperación parcial anotada por PTS y errores descriptivos pendientes de censo.
3. Estándares medidos sobre cierre: fallo de UN/LOCODE, IMDG limitado y corpus con reservas cotejadas.

Comandos **solo para Carlos**, un commit para este corte de T-98:

```powershell
git add -- docs/T98-RESULTADOS.md
git add -- tool/t98_main.dart
git add -- tool/t98_catalogo_invalidos.dart
git add -- tool/t98_estandares_corpus.dart
git add -- tool/t98_estandares_test.dart
git add -- tool/t98_sonda_red_windows.ps1
git add -- tool/t98_honor_ui.py
git add -- tool/t98_recuperacion_honor.py
git add -- tool/t98_video_cuadros.py
git commit -m "Sprint 3: medir Fase B de T98 y registrar limites"
git push
```

**Mensaje para Yov:**

> Yov: continué T-98 B sobre 90dce4bf09ab57e16a937460854c4a6d2b4034e5.
> RNF-004 sigue no medible: A funcional 11/11 por cliente, sin NetLog global
> ni control positivo atribuible del Honor. RNF-006 no cumple por mensajes;
> Honor sin red 11/11, cuatro recuperaciones con cota <3 s y dos inconclusas;
> 03/04 se admiten y Windows/Web siguen pendientes. RNF-008 no cumple:
> ZZZZZ ausente de UNECE 2025-1 se acepta en silencio, además de IMDG 16b.
> Batería de 30 casos de norma: 29 satisfactorios y uno fallido; más un
> control. Corpus de diez archivos procesado, reservas y pesos cotejados,
> GID/DIM/EQA ausentes. RNF-002 sigue no medible; hojas y piloto preparados.
> Analyze 0 y suite 1047/1047 en copia. Solo informe y ocho instrumentos;
> producto/pubspec intactos, sin Git ni publicaciones. Interfaz suspendida
> por bloqueo automático al no poder verificar la URL de Chrome. Informe
> vigente en docs/T98-RESULTADOS.md; pendientes precisos al final. Carlos
> aún debe completar la tanda de cuentas/pktmon después de lo sin sesión.
