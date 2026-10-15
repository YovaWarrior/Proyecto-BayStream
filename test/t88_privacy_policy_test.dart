import 'dart:async';
import 'dart:io';

import 'package:baystream/core/constants/privacy_policy.dart';
import 'package:baystream/core/errors/failures.dart';
import 'package:baystream/core/utils/privacy_policy_html.dart';
import 'package:baystream/features/vessel/data/repositories/local_only_operation_sync.dart';
import 'package:baystream/features/vessel/domain/entities/app_theme_preference.dart';
import 'package:baystream/features/vessel/domain/repositories/local_vessel_repository.dart';
import 'package:baystream/features/vessel/domain/repositories/session_repository.dart';
import 'package:baystream/features/vessel/presentation/pages/cloud_page.dart';
import 'package:baystream/features/vessel/presentation/pages/parameters_page.dart';
import 'package:baystream/features/vessel/presentation/pages/privacy_policy_page.dart';
import 'package:baystream/features/vessel/presentation/providers/movement_log_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/sync_providers.dart';
import 'package:baystream/features/vessel/presentation/providers/vessel_providers.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/t75_memory_log.dart';

/// T-88 · La política de privacidad: una sola fuente para la pantalla y
/// `web/privacidad.html`, sus dos entradas sin viaje ni sesión, D3 y D9 en
/// Android, y el mensaje de `UnknownError` del script de T-93.
class _Settings implements LocalVesselRepository {
  @override
  Future<Either<Failure, AppThemePreference>> getThemePreference() async =>
      const Right(AppThemePreference.system);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Sin sesión iniciada: la pantalla de «Nube y cuenta» muestra el formulario.
class _SignedOut implements SessionRepository {
  @override
  bool get supportsAccounts => true;
  @override
  Operator? get current => null;
  @override
  Stream<Operator?> watchOperator() => Stream.value(null);
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget _app(Widget home, {Brightness brightness = Brightness.light, List overrides = const []}) =>
    ProviderScope(
      overrides: [...overrides],
      child: MaterialApp(
        theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF0D47A1), brightness: brightness)),
        home: home,
      ),
    );

String _allText() => [
      kPrivacyPolicyTitle,
      kPrivacyPolicyUpdated,
      for (final section in kPrivacyPolicySections) ...[
        section.title,
        ...section.paragraphs.map(privacyPlainText),
        ...section.items.map(privacyPlainText),
      ],
    ].join('\n');

void main() {
  Future<void> narrow(WidgetTester tester, {double scale = 1}) async {
    tester.view.physicalSize = const Size(720, 1600);
    tester.view.devicePixelRatio = 2;
    tester.platformDispatcher.textScaleFactorTestValue = scale;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  }

  test('T-88 web/privacidad.html es lo que genera la fuente, salvo finales de línea', () {
    final published = File('web/privacidad.html').readAsStringSync().replaceAll('\r\n', '\n');
    expect(published, privacyPolicyHtml(),
        reason: 'regenéralo con: dart run tool/t88_privacidad.dart');
  });

  test('T-88 la política nombra micrófono, sincronización, respaldo y contacto', () {
    final text = _allText();
    expect(text, contains('El micrófono, solo si lo usas.'));
    expect(text, contains('En Windows no hay dictado.'));
    expect(text, contains('Con cuenta, la operación se sincroniza.'));
    expect(text, contains('Cloud Firestore'));
    expect(text, contains('no entran en la copia de seguridad de Google ni pasan a otro '
        'teléfono en una transferencia'));
    expect(text, contains('escribe a giovannimartinezcrl2002@gmail.com.'));
    expect(text, contains(kPrivacyPolicyUpdated));
    // D2 es la única dirección de correo del texto (10.44).
    final emails = RegExp(r'[\w.+-]+@[\w-]+(\.[\w-]+)+').allMatches(text).map((m) => m.group(0));
    expect(emails.toSet(), {kPrivacyContactEmail});
    expect(text, isNot(contains('[correo')));
  });

  test('T-88 privacidad.html es autocontenido: sin JavaScript ni recursos externos', () {
    final html = privacyPolicyHtml();
    expect(html, contains('<html lang="es">'));
    expect(html, contains('<meta name="viewport"'));
    expect(html, contains('prefers-color-scheme: dark'));
    expect(html.toLowerCase(), isNot(contains('<script')));
    expect(html.toLowerCase(), isNot(contains('<link')));
    expect(html.toLowerCase(), isNot(contains('<img')));
    expect(html, isNot(contains('@import')));
    expect(html, isNot(contains('url(')));
    expect(RegExp(r'''(src|href)\s*=\s*["']?(https?:)?//''').hasMatch(html), isFalse);
    expect(RegExp(r'\son\w+\s*=').hasMatch(html), isFalse);
    // Cada párrafo y punto de la fuente está en el HTML, con sus marcas.
    for (final section in kPrivacyPolicySections) {
      expect(html, contains('<h2>${section.title}</h2>'));
    }
    expect(html, contains('<strong>Tu cuenta.</strong>'));
    expect(html, contains(r'<code>AppData\Local\BayStream</code>'));
  });

  test('T-88 las marcas de la fuente se leen sin asteriscos ni comillas', () {
    final runs = privacyRuns('**Tu cuenta.** Borra `AppData` ya.');
    expect(runs.map((r) => r.text).join(), 'Tu cuenta. Borra AppData ya.');
    expect(runs.first.bold, isTrue);
    expect(runs[2].code, isTrue);
    expect(_allText(), isNot(contains('**')));
    expect(_allText(), isNot(contains('`')));
  });

  for (final brightness in Brightness.values) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('T-88 la pantalla muestra el texto completo a 360 dp, '
          '${brightness.name}, letra $scale', (tester) async {
        await narrow(tester, scale: scale);
        // 360 dp de ancho y alto de sobra: la lista se arma completa sin
        // desplazarla, y cualquier desborde a ese ancho sale como excepción.
        tester.view.physicalSize = const Size(720, 120000);
        await tester.pumpWidget(_app(const PrivacyPolicyPage(), brightness: brightness));
        await tester.pumpAndSettle();
        final expected = [
          kPrivacyPolicyTitle,
          kPrivacyPolicyUpdated,
          for (final section in kPrivacyPolicySections) ...[
            section.title,
            ...section.paragraphs.map(privacyPlainText),
            ...section.items.map(privacyPlainText),
          ],
        ];
        for (final text in expected) {
          expect(find.text(text, findRichText: true), findsOneWidget, reason: text);
        }
        expect(tester.takeException(), isNull);
      });
    }
  }

  // A la superficie por defecto: a 360 dp, con la letra de pruebas, el selector
  // de tema de T-90 ya se desborda 2.5 px, con o sin esta entrada.
  testWidgets('T-88 se llega desde Parámetros sin viaje', (tester) async {
    await tester.pumpWidget(_app(const ParametersPage(), overrides: [
      localVesselRepositoryProvider.overrideWith((ref) async => _Settings()),
    ]));
    await tester.pumpAndSettle();
    expect(find.text('Parámetros del buque'), findsNothing, reason: 'sin viaje abierto');
    await tester.tap(find.byKey(const ValueKey('privacy-policy')));
    await tester.pumpAndSettle();
    expect(find.byType(PrivacyPolicyPage), findsOneWidget);
    expect(find.text(kPrivacyPolicyTitle), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('T-88 se llega desde el inicio de sesión, sin sesión', (tester) async {
    await narrow(tester);
    await tester.pumpWidget(_app(const CloudPage(), overrides: [
      sessionRepositoryProvider.overrideWith((ref) async => _SignedOut()),
      operationSyncProvider.overrideWith((ref) async => const LocalOnlyOperationSync()),
      movementLogRepositoryProvider.overrideWith((ref) async => T75MemoryLog()),
    ]));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('sign-in-button')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('sign-in-privacy-policy')));
    await tester.pumpAndSettle();
    expect(find.byType(PrivacyPolicyPage), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test('T-88 D3 y D9 en el manifiesto de Android', () {
    final manifest = File('android/app/src/main/AndroidManifest.xml').readAsStringSync();
    expect(manifest, contains('android:label="BayStream"'));
    expect(manifest, contains('android:allowBackup="false"'));
    expect(manifest, contains('android:dataExtractionRules="@xml/data_extraction_rules"'));
    final rules = File('android/app/src/main/res/xml/data_extraction_rules.xml').readAsStringSync();
    expect(rules, isNot(contains('<include')));
    const domains = ['root', 'file', 'database', 'sharedpref', 'external', 'device_root',
        'device_file', 'device_database', 'device_sharedpref'];
    for (final section in ['cloud-backup', 'device-transfer']) {
      final body = RegExp('<$section>(.*?)</$section>', dotAll: true).firstMatch(rules)!.group(1)!;
      for (final domain in domains) {
        expect(body, contains('<exclude domain="$domain" path="." />'), reason: '$section $domain');
      }
    }
  });

  test('T-88 D9 en Windows: la ventana y el ejecutable dicen BayStream (10.47)', () {
    final main = File('windows/runner/main.cpp').readAsStringSync();
    expect(main, contains('window.Create(L"BayStream", origin, size)'));
    final rc = File('windows/runner/Runner.rc').readAsStringSync();
    expect(rc, contains(r'VALUE "FileDescription", "BayStream" "\0"'));
    expect(rc, contains(r'VALUE "ProductName", "BayStream" "\0"'));
  });

  test('T-88 el script de T-93 da la indicación del .cer también con UnknownError', () {
    final script = File('tool/t93_msix.ps1').readAsBytesSync();
    expect(script.every((byte) => byte < 128), isTrue, reason: 'el script va en ASCII');
    final text = String.fromCharCodes(script);
    expect(text, contains(r"} elseif ($firma.Status -eq 'UnknownError') {"));
    expect(text, contains("'La firma no es de confianza en este equipo o no se pudo validar. "
        'Si no ha importado BayStream.cer en Personas de confianza del equipo local, '
        "importelo primero.'"));
    expect(text, contains(r'$detalle = "Status: $($firma.Status). StatusMessage: $($firma.StatusMessage)"'));
  });
}
