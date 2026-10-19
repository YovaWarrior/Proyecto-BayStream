// T-99 · Servidor local para el banco Web: sirve build/web de la copia de
// compilación y recibe sus registros y capturas, que guarda en %TEMP%.
// Solo escucha en 127.0.0.1. Se detiene con Ctrl+C o cerrando el proceso.
//
//   dart tool/t99_servidor.dart <build/web de la copia> <salida en %TEMP%> [puerto]
import 'dart:io';

import 't99_comun.dart';

const _tipos = {
  'html': 'text/html; charset=utf-8',
  'js': 'text/javascript; charset=utf-8',
  'mjs': 'text/javascript; charset=utf-8',
  'json': 'application/json',
  'wasm': 'application/wasm',
  'css': 'text/css',
  'png': 'image/png',
  'ico': 'image/x-icon',
  'ttf': 'font/ttf',
  'otf': 'font/otf',
  'woff2': 'font/woff2',
  'svg': 'image/svg+xml',
  'symbols': 'application/octet-stream',
  'bin': 'application/octet-stream',
  'frag': 'application/octet-stream',
};

/// Solo nombres simples: sin rutas, sin `..`.
bool nombreSeguro(String nombre) => RegExp(r'^[A-Za-z0-9_.x-]{1,120}$').hasMatch(nombre) &&
    !nombre.contains('..');

Future<void> main(List<String> args) async {
  if (args.length < 2) {
    stderr.writeln('Uso: dart tool/t99_servidor.dart <build/web> <salida en %TEMP%> [puerto]');
    exitCode = 64;
    return;
  }
  final raiz = Directory(args[0]).absolute.path;
  final salida = args[1];
  exigirSalidaEnTemp(salida);
  Directory(salida).createSync(recursive: true);
  final puerto = args.length > 2 ? int.parse(args[2]) : 8099;
  final servidor = await HttpServer.bind(InternetAddress.loopbackIPv4, puerto);
  stdout.writeln('Banco T-99 en http://127.0.0.1:$puerto/ · salida $salida');
  await for (final pedido in servidor) {
    final r = pedido.response..headers.set('Cache-Control', 'no-store');
    try {
      final camino = pedido.uri.path;
      if (pedido.method == 'POST' && (camino == '/t99/captura' || camino == '/t99/registro')) {
        final nombre = pedido.uri.queryParameters['nombre'] ?? '';
        if (!nombreSeguro(nombre)) {
          r.statusCode = HttpStatus.badRequest;
        } else {
          final bytes = <int>[];
          await for (final trozo in pedido) {
            bytes.addAll(trozo);
          }
          final archivo = File('$salida/$nombre');
          if (camino == '/t99/captura') {
            archivo.writeAsBytesSync(bytes);
          } else {
            archivo.writeAsBytesSync([...bytes, 10], mode: FileMode.append);
          }
          r.statusCode = HttpStatus.noContent;
        }
      } else if (pedido.method == 'GET') {
        final relativo = camino == '/' ? 'index.html' : Uri.decodeComponent(camino.substring(1));
        final archivo = File('$raiz/$relativo');
        if (relativo.contains('..') || !archivo.existsSync()) {
          r.statusCode = HttpStatus.notFound;
        } else {
          final ext = relativo.split('.').last.toLowerCase();
          r.headers.contentType = ContentType.parse(_tipos[ext] ?? 'application/octet-stream');
          await r.addStream(archivo.openRead());
        }
      } else {
        r.statusCode = HttpStatus.methodNotAllowed;
      }
    } catch (error) {
      stderr.writeln('Pedido ${pedido.uri}: $error');
      r.statusCode = HttpStatus.internalServerError;
    }
    await r.close();
  }
}
