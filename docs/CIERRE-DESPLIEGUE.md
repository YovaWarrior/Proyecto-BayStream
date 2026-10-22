# Cierre del Sprint 3 · Guía de la mezcla y el despliegue

**Todo esto lo hace Carlos.** Yov redacta; Carlos ejecuta Git, Flutter, la firma y
Firebase. Base del release: el commit de cierre **`sprint3-cierre-2`** (su código es
el de T-112; `main` recibe exactamente eso al mezclar en `master` (la rama principal del repo)). Antes de nada, confirma que no
quede nada sin commitear de las tareas y aceptaciones.

---

## ⚠️ La regla que no se puede romper

**Nunca corras `firebase deploy` a secas.** El `firestore.rules` de la raíz del repo
es el del proyecto temporal de H5; un deploy completo publicaría esas reglas sobre
producción. Las reglas de producción se publican **solo pegando la propuesta en la
consola** (ya están publicadas y coinciden byte a byte, 10.108). Para la Web usa
exclusivamente:

```
firebase deploy --only hosting
```

---

## 1. La mezcla de `sprint-3` a `master`

```powershell
git checkout master
git pull
git merge --no-ff sprint-3 -m "Sprint 3: cierre, mezcla a master"
git tag -a v3.0 -m "BayStream Sprint 3"
git push origin master
git push origin v3.0
```

- `--no-ff` conserva el histórico del sprint en un commit de mezcla.
- Si Git marca conflictos (no debería, las ramas comparten `.gitattributes`), para y
  avísame antes de resolver.
- El repo privado es `YovaWarrior/Proyecto-BayStream`. El repo público de portafolio
  (`YovaWarrior/BayStream`) no recibe código.

## 2. El despliegue

Compila los tres clientes desde una copia limpia de `main` (ya con el código del
cierre), con la configuración privada y **sin abrir** `firebase-prod.json`.

### 2.1 La Web (Firebase Hosting)

```powershell
Set-Location -LiteralPath C:\Proyectos\proyecto-baystream
# 1. Aparta la caché vieja de la Web (2-oct, sin Firebase Auth ni voz). Ver 10.112.
$viejo = '.dart_tool\flutter_build\c00f0219d5d4c3dd1d45ce8ba5ce2f45'
if (Test-Path -LiteralPath $viejo) { Rename-Item -LiteralPath $viejo -NewName 'c00f0219d5d4c3dd1d45ce8ba5ce2f45-viejo-2oct' }
# 2. Compila limpio en build\web (el bloque de publicación de T-92)
$destino = [IO.Path]::GetFullPath('C:\Proyectos\proyecto-baystream\build\web')
if ($destino -ne 'C:\Proyectos\proyecto-baystream\build\web') { throw 'Destino de Hosting inesperado' }
if (Test-Path -LiteralPath $destino) { Remove-Item -LiteralPath $destino -Recurse -Force }
flutter build web --release --output=build/web --build-name=3.0.0 --build-number=3 --dart-define-from-file=C:\Proyectos\baystream-privado\firebase-prod.json
if ($LASTEXITCODE -ne 0) { throw 'No publicar: build fallido' }
# 3. Dos controles antes de publicar
if (-not (Select-String -LiteralPath build\web\main.dart.js -Pattern 'flutter-fire-auth' -SimpleMatch -Quiet)) { throw 'No publicar: la Web salio sin Firebase Auth' }
dart run tool/t92_verify.dart build/web
if ($LASTEXITCODE -ne 0) { throw 'No publicar: verificacion fallida' }
# 4. Solo Hosting
firebase deploy --only hosting --project baystream-app
```

- **Es el bloque de publicación de T-92** (`docs/T92-RESULTADOS.md`), más el control de
  Firebase Auth y sin `--no-pub`. La primera versión de esta guía lo había simplificado;
  esa compilación del 21-oct reusó una caché del 2-oct y la Web salió sin inicio de
  sesión (10.112).
- Borra solo `build\web` (con la ruta verificada), así que también salen los viejos
  `t54-format.*`. `firebase.json` sirve `build/web`.
- Después, abre `https://baystream-app.web.app` en una ventana nueva y confirma que es
  la versión del Sprint 3. **Limitación conocida (10.48):** quien ya visitó el sitio
  puede ver una vez la versión anterior por el *service worker*; recargar la resuelve.

### 2.2 El instalador de Windows (MSIX)

```powershell
$h = @(Get-ChildItem Cert:\CurrentUser\My | Where-Object Subject -eq 'CN=BayStream')
$h.Count   # tiene que dar 1
powershell -NoProfile -ExecutionPolicy Bypass -File tool\t93_msix.ps1 -Huella $h[0].Thumbprint -Version 3.0.0.0
```

- **Siempre con `tool\t93_msix.ps1`, nunca con `dart run msix:create` a secas.** Sin la huella,
  la herramienta firma con su certificado de prueba (`CN=Msix Testing`) y Windows rechaza el
  paquete con el error `0x800B010A`. Pasó el 21-oct (10.111).
- El script compila Release con las opciones de Firebase, firma con tu certificado de usuario
  `CN=BayStream` por su huella, sin exportar la clave, y termina verificando que la firma
  sea `Valid`. Si la Release ya se compiló con esas opciones, agrega `-SinCompilar`.
- Sale `build\t93\BayStream_3.0.0.0.msix`. Cada arreglo posterior sube la versión
  (3.0.1.0, 3.1.0.0…), o Windows no lo instala encima.
- Prueba el `.msix` resultante en una instalación limpia antes de distribuirlo.

### 2.3 Android (prueba interna de Play)

```powershell
flutter build appbundle --release --build-name=3.0.0 --build-number=3 --dart-define-from-file=C:\Proyectos\baystream-privado\firebase-prod.json
```

- **Con `--build-number=3`:** el AAB del Sprint 2 (T-49) ya usó el `versionCode` 1, y Play
  rechaza un número repetido. Cada subida posterior sube el número (10.112).

- **Sin `--no-pub`** (10.86): con `integration_test` en el `pubspec`, el `--no-pub`
  rompe el registrante de plugins. El comando de `docs/T47-RESULTADOS.md` (línea 36) lo
  lleva; para este release, quítaselo.
- Sube el `.aab` a la **prueba interna** de Google Play, como en el Sprint 2 (T-49).
  Producción queda fuera.

## 3. Antes de la entrega

- **T113-11 (los registros de auditoría):** mira en la consola de `baystream-app`,
  Registros → Registros de auditoría, si está activo, o se declara como limitación en
  el documento (10.109). Es Baja.
- **El documento del Incremento 3 y la presentación corta:** los prepara Yov, con los
  dictámenes finales de los RNF (T-98 y T-99), el pentest pendiente del cierre y el
  estado del despliegue.

## 4. Orden sugerido (22-23 oct)

1. La mezcla a `main` y la etiqueta `v3.0`.
2. La Web, con su verificación.
3. El MSIX firmado, probado en limpio.
4. El AAB subido a la prueba interna.
5. El documento y la presentación (Yov), ya con el despliegue confirmado.
