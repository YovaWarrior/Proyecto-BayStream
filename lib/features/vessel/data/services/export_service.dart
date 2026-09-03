import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

import '../../domain/entities/entities.dart';

/// Formatos disponibles desde el único punto de exportación del viaje.
enum VoyageExportFormat { pdf, csv, json }

extension VoyageExportFormatX on VoyageExportFormat {
  String get label => switch (this) {
        VoyageExportFormat.pdf => 'PDF',
        VoyageExportFormat.csv => 'CSV',
        VoyageExportFormat.json => 'JSON',
      };

  String get extension => name;
}

/// Serializa y guarda viajes en formatos interoperables.
class ExportService {
  static const List<String> csvHeaders = [
    'id',
    'containerId',
    'isoSizeType',
    'status',
    'stowagePosition',
    'grossWeight',
    'vgmWeight',
    'tareWeight',
    'portOfLoading',
    'portOfDischarge',
    'finalDestination',
    'operatorCode',
    'isDangerous',
    'imdgClass',
    'unNumber',
    'isReefer',
    'temperature',
    'temperatureUnit',
    'isOverDimension',
    'overHeight',
    'overWidthLeft',
    'overWidthRight',
    'overLengthFront',
    'overLengthRear',
  ];

  const ExportService();

  /// CSV con todas las propiedades de [ContainerUnit] y BOM UTF-8 para Excel.
  String serializeCsv(VesselVoyage voyage) {
    final buffer = StringBuffer('\ufeff')
      ..write(csvHeaders.join(','))
      ..write('\r\n');

    for (final container in voyage.containers) {
      final values = <Object?>[
        container.id,
        container.containerId,
        container.isoSizeType,
        container.status.name,
        container.stowagePosition?.rawCode,
        container.grossWeight,
        container.vgmWeight,
        container.tareWeight,
        container.portOfLoading,
        container.portOfDischarge,
        container.finalDestination,
        container.operatorCode,
        container.isDangerous,
        container.imdgClass,
        container.unNumber,
        container.isReefer,
        container.temperature,
        container.temperatureUnit,
        container.isOverDimension,
        container.overHeight,
        container.overWidthLeft,
        container.overWidthRight,
        container.overLengthFront,
        container.overLengthRear,
      ];
      buffer
        ..write(values.map(_escapeCsvField).join(','))
        ..write('\r\n');
    }

    return buffer.toString();
  }

  /// JSON completo del viaje, reutilizando la serialización del dominio.
  String serializeJson(VesselVoyage voyage) {
    return const JsonEncoder.withIndent('  ').convert(voyage.toJson());
  }

  Uint8List bytesFor(VesselVoyage voyage, VoyageExportFormat format) {
    final content = switch (format) {
      VoyageExportFormat.csv => serializeCsv(voyage),
      VoyageExportFormat.json => serializeJson(voyage),
      VoyageExportFormat.pdf => throw UnsupportedError(
          'Los bytes PDF deben ser generados por RF-025.',
        ),
    };
    return Uint8List.fromList(utf8.encode(content));
  }

  /// Abre el selector nativo y guarda los bytes también en Web.
  Future<String?> saveVoyage(
    VesselVoyage voyage,
    VoyageExportFormat format, {
    Uint8List? pdfBytes,
  }) {
    final bytes = format == VoyageExportFormat.pdf
        ? pdfBytes ??
            (throw ArgumentError.value(
              pdfBytes,
              'pdfBytes',
              'Es obligatorio para exportar PDF.',
            ))
        : bytesFor(voyage, format);
    final fileName = buildFileName(voyage, format);

    return FilePicker.platform.saveFile(
      dialogTitle: 'Guardar reporte del viaje',
      fileName: fileName,
      type: FileType.custom,
      allowedExtensions: [format.extension],
      bytes: bytes,
    );
  }

  String buildFileName(VesselVoyage voyage, VoyageExportFormat format) {
    final vesselName = _safeFileNamePart(voyage.vessel.name);
    final voyageNumber = _safeFileNamePart(voyage.voyageNumber);
    return 'BayStream_${vesselName}_$voyageNumber.${format.extension}';
  }

  /// Carácter que fuerza a Excel a leer el campo como texto.
  ///
  /// Se elige la tabulación y no la comilla simple porque Excel oculta la
  /// tabulación al importar y en cambio muestra la comilla como parte del
  /// dato. Tampoco se usa `="0030410"`: esa forma es una fórmula, y sería
  /// introducir el defecto 5.4 mientras se corrige el de los ceros.
  static const String _excelTextGuard = '\t';

  /// Indica si Excel interpretaría el campo como algo distinto del texto que
  /// trae, y por tanto hay que protegerlo.
  ///
  /// Cubre los dos defectos a la vez, porque son el mismo mecanismo:
  ///
  /// - **Ceros a la izquierda (C-6).** La posición de estiba es de siete
  ///   dígitos: `0030410` es bahía 003, fila 04, nivel 10. Excel la lee como
  ///   número y la deja en `30410`.
  /// - **Inyección de fórmulas (defecto 5.4 de la auditoría).** Un campo que
  ///   empieza en `=`, `+`, `@` o un carácter de control se evalúa al abrir
  ///   el archivo. El contenido viene de un BAPLIE de terceros.
  ///
  /// El signo menos se trata aparte: `-18.5` es una temperatura legítima y
  /// tiene que seguir siendo un número en Excel. Solo se protege cuando lo
  /// que sigue al signo no forma un número, que es cuando es una fórmula.
  static bool _needsExcelTextGuard(String text) {
    if (text.isEmpty) return false;
    if (RegExp(r'^0\d').hasMatch(text)) return true;
    if (RegExp(r'^[=+@\t\r\n]').hasMatch(text)) return true;
    if (text.startsWith('-') && double.tryParse(text) == null) return true;
    return false;
  }

  String _escapeCsvField(Object? value) {
    final text = value?.toString() ?? '';
    final guarded = _needsExcelTextGuard(text);
    final protected = guarded ? '$_excelTextGuard$text' : text;
    final escaped = protected.replaceAll('"', '""');
    // Un campo protegido se entrecomilla siempre: la tabulación suelta queda
    // a merced de cómo cada lector delimite los campos.
    final needsQuotes = guarded ||
        escaped.contains(',') ||
        escaped.contains('"') ||
        escaped.contains('\r') ||
        escaped.contains('\n');
    return needsQuotes ? '"$escaped"' : escaped;
  }

  String _safeFileNamePart(String value) {
    final sanitized = value.trim().replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
    return sanitized.isEmpty ? 'sin_dato' : sanitized;
  }
}
