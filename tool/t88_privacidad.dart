import 'dart:io';

import 'package:baystream/core/utils/privacy_policy_html.dart';

/// T-88 · Escribe `web/privacidad.html` desde la fuente única de la política.
///
/// Uso, desde la raíz del repositorio: `dart run tool/t88_privacidad.dart`.
/// Con `--comprobar` no escribe: termina con 1 si el archivo no coincide.
void main(List<String> arguments) {
  final file = File('web/privacidad.html');
  final html = privacyPolicyHtml();
  if (arguments.contains('--comprobar')) {
    final current = file.existsSync()
        ? file.readAsStringSync().replaceAll('\r\n', '\n')
        : null;
    if (current != html) {
      stderr.writeln('web/privacidad.html no coincide con la fuente. '
          'Regenéralo con: dart run tool/t88_privacidad.dart');
      exitCode = 1;
      return;
    }
    stdout.writeln('web/privacidad.html coincide con la fuente.');
    return;
  }
  file.writeAsStringSync(html);
  stdout.writeln('Escrito ${file.path} (${html.length} caracteres).');
}
