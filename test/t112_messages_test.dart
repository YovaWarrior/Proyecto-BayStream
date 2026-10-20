import 'package:baystream/core/errors/exceptions.dart';
import 'package:baystream/core/errors/failures.dart';
import 'package:baystream/features/vessel/data/repositories/firebase_session_repository.dart';
import 'package:baystream/features/vessel/domain/entities/movement.dart';
import 'package:baystream/features/vessel/domain/repositories/operation_sync_repository.dart';
import 'package:baystream/features/vessel/presentation/formatters/vessel_error_message.dart';
import 'package:baystream/features/vessel/presentation/providers/loading_operation_provider.dart';
import 'package:baystream/features/vessel/presentation/widgets/hatch_operation_controls.dart';
import 'package:baystream/features/vessel/presentation/widgets/sync_status_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/t82_fixture.dart';

/// T-112 · Una muestra de los 218 mensajes del censo: causa y acción
/// explícitas, el segmento en los de lectura, y nada en inglés ni técnico en
/// pantalla.
void main() {
  group('M001, M004 y M006 · el formateador común', () {
    test('M001: el error desconocido dice qué operación falló y qué hacer', () {
      final message =
          vesselErrorMessage(StateError('interno'), null, 'abrir el viaje');
      expect(message, startsWith('No se pudo abrir el viaje por un error interno'));
      expect(message, contains('el detalle técnico quedó en el registro'));
      expect(message, contains('Inténtalo de nuevo'));
      expect(message, isNot(contains('Bad state')));
      expect(vesselErrorMessage(StateError('interno')), unknownVesselErrorMessage);
    });

    test('M006: el almacén local nombra la operación y la falla', () {
      expect(
          vesselFailureMessage(
              const CacheFailure(message: 'HiveError: caja cerrada'),
              'guardar el perfil del buque'),
          'No se pudo guardar el perfil del buque: falló la lectura o la '
          'escritura de los datos guardados en este dispositivo. Inténtalo de '
          'nuevo y, si se repite, reinicia la aplicación.');
    });

    test('M004: el fallo inesperado del lector nombra el segmento', () {
      expect(
          vesselFailureMessage(const BaplieParsingFailure(
              message: 'Fallo inesperado del lector: RangeError',
              code: BaplieParsingException.unexpectedSegment,
              segment: 'LOC',
              lineNumber: 245)),
          'No se pudo interpretar el segmento LOC (n.º 245 del archivo) del '
          'BAPLIE: trae un dato que el lector no esperaba. Revisa ese segmento '
          'en el archivo o pide una nueva exportación.');
      expect(
          vesselFailureMessage(const BaplieParsingFailure(
              message: 'Fallo inesperado del lector: FormatException',
              code: BaplieParsingException.unexpectedSegment,
              segment: 'UNH y DTM')),
          startsWith('No se pudo interpretar los segmentos UNH y DTM del BAPLIE'));
    });
  });

  test('M034 y M037: el código de Firebase no sale en pantalla', () {
    final message = FirebaseSessionRepository.signInMessage('operation-not-allowed');
    expect(message, isNot(contains('operation-not-allowed')));
    expect(message, contains('el código quedó en el registro'));
    expect(message, contains('avisa al responsable'));
    expect(FirebaseSessionRepository.signInMessage('network-request-failed'),
        'Sin conexión: iniciar sesión requiere red. Conéctate e inténtalo de nuevo.');
  });

  test('M061: los rechazados dicen por qué no cuentan y qué hacer', () {
    expect(syncStatusText(const SyncStatus(SyncState.upToDate, rejected: 2)),
        'Al día · 2 rechazados por la nube, fuera del plan: regístralos de nuevo '
        'si hacen falta');
  });

  test('M068: la tara dice su rango y que se corrija', () {
    final draft = MovementDraft.raw('op', MovementType.assignEmpty, 'R:0020182',
        {'container': 'TSTU1120001', 'tareKg': 15000});
    expect(draft.validate(),
        'Tara fuera de rango: debe ser mayor que 0 y menor que 15 000 kg. '
        'Corrígela.');
  });

  testWidgets('M218: Tapas en la operación no muestra el toString() de la excepción',
      (tester) async {
    await tester.pumpWidget(ProviderScope(
        overrides: [
          loadingOperationProvider(t82Loading).overrideWith((ref) =>
              Stream.error(const VesselOperationFailure(
                  CacheFailure(message: 'HiveError: caja cerrada')))),
        ],
        child: MaterialApp(home: HatchOperationPage(voyage: t82Loading))));
    await tester.pumpAndSettle();
    expect(
        find.text('No se pudo leer las tapas de la operación: falló la lectura o '
            'la escritura de los datos guardados en este dispositivo. Inténtalo '
            'de nuevo y, si se repite, reinicia la aplicación.'),
        findsOneWidget);
    expect(find.textContaining('Instance of'), findsNothing);
    expect(find.textContaining('HiveError'), findsNothing);
  });
}
