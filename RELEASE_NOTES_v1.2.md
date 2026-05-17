# PowerPilot v1.2.2605.23851

PowerPilot v1.2 is the next release line after v1.1. It keeps the same fixed-plan model while tightening hidden startup, tray behavior, dependent settings, layout, and view scaling.

Current release build: `v1.2.2605.23851`.

## Highlights

- Hidden startup uses `/startup` so PowerPilot starts in the tray after install and sign-in, reapplies saved plan settings, follows Windows power mode, and stays hidden until opened.
- Tray activation shows the already-created window quickly, then refreshes stale visible data after the first paint.
- Battery Saver brightness now has a checkbox; unchecked means PowerPilot leaves the Windows Energy Saver brightness setting untouched.
- Dependent controls now gray out when inactive:
  - `Turn on at` when Energy Saver mode is `Battery plan always`
  - `Brightness` when brightness writing is unchecked
  - `Log every` when sample logging is unchecked
  - charge-limit percent when `Use charge limit` is unchecked
- PowerPilot Log sampling controls were realigned into a cleaner grid with consistent units and spacing.
- Battery Graph now includes 1-hour, 3-hour, and Max history windows for close-up checks or the full retained 168-hour log window.
- Battery Graph live status now shows a configurable app-use average, defaulting to 10 minutes.
- Theme switching now keeps the window visible while locking repaint until the dark/light update is complete.
- The desktop UI was polished with a Fluent-like light/dark surface, stronger frame titles, and clipping fixes for About, Low Battery Guard, and Battery Graph frame spacing.
- Overview hardware details are aligned in one left column, with a saved `Zoom factor` selector on the right.
- View zoom supports 50%, 75%, 100%, 125%, and 150% content scaling without shrinking the window shell.
- Build and release artifacts now use the `PowerPilot_V1.2...` filename line.
- Public publisher / Microsoft Store developer name is Dofta, with a GitHub-hosted privacy policy and support contact to avoid exposing a personal email address.

## Source And Build

- Main source: `PowerPilot_V1.2.pb`
- Default build stamping: `1.2.YYMM.minute-of-month`
- Executable pattern: `PowerPilot_V1.2.YYMM.minute-of-month.exe`
- Installer pattern: `PowerPilot_V1.2.YYMM.minute-of-month_Setup.exe`

## Final Local Artifacts

- `PowerPilot_V1.2.2605.23851.exe`
  - SHA-256: `95f771747271be961f7bd345e3f4b950ba9a4f8dae21991235abb8bed6fafe8a`
- `PowerPilot_V1.2.2605.23851_Setup.exe`
  - SHA-256: `3c9d01920d4ef256985a1be7dd61ee08af519d4120577ca5a3cdb32c1e4f115e`

## Verification

Before publishing a stamped v1.2 release:

- Run `.\build-purebasic.ps1`
- Run `.\tests\battery-log-regression.ps1`
- Run `.\build-installer.ps1`
- Install the generated setup and confirm PowerPilot starts hidden in the tray
- Confirm `Zoom factor` scales tab contents without shrinking the main window shell
- Confirm About shows Store developer/copyright as Dofta
