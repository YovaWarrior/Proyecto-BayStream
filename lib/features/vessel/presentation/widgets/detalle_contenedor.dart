import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design/design.dart';
import '../../domain/entities/entities.dart';
import '../providers/discharge_provider.dart';
import 'discharge_controls.dart';
import 'iconos_del_dominio.dart';
import 'office_plan_controls.dart';

/// El detalle de un contenedor (`DESIGN.md` 8 y 13.8): **una sola hoja** para
/// la hoja inferior de las pantallas angostas y el panel lateral de la
/// oficina. Lo que ya decía el detalle de antes (posición, tipo, estado,
/// peso con su fuente, puertos, IMDG, refrigerado, la descarga de T-75 y las
/// acciones de la oficina) sigue aquí, con los textos de 11 y las filas de
/// `BsHojaDeDetalle`.
class DetalleContenedor extends ConsumerWidget {
  const DetalleContenedor({
    super.key,
    required this.voyage,
    required this.container,
    this.controlador,
    this.onCerrar,
  });

  /// El viaje al que pertenece.
  final VesselVoyage voyage;

  /// El contenedor.
  final ContainerUnit container;

  /// El controlador de la hoja arrastrable; nulo en el panel.
  final ScrollController? controlador;

  /// Qué hace «Cerrar»: en la hoja cierra la hoja; en el panel, lo vacía.
  final VoidCallback? onCerrar;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tema = Theme.of(context);
    final medidas = BsMedidas.de(context);
    final semanticos = BsColoresSemanticos.de(context);
    final textos = tema.textTheme;
    final posicion = container.stowagePosition;
    final estado = switch (container.status) {
      ContainerStatus.full => 'lleno',
      ContainerStatus.empty => 'vacío',
      _ => 'sin declarar',
    };
    final pies = container.sizeInFeet;
    final subtitulo = <String>[
      if (container.isoSizeType != null) container.isoSizeType!,
      if (pies != null) '$pies pies',
      estado,
    ].join(' · ');

    final filas = <BsFilaDeDetalle>[
      BsFilaDeDetalle(
        'Celda',
        posicion == null ? 'Sin posición' : formatearPosicion(posicion.toIsoCode()),
      ),
      BsFilaDeDetalle('Tipo ISO', container.isoSizeType ?? 'Sin declarar'),
      BsFilaDeDetalle('Estado', estado),
      // T-66: cada peso con su fuente; si vienen los dos, los dos.
      if (container.vgmWeight != null)
        BsFilaDeDetalle('VGM', formatearKilos(container.vgmWeight!)),
      if (container.grossWeight != null)
        BsFilaDeDetalle('Peso bruto', formatearKilos(container.grossWeight!)),
      if (container.effectiveWeight == null)
        const BsFilaDeDetalle('Peso', 'El archivo no trae peso'),
      BsFilaDeDetalle('Puerto de carga', container.portOfLoading ?? 'Sin declarar'),
      BsFilaDeDetalle(
          'Puerto de descarga', container.portOfDischarge ?? 'Sin declarar'),
      if (container.operatorCode != null)
        BsFilaDeDetalle('Naviera', container.operatorCode!),
    ];

    final secciones = <Widget>[
      if (container.isDangerous)
        _Senal(
          icono: BsIconos.peligrosa,
          color: semanticos.peligrosa.contorno,
          titulo:
              'Carga peligrosa · IMO ${container.imdgClass ?? 'sin clase'}',
          detalle: container.unNumber == null ? null : 'UN ${container.unNumber}',
        ),
      if (container.isReefer)
        _Senal(
          icono: BsIconos.refrigerado,
          color: semanticos.refrigerado.contorno,
          titulo: 'Refrigerado',
          detalle: container.temperature == null
              ? 'Sin temperatura declarada'
              : '${container.temperature!.toStringAsFixed(1)} °'
                  '${container.temperatureUnit ?? 'C'}',
        ),
      if (container.isOverDimension)
        _Senal(
          icono: BsIconos.fueraDeMedida,
          color: semanticos.oog.contorno,
          titulo: 'Sobredimensionado',
        ),
      // T-75: estado en la escala, quién y cuándo, y deshacer.
      if (offersDischarge(voyage))
        DischargeDetailSection(voyage: voyage, container: container),
      if (voyage.portOfCall != null)
        OfficePlanActions(
            voyage: voyage, itemKey: 'C:${container.containerId}'),
    ];

    return BsHojaDeDetalle(
      key: const ValueKey('detalle-contenedor'),
      titulo: Row(
        children: <Widget>[
          // El ícono principal, con la misma regla y el mismo nombre que la
          // Lista y la búsqueda (DESIGN.md 13.11; O1 y H1 de 10.23).
          IconoDelContenedor(
            container,
            color: tema.colorScheme.onSurfaceVariant,
          ),
          SizedBox(width: medidas.espacioS),
          Expanded(
            child: BsNumeroDeContenedor(
              container.containerId,
              estilo: textos.headlineSmall,
            ),
          ),
          if (container.operatorCode != null)
            Container(
              padding: EdgeInsets.symmetric(
                  horizontal: medidas.espacioS, vertical: medidas.espacioXs),
              decoration: BoxDecoration(
                color: tema.colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(medidas.radioControl),
              ),
              child: Text(
                container.operatorCode!,
                style: textos.labelLarge,
              ),
            ),
        ],
      ),
      subtitulo: subtitulo,
      filas: filas,
      secciones: secciones,
      controlador: controlador,
      onCerrar: onCerrar,
    );
  }
}

/// Una señal de carga especial en el detalle: icono del rol, título y dato.
class _Senal extends StatelessWidget {
  const _Senal({
    required this.icono,
    required this.color,
    required this.titulo,
    this.detalle,
  });

  final IconData icono;
  final Color color;
  final String titulo;
  final String? detalle;

  @override
  Widget build(BuildContext context) {
    final medidas = BsMedidas.de(context);
    final textos = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(icono, color: color),
        SizedBox(width: medidas.espacioS),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(titulo,
                  style: textos.titleSmall?.copyWith(color: color)),
              if (detalle != null) Text(detalle!, style: textos.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}
