/* ============================================================================
 * BayStream — Prototipos Interactivos  ·  components.js
 * Librería de componentes reutilizables (window.Proto).
 * Cada builder devuelve HTML; las pantallas lo insertan y enganchan eventos.
 * ==========================================================================*/
window.Proto = (function () {
  var P = {};

  /* ---- Utilidades ---- */
  P.esc = function (s) {
    return String(s == null ? '' : s)
      .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;');
  };
  P.pad = function (n, l) { return String(n).padStart(l, '0'); };
  P.q = function (root, sel) { return root.querySelector(sel); };
  P.qa = function (root, sel) { return Array.prototype.slice.call(root.querySelectorAll(sel)); };

  var KIND_COLOR = {
    full: 'var(--c-full)', empty: 'var(--c-empty)', reefer: 'var(--c-reefer)',
    imo: 'var(--c-imo)', oog: 'var(--c-oog)', none: 'var(--c-none)',
  };
  var KIND_ICON = { imo: '⚠', reefer: '❄', oog: '⤢' };
  P.KIND_COLOR = KIND_COLOR;

  P.matchesFilter = function (c, filter) {
    switch (filter) {
      case 'full': return c.status === 'full';
      case 'empty': return c.status === 'empty';
      case 'imo': return c.isDangerous;
      case 'reefer': return c.isReefer;
      case 'oog': return c.isOOG;
      default: return true;
    }
  };

  /* ---- Banderas / chips de carga de una tarjeta ---- */
  P.flagsHTML = function (c) {
    var f = [];
    if (c.operator) f.push('<span class="flag flag-op">' + P.esc(c.operator) + '</span>');
    if (c.isDangerous) f.push('<span class="flag flag-imo">IMO ' + P.esc(c.imdgClass || '') + '</span>');
    if (c.isReefer) f.push('<span class="flag flag-reefer">REEFER</span>');
    if (c.isOOG) f.push('<span class="flag flag-oog">OOG</span>');
    f.push(c.status === 'full'
      ? '<span class="flag flag-full">LLENO</span>'
      : c.status === 'empty' ? '<span class="flag flag-empty">VACÍO</span>' : '');
    return f.join('');
  };

  /* ---- Chrome de la aplicación (ventana + tabs) ---- */
  function tabbarHTML(active) {
    var tabs = [
      { k: 'lista', ic: '☰', label: 'Lista' },
      { k: 'bayplan', ic: '▦', label: 'Bay Plan' },
      { k: 'stats', ic: '📊', label: 'Estadísticas' },
    ];
    return '<div class="device-tabbar">' + tabs.map(function (t) {
      return '<div class="tab' + (t.k === active ? ' active' : '') + '">' +
        '<span class="tab-ic">' + t.ic + '</span><span>' + t.label + '</span></div>';
    }).join('') + '</div>';
  }

  /**
   * deviceShell(opts)
   *  opts.tab     : 'lista' | 'bayplan' | 'stats' | null  (pestaña activa)
   *  opts.appbar  : bool  (mostrar barra "BayStream" + iconos)
   *  opts.body    : HTML del cuerpo
   *  opts.pad0    : bool  (sin padding en el cuerpo)
   *  opts.title   : título de la ventana (def "BayStream")
   */
  P.deviceShell = function (opts) {
    opts = opts || {};
    var title = opts.title || 'BayStream';
    var appbar = opts.appbar;
    var tab = opts.tab || null;
    var titlebar =
      '<div class="device-titlebar">' +
        '<div class="tb-left">' +
          '<span class="tb-dot" style="background:#ff5f57"></span>' +
          '<span class="tb-dot" style="background:#febc2e"></span>' +
          '<span class="tb-dot" style="background:#28c840"></span>' +
          '<span class="device-title">⛴ ' + P.esc(title) + '</span>' +
        '</div>' +
        '<div class="win-ctrls"><span>—</span><span>▢</span><span>✕</span></div>' +
      '</div>';
    var appbarHTML = appbar
      ? '<div class="device-appbar"><span class="ab-title">BayStream</span>' +
        '<span class="ab-ic" title="Buscar">🔍</span>' +
        '<span class="ab-ic" title="Cargar otro">🗎</span>' +
        '<span class="ab-ic" title="Limpiar">✕</span></div>'
      : '';
    return '<div class="device">' + titlebar + appbarHTML +
      (tab ? tabbarHTML(tab) : '') +
      '<div class="device-body' + (opts.pad0 ? ' pad-0' : '') + '">' + (opts.body || '') + '</div>' +
      '</div>';
  };

  /* ---- Tarjeta de resumen del viaje (RF-023) ---- */
  P.voyageCardHTML = function () {
    var v = DEMO.vessel, vo = DEMO.voyage;
    return '' +
      '<div class="voyage-card">' +
        '<div class="voyage-top">' +
          '<div class="voyage-icon">🚢</div>' +
          '<div><div class="voyage-name">' + P.esc(v.name) + '</div>' +
          '<div class="voyage-tags">' +
            '<span class="vtag">⚑ Viaje ' + P.esc(vo.voyageNumber) + '</span>' +
            '<span class="vtag">🏳 ' + P.esc(v.flagName) + ' (' + P.esc(v.flag) + ')</span>' +
            '<span class="vtag">IMO ' + P.esc(v.imoNumber) + '</span>' +
          '</div></div>' +
        '</div>' +
        '<div class="voyage-stats">' +
          vstat('📦', DEMO.containers.length, 'Contenedores') +
          vstat('▦', DEMO.bays.length, 'Bahías') +
          vstat('⚖', DEMO.totalWeightTon() + 't', 'Peso Total') +
        '</div>' +
        '<div class="voyage-meta">' +
          '<span>📨 Mensaje: ' + P.esc(vo.messageType) + ' ' + P.esc(vo.baplieVersion) + '</span>' +
          '<span>🗓 ' + P.esc(vo.preparationDate) + '</span>' +
          '<span>📍 ' + P.esc(vo.portOfLoading) + ' → ' + P.esc(vo.portOfDischarge) + '</span>' +
        '</div>' +
      '</div>';
  };
  function vstat(ic, num, lbl) {
    return '<div class="vstat"><div class="v-ic">' + ic + '</div>' +
      '<div class="v-num">' + P.esc(num) + '</div><div class="v-lbl">' + P.esc(lbl) + '</div></div>';
  }

  /* ---- Chips de filtro por naviera (RF-022) ---- */
  P.carrierChipsHTML = function (active) {
    var carriers = DEMO.carriers();
    var html = '<div class="section-label">Filtrar por Naviera</div><div class="chips">';
    html += '<span class="chip' + (active == null ? ' active' : '') + '" data-carrier="all">Todas (' + DEMO.containers.length + ')</span>';
    Object.keys(carriers).sort().forEach(function (cr) {
      html += '<span class="chip' + (active === cr ? ' active' : '') + '" data-carrier="' + cr + '">' +
        cr + ' (' + carriers[cr] + ')</span>';
    });
    return html + '</div>';
  };

  /* ---- Chips estadísticos rápidos llenos/vacíos ---- */
  P.statChipsHTML = function (list) {
    var full = list.filter(function (c) { return c.status === 'full'; }).length;
    var empty = list.filter(function (c) { return c.status === 'empty'; }).length;
    return '<span class="chip chip-stat full">' + full + ' llenos</span>' +
           '<span class="chip chip-stat empty">' + empty + ' vacíos</span>';
  };

  /* ---- Tarjeta de contenedor para la lista (RF-021) ---- */
  P.containerCardHTML = function (c) {
    var info = '<div>📍 <b>' + P.esc(fmtPosition(c)) + '</b></div>' +
               '<div>⚖ <b>' + (c.gross != null ? c.gross + ' kg' : 'N/A') + '</b></div>' +
               '<div>📍 Destino <b>' + P.esc(c.pod || 'N/A') + '</b></div>';
    return '<div class="ccard" data-cid="' + P.esc(c.containerId) + '">' +
      '<div class="ccard-top">' +
        '<span class="ccard-id">' + P.esc(c.containerId) + '</span>' +
        '<span class="ccard-type">' + P.esc(c.isoSizeType) + ' · ' + c.sizeFeet + 'ft</span>' +
        '<span class="ccard-flags">' + P.flagsHTML(c) + '</span>' +
      '</div>' +
      '<div class="ccard-info">' + info + '</div>' +
    '</div>';
  };

  /* ---- Selector de bahías (RF-007 / RF-014) ---- */
  P.baySelectorHTML = function (selectedBay) {
    var chips = DEMO.bays.map(function (b) {
      var list = DEMO.containersByBay(b.bayNumber);
      var occColor = 'var(--primary)';
      return '<div class="bay-chip' + (b.bayNumber === selectedBay ? ' active' : '') + '" data-bay="' + b.bayNumber + '">' +
        '<div class="bc-name">BAY ' + P.pad(b.bayNumber, 2) + ' (' + b.occupancy + '%)</div>' +
        '<div class="bc-count">' + list.length + ' cont.</div>' +
        '<div class="bc-occ" style="width:' + Math.max(18, b.occupancy * 10) + '%;background:' + occColor + '"></div>' +
      '</div>';
    }).join('');
    return '<div class="bay-selector">' +
      '<button class="arrow" data-bay-nav="-1">‹</button>' +
      '<div class="bay-chips">' + chips + '</div>' +
      '<button class="arrow" data-bay-nav="1">›</button>' +
    '</div>';
  };

  /* ---- Grid de una bahía (RF-006/008/009/010/012/013) ---- */
  P.bayGridHTML = function (bayNumber, opts) {
    opts = opts || {};
    var list = DEMO.containersByBay(bayNumber);
    var bay = DEMO.bays.find(function (b) { return b.bayNumber === bayNumber; });
    if (!list.length) {
      return '<div class="bay-canvas"><div class="bay-name">BAY ' + P.pad(bayNumber, 2) + '</div>' +
        '<div class="bay-meta">Sin contenedores</div></div>';
    }
    var minRow = 99, maxRow = 0, minTier = 99, maxTier = 0;
    list.forEach(function (c) {
      if (c.row < minRow) minRow = c.row; if (c.row > maxRow) maxRow = c.row;
      if (c.tier < minTier) minTier = c.tier; if (c.tier > maxTier) maxTier = c.tier;
    });
    var even = [], odd = [];
    for (var r = minRow; r <= maxRow; r++) { (r % 2 === 0 ? even : odd).push(r); }
    even.sort(function (a, b) { return b - a; }); odd.sort(function (a, b) { return a - b; });
    var rows = even.concat(odd);

    var deck = [], hold = [];
    for (var t = maxTier; t >= minTier; t -= 2) { (t >= 80 ? deck : hold).push(t); }

    var posMap = {};
    list.forEach(function (c) { posMap[c.row + '-' + c.tier] = c; });

    var weightTon = (list.reduce(function (s, c) { return s + (c.gross || 0); }, 0) / 1000).toFixed(1);

    var html = '<div class="bay-canvas">' +
      '<div class="bay-name">BAY ' + P.pad(bayNumber, 2) + '</div>' +
      '<div class="bay-meta">' + list.length + ' contenedores · ' + weightTon + ' ton' +
      (bay ? ' · ' + bay.occupancy + '% ocupación' : '') + '</div>';

    // Encabezado de filas
    html += '<div class="grid-row"><div class="grid-axis"></div>' +
      rows.map(function (r) { return '<div class="grid-axis" style="width:52px">' + P.pad(r, 2) + '</div>'; }).join('') +
      (opts.showWeights ? '<div class="weight-axis">peso/tier</div>' : '') + '</div>';

    function tierRow(t) {
      var cells = rows.map(function (r) { return cellHTML(posMap[r + '-' + t], opts); }).join('');
      var weight = '';
      if (opts.showWeights) {
        var tw = rows.reduce(function (s, r) { var c = posMap[r + '-' + t]; return s + (c ? (c.gross || 0) : 0); }, 0);
        var bars = '▏'.repeat(Math.max(1, Math.round(tw / 8000)));
        weight = '<div class="weight-axis">' + (tw / 1000).toFixed(1) + 't <span style="color:var(--primary)">' + bars + '</span></div>';
      }
      return '<div class="grid-row"><div class="grid-axis">' + P.pad(t, 2) + '</div>' + cells + weight + '</div>';
    }

    if (deck.length) {
      html += '<div class="zone-label zone-deck">▲ CUBIERTA (DECK)</div>';
      html += deck.map(tierRow).join('');
    }
    if (deck.length && hold.length) html += '<div class="hatch"></div>';
    if (hold.length) {
      html += '<div class="zone-label zone-hold">▼ BODEGA (HOLD)</div>';
      html += hold.map(tierRow).join('');
    }
    html += '</div>';
    return html;
  };

  function cellHTML(c, opts) {
    if (!c) return '<div class="cell"></div>';
    var kind = cargoKind(c);
    var cls = 'cell occupied ' + kind;
    if (opts.activeFilter && !P.matchesFilter(c, opts.activeFilter)) cls += ' dim';
    if (opts.highlightId && c.containerId === opts.highlightId) cls += ' highlight';
    var inner = KIND_ICON[kind] || c.sizeFeet;
    return '<div class="' + cls + '" data-cid="' + P.esc(c.containerId) + '" title="' + P.esc(c.containerId) + '">' +
      '<span>' + inner + '</span>' +
      (c.operator ? '<span class="cell-op">' + P.esc(c.operator) + '</span>' : '') +
    '</div>';
  }

  /* ---- Leyenda interactiva (RF-008 / RF-011) ---- */
  P.legendHTML = function (activeFilter, interactive) {
    var items = [
      { k: 'full', label: 'Lleno' }, { k: 'empty', label: 'Vacío / OOG' },
      { k: 'imo', label: 'IMO' }, { k: 'reefer', label: 'Reefer' },
      { k: 'oog', label: 'OOG' }, { k: 'none', label: 'Sin contenedor' },
    ];
    return '<div class="legend">' + items.map(function (it) {
      var filterable = it.k !== 'none';
      var active = interactive && filterable && activeFilter === it.k;
      return '<div class="legend-item' + (active ? ' active' : '') + '"' +
        (interactive && filterable ? ' data-filter="' + it.k + '"' : '') + '>' +
        '<span class="legend-swatch" style="background:' + KIND_COLOR[it.k] + '"></span>' + it.label + '</div>';
    }).join('') + '</div>';
  };

  /* ---- Hoja de detalle de contenedor (RF-010) ---- */
  P.detailSheetHTML = function (c) {
    function row(k, v) { return '<div class="detail-row"><span class="dr-k">' + k + '</span><span class="dr-v">' + P.esc(v) + '</span></div>'; }
    var html = '<div class="sheet-handle"></div>' +
      '<div class="sheet-title"><span class="sheet-id">' + P.esc(c.containerId) + '</span>' +
        (c.operator ? '<span class="flag flag-op" style="font-size:12px">' + P.esc(c.operator) + '</span>' : '') + '</div>' +
      '<div class="kv-list" style="margin-top:14px">' +
        row('Posición', fmtPosition(c)) +
        row('Tipo ISO', c.isoSizeType + ' (' + c.sizeFeet + 'ft)') +
        row('Estado', c.status === 'full' ? 'LLENO' : c.status === 'empty' ? 'VACÍO' : 'Desconocido') +
        row('Peso Bruto', (c.gross != null ? c.gross + ' kg' : 'N/A')) +
        row('Peso VGM (SOLAS)', (c.vgm != null ? c.vgm + ' kg' : 'N/A')) +
        row('Puerto Carga', c.pol || 'N/A') +
        row('Puerto Descarga', c.pod || 'N/A') +
      '</div>';
    if (c.isDangerous) {
      html += '<div class="danger-box"><div class="db-title">⚠ MERCANCÍA PELIGROSA</div>' +
        '<div class="detail-row"><span class="dr-k">Clase IMO</span><span class="dr-v">' + P.esc(c.imdgClass) + '</span></div>' +
        '<div class="detail-row" style="border:none"><span class="dr-k">Número ONU</span><span class="dr-v">' + P.esc(c.unNumber) + '</span></div></div>';
    }
    if (c.isReefer) {
      html += '<div class="reefer-box"><div class="rb-title">❄ REFRIGERADO</div>' +
        '<div class="detail-row" style="border:none"><span class="dr-k">Temperatura</span><span class="dr-v">' +
        P.esc(c.temp) + ' °' + P.esc(c.tempUnit || 'C') + '</span></div></div>';
    }
    if (c.isOOG) {
      html += '<div class="danger-box" style="background:rgba(255,112,67,.1);border-color:rgba(255,112,67,.35)">' +
        '<div class="db-title" style="color:var(--c-oog)">⤢ SOBREDIMENSIONADO (OOG)</div>' +
        '<div class="detail-row" style="border:none"><span class="dr-k">Sobre-altura</span><span class="dr-v">' +
        P.esc(c.overHeight) + ' cm</span></div></div>';
    }
    html += '<button class="btn btn-outline btn-block" data-close style="margin-top:18px">Cerrar</button>';
    return html;
  };

  /* ---- Interacciones: snackbar y bottom-sheet ---- */
  P.toast = function (bodyEl, msg, isErr) {
    var old = bodyEl.querySelector('.snackbar'); if (old) old.remove();
    var s = document.createElement('div');
    s.className = 'snackbar' + (isErr ? ' err' : '');
    s.innerHTML = (isErr ? '⚠ ' : '✓ ') + P.esc(msg);
    bodyEl.appendChild(s);
    setTimeout(function () { if (s.parentNode) s.remove(); }, 2800);
  };
  P.closeSheet = function (bodyEl) {
    var ov = bodyEl.querySelector('.sheet-overlay'); if (ov) ov.remove();
  };
  P.showSheet = function (bodyEl, contentHTML) {
    P.closeSheet(bodyEl);
    var ov = document.createElement('div');
    ov.className = 'sheet-overlay';
    ov.innerHTML = '<div class="sheet">' + contentHTML + '</div>';
    ov.addEventListener('click', function (e) { if (e.target === ov) P.closeSheet(bodyEl); });
    P.qa(ov, '[data-close]').forEach(function (b) { b.addEventListener('click', function () { P.closeSheet(bodyEl); }); });
    bodyEl.appendChild(ov);
    return ov;
  };

  /* Enlaza el click de las celdas/tarjetas con el modal de detalle */
  P.wireDetailTargets = function (bodyEl) {
    P.qa(bodyEl, '[data-cid]').forEach(function (el) {
      el.addEventListener('click', function () {
        var c = DEMO.findContainer(el.getAttribute('data-cid'));
        if (c) P.showSheet(bodyEl, P.detailSheetHTML(c));
      });
    });
  };

  return P;
})();
