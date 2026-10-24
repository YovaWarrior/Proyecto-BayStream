# Concepto «Puente de mando» (22-oct-2026)

Las fuentes de las cuatro mesas del lienzo de diseño que Carlos aprobó (`SPRINT-4.md`, 10.14). Son archivos `.dc.html` del lienzo de Claude: necesitan su motor para verse, así que aquí sirven para leer los valores exactos (colores, medidas, estados y textos). Si están las exportaciones en PNG, esas son la vista.

| Archivo | Mesa | Tamaño | Qué muestra |
|---|---|---|---|
| `Main.dc.html` | Oficina · Plano por bahía (oscuro) | 1440 × 1060 | El riel con la marca, las cifras grandes, la silueta del buque, la bahía 14 dibujada como el ícono, el detalle del contenedor y «En vivo». En el lienzo funcionan «Colorear por» y la selección de celdas. |
| `Muelle.dc.html` | Muelle · Descarga (claro) | 390 × 844 | La banda de la marca, las celdas «Baja», «Hecho» y «Paso», y el aviso con «Deshacer». En el lienzo, tocar «Baja» la registra. |
| `Inicio.dc.html` | Inicio (oscuro) | 1440 × 860 | La ilustración de la grúa y los viajes recientes. |
| `Sistema.dc.html` | Sistema | 1200 × 1100 | Los colores, la tabla reordenada, la letra, el borrador de íconos y dónde vive la marca. |

Notas:
- Todos los datos son sintéticos: BUQUE MANUAL, BUQUE PRUEBA y T99 SINTÉTICO, y números TSTU con su dígito de control.
- Lo que el concepto ilustra pero la app no sabe (10.14): la grúa que mueve cada contenedor («Grúa 2»), la superestructura del buque y los nombres de los equipos. El estado «Bajando» del lienzo es, en la app, la celda que se acaba de mover: dura 1.5 s.
- Los íconos de la mesa «Sistema» son un borrador; los definitivos llegan en el paquete del chat de la nube.
- La letra se carga desde Google Fonts solo en el lienzo. En la app, Plex va empaquetada.
