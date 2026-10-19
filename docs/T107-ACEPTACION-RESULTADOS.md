# T-107 · Aceptación cruzada de las partes A y B

Capitán Codex · 19-oct-2026 · **ACEPTADA con observaciones. Sin commit.**

Se acepta el encabezado compacto y los textos entregados en `2414588` y
`b862b15`. El Honor pide sesión al preparar el arrastre: Carlos prohibió
iniciar sesión hoy, por lo que **no se afirma haber trasladado el contenedor
ni haber abierto su hoja de confirmación**. No se registró ningún movimiento.

## Base y límites

Se contrastaron la ficha de la Ola 5, las decisiones 10.81/10.88/10.89,
`docs/T107-RESULTADOS.md` (A y B), la revisión rápida de A y el informe del Honor.
El historial coincidió: `83d0dc1` seguido de `8ef6da1`.

Evidencia: `%TEMP%\baystream-19oct-codex-83d0dc1\`.
La copia `head/` se exportó con `git archive` de
`83d0dc1d55358e66d5bc23ccc0b59a284327f8be`.
**La suite, analyze y corpus de aceptación corrieron allí, sin T-111.**
Las pruebas propias se añadieron después, fuera de `test/`; no se cuentan en el piso.

Los clientes usan la copia `clients/`, **HEAD + la tarjeta de T-111**, como
autorizó Carlos. T-111 no cambia el plano ni sus acciones. El banco
`tool/t111_main.dart` muestra la UI real, con repositorios aislados y sin
Firebase ni sesión; cualquier acceso remoto por el lector falla explícitamente.
Las tres compilaciones recibieron la configuración por `--dart-define-from-file`,
sin abrirla. No se abrió ni copió `android/key.properties`.

Windows utilizó `%TEMP%\baystream-19oct-codex-83d0dc1\windows-store`, namespace
`t111`, abierto por Explorer y cerrado por PID. No se usó ni consultó el almacén
real. Honor: paquete nuevo `gt.cmartinez.baystream.t111.t98`, namespace `t111`.
No se abrió «PRUEBA T-105», demo17 ni ninguna BayStream preexistente del Honor.

## Validaciones independientes

| Comprobación en HEAD sin T-111 | Resultado | Registro |
|---|---|---|
| Suite completa | **1034/1034**, sin skip | `t107-head-suite.log` |
| `flutter analyze --no-pub` | **0 incidencias** | `t107-head-analyze.log` |
| Corpus habitual, 36 instrumentos | **157/157**, sin skip | `t107-head-corpus.log` |
| Pruebas propias con A07 real | **6/6** | `t107-a07-propio-final.log` |

Las 38 pruebas T-107 de Timonel están dentro de las 1034: geometría y acciones,
etiquetas de accesibilidad, 19 avisos del deriver sin claves internas y pestañas.
Se mantiene la evidencia independiente de A ya documentada: callbacks, condiciones
y claves conservados; no se cambiaron reglas para compactar los controles.

Las seis propias montan la página completa con A07 leído del corpus por
`BAYSTREAM_CORPUS_DIRECTORY`, escala GTSTC y una operación local en memoria.
Prueban Carga/Descarga a 360×780 y letra 1.0/1.45, las dos filas, pendientes y
avance desde Acciones, y ausencia/deshabilitación de acciones cuando faltan
cuenta o listado. Repiten tres veces Lista → Estadísticas → Bay Plan → Lista,
con ambas letras, comprobando los índices y contenido reales.

Medidas de widget, **no mediciones del Honor**, en dp:

| Modo | Letra | Encabezado | Rejilla útil | Mínimo de la ficha |
|---|---:|---:|---:|---:|
| Carga | 1.0 | 104 | 441.8 | 390 |
| Descarga | 1.0 | 76 | 469.8 | 390 |
| Carga | 1.45 | 109 | 403.9 | 260 |
| Descarga | 1.45 | 90 | 422.9 | 260 |

Registro: `t107-a07-metricas.json`. En la primera corrida propia se confundió
la tabla de carga (0 pendientes) con la de descarga (114), y se intentó tocar
el botón Cerrar fuera de pantalla. Se corrigió únicamente el instrumento:
destinos diferenciados y retorno con Atrás. Se conserva `t107-a07-propio.log`;
no se cambió producto ni pruebas de Timonel.

## Windows

A07 en GTSTC, ventana maximizada:

- Contenido: pendientes, avance y chip «Solo este dispositivo» en línea.
- Carga: mismos botones, resumen completo, «0 re‑estibas», OR y Asignar vacío.
- Descarga: pendientes de descarga, avance, chip y resumen completo.
- No aparece Acciones. No hay claves `C:` a la vista.

Capturas `evidencia/windows/t107-{contenido,carga,descarga}.png`.
La referencia exacta a 1280 dp se conserva en las pruebas de widget de la
suite; no se atribuye esa dimensión a la ventana maximizada sin medirla.

## Honor: A07, Carga y Descarga

El Honor ya da **360 dp** (720 px, densidad 320); no se tocó `wm`.
Con letra **1.0 y 1.45**:

- Modo, Acciones y nube en la primera fila; resumen en la segunda, más el
  selector de bahías. En Carga, OR permanece en la segunda fila.
- El plano está visible; el resumen se despliega con un toque y muestra
  «re‑estibas» sin partirse.
- Pendientes por bahía abre la tabla de carga de A07: 0 pendientes.
- Pendientes de descarga abre su tabla: **6 bahías, 114 pendientes**,
  66 en cubierta y 48 en bodega.
- Avance de la operación abre su página en ambos modos y escalas; dice
  «Sin movimientos» y presenta las re‑estibas aparte.
- Asignar vacío y OR permanecen deshabilitados porque A07 no tiene listado
  importado. Solicitudes/bandeja no aparece sin cuenta y operación publicada.
  No se presentan esos destinos como ejercitados en el Honor: sí los cubren
  las pruebas de widget con sus condiciones habilitadas.
- Las etiquetas visibles no muestran `C:`; la etiqueta del lleno del sintético
  adicional dice «CSQU3054383, sube».

Capturas en `evidencia/honor/`:
`t107-a07-carga10.png`, `t107-a07-descarga10.png`,
`t107-a07-carga145.png`, `t107-a07-descarga145.png`,
`t107-a07-carga145-resumen.png` y `t107-a07-tabla-descarga145.png`.
La tabla se desplaza; a 1.45 hay columnas y un botón Cerrar que requieren
desplazarse. Atrás la cierra. No se atribuye eso al encabezado de T-107.

**Estadísticas / Bay Plan:** se tocó Estadísticas desde Lista, con ambas letras;
mostró 398, 21 bahías ocupadas y 6940.6 t. El toque posterior en Bay Plan mostró
el plano. **No se reprodujo el salto involuntario** de la observación de 10.81.
Capturas `t107-estadisticas10.png` y `t107-estadisticas145.png`.

**Arrastre:** se abrió un BAPLIE sintético de carga en una operación local sin
publicar del namespace `t111`. En Carga, mantener pulsado el lleno pendiente a
1.45 muestra **«Inicia sesión para mover»**, como establece
`plan_drag_confirmation.dart`. Se detuvo allí, sin sesión ni movimientos;
no llegó a existir una hoja que cancelar.
Captura `t107-arrastre-pide-sesion.png`.

La operación compartida y las acciones dependientes de cuenta quedan para
Carlos, si quiere completar esa evidencia con sesión. No son un fallo nuevo
de T-107 ni se simularon credenciales para obtener un aprobado.

## Estado final y archivos

Capturas y volcados sanitizados con el ayudante de la ronda del 19-oct; se
recortó la barra de estado en memoria. La página «Nube y cuenta» no se abrió.
Avión 0, Wi-Fi 1, letra 1.0 y app propia detenida al terminar. Los 45 paquetes
BayStream previos conservan `lastUpdateTime`; solo se añadió la app propia.
No hubo Firebase, publicaciones ni Git de escritura.

**Único archivo propio de esta aceptación:** `docs/T107-ACEPTACION-RESULTADOS.md`.
No se modificó ningún archivo de T-107, su informe de Timonel o sus pruebas.
**`pubspec.yaml` y `pubspec.lock` sin cambios.** El banco se entrega en T-111.

```powershell
git add -- docs/T107-ACEPTACION-RESULTADOS.md
git commit -m "Sprint 3: acepta T-107 con observaciones de sesion"
git push
```

## Tres líneas

ACEPTADA con observaciones: encabezado, textos y acciones locales comprobados.
HEAD limpio: 1034/1034, analyze 0, corpus 157/157 y seis pruebas propias con A07.
Honor 360 dp a 1.0/1.45 pasa; arrastre pide sesión y no se registró nada.

## Mensaje para Yov

T-107 A y B: ACEPTADA con observaciones sobre HEAD 83d0dc1. Suite limpia sin
T-111 1034/1034, analyze 0 y corpus 157/157; propias con A07 real 6/6.
Windows conserva el encabezado. Honor 360 dp, Carga/Descarga y letra 1.0/1.45:
dos filas más selector, pendientes y avance accesibles, sin C: ni re‑estibas
partida. Estadísticas no saltó al plano. Misma app HEAD + T-111, aislada y sin
Firebase/sesión. Mantener pulsado el lleno de la operación local muestra
«Inicia sesión para mover»: esa parte y las acciones con cuenta no se afirman
probadas en el Honor; los widgets sí las cubren. No hubo movimientos ni
publicación. Informe docs/T107-ACEPTACION-RESULTADOS.md; commit propuesto
«Sprint 3: acepta T-107 con observaciones de sesion».
