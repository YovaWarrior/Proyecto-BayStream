# Bloque 5 · T-32 → T-33 → T-34 · RF-036

27-sep-2026, Guatemala. Inicio después de la confirmación de Carlos de que
Timonel terminó de compilar desde el árbol limpio. Git lo ejecuta Carlos.

## Resultado

- T-32: `VesselProfile.cloneFor` exige el buque destino. Copia geometría,
  anclas, frontera, límite y tomas, pero usa la clave/nombre del buque nuevo.
  Ambos orígenes pasan a `template`. Rechaza clonar sobre la misma clave.
  Las listas y el conjunto tienen copias inmutables independientes.
- T-33: tras resolver identidad/homónimos, un buque sin perfil puede usar
  un perfil guardado como plantilla o la propuesta del archivo. Sin perfiles
  guardados no aparece selector. Elegir solo prepara un borrador; ambas
  salidas pasan por Parámetros. Cancelar no guarda ni publica. La resolución
  por nombre de T-25 conserva su diálogo y sus restricciones.
- T-34: acceso «Perfiles guardados» incluso sin viaje abierto. Desde allí se
  edita la misma pantalla de Parámetros. Frontera/anclas y tomas tienen
  secciones desplegables; tomas como chips y entrada BBBRRTT sin duplicados.
  El límite admite decimales y null. Cambiar la frontera reclasifica los
  niveles existentes sin inventar niveles; las anclas no borran carga bajo ellas.
  Si el buque tiene viaje visible, la edición debe cubrir su carga y actualiza
  el plano solo tras guardarse correctamente.

El origen de tomas se mantiene salvo declaración explícita de ese conjunto.
Confirmar geometría no convierte tomas propuestas/heredadas en declaradas.
Editar manualmente una toma de un conjunto propuesto tampoco declara todo
el inventario por accidente. El editor informa el origen vigente.

La presentación lee/guarda a través del contrato y Riverpod. Se reutiliza
`getAllProfiles`/`saveProfile`; no se crea una segunda ruta de persistencia.
Se invalidan los listados tras guardar. Una edición con identidad distinta,
con carga fuera del plano o basada en un perfil que cambió se rechaza.

## Pruebas y regresiones

Suite completa final: **202/202**, ocho pruebas nuevas sobre 194.
Analyze: **49 incidencias**, mismos diagnósticos que la base descontando
desplazamientos de línea. Ninguna aserción eliminada ni prueba deshabilitada.
Las 42 pruebas de `vessel_geometry_test.dart` no se modificaron.

Se extendieron estas dos pruebas de `vessel_geometry_page_test.dart`:

1. **«la propuesta sin tocar no se rotula como corregida»**: ahora incluye
   perfil con anclas 04/84, límite decimal y tomas; comprueba que confirmar
   devuelve los mismos valores, colecciones independientes y `changed=false`.
2. **«al quitar un nivel sí se rotula como corregida»**: además elimina y
   repone una toma, cambiando el orden de inserción. El mismo contenido
   vuelve a «Perfil sin cambios»; quitar un nivel sí modifica el perfil.

Conservan sus aserciones originales. Se amplió cobertura porque el contrato
incluye colecciones y parámetros persistentes nuevos, no porque dejaran de
tener sentido. La comparación usa contenido tanto para listas como para Set.

Las pruebas nuevas cubren identidad/orígenes del clon, independencia mutable,
cancelación del selector, plantilla hasta confirmación, edición sin viaje,
guardar intacto sin cambiar la fecha, cancelación sin escribir, reapertura
real de Hive, identidad inválida, cobertura del viaje y edición obsoleta.
Una regresión adicional cambia la frontera de 80 a 84 y verifica que el nivel
82 pasa a bodega, sin perder niveles ni cobertura. El editor delega esta
clasificación en `VesselGeometry.isDeckTier`, la definición única del proyecto.

## Compilación frente a ejecución, por cliente

| Cliente | Compilado | Ejecutado |
|---|---|---|
| Web | Aplicación habitual release y sonda release | Chrome 154 headless real: clonación, confirmación, edición sin viaje, IndexedDB, recarga y recuperación; PDF A01 dentro de Chrome. |
| Windows | Aplicación habitual debug y sonda debug | Ejecutable nativo, escritura y reinicio de proceso; recuperación del perfil y PDF A01. Además, suite de widgets/dominio sobre VM Windows. |
| Android | Aplicación habitual debug y APK de QA aislado | **Sí se instaló** el APK de QA en Honor X5d NAA-LX3; ejecución, cierre forzado y reapertura, recuperación del perfil y PDF A01. |

La sonda usa parser, entidades, notifier, repositorio y motor reales. Solo
inyecta el contenido del archivo en vez del selector nativo. No automatiza
las pantallas tocando botones ni el menú/diálogo de exportación: los flujos
visibles se comprobaron mediante pruebas de widgets. No se afirma que pasó
`flutter test --platform chrome`, cuyo ejecutor sigue bloqueado.

Ensayo `block5_20260927182926`, A01 real de 977 contenedores:

| Evento | Hora Guatemala, 27-sep |
|---|---|
| Chrome guarda y cierra cajas | 18:30:07 |
| Chrome recupera tras recarga y genera PDF | 18:30:09 |
| Windows recupera tras reiniciar proceso y genera PDF | 18:33:31 |
| Android guarda y cierra cajas | 18:33:47 |
| Android recupera tras force-stop/reapertura y genera PDF | 18:34:33 |

En los tres: dos perfiles; fuente intacta con 50 tomas; clon de otro buque
editado a 51 tomas, origen de tomas `template`, límite null, frontera 78,
anclas 04/80. El viaje del clon reutiliza esos parámetros sin volver a
preguntar. La fuente conserva límite 75 000 y sus parámetros originales.

El primer envío de evidencia de Windows falló porque el receptor de QA no
leía HTTP chunked. Se corrigió el receptor y se reinició el proceso: la
recuperación quedó registrada. No fue un fallo del almacén ni se cambió el
código de producción para superar la prueba.

Android: paquete separado `com.example.baystream.block5qa`, desde copia
temporal con **todas las fuentes de lib verificadas iguales por hash al compilar la sonda**.
Solo la copia cambia identificador/etiqueta y permite el receptor HTTP local
de QA, alcanzado por redirección USB. No reemplazó la app de Timonel ni sus
datos. SHA-256 del APK instalado:
`665400905DE64B47D09273ABCC206EEFBFAB21C67362DFD6025DCA6E0D29EE52`.
Al terminar se detuvieron los clientes de QA y se retiró la redirección USB.

Después de esas ejecuciones se ajustó únicamente el editor visual para delegar
la reclasificación en `isDeckTier` y permitir añadir el nivel 99 cuando
corresponde. Ese ajuste pasó la suite final y las tres compilaciones habituales;
no se reinstaló el APK de QA por ese ajuste de interfaz. Las sondas no usan esa
pantalla; su código de dominio, persistencia y PDF no cambió después de ejecutarse.

## Evidencia y reproducción

- `build/block5-final-tests.log`, `build/block5-final-analyze.log`.
- `build/block5_probe/results.jsonl`: eventos recibidos desde cada cliente.
- `build/block5_probe/*build.log`: compilaciones habituales y sondas.
- PDF por cliente: `build/block5_probe/T53-{chrome,windows,android}.pdf`.
- Procedimiento de validación de PDF: `docs/T53-RESULTADOS.md`.

```powershell
./tool/prepare_block5_probe.ps1 -CorpusPath 'C:\Users\Giova\OneDrive\Documentos\OneDrive\Desktop\Archivos .EDI\Anonimizados\files\CORPUS_A01.edi'
python build/block5_probe/receiver.py
# Otra terminal: la Web se recarga sola tras guardar.
flutter run -d chrome --release --no-web-resources-cdn --web-port=8784 --web-browser-flag=--headless -t build/block5_probe/probe.dart
# Para Windows: ejecutar dos veces, cerrando el primer proceso.
flutter run -d windows -t build/block5_probe/probe.dart
```

Android requiere copia con identificador de QA propio, `adb reverse tcp:8785
tcp:8785`, instalación y dos aperturas separadas por force-stop. No ejecutar
el lanzador con el identificador de producción sobre la app del usuario.
La preparación crea un namespace nuevo y no contiene el corpus en el repositorio.

## Archivos de este bloque

- `lib/features/vessel/domain/entities/vessel_profile.dart`
- `lib/features/vessel/domain/repositories/local_vessel_repository.dart`
- `lib/features/vessel/presentation/providers/vessel_providers.dart`
- `lib/features/vessel/presentation/pages/vessel_overview_page.dart`
- `lib/features/vessel/presentation/pages/vessel_geometry_page.dart`
- `lib/features/vessel/presentation/pages/vessel_profiles_page.dart`
- `test/profile_template_test.dart`
- `test/profile_editor_test.dart`
- `test/profile_loading_page_test.dart`
- `test/vessel_geometry_page_test.dart`
- `tool/prepare_block5_probe.ps1`
- `docs/BLOQUE5-RESULTADOS.md`

**pubspec.yaml y pubspec.lock sin cambios.** Sin dependencias nuevas, cambios
en main.dart, Firebase, archivos H5 congelados ni documentos ajenos. Los
informes antiguos del bloque 4/T-52 ya tenían cambios al comenzar; no forman
parte del bloque de Git de esta entrega.
