// Aceptación de T-98 (Timonel): escribe los dos casos UN/LOCODE de la batería
// tal como los arma tool/t98_estandares_test.dart, para cargarlos en un cliente.
// dart tool/t98acc_sinteticos.dart <carpeta bajo TEMP>
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';

import 't98_support.dart';

void main(List<String> args) {
  if (args.length != 1) {
    stderr.writeln('Uso: dart tool/t98acc_sinteticos.dart <carpeta TEMP>');
    exit(64);
  }
  final out = t98Output(args.single);
  final cases = {
    'T98ACC_PUERTOS_GTSTC_PAMIT.edi': t98Message(),
    'T98ACC_PUERTO_ZZZZZ.edi': t98Message().replaceAll('PAMIT', 'ZZZZZ'),
  };
  for (final entry in cases.entries) {
    final file = File('${out.path}${Platform.pathSeparator}${entry.key}');
    if (file.existsSync()) throw StateError('No sobrescribe ${file.path}');
    final bytes = utf8.encode(entry.value);
    file.writeAsBytesSync(bytes);
    stdout.writeln('${entry.key} ${bytes.length} ${sha256.convert(bytes)}');
  }
}
