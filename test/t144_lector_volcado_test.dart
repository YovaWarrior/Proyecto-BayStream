import 'dart:convert';

import 'package:baystream/core/design/design.dart';
import 'package:baystream/core/errors/failures.dart';
import 'package:baystream/features/vessel/data/datasources/local_vessel_codec.dart';
import 'package:baystream/features/vessel/data/repositories/vessel_repository_impl.dart';
import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/data/services/export_list_parser_service.dart';
import 'package:baystream/features/vessel/data/services/export_service.dart';
import 'package:baystream/features/vessel/domain/entities/dangerous_goods.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/services/container_number.dart';
import 'package:baystream/features/vessel/domain/services/departure_baplie_writer.dart';
import 'package:baystream/features/vessel/domain/services/export_list_cross_checker.dart';
import 'package:baystream/features/vessel/domain/services/iso6346_check_digit.dart';
import 'package:baystream/features/vessel/domain/services/loading_operation.dart';
import 'package:baystream/features/vessel/domain/services/un_locode.dart';
import 'package:baystream/features/vessel/presentation/formatters/carga_especial.dart';
import 'package:baystream/features/vessel/presentation/formatters/estadisticas_del_viaje.dart';
import 'package:baystream/features/vessel/presentation/widgets/container_search_delegate.dart';
import 'package:baystream/features/vessel/presentation/widgets/containers_list_view.dart';
import 'package:baystream/features/vessel/presentation/widgets/detalle_contenedor.dart';
import 'package:baystream/features/vessel/presentation/widgets/voyage_summary_card.dart';
import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/t129_fake_firestore.dart';
import 'support/t73_export_list_support.dart';
import 'support/t82_fixture.dart';

/// T-144 · El lector y el volcado: todas las DGS, el LOC+83, los puertos de
/// la 1.5, las matrículas sin espacio, el DIM (RF-005) y el UN/LOCODE
/// (RNF-008). Solo datos sintéticos.

/// Un número ISO 6346 válido a partir de sus diez primeras posiciones.
String iso(String diez) => [
      for (var d = 0; d < 10; d++) '$diez$d',
    ].firstWhere((n) => Iso6346CheckDigit.isValid(n) == true);

const v22 = 'BAPLIE:D:95B:UN:SMDG22';

String edi(String grupos,
        {String unh = v22, String cabecera = "LOC+5+GTSTC:139:6'"}) =>
    "UNB+UNOA:2+TEST+TEST+261111:1200+T144'UNH+T144+$unh'BGM++T144+9'"
    "TDT+20+V144+++TEST:172:20+++:::BUQUE PRUEBA'$cabecera$grupos"
    "UNT+1+T144'UNZ+1+T144'";

/// Un grupo de contenedor de la 2.x: [antes] va entre los pesos y los
/// puertos, [despues] tras el EQD.
String grupo(String numero,
        {String posicion = '0020182',
        String puertos = "LOC+9+GTSTC:139:6'LOC+11+PAMIT:139:6'",
        String antes = '',
        String despues = ''}) =>
    "LOC+147+$posicion::5'MEA+WT++KGM:20000'$antes$puertos"
    "EQD+CN+$numero+22G1+++5'$despues";

VesselVoyage leer(String texto) => BaplieParserService().parse(texto);

List<String> avisos(VesselVoyage viaje, BaplieReadNoticeKind tipo) => viaje
    .readNotices
    .where((n) => n.kind == tipo)
    .expand((n) => n.details)
    .toList();

List<List<String>> filas(String csv) => csv
    .substring(1)
    .split('\r\n')
    .where((l) => l.isNotEmpty)
    .map((l) => l.split(','))
    .toList();

String columna(String csv, String encabezado, {int fila = 1}) =>
    filas(csv)[fila][ExportService.csvHeaders.indexOf(encabezado)];

VesselVoyage viajeCon(List<ContainerUnit> contenedores) => VesselVoyage(
      id: 'v144',
      vessel: const Vessel(id: 'b144', name: 'BUQUE PRUEBA'),
      voyageNumber: 'V144',
      containers: contenedores,
    );

Widget app(Widget hijo, {double letra = 1.0}) => ProviderScope(
      child: MaterialApp(
        theme: BayStreamTema.claro(muelle: true),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(letra)),
          child: child!,
        ),
        home: Scaffold(body: hijo),
      ),
    );

void main() {
  final a = iso('TSTU144000');
  final b = iso('TSTU144001');

  group('Punto 4 · la matrícula sin espacios', () {
    test('numeroDeContenedor quita todo espacio y pasa a mayúsculas, sin '
        'completar a 11', () {
      expect(numeroDeContenedor('BYSU 9672095'), 'BYSU9672095');
      expect(numeroDeContenedor(' bysu 9672095\t'), 'BYSU9672095');
      expect(numeroDeContenedor('BYSU 967209 5'), 'BYSU9672095');
      expect(numeroDeContenedor('EU 876'), 'EU876');
      expect(numeroDeContenedor('EU   876'), 'EU876');
      expect(numeroDeContenedor('MSCU1234567'), 'MSCU1234567');
    });

    test('el lector entrega la matrícula sin espacio y evalúa su dígito', () {
      final conEspacio = '${a.substring(0, 4)} ${a.substring(4)}';
      final viaje = leer(edi(grupo(conEspacio)));
      expect(viaje.containers.single.containerId, a);
      expect(avisos(viaje, BaplieReadNoticeKind.checkDigit), isEmpty);
      final malo = '${a.substring(0, 10)}${(int.parse(a[10]) + 1) % 10}';
      final otro = leer(edi(grupo('${malo.substring(0, 4)} ${malo.substring(4)}')));
      expect(avisos(otro, BaplieReadNoticeKind.checkDigit), [malo]);
    });

    test('un viaje guardado con espacios se lee normalizado, con sus avisos',
        () {
      final viaje = leer(edi(grupo(a, antes: "MEA+VGM++LBR:44000'")));
      final json = viaje.toJson(includeBays: false);
      final contenedores = json['containers'] as List<dynamic>;
      (contenedores.single as Map<String, dynamic>)['containerId'] =
          '${a.substring(0, 4)} ${a.substring(4)}';
      final releido = VesselVoyage.fromJson(
          jsonDecode(jsonEncode(json)) as Map<String, dynamic>);
      expect(releido.containers.single.containerId, a);
      expect(avisos(releido, BaplieReadNoticeKind.weight).single,
          startsWith('$a: '));
    });

    testWidgets('la búsqueda encuentra la matrícula escrita con espacios',
        (tester) async {
      final contenedor = ContainerUnit(id: '1', containerId: a);
      await tester.pumpWidget(app(Consumer(builder: (context, ref, _) {
        final delegado = ContainerSearchDelegate(containers: [contenedor], ref: ref)
          ..query = '${a.substring(0, 4).toLowerCase()} ${a.substring(4, 7)}';
        return delegado.buildResults(context);
      })));
      await tester.pumpAndSettle();
      expect(find.byType(ListTile), findsOneWidget);
    });

    test('el cruce con el listado encuentra un plan guardado con espacios', () {
      final list = const ExportListParserService()
          .parseXlsx(t73ListBytes(), fileName: 'sintetico.xlsx');
      final plan = t73Plan();
      final json = plan.toJson(includeBays: false);
      for (final c in json['containers'] as List<dynamic>) {
        final mapa = c as Map<String, dynamic>;
        final numero = mapa['containerId'] as String;
        if (numero.length == 11) {
          mapa['containerId'] =
              '${numero.substring(0, 4)} ${numero.substring(4)}';
        }
      }
      final conEspacios = VesselVoyage.fromJson(
          jsonDecode(jsonEncode(json)) as Map<String, dynamic>);
      ExportListCrossCheck cruce(VesselVoyage p) {
        final propuestas = [
          for (final x in ExportListCrossChecker.propose(list, p,
              portOfCall: 'GTSTC'))
            x.listCode == '40RF' ? x.choose('45R1') : x,
        ];
        return ExportListCrossChecker.crossCheck(
            list.normalized(ExportListCrossChecker.tableOf(propuestas)),
            p,
            'GTSTC');
      }

      final original = cruce(plan);
      final nuevo = cruce(conEspacios);
      expect(nuevo.matches.map((m) => m.row.order),
          original.matches.map((m) => m.row.order));
      expect(nuevo.matches, isNotEmpty);
      expect(nuevo.fullsNotInPlan.map((r) => r.order),
          original.fullsNotInPlan.map((r) => r.order));
    });

    test('un movimiento sobre la matrícula normalizada pasa la validación; '
        'con espacio no (por eso no hay ninguno guardado)', () {
      expect(MovementDraft.discharge('op', a, '0030984').validate(), isNull);
      expect(
          MovementDraft.discharge(
                  'op', '${a.substring(0, 4)} ${a.substring(4)}', '0030984')
              .validate(),
          isNotNull);
    });

    test('el BAPLIE de salida encuentra el grupo de una matrícula con espacio '
        'y lo copia tal cual, con su DIM', () {
      const dimTransito = "DIM+9+CMT:::25'";
      const dimCarga = "DIM+7+CMT::20'";
      final transito = t82Transit
          .replaceFirst('TSTU0000105', 'TSTU 0000105')
          .replaceFirst("MEA+T++KGM:3900'", "MEA+T++KGM:3900'$dimTransito");
      final llegada = t82ArrivalEdi.replaceFirst(t82Transit, transito);
      final carga = t82LoadingEdi
          .replaceFirst(t82Transit, transito)
          .replaceFirst("MEA+WT++KGM:7200'", "MEA+WT++KGM:7200'$dimCarga");
      final operacion = Operation(
          id: 'op',
          vesselName: 'BUQUE PRUEBA',
          voyageNumber: 'VTEST',
          portOfCall: 'GTSTC',
          createdAt: DateTime.utc(2026),
          sources: [
            OperationSource(
                kind: OperationSourceKind.arrivalBaplie,
                fileName: 'llegada.edi',
                content: llegada),
            OperationSource(
                kind: OperationSourceKind.loadingBaplie,
                fileName: 'carga.edi',
                content: carga),
          ]);
      final parser = BaplieParserService();
      final estado = LoadingOperation.build(
              operationId: 'op',
              arrival: parser.parse(llegada).copyWith(portOfCall: 'GTSTC'),
              loading: parser.parse(carga).copyWith(portOfCall: 'GTSTC'),
              list: t82List,
              movements: t82Loads)
          .state;
      expect(estado.items.containsKey('C:TSTU0000105'), isTrue);
      final salida = const DepartureBaplieWriter().generate(
          operation: operacion,
          state: estado,
          list: t82List,
          movements: t82Loads,
          now: DateTime.utc(2026, 11, 11));
      expect(salida.text, contains(transito));
      expect(salida.text, contains(dimCarga));
      final releido = parser.parse(salida.text);
      final cargado =
          releido.containers.singleWhere((c) => c.containerId == 'TSTU0000014');
      expect(cargado.overWidthRight, 20);
      expect(releido.containers
          .singleWhere((c) => c.containerId == 'TSTU0000105')
          .overHeight, 25);
    });
  });

  group('Punto 3 · los puertos de la 1.5', () {
    const v15 = 'BAPLIE:1:911:UN:SMDG15';
    const puertos15 = "LOC+6+GTSTC'LOC+12+PAMIT'";

    test('la 1.5 lee el puerto de carga de LOC+6 y el de descarga de LOC+12',
        () {
      final c = leer(edi(grupo(a, puertos: puertos15), unh: v15))
          .containers
          .single;
      expect(c.portOfLoading, 'GTSTC');
      expect(c.portOfDischarge, 'PAMIT');
    });

    test('en la 1.5, LOC+9 y LOC+11 no son puertos; en la 2.x, LOC+6 y '
        'LOC+12 tampoco', () {
      final c15 = leer(edi(grupo(a), unh: v15)).containers.single;
      expect([c15.portOfLoading, c15.portOfDischarge], [null, null]);
      final c22 = leer(edi(grupo(a, puertos: puertos15))).containers.single;
      expect([c22.portOfLoading, c22.portOfDischarge], [null, null]);
      final normal = leer(edi(grupo(a))).containers.single;
      expect([normal.portOfLoading, normal.portOfDischarge], ['GTSTC', 'PAMIT']);
    });

    test('el LOC+97 (descarga opcional) no se lee como puerto', () {
      final c = leer(edi(grupo(a, puertos: "LOC+6+GTSTC'LOC+97+XXOPT'"),
              unh: v15))
          .containers
          .single;
      expect(c.portOfDischarge, isNull);
    });

    test('las celdas reservadas de la 1.5 también toman 6 y 12', () {
      final viaje = leer(edi(
          "LOC+147+0020182::5'MEA+WT++KGM:2000'${puertos15}EQD+CN++22G1+++4'",
          unh: v15));
      expect(viaje.reservedSlots.single.portOfLoading, 'GTSTC');
      expect(viaje.reservedSlots.single.portOfDischarge, 'PAMIT');
    });
  });

  group('Punto 2 · el destino final (LOC+83)', () {
    for (final (nombre, valor, esperado) in [
      ('un UN/LOCODE', 'USHOU:139:6', 'USHOU'),
      ('texto libre', 'US - USHOU', 'US - USHOU'),
      ('vacío', '', null),
    ]) {
      test('LOC+83 con $nombre se conserva tal cual', () {
        final c = leer(edi(grupo(a, antes: "LOC+83+$valor'")))
            .containers
            .single;
        expect(c.finalDestination, esperado);
      });
    }

    test('la 1.5 usa el mismo calificador, y no se arrastra al siguiente '
        'contenedor', () {
      final viaje = leer(edi(
          grupo(a, puertos: "LOC+6+GTSTC'LOC+12+PAMIT'LOC+83+COCTG'") +
              grupo(b, posicion: '0020282', puertos: "LOC+6+GTSTC'LOC+12+PAMIT'"),
          unh: 'BAPLIE:1:911:UN:SMDG15'));
      expect(viaje.containers.map((c) => c.finalDestination), ['COCTG', null]);
    });

    test('el CSV llena «Destino final» y el LOC+83 no se valida', () {
      final viaje = leer(edi(grupo(a, antes: "LOC+83+COL'")));
      expect(columna(const ExportService().serializeCsv(viaje), 'Destino final'),
          'COL');
      expect(avisos(viaje, BaplieReadNoticeKind.locode), isEmpty);
    });
  });

  group('Punto 1 · todas las peligrosas', () {
    ContainerUnit peligrosa(List<DangerousGoods>? lista,
            {String? clase, String? onu}) =>
        ContainerUnit(
          id: '1',
          containerId: a,
          isDangerous: true,
          imdgClass: clase ?? lista?.last.hazardClass,
          unNumber: onu ?? lista?.last.unNumber,
          dangerousGoods: lista,
        );
    final dos = [
      DangerousGoods(hazardClass: '3', unNumber: '1993'),
      DangerousGoods(hazardClass: '8', unNumber: '1760'),
    ];

    test('el CSV lleva todas las declaraciones, separadas por « | »', () {
      final csv = const ExportService().serializeCsv(viajeCon([peligrosa(dos)]));
      expect(columna(csv, 'Clase IMDG'), '3 | 8');
      expect(columna(csv, 'Número ONU'), '1993 | 1760');
      expect(columna(csv, 'DGS declarados'), '2');
      expect(ExportService.csvHeaders.last, 'DGS declarados');
    });

    test('lo que falta va como «sin dato» para no perder la posición', () {
      final csv = const ExportService().serializeCsv(viajeCon([
        peligrosa([
          DangerousGoods(hazardClass: '3'),
          DangerousGoods(hazardClass: '8', unNumber: '1760'),
          DangerousGoods(unNumber: '2810'),
        ])
      ]));
      expect(columna(csv, 'Clase IMDG'), '3 | 8 | sin dato');
      expect(columna(csv, 'Número ONU'), 'sin dato | 1760 | 2810');
      expect(columna(csv, 'DGS declarados'), '3');
    });

    test('con una, con ninguna o en un registro viejo, las celdas quedan como '
        'antes', () {
      final csv = const ExportService().serializeCsv(viajeCon([
        peligrosa([DangerousGoods(hazardClass: '3', unNumber: '1993')]),
        ContainerUnit(id: '2', containerId: b, dangerousGoods: const []),
        peligrosa(null, clase: '9', onu: '3077'),
      ]));
      expect([for (final f in [1, 2, 3]) columna(csv, 'Clase IMDG', fila: f)],
          ['3', '', '9']);
      expect([for (final f in [1, 2, 3]) columna(csv, 'Número ONU', fila: f)],
          ['1993', '', '3077']);
      expect([for (final f in [1, 2, 3]) columna(csv, 'DGS declarados', fila: f)],
          ['1', '0', '']);
    });

    test('el lector conserva las dos y el volcado las muestra', () {
      final viaje = leer(edi(grupo(a,
          despues: "DGS+IMD+3+1993'DGS+IMD+8+1760'")));
      final csv = const ExportService().serializeCsv(viaje);
      expect(columna(csv, 'Clase IMDG'), '3 | 8');
      expect(columna(csv, 'Número ONU'), '1993 | 1760');
    });

    testWidgets('el detalle muestra una línea por declaración', (tester) async {
      await tester.pumpWidget(app(DetalleContenedor(
          voyage: viajeCon([peligrosa(dos)]), container: peligrosa(dos))));
      await tester.pumpAndSettle();
      expect(find.text('Carga peligrosa · 2 declaraciones'), findsOneWidget);
      expect(find.text('IMO 3 · UN 1993\nIMO 8 · UN 1760'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('con una sola, el detalle dice lo de siempre', (tester) async {
      final una = peligrosa([DangerousGoods(hazardClass: '3', unNumber: '1993')]);
      await tester.pumpWidget(
          app(DetalleContenedor(voyage: viajeCon([una]), container: una)));
      await tester.pumpAndSettle();
      expect(find.text('Carga peligrosa · IMO 3'), findsOneWidget);
      expect(find.text('UN 1993'), findsOneWidget);
    });

    test('las líneas dicen lo que falta', () {
      expect(lineaDeDeclaracion(DangerousGoods(unNumber: '1993')),
          'IMO sin clase · UN 1993');
      expect(lineaDeDeclaracion(DangerousGoods(hazardClass: '8')),
          'IMO 8 · sin número ONU');
    });

    test('la etiqueta de la Lista y su texto accesible', () {
      expect(etiquetaDePeligrosa(peligrosa(dos)), 'IMO 3 +1');
      expect(etiquetaAccesibleDePeligrosa(peligrosa(dos)),
          'Carga peligrosa: IMO 3 e IMO 8');
      final tres = peligrosa([...dos, DangerousGoods(hazardClass: '2.1')]);
      expect(etiquetaDePeligrosa(tres), 'IMO 3 +2');
      expect(etiquetaAccesibleDePeligrosa(tres),
          'Carga peligrosa: IMO 3, IMO 8 e IMO 2.1');
      final una = peligrosa([DangerousGoods(hazardClass: '3', unNumber: '1993')]);
      expect(etiquetaDePeligrosa(una), 'IMO 3');
      expect(etiquetaDePeligrosa(peligrosa(null, clase: '9', onu: '3077')),
          'IMO 9');
    });

    for (final letra in [1.0, 1.45, 2.0]) {
      testWidgets('la etiqueta «IMO 3 +1» cabe a 360 dp con letra $letra',
          (tester) async {
        tester.view.physicalSize = const Size(360, 800);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final semantica = tester.ensureSemantics();
        final contenedor = ContainerUnit(
          id: '1',
          containerId: a,
          isoSizeType: '22G1',
          status: ContainerStatus.full,
          isDangerous: true,
          isReefer: true,
          temperature: -18,
          imdgClass: '8',
          unNumber: '1760',
          dangerousGoods: dos,
          operatorCode: 'TEST',
        );
        await tester.pumpWidget(app(
            SingleChildScrollView(
                child: ContainersListView(containers: [contenedor])),
            letra: letra));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        final texto = find.text('IMO 3 +1');
        expect(texto, findsOneWidget);
        final parrafo = tester.renderObject<RenderParagraph>(texto);
        expect(parrafo.didExceedMaxLines, isFalse);
        // La tarjeta reúne la semántica de sus hijos (como en T-114): el
        // lector de pantalla oye todas las clases, no «IMO 3 +1».
        final tarjeta = tester.getSemantics(find.descendant(
            of: find.byType(Card), matching: find.byType(InkWell)));
        expect(tarjeta.label, contains('Carga peligrosa: IMO 3 e IMO 8'),
            reason: tarjeta.toStringDeep());
        expect(tarjeta.label, isNot(contains('+1')));
        semantica.dispose();
      });
    }
  });

  group('Punto 5 · el DIM (RF-005)', () {
    ContainerUnit conDim(String dims, {bool antesDelEqd = true}) =>
        leer(edi(grupo(a,
                antes: antesDelEqd ? dims : '',
                despues: antesDelEqd ? '' : dims)))
            .containers
            .single;

    test('cada calificador lee su componente, en CMT', () {
      final c = conDim("DIM+5+CMT:30'DIM+6+CMT:40'DIM+7+CMT::20'"
          "DIM+8+CMT::21'DIM+9+CMT:::25'");
      expect(c.isOverDimension, isTrue);
      expect([
        c.overLengthFront,
        c.overLengthRear,
        c.overWidthRight,
        c.overWidthLeft,
        c.overHeight
      ], [30, 40, 20, 21, 25]);
    });

    test('después del EQD también, y CM de la 1.5 es centímetro', () {
      final c = conDim("DIM+9+CM:::320'", antesDelEqd: false);
      expect(c.overHeight, 320);
      expect(c.isOverDimension, isTrue);
    });

    test('INH se convierte a cm con aviso', () {
      final viaje = leer(edi(grupo(a, antes: "DIM+9+INH:::10'")));
      expect(viaje.containers.single.overHeight, 25);
      expect(avisos(viaje, BaplieReadNoticeKind.dimension).single,
          '$a: DIM+9 en INH convertido a 25 cm');
    });

    for (final (nombre, dim, aviso) in [
      ('sin unidad', "DIM+9+:::25'", 'DIM+9 sin unidad; sin esa medida'),
      ('con otra unidad', "DIM+9+MTR:::2'",
          'DIM+9 con unidad desconocida MTR; sin esa medida'),
      ('con el valor en otro componente', "DIM+7+CMT:20'",
          'DIM+7 sin valor en su componente'),
      ('con un valor que no es número', "DIM+9+CMT:::abc'",
          'DIM+9 con un valor que no es una medida («abc»)'),
    ]) {
      test('$nombre: se avisa, no se toma y queda sobredimensionado', () {
        final viaje = leer(edi(grupo(a, antes: dim)));
        final c = viaje.containers.single;
        expect(c.isOverDimension, isTrue);
        expect([c.overHeight, c.overWidthRight], [null, null]);
        expect(avisos(viaje, BaplieReadNoticeKind.dimension).single, '$a: $aviso');
        expect(medidasFueraDeGalibo(c), 'Medidas no declaradas');
      });
    }

    test('repetido con otro valor deja el mayor, con aviso', () {
      final viaje = leer(edi(grupo(a, antes: "DIM+9+CMT:::25'DIM+9+CMT:::40'")));
      expect(viaje.containers.single.overHeight, 40);
      expect(avisos(viaje, BaplieReadNoticeKind.dimension).single,
          '$a: DIM+9 repetido (25 y 40 cm); se tomó el mayor');
    });

    test('DIM+1, DIM+10 y un valor cero no son sobredimensión', () {
      final c = conDim("DIM+1+CMT:890:250:320'DIM+10+CMT:1:1:1'DIM+9+CMT:::0'");
      expect(c.isOverDimension, isFalse);
      expect(c.overHeight, isNull);
    });

    test('las medidas no se arrastran al siguiente contenedor', () {
      final viaje = leer(edi(grupo(a, antes: "DIM+9+CMT:::25'") +
          grupo(b, posicion: '0020282')));
      expect(viaje.containers.map((c) => c.isOverDimension), [true, false]);
    });

    test('el detalle dice las medidas en su orden, y el CSV las lleva', () {
      final c = conDim("DIM+9+CMT:::25'DIM+8+CMT::20'DIM+5+CMT:30'");
      expect(medidasFueraDeGalibo(c),
          'Frente 30${espacioDuro}cm · Izquierda 20${espacioDuro}cm · '
          'Alto 25${espacioDuro}cm');
      final csv = const ExportService().serializeCsv(viajeCon([c]));
      expect(columna(csv, 'Sobredimensionado'), 'sí');
      expect(columna(csv, 'Sobrealtura (cm)'), '25.0');
      expect(columna(csv, 'Sobreancho izquierdo (cm)'), '20.0');
      expect(columna(csv, 'Sobrelongitud frontal (cm)'), '30.0');
    });

    testWidgets('el detalle muestra la señal con las medidas', (tester) async {
      final c = conDim("DIM+7+CMT::15'");
      await tester.pumpWidget(
          app(DetalleContenedor(voyage: viajeCon([c]), container: c)));
      await tester.pumpAndSettle();
      expect(find.text('Sobredimensionado'), findsOneWidget);
      expect(find.text('Derecha 15${espacioDuro}cm'), findsOneWidget);
    });

    test('las estadísticas cuentan el contenedor fuera de medida', () {
      final c = conDim("DIM+9+CMT:::25'");
      expect(EstadisticasDelViaje.de(viajeCon([c])).fueraDeMedida, 1);
    });
  });

  group('Punto 6 · el UN/LOCODE (RNF-008)', () {
    test('la forma, el país y lo que no se valida', () {
      expect(paisesIso3166, hasLength(249));
      expect(problemaDeUnLocode('GTSTC'), isNull);
      expect(problemaDeUnLocode('TWKHH'), isNull);
      expect(problemaDeUnLocode('ZZABC'), 'el país ZZ no existe en ISO 3166-1');
      expect(problemaDeUnLocode('GT-PB'),
          'no tiene la forma de un UN/LOCODE (2 letras de país y 3 de lugar)');
      expect(problemaDeUnLocode('gtstc'), isNotNull);
      expect(problemaDeUnLocode('XXVSL'), isNull);
      expect(problemaDeUnLocode('XXOPT'), isNull);
      expect(problemaDeUnLocode('*****'), isNull);
      expect(problemaDeUnLocode(''), isNull);
      expect(problemaDeUnLocode(null), isNull);
      expect(problemaDeUnLocode('1234', agencia: '112'), isNull);
      expect(problemaDeUnLocode('1234'), isNotNull);
    });

    test('un puerto que no es UN/LOCODE se avisa, sin rechazar ni cambiar el '
        'código', () {
      final viaje = leer(edi(
          grupo(a, puertos: "LOC+9+GTSTC:139:6'LOC+11+ZZABC:139:6'") +
              grupo(b,
                  posicion: '0020282',
                  puertos: "LOC+9+GT-PB'LOC+11+XXVSL:139:6'LOC+13+PAMIT'"),
          cabecera: "LOC+5+GTSTC:139:6'LOC+61+*****'"));
      expect(viaje.containers.first.portOfDischarge, 'ZZABC');
      expect(viaje.containers.last.portOfLoading, 'GT-PB');
      const forma =
          'no tiene la forma de un UN/LOCODE (2 letras de país y 3 de lugar)';
      expect(avisos(viaje, BaplieReadNoticeKind.locode), [
        '$a: LOC+11 «ZZABC»: el país ZZ no existe en ISO 3166-1',
        '$b: LOC+9 «GT-PB»: $forma',
      ]);
    });

    test('la cabecera y las celdas reservadas también', () {
      final viaje = leer(edi(
          "LOC+147+0020182::5'MEA+WT++KGM:2000'LOC+9+GTSTC'LOC+11+QQXYZ'"
          "EQD+CN++22G1+++4'",
          cabecera: "LOC+5+GT1:139:6'LOC+61+PAMIT'"));
      const forma =
          'no tiene la forma de un UN/LOCODE (2 letras de país y 3 de lugar)';
      const pais = 'el país QQ no existe en ISO 3166-1';
      expect(avisos(viaje, BaplieReadNoticeKind.locode), [
        'Cabecera: LOC+5 «GT1»: $forma',
        'Celda reservada 0020182: LOC+11 «QQXYZ»: $pais',
      ]);
    });

    testWidgets('el aviso sale en el resumen con su causa y su acción',
        (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final viaje = leer(edi(
          grupo(a, puertos: "LOC+9+GTSTC'LOC+11+ZZABC'", antes: "DIM+9+INH:::10'"),
          cabecera: "LOC+5+GT1'"));
      await tester.pumpWidget(MaterialApp(
          home: Scaffold(
              body: SingleChildScrollView(
                  child: VoyageSummaryCard(voyage: viaje)))));
      expect(
          find.text('Códigos de puerto que no son UN/LOCODE: 2 casos · '
              'revisa esos puertos con la agencia'),
          findsOneWidget);
      expect(
          find.text('Medidas DIM revisadas: 1 contenedor · '
              'revisa esas medidas antes de estibar'),
          findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('voyage-locode-notice')));
      await tester.pumpAndSettle();
      expect(find.text('$a: LOC+11 «ZZABC»: el país ZZ no existe en ISO 3166-1'),
          findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('Decisión 3 de la 10.123 · la 1.0.0 sigue leyendo lo guardado', () {
    // Peso, posición, incompleto (sin UNT), UN/LOCODE y DIM.
    VesselVoyage conSeisTipos() => leer(edi(grupo(a,
            posicion: '012A082',
            puertos: "LOC+9+GTSTC'LOC+11+ZZABC'",
            antes: "MEA+VGM++LBR:44000'DIM+9+INH:::10'"))
        .replaceFirst("UNT+1+T144'", ''));

    test('readNotices guarda solo los cuatro tipos de antes; los nuevos van '
        'aparte, como texto', () {
      final viaje = conSeisTipos();
      expect(viaje.readNotices.map((n) => n.kind).toSet(), {
        BaplieReadNoticeKind.weight,
        BaplieReadNoticeKind.position,
        BaplieReadNoticeKind.incomplete,
        BaplieReadNoticeKind.locode,
        BaplieReadNoticeKind.dimension,
      });
      final json = jsonDecode(jsonEncode(viaje.toJson(includeBays: false)))
          as Map<String, dynamic>;
      const deLa100 = {'weight', 'position', 'checkDigit', 'incomplete'};
      final viejos = [
        for (final n in json['readNotices'] as List<dynamic>)
          (n as Map<String, dynamic>)['kind'] as String
      ];
      expect(viejos, isNotEmpty);
      expect(deLa100.containsAll(viejos), isTrue);
      final nuevos = json['extraReadNotices'] as List<dynamic>;
      expect([for (final n in nuevos) (n as Map)['kind']], ['locode', 'dimension']);
      expect((nuevos.first as Map)['details'], [
        '$a: LOC+11 «ZZABC»: el país ZZ no existe en ISO 3166-1',
      ]);
      // Lo mismo que hace la 1.0.0: `byName` sobre `readNotices`, sin lanzar.
      for (final kind in viejos) {
        expect(() => BaplieReadNoticeKind.values.byName(kind), returnsNormally);
      }
    });

    test('el viaje va y vuelve por el almacén local con los seis tipos', () {
      const codec = LocalVesselCodec();
      final viaje = conSeisTipos();
      final releido = codec.decodeVoyage(codec.encodeVoyage(viaje));
      expect(releido.readNotices, viaje.readNotices);
    });

    test('un tipo que esta versión no conoce se salta sin romper el viaje', () {
      final json = jsonDecode(jsonEncode(conSeisTipos().toJson(includeBays: false)))
          as Map<String, dynamic>;
      (json['readNotices'] as List<dynamic>)
          .add({'kind': 'deUnaVersionFutura', 'details': ['algo']});
      (json['extraReadNotices'] as List<dynamic>)
          .add({'kind': 'otroFuturo', 'details': ['algo']});
      final releido = VesselVoyage.fromJson(json);
      expect(releido.containers.single.containerId, a);
      expect(releido.readNotices, conSeisTipos().readNotices);
    });
  });

  group('Corrección 1 (10.125) · una consulta de solo espacios no busca', () {
    // T144-ACC-01: con puertos y naviera, «   » encontraba el contenedor por
    // `contains('')` en esos filtros.
    final conPuertos = leer(edi(grupo('BYSU 9672095',
            despues: "NAD+CA+LINEA:172:20'")))
        .containers
        .single;
    const vacias = {
      'tres espacios': '   ',
      'una tabulación': '\t',
      'el espacio duro': ' ',
      'todo junto': ' \t   ',
    };

    test('el contenedor de la prueba tiene puertos y naviera', () {
      expect(conPuertos.containerId, 'BYSU9672095');
      expect([conPuertos.portOfLoading, conPuertos.portOfDischarge],
          ['GTSTC', 'PAMIT']);
      expect(conPuertos.operatorCode, 'LINEA');
    });

    Widget buscador(String consulta) => app(Consumer(builder: (context, ref, _) {
          final delegado =
              ContainerSearchDelegate(containers: [conPuertos], ref: ref)
                ..query = consulta;
          return delegado.buildResults(context);
        }));

    for (final MapEntry(key: nombre, value: consulta) in vacias.entries) {
      testWidgets('en el buscador, $nombre da el estado inicial y ningún '
          'contenedor', (tester) async {
        await tester.pumpWidget(buscador(consulta));
        await tester.pumpAndSettle();
        expect(find.byType(ListTile), findsNothing);
        expect(find.byKey(const ValueKey('busqueda-sin-resultados')),
            findsNothing);
        expect(find.text('Busca por ID, puerto de descarga o naviera'),
            findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      test('en searchContainers, $nombre da una lista vacía sin leer los '
          'viajes', () async {
        final repositorio = _RepositorioConViajes([viajeCon([conPuertos])]);
        final resultado = await repositorio.searchContainers(consulta);
        expect(resultado.getOrElse(() => [conPuertos]), isEmpty);
        expect(repositorio.lecturas, 0);
      });
    }

    testWidgets('«bysu 967» sigue encontrando BYSU9672095', (tester) async {
      await tester.pumpWidget(buscador('bysu 967'));
      await tester.pumpAndSettle();
      expect(find.byType(ListTile), findsOneWidget);
    });

    test('searchContainers con «bysu 967» sigue encontrando BYSU9672095',
        () async {
      final repositorio = _RepositorioConViajes([viajeCon([conPuertos])]);
      final resultado = await repositorio.searchContainers('bysu 967');
      expect(resultado.getOrElse(() => const []).map((c) => c.containerId),
          ['BYSU9672095']);
      expect(repositorio.lecturas, 1);
    });
  });
}

/// El repositorio real con los viajes en memoria: solo cambia de dónde salen
/// los viajes. La nube falsa de T-129 basta para construirlo; no se usa.
class _RepositorioConViajes extends VesselRepositoryImpl {
  _RepositorioConViajes(this.viajes)
      : super(firestore: T129FakeFirestore().instance);

  final List<VesselVoyage> viajes;
  int lecturas = 0;

  @override
  Future<Either<Failure, List<VesselVoyage>>> getAllVoyages() async {
    lecturas++;
    return Right(viajes);
  }
}
