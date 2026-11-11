// T-143 · Los estados y los textos de la operación (10.117): la regla única
// del estado (O-139-7), la píldora de la cabecera, el chip con la operación
// cerrada (O-139-1), la etiqueta de la silueta (O-139-3) y los textos en tipo
// oración de la tarjeta y la Lista (O-139-2).
//
// Buque y números sintéticos (BUQUE MANUAL, TSTU); sin nube ni almacén real.
import 'package:baystream/core/design/design.dart';
import 'package:baystream/features/vessel/data/repositories/local_only_operation_sync.dart';
import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/repositories/operation_sync_repository.dart';
import 'package:baystream/features/vessel/presentation/formatters/operation_text.dart';
import 'package:baystream/features/vessel/presentation/pages/vessel_overview_page.dart';
import 'package:baystream/features/vessel/presentation/providers/movement_log_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/sync_providers.dart';
import 'package:baystream/features/vessel/presentation/providers/vessel_providers.dart';
import 'package:baystream/features/vessel/presentation/widgets/containers_list_view.dart';
import 'package:baystream/features/vessel/presentation/widgets/sync_status_chip.dart';
import 'package:baystream/features/vessel/presentation/widgets/voyage_summary_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/local_profile_test_support.dart';
import 'support/t117_oficina_support.dart';
import 'support/t74_movement_log_support.dart';

class _Viaje extends VoyageNotifier {
  _Viaje(this.voyage);
  final VesselVoyage voyage;
  @override
  AsyncValue<VesselVoyage?> build() => AsyncData(voyage);
}

Operation _operacion({bool publicada = true, DateTime? cerrada}) => Operation(
      id: '6a0c2b84-3f1d-4e7a-9b25-c8d4e1f0a937',
      vesselName: 'BUQUE MANUAL',
      voyageNumber: 'V117',
      portOfCall: 'GTSTC',
      createdAt: DateTime.utc(2026, 11, 10, 20),
      published: publicada,
      closedAt: cerrada,
    );

VesselVoyage _conGeometria(String texto, {String? escala = 'GTSTC'}) {
  final leido = BaplieParserService().parse(texto);
  return leido.withGeometry(
      VesselProfile.proposeFrom(leido)
          .geometry
          .copyWith(portRows: 4, starboardRows: 4),
      portOfCall: escala);
}

/// La página del viaje en la oficina (como `t117Pump`), con la operación y
/// el estado del envío que se pidan.
Future<void> _montar(
  WidgetTester tester, {
  VesselVoyage? voyage,
  Operation? operacion,
  SyncStatus? estado,
  Size tamano = const Size(1920, 1000),
  double letra = 1.0,
}) async {
  await t117CargarFuentes();
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = tamano;
  addTearDown(tester.view.reset);
  if (letra != 1.0) {
    tester.platformDispatcher.textScaleFactorTestValue = letra;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  }
  final scope = ProviderContainer(overrides: [
    voyageNotifierProvider.overrideWith(() => _Viaje(voyage ?? t117ConEscala)),
    localVesselRepositoryProvider.overrideWith((ref) async => T117Equipo()),
    vesselRepositoryProvider.overrideWithValue(ParserOnlyRepository()),
    movementLogRepositoryProvider.overrideWith((ref) async => T74MemoryLog()),
    sessionRepositoryProvider
        .overrideWith((ref) async => const LocalSessionRepository()),
    if (operacion != null)
      activeOperationProvider.overrideWith((ref) async => operacion),
    if (estado != null)
      syncStatusProvider.overrideWith((ref) => Stream.value(estado)),
  ]);
  addTearDown(scope.dispose);
  scope.read(selectedBayProvider.notifier).select(2);
  await tester.pumpWidget(UncontrolledProviderScope(
    container: scope,
    child: MaterialApp(
      theme: BayStreamTema.claro(),
      home: const VesselOverviewPage(),
    ),
  ));
  // Con la nube «Al día», el punto de «En vivo» late sin parar: no hay
  // `pumpAndSettle`, sino cuadros contados.
  await tester.pump();
  for (var i = 0; i < 20; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  group('la regla del estado (O-139-7)', () {
    test('sin confirmar, confirmado aquí, publicada y cerrada', () {
      expect(estadoDeLaOperacion(confirmado: false, operation: _operacion()),
          EstadoDeLaOperacion.sinConfirmar);
      expect(estadoDeLaOperacion(confirmado: true),
          EstadoDeLaOperacion.confirmado,
          reason: 'sin escala no hay operación: el plano está confirmado aquí');
      expect(
          estadoDeLaOperacion(
              confirmado: true,
              operation: _operacion(publicada: false),
              status: SyncStatus.local),
          EstadoDeLaOperacion.confirmado);
      expect(
          estadoDeLaOperacion(
              confirmado: true,
              operation: _operacion(),
              status: const SyncStatus(SyncState.offline, pending: 2)),
          EstadoDeLaOperacion.publicada,
          reason: 'sin red sigue publicada: la red no cambia el estado');
      expect(
          estadoDeLaOperacion(
              confirmado: true,
              operation: _operacion(cerrada: DateTime.utc(2026, 11, 10, 22))),
          EstadoDeLaOperacion.cerrada);
      expect(
          estadoDeLaOperacion(
              confirmado: true,
              operation: _operacion(),
              status: const SyncStatus(SyncState.upToDate, closed: true)),
          EstadoDeLaOperacion.cerrada,
          reason: 'el cierre que el motor vio cuenta antes de releer la operación');
    });

    test('la píldora dice una palabra y la frase la contiene', () {
      expect([for (final e in EstadoDeLaOperacion.values) textoDelEstado(e)],
          ['Sin confirmar', 'Confirmado', 'Publicada', 'Cerrada']);
      for (final e in EstadoDeLaOperacion.values) {
        expect(fraseDelEstado(e).toLowerCase(),
            startsWith(textoDelEstado(e).toLowerCase()),
            reason: 'la etiqueta accesible contiene lo que se ve');
      }
      expect(fraseDelEstado(EstadoDeLaOperacion.confirmado),
          'Confirmado en este equipo: la operación todavía no está en la nube');
      expect(fraseDelEstado(EstadoDeLaOperacion.confirmado),
          isNot(contains('Publicad')));
    });

    test('«Nube y cuenta» con la misma regla', () {
      expect(textoDeLaOperacionEnLaNube(_operacion(publicada: false), null),
          'Solo en este dispositivo');
      expect(textoDeLaOperacionEnLaNube(_operacion(), null), 'Publicada');
      expect(
          textoDeLaOperacionEnLaNube(
              _operacion(), const SyncStatus(SyncState.upToDate, closed: true)),
          'Publicada y cerrada');
    });
  });

  group('el chip con la operación cerrada (O-139-1)', () {
    test('no invita a registrar de nuevo lo que se rechazará otra vez', () {
      expect(
          syncStatusText(const SyncStatus(SyncState.upToDate, closed: true)),
          'Al día · operación cerrada');
      expect(
          syncStatusText(
              const SyncStatus(SyncState.upToDate, rejected: 1, closed: true)),
          'Al día · 1 rechazado: la operación ya estaba cerrada · operación cerrada');
      expect(
          syncStatusText(
              const SyncStatus(SyncState.offline, rejected: 2, closed: true)),
          'Sin conexión · 2 rechazados: la operación ya estaba cerrada · '
          'operación cerrada');
      expect(
          syncStatusText(const SyncStatus(SyncState.upToDate, rejected: 1)),
          'Al día · 1 rechazado por la nube, fuera del plan: regístralo de nuevo '
          'si hace falta',
          reason: 'con la operación abierta, el texto de siempre');
    });
  });

  group('la píldora de la cabecera (O-139-7)', () {
    Future<void> espera(WidgetTester tester, String palabra, String frase) async {
      final semantica = tester.ensureSemantics();
      final pildora = find.byKey(const ValueKey('cabecera-estado'));
      expect(pildora, findsOneWidget);
      expect(find.descendant(of: pildora, matching: find.text(palabra)),
          findsOneWidget);
      expect(tester.getSemantics(pildora).label, frase);
      expect(find.text('Publicado'), findsNothing);
      final ayuda = find.ancestor(of: pildora, matching: find.byType(Tooltip));
      expect(tester.widget<Tooltip>(ayuda.first).message, frase);
      semantica.dispose();
    }

    testWidgets('confirmado aquí, sin operación en la nube: «Confirmado»',
        (tester) async {
      await _montar(tester,
          operacion: _operacion(publicada: false), estado: SyncStatus.local);
      await espera(tester, 'Confirmado',
          'Confirmado en este equipo: la operación todavía no está en la nube');
    });

    testWidgets('sin escala, sin operación: «Confirmado»', (tester) async {
      await _montar(tester, voyage: t117SinEscala);
      await espera(tester, 'Confirmado',
          'Confirmado en este equipo: la operación todavía no está en la nube');
    });

    testWidgets('publicada: «Publicada»', (tester) async {
      await _montar(tester,
          operacion: _operacion(),
          estado: const SyncStatus(SyncState.upToDate));
      await espera(tester, 'Publicada', 'Publicada en la nube');
    });

    testWidgets('cerrada por la oficina, vista por el motor: «Cerrada»',
        (tester) async {
      await _montar(tester,
          operacion: _operacion(),
          estado: const SyncStatus(SyncState.upToDate, closed: true));
      await espera(tester, 'Cerrada',
          'Cerrada por la oficina: ya no se registran movimientos');
    });

    for (final letra in [1.0, 2.0]) {
      testWidgets('a 1024 dp con la letra a $letra la cabecera no se corta',
          (tester) async {
        await _montar(tester,
            operacion: _operacion(publicada: false),
            estado: SyncStatus.local,
            tamano: const Size(1024, 800),
            letra: letra);
        expect(find.text('Confirmado'), findsWidgets);
        expect(
            t117TextosCortados(
                tester, find.byKey(const ValueKey('cabecera-de-oficina'))),
            isEmpty);
        expect(tester.takeException(), isNull);
      });
    }
  });

  group('la etiqueta de la silueta (O-139-3)', () {
    List<String> etiquetas(WidgetTester tester) {
      final bahias = find.bySemanticsLabel(RegExp(r'^Bahía \d+,'));
      return [
        for (var i = 0; i < bahias.evaluate().length; i++)
          tester.getSemantics(bahias.at(i)).label
      ];
    }

    String? de(WidgetTester tester, String bahia) => etiquetas(tester)
        .where((e) => e.startsWith('Bahía $bahia,'))
        .firstOrNull;

    testWidgets('sin escala dice «sin operación»', (tester) async {
      final semantica = tester.ensureSemantics();
      await _montar(tester, voyage: t117SinEscala);
      expect(de(tester, '02'), endsWith(', sin operación'));
      semantica.dispose();
    });

    testWidgets('con la descarga a la vista, una bahía de paso no tiene movimientos',
        (tester) async {
      final semantica = tester.ensureSemantics();
      // La bahía 010 solo lleva un contenedor de paso, a USHOU.
      await _montar(tester,
          voyage: _conGeometria("$t117Texto"
              "LOC+147+0100182::5'LOC+9+HNPCR:139:6'LOC+11+USHOU:139:6'"
              "MEA+AAE+VGM+KGM:20000'EQD+CN+TSTU0000160+42G1+++5'"));
      expect(de(tester, '02'), contains('avance'));
      expect(de(tester, '10'), endsWith(', sin movimientos en GTSTC'));
      expect(etiquetas(tester).where((e) => e.contains('sin operación')), isEmpty);
      semantica.dispose();
    });

    testWidgets(
        'un plan de carga en «Contenido» no habla del avance ni dice «sin operación»',
        (tester) async {
      final semantica = tester.ensureSemantics();
      // Lo mismo, cargado en GTSTC: nada baja aquí, así que es un plan de
      // carga y en «Contenido» la silueta no muestra avance (T-139).
      final carga = t117Texto
          .replaceAll('LOC+11+GTSTC', 'LOC+11+PAMIT')
          .replaceAll('LOC+9+HNPCR', 'LOC+9+GTSTC');
      await _montar(tester, voyage: _conGeometria(carga));
      final todas = etiquetas(tester);
      expect(todas, isNotEmpty);
      for (final e in todas) {
        expect(e, isNot(contains('sin operación')));
        expect(e, isNot(contains('avance')));
      }
      expect(de(tester, '02'),
          'Bahía 02, 6 niveles en cubierta y 6 en bodega');
      semantica.dispose();
    });

    test('la pieza dice el motivo que le dan, o nada', () {
      const sinMotivo = BsBahiaDeSilueta(
          numero: 22, nivelesCubierta: 4, nivelesBodega: 3);
      expect(sinMotivo.etiqueta, 'Bahía 22, 4 niveles en cubierta y 3 en bodega');
      const conMotivo = BsBahiaDeSilueta(
          numero: 22,
          nivelesCubierta: 4,
          nivelesBodega: 3,
          sinAvance: 'sin movimientos en GTSTC');
      expect(conMotivo.etiqueta,
          'Bahía 22, 4 niveles en cubierta y 3 en bodega, sin movimientos en GTSTC');
      const conAvance = BsBahiaDeSilueta(
          numero: 22,
          nivelesCubierta: 4,
          nivelesBodega: 3,
          avance: 0.5,
          sinAvance: 'sin operación');
      expect(conAvance.etiqueta, contains('avance'),
          reason: 'con avance, el motivo no se usa');
    });
  });

  group('los textos en tipo oración (O-139-2)', () {
    testWidgets('la tarjeta del viaje dice «Peso total»', (tester) async {
      await tester.pumpWidget(MaterialApp(
          home: Scaffold(
              body: SingleChildScrollView(
                  child: VoyageSummaryCard(voyage: t117ConEscala)))));
      await tester.pumpAndSettle();
      expect(find.text('Peso total'), findsOneWidget);
      expect(find.text('Peso Total'), findsNothing);
    });

    testWidgets('la Lista dice «Lleno», «Vacío» y «Sin dato»', (tester) async {
      final lleno = t117ConEscala.containers
          .firstWhere((c) => c.status == ContainerStatus.full);
      final vacio = t117ConEscala.containers
          .firstWhere((c) => c.status == ContainerStatus.empty);
      final sinDato = lleno.copyWith(
          containerId: 'TSTU0000999', status: ContainerStatus.unknown);
      tester.view.physicalSize = const Size(1280, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(
          home: Scaffold(
              body: ContainersListView(containers: [lleno, vacio, sinDato]))));
      await tester.pumpAndSettle();
      expect(find.text('Lleno'), findsOneWidget);
      expect(find.text('Vacío'), findsOneWidget);
      expect(find.text('Sin dato'), findsOneWidget);
      for (final viejo in ['LLENO', 'VACÍO', 'N/A']) {
        expect(find.text(viejo), findsNothing);
      }
    });
  });
}
