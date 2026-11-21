// T-147, entrega 2, parte 2b · O-147-4 y O-147-5.
//
// O-147-4 (10.161): «TRANSBORDOS» y «VACIOS» son de la agencia de arriba, y
// «AGREGADOS» se sigue contando sola (10.50). Un listado guardado por la
// 1.0.2 se lee como entonces hasta que se vuelve a importar.
//
// O-147-5: un grupo sin matrícula con la posición mal formada ya no se
// pierde sin aviso.
//
// Compila también contra `v1.0.2`: lo que la 1.0.2 no tiene se lee a través
// de `dynamic`, y la roja es por comportamiento.
import 'package:baystream/features/vessel/data/services/export_list_parser_service.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/t147_listado_support.dart';
import 'support/t147e2_support.dart';

/// La sección de una fila, o nulo. La 1.0.2 no la tiene.
String? _seccion(ExportListRow fila) =>
    e2Nuevo<String?>(() => (fila as dynamic).section as String?, null);

/// El listado como lo guardó la 1.0.2: la sección, escrita como agencia.
ExportList _guardadoPorLa102(ExportList lista) {
  final json = lista.toJson();
  final filas = [
    for (final fila in (json['rows'] as List).cast<Map<String, dynamic>>())
      {
        for (final entrada in fila.entries)
          if (entrada.key != 'section') entrada.key: entrada.value,
        if (fila['section'] != null) 'agency': fila['section'],
      }
  ];
  return ExportList.fromJson({...json, 'rows': filas});
}

List<String> _posiciones(VesselVoyage plan) => [
      for (final aviso in plan.readNotices)
        if (aviso.kind == BaplieReadNoticeKind.position) ...aviso.details
    ];

void main() {
  group('O-147-4 · Las secciones son de la agencia de arriba', () {
    test('«TRANSBORDOS» y «VACIOS» no pisan la agencia; «AGREGADOS» se cuenta '
        'sola', () {
      final lista = t147Listado();
      expect(lista.issues, isEmpty);
      expect(lista.agencies, {
        'AGENCIA UNO S.A.': 6,
        'AGENCIA DOS S.A.': 1,
        'AGREGADOS': 1,
      }, reason: 'la 1.0.2 contaba cinco agencias');
      expect(_seccion(lista.byOrder(1)!), isNull);
      expect(_seccion(lista.byOrder(3)!), 'TRANSBORDOS');
      for (final orden in [5, 6, 7]) {
        expect(lista.byOrder(orden)!.agency, 'AGENCIA UNO S.A.');
        expect(_seccion(lista.byOrder(orden)!), 'VACIOS');
      }
      // La agencia siguiente cierra la sección de la anterior.
      expect(lista.byOrder(4)!.agency, 'AGENCIA DOS S.A.');
      expect(_seccion(lista.byOrder(4)!), isNull);
      expect(lista.byOrder(8)!.agency, 'AGREGADOS');
    });

    test('la sección sobrevive a guardar, a leer y a traducir', () {
      final lista = t147Listado();
      final leida = ExportList.fromJson(lista.toJson());
      expect(_seccion(leida.byOrder(3)!), 'TRANSBORDOS');
      expect(leida.agencies, lista.agencies);
      final traducida = lista.normalized(CodeEquivalences.empty);
      expect(_seccion(traducida.byOrder(7)!), 'VACIOS');
    });

    test('un título que el lector no conoce se informa, y no cambia ni la '
        'agencia ni la sección de las filas de debajo', () {
      final hoja = t147Hoja();
      final vacios = hoja.indexWhere((f) => f.length == 1 && f[0] == 'VACIOS');
      // Entre el primer vacío y el segundo, una fila que no es un título
      // conocido ni un contenedor.
      hoja.insert(vacios + 2, const ['REFRIGERADOS']);
      final lista = const ExportListParserService()
          .parseGrid(hoja, fileName: 'sintetico-t147.xlsx');
      expect(lista.issues, hasLength(1));
      expect(lista.issues.single.message,
          contains('No es un contenedor ni un separador de agencia'));
      expect(lista.issues.single.message, contains('REFRIGERADOS'));
      expect(lista.rows, hasLength(8));
      for (final orden in [5, 6, 7]) {
        expect(lista.byOrder(orden)!.agency, 'AGENCIA UNO S.A.',
            reason: 'la 1.0.2 las ponía en la agencia «VACIOS»');
        expect(_seccion(lista.byOrder(orden)!), 'VACIOS');
      }
    });

    test('un listado guardado por la 1.0.2 se lee como entonces', () {
      final viejo = _guardadoPorLa102(t147Listado());
      expect(viejo.agencies, {
        'AGENCIA UNO S.A.': 2,
        'TRANSBORDOS': 1,
        'VACIOS': 3,
        'AGENCIA DOS S.A.': 1,
        'AGREGADOS': 1,
      });
      expect(viejo.rows.map(_seccion), everyElement(isNull));
    });

    testWidgets('el resumen dice dos agencias, cada una con sus secciones',
        (tester) async {
      await e2AbrirLaPagina(tester, t147Plan(), t147Listado());
      final cuenta = tester
          .widget<Text>(find.byKey(const ValueKey('export-list-counts')))
          .data!;
      expect(cuenta, startsWith('8 filas en 2 agencias · '),
          reason: 'la 1.0.2 decía «8 filas en 5 agencias»');
      expect(find.text('AGENCIA UNO S.A.: 6 (TRANSBORDOS 1, VACIOS 3)'),
          findsOneWidget);
      expect(find.text('AGENCIA DOS S.A.: 1'), findsOneWidget);
      expect(find.text('AGREGADOS: 1'), findsOneWidget);
      expect(find.text('TRANSBORDOS: 1'), findsNothing);
      expect(find.text('VACIOS: 3'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('con el listado guardado por la 1.0.2, el resumen dice lo de '
        'entonces', (tester) async {
      await e2AbrirLaPagina(
          tester, t147Plan(), _guardadoPorLa102(t147Listado()));
      final cuenta = tester
          .widget<Text>(find.byKey(const ValueKey('export-list-counts')))
          .data!;
      expect(cuenta, startsWith('8 filas en 5 agencias · '));
      expect(find.text('AGENCIA UNO S.A.: 2'), findsOneWidget);
      expect(find.text('TRANSBORDOS: 1'), findsOneWidget);
      expect(find.text('VACIOS: 3'), findsOneWidget);
      expect(find.text('AGREGADOS: 1'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('O-147-5 · El grupo sin matrícula con la posición mal formada', () {
    for (final (nombre, numero) in [('en blanco', ''), ('«NO»', 'NO')]) {
      test('con el número $nombre, se avisa con su posición', () {
        final plan = e2Plan(e2PlanEdi([
          e2Grupo('0100282', t147Matricula(1), '45G1', 'COCTG', 'LNH'),
          e2Grupo('0180082', numero, '45G1', 'COTRB', 'LNH',
              peso: 3800, estado: '4'),
          e2Grupo('01A0282', numero, '45G1', 'COTRB', 'LNH',
              peso: 3800, estado: '4'),
        ]));
        // No es un contenedor ni una celda reservada: no hay dónde ponerla.
        expect(plan.containers, hasLength(1));
        expect(plan.reservedSlots, hasLength(1));
        expect(_posiciones(plan),
            ['Celda reservada sin matrícula: «01A0282»'],
            reason: 'la 1.0.2 la perdía sin decir nada');
      });
    }

    test('la celda reservada bien formada no avisa de nada', () {
      final plan = e2Plan(e2PlanEdi([
        e2Grupo('0100282', t147Matricula(1), '45G1', 'COCTG', 'LNH'),
        e2Reserva('0180082', '45G1', 'COTRB', 'LNH'),
      ]));
      expect(plan.reservedSlots, hasLength(1));
      expect(_posiciones(plan), isEmpty);
    });

    test('el contenedor con la posición mal formada se avisa como siempre',
        () {
      final plan = e2Plan(e2PlanEdi([
        e2Grupo('01A0282', t147Matricula(1), '45G1', 'COCTG', 'LNH'),
      ]));
      expect(_posiciones(plan), ['${t147Matricula(1)}: 01A0282']);
    });
  });
}
