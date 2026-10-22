<!-- Generado por tool/t112_censos.py; no editar a mano. -->

## Tabla T1 · Idioma: visibles por canal e idioma

| Canal | español | sin idioma (siglas, nombres o unidades) | mixta | otro idioma | Total |
|---|---:|---:|---:|---:|---:|
| pantalla | 1539 | 117 | 0 | 0 | 1656 |
| accesibilidad | 55 | 0 | 0 | 0 | 55 |
| sistema | 7 | 2 | 0 | 0 | 9 |
| pdf | 48 | 19 | 0 | 0 | 67 |
| archivo | 28 | 1 | 0 | 0 | 29 |
| **Total** | **1677** | **139** | **0** | **0** | **1816** |

## Tabla T2 · Idioma: la métrica de T-98, repetida

Las dos lecturas de T-98: (a) español / (español + inglés o mixto); (b) (español + sin idioma) / visibles. Los 20 textos de Flutter ya salen en español y suman como español.

| Alcance | Español (con Flutter) | Sin idioma | Inglés o mixto | (a) | (b) |
|---|---:|---:|---:|---:|---:|
| Interfaz (pantalla, accesibilidad y diálogos del sistema) | 1601 | 119 | 0 | 100.0 % | 100.0 % |
| Interfaz, con los textos de Flutter | 1621 | 119 | 0 | 100.0 % | 100.0 % |
| Todo lo visible, también el PDF y el CSV | 1677 | 139 | 0 | 100.0 % | 100.0 % |
| Todo lo visible, con los textos de Flutter | 1697 | 139 | 0 | 100.0 % | 100.0 % |

## Tabla T3 · Idioma: lo visible que no es español

Ninguna: las cadenas visibles están en español o no tienen idioma (siglas, nombres, unidades).

## Tabla T4 · Textos de Flutter, ahora en español

| # | Texto en español | Origen en el SDK 3.38.9 (en material_es.arb) | Dónde aparece |
|---|---|---|---|
| F01 | Atrás | material/action_buttons.dart:149 y :200 (backButtonTooltip) | las 15 rutas empujadas sin leading propio (14 pantallas): Recientes, Perfiles, Parámetros, Política, Tapas de escotilla, Alertas, Listado, BAPLIE de salida, Comparar, Orden de descarga, Avance, Tapas en la operación, Solicitudes (y su formulario) y Nube y cuenta. El Honor lo leyó en Alertas, Recientes y Parámetros (Fase B). |
| F02 | Alerta | material/dialog.dart:782 (alertDialogLabel) | los 17 AlertDialog del producto |
| F03 | Cerrar | material/dialog.dart:1680 (modalBarrierDismissLabel) | las 19 llamadas a showDialog |
| F04 | Sombreado | material/bottom_sheet.dart:1271 (scrimLabel) | las 7 hojas modales (detalle del contenedor y de la reserva, tablas de pendientes, selector de OR, confirmación del arrastre) |
| F05 | Cerrar Hoja inferior | material/bottom_sheet.dart:1272 (scrimOnTapHint + bottomSheetLabel) | las mismas 7 hojas |
| F06 | Menú emergente | material/popup_menu.dart:1203 (popupMenuLabel) | Exportar viaje, Acciones del Bay Plan compacto, Agregar un nivel (los tres botones traen tooltip propio) |
| F07 | Eliminar | material/chip.dart:1307-1308 (deleteButtonTooltip) | Parámetros del buque: niveles (vessel_geometry_page.dart:778) y tomas (:505) |
| F08 | Pestaña 1 de 3 | material/tabs.dart:1970 (tabLabel) | pestañas Lista / Bay Plan / Estadísticas y las de Comparar BAPLIE |
| F09 | Quedan N caracteres | material/text_field.dart:1243 (remainingTextFieldCharacterCount) | los cuatro campos de motivo con 300 caracteres (arrastre, oficina, solicitud, decisión); el contador visible «0/300» es numérico |
| F10 | Contraído / Desplegado | material/expansion_tile.dart:533-534 (expandedHint, collapsedHint; se anuncia al abrir o cerrar) | Celdas reservadas, Frontera y anclas, Tomas de reefer, secciones del cruce y Filas del listado |
| F11 | Desplegar para ver más detalles / Contraer | material/expansion_tile.dart:590-591 | los mismos cinco |
| F12 | Cortar / Copiar / Pegar / Seleccionar todo | material/adaptive_text_selection_toolbar.dart:221-224 | todos los TextField y TextFormField, los SelectableText (detalle de avisos, cancelados, etiquetas de Estadísticas) y la SelectionArea de la Política |
| F13 | Buscador visual / Buscar en la Web / Compartir | material/adaptive_text_selection_toolbar.dart:226-228 | los mismos campos, según lo que ofrezca el sistema |
| F14 | Seleccionar fecha | material/date_picker.dart:724 (datePickerHelpText) | botón «Fecha» del diálogo Confirmar carga (loading_controls.dart:660) |
| F15 | Cancelar / ACEPTAR | material/date_picker.dart:615 y :622 | el mismo selector |
| F16 | Cambiar a cuadro de texto / Cambiar a calendario | material/date_picker.dart:698 y :711 | el mismo selector |
| F17 | Introduce una fecha / dd/mm/aaaa | material/input_date_picker_form_field.dart:273-274 | el mismo selector (formato de EE. UU., distinto del «día/mes/año» que muestra el diálogo) |
| F18 | Formato no válido. / Fuera del periodo válido. | material/input_date_picker_form_field.dart:232-234 | el mismo selector |
| F19 | Mes anterior / Mes siguiente / Seleccionar año | material/calendar_date_picker.dart:874-889 y :489 | el mismo selector |
| F20 | meses y días en español, como «octubre de 2026» (test/t112_localization_test.dart) | material/material_localizations.dart (_months, _narrowWeekdays, formatMediumDate, formatMonthYear) | el mismo selector |

## Tabla T5 · Material 3 por pantalla

| Pantalla | Controles | Material | Color del esquema o del tema | Excepciones |
|---|---:|---:|---:|---:|
| S01 · Inicio y viaje: barra superior, pestañas y Lista (VesselOverviewPage) | 48 | 48 | 48 | 0 |
| S02 · Bay Plan (pestaña): encabezado, selector de bahías, leyenda, zoom y hojas de detalle | 79 | 74 | 77 | 5 |
| S03 · Estadísticas (pestaña) | 4 | 4 | 4 | 0 |
| S04 · Buscar contenedor (SearchDelegate) | 6 | 6 | 6 | 0 |
| S05 · Viajes recientes | 7 | 7 | 7 | 0 |
| S06 · Perfiles guardados | 3 | 3 | 3 | 0 |
| S07 · Parámetros | 4 | 4 | 4 | 0 |
| S08 · Política de privacidad | 1 | 1 | 1 | 0 |
| S09 · Parámetros del buque (geometría) | 27 | 27 | 27 | 0 |
| S10 · Tapas de escotilla | 12 | 12 | 12 | 0 |
| S11 · Alertas de estiba | 3 | 3 | 3 | 0 |
| S12 · Listado de la agencia | 12 | 12 | 12 | 0 |
| S13 · BAPLIE de salida | 4 | 4 | 4 | 0 |
| S14 · Comparar BAPLIE | 5 | 5 | 3 | 0 |
| S15 · Orden de descarga | 2 | 2 | 2 | 0 |
| S16 · Avance de la operación | 4 | 4 | 4 | 0 |
| S17 · Tapas en la operación | 6 | 6 | 6 | 0 |
| S18 · Solicitudes de cambio, Bandeja y formulario Pedir cambio / Mover | 15 | 15 | 15 | 0 |
| S19 · Nube y cuenta | 14 | 14 | 14 | 0 |
| T114 · Sistema de diseño de T-114: componentes, tema y vistas previas (sin pantalla aún) | 7 | 7 | 7 | 0 |

Denominador: **259** controles; excepciones: **5**.

## Tabla T6 · Mensajes: métricas

| Medida | Cantidad | De | % |
|---|---:|---:|---:|
| Mensajes distintos | 218 |  |  |
| Dicen la causa (sí) | 218 | 218 | 100.0 |
| Dicen la acción (sí) | 218 | 218 | 100.0 |
| **Causa y acción explícitas** | **218** | 218 | **100.0** |
| Errores de lectura de un BAPLIE que nombran el segmento | 12 | 12 | 100.0 |

## Tabla T7 · Mensajes: inventario

| # | Archivo:línea | Texto como se ve | Tipo | Causa | Acción | Parseo | Segmento |
|---|---|---|---|---|---|---|---|
|  | **Formateador común (vessel_error_message.dart)** |  |  |  |  |  |  |
| M001 | `presentation/formatters/vessel_error_message.dart:21` | No se pudo {la operación que nombra el llamador\|completar la operación} por un error interno de la aplicación; el detalle técnico quedó en el registro. Inténtalo de nuevo y, si se repite, reinicia la aplicación. | falla | sí | sí | no | — |
| M002 | `presentation/formatters/vessel_error_message.dart:38` | Este archivo no parece un BAPLIE: no se reconoce su cabecera UNH/S009. Selecciona una exportación BAPLIE completa. (También con «Archivo «nombre»: » delante.) | falla | sí | sí | sí | sí |
| M003 | `presentation/formatters/vessel_error_message.dart:66` | El archivo no trae el nombre del buque en el segmento TDT. Revisa que sea un BAPLIE completo o pide una nueva exportación. | falla | sí | sí | sí | sí |
| M004 | `presentation/formatters/vessel_error_message.dart:54` | No se pudo interpretar el segmento {segmento} (n.º {n} del archivo) del BAPLIE: trae un dato que el lector no esperaba. Revisa ese segmento en el archivo o pide una nueva exportación. (Fuera de la carga: «los segmentos UNH y DTM», «el segmento TDT»…) | falla | sí | sí | sí | sí |
| M005 | `presentation/formatters/vessel_error_message.dart:76` | Hay un perfil con el mismo nombre y no se puede identificar el buque. Confirma su identidad antes de guardar. | rechazo | sí | sí | no | — |
| M006 | `presentation/formatters/vessel_error_message.dart:81` | No se pudo {la operación que nombra el llamador\|completar la operación}: falló la lectura o la escritura de los datos guardados en este dispositivo. Inténtalo de nuevo y, si se repite, reinicia la aplicación. | falla | sí | sí | no | — |
|  | **Carga del BAPLIE, perfil y viajes (vessel_providers.dart y pantallas)** |  |  |  |  |  |  |
| M007 | `presentation/pages/vessel_overview_page.dart:224` | No se pudo guardar la preferencia de la barra por un error interno de la aplicación; el detalle técnico quedó en el registro. Inténtalo de nuevo y, si se repite, reinicia la aplicación. (con el almacén local: «…: falló la lectura o la escritura de los datos guardados en este dispositivo. Inténtalo de nuevo y, si se repite, reinicia la aplicación.») | falla | sí | sí | no | — |
| M008 | `presentation/pages/vessel_overview_page.dart:384` | No se pudo exportar {PDF\|CSV\|JSON} por un error interno de la aplicación; el detalle técnico quedó en el registro. Inténtalo de nuevo y, si se repite, reinicia la aplicación. (con el almacén local: «…: falló la lectura o la escritura de los datos guardados en este dispositivo. Inténtalo de nuevo y, si se repite, reinicia la aplicación.») | falla | sí | sí | no | — |
| M009 | `presentation/providers/vessel_providers.dart:166` | No hay un buque nuevo confirmado para usar la plantilla. Confirma primero el buque o inicia otra carga. | rechazo | sí | sí | no | — |
| M010 | `presentation/providers/vessel_providers.dart:218,255,530,571,627` | Ya hay una carga en curso. Termínala o cancélala antes de abrir otra. | rechazo | sí | sí | no | — |
| M011 | `presentation/providers/vessel_providers.dart:309,475` | Hay una operación en curso. Espera a que termine e inténtalo de nuevo. | rechazo | sí | sí | no | — |
| M012 | `presentation/providers/vessel_providers.dart:314` | No hay una identidad pendiente. Carga un BAPLIE para elegir el buque. | rechazo | sí | sí | no | — |
| M013 | `presentation/providers/vessel_providers.dart:318` | El perfil no corresponde a este buque. Elige uno de los perfiles propuestos. | validación | sí | sí | no | — |
| M014 | `presentation/providers/vessel_providers.dart:323` | No se pueden distinguir estos buques solo por nombre. Pide una exportación con IMO o indicativo en el archivo. | rechazo | sí | sí | no | — |
| M015 | `presentation/providers/vessel_providers.dart:442,492` | Falta indicar si este BAPLIE es de llegada o de carga: elige una opción. | validación | sí | sí | no | — |
| M016 | `presentation/providers/vessel_providers.dart:478` | La identidad del buque está sin confirmar: confírmala primero. | validación | sí | sí | no | — |
| M017 | `presentation/providers/vessel_providers.dart:482` | No hay un viaje para confirmar. Carga un BAPLIE primero. | rechazo | sí | sí | no | — |
| M018 | `presentation/providers/vessel_providers.dart:485` | La geometría deja posiciones del archivo fuera del plano. Amplía las filas o niveles para incluirlas. | validación | sí | sí | no | — |
| M019 | `presentation/providers/vessel_providers.dart:534` | La edición de parámetros no permite cambiar la identidad del buque. Abre el perfil correcto antes de editar. | rechazo | sí | sí | no | — |
| M020 | `presentation/providers/vessel_providers.dart:540` | La geometría deja posiciones del viaje abierto fuera del plano. Amplía las filas o niveles para incluirlas. | validación | sí | sí | no | — |
| M021 | `presentation/providers/vessel_providers.dart:551` | El perfil cambió. Vuelve a abrirlo antes de editar. | rechazo | sí | sí | no | — |
| M022 | `presentation/providers/vessel_providers.dart:579` | El viaje ya no está guardado. Vuelve a cargar su BAPLIE. | falla | sí | sí | no | — |
| M023 | `presentation/providers/vessel_providers.dart:583` | Este viaje no tiene una geometría válida guardada. Vuelve a cargar el BAPLIE. | falla | sí | sí | no | — |
| M024 | `data/services/baplie_parser_service.dart:163` | Archivo «{nombre}»: Versión BAPLIE no admitida: la cabecera UNH declara {identificador S009}. BayStream lee la familia 2.x (SMDG20, SMDG21 y SMDG22). [El archivo contiene más de un mensaje.] Pide una exportación compatible. | falla | sí | sí | sí | sí |
| M025 | `presentation/pages/recent_voyages_page.dart:36` | No se aplicó del perfil vigente: {parámetros}. Dejaría contenedores de este viaje fuera del plano; se conserva el valor guardado con el viaje. Revisa el perfil del buque. | aviso de datos | sí | sí | no | — |
| M026 | `presentation/pages/parameters_page.dart:38` | No se pudo guardar el tema por un error interno de la aplicación; el detalle técnico quedó en el registro. Inténtalo de nuevo y, si se repite, reinicia la aplicación. (con el almacén local: «…: falló la lectura o la escritura de los datos guardados en este dispositivo. Inténtalo de nuevo y, si se repite, reinicia la aplicación.») | falla | sí | sí | no | — |
| M027 | `presentation/pages/parameters_page.dart:48` | No se pudo leer el tema guardado: falló la lectura de las preferencias de este dispositivo; se usa el del sistema. Elígelo de nuevo. | falla | sí | sí | no | — |
| M028 | `lib/main.dart:67` | Falta la configuración de Firebase · Esta versión de BayStream no tiene todas las opciones necesarias para iniciar. Solicita una compilación configurada al responsable. | falla | sí | sí | no | — |
|  | **Cuenta y nube (Nube y cuenta)** |  |  |  |  |  |  |
| M029 | `data/repositories/firebase_session_repository.dart:174` | Correo o contraseña incorrectos. Revísalos e inténtalo de nuevo, o usa «Olvidé mi contraseña». | rechazo | sí | sí | no | — |
| M030 | `data/repositories/firebase_session_repository.dart:186` | El correo no es válido: escríbelo completo, como nombre@dominio. | validación | sí | sí | no | — |
| M031 | `data/repositories/firebase_session_repository.dart:177` | Esta cuenta está deshabilitada. Habla con el responsable. | rechazo | sí | sí | no | — |
| M032 | `data/repositories/firebase_session_repository.dart:178` | Demasiados intentos. Espera un momento. | rechazo | sí | sí | no | — |
| M033 | `data/repositories/firebase_session_repository.dart:180` | Sin conexión: iniciar sesión requiere red. Conéctate e inténtalo de nuevo. | falla | sí | sí | no | — |
| M034 | `data/repositories/firebase_session_repository.dart:190` | No se pudo iniciar sesión: el servicio de cuentas respondió con un error que BayStream no reconoce; el código quedó en el registro. Inténtalo de nuevo y, si se repite, avisa al responsable. | falla | sí | sí | no | — |
| M035 | `data/repositories/firebase_session_repository.dart:164` | No se pudo iniciar sesión por un error inesperado del servicio de cuentas; el detalle quedó en el registro. Inténtalo de nuevo. | falla | sí | sí | no | — |
| M036 | `data/repositories/firebase_session_repository.dart:212` | No se pudo cerrar la sesión por un error del servicio de cuentas; el detalle quedó en el registro. Inténtalo de nuevo. | falla | sí | sí | no | — |
| M037 | `data/repositories/firebase_session_repository.dart:197` | No se pudo enviar el correo de recuperación: el servicio de cuentas respondió con un error; el código quedó en el registro. Revisa la conexión y el correo, e inténtalo de nuevo. | falla | sí | sí | no | — |
| M038 | `presentation/pages/cloud_page.dart:144` | Falta el correo: escríbelo para recuperar la contraseña. | validación | sí | sí | no | — |
| M039 | `presentation/pages/cloud_page.dart:248` | No hay un plano abierto con perfil de buque: abre el plano de la escala para publicarla con su perfil. | rechazo | sí | sí | no | — |
| M040 | `presentation/pages/cloud_page.dart:300` | No se pudieron leer las operaciones abiertas de la nube: puede faltar la conexión o el permiso de la cuenta. Revisa la conexión y la cuenta. | falla | sí | sí | no | — |
| M041 | `presentation/pages/cloud_page.dart:386` | La operación no tiene esa fuente: la oficina no la publicó. Abre otra fuente o pide a la oficina que la publique. | rechazo | sí | sí | no | — |
| M042 | `presentation/pages/cloud_page.dart:376` | No se abrió la fuente publicada: la lectura terminó sin el viaje ni un motivo. Inténtalo de nuevo y, si se repite, avisa al responsable. | falla | sí | sí | no | — |
| M043 | `data/repositories/firestore_operation_sync.dart:56` | Publicar y cerrar exige sesión: inicia sesión con una cuenta de oficina. | rechazo | sí | sí | no | — |
| M044 | `data/repositories/firestore_operation_sync.dart:61` | Solo una cuenta de oficina autorizada publica y cierra operaciones: inicia sesión con una o pide al responsable que autorice la tuya. | rechazo | sí | sí | no | — |
| M045 | `data/repositories/firestore_operation_sync.dart:131` | Sin respuesta de la nube. Publicar requiere conexión: revisa la red e inténtalo de nuevo. | falla | sí | sí | no | — |
| M046 | `data/repositories/firestore_operation_sync.dart:138` | La nube no aceptó la publicación: revisa que la cuenta sea de oficina y esté activa. | rechazo | sí | sí | no | — |
| M047 | `data/repositories/firestore_operation_sync.dart:140` | Sin conexión con la nube: publicar o cerrar requiere red. Conéctate e inténtalo de nuevo. | falla | sí | sí | no | — |
| M048 | `data/repositories/firestore_operation_sync.dart:148` | La nube devolvió un error que BayStream no reconoce; el código técnico quedó en el registro. Inténtalo de nuevo y, si se repite, avisa al responsable. | falla | sí | sí | no | — |
| M049 | `data/repositories/firestore_operation_sync.dart:199` | La operación ya no está en la nube: se retiró después de publicarse. Pide a la oficina que la publique de nuevo. | falla | sí | sí | no | — |
| M050 | `data/repositories/firestore_operation_sync.dart:224` | La fuente «{plano de llegada\|plan de carga\|listado de la agencia}» llegó incompleta o distinta de la publicada. No se guardó nada: vuelve a intentarlo. | falla | sí | sí | no | — |
| M051 | `data/repositories/firestore_operation_sync.dart:248` | Tu cuenta no puede leer esta operación: revisa que esté autorizada. | rechazo | sí | sí | no | — |
| M052 | `data/repositories/firestore_operation_sync.dart:249` | Sin conexión con la nube: unirse requiere red. Conéctate e inténtalo de nuevo. | falla | sí | sí | no | — |
| M053 | `data/repositories/firestore_operation_sync.dart:254` | Sin respuesta de la nube: unirse requiere red. Revisa la red e inténtalo de nuevo. | falla | sí | sí | no | — |
| M054 | `data/repositories/firestore_operation_sync.dart:282` | No se encontró la operación para cerrarla en este dispositivo o en la nube. Vuelve a abrir «Nube y cuenta» e inténtalo de nuevo. | falla | sí | sí | no | — |
| M055 | `data/repositories/firestore_operation_sync.dart:292` | Sin respuesta de la nube: cerrar requiere red. Revisa la red e inténtalo de nuevo. | falla | sí | sí | no | — |
| M056 | `data/repositories/local_only_operation_sync.dart:19` | Esta compilación no tiene la nube configurada: la app trabaja en un solo dispositivo. Para sincronizar, pide al responsable una compilación con la nube. | rechazo | sí | sí | no | — |
| M057 | `domain/services/operation_sources.dart:52` | La operación de esta escala ya está publicada y sus fuentes no cambian. Abre la fuente publicada desde «Nube y cuenta». | rechazo | sí | sí | no | — |
|  | **Estado de envío con error (sync_status_chip.dart: barra, Bay Plan, Avance, Solicitudes)** |  |  |  |  |  |  |
| M058 | `presentation/widgets/sync_status_chip.dart:32` | Sesión vencida: inicia sesión para enviar {n} | estado de error | sí | sí | no | — |
| M059 | `presentation/widgets/sync_status_chip.dart:35` | Tu cuenta no está autorizada · {n} espera(n) · pide al responsable que la autorice | estado de error | sí | sí | no | — |
| M060 | `presentation/widgets/sync_status_chip.dart:36` | Sesión sin confirmar desde las {hh:mm} · inicia sesión de nuevo | estado de error | sí | sí | no | — |
| M061 | `presentation/widgets/sync_status_chip.dart:41` | {n} rechazado(s) por la nube, fuera del plan: regístralo(s) de nuevo si hace(n) falta | estado de error | sí | sí | no | — |
|  | **Registro de movimientos (bitácora y validación del borrador)** |  |  |  |  |  |  |
| M062 | `data/repositories/movement_log_repository_impl.dart:46` | No se pudo usar la bitácora local de este dispositivo: falló su lectura o su escritura y el movimiento no se registró. Inténtalo de nuevo y, si se repite, reinicia la aplicación. | falla | sí | sí | no | — |
| M063 | `domain/entities/movement.dart:325` | Este tipo de movimiento no admite corrección: deshazlo y regístralo de nuevo. | validación | sí | sí | no | — |
| M064 | `domain/entities/movement.dart:331` | Falta el número de contenedor: escríbelo. | validación | sí | sí | no | — |
| M065 | `domain/entities/movement.dart:334` | La posición debe tener 6 o 7 cifras (BBBRRTT): corrígela. | validación | sí | sí | no | — |
| M066 | `domain/entities/movement.dart:338` | Falta la celda reservada: elige una. | validación | sí | sí | no | — |
| M067 | `domain/entities/movement.dart:342` | Falta el número del vacío: indícalo. | validación | sí | sí | no | — |
| M068 | `domain/entities/movement.dart:346` | Tara fuera de rango: debe ser mayor que 0 y menor que 15 000 kg. Corrígela. | validación | sí | sí | no | — |
| M069 | `domain/entities/movement.dart:351` | Falta el movimiento a anular: vuelve a elegirlo en el detalle de la celda. | validación | sí | sí | no | — |
| M070 | `domain/entities/movement.dart:353` | Anular exige un motivo: escríbelo. | validación | sí | sí | no | — |
| M071 | `domain/entities/movement.dart:357` | Falta el contenedor o la reserva a cancelar: vuelve a elegirlo en el plano. | validación | sí | sí | no | — |
| M072 | `domain/entities/movement.dart:360` | Cancelar exige un motivo de hasta 300 caracteres: escríbelo. | validación | sí | sí | no | — |
| M073 | `domain/entities/movement.dart:365` | El cambio llegó mal armado: sus objetos van en la lista, no aparte. Vuelve a abrir el formulario y repite el cambio. | validación | sí | sí | no | — |
| M074 | `domain/entities/movement.dart:369,383` | Falta el motivo: escribe uno de hasta 300 caracteres. | validación | sí | sí | no | — |
| M075 | `domain/entities/movement.dart:380` | Falta la solicitud que se rechaza: vuelve a abrirla desde la bandeja. | validación | sí | sí | no | — |
| M076 | `domain/entities/movement.dart:389` | Falta la tapa o la acción: indica una tapa y si se quita o se repone. | validación | sí | sí | no | — |
|  | **Cambios del plan (arrastre, solicitudes, oficina)** |  |  |  |  |  |  |
| M077 | `domain/services/change_requests.dart:14` | Mover exige una cuenta autorizada: inicia sesión o pide al responsable que autorice la tuya. (También al mantener pulsada una celda sin sesión.) | rechazo | sí | sí | no | — |
| M078 | `domain/services/change_requests.dart:30; domain/entities/movement.dart:373` | Los cambios de la solicitud no son válidos: indica de uno a cuatro, sin repetir objetos ni destinos. | validación | sí | sí | no | — |
| M079 | `domain/services/change_requests.dart:40` | Solo se mueve un objeto pendiente del plan de carga: este ya se cargó o se canceló. Elige uno pendiente. | rechazo | sí | sí | no | — |
| M080 | `domain/services/change_requests.dart:51` | Las reservas del intercambio deben ser del mismo grupo (tipo, POD y línea): elige reservas iguales. | validación | sí | sí | no | — |
| M081 | `domain/services/change_requests.dart:74` | Solo se cancela un objeto pendiente del plan de carga: este ya se cargó o ya está cancelado. Si se cargó, deshaz antes la carga. | rechazo | sí | sí | no | — |
| M082 | `domain/services/change_requests.dart:99` | El cambio de oficina ya no está vigente: vuelve a abrir el detalle para ver el estado actual. | rechazo | sí | sí | no | — |
| M083 | `domain/services/change_requests.dart:104` | Deshacer exige un motivo de hasta 300 caracteres: escríbelo. | validación | sí | sí | no | — |
| M084 | `domain/services/change_requests.dart:113` | Solo una cuenta de muelle autorizada puede pedir cambios: inicia sesión con una. | rechazo | sí | sí | no | — |
| M085 | `domain/services/change_requests.dart:115` | Solo una cuenta de oficina autorizada puede decidir: inicia sesión con una. | rechazo | sí | sí | no | — |
| M086 | `domain/services/change_requests.dart:12` | La operación debe estar publicada y abierta: la oficina la publica desde «Nube y cuenta»; si ya se cerró, no admite cambios. (También en el arrastre.) | rechazo | sí | sí | no | — |
| M087 | `domain/services/change_requests.dart:128` | Los cambios no son válidos: indica de uno a cuatro. | validación | sí | sí | no | — |
| M088 | `domain/services/change_requests.dart:134` | {Objeto} no está en el plan de carga: revisa el OR o el número. | validación | sí | sí | no | — |
| M089 | `domain/services/change_requests.dart:138` | El origen de {objeto} cambió; revisa la solicitud. | validación | sí | sí | no | — |
| M090 | `domain/services/change_requests.dart:144` | La celda {BBBRRTT} no existe en la geometría del buque: elige una celda del plano. | validación | sí | sí | no | — |
| M091 | `domain/services/change_requests.dart:152` | {Objeto} no cabe en la bahía {n}: un 20 va en bahía impar y un 40 en par. Elige una bahía de su tamaño. | validación | sí | sí | no | — |
| M092 | `domain/services/change_requests.dart:171` | {destino} choca con {objeto} en {posición}[: un 40 ocupa las dos mitades de la celda.] Es carga de paso: no se descarga aquí. Elige otra celda. | validación | sí | sí | no | — |
| M093 | `domain/services/change_requests.dart:173` | {destino} choca con {objeto} en {posición}[…] La celda está ocupada a bordo; marca primero su descarga. | validación | sí | sí | no | — |
| M094 | `domain/services/change_requests.dart:200` | {destino} choca con {objeto} en {posición}[…] La celda está prevista para otro objeto; inclúyelo en el intercambio. | validación | sí | sí | no | — |
| M095 | `domain/services/change_requests.dart:251` | {destino} choca con {objeto} en {posición}[…] Un 20 y un 40 no se intercambian: elige otra celda del mismo tamaño. | validación | sí | sí | no | — |
| M096 | `domain/services/change_requests.dart:259` | {destino} choca con {objeto} en {posición}[: un 40 ocupa las dos mitades de la celda.] Elige otra celda. (sin regla que agregar) | validación | sí | sí | no | — |
| M097 | `domain/services/change_requests.dart:278` | La solicitud ya no está pendiente: ya se decidió o se anuló. Vuelve a la bandeja para ver su estado. | rechazo | sí | sí | no | — |
| M098 | `presentation/widgets/plan_drag_confirmation.dart:194` | El arrastre solo mueve dentro de la bahía: para otra bahía utiliza el formulario. | rechazo | sí | sí | no | — |
| M099 | `presentation/formatters/vessel_error_message.dart:34` | La operación todavía no se cargó o cambió mientras tanto: espera un momento e inténtalo de nuevo. (Arrastre, acciones de oficina y solicitudes.) | falla | sí | sí | no | — |
|  | **Registro de carga (diálogo Confirmar carga y revisión)** |  |  |  |  |  |  |
| M100 | `domain/services/loading_operation.dart:240,257` | La escala no tiene operación guardada: vuelve a abrir el plan de carga y confirma la escala. | rechazo | sí | sí | no | — |
| M101 | `domain/services/loading_operation.dart:261` | El OR ya no está en el listado de la agencia: importa de nuevo el listado. | rechazo | sí | sí | no | — |
| M102 | `domain/services/loading_operation.dart:268` | La corrección exige un movimiento vigente y un motivo: elige la carga vigente y escribe el motivo. | validación | sí | sí | no | — |
| M103 | `domain/services/loading_operation.dart:275; domain/services/load_check.dart:181; presentation/widgets/office_plan_controls.dart:77` | Cancelado por la oficina. Debe deshacer la cancelación antes de cargar. | rechazo | sí | sí | no | — |
| M104 | `domain/services/loading_operation.dart:277` | El contenedor ya está operado: para cambiarlo, abre su detalle y usa Corregir o Deshacer carga. | rechazo | sí | sí | no | — |
| M105 | `domain/services/loading_operation.dart:285` | Un vacío se asigna a una celda reservada del plan: elige una celda reservada. | validación | sí | sí | no | — |
| M106 | `domain/services/loading_operation.dart:289` | La reserva está cancelada: elige otra o pide a la oficina que deshaga la cancelación. | rechazo | sí | sí | no | — |
| M107 | `domain/services/loading_operation.dart:299` | La celda la ocupa {contenedor}, que baja aquí: marca primero su descarga. | validación | sí | sí | no | — |
| M108 | `domain/services/loading_operation.dart:303` | Esta carga se registra solo con un motivo escrito: escribe el motivo para registrarla. | validación | sí | sí | no | — |
| M109 | `domain/services/load_check.dart:162` | [No se registra:] La posición «{posición}» no tiene la forma BBB-RR-TT: escríbela así, por ejemplo 012-04-82. | validación | sí | sí | no | — |
| M110 | `domain/services/load_check.dart:192` | No se registra: Un contenedor de {n} pies ({tipo}) no cabe en {celda}: la bahía {b} es {impar, de 20\|par, de 40} pies. Elige una celda de su tamaño. | validación | sí | sí | no | — |
| M111 | `domain/services/load_check.dart:204` | Pide motivo: OR {n} está planificado en {celda}; en {celda} quedará «fuera de plan»[, y {celda} es la celda de {objeto}]. Para cargarlo ahí, escribe el motivo; si no, usa la celda planificada. | aviso de datos | sí | sí | no | — |
| M112 | `domain/services/load_check.dart:218` | Pide motivo: La reserva {celda} es de otro grupo ({diferencias}); el OR {n} es {tipo} · {POD} · {línea}. Para cargarlo ahí, escribe el motivo; si no, elige una reserva de su grupo. | aviso de datos | sí | sí | no | — |
| M113 | `domain/services/load_check.dart:234` | Pide motivo: {celda} la ocupa {objeto}, que no baja en {escala}: la celda está ocupada. Para cargarlo ahí, escribe el motivo; si no, elige otra celda. | aviso de datos | sí | sí | no | — |
| M114 | `domain/services/load_check.dart:269` | No se registra: La bahía {b} no existe en este buque: {celda} no se puede registrar. Elige una celda de una bahía del buque. | validación | sí | sí | no | — |
| M115 | `domain/services/load_check.dart:274` | No se registra: {celda} no existe en la geometría del buque (fila {f}, nivel {n}). Revisa la celda o amplía la geometría en Parámetros del buque. | validación | sí | sí | no | — |
| M116 | `domain/services/load_check.dart:243` | Pide motivo: {Pila de cubierta\|bodega} {bahía}, fila {f}: quedaría en {x} t y el límite del perfil es {y} t[; {n} contenedores de la pila no traen peso, el peso real es mayor]. Para cargarlo ahí, escribe el motivo; si no, elige otra pila. | aviso de datos | sí | sí | no | — |
| M117 | `presentation/widgets/loading_controls.dart:40` | Este contenedor no tiene OR en el listado de la agencia: importa el listado actualizado. | rechazo | sí | sí | no | — |
| M118 | `presentation/widgets/loading_controls.dart:425` | Hora no válida: escríbela como HH:mm (00:00 a 23:59). | validación | sí | sí | no | — |
|  | **Descarga y tapas** |  |  |  |  |  |  |
| M119 | `presentation/widgets/discharge_controls.dart:157` | Esta escala no tiene operación guardada: vuelve a abrir el BAPLIE de llegada y confirma la escala. | rechazo | sí | sí | no | — |
| M120 | `domain/entities/hatch_covers.dart:38` | Una bahía sin bodega no puede declarar tapas: déjala «Sin declarar». | validación | sí | sí | no | — |
| M121 | `domain/entities/hatch_covers.dart:43` | Una bodega abierta no lleva tapas: quita las filas de tapa. | validación | sí | sí | no | — |
| M122 | `domain/entities/hatch_covers.dart:46` | Falta la tapa automática o hay más de una: declara exactamente una. | validación | sí | sí | no | — |
| M123 | `domain/entities/hatch_covers.dart:49` | Faltan las tapas de grúa o hay más de tres: declara de una a tres. | validación | sí | sí | no | — |
| M124 | `domain/entities/hatch_covers.dart:54` | La tapa {n} necesita al menos una fila: escribe sus filas. | validación | sí | sí | no | — |
| M125 | `domain/entities/hatch_covers.dart:65` | La fila {nn} de la tapa {n} no pertenece a la geometría de bodega de esta bahía. Usa filas de esa geometría. | validación | sí | sí | no | — |
| M126 | `domain/entities/hatch_covers.dart:69` | La fila {nn} se solapa entre tapas: déjala en una sola. | validación | sí | sí | no | — |
| M127 | `presentation/pages/hatch_covers_page.dart:71` | Tapa {n}: las filas no tienen el formato esperado; escribe filas de uno o dos dígitos separadas por coma. | validación | sí | sí | no | — |
| M128 | `presentation/pages/hatch_covers_page.dart:77` | Tapa {n}: hay una fila repetida; quítala. | validación | sí | sí | no | — |
|  | **Listado de la agencia** |  |  |  |  |  |  |
| M129 | `presentation/providers/export_list_providers.dart:132` | El archivo está vacío o no se pudo leer: vuelve a elegir el Excel (.xlsx) de la agencia. | falla | sí | sí | no | — |
| M130 | `presentation/providers/export_list_providers.dart:143` | No hay un plan de carga confirmado: abre primero el plan de carga y confirma la escala. | rechazo | sí | sí | no | — |
| M131 | `presentation/pages/export_list_import_page.dart:40` | No hay un plan de carga confirmado: abre primero el plan de carga (BAPLIE) y confirma la escala. | rechazo | sí | sí | no | — |
| M132 | `presentation/providers/export_list_providers.dart:206` | No hay un listado leído para importar: elige primero el Excel de la agencia. | rechazo | sí | sí | no | — |
| M133 | `presentation/providers/export_list_providers.dart:211` | Falta elegir equivalencias: {códigos}. Elige una para cada código antes de importar. | validación | sí | sí | no | — |
| M134 | `presentation/providers/export_list_providers.dart:213` | Hay una operación en curso: espera a que termine. | rechazo | sí | sí | no | — |
| M135 | `presentation/pages/export_list_import_page.dart:93` | Falta elegir {n} equivalencias antes de importar. Elige una para cada código pendiente. | validación | sí | sí | no | — |
| M136 | `data/repositories/export_list_repository_impl.dart:26` | No se pudo leer el listado por un error interno de la aplicación; el detalle técnico quedó en el registro. Revisa que sea el Excel de la agencia e inténtalo de nuevo. | falla | sí | sí | no | — |
| M137 | `data/services/export_list_parser_service.dart:65` | El archivo no es un libro de Excel (.xlsx) legible: guárdalo como .xlsx desde Excel y vuelve a elegirlo. | falla | sí | sí | Excel | — |
| M138 | `data/services/export_list_parser_service.dart:79` | El libro no tiene hojas con datos: elige el listado de la agencia. | falla | sí | sí | Excel | — |
| M139 | `data/services/export_list_parser_service.dart:160` | No se encontró la fila de encabezados del listado (OR, CONTENEDOR, TIPO…): revisa que sea el listado de exportación de la agencia. | falla | sí | sí | Excel | — |
| M140 | `data/services/export_list_parser_service.dart:174` | Al listado le faltan columnas: {columnas}. Pide a la agencia el listado completo. | falla | sí | sí | Excel | — |
| M141 | `presentation/pages/export_list_import_page.dart:205` | Fila {n}: OR {orden}: {falta el número de contenedor; el contenedor «x» no tiene la forma ISO 6346 …; marca lleno (F) y vacío (E) a la vez; …}. Corrige esa fila en el Excel y vuelve a importarlo. | aviso de datos | sí | sí | Excel | — |
| M142 | `presentation/pages/export_list_import_page.dart:205` | Fila {n}: No es un contenedor ni un separador de agencia: «{texto}». Corrige esa fila en el Excel y vuelve a importarlo. | aviso de datos | sí | sí | Excel | — |
|  | **BAPLIE de salida** |  |  |  |  |  |  |
| M143 | `domain/services/departure_baplie_writer.dart:19` | La operación no tiene el plan de carga (BAPLIE): impórtalo antes de generar la salida. | rechazo | sí | sí | no | — |
| M144 | `domain/services/departure_baplie_writer.dart:25` | No está disponible el plan efectivo de la operación: espera a que termine de cargar e inténtalo de nuevo. | falla | sí | sí | no | — |
| M145 | `domain/services/departure_baplie_writer.dart:46` | Hay ocupantes duplicados en el estado derivado; resuelve el conflicto antes de generar. | conflicto | sí | sí | no | — |
| M146 | `domain/services/departure_baplie_writer.dart:56` | Falta la fuente del ocupante {contenedor}; no se puede conservar su información. Vuelve a importar el plano de llegada y el plan de carga. | falla | sí | sí | no | — |
| M147 | `domain/services/departure_baplie_writer.dart:69` | El contenedor cargado {contenedor} no está en el listado; faltan sus datos exactos. Importa el listado de la agencia que lo incluye. | falla | sí | sí | no | — |
| M148 | `domain/services/departure_baplie_writer.dart:186` | El listado contiene un peso inválido: corrige los pesos en el Excel y vuelve a importarlo. | aviso de datos | sí | sí | no | — |
| M149 | `domain/services/departure_baplie_writer.dart:197` | El listado no declara lleno/vacío para {contenedor}: corrige esa fila en el Excel y vuelve a importarlo. | aviso de datos | sí | sí | no | — |
| M150 | `domain/services/departure_baplie_writer.dart:201` | El listado no declara el VGM de {contenedor}: pide el VGM a la agencia y vuelve a importar el listado. | aviso de datos | sí | sí | no | — |
| M151 | `domain/services/departure_baplie_writer.dart:235` | El plan de carga debe contener un único mensaje BAPLIE con sus segmentos UNB y UNH: no se generó la salida. Vuelve a importar el plan de carga. | falla | sí | sí | sí | sí |
| M152 | `domain/services/departure_baplie_writer.dart:244` | Versión BAPLIE no reconocida para salida 2.x en la cabecera UNH: {identificador\|sin cabecera}. No se generó el archivo. Importa el plan de carga en SMDG20, SMDG21 o SMDG22. | falla | sí | sí | sí | sí |
| M153 | `domain/services/departure_baplie_writer.dart:288` | Separadores EDIFACT no reconocidos en el segmento UNA del plan de carga: no se generó la salida. Pide una exportación con los separadores estándar. | falla | sí | sí | sí | sí |
| M154 | `presentation/pages/departure_baplie_page.dart:56` | No se genera el BAPLIE de salida: «{archivo}» es versión 1.5 (SMDG15) y se leyó con las reglas de 2.x. Escribir la salida con esas reglas no sería fiel a lo que llegó. Importa el plano en SMDG20, SMDG21 o SMDG22. | rechazo | sí | sí | no | — |
| M155 | `presentation/pages/departure_baplie_page.dart:96` | La escala no tiene una operación guardada con su plan de carga: abre el plan de carga (BAPLIE) y confirma la escala. | rechazo | sí | sí | no | — |
| M156 | `presentation/pages/departure_baplie_page.dart:193` | La operación se está actualizando. Intenta de nuevo. | falla | sí | sí | no | — |
|  | **Comparar BAPLIE** |  |  |  |  |  |  |
| M157 | `domain/services/voyage_comparison.dart:128` | No se puede confirmar que sea el mismo buque: {motivo}. Confirma que es el mismo buque antes de usar la comparación. | aviso de datos | sí | sí | no | — |
| M158 | `domain/services/voyage_comparison.dart:133` | No parece el mismo buque: {nombre} ({clave}) y {nombre} ({clave}). Revisa que el segundo archivo sea del mismo buque. | aviso de datos | sí | sí | no | — |
|  | **Parámetros del buque (validación del formulario y de las tomas)** |  |  |  |  |  |  |
| M159 | `presentation/pages/vessel_geometry_page.dart:870` | Valor no numérico: escribe un número. | validación | sí | sí | no | — |
| M160 | `presentation/pages/vessel_geometry_page.dart:873` | No puede ser menor que {mínimo}: escribe {mínimo} o más. | validación | sí | sí | no | — |
| M161 | `presentation/pages/vessel_geometry_page.dart:875` | El archivo trae carga en {la fila nn}; con {v} {filas a babor\|estribor} quedaría fuera del plano. Escribe al menos {mínimo}. | validación | sí | sí | no | — |
| M162 | `presentation/pages/vessel_geometry_page.dart:1035` | Falta el límite de apilamiento: escríbelo o marca que no lo tienes. | validación | sí | sí | no | — |
| M163 | `presentation/pages/vessel_geometry_page.dart:520` | Posición de toma no válida: escribe siete dígitos y una bahía distinta de 000. | validación | sí | sí | no | — |
| M164 | `presentation/pages/vessel_geometry_page.dart:552,569` | La frontera y las anclas no forman una geometría válida: revísalas antes de cargar tomas. | validación | sí | sí | no | — |
| M165 | `presentation/pages/vessel_geometry_page.dart:572` | No hay códigos pegados: pega al menos uno. | validación | sí | sí | no | — |
| M166 | `presentation/pages/vessel_geometry_page.dart:312` | Revisa frontera y anclas: bodega debajo de la frontera y cubierta desde ella. | validación | sí | sí | no | — |
| M167 | `presentation/pages/vessel_geometry_page.dart:424` | Falta resolver el límite de apilamiento: escríbelo o marca que no lo tienes. | validación | sí | sí | no | — |
| M168 | `domain/services/reefer_socket_ranges.dart:44` | {Bahías\|Filas\|Niveles}: «{x}» no es un número ni un rango como 02-08. Escribe un número o un rango así. | validación | sí | sí | no | — |
| M169 | `domain/services/reefer_socket_ranges.dart:55` | {campo}: «{x}» sale de {mín} a {máx}. Escribe valores entre esos dos. | validación | sí | sí | no | — |
| M170 | `domain/services/reefer_socket_ranges.dart:61` | {campo}: en «{x}» el final es menor que el inicio: escribe primero el menor. | validación | sí | sí | no | — |
| M171 | `domain/services/reefer_socket_ranges.dart:68` | {campo}: en «{x}» el paso tiene que ser 1 o más: escríbelo así, como 002-038/4. | validación | sí | sí | no | — |
| M172 | `domain/services/reefer_socket_ranges.dart:96` | Faltan las bahías: escribe al menos una. | validación | sí | sí | no | — |
| M173 | `domain/services/reefer_socket_ranges.dart:102` | Faltan los niveles: escribe al menos uno. | validación | sí | sí | no | — |
| M174 | `domain/services/reefer_socket_ranges.dart:130` | El rango genera {n} códigos; el máximo es {m}. Acótalo. | validación | sí | sí | no | — |
|  | **Búsqueda por voz** |  |  |  |  |  |  |
| M175 | `presentation/widgets/voice_search_field.dart:119` | Permiso de micrófono denegado. Puedes escribir la búsqueda. | falla | sí | sí | no | — |
| M176 | `presentation/widgets/voice_search_field.dart:121` | Reconocimiento sin conexión o servicio no disponible. Puedes escribir la búsqueda. | falla | sí | sí | no | — |
| M177 | `presentation/widgets/voice_search_field.dart:123` | No se entendió el dictado. Reintenta o escribe la búsqueda. | falla | sí | sí | no | — |
| M178 | `presentation/widgets/voice_search_field.dart:125` | Reconocimiento en español no disponible. Puedes escribir la búsqueda. | falla | sí | sí | no | — |
| M179 | `presentation/widgets/voice_search_field.dart:127` | Reconocimiento de voz no disponible. Puedes escribir la búsqueda. | falla | sí | sí | no | — |
|  | **Avisos de lectura del BAPLIE (tarjeta del viaje y Comparar)** |  |  |  |  |  |  |
| M180 | `presentation/widgets/voyage_summary_card.dart:8` | Versión 1.5 (la cabecera UNH declara SMDG15), leída con las reglas de 2.x; revisa pesos y peligrosas | aviso de datos | sí | sí | sí | sí |
| M181 | `presentation/widgets/voyage_summary_card.dart:324` | Pesos revisados en MEA: {n} contenedor(es) · revisa esos pesos antes de operar · detalle: «{número}: WT en LBR convertido a {x} kg», … | aviso de datos | sí | sí | sí | sí |
| M182 | `presentation/widgets/voyage_summary_card.dart:325` | Posiciones mal formadas en LOC+147: {n} contenedor(es) · pide una exportación corregida · detalle: «{número}: {posición}» | aviso de datos | sí | sí | sí | sí |
| M183 | `presentation/widgets/voyage_summary_card.dart:326` | Dígito de control inválido en EQD: {n} contenedor(es) · revisa esos números con la agencia · detalle: «{número}» | aviso de datos | sí | sí | sí | sí |
| M184 | `presentation/widgets/voyage_summary_card.dart:327` | Archivo posiblemente incompleto: faltan {n} segmentos ({UNB, BGM, UNT, UNZ}) · detalle: «El archivo puede venir incompleto. Revisa los segmentos que faltan:» | aviso de datos | sí | sí | sí | sí |
|  | **Rejilla y geometría (Bay Plan y Orden de descarga)** |  |  |  |  |  |  |
| M185 | `presentation/widgets/bay_plan_view.dart:964` | {n} contenedores fuera de la geometría declarada · No se dibujan en la rejilla porque su posición no existe en el buque declarado: {posiciones}. Amplía la geometría en Parámetros del buque. | aviso de datos | sí | sí | no | — |
| M186 | `presentation/widgets/bay_plan_view.dart:867` | {n} celdas reservadas fuera de la geometría declarada: {posiciones}[ y {n} más]. Amplía la geometría en Parámetros del buque. | aviso de datos | sí | sí | no | — |
| M187 | `presentation/widgets/bay_plan_view.dart:897` | Este viaje no trae la geometría del buque declarada, así que no hay rejilla contra la cual dibujarlo. Declara los parámetros del buque para ver el plano. | aviso de datos | sí | sí | no | — |
| M188 | `presentation/pages/discharge_sequence_page.dart:47` | La geometría del buque está sin confirmar: confírmala para sugerir el orden de descarga. | rechazo | sí | sí | no | — |
| M189 | `presentation/pages/discharge_sequence_page.dart:49` | El archivo no trae puertos de descarga (LOC+11) en ningún contenedor: no hay orden que sugerir. Pide una exportación del BAPLIE que los incluya. | aviso de datos | sí | sí | no | — |
|  | **Conflictos de la operación (detalle de la celda, Avance, Tapas en la operación)** |  |  |  |  |  |  |
| M190 | `domain/services/operation_state_deriver.dart:101` | Solicitud con cambios inválidos: no trae de uno a cuatro cambios válidos. Revísalo en la bandeja de cambios de la oficina. | conflicto | sí | sí | no | — |
| M191 | `domain/services/operation_state_deriver.dart:110` | La decisión cita una solicitud que no está vigente. Revísalo en la bandeja de cambios de la oficina. | conflicto | sí | sí | no | — |
| M192 | `domain/services/operation_state_deriver.dart:114` | La solicitud ya tiene una decisión o está en conflicto. Revísalo en la bandeja de cambios de la oficina. | conflicto | sí | sí | no | — |
| M193 | `domain/services/operation_state_deriver.dart:119` | El rechazo no cita una solicitud. Revísalo en la bandeja de cambios de la oficina. | conflicto | sí | sí | no | — |
| M194 | `domain/services/operation_state_deriver.dart:130` | El cambio no contiene de uno a cuatro cambios válidos. Revísalo en la bandeja de cambios de la oficina. | conflicto | sí | sí | no | — |
| M195 | `domain/services/operation_state_deriver.dart:134` | La aprobación no coincide con lo solicitado. Revísalo en la bandeja de cambios de la oficina. | conflicto | sí | sí | no | — |
| M196 | `domain/services/operation_state_deriver.dart:141` | {Objeto} no está en el plan de carga. Revísalo en la bandeja de cambios de la oficina. | conflicto | sí | sí | no | — |
| M197 | `domain/services/operation_state_deriver.dart:143` | {Objeto}: origen obsoleto; plan efectivo {p}, cambio desde {p}. Revísalo en la bandeja de cambios de la oficina. | conflicto | sí | sí | no | — |
| M198 | `domain/services/operation_state_deriver.dart:146` | {celda} está prevista para otro objeto del plan. Revísalo en la bandeja de cambios de la oficina. | conflicto | sí | sí | no | — |
| M199 | `domain/services/operation_state_deriver.dart:295` | {tapa}: tapa sin declarar o acción inválida. Si el registro fue un error, deshazlo con «Deshacer conflicto». | conflicto | sí | sí | no | — |
| M200 | `domain/services/operation_state_deriver.dart:302` | Bahía {b} · {tapa}: {ya está quitada\|no está quitada para reponerla}. Si el registro fue un error, deshazlo con «Deshacer conflicto». | conflicto | sí | sí | no | — |
| M201 | `domain/services/operation_state_deriver.dart:341` | {Objeto} no está en el plano de llegada de esta escala. Si el registro fue un error, deshazlo desde el detalle del contenedor. | conflicto | sí | sí | no | — |
| M202 | `domain/services/operation_state_deriver.dart:345` | {Objeto} está cancelado y se descargó. Si el registro fue un error, deshazlo desde el detalle del contenedor. | conflicto | sí | sí | no | — |
| M203 | `domain/services/operation_state_deriver.dart:361` | {Objeto} no descarga en {escala}; si sale para volver a subir, es una re‑estiba. Si el registro fue un error, deshazlo desde el detalle del contenedor. | conflicto | sí | sí | no | — |
| M204 | `domain/services/operation_state_deriver.dart:374,415,465` | {celda} ya la ocupa {objeto}. (tres reglas: descarga, carga y vacío) Si el registro fue un error, deshazlo desde el detalle de la celda. | conflicto | sí | sí | no | — |
| M205 | `domain/services/operation_state_deriver.dart:389` | {Objeto} no está en el plan de carga de {escala}. Si el registro fue un error, deshazlo desde el detalle de la celda. | conflicto | sí | sí | no | — |
| M206 | `domain/services/operation_state_deriver.dart:393` | {Objeto} está cancelado y se cargó. Si el registro fue un error, deshazlo desde el detalle de la celda. | conflicto | sí | sí | no | — |
| M207 | `domain/services/operation_state_deriver.dart:400` | {Objeto} no se carga en {escala}. Si el registro fue un error, deshazlo desde el detalle de la celda. | conflicto | sí | sí | no | — |
| M208 | `domain/services/operation_state_deriver.dart:408` | {Objeto} ya se cargó en {posición}. Si el registro fue un error, deshazlo desde el detalle de la celda. | conflicto | sí | sí | no | — |
| M209 | `domain/services/operation_state_deriver.dart:429` | {Objeto}: planificado en {p}, registrado en {p}. Si el registro fue un error, deshazlo desde el detalle de la celda. | conflicto | sí | sí | no | — |
| M210 | `domain/services/operation_state_deriver.dart:438` | {Objeto} no es una celda reservada del plan. Si el registro fue un error, deshazlo desde el detalle de la celda. | conflicto | sí | sí | no | — |
| M211 | `domain/services/operation_state_deriver.dart:442` | {Objeto} está cancelada y se asignó. Si el registro fue un error, deshazlo desde el detalle de la celda. | conflicto | sí | sí | no | — |
| M212 | `domain/services/operation_state_deriver.dart:451` | {Objeto} ya tiene asignado {contenedor}. Si el registro fue un error, deshazlo desde el detalle de la celda. | conflicto | sí | sí | no | — |
| M213 | `domain/services/operation_state_deriver.dart:458` | {contenedor} ya está en {objeto}. Si el registro fue un error, deshazlo desde el detalle de la celda. | conflicto | sí | sí | no | — |
| M214 | `domain/services/operation_state_deriver.dart:489` | {contenedor} ({tipo} · {POD} · {línea}) quedó en una reserva de {tipo} · {POD} · {línea}. Si el registro fue un error, deshazlo desde el detalle de la celda. | conflicto | sí | sí | no | — |
| M215 | `domain/services/operation_state_deriver.dart:498` | {Objeto} no está en el plan de esta escala. Si la cancelación fue un error, la oficina la deshace desde el detalle de la celda. | conflicto | sí | sí | no | — |
| M216 | `domain/services/operation_state_deriver.dart:507` | {Objeto} ya se movió; para cancelarlo, anula antes ese movimiento. | conflicto | sí | sí | no | — |
|  | **El toString() de una excepción, ahora con mensaje en español (T-112)** |  |  |  |  |  |  |
| M217 | `presentation/widgets/plan_drag_confirmation.dart:402; presentation/widgets/loading_controls.dart:496; presentation/widgets/office_plan_controls.dart:52; presentation/pages/change_requests_page.dart:88,292` | Cuando el error no es un StateError: «No se pudo {guardar el cambio\|registrar la carga\|guardar la acción de la oficina\|decidir la solicitud\|enviar el cambio} por un error interno de la aplicación; el detalle técnico quedó en el registro. Inténtalo de nuevo y, si se repite, reinicia la aplicación.» (o la variante del almacén local) | falla | sí | sí | no | — |
| M218 | `presentation/widgets/hatch_operation_controls.dart:86` | No se pudo leer las tapas de la operación por un error interno de la aplicación; el detalle técnico quedó en el registro. Inténtalo de nuevo y, si se repite, reinicia la aplicación. (con el almacén local: «…: falló la lectura o la escritura de los datos guardados en este dispositivo. Inténtalo de nuevo y, si se repite, reinicia la aplicación.») | falla | sí | sí | no | — |
