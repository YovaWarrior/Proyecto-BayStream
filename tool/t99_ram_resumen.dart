// T-99 · Resume las lecturas de RAM de t99_ram_windows.ps1 y t99_ram_honor.ps1.
//
// Escenario fijo de T-63 (1, «Operación normal»): cargar, Plano, todas las
// bahías, Estadísticas, buscar un ID y volver a Lista. Tras cada paso, 5 s sin
// interacción y cinco lecturas separadas 0.5 s. Por corrida:
//   - estable: la mediana de las lecturas del último paso (volver a Lista);
//   - pico: la mayor de todas las lecturas tomadas después de cada paso.
// Entre corridas se descarta la primera (en frío) y se dan mediana y máximo.
// MB del SI: 10⁶ bytes (decisión 1.3). Métrica: WorkingSet64 en Windows y RSS
// en Android (decisión 1.4, opción A). No da dictamen.
//
//   dart tool/t99_ram_resumen.dart <ram.csv> [<ram.csv>…] <salida en %TEMP%>
import 'dart:io';

import 't99_comun.dart';

const pasosDelEscenario = [
  'cargar', 'bay_plan', 'bahias', 'estadisticas', 'buscar', 'lista'
];

class Lectura {
  final String plataforma;
  final String archivo;
  final int corrida;
  final String paso;
  final int bytes;
  const Lectura(this.plataforma, this.archivo, this.corrida, this.paso, this.bytes);
}

/// Las lecturas de un CSV con cabecera; la columna de RAM es `bytes`.
List<Lectura> leerLecturas(String csv) {
  final filas = leerCsv(csv);
  if (filas.isEmpty) return const [];
  final c = filas.first;
  int col(String n) {
    final i = c.indexOf(n);
    if (i < 0) throw FormatException('Falta la columna $n');
    return i;
  }

  final plataforma = col('plataforma'), archivo = col('archivo'),
      corrida = col('corrida'), paso = col('paso'), bytes = col('bytes');
  return [
    for (final f in filas.skip(1))
      if (f.length > bytes && f[bytes].isNotEmpty)
        Lectura(f[plataforma], f[archivo], int.parse(f[corrida]), f[paso],
            int.parse(f[bytes])),
  ];
}

/// Estable y pico de una corrida, en MB del SI.
({double estable, double pico, int lecturas, List<String> faltan}) resumirCorrida(
    List<Lectura> lecturas) {
  final pasos = lecturas.map((l) => l.paso).toSet();
  final ultimo = pasosDelEscenario.lastWhere(pasos.contains,
      orElse: () => lecturas.last.paso);
  final finales = lecturas.where((l) => l.paso == ultimo).map((l) => l.bytes);
  // El pico es de las lecturas tras los pasos del escenario; «inicio» (antes
  // de cargar) se toma como referencia y no entra.
  final delEscenario = lecturas.where((l) => pasosDelEscenario.contains(l.paso));
  return (
    estable: mediana(finales) / 1e6,
    pico: maximo((delEscenario.isEmpty ? lecturas : delEscenario).map((l) => l.bytes)) / 1e6,
    lecturas: lecturas.length,
    faltan: pasosDelEscenario.where((p) => !pasos.contains(p)).toList(),
  );
}

void main(List<String> args) {
  if (args.length < 2) {
    stderr.writeln('Uso: dart tool/t99_ram_resumen.dart <ram.csv> [<ram.csv>…] <salida en %TEMP%>');
    exitCode = 64;
    return;
  }
  final salida = args.last;
  exigirSalidaEnTemp(salida);
  carpetaNueva(salida);
  final lecturas = [
    for (final a in args.sublist(0, args.length - 1)) ...leerLecturas(File(a).readAsStringSync())
  ];
  final porCorrida = <String, List<Lectura>>{};
  for (final l in lecturas) {
    porCorrida.putIfAbsent('${l.plataforma}|${l.archivo}|${l.corrida}', () => []).add(l);
  }
  final csv = StringBuffer()
    ..writeln(filaCsv([
      'plataforma', 'archivo', 'corrida', 'descartada', 'lecturas', 'estable_mb',
      'pico_mb', 'pasos_que_faltan'
    ]));
  final porArchivo = <String, List<({double estable, double pico})>>{};
  final claves = porCorrida.keys.toList()..sort();
  for (final k in claves) {
    final p = k.split('|');
    final r = resumirCorrida(porCorrida[k]!);
    final corrida = int.parse(p[2]);
    final primera = porCorrida.keys
        .where((x) => x.startsWith('${p[0]}|${p[1]}|'))
        .map((x) => int.parse(x.split('|')[2]))
        .reduce((a, b) => a < b ? a : b);
    final descartada = corrida == primera;
    csv.writeln(filaCsv([
      p[0], p[1], corrida, descartada ? 'si (en frio)' : '', r.lecturas,
      cifra(r.estable, 1), cifra(r.pico, 1), r.faltan.join(' ')
    ]));
    if (!descartada) {
      porArchivo.putIfAbsent('${p[0]}|${p[1]}', () => []).add((estable: r.estable, pico: r.pico));
    }
  }
  File('$salida/ram_corridas.csv').writeAsStringSync(csv.toString());
  final md = StringBuffer()
    ..writeln('| Plataforma | Archivo | Corridas | Estable, mediana | Estable, máximo | '
        'Pico, mediana | Pico, máximo | Umbral |')
    ..writeln('|---|---|---:|---:|---:|---:|---:|---|');
  for (final e in porArchivo.entries) {
    final p = e.key.split('|');
    final est = e.value.map((v) => v.estable);
    final pico = e.value.map((v) => v.pico);
    md.writeln('| ${p[0]} | ${p[1]} | ${e.value.length} | ${cifra(mediana(est))} MB | '
        '${cifra(maximo(est))} MB | ${cifra(mediana(pico))} MB | ${cifra(maximo(pico))} MB | < 200 MB |');
  }
  File('$salida/ram_resumen.md').writeAsStringSync(md.toString());
  stdout.write(md.toString());
  stdout.writeln('MB del SI (10⁶ bytes). La primera corrida de cada archivo se descarta. '
      'Salida: $salida');
}
