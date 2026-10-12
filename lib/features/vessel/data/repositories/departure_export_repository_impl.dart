import 'dart:convert';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import '../../domain/entities/operation.dart';
import '../../domain/repositories/departure_export_repository.dart';

class DepartureExportRepositoryImpl implements DepartureExportRepository {
  const DepartureExportRepositoryImpl();

  @override
  Future<String?> save(Operation operation, String edi) {
    String safe(String value) {
      final name =
          value.trim().replaceAll(RegExp(r'[<>:"/\\|?*\x00-\x1f]'), '_');
      return name.isEmpty ? 'sin_dato' : name;
    }

    return FilePicker.platform.saveFile(
      dialogTitle: 'Guardar BAPLIE de salida',
      fileName:
          'BayStream_${safe(operation.vesselName)}_${safe(operation.voyageNumber)}_salida.edi',
      type: FileType.custom,
      allowedExtensions: ['edi'],
      bytes: Uint8List.fromList(utf8.encode(edi)),
    );
  }
}
