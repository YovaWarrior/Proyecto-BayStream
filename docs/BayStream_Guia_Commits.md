# Rescate del repositorio BayStream — guía paso a paso

**Para:** Carlos Giovanni Martínez Aldana · 19 de agosto de 2026
**Repositorio:** `C:\Proyectos\proyecto-baystream` → `github.com/yovawarrior/proyecto-baystream` (rama `master`)

---

## Qué vamos a hacer y por qué

Tu último commit es del **4 de junio**. Desde entonces hay **83 archivos con cambios** que solo existen en tu disco: todo `lib/`, la sincronización sobre Firestore que es la evidencia de H5, las dos pantallas de instrumentación, y los proyectos de plataforma actualizados.

Vamos a subirlo en **cinco commits temáticos** en vez de uno solo, para que cada commit respalde una parte concreta de la tesis y la bitácora siga siendo legible. Y vamos a **etiquetar** el estado del código que reproduce el conteo de `cloc` de la hipótesis H4.

> **Antes de empezar:** abre una terminal en la carpeta del proyecto.
> En VS Code: `Terminal → New Terminal` (ya se abre en la carpeta correcta).
> O en PowerShell: `cd C:\Proyectos\proyecto-baystream`

---

## Paso 0 · Configurar tu identidad en git

Tu `git config user.name` y `user.email` están **vacíos**. Sin esto el commit falla o queda mal atribuido.

```bash
git config user.name "Carlos Giovanni Martinez Aldana"
git config user.email "giovannimartinezcrl2002@gmail.com"
```

Verifica que quedó:

```bash
git config user.name
git config user.email
```

---

## Paso 1 · Excluir lo que no debe subir a GitHub

Abre `.gitignore` en VS Code y **pega estas líneas al final del archivo**:

```gitignore

# Material bibliografico de terceros (no redistribuible)
docs/Metodologia*.pdf

# Archivos temporales de trabajo con XML de Word
docs/temp_*.xml
docs/temp_*.txt

# Configuracion local de herramientas
.claude/
```

**Por qué cada uno:**

| Patrón | Motivo |
|---|---|
| `docs/Metodologia*.pdf` | El libro de Sampieri pesa **21 MB** y tiene derechos de autor. Publicarlo en un repositorio abierto es redistribución. |
| `docs/temp_*.xml` y `.txt` | 1.9 MB de XML crudo de Word que quedó de cuando convertiste los requerimientos a tablas. No aporta nada. |
| `.claude/` | Configuración local de herramientas, cambia en cada máquina. |

Guarda el archivo (`Ctrl+S`).

---

## Paso 2 · Commit 1 — dejar de versionar esos archivos

Seis de los `temp_*` y el `settings.local.json` **ya estaban** en el repositorio, así que el `.gitignore` por sí solo no los saca. Este comando los quita del control de versiones **sin borrarlos de tu disco** (eso es lo que hace `--cached`):

```bash
git rm --cached --ignore-unmatch docs/temp_*.xml docs/temp_*.txt .claude/settings.local.json
git add .gitignore
git commit -m "chore: excluir material de terceros y archivos temporales del control de versiones"
```

---

## Paso 3 · Commit 2 — la sincronización en tiempo real

Este es el commit importante: contiene la evidencia de H5.

```bash
git add lib/core/ lib/features/ lib/main.dart pubspec.yaml pubspec.lock test/
git commit -m "feat: sincronizacion en tiempo real sobre Firestore" -m "Repositorio de viajes sobre cloud_firestore con escuchas en tiempo real mediante watchVoyageById. Habilita el escenario oficina-muelle con el que se contrasto la hipotesis H5. Incluye la configuracion de Firebase para los clientes Web y Android y las 21 pruebas unitarias en verde."
```

> El doble `-m` crea un commit con título y cuerpo separados, que es la convención. El primero es el título, el segundo el párrafo explicativo.

---

## Paso 4 · Commit 3 — la instrumentación de la medición

Las dos pantallas de medición **no estaban ni siquiera registradas** en git (`untracked`). Van en su propio commit porque son instrumento de investigación, no producto.

```bash
git add lib/latency_test_screen.dart lib/c3_reconciliation_screen.dart
git commit -m "test: instrumentacion de latencia para los escenarios C1, C2 y C3" -m "Pantallas de medicion del instrumento M3: protocolo de ida y vuelta sobre un solo reloj para C1 y C2, y reconciliacion tras 60 s sin conexion para C3. Evidencia de la hipotesis H5."
```

---

## Paso 5 · Commit 4 — los proyectos de plataforma

```bash
git add android/ windows/ web/ analysis_options.yaml README.md
git commit -m "chore: configuracion de los clientes Windows, Android y Web" -m "Actualizacion de los proyectos de plataforma tras incorporar Firebase. Es el codigo especifico por plataforma que mide el instrumento M2 para la hipotesis H4: 702 lineas en windows, 389 en android y 54 en web."
```

---

## Paso 6 · La etiqueta `m2-baseline`

**Este paso es el que protege tu H4.** El conteo de `cloc` que sostiene esa hipótesis —4,953 líneas compartidas y 1,145 específicas— se hizo con las dos pantallas de instrumentación **dentro** de `lib/`. Si algún día las mueves de sitio, el conteo dejará de reproducir esa cifra.

La etiqueta congela este punto exacto del historial. Si el jurado te pide reproducir el conteo, le das el nombre de la etiqueta y lo reproduce, sin importar cómo haya evolucionado el código después.

```bash
git tag -a m2-baseline -m "Estado del repositorio sobre el que se ejecuto el conteo de cloc del instrumento M2: 4953 lineas compartidas en lib/ y 1145 especificas por plataforma (702 windows, 389 android, 54 web). Evidencia de la hipotesis H4."
```

Verifica que quedó:

```bash
git tag
git show m2-baseline --stat | head -20
```

---

## Paso 7 · Commit 5 — los entregables del proyecto

```bash
git add docs/ outputs/ presentacion/ bitacora_commits.csv
git commit -m "docs: entregables del Proyecto de Graduacion II" -m "Product Backlog con estimacion de tiempos de entrega, Sprint Backlog del Sprint 1 con historias de usuario y tablero Kanban, registros de las mediciones tecnicas y prototipos navegables de los 35 requerimientos."
```

> Si este `git add` tarda, es normal: `docs/` pesa unos 8 MB una vez excluido el PDF de Sampieri.

---

## Paso 8 · Subir todo a GitHub

```bash
git push origin master
git push origin m2-baseline
```

Si te pide credenciales, GitHub ya no acepta contraseña: necesitas un **token de acceso personal**. Se genera en `github.com → Settings → Developer settings → Personal access tokens → Tokens (classic) → Generate new token`, con el permiso `repo` marcado. Ese token se usa como contraseña.

---

## Verificación final

```bash
git status --short
git log --oneline -6
git tag
```

**Lo que debes ver:**

- `git status --short` → **vacío**, o a lo sumo con `.claude/settings.local.json` marcado como no rastreado.
- `git log --oneline -6` → tus cinco commits nuevos encima de `ead8a60`.
- `git tag` → `m2-baseline`.

Y en `github.com/yovawarrior/proyecto-baystream` deberías ver los cinco commits y la etiqueta en la sección de *Tags*.

---

## Si prefieres hacerlo desde la interfaz de VS Code

El panel de **Source Control** (`Ctrl+Shift+G`) sirve para todo salvo la etiqueta:

1. Los archivos aparecen en *Changes*. Pasa el cursor sobre cada archivo o carpeta y pulsa el **`+`** para moverlo a *Staged Changes*.
2. Escribe el mensaje del commit en la caja de arriba y pulsa **✓ Commit**.
3. Repite para cada uno de los cinco grupos, en el mismo orden de esta guía.
4. La etiqueta del Paso 6 **sí hay que crearla por terminal**, o con `Ctrl+Shift+P → Git: Create Tag`.
5. Al final pulsa **Sync Changes** para subir, y luego `git push origin m2-baseline` por terminal.

> Un aviso: en VS Code es fácil pulsar el `+` de *Changes* completo y meter todo en un solo commit. Si eso pasa, no es grave —el trabajo queda a salvo igual—, solo pierdes la trazabilidad entre cada commit y la hipótesis que respalda.

---

## Después de esto

Con el repositorio a salvo, el viernes 22 abre el Sprint 1 con las 20 tareas del Sprint Backlog. La primera que conviene atacar no es la T-01 sino la **T-08**, que verifica que el paquete de generación de PDF compila en las tres plataformas: es el riesgo de mayor impacto del sprint y conviene descubrirlo el primer día, no la víspera de la entrega del 29.
