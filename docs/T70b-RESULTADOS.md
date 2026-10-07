# T-70b · Resistencia de Firebase en Windows

Timonel · 6-oct-2026 (hora de Guatemala; 7-oct en UTC) · sobre `9ee72af` · fuera del repositorio, con el emulador local · criterios de la decisión 10.3 de `SPRINT-3.md`, sin cambios

## 1. Resultado

**T-70b no pasa: tres criterios de cuatro.** Falla la renovación del token. Pasan la sesión larga, el cierre con pendientes y la memoria.

| Criterio (10.3) | Pasa si | Resultado | Evidencia |
|---|---|---|---|
| Sesión larga | 60 min seguidos con el listener abierto en Windows; escrituras de Chrome cada 30 s; 0 documentos perdidos y la app no se cae | **PASA** | **60.5 min**, de 02:20:41 a 03:21:12 UTC. **120 escrituras de Chrome:** 120 en el emulador, 120 recibidas y confirmadas por Windows (`pending:false`, `cache:false`), 0 perdidas y 0 tardías (> 25 s). Latencia entre la orden y la recepción: mediana 209 ms, máximo 427 ms. 61 latidos de Windows, 0 errores del listener ni de escritura, la app siguió respondiendo. `evidence/t70b-hora.json` |
| Renovación del token | 50 renovaciones forzadas en Windows sin caída ni error que corte la sesión | **NO PASA** | **50 de 50 fallaron** con `[firebase_auth/unknown-error] An internal error has occurred.` La app no se cayó, pero la escritura de Windows posterior **quedó pendiente sin confirmación** y, al reabrir la app, Windows no reconectó con el servidor. Sección 3 |
| Cierre con pendientes | Una escritura sin red, con la app cerrada a la fuerza, llega al reabrir y reconectar | **PASA**, por la **persistencia del SDK** | `cierre-1791339562316`: pendiente en local y ausente del emulador. Cierre con `taskkill /F`, que la deja igual de ausente. **Al reabrir**, la sesión se restauró (mismo UID), el documento salió de la caché en disco como pendiente y **a los 2 s estaba en el emulador** y confirmado en Windows. No hizo falta la cola en Hive. `evidence/t70b-cierre-a.json`, `t70b-cierre-b.json` |
| Memoria | No crece sin límite; se informa al inicio, a los 30 y a los 60 min | **PASA**, con la reserva de 4 | Memoria residente / privada: **inicio 90.3 / 108.3 MB · 30 min 97.1 / 115.6 MB · 60 min 101.1 / 118.1 MB**. Entre los minutos 30 y 50, plana. Identificadores (≈ 1 433) e hilos (≈ 142) planos hasta el vencimiento del token. `evidence/t70b-memoria.csv` |

**Lo que se usó:**
- Copia de la espiga en `C:\Proyectos\espiga-sync-windows\`. La original no se tocó.
- Proyecto `demo-baystream-t70b`, con puertos propios (Auth 9199, Firestore 8180).
- Versiones de T-70: `firebase_core` 4.13.0, `firebase_auth` 6.5.7, `cloud_firestore` 6.8.0, Flutter 3.38.9, Firebase CLI 15.32.1 y emulador de Firestore 1.22.0.
- Windows 11, 10.0.26300, **en compilación de lanzamiento**. T-70 usó la de depuración.
- Escritor: Chrome 154 en un perfil aparte, con el frenado de temporizadores en segundo plano desactivado, para que las escrituras cada 30 s no dependieran de que la ventana estuviera al frente.

**Persistencia:** la copia activa la del SDK (`persistenceEnabled: true`). T-70 la había desactivado para medir la cola en memoria.

## 2. Cronología

| Hora (UTC) | Hecho |
|---|---|
| ≈ 02:19:20 | Windows inicia sesión en el emulador. El token de Firebase dura una hora |
| 02:19:25 | `cierre-a`: escritura sin red, pendiente en local, ausente del emulador |
| 02:19:35 | Cierre forzado. Reapertura: la sesión se restaura y la escritura llega |
| 02:20:40 | Único `too_many_pings` de gRPC (sección 5) |
| 02:20:41 | **SEMÁFORO: inicio de la hora.** Memoria a 90.3 MB |
| 02:50:41 | 60 de 120, ninguna perdida. Memoria a 97.1 MB |
| ≈ 03:19 | Vence el token. **En toda la hora no hubo ninguna renovación automática** (el contador de `idTokenChanges` se quedó en 2) |
| 03:20:41 | 120 de 120. Memoria a 101.1 MB |
| 03:21:12 | **SEMÁFORO: fin de la hora** |
| 03:21:27–31 | 50 renovaciones forzadas: 50 fallos. Chrome escribe y Windows lo recibe por el listener ya abierto. Windows escribe y su escritura queda pendiente |
| 03:22:42 | Control: Chrome renueva 3 de 3 contra el mismo emulador; Windows falla 3 de 3 |
| 03:24 | Cierre y reapertura de Windows: la escritura sigue pendiente y todo lo que se ve sale de la caché (`cache:true`) |
| 03:25:04 | Diagnóstico `relogin` (cerrar sesión y entrar de nuevo): **la escritura atascada llega al emulador** |

## 3. La renovación del token

### 3.1 Qué pasó

- **Las 50 renovaciones forzadas** (`User.getIdToken(true)`) devolvieron el mismo error, en unos 4 segundos entre todas:

```text
[firebase_auth/unknown-error] An internal error has occurred.
```

- **La renovación automática tampoco ocurrió.** En toda la hora el SDK no emitió ningún cambio de token, aunque el token vencía a los 60 minutos. **No hubo aviso en la app:** ni error del listener ni de `idTokenChanges`.
- **Consecuencias, una vez vencido el token:**
  - **El listener ya abierto siguió entregando** lo que escribía Chrome.
  - **Una escritura nueva de Windows quedó pendiente.** Desde las 03:21:32 hasta que se rehízo la sesión, no llegó al servidor.
  - **Al reabrir la app, Windows no reconectó**: todo lo que mostraba venía de la caché local.
- **Al rehacer la sesión** (`signOut` y `signInWithEmailAndPassword`, que sí van al emulador), la escritura atascada llegó al instante. **No se perdió nada:** quedó en la caché en disco hasta que hubo un token válido.
- El `signOut` canceló el listener, como corresponde cuando la sesión se cierra y las reglas exigen sesión:

```text
[cloud_firestore/permission-denied]
false for 'list' @ L6
```

### 3.2 La causa más probable

**Mientras Windows intentaba renovar, abrió una conexión a `172.217.115.4:443`**, que es una de las direcciones de `securetoken.googleapis.com`, el servicio de Google que renueva tokens. Lo comprobé con la resolución de nombres de la máquina. **No fue al emulador de Auth (`127.0.0.1:9199`).**

**Con el mismo emulador, Chrome renovó 3 de 3** en 2–4 ms. Es decir: el SDK de C++ que usa la app de Windows envía al emulador el inicio de sesión, pero **la renovación del token la manda al servicio real de Google**. Allí el token de un proyecto `demo-` no vale y la respuesta es el «internal error».

**Lo que esto permite afirmar y lo que no:**
- **Que no pasa en el entorno de prueba acordado.** Con el emulador, Windows no puede renovar el token ni sostener una sesión de más de una hora.
- **No permite afirmar que en producción ocurra lo mismo.** Allí `securetoken.googleapis.com` es el destino correcto, y es posible que la renovación funcione. Pero no se probó: hacerlo exige un proyecto real, y T-70b se hizo solo con el emulador.
- **No encontré un aviso oficial de este comportamiento.** La explicación es la observación de arriba, no una cita.

**Transparencia:** esas renovaciones salieron de la máquina hacia un servicio real de Google, con el token sintético del proyecto `demo-baystream-t70b`, que no existe en la nube. No se usó ni se tocó ningún proyecto de Carlos. Fueron 53 peticiones (50 + 3) y no las repetí.

## 4. Memoria

Muestras cada minuto, del proceso de la app de Windows:

| Minuto | Residente (MB) | Privada (MB) | Identificadores | Hilos | CPU acumulada (s) |
|---:|---:|---:|---:|---:|---:|
| 0 | 90.3 | 108.3 | 1 437 | 143 | 0.5 |
| 10 | 91.2 | 111.2 | 1 434 | 144 | 3.8 |
| 20 | 96.3 | 115.2 | 1 433 | 141 | 7.1 |
| **30** | **97.1** | **115.6** | 1 433 | 141 | 10.5 |
| 40 | 98.5 | 116.9 | 1 433 | 141 | 13.6 |
| 50 | 97.0 | 116.5 | 1 434 | 142 | 16.8 |
| 59 | 99.6 | 117.7 | 1 484 | 144 | 20.0 |
| **60** | **101.1** | **118.1** | 1 480 | 142 | 20.5 |
| 63 | 102.8 | 119.5 | 1 490 | 142 | 21.8 |

- **La pendiente media de la hora es 0.16 MB/min.** No es una recta: sube 6.8 MB en la primera media hora, queda plana entre los minutos 30 y 50, y vuelve a subir desde el minuto 59.
- **El último tramo coincide con el vencimiento del token** (≈ 03:19). En ese minuto los identificadores saltan de 1 434 a 1 484: son las conexiones de los intentos de renovación de la sección 3.
- **Reserva:** una hora no prueba que la memoria se estabilice. Si la pendiente media siguiera igual durante un turno de 8 h, serían unos +77 MB, hasta ≈ 180 MB. Es una extrapolación, no una medida.

## 5. Mensajes nativos

La salida estándar y la de error de cada arranque de Windows se guardaron en `evidence/win-*.txt`.

- **Errores de hilo de `firebase_auth` de T-70** («sent a message from native to Flutter on a non-platform thread»): **0** en los cuatro arranques. Hubo inicio de sesión, sesión restaurada y `signOut` más `signIn`. Esta es la compilación de lanzamiento; T-70 los vio en la de depuración, que aquí no se repitió.
- **`too_many_pings`:** un solo episodio en toda la prueba, a los 60 s del arranque que después corrió la hora. Mensaje exacto:

```text
I0000 00:00:1791339640.720953   28248 chttp2_transport.cc:1204] ipv4:127.0.0.1:8180: Got goaway [11] err=UNAVAILABLE:GOAWAY received; Error code: 11; Debug Text: too_many_pings {created_time:"2026-10-07T02:20:40.7207368+00:00", http2_error:11, grpc_status:14}
E0000 00:00:1791339640.730454   28248 chttp2_transport.cc:1232] ipv4:127.0.0.1:8180: Received a GOAWAY with error code ENHANCE_YOUR_CALM and debug data equal to "too_many_pings". Current keepalive time (before throttling): 30000ms
```

  No costó ningún documento: después vinieron las 120 escrituras sin pérdidas.

## 6. Recomendación

1. **Para T-79, aplicar el respaldo de 10.3.** La oficina en Windows usa la Web instalada desde Chrome o Edge como aplicación, con ventana e ícono propios. La app nativa de Windows conserva el adaptador sin sincronización de T-79a para el modo de un solo dispositivo. Para T-79 no cambia nada más: la Web ya estaba en el diseño.
2. **Lo que T-70b sí demostró de Windows sirve igual:**
   - La persistencia del SDK sobrevive a un cierre forzado.
   - Un listener de una hora no pierde nada.
   - La memoria se mantiene moderada.
   - **Nada se perdió ni siquiera con el token vencido:** la cola esperó hasta que hubo un token válido. Eso confirma el diseño de T-79a: primero lo local, después la nube.
3. **Si Carlos quiere reabrir la puerta a Windows nativo,** la pregunta que queda es una sola: ¿renueva el token contra el servicio real? Solo se contesta con un proyecto real.
   - **Cómo:** una cuenta de prueba en `baystream-app` (cuando exista Auth, paso 6 de T-79a) o en un proyecto gratuito aparte. Se repite la fase `token` y una sesión de 75 minutos que cruce el vencimiento.
   - **Coste:** ≈ 0.5 h de trabajo y 75 min de espera.
   - **No lo hice:** T-70b prohíbe la nube. Es decisión de Carlos.
   - **Aunque pasara, queda un costo:** el emulador no puede probar sesiones de Windows de más de una hora, así que cada prueba larga de T-79 en Windows necesitaría la nube.
4. **Un riesgo que vale para cualquier cliente:** cuando el token no se renueva, el SDK no avisa a la app. T-79 no debe fiarse solo de los errores del SDK: si un movimiento lleva pendiente más de unos minutos con red disponible, la pantalla debe decirlo («sin confirmar desde las 10:42») y ofrecer volver a iniciar sesión. Lo agrego al apéndice de T-79a.

## 7. Evidencia y reproducción

Todo está en `C:\Proyectos\espiga-sync-windows\`, fuera del repositorio:

| Archivo | Contenido |
|---|---|
| `README.md` | Cómo repetir las cuatro fases |
| `lib/main.dart`, `t70b.mjs`, `memoria.ps1` | App con renovación forzada, latido y `relogin`; orquestador; muestreo de memoria |
| `evidence/t70b-cierre-a.json`, `t70b-cierre-b.json` | Cierre con pendientes |
| `evidence/t70b-hora.json`, `t70b-hora.log` | La hora: 120/120, latencias, latidos y errores |
| `evidence/t70b-memoria.csv` | 63 muestras de memoria |
| `evidence/t70b-eventos.json`, `events.jsonl` | Todos los eventos de los dos clientes |
| `evidence/t70b-documentos-emulador.txt` | Los 124 documentos finales del emulador (120 de la hora, el del cierre, dos del token y uno tras `relogin`) |
| `evidence/win-*.txt` | Salida nativa de cada arranque de Windows |
| `evidence/windows-build.txt`, `windows-rebuild.txt`, `web-build.txt` | Compilaciones |

**Limpieza.**
- Cerré la app de prueba, mi Chrome con perfil aparte, el emulador, el controlador y el servidor web. Los siete puertos de la prueba quedaron libres.
- Desde ayer a las 5:19 p. m. sigue abierto un `espiga_sync.exe` de **depuración de la espiga original** (`C:\Proyectos\espiga-sync\build\…\Debug`). No es mío y no lo toqué; apunta a puertos de T-70 que ya no escuchan.

**El repositorio solo cambia en dos documentos:** este informe y el apéndice de `docs/T79a-DISENO.md`.
- No se tocaron `lib/`, `test/`, `pubspec.*` ni `firestore.rules`.
- Los comandos de Flutter (`pub get`, `analyze`, `build windows` dos veces y `build web`) corrieron en la copia, uno a la vez, y ninguno durante la hora.
