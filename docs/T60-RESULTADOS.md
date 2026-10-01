# T-60 · La fila 00 ocupada por el viaje

Base: `e5dbfbb` (1-oct-2026). Solo se modificaron el validador de mercancías peligrosas, su prueba y este informe. `pubspec.yaml` y `pubspec.lock` no cambiaron; no hay dependencias nuevas.

## Cambio

`validate` recoge la ocupación de la fila 00 de **todos** los contenedores del viaje, incluso los que no declaran mercancía peligrosa. La evidencia distingue cubierta de bodega y las bahías ocupadas por cada unidad; para una unidad larga en bahía par se incluyen las dos bahías impares que cubre. Para cada par, una declaración `true` incorpora la fila, `false` la excluye y `null` la infiere solo si hay carga en 00 de la misma zona y en alguna bahía ocupada por el par. La evidencia de otra bahía o de otra zona no basta.

Cuando el hueco transversal depende de la 00, la descripción identifica su origen como «fila 00 declarada» o «fila 00 ocupada en este viaje». La explicación sigue rotulada como derivación por huecos, no medición de distancias reales.

## Pruebas y panel histórico

- Prueba dirigida del validador: `00:00 +26: All tests passed!`. El nuevo caso cubre 02/01 sin carga en 00 (posible incumplimiento), con carga en 00 de la misma bahía y zona (conforme), otra bahía (posible incumplimiento), otra zona (posible incumplimiento), declaración `true` (conforme) y declaración `false` aun con carga (posible incumplimiento). Comprueba las dos frases de procedencia.
- Suite completa: `00:10 +273: All tests passed!` con `flutter test --no-pub --reporter expanded`.
- Análisis: `No issues found! (ran in 8.7s)` con `flutter analyze --no-pub`.
- En **Windows release**, se abrió desde «Viajes recientes» el A03 histórico (`BUQUE CHARLIE · VIAJE003A`). El editor de parámetros mostró «No declarada» en cubierta y bodega; se cerró sin guardar. El panel mostró **2 posibles incumplimientos / 100 no evaluados / 151 conformes**, frente a 4/98/151 antes de T-60. Los pares 0260184/0260284 y 0260286/0260184 dejan de ser alertas falsas por ausencia supuesta de 00.
- En el mismo cliente se abrió el A01 histórico (`BUQUE ALFA · V01N`). El panel mostró **47 posibles incumplimientos / 0 no evaluados / 6 conformes**, sin cambio.

## Compilaciones release

Las tres compilaciones finalizaron sobre el mismo código de producto. SHA-256 del binario indicado, no del lanzador Windows:

| Cliente | Archivo | SHA-256 |
|---|---|---|
| Windows | `build/windows/x64/runner/Release/data/app.so` | `1077E1D46D5B4B9ED6153017213209893460C6EAF452A64A98F9B83A59433C93` |
| Web | `build/web/main.dart.js` | `9BC86E5D3BF7D3B215045959D897CF38607E085E4603B1771FADC174FC2883D8` |
| Android | `build/app/outputs/flutter-apk/app-release.apk` | `B5B0CA50C0BDC4DB1AED3BB9C4AEEB0EA19DCE61458232840BBD3CE01D0AD30D` |

Web imprimió las advertencias preexistentes del ensayo Wasm y de la fuente `CupertinoIcons`; `analyze` permaneció en cero. No se instalaron ni publicaron estos binarios.
