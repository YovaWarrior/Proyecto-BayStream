// T-147, entrega 2, parte 2b · P5: la matrícula repetida (10.160, D11).
//
// Un plan con una matrícula en más de una celda no entra a la nube: ni al
// publicar ni al agregar, el plano de llegada incluido. En el equipo que
// opera solo se deja operar, con el defecto a la vista: la ficha fija, la
// primera celda que responde, el peso del archivo y el aviso de la salida.
//
// Compila también contra `v1.0.2`, para que la roja sea por comportamiento:
// lo que la 1.0.2 no tiene se lee a través de `dynamic`.
import 'dart:async';

import 'package:baystream/core/errors/failures.dart';
import 'package:baystream/features/vessel/data/repositories/local_only_operation_sync.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/repositories/operation_sync_repository.dart';
import 'package:baystream/features/vessel/domain/repositories/session_repository.dart';
import 'package:baystream/features/vessel/domain/services/departure_baplie_writer.dart';
import 'package:baystream/features/vessel/domain/services/loading_operation.dart';
import 'package:baystream/features/vessel/domain/services/operation_sources.dart';
import 'package:baystream/features/vessel/presentation/pages/cloud_page.dart';
import 'package:baystream/features/vessel/presentation/providers/loading_operation_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/movement_log_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/sync_providers.dart';
import 'package:baystream/features/vessel/presentation/providers/vessel_providers.dart';
import 'package:baystream/features/vessel/presentation/widgets/bay_plan_view.dart';
import 'package:baystream/features/vessel/presentation/widgets/dialogo_agregar_plan.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/local_profile_test_support.dart';
import 'support/t147_listado_support.dart';
import 'support/t147e2_support.dart';
import 'support/t75_memory_log.dart';

final _repetida = t147Matricula(1);

/// El plan de carga: la misma matrícula en 018-01-82 (28.5 t) y en 018-00-82
/// (20.6 t), otro lleno y una celda reservada.
final _cargaEdi = e2PlanEdi([
  e2Grupo('0180182', _repetida, '45G1', 'COCTG', 'LNH', peso: 28500),
  e2Grupo('0180082', _repetida, '45G1', 'COCTG', 'LNH', peso: 20600),
  e2Grupo('0180282', t147Matricula(2), '45G1', 'COCTG', 'LNH'),
  e2Reserva('0180482', '45G1', 'COTRB', 'LNH'),
]);

/// El mismo plan, corregido: cada matrícula en una celda.
final _corregidaEdi = e2PlanEdi([
  e2Grupo('0180182', t147Matricula(3), '45G1', 'COCTG', 'LNH', peso: 28500),
  e2Grupo('0180082', _repetida, '45G1', 'COCTG', 'LNH', peso: 20600),
  e2Grupo('0180282', t147Matricula(2), '45G1', 'COCTG', 'LNH'),
  e2Reserva('0180482', '45G1', 'COTRB', 'LNH'),
]);

/// Un plano de llegada con la misma matrícula en dos celdas: bajan en la
/// escala.
final _llegadaEdi = e2PlanEdi([
  e2Grupo('0180182', _repetida, '45G1', e2Escala, 'LNH',
      carga: 'HNPCR', peso: 28500),
  e2Grupo('0180082', _repetida, '45G1', e2Escala, 'LNH',
      carga: 'HNPCR', peso: 20600),
  e2Grupo('0180282', t147Matricula(4), '45G1', e2Escala, 'LNH',
      carga: 'HNPCR'),
]);

/// Un plano de llegada que trae una vez la matrícula que el plan de carga
/// corregido trae una vez: un contenedor de paso, no una repetida.
final _llegadaDePasoEdi = e2PlanEdi([
  e2Grupo('0180082', _repetida, '45G1', 'COCTG', 'LNH', carga: 'HNPCR'),
  e2Grupo('0180682', t147Matricula(5), '45G1', e2Escala, 'LNH',
      carga: 'HNPCR'),
]);

VesselVoyage _conGeometria(String edi) {
  final plan = e2Plan(edi);
  return plan.withGeometry(VesselProfile.proposeFrom(plan).geometry,
      portOfCall: e2Escala);
}

OperationSource _fuente(OperationSourceKind kind, String edi, String nombre) =>
    OperationSource(kind: kind, fileName: nombre, content: edi);

Operation _publicada(Iterable<OperationSource> fuentes) => Operation(
    id: 'publicada',
    vesselName: 'BUQUE SINTETICO DOS',
    voyageNumber: 'VIAJE147E',
    portOfCall: e2Escala,
    createdAt: DateTime.utc(2026, 11, 20),
    sources: fuentes,
    published: true);

/// La nube, en memoria: recuerda lo que se le pidió agregar.
class _Nube implements OperationSyncRepository {
  final agregadas = <OperationSource>[];

  @override
  Future<Either<Failure, Operation>> addSource(
      Operation operation, OperationSource source) async {
    agregadas.add(source);
    return Right(
        operation.copyWith(sources: [...operation.sources, source]));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Sesion implements SessionRepository {
  @override
  bool get supportsAccounts => true;
  @override
  Operator? get current =>
      const Operator(uid: 'o1', name: 'Oficina 1', role: OperatorRole.office);
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

/// La matrícula repetida de una celda, o nulo. La 1.0.2 no la tiene.
Object? _repetidaEn(Object operacion, String posicion) =>
    e2Nuevo<Object?>(() => (operacion as dynamic).repeatedAt(posicion), null);

String _mensajeDe(Object error) => (error as ValidationFailure).message;

void main() {
  group('P5 · La operación con una matrícula repetida', () {
    test('la proyección de Carga pesa lo que trae el archivo', () {
      final plan = e2Plan(_cargaEdi);
      final operacion =
          LoadingOperation.build(operationId: 'e2b', loading: plan);
      expect(plan.totalWeight, closeTo(69100, 0.5));
      expect(operacion.loading.totalWeight, closeTo(plan.totalWeight, 0.5),
          reason: 'la 1.0.2 ponía dos veces el contenedor de la última celda');
      expect({
        for (final c in operacion.loading.containers)
          c.stowagePosition!.toIsoCode()
      }, containsAll(<String>['0180182', '0180082', '0180282']));
    });

    test('la operación sabe cuál celda no se puede operar', () {
      final operacion = LoadingOperation.build(
          operationId: 'e2b', loading: e2Plan(_cargaEdi));
      expect(_repetidaEn(operacion, '0180182'), isNotNull,
          reason: 'la primera celda es la que la operación no guarda');
      expect(_repetidaEn(operacion, '0180082'), isNull,
          reason: 'la última del archivo es la que se opera');
      expect(_repetidaEn(operacion, '0180282'), isNull);
      // La pieza que la operación guarda sigue siendo una, en la última.
      expect(operacion.plan.loading['C:$_repetida']!.plannedPosition,
          '0180082');
    });

    test('lo mismo en el plano de llegada, para la descarga', () {
      final operacion = LoadingOperation.build(
          operationId: 'e2b',
          arrival: e2Plan(_llegadaEdi),
          loading: e2Plan(_corregidaEdi));
      expect(_repetidaEn(operacion.discharge, '0180182'), isNotNull);
      expect(_repetidaEn(operacion.discharge, '0180082'), isNull);
      expect(_repetidaEn(operacion, '0180182'), isNull,
          reason: 'el plan de carga corregido no trae ninguna');
    });

    test('una vez en la llegada y una vez en la carga no es repetida', () {
      final operacion = LoadingOperation.build(
          operationId: 'e2b',
          arrival: e2Plan(_llegadaDePasoEdi),
          loading: e2Plan(_corregidaEdi));
      for (final celda in ['0180182', '0180082', '0180282', '0180682']) {
        expect(_repetidaEn(operacion, celda), isNull);
        expect(_repetidaEn(operacion.discharge, celda), isNull);
      }
    });

    test('la salida avisa de la matrícula, con sus dos celdas', () {
      final plan = e2Plan(_cargaEdi);
      final operacion =
          LoadingOperation.build(operationId: 'e2', loading: plan);
      final salida = const DepartureBaplieWriter().generate(
          operation: e2OperacionGuardada(_cargaEdi, plan),
          state: operacion.state,
          now: DateTime.utc(2026, 11, 21, 12),
          preview: true);
      final avisos = salida.warnings.where((w) => w.contains(_repetida));
      expect(avisos, hasLength(1), reason: salida.warnings.join('\n'));
      expect(avisos.single, contains('018-01-82 y 018-00-82'));
      expect(avisos.single, contains('un solo grupo'));
      expect(avisos.single, contains('plan de carga'));
    });

    test('la salida de un plan sin repetidas no dice nada de eso', () {
      final plan = e2Plan(_corregidaEdi);
      final operacion =
          LoadingOperation.build(operationId: 'e2', loading: plan);
      final salida = const DepartureBaplieWriter().generate(
          operation: e2OperacionGuardada(_corregidaEdi, plan),
          state: operacion.state,
          now: DateTime.utc(2026, 11, 21, 12),
          preview: true);
      expect(salida.warnings.where((w) => w.contains('un solo grupo')),
          isEmpty);
    });
  });

  group('P5 · No entra a la nube', () {
    test('el plan de carga con una repetida no se agrega', () async {
      final bitacora = E2Bitacora();
      final nube = _Nube();
      final publicada = _publicada([
        _fuente(OperationSourceKind.arrivalBaplie, _llegadaDePasoEdi,
            'llegada.edi'),
      ]);
      await bitacora.saveOperation(publicada);
      Object? error;
      try {
        await OperationSources.save(
            bitacora,
            e2Plan(_cargaEdi),
            e2Escala,
            _fuente(OperationSourceKind.loadingBaplie, _cargaEdi,
                'carga-repetida.edi'),
            sync: nube,
            attachTo: publicada);
      } on ValidationFailure catch (e) {
        error = e;
      }
      expect(error, isNotNull, reason: 'la 1.0.2 lo agregaba');
      expect(nube.agregadas, isEmpty);
      final mensaje = _mensajeDe(error!);
      expect(mensaje, startsWith('No se agrega: el plan de carga '));
      expect(mensaje, contains('«carga-repetida.edi»'));
      expect(mensaje, contains('1 matrícula en más de una celda'));
      expect(mensaje, contains('$_repetida en 018-01-82 y 018-00-82'));
      expect(mensaje, contains('Pide el plan corregido'));
    });

    test('el plano de llegada con una repetida tampoco', () async {
      final bitacora = E2Bitacora();
      final nube = _Nube();
      final publicada = _publicada([
        _fuente(
            OperationSourceKind.loadingBaplie, _corregidaEdi, 'carga.edi'),
      ]);
      await bitacora.saveOperation(publicada);
      Object? error;
      try {
        await OperationSources.save(
            bitacora,
            e2Plan(_llegadaEdi),
            e2Escala,
            _fuente(OperationSourceKind.arrivalBaplie, _llegadaEdi,
                'llegada-repetida.edi'),
            sync: nube,
            attachTo: publicada);
      } on ValidationFailure catch (e) {
        error = e;
      }
      expect(error, isNotNull, reason: 'la 1.0.2 lo agregaba');
      expect(nube.agregadas, isEmpty);
      expect(_mensajeDe(error!),
          startsWith('No se agrega: el plano de llegada '));
    });

    test('el plan corregido sí se agrega, aunque la llegada traiga la misma '
        'matrícula una vez', () async {
      final bitacora = E2Bitacora();
      final nube = _Nube();
      final publicada = _publicada([
        _fuente(OperationSourceKind.arrivalBaplie, _llegadaDePasoEdi,
            'llegada.edi'),
      ]);
      await bitacora.saveOperation(publicada);
      await OperationSources.save(
          bitacora,
          e2Plan(_corregidaEdi),
          e2Escala,
          _fuente(OperationSourceKind.loadingBaplie, _corregidaEdi,
              'carga.edi'),
          sync: nube,
          attachTo: publicada);
      expect(nube.agregadas, hasLength(1));
    });

    test('en el equipo que opera solo, el plan repetido se guarda', () async {
      final bitacora = E2Bitacora();
      final guardada = await OperationSources.save(
          bitacora,
          e2Plan(_cargaEdi),
          e2Escala,
          _fuente(OperationSourceKind.loadingBaplie, _cargaEdi,
              'carga-repetida.edi'));
      expect(guardada.published, isFalse);
      expect(bitacora.operaciones, hasLength(1));
      // Y el plan corregido reemplaza al anterior, en la misma operación.
      final corregida = await OperationSources.save(
          bitacora,
          e2Plan(_corregidaEdi),
          e2Escala,
          _fuente(OperationSourceKind.loadingBaplie, _corregidaEdi,
              'carga.edi'));
      expect(corregida.id, guardada.id);
      expect(corregida.source(OperationSourceKind.loadingBaplie)!.fileName,
          'carga.edi');
    });

    Future<void> abrirLaNube(WidgetTester tester, String edi) async {
      tester.view.physicalSize = const Size(360, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final plan = e2Plan(edi);
      await tester.pumpWidget(ProviderScope(overrides: [
        sessionRepositoryProvider.overrideWith((ref) async => _Sesion()),
        operationSyncProvider
            .overrideWith((ref) async => const LocalOnlyOperationSync()),
        movementLogRepositoryProvider.overrideWith((ref) async =>
            E2Bitacora([e2OperacionGuardada(edi, plan)])),
        voyageNotifierProvider.overrideWith(() => _Plano(plan)),
      ], child: const MaterialApp(home: CloudPage())));
      await tester.pumpAndSettle();
    }

    testWidgets('«Publicar operación» queda apagado, con el motivo debajo',
        (tester) async {
      await abrirLaNube(tester, _cargaEdi);
      final boton = tester.widget<FilledButton>(
          find.byKey(const ValueKey('publish-button')));
      expect(boton.onPressed, isNull, reason: 'la 1.0.2 lo dejaba publicar');
      final motivo = e2Textos(tester, 'No se publica').join('\n');
      expect(motivo, contains('No se publica: el plan de carga '));
      expect(motivo, contains('«sintetico-t147e2.edi»'));
      expect(motivo, contains('$_repetida en 018-01-82 y 018-00-82'));
      expect(tester.takeException(), isNull);
    });

    testWidgets('con el plan corregido, «Publicar operación» está encendido',
        (tester) async {
      await abrirLaNube(tester, _corregidaEdi);
      final boton = tester.widget<FilledButton>(
          find.byKey(const ValueKey('publish-button')));
      expect(boton.onPressed, isNotNull);
      expect(e2Textos(tester, 'No se publica'), isEmpty);
    });

    Future<void> abrirElDialogo(WidgetTester tester, String edi) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final publicada = _publicada([
        _fuente(OperationSourceKind.arrivalBaplie, _llegadaDePasoEdi,
            'llegada.edi'),
      ]);
      await tester.pumpWidget(MaterialApp(
          home: Scaffold(
              body: Builder(
                  builder: (context) => TextButton(
                      onPressed: () => unawaited(confirmarAgregarPlan(context,
                          plan: e2Plan(edi),
                          port: e2Escala,
                          kind: OperationSourceKind.loadingBaplie,
                          lookup: AttachablePlan(publicada),
                          fileName: 'carga-repetida.edi')),
                      child: const Text('abrir'))))));
      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();
    }

    testWidgets('el diálogo de agregar dice el motivo y apaga su botón',
        (tester) async {
      await abrirElDialogo(tester, _cargaEdi);
      final boton = tester.widget<FilledButton>(
          find.byKey(const ValueKey('attach-plan-confirm')));
      expect(boton.onPressed, isNull, reason: 'la 1.0.2 lo dejaba agregar');
      final motivo = e2Textos(tester, 'No se agrega').join('\n');
      expect(motivo, contains('$_repetida en 018-01-82 y 018-00-82'));
      expect(tester.takeException(), isNull);
    });

    testWidgets('con el plan corregido, el diálogo deja agregar',
        (tester) async {
      await abrirElDialogo(tester, _corregidaEdi);
      final boton = tester.widget<FilledButton>(
          find.byKey(const ValueKey('attach-plan-confirm')));
      expect(boton.onPressed, isNotNull);
      expect(e2Textos(tester, 'No se agrega'), isEmpty);
    });
  });

  group('P5 · En el equipo que opera solo', () {
    Future<void> abrirElPlano(WidgetTester tester, VesselVoyage plano,
        {LoadingOperation? operacion}) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final scope = ProviderContainer(overrides: [
        movementLogRepositoryProvider
            .overrideWith((ref) async => T75MemoryLog()),
        vesselRepositoryProvider.overrideWithValue(ParserOnlyRepository()),
        if (operacion != null)
          loadingOperationProvider(plano)
              .overrideWith((ref) => Stream.value(operacion)),
      ]);
      addTearDown(scope.dispose);
      await tester.pumpWidget(UncontrolledProviderScope(
          container: scope,
          child: MaterialApp(
              theme: ThemeData(useMaterial3: true),
              home: Scaffold(body: BayPlanView(voyage: plano)))));
      await tester.pumpAndSettle();
    }

    Future<void> modo(WidgetTester tester, String nombre) async {
      await tester.tap(find.byKey(const ValueKey('bay-plan-display-mode')));
      await tester.pumpAndSettle();
      await tester.tap(find.text(nombre).last);
      await tester.pumpAndSettle();
    }

    testWidgets('Carga: la ficha fija y la primera celda, que responde',
        (tester) async {
      final plano = _conGeometria(_cargaEdi);
      await abrirElPlano(tester, plano,
          operacion:
              LoadingOperation.build(operationId: 'e2b', loading: plano));
      await modo(tester, 'Carga');
      expect(
          e2Textos(tester, 'matrícula repetida'),
          contains('Plan con 1 matrícula repetida: una carga no se puede '
              'registrar. Pide el plan corregido.'),
          reason: 'la 1.0.2 no decía nada en Carga');
      // A 360 dp va fija, sobre el resumen recogido: se lee sin abrir nada.
      expect(find.textContaining('matrícula repetida').hitTestable(),
          findsOneWidget);
      final primera = find.byKey(const ValueKey('repeated-0180182'));
      expect(primera, findsOneWidget,
          reason: 'la 1.0.2 dibujaba la celda vacía, y no respondía');
      // La otra celda se opera como siempre.
      expect(find.byKey(ValueKey('loading-C:$_repetida')), findsOneWidget);
      await tester.ensureVisible(primera);
      await tester.tap(primera);
      await tester.pumpAndSettle();
      expect(find.text('Matrícula repetida'), findsOneWidget);
      expect(
          e2Textos(tester, 'también en'),
          contains('El plan trae $_repetida también en 018-00-82. Esta celda '
              'no se puede operar hasta abrir el plan corregido.'));
      await tester.tap(find.text('Entendido'));
      await tester.pumpAndSettle();
      expect(find.text('Matrícula repetida'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Descarga: la ficha fija y la primera celda, que responde',
        (tester) async {
      final plano = _conGeometria(_llegadaEdi);
      await abrirElPlano(tester, plano);
      await modo(tester, 'Descarga');
      expect(
          e2Textos(tester, 'matrícula repetida'),
          contains('Plan con 1 matrícula repetida: una descarga no se puede '
              'registrar. Pide el plan corregido.'),
          reason: 'la 1.0.2 no decía nada en Descarga');
      expect(find.textContaining('matrícula repetida').hitTestable(),
          findsOneWidget);
      final primera = find.byKey(const ValueKey('repeated-0180182'));
      expect(primera, findsOneWidget);
      await tester.ensureVisible(primera);
      await tester.tap(primera);
      await tester.pumpAndSettle();
      expect(
          e2Textos(tester, 'también en'),
          contains('El plan trae $_repetida también en 018-00-82. Esta celda '
              'no se puede operar hasta abrir el plan corregido.'));
      expect(tester.takeException(), isNull);
    });

    testWidgets('con el plan corregido no hay ficha ni celda apartada',
        (tester) async {
      final plano = _conGeometria(_corregidaEdi);
      await abrirElPlano(tester, plano,
          operacion:
              LoadingOperation.build(operationId: 'e2b', loading: plano));
      await modo(tester, 'Carga');
      expect(e2Textos(tester, 'matrícula repetida'), isEmpty);
      expect(find.byKey(const ValueKey('repeated-0180182')), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
}
