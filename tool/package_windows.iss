#define AppName "Sistem Antrean Satker"
#define AppExeName "sistem_antrean_satker.exe"
#define AppPublisher "ma-sum"
#define BuildDir "..\build\windows\x64\runner\Release"
#define DistDir "..\dist"

[Setup]
AppId={{D37F2C70-988B-4BBA-85D3-8E5A8F7F3B9A}
AppName={#AppName}
AppVersion={#AppVersion}
AppPublisher={#AppPublisher}
DefaultDirName={autopf}\{#AppName}
DisableProgramGroupPage=yes
OutputDir={#DistDir}
OutputBaseFilename=sistem_antrean_satker_setup
Compression=lzma
SolidCompression=yes
WizardStyle=modern

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "{#BuildDir}\{#AppExeName}"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#BuildDir}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
; VC++ Redistributables are expected to be in the build dir (copied by the workflow)
Source: "{#BuildDir}\msvcp140.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#BuildDir}\vcruntime140.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#BuildDir}\vcruntime140_1.dll"; DestDir: "{app}"; Flags: ignoreversion

[Icons]
Name: "{autoprograms}\{#AppName}"; Filename: "{app}\{#AppExeName}"
Name: "{autodesktop}\{#AppName}"; Filename: "{app}\{#AppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#AppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(AppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent
