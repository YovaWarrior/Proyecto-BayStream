# T-132 · El BAPLIE de salida, fiel — Resultados

**Capitán Codex · Carlos Martínez · 2-nov-2026, Guatemala (UTC−6).**
Carpeta única: `C:\Proyectos\baystream-t132`; rama `t132-salida`.
Inicio: **21:25**. Cierre: **21:51** (26 min; aproximadamente 0.43 h). Sin escrituras de Git ni publicaciones.

## 1. Paso 0 y fuentes

- Punta comprobada con `git log --oneline --decorate -1` y `git show --stat HEAD`:
  **687d68d51325c63baef9ebf6e0d3bc9cce2dfe85**, `HEAD -> t132-salida`.
  Ese commit incorpora las decisiones **10.84 a 10.88**. El `git diff --stat`
  inicial no mostró cambios. Nunca se ejecutó `git status`.
- Leídos AGENTS.md, CLAUDE.md, las restricciones vigentes de Sprint 3 y 4,
  las decisiones 10.56–10.61 y 10.84–10.88, H4 y sus correcciones en T122,
  y 3.6 de T127; contrastados con escritor, repositorio, página, entidades,
  lectores de BAPLIE y listado, cruce y pruebas existentes.
- La excepción de carpeta y rama está autorizada en 10.88 y en el encargo
  de Carlos. No se accedió a la carpeta de Timonel.
- `flutter pub get`: **correcto**, con luz verde expresa; terminó a las
  **21:34:52**. Después Carlos autorizó la ventana de validación. Todos los
  comandos Flutter se ejecutaron secuencialmente.
- **pubspec.yaml y pubspec.lock no cambian. Ninguna dependencia nueva.**

## 2. Resultado

1. **Llenos con fila:** parten de los segmentos del plan de carga. Se superponen
   VGM, tara, tipo/estado, línea, POD y POT del listado, sin perder los componentes
   adicionales del EQD, las referencias ni los segmentos no modelados: DGS,
   TMP, LOC+83, FTX, RNG, etc. El POL declarado por el plan se conserva.
2. **Peligrosas:** si difieren clase o conjunto de ONU, cada contenedor tiene
   una elección independiente. Guardar y comparar quedan desactivados hasta
   resolver todas. El dominio también rechaza generar sin resolver: la vista
   previa no contiene un EDI utilizable (`text` vacío). Elegir el plan conserva
   sus DGS completos; elegir el listado cambia clase/ONU conservando los otros
   componentes del DGS correspondiente. Una clase del listado sin ONU no borra
   los ONU ni los otros DGS del plan. Solo listado: se escribe lo disponible y
   se avisa. Solo plan: no se elimina su declaración y se avisa.
3. **Refrigerados llenos:** conservan TMP del plan. Sin TMP, se escribe la
   temperatura del listado. Si ambas difieren, la oficina elige por contenedor,
   igual que en peligrosas. Las temperaturas equivalentes en °F/°C no se
   consideran distintas. Un REEFER TEMP ilegible bloquea con fila y causa.
4. **Bytes:** el repositorio invierte `String.fromCharCodes` y entrega los
   bytes originales al selector, sin `utf8.encode`. Los grupos conservados
   mantienen sus separadores, escapes, tildes y CRLF, no solo sus valores.
   Si cambia únicamente la celda, se sustituye solo LOC+147. Sigue vigente el
   respaldo de llegada de T-82 para declaraciones ausentes del plan de carga.
5. **Codificación de campos nuevos:** se valida el repertorio del UNB antes
   de guardarlos. UNOA, UNOB y UNOC están admitidos. Se informa contenedor,
   OR, fila de Excel, campo, carácter y código Unicode cuando no cabe.
   No hay sustituciones por `?`, truncamientos ni cambios silenciosos de UNB.
6. **Pesos nuevos del listado:** kilos enteros, mitad hacia arriba; por ejemplo,
   `18837.129999999997 → 18837` y `3900.5 → 3901`. Los grupos que se conservan
   del plan mantienen sus pesos originales, conforme a la fidelidad byte a byte.
7. **POT:** las cargas armadas con el listado llevan LOC+13 únicamente cuando
   el POT está informado y es distinto del POD; se retira un LOC+13 anterior
   si el listado no lo justifica.
8. **Filas no cargadas:** todas las filas ausentes de la salida aparecen
   ordenadas por OR, con contenedor y motivo. Se detecta CANCEL y variantes
   del texto CONTENIDO, sin cambiar el lector ni su esquema. Las cancelaciones
   operativas conservan además su lista anterior y su motivo registrado.
9. **Datos actualizados:** la elección se identifica por operación,
   contenedor y declaraciones comparadas. Una revisión que cambia la
   discrepancia invalida la elección anterior. Guardar relee la operación y
   el estado vigentes, como antes; no usa un EDI viejo de la vista previa.

El repertorio UNOC corresponde a ISO 8859-1 en el
[directorio de sintaxis de UNECE](https://unece.org/fileadmin/DAM/trade/untdid/download/r1241.pdf).
El repertorio restringido UNOB, con minúsculas y sus signos adicionales, se
contrastó con la tabla de caracteres de la sección 7.2 del
[manual de implementación Ediel](https://ediel.org/wp-content/uploads/2019/02/Functional-Description-23H-20010507.pdf).

## 3. Validaciones y evidencia

**Solo datos sintéticos; no se leyó ni se copió el corpus real ni evidencia del piloto.**

| Validación | Resultado | Evidencia en build/t132/ |
|---|---|---|
| Resolución de paquetes | Correcta, lock sin diferencias | `01-pub-get.log` |
| Batería inicial T-132 | 33/33 antes de ampliar peligrosas y UNOB hasta el total final | `03-pruebas-nuevas.log` |
| T-82 + T-122 + primeras 34 nuevas | **83/83**, sin omitidas | `09-regresion-y-nuevas.log` |
| Analyze del proyecto entero | **0 incidencias** | `10-analyze.log` |
| Primera suite completa | **1905/1905**, 0 fallas, 0 omitidas | `11-suite-completa.jsonl` |
| Revisión final de salida y página tras conservar el formato ajeno al cambio | **55/55**, 0 fallas | `12-verificacion-final.log` |
| Dominio ampliado con UNOB | **24/24**, 0 fallas | `13-repertorio-unob.log` |
| Suite final, una corrida | **1907/1907**, 0 fallas, 0 omitidas (130.721 s) | `14-suite-final.jsonl`, `resumen-suite-final.json` |
| Analyze final del proyecto entero | **0 incidencias**, proyecto completo (12.5 s) | `15-analyze-final.log` |
| Archivos protegidos y pubspec.* contra HEAD | Iguales, normalizando solo CRLF/LF | `archivos-protegidos.json` |

El piso de esta rama era **1871** (T-127). Se añaden **36 pruebas**:
**24 de dominio/lectura**, **11 de página** y **1 del repositorio con el selector
falso**, que comprueba los bytes realmente entregados al guardado.
No se eliminó ni se omitió ninguna prueba.

Casos cubiertos: DGS completo con ONU distinto y ambas elecciones, clase
sola distinta, varias declaraciones y clase sin ONU; peligrosa solo del
listado; reefer con TMP del plan, solo listado, discrepancia y equivalencia
°F/°C; temperatura ilegible; FTX con tilde, escape y CRLF byte a byte;
caracteres incompatibles con UNOA/UNOB/UNOC; pesos con restos binarios,
mitades y pesos inválidos; POT igual/distinto del POD; cancelados del listado,
sin celda, pendientes y cancelados por oficina; copia de la lista y actualización
que invalida decisiones anteriores.

**Capturas:** 8 PNG de widgets en `build/t132/capturas/`, 360 y 1920 px,
claro/oscuro, letra 1.0/2.0; interacción y ausencia de excepciones verificadas
en las ocho combinaciones. Inspección visual directa de 360 claro letra 2.0 y
1920 oscuro letra 1.0. Son capturas de pruebas Flutter, no de los clientes
instalados. La lista larga se desplaza y los chips se distribuyen con Wrap.

**Ajustes de las pruebas anteriores:** T-82 y T122c1 esperan ahora VGM nuevo
7267 en vez de 7266.59, y el grupo de paso con el formato original en vez de
saltos de línea introducidos. Los pesos de grupos conservados siguen exactos.
T-82 página verifica por clave cada lista: el cancelado figura ahora en dos
secciones, como corresponde; ambas se comprueban sin aflojar el contenido.

**Incidencias de preparación, corregidas:**
- La primera ejecución (`02`) se interrumpió: plataforma FilePicker no
  inicializada en la VM de pruebas y captura pendiente fuera de `runAsync`.
  Se corrigió el arnés; la repetición `03` pasó completa.
- El primer analyze (`04`) mostró tres avisos nuevos, corregidos sin ignores,
  y tres errores por la entrada generada ausente de T-124. Se reconstruyó
  con los generadores existentes: T100 sintético en `%TEMP%`, ese archivo
  como plantilla sintética del generador T99 para 977 y el empaquetador T124
  (registros `05`–`07`). No se usó el corpus A01. La entrada resultante,
  `build/t124/entradas/t124_entradas.dart`, es un prerrequisito ignorado del
  banco existente, no código de producto ni un archivo para el commit.
- La primera regresión (`08`) tuvo dos fallas del buscador de texto de T-82
  (temas claro/oscuro): encontró el OR en las dos listas. Se corrigió para
  comprobar específicamente ambas listas y `09` pasó completa.

## 4. Textos nuevos de la página (rótulos exactos)

Los parámetros entre llaves se reemplazan con los valores de cada fila.

- **Datos por confirmar**
- «Elige el dato válido para cada contenedor. No se puede guardar hasta resolver todas las discrepancias.»
- «OR {or} · {contenedor} · Mercancías peligrosas»
- «OR {or} · {contenedor} · Temperatura del refrigerado»
- **Usar el plan** / **Usar el listado**
- «El plan dice UN 2902; el listado, UN 2903» (ejemplo sintético; se listan todos los ONU diferentes).
- «El plan dice clase {clasePlan}; el listado, clase {claseListado}»
- «El plan dice -18 °C; el listado, -20 °C» (ejemplo sintético).
- **Avisos de la salida**
- «OR {or} · {contenedor}: solo el listado declara mercancías peligrosas. La salida lleva los datos disponibles; verifica la declaración de peligrosas.»
- «OR {or} · {contenedor}: el plan declara mercancías peligrosas y el listado no las declara. Se conserva el DGS completo del plan.»
- **Datos que impiden guardar**
- «OR {or} · {contenedor} · fila {fila} · {campo}: el carácter «{carácter}» (U+{código}) no cabe en {UNB}. Corrige la fila y vuelve a importar el listado.»
- «OR {or} · {contenedor} · fila {fila} · REEFER TEMP: «{valor}» no es una temperatura válida. Usa un número en °C o indica C/CEL o F/FAH y vuelve a importar el listado.»
- «El juego de caracteres {código} del UNB no está admitido para datos nuevos. Pide el plan en UNOA, UNOB o UNOC.»
- **Filas del listado que no cargaron ({cantidad})**
- «OR {or} · {contenedor} · {motivo}»; motivos exactos: «cancelado en el listado», «cancelado en la operación», «sin celda en el plan», «sin celda asignada en el plan» (vacío sin asignar) y «carga no registrada».
- «La operación no tiene un listado de la agencia.»
- «Todas las filas del listado están a bordo en la salida.»
- **Copiar filas no cargadas**
- «Lista de filas no cargadas copiada»

Se mantienen **Cancelados vigentes**, **Copiar cancelados** y **Guardar BAPLIE
de salida**. También «Comparar con la llegada» queda desactivado si la revisión
no está resuelta, para no comparar una salida incompleta.

## 5. Límites y lo que no se ejecutó

- No se compilaron ni se abrieron Windows, Android o navegadores; no se tocó
  el Honor, almacenes locales, Firebase ni las apps instaladas. No se ejecutó
  `flutter test --platform chrome`. La aceptación aquí es de dominio,
  repositorio y widgets, con la suite completa y el analyzer.
- Para datos nuevos se admiten UNOA, UNOB y UNOC. Otros repertorios del UNB
  bloquean con el aviso anterior: no se añadió un codificador de otros
  alfabetos ni se cambió el juego del mensaje. Los bytes originales conservados
  no se recodifican.
- REEFER TEMP numérica sin unidad se interpreta como °C; C/CEL y F/FAH
  explícitos se respetan. Un texto fuera de esas formas se informa y bloquea.
- Las decisiones son de esta página y salida; no modifican fuentes ni se
  persisten/sincronizan. Si se vuelve a abrir la página, se elige de nuevo.
- No se cambió el lector, el listado compartido de T-127 ni las reglas de
  cancelación/carga. Una fila marcada CANCEL ya cargada no se elimina de
  oficio: manda el estado operativo; esta sección reporta las no cargadas.

## 6. Archivos exactos

**Modificados (6):**

1. `lib/features/vessel/domain/services/departure_baplie_writer.dart`
2. `lib/features/vessel/data/repositories/departure_export_repository_impl.dart`
3. `lib/features/vessel/presentation/pages/departure_baplie_page.dart`
4. `test/t82_departure_baplie_test.dart`
5. `test/t82_departure_widget_test.dart`
6. `test/t122c1_salida_sin_fila_test.dart`

**Nuevos (6):**

7. `lib/features/vessel/domain/services/departure_baplie_review.dart`
8. `test/support/t132_fixture.dart`
9. `test/t132_departure_fidelity_test.dart`
10. `test/t132_departure_page_test.dart`
11. `test/t132_departure_repository_test.dart`
12. `docs/T132-RESULTADOS.md` (este informe).

Evidencia generada en `build/t132/`, fuera de Git; no requiere `git add -f`.
El prerrequisito generado de T-124 tampoco se versiona. Los avisos de CRLF de
los registrantes generados de Windows tras pub get no representan diferencias
de contenido en `git diff --stat` y no se incluyen.

**Sin cambios comprobados:** pubspec.yaml, pubspec.lock, lib/main.dart,
latency_test_screen.dart, c3_reconciliation_screen.dart, AGENTS.md, CLAUDE.md,
SPRINT-4.md y README.md. No se modificó ningún otro documento de Carlos.

## 7. Git — solo Carlos lo ejecuta

```powershell
Set-Location -LiteralPath C:\Proyectos\baystream-t132
git add -- lib/features/vessel/domain/services/departure_baplie_writer.dart
git add -- lib/features/vessel/domain/services/departure_baplie_review.dart
git add -- lib/features/vessel/data/repositories/departure_export_repository_impl.dart
git add -- lib/features/vessel/presentation/pages/departure_baplie_page.dart
git add -- test/support/t132_fixture.dart
git add -- test/t132_departure_fidelity_test.dart
git add -- test/t132_departure_page_test.dart
git add -- test/t132_departure_repository_test.dart
git add -- test/t82_departure_baplie_test.dart
git add -- test/t82_departure_widget_test.dart
git add -- test/t122c1_salida_sin_fila_test.dart
git add -- docs/T132-RESULTADOS.md
git commit -m "Sprint 4: T-132, el BAPLIE de salida fiel"
git push -u origin t132-salida
```

## 8. Tres líneas

Los llenos conservan DGS/TMP y segmentos del plan; la oficina resuelve por contenedor los datos distintos antes de guardar.
La salida conserva los bytes originales, redondea pesos nuevos al kilo y usa LOC+13 solo si POT y POD difieren.
Las filas no cargadas se listan y se copian con OR y motivo; 36 nuevas y suite final 1907/1907 sin omitidas, analyze en cero, sin cambios de dependencias.

## 9. Mensaje para Yov

> T-132 implementada en baystream-t132, t132-salida, sobre 687d68d. Los llenos con fila parten del grupo del plan; se conservan DGS completos, TMP y segmentos no modelados. La página exige elegir plan/listado por peligrosa o temperatura discrepante, invalida elecciones si cambian los datos, informa caracteres incompatibles con UNB y copia las filas no cargadas con OR y causa. Guardado por bytes originales, pesos nuevos al kilo y POT distinto del POD. 36 nuevas y suite final 1907/1907 sin omitidas; analyze completo en cero. Sin pubspec.*, congelados, main, Firebase ni Git de escritura. Informe y bloque de Carlos en docs/T132-RESULTADOS.md; evidencia sintética en build/t132/. Falta tu revisión y la aceptación de clientes en la candidata integrada.
