"""SIN_ALERTAS (320 × 200) — la tapa de escotilla, grande, con un check (Nube).

Solo la barra de la tapa de escotilla del ícono, en grande, y debajo el check en `hecho`: «sin
posibles incumplimientos». Sin casco ni celdas, para que no se confunda con `descarga_completa`,
que lleva la bahía entera. Nada se mueve: sin naranja.

Rondas: (1) el check como insignia en el extremo derecho de la tapa: se leía como un interruptor
encendido, sobre todo a 0.5; (2) de tres bocetos (esquina, apilado, centrado) queda el apilado: la
tapa arriba y el check debajo, dos piezas grandes sin solaparse; la tapa más fina (1 : 10, cerca del
1 : 12 del ícono) para que sea una barra y no una píldora, y el check más grande; (3) la tapa a 276
de ancho dejaba 22 px de margen y pesaba más que el check: baja a 248 × 26, el check sube a 88 y el
grupo queda con 35 px de aire arriba y abajo.
"""
import os
import sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from ilus import Ilustracion
from plantilla import tapa, check

W, H = 320, 200
G = 1.75                      # grosor de trazo a 320 de ancho
TW, TH = 248, 26              # la tapa del ícono (64.4 × 5.4) en grande, algo más gruesa para que pese
CHECK = 88                    # diámetro del check (44 px a la mitad)
SEP = 16                      # aire entre la tapa y el check

# el grupo tapa + aire + check, centrado en la hoja
alto = TH + SEP + CHECK
TY = (H - alto) / 2
il = Ilustracion('sin_alertas', W, H)
tapa(il, (W - TW) / 2, TY, TW, TH, grosor=G)
check(il, W / 2, TY + TH + SEP + CHECK / 2, CHECK)

ILUSTRACIONES = {'sin_alertas': il}
