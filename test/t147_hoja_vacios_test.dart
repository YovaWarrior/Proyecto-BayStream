// T-147 · R1 (10.151, hallazgo 1): la hoja «Vacíos del listado» no se traba.
//
// La hoja ofrece lo mismo y en el mismo orden que en la 1.0.1; lo que cambia
// es el trabajo: la ocupación se calcula una vez por estado y la hoja decide
// una sola vez si la celda admite un vacío, no una vez por fila. Ninguna
// prueba mira el reloj: la de escala cuenta lecturas.
//
// Solo datos sintéticos, con la forma del caso A09: cientos de reservas en
// varios grupos y cientos de vacíos, más que celdas en algún grupo.
import 'package:baystream/core/utils/iso_coordinate_parser.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/services/loading_operation.dart';
import 'package:baystream/features/vessel/presentation/providers/loading_operation_provider.dart';
import 'package:baystream/features/vessel/presentation/widgets/loading_controls.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/t76_fixture.dart';

/// Una celda reservada que cuenta cuántas veces se le lee el tipo: cada
/// comparación de grupo y cada igualdad campo por campo pasa por ahí.
class _CeldaContada extends ReservedSlot {
  static int lecturas = 0;

  const _CeldaContada(
      {required super.stowagePosition,
      super.isoSizeType,
      super.portOfDischarge,
      super.operatorCode})
      : super(
            status: ContainerStatus.empty,
            portOfLoading: 'GTSTC',
            nominalWeight: 2100);

  @override
  String? get isoSizeType {
    lecturas++;
    return super.isoSizeType;
  }
}

const _grupos = [
  (tipo: '22G1', puerto: 'COTRB', linea: 'LNH'),
  (tipo: '22G1', puerto: 'JMKIN', linea: 'LNJ'),
  (tipo: '22U1', puerto: 'JMKIN', linea: 'LNH'),
];

String _posicion(int i) {
  // Bahías impares (20 pies) 1 a 11, diez filas y cinco niveles de cubierta.
  final bahia = 1 + 2 * (i ~/ 50);
  final fila = 1 + (i % 50) ~/ 5;
  final nivel = 82 + 2 * (i % 5);
  return '${bahia.toString().padLeft(3, '0')}'
      '${fila.toString().padLeft(2, '0')}$nivel';
}

/// [reservas] celdas reservadas y [vacios] vacíos del listado, repartidos en
/// tres grupos con más vacíos que celdas en el primero, como en el caso.
({VesselVoyage plan, ExportList lista}) _caso(
    {required int reservas, required int vacios}) {
  final celdas = [
    for (var i = 0; i < reservas; i++)
      _CeldaContada(
          stowagePosition: IsoCoordinateParser.parse(_posicion(i)),
          isoSizeType: _grupos[i % 3].tipo,
          portOfDischarge: _grupos[i % 3].puerto,
          operatorCode: _grupos[i % 3].linea)
  ];
  final filas = [
    for (var i = 0; i < vacios; i++)
      ExportListRow(
          sheetRow: i + 6,
          order: i + 1,
          containerId: 'TSTU${(i + 1).toString().padLeft(7, '0')}',
          status: ContainerStatus.empty,
          // Dos de cada cinco van al primer grupo.
          listType: _grupos[i % 5 < 2 ? 0 : 1 + i % 2].tipo,
          listPod: _grupos[i % 5 < 2 ? 0 : 1 + i % 2].puerto,
          listLine: _grupos[i % 5 < 2 ? 0 : 1 + i % 2].linea,
          tareKg: 2100.0 + i)
  ];
  return (
    plan: t76Voyage(const [], slots: celdas),
    lista: ExportList(fileName: 'sintetico-t147.xlsx', rows: filas),
  );
}

/// Lo que la hoja de la 1.0.1 ofrece para [celda], con su misma expresión
/// (`_LoadingPickerState.build` en `37be8a5`): es la referencia.
List<int> _ordenesDeLa101(LoadingOperation data, ReservedSlot celda,
    [String consulta = '']) {
  bool suGrupo(ExportListRow row) =>
      celda.isoSizeType == row.type &&
      celda.portOfDischarge == row.pod &&
      celda.operatorCode == row.line;
  final rows = data
      .search(consulta, empties: true)
      .where((row) => data
          .candidateSlots(row, otherGroups: true)
          .any((s) => s.key == celda.key))
      .toList()
    ..sort((a, b) => (suGrupo(a) ? 0 : 1).compareTo(suGrupo(b) ? 0 : 1));
  return [for (final row in rows) row.order];
}

/// Abre la hoja como lo hace el plano al tocar una celda reservada
/// (`chooseLoadingRow` con la celda), en una pantalla tan alta que todas sus
/// filas quedan construidas.
Future<void> _abrirLaHoja(WidgetTester tester, LoadingOperation data,
    VesselVoyage plan, ReservedSlot celda,
    {double alto = 60000}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = Size(400, alto);
  addTearDown(tester.view.reset);
  final scope = ProviderContainer(overrides: [
    loadingOperationProvider(plan).overrideWith((ref) => Stream.value(data)),
  ]);
  addTearDown(scope.dispose);
  await tester.pumpWidget(UncontrolledProviderScope(
      container: scope,
      child: MaterialApp(
          home: Scaffold(
              body: Consumer(
                  builder: (context, ref, _) => TextButton(
                      key: const ValueKey('abrir'),
                      onPressed: () => chooseLoadingRow(context, ref, plan,
                          empties: true, slot: celda),
                      child: const Text('abrir')))))));
  await tester.tap(find.byKey(const ValueKey('abrir')));
  await tester.pumpAndSettle();
}

/// Los OR de las filas de la hoja, de arriba abajo.
List<int> _ordenesEnPantalla(WidgetTester tester) {
  final filas = tester
      .widgetList<ListTile>(find.byWidgetPredicate((w) =>
          w is ListTile &&
          w.key is ValueKey<String> &&
          (w.key! as ValueKey<String>).value.startsWith('loading-or-')))
      .toList();
  final conAltura = [
    for (final fila in filas)
      (
        orden: int.parse((fila.key! as ValueKey<String>).value.substring(11)),
        y: tester.getTopLeft(find.byKey(fila.key!)).dy
      )
  ]..sort((a, b) => a.y.compareTo(b.y));
  return [for (final fila in conAltura) fila.orden];
}

/// Las celdas que `candidateSlots` ofrecía en la 1.0.1 a [row], con sus
/// mismos dos recorridos y su igualdad campo por campo, sobre el estado
/// vigente: es la referencia para comprobar que el diálogo ofrece lo mismo.
List<String> _celdasDeLa101(LoadingOperation data, ExportListRow row,
    {required bool otherGroups, int? selectedBay}) {
  final state = data.state;
  final disponible = state['C:${row.containerId}']?.state !=
          ItemState.cancelled &&
      !state.items.values.any((s) =>
          s.state == ItemState.moved &&
          (s.key == 'C:${row.containerId}' ||
              s.assignedContainer == row.containerId));
  if (!row.isEmpty || data.numbered(row) != null || !disponible) return [];
  int orden(ReservedSlot a, ReservedSlot b) {
    final grupo = selectedBay == null ? null : data.displayBay(selectedBay);
    final aqui = data.displayBay(a.stowagePosition.bay) == grupo;
    final alla = data.displayBay(b.stowagePosition.bay) == grupo;
    if (aqui != alla) return aqui ? -1 : 1;
    return a.stowagePosition.toIsoCode().compareTo(b.stowagePosition.toIsoCode());
  }

  bool suGrupo(ReservedSlot slot) =>
      slot.isoSizeType == row.type &&
      slot.portOfDischarge == row.pod &&
      slot.operatorCode == row.line;
  final libres = [
    for (final item in data.plan.loading.values)
      if (item.role == PlanRole.load &&
          item.reservedSlot != null &&
          suGrupo(item.reservedSlot!) &&
          state[item.key]?.state == ItemState.planned &&
          !state.occupancy.containsKey(item.plannedPosition))
        item.reservedSlot!
  ]..sort(orden);
  final esperan = <ReservedSlot>[];
  final otras = <ReservedSlot>[];
  for (final item in data.plan.loading.values) {
    final slot = item.reservedSlot;
    if (slot == null ||
        item.role != PlanRole.load ||
        libres.contains(slot) ||
        state[item.key]?.state != ItemState.planned) {
      continue;
    }
    final ocupante = state.occupancy[item.plannedPosition];
    final baja = ocupante == null ||
        (state['C:$ocupante']?.role == PlanRole.discharge &&
            state['C:$ocupante']?.state == ItemState.planned);
    if (!baja) continue;
    if (suGrupo(slot)) {
      esperan.add(slot);
    } else if (otherGroups) {
      otras.add(slot);
    }
  }
  return [
    for (final slot in [
      ...libres,
      ...esperan..sort(orden),
      ...otras..sort(orden)
    ])
      slot.stowagePosition.toIsoCode()
  ];
}

void main() {
  test('R1 · la ocupación se calcula una vez por estado', () {
    final caso = _caso(reservas: 12, vacios: 12);
    final data = LoadingOperation.build(
        operationId: 'op', loading: caso.plan, list: caso.lista);
    final primera = data.state.occupancy;
    expect(identical(data.state.occupancy, primera), isTrue,
        reason: 'Cada lectura de `occupancy` rehace el mapa completo: es lo '
            'que trababa la hoja con 271 celdas (10.151, hallazgo 1).');
    // Con un movimiento, el estado nuevo trae su propia ocupación.
    final fila = caso.lista.rows.first;
    final celda = data.slots(fila).first.stowagePosition.toIsoCode();
    final despues = LoadingOperation.build(
        operationId: 'op',
        loading: caso.plan,
        list: caso.lista,
        movements: [t76Movement(data.draft(fila, celda), 1)]);
    expect(primera, isEmpty);
    expect(despues.state.occupancy, {celda: fila.containerId});
    expect(identical(despues.state.occupancy, despues.state.occupancy), isTrue);
  });

  testWidgets(
      'R1 · escala: con 300 vacíos y 300 reservas, abrir la hoja desde una '
      'celda no recorre las reservas por cada fila', (tester) async {
    const reservas = 300;
    const vacios = 300;
    final caso = _caso(reservas: reservas, vacios: vacios);
    final data = LoadingOperation.build(
        operationId: 'op', loading: caso.plan, list: caso.lista);
    final celda = caso.plan.reservedSlots.first;
    final esperados = _ordenesDeLa101(data, celda);
    expect(esperados, hasLength(vacios));

    _CeldaContada.lecturas = 0;
    await _abrirLaHoja(tester, data, caso.plan, celda);
    final lecturas = _CeldaContada.lecturas;

    expect(find.text('Vacíos del listado'), findsOneWidget);
    expect(_ordenesEnPantalla(tester), esperados,
        reason: 'La hoja ofrece lo mismo y en el mismo orden que la 1.0.1.');
    // En la 1.0.1 cada fila recorría todas las reservas: 300 × 300 = 90 000
    // lecturas como piso, más las comparaciones campo por campo. Decidir una
    // vez por hoja deja un trabajo proporcional a las filas (ordenarlas y
    // rotularlas), muy por debajo del producto.
    expect(lecturas, lessThan(40 * (reservas + vacios)),
        reason: 'Leyó $lecturas veces el grupo de una celda para abrir una '
            'hoja de $vacios vacíos sobre $reservas reservas.');
  });

  testWidgets(
      'R1 · escala: al abrirse el teclado y al escribir, la hoja tampoco '
      'recorre las reservas por cada fila', (tester) async {
    const reservas = 300;
    const vacios = 300;
    final caso = _caso(reservas: reservas, vacios: vacios);
    final data = LoadingOperation.build(
        operationId: 'op', loading: caso.plan, list: caso.lista);
    final celda = caso.plan.reservedSlots.first;
    await _abrirLaHoja(tester, data, caso.plan, celda);

    // El teclado: cambia el alto útil y la hoja se vuelve a armar.
    _CeldaContada.lecturas = 0;
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpAndSettle();
    expect(_CeldaContada.lecturas, lessThan(40 * (reservas + vacios)),
        reason: 'Al abrirse el teclado.');
    expect(_ordenesEnPantalla(tester), _ordenesDeLa101(data, celda));

    // Una tecla en «OR / últimos dígitos».
    _CeldaContada.lecturas = 0;
    await tester.enterText(find.byType(TextField), '7');
    await tester.pumpAndSettle();
    expect(_CeldaContada.lecturas, lessThan(40 * (reservas + vacios)),
        reason: 'Al escribir una tecla.');
    final conSiete = _ordenesDeLa101(data, celda, '7');
    expect(conSiete, isNotEmpty);
    expect(_ordenesEnPantalla(tester), conSiete);
  });

  group('R1 · la hoja ofrece lo mismo que la 1.0.1 en cada estado', () {
    // El plan y la llegada de T-76: una reserva libre de su grupo (0030882),
    // una que ocupa un contenedor que baja aquí (0030482, INCOMING2) y
    // reservas de otros grupos (otro tipo, otro puerto, otra línea).
    final vacios = ExportList(fileName: 'sintetico-t147.xlsx', rows: [
      ...t76List.rows,
      t76Row(14, 'EMPTY0000014', empty: true),
      ExportListRow(
          sheetRow: 15,
          order: 15,
          containerId: 'EMPTY0000015',
          status: ContainerStatus.empty,
          listType: '45G1',
          listPod: 'PAMIT',
          listLine: 'TEST',
          tareKg: 3900),
    ]);
    LoadingOperation operacion(List<Movement> movimientos) =>
        LoadingOperation.build(
            operationId: 'op',
            arrival: t76Arrival,
            loading: t76Loading,
            list: vacios,
            movements: movimientos);
    ReservedSlot celda(String posicion) => t76Loading.reservedSlots
        .firstWhere((s) => s.stowagePosition.toIsoCode() == posicion);

    final asignado = t76Movement(
        MovementDraft.assignEmpty('op', '0030882', 'EMPTY0000012', 2185,
            order: 12),
        1);
    final casos = <(String, List<Movement>, String)>[
      ('una celda libre de su grupo', const [], '0030882'),
      ('una celda de otro grupo (otro tipo)', const [], '0030182'),
      ('una celda de otro grupo (otro puerto)', const [], '0030382'),
      ('una celda que ocupa un contenedor que baja aquí', const [], '0030482'),
      ('otra celda, con un vacío ya asignado', [asignado], '0050282'),
      ('una celda que ya tiene su vacío', [asignado], '0030882'),
      (
        'una celda cancelada por la oficina',
        [t76Movement(MovementDraft.cancelItem('op', 'R:0030882', 'No va'), 1)],
        '0030882'
      ),
      (
        'una celda con la descarga de su ocupante ya marcada',
        [t76Movement(MovementDraft.discharge('op', 'INCOMING2', '0030482'), 1)],
        '0030482'
      ),
      (
        'una celda cuyo ocupante se quedó a bordo (cancelaron su descarga)',
        [
          t76Movement(
              MovementDraft.cancelItem('op', 'C:INCOMING2', 'No baja'), 1)
        ],
        '0030482'
      ),
    ];
    for (final (nombre, movimientos, _) in casos) {
      test('el diálogo «Asignar vacío» ofrece las mismas celdas: $nombre', () {
        final data = operacion(movimientos);
        for (final fila in vacios.rows) {
          for (final otros in [false, true]) {
            for (final bahia in [null, 3, 5]) {
              expect(
                  [
                    for (final slot in data.candidateSlots(fila,
                        otherGroups: otros, selectedBay: bahia))
                      slot.stowagePosition.toIsoCode()
                  ],
                  _celdasDeLa101(data, fila,
                      otherGroups: otros, selectedBay: bahia),
                  reason: 'OR ${fila.order}, otros grupos: $otros, '
                      'bahía: $bahia');
            }
          }
          expect(
              data.available(fila),
              data.state['C:${fila.containerId}']?.state !=
                      ItemState.cancelled &&
                  !data.state.items.values.any((s) =>
                      s.state == ItemState.moved &&
                      (s.key == 'C:${fila.containerId}' ||
                          s.assignedContainer == fila.containerId)));
        }
      });
    }

    test('«Corregir carga» de un vacío: el estado sin la carga corregida se '
        'deriva una vez y da lo mismo cada vez', () {
      final otro = t76Movement(
          MovementDraft.assignEmpty('op', '0050282', 'EMPTY0000013', 2300,
              order: 13),
          2);
      final data = operacion([asignado, otro]);
      final doce = vacios.byOrder(12)!;
      final trece = vacios.byOrder(13)!;
      // Sin corregir, los dos están operados; corrigiendo uno, ese vuelve a
      // estar disponible, con su celda entre las libres, y el otro no.
      expect(data.available(doce), isFalse);
      expect(data.available(trece), isFalse);
      for (var vuelta = 0; vuelta < 3; vuelta++) {
        expect(data.available(doce, correcting: asignado), isTrue);
        expect(data.available(trece, correcting: asignado), isFalse);
        expect(
            data
                .candidateSlots(doce, correcting: asignado)
                .map((s) => s.stowagePosition.toIsoCode()),
            contains('0030882'));
        // Otra corrección no hereda el estado de la anterior.
        expect(data.available(trece, correcting: otro), isTrue);
        expect(data.available(doce, correcting: otro), isFalse);
        expect(
            data
                .candidateSlots(trece, correcting: otro)
                .map((s) => s.stowagePosition.toIsoCode()),
            contains('0050282'));
        expect(data.available(doce), isFalse);
      }
      // Lo que «Corregir carga» ofrece como «OR del vacío».
      expect(
          vacios.empties
              .where((r) =>
                  data.available(r, correcting: asignado) &&
                  data.numbered(r) == null)
              .map((r) => r.order),
          [12, 14, 15]);
    });

    for (final (nombre, movimientos, posicion) in casos) {
      testWidgets(nombre, (tester) async {
        final data = operacion(movimientos);
        final esperados = _ordenesDeLa101(data, celda(posicion));
        await _abrirLaHoja(tester, data, t76Loading, celda(posicion),
            alto: 4000);
        expect(_ordenesEnPantalla(tester), esperados);
        expect(find.text('No hay coincidencias disponibles.'),
            esperados.isEmpty ? findsOneWidget : findsNothing);
        final otros = find.textContaining('Otro grupo: pide motivo');
        final deOtroGrupo = [
          for (final orden in esperados)
            if (vacios.byOrder(orden)!.type != celda(posicion).isoSizeType ||
                vacios.byOrder(orden)!.pod != celda(posicion).portOfDischarge ||
                vacios.byOrder(orden)!.line != celda(posicion).operatorCode)
              orden
        ];
        expect(otros, findsNWidgets(deOtroGrupo.length));
      });
    }
  });
}
