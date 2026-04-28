# Release Checklist

Use this checklist for public PowerPilot releases.

## Before tagging

- Confirm the intended version number in `PowerPilot_V1.0.pb` and `powerpilot.iss`.
- Review `README.md` for current installer, startup, tray, telemetry, and Auto Cool behavior.
- Confirm the project still matches the statements in `CODE_SIGNING_POLICY.md`.
- Confirm the SignPath notes in `SIGNPATH_APPLICATION.md` are still accurate.
- Build locally with:

```powershell
.\build-purebasic.ps1
.\build-installer.ps1
```

- Verify the executable, helper executables, and installer exist in `build\`.
- If signing is available, sign and verify the executable, helper executables, and installer before release.
- Test-install the built installer on Windows.
- Confirm the app starts in the tray after install.
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
