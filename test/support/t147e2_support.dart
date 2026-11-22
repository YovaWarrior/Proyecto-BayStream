// T-147, entrega 2, parte 2a · El caso sintético de las pruebas de la 2a, con
// las formas del caso A09 (10.151, 10.156 y 10.160): un listado con notas de
// cancelación en MARCHAMO y en CONTENIDO, un tipo del listado que el plan
// reparte en dos códigos ISO, celdas reservadas de códigos sin dueño, POT y
// POD distintos, y un plan con contenedores de paso que traen `LOC+83`.
// Todo inventado.
//
// Este archivo y las pruebas que lo usan compilan también contra `v1.0.2`,
// para que la roja de cada regla sea por comportamiento: lo que la 1.0.2 no
// tiene se llama a través de `dynamic`.
import 'package:baystream/core/errors/failures.dart';
import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/data/services/export_list_parser_service.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/repositories/export_list_repository.dart';
import 'package:baystream/features/vessel/domain/repositories/local_vessel_repository.dart';
import 'package:baystream/features/vessel/domain/repositories/movement_log_repository.dart';
import 'package:baystream/features/vessel/domain/services/export_list_cross_checker.dart';
import 'package:baystream/features/vessel/domain/services/loading_operation.dart';
import 'package:baystream/features/vessel/presentation/pages/export_list_import_page.dart';
import 'package:baystream/features/vessel/presentation/providers/export_list_providers.dart';
import 'package:baystream/features/vessel/presentation/providers/vessel_providers.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 't147_listado_support.dart';

const e2Escala = 'GTSTC';

/// Un grupo del plan. Con [numero] vacío es una celda reservada. [destino]
/// es su `LOC+83`, y [origen], su `LOC+76`.
String e2Grupo(String posicion, String numero, String tipo, String descarga,
        String linea,
        {String carga = e2Escala,
        int peso = 20000,
        String estado = '5',
        String? destino,
        String? origen}) =>
    "LOC+147+$posicion::5'MEA+VGM++KGM:$peso'"
    "LOC+9+$carga:139:6'LOC+11+$descarga:139:6'"
    "${destino == null ? '' : "LOC+83+$destino:139:6'"}"
    "${origen == null ? '' : "LOC+76+$origen:139:6'"}"
    "RFF+BM:1'"
    "EQD+CN+$numero+$tipo+++$estado'NAD+CA+$linea:172:20'";

String e2Reserva(String posicion, String tipo, String descarga, String linea) =>
    e2Grupo(posicion, '', tipo, descarga, linea, peso: 3800, estado: '4');

String e2PlanEdi(Iterable<String> grupos) =>
    "UNB+UNOA:2+EMISOR+RECEPTOR+261120:2200+REF147E2'"
    "UNH+M147E2+BAPLIE:D:95B:UN:SMDG20'BGM++DOC147E2+9'"
    "DTM+137:2611202200:201'"
    "TDT+20+VIAJE147E+++LNH:172:20+++9000148:146:11:BUQUE SINTETICO DOS'"
    "LOC+5+GTSTC:139:6'LOC+61+COTRB:139:6'RFF+VON:VIAJE147E'"
    '${grupos.join()}'
    "UNT+1+M147E2'UNZ+1+REF147E2'";

VesselVoyage e2Plan(String edi) =>
    BaplieParserService().parse(edi).copyWith(portOfCall: e2Escala);

const e2Encabezado = <Object?>[
  'OR', 'CONTENEDOR', 'TIPO', 'POT', 'POD', 'TARA', 'PESO NETO', 'PESO VGM',
  'REEFER TEMP', 'ORIG', 'F', 'E', 'CONTENIDO ', 'HORA', 'MARCHAMO', 'OPR',
];

/// Una fila de la hoja. [nota] va en MARCHAMO y [contenido], en CONTENIDO.
List<Object?> e2Fila(int orden, int numero, String tipo, String pot,
        String linea,
        {String? pod,
        bool vacio = false,
        String? nota,
        String? contenido}) =>
    [
      orden, t147Matricula(numero), tipo, pot, pod ?? pot,
      vacio ? 3900 : 3800, null, vacio ? null : 20000.4, null, 'GT',
      vacio ? null : 'X', vacio ? 'X' : null,
      contenido ?? (vacio ? 'VACIO EN PATIO' : 'GENERAL CARGO'), null, nota,
      linea,
    ];

ExportList e2Listado(List<List<Object?>> filas) =>
    const ExportListParserService().parseGrid([
      const ['BUQUE SINTETICO DOS V. VIAJE147E'],
      e2Encabezado,
      const ['AGENCIA UNO S.A. CODIGO 00-000-001'],
      ...filas,
    ], fileName: 'sintetico-t147e2.xlsx');

/// P1 · El plan de las pruebas de las filas canceladas: tres llenos que
/// suben en la escala (el tercero, cancelado en el listado), tres celdas
/// reservadas y uno de paso.
final e2EdiDeLasCanceladas = e2PlanEdi([
  e2Grupo('0100282', t147Matricula(1), '45G1', 'COCTG', 'LNH'),
  e2Grupo('0100482', t147Matricula(2), '45G1', 'COCTG', 'LNH'),
  // El plan todavía lo carga, y el listado lo cancela.
  e2Grupo('0100682', t147Matricula(3), '45G1', 'COCTG', 'LNH'),
  e2Reserva('0180082', '45G1', 'COTRB', 'LNH'),
  e2Reserva('0180282', '45G1', 'COTRB', 'LNH'),
  e2Reserva('0190682', '22G1', 'JMKIN', 'LNJ'),
  e2Grupo('0300282', t147Matricula(90), '45G1', 'USHOU', 'LNK', carga: 'HNPCR'),
]);

/// P1 · Su listado, con las notas de la agencia en MARCHAMO y en CONTENIDO.
List<List<Object?>> e2HojaDeLasCanceladas({String? notaDelOr1}) => [
      e2Fila(1, 1, '40HC', 'COCTG', 'LGH', nota: notaDelOr1),
      e2Fila(2, 2, '40HC', 'COCTG', 'LGH', nota: 'AB123456'),
      e2Fila(3, 3, '40HC', 'COCTG', 'LGH', nota: 'ROLEADO - CANCEL'),
      e2Fila(4, 20, '40HC', 'COCTG', 'LGH', nota: 'YA EMBARCADO -CANCEL'),
      e2Fila(5, 21, '40HC', 'COCTG', 'LGH', nota: 'cancelado'),
      e2Fila(6, 22, '40XX', 'COCTG', 'LGH',
          contenido: 'Carga general cancelled'),
      e2Fila(7, 23, '40HC', 'COCTG', 'LGH', nota: 'ROLEADO'),
      e2Fila(8, 24, '40HC', 'COCTG', 'LGH', nota: 'Ya  embarcada'),
      e2Fila(9, 11, '40HC', 'COTRB', 'LGH', vacio: true),
      e2Fila(10, 12, '40HC', 'COTRB', 'LGH', vacio: true),
      e2Fila(11, 13, '40HC', 'COTRB', 'LGH', vacio: true, nota: 'CANCELADO'),
      e2Fila(12, 14, '20ST', 'JMKIN', 'LNJ', vacio: true, nota: 'PENDIENTE'),
      e2Fila(14, 25, '40HC', 'COCTG', 'LGH',
          nota: 'Reemplazadas - Canceladas'),
      e2Fila(15, 26, '40HC', 'COCTG', 'LGH', nota: 'CANCELACION'),
    ];

/// Las propuestas, con lo que elige la persona: `{'20ST': '22G1'}`.
List<EquivalenceProposal> e2Proponer(ExportList lista, VesselVoyage plan,
        {Map<String, String> tipos = const {}, CodeEquivalences? guardado}) =>
    [
      for (final p in ExportListCrossChecker.propose(lista, plan,
          portOfCall: e2Escala, saved: guardado))
        p.kind == EquivalenceKind.type &&
                p.needsUser &&
                tipos.containsKey(p.listCode)
            ? p.choose(tipos[p.listCode]!)
            : p
    ];

/// «También llena» de una propuesta. La 1.0.2 no lo tiene: ahí es vacío, y
/// las pruebas que lo esperan fallan por lo que la pantalla y el cruce dan.
List<String> e2Tambien(EquivalenceProposal p) {
  try {
    return ((p as dynamic).also as List).cast<String>();
  } on NoSuchMethodError {
    return const [];
  }
}

/// «También llena» como va en el listado: cada código de más, con el
/// principal de su tipo (`ExportListCrossChecker.familiesOf`).
Map<String, String> e2Familias(List<EquivalenceProposal> propuestas) => {
      for (final p in propuestas)
        if (p.kind == EquivalenceKind.type && p.planCode != null)
          for (final codigo in e2Tambien(p)) codigo: p.planCode!,
    };

/// El listado traducido con esas propuestas, como lo deja la importación.
ExportList e2Normalizar(
    ExportList lista, List<EquivalenceProposal> propuestas) {
  final tabla = ExportListCrossChecker.tableOf(propuestas);
  final familias = e2Familias(propuestas);
  if (familias.isEmpty) return lista.normalized(tabla);
  return (lista as dynamic).normalized(tabla, typeFamilies: familias)
      as ExportList;
}

/// Un miembro que la 1.0.2 no tiene, o [siFalta].
T e2Nuevo<T>(T Function() leer, T siFalta) {
  try {
    return leer();
  } on NoSuchMethodError {
    return siFalta;
  }
}

EquivalenceProposal e2De(Iterable<EquivalenceProposal> propuestas,
        EquivalenceKind kind, String codigo) =>
    propuestas.firstWhere((p) => p.kind == kind && p.listCode == codigo);

LoadingOperation e2Operacion(VesselVoyage plan, ExportList lista,
        [List<Movement> movimientos = const []]) =>
    LoadingOperation.build(
        operationId: 'e2', loading: plan, list: lista, movements: movimientos);

Movement e2Movimiento(MovementDraft draft, int n) => Movement(
    id: 'm$n',
    operationId: draft.operationId,
    type: draft.type,
    target: draft.target,
    payload: draft.payload,
    author: const MovementAuthor(name: 'Muelle', role: OperatorRole.dock),
    deviceId: 'equipo-e2',
    sequence: n,
    createdAt: DateTime.utc(2026, 11, 20, 12).add(Duration(minutes: n)));

Operation e2OperacionGuardada(String edi, VesselVoyage plan) => Operation(
      id: 'e2',
      vesselName: plan.vessel.name,
      voyageNumber: plan.voyageNumber,
      portOfCall: e2Escala,
      createdAt: DateTime.utc(2026, 11, 20),
      sources: [
        OperationSource(
            kind: OperationSourceKind.loadingBaplie,
            fileName: 'sintetico-t147e2.edi',
            content: edi),
      ],
    );

/// El grupo de segmentos de [contenedor] en un BAPLIE, sin apóstrofos.
List<String> e2GrupoDe(String texto, String contenedor) {
  final segmentos = [
    for (final s in texto.split("'"))
      if (s.trim().isNotEmpty) s.trim()
  ];
  final i = segmentos.indexWhere((s) => s.startsWith('EQD+CN+$contenedor+'));
  if (i < 0) return const [];
  var desde = i;
  while (desde > 0 && !segmentos[desde].startsWith('LOC+147+')) {
    desde--;
  }
  var hasta = i;
  while (hasta + 1 < segmentos.length &&
      !segmentos[hasta + 1].startsWith('LOC+147+') &&
      !segmentos[hasta + 1].startsWith('UNT+')) {
    hasta++;
  }
  return segmentos.sublist(desde, hasta + 1);
}

/// El almacén del dispositivo, en memoria: solo la tabla de equivalencias.
class E2Equipo implements LocalVesselRepository {
  CodeEquivalences tabla;
  E2Equipo([CodeEquivalences? tabla]) : tabla = tabla ?? CodeEquivalences.empty;

  @override
  Future<Either<Failure, CodeEquivalences>> getCodeEquivalences() async =>
      Right(tabla);

  @override
  Future<Either<Failure, void>> saveCodeEquivalences(
      CodeEquivalences equivalences) async {
    tabla = equivalences;
    return const Right(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// La bitácora del equipo, en memoria: solo sus operaciones, para que la
/// importación encuentre la de la escala y guarde en ella el listado.
class E2Bitacora implements MovementLogRepository {
  final List<Operation> operaciones;
  E2Bitacora([Iterable<Operation> operaciones = const []])
      : operaciones = [...operaciones];

  @override
  Future<Either<Failure, List<Operation>>> getOperations() async =>
      Right([...operaciones]);

  @override
  Future<Either<Failure, void>> saveOperation(Operation operation) async {
    operaciones
      ..removeWhere((o) => o.id == operation.id)
      ..add(operation);
    return const Right(null);
  }

  @override
  Future<Either<Failure, List<MovementRecord>>> records(
          String operationId) async =>
      const Right([]);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Plan extends VoyageNotifier {
  final VesselVoyage plan;
  _Plan(this.plan);

  @override
  AsyncValue<VesselVoyage?> build() => AsyncValue.data(plan);
}

class _Listados implements ExportListRepository {
  final ExportList lista;
  const _Listados(this.lista);

  @override
  Future<Either<Failure, ExportList>> parseExportList(List<int> bytes,
          {String fileName = 'listado.xlsx'}) async =>
      Right(lista);
}

/// Abre «Listado de la agencia» con [plan] a la vista y [lista] recién leída,
/// en una pantalla tan alta que todo queda construido.
Future<ProviderContainer> e2AbrirLaPagina(
    WidgetTester tester, VesselVoyage plan, ExportList lista,
    {E2Equipo? equipo,
    E2Bitacora? bitacora,
    double ancho = 360,
    bool leer = true}) async {
  tester.view.physicalSize = Size(ancho, 9000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final local = equipo ?? E2Equipo();
  final log = bitacora ?? E2Bitacora();
  await tester.pumpWidget(ProviderScope(overrides: [
    voyageNotifierProvider.overrideWith(() => _Plan(plan)),
    localVesselRepositoryProvider.overrideWith((ref) async => local),
    movementLogRepositoryProvider.overrideWith((ref) async => log),
    exportListRepositoryProvider.overrideWithValue(_Listados(lista)),
  ], child: const MaterialApp(home: ExportListImportPage())));
  await tester.pump();
  final scope = ProviderScope.containerOf(
      tester.element(find.byType(ExportListImportPage)));
  if (leer) {
    await scope
        .read(exportListImportProvider.notifier)
        .loadBytes(const [1], fileName: 'sintetico-t147e2.xlsx');
  }
  await tester.pumpAndSettle();
  return scope;
}

/// Los textos a la vista que casan con [patron].
List<String> e2Textos(WidgetTester tester, Pattern patron) => [
      for (final w in tester.widgetList<Text>(find.byType(Text)))
        if ((w.data ?? w.textSpan?.toPlainText() ?? '').contains(patron))
          w.data ?? w.textSpan!.toPlainText()
    ];
