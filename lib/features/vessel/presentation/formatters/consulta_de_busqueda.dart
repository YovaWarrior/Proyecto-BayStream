import 'package:flutter/foundation.dart' show immutable;

import '../../../../core/design/bs_formato.dart';
import '../../domain/entities/container_unit.dart';
import '../../domain/services/container_number.dart';
import 'carga_especial.dart';

/// T-120 · Las tres cargas especiales que la Lista filtra y el buscador
/// entiende (RF-018; `DESIGN.md` 18), con los nombres del plano y de
/// Estadísticas (15.5). En este orden van en la fila de la Lista.
enum CargaEspecial {
  /// `isDangerous`: el contenedor trae al menos un `DGS`.
  peligrosa('Peligrosa IMDG', 'peligroso', 'peligrosos'),

  /// `isReefer`: el tipo ISO es de refrigerado o el archivo trae `TMP`.
  refrigerado('Refrigerado', 'refrigerado', 'refrigerados'),

  /// `isOverDimension`: un `DIM` 5 a 9 mayor que cero o ilegible (T-144).
  fueraDeMedida('Fuera de medida', 'fuera de medida', 'fuera de medida');

  const CargaEspecial(this.rotulo, this.singular, this.plural);

  /// Cómo se llama en la Lista, en Estadísticas y en el resultado.
  final String rotulo;

  /// Cómo concuerda con «contenedor» en la línea de lo que se entendió
  /// («1 refrigerado», «12 refrigerados»).
  final String singular;
  final String plural;

  /// Si [contenedor] es de esta carga.
  bool en(ContainerUnit contenedor) => switch (this) {
        CargaEspecial.peligrosa => contenedor.isDangerous,
        CargaEspecial.refrigerado => contenedor.isReefer,
        CargaEspecial.fueraDeMedida => contenedor.isOverDimension,
      };

  /// El término que escribe la sugerencia del buscador: los de la
  /// especificación (RF-018).
  String get termino => switch (this) {
        CargaEspecial.peligrosa => 'imo',
        CargaEspecial.refrigerado => 'reefer',
        CargaEspecial.fueraDeMedida => 'oog',
      };
}

/// T-120 · RF-018 · Lo que el buscador entiende de una consulta: las cargas
/// especiales que nombra, la clase IMO, el número ONU y **el resto**, que se
/// busca como siempre (la matrícula sin espacios, los dos puertos y la
/// naviera).
///
/// - Los términos se reconocen como **palabras enteras**, sin mayúsculas ni
///   tildes: «reefer», «imo», «oog» y sus equivalentes en español (la tabla
///   de `DESIGN.md` 18.6).
/// - «imo 3», «imdg 3», «imo3» o «clase 3» piden las peligrosas con alguna
///   declaración de esa clase («imo 2» también da 2.1, 2.2 y 2.3); «un 1993»
///   u «onu 1993», las que declaran ese número.
/// - **Varias cargas son «cualquiera de ellas»**, y el resto se cumple además
///   (D7 de la 10.148).
/// - Sin ningún término, [coincide] es la búsqueda de siempre.
@immutable
class ConsultaDeBusqueda {
  const ConsultaDeBusqueda._({
    required this.cargas,
    required this.claseImo,
    required this.numeroOnu,
    required this.resto,
  });

  /// Las cargas especiales que nombra la consulta.
  final Set<CargaEspecial> cargas;

  /// La clase IMO pedida («3», «2.1»), si la hay. Implica [CargaEspecial.peligrosa].
  final String? claseImo;

  /// El número ONU pedido («1993»), si lo hay. Implica [CargaEspecial.peligrosa].
  final String? numeroOnu;

  /// Lo que no es un término, como se escribió (sin los espacios de las
  /// orillas). Vacío si la consulta solo nombra cargas.
  final String resto;

  /// Si la consulta nombra alguna carga especial.
  bool get conCargas => cargas.isNotEmpty;

  static const Set<String> _refrigerado = <String>{
    'reefer',
    'reefers',
    'refrigerado',
    'refrigerados',
    'refrigerada',
    'refrigeradas',
  };
  static const Set<String> _peligrosa = <String>{
    'imo',
    'imdg',
    'peligrosa',
    'peligrosas',
    'peligroso',
    'peligrosos',
  };
  static const Set<String> _fueraDeMedida = <String>{
    'oog',
    'sobredimensionado',
    'sobredimensionados',
    'sobredimensionada',
    'sobredimensionadas',
  };
  static final RegExp _clase = RegExp(r'^\d(\.\d)?$');
  static final RegExp _claseJunta = RegExp(r'^(imo|imdg)(\d(\.\d)?)$');
  static final RegExp _onu = RegExp(r'^\d{4}$');

  /// Sin mayúsculas ni tildes, para comparar términos.
  static String _normal(String palabra) {
    const conTilde = 'áéíóúüÁÉÍÓÚÜ';
    const sinTilde = 'aeiouuaeiouu';
    final salida = StringBuffer();
    for (final letra in palabra.split('')) {
      final i = conTilde.indexOf(letra);
      salida.write(i < 0 ? letra : sinTilde[i]);
    }
    return salida.toString().toLowerCase();
  }

  /// Parte [consulta] en sus términos y su resto.
  factory ConsultaDeBusqueda.interpretar(String consulta) {
    final palabras = consulta
        .split(RegExp(r'\s+'))
        .where((String p) => p.isNotEmpty)
        .toList();
    final normales = palabras.map(_normal).toList();
    final cargas = <CargaEspecial>{};
    String? clase;
    String? onu;
    final resto = <String>[];
    var i = 0;
    while (i < palabras.length) {
      final p = normales[i];
      final siguiente = i + 1 < normales.length ? normales[i + 1] : null;
      if (p == 'fuera' &&
          siguiente == 'de' &&
          i + 2 < normales.length &&
          normales[i + 2] == 'medida') {
        cargas.add(CargaEspecial.fueraDeMedida);
        i += 3;
        continue;
      }
      if (_refrigerado.contains(p)) {
        cargas.add(CargaEspecial.refrigerado);
      } else if (_fueraDeMedida.contains(p)) {
        cargas.add(CargaEspecial.fueraDeMedida);
      } else if ((p == 'imo' || p == 'imdg' || p == 'clase') &&
          siguiente != null &&
          _clase.hasMatch(siguiente)) {
        cargas.add(CargaEspecial.peligrosa);
        clase = siguiente;
        i += 2;
        continue;
      } else if (_claseJunta.firstMatch(p) case final m?) {
        cargas.add(CargaEspecial.peligrosa);
        clase = m.group(2);
      } else if ((p == 'un' || p == 'onu') &&
          siguiente != null &&
          _onu.hasMatch(siguiente)) {
        cargas.add(CargaEspecial.peligrosa);
        onu = siguiente;
        i += 2;
        continue;
      } else if (_peligrosa.contains(p)) {
        cargas.add(CargaEspecial.peligrosa);
      } else {
        resto.add(palabras[i]);
      }
      i++;
    }
    return ConsultaDeBusqueda._(
      cargas: cargas,
      claseImo: clase,
      numeroOnu: onu,
      resto: resto.join(' '),
    );
  }

  /// Si [contenedor] sale con esta consulta.
  bool coincide(ContainerUnit contenedor) {
    if (conCargas && !cargas.any((c) => _deLaCarga(c, contenedor))) {
      return false;
    }
    if (resto.trim().isEmpty) return conCargas;
    return coincideConElTexto(contenedor, resto);
  }

  bool _deLaCarga(CargaEspecial carga, ContainerUnit contenedor) {
    if (!carga.en(contenedor)) return false;
    if (carga != CargaEspecial.peligrosa) return true;
    final declaraciones = declaracionesDe(contenedor);
    if (claseImo case final clase?) {
      final ok = declaraciones.any((d) {
        final suya = d.hazardClass?.trim() ?? '';
        return suya == clase || suya.startsWith('$clase.');
      });
      if (!ok) return false;
    }
    if (numeroOnu case final numero?) {
      if (!declaraciones.any((d) => d.unNumber?.trim() == numero)) {
        return false;
      }
    }
    return true;
  }

  /// La búsqueda de siempre (T-144 y T-146): la matrícula sin espacios, o el
  /// puerto de descarga, el de carga o la naviera que contienen [texto].
  static bool coincideConElTexto(ContainerUnit contenedor, String texto) {
    final normal = texto.toUpperCase().trim();
    final numero = numeroDeContenedor(texto);
    final porId = numero.isNotEmpty &&
        contenedor.containerId.toUpperCase().contains(numero);
    final porDescarga =
        contenedor.portOfDischarge?.toUpperCase().contains(normal) ?? false;
    final porCarga =
        contenedor.portOfLoading?.toUpperCase().contains(normal) ?? false;
    final porNaviera =
        contenedor.operatorCode?.toUpperCase().contains(normal) ?? false;
    return porId || porDescarga || porCarga || porNaviera;
  }

  /// La línea de arriba de los resultados, con lo que se entendió: «12
  /// refrigerados», «17 refrigerados o peligrosos», «3 peligrosos de clase
  /// 3», «5 refrigerados que coinciden con «GTSTC»». Sin cargas, `null`.
  String? resumen(int cuantos) {
    if (!conCargas) return null;
    final uno = cuantos == 1;
    final nombres = <String>[
      for (final c in CargaEspecial.values)
        if (cargas.contains(c)) uno ? c.singular : c.plural,
    ];
    final cargasDichas = nombres.length == 1
        ? nombres.single
        : '${nombres.take(nombres.length - 1).join(', ')} o ${nombres.last}';
    final detalles = <String>[
      if (claseImo != null) 'de clase $claseImo',
      if (numeroOnu != null) 'con UN$espacioDuro$numeroOnu',
    ];
    final texto = resto.trim();
    return <String>[
      '$cuantos $cargasDichas',
      ...detalles,
      if (texto.isNotEmpty) uno
          ? 'que coincide con «$texto»'
          : 'que coinciden con «$texto»',
    ].join(' ');
  }

  /// Por qué [contenedor] salió, una línea por cada carga pedida que tiene:
  /// «Refrigerado, −18 °C», «Peligrosa IMDG, IMO 3, UN 1993», «Fuera de
  /// medida: Frente 30 cm, Alto 25 cm» (regla 6: con comas).
  List<String> motivos(ContainerUnit contenedor) => <String>[
        for (final c in CargaEspecial.values)
          if (cargas.contains(c) && c.en(contenedor)) motivo(c, contenedor),
      ];

  /// La señal de [carga] en [contenedor], con lo que el archivo dice.
  static String motivo(CargaEspecial carga, ContainerUnit contenedor) =>
      switch (carga) {
        CargaEspecial.refrigerado =>
          'Refrigerado, ${temperaturaDe(contenedor)}',
        CargaEspecial.peligrosa => 'Peligrosa IMDG, ${_declaraciones(contenedor)}',
        CargaEspecial.fueraDeMedida =>
          'Fuera de medida: ${medidasFueraDeGalibo(contenedor).replaceAll(' · ', ', ')}',
      };

  static String _declaraciones(ContainerUnit contenedor) {
    final declaraciones = declaracionesDe(contenedor);
    if (declaraciones.length > 1) return etiquetaDePeligrosa(contenedor);
    if (declaraciones.isEmpty) return 'IMO sin clase';
    return lineaDeDeclaracion(declaraciones.single).replaceAll(' · ', ', ');
  }
}

/// La temperatura de un refrigerado como se lee en pantalla: «−18 °C»,
/// «4.5 °C»; sin `TMP`, «el archivo no trae temperatura» (un refrigerado
/// vacío o apagado: el tipo ISO lo marca).
String temperaturaDe(ContainerUnit contenedor) {
  final valor = contenedor.temperature;
  if (valor == null) return 'el archivo no trae temperatura';
  final redondo = valor == valor.roundToDouble();
  final cifra = (redondo ? valor.abs().toStringAsFixed(0) : valor.abs().toStringAsFixed(1));
  final signo = valor < 0 ? menos : '';
  return '$signo$cifra$espacioDuro°${contenedor.temperatureUnit ?? 'C'}';
}
