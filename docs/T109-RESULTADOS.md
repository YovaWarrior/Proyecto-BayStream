# T-109 · Estadísticas a 360 dp y guion de la política

Capitán Codex · 18-oct-2026 · Implementación, Windows y Web verificados.
Sin commit; Honor y aceptación de Timonel pendientes.

## Procedencia y control

Copia aislada `%TEMP%\baystream-t109-25b3efd\head-verified`: nueva extracción
UTF-8 del `git archive` de HEAD `25b3efd9fa860605a1e40e9a7788d212d19e24cf`,
verificada byte a byte. Se superpusieron solo las siete rutas propias de
código/instrumentos T-108, ya verificadas, y las rutas T-109. No incluye cambios
en curso de Timonel ni sus `pubspec.*`, pruebas o instrumentos. Se reutilizaron
la configuración de paquetes instalados y los metadatos de plugins de la copia
anterior, sin `pub get`. Evidencia: `procedencia.json` en el directorio padre.

El piso de HEAD se comprobó antes de T-108: **964/964, analyze cero**.
T-108 terminó en **988/988, analyze cero, corpus 157/157**, con Windows y Web
comprobados antes de iniciar T-109. Se conserva cada evidencia en su carpeta.

El control T-109 definitivo, anterior al cambio de la vista de su copia,
produjo **1 aprobada y 5 fallidas**: referencia de 1280 dp completada y fallos
en las tres condiciones de 360 dp, el detalle de etiqueta larga y el guion.
`control-t109-reference.txt`; referencias en `visual-reference/` de TEMP.

### Hallazgo previo de la vista ancha

Los gráficos de contenedores y de peso por bahía ya se desbordan verticalmente
a 1280 dp: **8 dp** con la fuente habitual de las pruebas y **0.23 dp** al
cargar Roboto. Los dos controles iniciales quedaron sin referencia utilizable
por ese hallazgo (`control-t109.txt`, `control-t109-suite-font.txt`).
La ficha pide conservar la vista ancha. La prueba definitiva de referencia
**imprime y registra** esas incidencias concretas de los gráficos y compara
las imágenes y su extensión; no afirma ausencia de desbordes en esa vista
previa. La captura acotada de esas incidencias se usa únicamente para montar
la referencia de 1280 dp, nunca para la vista de 360 dp. Esta última debe
terminar sin excepciones y con el mismo inventario completo de textos y cifras.
Sin `// ignore` ni pruebas omitidas. El hallazgo ancho se declara, no se corrige
como limpieza adicional.

## Política

`privacy_policy.dart` y el HTML generado contienen exactamente una sustitución
de `re-estibas` por `re‑estibas` (U+2011) cada uno. Se ejecutó el generador
existente `tool/t88_privacidad.dart`. La comparación binaria con las copias
previas confirmó que no cambió ningún otro byte, incluidos finales de línea.

## Cambios y pruebas de la vista

Por debajo de 600 dp, las métricas pasan a una columna con letra grande y
reciben altura suficiente; el estado y la carga especial se apilan. Las barras
horizontales separan etiqueta, cifra completa y barra. Los títulos se parten
en líneas. Las etiquetas abreviadas tienen detalle a un toque y su texto
completo en Semantics. Los números se conservan completos.

El perfil longitudinal tiene desplazamiento horizontal cuando necesita más
espacio con letra grande; no se modifica `vessel_profile_view.dart`. Los dos
gráficos de bahías reciben espacio para ejes y etiquetas a escala grande.
Las ramas anchas conservan su composición y alturas anteriores.

Pruebas dirigidas finales: **6/6** con el archivo real A07 mediante
`--dart-define`, registro `t109-tests-final.txt`. Las tres escalas recorren toda
la vista a 360×780 sin tolerar errores de desborde y comparan el inventario
completo de textos y cifras contra 1280 dp. La prueba de etiqueta larga verifica
el texto accesible y el diálogo al toque. La política comprueba U+2011 y la
igualdad con el generador de HTML.

Los cinco cuadros RGBA de 1280 dp, la extensión de desplazamiento (1900 dp) y
las dos incidencias previas coinciden exactamente con HEAD: `wide-baseline.json`
y `wide-final.json` bajo `visual-reference/`. No se modificó la referencia.

La primera candidata pasó 4/6: faltaba altura en métricas a 2.0 y espacio para
la leyenda del perfil. Se corrigieron solo en la vista de estadísticas. La
siguiente pasó 5/6: el instrumento dejaba vivo su recurso de accesibilidad;
se corrigió su cierre con `finally`, y la corrida final pasa 6/6.

## Validaciones finales

Suite completa final: **994/994**, código 0, sin omisiones, sobre HEAD +
T-108 + T-109 (`suite-t109-final.txt`). A07 y referencia visual por
`--dart-define`; sin pruebas en curso de Timonel.

Corpus final: **167/167**, código 0 (`corpus-t109-final.txt`): 157 casos
de los 36 instrumentos anteriores y 10 cotejos completos contra el lector
de HEAD. No cambió ningún campo previo ni aparece aviso nuevo en el corpus.
Las salidas y los PDF permanecen en TEMP.

Analyze final: **cero incidencias**,
código 0 (`analyze-t109-final.txt`); se añadió el `const` que pidió en
una primera corrida sobre el instrumento nuevo, sin `// ignore`.
Todos los comandos Flutter tuvieron luz verde individual de Carlos.
El Honor no se utilizó hoy por su instrucción y queda pendiente.
`pubspec.yaml` y `pubspec.lock` sin cambios de Codex.


## Windows

Compilación release de `tool/t109_main.dart`: código 0, 258.5 s;
`build-windows-t109.txt`. La precomprobación de reutilización directa del SDK
no encontró su encabezado de versión y terminó antes de ejecutar Flutter.
Se copiaron el ZIP 13.9.0 y el directorio extraído de T-108 a la caché de
compilación T-109: CMake los reutilizó sin otra descarga. No se compartieron
binarios de aplicación. MSBuild conservó las advertencias MSB8029 por estar
en TEMP; no son incidencias de analyze.

Se abrió exclusivamente con `Start-Process explorer.exe -ArgumentList <exe>`.
PID 17528, ejecutable verificado y cerrado por ese PID al terminar.
El padre 22636 ya había salido al consultar su nombre: el JSON lo deja nulo,
sin atribuirle un nombre no observado. Evidencia: `windows-proceso.json`.

Almacén exacto:
`C:\Users\Giova\AppData\Local\Temp\baystream-t109-25b3efd\store-t109`.
Solo cajas `t109_profiles`, `t109_settings`, `t109_voyages`, con sus locks;
`windows-store.json`. No se abrió el almacén real ni el del paquete.

Con A07 se comprobó en la vista real: 398 contenedores, 6940.6 t, 290 llenos,
108 vacíos, 12 reefers y 14 IMO/DG. La geometría propuesta del banco incluye
21 bahías (incluidas las vacías), igual en las tres escalas y en la referencia.
A 1280×780 se conserva la composición ancha; a 600×780, la rama original.
A 360×780 se inspeccionaron 1.0, 1.45 y 2.0: cifras completas, tarjetas en
columna con letra grande, gráficos finales y perfil con desplazamiento
horizontal. A 2.0 se desplazó el perfil hasta la leyenda completa «100 %».

Capturas TEMP: `windows-1280.png`, `windows-600-top.png`,
`windows-600-bottom.png`, `windows-360-145-top.png`,
`windows-360-145-middle.png`, `windows-360-145-bottom.png`,
`windows-360-200-top.png`, `windows-360-200-bottom.png` y
`windows-360-200-profile-left.png` / `windows-360-200-profile-right.png`.
Son comprobaciones del banco con el widget real, sin recorrido integral de
la aplicación ni mediciones de tiempos del producto.

SHA-256 EXE: `6d616e982f37ce6f3db77390f1fd5cd61706f87039f6f4ccbc8a03192b5834ea`.
SHA-256 app.so: `a261363fec09bc43b4198a9e19dfb801326e226de2443dda39a95f6917f2a707`.
`windows-binarios.json`.

## Web

Compilación release del mismo banco: código 0, 54.7 s, con `--no-pub` y
`--no-wasm-dry-run`; `build-web-t109.txt`. Conserva la advertencia de fuente
Cupertino ausente entre los assets, ya observada en T-108. No se modifica
`pubspec.*` ni se agregan dependencias para resolverla.

Servida únicamente en `http://127.0.0.1:8819/`, Chrome visible, namespace
`t109` e IndexedDB del origen local. Se cargó A07 con la API documentada del
selector de archivos del navegador, sin controles nativos de Chrome.
Vista efectiva 1280×780 a escala 1, 600×780 a escala 1 y 360×780 a escalas
1, 1.45 y 2. Se comprobaron las mismas cifras que en Windows, el recorrido
vertical hasta los gráficos finales, el perfil desplazado hasta «100 %» y
el detalle al tocar «GTSTC». La etiqueta larga sintética y su accesibilidad
se validan en la prueba de widget, no se sustituyen por este caso corto.

Capturas TEMP: `web-1280.png`, `web-600.png`, `web-360-145-top.png`,
`web-360-145-middle.png`, `web-360-145-bottom.png`, `web-360-200-top.png`,
`web-360-200-bottom.png`, `web-360-200-profile-left.png`,
`web-360-200-profile-right.png`, `web-360-200-label.png`.
Se cerró la pestaña propia y el servidor propio por PID 17160;
`web-server-cierre.json`. Sin publicación, cuentas ni inicialización Firebase.

## Alcance y pendientes

Las cinco rutas de código/instrumentos del árbol y la copia coinciden byte a
byte (`t109-source-manifest.json`); la política solo cambia el guion. En la
copia, pubspec, main y los dos archivos congelados siguen iguales a HEAD.
No se tocaron demo17, el almacén real, «PRUEBA T-105» ni trabajo de Timonel.
No hubo Git de escritura ni mediciones TLS de T-98 Fase B.

Quedan el Honor cuando Carlos lo permita y la aceptación de Timonel.
Los desbordes anteriores de los gráficos a 1280 dp están declarados y
preservados; no se afirma cero desbordes para esa referencia previa.

## Archivos exactos de T-109

Modificados:

- `lib/features/vessel/presentation/widgets/voyage_stats_view.dart`
- `lib/core/constants/privacy_policy.dart`
- `web/privacidad.html`

Nuevos:

- `test/t109_stats_test.dart`
- `tool/t109_main.dart`
- `docs/T109-RESULTADOS.md`

`pubspec.yaml` y `pubspec.lock` sin cambios de Codex. Sin dependencias nuevas,
sin cambios a main, reglas, codec, congelados ni archivos de Timonel.

## Git preparado para Carlos

Un commit separado de T-108. No se ejecutó Git de escritura.
Las seis rutas no necesitan `-f`.

```powershell
git add -- lib/features/vessel/presentation/widgets/voyage_stats_view.dart
git add -- lib/core/constants/privacy_policy.dart
git add -- web/privacidad.html
git add -- test/t109_stats_test.dart
git add -- tool/t109_main.dart
git add -- docs/T109-RESULTADOS.md
git commit -m "Sprint 3: Ajusta estadisticas a letra grande en T-109"
git push
```

## Tres líneas para Carlos

Estadísticas a 360×780 con 1.0/1.45/2.0, mismos textos y cifras, sin desbordes.
Referencia de 1280 idéntica; política y HTML con U+2011 como único cambio.
Suite 994/994, analyze cero, corpus 167/167; Windows/Web verificados, Honor pendiente.

## Mensaje para Yov

T-109 implementada después de verificar T-108, sin commit y en otra copia limpia del mismo HEAD.
Seis pruebas nuevas con A07: 360×780 a 1.0/1.45/2.0, sin desbordes ni pérdida de textos o cifras.
Los cinco cuadros de 1280 dp y la extensión coinciden con HEAD; sus dos desbordes previos quedan declarados y preservados.
Política y HTML solo sustituyen el guion de re-estibas por U+2011; HTML igual al generador existente.
Suite final 994/994, analyze cero y corpus 167/167; los diez cotejos no cambian datos ni agregan avisos.
Windows y Chrome comprobados con A07, namespace t109, almacén TEMP/IndexedDB; instancia y servidor cerrados por PID.
No toqué pubspec.*, main, reglas, codec, congelados, demo17, PRUEBA T-105 ni el trabajo de Timonel.
Honor y aceptación de Timonel pendientes; evidencia y Git por seis rutas en docs/T109-RESULTADOS.md.
