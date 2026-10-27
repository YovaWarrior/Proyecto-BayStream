/// T-122 · La bahía de referencia de un grupo de 40 pies (SPRINT-4.md 10.52
/// y 10.56).
///
/// Regla de Carlos, escrita una sola vez: **la par es la bahía de
/// referencia.** La 22 es la bahía de 40 pies, y la 21 y la 23 son sus dos
/// mitades de 20 (igual 01, 02 y 03, o 17, 18 y 19). Una impar se cuenta con
/// la par vecina que la cubre, y el grupo se rotula con la par. Si esa par no
/// está en el plano, la impar queda sola. En la 3.1.0 era al revés (la par se
/// contaba con la impar anterior) y el avance de la 22 subía bajo la 21.
///
/// «La par vecina que la cubre» es la que está en el plano entre las dos
/// vecinas de la impar: para la 21, la 20 o la 22. La numeración ISO pone
/// las de 40 pies en 02, 06, 10… (4k + 2; así vienen las tres referencias
/// del corpus), pero `CORPUS_A01` trae también una 044, así que la regla
/// mira lo que el plano trae y no la convención. Si las dos vecinas
/// estuvieran en el plano, cosa que la numeración no permite, se queda con
/// la convencional ([conventionalEvenBay]).
///
/// La toman el avance de la carga (`LoadingOperation.displayBay`,
/// `OperationProgress`, `LoadingPlanProgress`) y, a través de ellos, la
/// silueta del plano; Estadísticas la adopta en `sprint-4`. Los movimientos
/// guardados no cambian: llevan su posición física.
library;

/// La par que, por la numeración ISO, cubre una impar: 21 y 23 → 22; 25 y
/// 27 → 26; 01 y 03 → 02. Solo desempata; la regla es [referenceBay].
int conventionalEvenBay(int oddBay) => ((oddBay - 1) ~/ 4) * 4 + 2;

/// La bahía con la que se cuenta y se rotula [bay]: la misma si es par, o si
/// es impar y ninguna par vecina está en el plano ([hasBay]); si no, la par
/// vecina que la cubre.
int referenceBay(int bay, {required bool Function(int bay) hasBay}) {
  if (bay.isEven) return bay;
  final before = bay - 1;
  final after = bay + 1;
  final hasBefore = before > 0 && hasBay(before);
  final hasAfter = hasBay(after);
  if (hasBefore && hasAfter) return conventionalEvenBay(bay);
  if (hasBefore) return before;
  if (hasAfter) return after;
  return bay;
}
