import 'dart:io';

import 'package:baystream/core/errors/failures.dart';
import 'package:baystream/features/vessel/data/datasources/hive_vessel_data_source.dart';
import 'package:baystream/features/vessel/data/repositories/local_vessel_repository_impl.dart';
import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/repositories/vessel_repository.dart';
import 'package:dartz/dartz.dart';

const profileTestEdi = "TDT+20+V01N+++NV2:172:20+++9000003:146:11:BUQUE ALFA'"
    "LOC+147+0020182:::5'EQD+CN+TEST0000001+42G1+++5'";

/// Parser real con el contrato del repositorio, sin inicializar servicios remotos.
class ParserOnlyRepository implements VesselRepository {
  @override
  Future<Either<Failure, VesselVoyage>> parseBaplieFile(String content) async =>
      Right(BaplieParserService().parse(content));
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<({Directory directory, LocalVesselRepositoryImpl repository})>
    testProfileStore() async {
  final root =
      await Directory('build/block3/test-stores').create(recursive: true);
  final directory = await root.createTemp('profile_');
  final source = await HiveVesselDataSource.open(
      directory: directory.path,
      namespace: 'test_${DateTime.now().microsecondsSinceEpoch}');
  return (directory: directory, repository: LocalVesselRepositoryImpl(source));
}
