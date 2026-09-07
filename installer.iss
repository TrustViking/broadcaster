#ifndef MyAppVersion
#define MyAppVersion "0.2.0"
#endif

#ifndef IncludeSecrets
#define IncludeSecrets 0
#endif

#ifndef SecretsSource
#define SecretsSource ""
#endif

#ifndef SourceDir
#define SourceDir "dist\broadcaster"
#endif

#ifndef OutputDir
#define OutputDir "dist\installer"
#endif

#ifndef OutputBaseFilename
#define OutputBaseFilename "broadcaster-setup-" + MyAppVersion
#endif

[Setup]
AppName=Broadcaster
AppId={{B6A4F2C0-7D33-4F8A-9D9E-B0ADC0010001}}
AppPublisher=Vi0rel
AppVersion={#MyAppVersion}
DefaultDirName={autopf}\Broadcaster
PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=dialog commandline
DisableDirPage=no
DisableProgramGroupPage=yes
OutputBaseFilename={#OutputBaseFilename}
OutputDir={#OutputDir}
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
SetupIconFile={#SourceDir}\ico_code.ico
UninstallDisplayIcon={app}\broadcaster.exe
UninstallDisplayName=Broadcaster
ArchitecturesInstallIn64BitMode=x64compatible
CloseApplications=force
RestartIfNeededByRun=no

[Files]
Source: "{#SourceDir}\broadcaster.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#SourceDir}\run_debug.bat"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#SourceDir}\ico_code.ico"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#SourceDir}\_internal\*"; DestDir: "{app}\_internal"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "{#SourceDir}\tools\*"; DestDir: "{app}\tools"; Flags: ignoreversion recursesubdirs createallsubdirs skipifsourcedoesntexist
Source: "{#SourceDir}\config\app_config.example.yaml"; DestDir: "{app}\config"; Flags: ignoreversion
Source: "{#SourceDir}\config\README.txt"; DestDir: "{app}\config"; Flags: ignoreversion onlyifdoesntexist skipifsourcedoesntexist
Source: "{#SourceDir}\secrets\README.txt"; DestDir: "{app}\secrets"; Flags: ignoreversion onlyifdoesntexist skipifsourcedoesntexist
Source: "{#SourceDir}\config\templates.yaml"; DestDir: "{app}\config"; Flags: ignoreversion
Source: "{#SourceDir}\config\app_config.yaml"; DestDir: "{app}\config"; Flags: ignoreversion onlyifdoesntexist skipifsourcedoesntexist
Source: "{#SourceDir}\secrets\.env.example"; DestDir: "{app}\secrets"; Flags: ignoreversion onlyifdoesntexist skipifsourcedoesntexist
#if IncludeSecrets
Source: "{#SecretsSource}\.env"; DestDir: "{app}\secrets"; Flags: ignoreversion onlyifdoesntexist skipifsourcedoesntexist
Source: "{#SecretsSource}\token.json"; DestDir: "{app}\secrets"; Flags: ignoreversion onlyifdoesntexist skipifsourcedoesntexist
Source: "{#SecretsSource}\credentials.json"; DestDir: "{app}\secrets"; Flags: ignoreversion onlyifdoesntexist skipifsourcedoesntexist
Source: "{#SecretsSource}\service_account.json"; DestDir: "{app}\secrets"; Flags: ignoreversion onlyifdoesntexist skipifsourcedoesntexist
Source: "{#SecretsSource}\cookies.txt"; DestDir: "{app}\secrets"; Flags: ignoreversion onlyifdoesntexist skipifsourcedoesntexist
#endif

[Dirs]
Name: "{app}\state"
Name: "{app}\logs"

[Icons]
Name: "{autodesktop}\Broadcaster"; Filename: "{app}\run_debug.bat"; IconFilename: "{app}\ico_code.ico"; WorkingDir: "{app}"
