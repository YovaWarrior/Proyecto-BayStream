// T-130 · La operación publicada acepta el plan que le falta (10.85, 10.90):
// los casos nuevos de las reglas, contra docs/T130-firestore.rules.propuesta,
// en el emulador local de Firestore. Ningún proyecto en la nube: solo `demo-*`.
//
// Lo que prueba, además de lo que ya cubren tool/t80_reglas.mjs (69),
// tool/t113_reglas_abuso.mjs (25) y tool/t127_reglas_revision.mjs (31), que
// tienen que seguir dando lo mismo con estas reglas:
//   - la oficina agrega el BAPLIE que falta (llegada o carga), el muelle no;
//   - agregar, nunca reemplazar ni quitar: un tipo que ya estaba no cambia;
//   - la entrada del manifiesto con sus campos, `voyage` opcional (≤ 40);
//   - los trozos `{tipo}-{i}` atados a la entrada: huella, partes, id;
//   - el ajuste al trozo publicado: un trozo sin revisión que no cuadra con
//     el manifiesto no nace en una operación ya publicada;
//   - el presupuesto de accesos: una publicación de cinco trozos y una
//     adición de cuatro, en un lote cada una;
//   - lo que sigue igual: publicar, la revisión del listado, los movimientos,
//     el cierre y la lectura.
//
// Uso, con el emulador corriendo (tool/t113_emulador.ps1 -Proyecto demo-t130
// -Puerto 8282):
//
//     node tool/t130_reglas_plan.mjs [puerto] [proyecto-demo] [reglas]
//
// Por omisión, el puerto 8282, el proyecto demo-t130 y las reglas de T-130.
// Contra las de T-127 (`docs/T127-firestore.rules.propuesta`) los casos que
// esperan «permitido» tienen que fallar, y también el trozo suelto que no
// cuadra: es la prueba roja de las reglas. Borra los datos del emulador al
// empezar. Sale con 1 si un caso no da lo esperado. Con T130_DETALLE=1
// muestra el motivo de cada denegación. Si el emulador menciona el límite de
// accesos a documentos en alguna respuesta, lo dice al final.

import { randomUUID } from 'node:crypto';
import { readFileSync } from 'node:fs';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const port = Number(process.argv[2] ?? 8282);
const project = process.argv[3] ?? 'demo-t130';
if (!project.startsWith('demo-')) {
  console.error('Solo se prueba contra un proyecto demo- del emulador.');
  process.exit(2);
}
const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const rulesFile = process.argv[4]
  ? resolve(process.argv[4])
  : join(root, 'docs', 'T130-firestore.rules.propuesta');
const host = `http://127.0.0.1:${port}`;
const dbPath = `projects/${project}/databases/(default)/documents`;
const base = `${host}/v1/${dbPath}`;

// ------------------------------------------------------------ identidades
const DOCK = 'uid-muelle-t130';
const OFFICE = 'uid-oficina-t130';
const STRANGER = 'uid-sin-lista-t130';

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
// ruta con punto (`sources.loading_baplie`) toca solo esa entrada del mapa; una
// ruta en la máscara sin valor en `data` borra ese campo.
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
const sha = { arrival_baplie: 'a'.repeat(64), loading_baplie: 'b'.repeat(64), export_list: 'c'.repeat(64) };
const shaOther = 'd'.repeat(64);
const fileOf = { arrival_baplie: 'llegada.edi', loading_baplie: 'plan.edi', export_list: 'listado.xlsx' };
const deviceId = randomUUID();
let sequence = 0;

const entryOf = (kind, { parts = 1, extra = {} } = {}) =>
  ({ fileName: fileOf[kind], sha256: sha[kind], parts, length: 8, ...extra });

// Una operación publicada por la oficina con los tipos que se pidan, sin
// revisión, como `publish` (y como la 0.4.0 y la 0.4.1).
function operationDoc(uid, id, kinds, { parts = {} } = {}) {
  return {
    path: `operations/${id}`,
    data: {
      id, schema: 1, vessel: 'BUQUE T130', voyage: 'V-T130', portOfCall: 'GTSTC',
      status: 'open', createdBy: uid, profile: { vesselName: 'BUQUE T130' },
      sources: Object.fromEntries(kinds.map((k) => [k, entryOf(k, { parts: parts[k] ?? 1 })])),
    },
    server: ['createdAt'],
  };
}

// Un trozo `{tipo}-{i}` en el formato publicado (sin `revision`), tanto para
// publicar como para agregar; `id`, `sha256`, `parts` y `revision` sirven
// para que no cuadre con el manifiesto.
function part(uid, op, kind, { id, index = 0, parts = 1, sha256 = sha[kind], revision } = {}) {
  const partId = id ?? `${kind}-${index}`;
  return {
    path: `operations/${op}/sources/${partId}`,
    data: {
      id: partId, kind, sha256, part: index, parts, content: 'UNB+UNOA', createdBy: uid,
      ...(revision === undefined ? {} : { revision }),
    },
    server: ['createdAt'],
  };
}

// La actualización del manifiesto que agrega un tipo: solo `sources.{tipo}`,
// salvo que se pida otra máscara (para probar que no se cuela nada más).
function manifestAdd(op, kind, entry, { mask = [`sources.${kind}`], extra = {} } = {}) {
  const data = { sources: { [kind]: entry }, ...extra };
  if (extra.sources) data.sources = { [kind]: entry, ...extra.sources };
  return { path: `operations/${op}`, data, mask };
}

// Una adición completa, en un lote: la entrada y sus trozos.
function addition(uid, op, kind, { parts = 1, entryExtra = {}, partOptions = {}, mask, extra } = {}) {
  const writes = [manifestAdd(op, kind, entryOf(kind, { parts, extra: entryExtra }), { mask, extra })];
  for (let i = 0; i < parts; i++) {
    writes.push(part(uid, op, kind, { index: i, parts, ...partOptions }));
  }
  return writes;
}

// Los trozos de T-127: una revisión del listado.
const listEntry = (revision) => ({ fileName: 'listado.xlsx', sha256: sha.export_list, parts: 1, length: 7, revision });
function revisionPart(uid, op, revision) {
  const id = `export_list-r${revision}-0`;
  return {
    path: `operations/${op}/sources/${id}`,
    data: { id, kind: 'export_list', sha256: sha.export_list, part: 0, parts: 1, content: 'LISTADO', revision, createdBy: uid },
    server: ['createdAt'],
  };
}

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
const accessLimit = [];
function noteAccess(name, res) {
  if (/document access|access calls|exceeded.*(get|exists|getAfter)|too many .*(get|exists)/i.test(res.text)) {
    accessLimit.push({ name, status: res.status, text: res.text.replace(/\s+/g, ' ').slice(0, 240) });
  }
}
async function expect(group, name, allowed, request) {
  const res = await request;
  noteAccess(name, res);
  const pass = res.ok === allowed && !res.text.includes('maximum of 1000 expressions');
  results.push({ group, name, allowed, got: res.ok, pass, status: res.status });
  console.log(`${pass ? 'PASA ' : 'FALLA'} · ${group} · ${name} · esperado ${allowed ? 'permitido' : 'denegado'}, ${res.ok ? 'permitido' : `denegado (${res.status})`}`);
  if ((process.env.T130_DETALLE && !res.ok) || (!pass && !res.ok)) {
    const limit = res.text.includes('maximum of 1000 expressions') ? ' [LÍMITE DE 1000 EXPRESIONES]' : '';
    console.log(`        ${limit} ${res.text.replace(/\s+/g, ' ').slice(0, 240)}`);
  }
  return res;
}
function check(name, pass, detail) {
  results.push({ group: 'Lectura', name, allowed: true, got: pass, pass, status: 0 });
  console.log(`${pass ? 'PASA ' : 'FALLA'} · Lectura · ${name}${detail ? ` · ${detail}` : ''}`);
}
async function publish(uid, id, kinds, options) {
  const writes = [operationDoc(uid, id, kinds, options)];
  for (const kind of kinds) {
    const parts = options?.parts?.[kind] ?? 1;
    for (let i = 0; i < parts; i++) writes.push(part(uid, id, kind, { index: i, parts }));
  }
  return commit(uid, writes);
}
async function seed(id, kinds, options) {
  const created = await publish(OFFICE, id, kinds, options);
  if (!created.ok) throw new Error(`No se creó la operación base ${id}: ${created.text}`);
  return id;
}
const stringField = (doc, path) => path.split('.').reduce((f, k) => f?.mapValue?.fields?.[k] ?? f?.[k], doc.fields)?.stringValue;

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

  // A: solo el plan de carga (el caso del piloto al revés).
  // B: solo el plano de llegada (el caso del piloto, 10.85).
  const opA = await seed(randomUUID(), ['loading_baplie']);
  const opB = await seed(randomUUID(), ['arrival_baplie']);

  // A · Quién (4)
  await expect('Quién', 'el muelle no agrega el plano de llegada', false,
    commit(DOCK, addition(DOCK, opA, 'arrival_baplie')));
  await expect('Quién', 'una cuenta fuera de la lista no agrega', false,
    commit(STRANGER, addition(STRANGER, opA, 'arrival_baplie')));
  await expect('Quién', 'la oficina agrega el plano de llegada a una operación con solo el plan de carga', true,
    commit(OFFICE, addition(OFFICE, opA, 'arrival_baplie')));
  await expect('Quién', 'la oficina agrega el plan de carga a una operación con solo el plano de llegada', true,
    commit(OFFICE, addition(OFFICE, opB, 'loading_baplie')));

  // B · Una sola vez, nunca reemplazar ni quitar (5)
  const opE = await seed(randomUUID(), ['arrival_baplie']);
  await expect('Una vez', 'el mismo tipo otra vez (ya está), no', false,
    commit(OFFICE, [manifestAdd(opA, 'arrival_baplie', entryOf('arrival_baplie', { extra: { sha256: shaOther } }))]));
  await expect('Una vez', 'reemplazar la entrada del plan de carga con otra huella, no', false,
    commit(OFFICE, [manifestAdd(opA, 'loading_baplie', entryOf('loading_baplie', { extra: { sha256: shaOther } }))]));
  await expect('Una vez', 'quitar una entrada, no', false,
    commit(OFFICE, [{ path: `operations/${opA}`, data: { sources: {} }, mask: ['sources.loading_baplie'] }]));
  await expect('Una vez', 'agregar el plan y el listado en la misma actualización, no', false,
    commit(OFFICE, addition(OFFICE, opE, 'loading_baplie', {
      mask: ['sources.loading_baplie', 'sources.export_list'],
      extra: { sources: { export_list: listEntry(1) } },
    })));
  await expect('Una vez', 'agregar el plan y cambiar el buque, no', false,
    commit(OFFICE, addition(OFFICE, opE, 'loading_baplie', { mask: ['sources.loading_baplie', 'vessel'], extra: { vessel: 'OTRO' } })));

  // C · La entrada (7)
  await expect('Entrada', 'sin length, no', false,
    commit(OFFICE, [manifestAdd(opE, 'loading_baplie', (() => { const e = entryOf('loading_baplie'); delete e.length; return e; })()), part(OFFICE, opE, 'loading_baplie')]));
  await expect('Entrada', 'con un campo de más, no', false,
    commit(OFFICE, addition(OFFICE, opE, 'loading_baplie', { entryExtra: { extra: true } })));
  await expect('Entrada', 'con una huella que no es hex de 64, no', false,
    commit(OFFICE, addition(OFFICE, opE, 'loading_baplie', { entryExtra: { sha256: 'no-es-una-huella' }, partOptions: { sha256: 'no-es-una-huella' } })));
  await expect('Entrada', 'con parts 0, no', false,
    commit(OFFICE, [manifestAdd(opE, 'loading_baplie', entryOf('loading_baplie', { parts: 0 }))]));
  await expect('Entrada', 'con parts 21, no', false,
    commit(OFFICE, [manifestAdd(opE, 'loading_baplie', entryOf('loading_baplie', { parts: 21 }))]));
  await expect('Entrada', 'con voyage de 41 caracteres, no', false,
    commit(OFFICE, addition(OFFICE, opE, 'loading_baplie', { entryExtra: { voyage: 'V'.repeat(41) } })));
  const opD = await seed(randomUUID(), ['arrival_baplie']);
  await expect('Entrada', 'con voyage válido (M100N) sí: el plan declara otro viaje', true,
    commit(OFFICE, addition(OFFICE, opD, 'loading_baplie', { entryExtra: { voyage: 'M100N' } })));
  const docD = await get(DOCK, `operations/${opD}`);
  const voyageD = docD.ok ? stringField(JSON.parse(docD.text), 'sources.loading_baplie.voyage') : undefined;
  check('un cliente lee la operación y ve sources.loading_baplie.voyage = M100N', voyageD === 'M100N', voyageD ?? docD.status);

  // D · Los trozos (7)
  await expect('Trozos', 'con otra huella que la entrada, no', false,
    commit(OFFICE, addition(OFFICE, opE, 'loading_baplie', { partOptions: { sha256: shaOther } })));
  await expect('Trozos', 'con otro número de partes que la entrada, no', false,
    commit(OFFICE, addition(OFFICE, opE, 'loading_baplie', { partOptions: { parts: 2 } })));
  await expect('Trozos', 'con id de revisión (loading_baplie-r1-0), no', false,
    commit(OFFICE, addition(OFFICE, opE, 'loading_baplie', { partOptions: { id: 'loading_baplie-r1-0' } })));
  await expect('Trozos', 'con campo revision, no', false,
    commit(OFFICE, addition(OFFICE, opE, 'loading_baplie', { partOptions: { revision: 1 } })));
  await expect('Trozos', 'sin su entrada en el mismo lote, no', false,
    commit(OFFICE, [part(OFFICE, opE, 'loading_baplie')]));
  await expect('Trozos', 'un trozo de más de un tipo que ya estaba (arrival_baplie-1 con parts 1), no', false,
    commit(OFFICE, [part(OFFICE, opE, 'arrival_baplie', { index: 1, parts: 1 })]));
  const opF = await seed(randomUUID(), ['arrival_baplie']);
  await expect('Trozos', 'dos trozos (parts 2) sí', true,
    commit(OFFICE, addition(OFFICE, opF, 'loading_baplie', { parts: 2 })));

  // E · El ajuste al trozo publicado (2): G se publicó con parts 2 y un solo
  // trozo escrito (las reglas no cuentan los trozos); después de publicada…
  const opG = randomUUID();
  const createdG = await commit(OFFICE, [operationDoc(OFFICE, opG, ['loading_baplie'], { parts: { loading_baplie: 2 } }), part(OFFICE, opG, 'loading_baplie', { index: 0, parts: 2 })]);
  if (!createdG.ok) throw new Error(`No se creó la operación G: ${createdG.text}`);
  await expect('Ajuste', 'un trozo suelto que no cuadra con el manifiesto (otra huella) en una operación ya publicada, no', false,
    commit(OFFICE, [part(OFFICE, opG, 'loading_baplie', { index: 1, parts: 2, sha256: shaOther })]));
  await expect('Ajuste', 'un trozo que completa lo que el manifiesto declara (misma huella, mismas partes) sí: es inofensivo', true,
    commit(OFFICE, [part(OFFICE, opG, 'loading_baplie', { index: 1, parts: 2 })]));

  // F · El presupuesto de accesos a documentos (2)
  await expect('Presupuesto', 'una publicación de cinco trozos en un lote', true,
    publish(OFFICE, randomUUID(), ['loading_baplie'], { parts: { loading_baplie: 5 } }));
  const opI = await seed(randomUUID(), ['arrival_baplie']);
  await expect('Presupuesto', 'una adición de cuatro trozos en un lote', true,
    commit(OFFICE, addition(OFFICE, opI, 'loading_baplie', { parts: 4 })));

  // G · Lo que sigue igual (9)
  await expect('Igual', 'publicar una operación nueva con sus dos planos, sí', true,
    publish(OFFICE, randomUUID(), ['arrival_baplie', 'loading_baplie']));
  await expect('Igual', 'la revisión del listado (T-127) después de agregar el plan, sí', true,
    commit(OFFICE, [{ path: `operations/${opA}`, data: { sources: { export_list: listEntry(1) } }, mask: ['sources.export_list'] }, revisionPart(OFFICE, opA, 1)]));
  await expect('Igual', 'el muelle sigue registrando movimientos después de la adición', true,
    commit(DOCK, [movement(DOCK, opA, 'load_full', 'C:TSTU1300001', { position: '0140102', order: 1 })]));
  const parts = await expect('Lectura', 'el muelle lee los trozos', true,
    get(DOCK, `operations/${opA}/sources?pageSize=50`));
  const ids = (JSON.parse(parts.text).documents ?? []).map((d) => d.name.split('/').pop()).sort();
  check('quedan el trozo publicado, el agregado y el de la revisión',
    ids.join(',') === 'arrival_baplie-0,export_list-r1-0,loading_baplie-0', ids.join(','));
  await expect('Igual', 'un trozo agregado no se actualiza', false,
    commit(OFFICE, [{ ...part(OFFICE, opA, 'arrival_baplie'), data: { ...part(OFFICE, opA, 'arrival_baplie').data, content: 'OTRO' } }]));
  await expect('Igual', 'un trozo agregado no se borra', false,
    commit(OFFICE, [{ delete: `operations/${opA}/sources/arrival_baplie-0` }]));
  await expect('Cierre', 'la oficina cierra la operación con el plan agregado', true,
    commit(OFFICE, [{ path: `operations/${opA}`, data: { status: 'closed', closedBy: OFFICE }, mask: ['status', 'closedBy', 'closedAt'], server: ['closedAt'] }]));
  const opK = await seed(randomUUID(), ['arrival_baplie']);
  const closedK = await commit(OFFICE, [{ path: `operations/${opK}`, data: { status: 'closed', closedBy: OFFICE }, mask: ['status', 'closedBy', 'closedAt'], server: ['closedAt'] }]);
  if (!closedK.ok) throw new Error(`No se cerró la operación K: ${closedK.text}`);
  await expect('Cierre', 'cerrada, no admite la entrada del plan', false,
    commit(OFFICE, [manifestAdd(opK, 'loading_baplie', entryOf('loading_baplie'))]));
  await expect('Cierre', 'ni el trozo', false,
    commit(OFFICE, [part(OFFICE, opK, 'loading_baplie')]));

  const passed = results.filter((r) => r.pass).length;
  if (accessLimit.length > 0) {
    console.log(`\nEl emulador mencionó el límite de accesos a documentos en ${accessLimit.length} respuesta(s):`);
    for (const a of accessLimit) console.log(`  ${a.name} (${a.status}): ${a.text}`);
  } else {
    console.log('\nNinguna respuesta del emulador mencionó el límite de accesos a documentos.');
  }
  console.log(`Resultado: ${passed} de ${results.length} casos dieron lo esperado` +
    ` · reglas: ${rulesFile.replace(root, '.')} · emulador ${host} · proyecto ${project}`);
  process.exit(passed === results.length ? 0 : 1);
}

main().catch((error) => { console.error(error); process.exit(1); });
