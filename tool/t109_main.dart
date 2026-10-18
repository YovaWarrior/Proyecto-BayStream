// Banco T-109: vista real con ancho/escala explícitos, sin cuentas ni Firebase.
// Windows: --dart-define=T109_STORE=<directorio TEMP propio>. Namespace t109.
import 'dart:convert';
import 'dart:math';

import 'package:baystream/core/app.dart';
import 'package:baystream/features/vessel/data/datasources/hive_vessel_data_source.dart';
import 'package:baystream/features/vessel/data/repositories/local_vessel_repository_impl.dart';
import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/repositories/local_vessel_repository.dart';
import 'package:baystream/features/vessel/presentation/providers/vessel_providers.dart';
import 'package:baystream/features/vessel/presentation/widgets/voyage_stats_view.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class _BankVoyage extends VoyageNotifier {
  @override
  AsyncValue<VesselVoyage?> build() => const AsyncData(null);
  void publish(VesselVoyage voyage) => state = AsyncData(voyage);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const directory = String.fromEnvironment('T109_STORE');
  if (!kIsWeb && !RegExp(r'[/\\]Temp[/\\]').hasMatch(directory)) {
    throw StateError(
        'T109_STORE debe apuntar a TEMP; no usar el almacén real.');
  }
  final repository = LocalVesselRepositoryImpl(await HiveVesselDataSource.open(
    directory: kIsWeb ? null : directory,
    namespace: 't109',
  ));
  runApp(ProviderScope(overrides: [
    localVesselRepositoryProvider.overrideWith((ref) async => repository),
    voyageNotifierProvider.overrideWith(_BankVoyage.new),
  ], child: BayStreamApp(home: _Bank(repository: repository))));
}

class _Bank extends ConsumerStatefulWidget {
  final LocalVesselRepository repository;
  const _Bank({required this.repository});
  @override
  ConsumerState<_Bank> createState() => _BankState();
}

class _BankState extends ConsumerState<_Bank> {
  double _width = 1280;
  double _scale = 1;
  String _message = 'T-109 · namespace t109 · sin cuenta';

  Future<void> _pick() async {
    try {
      final picked = await FilePicker.platform.pickFiles(withData: true);
      final bytes = picked?.files.single.bytes;
      if (bytes == null) return;
      final parsed = BaplieParserService().parse(utf8.decode(bytes));
      final voyage =
          parsed.withGeometry(VesselProfile.proposeFrom(parsed).geometry);
      final saved = await widget.repository.saveVoyage(voyage);
      saved.fold((failure) => throw StateError(failure.message), (_) {});
      if (!mounted) return;
      (ref.read(voyageNotifierProvider.notifier) as _BankVoyage)
          .publish(voyage);
      setState(() => _message = '${picked!.files.single.name} · '
          '${voyage.totalContainers} contenedores');
    } catch (error) {
      if (mounted) setState(() => _message = 'Error: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final voyage = ref.watch(voyageNotifierProvider).value;
    return Scaffold(
      appBar: AppBar(title: const Text('T-109'), actions: [
        TextButton(onPressed: _pick, child: const Text('Abrir A07')),
        for (final width in [360.0, 600.0, 1280.0])
          TextButton(
              onPressed: () => setState(() => _width = width),
              child: Text('${width.toInt()} dp')),
        for (final scale in [1.0, 1.45, 2.0])
          TextButton(
              onPressed: () => setState(() => _scale = scale),
              child: Text('Letra $scale')),
      ]),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: LayoutBuilder(builder: (context, constraints) {
          final width = min(_width, constraints.maxWidth);
          final height = min(780.0, max(0.0, constraints.maxHeight - 24));
          return Column(children: [
            Text('$_message · vista ${width.toStringAsFixed(0)} × '
                '${height.toStringAsFixed(0)} dp · letra $_scale'),
            Expanded(
                child: Center(
                    child: SizedBox(
              width: width,
              height: height,
              child: MediaQuery(
                data: MediaQuery.of(context).copyWith(
                    size: Size(width, height),
                    textScaler: TextScaler.linear(_scale)),
                child: voyage == null
                    ? const Center(child: Text('Abre A07'))
                    : VoyageStatsView(
                        voyage: voyage,
                        onBaySelected: (bay) => setState(
                            () => _message = 'Bahía $bay seleccionada')),
              ),
            ))),
          ]);
        }),
      ),
    );
  }
}
