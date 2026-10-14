/// Concordancia de los contadores visibles de la operación.
String operationCount(int count, String singular, String plural) =>
    '$count ${count == 1 ? singular : plural}';

String pendingZones(int deck, int hold) =>
    '(${operationCount(deck, 'pendiente', 'pendientes')} en cubierta / '
    '${operationCount(hold, 'pendiente', 'pendientes')} en bodega)';

String rejectionText(String message) =>
    message.replaceFirst(RegExp(r'\.{2,}\s*$'), '.');
