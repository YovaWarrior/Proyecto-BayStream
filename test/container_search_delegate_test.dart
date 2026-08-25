import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/presentation/widgets/container_search_delegate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'muestra las cinco navieras y puertos más frecuentes en orden',
    (tester) async {
      final containers = _createContainersWithFrequencies();

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Consumer(
                builder: (context, ref, child) {
                  final delegate = ContainerSearchDelegate(
                    containers: containers,
                    ref: ref,
                  );
                  return delegate.buildSuggestions(context);
                },
              ),
            ),
          ),
        ),
      );

      final chips =
          tester.widgetList<ActionChip>(find.byType(ActionChip)).toList();
      final labels = chips.map((chip) => (chip.label as Text).data).toList();
      final counts = chips
          .map(
            (chip) => ((chip.avatar as CircleAvatar).child as Text).data,
          )
          .toList();

      expect(
        labels,
        [
          'NAV-B',
          'NAV-C',
          'NAV-Y',
          'NAV-D',
          'NAV-W',
          'P-B',
          'P-C',
          'P-Y',
          'P-D',
          'P-W',
        ],
      );
      expect(counts, ['6', '5', '5', '4', '3', '6', '5', '5', '4', '3']);
    },
  );
}

List<ContainerUnit> _createContainersWithFrequencies() {
  const frequencies = <String, int>{
    'Z': 1,
    'Y': 5,
    'X': 2,
    'B': 6,
    'D': 4,
    'C': 5,
    'W': 3,
  };
  final containers = <ContainerUnit>[];
  var sequence = 0;

  void addContainers({String? operator, String? port, required int count}) {
    for (var index = 0; index < count; index++) {
      sequence++;
      containers.add(
        ContainerUnit(
          id: 'unidad-$sequence',
          containerId: 'TEST${sequence.toString().padLeft(7, '0')}',
          operatorCode: operator,
          portOfDischarge: port,
        ),
      );
    }
  }

  for (final entry in frequencies.entries) {
    addContainers(operator: 'NAV-${entry.key}', count: entry.value);
  }
  for (final entry in frequencies.entries) {
    addContainers(port: 'P-${entry.key}', count: entry.value);
  }

  return containers;
}
