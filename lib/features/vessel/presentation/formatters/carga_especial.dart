import '../../../../core/design/bs_formato.dart';
import '../../domain/entities/container_unit.dart';
import '../../domain/entities/dangerous_goods.dart';

/// T-144 · Los textos de la carga especial que comparten el detalle del
/// contenedor y la Lista.

/// Una declaración DGS en una línea: «IMO 3 · UN 1993». Lo que falta se dice:
/// «IMO sin clase» o «sin número ONU».
String lineaDeDeclaracion(DangerousGoods declaracion) {
  final clase = declaracion.hazardClass?.trim();
  final onu = declaracion.unNumber?.trim();
  return [
    clase == null || clase.isEmpty ? 'IMO sin clase' : 'IMO $clase',
    onu == null || onu.isEmpty ? 'sin número ONU' : 'UN $onu',
  ].join(' · ');
}

/// Las declaraciones DGS del contenedor, en el orden del archivo. Un registro
/// guardado antes de que se conservaran todas (`dangerousGoods == null`) da
/// solo la última, con la clase y el número que guardó.
List<DangerousGoods> declaracionesDe(ContainerUnit contenedor) =>
    contenedor.dangerousGoods ??
    [
      if (contenedor.isDangerous)
        DangerousGoods(
            hazardClass: contenedor.imdgClass, unNumber: contenedor.unNumber),
    ];

/// La etiqueta corta de la Lista: «IMO 3» o, con más declaraciones, «IMO 3
/// +1» (la clase de la primera, en el orden del archivo).
String etiquetaDePeligrosa(ContainerUnit contenedor) {
  final declaraciones = declaracionesDe(contenedor);
  final primera = declaraciones.isEmpty
      ? contenedor.imdgClass
      : declaraciones.first.hazardClass;
  final base = 'IMO ${primera?.trim() ?? ''}'.trim();
  return declaraciones.length > 1
      ? '$base +${declaraciones.length - 1}'
      : base;
}

/// Lo que lee un lector de pantalla en esa etiqueta: todas las clases.
/// «Carga peligrosa: IMO 3 e IMO 8».
String etiquetaAccesibleDePeligrosa(ContainerUnit contenedor) {
  final clases = [
    for (final d in declaracionesDe(contenedor))
      d.hazardClass?.trim().isNotEmpty == true
          ? 'IMO ${d.hazardClass!.trim()}'
          : 'IMO sin clase',
  ];
  if (clases.isEmpty) return 'Carga peligrosa';
  if (clases.length == 1) return 'Carga peligrosa: ${clases.single}';
  return 'Carga peligrosa: ${clases.take(clases.length - 1).join(', ')} '
      'e ${clases.last}';
}

/// Lo que el DIM declara, en el orden frente, atrás, izquierda, derecha y
/// alto: «Frente 30 cm · Izquierda 20 cm · Alto 25 cm». Sin medidas:
/// «Medidas no declaradas».
String medidasFueraDeGalibo(ContainerUnit contenedor) {
  String cm(double valor) => valor == valor.roundToDouble()
      ? valor.toStringAsFixed(0)
      : valor.toStringAsFixed(1);
  final medidas = <String>[
    for (final (rotulo, valor) in <(String, double?)>[
      ('Frente', contenedor.overLengthFront),
      ('Atrás', contenedor.overLengthRear),
      ('Izquierda', contenedor.overWidthLeft),
      ('Derecha', contenedor.overWidthRight),
      ('Alto', contenedor.overHeight),
    ])
      if (valor != null && valor > 0) '$rotulo ${cm(valor)}${espacioDuro}cm',
  ];
  return medidas.isEmpty ? 'Medidas no declaradas' : medidas.join(' · ');
}
