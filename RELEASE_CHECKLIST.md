# Release Checklist

Use this checklist for public PowerPilot releases.

## Before tagging

- Confirm the intended version number in `PowerPilot_V1.0.pb` and `powerpilot.iss`.
- Review `README.md` for current installer, startup, tray, plan-maker, and hardware-info behavior.
- Review `INSTALLER_README.md` for user-facing app functionality and usage changes.
- Confirm `THIRD_PARTY_NOTICES.md` is included with the installer and still matches bundled assets.
- Confirm the installer includes `INSTALLER_README.md` as installed `README.md`.
- Confirm the installer creates a desktop shortcut.
- Confirm the project still matches the statements in `CODE_SIGNING_POLICY.md`.
- Confirm the SignPath notes in `SIGNPATH_APPLICATION.md` are still accurate.
- Build locally with:

```powershell
.\build-purebasic.ps1
.\build-installer.ps1
```

- Verify the executable and installer exist in `build\`.
- If signing is available, sign and verify the executable and installer before release.
- Test-launch the built executable on Windows.
- Test-install the built installer on Windows.
- Confirm the installer "Read Included Files" page opens the README, license, and third-party notices.
- Confirm the app starts in the tray after install.
- Confirm the installed desktop shortcut launches PowerPilot.
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
- Create an annotated tag using the release version.

## GitHub release

- Push `main`.
- Push the version tag.
- Confirm the GitHub Actions workflow completes successfully on the self-hosted Windows runner.
- Verify the release assets include the expected `.exe` files and `.sha256` files.
- Confirm the installer and published executables have valid signatures when signing is enabled.
- Add or review release notes on GitHub.

## After release

- Download the published assets from GitHub.
- Verify SHA-256 checksums against the published `.sha256` files.
- Verify the Authenticode signer and timestamp on signed artifacts.
- Install from the downloaded installer on a clean Windows test machine when possible.
- Confirm `README.md`, `CODE_SIGNING_POLICY.md`, and `SIGNPATH_APPLICATION.md` still describe the published state accurately.
