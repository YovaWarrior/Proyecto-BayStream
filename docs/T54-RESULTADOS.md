# T-54 · Formato del límite de apilamiento

Fecha: 28 de septiembre de 2026. Responsable: Capitán Codex.

## Resultado

El editor de parámetros usa un formateador explícito: un valor entero se
escribe sin parte decimal (`75000`), uno fraccionario conserva su precisión
(`62500.5`, `75000.125`) y `null` deja el campo vacío. No se redondea el límite
ni se introduce un umbral. Abrir y confirmar sin editar mantiene el valor y
«Perfil sin cambios».

## Validación ejecutada y límites

- Suite completa **209/209**, incluyendo tres pruebas nuevas de T-54: una del
  formateador y dos del editor con perfil, entero y fraccionario.
- `flutter analyze`: **cero problemas**.
- Sonda del mismo formateador en Dart VM y JavaScript compilado ejecutado con
  Node: ambos devuelven exactamente
  `["", "75000", "62500.5", "75000.125", "12345.6789012345"]` y conservan el
  valor al convertirlo otra vez a número.
- **Honor X5d: APK final instalado y ejecutado.** El perfil ALFA persistido
  muestra `80000`, frente a `80000.0` antes del cambio; mantiene «Perfil sin
  cambios», sus niveles y las 50 tomas. No se alteró ese perfil para la prueba.
- **Windows:** build final compilado y lanzado. La prueba de widgets en Dart VM
  verifica el texto entero y fraccionario y el resultado de confirmar. El
  recorrido visual de la app anterior al ajuste está en el informe T-37; no
  se atribuye a la inspección visual del build final lo probado en widgets.
- **Chrome: Web final ejecutado e inspeccionado por Codex mediante la extensión.**
  En el editor real de ALFA se guardó y reabrió **`75000`**; después se guardó
  **`62500.5`**, se recargó la página y se reabrió el perfil. Ambos valores
  aparecen exactamente así y mantienen **«Perfil sin cambios»** al abrir.
  Se restauró el límite original de ese perfil Web a `null` mediante
  **«No lo tengo»**, se guardó y se verificó otra vez. Las 50 tomas siguen
  propuestas. Evidencia: `build/t37/chrome/t54-entero.png` y `t54-decimal.png`.
  El bloqueo anterior de conexión con Chrome quedó resuelto. El intento
  adicional previo de ejecutar las dos pruebas con
  `flutter test --platform chrome` falló antes de ejecutar casos por faltar
  `test-1.26.3/lib/src/runner/browser/static/host.dart.js` en la instalación del
  SDK; **no se contabiliza como prueba pasada ni como defecto de la app**.

La ejecución del editor en Chrome ya complementa la sonda de JavaScript en
Node; no se confunden ambas evidencias. Permanece la limitación de inspección
visual del build final en Windows, y en Honor se observó el entero persistido,
sin editarlo a un valor fraccionario. No se declara una inspección visual de
ambos formatos en los tres clientes.

Registros locales en `build/t37/`: `t54-vm.log`, `t54-js.log`,
`t54-js-build.log`, `t54-chrome-tests.log`, `tests-final.log`,
`analyze-final.log` y `android-final-profile-limit.xml`.

Reproducción de la sonda:

```powershell
dart run tool/t54_format_probe.dart
dart compile js tool/t54_format_probe.dart -o build/t37/t54.js
node build/t37/t54.js
```

No se cambiaron `pubspec.yaml` ni `pubspec.lock`. Sin dependencias nuevas y sin
cambios en archivos H5, `lib/main.dart` o configuración Firebase.

## Archivos de T-54 y Git para Carlos

Ejecutar después del bloque de T-37. Las rutas enumeran exactamente el cambio
y este informe; no incluir los documentos de tesis ajenos a la tarea.

```powershell
git add -- lib/features/vessel/presentation/formatters/stack_weight_formatter.dart
git add -- lib/features/vessel/presentation/pages/vessel_geometry_page.dart
git add -- test/stack_weight_formatter_test.dart
git add -- test/vessel_geometry_page_test.dart
git add -- tool/t54_format_probe.dart
git add -- docs/T54-RESULTADOS.md
git commit -m "RF-036: unificar el texto del limite de apilamiento"
git push
```
