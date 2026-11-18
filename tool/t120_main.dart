// T-120, corrección 1 (R4, 10.149) · El banco para MIRAR la Lista y el
// buscador con el buque de las pruebas: la app del producto con los almacenes
// del banco de T-99 (`t99App`, sin Firebase) y el conductor de
// `tool/t120_conductor.dart`. Solo Windows; se compila en release desde una
// copia de %TEMP% hecha con `tool/t99_copia.ps1 -Arbol -Sufijo r4`, con el
// archivo de `tool/t120_buque.dart` entre las entradas:
//   flutter build windows --release --no-pub -t tool/t120_main.dart `
//     --dart-define=T99_ALMACEN=<carpeta en %TEMP%> --dart-define=T99_NAMESPACE=r4
// y se abre con explorer.exe desde un .cmd con T120_ARCHIVO, T120_CAPTURAS y
// T120_PASOS. Sin T120_ARCHIVO es la app para recorrerla a mano.
//
// El almacén va en %TEMP% (T99_ALMACEN), con el namespace r4: el almacén
// real no se abre. Sin Firebase, la sesión queda en el modo de un solo
// dispositivo y no abre ningún almacén (10.135).
import 'package:baystream/features/vessel/data/datasources/hive_movement_data_source.dart';
import 'package:baystream/features/vessel/data/datasources/hive_vessel_data_source.dart';
import 'package:baystream/features/vessel/data/repositories/local_vessel_repository_impl.dart';
import 'package:baystream/features/vessel/data/repositories/movement_log_repository_impl.dart';
import 'package:baystream/features/vessel/domain/repositories/local_vessel_repository.dart';
import 'package:baystream/features/vessel/domain/repositories/movement_log_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 't120_conductor.dart';
import 't99_app.dart';

const _almacen = String.fromEnvironment('T99_ALMACEN');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final windows = !kIsWeb && defaultTargetPlatform == TargetPlatform.windows;
  if (!windows || !RegExp(r'[/\\]Temp[/\\]').hasMatch(_almacen)) {
    throw StateError('Solo Windows, con T99_ALMACEN en %TEMP%: el almacén real '
        'no se abre (10.88).');
  }
  Future<LocalVesselRepository> local() async => LocalVesselRepositoryImpl(
      await HiveVesselDataSource.open(directory: _almacen, namespace: t99Namespace));
  Future<MovementLogRepository> bitacora() async => MovementLogRepositoryImpl(
      await HiveMovementDataSource.open(directory: _almacen, namespace: t99Namespace));
  final conductor = t120ConductorDelEntorno();
  runApp(t99App(local: local, bitacora: bitacora, builder: conductor?.envoltorio));
  conductor?.iniciar();
}
