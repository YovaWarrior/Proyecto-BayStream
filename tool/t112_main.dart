// Banco T-112: la UI real, en español, sin sesión ni acceso remoto.
//
// Arranca publicando un BAPLIE de ensayo escrito aquí (no es un buque real):
// un refrigerado, una IMO, bodega y cubierta, un 40, un vacío con el dígito de
// control mal, una posición mal formada, un peso en LBR, una reserva y sin
// número de viaje. Así los textos de T-112 se ven en Windows, la Web y el
// Honor sin elegir archivo. El botón real para abrir un BAPLIE sigue ahí (A07).
// Con T112_RECORRIDO, además, recorre la UI sola (tool/t112_recorrido.dart).
//
// Windows exige T112_STORE en TEMP; Android usa la carpeta privada de esta
// identidad de prueba; Web, IndexedDB del origen local. No modifica main.dart
// ni inicializa Firebase. El lector usa su adaptador real de parseo.
import 'dart:async';

import 'package:baystream/core/app.dart';
import 'package:baystream/features/vessel/data/datasources/hive_movement_data_source.dart';
import 'package:baystream/features/vessel/data/datasources/hive_vessel_data_source.dart';
import 'package:baystream/features/vessel/data/datasources/local_store_directory.dart';
import 'package:baystream/features/vessel/data/repositories/local_only_operation_sync.dart';
import 'package:baystream/features/vessel/data/repositories/local_vessel_repository_impl.dart';
import 'package:baystream/features/vessel/data/repositories/movement_log_repository_impl.dart';
import 'package:baystream/features/vessel/data/repositories/vessel_repository_impl.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/services/operation_sources.dart';
import 'package:baystream/features/vessel/presentation/providers/movement_log_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/sync_providers.dart';
import 'package:baystream/features/vessel/presentation/providers/vessel_providers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 't112_recorrido.dart';

/// El BAPLIE de ensayo. Los números de contenedor siguen ISO 6346 salvo
/// TSTU1120011 (le toca un 4), que es el que debe salir con el aviso.
const _ensayo = "UNB+UNOA:2+T112+T112+261020:1200+T112'"
    "UNH+T112+BAPLIE:D:95B:UN:SMDG22'"
    "BGM++T112+9'"
    "TDT+20++++TEST:172:20+++:::BUQUE T112'"
    "LOC+5+HNPCR:139:6'"
    "LOC+61+GTSTC:139:6'"
    "LOC+147+0020182::5'MEA+WT++KGM:18000'TMP+2+-18:CEL'"
    "LOC+9+HNPCR:139:6'LOC+11+GTSTC:139:6'EQD+CN+TSTU1120009+22R1++2+5'"
    "LOC+147+0020282::5'MEA+WT++LBR:44092'"
    "LOC+9+HNPCR:139:6'LOC+11+GTSTC:139:6'EQD+CN+TSTU1120014+22G1++2+5'"
    "DGS+IMD+3+1203'"
    "LOC+147+0020104::5'MEA+WT++KGM:22000'"
    "LOC+9+HNPCR:139:6'LOC+11+PAMIT:139:6'EQD+CN+TSTU1120020+22G1++2+5'"
    "LOC+147+0040282::5'MEA+WT++KGM:26000'"
    "LOC+9+HNPCR:139:6'LOC+11+GTSTC:139:6'EQD+CN+TSTU1120035+42G1++2+5'"
    "LOC+147+0010102::5'MEA+WT++KGM:2200'"
    "LOC+9+HNPCR:139:6'LOC+11+GTSTC:139:6'EQD+CN+TSTU1120011+22G1++2+4'"
    "LOC+147+00X0182::5'MEA+WT++KGM:12000'"
    "LOC+9+HNPCR:139:6'LOC+11+GTSTC:139:6'EQD+CN+TSTU1120040+22G1++2+5'"
    "LOC+147+0050182::5'"
    "LOC+9+GTSTC:139:6'LOC+11+PAMIT:139:6'EQD+CN++22G1+++4'"
    "UNT+36+T112'"
    "UNZ+1+T112'";

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const temporary = String.fromEnvironment('T112_STORE');
  if (!kIsWeb &&
      defaultTargetPlatform == TargetPlatform.windows &&
      !RegExp(r'[/\\]Temp[/\\]').hasMatch(temporary)) {
    throw StateError('T112_STORE debe apuntar a TEMP.');
  }
  final directory = kIsWeb
      ? null
      : defaultTargetPlatform == TargetPlatform.windows
          ? temporary
          : await localStoreDirectory();
  final container = ProviderContainer(overrides: [
    vesselRepositoryProvider
        .overrideWith((ref) => VesselRepositoryImpl(firestore: _NoCloud())),
    localVesselRepositoryProvider.overrideWith((ref) async {
      final repository = LocalVesselRepositoryImpl(
          await HiveVesselDataSource.open(
              directory: directory, namespace: 't112'));
      ref.onDispose(() => unawaited(repository.close()));
      return repository;
    }),
    movementLogRepositoryProvider.overrideWith((ref) async {
      final repository = MovementLogRepositoryImpl(
          await HiveMovementDataSource.open(
              directory: directory, namespace: 't112'));
      ref.onDispose(() => unawaited(repository.close()));
      return repository;
    }),
    sessionRepositoryProvider
        .overrideWith((ref) async => const LocalSessionRepository()),
    operationSyncProvider
        .overrideWith((ref) async => const LocalOnlyOperationSync()),
  ]);
  final error = await _publicar(
      container.read(voyageNotifierProvider.notifier), _ensayo, 'T112_ENSAYO.edi');
  if (error != null) debugPrint('T112 el ensayo no se publicó: $error');
  final recorrido = recorridoDesdeDefiniciones();
  runApp(UncontrolledProviderScope(
      container: container, child: BayStreamApp(builder: recorrido?.envoltorio)));
  recorrido?.iniciar();
}

/// Publica [texto] como lo haría una persona que acepta lo que propone la
/// app (la misma secuencia que t99Publicar de tool/t99_app.dart): el perfil
/// guardado si existe; si no, la geometría propuesta desde el archivo y la
/// escala sugerida. Devuelve el error, o `null` si quedó publicado.
Future<String?> _publicar(VoyageNotifier n, String texto, String nombre) async {
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

// Igual que los bancos de T-98 y T-111: una llamada remota accidental falla
// explícitamente, en lugar de acceder a la red o simular una respuesta válida.
class _NoCloud implements FirebaseFirestore {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw StateError('El banco T112 no admite acceso remoto.');
}
