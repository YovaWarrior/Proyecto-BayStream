// T-114 · Fase 3, entrega 1: el tema conectado, el inicio, el previo («ver
// primero, confirmar después», DESIGN.md 7) y la regla estricta de
// publicación directa (DESIGN.md 7.2; decisiones 10.2, 10.4 y 10.9).
//
// Los archivos son sintéticos: BUQUE MANUAL, con dos cajas en la bahía 002.
import 'dart:io';

import 'package:baystream/core/app.dart';
import 'package:baystream/core/design/design.dart';
import 'package:baystream/features/vessel/data/repositories/local_vessel_repository_impl.dart';
import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/domain/entities/app_theme_preference.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/presentation/pages/vessel_geometry_page.dart';
import 'package:baystream/features/vessel/presentation/pages/vessel_overview_page.dart';
import 'package:baystream/features/vessel/presentation/providers/discharge_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/movement_log_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/theme_preference_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/vessel_providers.dart';
import 'package:baystream/features/vessel/presentation/providers/voyage_ui_state.dart';
import 'package:baystream/features/vessel/presentation/widgets/bay_plan_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/local_profile_test_support.dart';
import 'support/t74_movement_log_support.dart';

const _cabecera = "UNH+1+BAPLIE:D:95B:UN:SMDG20'"
    "TDT+20+V01N+++NV2:172:20+++9000003:146:11:BUQUE MANUAL'";

/// Plan de carga: sale de GTSTC y todo se cargó en GTSTC.
const _planDeCarga = "${_cabecera}LOC+5+GTSTC:139:6'"
    "LOC+147+0020182::5'LOC+9+GTSTC:139:6'LOC+11+USHOU:139:6'"
    "EQD+CN+TEST0000001+42G1+++5'"
    "LOC+147+0020184::5'LOC+9+GTSTC:139:6'LOC+11+USHOU:139:6'"
    "EQD+CN+TEST0000002+42G1+++5'";

/// Plan de llegada: sale de PAMIT rumbo a GTSTC y todo se descarga en GTSTC.
/// Es el hallazgo 5 del manual: la app propone el puerto de salida.
const _planDeLlegada = "${_cabecera}LOC+5+PAMIT:139:6'LOC+61+GTSTC:139:6'"
    "LOC+147+0020182::5'LOC+9+PAMIT:139:6'LOC+11+GTSTC:139:6'"
    "EQD+CN+TEST0000001+42G1+++5'"
    "LOC+147+0020184::5'LOC+9+PAMIT:139:6'LOC+11+GTSTC:139:6'"
    "EQD+CN+TEST0000002+42G1+++5'";

/// El notifier del producto, con el selector de archivos sustituido.
class _ReplayNotifier extends VoyageNotifier {
  _ReplayNotifier(this.content);
  String content;
  @override
  Future<LoadFileResult> loadVesselFromFile() =>
      parseBaplieContent(content, fileName: 'BUQUE_MANUAL.edi');
}

void main() {
  late ProviderContainer container;
  late ({Directory directory, LocalVesselRepositoryImpl repository}) store;

  Future<void> abrir({String contenido = _planDeCarga}) async {
    store = await testProfileStore();
    container = ProviderContainer(overrides: [
      movementLogRepositoryProvider.overrideWith((ref) async => T74MemoryLog()),
      vesselRepositoryProvider.overrideWithValue(ParserOnlyRepository()),
      localVesselRepositoryProvider.overrideWith((ref) async => store.repository),
      voyageNotifierProvider.overrideWith(() => _ReplayNotifier(contenido)),
    ]);
  }

  Future<void> cerrar() async {
    container.dispose();
    await store.repository.close();
    await store.directory.delete(recursive: true);
  }

  VoyageNotifier notifier() => container.read(voyageNotifierProvider.notifier);

  /// Publica un plan de carga confirmando el perfil y la escala GTSTC, como
  /// lo haría la oficina la primera vez, y cierra el viaje.
  Future<void> publicarYCerrar() async {
    final n = notifier();
    final primera = await n.parseBaplieContent(_planDeCarga, fileName: 'carga.edi');
    expect(primera.preview, isTrue);
    expect(
        await n.confirmGeometry(n.currentProfile!.geometry,
            portOfCall: 'GTSTC', sourceKind: OperationSourceKind.loadingBaplie),
        isNull);
    expect(n.isPreview, isFalse);
    expect(n.publishedVoyage!.portOfCall, 'GTSTC');
    n.clearVoyage();
  }

  Future<void> pumpApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(UncontrolledProviderScope(
        container: container, child: const BayStreamApp()));
    await tester.pumpAndSettle();
  }

  group('el tema', () {
    testWidgets('el tema está conectado, en claro y en oscuro, con la preferencia',
        (tester) async {
      await tester.runAsync(() async {
        await abrir();
        try {
          await pumpApp(tester);
          var theme = Theme.of(tester.element(find.byType(VesselOverviewPage)));
          expect(theme.extension<BsColoresSemanticos>(), isNotNull);
          expect(theme.extension<BsMedidas>(), isNotNull);
          expect(theme.textTheme.bodyMedium?.fontFamily, BsFuentes.sans);
          expect(theme.brightness, Brightness.light);
          expect(theme.colorScheme.primary, BsPaleta.claro.marca);
          await container
              .read(themePreferenceProvider.notifier)
              .select(AppThemePreference.dark);
          await tester.pumpAndSettle();
          theme = Theme.of(tester.element(find.byType(VesselOverviewPage)));
          expect(theme.brightness, Brightness.dark);
          expect(theme.colorScheme.primary, BsPaleta.oscuro.marca);
          expect(tester.takeException(), isNull);
        } finally {
          await tester.pumpWidget(const SizedBox.shrink());
          await cerrar();
        }
      });
    });
  });

  group('el inicio', () {
    testWidgets('una sola acción, los recientes y los perfiles; abrir un reciente va al Plano',
        (tester) async {
      await tester.runAsync(() async {
        await abrir();
        try {
          final parsed = BaplieParserService().parse(_planDeCarga);
          final profile = VesselProfile.proposeFrom(parsed)
              .copyWith(origin: VesselProfileOrigin.declaredByUser);
          final voyage = parsed
              .withGeometry(profile.geometry, portOfCall: 'GTSTC')
              .copyWith(vesselProfileKey: profile.key);
          await store.repository.saveProfile(profile);
          await store.repository.saveVoyage(voyage);
          await pumpApp(tester);
          expect(container.read(voyageUiStateProvider), isA<SinViaje>());
          expect(find.text('Abre un plano de estiba'), findsOneWidget);
          expect(find.byKey(const ValueKey('select-file')), findsOneWidget);
          expect(find.byType(FloatingActionButton), findsNothing,
              reason: 'una sola acción para abrir (T-98, con01)');
          expect(find.byTooltip('Cargar archivo BAPLIE'), findsNothing);
          expect(find.text('Recientes en este dispositivo'), findsOneWidget);
          expect(find.byKey(ValueKey('inicio-reciente-${voyage.id}')), findsOneWidget);
          expect(find.textContaining('Escala GTSTC'), findsOneWidget);
          expect(find.text('Perfiles guardados (1)'), findsOneWidget);
          expect(find.byKey(const ValueKey('cloud-operations')), findsNothing,
              reason: 'sin cuenta no hay nube');
          expect(tester.takeException(), isNull);

          await tester.tap(find.byKey(ValueKey('inicio-reciente-${voyage.id}')));
          await tester.pumpAndSettle();
          expect(container.read(voyageUiStateProvider), isA<Publicado>());
          expect(find.byType(BayPlanView), findsOneWidget,
              reason: 'el plano es la primera pestaña (10.2 a)');
          expect(tester.takeException(), isNull);
        } finally {
          await tester.pumpWidget(const SizedBox.shrink());
          await cerrar();
        }
      });
    });
  });

  group('el previo', () {
    testWidgets('un buque nuevo abre en previo: banda, sin evaluar, sin modos ni exportar',
        (tester) async {
      await tester.runAsync(() async {
        await abrir();
        try {
          await pumpApp(tester);
          await tester.tap(find.byKey(const ValueKey('select-file')));
          await tester.pumpAndSettle();

          final ui = container.read(voyageUiStateProvider);
          expect(ui, isA<Previo>());
          final previo = ui as Previo;
          expect(previo.motivo, PreviewReason.buqueNuevo);
          expect(previo.portOfCall, 'GTSTC');
          expect(previo.fileName, 'BUQUE_MANUAL.edi');
          expect(
              find.text('Plano sin confirmar: perfil propuesto desde el archivo. '
                  'Escala propuesta GTSTC.'),
              findsOneWidget);
          expect(find.byKey(const ValueKey('preview-banner')), findsOneWidget);
          expect(find.text(sinEvaluarHastaConfirmar), findsOneWidget);
          expect(find.byType(BayPlanView), findsOneWidget);
          final n = notifier();
          expect(n.publishedVoyage, isNull);
          expect(n.publishedProfile, isNull, reason: 'sin perfil no se evalúa');
          expect(n.visibleVoyage!.portOfCall, isNull);
          expect(n.visibleVoyage!.geometry, isNotNull);
          expect(offersDischarge(n.visibleVoyage!), isFalse);
          expect((await store.repository.getAllVoyages()).getOrElse(() => []),
              isEmpty, reason: 'el previo no guarda nada');
          expect((await store.repository.getAllProfiles()).getOrElse(() => []),
              isEmpty);

          // En la Lista: sin listado de la agencia ni salida; exportar avisa.
          await tester.tap(find.text('Lista'));
          await tester.pumpAndSettle();
          expect(find.byKey(const ValueKey('open-export-list')), findsNothing);
          // Exportar vive en «Más» (DESIGN.md 8); en previo avisa.
          await tester.tap(find.text('Más'));
          await tester.pumpAndSettle();
          await tester.tap(find.byKey(const ValueKey('export-preview')));
          await tester.pumpAndSettle();
          expect(find.text(exportarSinConfirmar), findsOneWidget);

          // En Alertas: «sin evaluar», nunca «no hay resultados».
          await tester.ensureVisible(find.text('Alertas de estiba'));
          await tester.tap(find.text('Alertas de estiba'));
          await tester.pumpAndSettle();
          expect(find.byKey(const ValueKey('alerts-sin-evaluar')), findsOneWidget);
          expect(find.textContaining('No hay resultados para mostrar'), findsNothing);
          expect(tester.takeException(), isNull);
        } finally {
          await tester.pumpWidget(const SizedBox.shrink());
          await cerrar();
        }
      });
    });

    testWidgets('Confirmar en la banda publica, guarda y se queda en el Plano',
        (tester) async {
      await tester.runAsync(() async {
        await abrir();
        try {
          await pumpApp(tester);
          await tester.tap(find.byKey(const ValueKey('select-file')));
          await tester.pumpAndSettle();
          expect(container.read(voyageUiStateProvider), isA<Previo>());
          await tester.tap(find.text('Confirmar'));
          await tester.pumpAndSettle();
          expect(find.byType(VesselGeometryPage), findsOneWidget);
          // A 360 dp los parámetros están debajo del pliegue: se desplaza.
          final lista = find.byType(Scrollable).first;
          await tester.scrollUntilVisible(
              find.byKey(const ValueKey('geometry-no-limit')), 300,
              scrollable: lista);
          await tester.ensureVisible(find.byKey(const ValueKey('geometry-no-limit')));
          await tester.pumpAndSettle();
          await tester.tap(find.byKey(const ValueKey('geometry-no-limit')));
          await tester.pumpAndSettle();
          await tester.scrollUntilVisible(
              find.byKey(const ValueKey('geometry-confirm')), 300,
              scrollable: lista);
          await tester.ensureVisible(find.byKey(const ValueKey('geometry-confirm')));
          await tester.pumpAndSettle();
          expect(find.text('Confirmar y ver el plano'), findsOneWidget);
          expect(
              tester.widget<FilledButton>(find.byKey(const ValueKey('geometry-confirm'))).enabled,
              isTrue,
              reason: 'con «No lo tengo» marcado se puede confirmar');
          await tester.tap(find.byKey(const ValueKey('geometry-confirm')));
          await tester.pumpAndSettle();
          // Guardar el perfil y el viaje es E/S real: se espera fuera del reloj
          // de los widgets, como en recent_voyages_test.
          for (var intento = 0;
              intento < 500 && notifier().isPreview;
              intento++) {
            await Future<void>.delayed(const Duration(milliseconds: 10));
          }
          await tester.pumpAndSettle();
          expect(find.byType(VesselGeometryPage), findsNothing,
              reason: 'confirmar cierra los parámetros; si queda un aviso, dice el motivo');

          expect(container.read(voyageUiStateProvider), isA<Publicado>());
          expect(find.byKey(const ValueKey('preview-banner')), findsNothing);
          expect(find.text(sinEvaluarHastaConfirmar), findsNothing);
          expect(find.byType(BayPlanView), findsOneWidget, reason: 'se queda en el Plano');
          final n = notifier();
          expect(n.publishedVoyage!.portOfCall, 'GTSTC');
          expect(n.publishedProfile, isNotNull);
          expect((await store.repository.getAllVoyages()).getOrElse(() => []),
              hasLength(1));
          expect((await store.repository.getAllProfiles()).getOrElse(() => []),
              hasLength(1));
          expect(tester.takeException(), isNull);
        } finally {
          await tester.pumpWidget(const SizedBox.shrink());
          await cerrar();
        }
      });
    });

    testWidgets('cancelar en los parámetros deja el previo; descartar pregunta y vuelve al inicio',
        (tester) async {
      await tester.runAsync(() async {
        await abrir();
        try {
          await pumpApp(tester);
          await tester.tap(find.byKey(const ValueKey('select-file')));
          await tester.pumpAndSettle();
          await tester.tap(find.text('Confirmar'));
          await tester.pumpAndSettle();
          await tester.tap(find.byKey(const ValueKey('geometry-cancel')));
          await tester.pumpAndSettle();
          expect(container.read(voyageUiStateProvider), isA<Previo>(),
              reason: 'cancelar deja el plano a la vista, sin operar');
          expect(find.byKey(const ValueKey('preview-banner')), findsOneWidget);

          // «Cerrar el plano» está en «Más» (DESIGN.md 8).
          await tester.tap(find.text('Más'));
          await tester.pumpAndSettle();
          await tester.tap(find.byKey(const ValueKey('mas-cerrar')));
          await tester.pumpAndSettle();
          expect(find.text('¿Descartar el plano sin confirmar?'), findsOneWidget);
          await tester.tap(find.byKey(const ValueKey('preview-keep')));
          await tester.pumpAndSettle();
          expect(container.read(voyageUiStateProvider), isA<Previo>());
          await tester.tap(find.text('Más'));
          await tester.pumpAndSettle();
          await tester.tap(find.byKey(const ValueKey('mas-cerrar')));
          await tester.pumpAndSettle();
          await tester.tap(find.byKey(const ValueKey('preview-discard')));
          await tester.pumpAndSettle();
          expect(container.read(voyageUiStateProvider), isA<SinViaje>());
          expect(find.text('Abre un plano de estiba'), findsOneWidget);
          expect((await store.repository.getAllVoyages()).getOrElse(() => []),
              isEmpty);
          expect(tester.takeException(), isNull);
        } finally {
          await tester.pumpWidget(const SizedBox.shrink());
          await cerrar();
        }
      });
    });
  });

  group('la regla estricta de publicación directa (DESIGN.md 7.2)', () {
    setUp(() => abrir());
    tearDown(() => cerrar());

    test('perfil que cubre la carga y la escala de siempre: abre publicado', () async {
      await publicarYCerrar();
      final n = notifier();
      final segunda = await n.parseBaplieContent(_planDeCarga, fileName: 'carga2.edi');
      expect(segunda.success, isTrue);
      expect(segunda.preview, isFalse);
      expect(segunda.needsGeometry, isFalse);
      expect(n.isPreview, isFalse);
      expect(n.publishedVoyage!.portOfCall, 'GTSTC');
      expect(n.publishedProfile, isNotNull);
      expect((await store.repository.getAllVoyages()).getOrElse(() => []),
          hasLength(2));
    });

    test('otra escala propuesta abre en previo aunque el perfil cubra', () async {
      await publicarYCerrar();
      final n = notifier();
      final otra = _planDeCarga.replaceAll('GTSTC', 'USHOU').replaceAll('LOC+11+USHOU', 'LOC+11+JMKIN');
      final result = await n.parseBaplieContent(otra, fileName: 'otra.edi');
      expect(result.preview, isTrue);
      expect(n.previewReason, PreviewReason.escalaPorDecidir);
      expect(n.previewPortOfCall, 'USHOU');
      expect(n.publishedVoyage, isNull);
      expect(n.visibleVoyage, isNotNull);
    });

    test('hallazgo 5: un plano de llegada propone el puerto de salida y abre en previo', () async {
      await publicarYCerrar();
      // El historial del dispositivo apunta a otra escala: la propuesta vuelve
      // a ser el puerto de salida del archivo (PAMIT), no GTSTC.
      await store.repository.setLastConfirmedPortOfCall('USHOU');
      final n = notifier();
      final result = await n.parseBaplieContent(_planDeLlegada, fileName: 'llegada.edi');
      expect(result.preview, isTrue);
      expect(n.previewReason, PreviewReason.escalaPorDecidir);
      expect(n.previewPortOfCall, 'PAMIT');
      final ui = container.read(voyageUiStateProvider) as Previo;
      expect(ui.texto, 'El archivo sale de PAMIT rumbo a GTSTC: confirma la escala.');
      expect(n.publishedVoyage, isNull);
      // Confirmar con la escala de llegada publica como plano de llegada.
      expect(
          await n.confirmGeometry(n.currentProfile!.geometry,
              portOfCall: 'GTSTC', sourceKind: OperationSourceKind.arrivalBaplie),
          isNull);
      expect(n.publishedVoyage!.portOfCall, 'GTSTC');
      expect(offersDischarge(n.publishedVoyage!), isTrue);
    });

    test('con el historial de la misma escala, la llegada abre publicada', () async {
      await publicarYCerrar();
      final n = notifier();
      final result = await n.parseBaplieContent(_planDeLlegada, fileName: 'llegada.edi');
      expect(result.preview, isFalse, reason: 'GTSTC es la última escala de este buque');
      expect(n.publishedVoyage!.portOfCall, 'GTSTC');
    });

    test('perfil que no cubre la carga abre en previo con la geometría ampliada', () async {
      await publicarYCerrar();
      final n = notifier();
      final masAlta = _planDeCarga.replaceAll('0020184', '0020386');
      final result = await n.parseBaplieContent(masAlta, fileName: 'alta.edi');
      expect(result.preview, isTrue);
      expect(n.previewReason, PreviewReason.fueraDelPerfil);
      expect(n.outsideProfilePositions, ['0020386']);
      expect(n.visibleVoyage!.geometry!.coversAll(n.visibleVoyage!.stowagePositions), isTrue,
          reason: 'el previo dibuja toda la carga');
      expect((container.read(voyageUiStateProvider) as Previo).texto,
          'El perfil guardado no cubre esta carga: revisa la ampliación.');
    });

    test('descartar el previo vuelve al viaje que estaba publicado', () async {
      final n = notifier();
      await n.parseBaplieContent(_planDeCarga, fileName: 'carga.edi');
      await n.confirmGeometry(n.currentProfile!.geometry,
          portOfCall: 'GTSTC', sourceKind: OperationSourceKind.loadingBaplie);
      final publicado = n.publishedVoyage!;
      final perfil = n.publishedProfile;
      final otra = _planDeCarga.replaceAll('GTSTC', 'USHOU');
      expect((await n.parseBaplieContent(otra, fileName: 'otra.edi')).preview, isTrue);
      expect(n.publishedVoyage, publicado, reason: 'lo publicado sigue siendo lo de antes');
      expect(n.publishedProfile, isNull);
      expect(n.visibleVoyage, isNot(publicado));
      n.discardPreview();
      expect(n.isPreview, isFalse);
      expect(n.visibleVoyage, publicado);
      expect(n.publishedProfile, perfil);
      expect(container.read(voyageUiStateProvider), isA<Publicado>());
    });

    test('un buque nuevo sin escala en el archivo abre en previo y lo dice', () async {
      final n = notifier();
      final result = await n.parseBaplieContent(profileTestEdi, fileName: 'sin_puertos.edi');
      expect(result.preview, isTrue);
      expect(n.previewReason, PreviewReason.buqueNuevo);
      expect(n.previewPortOfCall, isNull);
      expect((container.read(voyageUiStateProvider) as Previo).texto,
          'Plano sin confirmar: perfil propuesto desde el archivo. El archivo no declara la escala.');
    });

    test('un homónimo abre en previo y Confirmar pide elegir el buque', () async {
      await publicarYCerrar();
      final n = notifier();
      final sinId = _planDeCarga.replaceAll('9000003:146:11:', ':::');
      final result = await n.parseBaplieContent(sinId, fileName: 'homonimo.edi');
      expect(result.needsIdentity, isTrue);
      expect(n.isPreview, isTrue);
      expect(n.previewReason, PreviewReason.homonimo);
      expect(n.identityCandidates, hasLength(1));
      final ui = container.read(voyageUiStateProvider) as Previo;
      expect(ui.identidadPendiente, isTrue);
      expect(ui.texto, 'Hay perfiles con el mismo nombre: confirma el buque antes de operar.');
    });
  });
}
