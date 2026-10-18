// Banco local T-108: widgets reales, namespace t108, sin Firebase ni cuentas.
// Windows exige --dart-define=T108_STORE=<directorio TEMP propio>.
// A07 se abre con el selector; nunca se agrega como asset ni al repositorio.
import 'dart:convert';

import 'package:baystream/core/app.dart';
import 'package:baystream/features/vessel/data/datasources/hive_vessel_data_source.dart';
import 'package:baystream/features/vessel/data/repositories/local_vessel_repository_impl.dart';
import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/repositories/local_vessel_repository.dart';
import 'package:baystream/features/vessel/presentation/providers/vessel_providers.dart';
import 'package:baystream/features/vessel/presentation/widgets/voyage_summary_card.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const t108Synthetic = "UNB+UNOA:2+TEST+TEST+261018:1200+T108'"
    "UNH+T108+BAPLIE:D:95B:UN:SMDG22'BGM++T108+9'"
    "TDT+20+T108+++TEST:172:20+++:::BUQUE PRUEBA'"
    "LOC+147+012A082::5'MEA+WT++LBR:24000'"
    "EQD+CN+CSQU3054384+22G1++2+5'";

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const directory = String.fromEnvironment('T108_STORE');
  if (!kIsWeb && !RegExp(r'[/\\]Temp[/\\]').hasMatch(directory)) {
    throw StateError(
        'T108_STORE debe apuntar a TEMP; no usar el almacén real.');
  }
  final repository = LocalVesselRepositoryImpl(await HiveVesselDataSource.open(
    directory: kIsWeb ? null : directory,
    namespace: 't108',
  ));
  runApp(ProviderScope(overrides: [
    localVesselRepositoryProvider.overrideWith((ref) async => repository),
  ], child: BayStreamApp(home: _Bank(repository: repository))));
}

class _Bank extends StatefulWidget {
  final LocalVesselRepository repository;
  const _Bank({required this.repository});
  @override
  State<_Bank> createState() => _BankState();
}

class _BankState extends State<_Bank> {
  VesselVoyage? _voyage;
  String _message = 'T-108 · namespace t108 · sin cuenta';

  Future<void> _open(String source, String name) async {
    try {
      final voyage = BaplieParserService().parse(source);
      final saved = await widget.repository.saveVoyage(voyage);
      saved.fold((failure) => throw StateError(failure.message), (_) {});
      if (!mounted) return;
      setState(() {
        _voyage = voyage;
        _message = '$name · ${voyage.totalContainers} contenedores · '
            '${voyage.readNotices.length} tipos de aviso';
      });
    } catch (error) {
      if (mounted) setState(() => _message = 'Error: $error');
    }
  }

  Future<void> _pick() async {
    final picked = await FilePicker.platform.pickFiles(withData: true);
    final file = picked?.files.single;
    if (file?.bytes != null) {
      await _open(utf8.decode(file!.bytes!), file.name);
    }
  }

  Future<void> _recent() async {
    final result = await widget.repository.getAllVoyages();
    final voyages = result.fold(
        (failure) => throw StateError(failure.message), (value) => value);
    if (!mounted) return;
    final selected = await showDialog<VesselVoyage>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Recientes · t108'),
        children: [
          for (final voyage in voyages)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, voyage),
              child: Text('${voyage.voyageNumber} · ${voyage.totalContainers} '
                  'contenedores · ${voyage.readNotices.length} avisos'),
            ),
        ],
      ),
    );
    if (selected == null || !mounted) return;
    setState(() {
      _voyage = selected;
      _message =
          'Reabierto desde Recientes · ${selected.readNotices.length} avisos';
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('BayStream · T-108')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Wrap(spacing: 12, runSpacing: 12, children: [
              FilledButton(onPressed: _pick, child: const Text('Abrir A07')),
              FilledButton.tonal(
                  onPressed: () => _open(t108Synthetic, 'Sintético T108'),
                  child: const Text('Cuatro avisos')),
              OutlinedButton(
                  onPressed: _recent, child: const Text('Recientes')),
            ]),
            const SizedBox(height: 12),
            Text(_message),
            const SizedBox(height: 16),
            if (_voyage != null) VoyageSummaryCard(voyage: _voyage!),
          ]),
        ),
      );
}
