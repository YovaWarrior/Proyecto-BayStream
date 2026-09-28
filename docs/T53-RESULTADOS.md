# T-53 · Sombras vecinas y contraste del PDF · RF-025

27-sep-2026, después de T-32 → T-33 → T-34. Contra holgura. Git lo ejecuta Carlos.

## Resultado

El PDF consulta `slotsOccupiedByNeighbors` en cada celda. Cuando falta carga
propia y la posición está tomada, dibuja una sombra gris azulada y `40'`.
La carga propia mantiene prioridad si coinciden ambas marcas. La leyenda
incluye «Vecino de 40 pies». No se agregan contenedores ni se modifica el
modelo, pesos, conteos o tabla.

Vacío mantiene naranja claro; OOG usa violeta más oscuro. Celda y leyenda
comparten constantes, para evitar que vuelvan a divergir. La diferencia de
luminancia relativa medida sobre los colores del PDF es **0.543** (escala
0–1): se distinguen también por claridad. Los rótulos propios se conservan.

## A01 real y PDF inspeccionado

**977 contenedores · 34 bahías · 62 páginas · 1 698 sombras**.

Geometría de QA declarada más amplia que la observada, igual a T-52: 17 columnas
y 16 niveles. No se presenta como especificación técnica del buque real.

Las bahías **005, 013, 015, 035, 039, 043 y 045** muestran sus huecos tomados.
También se comprobaron las sombras en bahías con carga propia. El oráculo
deriva coordenadas directamente de contenedores de 40/45 pies en bahías pares,
sin leer el conjunto de vecinos que usa el renderizador. La revisión Python
extrae cada `40'` del PDF y comprueba su fila/nivel exactos.

La tabla de las páginas 36–62 coincide en texto con el PDF de T-52, descontando
espacios: los contenedores y sus pesos no se duplicaron. Se comprobaron las
34 rejillas declaradas y los márgenes de texto y trazos de todas las páginas.
El caso «contraste» fuerza carga propia y sombra en la misma coordenada:
aparece el contenedor, no la sombra; Vacío/OOG/vecino coinciden con su leyenda.

Se renderizaron e inspeccionaron las 62 páginas de A01 y el caso de contraste
ampliado. Sin desbordes, recortes ni superposición de la leyenda con el plano.

Salidas locales regenerables, fuera de Git:
- `output/pdf/T53-CORPUS_A01.pdf`
- `output/pdf/T53-contraste.pdf`

## Ejecución por cliente

| Cliente | Compilado | Ejecutado y comprobado |
|---|---|---|
| Web | App habitual release; sonda release | Chrome 154 headless genera PDF A01, 295 769 bytes, después de recargar y leer IndexedDB. Verificación de 62 páginas/1 698 sombras/tabla/márgenes aprobada. |
| Windows | App habitual debug; sonda debug | Ejecutable nativo genera PDF A01, 292 556 bytes, después de reiniciar y leer Hive. Misma verificación aprobada. |
| Android | App habitual debug; APK de QA debug | **APK instalado y ejecutado en Honor X5d NAA-LX3**. Tras force-stop y reapertura genera PDF A01, 292 556 bytes. Misma verificación aprobada. |

La ejecución usa `PdfReportService` de producción. No se recorrió manualmente
el menú de exportación ni el diálogo de guardado en esta tanda. El APK de QA
tiene identificador propio: no reemplazó la app instalada por Timonel.
Detalles, timestamps y hash en `docs/BLOQUE5-RESULTADOS.md`.

## Pruebas y reproducción

- Suite completa: **202/202**, sin borrar aserciones anteriores.
- Corpus adicional de T-53: **1/1** (`tool/t53_corpus_pdf_test.dart`).
- Python: aprobado para VM, Chrome, Windows nativo y Android.
- Analyze: **49 incidencias**, sin diagnósticos nuevos.

```powershell
flutter test tool/t53_corpus_pdf_test.dart --dart-define="BAYSTREAM_CORPUS_DIRECTORY=C:\Users\Giova\OneDrive\Documentos\OneDrive\Desktop\Archivos .EDI\Anonimizados\files"
python tool/verify_t53_pdf.py
python tool/verify_t53_pdf.py build/block5_probe/T53-chrome.pdf
python tool/verify_t53_pdf.py build/block5_probe/T53-windows.pdf
python tool/verify_t53_pdf.py build/block5_probe/T53-android.pdf
```

La comprobación independiente requiere pdfplumber/pypdf del entorno de QA
y el PDF previo `output/pdf/T52-CORPUS_A01.pdf` para contrastar la tabla.
No son dependencias de la aplicación.

## Archivos de T-53

- `lib/features/vessel/data/services/pdf_report_service.dart`
- `tool/t53_corpus_pdf_test.dart`
- `tool/verify_t53_pdf.py`
- `docs/T53-RESULTADOS.md`

El lanzador común de los tres clientes se entrega con el bloque 5.
Sin cambios en pubspec.yaml/pubspec.lock, fuentes de Firebase ni archivos
congelados. No se ejecutaron operaciones Git ni publicaciones.
