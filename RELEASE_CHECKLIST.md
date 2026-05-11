# Release Checklist

Use this checklist for public PowerPilot releases.

## Before tagging

- Confirm the intended version number in `PowerPilot_V1.1.pb` and `powerpilot.iss`.
- Confirm the full stamped release version from the build metadata, using the full `v1.1.YYMM.minute-of-month` style version for the public release and generated artifact filenames instead of short `v1.1` filenames.
- Review `README.md` for current installer, startup, tray, plan-maker, PowerPilot Log, battery graph, battery stats, and hardware-info behavior.
- Review `INSTALLER_README.md` for user-facing app functionality and usage changes.
- Review `FUNCTION_MAP.md` after major PureBasic source changes.
- Confirm `THIRD_PARTY_NOTICES.md` is included with the installer as `THIRD_PARTY_NOTICES.txt` and still matches bundled assets.
- Confirm the installer includes `INSTALLER_README.md` as installed `README.txt`.
- Confirm the installer includes `LICENSE` as installed `LICENSE.txt`.
- Confirm the installer creates a desktop shortcut.
- Confirm the installed desktop shortcut uses `powerpilot_desktop.ico` and shows the green shield.
- Confirm the tray icon uses `powerpilot_tray.ico` and shows the green shield.
- Confirm the project still matches the statements in `CODE_SIGNING_POLICY.md`.
- Confirm the SignPath notes in `SIGNPATH_APPLICATION.md` are still accurate.
- Build locally with:

```powershell
.\build-purebasic.ps1
.\build-installer.ps1
```

- Verify the executable and installer exist in `build\`.
- Confirm the executable and installer filenames include the full stamped version, for example `PowerPilot_V1.1.2605.01042.exe` and `PowerPilot_V1.1.2605.01042_Setup.exe`.
- If signing is available, sign and verify the executable and installer before release.
- Test-launch the built executable on Windows.
- Test-install the built installer on Windows.
- Confirm the installer "Read Included Files" page opens the README, license, and third-party notices.
- Confirm the app starts in the tray after install.
- Confirm reinstall/repair closes older running `PowerPilot_V*.exe` processes and leaves only the current stamped app executable in `Program Files\PowerPilot`.
- Confirm the install helper reports clear post-install elevated/setup/cleanup process checks.
- Confirm the installed desktop shortcut launches PowerPilot.
- Confirm Battery Graph shows live battery values, average/instant/Windows estimates, and selectable 6- to 72-hour graph windows.
- Confirm Battery Saver writes Energy Saver, low/reserve/critical battery settings, and restore-on-exit behavior to PowerPilot-owned plans only.
- Confirm PowerPilot-owned plans remain Balanced-derived so they stay visible on Modern Standby systems while still mapping Windows power mode to Maximum, Balanced, and Battery.
- Confirm plan activation succeeds as a normal user through the native `PowerSetActiveScheme` path, with `powercfg /SETACTIVE` only as fallback.
- Confirm `PowerPilot Battery` has hidden saving policy applied: low-power GPU, PCIe maximum saving, DC device idle, disabled DC standby networking, aggressive disconnected standby on DC, DC display/disk/sleep timeouts, DC hibernate, and disabled DC wake timers.
- Confirm the reserve battery level writes through the raw Windows reserve GUID when permissions allow it.
- Confirm PowerPilot Log shows retained battery samples, app status rows, event rows, Windows runtime, multi-row selection, and copy buttons.
- Confirm Battery Stats summaries exclude app lifecycle gaps from PC off/sleep loss and drain averages.
- Confirm the Plans tab Purpose column has enough width to show full text at the tested window scale.
- Confirm `PowerPilot Balanced` is close to Windows Balanced: 100% max CPU, AC boost enabled, DC boost disabled, no frequency cap, and CPU idle enabled.
- Confirm `PowerPilot Maximum` uses aggressive AC boost, AC energy preference `0`, 100% max CPU, no frequency cap, and CPU idle enabled.
- Confirm the installed maintenance entry offers Repair install and Uninstall.
- Confirm uninstall removes the startup entry and PowerPilot-owned plans.
- Confirm GitHub MFA is enabled for the maintainer account.

## Git preparation

- Review pending changes:

```powershell
git status
git diff --stat
```

- Commit the release-ready state.
- Create an annotated tag using the full stamped release version, for example `v1.1.2605.01042`.
- Confirm the version tag matches the four-part `#AppVersion$` exactly so the workflow and local artifact names stay aligned.

## GitHub release

- Push `main`.
- Push the version tag.
- Confirm the GitHub Actions workflow completes successfully on the self-hosted Windows runner.
- Verify the release assets include the expected `.exe` files and `.sha256` files.
- Publish or attach the versioned app EXE, setup EXE, and matching `.sha256` files.
- Confirm the installer and published executables have valid signatures when signing is enabled.
- Add or review release notes on GitHub, using the full stamped version in the release title and notes.

## After release

- Download the published assets from GitHub.
- Verify SHA-256 checksums against the published `.sha256` files.
- Verify the Authenticode signer and timestamp on signed artifacts.
- Install from the downloaded installer on a clean Windows test machine when possible.
- Confirm `README.md`, `CODE_SIGNING_POLICY.md`, and `SIGNPATH_APPLICATION.md` still describe the published state accurately.
