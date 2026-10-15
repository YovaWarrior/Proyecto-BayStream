/// T-88 · La política de privacidad de BayStream: fuente única del texto.
///
/// De aquí salen la pantalla «Política de privacidad» y `web/privacidad.html`
/// (`tool/t88_privacidad.dart`). El texto es el de la ficha de T-88 en
/// `SPRINT-3.md`, palabra por palabra, con la corrección de 10.46. Si una
/// frase deja de ser cierta frente al código, no se arregla aquí por cuenta
/// propia: se reporta y la corrige Yov.
///
/// Dart puro, sin Flutter: lo leen la app, la herramienta y las pruebas.
/// Dentro de cada texto, `**negrita**` y `` `ruta` `` son las únicas marcas.
library;

/// D2 · Correo de contacto. Es público por definición: sale en la política y
/// en la ficha de Play. Es la única dirección de correo autorizada en el
/// repositorio (10.44).
const String kPrivacyContactEmail = 'giovannimartinezcrl2002@gmail.com';

const String kPrivacyPolicyTitle = 'Política de privacidad de BayStream';

const String kPrivacyPolicyUpdated =
    'Última actualización: 15 de octubre de 2026';

/// Una sección: su título en negrita, sus párrafos y, si los tiene, sus
/// puntos en lista.
class PrivacyPolicySection {
  final String title;
  final List<String> paragraphs;
  final List<String> items;

  const PrivacyPolicySection(this.title, this.paragraphs,
      [this.items = const []]);
}

const List<PrivacyPolicySection> kPrivacyPolicySections = [
  PrivacyPolicySection('Quién la publica.', [
    ('BayStream es una aplicación para ver y operar el plano de estiba de un '
        'buque portacontenedores. La desarrolla Carlos Giovanni Martínez '
        'Aldana, en Puerto Barrios, Guatemala, como proyecto de graduación de '
        'Ingeniería en Sistemas. Esta política explica qué datos usa la '
        'aplicación en Android, Windows y la Web, dónde quedan y qué decides '
        'tú.'),
  ]),
  PrivacyPolicySection('Sin cuenta, todo se queda en tu dispositivo.', [
    ('Puedes usar BayStream sin iniciar sesión. Así, los archivos que abres y '
        'lo que haces con ellos se procesan y se guardan solo en tu '
        'dispositivo, y la aplicación no los envía a ningún servidor.'),
  ]),
  PrivacyPolicySection('Los archivos que abres.', [
    ('La aplicación lee los archivos que tú eliges: planos BAPLIE y listados '
        'de exportación en Excel. Contienen información comercial del buque, '
        'del viaje y de la carga, como números de contenedor, puertos, pesos, '
        'refrigerados y mercancías peligrosas. No están pensados para contener '
        'datos personales.'),
  ]),
  PrivacyPolicySection('Con cuenta, la operación se sincroniza.', [
    ('Las cuentas las crea el administrador de BayStream para el personal de '
        'una operación portuaria: la aplicación no permite crearlas por tu '
        'cuenta.'),
  ], [
    ('**Tu cuenta.** Tu correo y tu contraseña los gestiona Firebase '
        'Authentication, de Google. BayStream no guarda tu contraseña. El '
        'administrador registra además tu nombre, tu rol (muelle u oficina) y '
        'si la cuenta está activa.'),
    ('**Lo que se envía a la nube.** Al publicar una operación, o al unirte a '
        'ella, se guardan en Cloud Firestore, de Google: los archivos de la '
        'operación, el perfil del buque y cada movimiento que registras, como '
        'descargas, cargas, re-estibas, tapas, solicitudes y aprobaciones. Cada '
        'movimiento lleva tu nombre, tu rol, la hora y un identificador '
        'aleatorio de la instalación de la aplicación, que no identifica tu '
        'teléfono ni tu computadora.'),
    ('**Quién lo ve.** Solo las cuentas autorizadas de BayStream, según su '
        'rol, y el administrador. Las reglas de la base de datos lo exigen.'),
    ('**Dónde se guarda.** Los datos de la operación, en la región de Firebase '
        'en México (northamerica-south1); los de la cuenta, en Firebase '
        'Authentication. Las conexiones van cifradas.'),
    ('**Sin conexión.** Los movimientos esperan en tu dispositivo y se envían '
        'cuando vuelve la red.'),
  ]),
  PrivacyPolicySection('El micrófono, solo si lo usas.', [
    ('La búsqueda de contenedores se puede dictar. El micrófono se pide '
        'únicamente cuando pulsas su botón, y puedes negarlo: escribir la '
        'búsqueda siempre funciona. El dictado lo hace el servicio de '
        'reconocimiento de voz de tu sistema, en Android, o de tu navegador, en '
        'la Web. Ese servicio puede enviar el audio a los servidores de su '
        'proveedor, como Google, según la política de ese proveedor. BayStream '
        'no graba ni guarda el audio, y el texto reconocido solo llena el campo '
        'de búsqueda: no se guarda ni se envía. En Windows no hay dictado.'),
  ]),
  PrivacyPolicySection('Lo que se guarda en tu dispositivo.', [
    ('Los viajes recientes, los perfiles de buque, la operación con su cola de '
        'movimientos, los datos de tu cuenta y tu preferencia de tema se '
        'guardan en tu dispositivo: en Android, en el almacenamiento privado de '
        'la aplicación; en Windows, en la carpeta de datos de tu usuario; en la '
        'Web, en el almacenamiento del navegador para el sitio de BayStream. '
        'Firebase guarda además tu sesión, para no pedirte la contraseña cada '
        'vez, y en Android y en Windows, una copia de la operación para '
        'trabajar sin conexión.'),
  ], [
    ('En Android, estos datos no entran en la copia de seguridad de Google ni '
        'pasan a otro teléfono en una transferencia.'),
    'Puedes borrar un viaje desde Recientes.',
    ('En Android, lo demás se borra al desinstalar la aplicación o al borrar '
        'sus datos desde los ajustes; en la Web, al borrar los datos del sitio '
        'en el navegador.'),
    // 10.46 · Las dos rutas se verificaron en Windows sin abrir su contenido:
    // la caché de Firestore vive en `firestore\[DEFAULT]\<proyecto>`.
    ('En Windows, desinstalar puede dejar en tu carpeta de usuario los datos '
        'de BayStream y la copia de Firebase. Para quitarlos, cierra sesión '
        'antes de desinstalar y borra la carpeta `AppData\\Local\\BayStream` y '
        'la de BayStream dentro de `AppData\\Local\\firestore\\[DEFAULT]`.'),
    'Cerrar sesión quita tu sesión del dispositivo.',
  ]),
  PrivacyPolicySection('Exportar.', [
    ('Cuando exportas un reporte (PDF, CSV o JSON) o el BAPLIE de salida, el '
        'archivo se guarda: en Android y en Windows, donde tú decides con el '
        'selector de archivos del sistema; en la Web, como una descarga del '
        'navegador. Lo que hagas con él después queda fuera de BayStream.'),
  ]),
  PrivacyPolicySection('La Web.', [
    ('La versión Web se sirve desde el sitio de BayStream en Firebase Hosting, '
        'de Google, incluidos el motor de dibujo, las fuentes y el SDK de '
        'Firebase: no carga código de otros sitios. Como cualquier servidor '
        'web, el alojamiento puede registrar datos técnicos de cada conexión, '
        'como la dirección IP.'),
  ]),
  PrivacyPolicySection('Lo que BayStream no hace.', [
    ('No muestra anuncios, no usa herramientas de analítica ni de seguimiento, '
        'y no vende ni cede tus datos. Las bibliotecas de Firebase envían con '
        'cada petición el nombre y la versión de la plataforma, como lo '
        'describe Google.'),
  ]),
  PrivacyPolicySection('Cuánto tiempo se guardan.', [
    ('Los datos de una operación se conservan en la nube mientras el '
        'administrador la mantenga. Los movimientos registrados conservan el '
        'nombre con que se firmaron, porque son el registro de la operación. '
        'Si dejas de trabajar con BayStream, puedes pedir que se borre tu '
        'cuenta.'),
  ]),
  PrivacyPolicySection('Menores.', [
    ('BayStream es una herramienta de trabajo para adultos y no está dirigida '
        'a menores de 18 años.'),
  ]),
  PrivacyPolicySection('Cambios.', [
    ('Si esta política cambia, la nueva versión se publica en la aplicación y '
        'en el sitio, con su fecha.'),
  ]),
  PrivacyPolicySection('Contacto.', [
    ('Para preguntas sobre esta política, o para pedir que se borre tu cuenta, '
        'escribe a $kPrivacyContactEmail.'),
  ]),
];

/// Un tramo de texto con su marca.
class PrivacyRun {
  final String text;
  final bool bold;
  final bool code;
  const PrivacyRun(this.text, {this.bold = false, this.code = false});
}

/// Parte un texto de la política en tramos según `**…**` y `` `…` ``.
List<PrivacyRun> privacyRuns(String text) {
  final runs = <PrivacyRun>[];
  final marks = RegExp(r'\*\*(.+?)\*\*|`(.+?)`');
  var start = 0;
  for (final match in marks.allMatches(text)) {
    if (match.start > start) runs.add(PrivacyRun(text.substring(start, match.start)));
    runs.add(match.group(1) != null
        ? PrivacyRun(match.group(1)!, bold: true)
        : PrivacyRun(match.group(2)!, code: true));
    start = match.end;
  }
  if (start < text.length) runs.add(PrivacyRun(text.substring(start)));
  return runs;
}

/// El texto sin marcas, como se lee en pantalla.
String privacyPlainText(String text) =>
    privacyRuns(text).map((run) => run.text).join();
