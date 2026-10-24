// T-114 · Fase 3, entrega 1: la primera visualización en la Web, en tres pasos.
//
// Se inyecta en la página del banco Web (tool/t99_main.dart servido en
// 127.0.0.1) desde el navegador integrado de la consola, como instrumento de
// RNF-002. Los tres pasos del producto: (1) abrir la app (la navegación, que
// es el «icono» y el origen del reloj, performance.timeOrigin), (2) pulsar
// «Seleccionar archivo», (3) elegir el archivo en el selector. El selector lo
// intercepta el navegador: el archivo ya descargado se asigna al <input
// type=file> de file_picker y se dispara su evento `change`, como hizo T-98
// con DOM.setFileInputFiles; el tiempo humano de buscar en el diálogo no se
// mide, igual que allí. El fin es el primer cuadro en que el árbol de
// semántica trae una bahía del plano, muestreado en cada animación
// (requestAnimationFrame). Los relojes son performance.now() de la página.
//
// Uso, en la página recién navegada (el instrumento espera el primer cuadro):
//   await t114Esperar();                                   // primer cuadro y semántica
//   await t114Preparar('/t114/T99_SINTETICO_977.edi');   // descarga el archivo
//   const r = await t114Medir();                           // pulsa, elige, espera la rejilla
//   JSON.stringify(r)
// Para una repetición «sin perfil»: await t114Limpiar(); y navegar de nuevo.
(() => {
  const t114 = (window.t114 = window.t114 || { marcas: [], origen: performance.timeOrigin });

  const marca = (evento, extra = {}) => {
    const m = { evento, t: performance.now(), ...extra };
    t114.marcas.push(m);
    return m;
  };

  const nodosConTexto = (patron) =>
    Array.from(document.querySelectorAll('flt-semantics, [aria-label], [role]'))
      .filter((n) => patron.test(n.getAttribute('aria-label') || n.textContent || ''));

  // El primer cuadro del motor: el lienzo dentro de flt-glass-pane (Flutter 3.38).
  const hayPrimerCuadro = () => {
    const vidrio = document.querySelector('flt-glass-pane');
    const sombra = vidrio && vidrio.shadowRoot;
    return !!(sombra && sombra.querySelector('flt-scene canvas, flt-scene-host canvas'));
  };

  const esperarCuadros = (condicion, limiteMs) =>
    new Promise((resolver, rechazar) => {
      const inicio = performance.now();
      const mirar = () => {
        if (condicion()) return resolver(performance.now());
        if (performance.now() - inicio > limiteMs) return rechazar(new Error('espera agotada'));
        requestAnimationFrame(mirar);
      };
      mirar();
    });

  // Espera el primer cuadro y activa la semántica de Flutter: sin ella no hay
  // nodos que leer ni botones que pulsar. El marcador se pulsa solo cuando el
  // motor ya pintó; si el árbol no llega, un `resize` le pide otro cuadro.
  window.t114Esperar = async (limiteMs = 60000) => {
    const t = await esperarCuadros(hayPrimerCuadro, limiteMs);
    if (!t114.primerCuadro) t114.primerCuadro = marca('primer cuadro del motor (lienzo observado)', { desdeNavegacionMs: t });
    for (let intento = 1; intento <= 8 && document.querySelectorAll('flt-semantics').length === 0; intento += 1) {
      const marcador = document.querySelector('flt-semantics-placeholder');
      if (marcador) {
        marcador.click();
        marca('semantica activada (acción del instrumento, no del producto)', { intento });
      } else {
        window.dispatchEvent(new Event('resize'));
      }
      await esperarCuadros(() => document.querySelectorAll('flt-semantics').length > 0, 1500).catch(() => null);
    }
    await esperarCuadros(() => nodosConTexto(/^Seleccionar archivo$/).length > 0, limiteMs);
    return { primerCuadroS: +(t114.primerCuadro.t / 1000).toFixed(3), semanticos: document.querySelectorAll('flt-semantics').length };
  };

  window.t114Preparar = async (rutaDelArchivo) => {
    const respuesta = await fetch(rutaDelArchivo, { cache: 'no-store' });
    if (!respuesta.ok) throw new Error(`No se pudo leer ${rutaDelArchivo}: ${respuesta.status}`);
    const bytes = await respuesta.arrayBuffer();
    const nombre = rutaDelArchivo.split('/').pop();
    t114.archivo = new File([bytes], nombre, { type: 'application/octet-stream' });
    if (!t114.interceptado) {
      const original = HTMLInputElement.prototype.click;
      HTMLInputElement.prototype.click = function () {
        if (this.type !== 'file') return original.call(this);
        marca('3 selector abierto (interceptado por el navegador)');
        const dt = new DataTransfer();
        dt.items.add(t114.archivo);
        this.files = dt.files;
        this.dispatchEvent(new Event('change', { bubbles: true }));
        marca('3 archivo elegido', { archivo: t114.archivo.name, bytes: t114.archivo.size });
      };
      t114.interceptado = true;
    }
    if (document.querySelectorAll('flt-semantics').length === 0) await window.t114Esperar();
    return { archivo: nombre, bytes: bytes.byteLength, origen: t114.origen };
  };

  window.t114Medir = (limiteMs = 60000) =>
    new Promise((resolver, rechazar) => {
      const boton = nodosConTexto(/^Seleccionar archivo$/)[0];
      if (!boton) return rechazar(new Error('No está «Seleccionar archivo» en la semántica.'));
      marca('1 app abierta: navegación', { desdeOrigenMs: performance.now() });
      marca('2 pulsar «Seleccionar archivo»');
      boton.click();
      const inicio = performance.now();
      let cuadros = 0;
      const mirar = () => {
        cuadros += 1;
        const ahora = performance.now();
        const bahia = nodosConTexto(/BAH[IÍ]A|Bah[ií]a/)[0];
        if (bahia) {
          const fin = marca('fin: rejilla en la semántica', {
            cuadrosMuestreados: cuadros,
            texto: (bahia.getAttribute('aria-label') || bahia.textContent || '').slice(0, 40),
            previo: nodosConTexto(/Plano sin confirmar|confirma la escala|confirma el buque/).length > 0,
            parametrosAbiertos: nodosConTexto(/Parámetros del buque/).length > 0,
          });
          // El inicio a la vista es el primer cuadro pintado tras la navegación:
          // first-contentful-paint cuando el navegador lo registra (no lo hace si
          // la pestaña estaba oculta) y, si no, el lienzo que observó t114Esperar.
          // El total es ese más el del clic a la rejilla, sin el tiempo de
          // reacción de la persona, como en Windows.
          const fcp = (performance.getEntriesByName('first-contentful-paint')[0] || {}).startTime;
          const primero = fcp !== undefined ? fcp : (t114.primerCuadro || {}).t;
          return resolver({
            pasosDelProducto: 3,
            primerCuadroDesdeNavegacionS: primero === undefined ? null : +(primero / 1000).toFixed(3),
            origenDelPrimerCuadro: fcp !== undefined ? 'first-contentful-paint' : 'lienzo observado por el instrumento',
            tiempoDesdeElClicS: +((fin.t - inicio) / 1000).toFixed(3),
            tiempoHastaRejillaS: primero === undefined ? null : +((primero + (fin.t - inicio)) / 1000).toFixed(3),
            tiempoHastaRejillaDesdeNavegacionConInstrumentoS: +(fin.t / 1000).toFixed(3),
            incertidumbreS: +(cuadros > 1 ? ((fin.t - inicio) / cuadros / 1000).toFixed(3) : 0),
            marcas: t114.marcas,
          });
        }
        if (ahora - inicio > limiteMs) return rechazar(new Error('Sin rejilla en el límite.'));
        requestAnimationFrame(mirar);
      };
      requestAnimationFrame(mirar);
    });

  window.t114Limpiar = async () => {
    const bases = (await indexedDB.databases()).map((b) => b.name).filter(Boolean);
    await Promise.all(bases.map((nombre) => new Promise((ok) => {
      const peticion = indexedDB.deleteDatabase(nombre);
      peticion.onsuccess = peticion.onerror = peticion.onblocked = () => ok();
    })));
    localStorage.clear();
    return bases;
  };
})();
