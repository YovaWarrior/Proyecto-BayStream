import 'dart:math';

import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../domain/entities/entities.dart';

/// Genera el reporte operativo completo del viaje en PDF.
class PdfReportService {
  static const _pageMargin = 24.0;

  const PdfReportService();

  Future<Uint8List> generate(VesselVoyage voyage) async {
    final regularFont = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Roboto-Regular.ttf'),
    );
    final mediumFont = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Roboto-Medium.ttf'),
    );
    final document = pw.Document(
      title: 'BayStream - ${voyage.vessel.name} ${voyage.voyageNumber}',
      author: 'BayStream',
      creator: 'BayStream',
      subject: 'Reporte del plan de estiba',
      theme: pw.ThemeData.withFont(
        base: regularFont,
        bold: mediumFont,
        italic: regularFont,
      ),
    );

    document.addPage(_coverPage(voyage));

    final bays = voyage.bays.values.toList()
      ..sort((a, b) => a.bayNumber.compareTo(b.bayNumber));
    for (final bay in bays) {
      document.addPage(_bayPage(voyage, bay));
    }

    document.addPage(_containersTable(voyage));
    return document.save();
  }

  List<ContainerUnit> sortedContainers(VesselVoyage voyage) {
    final containers = List<ContainerUnit>.from(voyage.containers);
    containers.sort((a, b) {
      final aPosition = a.stowagePosition?.rawCode ?? '9999999';
      final bPosition = b.stowagePosition?.rawCode ?? '9999999';
      final byPosition = aPosition.compareTo(bPosition);
      return byPosition != 0
          ? byPosition
          : a.containerId.compareTo(b.containerId);
    });
    return containers;
  }

  pw.Page _coverPage(VesselVoyage voyage) {
    final reeferCount = voyage.containers.where((c) => c.isReefer).length;
    final dangerousCount = voyage.containers.where((c) => c.isDangerous).length;
    final oogCount = voyage.containers.where((c) => c.isOverDimension).length;
    final origin = _portSummary(
      voyage.portOfOrigin,
      voyage.containers.map((c) => c.portOfLoading),
    );
    final destination = _portSummary(
      voyage.portOfDestination,
      voyage.containers.map((c) => c.portOfDischarge),
    );

    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: double.infinity,
            padding:
                const pw.EdgeInsets.symmetric(vertical: 28, horizontal: 24),
            decoration: const pw.BoxDecoration(
              color: PdfColors.blueGrey900,
              borderRadius: pw.BorderRadius.all(pw.Radius.circular(8)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'BAYSTREAM',
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                pw.SizedBox(height: 18),
                pw.Text(
                  'Reporte del plan de estiba',
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 28,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  '${voyage.vessel.name} - Viaje ${voyage.voyageNumber}',
                  style: const pw.TextStyle(
                    color: PdfColors.blueGrey100,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 28),
          _sectionTitle('Datos del viaje'),
          pw.SizedBox(height: 10),
          pw.Table(
            columnWidths: const {
              0: pw.FixedColumnWidth(90),
              1: pw.FlexColumnWidth(),
              2: pw.FixedColumnWidth(90),
              3: pw.FlexColumnWidth(),
            },
            children: [
              _infoRow(
                  'Buque', voyage.vessel.name, 'Viaje', voyage.voyageNumber),
              _infoRow('Puerto origen', origin, 'Puerto destino', destination),
              _infoRow(
                'Dirección',
                _directionLabel(voyage.direction),
                'Bahías',
                voyage.bays.length.toString(),
              ),
            ],
          ),
          pw.SizedBox(height: 24),
          _sectionTitle('Resumen operativo'),
          pw.SizedBox(height: 12),
          pw.Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _metricCard('Contenedores', voyage.totalContainers.toString()),
              _metricCard('TEU', _formatTeu(_totalTeu(voyage))),
              _metricCard(
                'Peso bruto',
                '${(voyage.totalGrossWeight / 1000).toStringAsFixed(1)} t',
              ),
              _metricCard(
                'Peso VGM',
                '${(voyage.totalVgmWeight / 1000).toStringAsFixed(1)} t',
              ),
              _metricCard('Llenos', voyage.fullContainers.toString()),
              _metricCard('Vacíos', voyage.emptyContainers.toString()),
            ],
          ),
          pw.SizedBox(height: 24),
          _sectionTitle('Carga especial'),
          pw.SizedBox(height: 12),
          pw.Row(
            children: [
              _specialCargoCard('Refrigerados', reeferCount, PdfColors.cyan700),
              pw.SizedBox(width: 10),
              _specialCargoCard(
                  'Peligrosos IMO', dangerousCount, PdfColors.red700),
              pw.SizedBox(width: 10),
              _specialCargoCard(
                  'Fuera de gálibo', oogCount, PdfColors.orange700),
            ],
          ),
          pw.Spacer(),
          pw.Divider(color: PdfColors.blueGrey200),
          _footer(context, voyage),
        ],
      ),
    );
  }

  pw.Page _bayPage(VesselVoyage voyage, Bay bay) {
    return pw.Page(
      pageFormat: PdfPageFormat.a4.landscape,
      margin: const pw.EdgeInsets.all(_pageMargin),
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Plano de bahía ${bay.bayNumberPadded}',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blueGrey900,
                ),
              ),
              pw.Text(
                '${bay.containers.length} contenedores - '
                '${(bay.totalWeight / 1000).toStringAsFixed(1)} t',
                style: const pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.blueGrey700,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 12),
          pw.Expanded(child: _bayPlan(bay)),
          pw.SizedBox(height: 8),
          _bayLegend(),
          pw.Divider(color: PdfColors.blueGrey200),
          _footer(context, voyage),
        ],
      ),
    );
  }

  pw.Widget _bayPlan(Bay bay) {
    final positioned = bay.containers
        .where((container) => container.stowagePosition != null)
        .toList();
    if (positioned.isEmpty) {
      return pw.Center(
        child: pw.Text(
          'Sin contenedores con posición de estiba',
          style: const pw.TextStyle(color: PdfColors.blueGrey500),
        ),
      );
    }

    final positions = <String, ContainerUnit>{};
    final rowValues = <int>{};
    final deckValues = <int>{};
    final holdValues = <int>{};
    for (final container in positioned) {
      final position = container.stowagePosition!;
      positions['${position.row}-${position.tier}'] = container;
      rowValues.add(position.row);
      (position.tier >= 80 ? deckValues : holdValues).add(position.tier);
    }

    final rows = _orderedRows(rowValues);
    final deckTiers = _tierRange(deckValues);
    final holdTiers = _tierRange(holdValues);
    final totalTierRows = max(1, deckTiers.length + holdTiers.length);
    final cellWidth = ((PdfPageFormat.a4.landscape.width - 160) / rows.length)
        .clamp(18.0, 36.0)
        .toDouble();
    final cellHeight = (330 / totalTierRows).clamp(10.0, 24.0).toDouble();

    return pw.Center(
      child: pw.Column(
        mainAxisSize: pw.MainAxisSize.min,
        children: [
          _rowHeader(rows, cellWidth),
          if (deckTiers.isNotEmpty) ...[
            _deckLabel('CUBIERTA (DECK) - Tiers 80 y superiores'),
            ...deckTiers.map(
              (tier) => _tierRow(
                tier,
                rows,
                positions,
                cellWidth,
                cellHeight,
              ),
            ),
          ],
          if (deckTiers.isNotEmpty && holdTiers.isNotEmpty) ...[
            pw.SizedBox(height: 5),
            pw.Container(
              width: 60 + rows.length * cellWidth,
              height: 3,
              color: PdfColors.brown400,
            ),
            pw.SizedBox(height: 5),
          ],
          if (holdTiers.isNotEmpty) ...[
            _deckLabel('BODEGA (HOLD) - Tiers inferiores a 80'),
            ...holdTiers.map(
              (tier) => _tierRow(
                tier,
                rows,
                positions,
                cellWidth,
                cellHeight,
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<int> _orderedRows(Set<int> values) {
    final even = values.where((row) => row.isEven).toList()
      ..sort((a, b) => b.compareTo(a));
    final odd = values.where((row) => row.isOdd).toList()..sort();
    return [...even, ...odd];
  }

  List<int> _tierRange(Set<int> values) {
    if (values.isEmpty) return [];
    final minTier = values.reduce(min);
    final maxTier = values.reduce(max);
    return [for (var tier = maxTier; tier >= minTier; tier -= 2) tier];
  }

  pw.Widget _rowHeader(List<int> rows, double cellWidth) {
    return pw.Row(
      mainAxisSize: pw.MainAxisSize.min,
      children: [
        pw.SizedBox(width: 30),
        ...rows.map(
          (row) => pw.Container(
            width: cellWidth,
            alignment: pw.Alignment.center,
            child: pw.Text(
              row.toString().padLeft(2, '0'),
              style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  pw.Widget _deckLabel(String label) {
    return pw.Container(
      margin: const pw.EdgeInsets.symmetric(vertical: 3),
      padding: const pw.EdgeInsets.symmetric(vertical: 2, horizontal: 8),
      decoration: const pw.BoxDecoration(
        color: PdfColors.blueGrey50,
        borderRadius: pw.BorderRadius.all(pw.Radius.circular(3)),
      ),
      child: pw.Text(
        label,
        style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold),
      ),
    );
  }

  pw.Widget _tierRow(
    int tier,
    List<int> rows,
    Map<String, ContainerUnit> positions,
    double cellWidth,
    double cellHeight,
  ) {
    return pw.Row(
      mainAxisSize: pw.MainAxisSize.min,
      children: [
        pw.Container(
          width: 30,
          alignment: pw.Alignment.center,
          child: pw.Text(
            tier.toString().padLeft(2, '0'),
            style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold),
          ),
        ),
        ...rows.map(
          (row) => _containerCell(
            positions['$row-$tier'],
            cellWidth,
            cellHeight,
          ),
        ),
      ],
    );
  }

  pw.Widget _containerCell(
    ContainerUnit? container,
    double width,
    double height,
  ) {
    final colors = _containerColors(container);
    final label = container == null
        ? ''
        : container.isDangerous
            ? 'IMO'
            : container.isReefer
                ? 'R'
                : container.isOverDimension
                    ? 'OOG'
                    : container.sizeInFeet?.toString() ?? '?';

    return pw.Container(
      width: width,
      height: height,
      margin: const pw.EdgeInsets.all(0.8),
      decoration: pw.BoxDecoration(
        color: colors.$1,
        border: pw.Border.all(color: colors.$2, width: 0.8),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(2)),
      ),
      child: pw.Center(
        child: pw.Column(
          mainAxisSize: pw.MainAxisSize.min,
          children: [
            pw.Text(
              label,
              style: pw.TextStyle(
                color: colors.$2,
                fontSize: height < 15 ? 4.5 : 6,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            if (container?.operatorCode != null && height >= 17)
              pw.Text(
                container!.operatorCode!,
                maxLines: 1,
                style: pw.TextStyle(color: colors.$2, fontSize: 4.5),
              ),
          ],
        ),
      ),
    );
  }

  (PdfColor, PdfColor) _containerColors(ContainerUnit? container) {
    if (container == null) return (PdfColors.grey200, PdfColors.grey300);
    if (container.isDangerous) return (PdfColors.red100, PdfColors.red);
    if (container.isReefer) return (PdfColors.cyan100, PdfColors.cyan);
    if (container.isOverDimension) {
      return (PdfColors.orange100, PdfColors.orange);
    }
    if (container.status == ContainerStatus.full) {
      return (PdfColors.green100, PdfColors.green);
    }
    if (container.status == ContainerStatus.empty) {
      return (PdfColors.orange100, PdfColors.orange);
    }
    return (PdfColors.grey100, PdfColors.grey);
  }

  pw.Widget _bayLegend() {
    return pw.Wrap(
      spacing: 12,
      runSpacing: 4,
      children: [
        _legendItem('Lleno', PdfColors.green100, PdfColors.green),
        _legendItem('Vacío', PdfColors.orange100, PdfColors.orange),
        _legendItem('IMO', PdfColors.red100, PdfColors.red),
        _legendItem('Reefer', PdfColors.cyan100, PdfColors.cyan),
        _legendItem('OOG', PdfColors.orange100, PdfColors.orange),
        _legendItem('Sin contenedor', PdfColors.grey200, PdfColors.grey300),
      ],
    );
  }

  pw.Widget _legendItem(String label, PdfColor fill, PdfColor border) {
    return pw.Row(
      mainAxisSize: pw.MainAxisSize.min,
      children: [
        pw.Container(
          width: 10,
          height: 10,
          decoration: pw.BoxDecoration(
            color: fill,
            border: pw.Border.all(color: border),
          ),
        ),
        pw.SizedBox(width: 3),
        pw.Text(label, style: const pw.TextStyle(fontSize: 7)),
      ],
    );
  }

  pw.MultiPage _containersTable(VesselVoyage voyage) {
    final containers = sortedContainers(voyage);
    return pw.MultiPage(
      pageFormat: PdfPageFormat.a4.landscape,
      margin: const pw.EdgeInsets.all(_pageMargin),
      maxPages: 100,
      header: (context) => pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 8),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Detalle de contenedores',
              style: pw.TextStyle(
                fontSize: 15,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blueGrey900,
              ),
            ),
            pw.Text(
              '${voyage.vessel.name} - ${voyage.voyageNumber}',
              style: const pw.TextStyle(
                fontSize: 8,
                color: PdfColors.blueGrey700,
              ),
            ),
          ],
        ),
      ),
      footer: (context) => _footer(context, voyage),
      build: (context) => [
        pw.TableHelper.fromTextArray(
          headers: const [
            'Posición',
            'Contenedor',
            'Tipo',
            'Estado',
            'Peso t',
            'VGM t',
            'POL',
            'POD',
            'Naviera',
            'Especial',
          ],
          data: containers.map(_containerTableRow).toList(),
          headerCount: 1,
          headerDecoration:
              const pw.BoxDecoration(color: PdfColors.blueGrey800),
          headerStyle: pw.TextStyle(
            color: PdfColors.white,
            fontSize: 6.5,
            fontWeight: pw.FontWeight.bold,
          ),
          headerPadding:
              const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 3),
          cellStyle: const pw.TextStyle(fontSize: 6.2),
          cellPadding:
              const pw.EdgeInsets.symmetric(vertical: 3, horizontal: 3),
          oddRowDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey50),
          border: const pw.TableBorder(
            horizontalInside:
                pw.BorderSide(color: PdfColors.blueGrey100, width: 0.4),
          ),
          columnWidths: const {
            0: pw.FixedColumnWidth(48),
            1: pw.FixedColumnWidth(72),
            2: pw.FixedColumnWidth(34),
            3: pw.FixedColumnWidth(38),
            4: pw.FixedColumnWidth(38),
            5: pw.FixedColumnWidth(38),
            6: pw.FixedColumnWidth(42),
            7: pw.FixedColumnWidth(42),
            8: pw.FixedColumnWidth(48),
            9: pw.FlexColumnWidth(),
          },
        ),
      ],
    );
  }

  List<String> _containerTableRow(ContainerUnit container) {
    return [
      container.stowagePosition?.rawCode ?? 'Sin posición',
      container.containerId,
      container.isoSizeType ?? '-',
      _statusLabel(container.status),
      _tons(container.grossWeight),
      _tons(container.vgmWeight),
      container.portOfLoading ?? '-',
      container.portOfDischarge ?? '-',
      container.operatorCode ?? '-',
      _specialLabels(container),
    ];
  }

  pw.Widget _sectionTitle(String title) {
    return pw.Text(
      title,
      style: pw.TextStyle(
        fontSize: 15,
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.blueGrey800,
      ),
    );
  }

  pw.TableRow _infoRow(
    String label1,
    String value1,
    String label2,
    String value2,
  ) {
    pw.Widget cell(String text, {bool label = false}) => pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 5, horizontal: 4),
          child: pw.Text(
            text,
            style: pw.TextStyle(
              fontSize: 9,
              fontWeight: label ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: label ? PdfColors.blueGrey700 : PdfColors.black,
            ),
          ),
        );
    return pw.TableRow(
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColors.blueGrey100, width: 0.5),
        ),
      ),
      children: [
        cell(label1, label: true),
        cell(value1),
        cell(label2, label: true),
        cell(value2),
      ],
    );
  }

  pw.Widget _metricCard(String label, String value) {
    return pw.Container(
      width: 158,
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.blueGrey50,
        border: pw.Border.all(color: PdfColors.blueGrey200),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            label,
            style:
                const pw.TextStyle(fontSize: 8, color: PdfColors.blueGrey600),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            value,
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    );
  }

  pw.Widget _specialCargoCard(String label, int count, PdfColor color) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(12),
        decoration: pw.BoxDecoration(
          border: pw.Border(left: pw.BorderSide(color: color, width: 3)),
          color: PdfColors.grey50,
        ),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(label, style: const pw.TextStyle(fontSize: 8)),
            pw.Text(
              count.toString(),
              style: pw.TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  pw.Widget _footer(pw.Context context, VesselVoyage voyage) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          'BayStream - ${voyage.vessel.name}',
          style: const pw.TextStyle(fontSize: 7, color: PdfColors.blueGrey500),
        ),
        pw.Text(
          'Página ${context.pageNumber} de ${context.pagesCount}',
          style: const pw.TextStyle(fontSize: 7, color: PdfColors.blueGrey500),
        ),
      ],
    );
  }

  double _totalTeu(VesselVoyage voyage) {
    return voyage.containers.fold<double>(0, (sum, container) {
      final size = container.sizeInFeet;
      return sum + (size == null ? 0 : size / 20);
    });
  }

  String _formatTeu(double teu) {
    return teu == teu.roundToDouble()
        ? teu.toStringAsFixed(0)
        : teu.toStringAsFixed(2);
  }

  String _portSummary(String? primary, Iterable<String?> alternatives) {
    if (primary != null && primary.trim().isNotEmpty) return primary;
    final ports = alternatives
        .whereType<String>()
        .where((port) => port.trim().isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    return ports.isEmpty ? 'N/D' : ports.join(', ');
  }

  String _directionLabel(VoyageDirection direction) => switch (direction) {
        VoyageDirection.import_ => 'Importación',
        VoyageDirection.export_ => 'Exportación',
        VoyageDirection.unknown => 'Sin determinar',
      };

  String _statusLabel(ContainerStatus status) => switch (status) {
        ContainerStatus.full => 'Lleno',
        ContainerStatus.empty => 'Vacío',
        ContainerStatus.unknown => 'Sin dato',
      };

  String _tons(double? kilograms) {
    return kilograms == null ? '-' : (kilograms / 1000).toStringAsFixed(1);
  }

  String _specialLabels(ContainerUnit container) {
    final labels = <String>[
      if (container.isDangerous) 'IMO',
      if (container.isReefer) 'Reefer',
      if (container.isOverDimension) 'OOG',
    ];
    return labels.isEmpty ? '-' : labels.join(' / ');
  }
}
