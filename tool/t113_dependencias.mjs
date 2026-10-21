// T-113 · Las dependencias de pubspec.lock contra los avisos conocidos.
//
// Dos fuentes públicas, sin credenciales:
//   - OSV (api.osv.dev), ecosistema «Pub»: una consulta por paquete y
//     versión exacta del lock; OSV ya evalúa los rangos afectados.
//   - GitHub Advisory Database (api.github.com/advisories, ecosystem=pub):
//     se baja la lista entera y se cruza por nombre y por rango.
// Además, cada paquete se consulta en OSV sin versión, para contar los avisos
// históricos que ya no afectan a la versión fijada.
//
// Los paquetes del SDK (flutter, flutter_localizations, flutter_test,
// integration_test, sky_engine…) no viven en pub.dev: se consultan igual por
// nombre y se declaran aparte, con la versión de Flutter y de Dart instalada.
//
// Uso:
//
//     node tool/t113_dependencias.mjs [pubspec.lock] [carpeta de salida]
//
// Escribe dependencias.json y dependencias.md en la carpeta de salida
// (por omisión build/t113). Sale con 1 si un aviso afecta a una versión del
// lock y con 2 si una fuente no respondió.

import { mkdirSync, readFileSync, readdirSync, writeFileSync, existsSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const lockFile = process.argv[2] ?? join(root, 'pubspec.lock');
const outDir = process.argv[3] ?? join(root, 'build', 't113');
mkdirSync(outDir, { recursive: true });

// ------------------------------------------------------------- el lock
function parseLock(text) {
  const packages = [];
  let current = null;
  for (const line of text.split(/\r?\n/)) {
    const name = /^ {2}([a-z0-9_]+):$/.exec(line);
    if (name) {
      current = { name: name[1] };
      packages.push(current);
      continue;
    }
    if (!current) continue;
    const field = /^ {4}(dependency|source|version): "?([^"]+)"?$/.exec(line);
    if (field) current[field[1]] = field[2];
    if (/^\S/.test(line) && line !== 'packages:') current = null;
  }
  return packages;
}

const packages = parseLock(readFileSync(lockFile, 'utf8'));

// Versión instalada del SDK, para los paquetes `source: sdk`.
function sdkVersions() {
  const candidates = [process.env.FLUTTER_ROOT, 'C:/flutter'].filter(Boolean);
  for (const dir of candidates) {
    const file = join(dir, 'bin', 'cache', 'flutter.version.json');
    if (existsSync(file)) {
      const v = JSON.parse(readFileSync(file, 'utf8'));
      return { flutter: v.frameworkVersion, dart: v.dartSdkVersion, channel: v.channel };
    }
  }
  return { flutter: null, dart: null, channel: null };
}
const sdk = sdkVersions();

// ------------------------------------------------------------ versiones
function parseVersion(v) {
  const [core, pre] = String(v).trim().split('-', 2);
  const nums = core.split('+')[0].split('.').map((n) => Number(n));
  while (nums.length < 3) nums.push(0);
  return { nums, pre: pre ?? null };
}
function compare(a, b) {
  const x = parseVersion(a);
  const y = parseVersion(b);
  for (let i = 0; i < 3; i++) if (x.nums[i] !== y.nums[i]) return x.nums[i] - y.nums[i];
  if (x.pre === y.pre) return 0;
  if (x.pre === null) return 1;
  if (y.pre === null) return -1;
  return x.pre < y.pre ? -1 : 1;
}
// Rango de GitHub: «< 1.2.3», «>= 1.0.0, < 1.2.3», «= 1.0.0», «<= 2.0.0».
function inRange(version, range) {
  if (!range) return false;
  return range.split(',').every((part) => {
    const m = /^\s*(<=|>=|<|>|=)\s*([^\s]+)\s*$/.exec(part);
    if (!m) return false;
    const c = compare(version, m[2]);
    return { '<': c < 0, '<=': c <= 0, '>': c > 0, '>=': c >= 0, '=': c === 0 }[m[1]];
  });
}

// ------------------------------------------------------------------- red
const failures = [];
async function getJson(url, init) {
  for (let attempt = 1; attempt <= 3; attempt++) {
    try {
      const res = await fetch(url, { ...init, signal: AbortSignal.timeout(30000) });
      if (!res.ok) throw new Error(`HTTP ${res.status}`);
      return { json: await res.json(), headers: res.headers };
    } catch (error) {
      if (attempt === 3) {
        failures.push(`${url}: ${error.message}`);
        return null;
      }
    }
  }
}

// OSV, por versión exacta (los del SDK, por nombre).
async function osvBatch(queries) {
  const results = [];
  for (let i = 0; i < queries.length; i += 100) {
    const chunk = queries.slice(i, i + 100);
    const r = await getJson('https://api.osv.dev/v1/querybatch', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ queries: chunk }),
    });
    const got = r?.json?.results ?? chunk.map(() => null);
    results.push(...got);
  }
  return results;
}

const hosted = packages.filter((p) => p.source === 'hosted');
const sdkPackages = packages.filter((p) => p.source === 'sdk');
const others = packages.filter((p) => p.source !== 'hosted' && p.source !== 'sdk');

const exact = await osvBatch(
  hosted.map((p) => ({ package: { name: p.name, ecosystem: 'Pub' }, version: p.version })),
);
const anyVersion = await osvBatch(
  packages.map((p) => ({ package: { name: p.name, ecosystem: 'Pub' } })),
);

const osvDetails = {};
async function osvVuln(id) {
  if (!osvDetails[id]) {
    const r = await getJson(`https://api.osv.dev/v1/vulns/${id}`);
    osvDetails[id] = r?.json ?? { id };
  }
  return osvDetails[id];
}

// GitHub Advisory, toda la lista de pub (paginada).
const ghsa = [];
let next = 'https://api.github.com/advisories?ecosystem=pub&per_page=100';
while (next) {
  const r = await getJson(next, { headers: { Accept: 'application/vnd.github+json' } });
  if (!r) break;
  ghsa.push(...r.json);
  const link = r.headers.get('link') ?? '';
  next = /<([^>]+)>;\s*rel="next"/.exec(link)?.[1] ?? null;
}

// Los SDK nativos de Firebase no están en el lock: los fijan los plugins.
// Web: la copia servida desde web/vendor (T-92); Android: la BoM que pide
// firebase_core; Windows: el SDK de C++ que baja su CMake.
function lockVersion(name) {
  return packages.find((p) => p.name === name)?.version ?? null;
}
function pubCache(name) {
  const dir = process.env.PUB_CACHE
    ? join(process.env.PUB_CACHE, 'hosted', 'pub.dev')
    : join(process.env.LOCALAPPDATA ?? '', 'Pub', 'Cache', 'hosted', 'pub.dev');
  return join(dir, `${name}-${lockVersion(name)}`);
}
function grep(file, re) {
  return existsSync(file) ? re.exec(readFileSync(file, 'utf8'))?.[1] ?? null : null;
}
const natives = [
  {
    component: 'Firebase JS (Web)',
    ecosystem: 'npm',
    name: 'firebase',
    version: grep(join(pubCache('firebase_core_web'), 'lib', 'src', 'firebase_sdk_version.dart'),
      /supportedFirebaseJsSdkVersion\s*=\s*'([^']+)'/),
    served: existsSync(join(root, 'web', 'vendor', 'firebase'))
      ? readdirSync(join(root, 'web', 'vendor', 'firebase')).join(', ') : null,
  },
  {
    component: 'Firebase Android BoM',
    ecosystem: 'Maven',
    name: 'com.google.firebase:firebase-bom',
    version: grep(join(pubCache('firebase_core'), 'android', 'gradle.properties'),
      /FirebaseSDKVersion\s*=\s*(\S+)/),
  },
  {
    component: 'Firebase C++ (Windows)',
    ecosystem: null,
    name: 'firebase_cpp_sdk_windows',
    version: grep(join(pubCache('firebase_core'), 'windows', 'CMakeLists.txt'),
      /set\(FIREBASE_SDK_VERSION "([^"]+)"\)/),
  },
];
for (const n of natives) {
  if (!n.ecosystem || !n.version) {
    n.osv = null;
    continue;
  }
  const r = await getJson('https://api.osv.dev/v1/query', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ package: { name: n.name, ecosystem: n.ecosystem }, version: n.version }),
  });
  n.osv = r ? (r.json.vulns ?? []).map((v) => v.id) : null;
}

// ------------------------------------------------------------ el cruce
const rows = [];
for (const [i, p] of packages.entries()) {
  const row = {
    name: p.name,
    version: p.version,
    dependency: p.dependency,
    source: p.source,
    osvAffecting: [],
    osvHistoric: [],
    ghsaAffecting: [],
    ghsaHistoric: [],
  };
  const hostedIndex = hosted.indexOf(p);
  if (hostedIndex >= 0) {
    for (const v of exact[hostedIndex]?.vulns ?? []) row.osvAffecting.push(v.id);
  }
  for (const v of anyVersion[i]?.vulns ?? []) {
    if (!row.osvAffecting.includes(v.id)) row.osvHistoric.push(v.id);
  }
  for (const adv of ghsa) {
    for (const vuln of adv.vulnerabilities ?? []) {
      if (vuln.package?.ecosystem !== 'pub' || vuln.package?.name !== p.name) continue;
      const affected = p.source === 'hosted' && inRange(p.version, vuln.vulnerable_version_range);
      const entry = {
        id: adv.ghsa_id,
        severity: adv.severity,
        range: vuln.vulnerable_version_range,
        patched: vuln.first_patched_version,
        summary: adv.summary,
      };
      (affected ? row.ghsaAffecting : row.ghsaHistoric).push(entry);
    }
  }
  rows.push(row);
}

for (const row of rows) {
  for (const id of [...row.osvAffecting, ...row.osvHistoric]) await osvVuln(id);
}

const affecting = rows.filter((r) => r.osvAffecting.length || r.ghsaAffecting.length);
const historic = rows.filter(
  (r) => !affecting.includes(r) && (r.osvHistoric.length || r.ghsaHistoric.length),
);

const summary = {
  date: new Date().toISOString(),
  lockFile,
  sdk,
  counts: {
    total: packages.length,
    directMain: packages.filter((p) => p.dependency === 'direct main').length,
    directDev: packages.filter((p) => p.dependency === 'direct dev').length,
    transitive: packages.filter((p) => p.dependency === 'transitive').length,
    hosted: hosted.length,
    sdk: sdkPackages.length,
    other: others.length,
    ghsaPubAdvisories: ghsa.length,
  },
  failures,
  natives,
  affecting: affecting.map((r) => r.name),
  historic: historic.map((r) => r.name),
};

writeFileSync(
  join(outDir, 'dependencias.json'),
  JSON.stringify({ summary, rows, osvDetails }, null, 2),
);

// ------------------------------------------------------------ el informe
const md = [];
md.push('# T-113 · Dependencias contra OSV y GitHub Advisory', '');
md.push(`Fecha: ${summary.date}  `);
md.push(`Flutter ${sdk.flutter} (${sdk.channel}), Dart ${sdk.dart}  `);
md.push(
  `Paquetes en el lock: ${summary.counts.total} (directos ${summary.counts.directMain}, ` +
    `de desarrollo ${summary.counts.directDev}, transitivos ${summary.counts.transitive}; ` +
    `de pub.dev ${summary.counts.hosted}, del SDK ${summary.counts.sdk}, otros ${summary.counts.other})  `,
);
md.push(`Avisos de pub en GitHub Advisory: ${ghsa.length}  `);
md.push(`Fuentes que no respondieron: ${failures.length ? failures.join('; ') : 'ninguna'}`, '');
md.push('## Avisos que afectan a una versión del lock', '');
if (!affecting.length) md.push('Ninguno.', '');
for (const r of affecting) {
  md.push(`- **${r.name} ${r.version}** (${r.dependency})`);
  for (const id of r.osvAffecting) {
    const d = osvDetails[id];
    md.push(`  - OSV ${id}: ${d.summary ?? ''} (alias ${(d.aliases ?? []).join(', ') || '—'})`);
  }
  for (const g of r.ghsaAffecting) {
    md.push(`  - ${g.id} [${g.severity}] rango «${g.range}», corregido en ${g.patched ?? '—'}: ${g.summary}`);
  }
}
md.push('', '## Avisos históricos (la versión del lock ya no está en el rango)', '');
if (!historic.length) md.push('Ninguno.', '');
for (const r of historic) {
  md.push(`- **${r.name} ${r.version}** (${r.dependency})`);
  for (const id of r.osvHistoric) {
    const d = osvDetails[id];
    const fixed = (d.affected ?? [])
      .flatMap((a) => a.ranges ?? [])
      .flatMap((x) => x.events ?? [])
      .filter((e) => e.fixed)
      .map((e) => e.fixed);
    md.push(`  - OSV ${id}: ${d.summary ?? ''} (corregido en ${fixed.join(', ') || '—'})`);
  }
  for (const g of r.ghsaHistoric) {
    md.push(`  - ${g.id} [${g.severity}] rango «${g.range}», corregido en ${g.patched ?? '—'}`);
  }
}
md.push('', '## SDK nativos de Firebase (no están en el lock)', '');
md.push('| Componente | Paquete | Versión | Avisos en OSV |');
md.push('|---|---|---|---|');
for (const n of natives) {
  const osv = n.osv === null ? 'sin ecosistema o sin respuesta' : n.osv.length ? n.osv.join(', ') : 'ninguno';
  md.push(`| ${n.component} | ${n.ecosystem ?? '—'}:${n.name} | ${n.version ?? '—'} | ${osv} |`);
}
md.push('', '## Todos los paquetes', '');
md.push('| Paquete | Versión | Dependencia | Fuente | Afectan | Históricos |');
md.push('|---|---|---|---|---:|---:|');
for (const r of rows) {
  md.push(
    `| ${r.name} | ${r.version} | ${r.dependency} | ${r.source} | ` +
      `${r.osvAffecting.length + r.ghsaAffecting.length} | ` +
      `${r.osvHistoric.length + r.ghsaHistoric.length} |`,
  );
}
writeFileSync(join(outDir, 'dependencias.md'), md.join('\n') + '\n');

console.log(JSON.stringify(summary, null, 2));
process.exit(failures.length ? 2 : affecting.length ? 1 : 0);
