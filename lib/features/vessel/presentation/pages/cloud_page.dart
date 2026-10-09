import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/entities.dart';
import '../../domain/repositories/operation_sync_repository.dart';
import '../../domain/repositories/session_repository.dart';
import '../formatters/vessel_error_message.dart';
import '../providers/movement_log_provider.dart';
import '../providers/sync_providers.dart';
import '../providers/vessel_providers.dart';
import '../widgets/sync_status_chip.dart';

/// T-79 · Cuenta, operación de la escala y operaciones abiertas en la nube.
///
/// - Sin cuenta, la app sigue en el modo de un solo dispositivo.
/// - No hay registro: las cuentas las crea el responsable en la consola y las
///   autoriza por su identificador, con su rol (10.3).
/// - La oficina publica y cierra; el muelle se une a una operación abierta.
class CloudPage extends ConsumerStatefulWidget {
  const CloudPage({super.key});

  @override
  ConsumerState<CloudPage> createState() => _CloudPageState();
}

class _CloudPageState extends ConsumerState<CloudPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;
  String? _message;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _run(Future<String?> Function() action, {String? done}) async {
    setState(() {
      _busy = true;
      _message = null;
    });
    String? error;
    try {
      error = await action();
    } catch (failure, stack) {
      error = vesselErrorMessage(failure, stack);
    }
    if (!mounted) return;
    setState(() {
      _busy = false;
      _message = error ?? done;
    });
  }

  void _changed() => ref.read(operationSourcesRevisionProvider.notifier).changed();

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionRepositoryProvider).value;
    final operator = ref.watch(operatorProvider).value;
    return Scaffold(
      appBar: AppBar(title: const Text('Nube y cuenta')),
      body: ListView(
        key: const ValueKey('cloud-page-list'),
        padding: const EdgeInsets.all(16),
        children: [
          if (_message != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(_message!, key: const ValueKey('cloud-message')),
            ),
          _section(context, 'Cuenta'),
          if (session == null)
            const Text('Leyendo la sesión…')
          else if (!session.supportsAccounts)
            const Text('Esta compilación no tiene la nube configurada: la app '
                'trabaja en un solo dispositivo.')
          else if (operator == null)
            _signInForm(context)
          else
            _account(context, operator),
          const SizedBox(height: 24),
          _section(context, 'Operación de la escala abierta'),
          _activeOperation(context, operator),
          if (operator != null && operator.authorized) ...[
            const SizedBox(height: 24),
            _section(context, 'Operaciones abiertas en la nube'),
            _openOperations(context),
          ],
        ],
      ),
    );
  }

  Widget _section(BuildContext context, String title) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(title, style: Theme.of(context).textTheme.titleMedium),
      );

  Widget _signInForm(BuildContext context) {
    return AutofillGroup(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Sin cuenta, lo que registres se queda en este dispositivo. '
            'Las cuentas las crea el responsable: la app no tiene registro.'),
        const SizedBox(height: 12),
        TextField(
          key: const ValueKey('sign-in-email'),
          controller: _email,
          keyboardType: TextInputType.emailAddress,
          autofillHints: const [AutofillHints.email],
          decoration: const InputDecoration(
              labelText: 'Correo', border: OutlineInputBorder()),
        ),
        const SizedBox(height: 8),
        TextField(
          key: const ValueKey('sign-in-password'),
          controller: _password,
          obscureText: true,
          autofillHints: const [AutofillHints.password],
          decoration: const InputDecoration(
              labelText: 'Contraseña', border: OutlineInputBorder()),
          onSubmitted: (_) => _signIn(),
        ),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: [
          FilledButton(
              key: const ValueKey('sign-in-button'),
              onPressed: _busy ? null : _signIn,
              child: const Text('Iniciar sesión')),
          TextButton(
              key: const ValueKey('password-reset-button'),
              onPressed: _busy
                  ? null
                  : () => _run(() async {
                        if (_email.text.trim().isEmpty) {
                          return 'Escribe tu correo para recuperar la contraseña.';
                        }
                        final session =
                            await ref.read(sessionRepositoryProvider.future);
                        return (await session.sendPasswordReset(_email.text))
                            .fold((f) => f.message, (_) => null);
                      },
                          done: 'Si el correo tiene cuenta, llegará un enlace '
                              'para cambiar la contraseña.'),
              child: const Text('Olvidé mi contraseña')),
        ]),
      ]),
    );
  }

  void _signIn() => _run(() async {
        final session = await ref.read(sessionRepositoryProvider.future);
        final result = await session.signIn(_email.text, _password.text);
        _password.clear();
        return result.fold((failure) => failure.message, (_) => null);
      });

  Widget _account(BuildContext context, Operator operator) {
    final role = operator.role == OperatorRole.office ? 'Oficina' : 'Muelle';
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('${operator.name} · $role', key: const ValueKey('account-name')),
      Text(operator.authorized
          ? 'Cuenta autorizada'
          : 'Cuenta sin autorizar: lo que registres espera a que el '
              'responsable la active.'),
      if (operator.cached) const Text('Sin conexión: datos guardados de la cuenta.'),
      const SizedBox(height: 8),
      OutlinedButton(
        key: const ValueKey('sign-out-button'),
        onPressed: _busy
            ? null
            : () => _run(() async {
                  final session = await ref.read(sessionRepositoryProvider.future);
                  return (await session.signOut()).fold((f) => f.message, (_) => null);
                },
                    done: 'Sesión cerrada. Lo pendiente de esta cuenta espera a '
                        'que vuelva a iniciar sesión.'),
        child: const Text('Cerrar sesión'),
      ),
    ]);
  }

  Widget _activeOperation(BuildContext context, Operator? operator) {
    final operation = ref.watch(activeOperationProvider).value;
    if (operation == null) {
      return const Text('Abre un plano con su escala confirmada para ver su operación.');
    }
    final status = ref.watch(syncStatusProvider).value ?? SyncStatus.local;
    final office = operator != null &&
        operator.authorized &&
        operator.role == OperatorRole.office;
    final sync = ref.watch(operationSyncProvider).value;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('${operation.vesselName} · ${operation.voyageNumber} · ${operation.portOfCall}'),
      Text(operation.published
          ? (operation.closed ? 'Publicada y cerrada' : 'Publicada')
          : 'Solo en este dispositivo'),
      const SizedBox(height: 8),
      Text(syncStatusText(status), key: const ValueKey('cloud-sync-status')),
      const SizedBox(height: 8),
      Wrap(spacing: 8, runSpacing: 8, children: [
        if (office && !operation.published)
          FilledButton(
            key: const ValueKey('publish-button'),
            onPressed: _busy || sync == null ? null : () => _publish(operation),
            child: const Text('Publicar operación'),
          ),
        if (office && operation.published && !operation.closed)
          OutlinedButton(
            key: const ValueKey('close-operation-button'),
            onPressed: _busy || sync == null ? null : () => _close(operation),
            child: const Text('Cerrar operación'),
          ),
        if (operation.published && syncStatusNeedsAction(status))
          OutlinedButton(
            key: const ValueKey('retry-button'),
            onPressed: _busy || sync == null
                ? null
                : () => _run(() async {
                      await sync.retry(operation.id);
                      return null;
                    }, done: 'Se volvió a intentar el envío.'),
            child: const Text('Reintentar'),
          ),
      ]),
    ]);
  }

  Future<void> _publish(Operation operation) async {
    var kept = 0;
    const done = 'Operación publicada.';
    await _run(() async {
      final profile = ref.read(voyageNotifierProvider.notifier).publishedProfile;
      if (profile == null) {
        return 'Abre el plano de la escala para publicarla con su perfil de buque.';
      }
      final log = await ref.read(movementLogRepositoryProvider.future);
      kept = (await log.records(operation.id)).getOrElse(() => const []).length;
      final sync = await ref.read(operationSyncProvider.future);
      return (await sync.publish(operation, profile)).fold((f) => f.message, (_) {
        _changed();
        return null;
      });
    }, done: done);
    // Lo registrado antes de publicar no se sube (10.14), y la pantalla lo dice.
    if (kept > 0 && mounted && _message == done) {
      setState(() => _message = '$done $kept movimientos registrados antes de '
          'publicar se quedan en este dispositivo.');
    }
  }

  Future<void> _close(Operation operation) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar la operación'),
        content: const Text('Los movimientos registrados después del cierre '
            'se rechazarán. No se puede volver a abrir.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          FilledButton(
              key: const ValueKey('close-operation-confirm'),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Cerrar operación')),
        ],
      ),
    );
    if (confirmed != true) return;
    await _run(() async {
      final sync = await ref.read(operationSyncProvider.future);
      return (await sync.close(operation.id)).fold((f) => f.message, (_) {
        _changed();
        return null;
      });
    }, done: 'Operación cerrada.');
  }

  Widget _openOperations(BuildContext context) {
    final remote = ref.watch(openOperationsProvider);
    final local = ref.watch(localOperationsProvider).value ?? const [];
    return remote.when(
      loading: () => const Text('Buscando operaciones abiertas…'),
      error: (error, _) => const Text(
          'No se pudieron leer las operaciones: revisa la conexión y la cuenta.'),
      data: (operations) {
        if (operations.isEmpty) return const Text('No hay operaciones abiertas.');
        return Column(children: [
          for (final operation in operations)
            _openOperationTile(context, operation,
                local.where((o) => o.id == operation.id && o.published).firstOrNull),
        ]);
      },
    );
  }

  Widget _openOperationTile(
      BuildContext context, PublishedOperation remote, Operation? joined) {
    String label(OperationSourceKind kind) => switch (kind) {
          OperationSourceKind.arrivalBaplie => 'Abrir plano de llegada',
          OperationSourceKind.loadingBaplie => 'Abrir plan de carga',
          OperationSourceKind.exportList => '',
        };
    return Card(
      key: ValueKey('open-operation-${remote.id}'),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('${remote.vesselName} · ${remote.voyageNumber} · ${remote.portOfCall}',
              style: Theme.of(context).textTheme.titleSmall),
          Text(remote.sources.isEmpty
              ? 'Sin fuentes'
              : 'Fuentes: ${remote.sources.map((k) => switch (k) {
                    OperationSourceKind.arrivalBaplie => 'llegada',
                    OperationSourceKind.loadingBaplie => 'carga',
                    OperationSourceKind.exportList => 'listado',
                  }).join(', ')}'),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: [
            if (joined == null)
              FilledButton(
                key: ValueKey('join-${remote.id}'),
                onPressed: _busy ? null : () => _join(remote.id),
                child: const Text('Unirse'),
              )
            else
              for (final kind in [
                OperationSourceKind.arrivalBaplie,
                OperationSourceKind.loadingBaplie
              ])
                if (joined.source(kind) != null)
                  OutlinedButton(
                    key: ValueKey('open-${kind.wire}-${remote.id}'),
                    onPressed: _busy ? null : () => _open(joined, kind),
                    child: Text(label(kind)),
                  ),
          ]),
        ]),
      ),
    );
  }

  Future<void> _join(String id) => _run(() async {
        final sync = await ref.read(operationSyncProvider.future);
        return (await sync.join(id)).fold((f) => f.message, (operation) {
          _changed();
          return null;
        });
      }, done: 'Te uniste a la operación. Abre su plano para trabajar.');

  Future<void> _open(Operation operation, OperationSourceKind kind) => _run(() async {
        final error = await openOperationSource(ref, operation, kind);
        if (error == null && mounted) Navigator.of(context).pop();
        return error;
      });
}

/// T-79 · Abre una fuente publicada como si fuera el archivo: con el perfil
/// de buque que publicó la oficina y la escala de la operación, sin pedir la
/// geometría otra vez.
Future<String?> openOperationSource(
    WidgetRef ref, Operation operation, OperationSourceKind kind) async {
  final source = operation.source(kind);
  if (source == null) return 'La operación no tiene esa fuente.';
  final profile = operation.profile;
  if (profile != null) {
    final local = await ref.read(localVesselRepositoryProvider.future);
    final saved = await local.saveProfile(profile, nameMatchConfirmed: true);
    final error = saved.fold<String?>(vesselFailureMessage, (_) => null);
    if (error != null) return error;
    ref.invalidate(savedVesselProfilesProvider);
  }
  final notifier = ref.read(voyageNotifierProvider.notifier);
  var result =
      await notifier.parseBaplieContent(source.content, fileName: source.fileName);
  if (!result.success) return result.errorMessage ?? 'No se abrió la fuente.';
  if (result.needsIdentity) {
    final match =
        notifier.identityCandidates.where((p) => p.key == profile?.key).firstOrNull;
    result = await notifier.resolveIdentity(match);
    if (!result.success) return result.errorMessage ?? 'No se abrió la fuente.';
  }
  if (result.needsGeometry) {
    final draft = notifier.currentProfile;
    return notifier.confirmGeometry(
      (profile ?? draft!).geometry,
      portOfCall: operation.portOfCall,
      sourceKind: kind,
      reeferSlots: profile?.reeferSlots,
      reeferSlotsOrigin: profile?.reeferSlotsOrigin,
    );
  }
  return null;
}
