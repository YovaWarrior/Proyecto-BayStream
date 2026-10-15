# T-103 · Aceptación cruzada

Capitán Codex · 15-oct-2026 · rama `sprint-3`.

## Veredicto

**T-103 pasa la aceptación cruzada sobre `842dcb8`.** Pasan las referencias
históricas propias, las validaciones y los recorridos de Chrome, Windows y Honor.
A06 conserva su aviso al reabrir desde Recientes después de reiniciar cada
cliente. La salida se niega desde una 1.5 como plan o como llegada, con el
mensaje explicativo y sin botón de guardar. Los tres rechazos conservan A06.

Este resultado sustituye el veredicto provisional de este mismo informe, que
había quedado pendiente por el control de interfaz. Se retomó el trabajo cuando
la extensión de Chrome apareció conectada y pudo identificar la URL de la
pestaña. El borde conocido de 10.43 queda documentado y sin corregir.

## Aislamiento y alcance

- Se leyó `AGENTS.md` completo. `git log --oneline -3` mostró `842dcb8`
  (decisión 10.43), `f52570b` y `3696930`. Se leyeron la ficha completa de T-103,
  las decisiones 10.35, 10.41 y 10.43, `docs/T103-RESULTADOS.md` y
  `docs/T86-RESULTADOS.md`.
- HEAD aceptado como objeto de revisión:
  `842dcb8fce4d73f2aada6431974c2925b381013f`. Implementación de T-103:
  `369693051694a87c491780bfc1717314aed9614b`.
- Se extrajeron **562 archivos versionados** del objeto `842dcb8` mediante
  `git show`, conservando sus bytes, a
  `%TEMP%\baystream-t103cx`. No se copiaron archivos del árbol compartido para
  compilar ni probar. `evidence/head-manifest.json` guarda sus SHA-256.
- Carlos confirmó el turno reservado de Flutter y dispositivos. Los comandos
  Flutter fueron secuenciales. No se ejecutó Flutter en el repositorio.
- Las referencias, corpus, assets del banco y salidas permanecen fuera del
  repositorio. No se abrió el archivo privado de definiciones ni
  `android/key.properties`. No se usó la CLI de Firebase, el proyecto H5,
  cuentas ni publicaciones.
- No se corrigió código. Solo se incorpora este informe al árbol compartido.

## Referencias propias

Se escribió `tool/t103cx_reference_test.dart` **solo en la copia temporal**.
Lee cada fuente con el lector seleccionado, serializa el viaje completo y
excluye las claves `id` generadas en la lectura. Las referencias se produjeron
en esta sesión; no se utilizaron los JSON generados por Timonel.

Para cada referencia se sustituyó temporalmente el lector de la copia por los
bytes de su revisión histórica, manteniendo las entidades de HEAD. El lector
de HEAD se restituyó antes de los cotejos y del corpus. La comprobación final
contra el manifiesto no encontró diferencias en ninguna ruta de `lib/` o
`test/` de la copia.

| Referencia | Lector ejecutado | Resultado contra HEAD |
|---|---|---|
| A06 completa | `1b1be4b^` = `780a6088f1f84b13dc43033798cab3b058bfc200` | Sin diferencias con `T103_A06_BEFORE` |
| Nueve fuentes 2.x completas | `0b7f539f292c5166a020b716df0c751159fee1ac` | Nueve de nueve sin diferencias con `T86_BASELINE` |

SHA-256 de las referencias propias, en `evidence/`:

| Archivo | SHA-256 |
|---|---|
| `a06-before.json` | `8030C09A611BC4C5C4C97BCAD2A12EF4475450FDE7D75E28A395D9848F1FAF8C` |
| `nine-before.json` | `326E702B1F20B1AFD6C312A5FA3842A5D0CC59ED522FDEE9414526FB3499F37B` |

La lectura histórica propia de A06 dio **717 contenedores,
10 766 933 kg y 1 DGS**. El cotejo de HEAD y la geometría propuesta confirmaron
**27 bahías**, cero reservas y el aviso. La prueba del corpus que guarda y
reabre A06 en un Hive temporal también conservó el aviso.

Las nueve 2.x cotejadas fueron A01, A02, A03, A03v_VGM, A04, A05, A07, A08 y
A08v_VGM: bahías, contenedores, reservas y metadatos completos sin diferencias,
salvo los identificadores excluidos. Ninguna lleva la marca del aviso.

## Revisión de las cuatro rutas de lib/

1. `features/vessel/data/services/baplie_parser_service.dart`: valida un solo
   UNH anterior a la carga y cinco componentes; añade únicamente el identificador
   exacto `BAPLIE:1:911:UN:SMDG15` al conjunto 2.x. El mensaje de rechazo de
   T-86 se conserva.
2. `features/vessel/domain/entities/vessel_voyage.dart`: añade el identificador,
   el reconocimiento textual de SMDG15 y el getter del aviso. No añade un campo
   persistido ni cambia el JSON de las 2.x.
3. `features/vessel/presentation/widgets/voyage_summary_card.dart`: muestra
   el texto «Versión 1.5, leída con las reglas de 2.x; revisa pesos y peligrosas»
   de forma fija en el resumen, con colores del tema.
4. `features/vessel/presentation/pages/departure_baplie_page.dart`: comprueba
   todas las fuentes BAPLIE, tanto llegada como plan, antes de invocar al escritor.
   Ante SMDG15 devuelve el mensaje explicativo y no construye el botón de guardar.

**Borde de 10.43, confirmado sin corregir:**
`BaplieMetadata.readWithV2Rules` se calcula con **`messageVersion == '1'`**.
Otra 1.x guardada antes de T-86 también mostraría el aviso de la 1.5. Es un
aviso adicional en datos históricos; el lector actual no acepta esa otra 1.x.

La suite ejecutada cubre el rechazo de SMDG10, `t86_smdg31` y `t86_sin_unh`,
conservando el viaje anterior y sin abrir el almacén. Para el archivo sin UNH,
el lector conserva el mensaje tipado de T-86; la pantalla lo traduce al mensaje
de T-89 «Este archivo no parece un BAPLIE…». No se exige a la pantalla un texto
distinto del contrato vigente.

Las dos pruebas de salida, con la 1.5 únicamente como plan o únicamente como
llegada, pasaron: mensaje completo y ausencia de `departure-save`. También se
confirmaron visualmente ambos casos en los tres clientes.

## Validaciones ejecutadas

Horas del 15-oct-2026, Guatemala (UTC−06:00).

| Validación | Hora | Resultado | Registro en `evidence/` |
|---|---|---|---|
| Suite completa | 12:13:41–12:14:35 | **697/697**, código 0 | `suite.log` |
| `flutter analyze` | 12:14:35–12:14:56 | **Cero incidencias**, código 0 | `analyze.log` |
| Referencia propia A06 histórica | 12:14:56–12:15:05 | 1/1 | `a06-before.log` |
| Referencia propia nueve 2.x | 12:15:05–12:15:13 | 1/1, nueve viajes | `nine-before.log` |
| Cotejo HEAD con ambas referencias | 12:15:13–12:15:24 | **12/12**, sin diferencias | `references.log` |
| Corpus completo | 12:15:24–12:16:06 | **118/118 en 32 archivos**, código 0 | `corpus.log` |
| Compilación Web release del banco | 12:16:16–12:16:51 | Código 0 | `build-web.log` |
| Compilación Windows release, reanudada | 12:34:17–12:34:33 | Código 0 | `build-windows.log` |
| Compilación APK release `.t103cx` | 12:34:33–12:36:16 | Código 0 | `build-apk.log` |

El corpus usa `BAYSTREAM_CORPUS_DIRECTORY` con la carpeta externa indicada en
el sprint. No se ejecutó `flutter test --platform chrome`. Las compilaciones
usan `--dart-define-from-file=C:\Proyectos\baystream-privado\firebase-prod.json`
sin abrir ni imprimir el archivo.

Incidencia del envoltorio de validación: después de finalizar el corpus con
código 0 y escribir su resultado, Python no pudo imprimir una flecha Unicode
en la consola CP1252. El fallo ocurrió al mostrar el final del registro,
**después** de `+118: All tests passed!`; no es un fallo de Flutter. El registro
completo y `corpus.result.json` quedaron guardados.

La Web emitió el aviso conocido de fuente CupertinoIcons. Windows emitió
MSB8029 por la ubicación temporal; Android, notas de APIs obsoletas y operaciones
no comprobadas de plugins. La primera construcción de Windows se interrumpió
al cerrar el turno bloqueado de interfaz; la reanudación y la APK finalizaron
con código 0. No se modificaron dependencias de producción.

## Clientes y almacén real

Banco preparado en `tool/t103cx_main.dart`, solo en TEMP, a partir del banco
existente y con namespace propio **`t103cx`**. Añade entradas a la página real
de salida con una fuente 1.5 aislada como plan o como llegada, sin escribir
movimientos. Los assets de A06 y rechazos y el cambio de applicationId a
**`gt.cmartinez.baystream.t103cx`** existen únicamente en esa copia.

| Cliente | A06 y aviso | Rechazos SMDG10 / SMDG31 / sin UNH | Salida desde plan / llegada | Recientes tras reinicio |
|---|---|---|---|---|
| Chrome, extensión conectada, visible | **Pasa:** 717, 27, 10766.9 t; aviso completo; plano dibujado | **Pasan los tres**, conservan A06 y su aviso | **Pasan ambos**, mensaje completo y ningún botón de guardar | **Pasa**, tras recargar la página y abrir A06 guardada |
| Windows, namespace `t103cx` | **Pasa:** mismas cifras y aviso; banco confirma 10766933.00 kg | **Pasan los tres**, conservan A06 y su aviso | **Pasan ambos**, mensaje completo y ningún botón de guardar | **Pasa**, tras cerrar el PID y relanzar con explorer |
| Honor `.t103cx`, 360×800 dp, letra **1.0** | **Pasa:** mismas cifras y aviso; banco confirma 10766933.00 kg; plano dibujado | **Pasan los tres sin red**, conservan A06 y su aviso | **Pasan ambos sin red**, mensaje completo y ningún botón de guardar | **Pasa sin red**, tras force-stop y relanzamiento |

La interfaz presenta el peso redondeado en toneladas; el valor exacto de
**10 766 933 kg y 1 DGS** queda comprobado por la lectura completa propia y el
corpus. En Windows y Honor se observó también el peso exacto en el banco.

**Chrome.** Origen `http://127.0.0.1:8203/`, namespace `t103cx`, sin cuenta.
Se habilitó la accesibilidad de Flutter y se utilizaron los controles reales
del producto. Se guardaron capturas y árboles de accesibilidad propios. La
prueba de Recientes parte de una recarga completa: se entra en BayStream vacío
y se abre el viaje guardado, sin importar otra vez el asset A06.
`document.visibilityState` dio `visible` al confirmar la reapertura.

**Windows.** Ambas aperturas se hicieron con
`Start-Process explorer.exe -ArgumentList <exe>` desde la copia temporal.
Primer PID **36536**, segundo PID **13320**: los dos se cerraron por su PID
después de verificar la ruta del ejecutable. No queda ningún `baystream.exe`.

**Almacén real comprobado:** `C:\Users\Giova\AppData\Local\BayStream`.
Las huellas se tomaron con `.bat` lanzados por `explorer.exe`, fuera de la
vista virtualizada del agente. Cada huella registra la cadena
`powershell.exe ← cmd.exe ← explorer.exe`.

- Las validaciones y el corpus dejaron **328 archivos idénticos**. Se conserva
  `store-after-corpus.json`; al retomar se renovó `store-before.json` y se
  conservó además como `store-before-windows.json`.
- Huella antes de Windows: **328 archivos**, 12:35:06; PowerShell PID 7656,
  cmd PID 29148, explorer PID 36896.
- Huella después de cerrar Windows: **340 archivos**, 12:42:18; PowerShell PID
  16276, cmd PID 29132, explorer PID 33544.
- **Los 328 previos conservan nombre, tamaño y SHA-256.** Los únicos 12 archivos
  nuevos son `vessel_store\t103cx_*`: seis cajas Hive y sus seis `.lock`.
- **`t103cx_movements.hive`: 0 bytes.** No se registraron movimientos.
- `store-comparison.json` contiene la comparación y los hashes de lo nuevo;
  `fingerprint.ps1` y los `.bat` permiten reproducir las huellas fuera del paquete.

**Honor.** Se instaló y abrió únicamente
`gt.cmartinez.baystream.t103cx/gt.cmartinez.baystream.MainActivity`.
ADB confirmó 720×1600 px y densidad 320: **360×800 dp**. La letra fue **1.0**
durante todo el recorrido; no se modificó.

- A06 se importó antes de desconectar; el aviso, los dos casos aislados de
  salida, los rechazos y Recientes tras el reinicio se verificaron sin red.
- Se activó el modo avión y se apagó explícitamente el Wi-Fi. A las **12:42:32**
  y de nuevo a las **12:47:22**: `airplane_mode_on=1`, `wifi_on=0` y
  `ping -c 1 -W 2 1.1.1.1` falló con **`Network is unreachable`, código 2**.
  El ajuste `mobile_data` seguía indicando 1, pero no había ruta de red; no se
  toma ese ajuste como prueba de conectividad.
- Volcados exclusivamente con `adb exec-out uiautomator dump /dev/tty`,
  capturados en memoria y sanitizados antes de guardar o mostrar. El auxiliar
  reemplaza correos y UID; descarta la captura si detecta datos de cuenta.
  No aparecieron cuentas ni diálogos del sistema en los recorridos.
- Se guardó el fotograma del aviso antes de esperar el volcado, para no perder
  el SnackBar. Las primeras capturas de importación y reapertura se adelantaron
  a la transición; se sustituyeron por capturas estables de la pantalla resultante.
- Se cerró la variante con `force-stop`. A las **12:47:37** quedaron restaurados
  `airplane_mode_on=0`, `wifi_on=1`, `mobile_data=1` y `font_scale=1.0`.

**Evidencia propia**, exclusivamente en
`%TEMP%\baystream-t103cx\evidence`: capturas `chrome-*`, `windows-*` y
`honor-*`; árboles de Chrome `.txt`; volcados sanitizados del Honor `.xml`;
huellas y registros `honor-offline.txt`, `honor-offline-final.txt` y
`honor-final.txt`. Capturas principales: `chrome-reabierto.png`,
`windows-reabierto.png`, `honor-reabierto.png`, los tres `*-rechazo-*` por
cliente y `*-salida-plan.png` / `*-salida-llegada.png`.

**Incidencias de herramientas, resueltas:** el control nativo de Chrome no pudo
identificar su URL y detuvo los primeros turnos. Después la extensión apareció
conectada y expuso la pestaña y su URL: se completó el recorrido mediante esa
conexión. En Windows se usaron capturas nuevas para los clics cuando caducaban
las referencias de accesibilidad. Un primer deslizamiento desde el borde del
Honor activó Atrás; se reabrió la prueba y se desplazó la barra desde su interior.
No se cambió código ni se borraron bloqueos para resolver estas incidencias.

**Observaciones sin corregir:** siguen el texto de inicio «Contenido compatible:
BAPLIE 2.x.» y el resumen 0/0/0 de A06 en GTPBR, ya asignados a T-56 en 10.43.
A 360 dp y letra 1.0, «Contenedores» ocupa dos líneas, con la «s» en la segunda;
el aviso de la 1.5 se ve completo. Se registra el detalle visual sin ampliar
esta aceptación a una corrección de textos o diseño.

## Integridad y SHA

Comparación propia de los bytes de Git entre `0b7f539` y `842dcb8`: los siete
archivos protegidos siguientes son idénticos. También se ejecutó
`git diff --stat --ignore-cr-at-eol` entre esas revisiones para esas rutas:
salida vacía.

| Archivo | SHA-256 de ambos objetos Git |
|---|---|
| `firestore.rules` | `0112510984D9A16364F9752E243999C47306E0BCF82766E380DB380E8FE8E60A` |
| `lib/main.dart` | `C5189B1D8711837A05C68306D424C9FDBCC977BA3BBB6C823089FFE4CA5339D5` |
| `pubspec.yaml` | `AADF0A63067B6204C1C3B26BBC8C81E315B540484034B0847A19D9E24FD4DC69` |
| `pubspec.lock` | `577D742E04143131BC02A1BBB6C246D298C90396E08F6C9DFE393637A2617F53` |
| Escritor `departure_baplie_writer.dart` | `05EE91981499215E9981094EE3C3230C00AB98C54F4793B8750880D23E656147` |
| `lib/latency_test_screen.dart` | `599310DB13A713E82FC0D6A411BE2D7757CBC2B803D772C1CAA16C471725CDFF` |
| `lib/c3_reconciliation_screen.dart` | `3AF478364A8C5386E1F921E0142DC4F847594BECA00B6743563CB09A8A4112A5` |

SHA-256 de los binarios propios de aceptación:

| Binario temporal | SHA-256 |
|---|---|
| Windows `baystream.exe` | `92F6F67238441898F990267E6CA016C6B55BBCB494159A82B30B14361A6ADB41` |
| APK `.t103cx` | `DE84BAB385A9FE49B0C4B5EDFE112E39E02E2B640BD3A6A8792D5607D67E5C65` |

Se consignan los hashes de los objetos Git, no de una copia con finales de
línea de Windows. Por ello el hash de `pubspec.yaml` puede diferir del anotado
por Timonel para su copia; la igualdad entre ambas revisiones está comprobada
directamente. `protected-sha.json` conserva el detalle.

**Esta aceptación no modifica `pubspec.yaml` ni `pubspec.lock` del repositorio.** El YAML de la
copia temporal sí añade los assets del banco después de las validaciones.
Las cuatro rutas de implementación, reglas, escritor y congelados H5 no se
editaron en el árbol compartido. No se ejecutó Git de escritura ni comandos
fuera de `log`, `show`, `diff --stat --ignore-cr-at-eol` y `ls-files`.

## Horas

Primer registro horario conservado: **12:12:18**; la lectura inicial de
instrucciones y Git fue anterior y no se cronometró. Hubo un cierre provisional
a las **12:17:55**, seguido del diagnóstico de conexión y la reanudación.
Compilaciones reanudadas: **12:34:17–12:36:16**; Windows cerrado y huella final:
**12:42:18**; Honor cerrado y ajustes restaurados: **12:47:37**; comprobación
final de evidencias e integridad: **12:48:01**.

El servidor HTTP propio (PID 22672) se cerró a las **12:50:20**, al finalizar
la revisión del informe. La pestaña de Chrome de Carlos quedó abierta, sin
recargarla ni cerrarla.

Ventana registrada **≈ 0.60 h**, incluida la espera y los intentos de conexión,
frente a 1.0 h estimada para la implementación de T-103. La aceptación es trabajo
adicional a la implementación de Timonel; no se presenta como una medición de
trabajo activo ni incluye la lectura inicial o la redacción posterior.

## Entrega

Único archivo creado en el repositorio:
`docs/T103-ACEPTACION-RESULTADOS.md`.

Tres líneas:

1. Referencias propias de A06 y las nueve 2.x: sin diferencias contra HEAD.
2. Chrome, Windows y Honor pasan aviso, rechazos, salida y Recientes tras reinicio.
3. Suite 697/697, analyze cero, corpus 118/118 y los 328 archivos previos intactos.

**Mensaje para Yov:** Capitán Codex verificó T-103 sobre una copia exacta de
842dcb8. Pasan 697/697, analyze cero y corpus 118/118 en 32 archivos; A06
coincide con mi ejecución de 1b1be4b^ y las nueve 2.x con mi ejecución de
0b7f539. Confirmé el borde messageVersion == '1' sin corregirlo. Pasan Chrome,
Windows t103cx y Honor .t103cx a 360 dp y letra 1.0: aviso, tres rechazos, salida
negada como plan y como llegada, y Recientes después de reiniciar cada cliente.
El Honor reabre sin red, con Wi-Fi apagado y ping fallido. El almacén real pasa
de 328 a 340 archivos: los 328 previos intactos y solo 12 nuevos t103cx_*, con
movimientos en cero bytes. La aceptación queda completada; informe actualizado
en docs/T103-ACEPTACION-RESULTADOS.md.

Git para Carlos, no ejecutado por Codex:

```powershell
git add -- "docs/T103-ACEPTACION-RESULTADOS.md"
git commit -m "Sprint 3: aceptar T-103 en Chrome Windows y Honor"
git push
```
