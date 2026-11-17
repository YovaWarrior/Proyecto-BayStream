// T-131 · Lo común a las pruebas del distintivo de rol en las cabeceras
// (DESIGN.md 13.12): la página del viaje con un `operatorProvider` falso que
// se puede cambiar sin reiniciar, en las tres cabeceras donde va.
//
// Buque y números sintéticos (BUQUE MANUAL, TSTU); las cuentas son
// sintéticas y su nombre no se ve en ninguna cabecera; sin nube ni almacén
// real.
import 'dart:async';

import 'package:baystream/core/design/design.dart';
import 'package:baystream/features/vessel/data/repositories/local_only_operation_sync.dart';
import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/repositories/session_repository.dart';
import 'package:baystream/features/vessel/presentation/pages/vessel_overview_page.dart';
import 'package:baystream/features/vessel/presentation/providers/movement_log_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/sync_providers.dart';
import 'package:baystream/features/vessel/presentation/providers/vessel_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'local_profile_test_support.dart';
import 't117_oficina_support.dart';
import 't74_movement_log_support.dart';

/// Una cuenta de oficina autorizada.
const t131Oficina = Operator(
    uid: 'sintetica-oficina', name: 'Cuenta sintética', role: OperatorRole.office);

/// Una cuenta del muelle autorizada.
const t131Muelle = Operator(
    uid: 'sintetica-muelle', name: 'Cuenta sintética', role: OperatorRole.dock);

/// Una cuenta de oficina sin autorizar.
const t131SinAutorizar = Operator(
    uid: 'sintetica-x',
    name: 'Cuenta sintética',
    role: OperatorRole.office,
    authorized: false);

/// La cuenta del muelle de la copia local, sin red: sigue autorizada.
const t131DeLaCopia = Operator(
    uid: 'sintetica-muelle',
    name: 'Cuenta sintética',
    role: OperatorRole.dock,
    cached: true);

/// El mismo plano de T-117, sin escala, con un nombre de buque largo: en la
/// barra de 360 el distintivo no cabe completo y el nombre tiene que
/// encogerse. Sin escala, el muelle lleva la barra superior y no la banda.
final t131NombreLargo = () {
  final leido = BaplieParserService().parse(
      t117Texto.replaceAll('BUQUE MANUAL', 'BUQUE SINTETICO DE NOMBRE MUY LARGO'));
  return leido.withGeometry(VesselProfile.proposeFrom(leido)
      .geometry
      .copyWith(portRows: 4, starboardRows: 4));
}();

/// Las tres cabeceras donde va el distintivo, con su equipo y su tamaño de
/// referencia (el de las capturas de T-131).
enum T131Cabecera {
  /// La banda del muelle, operando: el Honor.
  banda('la banda del muelle', Size(360, 800), muelle: true, conEscala: true),

  /// La barra superior del teléfono del muelle fuera de una operación.
  barraDelMuelle('la barra superior del muelle sin operación', Size(360, 800),
      muelle: true, conEscala: false),

  /// La barra superior de la oficina en la Web de un teléfono.
  barraDeLaOficina('la barra superior de la oficina en un teléfono',
      Size(390, 844), muelle: false, conEscala: true),

  /// La cabecera de la oficina, en Windows y en la Web.
  cabecera('la cabecera de la oficina', Size(1366, 768),
      muelle: false, conEscala: true);

  const T131Cabecera(this.nombre, this.tamano,
      {required this.muelle, required this.conEscala});

  final String nombre;
  final Size tamano;

  /// La densidad (y el tema) del muelle: Android e iOS.
  final bool muelle;

  /// Con la escala GTSTC hay operación; sin ella, no.
  final bool conEscala;

  /// Dónde se busca el distintivo.
  Finder get donde => switch (this) {
        banda => find.byKey(const ValueKey('banda-del-muelle')),
        barraDelMuelle || barraDeLaOficina => find.byType(AppBar),
        cabecera => find.byKey(const ValueKey('cabecera-de-oficina')),
      };
}

/// T-143 · La operación de la escala de T-117 (BUQUE MANUAL · V117 ·
/// GTSTC), publicada y, si se pide, cerrada: con ella la píldora dice
/// «Publicada» o «Cerrada». Sin operación, el plano está «Confirmado» aquí.
Operation t131Operacion({bool cerrada = false, bool publicada = true}) =>
    Operation(
      id: '0b9e6d42-7c1a-4f85-a3e2-5d8c1b4f9a06',
      vesselName: 'BUQUE MANUAL',
      voyageNumber: 'V117',
      portOfCall: 'GTSTC',
      createdAt: DateTime.utc(2026, 11, 10, 20),
      published: publicada,
      closedAt: cerrada ? DateTime.utc(2026, 11, 10, 22) : null,
    );

class _Viaje extends VoyageNotifier {
  _Viaje(this.voyage);
  final VesselVoyage voyage;
  @override
  AsyncValue<VesselVoyage?> build() => AsyncData(voyage);
}

/// Monta la página del viaje en [donde] con [cuenta] y devuelve con qué
/// cambiar la cuenta después, como la escucha de la lista de autorizados.
/// Con [capturable], la app va dentro de un `RepaintBoundary` con la clave
/// `t131-pantalla`.
Future<ValueChanged<Operator?>> t131Pump(
  WidgetTester tester,
  T131Cabecera donde, {
  Operator? cuenta,
  Size? tamano,
  double letra = 1.0,
  bool oscuro = false,
  VesselVoyage? voyage,
  bool capturable = false,
  Operation? Function()? operacion,
}) async {
  await t117CargarFuentes();
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = tamano ?? donde.tamano;
  addTearDown(tester.view.reset);
  if (letra != 1.0) {
    tester.platformDispatcher.textScaleFactorTestValue = letra;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  }
  final cuentas = StreamController<Operator?>.broadcast();
  addTearDown(cuentas.close);
  final scope = ProviderContainer(overrides: [
    voyageNotifierProvider.overrideWith(() => _Viaje(
        voyage ?? (donde.conEscala ? t117ConEscala : t117SinEscala))),
    localVesselRepositoryProvider.overrideWith((ref) async => T117Equipo()),
    vesselRepositoryProvider.overrideWithValue(ParserOnlyRepository()),
    movementLogRepositoryProvider.overrideWith((ref) async => T74MemoryLog()),
    sessionRepositoryProvider
        .overrideWith((ref) async => const LocalSessionRepository()),
    operatorProvider.overrideWith((ref) async* {
      yield cuenta;
      yield* cuentas.stream;
    }),
    // T-143: la operación de la escala, que la píldora lee; se vuelve a leer
    // con `operationSourcesRevisionProvider`, como en la app al publicar.
    if (operacion != null)
      activeOperationProvider.overrideWith((ref) async {
        ref.watch(operationSourcesRevisionProvider);
        return operacion();
      }),
  ]);
  addTearDown(scope.dispose);
  scope.read(selectedBayProvider.notifier).select(2);
  final app = MaterialApp(
    // Sin la cinta de depuración: en las capturas tapaba la nube.
    debugShowCheckedModeBanner: false,
    theme: BayStreamTema.claro(muelle: donde.muelle),
    darkTheme: BayStreamTema.oscuro(muelle: donde.muelle),
    themeMode: oscuro ? ThemeMode.dark : ThemeMode.light,
    home: const VesselOverviewPage(),
  );
  await tester.pumpWidget(UncontrolledProviderScope(
    container: scope,
    child: capturable
        ? RepaintBoundary(key: const ValueKey('t131-pantalla'), child: app)
        : app,
  ));
  await tester.pumpAndSettle();
  return cuentas.add;
}

/// El distintivo que se ve en [donde], o nada.
BsDistintivoDeRol? t131Distintivo(WidgetTester tester, Finder donde) {
  final distintivos =
      find.descendant(of: donde, matching: find.byType(BsDistintivoDeRol));
  final cuantos = distintivos.evaluate().length;
  expect(cuantos, lessThanOrEqualTo(1), reason: 'un solo distintivo a la vista');
  return cuantos == 0 ? null : tester.widget<BsDistintivoDeRol>(distintivos);
}
