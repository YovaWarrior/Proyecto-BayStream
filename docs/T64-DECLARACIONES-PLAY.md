# T-64 · Declaraciones de Play para la prueba cerrada, comprobadas contra el código

Timonel · 2-oct-2026 · Solo documentos.

**No se compiló, no se tocó `lib/`, `test/`, `pubspec.*`, `android/`, `web/` ni `tool/`, y no se entró a
ninguna consola.** Todo lo que sigue sale de tres fuentes: el APK de T-44 (leído con herramientas del
SDK), el código del repositorio (leído, no ejecutado) y las páginas oficiales de Google y de Firebase
(leídas el 2-oct-2026). Donde una afirmación no se pudo comprobar con eso, aparece como
**verificación pendiente (V)**, y donde la decide Carlos, como **decisión (D)**.

**Corrección pedida sobre T-63.** En `docs/T63-CRITERIOS-RNF.md`, la opción 1.1 (a) ya no dice que
Carlos declaró el Honor X5d como dispositivo de referencia. Dice: «Es el único dispositivo Android con
el que se midió; si representa la gama media del planificador lo decide Carlos.» No se tocó nada más.

## Resumen

- **Seguridad de los datos.** La respuesta que sostiene la evidencia es **«no recopila ni comparte
  datos del usuario»**, pero **no debe declararse todavía**: tres dudas (V1, V2, V3) pueden cambiarla.
  La más seria es el respaldo automático de Android (V3), que el manifiesto deja activo y que la página
  de Google sobre esta sección no menciona.
- **Política de privacidad.** Las páginas oficiales **se contradicen** sobre si es obligatoria para una
  app como esta. La política de datos de usuario y la página de Seguridad de los datos (que la prueba
  cerrada sí exige) la piden a toda app; la página de preparación para revisión la condiciona a
  permisos sensibles o público infantil. **Hay que tenerla.** Además, la política de Google pide un
  enlace o texto **dentro de la app**, y la app no lo tiene (D4).
- **Anuncios, ID de publicidad, funciones financieras, salud, noticias, COVID-19 y permisos sensibles:**
  no aplican, con el dato del inventario que lo sostiene.
- **Clasificación, público objetivo y acceso a la app:** respuestas propuestas, con lo que solo se
  puede confirmar al ver el formulario en la consola.
- **Hallazgo de la ficha de tienda:** el ícono de la app es el logo por defecto de Flutter, y las capturas
  nativas del Honor (720×1600) no cumplen el límite de proporción de Play (D5).

---

## 1. Inventario: lo que la app hace con datos

### 1.1 Qué binario se leyó

| | |
|---|---|
| APK de T-44 | `build/app/outputs/flutter-apk/app-release.apk`, SHA-256 `C9A91F86…A169731E` (**coincide** con T-44) |
| Identidad | `gt.cmartinez.baystream`, `versionCode 1`, `versionName 1.0.0`, `minSdk 24`, `targetSdk 36` |
| Herramientas | `aapt2 dump badging` (build-tools 36.1.0), `apkanalyzer manifest print` (cmdline-tools `latest`), lectura del ZIP |
| Lo que se subirá | el `.aab` de T-49, SHA-256 `C60FFF0C…5679D` |

Del `.aab` solo se pudo leer el manifiesto de su módulo base **a nivel de cadenas** (no hay `bundletool`
instalado ni `apkanalyzer` lo abre). Salieron los mismos nombres de permiso que en el APK y las mismas
bibliotecas; no aparecen `allowBackup`, `dataExtractionRules`, `fullBackupContent` ni `AD_ID`. Aparece
además la cadena `android.permission.DUMP`: es el permiso que **exige el receptor
`ProfileInstallReceiver`** de AndroidX a quien le envíe órdenes (`android:permission` del receptor en
el manifiesto del APK), no un permiso que la app solicite. Para una lectura estructurada del `.aab`,
ver V9.

### 1.2 Permisos del manifiesto fusionado (APK de T-44)

| Permiso | Origen | Sensible según Play |
|---|---|---|
| `android.permission.INTERNET` | no está en el manifiesto de `android/app/src/main`; **aparece al fusionar** | no |
| `android.permission.ACCESS_NETWORK_STATE` | igual, al fusionar | no |
| `gt.cmartinez.baystream.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION` | permiso propio que agrega AndroidX | no |

- **No hay** permisos de ubicación, cámara, micrófono, contactos, SMS, llamadas, almacenamiento ni
  `com.google.android.gms.permission.AD_ID`.
- **Consultas de paquetes (`<queries>`):** solo dos intents (`PROCESS_TEXT` y `GET_CONTENT`); no hay
  `QUERY_ALL_PACKAGES`.
- **Componentes de Firebase presentes en el manifiesto fusionado:** `ComponentDiscoveryService` con los
  registradores de Core y Firestore, y `FirebaseInitProvider`.
- **Atributos de respaldo:** ni el manifiesto fuente (`android/app/src/main/AndroidManifest.xml`) ni el
  fusionado declaran `android:allowBackup`, `dataExtractionRules` ni `fullBackupContent`. Con
  `targetSdk 36` rige el valor por defecto (ver 1.6).
- **Aplica a la definición de Play.** La política de datos de usuario de Google enumera como datos
  personales y sensibles la información de identificación, la financiera, la de autenticación,
  contactos, ubicación, SMS y llamadas, salud, inventario de otras apps, micrófono y cámara. El acceso a
  red no figura en esa lista.
  Fuente: [Política de datos de usuario](https://support.google.com/googleplay/android-developer/answer/10144311).

### 1.3 Bibliotecas dentro del APK

Las clases del APK están ofuscadas por R8, así que los nombres de paquete del dex no identifican SDK.
Se usaron los archivos de metadatos que las bibliotecas dejan en el ZIP y las cadenas de texto del dex.

- **Firebase y Google Play services presentes:** `firebase-auth-interop 19.0.2`,
  `firebase-database-collection 18.0.1`, `play-services-base 18.9.0`, `play-services-basement 18.9.0`
  y `play-services-tasks 18.4.0`, además del propio Firestore. Dependencias directas del proyecto:
  `firebase_core ^4.4.0` y `cloud_firestore ^6.1.2` (`pubspec.yaml`).
- **No aparecen** metadatos de Analytics, Crashlytics, Messaging, Installations, App Check ni anuncios.
- **Cadenas de texto del dex:** de las 16 que se buscaron, solo aparece **`firestore.googleapis.com`**
  (una vez), que es el host por defecto del SDK de Firestore. **No aparecen las otras 15**, entre ellas
  `firebaseinstallations.googleapis.com`, `app-measurement`, `crashlytics`, `firebaselogging`,
  `google-analytics`, `googleads`, `doubleclick`, `admob`, `identitytoolkit`, `securetoken` y
  `fcm.googleapis.com`.
- **Código nativo (arm64):** en `libapp.so` y `libflutter.so` se buscaron seis de esas cadenas
  (`firestore.googleapis.com`, `firebaseinstallations`, `app-measurement`, `crashlytics`, `googleads` y
  `doubleclick`) y **no apareció ninguna**.
- **Límite:** que una cadena no esté no demuestra que el SDK no corra. Lo respalda además la medición
  de red de 1.5 (V1).

### 1.4 Lo que dice la página oficial de Firebase

Fuente: [Firebase: divulgación de datos de Google Play](https://firebase.google.com/docs/android/play-data-disclosure).

| SDK | Qué dice la página | Aplicado a este APK |
|---|---|---|
| **Cloud Firestore** | recopila automáticamente el *user agent* de Firebase, que Google usa para saber la adopción de plataformas y versiones y que «nunca se vincula a un identificador de usuario o dispositivo»; además puede recopilar datos de usuario que defina el desarrollador, según la implementación; con Firebase Authentication, cada petición incluye el ID de usuario | la app **no usa Authentication**; el *user agent* viaja solo cuando el SDK hace una petición (ver 1.5) |
| **Firebase Core (Installations)** | genera y recopila un identificador por instalación (FID), que no identifica de forma única a un usuario ni a un dispositivo | en este APK **no se encontró** el artefacto de Installations (1.3), pero no se confirmó con el árbol de dependencias de Gradle (V1) |
| **Cifrado** | Firebase cifra los datos en tránsito con HTTPS | solo importa si hubiera transmisión |

Esa misma página, por el lado de Google Play, remite a que el desarrollador **debe reflejar** lo que
hagan los SDK de terceros en el formulario de Seguridad de los datos
([ayuda de Play](https://support.google.com/googleplay/android-developer/answer/10787469)).

### 1.5 Lo que hace el código

Leído del repositorio en `0ec164b`, sin ejecutar nada:

| Hecho | Evidencia |
|---|---|
| Al arrancar se inicializa Firebase (solo si las opciones están definidas) | `lib/main.dart`: `Firebase.initializeApp(options: …)`; no se llama a ningún otro método de Firebase |
| **La única clase que escribe en Firestore** (`VesselRepositoryImpl`: `set`, `get`, `delete` sobre la colección `voyages`) | `lib/features/vessel/data/repositories/vessel_repository_impl.dart` |
| **El flujo de usuario solo usa de ella `parseBaplieFile`**, que parsea el texto en memoria y **no toca Firestore** | `vessel_providers.dart:217`; `vessel_repository_impl.dart:25-41` |
| Los métodos que sí escriben en Firestore solo se llaman desde `c3_reconciliation_screen.dart` | `grep`: `saveVoyage` en `lib/c3_reconciliation_screen.dart:100` |
| **Las pantallas de H5 (`latency_test_screen.dart`, `c3_reconciliation_screen.dart`) no están importadas desde ninguna otra parte de `lib/`:** no hay ruta de interfaz que las abra | `grep` sin resultados fuera de ellas mismas; coincide con lo que `docs/T44-RESULTADOS.md` cita de T-45 (§10.10–10.11 de `SPRINT-2.md`): el producto no llama al repositorio de Firestore |
| Los viajes y perfiles se guardan **solo en el dispositivo**, en el directorio privado `filesDir` de la app | `local_store_directory_io.dart`; `MainActivity.kt` (`filesDir.absolutePath`); almacén Hive |
| Exportar (PDF, CSV…) abre el **selector de archivos del sistema** y guarda los bytes donde el usuario elige | `export_service.dart:110-132`: `FilePicker.platform.saveFile(…, bytes: …)` |
| El usuario puede **eliminar un viaje guardado** desde la interfaz; «borrar la copia local no borra el perfil» | `recent_voyages_page.dart:50-115`; `vessel_providers.dart:454-457` |
| **No hay autenticación, cuentas ni contraseñas** | `grep` de `FirebaseAuth`, `signIn`, `login`, `password`, `credential` en `lib/` sin resultados |
| **No hay compras ni anuncios** | `pubspec.yaml` sin SDK de facturación ni de anuncios; sin permiso de facturación ni `AD_ID` en el manifiesto |
| **No hay texto ni enlace de política de privacidad dentro de la app** | `grep` de `privacidad`, `privacy`, `launchUrl` en `lib/` sin resultados |
| El ícono de la app es el **logo por defecto de Flutter** | `android/app/src/main/res/mipmap-*/ic_launcher.png`, tamaños de fábrica (442, 544, 721, 1031, 1443 bytes); vista en pantalla confirmada |

### 1.6 Lo que midió RNF-004 (`docs/T44-FINAL-RESULTADOS.md`)

| Plataforma | Resultado | Límite declarado |
|---|---|---|
| **Honor, APK `C9A91F86`, UID 10231** | **0 conexiones TCP** durante el arranque en frío (120 s) y durante la carga de A01 con el flujo de perfil completo (180 s). Control positivo con GMS: 1 conexión | la sonda **no ve UDP ni QUIC**, muestrea cada 250 ms y **solo cubre el arranque y la carga de A01**: la búsqueda, las estadísticas, las alertas, la exportación y la reapertura de un viaje **no se midieron en Android** |
| **Web, `main.dart.js` `4939E264`** | 0 peticiones a `firestore.googleapis.com`; al cargar A01 y A02 y al usar plano, estadísticas y búsqueda, ninguna petición (solo URL `data:` locales) | la Web **no se publica en Play**; sirve de indicio, no de prueba para Android |
| **Windows** | sin medir | no se publica en Play |

**Respaldo automático de Android.** Con `allowBackup` sin declarar, Android lo trata como activo. La
documentación de Android dice que, por defecto, el respaldo incluye los archivos del almacenamiento
interno (`getFilesDir()`), se guarda en una carpeta privada de la cuenta de Google Drive del usuario,
con un límite de 25 MB por app, y está cifrado de extremo a extremo desde Android 9 con el bloqueo de
pantalla. Para apps con `targetSdk 31` o superior, las reglas de extracción se declaran con
`dataExtractionRules`.
Fuente: [Android: Auto Backup](https://developer.android.com/identity/data/autobackup).
**Consecuencia:** los viajes y perfiles que la app guarda en `filesDir` pueden salir del dispositivo
hacia la cuenta de Google del usuario sin que la app haga nada. Esto **no figuraba** en el inventario de
T-44 y no está resuelto en 2.6.

### 1.7 Lo que el inventario no puede decir (verificaciones pendientes)

| # | Verificación pendiente | Qué haría falta |
|---|---|---|
| **V1** | Que **no hay Firebase Installations** en el APK real. Falta el árbol de dependencias de Gradle: no se corrió porque toca `android/` y la regla pide no compilar | `gradlew :app:dependencies` o `bundletool`, lo hace Carlos o se agenda como tarea |
| **V2** | Que **ninguna operación básica transmite en Android**. Solo se midió el arranque y A01 | repetir la sonda de red del Honor sobre búsqueda, estadísticas, alertas, exportación y reapertura (≈ 1 h; coincide con la medición faltante de RNF-004 en T-63) |
| **V3** | Si el **respaldo automático cuenta como «recopilación»** para Play. La página de la sección de Seguridad de los datos define «recopilar» como transmitir datos fuera del dispositivo, y **no menciona el respaldo del sistema** (se leyó la página completa buscando ese tema) | decisión de Carlos (D3) y, si se quiere certeza, una consulta a Play Console Help |
| **V4** | Que el **cuestionario de clasificación de contenido** se contesta como se propone en 2.4. Las preguntas exactas solo se ven en la consola | verlas en la consola |
| **V5** | Que la **declaración de apps gubernamentales** no aplica, que depende de quién use la app (D6) | respuesta de Carlos |
| **V6** | Qué preguntas exactas trae hoy el **formulario de Seguridad de los datos** en la consola; este documento usa la página de ayuda, no el formulario | verlo en la consola |
| **V7** | Que la **exportación** cae en la excepción de «acción iniciada por el usuario». La página la describe, y el flujo usa el selector del sistema, pero no se probó qué opciones ofrece ese selector en el Honor | revisar el selector en el Honor |
| **V8** | Que el contenido de un BAPLIE **no incluye datos personales** (nombres de personas, contactos). Se asumió por el formato y por el corpus anonimizado; el corpus no es un archivo real | revisar con Carlos un archivo real, sin copiarlo aquí |
| **V9** | El manifiesto del **`.aab`** leído con herramienta estructurada (`bundletool`), no por cadenas | `bundletool dump manifest` |

---

## 2. Una respuesta por declaración

Orden de la página de **Contenido de la app**. «Estado» dice si la respuesta se puede declarar hoy.

### 2.1 Política de privacidad — ver la sección 3.

### 2.2 Anuncios

| | |
|---|---|
| **Respuesta propuesta** | **No contiene anuncios** |
| **Evidencia** | `pubspec.yaml` sin SDK de anuncios; sin `AD_ID` en el manifiesto del APK ni del `.aab`; sin cadenas de redes de anuncios en el dex (1.3) |
| **Fuente** | [Preparar la app para revisión](https://support.google.com/googleplay/android-developer/answer/9859455): hay que declarar si la app contiene o no anuncios |
| **Estado** | declarable |

### 2.3 Acceso a la app

| | |
|---|---|
| **Respuesta propuesta** | **Toda la funcionalidad está disponible sin credenciales ni restricciones** |
| **Evidencia** | no hay autenticación ni cuentas (1.5) |
| **Fuente** | misma página: los detalles de acceso se piden solo si la app, o parte de ella, está restringida por inicio de sesión, membresía, ubicación u otra autenticación |
| **Duda (D7)** | la app **no muestra nada útil sin un archivo BAPLIE**. Eso no es una restricción de acceso en el sentido de la página, pero un revisor sin archivo verá solo la portada. Conviene decidir si se incluye una nota o un archivo de muestra para el revisor. El corpus está anonimizado, pero es de viajes reales: **no se debe publicar sin que Carlos lo decida** |
| **Estado** | declarable; D7 pendiente |

### 2.4 Clasificación de contenido

| | |
|---|---|
| **Respuesta propuesta** | cuestionario IARC contestado con «ninguno» en violencia, contenido sexual, lenguaje, sustancias controladas y juego; **sin** interacción entre usuarios, **sin** compartir ubicación, **sin** compras digitales |
| **Evidencia** | la app es un visor de archivos de estiba: sin contenido generado por usuarios, sin red social, sin ubicación (1.2) y sin compras (1.5) |
| **Fuente** | [Clasificación de contenido](https://support.google.com/googleplay/android-developer/answer/9859655): el cuestionario determina las clasificaciones, hay que rehacerlo si cambia el contenido o las funciones, y una app sin clasificación se marca como «sin clasificar» |
| **Pendiente** | V4: las preguntas exactas. La **categoría** de la app (D6) cambia el cuestionario |
| **Estado** | propuesta, a confirmar en la consola |

### 2.5 Público objetivo y contenido

| | |
|---|---|
| **Respuesta propuesta** | **18 años o más**; no está dirigida a niños |
| **Evidencia** | el ERS la define para «personal del sector marítimo-portuario»; no hay ningún elemento infantil en la interfaz |
| **Fuente** | [Público objetivo](https://support.google.com/googleplay/android-developer/answer/9867159): los rangos son «5 o menos», «6–8», «9–12», «13–15», «16–17» y «18 o más»; cualquier rango que incluya niños exige cumplir la política de Familias, y Play puede rechazar una ficha cuyo material de marketing sugiera público infantil |
| **Duda** | el ERS no fija una edad mínima. Elegir «16–17 y 18 o más» ampliaría el público sin una razón del producto: se propone solo «18 o más», y **lo confirma Carlos** (D6) |
| **Estado** | propuesta |

### 2.6 Seguridad de los datos

| | |
|---|---|
| **Respuesta propuesta** | «¿Su app recopila o comparte alguno de los tipos de datos de usuario requeridos?» → **No** |
| **Qué la sostiene** | permisos sin datos sensibles (1.2); sin SDK de analítica, anuncios ni Installations (1.3); el flujo de usuario no llama a Firestore (1.5); 0 conexiones TCP en el arranque y la carga de A01 en el Honor (1.6); los datos se procesan y se guardan solo en el dispositivo |
| **Qué dice Google que no hay que declarar** | los datos de usuario que la app procesa **solo de forma local** y no salen del dispositivo; y las transferencias iniciadas por una acción específica del usuario, donde este espera razonablemente que los datos se compartan (la exportación por el selector del sistema) |
| **Fuente** | [Sección de Seguridad de los datos](https://support.google.com/googleplay/android-developer/answer/10787469); [Firebase: divulgación para Google Play](https://firebase.google.com/docs/android/play-data-disclosure) |
| **Es obligatoria en la prueba cerrada** | **sí.** Solo están exentas las apps que están **únicamente** en la pista de prueba interna; las de pruebas cerradas, abiertas o producción deben completarla, aunque no recopilen ningún dato, y deben incluir el enlace a la política de privacidad |
| **No declarar todavía** | por tres dudas que pueden convertir el «No» en un «Sí»: **V1** (Installations), **V2** (operaciones no medidas en Android) y **V3** (respaldo automático) |
| **Si V3 resulta ser «sí, cuenta»** | habría que contestar «Sí» y elegir los tipos de datos que se respaldan. No se proponen tipos aquí: la página de ayuda no dice cuáles corresponden |
| **Si el *user agent* de Firestore contara** | Firebase dice que no se vincula a un usuario ni a un dispositivo, y que solo viaja cuando el SDK hace una petición. Es la razón por la que V2 importa |

**Qué no se puede afirmar.** La respuesta «No» queda **propuesta, no confirmada**. Se escribe así porque
la alternativa cómoda, declarar «No» y seguir, ocultaría el respaldo automático y las operaciones sin
medir.

### 2.7 ID de publicidad

| | |
|---|---|
| **Respuesta propuesta** | **No usa el ID de publicidad** |
| **Evidencia** | sin `com.google.android.gms.permission.AD_ID` en el manifiesto del APK ni del `.aab`; sin SDK de anuncios (1.2, 1.3); `targetSdk 36`, así que la declaración sí es obligatoria |
| **Fuente** | [ID de publicidad](https://support.google.com/googleplay/android-developer/answer/6048248): las apps con `targetSdk` 13 o superior declaran este permiso en el manifiesto cuando lo usan, y algunos SDK de anuncios lo agregan al fusionarse |
| **Estado** | declarable |

### 2.8 Funciones financieras

| | |
|---|---|
| **Respuesta propuesta** | **«Mi app no ofrece ninguna función financiera»** |
| **Evidencia** | sin SDK de facturación ni de pagos en `pubspec.yaml`; sin permiso de facturación; la app no maneja dinero (1.5) |
| **Fuente** | [Funciones financieras](https://support.google.com/googleplay/android-developer/answer/13849271): obligatoria para todas las apps, también en pruebas cerradas, incluso sin funciones financieras |
| **Estado** | declarable |

### 2.9 Apps de salud

| | |
|---|---|
| **Respuesta propuesta** | **No ofrece funciones de salud** |
| **Evidencia** | la app no maneja datos de salud (1.2, 1.5) |
| **Fuente** | [Apps de salud](https://support.google.com/googleplay/android-developer/answer/14738291): se completa y certifica también si la app no ofrece funciones de salud, incluso en pruebas cerradas |
| **Estado** | declarable |

### 2.10 Apps gubernamentales

| | |
|---|---|
| **Respuesta propuesta** | **No** |
| **Evidencia** | la app es el proyecto de graduación de Carlos; el repositorio no dice que la use ni se la entregue un gobierno |
| **Fuente** | [Apps gubernamentales](https://support.google.com/googleplay/android-developer/answer/9514050). Esta página **se confirmó solo por el resumen de una búsqueda**, no se abrió completa |
| **Pendiente** | V5 y D6: depende de quién use la app. Una autoridad portuaria pública podría contar |
| **Estado** | propuesta |

### 2.11 Declaraciones que no aplican

| Declaración | Por qué no aplica | Fuente |
|---|---|---|
| Formulario de permisos | exige permisos de alto riesgo (SMS, registro de llamadas); la app solo tiene `INTERNET` y `ACCESS_NETWORK_STATE` | [Preparar la app para revisión](https://support.google.com/googleplay/android-developer/answer/9859455) |
| Apps de noticias | la app no publica noticias ni revistas | misma página |
| Seguimiento de contactos de COVID-19 | no tiene funciones relacionadas con el coronavirus | misma página |
| Cuenta de usuario y su eliminación | no hay cuentas (1.5) | **sin fuente oficial leída**; si la consola pregunta, se responde «no hay cuentas» |

---

## 3. Política de privacidad

### 3.1 ¿Es obligatoria? Las fuentes oficiales no coinciden

| Página oficial | Qué dice, en síntesis | Para esta app |
|---|---|---|
| [Preparar la app para revisión](https://support.google.com/googleplay/android-developer/answer/9859455) | pide el enlace en la ficha y **dentro de la app** a las apps que piden **permisos o datos sensibles** y a las apps dirigidas a niños. Para estas últimas agrega que incluso las que no acceden a datos personales deben presentarla | **no sería obligatoria**: sin permisos sensibles y sin público infantil |
| [Política de datos de usuario](https://support.google.com/googleplay/android-developer/answer/10144311) | **toda app** debe publicar un enlace en el campo de Play Console y un enlace o texto **dentro de la app**; también las que no acceden a datos personales ni sensibles. Debe estar en una dirección activa, pública, no restringida por región, **sin PDF** y no editable | **obligatoria**, y también dentro de la app |
| [Seguridad de los datos](https://support.google.com/googleplay/android-developer/answer/10787469) | incluso las apps que no recopilan ningún dato deben completar el formulario y dar el enlace a su política | **obligatoria** para la prueba cerrada (2.6) |

**Conclusión.** La primera página, tomada sola, diría que no hace falta. Las otras dos, que sí, y la tercera
es el formulario que la prueba cerrada exige. **Se trata como obligatoria**; no por ser la lectura más
cómoda ni la más estricta, sino porque sin ella el formulario de Seguridad de los datos no se puede
completar. La política de datos de usuario añade además que el enlace o texto esté **dentro de la app**
(D4).

### 3.2 Hallazgo para el producto

La app **no tiene** ni enlace ni texto de política de privacidad (1.5). Cumplir la parte «dentro de la
app» exige un cambio en `lib/`, y **el producto está quieto hasta el cierre del sprint** (10.40). Es
una decisión de Carlos (D4): pasarlo al Sprint 3, o decidir cómo se maneja la prueba cerrada con ese
hueco declarado.

### 3.3 Borrador (español, corto, verdadero)

> **Política de privacidad de BayStream**
> Última actualización: [FECHA — pendiente de Carlos]
>
> **Qué es BayStream.** BayStream es una aplicación para ver el plano de estiba de un buque a partir de
> un archivo BAPLIE que usted elige. Es un proyecto de graduación de Carlos Martínez.
>
> **Qué datos usa.** La aplicación lee el archivo BAPLIE que usted selecciona y lo procesa en su
> dispositivo. Ese archivo puede contener información comercial de carga, como números de contenedor,
> puertos, pesos y mercancías peligrosas. La aplicación no le pide ni guarda su nombre, correo,
> ubicación, contactos ni ningún dato personal, y no tiene cuentas de usuario.
>
> **Qué guarda.** Los viajes recientes y los perfiles de buque que usted confirma se guardan solo en el
> almacenamiento privado de la aplicación en su dispositivo. Usted puede eliminar un viaje guardado
> desde la aplicación. Los perfiles de buque no se pueden eliminar desde la aplicación: permanecen
> hasta que usted desinstale la aplicación o borre sus datos desde los ajustes de Android.
>
> **Qué envía.** La aplicación **no envía** el contenido de sus archivos ni los viajes guardados a ningún
> servidor, no muestra anuncios y no usa herramientas de analítica ni de seguimiento. [CONDICIONADO A
> V1 y V2: se escribe tal como lo muestra la evidencia de hoy.]
>
> **Copias de seguridad de Android.** [DEPENDE DE D3. Si el respaldo automático sigue activo: «Android
> puede incluir los datos guardados por la aplicación en la copia de seguridad automática de su cuenta
> de Google, según la configuración de su dispositivo. BayStream no controla esa copia.»]
>
> **Exportar.** Cuando usted exporta un reporte, la aplicación abre el selector de archivos de su
> dispositivo y guarda el archivo donde usted decida. Lo que haga con ese archivo después queda fuera de
> la aplicación.
>
> **Contacto.** [CORREO DE CONTACTO — pendiente de Carlos]

**Qué no dice, a propósito:**
- No dice que la aplicación «no usa Firebase»: **sí lo inicializa** (`main.dart`). Si V1 o V2 muestran
  tráfico, hay que reescribir la sección «Qué envía».
- No promete derechos que no existen, como una «solicitud de eliminación de datos»: no hay cuentas ni
  servidor donde eliminar nada.
- No cita leyes ni plazos. Si Carlos quiere un asesor legal, esa revisión no se sustituye con este borrador.
  Play mismo recomienda consultar a un representante legal sobre lo que se exige
  ([Preparar la app para revisión](https://support.google.com/googleplay/android-developer/answer/9859455)).

### 3.4 Dónde publicarla (decide Carlos, D1)

Requisitos de la política de datos de usuario: dirección **pública y activa**, **sin restricción por
región**, **no editable** y **sin formato PDF** (3.1). No se creó ninguna página ni se desplegó nada.
Hosting del proyecto de producción es una posibilidad ya existente; otra, cualquier sitio estático que
Carlos controle. **No se elige aquí.**

---

## 4. Lo que hará Carlos en la consola, y lo que falta que no es código

**Orden propuesto.** La consola puede reordenar o renombrar pasos; este orden sale de las dependencias
entre ellos.

### Antes de abrir la consola

1. **Decidir D1 a D9** (abajo). Varias cambian lo que se escribe en la consola.
2. **Esperar la aprobación de identidad de Google** (10.40). Todo lo que sigue depende de ella.
3. **Publicar la política de privacidad** donde decida D1 y anotar la dirección.

### En Play Console

4. **Crear la app.** Nombre de hasta 30 caracteres (la ficha oficial fija ese límite; el manifiesto dice
   `baystream` en minúsculas y la interfaz `BayStream`, D9), idioma español, gratuita.
   Fuente: [Ficha de la tienda](https://support.google.com/googleplay/android-developer/answer/9859152).
5. **Prueba interna (T-49, parte 2):** subir el `.aab`. **No necesita** las declaraciones de este
   documento (10.40; y la sección de Seguridad de los datos exime a las apps que están únicamente en la
   pista interna).
6. **Contenido de la app**, en este orden: política de privacidad (2.1/3), anuncios (2.2), acceso a la app
   (2.3), clasificación de contenido (2.4), público objetivo (2.5), Seguridad de los datos (2.6, **solo
   después de cerrar V1 a V3**), ID de publicidad (2.7), funciones financieras (2.8), apps de salud
   (2.9) y apps gubernamentales (2.10).
7. **Ficha de la tienda.** Falta todo lo siguiente, y nada de ello es código:

   | Pieza | Requisito oficial | Estado hoy |
   |---|---|---|
   | Descripción corta | hasta 80 caracteres | por redactar |
   | Descripción completa | hasta 4 000 caracteres | por redactar |
   | **Correo de contacto** | **obligatorio**; Play recomienda también un sitio web | **pendiente** (D2) |
   | Ícono | PNG de 32 bits con alfa, 512×512, hasta 1 024 KB | **no existe**; el de la app es el de Flutter (D5) |
   | Gráfico de funciones | 1024×500, JPEG o PNG de 24 bits sin alfa | por crear |
   | Capturas | mínimo dos; JPEG o PNG de 24 bits sin alfa; lado menor ≥ 320 px, lado mayor ≤ 3 840 px y **nunca más del doble del lado menor**; para destacar, al menos cuatro de 1 080 px o más en 16:9 o 9:16 | las capturas nativas del Honor son **720×1600 (proporción 2.22:1)**, que **excede** el 2:1 permitido; hay que tomarlas de otro modo (D5) |

   Fuente de los tamaños: [Recursos de la ficha](https://support.google.com/googleplay/android-developer/answer/9866151).
8. **Pista de prueba cerrada.** Crear la pista, la lista de probadores (por correos o por Google Groups,
   hasta 2 000 usuarios por lista), y una **dirección de comentarios**: un correo o una URL que aparece
   en la página de aceptación. Los probadores necesitan una cuenta de Google y entran por un enlace de
   aceptación que se comparte.
   Fuente: [Pruebas cerradas](https://support.google.com/googleplay/android-developer/answer/9845334).
9. **Reunir al menos 12 probadores** con la aceptación vigente **14 días seguidos** antes de solicitar el
   acceso a producción (cuentas personales nuevas).
   Fuente: [Requisitos de prueba para cuentas nuevas](https://support.google.com/googleplay/android-developer/answer/14151465).
   Con la identidad aprobada, el calendario de 14 días es el tramo más lento que queda.

### Lo que falta y no es código

| Pendiente | Quién |
|---|---|
| Correo de contacto de la ficha y de la política | Carlos (D2) |
| Dónde publicar la política (D1) y su fecha | Carlos |
| Redactar descripciones corta y completa | Carlos, con Yov |
| Ícono de 512×512, gráfico de 1024×500 y capturas válidas | Carlos |
| Lista de al menos 12 probadores con cuenta de Google | Carlos (D8) |
| Revisar con un asesor legal el texto de la política, si Carlos lo desea | Carlos |

### Decisiones para Carlos

| # | Decisión | Por qué importa |
|---|---|---|
| **D1** | Dónde se publica la política de privacidad | URL pública, no PDF, no editable (3.4) |
| **D2** | Correo de contacto | obligatorio en la ficha; va también en la política |
| **D3** | Respaldo automático de Android: **dejarlo activo y declararlo**, o **desactivarlo** en un cambio futuro de `android/` (el producto está quieto) | cambia la respuesta de 2.6 y un párrafo de 3.3. **No se elige aquí** |
| **D4** | La política dentro de la app: pasarlo al Sprint 3, o decidir cómo se sigue con el hueco | exige cambio en `lib/`; la política de datos de usuario la pide |
| **D5** | Ícono propio y capturas válidas; el ícono de la **app** también es el de Flutter y cambiarlo toca `android/` | la ficha pide un ícono de 512×512; el de la app no es el de BayStream |
| **D6** | Categoría de la app, rango de edad (propuesta: 18 o más) y si la app es «gubernamental» | cambia el cuestionario de clasificación y 2.10 |
| **D7** | Cómo se maneja la revisión sin archivo BAPLIE: nota, archivo de muestra o nada | el revisor solo verá la portada |
| **D8** | Quiénes son los 12 probadores | el plazo de 14 días empieza cuando todos aceptan |
| **D9** | Nombre en la tienda: «BayStream» o «baystream» | el manifiesto dice `baystream` |

## Archivos

- Nuevo: `docs/T64-DECLARACIONES-PLAY.md`.
- Modificado: `docs/T63-CRITERIOS-RNF.md` (solo la opción 1.1 (a), a pedido de Yov).
- No se tocó `lib/`, `test/`, `pubspec.*`, `android/`, `web/` ni `tool/`. No se compiló y no se entró a
  ninguna consola.
- Las salidas de las herramientas del SDK quedaron en el directorio temporal de la sesión; no se
  versionan.
