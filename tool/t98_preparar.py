"""Hojas vacías y protocolo fijo T98. Nunca genera observaciones ni resultados."""
import argparse
import csv
import json
from pathlib import Path

from t98_inventario import output_directory


OPERATIONS = ['cargar_baplie', 'confirmar_perfil', 'ver_bay_plan',
              'navegar_bahias', 'lista_filtros', 'buscar', 'estadisticas',
              'alertas_estiba', 'exportar', 'reabrir_reciente', 'parametros_buque']
CLIENTS = ['windows', 'web', 'honor']
TASKS = ['Cargar A01', 'Ver una bahía', 'Encontrar un contenedor por ID',
         'Identificar un refrigerado', 'Leer una alerta de estiba']
SUS = [
    'Creo que usaría este sistema con frecuencia.',
    'El sistema me resultó innecesariamente complejo.',
    'Me pareció fácil usar el sistema.',
    'Necesitaría apoyo técnico para usarlo.',
    'Las funciones del sistema se integran adecuadamente.',
    'Encontré demasiada inconsistencia en el sistema.',
    'Creo que la mayoría aprendería a usarlo rápidamente.',
    'El sistema me resultó complicado de manejar.',
    'Me sentí seguro al usarlo.',
    'Tuve que aprender mucho antes de poder empezar a usarlo.',
]


def sheet(path, columns, rows):
    with path.open('x', encoding='utf-8-sig', newline='') as stream:
        writer = csv.DictWriter(stream, fieldnames=columns)
        writer.writeheader()
        for row in rows:
            writer.writerow({**dict.fromkeys(columns, ''), **row})


def prepare(output, commit, phase):
    sheet(output / 'operaciones.csv',
          ['cliente', 'condicion', 'operacion', 'inicio_utc', 'fin_utc',
           'evidencia', 'sin_red_verificada', 'funciona', 'transmite_T63',
           'justificacion', 'worker_comprobado', 'limitaciones'],
          ({'cliente': c, 'condicion': k, 'operacion': op}
           for c in CLIENTS for k in ['A_sin_sesion', 'B_sesion_fuera_compartida', 'sin_red']
           for op in OPERATIONS))
    sheet(output / 'recuperacion.csv',
          ['cliente', 'archivo', 'video', 'fps_real', 'inicio_cuadro',
           'error_cuadro', 'viaje_anterior_cuadro', 'boton_responde_cuadro',
           'tiempo_pts_s', 'incertidumbre_s', 'causa', 'accion', 'segmento', 'dictamen'],
          ({'cliente': c, 'archivo': f'{i:02}'} for c in CLIENTS for i in range(1, 9)))
    sheet(output / 'primera_visualizacion.csv',
          ['cliente', 'perfil', 'repeticion', 'video', 'fps_real', 'inicio_icono_cuadro',
           'rejilla_cuadro', 'pasos_detalle', 'pasos', 'tiempo_pts_s', 'dictamen'],
          ({'cliente': c, 'perfil': p, 'repeticion': r}
           for c in CLIENTS for p in ['sin_perfil_rige', 'con_perfil_informativo'] for r in range(1, 6)))
    sheet(output / 'piloto_tiempos.csv',
          ['participante', 'tarea', 'inicio_s', 'fin_s', 'completa_sin_ayuda', 'incidencia_sin_datos_personales'],
          ({'participante': f'P{p}', 'tarea': t} for p in range(1, 6) for t in TASKS))
    sheet(output / 'piloto_sus.csv',
          ['participante'] + [f'item_{i}' for i in range(1, 11)] + ['SUS_0_100'],
          ({'participante': f'P{p}'} for p in range(1, 6)))
    protocol = f'''# T-98 · Protocolo · Fase {phase} · base {commit}

Las hojas están vacías por diseño. Fase A no produce mediciones RNF.
Fase B requiere el commit anunciado por Carlos y binarios de su copia limpia,
identificados por SHA-256. Registrar SO, pantalla, escala, versiones y almacén.

## Seguridad y disponibilidad

Once operaciones fijas, desglosadas sin eliminar ninguna de T63 4.1.
A: Firebase configurado, sin sesión. B: con sesión, sin operación compartida,
solo informativa. Sin Firebase inicializado es solo ensayo, no condición A válida.
La sincronización se evalúa con TLS; solo PRUEBA T-98 creada por Carlos.
No abrir PRUEBA T-105. No usar apps reales ni demo17. No Firebase CLI/consola.
La autenticación del SDK NO queda aislada solo por prefijar Hive: usar paquete
Android .t98, perfil/origen Web exclusivo y cliente Windows separado; comprobar
ausencia de sesión antes de grabar. Si no se puede aislar, detener ese cliente.
La entrada t98_main usa FirebaseApp con nombre t98 y clientes Auth/Firestore
explícitos. Confirmar su aislamiento real en cada plataforma antes de la sesión.

Web visible: DevTools Network Preserve log + HAR; chrome://net-export en modo
sin cookies/credenciales ni bytes crudos. Registrar una petición provocada por
el worker y comprobarla en NetLog global. Una traza de pestaña no lo sustituye.
Guardar originales transitorios solo en TEMP privado; revisar allí y generar
resúmenes con t98_sanitizar.py. Cualquier petición con datos derivados o escritura
remota cuenta; descargar motor/fuentes públicos no. Una operación A que transmita
obliga a detener y avisar a Yov. Ausencia de sockets no demuestra cero bytes.

Honor (solo B): netstats antes/después por cada operación, validar frescura y
sección UID/tag/set sin duplicados; t44_honor_red.ps1 como segunda fuente TCP,
sin persistir su UID. No sumar indiscriminadamente totales de varias secciones.
La sonda t98_honor_red.ps1 filtra en memoria y no guarda volcados completos.
Sin red: modo avión=1, wifi_on=0 y ping fallido. Al terminar, letra 1.0.
Windows/Web: Carlos desconecta la red de verdad después de cargar la Web;
registrar adaptadores/ruta/ping fallido y recorrer las once operaciones.
DevTools Offline solo no basta para afirmar red del equipo desconectada.

Windows: abrir por explorer.exe y cerrar solo su PID. Registrar almacén real;
para huellas/conteos, helper externo lanzado mediante explorer.exe que registre
su padre (T93), nunca confiar en LOCALAPPDATA virtualizado del agente.
No borrar bitácoras; no restablecer el almacén real. Preparar por separado las
condiciones sin/con perfil usando solo datos t98 y respaldos del namespace.
En Web, perfil nuevo; en Honor, app .t98 separada. No alterar datos por defecto.

## Recuperación y primera visualización

Recuperación: un video por cada uno de los 8 archivos y cada cliente (24).
Inicio: confirmar selector. Fin: error visible, viaje anterior visible y botón
de carga que responde; manda el último hito. Umbral estricto <3 s.
Si el archivo se acepta sin aviso, registrar aceptación; no inventar recuperación.
No usar tiempos de parseo de un script como tiempo de recuperación de interfaz.

Primera visualización: 5 repeticiones por condición y cliente (30).
Inicio: toque/clic al ícono; fin: primer cuadro con rejilla Bay Plan.
Un paso por control propio/decisión; selector del sistema = uno; scroll = cero.
El inicio en el ícono también cuenta. Sin perfil rige <=3 pasos y <=30 s;
con perfil es informativo. Anotar cada acción, no solo el total.
Conservar video, PTS de cuadros y fps reales. t98_video.py calcula diferencias
de PTS; la selección de hitos es humana y queda auditable. No instalar grabadores:
FFmpeg gdigrab está disponible. Ocultar cuentas y notificaciones, login sin grabar.

## Idioma y Material 3

t98_inventario.py conserva todos los literales como candidatos; revisar usos
indirectos, concatenaciones/interpolaciones, errores de plugins y componentes
propios. Las columnas PENDIENTE no cuentan como auditoría completada.
Idioma = cadenas visibles en español / cadenas visibles. Errores: revisar causa,
acción y segmento si es parseo. Recorrer todas las rutas; no usar indicios léxicos
como dictamen. Material: controles interactivos por pantalla, origen Material
y colorScheme. Identificar excepciones. Excluir rejilla por carecer de equivalente
Material, sin excluir sus controles externos. No inferir 100% de useMaterial3.

## Piloto: lo aplica Carlos

Cinco participantes de operaciones COMAR, P1-P5, sin nombres ni capacitación.
Tareas fijas en piloto_tiempos.csv. Productivo = cinco completas sin ayuda en
<10 min desde que recibe la app. Registrar ayudas y tareas incompletas.
SUS inmediatamente después, sin dirigir respuestas. Escala de 1 (total desacuerdo)
a 5 (total acuerdo). Traducción de trabajo al español de Brooke; no se presenta
como una traducción validada. Fuente primaria conservada por AHRQ:
https://digital.ahrq.gov/sites/default/files/docs/survey/systemusabilityscale%2528sus%2529_comp%255B1%255D.pdf

'''
    protocol += '\n'.join(f'{i}. {text}' for i, text in enumerate(SUS, 1))
    protocol += '''

Puntuación: impares respuesta-1; pares 5-respuesta; sumar y multiplicar por 2.5.
No imputar respuestas ausentes. Informar cinco puntajes y media, sin tratar el
puntaje como porcentaje. Meta del indicador 6: SUS >=68 (10.80), no es H6.
No cambia los umbrales de RNF002. Resultados y limitaciones quedan pendientes.
'''
    (output / 'protocolo.md').write_text(protocol, encoding='utf-8')
    (output / 'identidad.json').write_text(json.dumps({
        'fase': phase, 'commit': commit, 'namespace': 't98',
        'binarios_sha256': {}, 'mediciones': [],
    }, indent=2), encoding='utf-8')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('salida')
    parser.add_argument('--commit', required=True)
    parser.add_argument('--fase', choices=['A', 'B'], default='A')
    args = parser.parse_args()
    import re
    if not re.fullmatch(r'[a-fA-F0-9]{7,40}', args.commit):
        raise ValueError('Indicar hash real del commit.')
    prepare(output_directory(args.salida), args.commit, args.fase)
    print('T98: protocolo y hojas vacías preparados; no hay mediciones.')


if __name__ == '__main__':
    main()
