// T-127 · El listado con revisión en una operación publicada (10.78): los
// casos nuevos de las reglas, contra docs/T127-firestore.rules.propuesta, en
// el emulador local de Firestore. Ningún proyecto en la nube: solo `demo-*`.
//
// Lo que prueba, además de lo que ya cubren tool/t80_reglas.mjs (69) y
// tool/t113_reglas_abuso.mjs (25), que tienen que seguir dando lo mismo con
// estas reglas:
//   - una revisión de la oficina pasa, y una del muelle no;
//   - una revisión que no sube no pasa;
//   - un trozo con una revisión distinta de la del manifiesto no pasa, y un
//     trozo de revisión sin su manifiesto tampoco;
//   - las entradas de arrival_baplie y loading_baplie no cambian;
//   - en una operación cerrada no hay revisión;
//   - los trozos anteriores quedan, sin update ni delete, y el muelle los lee;
//   - los movimientos, el cierre y publicar con listado siguen como siempre.
//
// Uso, con el emulador corriendo (tool/t113_emulador.ps1 -Proyecto demo-t127
// -Puerto 8282):
//
//     node tool/t127_reglas_revision.mjs [puerto] [proyecto-demo] [reglas]
//
// Por omisión, el puerto 8282, el proyecto demo-t127 y las reglas de T-127.
// Contra las de T-80 (`docs/T80-firestore.rules.propuesta`) los casos que
// esperan «permitido» tienen que fallar: es la prueba roja de antes.
// Borra los datos del emulador al empezar. Sale con 1 si un caso no da lo
// esperado. Con T127_DETALLE=1 muestra el motivo de cada denegación.

import { randomUUID } from 'node:crypto';
import { readFileSync } from 'node:fs';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const port = Number(process.argv[2] ?? 8282);
const project = process.argv[3] ?? 'demo-t127';
if (!project.startsWith('demo-')) {
  console.error('Solo se prueba contra un proyecto demo- del emulador.');
  process.exit(2);
}
const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const rulesFile = process.argv[4]
  ? resolve(process.argv[4])
  : join(root, 'docs', 'T127-firestore.rules.propuesta');
const host = `http://127.0.0.1:${port}`;
const dbPath = `projects/${project}/databases/(default)/documents`;
const base = `${host}/v1/${dbPath}`;

// ------------------------------------------------------------ identidades
const DOCK = 'uid-muelle-t127';
const OFFICE = 'uid-oficina-t127';

// Tokens sin firmar, como los que acepta el emulador (igual que T-80).
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
// mask: [campos]} o {delete: path}. Con `mask`, es un `update` del SDK: una
// ruta con punto (`sources.export_list`) toca solo esa entrada del mapa.
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
const shaPlan = 'a'.repeat(64);
const shaList = 'c'.repeat(64);
const shaOther = 'd'.repeat(64);
const deviceId = randomUUID();
let sequence = 0;

// Una operación publicada: con el plan de carga y, si se pide, el listado
// publicado junto con ella, sin revisión (como la 0.4.0 y como `publish`).
function operationDoc(uid, id, { withList = false } = {}) {
  return {
    path: `operations/${id}`,
    data: {
      id, schema: 1, vessel: 'BUQUE T127', voyage: 'V-T127', portOfCall: 'GTSTC',
      status: 'open', createdBy: uid, profile: { vesselName: 'BUQUE T127' },
      sources: {
        loading_baplie: { fileName: 'plan.edi', sha256: shaPlan, parts: 1, length: 8 },
        ...(withList ? { export_list: { fileName: 'listado.xlsx', sha256: shaList, parts: 1, length: 7 } } : {}),
      },
    },
    server: ['createdAt'],
  };
}
function planPart(uid, op) {
  const id = 'loading_baplie-0';
  return {
    path: `operations/${op}/sources/${id}`,
    data: { id, kind: 'loading_baplie', sha256: shaPlan, part: 0, parts: 1, content: 'UNB+UNOA', createdBy: uid },
    server: ['createdAt'],
  };
}
// El trozo del listado publicado con la operación (sin revisión).
function publishedListPart(uid, op) {
  const id = 'export_list-0';
  return {
    path: `operations/${op}/sources/${id}`,
    data: { id, kind: 'export_list', sha256: shaList, part: 0, parts: 1, content: 'LISTADO', createdBy: uid },
    server: ['createdAt'],
  };
}

// La entrada `sources.export_list` de una revisión.
const listEntry = (revision, extra = {}) =>
  ({ fileName: 'listado.xlsx', sha256: shaList, parts: 1, length: 7, revision, ...extra });

// La actualización del manifiesto: solo `sources.export_list`, salvo que se
// pida otra máscara (para probar que no se cuela nada más).
function manifestWrite(op, entry, { mask = ['sources.export_list'], extra = {} } = {}) {
  const data = { sources: { export_list: entry }, ...extra };
  if (extra.sources) data.sources = { export_list: entry, ...extra.sources };
  return { path: `operations/${op}`, data, mask };
}

// Un trozo `export_list-r{revision}-{part}`; `id` y `fieldRevision` sirven
// para que no cuadren con el manifiesto.
function revisionPart(uid, op, revision, { id, part = 0, parts = 1, sha256 = shaList, fieldRevision } = {}) {
  const partId = id ?? `export_list-r${revision}-${part}`;
  return {
    path: `operations/${op}/sources/${partId}`,
    data: {
      id: partId, kind: 'export_list', sha256, part, parts, content: 'LISTADO',
      revision: fieldRevision ?? revision, createdBy: uid,
    },
    server: ['createdAt'],
  };
}

// Una revisión completa, en un lote: el manifiesto y su trozo.
const revision = (uid, op, n, options = {}) => [
  manifestWrite(op, listEntry(n, options.entryExtra), options),
  revisionPart(uid, op, n, options.part ?? {}),
];

function movement(uid, op, type, target, payload) {
  const id = randomUUID();
  return {
    id,
    path: `operations/${op}/movements/${id}`,
    data: {
      id, schema: 1, operationId: op, type, target, payload,
      author: { uid, name: uid === DOCK ? 'Muelle' : 'Oficina', role: uid === DOCK ? 'dock' : 'office' },
      deviceId, sequence: ++sequence, createdAt: ts(new Date()),
    },
    server: ['receivedAt'],
  };
}

// ------------------------------------------------------------------ batería
const results = [];
async function expect(group, name, allowed, request) {
  const res = await request;
  const pass = res.ok === allowed && !res.text.includes('maximum of 1000 expressions');
  results.push({ group, name, allowed, got: res.ok, pass, status: res.status });
  console.log(`${pass ? 'PASA ' : 'FALLA'} · ${group} · ${name} · esperado ${allowed ? 'permitido' : 'denegado'}, ${res.ok ? 'permitido' : `denegado (${res.status})`}`);
  if ((process.env.T127_DETALLE && !res.ok) || (!pass && !res.ok)) {
    const limit = res.text.includes('maximum of 1000 expressions') ? ' [LÍMITE DE 1000 EXPRESIONES]' : '';
    console.log(`        ${limit} ${res.text.replace(/\s+/g, ' ').slice(0, 240)}`);
  }
  return res;
}
function check(name, pass, detail) {
  results.push({ group: 'Lectura', name, allowed: true, got: pass, pass, status: 0 });
  console.log(`${pass ? 'PASA ' : 'FALLA'} · Lectura · ${name}${detail ? ` · ${detail}` : ''}`);
}

async function main() {
  const rules = readFileSync(rulesFile, 'utf8');
  const loaded = await call('PUT', `${host}/emulator/v1/projects/${project}:securityRules`, null,
    { rules: { files: [{ name: 'firestore.rules', content: rules }] } });
  if (!loaded.ok) throw new Error(`No se cargaron las reglas: ${loaded.status} ${loaded.text}`);
  await call('DELETE', `${host}/emulator/v1/projects/${project}/databases/(default)/documents`, null);

  const seeded = await commit('owner', [
    { path: `authorized/${DOCK}`, data: { role: 'dock', name: 'Muelle', active: true } },
    { path: `authorized/${OFFICE}`, data: { role: 'office', name: 'Oficina', active: true } },
  ]);
  if (!seeded.ok) throw new Error(`No se sembró la lista: ${seeded.text}`);

  // A: publicada sin listado (el caso del piloto, 10.50).
  // B: publicada con el listado, sin revisión (como la 0.4.0).
  const opA = randomUUID();
  const opB = randomUUID();
  for (const [op, withList] of [[opA, false], [opB, true]]) {
    const created = await commit(OFFICE, [
      operationDoc(OFFICE, op, { withList }),
      planPart(OFFICE, op),
      ...(withList ? [publishedListPart(OFFICE, op)] : []),
    ]);
    if (!created.ok) throw new Error(`No se creó la operación base: ${created.text}`);
  }

  // A · Quién revisa (3)
  await expect('Revisión', 'el muelle no agrega el listado a la operación publicada', false,
    commit(DOCK, revision(DOCK, opA, 1)));
  await expect('Revisión', 'la oficina agrega el listado a una operación publicada sin listado: revisión 1', true,
    commit(OFFICE, revision(OFFICE, opA, 1)));
  await expect('Revisión', 'la oficina reemplaza el listado: revisión 2, y los trozos de la 1 quedan', true,
    commit(OFFICE, revision(OFFICE, opA, 2)));

  // B · La revisión tiene que subir (4)
  await expect('Revisión', 'la misma revisión (2) otra vez, no', false,
    commit(OFFICE, [manifestWrite(opA, listEntry(2, { sha256: shaOther }))]));
  await expect('Revisión', 'una revisión menor (1), no', false,
    commit(OFFICE, [manifestWrite(opA, listEntry(1, { sha256: shaOther }))]));
  await expect('Revisión', 'la revisión 0, no', false,
    commit(OFFICE, [manifestWrite(opA, listEntry(0))]));
  await expect('Revisión', 'sin listado antes, la primera revisión es la 1: empezar en 2, no', false,
    commit(OFFICE, revision(OFFICE, randomUUID(), 2)));

  // C · Los trozos y el manifiesto cuadran (5)
  await expect('Trozos', 'un trozo con otra revisión que la del manifiesto (campo), no', false,
    commit(OFFICE, revision(OFFICE, opA, 3, { part: { id: 'export_list-r3-0', fieldRevision: 2 } })));
  await expect('Trozos', 'un trozo con otra revisión que la del manifiesto (id), no', false,
    commit(OFFICE, revision(OFFICE, opA, 3, { part: { id: 'export_list-r4-0', fieldRevision: 4 } })));
  await expect('Trozos', 'un trozo de revisión sin subir el manifiesto, no', false,
    commit(OFFICE, [revisionPart(OFFICE, opA, 3)]));
  await expect('Trozos', 'un trozo con otra huella que la del manifiesto, no', false,
    commit(OFFICE, revision(OFFICE, opA, 3, { part: { sha256: shaOther } })));
  await expect('Trozos', 'un trozo de revisión que no cuenta sus partes como el manifiesto, no', false,
    commit(OFFICE, revision(OFFICE, opA, 3, { part: { parts: 2 } })));

  // D · Solo cambia el listado (6)
  await expect('Fuentes', 'la revisión no cambia el plan de carga', false,
    commit(OFFICE, revision(OFFICE, opA, 3, {
      mask: ['sources.export_list', 'sources.loading_baplie'],
      extra: { sources: { loading_baplie: { fileName: 'otro.edi', sha256: shaOther, parts: 1, length: 8 } } },
    })));
  await expect('Fuentes', 'la entrada del plan de carga no cambia sola', false,
    commit(OFFICE, [{
      path: `operations/${opA}`, mask: ['sources.loading_baplie'],
      data: { sources: { loading_baplie: { fileName: 'otro.edi', sha256: shaOther, parts: 1, length: 8 } } },
    }]));
  await expect('Fuentes', 'la revisión no agrega un plano de llegada', false,
    commit(OFFICE, revision(OFFICE, opA, 3, {
      mask: ['sources.export_list', 'sources.arrival_baplie'],
      extra: { sources: { arrival_baplie: { fileName: 'llegada.edi', sha256: shaOther, parts: 1, length: 8 } } },
    })));
  await expect('Fuentes', 'la revisión no toca otro campo de la operación', false,
    commit(OFFICE, revision(OFFICE, opA, 3, { mask: ['sources.export_list', 'vessel'], extra: { vessel: 'OTRO' } })));
  await expect('Fuentes', 'la entrada sin length, no', false,
    commit(OFFICE, [manifestWrite(opA, (() => { const e = listEntry(3); delete e.length; return e; })())]));
  await expect('Fuentes', 'la entrada con un campo de más, no', false,
    commit(OFFICE, [manifestWrite(opA, listEntry(3, { extra: true }))]));
  await expect('Fuentes', 'la revisión como texto, no', false,
    commit(OFFICE, [manifestWrite(opA, listEntry('3'))]));

  // E · Sobre un listado publicado con la operación, sin revisión (2)
  await expect('Sin revisión', 'sobre un listado publicado con la operación, la revisión 0, no', false,
    commit(OFFICE, revision(OFFICE, opB, 0)));
  await expect('Sin revisión', 'sobre un listado publicado con la operación, la revisión 1 pasa', true,
    commit(OFFICE, revision(OFFICE, opB, 1)));

  // F · Lo que sigue igual (5)
  const parts = await expect('Lectura', 'el muelle lee los trozos de todas las revisiones', true,
    get(DOCK, `operations/${opA}/sources?pageSize=50`));
  const ids = (JSON.parse(parts.text).documents ?? []).map((d) => d.name.split('/').pop()).sort();
  check('quedan los trozos de las dos revisiones y el del plan',
    ids.join(',') === 'export_list-r1-0,export_list-r2-0,loading_baplie-0', ids.join(','));
  await expect('Igual', 'el muelle sigue registrando movimientos después de la revisión', true,
    commit(DOCK, [movement(DOCK, opA, 'load_full', 'C:TSTU1270001', { position: '0140102', order: 1 })]));
  await expect('Igual', 'un trozo anterior no se actualiza', false,
    commit(OFFICE, [{ ...revisionPart(OFFICE, opA, 1), data: { ...revisionPart(OFFICE, opA, 1).data, content: 'OTRO' } }]));
  await expect('Igual', 'un trozo anterior no se borra', false,
    commit(OFFICE, [{ delete: `operations/${opA}/sources/export_list-r1-0` }]));

  // G · Cierre (3)
  await expect('Cierre', 'la oficina cierra la operación revisada', true,
    commit(OFFICE, [{ path: `operations/${opA}`, data: { status: 'closed', closedBy: OFFICE }, mask: ['status', 'closedBy', 'closedAt'], server: ['closedAt'] }]));
  await expect('Cierre', 'en una operación cerrada no hay revisión', false,
    commit(OFFICE, revision(OFFICE, opA, 3)));
  await expect('Cierre', 'ni un trozo nuevo', false,
    commit(OFFICE, [revisionPart(OFFICE, opA, 3)]));

  // H · Publicar sigue igual (2)
  const opC = randomUUID();
  await expect('Publicar', 'publicar una operación nueva con su listado, sin revisión, sigue igual', true,
    commit(OFFICE, [operationDoc(OFFICE, opC, { withList: true }), planPart(OFFICE, opC), publishedListPart(OFFICE, opC)]));
  const opD = randomUUID();
  await expect('Publicar', 'un trozo de revisión con un manifiesto sin revisión, no', false,
    commit(OFFICE, [operationDoc(OFFICE, opD, { withList: true }), planPart(OFFICE, opD), revisionPart(OFFICE, opD, 1)]));

  const passed = results.filter((r) => r.pass).length;
  console.log(`\nResultado: ${passed} de ${results.length} casos dieron lo esperado` +
    ` · reglas: ${rulesFile.replace(root, '.')} · emulador ${host} · proyecto ${project}`);
  process.exit(passed === results.length ? 0 : 1);
}

main().catch((error) => { console.error(error); process.exit(1); });
