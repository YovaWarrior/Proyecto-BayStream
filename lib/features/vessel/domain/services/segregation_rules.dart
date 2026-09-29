/// Subconjunto documentado en docs/T41-SEGREGACION-FUENTE.md.
/// Fuente: 49 CFR Parte 176 y §172.101; NO es el Código IMDG ni su equivalente.
/// Apoyo a la decisión, no verificación de cumplimiento.
enum SegregationCode { substance, away, separated, compatibility }

class UnSegregationProfile {
  final String primary;
  final List<String> subsidiary;
  final String? compatibilityGroup;
  final bool asClassNine;
  final List<int> groupCodes;
  const UnSegregationProfile(this.primary,
      {this.subsidiary = const [],
      this.compatibilityGroup,
      this.asClassNine = false,
      this.groupCodes = const []});
}

class SegregationRules {
  SegregationRules._();
  static const disclaimer =
      'Apoyo a la decisión, no verificación de cumplimiento. '
      'Fuente: 49 CFR Parte 176. No es el Código IMDG ni se afirma equivalencia. '
      'Para la operación real, revisar el Código IMDG aplicable y consultar al responsable.';

  static const unProfiles = <String, UnSegregationProfile>{
    '0012': UnSegregationProfile('1.4',
        compatibilityGroup: 'S'), // §172.101 UN0012; §176.144(a),(e).
    '0303': UnSegregationProfile('1.4',
        compatibilityGroup: 'G'), // §172.101 UN0303; §176.144(a),(e).
    '1950': UnSegregationProfile('2.1',
        asClassNine:
            true), // §172.101 UN1950; §176.84 códigos 87/126; §176.83(a)(10).
    '1170': UnSegregationProfile('3'), // §172.101 UN1170; §176.83(b).
    '1263': UnSegregationProfile('3'), // §172.101 UN1263; §176.83(b).
    '1266': UnSegregationProfile('3'), // §172.101 UN1266; §176.83(b).
    '1993': UnSegregationProfile('3'), // §172.101 UN1993; §176.83(b).
    '3065': UnSegregationProfile('3'), // §172.101 UN3065; §176.83(b).
    '3175': UnSegregationProfile('4.1'), // §172.101 UN3175; §176.83(b).
    '3085': UnSegregationProfile('5.1', subsidiary: [
      '8'
    ], groupCodes: [
      56,
      58,
      138
    ]), // §172.101 UN3085; §176.83(a)(6),(m); §176.84.
    '1719': UnSegregationProfile('8',
        groupCodes: [52]), // §172.101 UN1719; §176.84 código 52; §176.83(m).
    '2735': UnSegregationProfile('8',
        groupCodes: [52]), // §172.101 UN2735; §176.84 código 52; §176.83(m).
    '2794': UnSegregationProfile('8', groupCodes: [
      53,
      58
    ]), // §172.101 UN2794; §176.84 códigos 53/58; §176.83(m).
    '3084': UnSegregationProfile('8',
        subsidiary: ['5.1']), // §172.101 UN3084; §176.83(a)(6).
    '3265': UnSegregationProfile('8', groupCodes: [
      53,
      58
    ]), // §172.101 UN3265; §176.84 códigos 53/58; §176.83(m).
    '3077': UnSegregationProfile('9'), // §172.101 UN3077; §176.83(b).
    '3082': UnSegregationProfile('9'), // §172.101 UN3082; §176.83(b).
  };
  static const classes = ['1.4', '2.1', '3', '4.1', '5.1', '8', '9'];
  // Cada par está citado. X no significa conforme: obliga a resolver la sustancia.
  static const _pairs = <String, SegregationCode>{
    '1.4/1.4': SegregationCode.compatibility, // §176.144(a),(e).
    '1.4/2.1': SegregationCode.separated, // §176.83(b).
    '1.4/3': SegregationCode.separated, // §176.83(b).
    '1.4/4.1': SegregationCode.separated, // §176.83(b).
    '1.4/5.1': SegregationCode.separated, // §176.83(b).
    '1.4/8': SegregationCode.separated, // §176.83(b).
    '1.4/9': SegregationCode.substance, // §176.83(b) → §172.101.
    '2.1/2.1': SegregationCode.substance, // §176.83(b) → §172.101.
    '2.1/3': SegregationCode.separated, // §176.83(b).
    '2.1/4.1': SegregationCode.away, // §176.83(b).
    '2.1/5.1': SegregationCode.separated, // §176.83(b).
    '2.1/8': SegregationCode.away, // §176.83(b).
    '2.1/9': SegregationCode.substance, // §176.83(b) → §172.101.
    '3/3': SegregationCode.substance, // §176.83(b) → §172.101.
    '3/4.1': SegregationCode.substance, // §176.83(b) → §172.101.
    '3/5.1': SegregationCode.separated, // §176.83(b).
    '3/8': SegregationCode.substance, // §176.83(b) → §172.101.
    '3/9': SegregationCode.substance, // §176.83(b) → §172.101.
    '4.1/4.1': SegregationCode.substance, // §176.83(b) → §172.101.
    '4.1/5.1': SegregationCode.away, // §176.83(b).
    '4.1/8': SegregationCode.away, // §176.83(b).
    '4.1/9': SegregationCode.substance, // §176.83(b) → §172.101.
    '5.1/5.1': SegregationCode.substance, // §176.83(b) → §172.101.
    '5.1/8': SegregationCode.separated, // §176.83(b).
    '5.1/9': SegregationCode.substance, // §176.83(b) → §172.101.
    '8/8': SegregationCode.substance, // §176.83(b) → §172.101; grupos en (m).
    '8/9': SegregationCode.substance, // §176.83(b) → §172.101.
    '9/9': SegregationCode.substance, // §176.83(b) → §172.101.
  };

  static SegregationCode? code(String a, String b) {
    final pair = [a, b]..sort();
    return _pairs[pair.join('/')];
  }
}
