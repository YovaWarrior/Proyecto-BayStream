// T-147 · El conductor del banco: recorre la app del producto por dentro, con
// toques de verdad sobre sus controles, y deja en `pasos.jsonl` lo que la
// pantalla dice, las capturas y los tiempos. Es el mismo en la Web y en
// Windows, y el mismo antes y después de los cambios: `_medir` no se toca.
//
// Parámetros (variables `T147_…` en Windows; `?nombre=valor` en la Web):
//   escenario  preparar | medir | recorrido (el de la sección 5, con el
//              banco «después»: el aviso del lector, el POT y la carga)
//              | recorrido2a (entrega 2, parte 2a: las canceladas,
//              «también llena», la hoja, la salida, lo guardado y la
//              revisión que cancela una fila ya cargada)
//   plan       el BAPLIE del caso, por su nombre en la carpeta del caso
//   listado    el listado de la agencia, por su nombre
//   escala     el puerto de la escala (GTSTC)
//   elegir     las equivalencias que elige la persona (tipo:20ST=22G1,…)
//   tamano     real | 360x800 | 1366x690
//   tema       dia | noche
//   celda      la celda reservada que se toca al medir (BBBRRTT); sin ella,
//              la primera que esté a la vista en su bahía
//   bahia      la bahía que se abre al medir (por omisión, la de la celda)
//   prefijo    el principio del nombre de las capturas
//   listado2   (recorrido2a) la revisión del listado que cancela `lleno`
//   lleno      (recorrido2a) el OR del lleno que se carga; por omisión, 1
//   codigo     (recorrido2a) el código ISO de la celda de otro código de
//              su tipo; por omisión, 45G0
//   cancelado  (recorrido2a) el OR de un vacío cancelado que se busca en
//              la hoja; por omisión, 156
import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;

import 'package:baystream/core/app.dart';
import 'package:baystream/features/vessel/domain/entities/app_theme_preference.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/services/export_list_cross_checker.dart';
import 'package:baystream/features/vessel/domain/services/loading_operation.dart';
import 'package:baystream/features/vessel/domain/services/operation_sources.dart';
import 'package:baystream/features/vessel/presentation/providers/export_list_providers.dart';
import 'package:baystream/features/vessel/presentation/providers/loading_operation_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/plano_providers.dart';
import 'package:baystream/features/vessel/presentation/providers/theme_preference_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/vessel_providers.dart';
import 'package:baystream/features/vessel/presentation/widgets/loading_plan_controls.dart'
    show BayPlanMode;
import 'package:baystream/features/vessel/presentation/widgets/navegacion_del_viaje.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 't147_plataforma.dart';

/// El conductor, o `null` si no se pide un escenario: entonces el banco es la
/// app para recorrerla a mano.
T147Conductor? t147Conductor() =>
    parametro('escenario').isEmpty ? null : T147Conductor(parametro('escenario'));

class T147Conductor {
  final String escenario;
  T147Conductor(this.escenario);

  final _tamano = ValueNotifier<Size?>(null);
  final _teclado = ValueNotifier<double>(0);
  final _quieto = ValueNotifier<bool>(false);
  final _lienzo = GlobalKey();
  final _errores = <String>[];
  var _puntero = 9900;
  var _paso = 0;

  String get _prefijo => parametro('prefijo');
  String get _escala =>
      parametro('escala').isEmpty ? 'GTSTC' : parametro('escala');

  /// Para `BayStreamApp.builder`: impone el tamaño lógico si se pide, simula
  /// la altura del teclado (`viewInsets`) y deja un lienzo para las capturas.
  Widget envoltorio(BuildContext context, Widget? child) =>
      ListenableBuilder(
          listenable: Listenable.merge([_tamano, _teclado, _quieto]),
          builder: (context, _) {
            final tamano = _tamano.value;
            final lienzo = RepaintBoundary(key: _lienzo, child: child);
            final base = MediaQuery.of(context);
            final datos = base.copyWith(
                size: tamano,
                viewInsets: _teclado.value == 0
                    ? null
                    : EdgeInsets.only(bottom: _teclado.value),
                disableAnimations: _quieto.value ? true : null);
            if (tamano == null) return MediaQuery(data: datos, child: lienzo);
            return ColoredBox(
                color: Theme.of(context).colorScheme.surfaceContainerLowest,
                child: FittedBox(
                    child: SizedBox.fromSize(
                        size: tamano,
                        child: MediaQuery(data: datos, child: lienzo))));
          });

  void iniciar() {
    final anterior = FlutterError.onError;
    FlutterError.onError = (detalles) {
      _errores.add(detalles.exceptionAsString().split('\n').first);
      anterior?.call(detalles);
    };
    SchedulerBinding.instance
        .addPostFrameCallback((_) => unawaited(_ejecutar()));
  }

  Future<void> _ejecutar() async {
    try {
      final especificacion = parametro('tamano');
      if (especificacion.isNotEmpty && especificacion != 'real') {
        final partes = especificacion.split('x');
        _tamano.value = Size(double.parse(partes[0]), double.parse(partes[1]));
      }
      await _contenedor().read(themePreferenceProvider.notifier).select(
          parametro('tema') == 'noche'
              ? AppThemePreference.dark
              : AppThemePreference.light);
      await _registrar('inicio', {
        'escenario': escenario,
        'tamano': especificacion.isEmpty ? 'real' : especificacion,
        'tema': parametro('tema').isEmpty ? 'dia' : parametro('tema'),
        'plan': parametro('plan'),
        'listado': parametro('listado'),
      });
      switch (escenario) {
        case 'preparar':
          _quieto.value = true;
          await _preparar();
        case 'medir':
          await _medir();
        case 'recorrido':
          _quieto.value = true;
          await _recorrido();
        case 'recorrido2a':
          _quieto.value = true;
          await _recorrido2a();
        default:
          throw StateError('Escenario desconocido: $escenario');
      }
      await _registrar('fin', {'errores_de_flutter': [..._errores]});
    } catch (error, pila) {
      await _registrar('error', {
        'detalle': '$error',
        'pila': pila.toString().split('\n').take(12).toList(),
        'errores_de_flutter': [..._errores],
      });
    }
  }

  // --- Los escenarios -----------------------------------------------------

  /// Abre el plan por la entrada del producto, lo publica con la geometría
  /// propuesta desde el archivo y la escala pedida. Devuelve si quedó en
  /// previo antes de confirmar.
  Future<bool> _abrirElPlan() async {
    final n = _contenedor().read(voyageNotifierProvider.notifier);
    final nombre = parametro('plan');
    final texto = latin1.decode(await leerDelCaso(nombre));
    var r = await n.parseBaplieContent(texto, fileName: nombre);
    if (!r.success) throw StateError(r.errorMessage ?? 'No abrió $nombre');
    if (r.needsIdentity) {
      r = await n.resolveIdentity(n.identityCandidates.first);
      if (!r.success) throw StateError(r.errorMessage ?? 'Identidad sin resolver');
    }
    await _asentar();
    return n.pendingVoyage != null;
  }

  Future<void> _confirmarElPlan() async {
    final n = _contenedor().read(voyageNotifierProvider.notifier);
    final pendiente = n.pendingVoyage;
    if (pendiente == null) return;
    final perfil = n.currentProfile ?? VesselProfile.proposeFrom(pendiente);
    final propuesta =
        VesselProfile.proposeFrom(pendiente, parameters: perfil.geometry)
            .geometry;
    final geometria = perfil.origin != VesselProfileOrigin.proposedFromFile &&
            perfil.geometry.coversAll(pendiente.stowagePositions)
        ? perfil.geometry
        : propuesta;
    final tipo = OperationSources.baplieKind(pendiente, _escala) == null
        ? OperationSourceKind.loadingBaplie
        : null;
    final error = await n.confirmGeometry(geometria,
        portOfCall: _escala, sourceKind: tipo);
    if (error != null) throw StateError(error);
    await _asentar();
  }

  Future<void> _preparar() async {
    final contenedor = _contenedor();
    await _asentar();
    await _capturar('inicio');

    // 1. El plan: en previo y publicado, con lo que dice su tarjeta.
    final enPrevio = await _abrirElPlan();
    if (enPrevio) {
      await _capturar('plan-en-previo');
      await _confirmarElPlan();
    }
    final viaje = _viaje();
    await _registrar('plan', {
      'contenedores': viaje.totalContainers,
      'celdas_reservadas': viaje.totalReservedSlots,
      'escala': viaje.portOfCall,
      'avisos_del_lector': {
        for (final aviso in viaje.readNotices)
          aviso.kind.name: aviso.details.length
      },
    });
    await _capturar('plan-publicado');
    contenedor.read(destinoDelViajeProvider.notifier).ir(DestinoDelViaje.lista);
    await _asentar();
    await _capturar('lista-tarjeta-del-viaje',
        textos: RegExp('contenedores ·|celdas? reservadas?|aviso|«'));

    // 2. La carga: lo pendiente de la escala y la ficha de una bahía.
    contenedor.read(destinoDelViajeProvider.notifier).ir(DestinoDelViaje.plano);
    contenedor.read(bayPlanModeProvider.notifier).elegir(BayPlanMode.loading);
    await _asentar();
    await _capturar('carga', textos: RegExp('pendientes|por cargar'));
    contenedor.read(selectedBayProvider.notifier).select(1);
    await _asentar();
    await _capturar('carga-bahia-01',
        textos: RegExp('Bahía 01|pendientes|por cargar'));

    // 3. El listado: lo leído, las equivalencias y el cruce.
    contenedor.read(destinoDelViajeProvider.notifier).ir(DestinoDelViaje.lista);
    await _asentar();
    await _tocarALaVista(() => _conClave('open-export-list'));
    await _asentar();
    final importacion = contenedor.read(exportListImportProvider.notifier);
    final nombre = parametro('listado');
    await importacion.loadBytes(await leerDelCaso(nombre), fileName: nombre);
    await _asentar();
    _sinAvisos();
    await _asentar();
    await _registrarElListado('listado-leido');
    await _capturar('listado-leido',
        textos: RegExp('filas en|sin entender|se entendieron|Falta elegir'));
    await _capturarEn('equivalencias', 'Equivalencias con el plan');
    for (final par in parametro('elegir').split(',')) {
      if (par.trim().isEmpty) continue;
      final partes = RegExp(r'^(\w+):([^=]+)=(.+)$').firstMatch(par.trim())!;
      importacion.choose(
          switch (partes[1]) {
            'tipo' => EquivalenceKind.type,
            'puerto' => EquivalenceKind.port,
            _ => EquivalenceKind.line,
          },
          partes[2]!,
          partes[3]!);
    }
    await _asentar();
    await _registrarElListado('listado-con-lo-elegido');
    await _capturarEn('equivalencias-elegidas', 'Equivalencias con el plan');
    await _capturarEn('cruce', 'Cruce con el plan de $_escala',
        textos: RegExp('cruzan|no est|vacíos en|datos distintos|VGM distinto|'
            r'· \w{5} · '));
    _sinAvisos();
    await _asentar();
    await _tocar(_conClave('export-list-confirm'));
    await _asentar();
    await _capturar('listado-importado',
        textos: RegExp('Listado guardado|Guardado en la operación'));
    _sinAvisos();
    await _volver();

    // 4. La carga otra vez, ya con el listado.
    contenedor.read(destinoDelViajeProvider.notifier).ir(DestinoDelViaje.plano);
    contenedor.read(bayPlanModeProvider.notifier).elegir(BayPlanMode.loading);
    await _asentar();
    await _capturar('carga-con-listado',
        textos: RegExp('pendientes|por cargar|Bahía'));
  }

  /// El recorrido de la sección 5: el plan como vino, con su aviso; el
  /// listado y su cruce, y la carga tocando la celda: un vacío en su grupo,
  /// un vacío en otro grupo con su motivo y un lleno.
  Future<void> _recorrido() async {
    final contenedor = _contenedor();
    await _asentar();

    // 1. El plan como vino.
    if (await _abrirElPlan()) {
      await _capturar('plan-en-previo');
      await _confirmarElPlan();
    }
    final viaje = _viaje();
    await _registrar('plan', {
      'contenedores': viaje.totalContainers,
      'celdas_reservadas': viaje.totalReservedSlots,
      'escala': viaje.portOfCall,
      'avisos_del_lector': {
        for (final aviso in viaje.readNotices) aviso.kind.name: aviso.details
      },
    });
    await _capturar('plan-publicado',
        textos: RegExp('Bahía|contenedores ·'));
    contenedor.read(destinoDelViajeProvider.notifier).ir(DestinoDelViaje.lista);
    await _asentar();
    await _capturar('lista-tarjeta-del-viaje',
        textos: RegExp('contenedores ·|celdas? reservadas?|en EQD|«'));
    final aviso = _buscarElemento(
        (e) => e.widget.key == const ValueKey('voyage-noNumber-notice'));
    if (aviso != null) {
      await _tocarALaVista(() => aviso);
      await _asentar();
      await _capturar('aviso-sin-matricula', textos: RegExp('«|matrícula'));
      await _volver();
    }
    contenedor.read(destinoDelViajeProvider.notifier).ir(DestinoDelViaje.plano);
    contenedor.read(bayPlanModeProvider.notifier).elegir(BayPlanMode.loading);
    await _asentar();
    await _capturar('carga-sin-listado', textos: RegExp('pendientes|por cargar'));

    // 2. El listado y su cruce.
    contenedor.read(destinoDelViajeProvider.notifier).ir(DestinoDelViaje.lista);
    await _asentar();
    await _tocarALaVista(() => _conClave('open-export-list'));
    await _asentar();
    final importacion = contenedor.read(exportListImportProvider.notifier);
    final nombre = parametro('listado');
    await importacion.loadBytes(await leerDelCaso(nombre), fileName: nombre);
    await _asentar();
    _sinAvisos();
    await _asentar();
    await _registrarElListado('listado-leido');
    await _capturar('listado-leido',
        textos: RegExp('filas en|sin entender|se entendieron|POT y POD|'
            'Falta elegir'));
    await _capturarEn('equivalencias', 'Equivalencias con el plan',
        textos: RegExp('→|Propuesta|códigos son iguales'));
    for (final par in parametro('elegir').split(',')) {
      if (par.trim().isEmpty) continue;
      final partes = RegExp(r'^(\w+):([^=]+)=(.+)$').firstMatch(par.trim())!;
      importacion.choose(
          switch (partes[1]) {
            'tipo' => EquivalenceKind.type,
            'puerto' => EquivalenceKind.port,
            _ => EquivalenceKind.line,
          },
          partes[2]!,
          partes[3]!);
    }
    await _asentar();
    await _registrarElListado('listado-con-lo-elegido');
    await _capturarEn('equivalencias-elegidas', 'Equivalencias con el plan',
        textos: RegExp('→|códigos son iguales'));
    await _capturarEn('cruce', 'Cruce con el plan de $_escala',
        textos: RegExp('cruzan|no est|vacíos en|datos distintos|VGM distinto|'
            r'· \w{5} · '));
    final filas = _buscarElemento(
        (e) => e.widget.key == const ValueKey('export-list-rows'),
        aLaVista: false);
    if (filas != null) {
      await _tocarALaVista(() => _conClave('export-list-rows'));
      await _asentar();
      await _capturarEn('filas-con-pot-y-pod', 'Filas del listado',
          textos: RegExp('^POT '), empezando: false);
    }
    _sinAvisos();
    await _asentar();
    await _tocar(_conClave('export-list-confirm'));
    await _asentar();
    await _capturar('listado-importado',
        textos: RegExp('Listado guardado|Guardado en la operación'));
    _sinAvisos();
    await _volver();

    // 3. La carga, tocando la celda.
    final bahia = int.tryParse(parametro('bahia')) ?? 18;
    contenedor.read(destinoDelViajeProvider.notifier).ir(DestinoDelViaje.plano);
    contenedor.read(bayPlanModeProvider.notifier).elegir(BayPlanMode.loading);
    contenedor.read(selectedBayProvider.notifier).select(bahia);
    await _asentar();
    await Future<void>.delayed(const Duration(seconds: 1));
    await _capturar('carga-bahia', textos: RegExp('pendientes|por cargar|Bahía'));

    // 3a. Un vacío en su grupo.
    var celda = _celdaPorCargar('loading-R:');
    await _registrar('toca', {'celda': _clave(celda)});
    await _tocar(celda);
    await _asentar();
    await _capturar('hoja-vacios',
        textos: RegExp('Vacíos del listado|Otro grupo|No hay coincidencias'));
    await _tocar(await _filaDeLaHoja(otroGrupo: false));
    await _asentar();
    await _capturar('asignar-vacio-en-su-grupo',
        textos: RegExp('Asignar vacío|OR |Revisado|Pide motivo|POT '));
    await _tocarALaVista(() => _conClave('loading-confirm'));
    await _asentar();
    await _capturar('vacio-en-su-grupo-asignado',
        textos: RegExp('Carga registrada|Cargado|pendientes'));
    _sinAvisos();
    await _asentar();

    // 3b. Un vacío en otro grupo, con su motivo.
    celda = _celdaPorCargar('loading-R:');
    await _registrar('toca', {'celda': _clave(celda)});
    await _tocar(celda);
    await _asentar();
    await _capturar('hoja-vacios-segunda-celda',
        textos: RegExp('Vacíos del listado|No hay coincidencias'));
    final deOtroGrupo = await _filaDeLaHoja(
        otroGrupo: true, largo: bahia.isEven ? '4L' : '2');
    await _capturar('hoja-vacios-otro-grupo', textos: RegExp('Otro grupo'));
    await _tocar(deOtroGrupo);
    await _asentar();
    await _capturar('asignar-vacio-en-otro-grupo',
        textos: RegExp('Asignar vacío|OR |Pide motivo|No se registra'));
    final motivo = _exigir(
        _buscarElemento((e) =>
            e is StatefulElement &&
            e.state is EditableTextState &&
            _tieneAncestro(
                e, (w) => w.key == const ValueKey('loading-reason'))),
        'el campo del motivo');
    ((motivo as StatefulElement).state as EditableTextState).updateEditingValue(
        const TextEditingValue(
            text: 'Faltan vacíos de su tipo; lo autoriza el planificador',
            selection: TextSelection.collapsed(offset: 53)));
    await _asentar();
    await _capturarEnDialogo('asignar-vacio-en-otro-grupo-con-motivo',
        'loading-confirm');
    await _tocarALaVista(() => _conClave('loading-confirm'));
    await _asentar();
    await _capturar('vacio-en-otro-grupo-asignado',
        textos: RegExp('Carga registrada|Revisar|pendientes'));
    _sinAvisos();
    await _asentar();

    // 3c. Un lleno.
    celda = _celdaPorCargar('loading-C:');
    await _registrar('toca', {'celda': 'un lleno del plan'});
    await _tocar(celda);
    await _asentar();
    await _capturar('confirmar-carga-de-un-lleno',
        textos: RegExp('Confirmar carga|Posición planificada|Revisado|POT '));
    await _tocarALaVista(() => _conClave('loading-confirm'));
    await _asentar();
    await _capturar('lleno-cargado',
        textos: RegExp('Carga registrada|pendientes'));
    _sinAvisos();
    await _asentar();
    await _capturar('carga-al-final', textos: RegExp('pendientes|por cargar'));
  }

  // --- T-147, entrega 2, parte 2a ------------------------------------------

  /// El recorrido de la parte 2a con el caso, tocando la pantalla: lo que el
  /// listado cancela, «también llena», la hoja de los vacíos, una carga en
  /// una celda de otro código de su tipo, el BAPLIE de salida con su destino
  /// final, lo guardado en el dispositivo y una revisión del listado que
  /// cancela una fila ya cargada.
  ///
  /// Parámetros: `plan`, `listado`, `listado2` (la revisión que cancela el OR
  /// de `lleno`), `elegir` (los tipos pendientes), `lleno` (el OR del lleno
  /// que se carga; por omisión, 1) y `codigo` (el código ISO de la celda
  /// donde se asigna un vacío de otro código de su tipo; por omisión, 45G0).
  Future<void> _recorrido2a() async {
    final contenedor = _contenedor();
    await _asentar();
    if (await _abrirElPlan()) await _confirmarElPlan();
    // El proveedor de la importación vive mientras su página está abierta:
    // se lee cada vez, con la página ya a la vista.
    ExportListImportNotifier importacion() =>
        contenedor.read(exportListImportProvider.notifier);
    final nombre = parametro('listado');
    LoadingOperation datos() =>
        contenedor.read(loadingOperationProvider(_viaje())).value!;

    // 1. El listado: lo que se carga y lo que la agencia cancela.
    contenedor.read(destinoDelViajeProvider.notifier).ir(DestinoDelViaje.lista);
    await _asentar();
    await _tocarALaVista(() => _conClave('open-export-list'));
    await _asentar();
    await importacion().loadBytes(await leerDelCaso(nombre), fileName: nombre);
    await _asentar();
    _sinAvisos();
    await _asentar();
    await _registrarLa2a('listado-leido');
    await _capturar('listado-resumen',
        textos: RegExp('filas en|para cargar|ancelad|CANCEL|se entendieron|'
            'no se reconoce|POT y POD'));
    await _capturarEn('equivalencias', 'Equivalencias con el plan',
        textos: RegExp('→|Propuesta|llena|códigos son iguales'));

    // 2. Los tipos que nadie respalda, y las celdas sin dueño.
    for (final par in parametro('elegir').split(',')) {
      if (par.trim().isEmpty) continue;
      final partes = RegExp(r'^(\w+):([^=]+)=(.+)$').firstMatch(par.trim())!;
      importacion().choose(EquivalenceKind.type, partes[2]!, partes[3]!);
    }
    await _asentar();
    await _registrarLa2a('listado-con-lo-elegido');
    await _capturarDonde('celdas-sin-duenio',
        (e) => e.widget.key == const ValueKey('orphan-codes'),
        textos: RegExp(r'ningún tipo|celdas?[.:]| · \d+ celda'));
    var aceptadas = 0;
    bool esSi(Element e) {
      final k = e.widget.key;
      return k is ValueKey<String> && k.value.startsWith('orphan-yes-');
    }

    while (_buscarElemento(esSi, aLaVista: false) != null) {
      final si = await _traer(esSi, 'una sugerencia');
      await _registrar('acepta', {'sugerencia': _clave(si).substring(11)});
      await _tocar(si);
      await _asentar();
      if (++aceptadas > 40) throw StateError('Las sugerencias no se acaban.');
    }
    await _registrarLa2a('listado-declarado');
    await _capturarEn('equivalencias-declaradas', 'Equivalencias con el plan',
        textos: RegExp('→|También llena|llena'));
    await _capturarEn('cruce', 'Cruce con el plan de $_escala',
        textos: RegExp('cruzan|no est|vacíos en|datos distintos|ancelad|'
            r'· \w{5} · '));
    _sinAvisos();
    await _asentar();
    await _tocar(_conClave('export-list-confirm'));
    await _asentar();
    await _capturar('listado-importado',
        textos: RegExp('Listado guardado|Guardado en la operación|para cargar'));
    _sinAvisos();
    await _volver();

    // 3. La hoja, desde una celda de 40 pies y desde una de 20.
    final bahia = int.tryParse(parametro('bahia')) ?? 18;
    await _aCarga(bahia);
    await _capturar('carga-bahia',
        textos: RegExp('pendientes|por cargar|Bahía'));
    var celda = _celdaPorCargar('loading-R:');
    await _hojaDesde(celda, 'hoja-desde-40', datos());
    await _escribirEnLaHoja(parametro('cancelado').isEmpty
        ? '156'
        : parametro('cancelado'));
    await _capturar('hoja-al-buscar-un-cancelado',
        textos: RegExp('Cancelado en el listado|No hay coincidencias|OR '));
    await _registrar('hoja-al-buscar-un-cancelado', _laHoja());
    await _volver();

    final de20 = datos()
        .loading
        .reservedSlots
        .where((s) =>
            s.portOfLoading == _escala && s.stowagePosition.bay.isOdd)
        .map((s) => s.stowagePosition.bay)
        .toSet();
    for (final impar in de20) {
      await _aCarga(impar);
      try {
        celda = _celdaPorCargar('loading-R:');
      } on StateError {
        continue;
      }
      await _hojaDesde(celda, 'hoja-desde-20', datos());
      await _volver();
      break;
    }

    // 4. Un vacío en una celda de otro código de su tipo: sin motivo.
    final codigo =
        parametro('codigo').isEmpty ? '45G0' : parametro('codigo');
    final deEseCodigo = [
      for (final item in datos().plan.loading.values)
        if (item.reservedSlot?.isoSizeType == codigo &&
            item.role == PlanRole.load)
          item
    ];
    await _registrar('celdas-de-otro-codigo',
        {'codigo': codigo, 'celdas': deEseCodigo.length});
    for (final item in deEseCodigo) {
      await _aCarga(datos().bayOf(item.plannedPosition));
      final Element e;
      try {
        e = await _celdaDe('loading-${item.key}');
      } on StateError {
        continue;
      }
      await _hojaDesde(e, 'hoja-desde-otro-codigo', datos());
      await _tocar(await _filaDeLaHoja(otroGrupo: false));
      await _asentar();
      await _capturar('asignar-en-celda-de-otro-codigo',
          textos: RegExp('Asignar vacío|OR |Revisado|Pide motivo|'
              'No se registra| · '));
      await _tocarALaVista(() => _conClave('loading-confirm'));
      await _asentar();
      await _capturar('celda-de-otro-codigo-cargada',
          textos: RegExp('Carga registrada|Cargado|Revisar|pendientes'));
      _sinAvisos();
      await _asentar();
      await _registrar('celda-de-otro-codigo-cargada', {
        'celda': item.key,
        'estado': datos().state[item.key]?.state.name,
        'en_conflicto': datos().state[item.key]?.inConflict,
        'conflictos': datos().state.conflicts.length,
      });
      break;
    }

    // 5. Un lleno y un vacío con el POD distinto del POT.
    final orden = int.tryParse(parametro('lleno')) ?? 1;
    final lleno = datos().list!.byOrder(orden)!;
    final suPieza = datos().numbered(lleno)!;
    await _aCarga(datos().bayOf(suPieza.plannedPosition));
    await _tocar(await _celdaDe('loading-${suPieza.key}'));
    await _asentar();
    await _capturar('confirmar-lleno',
        textos: RegExp('Confirmar carga|Posición planificada|Revisado|POT |'
            'Pide motivo'));
    await _tocarALaVista(() => _conClave('loading-confirm'));
    await _asentar();
    await _capturar('lleno-cargado',
        textos: RegExp('Carga registrada|pendientes'));
    _sinAvisos();
    await _asentar();

    final vacio = datos().list!.loadRows.firstWhere((x) =>
        x.isEmpty &&
        x.potDiffersFromPod &&
        datos().numbered(x) == null &&
        datos().available(x));
    for (final slot in datos().candidateSlots(vacio)) {
      await _aCarga(slot.stowagePosition.bay);
      final Element e;
      try {
        e = await _celdaDe('loading-${slot.key}');
      } on StateError {
        continue;
      }
      await _tocar(e);
      await _asentar();
      await _escribirEnLaHoja('${vacio.order}');
      await _tocar(_conClave('loading-or-${vacio.order}'));
      await _asentar();
      await _capturar('asignar-vacio-con-destino-final',
          textos: RegExp('Asignar vacío|OR |Revisado|POT '));
      await _tocarALaVista(() => _conClave('loading-confirm'));
      await _asentar();
      _sinAvisos();
      await _asentar();
      await _registrar('vacio-con-destino-final', {
        'or': vacio.order,
        'pot': vacio.listPot,
        'pod': vacio.listPod,
        'celda': slot.key,
      });
      break;
    }

    // 6. El BAPLIE de salida.
    await _salida('salida');

    // 7. La segunda importación en el mismo equipo, y lo guardado.
    contenedor.read(destinoDelViajeProvider.notifier).ir(DestinoDelViaje.lista);
    await _asentar();
    await _tocarALaVista(() => _conClave('open-export-list'));
    await _asentar();
    await importacion().loadBytes(await leerDelCaso(nombre), fileName: nombre);
    await _asentar();
    _sinAvisos();
    await _asentar();
    await _registrarLa2a('segunda-importacion');
    await _capturarEn('segunda-importacion', 'Equivalencias con el plan',
        textos: RegExp('→|revisión anterior|Guardada|Propuesta|llena'));
    bool esLaTarjeta(Element e) =>
        e.widget.key == const ValueKey('saved-equivalences');
    await _tocar(await _traer(esLaTarjeta, 'lo guardado en el dispositivo'));
    await _asentar();
    await _capturarDonde('guardadas-en-este-dispositivo', esLaTarjeta,
        textos: RegExp('guardadas en este dispositivo|→|Quitar|De puerto|'
            'no cambia'));
    // Una guardada que el plan contradice: no se usa, y se dice.
    final local = await contenedor.read(localVesselRepositoryProvider.future);
    final guardado =
        (await local.getCodeEquivalences()).getOrElse(() => CodeEquivalences.empty);
    await local.saveCodeEquivalences(guardado
        .put(EquivalenceKind.type, '40ST', '45G1')
        .put(EquivalenceKind.port, 'COTRB', 'JMKIN'));
    importacion().discard();
    await _asentar();
    await importacion().loadBytes(await leerDelCaso(nombre), fileName: nombre);
    await _asentar();
    _sinAvisos();
    await _asentar();
    await _registrarLa2a('con-algo-guardado-que-el-plan-contradice');
    await _capturarDonde(
        'guardada-que-el-plan-contradice',
        (e) =>
            e.widget.key == const ValueKey('equivalence-discarded-type-40ST'),
        textos: RegExp('no se usó|→'));
    importacion().discard();
    await _asentar();

    // 8. La revisión del listado que cancela el lleno ya cargado.
    final revision = parametro('listado2');
    if (revision.isNotEmpty) {
      await importacion().loadBytes(await leerDelCaso(revision),
          fileName: revision);
      await _asentar();
      _sinAvisos();
      await _asentar();
      await _registrarLa2a('revision-leida');
      await _capturar('revision-resumen',
          textos: RegExp('filas en|para cargar|ancelad|CANCEL'));
      await _capturarDonde('revision-lo-ya-operado',
          (e) => e.widget.key == const ValueKey('revision-impact'),
          textos: RegExp('ya cargad|no se pierden|cambia de grupo|ancelad'));
      _sinAvisos();
      await _asentar();
      await _tocar(_conClave('export-list-confirm'));
      await _asentar();
      await _capturar('revision-importada',
          textos: RegExp('Listado guardado|revisión|para cargar|ancelad'));
      _sinAvisos();
      await _volver();
      await _aCarga(datos().bayOf(suPieza.plannedPosition));
      await _celdaDe('loading-${suPieza.key}');
      await _capturar('celda-de-la-cancelada-cargada',
          textos: RegExp('Revisar|Cargado|pendientes'));
      await _registrar('tras-la-revision', {
        'estado': datos().state[suPieza.key]?.state.name,
        'en_conflicto': datos().state[suPieza.key]?.inConflict,
        'conflictos': [
          for (final c in datos().state.conflicts)
            '${c.kind.name}: ${c.message.replaceAll(lleno.containerId, '‹matrícula›')}'
        ],
      });
      contenedor
          .read(destinoDelViajeProvider.notifier)
          .ir(DestinoDelViaje.avance);
      await _asentar();
      await _capturar('avance',
          textos: RegExp('Listado:|Hechos y pendientes|TOTAL'));
      await _capturarDonde('avance-conflictos', (e) {
        final w = e.widget;
        return w is Text && (w.data ?? '').startsWith('Conflictos ·');
      }, textos: RegExp('Conflictos ·|se cargó y el listado|Motivo'));
      await _salida('salida-con-la-cancelada-a-bordo');
    }
  }

  /// Va a Carga y elige la bahía.
  Future<void> _aCarga(int bahia) async {
    final contenedor = _contenedor();
    contenedor.read(destinoDelViajeProvider.notifier).ir(DestinoDelViaje.plano);
    contenedor.read(bayPlanModeProvider.notifier).elegir(BayPlanMode.loading);
    contenedor.read(selectedBayProvider.notifier).select(bahia);
    await _asentar();
    await Future<void>.delayed(const Duration(milliseconds: 700));
    await _asentar();
  }

  /// La celda con esa clave, traída a la vista y al alcance del dedo.
  Future<Element> _celdaDe(String clave) async {
    final lejos = _buscarElemento((e) => e.widget.key == ValueKey(clave),
        aLaVista: false);
    if (lejos == null) throw StateError('No está en la bahía: $clave');
    await Scrollable.ensureVisible(lejos,
        alignment: 0.5, duration: Duration.zero);
    await _asentar();
    final e = _conClave(clave);
    if (!_alAlcance(e)) throw StateError('No queda al alcance: $clave');
    return e;
  }

  /// Toca la celda reservada [celda], captura la hoja y anota lo que ofrece.
  Future<void> _hojaDesde(
      Element celda, String pantalla, LoadingOperation data) async {
    final clave = _clave(celda);
    final slot = data.loading.reservedSlots
        .firstWhere((s) => s.key == clave.substring(8));
    final filas = data.rowsFor(slot, '');
    await _tocar(celda);
    await _asentar();
    await Future<void>.delayed(const Duration(milliseconds: 500));
    await _asentar();
    await _capturar(pantalla,
        textos: RegExp('Vacíos del listado|No hay coincidencias'));
    await _registrar(pantalla, {
      'celda': clave.substring(8),
      'grupo_de_la_celda':
          '${slot.isoSizeType} · ${slot.portOfDischarge} · ${slot.operatorCode}',
      'filas_que_ofrece': filas.length,
      'de_su_grupo': filas.where((x) => data.sameGroup(slot, x)).length,
      'canceladas_que_ofrece': filas.where((x) => x.cancelled).length,
      'largos_que_ofrece': {
        for (final x in filas) x.type.isEmpty ? '?' : x.type.substring(0, 1)
      }.toList()
        ..sort(),
      'primeras_doce': filas.take(12).map((x) => x.order).toList(),
      ..._laHoja(),
    });
  }

  /// Escribe en «OR / últimos dígitos» de la hoja.
  Future<void> _escribirEnLaHoja(String texto) async {
    final campo = _exigir(
        _buscarElemento((e) =>
            e is StatefulElement &&
            e.state is EditableTextState &&
            _tieneAncestro(e, (w) => w is BottomSheet)),
        'el campo de la hoja');
    ((campo as StatefulElement).state as EditableTextState).updateEditingValue(
        TextEditingValue(
            text: texto,
            selection: TextSelection.collapsed(offset: texto.length)));
    await _asentar();
    await Future<void>.delayed(const Duration(milliseconds: 400));
    await _asentar();
  }

  /// Abre «Generar BAPLIE de salida» desde la Lista, captura la página y lo
  /// que dice de las filas que no cargaron, y vuelve.
  Future<void> _salida(String pantalla) async {
    _contenedor()
        .read(destinoDelViajeProvider.notifier)
        .ir(DestinoDelViaje.lista);
    await _asentar();
    await _tocarALaVista(() => _conClave('departure-baplie-button'));
    await _asentar();
    await Future<void>.delayed(const Duration(milliseconds: 500));
    await _asentar();
    await _capturar(pantalla,
        textos: RegExp('a bordo en la salida|destino final|Pendientes:|'
            'por confirmar|está a bordo|decía|UN/LOCODE'));
    bool esElTitulo(Element e) {
      final w = e.widget;
      return w is Text &&
          (w.data ?? '').startsWith('Filas del listado que no cargaron');
    }

    final titulo = _buscarElemento(esElTitulo, aLaVista: false);
    if (titulo != null) {
      await Scrollable.ensureVisible(titulo,
          alignment: 0, duration: Duration.zero);
      final lista = _buscarElemento(
          (e) =>
              e.widget.key == const ValueKey('departure-not-loaded-list'),
          aLaVista: false);
      final texto = lista?.widget is SelectableText
          ? (lista!.widget as SelectableText).data ?? ''
          : '';
      final lineas = texto.split('\n');
      await _capturar('$pantalla-no-cargaron',
          textos: RegExp('Filas del listado que no cargaron'));
      await _registrar('$pantalla-no-cargaron', {
        'lineas': lineas.length,
        'canceladas_en_el_listado':
            lineas.where((l) => l.contains('cancelado en el listado')).length,
        'notas': {
          for (final l in lineas)
            if (l.contains('cancelado en el listado'))
              l.substring(l.indexOf('(«'))
        }.toList()
          ..sort(),
      });
    }
    await _volver();
  }

  /// Baja por la página de encima hasta que exista lo que [cumple], y lo
  /// deja a la vista. La página es una lista perezosa: lo que queda lejos no
  /// está construido.
  Future<Element> _traer(bool Function(Element e) cumple, String que) async {
    ScrollPosition? posicion;
    void buscarLista(Element e) {
      if (e is StatefulElement &&
          e.state is ScrollableState &&
          _visible(e) &&
          _tieneAncestro(e, (w) => w is ListView)) {
        final candidata = (e.state as ScrollableState).position;
        if (candidata.axis == Axis.vertical) posicion = candidata;
      }
      e.visitChildren(buscarLista);
    }

    WidgetsBinding.instance.rootElement?.visitChildren(buscarLista);
    var e = _buscarElemento(cumple, aLaVista: false);
    if (e == null) {
      posicion?.jumpTo(0);
      await _asentar();
      e = _buscarElemento(cumple, aLaVista: false);
    }
    while (e == null &&
        posicion != null &&
        posicion!.pixels < posicion!.maxScrollExtent) {
      posicion!.jumpTo(
          (posicion!.pixels + 300).clamp(0, posicion!.maxScrollExtent));
      await _asentar();
      e = _buscarElemento(cumple, aLaVista: false);
    }
    final hallado = _exigir(e, que);
    await Scrollable.ensureVisible(hallado,
        alignment: 0.3, duration: Duration.zero);
    await _asentar();
    return _exigir(_buscarElemento(cumple), que);
  }

  /// Trae a la vista lo que [cumple] y captura.
  Future<void> _capturarDonde(
      String pantalla, bool Function(Element e) cumple,
      {RegExp? textos}) async {
    final e = await _traer(cumple, pantalla);
    await Scrollable.ensureVisible(e, alignment: 0, duration: Duration.zero);
    await _capturar(pantalla, textos: textos);
  }

  /// Lo que la importación tiene a la vista, con las cuentas de la parte 2a.
  Future<void> _registrarLa2a(String paso) async {
    final estado = _contenedor().read(exportListImportProvider);
    final lista = estado.list;
    final cruce = estado.crossCheck;
    final impacto = estado.impact;
    await _registrar(paso, {
      'error': estado.error,
      'filas': lista?.rows.length,
      'para_cargar': lista?.loadRows.length,
      'llenos_para_cargar': lista?.loadRows.where((x) => x.isFull).length,
      'vacios_para_cargar': lista?.loadRows.where((x) => x.isEmpty).length,
      'canceladas': lista?.cancelledRows.length,
      'canceladas_por_nota': lista?.cancelNotes,
      'pendientes': [
        for (final p in estado.proposals)
          if (p.needsUser) '${p.kind.label} ${p.listCode} (${p.rows})'
      ],
      'origenes': {
        for (final p in estado.proposals)
          if (!(p.origin == EquivalenceOrigin.inferred && p.isIdentity))
            '${p.kind.wire}:${p.listCode}':
                '${p.planCode ?? '?'} (${p.origin.name})'
      },
      'tambien_llena': {
        for (final p in estado.proposals)
          if (p.also.isNotEmpty) p.listCode: p.also
      },
      'guardadas_que_no_se_usaron': {
        for (final p in estado.proposals)
          if (p.discarded != null) '${p.kind.wire}:${p.listCode}': p.discarded
      },
      'celdas_sin_duenio': {
        for (final h in estado.orphans)
          h.code: '${h.cells} · ${h.suggestedListCode ?? 'sin sugerencia'}'
      },
      'conflictos_de_un_codigo_en_dos_tipos': estado.conflicts.length,
      'en_el_dispositivo': estado.device == null
          ? null
          : {
              for (final kind in EquivalenceKind.values)
                kind.wire: estado.device!.of(kind).length
            },
      if (cruce != null)
        'cruce': {
          'llenos_que_cruzan': cruce.matches.length,
          'llenos': cruce.matches.length + cruce.fullsNotInPlan.length,
          'del_plan_fuera_del_listado': cruce.planNotInList.length,
          'vacios_en_grupos': cruce.emptiesInGroups,
          'vacios': cruce.emptiesInGroups + cruce.emptiesWithoutGroup.length,
          'grupos': cruce.groups.length,
          'grupos_que_cuadran': cruce.groups.where((g) => g.balanced).length,
          'llenos_con_datos_distintos': cruce.matchesWithDifferences.length,
          'canceladas': cruce.cancelled.length,
          'canceladas_que_el_plan_carga': cruce.cancelledInPlan.length,
          'limpio': cruce.clean,
        },
      if (impacto != null)
        'lo_ya_operado': {
          'ya_cargados_sin_fila': impacto.loadedNotListed.length,
          'vacios_que_cambian_de_grupo': impacto.emptiesRegrouped.length,
          'ya_cargados_que_quedan_cancelados':
              impacto.loadedNowCancelled.length,
        },
    });
  }

  String _clave(Element e) => (e.widget.key! as ValueKey<String>).value;

  /// La primera celda de la bahía, con la clave que empieza por [prefijo],
  /// que el dedo alcanza y sigue por cargar.
  Element _celdaPorCargar(String prefijo) {
    final data =
        _contenedor().read(loadingOperationProvider(_viaje())).value;
    Element? hallada;
    void visitar(Element e) {
      if (hallada != null) return;
      final k = e.widget.key;
      if (k is ValueKey<String> &&
          k.value.startsWith(prefijo) &&
          _visible(e) &&
          _alAlcance(e) &&
          data?.state[k.value.substring(8)]?.state == ItemState.planned) {
        hallada = e;
        return;
      }
      e.visitChildren(visitar);
    }

    WidgetsBinding.instance.rootElement?.visitChildren(visitar);
    return _exigir(hallada, 'una celda $prefijo por cargar');
  }

  /// La primera fila de la hoja que es de su grupo o de otro, sin cargar,
  /// bajando por la lista hasta hallarla.
  ///
  /// Con [largo], solo las de ese largo («2» para 20 pies; «4» o «L» para una
  /// celda de 40): la hoja también ofrece, como «otro grupo», vacíos que no
  /// caben en la celda, y esos no se registran ni con motivo.
  Future<Element> _filaDeLaHoja(
      {required bool otroGrupo, String? largo}) async {
    Element? buscar() => _buscarElemento((e) {
          final w = e.widget;
          final k = w.key;
          if (w is! ListTile ||
              k is! ValueKey<String> ||
              !k.value.startsWith('loading-or-') ||
              !_alAlcance(e)) {
            return false;
          }
          final texto =
              w.subtitle is Text ? (w.subtitle! as Text).data ?? '' : '';
          return texto.contains('Otro grupo: pide motivo') == otroGrupo &&
              (largo == null || largo.contains(texto.substring(0, 1))) &&
              !texto.contains('Ya cargado');
        });
    final lista = _exigir(
        _buscarElemento((e) =>
            e is StatefulElement &&
            e.state is ScrollableState &&
            (e.state as ScrollableState).position.axis == Axis.vertical &&
            _tieneAncestro(e, (w) => w is ListView) &&
            _tieneAncestro(e, (w) => w is BottomSheet)),
        'la lista de la hoja');
    final posicion =
        ((lista as StatefulElement).state as ScrollableState).position;
    var fila = buscar();
    while (fila == null && posicion.pixels < posicion.maxScrollExtent) {
      posicion.jumpTo(
          (posicion.pixels + 320).clamp(0, posicion.maxScrollExtent));
      await _asentar();
      fila = buscar();
    }
    final hallada = _exigir(
        fila, 'una fila ${otroGrupo ? 'de otro grupo' : 'de su grupo'}');
    await _registrar('elige', {
      'fila': _clave(hallada),
      'otro_grupo': otroGrupo,
    });
    return hallada;
  }

  /// Captura con el control [clave] del diálogo a la vista.
  Future<void> _capturarEnDialogo(String pantalla, String clave) async {
    await Scrollable.ensureVisible(_conClave(clave),
        alignment: 1, duration: Duration.zero);
    await _capturar(pantalla, textos: RegExp('Motivo|motivo|Pide motivo'));
  }

  Future<void> _registrarElListado(String paso) async {
    final estado = _contenedor().read(exportListImportProvider);
    final lista = estado.list;
    final cruce = estado.crossCheck;
    await _registrar(paso, {
      'error': estado.error,
      'filas': lista?.rows.length,
      'llenos': lista?.fulls.length,
      'vacios': lista?.empties.length,
      'secciones': lista?.agencies.length,
      'filas_sin_entender': [
        for (final problema in lista?.issues ?? const <ExportListIssue>[])
          problema.sheetRow
      ],
      'pendientes': [
        for (final p in estado.proposals)
          if (p.needsUser) '${p.kind.label} ${p.listCode} (${p.rows})'
      ],
      if (cruce != null)
        'cruce': {
          'llenos_que_cruzan': cruce.matches.length,
          'llenos': cruce.matches.length + cruce.fullsNotInPlan.length,
          'del_plan_fuera_del_listado': cruce.planNotInList.length,
          'vacios_en_grupos': cruce.emptiesInGroups,
          'vacios': cruce.emptiesInGroups + cruce.emptiesWithoutGroup.length,
          'grupos': cruce.groups.length,
          'llenos_fuera_del_plan': cruce.fullsNotInPlan.length,
          'llenos_con_datos_distintos': cruce.matchesWithDifferences.length,
          'llenos_con_vgm_distinto': cruce.weightDifferences,
        },
    });
  }

  /// La medición del hallazgo 1 de la 10.151. Tres tiempos, con un solo
  /// reloj (`Stopwatch`) y sin tocar el producto:
  ///
  /// - **toque:** de soltar el dedo sobre una celda reservada a que empiece
  ///   el cuadro siguiente al primero que trae el título «Vacíos del
  ///   listado» (ese primer cuadro ya está entregado);
  /// - **teclado:** con la hoja abierta, de cambiar `viewInsets.bottom` a
  ///   300, como al abrirse el teclado, a que empiece el cuadro siguiente;
  /// - **tecla:** de escribir un carácter en «OR / últimos dígitos» de la
  ///   hoja a que empiece el cuadro siguiente.
  ///
  /// De cada uno queda además el cuadro más largo que informa el motor
  /// (`FrameTiming`): su construcción y su rasterizado.
  Future<void> _medir() async {
    final contenedor = _contenedor();
    await _asentar();
    if (await _abrirElPlan()) await _confirmarElPlan();
    final celdaPedida = parametro('celda');
    final bahia = int.tryParse(parametro('bahia')) ??
        (celdaPedida.length == 7 ? int.parse(celdaPedida.substring(0, 3)) : 18);
    contenedor.read(destinoDelViajeProvider.notifier).ir(DestinoDelViaje.plano);
    contenedor.read(bayPlanModeProvider.notifier).elegir(BayPlanMode.loading);
    contenedor.read(selectedBayProvider.notifier).select(bahia);
    await _asentar();
    await Future<void>.delayed(const Duration(seconds: 2));
    await _asentar();

    final celda = _celdaReservada(celdaPedida);
    final clave = (celda.widget.key! as ValueKey<String>).value;
    final caja = celda.renderObject! as RenderBox;
    final centro = caja.localToGlobal(caja.size.center(Offset.zero));
    final vista =
        WidgetsBinding.instance.platformDispatcher.implicitView!.viewId;

    // El toque.
    final puntero = _puntero++;
    final toque = await _cronometrar(
        disparar: () async {
          GestureBinding.instance.handlePointerEvent(PointerDownEvent(
              pointer: puntero, position: centro, viewId: vista));
          await Future<void>.delayed(const Duration(milliseconds: 60));
        },
        soltar: () => GestureBinding.instance.handlePointerEvent(
            PointerUpEvent(pointer: puntero, position: centro, viewId: vista)),
        listo: () => _textoSiHay('Vacíos del listado') != null);
    await _registrar('toque', {'celda': clave, ...toque, ..._laHoja()});

    // El teclado.
    final teclado = await _cronometrar(
        soltar: () => _teclado.value = 300, listo: () => true);
    await _registrar('teclado', {'celda': clave, ...teclado});

    // Una tecla.
    final campo = _exigir(
        _buscarElemento((e) =>
            e is StatefulElement &&
            e.state is EditableTextState &&
            _tieneAncestro(e, (w) => w is BottomSheet)),
        'el campo de la hoja');
    final editor = (campo as StatefulElement).state as EditableTextState;
    final tecla = await _cronometrar(
        soltar: () => editor.updateEditingValue(const TextEditingValue(
            text: '1', selection: TextSelection.collapsed(offset: 1))),
        listo: () => true);
    await _registrar('tecla', {'celda': clave, ...tecla, ..._laHoja()});

    _teclado.value = 0;
    await _asentar();
    await _volver();
  }

  /// Lo que la hoja ofrece a la vista, para comparar el antes y el después:
  /// los OR de las primeras filas, en su orden, y cuáles piden motivo.
  Map<String, Object?> _laHoja() {
    final filas = <String>[];
    void visitar(Element e) {
      final w = e.widget;
      final k = w.key;
      if (w is ListTile &&
          k is ValueKey<String> &&
          k.value.startsWith('loading-or-') &&
          _visible(e)) {
        final subtitulo = w.subtitle;
        final otro = subtitulo is Text &&
            (subtitulo.data ?? '').contains('Otro grupo: pide motivo');
        filas.add('${k.value.substring(11)}${otro ? ' (otro grupo)' : ''}');
      }
      e.visitChildren(visitar);
    }

    WidgetsBinding.instance.rootElement?.visitChildren(visitar);
    return {'filas_a_la_vista': filas};
  }

  /// Corre [disparar] (lo que no se cuenta), pone el reloj en cero, corre
  /// [soltar] y espera al primer cuadro en que [listo] es cierto.
  Future<Map<String, Object?>> _cronometrar({
    Future<void> Function()? disparar,
    required void Function() soltar,
    required bool Function() listo,
  }) async {
    final cuadros = <FrameTiming>[];
    void anotar(List<FrameTiming> lote) => cuadros.addAll(lote);
    // Lo que el motor tenga pendiente de informar no es de esta medición.
    await Future<void>.delayed(const Duration(milliseconds: 1500));
    SchedulerBinding.instance.addTimingsCallback(anotar);
    await disparar?.call();
    final reloj = Stopwatch()..start();
    soltar();
    final trasSoltar = reloj.elapsedMicroseconds;
    int? construida;
    var cuadrosHastaVerla = 0;
    while (construida == null) {
      await _cuadro();
      cuadrosHastaVerla++;
      if (listo()) construida = reloj.elapsedMicroseconds;
      if (reloj.elapsed > const Duration(minutes: 3)) {
        throw StateError('La medición no terminó en tres minutos.');
      }
    }
    final siguiente = Completer<int>();
    SchedulerBinding.instance
      ..scheduleFrameCallback((_) => siguiente.complete(reloj.elapsedMicroseconds))
      ..scheduleFrame();
    final dibujada = await siguiente.future;
    await _asentar();
    final asentada = reloj.elapsedMicroseconds;
    // En release el motor informa los cuadros por lotes, cada segundo.
    await Future<void>.delayed(const Duration(milliseconds: 1500));
    SchedulerBinding.instance.removeTimingsCallback(anotar);
    double ms(int micros) => (micros / 100).round() / 10;
    final porConstruccion = [...cuadros]
      ..sort((a, b) => b.buildDuration.compareTo(a.buildDuration));
    return {
      'manejador_ms': ms(trasSoltar),
      'construida_ms': ms(construida),
      'dibujada_ms': ms(dibujada),
      'asentada_ms': ms(asentada),
      'cuadros_hasta_verla': cuadrosHastaVerla,
      'cuadros_informados': cuadros.length,
      'construccion_mas_larga_ms': porConstruccion.isEmpty
          ? null
          : ms(porConstruccion.first.buildDuration.inMicroseconds),
      'su_rasterizado_ms': porConstruccion.isEmpty
          ? null
          : ms(porConstruccion.first.rasterDuration.inMicroseconds),
      'construcciones_de_mas_de_100_ms': [
        for (final cuadro in porConstruccion)
          if (cuadro.buildDuration.inMilliseconds >= 100)
            ms(cuadro.buildDuration.inMicroseconds)
      ],
    };
  }

  /// La celda reservada pedida o, si no se pide o no está a la vista, la
  /// primera de la bahía que el dedo alcanza.
  Element _celdaReservada(String pedida) {
    final halladas = <Element>[];
    void visitar(Element e) {
      final k = e.widget.key;
      if (k is ValueKey<String> &&
          k.value.startsWith('loading-R:') &&
          _visible(e) &&
          _alAlcance(e)) {
        halladas.add(e);
      }
      e.visitChildren(visitar);
    }

    WidgetsBinding.instance.rootElement?.visitChildren(visitar);
    if (halladas.isEmpty) {
      throw StateError('No hay celdas reservadas al alcance en la bahía.');
    }
    for (final e in halladas) {
      if ((e.widget.key! as ValueKey<String>).value == 'loading-R:$pedida') {
        return e;
      }
    }
    return halladas.first;
  }

  // --- Lo que se ve -------------------------------------------------------

  Future<void> _capturar(String pantalla, {RegExp? textos}) async {
    await _asentar();
    final caja =
        _lienzo.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final imagen =
        await caja.toImage(pixelRatio: caja.size.width < 600 ? 2 : 1);
    final png = await imagen.toByteData(format: ui.ImageByteFormat.png);
    imagen.dispose();
    _paso++;
    final nombre =
        '$_prefijo${_paso.toString().padLeft(2, '0')}-$pantalla.png';
    await guardarCaptura(nombre, png!.buffer.asUint8List());
    final noCaben = <String>[];
    void visitar(RenderObject r) {
      if (r is RenderParagraph && r.didExceedMaxLines) {
        noCaben.add(r.text.toPlainText());
      }
      r.visitChildren(visitar);
    }

    visitar(caja);
    await _registrar('captura', {
      'pantalla': pantalla,
      'archivo': nombre,
      'logico': '${caja.size.width.round()}x${caja.size.height.round()}',
      if (textos != null) 'se_lee': _textos(textos),
      'textos_que_no_caben': noCaben,
      'errores_de_flutter': [..._errores],
    });
    _errores.clear();
  }

  /// Trae a la vista el texto [titulo] (el de una tarjeta) y captura. Con
  /// [empezando] en falso no vuelve al principio de la lista antes de buscar.
  Future<void> _capturarEn(String pantalla, String titulo,
      {RegExp? textos, bool empezando = true}) async {
    // La página es una lista perezosa: lo que queda lejos no está construido.
    // Se baja de a media pantalla hasta que el título exista.
    // La última del árbol es la de la página de encima.
    ScrollPosition? posicion;
    void buscarLista(Element e) {
      if (e is StatefulElement &&
          e.state is ScrollableState &&
          _visible(e) &&
          _tieneAncestro(e, (w) => w is ListView)) {
        final candidata = (e.state as ScrollableState).position;
        if (candidata.axis == Axis.vertical) posicion = candidata;
      }
      e.visitChildren(buscarLista);
    }

    WidgetsBinding.instance.rootElement?.visitChildren(buscarLista);
    if (empezando) posicion?.jumpTo(0);
    await _asentar();
    var e = _textoSiHay(titulo, aLaVista: false);
    while (e == null &&
        posicion != null &&
        posicion!.pixels < posicion!.maxScrollExtent) {
      posicion!.jumpTo(
          (posicion!.pixels + 300).clamp(0, posicion!.maxScrollExtent));
      await _asentar();
      e = _textoSiHay(titulo, aLaVista: false);
    }
    if (e != null) {
      await Scrollable.ensureVisible(e, alignment: 0, duration: Duration.zero);
    }
    await _capturar(pantalla, textos: textos);
  }

  /// Los textos que están en pantalla y casan con [patron], en su orden.
  List<String> _textos(RegExp patron) {
    final hallados = <String>[];
    void visitar(Element e) {
      final w = e.widget;
      if (w is Text && _visible(e)) {
        final texto = w.data ?? w.textSpan?.toPlainText() ?? '';
        if (patron.hasMatch(texto)) hallados.add(texto);
      }
      e.visitChildren(visitar);
    }

    WidgetsBinding.instance.rootElement?.visitChildren(visitar);
    return hallados;
  }

  // --- Interacción ----------------------------------------------------------

  ProviderContainer _contenedor() {
    final e = _buscarElemento((e) => e.widget is BayStreamApp);
    if (e == null) throw StateError('No se encontró la app');
    return ProviderScope.containerOf(e);
  }

  VesselVoyage _viaje() {
    final v =
        _contenedor().read(voyageNotifierProvider.notifier).visibleVoyage;
    if (v == null) throw StateError('No hay viaje a la vista');
    return v;
  }

  Element? _buscarElemento(bool Function(Element e) cumple,
      {bool aLaVista = true}) {
    Element? hallado;
    void visitar(Element e) {
      if (hallado != null) return;
      if (cumple(e) && (!aLaVista || _visible(e))) {
        hallado = e;
        return;
      }
      e.visitChildren(visitar);
    }

    WidgetsBinding.instance.rootElement?.visitChildren(visitar);
    return hallado;
  }

  bool _visible(Element e) {
    final r = e.renderObject;
    return r is RenderBox && r.attached && r.hasSize && !r.size.isEmpty;
  }

  /// Si un toque en el centro de [e] le llega a [e] o a algo de dentro.
  bool _alAlcance(Element e) {
    final caja = e.renderObject! as RenderBox;
    final centro = caja.localToGlobal(caja.size.center(Offset.zero));
    final vista =
        WidgetsBinding.instance.platformDispatcher.implicitView!.viewId;
    final prueba = HitTestResult();
    WidgetsBinding.instance.hitTestInView(prueba, centro, vista);
    for (final entrada in prueba.path) {
      Object? objetivo = entrada.target;
      while (objetivo is RenderObject) {
        if (objetivo == caja) return true;
        objetivo = objetivo.parent;
      }
    }
    return false;
  }

  bool _tieneAncestro(Element e, bool Function(Widget w) cumple) {
    var hallado = false;
    e.visitAncestorElements((a) {
      if (cumple(a.widget)) {
        hallado = true;
        return false;
      }
      return true;
    });
    return hallado;
  }

  Element _exigir(Element? e, String que) =>
      e ?? (throw StateError('No está a la vista: $que'));

  Element? _textoSiHay(String texto, {bool aLaVista = true}) =>
      _buscarElemento(
          (e) => e.widget is Text && (e.widget as Text).data == texto,
          aLaVista: aLaVista);

  Element _conClave(String clave) => _exigir(
      _buscarElemento((e) => e.widget.key == ValueKey(clave)),
      'el control $clave');

  Future<void> _tocarALaVista(Element Function() buscar) async {
    await Scrollable.ensureVisible(buscar(),
        alignment: 0.5, duration: Duration.zero);
    await _asentar();
    await _tocar(buscar());
  }

  /// Toca el centro de [e], después de comprobar que nada lo tapa.
  Future<void> _tocar(Element e) async {
    if (!_alAlcance(e)) {
      throw StateError('Algo tapa ${e.widget.key ?? e.widget.runtimeType}');
    }
    final caja = e.renderObject! as RenderBox;
    final centro = caja.localToGlobal(caja.size.center(Offset.zero));
    final vista =
        WidgetsBinding.instance.platformDispatcher.implicitView!.viewId;
    final puntero = _puntero++;
    GestureBinding.instance.handlePointerEvent(
        PointerDownEvent(pointer: puntero, position: centro, viewId: vista));
    await Future<void>.delayed(const Duration(milliseconds: 60));
    GestureBinding.instance.handlePointerEvent(
        PointerUpEvent(pointer: puntero, position: centro, viewId: vista));
  }

  /// Aparta los avisos (SnackBar) que floten sobre lo que se va a tocar.
  void _sinAvisos() {
    final e = _buscarElemento((e) => e.widget is ScaffoldMessenger);
    if (e == null) return;
    ((e as StatefulElement).state as ScaffoldMessengerState).clearSnackBars();
  }

  /// Cierra la ruta de encima (una página, una hoja, un diálogo).
  Future<void> _volver() async {
    final e =
        _exigir(_buscarElemento((e) => e.widget is Navigator), 'el navegador');
    await ((e as StatefulElement).state as NavigatorState).maybePop();
    await _asentar();
  }

  /// Espera a que no quede ningún cuadro pendiente, hasta 4 segundos.
  Future<bool> _asentar() async {
    final limite = Stopwatch()..start();
    do {
      await _cuadro();
    } while (SchedulerBinding.instance.hasScheduledFrame &&
        limite.elapsed < const Duration(seconds: 4));
    return !SchedulerBinding.instance.hasScheduledFrame;
  }

  Future<void> _cuadro() {
    final listo = Completer<void>();
    SchedulerBinding.instance
      ..addPostFrameCallback((_) => listo.complete())
      ..scheduleFrame();
    return listo.future;
  }

  Future<void> _registrar(String paso, Map<String, Object?> datos) async {
    final ahora = DateTime.now().toUtc().toIso8601String();
    debugPrint('T147 PASO $paso $ahora');
    await registrarLinea(jsonEncode({'paso': paso, 'ts': ahora, ...datos}));
  }
}
