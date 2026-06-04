/* ============================================================================
 * BayStream — Prototipos Interactivos  ·  screens-2.js
 * Módulo 3 (RF-015..020 búsqueda) y Módulo 4 (RF-021..025 lista/stats)
 * ==========================================================================*/
window.SCREENS = window.SCREENS || {};

/* --------------------------------------------------------------------------
 * Buscador multicriterio (RF-015..020)
 * ------------------------------------------------------------------------*/
function searchMatch(c, qRaw) {
  var q = (qRaw || '').trim().toUpperCase();
  if (!q) return false;
  if (['REEFER', 'REFRIGERADO'].indexOf(q) >= 0) return c.isReefer;
  if (['IMO', 'DG', 'IMDG', 'PELIGROSO', 'DANGEROUS'].indexOf(q) >= 0) return c.isDangerous;
  if (['OOG', 'SOBREDIMENSION', 'SOBREDIMENSIÓN'].indexOf(q) >= 0) return c.isOOG;
  return (c.containerId.indexOf(q) >= 0) ||
    (!!c.pol && c.pol.toUpperCase().indexOf(q) >= 0) ||
    (!!c.pod && c.pod.toUpperCase().indexOf(q) >= 0) ||
    (!!c.operator && c.operator.toUpperCase().indexOf(q) >= 0);
}

function searchScreen(host, opts) {
  opts = opts || {};
  var state = { q: opts.initialQuery || '' };
  var KIND_ICON = { imo: '⚠', reefer: '❄', oog: '⤢' };

  function emptyHTML() {
    var carriers = DEMO.carriers(), ports = DEMO.ports();
    var carrierChips = Object.keys(carriers).sort().map(function (cr) {
      return '<span class="chip" data-suggest="' + cr + '">🚢 ' + cr + ' (' + carriers[cr] + ')</span>';
    }).join('');
    var portChips = Object.keys(ports).sort().map(function (p) {
      return '<span class="chip" data-suggest="' + p + '">📍 ' + p + ' (' + ports[p] + ')</span>';
    }).join('');
    return '<div class="search-stat-hero"><div class="ssh-ic">🔍</div>' +
      '<div class="ssh-num">' + DEMO.containers.length + ' contenedores disponibles</div>' +
      '<div class="muted" style="font-size:12px">Busca por ID, puerto de descarga, naviera o tipo de carga</div></div>' +
      '<div class="suggest-block"><div class="section-label">Navieras en este viaje</div><div class="chips">' + carrierChips + '</div></div>' +
      '<div class="suggest-block"><div class="section-label">Puertos de descarga</div><div class="chips">' + portChips + '</div></div>' +
      '<div class="suggest-block"><div class="section-label">Tipo de carga especial</div><div class="chips">' +
        '<span class="chip" data-suggest="reefer">❄ reefer</span>' +
        '<span class="chip" data-suggest="imo">⚠ imo</span>' +
        '<span class="chip" data-suggest="oog">⤢ oog</span></div></div>' +
      '<div class="tip-box">💡 Tip: escribe parte del ID (ej. «MSKU»), un puerto («HNPCR»), una naviera o «reefer» / «imo» / «oog».</div>';
  }

  function resultsHTML(q) {
    var matches = DEMO.containers.filter(function (c) { return searchMatch(c, q); });
    if (!matches.length) {
      return '<div class="no-results">🔍<div style="margin-top:10px">Sin coincidencias para «' + Proto.esc(q) + '»</div>' +
        '<div class="muted" style="font-size:12px;margin-top:6px">Prueba con otro ID, puerto, naviera o tipo de carga.</div></div>';
    }
    return '<div class="suggest-block"><div class="section-label">' + matches.length + ' resultado(s) para «' + Proto.esc(q) + '»</div></div>' +
      matches.map(function (c) {
        var kind = cargoKind(c), color = Proto.KIND_COLOR[kind];
        var icon = KIND_ICON[kind] || '📦';
        return '<div class="result-tile" data-go="' + Proto.esc(c.containerId) + '">' +
          '<div class="result-ic" style="color:' + color + ';border:1px solid ' + color + '">' + icon + '</div>' +
          '<div style="flex:1"><div class="ccard-id" style="font-size:13px">' + Proto.esc(c.containerId) + '</div>' +
          '<div class="muted" style="font-size:11px">' + Proto.esc(fmtPosition(c)) + ' · ' + Proto.esc(c.operator) + '</div></div>' +
          '<div style="text-align:right">' + (c.gross ? '<div style="font-size:12px">' + (c.gross / 1000).toFixed(1) + ' t</div>' : '') +
          '<div class="ccard-flags" style="justify-content:flex-end;margin-top:3px">' + Proto.flagsHTML(c) + '</div></div>' +
        '</div>';
      }).join('');
  }

  host.innerHTML = Proto.deviceShell({
    tab: null, appbar: false, pad0: true,
    body: '<div class="search-bar"><span class="sb-ic">←</span>' +
      '<input class="search-input" placeholder="Buscar contenedor o puerto..." value="' + Proto.esc(state.q) + '">' +
      '<span class="sb-ic" data-clear>✕</span></div>' +
      '<div id="search-results"></div>',
  });
  var dbody = host.querySelector('.device-body');
  var input = dbody.querySelector('.search-input');
  var resultsEl = dbody.querySelector('#search-results');

  function update() {
    resultsEl.innerHTML = state.q.trim() ? resultsHTML(state.q) : emptyHTML();
    Proto.qa(resultsEl, '[data-suggest]').forEach(function (el) {
      el.onclick = function () { state.q = el.getAttribute('data-suggest'); input.value = state.q; update(); input.focus(); };
    });
    Proto.qa(resultsEl, '[data-go]').forEach(function (el) {
      el.onclick = function () {
        var c = DEMO.findContainer(el.getAttribute('data-go'));
        // RF-019: navegación automática al Bay Plan con resaltado
        ScreenKit.bayPlan(host, { initialBay: c.bay, highlightId: c.containerId,
          hint: 'Contenedor ' + c.containerId + ' resaltado en BAY ' + Proto.pad(c.bay, 2) });
      };
    });
  }
  input.oninput = function () { state.q = input.value; update(); };
  dbody.querySelector('[data-clear]').onclick = function () { state.q = ''; input.value = ''; update(); input.focus(); };
  update();
  setTimeout(function () { input.focus(); }, 30);
}

/* RF-015..020 */
SCREENS['RF-015'] = function (host) { searchScreen(host, { initialQuery: 'MSKU' }); };
SCREENS['RF-016'] = function (host) { searchScreen(host, { initialQuery: 'HNPCR' }); };
SCREENS['RF-017'] = function (host) { searchScreen(host, { initialQuery: 'MSC' }); };
SCREENS['RF-018'] = function (host) { searchScreen(host, { initialQuery: 'reefer' }); };
SCREENS['RF-019'] = function (host) { searchScreen(host, { initialQuery: 'MSKU' }); };
SCREENS['RF-020'] = function (host) { searchScreen(host, { initialQuery: '' }); };

/* --------------------------------------------------------------------------
 * MÓDULO 4 — Lista y Filtrado (RF-021..023 reutilizan listaScreen)
 * ------------------------------------------------------------------------*/
SCREENS['RF-021'] = function (host) { ScreenKit.listaScreen(host, {}); };
SCREENS['RF-022'] = function (host) { ScreenKit.listaScreen(host, {}); };
SCREENS['RF-023'] = function (host) { ScreenKit.listaScreen(host, {}); };

/* RF-024 — Dashboard Estadístico */
function statsBody() {
  var list = DEMO.containers;
  var total = list.length;
  var full = list.filter(function (c) { return c.status === 'full'; }).length;
  var empty = total - full;
  var reefers = list.filter(function (c) { return c.isReefer; }).length;
  var imos = list.filter(function (c) { return c.isDangerous; }).length;
  var oogs = list.filter(function (c) { return c.isOOG; }).length;

  function metric(ic, num, lbl, color) {
    return '<div class="metric"><div class="m-ic">' + ic + '</div>' +
      '<div class="m-num" style="color:' + (color || 'var(--text)') + '">' + num + '</div>' +
      '<div class="m-lbl">' + lbl + '</div></div>';
  }
  var metrics = '<div class="metric-grid">' +
    metric('📦', total, 'Contenedores') +
    metric('▦', DEMO.bays.length, 'Bahías') +
    metric('⚖', DEMO.totalWeightTon() + ' t', 'Peso bruto') +
    metric('🟩', full, 'Llenos', 'var(--c-full)') +
    metric('🟧', empty, 'Vacíos', 'var(--c-empty)') +
    metric('❄', reefers, 'Reefers', 'var(--c-reefer)') +
    '</div>';

  // Pie lleno/vacío
  var fullDeg = total ? Math.round(full / total * 360) : 0;
  var pie = '<div class="panel"><h4>Distribución por estado</h4><div class="pie-wrap">' +
    '<div class="pie" style="background:conic-gradient(var(--c-full) 0 ' + fullDeg + 'deg, var(--c-empty) ' + fullDeg + 'deg 360deg)"></div>' +
    '<div class="pie-legend">' +
      '<div><span class="dot" style="background:var(--c-full)"></span> Llenos · ' + full + ' (' + Math.round(full / total * 100) + '%)</div>' +
      '<div><span class="dot" style="background:var(--c-empty)"></span> Vacíos · ' + empty + ' (' + Math.round(empty / total * 100) + '%)</div>' +
    '</div></div></div>';

  // Distribución por tamaño
  var s20 = list.filter(function (c) { return c.sizeFeet === 20; }).length;
  var s40 = list.filter(function (c) { return c.sizeFeet === 40; }).length;
  var s45 = list.filter(function (c) { return c.sizeFeet === 45; }).length;
  function seg(val, color, label) {
    if (!val) return '';
    return '<div class="size-seg" style="flex:' + val + ';background:' + color + '">' + label + ': ' + val + '</div>';
  }
  var sizeBar = '<div class="panel"><h4>Distribución por tamaño</h4><div class="size-bar">' +
    seg(s20, 'var(--c-full)', '20′') + seg(s40, 'var(--c-reefer)', '40′') + seg(s45, 'var(--c-empty)', '45′') +
    '</div></div>';

  // Carga especial
  var special = '<div class="panel"><h4>Carga especial</h4><div class="special-cards">' +
    '<div class="special-card imo"><div class="sc-num">' + imos + '</div>⚠ Peligrosa (IMO)</div>' +
    '<div class="special-card reefer"><div class="sc-num">' + reefers + '</div>❄ Refrigerada</div>' +
    '<div class="special-card oog"><div class="sc-num">' + oogs + '</div>⤢ Sobredimensión</div>' +
    '</div></div>';

  // Barras por naviera
  var carriers = DEMO.carriers();
  var maxCarrier = Math.max.apply(null, Object.keys(carriers).map(function (k) { return carriers[k]; }));
  function barRow(lbl, val, max) {
    return '<div class="bar-row"><div class="br-lbl">' + Proto.esc(lbl) + '</div>' +
      '<div class="bar-track"><div class="bar-fill" style="width:' + (val / max * 100) + '%"></div></div>' +
      '<div class="br-val">' + val + '</div></div>';
  }
  var byCarrier = '<div class="panel"><h4>Distribución por naviera</h4>' +
    Object.keys(carriers).sort().map(function (k) { return barRow(k, carriers[k], maxCarrier); }).join('') + '</div>';

  // Barras por bahía
  var maxBay = Math.max.apply(null, DEMO.bays.map(function (b) { return DEMO.containersByBay(b.bayNumber).length; }));
  var byBay = '<div class="panel"><h4>Contenedores por bahía</h4>' +
    DEMO.bays.map(function (b) { return barRow('BAY ' + Proto.pad(b.bayNumber, 2), DEMO.containersByBay(b.bayNumber).length, maxBay); }).join('') + '</div>';

  // Barras por puerto
  var ports = DEMO.ports();
  var maxPort = Math.max.apply(null, Object.keys(ports).map(function (k) { return ports[k]; }));
  var byPort = '<div class="panel"><h4>Distribución por puerto de descarga</h4>' +
    Object.keys(ports).sort().map(function (k) { return barRow(k, ports[k], maxPort); }).join('') + '</div>';

  return metrics + '<div class="grid-2">' + pie + sizeBar + '</div>' + special +
    '<div class="grid-2">' + byCarrier + byBay + '</div>' + byPort;
}
SCREENS['RF-024'] = function (host) {
  host.innerHTML = Proto.deviceShell({ tab: 'stats', appbar: true, body: statsBody() });
};

/* RF-025 — Exportación de Reporte en PDF */
SCREENS['RF-025'] = function (host) {
  function pdfPreview() {
    var rows = DEMO.containers.map(function (c) {
      return '<tr><td>' + Proto.esc(c.containerId) + '</td><td>' + Proto.esc(c.isoSizeType) + '</td><td>' +
        (c.status === 'full' ? 'Lleno' : 'Vacío') + '</td><td>' + Proto.esc(fmtPosition(c)) + '</td><td>' +
        (c.gross || 0) + ' kg</td></tr>';
    }).join('');
    return '<div class="sheet-handle"></div>' +
      '<div class="sheet-title"><span class="sheet-id" style="font-size:16px">📄 Vista previa del reporte</span></div>' +
      '<div class="preview-doc" style="margin-top:12px">' +
        '<h3>BayStream — Reporte de Viaje</h3>' +
        '<div>Buque: <b>' + DEMO.vessel.name + '</b> · Viaje ' + DEMO.voyage.voyageNumber + ' · Bandera ' + DEMO.vessel.flagName + '</div>' +
        '<div>Ruta: ' + DEMO.voyage.portOfLoading + ' → ' + DEMO.voyage.portOfDischarge + '</div>' +
        '<div>Total: ' + DEMO.containers.length + ' contenedores · ' + DEMO.bays.length + ' bahías · ' + DEMO.totalWeightTon() + ' t</div>' +
        '<table><tr><th>BIC</th><th>ISO</th><th>Estado</th><th>Posición</th><th>Peso</th></tr>' + rows + '</table>' +
      '</div>' +
      '<div style="display:flex;gap:8px;justify-content:flex-end;margin-top:14px">' +
        '<button class="btn btn-outline" data-close>Cancelar</button>' +
        '<button class="btn btn-soft" data-save>📤 Compartir</button>' +
        '<button class="btn btn-primary" data-save>💾 Guardar PDF</button>' +
      '</div>';
  }
  var body = Proto.voyageCardHTML() +
    '<div class="panel" style="margin-top:16px"><h4>📄 Exportación de Reporte en PDF</h4>' +
    '<div class="muted" style="font-size:13px">Genera un reporte PDF con el resumen del viaje, estadísticas, distribución por naviera/puerto, listado de carga especial y un Bay Plan simplificado. Se genera localmente, sin conexión a internet.</div>' +
    '<button class="btn btn-primary" data-export style="margin-top:14px">📄 Generar reporte PDF</button></div>';
  host.innerHTML = Proto.deviceShell({ tab: 'stats', appbar: true, body: body });
  var dbody = host.querySelector('.device-body');
  dbody.querySelector('[data-export]').onclick = function () {
    var ov = Proto.showSheet(dbody, pdfPreview());
    Proto.qa(ov, '[data-save]').forEach(function (b) {
      b.onclick = function () { Proto.closeSheet(dbody); Proto.toast(dbody, 'Reporte PDF generado y guardado'); };
    });
  };
};
