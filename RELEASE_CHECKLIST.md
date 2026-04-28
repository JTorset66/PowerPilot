# Release Checklist

Use this checklist for public PowerPilot releases.

## Before tagging

- Confirm the intended version number in `PowerPilot_V1.0.pb`.
- Review `README.md` for installer, startup, and tray-behavior notes.
- Confirm the project still matches the statements in `CODE_SIGNING_POLICY.md`.
- Build locally with:

```powershell
.\build-purebasic.ps1
.\build-installer.ps1
```

- Verify the executable and installer exist in `build\`.
- If signing is available, sign and verify the executable and installer before release.
- Test-install the built installer on Windows.
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
- Verify the release assets include the `.exe`, installer, and `.sha256` files.
- Add or review release notes on GitHub.
