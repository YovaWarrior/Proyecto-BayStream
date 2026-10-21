// Archivo ficticio de la tanda con Carlos; nunca contiene datos del corpus.
import 'dart:convert';
import 'dart:io';

import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';

import 't98_support.dart';

void main(List<String> args) {
  if (args.length != 1) throw ArgumentError('Indicar carpeta TEMP vacía.');
  final out = t98Output(args.single);
  final file = File('${out.path}/PRUEBA_T98.edi');
  if (file.existsSync()) throw StateError('No sobrescribir el sintético.');
  final secondId = 'TSTU000098${t98CheckDigit('TSTU000098')}';
  final second = [
    'LOC+147+0030182::5',
    'MEA+WT++KGM:12000',
    'LOC+9+GTSTC:139:6',
    'LOC+11+PAMIT:139:6',
    'RFF+BM:2',
    'EQD+CN+$secondId+22G1++2+5',
    'NAD+CA+T98B:172:20',
  ].join("'\n");
  final source = t98Message(position: '0010182')
      .replaceFirst('UNT+13+T98', "NAD+CA+T98A:172:20'\n$second'\nUNT+21+T98");
  final voyage = BaplieParserService().parse(source);
  if (voyage.containers.any((c) => c.grossWeight == null)) {
    throw StateError('El sintético perdió un peso declarado.');
  }
  final total =
      voyage.containers.fold<double>(0, (sum, c) => sum + c.grossWeight!);
  if (voyage.totalContainers != 2 ||
      total != 36000 ||
      voyage.containers.map((c) => c.operatorCode).toSet().length != 2 ||
      voyage.containers
          .any((c) => !{'T98A', 'T98B'}.contains(c.operatorCode)) ||
      voyage.containers.any((c) => !t98ValidId(c.containerId))) {
    throw StateError(
        'El sintético perdió unidades, pesos o navieras ficticias.');
  }
  file.writeAsStringSync(source, encoding: utf8);
  t98Json(File('${out.path}/sintetico.json'), {
    'declaracion': '100 % sintético, sin corpus ni datos comerciales.',
    'archivo': file.path,
    'sha256': t98Hash(utf8.encode(source)),
    'contenedores': voyage.totalContainers,
    'pesoBrutoKg': total,
    'idsSinteticos': voyage.containers.map((c) => c.containerId).toList(),
    'posiciones':
        voyage.containers.map((c) => c.stowagePosition?.toIsoCode()).toList(),
    'navierasFicticias': voyage.containers.map((c) => c.operatorCode).toList(),
    'operacion':
        'Carlos crea PRUEBA T-98 desde la app; este script no publica.',
  });
  stdout.writeln('T98 sintético validado: 2 unidades, 36000 kg, dos bahías.');
}
