; T-137 · Asistente de BayStream. Se arma desde tool/t137_instalador.dart.
; ISCC 7.1.1; el include se genera con archivos de la compilación y el arte.
; No hay acceso al almacén, desinstalación de MSIX ni instalación de runtimes.
#define T137Include GetEnv("T137_INCLUDE")
#if T137Include == ""
  #error Armar con tool/t137_instalador.dart; falta T137_INCLUDE.
#endif
#include T137Include
#if GetVersionNumbersString(T137AppDir + "\baystream.exe") != T137Version
  #error El recurso de version del ejecutable cambio durante la preparacion.
#endif
#if T137Variante != "produccion" && T137Variante != "prueba"
  #error Variante T-137 desconocida.
#endif
; T-145 (O-137-7b): el ensayo de la consulta colgada solo existe en la prueba.
#if T137Ensayo != "" && T137Ensayo != "msix-colgada"
  #error Ensayo T-145 desconocido.
#endif
#if T137Ensayo != "" && T137Variante != "prueba"
  #error El ensayo T-145 solo se arma con la variante de prueba.
#endif
#if T137Variante == "produccion" || T137Ensayo == "msix-colgada"
  #define T145ConsultaMsix
#endif
; Espera máxima de la consulta de la MSIX, en milisegundos.
#define T145LimiteMsixMs 30000

[Setup]
; El GUID viene de las dos constantes permanentes del programa de armado.
AppId={{{#T137AppId}}
AppName={#T137AppName}
AppVersion={#T137Version}
AppVerName={#T137AppName} {#T137Version}
AppPublisher={#T137Publisher}
VersionInfoVersion={#T137Version}
VersionInfoCompany={#T137Publisher}
VersionInfoProductName={#T137AppName}
VersionInfoDescription=Asistente de instalación de {#T137AppName}
SetupArchitecture=x64
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
MinVersion=10.0
PrivilegesRequired=lowest
DefaultDirName={localappdata}\Programs\{#T137Carpeta}
DefaultGroupName={#T137AppName}
DisableProgramGroupPage=yes
AllowNoIcons=no
DisableDirPage=no
DisableWelcomePage=no
DisableReadyPage=yes
DisableFinishedPage=no
UsePreviousAppDir=yes
UsePreviousTasks=yes
CloseApplications=yes
CloseApplicationsFilter=*.exe,*.dll
RestartApplications=no
Uninstallable=yes
UninstallDisplayName={#T137AppName}
UninstallDisplayIcon={app}\baystream.exe
SetupIconFile={#T137Icono}
SignedUninstaller=no
SetupLogging=yes
WizardStyle=modern dynamic
WizardBackColor={#T137PapelClaro}
WizardBackColorDynamicDark={#T137PapelOscuro}
WizardImageBackColor={#T137PapelClaro}
WizardImageBackColorDynamicDark={#T137PapelOscuro}
WizardSmallImageBackColor={#T137PapelClaro}
WizardSmallImageBackColorDynamicDark={#T137PapelOscuro}
WizardImageFile={#T137GrandesClaro}
WizardImageFileDynamicDark={#T137GrandesOscuro}
WizardSmallImageFile={#T137PequenasClaro}
WizardSmallImageFileDynamicDark={#T137PequenasOscuro}
WizardImageStretch=yes
OutputDir={#T137Salida}
OutputBaseFilename={#T137NombreSalida}
OutputManifestFile={#T137NombreSalida}.inno-manifiesto.txt
Compression=lzma2
SolidCompression=yes

[Languages]
Name: "spanish"; MessagesFile: "compiler:Languages\Spanish.isl"

[Messages]
WelcomeLabel1=Bienvenido a {#T137AppName}
WelcomeLabel2=BayStream lee el BAPLIE y muestra el plano de estiba, para la oficina y el muelle.%n%nEste asistente instalará {#T137AppName} {#T137Version} solo para tu cuenta de Windows, sin pedir permisos de administrador.%n%nA continuación verás qué se instala y la tecnología que lo hace posible.
ClickNext=Pulsa Siguiente para continuar o Cancelar para salir de la instalación.
BrowseDialogLabel=Elige una carpeta y pulsa Aceptar.
ExitSetupMessage=La instalación no se ha completado aún. Si cancelas ahora, el programa no se instalará.%n%nPuedes ejecutar nuevamente el asistente para completar la instalación.%n%n¿Quieres salir de la instalación?
WizardSelectDir=Elige la carpeta de destino
SelectDirDesc=La carpeta y los accesos
SelectDirLabel3=BayStream se instalará en esta carpeta. El acceso en Inicio se crea siempre.
SelectDirBrowseLabel=Elige la carpeta y, si lo deseas, un acceso en el escritorio. Después pulsa Instalar.
DirExists=La carpeta:%n%n%1%n%nya existe. ¿Quieres instalar en esa carpeta de todas formas?
DirDoesntExist=La carpeta:%n%n%1%n%nno existe. ¿Quieres crearla?
WizardReady=Listo para instalar
ReadyLabel1=El asistente está listo para instalar [name] en tu equipo.
ReadyLabel2a=Pulsa Instalar para continuar o Atrás si quieres revisar o cambiar la configuración.
ReadyLabel2b=Pulsa Instalar para continuar.
WizardPreparing=Preparando la instalación
PreparingDesc=El asistente está preparando la instalación de [name] en tu equipo.
ApplicationsFound=Las siguientes aplicaciones están usando archivos que deben actualizarse. Te recomendamos dejar que el asistente las cierre automáticamente.
InstallingLabel=Espera mientras se instala [name] en tu equipo.
FinishedHeadingLabel={#T137AppName} está listo
FinishedLabelNoIcons=La instalación de [name] terminó correctamente en tu equipo.
ClickFinish=Pulsa Finalizar para cerrar el asistente.
FinishedRestartLabel=Para completar la instalación de [name], necesitas reiniciar Windows. ¿Quieres reiniciar ahora?
FinishedRestartMessage=Para completar la instalación de [name], necesitas reiniciar Windows.%n%n¿Quieres reiniciar ahora?
#if T137Variante == "prueba"
FinishedLabel=La variante de prueba quedó instalada.%n%nNo abras esta app en la cuenta de Carlos: usaría el almacén real. Esta variante es solo para aceptación T-137 y nunca se publica.
#else
FinishedLabel=Ya puedes abrir BayStream desde Inicio o desde este asistente.%n%nTus datos se guardan aparte, en %LOCALAPPDATA%\BayStream. Desinstalar la aplicación los conserva.
#endif
ConfirmUninstall=¿Seguro que quieres desinstalar %1? Tus datos en %LOCALAPPDATA%\BayStream se conservan.
UninstallStatusLabel=Espera mientras se desinstala %1 de tu equipo.
UninstalledAll=%1 se desinstaló correctamente.%n%nTus datos permanecen en %LOCALAPPDATA%\BayStream. El desinstalador no los borra.
UninstalledMost=La desinstalación de %1 terminó, aunque Windows no pudo quitar algunos archivos de la aplicación.%n%nTus datos permanecen en %LOCALAPPDATA%\BayStream. El desinstalador no los borra.
UninstalledAndNeedsRestart=Para completar la desinstalación de %1, reinicia Windows.%n%nTus datos permanecen en %LOCALAPPDATA%\BayStream. El desinstalador no los borra.%n%n¿Deseas reiniciar ahora?

[Tasks]
; Se muestra en la misma página que la carpeta. Se conserva el mecanismo
; nativo de tareas, incluida la opción /TASKS=escritorio en aceptación.
Name: "escritorio"; Description: "Crear un acceso en el escritorio"; Flags: unchecked

[Files]
Source: "{#T137AppDir}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[InstallDelete]
; T-145 (O-137-6, 10.130): restos de compilación que traía el asistente
; 1.0.0.9 de T-137 y que la carga ya no lleva. Al instalar encima se quitan.
; Nombres exactos y solo en {app}: nunca comodines ni otra carpeta. La lista
; es la de _excluidos en tool/t137_instalador.dart, que la comprueba.
Type: files; Name: "{app}\baystream.exp"
Type: files; Name: "{app}\baystream.lib"
Type: files; Name: "{app}\cloud_firestore_plugin.lib"
Type: files; Name: "{app}\firebase_auth_plugin.lib"
Type: files; Name: "{app}\firebase_core_plugin.lib"

[Icons]
Name: "{userprograms}\{#T137AppName}"; Filename: "{app}\baystream.exe"; WorkingDir: "{app}"; IconFilename: "{app}\baystream.exe"
Name: "{userdesktop}\{#T137AppName}"; Filename: "{app}\baystream.exe"; WorkingDir: "{app}"; IconFilename: "{app}\baystream.exe"; Tasks: escritorio

[Run]
; La variante de prueba no contiene ninguna orden de abrir BayStream.
#if T137Variante == "produccion"
Filename: "{app}\baystream.exe"; Description: "Abrir BayStream"; WorkingDir: "{app}"; Flags: nowait postinstall skipifsilent unchecked
#endif

[UninstallDelete]
; Nunca filesandordirs ni rutas del almacén. Solo retira la carpeta si está
; vacía después de quitar los archivos que registra el motor de Inno.
Type: dirifempty; Name: "{app}"

[Code]
var
  QuePagina: TWizardPage;
  DetrasPagina: TWizardPage;
  QueTexto: TNewMemo;
  DetrasTexto: TNewMemo;
  AccesoEscritorio: TNewCheckBox;
#ifdef T145ConsultaMsix
  ConsultasMsix: Integer;
#endif

{ T-145: WMI por COM, sin PowerShell. Lo usan el límite de la consulta de
  la MSIX (O-137-7b) y el desinstalador (O-137-8). }
function ServicioWmi: Variant;
var
  Localizador: Variant;
begin
  Localizador := CreateOleObject('WbemScripting.SWbemLocator');
  Result := Localizador.ConnectServer('.', 'root\CIMV2');
end;

#ifdef T145ConsultaMsix
function ComillaPs(Texto: String): String;
begin
  Result := Texto;
  StringChangeEx(Result, '''', '''''', True);
end;

{ Termina el PowerShell de la consulta vencida, buscado por la ruta única de
  su resultado en la línea de comandos. Nunca toca otro proceso.
  1: terminado; 0: ya no estaba; -1: WMI falló. }
function TerminarConsulta(const Marca: String): Integer;
var
  Servicio, Lista, Proceso: Variant;
  I, Cantidad: Integer;
  Linea: String;
begin
  Result := 0;
  try
    Servicio := ServicioWmi;
    Lista := Servicio.ExecQuery('SELECT * FROM Win32_Process WHERE Name = ''powershell.exe''');
    Cantidad := Lista.Count;
    for I := 0 to Cantidad - 1 do begin
      Proceso := Lista.ItemIndex(I);
      if not VarIsNull(Proceso.CommandLine) then begin
        Linea := Proceso.CommandLine;
        if Pos(Marca, Linea) > 0 then begin
          Proceso.Terminate(0);
          Result := 1;
        end;
      end;
    end;
  except
    Log('T145_WMI_FALLO: ' + GetExceptionMessage);
    Result := -1;
  end;
end;
#endif

function ErrorMsix: String;
#ifdef T145ConsultaMsix
var
  Codigo, Espera, Terminada: Integer;
  Comando, Resultado, Parcial: String;
  Lectura: AnsiString;
#endif
begin
  Result := '';
#ifdef T145ConsultaMsix
  { Solo el registro de paquetes de esta cuenta; sin -AllUsers ni cambios.
    T-145 (O-137-7b): Exec no tiene límite de tiempo. PowerShell corre sin
    esperar y deja su código en un archivo de la carpeta temporal del
    asistente; si no llega a tiempo,
    el asistente termina esa consulta y se detiene antes de copiar nada. }
  ConsultasMsix := ConsultasMsix + 1;
  Resultado := ExpandConstant('{tmp}\t145-msix-') + IntToStr(ConsultasMsix) + '.txt';
  Parcial := Resultado + '.part';
  Comando := '-NoLogo -NoProfile -NonInteractive -Command "' +
    '$ErrorActionPreference = ''Stop''; $c = 20; try { ' +
#if T137Ensayo == "msix-colgada"
    'Start-Sleep -Seconds 600; $c = 0 ' +
#else
    'if (@(Get-AppxPackage -Name ''{#T137IdentidadMsix}'' ' +
    '-ErrorAction Stop).Count -gt 0) { $c = 10 } else { $c = 0 } ' +
#endif
    '} catch { $c = 20 }; ' +
    '[IO.File]::WriteAllText(''' + ComillaPs(Parcial) + ''', [string]$c); ' +
    'Move-Item -LiteralPath ''' + ComillaPs(Parcial) + ''' -Destination ''' +
    ComillaPs(Resultado) + '''; exit $c"';
  if not Exec(ExpandConstant('{sys}\WindowsPowerShell\v1.0\powershell.exe'),
      Comando, ExpandConstant('{tmp}'), SW_HIDE, ewNoWait, Codigo) then
    Result := 'No se pudo comprobar si BayStream está instalado como MSIX.'#13#10#13#10 +
      'Cierra el asistente y vuelve a intentarlo. No se copió ningún archivo de la aplicación.'
  else begin
    Espera := 0;
    while (not FileExists(Resultado)) and (Espera < {#T145LimiteMsixMs}) do begin
      Sleep(100);
      Espera := Espera + 100;
    end;
    Codigo := 20;
    if FileExists(Resultado) then begin
      if LoadStringFromFile(Resultado, Lectura) then
        Codigo := StrToIntDef(Trim(String(Lectura)), 20);
    end else begin
      Terminada := TerminarConsulta(Resultado);
      if Terminada = 0 then
        Log('T145_MSIX_SIN_RESULTADO: la consulta terminó sin dejar su código.')
      else begin
        if Terminada = 1 then
          Log('T145_MSIX_TERMINADA: la consulta superó el límite y se terminó.')
        else
          Log('T145_MSIX_NO_TERMINADA: la consulta superó el límite y no se pudo terminar.');
        Result := 'Windows no respondió en {#T145LimiteMsixMs / 1000} segundos si BayStream ' +
          'está instalado como paquete MSIX, y el asistente se detuvo para no ' +
          'instalar en la duda.'#13#10#13#10 +
          'Cierra el asistente y vuelve a intentarlo. Si se repite, reinicia Windows ' +
          'y prueba otra vez. No se copió ningún archivo de la aplicación.';
      end;
    end;
  end;
  if Result = '' then begin
  if Codigo = 10 then
    Result := 'BayStream ya está instalado como paquete MSIX en esta cuenta, ' +
      'y este asistente no lo reemplaza.'#13#10#13#10 +
      'Para saber dónde están tus datos, abre %LOCALAPPDATA%\Packages en el Explorador ' +
      'y entra en la carpeta que empieza por gt.cmartinez.baystream, después en ' +
      'LocalCache y en Local. Si ahí hay una carpeta BayStream, tus datos están dentro ' +
      'del paquete y se borran con él: si los necesitas, sigue con la MSIX. Si no la hay, ' +
      'están en %LOCALAPPDATA%\BayStream y se quedan al desinstalar la MSIX.'#13#10#13#10 +
      'Para cambiar al asistente: si tienes operaciones publicadas, abre cada una en ' +
      'BayStream y espera a que diga «Al día». Después desinstala BayStream en ' +
      'Configuración > Aplicaciones y abre este asistente otra vez.'#13#10#13#10 +
      'Este asistente no desinstala la MSIX y no copió archivos de la aplicación.'
  else if Codigo <> 0 then
    Result := 'Windows no pudo completar la consulta del paquete MSIX.'#13#10#13#10 +
      'Cierra el asistente y vuelve a intentarlo. No se copió ningún archivo de la aplicación.';
  end;
#endif
  if Result <> '' then Log('T137_BLOQUEO_MSIX: ' + Result);
end;

function InitializeSetup: Boolean;
var
  Mensaje: String;
begin
  Mensaje := ErrorMsix;
  Result := Mensaje = '';
  if not Result then
    SuppressibleMsgBox(Mensaje, mbCriticalError, MB_OK, IDOK);
end;

function RutasRelacionadas(A, B: String): Boolean;
begin
  A := AddBackslash(ExpandFileName(A));
  B := AddBackslash(ExpandFileName(B));
  Result := (CompareText(Copy(A, 1, Length(B)), B) = 0) or
    (CompareText(Copy(B, 1, Length(A)), A) = 0);
end;

function ErrorCarpeta: String;
var
  Carpeta, OtraInstalacion: String;
begin
  Result := '';
  Carpeta := WizardDirValue;
  { No se permite elegir el almacén, un hijo ni un padre suyo como destino. }
  if RutasRelacionadas(Carpeta, ExpandConstant('{localappdata}\BayStream')) then
    Result := 'Elige otra carpeta: la instalación debe quedar separada de ' +
      '%LOCALAPPDATA%\BayStream, donde viven tus datos.'
  else if RutasRelacionadas(Carpeta,
      ExpandConstant('{localappdata}\Programs\{#T137OtraCarpeta}')) then
    Result := 'Elige otra carpeta: BayStream y la variante de prueba T-137 ' +
      'deben instalarse por separado.'
  else if RegQueryStringValue(HKCU,
      'Software\Microsoft\Windows\CurrentVersion\Uninstall\{{#T137OtroAppId}}_is1',
      'InstallLocation', OtraInstalacion) then begin
    if (OtraInstalacion <> '') and RutasRelacionadas(Carpeta, OtraInstalacion) then
      Result := 'Elige otra carpeta: ahí está instalada la otra variante de BayStream.';
  end;
  if Result <> '' then Log('T137_CARPETA_RECHAZADA: ' + Result);
end;

function PrepararTexto(Pagina: TWizardPage): TNewMemo;
begin
  Result := TNewMemo.Create(Pagina);
  Result.Parent := Pagina.Surface;
  Result.SetBounds(0, 0, Pagina.SurfaceWidth, Pagina.SurfaceHeight);
  Result.Anchors := [akLeft, akTop, akRight, akBottom];
  Result.ReadOnly := True;
  Result.BorderStyle := bsNone;
  Result.ScrollBars := ssVertical;
  Result.WordWrap := True;
  Result.WantReturns := False;
  Result.TabStop := True;
  { Los estilos nativos mantienen sus controles y el alto contraste. }
  if not HighContrastActive then begin
    if IsDarkInstallMode then begin
      Result.Color := {#T137PapelOscuroBgr};
      Result.Font.Color := {#T137TintaOscuroBgr};
    end else begin
      Result.Color := {#T137PapelClaroBgr};
      Result.Font.Color := {#T137TintaClaroBgr};
    end;
  end;
end;

procedure ActualizarQueSeInstala;
begin
  QueTexto.Text :=
    '{#T137AppName} {#T137Version}, para Windows de 64 bits.'#13#10#13#10 +
    'Carpeta de la aplicación:'#13#10 + WizardDirValue + #13#10#13#10 +
    'Tus datos viven aparte, en %LOCALAPPDATA%\BayStream. ' +
    'El desinstalador quita la aplicación y sus accesos, pero nunca tus datos.'#13#10#13#10 +
    'El runtime de Visual C++ acompaña al ejecutable dentro de esa carpeta. ' +
    'No se instala en el sistema.'#13#10#13#10 +
    'Esta instalación es solo para tu cuenta y no pide permisos de administrador.';
end;

procedure InitializeWizard;
var
  AccesoInicio: TNewStaticText;
begin
  QuePagina := CreateCustomPage(wpWelcome, 'Qué se instala',
    'La aplicación y tus datos, cada uno en su lugar');
  QueTexto := PrepararTexto(QuePagina);
  DetrasPagina := CreateCustomPage(QuePagina.ID, 'Lo que hay detrás',
    'La tecnología que mueve BayStream');
  DetrasTexto := PrepararTexto(DetrasPagina);
  DetrasTexto.Text :=
    'Flutter {#T137Flutter} y Dart {#T137Dart}.'#13#10#13#10 +
    'Firebase: cloud_firestore {#T137Firestore}, firebase_core {#T137FirebaseCore} ' +
    'y SDK de C++ {#T137FirebaseCpp}.'#13#10#13#10 +
    'Lector de archivos BAPLIE/EDIFACT 2.2.1 para interpretar el plano de estiba.'#13#10#13#10 +
    'Clean Architecture con Riverpod {#T137Riverpod}.'#13#10#13#10 +
    'Proyecto de graduación de Carlos Martínez · Universidad Mariano Gálvez de Guatemala';
  AccesoInicio := TNewStaticText.Create(WizardForm);
  AccesoInicio.Parent := WizardForm.SelectDirPage;
  AccesoInicio.Left := WizardForm.DirEdit.Left;
  AccesoInicio.Top := WizardForm.DirEdit.Top + WizardForm.DirEdit.Height + ScaleY(20);
  AccesoInicio.Width := WizardForm.DirEdit.Width;
  AccesoInicio.WordWrap := True;
  AccesoInicio.Caption := 'En Inicio: {#T137AppName} (siempre).';
  AccesoInicio.AdjustHeight;
  AccesoEscritorio := TNewCheckBox.Create(WizardForm);
  AccesoEscritorio.Parent := WizardForm.SelectDirPage;
  AccesoEscritorio.SetBounds(AccesoInicio.Left,
    AccesoInicio.Top + AccesoInicio.Height + ScaleY(12),
    WizardForm.SelectDirPage.ClientWidth - AccesoInicio.Left, ScaleY(22));
  AccesoEscritorio.Caption := 'Crear un acceso en el &escritorio';
  AccesoEscritorio.Checked := WizardIsTaskSelected('escritorio');
  ActualizarQueSeInstala;
end;

procedure CurPageChanged(CurPageID: Integer);
begin
  if CurPageID = QuePagina.ID then ActualizarQueSeInstala;
  if CurPageID = wpSelectDir then
    WizardForm.NextButton.Caption := SetupMessage(msgButtonInstall);
end;

function ShouldSkipPage(PageID: Integer): Boolean;
begin
  Result := PageID = wpSelectTasks;
end;

function NextButtonClick(CurPageID: Integer): Boolean;
var
  Mensaje: String;
begin
  Result := True;
  if CurPageID = wpSelectDir then begin
    Mensaje := ErrorCarpeta;
    Result := Mensaje = '';
    if not Result then
      SuppressibleMsgBox(Mensaje, mbError, MB_OK, IDOK)
    else if AccesoEscritorio.Checked then
      WizardSelectTasks('escritorio')
    else
      WizardSelectTasks('!escritorio');
  end;
end;

function PrepareToInstall(var NeedsRestart: Boolean): String;
begin
  { También cubre /VERYSILENT y una MSIX registrada mientras el asistente
    estaba abierto. Esta comprobación precede a cualquier copia de la app. }
  Result := ErrorCarpeta;
  if Result = '' then Result := ErrorMsix;
end;

{ T-145 (O-137-8): procesos que corren desde la carpeta de la aplicación,
  sin contar el desinstalador original, que sigue vivo mientras su copia en
  TEMP desinstala. La carpeta va con su barra final (10.130): BayStream\ no
  es el comienzo de BayStream-Prueba-T137\. False si WMI falló. }
function ProcesosDeLaApp(var Cantidad: Integer): Boolean;
var
  Servicio, Lista, Proceso: Variant;
  I, Total, Id: Integer;
  Carpeta, Ruta: String;
begin
  Cantidad := 0;
  Carpeta := AddBackslash(ExpandConstant('{app}'));
  try
    Servicio := ServicioWmi;
    Lista := Servicio.ExecQuery('SELECT ProcessId, ExecutablePath FROM Win32_Process');
    Total := Lista.Count;
    for I := 0 to Total - 1 do begin
      Proceso := Lista.ItemIndex(I);
      if not VarIsNull(Proceso.ExecutablePath) then begin
        Ruta := Proceso.ExecutablePath;
        if PathStartsWith(Ruta, Carpeta, True) and
           not WildcardMatch(LowerCase(ExtractFileName(Ruta)), 'unins*.exe') then begin
          Id := Proceso.ProcessId;
          Cantidad := Cantidad + 1;
          Log('T145_PROCESO_ABIERTO: ' + IntToStr(Id) + ' ' + Ruta);
        end;
      end;
    end;
    Result := True;
  except
    Log('T145_WMI_FALLO: ' + GetExceptionMessage);
    Result := False;
  end;
end;

{ Antes de quitar nada. Nunca cierra la app: pide cerrarla, con Reintentar y
  Cancelar. En silencio con /SUPPRESSMSGBOXES, Cancelar. }
function InitializeUninstall: Boolean;
var
  Cantidad, Boton: Integer;
  Abierta: Boolean;
begin
  Result := True;
  Abierta := False;
  while True do begin
    if not ProcesosDeLaApp(Cantidad) then begin
      Boton := SuppressibleTaskDialogMsgBox(
        'No se pudo comprobar si {#T137AppName} está abierta',
        'Si está abierta, ciérrala antes de seguir: mientras está abierta, ' +
        'Windows no deja quitar todos sus archivos.'#13#10#13#10 +
        'Pulsa Desinstalar para seguir o Cancelar para no desinstalar ahora. ' +
        'Tus datos en %LOCALAPPDATA%\BayStream no se tocan.',
        mbInformation, MB_OKCANCEL, ['Desinstalar', 'Cancelar'], 0, IDCANCEL);
      Result := Boton = IDOK;
      if not Result then Log('T145_DESINSTALAR_CANCELADO');
      Exit;
    end;
    if Cantidad = 0 then begin
      if Abierta then
        Log('T145_APP_CERRADA')
      else
        Log('T145_SIN_PROCESOS: ninguna instancia corre desde ' + ExpandConstant('{app}'));
      Exit;
    end;
    Abierta := True;
    Log('T145_APP_ABIERTA: ' + IntToStr(Cantidad) + ' proceso(s)');
    Boton := SuppressibleTaskDialogMsgBox(
      '{#T137AppName} está abierta',
      'Ciérrala para poder desinstalarla: mientras está abierta, Windows no ' +
      'deja quitar todos sus archivos.'#13#10#13#10 +
      'Cuando la hayas cerrado, pulsa Reintentar. Si prefieres no desinstalar ' +
      'ahora, pulsa Cancelar. Tus datos en %LOCALAPPDATA%\BayStream no se tocan.',
      mbInformation, MB_RETRYCANCEL, ['Reintentar', 'Cancelar'], 0, IDCANCEL);
    if Boton <> IDRETRY then begin
      Log('T145_DESINSTALAR_CANCELADO');
      Result := False;
      Exit;
    end;
  end;
end;

procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
begin
  if CurUninstallStep = usDone then
    Log('T137_DATOS_CONSERVADOS: el desinstalador no accede a %LOCALAPPDATA%\BayStream.');
end;
