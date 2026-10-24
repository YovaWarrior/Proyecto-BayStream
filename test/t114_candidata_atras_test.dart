// T-114 · Candidata del piloto (SPRINT-4.md 10.28): Atrás en Android como
// dice DESIGN.md 8. Primero cierra lo abierto (la hoja «Más», la hoja del
// detalle, el menú del zoom, el detalle del panel lateral); en la raíz del
// viaje, con un previo pregunta si descartarlo; con el viaje publicado vuelve
// al inicio solo con dos toques seguidos: un toque por error no saca a nadie
// del plano. En Windows y en la Web no gobierna nada.
//
// Corrección tras la aceptación de Codex (10.29, H1): la ventana de 2 s se
// cuenta desde el primer toque con su propio reloj, la advertencia se ve
// aunque haya otro aviso en pantalla (el de 6 s con «Deshacer» de cada
// registro) y nunca se cierra un aviso que no sea el primero de la cola. Los
// casos combinados van en «la ventana de Atrás con otros avisos en pantalla».
//
// Los archivos son sintéticos: BUQUE MANUAL, con dos cajas en la bahía 002.
import 'dart:io';

import 'package:baystream/core/app.dart';
import 'package:baystream/features/vessel/data/repositories/local_vessel_repository_impl.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/presentation/pages/vessel_overview_page.dart';
import 'package:baystream/features/vessel/presentation/providers/movement_log_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/plano_providers.dart';
import 'package:baystream/features/vessel/presentation/providers/vessel_providers.dart';
import 'package:baystream/features/vessel/presentation/providers/voyage_ui_state.dart';
import 'package:baystream/features/vessel/presentation/widgets/navegacion_del_viaje.dart';
import 'package:flutter/foundation.dart';
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

  Future<void> abrir() async {
    store = await testProfileStore();
    container = ProviderContainer(overrides: [
      movementLogRepositoryProvider.overrideWith((ref) async => T74MemoryLog()),
      vesselRepositoryProvider.overrideWithValue(ParserOnlyRepository()),
      localVesselRepositoryProvider.overrideWith((ref) async => store.repository),
      voyageNotifierProvider.overrideWith(() => _ReplayNotifier(_planDeCarga)),
    ]);
  }

  Future<void> cerrar() async {
    container.dispose();
    await store.repository.close();
    await store.directory.delete(recursive: true);
  }

  /// Una prueba en un cliente: Android (el muelle, con botón Atrás) o
  /// Windows. La plataforma se restablece dentro del cuerpo, que es lo que
  /// el arnés de pruebas comprueba al terminar.
  Future<void> en(WidgetTester tester, TargetPlatform plataforma,
      Future<void> Function() cuerpo) async {
    await tester.runAsync(() async {
      debugDefaultTargetPlatformOverride = plataforma;
      await abrir();
      try {
        await cuerpo();
      } finally {
        await tester.pumpWidget(const SizedBox.shrink());
        await cerrar();
        debugDefaultTargetPlatformOverride = null;
      }
    });
  }

  VoyageNotifier notifier() => container.read(voyageNotifierProvider.notifier);

  VoyageUiState estado() => container.read(voyageUiStateProvider);

  /// Deja el plan en previo, como cuando se abre un buque nuevo.
  Future<void> enPrevio() async {
    final n = notifier();
    final leido = await n.parseBaplieContent(_planDeCarga, fileName: 'carga.edi');
    expect(leido.preview, isTrue);
    expect(n.isPreview, isTrue);
  }

  /// Publica el plan de carga confirmando el perfil y la escala GTSTC, como
  /// lo haría la oficina la primera vez.
  Future<void> publicado() async {
    await enPrevio();
    final n = notifier();
    expect(
        await n.confirmGeometry(n.currentProfile!.geometry,
            portOfCall: 'GTSTC', sourceKind: OperationSourceKind.loadingBaplie),
        isNull);
    expect(n.isPreview, isFalse);
    expect(n.publishedVoyage!.portOfCall, 'GTSTC');
  }

  Future<void> pumpApp(WidgetTester tester,
      {Size tamano = const Size(360, 800)}) async {
    tester.view.physicalSize = tamano;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(UncontrolledProviderScope(
        container: container, child: const BayStreamApp()));
    await tester.pumpAndSettle();
  }

  /// El botón Atrás del sistema. Devuelve si la app lo atendió.
  Future<bool> atras(WidgetTester tester) async {
    final atendido = await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    return atendido;
  }

  final aviso = find.byKey(const ValueKey('aviso-de-atras'));

  group('lo abierto se cierra primero', () {
    testWidgets('la hoja «Más»: Atrás la cierra y el viaje sigue', (tester) async {
      await en(tester, TargetPlatform.android, () async {
        await publicado();
        await pumpApp(tester);
        expect(estado(), isA<Publicado>());
        await tester.tap(find.byKey(const ValueKey('destino-mas')));
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey('hoja-mas')), findsOneWidget);
        expect(await atras(tester), isTrue);
        expect(find.byKey(const ValueKey('hoja-mas')), findsNothing);
        expect(estado(), isA<Publicado>());
        expect(aviso, findsNothing, reason: 'cerrar la hoja no es salir');
        expect(find.byType(VesselOverviewPage), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    });

    testWidgets('la hoja del detalle en el teléfono: Atrás la cierra', (tester) async {
      await en(tester, TargetPlatform.android, () async {
        await publicado();
        await pumpApp(tester);
        final celda = find.byKey(const ValueKey('cell-1-82'));
        expect(celda, findsOneWidget);
        await tester.ensureVisible(celda);
        await tester.pumpAndSettle();
        await tester.tap(celda);
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey('detalle-contenedor')), findsOneWidget);
        expect(await atras(tester), isTrue);
        expect(find.byKey(const ValueKey('detalle-contenedor')), findsNothing);
        expect(estado(), isA<Publicado>());
        expect(aviso, findsNothing);
        expect(tester.takeException(), isNull);
      });
    });

    testWidgets('el menú del zoom no es una ruta: Atrás lo cierra', (tester) async {
      await en(tester, TargetPlatform.android, () async {
        await publicado();
        await pumpApp(tester);
        final chip = find.byKey(const ValueKey('plan-zoom-toggle'));
        await tester.ensureVisible(chip);
        await tester.pumpAndSettle();
        await tester.tap(chip);
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey('plan-zoom-in')), findsOneWidget);
        expect(container.read(cerrablesDeAtrasProvider), 1,
            reason: 'el menú abierto se anota para Atrás');
        expect(await atras(tester), isTrue);
        expect(find.byKey(const ValueKey('plan-zoom-in')), findsNothing);
        expect(container.read(cerrablesDeAtrasProvider), 0);
        expect(estado(), isA<Publicado>());
        expect(aviso, findsNothing);
        // Cerrado desde el chip, también se olvida.
        await tester.tap(chip);
        await tester.pumpAndSettle();
        expect(container.read(cerrablesDeAtrasProvider), 1);
        await tester.tap(chip);
        await tester.pumpAndSettle();
        expect(container.read(cerrablesDeAtrasProvider), 0);
        expect(tester.takeException(), isNull);
      });
    });

    testWidgets('el detalle en el panel lateral: Atrás lo cierra antes que la raíz',
        (tester) async {
      await en(tester, TargetPlatform.android, () async {
        await publicado();
        await pumpApp(tester, tamano: const Size(1300, 900));
        expect(find.byKey(const ValueKey('panel-lateral')), findsOneWidget);
        final celda = find.byKey(const ValueKey('cell-1-82'));
        await tester.tap(celda);
        await tester.pumpAndSettle();
        expect(container.read(celdaSeleccionadaProvider), isNotNull);
        expect(find.byKey(const ValueKey('detalle-contenedor')), findsOneWidget);
        expect(await atras(tester), isTrue);
        expect(container.read(celdaSeleccionadaProvider), isNull);
        expect(find.byKey(const ValueKey('detalle-contenedor')), findsNothing);
        expect(find.textContaining('Toca una celda del plano'), findsOneWidget);
        expect(estado(), isA<Publicado>());
        expect(aviso, findsNothing);
        expect(tester.takeException(), isNull);
      });
    });
  });

  group('la raíz del viaje', () {
    testWidgets('con un previo pregunta; «Seguir mirando» y Atrás sobre la pregunta '
        'lo dejan; «Descartar» vuelve al inicio', (tester) async {
      await en(tester, TargetPlatform.android, () async {
        await enPrevio();
        await pumpApp(tester);
        expect(estado(), isA<Previo>());
        expect(await atras(tester), isTrue);
        expect(find.text('¿Descartar el plano sin confirmar?'), findsOneWidget);
        await tester.tap(find.byKey(const ValueKey('preview-keep')));
        await tester.pumpAndSettle();
        expect(estado(), isA<Previo>());
        expect(find.byKey(const ValueKey('preview-banner')), findsOneWidget);
        // Atrás sobre la pregunta la cierra: es seguir mirando.
        expect(await atras(tester), isTrue);
        expect(find.text('¿Descartar el plano sin confirmar?'), findsOneWidget);
        expect(await atras(tester), isTrue);
        expect(find.text('¿Descartar el plano sin confirmar?'), findsNothing);
        expect(estado(), isA<Previo>());
        expect(aviso, findsNothing, reason: 'con un previo no hay doble toque');
        // Descartar sí vuelve al inicio, sin guardar nada.
        expect(await atras(tester), isTrue);
        await tester.tap(find.byKey(const ValueKey('preview-discard')));
        await tester.pumpAndSettle();
        expect(estado(), isA<SinViaje>());
        expect(find.text('Abre un plano de estiba'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    });

    testWidgets('publicado: un toque avisa y no sale; dos toques seguidos vuelven '
        'al inicio, y el viaje sigue en los recientes', (tester) async {
      await en(tester, TargetPlatform.android, () async {
        await publicado();
        await pumpApp(tester);
        expect(estado(), isA<Publicado>());
        // Un toque por error: el aviso, y el plano sigue.
        expect(await atras(tester), isTrue);
        expect(aviso, findsOneWidget);
        expect(find.text(AtrasDelViaje.avisoDeSalida), findsOneWidget);
        expect(estado(), isA<Publicado>());
        expect(find.byKey(const ValueKey('barra-del-viaje')), findsOneWidget);
        // Pasada la ventana, otro toque solo vuelve a avisar.
        await Future<void>.delayed(
            AtrasDelViaje.ventana + const Duration(seconds: 1));
        await tester.pumpAndSettle();
        expect(aviso, findsNothing);
        expect(await atras(tester), isTrue);
        expect(aviso, findsOneWidget);
        expect(estado(), isA<Publicado>());
        // Dos toques seguidos: al inicio, con el viaje entre los recientes.
        expect(await atras(tester), isTrue);
        expect(estado(), isA<SinViaje>());
        expect(find.text('Abre un plano de estiba'), findsOneWidget);
        expect(find.textContaining('BUQUE MANUAL'), findsWidgets,
            reason: 'el viaje publicado sigue guardado');
        expect(aviso, findsNothing, reason: 'el aviso se apaga al salir');
        expect(tester.takeException(), isNull);
      });
    });

    testWidgets('dos toques nada más abrir el plano tampoco rompen nada',
        (tester) async {
      await en(tester, TargetPlatform.android, () async {
        await publicado();
        await pumpApp(tester);
        // Sin esperar a que la operación termine de construirse.
        expect(await atras(tester), isTrue);
        expect(await atras(tester), isTrue);
        expect(estado(), isA<SinViaje>());
        await Future<void>.delayed(const Duration(milliseconds: 300));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    });

    testWidgets('en el inicio, Atrás no se atiende: sale de la app como siempre',
        (tester) async {
      await en(tester, TargetPlatform.android, () async {
        await pumpApp(tester);
        expect(estado(), isA<SinViaje>());
        expect(await atras(tester), isFalse);
        expect(find.byType(AtrasDelViaje), findsNothing);
        expect(tester.takeException(), isNull);
      });
    });
  });

  group('la ventana de Atrás con otros avisos en pantalla', () {
    /// Un aviso como el del muelle, mostrado desde la página del viaje: el
    /// de un registro dura 6 s y lleva «Deshacer»; el de «cargado
    /// correctamente», 4 s.
    void mostrarAviso(WidgetTester tester, String texto, Duration duracion,
        {bool deshacer = false}) {
      final contexto = tester.element(find.byType(VesselOverviewPage));
      ScaffoldMessenger.of(contexto).showSnackBar(SnackBar(
        key: ValueKey<String>('aviso-de-prueba-${duracion.inSeconds}'),
        content: Text(texto),
        duration: duracion,
        action: deshacer
            ? SnackBarAction(label: 'Deshacer', onPressed: () {})
            : null,
      ));
    }

    final avisoDe6 = find.byKey(const ValueKey('aviso-de-prueba-6'));
    final avisoDe4 = find.byKey(const ValueKey('aviso-de-prueba-4'));

    testWidgets(
        'con un aviso de movimiento de 6 s en pantalla, la advertencia se ve a '
        'la vez, «Deshacer» sigue, y dos toques seguidos salen sin excepciones',
        (tester) async {
      await en(tester, TargetPlatform.android, () async {
        await publicado();
        await pumpApp(tester);
        mostrarAviso(tester, 'Descargado · TEST0000001 · 002-01-82',
            const Duration(seconds: 6),
            deshacer: true);
        await tester.pumpAndSettle();
        expect(avisoDe6, findsOneWidget);
        // El primer toque: la advertencia, encima del viaje, con el aviso
        // del movimiento todavía a la vista y con su «Deshacer».
        expect(await atras(tester), isTrue);
        expect(aviso, findsOneWidget);
        expect(find.text(AtrasDelViaje.avisoDeSalida), findsOneWidget);
        expect(avisoDe6, findsOneWidget,
            reason: 'la advertencia no aparta el aviso del movimiento');
        expect(find.text('Deshacer'), findsOneWidget);
        expect(estado(), isA<Publicado>());
        // La advertencia va arriba y el aviso abajo: no se tapan.
        final arriba = tester.getRect(
            find.descendant(of: aviso, matching: find.byType(Material)).first);
        final abajo = tester.getRect(
            find.descendant(of: avisoDe6, matching: find.byType(Material)).first);
        expect(arriba.bottom, lessThan(abajo.top));
        // El segundo toque, dentro de la ventana: al inicio, sin tocar la
        // cola de avisos (antes, `close()` sobre un aviso que no era el
        // primero lanzaba `_snackBars.first == controller`).
        expect(await atras(tester), isTrue);
        expect(estado(), isA<SinViaje>());
        expect(find.text('Abre un plano de estiba'), findsOneWidget);
        expect(aviso, findsNothing);
        expect(tester.takeException(), isNull);
      });
    });

    testWidgets(
        'con un aviso de 4 s y otro de 6 s en cola, dos toques separados por '
        'más de 2 s no salen: la advertencia vence y vuelve a avisar',
        (tester) async {
      await en(tester, TargetPlatform.android, () async {
        await publicado();
        await pumpApp(tester);
        mostrarAviso(tester, 'Archivo "carga.edi" cargado correctamente',
            const Duration(seconds: 4));
        mostrarAviso(tester, 'Descargado · TEST0000001 · 002-01-82',
            const Duration(seconds: 6),
            deshacer: true);
        await tester.pumpAndSettle();
        expect(avisoDe4, findsOneWidget, reason: 'el de 4 s va primero');
        expect(await atras(tester), isTrue);
        expect(aviso, findsOneWidget);
        expect(estado(), isA<Publicado>());
        // Pasados 3 s de reloj, la ventana venció aunque el aviso de 4 s
        // siga o ya haya dado paso al de 6 s: el toque vuelve a avisar.
        await Future<void>.delayed(const Duration(seconds: 3));
        await tester.pumpAndSettle();
        expect(aviso, findsNothing, reason: 'la advertencia dura 2 s');
        expect(await atras(tester), isTrue);
        expect(aviso, findsOneWidget);
        expect(estado(), isA<Publicado>(),
            reason: 'dos toques separados por más de 2 s no cierran el viaje');
        expect(find.byType(VesselOverviewPage), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    });

    testWidgets(
        'con un aviso de 4 s y otro de 6 s en cola, dos toques dentro de 2 s '
        'salen, sin excepciones y sin cerrar un aviso que no era el primero',
        (tester) async {
      await en(tester, TargetPlatform.android, () async {
        await publicado();
        await pumpApp(tester);
        mostrarAviso(tester, 'Archivo "carga.edi" cargado correctamente',
            const Duration(seconds: 4));
        mostrarAviso(tester, 'Descargado · TEST0000001 · 002-01-82',
            const Duration(seconds: 6),
            deshacer: true);
        await tester.pumpAndSettle();
        expect(await atras(tester), isTrue);
        expect(aviso, findsOneWidget);
        expect(avisoDe4, findsOneWidget);
        expect(await atras(tester), isTrue);
        expect(estado(), isA<SinViaje>());
        expect(find.text('Abre un plano de estiba'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    });

    testWidgets('la advertencia no recibe toques y se anuncia al lector de pantalla',
        (tester) async {
      await en(tester, TargetPlatform.android, () async {
        await publicado();
        final semantica = tester.ensureSemantics();
        await pumpApp(tester);
        expect(await atras(tester), isTrue);
        expect(aviso, findsOneWidget);
        expect(
            tester.getSemantics(find.text(AtrasDelViaje.avisoDeSalida)),
            matchesSemantics(
                label: AtrasDelViaje.avisoDeSalida, isLiveRegion: true));
        // Lo que está debajo de la advertencia sigue respondiendo: el toque
        // la atraviesa (la barra de la marca o la barra superior están ahí).
        expect(
            tester.widget<IgnorePointer>(find.ancestor(
                of: find.text(AtrasDelViaje.avisoDeSalida),
                matching: find.byType(IgnorePointer)).first).ignoring,
            isTrue);
        semantica.dispose();
        expect(tester.takeException(), isNull);
      });
    });
  });

  // Segunda corrección (10.31, O1): Codex mostró que, tras el primer toque,
  // abrir el zoom o el detalle y cerrarlo con Atrás dejaba la ventana abierta,
  // y otro toque dentro de los mismos 2 s salía del viaje. Ahora lo que se
  // abre o se cierra en medio cancela la ventana.
  group('lo que se abre o se cierra en medio cancela la ventana', () {
    testWidgets(
        'el zoom (Codex): se abre, Atrás lo cierra y el siguiente toque vuelve '
        'a advertir; dos toques seguidos en la raíz siguen saliendo',
        (tester) async {
      await en(tester, TargetPlatform.android, () async {
        await publicado();
        await pumpApp(tester);
        final chip = find.byKey(const ValueKey('plan-zoom-toggle'));
        await tester.ensureVisible(chip);
        await tester.pumpAndSettle();
        expect(await atras(tester), isTrue);
        expect(aviso, findsOneWidget);
        await tester.tap(chip);
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey('plan-zoom-in')), findsOneWidget);
        expect(aviso, findsNothing, reason: 'abrir el zoom cancela la ventana');
        expect(await atras(tester), isTrue);
        expect(find.byKey(const ValueKey('plan-zoom-in')), findsNothing);
        expect(aviso, findsNothing);
        // Dentro de los 2 s del primer toque: advierte de nuevo y no sale.
        expect(await atras(tester), isTrue);
        expect(aviso, findsOneWidget);
        expect(estado(), isA<Publicado>());
        // Y dos toques seguidos en la raíz salen, como siempre.
        expect(await atras(tester), isTrue);
        expect(estado(), isA<SinViaje>());
        expect(tester.takeException(), isNull);
      });
    });

    testWidgets(
        'el detalle en el panel lateral (Codex): se elige una celda, Atrás '
        'cierra el detalle y el siguiente toque vuelve a advertir',
        (tester) async {
      await en(tester, TargetPlatform.android, () async {
        await publicado();
        await pumpApp(tester, tamano: const Size(1300, 900));
        expect(await atras(tester), isTrue);
        expect(aviso, findsOneWidget);
        await tester.tap(find.byKey(const ValueKey('cell-1-82')));
        await tester.pumpAndSettle();
        expect(container.read(celdaSeleccionadaProvider), isNotNull);
        expect(aviso, findsNothing,
            reason: 'abrir el detalle cancela la ventana');
        expect(await atras(tester), isTrue);
        expect(container.read(celdaSeleccionadaProvider), isNull);
        expect(await atras(tester), isTrue);
        expect(aviso, findsOneWidget);
        expect(estado(), isA<Publicado>(),
            reason: 'el toque tras cerrar el detalle no sale del viaje');
        expect(tester.takeException(), isNull);
      });
    });

    testWidgets(
        'una hoja: la hoja «Más» se abre encima, Atrás la cierra y el '
        'siguiente toque vuelve a advertir', (tester) async {
      await en(tester, TargetPlatform.android, () async {
        await publicado();
        await pumpApp(tester);
        expect(await atras(tester), isTrue);
        expect(aviso, findsOneWidget);
        await tester.tap(find.byKey(const ValueKey('destino-mas')));
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey('hoja-mas')), findsOneWidget);
        expect(aviso, findsNothing, reason: 'la hoja encima cancela la ventana');
        expect(await atras(tester), isTrue);
        expect(find.byKey(const ValueKey('hoja-mas')), findsNothing);
        expect(await atras(tester), isTrue);
        expect(aviso, findsOneWidget);
        expect(estado(), isA<Publicado>());
        expect(tester.takeException(), isNull);
      });
    });
  });

  group('fuera de Android', () {
    testWidgets('en Windows no gobierna nada: Atrás no se atiende y nada cambia',
        (tester) async {
      await en(tester, TargetPlatform.windows, () async {
        await publicado();
        await pumpApp(tester, tamano: const Size(1300, 900));
        expect(find.byType(AtrasDelViaje), findsOneWidget);
        expect(find.byType(PopScope<Object?>), findsNothing,
            reason: 'sin botón Atrás del sistema no hay nada que gobernar');
        expect(await atras(tester), isFalse);
        expect(estado(), isA<Publicado>());
        expect(aviso, findsNothing);
        expect(tester.takeException(), isNull);
      });
    });
  });
}
