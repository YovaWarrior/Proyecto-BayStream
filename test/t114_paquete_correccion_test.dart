// Corrección del paquete de íconos tras la aceptación de Codex (10.23).
//
// H1: cada resultado de la búsqueda dice su condición al lector de pantalla
// (carga peligrosa, refrigerado, fuera de medida, vacío) con la etiqueta del
// ícono, y lleva una descripción emergente. Se lee desde el árbol de
// semántica, no solo desde el glifo.
// O1: la Lista, la búsqueda y el detalle dibujan el mismo glifo, con el mismo
// nombre, para el mismo contenedor: la regla única de `condicionDelContenedor`
// (`DESIGN.md` 13.11).

import 'package:baystream/core/design/design.dart';
import 'package:baystream/features/vessel/data/repositories/local_only_operation_sync.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/presentation/pages/vessel_overview_page.dart';
import 'package:baystream/features/vessel/presentation/providers/movement_log_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/plano_providers.dart';
import 'package:baystream/features/vessel/presentation/providers/sync_providers.dart';
import 'package:baystream/features/vessel/presentation/providers/vessel_providers.dart';
import 'package:baystream/features/vessel/presentation/widgets/container_search_delegate.dart';
import 'package:baystream/features/vessel/presentation/widgets/containers_list_view.dart';
import 'package:baystream/features/vessel/presentation/widgets/detalle_contenedor.dart';
import 'package:baystream/features/vessel/presentation/widgets/iconos_del_dominio.dart';
import 'package:baystream/features/vessel/presentation/widgets/loading_plan_controls.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/local_profile_test_support.dart';
import 'support/t74_movement_log_support.dart';
import 'support/t76_fixture.dart';
import 'support/t91_toolbar_support.dart';

/// Un contenedor sintético: el mismo número y tipo ISO en todos los casos,
/// para que solo cambie la condición.
ContainerUnit _contenedor(
  String iso, {
  ContainerStatus status = ContainerStatus.full,
  bool peligrosa = false,
  bool refrigerado = false,
  bool fueraDeMedida = false,
}) =>
    ContainerUnit(
      id: 'uuid-$iso',
      containerId: 'TSTU0000011',
      isoSizeType: iso,
      status: status,
      isDangerous: peligrosa,
      isReefer: refrigerado,
      isOverDimension: fueraDeMedida,
    );

/// Los cuatro casos de H1, con el nombre que cada uno tiene que decir.
final _casos = <String, ContainerUnit>{
  'Carga peligrosa': _contenedor('22G1', peligrosa: true),
  'Refrigerado': _contenedor('22G1', refrigerado: true),
  'Fuera de medida': _contenedor('22G1', fueraDeMedida: true),
  'Vacío': _contenedor('22G1', status: ContainerStatus.empty),
};

/// Los demás: el tipo ISO y el tamaño.
final _corrientes = <String, ContainerUnit>{
  'Contenedor de 20 pies': _contenedor('22G1'),
  'Contenedor de 40 pies': _contenedor('42G1'),
  'Contenedor de 45 pies': _contenedor('L5G1'),
  'Tanque': _contenedor('22T1'),
  'Plataforma': _contenedor('42P1'),
  'Techo abierto': _contenedor('22U1'),
};

/// Un viaje sin escala: el detalle no ofrece descarga ni acciones de oficina.
const _viaje = VesselVoyage(
  id: 'sintetico',
  vessel: Vessel(id: 'prueba', name: 'BUQUE PRUEBA'),
  voyageNumber: 'VPRUEBA',
);

Widget _app(Widget hijo) => ProviderScope(
      child: MaterialApp(
        theme: BayStreamTema.claro(muelle: true),
        home: Scaffold(body: hijo),
      ),
    );

/// Los resultados de la búsqueda para [contenedores], como los arma el
/// delegado con la consulta «TSTU».
Widget _busqueda(List<ContainerUnit> contenedores) =>
    Consumer(builder: (context, ref, _) {
      final delegado = ContainerSearchDelegate(
        containers: contenedores,
        ref: ref,
      )..query = 'TSTU';
      return delegado.buildResults(context);
    });

/// El glifo del ícono principal dentro de [donde].
Icon _principal(WidgetTester tester, Finder donde) => tester.widget<Icon>(
      find.descendant(
        of: find.descendant(
            of: donde, matching: find.byType(IconoDelContenedor)),
        matching: find.byType(Icon),
      ),
    );

Future<void> _pautas(WidgetTester tester) async {
  await expectLater(tester, meetsGuideline(textContrastGuideline));
  await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
  await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
}

class _Viaje extends VoyageNotifier {
  _Viaje(this.voyage);
  final VesselVoyage voyage;
  @override
  AsyncValue<VesselVoyage?> build() => AsyncData(voyage);
}

/// Las celdas del plano para la insignia: la bahía 003, cubierta, con los
/// cuatro casos y uno corriente. Cada una: el nombre que tiene que decir (vacío
/// si no dice ninguno), su unidad y la clave de su celda.
final _celdas = <({String nombre, ContainerUnit unidad, String clave})>[
  (
    nombre: 'Carga peligrosa',
    unidad: t76Unit('TSTU0000011', '0030182').copyWith(isDangerous: true),
    clave: 'cell-1-82',
  ),
  (
    nombre: 'Refrigerado',
    unidad: t76Unit('TSTU0000022', '0030282').copyWith(isReefer: true),
    clave: 'cell-2-82',
  ),
  (
    nombre: 'Fuera de medida',
    unidad: t76Unit('TSTU0000033', '0030382').copyWith(isOverDimension: true),
    clave: 'cell-3-82',
  ),
  (
    nombre: 'Vacío',
    unidad: t76Unit('TSTU0000044', '0030482')
        .copyWith(status: ContainerStatus.empty),
    clave: 'cell-4-82',
  ),
  (
    nombre: '',
    unidad: t76Unit('TSTU0000055', '0030582'),
    clave: 'cell-5-82',
  ),
];

/// El plano del viaje sintético con [_celdas], sin nube ni almacén real.
Future<ProviderContainer> _plano(WidgetTester tester) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(1300, 900);
  addTearDown(tester.view.reset);
  final viaje = t76Voyage([for (final c in _celdas) c.unidad]);
  final scope = ProviderContainer(overrides: [
    voyageNotifierProvider.overrideWith(() => _Viaje(viaje)),
    localVesselRepositoryProvider
        .overrideWith((ref) async => T91MemorySettings()),
    vesselRepositoryProvider.overrideWithValue(ParserOnlyRepository()),
    movementLogRepositoryProvider.overrideWith((ref) async => T74MemoryLog()),
    sessionRepositoryProvider
        .overrideWith((ref) async => const LocalSessionRepository()),
  ]);
  addTearDown(scope.dispose);
  scope.read(selectedBayProvider.notifier).select(3);
  await tester.pumpWidget(UncontrolledProviderScope(
    container: scope,
    child: MaterialApp(
      theme: BayStreamTema.claro(),
      home: const VesselOverviewPage(),
    ),
  ));
  await tester.pumpAndSettle();
  return scope;
}

void main() {
  group('H1 · la búsqueda dice la condición del contenedor', () {
    testWidgets('los cuatro casos, leídos desde el árbol de semántica',
        (tester) async {
      final semantica = tester.ensureSemantics();
      final etiquetas = <String>[];
      for (final MapEntry(key: nombre, value: contenedor) in _casos.entries) {
        await tester.pumpWidget(_app(_busqueda([contenedor])));
        await tester.pumpAndSettle();
        final resultado = find.byType(ListTile);
        final nodo = tester.getSemantics(resultado);
        expect(nodo.label, contains(nombre), reason: nodo.toStringDeep());
        expect(nodo.label, contains('TSTU0000011'), reason: nombre);
        expect(nodo.label, contains('22G1'), reason: nombre);
        etiquetas.add(nodo.label);

        final glifo = _principal(tester, resultado);
        expect(glifo.icon, iconoDeContenedor(contenedor), reason: nombre);
        expect(glifo.semanticLabel, nombre);

        final emergente = tester.widget<Tooltip>(
            find.descendant(of: resultado, matching: find.byType(Tooltip)));
        expect(emergente.message, nombre);
        // Fuera de la semántica: la etiqueta del glifo ya dice el nombre.
        expect(emergente.excludeFromSemantics, isTrue);
      }
      // Antes de la corrección, los cuatro tenían la misma etiqueta.
      expect(etiquetas.toSet(), hasLength(4), reason: etiquetas.join('\n'));
      semantica.dispose();
    });

    testWidgets('sin carga especial, dice el tipo ISO o el tamaño',
        (tester) async {
      final semantica = tester.ensureSemantics();
      for (final MapEntry(key: nombre, value: contenedor)
          in _corrientes.entries) {
        await tester.pumpWidget(_app(_busqueda([contenedor])));
        await tester.pumpAndSettle();
        final nodo = tester.getSemantics(find.byType(ListTile));
        expect(nodo.label, contains(nombre), reason: nodo.toStringDeep());
        expect(_principal(tester, find.byType(ListTile)).semanticLabel, nombre);
      }
      semantica.dispose();
    });

    testWidgets('la búsqueda y la Lista siguen las pautas con los cuatro casos',
        (tester) async {
      tester.view.physicalSize = const Size(900, 1800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final contenedores = _casos.values.toList();
      await tester.pumpWidget(_app(_busqueda(contenedores)));
      await tester.pumpAndSettle();
      expect(find.byType(ListTile), findsNWidgets(4));
      await _pautas(tester);
      await tester
          .pumpWidget(_app(ContainersListView(containers: contenedores)));
      await tester.pumpAndSettle();
      expect(find.byType(IconoDelContenedor), findsNWidgets(4));
      await _pautas(tester);
      expect(tester.takeException(), isNull);
    });
  });

  group('O1 · la regla única del ícono del contenedor', () {
    test('la condición da el glifo y el nombre, con la prioridad de 13.11', () {
      // La carga especial manda, en este orden; después el vacío; luego el
      // tipo ISO y, si no, el tamaño.
      expect(
          condicionDelContenedor(_contenedor('22T1',
              peligrosa: true,
              refrigerado: true,
              fueraDeMedida: true,
              status: ContainerStatus.empty)),
          CondicionDelContenedor.peligrosa);
      expect(
          condicionDelContenedor(_contenedor('22T1',
              refrigerado: true,
              fueraDeMedida: true,
              status: ContainerStatus.empty)),
          CondicionDelContenedor.refrigerado);
      expect(
          condicionDelContenedor(_contenedor('22T1',
              fueraDeMedida: true, status: ContainerStatus.empty)),
          CondicionDelContenedor.fueraDeMedida);
      expect(
          condicionDelContenedor(
              _contenedor('22T1', status: ContainerStatus.empty)),
          CondicionDelContenedor.vacio);
      expect(condicionDelContenedor(_contenedor('22T1')),
          CondicionDelContenedor.tanque);
      expect(condicionDelContenedor(_contenedor('42P1')),
          CondicionDelContenedor.plataforma);
      expect(condicionDelContenedor(_contenedor('22U1')),
          CondicionDelContenedor.techoAbierto);
      expect(condicionDelContenedor(_contenedor('42R1')),
          CondicionDelContenedor.refrigerado);
      expect(condicionDelContenedor(_contenedor('22G1')),
          CondicionDelContenedor.contenedor20);
      expect(condicionDelContenedor(_contenedor('42G1')),
          CondicionDelContenedor.contenedor40);
      expect(condicionDelContenedor(_contenedor('L5G1')),
          CondicionDelContenedor.contenedor45);
      expect(condicionDelContenedor(_contenedor('22B1')),
          CondicionDelContenedor.contenedor20);
      expect(
          condicionDelContenedor(
              const ContainerUnit(id: 'sin-iso', containerId: 'TSTU0000011')),
          CondicionDelContenedor.contenedor40);

      // Cada condición tiene su glifo del paquete y su nombre, todos distintos.
      const nombres = <CondicionDelContenedor, String>{
        CondicionDelContenedor.peligrosa: 'Carga peligrosa',
        CondicionDelContenedor.refrigerado: 'Refrigerado',
        CondicionDelContenedor.fueraDeMedida: 'Fuera de medida',
        CondicionDelContenedor.vacio: 'Vacío',
        CondicionDelContenedor.tanque: 'Tanque',
        CondicionDelContenedor.plataforma: 'Plataforma',
        CondicionDelContenedor.techoAbierto: 'Techo abierto',
        CondicionDelContenedor.contenedor20: 'Contenedor de 20 pies',
        CondicionDelContenedor.contenedor40: 'Contenedor de 40 pies',
        CondicionDelContenedor.contenedor45: 'Contenedor de 45 pies',
      };
      expect(nombres, hasLength(CondicionDelContenedor.values.length));
      for (final condicion in CondicionDelContenedor.values) {
        expect(condicion.icono.fontFamily, BsIconos.familia,
            reason: condicion.name);
        expect(condicion.nombre, nombres[condicion], reason: condicion.name);
      }
      expect(CondicionDelContenedor.values.map((c) => c.icono).toSet(),
          hasLength(CondicionDelContenedor.values.length));
      expect(CondicionDelContenedor.values.map((c) => c.nombre).toSet(),
          hasLength(CondicionDelContenedor.values.length));

      // Las funciones de siempre dan el glifo de la misma condición.
      for (final contenedor in [..._casos.values, ..._corrientes.values]) {
        expect(iconoDeContenedor(contenedor),
            condicionDelContenedor(contenedor).icono);
      }
      expect(iconoDeTipo(ContainerType.tank), BsIconos.tanque);
      expect(iconoDeTipo(null, pies: 20), BsIconos.contenedor20);
      expect(iconoDeTamano(45), BsIconos.contenedor45);
      expect(iconoDeTamano(null), BsIconos.contenedor40);
    });

    testWidgets(
        'la Lista, la búsqueda y el detalle dibujan el mismo glifo con el mismo nombre',
        (tester) async {
      for (final MapEntry(key: nombre, value: contenedor)
          in {..._casos, ..._corrientes}.entries) {
        final esperado = condicionDelContenedor(contenedor);
        expect(esperado.nombre, nombre);
        final glifos = <String, Icon>{};
        await tester
            .pumpWidget(_app(ContainersListView(containers: [contenedor])));
        await tester.pumpAndSettle();
        glifos['Lista'] = _principal(tester, find.byType(ContainersListView));
        await tester.pumpWidget(_app(_busqueda([contenedor])));
        await tester.pumpAndSettle();
        glifos['búsqueda'] = _principal(tester, find.byType(ListTile));
        await tester.pumpWidget(
            _app(DetalleContenedor(voyage: _viaje, container: contenedor)));
        await tester.pumpAndSettle();
        glifos['detalle'] = _principal(tester, find.byType(DetalleContenedor));
        for (final MapEntry(key: donde, value: glifo) in glifos.entries) {
          expect(glifo.icon, esperado.icono, reason: '$donde · $nombre');
          expect(glifo.icon!.fontFamily, BsIconos.familia, reason: donde);
          expect(glifo.semanticLabel, nombre, reason: '$donde · $nombre');
        }
        expect(tester.takeException(), isNull, reason: nombre);
      }
    });

    testWidgets(
        'la tarjeta de la Lista y el detalle también dicen la condición',
        (tester) async {
      final semantica = tester.ensureSemantics();
      for (final MapEntry(key: nombre, value: contenedor) in _casos.entries) {
        await tester
            .pumpWidget(_app(ContainersListView(containers: [contenedor])));
        await tester.pumpAndSettle();
        final tarjeta = tester.getSemantics(find.descendant(
            of: find.byType(Card), matching: find.byType(InkWell)));
        expect(tarjeta.label, contains(nombre), reason: tarjeta.toStringDeep());
        expect(tarjeta.label, contains('TSTU0000011'), reason: nombre);

        await tester.pumpWidget(
            _app(DetalleContenedor(voyage: _viaje, container: contenedor)));
        await tester.pumpAndSettle();
        expect(find.bySemanticsLabel(RegExp(nombre)), findsWidgets,
            reason: nombre);
        expect(
            tester
                .widget<Tooltip>(find.descendant(
                    of: find.byType(IconoDelContenedor),
                    matching: find.byType(Tooltip)))
                .message,
            nombre);
      }
      semantica.dispose();
    });
  });

  group('La celda del plano dice su insignia', () {
    testWidgets(
        'en Destino, Tipo de vacío y Estado, la etiqueta de la celda nombra la condición',
        (tester) async {
      final semantica = tester.ensureSemantics();
      const nombres = [
        'Carga peligrosa',
        'Refrigerado',
        'Fuera de medida',
        'Vacío'
      ];
      expect(
          CondicionDelContenedor.values
              .where((c) => c.enLaCelda)
              .map((c) => c.nombre),
          nombres);
      final scope = await _plano(tester);
      for (final vista in ColorearPor.values) {
        scope
            .read(colorearPorProvider.notifier)
            .elegir(BayPlanMode.content, vista);
        await tester.pumpAndSettle();
        for (final (:nombre, :unidad, :clave) in _celdas) {
          final donde = '$clave en ${vista.rotulo}';
          final celda = find.descendant(
              of: find.byKey(ValueKey(clave)),
              matching: find.byType(BsCelda),
              matchRoot: true);
          expect(celda, findsOneWidget, reason: donde);
          final etiqueta = tester.getSemantics(celda).label;
          expect(etiqueta, contains(formatearContenedor(unidad.containerId)),
              reason: donde);
          if (nombre.isEmpty) {
            for (final otro in nombres) {
              expect(etiqueta, isNot(contains(otro)), reason: donde);
            }
          } else {
            expect(etiqueta, contains(nombre), reason: '$donde: $etiqueta');
            for (final otro in nombres.where((n) => n != nombre)) {
              expect(etiqueta, isNot(contains(otro)), reason: donde);
            }
          }
          // La insignia dibujada es la que el nombre dice.
          expect(
              tester.widget<BsCelda>(celda).insignia,
              switch (nombre) {
                'Carga peligrosa' => BsInsigniaDeCelda.peligrosa,
                'Refrigerado' => BsInsigniaDeCelda.refrigerado,
                'Fuera de medida' => BsInsigniaDeCelda.oog,
                _ => BsInsigniaDeCelda.ninguna,
              },
              reason: donde);
        }
      }
      expect(tester.takeException(), isNull);
      semantica.dispose();
    });
  });
}
