"""T-124 · O1 de la aceptación de T-123 (10.65): la prueba del conductor del
arrastre del emulador (tool/t123_capturas_android.py, `h7`).

Sin emulador: `adb` se sustituye por uno que anota cada orden y devuelve
pantallas sintéticas, y el volcado de uiautomator por unos nodos fijos. Tres
casos, rojos con el conductor de T-123:

  1. si algo falla con el dedo abajo, el contacto se suelta igual (finally):
     la última orden de la pantalla táctil es levantar el dedo;
  2. dos arrastres seguidos no reutilizan el identificador del contacto
     (ABS_MT_TRACKING_ID);
  3. si la celda no se levantó (la pantalla no cambió sobre el origen tras la
     pulsación larga), el conductor se detiene antes de llevar el dedo al
     borde.

python -X utf8 tool/t124_conductor_prueba.py
"""
import io
import sys
from pathlib import Path

from PIL import Image

sys.path.insert(0, str(Path(__file__).resolve().parent))
import t122_capturas_android as t122  # noqa: E402
import t123_capturas_android as t123  # noqa: E402

ORIGEN = (168, 737, 348, 893, 'OR 2 · TSTU0220019, sube')
DESTINO = (900, 737, 1060, 893, 'Celda 022-09-84, libre')


def _png(gris):
    imagen = Image.new('RGB', (1080, 1920), (gris, gris, gris))
    salida = io.BytesIO()
    imagen.save(salida, format='PNG')
    return salida.getvalue()


CLARA, OSCURA = _png(240), _png(90)


class Emulador:
    """El adb simulado: anota las órdenes y da pantallas según el caso."""

    def __init__(self, se_levanta=True, falla_el_destino=False):
        self.ordenes = []
        self.se_levanta = se_levanta
        self.falla_el_destino = falla_el_destino
        self.pantallas = 0

    def adb(self, *args, texto=False):
        self.ordenes.append(' '.join(str(a) for a in args))
        if 'screencap' in args:
            self.pantallas += 1
            # Antes de la pulsación, clara; después, si la celda se levantó,
            # el origen queda atenuado.
            if self.se_levanta and self.pantallas % 2 == 0:
                return OSCURA
            return CLARA
        return '' if texto else b''

    def nodos(self, patron=None):
        import re
        return [n for n in (ORIGEN, DESTINO) if patron is None or re.search(patron, n[4])]

    def esperar(self, patron, segundos=40):
        if 'Celda 022-09-84' in patron and self.falla_el_destino:
            raise RuntimeError(f'No apareció: {patron}')
        filas = self.nodos(patron)
        if not filas:
            raise RuntimeError(f'No apareció: {patron}')
        return filas

    def tactiles(self):
        """Las órdenes de sendevent, en orden."""
        return [o for o in self.ordenes if 'sendevent' in o]


def _preparar(emulador, monkeypatch):
    for modulo in (t122, t123):
        for nombre, valor in (('adb', emulador.adb), ('nodos', emulador.nodos),
                              ('esperar', emulador.esperar)):
            if hasattr(modulo, nombre):
                monkeypatch(modulo, nombre, valor)
    for modulo in (t122, t123):
        for nombre in ('panel', 'modo', 'bahia', 'tocar', 'captura', 'tap'):
            if hasattr(modulo, nombre):
                monkeypatch(modulo, nombre, lambda *a, **k: None)
    monkeypatch(t122.time, 'sleep', lambda *_: None)


def _con_parches(funcion):
    guardados = []

    def monkeypatch(modulo, nombre, valor):
        guardados.append((modulo, nombre, getattr(modulo, nombre)))
        setattr(modulo, nombre, valor)

    try:
        return funcion(monkeypatch)
    finally:
        for modulo, nombre, valor in reversed(guardados):
            setattr(modulo, nombre, valor)


def caso_suelta_siempre():
    emulador = Emulador(falla_el_destino=True)

    def correr(monkeypatch):
        _preparar(emulador, monkeypatch)
        try:
            t123.h7(Path('.'), 'prueba')
        except RuntimeError:
            pass
        else:
            raise AssertionError('el destino debía fallar')

    _con_parches(correr)
    tactiles = emulador.tactiles()
    assert any(' 1 330 1' in o for o in tactiles), 'no se apoyó el dedo'
    ultima = tactiles[-1]
    assert ' 1 330 0' in ultima, f'el contacto quedó apoyado: {ultima[-80:]}'


def _identificadores(tactiles):
    import re
    ids = []
    for orden in tactiles:
        for valor in re.findall(r'sendevent \S+ 3 57 (\d+)', orden):
            if valor != '4294967295':
                ids.append(int(valor))
    return ids


def caso_no_reutiliza():
    emulador = Emulador()

    def correr(monkeypatch):
        _preparar(emulador, monkeypatch)
        t123.h7(Path('.'), 'prueba')
        t123.h7(Path('.'), 'prueba')

    _con_parches(correr)
    ids = _identificadores(emulador.tactiles())
    assert len(ids) == 2, ids
    assert ids[0] != ids[1], f'reutiliza el identificador {ids[0]}'


def caso_comprueba_que_se_levanto():
    emulador = Emulador(se_levanta=False)

    def correr(monkeypatch):
        _preparar(emulador, monkeypatch)
        try:
            t123.h7(Path('.'), 'prueba')
        except RuntimeError as error:
            return str(error)
        return None

    mensaje = _con_parches(correr)
    assert mensaje is not None and 'levant' in mensaje, \
        f'siguió sin que la celda se levantara: {mensaje}'
    tactiles = emulador.tactiles()
    abajo = max(i for i, o in enumerate(tactiles) if ' 1 330 1' in o)
    assert not [o for o in tactiles[abajo + 1:] if ' 3 53 ' in o and ' 1 330 0' not in o], \
        'llevó el dedo hacia el borde'
    assert ' 1 330 0' in tactiles[-1], 'el contacto quedó apoyado'


def main():
    fallos = 0
    for caso in (caso_suelta_siempre, caso_no_reutiliza, caso_comprueba_que_se_levanto):
        try:
            caso()
            print(f'PASA  {caso.__name__}')
        except Exception as error:  # noqa: BLE001
            fallos += 1
            print(f'FALLA {caso.__name__}: {type(error).__name__}: {error}')
    print('resultado:', 'todo pasa' if fallos == 0 else f'{fallos} de 3 fallan')
    return 1 if fallos else 0


if __name__ == '__main__':
    raise SystemExit(main())
