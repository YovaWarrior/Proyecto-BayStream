import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design/design.dart';
import '../../../../core/utils/iso_coordinate_parser.dart';
import '../../domain/entities/entities.dart';
import '../../domain/services/loading_plan_progress.dart';
import '../../domain/services/reference_bay.dart';
import '../formatters/operation_text.dart';
import '../formatters/vessel_error_message.dart';
import '../providers/discharge_provider.dart';
import '../providers/loading_operation_provider.dart';
import '../providers/loading_plan_provider.dart';
import 'loading_plan_controls.dart' show BayPlanMode;

/// El resumen del modo en fichas de una línea (`DESIGN.md` 14.7): primero la
/// bahía, que las tarjetas no dicen; después el modo y el otro modo. En la
/// oficina va en la franja de cifras; en el teléfono, en la línea de T-107.
///
/// Con [cifrasDeLaBahia] (la oficina, 10.40: bajan de la franja de la bahía)
/// la ficha de la bahía empieza por ellas: «Bahía 02: 20 contenedores,
/// 231.9 t; 3 por bajar en cub., …». Sin escala, o mientras se lee la
/// operación, van en una ficha propia (`cifras-de-la-bahia`).
///
/// Con [soloLaBahia] (el teléfono con la barra de la operación del muelle,
/// que ya cuenta el modo) queda la bahía y lo que falta por hacer. Las fichas
/// conservan las claves de las frases de T-107 (`loading-operation-totals`,
/// `bay-discharge-pending`, `operation-discharge-totals`,
/// `bay-loading-pending`).
///
/// T-124 (10.65, P2) · En Carga y en Contenido, lo pendiente es del grupo de
/// la par que cubre la bahía (H5, `reference_bay.dart`). La ficha dice lo de
/// la bahía que se ve con su número y lo del grupo con el rótulo de su par:
/// «Bahía 21: 7 contenedores, …; grupo 22 (21, 22 y 23), por cargar cub. 27,
/// bod. 0». Una bahía que no se cuenta con otra sigue como antes.
List<Widget> fichasDelResumen(
  BuildContext context,
  WidgetRef ref, {
  required VesselVoyage voyage,
  required BayPlanMode modo,
  required int? bahia,
  bool soloLaBahia = false,
  String? cifrasDeLaBahia,
}) {
  final semanticos = BsColoresSemanticos.de(context);
  BsFichaDeCifra revisar(String clave, String texto) => BsFichaDeCifra(
      key: ValueKey<String>(clave), valor: texto, rol: semanticos.revisar);
  String rotuloDeBahia(int numero) =>
      'Bahía ${numero.toString().padLeft(2, '0')}';
  // Lo que la ficha de la bahía dice de la operación, detrás de las cifras.
  String conCifras(String valor) =>
      cifrasDeLaBahia == null ? valor : '$cifrasDeLaBahia; $valor';
  final soloLasCifras = <Widget>[
    if (bahia != null && cifrasDeLaBahia != null)
      BsFichaDeCifra(
          key: const ValueKey('cifras-de-la-bahia'),
          rotulo: rotuloDeBahia(bahia),
          valor: cifrasDeLaBahia),
  ];

  // Sin escala no hay operación: la bahía y el viaje entero.
  if (voyage.portOfCall == null) {
    return <Widget>[
      ...soloLasCifras,
      BsFichaDeCifra(
        key: const ValueKey('resumen-del-viaje'),
        rotulo: 'Viaje',
        valor: '${operationCount(voyage.totalContainers, 'contenedor', 'contenedores')}, '
            '${operationCount(voyage.bays.length, 'bahía', 'bahías')}, '
            '${formatearToneladas(voyage.totalWeight)}',
      ),
    ];
  }

  if (modo == BayPlanMode.loading) {
    return ref.watch(loadingOperationProvider(voyage)).when(
          loading: () => <Widget>[
            ...soloLasCifras,
            const BsFichaDeCifra(
                key: ValueKey('resumen-leyendo'),
                valor: 'Leyendo el plan combinado…'),
          ],
          error: (error, stack) => <Widget>[
            ...soloLasCifras,
            revisar(
                'resumen-error',
                vesselErrorMessage(
                    error, stack, 'leer el plan de carga de la operación')),
          ],
          data: (data) {
            final enLaBahia =
                bahia == null ? null : data.progress.forBay(bahia);
            final grupo = bahia == null || enLaBahia == null
                ? null
                : grupoDeLaPar(bahia, enLaBahia, data.progress.plan);
            final pendiente =
                'cub. ${enLaBahia?.deck}, bod. ${enLaBahia?.hold}';
            return <Widget>[
              if (bahia != null)
                BsFichaDeCifra(
                  key: const ValueKey('loading-bay-pending'),
                  rotulo: rotuloDeBahia(bahia),
                  valor: enLaBahia == null
                      ? conCifras('sin carga pendiente')
                      : cifrasDeLaBahia == null
                          ? (grupo == null ? pendiente : '$grupo, $pendiente')
                          : conCifras(grupo == null
                              ? 'por cargar $pendiente'
                              : '$grupo, por cargar $pendiente'),
                ),
              if (!soloLaBahia) ...<Widget>[
                BsFichaDeCifra(
                  key: const ValueKey('loading-operation-totals'),
                  rotulo: 'Carga',
                  valor:
                      '${operationCount(data.progress.total, 'pendiente', 'pendientes')}, '
                      '${operationCount(data.progress.full, 'lleno', 'llenos')}, '
                      '${operationCount(data.progress.empty, 'vacío', 'vacíos')}',
                ),
                BsFichaDeCifra(
                  key: const ValueKey('loading-discharge-totals'),
                  rotulo: 'Descarga',
                  // Con U+2011, «re‑estibas» no se parte en el guion (T-107).
                  valor:
                      '${operationCount(data.discharge.pending, 'pendiente', 'pendientes')}, '
                      '${operationCount(data.discharge.restows, 're‑estiba', 're‑estibas')}',
                ),
              ],
              // T-122 (H4, 10.51): sin listado, los llenos del plan se
              // cargan por su número; los vacíos esperan su fila.
              if (data.list == null)
                BsFichaDeCifra(
                    key: const ValueKey('loading-sin-listado'),
                    rotulo: 'Sin listado de agencia',
                    valor: 'los llenos se cargan por su número; '
                        'los vacíos esperan el listado',
                    rol: semanticos.revisar),
            ];
          },
        );
  }

  if (modo == BayPlanMode.discharge && offersDischarge(voyage)) {
    final progreso = ref.watch(dischargeProgressProvider(voyage));
    if (progreso.hasError) {
      return <Widget>[
        ...soloLasCifras,
        revisar(
            'resumen-error',
            vesselErrorMessage(progreso.error!, progreso.stackTrace,
                'calcular los pendientes de descarga')),
      ];
    }
    final data = progreso.value;
    if (data == null) {
      return <Widget>[
        ...soloLasCifras,
        const BsFichaDeCifra(
            key: ValueKey('resumen-leyendo'),
            valor: 'Leyendo el estado de la operación…'),
      ];
    }
    final enLaBahia = bahia == null ? null : data.forBay(bahia);
    final carga = soloLaBahia
        ? null
        : ref.watch(loadingOperationProvider(voyage)).value?.progress;
    return <Widget>[
      if (bahia != null)
        BsFichaDeCifra(
          key: const ValueKey('bay-discharge-pending'),
          rotulo: enLaBahia == null
              ? rotuloDeBahia(bahia)
              : 'Bahía ${enLaBahia.label}',
          valor: conCifras(enLaBahia == null
              ? 'nada por bajar'
              : '${enLaBahia.deckPending} por bajar en cub., '
                  '${enLaBahia.holdPending} en bod., '
                  '${operationCount(enLaBahia.discharged, 'bajado', 'bajados')}'
                  '${enLaBahia.restows == 0 ? '' : ', ${operationCount(enLaBahia.restows, 're‑estiba', 're‑estibas')}'}'),
        ),
      if (!soloLaBahia)
        BsFichaDeCifra(
          key: const ValueKey('operation-discharge-totals'),
          rotulo: voyage.portOfCall,
          valor: '${data.pending} por bajar, '
              '${operationCount(data.discharged, 'bajado', 'bajados')}, '
              '${operationCount(data.restows, 're‑estiba', 're‑estibas')}',
        ),
      if (carga != null)
        BsFichaDeCifra(
          key: const ValueKey('discharge-loading-totals'),
          rotulo: 'Carga',
          valor: operationCount(carga.total, 'pendiente', 'pendientes'),
        ),
      if (!data.canRegister)
        revisar(
            'discharge-sin-operacion',
            'Esta escala todavía no tiene operación guardada: vuelve a '
                'abrir el BAPLIE de llegada y confirma la escala para '
                'registrar.'),
    ];
  }

  // Contenido y Número de orden: la carga pendiente de la bahía.
  final progreso = ref.watch(loadingPlanProgressProvider(voyage));
  if (progreso.hasError) {
    return <Widget>[
      ...soloLasCifras,
      revisar(
          'resumen-error',
          vesselErrorMessage(progreso.error!, progreso.stackTrace,
              'calcular los pendientes de carga')),
    ];
  }
  final data = progreso.value;
  if (data == null) {
    return <Widget>[
      ...soloLasCifras,
      const BsFichaDeCifra(
          key: ValueKey('resumen-leyendo'),
          valor: 'Leyendo el estado de la operación…'),
    ];
  }
  final enLaBahia = bahia == null ? null : data.forBay(bahia);
  final grupo = bahia == null || enLaBahia == null
      ? null
      : grupoDeLaPar(bahia, enLaBahia, data.plan);
  final deLaCarga = grupo == null ? 'carga' : 'carga del $grupo';
  final carga = enLaBahia == null
      ? 'nada pendiente'
      : 'cub. ${enLaBahia.deck} '
          '(${operationCount(enLaBahia.deckFull, 'lleno', 'llenos')}, '
          '${operationCount(enLaBahia.deckEmpty, 'vacío', 'vacíos')}), '
          'bod. ${enLaBahia.hold} '
          '(${operationCount(enLaBahia.holdFull, 'lleno', 'llenos')}, '
          '${operationCount(enLaBahia.holdEmpty, 'vacío', 'vacíos')})';
  return <Widget>[
    if (bahia != null)
      BsFichaDeCifra(
        key: const ValueKey('bay-loading-pending'),
        // Con las cifras, la carga va detrás: «Bahía 02: 20 contenedores,
        // 231.9 t; carga: cub. 3 (…)»; con el grupo de la par, «…; carga del
        // grupo 22 (21, 22 y 23): cub. 27 (…)».
        rotulo: '${rotuloDeBahia(bahia)}'
            '${cifrasDeLaBahia == null ? ', $deLaCarga' : ''}',
        valor: cifrasDeLaBahia == null
            ? carga
            : conCifras('$deLaCarga: $carga'),
      ),
    if (modo == BayPlanMode.order)
      if (data.list == null)
        revisar('order-sin-listado',
            'Esta operación todavía no tiene listado de agencia.')
      else
        BsFichaDeCifra(
          key: const ValueKey('order-unmatched'),
          rotulo: 'Listado',
          valor: operationCount(data.unmatched, 'celda de carga sin cruce',
              'celdas de carga sin cruce'),
        ),
  ];
}

/// T-124 (10.65, P2) · El nombre del grupo de la par que cuenta [bahia], si
/// es otro que la bahía sola: «grupo 22 (21, 22 y 23)». Es nulo si [grupo] es
/// la propia [bahia] y no cuenta ninguna vecina, que es lo de siempre.
///
/// Las bahías del grupo son las del plan de carga que la regla de
/// `reference_bay.dart` cuenta con su par (la misma de [LoadingPlanProgress]),
/// más la que se ve: una mitad de 20 sin carga propia también es del grupo.
String? grupoDeLaPar(int bahia, BayLoadingPending grupo, OperationPlan plan) {
  if (grupo.bay == bahia && !grupo.paired) return null;
  final delPlan = <int>{
    for (final item in plan.loading.values)
      IsoCoordinateParser.parse(item.plannedPosition).bay,
    bahia,
  };
  final miembros = <int>[
    for (final b in <int>[grupo.bay - 1, grupo.bay, grupo.bay + 1])
      if (delPlan.contains(b) &&
          referenceBay(b, hasBay: delPlan.contains) == grupo.bay)
        b,
  ];
  if (!miembros.contains(bahia)) miembros.add(bahia);
  final rotulos = <String>[
    for (final b in miembros..sort()) b.toString().padLeft(2, '0'),
  ];
  final lista = rotulos.length == 1
      ? rotulos.single
      : '${rotulos.sublist(0, rotulos.length - 1).join(', ')} y ${rotulos.last}';
  return 'grupo ${grupo.label} ($lista)';
}
