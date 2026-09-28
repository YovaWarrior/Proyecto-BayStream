# T-52 · PDF con geometría declarada

25-sep-2026. RF-025, fuera del compromiso, contra holgura. Git lo ejecuta Carlos.

## Cambio

El plano PDF usa `geometry.orderedRows`, `deckTierNumbers` y `holdTierNumbers`,
igual que la pantalla. Se retiraron `_orderedRows` y `_tierRange`: ya no infiere
filas ni niveles desde la carga. La fila 00 vacía permanece y un nivel omitido
en la declaración no se inventa. También se dibuja la rejilla en bahías sin
contenedores propios. Los rótulos de zona usan `deckTierFloor` declarado.

Los clamps de celda siguen en 18–36 y 10–24 puntos; `FittedBox.scaleDown` ajusta
la rejilla completa al espacio entre encabezado y leyenda si esos mínimos no
caben. Las etiquetas de fila ahora incluyen el margen exterior de las celdas:
la inspección visual detectó el desplazamiento acumulativo que había antes.

## Medición y revisión del PDF real

Archivo de entrada: `CORPUS_A01.edi` real de la carpeta Anonimizados/files.
Salida: `output/pdf/T52-CORPUS_A01.pdf`.

- **977 contenedores, 34 bahías, 62 páginas**: 1 portada + 34 planos + 27 tabla.
- Portada A4 vertical; planos y tabla A4 horizontal, 841.89 × 595.28 puntos.
- Declaración de QA: 8 filas por banda + fila central = 17 columnas;
  bodega 02–18, cubierta 82–94 = 16 niveles. Se amplió deliberadamente la
  propuesta mínima del archivo. No es una especificación real del buque.
- Celda del caso real: 36 × 20.625 puntos antes de márgenes; cabe sin reducción
  adicional. Caso extremo independiente: 51 columnas × 47 niveles activa
  ambos mínimos y el escalado, sin salir de la página (texto más pequeño).
- Se renderizaron las 62 páginas con Poppler y se inspeccionaron las hojas
  de contacto completas y la bahía 014 (92 contenedores) a mayor resolución.
  Sin recortes ni solapamientos de rejilla, leyenda o pie. Fila 00 vacía visible.
- `verify_t52_pdf.py` verifica filas y niveles en las 34 bahías y los límites
  de texto y trazos en las tres salidas. Regresión específica con filas
  04/02/00/01/03, niveles 92/88/84 y 08/04, frontera 84, una bahía sin carga:
  conserva vacíos declarados y no rellena huecos deliberados.

La cifra anterior de 55 páginas correspondía a 27 bahías y queda sustituida,
para esta verificación, por **62**. No se reescribió la bitácora histórica.

## Pruebas y reproducción

- Suite antes de pasar al bloque 4: **184/184**.
- Pruebas PDF existentes: **3/3**; ninguna aserción retirada.
- Generación corpus adicional: **1/1**; verificación Python satisfactoria.
- Analyze al cerrar T-52: **49 incidencias**, sin nuevas.

```powershell
flutter test tool/t52_corpus_pdf_test.dart --dart-define="BAYSTREAM_CORPUS_DIRECTORY=C:\Users\Giova\OneDrive\Documentos\OneDrive\Desktop\Archivos .EDI\Anonimizados\files"
python tool/verify_t52_pdf.py
```

La segunda orden requiere `pdfplumber` y `pypdf` en el entorno de QA. Se usaron
las herramientas incluidas con Codex; no se agregaron dependencias a Flutter.

### Ejecución Web completada (25-sep, 21:38 Guatemala)

El generador real se ejecutó en Chrome 154 headless, después de guardar perfiles
en IndexedDB, cerrar las cajas y recargar la página. Corpus A01 real y la misma
geometría de QA ampliada descrita arriba. Salida independiente de Chrome:
`output/pdf/T52-Chrome-A01.pdf`, **284 891 bytes y 62 páginas**. Se verificaron
las filas/niveles declarados de las 34 bahías, incluido 00, y los límites de
texto y trazos de todas las páginas. Se renderizaron e inspeccionaron las 62
páginas y la bahía 014 ampliada; sin recortes ni desbordes.

`tool/verify_block4_web.py` comprueba tanto la evidencia de recarga como este PDF.
Procedimiento y timestamps en `docs/BLOQUE4-RESULTADOS.md`; evidencia cruda en
`build/block4_web/results.jsonl` y `verify.log`. Es ejecución del servicio en
Chrome real, no solo compilación. El lanzador de QA no automatiza el menú de
exportación ni el diálogo de descarga. El ejecutor de `flutter test` en Chrome
sigue sin completar y no se contabiliza como prueba aprobada.

## Hallazgo fuera del alcance

El PDF sigue sin representar las sombras de `slotsOccupiedByNeighbors` (C-5b).
En las siete bahías sin carga propia la rejilla aparece sin contenedores;
la pantalla sí marca los huecos ocupados por un 40 pies vecino. Es un defecto
preexistente distinto de C-2/C-4: se registra y no se corrige de paso. Este cierre
afirma igualdad de **rejilla declarada**, no paridad visual completa del PDF.

Revisión posterior: `bay_plan_view.dart:814-815` consulta el conjunto y su celda
dibuja `40'` cuando no hay contenedor propio; el PDF solo consulta su mapa de
contenedores propios y no usa ese conjunto en ningún punto. En A01 se ve
especialmente en 005, 013, 015, 035, 039, 043 y 045, sin carga propia. También
puede afectar huecos de bahías que sí tienen carga propia.

Alcance propuesto para la corrección independiente: representar y rotular los
huecos ocupados por vecinos con la misma prioridad que pantalla (carga propia
primero), incluirlos en la leyenda y comprobarlo contra A01. No sumar sombras
como contenedores nuevos ni alterar peso, tabla o conteo de páginas. Falta
implementar esta corrección; no queda cerrada por resolver la ejecución Web.

## Archivos

- `lib/features/vessel/data/services/pdf_report_service.dart`
- `tool/t52_corpus_pdf_test.dart`
- `tool/verify_t52_pdf.py`
- `docs/T52-RESULTADOS.md`

PDF y renders son evidencia local regenerable; no se incluyen en Git.
Sin cambios en pubspec.yaml, pubspec.lock, credenciales ni instrumentación H5.
