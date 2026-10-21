// Ejecutar solo desde cua_repl, con el tab y CDP documentados del IAB.
// No abre Chrome, cuentas ni un canal de control alternativo.
import * as fs from 'node:fs/promises';
import path from 'node:path';

const sleep = ms => new Promise(resolve => setTimeout(resolve, ms));

export async function grabarIab({tab, cdp, salida, accion, base}) {
  if (!/^[a-fA-F0-9]{40}$/.test(base ?? '')) {
    throw new Error('Declarar SHA completo del cierre que produjo la Web.');
  }
  const inicio = await tab.url();
  if (!['http://127.0.0.1:5898/',
    'http://127.0.0.1:5898/t98-inicio.html'].includes(inicio)) {
    throw new Error('Solo el origen exclusivo de T98.');
  }
  const root = path.resolve(salida);
  if (!/[\\/]Temp[\\/]t98[^\\/]*[\\/]/i.test(root)) {
    throw new Error('La evidencia debe estar bajo TEMP/t98.');
  }
  const before = await tab.playwright.domSnapshot();
  if (/Iniciar sesión|Cerrar sesión|contraseña/i.test(before)) {
    throw new Error('No grabar cuentas.');
  }
  await fs.mkdir(path.dirname(root), {recursive: true});
  await fs.mkdir(root); // No sobrescribir una corrida.
  const resolved = await fs.realpath(root);
  if (!/[\\/]Temp[\\/]t98[^\\/]*[\\/]/i.test(resolved)) {
    throw new Error('Destino real fuera del banco temporal.');
  }
  const frames = [];
  const actions = [];
  const observations = [];
  let cursor = (await cdp.readEvents()).cursor;
  let running = true;
  let truncated = false;
  let firstResolve;
  const firstFrame = new Promise(resolve => {firstResolve = resolve;});
  const mark = (evento, extra = {}) => {
    const item = {evento, utcHostSoloTrazabilidad: new Date().toISOString(),
      cuadroRecibidoAnterior: frames.length - 1, ...extra};
    actions.push(item);
    return item;
  };
  await cdp.send('Page.enable');
  await cdp.send('Page.startScreencast', {format: 'jpeg', quality: 85,
    maxWidth: 1280, maxHeight: 960, everyNthFrame: 1});
  const pump = (async () => {
    while (true) {
      const batch = await cdp.readEvents({afterSequence: cursor,
        methods: ['Page.screencastFrame', 'Page.screencastVisibilityChanged',
          'Page.fileChooserOpened'], limit: 1000, timeoutMs: 100});
      cursor = batch.cursor;
      truncated ||= batch.truncated;
      for (const event of batch.events) {
        if (event.method === 'Page.screencastFrame') {
          const p = event.params;
          const name = `${String(frames.length).padStart(6, '0')}.jpg`;
          await fs.writeFile(path.join(root, name), Buffer.from(p.data, 'base64'));
          frames.push({archivo: name, secuenciaCdp: event.sequence,
            metadataOrigen: p.metadata,
            recibidoUtcSoloTrazabilidad: new Date().toISOString()});
          await cdp.send('Page.screencastFrameAck', {sessionId: p.sessionId});
          firstResolve();
        } else {
          observations.push({metodo: event.method, secuenciaCdp: event.sequence,
            modo: event.params?.mode, visible: event.params?.visible,
            cuadroRecibidoAnterior: frames.length - 1});
        }
      }
      if (!running && !batch.hasMore && batch.events.length === 0) break;
      if (batch.events.length === 0) await sleep(10);
    }
  })();
  let error = null;
  try {
    await Promise.race([firstFrame, sleep(5000).then(() => {
      throw new Error('No llego el primer cuadro; no iniciar el caso.');
    })]);
    await accion({mark, frames});
    await sleep(300);
  } catch (failure) {
    error = String(failure);
  } finally {
    running = false;
    await cdp.send('Page.stopScreencast');
    await pump;
    const times = frames.map(f => f.metadataOrigen.timestamp);
    const monotonic = times.every((t, i) => Number.isFinite(t) &&
      (i === 0 || t > times[i - 1]));
    const data = {fase: 'B', base,
      navegador: 'Integrado de Codex; autorizado por Carlos, decision 10.92',
      origen: 'http://127.0.0.1:5898/', paginaInicial: inicio,
      fuente: 'Page.screencastFrame',
      relojMedicion: 'metadata.timestamp del cuadro; host solo trazabilidad',
      error, truncado: truncated, ptsEstrictamenteCrecientes: monotonic,
      cuadros: frames, acciones: actions, observacionesCdp: observations,
      aviso: 'El selector interceptado no se dibuja en la pagina; su apertura '
        + 'se corrobora con el evento real de filechooser. No graba cuentas. '
        + 'Los cuadros son variables; no asumir 30/60 fps.'};
    await fs.writeFile(path.join(root, 'captura.json'), JSON.stringify(data, null, 2));
    if (error || truncated || !monotonic || frames.length < 2) {
      throw new Error('Captura no apta para dictamen; conservar y revisar captura.json.');
    }
  }
  return {cuadros: frames.length, segundosEntreCuadros:
    frames.at(-1).metadataOrigen.timestamp - frames[0].metadataOrigen.timestamp,
    acciones: actions.map(a => ({evento: a.evento,
      cuadroRecibidoAnterior: a.cuadroRecibidoAnterior})),
    archivo: path.join(root, 'captura.json')};
}
