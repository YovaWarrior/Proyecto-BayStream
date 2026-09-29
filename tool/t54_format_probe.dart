import 'dart:async';
import 'dart:convert';

import 'package:baystream/features/vessel/presentation/formatters/stack_weight_formatter.dart';

/// Ejecutar con Dart VM y compilar a JavaScript para contrastar ambos motores.
void main() {
  final cases = <double?, String>{null: '', 75000: '75000', 62500.5: '62500.5',
    75000.125: '75000.125', 12345.6789012345: '12345.6789012345'};
  final results = <String>[];
  for (final entry in cases.entries) {
    final text = formatStackWeightLimit(entry.key);
    if (text != entry.value) throw StateError('Formato inesperado: $text');
    if (entry.key != null && double.parse(text) != entry.key) {
      throw StateError('El formato cambió el valor numérico');
    }
    results.add(text);
  }
  Zone.current.print(jsonEncode({'T54': 'OK', 'textos': results}));
}
