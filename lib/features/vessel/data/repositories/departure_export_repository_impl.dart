import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import '../../domain/entities/operation.dart';
import '../../domain/repositories/departure_export_repository.dart';
import '../../domain/services/departure_baplie_review.dart';

class DepartureExportRepositoryImpl implements DepartureExportRepository {
  const DepartureExportRepositoryImpl();

  @override
  Future<String?> save(Operation operation, String edi) {
    String safe(String value) {
      final name = value.trim().replaceAll(
            RegExp(r'[<>:"/\\|?*\x00-\x1f]'),
            '_',
          );
      return name.isEmpty ? 'sin_dato' : name;
    }

    return FilePicker.platform.saveFile(
      dialogTitle: 'Guardar BAPLIE de salida',
      // T-130 (10.90, ajuste 5): el nombre lleva el viaje del plan de carga,
      // el mismo que el TDT del archivo; es el de la operación salvo que el
      // plan se haya agregado con otro.
      fileName:
          'BayStream_${safe(operation.vesselName)}_${safe(operation.departureVoyageNumber)}_salida.edi',
      type: FileType.custom,
      allowedExtensions: ['edi'],
      bytes: Uint8List.fromList(DepartureCharacterSet.bytes(edi)),
    );
  }
}
