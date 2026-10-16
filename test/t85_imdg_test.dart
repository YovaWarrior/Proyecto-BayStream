import 'package:baystream/features/vessel/domain/entities/dangerous_goods.dart';
import 'package:baystream/features/vessel/domain/entities/hatch_covers.dart';
import 'package:baystream/features/vessel/domain/entities/stowage_validation_result.dart';
import 'package:baystream/features/vessel/domain/services/dangerous_goods_validator.dart';
import 'package:baystream/features/vessel/domain/services/imdg_42_24_data.dart';
import 'package:baystream/features/vessel/domain/services/segregation_rules.dart';
import 'package:flutter_test/flutter_test.dart';
import 'dangerous_goods_validator_test.dart' show dangerous, testGeometry;

void main() {
  const validator = DangerousGoodsValidator();
  StowageValidationResult run(String ha, String hb, String pa, String pb,
      {String ia = '22G1',
      String ib = '22G1',
      List<String> labels = const [],
      Map<int, HatchCoverDeclaration> covers = const {}}) {
    final a = dangerous('0001', ha, pa, iso: ia, labels: labels, id: 'a');
    final b = dangerous('0002', hb, pb, iso: ib, id: 'b');
    return validator.evaluatePair(
        a, a.dangerousGoods!.single, b, b.dangerousGoods!.single, testGeometry,
        hatchCovers: covers);
  }

  test('T85 tipo desconocido solitario conserva un aviso no evaluado', () {
    final a = dangerous('1170', '3', '0010182', iso: '22K2');
    final r = validator.validate([a], testGeometry).single;
    expect(r.status, ValidationStatus.notEvaluated);
    expect(r.description, contains('Tipo de unidad'));
    expect(r.references, contains('IMDG 42-24, 7.4.3.2'));
  });
  test('T85 datos completos y simetricos con simbolos permitidos', () {
    expect(Imdg4224Data.matrix.length, 17);
    for (var i = 0; i < 17; i++) {
      expect(Imdg4224Data.matrix[i].length, 17);
      for (var j = 0; j < 17; j++) {
        expect('1234X*'.contains(Imdg4224Data.matrix[i][j]), isTrue);
        expect(Imdg4224Data.matrix[i][j], Imdg4224Data.matrix[j][i]);
      }
    }
    expect(Imdg4224Data.vertical.expand((r) => r).length, 12);
    expect(Imdg4224Data.horizontal.expand((r) => r).length, 48);
  });
  test('T85 3 con 5.1 pegados falla y un hueco cumple', () {
    expect(run('3', '5.1', '0010182', '0010382').status,
        ValidationStatus.nonConforming);
    expect(run('3', '5.1', '0010182', '0010582').status,
        ValidationStatus.conforming);
  });
  test('T85 2.1 con 4.1 cerrados pegados cumple codigo 1', () {
    expect(run('2.1', '4.1', '0010182', '0010382').status,
        ValidationStatus.conforming);
  });
  test('T85 dos abiertas codigo 1 necesitan un hueco', () {
    expect(
        run('2.1', '4.1', '0010182', '0010382', ia: '22U1', ib: '22P1').status,
        ValidationStatus.nonConforming);
    expect(
        run('2.1', '4.1', '0010182', '0010582', ia: '22U1', ib: '22P1').status,
        ValidationStatus.conforming);
  });
  test('T85 vertical codigo 1 abierta sobre cerrada cumple, inversa no', () {
    expect(run('2.1', '4.1', '0010184', '0010182', ia: '22U1').status,
        ValidationStatus.conforming);
    expect(run('4.1', '2.1', '0010182', '0010184', ib: '22U1').status,
        ValidationStatus.conforming);
    expect(run('2.1', '4.1', '0010182', '0010184', ia: '22U1').status,
        ValidationStatus.nonConforming);
  });
  test('T85 1.4 con 6.2 cuatro huecos aproxima 24 m y tres no', () {
    final r = run('1.4', '6.2', '0010182', '0110182');
    expect(r.status, ValidationStatus.conforming);
    expect(r.description, contains('Aproximación de 24 m'));
    expect(run('1.4', '6.2', '0010182', '0090182').status,
        ValidationStatus.nonConforming);
  });
  test('T85 exigencia 4 transversal sola no cumple', () {
    expect(run('1.4', '6.2', '0010282', '0011182').status,
        ValidationStatus.nonConforming);
  });
  test('T85 mamparos desconocidos bajo cubierta no se aprueban', () {
    expect(run('3', '6.2', '0010102', '0411102').status,
        ValidationStatus.notEvaluated);
    expect(run('1.4', '6.2', '0010102', '0110102').status,
        ValidationStatus.notEvaluated);
  });
  test('T85 bajo cubierta alternativa hueco o mamparo puede cumplir por hueco',
      () {
    expect(run('3', '5.1', '0010102', '0050102').status,
        ValidationStatus.conforming);
    expect(run('3', '5.1', '0010102', '0030102').status,
        ValidationStatus.notEvaluated);
  });
  test('T85 entre zonas 1 y 2 cumplen con supuesto de tapa y cita', () {
    for (final classes in [('2.1', '4.1'), ('3', '5.1')]) {
      final r = run(classes.$1, classes.$2, '0010182', '0010102');
      expect(r.status, ValidationStatus.conforming);
      expect(r.description, contains('se considera la tapa'));
      expect(r.references, contains('IMDG 42-24, 7.4.2.2'));
    }
  });
  test('T85 entre zonas 3 y 4 no se evaluan', () {
    expect(run('3', '6.2', '0010182', '0010102').status,
        ValidationStatus.notEvaluated);
    expect(run('1.4', '6.2', '0010182', '0010102').status,
        ValidationStatus.notEvaluated);
  });
  test('T85 bodega abierta no aporta cubierta, tambien bajo huella par', () {
    final r = run('3', '5.1', '0020182', '0010102',
        ia: '42G1',
        covers: {3: HatchCoverDeclaration(kind: HatchCoverKind.openHold)});
    expect(r.status, ValidationStatus.notEvaluated);
    expect(r.description, contains('Bodega abierta'));
  });
  test('T85 toda la clase 9 y asteriscos remiten a la fuente pendiente', () {
    for (final cls in SegregationRules.classes) {
      final r = run('9', cls, '0010182', '0410182');
      expect(r.status, ValidationStatus.notEvaluated);
      expect(r.description, contains('Lista de mercancías peligrosas'));
    }
    expect(run('1.1D', '1.6N', '0010182', '0410182').description,
        contains('7.2.7.1'));
  });
  test('T85 divisiones de clase 1 con grupo usan las tres filas', () {
    for (final cls in ['1.1D', '1.2', '1.5D']) {
      expect(SegregationRules.classRow(cls), '1.1/1.2/1.5');
    }
    for (final cls in ['1.3G', '1.6N']) {
      expect(SegregationRules.classRow(cls), '1.3/1.6');
    }
    expect(SegregationRules.classRow('1.4S'), '1.4');
  });
  test('T85 secundario uno impone mayor exigencia y X conserva aviso', () {
    final r = run('3', '8', '0010182', '0010382', labels: ['5.1']);
    expect(r.status, ValidationStatus.nonConforming);
    expect(r.description, contains('Exigencia 2'));
    expect(r.description, contains('X: consultar'));
    expect(r.references, contains('IMDG 42-24, 7.2.3.3'));
  });
  test('T85 secundario de clase 1 se toma como 1.3', () {
    final r = run('3', '4.1', '0010182', '0050182', labels: ['1.1D']);
    expect(r.description, contains('Exigencia 3'));
    expect(r.status, ValidationStatus.conforming);
  });
  test('T85 dos secundarios necesitan columna 16b y no se evaluan', () {
    final r = run('3', '5.1', '0010182', '0410182', labels: ['4.1', '8']);
    expect(r.status, ValidationStatus.notEvaluated);
    expect(r.description, contains('7.2.3.4'));
  });
  test('T85 etiquetas primarias repetidas no son secundarios nuevos', () {
    expect(run('3', '5.1', '0010182', '0050182', labels: ['3', '3']).status,
        ValidationStatus.conforming);
  });
  test(
      'T85 sustancias segregables en misma unidad fallan sin depender del numero ONU',
      () {
    final a = dangerous('0001', '3', '0010182', id: 'same');
    final b = dangerous('0002', '5.1', '0010182', id: 'same');
    final r = validator.evaluatePair(
        a, a.dangerousGoods!.single, b, b.dangerousGoods!.single, testGeometry);
    expect(r.status, ValidationStatus.nonConforming);
    expect(r.references, contains('IMDG 42-24, 7.2.3.2'));
  });
  test('T85 clase regulacion incompleta tiene diagnostico aun sin pares', () {
    final a = dangerous('0001', '', '0010182');
    expect(validator.validate([a], testGeometry).single.status,
        ValidationStatus.notEvaluated);
  });
  test('T85 tipo abierto P o U no se descarta y desconocido queda pendiente',
      () {
    for (final type in ['P', 'U']) {
      expect(run('2.1', '4.1', '0010182', '0010382', ia: '22${type}1').status,
          ValidationStatus.conforming);
    }
    expect(run('2.1', '4.1', '0010182', '0010382', ia: '22K2').status,
        ValidationStatus.notEvaluated);
  });
  test('T85 vertical ALFA ve 044 sobre 043 y 045, pero no 041', () {
    expect(run('3', '5.1', '0440184', '0430182', ia: '42G1').status,
        ValidationStatus.nonConforming);
    expect(run('3', '5.1', '0440184', '0450182', ia: '42G1').status,
        ValidationStatus.nonConforming);
    final separated = run('3', '5.1', '0440184', '0410182', ia: '42G1');
    expect(separated.status, ValidationStatus.nonConforming);
    expect(separated.description, contains('sin separación suficiente'));
    expect(separated.description, isNot(contains('disposición vertical')));
  });
  test('T85 invertir los argumentos conserva el estado espacial', () {
    final a = dangerous('0001', '3', '0010182', labels: ['5.1']);
    final b = dangerous('0002', '8', '0050182');
    expect(
        validator
            .evaluatePair(a, a.dangerousGoods!.single, b,
                b.dangerousGoods!.single, testGeometry)
            .status,
        validator
            .evaluatePair(b, b.dangerousGoods!.single, a,
                a.dangerousGoods!.single, testGeometry)
            .status);
  });
  test('T85 dos DGS en la misma entidad se recorren sin cambiar el modelo', () {
    final a = dangerous('0001', '3', '0010182').copyWith(dangerousGoods: [
      DangerousGoods(hazardClass: '3'),
      DangerousGoods(hazardClass: '5.1')
    ]);
    expect(validator.validate([a], testGeometry).single.status,
        ValidationStatus.nonConforming);
  });
}
