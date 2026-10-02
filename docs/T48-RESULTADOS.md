# T-48 · Cliente Web en Firebase Hosting

**Fecha:** 1-oct-2026. **Estado:** implementación y verificaciones terminadas; lista para revisión y cierre de Carlos/Yov. Desplegada por Carlos en Firebase Hosting.

## 1. Alcance y configuración

Se crearon manualmente `firebase.json` y `.firebaserc`, sin ejecutar `firebase init`. El proyecto predeterminado es `baystream-app`; la única sección de servicios es `hosting`, con directorio público `build/web` y reescritura de `**` a `/index.html`.

Se configura `Cache-Control: no-cache, max-age=0, must-revalidate` para todos los recursos publicados. Incluye `index.html`, `flutter_bootstrap.js` y `main.dart.js`, y evita que un recurso con nombre estable quede en caché larga entre versiones. Esta política permite almacenar una respuesta, pero exige revalidarla antes de reutilizarla. Las rutas reescritas también quedan cubiertas. Se contrastó la sintaxis con la [documentación oficial de Hosting](https://firebase.google.com/docs/hosting/full-config).

No se incluye configuración de Firestore ni se despliega `firestore.rules`, que pertenece al proyecto temporal. Se conserva la decisión de SPRINT-2.md §10.36: la Web necesita conexión para arrancar en este sprint; no se cambia CanvasKit ni Roboto.

## 2. Compilación candidata

Referencia de producto: **`ba7353a`**, cierre de T-47. HEAD al preparar T-48: **`b526732`**, actualización documental del sprint. La consulta `git diff --stat -- lib/ test/ pubspec.yaml pubspec.lock` no mostró diferencias; Git emitió avisos de conversión LF/CRLF preexistentes.

Comando ejecutado desde la raíz:

```powershell
flutter build web --release --no-pub --dart-define-from-file=C:\Proyectos\baystream-privado\firebase-prod.json
```

Resultado: `Compiling lib\main.dart for the Web... 40.3s` y `√ Built build\web`. Flutter también informó que el ensayo Wasm fue satisfactorio y sugirió probar `--wasm`; se mantuvo la compilación Web solicitada.

**SHA-256 de `build/web/main.dart.js`:**

```text
4939E2641C53D75589103F4D27F087D262E93D277626A6F1658FD570A94E2C38
```

Tamaño: **3 970 998 bytes**. Coincide con la versión de T-47. El registro de compilación está en `build/t48/build-web.log`. Las opciones privadas permanecen fuera del repositorio; no se imprimieron sus valores.

Se avisó con `SEMÁFORO:` antes y después de compilar, y antes y después de las verificaciones de Flutter. El primer intento restringido no produjo salida y fue interrumpido; la ejecución con permiso de acceso a la caché externa de Flutter terminó correctamente. No se borraron archivos de bloqueo ni se interrumpieron procesos ajenos.

## 3. Suite y análisis

- `flutter test --no-pub --reporter expanded`: **`00:09 +282: All tests passed!`**.
- `flutter analyze --no-pub`: **`No issues found! (ran in 23.3s)`**.
- Registros: `build/t48/test.log` y `build/t48/analyze.log`.
- No se agregaron, modificaron, eliminaron ni omitieron pruebas.

## 4. Despliegue a cargo de Carlos

Comando entregado para ejecutar desde `C:\Proyectos\proyecto-baystream`:

```powershell
firebase deploy --only hosting --project baystream-app
```

**URL publicada:** https://baystream-app.web.app.

Carlos confirmó `Deploy complete!`: Hosting encontró 35 archivos en `build/web`, completó la subida, finalizó la versión y la liberó en `baystream-app`. Capitán Codex no ejecutó el despliegue.

## 5. Verificación publicada

| Criterio | Estado / evidencia |
|---|---|
| SHA-256 del `main.dart.js` publicado igual al local | **Cumple.** Descarga HTTP del archivo publicado; mismo hash de §2. `build/t48/hosting-verificacion.json`. |
| Google Chrome visible, carga A01 y panel 0/0/6 | **Cumple.** BUQUE ALFA / V01N: 977 contenedores, 34 bahías. Perfil propuesto desde A01, sin límite de apilamiento declarado, tomas de reefer propuestas. `chrome-a01-panel.png` y `.txt`. |
| Google Chrome visible, carga A03 y panel 2/100/151 | **Cumple.** BUQUE CHARLIE / VIAJE003A: 369 contenedores, 27 bahías. Perfil propuesto desde A03, fila 00 en cubierta propuesta como existente, sin límite de apilamiento declarado. `chrome-a03-panel.png` y `.txt`. |
| Recarga de página conserva Recientes y perfiles | **Cumple.** Tras `reload()`, Recientes lista ambos viajes y Perfiles guardados lista ALFA y CHARLIE. Se abrió el perfil ALFA y recuperó sus niveles y la opción «No lo tengo». `chrome-recientes-recarga.png` y `.txt`; `chrome-perfiles-recarga.png` y `.txt`. |
| Network sin peticiones a `firestore.googleapis.com` | **Cumple en la sesión manual observada.** Carlos confirmó «ya cargue el A01 Y A03». La captura de contexto muestra el dominio publicado, A03 cargado, Network con All, Keep log y Disable cache activados, y 16 solicitudes conservadas. La captura posterior filtra por `https://firestore.googleapis.com/` y no muestra ninguna fila. Evidencias: `chrome-network-manual-a03.png` y `chrome-network-manual-sin-firestore.png`. |
| Cabeceras de caché de index y bootstrap en Hosting | **Cumple.** HEAD sobre `/`, `/index.html`, `/flutter_bootstrap.js` y `/ruta-t48`: HTTP 200 y `must-revalidate, no-cache, max-age=0`. La ruta reescrita devuelve HTML. `hosting-verificacion.json`. |

Las comprobaciones de interfaz se realizaron en una pestaña Chrome creada para T-48, visible, con URL `https://baystream-app.web.app/`. Se cargaron `build/t44/CORPUS_A01.edi` y `CORPUS_A03.edi` mediante el selector real del cliente publicado. Las capturas y textos de accesibilidad proceden de esa pestaña; no se modificó ni instrumentó el cliente. El archivo publicado se descargó a `build/t48/main-publicado.dart.js` solo para comparar su hash; no se imprimió su contenido.

El almacén verificado pertenece al origen **`https://baystream-app.web.app`** del perfil de Chrome utilizado. Estos datos locales son independientes del almacén de Windows y de los orígenes `127.0.0.1` usados en tareas anteriores. No se verificó la persistencia por lectura interna del almacenamiento: se comprobó mediante la interfaz después de recargar.

La comprobación de Network se completó manualmente por Carlos porque la automatización nativa de Windows se detuvo antes de abrir DevTools: no pudo verificar la URL de Chrome con confianza suficiente. Se detuvo la interacción al recibir el aviso y no se intentó eludirlo. Las capturas manuales se conservaron sin edición; la comprobación acredita ausencia de solicitudes al dominio de Firestore en el registro de esa sesión, no una garantía sobre todos los flujos posibles.

En la lista sin filtrar se descargan los scripts `firebase-app.js` y `firebase-firestore-pipelines.js`; cargar el SDK no equivale a consultar la API `firestore.googleapis.com`. También aparece una petición fallida a la propia raíz de Hosting, iniciada por `flutter_service_worker`, y solicitudes posteriores a esa raíz con 200. La captura no muestra el motivo del fallo; no se atribuye a Firestore y no impidió cargar A03. El 404 que Carlos mostró en una pestaña distinta corresponde a abrir manualmente la raíz de `firestore.googleapis.com`, no a una petición del cliente BayStream; esa captura no se usa para acreditar el criterio.

Los criterios de T-48 quedaron verificados en el dominio real. Los resultados locales de T-47 no se usaron como sustituto de estas comprobaciones.

## 6. Archivos de la entrega

- `firebase.json`.
- `.firebaserc`.
- `docs/T48-RESULTADOS.md`.

No se modificaron `lib/`, `test/`, `android/`, los archivos congelados, `pubspec.yaml` ni `pubspec.lock`. No se agregaron dependencias. Los binarios y evidencias bajo `build/` están ignorados y no se incluyen en la entrega Git. Ningún archivo privado pertenece a la entrega.
