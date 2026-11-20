// T-147 · Lo que el banco hace distinto en cada cliente: de dónde lee el caso
// (que vive fuera del repositorio) y dónde deja sus pasos y sus capturas. En
// Windows, archivos; en la Web, el servidor local de tool/t147_servidor.py.
export 't147_plataforma_web.dart' if (dart.library.io) 't147_plataforma_io.dart';
