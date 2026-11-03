import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Las entradas de primer nivel de `msix_config` en pubspec.yaml, como texto:
/// el paquete `yaml` no es dependencia directa y no hace falta para esto.
Map<String, String> msixConfig(String pubspec) {
  final lines = pubspec.split(RegExp(r'\r?\n'));
  final start = lines.indexOf('msix_config:');
  expect(start, greaterThanOrEqualTo(0), reason: 'falta msix_config');
  final config = <String, String>{};
  for (final line in lines.skip(start + 1)) {
    if (line.isNotEmpty && !line.startsWith(' ')) break;
    final match = RegExp(r'^  ([a-z_]+):\s*(.*)$').firstMatch(line);
    if (match != null) config[match.group(1)!] = match.group(2)!.trim();
  }
  return config;
}

void main() {
  final pubspec = File('pubspec.yaml').readAsStringSync();

  test('T-93 msix_config no compila ni instala certificados por su cuenta', () {
    final config = msixConfig(pubspec);
    expect(config['build_windows'], 'false');
    expect(config['install_certificate'], 'false');
    expect(config.containsKey('sign_msix'), isFalse);
    expect(config.containsKey('store'), isFalse);
  });

  test('T-93 msix_config identifica la app con el sujeto del certificado', () {
    final config = msixConfig(pubspec);
    expect(config['publisher'], 'CN=BayStream');
    expect(config['identity_name'], 'gt.cmartinez.baystream');
    expect(config['display_name'], 'BayStream');
    // El MSIX lleva la versión del pubspec con «.0» al final (10.77): fijar
    // el número rompía la prueba en cada versión nueva.
    final version = RegExp(r'^version:\s*(\d+\.\d+\.\d+)\+\d+\s*$',
            multiLine: true)
        .firstMatch(pubspec);
    expect(version, isNotNull, reason: 'falta la línea version: x.y.z+n');
    expect(config['msix_version'], '${version!.group(1)}.0');
    expect(config['capabilities'], 'internetClient');
    expect(config['logo_path'], 'web/icons/Icon-512.png');
  });

  test('T-93 pubspec.yaml no guarda contraseña, certificado ni huella', () {
    final config = msixConfig(pubspec);
    for (final key in [
      'certificate_path',
      'certificate_password',
      'signtool_options',
    ]) {
      expect(config.containsKey(key), isFalse, reason: key);
    }
    final lower = pubspec.toLowerCase();
    for (final forbidden in ['.pfx', '.p12', 'password', '/sha1', '/p ']) {
      expect(lower.contains(forbidden), isFalse, reason: forbidden);
    }
    // Una huella SHA-1 son 40 hexadecimales seguidos.
    expect(RegExp(r'[0-9a-fA-F]{40}').hasMatch(pubspec), isFalse);
  });

  test('T-93 msix es solo de desarrollo y con versión fija', () {
    final dev = pubspec.substring(pubspec.indexOf('dev_dependencies:'));
    final main = pubspec.substring(0, pubspec.indexOf('dev_dependencies:'));
    expect(main.contains(RegExp(r'^\s+msix:', multiLine: true)), isFalse);
    expect(dev, contains(RegExp(r'^  msix: 3\.18\.0\s*$', multiLine: true)));
    final lock = File('pubspec.lock').readAsStringSync();
    expect(
        lock,
        contains(RegExp(r'  msix:\r?\n    dependency: "direct dev"'
            r'(\r?\n.*){5}\r?\n    version: "3\.18\.0"')));
  });

  test('T-93 el script compila con Firebase y firma por huella', () {
    final script = File('tool/t93_msix.ps1').readAsStringSync();
    expect(script, contains('flutter build windows --release'));
    expect(script, contains('--dart-define-from-file='));
    expect(script, contains('--build-windows false'));
    expect(script, contains('--install-certificate false'));
    expect(script, contains(r"if ($firma.Status -ne 'Valid')"));
    expect(script, contains(r'"/fd SHA256 /sha1 $Huella"'));
    expect(script.indexOf('flutter build windows'),
        lessThan(script.indexOf('dart run msix:create')));
    expect(RegExp(r'[0-9a-fA-F]{40}').hasMatch(script), isFalse);
    expect(script, isNot(contains('--certificate-path')));
    expect(script, isNot(contains('--certificate-password')));
  });

  test('T-136 el script comprueba el SDK de Firebase antes de empaquetar', () {
    final script = File('tool/t93_msix.ps1').readAsStringSync();
    // Los comandos de verdad: el encabezado del script también nombra
    // «flutter build windows» y «dart run msix:create».
    final pubGet = script.indexOf('& flutter pub get');
    final apartar = script.indexOf(r'& $sdkFirebase -Proyecto $repo -Apartar');
    final compilar = script.indexOf('& flutter build windows');
    final empaquetar = script.indexOf('& dart run msix:create');
    expect(script, contains('t136_sdk_firebase.ps1'));
    expect(pubGet, greaterThanOrEqualTo(0));
    expect(pubGet, lessThan(apartar));
    expect(apartar, lessThan(compilar));
    // En la columna 0, fuera del bloque de compilar: con -SinCompilar también
    // se comprueba, y la comprobación queda después de compilar.
    final verificar = RegExp(r'^& \$sdkFirebase -Proyecto \$repo -Verificar',
            multiLine: true)
        .firstMatch(script);
    expect(verificar, isNotNull);
    expect(compilar, lessThan(verificar!.start));
    expect(verificar.start, lessThan(empaquetar));
  });
}
