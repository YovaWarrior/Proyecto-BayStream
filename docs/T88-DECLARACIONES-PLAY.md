# T-88 · Declaraciones de Play, con la app de hoy

Yov · 15-oct-2026 · Solo documentos. Reemplaza las respuestas de `docs/T64-DECLARACIONES-PLAY.md` (Sprint 2), que se escribieron antes de las cuentas, la sincronización y la voz.

**Fuentes:**
- el inventario del APK release de `docs/T88-RESULTADOS.md` (sección 5), de Timonel;
- la política de privacidad de T-88 (`lib/core/constants/privacy_policy.dart`), corregida en 10.46 y 10.47;
- la consola de Firebase, revisada por Carlos el 15-oct sin cambiar nada:
  - **App Check:** ninguna app registrada, ni la de Android ni la Web;
  - **Authentication → Configuración → Fraud Defense** (antes reCAPTCHA Enterprise): pide «configurar reCAPTCHA para crear claves de sitio» primero, así que **no hay claves ni protección activa**;
- las páginas oficiales que citan T-64 y T-88:
  - [Firebase: divulgación de datos de Google Play](https://firebase.google.com/docs/android/play-data-disclosure);
  - [Play: sección de Seguridad de los datos](https://support.google.com/googleplay/android-developer/answer/10787469).

**Cuándo hace falta.**
- **La prueba interna** (18 al 21-oct) **no exige** el formulario de Seguridad de los datos (T-64, 2.6).
- **La prueba cerrada y producción sí.** Este documento es para ese momento.
- Si la app cambia antes, se revisa.

## 1. Política de privacidad

| | |
|---|---|
| Dirección para Play | `https://baystream-app.web.app/privacidad.html`, cuando Carlos publique la Web (T-92) |
| Dentro de la app | Parámetros → «Política de privacidad», y en Nube y cuenta, en el formulario de inicio de sesión |
| Contacto | el correo de D2, el mismo de la ficha de la tienda |

## 2. Seguridad de los datos

**¿La app recopila o comparte alguno de los tipos de datos requeridos?** **Sí, recopila. No comparte.**
- Lo que va a Firebase (Google) es un proveedor de servicios que procesa los datos por cuenta de BayStream. Según la página de Play, eso no cuenta como «compartir».
- **Todo es opcional:** la app funciona completa sin cuenta, y entonces no sale nada del dispositivo (la política, «Sin cuenta»).

### 2.1 Lo que se declara

| Categoría de Play | Tipo | ¿Recopila? | ¿Opcional? | Finalidad | Qué es en BayStream |
|---|---|---|---|---|---|
| Información personal | **Dirección de correo electrónico** | Sí | Sí | Funcionalidad de la app; administración de la cuenta | El correo con que se inicia sesión en Firebase Authentication |
| Información personal | **Nombre** | Sí | Sí | Funcionalidad de la app | El nombre que firma cada movimiento sincronizado (`author.name`) |
| Información personal | **ID de usuario** | Sí | Sí | Funcionalidad de la app; administración de la cuenta | El UID de la cuenta, en cada movimiento y en la operación (`createdBy`, `closedBy`) |
| Archivos y documentos | **Archivos y documentos** | Sí | Sí | Funcionalidad de la app | Los BAPLIE y el listado de Excel de una operación publicada |
| Actividad en la app | **Otro contenido generado por el usuario** | Sí | Sí | Funcionalidad de la app | Los movimientos: descargas, cargas, re-estibas, tapas, solicitudes y aprobaciones |
| ID de dispositivo u otros | **ID de dispositivo u otros** | Sí | Sí | Funcionalidad de la app; prevención de fraudes, seguridad y cumplimiento | El identificador aleatorio de la instalación en cada movimiento, y la dirección IP que recibe Authentication al iniciar sesión (ver 2.3) |

### 2.2 Lo que no se declara, y por qué

| Tipo | Por qué no |
|---|---|
| **Audio (grabaciones de voz)** | El dictado lo hace el servicio de reconocimiento del sistema (Android) o del navegador (Web), no BayStream ni una biblioteca dentro de la app. BayStream recibe solo el texto, que llena el campo de búsqueda: no se guarda ni se envía. La política explica el servicio del proveedor. Es un criterio de Yov (2.3). |
| Ubicación | La app no pide permisos de ubicación ni la calcula. La IP de Authentication va en 2.1, con su finalidad. |
| Información y rendimiento de la app | No hay Crashlytics, informes de fallos ni diagnósticos (inventario: 0). |
| Analítica, publicidad | No hay Analytics, Installations ni anuncios (inventario: 0). |
| Contactos, mensajes, fotos, calendario, salud, finanzas, navegación | La app no los toca. |

### 2.3 Tres criterios de Yov, para que Carlos los conozca

1. **La IP de Authentication.**
   - Firebase dice que Authentication recopila la IP para la seguridad y contra el abuso.
   - Play no tiene un tipo «dirección IP». Se declara en **ID de dispositivo u otros**, con la finalidad de **prevención de fraudes y seguridad**, que es lo más conservador. Si la consola de Play ofrece algo más preciso cuando Carlos llene el formulario, se usa eso.
2. **El identificador de la instalación.**
   - Es aleatorio y no identifica el teléfono.
   - Aun así, identifica una instalación de la app, que es lo que Play describe en ese tipo. Se declara.
3. **La voz.**
   - La procesa el servicio del sistema o del navegador, fuera de la app.
   - Si Play o un revisor lo leen distinto, se declara **Grabaciones de voz**, opcional, para la funcionalidad de la app, y la política no cambia: ya lo explica.

### 2.4 Prácticas de seguridad

| Pregunta | Respuesta | Por qué |
|---|---|---|
| ¿Los datos se cifran en tránsito? | **Sí** | Firebase usa HTTPS (la política: «Las conexiones van cifradas») |
| ¿Hay una forma de pedir que se borren los datos? | **Sí** | Escribir al contacto de la política; Carlos borra la cuenta |
| ¿Los usuarios pueden crear una cuenta dentro de la app? | **No** | Las cuentas las crea Carlos en la consola (10.3). Por eso no aplica el requisito de borrar la cuenta desde la app |

## 3. Las demás declaraciones

Las de T-64 siguen igual, salvo lo marcado:

| Declaración | Respuesta | Estado |
|---|---|---|
| Anuncios | No contiene anuncios | sin cambio |
| ID de publicidad | No lo usa (sin `AD_ID`) | sin cambio; el inventario de T-88 lo confirma |
| **Acceso a la app** | **Hay funciones restringidas:** la sincronización necesita una cuenta | **cambia** (2.3 de T-64 decía que todo estaba disponible). Ver la decisión pendiente 1 |
| Clasificación de contenido | Cuestionario sin violencia, sexo, lenguaje, sustancias ni juego; sin interacción entre usuarios ni ubicación compartida | sin cambio |
| Público objetivo | 18 años o más | sin cambio; la política lo dice |
| Funciones financieras | Ninguna | sin cambio |
| Apps de salud | No ofrece funciones de salud | sin cambio |
| Apps gubernamentales | No | sin cambio (D6) |
| Permisos | `RECORD_AUDIO` es un permiso en tiempo de ejecución, pero no está entre los que piden el formulario de permisos. `READ_GSERVICES` lo agrega reCAPTCHA y es normal | **nuevo**, no pide formulario |

## 4. Decisiones pendientes de Carlos, para la prueba cerrada

1. **Acceso para el revisor de Play.** La sincronización necesita una cuenta. Hay dos caminos:
   - **declarar que la sincronización es opcional** y que la app se revisa en modo local, con una nota;
   - **o crear una cuenta de revisión.**
     - Con las reglas de hoy, cualquier cuenta autorizada lee **todas** las operaciones (10.47).
     - Antes de darle una cuenta a Google, las operaciones de producción deben ser solo de prueba, o hace falta otra regla.
2. **Un archivo de muestra para el revisor (D7 de T-64).** Sin un BAPLIE, el revisor ve solo la portada. Tiene que ser sintético: nunca del corpus.
3. **D1, D2 y D9 ya están decididos** (10.44). D5, el ícono, llega con la segunda entrega de T-88 (10.48).

## 5. Qué revisar si la app cambia

- Si se activa **Fraud Defense (reCAPTCHA)** en Authentication, o **App Check**: se agrega el token de reCAPTCHA o de App Check, para prevención de fraudes.
- Si entra **Crashlytics, Analytics o Installations**: cambia 2.2, y la política también.
- Si la app permite **crear cuentas**: aplica el requisito de borrar la cuenta desde la app y desde la Web.
- Si se usa **inicio de sesión por teléfono**: entra Play Integrity, según la página de Firebase.
