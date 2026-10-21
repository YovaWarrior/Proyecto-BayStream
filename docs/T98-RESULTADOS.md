# T-98 · Instrumentos RNF-004, 006, 008 y 002

Capitán Codex · 17-oct-2026 · Fase A · base `9ae744a` de `sprint-3`.

**Vigencia:** las secciones finales del cierre **33404a5 (sprint3-cierre-2)**
registran el trabajo vigente del 20-oct. Prevalecen sobre los pendientes y bloques Git
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

## Continuación · Decisión 10.92 · 20-oct-2026

Esta sección incorpora la instrucción actual de Carlos y prevalece sobre los
pendientes históricos del corte anterior. **En curso.** La Web pasa al
navegador integrado de Codex, en `http://127.0.0.1:5898/`; no se vuelve a
automatizar Chrome. Se declara ese entorno, como en 10.55 y 10.70. RNF-002
requiere ahora **cinco repeticiones sin perfil y una con perfil por cliente**
(18 en total, no 30). La condición con perfil es informativa.

Los censos de idioma, Material 3 y mensajes de error pertenecen a Timonel,
en `docs/T98-CENSOS-RESULTADOS.md`. Capitán no los duplica ni modifica ese
archivo: los citará cuando estén entregados. No se vuelve a ejecutar RNF-008
ni se corrige ZZZZZ; queda el resultado «no cumple», para Sprint 4. No se
desconecta la laptop: Windows/Web sin red se reservan para Carlos al final.

### Windows · Catálogo grabado, anotación en curso

Se reutilizó el mismo EXE release, SHA-256
`596db54f24bee78cf23b28249aca2ebf6f75ef25e31c5c5f572977c3002be359`,
abierto con `explorer.exe`, PID 15804. Almacén efectivo: el directorio T98
aislado de TEMP declarado antes. Se reabrió A01 desde Recientes (977/34),
sin sesión; no se abrió «Nube y cuenta». La app se cerró por su PID al
terminar el catálogo.

Evidencia nueva en `%TEMP%\t98-b-90dce4b-19oct\continuacion-20oct\windows\`.
`formal/rec01.mp4` a `rec08.mp4` registran los ocho casos. El 03 abre
Parámetros del buque: se canceló sin confirmar ni reemplazar el viaje anterior.
El 04 se admite con el aviso de UNT/UNZ y mantiene 977/34/8366.1 t; es el
viaje anterior de los casos siguientes. Los otros seis rechazan y el botón
de carga vuelve a abrir el selector. Los PTS y sus hitos aún se están revisando;
**ocho grabaciones no significan ocho recuperaciones aprobadas**.

El instrumento nuevo `tool/t98_grabar_escritorio.py` captura un rectángulo
de 1900×1068 que contiene la app y el selector; usa FFmpeg, sin entrada de
Windows por script. Inicia y cierra por archivo de control bajo TEMP,
conserva PID propio y metadatos, limita la captura a 180 s y evita sobrescribir.
Se piden 30 fps, pero la tasa y los intervalos se leen del video. Los tiempos
del host no son la medición. El recorte por título de app se descartó para
este uso porque excluye el selector nativo.

**Calibraciones descartadas:** `encuadre-*.mkv`, el primer `rec01.mp4` fuera
de `formal/`, y las carpetas `serie/`, `medicion/`, `catalogo/` y
`escala-explicita/` son ensayos del instrumento. Cambiar entre el selector
y la app invalida referencias de captura/escala: hubo sondas fuera del
botón, un intento de teclado que no lo activó y una referencia de captura
rechazada como desconocida. Ninguno se atribuye al producto ni aprueba una
recuperación. La serie `formal/` refresca la captura de la app antes de
aplicar la sonda y muestra su reapertura real.

La lectura intermedia del instrumento añade aproximadamente 2.8–3.2 s
antes de la sonda. Ese retraso queda incluido; no se resta ni se presenta
como demora del producto. Si la prueba solo confirma operatividad después
de 3 s por ese retraso, no permite decidir si BayStream ya era operativa
antes. Se publicarán cotas observadas y la limitación, sin convertirla en
un incumplimiento de recuperación. El dictamen de mensajes se consolidará
con el censo de Timonel.

**Anotación Windows terminada para esta serie:** los ocho videos conservan
PTS estrictamente crecientes, verificados en `formal/pts-verificados.json`.
Se revisaron cuadros originales y contactos; `anotacion-revisada.json`
conserva índices, PTS, tasas y limitaciones. El inicio anotado es una cota
conservadora del selector antes de confirmarse/cerrarse, no una marca exacta
del contacto. El error se anotó con el texto completo y el viaje anterior
visibles; el final muestra el selector reabierto con su lista. GDI deja
blancas algunas superficies nativas del selector: no se afirma que todos
sus controles estén dibujados en ese cuadro.

| Caso Windows | Cuadros inicio conservador / error y viaje / selector | Intervalo observado (s) | Incertidumbre de cuadros (s) | Tasa media real (fps) | Dictamen temporal |
|---|---|---|---|---|---|
| 01 bytes aleatorios | 161 / 230 / 320 | 5.298 | 0.063 | 30.051 | No medible frente a 3 s por espera instrumental |
| 02 texto sin EDIFACT | 306 / 399 / 453 | 4.902 | 0.052 | 30.038 | No medible frente a 3 s por espera instrumental |
| 03 segmento cortado | Abre Parámetros; cancelado | — | — | PTS en JSON | No es un rechazo recuperado |
| 04 sin UNT/UNZ | Admitido con aviso, 977/34 | — | — | PTS en JSON | No es un rechazo recuperado |
| 05 sin TDT | 383 / 477 / 541 | 5.276 | 0.079 | 30.051 | No medible frente a 3 s por espera instrumental |
| 06 COPRAR | 278 / 349 / 434 | 5.195 | 0.062 | 30.034 | No medible frente a 3 s por espera instrumental |
| 07 versión no admitida | 160 / 256 / 314 | 5.127 | 0.062 | 30.030 | No medible frente a 3 s por espera instrumental |
| 08 vacío | 182 / 239 / 325 | 4.769 | 0.064 | 30.039 | No medible frente a 3 s por espera instrumental |

Son intervalos conservadores observados con una comprobación tardía, **no
latencias intrínsecas de recuperación**. La incertidumbre de cuadros no
incluye ni elimina el efecto de esa espera. No se infiere que el producto
incumpla ni que cumpla <3 s. Los seis rechazos conservaron el viaje y
reabrieron carga; los mensajes se ven en `errores-verificacion.jpg` y los
cuadros completos. 06/07 no nombran UNH explícitamente, igual que en Honor.

Durante la búsqueda de candidatos, la salida raw de miniaturas advirtió
DTS cuantizados en su muxer. No se modificó el MP4 y el número de imágenes
decodificadas coincidió con todos los cuadros del original. Las lecturas
posteriores usan una secuencia de índices para las miniaturas y **siempre
los PTS originales del MP4 para medir**; no se reconstruyen marcas del video.

### Honor · Repetición 01/02 resuelta

Se mantuvieron APK y datos T98 del cierre. Se reabrió A01 desde Recientes:
977/34/8366.1 t, sin aviso de incompleto. Los ensayos anteriores no se borran.
El nuevo 01 con 120 ms volvió a omitir el contacto activo en la captura y
queda sin tiempo publicable. El 02 con 120 ms sí muestra la transición.

Se añadió a `tool/t98_recuperacion_honor.py` la opción `--pulsacion-ms`
(120 o 300). Para 300 exige leer y acreditar que el umbral de pulsación
larga del dispositivo sea superior: se comprobó **400 ms**, sin modificarlo.
La repetición 01 con 300 ms conserva el tramo de contacto y su liberación.
Se restauró el indicador de puntero al finalizar cada corrida; el calentamiento
previo de las primeras dos también se restauró en `finally`.

**Evento inicial declarado antes de anotar:** último cuadro con contacto
activo P=1 antes de la liberación P=0 que confirma el archivo. Es una cota
conservadora inmediatamente anterior a confirmar, en vez del primer contacto
separado por un largo intervalo estático del video. Se conservan ambos
cuadros como intervalo de confirmación. No se resta la duración del gesto
ni la espera solicitada de 1 s de la sonda. El final es un cuadro verificado
con selector completo, sin afirmar que sea el primero posible.

| Caso | Fuente bajo `continuacion-20oct/` | Último P=1 / primer P=0 / error y viaje / selector | Confirmación acotada por PTS (s) | Intervalo conservador (s) | Incertidumbre (s) | Cota superior (s) | Dictamen |
|---|---|---|---|---|---|---|---|
| 01 | `honor-300ms/rec01.mp4` | 72 / 73 / 111 / 147 | [3.759633, 3.785033] | 1.849 | 0.030 | 1.880 | Cumple esta recuperación |
| 02 | `honor/rec02.mp4` | 63 / 64 / 114 / 150 | [3.599400, 3.618156] | 2.005 | 0.032 | 2.037 | Cumple esta recuperación |

Las tasas medias reales son **22.313 y 23.419 fps**, respectivamente, con
PTS variables. Los 168 cuadros del 01 y los 157 del 02 conservan exactamente
los PTS de origen y su crecimiento estricto. `honor-repeticion-anotada.json`
reúne los datos y cada carpeta conserva `anotadoNN/video-anotado.json`, los
cuadros originales, contactos de hitos y tiras del indicador.

Estos resultados sustituyen únicamente los pendientes temporales 01/02 del
Honor. Junto con 05/06/07/08 del corte previo, los seis rechazos medidos
acreditan <3 s; 03/04 siguen siendo admisiones, sin tiempo de rechazo.
RNF-006 global continúa pendiente de Web, de los límites de Windows y del
censo de mensajes encargado a Timonel. Estado comprobado tras las corridas:
avión 0, Wi-Fi 1, letra 1.0, puntero `null`, umbral largo 400 ms intacto.

### Web integrada · Ocho casos y PTS revisados

Se utilizó el navegador **integrado de Codex**, visible, autorizado por Carlos
en 10.92. Origen exclusivo `http://127.0.0.1:5898/`, mismo build release y
SHA del cierre. El registro de inicio confirmó `Firebase=true` y
`sesionInicial=ausente`; no se abrió la cuenta. A01 se cargó con el selector
real, «No lo tengo» y confirmación: 977/34/8366.1 t. Después del 04, el
viaje previo es esa copia admitida con aviso de UNT/UNZ.

`tool/t98_iab_grabar.mjs` conserva los JPEG originales de
`Page.screencastFrame`, su `metadata.timestamp`, secuencia CDP y confirmaciones
de los eventos reales de selector. No se asumieron fps constantes. El
selector interceptado **no se dibuja en la página**: el final combina el
cuadro revisado del error/viaje con `Page.fileChooserOpened`, seguido por
cuadros posteriores y la resolución real de `waitForEvent('filechooser')`.
Es una comprobación instrumental de reapertura; no se presenta como video
de un selector nativo visible. La sonda solicita carga después de 500 ms;
ese tiempo permanece incluido.

Inicio conservador: primer cuadro recibido y reconocido antes de confirmar
el archivo. Final conservador: último cuadro de la captura, posterior al
evento del selector y a su confirmación. La incertidumbre suma los dos
intervalos extremos de cuadros; no se resta ninguna espera. Se revisaron
los originales finales completos: error legible y viaje previo conservado.

| Caso Web | Fuente bajo `continuacion-20oct/web-iab/` | Cuadros; inicio/final | Intervalo (s) | Incertidumbre (s) | Cota superior (s) | Tasa media real (fps) | Resultado |
|---|---|---|---|---|---|---|---|
| 01 | `serie/rec01/` | 30; 0/29 | 1.422 | 0.116 | 1.539 | 20.390 | Recuperación <3 s corroborada por selector |
| 02 | `serie/rec02/` | 25; 0/24 | 1.349 | 0.890 | 2.238 | 17.794 | Recuperación <3 s corroborada por selector |
| 03 | `serie3/rec03/` | 11 | — | — | — | 3.621 | Abre Parámetros; cancelado sin confirmar |
| 04 | `serie/rec04/` | 11 | — | — | — | 5.740 | Admitido, aviso UNT/UNZ, 977/34/8366.1 t |
| 05 | `serie2/rec05/` | 32; 0/31 | 1.376 | 0.122 | 1.498 | 22.527 | Recuperación <3 s corroborada por selector |
| 06 | `serie/rec06/` | 27; 0/26 | 1.207 | 0.009 | 1.216 | 21.541 | Recuperación <3 s corroborada por selector |
| 07 | `serie/rec07/` | 29; 0/28 | 1.250 | 0.115 | 1.365 | 22.399 | Recuperación <3 s corroborada por selector |
| 08 | `serie/rec08/` | 44; 0/43 | 1.141 | 0.118 | 1.260 | 37.675 | Recuperación <3 s corroborada por selector |

`tool/t98_iab_video.py` empaqueta los cuadros en MP4 con base temporal de
microsegundos, sin interpolar ni añadir cuadros. La dimensión JPEG de
1203×960 exige una columna negra para H.264: no se escala la interfaz.
Se verificaron **todos los PTS y cantidades de los ocho MP4**, iguales a los
timestamps relativos originales cuantizados a 1 µs (error máximo 0.5 µs).
Cada carpeta conserva `captura.json`, `video-verificado.json` y huellas SHA.
`revision-candidata.json` contiene los cálculos; los seis originales finales
se revisaron manualmente, además del contacto `verificacion-errores.jpg`.

**Ensayos descartados:** `rec01/`, `formal01/`, `valido01/`, `serie/rec03/`,
`serie2/rec03/` y `serie/rec05/` conservan errores de referencia del selector,
comprobaciones prematuras o la cancelación no soportada por `setFiles([])`.
No son defectos de BayStream ni mediciones aprobadas. El 03 válido es
`serie3/rec03/`; el 05 válido es `serie2/rec05/`. El aviso gris residual
«Carga cancelada» del 03 sigue visible durante el 04; no se confunde con el
aviso rojo de archivo incompleto, que sí corresponde al 04.

**AVANCE del bloque:** los seis rechazos Web tienen cotas inferiores a 3 s,
con la limitación explícita del selector interceptado. Honor también tiene
los seis; Windows confirma conservación y reapertura, pero sus sondas
tardías no deciden el umbral temporal. RNF-006 global aún no se cierra.

### RNF-002 · Primera visualización Honor completa

Instrumento `tool/t98_primera_honor.py`, únicamente paquete `.t98`. Se abrió
desde el icono real «BayStream T98» del launcher, con contacto corto de
300 ms, inferior al umbral de 400 ms. El indicador se restauró en `finally`.
La corrida con perfil conservó el perfil existente; antes de cada corrida
sin perfil se reiniciaron **solo los datos desechables de `.t98`** con
`pm clear gt.cmartinez.baystream.t98`. Ninguna otra app se tocó. El selector
usó A01 de `Descargas/t98b`. Al terminar: avión 0, Wi-Fi 1, letra 1.0,
puntero `null`; `.t98` cerrada por su paquete, datos de la última corrida
conservados para la tanda con Carlos.

**Seis acciones sin perfil:** (1) icono, (2) Seleccionar archivo, (3) A01 en
el selector, (4) No lo tengo, (5) Confirmar y ver el plano, (6) Bay Plan.
Con perfil son cuatro: se omiten 4/5. No se cuentan los desplazamientos.
La confirmación abre Lista; por eso Bay Plan es otra acción necesaria.

Se anotó el inicio entre el último cuadro verificado P=0 y el primer P=1
legible del contacto sobre el icono. Algunos cuadros intermedios muestran
negro en la franja del indicador: no se les atribuye un estado. El final
está entre el último cuadro sin rejilla y el primero con rejilla. Para
inicio `[i0,i1]` y final `[f0,f1]`, se informa el intervalo de duración
`[f0-i1, f1-i0]`: **la cota superior ya incluye la incertidumbre de ambos
extremos; no se suma otra vez**. Todos los originales y sus vecinos se
revisaron. Los tiempos ADB no se usan para el dictamen.

| Honor, corrida | Cuadros P0/P1; sin rejilla/con rejilla | Duración acotada (s) | Anchura de incertidumbre (s) | Pasos | Tasa media real (fps) | Dictamen |
|---|---|---|---|---|---|---|
| Sin 01 | 0/3; 409/410 | [29.037, 29.527] | 0.490 | 6 | 13.077 | No cumple pasos; tiempo ≤30 s |
| Sin 02 | 0/3; 405/406 | [29.068, 29.625] | 0.557 | 6 | 12.881 | No cumple pasos; tiempo ≤30 s |
| Sin 03 | 1/3; 408/409 | [29.349, 29.600] | 0.251 | 6 | 12.878 | No cumple pasos; tiempo ≤30 s |
| Sin 04 | 0/3; 407/408 | [29.017, 29.538] | 0.521 | 6 | 13.004 | No cumple pasos; tiempo ≤30 s |
| Sin 05 | 1/4; 405/406 | [29.196, 29.456] | 0.259 | 6 | 12.792 | No cumple pasos; tiempo ≤30 s |
| Con, informativa (`con02`) | 1/3; 262/263 | [18.693, 18.930] | 0.237 | 4 | 12.512 | Informativa; tiempo ≤30 s |

Las cinco sin perfil incumplen ≤3 pasos aunque sus cotas temporales estén
dentro de 30 s. Los intervalos incluyen observaciones del instrumento y
navegación del selector: no son una estimación del tiempo mínimo humano.
Fuente: `continuacion-20oct/primera/honor/primera-anotada.json`; cada corrida
conserva video, SHA, todos sus PTS, acciones y `anotacion.json`. Se cotejaron
exactamente los PTS originales y recortados de los seis videos. `con01` es
un ensayo descartado: el texto de carga de inicio se duplicaba en un título
y un botón; el instrumento se detuvo sin elegir un control ambiguo.

**RNF-002 ya tiene evidencia de no cumple por pasos**; faltan Windows/Web
y los censos de Timonel para completar la tabla, no para invertir este fallo.

## Continuación vigente · Cierre 2 · Decisiones 10.93–10.96

**Base nueva:** `sprint3-cierre-2`, commit completo
`33404a5804be4fad85aab80dd923a7ae9e878ee9`. La etiqueta es anotada: su objeto
es `f631efa8c756a7df4f6923d7ca15a5a5eae97c70`; al resolver `^{commit}` se
obtiene el SHA anterior. No se confunde el objeto etiqueta con el commit.
Al retomar, HEAD era `70270f5`, decisión 10.96, en `sprint-3`.

Se comprobó el chat «Aceptar T-112» y
`docs/T112-ACEPTACION-RESULTADOS.md`: **ACEPTADA con observaciones**, ya
versionada en `6206615`, sin cambios pendientes de producto ni otro cierre.
La decisión 10.96 mantiene `33404a5` y asigna a Codex la máquina durante su
ventana; se anuncia `SEMÁFORO: mido` al ocuparla y `SEMÁFORO: libre` al
terminar o parar. No se contacta a Timonel; Carlos coordina los turnos.

**Conservación autorizada por 10.93:** condición A de RNF-004 en los tres
clientes, Honor sin red 11/11, barrido del corpus RNF-008 y las seis primeras
visualizaciones del Honor anotadas arriba. T-112 cambia textos y localización,
sin cambiar pasos, datos o red; su aceptación no encontró un cambio que
invalide esa conservación. Se conservan también las limitaciones originales
de las sondas: ninguna certifica cero bytes.

**Repeticiones obligatorias sobre el cierre 2:** ocho casos de recuperación
por cada cliente (24), batería de conformidad RNF-008, tres censos y las
primeras visualizaciones Windows/Web (5 sin perfil +1 con perfil por cliente).
Las recuperaciones del cierre anterior son **evidencia histórica**, aunque
hubieran aprobado: no se trasladan al dictamen del cierre 2.

Windows llegó a grabar primeras visualizaciones del cierre anterior en
`continuacion-20oct/primera/windows/`: `con02`, `sin01b`, `sin02b` y `sin03`
completaron la rejilla; `sin04` se interrumpió al recibirse la nueva decisión,
antes de completar el selector. No se usan para cumplir las doce corridas
Windows/Web ahora solicitadas. `con01`, `sin01` y `sin02` son ensayos
descartados; `sin02` alcanzó el límite de captura de 180 s. Las pausas de
observación impiden atribuir esos intervalos a rendimiento intrínseco.
Se cerró solo el PID de T98 y no se tocó otro BayStream. Los almacenes TEMP
apartados se conservan. El primer traslado se detuvo con un archivo todavía
retenido tras cerrar el proceso; se verificaron ambos directorios, se trasladó
solo el archivo propio restante y se acreditó el origen vacío. Los traslados
siguientes esperaron `WaitForExit` antes de mover.

### Copia nueva e instrumentos

`tool/t98_cierre2.py preparar` creó por `git archive` una copia nueva en
`%TEMP%\t98-b-33404a5-20oct\app`, con manifiesto SHA-256 de todos los originales
antes de superponer **solo** instrumentos `tool/t98_*`. `lib/` y `pubspec.*`
se verifican byte a byte contra el archivo original. No se copian la firma
de subida ni la configuración privada; esta última solo se pasa por ruta a
Flutter, sin abrirla ni imprimirla. Los tres binarios nuevos y sus huellas
quedan pendientes hasta finalizar la compilación.

Instrumentos ajustados antes de medir: «Plano» sustituye a «Bay Plan» en el
recorrido Android; los grabadores Honor/IAB exigen el SHA completo por
argumento, en vez de incrustar el cierre anterior. Las hojas preparan **18**
primeras visualizaciones, según 10.92. La comprobación Python existente se
actualizó para exigir cinco sin perfil y una con perfil en cada cliente:
**10/10 auxiliares pasan**; `node --check` del grabador IAB pasa.
El grabador de escritorio amplió su límite automático de 180 a **600 s** para
conservar recorridos largos del instrumento; el umbral RNF sigue en 30 s.

### Censos repetidos sobre 33404a5

Se ejecutó el `tool/t112_censos.py` archivado en la copia nueva, que importa
los cinco `tool/t98c_*` archivados, sin modificarlos. `--antes` apunta al
`app/lib` byte idéntico de `90dce4b`, conservado del primer cierre. No hubo
cadenas pendientes ni errores. Evidencia y huellas:
`%TEMP%\t98-b-33404a5-20oct\censos\`.

| Submétrica | Umbral | Medición repetida | Dictamen de Capitán |
|---|---|---|---|
| RNF-002 idioma | Español en el 100 % de textos visibles | 4853 cadenas censadas; 1790 visibles: 1657 español, 133 sin idioma; 0 inglés/mixtas. 20 grupos Flutter en español | Cumple en el alcance del censo |
| RNF-002 Material 3 | 100 % de controles interactivos incluidos | 237 controles, 12 exclusiones declaradas, 0 excepciones | Cumple en el denominador T63 2.4 |
| RNF-006 mensajes | 100 % causa y acción; segmento cuando es lectura BAPLIE | 218/218 explícitos; 12/12 de lectura con segmento; envolturas declaradas en CSV | Cumple el censo |

El censo traslada decisiones semánticas declaradas por línea; ejecutarlo no
equivale a revisar manualmente 218 mensajes. El control independiente ya se
realizó sobre **este mismo cierre** en la aceptación de T-112: muestra de 20
sin reemplazo, semilla `11220261020`, **20/20** con causa y acción, con fuentes
en `build/t112acc/muestra-independiente.json`. Se cita esa aceptación y su
informe, sin presentarla como una segunda muestra nueva de este chat.
Las exclusiones de Material y las cadenas sin idioma conservan las reglas
del censo; no se afirma haber auditado todos los colores de `lib/`.

Estos resultados sustituyen los fallos históricos de idioma, buscador y
mensajes del primer cierre. RNF-002 sigue **no cumple por pasos**, demostrado
en Honor y conservado por decisión expresa. RNF-006 global queda **no medible**
en este corte: falta repetir recuperación y medir sin red Windows/Web. No se
arrastra al cierre 2 el anterior «no cumple» de mensajes. RNF-008 conserva
**no cumple**, por IMDG y ZZZZZ, pendiente de repetir su batería. RNF-004
permanece **no medible** hasta completar sus evidencias con Carlos.

### Validación y conformidad repetidas · Cierre 2

`tool/t98_cierre2.py validar`, en la copia nueva: pub get offline, suite,
analyze y batería de conformidad, **en serie**. Se hicieron antes de cambiar
la etiqueta Android del banco, que la prueba T-88 exige literalmente.

| Validación | Resultado ejecutado |
|---|---|
| Suite Flutter | **1063/1063**, cero fallas y cero omitidas. Conteo de eventos `testDone` no ocultos del registro JSON; no se cuentan cargas o auxiliares ocultos |
| Analyze | **0 incidencias**, 32.8 s |
| Batería RNF-008 | **31 observaciones**: 30 casos de norma y un control del detector de avisos. El test de instrumento termina en exit 0; eso no significa que los 30 casos cumplan |
| Huellas posteriores | Los 137 Dart de `lib/` y `pubspec.yaml`/`pubspec.lock` siguen idénticos al archivo original del cierre |

La clasificación manual de las filas vuelve a dar **29/30 satisfactorias**.
Los negativos BBBRRTT, dígito ISO 6346 y unidades LBR/TNE avisan; las
cabeceras no admitidas y las ausencias UNH/TDT se rechazan; las ausencias
UNB/BGM/UNT/UNZ admitidas muestran aviso visible. El control SMDG15 muestra
su aviso en la tarjeta real. Pesos WT/VGM de los positivos: 24000 kg,
sin conversión inventada. El negativo **«Puerto inexistente ZZZZZ» vuelve
a aceptarse en silencio**, sin aviso visible. No se corrige (10.93).

Evidencia nueva: `suite.log`, `analyze.log`, `conformidad.log`, metadatos de
ejecución y `conformidad/conformidad.csv`/`.md`, bajo el banco `33404a5`.
Los CSV conservan el SHA de cada entrada sintética, el SHA completo de base
y las observaciones del lector. El barrido del corpus y su contraste UNECE
2025-1 se conservan del primer cierre por decisión expresa; **no se anuncian
como un barrido nuevo**. RNF-008 sigue **no cumple** por ZZZZZ y por IMDG
(8.1), con las coberturas y límites ya declarados.

### Binarios del cierre 2 e inicio de recuperación

Los tres builds release terminaron con exit 0, en serie y sin cambiar
`lib/`, `lib/main.dart` ni `pubspec.*`. Windows: 198.6 s; Web: 58.3 s;
Android: 105.8 s. Son tiempos de compilación, no métricas RNF.

| Artefacto nuevo | Bytes | SHA-256 |
|---|---|---|
| EXE Windows | 15937536 | `8944a08616efe2f5b7c5acb1f6fb7062f93c306ee8d751f61cf6852adb67a7d6` |
| Web `main.dart.js` | 5545522 | `dd9fdc47d1415fe4f98b8745f430fea440f58edc791767b223b1983a66966ffe` |
| APK release `.t98` | 68477323 | `845a4ae2ea251dc5e03ae4b836623d9f23fb291b201c265864508bd4fe863313` |

El manifiesto de los 49 archivos Web, antes de añadir cualquier lanzador del
instrumento, tiene SHA `028db6ff5a3dee4c7ac8e0e92b54bf4d05f1492eebd4d234912783ca82c869ac`.
`binarios.json` y `producto-despues-pruebas.json` acreditan 137 Dart de `lib/`
y ambos pubspec sin diferencias respecto del cierre archivado. Android solo
cambia `applicationId` a `gt.cmartinez.baystream.t98` y la etiqueta a
«BayStream T98» en la copia; `aapt` confirmó ambas y su actividad original.
No se copió `key.properties`. Firebase se compiló activo por definición y
configuración privada por ruta. Los avisos de compilación fueron MSB8029
por TEMP, la familia CupertinoIcons ausente y las notas Java de Firestore;
no se silenciaron ni se modificaron dependencias.

**Windows, ocho casos nuevos grabados:** PID 32912, abierto mediante
`explorer.exe`, almacén `%TEMP%\t98-b-33404a5-20oct\store-windows`, namespace
`t98`. A01: 977/34/8366.1 t. El 03 abre Parámetros y se cancela sin confirmar;
el 04 se admite con aviso UNT/UNZ y conserva esas cifras. Los seis rechazos
reabren carga. Se cerró solo ese PID al acabar. Los ocho videos tienen PTS
estrictamente crecientes; la anotación está en revisión. Las sondas siguen
siendo tardías por observar la pantalla antes de pulsar: **no se aprueba
ni se reprueba <3 s por una reapertura posterior al umbral**.

La captura original de 1900×1068 incluía el navegador de fondo porque la
ventana Windows ocupa 1600×900 físicos en este entorno. Se detectó al revisar
los cuadros y se prepara un recorte 1600×900 de la ventana propia, conservando
y comparando todos los PTS; no se usará el fondo como evidencia. Los contactos
de revisión acotados muestran el mensaje y el viaje. Los MP4 recortados y sus
comprobaciones temporales quedan pendientes de finalizar esa revisión.

**Honor, preparación del cierre 2:** el APK nuevo se instaló con `adb install -r`
solo sobre `.t98`. Se reabrió A01 desde Recientes, 977/34/8366.1 t, y «Plano»
confirma la interfaz nueva. El registro filtrado del PID propio confirma
`Firebase=true; sesionInicial=ausente`. Los nueve archivos del dispositivo
(ocho casos y A01) se cotejaron por SHA contra el catálogo nuevo y su
`origenSha256`: todos coinciden. El control local A01 no apareció en la
inspección del catálogo; se materializó desde la copia del Honor, **solo
después de acreditar su SHA contra el origen de la nueva generación**.
No se atribuye una causa a esa ausencia. Evidencia: `honor-inicio.json`.
Estado previo: avión 0, Wi-Fi 1, letra 1.0 y puntero `null`.

Se preparó además `tool/t98_sintetico.dart` para la tanda con Carlos:
**dos unidades totalmente ficticias, 36000 kg y dos bahías**, sin corpus.
Lo valida el lector real y sus dígitos ISO antes de escribir el archivo;
`dart analyze` del instrumento da 0. El primer borrador no compiló por
tratar un peso nullable como obligatorio; se corrigió con validación
explícita antes de generar el archivo. El sintético final y su huella están
en `sintetico/`; **no se creó ni se publicó ninguna operación**.

### Recuperación Honor repetida · Cierre 2

Se ejecutaron los ocho casos con el APK nuevo. Los MP4 están acotados a la
app/selector, sin barra de estado; todos sus PTS coinciden exactamente con
los originales y son estrictamente crecientes. La marca de toque duró
300 ms, por debajo del umbral de pulsación larga de 400 ms. El inicio se
acota entre el último P=1 y el primer P=0: **liberación de la selección**.
No se usan tiempos host/ADB ni se restan el gesto o la espera fija de 1 s.

| Caso rechazado | Cuadros P=1/P=0 | PTS de inicio acotado | Cuadro selector completo observado | Cota superior de recuperación |
|---|---|---|---|---|
| 01 bytes | 97/98 | [6.435233, 6.452678] | 190 (8.986056) | **2.550823 s** |
| 02 texto | 76/77 | [3.773511, 3.791756] | 171 (5.847011) | **2.073500 s** |
| 05 sin TDT | 74/75 | [3.811222, 3.829222] | 160 (6.041578) | **2.230356 s** |
| 06 COPRAR | 78/79 | [3.843478, 3.862244] | 164 (6.040011) | **2.196533 s** |
| 07 versión | 74/75 | [3.785778, 3.804922] | 161 (6.000111) | **2.214333 s** |
| 08 vacío | 78/79 | [3.823911, 3.842378] | 158 (5.902767) | **2.078856 s** |

Cada cota resta el PTS del último contacto al del selector **ya completo**;
no se atribuye al cuadro elegido ser el primero posible. Esta cota incluye
la incertidumbre de inicio y la observación tardía del final, y basta para
resolver **<3 s en los seis rechazos**. Se revisaron mensaje legible, viaje
anterior A01 (977/34/8366.1 t) y reapertura real, no solo un botón iluminado.
Los mensajes 06/07 nombran ahora UNH. En 05–08 sigue visible el aviso UNT/UNZ
del viaje cargado por 04; no se confunde ese aviso previo con el nuevo error.

El **03 admite y abre Parámetros**, cancelado sin confirmar; no tiene error
ni tiempo de recuperación de rechazo. El **04 admite con aviso UNT/UNZ**
y conserva las cifras de A01; también se observó la reapertura del selector,
sin presentarlo como rechazo. Evidencia: `recuperacion/honor/rec01..08`,
`hitos/`, `cierre/`, `puntero.jpg` y `recuperacion-anotada.json` del banco nuevo.

Restauración comprobada al acabar: avión **0**, Wi-Fi **1**, letra **1.0**,
puntero **null**. No se tocó la red de la laptop ni otra app del Honor.

### Windows y Web · revisión de recuperación del cierre 2

Los ocho MP4 Windows se recortaron a 1600×900. `recortes-verificados.json`
compara **todos** los PTS de cada origen y salida, sin diferencias, pérdida,
repetición ni cambio de orden. Se revisaron los seis mensajes de rechazo,
A01 preservado y el selector nativo reabierto. El 03 muestra Parámetros en
los cuadros 900/1200 y luego se cancela; el 04 muestra aviso UNT/UNZ.

| Windows | Último selector previo visible: cuadro/PTS | Error: cuadro/PTS | Selector reabierto observado: cuadro/PTS | Dictamen <3 s |
|---|---|---|---|---|
| 01 | 2247 / 74.975537 | 2351 / 78.434848 | 3724 / 124.200411 | No medible |
| 02 | 585 / 19.546182 | 691 / 23.068891 | 2094 / 69.834310 | No medible |
| 05 | 970 / 32.335292 | 1080 / 36.002182 | 1927 / 64.244519 | No medible |
| 06 | 461 / 15.378493 | 527 / 17.578752 | 1880 / 62.672298 | No medible |
| 07 | 435 / 14.510603 | 543 / 18.114200 | 1390 / 46.342465 | No medible |
| 08 | 439 / 14.648507 | 493 / 16.442118 | 1670 / 55.676244 | No medible |

El cierre visible del selector es un **proxy**, no el evento exacto de
confirmación. Los intervalos hasta las sondas tardías son 31.832–50.288 s;
no son latencia intrínseca de BayStream y no permiten aprobar ni reprobar
<3 s. Evidencia funcional completa; limitación temporal conservada.

**Corrección de preparación Web:** al arrancar desde caché limpia, el primer
build no tenía CanvasKit local y produjo 404/pantalla en blanco. No se usó
para mediciones. Se archivó en `web-incompleto-archivo/` y se repitió el
build con `--no-web-resources-cdn` (60.7 s). El bootstrap del producto exige
esas rutas locales. No se cambió código del producto. `tool/t92_verify.dart`
del cierre confirma **49 archivos, 36432661 bytes, sin errores**, antes de
añadir el lanzador del instrumento. Se actualizó el preparador T98 para
reproducir ese comando correcto.

**Huella Web vigente que sustituye la tabla anterior:** `main.dart.js`,
5545449 bytes, SHA `1fd04bfb2ef45f414e9d05fbc235c74e664b498314c427f86ada8a955b9a2fec`.
Manifiesto `web-local-manifiesto.json`: SHA
`b9d24192b42c9da229d5eda7363638bb3179d6bfad836eb152c17d080be231d8`.
Se cotejó además el cuerpo recibido en el IAB contra esa huella, sin
imprimir ni guardar su contenido de configuración. Inicio filtrado:
`Firebase=true; sesionInicial=ausente`. Servidor nuevo PID 30132,
únicamente `127.0.0.1:5898`, en la copia nueva. Se retiraron los workers,
cachés y almacenes de prueba del **único origen T98**; nada de otros sitios.
El comando CDP Storage no está disponible; se hizo mediante Runtime del
origen, tras salir al lanzador para cerrar sus bases.

La primera tanda Web rápida mostró mensajes transitorios anteriores todavía
en cola. Se conserva para auditoría y **no decide los seis rechazos**.
Las repeticiones `rec01/02/05/06/07/08-sin-cola` esperan fuera del video la
desaparición del aviso previo y verifican el mensaje propio antes de sondear.
Los casos 03/04 de la primera tanda sí documentan admisión y se conservan.

| Rechazo Web válido | Cuadros | Cota superior: video completo |
|---|---|---|
| 01 | 35 | 1.309699 s |
| 02 | 36 | 1.227233 s |
| 05 | 37 | 1.221961 s |
| 06 | 35 | 1.215439 s |
| 07 | 37 | 1.235731 s |
| 08 | 46 | 0.821791 s |

La cota va desde un cuadro **antes de confirmar** hasta el último cuadro,
posterior al evento real `Page.fileChooserOpened`. Incluye toda la captura,
por lo que resuelve <3 s sin fingir un instante exacto del selector que el
IAB intercepta y no dibuja. La secuencia CDP ubica ese evento antes del último
cuadro en los seis casos. Se revisaron visualmente error propio y A01
(977/34/8366.1 t), además de la apertura real. Se mantiene visible el aviso
UNT/UNZ previo de 04, sin confundirlo con el nuevo rechazo.

Los ocho MP4 Web válidos conservan cantidad y PTS relativos de **cada** JPEG
fuente con cuantización máxima de 0.5 microsegundos, sin interpolar cuadros;
`video-verificado.json`, capturas, eventos y anotaciones están bajo
`recuperacion/web/`. **Navegador integrado autorizado por Carlos (10.92)**,
visible durante las pruebas; Chrome no se usó para medir esta recuperación.

### Reanudación de las 19:46 · decisión 10.97 y primera visualización

Base vigente: **33404a5804be4fad85aab80dd923a7ae9e878ee9**. La decisión
10.97 corrige la atribución del desplazamiento de ventana: era del arnés,
no del producto. Windows debe medirse maximizado en la laptop a 1920×1080,
125 %. No se cambió la resolución ni la escala desde este instrumento.

Tras la pausa faltaban dependencias del banco TEMP. La corrida Windows
`primera/windows/con01` terminó por el límite automático de 600 s y se
excluye; `con02` mostró el fallo del SO por DLL ausente y también se excluye.
Son incidencias de preparación, no fallos medidos de BayStream. Se apartó
el Release incompleto y se reconstruyó la misma copia limpia (100.6 s).
**EXE vigente para primera visualización y tanda:** 15937536 bytes, SHA
`324b3c935ce92e61e5349b75dafd16d1bcdd44b98c3f32b6f9bef28c66a9366f`.
`windows-repuesto-manifiesto.json` identifica los 19 archivos del Release.
La recuperación Windows anterior conserva su EXE `8944a086…` declarado;
no se le atribuye retroactivamente el nuevo binario. Los 137 Dart de lib y
los dos pubspec siguen idénticos al archivo del cierre (139/139).

En Web se repusieron 13 recursos del SDK local, cotejando cada SHA con el
manifiesto anterior: los 49 archivos vuelven a coincidir. No cambió
`main.dart.js` (`1fd04bfb…`) ni se recompiló para esta reposición.
Registro: `web-reposicion-pausa.json`. Servidor reiniciado PID 17140,
solo `127.0.0.1:5898`; sustituye el PID anterior del informe.

**Web: seis videos válidos**, en `primera/web/`, navegador integrado visible
autorizado por Carlos, nunca Chrome para esta medición. MP4, JPEG fuente,
PTS y conteos cotejados por corrida (`video-verificado.json`). Se revisaron
la primera rejilla y su cuadro inmediatamente anterior. El cuadro cero
antecede al clic del icono del lanzador propio; se informa una cota superior,
no un instante de clic ficticio. El lanzador no modifica el producto.

| Perfil / repetición | Último sin / primero con rejilla | Cota superior desde antes del icono | Incertidumbre del final | Pasos |
|---|---|---|---|---|
| Con, 01 (informativa) | 34 / 35 | 7.428063 s | 0.810518 s | 4 |
| Sin, 01 | 69 / 70 | 5.468549 s | 0.731845 s | 6 |
| Sin, 02 | 66 / 67 | 5.472654 s | 0.691551 s | 6 |
| Sin, 03 | 67 / 68 | 5.407416 s | 0.707930 s | 6 |
| Sin, 04 | 66 / 67 | 5.577890 s | 0.733008 s | 6 |
| Sin, 05 | 61 / 62 | 5.291536 s | 0.694881 s | 6 |

Pasos sin perfil: **icono → Seleccionar archivo → selector del sistema →
No lo tengo → Confirmar y ver el plano → pestaña Plano**. Scroll no cuenta.
Con perfil se omiten No lo tengo y Confirmar: cuatro pasos informativos.
La confirmación todavía abre Lista; no se corrige para reducir el conteo.
Activar semántica con Enter es una acción del instrumento: excluida de los
pasos de producto, pero incluida íntegramente en el tiempo. El selector es
interceptado por el navegador, con su evento real registrado. Recursos
públicos en caché; cada repetición sin perfil elimina únicamente las bases
y el almacenamiento local del origen T98 desde el lanzador, cerrando antes
las conexiones de la app. No se limpia ningún otro origen.

**Web: tiempo cumple ≤30 s por cota conservadora; pasos no cumple (6>3)**
en las cinco repeticiones que rigen. El perfil conservado del Honor y sus
seis grabaciones de la mañana siguen vigentes por decisión 10.93, sin
presentarlas como repeticiones del cierre nuevo.

**Windows: exclusión adicional por tamaño.** `primera/windows/con03` y
`sin01..05` tienen video y rejilla revisada, pero la ventana era 1600×900
sin maximizar. Quedan como evidencia auxiliar, fuera de la serie normativa.
Sus intervalos incluyen pausas del agente entre observaciones y tampoco
resuelven el tiempo intrínseco del producto. Las seis aperturas maximizadas
se repiten en `primera/windows-max/`; mientras no estén verificadas, esa
serie queda **pendiente**, no aprobada por extrapolación.

### Tanda preparada con Carlos · orden obligatorio (a–f)

**Estado: preparada, todavía no ejecutada.** Nadie ha creado PRUEBA T-98,
no se inició pktmon, no se capturó una sesión y no se desconectó la laptop.
Esta lista no es evidencia de que las acciones hayan ocurrido.

**a. Crear PRUEBA T-98 desde la app.** Carlos usa exclusivamente los clientes
t98 y el archivo ficticio del banco nuevo:
`C:\Users\Giova\AppData\Local\Temp\t98-b-33404a5-20oct\sintetico-tanda\PRUEBA_T98.edi`.
492 bytes, SHA `2b8ba3998d288ac2eaae3ed4b6fc89160bcc305a17ef5955330499ac33562344`.
El generador lo validó con el parser del producto: **2 unidades, 36000 kg,
bahías 001 y 003**. IDs ficticios CSQU3054383 y TSTU0000987; no es corpus.
La operación compartida la crea Carlos mediante la app; ningún script
publica ni usa consola/CLI de Firebase. Si la creación solicita entrar,
Carlos resuelve ese acceso sin captura; el paso b completa las sesiones
de los demás clientes. No usar PRUEBA T-105 ni operaciones reales.

**b. Carlos inicia sesión en los clientes t98.** Sin grabación ni captura de
cuentas/contraseñas. Windows usa el EXE 324b3c93… y `store-windows` de TEMP;
Web usa el origen exclusivo 127.0.0.1:5898; Honor, paquete .t98. La condición
B, con sesión fuera de operación compartida, es informativa. Registrar el
estado de sesión mediante señales no identificadoras, nunca leer tokens ni
volcar almacenes de autenticación. La persistencia de sesión y su mecanismo
no se dan por comprobados solo por el nombre t98.

**c. Aprobar pktmon.** Carlos autoriza la captura elevada antes de que se
inicie. Se comprobó únicamente la ayuda local de los comandos disponibles.
Preparación concreta, sin ejecutar todavía: consultar `pktmon status` y
`pktmon filter list`; si hay otra captura/filtros ajenos, no detenerlos ni
borrarlos. En una ventana exclusiva, incorporar filtros propios
`t98_https` (TCP 443) y `t98_quic` (UDP 443), capturar NIC con paquetes
completos en `tanda/t98-tls.etl` y máximo 128 MB. Comando previsto:

```powershell
pktmon filter add t98_https -t TCP -p 443
pktmon filter add t98_quic -t UDP -p 443
pktmon start --capture --comp nics --pkt-size 0 --file-size 128 --file-name "$env:TEMP\t98-b-33404a5-20oct\tanda\t98-tls.etl"
# Solo al cerrar la captura propia confirmada:
pktmon stop
pktmon etl2pcap "$env:TEMP\t98-b-33404a5-20oct\tanda\t98-tls.etl" --out "$env:TEMP\t98-b-33404a5-20oct\tanda\t98-tls.pcapng"
```

El tráfico de NIC es global: se correlaciona con conexiones del proceso y
con el intervalo de acción; un paquete ajeno no prueba TLS de BayStream.
Los originales quedan privados en TEMP, sin incorporarlos a Git. No hay
tshark disponible en PATH; no se instala software. La decodificación y
atribución de ServerHello/QUIC, o su limitación, se documentan después de
capturar. Si no se puede demostrar la negociación del cliente, permanece
**no medible**. La sonda TLS de Python negocia por sí misma: no sustituye
la negociación efectiva de los SDK. TLS real se verifica antes de ejecutar
sincronización. No se afirma TLS 1.2+ por ver únicamente HTTPS/puerto 443.

**d. Carlos abre a mano chrome://net-export y el panel Security de Chrome.**
Modo predeterminado, sin incluir cookies, credenciales ni bytes crudos en
NetLog. No se automatiza Chrome. Conservar HAR y NetLog en TEMP privado;
el resumen se obtiene con `t98_sanitizar.py`. Comprobar con una solicitud
del worker la cobertura global: un HAR solo no basta. **La recuperación y
primera visualización Web se midieron en el navegador integrado**; una
negociación observada en Chrome identifica ese contexto y no se atribuye
al IAB por equivalencia. El panel debe corresponder al host remoto usado
por la sincronización, no al origen HTTP local.

**e. Disponibilidad sin red, Windows y Web.** Antes de apagar Wi-Fi:
abrir ambos clientes, precargar motor Web local, dejar este archivo y el
sintético accesibles; ocultar notificaciones y cerrar toda pantalla de
cuenta. Iniciar grabación y la sonda de red propia. Carlos apaga Wi-Fi,
realiza **las once operaciones siguientes en Windows y luego las mismas
once en la Web**, y vuelve a encenderlo. Codex no desconecta adaptadores.
No se depende del agente conectado durante el corte. El grabador corta a
600 s; si la tanda requiere más, se divide antes del corte, sin perder
operaciones ni reiniciar la red desde Codex. Confirmar éxito de cada acción,
no solo presencia del control. Si aparecen Parámetros por primera carga,
la operación 2 corresponde a ese diálogo; con perfil existente, abrirlo
expresamente y confirmar valores ya existentes.

| # | Operación exacta | Acción y evidencia a anotar en cada cliente |
|---|---|---|
| 1 | Cargar BAPLIE | Seleccionar el archivo PRUEBA_T98.edi local. No importar otro archivo. |
| 2 | Confirmar perfil | Usar No lo tengo si falta perfil y confirmar. Si hay perfil, abrir Parámetros y confirmar los valores existentes. No inventar dimensiones o umbrales del buque. |
| 3 | Ver Plano | Abrir la pestaña Plano y comprobar la rejilla del sintético. Hay una unidad en cada bahía. |
| 4 | Navegar bahías | Pasar de Bahía 01 (ISO 001) a Bahía 03 (ISO 003) y comprobar el cambio. |
| 5 | Lista y filtros | Abrir Lista, aplicar T98A (1) y comprobar una unidad; volver a Todas (2) y comprobar las dos. |
| 6 | Buscar | Buscar CSQU3054383 y comprobar el único resultado; limpiar la búsqueda. |
| 7 | Estadísticas | Abrir Estadísticas y comprobar 2 unidades / 36 t. |
| 8 | Alertas de estiba | Abrir Alertas y comprobar que termina la evaluación; ausencia de alertas no significa fallo. Límites sin especificación siguen PROVISIONALES/no evaluados. |
| 9 | Exportar | Exportar BAPLIE al banco TEMP (nombre distinto por cliente), confirmar la creación y conservar el archivo para cotejo. No publicar ni sincronizar. |
| 10 | Reabrir reciente | Volver al inicio y reabrir el sintético desde Recientes; comprobar 2 unidades. |
| 11 | Parámetros del buque | Abrir Parámetros y comprobar los controles; salir sin cambios adicionales. |

`tool/t98_tanda_red.ps1` observa, sin cambiar configuración: adaptadores
físicos activos, cantidad de rutas predeterminadas IPv4 y ping externo,
con UTC para correlacionar el video. Errores de consulta quedan inconclusos,
nunca se convierten en cero. Su prueba conectada dio **1 adaptador activo,
1 ruta y ping Success**; no es evidencia sin red. La aceptación sin red
requiere el corte visible por Carlos, sonda coherente y las 11 operaciones;
un ping fallido por sí solo no prueba desconexión. Tras reconectar, Codex
anota PTS, coteja exportaciones y completa 11 filas por cliente. Honor
**11/11 sin red se conserva** por 10.93; no se repite ni se extrapola a estos
clientes. La disponibilidad longitudinal 99.9 % sigue fuera de esta tanda.

**f. Cerrar las sesiones.** Carlos cierra las sesiones t98 sin grabar la
pantalla de cuenta. Detener únicamente capturas propias, verificar el cierre
y revisar que no haya datos identificadores antes de entregar resúmenes.
No se modifican la app real ni sus almacenes. Honor debe quedar avión 0,
Wi-Fi 1, letra 1.0 y puntero desactivado al terminar.

### Primera parada de la ventana de medición · 20-oct (histórico)

**T-98 sigue en curso.** Las seis primeras visualizaciones Windows
maximizadas no se dan por hechas. El control nativo no recuperó el
Explorador: activarlo devolvió `user input was detected in this window`;
consultar su estado devolvió `window is minimized`. Tras seleccionar de
nuevo la ventana, la recuperación volvió a fallar. Se solicitó a Carlos
restaurar y maximizar «inicio-t98-cierre2» manualmente; no se reemplazó el
control por otro mecanismo ni se simularon aperturas. No hay medición activa
y se anunció **SEMÁFORO: libre**. Al recuperarlo se anunciará otra ventana.

| RNF | Dictamen vigente y límite |
|---|---|
| 004 | **No medible**: se conserva A de los tres clientes; quedan TLS efectivo, atribución de tráfico/worker y sesión de la tanda. Los sondeos previos no prueban cero bytes. |
| 006 | **No medible en conjunto**: Honor sin red 11/11 conservado; recuperación nueva 8 casos por cliente registrada funcionalmente, con seis rechazos <3 s en Honor y Web. Windows no resuelve <3 s; disponibilidad sin red Windows/Web pendiente de Carlos. Los casos 03/04 admitidos no se convierten en rechazos. |
| 008 | **No cumple**: ZZZZZ no se detecta visiblemente y las disposiciones especiales IMDG siguen pendientes. Corpus conservado y batería nueva registrados; no se corrige el producto. |
| 002 | **No cumple** por seis pasos sin perfil frente a tres. Web cinco cotas ≤30 s; Honor cinco cotas ≤30 s conservadas. Windows maximizado completado en la reanudación siguiente; tiempo intrínseco no medible por pausas del agente. Idioma/Material 3/mensajes satisfacen los censos del cierre; SUS y piloto siguen pendientes, sin imputación. |

Validaciones de cierre de esta continuación: **10/10 autopruebas Python**,
AST de los seis Python modificados/nuevos correcto, `node --check` del
instrumento IAB correcto y sintaxis PowerShell de ambos helpers correcta.
La sonda de tanda se ejercitó conectada, sin cambiar la red. Las huellas
se volvieron a cotejar: **19/19 Windows, 49/49 Web, 139/139 archivos de
producto**. `binarios-vigentes.json` reúne los tres artefactos actuales,
sin reescribir el manifiesto histórico del primer build. La suite de la
copia limpia ya registrada permanece **1063/1063**, analyze **0**; no se
repite por cambios documentales o de instrumentación Python/PowerShell.
Honor comprobado nuevamente: avión **0**, Wi-Fi **1**, letra **1.0**, puntero
**null**. No se ejecutó Git de escritura ni publicación. **pubspec.yaml y
pubspec.lock no cambiaron.**

Archivos propios pendientes de versionar, incluida la continuación anterior:

- `docs/T98-RESULTADOS.md`
- `test/t98_auxiliares_test.py`
- `tool/t98_preparar.py`
- `tool/t98_recuperacion_honor.py`
- `tool/t98_cierre2.py`
- `tool/t98_grabar_escritorio.py`
- `tool/t98_iab_grabar.mjs`
- `tool/t98_iab_video.py`
- `tool/t98_primera_honor.py`
- `tool/t98_primera_windows.ps1`
- `tool/t98_sintetico.dart`
- `tool/t98_tanda_red.ps1`

Bloque para Carlos; registra avance, **no declara T-98 terminada**:

```powershell
git add -- docs/T98-RESULTADOS.md
git add -- test/t98_auxiliares_test.py
git add -- tool/t98_preparar.py
git add -- tool/t98_recuperacion_honor.py
git add -- tool/t98_cierre2.py
git add -- tool/t98_grabar_escritorio.py
git add -- tool/t98_iab_grabar.mjs
git add -- tool/t98_iab_video.py
git add -- tool/t98_primera_honor.py
git add -- tool/t98_primera_windows.ps1
git add -- tool/t98_sintetico.dart
git add -- tool/t98_tanda_red.ps1
git commit -m "Sprint 3: registra avance de mediciones T98 sobre cierre 2"
git push
```

Tres líneas:
- Evidencia del cierre 2 y censos incorporados; Web primera visualización completa.
- Seis aperturas Windows auxiliares excluidas y seis repeticiones maximizadas completadas y anotadas.
- Tanda a–f y once operaciones preparadas, sin desconectar la laptop ni abrir cuentas.

Mensaje para Yov:
> T-98 continúa sobre 33404a5. Suite 1063/1063, analyze 0; censos y batería 008 registrados. Recuperación funcional 8×3 grabada: seis rechazos Honor/Web resuelven <3 s; Windows queda temporalmente no medible. Primera visualización: Windows maximizado y Web completan cada uno 5 sin perfil +1 con perfil, con video y PTS; Honor de la mañana conservado. Sin perfil son seis pasos: RNF002 no cumple. Web/Honor resuelven ≤30 s por cota; Windows no resuelve tiempo intrínseco por pausas del agente. Control nativo recuperado después de la intervención de Carlos. Tanda a–f y once operaciones listas; sintético definitivo con navieras ficticias y filtro comprobado, cargado solo localmente en Windows. Cuentas, pktmon y corte de red aún no ejecutados. RNF004/006 no medibles en conjunto; RNF008 no cumple. Honor restaurado; no se declara T-98 terminada.

### Reanudación tras restaurar el Explorador · seis aperturas Windows maximizadas

Carlos confirmó «Ya está restaurada y maximizada» y se anunció
**SEMÁFORO: mido**. Se recuperó el control nativo y se maximizó el lanzador.
Una reapertura de la app durante la preparación se cerró por su PID propio,
**fuera de la serie**. Los seis videos de `primera/windows-max/` empiezan
antes del clic en el icono, sin avisos de entrada manual durante sus recorridos.
El acceso directo propio usa WindowStyle=3: la app arranca maximizada,
con icono Restaurar observado, sin una acción adicional de maximizar en la
medición. Pantalla física 1920×1080 y escala 125 % ya declarada.

La corrida con perfil conserva el perfil A01 de prueba. Antes de cada
sin01..05, `t98_primera_windows.ps1 -Corrida max-sinNN` cierra únicamente
el PID del EXE propio, verifica su salida y aparta `store-windows` bajo
`primera/almacenes/`. Los cinco JSON de preparación confirman ausencia de
almacén previo. No se toca LOCALAPPDATA/BayStream ni otra app/namespace.

| Corrida | Último sin / primero con rejilla | PTS de los dos cuadros | Incertidumbre solo del final | FPS promedio observado | Pasos |
|---|---|---|---|---|---|
| con01 (informativa) | 1735/1736 | 57.833818 / 57.881933 s | 0.048115 s | 29.999949 | 4 |
| sin01 | 2017/2018 | 67.234075 / 67.279956 s | 0.045881 s | 29.999889 | 6 |
| sin02 | 1724/1725 | 57.476000 / 57.506953 s | 0.030953 s | 29.998837 | 6 |
| sin03 | 1925/1926 | 64.168855 / 64.215933 s | 0.047078 s | 29.999943 | 6 |
| sin04 | 2053/2054 | 68.433917 / 68.480323 s | 0.046406 s | 29.999406 | 6 |
| sin05 | 2561/2562 | 85.368307 / 85.415906 s | 0.047599 s | 29.999429 | 6 |

Cuadros numerados desde cero. PTS originales del MP4; los seis videos
1920×1080 tienen PTS estrictamente crecientes, sin asumir 30 fps exactos.
Se revisaron los dos cuadros **contiguos** en cada transición: la rejilla
ya es visible durante la animación; no se espera a que termine para elegir
el hito. `revision.json`, `fin-NN.jpg`, `pares-rejilla.jpg`, `anotacion.json`
y `primera-anotada.json` conservan SHA de video, PTS y decisión humana.
Las seis capturas terminaron con código 0; no queda grabación activa.

El intervalo desde el cuadro cero anterior al icono incluye las pausas
entre observaciones del agente (57.5–85.4 s hasta la rejilla). **No medible
para decidir ≤30 s del producto**: no se restan esas pausas, no se convierte
el intervalo en latencia de BayStream y no se declara un fallo temporal
atribuible al producto. La incertidumbre de 31–48 ms de la tabla afecta
solo al final; no elimina ese sesgo. Sí queda firme el conteo del recorrido:
icono, Seleccionar archivo, selector del sistema, No lo tengo, Confirmar y
ver el plano, Plano: **6>3, no cumple**, en las cinco corridas sin perfil.
El scroll cuenta cero; con perfil son cuatro pasos informativos.

**Se completa la serie de 18 primeras visualizaciones requeridas**, con
las limitaciones temporales explícitas: seis Windows maximizadas nuevas,
seis Web nuevas en IAB y seis Honor conservadas por 10.93. Esto sustituye
el pendiente de aperturas Windows de la primera parada. No convierte en
cumplidos los indicadores de RNF002 ni cierra la tanda de RNF004/006.

**Preparación concreta de la tanda.** Tras terminar los videos se cargó
localmente el sintético y se observó que la versión inicial no traía NAD:
el filtro de naviera no aparecía. Se corrigió solo el generador del archivo
ficticio, añadiendo T98A y T98B, una unidad cada una, y UNT=21. Se conserva
el original sin filtros como preparación descartada; también se excluye
una generación que por error usó la copia anterior del instrumento. Ninguno
se usa para la tanda. El definitivo está en `sintetico-tanda/PRUEBA_T98.edi`,
492 bytes, SHA `2b8ba3998d288ac2eaae3ed4b6fc89160bcc305a17ef5955330499ac33562344`.
Parser del cierre: 2 unidades, 36000 kg, dos bahías, ISO válidos y dos
navieras ficticias. Generación ejecutada y analyze del instrumento en cero;
no se cambió lib ni se recompilaron binarios.

Windows queda abierto y maximizado en Lista con **BUQUE PRUEBA, viaje T98,
2 contenedores, 2 bahías y 36.0 t**. Se comprobó T98A → 1 resultado y se
restauró Todas → 2. Este recorrido fue preparación conectada, sin video:
**no cuenta como disponibilidad sin red**. Se reutilizó exclusivamente el
perfil sintético propio; no se creó operación compartida, no se inició
sesión ni se abrió Nube y cuenta. La lista a–f anterior ya apunta al archivo
definitivo y al filtro real. Carlos conserva la creación de PRUEBA T-98.

**Cierre de esta ventana:** se anunció **SEMÁFORO: libre** tras completar
las seis aperturas maximizadas, su anotación y la preparación local del
sintético. Comprobaciones finales: SHA y cierre correcto de los seis videos,
UNT=21 correcto en el archivo definitivo, generador analizado idéntico al
entregado y **139/139 archivos de producto sin diferencias**. Honor vuelve
a comprobar avión 0, Wi-Fi 1, letra 1.0 y puntero null. No quedan grabadores
activos; Windows se entrega abierto con el sintético para la tanda. El
bloque Git de doce rutas explícitas anterior sigue vigente y solo lo ejecuta
Carlos. pubspec.yaml/pubspec.lock permanecen sin cambios. **T-98 continúa
en curso** por TLS/sesiones, disponibilidad sin red Windows/Web y demás
limitaciones expresamente declaradas.
