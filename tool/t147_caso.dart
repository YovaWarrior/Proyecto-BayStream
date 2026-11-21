// T-147 · El caso A09 leído con el lector del producto.
//
// Lee un plan de carga (BAPLIE) y un listado de la agencia (.xlsx) que viven
// FUERA del repositorio, con las mismas clases que usa la app, y saca las
// cifras que `docs/S4-CASO-A09.md` da para la pantalla: el plan, la carga de
// la escala, el listado, las equivalencias y el cruce. Con `--medir` mide
// además lo que cuesta armar la hoja «Vacíos del listado» desde una celda
// reservada: con la expresión que usaba `_LoadingPickerState.build` hasta la
// 1.0.1 (`candidateSlots` por cada fila), contando cuántas veces esa
// expresión leía `OperationState.occupancy`, y con la de T-147 (`rowsFor`).
// La versión que corrió contra `37be8a5`, sin `rowsFor`, que ahí no existe,
// está en build/t147/e1/antes/herramientas/.
//
// No copia nada del caso: en la salida van conteos, códigos y posiciones,
// nunca una matrícula. Solo escribe dentro de build/t147.
//
//   dart run tool/t147_caso.dart --plan RUTA.edi --listado RUTA.xlsx
//       [--escala GTSTC] [--elegir tipo:20ST=22G1,puerto:INMUN=COCTG,...]
//       [--salida build/t147/e1/caso/NOMBRE.json] [--medir] [--celda 0180682]
//
// Dart estándar con el dominio y los lectores de lib/. Ejecutar con el
// semáforo: un comando de Flutter o de Dart a la vez en la máquina.
import 'dart:convert';
import 'dart:io';

import 'package:baystream/core/errors/exceptions.dart';
import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/data/services/export_list_parser_service.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/services/export_list_cross_checker.dart';
import 'package:baystream/features/vessel/domain/services/loading_operation.dart';

const _uso = '''
dart run tool/t147_caso.dart --plan RUTA.edi --listado RUTA.xlsx [opciones]
  --plan RUTA      El plan de carga, fuera del repositorio.
  --listado RUTA   El listado de la agencia (.xlsx), fuera del repositorio.
  --escala CÓDIGO  El puerto de la escala. Por omisión: GTSTC.
  --elegir LISTA   Las equivalencias que elige la persona, separadas por comas:
                   tipo:20ST=22G1, puerto:INMUN=COCTG o linea:LGH=LNH.
  --salida RUTA    Un .json dentro de build/t147. Por omisión no escribe.
  --medir          Mide la hoja «Vacíos del listado» desde una celda reservada.
  --celda BBBRRTT  La celda de la medición. Por omisión: la primera reservada
                   de la bahía con más reservas.
  --help           Muestra esta ayuda.
''';

class _Fallo implements Exception {
  const _Fallo(this.mensaje);
  final String mensaje;
}

Future<void> main(List<String> argumentos) async {
  try {
    if (argumentos.contains('--help') || argumentos.contains('-h')) {
      stdout.write(_uso);
      return;
    }
    await _correr(_opciones(argumentos));
  } on _Fallo catch (error) {
    stderr
      ..writeln('T-147: ${error.mensaje}')
      ..write(_uso);
    exitCode = 2;
  } on BaplieParsingException catch (error) {
    stderr.writeln('T-147: el lector rechazó el plan: ${error.message}');
    exitCode = 2;
  } on ExportListParsingException catch (error) {
    stderr.writeln('T-147: el lector rechazó el listado: ${error.message}');
    exitCode = 2;
  } on FileSystemException catch (error) {
    stderr.writeln('T-147: ${error.message}: ${error.path ?? ''}');
    exitCode = 2;
  }
}

Map<String, String> _opciones(List<String> argumentos) {
  const conValor = {'--plan', '--listado', '--escala', '--elegir', '--salida', '--celda'};
  final opciones = <String, String>{'escala': 'GTSTC'};
  for (var i = 0; i < argumentos.length; i++) {
    final nombre = argumentos[i];
    if (nombre == '--medir') {
      opciones['medir'] = 'si';
    } else if (conValor.contains(nombre) && i + 1 < argumentos.length) {
      opciones[nombre.substring(2)] = argumentos[++i];
    } else {
      throw _Fallo('Opción desconocida o sin valor: $nombre');
    }
  }
  for (final obligatoria in const ['plan', 'listado']) {
    if (!opciones.containsKey(obligatoria)) {
      throw _Fallo('Falta --$obligatoria.');
    }
  }
  return opciones;
}

/// El caso real no entra al repositorio: una ruta de dentro se rechaza.
File _fueraDelRepositorio(String ruta) {
  final archivo = File(ruta).absolute;
  final raiz = Directory.current.absolute.path.toLowerCase();
  final normal = archivo.path.replaceAll('/', r'\').toLowerCase();
  if (normal.startsWith(raiz.replaceAll('/', r'\'))) {
    throw _Fallo('$ruta está dentro del repositorio: el caso se lee de fuera.');
  }
  if (!archivo.existsSync()) throw _Fallo('No existe $ruta.');
  return archivo;
}

EquivalenceKind _tipoDeEquivalencia(String nombre) => switch (nombre) {
      'tipo' => EquivalenceKind.type,
      'puerto' => EquivalenceKind.port,
      'linea' => EquivalenceKind.line,
      _ => throw _Fallo('Equivalencia desconocida: $nombre (tipo, puerto o linea).'),
    };

String _nombreDe(EquivalenceKind kind) => switch (kind) {
      EquivalenceKind.type => 'tipo',
      EquivalenceKind.port => 'puerto',
      EquivalenceKind.line => 'linea',
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

Future<void> _correr(Map<String, String> opciones) async {
  final escala = opciones['escala']!;
  final archivoPlan = _fueraDelRepositorio(opciones['plan']!);
  final archivoListado = _fueraDelRepositorio(opciones['listado']!);
  final salida = opciones['salida'];
  if (salida != null &&
      !salida.replaceAll(r'\', '/').startsWith('build/t147/')) {
    throw const _Fallo('--salida tiene que estar dentro de build/t147.');
  }

  // 1. El plan, como lo abre la app: el lector y la geometría propuesta.
  final texto = latin1.decode(await archivoPlan.readAsBytes());
  final leido = BaplieParserService().parse(texto);
  final plan = leido.withGeometry(VesselProfile.proposeFrom(leido).geometry,
      portOfCall: escala);
  final cargados = [
    for (final c in plan.containers)
      if (c.portOfLoading == escala) c
  ];
  final reservasDeLaEscala = [
    for (final s in plan.reservedSlots)
      if (s.portOfLoading == escala) s
  ];
  final porBahia = <String, Map<String, Object>>{};
  for (final numero in plan.bays.keys.toList()..sort()) {
    final contenedores = plan.getContainersInBay(numero);
    final reservas = plan.getReservedSlotsInBay(numero);
    final kilos = contenedores.fold<double>(
        0, (suma, c) => suma + (c.effectiveWeight ?? 0));
    porBahia[numero.toString().padLeft(2, '0')] = {
      'contenedores': contenedores.length,
      'reservas': reservas.length,
      'toneladas': (kilos / 100).round() / 10,
    };
  }
  final resultado = <String, Object?>{
    'escala': escala,
    'plan': {
      'bytes': await archivoPlan.length(),
      'contenedores': plan.containers.length,
      'reservas': plan.reservedSlots.length,
      'bahias': plan.bays.length,
      'porPuertoDeCarga': _contar([
        for (final c in plan.containers) c.portOfLoading,
        for (final s in plan.reservedSlots) s.portOfLoading,
      ]),
      'seCarganEnLaEscala': {
        'contenedoresLlenos':
            cargados.where((c) => c.status == ContainerStatus.full).length,
        'contenedoresVacios':
            cargados.where((c) => c.status == ContainerStatus.empty).length,
        'contenedoresSinEstado':
            cargados.where((c) => c.status == ContainerStatus.unknown).length,
        'reservas': reservasDeLaEscala.length,
        'descarga': _contar([
          for (final c in cargados) c.portOfDischarge,
          for (final s in reservasDeLaEscala) s.portOfDischarge,
        ]),
        'lineas': _contar([
          for (final c in cargados) c.operatorCode,
          for (final s in reservasDeLaEscala) s.operatorCode,
        ]),
      },
      // Una matrícula en dos celdas: se cuenta, no se nombra.
      'matriculasRepetidas': _contar([
        for (final c in plan.containers) c.containerId
      ]).values.where((n) => n > 1).length,
      'avisosDelLector': {
        for (final aviso in plan.readNotices)
          aviso.kind.name: {
            'casos': aviso.details.length,
            // Los avisos que no nombran contenedores se pueden citar enteros.
            if (aviso.kind.storedAsText &&
                aviso.kind != BaplieReadNoticeKind.locode)
              'texto': aviso.details,
          }
      },
      'porBahia': porBahia,
    },
  };

  // 2. El listado, como lo lee la importación.
  final lista = const ExportListParserService().parseXlsx(
      await archivoListado.readAsBytes(),
      fileName: 'LISTADO.xlsx');
  resultado['listado'] = {
    'filas': lista.rows.length,
    'llenos': lista.fulls.length,
    'vacios': lista.empties.length,
    'agencias': lista.agencies.length,
    'filasPorSeccion': lista.agencies.values.toList(),
    'filasSinEntender': [
      for (final issue in lista.issues) issue.sheetRow,
    ],
    'tipos': _contar(lista.rows.map((r) => r.listType)),
    'pot': _contar(lista.rows.map((r) => r.listPot)),
    'pod': lista.rows.map((r) => r.listPod).toSet().length,
    'potDistintoDelPod':
        lista.rows.where((r) => r.listPot != null && r.listPot != r.listPod).length,
    'lineas': _contar(lista.rows.map((r) => r.listLine)),
  };

  // 3. Las equivalencias que propone la app, sin nada guardado en el equipo.
  var propuestas =
      ExportListCrossChecker.propose(lista, plan, portOfCall: escala);
  Map<String, Object?> describir(EquivalenceProposal p) => {
        'clase': _nombreDe(p.kind),
        'listado': p.listCode,
        'plan': p.planCode,
        'origen': p.origin.name,
        'filas': p.rows,
        'respaldo': p.observed,
        'ofrece': p.candidates,
      };
  resultado['equivalencias'] = {
    'pendientes': [
      for (final p in propuestas)
        if (p.needsUser) describir(p)
    ],
    'deducidasQueTraducen': [
      for (final p in propuestas)
        if (!p.needsUser && !p.isIdentity) describir(p)
    ],
    'identidades': {
      for (final kind in EquivalenceKind.values)
        _nombreDe(kind): [
          for (final p in propuestas)
            if (p.kind == kind && !p.needsUser && p.isIdentity)
              '${p.listCode} (${p.origin.name}, respaldo ${p.evidence})'
        ]
    },
  };

  // 4. Lo que elige la persona, y el cruce.
  final elegidas = <String>[];
  for (final par in (opciones['elegir'] ?? '').split(',')) {
    if (par.trim().isEmpty) continue;
    final partes = RegExp(r'^(\w+):([^=]+)=(.+)$').firstMatch(par.trim());
    if (partes == null) throw _Fallo('No se entiende --elegir «$par».');
    final kind = _tipoDeEquivalencia(partes[1]!);
    final hallada = propuestas
        .where((p) => p.kind == kind && p.listCode == partes[2])
        .firstOrNull;
    if (hallada == null) {
      throw _Fallo('El listado no trae ${partes[1]} ${partes[2]}.');
    }
    propuestas = [
      for (final p in propuestas)
        identical(p, hallada) ? p.choose(partes[3]!) : p
    ];
    elegidas.add(par.trim());
  }
  final faltan = [
    for (final p in propuestas)
      if (p.needsUser) '${_nombreDe(p.kind)}:${p.listCode}'
  ];
  resultado['elegidas'] = elegidas;
  resultado['faltanPorElegir'] = faltan;

  LoadingOperation? operacion;
  if (faltan.isEmpty) {
    final normalizada =
        lista.normalized(ExportListCrossChecker.tableOf(propuestas));
    final cruce =
        ExportListCrossChecker.crossCheck(normalizada, plan, escala);
    final distintos = cruce.matchesWithDifferences.toList();
    bool porTipo(ExportListMatch m) =>
        m.differences.any((d) => d.startsWith('tipo '));
    bool porPuerto(ExportListMatch m) =>
        m.differences.any((d) => d.startsWith('descarga '));
    resultado['cruce'] = {
      'llenosQueCruzan': cruce.matches.length,
      'llenosDelListado': cruce.matches.length + cruce.fullsNotInPlan.length,
      'delPlanQueNoEstanEnElListado': cruce.planNotInList.length,
      'vaciosEnGrupos': cruce.emptiesInGroups,
      'vaciosDelListado':
          cruce.emptiesInGroups + cruce.emptiesWithoutGroup.length,
      'grupos': cruce.groups.length,
      'gruposQueCuadran': cruce.groups.where((g) => g.balanced).length,
      'llenosQueNoEstanEnElPlan': cruce.fullsNotInPlan.length,
      'llenosConDatosDistintos': distintos.length,
      'distintosPorElTipo': distintos.where(porTipo).length,
      'distintosPorElPuerto': distintos.where(porPuerto).length,
      'distintosPorLosDos':
          distintos.where((m) => porTipo(m) && porPuerto(m)).length,
      'llenosConVgmDistinto': cruce.weightDifferences,
      'toneladasDelPlanMenosElListado':
          (cruce.weightDifferenceKg / 100).round() / 10,
      'porGrupo': [
        for (final g in cruce.groups)
          [
            '${g.type} · ${g.pod} · ${g.line}: ${g.empties.length} vacíos',
            '${g.planCells} celdas${g.numberedEmpties.isEmpty ? '' : ' (${g.numberedEmpties.length} ya con número)'}',
          ].join(', ')
      ],
    };

    // 5. La operación de la escala, como la deriva el modo Carga.
    final armar = Stopwatch()..start();
    operacion = LoadingOperation.build(
        operationId: 't147', loading: plan, list: normalizada);
    armar.stop();
    resultado['carga'] = {
      'pendientes': operacion.progress.total,
      'llenos': operacion.progress.full,
      'vacios': operacion.progress.empty,
      'piezasDelPlan': operacion.plan.loading.length,
      'armarLaOperacionMs': armar.elapsedMicroseconds / 1000,
    };
  }

  if (opciones.containsKey('medir')) {
    if (operacion == null) {
      throw const _Fallo('--medir necesita todas las equivalencias elegidas.');
    }
    resultado['medicion'] = _medir(operacion, plan, opciones['celda']);
    resultado['otrosRecorridos'] =
        _otrosRecorridos(operacion, plan, operacion.list!);
  }

  const codificador = JsonEncoder.withIndent('  ');
  final json = codificador.convert(resultado);
  stdout.writeln(json);
  if (salida != null) {
    final archivo = File(salida);
    await archivo.parent.create(recursive: true);
    await archivo.writeAsString('$json\n');
  }
}

/// La expresión de `_LoadingPickerState.build` (`loading_controls.dart`), tal
/// cual: los vacíos del listado que caben en [slot], los de su grupo primero.
List<ExportListRow> _filasDeLaHoja(LoadingOperation data, ReservedSlot slot) {
  final rows = data
      .search('', empties: true)
      .where((row) => data
          .candidateSlots(row, otherGroups: true)
          .any((s) => s.key == slot.key))
      .toList();
  bool sameGroup(ExportListRow row) =>
      slot.isoSizeType == row.type &&
      slot.portOfDischarge == row.pod &&
      slot.operatorCode == row.line;
  rows.sort(
      (a, b) => (sameGroup(a) ? 0 : 1).compareTo(sameGroup(b) ? 0 : 1));
  return rows;
}

/// Cuántas veces leía `occupancy` esa expresión en el código de `37be8a5`:
/// una por cada pieza que pasa las cinco primeras condiciones de `slots` y
/// una por cada reserva que llega a la lectura en `candidateSlots`. Es una
/// réplica de los dos recorridos, sin tocar el producto.
int _lecturasDeOcupacion(LoadingOperation data) {
  var lecturas = 0;
  final ocupadas = data.state.occupancy;
  for (final row in data.search('', empties: true)) {
    if (!row.isEmpty || data.numbered(row) != null || !data.available(row)) {
      continue;
    }
    final libres = <String>{};
    for (final item in data.plan.loading.values) {
      final slot = item.reservedSlot;
      if (item.role == PlanRole.load &&
          slot != null &&
          slot.isoSizeType == row.type &&
          slot.portOfDischarge == row.pod &&
          slot.operatorCode == row.line &&
          data.state[item.key]?.state == ItemState.planned) {
        lecturas++;
        if (!ocupadas.containsKey(item.plannedPosition)) {
          libres.add(item.key);
        }
      }
    }
    for (final item in data.plan.loading.values) {
      if (item.reservedSlot == null ||
          item.role != PlanRole.load ||
          libres.contains(item.key) ||
          data.state[item.key]?.state != ItemState.planned) {
        continue;
      }
      lecturas++;
    }
  }
  return lecturas;
}

/// La mediana de cinco corridas de [trabajo], en milisegundos, después de una
/// corrida de calentamiento.
double _mediana(void Function() trabajo) {
  trabajo();
  final tiempos = [
    for (var i = 0; i < 5; i++)
      () {
        final reloj = Stopwatch()..start();
        trabajo();
        reloj.stop();
        return reloj.elapsedMicroseconds / 1000;
      }()
  ]..sort();
  return tiempos[2];
}

/// Los otros recorridos de la carga que repiten el patrón (10.151, regla 1),
/// cada uno con lo que cuesta con el caso: el diálogo «Asignar vacío», la
/// revisión, el rearmado de la operación por cada movimiento y la corrección
/// de un vacío ya asignado. Usa las expresiones de `loading_controls.dart`.
Map<String, Object?> _otrosRecorridos(
    LoadingOperation data, VesselVoyage plan, ExportList lista) {
  // Un vacío con celdas libres en su grupo, y la primera de ellas.
  late ExportListRow fila;
  late ReservedSlot celda;
  for (final candidata in data.search('', empties: true)) {
    final libres = data.slots(candidata);
    if (libres.isNotEmpty) {
      fila = candidata;
      celda = libres.first;
      break;
    }
  }
  final posicion = celda.stowagePosition.toIsoCode();
  final resultado = <String, Object?>{
    // Cada `ref.watch(loadingOperationProvider(voyage))` busca el proveedor
    // por su viaje, y eso calcula la huella (`hashCode`) del viaje entero:
    // contenedores, reservas y bahías. No es de la hoja; se anota.
    'huellaDelViajePorLecturaMs': _mediana(() => plan.hashCode),
    'buscarPorOrMs': _mediana(() => data.search('')),
    'dialogoAsignarVacio': {
      'celdasConOtrosGrupos':
          data.candidateSlots(fila, otherGroups: true).length,
      'candidateSlotsMs':
          _mediana(() => data.candidateSlots(fila, otherGroups: true)),
      // Una lectura de la ocupación por cada opción de la lista desplegable.
      'ocupacionPorOpcionMs': _mediana(() {
        for (final s in data.candidateSlots(fila, otherGroups: true)) {
          data.state.occupancy.containsKey(s.stowagePosition.toIsoCode());
        }
      }),
      'revisionMs': _mediana(() => data.check(fila, posicion)),
    },
  };

  // Un vacío asignado: lo que cuesta cada movimiento y corregirlo.
  final borrador = data.draft(fila, posicion);
  final movimiento = Movement(
      id: 't147-m1',
      operationId: 't147',
      type: borrador.type,
      target: borrador.target,
      payload: borrador.payload,
      author: const MovementAuthor(name: 'T147', role: OperatorRole.dock),
      deviceId: 't147',
      sequence: 1,
      createdAt: DateTime.utc(2026, 11, 19));
  LoadingOperation armar() => LoadingOperation.build(
      operationId: 't147',
      loading: plan,
      list: lista,
      movements: [movimiento]);
  final conUno = armar();
  resultado['rearmarLaOperacionPorMovimientoMs'] = _mediana(armar);
  resultado['corregirUnVacioAsignado'] = {
    'vaciosQueOfrece': lista.empties
        .where((r) =>
            conUno.available(r, correcting: movimiento) &&
            conUno.numbered(r) == null)
        .length,
    'alternativasMs': _mediana(() => lista.empties
        .where((r) =>
            conUno.available(r, correcting: movimiento) &&
            conUno.numbered(r) == null)
        .toList()),
    'candidateSlotsMs': _mediana(
        () => conUno.candidateSlots(fila, correcting: movimiento)),
    'revisionMs':
        _mediana(() => conUno.check(fila, posicion, correcting: movimiento)),
  };
  return resultado;
}

Map<String, Object?> _medir(
    LoadingOperation data, VesselVoyage plan, String? celda) {
  final ReservedSlot slot;
  if (celda != null) {
    slot = plan.reservedSlots.firstWhere(
        (s) => s.stowagePosition.toIsoCode() == celda,
        orElse: () => throw _Fallo('No hay una celda reservada en $celda.'));
  } else {
    final porBahia = <int, List<ReservedSlot>>{};
    for (final s in plan.reservedSlots) {
      porBahia.putIfAbsent(s.stowagePosition.bay, () => []).add(s);
    }
    final mayor = porBahia.values.reduce((a, b) => a.length >= b.length ? a : b)
      ..sort((a, b) => a.stowagePosition
          .toIsoCode()
          .compareTo(b.stowagePosition.toIsoCode()));
    slot = mayor.first;
  }

  double ms(void Function() trabajo) {
    final reloj = Stopwatch()..start();
    trabajo();
    reloj.stop();
    return reloj.elapsedMicroseconds / 1000;
  }

  // La primera corrida va aparte: la máquina virtual todavía no optimizó.
  var filas = const <ExportListRow>[];
  final corridas = [
    for (var i = 0; i < 4; i++) ms(() => filas = _filasDeLaHoja(data, slot))
  ];
  const vueltas = 2000;
  var piezas = 0;
  final ocupacion = ms(() {
    for (var i = 0; i < vueltas; i++) {
      piezas += data.state.occupancy.length;
    }
  });
  final lecturas = _lecturasDeOcupacion(data);
  final porLectura = ocupacion / vueltas;
  final otroGrupo = filas
      .where((row) => !(slot.isoSizeType == row.type &&
          slot.portOfDischarge == row.pod &&
          slot.operatorCode == row.line))
      .length;
  return {
    'celda': slot.stowagePosition.toIsoCode(),
    'grupoDeLaCelda':
        '${slot.isoSizeType} · ${slot.portOfDischarge} · ${slot.operatorCode}',
    'vaciosQueBuscaLaHoja': data.search('', empties: true).length,
    'filasQueOfrece': filas.length,
    'deSuGrupo': filas.length - otroGrupo,
    'deOtroGrupo': otroGrupo,
    'primeraCorridaMs': corridas.first,
    'corridasMs': corridas.sublist(1),
    // Lo que la hoja hace desde T-147: decide una vez si la celda admite un
    // vacío (`rowsFor`) y ordena, sin `candidateSlots` por fila.
    'laHojaDesdeT147Ms': _mediana(() {
      bool suGrupo(ExportListRow row) =>
          slot.isoSizeType == row.type &&
          slot.portOfDischarge == row.pod &&
          slot.operatorCode == row.line;
      data.rowsFor(slot, '').sort(
          (a, b) => (suGrupo(a) ? 0 : 1).compareTo(suGrupo(b) ? 0 : 1));
    }),
    'ofreceLoMismoQueLa101': () {
      final hoy = data.rowsFor(slot, '');
      final antes = data
          .search('', empties: true)
          .where((row) => data
              .candidateSlots(row, otherGroups: true)
              .any((s) => s.key == slot.key))
          .toList();
      return hoy.length == antes.length &&
          [for (var i = 0; i < hoy.length; i++) hoy[i].order == antes[i].order]
              .every((igual) => igual);
    }(),
    'piezasConPosicion': piezas ~/ vueltas,
    'unaLecturaDeOcupacionMs': porLectura,
    'lecturasDeOcupacionPorHoja': lecturas,
    'lecturasPorSuCostoMs': lecturas * porLectura,
  };
}
