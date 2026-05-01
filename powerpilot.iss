#define AppName "PowerPilot"
#define AppVersion "1.0.2605.01036"
#define AppExeName "PowerPilot_V1.0.exe"
#define AppSetupName "PowerPilot_V1.0_Setup.exe"
#define AppPublisher "John Torset"
#define AppURL "https://github.com/JTorset66/PowerPilot"
#define AppIconName "powerpilot.ico"
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
DisableProgramGroupPage=yes
OutputDir=build
OutputBaseFilename=PowerPilot_V1.0_Setup
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
SetupIconFile=powerpilot.ico
PrivilegesRequired=admin
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
UninstallDisplayName={#AppName}
UninstallDisplayIcon={app}\{#AppExeName}
CloseApplications=yes
CloseApplicationsFilter={#AppExeName}
RestartApplications=no
VersionInfoCompany={#AppPublisher}
VersionInfoDescription=PowerPilot Setup
VersionInfoProductName={#AppName}
VersionInfoProductVersion={#AppVersion}

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Messages]
WelcomeLabel1=Welcome to PowerPilot
WelcomeLabel2=PowerPilot installs a local tray utility that follows Windows power mode.%n%nSetup will refresh the PowerPilot-owned plans, remove older helper files, include the user README, license, and third-party notices, and start PowerPilot in the tray when it finishes.
FinishedHeadingLabel=PowerPilot is ready
FinishedLabelNoIcons=Setup has installed PowerPilot and started the tray app. Open PowerPilot from the desktop shortcut or the tray icon to review plans, Windows power mode, and hardware information.

[Files]
Source: "build\{#AppExeName}"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#AppIconName}"; DestDir: "{app}"; Flags: ignoreversion
Source: "powerpilot_tray.ico"; DestDir: "{app}"; Flags: ignoreversion
Source: "INSTALLER_README.md"; DestDir: "{app}"; DestName: "README.md"; Flags: ignoreversion
Source: "THIRD_PARTY_NOTICES.md"; DestDir: "{app}"; Flags: ignoreversion
Source: "LICENSE"; DestDir: "{app}"; Flags: ignoreversion
Source: "INSTALLER_README.md"; DestName: "PowerPilot_README.md"; Flags: dontcopy
Source: "THIRD_PARTY_NOTICES.md"; DestName: "PowerPilot_THIRD_PARTY_NOTICES.md"; Flags: dontcopy
Source: "LICENSE"; DestName: "PowerPilot_LICENSE.txt"; Flags: dontcopy
Source: "installer-assets\installer-welcome.bmp"; Flags: dontcopy
Source: "installer-assets\installer-finish.bmp"; Flags: dontcopy

[Icons]
Name: "{autodesktop}\{#AppName}"; Filename: "{app}\{#AppExeName}"; WorkingDir: "{app}"; IconFilename: "{app}\{#AppIconName}"

[InstallDelete]
Type: files; Name: "{app}\PowerPilotLibreHelper.exe"
Type: files; Name: "{app}\PowerPilotWindowsPmiHelper.exe"
Type: files; Name: "{app}\PowerPilotWindowsPerfHelper.exe"
Type: files; Name: "{app}\PowerPilotWindowsEmiHelper.exe"
Type: files; Name: "{app}\PowerPilotAmdAdlxHelper.exe"
Type: files; Name: "{app}\PowerPilotAmdAdlHelper.exe"
Type: files; Name: "{app}\powerpilot_desktop.ico"
Type: files; Name: "{app}\powerpilot_tray.png"
Type: filesandordirs; Name: "{app}\third_party\LibreHardwareMonitor"
Type: dirifempty; Name: "{app}\third_party"

[UninstallDelete]
Type: files; Name: "{app}\{#AppSetupName}"
Type: files; Name: "{app}\PowerPilotWindowsPmiHelper.exe"
Type: files; Name: "{app}\PowerPilotWindowsPerfHelper.exe"
Type: files; Name: "{app}\PowerPilotWindowsEmiHelper.exe"
Type: files; Name: "{app}\PowerPilotAmdAdlxHelper.exe"
Type: files; Name: "{app}\PowerPilotAmdAdlHelper.exe"
Type: files; Name: "{app}\powerpilot_desktop.ico"
Type: files; Name: "{app}\powerpilot_tray.png"
Type: filesandordirs; Name: "{app}\third_party\LibreHardwareMonitor"
Type: dirifempty; Name: "{app}\third_party"

[Code]
const
  UninstallRegSubkey = 'Software\Microsoft\Windows\CurrentVersion\Uninstall\{88D96927-5B26-4DF8-8EE0-3BF9A49E56E3}_is1';
  LegacyBrokenRegSubkey = 'Software\Microsoft\Windows\CurrentVersion\Uninstall\{{88D96927-5B26-4DF8-8EE0-3BF9A49E56E3}_is1';

var
  OverviewPage: TWizardPage;
  IncludedFilesPage: TWizardPage;

function GetCurrentProcessId(): Cardinal;
  external 'GetCurrentProcessId@kernel32.dll stdcall';

function QuoteValue(const Value: string): string;
begin
  Result := '"' + Value + '"';
end;

function MaintenanceMode: Boolean;
begin
  Result := ExpandConstant('{param:maintenance|0}') = '1';
end;

procedure AddOverviewText(const Caption: string; Top, Height, FontSize: Integer; Bold: Boolean);
var
  Text: TNewStaticText;
begin
  Text := TNewStaticText.Create(OverviewPage);
  Text.Parent := OverviewPage.Surface;
  Text.AutoSize := False;
  Text.WordWrap := True;
  Text.Caption := Caption;
  Text.SetBounds(ScaleX(0), ScaleY(Top), OverviewPage.SurfaceWidth, ScaleY(Height));
  Text.Font.Size := FontSize;
  if Bold then
    Text.Font.Style := [fsBold];
end;

procedure OpenIncludedTextFile(const FileName: string);
var
  ResultCode: Integer;
  TempPath: string;
begin
  ExtractTemporaryFile(FileName);
  TempPath := ExpandConstant('{tmp}\' + FileName);

  if not Exec(ExpandConstant('{sys}\notepad.exe'), QuoteValue(TempPath), '', SW_SHOWNORMAL, ewNoWait, ResultCode) then
    MsgBox('PowerPilot Setup could not open ' + FileName + '.', mbError, MB_OK);
end;

procedure ReadmeButtonClick(Sender: TObject);
begin
  OpenIncludedTextFile('PowerPilot_README.md');
end;

procedure LicenseButtonClick(Sender: TObject);
begin
  OpenIncludedTextFile('PowerPilot_LICENSE.txt');
end;

procedure ThirdPartyButtonClick(Sender: TObject);
begin
  OpenIncludedTextFile('PowerPilot_THIRD_PARTY_NOTICES.md');
end;

procedure CreateIncludedFileButton(const Caption: string; Top: Integer; OnClick: TNotifyEvent);
var
  Button: TNewButton;
begin
  Button := TNewButton.Create(IncludedFilesPage);
  Button.Parent := IncludedFilesPage.Surface;
  Button.Caption := Caption;
  Button.Left := 0;
  Button.Top := Top;
  Button.Width := ScaleX(190);
  Button.Height := WizardForm.NextButton.Height;
  Button.OnClick := OnClick;
end;

procedure CreateIncludedFilesPage;
var
  BodyText: TNewStaticText;
  ButtonTop: Integer;
begin
  IncludedFilesPage :=
    CreateCustomPage(
      wpSelectDir,
      'Read Included Files',
      'Open the documents bundled with PowerPilot before installing.'
    );

  BodyText := TNewStaticText.Create(IncludedFilesPage);
  BodyText.Parent := IncludedFilesPage.Surface;
  BodyText.Left := 0;
  BodyText.Top := 0;
  BodyText.Width := IncludedFilesPage.SurfaceWidth;
  BodyText.Height := ScaleY(60);
  BodyText.WordWrap := True;
  BodyText.Caption :=
    'PowerPilot Setup includes a user README, license, and third-party notices. ' +
    'Use these buttons to read them now; the same files will also be installed with PowerPilot.';

  ButtonTop := BodyText.Top + BodyText.Height + ScaleY(18);
  CreateIncludedFileButton('Read README', ButtonTop, @ReadmeButtonClick);
  CreateIncludedFileButton('Read License', ButtonTop + ScaleY(36), @LicenseButtonClick);
  CreateIncludedFileButton('Read Third-Party Notices', ButtonTop + ScaleY(72), @ThirdPartyButtonClick);
end;

procedure ApplyWizardArtwork(PageID: Integer);
var
  BitmapPath: string;
begin
  BitmapPath := '';
  if PageID = wpWelcome then
    BitmapPath := ExpandConstant('{tmp}\installer-welcome.bmp')
  else if PageID = wpFinished then
    BitmapPath := ExpandConstant('{tmp}\installer-finish.bmp');

  if BitmapPath <> '' then
  begin
    try
      WizardForm.WizardBitmapImage.Bitmap.LoadFromFile(BitmapPath);
    except
    end;
  end;
end;

procedure InitializeWizard;
begin
  ExtractTemporaryFile('installer-welcome.bmp');
  ExtractTemporaryFile('installer-finish.bmp');
  ApplyWizardArtwork(wpWelcome);

  OverviewPage :=
    CreateCustomPage(
      wpWelcome,
      'What PowerPilot will set up',
      'A quick summary before PowerPilot refreshes its owned plans.'
    );

  AddOverviewText('PowerPilot runs locally from the tray and manages only this PC.', 0, 28, 10, True);
  AddOverviewText('The tray app follows Windows power mode: Best performance, Balanced, or Best power efficiency. CPU information comes from CPUID assembly; GPU names come from Windows display enumeration plus CPU-based iGPU resolution.', 38, 64, 9, False);
  AddOverviewText('During install:', 104, 24, 10, True);
  AddOverviewText('- any running PowerPilot process is closed safely' + #13 +
                  '- PowerPilot-owned and legacy prototype plans are removed and recreated' + #13 +
                  '- old helper executables from previous builds are removed' + #13 +
                  '- startup is enabled so the tray app is available after sign-in', 134, 88, 9, False);
  AddOverviewText('Managed plans:', 226, 24, 10, True);
  AddOverviewText('PowerPilot keeps only Maximum, Balanced, and Battery plans. The Plans tab edits those fixed plans directly, while Windows power mode chooses which one should be active.', 256, 72, 9, False);

  CreateIncludedFilesPage();
end;

procedure CurPageChanged(CurPageID: Integer);
begin
  ApplyWizardArtwork(CurPageID);
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

function ShouldKeepSettingsOnReinstall: Boolean;
begin
  Result := RunAsOriginalUserAndWait(ExpandConstant('{app}\{#AppExeName}'), '/query-keep-settings') = 1;
  Log(Format('Keep settings on reinstall query -> %d', [Ord(Result)]));
end;

procedure StopRunningPowerPilot;
var
  I: Integer;
begin
  for I := 0 to 1 do
  begin
    RunHiddenAndWait(ExpandConstant('{sys}\taskkill.exe'), '/IM {#AppExeName} /F /T');
    RunHiddenAndWait(ExpandConstant('{sys}\taskkill.exe'), '/IM PowerPilotWindowsPerfHelper.exe /F /T');
    RunHiddenAndWait(ExpandConstant('{sys}\taskkill.exe'), '/IM PowerPilotWindowsPmiHelper.exe /F /T');
    RunHiddenAndWait(ExpandConstant('{sys}\taskkill.exe'), '/IM PowerPilotWindowsEmiHelper.exe /F /T');
    RunHiddenAndWait(ExpandConstant('{sys}\taskkill.exe'), '/IM PowerPilotLibreHelper.exe /F /T');
    RunHiddenAndWait(ExpandConstant('{sys}\taskkill.exe'), '/IM PowerPilotAmdAdlxHelper.exe /F /T');
    RunHiddenAndWait(ExpandConstant('{sys}\taskkill.exe'), '/IM PowerPilotAmdAdlHelper.exe /F /T');
    Sleep(300);
  end;
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
  LauncherArgs := '/C start "" "' + ExpandConstant('{app}\{#AppExeName}') + '" /tray';
  for Attempt := 1 to 2 do
  begin
    if ExecAsOriginalUser(ExpandConstant('{sys}\cmd.exe'), LauncherArgs, '', SW_HIDE, ewNoWait, ResultCode) then
    begin
      Log(Format('Launched detached tray as original user: %s /tray', [ExpandConstant('{app}\{#AppExeName}')]));
      Exit;
    end;
    Sleep(400);
  end;

  for Attempt := 1 to 2 do
  begin
    if Exec(ExpandConstant('{sys}\cmd.exe'), LauncherArgs, '', SW_HIDE, ewNoWait, ResultCode) then
    begin
      Log(Format('Launched detached tray with elevated fallback: %s /tray', [ExpandConstant('{app}\{#AppExeName}')]));
      Exit;
    end;
    Sleep(400);
  end;

  Log(Format('Failed to launch after retries: %s /tray', [ExpandConstant('{app}\{#AppExeName}')]));
end;

procedure CurStepChanged(CurStep: TSetupStep);
begin
  case CurStep of
    ssInstall:
      StopRunningPowerPilot();

    ssPostInstall:
      begin
        EnsureInstalledMaintenanceSetup();
        WriteMaintenanceRegistry();
        if not ShouldKeepSettingsOnReinstall() then
          RunHiddenAndWait(ExpandConstant('{app}\{#AppExeName}'), '/cleanup-settings')
        else
          Log('Keeping existing user settings because the app preference is enabled.');
        RefreshDesktopIconState();
        RunAsOriginalUserAndWait(ExpandConstant('{app}\{#AppExeName}'), '/startup-on');
        RunHiddenAndWait(ExpandConstant('{app}\{#AppExeName}'), '/cleanup-plans');
        RunHiddenAndWait(ExpandConstant('{app}\{#AppExeName}'), '/create-plans');
        RunHiddenAndWait(ExpandConstant('{app}\{#AppExeName}'), '/follow-once');
      end;

    ssDone:
      begin
        StartInstalledPowerPilot();
      end;
  end;
end;

procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
begin
  if CurUninstallStep = usUninstall then
  begin
    StopRunningPowerPilot();
    RunAsOriginalUserAndWait(ExpandConstant('{app}\{#AppExeName}'), '/startup-off');
    RunHiddenAndWait(ExpandConstant('{app}\{#AppExeName}'), '/cleanup-settings');
    RunHiddenAndWait(ExpandConstant('{app}\{#AppExeName}'), '/cleanup-plans');
  end;
end;
