import 'package:file_picker/file_picker.dart';

/// Sustituye solo el diálogo; los bytes recorren la entrada real del producto.
class T89FilePicker extends FilePicker {
  FilePickerResult? result;
  FileType? requestedType;
  List<String>? requestedExtensions;
  bool? requestedData;

  @override
  Future<FilePickerResult?> pickFiles({
    String? dialogTitle,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    Function(FilePickerStatus)? onFileLoading,
    bool allowCompression = false,
    int compressionQuality = 0,
    bool allowMultiple = false,
    bool withData = false,
    bool withReadStream = false,
    bool lockParentWindow = false,
    bool readSequential = false,
  }) async {
    requestedType = type;
    requestedExtensions = allowedExtensions;
    requestedData = withData;
    return result;
  }
}
