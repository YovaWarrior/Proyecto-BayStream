// T-120 · RF-018: el buscador entiende la carga especial (DESIGN.md 18.6).
// La fuente es docs/entrega-7nov/fuentes/DOC2.md, la tabla «RF‑018»: «Los
// términos "reefer", "imo" y "oog" filtran los resultados del buscador»; la
// historia, «listar todos los reefer o IMDG del viaje para hacer la ronda de
// revisión».
//
// Contenedores sintéticos (TSTU); sin nube ni almacén real.
import 'package:baystream/core/design/design.dart';
import 'package:baystream/features/vessel/domain/entities/dangerous_goods.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/presentation/formatters/consulta_de_busqueda.dart';
import 'package:flutter_test/flutter_test.dart';

ContainerUnit _c(
  String numero, {
  String? pod = 'GTSTC',
  String? pol = 'HNPCR',
  String? naviera = 'LNA',
  bool refrigerado = false,
  double? temperatura,
  List<DangerousGoods>? peligrosas,
  bool oog = false,
  double? frente,
  double? alto,
}) =>
    ContainerUnit(
      id: numero,
      containerId: numero,
      portOfDischarge: pod,
      portOfLoading: pol,
      operatorCode: naviera,
      isReefer: refrigerado,
      temperature: temperatura,
      temperatureUnit: temperatura == null ? null : 'C',
      isDangerous: peligrosas != null && peligrosas.isNotEmpty,
      dangerousGoods: peligrosas,
      imdgClass: peligrosas == null || peligrosas.isEmpty
          ? null
          : peligrosas.last.hazardClass,
      unNumber: peligrosas == null || peligrosas.isEmpty
          ? null
          : peligrosas.last.unNumber,
      isOverDimension: oog,
      overLengthFront: frente,
      overHeight: alto,
    );

final _frio = _c('TSTU0000011', refrigerado: true, temperatura: -18);
final _frioApagado = _c('TSTU0000022', refrigerado: true, pod: 'USHOU');
final _clase3 = _c('TSTU0000033',
    peligrosas: [DangerousGoods(hazardClass: '3', unNumber: '1993')]);
final _clase21 = _c('TSTU0000044',
    pod: 'USHOU',
    peligrosas: [DangerousGoods(hazardClass: '2.1', unNumber: '1950')]);
final _dosDeclaraciones = _c('TSTU0000055', pod: 'PAMIT', peligrosas: [
  DangerousGoods(hazardClass: '8', unNumber: '1760'),
  DangerousGoods(hazardClass: '3', unNumber: '1993'),
]);
final _fuera = _c('TSTU0000066', oog: true, frente: 30, alto: 25);
final _seco = _c('IMOU0000077', naviera: 'LNB');
final _todos = <ContainerUnit>[
  _frio,
  _frioApagado,
  _clase3,
  _clase21,
  _dosDeclaraciones,
  _fuera,
  _seco,
];

List<String> _busca(String consulta) {
  final c = ConsultaDeBusqueda.interpretar(consulta);
  return [
    for (final x in _todos)
      if (c.coincide(x)) x.containerId
  ];
}

/// La búsqueda de antes de T-120 (T-144 y T-146), para comparar.
bool _deAntes(ContainerUnit c, String query) {
  final normal = query.toUpperCase().trim();
  final numero = query.replaceAll(RegExp(r'\s'), '').toUpperCase();
  return (numero.isNotEmpty && c.containerId.toUpperCase().contains(numero)) ||
      (c.portOfDischarge?.toUpperCase().contains(normal) ?? false) ||
      (c.portOfLoading?.toUpperCase().contains(normal) ?? false) ||
      (c.operatorCode?.toUpperCase().contains(normal) ?? false);
}

void main() {
  group('los términos (ConsultaDeBusqueda.interpretar)', () {
    const casos = <String, CargaEspecial>{
      'reefer': CargaEspecial.refrigerado,
      'reefers': CargaEspecial.refrigerado,
      'refrigerado': CargaEspecial.refrigerado,
      'refrigerados': CargaEspecial.refrigerado,
      'refrigerada': CargaEspecial.refrigerado,
      'refrigeradas': CargaEspecial.refrigerado,
      'imo': CargaEspecial.peligrosa,
      'imdg': CargaEspecial.peligrosa,
      'peligrosa': CargaEspecial.peligrosa,
      'peligrosas': CargaEspecial.peligrosa,
      'peligroso': CargaEspecial.peligrosa,
      'peligrosos': CargaEspecial.peligrosa,
      'oog': CargaEspecial.fueraDeMedida,
      'sobredimensionado': CargaEspecial.fueraDeMedida,
      'sobredimensionados': CargaEspecial.fueraDeMedida,
      'sobredimensionada': CargaEspecial.fueraDeMedida,
      'sobredimensionadas': CargaEspecial.fueraDeMedida,
      'fuera de medida': CargaEspecial.fueraDeMedida,
    };
    for (final MapEntry(key: termino, value: carga) in casos.entries) {
      test('«$termino» es ${carga.rotulo}, sin resto', () {
        final c = ConsultaDeBusqueda.interpretar(termino);
        expect(c.cargas, {carga});
        expect(c.resto, isEmpty);
      });
    }

    test('sin mayúsculas ni tildes', () {
      for (final t in ['REEFER', 'Refrigerádos', 'PELIGROSA', 'Imdg', 'OoG',
          'Fuera De Medida']) {
        expect(ConsultaDeBusqueda.interpretar(t).cargas, hasLength(1),
            reason: t);
      }
    });

    test('solo palabras enteras: «imou», «reefer1» y «fuera» son resto', () {
      for (final t in ['imou', 'reefer1', 'fuera', 'de medida', 'xoog']) {
        final c = ConsultaDeBusqueda.interpretar(t);
        expect(c.cargas, isEmpty, reason: t);
        expect(c.resto, t, reason: t);
      }
    });

    test('la clase IMO: «imo 3», «imdg 3», «imo3», «clase 3»', () {
      for (final t in ['imo 3', 'imdg 3', 'imo3', 'clase 3', 'IMDG3']) {
        final c = ConsultaDeBusqueda.interpretar(t);
        expect(c.cargas, {CargaEspecial.peligrosa}, reason: t);
        expect(c.claseImo, '3', reason: t);
        expect(c.resto, isEmpty, reason: t);
      }
      expect(ConsultaDeBusqueda.interpretar('imo 2.1').claseImo, '2.1');
      final sola = ConsultaDeBusqueda.interpretar('clase');
      expect(sola.cargas, isEmpty);
      expect(sola.resto, 'clase');
    });

    test('el número ONU: «un 1993» y «onu 1993»; «un» solo es resto', () {
      for (final t in ['un 1993', 'ONU 1993']) {
        final c = ConsultaDeBusqueda.interpretar(t);
        expect(c.cargas, {CargaEspecial.peligrosa}, reason: t);
        expect(c.numeroOnu, '1993', reason: t);
      }
      final un = ConsultaDeBusqueda.interpretar('un gtstc');
      expect(un.cargas, isEmpty);
      expect(un.resto, 'un gtstc');
    });

    test('varias cargas y un resto, con el espacio duro y la tabulación', () {
      final c = ConsultaDeBusqueda.interpretar('reefer imo\tGTSTC');
      expect(c.cargas, {CargaEspecial.refrigerado, CargaEspecial.peligrosa});
      expect(c.resto, 'GTSTC');
    });
  });

  group('lo que sale (coincide)', () {
    test('«reefer» da los refrigerados, con temperatura y sin ella', () {
      expect(_busca('reefer'), ['TSTU0000011', 'TSTU0000022']);
    });

    test('«imo» da las peligrosas; «oog», las fuera de medida', () {
      expect(_busca('imo'), ['TSTU0000033', 'TSTU0000044', 'TSTU0000055']);
      expect(_busca('oog'), ['TSTU0000066']);
    });

    test('«imo 3» mira todas las declaraciones; «imo 2» da también la 2.1', () {
      expect(_busca('imo 3'), ['TSTU0000033', 'TSTU0000055']);
      expect(_busca('imo 2'), ['TSTU0000044']);
      expect(_busca('imo 2.1'), ['TSTU0000044']);
      expect(_busca('imo 8'), ['TSTU0000055']);
    });

    test('«un 1993» da las que lo declaran, en cualquier declaración', () {
      expect(_busca('un 1993'), ['TSTU0000033', 'TSTU0000055']);
    });

    test('varias cargas son cualquiera de ellas (D7)', () {
      expect(_busca('reefer imo'), [
        'TSTU0000011',
        'TSTU0000022',
        'TSTU0000033',
        'TSTU0000044',
        'TSTU0000055',
      ]);
    });

    test('el resto se cumple además (D7): «reefer USHOU»', () {
      expect(_busca('reefer USHOU'), ['TSTU0000022']);
      expect(_busca('imo ushou'), ['TSTU0000044']);
    });

    test('«imou» busca la matrícula como siempre, no la carga', () {
      expect(_busca('imou'), ['IMOU0000077']);
    });

    test('sin términos, la búsqueda es la de antes', () {
      for (final q in ['gtstc', 'LNB', 'tstu 00000', '0000044', 'hnpcr', 'xyz',
          'TSTU 000003 3']) {
        expect(
          _busca(q),
          [
            for (final x in _todos)
              if (_deAntes(x, q)) x.containerId
          ],
          reason: q,
        );
      }
    });
  });

  group('lo que dice', () {
    test('la línea de arriba, con su concordancia', () {
      String? r(String q, int n) => ConsultaDeBusqueda.interpretar(q).resumen(n);
      expect(r('reefer', 12), '12 refrigerados');
      expect(r('reefer', 1), '1 refrigerado');
      expect(r('imo reefer', 17), '17 peligrosos o refrigerados');
      expect(r('imo 3', 3), '3 peligrosos de clase 3');
      expect(r('un 1993', 1), '1 peligroso con UN${espacioDuro}1993');
      expect(r('oog', 2), '2 fuera de medida');
      expect(r('reefer gtstc', 5), '5 refrigerados que coinciden con «gtstc»');
      expect(r('reefer gtstc', 1), '1 refrigerado que coincide con «gtstc»');
      expect(r('gtstc', 5), isNull);
    });

    test('por qué salió cada uno, con comas', () {
      final c = ConsultaDeBusqueda.interpretar('reefer imo oog');
      expect(c.motivos(_frio), ['Refrigerado, $menos${'18'}$espacioDuro°C']);
      expect(c.motivos(_frioApagado),
          ['Refrigerado, el archivo no trae temperatura']);
      expect(c.motivos(_clase3), ['Peligrosa IMDG, IMO 3, UN 1993']);
      expect(c.motivos(_dosDeclaraciones), ['Peligrosa IMDG, IMO 8 +1']);
      expect(c.motivos(_fuera), [
        'Fuera de medida: Frente 30${espacioDuro}cm, Alto 25${espacioDuro}cm'
      ]);
      expect(c.motivos(_seco), isEmpty);
      // Solo las cargas pedidas.
      expect(ConsultaDeBusqueda.interpretar('imo').motivos(_frio), isEmpty);
    });
  });
}
