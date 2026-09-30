import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

/// Uso: dart run tool/t44_honor_bay_plan.dart A01 5
///
/// Requiere el archivo ya cargado en el Honor X5d y la pantalla Lista o Bay Plan.
/// La cifra es una cota superior: incluye ADB, captura PNG y su transferencia.
Future<void> main(List<String> args) async {
  if (args.isEmpty || args.length > 2) {
    stderr.writeln('Uso: dart run tool/t44_honor_bay_plan.dart ETIQUETA [N]');
    exitCode = 64;
    return;
  }
  final repetitions = args.length == 2 ? int.parse(args[1]) : 5;
  final adb = Platform.environment['T44_ADB'] ??
      r'C:\Users\Giova\AppData\Local\Android\Sdk\platform-tools\adb.exe';
  final results = <Map<String, Object>>[];

  for (var repetition = 1; repetition <= repetitions; repetition++) {
    await _adb(adb, ['shell', 'input', 'tap', '120', '270']);
    var listReady = false;
    for (var attempt = 0; attempt < 5; attempt++) {
      await Future<void>.delayed(const Duration(milliseconds: 200));
      final listShot = await _capture(adb);
      if (!_hasBayGrid(listShot)) {
        listReady = true;
        break;
      }
    }
    if (!listReady) {
      throw StateError('Repetición $repetition: no volvió a Lista');
    }

    final watch = Stopwatch()..start();
    await _adb(adb, ['shell', 'input', 'tap', '360', '270']);
    var previousCaptureEndMs = 0;
    var captures = 0;
    while (true) {
      final shotWatch = Stopwatch()..start();
      final shot = await _capture(adb);
      shotWatch.stop();
      captures++;
      final observedMs = watch.elapsedMilliseconds;
      if (_hasBayGrid(shot)) {
        results.add({
          'repetition': repetition,
          'lowerBoundMs': previousCaptureEndMs,
          'upperBoundMs': observedMs,
          'captures': captures,
          'lastCaptureMs': shotWatch.elapsedMilliseconds,
        });
        stdout.writeln('${args.first} $repetition: '
            '[$previousCaptureEndMs, $observedMs] ms; '
            'capturas=$captures; última=${shotWatch.elapsedMilliseconds} ms');
        break;
      }
      previousCaptureEndMs = observedMs;
      if (observedMs > 10000) {
        throw StateError('Repetición $repetition: la rejilla no apareció');
      }
    }
  }

  final upper = results.map((r) => r['upperBoundMs']! as int).toList()..sort();
  final median = upper[upper.length ~/ 2];
  final output = {
    'label': args.first,
    'device': 'Honor X5d / Android 15',
    'method': 'Orden adb input tap Bay Plan -> primera captura PNG con rejilla',
    'limitation': 'Cota superior; incluye ADB, captura y transferencia',
    'repetitions': results,
    'medianUpperBoundMs': median,
    'maximumUpperBoundMs': upper.last,
  };
  final file = File('build/t44/honor-${args.first.toLowerCase()}-bayplan.json');
  await file.writeAsString(const JsonEncoder.withIndent('  ').convert(output));
  stdout.writeln(
      'Mediana superior: $median ms; máximo superior: ${upper.last} ms');
}

Future<void> _adb(String executable, List<String> args) async {
  final result = await Process.run(executable, args);
  if (result.exitCode != 0) {
    throw ProcessException(executable, args,
        '${result.stdout}\n${result.stderr}', result.exitCode);
  }
}

Future<List<int>> _capture(String executable) async {
  final result = await Process.run(executable, ['exec-out', 'screencap', '-p'],
      stdoutEncoding: null);
  if (result.exitCode != 0) {
    throw ProcessException(executable, ['exec-out', 'screencap', '-p'],
        result.stderr.toString(), result.exitCode);
  }
  return result.stdout as List<int>;
}

bool _hasBayGrid(List<int> png) {
  final bytes = Uint8List.fromList(png);
  if (bytes.length < 33 ||
      bytes.buffer.asByteData().getUint32(16) != 720 ||
      bytes.buffer.asByteData().getUint32(20) != 1600 ||
      bytes[24] != 8 ||
      bytes[25] != 6) {
    throw StateError('Captura PNG RGBA del Honor inesperada');
  }
  final compressed = BytesBuilder(copy: false);
  var offset = 8;
  while (offset + 12 <= bytes.length) {
    final length = bytes.buffer.asByteData().getUint32(offset);
    final type = ascii.decode(bytes.sublist(offset + 4, offset + 8));
    if (type == 'IDAT') {
      compressed.add(bytes.sublist(offset + 8, offset + 8 + length));
    }
    offset += 12 + length;
    if (type == 'IEND') break;
  }
  final raw = ZLibDecoder().convert(compressed.takeBytes());
  const widthBytes = 720 * 4;
  var previous = Uint8List(widthBytes);
  var bright = 0;
  const sampleYs = [820, 900, 980, 1060, 1140, 1220, 1300];
  const sampleXs = [150, 250, 350, 450, 550, 650];
  for (var y = 0; y <= sampleYs.last; y++) {
    final rowStart = y * (widthBytes + 1);
    final filter = raw[rowStart];
    final row = Uint8List(widthBytes);
    for (var i = 0; i < widthBytes; i++) {
      final left = i >= 4 ? row[i - 4] : 0;
      final above = previous[i];
      final upperLeft = i >= 4 ? previous[i - 4] : 0;
      final predictor = switch (filter) {
        0 => 0,
        1 => left,
        2 => above,
        3 => (left + above) ~/ 2,
        4 => _paeth(left, above, upperLeft),
        _ => throw StateError('Filtro PNG no soportado: $filter'),
      };
      row[i] = (raw[rowStart + 1 + i] + predictor) & 0xff;
    }
    if (sampleYs.contains(y)) {
      for (final x in sampleXs) {
        final i = x * 4;
        if (row[i] > 210 && row[i + 1] > 210 && row[i + 2] > 210) {
          bright++;
        }
      }
    }
    previous = row;
  }
  return bright >= 8;
}

int _paeth(int left, int above, int upperLeft) {
  final prediction = left + above - upperLeft;
  final leftDistance = (prediction - left).abs();
  final aboveDistance = (prediction - above).abs();
  final cornerDistance = (prediction - upperLeft).abs();
  if (leftDistance <= aboveDistance && leftDistance <= cornerDistance) {
    return left;
  }
  if (aboveDistance <= cornerDistance) return above;
  return upperLeft;
}
