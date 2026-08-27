# BayStream · Auditoría de seguridad del Sprint 1

**Fecha:** 25 de agosto de 2026 · **Código auditado:** commit `80dde67` (cierre del Sprint 1)
**Marcos aplicados:** OWASP Top 10:2025 (cliente Web) y OWASP Mobile Top 10 2024 (cliente Android)

---

## Nota metodológica: por qué se aplican dos catálogos

BayStream se distribuye en tres clientes desde una sola base de código. Eso significa que **no basta un catálogo**:

| Cliente | Catálogo aplicable | Motivo |
|---|---|---|
| Web (navegador) | **OWASP Top 10:2025** | Aplicación web; el bundle es público y el origen es inspeccionable. |
| Android | **OWASP Mobile Top 10 2024** | El artefacto es un APK instalable; aplican riesgos de binario y almacenamiento local. |
| Windows | Ambos, parcialmente | Escritorio: hereda los riesgos de datos y credenciales, no los de navegador. |

Que el enfoque multiplataforma **duplique la superficie normativa** es en sí un hallazgo relevante para la discusión de la hipótesis H4: el ahorro en esfuerzo de desarrollo no se traslada automáticamente al esfuerzo de aseguramiento.

> **Corrección de versión.** No existe un «OWASP Top 10 2026». La versión vigente del catálogo web es **OWASP Top 10:2025**. La versión vigente del catálogo móvil es **OWASP Mobile Top 10 2024**.

---

## Resumen de hallazgos

| # | Hallazgo | Severidad | Top 10:2025 | Mobile 2024 |
|---|---|---|---|---|
| H-01 | Sin reglas de autorización bajo control de versiones | **Crítica** | A01 | M3 |
| H-02 | Sin autenticación; creación y actualización anónimas | **Alta** | A01, A07 | M3 |
| H-03 | Reglas de prueba **expiradas el 17-ago**: acceso denegado ocho días | **Crítica** | A02 | M8 |
| H-04 | Credenciales de Firebase escritas en duro en el código fuente | Media | A02 | M1 |
| H-05 | Texto crudo de excepciones expuesto en mensajes de interfaz | Baja | A10 | M6 |
| H-06 | Sin registro de eventos ni alertas | Baja | A09 | — |
| H-07 | Sin análisis automatizado de vulnerabilidades en dependencias | Baja | A03 | M2 |

**Controles verificados como adecuados:** validación de entrada del parser BAPLIE (A05/M4), higiene de secretos en `.gitignore` (M1), fijación exacta de la dependencia `pdf` (A03/M2).

---

> ## ⚠️ Corrección del 25 de agosto — leer antes que nada
>
> Esta auditoría se ejecutó **sin poder leer las reglas de autorización vigentes**, porque no estaban en el repositorio. Sus valores se infirieron del comportamiento por defecto de la plataforma. El 25 de agosto se accedió a la consola de Firebase y se comprobó que **dos de las tres inferencias eran incorrectas**. El texto de abajo ya está corregido; se deja constancia del error porque su causa es, en sí misma, el hallazgo H-01.
>
> | Afirmación original | Realidad observada |
> |---|---|
> | «La colección admite **borrado** anónimo» | **Falso.** Las reglas vigentes ya declaraban `allow delete: if false` en ambas colecciones. La operación destructiva nunca estuvo abierta. |
> | «Las reglas de prueba caducan alrededor del **13 de septiembre**» | **Falso.** Caducaban el **17 de agosto** y llevaban **ocho días vencidas**. La sincronización estaba caída, no en riesgo. |
> | «No hay reglas bajo control de versiones» (H-01) | **Confirmado.** Y es precisamente lo que obligó a inferir en lugar de leer. |
>
> **H-01 se demostró a sí mismo.** El hallazgo era que las reglas no eran revisables; la consecuencia directa fue una auditoría con dos errores de hecho. De haber estado versionadas, se habrían leído y el informe habría sido exacto. Ningún argumento teórico sobre la importancia de versionar la configuración de seguridad es tan convincente como este episodio.
>
> **También conviene reconocer lo que la inferencia subestimó:** las reglas existentes ya negaban el borrado y acotaban el acceso a las dos colecciones en uso. Estaban mejor diseñadas de lo que la auditoría supuso.

## Hallazgos críticos, en detalle

### H-01 · Sin reglas de seguridad de Firestore bajo control de versiones

**Evidencia.** No existe ningún archivo `firestore.rules`, `firebase.json` ni `.firebaserc` en el repositorio. Búsqueda ejecutada sobre el árbol completo en el commit `80dde67`.

**Implicación.** Las reglas de acceso a la base de datos —el único control de autorización que tiene la aplicación— viven exclusivamente en la consola de Firebase. No están versionadas, no son revisables, no son reproducibles y no forman parte de ningún despliegue. Si alguien las modifica, no queda rastro en el historial del proyecto.

**Mapeo.** A01:2025 Broken Access Control · M3 Insecure Authentication/Authorization.

### H-02 · Ausencia total de autenticación

**Evidencia.** Cero apariciones de `firebase_auth`, `signIn`, `currentUser` o cualquier equivalente en todo `lib/`. El repositorio accede a la colección directamente:

```dart
_firestore.collection('voyages')
await _voyages.doc(voyage.id).set({...});   // escritura
await _voyages.doc(id).delete();            // borrado
```

**Implicación (corregida).** Cualquier cliente que conozca el `projectId` —que es público, va incrustado en el bundle web— podía enumerar y sobrescribir viajes mientras la ventana de las reglas de prueba estuvo abierta. **El borrado nunca fue posible:** las reglas vigentes ya lo negaban. Esto rebaja la severidad de crítica a alta, porque la operación irreversible estaba cubierta desde el principio.

**Mapeo.** A01:2025 Broken Access Control · A07:2025 Authentication Failures · M3.

**Matiz honesto para la defensa:** la autenticación está **deliberadamente diferida** fuera del alcance del curso (elementos RF-034/RF-035, sprint 10). El hallazgo no es que se haya olvidado, sino que **el diferimiento deja la base de datos sin ningún control de acceso mientras tanto**, y eso sí requiere una mitigación provisional.

### H-03 · Proyecto temporal con reglas de prueba

**Evidencia observada el 25 de agosto.** Las reglas vigentes en la consola declaraban, para ambas colecciones:

```javascript
allow read, create, update: if request.time < timestamp.date(2026, 8, 17);
allow delete: if false;
```

**Implicación.** La ventana de acceso venció el **17 de agosto de 2026**. Al momento de la observación habían transcurrido **ocho días** con toda lectura y escritura denegada. El panel de uso de Firestore lo confirma de forma independiente: cero operaciones de lectura y cero de escritura en el período del 18 al 24 de agosto.

No se trataba, por tanto, de un riesgo futuro. **La sincronización en tiempo real llevaba ocho días inoperante**, sin que nadie lo advirtiera, porque ninguna de las cinco funcionalidades del Incremento 1 —análisis BAPLIE, indicadores de peso, perfil longitudinal, exportación PDF y exportación CSV/JSON— utiliza Firestore.

**Severidad corregida: crítica.** La estimación original de treinta días de ventana, tomada del comportamiento por defecto de la plataforma, resultó ser de tres.

**Mapeo.** A02:2025 Security Misconfiguration · M8 Security Misconfiguration.

**Estado: resuelto.** Las reglas publicadas el 25 de agosto no contienen cláusula de expiración.

---

## Mitigación recomendada

### Ahora (antes del sprint 2)

Escribir un archivo `firestore.rules` versionado con una regla provisional explícita y documentada. Cubre H-01 y acota H-02 sin necesidad de implementar autenticación, que está fuera de alcance:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // PROVISIONAL - Proyecto de Graduacion II, sin autenticacion en alcance.
    // Permite lectura y escritura de viajes, pero NUNCA borrado.
    // El borrado es la operacion irreversible y no la necesita ningun
    // requerimiento del ERS.
    match /voyages/{voyageId} {
      allow read, create, update: if true;
      allow delete: if false;
    }
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

Esto **no** convierte la aplicación en segura. Lo que hace son tres cosas defendibles: elimina la operación destructiva, cierra todo lo que no esté declarado, y pone el control bajo control de versiones donde puede ser revisado y explicado.

**Confirmado en el commit `89bdb2c`.**

### Corrección detectada al aplicar la regla

La cláusula general de denegación alcanzaba también a la colección **`latency_test`**, donde escribe `lib/latency_test_screen.dart` — la instrumentación de la hipótesis **H5**. (`c3_reconciliation_screen.dart` no se ve afectada: escribe en `voyages`.)

Las mediciones ya tomadas no corren riesgo: están confirmadas en `7e68a59`. El problema es la **reproducibilidad**: si en la defensa se pide repetir C1 o C2, o ampliar la muestra, la instrumentación no podría escribir.

#### Primer intento, y por qué era incorrecto

La regla correctiva se redactó inicialmente como **solo anexar** — `allow read, create: if true; allow update, delete: if false`. **Habría inhabilitado la medición por completo.**

El protocolo C1/C2 no registra un dato aislado: es un intercambio en dos fases sobre un mismo documento.

| Fase | Quién | Qué hace | Líneas |
|---|---|---|---|
| 1 | Emisor | Crea el documento con `t0`, `condicion`, `evento`, `respondido: false` | 61-68 |
| 2 | Receptor | **Actualiza** el documento: `respondido: true` y añade `proceso_b_ms` | 42-45 |
| 3 | Emisor | Su listener espera `respondido == true` y calcula la latencia de ida y vuelta | 71 |

Con `update` denegado, la fase 2 falla, la 3 nunca se completa y cada evento termina por tiempo de espera agotado. Y como `latency_test_screen.dart` es archivo congelado, el protocolo no se puede cambiar: la regla es la que tiene que acomodarse.

#### Regla adoptada

```javascript
    // Instrumentacion de la hipotesis H5 (pantallas de medicion C1 y C2).
    // El protocolo es un intercambio en dos fases sobre un mismo documento:
    // el emisor lo crea con respondido:false y el receptor lo cierra
    // poniendo respondido:true. Se permite ESA transicion y ninguna otra.
    // t0, condicion y evento son inmutables desde su creacion, y una
    // medicion ya cerrada no se puede volver a tocar.
    match /latency_test/{medicionId} {
      allow read, create: if true;
      allow update: if resource.data.respondido == false
        && request.resource.data.respondido == true
        && request.resource.data.proceso_b_ms is number
        && request.resource.data.diff(resource.data).affectedKeys()
          .hasOnly(['respondido', 'proceso_b_ms']);
      allow delete: if false;
    }
```

**La garantía resultante es más fuerte que la del primer intento, no más débil:**

- **`t0`, `condicion` y `evento` son inmutables desde su creación.** Son exactamente los tres campos que habría que tocar para falsear un resultado de latencia: el instante de emisión, la condición experimental y el número de evento. La cláusula `hasOnly` los blinda.
- **Una medición se cierra exactamente una vez.** La guarda `resource.data.respondido == false` impide reabrir un documento ya cerrado: no es posible reintentar hasta obtener una cifra favorable.
- **El campo de respuesta debe ser numérico**, lo que descarta escrituras mal formadas.

#### Verificación funcional de las reglas publicadas (25 de agosto)

Las reglas se publicaron y se contrastaron contra el protocolo real, con el cliente Android como receptor y el cliente Web como emisor, condición C1, serie de tres eventos.

| Evento | t0 (ms) | t1 (ms) | Ida y vuelta | Proceso B (ms) | Cerrado |
|---|---|---|---|---|---|
| 1 | 1787699349812 | 1787699351135 | 1 323 ms | 2.614 | Sí |
| 2 | 1787699356147 | 1787699356950 | 803 ms | 0.110 | Sí |
| 3 | 1787699361956 | 1787699362921 | 965 ms | 0.086 | Sí |

**3 de 3 eventos cerrados.** La instrumentación de H5 queda operativa y reproducible.

La evidencia es concluyente por construcción del código: la fila de resultados solo se emite después de que el listener del emisor observa `respondido == true`, de modo que un `t1_ms` con valor demuestra que la actualización del receptor fue aceptada por las reglas publicadas.

**Observación durante la activación.** Al activar el receptor se produjeron tres denegaciones de permiso sobre documentos históricos que habían quedado sin cerrar en corridas anteriores. No afectaron a los eventos nuevos. La explicación más probable es que la regla rechazó un segundo cierre sobre documentos que ya había cerrado —es decir, la garantía de no reabrir una medición operando por sí sola—, aunque no se conservó traza suficiente para descartar que se trate de documentos con una forma que la regla no contempla.

**Seguimiento (27-ago).** La recomendación inicial fue purgar esos documentos antes de una serie completa. Al revisar la colección desde la consola resultó innecesaria: los 66 documentos históricos estaban en `respondido: true`, sin ninguno pendiente. La serie completa se ejecutó después sin incidencias y la colección terminó con 99 documentos, todos cerrados.

### Lección registrada

Una cláusula general de denegación puede inhabilitar funcionalidad legítima **de forma silenciosa**: no produce error de compilación ni prueba fallida. Se detectó porque la regla se contrastó contra el código de la instrumentación **antes** de publicarse. Conviene aplicar el mismo contraste a cualquier regla futura, en particular a las de TC-03.

### En TC-03 (sprint de cierre, octubre)

Migración al proyecto de producción, autenticación real, y reglas basadas en identidad. Ya está planificado; estos hallazgos le dan contenido concreto.

---

## Alcance de esta auditoría — lo que NO se hizo

Declararlo es parte del rigor:

- **No se ejecutaron pruebas dinámicas** (DAST) ni escaneo de penetración contra el despliegue.
- **No se auditó el binario Android** para M7 (Insufficient Binary Protections): requiere herramientas de ingeniería inversa fuera del alcance.
- **No se ejecutó análisis de composición de software** (SCA) sobre el árbol de dependencias transitivas.

Estas tres quedan como alcance de **TC-03 · Pruebas de Seguridad** (18–24 de octubre).

> **Corregido el 27-ago.** Esta lista incluía una cuarta entrada: «no se verificó el estado real de las
> reglas en la consola». Dejó de ser cierta el 25 de agosto, cuando se leyeron las reglas vigentes
> directamente en la consola —así se detectaron los dos errores de la propia auditoría—, se confirmó la
> interrupción con el panel de uso, se publicaron las reglas versionadas y se ejercitó el Rules
> Playground. H-03 dejó de ser inferido y pasó a ser observado. La entrada se retiró.
