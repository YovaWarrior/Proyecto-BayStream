/* ============================================================================
 * BayStream — Prototipos Interactivos  ·  screens-1.js
 * Módulo 1 (RF-001..005) y Módulo 2 (RF-006..014)
 * ==========================================================================*/
window.SCREENS = window.SCREENS || {};

/* --------------------------------------------------------------------------
 * ScreenKit: factorías compartidas (lista y bay plan) reutilizadas por
 * varias pantallas y por los módulos 3-4.
 * ------------------------------------------------------------------------*/
window.ScreenKit = (function () {
  var K = {};

  /* Cuerpo de la pestaña "Lista" (RF-021/022/023) */
  K.listaBody = function (carrier) {
    var list = carrier ? DEMO.containers.filter(function (c) { return c.operator === carrier; }) : DEMO.containers;
    return Proto.voyageCardHTML() +
      '<div style="margin-top:16px">' + Proto.carrierChipsHTML(carrier) + '</div>' +
      '<div class="list-title"><h4>Contenedores (' + list.length + ')</h4>' +
      '<div class="chips">' + Proto.statChipsHTML(list) + '</div></div>' +
      list.map(Proto.containerCardHTML).join('');
  };

  /* Pantalla completa "Lista" con chips reactivos y detalle */
  K.listaScreen = function (host, opts) {
    opts = opts || {};
    var state = { carrier: null };
    function render() {
      host.innerHTML = Proto.deviceShell({ tab: 'lista', appbar: true, body: K.listaBody(state.carrier) });
      var dbody = host.querySelector('.device-body');
      Proto.qa(dbody, '[data-carrier]').forEach(function (el) {
        el.onclick = function () {
          var cr = el.getAttribute('data-carrier');
          state.carrier = cr === 'all' ? null : cr;
          render();
        };
      });
      Proto.wireDetailTargets(dbody);
      if (opts.withToast) { Proto.toast(dbody, "Archivo 'test_baystream_demo.edi' cargado correctamente"); opts.withToast = false; }
    }
    render();
  };

  /* Pantalla completa "Bay Plan" parametrizable (RF-006..014) */
  K.bayPlan = function (host, opts) {
    opts = opts || {};
    var nums = DEMO.bays.map(function (b) { return b.bayNumber; });
    var state = { bay: opts.initialBay || nums[0], filter: null };
    function render() {
      var body =
        Proto.baySelectorHTML(state.bay) +
        Proto.bayGridHTML(state.bay, {
          showWeights: opts.showWeights,
          activeFilter: state.filter,
          highlightId: opts.highlightId && state.bay === (opts.initialBay || nums[0]) ? opts.highlightId : null,
        }) +
        Proto.legendHTML(state.filter, opts.interactiveLegend);
      host.innerHTML = Proto.deviceShell({ tab: 'bayplan', appbar: true, body: body, pad0: true });
      var dbody = host.querySelector('.device-body');
      Proto.qa(dbody, '[data-bay]').forEach(function (el) {
        el.onclick = function () { state.bay = +el.getAttribute('data-bay'); state.filter = null; render(); };
      });
      Proto.qa(dbody, '[data-bay-nav]').forEach(function (el) {
        el.onclick = function () {
          var i = nums.indexOf(state.bay) + (+el.getAttribute('data-bay-nav'));
          i = Math.min(nums.length - 1, Math.max(0, i));
          state.bay = nums[i]; state.filter = null; render();
        };
      });
      if (opts.interactiveLegend) {
        Proto.qa(dbody, '[data-filter]').forEach(function (el) {
          el.onclick = function () {
            var f = el.getAttribute('data-filter');
            state.filter = state.filter === f ? null : f;
            render();
          };
        });
      }
      Proto.wireDetailTargets(dbody);
      if (opts.hint) Proto.toast(dbody, opts.hint);
    }
    render();
  };

  return K;
})();

/* ==========================================================================
 * MÓDULO 1 — Carga y Procesamiento de Datos
 * ========================================================================*/

/* RF-001 — Selección y Carga de Archivo BAPLIE */
SCREENS['RF-001'] = function (host) {
  function emptyBody() {
    return '<div class="center-col empty-hero">' +
      '<div class="empty-boat">⛴</div>' +
      '<div class="empty-title">BayStream</div>' +
      '<div class="empty-sub">Gestión de Carga Marítima</div>' +
      '<div class="upload-card center-col">' +
        '<div class="up-ic">📂</div>' +
        '<div style="font-weight:700;margin:8px 0 4px">Cargar archivo BAPLIE</div>' +
        '<div class="muted" style="font-size:12px;margin-bottom:14px;max-width:340px">Seleccione un archivo .edi o .txt con formato BAPLIE 2.2.1 para visualizar el plan de estiba del buque.</div>' +
        '<button class="btn btn-outline" data-pick-open>📂 Seleccionar archivo</button>' +
        '<div class="hint">Formatos soportados: .edi, .txt, .baplie</div>' +
      '</div>' +
      '<button class="fab" data-pick-open>📥 Cargar BAPLIE</button>' +
    '</div>';
  }
  function pickerHTML() {
    return '<div class="sheet-handle"></div>' +
      '<h4 style="margin:0 0 4px">Abrir — Seleccionar archivo BAPLIE</h4>' +
      '<div class="muted" style="font-size:12px;margin-bottom:12px">Este equipo › Windows (C:) › Proyectos · Filtro: <b>*.edi; *.txt; *.baplie</b></div>' +
      '<div class="recent-item"><div class="recent-ic">📁</div><div><b>proyecto-baystream</b><div class="muted" style="font-size:11px">Carpeta de archivos</div></div></div>' +
      '<div class="recent-item" data-pick><div class="recent-ic">📄</div><div><b>test_baystream_demo.edi</b><div class="muted" style="font-size:11px">Archivo EDI · 1 KB</div></div></div>' +
      '<div style="display:flex;gap:8px;justify-content:flex-end;margin-top:14px">' +
        '<button class="btn btn-outline" data-close>Cancelar</button>' +
        '<button class="btn btn-primary" data-pick>Abrir</button>' +
      '</div>';
  }
  function render() {
    host.innerHTML = Proto.deviceShell({ tab: null, appbar: false, body: emptyBody() });
    var dbody = host.querySelector('.device-body');
    Proto.qa(dbody, '[data-pick-open]').forEach(function (b) {
      b.onclick = function () {
        var ov = Proto.showSheet(dbody, pickerHTML());
        Proto.qa(ov, '[data-pick]').forEach(function (el) {
          el.onclick = function () {
            Proto.closeSheet(dbody);
            Proto.toast(dbody, 'Procesando archivo…');
            setTimeout(function () { ScreenKit.listaScreen(host, { withToast: true }); }, 1000);
          };
        });
      };
    });
  }
  render();
};

/* RF-002 — Parsing y Validación del Formato BAPLIE 2.2.1 */
SCREENS['RF-002'] = function (host) {
  var raw =
"UNB+UNOA:2+MSC+TERMINAL+260512:1827+1'\n" +
"UNH+1+BAPLIE:D:13B:UN:SMDG22'\n" +
"BGM+45+V047E+9'\n" +
"TDT+20+V047E+++:::MSC GUATEMALA+++PA'\n" +
"LOC+147+0100482::5'\n" +
"EQD+CN+MSCU1234567+22G1+++5'\n" +
"MEA+WT++KGM:24500'\n" +
"NAD+CA+MSC:172:166'\n" +
"...\n" +
"LOC+147+0120184::5'\n" +
"EQD+CN+CMAU9988776+22G1+++5'\n" +
"DGS+IMD+3+1993'\n" +
"LOC+147+0100682::5'\n" +
"EQD+CN+MSKU7654321+45R1+++5'\n" +
"TMP+2+-18:CEL'\n" +
"UNT+42+1'";
  var steps = [
    { seg: 'UNH', txt: 'Cabecera del mensaje · BAPLIE versión D.13B (SMDG)' },
    { seg: 'TDT', txt: 'Buque MSC GUATEMALA · Viaje V047E · Operador MSC · Bandera PA' },
    { seg: 'LOC+147', txt: 'Posición de estiba 0100482 → Bay 010, Row 04, Tier 82' },
    { seg: 'EQD+CN', txt: 'Contenedor MSCU1234567 · Tipo 22G1 · Estado LLENO' },
    { seg: 'MEA+WT', txt: 'Peso bruto 24 500 kg (pendiente → aplicado al EQD)' },
    { seg: 'NAD+CA', txt: 'Naviera operadora MSC' },
    { seg: 'DGS', txt: 'Mercancía peligrosa IMDG clase 3 · ONU 1993 (CMAU9988776)' },
    { seg: 'TMP', txt: 'Contenedor refrigerado -18 °C (MSKU7654321)' },
    { seg: 'UNT', txt: 'Fin del mensaje · estructura válida' },
  ];
  function body() {
    return '<div class="section-label">Contenido EDIFACT de entrada (test_baystream_demo.edi)</div>' +
      '<div class="code-block">' + Proto.esc(raw) + '</div>' +
      '<button class="btn btn-primary" data-run style="margin:14px 0">▶ Procesar archivo</button>' +
      '<div class="section-label">Procesamiento secuencial de segmentos</div>' +
      '<div class="parse-log" id="plog"><div class="muted" style="opacity:1">Pulsa «Procesar archivo» para iniciar el parser EDIFACT…</div></div>';
  }
  host.innerHTML = Proto.deviceShell({ tab: null, appbar: false, body: body() });
  var dbody = host.querySelector('.device-body');
  dbody.querySelector('[data-run]').onclick = function () {
    var log = dbody.querySelector('#plog');
    log.innerHTML = '';
    steps.forEach(function (s, i) {
      setTimeout(function () {
        var d = document.createElement('div');
        d.className = 'parse-line';
        d.innerHTML = '<span class="parse-seg">[' + s.seg + ']</span> ' + Proto.esc(s.txt);
        log.appendChild(d); log.scrollTop = log.scrollHeight;
      }, i * 360);
    });
    setTimeout(function () {
      var d = document.createElement('div');
      d.className = 'parse-line parse-ok';
      d.innerHTML = '✓ VesselVoyage construido correctamente: ' + DEMO.containers.length + ' contenedores · ' + DEMO.bays.length + ' bahías · ' + DEMO.totalWeightTon() + ' t';
      log.appendChild(d); log.scrollTop = log.scrollHeight;
    }, steps.length * 360 + 200);
  };
};

/* RF-003 — Extracción de Información del Buque */
SCREENS['RF-003'] = function (host) {
  var rows = [
    ['e8051 = 20', 'Etapa de transporte: marítimo principal'],
    ['e8028 = V047E', 'Número de viaje'],
    ['c222.e8212 = 9839272', 'Número IMO del buque'],
    ['c222 (pos.8) = MSC GUATEMALA', 'Nombre del buque'],
    ['c040.e3127 = MSC', 'Código de naviera (operador)'],
    ['e8453 = PA', 'Bandera (Panamá)'],
  ];
  var body =
    '<div class="section-label">Segmento TDT (Transport Information)</div>' +
    '<div class="code-block">TDT+20+V047E+++:::MSC GUATEMALA+++PA\'</div>' +
    '<div class="grid-2" style="margin-top:14px;align-items:start">' +
      '<div><div class="section-label">Mapeo de elementos extraídos</div><table class="data-table">' +
        '<tr><th>Elemento EDIFACT</th><th>Significado</th></tr>' +
        rows.map(function (r) { return '<tr><td class="mono">' + Proto.esc(r[0]) + '</td><td>' + Proto.esc(r[1]) + '</td></tr>'; }).join('') +
      '</table><div class="hint">Respaldo: si el nombre no aparece en TDT se busca en segmentos RFF con calificador VM.</div></div>' +
      '<div><div class="section-label">Objeto Vessel resultante</div>' + Proto.voyageCardHTML() + '</div>' +
    '</div>';
  host.innerHTML = Proto.deviceShell({ tab: null, appbar: false, body: body });
};

/* RF-004 — Extracción de Datos de Contenedores */
SCREENS['RF-004'] = function (host) {
  var rowsHTML = DEMO.containers.map(function (c) {
    return '<tr>' +
      '<td class="mono">' + Proto.esc(c.containerId) + '</td>' +
      '<td class="mono">' + Proto.esc(c.isoSizeType) + '</td>' +
      '<td>' + (c.status === 'full' ? 'LLENO' : 'VACÍO') + '</td>' +
      '<td class="mono">' + Proto.esc(fmtPosition(c)) + '</td>' +
      '<td>' + (c.gross != null ? c.gross + ' kg' : 'N/A') + '</td>' +
      '<td>' + Proto.esc(c.operator) + '</td>' +
    '</tr>';
  }).join('');
  var body =
    '<div class="section-label">Contenedores extraídos de los grupos LOC + EQD + MEA + NAD</div>' +
    '<table class="data-table">' +
      '<tr><th>BIC (ISO 6346)</th><th>Tipo ISO</th><th>Estado</th><th>Posición (BBBRRTT)</th><th>Peso bruto</th><th>Naviera</th></tr>' +
      rowsHTML +
    '</table>' +
    '<div class="hint">Mecanismo de «pesos pendientes»: los valores MEA se acumulan y se aplican al contenedor del EQD correspondiente sin importar el orden de los segmentos.</div>';
  host.innerHTML = Proto.deviceShell({ tab: null, appbar: false, body: body });
};

/* RF-005 — Detección de Carga Especial (IMO, Reefer, OOG) */
SCREENS['RF-005'] = function (host) {
  var imo = DEMO.findContainer('CMAU9988776');
  var reefer = DEMO.findContainer('MSKU7654321');
  var oog = DEMO.findContainer('HLBU5544332');
  function card(cls, icon, title, cid, seg, lines, flag) {
    return '<div class="special-card ' + cls + '">' +
      '<div style="font-size:22px">' + icon + '</div>' +
      '<div style="font-weight:700;margin:6px 0">' + title + '</div>' +
      '<div class="mono" style="font-size:12px">' + Proto.esc(cid) + '</div>' +
      '<div class="code-block" style="margin:10px 0;font-size:11px;max-height:none">' + Proto.esc(seg) + '</div>' +
      lines.map(function (l) { return '<div style="font-size:12px;margin:3px 0">' + l + '</div>'; }).join('') +
      '<div style="margin-top:8px"><span class="flag ' + flag + '">' + title + '</span></div>' +
    '</div>';
  }
  var body =
    '<div class="section-label">Contenedores con carga especial detectada (indicadores booleanos)</div>' +
    '<div class="special-cards">' +
      card('imo', '⚠', 'IMDG', imo.containerId, "DGS+IMD+3+1993'",
        ['<b>isDangerous = true</b>', 'Clase IMO: 3', 'Número ONU: 1993'], 'flag-imo') +
      card('reefer', '❄', 'REEFER', reefer.containerId, "TMP+2+-18:CEL'",
        ['<b>isReefer = true</b>', 'Temperatura: -18 °C', 'Unidad: Celsius'], 'flag-reefer') +
      card('oog', '⤢', 'OOG', oog.containerId, "DIM+1+CMT:::35'",
        ['<b>isOverDimension = true</b>', 'Sobre-altura: 35 cm', 'Fuera de gálibo'], 'flag-oog') +
    '</div>' +
    '<div class="hint">La detección es crítica para la seguridad portuaria (Código IMDG, conexiones de reefers y planificación de espacios OOG). Un contenedor puede activar varios indicadores a la vez.</div>';
  host.innerHTML = Proto.deviceShell({ tab: null, appbar: false, body: body });
};

/* ==========================================================================
 * MÓDULO 2 — Visualización del Plano de Estiba (RF-006..014)
 * ========================================================================*/
SCREENS['RF-006'] = function (host) { ScreenKit.bayPlan(host, {}); };
SCREENS['RF-007'] = function (host) { ScreenKit.bayPlan(host, {}); };
SCREENS['RF-008'] = function (host) { ScreenKit.bayPlan(host, {}); };
SCREENS['RF-009'] = function (host) { ScreenKit.bayPlan(host, { initialBay: 10 }); };
SCREENS['RF-010'] = function (host) { ScreenKit.bayPlan(host, { initialBay: 10, hint: 'Toca una celda ocupada para ver el detalle del contenedor' }); };
SCREENS['RF-011'] = function (host) { ScreenKit.bayPlan(host, { initialBay: 10, interactiveLegend: true, hint: 'Toca un color de la leyenda para filtrar el grid' }); };
SCREENS['RF-012'] = function (host) { ScreenKit.bayPlan(host, { initialBay: 10, showWeights: true }); };
SCREENS['RF-013'] = function (host) { ScreenKit.bayPlan(host, { initialBay: 10, highlightId: 'MSKU7654321', hint: 'Contenedor MSKU7654321 resaltado tras la búsqueda' }); };
SCREENS['RF-014'] = function (host) { ScreenKit.bayPlan(host, {}); };
