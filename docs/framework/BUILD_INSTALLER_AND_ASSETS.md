# Build, Installer, Icons, And Tray Framework

## Required Tools

PowerPilot builds on Windows with:

- PureBasic compiler, normally `C:\Program Files\PureBasic\Compilers\pbcompiler.exe`.
- Inno Setup 6.
- PowerShell.
- Git for release workflows.

## Build Executable

Run:

```powershell
.\build-purebasic.ps1
```

What it does:

1. Calculates a version like `1.1.yymm.minutes`.
2. Updates `#AppVersion$` in `PowerPilot_V1.2.pb`.
3. Compiles the PureBasic source.
4. Writes a versioned executable under `build\`.

For a release tag or repeatable rebuild, pass the exact four-part version:

```powershell
.\build-purebasic.ps1 -AppVersion 1.2.2605.14550
```

## Build Installer

Run:

```powershell
.\build-installer.ps1
```

What it does:

1. Creates a pre-build snapshot in `SNAPSHOTS`.
2. Runs the PureBasic build.
3. Synchronizes `powerpilot.iss` with the current app version and executable name.
4. Builds the Inno Setup installer into `build\`.
5. Saves build context in `CHAT_MEMORY` and `STARTUP_CONTEXT.md`.

`build-installer.ps1` also accepts `-AppVersion` and passes it through to the PureBasic build. The GitHub workflow uses this for `v*` tags so tagged releases produce matching artifact names.

## Install Locally

Run:

```powershell
.\install-powerpilot.ps1
```

The install helper runs the latest setup EXE, waits for completion, verifies installer logs, and checks that PowerPilot is running after install.

## Installer Script

`powerpilot.iss` defines:

- App identity, publisher, URL, app id, version, and setup filename.
- Admin-approved install under `Program Files\PowerPilot`.
- No UAC/admin requirement for post-install app commands, startup launch, or normal tray runtime.
- x64-compatible architecture.
- LZMA2 solid compression.
- Installer icon.
- Installed files.
- Desktop shortcut.
- HKLM maintenance/uninstall metadata.
- Cleanup of older helper files and old bundled docs.
- Uninstall cleanup for app-owned installed files.
- A lean Inno Setup flow with one combined two-column front page: setup summary on the left, read buttons for USER MANUAL, README, LICENSE, and THIRD-PARTY NOTICES on the right. The same documents are also opened from the app's About tab after install.
- A final setup-progress phase after file copy, with visible status text for settings, plan refresh, startup registration, old-version cleanup, and tray launch.

## Bundled Files

Installed app folder includes:

- Versioned PowerPilot EXE.
- `powerpilot.ico`.
- `powerpilot_desktop.ico`.
- `powerpilot_tray.ico`.
- `USER_MANUAL.txt`.
- `README.txt` from `INSTALLER_README.md`.
- `THIRD_PARTY_NOTICES.txt`.
- `LICENSE.txt`.

## Icon Rules

Use three icon files:

- `powerpilot.ico` for the app and setup icon.
- `powerpilot_desktop.ico` for the desktop shortcut.
- `powerpilot_tray.ico` for the tray icon.

The installer copies all three into `{app}`. The tray setup loads `powerpilot_tray.ico` beside the running executable.

## Privilege Model

PowerPilot uses an admin-approved installer but a normal-user runtime:

- Inno Setup uses `PrivilegesRequired=admin`.
- The default install directory is `{autopf}\PowerPilot`.
- Startup uses HKCU `Software\Microsoft\Windows\CurrentVersion\Run`.
- The installer owns setup-time startup registration and removal for the original ordinary user. The app `/install-refresh` path persists the preference, creates missing plans, and refreshes the current CPU, battery, Energy Saver, and hidden platform policy on existing managed plans, but does not write the setup-time startup entry.
- All installed EXE invocations from setup use `ExecAsOriginalUser`.
- Post-install tray launch must not fall back to an elevated process.
- The install helper may request UAC for setup, but must not launch the installed app from an elevated helper process.

## Tray Behavior

Tray setup is handled by:

- `CreateTrayMenu()`.
- `SetupTray()`.
- `HideToTray()`.
- `ShowFromTray()`.
- `ShutdownApp()`.
- `ShutdownForUpdate()`.

Runtime behavior:

- The tray menu has `Open` and `Exit`.
- Hiding keeps PowerPilot running and slows refresh.
- Showing forces an immediate refresh.
- Exiting removes the tray icon, saves settings, logs `PowerPilot exit`, and unregisters display power notifications.
- Installer replacement logs `PowerPilot update close` instead of normal exit.

If the tray icon cannot be created, the window stays visible so the app is not hidden without a recovery path.

## Bundled Documentation

The installer bundles user-facing text docs. Framework docs stay in the repo unless intentionally added to `powerpilot.iss`.
