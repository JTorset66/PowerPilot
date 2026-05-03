# PowerPilot

PowerPilot is a PureBasic x64 Windows tray application for managing three local Windows power plans, tracking local battery history, and showing a copyable PowerPilot log:

- `PowerPilot Maximum`
- `PowerPilot Balanced`
- `PowerPilot Battery`

The app creates or refreshes those plans from the currently selected Windows power plan, then applies PowerPilot's tuned CPU behavior settings on top. It watches Windows power mode while open or hidden in the tray and follows Best performance, Balanced, or Best power efficiency. It also records retained local battery samples, Windows power events, and short app status rows. It no longer uses temperature, package-power telemetry, Auto Control, or helper executables.

## Main Features

- PureBasic x64 tray application
- fixed three-plan editor for Maximum, Balanced, and Battery
- automatic Maximum, Balanced, or Battery activation based on Windows power mode
- automatic refresh from a newly selected non-PowerPilot Windows plan
- CPU information from inline CPUID assembly
- GPU names and PCI IDs from Windows display adapter enumeration
- Battery Graph tab with live charge state, capacity/wear data, Windows runtime, average and instant estimates, and a gliding 24-hour percent graph
- Battery Graph minimum percent is also applied to PowerPilot-managed Windows plans as the on-battery critical sleep level
- PowerPilot Log tab with configurable sample interval, saved column sizing, copyable retained CSV rows, app status rows, and battery/power-event rows
- Battery Stats tab with session, daily battery, off-time battery loss, log column, and settings backup controls
- startup-in-tray support
- matching green shield icons for the executable, tray icon, and desktop shortcut
- standard Inno Setup installer with uninstall support

## Hardware Information

PowerPilot shows static local hardware information plus local battery status:

- CPU brand, vendor, family/model/stepping
- core/thread topology when CPUID exposes it
- cache summary
- CPU feature summary such as AVX2, AVX-512, AES, SHA, BMI, and virtualization
- installed system memory
- GPU display adapter names, vendor IDs, device IDs, and active/primary flags
- battery percent, connected/charging state, remaining capacity, full/design capacity, wear, live charge/discharge rate, cycle count, and runtime data when exposed by Windows battery providers
- PowerPilot log event rows for PC startup, shutdown, shutdown requested, sleep/hibernate, wake, return from hibernation, improper shutdown, app start/exit/update close, and short app status messages
- battery stats summaries for the latest session event, today's active battery drain, and battery percentage lost across off/sleep/hibernate gaps

PowerPilot does not read live CPU temperature, live package watts, fan speed, or live GPU telemetry.

## Build Requirements

- PureBasic x64
- Windows target
- Thread Safe runtime enabled
- Inno Setup 6 for installer builds

## Command-Line Build

Build the application:

```powershell
.\build-purebasic.ps1
```

Build the installer:

```powershell
.\build-installer.ps1
```

The installer build produces:

- `build\PowerPilot_V1.1.YYMM.minute-of-month.exe`
- `build\PowerPilot_V1.1.YYMM.minute-of-month_Setup.exe`

To sign the project-owned executables with a certificate already installed in the Windows certificate store:

```powershell
.\build-installer.ps1 -CertificateThumbprint "<YOUR_CERT_THUMBPRINT>"
```

To add RFC 3161 timestamping:

```powershell
.\build-installer.ps1 -CertificateThumbprint "<YOUR_CERT_THUMBPRINT>" -TimestampUrl "<YOUR_TIMESTAMP_URL>"
```

## Versioning

The public source file is on the `V1.1` line, while build scripts stamp a full build version into metadata and generated artifact filenames:

```text
1.1.YYMM.minute-of-month
```

For example, a May 2026 build may produce artifacts such as `PowerPilot_V1.1.2605.01042.exe` and `PowerPilot_V1.1.2605.01042_Setup.exe`.

## Installer Behavior

The installer:

- installs into `Program Files\PowerPilot`
- creates a desktop shortcut using `powerpilot_desktop.ico`
- registers the app to start with Windows using `/tray`
- launches the app into the notification area after installation
- includes a user-focused README, license, and third-party notices
- provides installer buttons to read those included files before installation
- removes old PowerPilot helper files from earlier builds if present
- installs newer versions side-by-side, writes a `PowerPilot update close` app-log row when an existing tray copy is running, lets the new app close older `PowerPilot_V*.exe` versions in the background, and only pre-closes the exact same stamped exe during same-version reinstall
- removes stale versioned `PowerPilot_V*.exe` app files after install through a background cleanup command
- calls the app to repair missing PowerPilot plans during normal updates without recreating existing plans
- checks after install that setup, elevated helper, and cleanup processes have exited
- supports repair and uninstall from Windows Apps/Programs maintenance

The uninstall path removes:

- the installed files
- the Windows startup entry
- the PowerPilot plans
- any legacy `Codex *` plans from the prototype

## Command-Line Options

```text
/tray
/show
/create-plans
/cleanup-plans
/install-refresh
/cleanup-old-versions
/startup-on
/startup-off
/query-keep-settings
/cleanup-settings
/follow-once
```

## Fixed Plan Editing

PowerPilot keeps exactly three managed plans:

- `PowerPilot Maximum`
- `PowerPilot Balanced`
- `PowerPilot Battery`

The Plans tab edits those fixed plans directly. Select one of the three plans, adjust its processor settings, then click `Save`. If the selected PowerPilot plan is missing from Windows, Save recreates it and applies the edited settings.

PowerPilot does not expose manual plan activation in the UI. While PowerPilot is running, Windows power mode chooses which of the three fixed plans should be active.

## Default Plan Behavior

PowerPilot applies a small set of tuned processor settings on top of the base Windows plan:

- `PowerPilot Maximum` favors maximum possible plugged-in performance: AC energy preference `0`, aggressive AC boost, 100% max CPU, no frequency cap, active cooling, faster boost ramp-up, slower ramp-down, and CPU idle still enabled.
- `PowerPilot Balanced` stays close to Windows Balanced: AC/DC energy preference `33/50`, AC boost enabled, DC boost disabled, 100% max CPU on AC and battery, no frequency cap, active AC cooling, passive DC cooling, Windows-like boost policy and ramp thresholds, and CPU idle enabled.
- `PowerPilot Battery` favors battery life with disabled boost, lower max CPU, MHz caps, passive cooling, deeper core parking when deep idle saver is enabled, and CPU idle enabled.

Windows firmware, chipset drivers, and hidden processor settings can still affect the exact behavior available on a device.

## Privacy

PowerPilot does not transfer information to networked systems unless explicitly requested by the user or operator. Hardware information is read locally from CPUID, Windows display adapter enumeration, and Windows battery providers.

## Releases

Tagged releases and release artifact filenames should use the full stamped version number, for example `v1.1.2605.01042`.

The repository includes a self-hosted GitHub Actions workflow at [`.github/workflows/release-self-hosted.yml`](.github/workflows/release-self-hosted.yml) for controlled Windows builds with PureBasic and Inno Setup installed. The workflow can optionally sign artifacts when a trusted certificate thumbprint is provided through repository secrets.

Release steps are summarized in [`RELEASE_CHECKLIST.md`](RELEASE_CHECKLIST.md).

## Code Signing Policy

The code-signing and release-signing rules are documented in [`CODE_SIGNING_POLICY.md`](CODE_SIGNING_POLICY.md).

For SignPath Foundation onboarding preparation, see [`SIGNPATH_APPLICATION.md`](SIGNPATH_APPLICATION.md).

## Function Map

The current PureBasic source layout is summarized in [`FUNCTION_MAP.md`](FUNCTION_MAP.md). Review it after larger source changes to catch stale functions, obsolete UI references, and documentation drift.

## Repository Contents

```text
PowerPilot_V1.1.pb
PowerPilot.code-workspace
powerpilot.iss
build-purebasic.ps1
build-installer.ps1
install-powerpilot.ps1
FUNCTION_MAP.md
installer-assets/
powerpilot.ico
powerpilot_desktop.ico
powerpilot_tray.ico
README.md
INSTALLER_README.md
THIRD_PARTY_NOTICES.md
RELEASE_NOTES_v1.1.md
CODE_SIGNING_POLICY.md
RELEASE_CHECKLIST.md
SIGNPATH_APPLICATION.md
LICENSE
```

## Third-Party Notices

No third-party assets or libraries requiring separate redistribution notices are intentionally bundled with the PowerPilot release package. See [`THIRD_PARTY_NOTICES.md`](THIRD_PARTY_NOTICES.md).

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE).

## Author

John Torset
