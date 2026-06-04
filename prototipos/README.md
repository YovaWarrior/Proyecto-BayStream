# BayStream — Prototipos Interactivos (35 RF)

Prototipo navegable y **clickeable** del ecosistema **BayStream** que refleja **los 35
requerimientos funcionales (RF-001 a RF-035)** definidos en el ERS del proyecto de
graduación. Sustituye al documento Word con capturas: aquí cada requerimiento tiene su
propia pantalla interactiva.

Buque demo: **MSC GUATEMALA** · Viaje **V047E** · Ruta **GTSTC → HNPCR** (igual que el entregable).

---

## ▶ Cómo abrirlo

1. **Doble clic en `index.html`** — se abre en cualquier navegador (Chrome, Edge, Firefox).
   No requiere instalar nada ni conexión a internet.
2. Navega con el **menú lateral** (los 35 RF agrupados por los 7 módulos) o con los
   botones **‹ Anterior / Siguiente ›**.
3. También puedes abrir un RF directo por URL: `index.html#RF-006`.

> Opcional (recomendado para presentar): servirlo con un servidor local
> `python -m http.server` dentro de esta carpeta y abrir `http://localhost:8000`.

---

## 🧭 Qué muestra cada pantalla

Arriba de cada prototipo aparece una **tarjeta de trazabilidad** con:

- **ID del RF** (RF-001 … RF-035)
- **Prioridad MoSCoW**: `MUST` / `SHOULD` / `COULD`
- **Estado**: `Implementado` (punto verde) / `Propuesto` (punto naranja)
- **Caso de uso** asociado (CU01 … CU10) y **módulo**
- Descripción y **elementos clave** verificables

Debajo se muestra el prototipo dentro de una ventana que replica la app real
(pestañas *Lista · Bay Plan · Estadísticas*, tema oscuro Material 3 y los mismos colores
de carga).

---

## 🗂 Cobertura de los 35 requerimientos

| Módulo | RF | Pantalla interactiva |
|---|---|---|
| **1. Carga y Procesamiento** | RF-001…005 | Estado vacío + selector de archivo, parsing animado de segmentos EDIFACT, extracción del buque, tabla de contenedores, detección IMO/Reefer/OOG |
| **2. Visualización Bay Plan** | RF-006…014 | Grid de bahía, selector de bahías, colores por estado, cubierta/bodega, modal de detalle, leyenda interactiva, peso por tier, resaltado dorado, % de ocupación |
| **3. Búsqueda** | RF-015…020 | Buscador por ID/puerto/naviera/tipo de carga, navegación automática al Bay Plan, estado vacío con sugerencias |
| **4. Lista y Filtrado** | RF-021…025 | Lista de tarjetas, filtro por naviera (chips), tarjeta de resumen, dashboard estadístico, exportación PDF |
| **5. Muelle y Planificación** | RF-026…030 | Vista panorámica del buque, validación de reglas de estiba, secuencia de descarga, comparación de viajes, modo offline |
| **6. Sincronización** | RF-031…033 | Almacenamiento local (viajes recientes), sincronización en la nube, exportación CSV/JSON |
| **7. Administración** | RF-034…035 | Autenticación, control de acceso por roles (RBAC) |

Los RF con estado **Propuesto** se presentan como prototipo de la interfaz prevista
(coherente con el ERS), no como funcionalidad final de la app.

---

## 🧪 Interacciones para demostrar en vivo

- **RF-001**: «Cargar BAPLIE» → selector de archivo → carga → notificación de éxito.
- **RF-002**: «Procesar archivo» → animación del parser segmento por segmento.
- **RF-006…014**: cambiar de bahía, tocar una celda para ver el detalle, tocar un color
  de la leyenda para filtrar.
- **RF-015…019**: escribir en el buscador (`MSKU`, `HNPCR`, `MSC`, `reefer`) y **tocar un
  resultado** → salta al Bay Plan con la celda resaltada en dorado.
- **RF-022**: tocar los chips de naviera para filtrar la lista.
- **RF-024 / RF-025 / RF-033**: dashboard y exportaciones (PDF / CSV / JSON).
- **RF-030 / RF-032 / RF-035**: interruptores de offline/sync y selector de roles.

---

## 📁 Estructura

```
prototipos/
├── index.html            ← punto de entrada (abrir este)
├── css/styles.css        ← tema oscuro Material 3
└── js/
    ├── data.js           ← viaje demo + catálogo de los 35 RF
    ├── components.js      ← componentes reutilizables (grid, tarjetas, modal…)
    ├── screens-1.js       ← RF-001…014
    ├── screens-2.js       ← RF-015…025
    ├── screens-3.js       ← RF-026…035
    └── app.js             ← menú lateral + navegación + trazabilidad
```

---

## ☁️ Publicar en línea (opcional)

Para compartir un enlace con el ingeniero, sube la carpeta `prototipos/` a un repositorio
y activa **GitHub Pages** (Settings → Pages → carpeta raíz). El prototipo es 100% estático.
