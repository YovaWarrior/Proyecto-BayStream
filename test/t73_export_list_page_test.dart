import 'dart:convert';

import 'package:baystream/core/errors/failures.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/repositories/local_vessel_repository.dart';
import 'package:baystream/features/vessel/domain/repositories/movement_log_repository.dart';
import 'package:baystream/features/vessel/presentation/pages/export_list_import_page.dart';
import 'package:baystream/features/vessel/presentation/providers/export_list_providers.dart';
import 'package:baystream/features/vessel/presentation/providers/vessel_providers.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/t73_export_list_support.dart';

class _Local implements LocalVesselRepository {
  CodeEquivalences table = CodeEquivalences.empty;

  @override
  Future<Either<Failure, CodeEquivalences>> getCodeEquivalences() async => Right(table);

  @override
  Future<Either<Failure, void>> saveCodeEquivalences(CodeEquivalences equivalences) async {
    table = equivalences;
    return const Right(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Log implements MovementLogRepository {
  final operations = <Operation>[];

  @override
  Future<Either<Failure, List<Operation>>> getOperations() async => Right(List.of(operations));

  @override
  Future<Either<Failure, void>> saveOperation(Operation operation) async {
    operations
      ..removeWhere((o) => o.id == operation.id)
      ..add(operation);
    return const Right(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _PlanNotifier extends VoyageNotifier {
  final VesselVoyage plan;
  _PlanNotifier(this.plan);

  @override
  AsyncValue<VesselVoyage?> build() => AsyncValue.data(plan);
}

void main() {
  late _Local local;
  late _Log log;

  Future<ProviderContainer> open(WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(ProviderScope(overrides: [
      voyageNotifierProvider.overrideWith(() => _PlanNotifier(t73Plan())),
      localVesselRepositoryProvider.overrideWith((ref) async => local),
      movementLogRepositoryProvider.overrideWith((ref) async => log),
    ], child: const MaterialApp(home: ExportListImportPage())));
    await tester.pump();
    return ProviderScope.containerOf(tester.element(find.byType(ExportListImportPage)));
  }

  const confirmKey = ValueKey('export-list-confirm');

  /// A 360 dp el botón queda bajo el borde: la lista no lo construye hasta llegar.
  Future<bool> enabled(WidgetTester tester) async {
    await tester.scrollUntilVisible(find.byKey(confirmKey), 300,
        scrollable: find.byType(Scrollable).first);
    await tester.ensureVisible(find.byKey(confirmKey));
    await tester.pumpAndSettle();
    return tester.widget<ButtonStyleButton>(find.byKey(confirmKey)).enabled;
  }

  setUp(() {
    local = _Local();
    log = _Log();
  });

  testWidgets('T-73 a 360 dp: pide 40RF, guarda la fuente y no lo vuelve a pedir',
      (tester) async {
    var container = await open(tester);
    await container
        .read(exportListImportProvider.notifier)
        .loadBytes(t73ListBytes(), fileName: 'sintetico.xlsx');
    await tester.pump();

    expect(find.text('7 filas en 2 agencias · 4 llenos · 3 vacíos'), findsOneWidget);
    expect(find.text('2 filas sin entender:'), findsOneWidget);
    expect(find.text('Tipo 40HC → 45G1'), findsOneWidget);
    expect(find.text('Puerto COMNG → COSPC'), findsOneWidget);
    expect(find.text('Línea LNB → LINB'), findsOneWidget);
    expect(find.text('Tipo 40RF → ?'), findsOneWidget);
    expect(await enabled(tester), isFalse);

    final choice = find.byKey(const ValueKey('equivalence-choice-40RF-45R1'));
    await tester.scrollUntilVisible(choice, -300, scrollable: find.byType(Scrollable).first);
    await tester.ensureVisible(choice);
    await tester.pumpAndSettle();
    await tester.tap(choice);
    await tester.pump();
    expect(find.text('Tipo 40RF → 45R1'), findsOneWidget);
    await tester.scrollUntilVisible(find.byKey(const ValueKey('cross-fulls')), 300,
        scrollable: find.byType(Scrollable).first);
    expect(find.text('3 de 4 llenos cruzan con el plan'), findsOneWidget);
    expect(find.text('3 de 3 vacíos en 3 grupos de reservas'), findsOneWidget);
    expect(find.byKey(const ValueKey('dg-3')), findsOneWidget);
    expect(await enabled(tester), isTrue);

    await tester.tap(find.byKey(confirmKey));
    await tester.pumpAndSettle();

    final source = log.operations.single.source(OperationSourceKind.exportList)!;
    expect(log.operations.single.portOfCall, 'GTSTC');
    expect(source.fileName, 'sintetico.xlsx');
    final saved = ExportList.fromJson(jsonDecode(source.content) as Map<String, dynamic>);
    expect(saved.rows.length, 7);
    expect(saved.byOrder(5)!.type, '45R1');
    expect(saved.byOrder(2)!.vgmKg, 7266.59);
    expect(local.table.lookup(EquivalenceKind.type, '40RF'), '45R1');
    expect(local.table.lookup(EquivalenceKind.line, 'LNB'), 'LINB');
    await tester.scrollUntilVisible(find.text('Guardado en la operación'), -300,
        scrollable: find.byType(Scrollable).first);
    expect(find.text('Guardado en la operación'), findsOneWidget);

    // Reabrir la pantalla: se ve lo guardado y una segunda importación no pide nada.
    await tester.pumpWidget(const SizedBox());
    container = await open(tester);
    await tester.pump();
    expect(find.text('Guardado en la operación'), findsOneWidget);
    await container
        .read(exportListImportProvider.notifier)
        .loadBytes(t73ListBytes(), fileName: 'sintetico.xlsx');
    await tester.pump();
    expect(find.text('Tipo 40RF → 45R1'), findsOneWidget);
    expect(find.textContaining('→ ?'), findsNothing);
    expect(await enabled(tester), isTrue);
  });

  testWidgets('T-73 sin plan con escala no deja importar', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(ProviderScope(overrides: [
      voyageNotifierProvider
          .overrideWith(() => _PlanNotifier(t73Plan().copyWith(clearPortOfCall: true))),
      localVesselRepositoryProvider.overrideWith((ref) async => local),
      movementLogRepositoryProvider.overrideWith((ref) async => log),
    ], child: const MaterialApp(home: ExportListImportPage())));
    await tester.pump();
    expect(find.text('Abre primero el plan de carga (BAPLIE) y confirma la escala.'),
        findsOneWidget);
    expect(find.byKey(const ValueKey('export-list-pick')), findsNothing);
  });
}
