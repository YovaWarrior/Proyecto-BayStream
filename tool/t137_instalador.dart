// T-137 · Empaqueta una Release existente; nunca compila ni abre BayStream.
// Dart estándar, sin paquetes. PowerShell lee recursos PE y calcula SHA-256;
// dumpbin inspecciona las importaciones e ISCC construye el asistente.
// Ejecutar solo con el semáforo de Carlos.
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

const _uso = '''
dart run tool/t137_instalador.dart [opciones]
  --origen RUTA             Release, o raíz del proyecto que la compiló.
                            Por omisión: build/windows/x64/runner/Release.
  --variante produccion|prueba  Por omisión: produccion.
  --salida RUTA             Por omisión: build/t137.
  --help                   Muestra esta ayuda sin empaquetar.

No ejecuta Flutter, Dart, la app, un instalador ni una desinstalación.
Requiere Inno Setup 7.1.1, dumpbin y el arte generado con Flutter.
T137_ISCC y T137_DUMPBIN permiten indicar esas herramientas explícitamente.
La variante de prueba nunca se publica ni ofrece abrir la app.
''';

// Identidades permanentes. No regenerar estos GUID al cambiar la versión.
const _appIdProduccion = 'D837B138-34EF-4B47-9B86-58295383D542';
const _appIdPrueba = '71B5E2CB-F84C-46C9-A7CA-684EA57A5137';

Future<void> main(List<String> argumentos) async {
  try {
    if (argumentos.length == 1 &&
        (argumentos.single == '--help' || argumentos.single == '-h')) {
      stdout.write(_uso);
      return;
    }
    final opciones = _opciones(argumentos);
    if (!Platform.isWindows) {
      throw const _Fallo('Este programa necesita Windows de 64 bits.');
    }
    await _armar(opciones);
  } on FormatException catch (error) {
    stderr
      ..writeln(error.message)
      ..write(_uso);
    exitCode = 64;
  } on _Fallo catch (error) {
    stderr.writeln('T-137: ${error.mensaje}');
    exitCode = 1;
  } on FileSystemException catch (error) {
    stderr.writeln('T-137: ${error.message}: ${error.path ?? ''}');
    exitCode = 1;
  } on ProcessException catch (error) {
    stderr.writeln(
      'T-137: no se pudo ejecutar ${error.executable}: '
      '${error.message}',
    );
    exitCode = 1;
  }
}

Map<String, String> _opciones(List<String> argumentos) {
  final opciones = <String, String>{
    'origen': _ruta(Directory.current.path, 'build/windows/x64/runner/Release'),
    'variante': 'produccion',
    'salida': _ruta(Directory.current.path, 'build/t137'),
  };
  final vistas = <String>{};
  for (var i = 0; i < argumentos.length; i++) {
    final argumento = argumentos[i];
    final igual = argumento.indexOf('=');
    final opcion = igual < 0 ? argumento : argumento.substring(0, igual);
    if (!opcion.startsWith('--') ||
        !opciones.containsKey(opcion.substring(2))) {
      throw FormatException('Opción desconocida: $opcion');
    }
    final nombre = opcion.substring(2);
    if (!vistas.add(nombre)) {
      throw FormatException('La opción $opcion está repetida.');
    }
    final String valor;
    if (igual >= 0) {
      valor = argumento.substring(igual + 1);
    } else {
      if (++i == argumentos.length || argumentos[i].startsWith('--')) {
        throw FormatException('Falta el valor de $opcion.');
      }
      valor = argumentos[i];
    }
    if (valor.trim().isEmpty) {
      throw FormatException('El valor de $opcion está vacío.');
    }
    opciones[nombre] = valor;
  }
  if (!['produccion', 'prueba'].contains(opciones['variante'])) {
    throw const FormatException('--variante debe ser produccion o prueba.');
  }
  return opciones;
}

Future<void> _armar(Map<String, String> opciones) async {
  final proyecto = File.fromUri(Platform.script).parent.parent;
  final guion = File(_ruta(proyecto.path, 'windows/installer/baystream.iss'));
  _exigirArchivo(guion);
  var origen = Directory(opciones['origen']!).absolute;
  if (File(_ruta(origen.path, 'pubspec.lock')).existsSync()) {
    origen = Directory(_ruta(origen.path, 'build/windows/x64/runner/Release'));
  }
  if (!origen.existsSync()) {
    throw _Fallo('No existe la Release: ${origen.path}');
  }
  origen = Directory(origen.resolveSymbolicLinksSync());
  final exe = File(_ruta(origen.path, 'baystream.exe'));
  _exigirArchivo(exe);
  final raizOrigen = _raizDeRelease(origen);
  final prueba = opciones['variante'] == 'prueba';
  final appId = prueba ? _appIdPrueba : _appIdProduccion;
  final salida = Directory(opciones['salida']!).absolute;
  _protegerSalida(salida, origen, proyecto);

  // Todo el preflight precede a la primera escritura. En especial, se
  // compara el SDK extraído, no el nombre del zip que quedó en build/.
  final archivosOrigen = _archivos(origen);
  await _exigirX64(exe);
  final metadatos = await _metadatos(raizOrigen, exe);
  final arte = await _comprobarArte(proyecto);
  final iscc = await _buscarIscc();
  final dumpbin = await _buscarDumpbin();
  final runtime = await _buscarRuntime(origen);
  final antes = await _huellas(archivosOrigen);
  final fuentes = (metadatos['fuentes']! as List).cast<String>();
  final fuentesAntes = await _huellas(fuentes.map(File.new).toList());

  final sello = DateTime.now().toUtc().toIso8601String().replaceAll(':', '-');
  _prepararSalida(salida);
  final corrida = Directory(
    _ruta(salida.path, 'corridas/${opciones['variante']}-$sello'),
  );
  corrida.createSync(recursive: true);
  final preparando = Directory(_ruta(corrida.path, 'app'))..createSync();
  stdout.writeln(
    'T-137: Release ${metadatos['version']} · '
    '${opciones['variante']} · ${archivosOrigen.length} archivos de origen.',
  );
  for (final archivo in archivosOrigen) {
    final relativo = _relativa(archivo, origen);
    final copia = File(_ruta(preparando.path, relativo));
    copia.parent.createSync(recursive: true);
    archivo.copySync(copia.path);
  }
  for (final entrada in runtime) {
    final destino = File(_ruta(preparando.path, entrada['nombre']! as String));
    if (!destino.existsSync()) {
      File(entrada['origen']! as String).copySync(destino.path);
    }
  }

  final appArchivos = _archivos(preparando);
  final inventario = await _huellas(appArchivos);
  final porRuta = <String, Map<String, Object?>>{
    for (var i = 0; i < appArchivos.length; i++)
      _relativa(appArchivos[i], preparando).toLowerCase(): inventario[i],
  };
  if (porRuta.length != appArchivos.length) {
    throw const _Fallo(
      'La carga tiene nombres que solo difieren en mayúsculas.',
    );
  }
  for (var i = 0; i < archivosOrigen.length; i++) {
    final relativo = _relativa(archivosOrigen[i], origen).toLowerCase();
    if (porRuta[relativo]?['sha256'] != antes[i]['sha256']) {
      throw _Fallo('La copia no coincide con la Release: $relativo');
    }
  }
  for (final entrada in runtime) {
    if (porRuta[(entrada['nombre']! as String).toLowerCase()]?['sha256'] !=
        entrada['sha256']) {
      throw _Fallo('La copia del runtime cambió: ${entrada['nombre']}.');
    }
  }
  final dependencias = await _dependencias(preparando, dumpbin, corrida);
  // Un cambio concurrente en la Release o en sus metadatos invalida la
  // corrida. No se modifica ni se aparta ningún archivo del origen.
  _compararHuellas(antes, await _huellas(_archivos(origen)), 'Release');
  _compararHuellas(
    fuentesAntes,
    await _huellas(fuentes.map(File.new).toList()),
    'metadatos de la compilación',
  );
  if (jsonEncode(metadatos) != jsonEncode(await _metadatos(raizOrigen, exe))) {
    throw const _Fallo(
      'Los metadatos cambiaron entre su lectura y la preparación.',
    );
  }

  final app = Directory(_ruta(salida.path, 'app'));
  // No hay borrados recursivos: se conserva la preparación anterior como
  // evidencia, también si después falla ISCC.
  if (app.existsSync()) {
    app.renameSync(_ruta(corrida.path, 'app-anterior'));
  }
  preparando.renameSync(app.path);
  final version = metadatos['version']! as String;
  final nombre = 'BayStream_Setup_$version${prueba ? '_prueba' : ''}';
  final instalador = File(_ruta(salida.path, '$nombre.exe'));
  for (final extension in [
    '.exe',
    '.exe.sha256',
    '.manifiesto.json',
    '.inno-manifiesto.txt',
  ]) {
    final anterior = File(_ruta(salida.path, '$nombre$extension'));
    if (anterior.existsSync()) {
      anterior.renameSync(_ruta(corrida.path, 'anterior-$nombre$extension'));
    }
  }
  final include = File(_ruta(corrida.path, 'compilacion.iss'));
  final constantes = <String, String>{
    'T137Variante': prueba ? 'prueba' : 'produccion',
    'T137AppId': appId,
    'T137OtroAppId': prueba ? _appIdProduccion : _appIdPrueba,
    'T137AppName': prueba ? 'BayStream (prueba T-137)' : 'BayStream',
    'T137Publisher': metadatos['editor']! as String,
    'T137IdentidadMsix': metadatos['identidadMsix']! as String,
    'T137Carpeta': prueba ? 'BayStream-Prueba-T137' : 'BayStream',
    'T137OtraCarpeta': prueba ? 'BayStream' : 'BayStream-Prueba-T137',
    'T137AppDir': app.path,
    'T137Salida': salida.path,
    'T137NombreSalida': nombre,
    'T137Version': version,
    'T137Flutter': metadatos['flutter']! as String,
    'T137Dart': metadatos['dart']! as String,
    'T137Firestore': metadatos['cloud_firestore']! as String,
    'T137FirebaseCore': metadatos['firebase_core']! as String,
    'T137FirebaseCpp': metadatos['firebaseCpp']! as String,
    'T137Riverpod': metadatos['flutter_riverpod']! as String,
    'T137Icono': _ruta(proyecto.path, 'windows/runner/resources/app_icon.ico'),
    ..._constantesArte(arte, proyecto),
  };
  include.writeAsStringSync(
    '\uFEFF; Generado por T-137: datos de la Release, sin versiones manuales.\n'
    '${constantes.entries.map((e) => _definir(e.key, e.value)).join('\n')}\n',
    flush: true,
  );
  final carga = <Map<String, Object?>>[
    for (var i = 0; i < appArchivos.length; i++)
      {
        'archivo': _relativa(appArchivos[i], preparando),
        'bytes': inventario[i]['bytes'],
        'sha256': inventario[i]['sha256'],
        'procedencia': antes.any((a) => a['sha256'] == inventario[i]['sha256'])
            ? 'Release sin cambios'
            : 'runtime Visual C++ junto al ejecutable',
      },
  ];
  final manifiesto = <String, Object?>{
    'schema': 1,
    'variante': opciones['variante'],
    'publicable': !prueba,
    'appId': appId,
    'nombre': constantes['T137AppName'],
    'editor': metadatos['editor'],
    'version': version,
    'origen': origen.path,
    'metadatos': metadatos,
    'huellasMetadatos': fuentesAntes,
    'runtime': runtime,
    'arte': arte,
    'iscc': {'ruta': iscc, 'version': '7.1.1'},
    'dumpbin': dumpbin,
    'dependencias': dependencias,
    'archivos': carga,
    'archivosDelMotor': {
      'nota': 'Inno genera unins000.exe y unins000.dat al instalar. '
          'No pertenecen a la Release; su huella se registra en la aceptación '
          'sobre la instalación. El manifiesto de Inno detalla lo compilado.',
    },
    'limites': [
      'Instalador y desinstalador sin firma de código comercial. SmartScreen puede avisar al descargarlos de internet.',
      'La inspección de importaciones no ejecuta la app ni prueba Windows limpio o bibliotecas cargadas dinámicamente.',
      'El tema claro u oscuro de Windows se toma al arrancar el asistente.',
      if (prueba) 'Solo para aceptación T-137: no publicar ni abrir la app.',
    ],
  };
  _json(File(_ruta(corrida.path, 'preparacion.json')), manifiesto);
  final compilacion = await Process.run(
    iscc,
    ['--no-ide-signtools', '--no-signing', guion.path],
    environment: {'T137_INCLUDE': include.path},
    stdoutEncoding: systemEncoding,
    stderrEncoding: systemEncoding,
  );
  File(_ruta(corrida.path, 'iscc.log')).writeAsStringSync(
    '${compilacion.stdout}\n${compilacion.stderr}',
    flush: true,
  );
  if (compilacion.exitCode != 0 || !instalador.existsSync()) {
    throw _Fallo(
      'ISCC no produjo el instalador (salida '
      '${compilacion.exitCode}). Revisa ${corrida.path}\\iscc.log.',
    );
  }
  // Se vuelve a verificar la carga después de que ISCC la leyó.
  final despues = await _huellas(_archivos(app));
  if (despues.length != carga.length) {
    throw const _Fallo(
      'La cantidad de archivos cambió durante ISCC: no distribuir.',
    );
  }
  final finales = {for (final h in despues) h['ruta']: h['sha256']};
  for (final entrada in carga) {
    if (finales[_ruta(app.path, entrada['archivo']! as String)] !=
        entrada['sha256']) {
      throw const _Fallo('La carga cambió durante ISCC: no distribuir.');
    }
  }
  _compararHuellas(antes, await _huellas(_archivos(origen)), 'Release');
  _compararHuellas(
    fuentesAntes,
    await _huellas(fuentes.map(File.new).toList()),
    'metadatos de la compilación',
  );
  await _comprobarArte(proyecto);
  final hash = (await _huellas([instalador])).single;
  File(
    '${instalador.path}.sha256',
  ).writeAsStringSync('${hash['sha256']}  $nombre.exe\n', flush: true);
  manifiesto['instalador'] = {
    'archivo': '$nombre.exe',
    'bytes': hash['bytes'],
    'sha256': hash['sha256'],
    'firmado': false,
  };
  _json(File(_ruta(salida.path, '$nombre.manifiesto.json')), manifiesto);
  stdout
    ..writeln('Instalador: ${instalador.path}')
    ..writeln('SHA-256: ${hash['sha256']}')
    ..writeln('AppId: {$appId}')
    ..writeln(
      'Origen verificado sin cambios. '
      '${carga.length} archivos en la carga; ${dependencias.length} módulos PE.',
    );
}

class _Fallo implements Exception {
  const _Fallo(this.mensaje);
  final String mensaje;
}

String _ruta(String base, String relativa) => File.fromUri(
      Directory(base).absolute.uri.resolveUri(Uri(path: relativa)),
    ).path;

String _relativa(File archivo, Directory raiz) {
  final base = raiz.absolute.uri.pathSegments;
  final partes = archivo.absolute.uri.pathSegments;
  return partes.skip(base.length - (base.last.isEmpty ? 1 : 0)).join('/');
}

void _exigirArchivo(File archivo) {
  if (!archivo.existsSync()) throw _Fallo('Falta ${archivo.path}');
}

void _json(File archivo, Object valor) => archivo.writeAsStringSync(
      '${const JsonEncoder.withIndent('  ').convert(valor)}\n',
      flush: true,
    );

String _definir(String nombre, String valor) {
  if (RegExp(r'[\r\n\x00"{}]').hasMatch(valor)) {
    throw _Fallo('Valor no admitido para $nombre; no se genera código con él.');
  }
  return '#define $nombre "$valor"';
}

Directory _raizDeRelease(Directory release) {
  final raiz = Directory.fromUri(release.uri.resolve('../../../../../'));
  final esperada = Directory(
    _ruta(raiz.path, 'build/windows/x64/runner/Release'),
  );
  if (esperada.path.toLowerCase() != release.path.toLowerCase() ||
      !File(_ruta(raiz.path, 'pubspec.lock')).existsSync()) {
    throw const _Fallo(
      '--origen debe conservar la ruta '
      'build/windows/x64/runner/Release de la carpeta que compiló la app.',
    );
  }
  return raiz;
}

bool _dentro(String ruta, String raiz) {
  final a = Directory(ruta).absolute.uri.normalizePath().path.toLowerCase();
  final b = Directory(raiz).absolute.uri.normalizePath().path.toLowerCase();
  return a == b || a.startsWith(b.endsWith('/') ? b : '$b/');
}

void _protegerSalida(Directory salida, Directory origen, Directory proyecto) {
  final permitida = _ruta(proyecto.path, 'build/t137');
  if (!_dentro(salida.path, permitida)) {
    throw const _Fallo(
      '--salida debe estar dentro de build/t137 de T-137. '
      'Puede usar subcarpetas para conservar distintas corridas.',
    );
  }
  // Se resuelven también los ancestros existentes para rechazar junctions
  // que redirijan build/t137 hacia otra carpeta o la Release de Carlos.
  var ancestro = salida;
  final pendientes = <String>[];
  while (!ancestro.existsSync()) {
    pendientes.insert(
      0,
      ancestro.uri.pathSegments.where((parte) => parte.isNotEmpty).last,
    );
    ancestro = ancestro.parent;
  }
  final real = _ruta(ancestro.resolveSymbolicLinksSync(), pendientes.join('/'));
  final permitidaReal = _ruta(
    proyecto.resolveSymbolicLinksSync(),
    'build/t137',
  );
  if (!_dentro(real, permitidaReal) ||
      _dentro(real, origen.path) ||
      _dentro(origen.path, real)) {
    throw const _Fallo(
      'La salida se cruza con el origen o sale del proyecto '
      'mediante un enlace. No se escribe nada.',
    );
  }
  final app = Directory(_ruta(salida.path, 'app'));
  if (app.existsSync() && !_dentro(app.resolveSymbolicLinksSync(), real)) {
    throw const _Fallo('app/ redirige a otra carpeta. No se reemplaza.');
  }
}

void _prepararSalida(Directory salida) {
  final marca = File(_ruta(salida.path, 't137-salida.json'));
  if (salida.existsSync() &&
      !marca.existsSync() &&
      (Directory(_ruta(salida.path, 'app')).existsSync() ||
          File(_ruta(salida.path, 'app')).existsSync())) {
    throw const _Fallo(
      'La salida contiene app/ sin marca de T-137. '
      'Usa otra subcarpeta; no se reemplaza trabajo ajeno.',
    );
  }
  if (marca.existsSync()) {
    final valor = jsonDecode(marca.readAsStringSync());
    if (valor is! Map || valor['propietario'] != _appIdProduccion) {
      throw const _Fallo('La marca de la salida no corresponde a T-137.');
    }
  }
  salida.createSync(recursive: true);
  _json(marca, {'schema': 1, 'propietario': _appIdProduccion});
}

List<File> _archivos(Directory raiz) {
  final archivos = <File>[];
  for (final entidad in raiz.listSync(recursive: true, followLinks: false)) {
    if (entidad is Link) {
      throw _Fallo('No se admiten enlaces en la carga: ${entidad.path}');
    }
    if (entidad is File) archivos.add(entidad);
  }
  archivos.sort((a, b) => a.path.compareTo(b.path));
  return archivos;
}

void _compararHuellas(
  List<Map<String, Object?>> antes,
  List<Map<String, Object?>> despues,
  String nombre,
) {
  if (jsonEncode(antes) != jsonEncode(despues)) {
    throw _Fallo('Cambió $nombre durante la preparación; corrida inválida.');
  }
}

Future<Object?> _powershell(String codigo, Object entrada) async {
  final windows = Platform.environment['SystemRoot'];
  if (windows == null) throw const _Fallo('Falta SystemRoot.');
  final ejecutable = _ruta(
    windows,
    'System32/WindowsPowerShell/v1.0/powershell.exe',
  );
  final datos = jsonEncode(entrada);
  if (datos.length > 24000) {
    throw const _Fallo('La consulta de Windows supera el tamaño admitido.');
  }
  final guion = '''
\$ErrorActionPreference = 'Stop'
\$ProgressPreference = 'SilentlyContinue'
[Console]::OutputEncoding = [Text.UTF8Encoding]::new(\$false)
try {
  \$t137Input = \$env:T137_QUERY_JSON | ConvertFrom-Json
  $codigo
} catch {
  [Console]::Error.WriteLine(\$_.Exception.Message)
  exit 1
}
''';
  final bytes = ByteData(guion.codeUnits.length * 2);
  for (var i = 0; i < guion.codeUnits.length; i++) {
    bytes.setUint16(i * 2, guion.codeUnits[i], Endian.little);
  }
  // Evita depender del EOF de stdin en Windows PowerShell. La consulta
  // solo contiene rutas/metadatos públicos; nunca opciones de Firebase.
  final proceso = await Process.start(
    ejecutable,
    [
      '-NoLogo',
      '-NoProfile',
      '-NonInteractive',
      '-EncodedCommand',
      base64Encode(bytes.buffer.asUint8List()),
    ],
    environment: {
      'T137_QUERY_JSON': datos,
      // El agente puede usar PowerShell Core. Windows PowerShell necesita
      // sus módulos propios; no se modifica el entorno de la máquina.
      'PSModulePath': _ruta(windows, 'System32/WindowsPowerShell/v1.0/Modules'),
    },
  );
  final salida = proceso.stdout.transform(utf8.decoder).join();
  final errores = proceso.stderr.transform(utf8.decoder).join();
  await proceso.stdin.close();
  final resultado = await proceso.exitCode.timeout(
    const Duration(seconds: 45),
    onTimeout: () {
      proceso.kill();
      return -2;
    },
  );
  final texto = await salida.timeout(
    const Duration(seconds: 5),
    onTimeout: () =>
        throw const _Fallo('Windows no cerró la salida de la consulta.'),
  );
  final error = await errores.timeout(
    const Duration(seconds: 5),
    onTimeout: () =>
        throw const _Fallo('Windows no cerró el diagnóstico de la consulta.'),
  );
  if (resultado == -2) {
    throw const _Fallo(
        'La consulta de Windows agotó su límite de 45 segundos.');
  }
  if (resultado != 0) {
    throw _Fallo('La consulta de Windows falló ($resultado): ${error.trim()}');
  }
  try {
    return jsonDecode(texto.trim().replaceFirst('\uFEFF', ''));
  } on FormatException {
    throw const _Fallo('Windows no devolvió los metadatos en JSON esperado.');
  }
}

Future<List<Map<String, Object?>>> _huellas(List<File> archivos) async {
  final huellas = <Map<String, Object?>>[];
  for (var inicio = 0; inicio < archivos.length; inicio += 16) {
    final fin = inicio + 16 < archivos.length ? inicio + 16 : archivos.length;
    final lote = archivos.sublist(inicio, fin);
    final resultado = await _powershell(
      r'''
$t137Rows = @(foreach ($t137Path in $t137Input.archivos) {
  $t137File = [IO.FileInfo]::new($t137Path)
  if (-not $t137File.Exists -or
      ($t137File.Attributes -band [IO.FileAttributes]::ReparsePoint)) {
    throw 'La huella solo admite archivos normales, sin enlaces.'
  }
  $t137Stream = [IO.File]::OpenRead($t137Path)
  $t137Sha = [Security.Cryptography.SHA256]::Create()
  try {
    $t137Hash = [BitConverter]::ToString($t137Sha.ComputeHash($t137Stream)).Replace('-', '').ToLowerInvariant()
  } finally {
    $t137Stream.Dispose()
    $t137Sha.Dispose()
  }
  [pscustomobject]@{
    ruta = $t137File.FullName
    bytes = $t137File.Length
    sha256 = $t137Hash
  }
})
ConvertTo-Json -InputObject @($t137Rows) -Compress -Depth 4
''',
      {'archivos': lote.map((a) => a.absolute.path).toList()},
    );
    huellas.addAll((resultado! as List)
        .map((fila) => Map<String, Object?>.from(fila as Map))
        .toList());
  }
  return huellas;
}

Future<Map<String, Object?>> _versionPe(File archivo) async {
  return Map<String, Object?>.from(
    (await _powershell(
      r'''
$t137Version = [Diagnostics.FileVersionInfo]::GetVersionInfo($t137Input.ruta)
if (-not $t137Version.FileVersion) { throw 'El archivo no tiene recurso de versión.' }
[pscustomobject]@{
  version = ('{0}.{1}.{2}.{3}' -f $t137Version.FileMajorPart,
    $t137Version.FileMinorPart, $t137Version.FileBuildPart, $t137Version.FilePrivatePart)
  texto = $t137Version.FileVersion
  producto = $t137Version.ProductVersion
  nombre = $t137Version.ProductName
} | ConvertTo-Json -Compress
''',
      {'ruta': archivo.path},
    ))! as Map,
  );
}

Future<Map<String, Object?>> _metadatos(Directory raiz, File exe) async {
  final pubspec = File(_ruta(raiz.path, 'pubspec.yaml'));
  final lock = File(_ruta(raiz.path, 'pubspec.lock'));
  final config = File(_ruta(raiz.path, '.dart_tool/package_config.json'));
  final generada = File(
    _ruta(raiz.path, 'windows/flutter/ephemeral/generated_config.cmake'),
  );
  for (final archivo in [pubspec, lock, config, generada]) {
    _exigirArchivo(archivo);
  }
  final yaml = pubspec.readAsStringSync();
  final msix = RegExp(
    r'^msix_config:\s*\r?\n((?:[ \t].*\r?\n|\r?\n)*)',
    multiLine: true,
  ).firstMatch(yaml)?.group(1);
  if (msix == null) throw const _Fallo('No se encontró msix_config.');
  final nombre = _escalar(msix, 'display_name', sangria: 2);
  final editor = _escalar(msix, 'publisher_display_name', sangria: 2);
  final identidad = _escalar(msix, 'identity_name', sangria: 2);
  if (nombre != 'BayStream' ||
      editor != 'Carlos Martínez' ||
      identidad != 'gt.cmartinez.baystream') {
    throw const _Fallo(
      'La identidad de msix_config cambió; revisar T-137 '
      'antes de crear otro producto o de cambiar el editor.',
    );
  }
  final version = await _versionPe(exe);
  if (version['nombre'] != 'BayStream' ||
      !RegExp(
        r'^\d+\.\d+\.\d+\.\d+$',
      ).hasMatch(version['version']! as String)) {
    throw const _Fallo(
      'El ejecutable no se identifica como BayStream '
      'o no tiene una versión numérica de cuatro partes.',
    );
  }
  final lockTexto = lock.readAsStringSync();
  final paquetes = <String, String>{};
  for (final paquete in [
    'firebase_core',
    'cloud_firestore',
    'flutter_riverpod',
  ]) {
    final bloque = RegExp(
      '^  ${RegExp.escape(paquete)}:\\r?\\n'
      r'(.*?)(?=^  [a-zA-Z_]|^sdks:)',
      multiLine: true,
      dotAll: true,
    ).firstMatch(lockTexto)?.group(1);
    if (bloque == null) throw _Fallo('Falta $paquete en pubspec.lock.');
    paquetes[paquete] = _escalar(bloque, 'version', sangria: 4);
  }
  final json = jsonDecode(config.readAsStringSync()) as Map;
  final paquetesConfig = (json['packages'] as List).cast<Map>();
  final firebase = paquetesConfig.where((p) => p['name'] == 'firebase_core');
  if (firebase.length != 1) {
    throw const _Fallo(
      'package_config no resuelve firebase_core una sola vez.',
    );
  }
  final firebaseRaiz = Directory.fromUri(
    config.uri.resolve(firebase.single['rootUri'] as String),
  );
  final firebasePubspec = File(_ruta(firebaseRaiz.path, 'pubspec.yaml'));
  final cmake = File(_ruta(firebaseRaiz.path, 'windows/CMakeLists.txt'));
  _exigirArchivo(firebasePubspec);
  _exigirArchivo(cmake);
  if (_escalar(firebasePubspec.readAsStringSync(), 'version') !=
      paquetes['firebase_core']) {
    throw const _Fallo('firebase_core resuelto no coincide con pubspec.lock.');
  }
  final pedido = RegExp(
    r'set\(\s*FIREBASE_SDK_VERSION\s+"([0-9.]+)"\s*\)',
  ).firstMatch(cmake.readAsStringSync())?.group(1);
  if (pedido == null) {
    throw const _Fallo(
      'No se pudo leer FIREBASE_SDK_VERSION del paquete resuelto.',
    );
  }
  final header = File(
    _ruta(
      raiz.path,
      'build/windows/x64/extracted/firebase_cpp_sdk_windows/include/firebase/version.h',
    ),
  );
  _exigirArchivo(header);
  final headerTexto = header.readAsStringSync();
  final cpp = ['MAJOR', 'MINOR', 'REVISION'].map((parte) {
    final valor = RegExp(
      '^\\s*#define\\s+FIREBASE_VERSION_$parte\\s+(\\d+)\\b',
      multiLine: true,
    ).firstMatch(headerTexto)?.group(1);
    if (valor == null) {
      throw _Fallo('No se pudo leer FIREBASE_VERSION_$parte.');
    }
    return valor;
  }).join('.');
  if (cpp != pedido) {
    throw _Fallo(
      'SDK de Firebase C++ extraído $cpp, pero firebase_core '
      '${paquetes['firebase_core']} pide $pedido. Trampa de 10.99: '
      'no se empaqueta y no se cambia extracted.',
    );
  }
  final cmakeGenerado = generada.readAsStringSync();
  // Flutter 3.38 escribe file(TO_CMAKE_PATH "C:\\flutter" FLUTTER_ROOT),
  // no set(FLUTTER_ROOT ...). Se leen ambas formas y se desescapan solo
  // las barras duplicadas de la cadena CMake; no se imprimen DART_DEFINES.
  final flutterRutaCmake = RegExp(
        r'file\(\s*TO_CMAKE_PATH\s+"([^"]+)"\s+FLUTTER_ROOT\s*\)',
      ).firstMatch(cmakeGenerado)?.group(1) ??
      RegExp(
        r'set\(\s*FLUTTER_ROOT\s+"([^"]+)"(?:\s+PARENT_SCOPE)?\s*\)',
      ).firstMatch(cmakeGenerado)?.group(1);
  if (flutterRutaCmake == null) {
    throw const _Fallo('No se encontró FLUTTER_ROOT de la compilación.');
  }
  final flutterRaiz = flutterRutaCmake.replaceAll('\\\\', '\\');
  final flutterJson = File(
    _ruta(flutterRaiz, 'bin/cache/flutter.version.json'),
  );
  _exigirArchivo(flutterJson);
  final flutter = jsonDecode(flutterJson.readAsStringSync()) as Map;
  for (final clave in ['frameworkVersion', 'dartSdkVersion']) {
    if (flutter[clave] is! String || (flutter[clave] as String).isEmpty) {
      throw _Fallo('Falta $clave en flutter.version.json.');
    }
  }
  // El SDK leído tiene que ser el mismo que resuelve el proyecto de origen.
  final flutterPaquete = paquetesConfig.where((p) => p['name'] == 'flutter');
  if (flutterPaquete.length != 1 ||
      Directory.fromUri(
            config.uri.resolve(flutterPaquete.single['rootUri'] as String),
          ).resolveSymbolicLinksSync().toLowerCase() !=
          Directory(
            _ruta(flutterRaiz, 'packages/flutter'),
          ).resolveSymbolicLinksSync().toLowerCase()) {
    throw const _Fallo(
      'El Flutter de package_config y el de la compilación difieren.',
    );
  }
  return {
    'version': version['version'],
    'versionTextoExe': version['texto'],
    'versionProductoExe': version['producto'],
    'nombre': nombre,
    'editor': editor,
    'identidadMsix': identidad,
    'flutter': flutter['frameworkVersion'],
    'dart': flutter['dartSdkVersion'],
    ...paquetes,
    'firebaseCpp': cpp,
    'firebaseCppPedido': pedido,
    'fuentes': [
      pubspec.path,
      lock.path,
      config.path,
      generada.path,
      firebasePubspec.path,
      cmake.path,
      header.path,
      flutterJson.path,
    ],
  };
}

String _escalar(String texto, String clave, {int sangria = 0}) {
  final coincidencia = RegExp(
    '^${' ' * sangria}${RegExp.escape(clave)}:[ \\t]*([^\\r\\n]+)',
    multiLine: true,
  ).firstMatch(texto);
  if (coincidencia == null) throw _Fallo('No se pudo leer $clave.');
  var valor = coincidencia.group(1)!.trim();
  if (valor.length >= 2 &&
      ((valor.startsWith('"') && valor.endsWith('"')) ||
          (valor.startsWith("'") && valor.endsWith("'")))) {
    valor = valor.substring(1, valor.length - 1);
  }
  if (valor.isEmpty) throw _Fallo('$clave está vacío.');
  return valor;
}

Future<String> _buscarIscc() async {
  final candidatos = <String>[
    if (Platform.environment['T137_ISCC'] case final String ruta) ruta,
    if (_enPath('ISCC.exe') case final String ruta) ruta,
    for (final variable in [
      'LOCALAPPDATA',
      'ProgramFiles(x86)',
      'ProgramFiles',
    ])
      if (Platform.environment[variable] case final String base)
        _ruta(
          base,
          variable == 'LOCALAPPDATA'
              ? 'Programs/Inno Setup 7/ISCC.exe'
              : 'Inno Setup 7/ISCC.exe',
        ),
  ];
  for (final candidato in candidatos) {
    final archivo = File(candidato);
    if (!archivo.existsSync()) continue;
    final resultado = await Process.run(archivo.path, ['--version']);
    if (resultado.exitCode != 0 || '${resultado.stdout}'.trim() != '7.1.1') {
      throw _Fallo(
        'Se necesita ISCC 7.1.1; revisar ${archivo.path}. '
        'La herramienta la instala Carlos.',
      );
    }
    _exigirArchivo(File(_ruta(archivo.parent.path, 'Languages/Spanish.isl')));
    return archivo.absolute.path;
  }
  throw const _Fallo('No está ISCC 7.1.1. Carlos debe instalarlo.');
}

String? _enPath(String nombre) {
  for (final carpeta in (Platform.environment['PATH'] ?? '').split(';')) {
    if (carpeta.isEmpty) continue;
    final archivo = File(_ruta(carpeta.replaceAll('"', ''), nombre));
    if (archivo.existsSync()) return archivo.absolute.path;
  }
  return null;
}

Future<List<String>> _visualStudio(String patron) async {
  final base = Platform.environment['ProgramFiles(x86)'];
  if (base == null) return [];
  final vswhere = File(
    _ruta(base, 'Microsoft Visual Studio/Installer/vswhere.exe'),
  );
  if (!vswhere.existsSync()) return [];
  final resultado = await Process.run(vswhere.path, [
    '-latest',
    '-products',
    '*',
    '-requires',
    'Microsoft.VisualStudio.Component.VC.Tools.x86.x64',
    '-find',
    patron,
  ]);
  if (resultado.exitCode != 0) return [];
  return const LineSplitter()
      .convert('${resultado.stdout}')
      .map((p) => p.trim())
      .where((p) => p.isNotEmpty)
      .toList()
    ..sort();
}

Future<String> _buscarDumpbin() async {
  final candidatos = <String>[
    if (Platform.environment['T137_DUMPBIN'] case final String ruta) ruta,
    if (_enPath('dumpbin.exe') case final String ruta) ruta,
    ...(await _visualStudio(
      r'VC\Tools\MSVC\**\bin\Hostx64\x64\dumpbin.exe',
    ))
        .reversed,
  ];
  for (final candidato in candidatos) {
    if (File(candidato).existsSync()) return candidato;
  }
  throw const _Fallo(
    'No se encontró dumpbin. No se omite la comprobación. '
    'Indica su ruta con T137_DUMPBIN o abre una consola de desarrollo de VS. '
    'Como alternativa revisable se puede usar llvm-readobj --coff-imports '
    'sobre todos los PE; requiere acordar y validar esa alternativa antes.',
  );
}

Future<void> _exigirX64(File archivo) async {
  final entrada = await archivo.open();
  try {
    if (await entrada.length() < 64) {
      throw _Fallo('PE incompleto: ${archivo.path}');
    }
    final dos = await entrada.read(64);
    if (dos[0] != 0x4d || dos[1] != 0x5a) {
      throw _Fallo('No es un ejecutable PE: ${archivo.path}');
    }
    final offset = ByteData.sublistView(dos).getUint32(60, Endian.little);
    await entrada.setPosition(offset);
    final pe = await entrada.read(6);
    if (pe.length != 6 ||
        pe[0] != 0x50 ||
        pe[1] != 0x45 ||
        pe[2] != 0 ||
        pe[3] != 0 ||
        ByteData.sublistView(pe).getUint16(4, Endian.little) != 0x8664) {
      throw _Fallo('No es PE x64: ${archivo.path}');
    }
  } finally {
    await entrada.close();
  }
}

Future<List<Map<String, Object?>>> _buscarRuntime(Directory origen) async {
  final resultado = <Map<String, Object?>>[];
  for (final nombre in [
    'msvcp140.dll',
    'vcruntime140.dll',
    'vcruntime140_1.dll',
  ]) {
    final existentes = <File>[
      File(_ruta(origen.path, nombre)),
      if (Platform.environment['SystemRoot'] case final String windows)
        File(_ruta(windows, 'System32/$nombre')),
    ];
    File? elegido;
    for (final archivo in existentes) {
      if (archivo.existsSync()) {
        await _exigirX64(archivo);
        elegido = archivo;
        break;
      }
    }
    if (elegido == null) {
      final visual = await _visualStudio(
        'VC\\Redist\\MSVC\\**\\x64\\Microsoft.VC*.CRT\\$nombre',
      );
      for (final ruta in visual.reversed) {
        final archivo = File(ruta);
        if (archivo.existsSync()) {
          await _exigirX64(archivo);
          elegido = archivo;
          break;
        }
      }
    }
    if (elegido == null) {
      throw _Fallo(
        'Falta $nombre x64 en Release, System32 y el redistribuible de VS.',
      );
    }
    final version = await _versionPe(elegido);
    final hash = (await _huellas([elegido])).single;
    resultado.add({
      'nombre': nombre,
      'origen': elegido.path,
      'version': version['version'],
      'sha256': hash['sha256'],
      'bytes': hash['bytes'],
      'yaEnRelease': _dentro(elegido.path, origen.path),
    });
  }
  return resultado;
}

Future<Map<String, Object?>> _comprobarArte(Directory proyecto) async {
  final directorio = Directory(_ruta(proyecto.path, 'windows/installer/arte'));
  final archivo = File(_ruta(directorio.path, 'manifiesto.json'));
  if (!archivo.existsSync()) {
    throw const _Fallo(
      'Falta el arte. Con luz verde de Carlos, ejecutar '
      'flutter test tool/t137_arte_test.dart antes de empaquetar.',
    );
  }
  final arte = Map<String, Object?>.from(
    jsonDecode(archivo.readAsStringSync()) as Map,
  );
  if (arte['schema'] != 1 ||
      arte['archivos'] is! List ||
      (arte['archivos']! as List).length != 28 ||
      arte['fuentes'] is! List) {
    throw const _Fallo(
      'El manifiesto del arte no contiene las 28 imágenes esperadas.',
    );
  }
  const dimensiones = <int, List<int>>{
    100: [202, 386, 58],
    125: [269, 515, 77],
    150: [336, 643, 97],
    175: [403, 772, 116],
    200: [430, 824, 124],
    225: [498, 953, 143],
    250: [534, 1022, 159],
  };
  final imagenes = <File>[];
  final filas = (arte['archivos']! as List).cast<Map>();
  final nombres = <String>{};
  for (final fila in filas) {
    final tamano = dimensiones[fila['escala']];
    if (tamano == null ||
        !['claro', 'oscuro'].contains(fila['tema']) ||
        !['grande', 'pequena'].contains(fila['tipo'])) {
      throw const _Fallo(
        'Hay una escala, un tema o un tipo de arte no admitido.',
      );
    }
    final nombre = '${fila['tipo']}_${fila['tema']}_${fila['escala']}.png';
    final grande = fila['tipo'] == 'grande';
    if (fila['archivo'] != nombre ||
        !nombres.add(nombre) ||
        fila['ancho'] != (grande ? tamano[0] : tamano[2]) ||
        fila['alto'] != (grande ? tamano[1] : tamano[2])) {
      throw const _Fallo(
        'Las dimensiones o el nombre del arte no coinciden con Inno.',
      );
    }
    final png = File(_ruta(directorio.path, nombre));
    _exigirArchivo(png);
    final entrada = await png.open();
    try {
      final cabecera = await entrada.read(24);
      if (cabecera.length < 24 ||
          base64Encode(cabecera.sublist(0, 8)) != 'iVBORw0KGgo=' ||
          ByteData.sublistView(cabecera).getUint32(16) != fila['ancho'] ||
          ByteData.sublistView(cabecera).getUint32(20) != fila['alto']) {
        throw _Fallo('PNG inválido o de otra medida: $nombre');
      }
    } finally {
      await entrada.close();
    }
    imagenes.add(png);
  }
  final hashes = await _huellas(imagenes);
  for (var i = 0; i < filas.length; i++) {
    if (hashes[i]['sha256'] != filas[i]['sha256']) {
      throw _Fallo(
        'Cambió el arte: ${filas[i]['archivo']}. Regenerarlo con Flutter.',
      );
    }
  }
  final fuentes = (arte['fuentes']! as List).cast<Map>();
  if (fuentes.isEmpty) throw const _Fallo('Falta la procedencia del arte.');
  final archivosFuente = <File>[];
  for (final fuente in fuentes) {
    final ruta = fuente['archivo'];
    if (ruta is! String ||
        ruta.contains('..') ||
        ruta.contains('\\') ||
        ruta.startsWith('/') ||
        ruta.contains(':')) {
      throw const _Fallo('Ruta de procedencia no admitida en el arte.');
    }
    archivosFuente.add(File(_ruta(proyecto.path, ruta)));
  }
  final hashesFuente = await _huellas(archivosFuente);
  for (var i = 0; i < fuentes.length; i++) {
    if (hashesFuente[i]['sha256'] != fuentes[i]['sha256']) {
      throw _Fallo(
        'El arte quedó anterior a ${fuentes[i]['archivo']}. '
        'Hay que regenerarlo con Flutter, con el semáforo de Carlos.',
      );
    }
  }
  return arte;
}

Map<String, String> _constantesArte(
  Map<String, Object?> arte,
  Directory proyecto,
) {
  final resultado = <String, String>{};
  final paletas = arte['paletas']! as Map;
  for (final tema in ['claro', 'oscuro']) {
    final sufijo = tema == 'claro' ? 'Claro' : 'Oscuro';
    final paleta = paletas[tema] as Map;
    for (final token in ['papel', 'hoja', 'tinta', 'tintaSuave', 'marca']) {
      final valor = paleta[token];
      if (valor is! String || !RegExp(r'^#[0-9a-fA-F]{6}$').hasMatch(valor)) {
        throw _Fallo('Falta el token $token de BsPaleta $tema.');
      }
      final nombre = '${token[0].toUpperCase()}${token.substring(1)}';
      resultado['T137$nombre$sufijo'] = valor;
      // TColor de Pascal es BGR; las directivas del asistente aceptan RGB.
      resultado['T137$nombre${sufijo}Bgr'] =
          '\$${valor.substring(5, 7)}${valor.substring(3, 5)}${valor.substring(1, 3)}';
    }
    for (final tipo in ['grande', 'pequena']) {
      final nombre = tipo == 'grande' ? 'Grandes' : 'Pequenas';
      resultado['T137$nombre$sufijo'] = [
        for (final escala in [100, 125, 150, 175, 200, 225, 250])
          _ruta(
            proyecto.path,
            'windows/installer/arte/${tipo}_${tema}_$escala.png',
          ),
      ].join(',');
    }
  }
  return resultado;
}

// DLL de Windows 10/11, no la lista de todo lo que hoy exista en System32.
// Un runtime de terceros presente en la máquina no cuenta como componente
// del sistema. Los contratos API-set los resuelve Windows aunque no tengan
// un archivo de igual nombre en System32.
const _dllWindows = <String>{
  'advapi32.dll',
  'authz.dll',
  'avrt.dll',
  'bcrypt.dll',
  'bcryptprimitives.dll',
  'cfgmgr32.dll',
  'clbcatq.dll',
  'combase.dll',
  'comctl32.dll',
  'comdlg32.dll',
  'credui.dll',
  'crypt32.dll',
  'cryptbase.dll',
  'cryptsp.dll',
  'd2d1.dll',
  'd3d9.dll',
  'd3d11.dll',
  'd3d12.dll',
  'd3dcompiler_47.dll',
  'dbghelp.dll',
  'devobj.dll',
  'dhcpcsvc.dll',
  'dnsapi.dll',
  'dpapi.dll',
  'dwmapi.dll',
  'dwrite.dll',
  'dxcore.dll',
  'dxgi.dll',
  'gdi32.dll',
  'gdi32full.dll',
  'glu32.dll',
  'hid.dll',
  'iertutil.dll',
  'imm32.dll',
  'iphlpapi.dll',
  'kernel32.dll',
  'kernelbase.dll',
  'ksuser.dll',
  'mf.dll',
  'mfplat.dll',
  'mfreadwrite.dll',
  'mfuuid.dll',
  'mpr.dll',
  'msacm32.dll',
  'msasn1.dll',
  'msctf.dll',
  'msimg32.dll',
  'msvcrt.dll',
  'mswsock.dll',
  'ncrypt.dll',
  'netapi32.dll',
  'normaliz.dll',
  'ntdll.dll',
  'ole32.dll',
  'oleacc.dll',
  'oleaut32.dll',
  'opengl32.dll',
  'pathcch.dll',
  'powrprof.dll',
  'profapi.dll',
  'propsys.dll',
  'psapi.dll',
  'rpcrt4.dll',
  'secur32.dll',
  'sensapi.dll',
  'setupapi.dll',
  'shcore.dll',
  'shell32.dll',
  'shlwapi.dll',
  'sspicli.dll',
  'textshaping.dll',
  'ucrtbase.dll',
  'uiautomationcore.dll',
  'urlmon.dll',
  'user32.dll',
  'userenv.dll',
  'usp10.dll',
  'uxtheme.dll',
  'version.dll',
  'win32u.dll',
  'windowscodecs.dll',
  'winhttp.dll',
  'wininet.dll',
  'winmm.dll',
  'winspool.drv',
  'wintrust.dll',
  'winusb.dll',
  'wlanapi.dll',
  'wldap32.dll',
  'ws2_32.dll',
  'wtsapi32.dll',
};

Future<List<Map<String, Object?>>> _dependencias(
  Directory app,
  String dumpbin,
  Directory corrida,
) async {
  final resultado = <Map<String, Object?>>[];
  final modulos = _archivos(app)
      .where(
        (archivo) =>
            archivo.path.toLowerCase().endsWith('.exe') ||
            archivo.path.toLowerCase().endsWith('.dll'),
      )
      .toList();
  final raiz = {
    for (final archivo in app.listSync().whereType<File>())
      archivo.uri.pathSegments.last.toLowerCase(): archivo.path,
  };
  final windows = Platform.environment['SystemRoot']!;
  for (var i = 0; i < modulos.length; i++) {
    final modulo = modulos[i];
    await _exigirX64(modulo);
    final inspeccion = await Process.run(
      dumpbin,
      ['/nologo', '/dependents', modulo.path],
      stdoutEncoding: systemEncoding,
      stderrEncoding: systemEncoding,
    );
    final texto = '${inspeccion.stdout}\n${inspeccion.stderr}';
    final registro = '${i.toString().padLeft(3, '0')}-'
        '${modulo.uri.pathSegments.last}.dumpbin.txt';
    File(_ruta(corrida.path, registro)).writeAsStringSync(texto, flush: true);
    if (inspeccion.exitCode != 0) {
      throw _Fallo(
        'dumpbin falló con ${_relativa(modulo, app)}; revisa $registro.',
      );
    }
    final nombres = RegExp(
      r'^\s*([A-Za-z0-9_.+\-]+\.(?:dll|drv))\s*$',
      multiLine: true,
      caseSensitive: false,
    ).allMatches(texto).map((m) => m.group(1)!.toLowerCase()).toSet().toList()
      ..sort();
    if (nombres.isEmpty) {
      throw _Fallo(
        'dumpbin no devolvió importaciones para ${modulo.path}; '
        'no se interpreta una salida desconocida como comprobación correcta.',
      );
    }
    final resueltas = <Map<String, String>>[];
    for (final nombre in nombres) {
      final String clase;
      final String ubicacion;
      if (raiz.containsKey(nombre)) {
        clase = 'junto al ejecutable';
        ubicacion = nombre;
      } else if (RegExp(
        r'^(?:api|ext)-ms-win-[a-z0-9\-]+\.dll$',
      ).hasMatch(nombre)) {
        clase = 'contrato API-set de Windows 10/11';
        ubicacion = 'resuelto por el cargador de Windows';
      } else if (_dllWindows.contains(nombre) &&
          File(_ruta(windows, 'System32/$nombre')).existsSync()) {
        clase = 'Windows 10/11';
        ubicacion = _ruta(windows, 'System32/$nombre');
      } else {
        throw _Fallo(
          '${_relativa(modulo, app)} pide $nombre: no está junto '
          'al ejecutable ni está admitida como DLL del sistema. '
          'No se arma un instalador que dependa del runtime de esta máquina.',
        );
      }
      resueltas.add({'dll': nombre, 'clase': clase, 'ubicacion': ubicacion});
    }
    resultado.add({
      'modulo': _relativa(modulo, app),
      'importaciones': resueltas,
      'evidencia': registro,
    });
  }
  return resultado;
}
