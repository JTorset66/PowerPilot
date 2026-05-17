#define AppName "PowerPilot"
#define AppVersion "1.2.2605.23851"
#define AppExeName "PowerPilot_V1.2.2605.23851.exe"
#define AppSetupName "PowerPilot_V1.2.2605.23851_Setup.exe"
#define AppPublisher "Dofta"
#define AppURL "https://github.com/JTorset66/PowerPilot"
#define AppRunKey "PowerPilot"
#define AppIconName "powerpilot.ico"
#define AppDesktopIconName "powerpilot_desktop.ico"
#define AppId "{{88D96927-5B26-4DF8-8EE0-3BF9A49E56E3}"

[Setup]
AppId={#AppId}
AppName={#AppName}
AppVersion={#AppVersion}
AppPublisher={#AppPublisher}
AppPublisherURL={#AppURL}
AppSupportURL={#AppURL}
AppUpdatesURL={#AppURL}
AppVerName={#AppName} {#AppVersion}
DefaultDirName={autopf}\{#AppName}
DefaultGroupName={#AppName}
DisableWelcomePage=yes
DisableDirPage=yes
DisableProgramGroupPage=yes
DisableReadyPage=yes
OutputDir=build
OutputBaseFilename=PowerPilot_V1.2.2605.23851_Setup
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
SetupIconFile=powerpilot.ico
PrivilegesRequired=admin
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
UninstallDisplayName={#AppName}
UninstallDisplayIcon={app}\{#AppExeName}
CloseApplications=no
RestartApplications=no
VersionInfoCompany={#AppPublisher}
VersionInfoDescription=PowerPilot Setup
VersionInfoProductName={#AppName}
VersionInfoProductVersion={#AppVersion}

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Messages]
WelcomeLabel1=Welcome to PowerPilot
WelcomeLabel2=PowerPilot installs a local tray app that follows Windows power mode and starts hidden in the notification area.
FinishedHeadingLabel=PowerPilot is ready
FinishedLabelNoIcons=PowerPilot is installed and started hidden in the notification area. Open it from the tray icon or desktop shortcut. USER MANUAL, README, LICENSE, and THIRD-PARTY NOTICES are installed with the app.

[Files]
Source: "build\{#AppExeName}"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#AppIconName}"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#AppDesktopIconName}"; DestDir: "{app}"; Flags: ignoreversion
Source: "powerpilot_tray.ico"; DestDir: "{app}"; Flags: ignoreversion
Source: "USER_MANUAL.txt"; DestDir: "{app}"; DestName: "USER_MANUAL.txt"; Flags: ignoreversion
Source: "INSTALLER_README.md"; DestDir: "{app}"; DestName: "README.txt"; Flags: ignoreversion
Source: "THIRD_PARTY_NOTICES.md"; DestDir: "{app}"; DestName: "THIRD_PARTY_NOTICES.txt"; Flags: ignoreversion
Source: "LICENSE"; DestDir: "{app}"; DestName: "LICENSE.txt"; Flags: ignoreversion
Source: "USER_MANUAL.txt"; DestName: "PowerPilot_USER_MANUAL.txt"; Flags: dontcopy
Source: "INSTALLER_README.md"; DestName: "PowerPilot_README.txt"; Flags: dontcopy
Source: "THIRD_PARTY_NOTICES.md"; DestName: "PowerPilot_THIRD_PARTY_NOTICES.txt"; Flags: dontcopy
Source: "LICENSE"; DestName: "PowerPilot_LICENSE.txt"; Flags: dontcopy

[Icons]
Name: "{autodesktop}\{#AppName}"; Filename: "{app}\{#AppExeName}"; WorkingDir: "{app}"; IconFilename: "{app}\{#AppDesktopIconName}"

[InstallDelete]
Type: files; Name: "{app}\PowerPilotLibreHelper.exe"
Type: files; Name: "{app}\PowerPilotWindowsPmiHelper.exe"
Type: files; Name: "{app}\PowerPilotWindowsPerfHelper.exe"
Type: files; Name: "{app}\PowerPilotWindowsEmiHelper.exe"
Type: files; Name: "{app}\PowerPilotAmdAdlxHelper.exe"
Type: files; Name: "{app}\PowerPilotAmdAdlHelper.exe"
Type: files; Name: "{app}\powerpilot_desktop.ico"
Type: files; Name: "{app}\powerpilot_tray.png"
Type: files; Name: "{app}\USER_MANUAL.txt"
Type: files; Name: "{app}\README.md"
Type: files; Name: "{app}\THIRD_PARTY_NOTICES.md"
Type: files; Name: "{app}\LICENSE"
Type: filesandordirs; Name: "{app}\third_party\LibreHardwareMonitor"
Type: dirifempty; Name: "{app}\third_party"

[UninstallDelete]
Type: files; Name: "{app}\PowerPilot_V*.exe"
Type: files; Name: "{app}\{#AppSetupName}"
Type: files; Name: "{app}\PowerPilotWindowsPmiHelper.exe"
Type: files; Name: "{app}\PowerPilotWindowsPerfHelper.exe"
Type: files; Name: "{app}\PowerPilotWindowsEmiHelper.exe"
Type: files; Name: "{app}\PowerPilotAmdAdlxHelper.exe"
Type: files; Name: "{app}\PowerPilotAmdAdlHelper.exe"
Type: files; Name: "{app}\powerpilot_desktop.ico"
Type: files; Name: "{app}\powerpilot_tray.png"
Type: files; Name: "{app}\USER_MANUAL.txt"
Type: files; Name: "{app}\README.txt"
Type: files; Name: "{app}\THIRD_PARTY_NOTICES.txt"
Type: files; Name: "{app}\LICENSE.txt"
Type: files; Name: "{app}\LICENSE"
Type: filesandordirs; Name: "{app}\third_party\LibreHardwareMonitor"
Type: dirifempty; Name: "{app}\third_party"

[Code]
const
  UninstallRegSubkey = 'Software\Microsoft\Windows\CurrentVersion\Uninstall\{88D96927-5B26-4DF8-8EE0-3BF9A49E56E3}_is1';
  LegacyBrokenRegSubkey = 'Software\Microsoft\Windows\CurrentVersion\Uninstall\{{88D96927-5B26-4DF8-8EE0-3BF9A49E56E3}_is1';

var
  FrontPage: TWizardPage;

function GetCurrentProcessId(): Cardinal;
  external 'GetCurrentProcessId@kernel32.dll stdcall';

function QuoteValue(const Value: string): string;
begin
  Result := '"' + Value + '"';
end;

function PowerShellLiteral(const Value: string): string;
var
  Escaped: string;
begin
  Escaped := Value;
  StringChangeEx(Escaped, '''', '''''', True);
  Result := '''' + Escaped + '''';
end;

function MaintenanceMode: Boolean;
begin
  Result := ExpandConstant('{param:maintenance|0}') = '1';
end;

procedure AddFrontText(const Caption: string; Left, Top, Width, Height, FontSize: Integer; Bold: Boolean);
var
  Text: TNewStaticText;
begin
  Text := TNewStaticText.Create(FrontPage);
  Text.Parent := FrontPage.Surface;
  Text.AutoSize := False;
  Text.WordWrap := True;
  Text.Caption := Caption;
  Text.SetBounds(ScaleX(Left), ScaleY(Top), ScaleX(Width), ScaleY(Height));
  Text.Font.Size := FontSize;
  if Bold then
    Text.Font.Style := [fsBold];
end;

procedure OpenBundledTextFile(const FileName: string);
var
  ResultCode: Integer;
  TempPath: string;
begin
  ExtractTemporaryFile(FileName);
  TempPath := ExpandConstant('{tmp}\' + FileName);
  if not ShellExec('', TempPath, '', '', SW_SHOWNORMAL, ewNoWait, ResultCode) then
    MsgBox('PowerPilot Setup could not open ' + FileName + '.', mbError, MB_OK);
end;

procedure ManualButtonClick(Sender: TObject);
begin
  OpenBundledTextFile('PowerPilot_USER_MANUAL.txt');
end;

procedure ReadmeButtonClick(Sender: TObject);
begin
  OpenBundledTextFile('PowerPilot_README.txt');
end;

procedure LicenseButtonClick(Sender: TObject);
begin
  OpenBundledTextFile('PowerPilot_LICENSE.txt');
end;

procedure ThirdPartyButtonClick(Sender: TObject);
begin
  OpenBundledTextFile('PowerPilot_THIRD_PARTY_NOTICES.txt');
end;

procedure CreateFrontButton(const Caption: string; Left, Top, Width: Integer; OnClick: TNotifyEvent);
var
  Button: TNewButton;
begin
  Button := TNewButton.Create(FrontPage);
  Button.Parent := FrontPage.Surface;
  Button.Caption := Caption;
  Button.Left := ScaleX(Left);
  Button.Top := ScaleY(Top);
  Button.Width := ScaleX(Width);
  Button.Height := WizardForm.NextButton.Height;
  Button.OnClick := OnClick;
end;

procedure InitializeWizard;
begin
  FrontPage :=
    CreateCustomPage(
      wpWelcome,
      'Welcome to PowerPilot',
      'Review what setup will install before continuing.'
    );

  AddFrontText('PowerPilot follows Windows power mode and keeps its owned plans aligned.', 0, 0, 210, 40, 9, False);
  AddFrontText('Setup will:', 0, 52, 210, 18, 9, True);
  AddFrontText('- install the tray app and desktop shortcut' + #13 +
               '- refresh Maximum, Balanced, and Battery plans' + #13 +
               '- enable startup for this Windows user' + #13 +
               '- start PowerPilot hidden in the tray', 0, 76, 210, 90, 9, False);
  AddFrontText('Administrator approval is only for installation. Runtime stays under the signed-in user.', 0, 178, 210, 42, 9, False);

  AddFrontText('Bundled files', 230, 0, 180, 22, 10, True);
  AddFrontText('Open before installing. The same files are installed and available from About.', 230, 30, 180, 58, 8, False);
  CreateFrontButton('USER MANUAL', 230, 98, 180, @ManualButtonClick);
  CreateFrontButton('README', 230, 134, 180, @ReadmeButtonClick);
  CreateFrontButton('LICENSE', 230, 170, 180, @LicenseButtonClick);
  CreateFrontButton('THIRD-PARTY NOTICES', 230, 206, 180, @ThirdPartyButtonClick);
end;

function QueryUninstallValue(const ValueName: string; var Value: string): Boolean;
begin
  Result :=
    RegQueryStringValue(HKLM64, UninstallRegSubkey, ValueName, Value) or
    RegQueryStringValue(HKLM, UninstallRegSubkey, ValueName, Value);
end;

function InstalledUninstallerPath: string;
var
  InstallLocation: string;
begin
  Result := '';
  if QueryUninstallValue('InstallLocation', InstallLocation) then
    Result := AddBackslash(RemoveBackslashUnlessRoot(InstallLocation)) + 'unins000.exe';
end;

procedure WriteMaintenanceRegistry;
var
  MaintenanceCommand: string;
  QuietCommand: string;
begin
  MaintenanceCommand := QuoteValue(ExpandConstant('{app}\{#AppSetupName}')) + ' /maintenance=1';
  QuietCommand := QuoteValue(ExpandConstant('{app}\unins000.exe')) + ' /SILENT';

  RegDeleteKeyIncludingSubkeys(HKLM64, LegacyBrokenRegSubkey);
  RegDeleteKeyIncludingSubkeys(HKLM, LegacyBrokenRegSubkey);
  RegWriteStringValue(HKLM64, UninstallRegSubkey, 'ModifyPath', MaintenanceCommand);
  RegWriteStringValue(HKLM64, UninstallRegSubkey, 'UninstallString', MaintenanceCommand);
  RegWriteStringValue(HKLM64, UninstallRegSubkey, 'QuietUninstallString', QuietCommand);
  RegWriteDWordValue(HKLM64, UninstallRegSubkey, 'NoModify', 0);
  RegWriteDWordValue(HKLM64, UninstallRegSubkey, 'NoRepair', 0);
end;

procedure EnsureInstalledMaintenanceSetup;
var
  SourcePath: string;
  TargetPath: string;
begin
  SourcePath := ExpandConstant('{srcexe}');
  TargetPath := ExpandConstant('{app}\{#AppSetupName}');

  if CompareText(SourcePath, TargetPath) = 0 then
  begin
    Log('Setup already running from the installed maintenance path.');
    Exit;
  end;

  if CopyFile(SourcePath, TargetPath, False) then
    Log(Format('Copied maintenance setup: %s -> %s', [SourcePath, TargetPath]))
  else
    Log(Format('Failed to copy maintenance setup: %s -> %s', [SourcePath, TargetPath]));
end;

function LaunchInstalledUninstaller: Boolean;
var
  UninstallerPath: string;
  ResultCode: Integer;
begin
  Result := False;
  UninstallerPath := InstalledUninstallerPath();
  if (UninstallerPath = '') or (not FileExists(UninstallerPath)) then
  begin
    MsgBox('PowerPilot is not currently installed, so there is nothing to uninstall.', mbInformation, MB_OK);
    Exit;
  end;

  if Exec(UninstallerPath, '', '', SW_SHOWNORMAL, ewNoWait, ResultCode) then
    Result := True
  else
    MsgBox('PowerPilot could not start its uninstaller.', mbError, MB_OK);
end;

function InitializeSetup(): Boolean;
var
  Choice: Integer;
begin
  Result := True;

  if not MaintenanceMode() then
    Exit;

  Choice :=
    MsgBox(
      'PowerPilot maintenance:'#13#13 +
      'Yes = Repair install'#13 +
      'No = Uninstall'#13 +
      'Cancel = Exit without changes',
      mbConfirmation,
      MB_YESNOCANCEL
    );

  case Choice of
    IDYES:
      Result := True;
    IDNO:
      begin
        LaunchInstalledUninstaller();
        Result := False;
      end;
  else
    Result := False;
  end;
end;

function RunHiddenAndWait(const FileName, Params: string): Integer;
var
  ResultCode: Integer;
begin
  Log(Format('Executing: %s %s', [FileName, Params]));
  if Exec(FileName, Params, '', SW_HIDE, ewWaitUntilTerminated, ResultCode) then
  begin
    Log(Format('Executed: %s %s -> %d', [FileName, Params, ResultCode]));
    Result := ResultCode;
  end
  else
  begin
    Log(Format('Failed to execute: %s %s', [FileName, Params]));
    Result := -1;
  end;
end;

procedure RunHiddenNoWait(const FileName, Params: string);
var
  ResultCode: Integer;
begin
  if Exec(FileName, Params, '', SW_HIDE, ewNoWait, ResultCode) then
    Log(Format('Started: %s %s', [FileName, Params]))
  else
    Log(Format('Failed to start: %s %s', [FileName, Params]));
end;

procedure SetInstallStatus(const Caption: string);
begin
  WizardForm.StatusLabel.Caption := Caption;
  WizardForm.Refresh;
end;

procedure SetFinalInstallProgress(const Caption: string; Percent: Integer);
begin
  WizardForm.ProgressGauge.Max := 100;
  WizardForm.ProgressGauge.Position := Percent;
  SetInstallStatus(Caption);
end;

function RunAsOriginalUserAndWait(const FileName, Params: string): Integer;
var
  ResultCode: Integer;
begin
  Log(Format('Executing as original user: %s %s', [FileName, Params]));
  if ExecAsOriginalUser(FileName, Params, '', SW_HIDE, ewWaitUntilTerminated, ResultCode) then
  begin
    Log(Format('Executed as original user: %s %s -> %d', [FileName, Params, ResultCode]));
    Result := ResultCode;
  end
  else
  begin
    Log(Format('Failed to execute as original user: %s %s', [FileName, Params]));
    Result := -1;
  end;
end;

function PowerShellExePath: string;
begin
  Result := ExpandConstant('{sys}\WindowsPowerShell\v1.0\powershell.exe');
end;

function RunOriginalUserPowerShell(const Script: string): Integer;
begin
  Result := RunAsOriginalUserAndWait(PowerShellExePath(), '-NoProfile -ExecutionPolicy Bypass -Command ' + QuoteValue(Script));
end;

procedure RegisterStartupForOriginalUser;
var
  Script: string;
begin
  Script := '$q=[char]34; $cmd=$q + ' + PowerShellLiteral(ExpandConstant('{app}\{#AppExeName}')) + ' + $q + '' /startup''; ' +
            'New-Item -Path ''HKCU:\Software\Microsoft\Windows\CurrentVersion\Run'' -Force | Out-Null; ' +
            'Set-ItemProperty -Path ''HKCU:\Software\Microsoft\Windows\CurrentVersion\Run'' -Name ' +
            PowerShellLiteral('{#AppRunKey}') + ' -Value $cmd';
  if RunOriginalUserPowerShell(Script) = 0 then
    Log(Format('Registered startup for original user: %s /startup', [QuoteValue(ExpandConstant('{app}\{#AppExeName}'))]))
  else
    Log(Format('Failed to register startup for original user: %s /startup', [QuoteValue(ExpandConstant('{app}\{#AppExeName}'))]));
end;

procedure UnregisterStartupForOriginalUser;
var
  Script: string;
begin
  Script := 'Remove-ItemProperty -Path ''HKCU:\Software\Microsoft\Windows\CurrentVersion\Run'' -Name ' +
            PowerShellLiteral('{#AppRunKey}') + ' -ErrorAction SilentlyContinue';
  if RunOriginalUserPowerShell(Script) = 0 then
    Log('Removed startup entry for original user.')
  else
    Log('Failed to remove startup entry for original user.');
end;

function ShouldKeepSettingsOnReinstall: Boolean;
begin
  Result := RunAsOriginalUserAndWait(ExpandConstant('{app}\{#AppExeName}'), '/query-keep-settings') = 1;
  Log(Format('Keep settings on reinstall query -> %d', [Ord(Result)]));
end;

procedure StopRunningPowerPilot;
begin
  RunHiddenAndWait(ExpandConstant('{sys}\taskkill.exe'), '/IM PowerPilot_V*.exe /F /T');
  if FileExists(ExpandConstant('{app}\PowerPilotWindowsPerfHelper.exe')) then
    RunHiddenAndWait(ExpandConstant('{sys}\taskkill.exe'), '/IM PowerPilotWindowsPerfHelper.exe /F /T');
  if FileExists(ExpandConstant('{app}\PowerPilotWindowsPmiHelper.exe')) then
    RunHiddenAndWait(ExpandConstant('{sys}\taskkill.exe'), '/IM PowerPilotWindowsPmiHelper.exe /F /T');
  if FileExists(ExpandConstant('{app}\PowerPilotWindowsEmiHelper.exe')) then
    RunHiddenAndWait(ExpandConstant('{sys}\taskkill.exe'), '/IM PowerPilotWindowsEmiHelper.exe /F /T');
  if FileExists(ExpandConstant('{app}\PowerPilotLibreHelper.exe')) then
    RunHiddenAndWait(ExpandConstant('{sys}\taskkill.exe'), '/IM PowerPilotLibreHelper.exe /F /T');
  if FileExists(ExpandConstant('{app}\PowerPilotAmdAdlxHelper.exe')) then
    RunHiddenAndWait(ExpandConstant('{sys}\taskkill.exe'), '/IM PowerPilotAmdAdlxHelper.exe /F /T');
  if FileExists(ExpandConstant('{app}\PowerPilotAmdAdlHelper.exe')) then
    RunHiddenAndWait(ExpandConstant('{sys}\taskkill.exe'), '/IM PowerPilotAmdAdlHelper.exe /F /T');
  Sleep(200);
end;

procedure StopSameVersionPowerPilotIfInstalled;
begin
  if FileExists(ExpandConstant('{app}\{#AppExeName}')) then
  begin
    SetInstallStatus('Closing the running PowerPilot tray app so Setup can replace it.');
    Log(Format('Same-version exe exists; closing it before overwrite: %s', [ExpandConstant('{app}\{#AppExeName}')]));
    if RunAsOriginalUserAndWait(ExpandConstant('{app}\{#AppExeName}'), '/log-update-close-if-running') = 0 then
      Log('Same-version running app reported update close to the PowerPilot log.')
    else
      Log('Same-version exe exists but no running copy reported an update close.');
    RunHiddenAndWait(ExpandConstant('{sys}\taskkill.exe'), '/IM {#AppExeName} /F /T');
    Sleep(200);
  end
  else begin
    SetInstallStatus('Copying new PowerPilot files. Older tray versions will close after launch.');
    Log('No same-version exe exists; skipping pre-copy app close.');
  end;
end;

procedure RunAsOriginalUserNoWait(const FileName, Params: string);
var
  ResultCode: Integer;
begin
  if ExecAsOriginalUser(FileName, Params, '', SW_HIDE, ewNoWait, ResultCode) then
    Log(Format('Started as original user: %s %s', [FileName, Params]))
  else
    Log(Format('Failed to start as original user: %s %s', [FileName, Params]));
end;

procedure RefreshDesktopIconState;
begin
  RunHiddenNoWait(ExpandConstant('{sys}\ie4uinit.exe'), '-show');
end;

procedure StartInstalledPowerPilot;
var
  ResultCode: Integer;
  Attempt: Integer;
  LauncherArgs: string;
begin
  LauncherArgs := '/C start "" "' + ExpandConstant('{app}\{#AppExeName}') + '" /startup';
  for Attempt := 1 to 2 do
  begin
    if ExecAsOriginalUser(ExpandConstant('{sys}\cmd.exe'), LauncherArgs, '', SW_HIDE, ewNoWait, ResultCode) then
    begin
      Log(Format('Launched detached hidden startup as original user: %s /startup', [ExpandConstant('{app}\{#AppExeName}')]));
      Exit;
    end;
    Sleep(400);
  end;

  Log(Format('Failed to launch hidden startup as original user; not starting elevated: %s /startup', [ExpandConstant('{app}\{#AppExeName}')]));
end;

procedure CurStepChanged(CurStep: TSetupStep);
begin
  case CurStep of
    ssInstall:
      StopSameVersionPowerPilotIfInstalled();

    ssPostInstall:
      begin
        SetFinalInstallProgress('Preparing PowerPilot repair and uninstall files...', 72);
        EnsureInstalledMaintenanceSetup();
        SetFinalInstallProgress('Writing PowerPilot install information...', 76);
        WriteMaintenanceRegistry();
        SetFinalInstallProgress('Checking whether existing user settings should be kept...', 80);
        if not ShouldKeepSettingsOnReinstall() then
        begin
          SetFinalInstallProgress('Cleaning old PowerPilot user settings...', 84);
          RunAsOriginalUserAndWait(ExpandConstant('{app}\{#AppExeName}'), '/cleanup-settings')
        end
        else
        begin
          SetFinalInstallProgress('Keeping existing PowerPilot user settings...', 84);
          Log('Keeping existing user settings because the app preference is enabled.');
        end;
        SetFinalInstallProgress('Refreshing the desktop shortcut...', 88);
        RefreshDesktopIconState();
        SetFinalInstallProgress('Refreshing PowerPilot plans and saved policy...', 92);
        RunAsOriginalUserAndWait(ExpandConstant('{app}\{#AppExeName}'), '/install-refresh');
        SetFinalInstallProgress('Registering PowerPilot to start with Windows...', 96);
        RegisterStartupForOriginalUser();
        SetFinalInstallProgress('PowerPilot final setup steps are complete.', 98);
      end;

    ssDone:
      begin
        SetFinalInstallProgress('Closing older PowerPilot versions in the background...', 99);
        if RunAsOriginalUserAndWait(ExpandConstant('{app}\{#AppExeName}'), '/log-update-close-if-powerpilot-running') = 0 then
          Log('Running PowerPilot copy reported update close to the PowerPilot log.')
        else
          Log('No running PowerPilot copy reported an update close before background cleanup.');
        RunAsOriginalUserNoWait(ExpandConstant('{app}\{#AppExeName}'), '/cleanup-old-versions');
        SetFinalInstallProgress('Starting PowerPilot hidden in the notification area...', 100);
        StartInstalledPowerPilot();
        SetInstallStatus('PowerPilot is installed and running hidden in the tray.');
      end;
  end;
end;

procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
begin
  if CurUninstallStep = usUninstall then
  begin
    StopRunningPowerPilot();
    UnregisterStartupForOriginalUser();
    RunAsOriginalUserAndWait(ExpandConstant('{app}\{#AppExeName}'), '/cleanup-settings');
    RunAsOriginalUserAndWait(ExpandConstant('{app}\{#AppExeName}'), '/cleanup-plans');
  end;
end;
