# PowerPilot Function Map

This map describes the current `PowerPilot_V1.1.pb` source layout so stale code and documentation drift are easier to spot during release work.

## Startup Flow

1. Load settings with `LoadSettings`.
2. Resolve the selected plan with `PlanIndexByName`.
3. Handle command-line maintenance commands such as `/install-refresh`, `/cleanup-old-versions`, `/log-update-close-if-powerpilot-running`, `/startup-on`, and `/cleanup-settings`.
4. Start the GUI with `RunGui`, which creates the window, tray icon, timers, startup log rows, graph history, and first battery refresh.
5. The timer loop calls `MonitorAutomaticPlans`, `RefreshBattery`, and `RefreshDisplay`.

## Core Settings And Utility

- Path and text helpers: `QuoteArgument`, `SettingsDirectory`, `SettingsPath`, `EnsureSettingsDirectory`, `CleanPlanText`, `ClampInt`, `PowerShellLiteral`.
- Settings lifecycle: `LoadSettings`, `SaveSettings`, `UpgradeSettingsIfNeeded`, `CleanupSettingsData`, `ExportSettings`, `ImportSettings`; PowerPilot Log column width helpers persist user-resized columns.
- UI feedback: `LogAction` updates the Overview `Last action` text and writes a shortened `app` row to the PowerPilot Log through `ShortStatusLogText`.
- Process helpers: `ProgramWaitTimedOut`, `RunExitCode`, `RunCapture`, `PowerShellCapture`.

## Fixed Plan Model

- Plan defaults and validation: `AddPlan`, `LoadDefaultPlan`, `LoadDefaultPlans`, `ClampPlanValues`, `PlanMatchesValues`.
- Plan lookup and naming: `PlanIndexByName`, `NormalizePlanName`, `IsManagedPlanName`.
- Power-mode mapping: `IsEfficiencyPowerMode`, `PowerModeTextFromGuid`, `TargetPlanForPowerModeGuid`, `TargetPlanForWindowsPlan`.
- Windows plan commands and cache: `RunPowerCfg`, `RunPowerCfgCapture`, `FindGuidInText`, `RefreshSchemeCache`, `InvalidateSchemeCache`, `GetActiveSchemeGuid`, `GetSchemeGuidByName`, `GetSchemeNameByGuid`.
- Power API fallback: `EnsurePowerApi`, `ReadPowerGuidValue`, `GetActiveSchemeGuidByApi`, `GetWindowsPowerModeGuid`, `CurrentPowerSupplyIsBattery`.
- Plan creation and cleanup: `DuplicateBaseScheme`, `EnsurePlanInstalled`, `DeleteManagedPlanCopies`, `CreateManagedPlansFromBase`, `CreateManagedPlans`, `ManagedPlansInstalled`, `InstallRefresh`, `CleanupManagedPlans`.
- Plan application: `SetSchemeValue`, `TrySetSchemeValue`, `SetFrequencyCaps`, `ConfigureBatterySleepFloor`, `ApplyBatterySleepFloorToManagedPlans`, `ConfigureEnergySaverPolicy`, `ApplyEnergySaverPolicyToManagedPlans`, `ConfigureScheme`, `ActivatePlanByName`, `ApplyWindowsPowerFollow`, `MonitorAutomaticPlans`.

## Battery Telemetry And Estimates

- Battery formatting and parsing: `BatteryLogPath`, `IsoTimestamp`, `DisplayTimestamp`, `BatteryLogTimestampForDisplay`, `BatteryLogHeader`, `CleanBatteryEventName`, `BatteryFieldValue`, `BatteryBool`, `BatteryEffectiveMaxPercent`, `FormatBatteryMinutes`, `FormatDurationSeconds`.
- Live reads: `QueryNativeBatteryData` uses SetupAPI plus battery IOCTLs for live capacity, charging/discharging rate, voltage, runtime, full/design capacity, wear, and cycle count; `QueryBatteryStatic` and `QueryBatteryStatus` fall back to PowerShell/CIM only when native battery APIs are unavailable.
- Refresh pipeline: `RefreshBattery`, `UpdateBatteryEstimate`, `WriteBatteryLog`, `RefreshBatteryDisplay`, `RefreshPowerPilotDrawDisplay`, `RefreshPowerUseDetails`, `RefreshBatteryTest`; visible-window battery reads use the user `Read every` setting, while hidden tray mode backs off to a slower floor and skips visible-control redraw/list rebuild work. Windows power-status broadcasts force an immediate live sample and log row only when plugged-in/charging state actually changes. Normal retained sample rows include built-in laptop panel brightness percent when WMI exposes it, with a conservative `Dxva2.dll` fallback only when the display layout is unambiguous; brightness lookup is skipped while the logged screen state is off.
- Average charge/discharge logic: `BatteryAverageDrainPctPerHour`, `BatteryAverageChargePctPerHour`, `BatteryChargingTaperAdjustedRatePctPerHour`, `RememberLearnedChargingRate`, `ResetBatteryAverageSamples`, `BatteryFullLogDrainPctPerHour`, `AutoSetInitialBatteryDrainFromLog`.
- Break handling: `AddBatteryAverageBreak`, `AddBatteryAppBreak`, `BatteryEventBreaksAverage`, `BatteryIntervalHasAverageBreak`, `BatteryIntervalHasAppBreak`, `BatteryIntervalHasPowerBreak`, `BatteryGraphFlatGapSeconds`.

## PowerPilot Log And Events

- Retention: `PruneBatteryLog` keeps the CSV to the configured 168-hour retention cap.
- Graph load: `LoadBatteryGraphFromLog` rebuilds the in-memory graph from retained CSV rows at startup.
- Power event detection: `CurrentBootTime`, `LastBatteryEventName`, `RecentResumeEventName`, `CleanupAppCloseShutdownEvents`, `LogStartupPowerEvents`; `RegisterDisplayPowerNotification` listens for session display and Energy Saver state changes, with `ScreenEventFromPowerSetting` and `EnergySaverStateFromPowerSetting` mapping them to log rows.
- Log writers: `WriteBatteryLog` writes battery sample rows, `WriteBatteryEvent` writes PC power-event rows, `WriteBatteryAppEvent` writes app lifecycle/status rows, `WriteBatteryScreenEvent` writes display state rows without breaking average calculations, and `WriteBatteryTestRow` writes `BATTERY TEST` workflow rows.
- Log UI: `RefreshBatteryLogPreview` fills the PowerPilot Log tab from the full retained CSV, formats timestamps with a space for readability, and includes signed watts, screen event, and brightness columns; `CaptureBatteryLogColumnWidths` / `ApplyBatteryLogColumnWidths` keep user column sizing, `BatteryLogPreviewRowText` formats selected rows, `CopyBatteryLogRow` supports multi-row copy, and `CopyBatteryLogAll` copies the full retained CSV.

## Battery Graph And Stats

- In-memory graph: `AddBatteryGraphPoint`, `PruneBatteryGraph`, `BatteryGraphIndexBefore`, `BatteryGraphIndexAfter`.
- Event markers: `AddBatteryEventPoint`, `PruneBatteryEvents`, `BatteryEventShortName`.
- Summaries: `RefreshBatteryStatsSummary` updates session, off-time battery loss, and daily battery summary text. `RefreshPowerUseDetails` updates the Power Use tab values and provider status from the gliding 60-second PowerPilot-use sample. Plugged-in Power Use estimates use current full-charge capacity plus learned average discharging as the battery discharging basis.
- Drawing: `DrawBatteryGraph` renders the selectable gliding graph window into an offscreen image, then blits it to the canvas once to avoid flicker. It uses a fixed 0% to 100% scale, horizontal hour-only labels, a spaced legend, complete plot border, anti-aliased colored line segments, thin full-height color-change markers, endpoint-to-endpoint gap segments, and event markers. The graph window can be 6, 12, 18, 24, 36, 48, 60, or 72 hours; windows above 24 hours label every fourth hour. Energy Saver state includes Windows' flag and PowerPilot's controlled Battery plan setting.

## Battery Test

- Guided workflow: `BatteryTestMode`, `BatteryTestPhase`, and `BatteryTestGuide` surface manual discharge, Lenovo calibration reset, vendor calibration detected, charge recovery, monitor, and complete states from Windows battery telemetry.
- Test logging and reports: `StartBatteryTestLog`, `StartLenovoCalibrationReset`, `EndBatteryTestLog`, `RefreshBatteryTest`, `SaveBatteryTestReportFile`, `OpenLatestBatteryTestReport`, and `CopyBatteryTestReport` track start/end percent, mWh used/charged, average discharge/charge watts, observed runtime, capacity notes, and saved `.txt` reports under `%APPDATA%\PowerPilot\reports`.
- Drain helper: `StepBatteryCpuLoad`, `StartBatteryCpuLoad`, `StopBatteryCpuLoad`, and `BatteryCpuLoadWorker` run bounded local CPU work for watched battery drain tests. `StartAutoDrainTarget`, `ToggleAutoDrainTarget`, and `UpdateAutoDrainTarget` use target drain time, filtered watts, and PI-style load changes about every 10 seconds. `SetBatteryDrainHelperTestMode` and `WriteBatteryDrainHelperTrace` add detailed controller telemetry for normal unplug tuning runs.
- Fast visible refresh: `BatteryTestTabVisible`, `DesiredRefreshInterval`, and `DesiredBatteryRefreshSeconds` use a 1-second battery read cadence only while Battery Test is the selected visible tab. `BatteryGraphTabVisible` avoids hidden graph-canvas redraws and redraws the graph when the Battery Graph tab is selected.

## Hardware Information

- CPU primitives: `Cpuid`, `XGetBv0`, `HasBit`.
- CPU display text: `CpuVendor`, `CpuBrand`, `CpuFamilyModelText`, `CpuTopologyText`, `CpuFeatureText`, `CpuCacheText`, `BuildCpuInfo`, `CpuInfo`.
- Memory formatting: `FormatBytes`, `SystemMemoryText`, `FormatCacheSize`.
- GPU display text: `BuildCpuMatchText`, `CpuMatchAny`, `IsGenericAmdIntegratedGpuName`, `ResolveAmdGraphicsCuName`, `ResolveAmdIntegratedGpuName`, `IsGenericIntelIntegratedGpuName`, `ResolveIntelIntegratedGpuName`, `CpuInferredIntegratedGpuName`, `NormalizeGpuHardwareName`, `IsLikelyIntegratedGpuName`, `IsLikelyDiscreteGpuName`, `VendorNameFromPciId`, `PciSummary`, `IsUsefulGpuName`, `BuildGpuInfo`, `GpuInfo`.

## Process And Installer Support

- Startup registry: `SetStartupRegistry`.
- Versioned app cleanup: `IsPowerPilotVersionedExeName`, `PowerPilotVersionFromExeName`, `CompareVersionStrings`, `CleanupOldPowerPilotVersions`, `LogUpdateCloseIfSameExeRunning`, `LogUpdateCloseIfAnyPowerPilotRunning`.
- Maintenance throttling: `EnsureProcessThrottleApi`, `ForegroundProcessId`, `IsMaintenanceThrottleProcessName`, `SetProcessEcoThrottle`, `ApplyMaintenanceThrottling`, `ApplySelfDeepIdleThrottle`.
- Shutdown lifecycle: `ShutdownApp`, `MainWindowCallback`.

## UI Construction And Event Handling

- Window and tray: `CreateMainWindow`, `CreateTrayMenu`, `SetupTray`, `HideToTray`, `ShowFromTray`, `MainWindowVisible`.
- Timer handling: `DesiredRefreshInterval`, `StartRefreshTimer`, `RefreshActiveTimer`, `RunPeriodicRefresh`; the main GUI loop stays blocking so the tab window paints normally, while `#TimerRefresh` owns periodic battery/log refresh. Deep idle tray mode uses a 5-minute timer and `ApplySelfDeepIdleThrottle` marks PowerPilot as EcoQoS while hidden.
- UI helpers: `SetGadgetTextIfChanged`, `EnsureUiFonts`, `UseBoldFont`, `SetTip`, `ApplyToolTips`.
- Plan UI: `ReadPlanEditor`, `RefreshPlanEditor`, `RefreshPlanList`, `SavePlanEditor`, `ResetSelectedPlan`.
- Battery/settings UI: `ApplySettingsToGui`, `ScheduleBatterySettingsApply`, `ApplyPendingBatterySettings`, `SaveBatterySettingsFromGui`, `ResetBatteryStats`, `SaveSettingsFromGui`.
- Dispatch: `HandleAction`, `HandleMenu`, `RunGui`.

## Current Cleanup Notes

- The old visible bottom status field has been removed. Status feedback is now retained as shortened `app` rows in the PowerPilot Log.
- Unused wrapper procedures from older UI/timer flows were removed during the v1.1 cleanup pass.
- `PowerPilot_V1.0.pb` is obsolete for v1.1 and should stay out of release packages.
- The repository `pb_*test*.pb` files are local PureBasic experiments and are not included by the installer.
