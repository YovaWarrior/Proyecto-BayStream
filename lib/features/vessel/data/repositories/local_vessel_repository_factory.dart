import '../../domain/repositories/local_vessel_repository.dart';
import '../datasources/hive_vessel_data_source.dart';
import '../datasources/local_store_directory.dart';
import 'local_vessel_repository_impl.dart';

Future<LocalVesselRepository> openLocalVesselRepository(
        {String namespace = 'baystream'}) async =>
    LocalVesselRepositoryImpl(await HiveVesselDataSource.open(
      directory: await localStoreDirectory(),
      namespace: namespace,
    ));
