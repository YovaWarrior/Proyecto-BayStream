# T-46 · Inventario de dependencias (H-07) y registro de eventos (H-06)

Fecha: 25 de septiembre de 2026, Guatemala. Hallazgos H-06 y H-07 de
`docs/AUDITORIA-SEGURIDAD-SPRINT1.md`. Autor: Timonel.
**Documento sin código.** No se agregó ni quitó ninguna dependencia (§2.5).

---

## H-07 · Inventario de dependencias

### Resultado

- **Cero vulnerabilidades conocidas en los 113 paquetes de pub.dev**, cada uno
  en su versión exacta de `pubspec.lock`.
- **Todas las licencias son permisivas** salvo una transitiva, `dbus`
  (MPL-2.0). Se comprobó que no entra en los binarios de Web ni de Android.
- **Seis dependencias directas están declaradas y no se usan.**
- El brief nombraba diez dependencias; **las directas de producción son doce.**

### Método

| Qué | Fuente | Control de que la consulta puede dar positivo |
|---|---|---|
| Versiones | `pubspec.yaml` (restricción) y `pubspec.lock` (versión resuelta): 117 paquetes, 113 de pub.dev y 4 del SDK | — |
| Licencia | El archivo `LICENSE` de **la versión exacta**, en la caché local de pub, contrastado con la etiqueta de licencia de pub.dev (que describe la última versión). Coinciden en las 16 directas | — |
| Vulnerabilidades | **OSV.dev**, ecosistema `Pub`, consulta por lote de los 113 paquetes con su versión exacta | `http 0.12.2` devuelve `GHSA-4rgh-jx4f-qfcq` |
| Avisos de seguridad | API de avisos de pub.dev, paquete por paquete, para las directas | `http` devuelve 1 aviso |

Sin el control, un «cero» no distinguiría «no hay vulnerabilidades» de «la
consulta no funciona».

### Dependencias directas de producción

| Paquete | Restricción | Resuelta | Licencia | Vulnerab. (OSV) | Avisos pub.dev | ¿Se usa en `lib/`? |
|---|---|---|---|:-:|:-:|---|
| `flutter` | SDK | — | BSD-3-Clause (SDK) | — | — | Sí |
| `flutter_riverpod` | ^3.1.0 | 3.1.0 | MIT | 0 | 0 | Sí (6 archivos) |
| `riverpod_annotation` | ^4.0.0 | 4.0.0 | MIT | 0 | 0 | **No** |
| `firebase_core` | ^4.4.0 | 4.13.0 | BSD-3-Clause | 0 | 0 | Sí (`main.dart`) |
| `cloud_firestore` | ^6.1.2 | 6.8.0 | BSD-3-Clause | 0 | 0 | Sí (3 archivos, dos congelados) |
| `equatable` | ^2.0.5 | 2.0.8 | MIT | 0 | 0 | Sí (8 archivos) |
| `dartz` | ^0.10.1 | 0.10.1 | MIT | 0 | 0 | Sí (4 archivos) |
| `uuid` | ^4.3.3 | 4.5.2 | MIT | 0 | 0 | Sí (1 archivo) |
| `intl` | ^0.20.2 | 0.20.2 | BSD-3-Clause | 0 | 0 | **No** (tampoco en `test/`) |
| `file_picker` | ^10.3.10 | 10.3.10 | MIT | 0 | 0 | Sí (2 archivos) |
| `pdf` | **3.12.0** (fija) | 3.12.0 | Apache-2.0 | 0 | 0 | Sí (1 archivo) |
| `hive_ce` | **2.20.0** (fija) | 2.20.0 | BSD-3-Clause + Apache-2.0 | 0 | 0 | Sí (1 archivo) |
| `cupertino_icons` | ^1.0.6 | 1.0.8 | MIT | 0 | 0 | **No** |

La licencia de `hive_ce` combina dos textos: el BSD de su mantenedor actual y
el Apache 2.0 del proyecto Hive original, del que es derivado. Las dos son
permisivas.

### Dependencias directas de desarrollo

No viajan en los binarios publicados.

| Paquete | Restricción | Resuelta | Licencia | Vulnerab. (OSV) | ¿Se usa? |
|---|---|---|---|:-:|---|
| `flutter_test` | SDK | — | BSD-3-Clause (SDK) | — | Sí |
| `flutter_lints` | ^6.0.0 | 6.0.0 | BSD-3-Clause | 0 | Sí (`analysis_options.yaml`) |
| `riverpod_generator` | ^4.0.0+1 | 4.0.0+1 | MIT | 0 | **No**: no hay anotaciones `@riverpod` ni archivos `.g.dart` |
| `build_runner` | ^2.4.8 | 2.10.5 | BSD-3-Clause | 0 | **No**: no hay código generado |
| `mockito` | ^5.4.4 | 5.6.3 | Apache-2.0 | 0 | **No**: ninguna prueba lo importa |

### Transitivas

Hay 99 dependencias transitivas: 97 de pub.dev y 2 del SDK
(`flutter_web_plugins` y `sky_engine`). **Ninguna tiene vulnerabilidades
conocidas.** Licencias de los 113 paquetes de pub.dev:

| Licencia | Paquetes |
|---|---:|
| BSD | 83 |
| MIT | 21 |
| Apache-2.0 | 6 |
| BSD + MIT (`node_preamble`) | 1 |
| BSD + Apache-2.0 (`hive_ce`) | 1 |
| **MPL-2.0 (`dbus` 0.7.11)** | 1 |

**`dbus` es la única con copyleft**, y es débil: MPL-2.0 obliga a publicar solo
los archivos MPL que uno modifique. La trae `file_picker` para su
implementación en Linux, que no es plataforma de BayStream. **Se comprobó que
no entra en los binarios.** Se buscaron cadenas propias de `dbus`
(`org.freedesktop`, `DBusClient`) en el `main.dart.js` de un build Web release
y en el `libapp.so` de un APK release, los dos de la verificación de T-45: cero
coincidencias. En los mismos archivos las cadenas de control sí aparecen
(`C3TEST`, `latency_test`, «Verificacion T-45»). **Windows no se comprobó**
porque no había un build a mano. Aun si entrara, usarla sin modificarla no
obliga a nada.

### Dependencias declaradas que no se usan

`riverpod_annotation`, `intl` y `cupertino_icons` (producción), y
`riverpod_generator`, `build_runner` y `mockito` (desarrollo). Ninguna aparece
en `lib/`, `test/` ni `tool/`, ni en el trabajo sin commitear del árbol al
25-sep.

- **Para H-07:** son superficie de ataque sin función. Hoy tienen cero
  vulnerabilidades, pero cada versión nueva las vuelve a traer.
- **Para H4:** cuentan como dependencias declaradas sin aportar nada, y el
  argumento del proyecto es que cada dependencia se gana su lugar.

**No se quitaron.** Es un cambio de `pubspec.yaml`, y esa decisión es de
Carlos. §2.5 limita agregar, no quitar, así que quitarlas no choca con la
regla.

### Lo que este inventario no cubre

- **Es una foto al 25-sep-2026, no un análisis programado.** Las consultas son
  reproducibles (abajo), pero nadie las corre solas. Automatizarlas —una tarea
  de integración continua o una alerta del repositorio— sería el paso que
  cierra H-07 del todo.
- **Solo ve vulnerabilidades publicadas** en las bases que agrega OSV para el
  ecosistema Pub. No es un análisis del código.
- **No ve los SDK nativos que traen los plugins.** `firebase_core` y
  `cloud_firestore` incorporan los SDK de Firebase para Android (vía Gradle) y
  para Web (JavaScript). No son paquetes de pub, y OSV no los consulta con esta
  búsqueda.

### Cómo reproducirlo

Consulta de un paquete en OSV.dev (PowerShell):

```powershell
curl.exe -s -X POST https://api.osv.dev/v1/query -H "Content-Type: application/json" -d "{\"package\":{\"name\":\"cloud_firestore\",\"ecosystem\":\"Pub\"},\"version\":\"6.8.0\"}"
```

Una respuesta `{}` significa que no hay vulnerabilidades conocidas para esa
versión. Avisos de pub.dev: `https://pub.dev/api/packages/<paquete>/advisories`.
Para todos los paquetes a la vez: `https://api.osv.dev/v1/querybatch`, con la
lista de paquetes y versiones de `pubspec.lock`.

---

## H-06 · Registro de eventos: ¿se cierra desde la consola?

**Respuesta: no se sabe hasta probarlo en el proyecto, y hay una razón concreta
para sospechar que no.** No lo di por hecho. Esto es lo que dice la
documentación oficial y cómo se verifica.

### Lo que dice la documentación oficial de Google Cloud

- Los **registros de auditoría de acceso a datos** están **desactivados por
  defecto** y se activan explícitamente, desde la consola o por la API. Pueden
  generar cargos si el volumen es grande (*Configure Data Access audit logs*).
- Para Firestore se configuran con el servicio **`datastore.googleapis.com`**,
  que cubre también `firestore.googleapis.com`. Se registran como lectura de
  datos `Listen`, `GetDocument`, `ListDocuments` y `RunQuery`, entre otros, y
  como escritura `Write`, `Commit` y `UpdateDocument`, entre otros. Esos son
  los canales que usa el SDK cliente. No se registran las importaciones, los
  borrados masivos ni el TTL. Las peticiones con Firebase Authentication llevan
  el token, y todas llevan la IP de origen (*Firestore audit logging*).
- **La restricción que importa** (*Cloud Audit Logs overview*): «*Resources
  that can be accessed without logging into a Google Cloud account, Google
  Workspace, Cloud Identity, or Drive Enterprise account don't generate audit
  logs.*»

### Por qué eso puede anular la opción

Con la variante B publicada, **todo acceso a Firestore en este proyecto es
anónimo**: el de las pantallas de H5 y el de cualquier tercero con la clave
pública. Si la regla general se aplica a Firestore, **activar los registros no
registraría justamente los accesos que H-06 quiere ver.** La página de
Firestore no dice nada sobre peticiones sin autenticar, así que la
documentación no lo resuelve. Es la misma trampa de T-23: una configuración
que se lee bien y no hace lo que se espera.

**Lo que no pude verificar:** nada dentro del proyecto. No tengo acceso a la
consola, y la configuración de auditoría y el Explorador de registros solo se
ven desde ahí.

### Verificación, para Carlos (consola, unos 15 minutos)

**Paso 0 · Sin configurar nada.** Las operaciones administrativas se registran
siempre y no se pueden desactivar. En Google Cloud → **Explorador de
registros**, buscá entradas de `firebaserules.googleapis.com` el 25-sep, justo
antes de las 12:33:57, que es la hora de la sonda con la que se verificó la
publicación de B. Si aparecen, **los cambios de reglas ya quedan auditados
hoy**, y eso es parte de H-06 que ya existe.

**Paso 1 · Activar.** Proyecto `baystream-h5-temporal-20260814` → **IAM y
administración → Registros de auditoría** → el servicio
`datastore.googleapis.com`, que la consola muestra como **Cloud Datastore
API** → marcar **Lectura de datos** y **Escritura de datos** → Guardar. Si el
servicio no aparece o la página exige facturación, **se detiene aquí**.

**Paso 2 · Control positivo.** Firebase → Firestore → abrí un documento de
`latency_test` desde la consola, con tu cuenta. Esperá entre 2 y 5 minutos. En
el Explorador de registros, consultá
`protoPayload.serviceName="firestore.googleapis.com"`: tiene que aparecer tu
lectura, con tu correo en `authenticationInfo`. **Si no aparece, el registro no
está funcionando** y la prueba siguiente no significaría nada.

**Paso 3 · La prueba.** Corré la sonda anónima de T-45. Solo lee, no escribe
nada:

```powershell
foreach ($r in "voyages/c3-measurement-voyage","latency_test?pageSize=1") { "{0,-32} {1}" -f $r, (curl.exe -s -o NUL -w "%{http_code}" "https://firestore.googleapis.com/v1/projects/baystream-h5-temporal-20260814/databases/(default)/documents/$r") }
```

Anotá la hora. Esperá entre 2 y 5 minutos y buscá, en ese minuto, entradas de
`GetDocument` o `ListDocuments`.

**Paso 4 · Decisión.**

- **Si aparecen las lecturas anónimas** (con IP de origen): H-06 se cierra
  desde la consola, sin código, sin dependencia y sin tocar `main.dart`. Para
  confirmar también `Listen` y `Write`, sirve un ciclo C3 como el de T-45, que
  no altera la cuenta de `latency_test`.
- **Si solo aparece el control positivo:** el acceso anónimo, que es el único
  que hace BayStream con B y el que haría un atacante, no se audita. **H-06 no
  se cierra desde la consola y se difiere a la ventana de T-47**, como se
  decidió: cae en `main.dart`, que T-47 va a tocar de todas formas.

Después de la prueba, Carlos decide si deja los registros activos o los
apaga; el volumen de este proyecto es mínimo. La mitad de **alertas** de H-06
(alertas sobre registros en Cloud Monitoring) solo tiene sentido si el paso 4
sale bien, y no se investigó más.

---

## Fuentes

- OSV.dev, API — <https://api.osv.dev/v1/querybatch>
- pub.dev, API de avisos y puntuación — `https://pub.dev/api/packages/<paquete>/advisories`, `/score`
- Google Cloud, *Configure Data Access audit logs* — <https://cloud.google.com/logging/docs/audit/configure-data-access>
- Google Cloud, *Firestore audit logging* — <https://cloud.google.com/firestore/native/docs/audit-logging>
- Google Cloud, *Cloud Audit Logs overview* — <https://cloud.google.com/logging/docs/audit>

Consultadas el 25 de septiembre de 2026.
