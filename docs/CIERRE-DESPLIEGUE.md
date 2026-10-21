# Cierre del Sprint 3 · Guía de la mezcla y el despliegue

**Todo esto lo hace Carlos.** Yov redacta; Carlos ejecuta Git, Flutter, la firma y
Firebase. Base del release: el commit de cierre **`sprint3-cierre-2`** (su código es
el de T-112; `main` recibe exactamente eso al mezclar). Antes de nada, confirma que no
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

## 1. La mezcla de `sprint-3` a `main`

```powershell
git checkout main
git pull
git merge --no-ff sprint-3 -m "Sprint 3: cierre, mezcla a main"
git tag -a v3.0 -m "BayStream Sprint 3"
git push origin main
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
flutter build web --release --dart-define-from-file=C:\Proyectos\baystream-privado\firebase-prod.json
firebase deploy --only hosting
```

- `firebase.json` sirve `build/web`, así que compila al destino por defecto.
- Después, abre `https://baystream-app.web.app` en una ventana nueva y confirma que es
  la versión del Sprint 3. **Limitación conocida (10.48):** quien ya visitó el sitio
  puede ver una vez la versión anterior por el *service worker*; recargar la resuelve.

### 2.2 El instalador de Windows (MSIX)

```powershell
flutter build windows --release --dart-define-from-file=C:\Proyectos\baystream-privado\firebase-prod.json
dart run msix:create
```

- Lo firma tu certificado de usuario `CN=BayStream` (T-93). No exportes la clave.
- Prueba el `.msix` resultante en una instalación limpia antes de distribuirlo.

### 2.3 Android (prueba interna de Play)

```powershell
flutter build appbundle --release --dart-define-from-file=C:\Proyectos\baystream-privado\firebase-prod.json
```

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
