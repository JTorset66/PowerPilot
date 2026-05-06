# Defaults And Settings

PowerPilot loads defaults first, then overlays `%APPDATA%\PowerPilot\settings.ini`. On first install, the values below are the defaults. After that, user-selected settings are saved and reused.

## General Defaults

| Setting | Default |
| --- | --- |
| Start with Windows | On |
| Keep settings on reinstall | Off |
| Throttle background | On |
| Deep idle saver | On |
| Energy Saver mode | Follow Windows |
| Show tips | On |
| Last selected plan | `PowerPilot Balanced` |

## Battery And Log Defaults

| Setting | Default |
| --- | --- |
| Log samples | On |
| Log every | 5 min |
| Refresh | 5 sec |
| Empty at | 0% |
| Full at | 100% |
| Use charge limit | Off |
| Charge limit max | 80% |
| Smooth | 60 min |
| Startup estimate | 12%/h |
| Learned discharge estimate | 12%/h |
| Learned charge estimate | 0%/h until learned |
| Charge learning cap | 32 updates |
| Battery graph window | 24 h |
| Lenovo/drain helper target | 120 min |

## Log Column Defaults

All log columns are visible on first install.

| Column | Default width |
| --- | ---: |
| Time | 142 |
| Battery | 55 |
| Avg time | 145 |
| Now/rate | 72 |
| Win time | 64 |
| Rate | 64 |
| Plugged in | 58 |
| Batt W | 76 |
| Screen | 74 |
| Laptop % | 78 |

## Plan Defaults

PowerPilot defines three fixed plans. The values are stored per plan and may be edited by the user later.

### PowerPilot Maximum

| Field | AC | DC |
| --- | ---: | ---: |
| EPP | 0 | 60 |
| Boost mode | 2 | 1 |
| Max processor state | 100 | 100 |
| Max frequency MHz | 0 | 0 |
| Cooling | 1 | 1 |

### PowerPilot Balanced

| Field | AC | DC |
| --- | ---: | ---: |
| EPP | 33 | 50 |
| Boost mode | 1 | 0 |
| Max processor state | 100 | 100 |
| Max frequency MHz | 0 | 0 |
| Cooling | 1 | 0 |

### PowerPilot Battery

| Field | AC | DC |
| --- | ---: | ---: |
| EPP | 90 | 98 |
| Boost mode | 0 | 0 |
| Max processor state | 65 | 55 |
| Max frequency MHz | 2200 | 1600 |
| Cooling | 0 | 0 |

## Settings Persistence Rules

- `LoadSettings()` sets defaults first, then reads saved values.
- `UpgradeSettingsIfNeeded()` only changes old unchanged defaults or fills missing new fields.
- `SaveSettings()` writes app settings and all three plan definitions.
- Battery/log setting edits are debounced through `ScheduleBatterySettingsApply()` and `ApplyPendingBatterySettings()`.
- The Lenovo/drain helper target is saved as `BatteryCalibrationDrainMinutes`.
- User settings are not removed on reinstall when `Keep settings` is enabled.
