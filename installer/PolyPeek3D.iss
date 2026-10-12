; PolyPeek3D installer script (Inno Setup 6)
; Build:  build-release.bat  (or:  ISCC installer\PolyPeek3D.iss)
; The version comes from the VERSION file in the project root (build-release.bat also passes it as /DAppVer).
#ifndef AppVer
  #define VerFile FileOpen(AddBackslash(SourcePath) + "..\VERSION")
  #define AppVer Trim(FileRead(VerFile))
  #expr FileClose(VerFile)
  #undef VerFile
#endif

[Setup]
AppId={{6F0B1A52-3C4D-4B7E-9A1E-5D2C7E8F4A10}
AppName=PolyPeek3D
AppVersion={#AppVer}
AppVerName=PolyPeek3D {#AppVer}
AppPublisher=PolyPeek3D
VersionInfoVersion={#AppVer}
DefaultDirName={autopf}\PolyPeek3D
DefaultGroupName=PolyPeek3D
UninstallDisplayIcon={app}\PolyPeek3D.exe
SetupIconFile=..\icons\main.ico
OutputDir=..\release
OutputBaseFilename=PolyPeek3D-Setup-{#AppVer}
Compression=lzma2
SolidCompression=yes
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
; Always a per-user install (%LOCALAPPDATA%\Programs\PolyPeek3D): no admin rights, and the file associations
; (written to HKCU below) belong to the same user. There is no "install for all users" choice.
PrivilegesRequired=lowest
ChangesAssociations=yes
DisableProgramGroupPage=yes
WizardStyle=modern
LicenseFile=..\LICENSE

[Languages]
Name: "turkish"; MessagesFile: "compiler:Languages\Turkish.isl"
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "assoc"; Description: "{cm:AssocTask}"; GroupDescription: "{cm:AssocGroup}"
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; Flags: unchecked

[CustomMessages]
turkish.AssocTask=FBX, GLB, GLTF, OBJ, PLY, DAE, 3DS dosyalarını PolyPeek3D ile aç (varsayılan program)
turkish.AssocGroup=Dosya ilişkilendirme:
english.AssocTask=Open FBX, GLB, GLTF, OBJ, PLY, DAE, 3DS files with PolyPeek3D (default program)
english.AssocGroup=File associations:
turkish.NoWebView2=Bu bilgisayarda Microsoft Edge WebView2 Runtime bulunamadı. PolyPeek3D'nin çalışması için gereklidir (Windows 11'de hazır gelir).%n%nhttps://go.microsoft.com/fwlink/p/?LinkId=2124703 adresinden kurabilirsin.%n%nYine de devam edilsin mi?
english.NoWebView2=Microsoft Edge WebView2 Runtime was not found. PolyPeek3D needs it to run (it ships with Windows 11).%n%nInstall it from https://go.microsoft.com/fwlink/p/?LinkId=2124703%n%nContinue anyway?

[Files]
; release\app already holds LICENSE, THIRD-PARTY-NOTICES.txt and licenses\ (copied there by build-release.bat)
Source: "..\release\app\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[InstallDelete]
; left over from older versions (the JavaScript Draco fallback is no longer shipped)
Type: files; Name: "{app}\draco_decoder.js"

[Icons]
Name: "{autoprograms}\PolyPeek3D"; Filename: "{app}\PolyPeek3D.exe"
Name: "{autodesktop}\PolyPeek3D"; Filename: "{app}\PolyPeek3D.exe"; Tasks: desktopicon

[Registry]
; Keep the format table in step with install.reg and portable\Associate-Files.bat.
; The ".ext" default values are removed on uninstall by the [Code] section below, and only while they still point to PolyPeek3D.
Root: HKCU; Subkey: "Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.fbx\UserChoice"; Flags: deletekey; Tasks: assoc
Root: HKCU; Subkey: "Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.fbx\UserChoiceLatest"; Flags: deletekey; Tasks: assoc
Root: HKCU; Subkey: "Software\Classes\.fbx"; ValueType: string; ValueName: ""; ValueData: "PolyPeek3D.fbx"; Tasks: assoc
Root: HKCU; Subkey: "Software\Classes\.fbx\OpenWithProgids"; ValueType: string; ValueName: "PolyPeek3D.fbx"; ValueData: ""; Flags: uninsdeletevalue
Root: HKCU; Subkey: "Software\Classes\PolyPeek3D.fbx"; ValueType: string; ValueName: ""; ValueData: "FBX 3D Model"; Flags: uninsdeletekey
Root: HKCU; Subkey: "Software\Classes\PolyPeek3D.fbx\DefaultIcon"; ValueType: string; ValueName: ""; ValueData: "{app}\icons\fbx.ico"
Root: HKCU; Subkey: "Software\Classes\PolyPeek3D.fbx\shell\open\command"; ValueType: string; ValueName: ""; ValueData: """{app}\PolyPeek3D.exe"" ""%1"""
Root: HKCU; Subkey: "Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.glb\UserChoice"; Flags: deletekey; Tasks: assoc
Root: HKCU; Subkey: "Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.glb\UserChoiceLatest"; Flags: deletekey; Tasks: assoc
Root: HKCU; Subkey: "Software\Classes\.glb"; ValueType: string; ValueName: ""; ValueData: "PolyPeek3D.glb"; Tasks: assoc
Root: HKCU; Subkey: "Software\Classes\.glb\OpenWithProgids"; ValueType: string; ValueName: "PolyPeek3D.glb"; ValueData: ""; Flags: uninsdeletevalue
Root: HKCU; Subkey: "Software\Classes\PolyPeek3D.glb"; ValueType: string; ValueName: ""; ValueData: "GLB 3D Model"; Flags: uninsdeletekey
Root: HKCU; Subkey: "Software\Classes\PolyPeek3D.glb\DefaultIcon"; ValueType: string; ValueName: ""; ValueData: "{app}\icons\glb.ico"
Root: HKCU; Subkey: "Software\Classes\PolyPeek3D.glb\shell\open\command"; ValueType: string; ValueName: ""; ValueData: """{app}\PolyPeek3D.exe"" ""%1"""
Root: HKCU; Subkey: "Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.gltf\UserChoice"; Flags: deletekey; Tasks: assoc
Root: HKCU; Subkey: "Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.gltf\UserChoiceLatest"; Flags: deletekey; Tasks: assoc
Root: HKCU; Subkey: "Software\Classes\.gltf"; ValueType: string; ValueName: ""; ValueData: "PolyPeek3D.gltf"; Tasks: assoc
Root: HKCU; Subkey: "Software\Classes\.gltf\OpenWithProgids"; ValueType: string; ValueName: "PolyPeek3D.gltf"; ValueData: ""; Flags: uninsdeletevalue
Root: HKCU; Subkey: "Software\Classes\PolyPeek3D.gltf"; ValueType: string; ValueName: ""; ValueData: "glTF 3D Model"; Flags: uninsdeletekey
Root: HKCU; Subkey: "Software\Classes\PolyPeek3D.gltf\DefaultIcon"; ValueType: string; ValueName: ""; ValueData: "{app}\icons\gltf.ico"
Root: HKCU; Subkey: "Software\Classes\PolyPeek3D.gltf\shell\open\command"; ValueType: string; ValueName: ""; ValueData: """{app}\PolyPeek3D.exe"" ""%1"""
Root: HKCU; Subkey: "Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.obj\UserChoice"; Flags: deletekey; Tasks: assoc
Root: HKCU; Subkey: "Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.obj\UserChoiceLatest"; Flags: deletekey; Tasks: assoc
Root: HKCU; Subkey: "Software\Classes\.obj"; ValueType: string; ValueName: ""; ValueData: "PolyPeek3D.obj"; Tasks: assoc
Root: HKCU; Subkey: "Software\Classes\.obj\OpenWithProgids"; ValueType: string; ValueName: "PolyPeek3D.obj"; ValueData: ""; Flags: uninsdeletevalue
Root: HKCU; Subkey: "Software\Classes\PolyPeek3D.obj"; ValueType: string; ValueName: ""; ValueData: "OBJ 3D Model"; Flags: uninsdeletekey
Root: HKCU; Subkey: "Software\Classes\PolyPeek3D.obj\DefaultIcon"; ValueType: string; ValueName: ""; ValueData: "{app}\icons\obj.ico"
Root: HKCU; Subkey: "Software\Classes\PolyPeek3D.obj\shell\open\command"; ValueType: string; ValueName: ""; ValueData: """{app}\PolyPeek3D.exe"" ""%1"""
Root: HKCU; Subkey: "Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.ply\UserChoice"; Flags: deletekey; Tasks: assoc
Root: HKCU; Subkey: "Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.ply\UserChoiceLatest"; Flags: deletekey; Tasks: assoc
Root: HKCU; Subkey: "Software\Classes\.ply"; ValueType: string; ValueName: ""; ValueData: "PolyPeek3D.ply"; Tasks: assoc
Root: HKCU; Subkey: "Software\Classes\.ply\OpenWithProgids"; ValueType: string; ValueName: "PolyPeek3D.ply"; ValueData: ""; Flags: uninsdeletevalue
Root: HKCU; Subkey: "Software\Classes\PolyPeek3D.ply"; ValueType: string; ValueName: ""; ValueData: "PLY 3D Model"; Flags: uninsdeletekey
Root: HKCU; Subkey: "Software\Classes\PolyPeek3D.ply\DefaultIcon"; ValueType: string; ValueName: ""; ValueData: "{app}\icons\ply.ico"
Root: HKCU; Subkey: "Software\Classes\PolyPeek3D.ply\shell\open\command"; ValueType: string; ValueName: ""; ValueData: """{app}\PolyPeek3D.exe"" ""%1"""
Root: HKCU; Subkey: "Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.dae\UserChoice"; Flags: deletekey; Tasks: assoc
Root: HKCU; Subkey: "Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.dae\UserChoiceLatest"; Flags: deletekey; Tasks: assoc
Root: HKCU; Subkey: "Software\Classes\.dae"; ValueType: string; ValueName: ""; ValueData: "PolyPeek3D.dae"; Tasks: assoc
Root: HKCU; Subkey: "Software\Classes\.dae\OpenWithProgids"; ValueType: string; ValueName: "PolyPeek3D.dae"; ValueData: ""; Flags: uninsdeletevalue
Root: HKCU; Subkey: "Software\Classes\PolyPeek3D.dae"; ValueType: string; ValueName: ""; ValueData: "DAE 3D Model"; Flags: uninsdeletekey
Root: HKCU; Subkey: "Software\Classes\PolyPeek3D.dae\DefaultIcon"; ValueType: string; ValueName: ""; ValueData: "{app}\icons\dae.ico"
Root: HKCU; Subkey: "Software\Classes\PolyPeek3D.dae\shell\open\command"; ValueType: string; ValueName: ""; ValueData: """{app}\PolyPeek3D.exe"" ""%1"""
Root: HKCU; Subkey: "Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.3ds\UserChoice"; Flags: deletekey; Tasks: assoc
Root: HKCU; Subkey: "Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.3ds\UserChoiceLatest"; Flags: deletekey; Tasks: assoc
Root: HKCU; Subkey: "Software\Classes\.3ds"; ValueType: string; ValueName: ""; ValueData: "PolyPeek3D.3ds"; Tasks: assoc
Root: HKCU; Subkey: "Software\Classes\.3ds\OpenWithProgids"; ValueType: string; ValueName: "PolyPeek3D.3ds"; ValueData: ""; Flags: uninsdeletevalue
Root: HKCU; Subkey: "Software\Classes\PolyPeek3D.3ds"; ValueType: string; ValueName: ""; ValueData: "3DS 3D Model"; Flags: uninsdeletekey
Root: HKCU; Subkey: "Software\Classes\PolyPeek3D.3ds\DefaultIcon"; ValueType: string; ValueName: ""; ValueData: "{app}\icons\3ds.ico"
Root: HKCU; Subkey: "Software\Classes\PolyPeek3D.3ds\shell\open\command"; ValueType: string; ValueName: ""; ValueData: """{app}\PolyPeek3D.exe"" ""%1"""
Root: HKCU; Subkey: "Software\Classes\.stl\OpenWithProgids"; ValueType: string; ValueName: "PolyPeek3D.stl"; ValueData: ""; Flags: uninsdeletevalue
Root: HKCU; Subkey: "Software\Classes\PolyPeek3D.stl"; ValueType: string; ValueName: ""; ValueData: "STL 3D Model"; Flags: uninsdeletekey
Root: HKCU; Subkey: "Software\Classes\PolyPeek3D.stl\DefaultIcon"; ValueType: string; ValueName: ""; ValueData: "{app}\icons\stl.ico"
Root: HKCU; Subkey: "Software\Classes\PolyPeek3D.stl\shell\open\command"; ValueType: string; ValueName: ""; ValueData: """{app}\PolyPeek3D.exe"" ""%1"""
Root: HKCU; Subkey: "Software\Classes\.3mf\OpenWithProgids"; ValueType: string; ValueName: "PolyPeek3D.3mf"; ValueData: ""; Flags: uninsdeletevalue
Root: HKCU; Subkey: "Software\Classes\PolyPeek3D.3mf"; ValueType: string; ValueName: ""; ValueData: "3MF 3D Model"; Flags: uninsdeletekey
Root: HKCU; Subkey: "Software\Classes\PolyPeek3D.3mf\DefaultIcon"; ValueType: string; ValueName: ""; ValueData: "{app}\icons\generic.ico"
Root: HKCU; Subkey: "Software\Classes\PolyPeek3D.3mf\shell\open\command"; ValueType: string; ValueName: ""; ValueData: """{app}\PolyPeek3D.exe"" ""%1"""
Root: HKCU; Subkey: "Software\Classes\.amf\OpenWithProgids"; ValueType: string; ValueName: "PolyPeek3D.amf"; ValueData: ""; Flags: uninsdeletevalue
Root: HKCU; Subkey: "Software\Classes\PolyPeek3D.amf"; ValueType: string; ValueName: ""; ValueData: "AMF 3D Model"; Flags: uninsdeletekey
Root: HKCU; Subkey: "Software\Classes\PolyPeek3D.amf\DefaultIcon"; ValueType: string; ValueName: ""; ValueData: "{app}\icons\generic.ico"
Root: HKCU; Subkey: "Software\Classes\PolyPeek3D.amf\shell\open\command"; ValueType: string; ValueName: ""; ValueData: """{app}\PolyPeek3D.exe"" ""%1"""
Root: HKCU; Subkey: "Software\Classes\.stp\OpenWithProgids"; ValueType: string; ValueName: "PolyPeek3D.stp"; ValueData: ""; Flags: uninsdeletevalue
Root: HKCU; Subkey: "Software\Classes\PolyPeek3D.stp"; ValueType: string; ValueName: ""; ValueData: "STEP CAD Model"; Flags: uninsdeletekey
Root: HKCU; Subkey: "Software\Classes\PolyPeek3D.stp\DefaultIcon"; ValueType: string; ValueName: ""; ValueData: "{app}\icons\generic.ico"
Root: HKCU; Subkey: "Software\Classes\PolyPeek3D.stp\shell\open\command"; ValueType: string; ValueName: ""; ValueData: """{app}\PolyPeek3D.exe"" ""%1"""
Root: HKCU; Subkey: "Software\Classes\.step\OpenWithProgids"; ValueType: string; ValueName: "PolyPeek3D.step"; ValueData: ""; Flags: uninsdeletevalue
Root: HKCU; Subkey: "Software\Classes\PolyPeek3D.step"; ValueType: string; ValueName: ""; ValueData: "STEP CAD Model"; Flags: uninsdeletekey
Root: HKCU; Subkey: "Software\Classes\PolyPeek3D.step\DefaultIcon"; ValueType: string; ValueName: ""; ValueData: "{app}\icons\generic.ico"
Root: HKCU; Subkey: "Software\Classes\PolyPeek3D.step\shell\open\command"; ValueType: string; ValueName: ""; ValueData: """{app}\PolyPeek3D.exe"" ""%1"""

[UninstallDelete]
; everything PolyPeek3D keeps for this user: settings, window position, log, WebView2 data
Type: filesandordirs; Name: "{localappdata}\PolyPeek3D"

[Run]
Filename: "{app}\PolyPeek3D.exe"; Description: "{cm:LaunchProgram,PolyPeek3D}"; Flags: nowait postinstall skipifsilent

[Code]
function WebView2Installed(): Boolean;
var v: String;
begin
  Result :=
    (RegQueryStringValue(HKLM, 'SOFTWARE\WOW6432Node\Microsoft\EdgeUpdate\Clients\{F3017226-FE2A-4295-8BDF-00C3A9A7E4C5}', 'pv', v) and (v <> '') and (v <> '0.0.0.0')) or
    (RegQueryStringValue(HKCU, 'Software\Microsoft\EdgeUpdate\Clients\{F3017226-FE2A-4295-8BDF-00C3A9A7E4C5}', 'pv', v) and (v <> '') and (v <> '0.0.0.0'));
end;

function InitializeSetup(): Boolean;
begin
  Result := True;
  if not WebView2Installed() then
    Result := (MsgBox(CustomMessage('NoWebView2'), mbConfirmation, MB_YESNO) = IDYES);
end;

const
  FileExts = 'Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.';

// True if the key (or its "ProgId" subkey) has a ProgId value that points to PolyPeek3D
function PointsToUs(const Key: String): Boolean;
var v: String;
begin
  Result := (RegQueryStringValue(HKCU, Key, 'ProgId', v) and (Pos('PolyPeek3D', v) = 1)) or
            (RegQueryStringValue(HKCU, Key + '\ProgId', 'ProgId', v) and (Pos('PolyPeek3D', v) = 1));
end;

// Uninstall: remove the ".ext" default value and the user's "Always open with" choice, but only where they still
// point to PolyPeek3D (another program may have taken the format over since).
procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
var List, E, v: String; p: Integer;
begin
  if CurUninstallStep <> usPostUninstall then Exit;
  List := 'fbx,glb,gltf,obj,ply,dae,3ds,stl,3mf,amf,stp,step,';
  while List <> '' do begin
    p := Pos(',', List); E := Copy(List, 1, p - 1); Delete(List, 1, p);
    if RegQueryStringValue(HKCU, 'Software\Classes\.' + E, '', v) and (CompareText(v, 'PolyPeek3D.' + E) = 0) then
      RegDeleteValue(HKCU, 'Software\Classes\.' + E, '');
    if PointsToUs(FileExts + E + '\UserChoice') then RegDeleteKeyIncludingSubkeys(HKCU, FileExts + E + '\UserChoice');
    if PointsToUs(FileExts + E + '\UserChoiceLatest') then RegDeleteKeyIncludingSubkeys(HKCU, FileExts + E + '\UserChoiceLatest');
  end;
end;
