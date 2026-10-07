import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/export_list.dart';

/// T-73 · Lectura del listado de exportación de la agencia (RF-038).
abstract class ExportListRepository {
  /// Lee el libro .xlsx. Las filas que no se entienden vienen en `issues`;
  /// Left solo si no hay una tabla de listado que leer.
  Future<Either<Failure, ExportList>> parseExportList(List<int> bytes,
      {String fileName = 'listado.xlsx'});
}
