# PowerPilot

PowerPilot is a Windows x64 tray app for three things:

- keeping three local Windows power plans named `PowerPilot Maximum`, `PowerPilot Balanced`, and `PowerPilot Battery`
- following the normal Windows power mode slider and switching between those three plans automatically
- recording a local battery, screen, and power-event history that you can view or copy

PowerPilot runs locally. It does not send your hardware, battery, or log data anywhere.

## Quick Start

1. Install PowerPilot.
2. Leave it running in the tray.
3. Use the normal Windows power mode control:
   - Best performance uses `PowerPilot Maximum`
   - Balanced uses `PowerPilot Balanced`
   - Best power efficiency uses `PowerPilot Battery`
4. Open PowerPilot when you want to inspect battery history, tune the three plans, or copy the log.

You do not manually activate PowerPilot plans inside the app. Windows power mode chooses the active PowerPilot plan while PowerPilot is running.

Windows may still show PowerPilot-owned schemes in the older power-plan list because they are real local Windows plans. The normal Settings power mode choices stay the same: efficiency, balanced, and maximum performance. PowerPilot watches that Windows mode and activates the matching PowerPilot plan while it is running.

## What The Tabs Mean

### Overview

The Overview tab answers: "What is PowerPilot doing right now?"

- `Active plan` is the Windows power plan currently active.
- `Windows mode` is the Windows power mode that PowerPilot is following.
- `Battery` and `Energy Saver` show the live battery state and the active saver policy.
- `Latest action` shows the most recent automatic or manual thing PowerPilot did.
- `Hardware` summarizes CPU, memory, graphics, and display state.
- `Battery Runtime` summarizes watts, estimates, learned full-run runtime, capacity, and wear.
- `PowerPilot` shows read/log cadence, app battery cost sampling, Energy Saver policy, and startup controls.

Useful settings:

- `Start with Windows` starts PowerPilot hidden in the tray after sign-in, reapplies saved plan settings, follows Windows power mode, and stays hidden until you open it.
- `Keep settings` keeps your PowerPilot settings during reinstall or update.
- `Show tips` enables hover explanations in the app.
- `Theme` can follow the Windows app theme or force PowerPilot to Light or Dark.

The main window uses native PureBasic tabs for navigation. The tab page itself
is sized to PureBasic's reported panel item area, while section boxes use
thin custom line borders. This keeps Light mode close to the normal Windows
look, gives Dark mode a consistent frame, and avoids hidden overlay controls
that can block checkboxes or combo boxes.

### Plans

The Plans tab answers: "What should each PowerPilot plan do?"

PowerPilot owns exactly three plans:

- `Maximum` for performance
- `Balanced` for everyday use
- `Battery` for battery life

Select a plan, adjust its values, then click `Save plan`.

Plan tuning fields:

- `Energy` tells Windows whether the CPU should favor speed or efficiency. `0` favors fastest response. `100` favors strongest efficiency.
- `CPU boost` controls boost behavior. Disabled saves power. Aggressive responds fastest.
- `Max CPU` limits maximum CPU state as a percent. `100` allows full CPU speed.
- `CPU MHz cap` sets a maximum CPU frequency. `0` means no explicit cap.
- `Cooling` chooses passive or active cooling. Passive favors lower fan use and lower clocks. Active favors cooling.

Each setting has a plugged-in value and a battery value.

### Battery Saver

The Battery Saver tab answers: "Which Windows battery-saving behavior should PowerPilot control while it is running?"

- `Energy Saver` controls Windows Energy Saver on PowerPilot-owned plans. `Automatic threshold` uses the configured battery percent. `Battery plan always` forces Energy Saver for `PowerPilot Battery`.
- `Turn on at` is the Energy Saver battery threshold and is active only in `Automatic threshold` mode. `Brightness` controls whether PowerPilot writes the Windows Energy Saver brightness scale; unchecked leaves the Windows brightness value untouched.
- `Throttle background` asks Windows to reduce safe background maintenance work in efficiency mode.
- `Deep idle saver` reduces hidden-tray wakeups to about 5 minutes, marks PowerPilot itself as background/EcoQoS while hidden, and uses deeper idle-friendly Battery plan settings.
- `Restore normal plan on exit` switches back to the last non-PowerPilot Windows plan PowerPilot saw when the app exits.
- `Low warning`, `Reserve`, `Low action`, `Critical`, and `Critical action` write Windows low/reserve/critical battery behavior to PowerPilot-owned plans. Reserve is a warning level only; Windows does not expose a separate reserve action.

### Battery Graph

The Battery Graph tab answers: "How is the battery behaving?"

`Live Status` shows battery percent, live state, remaining mWh, battery draw, voltage, and app battery use.

`Time Estimates` shows several estimates:

- `Average` uses recent logged battery movement. On battery it estimates down to `Empty at`; while charging it estimates up to `Full at` or the configured charge-limit target. If the laptop is on AC or the drain is too small to trust, PowerPilot says so instead of showing a huge runtime.
- `Now` uses the current discharging rate. While charging, PowerPilot shows `Using average` because charging time is best handled by the learned average estimate.
- `Windows` is Windows or firmware's own on-battery runtime estimate, when available. Windows usually does not report charging time.
- `Full run` estimates from the configured full point down to the configured empty point, only when PowerPilot has believable on-battery drain data.
- `Wear` compares full-charge capacity with design capacity.
- `As-new run` estimates the same full-to-empty runtime as if the battery still had its original design capacity, using the same believable-data rule.
- `Capacity` shows full-charge capacity and design capacity.
- `Cycle count` shows the battery cycle count when Windows exposes it.

The graph shows a selectable battery-percent history window on a fixed 0% to 100% scale, with hour-only labels. Choose 1, 3, 6, 12, 18, 24, 36, 48, 60, or 72 hours, or `Max` for the retained 168-hour log window. Windows up to 24 hours label every hour; longer windows label every fourth hour. Blue line segments mean normal battery samples. Green line segments mean Energy Saver was active at that point, either from Windows or PowerPilot's controlled Battery plan setting. Orange line segments mean offline/discontinued samples. Red vertical lines show sleep, wake, shutdown, startup, hibernate, improper shutdown, and other PC power events. Marker letters are compact labels: `Z` sleep/suspend, `H` hibernate, `W` wake, `S` shutdown, `P` startup, `!` improper shutdown, `0` offline, `1` online, `E` Energy Saver, and `N` normal. Thin vertical lines mark graph color changes, and crowded marker letters stack as white letters with black shadows above their line instead of being hidden. Use `Markers` on the graph tab to show or hide the marker letters and their legend.

### PowerPilot Log

The PowerPilot Log tab answers: "What happened, and can I copy the evidence?"

The log is a retained CSV file stored under your user PowerPilot settings folder. It can contain:

- battery sample rows
- screen on, screen dim, and screen off rows
- Energy Saver on/off rows when Windows toggles battery saver
- PC power-event rows such as sleep, wake, shutdown, startup, hibernate, and improper shutdown
- app rows such as PowerPilot start, exit, update close, and short status messages

Log settings:

- `Log samples` turns battery sample logging on or off.
- `Log every` controls how often a saved battery row is written and is active only when `Log samples` is checked.
- `Read every` controls how often live battery data is refreshed while the window is open. The default is 5 seconds for a responsive visible window. Tray mode backs off to about 5 minutes to reduce background wakeups.
- `Empty at` is the battery percent treated as empty for PowerPilot estimates. It can be 0%; Windows low and critical battery behavior is on the Battery Saver tab.
- `Full at` is the percent treated as full for graph, charging target, and full-run estimates.
- `Use charge limit` uses the laptop charge limit as the full point.
- `Average window` controls how much recent history is averaged. Longer is calmer. Shorter reacts faster.
- `Startup drain` is a temporary percent-per-hour drain used until fresh samples are available.
- `Reset log` clears retained battery log rows, graph history, and current estimate learning.

PowerPilot also keeps a capped learned charging rate in its user settings, up to 32 recent charging-learning updates. That gives future charging sessions a better first estimate before enough fresh percent movement has accumulated.

Log columns:

- `Timestamp` is shown as `YYYY-MM-DD HH:MM:SS` in the table. `Copy CSV` keeps the stored ISO-style timestamp.
- `Battery %` is battery percent.
- `Avg time` is average time to `Empty at` while discharging, or to the configured full target while charging.
- `Instant time` is time based on the current discharging rate; while charging, the visible app uses the average estimate.
- `Win time` is Windows or firmware's runtime estimate.
- `Now rate` is the current percent-per-hour charging or discharging rate.
- `Plugged in` says whether external power was present.
- `Batt W` is battery charging/discharging power. The app display shows this as live battery draw; CSV values keep separate charging and discharging fields.
- `Screen` shows screen on, screen dim, or screen off events.
- `Laptop %` is built-in laptop screen brightness percent when Windows exposes it. PowerPilot first tries monitor WMI for the internal panel, then a conservative `Dxva2.dll` fallback when the display layout is unambiguous. If neither path is trustworthy, the cell stays blank.

During vendor battery calibration, Windows can report plugged in and discharging at the same time. PowerPilot treats that as active battery use while still showing that external power is present.

Copy buttons:

- `Copy rows` copies selected visible rows. If no row is selected, it copies the newest visible row.
- `Copy CSV` copies the full retained CSV log.

### Battery Stats

The Battery Stats tab answers: "What happened today?"

- `Latest Event` shows the latest sleep, wake, shutdown, startup, hibernate, or improper-shutdown event PowerPilot saw.
- `Sleep/Off Loss` estimates battery percent lost across sleep, hibernate, shutdown, startup, or large missing-sample gaps.
- `Today` shows battery range, active on-battery time, active drain, wear, and cycle count.
- `Visible Log Columns` hides or shows optional columns in the PowerPilot Log tab: average time, now/rate, Windows time, plugged-in state, battery watts, screen event, laptop brightness, and event rows including Energy Saver changes.
- `Battery Analysis` shows when analysis last ran, the retained rows/spans pulled, the covered time interval, stable capacity, normal power, runtime, calibration, charging, and a local stats-helper note. `Refresh analysis` forces a fresh battery read/log row before rebuilding it.
- `Export settings` and `Import settings` save or restore PowerPilot settings as an INI file.

`Avg active drain` is the average battery drop per hour while the laptop was awake and on battery. `Total battery used today` adds up each on-battery discharging period. Example: 80% to 60% counts as 20%; after charging back to 90%, 90% to 70% counts as another 20%. Recharging does not subtract from the total, so the value can go over 100% in one day.

Settings backup is optional. Normal reinstall/update keeps settings when `Keep settings` is enabled.

### Power Use

The Power Use tab answers: "How much battery might this app be costing?"

PowerPilot estimates app battery cost from process CPU time over a gliding 60-second live window and a configurable average window. The Battery Graph `Avg use` row defaults to 10 minutes and lets you choose 1 to 60 minutes.

`CPU time` is normalized to total logical CPU capacity. It tops out at 60 seconds when PowerPilot uses all logical CPUs for the whole 60-second window.

`CPU load` is shown as a share of total logical CPU capacity, not as a share of one core. This matches the live mW estimate below it; the average mW uses the selected average length.

```text
PowerPilot mW =
  normalized PowerPilot CPU seconds / sample seconds * battery discharging basis mW
```

When the laptop is on battery, the discharging basis is the current battery discharging power reported by Windows. When the laptop is plugged in, PowerPilot keeps the estimate going from the current full-charge capacity and the learned average discharging rate.

The full-to-empty battery cost estimates how many seconds of battery runtime this app may consume across the configured `Full at` to `Empty at` range. For example, `about 5 sec` means the current estimate says PowerPilot would account for about five seconds of that usable battery window if the same app CPU share continued.

This is an estimate, not a hardware power meter. It does not include display, device, memory, or OS background wake costs.

The lower half of the tab explains how to read the estimate and gives an idle-investigation checklist. Use it when comparing visible-window, tray-hidden, screen-off, and screen-on behavior.

The checklist points you toward:

- visible versus tray-hidden behavior
- screen on, dim, and off log rows
- unexpected wake or update-close rows
- old app versions still running
- Windows tools such as Task Manager or Energy report for causes outside PowerPilot

### Battery Test

The Battery Test tab answers: "What is this battery test doing right now?"

It is a monitor and guided workflow, not a vendor firmware controller.

- `Manual test` starts a report and prompts you to unplug. PowerPilot tracks the discharge part, then switches to charge recovery when you plug in again.
- `Calibration` waits for the charger, starts the saved drain helper target when plugged-in calibration discharge begins, stops load when charging starts, and saves a `.txt` report when charging reaches idle.
- `Vendor calibration detected` appears automatically when Windows reports plugged in and discharging at the same time.
- `Charge recovery` tracks charging back to the configured `Full at` or charge-limit target.
- `Report and Log` shows a short screen summary. `Open report` opens the latest saved Battery Test report. `Copy report` copies start/end percent, mWh used/charged, average discharge and charge watts, observed runtime, and capacity notes.
- `Calibration Drain Helper` automatically targets a chosen drain time with filtered PI-style load changes about every 10 seconds, starting gently during plugged-in calibration discharge, and stops when charging starts. `Test mode` adds detailed controller rows for tuning runs.
- While Battery Test is the selected tab, live test stats refresh about once per second. Other tabs keep the normal battery read interval.
- Battery Test uses current discharge watts for its time-to-empty estimate while discharging, so it reacts faster than the normal smoothed Battery Graph estimate.

The PowerPilot Log also gets clear `BATTERY TEST` rows for test start, samples, vendor calibration detection, calibration phases, drain-helper actions, and test end. Saved reports live in `%APPDATA%\PowerPilot\reports`.

### About

The About tab answers: "What does this app do?"

It includes:

- the current PowerPilot version
- `PowerPilot`: the short purpose of the app
- `Plan Follow`: how Windows power mode maps to PowerPilot Maximum, Balanced, and Battery
- `Logged Data`: battery fields, screen state, brightness, Energy Saver, power events, and app status rows
- `Local Data`: what PowerPilot reads locally, what it writes locally, and that it sends nothing by itself
- `Files`: Store developer identity, copyright, MIT license, included documentation, uninstall reference, plus `USER MANUAL`, `README`, and `LICENSE` buttons
- `Important Boundaries`: what PowerPilot cannot directly measure, including CPU package watts, display watts, fan power, temperature, Wi-Fi, storage, GPU load, and other apps

This tab is intended as an in-app reference so the main behavior is understandable without opening external docs.

## Default Plan Behavior

PowerPilot applies visible CPU settings plus selected Windows platform power policy on top of the Windows plan it was created from.

- `PowerPilot Maximum` favors plugged-in performance: low energy preference, aggressive AC boost, 100% max CPU, no frequency cap, active cooling, and CPU idle still enabled.
- `PowerPilot Balanced` stays close to Windows Balanced: moderate energy preference, AC boost enabled, DC boost disabled, 100% max CPU, no frequency cap, active AC cooling, passive DC cooling, and CPU idle enabled.
- `PowerPilot Battery` favors battery life: disabled boost, lower max CPU, MHz caps, passive cooling, low-power GPU preference, maximum PCIe link saving, DC device-idle saving, disabled DC standby networking, shorter DC display/disk/sleep timeouts, DC hibernate after 30 minutes, disabled DC wake timers, deeper idle-friendly behavior when Deep idle saver is enabled, and CPU idle enabled. PowerPilot keeps the schemes Balanced-derived so they remain visible on Modern Standby systems.

Windows firmware, chipset drivers, and hidden processor settings can still affect the exact behavior available on a device.

## Brightness And Screen Events

Screen events are logged from Windows session display-state notifications:

- screen on
- screen dim
- screen off

Brightness is sampled only on normal battery sample rows, and skipped while the logged screen state is off. That avoids adding a frequent brightness poll while the app is idle.

Brightness lookup order:

1. Match `root\wmi:WmiMonitorBrightness` to the built-in laptop panel using `root\wmi:WmiMonitorConnectionParams`.
2. If monitor WMI is unavailable, try Windows `Dxva2.dll` monitor brightness APIs only when the layout is unambiguous.
3. Leave the brightness cell blank if PowerPilot cannot tell which display is the laptop panel.

## Installer Behavior

The installer:

- installs into `Program Files\PowerPilot`
- creates a desktop shortcut
- shows final setup status after file copy while it refreshes plans, handles settings, registers startup, and starts the tray app
- registers PowerPilot to start with Windows using `/startup`
- launches PowerPilot hidden into the notification area after installation
- requires administrator approval for setup, then runs post-install commands and the tray app as the current user without UAC elevation
- keeps user settings during reinstall when the app preference is enabled
- installs newer stamped versions side-by-side
- writes a `PowerPilot update close` app-log row when replacing a running copy
- lets the newly launched app close older `PowerPilot_V*.exe` versions in the background
- removes stale versioned app files after install
- creates missing PowerPilot-owned plans and refreshes their current CPU, battery, Energy Saver, and hidden platform policy during normal updates and hidden startup without deleting existing plan GUIDs
- checks after install that setup and cleanup processes have exited
- supports repair and uninstall from Windows Apps/Programs

The uninstaller removes installed files, the Windows startup entry, PowerPilot-owned plans, and old prototype `Codex *` plans.

## Command-Line Build

Build the app:

```powershell
.\build-purebasic.ps1
```

Build the installer:

```powershell
.\build-installer.ps1
```

The installer build produces:

- `build\PowerPilot_V1.2.YYMM.minute-of-month.exe`
- `build\PowerPilot_V1.2.YYMM.minute-of-month_Setup.exe`

## Build Requirements

- PureBasic x64
- Windows target
- Thread Safe runtime enabled
- Inno Setup 6 for installer builds

## Privacy

PowerPilot reads local hardware and battery data from Windows APIs and providers. It writes local settings, local logs, local Windows power-plan settings, and the local Windows startup entry.

PowerPilot does not transfer information to networked systems unless the user or operator specifically asks for that outside the app.

Full privacy policy: [`PRIVACY_POLICY.md`](PRIVACY_POLICY.md)

## Repository Guide

- `PowerPilot_V1.2.pb` is the main PureBasic source file.
- `build-purebasic.ps1` builds the app executable.
- `build-installer.ps1` builds the installer and records build context.
- `install-powerpilot.ps1` installs the newest setup artifact.
- `FUNCTION_MAP.md` explains the source layout.
- `docs\framework\README.md` is the full build-from-scratch framework documentation set.
- `USER_MANUAL.txt` is the detailed user manual bundled with the installer and opened from About.
- `INSTALLER_README.md` is the source for the quick user guide bundled into the installer as `README.txt`.
- `RELEASE_CHECKLIST.md` summarizes release steps.
- `PRIVACY_POLICY.md` is the public privacy policy for GitHub and Microsoft Store listing use.
- `MICROSOFT_STORE_SUBMISSION.md` records Store-facing publisher, support, privacy, and certification notes.
- `CODE_SIGNING_POLICY.md` documents signing policy.
- `SIGNPATH_APPLICATION.md` tracks SignPath Foundation application material.
- `POWERPILOT_LEARNINGS.md` captures implementation lessons that should survive chat/history cleanup.

## License

This project is licensed under the MIT License. See `LICENSE` in the source tree or installed `LICENSE.txt`.

## Copyright

Copyright: Dofta

Publisher / Microsoft Store developer name: Dofta
