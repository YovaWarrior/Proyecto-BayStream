// T-99 · Conductor del banco: recorre la interfaz real del producto en
// release, sin flutter_test, tocando como lo haría una persona.
//
// Escenarios (`--dart-define=T99_ESCENARIO=…`):
//   - `ram`: el escenario fijo de T-63 (1, «Operación normal») para medir la
//     RAM desde fuera: cargar, Plano, todas las bahías, Estadísticas,
//     buscar un ID y volver a Lista. Tras cada paso anuncia «T99 PASO <paso>»
//     (consola y logcat; en Windows también T99_PASOS) y espera T99_PAUSA_MS
//     sin tocar nada, para que el muestreador tome sus cinco lecturas.
//   - `anchos`: RNF-003 (3.3 a). Para cada tamaño de T99_ANCHOS impone ese
//     tamaño lógico a la app, recorre Lista, Plano, Estadísticas y la
//     búsqueda, y guarda una captura PNG de cada pantalla con lo que encontró:
//     textos que no caben (RenderParagraph.didExceedMaxLines), desplazables
//     horizontales con contenido oculto y errores de Flutter. Los desbordes
//     de RenderFlex solo se informan en debug; en release los ve la persona.
//   - `inicio` (Fase 3 de T-114, 10.9): capturas del inicio y del previo a
//     cada tamaño de T99_ANCHOS, en claro y en oscuro y con la letra a cada
//     escala de T99_LETRAS. Antes publica T99_ARCHIVO_PUBLICADO (un plan de
//     carga) y lo cierra, para que el inicio tenga un reciente, y deja el
//     historial de escala en T99_ESCALA_ANTERIOR, para que el archivo
//     T99_ARCHIVO abra en previo; cada previo se descarta después.
//
// Las definiciones se leen al compilar (--dart-define) y, si faltan, del
// entorno del proceso al arrancar (Windows y Android): el mismo binario sirve
// para medir a mano y para los escenarios.
//
// Reposo (10.26, O1): los escenarios capturan o miden con la interfaz quieta,
// y desde la travesía del inicio (10.24) el inicio no se queda quieto nunca.
// Por eso el conductor pide reducción de movimiento (`MediaQuery.
// disableAnimations`, lo mismo que pide el sistema) salvo que
// `T99_MOVIMIENTO=completo`, que es para quien mida la animación con una
// ventana de cuadros acotada. `_asentar` espera a que no quede ningún cuadro
// programado hasta `T99_ASENTAR_MS` (20 000 por omisión) y, si el límite
// vence, lo anota como paso `aviso` y sigue: el que lee los pasos sabe que esa
// captura o medida se tomó sin reposo.
//
// Carga (`T99_CARGA`): `asset` lee t99_inputs/<T99_ARCHIVO> de la copia de
// compilación (nunca del repositorio) y la publica como t99Publicar;
// `selector` toca «Seleccionar archivo» en el inicio y espera a que una
// persona elija el archivo, que desde el rediseño (10.9, «ver primero,
// confirmar después») ya deja el plano a la vista en previo; si la persona
// además confirma el perfil, el viaje queda publicado. El paso `cargar` anota
// si quedó en previo.
import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;

import 'package:baystream/core/app.dart';
import 'package:baystream/features/vessel/domain/entities/app_theme_preference.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/presentation/providers/theme_preference_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/vessel_providers.dart';
import 'package:baystream/features/vessel/presentation/providers/discharge_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/export_list_providers.dart';
import 'package:baystream/features/vessel/presentation/providers/oficina_providers.dart';
import 'package:baystream/features/vessel/presentation/providers/plano_providers.dart';
import 'package:baystream/features/vessel/presentation/widgets/loading_plan_controls.dart'
    show BayPlanMode;
import 'package:baystream/features/vessel/presentation/widgets/navegacion_del_viaje.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 't99_app.dart';
import 't99_plataforma.dart';

String _definicion(String nombre, String compilada, [String porOmision = '']) {
  if (compilada.isNotEmpty) return compilada;
  final entorno = variableDeEntorno(nombre);
  return entorno.isNotEmpty ? entorno : porOmision;
}

final _escenario =
    _definicion('T99_ESCENARIO', const String.fromEnvironment('T99_ESCENARIO'));
final _archivo = _definicion('T99_ARCHIVO', const String.fromEnvironment('T99_ARCHIVO'));
final _archivoPublicado = _definicion(
    'T99_ARCHIVO_PUBLICADO', const String.fromEnvironment('T99_ARCHIVO_PUBLICADO'));
final _escalaAnterior = _definicion(
    'T99_ESCALA_ANTERIOR', const String.fromEnvironment('T99_ESCALA_ANTERIOR'));
// El listado de la agencia del escenario `piloto`, como asset de la copia.
final _listado = _definicion(
    'T99_LISTADO', const String.fromEnvironment('T99_LISTADO'), 'T100_LISTADO.xlsx');
final _carga = _definicion('T99_CARGA', const String.fromEnvironment('T99_CARGA'), 'asset');
final _pasos = _definicion('T99_PASOS', const String.fromEnvironment('T99_PASOS'));
final _capturas = _definicion('T99_CAPTURAS', const String.fromEnvironment('T99_CAPTURAS'));
final _pausaMs = int.parse(
    _definicion('T99_PAUSA_MS', const String.fromEnvironment('T99_PAUSA_MS'), '12000'));
final _idBuscado = _definicion('T99_ID', const String.fromEnvironment('T99_ID'));
final _anchos = _definicion('T99_ANCHOS', const String.fromEnvironment('T99_ANCHOS'),
    '360x800,600x960,840x1200,1200x800,2560x1440,real');
final _letras = _definicion(
    'T99_LETRAS', const String.fromEnvironment('T99_LETRAS'), '1.0,1.45,2.0');
final _reducirMovimiento = _definicion('T99_MOVIMIENTO',
        const String.fromEnvironment('T99_MOVIMIENTO'), 'reducido') !=
    'completo';
final _asentarMs = int.parse(
    _definicion('T99_ASENTAR_MS', const String.fromEnvironment('T99_ASENTAR_MS'), '20000'));

// Textos y claves de la interfaz que el conductor toca. T-112 (10.94) cambió
// «Bay Plan» por «Plano»; la Fase 3 del rediseño (entrega 2) cambió las
// pestañas por los destinos de la navegación (barra inferior o riel, con el
// mismo texto) y los chips «BAHÍA nn (» por la silueta, donde cada bahía es
// un botón con la clave `silueta-bahia-N`. Si vuelven a cambiar, es aquí.
const _pestanaPlano = 'Plano';
String _claveDeBahia(int bahia) => 'silueta-bahia-$bahia';

/// El conductor, o `null` si la compilación no pide un escenario.
T99Conductor? conductorDesdeDefiniciones() =>
    _escenario.isEmpty ? null : T99Conductor(_escenario);

class T99Conductor {
  final String escenario;
  T99Conductor(this.escenario);

  final _tamano = ValueNotifier<Size?>(null);
  final _letra = ValueNotifier<double>(1.0);
  final _lienzo = GlobalKey();
  final _errores = <String>[];
  var _puntero = 9900;

  /// Envoltorio para BayStreamApp.builder: en `anchos` impone el tamaño
  /// lógico y deja un RepaintBoundary para la captura.
  Widget envoltorio(BuildContext context, Widget? child) =>
      ValueListenableBuilder<Size?>(
          valueListenable: _tamano,
          builder: (context, tamano, _) => ValueListenableBuilder<double>(
              valueListenable: _letra,
              builder: (context, letra, _) {
                final lienzo = RepaintBoundary(key: _lienzo, child: child);
                // Con reducción de movimiento, lo que anima queda quieto en su
                // estado final (BsMovimiento.reducido): el inicio con la travesía
                // se asienta y las capturas salen iguales cada vez.
                final datos = MediaQuery.of(context).copyWith(
                    size: tamano,
                    textScaler: letra == 1.0 ? null : TextScaler.linear(letra),
                    disableAnimations: _reducirMovimiento ? true : null);
                if (tamano == null) {
                  return letra == 1.0 && !_reducirMovimiento
                      ? lienzo
                      : MediaQuery(data: datos, child: lienzo);
                }
                return ColoredBox(
                    color: Theme.of(context).colorScheme.surfaceContainerLowest,
                    child: FittedBox(
                        child: SizedBox.fromSize(
                            size: tamano,
                            child: MediaQuery(data: datos, child: lienzo))));
              }));

  void iniciar() {
    final anterior = FlutterError.onError;
    FlutterError.onError = (detalles) {
      _errores.add(detalles.exceptionAsString().split('\n').first);
      anterior?.call(detalles);
    };
    SchedulerBinding.instance.addPostFrameCallback((_) => unawaited(_ejecutar()));
  }

  Future<void> _ejecutar() async {
    try {
      await _asentar();
      await _registrar('inicio', {'escenario': escenario, 'archivo': _archivo});
      await _pausa();
      switch (escenario) {
        case 'ram':
          await _escenarioRam();
        case 'anchos':
          await _escenarioAnchos();
        case 'inicio':
          await _escenarioInicio();
        case 'plano':
          await _escenarioPlano();
        case 'piloto':
          await _escenarioPiloto();
        default:
          throw StateError('Escenario desconocido: $escenario');
      }
      await _registrar('fin', {});
    } catch (error) {
      await _registrar('error', {'detalle': '$error'});
    }
  }

  // --- Escenario de RAM -------------------------------------------------

  Future<void> _escenarioRam() async {
    await _cargar();
    await _registrar('cargar', {
      'previo': _contenedorRiverpod().read(voyageNotifierProvider.notifier).isPreview,
    });
    await _pausa();

    await _tocar(_pestana(_pestanaPlano));
    await _asentar();
    await _registrar('bay_plan', {});
    await _pausa();

    final bahias = _viaje().bays.keys.toList()..sort();
    final sinChip = <int>[];
    for (final bahia in bahias) {
      final chip = await _chipALaVista(bahia);
      if (chip == null) {
        sinChip.add(bahia);
        continue;
      }
      await Scrollable.ensureVisible(chip, alignment: 0.5);
      await _asentar();
      await _tocar(_chip(bahia));
      await _asentar();
    }
    await _registrar('bahias', {'bahias': bahias.length, 'sin_chip': sinChip});
    await _pausa();

    await _tocar(_pestana('Estadísticas'));
    await _asentar();
    await _registrar('estadisticas', {});
    await _pausa();

    await _buscar();
    await _registrar('buscar', {});
    await _pausa();

    await _tocar(_conTooltip('Volver'));
    await _asentar();
    await _tocar(_pestana('Lista'));
    await _asentar();
    await _registrar('lista', {});
    await _pausa();
  }

  Future<void> _cargar() async {
    final contenedor = _contenedorRiverpod();
    if (_carga == 'selector') {
      await _tocar(_conClave('select-file'));
      final limite = DateTime.now().add(const Duration(minutes: 10));
      while (contenedor.read(voyageNotifierProvider.notifier).visibleVoyage == null) {
        if (DateTime.now().isAfter(limite)) throw StateError('Nadie eligió el archivo');
        await Future<void>.delayed(const Duration(milliseconds: 500));
      }
    } else {
      final datos = await rootBundle.load('t99_inputs/$_archivo');
      final texto = String.fromCharCodes(datos.buffer.asUint8List());
      final error = await t99Publicar(
          contenedor.read(voyageNotifierProvider.notifier), texto, _archivo);
      if (error != null) throw StateError(error);
    }
    await _asentar();
  }

  Future<void> _buscar() async {
    await _tocar(_conTooltip('Buscar contenedor'));
    await _asentar();
    final ids = _viaje().containers.map((c) => c.containerId).toList()..sort();
    final id = _idBuscado.isNotEmpty ? _idBuscado : ids[ids.length ~/ 2];
    final campo = _buscarElemento((e) => e.widget is EditableText);
    if (campo == null) throw StateError('No apareció el campo de búsqueda');
    ((campo as StatefulElement).state as EditableTextState).updateEditingValue(
        TextEditingValue(text: id, selection: TextSelection.collapsed(offset: id.length)));
    await _asentar();
  }

  // --- Escenario de anchos ----------------------------------------------

  Future<void> _escenarioAnchos() async {
    await _cargar();
    for (final especificacion in _anchos.split(',').map((s) => s.trim())) {
      final partes = especificacion.split('x');
      _tamano.value = especificacion == 'real'
          ? null
          : Size(double.parse(partes[0]), double.parse(partes[1]));
      await _asentar();
      await _tocar(_pestana('Lista'));
      await _asentar();
      await _capturar(especificacion, 'lista');
      await _tocar(_pestana(_pestanaPlano));
      await _asentar();
      await _capturar(especificacion, 'bay_plan');
      await _tocar(_pestana('Estadísticas'));
      await _asentar();
      await _capturar(especificacion, 'estadisticas');
      await _buscar();
      await _capturar(especificacion, 'busqueda');
      await _tocar(_conTooltip('Volver'));
      await _asentar();
    }
    _tamano.value = null;
  }

  // --- Escenario del inicio (Fase 3 de T-114) ---------------------------

  Future<void> _escenarioInicio() async {
    final contenedor = _contenedorRiverpod();
    final n = contenedor.read(voyageNotifierProvider.notifier);
    // Un reciente en el inicio: el plan publicado como lo haría la oficina.
    if (_archivoPublicado.isNotEmpty) {
      final datos = await rootBundle.load('t99_inputs/$_archivoPublicado');
      final error = await t99Publicar(
          n, String.fromCharCodes(datos.buffer.asUint8List()), _archivoPublicado);
      if (error != null) throw StateError(error);
      await _asentar();
      n.clearVoyage();
      await _asentar();
    }
    // El historial de escala del dispositivo: con otra escala, un plano de
    // llegada propone el puerto de salida y abre en previo (hallazgo 5).
    if (_escalaAnterior.isNotEmpty) {
      final local = await contenedor.read(localVesselRepositoryProvider.future);
      await local.setLastConfirmedPortOfCall(_escalaAnterior);
    }
    final texto = String.fromCharCodes(
        (await rootBundle.load('t99_inputs/$_archivo')).buffer.asUint8List());
    for (final tema in [AppThemePreference.light, AppThemePreference.dark]) {
      await contenedor.read(themePreferenceProvider.notifier).select(tema);
      await _asentar();
      final nombreTema = tema == AppThemePreference.light ? 'claro' : 'oscuro';
      for (final letra in _letras.split(',').map((s) => double.parse(s.trim()))) {
        _letra.value = letra;
        for (final especificacion in _anchos.split(',').map((s) => s.trim())) {
          final partes = especificacion.split('x');
          _tamano.value = especificacion == 'real'
              ? null
              : Size(double.parse(partes[0]), double.parse(partes[1]));
          await _asentar();
          final sufijo = '${especificacion}_${nombreTema}_letra$letra';
          await _capturar(sufijo, 'inicio');
          final r = await n.parseBaplieContent(texto, fileName: _archivo);
          if (!r.success) throw StateError(r.errorMessage ?? 'No abrió $_archivo');
          await _asentar();
          await _capturar(sufijo, r.preview ? 'previo' : 'publicado');
          if (n.isPreview) {
            n.discardPreview();
          } else {
            n.clearVoyage();
          }
          await _asentar();
        }
      }
    }
    _letra.value = 1.0;
    _tamano.value = null;
    await contenedor
        .read(themePreferenceProvider.notifier)
        .select(AppThemePreference.system);
    await _asentar();
  }

  // --- Escenario del plano (Fase 3, entrega 2 de T-114) --------------------

  /// Publica el plan como lo haría la oficina y captura, por tema, letra y
  /// tamaño, el plano con la bahía con más carga, la lista y el avance.
  Future<void> _escenarioPlano() async {
    final contenedor = _contenedorRiverpod();
    final n = contenedor.read(voyageNotifierProvider.notifier);
    // La última escala confirmada del dispositivo: con la misma escala del
    // plano, un plano de llegada propone esa escala y la descarga existe.
    if (_escalaAnterior.isNotEmpty) {
      final local = await contenedor.read(localVesselRepositoryProvider.future);
      await local.setLastConfirmedPortOfCall(_escalaAnterior);
    }
    final datos = await rootBundle.load('t99_inputs/$_archivo');
    final error = await t99Publicar(
        n, String.fromCharCodes(datos.buffer.asUint8List()), _archivo);
    if (error != null) throw StateError(error);
    await _asentar();
    final viaje = _viaje();
    final bahias = viaje.bays.values.toList()
      ..sort((a, b) => b.containers.length.compareTo(a.containers.length));
    final bahia = bahias.first.bayNumber;
    for (final tema in [AppThemePreference.light, AppThemePreference.dark]) {
      await contenedor.read(themePreferenceProvider.notifier).select(tema);
      await _asentar();
      final nombreTema = tema == AppThemePreference.light ? 'claro' : 'oscuro';
      for (final letra in _letras.split(',').map((s) => double.parse(s.trim()))) {
        _letra.value = letra;
        for (final especificacion in _anchos.split(',').map((s) => s.trim())) {
          final partes = especificacion.split('x');
          _tamano.value = especificacion == 'real'
              ? null
              : Size(double.parse(partes[0]), double.parse(partes[1]));
          await _asentar();
          final sufijo = '${especificacion}_${nombreTema}_letra$letra';
          contenedor.read(destinoDelViajeProvider.notifier).ir(DestinoDelViaje.plano);
          contenedor.read(selectedBayProvider.notifier).select(bahia);
          await _asentar();
          await _capturar(sufijo, 'plano');
          if (offersDischarge(viaje)) {
            contenedor.read(bayPlanModeProvider.notifier).elegir(BayPlanMode.discharge);
            await _asentar();
            await _capturar(sufijo, 'plano_descarga');
            contenedor.read(bayPlanModeProvider.notifier).elegir(BayPlanMode.content);
            await _asentar();
          }
          final tamano = _tamano.value;
          if (tamano != null && tamano.width >= 1200) {
            await _capturasDeLaOficina(contenedor, viaje, sufijo);
          }
          contenedor.read(destinoDelViajeProvider.notifier).ir(DestinoDelViaje.lista);
          await _asentar();
          await _capturar(sufijo, 'lista');
          if (viaje.portOfCall != null) {
            contenedor.read(destinoDelViajeProvider.notifier).ir(DestinoDelViaje.avance);
            await _asentar();
            await _capturar(sufijo, 'avance');
          }
        }
      }
    }
    contenedor.read(destinoDelViajeProvider.notifier).ir(DestinoDelViaje.plano);
    _letra.value = 1.0;
    _tamano.value = null;
    await contenedor
        .read(themePreferenceProvider.notifier)
        .select(AppThemePreference.system);
    await _asentar();
  }

  /// T-117 (`DESIGN.md` 14): con el panel lateral fijo (desde 1200 dp), la
  /// Carga, el panel del buque compacto y plegado, y el panel lateral oculto
  /// y flotante (por un toque en su borde). Deja la oficina como la encontró.
  Future<void> _capturasDeLaOficina(
      ProviderContainer contenedor, VesselVoyage viaje, String sufijo) async {
    final oficina = contenedor.read(preferenciasDeLaOficinaProvider.notifier);
    if (viaje.portOfCall != null) {
      contenedor.read(bayPlanModeProvider.notifier).elegir(BayPlanMode.loading);
      await _asentar();
      await _capturar(sufijo, 'plano_carga');
      contenedor.read(bayPlanModeProvider.notifier).elegir(BayPlanMode.content);
      await _asentar();
    }
    await oficina.elegirAltura(AlturaDelPuente.compacto);
    await _asentar();
    await _capturar(sufijo, 'plano_puente_compacto');
    await oficina.elegirAltura(AlturaDelPuente.plegado);
    await _asentar();
    await _capturar(sufijo, 'plano_puente_plegado');
    await oficina.elegirAltura(AlturaDelPuente.completo);
    await oficina.mostrarPanel(false);
    await _asentar();
    await _capturar(sufijo, 'plano_panel_oculto');
    await _tocar(_conClave('borde-del-panel'));
    await _asentar();
    await _capturar(sufijo, 'plano_panel_flotante');
    await _tocar(_conClave('cerrar-panel'));
    await oficina.mostrarPanel(true);
    await _asentar();
  }

  // --- Escenario del piloto (candidata del piloto, 10.28) -----------------

  /// El recorrido del piloto en un cliente de oficina (Windows), con el
  /// primer tamaño de T99_ANCHOS, la primera letra de T99_LETRAS y el tema
  /// oscuro. Prepara la operación como la oficina: el plan de carga
  /// (T99_ARCHIVO_PUBLICADO) se confirma por la interfaz (la banda del
  /// previo, «Parámetros del buque», «No lo tengo», «Confirmar y ver el
  /// plano»); el listado de la agencia (T99_LISTADO) entra por su página,
  /// sin el selector del sistema; la llegada (T99_ARCHIVO) abre publicada por
  /// la regla de `DESIGN.md` 7.2. Después recorre la descarga (Baja, otra
  /// Baja y Deshacer, Paso con su pregunta), la carga (asignar un vacío por
  /// OR, otro y Deshacer), el avance con «En vivo», las alertas, el BAPLIE de
  /// salida con la comparación y «Más». Lo que necesita cuenta (pedir cambio,
  /// la bandeja) no se recorre aquí. Cada paso es una captura numerada, con
  /// los textos que no caben y los errores de Flutter, en `pasos.jsonl`.
  Future<void> _escenarioPiloto() async {
    final contenedor = _contenedorRiverpod();
    final n = contenedor.read(voyageNotifierProvider.notifier);
    var paso = 0;
    Future<void> foto(String nombre) async {
      paso++;
      await _capturar('p${paso.toString().padLeft(2, '0')}', nombre);
    }

    Future<String> texto(String nombre) async => String.fromCharCodes(
        (await rootBundle.load('t99_inputs/$nombre')).buffer.asUint8List());
    final especificacion = _anchos.split(',').first.trim();
    final partes = especificacion.split('x');
    _tamano.value = especificacion == 'real'
        ? null
        : Size(double.parse(partes[0]), double.parse(partes[1]));
    _letra.value = double.parse(_letras.split(',').first.trim());
    await contenedor
        .read(themePreferenceProvider.notifier)
        .select(AppThemePreference.dark);
    await _asentar();
    await foto('inicio');

    // 1. El plan de carga: abre en previo y se confirma por la interfaz.
    final carga = await n.parseBaplieContent(await texto(_archivoPublicado),
        fileName: _archivoPublicado);
    if (!carga.success) {
      throw StateError(carga.errorMessage ?? 'No abrió $_archivoPublicado');
    }
    await _asentar();
    await foto('plan-de-carga-en-previo');
    await _tocar(_textoEn(
        'Confirmar', (w) => w.key == const ValueKey('preview-banner')));
    await _asentar();
    await foto('parametros-del-buque');
    await _tocarALaVista(() => _textoVisible('No lo tengo'));
    await _asentar();
    await foto('parametros-no-lo-tengo');
    await _tocarALaVista(() => _conClave('geometry-confirm'));
    await _asentar();
    if (n.isPreview) throw StateError('El plan de carga sigue en previo');
    await foto('plan-de-carga-publicado');

    // 2. El listado de la agencia, por su página.
    await _tocar(_pestana('Lista'));
    await _asentar();
    await _tocarALaVista(() => _conClave('open-export-list'));
    await _asentar();
    final listado = await rootBundle.load('t99_inputs/$_listado');
    await contenedor
        .read(exportListImportProvider.notifier)
        .loadBytes(listado.buffer.asUint8List(), fileName: _listado);
    await _asentar();
    await foto('listado-leido');
    // El aviso «cargado correctamente» de hace un momento flota sobre el
    // botón de confirmar, al pie: una persona esperaría a que se apague.
    _sinAvisos();
    await _asentar();
    await _tocarALaVista(() => _conClave('export-list-confirm'));
    await _asentar();
    await foto('listado-importado');
    await _volver();

    // 3. La llegada: con la escala confirmada abre publicada (7.2).
    final llegada =
        await n.parseBaplieContent(await texto(_archivo), fileName: _archivo);
    if (!llegada.success) {
      throw StateError(llegada.errorMessage ?? 'No abrió $_archivo');
    }
    if (n.isPreview) {
      throw StateError('La llegada abrió en previo: la escala no coincide');
    }
    contenedor.read(destinoDelViajeProvider.notifier).ir(DestinoDelViaje.plano);
    await _asentar();
    await foto('llegada-publicada');

    // 4. La descarga: Baja, otra Baja y Deshacer, Paso con su pregunta.
    await _tocar(_textoEn('Descarga', (w) => w is SegmentedButton));
    await _asentar();
    await foto('descarga');
    await _tocar(_conClavePrefijo('discharge-pending'));
    await _asentar();
    await foto('baja-registrada');
    await _tocar(_conClavePrefijo('discharge-pending'));
    await _asentar();
    await foto('segunda-baja');
    await _tocar(_textoEn('Deshacer', (w) => w is SnackBar));
    await _asentar();
    await foto('baja-deshecha');
    await _tocar(_conClavePrefijo('discharge-transit'));
    await _asentar();
    await foto('paso-pregunta');
    await _tocar(_conClave('confirm-restow'));
    await _asentar();
    await foto('reestiba-registrada');

    // 5. La carga: un vacío por OR, otro y Deshacer.
    await _tocar(_textoEn('Carga', (w) => w is SegmentedButton));
    await _asentar();
    await foto('carga');
    await _tocarALaVista(() => _conClave('empty-search'));
    await _asentar();
    await foto('vacios-del-listado');
    await _tocar(_conClavePrefijo('loading-or-'));
    await _asentar();
    await foto('asignar-vacio');
    await _tocarALaVista(() => _conClave('loading-confirm'));
    await _asentar();
    await foto('vacio-asignado');
    // El aviso de la carga flota sobre el pie de la hoja de los vacíos.
    _sinAvisos();
    await _asentar();
    await _tocarALaVista(() => _conClave('empty-search'));
    await _asentar();
    // La segunda fila de la hoja: la primera ya se cargó y abriría su detalle;
    // la última puede quedar recortada por el borde de la hoja.
    await _tocarALaVista(() => _conClavePrefijo('loading-or-', indice: 1));
    await _asentar();
    await _tocarALaVista(() => _conClave('loading-confirm'));
    await _asentar();
    await foto('segundo-vacio-asignado');
    await _tocar(_textoEn('Deshacer', (w) => w is SnackBar));
    await _asentar();
    await foto('vacio-deshecho');

    // 6. El avance y «En vivo» (el panel, desde 1200 dp).
    await _tocar(_pestana('Avance'));
    await _asentar();
    await foto('avance');
    await _tocar(_pestana('Plano'));
    await _asentar();
    await foto('plano-con-en-vivo');

    // 7. Las alertas de estiba (en el riel desde 1200 dp).
    await _tocar(_pestana('Alertas'));
    await _asentar();
    await foto('alertas-de-estiba');
    await _volver();

    // 8. El BAPLIE de salida y la comparación con la llegada.
    await _tocar(_pestana('Lista'));
    await _asentar();
    _sinAvisos();
    await _asentar();
    await _tocarALaVista(() => _conClave('departure-baplie-button'));
    await _asentar();
    await foto('baplie-de-salida');
    await _tocarALaVista(() => _conClave('departure-compare-arrival'));
    await _asentar();
    await foto('comparar-con-la-llegada');
    await _volver();
    await _volver();

    // 9. «Más».
    await _tocar(_pestana('Más'));
    await _asentar();
    await foto('mas');
    await _volver();
    contenedor.read(destinoDelViajeProvider.notifier).ir(DestinoDelViaje.plano);
    await _asentar();
    _letra.value = 1.0;
    _tamano.value = null;
    await contenedor
        .read(themePreferenceProvider.notifier)
        .select(AppThemePreference.system);
    await _asentar();
  }

  /// Un texto a la vista, tal cual.
  Element _textoVisible(String texto) => _exigir(
      _buscarElemento(
          (e) => e.widget is Text && (e.widget as Text).data == texto),
      'el texto $texto');

  /// Un texto a la vista dentro de un ancestro que cumple [ancestro].
  Element _textoEn(String texto, bool Function(Widget w) ancestro) => _exigir(
      _buscarElemento((e) =>
          e.widget is Text &&
          (e.widget as Text).data == texto &&
          _tieneAncestro(e, ancestro)),
      'el texto $texto');

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

  /// El elemento [indice] (o el último) de los que están a la vista con una
  /// clave que empieza por [prefijo]: las marcas de descarga
  /// (`discharge-pending`) y las filas del listado (`loading-or-`).
  Element _conClavePrefijo(String prefijo, {int indice = 0, bool ultimo = false}) {
    final hallados = <Element>[];
    void visitar(Element e) {
      final k = e.widget.key;
      if (k is ValueKey<String> && k.value.startsWith(prefijo) && _visible(e)) {
        hallados.add(e);
      }
      e.visitChildren(visitar);
    }

    WidgetsBinding.instance.rootElement?.visitChildren(visitar);
    if (hallados.isEmpty) throw StateError('No está a la vista: $prefijo');
    if (ultimo) return hallados.last;
    return hallados[indice < hallados.length ? indice : hallados.length - 1];
  }

  /// Trae el control a la vista si está en un desplazable y lo toca.
  Future<void> _tocarALaVista(Element Function() buscar) async {
    await Scrollable.ensureVisible(buscar(),
        alignment: 0.5, duration: Duration.zero);
    await _asentar();
    await _tocar(buscar());
  }

  /// Aparta los avisos (SnackBar) que floten sobre lo que se va a tocar.
  void _sinAvisos() {
    final e = _buscarElemento((e) => e.widget is ScaffoldMessenger);
    if (e == null) return;
    ((e as StatefulElement).state as ScaffoldMessengerState).clearSnackBars();
  }

  /// Vuelve: cierra la ruta de encima (una página, una hoja, un diálogo).
  Future<void> _volver() async {
    final e = _exigir(
        _buscarElemento((e) => e.widget is Navigator), 'el navegador');
    await ((e as StatefulElement).state as NavigatorState).maybePop();
    await _asentar();
  }

  Future<void> _capturar(String tamano, String pantalla) async {
    await _asentar();
    final caja = _lienzo.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final imagen = await caja.toImage(pixelRatio: 1);
    final png = await imagen.toByteData(format: ui.ImageByteFormat.png);
    imagen.dispose();
    final nombre = '${tamano}_$pantalla.png';
    await guardarBytes(_capturas, nombre, png!.buffer.asUint8List());
    final truncados = <String>[];
    void visitar(RenderObject r) {
      if (r is RenderParagraph && r.didExceedMaxLines) {
        truncados.add(r.text.toPlainText());
      }
      r.visitChildren(visitar);
    }

    visitar(caja);
    final horizontales = <Map<String, Object>>[];
    void visitarElementos(Element e) {
      if (e is StatefulElement && e.state is ScrollableState) {
        final s = e.state as ScrollableState;
        if (s.position.axis == Axis.horizontal && s.position.maxScrollExtent > 0.5) {
          horizontales.add({
            'oculto_px': s.position.maxScrollExtent.round(),
            'dentro_de': _pista(e),
          });
        }
      }
      e.visitChildren(visitarElementos);
    }

    _lienzo.currentContext!.visitChildElements(visitarElementos);
    await _registrar('captura', {
      'tamano': tamano,
      'pantalla': pantalla,
      'archivo': nombre,
      'logico': '${caja.size.width.round()}x${caja.size.height.round()}',
      'textos_que_no_caben': truncados,
      'desplazables_horizontales': horizontales,
      'errores_de_flutter': [..._errores],
    });
    _errores.clear();
  }

  /// Qué contiene un desplazable: la rejilla, el selector de bahías u otro.
  /// La vista más cercana nombra el tipo (las páginas de TabBarView y la
  /// barra de pestañas se desplazan por diseño); las claves del plano dicen si
  /// es la rejilla, el selector de bahías o las acciones de la barra.
  String _pista(Element e) {
    String? tipo;
    String? clave;
    var enPestanas = false;
    e.visitAncestorElements((a) {
      final w = a.widget;
      // Nombres escritos a mano: en la Web en release, runtimeType sale
      // minificado.
      tipo ??= switch (w) {
        PageView() => 'páginas de las pestañas',
        SingleChildScrollView() => 'SingleChildScrollView',
        ListView() => 'ListView',
        GridView() => 'GridView',
        CustomScrollView() => 'CustomScrollView',
        ScrollView() => 'ScrollView',
        _ => null,
      };
      if (w is TabBar) enPestanas = true;
      final k = w.key;
      if (k is ValueKey<String>) {
        if (k.value.startsWith('plan-zoom-')) clave = 'rejilla de la bahía';
        if (k.value == 'bay-selector') clave = 'selector de bahías';
        if (k.value == 'silueta-del-viaje') clave = 'silueta del buque';
        if (k.value == 'leyenda-del-plano') clave = 'leyenda del plano';
      }
      return clave == null;
    });
    if (clave != null) return clave!;
    if (enPestanas) return 'pestañas';
    return tipo == 'páginas de las pestañas' ? tipo! : 'otro (${tipo ?? 'sin vista'})';
  }

  // --- Interacción ------------------------------------------------------

  ProviderContainer _contenedorRiverpod() {
    final e = _buscarElemento((e) => e.widget is BayStreamApp);
    if (e == null) throw StateError('No se encontró la app');
    return ProviderScope.containerOf(e);
  }

  /// El viaje a la vista: publicado o, con el selector, quizá en previo.
  VesselVoyage _viaje() {
    final v = _contenedorRiverpod().read(voyageNotifierProvider.notifier).visibleVoyage;
    if (v == null) throw StateError('No hay viaje a la vista');
    return v;
  }

  Element? _buscarElemento(bool Function(Element e) cumple) {
    Element? hallado;
    void visitar(Element e) {
      if (hallado != null) return;
      if (cumple(e) && _visible(e)) {
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

  Element _exigir(Element? e, String que) => e ?? (throw StateError('No está a la vista: $que'));

  /// Un destino de la navegación (la barra inferior o el riel), por el texto
  /// de su rótulo. Antes era una pestaña.
  Element _pestana(String texto) => _exigir(
      _buscarElemento((e) =>
          e.widget is Text &&
          (e.widget as Text).data == texto &&
          _dentroDeNavegacion(e)),
      'el destino $texto');

  bool _dentroDeNavegacion(Element e) {
    var dentro = false;
    e.visitAncestorElements((a) {
      final w = a.widget;
      if (w is NavigationBar || w is NavigationRail || w is TabBar) {
        dentro = true;
        return false;
      }
      return true;
    });
    return dentro;
  }

  Element _conTooltip(String mensaje) => _exigir(
      _buscarElemento((e) => e.widget is Tooltip && (e.widget as Tooltip).message == mensaje),
      'el botón $mensaje');

  Element _conClave(String clave) => _exigir(
      _buscarElemento((e) => e.widget.key == ValueKey(clave)), 'el control $clave');

  Element? _chipSiHay(int bahia) {
    final clave = ValueKey<String>(_claveDeBahia(bahia));
    return _buscarElemento((e) => e.widget.key == clave);
  }

  Element _chip(int bahia) => _exigir(_chipSiHay(bahia), 'la bahía $bahia');

  /// La silueta se desplaza en horizontal: si el botón de la bahía no está a
  /// la vista, se recorre desde el inicio hasta hallarlo. Devuelve `null` si
  /// la bahía no tiene botón.
  Future<Element?> _chipALaVista(int bahia) async {
    var chip = _chipSiHay(bahia);
    if (chip != null) return chip;
    final selector = _buscarElemento((e) => e.widget.key == const ValueKey('bay-selector'));
    ScrollableState? lista;
    void buscar(Element e) {
      if (lista != null) return;
      if (e is StatefulElement && e.state is ScrollableState) {
        lista = e.state as ScrollableState;
        return;
      }
      e.visitChildElements(buscar);
    }

    selector?.visitChildElements(buscar);
    final posicion = lista?.position;
    if (posicion == null) return null;
    posicion.jumpTo(0);
    await _asentar();
    while ((chip = _chipSiHay(bahia)) == null && posicion.pixels < posicion.maxScrollExtent) {
      posicion.jumpTo((posicion.pixels + 150).clamp(0, posicion.maxScrollExtent));
      await _asentar();
    }
    return chip;
  }

  /// Toca el centro de [e], después de comprobar que nada lo tapa.
  Future<void> _tocar(Element e) async {
    final caja = e.renderObject! as RenderBox;
    final centro = caja.localToGlobal(caja.size.center(Offset.zero));
    final vista = WidgetsBinding.instance.platformDispatcher.implicitView!.viewId;
    final prueba = HitTestResult();
    WidgetsBinding.instance.hitTestInView(prueba, centro, vista);
    if (!prueba.path.any((entrada) => entrada.target == caja)) {
      throw StateError('Algo tapa ${e.widget.runtimeType} en $centro');
    }
    final puntero = _puntero++;
    GestureBinding.instance.handlePointerEvent(
        PointerDownEvent(pointer: puntero, position: centro, viewId: vista));
    await Future<void>.delayed(const Duration(milliseconds: 60));
    GestureBinding.instance.handlePointerEvent(
        PointerUpEvent(pointer: puntero, position: centro, viewId: vista));
  }

  /// Espera a que no quede ningún cuadro pendiente (animaciones incluidas)
  /// hasta `T99_ASENTAR_MS`. Devuelve si hubo reposo; si el límite vence,
  /// lo anota como paso `aviso` y sigue, para que quien lea los pasos sepa
  /// que lo que siguió se tomó sin reposo (10.26, O1). Con la reducción de
  /// movimiento por omisión, el inicio con la travesía se asienta.
  Future<bool> _asentar() async {
    final limite = Stopwatch()..start();
    final tope = Duration(milliseconds: _asentarMs);
    do {
      await _cuadro();
    } while (SchedulerBinding.instance.hasScheduledFrame && limite.elapsed < tope);
    if (!SchedulerBinding.instance.hasScheduledFrame) return true;
    await _registrar('aviso', {
      'asentar': 'vencido',
      'ms': limite.elapsedMilliseconds,
      'detalle': 'Siguen cuadros programados: lo que sigue se toma sin reposo. '
          'Con T99_MOVIMIENTO=completo es lo esperado en el inicio (travesía).',
    });
    return false;
  }

  Future<void> _cuadro() {
    final listo = Completer<void>();
    SchedulerBinding.instance
      ..addPostFrameCallback((_) => listo.complete())
      ..scheduleFrame();
    return listo.future;
  }

  Future<void> _pausa() => Future<void>.delayed(Duration(milliseconds: _pausaMs));

  Future<void> _registrar(String paso, Map<String, Object?> datos) async {
    final ahora = DateTime.now().toUtc().toIso8601String();
    debugPrint('T99 PASO $paso $ahora');
    await anexarLinea(_pasos, jsonEncode({'paso': paso, 'ts': ahora, ...datos}));
    if (paso == 'captura' && _capturas.isNotEmpty) {
      await anexarLinea('$_capturas/anchos.jsonl',
          jsonEncode({'paso': paso, 'ts': ahora, ...datos}));
    }
  }
}
