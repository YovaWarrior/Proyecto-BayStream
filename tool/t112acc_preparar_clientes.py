"""Genera el banco aislado T112acc a partir del banco versionado de T-112.

Solo escribe en la copia TEMP creada por t112acc_verificar.py.
Agrega dos controles de ensayo: rechazo real de UNH y CSV del exportador real.
"""
import os
from pathlib import Path

base = Path(os.environ['TEMP']) / 't112acc-33404a5'
copia = base / 'cierre'
source = (copia / 'tool/t112_main.dart').read_text(encoding='utf-8')
source = source.replace("namespace: 't112'", "namespace: 't112acc'")
source = source.replace("import 'dart:async';", """import 'dart:async';
import 'dart:convert';
import 't99_plataforma.dart';
import 'package:baystream/features/vessel/data/services/export_service.dart';""")
source = source.replace('WidgetsFlutterBinding.ensureInitialized();',
                        'WidgetsFlutterBinding.ensureInitialized();\n'
                        '  if (kIsWeb || defaultTargetPlatform != TargetPlatform.windows) {\n'
                        '    WidgetsBinding.instance.ensureSemantics();\n'
                        '  }')
source = source.replace('child: BayStreamApp(builder: recorrido?.envoltorio)',
                        'child: BayStreamApp(builder: (context, child) => '
                        '_controles(container, recorrido?.envoltorio(context, child) ?? child!))')
source += r'''

// Controles exclusivos del banco. La aplicación y sus archivos lib/ se conservan.
Widget _controles(ProviderContainer container, Widget child) => Column(children: [
  Expanded(child: child),
  Material(child: SafeArea(top: false, child: Row(children: [
    Expanded(child: TextButton(onPressed: () async {
      final result = await container.read(voyageNotifierProvider.notifier)
          .parseBaplieContent("UNH+ACC+BAPLIE:D:95B:UN:SMDG30'",
              fileName: 'T112ACC_ERROR.edi');
      final texto = result.errorMessage ?? 'ERROR: el rechazo no llegó';
      await guardarBytes(const String.fromEnvironment('T112ACC_OUTPUT'),
          'error-lectura.txt', Uint8List.fromList(utf8.encode(texto)));
      await _mostrar('Error de lectura real', texto);
    }, child: const Text('Ensayo: error UNH'))),
    Expanded(child: TextButton(onPressed: () async {
      final voyage = container.read(voyageNotifierProvider.notifier).publishedVoyage!;
      final csv = const ExportService().serializeCsv(voyage);
      await guardarBytes(const String.fromEnvironment('T112ACC_OUTPUT'),
          'exportado.csv', Uint8List.fromList(utf8.encode(csv)));
      await _mostrar('CSV del exportador real', csv);
    }, child: const Text('Ensayo: CSV'))),
  ]))),
]);

Future<void> _mostrar(String title, String text) async {
  NavigatorState? navigator;
  void visit(Element element) {
    if (element is StatefulElement && element.state is NavigatorState) {
      navigator ??= element.state as NavigatorState;
    }
    element.visitChildren(visit);
  }
  WidgetsBinding.instance.rootElement!.visitChildren(visit);
  await showDialog<void>(context: navigator!.overlay!.context,
      builder: (context) => AlertDialog(title: Text(title),
          content: SingleChildScrollView(child: SelectableText(text)),
          actions: [TextButton(onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'))]));
}
'''
(copia / 'tool/t112acc_main.dart').write_text(source, encoding='utf-8')
gradle = copia / 'android/app/build.gradle.kts'
text = gradle.read_text(encoding='utf-8').replace(
    'applicationId = "gt.cmartinez.baystream"',
    'applicationId = "gt.cmartinez.baystream.t112acc"')
gradle.write_text(text, encoding='utf-8')
manifest = copia / 'android/app/src/main/AndroidManifest.xml'
manifest.write_text(manifest.read_text(encoding='utf-8').replace(
    'android:label="BayStream"', 'android:label="BayStream T112acc"'), encoding='utf-8')
print(copia / 'tool/t112acc_main.dart')
