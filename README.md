# PowerPilot

PowerPilot is a PureBasic x64 Windows tray application for managing custom Windows power plans, Auto Cool power levels, temperature protection, startup behavior, and clean install/uninstall handling for the plans it creates.

The current control logic uses CPU package power and temperature readings from Windows. Auto Cool uses CPU package power first when it is already running a Cool plan. When PowerPilot is in Full Power and Auto Cool is enabled, temperature is used to decide when to enter the Cool plans.

The GPU helper is used only to show GPU names and VRAM information. GPU load and GPU power are not used for Auto Cool decisions.

## Main features

- Windows x64 PureBasic tray application
- live temperature, CPU package power, and VRAM display
- CPU-package-power Auto Cool control while running Cool plans
- temperature-based entry into Cool plans from Full Power
- editable temperature thresholds, smoothing, and polling interval
- one-click creation and cleanup of PowerPilot-owned Windows power plans
- startup-in-tray support
- standard Inno Setup installer with uninstall support

## Plans managed by the app

PowerPilot creates these custom plans:

- `PowerPilot Battery Saver`
- `PowerPilot Plugged In`
- `PowerPilot Cool 12W`
- `PowerPilot Cool 15W`
- `PowerPilot Cool 18W`
- `PowerPilot Cool 21W`
- `PowerPilot Cool 24W`
- `PowerPilot Full Power`

Cleanup also removes legacy `Codex *` plans from the earlier prototype so upgrades stay clean.

## Runtime notes

- On battery, set Windows Power mode to Balanced or Best performance when using PowerPilot. Best power efficiency can cap the available CPU power range before PowerPilot can apply the full Auto Cool behavior.
- PowerPilot changes only local Windows power plans and the Windows startup entry needed for tray launch.
- The helper executables are project-built support tools used for local Windows hardware information.
- PowerPilot does not need network access for its normal control logic.

## Build requirements

- PureBasic x64
- Windows target
- Thread Safe runtime enabled
- Inno Setup 6 for installer builds
- .NET Framework C# compiler for helper builds
- Visual Studio Build Tools with the C++ workload for the EMI helper build

## Command-line build

Build the application and helper executables:

```powershell
.\build-purebasic.ps1
```

Build the installer:

```powershell
.\build-installer.ps1
```

The installer build produces:

- `build\PowerPilot_V1.0.exe`
- `build\PowerPilotWindowsPmiHelper.exe`
- `build\PowerPilotWindowsPerfHelper.exe`
- `build\PowerPilotWindowsEmiHelper.exe`
- `build\PowerPilot_V1.0_Setup.exe`

To sign the project-owned executables with a certificate already installed in the Windows certificate store:

```powershell
.\build-installer.ps1 -CertificateThumbprint "<YOUR_CERT_THUMBPRINT>"
```

To add RFC 3161 timestamping during signing:

```powershell
.\build-installer.ps1 -CertificateThumbprint "<YOUR_CERT_THUMBPRINT>" -TimestampUrl "<YOUR_TIMESTAMP_URL>"
```

You can inspect local code-signing certificates with:

```powershell
Get-ChildItem Cert:\CurrentUser\My, Cert:\LocalMachine\My |
  Where-Object {
    $_.HasPrivateKey -and (
      $_.EnhancedKeyUsageList.ObjectId -contains '1.3.6.1.5.5.7.3.3' -or
      $_.EnhancedKeyUsageList.FriendlyName -contains 'Code Signing'
    )
  } |
  Select-Object Subject, Thumbprint, NotAfter
```

## Smart App Control note

For Windows Smart App Control compatibility, Microsoft currently requires the app to be signed with an RSA-based code-signing certificate from a trusted provider, or through Microsoft Trusted Signing. A self-signed certificate or internal test certificate may produce a digital signature, but it will not make Smart App Control trust the app.

## Releases

Tagged releases are intended to use the format `v*`.

The repository includes a self-hosted GitHub Actions workflow at [`.github/workflows/release-self-hosted.yml`](.github/workflows/release-self-hosted.yml) for Windows builds. It is designed for a controlled Windows runner with PureBasic, helper build tools, and Inno Setup installed. It can optionally sign the build if a trusted certificate thumbprint is provided through repository secrets.

Until the project completes SignPath Foundation onboarding or another trusted signing setup, release binaries may be unsigned.

Release steps are summarized in [`RELEASE_CHECKLIST.md`](RELEASE_CHECKLIST.md).

## Code signing policy

The project code-signing and release-signing rules are documented in [`CODE_SIGNING_POLICY.md`](CODE_SIGNING_POLICY.md).

For SignPath Foundation onboarding preparation, see [`SIGNPATH_APPLICATION.md`](SIGNPATH_APPLICATION.md).

## Privacy

This program does not transfer information to other networked systems unless specifically requested by the user or the person installing or operating it.

PowerPilot reads local Windows telemetry for temperature, CPU package power, GPU names, and VRAM display. These readings stay on the local machine unless the user or operator explicitly chooses to share them.

## Startup memory

For quick context on future editor/code sessions, also check:

- `STARTUP_CONTEXT.md` for the latest verified build and installer status
- `CHAT_MEMORY\CURRENT_CONTEXT.md` for the latest working summary
- `CHAT_MEMORY\LATEST_BUILD.md` for the latest auto-generated installer-build summary
- `CHAT_MEMORY\INDEX.md` for saved chat-memory entries
- `CHAT_MEMORY\save-chat-memory.ps1` to save a pasted or clipboard chat into the project folder

`build-installer.ps1` also:

- creates a pre-build source snapshot in `SNAPSHOTS`
- trims old snapshots automatically
- refreshes `STARTUP_CONTEXT.md`
- refreshes `CHAT_MEMORY\LATEST_BUILD.md`
- saves an installer-build memory entry into `CHAT_MEMORY\logs`
- trims old chat-memory entries automatically
- can include clipboard chat text when run with `-SaveChatFromClipboard`

## Installer behavior

The installer:

- installs into `Program Files\PowerPilot`
- registers the app to start with Windows using `/tray`
- launches the app into the notification area after installation
- calls the app to remove and recreate only the custom plans it owns
- removes older helper files on upgrade or uninstall if an earlier install left them behind

The uninstall path removes:

- the installed files
- the Windows startup entry
- the custom PowerPilot plans
- any legacy `Codex *` plans from the prototype

## Command-line options

The GUI app also supports maintenance commands:

```text
/tray
/create-plans
/cleanup-plans
/auto-cool-once
/show
```

The legacy `/auto-gamecool-once` alias is still accepted for older automation.

## Repository contents

```text
PowerPilot_V1.0.pb
WindowsPmiHelper.cs
WindowsPerfRefresherHelper.cs
WindowsEmiHelper.c
build-purebasic.ps1
build-helpers.ps1
build-installer.ps1
powerpilot.iss
README.md
CODE_SIGNING_POLICY.md
RELEASE_CHECKLIST.md
SIGNPATH_APPLICATION.md
SIGNPATH_EMAIL_DRAFT.md
LICENSE
```

## Intended use

PowerPilot is intended for local Windows power-plan management, battery/plugged-in plan switching, and temperature-aware Auto Cool behavior on systems where the user wants quick tray access to those controls.

## License

This project is licensed under the GNU General Public License v3.0.

See the [LICENSE](LICENSE) file for the full text.

## Author

John Torset
