"""Reduce HAR/NetLog a una lista permitida; nunca copia cabeceras ni cuerpos.

No redistribuir el original. El resumen requiere revisión humana para
clasificar cada petición según T63 4.2. No certifica ausencia de datos.
"""
import argparse
import json
import re
from urllib.parse import urlsplit

from t98_inventario import output_directory


PUBLIC_HOSTS = {'firestore.googleapis.com', 'identitytoolkit.googleapis.com',
                'securetoken.googleapis.com', 'fonts.googleapis.com',
                'fonts.gstatic.com', 'www.gstatic.com', 'localhost', '127.0.0.1'}


def host(value):
    try:
        name = urlsplit(str(value)).hostname or ''
    except ValueError:
        return 'omitido'
    return name if name in PUBLIC_HOSTS else 'otro_host_omitido'


def sanitize_har(data):
    records = []
    for entry in data.get('log', {}).get('entries', []):
        request, response = entry.get('request', {}), entry.get('response', {})
        url = request.get('url', '')
        method = request.get('method', '')
        records.append({'host': host(url),
            'metodo': method if method in {'GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'HEAD', 'OPTIONS', 'CONNECT'} else 'otro',
            'status': response.get('status') if isinstance(response.get('status'), int) else None,
            'consultaPresente': bool(urlsplit(url).query),
            'cuerpoPresente': 'postData' in request,
            'revisarEscritura': method in {'POST', 'PUT', 'PATCH', 'DELETE'},
            'transmisionT63': 'PENDIENTE', 'justificacion': ''})
    return {'tipo': 'HAR reducido', 'peticiones': records,
            'limite': 'Se omiten rutas, consultas, cabeceras, cookies y cuerpos. '
            'Revisar el original de forma privada antes de eliminarlo. '
            'No clasificar un POST automáticamente como descarga pública.'}


def sanitize_netlog(data):
    constants = data.get('constants', {})
    types = {v: k for k, v in constants.get('logEventTypes', {}).items()}
    sources = {v: k for k, v in constants.get('logSourceType', {}).items()}
    events = []
    worker = 0
    for event in data.get('events', []):
        event_type = types.get(event.get('type'), 'TIPO_DESCONOCIDO')
        source = event.get('source', {})
        source_type = sources.get(source.get('type'), 'FUENTE_DESCONOCIDA')
        # Constantes solo como identificadores enumerados, nunca strings libres.
        event_type = event_type if re.fullmatch(r'[A-Z][A-Z0-9_]{0,95}', str(event_type)) else 'OMITIDO'
        source_type = source_type if re.fullmatch(r'[A-Z][A-Z0-9_]{0,95}', str(source_type)) else 'OMITIDO'
        worker += int('SERVICE_WORKER' in str(event_type) + str(source_type))
        params = event.get('params', {})
        dependency = params.get('source_dependency', {})
        events.append({'tipo': event_type, 'fuenteTipo': source_type,
                       'tiempo': str(event.get('time')) if re.fullmatch(r'[0-9.]+', str(event.get('time'))) else None,
                       'fuenteId': source.get('id') if isinstance(source.get('id'), int) else None,
                       'dependenciaId': dependency.get('id') if isinstance(dependency, dict) and isinstance(dependency.get('id'), int) else None,
                       'host': host(params.get('url', ''))})
    return {'tipo': 'NetLog reducido', 'eventos': events,
            'eventosWorkerExplicitos': worker,
            'workerCobertura': 'PENDIENTE: verificar una solicitud causada por el worker '
            'en el registro global; no inferir cobertura por ausencia ni solo por el nombre del evento.'}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('tipo', choices=['har', 'netlog'])
    parser.add_argument('entrada')
    parser.add_argument('salida')
    args = parser.parse_args()
    from pathlib import Path
    entry = Path(args.entrada).resolve()
    # Tampoco procesar evidencia ubicada fuera de TEMP.
    output_directory(str(entry.parent))
    with entry.open(encoding='utf-8-sig') as stream:
        data = json.load(stream)
    result = sanitize_har(data) if args.tipo == 'har' else sanitize_netlog(data)
    target = output_directory(args.salida) / f'{args.tipo}-sanitizado.json'
    if target.exists():
        raise ValueError('No sobrescribir evidencia.')
    target.write_text(json.dumps(result, indent=2), encoding='utf-8')
    print('T98: resumen sanitizado en TEMP; dictamen pendiente.')


if __name__ == '__main__':
    main()
