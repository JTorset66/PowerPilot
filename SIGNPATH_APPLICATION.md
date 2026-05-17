# SignPath Foundation Application Notes

This document keeps the SignPath Foundation application material and current status for PowerPilot.

Current status: SignPath Foundation onboarding is not active for this release state. The project can still use these notes if the free signing path is reopened, but public release documentation should not claim SignPath signing is available until it is approved and integrated.

## Project summary

- Project name: PowerPilot
- Project handle: powerpilot
- Public publisher / Microsoft Store developer name: Dofta
- Repository: <https://github.com/JTorset66/PowerPilot>
- Current release target: v1.2
- License: MIT
- Maintainer: John Torset
- Primary platform: Windows x64
- Project description: PureBasic tray application for editing three fixed local Windows power plans, following Windows power mode, managing startup behavior, handling clean install/uninstall, showing local CPU/GPU/battery information, and retaining a local PowerPilot battery/status log

## Why this project fits the program

- The repository is public.
- The project source uses the OSI-approved MIT License.
- The published release artifacts are built from the repository source.
- The repository includes a public code signing policy and privacy statement.
- The installer includes a user-focused guide from `INSTALLER_README.md` as `README.txt`, the MIT license as `LICENSE.txt`, and third-party notices as `THIRD_PARTY_NOTICES.txt`.
- The application does not include network telemetry or data transfer unless explicitly requested by the user or operator.
- The project is a user-facing Windows desktop utility where trusted code signing materially improves install and run experience.

## Current public links

- Repository home: <https://github.com/JTorset66/PowerPilot>
- Code signing policy: <https://github.com/JTorset66/PowerPilot/blob/main/CODE_SIGNING_POLICY.md>
- Privacy policy: <https://github.com/JTorset66/PowerPilot/blob/main/PRIVACY_POLICY.md>
- Release checklist: <https://github.com/JTorset66/PowerPilot/blob/main/RELEASE_CHECKLIST.md>
- Release workflow: <https://github.com/JTorset66/PowerPilot/blob/main/.github/workflows/release-self-hosted.yml>

## Expected release artifacts

- `PowerPilot_V1.2.YYMM.minute-of-month.exe`
- `PowerPilot_V1.2.YYMM.minute-of-month_Setup.exe`
- SHA-256 checksum files for published executables

## Compliance notes against SignPath Foundation terms

### License and source availability

- All repository content intended for release is open source under the MIT License.
- There is no commercial dual-licensing statement in the repository.
- The project does not intentionally bundle proprietary maintainer-owned components.

### Released and documented

- The repository README describes the software, build requirements, runtime notes, installer behavior, and usage.
- `INSTALLER_README.md` is the source for the user-facing `README.txt` bundled into the installer and focuses on PowerPilot functionality rather than build/release details.
- The repository includes third-party notices for the release package.
- The repository includes a release checklist and a self-hosted Windows GitHub Actions workflow.
- Current public binaries may be unsigned until signing onboarding is complete.

### Privacy and user safety

- The project states: "This program does not transfer information to other networked systems unless specifically requested by the user or the person installing or operating it."
- PowerPilot reads local CPU identification through CPUID, local GPU display-adapter names through Windows display enumeration, and local battery status/runtime data through Windows battery providers.
- PowerPilot changes only local Windows power plans and the Windows startup entry needed for tray launch.
- The project is not a hacking tool and does not include features intended to bypass platform security controls.

### Roles and approvals

- Committer and reviewer: John Torset
- Release signing approver: John Torset

### Build and signing readiness

- The repository includes a self-hosted Windows GitHub Actions workflow for release builds.
- The build scripts support signing with a certificate installed in the Windows certificate store.
- The release process is documented in `RELEASE_CHECKLIST.md`.
- The installer creates a desktop shortcut and includes buttons for reading the bundled README, license, and third-party notices before installation.
- The repository includes a code signing policy and public privacy policy. SignPath-specific wording should be restored only if the SignPath Foundation path is approved.

## Honest caveats to mention if asked

- The project is newly public and currently has limited external reputation.
- The current release line is `v1.2`, with stamped builds published as `v1.2.YYMM.minute-of-month`.
- Current binaries may be unsigned because SignPath onboarding is not yet complete.
- The self-hosted Windows build workflow is present in the repository, but actual SignPath integration still depends on onboarding and runner setup.

## Suggested form/email answers

### Short project description

PowerPilot is a Windows x64 PureBasic tray application for managing three fixed local Windows power plans: Maximum, Balanced, and Battery. The Plans tab lets users edit those fixed plans directly, PowerPilot follows Windows power mode to choose which managed plan should be active, and the Battery Graph/PowerPilot Log tabs show local battery estimates, history, power events, and short app status rows.

### Why code signing is needed

PowerPilot is distributed as a Windows desktop executable and installer. Trusted code signing would help users verify that published binaries come from the public repository and would reduce Windows trust friction for open-source releases.

### Why SignPath should consider it

The project is fully open source, documented, and already includes a public code signing policy, privacy statement, release checklist, and source-controlled release workflow. PowerPilot distributes Windows executables directly to end users, making repository-to-binary verification especially valuable.
