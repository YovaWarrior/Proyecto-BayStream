"""T-98 · Censo de los mensajes de error (RNF-006): todo lo que lib/ puede
mostrar cuando algo no se pudo hacer, se rechazó, no pasó una validación,
trae datos con problemas o queda en conflicto.

Cada fila nombra su archivo y un fragmento único del literal; el script busca
el fragmento en sprint3-cierre y escribe la línea (o las líneas, si el mismo
texto aparece en varias). Si un fragmento no aparece, el censo falla: la tabla
no puede quedar desalineada del código.

Juicios (escritos leyendo el código y la ruta hasta la pantalla):
- causa: «sí» si dice qué falló o por qué; «impl.» si solo se deduce de la
  instrucción (p. ej. «Escribe un número.»); «no» si es genérica («No se pudo
  cerrar la sesión.»).
- acción: «sí» si dice qué hacer; «impl.» si se deduce de la causa o de la
  regla («Sin conexión: iniciar sesión requiere red.»); «no» si no la hay.
- segmento: solo para errores de lectura de un BAPLIE (parseo = «sí»):
  «sí» si nombra el segmento EDIFACT.
- arreglo: el texto que falta para que el mensaje diga causa y acción
  explícitas (la lectura estricta) y, si es de lectura, el segmento; también
  señala los identificadores en inglés. Vacío solo si no falta nada: censo()
  lo exige.
"""
import re

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
F_DBW = _D + 'services/departure_baplie_writer.dart'
F_DBP = _P + 'pages/departure_baplie_page.dart'
F_GEO = _P + 'pages/vessel_geometry_page.dart'
F_RSR = _D + 'services/reefer_socket_ranges.dart'
F_OSD = _D + 'services/operation_state_deriver.dart'
F_CAR = _P + 'widgets/voyage_summary_card.dart'

GENERICO = ('No se pudo completar la operación por un error inesperado. '
            'Inténtalo de nuevo; si persiste, reinicia la aplicación.')

# (id, grupo, archivo, fragmento, texto como se ve, tipo, causa, acción,
#  parseo, segmento, arreglo sugerido)
M = []


def m(grupo, archivo, fragmento, texto, tipo, causa, accion, arreglo='',
      parseo='no', segmento='—'):
    M.append({'grupo': grupo, 'archivo': archivo, 'fragmento': fragmento,
              'texto': texto, 'tipo': tipo, 'causa': causa, 'accion': accion,
              'parseo': parseo, 'segmento': segmento, 'arreglo': arreglo})


G = 'Formateador común (vessel_error_message.dart)'
m(G, F_ERR, 'por un error inesperado', GENERICO, 'falla', 'no', 'sí',
  'Que el llamador diga qué falló, como ya hacen exportar, tema y preferencia: «No se pudo {operación}.» '
  'El motivo técnico queda en el registro.')
m(G, F_ERR, 'no parece un BAPLIE',
  'Este archivo no parece un BAPLIE: no se reconoce su cabecera UNH/S009. Selecciona una exportación BAPLIE '
  'completa. (También con «Archivo «nombre»: » delante.)', 'falla', 'sí', 'sí', parseo='sí', segmento='sí')
m(G, F_ERR, 'no trae el nombre del buque en el segmento TDT',
  'El archivo no trae el nombre del buque en el segmento TDT. Revisa que sea un BAPLIE completo o pide una nueva '
  'exportación.', 'falla', 'sí', 'sí', parseo='sí', segmento='sí')
m(G, F_ERR, "return 'No se pudo interpretar el archivo BAPLIE. '",
  'No se pudo interpretar el archivo BAPLIE. Revisa su formato o pide una nueva exportación.',
  'falla', 'no', 'sí',
  'Usar el segmento y la línea que ya trae BaplieParsingFailure: «No se pudo interpretar el segmento {segmento} '
  '(línea {n}) del archivo BAPLIE. Revisa su formato o pide una nueva exportación.»', parseo='sí', segmento='no')
m(G, F_ERR, 'Hay un perfil con el mismo nombre y no se puede identificar',
  'Hay un perfil con el mismo nombre y no se puede identificar el buque. Confirma su identidad antes de guardar.',
  'rechazo', 'sí', 'sí')
m(G, F_ERR, 'No se pudo acceder a los datos guardados en este dispositivo',
  'No se pudo acceder a los datos guardados en este dispositivo. Inténtalo de nuevo; si persiste, reinicia la '
  'aplicación.', 'falla', 'no', 'sí',
  'Decir qué dato no se pudo leer o guardar: «No se pudo leer el viaje guardado…», «No se pudo guardar el perfil…».')

G = 'Carga del BAPLIE, perfil y viajes (vessel_providers.dart y pantallas)'
m(G, F_OVR, "'No se pudo guardar la preferencia. '",
  'No se pudo guardar la preferencia. ' + GENERICO, 'falla', 'no', 'sí',
  'Agregar la consecuencia: «…; la barra queda como estaba.»')
m(G, F_OVR, "'No se pudo exportar ${format.label}",
  'No se pudo exportar {PDF|CSV|JSON}. ' + GENERICO, 'falla', 'no', 'sí',
  'Si el motivo es el selector o el disco, decirlo; si no se conoce, basta lo actual más «Revisa el espacio y '
  'los permisos de la carpeta elegida.»')
m(G, F_VPR, 'No hay un buque nuevo confirmado para usar la plantilla',
  'No hay un buque nuevo confirmado para usar la plantilla. Confirma primero el buque o inicia otra carga.',
  'rechazo', 'sí', 'sí')
m(G, F_VPR, 'Ya hay una carga en curso. Termínala o cancélala',
  'Ya hay una carga en curso. Termínala o cancélala antes de abrir otra.', 'rechazo', 'sí', 'sí')
m(G, F_VPR, 'Hay una operación en curso. Espera a que termine e inténtalo de nuevo.',
  'Hay una operación en curso. Espera a que termine e inténtalo de nuevo.', 'rechazo', 'sí', 'sí')
m(G, F_VPR, 'No hay una identidad pendiente.',
  'No hay una identidad pendiente. Carga un BAPLIE para elegir el buque.', 'rechazo', 'sí', 'sí')
m(G, F_VPR, 'El perfil no corresponde a este buque.',
  'El perfil no corresponde a este buque. Elige uno de los perfiles propuestos.', 'validación', 'sí', 'sí')
m(G, F_VPR, 'No se pueden distinguir estos buques solo por nombre.',
  'No se pueden distinguir estos buques solo por nombre. Pide una exportación con IMO o indicativo en el archivo.',
  'rechazo', 'sí', 'sí')
m(G, F_VPR, 'Elige si este BAPLIE es de llegada o de carga.',
  'Elige si este BAPLIE es de llegada o de carga.', 'validación', 'impl.', 'sí',
  'Decir la causa: «Falta indicar si este BAPLIE es de llegada o de carga: elige una opción.»')
m(G, F_VPR, 'Confirma primero la identidad del buque.',
  'Confirma primero la identidad del buque.', 'validación', 'impl.', 'sí',
  '«La identidad del buque está sin confirmar: confírmala primero.»')
m(G, F_VPR, 'No hay un viaje para confirmar.',
  'No hay un viaje para confirmar. Carga un BAPLIE primero.', 'rechazo', 'sí', 'sí')
m(G, F_VPR, 'La geometría deja posiciones del archivo fuera del plano.',
  'La geometría deja posiciones del archivo fuera del plano. Amplía las filas o niveles para incluirlas.',
  'validación', 'sí', 'sí')
m(G, F_VPR, 'La edición de parámetros no permite cambiar la identidad del buque.',
  'La edición de parámetros no permite cambiar la identidad del buque. Abre el perfil correcto antes de editar.',
  'rechazo', 'sí', 'sí')
m(G, F_VPR, 'La geometría deja posiciones del viaje abierto fuera del plano.',
  'La geometría deja posiciones del viaje abierto fuera del plano. Amplía las filas o niveles para incluirlas.',
  'validación', 'sí', 'sí')
m(G, F_VPR, 'El perfil cambió. Vuelve a abrirlo antes de editar.',
  'El perfil cambió. Vuelve a abrirlo antes de editar.', 'rechazo', 'sí', 'sí')
m(G, F_VPR, 'El viaje ya no está guardado. Vuelve a cargar su BAPLIE.',
  'El viaje ya no está guardado. Vuelve a cargar su BAPLIE.', 'falla', 'sí', 'sí')
m(G, F_VPR, 'Este viaje no tiene una geometría válida guardada.',
  'Este viaje no tiene una geometría válida guardada. Vuelve a cargar el BAPLIE.', 'falla', 'sí', 'sí')
m(G, _DA + 'services/baplie_parser_service.dart', "message: 'Versión BAPLIE no admitida: $version. '",
  'Archivo «{nombre}»: Versión BAPLIE no admitida: {identificador S009}. BayStream lee la familia 2.x (SMDG20, '
  'SMDG21 y SMDG22). [El archivo contiene más de un mensaje.] Pide una exportación compatible.',
  'falla', 'sí', 'sí',
  'Nombrar el segmento: «… la cabecera UNH declara {identificador} …».', parseo='sí', segmento='no')
m(G, _P + 'pages/recent_voyages_page.dart', "'No se aplicó del perfil vigente: '",
  'No se aplicó del perfil vigente: {parámetros}. Dejaría contenedores de este viaje fuera del plano; se conserva '
  'el valor guardado con el viaje. Revisa el perfil del buque.', 'aviso de datos', 'sí', 'sí')
m(G, _P + 'pages/parameters_page.dart', "'No se pudo guardar el tema. ",
  'No se pudo guardar el tema. ' + GENERICO, 'falla', 'no', 'sí',
  'Agregar la consecuencia: «…; se mantiene el tema anterior.»')
m(G, _P + 'pages/parameters_page.dart', 'No se pudo leer el tema guardado. Puedes elegirlo de nuevo.',
  'No se pudo leer el tema guardado. Puedes elegirlo de nuevo.', 'falla', 'no', 'sí',
  '«No se pudo leer el tema guardado; se usa el del sistema. Puedes elegirlo de nuevo.»')
m(G, 'lib/main.dart', "'Esta versión de BayStream no tiene todas las opciones '",
  'Falta la configuración de Firebase · Esta versión de BayStream no tiene todas las opciones necesarias para '
  'iniciar. Solicita una compilación configurada al responsable.', 'falla', 'sí', 'sí')

G = 'Cuenta y nube (Nube y cuenta)'
m(G, F_SES, "'Correo o contraseña incorrectos.'",
  'Correo o contraseña incorrectos.', 'rechazo', 'sí', 'no',
  '«Correo o contraseña incorrectos. Revísalos e inténtalo de nuevo, o usa «Olvidé mi contraseña».»')
m(G, F_SES, "'El correo no es válido.'",
  'El correo no es válido.', 'validación', 'sí', 'no',
  '«El correo no es válido: escríbelo completo, como nombre@dominio.»')
m(G, F_SES, 'Esta cuenta está deshabilitada. Habla con el responsable.',
  'Esta cuenta está deshabilitada. Habla con el responsable.', 'rechazo', 'sí', 'sí')
m(G, F_SES, 'Demasiados intentos. Espera un momento.',
  'Demasiados intentos. Espera un momento.', 'rechazo', 'sí', 'sí')
m(G, F_SES, 'Sin conexión: iniciar sesión requiere red.',
  'Sin conexión: iniciar sesión requiere red.', 'falla', 'sí', 'impl.',
  '«Sin conexión: iniciar sesión requiere red. Conéctate e inténtalo de nuevo.»')
m(G, F_SES, "'No se pudo iniciar sesión ($code).'",
  'No se pudo iniciar sesión ({código de Firebase}).', 'falla', 'no', 'no',
  '«No se pudo iniciar sesión (código {código}). Inténtalo de nuevo; si se repite, avisa al responsable con ese '
  'código.»')
m(G, F_SES, 'No se pudo iniciar sesión. Inténtalo de nuevo.',
  'No se pudo iniciar sesión. Inténtalo de nuevo.', 'falla', 'no', 'sí',
  'Si el motivo no se conoce, no hay causa que agregar; basta la acción.')
m(G, F_SES, 'No se pudo cerrar la sesión.',
  'No se pudo cerrar la sesión.', 'falla', 'no', 'no', '«No se pudo cerrar la sesión. Inténtalo de nuevo.»')
m(G, F_SES, "'No se pudo enviar el correo (${error.code}).'",
  'No se pudo enviar el correo ({código de Firebase}).', 'falla', 'no', 'no',
  '«No se pudo enviar el correo (código {código}). Revisa la conexión e inténtalo de nuevo.»')
m(G, F_CLD, 'Escribe tu correo para recuperar la contraseña.',
  'Escribe tu correo para recuperar la contraseña.', 'validación', 'impl.', 'sí',
  '«Falta el correo: escríbelo para recuperar la contraseña.»')
m(G, F_CLD, 'Abre el plano de la escala para publicarla con su perfil de buque.',
  'Abre el plano de la escala para publicarla con su perfil de buque.', 'rechazo', 'impl.', 'sí',
  '«Falta el perfil del buque: abre el plano de la escala para publicarla con su perfil.»')
m(G, F_CLD, 'No se pudieron leer las operaciones: revisa la conexión y la cuenta.',
  'No se pudieron leer las operaciones: revisa la conexión y la cuenta.', 'falla', 'impl.', 'sí',
  '«No se pudieron leer las operaciones: puede faltar la conexión o el permiso de la cuenta. Revisa la conexión y '
  'la cuenta.»')
m(G, F_CLD, "'La operación no tiene esa fuente.'",
  'La operación no tiene esa fuente.', 'rechazo', 'sí', 'no',
  '«La operación no tiene esa fuente. Abre otra o pide a la oficina que la publique.»')
m(G, F_CLD, "'No se abrió la fuente.'",
  'No se abrió la fuente.', 'falla', 'no', 'no', '«No se abrió la fuente publicada. Inténtalo de nuevo.»')
m(G, F_FOS, "message: 'Inicia sesión con una cuenta de oficina.'",
  'Inicia sesión con una cuenta de oficina.', 'rechazo', 'impl.', 'sí',
  '«Publicar y cerrar exige sesión: inicia sesión con una cuenta de oficina.»')
m(G, F_FOS, 'Solo una cuenta de oficina autorizada publica y cierra operaciones.',
  'Solo una cuenta de oficina autorizada publica y cierra operaciones.', 'rechazo', 'sí', 'no',
  '«… Inicia sesión con una cuenta de oficina autorizada.»')
m(G, F_FOS, "'Sin respuesta de la nube. Publicar requiere conexión: '",
  'Sin respuesta de la nube. Publicar requiere conexión: revisa la red e inténtalo de nuevo.', 'falla', 'sí', 'sí')
m(G, F_FOS, "'La nube no aceptó la publicación: revisa que la cuenta sea de oficina '",
  'La nube no aceptó la publicación: revisa que la cuenta sea de oficina y esté activa.', 'rechazo', 'sí', 'sí')
m(G, F_FOS, "'unavailable' => 'Sin conexión con la nube. Publicar requiere red.'",
  'Sin conexión con la nube. Publicar requiere red.', 'falla', 'sí', 'impl.',
  '«… Conéctate e inténtalo de nuevo.»')
m(G, F_FOS, "'La nube devolvió un error (${error.code}).'",
  'La nube devolvió un error ({código de Firebase}).', 'falla', 'no', 'no',
  '«La nube devolvió un error (código {código}). Inténtalo de nuevo; si se repite, avisa al responsable con ese '
  'código.»')
m(G, F_FOS, "message: 'La operación ya no está en la nube.'",
  'La operación ya no está en la nube.', 'falla', 'sí', 'no',
  '«… Pide a la oficina que la publique de nuevo.»')
m(G, F_FOS, "'La fuente ${kind.wire} llegó incompleta o distinta de la '",
  'La fuente {arrival_baplie|loading_baplie|export_list} llegó incompleta o distinta de la publicada. No se guardó '
  'nada: vuelve a intentarlo.', 'falla', 'sí', 'sí',
  'Nombrar la fuente en español en lugar del identificador: «La fuente {plano de llegada|plan de carga|listado} …».')
m(G, F_FOS, "'Tu cuenta no puede leer esta operación: revisa que esté autorizada.'",
  'Tu cuenta no puede leer esta operación: revisa que esté autorizada.', 'rechazo', 'sí', 'sí')
m(G, F_FOS, "'Sin conexión con la nube. Unirse requiere red.'",
  'Sin conexión con la nube. Unirse requiere red.', 'falla', 'sí', 'impl.', '«… Conéctate e inténtalo de nuevo.»')
m(G, F_FOS, "message: 'Sin respuesta de la nube. Unirse requiere red.'",
  'Sin respuesta de la nube. Unirse requiere red.', 'falla', 'sí', 'impl.', '«… Revisa la red e inténtalo de nuevo.»')
m(G, F_FOS, "'No se encontró la operación para cerrarla.'",
  'No se encontró la operación para cerrarla.', 'falla', 'sí', 'no',
  '«… Puede que ya esté cerrada: revisa las operaciones abiertas.»')
m(G, F_FOS, "message: 'Sin respuesta de la nube. Cerrar requiere red.'",
  'Sin respuesta de la nube. Cerrar requiere red.', 'falla', 'sí', 'impl.', '«… Revisa la red e inténtalo de nuevo.»')
m(G, _DA + 'repositories/local_only_operation_sync.dart', "message: 'Esta compilación no tiene la nube configurada: la app trabaja '",
  'Esta compilación no tiene la nube configurada: la app trabaja en un solo dispositivo.', 'rechazo', 'sí', 'no',
  '«… Para sincronizar, pide al responsable una compilación con la nube.»')
m(G, _D + 'services/operation_sources.dart', "message: 'La operación de esta escala ya está publicada y sus fuentes '",
  'La operación de esta escala ya está publicada y sus fuentes no cambian. Abre la fuente publicada desde «Nube y '
  'cuenta».', 'rechazo', 'sí', 'sí')

G = 'Estado de envío con error (sync_status_chip.dart: barra, Bay Plan, Avance, Solicitudes)'
m(G, F_SYN, "'Sesión vencida: inicia sesión para enviar ${status.pending}'",
  'Sesión vencida: inicia sesión para enviar {n}', 'estado de error', 'sí', 'sí')
m(G, F_SYN, "'Tu cuenta no está autorizada · ",
  'Tu cuenta no está autorizada · {n} espera(n)', 'estado de error', 'sí', 'no',
  '«Tu cuenta no está autorizada · {n} esperan · pide al responsable que la autorice»')
m(G, F_SYN, "SyncState.unconfirmed => 'Sin confirmar desde las '",
  'Sin confirmar desde las {hh:mm} · inicia sesión de nuevo', 'estado de error', 'impl.', 'sí',
  '«Sesión sin confirmar desde las {hh:mm} · inicia sesión de nuevo»')
m(G, F_SYN, "_count(status.rejected, 'rechazado', 'rechazados')",
  '{n} rechazado(s)', 'estado de error', 'no', 'no',
  '«{n} rechazados por la nube · abre Nube y cuenta y pulsa Reintentar». El motivo se guarda en el registro '
  '(sync_engine.dart) y ninguna pantalla lo muestra.')

G = 'Registro de movimientos (bitácora y validación del borrador)'
m(G, _DA + 'repositories/movement_log_repository_impl.dart', "message: 'No se pudo acceder a la bitácora local. Inténtalo de nuevo.'",
  'No se pudo acceder a la bitácora local. Inténtalo de nuevo.', 'falla', 'no', 'sí',
  'Agregar la consecuencia: «… El movimiento no se registró.»')
m(G, F_MOV, 'Este tipo de movimiento no admite corrección.',
  'Este tipo de movimiento no admite corrección.', 'validación', 'sí', 'no',
  '«… Anúlalo y registra uno nuevo.»')
m(G, F_MOV, "return 'Falta el número de contenedor.'",
  'Falta el número de contenedor.', 'validación', 'sí', 'impl.', '«Falta el número de contenedor: escríbelo.»')
m(G, F_MOV, 'La posición debe tener 6 o 7 cifras (BBBRRTT).',
  'La posición debe tener 6 o 7 cifras (BBBRRTT).', 'validación', 'sí', 'impl.',
  '«La posición debe tener 6 o 7 cifras (BBBRRTT): corrígela.»')
m(G, F_MOV, "return 'Falta la celda reservada.'",
  'Falta la celda reservada.', 'validación', 'sí', 'impl.', '«Falta la celda reservada: elige una.»')
m(G, F_MOV, "return 'Falta el número del vacío.'",
  'Falta el número del vacío.', 'validación', 'sí', 'impl.', '«Falta el número del vacío: elige su OR.»')
m(G, F_MOV, "return 'Tara fuera de rango.'",
  'Tara fuera de rango.', 'validación', 'sí', 'no', '«Tara fuera de rango: debe estar entre 1 y 14 999 kg.»')
m(G, F_MOV, "return 'Falta el movimiento a anular.'",
  'Falta el movimiento a anular.', 'validación', 'sí', 'no', 'Invariante del formulario; no se corrige con texto.')
m(G, F_MOV, "return 'Anular exige un motivo.'",
  'Anular exige un motivo.', 'validación', 'sí', 'impl.', '«Anular exige un motivo: escríbelo.»')
m(G, F_MOV, "return 'Falta el contenedor o la reserva a cancelar.'",
  'Falta el contenedor o la reserva a cancelar.', 'validación', 'sí', 'no',
  'Invariante del formulario; no se corrige con texto.')
m(G, F_MOV, "return 'Cancelar exige un motivo de hasta 300 caracteres.'",
  'Cancelar exige un motivo de hasta 300 caracteres.', 'validación', 'sí', 'impl.',
  '«Cancelar exige un motivo de hasta 300 caracteres: escríbelo.»')
m(G, F_MOV, "return 'Un cambio lleva sus objetos en la lista.'",
  'Un cambio lleva sus objetos en la lista.', 'validación', 'sí', 'no',
  'Invariante interna (el formulario no la produce); si se ve: «Error interno del cambio; vuelve a intentarlo.»')
m(G, F_MOV, "return 'Escribe un motivo de hasta 300 caracteres.'",
  'Escribe un motivo de hasta 300 caracteres.', 'validación', 'impl.', 'sí',
  '«Falta el motivo: escribe uno de hasta 300 caracteres.»')
m(G, F_MOV, "return 'Falta la solicitud.'",
  'Falta la solicitud.', 'validación', 'sí', 'no', 'Invariante del formulario; no se corrige con texto.')
m(G, F_MOV, "return 'Indica una tapa y la acción quitar o reponer.'",
  'Indica una tapa y la acción quitar o reponer.', 'validación', 'impl.', 'sí',
  '«Falta la tapa o la acción: indica una tapa y la acción quitar o reponer.»')

G = 'Cambios del plan (arrastre, solicitudes, oficina)'
m(G, (F_CHG, _P + 'widgets/plan_drag_confirmation.dart'), "'Inicia sesión para mover'",
  'Inicia sesión para mover', 'rechazo', 'impl.', 'sí', '«Mover exige sesión: inicia sesión para mover.»')
m(G, (F_CHG, F_MOV), "'Indica de uno a cuatro cambios válidos, sin repetir objetos ni destinos.'",
  'Indica de uno a cuatro cambios válidos, sin repetir objetos ni destinos.', 'validación', 'impl.', 'sí',
  '«Los cambios de la solicitud no son válidos: indica de uno a cuatro, sin repetir objetos ni destinos.»')
m(G, F_CHG, "'Solo se mueve un objeto pendiente del plan de carga.'",
  'Solo se mueve un objeto pendiente del plan de carga.', 'rechazo', 'sí', 'no',
  '«… Este ya se cargó o se canceló.»')
m(G, F_CHG, "'Las reservas del intercambio deben ser del mismo grupo.'",
  'Las reservas del intercambio deben ser del mismo grupo.', 'validación', 'sí', 'impl.',
  '«… Elige reservas del mismo grupo (tipo, POD y línea).»')
m(G, F_CHG, "'Solo se cancela un objeto pendiente del plan de carga.'",
  'Solo se cancela un objeto pendiente del plan de carga.', 'rechazo', 'sí', 'no',
  '«… Este ya se cargó o ya está cancelado; si se cargó, anula antes ese movimiento.»')
m(G, F_CHG, "'El cambio de oficina ya no está vigente.'",
  'El cambio de oficina ya no está vigente.', 'rechazo', 'sí', 'no', '«… Actualiza el detalle para ver el estado actual.»')
m(G, F_CHG, "'Deshacer exige un motivo de hasta 300 caracteres.'",
  'Deshacer exige un motivo de hasta 300 caracteres.', 'validación', 'sí', 'impl.',
  '«Deshacer exige un motivo de hasta 300 caracteres: escríbelo.»')
m(G, F_CHG, "'Solo una cuenta de muelle autorizada puede pedir cambios.'",
  'Solo una cuenta de muelle autorizada puede pedir cambios.', 'rechazo', 'sí', 'no',
  '«… Inicia sesión con una cuenta de muelle autorizada.»')
m(G, F_CHG, "'Solo una cuenta de oficina autorizada puede decidir.'",
  'Solo una cuenta de oficina autorizada puede decidir.', 'rechazo', 'sí', 'no',
  '«… Inicia sesión con una cuenta de oficina autorizada.»')
m(G, (F_CHG, _P + 'widgets/plan_drag_confirmation.dart'), "'La operación debe estar publicada y abierta.'",
  'La operación debe estar publicada y abierta.', 'rechazo', 'sí', 'no',
  '«… La oficina la publica desde Nube y cuenta.»')
m(G, F_CHG, "'Indica de uno a cuatro cambios válidos.'",
  'Indica de uno a cuatro cambios válidos.', 'validación', 'impl.', 'sí',
  '«Los cambios no son válidos: indica de uno a cuatro.»')
m(G, F_CHG, "no está en el plan.'",
  '{Objeto} no está en el plan.', 'validación', 'sí', 'no', '«… Revisa el OR o el número.»')
m(G, F_CHG, "cambió; revisa la solicitud.'",
  'El origen de {objeto} cambió; revisa la solicitud.', 'validación', 'sí', 'sí')
m(G, F_CHG, "no existe en la geometría del buque.'",
  'La celda {BBBRRTT} no existe en la geometría del buque.', 'validación', 'sí', 'no',
  '«… Elige una celda de la geometría (BBB-RR-TT).»')
m(G, F_CHG, "no cabe en la bahía ${coordinate.bay}.'",
  '{Objeto} no cabe en la bahía {n}.', 'validación', 'sí', 'no',
  '«… Un 20 va en bahía impar y un 40 en par.»')
m(G, F_CHG, "PlanRole.transit => 'Es carga de paso: no se descarga aquí.'",
  '{destino} choca con {objeto} en {posición}[: un 40 ocupa las dos mitades de la celda.] Es carga de paso: no se '
  'descarga aquí.', 'validación', 'sí', 'no', '«… Elige otra celda.»')
m(G, F_CHG, "'La celda está ocupada a bordo; marca primero su descarga.'",
  '{destino} choca con {objeto} en {posición}[…] La celda está ocupada a bordo; marca primero su descarga.',
  'validación', 'sí', 'sí')
m(G, F_CHG, "'La celda está prevista para otro objeto; inclúyelo en el intercambio.'",
  '{destino} choca con {objeto} en {posición}[…] La celda está prevista para otro objeto; inclúyelo en el '
  'intercambio.', 'validación', 'sí', 'sí')
m(G, F_CHG, "'Un 20 y un 40 no se intercambian.'",
  '{destino} choca con {objeto} en {posición}[…] Un 20 y un 40 no se intercambian.', 'validación', 'sí', 'no',
  '«… Elige otra celda del mismo tamaño.»')
m(G, F_CHG, "'${destination.toIsoCode()} choca con $name en ${other.toIsoCode()}'",
  '{destino} choca con {objeto} en {posición}[: un 40 ocupa las dos mitades de la celda.] (sin segunda frase)',
  'validación', 'sí', 'no', '«… Elige otra celda.»')
m(G, F_CHG, "'La solicitud ya no está pendiente.'",
  'La solicitud ya no está pendiente.', 'rechazo', 'sí', 'no', '«… Otra cuenta ya la decidió; actualiza la bandeja.»')
m(G, _P + 'widgets/plan_drag_confirmation.dart', "'Para otra bahía utiliza el formulario.'",
  'Para otra bahía utiliza el formulario.', 'rechazo', 'impl.', 'sí',
  '«El arrastre solo mueve dentro de la bahía: para otra bahía utiliza el formulario.»')
m(G, (_P + 'widgets/plan_drag_confirmation.dart', _P + 'widgets/office_plan_controls.dart',
      _P + 'pages/change_requests_page.dart'), "throw StateError('La operación no está disponible.')",
  'La operación no está disponible.',
  'falla', 'no', 'no',
  '«La operación todavía no se cargó o cambió mientras tanto. Espera un momento e inténtalo de nuevo.»')

G = 'Registro de carga (diálogo Confirmar carga y revisión)'
m(G, F_LOP, "throw StateError('La escala no tiene operación guardada.')",
  'La escala no tiene operación guardada.', 'rechazo', 'sí', 'no',
  '«… Vuelve a abrir el plan de carga y confirma la escala.» (como dice ya el modo Descarga)')
m(G, F_LOP, "'El OR ya no está en el listado.'",
  'El OR ya no está en el listado.', 'rechazo', 'sí', 'no', '«… Importa de nuevo el listado de la agencia.»')
m(G, F_LOP, "'La corrección exige un movimiento vigente y un motivo.'",
  'La corrección exige un movimiento vigente y un motivo.', 'validación', 'sí', 'impl.',
  '«… Elige un movimiento vigente y escribe el motivo.»')
m(G, (F_LOP, F_LCK, _P + 'widgets/office_plan_controls.dart'), "'Cancelado por la oficina. Debe deshacer la cancelación antes de cargar.'",
  'Cancelado por la oficina. Debe deshacer la cancelación antes de cargar.', 'rechazo', 'sí', 'sí')
m(G, F_LOP, "'El contenedor ya está operado.'",
  'El contenedor ya está operado.', 'rechazo', 'sí', 'no', '«… Para cambiarlo, abre su detalle y usa Corregir o Deshacer.»')
m(G, F_LOP, "'Un vacío se asigna a una celda reservada del plan.'",
  'Un vacío se asigna a una celda reservada del plan.', 'validación', 'sí', 'impl.',
  '«… Elige una celda reservada.»')
m(G, F_LOP, "'La reserva está cancelada.'",
  'La reserva está cancelada.', 'rechazo', 'sí', 'no', '«… Elige otra reserva o pide a la oficina que deshaga la cancelación.»')
m(G, F_LOP, "que baja aquí: '",
  'La celda la ocupa {contenedor}, que baja aquí: marca primero su descarga.', 'validación', 'sí', 'sí')
m(G, F_LOP, "'Esta carga se registra solo con un motivo escrito.'",
  'Esta carga se registra solo con un motivo escrito.', 'validación', 'sí', 'impl.',
  '«… Escribe el motivo para registrarla.»')
m(G, F_LCK, "no tiene la forma BBB-RR-TT.')",
  '[No se registra:] La posición «{posición}» no tiene la forma BBB-RR-TT.', 'validación', 'sí', 'impl.',
  '«… Escríbela como BBB-RR-TT, por ejemplo 012-04-82.»')
m(G, F_LCK, "'Un contenedor de $length pies ($type) no cabe en $shown: la bahía '",
  'No se registra: Un contenedor de {n} pies ({tipo}) no cabe en {celda}: la bahía {b} es {impar, de 20|par, de 40} '
  'pies.', 'validación', 'sí', 'no', '«… Elige una celda de {20|40} pies.»')
m(G, F_LCK, "quedará «fuera de plan»'",
  'Pide motivo: OR {n} está planificado en {celda}; en {celda} quedará «fuera de plan»[, y {celda} es la celda de '
  '{objeto}].', 'aviso de datos', 'sí', 'impl.',
  '«… Para registrarlo ahí, escribe el motivo; si no, usa la celda planificada.»')
m(G, F_LCK, "es de otro grupo (${differences.join(', ')}); '",
  'Pide motivo: La reserva {celda} es de otro grupo ({diferencias}); el OR {n} es {tipo} · {POD} · {línea}.',
  'aviso de datos', 'sí', 'impl.',
  '«… Para registrarlo ahí, escribe el motivo; si no, elige una reserva de su grupo.»')
m(G, F_LCK, "'${plan.portOfCall}: la celda está ocupada.'",
  'Pide motivo: {celda} la ocupa {objeto}, que no baja en {escala}: la celda está ocupada.', 'aviso de datos',
  'sí', 'impl.', '«… Para registrarlo ahí, escribe el motivo; si no, elige otra celda.»')
m(G, F_LCK, "no existe en este buque: $shown no se puede registrar.'",
  'No se registra: La bahía {b} no existe en este buque: {celda} no se puede registrar.', 'validación', 'sí', 'no',
  '«… Revisa la celda.»')
m(G, F_LCK, "no existe en la geometría del buque (fila ${c.rowPadded}, '",
  'No se registra: {celda} no existe en la geometría del buque (fila {f}, nivel {n}).', 'validación', 'sí', 'no',
  '«… Revisa la celda o la geometría en Parámetros del buque.»')
m(G, F_LCK, "'$label: quedaría en $weight y el límite del perfil es '",
  'Pide motivo: {Pila de cubierta|bodega} {bahía}, fila {f}: quedaría en {x} t y el límite del perfil es {y} t[; '
  '{n} contenedores de la pila no traen peso, el peso real es mayor].', 'aviso de datos', 'sí', 'impl.',
  '«… Para registrarlo ahí, escribe el motivo; si no, elige otra pila.»')
m(G, _P + 'widgets/loading_controls.dart', "Text('Este contenedor no tiene OR en el listado de agencia.')",
  'Este contenedor no tiene OR en el listado de agencia.', 'rechazo', 'sí', 'no',
  '«… Importa el listado de la agencia actualizado.»')
m(G, _P + 'widgets/loading_controls.dart', "'Escribe la hora como HH:mm (00:00 a 23:59).'",
  'Escribe la hora como HH:mm (00:00 a 23:59).', 'validación', 'impl.', 'sí',
  '«Hora no válida: escríbela como HH:mm (00:00 a 23:59).»')

G = 'Descarga y tapas'
m(G, _P + 'widgets/discharge_controls.dart', "content: Text('Esta escala no tiene operación guardada: vuelve a '",
  'Esta escala no tiene operación guardada: vuelve a abrir el BAPLIE de llegada y confirma la escala.',
  'rechazo', 'sí', 'sí')
m(G, F_HAT, "'Una bahía sin bodega no puede declarar tapas.'",
  'Una bahía sin bodega no puede declarar tapas.', 'validación', 'sí', 'no', '«… Déjala «Sin declarar».»')
m(G, F_HAT, "'Una bodega abierta no lleva tapas.'",
  'Una bodega abierta no lleva tapas.', 'validación', 'sí', 'no', '«… Quita las filas de tapa.»')
m(G, F_HAT, "'Declara exactamente una tapa automática.'",
  'Declara exactamente una tapa automática.', 'validación', 'impl.', 'sí',
  '«Falta la tapa automática o hay más de una: declara exactamente una.»')
m(G, F_HAT, "'Declara de una a tres tapas de grúa.'",
  'Declara de una a tres tapas de grúa.', 'validación', 'impl.', 'sí',
  '«Faltan las tapas de grúa o hay más de tres: declara de una a tres.»')
m(G, F_HAT, "necesita al menos una fila.'",
  'La tapa {n} necesita al menos una fila.', 'validación', 'sí', 'impl.', '«… Escribe sus filas.»')
m(G, F_HAT, "'no pertenece a la geometría de bodega de esta bahía.'",
  'La fila {nn} de la tapa {n} no pertenece a la geometría de bodega de esta bahía.', 'validación', 'sí', 'no',
  '«… Usa filas de la geometría.»')
m(G, F_HAT, "se solapa entre tapas.'",
  'La fila {nn} se solapa entre tapas.', 'validación', 'sí', 'no', '«… Déjala en una sola tapa.»')
m(G, _P + 'pages/hatch_covers_page.dart', "escribe filas de uno o dos dígitos separadas por coma.'",
  'Tapa {n}: escribe filas de uno o dos dígitos separadas por coma.', 'validación', 'impl.', 'sí',
  '«Tapa {n}: las filas no tienen el formato esperado; escribe filas de uno o dos dígitos separadas por coma.»')
m(G, _P + 'pages/hatch_covers_page.dart', "hay una fila repetida.'",
  'Tapa {n}: hay una fila repetida.', 'validación', 'sí', 'no', '«… Quita la repetida.»')

G = 'Listado de la agencia'
m(G, F_ELP, "'El archivo está vacío o no se pudo leer.'",
  'El archivo está vacío o no se pudo leer.', 'falla', 'sí', 'no',
  '«… Vuelve a elegir el Excel (.xlsx) de la agencia.»')
m(G, F_ELP, "'Abre primero el plan de carga y confirma la escala.'",
  'Abre primero el plan de carga y confirma la escala.', 'rechazo', 'impl.', 'sí',
  '«No hay un plan de carga confirmado: abre primero el plan de carga y confirma la escala.»')
m(G, _P + 'pages/export_list_import_page.dart', "'Abre primero el plan de carga (BAPLIE) y confirma la escala.'",
  'Abre primero el plan de carga (BAPLIE) y confirma la escala.', 'rechazo', 'impl.', 'sí',
  '«No hay un plan de carga confirmado: abre primero el plan de carga (BAPLIE) y confirma la escala.»')
m(G, F_ELP, "'No hay un listado leído para importar.'",
  'No hay un listado leído para importar.', 'rechazo', 'sí', 'impl.', '«… Elige primero el Excel de la agencia.»')
m(G, F_ELP, "'Falta elegir equivalencias: ",
  'Falta elegir equivalencias: {códigos}.', 'validación', 'sí', 'impl.',
  '«… Elige una para cada código antes de importar.»')
m(G, F_ELP, "return 'Hay una operación en curso.'",
  'Hay una operación en curso.', 'rechazo', 'sí', 'no', '«… Espera a que termine.»')
m(G, _P + 'pages/export_list_import_page.dart', "'equivalencias antes de importar.'",
  'Falta elegir {n} equivalencias antes de importar.', 'validación', 'sí', 'impl.',
  '«… Elige una para cada código pendiente.»')
m(G, _DA + 'repositories/export_list_repository_impl.dart', "'No se pudo leer el listado. Revisa que sea el Excel de la agencia.'",
  'No se pudo leer el listado. Revisa que sea el Excel de la agencia.', 'falla', 'impl.', 'sí',
  'Sale del catch general (error inesperado): si el motivo no se conoce, no hay causa que agregar; basta la '
  'acción. El motivo técnico queda en el registro.')
m(G, F_ELS, "'El archivo no es un libro de Excel (.xlsx) legible.'",
  'El archivo no es un libro de Excel (.xlsx) legible.', 'falla', 'sí', 'no',
  '«… Guárdalo como .xlsx desde Excel y vuelve a elegirlo.»', parseo='Excel')
m(G, F_ELS, "'El libro no tiene hojas con datos.'",
  'El libro no tiene hojas con datos.', 'falla', 'sí', 'no', '«… Elige el listado de la agencia.»', parseo='Excel')
m(G, F_ELS, "'No se encontró la fila de encabezados del listado '",
  'No se encontró la fila de encabezados del listado (OR, CONTENEDOR, TIPO…).', 'falla', 'sí', 'no',
  '«… Revisa que sea el listado de exportación de la agencia.»', parseo='Excel')
m(G, F_ELS, "'Al listado le faltan columnas: ",
  'Al listado le faltan columnas: {columnas}.', 'falla', 'sí', 'no',
  '«… Pide a la agencia el listado completo.»', parseo='Excel')
m(G, F_ELS, "'OR $order: ${problems.join('; ')}.'",
  'Fila {n}: OR {orden}: {falta el número de contenedor; el contenedor «x» no tiene la forma ISO 6346 …; marca '
  'lleno (F) y vacío (E) a la vez; …}.', 'aviso de datos', 'sí', 'no',
  '«… Corrige esas filas en el Excel y vuelve a importarlo.»', parseo='Excel')
m(G, F_ELS, "'No es un contenedor ni un separador de agencia: ",
  'Fila {n}: No es un contenedor ni un separador de agencia: «{texto}».', 'aviso de datos', 'sí', 'no',
  '«… Revisa esa fila del Excel.»', parseo='Excel')

G = 'BAPLIE de salida'
m(G, F_DBW, "'La operación no tiene una fuente loading_baplie. '",
  'La operación no tiene una fuente loading_baplie. Importa el plan de carga antes de generar la salida.',
  'rechazo', 'sí', 'sí', 'Sin el identificador: «La operación no tiene el plan de carga (BAPLIE). Impórtalo …».')
m(G, F_DBW, "'No está disponible el plan efectivo de la operación.'",
  'No está disponible el plan efectivo de la operación.', 'falla', 'sí', 'no',
  '«… Espera a que cargue la operación e inténtalo de nuevo.»')
m(G, F_DBW, "'Hay ocupantes duplicados en el estado derivado; '",
  'Hay ocupantes duplicados en el estado derivado; resuelve el conflicto antes de generar.', 'conflicto', 'sí', 'sí')
m(G, F_DBW, "'Falta la fuente del ocupante $container; '",
  'Falta la fuente del ocupante {contenedor}; no se puede conservar su información.', 'falla', 'sí', 'no',
  '«… Vuelve a importar el plano de llegada y el plan de carga.»')
m(G, F_DBW, "'El contenedor cargado $container no está en el '",
  'El contenedor cargado {contenedor} no está en el listado; faltan sus datos exactos.', 'falla', 'sí', 'no',
  '«… Importa el listado que lo incluye.»')
m(G, F_DBW, "'El listado contiene un peso inválido.'",
  'El listado contiene un peso inválido.', 'aviso de datos', 'sí', 'no', '«… Corrige los pesos en el Excel y vuelve a importarlo.»')
m(G, F_DBW, "'El listado no declara lleno/vacío para ${row.containerId}.'",
  'El listado no declara lleno/vacío para {contenedor}.', 'aviso de datos', 'sí', 'no',
  '«… Corrige esa fila en el Excel y vuelve a importarlo.»')
m(G, F_DBW, "'El listado no declara el VGM de ${row.containerId}.'",
  'El listado no declara el VGM de {contenedor}.', 'aviso de datos', 'sí', 'no',
  '«… Pide el VGM a la agencia e impórtalo de nuevo.»')
m(G, F_DBW, "'La fuente debe contener un único mensaje BAPLIE con UNB y UNH.'",
  'La fuente debe contener un único mensaje BAPLIE con UNB y UNH.', 'falla', 'sí', 'no',
  '«… Vuelve a importar el plan de carga.»', parseo='sí', segmento='sí')
m(G, F_DBW, "'Versión BAPLIE no reconocida para salida 2.x: '",
  'Versión BAPLIE no reconocida para salida 2.x: {identificador|sin cabecera}. No se generó el archivo.',
  'falla', 'sí', 'no', '«… (cabecera UNH) … Importa el plan en SMDG20, SMDG21 o SMDG22.»', parseo='sí', segmento='no')
m(G, F_DBW, "'Separadores EDIFACT no reconocidos para generar la salida.'",
  'Separadores EDIFACT no reconocidos para generar la salida.', 'falla', 'sí', 'no',
  '«Separadores EDIFACT no reconocidos en el segmento UNA … Pide una exportación con los separadores estándar.»',
  parseo='sí', segmento='no')
m(G, F_DBP, "'No se genera el BAPLIE de salida: '",
  'No se genera el BAPLIE de salida: «{archivo}» es versión 1.5 (SMDG15) y se leyó con las reglas de 2.x. Escribir '
  'la salida con esas reglas no sería fiel a lo que llegó. Importa el plano en SMDG20, SMDG21 o SMDG22.',
  'rechazo', 'sí', 'sí')
m(G, F_DBP, "'La escala no tiene una operación guardada con fuente loading_baplie.'",
  'La escala no tiene una operación guardada con fuente loading_baplie.', 'rechazo', 'sí', 'no',
  '«La escala no tiene una operación guardada con su plan de carga. Abre el plan de carga (BAPLIE) y confirma la '
  'escala.»')
m(G, F_DBP, "'La operación se está actualizando. Intenta de nuevo.'",
  'La operación se está actualizando. Intenta de nuevo.', 'falla', 'sí', 'sí')

G = 'Comparar BAPLIE'
m(G, _D + 'services/voyage_comparison.dart', "'No se puede confirmar que sea el mismo buque: $how. '",
  'No se puede confirmar que sea el mismo buque: {motivo}. Confirma que es el mismo buque antes de usar la '
  'comparación.', 'aviso de datos', 'sí', 'sí')
m(G, _D + 'services/voyage_comparison.dart', "'No parece el mismo buque: ${first.name} '",
  'No parece el mismo buque: {nombre} ({clave}) y {nombre} ({clave}).', 'aviso de datos', 'sí', 'no',
  '«… Revisa que el segundo archivo sea del mismo buque.»')

G = 'Parámetros del buque (validación del formulario y de las tomas)'
m(G, F_GEO, "return 'Escribe un número.'",
  'Escribe un número.', 'validación', 'impl.', 'sí', '«Valor no numérico: escribe un número.»')
m(G, F_GEO, "'No puede ser menor que $minimum.'",
  'No puede ser menor que {mínimo}.', 'validación', 'sí', 'impl.', '«… Escribe {mínimo} o más.»')
m(G, F_GEO, "'El archivo trae carga en $observed; con $value $unit '",
  'El archivo trae carga en {la fila nn}; con {v} {filas a babor|estribor} quedaría fuera del plano.',
  'validación', 'sí', 'impl.', '«… Aumenta las filas a {babor|estribor} hasta incluirla.»')
m(G, F_GEO, "'Escribe el límite o marca que no lo tienes.'",
  'Escribe el límite o marca que no lo tienes.', 'validación', 'impl.', 'sí',
  '«Falta el límite de apilamiento: escríbelo o marca que no lo tienes.»')
m(G, F_GEO, "'Escribe siete dígitos y una bahía distinta de 000.'",
  'Escribe siete dígitos y una bahía distinta de 000.', 'validación', 'impl.', 'sí',
  '«Posición de toma no válida: escribe siete dígitos y una bahía distinta de 000.»')
m(G, F_GEO, "'Revisa la frontera y las anclas antes de cargar tomas.'",
  'Revisa la frontera y las anclas antes de cargar tomas.', 'validación', 'impl.', 'sí',
  '«La frontera y las anclas no forman una geometría válida: revísalas antes de cargar tomas.»')
m(G, F_GEO, "'Pega al menos un código.'",
  'Pega al menos un código.', 'validación', 'impl.', 'sí', '«No hay códigos pegados: pega al menos uno.»')
m(G, F_GEO, "'Revisa frontera y anclas: bodega debajo de la frontera y cubierta desde ella.'",
  'Revisa frontera y anclas: bodega debajo de la frontera y cubierta desde ella.', 'validación', 'sí', 'sí')
m(G, F_GEO, "'Falta resolver el límite de apilamiento.'",
  'Falta resolver el límite de apilamiento.', 'validación', 'sí', 'impl.',
  '«… Escribe el límite o marca que no lo tienes.»')
m(G, F_RSR, "no es un número ni un rango como 02-08.'",
  '{Bahías|Filas|Niveles}: «{x}» no es un número ni un rango como 02-08.', 'validación', 'sí', 'impl.',
  '«… Escribe un número o un rango como 02-08.»')
m(G, F_RSR, "sale de ${_pad(min, max)} a ${_pad(max, max)}.'",
  '{campo}: «{x}» sale de {mín} a {máx}.', 'validación', 'sí', 'impl.', '«… Escribe valores entre {mín} y {máx}.»')
m(G, F_RSR, "el final es menor que el inicio.'",
  '{campo}: en «{x}» el final es menor que el inicio.', 'validación', 'sí', 'no', '«… Escribe el inicio primero.»')
m(G, F_RSR, "el paso tiene que ser 1 o más.'",
  '{campo}: en «{x}» el paso tiene que ser 1 o más.', 'validación', 'sí', 'impl.',
  '«… Escribe un paso de 1 o más, como 002-038/4.»')
m(G, F_RSR, "error: 'Escribe al menos una bahía.'",
  'Escribe al menos una bahía.', 'validación', 'impl.', 'sí', '«Faltan las bahías: escribe al menos una.»')
m(G, F_RSR, "error: 'Escribe al menos un nivel.'",
  'Escribe al menos un nivel.', 'validación', 'impl.', 'sí', '«Faltan los niveles: escribe al menos uno.»')
m(G, F_RSR, "'Acótalo.'",
  'El rango genera {n} códigos; el máximo es {m}. Acótalo.', 'validación', 'sí', 'sí')

G = 'Búsqueda por voz'
for frag, texto in (
        ('Permiso de micrófono denegado. Puedes escribir la búsqueda.', 'Permiso de micrófono denegado. Puedes escribir la búsqueda.'),
        ('Reconocimiento sin conexión o servicio no disponible.', 'Reconocimiento sin conexión o servicio no disponible. Puedes escribir la búsqueda.'),
        ('No se entendió el dictado. Reintenta o escribe la búsqueda.', 'No se entendió el dictado. Reintenta o escribe la búsqueda.'),
        ('Reconocimiento en español no disponible.', 'Reconocimiento en español no disponible. Puedes escribir la búsqueda.'),
        ('Reconocimiento de voz no disponible. Puedes escribir la búsqueda.', 'Reconocimiento de voz no disponible. Puedes escribir la búsqueda.')):
    m(G, _P + 'widgets/voice_search_field.dart', frag, texto, 'falla', 'sí', 'sí')

G = 'Avisos de lectura del BAPLIE (tarjeta del viaje y Comparar)'
m(G, F_CAR, "'Versión 1.5, leída con las reglas de 2.x; revisa pesos y peligrosas'",
  'Versión 1.5, leída con las reglas de 2.x; revisa pesos y peligrosas', 'aviso de datos', 'sí', 'sí',
  '«… (la cabecera UNH declara BAPLIE:1:911:UN:SMDG15) …».', parseo='sí', segmento='no')
m(G, F_CAR, "BaplieReadNoticeKind.weight => 'Pesos revisados'",
  'Pesos revisados: {n} contenedores · detalle: «{número}: WT en LBR convertido a {x} kg», «… sin unidad; se tomó '
  'como kg», «… con unidad desconocida {u}; sin ese peso»', 'aviso de datos', 'sí', 'no',
  '«Pesos revisados en MEA: {n} contenedores · revisa sus pesos antes de operar.»', parseo='sí', segmento='no')
m(G, F_CAR, "BaplieReadNoticeKind.position => 'Posiciones mal formadas'",
  'Posiciones mal formadas: {n} contenedores · detalle: «{número}: {posición}»', 'aviso de datos', 'sí', 'no',
  '«Posiciones mal formadas en LOC+147: {n} contenedores · pide una exportación corregida.»', parseo='sí',
  segmento='no')
m(G, F_CAR, "BaplieReadNoticeKind.checkDigit => 'Dígito de control inválido'",
  'Dígito de control inválido: {n} contenedores · detalle: «{número}»', 'aviso de datos', 'sí', 'no',
  '«Dígito de control inválido en EQD: {n} contenedores · revisa esos números con la agencia.»', parseo='sí',
  segmento='no')
m(G, F_CAR, "BaplieReadNoticeKind.incomplete => 'Archivo posiblemente incompleto'",
  'Archivo posiblemente incompleto: faltan {n} segmentos ({UNB, BGM, UNT, UNZ}) · detalle: «El archivo puede venir '
  'incompleto. Revisa los segmentos que faltan:»', 'aviso de datos', 'sí', 'sí', parseo='sí', segmento='sí')

G = 'Rejilla y geometría (Bay Plan y Orden de descarga)'
m(G, _P + 'widgets/bay_plan_view.dart', "'No se dibujan en la rejilla porque su posición no existe en '",
  '{n} contenedores fuera de la geometría declarada · No se dibujan en la rejilla porque su posición no existe en '
  'el buque declarado: {posiciones}.', 'aviso de datos', 'sí', 'no',
  '«… Amplía la geometría en Parámetros del buque.»')
m(G, _P + 'widgets/bay_plan_view.dart', "celdas reservadas fuera de la geometría declarada: '",
  '{n} celdas reservadas fuera de la geometría declarada: {posiciones}[ y {n} más].', 'aviso de datos', 'sí', 'no',
  '«… Amplía la geometría en Parámetros del buque.»')
m(G, _P + 'widgets/bay_plan_view.dart', "'Este viaje no trae la geometría del buque declarada, así que no '",
  'Este viaje no trae la geometría del buque declarada, así que no hay rejilla contra la cual dibujarlo. Declara '
  'los parámetros del buque para ver el plano.', 'aviso de datos', 'sí', 'sí')
m(G, _P + 'pages/discharge_sequence_page.dart', "'Confirma la geometría del buque para sugerir el orden de descarga.'",
  'Confirma la geometría del buque para sugerir el orden de descarga.', 'rechazo', 'impl.', 'sí',
  '«La geometría del buque está sin confirmar: confírmala para sugerir el orden de descarga.»')
m(G, _P + 'pages/discharge_sequence_page.dart', "'El archivo no trae puertos de descarga.'",
  'El archivo no trae puertos de descarga.', 'aviso de datos', 'sí', 'no',
  '«… (LOC+11): no hay orden que sugerir.» (no hay acción posible en la app)')

G = 'Conflictos de la operación (detalle de la celda, Avance, Tapas en la operación)'
_ACC_CONF = '«… Si el registro fue un error, anúlalo con Deshacer.»'
for frag, texto, accion in (
        ("problem(m, 'Solicitud con cambios inválidos.')", 'Solicitud con cambios inválidos.', 'no'),
        ("'La decisión cita una solicitud que no está vigente.'", 'La decisión cita una solicitud que no está vigente.', 'no'),
        ("'La solicitud ya tiene una decisión o está en conflicto.'", 'La solicitud ya tiene una decisión o está en conflicto.', 'no'),
        ("'El rechazo no cita una solicitud.'", 'El rechazo no cita una solicitud.', 'no'),
        ("'El cambio no contiene de uno a cuatro cambios válidos.'", 'El cambio no contiene de uno a cuatro cambios válidos.', 'no'),
        ("'La aprobación no coincide con lo solicitado.'", 'La aprobación no coincide con lo solicitado.', 'no'),
        ("no está en el plan de carga.'", '{Objeto} no está en el plan de carga.', 'no'),
        ("origen obsoleto; plan efectivo", '{Objeto}: origen obsoleto; plan efectivo {p}, cambio desde {p}.', 'no'),
        ("está prevista para otro objeto del plan.'", '{celda} está prevista para otro objeto del plan.', 'no'),
        ("tapa sin declarar o acción inválida.'", '{tapa}: tapa sin declarar o acción inválida.', 'no'),
        ("'ya está quitada'", 'Bahía {b} · {tapa}: {ya está quitada|no está quitada para reponerla}.', 'no'),
        ("no está en el plano de llegada de esta escala.'", '{Objeto} no está en el plano de llegada de esta escala.', 'no'),
        ("está cancelado y se descargó.'", '{Objeto} está cancelado y se descargó.', 'no'),
        ("si sale para volver a subir, es una re", '{Objeto} no descarga en {escala}; si sale para volver a subir, es una re‑estiba.', 'impl.'),
        ("ya la ocupa ${_occupant(taken)}.'", '{celda} ya la ocupa {objeto}. (tres reglas: descarga, carga y vacío)', 'no'),
        ("no está en el plan de carga de ${plan.portOfCall}.'", '{Objeto} no está en el plan de carga de {escala}.', 'no'),
        ("está cancelado y se cargó.'", '{Objeto} está cancelado y se cargó.', 'no'),
        ("no se carga en ${plan.portOfCall}.'", '{Objeto} no se carga en {escala}.', 'no'),
        ("ya se cargó en ${status.position}.'", '{Objeto} ya se cargó en {posición}.', 'no'),
        ("planificado en ${status.plannedPosition}, registrado en $position.'", '{Objeto}: planificado en {p}, registrado en {p}.', 'no'),
        ("no es una celda reservada del plan.'", '{Objeto} no es una celda reservada del plan.', 'no'),
        ("está cancelada y se asignó.'", '{Objeto} está cancelada y se asignó.', 'no'),
        ("ya tiene asignado ${status.assignedContainer}.'", '{Objeto} ya tiene asignado {contenedor}.', 'no'),
        ("ya está en ${_shown(elsewhere)}.'", '{contenedor} ya está en {objeto}.', 'no'),
        ("quedó en una '", '{contenedor} ({tipo} · {POD} · {línea}) quedó en una reserva de {tipo} · {POD} · {línea}.', 'no'),
        ("no está en el plan de esta escala.'", '{Objeto} no está en el plan de esta escala.', 'no'),
        ("ya se movió; para cancelarlo, anula antes ese movimiento.'", '{Objeto} ya se movió; para cancelarlo, anula antes ese movimiento.', 'sí')):
    m(G, F_OSD, frag, texto, 'conflicto', 'sí', accion, '' if accion == 'sí' else _ACC_CONF)

G = 'Texto no controlado: toString() de la excepción'
for archivo, frag in (
        ((_P + 'widgets/plan_drag_confirmation.dart', _P + 'widgets/loading_controls.dart',
          _P + 'widgets/office_plan_controls.dart', _P + 'pages/change_requests_page.dart'),
         "error = failure is StateError ? failure.message : '$failure'"),):
    m(G, archivo, frag,
      "'$failure' cuando el error no es StateError: el toString() de Dart o del paquete (p. ej. «HiveError: …», "
      "«FileSystemException: …», o el nombre de la clase de un Failure en release)",
      'no controlado', 'no', 'no', 'Mostrar vesselErrorMessage(failure, stack), como el resto de la app.')
m(G, _P + 'widgets/hatch_operation_controls.dart', "error: (error, _) => Center(child: Text('$error'))",
  "Text('$error') en el estado de error de Tapas en la operación: «Instance of 'VesselOperationFailure'», "
  "«CacheFailure» (release), «Bad state: …», «FormatException: …»", 'no controlado', 'no', 'no',
  'Text(vesselErrorMessage(error, stack)), como Avance de la operación y las demás pantallas.')

# Envolturas: muestran un mensaje de la tabla sin cambiarlo o con un prefijo
# que no agrega causa ni acción. No suman filas.
ENVOLTURAS = [
    (F_OVR, "'Error al procesar archivo'", 'título del estado de error + vesselErrorMessage y botón «Intentar de nuevo»'),
    (F_OVR, 'result.errorMessage ?? unknownVesselErrorMessage', 'SnackBar con el LoadFileResult.error'),
    (F_OVR, 'SnackBar(content: Text(vesselErrorMessage(error, stack))))', 'plantilla del buque: vesselErrorMessage'),
    (F_OVR, 'content: Text(error),', 'error de confirmGeometry (vessel_providers)'),
    (F_VPR, "'Archivo «${file.name}»: $notBaplieFileMessage'", 'prefijo con el nombre del archivo'),
    (F_VPR, "'Archivo «$fileName»: ${vesselFailureMessage(failure)}'", 'prefijo con el nombre del archivo'),
    (_P + 'pages/recent_voyages_page.dart', 'Text(vesselErrorMessage(error)),', 'estado de error + «Reintentar»'),
    (_P + 'pages/vessel_profiles_page.dart', 'Text(vesselErrorMessage(error)),', 'estado de error + «Reintentar»'),
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
    (_P + 'pages/voyage_comparison_page.dart', "notice('Archivo «${file.name}»: ${vesselFailureMessage(failure)}')", 'prefijo con el nombre del archivo'),
    (_P + 'pages/voyage_comparison_page.dart', 'notice(vesselErrorMessage(error, stack))', 'vesselErrorMessage'),
    (F_DBP, "_notice(error is StateError", 'StateError del escritor o vesselErrorMessage'),
    (F_DBP, '_notice(vesselFailureMessage(failure));', 'vesselFailureMessage'),
    (F_CLD, 'error = vesselErrorMessage(failure, stack);', '_run: vesselErrorMessage'),
    (F_CLD, 'rejectionText(error)', '_run: el texto de la falla sin puntos repetidos'),
    (F_ELP, 'error: e.failure.message', 'mensaje de la lectura del listado'),
    (_P + 'pages/change_requests_page.dart', 'const ChangeRequests().review(data, batch)!', 'error de la revisión del cambio'),
    (_P + 'widgets/plan_drag_confirmation.dart', '.showSnackBar(SnackBar(content: Text(result.error!)));', 'error de la revisión del arrastre'),
    (_P + 'widgets/loading_controls.dart', "issue.blocks ? 'No se registra' : 'Pide motivo'", 'prefijo de la revisión de carga'),
]


def ubicar(root, archivo, fragmento):
    """Líneas del archivo donde aparece el fragmento (en una sola línea o
    partido entre dos líneas consecutivas)."""
    lineas = (root / archivo).read_text(encoding='utf-8-sig').split('\n')
    encontradas = []
    for i, linea in enumerate(lineas):
        if fragmento in linea:
            encontradas.append(i + 1)
    if encontradas:
        return encontradas
    plano = ' '.join(l.strip() for l in lineas)
    if fragmento in plano:
        # el fragmento cruza líneas: se informa la línea donde empieza
        acumulado = 0
        for i, linea in enumerate(lineas):
            acumulado += len(linea.strip()) + 1
            if acumulado > plano.index(fragmento):
                return [i + 1]
    return []


def censo(root):
    filas = []
    for k, fila in enumerate(M, 1):
        archivos = fila['archivo'] if isinstance(fila['archivo'], tuple) else (fila['archivo'],)
        sitios = []
        for archivo in archivos:
            lineas = ubicar(root, archivo, fila['fragmento'])
            if not lineas:
                raise SystemExit(f'Fragmento no encontrado: {archivo} · {fila["fragmento"]}')
            sitios.append((archivo, lineas))
        completo = fila['causa'] == fila['accion'] == 'sí' and fila['segmento'] != 'no'
        if not completo and not fila['arreglo']:
            raise SystemExit(f'Falta el arreglo sugerido: {fila["texto"]}')
        filas.append(dict(fila, id=f'M{k:03d}', sitios=sitios))
    envolturas = []
    for archivo, fragmento, motivo in ENVOLTURAS:
        lineas = ubicar(root, archivo, fragmento)
        if not lineas:
            raise SystemExit(f'Envoltura no encontrada: {archivo} · {fragmento}')
        envolturas.append({'archivo': archivo, 'lineas': lineas, 'motivo': motivo})
    return filas, envolturas
