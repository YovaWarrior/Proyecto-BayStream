/* ============================================================================
 * BayStream — Prototipos Interactivos  ·  app.js
 * Sidebar de navegación + router por los 35 RF + cabecera de trazabilidad.
 * ==========================================================================*/
(function () {
  var host, headerEl, sidebar, crumb, current = 'RF-001';

  function statusDot(s) { return s === 'Implementado' ? 'impl' : 'prop'; }

  function buildSidebar() {
    var impl = RF_FLAT.filter(function (r) { return r.status === 'Implementado'; }).length;
    var html =
      '<div class="sidebar-header">' +
        '<div class="brand"><div class="brand-logo">⛴</div>' +
        '<div><div class="brand-name">BayStream</div>' +
        '<div class="brand-sub">Prototipos interactivos · 35 RF</div></div></div>' +
        '<div class="sidebar-meta">Proyecto de Graduación · UMG<br>' +
        'Buque <b>MSC GUATEMALA</b> · Viaje V047E<br>Ruta GTSTC → HNPCR' +
        '<br><span class="progress-pill">' + RF_FLAT.length + ' requerimientos · ' + impl + ' implementados</span></div>' +
      '</div>';
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
    var rf = findRF(id);
    if (!rf) { id = 'RF-001'; rf = findRF(id); }
    current = id;
    if (location.hash !== '#' + id) history.replaceState(null, '', '#' + id);

    Proto.qa(sidebar, '[data-rf]').forEach(function (el) {
      el.classList.toggle('active', el.getAttribute('data-rf') === id);
    });
    var active = sidebar.querySelector('[data-rf="' + id + '"]');
    if (active) active.scrollIntoView({ block: 'nearest' });

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
    var i = Math.min(RF_FLAT.length - 1, Math.max(0, idx(current) + d));
    navigate(RF_FLAT[i].id);
  }
  function updateNavButtons() {
    var i = idx(current);
    document.getElementById('prev').disabled = i <= 0;
    document.getElementById('next').disabled = i >= RF_FLAT.length - 1;
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
      if (findRF(id) && id !== current) navigate(id);
    });
    var start = location.hash.replace('#', '');
    navigate(findRF(start) ? start : 'RF-001');
  }

  document.addEventListener('DOMContentLoaded', init);
})();
