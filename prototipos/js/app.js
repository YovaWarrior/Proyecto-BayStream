/* ============================================================================
 * BayStream — Prototipos Interactivos  ·  app.js
 * Portada + sidebar de navegación + router por los 35 RF + trazabilidad.
 * ==========================================================================*/
(function () {
  var host, headerEl, sidebar, crumb, current = 'home';

  function statusDot(s) { return s === 'Implementado' ? 'impl' : 'prop'; }
  function implCount() { return RF_FLAT.filter(function (r) { return r.status === 'Implementado'; }).length; }

  /* ---------- Portada ---------- */
  function homeHTML() {
    var impl = implCount(), prop = RF_FLAT.length - impl;
    function meta(label, value, sub) {
      return '<div><span>' + label + '</span><b>' + value + '</b>' +
        (sub ? '<small>' + sub + '</small>' : '') + '</div>';
    }
    function stat(num, lbl) { return '<div class="cover-stat"><b>' + num + '</b><span>' + lbl + '</span></div>'; }
    return '<div class="cover">' +
      '<div class="cover-logo">⛴</div>' +
      '<h1 class="cover-title">BayStream</h1>' +
      '<div class="cover-sub">Ecosistema Multiplataforma para la optimización en Tiempo Real ' +
      'de la planificación de Estiba de Buques Portacontenedores</div>' +
      '<div class="cover-tag">Prototipos Interactivos · Revisión de Primeros Prototipos</div>' +
      '<div class="cover-meta-grid">' +
        meta('Estudiante', 'Carlos Giovanni Martínez Aldana', 'Carné 0909-22-19157') +
        meta('Casa de estudios', 'Universidad Mariano Gálvez de Guatemala', 'Centro Universitario de Puerto Barrios · Facultad de Ingeniería en Sistemas') +
        meta('Curso', 'Proyecto de Graduación I', 'Asesor: Ing. Juan Pablo Escobar') +
        meta('Caso de prueba', 'MSC GUATEMALA · Viaje V047E', 'Ruta GTSTC → HNPCR · BAPLIE D.13B') +
      '</div>' +
      '<div class="cover-stats">' +
        stat(RF_FLAT.length, 'Requerimientos') + stat(RF_MODULES.length, 'Módulos') +
        stat(impl, 'Implementados') + stat(prop, 'Propuestos') +
      '</div>' +
      '<button class="btn btn-primary" id="cover-start" style="font-size:15px;padding:12px 26px">▶ Explorar los 35 prototipos</button>' +
      '<div class="muted" style="font-size:12px;margin-top:14px">O usa el menú lateral para ir directo a cualquier requerimiento (RF-001 … RF-035).</div>' +
    '</div>';
  }

  /* ---------- Sidebar ---------- */
  function buildSidebar() {
    var html =
      '<div class="sidebar-header">' +
        '<div class="brand" id="brand-home" style="cursor:pointer"><div class="brand-logo">⛴</div>' +
        '<div><div class="brand-name">BayStream</div>' +
        '<div class="brand-sub">Prototipos interactivos · 35 RF</div></div></div>' +
        '<div class="sidebar-meta">Proyecto de Graduación · UMG<br>' +
        'Buque <b>MSC GUATEMALA</b> · Viaje V047E<br>Ruta GTSTC → HNPCR' +
        '<br><span class="progress-pill">' + RF_FLAT.length + ' requerimientos · ' + implCount() + ' implementados</span></div>' +
      '</div>' +
      '<div class="module-group"><div class="rf-item home-item" data-home>' +
        '<span class="rf-dot" style="background:var(--primary)"></span>' +
        '<div class="rf-item-body"><div class="rf-id">PORTADA</div>' +
        '<div class="rf-name">Inicio · Datos del proyecto</div></div></div></div>';
    RF_MODULES.forEach(function (m) {
      html += '<div class="module-group"><div class="module-title">' +
        '<span class="mt-icon">' + m.icon + '</span> Módulo ' + m.num + ' · ' + Proto.esc(m.name) + '</div>';
      m.rfs.forEach(function (rf) {
        html += '<div class="rf-item" data-rf="' + rf.id + '">' +
          '<span class="rf-dot ' + statusDot(rf.status) + '"></span>' +
          '<div class="rf-item-body"><div class="rf-id">' + rf.id + '</div>' +
          '<div class="rf-name">' + Proto.esc(rf.name) + '</div></div></div>';
      });
      html += '</div>';
    });
    sidebar.innerHTML = html;
    Proto.qa(sidebar, '[data-rf]').forEach(function (el) {
      el.onclick = function () { navigate(el.getAttribute('data-rf')); };
    });
    Proto.qa(sidebar, '[data-home]').forEach(function (el) { el.onclick = function () { navigate('home'); }; });
    var bh = sidebar.querySelector('#brand-home'); if (bh) bh.onclick = function () { navigate('home'); };
  }

  function setActive(id) {
    Proto.qa(sidebar, '.rf-item').forEach(function (el) { el.classList.remove('active'); });
    var sel = id === 'home' ? '[data-home]' : '[data-rf="' + id + '"]';
    var el = sidebar.querySelector(sel);
    if (el) { el.classList.add('active'); el.scrollIntoView({ block: 'nearest' }); }
  }

  function renderHeader(rf) {
    headerEl.innerHTML =
      '<div class="rf-header"><div class="rf-header-top">' +
        '<span class="rf-header-id">' + rf.id + '</span>' +
        '<span class="badge badge-' + rf.priority + '">' + rf.priority + '</span>' +
        '<span class="badge ' + (rf.status === 'Implementado' ? 'badge-impl' : 'badge-prop') + '">' + rf.status + '</span>' +
        '<span class="badge badge-cu">' + Proto.esc(rf.cu) + '</span>' +
        '<span class="badge badge-cu">Módulo ' + rf.moduleNum + '</span>' +
        '<h2 class="rf-header-name">' + Proto.esc(rf.name) + '</h2>' +
      '</div>' +
      '<p class="rf-desc">' + Proto.esc(rf.desc) + '</p>' +
      '<ul class="rf-key">' + rf.key.map(function (k) { return '<li>' + Proto.esc(k) + '</li>'; }).join('') + '</ul>' +
      '</div>';
  }

  function navigate(id) {
    if (id === 'home') {
      current = 'home';
      if (location.hash !== '#inicio') history.replaceState(null, '', '#inicio');
      setActive('home');
      crumb.textContent = 'Portada · Datos del proyecto';
      headerEl.innerHTML = '';
      host.innerHTML = homeHTML();
      var b = document.getElementById('cover-start');
      if (b) b.onclick = function () { navigate('RF-001'); };
      window.scrollTo(0, 0);
      updateNavButtons();
      return;
    }
    var rf = findRF(id);
    if (!rf) { id = 'RF-001'; rf = findRF(id); }
    current = id;
    if (location.hash !== '#' + id) history.replaceState(null, '', '#' + id);
    setActive(id);
    crumb.textContent = 'Módulo ' + rf.moduleNum + ' · ' + rf.moduleName;
    renderHeader(rf);
    host.innerHTML = '';
    try {
      (SCREENS[id] || function (h) { h.innerHTML = '<div class="muted">Pantalla no disponible.</div>'; })(host);
    } catch (e) {
      host.innerHTML = '<div class="muted">Error al renderizar ' + id + ': ' + Proto.esc(e.message) + '</div>';
      if (window.console) console.error(e);
    }
    window.scrollTo(0, 0);
    updateNavButtons();
  }

  function idx(id) { return RF_FLAT.findIndex(function (r) { return r.id === id; }); }
  function step(d) {
    if (current === 'home') { if (d > 0) navigate('RF-001'); return; }
    var i = idx(current);
    if (d < 0 && i === 0) { navigate('home'); return; }
    i = Math.min(RF_FLAT.length - 1, Math.max(0, i + d));
    navigate(RF_FLAT[i].id);
  }
  function updateNavButtons() {
    var prev = document.getElementById('prev'), next = document.getElementById('next');
    if (current === 'home') { prev.disabled = true; next.disabled = false; return; }
    prev.disabled = false;
    next.disabled = idx(current) >= RF_FLAT.length - 1;
  }

  function init() {
    host = document.getElementById('screen-host');
    headerEl = document.getElementById('rf-header');
    sidebar = document.getElementById('sidebar');
    crumb = document.getElementById('crumb');
    buildSidebar();
    document.getElementById('prev').onclick = function () { step(-1); };
    document.getElementById('next').onclick = function () { step(1); };
    window.addEventListener('hashchange', function () {
      var id = location.hash.replace('#', '');
      if (id === 'inicio' || id === 'home') { if (current !== 'home') navigate('home'); return; }
      if (findRF(id) && id !== current) navigate(id);
    });
    var start = location.hash.replace('#', '');
    if (start === 'inicio' || start === 'home' || !start) navigate('home');
    else navigate(findRF(start) ? start : 'home');
  }

  document.addEventListener('DOMContentLoaded', init);
})();
