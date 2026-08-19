import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'core/utils/iso_coordinate_parser.dart';
import 'features/vessel/data/repositories/vessel_repository_impl.dart';
import 'features/vessel/domain/entities/entities.dart';

class C3ReconciliationScreen extends StatefulWidget {
  const C3ReconciliationScreen({super.key});

  @override
  State<C3ReconciliationScreen> createState() => _C3ReconciliationScreenState();
}

class _C3ReconciliationScreenState extends State<C3ReconciliationScreen> {
  static const _voyageId = 'c3-measurement-voyage';

  final _repository = VesselRepositoryImpl();
  final _cycleController = TextEditingController(text: '1');
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _subscription;

  VesselVoyage? _visibleVoyage;
  int _officeCycle = 1;
  int _officeApplied = 0;
  int? _lastCompletedCycle;
  bool _receiverActive = false;
  bool _fromCache = true;
  bool _busy = false;
  String _status = 'Sin datos sincronizados';

  List<IsoCoordinate> get _basePositions => List.generate(
        5,
        (index) => IsoCoordinateParser.fromValues(
          bay: 10,
          row: index * 2,
          tier: 2,
        ),
      );

  List<IsoCoordinate> get _targetPositions => List.generate(
        5,
        (index) => IsoCoordinateParser.fromValues(
          bay: 10,
          row: (index * 2) + 1,
          tier: 4,
        ),
      );

  int _cycleFrom(VesselVoyage voyage) {
    final parts = voyage.voyageNumber.split('-');
    return parts.length == 3 ? int.tryParse(parts[1]) ?? 0 : 0;
  }

  int _appliedFrom(VesselVoyage voyage) {
    final parts = voyage.voyageNumber.split('-');
    return parts.length == 3 ? int.tryParse(parts[2]) ?? 0 : 0;
  }

  VesselVoyage _buildVoyage({
    required int cycle,
    required int applied,
  }) {
    final base = _basePositions;
    final target = _targetPositions;
    final containers = List.generate(5, (index) {
      final position = index < applied ? target[index] : base[index];
      return ContainerUnit(
        id: 'c3-container-${index + 1}',
        containerId: 'C3TEST${(index + 1).toString().padLeft(4, '0')}',
        isoSizeType: '22G1',
        status: ContainerStatus.full,
        stowagePosition: position,
        grossWeight: 18000 + (index * 500),
        portOfLoading: 'GTPRQ',
        portOfDischarge: 'USMIA',
        operatorCode: 'BST',
      );
    });

    return VesselVoyage(
      id: _voyageId,
      vessel: const Vessel(
        id: 'c3-vessel',
        name: 'BayStream C3',
        operator: 'BayStream',
      ),
      voyageNumber: 'C3-${cycle.toString().padLeft(2, '0')}-$applied',
      direction: VoyageDirection.export_,
      portOfOrigin: 'GTPRQ',
      portOfDestination: 'USMIA',
      messageDate: DateTime.now(),
      containers: containers,
    );
  }

  Future<void> _saveVoyage(VesselVoyage voyage) async {
    final result = await _repository.saveVoyage(voyage);
    result.fold(
      (failure) => throw StateError(failure.message),
      (_) {},
    );
  }

  Future<void> _prepareCycle() async {
    final cycle = int.tryParse(_cycleController.text.trim());
    if (cycle == null || cycle < 1 || cycle > 10) {
      setState(() => _status = 'El ciclo debe estar entre 1 y 10');
      return;
    }

    setState(() {
      _busy = true;
      _status = 'Preparando ciclo $cycle...';
    });
    try {
      final voyage = _buildVoyage(cycle: cycle, applied: 0);
      await _saveVoyage(voyage);
      setState(() {
        _officeCycle = cycle;
        _officeApplied = 0;
        _visibleVoyage = voyage;
        _status = 'Ciclo $cycle preparado: 0/5 cambios';
      });
      debugPrint(
        'C3_PREPARED:$cycle:${DateTime.now().millisecondsSinceEpoch}',
      );
    } catch (error) {
      setState(() => _status = 'Error preparando ciclo: $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _applyNextChange() async {
    if (_officeApplied >= 5 || _busy) return;
    setState(() => _busy = true);
    try {
      final next = _officeApplied + 1;
      final voyage = _buildVoyage(cycle: _officeCycle, applied: next);
      await _saveVoyage(voyage);
      setState(() {
        _officeApplied = next;
        _visibleVoyage = voyage;
        _status = 'Ciclo $_officeCycle: $next/5 cambios enviados';
      });
      debugPrint(
        'C3_CHANGE:$_officeCycle:$next:${DateTime.now().millisecondsSinceEpoch}',
      );
    } catch (error) {
      setState(() => _status = 'Error enviando cambio: $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _activateReceiver() {
    _subscription?.cancel();
    setState(() {
      _receiverActive = true;
      _status = 'Receptor activo; esperando plan...';
    });

    _subscription = FirebaseFirestore.instance
        .collection('voyages')
        .doc(_voyageId)
        .snapshots(includeMetadataChanges: true)
        .listen((snapshot) {
      final data = snapshot.data();
      if (!snapshot.exists || data == null) return;

      final voyage = VesselVoyage.fromJson(data);
      final cycle = _cycleFrom(voyage);
      final applied = _appliedFrom(voyage);
      final fromCache = snapshot.metadata.isFromCache;

      if (mounted) {
        setState(() {
          _visibleVoyage = voyage;
          _fromCache = fromCache;
          _status = fromCache
              ? 'Modo offline/caché · ciclo $cycle · $applied/5 cambios'
              : 'Servidor sincronizado · ciclo $cycle · $applied/5 cambios';
        });
      }

      if (!fromCache && applied == 0) {
        // Preparar de nuevo el mismo número de ciclo también debe habilitar
        // una medición nueva (útil para repetir una corrida descartada).
        _lastCompletedCycle = null;
        debugPrint(
          'C3_READY:$cycle:${DateTime.now().millisecondsSinceEpoch}',
        );
      }
      if (!fromCache && applied == 5 && _lastCompletedCycle != cycle) {
        _lastCompletedCycle = cycle;
        debugPrint(
          'C3_COMPLETE:$cycle:${DateTime.now().millisecondsSinceEpoch}:5',
        );
      }
    }, onError: (Object error) {
      debugPrint('C3_RECEIVER_ERROR:$error');
      if (mounted) setState(() => _status = 'Error del receptor: $error');
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _cycleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final voyage = _visibleVoyage;
    final applied = voyage == null ? 0 : _appliedFrom(voyage);

    return Scaffold(
      appBar: AppBar(title: const Text('C3 · Reconciliación Offline-First')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!kIsWeb) ...[
                FilledButton.icon(
                  onPressed: _receiverActive ? null : _activateReceiver,
                  icon: const Icon(Icons.sync),
                  label: Text(
                    _receiverActive
                        ? 'Receptor C3 activo ✓'
                        : 'Activar receptor C3',
                  ),
                ),
                const SizedBox(height: 12),
              ],
              if (kIsWeb) ...[
                Row(
                  children: [
                    SizedBox(
                      width: 110,
                      child: TextField(
                        controller: _cycleController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Ciclo',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: _busy ? null : _prepareCycle,
                        child: const Text('Preparar ciclo'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.tonal(
                        onPressed: _busy || _officeApplied >= 5
                            ? null
                            : _applyNextChange,
                        child: Text('Aplicar cambio ${_officeApplied + 1}/5'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        _fromCache ? Icons.cloud_off : Icons.cloud_done,
                        color: _fromCache ? Colors.orange : Colors.green,
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Text(_status)),
                      Text('$applied/5'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Plan de estiba compartido',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (voyage == null)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text('Todavía no hay un ciclo preparado.'),
                  ),
                )
              else
                ...voyage.containers.asMap().entries.map((entry) {
                  final index = entry.key;
                  final container = entry.value;
                  final moved = index < applied;
                  return Card(
                    color: moved ? Colors.green.shade50 : null,
                    child: ListTile(
                      leading: CircleAvatar(child: Text('${index + 1}')),
                      title: Text(container.containerId),
                      subtitle: Text(
                        container.stowagePosition?.displayFormat ??
                            'Sin posición',
                      ),
                      trailing: Icon(
                        moved ? Icons.check_circle : Icons.inventory_2,
                        color: moved ? Colors.green : null,
                      ),
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }
}
