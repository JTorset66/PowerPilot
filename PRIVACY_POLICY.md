# PowerPilot Privacy Policy

Effective date: May 17, 2026

Publisher and Microsoft Store developer name: Dofta

PowerPilot is a local Windows desktop application for power-plan control and battery observation.

## Summary

PowerPilot does not create accounts, does not include advertising, does not include analytics, and does not send telemetry or personal data to Dofta or any other network service by itself.

All normal app data stays on the user's Windows device unless the user chooses to copy, export, upload, or otherwise share files outside PowerPilot.

## Data PowerPilot reads locally

PowerPilot may read local Windows information needed for its visible features, including:

- battery percentage, charge state, power source, estimated runtime, battery capacity, voltage, cycle count, and related Windows battery-driver data when exposed by the device;
- Windows power mode, Energy Saver state, power-plan settings, sleep/wake/shutdown events, and display-state events;
- built-in display brightness when Windows exposes it reliably;
- local CPU identification and display-adapter names;
- PowerPilot's own process CPU time for the Power Use estimate.

PowerPilot does not directly measure CPU package watts, GPU watts, display panel watts, fan power, temperature, Wi-Fi, storage, USB device power, or power used by other apps.

## Data PowerPilot writes locally

PowerPilot may write local data needed for operation, including:

- app settings;
- retained battery/status log rows;
- Battery Test reports;
- Windows power-plan settings for PowerPilot-owned plans;
- the Windows startup entry used to start PowerPilot in the notification area.

Typical user data locations include `%APPDATA%\PowerPilot` and the Windows power-plan store.

## Network use

PowerPilot does not transmit app logs, battery data, hardware data, settings, or reports over the network by itself.

If a user manually copies, exports, attaches, uploads, or shares a PowerPilot log, report, screenshot, or settings file through another app or website, that separate action is outside PowerPilot's automatic behavior.

## Third parties

PowerPilot does not use third-party analytics, advertising SDKs, or remote tracking services.

The project may use GitHub for public source code, issue tracking, releases, and support. GitHub's own services are governed by GitHub's terms and privacy policy.

## Retention and deletion

PowerPilot keeps its local settings, retained logs, and reports on the user's device until the user deletes them, clears the relevant files, or uninstalls/removes the app data.

Uninstalling PowerPilot removes installed program files and PowerPilot-owned Windows power plans. Local user data under `%APPDATA%\PowerPilot` may remain so users do not lose logs or settings during reinstall unless they delete it separately.

## Support contact

For support, use the public GitHub issue tracker:

<https://github.com/JTorset66/PowerPilot/issues>

## Changes

This policy may be updated when PowerPilot behavior changes. Material changes should be reflected in the repository documentation and release notes.
