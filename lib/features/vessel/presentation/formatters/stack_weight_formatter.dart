/// Texto editable del límite, sin separadores ni redondeo de decimales.
/// La rama entera es explícita: Dart VM agrega `.0` y JavaScript no.
String formatStackWeightLimit(double? value) {
  if (value == null) return '';
  return value == value.truncateToDouble()
      ? value.toStringAsFixed(0)
      : value.toString();
}
