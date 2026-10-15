import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';

/// T-103 · A06 (SMDG15) vuelve a leerse, con las cifras de antes de T-86
/// (1b1be4b^: 717 contenedores) y el aviso de la 1.5. Hasta T-103 los
/// recorridos históricos exigían aquí su rechazo (`requireA06Rejection`).
VesselVoyage readA06WithNotice(String source) {
  final voyage = BaplieParserService().parse(source);
  if (!declaresSmdg15(source) ||
      voyage.metadata?.readWithV2Rules != true ||
      voyage.totalContainers != 717) {
    throw StateError('A06 debe leerse como 1.5, con aviso y 717 contenedores.');
  }
  return voyage;
}
