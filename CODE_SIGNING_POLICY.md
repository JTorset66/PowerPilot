# Code Signing Policy

This document describes how release binaries for PowerPilot are built, reviewed, and signed.

Free code signing provided by [SignPath.io](https://about.signpath.io), certificate by [SignPath Foundation](https://signpath.org).

Current status:

- This repository is preparing for a SignPath Foundation application.
- Until that application is approved and integrated, published binaries may be unsigned or signed through a separate trusted Windows code-signing setup controlled by the project maintainer.

## Project roles

- Committer and reviewer: John Torset
- Approver for release signing: John Torset

If the project team expands, this policy will be updated before additional maintainers are allowed to approve signed releases.

## Source of truth

- Primary repository: <https://github.com/JTorset66/PowerPilot>
- Default branch: `main`

Only binaries built from this repository and maintained by this project may be signed under this policy.

## Release build policy

- Release artifacts must be built from source in this repository.
- Builds should be produced by an automated workflow on a controlled Windows runner with PureBasic and Inno Setup installed.
- Release tags should use the format `v*`.
- Build scripts, installer scripts, and workflow definitions are part of the trusted source and must be reviewed with the same care as application code.
- Every signing event must correspond to a release build, release candidate, or explicit maintainer-run verification build.

## Signing policy

- Only project-owned binaries may be signed.
- Third-party upstream executables and DLLs must not be re-signed as if they were project binaries.
- If signing is enabled for a release build, the signed artifacts must come from the automated release workflow or an equivalent controlled maintainer-run process.
- Signed artifacts should use SHA-256 signatures and RFC 3161 timestamping when the signing provider supports it.
- The installer should contain signed project-owned executables when signing is available.

## Privacy policy

This program does not transfer information to other networked systems unless specifically requested by the user or the person installing or operating it.

PowerPilot reads local CPU identification through CPUID and local GPU display-adapter names through Windows display enumeration. PowerPilot changes local Windows power plans and the Windows startup entry needed for tray launch. These actions are part of the program's visible purpose and are documented in the README.

## User safety

- The project must not include malware, potentially unwanted software, or features intended to bypass platform security controls.
- System changes must be transparent to the user.
- The installer must provide a clear uninstall mechanism.
- Custom Windows power plans created by the project must be removable by the project.
- The application must not hide network activity or collect remote telemetry.

## Repository security expectations

- Maintainer accounts used for releases should use multi-factor authentication.
- Release tags should be intentional and reviewed before publication.
- Workflow, build, installer, and signing changes should be reviewed carefully before release.
- Signing credentials must not be committed to the repository.
- Certificate thumbprints and timestamp URLs may be provided through local parameters or GitHub repository secrets.
