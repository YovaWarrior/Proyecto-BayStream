import 'package:baystream/core/errors/failures.dart';
import 'package:baystream/features/vessel/presentation/formatters/vessel_error_message.dart';
import 'package:baystream/features/vessel/presentation/providers/vessel_providers.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/repositories/vessel_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FailedLoadRepository implements VesselRepository {
  @override
  Future<Either<Failure, VesselVoyage>> parseBaplieFile(String content) async =>
      const Left(BaplieParsingFailure(
        message: 'No se encontró el nombre del buque en el segmento TDT',
        segment: 'TDT',
      ));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  final exceptionPrefix =
      RegExp(r'Bad state|Exception|FormatException', caseSensitive: false);

  test('los mensajes de carga no exponen prefijos de excepciones', () {
    final failures = <Failure>[
      const BaplieParsingFailure(
          message: 'No se encontró el nombre del buque en el segmento TDT',
          segment: 'TDT'),
      const BaplieParsingFailure(
          message: 'El contenido del archivo BAPLIE está vacío'),
      const BaplieParsingFailure(
          message: 'No se encontraron segmentos válidos en el archivo'),
      const BaplieParsingFailure(
          message: 'FormatException: detalle inesperado'),
      const CacheFailure(message: 'Bad state: almacén inaccesible'),
    ];
    for (final failure in failures) {
      final message = vesselErrorMessage(VesselOperationFailure(failure));
      expect(message, isNot(matches(exceptionPrefix)));
      expect(message, contains('.'));
      expect(message,
          contains(RegExp(r'Revisa|Selecciona|Inténtalo|pide|Confirma')));
    }
    expect(vesselErrorMessage(StateError('Bad state: secreto')),
        isNot(matches(exceptionPrefix)));
  });

  test('la carga real del notifier conserva causa y acción sin Bad state',
      () async {
    final container = ProviderContainer(overrides: [
      vesselRepositoryProvider.overrideWithValue(_FailedLoadRepository()),
    ]);
    addTearDown(container.dispose);
    final result = await container
        .read(voyageNotifierProvider.notifier)
        .parseBaplieContent('INVALID');
    expect(result.success, isFalse);
    expect(result.errorMessage, contains('segmento TDT'));
    expect(result.errorMessage, contains('Revisa'));
    expect(result.errorMessage, isNot(matches(exceptionPrefix)));
  });
}
