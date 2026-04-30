# PowerPilot

PowerPilot is a PureBasic x64 Windows tray application for managing four Windows behavior profiles, target-based automatic CPU cap control, startup behavior, and clean install/uninstall handling for the profiles it creates.

The current control logic uses CPU package power and temperature readings from Windows. Auto Control does not switch profiles to regulate power or temperature; it applies temporary CPU caps from independent power and temperature targets, then restores the selected profile when control relaxes. Control uses a short response window with faster downward correction and slower recovery so package-power overshoot is corrected quickly without making normal recovery jumpy.

On AMD APUs where the driver exposes no iGPU power actuator, Auto Control can use very low CPU percentage and MHz caps to starve GPU-heavy package load through the shared APU power and memory path.

PowerPilot also includes an optional AMD ADLX helper layer. When enabled by the user and supported by the installed AMD display driver, it can read AMD GPU/APU metrics and use real AMD driver-side GPU power or frequency tuning when those controls are exposed. The Windows power-plan controller remains the primary control path and continues to work when ADLX is unavailable.

## Main features

- Windows x64 PureBasic tray application
- live temperature, CPU package power, and VRAM display
- target-based package-power control using temporary CPU caps
- optional single temperature target using the same controller path
- optional AMD ADLX GPU/APU-side probe, metrics, power/frequency tuning, and restore support
- editable target values, deadbands, smoothing, and polling interval
- one-click creation and cleanup of PowerPilot-owned Windows behavior profiles
- startup-in-tray support
- standard Inno Setup installer with uninstall support

## Profiles managed by the app

PowerPilot creates these behavior profiles:

- `PowerPilot Maximum`
- `PowerPilot Balanced`
- `PowerPilot Quiet`
- `PowerPilot Battery`

Cleanup also removes older `PowerPilot *` and legacy `Codex *` plans from earlier prototypes so upgrades stay clean.

## Runtime notes

- On battery, set Windows Power mode to Balanced or Best performance when using PowerPilot. Best power efficiency can cap the available CPU power range before PowerPilot can apply the full Auto Control behavior.
- PowerPilot changes only local Windows power plans and the Windows startup entry needed for tray launch.
- The helper executables are project-built support tools used for local Windows hardware information.
- `PowerPilotAmdAdlxHelper.exe` is optional. It uses only the AMD ADLX runtime installed by the AMD display driver.
- `PowerPilotAmdAdlHelper.exe` is a probe-only fallback helper for AMD's legacy ADL runtime. It dynamically loads only the driver-installed `atiadlxx.dll` from System32 and does not change tuning settings.
- PowerPilot does not bundle, copy, install, redistribute, or ship `amdadlx64.dll`, does not modify AMD driver files or AMD registry tuning values, and does not reset AMD Adrenalin tuning to factory defaults.
- PowerPilot does not need network access for its normal control logic.

## Build requirements

- PureBasic x64
- Windows target
- Thread Safe runtime enabled
- Inno Setup 6 for installer builds
- .NET Framework C# compiler for helper builds
- Visual Studio Build Tools with the C++ workload for the EMI helper build
- Optional: AMD ADLX SDK for real ADLX helper support. Without it, the helper still builds and reports ADLX as unavailable.

## Command-line build

Build the application and helper executables:

```powershell
.\build-purebasic.ps1
```

To build `PowerPilotAmdAdlxHelper.exe` with ADLX support, set `ADLX_SDK_DIR` to the root of the AMD ADLX SDK checkout before building:

```powershell
$env:ADLX_SDK_DIR = "C:\path\to\ADLX"
.\build-purebasic.ps1
```

Do not place `amdadlx64.dll` in this repository or beside the helper. The helper refuses to use a local ADLX runtime DLL next to itself.

Build the installer:

```powershell
.\build-installer.ps1
```

The installer build produces:

- `build\PowerPilot_V1.0.exe`
- `build\PowerPilotWindowsPmiHelper.exe`
- `build\PowerPilotWindowsPerfHelper.exe`
- `build\PowerPilotWindowsEmiHelper.exe`
- `build\PowerPilotAmdAdlxHelper.exe`
- `build\PowerPilotAmdAdlHelper.exe`
- `build\PowerPilot_V1.0_Setup.exe`

## AMD ADLX helper interface

The PureBasic app calls `PowerPilotAmdAdlxHelper.exe` as an external process and parses JSON output. Supported commands include:

```text
PowerPilotAmdAdlxHelper.exe probe
PowerPilotAmdAdlxHelper.exe metrics
PowerPilotAmdAdlxHelper.exe gfx_get
PowerPilotAmdAdlxHelper.exe gfx_set_max <mhz>
PowerPilotAmdAdlxHelper.exe power_get
PowerPilotAmdAdlxHelper.exe power_set <value>
PowerPilotAmdAdlxHelper.exe restore
```

The main controller uses ADLX only for real GPU power/frequency tuning when ADLX is enabled, package power is above the configured power target, and the driver exposes the required tuning controls. If the driver exposes metrics only, ADLX remains informational and CPU-side temporary caps continue to do the control work.

The helper saves only settings it changes and `restore` restores only those saved values. ADLX feature support is device, driver, and AMD Software configuration dependent.

## AMD ADL probe helper

`PowerPilotAmdAdlHelper.exe` is intentionally probe-only. It checks whether the older AMD Display Library exposes useful Overdrive, Overdrive8, OverdriveN, or PMLog capabilities on the current driver:

```text
PowerPilotAmdAdlHelper.exe probe
```

The ADL helper refuses to load a local `atiadlxx.dll` beside itself and instead loads the AMD-driver-installed runtime from System32. It does not call ADL setter APIs.

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
- calls the app to remove and recreate only the PowerPilot profiles it owns
- removes older helper files on upgrade or uninstall if an earlier install left them behind

The uninstall path removes:

- the installed files
- the Windows startup entry
- the PowerPilot behavior profiles
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

PowerPilot is intended for local Windows behavior-profile management, battery/plugged-in profile switching, and target-based Auto Control on systems where the user wants quick tray access to those controls.

## License

This project is licensed under the GNU General Public License v3.0.

See the [LICENSE](LICENSE) file for the full text.

## Author

John Torset
