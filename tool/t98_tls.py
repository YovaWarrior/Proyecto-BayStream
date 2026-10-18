"""T98 10.81: saludos TLS sin HTTP, sesión, credenciales ni instalaciones.

Una alerta TLS recibida después de enviar ClientHello se distingue de errores
del cliente, validación de certificados, EOF, timeout y errores de transporte.
La versión real del SDK sigue pendiente del panel Security de Chrome en Fase B.
"""
import argparse
import json
from pathlib import Path
import re
import socket
import ssl
import warnings

from t98_inventario import output_directory


HOSTS = ('firestore.googleapis.com', 'identitytoolkit.googleapis.com',
         'securetoken.googleapis.com')


def context(version):
    result = ssl.create_default_context()
    with warnings.catch_warnings():
        warnings.simplefilter('ignore', DeprecationWarning)
        if version == 'TLSv1.1':
            result.minimum_version = ssl.TLSVersion.TLSv1_1
            result.maximum_version = ssl.TLSVersion.TLSv1_1
            # Solo este cliente de prueba. No debilita SDK, SO ni TLS de control.
            result.set_ciphers('DEFAULT:@SECLEVEL=0')
        elif version == 'TLSv1.2':
            result.minimum_version = ssl.TLSVersion.TLSv1_2
            result.maximum_version = ssl.TLSVersion.TLSv1_2
        else:
            raise ValueError('Versión de prueba no permitida.')
    return result


def preflight(ctx, hostname):
    incoming, outgoing = ssl.MemoryBIO(), ssl.MemoryBIO()
    client = ctx.wrap_bio(incoming, outgoing, server_hostname=hostname)
    try:
        client.do_handshake()
    except ssl.SSLWantReadError:
        return outgoing.pending > 0
    return False


def classify(error, sent):
    if isinstance(error, ssl.SSLCertVerificationError):
        return 'validacion_certificado_cliente'
    if isinstance(error, (ssl.SSLEOFError, ConnectionError, TimeoutError, socket.gaierror)):
        return 'transporte_inconcluso'
    if isinstance(error, ssl.SSLError):
        reason = error.reason or ''
        # Las alertas del peer tienen *_ALERT_*; no confundir WRONG_VERSION_NUMBER,
        # NO_PROTOCOLS_AVAILABLE o NO_CIPHERS_AVAILABLE con un rechazo remoto.
        if sent > 0 and '_ALERT_' in reason:
            return 'alerta_servidor'
        return 'fallo_cliente_o_protocolo_inconcluso'
    if isinstance(error, OSError):
        return 'transporte_inconcluso'
    return 'fallo_cliente'


def handshake(hostname, version, timeout=8):
    result = {'host': hostname, 'ofrecido': version, 'clienthello_generable': False,
              'bytes_tls_enviados': 0, 'negociado': None, 'cifrado': None,
              'alerta_tls': None, 'observacion': None}
    try:
        ctx = context(version)
        result['clienthello_generable'] = preflight(ctx, hostname)
        if not result['clienthello_generable']:
            result['observacion'] = 'fallo_cliente'
            return result
        incoming, outgoing = ssl.MemoryBIO(), ssl.MemoryBIO()
        client = ctx.wrap_bio(incoming, outgoing, server_hostname=hostname)
        with socket.create_connection((hostname, 443), timeout=timeout) as connection:
            connection.settimeout(timeout)
            while True:
                try:
                    client.do_handshake()
                    while outgoing.pending:
                        data = outgoing.read()
                        connection.sendall(data)
                        result['bytes_tls_enviados'] += len(data)
                    result['negociado'] = client.version()
                    cipher = client.cipher()
                    result['cifrado'] = cipher[0] if cipher else None
                    result['observacion'] = 'negocia'
                    break
                except ssl.SSLWantReadError:
                    while outgoing.pending:
                        data = outgoing.read()
                        connection.sendall(data)
                        result['bytes_tls_enviados'] += len(data)
                    data = connection.recv(65536)
                    if not data:
                        result['observacion'] = 'transporte_inconcluso'
                        break
                    incoming.write(data)
    except (OSError, ValueError) as error:
        result['observacion'] = classify(error, result['bytes_tls_enviados'])
        if result['observacion'] == 'alerta_servidor':
            reason = error.reason or ''
            result['alerta_tls'] = reason if re.fullmatch('[A-Z0-9_]+', reason) else 'ALERTA'
        # Nunca persistir str(error), certificados ni bytes del saludo.
    return result


def run():
    records = []
    for hostname in HOSTS:
        positive = handshake(hostname, 'TLSv1.2')
        negative = handshake(hostname, 'TLSv1.1')
        negative['control_12_negocia'] = positive['negociado'] == 'TLSv1.2'
        negative['interpretacion'] = (
            'rechazo_remoto_observado' if negative['observacion'] == 'alerta_servidor'
            and negative['control_12_negocia'] else
            'negocia_11' if negative['negociado'] == 'TLSv1.1' else 'inconcluso')
        records.extend([positive, negative])
    return records


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--salida', type=Path, required=True)
    parser.add_argument('--fase', choices=['A', 'B'], default='A')
    parser.add_argument('--base', required=True)
    args = parser.parse_args()
    if not re.fullmatch('[a-fA-F0-9]{7,40}', args.base) or (args.fase == 'B' and len(args.base) != 40):
        raise ValueError('Indicar base real; B exige el hash completo de cierre.')
    target = output_directory(str(args.salida.resolve().parent)) / args.salida.name
    if target.exists():
        raise ValueError('No sobrescribir evidencia.')
    result = {'instrumento': 'T98 TLS Python', 'fase': args.fase, 'base': args.base,
              'biblioteca_ssl': ssl.OPENSSL_VERSION,
              'ensayo_no_medicion': args.fase == 'A', 'conexiones': run(),
              'limites': 'Solo saludos. Una alerta remota no identifica por sí sola '
              'la política mínima del servidor. Corroborar versión del SDK en '
              'Security; EOF/reset/timeout y fallos locales son inconclusos.'}
    with target.open('x', encoding='utf-8') as stream:
        json.dump(result, stream, indent=2)
    print('T98 TLS: seis saludos registrados en TEMP, sin HTTP ni credenciales.')


if __name__ == '__main__':
    main()
