// Banco T-110: widgets y Recientes reales, namespace t110, sin Firebase.
import 'dart:convert';
import 'package:baystream/core/app.dart';
import 'package:baystream/features/vessel/data/datasources/hive_vessel_data_source.dart';
import 'package:baystream/features/vessel/data/repositories/local_vessel_repository_impl.dart';
import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/repositories/local_vessel_repository.dart';
import 'package:baystream/features/vessel/presentation/providers/sync_providers.dart';
import 'package:baystream/features/vessel/presentation/providers/vessel_providers.dart';
import 'package:baystream/features/vessel/presentation/widgets/bay_plan_view.dart';
import 'package:baystream/features/vessel/presentation/widgets/voyage_summary_card.dart';
import 'package:baystream/features/vessel/presentation/widgets/voyage_stats_view.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class _Reader extends VoyageNotifier {
  void show(VesselVoyage voyage) => state = AsyncData(voyage);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const directory = String.fromEnvironment('T110_STORE');
  if (!kIsWeb && !RegExp(r'[/\\]Temp[/\\]').hasMatch(directory)) {
    throw StateError('T110_STORE debe apuntar a TEMP');
  }
  final repository = LocalVesselRepositoryImpl(await HiveVesselDataSource.open(
      directory: kIsWeb ? null : directory, namespace: 't110'));
  runApp(ProviderScope(overrides: [
    localVesselRepositoryProvider.overrideWith((ref) async => repository),
    voyageNotifierProvider.overrideWith(_Reader.new),
    operatorProvider.overrideWith((ref) => Stream.value(null)),
    activeOperationProvider.overrideWith((ref) async => null),
  ], child: BayStreamApp(home: _Bank(repository: repository))));
}

class _Bank extends ConsumerStatefulWidget {
  final LocalVesselRepository repository;
  const _Bank({required this.repository});
  @override
  ConsumerState<_Bank> createState() => _BankState();
}

class _BankState extends ConsumerState<_Bank> {
  int _tab = 0;
  String _message = 'T-110 · namespace t110 · almacén de ensayo';
  Future<void> _open(String text, String name) async {
    try {
      final parsed = BaplieParserService().parse(text);
      final voyage = parsed
          .withGeometry(VesselGeometry.proposeFrom(parsed.stowagePositions));
      (await widget.repository.saveVoyage(voyage))
          .fold((f) => throw StateError(f.message), (_) {});
      (ref.read(voyageNotifierProvider.notifier) as _Reader).show(voyage);
      if (mounted) {
        setState(
            () => _message = '$name · lectura ${parsed.bays.length} bahías · '
                '${parsed.totalContainers} contenedores');
      }
    } catch (error) {
      if (mounted) setState(() => _message = 'Error: $error');
    }
  }

  Future<void> _pick() async {
    final picked = await FilePicker.platform.pickFiles(withData: true);
    final file = picked?.files.single;
    if (file?.bytes != null) await _open(utf8.decode(file!.bytes!), file.name);
  }

  Future<void> _profile() async {
    final voyage = ref.read(voyageNotifierProvider).value;
    if (voyage == null) return;
    final profile = VesselProfile.proposeFrom(voyage).copyWith(
        geometry: voyage.geometry, origin: VesselProfileOrigin.declaredByUser);
    final result = await widget.repository.saveProfile(profile);
    if (mounted) {
      setState(() => _message = result.fold(
          (f) => 'Error: ${f.message}',
          (_) =>
              'Perfil de ensayo confirmado · ${voyage.bays.length} bahías con evidencia'));
    }
  }

  Future<void> _recent() async {
    final voyages = (await widget.repository.getAllVoyages())
        .fold((f) => throw StateError(f.message), (v) => v);
    if (!mounted) return;
    final id = await showDialog<String>(
        context: context,
        builder: (context) =>
            SimpleDialog(title: const Text('Recientes · t110'), children: [
              for (final v in voyages)
                SimpleDialogOption(
                    onPressed: () => Navigator.pop(context, v.id),
                    child: Text(
                        '${v.vessel.name} · ${v.voyageNumber} · ${v.bays.length} bahías'))
            ]));
    if (id == null || !mounted) return;
    final reader = ref.read(voyageNotifierProvider.notifier);
    final error = await reader.openRecentVoyage(id);
    if (mounted) {
      setState(() => _message = error ??
          'Reabierto desde Recientes · '
              '${reader.publishedVoyage!.bays.length} bahías · '
              '${reader.publishedVoyage!.totalContainers} contenedores');
    }
  }

  Future<void> _synthetic(bool two) async {
    final text = "UNB+UNOA:2+TEST+TEST+261019:0000+T110'"
        "UNH+T110+BAPLIE:D:95B:UN:SMDG22'BGM++T110+9'"
        "TDT+20+T110+++TEST:172:20+++:::BUQUE PRUEBA'"
        "LOC+147+0020102::5'MEA+WT++${two ? 'TNE:23.457' : 'LBR:24000'}'"
        "EQD+CN+CSQU3054383+42G1++2+5'"
        "LOC+147+0110182::5'EQD+CN++22G1+++4'${two ? '' : "UNT+10+T110'"}";
    await _open(
        text, two ? 'Sintético TNE, faltan 2' : 'Sintético LBR, falta 1');
  }

  @override
  Widget build(BuildContext context) {
    final voyage = ref.watch(voyageNotifierProvider).value;
    return Scaffold(
        appBar: AppBar(title: const Text('BayStream · T-110')),
        body: Column(children: [
          Padding(
              padding: const EdgeInsets.all(8),
              child: Wrap(spacing: 8, runSpacing: 4, children: [
                TextButton(onPressed: _pick, child: const Text('Abrir A07')),
                TextButton(onPressed: _recent, child: const Text('Recientes')),
                TextButton(
                    onPressed: _profile,
                    child: const Text('Confirmar perfil de ensayo')),
                TextButton(
                    onPressed: () => _synthetic(false),
                    child: const Text('LBR · falta 1')),
                TextButton(
                    onPressed: () => _synthetic(true),
                    child: const Text('TNE · faltan 2')),
                for (final (index, name) in [
                  (0, 'Plano'),
                  (1, 'Resumen'),
                  (2, 'Estadísticas')
                ])
                  TextButton(
                      onPressed: () => setState(() => _tab = index),
                      child: Text(name)),
              ])),
          Padding(padding: const EdgeInsets.all(8), child: Text(_message)),
          if (voyage != null)
            Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                    'Bahías: ${(voyage.bays.keys.toList()..sort()).join(', ')}')),
          Expanded(
              child: voyage == null
                  ? const Center(child: Text('Abre A07'))
                  : switch (_tab) {
                      0 =>
                        BayPlanView(key: ValueKey(voyage.id), voyage: voyage),
                      1 => SingleChildScrollView(
                          child: VoyageSummaryCard(voyage: voyage)),
                      _ => VoyageStatsView(
                          voyage: voyage,
                          onBaySelected: (n) =>
                              ref.read(selectedBayProvider.notifier).select(n)),
                    }),
        ]));
  }
}
