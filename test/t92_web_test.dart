import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../tool/t92_verify.dart';

void main() {
  test('T-92 SDK servido coincide con los paquetes resueltos', () {
    expect(
        Directory('web/vendor/firebase/${supportedSdkVersion()}').existsSync(),
        isTrue);
    expect(verifySources(), isEmpty);
  });

  test('T-92 todos los imports del SDK son relativos y existen', () {
    final directory = Directory('web/vendor/firebase/${supportedSdkVersion()}');
    var importCount = 0;
    for (final file
        in filesIn(directory).where((file) => file.path.endsWith('.js'))) {
      for (final match in moduleImports.allMatches(file.readAsStringSync())) {
        final path = match.group(1)!;
        importCount++;
        expect(path, startsWith('./'), reason: file.path);
        expect(File.fromUri(file.uri.resolve(path)).existsSync(), isTrue);
      }
    }
    expect(importCount, greaterThanOrEqualTo(2));
  });

  test('T-92 publica los tres módulos antes de inicializar el motor', () {
    final source = File('web/flutter_bootstrap.js').readAsStringSync();
    final initialize =
        source.indexOf('await engineInitializer.initializeEngine(');
    expect(initialize, greaterThan(0));
    for (final global in [
      'firebase_core',
      'firebase_auth',
      'firebase_firestore'
    ]) {
      expect(
          source.indexOf('window.$global ='), inExclusiveRange(0, initialize));
    }
    expect(source.indexOf("'firebase-app.js', sdkBase"),
        lessThan(source.indexOf('Promise.all([')));
    expect(source, contains('await appRunner.runApp()'));
  });

  test('T-92 plantilla fija motor y fuentes propios con SW de Flutter', () {
    final source = File('web/flutter_bootstrap.js').readAsStringSync();
    expect(
        source,
        contains(
            "canvasKitBaseUrl: new URL('canvaskit/', document.baseURI).href"));
    expect(
        source,
        contains(
            "fontFallbackBaseUrl: new URL('fonts/', document.baseURI).href"));
    expect(source, contains('config: bayStreamConfig'));
    expect(source, contains('initializeEngine(bayStreamConfig)'));
    expect(source,
        contains('serviceWorkerVersion: {{flutter_service_worker_version}}'));
    expect(source, contains("'controllerchange'"));
    expect(source, isNot(contains('downloadOffline')));
    expect(source, isNot(contains('https://')));
  });

  test('T-92 terceros conservan licencia y huellas de procedencia', () {
    for (final folder in [
      Directory('web/fonts'),
      Directory('web/vendor/firebase/${supportedSdkVersion()}')
    ]) {
      final records =
          jsonDecode(File('${folder.path}/provenance.json').readAsStringSync())
              as List;
      expect(records, isNotEmpty);
      for (final record in records) {
        final license =
            File('${folder.path}/${record['license']}').readAsStringSync();
        expect(
            license,
            anyOf(
                contains('Apache License'), contains('SIL OPEN FONT LICENSE')));
        expect(record['url'], startsWith('https://'));
        expect(record['originalSha256'], matches(r'^[A-F0-9]{64}$'));
        expect(record['servedSha256'], matches(r'^[A-F0-9]{64}$'));
      }
    }
  });

  test('T-92 primera visita guarda la URL raiz mediante el SW original', () {
    final source = File('web/flutter_bootstrap.js').readAsStringSync();
    final rootFetch =
        source.indexOf("await fetch(new URL('./', document.baseURI)");
    expect(rootFetch, greaterThan(source.indexOf("'controllerchange'")));
    expect(rootFetch, lessThan(source.indexOf('window.firebase_core =')));
    expect(source, contains('if (navigator.serviceWorker?.controller)'));
    expect(source, isNot(contains('caches.open(')));
  });

  test('T-92 nombre y lengua de la Web son BayStream y español', () {
    final index = File('web/index.html').readAsStringSync();
    final manifest =
        jsonDecode(File('web/manifest.json').readAsStringSync()) as Map;
    expect(index, contains('<html lang="es">'));
    expect(index, contains('<title>BayStream</title>'));
    expect(index, contains('apple-mobile-web-app-title" content="BayStream"'));
    expect(manifest['name'], 'BayStream');
    expect(manifest['short_name'], 'BayStream');
    expect(manifest['lang'], 'es');
  });
}
