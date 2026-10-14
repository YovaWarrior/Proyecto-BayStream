{{flutter_js}}
{{flutter_build_config}}

// Rutas relativas a <base>: también funcionan si Hosting usa una subcarpeta.
const bayStreamConfig = {
  canvasKitBaseUrl: new URL('canvaskit/', document.baseURI).href,
  fontFallbackBaseUrl: new URL('fonts/', document.baseURI).href,
};

_flutter.loader.load({
  config: bayStreamConfig,
  serviceWorkerSettings: {
    serviceWorkerVersion: {{flutter_service_worker_version}},
  },
  onEntrypointLoaded: async function(engineInitializer) {
    // El SW reclama el primer cliente al activarse. Esperar el controlador
    // permite guardar los módulos en esa misma primera visita con red.
    if ('serviceWorker' in navigator && !navigator.serviceWorker.controller) {
      await new Promise((resolve) => {
        const timer = setTimeout(done, 4000);
        function done() {
          clearTimeout(timer);
          navigator.serviceWorker.removeEventListener('controllerchange', done);
          resolve();
        }
        navigator.serviceWorker.addEventListener('controllerchange', done);
        if (navigator.serviceWorker.controller) done();
      });
    }

    // CORE guarda index.html; onlineFirst busca la URL de la navegación (/).
    // La primera navegación aún no tenía controlador. Esta única petición
    // guarda también la raíz mediante el SW original, sin precargar el sitio.
    if (navigator.serviceWorker?.controller) {
      await fetch(new URL('./', document.baseURI), { cache: 'reload' }).catch(() => {});
    }

    // Core primero: los otros servicios comparten exactamente su módulo.
    const sdkBase = new URL('vendor/firebase/12.17.0/', document.baseURI);
    window.firebase_core = await import(new URL('firebase-app.js', sdkBase).href);
    const [auth, firestore] = await Promise.all([
      import(new URL('firebase-auth.js', sdkBase).href),
      import(new URL('firebase-firestore-pipelines.js', sdkBase).href),
    ]);
    window.firebase_auth = auth;
    window.firebase_firestore = firestore;

    const appRunner = await engineInitializer.initializeEngine(bayStreamConfig);
    await appRunner.runApp();
  },
});
