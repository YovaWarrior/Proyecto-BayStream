// T-147 · El banco del caso A09: la app del producto (`BayStreamApp`, con sus
// temas y su página) con tres cambios, nada más:
//
// 1. Los almacenes llevan el namespace `r4`. En Windows viven en la carpeta de
//    %TEMP% que diga `T147_ALMACEN` (el almacén real no se abre ni se crean
//    cajas dentro, 10.88); en la Web, en el IndexedDB del perfil nuevo de
//    Chrome que abre tool/t147_web.py.
// 2. No hay nube: la sesión es local (muelle sin cuenta) y el repositorio de
//    buques solo lee BAPLIE.
// 3. Con un escenario, lo recorre tool/t147_conductor.dart. El caso no va
//    dentro del binario: el conductor lo lee de fuera del repositorio.
//
//   flutter build web --release --no-pub --no-web-resources-cdn
//       -t tool/t147_main.dart --output=build/t147/e1/<antes|despues>/web
//   flutter build windows --release --no-pub -t tool/t147_main.dart
//
// Sin escenario es la app para recorrerla a mano.
import 'dart:async';

import 'package:baystream/core/app.dart';
import 'package:baystream/core/errors/exceptions.dart';
import 'package:baystream/core/errors/failures.dart';
import 'package:baystream/features/vessel/data/datasources/hive_movement_data_source.dart';
import 'package:baystream/features/vessel/data/datasources/hive_vessel_data_source.dart';
import 'package:baystream/features/vessel/data/repositories/local_only_operation_sync.dart';
import 'package:baystream/features/vessel/data/repositories/local_vessel_repository_impl.dart';
import 'package:baystream/features/vessel/data/repositories/movement_log_repository_impl.dart';
import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/repositories/vessel_repository.dart';
import 'package:baystream/features/vessel/presentation/providers/movement_log_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/sync_providers.dart';
import 'package:baystream/features/vessel/presentation/providers/vessel_providers.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 't147_conductor.dart';
import 't147_plataforma.dart';

const _namespace = 'r4';

/// Solo lee BAPLIE; nada de nube (como `ParserOnlyRepository` de las pruebas).
class _SoloLector implements VesselRepository {
  @override
  Future<Either<Failure, VesselVoyage>> parseBaplieFile(String content) async {
    try {
      return Right(BaplieParserService().parse(content));
    } on BaplieParsingException catch (e) {
      return Left(BaplieParsingFailure(
          message: e.message, code: e.code, segment: e.segment));
    }
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  String? directorio;
  if (!kIsWeb) {
    directorio = parametro('almacen');
    if (!RegExp(r'[/\\]Temp[/\\]').hasMatch(directorio)) {
      throw StateError(
          'T147_ALMACEN debe apuntar a %TEMP%: el almacén real no se abre.');
    }
  }
  final conductor = t147Conductor();
  runApp(ProviderScope(overrides: [
    localVesselRepositoryProvider.overrideWith((ref) async {
      final repo = LocalVesselRepositoryImpl(await HiveVesselDataSource.open(
          directory: directorio, namespace: _namespace));
      ref.onDispose(() => unawaited(repo.close()));
      return repo;
    }),
    movementLogRepositoryProvider.overrideWith((ref) async {
      final repo = MovementLogRepositoryImpl(await HiveMovementDataSource.open(
          directory: directorio, namespace: _namespace));
      ref.onDispose(() => unawaited(repo.close()));
      return repo;
    }),
    sessionRepositoryProvider
        .overrideWith((ref) async => const LocalSessionRepository()),
    operatorProvider.overrideWith((ref) => Stream.value(null)),
    operationSyncProvider
        .overrideWith((ref) async => const LocalOnlyOperationSync()),
    vesselRepositoryProvider.overrideWithValue(_SoloLector()),
  ], child: BayStreamApp(builder: conductor?.envoltorio)));
  conductor?.iniciar();
}
