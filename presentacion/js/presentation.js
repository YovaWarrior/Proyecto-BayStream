/* ============================================================================
 * BayStream — Presentación · presentation.js
 * Navegación con teclado, barra de progreso, animaciones de entrada.
 * ========================================================================== */
(function () {
  'use strict';

  var slides, current = 0, total = 0;
  var progressFill, counter;
  var transitioning = false;

  /* ── Inicialización ── */
  function init() {
    slides = Array.from(document.querySelectorAll('.slide'));
    total = slides.length;
    progressFill = document.querySelector('.progress-fill');
    counter = document.querySelector('.slide-counter');

    if (!total) return;

    /* Mostrar primera slide */
    goTo(0, false);

    /* Teclado */
    document.addEventListener('keydown', onKey);

    /* Click en la presentación para avanzar (excepto links) */
    document.addEventListener('click', function (e) {
      if (e.target.closest('a, button, .nav-hint, .slide-counter')) return;
      var x = e.clientX;
      if (x > window.innerWidth * 0.65) next();
      else if (x < window.innerWidth * 0.35) prev();
    });

    /* Touch swipe */
    var touchStartX = 0;
    document.addEventListener('touchstart', function (e) {
      touchStartX = e.changedTouches[0].clientX;
    }, { passive: true });
    document.addEventListener('touchend', function (e) {
      var dx = e.changedTouches[0].clientX - touchStartX;
      if (Math.abs(dx) > 50) {
        if (dx < 0) next(); else prev();
      }
    }, { passive: true });

    /* Hash */
    if (location.hash) {
      var n = parseInt(location.hash.replace('#', ''), 10);
      if (!isNaN(n) && n >= 1 && n <= total) goTo(n - 1, false);
    }
  }

  /* ── Navegación ── */
  function goTo(index, animate) {
    if (index < 0 || index >= total) return;
    if (transitioning && animate !== false) return;

    transitioning = true;

    slides.forEach(function (s, i) {
      s.classList.toggle('active', i === index);
    });

    current = index;
    updateUI();

    history.replaceState(null, '', '#' + (current + 1));

    setTimeout(function () { transitioning = false; }, animate === false ? 0 : 550);
  }

  function next() { goTo(current + 1, true); }
  function prev() { goTo(current - 1, true); }

  function onKey(e) {
    if (e.key === 'ArrowRight' || e.key === 'ArrowDown' || e.key === ' ' || e.key === 'PageDown') {
      e.preventDefault(); next();
    } else if (e.key === 'ArrowLeft' || e.key === 'ArrowUp' || e.key === 'PageUp') {
      e.preventDefault(); prev();
    } else if (e.key === 'Home') {
      e.preventDefault(); goTo(0, true);
    } else if (e.key === 'End') {
      e.preventDefault(); goTo(total - 1, true);
    }
  }

  /* ── UI Updates ── */
  function updateUI() {
    /* Progress bar */
    var pct = total > 1 ? ((current) / (total - 1)) * 100 : 100;
    if (progressFill) progressFill.style.width = pct + '%';

    /* Counter */
    var pad = function (n) { return n < 10 ? '0' + n : '' + n; };
    if (counter) counter.textContent = pad(current + 1) + ' / ' + pad(total);
  }

  /* ── Start ── */
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
