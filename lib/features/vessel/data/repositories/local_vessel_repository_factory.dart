import '../../domain/repositories/local_vessel_repository.dart';
import '../../domain/repositories/movement_log_repository.dart';
import '../datasources/hive_movement_data_source.dart';
import '../datasources/hive_vessel_data_source.dart';
import '../datasources/local_store_directory.dart';
import 'local_vessel_repository_impl.dart';
import 'movement_log_repository_impl.dart';

Future<LocalVesselRepository> openLocalVesselRepository(
        {String namespace = 'baystream'}) async =>
    LocalVesselRepositoryImpl(await HiveVesselDataSource.open(
      directory: await localStoreDirectory(),
      namespace: namespace,
    ));

/// T-72 · Bitácora local, en el mismo directorio y con el mismo motor.
Future<MovementLogRepository> openMovementLogRepository(
        {String namespace = 'baystream'}) async =>
    MovementLogRepositoryImpl(await HiveMovementDataSource.open(
      directory: await localStoreDirectory(),
      namespace: namespace,
    ));
