# PowerPilot

PowerPilot is a PureBasic x64 Windows tray application for managing custom AC/DC power plans, live temperature-aware Cool tiers, and clean install/uninstall handling for the plans it creates.

The current build uses Windows telemetry only for sensor and power data.

The application is designed to:

- live in the notification area instead of the taskbar
- show real-time sensor data in a GUI window when opened
- automatically switch between battery, plugged-in, and Cool plans
- install and remove only the custom plans that do not belong to stock Windows
- start with Windows and launch directly into the tray
- avoid vendor-specific GPU telemetry helpers

## Main features

- Windows x64 PureBasic tray application
- live sensor display from Windows telemetry only
- background Auto Cool worker thread
- editable temperature thresholds and polling interval
- one-click creation and cleanup of custom Windows power plans
- custom-plan cleanup on uninstall
- no desktop icon and no Start menu shortcut
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

## Build requirements

- PureBasic x64
- Windows target
- Thread Safe runtime enabled
- Inno Setup 6 for installer builds

## Command-line build

Build the application:

```powershell
.\build-purebasic.ps1
```

Build the installer:

```powershell
.\build-installer.ps1
```

Default retention:

- snapshots kept: `8`
- chat-memory entries kept: `30`

Build the installer and also capture the current chat from clipboard into project memory:

```powershell
.\build-installer.ps1 -SaveChatFromClipboard -ChatTitle "display and dgpu session"
```

Build the installer without creating the automatic pre-build snapshot:

```powershell
.\build-installer.ps1 -SkipSnapshot
```

## Startup memory

For quick context on future editor/code sessions, also check:

- `STARTUP_CONTEXT.md` for the latest verified build and installer status
- `CHAT_MEMORY\CURRENT_CONTEXT.md` for the latest working summary
- `CHAT_MEMORY\LATEST_BUILD.md` for the latest auto-generated installer-build summary
- `CHAT_MEMORY\INDEX.md` for saved chat-memory entries
- `CHAT_MEMORY\save-chat-memory.ps1` to save a pasted or clipboard chat into the project folder

`build-installer.ps1` now also:

- creates a pre-build source snapshot in `SNAPSHOTS`
- trims old snapshots automatically
- refreshes `STARTUP_CONTEXT.md`
- refreshes `CHAT_MEMORY\LATEST_BUILD.md`
- saves an installer-build memory entry into `CHAT_MEMORY\logs`
- trims old chat-memory entries automatically
- can include clipboard chat text when run with `-SaveChatFromClipboard`

Snapshot reminder:

- take regular snapshots or commits while iterating, especially before installer work, larger refactors, or risky power-plan changes

## Installer behavior

The installer:

- installs into `Program Files\PowerPilot`
- registers the app to start with Windows using `/tray`
- launches the app into the notification area after installation
- does not create Start menu or desktop icons
- calls the app to remove and recreate only the custom plans it owns
- removes the legacy AMD helper file on upgrade or uninstall if an older install left it behind

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
/auto-gamecool-once
/auto-cool-once
/show
```

## License

This project is licensed under the GNU General Public License v3.0.

See the `LICENSE` file for the full text.

## Author

John Torset
