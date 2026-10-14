import 'dart:io';

import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/presentation/providers/vessel_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test/support/t91_toolbar_support.dart';
import '../test/t90_theme_test.dart' show t90Contrast;

void main() {
  const corpus = String.fromEnvironment('BAYSTREAM_CORPUS_DIRECTORY');
  for (final brightness in Brightness.values) {
    testWidgets('T-90 ${brightness.name}: A07 y A08 conservan cifras y pesos legibles en todas las bahías', (tester) async {
      for (final file in ['CORPUS_A07.edi', 'CORPUS_A08.edi']) {
        await tester.pumpWidget(const SizedBox());
        await tester.pump();
        final parsed = await tester.runAsync(() async => BaplieParserService().parse(await File('$corpus/$file').readAsString()));
        final voyage = parsed!.withGeometry(VesselProfile.proposeFrom(parsed).geometry, portOfCall: 'GTSTC');
        expect(voyage.totalContainers, file.contains('A07') ? 398 : 405);
        expect(voyage.totalReservedSlots, file.contains('A07') ? 0 : 55);
        expect(voyage.totalWeight, file.contains('A07') ? 6940578 : 6899700);
        final scope = await pumpT91Plan(tester, voyage, T91MemorySettings(), brightness);
        var weightsChecked = 0;
        for (final bay in voyage.bays.keys) {
          scope.read(selectedBayProvider.notifier).select(bay);
          await tester.pumpAndSettle();
          for (final element in find.byKey(const ValueKey('peso-celda')).evaluate()) {
            final text = element.widget as Text;
            final cells = find.ancestor(of: find.byWidget(text), matching: find.byWidgetPredicate((w) => w is Container && w.constraints?.maxWidth == 50 && w.constraints?.maxHeight == 40));
            final cell = tester.widget<Container>(cells.first);
            expect(t90Contrast(text.style!.color!, (cell.decoration! as BoxDecoration).color!), greaterThanOrEqualTo(4.5), reason: '$file bahía $bay peso ${text.data}');
            weightsChecked++;
          }
        }
        expect(weightsChecked, voyage.containers.where((c) => c.effectiveWeight != null).length);
        tester.view.physicalSize = const Size(360, 800);
        await tester.pumpAndSettle();
        expect(tester.widget<AppBar>(find.byType(AppBar)).actions, hasLength(1));
        await tester.tap(find.byTooltip('Desplegar acciones'));
        await tester.pumpAndSettle();
        expect(tester.getRect(find.byKey(const ValueKey('toggle-plan-toolbar'))).right, lessThanOrEqualTo(360));
        await tester.tap(find.byTooltip('Plegar acciones'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
    });
  }
}
