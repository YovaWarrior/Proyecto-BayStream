# T-70c · Renovación de Firebase Auth en Windows contra producción

**Responsable:** Capitán Codex. **Fecha:** 7-oct-2026.
**Estado:** terminada; ambos criterios **PASA**, lista para el commit de Carlos.

## 1. Criterios fijados antes de ejecutar

La decisión 10.5 de `SPRINT-3.md` y la instrucción directa de Carlos fijaron:

| Criterio | Exigencia | Resultado |
|---|---|---|
| Renovación forzada | 50 de 50 renovaciones sin error | **PASA: 50/50**, cero errores |
| Renovación automática | 75 minutos de sesión, cruzando el vencimiento con renovación automática y sin error | **PASA: 75 min 2 s**, una renovación automática, cero errores |

No se cambian los criterios después de observar los resultados. T-70c no prueba
Firestore, sincronización de movimientos ni las otras propiedades de T-70b.

## 2. Entorno y alcance

- Copia nueva de la espiga en `C:\Proyectos\espiga-sync-prod\`, fuera del repositorio.
- Windows release; `firebase_core` **4.13.0** y `firebase_auth` **6.5.7**, las versiones de T-70/T-70b.
- El proyecto permitido es **baystream-app**. La espiga no contiene Firestore ni usa emuladores.
- Las opciones entraron exclusivamente mediante `--dart-define-from-file=C:\Proyectos\baystream-privado\firebase-prod.json`. El agente no abrió el archivo ni imprimió valores.
- Carlos introdujo personalmente correo y contraseña en la ventana. No se consultaron capturas ni campos de credenciales. Los controladores se vacían tras el acceso; los registros no contienen correo, UID, contraseña, tokens ni opciones privadas.
- App Firebase propia `T70c-prod`, sin reutilizar una sesión anterior. Ejecutable `espiga_sync_prod.exe`; proceso de la medición **33968**.
- El proyecto H5 no se usa. No se crean cuentas, bases de datos, reglas ni publicaciones.

La compilación se ejecutó con el semáforo expreso de Carlos. Al terminar se
avisó **SEMÁFORO: libre**, y Flutter quedó disponible para Timonel/T-73.
La observación posterior de Auth no ejecuta comandos de Flutter. Carlos confirmó
que la laptop no se suspendería durante los 75 minutos.

**Incidencia de coordinación previa:** Codex interpretó erróneamente un «ok»
como autorización y ejecutó `flutter pub get --offline` y `flutter analyze
--no-pub` en la espiga. Carlos lo corrigió; ambos comandos ya habían terminado
al detenerse. La compilación, la apertura de la app y la medición comenzaron
después de la autorización explícita y la ruta privada proporcionadas por Carlos.

## 3. Método y evidencia

Se ejecutaron primero 50 llamadas consecutivas a `getIdTokenResult(true)`, con
dos segundos entre ellas. Cada respuesta debía incluir un token no vacío,
pertenecer a baystream-app, avanzar la emisión y conservar un vencimiento futuro.
Se registran hora de petición y respuesta, emisión, vencimiento y latencia.

Después de drenar las notificaciones de esa fase, comienza una observación de
75 minutos con reloj monótono y latidos cada 30 segundos. No se sondea
`getIdToken` ni se llama a `getIdTokenResult(true)` durante esa fase. Se escucha
`idTokenChanges()`: la llegada del evento nativo se registra antes de leer una
vez `getIdTokenResult(false)` para obtener los metadatos del token notificado.
Al final tampoco se solicita un token, para no confundir renovación automática
con renovación bajo demanda. El criterio requiere una nueva emisión observada,
cruzar el vencimiento de partida, sesión activa, token vigente y cero errores.

El plugin Windows de firebase_auth 6.5.7 devuelve el JWT, pero no rellena los
campos de emisión y vencimiento de `IdTokenResult` (implementación local de
`FirebaseAuthPlugin::GetIdToken`). La espiga extrae únicamente `iat` y `exp` en
memoria y comprueba `aud`/`iss`; no guarda ni imprime el JWT. Es instrumentación
local, no una verificación de firma en servidor. La API de escucha y renovación
está descrita en la [documentación oficial de Firebase Auth para Flutter](https://firebase.google.com/docs/auth/flutter/start).

Las horas de las tablas son **America/Guatemala, UTC−06:00**, del 7-oct-2026.
El registro original conserva UTC y hora de Guatemala; las fechas de emisión y
vencimiento tienen precisión de segundos. Se conserva la diferencia observada
entre el reloj local de respuesta y las fechas emitidas por el servicio.

Evidencia original, fuera del repositorio:

- `C:\Proyectos\espiga-sync-prod\evidence\session-1791398535223.jsonl`.
- `evidence\analyze.txt`: **No issues found!**.
- `evidence\windows-build.txt`: Windows release correcto, **99.1 s**.
- `evidence\native-stdout.txt` y `evidence\native-stderr.txt`: capturas nativas de la ejecución.
- Código y protocolo de la espiga: `lib\main.dart` y `README.md` en su carpeta externa.

## 4. Renovaciones forzadas

**PASA: 50 respuestas correctas de 50 solicitudes; cero errores.** La primera
respuesta se recibió a las **12:43:28.505**, la última a las **12:45:12.586**.
La fase terminó a las **12:45:14.595**. Cada emisión avanzó respecto de la anterior.

Latencias orientativas: mínimo **85 ms**, mediana **108 ms**, máximo **267 ms**.
No son una medición de H5 ni un umbral de aceptación de rendimiento.
El reloj monótono incluye la instrumentación local de inicio de cada petición;
estos intervalos no representan exclusivamente el transporte de red.

| N.º | Petición | Respuesta | Emisión | Vencimiento | Latencia ms |
|---:|---|---|---|---|---:|
| 1 | 12:43:28.237 | 12:43:28.505 | 12:43:27.000 | 13:43:27.000 | 267 |
| 2 | 12:43:30.515 | 12:43:30.602 | 12:43:29.000 | 13:43:29.000 | 88 |
| 3 | 12:43:32.620 | 12:43:32.711 | 12:43:31.000 | 13:43:31.000 | 91 |
| 4 | 12:43:34.721 | 12:43:34.811 | 12:43:33.000 | 13:43:33.000 | 105 |
| 5 | 12:43:36.839 | 12:43:36.960 | 12:43:35.000 | 13:43:35.000 | 120 |
| 6 | 12:43:38.970 | 12:43:39.059 | 12:43:37.000 | 13:43:37.000 | 94 |
| 7 | 12:43:41.087 | 12:43:41.214 | 12:43:39.000 | 13:43:39.000 | 132 |
| 8 | 12:43:43.228 | 12:43:43.325 | 12:43:42.000 | 13:43:42.000 | 102 |
| 9 | 12:43:45.349 | 12:43:45.439 | 12:43:44.000 | 13:43:44.000 | 91 |
| 10 | 12:43:47.448 | 12:43:47.584 | 12:43:46.000 | 13:43:46.000 | 140 |
| 11 | 12:43:49.610 | 12:43:49.690 | 12:43:48.000 | 13:43:48.000 | 90 |
| 12 | 12:43:51.723 | 12:43:51.836 | 12:43:50.000 | 13:43:50.000 | 112 |
| 13 | 12:43:53.858 | 12:43:53.964 | 12:43:52.000 | 13:43:52.000 | 107 |
| 14 | 12:43:55.983 | 12:43:56.094 | 12:43:54.000 | 13:43:54.000 | 114 |
| 15 | 12:43:58.110 | 12:43:58.206 | 12:43:56.000 | 13:43:56.000 | 104 |
| 16 | 12:44:00.224 | 12:44:00.320 | 12:43:59.000 | 13:43:59.000 | 95 |
| 17 | 12:44:02.330 | 12:44:02.438 | 12:44:01.000 | 13:44:01.000 | 108 |
| 18 | 12:44:04.453 | 12:44:04.581 | 12:44:03.000 | 13:44:03.000 | 133 |
| 19 | 12:44:06.608 | 12:44:06.720 | 12:44:05.000 | 13:44:05.000 | 115 |
| 20 | 12:44:08.743 | 12:44:08.861 | 12:44:07.000 | 13:44:07.000 | 123 |
| 21 | 12:44:10.888 | 12:44:11.021 | 12:44:09.000 | 13:44:09.000 | 132 |
| 22 | 12:44:13.037 | 12:44:13.133 | 12:44:11.000 | 13:44:11.000 | 108 |
| 23 | 12:44:15.162 | 12:44:15.263 | 12:44:13.000 | 13:44:13.000 | 110 |
| 24 | 12:44:17.284 | 12:44:17.396 | 12:44:16.000 | 13:44:16.000 | 116 |
| 25 | 12:44:19.415 | 12:44:19.522 | 12:44:18.000 | 13:44:18.000 | 115 |
| 26 | 12:44:21.550 | 12:44:21.648 | 12:44:20.000 | 13:44:20.000 | 108 |
| 27 | 12:44:23.671 | 12:44:23.799 | 12:44:22.000 | 13:44:22.000 | 139 |
| 28 | 12:44:25.822 | 12:44:25.900 | 12:44:24.000 | 13:44:24.000 | 85 |
| 29 | 12:44:27.929 | 12:44:28.041 | 12:44:26.000 | 13:44:26.000 | 112 |
| 30 | 12:44:30.054 | 12:44:30.150 | 12:44:28.000 | 13:44:28.000 | 96 |
| 31 | 12:44:32.161 | 12:44:32.259 | 12:44:30.000 | 13:44:30.000 | 100 |
| 32 | 12:44:34.277 | 12:44:34.374 | 12:44:33.000 | 13:44:33.000 | 100 |
| 33 | 12:44:36.399 | 12:44:36.498 | 12:44:35.000 | 13:44:35.000 | 110 |
| 34 | 12:44:38.521 | 12:44:38.646 | 12:44:37.000 | 13:44:37.000 | 125 |
| 35 | 12:44:40.669 | 12:44:40.771 | 12:44:39.000 | 13:44:39.000 | 111 |
| 36 | 12:44:42.796 | 12:44:42.891 | 12:44:41.000 | 13:44:41.000 | 96 |
| 37 | 12:44:44.910 | 12:44:45.017 | 12:44:43.000 | 13:44:43.000 | 110 |
| 38 | 12:44:47.043 | 12:44:47.168 | 12:44:45.000 | 13:44:45.000 | 127 |
| 39 | 12:44:49.190 | 12:44:49.285 | 12:44:48.000 | 13:44:48.000 | 101 |
| 40 | 12:44:51.300 | 12:44:51.398 | 12:44:50.000 | 13:44:50.000 | 107 |
| 41 | 12:44:53.428 | 12:44:53.531 | 12:44:52.000 | 13:44:52.000 | 116 |
| 42 | 12:44:55.561 | 12:44:55.700 | 12:44:54.000 | 13:44:54.000 | 151 |
| 43 | 12:44:57.732 | 12:44:57.842 | 12:44:56.000 | 13:44:56.000 | 112 |
| 44 | 12:44:59.860 | 12:44:59.953 | 12:44:58.000 | 13:44:58.000 | 93 |
| 45 | 12:45:01.968 | 12:45:02.064 | 12:45:00.000 | 13:45:00.000 | 96 |
| 46 | 12:45:04.075 | 12:45:04.154 | 12:45:02.000 | 13:45:02.000 | 88 |
| 47 | 12:45:06.175 | 12:45:06.264 | 12:45:04.000 | 13:45:04.000 | 88 |
| 48 | 12:45:08.281 | 12:45:08.360 | 12:45:07.000 | 13:45:07.000 | 93 |
| 49 | 12:45:10.386 | 12:45:10.473 | 12:45:09.000 | 13:45:09.000 | 87 |
| 50 | 12:45:12.482 | 12:45:12.586 | 12:45:11.000 | 13:45:11.000 | 103 |

## 5. Sesión de 75 minutos

- Inicio: **12:45:17.604**.
- Emisión de partida: **12:45:11**.
- Vencimiento de partida: **13:45:11**.
- Final previsto: aproximadamente **14:00:17.604**.
- Final observado: **14:00:19.778**.
- Duración monótona: **4502 segundos**, equivalentes a **75 min 2 s**.

**PASA.** Se observó una renovación automática, sin forzar ni sondear el token.
La nueva emisión ocurrió dos minutos antes del vencimiento inicial. La sesión
cruzó ese vencimiento y terminó activa, con token vigente y **cero errores**.

| Renovación automática | Llegada del evento nativo | Registro de renovación | Emisión nueva | Vencimiento nuevo | Tiempo de sesión |
|---:|---|---|---|---|---|
| 1 | 13:43:12.791 | 13:43:12.807 | 13:43:11 | 14:43:11 | 3475 s (57 min 55 s) |

El registro contiene **150 latidos** de continuidad: ninguno con el usuario
ausente, y los intervalos entre latidos van de **30.002748 a 30.049794 s**.
El mismo proceso permaneció abierto durante la medición. El resultado final
registra `crossed_initial_expiry: true`, `signed_in: true`,
`latest_token_unexpired: true`, `automatic_renewals: 1` y `session_errors: 0`.
Después de guardar ese resultado se cerró normalmente solo la espiga T-70c.

## 6. Errores y límites

**No hubo mensajes de error que transcribir.** El registro contiene **cero**
eventos `error`, tanto en las 50 renovaciones forzadas como en la fase larga.
Al cerrar normalmente la espiga se volcó la salida nativa que estaba en buffer:
`native-stdout.txt` terminó con **1802 bytes**, exclusivamente **53 líneas** del
mensaje informativo exacto `INFO: USE_AUTH_EMULATOR not set.`. No son errores;
indican que no se estableció el emulador de Auth. `native-stderr.txt` terminó
con **0 bytes**. No se observó un fallo del producto ni de la instrumentación
durante esta ejecución.

La entrega declara únicamente lo medido contra Auth real. No equivale a probar
Firestore en producción ni a revocar la advertencia oficial de Firebase sobre
Windows. La salvaguarda de T-79 para movimientos pendientes más de cinco minutos
sigue siendo la decisión 10.5 y su umbral sigue **PROVISIONAL**.

## 7. Rutas y entrega

La única ruta que se versiona en BayStream es **docs/T70c-RESULTADOS.md**.
No cambian `lib/`, `test/`, `pubspec.yaml` ni `pubspec.lock` del repositorio.
Los cambios de la espiga y su evidencia permanecen fuera del repositorio.
Carlos ejecuta Git; no se ejecutaron operaciones de escritura de Git.

## 8. Recomendación para T-79

Con **PASA en los dos criterios**, se cumple la condición fijada en 10.5 para
construir Windows con el adaptador previsto en T-79. Se conserva la cola local
durable del diseño de T-79a y la salvaguarda en los tres clientes: tras más de
**5 minutos pendientes con red disponible** (umbral **PROVISIONAL**), mostrar
«sin confirmar desde las HH:MM» y ofrecer volver a iniciar sesión. No basta
con esperar un error del SDK.

El fallo de renovación forzada contra el emulador de T-70b no se reprodujo
contra Auth real en T-70c. Esto no demuestra por sí solo su causa. Las pruebas
largas de Windows de T-79 quedan contra la nube, según 10.5; aquí no se probó
Firestore ni se modificó ninguna configuración de consola.

## 9. Resumen y mensaje para Yov

1. Se preparó una espiga externa dedicada solo a Auth de baystream-app, con opciones privadas por archivo y credenciales introducidas por Carlos.
2. PASA 50/50 renovaciones forzadas y PASA una sesión de 75 min 2 s con renovación automática, vencimiento cruzado y cero errores.
3. Se entrega únicamente este informe en el repositorio; Flutter quedó libre para Timonel y se cerró la espiga al completar la medición.

**Mensaje para Yov, listo para copiar:**

> Yov: T-70c terminada por Capitán Codex, con PASA en ambos criterios de 10.5 contra Auth real de baystream-app en Windows release. Las 50 renovaciones forzadas fueron correctas, con cero errores. La sesión duró 75 min 2 s: inicio 12:45:17.604, vencimiento de partida 13:45:11, evento automático 13:43:12.791 con nueva emisión 13:43:11 y vencimiento 14:43:11; terminó a las 14:00:19.778 activa y con token vigente. Hubo 150 latidos, cero errores y ninguna llamada forzada en la fase larga. Horas de Guatemala del 7-oct; las 50 renovaciones y la automática están detalladas en docs/T70c-RESULTADOS.md. Se cumple la condición para Windows en T-79, conservando la cola durable y la salvaguarda provisional de 5 min con opción de iniciar sesión otra vez. La espiga está fuera del repositorio; no se tocó Firestore ni H5, y Carlos escribio la contraseña. El único archivo del commit es el informe, sin cambios en lib, test o pubspec del repo. Commit propuesto: «Sprint 3: T-70c renovacion de sesion Windows validada contra Auth real». Flutter se liberó para Timonel y la espiga ya está cerrada.

Al terminar T-70c no se inicia otra tarea: Carlos coordinará la aceptación
cruzada de T-72/T-73 y luego T-74.


