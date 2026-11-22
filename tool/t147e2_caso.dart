// T-147, entrega 2, parte 2a · El caso A09 leído con el lector del producto.
//
// Lee el plan de carga y el listado del caso, que viven FUERA del
// repositorio, con las mismas clases que usa la app, y saca las cifras que la
// propuesta dio como oráculo (E2-P1 a E2-P4 y E2-P7 de
// `docs/T147-RESULTADOS.md`) y lo que la propuesta dejó como cuenta:
//
// - el listado: lo que se carga y lo que la agencia cancela, por su nota;
// - las equivalencias: lo que se propone solo, lo pendiente, las celdas sin
//   dueño con su sugerencia y, declaradas, el cruce;
// - la hoja «Vacíos del listado» desde una celda de 40 pies y desde una de 20;
// - **las 408 cargas registradas** y el BAPLIE de salida: cuántos `LOC+83`,
//   cuántas cargas salen con el código ISO que el plan trae para esa pieza, y
//   la salida releída con el lector;
// - lo que la importación deja en el dispositivo, y lo que pasa con algo
//   guardado que el plan contradice.
//
// No copia nada del caso: en la salida van conteos, códigos, posiciones y
// números de orden, nunca una matrícula. Solo escribe dentro de build/t147.
//
//   dart run tool/t147e2_caso.dart --plan RUTA.edi --listado RUTA.xlsx
//       [--escala GTSTC] [--salida build/t147/e2a/caso/NOMBRE.json]
//
// Dart estándar con el dominio y los lectores de lib/. Ejecutar con el
// semáforo: un comando de Flutter o de Dart a la vez en la máquina.
import 'dart:convert';
import 'dart:io';

import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/data/services/export_list_parser_service.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/services/departure_baplie_review.dart';
import 'package:baystream/features/vessel/domain/services/departure_baplie_writer.dart';
import 'package:baystream/features/vessel/domain/services/export_list_cross_checker.dart';
import 'package:baystream/features/vessel/domain/services/repeated_containers.dart';
import 'package:baystream/features/vessel/domain/services/load_check.dart';
import 'package:baystream/features/vessel/domain/services/loading_operation.dart';

/// Lo que elige la persona: los seis tipos que ningún contenedor respalda.
const _elegidos = {
  '45HC': 'L5G1',
  '20OT': '22U1',
  '40FF': '42P3',
  '40HF': '45P3',
  '40OT': '42U1',
  '40RF': '42R1',
};

Map<String, int> _contar(Iterable<String?> valores) {
  final cuenta = <String, int>{};
  for (final valor in valores) {
    final clave = valor ?? '(sin dato)';
    cuenta[clave] = (cuenta[clave] ?? 0) + 1;
  }
  return Map.fromEntries(
      cuenta.entries.toList()..sort((a, b) => a.key.compareTo(b.key)));
}

Movement _movimiento(MovementDraft draft, int n) => Movement(
    id: 'm$n',
    operationId: draft.operationId,
    type: draft.type,
    target: draft.target,
    payload: draft.payload,
    author: const MovementAuthor(name: 'Caso', role: OperatorRole.dock),
    deviceId: 't147e2-caso',
    sequence: n,
    createdAt: DateTime.utc(2026, 11, 20, 12).add(Duration(seconds: n)));

Map<String, Object?> _describir(EquivalenceProposal p) => {
      'listado': p.listCode,
      'plan': p.planCode,
      'tambienLlena': p.also,
      'origen': p.origin.name,
      'filas': p.rows,
      'respaldo': p.observed,
      if (p.discarded != null) 'guardadaQueNoSeUso': p.discarded,
    };

void main(List<String> argumentos) {
  final opciones = <String, String>{'escala': 'GTSTC'};
  for (var i = 0; i + 1 < argumentos.length; i += 2) {
    opciones[argumentos[i].replaceFirst('--', '')] = argumentos[i + 1];
  }
  final rutaPlan = opciones['plan'];
  final rutaListado = opciones['listado'];
  final salidaJson = opciones['salida'];
  if (rutaPlan == null || rutaListado == null) {
    stderr.writeln('Faltan --plan y --listado.');
    exitCode = 2;
    return;
  }
  if (salidaJson != null &&
      !salidaJson.replaceAll(r'\', '/').startsWith('build/t147/')) {
    stderr.writeln('--salida tiene que estar dentro de build/t147.');
    exitCode = 2;
    return;
  }
  final raiz = Directory.current.absolute.path.toLowerCase();
  for (final ruta in [rutaPlan, rutaListado]) {
    if (File(ruta).absolute.path.toLowerCase().startsWith(raiz)) {
      stderr.writeln('$ruta está dentro del repositorio: el caso se lee de '
          'fuera.');
      exitCode = 2;
      return;
    }
  }
  final escala = opciones['escala']!;
  final textoPlan = latin1.decode(File(rutaPlan).readAsBytesSync());
  final leido = BaplieParserService().parse(textoPlan);
  final plan = leido.withGeometry(VesselProfile.proposeFrom(leido).geometry,
      portOfCall: escala);
  final lista = const ExportListParserService()
      .parseXlsx(File(rutaListado).readAsBytesSync(), fileName: 'LISTADO.xlsx');
  final r = <String, Object?>{'escala': escala};

  // 1. El listado: lo que se carga y lo que la agencia cancela.
  final canceladas = lista.cancelledRows.toList();
  final cargan = lista.loadRows.toList();
  r['listado'] = {
    'filas': lista.rows.length,
    'paraCargar': cargan.length,
    'llenosParaCargar': cargan.where((x) => x.isFull).length,
    'vaciosParaCargar': cargan.where((x) => x.isEmpty).length,
    'canceladas': canceladas.length,
    'canceladasLlenas': canceladas.where((x) => x.isFull).length,
    'canceladasVacias': canceladas.where((x) => x.isEmpty).length,
    'canceladasPorNota': lista.cancelNotes,
    'ordenDeLosVaciosCancelados':
        canceladas.where((x) => x.isEmpty).map((x) => x.order).toList(),
    'notasSinReconocer': lista.unrecognizedNotes,
    'filasSinEntender': lista.issues.length,
    'tiposDeLoQueSeCarga': _contar(cargan.map((x) => x.listType)),
    'potDeLoQueSeCarga': _contar(cargan.map((x) => x.listPot)),
  };

  // 2. Las equivalencias, en un equipo sin nada guardado.
  final iniciales =
      ExportListCrossChecker.propose(lista, plan, portOfCall: escala);
  var propuestas = [
    for (final p in iniciales)
      p.kind == EquivalenceKind.type && p.needsUser && _elegidos[p.listCode] != null
          ? p.choose(_elegidos[p.listCode]!)
          : p
  ];
  final huerfanos = ExportListCrossChecker.orphanTypeCodes(propuestas, plan,
      portOfCall: escala);
  r['equivalencias'] = {
    'pendientes': [
      for (final p in iniciales)
        if (p.needsUser) '${p.kind.wire}:${p.listCode} (${p.rows})'
    ],
    'propuestasConTambienLlena': [
      for (final p in iniciales)
        if (p.also.isNotEmpty) _describir(p)
    ],
    'elegidas': _elegidos,
    'celdasSinDuenio': {
      for (final h in huerfanos)
        h.code: {
          'celdas': h.cells,
          'sugerencia': h.suggestedListCode == null
              ? null
              : '${h.suggestedListCode} (${h.suggestedPlanCode})',
        }
    },
    'celdasSinDuenioEnTotal': huerfanos.fold<int>(0, (s, h) => s + h.cells),
    'celdasConSugerencia': huerfanos
        .where((h) => h.suggestedListCode != null)
        .fold<int>(0, (s, h) => s + h.cells),
  };
  // La oficina acepta cada sugerencia.
  for (final h in huerfanos) {
    final tipo = h.suggestedListCode;
    if (tipo == null) continue;
    propuestas = [
      for (final p in propuestas)
        p.kind == EquivalenceKind.type && p.listCode == tipo
            ? p.withAlso([...p.also, h.code])
            : p
    ];
  }
  final familias = ExportListCrossChecker.familiesOf(propuestas);
  final normalizada = lista.normalized(
      ExportListCrossChecker.tableOf(propuestas),
      typeFamilies: familias);
  final cruce = ExportListCrossChecker.crossCheck(normalizada, plan, escala);
  r['declarado'] = {
    'tambienLlena': {
      for (final p in propuestas)
        if (p.also.isNotEmpty) p.listCode: [p.planCode, ...p.also]
    },
    'celdasSinDuenioQueQuedan': ExportListCrossChecker.orphanTypeCodes(
            propuestas, plan,
            portOfCall: escala)
        .map((h) => h.code)
        .toList(),
    'conflictosDeUnCodigoEnDosTipos':
        ExportListCrossChecker.familyConflicts(propuestas).length,
  };
  r['cruce'] = {
    'llenosQueCruzan': cruce.matches.length,
    'llenosParaCargar': cruce.matches.length + cruce.fullsNotInPlan.length,
    'llenosQueNoEstanEnElPlan': cruce.fullsNotInPlan.length,
    'delPlanQueNoEstanEnElListado': cruce.planNotInList.length,
    'vaciosEnGrupos': cruce.emptiesInGroups,
    'vaciosSinGrupo': cruce.emptiesWithoutGroup.length,
    'grupos': cruce.groups.length,
    'gruposQueCuadran': cruce.groups.where((g) => g.balanced).length,
    'llenosConDatosDistintos': cruce.matchesWithDifferences.length,
    'canceladas': cruce.cancelled.length,
    'canceladasQueElPlanTodaviaCarga': cruce.cancelledInPlan.length,
    'limpio': cruce.clean,
    'porGrupo': {
      for (final g in cruce.groups)
        '${g.type} · ${g.pod} · ${g.line}': {
          'vacios': g.empties.length,
          'celdas': g.planCells,
          'deQueCodigos': g.cellsByCode,
        }
    },
  };

  // 3. La hoja «Vacíos del listado».
  final sinCargas =
      LoadingOperation.build(operationId: 'caso', loading: plan, list: normalizada);
  Map<String, Object?> hoja(String posicion) {
    final celda = plan.reservedSlots
        .firstWhere((s) => s.stowagePosition.toIsoCode() == posicion);
    final filas = sinCargas.rowsFor(celda, '');
    final suyos = filas.where((x) => sinCargas.sameGroup(celda, x)).toList();
    bool porOrden(List<ExportListRow> l) {
      for (var i = 1; i < l.length; i++) {
        if (l[i].order < l[i - 1].order) return false;
      }
      return true;
    }

    final largo = celda.stowagePosition.bay.isOdd ? 20 : 40;
    return {
      'celda': posicion,
      'grupoDeLaCelda':
          '${celda.isoSizeType} · ${celda.portOfDischarge} · ${celda.operatorCode}',
      'filasQueOfrece': filas.length,
      'deSuGrupo': suyos.length,
      'deOtroGrupo': filas.length - suyos.length,
      'queNoCabenPorElLargo': filas
          .where((x) =>
              nominalLength(x.type) != null && nominalLength(x.type) != largo)
          .length,
      'canceladasQueOfrece': filas.where((x) => x.cancelled).length,
      'primerosDoce': filas.take(12).map((x) => x.order).toList(),
      'suGrupoVaPorOr': porOrden(suyos),
      'losDemasVanPorOr': porOrden(filas.skip(suyos.length).toList()),
      'alBuscarUnVacioCancelado': {
        for (final orden
            in canceladas.where((x) => x.isEmpty).map((x) => x.order))
          '$orden': sinCargas
              .rowsFor(celda, '$orden')
              .where((x) => x.order == orden && x.cancelled)
              .length
      },
    };
  }

  final celdaDe20 = plan.reservedSlots
      .firstWhere((s) => s.portOfLoading == escala && s.stowagePosition.bay.isOdd)
      .stowagePosition
      .toIsoCode();
  r['hoja'] = {
    'desdeUnaCeldaDe40': hoja('0181088'),
    'desdeUnaCeldaDe20': hoja(celdaDe20),
  };

  // 4. Las 408 cargas, registradas: cada lleno en su celda del plan y cada
  //    vacío en una celda de su grupo.
  final movimientos = <Movement>[];
  final codigoDelPlan = <String, String?>{};
  var n = 0;
  for (final m in cruce.matches) {
    movimientos.add(_movimiento(
        MovementDraft.loadFull(
            'caso', m.row.containerId, m.container.stowagePosition!.toIsoCode(),
            order: m.row.order),
        ++n));
    codigoDelPlan[m.row.containerId] = m.container.isoSizeType;
  }
  for (final g in cruce.groups) {
    // Los vacíos que el plan ya trae con su número suben como un lleno: en
    // su celda. Los demás, a las celdas reservadas del grupo, en su orden.
    final conNumero = {for (final c in g.numberedEmpties) c.containerId: c};
    final sinNumero = [
      for (final x in g.empties)
        if (!conNumero.containsKey(x.containerId)) x
    ];
    for (final x in g.empties) {
      final c = conNumero[x.containerId];
      if (c == null) continue;
      movimientos.add(_movimiento(
          MovementDraft.loadFull(
              'caso', x.containerId, c.stowagePosition!.toIsoCode(),
              order: x.order),
          ++n));
      codigoDelPlan[x.containerId] = c.isoSizeType;
    }
    for (var i = 0; i < sinNumero.length && i < g.reservedSlots.length; i++) {
      final celda = g.reservedSlots[i];
      movimientos.add(_movimiento(
          MovementDraft.assignEmpty('caso', celda.stowagePosition.toIsoCode(),
              sinNumero[i].containerId, sinNumero[i].tareKg,
              order: sinNumero[i].order),
          ++n));
      codigoDelPlan[sinNumero[i].containerId] = celda.isoSizeType;
    }
  }
  final cargada = LoadingOperation.build(
      operationId: 'caso',
      loading: plan,
      list: normalizada,
      movements: movimientos);
  r['cargas'] = {
    'registradas': movimientos.length,
    'llenos':
        movimientos.where((m) => m.type == MovementType.loadFull).length,
    'vaciosAsignados':
        movimientos.where((m) => m.type == MovementType.assignEmpty).length,
    'pendientesAlFinal': cargada.progress.total,
    'conflictos': _contar(cargada.state.conflicts.map((c) => c.kind.name)),
  };

  // 5. El BAPLIE de salida, con todo cargado.
  final operacion = Operation(
      id: 'caso',
      vesselName: plan.vessel.name,
      voyageNumber: plan.voyageNumber,
      portOfCall: escala,
      createdAt: DateTime.utc(2026, 11, 20),
      sources: [
        OperationSource(
            kind: OperationSourceKind.loadingBaplie,
            fileName: 'PLAN.edi',
            content: textoPlan),
      ]);
  // Donde el plan y el listado no coinciden en las peligrosas o en la
  // temperatura, la oficina elige por contenedor (T-132). Aquí se elige el
  // plan en todas, para poder contar la salida.
  final previa = const DepartureBaplieWriter().generate(
      operation: operacion,
      state: cargada.state,
      list: normalizada,
      movements: movimientos,
      now: DateTime.utc(2026, 11, 20, 12),
      preview: true);
  final salida = const DepartureBaplieWriter().generate(
      operation: operacion,
      state: cargada.state,
      list: normalizada,
      movements: movimientos,
      now: DateTime.utc(2026, 11, 20, 12),
      choices: {for (final d in previa.decisions) d.id: DepartureChoice.plan},
      preview: true);
  final isoEnLaSalida = <String, String>{};
  for (final segmento in salida.text.split("'")) {
    final s = segmento.trim();
    if (!s.startsWith('EQD+CN+')) continue;
    final e = s.split('+');
    isoEnLaSalida[e[2].split(':').first] = e[3].split(':').first;
  }
  final releida = BaplieParserService().parse(salida.text);
  final destinoReleido = {
    for (final c in releida.containers) c.containerId: c.finalDestination
  };
  final conDestino = [
    for (final x in cargan)
      if (x.potDiffersFromPod) x
  ];
  r['salida'] = {
    'sePuedeGuardar': salida.canSave,
    'contenedores': salida.containers,
    'segmentosLoc83': 'LOC+83+'.allMatches(salida.text).length,
    'segmentosLoc13': 'LOC+13+'.allMatches(salida.text).length,
    'cargasConDestinoFinal': salida.finalDestinations,
    'deEllasLlenas': conDestino.where((x) => x.isFull).length,
    'deEllasVacias': conDestino.where((x) => x.isEmpty).length,
    'cargasConElCodigoIsoDelPlan': [
      for (final e in codigoDelPlan.entries)
        if (isoEnLaSalida[e.key] == e.value) e.key
    ].length,
    'cargasConOtroCodigoIso': [
      for (final e in codigoDelPlan.entries)
        if (isoEnLaSalida[e.key] != e.value) e.key
    ].length,
    'vaciosEnUnaCeldaDeOtroCodigoDeSuTipo': [
      for (final m in movimientos)
        if (m.type == MovementType.assignEmpty &&
            codigoDelPlan[m.payload['container']] !=
                normalizada.byContainer(m.payload['container']! as String)!.type)
          m
    ].length,
    'releida': {
      'contenedores': releida.containers.length,
      'celdasReservadas': releida.reservedSlots.length,
      'avisosDelLector': {
        for (final aviso in releida.readNotices)
          aviso.kind.name: aviso.details.length
      },
      'conDestinoFinal':
          releida.containers.where((c) => c.finalDestination != null).length,
      'cargasCuyoDestinoFinalEsElPodDelListado': conDestino
          .where((x) => destinoReleido[x.containerId] == x.listPod)
          .length,
    },
    'filasQueNoCargaron': salida.notLoaded.length,
    'motivos': _contar(salida.notLoaded.map((l) {
      final motivo = l.substring(l.indexOf(' · ', l.indexOf(' · ') + 3) + 3);
      return motivo.replaceFirst(RegExp(r' \(«.*»\)$'), '');
    })),
    'avisos': salida.warnings.length,
    'datosPorConfirmar': previa.decisions.length,
    'datosPorConfirmarPorAsunto':
        _contar(previa.decisions.map((d) => d.subject)),
    'datosQueImpidenGuardar': salida.errors.length,
  };

  // 6. Lo que queda en el dispositivo, y lo guardado que el plan contradice.
  final dispositivo = ExportListCrossChecker.deviceTableOf(propuestas);
  final segunda = ExportListCrossChecker.propose(lista, plan,
      portOfCall: escala, saved: dispositivo);
  final sembrado = ExportListCrossChecker.propose(lista, plan,
      portOfCall: escala,
      saved: CodeEquivalences({
        EquivalenceKind.type: {'40ST': '45G1', '45HC': 'L5G9'},
        EquivalenceKind.port: {'COTRB': 'JMKIN'},
        EquivalenceKind.line: {'LGH': 'LNK'},
      }));
  r['dispositivo'] = {
    'guardaTipos': dispositivo.of(EquivalenceKind.type).length,
    'guardaLineas': dispositivo.of(EquivalenceKind.line).length,
    'guardaPuertos': dispositivo.of(EquivalenceKind.port).length,
    'enLaSegundaImportacion': {
      'pendientes': segunda.where((p) => p.needsUser).length,
      'guardadasQueSeUsan':
          segunda.where((p) => p.origin == EquivalenceOrigin.saved).length,
    },
    'conAlgoGuardadoQueElPlanContradice': [
      for (final p in sembrado)
        if (p.discarded != null ||
            (p.kind == EquivalenceKind.port && p.listCode == 'COTRB'))
          _describir(p)
    ],
  };

  // Parte 2b: las agencias (O-147-4), el POT y el POD de lo que se carga
  // (O-147-8), la tarjeta con tipos por elegir (O-147-7), el lápiz (O-147-10)
  // y las matrículas repetidas (P5). Las claves de arriba no cambian.
  final sinElegir = ExportListCrossChecker.orphanTypeCodes(iniciales, plan,
      portOfCall: escala);
  final hc = propuestas.firstWhere(
      (p) => p.kind == EquivalenceKind.type && p.listCode == '40HC');
  final conElLapiz = [
    for (final p in propuestas) identical(p, hc) ? p.choose('45G0') : p
  ];
  final cambiada = conElLapiz.firstWhere(
      (p) => p.kind == EquivalenceKind.type && p.listCode == '40HC');
  final cruceDelLapiz = ExportListCrossChecker.crossCheck(
      lista.normalized(ExportListCrossChecker.tableOf(conElLapiz),
          typeFamilies: ExportListCrossChecker.familiesOf(conElLapiz)),
      plan,
      escala);
  r['parte2b'] = {
    'agencias': lista.agencyCount,
    'porAgencia': [
      for (final g in lista.agencyGroups)
        {
          'filas': g.rows,
          'secciones': g.sections,
          'esAgregados': g.added,
        }
    ],
    'potYPodDistintos': {
      'queSeCargan': cargan.where((x) => x.potDiffersFromPod).length,
      'canceladas': canceladas.where((x) => x.potDiffersFromPod).length,
    },
    'conTiposPorElegir': {
      'tiposPorElegir': iniciales
          .where((p) => p.kind == EquivalenceKind.type && p.needsUser)
          .length,
      'codigosSinDuenio': sinElegir.length,
      'celdasSinDuenio': sinElegir.fold<int>(0, (s, h) => s + h.cells),
    },
    'elLapizDe40HC': {
      'antes': [hc.planCode, ...hc.also],
      'despues': [cambiada.planCode, ...cambiada.also],
      'gruposQueCuadranAntes': cruce.groups.where((g) => g.balanced).length,
      'gruposQueCuadranDespues':
          cruceDelLapiz.groups.where((g) => g.balanced).length,
      'grupos': cruceDelLapiz.groups.length,
      'celdasSinDuenioDespues': ExportListCrossChecker.orphanTypeCodes(
              conElLapiz, plan,
              portOfCall: escala)
          .map((h) => h.code)
          .toList(),
      'conflictos': ExportListCrossChecker.familyConflicts(conElLapiz).length,
    },
    'matriculasRepetidasEnElPlan': RepeatedContainers.of(plan).length,
  };

  final texto = const JsonEncoder.withIndent(' ').convert(r);
  if (salidaJson != null) {
    File(salidaJson)
      ..createSync(recursive: true)
      ..writeAsStringSync(texto);
  }
  stdout.writeln(texto);
}
