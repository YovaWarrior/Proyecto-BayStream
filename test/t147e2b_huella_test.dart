// T-147, entrega 2, parte 2b · P6: la huella del viaje (10.160, D12).
//
// El viaje es la llave de los proveedores de la operación, y cada búsqueda
// pide su `hashCode`. Hasta la 1.0.2 recorría todos los contenedores cada
// vez. Ahora se calcula una vez por objeto, y dos viajes iguales siguen
// siendo iguales.
//
// Compila también contra `v1.0.2`: la roja es por comportamiento.
import 'dart:collection';

import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/t76_fixture.dart';

/// Una lista que cuenta cuántas veces se le pide un contenedor.
class _Contada extends ListBase<ContainerUnit> {
  final List<ContainerUnit> _piezas;
  int lecturas = 0;
  _Contada(this._piezas);

  @override
  int get length => _piezas.length;
  @override
  set length(int value) => throw UnsupportedError('solo lectura');
  @override
  ContainerUnit operator [](int index) {
    lecturas++;
    return _piezas[index];
  }

  @override
  void operator []=(int index, ContainerUnit value) =>
      throw UnsupportedError('solo lectura');
}

VesselVoyage _viaje(List<ContainerUnit> contenedores,
        {String escala = 'GTSTC'}) =>
    VesselVoyage(
        id: 'sintetico',
        vessel: const Vessel(id: 'prueba', name: 'BUQUE PRUEBA'),
        voyageNumber: 'VPRUEBA',
        portOfCall: escala,
        containers: contenedores,
        reservedSlots: [t76Slot('0030482')],
        bays: const {});

List<ContainerUnit> _piezas() => [
      t76Unit('FULL0001234', '0030282'),
      t76Unit('FULL0005678', '0030682'),
      t76Unit('FULL0009012', '0050282'),
    ];

void main() {
  test('P6 · la huella del viaje se calcula una vez', () {
    final contada = _Contada(_piezas());
    final viaje = _viaje(contada);
    final primera = viaje.hashCode;
    final leidas = contada.lecturas;
    expect(leidas, greaterThan(0),
        reason: 'la huella sale de los contenedores');
    for (var i = 0; i < 50; i++) {
      expect(viaje.hashCode, primera);
    }
    expect(contada.lecturas, leidas,
        reason: 'la 1.0.2 recorría los contenedores en cada búsqueda');
    // Como llave de un mapa, que es como lo usan los proveedores.
    final porViaje = {viaje: 'operación'};
    for (var i = 0; i < 50; i++) {
      expect(porViaje[viaje], 'operación');
    }
    expect(contada.lecturas, leidas);
  });

  test('P6 · dos viajes iguales siguen siendo iguales, y uno distinto no', () {
    final uno = _viaje(_piezas());
    final otro = _viaje(_piezas());
    expect(identical(uno, otro), isFalse);
    expect(uno, otro);
    expect(uno.hashCode, otro.hashCode);
    expect({uno: 1}[otro], 1);
    expect({uno, otro}, hasLength(1));

    // Lo que cambia nace con otra huella: la guardada no se hereda.
    final enOtraEscala = uno.copyWith(portOfCall: 'COCTG');
    expect(enOtraEscala, isNot(uno));
    expect(enOtraEscala.hashCode, isNot(uno.hashCode));
    expect(enOtraEscala, _viaje(_piezas(), escala: 'COCTG'));
    expect(enOtraEscala.hashCode, _viaje(_piezas(), escala: 'COCTG').hashCode);

    final conUnoMenos = _viaje(_piezas()..removeLast());
    expect(conUnoMenos, isNot(uno));
    expect({uno: 1}[conUnoMenos], isNull);

    // Y la copia sin cambios es igual, con la misma huella.
    expect(uno.copyWith(), uno);
    expect(uno.copyWith().hashCode, uno.hashCode);
  });
}
