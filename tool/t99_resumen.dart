// T-99 · Resume lo que entrega el arnés integration_test/t99_rendimiento_test.dart.
//
// Lee el JSON que escribe integration_test/t99_driver.dart y saca, por
// escenario y repetición, las cifras de RNF-001 (T-63, 2): parseo, navegación
// entre bahías, búsqueda por carácter, tablero de Estadísticas y scroll.
//
// TimelineSummary vive en flutter_driver, que no es dependencia directa del
// proyecto (2.7 solo autoriza integration_test). Por eso aquí se aplican sus
// mismas reglas, citadas de flutter_driver 3.38.9:
//   - cuadro de build: pares de eventos «Frame»; de raster: pares de
//     «GPURasterizer::Draw» (timeline_summary.dart, kBuildFrameEventName y
//     kRasterizeFrameEventName); cada inicio se empareja con el siguiente fin;
//   - percentil: findPercentile, sin interpolar (percentile_utils.dart);
//   - presupuesto de cuadro perdido: 16 ms (kBuildBudget).
// La latencia va de la marca «t99_marca» (antes del toque o del carácter) al
// fin del raster del cuadro que construyó el estado final, señalado por
// «t99_fin». La primera repetición se descarta (en frío) y se declara.
// No da dictámenes: los pone una persona en el informe.
//
//   dart tool/t99_resumen.dart <respuesta.json> <salida en %TEMP%>
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 't99_comun.dart';

const eventoDeBuild = 'Frame';
const eventoDeRaster = 'GPURasterizer::Draw';
const presupuestoMs = 16.0;

/// Umbrales del ERS (T-63, 3). Solo se imprimen al lado de la cifra.
const umbrales = {
  'parseo': '< 5000 ms con 5 000 contenedores',
  'navegacion': '< 100 ms',
  'busqueda': '< 200 ms por actualización',
  'tablero': '< 1000 ms',
  'scroll_lista': 'p90 ≤ 16.67 ms (build y raster)',
  'scroll_estadisticas': 'p90 ≤ 16.67 ms (build y raster)',
};

int? _ts(Map e) => (e['ts'] as num?)?.toInt();

List<Map<String, dynamic>> _ordenados(List eventos) =>
    eventos.cast<Map<String, dynamic>>().where((e) => _ts(e) != null).toList()
      ..sort((a, b) => _ts(a)!.compareTo(_ts(b)!));

/// Pares (inicio, fin) en microsegundos de los eventos [nombre], con la regla
/// de TimelineSummary: un inicio «B» o «b» se cierra con el siguiente evento
/// del mismo nombre que no sea inicio. Los eventos completos «X» traen `dur`.
List<(int, int)> paresDeEvento(List eventos, String nombre) {
  final out = <(int, int)>[];
  int? inicio;
  for (final e in _ordenados(eventos).where((e) => e['name'] == nombre)) {
    final fase = e['ph'];
    if (fase == 'X') {
      out.add((_ts(e)!, _ts(e)! + ((e['dur'] as num?)?.toInt() ?? 0)));
    } else if (fase == 'B' || fase == 'b') {
      inicio = _ts(e);
    } else if (inicio != null) {
      out.add((inicio, _ts(e)!));
      inicio = null;
    }
  }
  return out;
}

List<double> duracionesMs(List eventos, String nombre) =>
    [for (final (a, b) in paresDeEvento(eventos, nombre)) (b - a) / 1000];

int? _instante(List eventos, String nombre) {
  for (final e in _ordenados(eventos)) {
    if (e['name'] == nombre) return _ts(e);
  }
  return null;
}

/// Latencia en ms de la marca al fin del raster del cuadro que construyó el
/// estado final: el último «Frame» que empezó antes de «t99_fin» y el primer
/// «GPURasterizer::Draw» que empezó desde ese cuadro.
double? latenciaMs(List eventos, {String raster = eventoDeRaster}) {
  final marca = _instante(eventos, 't99_marca');
  final fin = _instante(eventos, 't99_fin');
  if (marca == null || fin == null) return null;
  final cuadros = paresDeEvento(eventos, eventoDeBuild)
      .where((p) => p.$1 >= marca && p.$1 <= fin)
      .toList();
  if (cuadros.isEmpty) return null;
  final ultimo = cuadros.last;
  for (final (inicio, finRaster) in paresDeEvento(eventos, raster)) {
    if (inicio >= ultimo.$1) return (finRaster - marca) / 1000;
  }
  return null;
}

/// Latencia de la pasada sin traza, con los FrameTiming del motor: de la
/// marca al fin del raster del último cuadro cuyo build empezó entre la marca
/// y el fin. Es el mismo criterio que [latenciaMs], sin grabar la línea de
/// tiempo, que en el ensayo de la Fase A volvía lentos los cuadros grandes.
double? latenciaSinTrazaMs(Map? sinTraza) {
  final marca = (sinTraza?['marca_us'] as num?)?.toInt();
  final fin = (sinTraza?['fin_us'] as num?)?.toInt();
  if (marca == null || fin == null) return null;
  final cuadros = [
    for (final c in (sinTraza!['cuadros'] as List? ?? const []).cast<Map>())
      if ((c['build_inicio'] as num) >= marca && (c['build_inicio'] as num) <= fin) c
  ]..sort((a, b) => (a['build_inicio'] as num).compareTo(b['build_inicio'] as num));
  if (cuadros.isEmpty) return null;
  return ((cuadros.last['raster_fin'] as num) - marca) / 1000;
}

/// Cuánto se separan el reloj de la línea de tiempo y el de FrameTiming: la
/// mediana, en µs, entre cada «Animator::BeginFrame» de la traza y el inicio
/// de build más cercano. Si es grande, las dos latencias no se comparan.
double? desfaseDeRelojesUs(List eventos, List? cuadros) {
  final inicios = [
    for (final c in (cuadros ?? const []).cast<Map>()) (c['build_inicio'] as num).toInt()
  ];
  if (inicios.isEmpty) return null;
  final desfases = [
    for (final (inicio, _) in paresDeEvento(eventos, 'Animator::BeginFrame'))
      inicios.map((b) => (b - inicio).abs()).reduce(math.min)
  ];
  return desfases.isEmpty ? null : mediana(desfases);
}

/// El resumen de cuadros de una traza con las reglas de TimelineSummary.
Map<String, num> resumenDeCuadros(List eventos, {String raster = eventoDeRaster}) {
  final build = duracionesMs(eventos, eventoDeBuild);
  final dibujo = duracionesMs(eventos, raster);
  Map<String, num> de(String n, List<double> v) => v.isEmpty
      ? {'${n}_cuadros': 0}
      : {
          '${n}_cuadros': v.length,
          '${n}_promedio_ms': v.reduce((a, b) => a + b) / v.length,
          '${n}_p90_ms': percentilComoTimelineSummary(v, 90),
          '${n}_p99_ms': percentilComoTimelineSummary(v, 99),
          '${n}_peor_ms': maximo(v),
          '${n}_perdidos': v.where((d) => d > presupuestoMs).length,
        };
  return {...de('build', build), ...de('raster', dibujo)};
}

/// Una fila del resumen: escenario, repetición y cifra.
class Fila {
  final String escenario;
  final int repeticion;
  final String metrica;
  final double? valor;
  final String fuente;
  const Fila(this.escenario, this.repeticion, this.metrica, this.valor, this.fuente);
  bool get descartada => repeticion == 0;
}

/// Convierte la respuesta del arnés en filas.
List<Fila> filasDeLaRespuesta(Map<String, dynamic> respuesta) {
  final t99 = respuesta['t99'] as Map<String, dynamic>? ?? const {};
  final medidas = (t99['medidas'] as List? ?? const []).cast<Map<String, dynamic>>();
  final raster = (t99['entorno'] as Map?)?['evento_de_raster'] as String? ?? eventoDeRaster;
  final out = <Fila>[];
  for (final m in medidas) {
    final escenario = m['escenario'] as String;
    final rep = (m['repeticion'] as num).toInt();
    final eventos = m['eventos'] as List? ?? const [];
    switch (escenario) {
      case 'parseo':
        final d = duracionesMs(eventos, 't99_parseo');
        out.add(Fila(escenario, rep, 'duracion_ms', d.isEmpty ? null : d.first, 'traza'));
        final us = (m['cronometro_us'] as num?)?.toDouble();
        if (us != null) out.add(Fila(escenario, rep, 'cronometro_ms', us / 1000, 'cronometro'));
      case 'navegacion' || 'busqueda' || 'tablero':
        out.add(Fila(escenario, rep, 'latencia_ms', latenciaMs(eventos, raster: raster), 'traza'));
        if (m.containsKey('sin_traza')) {
          out.add(Fila(escenario, rep, 'latencia_ms',
              latenciaSinTrazaMs(m['sin_traza'] as Map?), 'FrameTiming sin traza'));
          out.add(Fila(escenario, rep, 'desfase_de_relojes_us',
              desfaseDeRelojesUs(eventos, m['cuadros_con_traza'] as List?), 'cotejo'));
        }
      case 'scroll_lista' || 'scroll_estadisticas':
        if (eventos.isNotEmpty) {
          final r = resumenDeCuadros(eventos, raster: raster);
          for (final k in ['build_p90_ms', 'raster_p90_ms', 'build_perdidos', 'raster_perdidos']) {
            out.add(Fila(escenario, rep, k, r[k]?.toDouble(), 'traza'));
          }
        }
        final c = m['resumen_cuadros'] as Map?;
        if (c != null) {
          out.add(Fila(escenario, rep, 'build_p90_ms',
              (c['90th_percentile_frame_build_time_millis'] as num?)?.toDouble(), 'FrameTiming'));
          out.add(Fila(escenario, rep, 'raster_p90_ms',
              (c['90th_percentile_frame_rasterizer_time_millis'] as num?)?.toDouble(),
              'FrameTiming'));
        }
    }
  }
  return out;
}

void main(List<String> args) {
  if (args.length != 2) {
    stderr.writeln('Uso: dart tool/t99_resumen.dart <respuesta.json> <salida en %TEMP%>');
    exitCode = 64;
    return;
  }
  final respuesta = jsonDecode(File(args[0]).readAsStringSync()) as Map<String, dynamic>;
  final salida = args[1];
  exigirSalidaEnTemp(salida);
  carpetaNueva(salida);
  final filas = filasDeLaRespuesta(respuesta);
  final csv = StringBuffer()
    ..writeln(filaCsv(['escenario', 'repeticion', 'descartada', 'metrica', 'valor', 'fuente']));
  for (final f in filas) {
    csv.writeln(filaCsv([
      f.escenario, f.repeticion, f.descartada ? 'si (en frio)' : '', f.metrica,
      f.valor == null ? 'sin dato' : cifra(f.valor!, 3), f.fuente
    ]));
  }
  File('$salida/resumen.csv').writeAsStringSync(csv.toString());

  final entorno = (respuesta['t99'] as Map?)?['entorno'] as Map? ?? const {};
  final md = StringBuffer()
    ..writeln('# T-99 · Resumen del arnés')
    ..writeln()
    ..writeln('Entorno: ${jsonEncode(entorno)}')
    ..writeln()
    ..writeln('La repetición 0 se descarta (en frío). Sin dictamen: lo pone el informe.')
    ..writeln()
    ..writeln('| Escenario | Métrica | Fuente | n | Mediana | Máximo | Sin dato | Umbral del ERS |')
    ..writeln('|---|---|---|---:|---:|---:|---:|---|');
  final grupos = <String, List<Fila>>{};
  for (final f in filas.where((f) => !f.descartada)) {
    grupos.putIfAbsent('${f.escenario}|${f.metrica}|${f.fuente}', () => []).add(f);
  }
  for (final e in grupos.entries) {
    final p = e.key.split('|');
    final v = e.value.where((f) => f.valor != null).map((f) => f.valor!).toList();
    md.writeln('| ${p[0]} | ${p[1]} | ${p[2]} | ${v.length} | '
        '${v.isEmpty ? '—' : cifra(mediana(v), 2)} | ${v.isEmpty ? '—' : cifra(maximo(v), 2)} | '
        '${e.value.length - v.length} | ${umbrales[p[0]] ?? ''} |');
  }
  File('$salida/resumen.md').writeAsStringSync(md.toString());
  stdout.write(md.toString());
  stdout.writeln('\nSalida: $salida');
}
