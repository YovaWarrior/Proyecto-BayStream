# Bloque 7, segunda mitad — T-39, T-40 y T-42

Capitán Codex · Inicio local: 29-sep-2026 · Entrega: 30-sep-2026 · Base: `9bdc79e`.

## Primero: los dos posibles incumplimientos de A03, antes de modificar código

Extracción ejecutada con el parser y `DangerousGoodsValidator` actuales, sin
modificarlos. Archivo real `CORPUS_A03.edi`, SHA-256:
`8795D2F1E34B0A34DD88E0099C33BD524B8C523C0DE1B52140C6B9C4DB8C734C`.
Salida íntegra local: `build/block7b/a03-alerts-before.json`.

| Par | Contenedor | Posición BBBRRTT | ISO / longitud | ONU | Clase DGS | Clase usada desde la tabla ONU |
| --- | --- | --- | --- | --- | --- | --- |
| 1-A | PLNU9223134 | 0020386 | 45G1 / 40 pies | UN1170 | 3 | 3 |
| 1-B | HXTU0749681 | 0030586 | 22G1 / 20 pies | UN0012 | 1.4 | 1.4S; grupo S obtenido del ONU |
| 2-A | PRBU3657820 | 0260184 | 45G1 / 40 pies | UN3085 | 5.1 | 5.1 con riesgo subsidiario 8 |
| 2-B | PLNU7015358 | 0270384 | 22G1 / 20 pies | UN0303 | 1.4 | 1.4G; grupo G obtenido del ONU |

**Par 1.** El motor aplica código 2 («Separated from») a 3/1.4 según
49 CFR §176.83(b), entradas UN1170/UN0012 de §172.101 y tabla para unidades
cerradas sobre portacontenedores de §176.83(f)(3). La separación de referencia
está definida en §176.83(f)(4). El resultado también cita §176.83(a)(6), aunque
este par no añade riesgos subsidiarios. Ambos están en cubierta, tier 86.
El 40 pies de bahía 002 proyecta su huella sobre las impares 001 y 003;
el 20 pies está en 003. Las filas 03 y 05 son contiguas.

**Par 2.** El motor aplica código 2 a 5.1/1.4 y a 8/1.4 según §176.83(b),
incorporando el secundario 8 por §176.83(a)(6). Usa las entradas UN3085/UN0303
de §172.101 y §176.83(f)(3)-(4). Ambos están en cubierta, tier 84.
El 40 pies de bahía 026 proyecta su huella sobre las impares 025 y 027;
el 20 pies está en 027. Las filas 01 y 03 son contiguas.
Además, el resultado declara **grupos no evaluados** para UN3085 (56, 58, 138),
con §176.83(m)(1)-(2); la alerta no resuelve esa compatibilidad adicional.

**Separación que efectivamente calcula la aplicación, igual en ambos pares:**

- Diferencia entre centros longitudinales: `|2−3| / 2 = 0.5` huecos de 20 pies
  (en el segundo par, `|26−27| / 2 = 0.5`).
- Distancia firmada entre bordes longitudinales:
  `0.5 − (40+20)/40 = −1.0`: las proyecciones se solapan un hueco de 20 pies.
  No es una distancia física negativa ni una colisión: las filas son distintas.
- Diferencia transversal: una columna; **cero columnas completas intermedias**.
- Diferencia de tiers: **0**. Ninguno de los pares está apilado en la misma fila.

El algoritmo exige al menos un hueco completo longitudinal **o** transversal
y por eso devuelve dos posibles incumplimientos. **No mide metros reales:** el
EDI y el perfil no aportan el paso entre huecos. Los 6 m longitudinales y 2.5 m
transversales son referencias normativas, no mediciones de estos contenedores.
La geometría empleada en esta reproducción es la propuesta mínima de A03.
Carlos revisó ambos pares en esta sesión y respondió **«alertas validas»**.
Quedan aceptados como alertas de apoyo a la decisión; no se declara que el
plano real incumpla el IMDG.

Los cuatro EQD/LOC/DGS se contrastaron también con el archivo crudo. Las reglas
se contrastaron con la [edición oficial 2024 de §176.83 en GovInfo](https://www.govinfo.gov/content/pkg/CFR-2024-title49-vol2/pdf/CFR-2024-title49-vol2-sec176-83.pdf).
El eCFR vigente no fue accesible; este contraste no certifica vigencia a 2026.
La fuente y las entradas ONU del alcance siguen siendo las documentadas en
`docs/T41-SEGREGACION-FUENTE.md`. No se cambió T-41 para alterar los resultados.

## Estado del bloque

Implementadas T-39, T-40 y T-42. **260 pruebas aprobadas**, partiendo de 237:
23 nuevas y ninguna eliminada ni debilitada. **flutter analyze: cero avisos**.
Sin cambios en `pubspec.yaml` ni `pubspec.lock`, sin dependencias nuevas.
No se tocaron Firebase, main.dart ni los dos archivos H5 congelados.

### Comportamiento

- T-39 usa `reeferSlotsOrigin`, independiente del origen general del perfil.
  Toma ausente en inventario declarado: error/posible incumplimiento.
  Propuesta o plantilla: aviso/no evaluado, con la razón explícita; una cota
  inferior no demuestra ausencia de enchufe. Sin posición válida también
  queda no evaluado. Una toma presente o carga seca no dispara esta regla.
- T-40 reutiliza `neighborOccupiedSlots()` para proyectar la huella de la
  bahía par sobre sus dos impares. Busca la carga inferior ocupada más cercana
  en la misma fila y zona; no cruza cubierta/bodega ni repite el aviso por cada
  20 adicional sobre otro 20. Incluye 45 pies y muestra la longitud real.
  Es posible incompatibilidad de apoyo: no presume equipos especiales que el
  archivo no declara. Solo compara tamaños/posiciones conocidos y cubiertos.
- T-42 reúne peso, tomas, apilamiento y segregación con el contrato existente.
  Orden: error, aviso, información; desempates estables. Los no evaluados
  conservan razón y contador separado. Todas las tarjetas usan el mismo tono
  del tema con distinta intensidad y llevan la severidad escrita.
  Cada posición tiene acceso propio al plano; tocar la tarjeta usa la primera.
  Limpia filtros, selecciona bahía, abre Bay Plan y desplaza la rejilla para
  revelar la celda resaltada, incluso en bodega o fuera del ancho inicial.

La prueba adicional de actualización detectó un defecto real: Riverpod 3
consideraba igual el viaje si solo cambiaban tomas/origen, que pertenecen al
perfil. `VoyageNotifier.updateShouldNotify` ahora notifica cada instantánea
nueva por identidad. La regresión comprobó aviso → error al declarar el
inventario y desaparición al agregar la toma, sin cambiar geometría ni carga.
También se comprobó que los filtros visuales no ocultan validaciones.

### Corpus real y trazabilidad

Ejecución reproducible: `dart run tool/block7b_corpus.dart DIRECTORIO_CORPUS`.
Salida local completa: `build/block7b/corpus-results.json`.

| Archivo | Contenedores | 20 pies | 40/45 pies | Posiciones reefer | Alertas T-40 |
| --- | ---: | ---: | ---: | ---: | ---: |
| A01 | 977 | 128 | 849 | 50 | 0 |
| A02 | 806 | 116 | 690 | 14 | 0 |
| A03 | 369 | 32 | 337 | 10 | 0 |
| A04 | 979 | 166 | 813 | 71 | 0 |
| A05 | 736 | 190 | 546 | 91 | 0 |
| A06 | 717 | 190 | 527 | 91 | 0 |

Los seis archivos contienen ambos tamaños; ninguno produce un positivo T-40
con esta relación de apoyo. No se inventó un positivo del corpus. Los casos
positivos, ambas mitades de huella, sentido inverso, filas distintas, frontera
personalizada y reconstrucción del viaje se cubrieron en pruebas controladas.
El recorrido de los seis archivos verificó que serializar y reconstruir con
`LocalVesselCodec` conserva los resultados.

Sobre A01, el perfil **de prueba** con geometría que cubre toda la carga,
50 tomas y límite de 75000 kg devuelve **33 excesos de peso**, cero alertas
de tomas/apilamiento y 6 pares conformes únicamente en las reglas de
segregación evaluadas. Al retirar solo la toma `0210804` del inventario de
prueba aparece exactamente una alerta: error si declarado, aviso si propuesto.
Cada resultado íntegro incluye descripción, contenedores y posiciones en JSON.

En Windows y Honor se conservaron los parámetros de pruebas anteriores:
**62500.5 kg**. Con A01 reimportado, ambos mostraron **47 excesos y 6 pares
conformes**, cero no evaluados. Ejemplo visible: pila de bodega 002/01,
FICU2155340 + ZKPU3030825 + GRDU6972450, posiciones 0020108/10/12,
**73452 kg > 62500.5 kg**. Navegar a 0020108 resaltó la celda correcta.
En Chrome, ALFA tenía límite null: cero alertas de peso, respetando la política.

**Límite de aceptación:** estos límites son datos de prueba, y las 50 tomas
proceden de la propuesta del archivo. No son una declaración operativa del
inventario completo de ALFA. Se pidió a Carlos el perfil completo declarado;
no se recibió aún. El funcionamiento con origen declarado está probado, pero
la aceptación final de T-42 contra ese perfil operativo sigue pendiente.
La aceptación de los dos pares A03 sí fue recibida expresamente.

### Clientes: compilación y ejecución

Los tres se compilaron en release. La pantalla nueva se recorrió en Windows,
Honor y Chrome; no se considera compilar equivalente a ejecutar.
Después de corregir `updateShouldNotify`, se recompilaron los tres, se
reinstaló el APK final y se volvió a abrir el panel en cada cliente:
Windows/Honor A01 47/0/6; Chrome A03 2/100/151. Evidencias finales:
`build/block7b/windows-final-panel.png`,
`build/block7b/chrome-final-panel.png` y
`build/recorrido-clientes/bloque7b-final-panel.png`.

SHA-256 de los artefactos finales ejecutados:

- Windows `data/app.so` (código Dart, no el lanzador exe):
  `DF4F123CE8CD689BBB8BA1829CA290AA03E22FD1B59FA9155F2DA96C83D8065B`.
- Android `app-release.apk`:
  `0FCD1D28F1E7CC967BC6B6540180FF45CB7C4462265880312D108A8074169C45`.
- Web `main.dart.js`:
  `804335A59CD09E6D56193F85ACBB415A68EE8B3FAD9DF9E3BE1019F256314A64`.

| Cliente | EJECUTADO en interfaz | Solo compilado |
| --- | --- | --- |
| Windows | Arranque; A03 2/100/151, posibles incumplimientos primero; salto a 0030586; A01 reimportado 47/0/6 y salto a 0020108; datos históricos sin DGS marcados no evaluados | Ningún cliente completo quedó solo compilado |
| Honor X5d | APK instalado con éxito conservando datos; arranque; A03 2/100/151, lectura de razones no evaluadas y navegación a 0030586; A01 real 977/34, panel 47/0/6 y salto a 0020108 | Casos positivos sintéticos T-39/T-40 comprobados en tests, no introducidos como datos operativos del teléfono |
| Chrome | App release local en 127.0.0.1:8786; reapertura de viaje histórico; A01 reimportado 0/0/6 con límite null; A03 reimportado 2/100/151 y salto a 0030586 | Sin prueba operativa con inventario completo declarado de ALFA |

Los conteos de las filas anteriores significan posibles incumplimientos /
no evaluados / conformes en reglas evaluadas. Chrome inicialmente mostró el
build anterior por el service worker; se recargó hasta ver el nuevo acceso
«Alertas de estiba» y ejecutar su navegación. Los viajes anteriores a T-41 sin
lista completa DGS quedaron correctamente como no evaluados; reimportarlos
recuperó las evaluaciones. No se borró el almacenamiento para ocultar ese caso.

El build Web emitió un aviso de fuentes Cupertino ausentes y la sugerencia de
Wasm; finalizó correctamente. No se modificaron dependencias para silenciarlo.
El análisis estático final, que es el piso exigido, terminó en cero.

Evidencia local (bajo build/, no se agrega a Git):

- `build/block7b/tests.log`, `analyze.log`, `build-windows.log`,
  `build-web.log`, `build-android.log`, `corpus-results.json`.
- `build/block7b/windows-a03-panel.png`, `windows-a03-position.png`,
  `windows-a01-panel.png`, `windows-a01-position.png`,
  `windows-legacy-no-evaluado.png`, `chrome-a03-panel.png`.
- `build/recorrido-clientes/bloque7b-a03-panel.png`,
  `bloque7b-a03-posicion.png`, `bloque7b-a01-panel.png`,
  `bloque7b-a01-peso-posicion.png`, `bloque7b-honor-no-evaluado.png`.

### Archivos de esta tarea

Modificados:

1. `lib/features/vessel/domain/entities/stowage_validation_result.dart`
2. `lib/features/vessel/presentation/providers/vessel_providers.dart`
3. `lib/features/vessel/presentation/pages/vessel_overview_page.dart`
4. `lib/features/vessel/presentation/widgets/bay_plan_view.dart`

Nuevos:

5. `lib/features/vessel/domain/services/reefer_socket_validator.dart`
6. `lib/features/vessel/domain/services/container_stacking_validator.dart`
7. `lib/features/vessel/presentation/providers/stowage_validation_provider.dart`
8. `lib/features/vessel/presentation/pages/stowage_alerts_page.dart`
9. `test/reefer_socket_validator_test.dart`
10. `test/container_stacking_validator_test.dart`
11. `test/stowage_alerts_page_test.dart`
12. `test/stowage_validation_provider_test.dart`
13. `tool/block7b_corpus.dart`
14. `docs/BLOQUE7B-RESULTADOS.md`

Los cuatro documentos binarios de tesis que ya estaban modificados son ajenos
a esta tarea y quedan fuera del bloque Git. Se creó además la sonda temporal
`build/block7b/inspect_a03.dart` y las evidencias ignoradas anteriores.

### Git para Carlos

Codex no ejecutó Git de escritura. Desde la raíz del repositorio, tres commits
por tarea; el propio informe está autorizado por la excepción de AGENTS.md.
No se necesita forzar ningún archivo ignorado.

```powershell
git add -- lib/features/vessel/domain/entities/stowage_validation_result.dart
git add -- lib/features/vessel/domain/services/reefer_socket_validator.dart
git add -- lib/features/vessel/presentation/providers/vessel_providers.dart
git add -- test/reefer_socket_validator_test.dart
git commit -m "T39 Validar tomas de refrigerados segun su origen"

git add -- lib/features/vessel/domain/services/container_stacking_validator.dart
git add -- test/container_stacking_validator_test.dart
git commit -m "T40 Detectar apilamiento de 20 pies sobre huellas de 40"

git add -- lib/features/vessel/presentation/providers/stowage_validation_provider.dart
git add -- lib/features/vessel/presentation/pages/stowage_alerts_page.dart
git add -- lib/features/vessel/presentation/pages/vessel_overview_page.dart
git add -- lib/features/vessel/presentation/widgets/bay_plan_view.dart
git add -- test/stowage_alerts_page_test.dart
git add -- test/stowage_validation_provider_test.dart
git add -- tool/block7b_corpus.dart
git add -- docs/BLOQUE7B-RESULTADOS.md
git commit -m "T42 Unificar alertas por severidad y navegar a su posicion"
git push
```

### Tres líneas de cambios

T-39 distingue inventario declarado de propuesta/plantilla y actualiza severidad al editar.
T-40 detecta 20 sobre huella de 40/45, respetando la zona y el apoyo inferior.
T-42 reúne las cuatro validaciones y lleva cada alerta a su posición visible en el plano.

### Mensaje para Yov

Yov: Codex implementó T-39/T-40/T-42. Antes de codificar documentó completos
los dos pares A03 y Carlos los confirmó como alertas válidas. Quedaron 260
pruebas (237 + 23), analyze cero, sin dependencias nuevas ni cambios en pubspec.
El panel se ejecutó y recorrió en Windows, Chrome y Honor X5d; el APK final
está instalado. En A01 real, 33 excesos con límite de prueba 75000 y 47 con
62500.5; no se presentan esos límites como especificaciones reales de ALFA.
Los seis archivos tienen 20 y 40/45 pies, sin positivos T-40; los positivos y
sus exclusiones están en pruebas controladas. Se corrigió una invalidación
de Riverpod que dejaba severidad vieja al cambiar solo el origen de tomas.
La aceptación operativa final de T-42 con perfil completo declarado de ALFA
queda pendiente de recibir ese perfil. Informe y Git: docs/BLOQUE7B-RESULTADOS.md.
