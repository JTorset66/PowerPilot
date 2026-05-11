# Current Context

Last updated: 2026-05-03

## Active summary

- PowerPilot v1.1 is the current released version.
- Release commit: `33968a2 Release PowerPilot v1.1`.
- Release tag: `v1.1`.
- GitHub release: https://github.com/JTorset66/PowerPilot/releases/tag/v1.1
- The source snapshot for this released tag is saved at `SNAPSHOTS\powerpilot-release-v1.1-2026-05-03_03-43-06.zip`.
- The latest verified build artifacts remain `build\PowerPilot_V1.1.2605.03093.exe` and `build\PowerPilot_V1.1.2605.03093_Setup.exe`.

## v1.1 battery work summary

- Added Battery Graph, PowerPilot Log, and Battery Stats tabs.
- Battery logging records timestamp, battery percent, connected/charging state, average time, instant time, Windows time, instant drain, and power/app events.
- The retained CSV log is capped to 168 hours.
- The PowerPilot Log supports multi-row selection, copying selected rows, and copying the retained log.
- The log keeps the newest row visible after refresh.
- The graph uses a gliding 24-hour window with hour marks, date/time labels, active/offline segments, and connected endpoints across sleep/offline gaps.
- Reset stats clears the log, graph samples, and current calculation state.

## estimate and battery-health summary

- Average remaining time uses elapsed on-battery history until the configured glide window is full, then rolls over that window.
- Sleep, hibernate, shutdown, startup, wake, improper shutdown, app exit, and update-close rows break average calculations so offline/app-closed time is not counted as drain time.
- Startup drain can be learned from the retained log and used immediately until fresh sample history is available.
- Battery Graph shows average, instant, Windows, wear, maximum capacity, cycle count, and `Max avg`.
- Average and `Max avg` are calculated to the configured minimum-percent sleep floor.
- `Max avg` uses the configured maximum ceiling, or the battery charge limiter ceiling when the limiter is enabled.
- PowerPilot-managed Windows plans align the DC critical battery level to the configured minimum percent, set the critical action to Sleep, and set the low warning one percent above the floor after a short debounce.

## installer and lifecycle summary

- The installer remains the elevated part; the installed tray app runs as the local user after install when possible.
- Installed app builds are side-by-side versioned executables.
- Newer-version installs can start immediately and let the new app close older PowerPilot versions in the background.
- Same-version reinstalls close only the matching executable before overwrite.
- Installer/update closes are logged as `PowerPilot update close`, not as normal app exit or PC shutdown.
- App lifecycle rows are excluded from PC off/sleep loss and graph offline markers.
- Install verification checks that no elevated installer/helper shell remains after the installer finishes.
- Important build habit: after source edits, run `build-installer.ps1` before `install-powerpilot.ps1`; otherwise the installer may reinstall the previous setup package even though `build-purebasic.ps1` produced a newer EXE.

## documentation and map

- `README.md`, `RELEASE_NOTES_v1.1.md`, and `FUNCTION_MAP.md` describe the current v1.1 application.
- `FUNCTION_MAP.md` maps the PureBasic source areas and helps future stale-code checks.
- `STARTUP_CONTEXT.md`, `CHAT_MEMORY\LATEST_BUILD.md`, `CHAT_MEMORY\LATEST_INSTALL.md`, and `CHAT_MEMORY\INDEX.md` are the first files to check when resuming.

## reminder

- Take regular snapshots or commits during active work.
- Snapshot before installer changes, major power-plan logic changes, battery-calculation edits, or any elevated install/uninstall step.
