// T-147, entrega 2, parte 2b · P8 a): abrir otra operación después de cerrar
// una del mismo buque, viaje y puerto (10.160, D14), también con el mismo
// archivo.
//
// La cerrada se sigue viendo, solo para mirar. Con otro archivo nace una
// operación nueva; con el mismo, «Nube y cuenta» ofrece «Empezar una operación
// nueva» con sus planos.
//
// Compila también contra `v1.0.2`, para que la roja sea por comportamiento:
// las pruebas usan `find` y `save`, que ya existían, y la pantalla.
import 'package:baystream/core/errors/failures.dart';
import 'package:baystream/features/vessel/data/repositories/local_only_operation_sync.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/repositories/session_repository.dart';
import 'package:baystream/features/vessel/domain/services/operation_sources.dart';
import 'package:baystream/features/vessel/presentation/pages/cloud_page.dart';
import 'package:baystream/features/vessel/presentation/providers/movement_log_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/sync_providers.dart';
import 'package:baystream/features/vessel/presentation/providers/vessel_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/t147_listado_support.dart';
import 'support/t147e2_support.dart';

/// El plan de carga con que se publicó y se cerró la operación.
final _cargaEdi = e2PlanEdi([
  e2Grupo('0180182', t147Matricula(1), '45G1', 'COCTG', 'LNH'),
  e2Grupo('0180282', t147Matricula(2), '45G1', 'COCTG', 'LNH'),
  e2Reserva('0180482', '45G1', 'COTRB', 'LNH'),
]);

/// Otro plan de carga del mismo buque, viaje y puerto: el corregido.
final _otraCargaEdi = e2PlanEdi([
  e2Grupo('0180182', t147Matricula(1), '45G1', 'COCTG', 'LNH'),
  e2Grupo('0180282', t147Matricula(3), '45G1', 'COCTG', 'LNH'),
  e2Reserva('0180482', '45G1', 'COTRB', 'LNH'),
]);

/// Su plano de llegada.
final _llegadaEdi = e2PlanEdi([
  e2Grupo('0180682', t147Matricula(5), '45G1', e2Escala, 'LNH',
      carga: 'HNPCR'),
]);

final _cierre = DateTime.utc(2026, 11, 20, 18);

OperationSource _fuente(OperationSourceKind kind, String edi, String nombre) =>
    OperationSource(kind: kind, fileName: nombre, content: edi);

final _carga =
    _fuente(OperationSourceKind.loadingBaplie, _cargaEdi, 'carga.edi');
final _otraCarga =
    _fuente(OperationSourceKind.loadingBaplie, _otraCargaEdi, 'carga-2.edi');
final _llegada =
    _fuente(OperationSourceKind.arrivalBaplie, _llegadaEdi, 'llegada.edi');
const _listado = OperationSource(
    kind: OperationSourceKind.exportList,
    fileName: 'listado.xlsx',
    content: '{"rows":[]}');

Operation _operacion(String id,
        {bool publicada = false,
        DateTime? cerrada,
        DateTime? creada,
        Iterable<OperationSource>? fuentes}) =>
    Operation(
        id: id,
        vesselName: 'BUQUE SINTETICO DOS',
        voyageNumber: 'VIAJE147E',
        portOfCall: e2Escala,
        createdAt: creada ?? DateTime.utc(2026, 11, 20, 8),
        sources: fuentes ?? [_carga],
        published: publicada,
        closedAt: cerrada);

Operation _cerrada({Iterable<OperationSource>? fuentes}) => _operacion(
    'cerrada',
    publicada: true,
    cerrada: _cierre,
    fuentes: fuentes);

class _Sesion implements SessionRepository {
  final OperatorRole rol;
  _Sesion(this.rol);

  @override
  bool get supportsAccounts => true;
  @override
  Operator? get current => Operator(uid: 'u1', name: 'Cuenta 1', role: rol);
  @override
  Stream<Operator?> watchOperator() async* {
    yield current;
  }

  @override
  Future<void> verify() async {}
  @override
  Future<void> dispose() async {}
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Plano extends VoyageNotifier {
  final VesselVoyage plan;
  _Plano(this.plan);

  @override
  AsyncValue<VesselVoyage?> build() => AsyncValue.data(plan);
}

void main() {
  final plan = e2Plan(_cargaEdi);
  final otroPlan = e2Plan(_otraCargaEdi);

  group('P8 a) · La operación de la escala, después de cerrar', () {
    test('con otro archivo nace una operación nueva, y la cerrada no cambia',
        () async {
      final bitacora = E2Bitacora([_cerrada()]);
      final Operation nueva;
      try {
        nueva = await OperationSources.save(
            bitacora, otroPlan, e2Escala, _otraCarga,
            clock: () => DateTime.utc(2026, 11, 21, 9));
      } on ValidationFailure catch (e) {
        fail('la 1.0.2 lo rechazaba, y no había cómo seguir: ${e.message}');
      }
      expect(nueva.id, isNot('cerrada'));
      expect(nueva.published, isFalse);
      expect(nueva.closed, isFalse);
      expect(nueva.vesselName, 'BUQUE SINTETICO DOS');
      expect(nueva.voyageNumber, 'VIAJE147E');
      expect(nueva.portOfCall, e2Escala);
      expect(nueva.sources.map((s) => s.fileName), ['carga-2.edi']);
      expect(bitacora.operaciones, hasLength(2));
      expect(bitacora.operaciones.firstWhere((o) => o.id == 'cerrada'),
          _cerrada());
      expect((await OperationSources.find(bitacora, otroPlan, e2Escala))!.id,
          nueva.id);
    });

    test('el plano de llegada que faltaba también abre una nueva, y el plan '
        'de carga se le suma', () async {
      final bitacora = E2Bitacora([_cerrada()]);
      final Operation nueva;
      try {
        nueva = await OperationSources.save(
            bitacora, e2Plan(_llegadaEdi), e2Escala, _llegada,
            clock: () => DateTime.utc(2026, 11, 21, 9));
      } on ValidationFailure catch (e) {
        fail('la 1.0.2 lo rechazaba: ${e.message}');
      }
      expect(nueva.sources.map((s) => s.kind),
          [OperationSourceKind.arrivalBaplie]);
      // El mismo plan de carga de la cerrada entra a la nueva.
      final completa =
          await OperationSources.save(bitacora, plan, e2Escala, _carga);
      expect(completa.id, nueva.id);
      expect(completa.sources.map((s) => s.fileName),
          ['llegada.edi', 'carga.edi']);
      expect(bitacora.operaciones.firstWhere((o) => o.id == 'cerrada'),
          _cerrada());
    });

    test('con el mismo archivo se sigue viendo la cerrada', () async {
      final bitacora = E2Bitacora([_cerrada()]);
      final vista =
          await OperationSources.save(bitacora, plan, e2Escala, _carga);
      expect(vista.id, 'cerrada');
      expect(vista.closed, isTrue);
      expect(bitacora.operaciones, hasLength(1));
    });

    test('el reloj atrasado del equipo no esconde la operación nueva',
        () async {
      final bitacora = E2Bitacora([_cerrada()]);
      final Operation nueva;
      try {
        nueva = await OperationSources.save(
            bitacora, otroPlan, e2Escala, _otraCarga,
            clock: () => _cierre.subtract(const Duration(hours: 3)));
      } on ValidationFailure catch (e) {
        fail('la 1.0.2 lo rechazaba: ${e.message}');
      }
      expect(nueva.createdAt.isAfter(_cierre), isTrue);
      expect((await OperationSources.find(bitacora, otroPlan, e2Escala))!.id,
          nueva.id);
    });

    test('otro listado en la cerrada se rechaza, y dice por dónde seguir',
        () async {
      final bitacora = E2Bitacora([
        _cerrada(fuentes: [_carga, _listado])
      ]);
      Object? error;
      try {
        await OperationSources.save(
            bitacora,
            plan,
            e2Escala,
            const OperationSource(
                kind: OperationSourceKind.exportList,
                fileName: 'listado-2.xlsx',
                content: '{"rows":[],"fileName":"otro"}'));
      } on ValidationFailure catch (e) {
        error = e;
      }
      expect(error, isNotNull);
      expect((error! as ValidationFailure).message,
          contains('empieza una operación nueva desde «Nube y cuenta»'),
          reason: 'la 1.0.2 mandaba a «abrir el plan como una operación '
              'nueva», que no se podía');
      expect(bitacora.operaciones, hasLength(1));
    });

    test('la publicada y abierta manda sobre la cerrada, esté donde esté',
        () async {
      final abierta = _operacion('abierta',
          publicada: true, creada: DateTime.utc(2026, 11, 21, 9));
      for (final orden in [
        [_cerrada(), abierta],
        [abierta, _cerrada()],
      ]) {
        final vista = await OperationSources.find(
            E2Bitacora(orden), plan, e2Escala);
        expect(vista!.id, 'abierta',
            reason: 'la 1.0.2 daba la primera publicada, aunque estuviera '
                'cerrada');
      }
    });

    test('la copia local de antes del cierre no tapa a la cerrada', () async {
      // El muelle abrió el archivo antes de unirse: esa copia es anterior.
      final vieja = _operacion('vieja', creada: DateTime.utc(2026, 11, 20, 7));
      for (final orden in [
        [vieja, _cerrada()],
        [_cerrada(), vieja],
      ]) {
        final vista = await OperationSources.find(
            E2Bitacora(orden), plan, e2Escala);
        expect(vista!.id, 'cerrada');
      }
    });

    test('de dos cerradas se ve la más reciente, o la que se empezó después',
        () async {
      final primera = _cerrada();
      final segunda = _operacion('segunda',
          publicada: true,
          creada: DateTime.utc(2026, 11, 21, 9),
          cerrada: DateTime.utc(2026, 11, 21, 12));
      expect(
          (await OperationSources.find(
                  E2Bitacora([primera, segunda]), plan, e2Escala))!
              .id,
          'segunda',
          reason: 'la 1.0.2 daba la primera');
      // Una local de entre los dos cierres ya no cuenta.
      final entre = _operacion('entre', creada: DateTime.utc(2026, 11, 21, 8));
      expect(
          (await OperationSources.find(
                  E2Bitacora([primera, entre, segunda]), plan, e2Escala))!
              .id,
          'segunda');
      final tercera =
          _operacion('tercera', creada: DateTime.utc(2026, 11, 21, 13));
      expect(
          (await OperationSources.find(
                  E2Bitacora([primera, entre, segunda, tercera]),
                  plan,
                  e2Escala))!
              .id,
          'tercera');
    });
  });

  group('P8 a) · «Empezar una operación nueva», en «Nube y cuenta»', () {
    Future<E2Bitacora> abrirLaNube(WidgetTester tester,
        {OperatorRole? rol, Iterable<OperationSource>? fuentes}) async {
      tester.view.physicalSize = const Size(360, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final bitacora = E2Bitacora([_cerrada(fuentes: fuentes)]);
      await tester.pumpWidget(ProviderScope(overrides: [
        if (rol != null) ...[
          sessionRepositoryProvider.overrideWith((ref) async => _Sesion(rol)),
          operationSyncProvider
              .overrideWith((ref) async => const LocalOnlyOperationSync()),
        ],
        movementLogRepositoryProvider.overrideWith((ref) async => bitacora),
        voyageNotifierProvider.overrideWith(() => _Plano(plan)),
      ], child: const MaterialApp(home: CloudPage())));
      await tester.pumpAndSettle();
      return bitacora;
    }

    testWidgets('la oficina ve la cerrada y empieza otra con sus planos',
        (tester) async {
      final bitacora = await abrirLaNube(tester,
          rol: OperatorRole.office, fuentes: [_llegada, _carga, _listado]);
      expect(e2Textos(tester, 'cerrada'), isNotEmpty);
      final boton = find.byKey(const ValueKey('new-operation-button'));
      expect(boton, findsOneWidget,
          reason: 'la 1.0.2 no tenía cómo empezar de nuevo');
      expect(find.text('Empezar una operación nueva'), findsOneWidget);
      expect(e2Textos(tester, 'solo para mirar'), hasLength(1));
      expect(find.byKey(const ValueKey('publish-button')), findsNothing);

      await tester.tap(boton);
      await tester.pumpAndSettle();
      final texto = e2Textos(tester, 'Empieza de cero').join();
      expect(texto, contains('el plano de llegada («llegada.edi»)'));
      expect(texto, contains('el plan de carga («carga.edi»)'));
      expect(texto, contains('El listado de la agencia se importa de nuevo'));
      expect(texto, contains('deja de verse en este equipo'));
      // «Cancelar» no cambia nada.
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();
      expect(bitacora.operaciones, hasLength(1));

      await tester.tap(boton);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('new-operation-confirm')));
      await tester.pumpAndSettle();
      expect(bitacora.operaciones, hasLength(2));
      final nueva = bitacora.operaciones.firstWhere((o) => o.id != 'cerrada');
      expect(nueva.published, isFalse);
      expect(nueva.closed, isFalse);
      expect(nueva.sources.map((s) => s.fileName),
          ['llegada.edi', 'carga.edi'],
          reason: 'los planos, sin el listado');
      expect(
          nueva.source(OperationSourceKind.loadingBaplie)!.content, _cargaEdi);
      expect(nueva.createdAt.isAfter(_cierre), isTrue);
      // La cerrada queda como estaba.
      expect(
          bitacora.operaciones.firstWhere((o) => o.id == 'cerrada'),
          _cerrada(fuentes: [_llegada, _carga, _listado]));
      // Y la pantalla pasa a la nueva, lista para publicarse.
      expect(find.byKey(const ValueKey('new-operation-button')), findsNothing);
      expect(find.byKey(const ValueKey('publish-button')), findsOneWidget);
      expect(e2Textos(tester, 'Operación nueva, en este dispositivo'),
          hasLength(1));
      expect(e2Textos(tester, 'la anterior de esta escala se cerró'),
          hasLength(1));
      expect(e2Textos(tester, 'Fuentes: llegada · carga'), hasLength(1));
      expect(tester.takeException(), isNull);
    });

    testWidgets('sin cuenta también se puede: es el equipo que opera solo',
        (tester) async {
      final bitacora = await abrirLaNube(tester);
      final boton = find.byKey(const ValueKey('new-operation-button'));
      expect(boton, findsOneWidget, reason: 'la 1.0.2 no lo tenía');
      await tester.tap(boton);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('new-operation-confirm')));
      await tester.pumpAndSettle();
      expect(bitacora.operaciones, hasLength(2));
      expect(tester.takeException(), isNull);
    });

    testWidgets('el muelle no la empieza: se une a la que publique la oficina',
        (tester) async {
      await abrirLaNube(tester, rol: OperatorRole.dock);
      expect(find.byKey(const ValueKey('new-operation-button')), findsNothing);
      expect(e2Textos(tester, 'únete a ella'), hasLength(1),
          reason: 'la 1.0.2 no decía por dónde seguir');
      expect(tester.takeException(), isNull);
    });
  });
}
