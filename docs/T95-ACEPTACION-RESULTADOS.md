# T-95 · Aceptación cruzada de Capitán Codex

**Veredicto: EN REVISIÓN únicamente por la comprobación visual Web pendiente.** No encontré defectos de dominio ni diferencias con el cotejo independiente. Windows y Honor pasan las comprobaciones solicitadas. La Web compila, pero el conector disponible solo ofrece el integrado de Codex, no el integrado de Claude autorizado; no se sustituyó por Chrome ni se pidió intervención a Carlos durante el modo siesta.

## Base y aislamiento

16-oct-2026. HEAD `93dc695662686d53cb9a09c161f5d4ae4bb4e896`, con T-95 `6b209f1`. Leídos AGENTS completo, secciones 2, 7 y 8, decisiones 10.55 y 10.59–10.69, fichas T-95/T-85 e informe T95. Copia de 631 archivos versionados extraída con `git ls-files` y `git show`, sin Git de escritura. `.claude/settings.local.json` y nombres de secretos excluidos.

Evidencia y bancos: `%TEMP%\baystream-codex-20261016\`. Producto en `t95cx/`. Namespace `t95cx`, applicationId `gt.cmartinez.baystream.t95cx`; cambios solo en la copia: banco, applicationId y asset externo A07 en pubspec. Ningún archivo del corpus entra al árbol. **pubspec.yaml y pubspec.lock del repositorio no cambian.**

## Validación ejecutada

| Comprobación | Resultado | Registro en TEMP |
|---|---|---|
| Suite de HEAD | 866/866 | `t95-suite-serial.log` |
| Analyze de la copia, con el banco | 0 incidencias | `t95-analyze-serial.log` |
| Búsqueda `// ignore:` en lib, test y tool | sin coincidencias | comando rg |
| Corpus completo, 35 archivos | 147/147 | `t95-corpus.log` |
| Casos nuevos de Codex | 4/4 | `t95-cross.log`, `t95cx/tool/t95cx_probe_test.dart` |
| Python contra las secuencias exportadas | todas las fuentes y 39 puertos; invariantes OK | `t95_raw.py`, `t95-service.json`, `t95-raw-results.json` |
| Compilaciones Windows / APK / Web | 0 / 0 / 0 | `t95-build-*.log` |

Compilaciones con `--dart-define-from-file=C:\Proyectos\baystream-privado\firebase-prod.json`, sin abrir ese archivo. Se conservan las advertencias de MSBuild por TEMP, deprecaciones Android y fuentes Web. No se ejecutó flutter test para Chrome.

## Cotejo independiente

`t95_raw.py` lee directamente el texto de los diez EDI `CORPUS_A*.edi`: separa grupos LOC+147, toma LOC+11 y excluye EQD+CN sin número. No importa Dart, no llama al lector ni al servicio y no usa geometría de BayStream. Interpreta fila/nivel con los últimos cuatro dígitos, nivel ≥80 como cubierta y huellas impares o las dos impares vecinas de una par. Compara sus conjuntos contra una exportación nueva del servicio, por posición y multiplicidad.

- **A07/GTSTC: 114 descargas, 66 cubierta, 48 bodega, 0 por columna.**
- **A07/JMKCT: 6** por columna; **A07/COSPC: 5**; **A01/XXVSL: 66**; **A04/JMKIN: 21**.
- En cada fuente y puerto: cada descarga una vez; cada re-estiba se queda y está sobre una descarga o sobre una tapa retirada; ninguna descarga conserva un obstáculo no declarado como re-estiba. No hubo discrepancias.
- A06 trae LOC+12 y ningún puerto LOC+11: conjunto de puertos vacío, coincide con el producto. No se reinterpretó el lector.
- Con tapas PROVISIONALES, Python también comprueba los obstáculos de las tapas retiradas.

Mis casos sintéticos comprueban ALFA (044 sobre 043/045, 041 aislada y bloqueo contado una vez); vuelta h4/h8, tapa, d4/d8; prioridad por movimientos de muelle y desempate por bahía menor. En el caso real comparo los pasos físicos de siete declaraciones en pares con las 21 copias: iguales y 42 declaraciones unidas. Resultado **114 descargas, 13 re-estibas por tapa, 4 tapas de grúa, 135 a bordo y 148 por muelle**. Primera celda 021/022/023: 76 por muelle. Las tapas son PROVISIONALES, sin atribuirlas al buque.

## Clientes y almacén

**Windows, sin cuenta, mouse:** abierta con Explorer y cerrada por su PID, guardado en `t95-windows-process.json`. Vi la entrada junto a Comparar con otro BAPLIE, el resumen GTSTC 114/0/0 y 114/114, pasos numerados y celda 021/022/023. JMKCT recalcula a 125 descargas, 6 por columna y 131/137. Declaradas las tapas en el banco, muestra 13 por tapa, 4 tapas, 135/148, el paso 21 Tapa T1: quitar y el 22 Re-estiba: sale, por tapa. Evidencias `windows-t95-*`.

**Honor, 360 dp:** 720×1600 y 320 dpi. Encontrado en 1.0; puesto por ADB en **1.45**, autorización expresa del modo siesta, y devuelto a **1.0** al terminar. Revisé GTSTC y JMKCT, luego las tapas, los pasos y las re-estibas por tapa en claro y oscuro. Capturas `honor-t95-light-*` y `honor-t95-dark-*`; XML sanitizado en memoria, sin cuentas ni UID y con descarte de formularios de acceso. No apareció ninguno. Resumen y pasos legibles, sin cortes de glifos. Se reproduce la partición cosmética re-/estibas en el resumen de celda, ya asignada a T-106; no se corrige en esta aceptación.

**Web:** compilación correcta, aceptación visual pendiente. La autorización es para el integrado de Claude. El inventario del conector solo ofreció Chrome, Edge, integrado de Codex y MCP Apps; no se usaron como sustitución. No se inició servidor Web para una sesión que no podía operarse. No se afirma que Chrome esté probado.

**Almacén real Windows:** `C:\Users\Giova\AppData\Local\BayStream`, huellas tomadas fuera del paquete con BAT lanzado por Explorer, con cadena de padres registrada (`powershell → cmd → explorer`). **450 → 462 archivos; los 450 previos idénticos; 0 modificados, 0 borrados, 0 errores.** Los doce nuevos son exclusivamente `vessel_store/t95cx_*` (device, movements, operations, profiles, settings, voyages; hive/lock). `store-t95-before.json`, `store-t95-after.json` y `t95-store-comparison.json`. No se borró nada.

## Guardia SHA-256

Los catorce archivos permanecen byte a byte iguales al comienzo en el árbol; además, los blobs de HEAD coinciden con el padre del commit T-95. Para archivos CRLF, el SHA del árbol puede diferir del blob Git por finales de línea; ambos constan en `t95-guard.json`. Perfil, tapas y su codec JSON sin cambio.

| Ruta | SHA-256 del árbol antes = después |
|---|---|
| `firestore.rules` | `0112510984d9a16364f9752e243999c47306e0bcf82766e380db380e8fe8e60a` |
| `firebase.json` | `9bcfd4d9b5a717bd4f044c0e67440c7a81d9858edb1363cbd2cba695d30852e9` |
| `lib/main.dart` | `c5189b1d8711837a05c68306d424c9fdbcc977ba3bbb6c823089ffe4ca5339d5` |
| `pubspec.yaml` | `1b40e5308d3d1594eafbf48ee578abb73a39dc2e3fe0a4551f0d1ac6956f38ea` |
| `pubspec.lock` | `577d742e04143131bc02a1bbb6c246d298c90396e08f6c9dfe393637a2617f53` |
| `lib/latency_test_screen.dart` | `599310db13a713e82fc0d6a411be2d7757cbc2b803d772c1caa16c471725cdff` |
| `lib/c3_reconciliation_screen.dart` | `3af478364a8c5386e1f921e0142dc4f847594beca00b6743563cb09a8a4112a5` |
| `lib/features/vessel/domain/entities/vessel_profile.dart` | `70f26644caddff4fc2413a133fc3e336ad865ee0cffb4164f428ff2b1f242edf` |
| `lib/features/vessel/domain/entities/hatch_covers.dart` | `321a3787e81a31754ebdee3eebc174b3669ce0ee06e86b066aca462e46fb413d` |
| `lib/features/vessel/domain/entities/vessel_geometry.dart` | `8c3a42ce7788d8315fcb8d9a863e6a5ecede7a7f2df08c91acb5adfba1551915` |
| `lib/features/vessel/data/datasources/local_vessel_codec.dart` | `c7bc2eea8cc2b8eb4b7c2f7d225c95fde17159e65fdb2216a0f79ff02c9d146a` |
| `lib/features/vessel/domain/entities/container_unit.dart` | `6daf61cd1c5eef19711e80fd910b56a63c7412e902594b36f117971de65c32ec` |
| `lib/features/vessel/domain/entities/dangerous_goods.dart` | `b1a5433c5b62df220f597e3bd5ea31aeb5c7a75879a6a66d02e5b0d93b6aeedb` |
| `lib/features/vessel/data/services/baplie_parser_service.dart` | `d34fe7f5d12aabd25119382305315747601d6ac77ac97cfd817911e02ff94b7c` |

## Incidencia de ejecución y repetición

Al revisar las marcas de tiempo al cerrar detecté un error mío: lancé el primer analyze antes de que terminara la suite. Los registros delimitan aproximadamente ocho segundos de solapamiento (13:41:44–13:41:52, Guatemala). No era una ventana de medición, pero incumplió el acuerdo de un comando Flutter a la vez. No se forzó ni se borró ningún bloqueo.

Lo declaré y **repetí las dos validaciones en secuencia**, con los clientes cerrados: primero analyze, **0 incidencias**, y solo al terminar, suite **866/866**, ambos con salida 0. La tabla de validación cita estos registros finales: `t95-analyze-serial.log` y `t95-suite-serial.log`. Se conservan los primeros logs; el corpus 147/147 se ejecutó por separado. La repetición incluye el banco y la prueba independiente en la copia y no modifica el árbol del producto.

## Entrega

Único archivo agregado al árbol: `docs/T95-ACEPTACION-RESULTADOS.md`. Los casos independientes, Python, exportaciones y evidencias permanecen en TEMP. Windows cerrada por PID; Android de aceptación detenida; Honor en 1.0; ningún servidor Web activo de esta tarea. Sin Firebase ni publicaciones.

Comandos para **Carlos**, cuando decida versionar el informe (no los ejecutó Codex):

```powershell
git add -- docs/T95-ACEPTACION-RESULTADOS.md
git commit -m "Registrar aceptacion cruzada de T-95 con Web pendiente"
git push
```

Tres líneas:
- Dominio, cotejo crudo y tapas de T-95 pasan sin cambios al producto.
- Suite 866/866, analyze 0, corpus 147/147; Windows y Honor pasan.
- Web visual pendiente; almacén real solo añade doce t95cx y Honor vuelve a 1.0.

**Mensaje para Yov:** Capitán revisó T-95 (6b209f1) en copia de HEAD 93dc695. Sigue En revisión solo por Web visual pendiente: no estuvo disponible el integrado de Claude autorizado y Carlos dormía. Suite 866/866, analyze 0 sin ignore y corpus 147/147; cuatro casos propios pasan. Cotejo Python independiente sobre EDI crudo coincide en diez fuentes y 39 puertos: A07 GTSTC 114/66/48 y 0 por columna; testigos 6/5/66/21. Tapas PROVISIONALES en pares o copiadas idénticas: 13 por tapa, 4 tapas, 135/148. Windows y Honor 360 dp/1.45 en claro y oscuro muestran resumen, pasos, recalculo JMKCT y tapas. Huella real externa 450→462, todos los previos idénticos y solo doce t95cx_*; catorce SHA protegidos intactos (firestore.rules 01125109…, main c5189b1d…, perfil 70f26644…). Honor termina en 1.0, apps cerradas. pubspec.* sin cambios. Única entrega docs/T95-ACEPTACION-RESULTADOS.md. T-85 se realiza independiente sobre copia nueva de 93dc695, sin esperar commit. Declaro un solapamiento inicial de unos ocho segundos entre suite y analyze: repetidos luego en secuencia, analyze 0 y suite 866/866, con los clientes cerrados.
