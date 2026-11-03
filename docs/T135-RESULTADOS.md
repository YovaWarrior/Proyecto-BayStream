# T-135 · El aviso «Archivo "null" cargado correctamente»

Timonel (Claude Code, Opus 5.5), 3-nov, en `C:\Proyectos\baystream-rediseno`, rama `sprint-4`, sobre `15ef04b` (10.96).

## 1. Paso 0

- La punta de `sprint-4` es `15ef04b`, la 10.96. Solo toca `SPRINT-4.md` y `docs/piloto/LISTA-PILOTO.md`.
- Antes de empezar, `git diff --stat -- lib test pubspec.yaml pubspec.lock` no mostraba ninguna línea cambiada.
- `test/t114_fase3_correccion_test.dart` figura como modificado en el árbol, pero solo por el fin de línea (Git avisa «LF will be replaced by CRLF»; no hay diferencia de contenido). No es mío y no lo toqué.

## 2. La causa

Hay tres entradas que confirman un plano en previo:

| Entrada | Llamada | ¿Pasa el nombre? |
|---|---|---|
| «Confirmar» en la banda | `_confirmPreview` → `_askForGeometry(context, fileName: notifier.loadedFileName)` | sí |
| «Parámetros» en el riel de la oficina → «Parámetros del buque» | `_askForGeometry(context)` (línea 168) | no |
| «Parámetros» en «Más» del teléfono → «Parámetros del buque» | `_askForGeometry(context)` (línea 582) | no |

Sin `fileName`, `VesselGeometryPage` no muestra «Archivo: …» y el aviso final interpola `null`. El diálogo de T-130 ya se protegía con `fileName ?? notifier.loadedFileName`. La banda no tenía el defecto, así que la causa es la que se había descrito.

## 3. El cambio

Un solo archivo de `lib/`: `lib/features/vessel/presentation/pages/vessel_overview_page.dart`, en `_askForGeometry` (+5 −2).

```dart
final isEditing = notifier.pendingVoyage == null;
// T-135: «Parámetros» llega sin el nombre; con un previo, es el del
// archivo que se está mirando.
final archivo = isEditing ? fileName : fileName ?? notifier.loadedFileName;
```

- `VesselGeometryPage(fileName: archivo)`: la pantalla muestra «Archivo: <nombre>».
- El aviso final pasa a ser `'Archivo "$archivo" cargado correctamente'`.
- El diálogo de T-130 se queda con su expresión, `fileName ?? notifier.loadedFileName`, por dos motivos:
  - `confirmarAgregarPlan` pide un `String` no nulo, y `archivo` es `String?`;
  - el diálogo solo se abre con un previo (`!isEditing`), y en ese caso las dos expresiones dan el mismo nombre.

  Mi primera versión le pasaba `archivo` y no compilaba (ver 4.2).
- **En la edición** (sin previo), `archivo` es el `fileName` de siempre y el aviso sigue siendo «Parámetros del buque actualizados». No cambia ningún otro texto ni otro archivo de `lib/`.

## 4. La prueba y las corridas

`test/t135_aviso_archivo_test.dart` tiene tres casos con el mismo plano en previo. El plano es un plan de carga recortado del sintético de T-100: BUQUE MANUAL, M100, sale de GTSTC. Lo arman `mensaje`, `Caja`, `celda` e `id` de `tool/t100_sintetico.dart`. Los casos:
- **por la banda**, a 360 × 800;
- **por «Parámetros» en el riel de la oficina**, a 1280 × 800;
- **por «Parámetros» en «Más» del teléfono**, a 360 × 800.

En los tres, la prueba confirma los parámetros como lo hizo Carlos: el puerto propuesto y «No lo tengo» en el apilamiento. Después comprueba cuatro cosas:
- que la pantalla dice «Archivo: T100_CARGA.edi»;
- que el aviso dice «Archivo "T100_CARGA.edi" cargado correctamente»;
- que ningún `SnackBar` contiene «null»;
- que el viaje queda publicado en GTSTC, sin excepciones.

La prueba carga las fuentes del producto (`t117CargarFuentes`) y reduce el movimiento (`disableAnimations: true`); el motivo está en 4.2.

Todas las corridas fueron entre las líneas `SEMÁFORO:`, de 12:50 a 13:10. Las salidas están en `build/t135/`.

### 4.1 Las corridas que valen

| Corrida | Resultado | Registro |
|---|---|---|
| Rojo: la prueba contra el código de `15ef04b` | +1 −2. La banda pasa. Los dos caminos de «Parámetros» fallan por comportamiento: `Found 0 widgets with text "Archivo: T100_CARGA.edi"` | `rojo.txt` |
| Verde: `flutter test`, la suite completa en una corrida | **2100 de 2100**, «All tests passed!», 0 omitidas, 2:08 (2097 + 3) | `suite.txt` |
| `flutter analyze` | **No issues found!**, sin ningún `// ignore:` | `analyze.txt` |

Para el rojo puse en su lugar la versión de HEAD del archivo (`git show HEAD:…`) y corrí solo esta prueba. Después devolví la versión con el arreglo y comprobé con `cmp` que era idéntica byte a byte.

### 4.2 Las corridas que no valen, y por qué

1. **Primer rojo** (`rojo-1-tiempo-agotado.txt`). El caso de la oficina no falló por comportamiento: falló porque `pumpAndSettle timed out` en el inicio a 1280 dp. Desde 840 dp el inicio lleva `BsTravesia`, que se repite sin fin. El caso de «Más» sí falló por comportamiento. Lo encontré con tres corridas de diagnóstico de una copia temporal de la prueba (`diag*.txt`). Esa copia está borrada y no queda en `test/`.
2. **Primera suite** (`suite-1-fallo-de-compilacion.txt`): 51 archivos no compilaron. Yo le había pasado `archivo` (`String?`) al diálogo de T-130, que pide `String`. Lo corregí como dice el punto 3.
3. **Segunda suite** (`suite-2-prueba-sin-ajustar.txt`): 2098 en verde y 2 en rojo, las dos de mi prueba, ninguna por «null»:
   - en la oficina, la misma travesía de antes;
   - en «Más», un desborde de 2,5 px en el menú «Tema» de `parameters_page.dart:32` a 360 dp. Lo provoca la fuente cuadrada de las pruebas, en la que «Seguir al sistema» ocupa 272 px. Ese archivo no lo toqué.

   Con las fuentes del producto y el movimiento reducido, como en `t117_oficina_support` y `t114_candidata_pantallas_test`, salió el rojo y el verde de 4.1.

No compilé clientes ni abrí la app: el comportamiento en Edge, Chrome y el `.exe` queda para la aceptación.

## 5. Archivos

| Archivo | Estado |
|---|---|
| `lib/features/vessel/presentation/pages/vessel_overview_page.dart` | modificado (+5 −2) |
| `test/t135_aviso_archivo_test.dart` | nuevo |
| `docs/T135-RESULTADOS.md` | nuevo (este informe) |

- `pubspec.yaml` y `pubspec.lock` no cambian, y no hay dependencias nuevas.
- No se tocaron `lib/main.dart`, `lib/latency_test_screen.dart` ni `lib/c3_reconciliation_screen.dart`.
- `build/t135/` es evidencia local y Git no la sigue.

## 6. Git (lo ejecuta Carlos)

```bash
git add -- lib/features/vessel/presentation/pages/vessel_overview_page.dart
git add -- test/t135_aviso_archivo_test.dart
git add -- docs/T135-RESULTADOS.md
git commit -m "Sprint 4: T-135, el aviso del archivo cargado sin null"
git push
```

No incluye `test/t114_fase3_correccion_test.dart` ni los archivos de `windows/flutter/` que aparecen modificados en el árbol: no son de esta tarea.
