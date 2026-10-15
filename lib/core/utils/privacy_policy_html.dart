import '../constants/privacy_policy.dart';

/// T-88 · `web/privacidad.html`, armado desde la misma fuente que la pantalla.
///
/// La usan `tool/t88_privacidad.dart`, que escribe el archivo, y la prueba que
/// exige que el archivo publicado sea igual a lo que genera la fuente.
/// Autocontenido: sin JavaScript, sin fuentes ni hojas de estilo de otros
/// sitios, en claro y oscuro con `prefers-color-scheme`. Finales de línea LF.
String privacyPolicyHtml() {
  final out = StringBuffer()
    ..writeln('<!DOCTYPE html>')
    ..writeln('<!-- Generado por tool/t88_privacidad.dart desde '
        'lib/core/constants/privacy_policy.dart. No se edita a mano. -->')
    ..writeln('<html lang="es">')
    ..writeln('<head>')
    ..writeln('<meta charset="utf-8">')
    ..writeln('<meta name="viewport" content="width=device-width, initial-scale=1">')
    ..writeln('<meta name="color-scheme" content="light dark">')
    ..writeln('<title>${_escape(kPrivacyPolicyTitle)}</title>')
    ..writeln('<style>')
    ..writeln(_css)
    ..writeln('</style>')
    ..writeln('</head>')
    ..writeln('<body>')
    ..writeln('<main>')
    ..writeln('<h1>${_escape(kPrivacyPolicyTitle)}</h1>')
    ..writeln('<p class="fecha">${_escape(kPrivacyPolicyUpdated)}</p>');
  for (final section in kPrivacyPolicySections) {
    out
      ..writeln('<section>')
      ..writeln('<h2>${_escape(section.title)}</h2>');
    for (final paragraph in section.paragraphs) {
      out.writeln('<p>${_inline(paragraph)}</p>');
    }
    if (section.items.isNotEmpty) {
      out.writeln('<ul>');
      for (final item in section.items) {
        out.writeln('<li>${_inline(item)}</li>');
      }
      out.writeln('</ul>');
    }
    out.writeln('</section>');
  }
  out
    ..writeln('</main>')
    ..writeln('</body>')
    ..writeln('</html>');
  return out.toString();
}

String _inline(String text) => privacyRuns(text).map((run) {
      final escaped = _escape(run.text);
      if (run.bold) return '<strong>$escaped</strong>';
      if (run.code) return '<code>$escaped</code>';
      return escaped.replaceAll(_escape(kPrivacyContactEmail),
          '<a href="mailto:$kPrivacyContactEmail">$kPrivacyContactEmail</a>');
    }).join();

String _escape(String text) => text
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;');

// Monocromático y con letra del sistema: nada se descarga de otro sitio.
const _css = '''
:root { --fondo: #ffffff; --texto: #1b1b1f; --suave: #44474f; --marca: #0d47a1; --codigo: #e8eaf0; }
@media (prefers-color-scheme: dark) {
  :root { --fondo: #121318; --texto: #e3e2e6; --suave: #c4c6d0; --marca: #a9c7ff; --codigo: #2a2c33; }
}
* { box-sizing: border-box; }
body { margin: 0; background: var(--fondo); color: var(--texto); font: 1rem/1.55 system-ui, -apple-system, "Segoe UI", Roboto, sans-serif; }
main { max-width: 44rem; margin: 0 auto; padding: 24px 16px 48px; overflow-wrap: anywhere; }
h1 { font-size: 1.6rem; line-height: 1.25; margin: 0 0 4px; }
h2 { font-size: 1.1rem; margin: 28px 0 8px; }
.fecha { color: var(--suave); margin: 0 0 8px; }
p, li { margin: 0 0 10px; }
ul { padding-left: 1.25rem; }
a { color: var(--marca); }
code { background: var(--codigo); padding: 0 4px; border-radius: 4px; font-family: ui-monospace, Consolas, monospace; }''';
