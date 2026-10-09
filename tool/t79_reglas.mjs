// T-79 · Batería de las reglas propuestas (T-79a 5.4 y 7.2) contra el
// emulador local de Firestore. Ningún proyecto en la nube: solo `demo-*`.
//
// Uso, con el emulador ya corriendo (Firestore en 127.0.0.1:8181):
//
//     node tool/t79_reglas.mjs [puerto] [proyecto-demo]
//
// Carga en el emulador el archivo docs/T79a-firestore.rules.propuesta tal
// cual, borra los datos del emulador y prueba cada caso por la API REST, con
// tokens sin firmar como los que acepta el emulador. Las escrituras replican
// `set()` del SDK, con la hora del servidor como transformación.
// Sale con código 1 si algún caso no da lo esperado. Con T79_DETALLE=1
// muestra el motivo que da el emulador a cada denegación.

import { randomUUID } from 'node:crypto';
import { readFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const port = Number(process.argv[2] ?? 8181);
const project = process.argv[3] ?? 'demo-t79';
if (!project.startsWith('demo-')) {
  console.error('Solo se prueba contra un proyecto demo- del emulador.');
  process.exit(2);
}
const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const rulesFile = join(root, 'docs', 'T79a-firestore.rules.propuesta');
const host = `http://127.0.0.1:${port}`;
const dbPath = `projects/${project}/databases/(default)/documents`;
const base = `${host}/v1/${dbPath}`;

// ------------------------------------------------------------ identidades
const DOCK = 'uid-muelle-t79';
const OFFICE = 'uid-oficina-t79';
const INACTIVE = 'uid-inactivo-t79';
const STRANGER = 'uid-sin-lista-t79';

const b64 = (o) => Buffer.from(JSON.stringify(o)).toString('base64url');
function token(uid) {
  const now = Math.floor(Date.now() / 1000);
  return `${b64({ alg: 'none', typ: 'JWT' })}.${b64({
    iss: `https://securetoken.google.com/${project}`, aud: project,
    auth_time: now, iat: now, exp: now + 3600, sub: uid, user_id: uid,
    firebase: { sign_in_provider: 'password', identities: {} },
  })}.`;
}
const auth = (uid) => (uid === 'owner' ? 'Bearer owner' : uid ? `Bearer ${token(uid)}` : null);

// ------------------------------------------------------- valores de Firestore
const ts = (date) => ({ __ts: date.toISOString() });
const dbl = (n) => ({ __double: n });
function value(v) {
  if (v === null) return { nullValue: null };
  if (v?.__ts) return { timestampValue: v.__ts };
  if (v?.__double !== undefined) return { doubleValue: v.__double };
  if (typeof v === 'string') return { stringValue: v };
  if (typeof v === 'boolean') return { booleanValue: v };
  if (typeof v === 'number') return Number.isInteger(v) ? { integerValue: String(v) } : { doubleValue: v };
  if (Array.isArray(v)) return { arrayValue: { values: v.map(value) } };
  return { mapValue: { fields: fields(v) } };
}
const fields = (o) => Object.fromEntries(Object.entries(o).map(([k, v]) => [k, value(v)]));

// --------------------------------------------------------------- peticiones
async function call(method, url, uid, body) {
  const headers = { 'Content-Type': 'application/json' };
  const a = auth(uid);
  if (a) headers.Authorization = a;
  const res = await fetch(url, { method, headers, body: body ? JSON.stringify(body) : undefined });
  const text = await res.text();
  return { ok: res.ok, status: res.status, text };
}

// Un lote como `commit` del SDK. Cada escritura: {path, data, server: [campos],
// mask: [campos]} o {delete: path}.
function commit(uid, writes) {
  return call('POST', `${base}:commit`, uid, {
    writes: writes.map((w) => {
      if (w.delete) return { delete: `${dbPath}/${w.delete}` };
      const write = { update: { name: `${dbPath}/${w.path}`, fields: fields(w.data) } };
      if (w.mask) write.updateMask = { fieldPaths: w.mask };
      if (w.server?.length) {
        write.updateTransforms = w.server.map((f) => ({ fieldPath: f, setToServerValue: 'REQUEST_TIME' }));
      }
      return write;
    }),
  });
}
const get = (uid, path) => call('GET', `${base}/${path}`, uid);

// ------------------------------------------------------------- documentos
const opId = randomUUID();
const deviceId = randomUUID();
let sequence = 0;
const sha = 'a'.repeat(64);

function operationDoc(uid, extra = {}) {
  return {
    path: `operations/${opId}`,
    data: {
      id: opId, schema: 1, vessel: 'BUQUE PRUEBA', voyage: 'V-T79', portOfCall: 'GTSTC',
      status: 'open', createdBy: uid, profile: { vesselName: 'BUQUE PRUEBA' },
      sources: { loading_baplie: { fileName: 'plan.edi', sha256: sha, parts: 1 } },
      ...extra,
    },
    server: ['createdAt'],
  };
}
function sourceDoc(uid, op = opId, id = 'loading_baplie-0', extra = {}) {
  return {
    path: `operations/${op}/sources/${id}`,
    data: { id, kind: 'loading_baplie', sha256: sha, part: 0, parts: 1, content: 'UNB+UNOA', createdBy: uid, ...extra },
    server: ['createdAt'],
  };
}

const role = { [DOCK]: 'dock', [OFFICE]: 'office', [INACTIVE]: 'dock', [STRANGER]: 'dock' };
const names = { [DOCK]: 'Muelle', [OFFICE]: 'Oficina', [INACTIVE]: 'Inactivo', [STRANGER]: 'Nadie' };

function movement(uid, type, target, payload, extra = {}) {
  const id = extra.id ?? randomUUID();
  const data = {
    id, schema: 1, operationId: opId, type, target, payload,
    author: { uid, name: names[uid], role: role[uid] },
    deviceId, sequence: ++sequence, createdAt: ts(new Date()),
    ...extra.data,
  };
  delete data.__drop;
  for (const k of extra.drop ?? []) delete data[k];
  return { id, path: `operations/${extra.op ?? opId}/movements/${extra.docId ?? id}`, data, server: extra.noServer ? [] : ['receivedAt'] };
}
const loadFull = (uid, container = 'TSTU0000001', extra = {}) =>
  movement(uid, 'load_full', `C:${container}`, { position: '0140102', order: 1, operatedAt: ts(new Date()), ...extra.payload }, extra);

// ------------------------------------------------------------------ batería
const results = [];
async function expect(group, name, allowed, request) {
  const res = await request;
  const pass = res.ok === allowed;
  results.push({ group, name, allowed, got: res.ok, pass, status: res.status });
  console.log(`${pass ? 'PASA ' : 'FALLA'} · ${group} · ${name} · esperado ${allowed ? 'permitido' : 'denegado'}, ${res.ok ? 'permitido' : `denegado (${res.status})`}`);
  // Con T79_DETALLE=1, el motivo que da el emulador a cada denegación.
  if (process.env.T79_DETALLE && !res.ok) {
    const limit = res.text.includes('maximum of 1000 expressions') ? ' [LÍMITE DE 1000 EXPRESIONES]' : '';
    console.log(`        ${limit} ${res.text.replace(/\s+/g, ' ').slice(0, 220)}`);
  }
  if (!pass && !res.ok) console.log(`        ${res.text.slice(0, 300).replace(/\s+/g, ' ')}`);
}

async function main() {
  const rules = readFileSync(rulesFile, 'utf8');
  const loaded = await call('PUT', `${host}/emulator/v1/projects/${project}:securityRules`, null,
    { rules: { files: [{ name: 'firestore.rules', content: rules }] } });
  if (!loaded.ok) throw new Error(`No se cargaron las reglas: ${loaded.status} ${loaded.text}`);
  await call('DELETE', `${host}/emulator/v1/projects/${project}/databases/(default)/documents`, null);

  // Lista de autorizados: la escribe «la consola» (el emulador, sin reglas).
  const seeded = await commit('owner', [
    { path: `authorized/${DOCK}`, data: { role: 'dock', name: 'Muelle', active: true } },
    { path: `authorized/${OFFICE}`, data: { role: 'office', name: 'Oficina', active: true } },
    { path: `authorized/${INACTIVE}`, data: { role: 'dock', name: 'Inactivo', active: false } },
    { path: 'voyages/x', data: { id: 'x' } },
    { path: 'latency_test/x', data: { id: 'x' } },
  ]);
  if (!seeded.ok) throw new Error(`No se sembró la lista: ${seeded.text}`);

  // A · Operación y fuentes (5)
  await expect('Operación y fuentes', 'el muelle no crea operaciones', false,
    commit(DOCK, [operationDoc(DOCK), sourceDoc(DOCK)]));
  await expect('Operación y fuentes', 'una operación con el puerto mal escrito, no', false,
    commit(OFFICE, [operationDoc(OFFICE, { portOfCall: 'gt stc' }), sourceDoc(OFFICE)]));
  await expect('Operación y fuentes', 'la oficina crea operación y fuente en un lote', true,
    commit(OFFICE, [operationDoc(OFFICE), sourceDoc(OFFICE)]));
  await expect('Operación y fuentes', 'una fuente no se modifica', false,
    commit(OFFICE, [sourceDoc(OFFICE, opId, 'loading_baplie-0', { content: 'OTRO' })]));
  await expect('Operación y fuentes', 'la operación no se borra', false,
    commit(OFFICE, [{ delete: `operations/${opId}` }]));

  // B · Lectura (9)
  await expect('Lectura', 'sin sesión no lee', false, get(null, `operations/${opId}`));
  await expect('Lectura', 'sin estar en la lista no lee', false, get(STRANGER, `operations/${opId}`));
  await expect('Lectura', 'inactivo no lee', false, get(INACTIVE, `operations/${opId}`));
  await expect('Lectura', 'el muelle lee la operación', true, get(DOCK, `operations/${opId}`));
  await expect('Lectura', 'el muelle lee las fuentes', true, get(DOCK, `operations/${opId}/sources`));
  await expect('Lectura', 'cada uno lee su registro de autorizado', true, get(DOCK, `authorized/${DOCK}`));
  await expect('Lectura', 'no lee el registro de otro', false, get(DOCK, `authorized/${OFFICE}`));
  await expect('Lectura', 'voyages, cerrada', false, get(OFFICE, 'voyages/x'));
  await expect('Lectura', 'latency_test, cerrada', false, get(OFFICE, 'latency_test/x'));

  // C · Movimientos del muelle (20)
  const first = loadFull(DOCK);
  await expect('Muelle', 'confirmar un lleno', true, commit(DOCK, [first]));
  await expect('Muelle', 'reenvío idéntico (no duplica)', true, commit(DOCK, [first]));
  await expect('Muelle', 'reenvío con otro contenido', false,
    commit(DOCK, [{ ...first, data: { ...first.data, payload: { ...first.data.payload, order: 2 } } }]));
  await expect('Muelle', 'borrar un movimiento', false, commit(DOCK, [{ delete: first.path }]));
  await expect('Muelle', 'reenviar el de otro', false, commit(OFFICE, [first]));
  await expect('Muelle', 'firmar como otro', false,
    commit(DOCK, [loadFull(DOCK, 'TSTU0000002', { data: { author: { uid: OFFICE, name: 'Muelle', role: 'dock' } } })]));
  await expect('Muelle', 'declarar otro rol', false,
    commit(DOCK, [loadFull(DOCK, 'TSTU0000002', { data: { author: { uid: DOCK, name: 'Muelle', role: 'office' } } })]));
  await expect('Muelle', 'id distinto del documento', false,
    commit(DOCK, [loadFull(DOCK, 'TSTU0000002', { docId: randomUUID() })]));
  await expect('Muelle', 'campos de más', false,
    commit(DOCK, [loadFull(DOCK, 'TSTU0000002', { data: { extra: true } })]));
  await expect('Muelle', 'tipo desconocido', false,
    commit(DOCK, [movement(DOCK, 'teleport', 'C:TSTU0000002', { position: '0140102' })]));
  await expect('Muelle', 'hora una hora en el futuro', false,
    commit(DOCK, [loadFull(DOCK, 'TSTU0000002', { data: { createdAt: ts(new Date(Date.now() + 3600e3)) } })]));
  await expect('Muelle', 'tara negativa', false,
    commit(DOCK, [movement(DOCK, 'assign_empty', 'R:0030984', { container: 'TSTU0000012', tareKg: dbl(-2185) })]));
  await expect('Muelle', 'seis horas sin red', true,
    commit(DOCK, [loadFull(DOCK, 'TSTU0000003', { data: { createdAt: ts(new Date(Date.now() - 6 * 3600e3)) } })]));
  await expect('Muelle', 'ocho días sin red, no', false,
    commit(DOCK, [loadFull(DOCK, 'TSTU0000004', { data: { createdAt: ts(new Date(Date.now() - 8 * 86400e3)) } })]));
  await expect('Muelle', 'descarga', true,
    commit(DOCK, [movement(DOCK, 'discharge', 'C:TSTU0000005', { position: '0140184', restow: false })]));
  await expect('Muelle', 'vacío asignado a su reserva', true,
    commit(DOCK, [movement(DOCK, 'assign_empty', 'R:0030984', { container: 'TSTU0000012', tareKg: dbl(2185.5), order: 12 })]));
  await expect('Muelle', 'tapa', true,
    commit(DOCK, [movement(DOCK, 'hatch_cover', 'T:14-1', { action: 'remove' })]));
  await expect('Muelle', 'corrección con corrects', true,
    commit(DOCK, [loadFull(DOCK, 'TSTU0000001', { payload: { corrects: first.id, seal: 'S-2' } })]));
  await expect('Muelle', 'sin la hora del servidor', false,
    commit(DOCK, [loadFull(DOCK, 'TSTU0000006', { noServer: true, data: { receivedAt: ts(new Date()) } })]));
  await expect('Muelle', 'otra operación en el documento', false,
    commit(DOCK, [loadFull(DOCK, 'TSTU0000006', { data: { operationId: randomUUID() } })]));

  // D · Cambio de posición, T-80 (6)
  const change = [{ target: 'C:XQDU0060080', from: '0140102', to: '0140108' },
    { target: 'C:XRFU2642829', from: '0140108', to: '0140102' }];
  const request = movement(DOCK, 'request_change', null, { changes: change, reason: 'Intercambio' });
  await expect('Cambio de posición', 'el muelle pide', true, commit(DOCK, [request]));
  await expect('Cambio de posición', 'el muelle no aprueba', false,
    commit(DOCK, [movement(DOCK, 'change_position', null, { changes: change, request: request.id, reason: 'Sí' })]));
  await expect('Cambio de posición', 'la oficina aprueba', true,
    commit(OFFICE, [movement(OFFICE, 'change_position', null, { changes: change, request: request.id, reason: 'Aprobado' })]));
  await expect('Cambio de posición', 'la oficina rechaza', true,
    commit(OFFICE, [movement(OFFICE, 'reject_change', null, { request: randomUUID(), reason: 'No' })]));
  await expect('Cambio de posición', 'el muelle no cancela', false,
    commit(DOCK, [movement(DOCK, 'cancel_item', 'C:TSTU0000007', { reason: 'No embarca' })]));
  const cancel = movement(OFFICE, 'cancel_item', 'C:TSTU0000007', { reason: 'No embarca' });
  await expect('Cambio de posición', 'la oficina cancela', true, commit(OFFICE, [cancel]));

  // E · Anular (5)
  await expect('Anular', 'el muelle anula lo del muelle', true,
    commit(DOCK, [movement(DOCK, 'annul', first.data.target, { annuls: first.id, reason: 'Marcado por error' })]));
  await expect('Anular', 'el muelle no anula lo de la oficina', false,
    commit(DOCK, [movement(DOCK, 'annul', cancel.data.target, { annuls: cancel.id, reason: 'No' })]));
  await expect('Anular', 'el muelle no anula algo inexistente', false,
    commit(DOCK, [movement(DOCK, 'annul', null, { annuls: randomUUID(), reason: 'No' })]));
  await expect('Anular', 'la oficina anula lo suyo', true,
    commit(OFFICE, [movement(OFFICE, 'annul', cancel.data.target, { annuls: cancel.id, reason: 'Sí embarca' })]));
  await expect('Anular', 'sin motivo, no', false,
    commit(OFFICE, [movement(OFFICE, 'annul', null, { annuls: cancel.id, reason: '' })]));

  // F · Cierre (6)
  await expect('Cierre', 'el muelle no cierra', false,
    commit(DOCK, [{ path: `operations/${opId}`, data: { status: 'closed', closedBy: DOCK }, mask: ['status', 'closedBy', 'closedAt'], server: ['closedAt'] }]));
  const beforeClose = new Date(Date.now() - 60e3);
  await expect('Cierre', 'la oficina cierra', true,
    commit(OFFICE, [{ path: `operations/${opId}`, data: { status: 'closed', closedBy: OFFICE }, mask: ['status', 'closedBy', 'closedAt'], server: ['closedAt'] }]));
  await expect('Cierre', 'la oficina no reabre', false,
    commit(OFFICE, [{ path: `operations/${opId}`, data: { status: 'open' }, mask: ['status'] }]));
  await expect('Cierre', 'un movimiento nuevo tras el cierre, no', false,
    commit(DOCK, [loadFull(DOCK, 'TSTU0000008', { data: { createdAt: ts(new Date(Date.now() + 2000)) } })]));
  await expect('Cierre', 'uno sin red anterior al cierre, sí', true,
    commit(DOCK, [loadFull(DOCK, 'TSTU0000009', { data: { createdAt: ts(beforeClose) } })]));
  await expect('Cierre', 'una fuente nueva en una operación cerrada, no', false,
    commit(OFFICE, [sourceDoc(OFFICE, opId, 'export_list-0', { kind: 'export_list' })]));

  // G · T-79 (3): lo que la app de T-79 envía y lo que no debe pasar.
  await expect('T-79', 'una cuenta inactiva no escribe (la app pausa, no rechaza)', false,
    commit(INACTIVE, [loadFull(INACTIVE, 'TSTU0000010', { data: { createdAt: ts(beforeClose) } })]));
  await expect('T-79', 'operatedAt como texto, no: la app lo manda como Timestamp', false,
    commit(DOCK, [loadFull(DOCK, 'TSTU0000011', { payload: { operatedAt: new Date().toISOString() }, data: { createdAt: ts(beforeClose) } })]));
  const op2 = randomUUID();
  await expect('T-79', 'la huella de una fuente es hexadecimal de 64', false,
    commit(OFFICE, [{ ...operationDoc(OFFICE), path: `operations/${op2}`, data: { ...operationDoc(OFFICE).data, id: op2 } },
      sourceDoc(OFFICE, op2, 'loading_baplie-0', { sha256: 'no-es-una-huella' })]));

  // Documentos que quedaron: uno por cada movimiento permitido.
  const list = await call('GET', `${base}/operations/${opId}/movements?pageSize=300`, 'owner');
  const docs = JSON.parse(list.text).documents ?? [];
  const expectedDocs = 13;
  const docsPass = docs.length === expectedDocs;
  console.log(`${docsPass ? 'PASA ' : 'FALLA'} · subcolección movements: ${docs.length} documentos (esperados ${expectedDocs}); el reenvío idéntico no creó otro`);

  const passed = results.filter((r) => r.pass).length;
  console.log(`\nResultado: ${passed} de ${results.length} casos dieron lo esperado` +
    ` · reglas: ${rulesFile.replace(root, '.')} · emulador ${host} · proyecto ${project}`);
  process.exit(passed === results.length && docsPass ? 0 : 1);
}

main().catch((error) => { console.error(error); process.exit(1); });
