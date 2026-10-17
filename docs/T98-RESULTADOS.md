# T-98 · Instrumentos RNF-004, 006, 008 y 002

Capitán Codex · 17-oct-2026 · Fase A · base `9ae744a` de `sprint-3`.

## Fase A

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
