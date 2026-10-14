# Fuentes Web servidas por BayStream · T-92

Rutas del motor Flutter 3.38.9, revisión
`587c18f873b8ab57330422bce09047420d9c7f42`:

- Roboto v32: ruta de `engine/canvaskit/fonts.dart`. Licencia Apache 2.0,
  descargada de https://raw.githubusercontent.com/googlefonts/roboto/main/LICENSE.
- Noto Sans Symbols v43: ruta de `engine/font_fallback_data.dart` y petición
  observada durante el arranque. Licencia SIL OFL 1.1, descargada de
  https://raw.githubusercontent.com/google/fonts/main/ofl/notosanssymbols/OFL.txt.
- Noto Sans Symbols 2 v24: ruta del mismo catálogo, solicitada al recorrer el
  plano. Licencia SIL OFL 1.1, descargada de
  https://raw.githubusercontent.com/google/fonts/main/ofl/notosanssymbols2/OFL.txt.

`provenance.json` indica URLs y SHA-256 de originales/servidos (sin modificar).
Las licencias se conservan en esta misma carpeta y cada entrada señala la suya.
La plantilla cambia `fontFallbackBaseUrl`, sin declarar fuentes en pubspec y sin
alterar la tipografía de Android o Windows. CanvasKit usa su copia compilada.

Al actualizar Flutter: inspeccionar esas rutas en el motor instalado, repetir
el inventario completo de la app en ambos temas e incluir las fuentes realmente
solicitadas con licencia y SHA. No descargar el catálogo completo.

Un carácter fuera de las fuentes servidas puede quedar en un recuadro, incluso
con red. Por ejemplo, un emoji escrito en un motivo no está garantizado. Esta
limitación aceptada en la ficha se declara para T-98.
