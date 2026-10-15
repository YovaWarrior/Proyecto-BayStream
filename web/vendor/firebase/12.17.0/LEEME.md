# Firebase JS SDK servido por BayStream · T-92

Versión **12.17.0**, exigida por `firebase_core_web 3.10.0` resuelto.
`provenance.json` registra la URL de cada descarga y los SHA-256 originales y
servidos. Se descargaron los tres módulos que inyecta ese paquete: app, auth y
firestore-pipelines. Sus únicas dependencias externas de módulo son app.

Se reemplazó la URL `https://www.gstatic.com/firebasejs/12.17.0/firebase-app.js`
por `./firebase-app.js` en los imports y en dos literales de código de
`firebase-app.js`: `name$q` y el argumento de `Logger`. No hay otros cambios.
Todos los servicios comparten así la misma instancia de
app. Core conserva su cabecera de licencia. Los bundles de Auth y Firestore
descargados no incluyen cabecera; `LICENSE.txt`, asociado a cada archivo en
procedencia, incluye la licencia Apache 2.0 y los avisos del proyecto Firebase.

Licencia descargada de:
https://raw.githubusercontent.com/firebase/firebase-js-sdk/main/LICENSE

Para actualizar: leer `supportedFirebaseJsSdkVersion` del paquete resuelto;
descargar de `https://www.gstatic.com/firebasejs/<version>/` los servicios que
realmente inyecta y seguir recursivamente sus imports; reescribir imports a rutas
relativas; actualizar carpeta, plantilla y procedencia con SHA antes/después.
Repetir pruebas T-92, verificador y aceptación de arranque y sincronización. No
actualizar este SDK independientemente de FlutterFire ni mezclar versiones.

La plantilla asigna `window.firebase_core`, `window.firebase_auth` y
`window.firebase_firestore` antes de `initializeEngine`. `_initializeCore()`
retorna al encontrar core; el arranque de Dart crea la app como antes. No hay
configuración de cuenta ni opciones de Firebase en estos archivos.
