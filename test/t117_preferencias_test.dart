// T-117 · Las preferencias de la oficina, por equipo (SPRINT-4.md 10.38, P2 y
// P3; DESIGN.md 14.4): el par genérico de leer y guardar en el almacén y en
// el repositorio, sin migración, y lo que la presentación hace con él.
import 'dart:io';

import 'package:baystream/core/errors/failures.dart';
import 'package:baystream/features/vessel/data/datasources/hive_vessel_data_source.dart';
import 'package:baystream/features/vessel/data/repositories/local_vessel_repository_impl.dart';
import 'package:baystream/features/vessel/domain/repositories/local_vessel_repository.dart';
import 'package:baystream/features/vessel/presentation/providers/oficina_providers.dart';
import 'package:baystream/features/vessel/presentation/providers/vessel_providers.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

T _valor<T>(Either<Failure, T> resultado) =>
    resultado.fold((falla) => throw StateError(falla.message), (dato) => dato);

/// Un almacén en memoria con las preferencias, para la presentación.
class _Equipo implements LocalVesselRepository {
  _Equipo([Map<UiPreference, String>? inicial])
      : guardadas = <UiPreference, String>{...?inicial};

  final Map<UiPreference, String> guardadas;
  bool fallaAlLeer = false;
  bool fallaAlGuardar = false;

  @override
  Future<Either<Failure, String?>> getUiPreference(UiPreference key) async =>
      fallaAlLeer
          ? const Left(CacheFailure(message: 'falla de lectura'))
          : Right(guardadas[key]);

  @override
  Future<Either<Failure, void>> setUiPreference(
      UiPreference key, String? value) async {
    if (fallaAlGuardar) {
      return const Left(CacheFailure(message: 'falla de escritura'));
    }
    if (value == null) {
      guardadas.remove(key);
    } else {
      guardadas[key] = value;
    }
    return const Right(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Un almacén de antes de T-117: no sabe de preferencias de la interfaz.
class _EquipoDeAntes implements LocalVesselRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('el almacén y el repositorio (data/)', () {
    late Directory carpeta;
    late String espacio;
    late LocalVesselRepositoryImpl repositorio;

    Future<LocalVesselRepositoryImpl> abrir() async => LocalVesselRepositoryImpl(
          await HiveVesselDataSource.open(
              directory: carpeta.path, namespace: espacio),
        );

    setUp(() async {
      carpeta = await Directory.systemTemp.createTemp('baystream_t117_');
      espacio = 't117_${DateTime.now().microsecondsSinceEpoch}';
      repositorio = await abrir();
    });

    tearDown(() async {
      await repositorio.close();
      await carpeta.delete(recursive: true);
    });

    test('sin valor guardado devuelve null: no hay migración', () async {
      for (final clave in UiPreference.values) {
        expect(_valor(await repositorio.getUiPreference(clave)), isNull,
            reason: clave.name);
      }
    });

    test('guarda y lee cada preferencia, independientes entre sí', () async {
      _valor(await repositorio.setUiPreference(
          UiPreference.bridgeHeight, 'compacto'));
      _valor(await repositorio.setUiPreference(UiPreference.sidePanel, 'oculto'));
      expect(_valor(await repositorio.getUiPreference(UiPreference.bridgeHeight)),
          'compacto');
      expect(_valor(await repositorio.getUiPreference(UiPreference.sidePanel)),
          'oculto');
      expect(
          _valor(await repositorio.getUiPreference(UiPreference.sidePanelOnHover)),
          isNull);
      // Cambiar una no toca las otras.
      _valor(await repositorio.setUiPreference(
          UiPreference.bridgeHeight, 'plegado'));
      expect(_valor(await repositorio.getUiPreference(UiPreference.sidePanel)),
          'oculto');
    });

    test('guardar null la borra', () async {
      _valor(await repositorio.setUiPreference(
          UiPreference.sidePanelOnHover, 'no'));
      _valor(await repositorio.setUiPreference(UiPreference.sidePanelOnHover, null));
      expect(
          _valor(await repositorio.getUiPreference(UiPreference.sidePanelOnHover)),
          isNull);
    });

    test('sobrevive al cerrar y abrir el almacén: es del equipo', () async {
      _valor(await repositorio.setUiPreference(
          UiPreference.bridgeHeight, 'compacto'));
      _valor(await repositorio.setUiPreference(UiPreference.sidePanel, 'oculto'));
      _valor(await repositorio.close());
      repositorio = await abrir();
      expect(_valor(await repositorio.getUiPreference(UiPreference.bridgeHeight)),
          'compacto');
      expect(_valor(await repositorio.getUiPreference(UiPreference.sidePanel)),
          'oculto');
    });

    test('van en la caja de ajustes con la clave ui.<nombre>, junto al tema',
        () async {
      final fuente = await HiveVesselDataSource.open(
          directory: carpeta.path, namespace: '${espacio}_b');
      await fuente.setUiPreference(UiPreference.sidePanelOnHover, 'no');
      expect(fuente.getUiPreference(UiPreference.sidePanelOnHover), 'no');
      await fuente.close();
      final crudo = File('${carpeta.path}${Platform.pathSeparator}'
          '${espacio}_b_settings.hive');
      expect(crudo.existsSync(), isTrue);
      expect(String.fromCharCodes(crudo.readAsBytesSync()),
          contains('ui.sidePanelOnHover'));
    });

    test('un almacén cerrado devuelve el fallo, no una excepción', () async {
      final otro = LocalVesselRepositoryImpl(await HiveVesselDataSource.open(
          directory: carpeta.path, namespace: '${espacio}_c'));
      _valor(await otro.close());
      final lectura = await otro.getUiPreference(UiPreference.bridgeHeight);
      final escritura =
          await otro.setUiPreference(UiPreference.bridgeHeight, 'plegado');
      expect(lectura.isLeft(), isTrue);
      expect(escritura.isLeft(), isTrue);
    });
  });

  group('las preferencias en la presentación', () {
    ProviderContainer contenedor(LocalVesselRepository equipo) {
      final scope = ProviderContainer(overrides: [
        localVesselRepositoryProvider.overrideWith((ref) async => equipo),
      ]);
      addTearDown(scope.dispose);
      return scope;
    }

    test('sin nada guardado: completo, panel visible y por el borde', () async {
      final scope = contenedor(_Equipo());
      final leidas = await scope.read(preferenciasDeLaOficinaProvider.future);
      expect(leidas, const PreferenciasDeLaOficina());
      expect(leidas.altura, AlturaDelPuente.completo);
      expect(leidas.panelVisible, isTrue);
      expect(leidas.panelAlPasarElMouse, isTrue);
    });

    test('lee lo guardado en el equipo', () async {
      final scope = contenedor(_Equipo({
        UiPreference.bridgeHeight: 'plegado',
        UiPreference.sidePanel: 'oculto',
        UiPreference.sidePanelOnHover: 'no',
      }));
      final leidas = await scope.read(preferenciasDeLaOficinaProvider.future);
      expect(leidas.altura, AlturaDelPuente.plegado);
      expect(leidas.panelVisible, isFalse);
      expect(leidas.panelAlPasarElMouse, isFalse);
    });

    test('un valor que no conoce, un fallo de lectura o un almacén de antes '
        'cuentan como «sin valor»', () async {
      final raro = contenedor(_Equipo({UiPreference.bridgeHeight: 'gigante'}));
      expect((await raro.read(preferenciasDeLaOficinaProvider.future)).altura,
          AlturaDelPuente.completo);
      final falla = _Equipo({UiPreference.sidePanel: 'oculto'})..fallaAlLeer = true;
      expect(
          await contenedor(falla).read(preferenciasDeLaOficinaProvider.future),
          const PreferenciasDeLaOficina());
      expect(
          await contenedor(_EquipoDeAntes())
              .read(preferenciasDeLaOficinaProvider.future),
          const PreferenciasDeLaOficina());
    });

    test('elegir se ve al momento y se guarda con su valor', () async {
      final equipo = _Equipo();
      final scope = contenedor(equipo);
      await scope.read(preferenciasDeLaOficinaProvider.future);
      final notifier = scope.read(preferenciasDeLaOficinaProvider.notifier);
      expect(await notifier.elegirAltura(AlturaDelPuente.compacto), isTrue);
      expect(await notifier.mostrarPanel(false), isTrue);
      expect(await notifier.panelAlPasarElMouse(false), isTrue);
      expect(scope.read(preferenciasDeLaOficinaProvider).value,
          const PreferenciasDeLaOficina(
              altura: AlturaDelPuente.compacto,
              panelVisible: false,
              panelAlPasarElMouse: false));
      expect(equipo.guardadas, {
        UiPreference.bridgeHeight: 'compacto',
        UiPreference.sidePanel: 'oculto',
        UiPreference.sidePanelOnHover: 'no',
      });
    });

    test('un fallo al guardar deja la elección en memoria y lo dice', () async {
      final equipo = _Equipo()..fallaAlGuardar = true;
      final scope = contenedor(equipo);
      await scope.read(preferenciasDeLaOficinaProvider.future);
      final guardado = await scope
          .read(preferenciasDeLaOficinaProvider.notifier)
          .mostrarPanel(false);
      expect(guardado, isFalse);
      expect(scope.read(preferenciasDeLaOficinaProvider).value!.panelVisible,
          isFalse);
      expect(equipo.guardadas, isEmpty);
    });

    test('plegar y desplegar vuelve a la última altura abierta', () async {
      final scope = contenedor(_Equipo({UiPreference.bridgeHeight: 'compacto'}));
      await scope.read(preferenciasDeLaOficinaProvider.future);
      final notifier = scope.read(preferenciasDeLaOficinaProvider.notifier);
      AlturaDelPuente altura() =>
          scope.read(preferenciasDeLaOficinaProvider).value!.altura;
      await notifier.alternarAltura();
      expect(altura(), AlturaDelPuente.plegado);
      await notifier.alternarAltura();
      expect(altura(), AlturaDelPuente.compacto, reason: 'la última abierta');
      await notifier.elegirAltura(AlturaDelPuente.completo);
      await notifier.alternarAltura();
      await notifier.alternarAltura();
      expect(altura(), AlturaDelPuente.completo);
    });

    test('las alturas suben y bajan de una en una, sin pasarse', () {
      expect(AlturaDelPuente.completo.menos, AlturaDelPuente.compacto);
      expect(AlturaDelPuente.compacto.menos, AlturaDelPuente.plegado);
      expect(AlturaDelPuente.plegado.menos, AlturaDelPuente.plegado);
      expect(AlturaDelPuente.plegado.mas, AlturaDelPuente.compacto);
      expect(AlturaDelPuente.compacto.mas, AlturaDelPuente.completo);
      expect(AlturaDelPuente.completo.mas, AlturaDelPuente.completo);
    });
  });
}
