"""Metadatos TLS de evidencia propia; no lee HTTP, tokens ni almacenes de Auth.

PCAPNG: solo Ethernet o Wi-Fi con LLC/SNAP, IP/TCP y ServerHello completo de una
tupla observada por la sonda del proceso. Sin reensamblado: ausencias son
inconclusas. NetLog: solo metadatos QUIC de tres hosts y particion local.
No exporta IP, puertos, nombres de usuario, certificados ni bytes capturados.
"""
import argparse
import hashlib
import ipaddress
import json
from pathlib import Path
import re
import struct

from t98_inventario import output_directory

HOSTS = {'firestore.googleapis.com', 'identitytoolkit.googleapis.com',
         'securetoken.googleapis.com'}
HRR = bytes.fromhex('cf21ad74e59a6111be1d8c021e65b891'
                    'c2a211167abb8c5e079e09e2c8a8339c')


def hello(payload):
    """No confundir legacy_version 0303 de TLS 1.3 con TLS 1.2."""
    offset = 0
    while offset + 5 <= len(payload):
        kind = payload[offset]
        size = int.from_bytes(payload[offset + 3:offset + 5], 'big')
        record = payload[offset + 5:offset + 5 + size]
        offset += 5 + size
        if kind != 22 or len(record) < 4 or record[0] != 2:
            if len(record) != size:
                return None
            continue
        size = int.from_bytes(record[1:4], 'big')
        body = record[4:4 + size]
        if len(body) != size or len(body) < 38 or body[2:34] == HRR:
            return None
        version = int.from_bytes(body[:2], 'big')
        pos = 35 + body[34]
        if pos + 3 > len(body):
            return None
        cipher = int.from_bytes(body[pos:pos + 2], 'big')
        pos += 3
        if pos < len(body):
            if pos + 2 > len(body):
                return None
            end = pos + 2 + int.from_bytes(body[pos:pos + 2], 'big')
            pos += 2
            if end != len(body):
                return None
            while pos < end:
                if pos + 4 > end:
                    return None
                typ, length = struct.unpack('!HH', body[pos:pos + 4])
                pos += 4
                if pos + length > end:
                    return None
                if typ == 43:
                    if length != 2:
                        return None
                    version = int.from_bytes(body[pos:pos + 2], 'big')
                pos += length
        if 0x1301 <= cipher <= 0x1305 and version != 0x304:
            return None
        return {'version': {0x301: 'TLS 1.0', 0x302: 'TLS 1.1',
                            0x303: 'TLS 1.2', 0x304: 'TLS 1.3'}.get(version, 'otra'),
                'cipherSuite': f'0x{cipher:04x}'}
    return None


def normalized(value):
    ip = ipaddress.ip_address(value)
    return str(ip.ipv4_mapped or ip) if ip.version == 6 else str(ip)


def tcp(packet):
    if len(packet) < 14:
        return None
    typ, pos = int.from_bytes(packet[12:14], 'big'), 14
    # Pktmon de esta NIC guarda cabecera Wi-Fi incluso con IDB linktype 1.
    # Validar tipo de trama, longitud derivada y LLC; no buscar IP por heuristica.
    control = int.from_bytes(packet[:2], 'little')
    if control & 0x0c == 0x08:
        header = 24 + (6 if control & 0x300 == 0x300 else 0)
        qos = bool(control & 0x80)
        header += 2 if qos else 0
        header += 4 if qos and control & 0x8000 else 0
        if packet[header:header + 6] == b'\xaa\xaa\x03\0\0\0':
            typ = int.from_bytes(packet[header + 6:header + 8], 'big')
            pos = header + 8
    if typ in (0x8100, 0x88a8) and len(packet) >= pos + 4:
        typ, pos = int.from_bytes(packet[pos + 2:pos + 4], 'big'), pos + 4
    ip = packet[pos:]
    if typ == 0x800 and len(ip) >= 20 and ip[9] == 6:
        if int.from_bytes(ip[6:8], 'big') & 0x3fff:
            return None  # No reensamblar fragmentos.
        src, dst = str(ipaddress.ip_address(ip[12:16])), str(ipaddress.ip_address(ip[16:20]))
        segment = ip[(ip[0] & 15) * 4:int.from_bytes(ip[2:4], 'big')]
    elif typ == 0x86dd and len(ip) >= 40 and ip[6] == 6:
        src, dst = normalized(ip[8:24]), normalized(ip[24:40])
        segment = ip[40:40 + int.from_bytes(ip[4:6], 'big')]
    else:
        return None  # Incluye IPv6 con extensiones; no inferir ausencia.
    if len(segment) < 20:
        return None
    sport, dport = struct.unpack('!HH', segment[:4])
    header = (segment[12] >> 4) * 4
    if header < 20 or header > len(segment):
        return None
    return (src, sport, dst, dport), segment[13], segment[header:]


def pcap(path, sockets):
    doc = json.loads(sockets.read_text(encoding='utf-8-sig'))
    owned = set()
    for sample in doc.get('muestras', []):
        if sample.get('protocolo') == 'TCP':
            for item in sample.get('sockets', []):
                if item.get('remotePort') == 443:
                    owned.add((normalized(item['remoteAddress']), 443,
                               normalized(item['localAddress']), item['localPort']))
    found, syns, packets, matches = [], {}, 0, 0
    with path.open('rb') as stream:
        prefix = stream.read(12)
        if prefix[:4] != bytes.fromhex('0a0d0d0a'):
            raise ValueError('Se requiere PCAPNG.')
        endian = '<' if prefix[8:12] == bytes.fromhex('4d3c2b1a') else '>'
        stream.seek(0)
        links = []
        while header := stream.read(8):
            typ, size = struct.unpack(endian + 'II', header)
            if size < 12 or size > 16 * 1024 * 1024:
                raise ValueError('Bloque PCAPNG invalido.')
            body = stream.read(size - 8)
            if len(body) != size - 8 or struct.unpack(endian + 'I', body[-4:])[0] != size:
                raise ValueError('Bloque incompleto.')
            if typ == 1:
                links.append(struct.unpack(endian + 'H', body[:2])[0])
            if typ != 6:
                continue
            packets += 1
            interface, _, _, caplen, _ = struct.unpack(endian + 'IIIII', body[:20])
            if interface >= len(links) or links[interface] != 1:
                continue
            decoded = tcp(body[20:20 + caplen])
            if not decoded or decoded[0] not in owned:
                continue
            flow, flags, payload = decoded
            matches += 1
            if flags & 0x12 == 0x12:
                syns[flow] = syns.get(flow, 0) + 1
            result = hello(payload)
            if result:
                found.append((flow, result))
    # Tuplas solo en memoria. Multiples SYN/ACK se declaran ambiguos.
    return {'tipo': 'PCAPNG y sonda del proceso', 'paquetes': packets,
            'tuplasPropiasObservadas': len(owned), 'paquetesServidorCoincidentes': matches,
            'saludos': [dict(result, flujoAnonimo=sorted(owned).index(flow) + 1,
                             synAckObservados=syns.get(flow, 0),
                             posibleReuso=syns.get(flow, 0) > 1)
                        for flow, result in found],
            'limite': 'Tupla y sonda, sin reensamblado ni prueba de todos los canales. '
                      'Sin SYN/ACK o con posible reuso, atribucion conservadora inconclusa.'}


def netlog(path):
    data = json.loads(path.read_text(encoding='utf-8-sig'))
    types = {v: k for k, v in data['constants']['logEventTypes'].items()}
    sessions = {}
    for event in data.get('events', []):
        if types.get(event.get('type')) != 'QUIC_SESSION':
            continue
        params = event.get('params', {})
        if params.get('host') not in HOSTS:
            continue
        if not re.search(r'(?<![\w.-])127\.0\.0\.1(?![\w.-])',
                         str(params.get('network_anonymization_key', ''))):
            continue
        sessions[event['source']['id']] = {'host': params['host'],
            'particionLocal': True, 'QUICv1': False, 'saludoCompleto': False}
    for event in data.get('events', []):
        row = sessions.get(event.get('source', {}).get('id'))
        if row is None:
            continue
        typ = types.get(event.get('type'))
        if typ == 'QUIC_SESSION_VERSION_NEGOTIATED':
            row['QUICv1'] |= event.get('params', {}).get('version') == 'RFCv1'
        if typ == 'QUIC_SESSION_CRYPTO_HANDSHAKE_COMPLETE':
            row['saludoCompleto'] = True
    return {'tipo': 'NetLog Chrome auxiliar, solo QUIC permitido',
            'eventosTotales': len(data.get('events', [])),
            'sesiones': list(sessions.values()),
            'inferencia': 'QUIC RFCv1 con saludo completo implica TLS >=1.3 por RFC9001 4.2; '
                          'no es un campo de version TLS leido en Security.',
            'limite': 'No atribuir a IAB, Windows o Honor; no exporta HTTP ni datos de cuenta.'}


def selftest():
    body = b'\x03\x03' + bytes(32) + b'\0\xc0\x2f\0'
    def wrap(b):
        hs = b'\x02' + len(b).to_bytes(3, 'big') + b
        return b'\x16\x03\x03' + len(hs).to_bytes(2, 'big') + hs
    assert hello(wrap(body))['version'] == 'TLS 1.2'
    body13 = body[:35] + b'\x13\x01\0'
    assert hello(wrap(body13 + b'\0\x06\0\x2b\0\x02\x03\x04'))['version'] == 'TLS 1.3'
    assert hello(wrap(body)[:-1]) is None
    assert hello(wrap(b'\x03\x03' + HRR + b'\0\x13\x01\0')) is None
    assert hello(wrap(body13)) is None
    partial_record = wrap(body)
    partial_record = partial_record[:3] + b'\x10\0' + partial_record[5:]
    assert hello(partial_record)['version'] == 'TLS 1.2'
    payload = wrap(body)
    ip = bytearray(20)
    ip[0], ip[9] = 0x45, 6
    ip[2:4] = (40 + len(payload)).to_bytes(2, 'big')
    ip[12:16], ip[16:20] = bytes([192, 0, 2, 1]), bytes([192, 0, 2, 2])
    segment = bytearray(20)
    segment[:4] = struct.pack('!HH', 443, 5000)
    segment[12], segment[13] = 0x50, 0x18
    packet = bytes(12) + b'\x08\0' + ip + segment + payload
    decoded = tcp(packet)
    assert decoded[0] == ('192.0.2.1', 443, '192.0.2.2', 5000)
    assert hello(decoded[2])['version'] == 'TLS 1.2'
    wifi = b'\x08\x02' + bytes(22) + b'\xaa\xaa\x03\0\0\0\x08\0' + ip + segment + payload
    decoded_wifi = tcp(wifi)
    assert decoded_wifi[0] == decoded[0]
    assert hello(decoded_wifi[2])['version'] == 'TLS 1.2'
    print('8 controles del decodificador: correctos; no son mediciones del producto.')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('tipo', choices=['pcap', 'netlog', 'autoprueba'])
    parser.add_argument('--entrada', type=Path)
    parser.add_argument('--sockets', type=Path)
    parser.add_argument('--salida', type=Path)
    args = parser.parse_args()
    if args.tipo == 'autoprueba':
        selftest()
        return
    if not args.entrada or not args.salida:
        parser.error('Indicar entrada y salida propias de TEMP.')
    output_directory(str(args.entrada.resolve().parent))
    output_directory(str(args.salida.resolve().parent))
    if args.salida.exists():
        raise ValueError('No sobrescribir evidencia.')
    if args.tipo == 'pcap':
        if not args.sockets:
            parser.error('PCAP requiere sonda del proceso.')
        output_directory(str(args.sockets.resolve().parent))
    result = netlog(args.entrada) if args.tipo == 'netlog' else pcap(args.entrada, args.sockets)
    result['sha256Entrada'] = hashlib.sha256(args.entrada.read_bytes()).hexdigest()
    args.salida.write_text(json.dumps(result, indent=2, ensure_ascii=False), encoding='utf-8')
    print(json.dumps(result, ensure_ascii=False))


if __name__ == '__main__':
    main()
