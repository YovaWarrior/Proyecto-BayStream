/// T-144 · RNF-008: la forma de un código de puerto UN/LOCODE y su país.
///
/// Las guías SMDG piden UN/LOCODE para los puertos: la 2.2.1 (06/2016, p. 21)
/// admite «UN-Locode or US-Census codes» (agencia 6 o 112) y la 1.5 (05/1993,
/// p. 20) «UN-Locode of 5 characters according to UN Recommendation No. 16».
/// Ninguna de las dos exige validarlo contra la lista completa de UN/LOCODE, y
/// BayStream no la trae (unos 116 000 lugares que UNECE renueva dos veces al
/// año, sin un mecanismo para actualizarla en la app). Se valida lo que atrapa
/// los errores de escritura y los países inventados: la forma y el país.
///
/// Un código que no cumple **no se rechaza**: el lector lo conserva tal cual y
/// lo avisa (`BaplieReadNoticeKind.locode`).
library;

/// Forma de un UN/LOCODE: dos letras de país y tres de lugar. Es la misma que
/// usan el lector para el LOC+61 y las reglas de Firestore para `portOfCall`.
final RegExp formaDeUnLocode = RegExp(r'^[A-Z]{2}[A-Z0-9]{3}$');

/// Códigos alfa-2 de ISO 3166-1 oficialmente asignados.
///
/// Fuente: la tabla «Standard country or area codes for statistical use (M49)»
/// de la División de Estadística de la ONU, columna «ISO-alpha2 Code»
/// (`https://unstats.un.org/unsd/methodology/m49/overview/`, leída el
/// 11-nov-2026): 248 códigos. Se suma TW, que ISO 3166-1 asigna y la tabla
/// M49 no publica como área propia: 249 en total. ISO permite usar sus
/// códigos de país sin costo («ISO allows free-of-charge use of its country,
/// currency and language codes», `https://www.iso.org/iso-3166-country-codes.html`).
const Set<String> paisesIso3166 = {
  'AD', 'AE', 'AF', 'AG', 'AI', 'AL', 'AM', 'AO', 'AQ', 'AR', 'AS', 'AT', //
  'AU', 'AW', 'AX', 'AZ', 'BA', 'BB', 'BD', 'BE', 'BF', 'BG', 'BH', 'BI', //
  'BJ', 'BL', 'BM', 'BN', 'BO', 'BQ', 'BR', 'BS', 'BT', 'BV', 'BW', 'BY', //
  'BZ', 'CA', 'CC', 'CD', 'CF', 'CG', 'CH', 'CI', 'CK', 'CL', 'CM', 'CN', //
  'CO', 'CR', 'CU', 'CV', 'CW', 'CX', 'CY', 'CZ', 'DE', 'DJ', 'DK', 'DM', //
  'DO', 'DZ', 'EC', 'EE', 'EG', 'EH', 'ER', 'ES', 'ET', 'FI', 'FJ', 'FK', //
  'FM', 'FO', 'FR', 'GA', 'GB', 'GD', 'GE', 'GF', 'GG', 'GH', 'GI', 'GL', //
  'GM', 'GN', 'GP', 'GQ', 'GR', 'GS', 'GT', 'GU', 'GW', 'GY', 'HK', 'HM', //
  'HN', 'HR', 'HT', 'HU', 'ID', 'IE', 'IL', 'IM', 'IN', 'IO', 'IQ', 'IR', //
  'IS', 'IT', 'JE', 'JM', 'JO', 'JP', 'KE', 'KG', 'KH', 'KI', 'KM', 'KN', //
  'KP', 'KR', 'KW', 'KY', 'KZ', 'LA', 'LB', 'LC', 'LI', 'LK', 'LR', 'LS', //
  'LT', 'LU', 'LV', 'LY', 'MA', 'MC', 'MD', 'ME', 'MF', 'MG', 'MH', 'MK', //
  'ML', 'MM', 'MN', 'MO', 'MP', 'MQ', 'MR', 'MS', 'MT', 'MU', 'MV', 'MW', //
  'MX', 'MY', 'MZ', 'NA', 'NC', 'NE', 'NF', 'NG', 'NI', 'NL', 'NO', 'NP', //
  'NR', 'NU', 'NZ', 'OM', 'PA', 'PE', 'PF', 'PG', 'PH', 'PK', 'PL', 'PM', //
  'PN', 'PR', 'PS', 'PT', 'PW', 'PY', 'QA', 'RE', 'RO', 'RS', 'RU', 'RW', //
  'SA', 'SB', 'SC', 'SD', 'SE', 'SG', 'SH', 'SI', 'SJ', 'SK', 'SL', 'SM', //
  'SN', 'SO', 'SR', 'SS', 'ST', 'SV', 'SX', 'SY', 'SZ', 'TC', 'TD', 'TF', //
  'TG', 'TH', 'TJ', 'TK', 'TL', 'TM', 'TN', 'TO', 'TR', 'TT', 'TV', 'TW', //
  'TZ', 'UA', 'UG', 'UM', 'US', 'UY', 'UZ', 'VA', 'VC', 'VE', 'VG', 'VI', //
  'VN', 'VU', 'WF', 'WS', 'YE', 'YT', 'ZA', 'ZM', 'ZW',
};

/// Agencia US Census Bureau (c517.e3055 = 112): la 2.2.1 la admite y sus
/// códigos no son UN/LOCODE, así que no se validan.
const String agenciaUsCensus = '112';

/// Por qué [codigo] no es un UN/LOCODE, en una frase para el aviso; `null` si
/// lo es o si no se valida:
/// - vacío o solo asteriscos (`*****`, relleno de A04 y A06): «sin declarar»;
/// - con la agencia 112 (US Census);
/// - con el prefijo `XX`, de convenio entre las partes (la 2.2.1 define
///   `XXOPT`; A01 trae `XXVSL`): se acepta sin aviso (10.123).
String? problemaDeUnLocode(String? codigo, {String? agencia}) {
  final valor = codigo?.trim() ?? '';
  if (valor.isEmpty || RegExp(r'^\*+$').hasMatch(valor)) return null;
  if (agencia?.trim() == agenciaUsCensus) return null;
  if (!formaDeUnLocode.hasMatch(valor)) {
    return 'no tiene la forma de un UN/LOCODE (2 letras de país y 3 de lugar)';
  }
  final pais = valor.substring(0, 2);
  if (pais == 'XX') return null;
  if (!paisesIso3166.contains(pais)) {
    return 'el país $pais no existe en ISO 3166-1';
  }
  return null;
}
