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

## What The Tabs Mean

### Overview

The Overview tab answers: "What is PowerPilot doing right now?"

- `Active plan` is the Windows power plan currently active.
- `Windows mode` is the Windows power mode that PowerPilot is following.
- `Latest action` shows the most recent automatic or manual thing PowerPilot did.
- `Processor` and `Graphics` show local hardware information. Graphics rows come from Windows display-adapter enumeration, keep Windows `active` and `primary` flags, label likely integrated and separate GPUs, and refine generic AMD/Intel iGPU names when the local CPU name makes that safe.
- `Startup and Idle` controls how PowerPilot behaves when Windows starts, when PowerPilot is hidden, and during efficiency mode.

Useful settings:

- `Start with Windows` starts PowerPilot in the tray after sign-in.
- `Keep settings` keeps your PowerPilot settings during reinstall or update.
- `Throttle background` asks Windows to reduce safe background maintenance work in efficiency mode.
- `Deep idle saver` reduces hidden-tray wakeups to about 5 minutes, marks PowerPilot itself as background/EcoQoS while hidden, and uses deeper idle-friendly Battery plan settings.
- `Show tips` enables hover explanations in the app.

### Plans

The Plans tab answers: "What should each PowerPilot plan do?"

PowerPilot owns exactly three plans:

- `Maximum` for performance
- `Balanced` for everyday use
- `Battery` for battery life

Select a plan, adjust its values, then click `Save plan`.

Plan tuning fields:

- `Energy pref` tells Windows whether the CPU should favor speed or efficiency. `0` favors fastest response. `100` favors strongest efficiency.
- `CPU boost` controls boost behavior. Disabled saves power. Aggressive responds fastest.
- `Max CPU` limits maximum CPU state as a percent. `100` allows full CPU speed.
- `CPU MHz cap` sets a maximum CPU frequency. `0` means no explicit cap.
- `Cooling` chooses passive or active cooling. Passive favors lower fan use and lower clocks. Active favors cooling.
- `Energy saver` controls Windows Energy Saver for PowerPilot plans. `Follow Windows` uses normal automatic behavior. `On for Battery plan` applies Energy Saver only to the Battery plan.

Each setting has a plugged-in value and a battery value.

### Battery Graph

The Battery Graph tab answers: "How is the battery behaving?"

`Live Battery Status` shows the current battery percent, combined live state, remaining mWh, battery draw, voltage, and PowerPilot's own estimated battery use.

`Battery Time` shows several estimates:

- `Average` uses recent logged battery movement. On battery it estimates down to `Empty at`; while charging it estimates up to `Full at` or the configured charge-limit target.
- `Now` uses the current discharging rate. While charging, PowerPilot shows `Using average` because charging time is best handled by the learned average estimate.
- `Windows` is Windows or firmware's own on-battery runtime estimate, when available. Windows usually does not report charging time.
- `Full-to-min` estimates from your configured full point down to your configured empty point.
- `Wear` compares full-charge capacity with design capacity.
- `As new` estimates the same full-to-empty runtime as if the battery still had its original design capacity.
- `Max capacity` shows full-charge capacity and design capacity.
- `Cycle count` shows the battery cycle count when Windows exposes it.

The graph shows a selectable battery-percent history window on a fixed 0% to 100% scale, with hour-only labels. Choose 6, 12, 18, 24, 36, 48, 60, or 72 hours. Windows up to 24 hours label every hour; longer windows label every fourth hour. Blue line segments mean normal battery samples. Green line segments mean Energy Saver was active at that point, either from Windows or PowerPilot's controlled Battery plan setting. Red segments and markers show sleep, wake, shutdown, startup, hibernate, improper shutdown, and other power gaps. Marker letters are compact labels: `Z` sleep/suspend, `H` hibernate, `W` wake, `S` shutdown, `P` startup, `!` improper shutdown, `O` offline or missing samples, `E` Energy Saver, and `N` normal. Thin vertical lines mark graph color changes. `E` and `N` labels are skipped when the view is crowded.

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
- `Log every` controls how often a saved battery row is written.
- `Read every` controls how often live battery data is refreshed while the window is open. The default is 5 seconds for a responsive visible window. Tray mode backs off to about 5 minutes to reduce background wakeups.
- `Empty at` is the battery percent treated as empty for estimates. It can be 0%; when PowerPilot writes Windows critical sleep settings, Windows is kept at least 1%.
- `Full at` is the percent treated as full for graph, charging target, and full-to-min estimates.
- `Use charge limit` uses your laptop's charging limit as the full point.
- `Average window` controls how much recent history is averaged. Longer is calmer. Shorter reacts faster.
- `Startup estimate` is a temporary percent-per-hour drain used until fresh samples are available.
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

- `Latest Power Event` shows the latest sleep, wake, shutdown, startup, hibernate, or improper-shutdown event PowerPilot saw.
- `Sleep/Off Battery Loss` estimates battery percent lost across sleep, hibernate, shutdown, startup, or large missing-sample gaps.
- `Daily Battery Summary` shows today's battery range, active on-battery time, active drain, wear, and cycle count.
- `Shown Log Columns` hides or shows optional columns in the PowerPilot Log tab: average time, now/rate, Windows time, plugged-in state, battery watts, screen event, laptop brightness, and event rows including Energy Saver changes.
- `Settings Backup` exports or imports your PowerPilot settings as an INI file.

`Avg active drain` is the average battery drop per hour while the laptop was awake and on battery. `Total battery used today` adds up each on-battery discharging period. Example: 80% to 60% counts as 20%; after charging back to 90%, 90% to 70% counts as another 20%. Recharging does not subtract from the total, so the value can go over 100% in one day.

Settings backup is optional. Normal reinstall/update keeps settings when `Keep settings` is enabled.

### Power Use

The Power Use tab answers: "How much battery might PowerPilot itself be costing?"

PowerPilot estimates its own battery cost from its process CPU time over a gliding 60-second window.

`PowerPilot CPU time in that 60s` is CPU time accumulated by the PowerPilot process during the last 60 seconds. It can be much lower than 60 seconds when the app is mostly idle.

`CPU load` is shown as a share of total logical CPU capacity, not as a share of one core. This matches the mW estimate below it.

```text
PowerPilot mW =
  PowerPilot CPU seconds / (sample seconds * logical CPU count) * battery discharging basis mW
```

When the laptop is on battery, the discharging basis is the current battery discharging power reported by Windows. When the laptop is plugged in, PowerPilot keeps the estimate going from the current full-charge capacity and the learned average discharging rate.

The full-to-empty battery cost estimates how many seconds of battery runtime PowerPilot may consume across your configured `Full at` to `Empty at` range. For example, `about 5 sec` means the current estimate says PowerPilot itself would account for about five seconds of that whole usable battery window if the same app CPU share continued.

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

- `Manual discharge test` starts a report and prompts you to unplug. PowerPilot tracks the discharge part, then switches to charge recovery when you plug in again.
- `Lenovo reset` waits for the charger, starts the saved drain helper target when Lenovo plugged-in discharge begins, stops load when charging starts, and saves a `.txt` report when charging reaches idle.
- `Vendor calibration detected` appears automatically when Windows reports plugged in and discharging at the same time, such as Lenovo calibration discharge mode.
- `Charge recovery` tracks charging back to your configured `Full at` or charge-limit target.
- `Open report` opens the latest saved Battery Test report. `Copy report` copies start/end percent, mWh used/charged, average discharge and charge watts, observed runtime, and capacity notes.
- `CPU Load` automatically targets a chosen drain time with filtered PI-style load changes about every 10 seconds, starting at 25%, and stops when charging starts. `Test mode` adds detailed controller rows for normal unplug tuning runs.
- While Battery Test is the selected tab, live test stats refresh about once per second. Other tabs keep the normal battery read interval.
- Battery Test uses current discharge watts for its time-to-empty estimate while discharging, so it reacts faster than the normal smoothed Battery Graph estimate.

The PowerPilot Log also gets clear `BATTERY TEST` rows for test start, samples, vendor calibration detection, Lenovo reset phases, drain-helper actions, and test end. Saved reports live in `%APPDATA%\PowerPilot\reports`.

### About

The About tab answers: "What is this app doing on my system?"

It includes:

- the current PowerPilot version
- `PowerPilot`: the short purpose of the app
- `Automatic Plan Follow`: how Windows power mode maps to PowerPilot Maximum, Balanced, and Battery
- `What It Tracks`: battery fields, screen on/dim/off, Energy Saver on/off, laptop-panel brightness, power events, and app status rows
- `Local Data And Privacy`: what PowerPilot reads locally, what it writes locally, and the fact that it does not send data anywhere by itself
- `License And Files`: author, MIT license summary, included documentation, update behavior, uninstall reference, plus `Open README` and `Open LICENSE` buttons that use the user's chosen `.txt` editor
- `Important Boundaries`: what PowerPilot cannot directly measure, including CPU package watts, display watts, fan power, temperature, Wi-Fi, storage, GPU load, and other apps

This tab is intended as an in-app reference so the main behavior is understandable without opening external docs.

## Default Plan Behavior

PowerPilot applies a small set of CPU-related settings on top of the Windows plan it was created from.

- `PowerPilot Maximum` favors plugged-in performance: low energy preference, aggressive AC boost, 100% max CPU, no frequency cap, active cooling, and CPU idle still enabled.
- `PowerPilot Balanced` stays close to Windows Balanced: moderate energy preference, AC boost enabled, DC boost disabled, 100% max CPU, no frequency cap, active AC cooling, passive DC cooling, and CPU idle enabled.
- `PowerPilot Battery` favors battery life: disabled boost, lower max CPU, MHz caps, passive cooling, deeper idle-friendly behavior when Deep idle saver is enabled, and CPU idle enabled.

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
- registers PowerPilot to start with Windows using `/tray`
- launches PowerPilot into the notification area after installation
- requires administrator approval for setup, then runs post-install commands and the tray app as the current user without UAC elevation
- keeps user settings during reinstall when the app preference is enabled
- installs newer stamped versions side-by-side
- writes a `PowerPilot update close` app-log row when replacing a running copy
- lets the newly launched app close older `PowerPilot_V*.exe` versions in the background
- removes stale versioned app files after install
- repairs missing PowerPilot-owned plans during normal updates without recreating existing plans
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

- `build\PowerPilot_V1.1.YYMM.minute-of-month.exe`
- `build\PowerPilot_V1.1.YYMM.minute-of-month_Setup.exe`

## Build Requirements

- PureBasic x64
- Windows target
- Thread Safe runtime enabled
- Inno Setup 6 for installer builds

## Privacy

PowerPilot reads local hardware and battery data from Windows APIs and providers. It writes local settings, local logs, local Windows power-plan settings, and the local Windows startup entry.

PowerPilot does not transfer information to networked systems unless the user or operator specifically asks for that outside the app.

## Repository Guide

- `PowerPilot_V1.1.pb` is the main PureBasic source file.
- `build-purebasic.ps1` builds the app executable.
- `build-installer.ps1` builds the installer and records build context.
- `install-powerpilot.ps1` installs the newest setup artifact.
- `FUNCTION_MAP.md` explains the source layout.
- `docs\framework\README.md` is the full build-from-scratch framework documentation set.
- `INSTALLER_README.md` is the source for the user guide bundled into the installer as `README.txt`.
- `RELEASE_CHECKLIST.md` summarizes release steps.
- `CODE_SIGNING_POLICY.md` documents signing policy.

## License

This project is licensed under the MIT License. See `LICENSE` in the source tree or installed `LICENSE.txt`.

## Author

John Torset
