"""T-112 · El censo de los mensajes de error (RNF-006) sobre el árbol de T-112.

Los mismos 218 mensajes de tool/t98c_mensajes.py, con el mismo orden y los
mismos identificadores (M001…M218), cada uno con su texto nuevo, el fragmento
que lo ubica en el código y su juicio. El script de T-98 aporta ubicar() y
censo(): t112_censos.py reemplaza su tabla por esta antes de correrlo, así que
un fragmento que no aparece detiene el censo.

Juicios: los mismos de T-98 (causa y acción «sí», «impl.» o «no»; segmento
solo en los errores de lectura de un BAPLIE).
"""
_P = 'lib/features/vessel/presentation/'
_D = 'lib/features/vessel/domain/'
_DA = 'lib/features/vessel/data/'

F_ERR = _P + 'formatters/vessel_error_message.dart'
F_OVR = _P + 'pages/vessel_overview_page.dart'
F_VPR = _P + 'providers/vessel_providers.dart'
F_SES = _DA + 'repositories/firebase_session_repository.dart'
F_FOS = _DA + 'repositories/firestore_operation_sync.dart'
F_CLD = _P + 'pages/cloud_page.dart'
F_SYN = _P + 'widgets/sync_status_chip.dart'
F_MOV = _D + 'entities/movement.dart'
F_CHG = _D + 'services/change_requests.dart'
F_LOP = _D + 'services/loading_operation.dart'
F_LCK = _D + 'services/load_check.dart'
F_HAT = _D + 'entities/hatch_covers.dart'
F_ELP = _P + 'providers/export_list_providers.dart'
F_ELS = _DA + 'services/export_list_parser_service.dart'
F_ELI = _P + 'pages/export_list_import_page.dart'
F_DBW = _D + 'services/departure_baplie_writer.dart'
F_DBP = _P + 'pages/departure_baplie_page.dart'
F_GEO = _P + 'pages/vessel_geometry_page.dart'
F_RSR = _D + 'services/reefer_socket_ranges.dart'
F_OSD = _D + 'services/operation_state_deriver.dart'
F_CAR = _P + 'widgets/voyage_summary_card.dart'

INTERNO = ('por un error interno de la aplicación; el detalle técnico quedó en el registro. '
           'Inténtalo de nuevo y, si se repite, reinicia la aplicación.')
ALMACEN = (': falló la lectura o la escritura de los datos guardados en este dispositivo. '
           'Inténtalo de nuevo y, si se repite, reinicia la aplicación.')

M = []


def m(grupo, archivo, fragmento, texto, tipo, causa='sí', accion='sí', arreglo='',
      parseo='no', segmento='—'):
    M.append({'grupo': grupo, 'archivo': archivo, 'fragmento': fragmento,
              'texto': texto, 'tipo': tipo, 'causa': causa, 'accion': accion,
              'parseo': parseo, 'segmento': segmento, 'arreglo': arreglo})


G = 'Formateador común (vessel_error_message.dart)'
m(G, F_ERR, "'No se pudo completar la operación por un error interno de la aplicación; '",
  'No se pudo {la operación que nombra el llamador|completar la operación} ' + INTERNO, 'falla')
m(G, F_ERR, 'no parece un BAPLIE',
  'Este archivo no parece un BAPLIE: no se reconoce su cabecera UNH/S009. Selecciona una exportación BAPLIE '
  'completa. (También con «Archivo «nombre»: » delante.)', 'falla', parseo='sí', segmento='sí')
m(G, F_ERR, 'no trae el nombre del buque en el segmento TDT',
  'El archivo no trae el nombre del buque en el segmento TDT. Revisa que sea un BAPLIE completo o pide una nueva '
  'exportación.', 'falla', parseo='sí', segmento='sí')
m(G, F_ERR, 'No se pudo interpretar $where del BAPLIE: trae un dato que el',
  'No se pudo interpretar el segmento {segmento} (n.º {n} del archivo) del BAPLIE: trae un dato que el lector no '
  'esperaba. Revisa ese segmento en el archivo o pide una nueva exportación. (Fuera de la carga: «los segmentos '
  'UNH y DTM», «el segmento TDT»…)', 'falla', parseo='sí', segmento='sí')
m(G, F_ERR, 'Hay un perfil con el mismo nombre y no se puede identificar',
  'Hay un perfil con el mismo nombre y no se puede identificar el buque. Confirma su identidad antes de guardar.',
  'rechazo')
m(G, F_ERR, "return 'No se pudo ${operation ?? 'completar la operación'}: falló la '",
  'No se pudo {la operación que nombra el llamador|completar la operación}' + ALMACEN, 'falla')

G = 'Carga del BAPLIE, perfil y viajes (vessel_providers.dart y pantallas)'
m(G, F_OVR, "'guardar la preferencia de la barra'",
  'No se pudo guardar la preferencia de la barra ' + INTERNO + ' (con el almacén local: «…' + ALMACEN + '»)',
  'falla')
m(G, F_OVR, "'exportar ${format.label}'",
  'No se pudo exportar {PDF|CSV|JSON} ' + INTERNO + ' (con el almacén local: «…' + ALMACEN + '»)', 'falla')
m(G, F_VPR, 'No hay un buque nuevo confirmado para usar la plantilla',
  'No hay un buque nuevo confirmado para usar la plantilla. Confirma primero el buque o inicia otra carga.',
  'rechazo')
m(G, F_VPR, 'Ya hay una carga en curso. Termínala o cancélala',
  'Ya hay una carga en curso. Termínala o cancélala antes de abrir otra.', 'rechazo')
m(G, F_VPR, 'Hay una operación en curso. Espera a que termine e inténtalo de nuevo.',
  'Hay una operación en curso. Espera a que termine e inténtalo de nuevo.', 'rechazo')
m(G, F_VPR, 'No hay una identidad pendiente.',
  'No hay una identidad pendiente. Carga un BAPLIE para elegir el buque.', 'rechazo')
m(G, F_VPR, 'El perfil no corresponde a este buque.',
  'El perfil no corresponde a este buque. Elige uno de los perfiles propuestos.', 'validación')
m(G, F_VPR, 'No se pueden distinguir estos buques solo por nombre.',
  'No se pueden distinguir estos buques solo por nombre. Pide una exportación con IMO o indicativo en el archivo.',
  'rechazo')
m(G, F_VPR, 'Falta indicar si este BAPLIE es de llegada o de carga: elige una opción.',
  'Falta indicar si este BAPLIE es de llegada o de carga: elige una opción.', 'validación')
m(G, F_VPR, 'La identidad del buque está sin confirmar: confírmala primero.',
  'La identidad del buque está sin confirmar: confírmala primero.', 'validación')
m(G, F_VPR, 'No hay un viaje para confirmar.',
  'No hay un viaje para confirmar. Carga un BAPLIE primero.', 'rechazo')
m(G, F_VPR, 'La geometría deja posiciones del archivo fuera del plano.',
  'La geometría deja posiciones del archivo fuera del plano. Amplía las filas o niveles para incluirlas.',
  'validación')
m(G, F_VPR, 'La edición de parámetros no permite cambiar la identidad del buque.',
  'La edición de parámetros no permite cambiar la identidad del buque. Abre el perfil correcto antes de editar.',
  'rechazo')
m(G, F_VPR, 'La geometría deja posiciones del viaje abierto fuera del plano.',
  'La geometría deja posiciones del viaje abierto fuera del plano. Amplía las filas o niveles para incluirlas.',
  'validación')
m(G, F_VPR, 'El perfil cambió. Vuelve a abrirlo antes de editar.',
  'El perfil cambió. Vuelve a abrirlo antes de editar.', 'rechazo')
m(G, F_VPR, 'El viaje ya no está guardado. Vuelve a cargar su BAPLIE.',
  'El viaje ya no está guardado. Vuelve a cargar su BAPLIE.', 'falla')
m(G, F_VPR, 'Este viaje no tiene una geometría válida guardada.',
  'Este viaje no tiene una geometría válida guardada. Vuelve a cargar el BAPLIE.', 'falla')
m(G, _DA + 'services/baplie_parser_service.dart', "        : 'la cabecera UNH declara $identifier';",
  'Archivo «{nombre}»: Versión BAPLIE no admitida: la cabecera UNH declara {identificador S009}. BayStream lee la '
  'familia 2.x (SMDG20, SMDG21 y SMDG22). [El archivo contiene más de un mensaje.] Pide una exportación '
  'compatible.', 'falla', parseo='sí', segmento='sí')
m(G, _P + 'pages/recent_voyages_page.dart', "'No se aplicó del perfil vigente: '",
  'No se aplicó del perfil vigente: {parámetros}. Dejaría contenedores de este viaje fuera del plano; se conserva '
  'el valor guardado con el viaje. Revisa el perfil del buque.', 'aviso de datos')
m(G, _P + 'pages/parameters_page.dart', "vesselErrorMessage(error, stack, 'guardar el tema')",
  'No se pudo guardar el tema ' + INTERNO + ' (con el almacén local: «…' + ALMACEN + '»)', 'falla')
m(G, _P + 'pages/parameters_page.dart', "'No se pudo leer el tema guardado: falló la lectura de las preferencias '",
  'No se pudo leer el tema guardado: falló la lectura de las preferencias de este dispositivo; se usa el del '
  'sistema. Elígelo de nuevo.', 'falla')
m(G, 'lib/main.dart', "'Esta versión de BayStream no tiene todas las opciones '",
  'Falta la configuración de Firebase · Esta versión de BayStream no tiene todas las opciones necesarias para '
  'iniciar. Solicita una compilación configurada al responsable.', 'falla')

G = 'Cuenta y nube (Nube y cuenta)'
m(G, F_SES, "'Correo o contraseña incorrectos. Revísalos e inténtalo de nuevo, o usa '",
  'Correo o contraseña incorrectos. Revísalos e inténtalo de nuevo, o usa «Olvidé mi contraseña».', 'rechazo')
m(G, F_SES, "'El correo no es válido: escríbelo completo, como nombre@dominio.'",
  'El correo no es válido: escríbelo completo, como nombre@dominio.', 'validación')
m(G, F_SES, 'Esta cuenta está deshabilitada. Habla con el responsable.',
  'Esta cuenta está deshabilitada. Habla con el responsable.', 'rechazo')
m(G, F_SES, 'Demasiados intentos. Espera un momento.',
  'Demasiados intentos. Espera un momento.', 'rechazo')
m(G, F_SES, "'Sin conexión: iniciar sesión requiere red. Conéctate e inténtalo de nuevo.'",
  'Sin conexión: iniciar sesión requiere red. Conéctate e inténtalo de nuevo.', 'falla')
m(G, F_SES, "'No se pudo iniciar sesión: el servicio de cuentas respondió con un '",
  'No se pudo iniciar sesión: el servicio de cuentas respondió con un error que BayStream no reconoce; el código '
  'quedó en el registro. Inténtalo de nuevo y, si se repite, avisa al responsable.', 'falla')
m(G, F_SES, "'No se pudo iniciar sesión por un error inesperado del servicio '",
  'No se pudo iniciar sesión por un error inesperado del servicio de cuentas; el detalle quedó en el registro. '
  'Inténtalo de nuevo.', 'falla')
m(G, F_SES, "'No se pudo cerrar la sesión por un error del servicio de '",
  'No se pudo cerrar la sesión por un error del servicio de cuentas; el detalle quedó en el registro. Inténtalo de '
  'nuevo.', 'falla')
m(G, F_SES, "'No se pudo enviar el correo de recuperación: el servicio de cuentas '",
  'No se pudo enviar el correo de recuperación: el servicio de cuentas respondió con un error; el código quedó en '
  'el registro. Revisa la conexión y el correo, e inténtalo de nuevo.', 'falla')
m(G, F_CLD, "'Falta el correo: escríbelo para recuperar la contraseña.'",
  'Falta el correo: escríbelo para recuperar la contraseña.', 'validación')
m(G, F_CLD, "'No hay un plano abierto con perfil de buque: abre el plano de la '",
  'No hay un plano abierto con perfil de buque: abre el plano de la escala para publicarla con su perfil.',
  'rechazo')
m(G, F_CLD, "'No se pudieron leer las operaciones abiertas de la nube: puede faltar '",
  'No se pudieron leer las operaciones abiertas de la nube: puede faltar la conexión o el permiso de la cuenta. '
  'Revisa la conexión y la cuenta.', 'falla')
m(G, F_CLD, "'La operación no tiene esa fuente: la oficina no la publicó. Abre otra '",
  'La operación no tiene esa fuente: la oficina no la publicó. Abre otra fuente o pide a la oficina que la '
  'publique.', 'rechazo')
m(G, F_CLD, "const _sourceNotOpened = 'No se abrió la fuente publicada: la lectura terminó sin '",
  'No se abrió la fuente publicada: la lectura terminó sin el viaje ni un motivo. Inténtalo de nuevo y, si se '
  'repite, avisa al responsable.', 'falla')
m(G, F_FOS, "'Publicar y cerrar exige sesión: inicia sesión con una cuenta de oficina.'",
  'Publicar y cerrar exige sesión: inicia sesión con una cuenta de oficina.', 'rechazo')
m(G, F_FOS, "message: 'Solo una cuenta de oficina autorizada publica y cierra '",
  'Solo una cuenta de oficina autorizada publica y cierra operaciones: inicia sesión con una o pide al responsable '
  'que autorice la tuya.', 'rechazo')
m(G, F_FOS, "'Sin respuesta de la nube. Publicar requiere conexión: '",
  'Sin respuesta de la nube. Publicar requiere conexión: revisa la red e inténtalo de nuevo.', 'falla')
m(G, F_FOS, "'La nube no aceptó la publicación: revisa que la cuenta sea de oficina '",
  'La nube no aceptó la publicación: revisa que la cuenta sea de oficina y esté activa.', 'rechazo')
m(G, F_FOS, "'unavailable' => 'Sin conexión con la nube: publicar o cerrar requiere '",
  'Sin conexión con la nube: publicar o cerrar requiere red. Conéctate e inténtalo de nuevo.', 'falla')
m(G, F_FOS, "return 'La nube devolvió un error que BayStream no reconoce; el código '",
  'La nube devolvió un error que BayStream no reconoce; el código técnico quedó en el registro. Inténtalo de nuevo '
  'y, si se repite, avisa al responsable.', 'falla')
m(G, F_FOS, "message: 'La operación ya no está en la nube: se retiró después de '",
  'La operación ya no está en la nube: se retiró después de publicarse. Pide a la oficina que la publique de '
  'nuevo.', 'falla')
m(G, F_FOS, "message: 'La fuente «${_sourceName(kind)}» llegó incompleta o '",
  'La fuente «{plano de llegada|plan de carga|listado de la agencia}» llegó incompleta o distinta de la publicada. '
  'No se guardó nada: vuelve a intentarlo.', 'falla')
m(G, F_FOS, "'Tu cuenta no puede leer esta operación: revisa que esté autorizada.'",
  'Tu cuenta no puede leer esta operación: revisa que esté autorizada.', 'rechazo')
m(G, F_FOS, ": 'Sin conexión con la nube: unirse requiere red. Conéctate e '",
  'Sin conexión con la nube: unirse requiere red. Conéctate e inténtalo de nuevo.', 'falla')
m(G, F_FOS, "message: 'Sin respuesta de la nube: unirse requiere red. Revisa la red e '",
  'Sin respuesta de la nube: unirse requiere red. Revisa la red e inténtalo de nuevo.', 'falla')
m(G, F_FOS, "message: 'No se encontró la operación para cerrarla en este dispositivo '",
  'No se encontró la operación para cerrarla en este dispositivo o en la nube. Vuelve a abrir «Nube y cuenta» e '
  'inténtalo de nuevo.', 'falla')
m(G, F_FOS, "message: 'Sin respuesta de la nube: cerrar requiere red. Revisa la red e '",
  'Sin respuesta de la nube: cerrar requiere red. Revisa la red e inténtalo de nuevo.', 'falla')
m(G, _DA + 'repositories/local_only_operation_sync.dart',
  "'en un solo dispositivo. Para sincronizar, pide al responsable una '",
  'Esta compilación no tiene la nube configurada: la app trabaja en un solo dispositivo. Para sincronizar, pide al '
  'responsable una compilación con la nube.', 'rechazo')
m(G, _D + 'services/operation_sources.dart', "message: 'La operación de esta escala ya está publicada y sus fuentes '",
  'La operación de esta escala ya está publicada y sus fuentes no cambian. Abre la fuente publicada desde «Nube y '
  'cuenta».', 'rechazo')

G = 'Estado de envío con error (sync_status_chip.dart: barra, Bay Plan, Avance, Solicitudes)'
m(G, F_SYN, "'Sesión vencida: inicia sesión para enviar ${status.pending}'",
  'Sesión vencida: inicia sesión para enviar {n}', 'estado de error')
m(G, F_SYN, "' · pide al responsable que la autorice',",
  'Tu cuenta no está autorizada · {n} espera(n) · pide al responsable que la autorice', 'estado de error')
m(G, F_SYN, "SyncState.unconfirmed => 'Sesión sin confirmar desde las '",
  'Sesión sin confirmar desde las {hh:mm} · inicia sesión de nuevo', 'estado de error')
m(G, F_SYN, "'1 rechazado por la nube, fuera del plan: regístralo de nuevo si hace falta'",
  '{n} rechazado(s) por la nube, fuera del plan: regístralo(s) de nuevo si hace(n) falta', 'estado de error')

G = 'Registro de movimientos (bitácora y validación del borrador)'
m(G, _DA + 'repositories/movement_log_repository_impl.dart',
  "message: 'No se pudo usar la bitácora local de este dispositivo: falló su '",
  'No se pudo usar la bitácora local de este dispositivo: falló su lectura o su escritura y el movimiento no se '
  'registró. Inténtalo de nuevo y, si se repite, reinicia la aplicación.', 'falla')
m(G, F_MOV, "'Este tipo de movimiento no admite corrección: deshazlo y regístralo de nuevo.'",
  'Este tipo de movimiento no admite corrección: deshazlo y regístralo de nuevo.', 'validación')
m(G, F_MOV, "'Falta el número de contenedor: escríbelo.'",
  'Falta el número de contenedor: escríbelo.', 'validación')
m(G, F_MOV, "'La posición debe tener 6 o 7 cifras (BBBRRTT): corrígela.'",
  'La posición debe tener 6 o 7 cifras (BBBRRTT): corrígela.', 'validación')
m(G, F_MOV, "'Falta la celda reservada: elige una.'", 'Falta la celda reservada: elige una.', 'validación')
m(G, F_MOV, "'Falta el número del vacío: indícalo.'", 'Falta el número del vacío: indícalo.', 'validación')
m(G, F_MOV, "'Tara fuera de rango: debe ser mayor que 0 y menor que 15 000 kg. '",
  'Tara fuera de rango: debe ser mayor que 0 y menor que 15 000 kg. Corrígela.', 'validación')
m(G, F_MOV, "'Falta el movimiento a anular: vuelve a elegirlo en el detalle de la celda.'",
  'Falta el movimiento a anular: vuelve a elegirlo en el detalle de la celda.', 'validación')
m(G, F_MOV, "'Anular exige un motivo: escríbelo.'", 'Anular exige un motivo: escríbelo.', 'validación')
m(G, F_MOV, "'Falta el contenedor o la reserva a cancelar: vuelve a elegirlo en el plano.'",
  'Falta el contenedor o la reserva a cancelar: vuelve a elegirlo en el plano.', 'validación')
m(G, F_MOV, "'Cancelar exige un motivo de hasta 300 caracteres: escríbelo.'",
  'Cancelar exige un motivo de hasta 300 caracteres: escríbelo.', 'validación')
m(G, F_MOV, "'El cambio llegó mal armado: sus objetos van en la lista, no aparte. '",
  'El cambio llegó mal armado: sus objetos van en la lista, no aparte. Vuelve a abrir el formulario y repite el '
  'cambio.', 'validación')
m(G, F_MOV, "'Falta el motivo: escribe uno de hasta 300 caracteres.'",
  'Falta el motivo: escribe uno de hasta 300 caracteres.', 'validación')
m(G, F_MOV, "'Falta la solicitud que se rechaza: vuelve a abrirla desde la bandeja.'",
  'Falta la solicitud que se rechaza: vuelve a abrirla desde la bandeja.', 'validación')
m(G, F_MOV, "'Falta la tapa o la acción: indica una tapa y si se quita o se repone.'",
  'Falta la tapa o la acción: indica una tapa y si se quita o se repone.', 'validación')

G = 'Cambios del plan (arrastre, solicitudes, oficina)'
m(G, F_CHG, "static const signInToMove = 'Mover exige una cuenta autorizada: inicia sesión '",
  'Mover exige una cuenta autorizada: inicia sesión o pide al responsable que autorice la tuya. (También al '
  'mantener pulsada una celda sin sesión.)', 'rechazo')
m(G, (F_CHG, F_MOV), "Los cambios de la solicitud no son válidos: indica de uno a cuatro, '",
  'Los cambios de la solicitud no son válidos: indica de uno a cuatro, sin repetir objetos ni destinos.',
  'validación')
m(G, F_CHG, "'Solo se mueve un objeto pendiente del plan de carga: este ya se '",
  'Solo se mueve un objeto pendiente del plan de carga: este ya se cargó o se canceló. Elige uno pendiente.',
  'rechazo')
m(G, F_CHG, "'Las reservas del intercambio deben ser del mismo grupo (tipo, POD '",
  'Las reservas del intercambio deben ser del mismo grupo (tipo, POD y línea): elige reservas iguales.',
  'validación')
m(G, F_CHG, "'Solo se cancela un objeto pendiente del plan de carga: este ya se '",
  'Solo se cancela un objeto pendiente del plan de carga: este ya se cargó o ya está cancelado. Si se cargó, '
  'deshaz antes la carga.', 'rechazo')
m(G, F_CHG, "throw StateError('El cambio de oficina ya no está vigente: vuelve a abrir '",
  'El cambio de oficina ya no está vigente: vuelve a abrir el detalle para ver el estado actual.', 'rechazo')
m(G, F_CHG, "'Deshacer exige un motivo de hasta 300 caracteres: escríbelo.'",
  'Deshacer exige un motivo de hasta 300 caracteres: escríbelo.', 'validación')
m(G, F_CHG, "? 'Solo una cuenta de muelle autorizada puede pedir cambios: inicia '",
  'Solo una cuenta de muelle autorizada puede pedir cambios: inicia sesión con una.', 'rechazo')
m(G, F_CHG, ": 'Solo una cuenta de oficina autorizada puede decidir: inicia sesión '",
  'Solo una cuenta de oficina autorizada puede decidir: inicia sesión con una.', 'rechazo')
m(G, F_CHG, "static const operationNotOpen = 'La operación debe estar publicada y abierta: '",
  'La operación debe estar publicada y abierta: la oficina la publica desde «Nube y cuenta»; si ya se cerró, no '
  'admite cambios. (También en el arrastre.)', 'rechazo')
m(G, F_CHG, "return 'Los cambios no son válidos: indica de uno a cuatro.';",
  'Los cambios no son válidos: indica de uno a cuatro.', 'validación')
m(G, F_CHG, "no está en el plan de carga: '",
  '{Objeto} no está en el plan de carga: revisa el OR o el número.', 'validación')
m(G, F_CHG, "cambió; revisa la solicitud.'",
  'El origen de {objeto} cambió; revisa la solicitud.', 'validación')
m(G, F_CHG, "no existe en la geometría del buque: elige una '",
  'La celda {BBBRRTT} no existe en la geometría del buque: elige una celda del plano.', 'validación')
m(G, F_CHG, "'${coordinate.bay}: un 20 va en bahía impar y un 40 en par. Elige una '",
  '{Objeto} no cabe en la bahía {n}: un 20 va en bahía impar y un 40 en par. Elige una bahía de su tamaño.',
  'validación')
m(G, F_CHG, "'Es carga de paso: no se descarga aquí. Elige otra celda.',",
  '{destino} choca con {objeto} en {posición}[: un 40 ocupa las dos mitades de la celda.] Es carga de paso: no se '
  'descarga aquí. Elige otra celda.', 'validación')
m(G, F_CHG, "'La celda está ocupada a bordo; marca primero su descarga.'",
  '{destino} choca con {objeto} en {posición}[…] La celda está ocupada a bordo; marca primero su descarga.',
  'validación')
m(G, F_CHG, "'La celda está prevista para otro objeto; inclúyelo en el intercambio.'",
  '{destino} choca con {objeto} en {posición}[…] La celda está prevista para otro objeto; inclúyelo en el '
  'intercambio.', 'validación')
m(G, F_CHG, "'Un 20 y un 40 no se intercambian: elige otra celda del mismo tamaño.'",
  '{destino} choca con {objeto} en {posición}[…] Un 20 y un 40 no se intercambian: elige otra celda del mismo '
  'tamaño.', 'validación')
m(G, F_CHG, "' ${then ?? 'Elige otra celda.'}';",
  '{destino} choca con {objeto} en {posición}[: un 40 ocupa las dos mitades de la celda.] Elige otra celda. (sin '
  'regla que agregar)', 'validación')
m(G, F_CHG, "throw StateError('La solicitud ya no está pendiente: ya se decidió o se '",
  'La solicitud ya no está pendiente: ya se decidió o se anuló. Vuelve a la bandeja para ver su estado.', 'rechazo')
m(G, _P + 'widgets/plan_drag_confirmation.dart', "'El arrastre solo mueve dentro de la bahía: para otra bahía utiliza '",
  'El arrastre solo mueve dentro de la bahía: para otra bahía utiliza el formulario.', 'rechazo')
m(G, F_ERR, "const operationUnavailable = 'La operación todavía no se cargó o cambió '",
  'La operación todavía no se cargó o cambió mientras tanto: espera un momento e inténtalo de nuevo. (Arrastre, '
  'acciones de oficina y solicitudes.)', 'falla')

G = 'Registro de carga (diálogo Confirmar carga y revisión)'
m(G, F_LOP, "throw StateError('La escala no tiene operación guardada: vuelve a abrir el '",
  'La escala no tiene operación guardada: vuelve a abrir el plan de carga y confirma la escala.', 'rechazo')
m(G, F_LOP, "throw StateError('El OR ya no está en el listado de la agencia: importa de '",
  'El OR ya no está en el listado de la agencia: importa de nuevo el listado.', 'rechazo')
m(G, F_LOP, "'La corrección exige un movimiento vigente y un motivo: elige la carga '",
  'La corrección exige un movimiento vigente y un motivo: elige la carga vigente y escribe el motivo.',
  'validación')
m(G, (F_LOP, F_LCK, _P + 'widgets/office_plan_controls.dart'),
  "'Cancelado por la oficina. Debe deshacer la cancelación antes de cargar.'",
  'Cancelado por la oficina. Debe deshacer la cancelación antes de cargar.', 'rechazo')
m(G, F_LOP, "throw StateError('El contenedor ya está operado: para cambiarlo, abre su '",
  'El contenedor ya está operado: para cambiarlo, abre su detalle y usa Corregir o Deshacer carga.', 'rechazo')
m(G, F_LOP, "throw StateError('Un vacío se asigna a una celda reservada del plan: '",
  'Un vacío se asigna a una celda reservada del plan: elige una celda reservada.', 'validación')
m(G, F_LOP, "throw StateError('La reserva está cancelada: elige otra o pide a la '",
  'La reserva está cancelada: elige otra o pide a la oficina que deshaga la cancelación.', 'rechazo')
m(G, F_LOP, "que baja aquí: '",
  'La celda la ocupa {contenedor}, que baja aquí: marca primero su descarga.', 'validación')
m(G, F_LOP, "throw StateError('Esta carga se registra solo con un motivo escrito: '",
  'Esta carga se registra solo con un motivo escrito: escribe el motivo para registrarla.', 'validación')
m(G, F_LCK, "'La posición «$position» no tiene la forma BBB-RR-TT: escríbela así, '",
  '[No se registra:] La posición «{posición}» no tiene la forma BBB-RR-TT: escríbela así, por ejemplo 012-04-82.',
  'validación')
m(G, F_LCK, "'Elige una celda de su tamaño.'));",
  'No se registra: Un contenedor de {n} pies ({tipo}) no cabe en {celda}: la bahía {b} es {impar, de 20|par, de 40} '
  'pies. Elige una celda de su tamaño.', 'validación')
m(G, F_LCK, "'Para cargarlo ahí, escribe el motivo; si no, usa la celda planificada.'));",
  'Pide motivo: OR {n} está planificado en {celda}; en {celda} quedará «fuera de plan»[, y {celda} es la celda de '
  '{objeto}]. Para cargarlo ahí, escribe el motivo; si no, usa la celda planificada.', 'aviso de datos')
m(G, F_LCK, "'Para cargarlo ahí, escribe el motivo; si no, elige una reserva de su grupo.'));",
  'Pide motivo: La reserva {celda} es de otro grupo ({diferencias}); el OR {n} es {tipo} · {POD} · {línea}. Para '
  'cargarlo ahí, escribe el motivo; si no, elige una reserva de su grupo.', 'aviso de datos')
m(G, F_LCK, "'el motivo; si no, elige otra celda.'));",
  'Pide motivo: {celda} la ocupa {objeto}, que no baja en {escala}: la celda está ocupada. Para cargarlo ahí, '
  'escribe el motivo; si no, elige otra celda.', 'aviso de datos')
m(G, F_LCK, "'registrar. Elige una celda de una bahía del buque.';",
  'No se registra: La bahía {b} no existe en este buque: {celda} no se puede registrar. Elige una celda de una '
  'bahía del buque.', 'validación')
m(G, F_LCK, "'nivel ${c.tierPadded}). Revisa la celda o amplía la geometría en '",
  'No se registra: {celda} no existe en la geometría del buque (fila {f}, nivel {n}). Revisa la celda o amplía la '
  'geometría en Parámetros del buque.', 'validación')
m(G, F_LCK, "'${stack.message} Para cargarlo ahí, escribe el motivo; si no, elige otra pila.'));",
  'Pide motivo: {Pila de cubierta|bodega} {bahía}, fila {f}: quedaría en {x} t y el límite del perfil es {y} t[; '
  '{n} contenedores de la pila no traen peso, el peso real es mayor]. Para cargarlo ahí, escribe el motivo; si no, '
  'elige otra pila.', 'aviso de datos')
m(G, _P + 'widgets/loading_controls.dart', "Text('Este contenedor no tiene OR en el listado de la agencia: '",
  'Este contenedor no tiene OR en el listado de la agencia: importa el listado actualizado.', 'rechazo')
m(G, _P + 'widgets/loading_controls.dart', "throw StateError('Hora no válida: escríbela como HH:mm (00:00 a 23:59).');",
  'Hora no válida: escríbela como HH:mm (00:00 a 23:59).', 'validación')

G = 'Descarga y tapas'
m(G, _P + 'widgets/discharge_controls.dart', "content: Text('Esta escala no tiene operación guardada: vuelve a '",
  'Esta escala no tiene operación guardada: vuelve a abrir el BAPLIE de llegada y confirma la escala.', 'rechazo')
m(G, F_HAT, "'Una bahía sin bodega no puede declarar tapas: déjala «Sin declarar».'",
  'Una bahía sin bodega no puede declarar tapas: déjala «Sin declarar».', 'validación')
m(G, F_HAT, "'Una bodega abierta no lleva tapas: quita las filas de tapa.'",
  'Una bodega abierta no lleva tapas: quita las filas de tapa.', 'validación')
m(G, F_HAT, "'Falta la tapa automática o hay más de una: declara exactamente una.'",
  'Falta la tapa automática o hay más de una: declara exactamente una.', 'validación')
m(G, F_HAT, "'Faltan las tapas de grúa o hay más de tres: declara de una a tres.'",
  'Faltan las tapas de grúa o hay más de tres: declara de una a tres.', 'validación')
m(G, F_HAT, "necesita al menos una fila: escribe sus filas.'",
  'La tapa {n} necesita al menos una fila: escribe sus filas.', 'validación')
m(G, F_HAT, "'no pertenece a la geometría de bodega de esta bahía. Usa filas de '",
  'La fila {nn} de la tapa {n} no pertenece a la geometría de bodega de esta bahía. Usa filas de esa geometría.',
  'validación')
m(G, F_HAT, "se solapa entre tapas: '",
  'La fila {nn} se solapa entre tapas: déjala en una sola.', 'validación')
m(G, _P + 'pages/hatch_covers_page.dart', "las filas no tienen el formato esperado; escribe filas '",
  'Tapa {n}: las filas no tienen el formato esperado; escribe filas de uno o dos dígitos separadas por coma.',
  'validación')
m(G, _P + 'pages/hatch_covers_page.dart', "hay una fila repetida; quítala.'",
  'Tapa {n}: hay una fila repetida; quítala.', 'validación')

G = 'Listado de la agencia'
m(G, F_ELP, "error: 'El archivo está vacío o no se pudo leer: vuelve a elegir el '",
  'El archivo está vacío o no se pudo leer: vuelve a elegir el Excel (.xlsx) de la agencia.', 'falla')
m(G, F_ELP, "error: 'No hay un plan de carga confirmado: abre primero el plan de '",
  'No hay un plan de carga confirmado: abre primero el plan de carga y confirma la escala.', 'rechazo')
m(G, F_ELI, "'No hay un plan de carga confirmado: abre primero el plan de carga '",
  'No hay un plan de carga confirmado: abre primero el plan de carga (BAPLIE) y confirma la escala.', 'rechazo')
m(G, F_ELP, "return 'No hay un listado leído para importar: elige primero el Excel de '",
  'No hay un listado leído para importar: elige primero el Excel de la agencia.', 'rechazo')
m(G, F_ELP, "'Elige una para cada código antes de importar.';",
  'Falta elegir equivalencias: {códigos}. Elige una para cada código antes de importar.', 'validación')
m(G, F_ELP, "if (state.busy) return 'Hay una operación en curso: espera a que termine.';",
  'Hay una operación en curso: espera a que termine.', 'rechazo')
m(G, F_ELI, "'equivalencias antes de importar. Elige una para cada código '",
  'Falta elegir {n} equivalencias antes de importar. Elige una para cada código pendiente.', 'validación')
m(G, _DA + 'repositories/export_list_repository_impl.dart',
  "message: 'No se pudo leer el listado por un error interno de la '",
  'No se pudo leer el listado por un error interno de la aplicación; el detalle técnico quedó en el registro. '
  'Revisa que sea el Excel de la agencia e inténtalo de nuevo.', 'falla')
m(G, F_ELS, "'El archivo no es un libro de Excel (.xlsx) legible: guárdalo '",
  'El archivo no es un libro de Excel (.xlsx) legible: guárdalo como .xlsx desde Excel y vuelve a elegirlo.',
  'falla', parseo='Excel')
m(G, F_ELS, "message: 'El libro no tiene hojas con datos: elige el listado de la '",
  'El libro no tiene hojas con datos: elige el listado de la agencia.', 'falla', parseo='Excel')
m(G, F_ELS, "'(OR, CONTENEDOR, TIPO…): revisa que sea el listado de exportación '",
  'No se encontró la fila de encabezados del listado (OR, CONTENEDOR, TIPO…): revisa que sea el listado de '
  'exportación de la agencia.', 'falla', parseo='Excel')
m(G, F_ELS, "message: 'Al listado le faltan columnas: ${missing.join(', ')}. Pide a '",
  'Al listado le faltan columnas: {columnas}. Pide a la agencia el listado completo.', 'falla', parseo='Excel')
# Los dos avisos de fila se guardan con el listado (y se publican con su huella):
# el texto guardado no cambia y la acción se agrega al mostrarlos.
m(G, F_ELI, "Text('Fila ${issue.sheetRow}: ${issue.message} Corrige esa fila en '",
  'Fila {n}: OR {orden}: {falta el número de contenedor; el contenedor «x» no tiene la forma ISO 6346 …; marca '
  'lleno (F) y vacío (E) a la vez; …}. Corrige esa fila en el Excel y vuelve a importarlo.', 'aviso de datos',
  parseo='Excel')
m(G, F_ELI, "Text('Fila ${issue.sheetRow}: ${issue.message} Corrige esa fila en '",
  'Fila {n}: No es un contenedor ni un separador de agencia: «{texto}». Corrige esa fila en el Excel y vuelve a '
  'importarlo.', 'aviso de datos', parseo='Excel')

G = 'BAPLIE de salida'
m(G, F_DBW, "throw StateError('La operación no tiene el plan de carga (BAPLIE): '",
  'La operación no tiene el plan de carga (BAPLIE): impórtalo antes de generar la salida.', 'rechazo')
m(G, F_DBW, "throw StateError('No está disponible el plan efectivo de la operación: '",
  'No está disponible el plan efectivo de la operación: espera a que termine de cargar e inténtalo de nuevo.',
  'falla')
m(G, F_DBW, "'Hay ocupantes duplicados en el estado derivado; '",
  'Hay ocupantes duplicados en el estado derivado; resuelve el conflicto antes de generar.', 'conflicto')
m(G, F_DBW, "'no se puede conservar su información. Vuelve a importar el plano '",
  'Falta la fuente del ocupante {contenedor}; no se puede conservar su información. Vuelve a importar el plano de '
  'llegada y el plan de carga.', 'falla')
m(G, F_DBW, "'listado; faltan sus datos exactos. Importa el listado de la agencia '",
  'El contenedor cargado {contenedor} no está en el listado; faltan sus datos exactos. Importa el listado de la '
  'agencia que lo incluye.', 'falla')
m(G, F_DBW, "throw StateError('El listado contiene un peso inválido: corrige los pesos '",
  'El listado contiene un peso inválido: corrige los pesos en el Excel y vuelve a importarlo.', 'aviso de datos')
m(G, F_DBW, "'El listado no declara lleno/vacío para ${row.containerId}: corrige '",
  'El listado no declara lleno/vacío para {contenedor}: corrige esa fila en el Excel y vuelve a importarlo.',
  'aviso de datos')
m(G, F_DBW, "throw StateError('El listado no declara el VGM de ${row.containerId}: '",
  'El listado no declara el VGM de {contenedor}: pide el VGM a la agencia y vuelve a importar el listado.',
  'aviso de datos')
m(G, F_DBW, "'El plan de carga debe contener un único mensaje BAPLIE con sus '",
  'El plan de carga debe contener un único mensaje BAPLIE con sus segmentos UNB y UNH: no se generó la salida. '
  'Vuelve a importar el plan de carga.', 'falla', parseo='sí', segmento='sí')
m(G, F_DBW, "throw StateError('Versión BAPLIE no reconocida para salida 2.x en la '",
  'Versión BAPLIE no reconocida para salida 2.x en la cabecera UNH: {identificador|sin cabecera}. No se generó el '
  'archivo. Importa el plan de carga en SMDG20, SMDG21 o SMDG22.', 'falla', parseo='sí', segmento='sí')
m(G, F_DBW, "'Separadores EDIFACT no reconocidos en el segmento UNA del plan de '",
  'Separadores EDIFACT no reconocidos en el segmento UNA del plan de carga: no se generó la salida. Pide una '
  'exportación con los separadores estándar.', 'falla', parseo='sí', segmento='sí')
m(G, F_DBP, "'No se genera el BAPLIE de salida: '",
  'No se genera el BAPLIE de salida: «{archivo}» es versión 1.5 (SMDG15) y se leyó con las reglas de 2.x. Escribir '
  'la salida con esas reglas no sería fiel a lo que llegó. Importa el plano en SMDG20, SMDG21 o SMDG22.', 'rechazo')
m(G, F_DBP, "'La escala no tiene una operación guardada con su plan de carga: abre '",
  'La escala no tiene una operación guardada con su plan de carga: abre el plan de carga (BAPLIE) y confirma la '
  'escala.', 'rechazo')
m(G, F_DBP, "'La operación se está actualizando. Intenta de nuevo.'",
  'La operación se está actualizando. Intenta de nuevo.', 'falla')

G = 'Comparar BAPLIE'
m(G, _D + 'services/voyage_comparison.dart', "'No se puede confirmar que sea el mismo buque: $how. '",
  'No se puede confirmar que sea el mismo buque: {motivo}. Confirma que es el mismo buque antes de usar la '
  'comparación.', 'aviso de datos')
m(G, _D + 'services/voyage_comparison.dart', "'que el segundo archivo sea del mismo buque.';",
  'No parece el mismo buque: {nombre} ({clave}) y {nombre} ({clave}). Revisa que el segundo archivo sea del mismo '
  'buque.', 'aviso de datos')

G = 'Parámetros del buque (validación del formulario y de las tomas)'
m(G, F_GEO, "return 'Valor no numérico: escribe un número.';",
  'Valor no numérico: escribe un número.', 'validación')
m(G, F_GEO, "? 'No puede ser menor que $minimum: escribe $minimum o más.'",
  'No puede ser menor que {mínimo}: escribe {mínimo} o más.', 'validación')
m(G, F_GEO, "'quedaría fuera del plano. Escribe al menos $minimum.';",
  'El archivo trae carga en {la fila nn}; con {v} {filas a babor|estribor} quedaría fuera del plano. Escribe al '
  'menos {mínimo}.', 'validación')
m(G, F_GEO, "return 'Falta el límite de apilamiento: escríbelo o marca que no '",
  'Falta el límite de apilamiento: escríbelo o marca que no lo tienes.', 'validación')
m(G, F_GEO, "_socketError = 'Posición de toma no válida: escribe siete dígitos y '",
  'Posición de toma no válida: escribe siete dígitos y una bahía distinta de 000.', 'validación')
m(G, F_GEO, "'La frontera y las anclas no forman una geometría válida: revísalas '",
  'La frontera y las anclas no forman una geometría válida: revísalas antes de cargar tomas.', 'validación')
m(G, F_GEO, "? 'No hay códigos pegados: pega al menos uno.'",
  'No hay códigos pegados: pega al menos uno.', 'validación')
m(G, F_GEO, "'Revisa frontera y anclas: bodega debajo de la frontera y cubierta desde ella.'",
  'Revisa frontera y anclas: bodega debajo de la frontera y cubierta desde ella.', 'validación')
m(G, F_GEO, "'Falta resolver el límite de apilamiento: escríbelo o marca que '",
  'Falta resolver el límite de apilamiento: escríbelo o marca que no lo tienes.', 'validación')
m(G, F_RSR, "'Escribe un número o un rango así.'",
  '{Bahías|Filas|Niveles}: «{x}» no es un número ni un rango como 02-08. Escribe un número o un rango así.',
  'validación')
m(G, F_RSR, "'Escribe valores entre esos dos.'",
  '{campo}: «{x}» sale de {mín} a {máx}. Escribe valores entre esos dos.', 'validación')
m(G, F_RSR, "el final es menor que el inicio: escribe '",
  '{campo}: en «{x}» el final es menor que el inicio: escribe primero el menor.', 'validación')
m(G, F_RSR, "el paso tiene que ser 1 o más: escríbelo así, '",
  '{campo}: en «{x}» el paso tiene que ser 1 o más: escríbelo así, como 002-038/4.', 'validación')
m(G, F_RSR, "error: 'Faltan las bahías: escribe al menos una.'",
  'Faltan las bahías: escribe al menos una.', 'validación')
m(G, F_RSR, "error: 'Faltan los niveles: escribe al menos uno.'",
  'Faltan los niveles: escribe al menos uno.', 'validación')
m(G, F_RSR, "'Acótalo.'",
  'El rango genera {n} códigos; el máximo es {m}. Acótalo.', 'validación')

G = 'Búsqueda por voz'
for frag, texto in (
        ('Permiso de micrófono denegado. Puedes escribir la búsqueda.', 'Permiso de micrófono denegado. Puedes escribir la búsqueda.'),
        ('Reconocimiento sin conexión o servicio no disponible.', 'Reconocimiento sin conexión o servicio no disponible. Puedes escribir la búsqueda.'),
        ('No se entendió el dictado. Reintenta o escribe la búsqueda.', 'No se entendió el dictado. Reintenta o escribe la búsqueda.'),
        ('Reconocimiento en español no disponible.', 'Reconocimiento en español no disponible. Puedes escribir la búsqueda.'),
        ('Reconocimiento de voz no disponible. Puedes escribir la búsqueda.', 'Reconocimiento de voz no disponible. Puedes escribir la búsqueda.')):
    m(G, _P + 'widgets/voice_search_field.dart', frag, texto, 'falla')

G = 'Avisos de lectura del BAPLIE (tarjeta del viaje y Comparar)'
# El detalle de cada aviso se guarda con el viaje y no cambia: el título y la
# acción son de la pantalla.
m(G, F_CAR, "'Versión 1.5 (la cabecera UNH declara SMDG15), leída con las reglas de '",
  'Versión 1.5 (la cabecera UNH declara SMDG15), leída con las reglas de 2.x; revisa pesos y peligrosas',
  'aviso de datos', parseo='sí', segmento='sí')
m(G, F_CAR, "BaplieReadNoticeKind.weight => 'Pesos revisados en MEA',",
  'Pesos revisados en MEA: {n} contenedor(es) · revisa esos pesos antes de operar · detalle: «{número}: WT en LBR '
  'convertido a {x} kg», …', 'aviso de datos', parseo='sí', segmento='sí')
m(G, F_CAR, "BaplieReadNoticeKind.position => 'Posiciones mal formadas en LOC+147',",
  'Posiciones mal formadas en LOC+147: {n} contenedor(es) · pide una exportación corregida · detalle: «{número}: '
  '{posición}»', 'aviso de datos', parseo='sí', segmento='sí')
m(G, F_CAR, "BaplieReadNoticeKind.checkDigit => 'Dígito de control inválido en EQD',",
  'Dígito de control inválido en EQD: {n} contenedor(es) · revisa esos números con la agencia · detalle: '
  '«{número}»', 'aviso de datos', parseo='sí', segmento='sí')
m(G, F_CAR, "BaplieReadNoticeKind.incomplete => 'Archivo posiblemente incompleto'",
  'Archivo posiblemente incompleto: faltan {n} segmentos ({UNB, BGM, UNT, UNZ}) · detalle: «El archivo puede venir '
  'incompleto. Revisa los segmentos que faltan:»', 'aviso de datos', parseo='sí', segmento='sí')

G = 'Rejilla y geometría (Bay Plan y Orden de descarga)'
m(G, _P + 'widgets/bay_plan_view.dart', "'el buque declarado: ${rest > 0 ? '$shown y $rest más' : shown}. '",
  '{n} contenedores fuera de la geometría declarada · No se dibujan en la rejilla porque su posición no existe en '
  'el buque declarado: {posiciones}. Amplía la geometría en Parámetros del buque.', 'aviso de datos')
m(G, _P + 'widgets/bay_plan_view.dart', "'${outside.length > 6 ? ' y ${outside.length - 6} más' : ''}. Amplía la '",
  '{n} celdas reservadas fuera de la geometría declarada: {posiciones}[ y {n} más]. Amplía la geometría en '
  'Parámetros del buque.', 'aviso de datos')
m(G, _P + 'widgets/bay_plan_view.dart', "'Este viaje no trae la geometría del buque declarada, así que no '",
  'Este viaje no trae la geometría del buque declarada, así que no hay rejilla contra la cual dibujarlo. Declara '
  'los parámetros del buque para ver el plano.', 'aviso de datos')
m(G, _P + 'pages/discharge_sequence_page.dart', "? 'La geometría del buque está sin confirmar: confírmala para '",
  'La geometría del buque está sin confirmar: confírmala para sugerir el orden de descarga.', 'rechazo')
m(G, _P + 'pages/discharge_sequence_page.dart', ": 'El archivo no trae puertos de descarga (LOC+11) en ningún '",
  'El archivo no trae puertos de descarga (LOC+11) en ningún contenedor: no hay orden que sugerir. Pide una '
  'exportación del BAPLIE que los incluya.', 'aviso de datos')

G = 'Conflictos de la operación (detalle de la celda, Avance, Tapas en la operación)'
# Cada conflicto lleva al final la acción que lo deshace en su pantalla
# (operation_state_deriver.dart: problem() y _remedy()).
BANDEJA = ' Revísalo en la bandeja de cambios de la oficina.'
TAPA = ' Si el registro fue un error, deshazlo con «Deshacer conflicto».'
CONTENEDOR = ' Si el registro fue un error, deshazlo desde el detalle del contenedor.'
CELDA = ' Si el registro fue un error, deshazlo desde el detalle de la celda.'
CANCELACION = ' Si la cancelación fue un error, la oficina la deshace desde el detalle de la celda.'
for frag, texto, accion in (
        ("problem(m, 'Solicitud con cambios inválidos: no trae de uno a cuatro '",
         'Solicitud con cambios inválidos: no trae de uno a cuatro cambios válidos.', BANDEJA),
        ("'La decisión cita una solicitud que no está vigente.'", 'La decisión cita una solicitud que no está vigente.', BANDEJA),
        ("'La solicitud ya tiene una decisión o está en conflicto.'", 'La solicitud ya tiene una decisión o está en conflicto.', BANDEJA),
        ("'El rechazo no cita una solicitud.'", 'El rechazo no cita una solicitud.', BANDEJA),
        ("'El cambio no contiene de uno a cuatro cambios válidos.'", 'El cambio no contiene de uno a cuatro cambios válidos.', BANDEJA),
        ("'La aprobación no coincide con lo solicitado.'", 'La aprobación no coincide con lo solicitado.', BANDEJA),
        ("no está en el plan de carga.'", '{Objeto} no está en el plan de carga.', BANDEJA),
        ("origen obsoleto; plan efectivo", '{Objeto}: origen obsoleto; plan efectivo {p}, cambio desde {p}.', BANDEJA),
        ("está prevista para otro objeto del plan.'", '{celda} está prevista para otro objeto del plan.', BANDEJA),
        ("tapa sin declarar o acción inválida.'", '{tapa}: tapa sin declarar o acción inválida.', TAPA),
        ("'ya está quitada'", 'Bahía {b} · {tapa}: {ya está quitada|no está quitada para reponerla}.', TAPA),
        ("no está en el plano de llegada de esta escala.'", '{Objeto} no está en el plano de llegada de esta escala.', CONTENEDOR),
        ("está cancelado y se descargó.'", '{Objeto} está cancelado y se descargó.', CONTENEDOR),
        ("si sale para volver a subir, es una re", '{Objeto} no descarga en {escala}; si sale para volver a subir, es una re‑estiba.', CONTENEDOR),
        ("ya la ocupa ${_occupant(taken)}.'", '{celda} ya la ocupa {objeto}. (tres reglas: descarga, carga y vacío)', CELDA),
        ("no está en el plan de carga de ${plan.portOfCall}.'", '{Objeto} no está en el plan de carga de {escala}.', CELDA),
        ("está cancelado y se cargó.'", '{Objeto} está cancelado y se cargó.', CELDA),
        ("no se carga en ${plan.portOfCall}.'", '{Objeto} no se carga en {escala}.', CELDA),
        ("ya se cargó en ${status.position}.'", '{Objeto} ya se cargó en {posición}.', CELDA),
        ("planificado en ${status.plannedPosition}, registrado en $position.'", '{Objeto}: planificado en {p}, registrado en {p}.', CELDA),
        ("no es una celda reservada del plan.'", '{Objeto} no es una celda reservada del plan.', CELDA),
        ("está cancelada y se asignó.'", '{Objeto} está cancelada y se asignó.', CELDA),
        ("ya tiene asignado ${status.assignedContainer}.'", '{Objeto} ya tiene asignado {contenedor}.', CELDA),
        ("ya está en ${_shown(elsewhere)}.'", '{contenedor} ya está en {objeto}.', CELDA),
        ("quedó en una '", '{contenedor} ({tipo} · {POD} · {línea}) quedó en una reserva de {tipo} · {POD} · {línea}.', CELDA),
        ("no está en el plan de esta escala.'", '{Objeto} no está en el plan de esta escala.', CANCELACION),
        ("ya se movió; para cancelarlo, anula antes ese movimiento.'", '{Objeto} ya se movió; para cancelarlo, anula antes ese movimiento.', '')):
    m(G, F_OSD, frag, texto + accion, 'conflicto')

G = 'El toString() de una excepción, ahora con mensaje en español (T-112)'
m(G, (_P + 'widgets/plan_drag_confirmation.dart', _P + 'widgets/loading_controls.dart',
      _P + 'widgets/office_plan_controls.dart', _P + 'pages/change_requests_page.dart'),
  ": vesselErrorMessage(failure, stack, '",
  'Cuando el error no es un StateError: «No se pudo {guardar el cambio|registrar la carga|guardar la acción de la '
  'oficina|decidir la solicitud|enviar el cambio} ' + INTERNO + '» (o la variante del almacén local)', 'falla')
m(G, _P + 'widgets/hatch_operation_controls.dart', "error, stack, 'leer las tapas de la operación'))",
  'No se pudo leer las tapas de la operación ' + INTERNO + ' (con el almacén local: «…' + ALMACEN + '»)', 'falla')

# Envolturas: muestran un mensaje de la tabla sin cambiarlo o con un prefijo
# que no agrega causa ni acción. No suman filas.
ENVOLTURAS = [
    (F_OVR, "'Error al procesar archivo'", 'título del estado de error + vesselErrorMessage y botón «Intentar de nuevo»'),
    (F_OVR, 'result.errorMessage ?? unexpectedErrorMessage', 'SnackBar con el LoadFileResult.error'),
    (F_OVR, "'aplicar la plantilla del buque'", 'plantilla del buque: vesselErrorMessage'),
    (F_OVR, 'content: Text(error),', 'error de confirmGeometry (vessel_providers)'),
    (F_VPR, "'Archivo «${file.name}»: $notBaplieFileMessage'", 'prefijo con el nombre del archivo'),
    (F_VPR, "'Archivo «$fileName»: ${vesselFailureMessage(failure)}'", 'prefijo con el nombre del archivo'),
    (_P + 'pages/recent_voyages_page.dart', "'leer los viajes recientes'", 'estado de error + «Reintentar»'),
    (_P + 'pages/vessel_profiles_page.dart', "'leer los perfiles guardados'", 'estado de error + «Reintentar»'),
    (_P + 'pages/vessel_profiles_page.dart', "content: Text(error ?? 'Perfil guardado'),", 'error de saveEditedProfile'),
    (_P + 'pages/recent_voyages_page.dart', '.showSnackBar(SnackBar(content: Text(error)));', 'error de openRecentVoyage'),
    (_P + 'widgets/discharge_controls.dart', "'No se quitó la tapa: ${first.error}'", 'prefijo + error del registro'),
    (_P + 'widgets/discharge_controls.dart', "'No se registró: ${result.error}'", 'prefijo + error del registro'),
    (_P + 'widgets/discharge_controls.dart', "'No se deshizo: $error'", 'prefijo + error del registro (dos sitios)'),
    (_P + 'widgets/hatch_operation_controls.dart', '_error = result.error;', 'error del registro de tapa'),
    (_P + 'widgets/loading_controls.dart', 'messenger.showSnackBar(SnackBar(content: Text(error)));', 'error de Deshacer'),
    (F_GEO, "if (error != null) return 'Bahía ${entry.key}: $error';", 'prefijo con la bahía + validación de tapas'),
    (_P + 'pages/hatch_covers_page.dart', "_error = 'Bahía $target: $error'", 'prefijo con la bahía + validación de tapas'),
    (_D + 'entities/vessel_profile.dart', "if (error != null) return 'Bahía ${entry.key}: $error';", 'prefijo con la bahía'),
    (_P + 'pages/voyage_comparison_page.dart', "notice('Archivo «${file.name}»: $notBaplieFileMessage');", 'prefijo con el nombre del archivo'),
    (_P + 'pages/voyage_comparison_page.dart', "vesselFailureMessage(failure, 'leer el archivo')", 'prefijo con el nombre del archivo'),
    (_P + 'pages/voyage_comparison_page.dart', "'comparar los dos archivos'", 'vesselErrorMessage'),
    (F_DBP, "_notice(error is StateError", 'StateError del escritor o vesselErrorMessage'),
    (F_DBP, "'comparar la salida con la llegada'", 'vesselFailureMessage'),
    (F_CLD, 'error = vesselErrorMessage(failure, stack, operation);', '_run: vesselErrorMessage con la operación'),
    (F_CLD, 'rejectionText(error)', '_run: el texto de la falla sin puntos repetidos'),
    (F_ELP, 'error: e.failure.message', 'mensaje de la lectura del listado'),
    (_P + 'pages/change_requests_page.dart', 'const ChangeRequests().review(data, batch)!', 'error de la revisión del cambio'),
    (_P + 'widgets/plan_drag_confirmation.dart', '.showSnackBar(SnackBar(content: Text(result.error!)));', 'error de la revisión del arrastre'),
    (_P + 'widgets/loading_controls.dart', "issue.blocks ? 'No se registra' : 'Pide motivo'", 'prefijo de la revisión de carga'),
]
