# T-108 · Avisos de lectura BAPLIE

Capitán Codex · 18-oct-2026 · Implementación, Windows y Web verificados; Honor pendiente.
Sin commit. T-108 no se declara cerrada ni aceptada.

## Base obligatoria, antes de editar código

HEAD: `25b3efd9fa860605a1e40e9a7788d212d19e24cf`, rama `sprint-3`.
Suite completa: **964/964**, código 0. `flutter analyze --no-pub`:
**0 incidencias**, código 0. Ambos comandos tuvieron luz verde individual
de Carlos y terminaron antes del primer cambio de código.

Copia: `%TEMP%\baystream-t108-25b3efd\head-verified`.
Se obtuvo con `git archive --format=tar` de la revisión exacta y extracción
Python con nombres UTF-8, sin conversión de finales de línea. Los 673 archivos
se verificaron byte a byte contra el archivo de HEAD. Se reutilizaron únicamente
`.dart_tool/package_config.json` y `package_graph.json` de los paquetes instalados,
sin `pub get`. No se copiaron cambios sin commit de Timonel, ni sus pruebas,
instrumentos o `pubspec.*`. Antes de cada validación posterior se superponen
exclusivamente las rutas propias de T-108.

Evidencia en esa carpeta TEMP: `head-manifest.json`, `suite-head.txt` y
`analyze-head.txt` (en el directorio padre de la copia).
La extracción inicial con `tar.exe` tuvo un problema de nombres Unicode de un
PDF; no se utilizó esa copia. La extracción Python es la copia verificada.

## Prechequeo del límite del dígito

Conteo Python de solo lectura de los diez archivos, incluidas las variantes VGM:
6 161 contenedores, 5 444 números evaluables (cuatro letras y siete dígitos),
**0 dígitos inválidos: 0 %**. Los 717 de A06 tienen otro formato y no se evalúan.
El cálculo usa valores alfabéticos 10–38 omitiendo múltiplos de 11, potencias
de 2 y residuos módulo 11 y 10; control `CSQU3054383`. No se activa el límite
de más del 1 %. No es una corrida del parser modificado ni un dictamen RNF.
Evidencia agregada y huellas: `prechequeo-digito-corpus.json` en TEMP.

## Cambios

- Pesos `WT`, `VGM` y `T`: KGM conserva su precisión; LBR × 0.45359237 y
  TNE × 1000, redondeados al kilo. Sin unidad se mantiene kg con aviso;
  unidad desconocida deja nulo únicamente ese peso y avisa. Se conservan
  los formatos MEA previos y los órdenes anterior/posterior a EQD.
- Posiciones mal formadas: siguen fuera de la rejilla, con número y texto
  original en el detalle. El dígito ISO 6346 se calcula en un servicio de
  dominio puro, únicamente para cuatro letras mayúsculas y siete dígitos;
  un fallo no rechaza ni altera al contenedor.
- Ausencia de UNB, BGM, UNT o UNZ: aviso de posible archivo incompleto que
  enumera los segmentos. No cambia el rechazo de versiones no admitidas.
- La tarjeta muestra una entrada por tipo, su cuenta y un detalle a un toque,
  con los colores y el estilo del aviso de T-103. Sin avisos nuevos conserva
  su composición anterior.
- Los avisos sobreviven `copyWith`, JSON y el codec local existente. El JSON
  guarda referencias por índice a los contenedores para no duplicar sus números.
  Los viajes anteriores sin el campo siguen leyendo una lista vacía. No se
  editó el codec, su versión, Firestore ni las reglas.
- Banco `tool/t108_main.dart`: tarjeta del producto, selector de A07, sintético
  de cuatro tipos y Recientes con Hive real, namespace `t108`. En Windows exige
  un directorio TEMP explícito; en Web usa IndexedDB del origen local.

## Pruebas y validaciones ejecutadas

| Validación | Resultado | Registro bajo `%TEMP%\baystream-t108-25b3efd\` |
|---|---|---|
| HEAD antes de editar | 964/964; analyze 0 | `suite-head.txt`, `analyze-head.txt` |
| Pruebas nuevas | 24/24, incluidas en la suite | `suite-t108-final.txt` |
| Suite final HEAD + T-108 | **988/988**, código 0, sin skip | `suite-t108-final.txt` |
| Analyze final | **0 incidencias**, código 0, sin `// ignore` | `analyze-t108-final.txt` |
| Corpus previo: 36 instrumentos | **157/157** | `corpus-t108-final.txt`, `corpus-36-rutas.json` |
| Cotejo completo contra lector de HEAD | **10/10**, misma huella de todos los campos previos salvo UUID y avisos | `corpus/baseline.json`, `corpus/corpus-notices.json` |
| Batería manual T-98 | 29 observaciones; **13/13 antes silenciosos detectados con aviso visible**; 18/18 negativos totales detectados | `conformidad-t108/conformidad.csv`, `conformidad.md`, `deteccion.json` |

El último comando de corpus ejecutó **168/168**: 157 previas + 10 cotejos +
un registrador manual T-98. Este último completa su salida; por sí solo no
es un aprobado de conformidad. La lectura posterior de su CSV comprobó que
los trece casos tienen `lector_hoy=avisa` y texto visible, y los otros cinco
negativos siguen rechazados. Es ensayo del producto modificado sobre la base
declarada con T-108 superpuesta, **no medición de cierre ni dictamen RNF**.

Las 24 pruebas cubren seis conversiones (WT/VGM/T y ambas unidades), dos
formas de peso sin unidad, unidad desconocida y reemplazo posterior a EQD,
cuatro posiciones inválidas, tres pares válido/alterado, otro formato de ID,
dos pares de segmentos ausentes, archivo limpio con KGM decimal, ida y vuelta
del codec y `copyWith`, aislamiento entre grupos/lecturas, y tarjeta real con
cuatro detalles que se abren y cierran después de deserializar.

Todas las corridas Flutter tuvieron luz verde individual de Carlos. El corpus
se indicó por `--dart-define`; las evidencias y PDF de las pruebas previas
quedaron en TEMP. Las siete rutas de código/instrumentos del árbol y de la
copia coinciden byte a byte (`t108-source-manifest.json`).

### Avisos por archivo del corpus

**Archivos con algún aviso nuevo de T-108: ninguno.** No cambió ningún peso,
contenedor, posición, reserva, bahía ni otro campo anterior.

| Archivos | Avisos T-108 | Aviso previo |
|---|---|---|
| A01, A02, A03, A03v_VGM, A04, A05, A07, A08, A08v_VGM | Ninguno | Ninguno |
| A06 | Ninguno | Versión 1.5, leída con las reglas de 2.x; revisa pesos y peligrosas |

En todos los archivos las unidades de peso son KGM y están presentes UNB,
BGM, UNT y UNZ. El prechequeo y el parser no encontraron dígitos inválidos
en los números evaluables. A06 mantiene su excepción de formato de número.

### Incidencias corregidas durante el trabajo

- La primera suite de T-108 dio 987/988: el aviso duplicaba un número en el
  JSON, contrario al invariante ya probado del almacén. Se cambió exclusivamente
  la serialización de avisos en la entidad a referencias por índice. La suite
  final pasa sin editar las pruebas anteriores ni el codec.
- El primer analyze de T-108 indicó unas llaves faltantes en el instrumento
  de corpus nuevo. Se corrigieron; el final da cero. Sin supresiones.

## Windows

Compilación release del banco `tool/t108_main.dart` en la copia TEMP, con
`--no-pub` y `T108_STORE=%TEMP%/baystream-t108-25b3efd/store-t108`:
**código 0**. Registro: `build-windows-t108.txt`. MSBuild emitió MSB8029 por
compilar dentro de TEMP; no se alteraron opciones para ocultarlo.

- A07: **398 contenedores, 18 bahías, 6 940.6 t, cero avisos nuevos**.
- Sintético: cuatro entradas visibles, con sus cuentas. El detalle de posición
  muestra `CSQU3054384: 012A082`. La unidad queda fuera de la rejilla y pesa
  10 886 kg después de la conversión de LBR.
- Se cerró el primer proceso por PID **21228**, se volvió a abrir el ejecutable
  mediante `explorer.exe`, y desde Recientes se recuperó el sintético con sus
  cuatro avisos. A07 también figura allí con cero avisos.
- Segundo proceso **12888**, padre `explorer.exe`, cerrado por PID al terminar.
  En la primera apertura se observó el padre PID 28088, pero ya no existía al
  consultar posteriormente su nombre; no se inventa esa comprobación.
- **Almacén usado:** `C:\Users\Giova\AppData\Local\Temp\baystream-t108-25b3efd\store-t108`.
  Solo cajas `t108_profiles`, `t108_voyages` y `t108_settings`. No se utilizó
  `%LOCALAPPDATA%\BayStream` ni un almacén del paquete, ni bitácoras reales.
- Banco local sin cuentas ni inicialización Firebase. Se ejercitaron los
  widgets, parser y repositorio local del producto; no se afirma un recorrido
  completo por todas las pantallas de la aplicación.

Capturas en TEMP: `windows-a07.png`, `windows-cuatro-avisos.png`,
`windows-detalle-posicion.png` y `windows-recientes-reinicio.png`.
Procedencia: `windows-proceso-1.json`, `windows-proceso-2.json` y
`windows-binarios.json`.
SHA-256 del ejecutable: `4502333aefb72ccf7a17c7eda27481075d7791623edb680d052603e635fd766e`.
SHA-256 de `data/app.so`: `851a2fb4e33e12ba2a9ea8e91aa0deb722ce48df934a5bfa258b155a5e1d8387`.

## Web y recuperación de la automatización

Compilación release del mismo banco con `--no-pub --no-wasm-dry-run`:
**código 0**, registro `build-web-t108.txt`. Se observó una advertencia sobre
la fuente Cupertino ausente entre los assets. No se agregaron dependencias
ni se modificó `pubspec.*` para corregirla; analyze sigue en cero.

Se sirvió únicamente en `http://127.0.0.1:8818/`, Chrome visible. El estado
accesible mostró el banco T-108, su namespace y los tres controles. Se activó
la accesibilidad y se solicitó abrir A07. La primera inspección quedó interrumpida antes de comprobar la carga.

Al intentar inspeccionar el selector nativo de Chrome, el control automático
de Windows detuvo Computer Use porque no pudo determinar la URL actual con
suficiente confianza para aplicar su política. Ordenó terminar la ronda.
Se detuvieron las acciones de interfaz y el servidor propio.

Carlos pidió después «dale intenta chrome». El reintento utilizó el control
de pestañas de Chrome con la URL local identificada y su API documentada
`waitForEvent('filechooser')` / `setFiles`, sin inspección nativa de Chrome.
Así se completó por una vía que sí verifica la pestaña:

- A07: 398 contenedores, 18 bahías, 6 940.6 t y cero avisos nuevos.
- Sintético: cuatro entradas visibles; el detalle de peso muestra la conversión
  de LBR a 10 886 kg.
- Tras recargar la página se abrió Recientes: A07 conserva cero avisos y el
  sintético recupera los cuatro. Persistencia en IndexedDB del origen local,
  cajas con namespace `t108`.
- Chrome permaneció visible. Se cerró la pestaña propia y se detuvo el servidor
  propio por PID 27744. No hubo publicación ni sesión Firebase.

Capturas en TEMP: `web-a07.png`, `web-cuatro-avisos.png`,
`web-detalle-peso.png`, `web-recientes-reinicio.png`.

T-108 queda lista para revisión de Timonel en los clientes permitidos.
T-109 se inicia después de estas comprobaciones, respetando el orden.
El Honor sigue pendiente por instrucción de Carlos: hoy no se utilizó.
No se hicieron mediciones TLS de T-98 Fase B. No se tocaron demo17 ni
«PRUEBA T-105», ni se ejecutó Git de escritura o Firebase.

## Archivos exactos de T-108

Modificados:

- `lib/features/vessel/data/services/baplie_parser_service.dart`
- `lib/features/vessel/domain/entities/vessel_voyage.dart`
- `lib/features/vessel/presentation/widgets/voyage_summary_card.dart`

Nuevos:

- `lib/features/vessel/domain/services/iso6346_check_digit.dart`
- `test/t108_read_notices_test.dart`
- `tool/t108_corpus_test.dart`
- `tool/t108_main.dart`
- `docs/T108-RESULTADOS.md`

**`pubspec.yaml` y `pubspec.lock` sin cambios de Codex.** No se editaron
`lib/main.dart`, codec, reglas, congelados ni archivos de Timonel.

## Git preparado para Carlos

Un solo commit de T-108. El bloque puede usarse cuando Carlos decida versionar;
**no declara aceptada la tarea**, que todavía requiere revisión y el Honor permitido.
No se necesita `-f` para estas rutas.

```powershell
git add -- lib/features/vessel/data/services/baplie_parser_service.dart
git add -- lib/features/vessel/domain/entities/vessel_voyage.dart
git add -- lib/features/vessel/domain/services/iso6346_check_digit.dart
git add -- lib/features/vessel/presentation/widgets/voyage_summary_card.dart
git add -- test/t108_read_notices_test.dart
git add -- tool/t108_corpus_test.dart
git add -- tool/t108_main.dart
git add -- docs/T108-RESULTADOS.md
git commit -m "Sprint 3: Agrega avisos de lectura BAPLIE en T-108"
git push
```

## Tres líneas para Carlos

El lector convierte los pesos y avisa posiciones, dígitos y segmentos faltantes.
Suite 988/988, analyze cero, corpus 157/157 y 13/13 negativos detectados.
Windows y Web comprobados con namespace t108; Honor y aceptación de Timonel pendientes.

## Mensaje para Yov

T-108 implementada sin commit, sobre HEAD 25b3efd y una copia aislada en TEMP.
Antes de editar: suite 964/964 y analyze cero; final: 988/988 y analyze cero.
Corpus 157/157 y cotejo completo 10/10: ningún dato cambió ni hay avisos nuevos; A06 conserva el de 1.5.
La batería T-98 detecta con aviso visible los 13 negativos antes silenciosos; 18/18 negativos totales detectados.
Windows comprobado con A07, cuatro avisos y Recientes tras reinicio, namespace t108 y almacén TEMP; cerrado por PID.
Web comprobada con el control de pestañas de Chrome tras un bloqueo de la inspección nativa; IndexedDB conserva los cuatro avisos.
No toqué pubspec.*, main, codec, Firestore, reglas, congelados, demo17 ni PRUEBA T-105; Honor pendiente.
T-108 lista para revisión en Windows/Web; T-109 se trabajó después. Detalles y Git por rutas en docs/T108-RESULTADOS.md.
