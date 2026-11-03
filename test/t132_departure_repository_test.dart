import 'dart:convert';
import 'dart:typed_data';
import 'package:baystream/features/vessel/data/repositories/departure_export_repository_impl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'support/t132_fixture.dart';

class _Picker extends FilePicker {
  Uint8List? saved;
  @override
  Future<String?> saveFile({
    String? dialogTitle,
    String? fileName,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    Uint8List? bytes,
    bool lockParentWindow = false,
  }) async {
    saved = bytes;
    return 't132-sintetico.edi';
  }
}

void main() {
  test(
    'T-132 el selector recibe los bytes originales del FTX con tilde',
    () async {
      final picker = _Picker();
      FilePicker? previous;
      try {
        previous = FilePicker.platform;
      } catch (_) {
        // En la VM de pruebas no siempre hay una plataforma registrada.
      }
      FilePicker.platform = picker;
      addTearDown(() {
        if (previous != null) FilePicker.platform = previous;
      });
      final original = t132Group(1, pol: 'HNPCR', extra: t132Auxiliary);
      final f = T132Fixture(cargo: original, rows: [], loaded: []);
      await const DepartureExportRepositoryImpl().save(
        f.operation,
        f.output().text,
      );
      final saved = String.fromCharCodes(picker.saved!);
      expect(picker.saved, contains(0xe1));
      expect(saved, contains(original));
      final start = saved.indexOf('LOC+147+');
      final end = saved.indexOf('UNT+', start);
      expect(picker.saved!.sublist(start, end), latin1.encode(original));
    },
  );
}
