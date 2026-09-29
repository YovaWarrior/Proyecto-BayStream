import 'package:baystream/features/vessel/presentation/formatters/stack_weight_formatter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('T-54 formato explícito conserva enteros, decimales y ausencia', () {
    expect(formatStackWeightLimit(null), '');
    expect(formatStackWeightLimit(75000), '75000');
    expect(formatStackWeightLimit(62500.5), '62500.5');
    expect(formatStackWeightLimit(75000.125), '75000.125');
    expect(formatStackWeightLimit(12345.6789012345), '12345.6789012345');
  });
}
