import '../entities/operation.dart';

/// Guardado local del BAPLIE por el mismo selector que los reportes PDF.
abstract class DepartureExportRepository {
  Future<String?> save(Operation operation, String edi);
}
