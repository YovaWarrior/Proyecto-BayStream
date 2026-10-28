import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design/design.dart';
import '../../domain/entities/entities.dart';
import '../../domain/services/operation_progress.dart';
import '../providers/discharge_provider.dart';
import '../providers/loading_operation_provider.dart';
import '../providers/plano_providers.dart';
import '../providers/voyage_ui_state.dart';
import 'loading_plan_controls.dart' show BayPlanMode;

/// Las tarjetas de cifra del plano en la oficina (`DESIGN.md` 13.8): el
/// avance con su anillo, lo que falta, las re‑estibas y las alertas. Salen de
/// la operación real (la bitácora de la escala); **sin operación no hay
/// tarjetas**, y una tarjeta sin dato no aparece.
class CifrasDelViaje extends ConsumerWidget {
  const CifrasDelViaje({
    super.key,
    required this.voyage,
    required this.modo,
    this.bahia,
    this.onAlertas,
  });

  /// El viaje publicado.
  final VesselVoyage voyage;

  /// El modo del plano: en Carga y Número de orden cuentan las cargas; en los
  /// demás, la descarga si el plano la ofrece.
  final BayPlanMode modo;

  /// La bahía seleccionada, para el detalle «18 en la bahía 14».
  final int? bahia;

  /// Abre las alertas de estiba.
  final VoidCallback? onAlertas;

  /// Las tarjetas que hay con los datos de ahora; vacío si no hay operación.
  /// Con [corta], las del panel del buque de la oficina (`DESIGN.md` 14.2):
  /// el anillo de 40 y el detalle en la descripción emergente.
  static List<Widget> tarjetas(BuildContext context, WidgetRef ref,
      {required VesselVoyage voyage,
      required BayPlanMode modo,
      int? bahia,
      VoidCallback? onAlertas,
      bool corta = false}) {
    if (voyage.portOfCall == null) return const <Widget>[];
    final semanticos = BsColoresSemanticos.de(context);
    BsAnilloAvance anillo(double fraccion) => BsAnilloAvance(
          fraccion: fraccion,
          etiqueta: formatearPorcentaje(fraccion),
          tamano: corta ? BsTarjetaCifra.anilloCorta : 52,
          grosor: corta ? 7 : 9,
        );
    final alertas = ref.watch(cuentaDeAlertasProvider);
    final publicado = ref.watch(voyageUiStateProvider) is Publicado;
    final resultado = <Widget>[];
    final deCarga =
        modo == BayPlanMode.loading || modo == BayPlanMode.order;
    if (deCarga) {
      final operacion = ref.watch(loadingOperationProvider(voyage)).value;
      if (operacion == null) return const <Widget>[];
      final total = OperationProgress.build(operacion).total;
      final hechas = total.fullLoaded + total.emptyLoaded;
      final pendientes = total.fullPending + total.emptyPending;
      final de = hechas + pendientes;
      if (de > 0) {
        resultado.add(BsTarjetaCifra(
          corta: corta,
          key: const ValueKey('cifra-carga'),
          rotulo: 'Carga',
          valor: '$hechas de $de',
          detalle: formatearPorcentaje(hechas / de),
          anillo: anillo(hechas / de),
        ));
      }
      if (total.fullLoaded + total.fullPending > 0) {
        resultado.add(BsTarjetaCifra(
          corta: corta,
          key: const ValueKey('cifra-llenos'),
          rotulo: 'Llenos',
          valor: '${total.fullLoaded} de ${total.fullLoaded + total.fullPending}',
          detalle: formatearCuenta(total.fullPending, 'pendiente', 'pendientes'),
        ));
      }
      if (total.emptyLoaded + total.emptyPending > 0) {
        resultado.add(BsTarjetaCifra(
          corta: corta,
          key: const ValueKey('cifra-vacios'),
          rotulo: 'Vacíos',
          valor:
              '${total.emptyLoaded} de ${total.emptyLoaded + total.emptyPending}',
          detalle:
              formatearCuenta(total.emptyPending, 'pendiente', 'pendientes'),
        ));
      }
      if (total.conflicts > 0) {
        resultado.add(BsTarjetaCifra(
          corta: corta,
          key: const ValueKey('cifra-conflictos'),
          rotulo: 'Conflictos',
          valor: '${total.conflicts}',
          detalle: 'en la bitácora',
          rol: semanticos.revisar,
        ));
      }
    } else if (offersDischarge(voyage)) {
      final descarga = ref.watch(dischargeProgressProvider(voyage)).value;
      if (descarga == null) return const <Widget>[];
      final de = descarga.pending + descarga.discharged;
      if (de > 0) {
        resultado.add(BsTarjetaCifra(
          corta: corta,
          key: const ValueKey('cifra-descarga'),
          rotulo: 'Descarga',
          valor: '${descarga.discharged} de $de',
          detalle: formatearPorcentaje(descarga.discharged / de),
          anillo: anillo(descarga.discharged / de),
        ));
        final enBahia = bahia == null ? null : descarga.forBay(bahia);
        resultado.add(BsTarjetaCifra(
          corta: corta,
          key: const ValueKey('cifra-por-bajar'),
          rotulo: 'Por bajar',
          valor: '${descarga.pending}',
          detalle: enBahia == null
              ? null
              : '${enBahia.pending} en la bahía ${enBahia.label}',
        ));
      }
      if (descarga.restows > 0) {
        resultado.add(BsTarjetaCifra(
          corta: corta,
          key: const ValueKey('cifra-reestibas'),
          rotulo: 'Re‑estibas',
          valor: '${descarga.restows}',
          detalle: 'no cuentan entre los que bajan',
        ));
      }
    }
    if (publicado && alertas > 0) {
      resultado.add(BsTarjetaCifra(
          corta: corta,
        key: const ValueKey('cifra-alertas'),
        rotulo: 'Alertas',
        valor: '$alertas',
        detalle: 'de estiba, por revisar',
        rol: semanticos.revisar,
        onTap: onAlertas,
      ));
    }
    return resultado;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medidas = BsMedidas.de(context);
    final lista = tarjetas(context, ref,
        voyage: voyage, modo: modo, bahia: bahia, onAlertas: onAlertas);
    if (lista.isEmpty) return const SizedBox.shrink();
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints restricciones) {
        // Dos por fila donde caben dos de 180; una debajo de otra si no.
        final porFila = restricciones.maxWidth >= 2 * 180 + medidas.espacioM
            ? 2
            : 1;
        final ancho =
            (restricciones.maxWidth - (porFila - 1) * medidas.espacioM) /
                porFila;
        return Wrap(
          spacing: medidas.espacioM,
          runSpacing: medidas.espacioM,
          children: <Widget>[
            for (final tarjeta in lista) SizedBox(width: ancho, child: tarjeta),
          ],
        );
      },
    );
  }
}
