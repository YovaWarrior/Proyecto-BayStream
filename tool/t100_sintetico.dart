// T-100 · Una escala sintética completa para el manual: el plano de llegada y
// el plan de carga de un mismo buque, viaje y puerto, para recorrer la descarga,
// la carga por OR y el BAPLIE de salida con capturas (10.99).
//
// Es CARGA DE PRUEBA, no un viaje: buque «BUQUE MANUAL» (IMO sintético),
// viaje M100, escala GTSTC. No usa el corpus. La estructura de los segmentos
// es la de tool/t98_support.dart (SMDG22), con TDT como el de t99_sintetico.
//
// Salida (solo en %TEMP%):
//   T100_LLEGADA.edi  emitido al salir de PAMIT rumbo a GTSTC: 60 a bordo,
//                     30 se descargan en GTSTC y 30 van de paso a USHOU/USMSY;
//   T100_CARGA.edi    emitido al salir de GTSTC: los 30 de paso en sus celdas
//                     y 30 cargas en GTSTC (20 llenos y 10 vacíos) en las celdas
//                     que dejan las descargas;
//   cargas.json       las 30 cargas, para el listado de la agencia
//                     (tool/t100_listado.py).
// El script se verifica con el lector real y con las cuentas de la escala:
// si algo no cuadra, falla y hay que detenerse.
//
//   dart tool/t100_sintetico.dart <salida en %TEMP%>
import 'dart:convert';
import 'dart:io';

import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/services/operation_sources.dart';

import 't99_comun.dart';
import 't99_sintetico.dart' show digitoIso6346, imoSintetico;

const escala = 'GTSTC';
const nombre = 'BUQUE MANUAL';
const viaje = 'M100';
final imo = imoSintetico('990055');

/// Una celda del plano: bahía, fila y nivel, en BBBRRTT.
String celda(int bahia, int fila, int nivel) =>
    '${bahia.toString().padLeft(3, '0')}${fila.toString().padLeft(2, '0')}'
    '${nivel.toString().padLeft(2, '0')}';

class Caja {
  final String id;
  final String tipo;
  final String celda;
  final String pol;
  final String pod;
  final String linea;
  final int kg;
  final bool lleno;
  final double? temperatura;
  final String? un;
  const Caja(this.id, this.tipo, this.celda, this.pol, this.pod, this.linea,
      this.kg, this.lleno,
      {this.temperatura, this.un});

  List<String> get segmentos => [
        'LOC+147+$celda::5',
        'MEA+WT++KGM:$kg',
        'LOC+9+$pol:139:6',
        'LOC+11+$pod:139:6',
        'EQD+CN+$id+$tipo++2+${lleno ? 5 : 4}',
        'NAD+CA+$linea:172:20',
        if (temperatura != null) 'TMP+2+${temperatura!.toStringAsFixed(1)}:CEL',
        if (un != null) 'DGS+IMD+9+$un',
      ];
}

String id(int n) {
  final diez = 'MNLU${n.toString().padLeft(6, '0')}';
  return '$diez${digitoIso6346(diez)}';
}

String mensaje(List<Caja> cajas,
    {required String salida, required String siguiente, required String ref}) {
  final s = <String>[
    'UNB+UNOA:2+MNL+MNL+261021:0100+$viaje',
    'UNH+$viaje+BAPLIE:D:95B:UN:SMDG22',
    'BGM++$ref+9',
    'DTM+137:2610210100:201',
    'TDT+20+$viaje+++MNL:172:20+++$imo:146:11:$nombre',
    'LOC+5+$salida:139:6',
    'LOC+61+$siguiente:139:6',
    'DTM+178:2610210100:201',
    for (final c in cajas) ...c.segmentos,
  ];
  s.add('UNT+${s.length}+$viaje');
  s.add('UNZ+1+$viaje');
  return "${s.join("'\n")}'\n";
}

void main(List<String> args) {
  if (args.length != 1) {
    stderr.writeln('Uso: dart tool/t100_sintetico.dart <salida en %TEMP%>');
    exitCode = 64;
    return;
  }
  final salida = args.single;
  exigirSalidaEnTemp(salida, repo: Directory.current.path);
  carpetaNueva(salida);

  // Tres bahías de 40 pies; filas 01-06; bodega 02-06 y cubierta 82-84.
  const bahias = [2, 6, 10];
  final descargan = <String>[]; // celdas que se vacían en la escala
  final dePaso = <String>[];
  for (final b in bahias) {
    for (final f in [1, 2, 3, 4, 5, 6]) {
      descargan.add(celda(b, f, 6));
      dePaso.add(celda(b, f, 2));
      (f <= 2 ? descargan : dePaso).add(celda(b, f, 4));
    }
    descargan.add(celda(b, 1, 82));
    descargan.add(celda(b, 2, 82));
  }
  assert(descargan.length == 30 && dePaso.length == 30);

  var n = 0;
  final llegada = <Caja>[];
  final transito = <Caja>[];
  for (var i = 0; i < 30; i++) {
    n++;
    llegada.add(Caja(id(n), i % 7 == 3 ? '45R1' : '45G1', descargan[i], 'PAMIT',
        escala, i.isEven ? 'MNA' : 'MNB', 12000 + 350 * i, true,
        temperatura: i % 7 == 3 ? -18.0 : null, un: i == 11 ? '3077' : null));
  }
  for (var i = 0; i < 30; i++) {
    n++;
    transito.add(Caja(id(n), i % 9 == 4 ? '45R1' : '42G1', dePaso[i], 'HNPCR',
        i.isEven ? 'USHOU' : 'USMSY', i % 3 == 0 ? 'MNB' : 'MNA',
        9000 + 420 * i, i % 5 != 2,
        temperatura: i % 9 == 4 ? 4.0 : null, un: i == 20 ? '1950' : null));
  }
  final cargas = <Caja>[];
  for (var i = 0; i < 30; i++) {
    n++;
    final vacio = i >= 20;
    cargas.add(Caja(
        id(n),
        i % 8 == 5 ? '45R1' : (i.isOdd ? '42G1' : '45G1'),
        descargan[i],
        escala,
        i % 3 == 0 ? 'USMSY' : 'USHOU',
        i % 4 == 0 ? 'MNB' : 'MNA',
        vacio ? 3900 : 14000 + 500 * i,
        !vacio,
        temperatura: i % 8 == 5 ? -20.0 : null,
        un: i == 9 ? '3082' : null));
  }

  final textoLlegada = mensaje([...llegada, ...transito],
      salida: 'PAMIT', siguiente: escala, ref: 'M100LLEGADA');
  final textoCarga = mensaje([...transito, ...cargas],
      salida: escala, siguiente: 'USHOU', ref: 'M100CARGA');

  // Verificación con el lector real y con las reglas de la escala.
  final lector = BaplieParserService();
  final vLlegada = lector.parse(textoLlegada);
  final vCarga = lector.parse(textoCarga);
  final cl = vLlegada.cargoCountsFor(escala);
  final cc = vCarga.cargoCountsFor(escala);
  final comprobaciones = <String, bool>{
    'llegada: 60 leídos': vLlegada.totalContainers == 60,
    'llegada: 30 se descargan en $escala': cl.discharged == 30,
    'llegada: 0 se cargan': cl.loaded == 0,
    'llegada: 30 de paso': cl.transit == 30,
    'llegada: siguiente puerto $escala': vLlegada.portOfNextCall == escala,
    'llegada: tipo = plano de llegada':
        OperationSources.baplieKind(vLlegada, escala) == OperationSourceKind.arrivalBaplie,
    'carga: 60 leídos': vCarga.totalContainers == 60,
    'carga: 30 se cargan en $escala': cc.loaded == 30,
    'carga: 0 se descargan': cc.discharged == 0,
    'carga: tipo = plan de carga':
        OperationSources.baplieKind(vCarga, escala) == OperationSourceKind.loadingBaplie,
    'carga: sale de $escala': vCarga.portOfOrigin == escala,
    'mismo buque y viaje': vLlegada.vessel.name == vCarga.vessel.name &&
        vLlegada.voyageNumber == vCarga.voyageNumber &&
        vLlegada.voyageNumber == viaje,
    'sin avisos del lector':
        vLlegada.readNotices.isEmpty && vCarga.readNotices.isEmpty,
    'geometría propuesta cubre todo':
        VesselProfile.proposeFrom(vLlegada).geometry.coversAll(vLlegada.stowagePositions) &&
            VesselProfile.proposeFrom(vCarga).geometry.coversAll(vCarga.stowagePositions),
    'refrigerados y peligrosas presentes':
        vLlegada.containers.any((c) => c.isReefer) &&
            vLlegada.containers.any((c) => c.isDangerous) &&
            vCarga.containers.any((c) => c.isReefer),
  };
  final fallas = comprobaciones.entries.where((e) => !e.value).map((e) => e.key).toList();

  File('$salida/T100_LLEGADA.edi').writeAsStringSync(textoLlegada);
  File('$salida/T100_CARGA.edi').writeAsStringSync(textoCarga);
  escribirJson('$salida/cargas.json', {
    'declaracion': '100 % sintético, sin corpus ni datos comerciales.',
    'buque': nombre,
    'viaje': viaje,
    'escala': escala,
    'cargas': [
      for (final c in cargas)
        {
          'contenedor': c.id,
          'iso': c.tipo,
          'pod': c.pod,
          'linea': c.linea,
          'lleno': c.lleno,
          'kg': c.kg,
          'celda': c.celda,
          'temperatura': c.temperatura,
          'un': c.un,
        }
    ],
  });
  escribirJson('$salida/manifiesto.json', {
    'instrumento': 'tool/t100_sintetico.dart',
    'archivos': {
      for (final f in ['T100_LLEGADA.edi', 'T100_CARGA.edi'])
        f: {'sha256': sha256DeArchivo('$salida/$f'), 'bytes': File('$salida/$f').lengthSync()},
    },
    'comprobaciones': comprobaciones,
  });
  for (final e in comprobaciones.entries) {
    stdout.writeln('${e.value ? 'ok ' : 'NO '} ${e.key}');
  }
  stdout.writeln('Carga de prueba sintética, no un viaje. Salida: $salida');
  if (fallas.isNotEmpty) {
    stderr.writeln('DETENTE: no cuadra: ${fallas.join('; ')}');
    exitCode = 1;
  }
}
