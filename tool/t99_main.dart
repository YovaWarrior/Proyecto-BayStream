// T-99 · Banco de medición: la interfaz del producto con el namespace t99, sin
// Firebase. Se compila en release desde una copia temporal del commit medido
// (tool/t99_copia.ps1), nunca sobre los binarios de otra tarea:
//   flutter build windows --release --no-pub -t tool/t99_main.dart
//   flutter build web --release --no-pub -t tool/t99_main.dart
//   flutter build apk --release -t tool/t99_main.dart
// El APK va SIN --no-pub: con integration_test entre las dependencias de
// desarrollo, solo así Flutter regenera GeneratedPluginRegistrant para
// release sin ese plugin (flutter#162649); con --no-pub no compila.
// Sin T99_ESCENARIO es la app para recorrerla a mano (anchos, entrada y el
// escenario de RAM con el selector de archivos). Con T99_ESCENARIO=ram o
// anchos la recorre tool/t99_conductor.dart.
import 'package:baystream/features/vessel/data/repositories/local_vessel_repository_factory.dart';
import 'package:flutter/widgets.dart';

import 't99_app.dart';
import 't99_conductor.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final conductor = conductorDesdeDefiniciones();
  runApp(t99App(
    local: () => openLocalVesselRepository(namespace: t99Namespace),
    bitacora: () => openMovementLogRepository(namespace: t99Namespace),
    builder: conductor?.envoltorio,
  ));
  conductor?.iniciar();
}
