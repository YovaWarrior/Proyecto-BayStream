// ARCHIVO NUEVO Y TEMPORAL — bórralo cuando termines las mediciones de H5.
// Sirve para AMBOS dispositivos: la misma app, el mismo archivo.
// En el dispositivo de MUELLE tocas "Activar receptor".
// En el dispositivo de OFICINA tocas "Ejecutar emisor".

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LatencyTestScreen extends StatefulWidget {
  const LatencyTestScreen({super.key});

  @override
  State<LatencyTestScreen> createState() => _LatencyTestScreenState();
}

class _LatencyTestScreenState extends State<LatencyTestScreen> {
  bool _receptorActivo = false;
  String _condicion = 'C1';
  final _numEventosCtrl = TextEditingController(text: '30');
  final List<String> _resultados = [];
  final List<String> _log = [];
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _receptorSub;

  void _agregarLog(String t) => setState(() => _log.insert(0, t));

  // ---------- Boton 1: RECEPTOR (tocar en el dispositivo de MUELLE) ----------
  void _activarReceptor() {
    if (_receptorActivo) return;
    setState(() => _receptorActivo = true);
    _receptorSub = FirebaseFirestore.instance
        .collection('latency_test')
        .where('respondido', isEqualTo: false)
        .snapshots()
        .listen((snapshot) async {
      for (final change in snapshot.docChanges) {
        final doc = change.doc;
        final procesoB = Stopwatch()..start();
        final data = doc.data();
        if (data?['respondido'] == false) {
          final procesoBMs = procesoB.elapsedMicroseconds / 1000.0;
          await doc.reference.update({
            'respondido': true,
            'proceso_b_ms': procesoBMs,
          });
          _agregarLog('Respondi al evento ${data?['evento']}');
        }
      }
    });
    _agregarLog(
        'Receptor ACTIVO. Ya puedes ejecutar el emisor en la otra pantalla.');
  }

  // ---------- Boton 2: EMISOR (tocar en el dispositivo de OFICINA) ----------
  Future<void> _ejecutarEmisor() async {
    final col = FirebaseFirestore.instance.collection('latency_test');
    final n = int.tryParse(_numEventosCtrl.text) ?? 30;
    _agregarLog('--- Iniciando $n eventos, condicion $_condicion ---');

    for (int i = 1; i <= n; i++) {
      final docRef = col.doc();
      final t0 = DateTime.now().millisecondsSinceEpoch;
      await docRef.set({
        't0': t0,
        'condicion': _condicion,
        'evento': i,
        'respondido': false
      });

      final completer = Completer<({int t1, double procesoBMs})>();
      final sub = docRef.snapshots().listen((snap) {
        final d = snap.data();
        if (d != null && d['respondido'] == true && !completer.isCompleted) {
          completer.complete((
            t1: DateTime.now().millisecondsSinceEpoch,
            procesoBMs: (d['proceso_b_ms'] as num?)?.toDouble() ?? 0.0,
          ));
        }
      });

      ({int t1, double procesoBMs})? respuesta;
      try {
        respuesta = await completer.future.timeout(const Duration(seconds: 15));
      } catch (_) {
        respuesta = null;
      }
      await sub.cancel();

      final t1 = respuesta?.t1;
      final rtt = t1 != null ? (t1 - t0) : null;
      final procesoBMs = respuesta?.procesoBMs;
      final resultado = '$i,$_condicion,$t0,${t1 ?? ""},'
          '${procesoBMs?.toStringAsFixed(3) ?? ""},${rtt != null ? 1 : 0}';
      _resultados.add(resultado);
      debugPrint('LATENCY_CSV:$resultado');
      _agregarLog('Evento $i: ${rtt != null ? "$rtt ms" : "SIN RESPUESTA"}');

      await Future.delayed(const Duration(seconds: 5));
    }
    _agregarLog(
        '--- Prueba terminada. Selecciona y copia el cuadro de abajo. ---');
    debugPrint('LATENCY_DONE:$_condicion:$n');
    setState(() {});
  }

  @override
  void dispose() {
    _receptorSub?.cancel();
    _numEventosCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Prueba de latencia (H5) — temporal')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('PASO 1 — En el dispositivo de MUELLE (Android):',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              ElevatedButton(
                onPressed: _receptorActivo ? null : _activarReceptor,
                child: Text(
                    _receptorActivo ? 'Receptor activo ✓' : 'Activar receptor'),
              ),
              const Divider(height: 32),
              const Text('PASO 2 — En el dispositivo de OFICINA (Web):',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Row(children: [
                Expanded(
                  child: DropdownButton<String>(
                    value: _condicion,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(
                          value: 'C1', child: Text('C1 — Wi-Fi estable')),
                      DropdownMenuItem(
                          value: 'C2', child: Text('C2 — Red móvil')),
                    ],
                    onChanged: (v) => setState(() => _condicion = v!),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 70,
                  child: TextField(
                    controller: _numEventosCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'N'),
                  ),
                ),
              ]),
              const SizedBox(height: 8),
              ElevatedButton(
                  onPressed: _ejecutarEmisor,
                  child: const Text('Ejecutar emisor')),
              const Divider(height: 32),
              const Text('PASO 3 — Copia esto a la hoja M3_Latencia:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(
                height: 260,
                child: Container(
                  color: Colors.black87,
                  padding: const EdgeInsets.all(8),
                  child: SingleChildScrollView(
                    child: SelectableText(
                      'evento,condicion,t0_ms,t1_ms,proceso_b_ms,respondio\n${_resultados.join("\n")}',
                      style: const TextStyle(
                          color: Colors.greenAccent,
                          fontFamily: 'monospace',
                          fontSize: 12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
