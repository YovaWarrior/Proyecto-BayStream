import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:baystream/core/errors/exceptions.dart';
import 'package:baystream/features/vessel/data/datasources/hive_vessel_data_source.dart';
import 'package:baystream/features/vessel/data/repositories/local_vessel_repository_impl.dart';
import 'package:baystream/features/vessel/data/services/export_list_parser_service.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/services/export_list_cross_checker.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/t73_export_list_support.dart';

void main() {
  const parser = ExportListParserService();
  late ExportList list;

  setUpAll(() => list = parser.parseXlsx(t73ListBytes(), fileName: 'sintetico.xlsx'));

  group('T-73 lectura del Excel', () {
    test('ubica las columnas por encabezado y separa las agencias', () {
      expect(list.rows.map((r) => r.order), [1, 2, 3, 4, 5, 6, 8]);
      expect(list.agencies, {'AGENCIA A S.A.': 3, 'AGENCIA B S.A.': 4});
      expect(list.titleLines, contains('M/V: BUQUE PRUEBA V-T73'));
      expect(list.fulls.length, 4);
      expect(list.empties.length, 3);
      final first = list.byOrder(1)!;
      expect(first.containerId, 'TSTU0000014');
      expect(first.listType, '40HC');
      expect(first.listPod, 'COMNG');
      expect(first.listPot, 'COMNG');
      expect(first.listLine, 'LNX');
      expect(first.origin, 'GT');
      expect(first.agency, 'AGENCIA A S.A.');
    });

    test('recalcula PESO NETO y guarda el VGM exacto', () {
      final row = list.byOrder(2)!;
      expect(row.vgmKg, 7266.59);
      expect(row.tareKg, 2230);
      expect(row.netKg, closeTo(5036.59, 1e-9));
      expect(row.hour, '14:35');
      expect(row.seal, 'S-0001');
      expect(list.byOrder(1)!.netKg, 16900);
      final empty = list.byOrder(4)!;
      expect(empty.isEmpty, isTrue);
      expect(empty.vgmKg, isNull);
      expect(empty.netKg, isNull);
      expect(empty.tareKg, 2185);
    });

    test('informa con su número de fila lo que no entiende', () {
      expect(list.issues.map((i) => i.sheetRow), [14, 15]);
      expect(list.issues.first.message, contains('no marca lleno (F) ni vacío (E)'));
      expect(list.issues.last.message, contains('TOTAL 8 CONTENEDORES'));
    });

    test('lee clase IMO y números ONU de CONTENIDO', () {
      final row = list.byOrder(3)!;
      expect(row.imdgClass, '9');
      expect(row.unNumbers, ['3082', '3077']);
      expect(row.contents, 'DANGEROUS CARGO IMO 9 UN 3082, 3077');
      String parse(String text) {
        final r = ExportListParserService.parseDangerousContents(text);
        return '${r.imdgClass} ${r.unNumbers.join(',')}';
      }

      expect(parse('IMDG 3 UN1203'), '3 1203');
      expect(parse('Clase 2.1 UN 1950 y 1075'), '2.1 1950,1075');
      expect(parse('GENERAL CARGO'), 'null ');
    });

    test('sin fila de encabezados o con columnas faltantes no inventa filas', () {
      expect(() => parser.parseGrid([['LISTADO'], ['1', 'X']]),
          throwsA(isA<ExportListParsingException>()));
      expect(
          () => parser.parseGrid([
                ['OR', 'CONTENEDOR', 'TIPO', 'POD', 'TARA', 'F', 'E', 'CONTENIDO', 'OPR'],
              ]),
          throwsA(isA<ExportListParsingException>()
              .having((e) => e.message, 'message', contains('PESO VGM'))));
      expect(() => parser.parseXlsx([1, 2, 3]), throwsA(isA<ExportListParsingException>()));
    });

    test('rechaza con su motivo un número repetido y acepta la coma decimal', () {
      final parsed = parser.parseGrid([
        ['OR', 'CONTENEDOR', 'TIPO', 'POD', 'TARA', 'PESO VGM', 'F', 'E', 'CONTENIDO', 'OPR'],
        [1, 'tstu 0000014', '20ST', 'PAMIT', '2 230', '7266,59', 'X', null, 'GENERAL', 'LNX'],
        [2, 'TSTU0000014', '20ST', 'PAMIT', 2230, 9000, 'X', null, 'GENERAL', 'LNX'],
      ]);
      expect(parsed.rows.single.containerId, 'TSTU0000014');
      expect(parsed.rows.single.vgmKg, 7266.59);
      expect(parsed.rows.single.tareKg, 2230);
      expect(parsed.issues.single.sheetRow, 3);
      expect(parsed.issues.single.message, contains('ya está en la fila 2'));
    });
  });

  group('T-73 rutas absolutas de workbook.xml.rels', () {
    String rels(List<int> bytes) => utf8.decode(
        ZipDecoder().decodeBytes(bytes).findFile('xl/_rels/workbook.xml.rels')!.content);

    test('el fixture de script las trae, como LISTADO_A08.xlsx, y el de Excel no', () {
      expect(rels(t73ListBytes()), contains('Target="/xl/worksheets/sheet1.xml"'));
      expect(rels(t73ListBytes()), contains('Target="/xl/styles.xml"'));
      expect(rels(t73ExcelListBytes()), isNot(contains('Target="/')));
    });

    test('vuelve relativas la hoja, los estilos, sharedStrings y el tema', () {
      const absolute = '<Relationships>'
          '<Relationship Id="rId1" Type="worksheet" Target="/xl/worksheets/sheet1.xml"/>'
          '<Relationship Id="rId2" Type="styles" Target="/xl/styles.xml"/>'
          "<Relationship Id='rId3' Type='sharedStrings' Target='/xl/sharedStrings.xml'/>"
          '<Relationship Id="rId4" Type="theme" Target="/xl/theme/theme1.xml"/>'
          '<Relationship Id="rId5" Type="customXml" Target="/customXml/item1.xml"/>'
          '<Relationship Id="rId6" Type="hyperlink" Target="https://example.com/a" TargetMode="External"/>'
          '</Relationships>';
      final fixed = ExportListParserService.relativeWorkbookTargets(absolute);
      expect(fixed, contains('Target="worksheets/sheet1.xml"'));
      expect(fixed, contains('Target="styles.xml"'));
      expect(fixed, contains("Target='sharedStrings.xml'"));
      expect(fixed, contains('Target="theme/theme1.xml"'));
      expect(fixed, contains('Target="../customXml/item1.xml"'));
      expect(fixed, contains('Target="https://example.com/a"'));
      // Lo que ya es relativo no se toca, y el libro pasa intacto.
      expect(ExportListParserService.relativeWorkbookTargets(fixed), fixed);
      final excelBytes = t73ExcelListBytes();
      expect(identical(ExportListParserService.withRelativeTargets(excelBytes), excelBytes), isTrue);
      expect(rels(ExportListParserService.withRelativeTargets(t73ListBytes())),
          isNot(contains('Target="/')));
    });
  });

  group('T-73 forma guardada desde Excel', () {
    late ExportList excel;
    setUpAll(() => excel = parser.parseXlsx(t73ExcelListBytes(), fileName: 'sintetico.xlsx'));

    test('se lee igual que la forma del script', () {
      expect(excel.titleLines, list.titleLines);
      expect(excel.rows, list.rows);
      expect(excel.issues, list.issues);
      expect(excel.agencies, list.agencies);
      expect(excel.byOrder(2)!.hour, '14:35');
    });

    test('el neto se recalcula aunque venga con valor en caché', () {
      // La caché del OR 2 dice 5000; VGM − TARA es 5036.59.
      expect(excel.byOrder(2)!.netKg, closeTo(5036.59, 1e-9));
      expect(excel.byOrder(1)!.netKg, 16900);
      final parsed = parser.parseGrid([
        ['OR', 'CONTENEDOR', 'TIPO', 'POD', 'TARA', 'PESO VGM', 'PESO NETO', 'F', 'E', 'CONTENIDO', 'OPR'],
        [1, 'TSTU0000014', '40HC', 'COMNG', 3900, 20800, 1234.0, 'X', null, 'GENERAL', 'LNX'],
      ]);
      expect(parsed.rows.single.netKg, 16900);
    });

    test('el OR acepta 1.0 y los pesos como double', () {
      final parsed = parser.parseGrid([
        ['OR', 'CONTENEDOR', 'TIPO', 'POD', 'TARA', 'PESO VGM', 'F', 'E', 'CONTENIDO', 'OPR'],
        [1.0, 'TSTU0000014', '40HC', 'COMNG', 3900.0, 20800.0, 'X', null, 'GENERAL', 'LNX'],
        [2.5, 'TSTU0000020', '20ST', 'JMKWL', 2230.0, 7266.59, 'X', null, 'GENERAL', 'LNX'],
      ]);
      expect(parsed.rows.single.order, 1);
      expect(parsed.rows.single.tareKg, 3900);
      expect(parsed.rows.single.vgmKg, 20800);
      // Un OR con decimales no es un número de orden: se informa, no se redondea.
      expect(parsed.issues.single.sheetRow, 3);
    });
  });

  group('T-73 equivalencias', () {
    test('se proponen solas desde los contenedores que están en los dos', () {
      final proposals = ExportListCrossChecker.propose(list, t73Plan(), portOfCall: 'GTSTC');
      EquivalenceProposal of(EquivalenceKind kind, String code) =>
          proposals.singleWhere((p) => p.kind == kind && p.listCode == code);
      expect(of(EquivalenceKind.type, '40HC').planCode, '45G1');
      expect(of(EquivalenceKind.type, '40HC').evidence, 2);
      expect(of(EquivalenceKind.type, '40HC').origin, EquivalenceOrigin.inferred);
      expect(of(EquivalenceKind.type, '20ST').planCode, '22G1');
      expect(of(EquivalenceKind.type, '40ST').planCode, '42G1');
      expect(of(EquivalenceKind.port, 'COMNG').planCode, 'COSPC');
      expect(of(EquivalenceKind.line, 'LNB').planCode, 'LINB');
      expect(of(EquivalenceKind.port, 'PAMIT').isIdentity, isTrue);

      final reefer = of(EquivalenceKind.type, '40RF');
      expect(reefer.needsUser, isTrue);
      expect(reefer.origin, EquivalenceOrigin.pending);
      expect(reefer.candidates, ['45R1']);
      expect(proposals.where((p) => p.needsUser), [reefer]);

      final table = ExportListCrossChecker.tableOf(proposals);
      expect(table.of(EquivalenceKind.type), {'40HC': '45G1', '20ST': '22G1', '40ST': '42G1'});
      expect(table.of(EquivalenceKind.port), {'COMNG': 'COSPC'});
      expect(table.of(EquivalenceKind.line), {'LNB': 'LINB'});
    });

    test('lo guardado en el dispositivo ya no se pide', () {
      final saved = CodeEquivalences().put(EquivalenceKind.type, '40RF', '45R1');
      final proposals =
          ExportListCrossChecker.propose(list, t73Plan(), portOfCall: 'GTSTC', saved: saved);
      final reefer = proposals.singleWhere((p) => p.listCode == '40RF');
      expect(reefer.planCode, '45R1');
      expect(reefer.origin, EquivalenceOrigin.saved);
      expect(proposals.any((p) => p.needsUser), isFalse);
    });

    test('una guardada que el plan contradice se marca', () {
      final saved = CodeEquivalences().put(EquivalenceKind.type, '40HC', '45R1');
      final proposals =
          ExportListCrossChecker.propose(list, t73Plan(), portOfCall: 'GTSTC', saved: saved);
      final hc = proposals.singleWhere((p) => p.listCode == '40HC');
      expect(hc.planCode, '45R1');
      expect(hc.contradicted, isTrue);
    });

    test('la tabla y el listado normalizado van y vuelven por JSON', () {
      final table = CodeEquivalences()
          .put(EquivalenceKind.type, '40RF', '45R1')
          .put(EquivalenceKind.port, 'COMNG', 'COSPC');
      expect(CodeEquivalences.fromJson(jsonDecode(jsonEncode(table.toJson()))), table);
      final normalized = list.normalized(table);
      final back = ExportList.fromJson(jsonDecode(jsonEncode(normalized.toJson())));
      expect(back, normalized);
      expect(back.byOrder(5)!.type, '45R1');
      expect(back.byOrder(5)!.listType, '40RF');
      expect(back.byOrder(1)!.pod, 'COSPC');
      expect(back.byOrder(2)!.vgmKg, 7266.59);
      expect(back.byOrder(3)!.unNumbers, ['3082', '3077']);
    });
  });

  group('T-73 cruce con el plan', () {
    ExportListCrossCheck check({bool reefer = true}) {
      var proposals = ExportListCrossChecker.propose(list, t73Plan(), portOfCall: 'GTSTC');
      if (reefer) {
        proposals = [
          for (final p in proposals) p.listCode == '40RF' ? p.choose('45R1') : p,
        ];
      }
      return ExportListCrossChecker.crossCheck(
          list.normalized(ExportListCrossChecker.tableOf(proposals)), t73Plan(), 'GTSTC');
    }

    test('llenos por número, vacíos por grupo y lo que no cruza', () {
      final result = check();
      expect(result.matches.map((m) => m.row.order), [1, 2, 3]);
      expect(result.matchesWithDifferences, isEmpty);
      expect(result.fullsNotInPlan.map((r) => r.order), [8]);
      expect(result.planNotInList.map((c) => c.containerId), ['TSTU0000090']);
      expect(result.emptiesWithoutGroup, isEmpty);
      expect(
          result.groups.map((g) => '${g.type} ${g.pod} ${g.line} ${g.empties.length}/${g.planCells}'),
          unorderedEquals(['22G1 PAMIT LNX 1/1', '45R1 PAMIT LNX 1/1', '42G1 PAMIT LNX 1/1']));
      final numbered = result.groups.singleWhere((g) => g.type == '42G1');
      expect(numbered.numberedEmpties.single.containerId, 'TSTU0000061');
      expect(result.clean, isFalse);
    });

    test('un vacío cuyo tipo no se tradujo queda sin grupo', () {
      final result = check(reefer: false);
      expect(result.emptiesWithoutGroup.map((r) => r.order), [5]);
      expect(result.groups.singleWhere((g) => g.type == '45R1').balanced, isFalse);
    });

    test('avisa los números ONU que el plan no trae', () {
      final notices = check().dangerousGoods;
      expect(notices.map((n) => n.row.order), [3]);
      expect(notices.single.message, contains('el plan no trae UN 3082'));
      expect(notices.single.message, contains('clase 9'));
    });

    test('cuenta los VGM que el plan trae distintos', () {
      final result = check();
      expect(result.weightDifferences, 1);
      expect(result.weightDifferenceKg, closeTo(7200 - 7266.59, 1e-9));
    });
  });

  group('T-73 equivalencias persistentes', () {
    late Directory directory;
    late String namespace;

    setUp(() async {
      final root = await Directory('build/t73/test-stores').create(recursive: true);
      directory = await root.createTemp('equivalencias_');
      namespace = 't73_${DateTime.now().microsecondsSinceEpoch}';
    });

    tearDown(() async {
      if (directory.existsSync()) await directory.delete(recursive: true);
    });

    Future<LocalVesselRepositoryImpl> open() async => LocalVesselRepositoryImpl(
        await HiveVesselDataSource.open(directory: directory.path, namespace: namespace));

    test('sobreviven a cerrar y abrir el almacén', () async {
      var repository = await open();
      expect((await repository.getCodeEquivalences()).getOrElse(() => throw StateError('')),
          CodeEquivalences.empty);
      final table = CodeEquivalences()
          .put(EquivalenceKind.type, '40RF', '45R1')
          .put(EquivalenceKind.line, 'LNB', 'LINB');
      expect((await repository.saveCodeEquivalences(table)).isRight(), isTrue);
      await repository.close();

      repository = await open();
      final reopened =
          (await repository.getCodeEquivalences()).getOrElse(() => throw StateError(''));
      expect(reopened, table);
      expect((await repository.getLastConfirmedPortOfCall()).getOrElse(() => 'x'), isNull);
      await repository.close();
    });
  });
}
