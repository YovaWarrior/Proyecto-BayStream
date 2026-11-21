"""T-147 · La copia del plan A09 con el número en blanco (el rodeo del piloto).

Lee CORPUS_A09.edi de la carpeta del corpus (fuera del repositorio) y escribe
en la carpeta de salida una copia, CORPUS_A09_EN_BLANCO.edi, donde
«EQD+CN+NO+» pasa a «EQD+CN++». No toca nada más: comprueba que el resto es
igual byte a byte. Es el plan que la 1.0.1 pudo leer en el piloto 4.

    python -X utf8 tool/t147_copia_en_blanco.py <carpeta del corpus> <carpeta de salida>

La carpeta de salida tiene que estar fuera del repositorio (en %TEMP%).
"""
import hashlib
import pathlib
import sys

corpus = pathlib.Path(sys.argv[1])
salida = pathlib.Path(sys.argv[2]).resolve()
raiz = pathlib.Path(__file__).resolve().parent.parent
if salida == raiz or raiz in salida.parents:
    sys.exit('La copia del caso va fuera del repositorio.')
origen = (corpus / "CORPUS_A09.edi").read_bytes()
huella = hashlib.sha256(origen).hexdigest()
assert huella == "450219fe01c62e0c33e946c9d73c17f5765917376c74ccce3636200e76e0f07e", huella

viejo, nuevo = b"EQD+CN+NO+", b"EQD+CN++"
cuenta = origen.count(viejo)
copia = origen.replace(viejo, nuevo)
assert len(copia) == len(origen) - 2 * cuenta
# Lo demás no cambia: al deshacer el reemplazo en las mismas posiciones sale el original.
partes_o = origen.split(viejo)
partes_c = copia.split(nuevo)
# `EQD+CN++` no existía antes en el original (ningún grupo venía en blanco).
assert origen.count(nuevo) == 0, origen.count(nuevo)
assert partes_o == partes_c

salida.mkdir(parents=True, exist_ok=True)
destino = salida / "CORPUS_A09_EN_BLANCO.edi"
destino.write_bytes(copia)
print("reemplazos:", cuenta)
print("EQD en total:", origen.count(b"EQD+CN+"))
print("LOC+147:", origen.count(b"LOC+147+"))
print("bytes:", len(origen), "->", len(copia))
print("sha256 de la copia:", hashlib.sha256(copia).hexdigest())
print("escrito en:", destino)
