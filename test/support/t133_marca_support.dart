// T-133 · La marca no tapa el número de orden (10.85, hallazgo 7): los datos
// sintéticos de las pruebas y de las capturas de build/t133/.
//
// La carga reproduce lo que el muelle anotó en la bahía 10 del piloto con
// números de orden y líneas inventados para el caso: ocho reservas de 45G1
// a PAMIT, cuatro de la línea CRLY en el nivel 82 y cuatro de ONE en el 84,
// y los vacíos cruzados (los de CRLY en las de ONE y al revés), cada uno con
// su motivo, así que las ocho quedan llenas y en «Revisar»
// (`ConflictKind.otherGroup`). Además, un lleno por subir y uno cancelado.
//
// La descarga trae en la misma bahía uno por bajar en cubierta y otro en
// bodega, uno de paso, uno bajado, uno de paso que se bajó sin re‑estiba
// (en conflicto: «Revisar») y uno cancelado por la oficina.
import 'package:baystream/core/design/design.dart';
import 'package:baystream/core/utils/iso_coordinate_parser.dart';
import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/repositories/session_repository.dart';
import 'package:baystream/features/vessel/domain/services/loading_operation.dart';
import 'package:baystream/features/vessel/presentation/providers/loading_operation_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/loading_plan_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/movement_log_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/plano_providers.dart';
import 'package:baystream/features/vessel/presentation/providers/sync_providers.dart';
import 'package:baystream/features/vessel/presentation/providers/vessel_providers.dart';
import 'package:baystream/features/vessel/presentation/widgets/bay_plan_view.dart';
import 'package:baystream/features/vessel/presentation/widgets/loading_plan_controls.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'local_profile_test_support.dart';
import 't117_oficina_support.dart' show t117CargarFuentes;
import 't91_toolbar_support.dart' show T91MemorySettings;
import 't75_memory_log.dart';
import 't76_fixture.dart' show t76Voyage, t76Slot;

/// La clave del `RepaintBoundary` que envuelve el plano.
const t133Pantalla = ValueKey('t133-pantalla');

const _oficina = MovementAuthor(name: 'Oficina', role: OperatorRole.office);
const _muelle = MovementAuthor(name: 'Muelle', role: OperatorRole.dock);

/// Los vacíos de CRLY que quedaron en las reservas de ONE.
const t133OrdenesCrly = <int>[142, 148, 138, 130];

/// Los vacíos de ONE que quedaron en las reservas de CRLY.
const t133OrdenesOne = <int>[67, 62, 63, 69];

/// Las reservas de CRLY (nivel 82) y de ONE (nivel 84), en orden de fila.
const t133ReservasCrly = <String>['0100182', '0100282', '0100382', '0100482'];
const t133ReservasOne = <String>['0100184', '0100284', '0100384', '0100484'];

/// Cada reserva con el OR del vacío que se le asignó.
final t133Cruce = <String, int>{
  for (var i = 0; i < 4; i++) t133ReservasCrly[i]: t133OrdenesOne[i],
  for (var i = 0; i < 4; i++) t133ReservasOne[i]: t133OrdenesCrly[i],
};

/// El lleno por subir (OR 1) y el cancelado (OR 49).
const t133PorSubir = 'TSTU0000001';
const t133Cancelado = 'TSTU0000049';

String _numero(int orden) => 'TSTU${orden.toString().padLeft(7, '0')}';

ContainerUnit _lleno(String id, String posicion) => ContainerUnit(
    id: 'uuid-$id',
    containerId: id,
    isoSizeType: '45G1',
    status: ContainerStatus.full,
    stowagePosition: IsoCoordinateParser.parse(posicion),
    operatorCode: 'CRLY',
    portOfLoading: 'GTSTC',
    portOfDischarge: 'PAMIT');

ExportListRow _fila(int orden, String linea, {bool vacio = true}) =>
    ExportListRow(
        sheetRow: orden,
        order: orden,
        containerId: _numero(orden),
        status: vacio ? ContainerStatus.empty : ContainerStatus.full,
        listType: '45G1',
        listPod: 'PAMIT',
        listLine: linea,
        tareKg: 3900);

/// El plan de carga de la bahía 10.
final t133PlanDeCarga = t76Voyage([
  _lleno(t133PorSubir, '0100582'),
  _lleno(t133Cancelado, '0100584'),
], slots: [
  for (final p in t133ReservasCrly) t76Slot(p, type: '45G1', line: 'CRLY'),
  for (final p in t133ReservasOne) t76Slot(p, type: '45G1', line: 'ONE'),
]);

final _llegadaVacia = t76Voyage(const []);

final _listado = ExportList(fileName: 'sintetico-t133.xlsx', rows: [
  _fila(1, 'CRLY', vacio: false),
  _fila(49, 'CRLY', vacio: false),
  for (final orden in t133OrdenesCrly) _fila(orden, 'CRLY'),
  for (final orden in t133OrdenesOne) _fila(orden, 'ONE'),
]);

Movement _movimiento(MovementDraft draft, int secuencia, MovementAuthor autor) =>
    Movement(
        id: 't133-$secuencia',
        operationId: draft.operationId,
        type: draft.type,
        target: draft.target,
        payload: draft.payload,
        author: autor,
        deviceId: 'prueba',
        sequence: secuencia,
        createdAt:
            DateTime.utc(2026, 11, 1, 19).add(Duration(minutes: secuencia)));

LoadingOperation _operacion(List<Movement> movimientos) =>
    LoadingOperation.build(
        operationId: 'op',
        arrival: _llegadaVacia,
        loading: t133PlanDeCarga,
        list: _listado,
        movements: movimientos);

/// La operación de carga con los ocho vacíos cruzados y el OR 49 cancelado.
final LoadingOperation t133Carga = () {
  final movimientos = <Movement>[];
  for (final MapEntry(key: posicion, value: orden) in t133Cruce.entries) {
    final fila = _listado.byOrder(orden)!;
    final draft = _operacion(movimientos)
        .draft(fila, posicion, reason: 'Intercambio de vacíos entre líneas');
    movimientos.add(_movimiento(draft, movimientos.length + 1, _muelle));
  }
  movimientos.add(_movimiento(
      MovementDraft.cancelItem('op', 'C:$t133Cancelado', 'Reemplazo'),
      movimientos.length + 1,
      _oficina));
  return _operacion(movimientos);
}();

/// El plano de llegada de la descarga, en la bahía 10.
const _llegada = "UNH+1+BAPLIE:D:95B:UN:SMDG20'"
    "TDT+20+V133+++NV2:172:20+++9000133:146:11:BUQUE PRUEBA'"
    "LOC+5+HNPCR:139:6'LOC+61+GTSTC:139:6'"
    "LOC+147+0100182::5'LOC+9+HNPCR:139:6'LOC+11+GTSTC:139:6'"
    "EQD+CN+TSTU0001001+45G1+++5'"
    "LOC+147+0100282::5'LOC+9+HNPCR:139:6'LOC+11+PAMIT:139:6'"
    "EQD+CN+TSTU0001002+45G1+++5'"
    "LOC+147+0100382::5'LOC+9+HNPCR:139:6'LOC+11+GTSTC:139:6'"
    "EQD+CN+TSTU0001003+45G1+++5'"
    "LOC+147+0100482::5'LOC+9+HNPCR:139:6'LOC+11+GTSTC:139:6'"
    "EQD+CN+TSTU0001004+45G1+++5'"
    "LOC+147+0100184::5'LOC+9+HNPCR:139:6'LOC+11+PAMIT:139:6'"
    "EQD+CN+TSTU0001005+45G1+++5'"
    "LOC+147+0100102::5'LOC+9+HNPCR:139:6'LOC+11+GTSTC:139:6'"
    "EQD+CN+TSTU0001006+45G1+++5'";

/// La descarga: lo que cada contenedor termina marcando.
const t133PorBajar = 'TSTU0001001';
const t133EnConflicto = 'TSTU0001002';
const t133CanceladoEnDescarga = 'TSTU0001003';
const t133Bajado = 'TSTU0001004';
const t133DePaso = 'TSTU0001005';

VesselVoyage t133PlanoDeLlegada() {
  final voyage = BaplieParserService().parse(_llegada);
  return voyage.withGeometry(VesselProfile.proposeFrom(voyage).geometry,
      portOfCall: 'GTSTC');
}

/// Carga las fuentes, fija el tamaño y la letra, y monta el plano con el
/// tema del producto.
Future<void> _montar(
  WidgetTester tester,
  ProviderContainer scope,
  VesselVoyage voyage, {
  required Size tamano,
  required double letra,
  required bool muelle,
  required bool oscuro,
}) async {
  await t117CargarFuentes();
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = tamano;
  addTearDown(tester.view.reset);
  if (letra != 1.0) {
    tester.platformDispatcher.textScaleFactorTestValue = letra;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  }
  await tester.pumpWidget(UncontrolledProviderScope(
    container: scope,
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: BayStreamTema.claro(muelle: muelle),
      darkTheme: BayStreamTema.oscuro(muelle: muelle),
      themeMode: oscuro ? ThemeMode.dark : ThemeMode.light,
      home: Scaffold(
        body: RepaintBoundary(
          key: t133Pantalla,
          child: BayPlanView(voyage: voyage),
        ),
      ),
    ),
  ));
  await tester.pumpAndSettle();
}

/// El plano de carga de la bahía 10 sobre [t133Carga], sin bitácora que lo
/// cambie, en el modo Carga y con la vista pedida.
Future<ProviderContainer> t133PumpCarga(
  WidgetTester tester, {
  Size tamano = const Size(360, 640),
  double letra = 1.0,
  bool muelle = true,
  bool oscuro = false,
  ColorearPor vista = ColorearPor.tipo,
}) async {
  final voyage = t133PlanDeCarga;
  final scope = ProviderContainer(overrides: [
    movementLogRepositoryProvider.overrideWith((ref) async => T75MemoryLog()),
    vesselRepositoryProvider.overrideWithValue(ParserOnlyRepository()),
    localVesselRepositoryProvider.overrideWith((ref) async => T91MemorySettings()),
    operatorProvider.overrideWith((ref) => Stream.value(const Operator(
        uid: 't133-oficina', name: 'Oficina', role: OperatorRole.office))),
    activeOperationProvider.overrideWith((ref) async => Operation(
        id: 'op',
        vesselName: voyage.vessel.name,
        voyageNumber: voyage.voyageNumber,
        portOfCall: 'GTSTC',
        createdAt: DateTime.utc(2026, 11, 1),
        published: true)),
    loadingOperationProvider(voyage)
        .overrideWith((ref) => Stream.value(t133Carga)),
    loadingPlanProgressProvider(voyage)
        .overrideWith((ref) => Stream.value(t133Carga.progress)),
  ]);
  addTearDown(scope.dispose);
  scope.read(bayPlanModeProvider.notifier).elegir(BayPlanMode.loading);
  scope.read(colorearPorProvider.notifier).elegir(BayPlanMode.loading, vista);
  await _montar(tester, scope, voyage,
      tamano: tamano,
      letra: letra,
      muelle: muelle,
      oscuro: oscuro);
  return scope;
}

/// El plano de descarga de la bahía 10, con la bitácora de la descarga, en
/// el modo Descarga y con la vista pedida.
Future<ProviderContainer> t133PumpDescarga(
  WidgetTester tester, {
  Size tamano = const Size(360, 640),
  double letra = 1.0,
  bool muelle = true,
  bool oscuro = false,
  ColorearPor vista = ColorearPor.estado,
}) async {
  final voyage = t133PlanoDeLlegada();
  final log = T75MemoryLog();
  await log.saveOperation(Operation(
      id: 'op-t133',
      vesselName: voyage.vessel.name,
      voyageNumber: voyage.voyageNumber,
      portOfCall: 'GTSTC',
      createdAt: DateTime.utc(2026, 11, 1)));
  await log.append(
      MovementDraft.discharge('op-t133', t133Bajado, '0100482'), _muelle);
  // De paso y bajado sin re‑estiba: queda en conflicto.
  await log.append(
      MovementDraft.discharge('op-t133', t133EnConflicto, '0100282'), _muelle);
  await log.append(
      MovementDraft.cancelItem(
          'op-t133', 'C:$t133CanceladoEnDescarga', 'No baja en esta escala'),
      _oficina);
  final scope = ProviderContainer(overrides: [
    movementLogRepositoryProvider.overrideWith((ref) async => log),
    vesselRepositoryProvider.overrideWithValue(ParserOnlyRepository()),
    localVesselRepositoryProvider.overrideWith((ref) async => T91MemorySettings()),
  ]);
  addTearDown(scope.dispose);
  scope.read(bayPlanModeProvider.notifier).elegir(BayPlanMode.discharge);
  scope.read(colorearPorProvider.notifier).elegir(BayPlanMode.discharge, vista);
  await _montar(tester, scope, voyage,
      tamano: tamano,
      letra: letra,
      muelle: muelle,
      oscuro: oscuro);
  return scope;
}

/// Las celdas de cerca: las marcas con su código, en una densidad y un tema,
/// para las capturas y las pruebas de la pieza. Las dos recién movidas
/// salen de su sitio salvo que el sistema pida reducir el movimiento.
Widget t133Muestrario(BsColoresSemanticos s) => Wrap(
      children: <Widget>[
        BsCelda(
          codigo: 'OR 67',
          marca: BsMarcaDeCelda.revisar,
          categoria: s.hecho,
          etiqueta: 'Reserva 010 01 82 · OR 67 · TSTU0000067, revisar',
          onTap: () {},
        ),
        BsCelda(
          codigo: 'OR 49',
          marca: BsMarcaDeCelda.cancelado,
          categoria: s.pendiente,
          etiqueta: 'OR 49 · TSTU0000049, cancelado',
          onTap: () {},
        ),
        BsCelda(
          codigo: 'GTSTC',
          marca: BsMarcaDeCelda.baja,
          estado: BsEstadoDeCelda.porBajarCubierta,
          etiqueta: 'TSTU 000100 1, 010-01-82, por descargar',
          onTap: () {},
        ),
        BsCelda(
          codigo: 'GTSTC',
          marca: BsMarcaDeCelda.hecho,
          estado: BsEstadoDeCelda.bajado,
          etiqueta: 'TSTU 000100 4, 010-04-82, descargado',
          onTap: () {},
        ),
        const BsCelda(
          codigo: 'PAMIT',
          marca: BsMarcaDeCelda.paso,
          estado: BsEstadoDeCelda.dePaso,
          etiqueta: 'TSTU 000100 5, 010-01-84, de paso',
        ),
        BsCelda(
          codigo: 'PAMIT',
          marca: BsMarcaDeCelda.reestiba,
          categoria: s.categorico('PAMIT'),
          etiqueta: 'TSTU 000100 7, 010-03-84, re‑estiba',
          onTap: () {},
        ),
        BsCelda(
          codigo: 'GTSTC',
          marca: BsMarcaDeCelda.baja,
          estado: BsEstadoDeCelda.recienMovido,
          etiqueta: 'TSTU 000100 1, 010-01-82',
          onTap: () {},
        ),
        BsCelda(
          codigo: 'OR 1',
          marca: BsMarcaDeCelda.sube,
          estado: BsEstadoDeCelda.recienMovido,
          etiqueta: 'OR 1 · TSTU0000001',
          onTap: () {},
        ),
        BsCelda(
          codigo: 'OR 142',
          marca: BsMarcaDeCelda.revisar,
          categoria: s.hecho,
          atenuada: true,
          etiqueta: 'Reserva 010 01 84 · OR 142 · TSTU0000142, revisar',
          onTap: () {},
        ),
      ],
    );
