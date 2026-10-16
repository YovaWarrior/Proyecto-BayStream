# Ícono de BayStream · v1

Concepto **Bahía**, elegido por Carlos Martínez en la fase 1 y afinado en dos rondas.
Todo es vectorial, hecho a mano para BayStream, y queda para el proyecto.

## La idea

Es el corte de una bahía tal como lo dibuja la app: dos filas de cubierta, la tapa de escotilla y la
bodega, que se cierra hacia la quilla con la forma del casco. El contenedor naranja salió de su celda:
flota media celda por encima de la fila de cubierta, sobre el hueco que dejó, como si la grúa lo
estuviera moviendo. Es la operación en vivo, la mitad «Stream» del nombre, y rompe la cuadrícula.

A 32, 24, 20 y 16 px se usa un dibujo propio, trazado sobre la rejilla de píxeles de cada tamaño: tres
columnas, una fila de cubierta apoyada en el casco y el contenedor levantado. Ahí el hueco queda a la
derecha, porque centrado el conjunto se leía como una cara.

En monocromo (íconos temáticos de Android 13) el contenedor se reconoce por la forma: es la única pieza
fuera de la cuadrícula.

## Paleta

| Uso | Hex |
|---|---|
| Fondo; es el color semilla de Material 3 de la app | `#0D47A1` |
| Celdas de cubierta y tapa de escotilla | `#F5F8FC` |
| Contenedor en movimiento | `#FF7A1A` |
| Bodega | `#6E9DE6` |
| Capa monocromo (Android la tiñe con el tema) | `#FFFFFF` |
| Frase del gráfico de Play | `#BCD2F7` |

## Zonas seguras

| Formato | Regla | Cómo quedó |
|---|---|---|
| Adaptativo de Android | Lienzo de 108 dp; se ven los 72 dp del centro; el frente debe caber en un círculo de 66 dp | El dibujo llega a 27,2 dp del centro, de 33 dp posibles |
| Web maskable | Lo importante dentro del círculo del 80 % | El dibujo ocupa un círculo del 73,9 %; fuera solo hay fondo |
| Play | Cuadrado de 512 a sangre; Play redondea las esquinas un 20 % | Mismo dibujo que el maskable; las esquinas solo tienen fondo |
| Forma propia (Windows ≥ 40 px, web «any», Android 7) | Cuadrado redondeado con margen del 4 % y esquinas del 21 % | Esquinas transparentes; el dibujo ocupa el 82 % del cuadrado |
| 32, 24, 20 y 16 px | Sin reescalar: cada uno es su propio SVG | Bordes sobre píxel entero |

En la ronda 2 el dibujo creció un 10,5 % en las versiones a sangre y un 10,8 % en la forma propia. El
adaptativo no cambió: sigue dentro de su zona de 66 dp.

## Archivos

### Fuentes y documentación (`design/icono/`)

| Archivo | Píxeles | Formato | Bytes | SHA-256 |
|---|---|---|---:|---|
| `design/icono/baystream.svg` | 512 × 512 (vector) | SVG | 3 922 | `4f12646124389f3c1ea36e94ef3dc1b4464370444a164b5e6c66c456032a39be` |
| `design/icono/baystream_frente.svg` | 108 × 108 (vector) | SVG | 3 900 | `b975968c040e944fbde77c8325aff0359030d41ad705a35afed208551ea45478` |
| `design/icono/baystream_monocromo.svg` | 108 × 108 (vector) | SVG | 3 875 | `58df99fb9a3c51fcdc0b16b1939a138501cb40041d28648e61eaf7cff8887af6` |
| `design/icono/baystream_forma.svg` | 512 × 512 (vector) | SVG | 3 984 | `04f4f1f089dcf25420ff205da0f35e3565741c2bcea6ac891b2cfd295a8fbaaf` |
| `design/icono/baystream_32.svg` | 32 × 32 (vector) | SVG | 1 886 | `8c3c68a773592c59f815e8cf76d115984428b9e5db1d485ede1493a994a5cc70` |
| `design/icono/baystream_24.svg` | 24 × 24 (vector) | SVG | 2 041 | `06d68ff4e607a3befa3331943afddd883b9425d4419e82846ac1da54bf0c5b19` |
| `design/icono/baystream_20.svg` | 20 × 20 (vector) | SVG | 1 823 | `38c92a410021fb6836e40ce9780e633acb1c1d5759d770f3a8b1fce122df480a` |
| `design/icono/baystream_16.svg` | 16 × 16 (vector) | SVG | 1 535 | `4be5cf0511b35d26ece415aa0465a0428316780141044f54004eb9da64f4e012` |
| `design/icono/grafico_play.svg` | 1024 × 500 (vector) | SVG | 69 829 | `cefae8d0bd2baa75cd1e4c7d5fbf6ef3018e3db1da098c7b3fe78174dd12d289` |
| `design/icono/generar.py` | — | texto | 9 895 | `3eebb673e65c7a64e738ab5fcefdeab8144334211fafe4a8e75899bd831f81a9` |
| `design/icono/vista-previa.png` | 1600 × 990 | RGB, 24 bits sin alfa | 149 766 | `f38744b47fc05c4cf7ffbf30a633a776b1b423db1555bdff364051da955b7bf4` |

### Android

| Archivo | Píxeles | Formato | Bytes | SHA-256 |
|---|---|---|---:|---|
| `android/app/src/main/res/mipmap-mdpi/ic_launcher_foreground.png` | 108 × 108 | RGBA, 32 bits con alfa | 883 | `cdfe666faf024ce164de78a12ff240f958f0fb7144b804fbabb6f2d38120eeaf` |
| `android/app/src/main/res/mipmap-mdpi/ic_launcher_monochrome.png` | 108 × 108 | RGBA, 32 bits con alfa | 658 | `4fb0fc05798b8964ea496f7633f0d0e463813df6fd4ff37eb7768103a3808d2e` |
| `android/app/src/main/res/mipmap-mdpi/ic_launcher.png` | 48 × 48 | RGBA, 32 bits con alfa | 1 154 | `a1403c046bcf62a7a142361c84cee3afdfaeeedb6fd36ec0c3e45ec9c3971146` |
| `android/app/src/main/res/mipmap-hdpi/ic_launcher_foreground.png` | 162 × 162 | RGBA, 32 bits con alfa | 1 226 | `209d2940b42b8e0db5975f3bf4a6a86fc4f3d7a9d047789a1784e46d263e5c5f` |
| `android/app/src/main/res/mipmap-hdpi/ic_launcher_monochrome.png` | 162 × 162 | RGBA, 32 bits con alfa | 874 | `60c71c696b0e202a5f9ea54756faa37b040aff743ba70d4d528cc8d4708b222d` |
| `android/app/src/main/res/mipmap-hdpi/ic_launcher.png` | 72 × 72 | RGBA, 32 bits con alfa | 1 308 | `7a997685a154d988f81c91f5d32aeaee34adfdd91908ce5e9768860315809489` |
| `android/app/src/main/res/mipmap-xhdpi/ic_launcher_foreground.png` | 216 × 216 | RGBA, 32 bits con alfa | 1 699 | `5876918d4ec5cdef3d738f947841340d9dec65ec328f5ad095f2812f28013f3d` |
| `android/app/src/main/res/mipmap-xhdpi/ic_launcher_monochrome.png` | 216 × 216 | RGBA, 32 bits con alfa | 1 215 | `b21c4950bb554b8938ddd865d9db96bfd6a8047a58f760b82c0e2d2ce59b95e1` |
| `android/app/src/main/res/mipmap-xhdpi/ic_launcher.png` | 96 × 96 | RGBA, 32 bits con alfa | 1 869 | `52e5f235e77a6cbf20f993889eafa82699ced9bf1fc8ccc70052f98f7b01c1f8` |
| `android/app/src/main/res/mipmap-xxhdpi/ic_launcher_foreground.png` | 324 × 324 | RGBA, 32 bits con alfa | 2 699 | `0efaf9a9d795863ee71e40fd629894e61d4e4037f78633367627eb69cd8b6deb` |
| `android/app/src/main/res/mipmap-xxhdpi/ic_launcher_monochrome.png` | 324 × 324 | RGBA, 32 bits con alfa | 1 947 | `28838371bc07e4ba7c6c85176919a856f648e653c1823325156fa275166fd8f4` |
| `android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png` | 144 × 144 | RGBA, 32 bits con alfa | 2 646 | `6c51e6fd465bee117aecbc4097cfa67a3f42e69c38dc5af352289167d77adb67` |
| `android/app/src/main/res/mipmap-xxxhdpi/ic_launcher_foreground.png` | 432 × 432 | RGBA, 32 bits con alfa | 3 814 | `79b4f0f6d7f925733448a47213bb3181d9810d5704a65daff26ec55bff973efb` |
| `android/app/src/main/res/mipmap-xxxhdpi/ic_launcher_monochrome.png` | 432 × 432 | RGBA, 32 bits con alfa | 2 783 | `276f8b3406cd8b81a9e9af1d03a0bc77b18435ef25b43d4fa44b2b0134edcdaf` |
| `android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png` | 192 × 192 | RGBA, 32 bits con alfa | 3 382 | `21d7c9f1faabfc13a0e17fa9e85220257620aa0e57e55533c28f78b1c5e75805` |
| `android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml` | — | texto | 334 | `cee3ff6c73e61072d4f99f71d5311df6de2540630951b0f9fbd4fc4bb010f62f` |
| `android/app/src/main/res/values/ic_launcher_background.xml` | — | texto | 121 | `87c0fa5b1f64046f2577b8e1a03bf3ad8bd1ba7cff3eb64a4a4bf50a46c17d27` |

### Web

| Archivo | Píxeles | Formato | Bytes | SHA-256 |
|---|---|---|---:|---|
| `web/favicon.png` | 32 × 32 | RGBA, 32 bits con alfa | 493 | `9d8da6448207eb75902183de44bb1a30816cd8345085250e52736fb29194bbde` |
| `web/icons/Icon-192.png` | 192 × 192 | RGBA, 32 bits con alfa | 3 382 | `21d7c9f1faabfc13a0e17fa9e85220257620aa0e57e55533c28f78b1c5e75805` |
| `web/icons/Icon-512.png` | 512 × 512 | RGBA, 32 bits con alfa | 9 165 | `37e29e43385b43a91446bca6320a417c4583c4a525d44856c677e21de8c22cf6` |
| `web/icons/Icon-maskable-192.png` | 192 × 192 | RGBA, 32 bits con alfa | 2 213 | `b5bacac546b7e80af4d72d1de4b167634e9247aa1c95b9c639b6802953adb781` |
| `web/icons/Icon-maskable-512.png` | 512 × 512 | RGBA, 32 bits con alfa | 6 471 | `1e860539d0828a7c158168ff8ae96e6bc7ade0cd9b2000fa9309bb1202281865` |

### Windows

| Archivo | Píxeles | Formato | Bytes | SHA-256 |
|---|---|---|---:|---|
| `windows/runner/resources/app_icon.ico` | 16, 20, 24, 32, 40, 48, 64, 128 y 256 | 32 bits con alfa (BMP; PNG en 256) | 114 967 | `1721c4752fa09ca07b9d3f5438ac99ccc6014aa9e72fd8eaf4703e050ca722bd` |

### Play

| Archivo | Píxeles | Formato | Bytes | SHA-256 |
|---|---|---|---:|---|
| `play/icono-512.png` | 512 × 512 | RGBA, 32 bits con alfa | 6 471 | `1e860539d0828a7c158168ff8ae96e6bc7ade0cd9b2000fa9309bb1202281865` |
| `play/grafico-1024x500.png` | 1024 × 500 | RGB, 24 bits sin alfa | 22 276 | `ef24f425d256e472cb4d3000569885d61f7510da417ca46e4d7d38dbdbaf0884` |

`design/icono/LEEME.md` es este archivo; no lleva su propio SHA-256.

Los PNG, el `.ico` y los dos XML los produce `generar.py` desde los SVG. Corriéndolo dos veces sobre una
carpeta vacía salen archivos idénticos byte a byte (Python 3.13, Pillow 12.3, resvg-py 0.5.0). Con
otras versiones de Pillow o de zlib los PNG pueden comprimirse distinto y cambiar su SHA-256 sin que
cambie un solo píxel.

## Cómo regenerar y verificar

Desde la raíz del repositorio:

```
python -m pip install resvg-py==0.5.0 Pillow
python design/icono/generar.py
```

El script escribe todos los archivos de Android, Web, Windows y Play, y después los comprueba:

- cada PNG tiene su tamaño exacto y su modo (RGBA con alfa; el gráfico de Play, RGB sin alfa);
- el `.ico` trae los nueve tamaños, en 32 bits, y cada uno es su dibujo propio, sin reescalar;
- el PNG de Play pesa menos de 1 024 KB, no tiene transparencia y sus esquinas solo tienen fondo;
- los maskable no tienen transparencia y fuera del círculo del 80 % solo hay fondo;
- el frente y el monocromo del adaptativo no salen del círculo de 66 dp en ninguna densidad.

Termina con «52 de 52 comprobaciones correctas» y código de salida 0; si algo falla, lo dice y sale con 1.
`python design/icono/generar.py --verificar` solo comprueba, sin escribir.

## Para integrarlo

1. Copia el contenido del zip sobre la raíz del repositorio. Reemplaza los íconos por defecto de Flutter
   en `android/`, `web/` y `windows/`; `design/` y `play/` son carpetas nuevas.
2. **Android.** `AndroidManifest.xml` debe usar `android:icon="@mipmap/ic_launcher"`, que es lo que
   trae Flutter. Si declara `android:roundIcon`, quítalo o apúntalo también a `@mipmap/ic_launcher`.
   La capa `<monochrome>` necesita `compileSdk` 33 o mayor. En Android 8 y posteriores se usa el
   adaptativo; los `ic_launcher.png` son para Android 7 y anteriores.
3. **Web.** El `manifest.json` de Flutter ya apunta a `Icon-192`, `Icon-512` y a los dos maskable, y
   `index.html` a `favicon.png`. Opcional: `"theme_color"` y `"background_color"` en `#0D47A1`.
4. **Windows.** `windows/runner/Runner.rc` ya apunta a `resources/app_icon.ico`. Se ve al recompilar.
5. **Play.** `play/icono-512.png` es el ícono de la ficha y `play/grafico-1024x500.png` el gráfico de
   funciones. No los usa la compilación; se suben en Play Console.

Después de compilar, conviene revisar en el teléfono el lanzador, el ícono temático (Ajustes →
Fondo de pantalla y estilo → Íconos temáticos) y, en Windows, la barra de tareas.

## Tipografía del gráfico de Play

El texto de `grafico_play.svg` está convertido a trazos desde Barlow Condensed (Bold y Medium),
© 2017 The Barlow Project Authors, bajo SIL Open Font License 1.1. No hace falta instalar la fuente
para regenerarlo.

## Para versionar

Carlos ejecuta Git. Un `git add` por ruta:

```
git add -- design/icono/baystream.svg
git add -- design/icono/baystream_frente.svg
git add -- design/icono/baystream_monocromo.svg
git add -- design/icono/baystream_forma.svg
git add -- design/icono/baystream_32.svg
git add -- design/icono/baystream_24.svg
git add -- design/icono/baystream_20.svg
git add -- design/icono/baystream_16.svg
git add -- design/icono/grafico_play.svg
git add -- design/icono/generar.py
git add -- design/icono/vista-previa.png
git add -- android/app/src/main/res/mipmap-mdpi/ic_launcher_foreground.png
git add -- android/app/src/main/res/mipmap-mdpi/ic_launcher_monochrome.png
git add -- android/app/src/main/res/mipmap-mdpi/ic_launcher.png
git add -- android/app/src/main/res/mipmap-hdpi/ic_launcher_foreground.png
git add -- android/app/src/main/res/mipmap-hdpi/ic_launcher_monochrome.png
git add -- android/app/src/main/res/mipmap-hdpi/ic_launcher.png
git add -- android/app/src/main/res/mipmap-xhdpi/ic_launcher_foreground.png
git add -- android/app/src/main/res/mipmap-xhdpi/ic_launcher_monochrome.png
git add -- android/app/src/main/res/mipmap-xhdpi/ic_launcher.png
git add -- android/app/src/main/res/mipmap-xxhdpi/ic_launcher_foreground.png
git add -- android/app/src/main/res/mipmap-xxhdpi/ic_launcher_monochrome.png
git add -- android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png
git add -- android/app/src/main/res/mipmap-xxxhdpi/ic_launcher_foreground.png
git add -- android/app/src/main/res/mipmap-xxxhdpi/ic_launcher_monochrome.png
git add -- android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png
git add -- web/favicon.png
git add -- web/icons/Icon-192.png
git add -- web/icons/Icon-512.png
git add -- web/icons/Icon-maskable-192.png
git add -- web/icons/Icon-maskable-512.png
git add -- play/icono-512.png
git add -- play/grafico-1024x500.png
git add -- windows/runner/resources/app_icon.ico
git add -- android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml
git add -- android/app/src/main/res/values/ic_launcher_background.xml
git add -- design/icono/LEEME.md
git commit -m "Agrega el icono de BayStream v1 para Android, Web, Windows y Play"
git push
```

No cambian `pubspec.yaml` ni `pubspec.lock`.
