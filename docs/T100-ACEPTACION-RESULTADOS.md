# T-100 · Aceptación cruzada del manual

Capitán Codex · 21-oct-2026 · Entrega de Timonel `f7e38a3`.

**Dictamen: NO PASA, por una captura con datos personales.** Los tres recorridos
funcionales se completaron en el producto del cierre. No se encontraron cuentas,
correos, la pantalla «Nube y cuenta» ni datos del corpus en las 103 capturas. Sin
embargo, `docs/manual/h13-privacidad.png` muestra el nombre completo del responsable
y su localidad: incumple el requisito literal «sin datos personales» de la ficha
de T-100. Que sea el texto público de la política no elimina esa diferencia.

El impedimento es documental y acotado; no es un fallo de los tres procedimientos
de la app. Para cerrar la aceptación hay que sustituir o encuadrar esa captura y
revisarla de nuevo. Se dejan además tres observaciones de texto y navegación.
Esta aceptación no modifica el manual ni sus imágenes.

## 1. Base, permisos y aislamiento

- Se cumplió primero la aceptación de T-99. `git log --oneline -3` mostró
  `8ee8144` con 10.104 y **10.105**, seguido de `b19744a` y `0cb1c48`.
- Se leyeron los acuerdos, la ficha, las decisiones solicitadas, el manual y
  `docs/T100-RESULTADOS.md`, en particular su sección 8. El alcance es el manual;
  la presentación final queda fuera según 10.99.
- Se reutilizó la copia limpia ya comprobada del cierre
  `sprint3-cierre-2`, **33404a5804be4fad85aab80dd923a7ae9e878ee9**, en
  `%TEMP%\t99acc-33404a5-21oct\app`. El nombre de esa carpeta no identifica el
  namespace de esta prueba: la entrada y el almacén son **t100acc**.
- Se extrajeron de `f7e38a3` los instrumentos `t100_main.dart`,
  `t100_sintetico.dart` y `t100_listado.py` en esa copia. Solo allí se cambió
  `t100` por `t100acc` en la entrada. Los **137 archivos de `lib/`** de la copia
  siguen iguales al cierre; no se trasladó trabajo sin commit del árbol.
- Almacén efectivo de Windows:
  **`%TEMP%\t100acc-33404a5-21oct\store`**, cajas `t100acc_*`. No se abrió el
  almacén real ni se registró en la operación por defecto.
- Compilación propia Windows release con Flutter **3.38.9**, Dart **3.10.8**:

  ```powershell
  flutter build windows --release --no-pub -t tool/t100_main.dart --dart-define=T100_WINDOWS_STORE=C:\Users\Giova\AppData\Local\Temp\t100acc-33404a5-21oct\store
  ```

  Terminó con exit 0. Se conservó **MSB8029**, advertencia nativa por compilar en
  TEMP. SHA-256 del exe: `9025c3bf427f604fde2b99eb033184935f0fcb759d086834c9b5b831a2836b1a`;
  el de `app.so` queda en la evidencia.
- Se omitió `T100_FIREBASE=true`: **Firebase no configurado**, sesión local y
  sincronización exclusivamente local. La entrada usa `LocalSessionRepository`,
  `LocalOnlyOperationSync` y un guard que falla ante acceso remoto. No se abrió
  «Nube y cuenta», se inició sesión ni se usó la consola de Firebase.
- App abierta mediante `explorer.exe`, PID **18232**. Pantalla 1920×1080,
  escala 125 %. El primer recorrido y los de OR y tomas se hicieron maximizados;
  durante la importación estuvo restaurada a una ventana menor y después se
  volvió a maximizar. Estas son pruebas funcionales, no mediciones de RAM ni
  de adaptación a un ancho fijo.
- El manual, el informe de Timonel y sus 103 imágenes —**105 archivos**— se
  cotejaron por SHA-256 contra `f7e38a3`: **0 diferencias**, también al finalizar.

## 2. Escala sintética generada de nuevo

Desde la copia del cierre se ejecutaron los dos comandos pedidos, en este orden:

```powershell
dart tool/t100_sintetico.dart C:\Users\Giova\AppData\Local\Temp\t100acc-33404a5-21oct\sinteticos
python -I tool/t100_listado.py C:\Users\Giova\AppData\Local\Temp\t100acc-33404a5-21oct\sinteticos
```

Las **15 comprobaciones** del generador resultaron verdaderas. Llegada: 60 a
bordo, 30 descargas, cero cargas y 30 de paso en GTSTC. Plan: 60 a bordo, 30
cargas y cero descargas. Mismo BUQUE MANUAL, viaje M100; sin avisos de lectura,
con refrigerados y mercancías peligrosas y geometría suficiente.

| Entrada propia | Bytes | SHA-256 |
|---|---:|---|
| `T100_LLEGADA.edi` | 8021 | `9573cfd78dce494881bcac0e4112f327f66188a92a236bbb298deafd43364d42` |
| `T100_CARGA.edi` | 8009 | `4acf7539a1f26f25a73d56f368c979b2da29dc9a435ef5414c93daca2ab99e68` |
| `T100_LISTADO.xlsx` | 4555 | `feb12a909b7b590f36a58a6b47ce26acac0027839da9d8ba3c1c9aa1367ae073` |

Los hashes coinciden con las entradas declaradas por Timonel. La importación se
hizo desde esos archivos nuevos, no desde su almacén ni desde el corpus.

## 3. Procedimiento 1 · Llegada, descarga y re-estiba (4.3 y 8.1)

1. Se abrió `T100_LLEGADA.edi` y se eligió **GTSTC**, en lugar del PAMIT propuesto,
   antes de confirmar. Se marcó «No lo tengo» para el límite de apilamiento.
2. «Confirmar y ver el plano» abrió **Lista**, tal como advierte 4.4. Se comprobó
   60 contenedores, 30 descargas, cero cargas y 30 de paso. Después se abrió Plano.
3. Se eligió «Contenido» → «Descarga». La bahía inicial 01 solo mostraba sombras
   de 40 pies; se pasó a **bahía 02**, con carga propia, siguiendo la explicación
   de 5.2. Este fue el punto de vacilación del recorrido.
4. Se tocó BAJA en **002-02-82**, contenedor **MNLU0000107**. La descarga quedó
   registrada y la celda pasó a «DESC.».
5. Se tocó PASO en **002-06-04**, contenedor **MNLU0000405**, destino USMSY.
   «Re-estiba» permitió dejar el motivo opcional vacío. Se pulsó «Registrar
   re-estiba» y la celda pasó a «RE-EST.».
6. El resumen y «Pendientes de descarga» coincidieron: **29 pendientes**
   —5 en cubierta y 24 en bodega—, **1 descargado y 1 re-estiba**. En bahía 02:
   9 pendientes, 1 descargado y 1 re-estiba.

**Resultado funcional: completado.** Evidencias `01` a `06`. No se cambió la
escala después de confirmar ni se provocó el hallazgo conocido de la operación
guardada en otro puerto.

## 4. Procedimiento 2 · Listado y carga por OR (8.5 y 8.1)

1. Se abrió `T100_CARGA.edi`, se revisó GTSTC y se confirmó la geometría. Lista
   mostró **0 descargas, 30 cargas y 30 de paso**, y «Listado de la agencia».
2. «Elegir listado (.xlsx)» leyó el archivo generado. Aparecieron **30 filas en
   dos agencias**, 20 llenos y 10 vacíos; agencias de 22 y 8 filas. El aviso de
   «TOTAL 30 CONTENEDORES» en la fila 39 es el previsto en 8.5.
3. Se revisaron las equivalencias propuestas: **40ST → 42G1** (11 contenedores),
   **40HC → 45G1** (15) y **40RF → 45R1** (4), más cuatro códigos iguales.
4. Cruce: **20 de 20 llenos**, **0 contenedores del plan ausentes del listado**
   y **10 de 10 vacíos en siete grupos**. «Confirmar e importar» guardó las
   30 filas en la operación de GTSTC.
5. En Plano → Carga se abrió «OR / últimos dígitos». Escribir **25** dejó
   únicamente **OR 25 · MNLU0000690**, como indica el manual.
6. Al elegirlo apareció «Confirmar carga», **002-01-82**, lleno 45G1, USHOU,
   MNB. Se dejaron vacíos los campos opcionales. La celda seguía ocupada por
   **MNLU0000093**, que baja aquí: la app ofreció **«Marcar su descarga y cargar»**.
   Se siguió esa variante documentada en 8.1, con la salvedad de que el texto la
   sitúa en el párrafo de vacíos aunque este OR es un lleno.
7. Se registraron ambos movimientos. La celda quedó **OR 25 / CARG.**, con el
   aviso «Descarga y carga registradas · OR 25». Quedaron **29 cargas pendientes**
   —19 llenos y 10 vacíos— y **28 descargas pendientes** —4 en cubierta y 24
   en bodega—. Avance confirmó **2 descargados, 1 cargado, 1 re-estiba y
   0 conflictos**. La descarga adicional es la que liberó la celda del OR 25.

**Resultado funcional: completado, con discrepancia de redacción en 8.1.** El
botón final no fue «Confirmar carga» por la ocupación previa. No se ocultó ese
desvío ni se atribuyó el resultado al ejemplo de OR 7 de otra captura.
Evidencias `07` a `13`.

## 5. Procedimiento 3 · Tomas por rangos (A.5)

1. Se abrió Parámetros → Parámetros del buque y se desplegó «Tomas de
   refrigerado (7)», luego «Cargar por rangos».
2. Se introdujo exactamente el ejemplo de A.5: bahías **`002-010/4`**, filas
   **`01-04`**, niveles **`82`**.
3. «Agregar por rango» mostró **12 tomas nuevas**, **0 ya existentes** y
   **0 descartadas**, con el aviso «Cargar no declara: la casilla de declaración
   no cambia». Se confirmó con «Agregar».
4. La pantalla dijo **«Se agregaron 12 tomas; quedan 19»**, con los códigos
   esperados de 002, 006 y 010, filas 01 a 04, nivel 82. Las otras siete eran
   las propuestas del archivo.
5. **«Declaro este conjunto de tomas para el buque» permaneció desmarcada**.
   No se declaró una dotación real del buque a partir de datos sintéticos.
6. Se guardó con «Confirmar y ver el plano» desde el perfil del viaje abierto.
   Apareció «Parámetros del buque actualizados». Al reabrir, seguían **19
   posiciones propuestas**. La edición de un perfil guardado usa «Guardar
   perfil», como explica 4.5: son dos entradas distintas al mismo editor.

**Resultado funcional: completado.** Evidencias `14` a `17`. No se recorrieron
«Quitar por rango», pegado, declaración real ni edición de tapas: no son los
procedimientos solicitados para esta aceptación.

## 6. Capturas y observaciones para corregir

Se revisaron las **103 imágenes originales**, mediante nueve hojas de contacto
y ampliación de la política de privacidad. Como apoyo se ejecutó OCR local con
`Windows.Media.Ocr`, idioma es-ES, sobre las 103; no se enviaron a un servicio
externo. Se verificaron 70 imágenes Windows de **1920×991** y 33 Honor de
**720×1600** (360×800 dp según el entorno declarado por Timonel).

| Comprobación | Resultado |
|---|---|
| Cuenta conectada, correo o formulario de autenticación | No observado |
| Pantalla «Nube y cuenta» | Ninguna |
| Datos operativos del corpus | No observados; se ven T99 SINTÉTICO/SNTU, BUQUE MANUAL/MNLU y BUQUE PRUEBA de T-98 |
| Datos personales, requisito de la ficha | **No cumple:** `h13-privacidad.png`, nombre completo y localidad del responsable |
| Integridad de originales | 105 archivos cotejados con `f7e38a3`, 0 diferencias |

El indicador OCR «iniciar sesión» de `h13` proviene de la explicación de uso
sin cuenta, no de una sesión abierta. La observación personal se comprobó
visualmente a tamaño completo. No se reproduce aquí el nombre completo.

| Hallazgo | Efecto y corrección propuesta, sin ejecutarla |
|---|---|
| **Bloqueante:** datos personales en `h13-privacidad.png` | Sustituir o encuadrar la imagen para conservar la explicación de privacidad sin el nombre completo y la localidad. Volver a verificar esa captura antes de cerrar T-100 y pasarla a Word. |
| 8.1 presenta la descarga previa dentro de «Un vacío» | El mismo aviso aparece con el lleno OR 25. Explicarlo como condición de celda ocupada aplicable también a llenos y citar el botón alternativo en el paso de confirmación. |
| 4.4 dice que los archivos de esta edición «no tienen descargas» | La llegada sintética sí tiene 30. Cambiar la razón por la ausencia de cargas y descargas simultáneas en la misma escala que obliguen a elegir tipo. El propio paso 4 y el informe de Timonel ya describen esa condición correctamente. |
| En 8.1 falta una indicación inmediata para las bahías sin carga propia | Se llega a bahía 01 con sombras y no hay BAJA ni PASO que operar. Añadir «elige una bahía con carga propia; en el ejemplo, 02», o remitir allí mismo a 5.2. La explicación ya existe en ese capítulo. |

Los puntos conocidos «Confirmar y ver el plano» → Lista y las acciones plegadas
están advertidos en el manual y permitieron continuar. No se convirtieron en
fallos nuevos. Las animaciones de las ventanas y los intentos fallidos de pegar
texto con la herramienta fueron incidencias del control: se refrescó el estado
y se usó el teclado para OR y rangos; no son hallazgos de producto.

## 7. Validaciones, evidencia y estado final

Se ejecutaron los dos generadores, sus 15 comprobaciones, la compilación release,
los tres recorridos manuales, la reapertura del perfil, la revisión visual/OCR de
103 capturas y el cotejo de hashes. No se ejecutaron otra suite, análisis global,
pruebas de nube, dictado ni exportación para esta aceptación. Los recorridos de
Timonel en Honor se revisaron como evidencia, no se presentan como una repetición
propia; el Honor no se usó.

Las **266 huellas protegidas** tomadas antes de las aceptaciones siguen sin
diferencias al final: `lib/`, `test/`, `pubspec.*`, acuerdos y configuración local
protegida. **No cambian `pubspec.yaml` ni `pubspec.lock`** del repositorio.
Manual, capturas originales, informes e instrumentos de Timonel permanecen intactos.

**Archivo versionable creado por esta aceptación:**
`docs/T100-ACEPTACION-RESULTADOS.md`. El otro archivo versionable de esta sesión es
el informe independiente de T-99. Ningún archivo ajeno entra en los bloques Git.

Evidencia propia local, **ignorada por `/build/`**, en `build/t100acc/`:

- 17 capturas JPEG numeradas de `01-escala-llegada.jpg` a
  `17-perfil-reabierto-19-tomas.jpg`;
- `entradas.json`, con hashes y las 15 comprobaciones;
- `revision-capturas.json`, inventario de las 103 imágenes y revisión de privacidad;
- `verificacion-final.json`, aislamiento, binarios, cotejos y resultados del recorrido;
- `MANIFIESTO.json`, lista exacta, tamaño y SHA-256 de los otros 20 archivos.

Los generadores usados, sus salidas, log de compilación, OCR y hojas de revisión
quedan en `%TEMP%\t100acc-33404a5-21oct\`; la copia compilada, en la carpeta
TEMP de T-99 ya indicada. No se fuerza su inclusión en Git. Las capturas de A01
de T-99 están separadas y no forman parte del manual ni de esta revisión de sus
imágenes.

La app de aceptación quedó cerrada, así como la ventana auxiliar propia del
Explorador. No quedan procesos propios de Flutter ni muestreadores activos.
No se modificó el Honor, la resolución ni la escala de Windows. No se ejecutó Git
de escritura ni se publicó o envió nada a terceros.

## 8. Git para Carlos

Este commit registra el dictamen, no una corrección del manual. `--only` evita
mezclar otras rutas preparadas en el índice.

```powershell
git add -- docs/T100-ACEPTACION-RESULTADOS.md
git commit --only -m "Sprint 3: aceptacion de T-100 y hallazgo en captura de privacidad" -- docs/T100-ACEPTACION-RESULTADOS.md
git push
```

## 9. Tres líneas y mensaje para Yov

Se completaron llegada/descarga/re-estiba, listado/carga por OR y tomas por rangos.
Las 103 capturas no muestran cuentas, correos, «Nube y cuenta» ni datos del corpus.
T-100 NO PASA la cláusula sin datos personales por h13; quedan tres ajustes de texto.

> Yov: T-100 queda NO PASA por un punto concreto de su ficha: h13-privacidad.png
> contiene el nombre completo del responsable y su localidad. No encontré cuentas,
> correos, Nube y cuenta ni corpus en las 103 capturas. Los tres recorridos se
> completaron con t100acc en TEMP: 2 descargas (la segunda libera el OR 25),
> 1 re-estiba, 1 carga y 19 tomas sin declarar. Antes de pasar a Word, sustituye o
> encuadra h13 y vuelve a verificarla; además aclara el botón de descarga previa
> también para llenos, corrige la frase «no tienen descargas» de 4.4 y orienta hacia
> bahía 02 en el ejemplo. No modifiqué tu manual, sus capturas ni el producto.
