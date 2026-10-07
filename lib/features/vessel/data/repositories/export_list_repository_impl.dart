import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/export_list.dart';
import '../../domain/repositories/export_list_repository.dart';
import '../services/export_list_parser_service.dart';

class ExportListRepositoryImpl implements ExportListRepository {
  final ExportListParserService _parser;

  const ExportListRepositoryImpl({ExportListParserService parser = const ExportListParserService()})
      : _parser = parser;

  @override
  Future<Either<Failure, ExportList>> parseExportList(List<int> bytes,
      {String fileName = 'listado.xlsx'}) async {
    try {
      return Right(_parser.parseXlsx(bytes, fileName: fileName));
    } on ExportListParsingException catch (e) {
      return Left(ValidationFailure(message: e.message, field: 'listado'));
    } catch (e, stack) {
      debugPrint('Error inesperado al leer el listado: $e\n$stack');
      return const Left(ValidationFailure(
          message: 'No se pudo leer el listado. Revisa que sea el Excel de la agencia.',
          field: 'listado'));
    }
  }
}
