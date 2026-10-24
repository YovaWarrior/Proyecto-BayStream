// T-99 · La app del producto con almacenes propios y sin Firebase.
//
// La interfaz es la de lib/ (BayStreamApp y VesselOverviewPage), sin tocarla.
// Cambian solo los almacenes, que se inyectan, y el repositorio de buques, que
// no puede crear FirebaseFirestore.instance sin Firebase inicializado. Sin
// Firebase, la sesión y la sincronización quedan en el modo de un solo
// dispositivo (operation_sync_factory.dart). Estas mediciones no usan sesión.
import 'dart:async';

import 'package:baystream/core/app.dart';
import 'package:baystream/features/vessel/data/repositories/vessel_repository_impl.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/repositories/local_vessel_repository.dart';
import 'package:baystream/features/vessel/domain/repositories/movement_log_repository.dart';
import 'package:baystream/features/vessel/domain/services/operation_sources.dart';
import 'package:baystream/features/vessel/presentation/providers/movement_log_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/vessel_providers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// El namespace de los almacenes del banco: `t99` (ficha de T-99, «Clientes»)
/// o el que pida la compilación (`--dart-define=T99_NAMESPACE=r4` para los
/// clientes del rediseño, 10.9), siempre aparte de los de la app instalada.
const t99Namespace =
    String.fromEnvironment('T99_NAMESPACE', defaultValue: 't99');

/// La app con los almacenes que se pasan, para el banco y para el arnés.
Widget t99App({
  required Future<LocalVesselRepository> Function() local,
  required Future<MovementLogRepository> Function() bitacora,
  TransitionBuilder? builder,
}) =>
    ProviderScope(overrides: [
      vesselRepositoryProvider
          .overrideWith((ref) => VesselRepositoryImpl(firestore: _SinNube())),
      localVesselRepositoryProvider.overrideWith((ref) async {
        final repo = await local();
        ref.onDispose(() => unawaited(repo.close()));
        return repo;
      }),
      movementLogRepositoryProvider.overrideWith((ref) async {
        final repo = await bitacora();
        ref.onDispose(() => unawaited(repo.close()));
        return repo;
      }),
    ], child: BayStreamApp(builder: builder));

/// Publica [texto] como lo haría una persona que acepta lo que propone la
/// app: el perfil guardado si existe; si no, la geometría propuesta desde el
/// archivo, la escala sugerida y, si la app pregunta, «Carga», que es el
/// botón principal del diálogo «Tipo de BAPLIE» (vessel_overview_page.dart).
/// Devuelve el error, o `null` si quedó publicado.
Future<String?> t99Publicar(VoyageNotifier n, String texto, String nombre) async {
  var r = await n.parseBaplieContent(texto, fileName: nombre);
  if (!r.success) return r.errorMessage ?? 'Carga cancelada';
  if (r.needsIdentity) {
    r = await n.resolveIdentity(n.identityCandidates.first);
    if (!r.success) return r.errorMessage ?? 'Identidad sin resolver';
  }
  final pendiente = n.pendingVoyage;
  if (pendiente == null) return null;
  final perfil = n.currentProfile ?? VesselProfile.proposeFrom(pendiente);
  final propuesta =
      VesselProfile.proposeFrom(pendiente, parameters: perfil.geometry).geometry;
  final geometria = perfil.origin != VesselProfileOrigin.proposedFromFile &&
          perfil.geometry.coversAll(pendiente.stowagePositions)
      ? perfil.geometry
      : propuesta;
  final puerto = pendiente.suggestPortOfCall(n.lastConfirmedPortOfCall) ??
      pendiente.portOfOrigin;
  final tipo = puerto != null && OperationSources.baplieKind(pendiente, puerto) == null
      ? OperationSourceKind.loadingBaplie
      : null;
  return n.confirmGeometry(geometria, portOfCall: puerto, sourceKind: tipo);
}

/// En las mediciones sin Firebase, el repositorio real solo usa su parseo.
/// Una llamada remota accidental falla de inmediato; no se simula la red.
class _SinNube implements FirebaseFirestore {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw StateError('T-99 no usa Firebase: acceso remoto no permitido.');
}
