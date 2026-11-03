# Revisión corta de T-135 · Capitán Codex

**Dictamen: PASA.** O-134-4 queda corregido: los tres casos pasan; contra el
archivo antiguo, la banda pasa y los dos caminos de Parámetros fallan por
comportamiento. Suite **2100/2100**, sin omitidas, y analyze **cero**. Carlos
confirmó los textos correctos en Windows, Chrome y Edge. No se encontraron
hallazgos nuevos en este cambio. Esta revisión no publica ni modifica producto.

3-nov-2026, hora de Guatemala. Carpeta: `C:\Proyectos\baystream-qa-r4`,
HEAD separado **fd3995177e1a5976e586fad20f7a7215cd753f76**:
«Sprint 4: T-135, el aviso del archivo cargado sin null».

## Paso 0 y alcance

- El historial confirma, en este orden: **fd39951** (T-135), **78c0e3f**
  (decisión 10.97), **a23df58** (aceptación 0.4.2), **15ef04b** (10.96).
- Entre 15ef04b y HEAD, en las rutas de producto, pruebas, herramientas y
  plataformas indicadas por Carlos solo cambian:
  `lib/features/vessel/presentation/pages/vessel_overview_page.dart`
  (**+5 −2**) y `test/t135_aviso_archivo_test.dart` (**182 líneas nuevas**).
- El diff del árbol no muestra cambios de contenido; únicamente emite los
  tres avisos previstos de LF/CRLF de los generados de `windows/flutter/`.
  No se tocaron esos archivos.
- Se leyeron AGENTS.md, CLAUDE.md, la decisión 10.97 y el informe de Timonel
  `docs/T135-RESULTADOS.md`. La instrucción actual de Carlos elige revisar
  T-135 antes de publicar, entre las opciones de la 10.97.
- Git se usó solo para lecturas permitidas; nunca `git status` ni escrituras.
  No se inicializó ni consultó Firebase. No se abrió la app instalada ni se
  accedió al almacén real. El `.exe` del banco lo abre Carlos desde Explorador.

## Revisión del cambio

En `_askForGeometry`, `isEditing` sigue significando que no hay plano en
previo. La nueva variable es exactamente:

```dart
final archivo = isEditing ? fileName : fileName ?? notifier.loadedFileName;
```

Con previo, el nombre explícito tiene prioridad y, si falta, se toma el nombre
del archivo cargado por el notifier. `VesselGeometryPage(fileName: archivo)`
y el aviso final usan ese mismo valor. Esto cubre las dos entradas desde
Parámetros que no pasan nombre y mantiene la banda que sí lo pasa.

En edición, `archivo` sigue siendo el `fileName` recibido antes del arreglo;
el aviso conserva **«Parámetros del buque actualizados»**. El diálogo de
T-130 conserva **`fileName ?? notifier.loadedFileName`**, dentro de `!isEditing`,
sin cambiar el contrato no nullable ni el nombre que recibe.

No hay cambios de dominio, persistencia, Firebase, plataformas, dependencias
ni versión. `pubspec.yaml` y `pubspec.lock` permanecen sin cambios.

## Copias y evidencia

La copia limpia se reconstruyó con `git show` de HEAD: **810 archivos**,
incluida la prueba nueva. La entrada generada T-124 procede de la copia de
la aceptación anterior, SHA-256
`d4384834fb9fc9cb18632b87180a7998cc3f91109edcbd33dbbf9787542d1162`.

La copia del rojo contiene esos mismos archivos, salvo el único archivo de
producto revisado, leído desde **15ef04b**. No se sustituyó ningún archivo
del árbol de aceptación ni de la copia limpia. No lleva datos reales.
Evidencia e instrumental privados: `build/t135rev/`, ignorado por `/build/`.
Después de las compilaciones, los **810 SHA-256 de la copia limpia siguen
idénticos a HEAD**. En la copia roja, la única diferencia sigue siendo ese
archivo y sus bytes coinciden con 15ef04b (`integridad-final.json`).

## Corridas

Las tres autorizaciones individuales de Carlos cubren la suite, el rojo y
analyze, secuencialmente y con líneas SEMÁFORO. Las dos compilaciones r4
también tienen luz verde individual y se ejecutan después de analyze.

| Corrida propia de Codex | Resultado |
|---|---|
| Suite completa de HEAD, una sola corrida | **2100/2100**, cero fallos, cero omitidas; salida 0 |
| Los tres casos T-135 dentro de esa suite | **3/3**: banda, Parámetros del riel y Parámetros de Más |
| Rojo: los tres casos con el archivo de producto de 15ef04b | **1 verde y 2 rojos esperados**, cero omitidas; salida 1 |
| `flutter analyze`, dentro de la copia limpia de HEAD | **Cero incidencias**, salida 0 |

Los dos rojos son exactamente las dos rutas de Parámetros. En ambos, el
fallo es **`Found 0 widgets with text "Archivo: T100_CARGA.edi"`**: ausencia
del texto esperado, no fallo de compilación, tiempo agotado ni desborde.
La banda queda verde contra el código antiguo. El verde de HEAD también
comprueba el aviso con el nombre, ningún SnackBar con null, viaje publicado
en GTSTC y ausencia de excepciones.

La prueba carga las fuentes del producto y desactiva animaciones, como
declara Timonel. Se ejecutó sin adaptarla ni agregar casos propios. Los
resultados son corridas nuevas de Codex, no una transcripción de su informe.
Registros: `suite.log`, `suite-resumen.json`, `rojo.log`, `rojo-resumen.json`,
`analyze.log` y sus respectivos `*-ejecucion.json`, en `build/t135rev/`.

## Comprobación manual

Entrada privada r4 basada en `tool/t100_main.dart` de HEAD; cambia solo el
namespace a **r4**, como en la aceptación. Firebase desactivado. Almacén
Windows explícito en **`%TEMP%\t135rev-r4`**, distinto del banco anterior;
Web en origen local propio. El sintético T-100 conserva su huella original.

Las dos compilaciones desde HEAD terminaron con salida **0** y sus líneas
SEMÁFORO. Windows: FileVersion y ProductVersion **0.4.2+8**; Web:
`version.json`, **0.4.2**, build **8**. No se instalaron ni publicaron.
Salidas conservadas en `build/t135rev/r4/windows/` y `r4/web/`.

El servidor Web escucha solo en **127.0.0.1**, puertos **5945** y **5946**;
el segundo ofrece otro origen limpio para comprobar la banda. Se verificaron
HTTP 200 y versión antes de entregar las rutas a Carlos. El almacén Windows
de esta revisión no existía antes de la prueba manual. Registros de
compilación y versión: `windows-ejecucion.json`, `web-ejecucion.json`,
`windows-version.json`, `web-artefacto.json` y
`manual-servidor-verificado.json`.

Se pidió a Carlos abrir el `.exe` exclusivamente desde Explorador y la Web
en Chrome y Edge, con `T100_CARGA.edi` generado en la aceptación anterior,
SHA-256 **4ACF7539A1F26F25A73D56F368C979B2DA29DC9A435EF5414C93DACA2AB99E68**.
La instrucción es entrar por **Parámetros → Parámetros del buque**, observar
**«Archivo: T100_CARGA.edi»**, confirmar GTSTC y «No lo tengo», y observar
**«Archivo "T100_CARGA.edi" cargado correctamente»**.

Carlos respondió el 3-nov, registrado a las **13:35:27, Guatemala**:
**«Pasan los tres clientes; terminé y cerré el .exe»**, a la pregunta que
nombraba ambos textos, los tres clientes, las rutas de los bancos y el
sintético. Resultado:

| Cliente recompilado desde HEAD | Archivo: T100_CARGA.edi | Aviso con el nombre correcto |
|---|---|---|
| Windows r4, apertura por Carlos desde Explorador | Pasa | Pasa |
| Chrome, Web r4 | Pasa | Pasa |
| Edge, Web r4 | Pasa | Pasa |

Es **testimonio manual de Carlos**, no observación automatizada de pantalla.
La banda está verificada por el caso automatizado tanto en HEAD como contra
15ef04b; Carlos no especificó una repetición manual de la banda y no se le
atribuye. Evidencia: `manual-resultado.json`.

## Entrega

Único archivo previsto para Git: **`docs/t135/revision-codex.md`**.
No cambian código de producto, pruebas, `pubspec.yaml` ni `pubspec.lock`
del árbol de aceptación. Las copias privadas, sus compilaciones y registros
quedan en `build/t135rev/`; el almacén de prueba está solo en TEMP.

Al terminar, se cerraron los dos servidores locales y se comprobó que no
quedan escuchas en **5945/5946** (`cierre.json`). Carlos confirmó el cierre
del `.exe`. No se usó el ayudante de aplicaciones. Firebase no se inició ni
se consultó; no se ejecutaron escrituras de Git ni publicaciones.

Este dictamen cierra **T-135/O-134-4** y no reevalúa las demás reservas ni el
ensayo de la aceptación general de la 0.4.2. El código revisado es **fd39951**;
la comprobación de mezcla de la lista podrá apuntar a ese commit cuando
Carlos y Yov la actualicen.

Bloque para que Carlos lo ejecute desde esta carpeta con HEAD separado;
Codex no lo ejecutó:

```powershell
git add -- docs/t135/revision-codex.md
git commit -m "Sprint 4: revision corta de T-135"
git push origin HEAD:sprint-4
```

Tres líneas:

1. **T-135 PASA**: el nombre se conserva desde Parámetros; edición y diálogo T-130 permanecen iguales.
2. **3/3**, rojo esperado **1 verde/2 rojos**, suite **2100/2100** y analyze **cero**.
3. Carlos confirma Windows, Chrome y Edge; solo se entrega este informe, sin tocar producto ni Firebase.

Mensaje para Yov:

> Yov: T-135 revisada sobre fd39951, PASA. Tres casos verdes, los dos rojos
> de Parámetros contra 15ef04b por nombre ausente y banda verde; suite
> 2100/2100 sin omitidas y analyze cero. Carlos confirmó los dos textos en
> Windows, Chrome y Edge. Bancos cerrados, sin Firebase ni escrituras Git.
> Informe: docs/t135/revision-codex.md. O-134-4 queda cerrado.
