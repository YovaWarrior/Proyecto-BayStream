import 'package:baystream/core/utils/iso_coordinate_parser.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/presentation/pages/hatch_covers_page.dart';
import 'package:baystream/features/vessel/presentation/pages/recent_voyages_page.dart';
import 'package:baystream/features/vessel/presentation/pages/vessel_geometry_page.dart';
import 'package:baystream/features/vessel/presentation/providers/vessel_providers.dart';
import 'package:baystream/features/vessel/presentation/widgets/empty_state_widget.dart';
import 'package:baystream/features/vessel/presentation/widgets/voyage_summary_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// La escala que T-104 midió en el Honor a font_scale=2.0 (honor-escala-real-2
/// en TEMP, 15-oct), con los mismos puntos; se interpola entre ellos.
class _HonorLargeText extends TextScaler {
  const _HonorLargeText();
  static const _samples = <int, double>{
    8: 16, 10: 20, 11: 22, 12: 24, 14: 26, 16: 28, 18: 30, 20: 34, 22: 35,
    24: 36, 28: 37.333, 32: 39.771, 36: 43.314, 40: 46.857, 48: 53.943,
    56: 61.029, 64: 68.114, 72: 75.200, 96: 96.457, 100: 100,
  };
  @override
  double scale(double fontSize) {
    var previousSize = 0.0;
    var previousScaled = 0.0;
    for (final sample in _samples.entries) {
      if (fontSize <= sample.key) {
        return previousScaled +
            (sample.value - previousScaled) *
                (fontSize - previousSize) /
                (sample.key - previousSize);
      }
      previousSize = sample.key.toDouble();
      previousScaled = sample.value;
    }
    return fontSize;
  }

  @override
  double get textScaleFactor => 2;
}

Widget _app(Widget home, Brightness brightness) => MaterialApp(
    theme: ThemeData(brightness: brightness, fontFamily: 'Roboto'),
    builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: const _HonorLargeText()),
        child: child!),
    home: home);

void _size(WidgetTester tester) {
  tester.view.physicalSize = const Size(360, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

ContainerUnit _unit(int n, String position, {String? pol, String? pod}) =>
    ContainerUnit(
        id: 't56-$n',
        containerId: 'TSTU${n.toString().padLeft(7, '0')}',
        isoSizeType: '22G1',
        grossWeight: 10000,
        portOfLoading: pol,
        portOfDischarge: pod,
        stowagePosition: IsoCoordinateParser.parse(position));

const _geometry = VesselGeometry(
    portRows: 1, starboardRows: 1, holdTiers: [2], deckTiers: [82, 84]);

/// Escala sintética: dos sin LOC+9 que siguen a bordo, uno sin LOC+9 que se
/// descarga aquí (ya contado) y uno clasificado de paso.
VesselVoyage _voyage(
    {String number = 'VIAJE007A',
    List<ContainerUnit>? containers,
    List<ReservedSlot> reserved = const []}) {
  final units = containers ??
      [
        _unit(1, '0010182', pod: 'PAMIT'),
        _unit(2, '0010184'),
        _unit(3, '0010102', pod: 'GTPBR'),
        _unit(4, '0030182', pol: 'HNPCR', pod: 'PAMIT'),
      ];
  final bays = <int, Bay>{};
  for (final unit in units) {
    final bay = unit.stowagePosition!.bay;
    bays[bay] = (bays[bay] ?? Bay(bayNumber: bay, is40FtBay: bay.isEven))
        .addContainer(unit);
  }
  return VesselVoyage(
          id: 't56-$number',
          vessel: const Vessel(id: 't56-buque', name: 'BUQUE PRUEBA'),
          voyageNumber: number,
          containers: units,
          bays: bays,
          reservedSlots: reserved)
      .withGeometry(_geometry, portOfCall: 'GTPBR');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final font = FontLoader('Roboto')
      ..addFont(rootBundle.load('assets/fonts/Roboto-Regular.ttf'));
    await font.load();
  });

  group('T-56 resumen de la escala sin LOC+9', () {
    test('cuenta solo lo que no se clasificó en ninguna parte', () {
      final v = _voyage();
      expect(v.cargoCountsFor('GTPBR'),
          (loaded: 0, discharged: 1, transit: 1));
      expect(v.withoutLoadingPortAt('GTPBR'), (containers: 2, reserved: 0));
      expect(v.withoutLoadingPortAt(null), (containers: 0, reserved: 0));
    });

    testWidgets('la ficha agrega «N sin puerto de carga en el archivo»',
        (tester) async {
      _size(tester);
      await tester.pumpWidget(_app(
          Scaffold(
              body: SingleChildScrollView(
                  child: VoyageSummaryCard(voyage: _voyage()))),
          Brightness.light));
      expect(
          find.text('1 se descargan · 0 se cargan · 1 de paso · '
              '2 sin puerto de carga en el archivo'),
          findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('sin ninguno, la ficha queda como antes', (tester) async {
      await tester.pumpWidget(_app(
          Scaffold(
              body: SingleChildScrollView(
                  child: VoyageSummaryCard(
                      voyage: _voyage(containers: [
            _unit(1, '0010182', pol: 'HNPCR', pod: 'GTPBR'),
          ])))),
          Brightness.light));
      expect(find.text('1 se descargan · 0 se cargan · 0 de paso'),
          findsOneWidget);
      expect(find.textContaining('sin puerto de carga'), findsNothing);
    });

    testWidgets('con reservas, una línea más, en singular y plural',
        (tester) async {
      ReservedSlot slot(String position, {String? pol}) => ReservedSlot(
          stowagePosition: IsoCoordinateParser.parse(position),
          isoSizeType: '22G1',
          status: ContainerStatus.empty,
          portOfLoading: pol,
          portOfDischarge: 'PAMIT',
          nominalWeight: 2100);
      await tester.pumpWidget(_app(
          Scaffold(
              body: SingleChildScrollView(
                  child: VoyageSummaryCard(
                      voyage: _voyage(reserved: [
            slot('0030184'),
            slot('0030102', pol: 'GTPBR'),
          ])))),
          Brightness.light));
      expect(
          tester
              .widget<Text>(
                  find.byKey(const ValueKey('call-without-loading-port')))
              .data,
          'Sin puerto de carga en el archivo: 2 contenedores y 1 reserva');
      // 10.57: las cuatro líneas concuerdan con su cifra.
      expect(find.text('Se cargan 0 contenedores y 1 reserva (1 movimiento)'),
          findsOneWidget);
      expect(
          find.text('Se descargan 1 contenedor y 0 reservas (1 movimiento)'),
          findsOneWidget);
      expect(find.text('De paso 1 contenedor y 0 reservas'), findsOneWidget);
      expect(find.textContaining('1 reservas'), findsNothing);
      expect(find.textContaining('1 contenedores'), findsNothing);
      expect(find.textContaining('1 movimientos'), findsNothing);
    });

    testWidgets('la pantalla de parámetros dice lo mismo', (tester) async {
      tester.view.physicalSize = const Size(1000, 2600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final v = _voyage();
      await tester.pumpWidget(MaterialApp(
          home: VesselGeometryPage(
              proposal: _geometry,
              initial: _geometry,
              voyage: v,
              declaredPort: 'GTPBR',
              initialPortOfCall: 'GTPBR',
              positions: v.stowagePositions)));
      expect(
          find.text('1 se descargan · 0 se cargan · 1 de paso · '
              '2 sin puerto de carga en el archivo'),
          findsOneWidget);
    });
  });

  for (final brightness in Brightness.values) {
    testWidgets('T-56 Recientes dice «1 contenedor», ${brightness.name}',
        (tester) async {
      _size(tester);
      await tester.pumpWidget(ProviderScope(overrides: [
        recentVoyagesProvider.overrideWith((ref) async => [
              _voyage(containers: [_unit(1, '0010182', pol: 'HNPCR')])
            ]),
      ], child: _app(const RecentVoyagesPage(), brightness)));
      await tester.pumpAndSettle();
      expect(find.text('1 contenedor · 1 bahía'), findsOneWidget);
      expect(find.textContaining('1 contenedores'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'T-56 el desplegable de tapas no corta «abierta», Honor 2.0 '
        '${brightness.name}', (tester) async {
      _size(tester);
      await tester.pumpWidget(_app(
          HatchCoversPage(
              geometry: _geometry,
              holdBays: {1},
              initial: {
                1: HatchCoverDeclaration(kind: HatchCoverKind.openHold)
              }),
          brightness));
      await tester.pumpAndSettle();
      final field = find.byKey(const ValueKey('hatch-kind-1'));
      await tester.ensureVisible(field);
      await tester.pumpAndSettle();
      final selected = find.descendant(
          of: field, matching: find.text('Sin tapa · bodega abierta'));
      _whole(tester, selected, find.descendant(
          of: field, matching: find.byType(InputDecorator)));
      await tester.tap(field);
      await tester.pumpAndSettle();
      final option = find.text('Sin tapa · bodega abierta').last;
      _whole(tester, option,
          find.ancestor(of: option, matching: find.byType(InkWell)).first);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'T-56 el chip del viaje no se sale de su fondo, Honor 2.0 '
        '${brightness.name}', (tester) async {
      _size(tester);
      await tester.pumpWidget(_app(
          Scaffold(
              body: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: VoyageSummaryCard(voyage: _voyage()))),
          brightness));
      await tester.pumpAndSettle();
      final label = find.text('Viaje: VIAJE007A');
      final chip = find
          .ancestor(of: label, matching: find.byType(Container))
          .first;
      _whole(tester, label, chip);
      expect(tester.takeException(), isNull);
    });

    testWidgets('T-56 la pantalla vacía nombra la 1.5, ${brightness.name}',
        (tester) async {
      _size(tester);
      await tester.pumpWidget(
          _app(Scaffold(body: EmptyStateWidget(onPickFile: () {})), brightness));
      expect(find.text('Contenido compatible: BAPLIE 2.x, y la 1.5 con aviso.'),
          findsOneWidget);
      expect(find.text('Contenido compatible: BAPLIE 2.x.'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }
}

/// El texto se dibuja entero y dentro de [box]: sin líneas recortadas ni
/// glifos fuera del fondo. Admite menos de un dp por el redondeo.
void _whole(WidgetTester tester, Finder text, Finder box) {
  expect(text, findsOneWidget);
  final paragraph = tester.renderObject<RenderParagraph>(text);
  expect(paragraph.didExceedMaxLines, isFalse);
  final data = tester.widget<Text>(text).data!;
  final lines = paragraph.getBoxesForSelection(
      TextSelection(baseOffset: 0, extentOffset: data.length));
  final origin = paragraph.localToGlobal(Offset.zero);
  final outer = tester.getRect(box);
  for (final line in lines) {
    final glyphs = line.toRect().shift(origin);
    expect(glyphs.left, greaterThanOrEqualTo(outer.left - 1), reason: data);
    expect(glyphs.right, lessThanOrEqualTo(outer.right + 1), reason: data);
    expect(glyphs.top, greaterThanOrEqualTo(outer.top - 1), reason: data);
    expect(glyphs.bottom, lessThanOrEqualTo(outer.bottom + 1), reason: data);
  }
  // Lo que el padre deja ver: un recorte más bajo que el texto lo corta.
  final clip = paragraph.paintBounds.shift(origin);
  expect(clip.height, greaterThanOrEqualTo(lines.last.bottom - 1),
      reason: data);
}
