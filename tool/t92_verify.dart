import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';

final moduleImports = RegExp(
  r'''(?:\bfrom\s*|\bimport\s*\(\s*|\bimport\s*)["']([^"']+)["']''',
);

String relativePath(Directory root, File file) => file.absolute.path
    .substring(root.absolute.path.length + 1)
    .replaceAll('\\', '/');

List<File> filesIn(Directory directory) =>
    directory.listSync(recursive: true).whereType<File>().toList();

Directory resolvedPackage(String name) {
  final configFile = File('.dart_tool/package_config.json').absolute;
  final config =
      jsonDecode(configFile.readAsStringSync()) as Map<String, dynamic>;
  final packages = (config['packages'] as List).cast<Map<String, dynamic>>();
  final package = packages.singleWhere((entry) => entry['name'] == name);
  return Directory.fromUri(
      configFile.uri.resolve(package['rootUri'] as String));
}

String supportedSdkVersion() {
  final source = File(
    '${resolvedPackage('firebase_core_web').path}/lib/src/firebase_sdk_version.dart',
  ).readAsStringSync();
  return RegExp(r'''supportedFirebaseJsSdkVersion\s*=\s*['"]([^'"]+)''')
      .firstMatch(source)!
      .group(1)!;
}

List<String> verifySources({Directory? root}) {
  final web = root ?? Directory('web');
  final errors = <String>[];
  final sdkVersion = supportedSdkVersion();
  final vendor = Directory('${web.path}/vendor/firebase/$sdkVersion');
  if (!vendor.existsSync()) return ['Falta el SDK $sdkVersion resuelto.'];
  final bootstrap = File('${web.path}/flutter_bootstrap.js').readAsStringSync();
  if (!bootstrap.contains('vendor/firebase/$sdkVersion/')) {
    errors.add('La plantilla no usa la versión resuelta.');
  }
  for (final folder in [vendor, Directory('${web.path}/fonts')]) {
    final provenance = File('${folder.path}/provenance.json');
    if (!provenance.existsSync()) {
      errors.add('Falta procedencia en ${folder.path}.');
      continue;
    }
    final entries = (jsonDecode(provenance.readAsStringSync()) as List)
        .cast<Map<String, dynamic>>();
    final recorded = <String>{};
    for (final entry in entries) {
      final path = entry['file'] as String;
      recorded.add(path);
      final file = File('${folder.path}/$path');
      final license = File('${folder.path}/${entry['license']}');
      if (!license.existsSync() || license.lengthSync() == 0) {
        errors.add('Falta licencia de $path.');
      }
      if (!file.existsSync()) {
        errors.add('Falta $path.');
        continue;
      }
      final hash =
          sha256.convert(file.readAsBytesSync()).toString().toUpperCase();
      if (hash != entry['servedSha256']) {
        errors.add('SHA servido distinto: $path.');
      }
      if (!RegExp(r'^[A-Fa-f0-9]{64}$')
          .hasMatch(entry['originalSha256'] as String)) {
        errors.add('SHA original inválido: $path.');
      }
      if (path.endsWith('.js')) {
        final source = file.readAsStringSync();
        for (final match in moduleImports.allMatches(source)) {
          final imported = match.group(1)!;
          if (!imported.startsWith('./') && !imported.startsWith('../')) {
            errors.add('Import no relativo en $path: $imported.');
          } else if (!File.fromUri(file.uri.resolve(imported)).existsSync()) {
            errors.add('Import ausente en $path: $imported.');
          }
        }
      }
    }
    for (final file in filesIn(folder)) {
      final path = relativePath(folder, file);
      if ((path.endsWith('.js') || path.endsWith('.woff2')) &&
          !recorded.contains(path)) {
        errors.add('Archivo de tercero sin procedencia: $path.');
      }
    }
  }
  return errors;
}

List<String> verifyBuild(Directory site) {
  final errors = verifySources();
  final bootstrapFile = File('${site.path}/flutter_bootstrap.js');
  final workerFile = File('${site.path}/flutter_service_worker.js');
  if (!bootstrapFile.existsSync() || !workerFile.existsSync()) {
    return [...errors, 'Falta bootstrap o service worker compilado.'];
  }
  final bootstrap = bootstrapFile.readAsStringSync();
  for (final token in [
    '{{flutter_js}}',
    '{{flutter_build_config}}',
    '{{flutter_service_worker_version}}'
  ]) {
    if (bootstrap.contains(token)) errors.add('Token sin resolver: $token.');
  }
  for (final setting in [
    "new URL('canvaskit/', document.baseURI)",
    "new URL('fonts/', document.baseURI)"
  ]) {
    if (!bootstrap.contains(setting)) {
      errors.add('Falta ruta propia: $setting.');
    }
  }
  final flutter = resolvedPackage('flutter').parent.parent;
  final engineStamp =
      File('${flutter.path}/bin/cache/engine.stamp').readAsStringSync().trim();
  if (!bootstrap.contains(engineStamp)) {
    errors.add('Revisión de motor inesperada.');
  }
  final fontSource = File(
    '${flutter.path}/engine/src/flutter/lib/web_ui/lib/src/engine/canvaskit/fonts.dart',
  ).readAsStringSync();
  final roboto =
      RegExp(r'roboto/[^\s\x27\x22]+\.woff2').firstMatch(fontSource)?.group(0);
  if (roboto == null || !File('${site.path}/fonts/$roboto').existsSync()) {
    errors.add('Falta Roboto en la ruta del motor instalado.');
  }
  for (final path in [
    'canvaskit/canvaskit.js',
    'canvaskit/canvaskit.wasm',
    'canvaskit/chromium/canvaskit.js',
    'canvaskit/chromium/canvaskit.wasm'
  ]) {
    if (!File('${site.path}/$path').existsSync()) errors.add('Falta $path.');
  }
  final worker = workerFile.readAsStringSync();
  final resourceMatch =
      RegExp(r'const RESOURCES = (\{[\s\S]*?\});').firstMatch(worker);
  if (resourceMatch == null) return [...errors, 'Lista RESOURCES ilegible.'];
  final resources = jsonDecode(resourceMatch.group(1)!) as Map<String, dynamic>;
  // Comparación del SW con su plantilla: solo se sustituyen los dos tokens.
  final workerTemplate = File(
    '${flutter.path}/packages/flutter_tools/lib/src/web/file_generators/js/flutter_service_worker.js',
  ).readAsStringSync();
  final core =
      RegExp(r'const CORE = (\[[\s\S]*?\]);').firstMatch(worker)?.group(1);
  final expectedWorker = workerTemplate
      .replaceAll(r'$$RESOURCES_MAP', resourceMatch.group(1)!)
      .replaceAll(r'$$CORE_LIST', core ?? '');
  if (worker.replaceAll('\r\n', '\n') !=
      expectedWorker.replaceAll('\r\n', '\n')) {
    errors.add('El service worker difiere de la plantilla de Flutter.');
  }
  final canvasKit =
      Directory('${flutter.path}/bin/cache/flutter_web_sdk/canvaskit');
  final allowed = <String>{
    'index.html',
    'flutter_bootstrap.js',
    'flutter.js',
    'main.dart.js',
    'flutter_service_worker.js',
    'version.json',
    '.last_build_id',
    'assets/AssetManifest.bin',
    'assets/AssetManifest.bin.json',
    'assets/FontManifest.json',
    'assets/NOTICES',
    'assets/shaders/ink_sparkle.frag',
    'assets/shaders/stretch_effect.frag',
    ...filesIn(Directory('assets')).map(
        (file) => 'assets/assets/${relativePath(Directory('assets'), file)}'),
    ...filesIn(canvasKit)
        .map((file) => 'canvaskit/${relativePath(canvasKit, file)}'),
    ...filesIn(Directory('web'))
        .map((file) => relativePath(Directory('web'), file)),
  };
  final fontManifest = jsonDecode(
    File('${site.path}/assets/FontManifest.json').readAsStringSync(),
  ) as List;
  for (final family in fontManifest) {
    for (final font in family['fonts'] as List) {
      allowed.add('assets/${font['asset']}');
    }
  }
  for (final file in filesIn(site)) {
    final path = relativePath(site, file);
    if (!allowed.contains(path)) {
      errors.add('Archivo sobrante: $path.');
    }
    if (path.contains('t54-format')) errors.add('Artefacto viejo: $path.');
    if (path == 'flutter_service_worker.js' || path.startsWith('.')) continue;
    if (!resources.containsKey(path)) {
      errors.add('Fuera de RESOURCES: $path.');
    } else if (resources[path] !=
        md5.convert(file.readAsBytesSync()).toString()) {
      errors.add('Hash del SW distinto: $path.');
    }
  }
  for (final source in filesIn(Directory('web'))) {
    final path = relativePath(Directory('web'), source);
    if (path == 'index.html' || path == 'flutter_bootstrap.js') continue;
    final compiled = File('${site.path}/$path');
    if (!compiled.existsSync() ||
        sha256.convert(compiled.readAsBytesSync()) !=
            sha256.convert(source.readAsBytesSync())) {
      errors.add('Recurso propio ausente o distinto: $path.');
    }
  }
  return errors;
}

void main(List<String> arguments) {
  if (arguments.length != 1) {
    stderr.writeln('Uso: dart run tool/t92_verify.dart <sitio-compilado>');
    exitCode = 64;
    return;
  }
  final site = Directory(arguments.single);
  if (!site.existsSync()) {
    stderr.writeln('No existe el sitio compilado.');
    exitCode = 64;
    return;
  }
  final errors = verifyBuild(site);
  if (errors.isNotEmpty) {
    for (final error in errors) {
      stderr.writeln(error);
    }
    exitCode = 1;
  } else {
    final files = filesIn(site);
    stdout.writeln('T-92: verificador correcto · ${files.length} archivos · '
        '${files.fold<int>(0, (sum, file) => sum + file.lengthSync())} bytes.');
  }
}
