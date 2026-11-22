// T-120, entrega 2 · Las entradas del banco de la entrega 2, escritas a una
// carpeta nueva de %TEMP% y verificadas con el lector del producto. Es CARGA
// DE PRUEBA, no un viaje (AGENTS.md: no inventar datos); sale del generador
// de la entrega 1 (`tool/t120_buque.dart`), el mismo de las pruebas:
//
// - T120_BUQUE_LISTA_977.edi: el buque de la entrega 1 (nueve puertos).
// - T120_LISTA_CORTA.edi: 200 contenedores entre GTSTC y USHOU, con dos de
//   VELAG y dos sin destino: en Estadísticas, «VELAG» y «Sin destino» tienen
//   su barra, y cada una lleva a una Lista de dos tarjetas (D9, 18.5).
// - T120_REPETIDA.edi: doce contenedores; el 3.º y el 5.º con la misma
//   matrícula, en celdas distintas (10.160 y 10.164).
// - T120_REPETIDA_TRES.edi (corrección 1, T120-E2-01): trece; el 3.º, el 4.º
//   y el 7.º con la misma matrícula.
//
//   dart tool/t120e2_buques.dart "$env:TEMP\t120-e2\caso"
import 'dart:io';

import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';

import 't120_buque.dart';
import 't99_comun.dart';

/// Los puertos de la lista corta: VELAG en la posición 7 de cada 100.
final t120e2PuertosCortos = <String>[
  for (var i = 0; i < 100; i++) i == 7 ? 'VELAG' : (i.isEven ? 'GTSTC' : 'USHOU'),
];

String t120e2ListaCorta() => t120Baplie(200, puertos: t120e2PuertosCortos);

String t120e2Repetida() => t120Baplie(12)
    .replaceFirst('EQD+CN+${t120Numero(5)}', 'EQD+CN+${t120Numero(3)}');

/// Corrección 1 (T120-E2-01): el caso de GLM, la matrícula en tres celdas
/// (el 3.º, el 4.º y el 7.º); el 3.º y el 4.º son de LNB.
String t120e2RepetidaTres() => t120Baplie(13)
    .replaceFirst('EQD+CN+${t120Numero(4)}', 'EQD+CN+${t120Numero(3)}')
    .replaceFirst('EQD+CN+${t120Numero(7)}', 'EQD+CN+${t120Numero(3)}');

void main(List<String> args) {
  if (args.isEmpty) {
    stderr.writeln('Uso: dart tool/t120e2_buques.dart <carpeta nueva en %TEMP%>');
    exit(64);
  }
  exigirSalidaEnTemp(args[0], repo: Directory.current.path);
  final carpeta = carpetaNueva(args[0]);
  void escribir(String nombre, String texto, void Function(VesselVoyage) ver) {
    final archivo = File('${carpeta.path}${Platform.pathSeparator}$nombre')
      ..writeAsStringSync(texto);
    final viaje = BaplieParserService().parse(texto);
    ver(viaje);
    final puertos = <String?, int>{};
    for (final c in viaje.containers) {
      puertos[c.portOfDischarge] = (puertos[c.portOfDischarge] ?? 0) + 1;
    }
    stdout.writeln('${archivo.path}: ${viaje.containers.length} contenedores, '
        '${viaje.containers.map((c) => c.containerId).toSet().length} '
        'matrículas; por destino: $puertos; avisos: '
        '${viaje.readNotices.map((a) => a.kind.name).toList()}');
  }

  escribir('T120_BUQUE_LISTA_977.edi', t120Baplie(977), (v) {
    if (v.containers.length != 977) throw StateError('977: ${v.containers.length}');
  });
  escribir('T120_LISTA_CORTA.edi', t120e2ListaCorta(), (v) {
    final velag = v.containers.where((c) => c.portOfDischarge == 'VELAG');
    final sin = v.containers.where((c) => c.portOfDischarge == null);
    if (v.containers.length != 200 || velag.length != 2 || sin.length != 2) {
      throw StateError('Lista corta: ${v.containers.length}, VELAG '
          '${velag.length}, sin destino ${sin.length}');
    }
  });
  escribir('T120_REPETIDA.edi', t120e2Repetida(), (v) {
    final ids = v.containers.map((c) => c.containerId).toSet();
    if (v.containers.length != 12 || ids.length != 11) {
      throw StateError('Repetida: ${v.containers.length} y ${ids.length}');
    }
  });
  escribir('T120_REPETIDA_TRES.edi', t120e2RepetidaTres(), (v) {
    final ids = v.containers.map((c) => c.containerId).toSet();
    if (v.containers.length != 13 || ids.length != 11) {
      throw StateError('Repetida en tres: ${v.containers.length} y ${ids.length}');
    }
  });
  stdout.writeln('Carga de prueba sintética, no un viaje.');
}
