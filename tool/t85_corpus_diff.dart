import 'dart:convert';
import 'dart:io';
import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/domain/entities/vessel_geometry.dart';
import 'package:baystream/features/vessel/domain/services/dangerous_goods_validator.dart';
import 't86_corpus_support.dart';

/// Solo lectura del corpus externo. Uso: dart run tool/t85_corpus_diff.dart
/// DIRECTORIO_CORPUS SALIDA_TEMP.json. No escribe en el repositorio.
void main(List<String> args) {
  if (args.length != 2) throw ArgumentError('Indicar corpus y salida en TEMP.');
  final output = File(args[1]).absolute;
  final temp = Directory.systemTemp.absolute.path.toLowerCase();
  if (!output.path
      .replaceAll('/', Platform.pathSeparator)
      .toLowerCase()
      .startsWith('$temp${Platform.pathSeparator}')) {
    throw ArgumentError('La salida debe estar en TEMP.');
  }
  final all = <String, dynamic>{};
  final files = Directory(args[0])
      .listSync()
      .whereType<File>()
      .where((f) =>
          RegExp(r'CORPUS_A.*\.edi$', caseSensitive: false).hasMatch(f.path))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));
  for (final file in files) {
    final name = file.uri.pathSegments.last;
    final raw = file.readAsStringSync();
    final v = name == 'CORPUS_A06.edi'
        ? readA06WithNotice(raw)
        : BaplieParserService().parse(raw);
    final geometry = VesselGeometry.proposeFrom(v.stowagePositions);
    final results =
        const DangerousGoodsValidator().validate(v.containers, geometry);
    all[name] = {
      'units': [
        for (final c in v.containers.where(
            (c) => c.isDangerous || (c.dangerousGoods?.isNotEmpty ?? false)))
          {
            'id': c.containerId,
            'position': c.stowagePosition?.toIsoCode(),
            'iso': c.isoSizeType,
            'dgs': c.dangerousGoods?.map((d) => d.toJson()).toList()
          }
      ],
      'results': [
        for (final r in results)
          {
            'status': r.status.name,
            'positions': r.positions.map((p) => p.toIsoCode()).toList(),
            'ids': r.containerIds,
            'description': r.description,
            'references': r.references
          }
      ],
    };
    stdout.writeln('$name: ${results.length} resultados');
  }
  output.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(all));
}
