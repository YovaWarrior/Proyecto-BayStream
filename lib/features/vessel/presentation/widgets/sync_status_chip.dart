import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/operation_sync_repository.dart';
import '../pages/cloud_page.dart';
import '../providers/sync_providers.dart';

String _count(int n, String singular, String plural) =>
    '$n ${n == 1 ? singular : plural}';

String _clock(DateTime value) {
  final local = value.toLocal();
  return '${local.hour.toString().padLeft(2, '0')}:'
      '${local.minute.toString().padLeft(2, '0')}';
}

/// T-79 · Lo que la pantalla dice del envío (T-79a 4.2 y 4.5), con texto e
/// icono, no solo con color.
String syncStatusText(SyncStatus status) {
  final parts = <String>[
    switch (status.state) {
      SyncState.localOnly => 'Solo este dispositivo',
      SyncState.upToDate => 'Al día',
      SyncState.sending => 'Enviando ${status.pending}',
      SyncState.offline => status.pending == 0
          ? 'Sin conexión'
          : 'Sin conexión · ${status.pending} por enviar',
      SyncState.sessionExpired =>
        'Sesión vencida: inicia sesión para enviar ${status.pending}',
      SyncState.notAuthorized =>
        'Tu cuenta no está autorizada · ${_count(status.pending, 'espera', 'esperan')}',
      SyncState.unconfirmed => 'Sin confirmar desde las '
          '${_clock(status.since!)} · inicia sesión de nuevo',
    },
    if (status.rejected > 0) _count(status.rejected, 'rechazado', 'rechazados'),
    if (status.otherAuthor > 0)
      '${_count(status.otherAuthor, 'de otra cuenta espera', 'de otra cuenta esperan')} a su autor',
    if (status.localOnly > 0 && status.state != SyncState.localOnly)
      '${_count(status.localOnly, 'movimiento sin cuenta', 'movimientos sin cuenta')}: solo aquí',
    if (status.closed) 'operación cerrada',
  ];
  return parts.join(' · ');
}

IconData syncStatusIcon(SyncStatus status) => switch (status.state) {
      SyncState.localOnly => Icons.phone_android,
      SyncState.upToDate =>
        status.rejected > 0 ? Icons.cloud_sync_outlined : Icons.cloud_done_outlined,
      SyncState.sending => Icons.cloud_upload_outlined,
      SyncState.offline => Icons.cloud_off_outlined,
      SyncState.sessionExpired => Icons.lock_clock_outlined,
      SyncState.notAuthorized => Icons.block,
      SyncState.unconfirmed => Icons.warning_amber_outlined,
    };

/// Un problema que pide algo al usuario.
bool syncStatusNeedsAction(SyncStatus status) =>
    status.rejected > 0 ||
    status.state == SyncState.sessionExpired ||
    status.state == SyncState.notAuthorized ||
    status.state == SyncState.unconfirmed;

Future<void> openCloudPage(BuildContext context) => Navigator.of(context)
    .push(MaterialPageRoute<void>(builder: (_) => const CloudPage()));

/// El estado de envío de la escala que se ve; lleva a «Nube y cuenta».
class SyncStatusChip extends ConsumerWidget {
  const SyncStatusChip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(syncStatusProvider).value ?? SyncStatus.local;
    final colors = Theme.of(context).colorScheme;
    final alert = syncStatusNeedsAction(status);
    return ActionChip(
      key: const ValueKey('sync-status-chip'),
      avatar: Icon(syncStatusIcon(status),
          size: 18, color: alert ? colors.error : colors.primary),
      label: Text(syncStatusText(status),
          style: alert ? TextStyle(color: colors.error) : null),
      tooltip: 'Nube y cuenta',
      onPressed: () => openCloudPage(context),
    );
  }
}

/// Botón de la barra superior. Al mirar el estado mantiene vivo el motor
/// mientras la escala está abierta, aunque el plano no esté en pantalla.
class SyncAppBarButton extends ConsumerWidget {
  const SyncAppBarButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(syncStatusProvider).value ?? SyncStatus.local;
    final alert = syncStatusNeedsAction(status);
    return IconButton(
      key: const ValueKey('cloud-page'),
      icon: Icon(
          status.state == SyncState.localOnly
              ? Icons.cloud_outlined
              : syncStatusIcon(status),
          color: alert ? Theme.of(context).colorScheme.error : null),
      tooltip: 'Nube y cuenta · ${syncStatusText(status)}',
      onPressed: () => openCloudPage(context),
    );
  }
}
