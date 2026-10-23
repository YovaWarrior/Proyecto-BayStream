// Dibuja cada glifo de la TTF como texto en Chromium (Skia, el mismo motor que Flutter) y el SVG del ícono
// al lado, y captura cada celda como PNG del tamaño exacto. Lo llama comprobar_skia.py.
//   NODE_PATH=$(npm root -g) node comprobar_skia.js pagina.html carpeta_salida
const fs = require('fs');
const path = require('path');
const { chromium } = require('playwright');
(async () => {
  const [, , entrada, salida] = process.argv;
  const b = await chromium.launch();
  const p = await b.newPage({ viewport: { width: 1200, height: 900 }, deviceScaleFactor: 1 });
  await p.goto('file://' + path.resolve(entrada));
  await p.evaluate(() => document.fonts.ready);
  await p.waitForTimeout(500);
  const celdas = await p.$$('[data-celda]');
  for (const c of celdas) {
    const id = await c.getAttribute('data-celda');
    await c.screenshot({ path: path.join(salida, id + '.png'), omitBackground: false });
  }
  console.log(celdas.length);
  await b.close();
})();
