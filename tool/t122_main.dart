// Banco de capturas de T-122 (la 3.1.1 con los hallazgos del piloto): la app
// del producto (`BayStreamApp`, con sus temas y su página) y tres cambios,
// nada más:
//
// 1. El selector de archivos devuelve una entrada sintética elegida en el
//    panel «T122» (tool/t122_entradas.py): el plano de llegada de H1, el plan
//    de carga de H4 a H7 o el listado de H3. Los bytes recorren la entrada
//    real del producto, como en T-89.
// 2. No hay Firebase: la sesión es local y el rol se elige en el panel (muelle
//    local sin cuenta, muelle con cuenta simulada u oficina simulada), como en
//    las pruebas de pantalla de T-105.
// 3. «Publicar en este dispositivo» marca la operación como publicada en la
//    bitácora local, para que el arrastre de T-105 esté activo sin nube (H7).
//
// Almacén con namespace t122cap. Nada del piloto; nada se publica en la nube.
//
//   flutter build windows --release -t tool/t122_main.dart
//   flutter build web --release -t tool/t122_main.dart --output=build/t122/web
//   flutter build apk --debug -t tool/t122_main.dart
import 'dart:async';
import 'dart:convert';

import 'package:baystream/core/app.dart';
import 'package:baystream/core/errors/exceptions.dart';
import 'package:baystream/core/errors/failures.dart';
import 'package:baystream/features/vessel/data/repositories/local_only_operation_sync.dart';
import 'package:baystream/features/vessel/data/repositories/local_vessel_repository_factory.dart';
import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/domain/entities/app_theme_preference.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/repositories/session_repository.dart';
import 'package:baystream/features/vessel/domain/repositories/vessel_repository.dart';
import 'package:baystream/features/vessel/presentation/providers/movement_log_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/sync_providers.dart';
import 'package:baystream/features/vessel/presentation/providers/theme_preference_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/vessel_providers.dart';
import 'package:dartz/dartz.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 't122_entradas.dart';

enum _Entrada {
  llegada('Llegada (H1)'),
  carga('Plan de carga'),
  listado('Listado (H3)');

  const _Entrada(this.rotulo);
  final String rotulo;
}

enum _Rol {
  muelleLocal('Muelle local'),
  muelleCuenta('Muelle con cuenta'),
  oficina('Oficina');

  const _Rol(this.rotulo);
  final String rotulo;
}

class _EntradaElegida extends Notifier<_Entrada> {
  @override
  _Entrada build() => _Entrada.carga;
  void elegir(_Entrada valor) => state = valor;
}

class _RolElegido extends Notifier<_Rol> {
  @override
  _Rol build() => _Rol.muelleLocal;
  void elegir(_Rol valor) => state = valor;
}

final _entrada = NotifierProvider<_EntradaElegida, _Entrada>(_EntradaElegida.new);
final _rol = NotifierProvider<_RolElegido, _Rol>(_RolElegido.new);

Operator? _operador(_Rol rol) => switch (rol) {
      _Rol.muelleLocal => null,
      _Rol.muelleCuenta => const Operator(
          uid: 't122-muelle', name: 'Muelle T122 (simulado)', role: OperatorRole.dock),
      _Rol.oficina => const Operator(
          uid: 't122-oficina', name: 'Oficina T122 (simulada)', role: OperatorRole.office),
    };

/// Sustituye solo el diálogo; los bytes recorren la entrada real del producto.
class _Selector extends FilePicker {
  final _Entrada Function() entrada;
  _Selector(this.entrada);

  @override
  Future<FilePickerResult?> pickFiles({
    String? dialogTitle,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    Function(FilePickerStatus)? onFileLoading,
    bool allowCompression = false,
    int compressionQuality = 0,
    bool allowMultiple = false,
    bool withData = false,
    bool withReadStream = false,
    bool lockParentWindow = false,
    bool readSequential = false,
  }) async {
    final (name, bytes) = switch (entrada()) {
      _Entrada.llegada =>
        ('T122_LLEGADA.edi', Uint8List.fromList(ascii.encode(t122Llegada))),
      _Entrada.carga =>
        ('T122_CARGA.edi', Uint8List.fromList(ascii.encode(t122Carga))),
      _Entrada.listado => ('T122_LISTADO.xlsx', base64Decode(t122ListadoBase64)),
    };
    return FilePickerResult(
        [PlatformFile(name: name, size: bytes.length, bytes: bytes)]);
  }
}

/// Solo lee BAPLIE; nada de nube (como `ParserOnlyRepository` de las pruebas).
class _SoloLector implements VesselRepository {
  @override
  Future<Either<Failure, VesselVoyage>> parseBaplieFile(String content) async {
    try {
      return Right(BaplieParserService().parse(content));
    } on BaplieParsingException catch (e) {
      return Left(BaplieParsingFailure(
          message: e.message, code: e.code, segment: e.segment));
    }
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final container = ProviderContainer(overrides: [
    localVesselRepositoryProvider.overrideWith((ref) async {
      final repo = await openLocalVesselRepository(namespace: 't122cap');
      ref.onDispose(() => unawaited(repo.close()));
      return repo;
    }),
    movementLogRepositoryProvider.overrideWith((ref) async {
      final repo = await openMovementLogRepository(namespace: 't122cap');
      ref.onDispose(() => unawaited(repo.close()));
      return repo;
    }),
    sessionRepositoryProvider
        .overrideWith((ref) async => const LocalSessionRepository()),
    operatorProvider
        .overrideWith((ref) => Stream.value(_operador(ref.watch(_rol)))),
    vesselRepositoryProvider.overrideWithValue(_SoloLector()),
  ]);
  FilePicker.platform = _Selector(() => container.read(_entrada));
  runApp(UncontrolledProviderScope(
      container: container,
      child: BayStreamApp(
          builder: (context, child) => _Panel(child: child!))));
}

/// Una pestaña pequeña en el borde izquierdo abre el panel del banco; cerrado,
/// solo queda la pestaña, que no tapa ningún control del producto.
class _Panel extends ConsumerStatefulWidget {
  final Widget child;
  const _Panel({required this.child});
  @override
  ConsumerState<_Panel> createState() => _PanelState();
}

class _PanelState extends ConsumerState<_Panel> {
  bool abierto = false;
  String mensaje = 'Banco T-122 · sintético · PROVISIONAL · t122cap';

  Future<void> publicarEnEsteDispositivo() async {
    try {
      final operation = await ref.read(activeOperationProvider.future);
      if (operation == null) {
        throw StateError('No hay operación: abre y confirma un plan primero.');
      }
      final log = await ref.read(movementLogRepositoryProvider.future);
      final profile = ref.read(voyageNotifierProvider.notifier).publishedProfile;
      (await log.saveOperation(
              operation.copyWith(published: true, profile: profile)))
          .fold((failure) => throw StateError(failure.message), (_) {});
      ref.read(operationSourcesRevisionProvider.notifier).changed();
      setState(() => mensaje =
          'Operación ${operation.portOfCall} marcada como publicada en este dispositivo.');
    } catch (e) {
      setState(() => mensaje = '$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    final entrada = ref.watch(_entrada);
    final rol = ref.watch(_rol);
    return Stack(children: [
      widget.child,
      Positioned(
        left: 0,
        top: MediaQuery.sizeOf(context).height * .42,
        child: Material(
          color: esquema.tertiaryContainer.withValues(alpha: .85),
          borderRadius:
              const BorderRadius.horizontal(right: Radius.circular(12)),
          child: InkWell(
            onTap: () => setState(() => abierto = !abierto),
            child: Semantics(
              label: 'Banco T122',
              button: true,
              child: SizedBox(
                width: 28,
                height: 56,
                child: Icon(Icons.science,
                    size: 18, color: esquema.onTertiaryContainer),
              ),
            ),
          ),
        ),
      ),
      if (abierto)
        Positioned(
          left: 32,
          top: 24,
          right: 8,
          child: Material(
            elevation: 8,
            color: esquema.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Banco T-122 · sintético · PROVISIONAL',
                        style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 8),
                    const Text('Próximo archivo'),
                    Wrap(spacing: 6, children: [
                      for (final e in _Entrada.values)
                        ChoiceChip(
                            label: Text(e.rotulo),
                            selected: entrada == e,
                            onSelected: (_) =>
                                ref.read(_entrada.notifier).elegir(e)),
                    ]),
                    const SizedBox(height: 8),
                    const Text('Rol'),
                    Wrap(spacing: 6, children: [
                      for (final r in _Rol.values)
                        ChoiceChip(
                            label: Text(r.rotulo),
                            selected: rol == r,
                            onSelected: (_) =>
                                ref.read(_rol.notifier).elegir(r)),
                    ]),
                    const SizedBox(height: 8),
                    const Text('Tema'),
                    Wrap(spacing: 6, children: [
                      TextButton(
                          onPressed: () => ref
                              .read(themePreferenceProvider.notifier)
                              .select(AppThemePreference.light),
                          child: const Text('Tema claro')),
                      TextButton(
                          onPressed: () => ref
                              .read(themePreferenceProvider.notifier)
                              .select(AppThemePreference.dark),
                          child: const Text('Tema oscuro')),
                    ]),
                    const SizedBox(height: 8),
                    FilledButton.tonal(
                        onPressed: publicarEnEsteDispositivo,
                        child: const Text('Publicar en este dispositivo')),
                    const SizedBox(height: 8),
                    Text(mensaje,
                        style: Theme.of(context).textTheme.bodySmall),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                          onPressed: () => setState(() => abierto = false),
                          child: const Text('Cerrar panel')),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
    ]);
  }
}
