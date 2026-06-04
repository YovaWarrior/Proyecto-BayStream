/* ============================================================================
 * BayStream — Prototipos Interactivos  ·  screens-3.js
 * Módulo 5 (RF-026..030), Módulo 6 (RF-031..033), Módulo 7 (RF-034..035)
 * ==========================================================================*/
window.SCREENS = window.SCREENS || {};

/* RF-026 — Distribución General del Buque (vista panorámica) */
SCREENS['RF-026'] = function (host) {
  // Perfil del buque: bahías reales + algunas vacías para dar contexto
  var profile = [
    { n: 2, occ: 0 }, { n: 6, occ: 0 }, { n: 10, occ: 6 }, { n: 12, occ: 2 },
    { n: 14, occ: 1 }, { n: 18, occ: 0 }, { n: 22, occ: 1 },
  ];
  function color(occ) { return occ === 0 ? 'var(--c-none)' : occ >= 5 ? 'var(--c-imo)' : occ >= 3 ? 'var(--c-empty)' : 'var(--c-full)'; }
  var bars = profile.map(function (b) {
    var h = 40 + b.occ * 16;
    return '<div class="ship-bay" data-bay="' + b.n + '" style="height:' + h + 'px;background:' + color(b.occ) + '22;border-color:' + color(b.occ) + '">' +
      '<div class="sb-num">BAY ' + Proto.pad(b.n, 2) + '</div><div class="sb-occ">' + b.occ + '%</div></div>';
  }).join('');
  var body =
    '<div class="section-label">⬅ POPA &nbsp;·&nbsp; Vista panorámica del buque MSC GUATEMALA &nbsp;·&nbsp; PROA ➡</div>' +
    '<div class="ship-overview">' + bars + '</div>' +
    '<div class="legend" style="border:none;background:transparent">' +
      '<div class="legend-item"><span class="legend-swatch" style="background:var(--c-none)"></span>Vacía</div>' +
      '<div class="legend-item"><span class="legend-swatch" style="background:var(--c-full)"></span>Baja</div>' +
      '<div class="legend-item"><span class="legend-swatch" style="background:var(--c-empty)"></span>Media</div>' +
      '<div class="legend-item"><span class="legend-swatch" style="background:var(--c-imo)"></span>Alta</div>' +
    '</div>' +
    '<div class="hint" style="text-align:center">Toca una bahía con carga para abrir su detalle en el Bay Plan.</div>';
  host.innerHTML = Proto.deviceShell({ tab: 'bayplan', appbar: true, body: body });
  var dbody = host.querySelector('.device-body');
  Proto.qa(dbody, '[data-bay]').forEach(function (el) {
    el.onclick = function () {
      var n = +el.getAttribute('data-bay');
      if (DEMO.containersByBay(n).length) ScreenKit.bayPlan(host, { initialBay: n });
      else Proto.toast(dbody, 'BAY ' + Proto.pad(n, 2) + ' está vacía', true);
    };
  });
};

/* RF-027 — Validación de Reglas de Estiba */
SCREENS['RF-027'] = function (host) {
  var alerts = [
    { lvl: 'ok', ic: '✓', t: 'Separación IMDG correcta', s: 'CMAU9988776 (clase 3 · ONU 1993) cumple la distancia de segregación según Código IMDG.' },
    { lvl: 'ok', ic: '✓', t: 'Reefer con conexión eléctrica', s: 'MSKU7654321 (-18 °C) ubicado en posición con acceso a alimentación eléctrica.' },
    { lvl: 'warn', ic: '⚠', t: 'Apilamiento 20′ sobre 40′', s: 'BAY 010, stack 04: contenedor de 20 pies apoyado sobre uno de 40 pies sin soporte estructural verificado.' },
    { lvl: 'warn', ic: '⚠', t: 'Peso por stack elevado', s: 'BAY 014, stack 06: 31.4 t supera el límite recomendado de apilamiento (revisar distribución).' },
    { lvl: 'err', ic: '✕', t: 'OOG sin holgura lateral', s: 'HLBU5544332 (sobre-ancho 20 cm) requiere verificar holgura con la celda contigua.' },
  ];
  var counts = { ok: 0, warn: 0, err: 0 };
  alerts.forEach(function (a) { counts[a.lvl]++; });
  var body =
    '<div class="section-label">Validación automática de reglas de estiba (' + alerts.length + ' verificaciones)</div>' +
    '<div class="chips" style="margin-bottom:14px">' +
      '<span class="chip chip-stat" style="color:var(--c-full);border-color:rgba(67,196,99,.4)">' + counts.ok + ' OK</span>' +
      '<span class="chip chip-stat" style="color:var(--c-empty);border-color:rgba(255,167,38,.4)">' + counts.warn + ' Advertencias</span>' +
      '<span class="chip chip-stat" style="color:var(--c-imo);border-color:rgba(239,77,84,.4)">' + counts.err + ' Errores</span>' +
    '</div>' +
    alerts.map(function (a) {
      return '<div class="alert-row ' + a.lvl + '"><div class="alert-ic">' + a.ic + '</div>' +
        '<div class="alert-body"><div class="a-title">' + a.t + '</div><div class="a-sub">' + a.s + '</div></div></div>';
    }).join('') +
    '<div class="hint">Funcionalidad avanzada (estado Propuesto). Requiere definición de los parámetros estructurales del buque.</div>';
  host.innerHTML = Proto.deviceShell({ tab: 'bayplan', appbar: true, body: body });
};

/* RF-028 — Planificación de Secuencia de Descarga */
SCREENS['RF-028'] = function (host) {
  var pod = 'HNPCR';
  var items = DEMO.containers.filter(function (c) { return c.pod === pod; })
    .sort(function (a, b) { return a.bay - b.bay || b.tier - a.tier; });
  var step = 0, lastBay = null, rows = '';
  items.forEach(function (c) {
    if (c.bay !== lastBay) { rows += '<div class="section-label" style="margin-top:12px">BAY ' + Proto.pad(c.bay, 2) + '</div>'; lastBay = c.bay; }
    step++;
    var zone = c.tier >= 80 ? 'Cubierta' : 'Bodega';
    rows += '<div class="alert-row"><div class="alert-ic" style="color:var(--primary);font-weight:800">' + step + '</div>' +
      '<div class="alert-body"><div class="a-title">' + Proto.esc(c.containerId) + ' · ' + zone + '</div>' +
      '<div class="a-sub">' + Proto.esc(fmtPosition(c)) + ' · ' + Proto.esc(c.operator) + ' · ' + (c.gross || 0) + ' kg</div></div></div>';
  });
  var body =
    '<div class="panel"><h4>Planificación de descarga — Puerto ' + pod + '</h4>' +
    '<div class="muted" style="font-size:13px">Secuencia sugerida que minimiza movimientos de grúa: prioriza <b>cubierta antes que bodega</b> y agrupa por bahía.</div>' +
    '<div class="chips" style="margin-top:10px"><span class="chip chip-stat" style="color:var(--primary);border-color:var(--primary-dim)">' + items.length + ' movimientos estimados</span></div>' +
    '</div>' + rows +
    '<div class="hint">Funcionalidad de valor agregado para operaciones de terminal (estado Propuesto).</div>';
  host.innerHTML = Proto.deviceShell({ tab: 'bayplan', appbar: true, body: body });
};

/* RF-029 — Comparación entre Viajes */
SCREENS['RF-029'] = function (host) {
  var arrival = DEMO.containers.map(function (c) { return c.containerId; });
  var departure = arrival.filter(function (id) { return ['CMAU9988776', 'ZIMU1112223'].indexOf(id) < 0; })
    .concat(['TGHU1234560', 'ONEU7788990']);
  var descargados = arrival.filter(function (id) { return departure.indexOf(id) < 0; });
  var cargados = departure.filter(function (id) { return arrival.indexOf(id) < 0; });
  var permanentes = arrival.filter(function (id) { return departure.indexOf(id) >= 0; });
  function col(title, color, ids) {
    return '<div class="panel"><h4 style="color:' + color + '">' + title + ' · ' + ids.length + '</h4>' +
      ids.map(function (id) { return '<div class="mono" style="font-size:12px;padding:4px 0;border-bottom:1px solid var(--border-soft)">' + id + '</div>'; }).join('') +
      '</div>';
  }
  var body =
    '<div class="section-label">Comparación BAPLIE de llegada vs. BAPLIE de salida — MSC GUATEMALA</div>' +
    '<div class="chips" style="margin-bottom:12px">' +
      '<span class="chip">📄 Llegada: ' + arrival.length + ' contenedores</span>' +
      '<span class="chip">📄 Salida: ' + departure.length + ' contenedores</span>' +
    '</div>' +
    '<div style="display:grid;grid-template-columns:repeat(3,1fr);gap:14px">' +
      col('⬇ Descargados', 'var(--c-imo)', descargados) +
      col('⬆ Cargados', 'var(--c-full)', cargados) +
      col('↔ Permanecen', 'var(--text-dim)', permanentes) +
    '</div>' +
    '<div class="hint">Permite auditar que las operaciones de carga/descarga se realizaron según el plan (estado Propuesto).</div>';
  host.innerHTML = Proto.deviceShell({ tab: 'lista', appbar: true, body: body });
};

/* RF-030 — Soporte de Modo Offline */
SCREENS['RF-030'] = function (host) {
  var state = { online: false };
  var features = ['Carga de archivo BAPLIE', 'Parsing EDIFACT', 'Visualización del Bay Plan', 'Búsqueda de contenedores', 'Filtrado por naviera', 'Dashboard estadístico'];
  function render() {
    var banner = state.online
      ? '<div class="sync-status" style="border-color:rgba(91,141,239,.4)"><span class="sync-dot" style="background:var(--primary)"></span><div style="flex:1"><b>Conexión disponible</b><div class="muted" style="font-size:12px">La sincronización opcional con la nube está activa.</div></div><div class="toggle on" data-toggle></div></div>'
      : '<div class="sync-status" style="border-color:rgba(255,167,38,.4)"><span class="sync-dot" style="background:var(--c-empty)"></span><div style="flex:1"><b>✈ Modo offline — sin conexión a internet</b><div class="muted" style="font-size:12px">Todas las funciones críticas operan localmente (Offline-First).</div></div><div class="toggle" data-toggle></div></div>';
    var checks = features.map(function (f) {
      return '<div class="perm-row"><span class="alert-ic" style="color:var(--c-full)">✓</span><div>' + f + '</div><span class="pr-allow allow-yes">Funciona offline</span></div>';
    }).join('');
    var body = banner + '<div class="panel"><h4>Funcionalidad sin conexión</h4>' + checks +
      '<div class="hint">Requisito operativo crítico del sector portuario, cumplido por la arquitectura Offline-First. La sincronización Firebase es opcional.</div></div>';
    host.innerHTML = Proto.deviceShell({ tab: 'lista', appbar: true, body: body });
    var dbody = host.querySelector('.device-body');
    dbody.querySelector('[data-toggle]').onclick = function () { state.online = !state.online; render(); };
  }
  render();
};

/* RF-031 — Almacenamiento Local Persistente */
SCREENS['RF-031'] = function (host) {
  var recents = [
    { name: 'MSC GUATEMALA', voy: 'V047E', date: '12/05/2026 18:27', n: 8 },
    { name: 'MAERSK SEVILLE', voy: 'A112W', date: '08/05/2026 09:14', n: 1240 },
    { name: 'CMA CGM LIBRA', voy: 'C088N', date: '03/05/2026 16:40', n: 3185 },
  ];
  var items = recents.map(function (r, i) {
    return '<div class="recent-item" data-recent="' + i + '"><div class="recent-ic">🚢</div>' +
      '<div style="flex:1"><b>' + r.name + '</b> · Viaje ' + r.voy + '<div class="muted" style="font-size:11px">Guardado ' + r.date + ' · ' + r.n + ' contenedores</div></div>' +
      '<span class="muted">↻ Abrir</span></div>';
  }).join('');
  var body =
    '<div class="section-label">Viajes recientes (almacenamiento local · JSON serializado)</div>' + items +
    '<button class="btn btn-primary" data-save style="margin-top:8px">💾 Guardar viaje actual</button>' +
    '<div class="hint">Las entidades implementan toJson/fromJson. Permite reabrir un viaje sin reprocesar el BAPLIE original (estado Propuesto).</div>';
  host.innerHTML = Proto.deviceShell({ tab: 'lista', appbar: true, body: body });
  var dbody = host.querySelector('.device-body');
  Proto.qa(dbody, '[data-recent]').forEach(function (el) {
    el.onclick = function () { Proto.toast(dbody, 'Viaje restaurado desde almacenamiento local'); };
  });
  dbody.querySelector('[data-save]').onclick = function () { Proto.toast(dbody, 'Viaje actual guardado localmente'); };
};

/* RF-032 — Sincronización en la Nube */
SCREENS['RF-032'] = function (host) {
  var state = { on: true };
  function render() {
    var status = state.on
      ? '<div class="sync-status"><span class="sync-dot" style="background:var(--c-full)"></span><div style="flex:1"><b>Sincronizado con Firebase Firestore</b><div class="muted" style="font-size:12px">Última sincronización: hace 2 min · sin conflictos</div></div><div class="toggle on" data-toggle></div></div>'
      : '<div class="sync-status"><span class="sync-dot" style="background:var(--c-empty)"></span><div style="flex:1"><b>Sincronización en la nube desactivada</b><div class="muted" style="font-size:12px">Operando solo en modo local (Offline-First).</div></div><div class="toggle" data-toggle></div></div>';
    var devices = state.on
      ? '<div class="panel"><h4>Dispositivos sincronizados</h4>' +
        '<div class="perm-row"><span class="alert-ic">🖥️</span><div style="flex:1">Módulo Desktop (Ship Planner)</div><span class="allow-yes">✓ Al día</span></div>' +
        '<div class="perm-row"><span class="alert-ic">📱</span><div style="flex:1">Módulo Tablet (Supervisor de Muelle)</div><span class="allow-yes">✓ Al día</span></div>' +
        '<div class="hint">Resolución de conflictos por timestamp («última escritura gana»). La cola offline reintenta al recuperar la red.</div></div>'
      : '';
    host.innerHTML = Proto.deviceShell({ tab: 'lista', appbar: true, body: status + devices +
      '<div class="hint">Firebase está incluido en pubspec.yaml pero comentado temporalmente por incompatibilidad con la build de Windows/CMake (estado Propuesto).</div>' });
    var dbody = host.querySelector('.device-body');
    dbody.querySelector('[data-toggle]').onclick = function () { state.on = !state.on; render(); };
  }
  render();
};

/* RF-033 — Exportación de Datos en Formatos Estándar */
SCREENS['RF-033'] = function (host) {
  function csv() {
    var head = 'containerId,isoType,status,bay,row,tier,grossWeight,operator,pol,pod,imdg,un,reefer,oog';
    var lines = DEMO.containers.map(function (c) {
      return [c.containerId, c.isoSizeType, c.status, c.bay, c.row, c.tier, c.gross || '', c.operator,
        c.pol || '', c.pod || '', c.imdgClass || '', c.unNumber || '', c.isReefer, c.isOOG].join(',');
    });
    return head + '\n' + lines.join('\n');
  }
  function json() {
    var sample = { vessel: DEMO.vessel, voyage: DEMO.voyage, totalContainers: DEMO.containers.length, containers: [DEMO.containers[0]] };
    return JSON.stringify(sample, null, 2);
  }
  function sheet(title, content) {
    return '<div class="sheet-handle"></div><div class="sheet-title"><span class="sheet-id" style="font-size:16px">' + title + '</span></div>' +
      '<div class="code-block" style="margin-top:12px;color:#b9c2e8">' + Proto.esc(content) + '</div>' +
      '<div style="display:flex;gap:8px;justify-content:flex-end;margin-top:14px">' +
      '<button class="btn btn-outline" data-close>Cerrar</button><button class="btn btn-primary" data-dl>💾 Descargar</button></div>';
  }
  var body = Proto.voyageCardHTML() +
    '<div class="panel" style="margin-top:16px"><h4>Exportar datos del viaje</h4>' +
    '<div class="muted" style="font-size:13px">Exporta el viaje en formatos estándar para integrarlo con otros sistemas o un TOS (Terminal Operating System).</div>' +
    '<div style="display:flex;gap:10px;margin-top:14px"><button class="btn btn-primary" data-csv>📄 Exportar CSV</button>' +
    '<button class="btn btn-soft" data-json>{ } Exportar JSON</button></div></div>';
  host.innerHTML = Proto.deviceShell({ tab: 'stats', appbar: true, body: body });
  var dbody = host.querySelector('.device-body');
  function openSheet(html) {
    var ov = Proto.showSheet(dbody, html);
    Proto.qa(ov, '[data-dl]').forEach(function (b) { b.onclick = function () { Proto.closeSheet(dbody); Proto.toast(dbody, 'Archivo exportado correctamente'); }; });
  }
  dbody.querySelector('[data-csv]').onclick = function () { openSheet(sheet('📄 viaje_V047E.csv', csv())); };
  dbody.querySelector('[data-json]').onclick = function () { openSheet(sheet('{ } viaje_V047E.json', json())); };
};

/* RF-034 — Autenticación de Usuarios */
SCREENS['RF-034'] = function (host) {
  var body =
    '<div class="login-card">' +
      '<div class="center-col"><div class="empty-boat" style="width:64px;height:64px;font-size:30px">⛴</div>' +
      '<div style="font-weight:800;font-size:18px">Iniciar sesión</div>' +
      '<div class="muted" style="font-size:12px;margin-bottom:16px">Accede a sincronización, historial y configuración</div></div>' +
      '<div class="field"><label>Correo electrónico</label><input type="email" value="planner@empornac.gob.gt"></div>' +
      '<div class="field"><label>Contraseña</label><input type="password" value="••••••••"></div>' +
      '<button class="btn btn-primary btn-block" data-login>Iniciar sesión</button>' +
      '<div class="divider-or">— o —</div>' +
      '<button class="btn btn-outline btn-block" data-login>🔵 Continuar con Google</button>' +
      '<div class="hint" style="text-align:center">Las funciones básicas (carga, parsing, visualización) funcionan sin iniciar sesión.</div>' +
    '</div>';
  host.innerHTML = Proto.deviceShell({ tab: null, appbar: false, body: body });
  var dbody = host.querySelector('.device-body');
  Proto.qa(dbody, '[data-login]').forEach(function (b) {
    b.onclick = function () { Proto.toast(dbody, 'Sesión iniciada como Planificador'); };
  });
};

/* RF-035 — Control de Acceso Basado en Roles (RBAC) */
SCREENS['RF-035'] = function (host) {
  var roles = [
    { id: 'op', ic: '👷', name: 'Operador' },
    { id: 'pl', ic: '🧭', name: 'Planificador' },
    { id: 'ad', ic: '🛡️', name: 'Administrador' },
  ];
  var features = ['Cargar y visualizar', 'Búsqueda de contenedores', 'Estadísticas', 'Exportar reportes', 'Comparar viajes', 'Sincronización en la nube', 'Gestión de usuarios'];
  var perms = {
    op: [1, 1, 0, 0, 0, 0, 0],
    pl: [1, 1, 1, 1, 1, 1, 0],
    ad: [1, 1, 1, 1, 1, 1, 1],
  };
  var state = { role: 'pl' };
  function render() {
    var tabs = roles.map(function (r) {
      return '<div class="role-tab' + (r.id === state.role ? ' active' : '') + '" data-role="' + r.id + '">' +
        '<div class="rt-ic">' + r.ic + '</div><div class="rt-name">' + r.name + '</div></div>';
    }).join('');
    var matrix = features.map(function (f, i) {
      var ok = perms[state.role][i];
      return '<div class="perm-row"><span class="alert-ic" style="color:' + (ok ? 'var(--c-full)' : 'var(--text-faint)') + '">' + (ok ? '✓' : '✕') + '</span>' +
        '<div style="flex:1">' + f + '</div><span class="pr-allow ' + (ok ? 'allow-yes' : 'allow-no') + '">' + (ok ? 'Permitido' : 'Bloqueado') + '</span></div>';
    }).join('');
    var body = '<div class="section-label">Selecciona un rol para ver sus permisos</div>' +
      '<div class="role-tabs">' + tabs + '</div>' +
      '<div class="panel"><h4>Permisos del rol</h4>' + matrix + '</div>' +
      '<div class="hint">La interfaz se adapta mostrando solo las funciones autorizadas por rol (estado Propuesto). Requiere Firebase y políticas de seguridad.</div>';
    host.innerHTML = Proto.deviceShell({ tab: null, appbar: false, body: body });
    var dbody = host.querySelector('.device-body');
    Proto.qa(dbody, '[data-role]').forEach(function (el) {
      el.onclick = function () { state.role = el.getAttribute('data-role'); render(); };
    });
  }
  render();
};
