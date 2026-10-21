// T-113 · Las reglas publicadas contra la propuesta de T-80.
//
// Compara el texto que Carlos copió de la consola con
// docs/T80-firestore.rules.propuesta. Da tres huellas SHA-256 de cada uno:
//   - cruda: los bytes del archivo, tal cual;
//   - LF: con los finales de línea normalizados a LF y sin BOM;
//   - normalizada: además, sin espacios al final de cada línea ni líneas
//     vacías al final del archivo (lo que cambia al copiar de un navegador).
// `21894B7F…` es la cruda de la copia de trabajo, que mezcla CRLF y LF; el
// blob versionado es LF. Si la normalizada no coincide, lista las líneas que
// difieren (las reglas no son secretas).
//
// Uso:
//
//     node tool/t113_reglas.mjs <reglas-publicadas.txt> [carpeta de salida]
//
// Sale con 0 si la huella normalizada coincide, 1 si no y 2 si falta un archivo.

import { createHash } from 'node:crypto';
import { existsSync, mkdirSync, readFileSync, writeFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const published = process.argv[2];
const outDir = process.argv[3] ?? join(root, 'build', 't113');
const proposal = join(root, 'docs', 'T80-firestore.rules.propuesta');

if (!published || !existsSync(published)) {
  console.error(`No está el texto publicado: ${published ?? '(sin ruta)'}`);
  process.exit(2);
}

const sha = (data) => createHash('sha256').update(data).digest('hex').toUpperCase();
const lf = (buf) => buf.toString('utf8').replace(/^﻿/, '').replace(/\r\n?/g, '\n');
const normalized = (buf) =>
  lf(buf)
    .split('\n')
    .map((l) => l.replace(/[ \t ]+$/, ''))
    .join('\n')
    .replace(/\n+$/, '\n');

function prints(file) {
  const buf = readFileSync(file);
  return {
    file,
    bytes: buf.length,
    lines: lf(buf).split('\n').length,
    crlf: (buf.toString('latin1').match(/\r\n/g) ?? []).length,
    raw: sha(buf),
    lf: sha(lf(buf)),
    normalized: sha(normalized(buf)),
  };
}

const a = prints(proposal);
const b = prints(published);
const equal = a.normalized === b.normalized;

const differences = [];
if (!equal) {
  const x = normalized(readFileSync(proposal)).split('\n');
  const y = normalized(readFileSync(published)).split('\n');
  for (let i = 0; i < Math.max(x.length, y.length) && differences.length < 40; i++) {
    if (x[i] !== y[i]) differences.push({ line: i + 1, proposal: x[i] ?? null, published: y[i] ?? null });
  }
}

const result = { date: new Date().toISOString(), proposal: a, published: b, equal, differences };
mkdirSync(outDir, { recursive: true });
writeFileSync(join(outDir, 'reglas-cotejo.json'), JSON.stringify(result, null, 2));
console.log(JSON.stringify(result, null, 2));
process.exit(equal ? 0 : 1);
