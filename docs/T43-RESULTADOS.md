# T-43 · Analyze en cero y seis dependencias sin uso retiradas

27-sep-2026, Guatemala. Autor: Timonel. TC-01. Sobre `c1199fb`, con el árbol
quieto: Codex estaba fuera de sesión. Git lo ejecuta Carlos.

## Resultado

- **`flutter analyze`: de 49 incidencias a cero.** No se silenció ninguna:
  el diff no agrega ni un `// ignore:` ni un `ignore_for_file`.
- **Seis dependencias retiradas** de `pubspec.yaml`: `riverpod_annotation`,
  `intl` y `cupertino_icons` de producción, y `riverpod_generator`,
  `build_runner` y `mockito` de desarrollo.
- **`pubspec.lock` pasa de 117 a 96 paquetes.** Salen 21 —las 6 directas y 15
  transitivas que solo ellas traían—, no entra ninguno y **ninguna versión
  cambia** en los 96 que quedan.
- **Suite: 202/202**, el mismo número que dejó el bloque 5. No se retiró ni se
  deshabilitó ninguna prueba.
- **Los tres clientes compilan en release:** APK a las 22:49:57, Web a las
  22:51:04 y Windows a las 22:52:07.

**Cambia `pubspec.yaml` y cambia `pubspec.lock`.** Es un retiro, no un
agregado: §2.5 limita agregar dependencias, no quitarlas.

## Las 49 incidencias y cómo se quitó cada una

| Regla | # | Dónde | Corrección | ¿Cambia comportamiento? |
|---|---:|---|---|---|
| `deprecated_member_use` | 34 | 7 archivos de `presentation/` | `.withOpacity(x)` → `.withValues(alpha: x)`, la migración que indica el propio aviso | Ver nota abajo |
| `prefer_const_constructors` | 7 | `voyage_stats_view.dart` | `const` en siete `_SectionTitle` con argumentos literales | No |
| `removed_lint` | 3 | `analysis_options.yaml` | Se quitan `avoid_returning_null_for_future`, `iterable_contains_unrelated_type` y `list_remove_unrelated_type`, retiradas en Dart 3.3 | No: ya no hacían nada. `collection_methods_unrelated_type`, que sigue activa, cubre a las dos de colecciones |
| `curly_braces_in_flow_control_structures` | 3 | `vessel_providers.dart` | Llaves en el `if / else if` que cuenta tamaños | No |
| `unused_import` | 1 | `test/widget_test.dart` | Se quita `package:flutter/material.dart` | No |
| `unnecessary_string_interpolations` | 1 | `voyage_stats_view.dart` | `'${tons.toStringAsFixed(0)}'` → `tons.toStringAsFixed(0)` | No |

**Nota sobre `withValues`.** No hubo que dejar ninguna incidencia sin tocar,
pero esta merece la aclaración. `withOpacity` redondeaba el alfa a 8 bits;
`withValues` lo conserva exacto, y esa pérdida de precisión es justamente la
razón de la obsolescencia. La diferencia es menor que medio escalón de 255:
no se ve en pantalla, y ninguna prueba compara opacidades (se revisó `test/`
y `tool/` antes de cambiar).

**Ninguna incidencia estaba en los archivos congelados de H5 ni en
`main.dart`**, así que no hubo nada que dejar fuera por restricción.

## Las seis dependencias

Antes de quitarlas se comprobó que **nada las usa** en `lib/`, `test/`,
`tool/`, `web/`, `windows/` ni `android/`. No había imports, anotaciones
`@riverpod`, archivos `.g.dart`, mocks, `build.yaml` ni usos de
`CupertinoIcons`. La única coincidencia fue un binario de caché de Gradle,
ajeno al código.

**Efecto medible en lo que se entrega.** La fuente `CupertinoIcons.ttf`, de
257 628 bytes, ya no se empaqueta. El APK release baja de 57 684 140 a
57 570 298 bytes (−113 842), y el manifiesto de fuentes de la Web queda solo
con `MaterialIcons`. Las otras cinco no llegaban al binario: tres son de
desarrollo, y el código que nadie usaba ya lo descartaba el compilador. Su
costo era de mantenimiento y de superficie de dependencias, no de tamaño.

**Para H4:** son 21 paquetes menos en el árbol de dependencias resuelto, sin
tocar una sola línea de funcionalidad.

## Verificación

| Comprobación | Resultado |
|---|---|
| `flutter analyze` | **No issues found** |
| `flutter test` | **202/202** |
| Diff con `--ignore-cr-at-eol` | 12 archivos: 49 líneas agregadas y 225 quitadas (168 del lock); ningún `ignore` |
| `flutter build apk --release` | Correcto, 57 570 298 bytes |
| `flutter build web --release` | Correcto |
| `flutter build windows --release` | Correcto |

Se compiló, no se recorrió la app con el build de T-43. Los cambios de código
son de forma —`const`, llaves, interpolación— o una migración de API sin
efecto visible. La prueba a mano del bloque 5 se hizo sobre `c1199fb`, antes
de T-43, y está en su propio informe.

## Finales de línea

Varios archivos mezclan LF y CRLF, algunos incluso dentro del mismo archivo
(`pubspec.yaml`). Las ediciones conservaron el fin de línea de cada línea
tocada, para que el diff no se llene de cambios que solo son de fin de línea.
El `.gitattributes` pendiente desde agosto lo resolvería de raíz; queda fuera
de T-43.

## Archivos

- `analysis_options.yaml`
- `pubspec.yaml`, `pubspec.lock`
- `lib/features/vessel/presentation/pages/vessel_overview_page.dart`
- `lib/features/vessel/presentation/providers/vessel_providers.dart`
- `lib/features/vessel/presentation/widgets/bay_plan_view.dart`
- `lib/features/vessel/presentation/widgets/container_search_delegate.dart`
- `lib/features/vessel/presentation/widgets/containers_list_view.dart`
- `lib/features/vessel/presentation/widgets/empty_state_widget.dart`
- `lib/features/vessel/presentation/widgets/voyage_stats_view.dart`
- `lib/features/vessel/presentation/widgets/voyage_summary_card.dart`
- `test/widget_test.dart`
- `CLAUDE.md`: la línea base pasa a 0 incidencias y 202 pruebas; decía 49 y
  139.
- `docs/T43-RESULTADOS.md`

Sin cambios en `main.dart`, en los archivos congelados de H5, en Firebase ni
en `.claude/`.
