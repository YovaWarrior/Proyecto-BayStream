// T-113 · Casos de abuso que la batería de T-80 no cubre, contra las mismas
// reglas (docs/T80-firestore.rules.propuesta), en el emulador local de
// Firestore. Ningún proyecto en la nube: solo `demo-*`.
//
// Lo que añade a tool/t80_reglas.mjs:
//   - escalada de rol: escribir en authorized/ (crearse, cambiarse el rol,
//     listar, borrar a otro);
//   - suplantación en operaciones: crear a nombre de otro, cambiar campos al
//     cerrar, crear sin estar en la lista;
//   - el cambio directo de la oficina sin solicitud (T-81), que el código usa
//     y la batería de T-80 solo prueba con `request`;
//   - anular entre roles, movimientos en una operación que no existe,
//     escrituras sin sesión y en colecciones no declaradas.
//
// Uso, con el emulador corriendo (tool/t113_emulador.ps1):
//
//     node tool/t113_reglas_abuso.mjs [puerto] [proyecto-demo]
//
// Borra los datos del emulador al empezar. Sale con 1 si un caso no da lo
// esperado. Con T113_DETALLE=1 muestra el motivo de cada denegación.

import { randomUUID } from 'node:crypto';
import { readFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const port = Number(process.argv[2] ?? 8181);
const project = process.argv[3] ?? 'demo-t113';
if (!project.startsWith('demo-')) {
  console.error('Solo se prueba contra un proyecto demo- del emulador.');
  process.exit(2);
}
const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const rulesFile = join(root, 'docs', 'T80-firestore.rules.propuesta');
const host = `http://127.0.0.1:${port}`;
const dbPath = `projects/${project}/databases/(default)/documents`;
const base = `${host}/v1/${dbPath}`;

const DOCK = 'uid-muelle-t113';
const OFFICE = 'uid-oficina-t113';
const STRANGER = 'uid-sin-lista-t113';

// Tokens sin firmar, como los que acepta el emulador (igual que T-80).
const b64 = (o) => Buffer.from(JSON.stringify(o)).toString('base64url');
function token(uid, claims = {}) {
  const now = Math.floor(Date.now() / 1000);
  return `${b64({ alg: 'none', typ: 'JWT' })}.${b64({
    iss: `https://securetoken.google.com/${project}`, aud: project,
    auth_time: now, iat: now, exp: now + 3600, sub: uid, user_id: uid,
    firebase: { sign_in_provider: 'password', identities: {} }, ...claims,
  })}.`;
}

const ts = (date) => ({ __ts: date.toISOString() });
function value(v) {
  if (v === null) return { nullValue: null };
  if (v?.__ts) return { timestampValue: v.__ts };
  if (typeof v === 'string') return { stringValue: v };
  if (typeof v === 'boolean') return { booleanValue: v };
  if (typeof v === 'number') return Number.isInteger(v) ? { integerValue: String(v) } : { doubleValue: v };
  if (Array.isArray(v)) return { arrayValue: { values: v.map(value) } };
  return { mapValue: { fields: fields(v) } };
}
const fields = (o) => Object.fromEntries(Object.entries(o).map(([k, v]) => [k, value(v)]));

async function call(method, url, who, body) {
  const headers = { 'Content-Type': 'application/json' };
  if (who === 'owner') headers.Authorization = 'Bearer owner';
  else if (who?.uid) headers.Authorization = `Bearer ${token(who.uid, who.claims)}`;
  else if (who) headers.Authorization = `Bearer ${token(who)}`;
  const res = await fetch(url, { method, headers, body: body ? JSON.stringify(body) : undefined });
  return { ok: res.ok, status: res.status, text: await res.text() };
}
function commit(who, writes) {
  return call('POST', `${base}:commit`, who, {
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
const get = (who, path) => call('GET', `${base}/${path}`, who);

const sha = 'b'.repeat(64);
function operationDoc(uid, id, extra = {}) {
  return {
    path: `operations/${id}`,
    data: {
      id, schema: 1, vessel: 'BUQUE T113', voyage: 'V-T113', portOfCall: 'GTSTC',
      status: 'open', createdBy: uid, profile: { vesselName: 'BUQUE T113' },
      sources: { loading_baplie: { fileName: 'plan.edi', sha256: sha, parts: 1 } },
      ...extra,
    },
    server: ['createdAt'],
  };
}
function sourceDoc(uid, op, extra = {}) {
  const id = 'loading_baplie-0';
  return {
    path: `operations/${op}/sources/${id}`,
    data: { id, kind: 'loading_baplie', sha256: sha, part: 0, parts: 1, content: 'UNB+UNOA', createdBy: uid, ...extra },
    server: ['createdAt'],
  };
}

const role = { [DOCK]: 'dock', [OFFICE]: 'office', [STRANGER]: 'office' };
const names = { [DOCK]: 'Muelle', [OFFICE]: 'Oficina', [STRANGER]: 'Nadie' };
const deviceId = randomUUID();
let sequence = 0;
function movement(uid, op, type, target, payload) {
  const id = randomUUID();
  return {
    id,
    path: `operations/${op}/movements/${id}`,
    data: {
      id, schema: 1, operationId: op, type, target, payload,
      author: { uid, name: names[uid], role: role[uid] },
      deviceId, sequence: ++sequence, createdAt: ts(new Date()),
    },
    server: ['receivedAt'],
  };
}
const change = [{ target: 'C:TSTU1130001', from: '0140102', to: '0140104' }];

const results = [];
async function expect(group, name, allowed, request) {
  const res = await request;
  const pass = res.ok === allowed;
  results.push({ group, name, allowed, got: res.ok, pass, status: res.status });
  console.log(`${pass ? 'PASA ' : 'FALLA'} · ${group} · ${name} · esperado ${allowed ? 'permitido' : 'denegado'}, ${res.ok ? 'permitido' : `denegado (${res.status})`}`);
  if ((process.env.T113_DETALLE && !res.ok) || (!pass && !res.ok)) {
    console.log(`        ${res.text.replace(/\s+/g, ' ').slice(0, 240)}`);
  }
}

async function main() {
  const rules = readFileSync(rulesFile, 'utf8');
  const loaded = await call('PUT', `${host}/emulator/v1/projects/${project}:securityRules`, null,
    { rules: { files: [{ name: 'firestore.rules', content: rules }] } });
  if (!loaded.ok) throw new Error(`No se cargaron las reglas: ${loaded.status} ${loaded.text}`);
  await call('DELETE', `${host}/emulator/v1/projects/${project}/databases/(default)/documents`, null);

  const op = randomUUID();
  const seeded = await commit('owner', [
    { path: `authorized/${DOCK}`, data: { role: 'dock', name: 'Muelle', active: true } },
    { path: `authorized/${OFFICE}`, data: { role: 'office', name: 'Oficina', active: true } },
  ]);
  if (!seeded.ok) throw new Error(`No se sembró la lista: ${seeded.text}`);
  const created = await commit(OFFICE, [operationDoc(OFFICE, op), sourceDoc(OFFICE, op)]);
  if (!created.ok) throw new Error(`No se creó la operación base: ${created.text}`);

  // A · Escalada sobre la lista de autorizados (6)
  await expect('Escalada', 'el muelle se cambia el rol a oficina', false,
    commit(DOCK, [{ path: `authorized/${DOCK}`, data: { role: 'office' }, mask: ['role'] }]));
  await expect('Escalada', 'el muelle reescribe su registro entero', false,
    commit(DOCK, [{ path: `authorized/${DOCK}`, data: { role: 'office', name: 'Muelle', active: true } }]));
  await expect('Escalada', 'una cuenta fuera de la lista se da de alta', false,
    commit(STRANGER, [{ path: `authorized/${STRANGER}`, data: { role: 'office', name: 'Nadie', active: true } }]));
  await expect('Escalada', 'la oficina da de alta a otra cuenta', false,
    commit(OFFICE, [{ path: `authorized/${STRANGER}`, data: { role: 'dock', name: 'Nadie', active: true } }]));
  await expect('Escalada', 'la oficina borra al muelle de la lista', false,
    commit(OFFICE, [{ delete: `authorized/${DOCK}` }]));
  await expect('Escalada', 'el muelle lista toda la colección', false,
    get(DOCK, 'authorized'));

  // B · Un rol en el token no cuenta: el rol sale de authorized/{uid} (1)
  await expect('Escalada', 'un token con rol «office» no convierte al muelle en oficina', false,
    commit({ uid: DOCK, claims: { role: 'office', admin: true } }, [operationDoc(DOCK, randomUUID())]));

  // C · Operaciones y fuentes (6)
  const op2 = randomUUID();
  await expect('Operación', 'una cuenta fuera de la lista no crea', false,
    commit(STRANGER, [operationDoc(STRANGER, op2), sourceDoc(STRANGER, op2)]));
  await expect('Operación', 'la oficina no crea a nombre del muelle', false,
    commit(OFFICE, [operationDoc(DOCK, op2), sourceDoc(OFFICE, op2)]));
  await expect('Operación', 'la oficina no cambia el buque al editar', false,
    commit(OFFICE, [{ path: `operations/${op}`, data: { vessel: 'OTRO' }, mask: ['vessel'] }]));
  await expect('Operación', 'al cerrar no se cuela otro campo', false,
    commit(OFFICE, [{ path: `operations/${op}`, data: { status: 'closed', closedBy: OFFICE, vessel: 'OTRO' }, mask: ['status', 'closedBy', 'closedAt', 'vessel'], server: ['closedAt'] }]));
  await expect('Operación', 'el muelle no escribe una fuente', false,
    commit(DOCK, [sourceDoc(DOCK, op, { kind: 'export_list' })]));
  await expect('Operación', 'la oficina no borra una fuente', false,
    commit(OFFICE, [{ delete: `operations/${op}/sources/loading_baplie-0` }]));

  // D · Movimientos (10)
  const direct = movement(OFFICE, op, 'change_position', null, { changes: change, reason: 'Cambio de la oficina' });
  await expect('Movimiento', 'T-81: la oficina cambia el plan sin solicitud', true, commit(OFFICE, [direct]));
  await expect('Movimiento', 'el muelle no cambia el plan sin solicitud', false,
    commit(DOCK, [movement(DOCK, op, 'change_position', null, { changes: change, reason: 'Por mi cuenta' })]));
  await expect('Movimiento', 'el muelle no anula un cambio de la oficina', false,
    commit(DOCK, [movement(DOCK, op, 'annul', null, { annuls: direct.id, reason: 'No me gusta' })]));
  const dockLoad = movement(DOCK, op, 'load_full', 'C:TSTU1130002', { position: '0140106' });
  await expect('Movimiento', 'el muelle confirma un lleno', true, commit(DOCK, [dockLoad]));
  await expect('Movimiento', 'la oficina anula un movimiento del muelle', true,
    commit(OFFICE, [movement(OFFICE, op, 'annul', dockLoad.data.target, { annuls: dockLoad.id, reason: 'Mal marcado' })]));
  await expect('Movimiento', 'sin sesión no escribe', false,
    commit(null, [movement(DOCK, op, 'load_full', 'C:TSTU1130003', { position: '0140108' })]));
  const ghost = randomUUID();
  await expect('Movimiento', 'en una operación que no existe, no', false,
    commit(DOCK, [movement(DOCK, ghost, 'load_full', 'C:TSTU1130004', { position: '0140110' })]));
  await expect('Movimiento', 'un motivo de 301 caracteres, no', false,
    commit(OFFICE, [movement(OFFICE, op, 'cancel_item', 'C:TSTU1130005', { reason: 'x'.repeat(301) })]));
  await expect('Movimiento', 'una tapa con un campo de más, no', false,
    commit(DOCK, [movement(DOCK, op, 'hatch_cover', 'T:14-1', { action: 'remove', extra: 'x' })]));
  await expect('Movimiento', 'la oficina no edita un movimiento del muelle', false,
    commit(OFFICE, [{ path: dockLoad.path, data: { receivedAt: ts(new Date()) }, mask: ['receivedAt'] }]));

  // E · Lo no declarado, cerrado (2)
  await expect('Cerrado', 'la oficina no escribe en una colección inventada', false,
    commit(OFFICE, [{ path: 'users/x', data: { id: 'x' } }]));
  await expect('Cerrado', 'la oficina no lee una colección inventada', false, get(OFFICE, 'users/x'));

  const passed = results.filter((r) => r.pass).length;
  console.log(`\nResultado: ${passed} de ${results.length} casos dieron lo esperado` +
    ` · reglas: ${rulesFile.replace(root, '.')} · emulador ${host} · proyecto ${project}`);
  process.exit(passed === results.length ? 0 : 1);
}

main().catch((error) => { console.error(error); process.exit(1); });
