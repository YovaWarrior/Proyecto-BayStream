/// T-130 (10.90, ajuste 2) · Una fecha corta en español, en la hora local del
/// equipo: «1-nov, 14:05». Dice cuándo se publicó una operación en el diálogo
/// de la oficina, en la banda del previo y en la negativa de «Publicar
/// operación», para que una operación vieja que nadie cerró no se confunda
/// con la de hoy.
String fechaCorta(DateTime instante) {
  const meses = [
    'ene', 'feb', 'mar', 'abr', 'may', 'jun',
    'jul', 'ago', 'sep', 'oct', 'nov', 'dic',
  ];
  final local = instante.toLocal();
  String dos(int valor) => valor.toString().padLeft(2, '0');
  return '${local.day}-${meses[local.month - 1]}, '
      '${dos(local.hour)}:${dos(local.minute)}';
}
