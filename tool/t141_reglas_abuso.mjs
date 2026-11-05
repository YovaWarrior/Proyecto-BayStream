// T-141 · Casos de abuso sobre lo que T-130 abrió (agregar el plan que falta,
// sus trozos y el manifiesto), contra el TEXTO PUBLICADO de las reglas
// (build/t141/reglas-publicadas.txt), en el emulador local de Firestore.
// Sigue el patrón de tool/t113_reglas_abuso.mjs. Ningún proyecto en la nube:
// solo `demo-*`.
//
// Lo que añade a t130_reglas_plan.mjs, desde el ángulo del abuso:
//   - quién agrega: el muelle no; la oficina no a una operación cerrada, no
//     a nombre de otro;
//   - trozos y manifiesto: un trozo que el manifiesto no declara (huella o
//     número de partes que no son), y qué pasa con un manifiesto sin sus
//     trozos (la regla no lo puede exigir: se anota como permitido);
//   - revisión del listado: no borra ni reescribe la anterior, y la revisión
//     siempre sube;
//   - lectura: fuera de la lista (o inactiva) no lee la operación ni sus
//     fuentes; el muelle no lee el authorized ajeno;
//   - tras el cierre, ningún movimiento nuevo de ningún rol; el que se
//     registró sin red antes del cierre sí entra (límite declarado).
//
// Uso, con el emulador corriendo (tool/t113_emulador.ps1):
//
//     node tool/t141_reglas_abuso.mjs [puerto] [proyecto-demo] [reglas]
//
// Borra los datos del emulador al empezar. Sale con 1 si un caso no da lo
// esperado. Con T141_DETALLE=1 muestra el motivo de cada denegación (la línea
// de la regla en la que cae).

import { randomUUID } from 'node:crypto';
import { readFileSync } from 'node:fs';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const port = Number(process.argv[2] ?? 8383);
const project = process.argv[3] ?? 'demo-t141';
if (!project.startsWith('demo-')) {
  console.error('Solo se prueba contra un proyecto demo- del emulador.');
  process.exit(2);
}
const root = join(dirname(fileURLToPath(import.meta.url)), '..');
// T-141: por omisión, el texto publicado copiado de la consola.
const rulesFile = process.argv[4]
  ? resolve(process.argv[4])
  : join(root, 'build', 't141', 'reglas-publicadas.txt');
const host = `http://127.0.0.1:${port}`;
const dbPath = `projects/${project}/databases/(default)/documents`;
const base = `${host}/v1/${dbPath}`;

const DOCK = 'uid-muelle-t141';
const OFFICE = 'uid-oficina-t141';
const STRANGER = 'uid-sin-lista-t141';
const INACTIVE = 'uid-inactiva-t141';

// Tokens sin firmar, como los que acepta el emulador (igual que T-113).
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
const shaOtro = 'c'.repeat(64);
function operationDoc(uid, id, extra = {}) {
  return {
    path: `operations/${id}`,
    data: {
      id, schema: 1, vessel: 'BUQUE T141', voyage: 'V-T141', portOfCall: 'GTSTC',
      status: 'open', createdBy: uid, profile: { vesselName: 'BUQUE T141' },
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
// T-130 · La entrada del manifiesto de un BAPLIE agregado, con voyage opcional.
function planEntry(kind, extra = {}) {
  return { fileName: `${kind}.edi`, sha256: sha, parts: 1, length: 9, ...extra };
}
// T-130 · El trozo `{tipo}-{i}` de un BAPLIE agregado.
function addedPart(uid, op, kind, extra = {}) {
  const id = `${kind}-0`;
  return {
    path: `operations/${op}/sources/${id}`,
    data: { id, kind, sha256: sha, part: 0, parts: 1, content: 'UNB+UNOA', createdBy: uid, ...extra },
    server: ['createdAt'],
  };
}
// T-127 · La entrada del manifiesto del listado, con revisión.
function listEntry(revision, extra = {}) {
  return { fileName: 'listado.csv', sha256: sha, parts: 1, length: 9, revision, ...extra };
}
function revisionPart(uid, op, revision, extra = {}) {
  const id = `export_list-r${revision}-0`;
  return {
    path: `operations/${op}/sources/${id}`,
    data: { id, kind: 'export_list', sha256: sha, part: 0, parts: 1, content: 'LISTADO', createdBy: uid, revision, ...extra },
    server: ['createdAt'],
  };
}
// Actualiza solo la entrada {kind} del manifiesto de la operación.
function manifestWrite(op, kind, entry) {
  return { path: `operations/${op}`, data: { sources: { [kind]: entry } }, mask: [`sources.${kind}`] };
}

const role = { [DOCK]: 'dock', [OFFICE]: 'office', [STRANGER]: 'office' };
const names = { [DOCK]: 'Muelle', [OFFICE]: 'Oficina', [STRANGER]: 'Nadie' };
const deviceId = randomUUID();
let sequence = 0;
function movement(uid, op, type, target, payload, extra = {}) {
  const id = randomUUID();
  return {
    id,
    path: `operations/${op}/movements/${id}`,
    data: {
      id, schema: 1, operationId: op, type, target, payload,
      author: { uid, name: names[uid], role: role[uid] },
      deviceId, sequence: ++sequence, createdAt: ts(new Date()),
      ...extra,
    },
    server: ['receivedAt'],
  };
}

const results = [];
async function expect(group, name, allowed, request) {
  const res = await request;
  const pass = res.ok === allowed;
  results.push({ group, name, allowed, got: res.ok, pass, status: res.status });
  console.log(`${pass ? 'PASA ' : 'FALLA'} · ${group} · ${name} · esperado ${allowed ? 'permitido' : 'denegado'}, ${res.ok ? 'permitido' : `denegado (${res.status})`}`);
  if ((process.env.T141_DETALLE && !res.ok) || (!pass && !res.ok)) {
    const motivo = /False for '[^']+'[^;]*/.exec(res.text)?.[0] ?? res.text.replace(/\s+/g, ' ').slice(0, 240);
    console.log(`        ${motivo}`);
  }
}

async function main() {
  const rules = readFileSync(rulesFile, 'utf8');
  const loaded = await call('PUT', `${host}/emulator/v1/projects/${project}:securityRules`, null,
    { rules: { files: [{ name: 'firestore.rules', content: rules }] } });
  if (!loaded.ok) throw new Error(`No se cargaron las reglas: ${loaded.status} ${loaded.text}`);
  await call('DELETE', `${host}/emulator/v1/projects/${project}/databases/(default)/documents`, null);

  const op = randomUUID();
  // La operación cerrada: sembrada por el dueño del emulador, cerrada hace
  // dos minutos, para probar qué pasa después del cierre.
  const opCerrada = randomUUID();
  const haceDosMin = ts(new Date(Date.now() - 2 * 60 * 1000));
  const seeded = await commit('owner', [
    { path: `authorized/${DOCK}`, data: { role: 'dock', name: 'Muelle', active: true } },
    { path: `authorized/${OFFICE}`, data: { role: 'office', name: 'Oficina', active: true } },
    { path: `authorized/${INACTIVE}`, data: { role: 'office', name: 'Inactiva', active: false } },
    operationDoc(OFFICE, opCerrada, { status: 'closed', closedBy: OFFICE, closedAt: haceDosMin }),
    sourceDoc(OFFICE, opCerrada),
  ]);
  if (!seeded.ok) throw new Error(`No se sembró la lista: ${seeded.text}`);
  const created = await commit(OFFICE, [operationDoc(OFFICE, op), sourceDoc(OFFICE, op)]);
  if (!created.ok) throw new Error(`No se creó la operación base: ${created.text}`);

  // A · Quién agrega el plan que falta (4)
  await expect('Agregar', 'el muelle no agrega una fuente (el plano de llegada que falta)', false,
    commit(DOCK, [manifestWrite(op, 'arrival_baplie', planEntry('arrival_baplie')), addedPart(DOCK, op, 'arrival_baplie')]));
  await expect('Agregar', 'la oficina no agrega una fuente de un tipo que ya está (reemplaza el plan de carga)', false,
    commit(OFFICE, [manifestWrite(op, 'loading_baplie', planEntry('loading_baplie', { sha256: shaOtro })), addedPart(OFFICE, op, 'loading_baplie', { sha256: shaOtro })]));
  await expect('Agregar', 'la oficina no agrega una fuente a una operación cerrada', false,
    commit(OFFICE, [manifestWrite(opCerrada, 'arrival_baplie', planEntry('arrival_baplie')), addedPart(OFFICE, opCerrada, 'arrival_baplie')]));
  await expect('Agregar', 'la oficina no agrega una fuente a nombre de otro (el trozo con createdBy del muelle)', false,
    commit(OFFICE, [manifestWrite(op, 'arrival_baplie', planEntry('arrival_baplie')), addedPart(DOCK, op, 'arrival_baplie')]));

  // B · Trozos contra el manifiesto (3)
  await expect('Trozos', 'nadie escribe un trozo que el manifiesto no declara: otra huella', false,
    commit(OFFICE, [manifestWrite(op, 'arrival_baplie', planEntry('arrival_baplie')), addedPart(OFFICE, op, 'arrival_baplie', { sha256: shaOtro })]));
  await expect('Trozos', 'ni otro número de partes que la entrada', false,
    commit(OFFICE, [manifestWrite(op, 'arrival_baplie', planEntry('arrival_baplie', { parts: 2 })), addedPart(OFFICE, op, 'arrival_baplie', { parts: 3, part: 0 })]));
  await expect('Trozos', 'un manifiesto sin sus trozos: la regla no lo puede exigir, se anota como permitido', true,
    commit(OFFICE, [manifestWrite(op, 'arrival_baplie', planEntry('arrival_baplie'))]));

  // C · La revisión del listado no borra ni reescribe la anterior (4)
  const r1 = await commit(OFFICE, [manifestWrite(op, 'export_list', listEntry(1)), revisionPart(OFFICE, op, 1)]);
  if (!r1.ok) throw new Error(`No se sembró la revisión 1 del listado: ${r1.text}`);
  const r2 = await commit(OFFICE, [manifestWrite(op, 'export_list', listEntry(2, { sha256: shaOtro })), revisionPart(OFFICE, op, 2, { sha256: shaOtro })]);
  if (!r2.ok) throw new Error(`No se sembró la revisión 2 del listado: ${r2.text}`);
  await expect('Listado', 'una revisión nueva no borra la anterior (delete del trozo r1)', false,
    commit(OFFICE, [{ delete: `operations/${op}/sources/export_list-r1-0` }]));
  await expect('Listado', 'ni la reescribe (update del trozo r1)', false,
    commit(OFFICE, [{ path: `operations/${op}/sources/export_list-r1-0`, data: { content: 'CAMBIADO' }, mask: ['content'] }]));
  await expect('Listado', 'la oficina no reescribe la revisión que ya pasó (r2 otra vez, otra huella)', false,
    commit(OFFICE, [manifestWrite(op, 'export_list', listEntry(2)), revisionPart(OFFICE, op, 2)]));
  await expect('Listado', 'ni vuelve atrás (r1 con la revisión en 2)', false,
    commit(OFFICE, [manifestWrite(op, 'export_list', listEntry(1)), revisionPart(OFFICE, op, 1)]));

  // D · Lecturas (4)
  await expect('Lectura', 'una cuenta fuera de la lista no lee la operación', false, get(STRANGER, `operations/${op}`));
  await expect('Lectura', 'ni sus fuentes', false, get(STRANGER, `operations/${op}/sources/loading_baplie-0`));
  await expect('Lectura', 'una cuenta inactiva tampoco lee la operación', false, get(INACTIVE, `operations/${op}`));
  await expect('Lectura', 'el muelle no lee el authorized ajeno', false, get(DOCK, `authorized/${OFFICE}`));

  // E · Tras el cierre, ningún movimiento nuevo (3)
  await expect('Cierre', 'tras el cierre, el muelle no registra un movimiento', false,
    commit(DOCK, [movement(DOCK, opCerrada, 'load_full', 'C:TSTU1410001', { position: '0140102' })]));
  await expect('Cierre', 'ni la oficina', false,
    commit(OFFICE, [movement(OFFICE, opCerrada, 'cancel_item', 'C:TSTU1410002', { reason: 'Ya cerre' })]));
  const antesDelCierre = new Date(Date.now() - 3 * 60 * 1000);
  await expect('Cierre', 'el que se registró sin red antes del cierre sí entra (límite declarado)', true,
    commit(DOCK, [movement(DOCK, opCerrada, 'load_full', 'C:TSTU1410003', { position: '0140104' }, { createdAt: ts(antesDelCierre) })]));

  const passed = results.filter((r) => r.pass).length;
  console.log(`\nResultado: ${passed} de ${results.length} casos dieron lo esperado` +
    ` · reglas: ${rulesFile.replace(root, '.')} · emulador ${host} · proyecto ${project}`);
  process.exit(passed === results.length ? 0 : 1);
}

main().catch((error) => { console.error(error); process.exit(1); });
