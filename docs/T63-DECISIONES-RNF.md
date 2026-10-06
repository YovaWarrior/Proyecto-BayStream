# Decisiones sobre los criterios de T‑63 · qué RNF se miden en el Sprint 3

Yov · 5‑oct‑2026 · Por delegación de Carlos (5‑oct), sobre `docs/T63-CRITERIOS-RNF.md`.

**Regla que se siguió.** Cada opción se eligió por el texto del ERS, por el uso real o por una fuente,
nunca por el resultado que daría con los datos de T‑44. Cuando una opción cambia un dictamen,
se dice. Las dos decisiones que dependen de un dato del entorno de Carlos quedan marcadas
**«confirma Carlos»**: no son de criterio, son de hecho.

**Lo que cambió desde T‑63.** El Sprint 3 incorpora sincronización y cuentas (RF‑032, RF‑034), el
módulo de muelle y la segregación con el Código IMDG, al que COMAR tiene acceso. Eso resuelve 4.3 y
8.1 de otra manera que la prevista el 2‑oct.

## Decisiones

| # | Punto | Decisión | Razón |
|---|---|---|---|
| 1.1 | «Gama media» | (a) **Honor X5d** | Es el teléfono con que se hará la prueba piloto en el muelle: uso real. Se declara que es un solo dispositivo. |
| 1.2 | «≥ 60 fps» | (b) **p90** del tiempo de cuadro ≤ 16.67 ms | Recomendación de T‑63: un promedio esconde los tirones que el usuario ve. |
| 1.3 | «MB» | **MB del SI** (10⁶ bytes) | Significado normalizado. No cambia el dictamen. |
| 1.4 | Métrica de RAM | **A:** `WorkingSet64` en Windows y RSS en Android | Es el único par que mide lo mismo en las dos plataformas. |
| 1.4 | Ventana de Windows | (a) **maximizada en una laptop de 1920×1080**, con la escala que Windows recomienda en esa pantalla, registrada | Así trabaja el planificador: en la pantalla de su laptop, de 14 a 17", a 1920×1080 (Carlos, 6-oct). |
| 1.4 | Archivo | (a) **sintético de 5 000**, declarado, más los archivos reales | El ERS pide hasta 5 000 y el corpus llega a 979. El sintético es carga de prueba, no un viaje. También se informan los archivos reales del MAGELLAN STAR, anonimizados. |
| 2.1 | Primera visualización | (i) **sin perfil** | Lectura literal; es la primera experiencia. Con perfil se informa aparte, sin dictamen. |
| 2.2 | «El plano de estiba» | (a) **la rejilla del Bay Plan** | Lectura literal. Que «Confirmar y ver el plano» abra Lista se corrige en el Sprint 3 como defecto de interfaz, no para ganar un paso. |
| 2.4 | Denominador de Material 3 | (a) **controles interactivos** | Material 3 define componentes; la rejilla de bahías no tiene equivalente y se declara excluida por eso. |
| 2.5 | Participantes | **cinco**, de operaciones de COMAR, durante la prueba piloto, con el cuestionario SUS que cita el ERS | NN/g recomienda cinco; el jefe de Carlos permite la prueba piloto. Sin participantes, queda como limitación. |
| 3.1 | Denominador del 95 % | (b) **`lib/` más el nativo escrito a mano** | «Reescribir código» incluye el nativo; es la lectura más exigente. |
| 3.2 | Qué representa 27" | **2560×1440 al 100 %** | Es la resolución nativa más común de un panel de 27". Se prueba además 1920×1080, la pantalla real de los planificadores. |
| 3.3 | «Funcional» | (a) **ningún texto ni control cortado o tapado** | Un control cortado no es funcional en el muelle. **Cambia el dictamen:** la parte responsiva pasa a *no cumple* a 360 px hasta que se corrija. |
| 4.1 | Operaciones básicas | **la lista de T‑63** (módulos 1 a 4) | Las operaciones de sincronización no son básicas: transmiten por diseño y se miden con 4.3. |
| 4.2 | Descarga del motor y del SDK | (a) **no es transmisión de datos** | El ERS habla de archivos e información comercial; bajar código público no los lleva. |
| 4.3 | TLS y credenciales | **aplican y se miden** | Con RF‑032 y RF‑034 en el Sprint 3, el condicional del ERS se cumple. Se mide TLS 1.2+ en cada conexión y dónde guarda la sesión cada plataforma. |
| 5.1 | Denominador de documentación | (a) **clases y métodos públicos**, incluidas las dos pantallas de H5 | Lectura literal; las pantallas de H5 están en `lib/` y se compilan. |
| 5.3 | Providers «granulares» | (b) **reconstrucciones** con DevTools | Mide el efecto que pide el ERS. |
| 6.1 | 99.9 % de disponibilidad | (a) **funcional sin red** | Es el paréntesis del propio ERS. (b) se informa solo si la prueba cerrada de Play da datos. |
| 7.1 | «Sin degradación» y «aceptable» | (a) **umbrales de RNF‑001** para los dos | No inventa un umbral nuevo. **Cambia el dictamen:** la capacidad mínima pasa a *no cumple* mientras la RAM no cumpla. |
| 7.2 | 10 000 contenedores o TEU | **contenedores** | Lectura literal de la métrica. |
| 7.3 | Archivo de 500 | (a) **A06** (717, real) | Es real y es más exigente que 500. |
| 7.4 | «Modificar existentes» | (a) **ningún archivo fuera de la carpeta nueva** | Lectura literal. Si un módulo necesita registrarse en otro archivo, cuenta como modificación. |
| 8.1 | IMDG | (a) **implementarlo** | COMAR tiene el Código (Enmienda 42‑24). Las disposiciones especiales por número ONU quedan como «no evaluado» y RNF‑008 sigue en *no cumple* mientras falten. |

## Qué se mide en el Sprint 3 y en qué orden

Todo se mide sobre los binarios de cierre, como T‑44. Los arneses van en `test/`, `integration_test/`
y `tool/`, sin tocar `lib/`, así que pueden construirse en paralelo con el código del sprint.

| Orden | RNF | Por qué en ese lugar | Horas (T‑63) |
|---|---|---|---|
| 1 | 004 Seguridad de los datos | Con la sincronización los datos salen del dispositivo por primera vez; es el centro de la entrega del 24‑oct. | ≈ 5, más TLS y sesión |
| 2 | 006 Tolerancia a fallos | El muelle trabaja sin señal. | ≈ 6 |
| 3 | 008 Estándares | Batería de BAPLIE, BBBRRTT, ISO 6346, UN/LOCODE y VGM; el IMDG va con su tarea. | ≈ 8 |
| 4 | 002 Usabilidad | Pasos, tiempo, idioma y Material 3; SUS en la prueba piloto. | ≈ 7, más la prueba piloto |
| 5 | 001 Rendimiento y 007 Escalabilidad | Comparten el arnés y los archivos sintéticos. | ≈ 18 |
| 6 | 005 Mantenibilidad | No toca `lib/`. | ≈ 5 |
| 7 | 003 Portabilidad | Emulador API 26, anchos y entrada. | ≈ 8 |

**Total ≈ 57 h,** más la prueba piloto. Si el sprint no alcanza, se corta desde abajo y lo que no
se mida se declara.

## Lo que queda como limitación declarada

- 6.1 (b), la disponibilidad longitudinal: hacen falta semanas de uso.
- La capacidad con un archivo **real** de 10 000 contenedores: solo hay sintéticos.
- Windows 10, si no se consigue una máquina para la prueba corta. Sigue en uso en COMAR, aunque la mayoría ya tiene Windows 11 (Carlos, 6-oct). Se mide en Windows 11, y Windows 10 no se da por cumplido con esa medición.
- Las disposiciones especiales del IMDG por número ONU, hasta tener la Lista de Mercancías
  Peligrosas en datos.

## Confirmado por Carlos (6-oct)

1. **Pantalla:** los planificadores usan la de su laptop, de 14 a 17", a 1920×1080. Ajusta 1.4 y 3.2.
2. **Windows:** Windows 10 sigue en uso, pero la mayoría ya tiene Windows 11.

**Pendiente:** una máquina de COMAR con Windows 10, unos 15 minutos, para una prueba corta: instalar, abrir A01 y recorrer el Bay Plan.
