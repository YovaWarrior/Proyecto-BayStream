import 'dart:io';

// Servidor de aceptación local. No registra consultas ni datos de cuenta.
Future<void> main(List<String> arguments) async {
  final inventory = arguments.contains('--inventory');
  final blockExternal = arguments.contains('--block-external');
  final positional = arguments
      .where((value) => value != '--inventory' && value != '--block-external')
      .toList();
  if (positional.isEmpty || positional.length > 2) {
    stderr.writeln(
      'Uso: dart run tool/t92_server.dart <sitio> [puerto] '
      '[--inventory] [--block-external]',
    );
    exitCode = 64;
    return;
  }
  final root = Directory(positional.first).absolute;
  if (!File('${root.path}/index.html').existsSync()) {
    stderr.writeln('La carpeta no contiene index.html.');
    exitCode = 64;
    return;
  }
  final server = await HttpServer.bind(
    InternetAddress.loopbackIPv4,
    positional.length == 2 ? int.parse(positional[1]) : 8192,
  );
  stdout.writeln('T-92: http://localhost:${server.port}/ · ${root.path}');
  await for (final request in server) {
    try {
      if (request.method != 'GET' && request.method != 'HEAD') {
        request.response.statusCode = HttpStatus.methodNotAllowed;
        await request.response.close();
        continue;
      }
      final segments = request.uri.pathSegments;
      if (segments.any((part) =>
          part == '..' ||
          part.contains('\\') ||
          part.contains('/') ||
          part.contains(':'))) {
        request.response.statusCode = HttpStatus.forbidden;
        await request.response.close();
        continue;
      }
      final path = segments.where((part) => part.isNotEmpty).join('/');
      final file = File('${root.path}/${path.isEmpty ? 'index.html' : path}');
      if (!file.existsSync()) {
        // Un recurso ausente devuelve 404; nunca HTML con MIME de módulo.
        request.response.statusCode = HttpStatus.notFound;
        await request.response.close();
        continue;
      }
      final extension = file.path.split('.').last.toLowerCase();
      const types = {
        'html': 'text/html; charset=utf-8',
        'js': 'application/javascript; charset=utf-8',
        'json': 'application/json; charset=utf-8',
        'wasm': 'application/wasm',
        'woff2': 'font/woff2',
        'ttf': 'font/ttf',
        'otf': 'font/otf',
        'png': 'image/png',
        'svg': 'image/svg+xml',
        'txt': 'text/plain; charset=utf-8',
        'md': 'text/plain; charset=utf-8',
      };
      request.response.headers.set(
        HttpHeaders.contentTypeHeader,
        types[extension] ?? 'application/octet-stream',
      );
      request.response.headers.set(
        HttpHeaders.cacheControlHeader,
        'no-cache, max-age=0, must-revalidate',
      );
      if (blockExternal) {
        // Solo en aceptación: bloquear terceros en esta página, sin tocar
        // la red del equipo ni el SW. La respuesta almacenada conserva CSP.
        request.response.headers.set(
          'Content-Security-Policy',
          "default-src 'self'; connect-src 'self'; "
              "script-src 'self' 'unsafe-inline' 'unsafe-eval' blob:; "
              "style-src 'self' 'unsafe-inline'; "
              "img-src 'self' blob: data:; font-src 'self' blob: data:; "
              "worker-src 'self' blob:; frame-src 'none'; object-src 'none'",
        );
      }
      if (inventory && extension == 'html') {
        final content = (await file.readAsString()).replaceFirst(
          '<head>',
          '<head>$_inventoryProbe',
        );
        if (request.method == 'GET') request.response.write(content);
      } else {
        request.response.contentLength = await file.length();
        if (request.method == 'GET') {
          await request.response.addStream(file.openRead());
        }
      }
      await request.response.close();
    } catch (_) {
      request.response.statusCode = HttpStatus.internalServerError;
      await request.response.close();
    }
  }
}

// Solo en aceptación instrumentada: rutas de código/fuentes; servicios de
// datos reducidos al dominio. Nunca consultas, fragmentos, cuerpos ni cuentas.
const _inventoryProbe = r'''
<script>
(() => {
  const rows = [];
  function updateOutput() {
    let output = document.getElementById('t92-inventory');
    if (!output && document.body) {
      output = document.createElement('pre');
      output.id = 't92-inventory';
      output.hidden = true;
      document.body.appendChild(output);
    }
    if (output) {
      output.textContent = JSON.stringify(rows);
      output.dataset.worker = navigator.serviceWorker?.controller?.scriptURL ?? 'none';
    }
  }
  const observer = new PerformanceObserver(list => {
    for (const entry of list.getEntries()) {
      const url = new URL(entry.name, location.href);
      if (!['http:', 'https:'].includes(url.protocol)) continue;
      const asset = ['www.gstatic.com', 'fonts.gstatic.com'].includes(url.hostname)
        && /\.(js|wasm|woff2?|ttf|otf|png|json)$/.test(url.pathname);
      const own = url.origin === location.origin;
      rows.push({
        resource: url.origin + (own || asset ? url.pathname : '/[servicio]'),
        kind: entry.initiatorType,
        transferBytes: entry.transferSize,
        encodedBytes: entry.encodedBodySize,
        decodedBytes: entry.decodedBodySize
      });
    }
    updateOutput();
  });
  observer.observe({type: 'resource', buffered: true});
  navigator.serviceWorker?.addEventListener('controllerchange', updateOutput);
})();
</script>
''';
