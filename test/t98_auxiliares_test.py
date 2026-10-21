"""Autopruebas de instrumentos sin Flutter ni clientes reales."""
import importlib.util
from pathlib import Path
import sys
import tempfile
import unittest

TOOLS = Path(__file__).resolve().parents[1] / 'tool'
sys.path.insert(0, str(TOOLS))


def load(name):
    spec = importlib.util.spec_from_file_location(name, TOOLS / f'{name}.py')
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


inventory = load('t98_inventario')
sanitizer = load('t98_sanitizar')
video = load('t98_video')
prepare = load('t98_preparar')
tls = load('t98_tls')


class Instruments(unittest.TestCase):
    def test_tls_11_clienthello_and_version_cap(self):
        import ssl
        ctx = tls.context('TLSv1.1')
        self.assertEqual(ctx.maximum_version, ssl.TLSVersion.TLSv1_1)
        self.assertEqual(ctx.minimum_version, ssl.TLSVersion.TLSv1_1)
        self.assertTrue(tls.preflight(ctx, 'firestore.googleapis.com'))

    def test_tls_local_error_is_not_remote_rejection(self):
        import ssl
        error = ssl.SSLError(1, 'Error sintetico local')
        error.reason = 'NO_CIPHERS_AVAILABLE'
        self.assertEqual(tls.classify(error, 200), 'fallo_cliente_o_protocolo_inconcluso')
        error.reason = 'TLSV1_ALERT_PROTOCOL_VERSION'
        self.assertEqual(tls.classify(error, 0), 'fallo_cliente_o_protocolo_inconcluso')
        self.assertEqual(tls.classify(error, 200), 'alerta_servidor')

    def test_tls_eof_and_timeout_are_inconclusive(self):
        import ssl
        self.assertEqual(tls.classify(ssl.SSLEOFError(), 200), 'transporte_inconcluso')
        self.assertEqual(tls.classify(TimeoutError(), 200), 'transporte_inconcluso')

    def test_tls_certificate_error_is_not_version_rejection(self):
        import ssl
        self.assertEqual(tls.classify(ssl.SSLCertVerificationError(), 200),
                         'validacion_certificado_cliente')

    def test_comments_and_strings(self):
        values = [v for _, _, v in inventory.literals(
            '// "comentario"\nText("Español"); /* "oculto" */ r"raw"; """multi\nlinea""";')]
        self.assertEqual(values, ['"Español"', 'r"raw"', '"""multi\nlinea"""'])

    def test_no_personal_data_in_har(self):
        payload = {'log': {'entries': [{'request': {
            'method': 'POST', 'url': 'https://identitytoolkit.googleapis.com/login?secret=CANARIO',
            'postData': {'text': 'PASSWORD_CANARIO'},
            'headers': [{'name': 'Authorization', 'value': 'TOKEN_CANARIO'}]},
            'response': {'status': 200, 'content': {'text': 'UID_CANARIO'}}}]}}
        text = str(sanitizer.sanitize_har(payload))
        self.assertNotIn('CANARIO', text)
        self.assertIn('PENDIENTE', text)

    def test_netlog_does_not_leak_params(self):
        data = {'constants': {'logEventTypes': {'REQUEST': 1}},
                'events': [{'type': 1, 'params': {'headers': 'TOKEN_CANARIO',
                           'url': 'https://unknown.invalid/UID_CANARIO?password=CANARIO'}}]}
        text = str(sanitizer.sanitize_netlog(data))
        self.assertNotIn('CANARIO', text)
        self.assertIn('otro_host_omitido', text)

    def test_video_uses_pts_variable_rate(self):
        probe = {'frames': [{'best_effort_timestamp_time': x} for x in [0, .03, .09, .2]]}
        self.assertAlmostEqual(video.analyze(probe, 1, 3)['segundos'], .17)

    def test_video_rejects_bad_annotations(self):
        probe = {'frames': [{'best_effort_timestamp_time': x} for x in [0, .03, .02]]}
        with self.assertRaises(ValueError):
            video.analyze(probe, 0, 2)

    def test_templates_have_no_results(self):
        with tempfile.TemporaryDirectory(prefix='t98_unit_') as tmp:
            output = Path(tmp)
            prepare.prepare(output, '9ae744a', 'A')
            import csv
            with (output / 'primera_visualizacion.csv').open(encoding='utf-8-sig') as stream:
                rows = list(csv.DictReader(stream))
            self.assertEqual(len(rows), 18)
            for client in ['windows', 'web', 'honor']:
                self.assertEqual(sum(r['cliente'] == client and
                                     r['perfil'] == 'sin_perfil_rige' for r in rows), 5)
                self.assertEqual(sum(r['cliente'] == client and
                                     r['perfil'] == 'con_perfil_informativo' for r in rows), 1)
            self.assertTrue(all(row['tiempo_pts_s'] == '' for row in rows))
            with (output / 'recuperacion.csv').open(encoding='utf-8-sig') as stream:
                self.assertEqual(len(list(csv.DictReader(stream))), 24)


if __name__ == '__main__':
    unittest.main()
