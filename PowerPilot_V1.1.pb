EnableExplicit

; PowerPilot v1.1
; PureBasic-only Windows power-plan manager with local CPU/GPU identification.
;
; Source layout:
; - Constants, structures, globals, and forward declarations.
; - Settings and fixed-plan model.
; - Battery telemetry, retained PowerPilot log, graph, and estimates.
; - Windows power APIs, powercfg integration, and managed plan install/apply.
; - Hardware summary helpers for CPU/GPU display text.
; - GUI construction, event dispatch, tray behavior, and command-line entry.

#AppName$            = "PowerPilot"
#AppVersion$         = "1.1.2605.03093"
#AppFullName$        = #AppName$ + " v" + #AppVersion$
#AppRunKey$          = "PowerPilot"
#SettingsFolderName$ = "PowerPilot"
#SettingsFileName$   = "settings.ini"
#SettingsVersion = 7
#TrayTooltip$        = #AppFullName$

; PowerPilot owns exactly three Windows plans. The old "Codex" prefix is kept
; only so cleanup code can remove prototype plans from earlier builds.
#PlanPrefixNew$ = "PowerPilot "
#PlanPrefixOld$ = "Codex "
#PlanFull$      = "PowerPilot Maximum"
#PlanBalanced$  = "PowerPilot Balanced"
#PlanBattery$   = "PowerPilot Battery"

; Windows power-mode overlay GUIDs. Balanced is the all-zero overlay GUID used
; by Windows when no explicit performance/efficiency overlay is selected.
#PowerModeEfficiency$ = "961cc777-2547-4f9d-8174-7d86181b8a7a"
#PowerModeBalanced$   = "00000000-0000-0000-0000-000000000000"
#PowerModePerformance$ = "ded574b5-45a0-4f42-8737-46345c09c238"

#ERROR_SUCCESS = 0
#EDD_GET_DEVICE_INTERFACE_NAME = 1

#WindowMain = 1
#ImageTray = 1
#TrayIconMain = 1
#PopupTray = 1
#TimerRefresh = 1
#TimerBatterySettingsApply = 2
#RefreshVisibleMs = 5000
#RefreshHiddenMs = 5000
#RefreshHiddenDeepIdleMs = 30000
#BatterySettingsApplyDelayMs = 1500
#ProgramTimeoutMs = 10000
#ThrottleScanMs = 30000

; Battery graph/log sizing. The CSV retention cap is the source of truth for
; how much history the PowerPilot Log tab and startup graph reload can show.
#BatteryGraphMaxPoints = 2880
#BatteryGraphWindowSeconds = 86400
#BatteryLogRetentionSeconds = 604800
#BatteryStaticRefreshSeconds = 86400
#BatteryDefaultLogMinutes = 5
#BatteryDefaultRefreshSeconds = 30
#BatteryWmiTimeoutMs = 15000

; Window and power-broadcast messages used to distinguish real PC power events
; from installer/restart-manager app closes. CLOSEAPP is intentionally ignored
; as a PC shutdown marker elsewhere in the code.
#WM_QUERYENDSESSION = $0011
#WM_ENDSESSION = $0016
#WM_POWERBROADCAST = $0218
#WM_APP = $8000
#WM_POWERPILOT_UPDATE_CLOSE = #WM_APP + $66
#ENDSESSION_CLOSEAPP = $00000001
#PBT_APMSUSPEND = $0004
#PBT_APMRESUMECRITICAL = $0006
#PBT_APMRESUMESUSPEND = $0007
#PBT_APMPOWERSTATUSCHANGE = $000A
#PBT_APMRESUMEAUTOMATIC = $0012

; Process and EcoQoS constants. These are deliberately minimal so PowerPilot
; can throttle only safe background maintenance processes without a helper exe.
#TH32CS_SNAPPROCESS = $00000002
#PROCESS_TERMINATE = $0001
#PROCESS_SET_INFORMATION = $0200
#PROCESS_QUERY_LIMITED_INFORMATION = $1000
#ProcessPowerThrottling = 4
#PROCESS_POWER_THROTTLING_CURRENT_VERSION = 1
#PROCESS_POWER_THROTTLING_EXECUTION_SPEED = $1
#INVALID_HANDLE_VALUE = -1

Prototype.i PowerGetActiveSchemeProto(userRoot.i, *activeScheme)
Prototype.i PowerGetGuidValueProto(*guid)
Prototype.i SetProcessInformationProto(processHandle.i, informationClass.i, *processInformation, processInformationSize.i)
Prototype.i GetProcessInformationProto(processHandle.i, informationClass.i, *processInformation, processInformationSize.i)

; Tray menu ids.
Enumeration 100
  #MenuOpen
  #MenuExit
EndEnumeration

; Gadget ids are centralized because PureBasic uses integer ids for event
; dispatch. Keep this list aligned with CreateMainWindow and HandleAction.
Enumeration 200
  #GadgetPanel
  #GadgetCpuInfo
  #GadgetGpuInfo
  #GadgetActivePlan
  #GadgetPowerSource
  #GadgetLastAction
  #GadgetPlanList
  #GadgetPlanSummary
  #GadgetPlanAcEpp
  #GadgetPlanDcEpp
  #GadgetPlanAcBoost
  #GadgetPlanDcBoost
  #GadgetPlanAcState
  #GadgetPlanDcState
  #GadgetPlanAcFreq
  #GadgetPlanDcFreq
  #GadgetPlanAcCooling
  #GadgetPlanDcCooling
  #GadgetPlanSave
  #GadgetPlanReset
  #GadgetAutoStart
  #GadgetKeepSettings
  #GadgetThrottleMaintenance
  #GadgetDeepIdleSaver
  #GadgetShowToolTips
  #GadgetHideToTray
  #GadgetExit
  #GadgetBatteryPercent
  #GadgetBatteryConnection
  #GadgetBatteryCharging
  #GadgetBatteryCapacity
  #GadgetBatteryRates
  #GadgetBatteryEstimate
  #GadgetBatteryInstantEstimate
  #GadgetBatteryRuntime
  #GadgetBatteryFullEstimate
  #GadgetBatteryWear
  #GadgetBatteryMaxCapacity
  #GadgetBatteryCycle
  #GadgetBatteryGraph
  #GadgetBatteryLogEnabled
  #GadgetBatteryLogMinutes
  #GadgetBatteryRefreshSeconds
  #GadgetBatteryMinPercent
  #GadgetBatteryMaxPercent
  #GadgetBatteryLimiterEnabled
  #GadgetBatteryLimiterMaxPercent
  #GadgetBatterySmoothingMinutes
  #GadgetBatteryStartupDrain
  #GadgetBatteryStatsReset
  #GadgetBatteryLogCopyRow
  #GadgetBatteryLogCopyAll
  #GadgetBatteryLogPreview
  #GadgetBatterySessionSummary
  #GadgetBatteryDailySummary
  #GadgetBatteryOffLossSummary
  #GadgetSettingsExport
  #GadgetSettingsImport
  #GadgetLogShowAverage
  #GadgetLogShowInstant
  #GadgetLogShowConnected
  #GadgetLogShowEvents
EndEnumeration

; CPUID returns four 32-bit registers; q is used here to make bit operations
; and string extraction straightforward in PureBasic.
Structure CpuidRegs
  Eax.q
  Ebx.q
  Ecx.q
  Edx.q
EndStructure

; A fixed plan definition stores only the settings PowerPilot owns. Additional
; hidden Windows plan settings are applied in ConfigureScheme.
Structure PlanDefinition
  Name.s
  Description.s
  AcEpp.i
  AcBoostMode.i
  AcMaxState.i
  AcFreqMHz.i
  AcCooling.i
  DcEpp.i
  DcBoostMode.i
  DcMaxState.i
  DcFreqMHz.i
  DcCooling.i
EndStructure

; User settings live in %APPDATA%\PowerPilot\settings.ini. SettingsVersion is
; used by UpgradeSettingsIfNeeded to safely adjust defaults between releases.
Structure AppSettings
  AutoStartWithApp.i
  KeepSettingsOnReinstall.i
  ThrottleMaintenance.i
  DeepIdleSaver.i
  ShowToolTips.i
  BatteryLogEnabled.i
  BatteryLogIntervalMinutes.i
  BatteryRefreshSeconds.i
  BatteryMinPercent.i
  BatteryMaxPercent.i
  BatteryLimiterEnabled.i
  BatteryLimiterMaxPercent.i
  BatterySmoothingMinutes.i
  BatteryStartupDrainPctPerHour.d
  BatteryLastDrainPctPerHour.d
  BatteryLastStaticQuery.q
  BatteryLogShowAverage.i
  BatteryLogShowInstant.i
  BatteryLogShowConnected.i
  BatteryLogShowEvents.i
  BatteryLogColumn0Width.i
  BatteryLogColumn1Width.i
  BatteryLogColumn2Width.i
  BatteryLogColumn3Width.i
  BatteryLogColumn4Width.i
  BatteryLogColumn5Width.i
  BatteryLogColumn6Width.i
  LastBootTime.q
  SettingsVersion.i
  LastPlan.s
EndStructure

; Live battery state combines WMI, Win32_Battery fallback, static capacity data,
; and PowerPilot's own average/instant estimate calculations.
Structure BatteryTelemetry
  Valid.i
  Timestamp.q
  Percent.d
  Connected.i
  Charging.i
  DisconnectedBattery.i
  RemainingMWh.d
  FullMWh.d
  DesignMWh.d
  WearPercent.d
  DischargeRateMW.d
  ChargeRateMW.d
  VoltageMV.d
  CycleCount.i
  RuntimeMinutes.i
  RuntimeValid.i
  EstimateMinutes.i
  EstimateValid.i
  InstantEstimateMinutes.i
  InstantEstimateValid.i
  InstantDrainPctPerHour.d
  SmoothedDrainPctPerHour.d
EndStructure

; The graph only needs time, percent, and basic power state. Event/app break
; arrays are kept separately so they can affect averages and drawing differently.
Structure BatteryGraphPoint
  Timestamp.q
  Percent.d
  Connected.i
  Charging.i
EndStructure

; PC power events are graph markers. App lifecycle/status rows stay in the CSV
; and average-break list, but are not drawn as PC shutdown/sleep markers.
Structure BatteryEventPoint
  Timestamp.q
  Name.s
EndStructure

; Windows PROCESS_POWER_THROTTLING_STATE layout for SetProcessInformation.
Structure ProcessPowerThrottlingState
  Version.l
  ControlMask.l
  StateMask.l
EndStructure

; PROCESSENTRY32 layout for Toolhelp snapshots. PowerPilot uses this to find
; older versioned app executables without relying on external taskkill behavior.
Structure PowerPilotProcessEntry32
  dwSize.l
  cntUsage.l
  th32ProcessID.l
  *th32DefaultHeapID
  th32ModuleID.l
  cntThreads.l
  th32ParentProcessID.l
  pcPriClassBase.l
  dwFlags.l
  szExeFile.c[#MAX_PATH]
EndStructure

; Fixed plans and application state.
Global Dim gPlans.PlanDefinition(2)
Global gSettings.AppSettings
Global gSelectedPlan.i
Global gTrayReady.i
Global gStartedInTrayMode.i
Global gLastAction$
Global gCachedCpuInfo$
Global gCachedGpuInfo$
Global gCachedActiveGuid$
Global gCachedActiveName$
Global gCachedPowerModeGuid$
Global gCachedPowerModeText$
Global gSchemeCacheValid.i

; Timer state is explicit because visible and tray/deep-idle modes can use
; different refresh intervals.
Global gRefreshTimerActive.i
Global gRefreshTimerMs.i
Global gBatterySettingsApplyPending.i
Global gFontUi.i
Global gFontBold.i
Global gPowrProfLibrary.i
Global gPowerApiTried.i
Global gPowerGetActiveScheme.PowerGetActiveSchemeProto
Global gPowerGetEffectiveOverlayScheme.PowerGetGuidValueProto
Global gPowerGetUserConfiguredACPowerMode.PowerGetGuidValueProto
Global gPowerGetUserConfiguredDCPowerMode.PowerGetGuidValueProto
Global gKernelLibrary.i
Global gThrottleApiTried.i
Global gSetProcessInformation.SetProcessInformationProto
Global gGetProcessInformation.GetProcessInformationProto

; Automatic plan following and optional maintenance throttling state.
Global gMonitorInitialized.i
Global gLastObservedActiveGuid$
Global gLastObservedPowerModeGuid$
Global gMaintenanceThrottleActive.i
Global gLastMaintenanceThrottleScan.q

; Battery samples, retained-log reload state, and break/event arrays. Sleep,
; hibernate, shutdown, startup, and app lifecycle rows are represented as
; separate break arrays so estimates can exclude non-active time.
Global gBattery.BatteryTelemetry
Global gLastBatteryRefresh.q
Global gLastBatteryLogTime.q
Global gBatteryLastSampleTime.q
Global gBatteryLastSamplePercent.d
Global gBatteryOnBatterySince.q
Global gLastSuspendTime.q
Global gShutdownLogged.i
Global Dim gBatteryGraph.BatteryGraphPoint(#BatteryGraphMaxPoints - 1)
Global gBatteryGraphCount.i
Global Dim gBatteryAverageBreakTime.q(#BatteryGraphMaxPoints - 1)
Global gBatteryAverageBreakCount.i
Global Dim gBatteryAppBreakTime.q(#BatteryGraphMaxPoints - 1)
Global gBatteryAppBreakCount.i
Global Dim gBatteryEvents.BatteryEventPoint(#BatteryGraphMaxPoints - 1)
Global gBatteryEventCount.i
Global gIntroOverview.i
Global gIntroPlans.i
Global gFrameProcessor.i
Global gFrameState.i
Global gFrameGraphics.i
Global gFrameStartup.i
Global gFrameManagedPlans.i
Global gFramePlanSettings.i
Global gFrameBatteryStatus.i
Global gFrameBatteryEstimate.i
Global gFrameBatteryGraph.i
Global gFrameBatterySettings.i
Global gFrameBatteryLog.i

; Windows scheme cache maps both directions because UI refreshes often need
; names while plan application paths usually need GUIDs.
Global NewMap gSchemeGuidByName.s()
Global NewMap gSchemeNameByGuid.s()

Declare RefreshDisplay(force.i = #False)
Declare RefreshPlanList(force.i = #False)
Declare RefreshPlanEditor()
Declare ApplySettingsToGui()
Declare SaveSettingsFromGui()
Declare SaveSettings()
Declare.i CaptureBatteryLogColumnWidths(saveIfChanged.i = #False)
Declare ApplyBatteryLogColumnWidths()
Declare RefreshBattery(force.i = #False)
Declare RefreshBatteryDisplay()
Declare RefreshBatteryLogPreview()
Declare SaveBatterySettingsFromGui()
Declare ResetBatteryStats()
Declare CopyBatteryLogRow()
Declare CopyBatteryLogAll()
Declare ExportSettings()
Declare ImportSettings()
Declare WriteBatteryAppEvent(eventName$)
Declare WriteBatteryEvent(eventName$)
Declare LogStartupPowerEvents()
Declare CleanupAppCloseShutdownEvents(bootTime.q)
Declare AutoSetInitialBatteryDrainFromLog()
Declare DrawBatteryGraph()
Declare RefreshBatteryStatsSummary()
Declare PruneBatteryLog()
Declare ApplyToolTips()
Declare SetGadgetTextIfChanged(gadget.i, text$)
Declare RefreshActiveTimer()
Declare.i SetStartupRegistry(enabled.i)
Declare.i CreateManagedPlans()
Declare.i CreateManagedPlansFromBase(baseGuid$, forceRebase.i = #False)
Declare.i CleanupManagedPlans()
Declare.i ApplyBatterySleepFloorToManagedPlans()
Declare.i ActivatePlanByName(planName$)
Declare.i InstallRefresh()
Declare.i CleanupOldPowerPilotVersions(deleteFiles.i = #False, logEvent.i = #True)
Declare.i LogUpdateCloseIfSameExeRunning()
Declare.i LogUpdateCloseIfAnyPowerPilotRunning()

; Quotes command arguments for RunProgram calls. The app builds its own command
; strings for powercfg and PowerShell rather than invoking a shell pipeline.
Procedure.s QuoteArgument(value$)
  ProcedureReturn Chr(34) + value$ + Chr(34)
EndProcedure

; Settings are stored per user. This is important because the installer can be
; elevated, but the tray app should run and persist settings as the local user.
Procedure.s SettingsDirectory()
  Protected path$ = GetEnvironmentVariable("APPDATA")
  If path$ = ""
    path$ = GetCurrentDirectory()
  Else
    path$ + "\" + #SettingsFolderName$
  EndIf
  ProcedureReturn path$
EndProcedure

Procedure.s SettingsPath()
  ProcedureReturn SettingsDirectory() + "\" + #SettingsFileName$
EndProcedure

Procedure EnsureSettingsDirectory()
  If FileSize(SettingsDirectory()) <> -2
    CreateDirectory(SettingsDirectory())
  EndIf
EndProcedure

; Keep plan names/descriptions single-line so powercfg output parsing and list
; rows remain predictable.
Procedure.s CleanPlanText(text$)
  text$ = ReplaceString(text$, #CR$, " ")
  text$ = ReplaceString(text$, #LF$, " ")
  text$ = ReplaceString(text$, #TAB$, " ")
  While FindString(text$, "  ", 1)
    text$ = ReplaceString(text$, "  ", " ")
  Wend
  ProcedureReturn Trim(text$)
EndProcedure

; Small helper used throughout UI and settings load/save to keep user-editable
; numeric values within the ranges the rest of the code expects.
Procedure.i ClampInt(value.i, minValue.i, maxValue.i)
  If value < minValue : ProcedureReturn minValue : EndIf
  If value > maxValue : ProcedureReturn maxValue : EndIf
  ProcedureReturn value
EndProcedure

; Default PowerPilot Log column widths are deliberately below the full list
; width so the vertical scrollbar does not force a horizontal scrollbar.
Procedure.i BatteryLogDefaultColumnWidth(column.i)
  Select column
    Case 0 : ProcedureReturn 142
    Case 1 : ProcedureReturn 55
    Case 2 : ProcedureReturn 145
    Case 3 : ProcedureReturn 72
    Case 4 : ProcedureReturn 64
    Case 5 : ProcedureReturn 64
    Case 6 : ProcedureReturn 58
  EndSelect
  ProcedureReturn 60
EndProcedure

; Store user-resized log column widths in named fields instead of an array so
; settings.ini remains simple and PureBasic's structure layout stays explicit.
Procedure.i BatteryLogColumnWidth(column.i)
  Select column
    Case 0 : ProcedureReturn ClampInt(gSettings\BatteryLogColumn0Width, 40, 240)
    Case 1 : ProcedureReturn ClampInt(gSettings\BatteryLogColumn1Width, 35, 160)
    Case 2 : ProcedureReturn ClampInt(gSettings\BatteryLogColumn2Width, 50, 260)
    Case 3 : ProcedureReturn ClampInt(gSettings\BatteryLogColumn3Width, 45, 200)
    Case 4 : ProcedureReturn ClampInt(gSettings\BatteryLogColumn4Width, 45, 180)
    Case 5 : ProcedureReturn ClampInt(gSettings\BatteryLogColumn5Width, 45, 180)
    Case 6 : ProcedureReturn ClampInt(gSettings\BatteryLogColumn6Width, 35, 160)
  EndSelect
  ProcedureReturn BatteryLogDefaultColumnWidth(column)
EndProcedure

Procedure SetBatteryLogColumnWidthSetting(column.i, width.i)
  width = ClampInt(width, 35, 260)
  Select column
    Case 0 : gSettings\BatteryLogColumn0Width = width
    Case 1 : gSettings\BatteryLogColumn1Width = width
    Case 2 : gSettings\BatteryLogColumn2Width = width
    Case 3 : gSettings\BatteryLogColumn3Width = width
    Case 4 : gSettings\BatteryLogColumn4Width = width
    Case 5 : gSettings\BatteryLogColumn5Width = width
    Case 6 : gSettings\BatteryLogColumn6Width = width
  EndSelect
EndProcedure

; Populate one of the three fixed in-memory plan definitions.
Procedure AddPlan(index.i, name$, description$, acEpp.i, acBoost.i, acState.i, acFreq.i, acCooling.i, dcEpp.i, dcBoost.i, dcState.i, dcFreq.i, dcCooling.i)
  gPlans(index)\Name = CleanPlanText(name$)
  gPlans(index)\Description = CleanPlanText(description$)
  gPlans(index)\AcEpp = acEpp
  gPlans(index)\AcBoostMode = acBoost
  gPlans(index)\AcMaxState = acState
  gPlans(index)\AcFreqMHz = acFreq
  gPlans(index)\AcCooling = acCooling
  gPlans(index)\DcEpp = dcEpp
  gPlans(index)\DcBoostMode = dcBoost
  gPlans(index)\DcMaxState = dcState
  gPlans(index)\DcFreqMHz = dcFreq
  gPlans(index)\DcCooling = dcCooling
EndProcedure

; Defaults are conservative: Maximum favors plugged-in performance, Balanced
; mirrors Windows Balanced, and Battery prioritizes lower power.
Procedure LoadDefaultPlan(index.i)
  Select index
    Case 0
      AddPlan(0, #PlanFull$, "Maximum performance profile based on your selected Windows plan.", 0, 2, 100, 0, 1, 60, 1, 100, 0, 1)
    Case 1
      AddPlan(1, #PlanBalanced$, "Balanced daily profile based on your selected Windows plan.", 33, 1, 100, 0, 1, 50, 0, 100, 0, 0)
    Case 2
      AddPlan(2, #PlanBattery$, "Battery profile based on your selected Windows plan.", 90, 0, 65, 2200, 0, 98, 0, 55, 1600, 0)
  EndSelect
EndProcedure

Procedure LoadDefaultPlans()
  LoadDefaultPlan(0)
  LoadDefaultPlan(1)
  LoadDefaultPlan(2)
EndProcedure

; Return -1 for unknown names so callers can fall back to Balanced.
Procedure.i PlanIndexByName(planName$)
  Protected i.i
  For i = 0 To 2
    If gPlans(i)\Name = planName$
      ProcedureReturn i
    EndIf
  Next
  ProcedureReturn -1
EndProcedure

; Persisted plan selection is normalized because old or hand-edited settings can
; refer to plans that no longer exist in the fixed three-plan model.
Procedure.s NormalizePlanName(planName$)
  If PlanIndexByName(planName$) >= 0
    ProcedureReturn planName$
  EndIf
  ProcedureReturn #PlanBalanced$
EndProcedure

; PowerPilot cleans both current and prototype-owned plans, but never arbitrary
; user-created Windows plans.
Procedure.i IsManagedPlanName(planName$)
  ProcedureReturn Bool(planName$ = #AppName$ Or Left(planName$, Len(#PlanPrefixNew$)) = #PlanPrefixNew$ Or Left(planName$, Len(#PlanPrefixOld$)) = #PlanPrefixOld$)
EndProcedure

; Convert Windows overlay GUIDs into the fixed PowerPilot plan target.
Procedure.i IsEfficiencyPowerMode(guid$)
  ProcedureReturn Bool(LCase(guid$) = #PowerModeEfficiency$)
EndProcedure

; Map the active Windows overlay to user-facing text for the Overview tab.
Procedure.s PowerModeTextFromGuid(guid$)
  Select LCase(guid$)
    Case #PowerModeEfficiency$
      ProcedureReturn "Best power efficiency"
    Case #PowerModePerformance$
      ProcedureReturn "Best performance"
    Case #PowerModeBalanced$
      ProcedureReturn "Balanced"
  EndSelect
  ProcedureReturn ""
EndProcedure

; Map the active Windows overlay directly to the fixed plan PowerPilot should
; activate while following Windows power mode.
Procedure.s TargetPlanForPowerModeGuid(guid$)
  Select LCase(guid$)
    Case #PowerModeEfficiency$
      ProcedureReturn #PlanBattery$
    Case #PowerModePerformance$
      ProcedureReturn #PlanFull$
    Case #PowerModeBalanced$
      ProcedureReturn #PlanBalanced$
  EndSelect
  ProcedureReturn ""
EndProcedure

; When creating plans from a user-selected base plan, use the base plan name as
; a hint for which PowerPilot plan should become active.
Procedure.s TargetPlanForWindowsPlan(planName$)
  Protected lower$ = LCase(planName$)
  If FindString(lower$, "power saver", 1) Or FindString(lower$, "powersaver", 1) Or FindString(lower$, "efficiency", 1) Or FindString(lower$, "efficient", 1) Or FindString(lower$, "energy saver", 1) Or FindString(lower$, "battery saver", 1) Or FindString(lower$, "eco", 1)
    ProcedureReturn #PlanBattery$
  EndIf
  If FindString(lower$, "balanced", 1)
    ProcedureReturn #PlanBalanced$
  EndIf
  If FindString(lower$, "ultimate", 1) Or FindString(lower$, "maximum", 1) Or FindString(lower$, "high performance", 1) Or FindString(lower$, "performance", 1)
    ProcedureReturn #PlanFull$
  EndIf
  ProcedureReturn #PlanBalanced$
EndProcedure

; Guard rails for every power-plan value that can be imported, edited, or read
; from older settings files.
Procedure ClampPlanValues(*plan.PlanDefinition)
  *plan\AcEpp = ClampInt(*plan\AcEpp, 0, 100)
  *plan\DcEpp = ClampInt(*plan\DcEpp, 0, 100)
  *plan\AcBoostMode = ClampInt(*plan\AcBoostMode, 0, 2)
  *plan\DcBoostMode = ClampInt(*plan\DcBoostMode, 0, 2)
  *plan\AcMaxState = ClampInt(*plan\AcMaxState, 1, 100)
  *plan\DcMaxState = ClampInt(*plan\DcMaxState, 1, 100)
  *plan\AcFreqMHz = ClampInt(*plan\AcFreqMHz, 0, 6000)
  *plan\DcFreqMHz = ClampInt(*plan\DcFreqMHz, 0, 6000)
  *plan\AcCooling = ClampInt(*plan\AcCooling, 0, 1)
  *plan\DcCooling = ClampInt(*plan\DcCooling, 0, 1)
EndProcedure

; Used by migrations to detect old default profiles. If the user has changed a
; profile, migration leaves that edited plan alone.
Procedure.i PlanMatchesValues(*plan.PlanDefinition, acEpp.i, acBoost.i, acState.i, acFreq.i, acCooling.i, dcEpp.i, dcBoost.i, dcState.i, dcFreq.i, dcCooling.i)
  If *plan\AcEpp <> acEpp : ProcedureReturn #False : EndIf
  If *plan\AcBoostMode <> acBoost : ProcedureReturn #False : EndIf
  If *plan\AcMaxState <> acState : ProcedureReturn #False : EndIf
  If *plan\AcFreqMHz <> acFreq : ProcedureReturn #False : EndIf
  If *plan\AcCooling <> acCooling : ProcedureReturn #False : EndIf
  If *plan\DcEpp <> dcEpp : ProcedureReturn #False : EndIf
  If *plan\DcBoostMode <> dcBoost : ProcedureReturn #False : EndIf
  If *plan\DcMaxState <> dcState : ProcedureReturn #False : EndIf
  If *plan\DcFreqMHz <> dcFreq : ProcedureReturn #False : EndIf
  If *plan\DcCooling <> dcCooling : ProcedureReturn #False : EndIf
  ProcedureReturn #True
EndProcedure

; Settings upgrades are intentionally narrow. Only old unchanged defaults are
; refreshed, avoiding accidental overwrites of user tuning.
Procedure.i UpgradeSettingsIfNeeded(savedVersion.i)
  Protected upgraded.i
  If savedVersion < 2
    If PlanMatchesValues(@gPlans(2), 85, 0, 70, 2500, 0, 95, 0, 60, 1800, 0)
      LoadDefaultPlan(2)
      upgraded = #True
    EndIf
  EndIf
  If savedVersion < 5
    If PlanMatchesValues(@gPlans(0), 5, 2, 100, 0, 1, 60, 1, 100, 0, 1)
      LoadDefaultPlan(0)
      upgraded = #True
    EndIf
    If PlanMatchesValues(@gPlans(1), 55, 1, 85, 0, 1, 75, 1, 80, 0, 1)
      LoadDefaultPlan(1)
      upgraded = #True
    EndIf
  EndIf
  If gSettings\SettingsVersion <> #SettingsVersion
    gSettings\SettingsVersion = #SettingsVersion
    upgraded = #True
  EndIf
  ProcedureReturn upgraded
EndProcedure

; Load defaults first, then overlay settings.ini. That makes missing keys safe
; and keeps new settings backward compatible with older installed versions.
Procedure LoadSettings()
  Protected i.i
  Protected savedVersion.i = 0
  Protected upgraded.i
  LoadDefaultPlans()
  gSettings\AutoStartWithApp = #True
  gSettings\KeepSettingsOnReinstall = #False
  gSettings\ThrottleMaintenance = #True
  gSettings\DeepIdleSaver = #True
  gSettings\ShowToolTips = #True
  gSettings\BatteryLogEnabled = #True
  gSettings\BatteryLogIntervalMinutes = #BatteryDefaultLogMinutes
  gSettings\BatteryRefreshSeconds = #BatteryDefaultRefreshSeconds
  gSettings\BatteryMinPercent = 5
  gSettings\BatteryMaxPercent = 100
  gSettings\BatteryLimiterEnabled = #False
  gSettings\BatteryLimiterMaxPercent = 80
  gSettings\BatterySmoothingMinutes = 60
  gSettings\BatteryStartupDrainPctPerHour = 12.0
  gSettings\BatteryLastDrainPctPerHour = 12.0
  gSettings\BatteryLastStaticQuery = 0
  gSettings\BatteryLogShowAverage = #True
  gSettings\BatteryLogShowInstant = #True
  gSettings\BatteryLogShowConnected = #True
  gSettings\BatteryLogShowEvents = #True
  gSettings\BatteryLogColumn0Width = BatteryLogDefaultColumnWidth(0)
  gSettings\BatteryLogColumn1Width = BatteryLogDefaultColumnWidth(1)
  gSettings\BatteryLogColumn2Width = BatteryLogDefaultColumnWidth(2)
  gSettings\BatteryLogColumn3Width = BatteryLogDefaultColumnWidth(3)
  gSettings\BatteryLogColumn4Width = BatteryLogDefaultColumnWidth(4)
  gSettings\BatteryLogColumn5Width = BatteryLogDefaultColumnWidth(5)
  gSettings\BatteryLogColumn6Width = BatteryLogDefaultColumnWidth(6)
  gSettings\SettingsVersion = #SettingsVersion
  gSettings\LastPlan = #PlanBalanced$

  If OpenPreferences(SettingsPath())
    savedVersion = ReadPreferenceInteger("SettingsVersion", 0)
    gSettings\SettingsVersion = savedVersion
    gSettings\AutoStartWithApp = ReadPreferenceInteger("AutoStartWithApp", gSettings\AutoStartWithApp)
    gSettings\KeepSettingsOnReinstall = ReadPreferenceInteger("KeepSettingsOnReinstall", gSettings\KeepSettingsOnReinstall)
    gSettings\ThrottleMaintenance = ReadPreferenceInteger("ThrottleMaintenance", gSettings\ThrottleMaintenance)
    gSettings\DeepIdleSaver = ReadPreferenceInteger("DeepIdleSaver", gSettings\DeepIdleSaver)
    gSettings\ShowToolTips = ReadPreferenceInteger("ShowToolTips", gSettings\ShowToolTips)
    gSettings\BatteryLogEnabled = ReadPreferenceInteger("BatteryLogEnabled", gSettings\BatteryLogEnabled)
    gSettings\BatteryLogIntervalMinutes = ReadPreferenceInteger("BatteryLogIntervalMinutes", gSettings\BatteryLogIntervalMinutes)
    gSettings\BatteryRefreshSeconds = ReadPreferenceInteger("BatteryRefreshSeconds", gSettings\BatteryRefreshSeconds)
    gSettings\BatteryMinPercent = ReadPreferenceInteger("BatteryMinPercent", gSettings\BatteryMinPercent)
    gSettings\BatteryMaxPercent = ReadPreferenceInteger("BatteryMaxPercent", gSettings\BatteryMaxPercent)
    gSettings\BatteryLimiterEnabled = ReadPreferenceInteger("BatteryLimiterEnabled", gSettings\BatteryLimiterEnabled)
    gSettings\BatteryLimiterMaxPercent = ReadPreferenceInteger("BatteryLimiterMaxPercent", gSettings\BatteryLimiterMaxPercent)
    gSettings\BatterySmoothingMinutes = ReadPreferenceInteger("BatterySmoothingMinutes", gSettings\BatterySmoothingMinutes)
    gSettings\BatteryStartupDrainPctPerHour = ValD(ReadPreferenceString("BatteryStartupDrainPctPerHour", StrD(gSettings\BatteryStartupDrainPctPerHour, 2)))
    gSettings\BatteryLastDrainPctPerHour = ValD(ReadPreferenceString("BatteryLastDrainPctPerHour", StrD(gSettings\BatteryLastDrainPctPerHour, 2)))
    gSettings\BatteryLastStaticQuery = Val(ReadPreferenceString("BatteryLastStaticQuery", Str(gSettings\BatteryLastStaticQuery)))
    gSettings\BatteryLogShowAverage = ReadPreferenceInteger("BatteryLogShowAverage", gSettings\BatteryLogShowAverage)
    gSettings\BatteryLogShowInstant = ReadPreferenceInteger("BatteryLogShowInstant", gSettings\BatteryLogShowInstant)
    gSettings\BatteryLogShowConnected = ReadPreferenceInteger("BatteryLogShowConnected", gSettings\BatteryLogShowConnected)
    gSettings\BatteryLogShowEvents = ReadPreferenceInteger("BatteryLogShowEvents", gSettings\BatteryLogShowEvents)
    gSettings\BatteryLogColumn0Width = ReadPreferenceInteger("BatteryLogColumn0Width", gSettings\BatteryLogColumn0Width)
    gSettings\BatteryLogColumn1Width = ReadPreferenceInteger("BatteryLogColumn1Width", gSettings\BatteryLogColumn1Width)
    gSettings\BatteryLogColumn2Width = ReadPreferenceInteger("BatteryLogColumn2Width", gSettings\BatteryLogColumn2Width)
    gSettings\BatteryLogColumn3Width = ReadPreferenceInteger("BatteryLogColumn3Width", gSettings\BatteryLogColumn3Width)
    gSettings\BatteryLogColumn4Width = ReadPreferenceInteger("BatteryLogColumn4Width", gSettings\BatteryLogColumn4Width)
    gSettings\BatteryLogColumn5Width = ReadPreferenceInteger("BatteryLogColumn5Width", gSettings\BatteryLogColumn5Width)
    gSettings\BatteryLogColumn6Width = ReadPreferenceInteger("BatteryLogColumn6Width", gSettings\BatteryLogColumn6Width)
    gSettings\LastBootTime = Val(ReadPreferenceString("LastBootTime", Str(gSettings\LastBootTime)))
    gSettings\LastPlan = ReadPreferenceString("LastPlan", gSettings\LastPlan)
    ; Plan sections are stored under their visible plan names. This keeps the
    ; settings file readable and lets each plan migrate independently.
    For i = 0 To 2
      PreferenceGroup(gPlans(i)\Name)
      gPlans(i)\Description = ReadPreferenceString("Description", gPlans(i)\Description)
      gPlans(i)\AcEpp = ReadPreferenceInteger("AcEpp", gPlans(i)\AcEpp)
      gPlans(i)\AcBoostMode = ReadPreferenceInteger("AcBoostMode", gPlans(i)\AcBoostMode)
      gPlans(i)\AcMaxState = ReadPreferenceInteger("AcMaxState", gPlans(i)\AcMaxState)
      gPlans(i)\AcFreqMHz = ReadPreferenceInteger("AcFreqMHz", gPlans(i)\AcFreqMHz)
      gPlans(i)\AcCooling = ReadPreferenceInteger("AcCooling", gPlans(i)\AcCooling)
      gPlans(i)\DcEpp = ReadPreferenceInteger("DcEpp", gPlans(i)\DcEpp)
      gPlans(i)\DcBoostMode = ReadPreferenceInteger("DcBoostMode", gPlans(i)\DcBoostMode)
      gPlans(i)\DcMaxState = ReadPreferenceInteger("DcMaxState", gPlans(i)\DcMaxState)
      gPlans(i)\DcFreqMHz = ReadPreferenceInteger("DcFreqMHz", gPlans(i)\DcFreqMHz)
      gPlans(i)\DcCooling = ReadPreferenceInteger("DcCooling", gPlans(i)\DcCooling)
      PreferenceGroup("")
      ClampPlanValues(@gPlans(i))
    Next
    ClosePreferences()
  EndIf

  gSettings\LastPlan = NormalizePlanName(gSettings\LastPlan)
  gSettings\BatteryLogIntervalMinutes = ClampInt(gSettings\BatteryLogIntervalMinutes, 1, 1440)
  gSettings\BatteryRefreshSeconds = ClampInt(gSettings\BatteryRefreshSeconds, 5, 3600)
  gSettings\BatteryMinPercent = ClampInt(gSettings\BatteryMinPercent, 1, 99)
  gSettings\BatteryMaxPercent = ClampInt(gSettings\BatteryMaxPercent, gSettings\BatteryMinPercent + 1, 100)
  gSettings\BatteryLimiterMaxPercent = ClampInt(gSettings\BatteryLimiterMaxPercent, gSettings\BatteryMinPercent + 1, 100)
  gSettings\BatterySmoothingMinutes = ClampInt(gSettings\BatterySmoothingMinutes, 5, 240)
  SetBatteryLogColumnWidthSetting(0, gSettings\BatteryLogColumn0Width)
  SetBatteryLogColumnWidthSetting(1, gSettings\BatteryLogColumn1Width)
  SetBatteryLogColumnWidthSetting(2, gSettings\BatteryLogColumn2Width)
  SetBatteryLogColumnWidthSetting(3, gSettings\BatteryLogColumn3Width)
  SetBatteryLogColumnWidthSetting(4, gSettings\BatteryLogColumn4Width)
  SetBatteryLogColumnWidthSetting(5, gSettings\BatteryLogColumn5Width)
  SetBatteryLogColumnWidthSetting(6, gSettings\BatteryLogColumn6Width)
  If gSettings\BatteryStartupDrainPctPerHour <= 0.0
    gSettings\BatteryStartupDrainPctPerHour = 12.0
  EndIf
  If gSettings\BatteryLastDrainPctPerHour <= 0.0
    gSettings\BatteryLastDrainPctPerHour = gSettings\BatteryStartupDrainPctPerHour
  EndIf
  ; Clamp and migrate after reading all values so old or hand-edited settings
  ; cannot leak invalid values into UI controls or powercfg calls.
  upgraded = UpgradeSettingsIfNeeded(savedVersion)
  If upgraded
    SaveSettings()
  EndIf
EndProcedure

; Save only PowerPilot-owned settings. Windows power-plan GUIDs are intentionally
; not persisted because plans can be deleted and recreated by Windows or setup.
Procedure SaveSettings()
  Protected i.i
  CaptureBatteryLogColumnWidths(#False)
  EnsureSettingsDirectory()
  If CreatePreferences(SettingsPath())
    WritePreferenceInteger("AutoStartWithApp", Bool(gSettings\AutoStartWithApp))
    WritePreferenceInteger("KeepSettingsOnReinstall", Bool(gSettings\KeepSettingsOnReinstall))
    WritePreferenceInteger("ThrottleMaintenance", Bool(gSettings\ThrottleMaintenance))
    WritePreferenceInteger("DeepIdleSaver", Bool(gSettings\DeepIdleSaver))
    WritePreferenceInteger("ShowToolTips", Bool(gSettings\ShowToolTips))
    WritePreferenceInteger("BatteryLogEnabled", Bool(gSettings\BatteryLogEnabled))
    WritePreferenceInteger("BatteryLogIntervalMinutes", ClampInt(gSettings\BatteryLogIntervalMinutes, 1, 1440))
    WritePreferenceInteger("BatteryRefreshSeconds", ClampInt(gSettings\BatteryRefreshSeconds, 5, 3600))
    WritePreferenceInteger("BatteryMinPercent", ClampInt(gSettings\BatteryMinPercent, 1, 99))
    WritePreferenceInteger("BatteryMaxPercent", ClampInt(gSettings\BatteryMaxPercent, gSettings\BatteryMinPercent + 1, 100))
    WritePreferenceInteger("BatteryLimiterEnabled", Bool(gSettings\BatteryLimiterEnabled))
    WritePreferenceInteger("BatteryLimiterMaxPercent", ClampInt(gSettings\BatteryLimiterMaxPercent, gSettings\BatteryMinPercent + 1, 100))
    WritePreferenceInteger("BatterySmoothingMinutes", ClampInt(gSettings\BatterySmoothingMinutes, 5, 240))
    WritePreferenceString("BatteryStartupDrainPctPerHour", StrD(gSettings\BatteryStartupDrainPctPerHour, 2))
    WritePreferenceString("BatteryLastDrainPctPerHour", StrD(gSettings\BatteryLastDrainPctPerHour, 2))
    WritePreferenceString("BatteryLastStaticQuery", Str(gSettings\BatteryLastStaticQuery))
    WritePreferenceInteger("BatteryLogShowAverage", Bool(gSettings\BatteryLogShowAverage))
    WritePreferenceInteger("BatteryLogShowInstant", Bool(gSettings\BatteryLogShowInstant))
    WritePreferenceInteger("BatteryLogShowConnected", Bool(gSettings\BatteryLogShowConnected))
    WritePreferenceInteger("BatteryLogShowEvents", Bool(gSettings\BatteryLogShowEvents))
    WritePreferenceInteger("BatteryLogColumn0Width", BatteryLogColumnWidth(0))
    WritePreferenceInteger("BatteryLogColumn1Width", BatteryLogColumnWidth(1))
    WritePreferenceInteger("BatteryLogColumn2Width", BatteryLogColumnWidth(2))
    WritePreferenceInteger("BatteryLogColumn3Width", BatteryLogColumnWidth(3))
    WritePreferenceInteger("BatteryLogColumn4Width", BatteryLogColumnWidth(4))
    WritePreferenceInteger("BatteryLogColumn5Width", BatteryLogColumnWidth(5))
    WritePreferenceInteger("BatteryLogColumn6Width", BatteryLogColumnWidth(6))
    WritePreferenceString("LastBootTime", Str(gSettings\LastBootTime))
    WritePreferenceInteger("SettingsVersion", #SettingsVersion)
    WritePreferenceString("LastPlan", NormalizePlanName(gSettings\LastPlan))
    ; Persist all three plan definitions, including user-edited description text
    ; and AC/DC processor behavior values.
    For i = 0 To 2
      ClampPlanValues(@gPlans(i))
      PreferenceGroup(gPlans(i)\Name)
      WritePreferenceString("Description", gPlans(i)\Description)
      WritePreferenceInteger("AcEpp", gPlans(i)\AcEpp)
      WritePreferenceInteger("AcBoostMode", gPlans(i)\AcBoostMode)
      WritePreferenceInteger("AcMaxState", gPlans(i)\AcMaxState)
      WritePreferenceInteger("AcFreqMHz", gPlans(i)\AcFreqMHz)
      WritePreferenceInteger("AcCooling", gPlans(i)\AcCooling)
      WritePreferenceInteger("DcEpp", gPlans(i)\DcEpp)
      WritePreferenceInteger("DcBoostMode", gPlans(i)\DcBoostMode)
      WritePreferenceInteger("DcMaxState", gPlans(i)\DcMaxState)
      WritePreferenceInteger("DcFreqMHz", gPlans(i)\DcFreqMHz)
      WritePreferenceInteger("DcCooling", gPlans(i)\DcCooling)
      PreferenceGroup("")
    Next
    ClosePreferences()
  EndIf
EndProcedure

; The visible bottom status field was removed. Shortened action text now becomes
; an app row in the PowerPilot Log, while the full text remains on Overview.
Procedure.s ShortStatusLogText(text$)
  Protected short$ = Trim(text$)
  short$ = ReplaceString(short$, "PowerPilot ", "")
  short$ = ReplaceString(short$, "Managed ", "")
  short$ = ReplaceString(short$, " and applied to Windows", "")
  short$ = ReplaceString(short$, " from the selected Windows plan", "")
  short$ = ReplaceString(short$, "PowerPilot log", "log", #PB_String_NoCase)
  short$ = ReplaceString(short$, "Battery log", "Log")
  short$ = ReplaceString(short$, "Settings ", "Settings ")
  short$ = ReplaceString(short$, "No PowerPilot log row to copy.", "No row to copy.")
  short$ = ReplaceString(short$, "PowerPilot log row copied.", "Row copied.")
  short$ = ReplaceString(short$, "PowerPilot CSV log copied.", "CSV copied.")
  short$ = ReplaceString(short$, "Settings export failed.", "Export failed.")
  short$ = ReplaceString(short$, "Settings import failed.", "Import failed.")
  short$ = ReplaceString(short$, "Settings exported.", "Settings exported.")
  short$ = ReplaceString(short$, "Settings imported.", "Settings imported.")
  short$ = ReplaceString(short$, "Battery stats reset.", "Stats reset.")
  short$ = ReplaceString(short$, "Tray icon unavailable. Window stays visible.", "Tray unavailable.")
  If Len(short$) > 42
    short$ = Left(short$, 39) + "..."
  EndIf
  ProcedureReturn short$
EndProcedure

; Central UI/app feedback path. This updates the Overview tab and records a
; compact app-status row in the retained CSV log when the GUI is available.
Procedure LogAction(text$)
  Protected logText$ = ShortStatusLogText(text$)
  gLastAction$ = FormatDate("%hh:%ii:%ss", Date()) + "  " + text$
  If IsGadget(#GadgetLastAction)
    SetGadgetText(#GadgetLastAction, gLastAction$)
  EndIf
  If logText$ <> ""
    WriteBatteryAppEvent(logText$)
  EndIf
EndProcedure

Procedure.i ProgramWaitTimedOut(startTick.q, timeoutMs.i)
  If timeoutMs <= 0
    ProcedureReturn #False
  EndIf
  ProcedureReturn Bool(ElapsedMilliseconds() - startTick >= timeoutMs)
EndProcedure

; Run a child process and return its exit code while draining stdout. Draining
; prevents hidden powercfg/PowerShell calls from blocking on a full output pipe.
Procedure.i RunExitCode(program$, arguments$, workingDir$ = "", timeoutMs.i = #ProgramTimeoutMs)
  Protected handle.i
  Protected code.i = -1
  Protected startTick.q
  Protected timedOut.i

  handle = RunProgram(program$, arguments$, workingDir$, #PB_Program_Open | #PB_Program_Read | #PB_Program_Hide)
  If handle
    startTick = ElapsedMilliseconds()
    While ProgramRunning(handle)
      While AvailableProgramOutput(handle)
        ReadProgramString(handle)
      Wend
      If ProgramWaitTimedOut(startTick, timeoutMs)
        timedOut = #True
        KillProgram(handle)
        Break
      EndIf
      Delay(10)
    Wend
    While AvailableProgramOutput(handle)
      ReadProgramString(handle)
    Wend
    If timedOut
      code = -2
    Else
      code = ProgramExitCode(handle)
    EndIf
    CloseProgram(handle)
  EndIf
  ProcedureReturn code
EndProcedure

; Capture stdout from small helper commands. This is used for powercfg, WMI
; PowerShell calls, and system event queries where a structured Windows API is
; either unavailable from PureBasic or too verbose for this utility.
Procedure.s RunCapture(program$, arguments$, workingDir$ = "", timeoutMs.i = #ProgramTimeoutMs)
  Protected handle.i
  Protected output$
  Protected startTick.q

  handle = RunProgram(program$, arguments$, workingDir$, #PB_Program_Open | #PB_Program_Read | #PB_Program_Hide)
  If handle
    startTick = ElapsedMilliseconds()
    While ProgramRunning(handle)
      While AvailableProgramOutput(handle)
        output$ + ReadProgramString(handle) + #LF$
      Wend
      If ProgramWaitTimedOut(startTick, timeoutMs)
        KillProgram(handle)
        Break
      EndIf
      Delay(10)
    Wend
    While AvailableProgramOutput(handle)
      output$ + ReadProgramString(handle) + #LF$
    Wend
    CloseProgram(handle)
  EndIf
  ProcedureReturn output$
EndProcedure

; WMI and event-log reads are run through PowerShell because root\wmi battery
; provider classes are easier to query and parse from PowerShell than COM/WBEM
; bindings inside a compact PureBasic tray app.
Procedure.s PowerShellCapture(command$, timeoutMs.i = #BatteryWmiTimeoutMs)
  ProcedureReturn RunCapture("powershell.exe", "-NoProfile -ExecutionPolicy Bypass -Command " + QuoteArgument(command$), "", timeoutMs)
EndProcedure

; The retained CSV combines battery sample rows, PC power-event rows, and app
; status/lifecycle rows. It is deliberately under APPDATA for non-elevated use.
Procedure.s BatteryLogPath()
  ProcedureReturn SettingsDirectory() + "\battery-log.csv"
EndProcedure

; ISO-like timestamps sort lexically and are easy to parse from PowerShell,
; PureBasic, and spreadsheet tools.
Procedure.s IsoTimestamp(timestamp.q)
  ProcedureReturn FormatDate("%yyyy-%mm-%ddT%hh:%ii:%ss", timestamp)
EndProcedure

; Keep the header stable. Older rows can have missing or legacy fields, so all
; CSV readers in this file check field counts before reading newer columns.
Procedure.s BatteryLogHeader()
  ProcedureReturn "timestamp,battery_percent,connected,charging,disconnected_battery,remaining_mwh,full_mwh,design_mwh,wear_percent,discharge_rate_mw,charge_rate_mw,runtime_minutes,average_estimate_minutes,instant_estimate_minutes,instant_drain_pct_hour,smoothed_drain_pct_hour,cycle_count,row_type,event_name"
EndProcedure

; Event names live in a CSV cell, so remove separators/control characters but
; preserve enough text for user-visible PowerPilot Log messages.
Procedure.s CleanBatteryEventName(eventName$)
  eventName$ = ReplaceString(eventName$, ",", " ")
  eventName$ = ReplaceString(eventName$, #CR$, " ")
  eventName$ = ReplaceString(eventName$, #LF$, " ")
  eventName$ = ReplaceString(eventName$, #TAB$, " ")
  While FindString(eventName$, "  ", 1)
    eventName$ = ReplaceString(eventName$, "  ", " ")
  Wend
  ProcedureReturn Trim(eventName$)
EndProcedure

; Escape a PowerShell single-quoted literal. This avoids interpreting user or
; filesystem text as script when passing paths to helper commands.
Procedure.s PowerShellLiteral(value$)
  ProcedureReturn "'" + ReplaceString(value$, "'", "''") + "'"
EndProcedure

; Parse key=value pairs from the compact pipe-separated PowerShell output used
; by battery WMI queries.
Procedure.s BatteryFieldValue(line$, key$)
  Protected token$ = key$ + "="
  Protected pos.i = FindString(line$, token$, 1)
  Protected endPos.i
  If pos = 0
    ProcedureReturn ""
  EndIf
  pos + Len(token$)
  endPos = FindString(line$, "|", pos)
  If endPos = 0
    endPos = Len(line$) + 1
  EndIf
  ProcedureReturn Mid(line$, pos, endPos - pos)
EndProcedure

; PowerShell Boolean string normalization.
Procedure.i BatteryBool(value$)
  value$ = LCase(Trim(value$))
  ProcedureReturn Bool(value$ = "true" Or value$ = "1" Or value$ = "yes")
EndProcedure

; The graph/estimate "full" point can be a user maximum or a limiter-reported
; charge maximum. The minimum percent is handled separately as the empty floor.
Procedure.d BatteryEffectiveMaxPercent()
  Protected maxPercent.i = gSettings\BatteryMaxPercent
  If gSettings\BatteryLimiterEnabled
    maxPercent = gSettings\BatteryLimiterMaxPercent
  EndIf
  If maxPercent <= gSettings\BatteryMinPercent
    maxPercent = gSettings\BatteryMinPercent + 1
  EndIf
  ProcedureReturn maxPercent
EndProcedure

; Format minute estimates consistently across live display and PowerPilot Log.
Procedure.s FormatBatteryMinutes(minutes.i)
  Protected hours.i
  Protected mins.i
  If minutes < 0
    ProcedureReturn "Unknown"
  EndIf
  hours = minutes / 60
  mins = minutes % 60
  ProcedureReturn Str(hours) + "h " + RSet(Str(mins), 2, "0") + "m"
EndProcedure

; Compact elapsed-duration display for session, off-time, and daily summaries.
Procedure.s FormatDurationSeconds(seconds.q)
  Protected hours.q
  Protected mins.q
  If seconds < 0
    seconds = 0
  EndIf
  hours = seconds / 3600
  mins = (seconds % 3600) / 60
  If hours >= 24
    ProcedureReturn Str(hours / 24) + "d " + Str(hours % 24) + "h"
  EndIf
  If hours > 0
    ProcedureReturn Str(hours) + "h " + RSet(Str(mins), 2, "0") + "m"
  EndIf
  ProcedureReturn Str(mins) + "m"
EndProcedure

; In-memory graph points are capped by both count and a 24-hour window. The CSV
; remains the durable source and is reloaded at startup.
Procedure PruneBatteryGraph(now.q)
  Protected cutoff.q = now - #BatteryGraphWindowSeconds
  Protected removeCount.i
  Protected i.i
  While removeCount < gBatteryGraphCount - 1 And gBatteryGraph(removeCount)\Timestamp < cutoff
    removeCount + 1
  Wend
  If removeCount > 0
    For i = removeCount To gBatteryGraphCount - 1
      gBatteryGraph(i - removeCount) = gBatteryGraph(i)
    Next
    gBatteryGraphCount - removeCount
  EndIf
EndProcedure

; Add one visible graph point. Duplicate timestamps are ignored because WMI
; refresh and forced logging can happen in the same second during startup.
Procedure AddBatteryGraphPoint(timestamp.q, percent.d, connected.i, charging.i)
  Protected i.i
  If percent < 0.0
    ProcedureReturn
  EndIf
  If gBatteryGraphCount > 0 And gBatteryGraph(gBatteryGraphCount - 1)\Timestamp = timestamp
    ProcedureReturn
  EndIf
  If gBatteryGraphCount < #BatteryGraphMaxPoints
    gBatteryGraph(gBatteryGraphCount)\Timestamp = timestamp
    gBatteryGraph(gBatteryGraphCount)\Percent = percent
    gBatteryGraph(gBatteryGraphCount)\Connected = connected
    gBatteryGraph(gBatteryGraphCount)\Charging = charging
    gBatteryGraphCount + 1
  Else
    For i = 1 To #BatteryGraphMaxPoints - 1
      gBatteryGraph(i - 1) = gBatteryGraph(i)
    Next
    gBatteryGraph(#BatteryGraphMaxPoints - 1)\Timestamp = timestamp
    gBatteryGraph(#BatteryGraphMaxPoints - 1)\Percent = percent
    gBatteryGraph(#BatteryGraphMaxPoints - 1)\Connected = connected
    gBatteryGraph(#BatteryGraphMaxPoints - 1)\Charging = charging
  EndIf
  PruneBatteryGraph(timestamp)
EndProcedure

; Average-breaks mark intervals that must not count as active battery drain:
; PC power events, app restarts, reinstall closes, or manual reset boundaries.
Procedure PruneBatteryAverageBreaks(now.q)
  Protected cutoff.q = now - #BatteryGraphWindowSeconds
  Protected removeCount.i
  Protected i.i
  While removeCount < gBatteryAverageBreakCount And gBatteryAverageBreakTime(removeCount) < cutoff
    removeCount + 1
  Wend
  If removeCount > 0
    For i = removeCount To gBatteryAverageBreakCount - 1
      gBatteryAverageBreakTime(i - removeCount) = gBatteryAverageBreakTime(i)
    Next
    gBatteryAverageBreakCount - removeCount
  EndIf
EndProcedure

; App breaks are tracked separately from power breaks. They reset averages but
; do not create PC-off loss summaries or graph event markers.
Procedure PruneBatteryAppBreaks(now.q)
  Protected cutoff.q = now - #BatteryGraphWindowSeconds
  Protected removeCount.i
  Protected i.i
  While removeCount < gBatteryAppBreakCount And gBatteryAppBreakTime(removeCount) < cutoff
    removeCount + 1
  Wend
  If removeCount > 0
    For i = removeCount To gBatteryAppBreakCount - 1
      gBatteryAppBreakTime(i - removeCount) = gBatteryAppBreakTime(i)
    Next
    gBatteryAppBreakCount - removeCount
  EndIf
EndProcedure

; Mark a timestamp where active-drain averaging should restart.
Procedure AddBatteryAverageBreak(timestamp.q)
  Protected i.i
  If timestamp <= 0
    ProcedureReturn
  EndIf
  If gBatteryAverageBreakCount > 0 And gBatteryAverageBreakTime(gBatteryAverageBreakCount - 1) = timestamp
    ProcedureReturn
  EndIf
  If gBatteryAverageBreakCount < #BatteryGraphMaxPoints
    gBatteryAverageBreakTime(gBatteryAverageBreakCount) = timestamp
    gBatteryAverageBreakCount + 1
  Else
    For i = 1 To #BatteryGraphMaxPoints - 1
      gBatteryAverageBreakTime(i - 1) = gBatteryAverageBreakTime(i)
    Next
    gBatteryAverageBreakTime(#BatteryGraphMaxPoints - 1) = timestamp
  EndIf
  PruneBatteryAverageBreaks(timestamp)
EndProcedure

; Mark an app lifecycle/status boundary. These rows stay visible in the log.
Procedure AddBatteryAppBreak(timestamp.q)
  Protected i.i
  If timestamp <= 0
    ProcedureReturn
  EndIf
  If gBatteryAppBreakCount > 0 And gBatteryAppBreakTime(gBatteryAppBreakCount - 1) = timestamp
    ProcedureReturn
  EndIf
  If gBatteryAppBreakCount < #BatteryGraphMaxPoints
    gBatteryAppBreakTime(gBatteryAppBreakCount) = timestamp
    gBatteryAppBreakCount + 1
  Else
    For i = 1 To #BatteryGraphMaxPoints - 1
      gBatteryAppBreakTime(i - 1) = gBatteryAppBreakTime(i)
    Next
    gBatteryAppBreakTime(#BatteryGraphMaxPoints - 1) = timestamp
  EndIf
  PruneBatteryAppBreaks(timestamp)
EndProcedure

; Power event markers are kept for graph labels and session summaries.
Procedure PruneBatteryEvents(now.q)
  Protected cutoff.q = now - #BatteryGraphWindowSeconds
  Protected removeCount.i
  Protected i.i
  While removeCount < gBatteryEventCount And gBatteryEvents(removeCount)\Timestamp < cutoff
    removeCount + 1
  Wend
  If removeCount > 0
    For i = removeCount To gBatteryEventCount - 1
      gBatteryEvents(i - removeCount) = gBatteryEvents(i)
    Next
    gBatteryEventCount - removeCount
  EndIf
EndProcedure

; Add a PC power-event marker to the in-memory graph/event list.
Procedure AddBatteryEventPoint(timestamp.q, eventName$)
  Protected i.i
  eventName$ = CleanBatteryEventName(eventName$)
  If timestamp <= 0 Or eventName$ = ""
    ProcedureReturn
  EndIf
  If gBatteryEventCount > 0 And gBatteryEvents(gBatteryEventCount - 1)\Timestamp = timestamp And gBatteryEvents(gBatteryEventCount - 1)\Name = eventName$
    ProcedureReturn
  EndIf
  If gBatteryEventCount < #BatteryGraphMaxPoints
    gBatteryEvents(gBatteryEventCount)\Timestamp = timestamp
    gBatteryEvents(gBatteryEventCount)\Name = eventName$
    gBatteryEventCount + 1
  Else
    For i = 1 To #BatteryGraphMaxPoints - 1
      gBatteryEvents(i - 1) = gBatteryEvents(i)
    Next
    gBatteryEvents(#BatteryGraphMaxPoints - 1)\Timestamp = timestamp
    gBatteryEvents(#BatteryGraphMaxPoints - 1)\Name = eventName$
  EndIf
  PruneBatteryEvents(timestamp)
EndProcedure

; These event rows represent time when the machine was not actively running, so
; active drain calculations must not bridge across them.
Procedure.i BatteryEventBreaksAverage(eventName$)
  Protected lower$ = LCase(eventName$)
  ProcedureReturn Bool(FindString(lower$, "sleep", 1) Or FindString(lower$, "hibernate", 1) Or FindString(lower$, "wake", 1) Or FindString(lower$, "shutdown", 1) Or FindString(lower$, "startup", 1) Or FindString(lower$, "improper", 1))
EndProcedure

; Test whether a time interval crosses a break. All interval helpers use sorted
; timestamp arrays and are intentionally inclusive to avoid edge leakage.
Procedure.i BatteryIntervalHasAverageBreak(startTime.q, endTime.q)
  Protected i.i
  If endTime < startTime
    ProcedureReturn #True
  EndIf
  For i = gBatteryAverageBreakCount - 1 To 0 Step -1
    If gBatteryAverageBreakTime(i) <= startTime
      ProcedureReturn #False
    EndIf
    If gBatteryAverageBreakTime(i) <= endTime
      ProcedureReturn #True
    EndIf
  Next
  ProcedureReturn #False
EndProcedure

; App breaks reset rolling average samples without counting as sleep/shutdown.
Procedure.i BatteryIntervalHasAppBreak(startTime.q, endTime.q)
  Protected i.i
  If endTime < startTime
    ProcedureReturn #True
  EndIf
  For i = gBatteryAppBreakCount - 1 To 0 Step -1
    If gBatteryAppBreakTime(i) <= startTime
      ProcedureReturn #False
    EndIf
    If gBatteryAppBreakTime(i) <= endTime
      ProcedureReturn #True
    EndIf
  Next
  ProcedureReturn #False
EndProcedure

; Power breaks are the subset used by graph off-time markers and off-loss stats.
Procedure.i BatteryIntervalHasPowerBreak(startTime.q, endTime.q)
  Protected i.i
  If endTime < startTime
    ProcedureReturn #True
  EndIf
  For i = gBatteryEventCount - 1 To 0 Step -1
    If gBatteryEvents(i)\Timestamp <= startTime
      ProcedureReturn #False
    EndIf
    If gBatteryEvents(i)\Timestamp <= endTime And BatteryEventBreaksAverage(gBatteryEvents(i)\Name)
      ProcedureReturn #True
    EndIf
  Next
  ProcedureReturn #False
EndProcedure

; Missing samples beyond this threshold are treated as offline-looking gaps
; unless an app break explains the gap.
Procedure.i BatteryGraphFlatGapSeconds()
  Protected gap.i = (ClampInt(gSettings\BatteryLogIntervalMinutes, 1, 1440) * 120) + 60
  Protected refreshGap.i = ClampInt(gSettings\BatteryRefreshSeconds, 5, 3600) * 4
  If refreshGap > gap
    gap = refreshGap
  EndIf
  If gap < 600
    gap = 600
  EndIf
  ProcedureReturn gap
EndProcedure

; Reset the simple last-sample pair used by instant measured-percent drain.
Procedure ResetBatteryAverageSamples()
  gBatteryLastSampleTime = 0
  gBatteryLastSamplePercent = 0.0
  gBatteryOnBatterySince = 0
EndProcedure

; Versioned exe names let installers use side-by-side updates while the newly
; started app closes/removes older stamped builds in the background.
Procedure.i IsPowerPilotVersionedExeName(exeName$)
  exeName$ = LCase(exeName$)
  ProcedureReturn Bool(Left(exeName$, 12) = "powerpilot_v" And Right(exeName$, 4) = ".exe" And FindString(exeName$, "_setup", 1) = 0)
EndProcedure

; Extract only the stamped version part from PowerPilot_Vx.y...exe.
Procedure.s PowerPilotVersionFromExeName(exeName$)
  If IsPowerPilotVersionedExeName(exeName$) = #False
    ProcedureReturn ""
  EndIf
  ProcedureReturn Left(Mid(exeName$, 13), Len(exeName$) - 16)
EndProcedure

; Numeric dotted-version compare for stamped app filenames. Missing segments are
; treated as zero, which is enough for 1.1.YYMM.minute-of-month.
Procedure.i CompareVersionStrings(leftVersion$, rightVersion$)
  Protected i.i
  Protected leftPart.i
  Protected rightPart.i
  For i = 1 To 4
    leftPart = Val(StringField(leftVersion$, i, "."))
    rightPart = Val(StringField(rightVersion$, i, "."))
    If leftPart < rightPart
      ProcedureReturn -1
    ElseIf leftPart > rightPart
      ProcedureReturn 1
    EndIf
  Next
  ProcedureReturn 0
EndProcedure

; Same-version reinstalls must overwrite the running exe, so setup still has to
; stop that exact process before copying files. This helper is called by setup
; first, as the original user, to leave a truthful lifecycle row in the log.
Procedure.i LogUpdateCloseIfSameExeRunning()
  Protected ownPid.i = GetCurrentProcessId_()
  Protected ownName$ = LCase(GetFilePart(ProgramFilename()))
  Protected command$
  Protected output$
  Protected snapshot.i
  Protected entry.PowerPilotProcessEntry32
  Protected foundRunningCopy.i
  command$ = "$ownPid=" + Str(ownPid) + "; $ownName=" + PowerShellLiteral(ownName$) + "; @((Get-Process PowerPilot_V* -ErrorAction SilentlyContinue) | Where-Object { $_.Id -ne $ownPid -and (($_.ProcessName + '.exe').ToLowerInvariant()) -eq $ownName }).Count"
  output$ = Trim(PowerShellCapture(command$, 5000))
  If Val(output$) > 0
    WriteBatteryAppEvent("PowerPilot update close")
    ProcedureReturn #True
  EndIf

  snapshot = CreateToolhelp32Snapshot_(#TH32CS_SNAPPROCESS, 0)
  If snapshot <> #INVALID_HANDLE_VALUE
    entry\dwSize = SizeOf(PowerPilotProcessEntry32)
    If Process32First_(snapshot, @entry)
      Repeat
        If entry\th32ProcessID <> ownPid And LCase(PeekS(@entry\szExeFile[0])) = ownName$
          foundRunningCopy = #True
          Break
        EndIf
      Until Process32Next_(snapshot, @entry) = #False
    EndIf
    CloseHandle_(snapshot)
  EndIf
  If foundRunningCopy
    WriteBatteryAppEvent("PowerPilot update close")
  EndIf
  ProcedureReturn foundRunningCopy
EndProcedure

; Normal version upgrades install the new exe side-by-side, then close the old
; tray app. Setup calls this helper before cleanup starts so the log gets the
; update-close row even if Windows later requires a force-stop to unlock files.
Procedure.i LogUpdateCloseIfAnyPowerPilotRunning()
  Protected ownPid.i = GetCurrentProcessId_()
  Protected command$
  Protected output$
  Protected snapshot.i
  Protected entry.PowerPilotProcessEntry32
  Protected exeName$
  Protected foundRunningCopy.i
  command$ = "$ownPid=" + Str(ownPid) + "; @((Get-Process PowerPilot_V* -ErrorAction SilentlyContinue) | Where-Object { $_.Id -ne $ownPid -and $_.ProcessName -notmatch '_Setup$' }).Count"
  output$ = Trim(PowerShellCapture(command$, 5000))
  If Val(output$) > 0
    WriteBatteryAppEvent("PowerPilot update close")
    ProcedureReturn #True
  EndIf

  snapshot = CreateToolhelp32Snapshot_(#TH32CS_SNAPPROCESS, 0)
  If snapshot <> #INVALID_HANDLE_VALUE
    entry\dwSize = SizeOf(PowerPilotProcessEntry32)
    If Process32First_(snapshot, @entry)
      Repeat
        exeName$ = LCase(PeekS(@entry\szExeFile[0]))
        If entry\th32ProcessID <> ownPid And PowerPilotVersionFromExeName(exeName$) <> ""
          foundRunningCopy = #True
          Break
        EndIf
      Until Process32Next_(snapshot, @entry) = #False
    EndIf
    CloseHandle_(snapshot)
  EndIf
  If foundRunningCopy
    WriteBatteryAppEvent("PowerPilot update close")
  EndIf
  ProcedureReturn foundRunningCopy
EndProcedure

; Close older running PowerPilot versions and optionally delete old app files.
; The current process and exact current exe name are excluded so an install
; refresh can launch the new app before cleanup completes.
Procedure.i CleanupOldPowerPilotVersions(deleteFiles.i = #False, logEvent.i = #True)
  Protected ownPid.i = GetCurrentProcessId_()
  Protected ownName$ = LCase(GetFilePart(ProgramFilename()))
  Protected ownVersion$ = #AppVersion$
  Protected dq$ = Chr(34)
  Protected command$
  Protected output$
  Protected line$
  Protected i.i
  Protected snapshot.i
  Protected entry.PowerPilotProcessEntry32
  Protected exeName$
  Protected exeVersion$
  Protected processHandle.i
  Protected closed.i
  Protected forced.i
  Protected removed.i
  Protected directory.i
  Protected fileName$
  Protected fullPath$

  ; Prefer PowerShell for process cleanup because it handles version parsing and
  ; elevated Program Files deletion better than manual Toolhelp loops. Before
  ; force-stopping anything, send PowerPilot's private update-close message to
  ; older builds. Fixed builds can then write "PowerPilot update close" to the
  ; log, while older builds still get cleaned up by the fallback stop.
  command$ = "$ErrorActionPreference='SilentlyContinue'; $own=" + PowerShellLiteral(ownName$) + "; $ownVersion=[version]" + PowerShellLiteral(ownVersion$) + "; $app=" + PowerShellLiteral(GetPathPart(ProgramFilename())) + "; $closed=0; $forced=0; $removed=0; "
  command$ + "$targets=@(Get-Process PowerPilot_V* | Where-Object { try { $name=$_.ProcessName + '.exe'; if ($name -ne $own -and $_.ProcessName -notmatch '_Setup$') { $v=[version](($_.ProcessName -replace '^PowerPilot_V','')); $v -lt $ownVersion } else { $false } } catch { $false } }); "
  command$ + "if($targets.Count -gt 0) { $sig='using System; using System.Runtime.InteropServices; public static class PPWin { public delegate bool EnumWindowsProc(IntPtr h, IntPtr l); [DllImport(" + dq$ + "user32.dll" + dq$ + ")] public static extern bool EnumWindows(EnumWindowsProc cb, IntPtr l); [DllImport(" + dq$ + "user32.dll" + dq$ + ")] public static extern uint GetWindowThreadProcessId(IntPtr h, out uint p); [DllImport(" + dq$ + "user32.dll" + dq$ + ")] public static extern bool PostMessage(IntPtr h, uint m, IntPtr w, IntPtr l); }'; Add-Type $sig; foreach($p in $targets) { $script:targetPid=[uint32]$p.Id; $callback=[PPWin+EnumWindowsProc]{ param([IntPtr]$h,[IntPtr]$l) $pid=0; [PPWin]::GetWindowThreadProcessId($h,[ref]$pid) | Out-Null; if($pid -eq $script:targetPid) { [PPWin]::PostMessage($h," + Str(#WM_POWERPILOT_UPDATE_CLOSE) + ",[IntPtr]::Zero,[IntPtr]::Zero) | Out-Null }; return $true }; [PPWin]::EnumWindows($callback,[IntPtr]::Zero) | Out-Null }; Start-Sleep -Milliseconds 1200; foreach($p in $targets) { try { $p.Refresh(); if($p.HasExited) { $closed++ } else { Stop-Process -Id $p.Id -Force; $closed++; $forced++ } } catch { $closed++ } } }; "
  If deleteFiles
    command$ + "Start-Sleep -Milliseconds 500; Get-ChildItem -LiteralPath $app -Filter 'PowerPilot_V*.exe' | ForEach-Object { try { if ($_.Name -ne $own -and $_.Name -notlike '*_Setup.exe') { $v=[version](($_.BaseName -replace '^PowerPilot_V','')); if ($v -lt $ownVersion) { Remove-Item -LiteralPath $_.FullName -Force; $removed++ } } } catch {} }; "
  EndIf
  command$ + "'cleanup|closed=' + $closed + '|forced=' + $forced + '|removed=' + $removed"
  output$ = PowerShellCapture(command$, 8000)
  For i = 1 To CountString(output$, #LF$) + 1
    line$ = Trim(StringField(output$, i, #LF$))
    If Left(line$, 8) = "cleanup|"
      closed = Val(BatteryFieldValue(line$, "closed"))
      forced = Val(BatteryFieldValue(line$, "forced"))
      removed = Val(BatteryFieldValue(line$, "removed"))
      If logEvent And (closed > 0 Or removed > 0)
        If forced > 0
          WriteBatteryAppEvent("PowerPilot update close")
        EndIf
        WriteBatteryAppEvent("PowerPilot cleaned " + Str(closed) + " old process(es) and " + Str(removed) + " old file(s)")
      EndIf
      ProcedureReturn #True
    EndIf
  Next

  ; If PowerShell is unavailable or blocked, fall back to native process
  ; enumeration. The fallback can close processes and delete files when rights
  ; allow, but does not rely on shell command availability.
  snapshot = CreateToolhelp32Snapshot_(#TH32CS_SNAPPROCESS, 0)
  If snapshot <> #INVALID_HANDLE_VALUE
    entry\dwSize = SizeOf(PowerPilotProcessEntry32)
    If Process32First_(snapshot, @entry)
      Repeat
        exeName$ = PeekS(@entry\szExeFile[0])
        exeVersion$ = PowerPilotVersionFromExeName(exeName$)
        If exeVersion$ <> "" And LCase(exeName$) <> ownName$ And entry\th32ProcessID <> ownPid And CompareVersionStrings(exeVersion$, ownVersion$) < 0
          processHandle = OpenProcess_(#PROCESS_TERMINATE | #PROCESS_QUERY_LIMITED_INFORMATION, #False, entry\th32ProcessID)
          If processHandle
            If TerminateProcess_(processHandle, 0)
              closed + 1
            EndIf
            CloseHandle_(processHandle)
          EndIf
        EndIf
      Until Process32Next_(snapshot, @entry) = #False
    EndIf
    CloseHandle_(snapshot)
  EndIf

  If deleteFiles
    Delay(500)
    directory = ExamineDirectory(#PB_Any, GetPathPart(ProgramFilename()), "PowerPilot_V*.exe")
    If directory
      While NextDirectoryEntry(directory)
        If DirectoryEntryType(directory) = #PB_DirectoryEntry_File
          fileName$ = DirectoryEntryName(directory)
          exeVersion$ = PowerPilotVersionFromExeName(fileName$)
          If exeVersion$ <> "" And LCase(fileName$) <> ownName$ And CompareVersionStrings(exeVersion$, ownVersion$) < 0
            fullPath$ = GetPathPart(ProgramFilename()) + fileName$
            If DeleteFile(fullPath$)
              removed + 1
            EndIf
          EndIf
        EndIf
      Wend
      FinishDirectory(directory)
    EndIf
  EndIf

  If logEvent And (closed > 0 Or removed > 0)
    WriteBatteryAppEvent("PowerPilot cleaned " + Str(closed) + " old process(es) and " + Str(removed) + " old file(s)")
  EndIf
  ProcedureReturn #True
EndProcedure

; Locate the graph point at or before an event time for session summary text.
Procedure.i BatteryGraphIndexBefore(timestamp.q)
  Protected i.i
  For i = gBatteryGraphCount - 1 To 0 Step -1
    If gBatteryGraph(i)\Timestamp <= timestamp
      ProcedureReturn i
    EndIf
  Next
  ProcedureReturn -1
EndProcedure

; Locate the graph point at or after an event time for session summary text.
Procedure.i BatteryGraphIndexAfter(timestamp.q)
  Protected i.i
  For i = 0 To gBatteryGraphCount - 1
    If gBatteryGraph(i)\Timestamp >= timestamp
      ProcedureReturn i
    EndIf
  Next
  ProcedureReturn -1
EndProcedure

; Compact event labels for graph markers and summaries.
Procedure.s BatteryEventShortName(eventName$)
  Protected lower$ = LCase(eventName$)
  If FindString(lower$, "improper", 1) : ProcedureReturn "!"
  ElseIf FindString(lower$, "shutdown", 1) : ProcedureReturn "S"
  ElseIf FindString(lower$, "startup", 1) : ProcedureReturn "P"
  ElseIf FindString(lower$, "hibernate", 1) : ProcedureReturn "H"
  ElseIf FindString(lower$, "sleep", 1) : ProcedureReturn "Z"
  ElseIf FindString(lower$, "wake", 1) : ProcedureReturn "W"
  EndIf
  ProcedureReturn "E"
EndProcedure

; Build the Battery Stats tab text from in-memory graph/event data. Active drain
; excludes intervals broken by power events, app lifecycle rows, or large gaps.
Procedure RefreshBatteryStatsSummary()
  Protected now.q = Date()
  Protected dayStart.q = ParseDate("%yyyy-%mm-%dd %hh:%ii:%ss", FormatDate("%yyyy-%mm-%dd 00:00:00", now))
  Protected i.i
  Protected elapsed.q
  Protected activeElapsed.q
  Protected activeDrain.d
  Protected offLoss.d
  Protected offCount.i
  Protected minPct.d = 101.0
  Protected maxPct.d = -1.0
  Protected lastEvent$
  Protected lastEventTime.q
  Protected session$
  Protected daily$
  Protected off$
  Protected beforeIndex.i
  Protected afterIndex.i
  Protected lastGap$
  Protected change.d
  Protected flatGapSeconds.i = BatteryGraphFlatGapSeconds()
  If IsGadget(#GadgetBatterySessionSummary) = #False
    ProcedureReturn
  EndIf
  PruneBatteryAppBreaks(now)
  For i = 0 To gBatteryEventCount - 1
    If gBatteryEvents(i)\Timestamp > 0
      lastEvent$ = gBatteryEvents(i)\Name
      lastEventTime = gBatteryEvents(i)\Timestamp
    EndIf
  Next
  If lastEvent$ <> ""
    session$ = "Last event: " + lastEvent$ + " at " + IsoTimestamp(lastEventTime) + " (" + FormatDurationSeconds(now - lastEventTime) + " ago)"
    beforeIndex = BatteryGraphIndexBefore(lastEventTime)
    afterIndex = BatteryGraphIndexAfter(lastEventTime)
    If beforeIndex >= 0 And afterIndex >= 0 And afterIndex <> beforeIndex
      change = gBatteryGraph(afterIndex)\Percent - gBatteryGraph(beforeIndex)\Percent
      session$ + #CRLF$ + "Battery around event: " + StrD(gBatteryGraph(beforeIndex)\Percent, 1) + "% -> " + StrD(gBatteryGraph(afterIndex)\Percent, 1) + "% (" + StrD(change, 1) + "%)"
    EndIf
  Else
    session$ = "No power session events recorded yet."
  EndIf
  ; Daily min/max can include all graph points from today. Active drain below is
  ; more selective because it should reflect awake/on-battery runtime only.
  For i = 0 To gBatteryGraphCount - 1
    If gBatteryGraph(i)\Timestamp >= dayStart
      If gBatteryGraph(i)\Percent < minPct : minPct = gBatteryGraph(i)\Percent : EndIf
      If gBatteryGraph(i)\Percent > maxPct : maxPct = gBatteryGraph(i)\Percent : EndIf
    EndIf
    If i > 0 And gBatteryGraph(i)\Timestamp >= dayStart
      elapsed = gBatteryGraph(i)\Timestamp - gBatteryGraph(i - 1)\Timestamp
      If elapsed > 0
        If BatteryIntervalHasPowerBreak(gBatteryGraph(i - 1)\Timestamp, gBatteryGraph(i)\Timestamp) Or (elapsed > flatGapSeconds And BatteryIntervalHasAppBreak(gBatteryGraph(i - 1)\Timestamp, gBatteryGraph(i)\Timestamp) = #False)
          If gBatteryGraph(i - 1)\Percent > gBatteryGraph(i)\Percent
            change = gBatteryGraph(i - 1)\Percent - gBatteryGraph(i)\Percent
            offLoss + change
            offCount + 1
            lastGap$ = FormatDurationSeconds(elapsed) + ": " + StrD(change, 1) + "% lost"
          EndIf
        ElseIf gBatteryGraph(i - 1)\Connected = #False And gBatteryGraph(i)\Connected = #False
          activeElapsed + elapsed
          If gBatteryGraph(i - 1)\Percent > gBatteryGraph(i)\Percent
            activeDrain + (gBatteryGraph(i - 1)\Percent - gBatteryGraph(i)\Percent)
          EndIf
        EndIf
      EndIf
    EndIf
  Next
  If minPct <= 100.0
    daily$ = "Today: " + StrD(minPct, 1) + "% min, " + StrD(maxPct, 1) + "% max, " + FormatDurationSeconds(activeElapsed) + " active battery time"
    If activeElapsed >= 60 And activeDrain > 0.0
      daily$ + #CRLF$ + "Active drain: " + StrD((activeDrain * 3600.0) / activeElapsed, 1) + "%/h over " + StrD(activeDrain, 1) + "%"
    Else
      daily$ + #CRLF$ + "Active drain: waiting for more battery samples"
    EndIf
    If gBattery\WearPercent >= 0.0
      daily$ + #CRLF$ + "Health: " + StrD(gBattery\WearPercent, 1) + "% wear, " + Str(gBattery\CycleCount) + " cycles"
    EndIf
  Else
    daily$ = "Today: waiting for battery samples."
  EndIf
  If offCount > 0
    off$ = "Off/sleep loss today: " + StrD(offLoss, 1) + "% across " + Str(offCount) + " gap(s)"
    If lastGap$ <> ""
      off$ + #CRLF$ + "Latest gap: " + lastGap$
    EndIf
  Else
    off$ = "Off/sleep loss today: none detected from retained samples."
  EndIf
  SetGadgetText(#GadgetBatterySessionSummary, session$)
  SetGadgetText(#GadgetBatteryDailySummary, daily$)
  SetGadgetText(#GadgetBatteryOffLossSummary, off$)
EndProcedure

; Rehydrate the graph and break/event arrays from retained CSV rows at startup
; so the graph and summaries have useful history before the next scheduled log.
Procedure LoadBatteryGraphFromLog()
  Protected file.i
  Protected line$
  Protected timestamp$
  Protected timestampValue.q
  Protected fieldCount.i
  Protected percent.d
  Protected connected.i
  Protected charging.i
  gBatteryGraphCount = 0
  gBatteryAverageBreakCount = 0
  gBatteryAppBreakCount = 0
  gBatteryEventCount = 0
  PruneBatteryLog()
  If ReadFile(0, BatteryLogPath())
    While Eof(0) = 0
      line$ = ReadString(0)
      If Left(line$, 9) <> "timestamp" And CountString(line$, ",") >= 3
        fieldCount = CountString(line$, ",") + 1
        timestamp$ = StringField(line$, 1, ",")
        timestampValue = ParseDate("%yyyy-%mm-%ddT%hh:%ii:%ss", timestamp$)
        ; Event rows become graph/session markers. App rows only become break
        ; points, which prevents reinstall/app restarts from looking like PC
        ; shutdowns or sleep gaps.
        If fieldCount >= 19 And LCase(StringField(line$, 18, ",")) = "event"
          AddBatteryEventPoint(timestampValue, StringField(line$, 19, ","))
          If BatteryEventBreaksAverage(StringField(line$, 19, ","))
            AddBatteryAverageBreak(timestampValue)
          EndIf
        ElseIf fieldCount >= 19 And LCase(StringField(line$, 18, ",")) = "app"
          AddBatteryAverageBreak(timestampValue)
          AddBatteryAppBreak(timestampValue)
        Else
          percent = ValD(StringField(line$, 2, ","))
          connected = Val(StringField(line$, 3, ","))
          charging = Val(StringField(line$, 4, ","))
          AddBatteryGraphPoint(timestampValue, percent, connected, charging)
        EndIf
      EndIf
    Wend
    CloseFile(0)
  EndIf
EndProcedure

; Keep the CSV bounded to the latest 168 hours. Rewriting the file is simple
; and safe here because the log is small and written by one tray process.
Procedure PruneBatteryLog()
  Protected path$ = BatteryLogPath()
  Protected tempPath$ = path$ + ".tmp"
  Protected cutoff.q = Date() - #BatteryLogRetentionSeconds
  Protected input.i
  Protected output.i
  Protected line$
  Protected timestamp.q
  Protected header$
  Protected wroteHeader.i
  If FileSize(path$) <= 0
    ProcedureReturn
  EndIf
  input = ReadFile(#PB_Any, path$)
  If input = 0
    ProcedureReturn
  EndIf
  output = CreateFile(#PB_Any, tempPath$)
  If output = 0
    CloseFile(input)
    ProcedureReturn
  EndIf
  WriteStringN(output, BatteryLogHeader())
  wroteHeader = #True
  While Eof(input) = 0
    line$ = ReadString(input)
    If Left(line$, 9) = "timestamp"
      header$ = line$
      If wroteHeader = #False
        WriteStringN(output, header$)
        wroteHeader = #True
      EndIf
    ElseIf Trim(line$) <> ""
      timestamp = ParseDate("%yyyy-%mm-%ddT%hh:%ii:%ss", StringField(line$, 1, ","))
      If timestamp = 0 Or timestamp >= cutoff
        If wroteHeader = #False
          WriteStringN(output, BatteryLogHeader())
          wroteHeader = #True
        EndIf
        WriteStringN(output, line$)
      EndIf
    EndIf
  Wend
  CloseFile(input)
  CloseFile(output)
  If DeleteFile(path$)
    RenameFile(tempPath$, path$)
  Else
    DeleteFile(tempPath$)
  EndIf
EndProcedure

; Return the latest PC power-event row. App rows are ignored so a normal app
; restart does not mask whether the last terminal PC event was Shutdown.
Procedure.s LastBatteryEventName()
  Protected line$
  Protected eventName$
  Protected fieldCount.i
  If ReadFile(0, BatteryLogPath())
    While Eof(0) = 0
      line$ = ReadString(0)
      fieldCount = CountString(line$, ",") + 1
      If fieldCount >= 19 And LCase(StringField(line$, 18, ",")) = "event"
        eventName$ = StringField(line$, 19, ",")
      EndIf
    Wend
    CloseFile(0)
  EndIf
  ProcedureReturn eventName$
EndProcedure

; Windows boot time distinguishes a real PC startup from a PowerPilot restart or
; reinstall inside the same boot session.
Procedure.q CurrentBootTime()
  Protected output$
  Protected line$
  Protected i.i
  Protected boot.q
  output$ = PowerShellCapture("$ErrorActionPreference='SilentlyContinue'; $os=Get-CimInstance -ClassName Win32_OperatingSystem | Select-Object -First 1; if ($os) { 'boot|' + $os.LastBootUpTime.ToString('yyyy-MM-ddTHH:mm:ss') }", 5000)
  For i = 1 To CountString(output$, #LF$) + 1
    line$ = Trim(StringField(output$, i, #LF$))
    If Left(line$, 5) = "boot|"
      boot = ParseDate("%yyyy-%mm-%ddT%hh:%ii:%ss", Mid(line$, 6))
      If boot > 0
        ProcedureReturn boot
      EndIf
    EndIf
  Next
  If gSettings\LastBootTime > 0
    ProcedureReturn gSettings\LastBootTime
  EndIf
  ProcedureReturn Date()
EndProcedure

; Resume broadcasts do not reliably label sleep versus hibernation. Recent
; System log text gives PowerPilot a better event name.
Procedure.s RecentResumeEventName()
  Protected output$
  Protected line$
  Protected i.i
  output$ = PowerShellCapture("$ErrorActionPreference='SilentlyContinue'; $since=(Get-Date).AddHours(-12); $events=Get-WinEvent -FilterHashtable @{LogName='System'; StartTime=$since; Id=1,42,107} -MaxEvents 8; $text=($events | ForEach-Object {$_.ProviderName + ' ' + $_.Id + ' ' + $_.Message}) -join ' '; if ($text -match '(?i)hibernate|hibernation') {'resume|Return from hibernation'} elseif ($text -match '(?i)sleep|suspend') {'resume|Wake'} else {'resume|'}", 4000)
  For i = 1 To CountString(output$, #LF$) + 1
    line$ = Trim(StringField(output$, i, #LF$))
    If Left(line$, 7) = "resume|"
      ProcedureReturn Mid(line$, 8)
    EndIf
  Next
  ProcedureReturn ""
EndProcedure

; Older builds could log installer/app close as Shutdown. On startup, remove
; same-boot false shutdown rows before graph and stats are loaded.
Procedure CleanupAppCloseShutdownEvents(bootTime.q)
  Protected path$ = BatteryLogPath()
  Protected tempPath$ = path$ + ".tmp"
  Protected input.i
  Protected output.i
  Protected line$
  Protected timestamp.q
  Protected fieldCount.i
  Protected eventName$
  Protected previousPowerEvent$
  Protected removed.i
  If bootTime <= 0 Or FileSize(path$) <= 0
    ProcedureReturn
  EndIf
  input = ReadFile(#PB_Any, path$)
  If input = 0
    ProcedureReturn
  EndIf
  output = CreateFile(#PB_Any, tempPath$)
  If output = 0
    CloseFile(input)
    ProcedureReturn
  EndIf
  WriteStringN(output, BatteryLogHeader())
  While Eof(input) = 0
    line$ = ReadString(input)
    If Left(line$, 9) = "timestamp" Or Trim(line$) = ""
      Continue
    EndIf
    fieldCount = CountString(line$, ",") + 1
    timestamp = ParseDate("%yyyy-%mm-%ddT%hh:%ii:%ss", StringField(line$, 1, ","))
    eventName$ = ""
    If fieldCount >= 19 And LCase(StringField(line$, 18, ",")) = "event"
      eventName$ = LCase(StringField(line$, 19, ","))
    EndIf
    If timestamp >= bootTime And (eventName$ = "shutdown requested" Or eventName$ = "shutdown")
      removed + 1
    ElseIf timestamp >= bootTime And eventName$ = "pc startup" And previousPowerEvent$ <> "shutdown" And previousPowerEvent$ <> "improper shutdown"
      removed + 1
    Else
      WriteStringN(output, line$)
      If eventName$ <> ""
        previousPowerEvent$ = eventName$
      EndIf
    EndIf
  Wend
  CloseFile(input)
  CloseFile(output)
  If removed > 0
    If DeleteFile(path$)
      RenameFile(tempPath$, path$)
    Else
      DeleteFile(tempPath$)
    EndIf
  Else
    DeleteFile(tempPath$)
  EndIf
EndProcedure

; Learn an initial drain rate from retained history. Only continuous on-battery
; sample spans count; power/app/event breaks and large gaps are skipped.
Procedure.d BatteryFullLogDrainPctPerHour()
  Protected file.i
  Protected line$
  Protected fieldCount.i
  Protected rowType$
  Protected timestamp.q
  Protected previousTime.q
  Protected elapsed.q
  Protected percent.d
  Protected previousPercent.d
  Protected connected.i
  Protected previousConnected.i
  Protected charging.i
  Protected previousCharging.i
  Protected hasPrevious.i
  Protected activeElapsed.q
  Protected drainTotal.d
  Protected intervalDrain.d
  Protected maxGap.i = BatteryGraphFlatGapSeconds()
  PruneBatteryLog()
  file = ReadFile(#PB_Any, BatteryLogPath())
  If file = 0
    ProcedureReturn 0.0
  EndIf
  While Eof(file) = 0
    line$ = ReadString(file)
    If Left(line$, 9) = "timestamp" Or Trim(line$) = ""
      Continue
    EndIf
    fieldCount = CountString(line$, ",") + 1
    rowType$ = ""
    If fieldCount >= 19
      rowType$ = LCase(StringField(line$, 18, ","))
    EndIf
    If rowType$ = "event" Or rowType$ = "app"
      hasPrevious = #False
      Continue
    EndIf
    If CountString(line$, ",") < 3
      Continue
    EndIf
    timestamp = ParseDate("%yyyy-%mm-%ddT%hh:%ii:%ss", StringField(line$, 1, ","))
    percent = ValD(StringField(line$, 2, ","))
    connected = Val(StringField(line$, 3, ","))
    charging = Val(StringField(line$, 4, ","))
    If timestamp <= 0 Or percent <= 0.0
      hasPrevious = #False
      Continue
    EndIf
    If hasPrevious And previousConnected = #False And connected = #False And previousCharging = #False And charging = #False
      elapsed = timestamp - previousTime
      If elapsed >= 10 And elapsed <= maxGap
        intervalDrain = previousPercent - percent
        If intervalDrain > 0.0 And intervalDrain < 20.0
          drainTotal + intervalDrain
          activeElapsed + elapsed
        EndIf
      EndIf
    EndIf
    previousTime = timestamp
    previousPercent = percent
    previousConnected = connected
    previousCharging = charging
    hasPrevious = #True
  Wend
  CloseFile(file)
  If activeElapsed >= 300 And drainTotal > 0.0
    ProcedureReturn (drainTotal * 3600.0) / activeElapsed
  EndIf
  ProcedureReturn 0.0
EndProcedure

; Apply the learned drain to both startup and last-known drain settings. The
; saved value makes early-session estimates useful before a full glide window.
Procedure AutoSetInitialBatteryDrainFromLog()
  Protected learnedDrain.d = BatteryFullLogDrainPctPerHour()
  If learnedDrain > 0.0 And learnedDrain < 200.0
    If Abs(gSettings\BatteryStartupDrainPctPerHour - learnedDrain) >= 0.05 Or Abs(gSettings\BatteryLastDrainPctPerHour - learnedDrain) >= 0.05
      gSettings\BatteryStartupDrainPctPerHour = learnedDrain
      gSettings\BatteryLastDrainPctPerHour = learnedDrain
      If gBattery\SmoothedDrainPctPerHour <= 0.0
        gBattery\SmoothedDrainPctPerHour = learnedDrain
      EndIf
      SaveSettings()
    EndIf
  EndIf
EndProcedure

; App rows include lifecycle and short status messages. They reset averages and
; appear in the PowerPilot Log, but are not PC power events.
Procedure WriteBatteryAppEvent(eventName$)
  Protected path$ = BatteryLogPath()
  Protected file.i
  Protected writeHeader.i
  Protected line$
  Protected timestamp.q = Date()
  Protected i.i
  eventName$ = CleanBatteryEventName(eventName$)
  If eventName$ = ""
    ProcedureReturn
  EndIf
  EnsureSettingsDirectory()
  writeHeader = Bool(FileSize(path$) <= 0)
  file = OpenFile(#PB_Any, path$)
  If file
    FileSeek(file, Lof(file))
    If writeHeader
      WriteStringN(file, BatteryLogHeader())
    EndIf
    line$ = IsoTimestamp(timestamp)
    For i = 1 To 17
      line$ + ","
    Next
    line$ + "app," + eventName$
    WriteStringN(file, line$)
    CloseFile(file)
    AddBatteryAverageBreak(timestamp)
    AddBatteryAppBreak(timestamp)
    ResetBatteryAverageSamples()
    PruneBatteryLog()
    RefreshBatteryLogPreview()
  EndIf
EndProcedure

; PC power-event rows are separate from battery samples. They are used for graph
; markers, session summaries, off-time loss, and average-drain breaks.
Procedure WriteBatteryEvent(eventName$)
  Protected path$ = BatteryLogPath()
  Protected file.i
  Protected writeHeader.i
  Protected line$
  Protected timestamp.q = Date()
  Protected i.i
  eventName$ = CleanBatteryEventName(eventName$)
  If eventName$ = ""
    ProcedureReturn
  EndIf
  EnsureSettingsDirectory()
  writeHeader = Bool(FileSize(path$) <= 0)
  file = OpenFile(#PB_Any, path$)
  If file
    FileSeek(file, Lof(file))
    If writeHeader
      WriteStringN(file, BatteryLogHeader())
    EndIf
    line$ = IsoTimestamp(timestamp)
    For i = 1 To 17
      line$ + ","
    Next
    line$ + "event," + eventName$
    WriteStringN(file, line$)
    CloseFile(file)
    AddBatteryEventPoint(timestamp, eventName$)
    If BatteryEventBreaksAverage(eventName$)
      AddBatteryAverageBreak(timestamp)
      ResetBatteryAverageSamples()
    EndIf
    PruneBatteryLog()
    RefreshBatteryLogPreview()
    RefreshBatteryStatsSummary()
  EndIf
EndProcedure

; At app startup, compare current boot time with the saved boot time. If the PC
; booted and the last terminal event was not Shutdown, log improper shutdown.
Procedure LogStartupPowerEvents()
  Protected bootTime.q = CurrentBootTime()
  Protected lastEvent$ = LastBatteryEventName()
  Protected newBoot.i = Bool(gSettings\LastBootTime = 0 Or Abs(bootTime - gSettings\LastBootTime) > 120)
  CleanupAppCloseShutdownEvents(bootTime)
  If newBoot
    If gSettings\LastBootTime <> 0
      If LCase(lastEvent$) <> "shutdown"
        WriteBatteryEvent("Improper shutdown")
      EndIf
      WriteBatteryEvent("PC startup")
    EndIf
    gSettings\LastBootTime = bootTime
    SaveSettings()
  EndIf
EndProcedure

; Static battery data changes slowly, so query it once a day or on forced
; startup refresh. Design capacity may require a batteryreport fallback.
Procedure QueryBatteryStatic(force.i = #False)
  Protected now.q = Date()
  Protected output$
  Protected line$
  Protected i.i
  Protected full.d
  Protected design.d
  Protected cycle.i
  If force = #False And gSettings\BatteryLastStaticQuery > 0 And now - gSettings\BatteryLastStaticQuery < #BatteryStaticRefreshSeconds
    ProcedureReturn
  EndIf
  ; root\wmi normally provides full-charge capacity and cycle count. Design
  ; capacity is less consistent across devices, so the command falls back
  ; through BatteryStaticData, Win32_Battery, then powercfg /batteryreport.
  output$ = PowerShellCapture("$ErrorActionPreference='SilentlyContinue'; $full=Get-CimInstance -Namespace root\wmi -ClassName BatteryFullChargedCapacity | Select-Object -First 1; $cycle=Get-CimInstance -Namespace root\wmi -ClassName BatteryCycleCount | Select-Object -First 1; $static=Get-CimInstance -Namespace root\wmi -ClassName BatteryStaticData | Select-Object -First 1; $win=Get-CimInstance -ClassName Win32_Battery | Select-Object -First 1; $design=0; if ($static -and $static.DesignedCapacity) {$design=$static.DesignedCapacity}; if (-not $design -and $static -and $static.DesignCapacity) {$design=$static.DesignCapacity}; if (-not $design -and $win -and $win.DesignCapacity) {$design=$win.DesignCapacity}; if (-not $design) {$path=Join-Path $env:TEMP 'PowerPilot_battery_report.html'; powercfg /batteryreport /output $path | Out-Null; if (Test-Path $path) {$html=Get-Content -LiteralPath $path -Raw; $m=[regex]::Match($html,'DESIGN CAPACITY</span></td><td>([\d,]+) mWh'); if ($m.Success) {$design=[int](($m.Groups[1].Value) -replace ',','')}}}; if ($full) { 'static|FullChargedCapacity=' + $full.FullChargedCapacity + '|DesignCapacity=' + $design + '|CycleCount=' + $(if ($cycle) {$cycle.CycleCount} else {-1}) }")
  For i = 1 To CountString(output$, #LF$) + 1
    line$ = Trim(StringField(output$, i, #LF$))
    If Left(line$, 7) = "static|"
      full = ValD(BatteryFieldValue(line$, "FullChargedCapacity"))
      design = ValD(BatteryFieldValue(line$, "DesignCapacity"))
      cycle = Val(BatteryFieldValue(line$, "CycleCount"))
      If full > 0.0
        gBattery\FullMWh = full
      EndIf
      If design > 0.0
        gBattery\DesignMWh = design
        If gBattery\FullMWh > 0.0
          gBattery\WearPercent = 100.0 - ((gBattery\FullMWh / gBattery\DesignMWh) * 100.0)
          If gBattery\WearPercent < 0.0 : gBattery\WearPercent = 0.0 : EndIf
        EndIf
      EndIf
      If cycle >= 0
        gBattery\CycleCount = cycle
      EndIf
      gSettings\BatteryLastStaticQuery = now
      SaveSettings()
      ProcedureReturn
    EndIf
  Next
EndProcedure

; Live WMI read. BatteryRuntime.EstimatedRuntime is seconds on this machine,
; while Win32_Battery.EstimatedRunTime is minutes, so both units are handled.
Procedure QueryBatteryStatus()
  Protected output$
  Protected line$
  Protected i.i
  Protected status.SYSTEM_POWER_STATUS
  Protected percent.d
  Protected runtimeSeconds.q
  Protected runtimeMinutes.q
  output$ = PowerShellCapture("$ErrorActionPreference='SilentlyContinue'; $s=Get-CimInstance -Namespace root\wmi -ClassName BatteryStatus | Select-Object -First 1; $r=Get-CimInstance -Namespace root\wmi -ClassName BatteryRuntime | Select-Object -First 1; $w=Get-CimInstance -ClassName Win32_Battery | Select-Object -First 1; if ($s) { 'status|Active=' + $s.Active + '|PowerOnline=' + $s.PowerOnline + '|Charging=' + $s.Charging + '|Discharging=' + $s.Discharging + '|RemainingCapacity=' + $s.RemainingCapacity + '|ChargeRate=' + $s.ChargeRate + '|DischargeRate=' + $s.DischargeRate + '|Voltage=' + $s.Voltage + '|EstimatedRuntimeSeconds=' + $(if ($r) {$r.EstimatedRuntime} else {-1}) + '|Win32EstimatedMinutes=' + $(if ($w) {$w.EstimatedRunTime} else {-1}) }")
  For i = 1 To CountString(output$, #LF$) + 1
    line$ = Trim(StringField(output$, i, #LF$))
    If Left(line$, 7) = "status|"
      gBattery\Valid = #True
      gBattery\Timestamp = Date()
      gBattery\Connected = BatteryBool(BatteryFieldValue(line$, "PowerOnline"))
      gBattery\Charging = BatteryBool(BatteryFieldValue(line$, "Charging"))
      gBattery\DisconnectedBattery = Bool(gBattery\Connected = #False)
      gBattery\RemainingMWh = ValD(BatteryFieldValue(line$, "RemainingCapacity"))
      gBattery\ChargeRateMW = ValD(BatteryFieldValue(line$, "ChargeRate"))
      gBattery\DischargeRateMW = ValD(BatteryFieldValue(line$, "DischargeRate"))
      gBattery\VoltageMV = ValD(BatteryFieldValue(line$, "Voltage"))
      runtimeSeconds = Val(BatteryFieldValue(line$, "EstimatedRuntimeSeconds"))
      runtimeMinutes = Val(BatteryFieldValue(line$, "Win32EstimatedMinutes"))
      ; Prefer root\wmi runtime when it is usable, then fall back to Win32.
      gBattery\RuntimeValid = Bool(runtimeSeconds > 0 And runtimeSeconds < 864000)
      If gBattery\RuntimeValid
        gBattery\RuntimeMinutes = runtimeSeconds / 60
      ElseIf runtimeMinutes > 0 And runtimeMinutes < 14400
        gBattery\RuntimeValid = #True
        gBattery\RuntimeMinutes = runtimeMinutes
      Else
        gBattery\RuntimeMinutes = -1
      EndIf
      If gBattery\FullMWh > 0.0 And gBattery\RemainingMWh > 0.0
        percent = (gBattery\RemainingMWh / gBattery\FullMWh) * 100.0
        If percent > 100.0 : percent = 100.0 : EndIf
        gBattery\Percent = percent
      ElseIf GetSystemPowerStatus_(@status) And status\BatteryLifePercent <= 100
        gBattery\Percent = status\BatteryLifePercent
      EndIf
      ProcedureReturn
    EndIf
  Next

  If GetSystemPowerStatus_(@status)
    gBattery\Valid = #True
    gBattery\Timestamp = Date()
    gBattery\Connected = Bool(status\ACLineStatus <> 0)
    gBattery\Charging = Bool(status\BatteryFlag & 8)
    gBattery\DisconnectedBattery = Bool(status\ACLineStatus = 0)
    If status\BatteryLifePercent <= 100
      gBattery\Percent = status\BatteryLifePercent
    EndIf
    gBattery\RuntimeValid = Bool(status\BatteryLifeTime > 0 And status\BatteryLifeTime < 864000)
    If gBattery\RuntimeValid
      gBattery\RuntimeMinutes = status\BatteryLifeTime / 60
    Else
      gBattery\RuntimeMinutes = -1
    EndIf
  EndIf
EndProcedure

; Calculate the rolling average drain from recent graph points. Until a full
; glide window exists, the elapsed available active-battery time is used.
Procedure.d BatteryAverageDrainPctPerHour(now.q)
  Protected windowStart.q = now - (ClampInt(gSettings\BatterySmoothingMinutes, 5, 240) * 60)
  Protected i.i
  Protected previousTime.q = now
  Protected previousPercent.d = gBattery\Percent
  Protected elapsed.q
  Protected drain.d
  Protected totalDrain.d
  Protected activeElapsed.q
  Protected maxInterval.i = (ClampInt(gSettings\BatteryLogIntervalMinutes, 1, 1440) * 120) + 60
  Protected refreshInterval.i = ClampInt(gSettings\BatteryRefreshSeconds, 5, 3600) * 4
  If refreshInterval > maxInterval
    maxInterval = refreshInterval
  EndIf
  If maxInterval < 600
    maxInterval = 600
  EndIf
  PruneBatteryAverageBreaks(now)
  ; Walk backward from the current point and stop at AC power, a break row, a
  ; large gap, or the configured glide-window boundary.
  For i = gBatteryGraphCount - 1 To 0 Step -1
    If gBatteryGraph(i)\Timestamp <= 0 Or gBatteryGraph(i)\Timestamp > previousTime
      Continue
    EndIf
    If gBatteryGraph(i)\Connected
      Break
    EndIf
    If gBatteryGraph(i)\Timestamp < windowStart
      Break
    EndIf
    If BatteryIntervalHasAverageBreak(gBatteryGraph(i)\Timestamp, previousTime)
      Break
    EndIf
    elapsed = previousTime - gBatteryGraph(i)\Timestamp
    If elapsed > maxInterval
      Break
    EndIf
    If elapsed >= 10
      drain = gBatteryGraph(i)\Percent - previousPercent
      If drain > 0.0
        totalDrain + drain
      EndIf
      activeElapsed + elapsed
    EndIf
    previousTime = gBatteryGraph(i)\Timestamp
    previousPercent = gBatteryGraph(i)\Percent
  Next
  ; If the graph has not yet been updated, fall back to the last live sample so
  ; the estimate can start moving before the first scheduled log interval.
  If activeElapsed = 0 And gBatteryLastSampleTime > 0 And gBatteryLastSampleTime < now And BatteryIntervalHasAverageBreak(gBatteryLastSampleTime, now) = #False
    elapsed = now - gBatteryLastSampleTime
    If elapsed >= 10 And elapsed <= maxInterval And gBatteryLastSamplePercent > gBattery\Percent
      totalDrain = gBatteryLastSamplePercent - gBattery\Percent
      activeElapsed = elapsed
    EndIf
  EndIf
  If activeElapsed >= 10 And totalDrain > 0.0
    drain = (totalDrain * 3600.0) / activeElapsed
    If drain > 0.0 And drain < 200.0
      ProcedureReturn drain
    EndIf
  EndIf
  ProcedureReturn 0.0
EndProcedure

; Combine firmware/WMI discharge rate, measured percent drop, and retained-log
; learning into average and instant remaining-time estimates.
Procedure UpdateBatteryEstimate()
  Protected now.q = gBattery\Timestamp
  Protected elapsed.q
  Protected liveDrain.d
  Protected sampleDrain.d
  Protected instantDrain.d
  Protected averageDrain.d
  Protected remainingPercent.d
  If gBattery\Valid = #False
    ProcedureReturn
  EndIf

  ; Seed the first display from retained history or user setting so startup does
  ; not show "Calculating" until a full hour has passed.
  If gBattery\SmoothedDrainPctPerHour <= 0.0
    If gSettings\BatteryLastDrainPctPerHour > 0.0
      gBattery\SmoothedDrainPctPerHour = gSettings\BatteryLastDrainPctPerHour
    Else
      gBattery\SmoothedDrainPctPerHour = gSettings\BatteryStartupDrainPctPerHour
    EndIf
  EndIf

  If gBattery\DisconnectedBattery
    If gBatteryOnBatterySince = 0
      gBatteryOnBatterySince = now
    EndIf
    ; Instant drain prefers current WMI discharge rate because it reflects the
    ; present workload. Measured percent drop is used to stabilize/fill gaps.
    If gBattery\FullMWh > 0.0 And gBattery\DischargeRateMW > 0.0
      liveDrain = (gBattery\DischargeRateMW / gBattery\FullMWh) * 100.0
      instantDrain = liveDrain
    EndIf
    If gBatteryLastSampleTime > 0 And gBatteryLastSamplePercent > gBattery\Percent
      elapsed = now - gBatteryLastSampleTime
      If elapsed >= 10
        sampleDrain = ((gBatteryLastSamplePercent - gBattery\Percent) * 3600.0) / elapsed
        If sampleDrain > 0.0 And sampleDrain < 200.0
          If instantDrain <= 0.0
            instantDrain = sampleDrain
          EndIf
          If liveDrain > 0.0
            liveDrain = (liveDrain + sampleDrain) / 2.0
          Else
            liveDrain = sampleDrain
          EndIf
        EndIf
      EndIf
    EndIf
    If liveDrain > 0.0 And liveDrain < 200.0
      ; Average drain is entirely time/sample based, excluding sleep, hibernate,
      ; shutdown, app restart, and other break rows.
      averageDrain = BatteryAverageDrainPctPerHour(now)
      If averageDrain > 0.0
        gBattery\SmoothedDrainPctPerHour = averageDrain
      Else
        gBattery\SmoothedDrainPctPerHour = liveDrain
      EndIf
    EndIf
    ; Remaining time is calculated to the configured floor, default 5 percent,
    ; not to absolute zero.
    remainingPercent = gBattery\Percent - gSettings\BatteryMinPercent
    If remainingPercent > 0.0 And instantDrain > 0.0 And instantDrain < 200.0
      gBattery\InstantDrainPctPerHour = instantDrain
      gBattery\InstantEstimateMinutes = (remainingPercent / instantDrain) * 60.0
      gBattery\InstantEstimateValid = #True
    Else
      gBattery\InstantDrainPctPerHour = 0.0
      gBattery\InstantEstimateMinutes = -1
      gBattery\InstantEstimateValid = #False
    EndIf
    If remainingPercent > 0.0 And gBattery\SmoothedDrainPctPerHour > 0.0
      gBattery\EstimateMinutes = (remainingPercent / gBattery\SmoothedDrainPctPerHour) * 60.0
      gBattery\EstimateValid = #True
    Else
      gBattery\EstimateMinutes = -1
      gBattery\EstimateValid = #False
    EndIf
  Else
    gBatteryOnBatterySince = 0
    gBattery\EstimateMinutes = -1
    gBattery\EstimateValid = #False
    gBattery\InstantDrainPctPerHour = 0.0
    gBattery\InstantEstimateMinutes = -1
    gBattery\InstantEstimateValid = #False
  EndIf

  gBatteryLastSampleTime = now
  gBatteryLastSamplePercent = gBattery\Percent
EndProcedure

; Write a battery sample row when the interval elapses, or immediately on
; forced startup/refresh. App and event rows are written by separate functions.
Procedure WriteBatteryLog(force.i = #False)
  Protected path$ = BatteryLogPath()
  Protected file.i
  Protected writeHeader.i
  Protected line$
  Protected intervalSeconds.i = ClampInt(gSettings\BatteryLogIntervalMinutes, 1, 1440) * 60
  If gSettings\BatteryLogEnabled = #False Or gBattery\Valid = #False
    ProcedureReturn
  EndIf
  If force = #False And gLastBatteryLogTime > 0 And gBattery\Timestamp - gLastBatteryLogTime < intervalSeconds
    ProcedureReturn
  EndIf
  EnsureSettingsDirectory()
  writeHeader = Bool(FileSize(path$) <= 0)
  file = OpenFile(#PB_Any, path$)
  If file
    FileSeek(file, Lof(file))
    If writeHeader
      WriteStringN(file, BatteryLogHeader())
    EndIf
    ; CSV order must match BatteryLogHeader. Runtime minutes is the direct
    ; Windows estimate; average/instant values are PowerPilot estimates.
    line$ = IsoTimestamp(gBattery\Timestamp)
    line$ + "," + StrD(gBattery\Percent, 2)
    line$ + "," + Str(gBattery\Connected)
    line$ + "," + Str(gBattery\Charging)
    line$ + "," + Str(gBattery\DisconnectedBattery)
    line$ + "," + StrD(gBattery\RemainingMWh, 0)
    line$ + "," + StrD(gBattery\FullMWh, 0)
    line$ + "," + StrD(gBattery\DesignMWh, 0)
    line$ + "," + StrD(gBattery\WearPercent, 1)
    line$ + "," + StrD(gBattery\DischargeRateMW, 0)
    line$ + "," + StrD(gBattery\ChargeRateMW, 0)
    line$ + "," + Str(gBattery\RuntimeMinutes)
    line$ + "," + Str(gBattery\EstimateMinutes)
    line$ + "," + Str(gBattery\InstantEstimateMinutes)
    line$ + "," + StrD(gBattery\InstantDrainPctPerHour, 2)
    line$ + "," + StrD(gBattery\SmoothedDrainPctPerHour, 2)
    line$ + "," + Str(gBattery\CycleCount)
    line$ + ",battery,"
    WriteStringN(file, line$)
    CloseFile(file)
    PruneBatteryLog()
    gLastBatteryLogTime = gBattery\Timestamp
    If gBattery\SmoothedDrainPctPerHour > 0.0
      gSettings\BatteryLastDrainPctPerHour = gBattery\SmoothedDrainPctPerHour
      SaveSettings()
    EndIf
    AddBatteryGraphPoint(gBattery\Timestamp, gBattery\Percent, gBattery\Connected, gBattery\Charging)
    RefreshBatteryLogPreview()
  EndIf
EndProcedure

; Refresh live battery data on the configured cadence. Static capacity data is
; queried only when missing or once per day to keep startup/refresh light.
Procedure RefreshBattery(force.i = #False)
  Protected now.q = Date()
  If force = #False And gLastBatteryRefresh > 0 And now - gLastBatteryRefresh < ClampInt(gSettings\BatteryRefreshSeconds, 5, 3600)
    ProcedureReturn
  EndIf
  QueryBatteryStatic(Bool(gBattery\FullMWh <= 0.0))
  QueryBatteryStatus()
  If gBattery\Valid
    UpdateBatteryEstimate()
    AddBatteryGraphPoint(gBattery\Timestamp, gBattery\Percent, gBattery\Connected, gBattery\Charging)
    WriteBatteryLog()
  EndIf
  gLastBatteryRefresh = now
  RefreshBatteryDisplay()
EndProcedure

; powercfg wrappers keep all plan manipulation in one place.
Procedure.i RunPowerCfg(arguments$)
  ProcedureReturn RunExitCode("powercfg.exe", arguments$)
EndProcedure

Procedure.s RunPowerCfgCapture(arguments$)
  ProcedureReturn RunCapture("powercfg.exe", arguments$)
EndProcedure

; Extract the first GUID from powercfg output.
Procedure.s FindGuidInText(text$)
  Protected re.i
  Protected result$
  re = CreateRegularExpression(#PB_Any, "[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}")
  If re
    If ExamineRegularExpression(re, text$)
      If NextRegularExpressionMatch(re)
        result$ = RegularExpressionMatchString(re)
      EndIf
    EndIf
    FreeRegularExpression(re)
  EndIf
  ProcedureReturn LCase(result$)
EndProcedure

; Helpers for converting GUID pointers returned by powrprof.dll into strings.
Procedure.s HexPart(value.q, width.i)
  ProcedureReturn RSet(LCase(Hex(value)), width, "0")
EndProcedure

Procedure.s GuidPointerText(*guid)
  Protected text$
  If *guid = 0
    ProcedureReturn ""
  EndIf

  text$ = HexPart(PeekL(*guid) & $FFFFFFFF, 8)
  text$ + "-" + HexPart(PeekW(*guid + 4) & $FFFF, 4)
  text$ + "-" + HexPart(PeekW(*guid + 6) & $FFFF, 4)
  text$ + "-" + HexPart(PeekA(*guid + 8) & $FF, 2) + HexPart(PeekA(*guid + 9) & $FF, 2)
  text$ + "-" + HexPart(PeekA(*guid + 10) & $FF, 2) + HexPart(PeekA(*guid + 11) & $FF, 2)
  text$ + HexPart(PeekA(*guid + 12) & $FF, 2) + HexPart(PeekA(*guid + 13) & $FF, 2)
  text$ + HexPart(PeekA(*guid + 14) & $FF, 2) + HexPart(PeekA(*guid + 15) & $FF, 2)
  ProcedureReturn text$
EndProcedure

; Load powrprof lazily. Some Windows builds expose different overlay APIs, so
; GetWindowsPowerModeGuid falls back between them.
Procedure EnsurePowerApi()
  If gPowerApiTried
    ProcedureReturn
  EndIf
  gPowerApiTried = #True
  gPowrProfLibrary = OpenLibrary(#PB_Any, "powrprof.dll")
  If gPowrProfLibrary
    gPowerGetActiveScheme = GetFunction(gPowrProfLibrary, "PowerGetActiveScheme")
    gPowerGetEffectiveOverlayScheme = GetFunction(gPowrProfLibrary, "PowerGetEffectiveOverlayScheme")
    gPowerGetUserConfiguredACPowerMode = GetFunction(gPowrProfLibrary, "PowerGetUserConfiguredACPowerMode")
    gPowerGetUserConfiguredDCPowerMode = GetFunction(gPowrProfLibrary, "PowerGetUserConfiguredDCPowerMode")
  EndIf
EndProcedure

; Read a GUID from one of the powrprof overlay callbacks.
Procedure.s ReadPowerGuidValue(callback.PowerGetGuidValueProto)
  Protected *guid
  Protected result$
  If callback = 0
    ProcedureReturn ""
  EndIf
  *guid = AllocateMemory(16)
  If *guid
    If callback(*guid) = #ERROR_SUCCESS
      result$ = GuidPointerText(*guid)
    EndIf
    FreeMemory(*guid)
  EndIf
  ProcedureReturn result$
EndProcedure

; API path for active plan GUID. powercfg text parsing is kept as fallback.
Procedure.s GetActiveSchemeGuidByApi()
  Protected activeScheme.i
  Protected guid$
  EnsurePowerApi()
  If gPowerGetActiveScheme And gPowerGetActiveScheme(0, @activeScheme) = #ERROR_SUCCESS And activeScheme
    guid$ = GuidPointerText(activeScheme)
    LocalFree_(activeScheme)
  EndIf
  ProcedureReturn guid$
EndProcedure

; Use GetSystemPowerStatus for a cheap AC/DC check when choosing AC/DC overlay.
Procedure.i CurrentPowerSupplyIsBattery()
  Protected status.SYSTEM_POWER_STATUS
  If GetSystemPowerStatus_(@status)
    ProcedureReturn Bool(status\ACLineStatus = 0)
  EndIf
  ProcedureReturn #False
EndProcedure

; Resolve Windows power mode overlay. Prefer the effective overlay; fall back to
; the user-configured AC/DC overlay when effective overlay is unavailable.
Procedure.s GetWindowsPowerModeGuid()
  Protected guid$
  EnsurePowerApi()

  guid$ = ReadPowerGuidValue(gPowerGetEffectiveOverlayScheme)
  If guid$ <> ""
    ProcedureReturn guid$
  EndIf

  If CurrentPowerSupplyIsBattery()
    guid$ = ReadPowerGuidValue(gPowerGetUserConfiguredDCPowerMode)
  Else
    guid$ = ReadPowerGuidValue(gPowerGetUserConfiguredACPowerMode)
  EndIf
  ProcedureReturn guid$
EndProcedure

; Load process-throttling APIs lazily. If unavailable, maintenance throttling is
; simply skipped.
Procedure EnsureProcessThrottleApi()
  If gThrottleApiTried
    ProcedureReturn
  EndIf
  gThrottleApiTried = #True
  gKernelLibrary = OpenLibrary(#PB_Any, "kernel32.dll")
  If gKernelLibrary
    gSetProcessInformation = GetFunction(gKernelLibrary, "SetProcessInformation")
    gGetProcessInformation = GetFunction(gKernelLibrary, "GetProcessInformation")
  EndIf
EndProcedure

; Avoid throttling the foreground process, even if its exe name matches a
; maintenance process pattern.
Procedure.i ForegroundProcessId()
  Protected hwnd.i = GetForegroundWindow_()
  Protected pid.i
  If hwnd
    GetWindowThreadProcessId_(hwnd, @pid)
  EndIf
  ProcedureReturn pid
EndProcedure

; Conservative allowlist of background maintenance processes that are safe to
; place in EcoQoS while Windows is in efficiency mode.
Procedure.i IsMaintenanceThrottleProcessName(exeName$)
  Select LCase(exeName$)
    Case "searchindexer.exe", "searchprotocolhost.exe", "searchfilterhost.exe"
      ProcedureReturn #True
    Case "sdxhelper.exe", "officec2rclient.exe", "officeclicktorun.exe"
      ProcedureReturn #True
    Case "microsoftedgeupdate.exe"
      ProcedureReturn #True
  EndSelect
  ProcedureReturn #False
EndProcedure

; Apply or clear EcoQoS execution-speed throttling on one process.
Procedure.i SetProcessEcoThrottle(pid.i, enable.i)
  Protected processHandle.i
  Protected state.ProcessPowerThrottlingState
  Protected stateSize.i = SizeOf(ProcessPowerThrottlingState)
  Protected queried.i
  Protected result.i

  If pid <= 0
    ProcedureReturn #False
  EndIf
  EnsureProcessThrottleApi()
  If gSetProcessInformation = 0
    ProcedureReturn #False
  EndIf

  processHandle = OpenProcess_(#PROCESS_SET_INFORMATION | #PROCESS_QUERY_LIMITED_INFORMATION, #False, pid)
  If processHandle = 0
    ProcedureReturn #False
  EndIf

  state\Version = #PROCESS_POWER_THROTTLING_CURRENT_VERSION
  If gGetProcessInformation
    queried = gGetProcessInformation(processHandle, #ProcessPowerThrottling, @state, stateSize)
  EndIf
  If queried = #False
    state\Version = #PROCESS_POWER_THROTTLING_CURRENT_VERSION
    state\ControlMask = 0
    state\StateMask = 0
  EndIf

  If enable
    state\ControlMask = state\ControlMask | #PROCESS_POWER_THROTTLING_EXECUTION_SPEED
    state\StateMask = state\StateMask | #PROCESS_POWER_THROTTLING_EXECUTION_SPEED
  Else
    If state\ControlMask & #PROCESS_POWER_THROTTLING_EXECUTION_SPEED
      state\ControlMask = state\ControlMask ! #PROCESS_POWER_THROTTLING_EXECUTION_SPEED
    EndIf
    If state\StateMask & #PROCESS_POWER_THROTTLING_EXECUTION_SPEED
      state\StateMask = state\StateMask ! #PROCESS_POWER_THROTTLING_EXECUTION_SPEED
    EndIf
  EndIf

  result = gSetProcessInformation(processHandle, #ProcessPowerThrottling, @state, stateSize)
  CloseHandle_(processHandle)
  ProcedureReturn Bool(result)
EndProcedure

; Scan processes at a modest cadence and apply EcoQoS only to the allowlist.
Procedure.i ApplyMaintenanceThrottling(enable.i, force.i = #False)
  Protected now.q = ElapsedMilliseconds()
  Protected snapshot.i
  Protected entry.PowerPilotProcessEntry32
  Protected foregroundPid.i = ForegroundProcessId()
  Protected exeName$
  Protected changed.i

  If gSettings\ThrottleMaintenance = #False
    enable = #False
  EndIf
  If force = #False And enable And gMaintenanceThrottleActive And now - gLastMaintenanceThrottleScan < #ThrottleScanMs
    ProcedureReturn 0
  EndIf
  If force = #False And enable = #False And gMaintenanceThrottleActive = #False
    ProcedureReturn 0
  EndIf

  EnsureProcessThrottleApi()
  If gSetProcessInformation = 0
    ProcedureReturn 0
  EndIf

  snapshot = CreateToolhelp32Snapshot_(#TH32CS_SNAPPROCESS, 0)
  If snapshot = #INVALID_HANDLE_VALUE
    ProcedureReturn 0
  EndIf

  entry\dwSize = SizeOf(PowerPilotProcessEntry32)
  If Process32First_(snapshot, @entry)
    Repeat
      exeName$ = PeekS(@entry\szExeFile[0])
      If IsMaintenanceThrottleProcessName(exeName$) And entry\th32ProcessID <> foregroundPid
        If SetProcessEcoThrottle(entry\th32ProcessID, enable)
          changed + 1
        EndIf
      EndIf
    Until Process32Next_(snapshot, @entry) = #False
  EndIf
  CloseHandle_(snapshot)

  gMaintenanceThrottleActive = Bool(enable)
  gLastMaintenanceThrottleScan = now
  ProcedureReturn changed
EndProcedure

; powercfg /L prints plan names in parentheses; this extracts the display name.
Procedure.s SchemeNameFromPowerCfgLine(line$)
  Protected p1.i = FindString(line$, "(", 1)
  Protected p2.i
  If p1
    p2 = FindString(line$, ")", p1 + 1)
    If p2 > p1
      ProcedureReturn Mid(line$, p1 + 1, p2 - p1 - 1)
    EndIf
  EndIf
  ProcedureReturn ""
EndProcedure

; Any plan create/delete/rename can invalidate both name->GUID and GUID->name.
Procedure InvalidateSchemeCache()
  gSchemeCacheValid = #False
  gCachedActiveName$ = ""
  ClearMap(gSchemeGuidByName())
  ClearMap(gSchemeNameByGuid())
EndProcedure

; Rebuild the scheme maps from powercfg /L.
Procedure RefreshSchemeCache()
  Protected output$ = ReplaceString(RunPowerCfgCapture("/L"), #CR$, "")
  Protected line$
  Protected guid$
  Protected name$
  Protected i.i

  ClearMap(gSchemeGuidByName())
  ClearMap(gSchemeNameByGuid())
  For i = 1 To CountString(output$, #LF$) + 1
    line$ = StringField(output$, i, #LF$)
    guid$ = FindGuidInText(line$)
    name$ = SchemeNameFromPowerCfgLine(line$)
    If guid$ <> "" And name$ <> ""
      gSchemeNameByGuid(guid$) = name$
      gSchemeGuidByName(LCase(name$)) = guid$
    EndIf
  Next
  gSchemeCacheValid = #True
EndProcedure

; Active plan GUID is read from powrprof when possible, then from powercfg.
Procedure.s GetActiveSchemeGuid()
  Protected guid$ = GetActiveSchemeGuidByApi()
  If guid$ = ""
    guid$ = FindGuidInText(RunPowerCfgCapture("/GETACTIVESCHEME"))
  EndIf
  ProcedureReturn guid$
EndProcedure

; Resolve a Windows plan GUID from its display name, refreshing once on miss.
Procedure.s GetSchemeGuidByName(planName$, forceRefresh.i = #False)
  Protected key$ = LCase(planName$)
  If forceRefresh Or gSchemeCacheValid = #False
    RefreshSchemeCache()
  EndIf
  If FindMapElement(gSchemeGuidByName(), key$)
    ProcedureReturn gSchemeGuidByName()
  EndIf
  If forceRefresh = #False
    RefreshSchemeCache()
    If FindMapElement(gSchemeGuidByName(), key$)
      ProcedureReturn gSchemeGuidByName()
    EndIf
  EndIf
  ProcedureReturn ""
EndProcedure

; Resolve a Windows plan name from its GUID, refreshing once on miss.
Procedure.s GetSchemeNameByGuid(schemeGuid$, forceRefresh.i = #False)
  schemeGuid$ = LCase(schemeGuid$)
  If forceRefresh Or gSchemeCacheValid = #False
    RefreshSchemeCache()
  EndIf
  If FindMapElement(gSchemeNameByGuid(), schemeGuid$)
    ProcedureReturn gSchemeNameByGuid()
  EndIf
  If forceRefresh = #False
    RefreshSchemeCache()
    If FindMapElement(gSchemeNameByGuid(), schemeGuid$)
      ProcedureReturn gSchemeNameByGuid()
    EndIf
  EndIf
  ProcedureReturn ""
EndProcedure

; Set one AC or DC power setting value through powercfg.
Procedure.i SetSchemeValue(schemeGuid$, acMode.i, subgroup$, setting$, value.i)
  Protected mode$ = "/SETDCVALUEINDEX "
  If acMode
    mode$ = "/SETACVALUEINDEX "
  EndIf
  ProcedureReturn RunPowerCfg(mode$ + schemeGuid$ + " " + subgroup$ + " " + setting$ + " " + Str(value))
EndProcedure

; Some processor settings are not available on every CPU/firmware combination.
; Optional writes intentionally ignore the result.
Procedure TrySetSchemeValue(schemeGuid$, acMode.i, subgroup$, setting$, value.i)
  SetSchemeValue(schemeGuid$, acMode, subgroup$, setting$, value)
EndProcedure

; Windows exposes several generation-specific maximum-frequency aliases.
Procedure SetFrequencyCaps(schemeGuid$, acMode.i, mhz.i)
  TrySetSchemeValue(schemeGuid$, acMode, "SUB_PROCESSOR", "PROCFREQMAX", mhz)
  TrySetSchemeValue(schemeGuid$, acMode, "SUB_PROCESSOR", "PROCFREQMAX1", mhz)
  TrySetSchemeValue(schemeGuid$, acMode, "SUB_PROCESSOR", "PROCFREQMAX2", mhz)
EndProcedure

; Tie Windows' on-battery critical action to PowerPilot's estimate floor. The
; value 1 is Sleep in the Battery/Critical battery action power setting.
Procedure.i ConfigureBatterySleepFloor(schemeGuid$)
  Protected floor.i = ClampInt(gSettings\BatteryMinPercent, 1, 99)
  Protected lowWarning.i = ClampInt(floor + 1, 1, 100)
  If schemeGuid$ = ""
    ProcedureReturn #False
  EndIf
  TrySetSchemeValue(schemeGuid$, #False, "SUB_BATTERY", "BATFLAGSLOW", 1)
  TrySetSchemeValue(schemeGuid$, #False, "SUB_BATTERY", "BATLEVELLOW", lowWarning)
  TrySetSchemeValue(schemeGuid$, #False, "SUB_BATTERY", "BATFLAGSCRIT", 1)
  TrySetSchemeValue(schemeGuid$, #False, "SUB_BATTERY", "BATACTIONCRIT", 1)
  TrySetSchemeValue(schemeGuid$, #False, "SUB_BATTERY", "BATLEVELCRIT", floor)
  ProcedureReturn #True
EndProcedure

; Apply all PowerPilot-owned processor settings to one Windows scheme. The
; visible plan editor controls the headline values; this routine also sets
; hidden ramp, boost-policy, cooling, and parking values for consistency.
Procedure.i ConfigureScheme(*plan.PlanDefinition, schemeGuid$)
  Protected acMinState.i = 5
  Protected dcMinState.i = 5
  Protected acCoreParkingMin.i = 100
  Protected dcCoreParkingMin.i = 25
  Protected acCoreParkingMin1.i = 100
  Protected dcCoreParkingMin1.i = 25
  Protected acCoreParkingMin2.i = 100
  Protected dcCoreParkingMin2.i = 25

  If schemeGuid$ = ""
    ProcedureReturn #False
  EndIf

  ; Core parking differs by profile. Battery can park aggressively when deep
  ; idle saver is enabled; Maximum keeps cores awake for responsiveness.
  If *plan\Name = #PlanBattery$
    If gSettings\DeepIdleSaver
      acCoreParkingMin = 0
      dcCoreParkingMin = 0
      acCoreParkingMin1 = 0
      dcCoreParkingMin1 = 0
      acCoreParkingMin2 = 0
      dcCoreParkingMin2 = 0
    Else
      acCoreParkingMin = 50
      dcCoreParkingMin = 10
      acCoreParkingMin1 = 50
      dcCoreParkingMin1 = 10
      acCoreParkingMin2 = 50
      dcCoreParkingMin2 = 10
    EndIf
  ElseIf *plan\Name = #PlanBalanced$
    acCoreParkingMin1 = 0
    dcCoreParkingMin1 = 0
    acCoreParkingMin2 = 0
    dcCoreParkingMin2 = 0
  ElseIf *plan\Name = #PlanFull$
    acMinState = 20
    dcMinState = 10
    dcCoreParkingMin = 100
    dcCoreParkingMin1 = 100
    dcCoreParkingMin2 = 100
  EndIf

  ; AC values.
  SetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PERFEPP", *plan\AcEpp)
  TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PERFEPP1", *plan\AcEpp)
  TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PERFEPP2", *plan\AcEpp)
  SetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PERFBOOSTMODE", *plan\AcBoostMode)
  SetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PROCTHROTTLEMAX", *plan\AcMaxState)
  TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PROCTHROTTLEMAX1", *plan\AcMaxState)
  TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PROCTHROTTLEMAX2", *plan\AcMaxState)
  TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PROCTHROTTLEMIN", acMinState)
  TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "CPMINCORES", acCoreParkingMin)
  TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "CPMINCORES1", acCoreParkingMin1)
  TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "CPMINCORES2", acCoreParkingMin2)
  SetFrequencyCaps(schemeGuid$, #True, *plan\AcFreqMHz)
  SetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "SYSCOOLPOL", *plan\AcCooling)

  ; DC values.
  SetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "PERFEPP", *plan\DcEpp)
  TrySetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "PERFEPP1", *plan\DcEpp)
  TrySetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "PERFEPP2", *plan\DcEpp)
  SetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "PERFBOOSTMODE", *plan\DcBoostMode)
  SetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "PROCTHROTTLEMAX", *plan\DcMaxState)
  TrySetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "PROCTHROTTLEMAX1", *plan\DcMaxState)
  TrySetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "PROCTHROTTLEMAX2", *plan\DcMaxState)
  TrySetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "PROCTHROTTLEMIN", dcMinState)
  TrySetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "CPMINCORES", dcCoreParkingMin)
  TrySetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "CPMINCORES1", dcCoreParkingMin1)
  TrySetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "CPMINCORES2", dcCoreParkingMin2)
  SetFrequencyCaps(schemeGuid$, #False, *plan\DcFreqMHz)
  SetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "SYSCOOLPOL", *plan\DcCooling)
  ConfigureBatterySleepFloor(schemeGuid$)

  ; Profile-specific hidden boost/ramp tuning. These calls are optional because
  ; many firmware packages hide or omit some aliases.
  If *plan\Name = #PlanBattery$
    TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "IDLEDISABLE", 0)
    TrySetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "IDLEDISABLE", 0)
    TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PERFBOOSTPOL", 0)
    TrySetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "PERFBOOSTPOL", 0)
    TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PERFINCTHRESHOLD", 80)
    TrySetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "PERFINCTHRESHOLD", 90)
    TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PERFINCTHRESHOLD1", 80)
    TrySetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "PERFINCTHRESHOLD1", 90)
    TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PERFDECTHRESHOLD", 20)
    TrySetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "PERFDECTHRESHOLD", 10)
    TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PERFDECTHRESHOLD1", 20)
    TrySetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "PERFDECTHRESHOLD1", 10)
    TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PERFINCTIME", 3)
    TrySetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "PERFINCTIME", 4)
    TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PERFINCTIME1", 3)
    TrySetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "PERFINCTIME1", 4)
    TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PERFDECTIME", 1)
    TrySetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "PERFDECTIME", 1)
    TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PERFDECTIME1", 1)
    TrySetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "PERFDECTIME1", 1)
  ElseIf *plan\Name = #PlanBalanced$
    TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "IDLEDISABLE", 0)
    TrySetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "IDLEDISABLE", 0)
    TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PERFBOOSTPOL", 60)
    TrySetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "PERFBOOSTPOL", 40)
    TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PERFBOOSTPOL1", 60)
    TrySetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "PERFBOOSTPOL1", 40)
    TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PERFINCTHRESHOLD", 30)
    TrySetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "PERFINCTHRESHOLD", 90)
    TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PERFINCTHRESHOLD1", 30)
    TrySetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "PERFINCTHRESHOLD1", 90)
    TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PERFDECTHRESHOLD", 10)
    TrySetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "PERFDECTHRESHOLD", 30)
    TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PERFDECTHRESHOLD1", 10)
    TrySetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "PERFDECTHRESHOLD1", 30)
    TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PERFINCTIME", 1)
    TrySetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "PERFINCTIME", 1)
    TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PERFINCTIME1", 1)
    TrySetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "PERFINCTIME1", 1)
    TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PERFDECTIME", 1)
    TrySetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "PERFDECTIME", 1)
    TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PERFDECTIME1", 1)
    TrySetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "PERFDECTIME1", 1)
  ElseIf *plan\Name = #PlanFull$
    TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "IDLEDISABLE", 0)
    TrySetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "IDLEDISABLE", 0)
    TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PERFBOOSTPOL", 100)
    TrySetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "PERFBOOSTPOL", 80)
    TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PERFBOOSTPOL1", 100)
    TrySetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "PERFBOOSTPOL1", 80)
    TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PERFINCTHRESHOLD", 10)
    TrySetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "PERFINCTHRESHOLD", 20)
    TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PERFINCTHRESHOLD1", 10)
    TrySetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "PERFINCTHRESHOLD1", 20)
    TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PERFDECTHRESHOLD", 5)
    TrySetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "PERFDECTHRESHOLD", 10)
    TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PERFDECTHRESHOLD1", 5)
    TrySetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "PERFDECTHRESHOLD1", 10)
    TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PERFINCTIME", 1)
    TrySetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "PERFINCTIME", 1)
    TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PERFINCTIME1", 1)
    TrySetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "PERFINCTIME1", 1)
    TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PERFDECTIME", 3)
    TrySetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "PERFDECTIME", 2)
    TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PERFDECTIME1", 3)
    TrySetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "PERFDECTIME1", 2)
  EndIf

  ProcedureReturn #True
EndProcedure

; Duplicate the selected base Windows plan, then rename it into a PowerPilot
; fixed plan. This preserves OEM hidden defaults where possible.
Procedure.s DuplicateBaseScheme(baseGuid$, planName$, description$)
  Protected output$
  Protected newGuid$
  If baseGuid$ = ""
    baseGuid$ = "SCHEME_BALANCED"
  EndIf
  output$ = RunPowerCfgCapture("/DUPLICATESCHEME " + baseGuid$)
  newGuid$ = FindGuidInText(output$)
  If newGuid$ <> ""
    RunPowerCfg("/CHANGENAME " + newGuid$ + " " + QuoteArgument(planName$) + " " + QuoteArgument(description$))
    InvalidateSchemeCache()
  EndIf
  ProcedureReturn newGuid$
EndProcedure

; Create a missing plan or refresh an existing fixed plan in place.
Procedure.i EnsurePlanInstalled(index.i, baseGuid$)
  Protected guid$ = GetSchemeGuidByName(gPlans(index)\Name)
  If guid$ = ""
    guid$ = DuplicateBaseScheme(baseGuid$, gPlans(index)\Name, gPlans(index)\Description)
  EndIf
  If guid$ = ""
    ProcedureReturn #False
  EndIf
  ProcedureReturn ConfigureScheme(@gPlans(index), guid$)
EndProcedure

; Delete only PowerPilot-owned and old prototype-owned plans.
Procedure DeleteManagedPlanCopies()
  Protected output$ = ReplaceString(RunPowerCfgCapture("/L"), #CR$, "")
  Protected line$
  Protected name$
  Protected guid$
  Protected i.i

  For i = 1 To CountString(output$, #LF$) + 1
    line$ = StringField(output$, i, #LF$)
    guid$ = FindGuidInText(line$)
    name$ = SchemeNameFromPowerCfgLine(line$)
    If guid$ <> "" And IsManagedPlanName(name$)
      RunPowerCfg("/DELETE " + guid$)
    EndIf
  Next
  InvalidateSchemeCache()
EndProcedure

; Create or refresh the three fixed plans from a chosen base. During force
; rebase, switch away from any managed plan before deleting old copies.
Procedure.i CreateManagedPlansFromBase(baseGuid$, forceRebase.i = #False)
  Protected baseName$ = GetSchemeNameByGuid(baseGuid$, #True)
  Protected activeGuid$
  Protected activeName$
  Protected i.i

  If baseGuid$ = "" Or IsManagedPlanName(baseName$)
    baseGuid$ = "SCHEME_BALANCED"
  EndIf

  If forceRebase
    activeGuid$ = GetActiveSchemeGuid()
    activeName$ = GetSchemeNameByGuid(activeGuid$, #True)
    If IsManagedPlanName(activeName$)
      RunPowerCfg("/SETACTIVE " + baseGuid$)
      gCachedActiveGuid$ = ""
      gCachedActiveName$ = ""
      gLastObservedActiveGuid$ = ""
    EndIf
    DeleteManagedPlanCopies()
  EndIf

  For i = 0 To 2
    If EnsurePlanInstalled(i, baseGuid$) = #False
      LogAction("Failed to create or refresh " + gPlans(i)\Name + ".")
      ProcedureReturn #False
    EndIf
  Next
  RefreshSchemeCache()
  LogAction("PowerPilot plans refreshed from the selected Windows plan.")
  ProcedureReturn #True
EndProcedure

Procedure.i CreateManagedPlans()
  ProcedureReturn CreateManagedPlansFromBase(GetActiveSchemeGuid(), #True)
EndProcedure

; Fast installer/update check: if all three plans exist, avoid recreating them.
Procedure.i ManagedPlansInstalled()
  Protected i.i
  RefreshSchemeCache()
  For i = 0 To 2
    If GetSchemeGuidByName(gPlans(i)\Name) = ""
      ProcedureReturn #False
    EndIf
  Next
  ProcedureReturn #True
EndProcedure

; Reapply only the Windows battery sleep floor to existing managed plans. This
; keeps Min percent changes quick while avoiding a full processor-plan rewrite.
Procedure.i ApplyBatterySleepFloorToManagedPlans()
  Protected i.i
  Protected guid$
  Protected changed.i
  For i = 0 To 2
    guid$ = GetSchemeGuidByName(gPlans(i)\Name)
    If guid$ <> ""
      If ConfigureBatterySleepFloor(guid$)
        changed + 1
      EndIf
    EndIf
  Next
  ProcedureReturn changed
EndProcedure

; Installer entry point. Keep the app registered for startup and repair missing
; plans, but do not recreate existing plans on every update.
Procedure.i InstallRefresh()
  gSettings\AutoStartWithApp = #True
  SaveSettings()
  SetStartupRegistry(#True)
  If ManagedPlansInstalled() = #False
    ProcedureReturn CreateManagedPlansFromBase(GetActiveSchemeGuid(), #False)
  EndIf
  ApplyBatterySleepFloorToManagedPlans()
  ProcedureReturn #True
EndProcedure

; Uninstall/cleanup path. If a managed plan is active, switch to Balanced before
; deleting owned plans.
Procedure.i CleanupManagedPlans()
  Protected output$ = ReplaceString(RunPowerCfgCapture("/L"), #CR$, "")
  Protected line$
  Protected name$
  Protected guid$
  Protected activeGuid$ = GetActiveSchemeGuid()
  Protected active$ = GetSchemeNameByGuid(activeGuid$, #True)
  Protected i.i

  If IsManagedPlanName(active$)
    RunPowerCfg("/SETACTIVE SCHEME_BALANCED")
    gCachedActiveGuid$ = ""
    gCachedActiveName$ = ""
  EndIf

  For i = 1 To CountString(output$, #LF$) + 1
    line$ = StringField(output$, i, #LF$)
    guid$ = FindGuidInText(line$)
    If guid$ <> ""
      name$ = SchemeNameFromPowerCfgLine(line$)
      If IsManagedPlanName(name$)
        RunPowerCfg("/DELETE " + guid$)
      EndIf
    EndIf
  Next

  InvalidateSchemeCache()
  LogAction("Managed PowerPilot and legacy Codex plans removed.")
  ProcedureReturn #True
EndProcedure

; Activate a fixed PowerPilot plan, recreating missing managed plans if needed.
Procedure.i ActivatePlanByName(planName$)
  Protected guid$ = GetSchemeGuidByName(planName$)
  If guid$ = ""
    CreateManagedPlans()
    guid$ = GetSchemeGuidByName(planName$)
  EndIf
  If guid$ = ""
    LogAction("Plan is not installed: " + planName$)
    ProcedureReturn #False
  EndIf
  If RunPowerCfg("/SETACTIVE " + guid$) = 0
    gSettings\LastPlan = NormalizePlanName(planName$)
    SaveSettings()
    gCachedActiveGuid$ = ""
    gCachedActiveName$ = ""
    LogAction(planName$ + " activated.")
    ProcedureReturn #True
  EndIf
  LogAction("Failed to activate " + planName$ + ".")
  ProcedureReturn #False
EndProcedure

; UI helpers.
Procedure.i MainWindowVisible()
  If IsWindow(#WindowMain) = #False
    ProcedureReturn #False
  EndIf
  ProcedureReturn Bool(IsWindowVisible_(WindowID(#WindowMain)) <> 0)
EndProcedure

Procedure SetGadgetTextIfChanged(gadget.i, text$)
  If IsGadget(gadget) And GetGadgetText(gadget) <> text$
    SetGadgetText(gadget, text$)
  EndIf
EndProcedure

Procedure EnsureUiFonts()
  If gFontUi = 0
    gFontUi = LoadFont(#PB_Any, "Segoe UI", 8)
  EndIf
  If gFontBold = 0
    gFontBold = LoadFont(#PB_Any, "Segoe UI", 8, #PB_Font_Bold)
  EndIf
  If gFontUi
    SetGadgetFont(#PB_Default, FontID(gFontUi))
  EndIf
EndProcedure

Procedure UseBoldFont(gadget.i)
  If IsGadget(gadget) And gFontBold
    SetGadgetFont(gadget, FontID(gFontBold))
  EndIf
EndProcedure

; Minimal x64 CPUID wrapper. RBX is preserved because it is nonvolatile on
; Windows x64 and PureBasic expects it to survive inline assembly blocks.
Procedure Cpuid(leaf.i, subleaf.i, *regs.CpuidRegs)
  Protected eax.q
  Protected ebx.q
  Protected ecx.q
  Protected edx.q
  Protected saveRbx.q

  !MOV [p.v_saveRbx], rbx
  !MOV eax, [p.v_leaf]
  !MOV ecx, [p.v_subleaf]
  !CPUID
  !MOV [p.v_eax], rax
  !MOV [p.v_ebx], rbx
  !MOV [p.v_ecx], rcx
  !MOV [p.v_edx], rdx
  !MOV rbx, [p.v_saveRbx]

  *regs\Eax = eax & $FFFFFFFF
  *regs\Ebx = ebx & $FFFFFFFF
  *regs\Ecx = ecx & $FFFFFFFF
  *regs\Edx = edx & $FFFFFFFF
EndProcedure

; XCR0 tells us whether the OS has enabled AVX/AVX-512 register state.
Procedure.q XGetBv0()
  Protected value.q
  !XOR rcx, rcx
  !XGETBV
  !MOV [p.v_value], rax
  ProcedureReturn value
EndProcedure

Procedure.i HasBit(value.q, bit.i)
  Protected mask.q = 1
  mask << bit
  ProcedureReturn Bool((value & mask) <> 0)
EndProcedure

; CPUID leaf 0 vendor string.
Procedure.s CpuVendor()
  Protected regs.CpuidRegs
  Protected *buf = AllocateMemory(13)
  Protected vendor$
  Cpuid(0, 0, @regs)
  If *buf
    PokeL(*buf + 0, regs\Ebx)
    PokeL(*buf + 4, regs\Edx)
    PokeL(*buf + 8, regs\Ecx)
    PokeB(*buf + 12, 0)
    vendor$ = PeekS(*buf, -1, #PB_Ascii)
    FreeMemory(*buf)
  EndIf
  ProcedureReturn vendor$
EndProcedure

; CPUID extended brand string.
Procedure.s CpuBrand()
  Protected maxExt.q
  Protected regs.CpuidRegs
  Protected *buf = AllocateMemory(49)
  Protected brand$
  Protected leaf.i
  Cpuid($80000000, 0, @regs)
  maxExt = regs\Eax
  If maxExt >= $80000004 And *buf
    For leaf = $80000002 To $80000004
      Cpuid(leaf, 0, @regs)
      PokeL(*buf + ((leaf - $80000002) * 16) + 0, regs\Eax)
      PokeL(*buf + ((leaf - $80000002) * 16) + 4, regs\Ebx)
      PokeL(*buf + ((leaf - $80000002) * 16) + 8, regs\Ecx)
      PokeL(*buf + ((leaf - $80000002) * 16) + 12, regs\Edx)
    Next
    PokeB(*buf + 48, 0)
    brand$ = Trim(PeekS(*buf, -1, #PB_Ascii))
    FreeMemory(*buf)
  EndIf
  If brand$ = ""
    brand$ = "Unknown CPU"
  EndIf
  ProcedureReturn brand$
EndProcedure

; Decode family/model/stepping using Intel/AMD CPUID rules.
Procedure.s CpuFamilyModelText()
  Protected regs.CpuidRegs
  Protected stepping.i
  Protected baseModel.i
  Protected baseFamily.i
  Protected extModel.i
  Protected extFamily.i
  Protected family.i
  Protected model.i
  Cpuid(1, 0, @regs)
  stepping = regs\Eax & $F
  baseModel = (regs\Eax >> 4) & $F
  baseFamily = (regs\Eax >> 8) & $F
  extModel = (regs\Eax >> 16) & $F
  extFamily = (regs\Eax >> 20) & $FF
  family = baseFamily
  If baseFamily = $F
    family + extFamily
  EndIf
  model = baseModel
  If baseFamily = $6 Or baseFamily = $F
    model + (extModel << 4)
  EndIf
  ProcedureReturn "Family " + Str(family) + ", model " + Str(model) + ", stepping " + Str(stepping)
EndProcedure

; Prefer modern topology leaves; fall back to AMD extended core count and then
; PureBasic's logical processor count.
Procedure.s CpuTopologyText()
  Protected regs.CpuidRegs
  Protected maxBasic.q
  Protected maxExt.q
  Protected leaf.i
  Protected level.i
  Protected domainType.i
  Protected smtLogical.i = 0
  Protected packageLogical.i = 0
  Protected cores.i = 0
  Protected logical.i = CountCPUs()

  Cpuid(0, 0, @regs)
  maxBasic = regs\Eax
  If maxBasic >= $1F
    leaf = $1F
  ElseIf maxBasic >= $0B
    leaf = $0B
  EndIf

  If leaf
    For level = 0 To 7
      Cpuid(leaf, level, @regs)
      If regs\Ebx = 0
        Break
      EndIf
      domainType = (regs\Ecx >> 8) & $FF
      If domainType = 1
        smtLogical = regs\Ebx & $FFFF
      ElseIf domainType = 2
        packageLogical = regs\Ebx & $FFFF
      EndIf
    Next
    If smtLogical > 0 And packageLogical >= smtLogical
      cores = packageLogical / smtLogical
    EndIf
  EndIf

  If cores = 0
    Cpuid($80000000, 0, @regs)
    maxExt = regs\Eax
    If maxExt >= $80000008
      Cpuid($80000008, 0, @regs)
      cores = (regs\Ecx & $FF) + 1
    EndIf
  EndIf

  If cores > 0
    ProcedureReturn Str(cores) + " cores / " + Str(logical) + " logical processors"
  EndIf
  ProcedureReturn Str(logical) + " logical processors"
EndProcedure

Procedure.s AddFeature(text$, label$)
  If text$ <> ""
    text$ + ", "
  EndIf
  ProcedureReturn text$ + label$
EndProcedure

; Build a compact feature summary. AVX/AVX-512 are reported only when both CPU
; support and OS xstate support are present.
Procedure.s CpuFeatureText()
  Protected r1.CpuidRegs
  Protected r7.CpuidRegs
  Protected re.CpuidRegs
  Protected maxBasic.q
  Protected maxExt.q
  Protected xcr0.q
  Protected features$
  Protected avxUsable.i
  Protected avx512Usable.i
  Protected bmi1.i
  Protected bmi2.i

  Cpuid(0, 0, @r7)
  maxBasic = r7\Eax
  Cpuid(1, 0, @r1)
  If HasBit(r1\Ecx, 27)
    xcr0 = XGetBv0()
    avxUsable = Bool((xcr0 & $6) = $6)
    avx512Usable = Bool((xcr0 & $E6) = $E6)
  EndIf

  If HasBit(r1\Ecx, 20)
    features$ = AddFeature(features$, "SSE-SSE4.2")
  Else
    If HasBit(r1\Edx, 25) : features$ = AddFeature(features$, "SSE") : EndIf
    If HasBit(r1\Edx, 26) : features$ = AddFeature(features$, "SSE2") : EndIf
    If HasBit(r1\Ecx, 0) : features$ = AddFeature(features$, "SSE3") : EndIf
    If HasBit(r1\Ecx, 9) : features$ = AddFeature(features$, "SSSE3") : EndIf
    If HasBit(r1\Ecx, 19) : features$ = AddFeature(features$, "SSE4.1") : EndIf
  EndIf
  If HasBit(r1\Ecx, 25) : features$ = AddFeature(features$, "AES") : EndIf
  If HasBit(r1\Ecx, 12) : features$ = AddFeature(features$, "FMA") : EndIf
  If HasBit(r1\Ecx, 23) : features$ = AddFeature(features$, "POPCNT") : EndIf
  If HasBit(r1\Ecx, 28) And avxUsable : features$ = AddFeature(features$, "AVX") : EndIf

  If maxBasic >= 7
    Cpuid(7, 0, @r7)
    bmi1 = HasBit(r7\Ebx, 3)
    bmi2 = HasBit(r7\Ebx, 8)
    If bmi1 And bmi2
      features$ = AddFeature(features$, "BMI1/2")
    ElseIf bmi1
      features$ = AddFeature(features$, "BMI1")
    ElseIf bmi2
      features$ = AddFeature(features$, "BMI2")
    EndIf
    If HasBit(r7\Ebx, 5) And avxUsable : features$ = AddFeature(features$, "AVX2") : EndIf
    If HasBit(r7\Ebx, 18) : features$ = AddFeature(features$, "RDSEED") : EndIf
    If HasBit(r7\Ebx, 29) : features$ = AddFeature(features$, "SHA") : EndIf
    If HasBit(r7\Ebx, 16) And avx512Usable : features$ = AddFeature(features$, "AVX-512F") : EndIf
    If HasBit(r7\Ecx, 5) : features$ = AddFeature(features$, "WAITPKG") : EndIf
  EndIf

  Cpuid($80000000, 0, @re)
  maxExt = re\Eax
  If maxExt >= $80000001
    Cpuid($80000001, 0, @re)
    If HasBit(re\Edx, 29) : features$ = AddFeature(features$, "x64") : EndIf
    If HasBit(re\Edx, 27) : features$ = AddFeature(features$, "RDTSCP") : EndIf
    If HasBit(re\Edx, 26) : features$ = AddFeature(features$, "1GB pg") : EndIf
    If HasBit(re\Ecx, 2) : features$ = AddFeature(features$, "SVM") : EndIf
  EndIf
  If HasBit(r1\Ecx, 5) : features$ = AddFeature(features$, "VMX") : EndIf
  If features$ = "" : features$ = "No CPUID feature summary available" : EndIf
  ProcedureReturn features$
EndProcedure

Procedure.s FormatBytes(bytes.q)
  Protected gb.d = bytes / 1073741824.0
  If gb >= 1.0
    ProcedureReturn StrD(gb, 1) + " GB"
  EndIf
  ProcedureReturn Str(bytes) + " bytes"
EndProcedure

Procedure.s SystemMemoryText()
  Protected memory.MEMORYSTATUSEX
  memory\dwLength = SizeOf(MEMORYSTATUSEX)
  If GlobalMemoryStatusEx_(@memory)
    ProcedureReturn FormatBytes(memory\ullTotalPhys) + " RAM"
  EndIf
  ProcedureReturn "RAM unavailable"
EndProcedure

Procedure.s FormatCacheSize(bytes.q)
  If bytes >= 1048576
    ProcedureReturn StrD(bytes / 1048576.0, 1) + " MB"
  EndIf
  ProcedureReturn Str(bytes / 1024) + " KB"
EndProcedure

; Deterministic cache parameters are available through leaf 4 on Intel and
; 8000001D on many AMD CPUs.
Procedure.s CpuCacheText()
  Protected regs.CpuidRegs
  Protected maxBasic.q
  Protected maxExt.q
  Protected vendor$ = CpuVendor()
  Protected leaf.i
  Protected sub.i
  Protected cacheType.i
  Protected level.i
  Protected lineSize.q
  Protected partitions.q
  Protected ways.q
  Protected sets.q
  Protected size.q
  Protected text$

  Cpuid(0, 0, @regs)
  maxBasic = regs\Eax
  Cpuid($80000000, 0, @regs)
  maxExt = regs\Eax

  If FindString(vendor$, "AuthenticAMD", 1) And maxExt >= $8000001D
    leaf = $8000001D
  ElseIf maxBasic >= 4
    leaf = 4
  EndIf
  If leaf = 0
    ProcedureReturn "Cache details unavailable"
  EndIf

  For sub = 0 To 15
    Cpuid(leaf, sub, @regs)
    cacheType = regs\Eax & $1F
    If cacheType = 0
      Break
    EndIf
    level = (regs\Eax >> 5) & $7
    lineSize = (regs\Ebx & $FFF) + 1
    partitions = ((regs\Ebx >> 12) & $3FF) + 1
    ways = ((regs\Ebx >> 22) & $3FF) + 1
    sets = regs\Ecx + 1
    size = lineSize * partitions * ways * sets
    If text$ <> "" : text$ + ", " : EndIf
    text$ + "L" + Str(level) + " " + FormatCacheSize(size)
  Next

  If text$ = "" : text$ = "Cache details unavailable" : EndIf
  ProcedureReturn text$
EndProcedure

; Compose the multi-line CPU/Memory text shown on the Overview tab.
Procedure.s BuildCpuInfo()
  Protected text$
  text$ = CpuBrand()
  text$ + #LF$ + CpuVendor() + " | " + CpuFamilyModelText()
  text$ + #LF$ + CpuTopologyText()
  text$ + #LF$ + "Cache: " + CpuCacheText() + " | " + SystemMemoryText()
  text$ + #LF$ + "Features: " + CpuFeatureText()
  ProcedureReturn text$
EndProcedure

; Normalize CPU names so GPU inference can match model families reliably.
Procedure.s BuildCpuMatchText(cpuName$)
  Protected cleaned$ = LCase(Trim(cpuName$))
  If cleaned$ = ""
    ProcedureReturn ""
  EndIf

  cleaned$ = ReplaceString(cleaned$, "-", " ")
  cleaned$ = ReplaceString(cleaned$, "/", " ")
  cleaned$ = ReplaceString(cleaned$, ",", " ")
  cleaned$ = ReplaceString(cleaned$, "(", " ")
  cleaned$ = ReplaceString(cleaned$, ")", " ")
  cleaned$ = ReplaceString(cleaned$, "[", " ")
  cleaned$ = ReplaceString(cleaned$, "]", " ")
  cleaned$ = ReplaceString(cleaned$, "+", " ")
  While FindString(cleaned$, "  ", 1)
    cleaned$ = ReplaceString(cleaned$, "  ", " ")
  Wend
  ProcedureReturn " " + Trim(cleaned$) + " "
EndProcedure

; Match a normalized CPU token string against a comma-separated pattern list.
Procedure.i CpuMatchAny(cpuMatchText$, patternList$)
  Protected itemCount.i = CountString(patternList$, ",") + 1
  Protected i.i
  Protected pattern$
  For i = 1 To itemCount
    pattern$ = Trim(StringField(patternList$, i, ","))
    If pattern$ <> "" And FindString(cpuMatchText$, " " + LCase(pattern$) + " ", 1)
      ProcedureReturn #True
    EndIf
  Next
  ProcedureReturn #False
EndProcedure

; Windows often reports AMD iGPUs generically. If so, infer a more useful CU
; count from the CPU family below.
Procedure.i IsGenericAmdIntegratedGpuName(hardwareName$)
  Protected lowered$ = LCase(Trim(hardwareName$))
  ProcedureReturn Bool(lowered$ = "amd radeon graphics" Or lowered$ = "radeon graphics" Or lowered$ = "amd radeon(tm) graphics" Or lowered$ = "radeon(tm) graphics")
EndProcedure

; Generic AMD Radeon Graphics plus CU count fallback.
Procedure.s ResolveAmdGraphicsCuName(cuCount.i)
  If cuCount <= 0
    ProcedureReturn "AMD Radeon Graphics"
  EndIf
  ProcedureReturn "AMD Radeon Graphics (" + Str(cuCount) + " CUs)"
EndProcedure

; CPU-family lookup table for AMD integrated GPU marketing names. This is only
; used when Windows reports a generic "AMD Radeon Graphics" display name.
Procedure.s ResolveAmdIntegratedGpuName(cpuName$)
  Protected cpuMatchText$ = BuildCpuMatchText(cpuName$)
  If cpuMatchText$ = "" Or FindString(cpuMatchText$, " amd ", 1) = 0
    ProcedureReturn ""
  EndIf

  If CpuMatchAny(cpuMatchText$, "ryzen ai 9 hx 370,ryzen ai 9 hx pro 370,ryzen ai 9 hx 375,ryzen ai 9 hx pro 375")
    ProcedureReturn "AMD Radeon 890M"
  EndIf
  If CpuMatchAny(cpuMatchText$, "ryzen ai 9 365,ryzen ai 7 360,ryzen ai 7 pro 360")
    ProcedureReturn "AMD Radeon 880M"
  EndIf
  If CpuMatchAny(cpuMatchText$, "ryzen ai 7 350,ryzen ai 7 pro 350")
    ProcedureReturn "AMD Radeon 860M"
  EndIf
  If CpuMatchAny(cpuMatchText$, "ryzen ai 5 340,ryzen ai 5 pro 340")
    ProcedureReturn "AMD Radeon 840M"
  EndIf
  If CpuMatchAny(cpuMatchText$, "ryzen ai max 395,ryzen ai max pro 395")
    ProcedureReturn "AMD Radeon 8060S Graphics"
  EndIf
  If CpuMatchAny(cpuMatchText$, "ryzen ai max 390,ryzen ai max 385,ryzen ai max pro 390,ryzen ai max pro 385")
    ProcedureReturn "AMD Radeon 8050S Graphics"
  EndIf
  If CpuMatchAny(cpuMatchText$, "ryzen ai max pro 380")
    ProcedureReturn "AMD Radeon 8040S Graphics"
  EndIf
  If CpuMatchAny(cpuMatchText$, "ryzen z1 extreme,7840u,7840hs,7940hs,8700g,8700ge,8945hs,8840u,8840hs,8845hs")
    ProcedureReturn "AMD Radeon 780M"
  EndIf
  If CpuMatchAny(cpuMatchText$, "7640u,7640hs,8600g,8600ge,8540u,8540hs,8640u,8640hs")
    ProcedureReturn "AMD Radeon 760M"
  EndIf
  If CpuMatchAny(cpuMatchText$, "ryzen z1,7440u,7440hs,7540u,7540hs,8300g,8305g,8440u,8440hs,8500g")
    ProcedureReturn "AMD Radeon 740M"
  EndIf
  If CpuMatchAny(cpuMatchText$, "7120u,7220u,7320u,7520u")
    ProcedureReturn "AMD Radeon 610M"
  EndIf
  If CpuMatchAny(cpuMatchText$, "6600u,6600h,6600hs,6650u,6650h,6650hs,7335u,7535u,7535hs")
    ProcedureReturn "AMD Radeon 660M"
  EndIf
  If CpuMatchAny(cpuMatchText$, "6800u,6800h,6800hs,6850u,6850h,6850hs,6860z,6900hs,6900hx,6980hs,6980hx,7735u,7735hs,7736u")
    ProcedureReturn "AMD Radeon 680M"
  EndIf
  If CpuMatchAny(cpuMatchText$, "2200g,2500u,3200g,3500u,3550h")
    ProcedureReturn "AMD Radeon Vega 8 Graphics"
  EndIf
  If CpuMatchAny(cpuMatchText$, "2300u")
    ProcedureReturn "AMD Radeon Vega 6 Graphics"
  EndIf
  If CpuMatchAny(cpuMatchText$, "3200u,3250u,300u")
    ProcedureReturn "AMD Radeon Vega 3 Graphics"
  EndIf
  If CpuMatchAny(cpuMatchText$, "2400g,3400g")
    ProcedureReturn "AMD Radeon RX Vega 11 Graphics"
  EndIf
  If CpuMatchAny(cpuMatchText$, "2700u,3700u,3750h")
    ProcedureReturn "AMD Radeon RX Vega 10 Graphics"
  EndIf
  If CpuMatchAny(cpuMatchText$, "4300u,4450u")
    ProcedureReturn ResolveAmdGraphicsCuName(5)
  EndIf
  If CpuMatchAny(cpuMatchText$, "4350g,4350ge,4500u,4600u,4600h,4600hs,4650u,5300u,5355g,5355ge,5400u,7330u")
    ProcedureReturn ResolveAmdGraphicsCuName(6)
  EndIf
  If CpuMatchAny(cpuMatchText$, "4650g,4700u,4700h,4700hs,4750u,5500u,5500h,5600u,5600h,5600hs,5600g,5625u,5650u,7430u,7530u")
    ProcedureReturn ResolveAmdGraphicsCuName(7)
  EndIf
  If CpuMatchAny(cpuMatchText$, "4750g,4750ge,4800u,4800h,4800hs,4900h,4900hs,5700u,5700g,5800u,5800h,5800hs,5825u,5850u,5875u,5900hs,5900hx,5980hs,5980hx,7730u")
    ProcedureReturn ResolveAmdGraphicsCuName(8)
  EndIf
  ProcedureReturn ""
EndProcedure

Procedure.s CpuInferredIntegratedGpuName()
  ProcedureReturn ResolveAmdIntegratedGpuName(CpuBrand())
EndProcedure

; Clean Windows display adapter names and replace generic AMD iGPU names when a
; CPU-family inference is available.
Procedure.s NormalizeGpuHardwareName(hardwareName$)
  Protected cleaned$ = Trim(hardwareName$)
  Protected resolved$
  If cleaned$ = ""
    ProcedureReturn ""
  EndIf

  cleaned$ = ReplaceString(cleaned$, #CR$, " ")
  cleaned$ = ReplaceString(cleaned$, #LF$, " ")
  cleaned$ = ReplaceString(cleaned$, "(TM)", "")
  cleaned$ = ReplaceString(cleaned$, "(R)", "")
  cleaned$ = ReplaceString(cleaned$, "Microsoft Corporation ", "")
  While FindString(cleaned$, "  ", 1)
    cleaned$ = ReplaceString(cleaned$, "  ", " ")
  Wend

  If IsGenericAmdIntegratedGpuName(cleaned$)
    resolved$ = CpuInferredIntegratedGpuName()
    If resolved$ <> ""
      cleaned$ = resolved$
    EndIf
  EndIf
  ProcedureReturn Trim(cleaned$)
EndProcedure

; Used to annotate likely integrated GPUs in the Overview tab.
Procedure.i IsLikelyIntegratedGpuName(name$)
  Protected lower$ = LCase(name$)
  ProcedureReturn Bool(FindString(lower$, "radeon 680m", 1) Or FindString(lower$, "radeon 660m", 1) Or FindString(lower$, "radeon 610m", 1) Or FindString(lower$, "radeon 740m", 1) Or FindString(lower$, "radeon 760m", 1) Or FindString(lower$, "radeon 780m", 1) Or FindString(lower$, "radeon 840m", 1) Or FindString(lower$, "radeon 860m", 1) Or FindString(lower$, "radeon 880m", 1) Or FindString(lower$, "radeon 890m", 1) Or FindString(lower$, "vega", 1) Or FindString(lower$, "uhd", 1) Or FindString(lower$, "iris", 1) Or FindString(lower$, "xe graphics", 1))
EndProcedure

; Vendor decoding from PCI vendor id fragments exposed by DISPLAY_DEVICE.
Procedure.s VendorNameFromPciId(id$)
  Protected upper$ = UCase(id$)
  If FindString(upper$, "VEN_1002", 1) Or FindString(upper$, "VEN_1022", 1)
    ProcedureReturn "AMD"
  EndIf
  If FindString(upper$, "VEN_10DE", 1)
    ProcedureReturn "NVIDIA"
  EndIf
  If FindString(upper$, "VEN_8086", 1)
    ProcedureReturn "Intel"
  EndIf
  ProcedureReturn "Unknown vendor"
EndProcedure

; Keep only VEN_xxxx and DEV_xxxx so GPU rows stay compact.
Procedure.s PciSummary(id$)
  Protected upper$ = UCase(id$)
  Protected ven.i = FindString(upper$, "VEN_", 1)
  Protected dev.i = FindString(upper$, "DEV_", 1)
  Protected text$
  If ven
    text$ = Mid(upper$, ven, 8)
  EndIf
  If dev
    If text$ <> "" : text$ + " " : EndIf
    text$ + Mid(upper$, dev, 8)
  EndIf
  ProcedureReturn text$
EndProcedure

; Filter out virtual/basic display adapters that add noise for users.
Procedure.i IsUsefulGpuName(name$)
  Protected lower$ = LCase(name$)
  If Trim(name$) = "" : ProcedureReturn #False : EndIf
  If FindString(lower$, "mirage", 1) : ProcedureReturn #False : EndIf
  If FindString(lower$, "remote display", 1) : ProcedureReturn #False : EndIf
  If FindString(lower$, "basic render", 1) : ProcedureReturn #False : EndIf
  ProcedureReturn #True
EndProcedure

; Enumerate Windows display adapters, normalize names, deduplicate, and include
; PCI/vendor/active/primary details where exposed.
Procedure.s BuildGpuInfo()
  Protected dd.DISPLAY_DEVICE
  Protected index.i
  Protected rawName$
  Protected name$
  Protected id$
  Protected pci$
  Protected vendor$
  Protected flags$
  Protected line$
  Protected key$
  Protected text$
  NewMap seenGpu.i()

  Repeat
    FillMemory(@dd, SizeOf(DISPLAY_DEVICE), 0)
    dd\cb = SizeOf(DISPLAY_DEVICE)
    If EnumDisplayDevices_(0, index, @dd, #EDD_GET_DEVICE_INTERFACE_NAME) = 0
      Break
    EndIf
    rawName$ = Trim(PeekS(@dd\DeviceString[0]))
    name$ = NormalizeGpuHardwareName(rawName$)
    id$ = Trim(PeekS(@dd\DeviceID[0]))
    key$ = LCase(name$)
    If IsUsefulGpuName(name$) And FindMapElement(seenGpu(), key$) = #False
      seenGpu(key$) = #True
      vendor$ = VendorNameFromPciId(id$)
      pci$ = PciSummary(id$)
      flags$ = ""
      If dd\StateFlags & 1 : flags$ = "active" : EndIf
      If dd\StateFlags & 4
        If flags$ <> "" : flags$ + ", " : EndIf
        flags$ + "primary"
      EndIf
      line$ = name$
      If IsLikelyIntegratedGpuName(name$)
        line$ + " [iGPU]"
      EndIf
      If vendor$ <> "Unknown vendor" And FindString(LCase(line$), LCase(vendor$), 1) = 0
        line$ + " (" + vendor$ + ")"
      EndIf
      If pci$ <> ""
        line$ + " - " + pci$
      EndIf
      If flags$ <> ""
        line$ + " [" + flags$ + "]"
      EndIf
      If text$ <> "" : text$ + #LF$ : EndIf
      text$ + line$
    EndIf
    index + 1
  ForEver

  If text$ = ""
    name$ = CpuInferredIntegratedGpuName()
    If name$ <> ""
      text$ = name$ + " [iGPU, CPU inferred]"
    Else
      text$ = "No display adapter names exposed by Windows."
    EndIf
  EndIf
  ProcedureReturn text$
EndProcedure

; CPU/GPU strings are cached because they are static and relatively expensive.
Procedure.s CpuInfo()
  If gCachedCpuInfo$ = ""
    gCachedCpuInfo$ = BuildCpuInfo()
  EndIf
  ProcedureReturn gCachedCpuInfo$
EndProcedure

Procedure.s GpuInfo()
  If gCachedGpuInfo$ = ""
    gCachedGpuInfo$ = BuildGpuInfo()
  EndIf
  ProcedureReturn gCachedGpuInfo$
EndProcedure

; Per-user startup registration. The installer is elevated, but the app startup
; entry must be HKCU so PowerPilot runs non-elevated for the local user.
Procedure.i SetStartupRegistry(enabled.i)
  Protected runKey$ = "HKCU\Software\Microsoft\Windows\CurrentVersion\Run"
  Protected dataArg$ = Chr(92) + Chr(34) + ProgramFilename() + Chr(92) + Chr(34) + " /tray"
  Protected args$
  If enabled
    args$ = "add " + QuoteArgument(runKey$) + " /v " + QuoteArgument(#AppRunKey$) + " /t REG_SZ /d " + QuoteArgument(dataArg$) + " /f"
  Else
    args$ = "delete " + QuoteArgument(runKey$) + " /v " + QuoteArgument(#AppRunKey$) + " /f"
  EndIf
  ProcedureReturn Bool(RunExitCode("reg.exe", args$) = 0)
EndProcedure

; Installer/uninstaller helper for removing user settings when requested.
Procedure.i CleanupSettingsData()
  SetStartupRegistry(#False)
  If FileSize(SettingsDirectory()) = -2
    ProcedureReturn DeleteDirectory(SettingsDirectory(), "", #PB_FileSystem_Recursive | #PB_FileSystem_Force)
  EndIf
  ProcedureReturn #True
EndProcedure

; Copy plan editor gadget values into the selected in-memory plan.
Procedure ReadPlanEditor()
  If gSelectedPlan < 0 Or gSelectedPlan > 2
    ProcedureReturn
  EndIf
  If IsGadget(#GadgetPlanSummary) : gPlans(gSelectedPlan)\Description = CleanPlanText(GetGadgetText(#GadgetPlanSummary)) : EndIf
  If IsGadget(#GadgetPlanAcEpp) : gPlans(gSelectedPlan)\AcEpp = GetGadgetState(#GadgetPlanAcEpp) : EndIf
  If IsGadget(#GadgetPlanDcEpp) : gPlans(gSelectedPlan)\DcEpp = GetGadgetState(#GadgetPlanDcEpp) : EndIf
  If IsGadget(#GadgetPlanAcBoost) : gPlans(gSelectedPlan)\AcBoostMode = GetGadgetState(#GadgetPlanAcBoost) : EndIf
  If IsGadget(#GadgetPlanDcBoost) : gPlans(gSelectedPlan)\DcBoostMode = GetGadgetState(#GadgetPlanDcBoost) : EndIf
  If IsGadget(#GadgetPlanAcState) : gPlans(gSelectedPlan)\AcMaxState = GetGadgetState(#GadgetPlanAcState) : EndIf
  If IsGadget(#GadgetPlanDcState) : gPlans(gSelectedPlan)\DcMaxState = GetGadgetState(#GadgetPlanDcState) : EndIf
  If IsGadget(#GadgetPlanAcFreq) : gPlans(gSelectedPlan)\AcFreqMHz = GetGadgetState(#GadgetPlanAcFreq) : EndIf
  If IsGadget(#GadgetPlanDcFreq) : gPlans(gSelectedPlan)\DcFreqMHz = GetGadgetState(#GadgetPlanDcFreq) : EndIf
  If IsGadget(#GadgetPlanAcCooling) : gPlans(gSelectedPlan)\AcCooling = GetGadgetState(#GadgetPlanAcCooling) : EndIf
  If IsGadget(#GadgetPlanDcCooling) : gPlans(gSelectedPlan)\DcCooling = GetGadgetState(#GadgetPlanDcCooling) : EndIf
  ClampPlanValues(@gPlans(gSelectedPlan))
EndProcedure

; Copy selected in-memory plan values into the editor gadgets.
Procedure RefreshPlanEditor()
  If gSelectedPlan < 0 Or gSelectedPlan > 2
    gSelectedPlan = 1
  EndIf
  SetGadgetText(#GadgetPlanSummary, gPlans(gSelectedPlan)\Description)
  SetGadgetState(#GadgetPlanAcEpp, gPlans(gSelectedPlan)\AcEpp)
  SetGadgetState(#GadgetPlanDcEpp, gPlans(gSelectedPlan)\DcEpp)
  SetGadgetState(#GadgetPlanAcBoost, gPlans(gSelectedPlan)\AcBoostMode)
  SetGadgetState(#GadgetPlanDcBoost, gPlans(gSelectedPlan)\DcBoostMode)
  SetGadgetState(#GadgetPlanAcState, gPlans(gSelectedPlan)\AcMaxState)
  SetGadgetState(#GadgetPlanDcState, gPlans(gSelectedPlan)\DcMaxState)
  SetGadgetState(#GadgetPlanAcFreq, gPlans(gSelectedPlan)\AcFreqMHz)
  SetGadgetState(#GadgetPlanDcFreq, gPlans(gSelectedPlan)\DcFreqMHz)
  SetGadgetState(#GadgetPlanAcCooling, gPlans(gSelectedPlan)\AcCooling)
  SetGadgetState(#GadgetPlanDcCooling, gPlans(gSelectedPlan)\DcCooling)
EndProcedure

; Refresh the fixed-plan list and whether each plan exists in Windows.
Procedure RefreshPlanList(force.i = #False)
  Protected i.i
  Protected installed$
  If force Or gSchemeCacheValid = #False
    RefreshSchemeCache()
  EndIf
  ClearGadgetItems(#GadgetPlanList)
  For i = 0 To 2
    installed$ = "No"
    If GetSchemeGuidByName(gPlans(i)\Name) <> ""
      installed$ = "Yes"
    EndIf
    AddGadgetItem(#GadgetPlanList, -1, gPlans(i)\Name + Chr(10) + installed$ + Chr(10) + gPlans(i)\Description)
  Next
  If gSelectedPlan < 0 Or gSelectedPlan > 2
    gSelectedPlan = PlanIndexByName(gSettings\LastPlan)
    If gSelectedPlan < 0 : gSelectedPlan = 1 : EndIf
  EndIf
  SetGadgetState(#GadgetPlanList, gSelectedPlan)
EndProcedure

; Save edited plan settings, creating a missing Windows plan if necessary.
Procedure SavePlanEditor()
  Protected guid$
  Protected baseGuid$
  Protected baseName$
  ReadPlanEditor()
  SaveSettings()
  guid$ = GetSchemeGuidByName(gPlans(gSelectedPlan)\Name)
  If guid$ <> ""
    RunPowerCfg("/CHANGENAME " + guid$ + " " + QuoteArgument(gPlans(gSelectedPlan)\Name) + " " + QuoteArgument(gPlans(gSelectedPlan)\Description))
    ConfigureScheme(@gPlans(gSelectedPlan), guid$)
    LogAction(gPlans(gSelectedPlan)\Name + " saved and applied to Windows.")
  Else
    baseGuid$ = GetActiveSchemeGuid()
    baseName$ = GetSchemeNameByGuid(baseGuid$, #True)
    If baseGuid$ = "" Or IsManagedPlanName(baseName$)
      baseGuid$ = "SCHEME_BALANCED"
    EndIf
    If EnsurePlanInstalled(gSelectedPlan, baseGuid$)
      RefreshSchemeCache()
      LogAction(gPlans(gSelectedPlan)\Name + " created, saved, and applied to Windows.")
    Else
      LogAction("Failed to create " + gPlans(gSelectedPlan)\Name + ".")
    EndIf
  EndIf
  RefreshPlanList(#True)
EndProcedure

; Restore one fixed plan to the current defaults and apply it if installed.
Procedure ResetSelectedPlan()
  Protected name$ = gPlans(gSelectedPlan)\Name
  Protected guid$
  LoadDefaultPlan(gSelectedPlan)
  SaveSettings()
  RefreshPlanEditor()
  guid$ = GetSchemeGuidByName(name$)
  If guid$ <> ""
    RunPowerCfg("/CHANGENAME " + guid$ + " " + QuoteArgument(gPlans(gSelectedPlan)\Name) + " " + QuoteArgument(gPlans(gSelectedPlan)\Description))
    ConfigureScheme(@gPlans(gSelectedPlan), guid$)
    LogAction(name$ + " reset to defaults and applied to Windows.")
  Else
    LogAction(name$ + " reset to defaults.")
  EndIf
  RefreshPlanList(#True)
EndProcedure

; Push loaded settings into Overview, PowerPilot Log, and Battery Stats controls.
Procedure ApplySettingsToGui()
  SetGadgetState(#GadgetAutoStart, Bool(gSettings\AutoStartWithApp))
  SetGadgetState(#GadgetKeepSettings, Bool(gSettings\KeepSettingsOnReinstall))
  SetGadgetState(#GadgetThrottleMaintenance, Bool(gSettings\ThrottleMaintenance))
  SetGadgetState(#GadgetDeepIdleSaver, Bool(gSettings\DeepIdleSaver))
  SetGadgetState(#GadgetShowToolTips, Bool(gSettings\ShowToolTips))
  If IsGadget(#GadgetBatteryLogEnabled) : SetGadgetState(#GadgetBatteryLogEnabled, Bool(gSettings\BatteryLogEnabled)) : EndIf
  If IsGadget(#GadgetBatteryLogMinutes) : SetGadgetState(#GadgetBatteryLogMinutes, ClampInt(gSettings\BatteryLogIntervalMinutes, 1, 1440)) : EndIf
  If IsGadget(#GadgetBatteryRefreshSeconds) : SetGadgetState(#GadgetBatteryRefreshSeconds, ClampInt(gSettings\BatteryRefreshSeconds, 5, 3600)) : EndIf
  If IsGadget(#GadgetBatteryMinPercent) : SetGadgetState(#GadgetBatteryMinPercent, ClampInt(gSettings\BatteryMinPercent, 1, 99)) : EndIf
  If IsGadget(#GadgetBatteryMaxPercent) : SetGadgetState(#GadgetBatteryMaxPercent, ClampInt(gSettings\BatteryMaxPercent, gSettings\BatteryMinPercent + 1, 100)) : EndIf
  If IsGadget(#GadgetBatteryLimiterEnabled) : SetGadgetState(#GadgetBatteryLimiterEnabled, Bool(gSettings\BatteryLimiterEnabled)) : EndIf
  If IsGadget(#GadgetBatteryLimiterMaxPercent) : SetGadgetState(#GadgetBatteryLimiterMaxPercent, ClampInt(gSettings\BatteryLimiterMaxPercent, gSettings\BatteryMinPercent + 1, 100)) : EndIf
  If IsGadget(#GadgetBatterySmoothingMinutes) : SetGadgetState(#GadgetBatterySmoothingMinutes, ClampInt(gSettings\BatterySmoothingMinutes, 5, 240)) : EndIf
  If IsGadget(#GadgetBatteryStartupDrain) : SetGadgetState(#GadgetBatteryStartupDrain, ClampInt(gSettings\BatteryStartupDrainPctPerHour, 1, 100)) : EndIf
  If IsGadget(#GadgetLogShowAverage) : SetGadgetState(#GadgetLogShowAverage, Bool(gSettings\BatteryLogShowAverage)) : EndIf
  If IsGadget(#GadgetLogShowInstant) : SetGadgetState(#GadgetLogShowInstant, Bool(gSettings\BatteryLogShowInstant)) : EndIf
  If IsGadget(#GadgetLogShowConnected) : SetGadgetState(#GadgetLogShowConnected, Bool(gSettings\BatteryLogShowConnected)) : EndIf
  If IsGadget(#GadgetLogShowEvents) : SetGadgetState(#GadgetLogShowEvents, Bool(gSettings\BatteryLogShowEvents)) : EndIf
  ApplyToolTips()
EndProcedure

; Read and persist PowerPilot Log/estimate settings from the GUI.
Procedure SaveBatterySettingsFromGui()
  Protected oldMinPercent.i = gSettings\BatteryMinPercent
  If gBatterySettingsApplyPending And IsWindow(#WindowMain)
    RemoveWindowTimer(#WindowMain, #TimerBatterySettingsApply)
  EndIf
  gBatterySettingsApplyPending = #False
  CaptureBatteryLogColumnWidths(#False)
  If IsGadget(#GadgetBatteryLogEnabled) : gSettings\BatteryLogEnabled = GetGadgetState(#GadgetBatteryLogEnabled) : EndIf
  If IsGadget(#GadgetBatteryLogMinutes) : gSettings\BatteryLogIntervalMinutes = GetGadgetState(#GadgetBatteryLogMinutes) : EndIf
  If IsGadget(#GadgetBatteryRefreshSeconds) : gSettings\BatteryRefreshSeconds = GetGadgetState(#GadgetBatteryRefreshSeconds) : EndIf
  If IsGadget(#GadgetBatteryMinPercent) : gSettings\BatteryMinPercent = GetGadgetState(#GadgetBatteryMinPercent) : EndIf
  If IsGadget(#GadgetBatteryMaxPercent) : gSettings\BatteryMaxPercent = GetGadgetState(#GadgetBatteryMaxPercent) : EndIf
  If IsGadget(#GadgetBatteryLimiterEnabled) : gSettings\BatteryLimiterEnabled = GetGadgetState(#GadgetBatteryLimiterEnabled) : EndIf
  If IsGadget(#GadgetBatteryLimiterMaxPercent) : gSettings\BatteryLimiterMaxPercent = GetGadgetState(#GadgetBatteryLimiterMaxPercent) : EndIf
  If IsGadget(#GadgetBatterySmoothingMinutes) : gSettings\BatterySmoothingMinutes = GetGadgetState(#GadgetBatterySmoothingMinutes) : EndIf
  If IsGadget(#GadgetBatteryStartupDrain) : gSettings\BatteryStartupDrainPctPerHour = GetGadgetState(#GadgetBatteryStartupDrain) : EndIf
  If IsGadget(#GadgetLogShowAverage) : gSettings\BatteryLogShowAverage = GetGadgetState(#GadgetLogShowAverage) : EndIf
  If IsGadget(#GadgetLogShowInstant) : gSettings\BatteryLogShowInstant = GetGadgetState(#GadgetLogShowInstant) : EndIf
  If IsGadget(#GadgetLogShowConnected) : gSettings\BatteryLogShowConnected = GetGadgetState(#GadgetLogShowConnected) : EndIf
  If IsGadget(#GadgetLogShowEvents) : gSettings\BatteryLogShowEvents = GetGadgetState(#GadgetLogShowEvents) : EndIf
  gSettings\BatteryLogIntervalMinutes = ClampInt(gSettings\BatteryLogIntervalMinutes, 1, 1440)
  gSettings\BatteryRefreshSeconds = ClampInt(gSettings\BatteryRefreshSeconds, 5, 3600)
  gSettings\BatteryMinPercent = ClampInt(gSettings\BatteryMinPercent, 1, 99)
  gSettings\BatteryMaxPercent = ClampInt(gSettings\BatteryMaxPercent, gSettings\BatteryMinPercent + 1, 100)
  gSettings\BatteryLimiterMaxPercent = ClampInt(gSettings\BatteryLimiterMaxPercent, gSettings\BatteryMinPercent + 1, 100)
  gSettings\BatterySmoothingMinutes = ClampInt(gSettings\BatterySmoothingMinutes, 5, 240)
  If gSettings\BatteryStartupDrainPctPerHour <= 0.0
    gSettings\BatteryStartupDrainPctPerHour = 12.0
  EndIf
  SaveSettings()
  If oldMinPercent <> gSettings\BatteryMinPercent
    ApplyBatterySleepFloorToManagedPlans()
  EndIf
  ApplySettingsToGui()
  RefreshBattery(#True)
  RefreshBatteryLogPreview()
EndProcedure

; Spinner/checkbox changes can fire repeatedly while the user is still editing.
; Debounce them so Windows powercfg battery writes happen once after the edit.
Procedure ScheduleBatterySettingsApply()
  If IsWindow(#WindowMain) = #False
    ProcedureReturn
  EndIf
  If gBatterySettingsApplyPending
    RemoveWindowTimer(#WindowMain, #TimerBatterySettingsApply)
  EndIf
  AddWindowTimer(#WindowMain, #TimerBatterySettingsApply, #BatterySettingsApplyDelayMs)
  gBatterySettingsApplyPending = #True
EndProcedure

Procedure ApplyPendingBatterySettings()
  If IsWindow(#WindowMain)
    RemoveWindowTimer(#WindowMain, #TimerBatterySettingsApply)
  EndIf
  If gBatterySettingsApplyPending
    SaveBatterySettingsFromGui()
  EndIf
  gBatterySettingsApplyPending = #False
EndProcedure

; Read current user-resized PowerPilot Log column widths from the live ListIcon.
; Hidden optional columns report width zero; keep their previous saved width so
; showing the column later restores the user's last useful size.
Procedure.i CaptureBatteryLogColumnWidths(saveIfChanged.i = #False)
  Protected column.i
  Protected width.i
  Protected changed.i
  If IsGadget(#GadgetBatteryLogPreview) = #False
    ProcedureReturn #False
  EndIf
  For column = 0 To 6
    width = GetGadgetItemAttribute(#GadgetBatteryLogPreview, #PB_Ignore, #PB_ListIcon_ColumnWidth, column)
    If width > 0 And width <> BatteryLogColumnWidth(column)
      SetBatteryLogColumnWidthSetting(column, width)
      changed = #True
    EndIf
  Next
  If changed And saveIfChanged
    SaveSettings()
  EndIf
  ProcedureReturn changed
EndProcedure

; Apply saved log column widths. The checkbox settings still control whether
; optional columns are shown, but their nonzero widths are retained separately.
Procedure ApplyBatteryLogColumnWidths()
  If IsGadget(#GadgetBatteryLogPreview) = #False
    ProcedureReturn
  EndIf
  SetGadgetItemAttribute(#GadgetBatteryLogPreview, #PB_Ignore, #PB_ListIcon_ColumnWidth, BatteryLogColumnWidth(0), 0)
  SetGadgetItemAttribute(#GadgetBatteryLogPreview, #PB_Ignore, #PB_ListIcon_ColumnWidth, BatteryLogColumnWidth(1), 1)
  SetGadgetItemAttribute(#GadgetBatteryLogPreview, #PB_Ignore, #PB_ListIcon_ColumnWidth, Bool(gSettings\BatteryLogShowAverage) * BatteryLogColumnWidth(2), 2)
  SetGadgetItemAttribute(#GadgetBatteryLogPreview, #PB_Ignore, #PB_ListIcon_ColumnWidth, Bool(gSettings\BatteryLogShowInstant) * BatteryLogColumnWidth(3), 3)
  SetGadgetItemAttribute(#GadgetBatteryLogPreview, #PB_Ignore, #PB_ListIcon_ColumnWidth, BatteryLogColumnWidth(4), 4)
  SetGadgetItemAttribute(#GadgetBatteryLogPreview, #PB_Ignore, #PB_ListIcon_ColumnWidth, Bool(gSettings\BatteryLogShowInstant) * BatteryLogColumnWidth(5), 5)
  SetGadgetItemAttribute(#GadgetBatteryLogPreview, #PB_Ignore, #PB_ListIcon_ColumnWidth, Bool(gSettings\BatteryLogShowConnected) * BatteryLogColumnWidth(6), 6)
EndProcedure

; Clear retained history and live estimate state, then immediately sample again
; so the graph/log are not left blank longer than necessary.
Procedure ResetBatteryStats()
  If FileSize(BatteryLogPath()) >= 0
    DeleteFile(BatteryLogPath())
  EndIf
  gBatteryGraphCount = 0
  gBatteryAverageBreakCount = 0
  gBatteryAppBreakCount = 0
  gBatteryEventCount = 0
  gLastBatteryLogTime = 0
  gBatteryLastSampleTime = 0
  gBatteryLastSamplePercent = 0.0
  gBatteryOnBatterySince = 0
  gBattery\EstimateMinutes = -1
  gBattery\EstimateValid = #False
  gBattery\InstantEstimateMinutes = -1
  gBattery\InstantEstimateValid = #False
  gBattery\InstantDrainPctPerHour = 0.0
  gBattery\SmoothedDrainPctPerHour = gSettings\BatteryStartupDrainPctPerHour
  gSettings\BatteryLastDrainPctPerHour = gSettings\BatteryStartupDrainPctPerHour
  SaveSettings()
  If IsGadget(#GadgetBatteryLogPreview)
    ClearGadgetItems(#GadgetBatteryLogPreview)
  EndIf
  DrawBatteryGraph()
  RefreshBattery(#True)
  RefreshBatteryLogPreview()
  RefreshBatteryStatsSummary()
  LogAction("Battery stats reset.")
EndProcedure

; Format one visible log row for tab-separated clipboard copy.
Procedure.s BatteryLogPreviewRowText(row.i)
  Protected columns.i = 7
  Protected i.i
  Protected text$
  For i = 0 To columns - 1
    If i > 0 : text$ + #TAB$ : EndIf
    text$ + GetGadgetItemText(#GadgetBatteryLogPreview, row, i)
  Next
  ProcedureReturn text$
EndProcedure

; Copy all selected rows. If nothing is selected, copy the newest visible row.
Procedure CopyBatteryLogRow()
  Protected row.i
  Protected copied.i
  Protected text$
  If IsGadget(#GadgetBatteryLogPreview) = #False
    ProcedureReturn
  EndIf
  For row = 0 To CountGadgetItems(#GadgetBatteryLogPreview) - 1
    If GetGadgetItemState(#GadgetBatteryLogPreview, row) & #PB_ListIcon_Selected
      If copied > 0 : text$ + #CRLF$ : EndIf
      text$ + BatteryLogPreviewRowText(row)
      copied + 1
    EndIf
  Next
  If copied = 0
    row = CountGadgetItems(#GadgetBatteryLogPreview) - 1
    If row >= 0
      text$ = BatteryLogPreviewRowText(row)
      copied = 1
    EndIf
  EndIf
  If copied = 0
    LogAction("No PowerPilot log row to copy.")
    ProcedureReturn
  EndIf
  SetClipboardText(text$)
  If copied = 1
    LogAction("PowerPilot log row copied.")
  Else
    LogAction(Str(copied) + " PowerPilot log rows copied.")
  EndIf
EndProcedure

; Copy the full retained CSV, not just visible columns.
Procedure CopyBatteryLogAll()
  Protected file.i
  Protected text$
  PruneBatteryLog()
  If FileSize(BatteryLogPath()) < 0
    LogAction("No PowerPilot log to copy.")
    ProcedureReturn
  EndIf
  file = ReadFile(#PB_Any, BatteryLogPath())
  If file
    While Eof(file) = 0
      text$ + ReadString(file) + #CRLF$
    Wend
    CloseFile(file)
  EndIf
  If text$ <> ""
    SetClipboardText(text$)
    LogAction("PowerPilot CSV log copied.")
  Else
    LogAction("No PowerPilot log to copy.")
  EndIf
EndProcedure

; Simple settings backup/restore helpers for the Battery Stats tab.
Procedure ExportSettings()
  Protected target$
  SaveSettings()
  target$ = SaveFileRequester("Export PowerPilot settings", GetHomeDirectory() + "PowerPilot-settings.ini", "INI files (*.ini)|*.ini|All files (*.*)|*.*", 0)
  If target$ = ""
    ProcedureReturn
  EndIf
  If LCase(GetExtensionPart(target$)) = ""
    target$ + ".ini"
  EndIf
  If CopyFile(SettingsPath(), target$)
    LogAction("Settings exported.")
  Else
    LogAction("Settings export failed.")
  EndIf
EndProcedure

Procedure ImportSettings()
  Protected source$
  source$ = OpenFileRequester("Import PowerPilot settings", GetHomeDirectory(), "INI files (*.ini)|*.ini|All files (*.*)|*.*", 0)
  If source$ = ""
    ProcedureReturn
  EndIf
  EnsureSettingsDirectory()
  If CopyFile(source$, SettingsPath())
    LoadSettings()
    gSelectedPlan = PlanIndexByName(gSettings\LastPlan)
    If gSelectedPlan < 0 : gSelectedPlan = 1 : EndIf
    ApplySettingsToGui()
    RefreshPlanList(#True)
    RefreshPlanEditor()
    RefreshBatteryLogPreview()
    RefreshBatteryStatsSummary()
    RefreshActiveTimer()
    LogAction("Settings imported.")
  Else
    LogAction("Settings import failed.")
  EndIf
EndProcedure

; Save Overview startup/maintenance settings.
Procedure SaveSettingsFromGui()
  Protected batteryGuid$
  gSettings\AutoStartWithApp = GetGadgetState(#GadgetAutoStart)
  gSettings\KeepSettingsOnReinstall = GetGadgetState(#GadgetKeepSettings)
  gSettings\ThrottleMaintenance = GetGadgetState(#GadgetThrottleMaintenance)
  gSettings\DeepIdleSaver = GetGadgetState(#GadgetDeepIdleSaver)
  gSettings\ShowToolTips = GetGadgetState(#GadgetShowToolTips)
  SaveSettings()
  SetStartupRegistry(gSettings\AutoStartWithApp)
  batteryGuid$ = GetSchemeGuidByName(#PlanBattery$)
  If batteryGuid$ <> ""
    ConfigureScheme(@gPlans(2), batteryGuid$)
  EndIf
  ApplyMaintenanceThrottling(IsEfficiencyPowerMode(GetWindowsPowerModeGuid()), #True)
  RefreshActiveTimer()
  ApplyToolTips()
  LogAction("Settings saved.")
EndProcedure

; Fill the PowerPilot Log tab from the retained CSV. The list intentionally
; shows the full retained window, not just the last few rows.
Procedure RefreshBatteryLogPreview()
  Protected file.i
  Protected line$
  Protected added.i
  Protected fieldCount.i
  Protected averageField.i
  Protected instantField.i
  Protected instantValueField.i
  Protected instantValue$
  Protected runtimeField.i
  Protected runtimeValue$
  Protected isEvent.i
  Protected rowType$
  If IsGadget(#GadgetBatteryLogPreview) = #False
    ProcedureReturn
  EndIf
  CaptureBatteryLogColumnWidths(#False)
  ClearGadgetItems(#GadgetBatteryLogPreview)
  ApplyBatteryLogColumnWidths()
  PruneBatteryLog()
  If ReadFile(0, BatteryLogPath())
    While Eof(0) = 0
      line$ = ReadString(0)
      If Left(line$, 9) <> "timestamp" And Trim(line$) <> ""
        fieldCount = CountString(line$, ",") + 1
        rowType$ = ""
        If fieldCount >= 19
          rowType$ = LCase(StringField(line$, 18, ","))
        EndIf
        isEvent = Bool(rowType$ = "event" Or rowType$ = "app")
        If isEvent
          If gSettings\BatteryLogShowEvents = #False
            Continue
          EndIf
          If rowType$ = "app"
            AddGadgetItem(#GadgetBatteryLogPreview, -1, StringField(line$, 1, ",") + Chr(10) + "APP" + Chr(10) + StringField(line$, 19, ",") + Chr(10) + "" + Chr(10) + "" + Chr(10) + "" + Chr(10) + "")
          Else
            AddGadgetItem(#GadgetBatteryLogPreview, -1, StringField(line$, 1, ",") + Chr(10) + "EVENT" + Chr(10) + StringField(line$, 19, ",") + Chr(10) + "" + Chr(10) + "" + Chr(10) + "" + Chr(10) + "")
          EndIf
        Else
          ; Legacy rows from earlier builds have fewer columns, so field indexes
          ; are chosen from the detected CSV shape.
          averageField = 11
          runtimeField = 12
          instantField = 0
          instantValueField = 0
          If fieldCount >= 17
            averageField = 13
            runtimeField = 12
            instantField = 14
            instantValueField = 15
          ElseIf fieldCount >= 16
            averageField = 13
            runtimeField = 12
            instantField = 14
          EndIf
          runtimeValue$ = FormatBatteryMinutes(Val(StringField(line$, runtimeField, ",")))
          If instantField > 0
            instantValue$ = FormatBatteryMinutes(Val(StringField(line$, instantField, ",")))
          Else
            instantValue$ = "Unknown"
          EndIf
          If instantValueField > 0
            instantValue$ + Chr(10) + StrD(ValD(StringField(line$, instantValueField, ",")), 1) + "%/h"
          Else
            instantValue$ + Chr(10) + ""
          EndIf
          AddGadgetItem(#GadgetBatteryLogPreview, -1, StringField(line$, 1, ",") + Chr(10) + StringField(line$, 2, ",") + "%" + Chr(10) + FormatBatteryMinutes(Val(StringField(line$, averageField, ","))) + Chr(10) + instantValue$ + Chr(10) + runtimeValue$ + Chr(10) + StringField(line$, 3, ","))
        EndIf
        added + 1
      EndIf
    Wend
    CloseFile(0)
  EndIf
  If added > 0
    ; Keep the newest row visible after refresh.
    SetGadgetState(#GadgetBatteryLogPreview, added - 1)
  EndIf
EndProcedure

; Update the Battery Graph tab and redraw graph/stats after every battery
; refresh. Unknown text is only shown when no valid battery provider responded.
Procedure RefreshBatteryDisplay()
  Protected connection$
  Protected charging$
  Protected estimate$
  Protected instantEstimate$
  Protected runtime$
  Protected fullEstimate$
  Protected wear$
  Protected maxCapacity$
  Protected floorText$ = " to " + Str(gSettings\BatteryMinPercent) + "%"
  Protected ceilingPercent.d
  If IsGadget(#GadgetBatteryPercent) = #False
    ProcedureReturn
  EndIf
  If gBattery\Valid = #False
    SetGadgetText(#GadgetBatteryPercent, "Unknown")
    SetGadgetText(#GadgetBatteryConnection, "Unknown")
    SetGadgetText(#GadgetBatteryCharging, "Unknown")
    SetGadgetText(#GadgetBatteryCapacity, "Unknown")
    SetGadgetText(#GadgetBatteryRates, "Unknown")
    SetGadgetText(#GadgetBatteryEstimate, "Unknown")
    SetGadgetText(#GadgetBatteryInstantEstimate, "Unknown")
    SetGadgetText(#GadgetBatteryRuntime, "Unknown")
    SetGadgetText(#GadgetBatteryFullEstimate, "Unknown")
    SetGadgetText(#GadgetBatteryWear, "Unknown")
    SetGadgetText(#GadgetBatteryMaxCapacity, "Unknown")
    SetGadgetText(#GadgetBatteryCycle, "Unknown")
    DrawBatteryGraph()
    ProcedureReturn
  EndIf
  If gBattery\Connected
    connection$ = "Connected"
  Else
    connection$ = "On battery"
  EndIf
  If gBattery\Charging
    charging$ = "Charging"
  ElseIf gBattery\DisconnectedBattery
    charging$ = "Discharging"
  Else
    charging$ = "Not charging"
  EndIf
  If gBattery\EstimateValid
    estimate$ = FormatBatteryMinutes(gBattery\EstimateMinutes) + floorText$ + " at " + StrD(gBattery\SmoothedDrainPctPerHour, 1) + "%/h"
  ElseIf gBattery\Connected
    estimate$ = "Connected"
  Else
    estimate$ = "Calculating"
  EndIf
  If gBattery\InstantEstimateValid
    instantEstimate$ = FormatBatteryMinutes(gBattery\InstantEstimateMinutes) + floorText$
  ElseIf gBattery\Connected
    instantEstimate$ = "Connected"
  Else
    instantEstimate$ = "Calculating"
  EndIf
  If gBattery\RuntimeValid
    runtime$ = FormatBatteryMinutes(gBattery\RuntimeMinutes)
  Else
    runtime$ = "Unknown"
  EndIf
  ceilingPercent = BatteryEffectiveMaxPercent()
  If gBattery\SmoothedDrainPctPerHour > 0.0 And ceilingPercent > gSettings\BatteryMinPercent
    fullEstimate$ = FormatBatteryMinutes(((ceilingPercent - gSettings\BatteryMinPercent) / gBattery\SmoothedDrainPctPerHour) * 60.0) + " (" + StrD(ceilingPercent, 0) + "->" + Str(gSettings\BatteryMinPercent) + "%)"
  Else
    fullEstimate$ = "Calculating"
  EndIf
  If gBattery\DesignMWh > 0.0 And gBattery\FullMWh > 0.0
    wear$ = StrD(gBattery\WearPercent, 1) + "%"
    maxCapacity$ = StrD(gBattery\FullMWh, 0) + " / " + StrD(gBattery\DesignMWh, 0) + " mWh"
  ElseIf gBattery\FullMWh > 0.0
    wear$ = "Unknown"
    maxCapacity$ = StrD(gBattery\FullMWh, 0) + " mWh"
  Else
    wear$ = "Unknown"
    maxCapacity$ = "Unknown"
  EndIf
  SetGadgetTextIfChanged(#GadgetBatteryPercent, StrD(gBattery\Percent, 1) + "%")
  SetGadgetTextIfChanged(#GadgetBatteryConnection, connection$)
  SetGadgetTextIfChanged(#GadgetBatteryCharging, charging$)
  SetGadgetTextIfChanged(#GadgetBatteryCapacity, StrD(gBattery\RemainingMWh, 0) + " mWh")
  SetGadgetTextIfChanged(#GadgetBatteryRates, "Discharge " + StrD(gBattery\DischargeRateMW, 0) + " mW, charge " + StrD(gBattery\ChargeRateMW, 0) + " mW")
  SetGadgetTextIfChanged(#GadgetBatteryEstimate, estimate$)
  SetGadgetTextIfChanged(#GadgetBatteryInstantEstimate, instantEstimate$)
  SetGadgetTextIfChanged(#GadgetBatteryRuntime, runtime$)
  SetGadgetTextIfChanged(#GadgetBatteryFullEstimate, fullEstimate$)
  SetGadgetTextIfChanged(#GadgetBatteryWear, wear$)
  SetGadgetTextIfChanged(#GadgetBatteryMaxCapacity, maxCapacity$)
  SetGadgetTextIfChanged(#GadgetBatteryCycle, Str(gBattery\CycleCount))
  DrawBatteryGraph()
  RefreshBatteryStatsSummary()
EndProcedure

; Draw the 24-hour gliding battery graph. Active intervals are green; power
; breaks and unexplained large gaps are grey endpoint-to-endpoint segments.
Procedure DrawBatteryGraph()
  Protected width.i
  Protected height.i
  Protected left.i = 44
  Protected top.i = 14
  Protected right.i
  Protected bottom.i
  Protected i.i
  Protected tick.q
  Protected startTime.q
  Protected endTime.q
  Protected firstHour.q
  Protected visibleCount.i
  Protected x1.i
  Protected y1.i
  Protected x2.i
  Protected y2.i
  Protected x.i
  Protected minPercent.d = gSettings\BatteryMinPercent
  Protected maxPercent.d = BatteryEffectiveMaxPercent()
  Protected span.d
  Protected percent.d
  Protected xScale.d
  Protected flatGapSeconds.i
  Protected flatSegment.i
  If IsGadget(#GadgetBatteryGraph) = #False
    ProcedureReturn
  EndIf
  width = GadgetWidth(#GadgetBatteryGraph)
  height = GadgetHeight(#GadgetBatteryGraph)
  right = width - 12
  bottom = height - 30
  endTime = Date()
  If gBatteryGraphCount > 0 And gBatteryGraph(gBatteryGraphCount - 1)\Timestamp > endTime
    endTime = gBatteryGraph(gBatteryGraphCount - 1)\Timestamp
  EndIf
  startTime = endTime - #BatteryGraphWindowSeconds
  xScale = (right - left) / #BatteryGraphWindowSeconds
  span = maxPercent - minPercent
  flatGapSeconds = BatteryGraphFlatGapSeconds()
  If span <= 0.0 : span = 1.0 : EndIf
  If StartDrawing(CanvasOutput(#GadgetBatteryGraph))
    Box(0, 0, width, height, RGB(250, 250, 248))
    DrawingMode(#PB_2DDrawing_Default)
    ; Hour marks are computed from wall-clock hours so date labels stay stable
    ; as the gliding window moves.
    firstHour = ParseDate("%yyyy-%mm-%dd %hh:%ii:%ss", FormatDate("%yyyy-%mm-%dd %hh:00:00", startTime))
    If firstHour < startTime
      firstHour = AddDate(firstHour, #PB_Date_Hour, 1)
    EndIf
    tick = firstHour
    While tick <= endTime
      x = left + ((tick - startTime) * xScale)
      If x >= left And x <= right
        If FormatDate("%hh", tick) = "00"
          FrontColor(RGB(154, 154, 148))
        Else
          FrontColor(RGB(218, 218, 214))
        EndIf
        LineXY(x, top, x, bottom)
      EndIf
      tick = AddDate(tick, #PB_Date_Hour, 1)
    Wend
    FrontColor(RGB(188, 188, 184))
    For i = 0 To 4
      y1 = top + ((bottom - top) * i / 4)
      LineXY(left, y1, right, y1)
    Next
    FrontColor(RGB(48, 48, 48))
    Box(left, top, 1, bottom - top + 1, RGB(48, 48, 48))
    Box(left, bottom, right - left + 1, 1, RGB(48, 48, 48))
    DrawingMode(#PB_2DDrawing_Transparent)
    FrontColor(RGB(24, 24, 24))
    DrawText(6, top - 2, StrD(maxPercent, 0) + "%")
    DrawText(8, bottom - 10, StrD(minPercent, 0) + "%")
    FrontColor(RGB(15, 112, 67))
    LineXY(left + 82, 5, left + 112, 5)
    DrawText(left + 118, 0, "active")
    FrontColor(RGB(112, 112, 108))
    LineXY(left + 176, 5, left + 206, 5)
    DrawText(left + 212, 0, "event/offline")
    tick = firstHour
    While tick <= endTime
      x = left + ((tick - startTime) * xScale)
      If x >= left And x <= right
        If FormatDate("%hh", tick) = "00"
          DrawText(x - 18, bottom + 4, FormatDate("%mm-%dd", tick))
        ElseIf Val(FormatDate("%hh", tick)) % 6 = 0
          DrawText(x - 10, bottom + 4, FormatDate("%hh", tick))
        EndIf
      EndIf
      tick = AddDate(tick, #PB_Date_Hour, 1)
    Wend
    DrawingMode(#PB_2DDrawing_Default)
    ; Draw PC power-event markers before the battery line so the line remains
    ; visible over the marker.
    For i = 0 To gBatteryEventCount - 1
      If gBatteryEvents(i)\Timestamp >= startTime And gBatteryEvents(i)\Timestamp <= endTime
        x = left + ((gBatteryEvents(i)\Timestamp - startTime) * xScale)
        FrontColor(RGB(176, 112, 56))
        LineXY(x, top, x, bottom)
        DrawingMode(#PB_2DDrawing_Transparent)
        FrontColor(RGB(94, 62, 32))
        DrawText(x + 2, top + 2, BatteryEventShortName(gBatteryEvents(i)\Name))
        DrawingMode(#PB_2DDrawing_Default)
      EndIf
    Next
    If gBatteryGraphCount > 1
      DrawingMode(#PB_2DDrawing_Default)
      For i = 1 To gBatteryGraphCount - 1
        If gBatteryGraph(i - 1)\Timestamp < startTime Or gBatteryGraph(i)\Timestamp < startTime
          Continue
        EndIf
        If gBatteryGraph(i - 1)\Timestamp > endTime Or gBatteryGraph(i)\Timestamp > endTime
          Continue
        EndIf
        percent = gBatteryGraph(i - 1)\Percent
        If percent < minPercent : percent = minPercent : EndIf
        If percent > maxPercent : percent = maxPercent : EndIf
        x1 = left + ((gBatteryGraph(i - 1)\Timestamp - startTime) * xScale)
        y1 = bottom - ((bottom - top) * (percent - minPercent) / span)
        percent = gBatteryGraph(i)\Percent
        If percent < minPercent : percent = minPercent : EndIf
        If percent > maxPercent : percent = maxPercent : EndIf
        x2 = left + ((gBatteryGraph(i)\Timestamp - startTime) * xScale)
        y2 = bottom - ((bottom - top) * (percent - minPercent) / span)
        ; A grey segment connects endpoints across true PC off/sleep gaps or
        ; unexplained missing samples. App restarts do not create grey gaps.
        flatSegment = Bool(BatteryIntervalHasPowerBreak(gBatteryGraph(i - 1)\Timestamp, gBatteryGraph(i)\Timestamp) Or (gBatteryGraph(i)\Timestamp - gBatteryGraph(i - 1)\Timestamp > flatGapSeconds And BatteryIntervalHasAppBreak(gBatteryGraph(i - 1)\Timestamp, gBatteryGraph(i)\Timestamp) = #False))
        If flatSegment
          FrontColor(RGB(112, 112, 108))
          LineXY(x1, y1, x2, y2)
          LineXY(x1, y1 + 1, x2, y2 + 1)
        Else
          FrontColor(RGB(15, 112, 67))
          LineXY(x1, y1, x2, y2)
          LineXY(x1, y1 + 1, x2, y2 + 1)
        EndIf
        visibleCount + 1
      Next
    EndIf
    If gBatteryGraphCount = 0 Or visibleCount = 0
      DrawingMode(#PB_2DDrawing_Transparent)
      FrontColor(RGB(70, 70, 70))
      DrawText(left + 12, top + 46, "Waiting for battery samples")
    EndIf
    StopDrawing()
  EndIf
EndProcedure

; Tooltip wrapper guards against gadgets that are not available in all states.
Procedure SetTip(gadget.i, text$)
  If IsGadget(gadget)
    GadgetToolTip(gadget, text$)
  EndIf
EndProcedure

; Tooltips can be turned off by the user without rebuilding the UI.
Procedure ApplyToolTips()
  Protected enabled.i = Bool(gSettings\ShowToolTips)
  Protected text$

  If enabled
    SetTip(#GadgetPanel, "Switch between system status and managed power-plan tuning.")
    SetTip(gIntroOverview, "PowerPilot mirrors Windows power mode and keeps hardware reporting lightweight.")
    SetTip(gFrameProcessor, "Static processor details from CPUID and Windows memory information.")
    SetTip(#GadgetCpuInfo, "Local CPU identity, topology, cache, memory, and instruction features. No helper process is used.")
    SetTip(gFrameState, "Current Windows plan, Windows power mode, and the latest PowerPilot action.")
    SetTip(#GadgetActivePlan, "The Windows power plan currently active.")
    SetTip(#GadgetPowerSource, "The Windows power mode PowerPilot follows: performance, balanced, or efficiency.")
    SetTip(#GadgetLastAction, "Most recent automatic or manual action.")
    SetTip(gFrameGraphics, "Display adapter name resolved from Windows display enumeration and local GPU matching.")
    SetTip(#GadgetGpuInfo, "Detected GPU name. Generic Windows names are refined when local CPU/GPU data allows it.")
    SetTip(gFrameStartup, "Startup and low-power behavior. Changes apply immediately.")
    SetTip(#GadgetAutoStart, "Start PowerPilot with Windows in the tray.")
    SetTip(#GadgetKeepSettings, "Keep saved PowerPilot settings when reinstalling.")
    SetTip(#GadgetThrottleMaintenance, "In efficiency mode, mark safe background maintenance processes for Windows EcoQoS throttling.")
    SetTip(#GadgetDeepIdleSaver, "In efficiency mode, reduce hidden PowerPilot wakeups and allow deeper CPU core parking.")
    SetTip(#GadgetShowToolTips, "Show or hide these hover explanations.")

    SetTip(gIntroPlans, "PowerPilot keeps exactly three editable managed plans and follows Windows power mode automatically.")
    SetTip(gFrameManagedPlans, "The three fixed PowerPilot plans managed inside Windows power settings.")
    SetTip(#GadgetPlanList, "Select one of the three fixed plans to edit its processor settings.")
    SetTip(gFramePlanSettings, "Processor power settings for the selected fixed plan. Save applies them to Windows.")
    SetTip(#GadgetPlanSummary, "Short purpose text shown in the managed plan list.")
    SetTip(#GadgetPlanAcEpp, "Plugged-in energy preference. 0 favors speed; 100 favors efficiency.")
    SetTip(#GadgetPlanDcEpp, "Battery energy preference. 0 favors speed; 100 favors efficiency.")
    SetTip(#GadgetPlanAcBoost, "Plugged-in processor boost behavior.")
    SetTip(#GadgetPlanDcBoost, "Battery processor boost behavior.")
    SetTip(#GadgetPlanAcState, "Plugged-in maximum processor state as a percentage.")
    SetTip(#GadgetPlanDcState, "Battery maximum processor state as a percentage.")
    SetTip(#GadgetPlanAcFreq, "Plugged-in maximum CPU frequency in MHz. 0 leaves Windows uncapped.")
    SetTip(#GadgetPlanDcFreq, "Battery maximum CPU frequency in MHz. 0 leaves Windows uncapped.")
    SetTip(#GadgetPlanAcCooling, "Plugged-in cooling policy. Passive favors less fan and lower clocks; Active favors cooling.")
    SetTip(#GadgetPlanDcCooling, "Battery cooling policy. Passive favors less fan and lower clocks; Active favors cooling.")
    SetTip(#GadgetPlanSave, "Save and apply the selected plan settings to Windows.")
    SetTip(#GadgetPlanReset, "Reset the selected plan to PowerPilot defaults.")
    SetTip(gFrameBatteryStatus, "Live battery status from Windows root\\wmi battery data with system-power fallback.")
    SetTip(gFrameBatteryEstimate, "PowerPilot's average and instant estimates plus direct Windows runtime when firmware exposes it.")
    SetTip(#GadgetBatteryPercent, "Current battery percentage calculated from remaining and full charge capacity when available.")
    SetTip(#GadgetBatteryConnection, "Whether Windows reports external power online.")
    SetTip(#GadgetBatteryCharging, "Charging, discharging, or idle battery state.")
    SetTip(#GadgetBatteryCapacity, "Remaining battery capacity in mWh.")
    SetTip(#GadgetBatteryRates, "Live charge and discharge rate from root\\wmi:BatteryStatus.")
    SetTip(#GadgetBatteryEstimate, "Average remaining time to the configured minimum percent sleep floor.")
    SetTip(#GadgetBatteryInstantEstimate, "Instant remaining time to the configured minimum percent sleep floor.")
    SetTip(#GadgetBatteryRuntime, "Direct Windows runtime from root\\wmi:BatteryRuntime when the firmware reports a usable value.")
    SetTip(#GadgetBatteryFullEstimate, "Average estimated battery life from the configured maximum ceiling down to the minimum percent floor.")
    SetTip(#GadgetBatteryWear, "Battery wear calculated from full-charge capacity versus design capacity.")
    SetTip(#GadgetBatteryMaxCapacity, "Current full-charge capacity and design capacity in mWh when Windows exposes both.")
    SetTip(#GadgetBatteryCycle, "Battery cycle count from root\\wmi:BatteryCycleCount.")
    SetTip(#GadgetBatteryGraph, "Gliding 24-hour battery percentage history with hour marks, event markers, and grey offline/event segments.")
    SetTip(gFrameBatterySettings, "Battery logging interval, refresh interval, graph range, limiter maximum, and estimate smoothing.")
    SetTip(#GadgetBatteryLogEnabled, "Enable or disable the battery CSV log.")
    SetTip(#GadgetBatteryLogMinutes, "Minutes between automatic battery sample rows in the PowerPilot log.")
    SetTip(#GadgetBatteryRefreshSeconds, "Seconds between live root\\wmi battery refreshes.")
    SetTip(#GadgetBatteryMinPercent, "Battery percentage treated as the empty floor for remaining-time estimates.")
    SetTip(#GadgetBatteryMaxPercent, "Battery percentage treated as the graph and charge ceiling when no limiter is active.")
    SetTip(#GadgetBatteryLimiterEnabled, "Use the limiter maximum instead of 100% as the configured full point.")
    SetTip(#GadgetBatteryLimiterMaxPercent, "Maximum battery charge target reported by your charge limiter.")
    SetTip(#GadgetBatterySmoothingMinutes, "Moving average window for percent-per-hour drain.")
    SetTip(#GadgetBatteryStartupDrain, "Percent-per-hour estimate used immediately after startup until one hour of fresh data accumulates.")
    SetTip(#GadgetBatteryStatsReset, "Clear the battery CSV log, graph samples, and current estimate calculations.")
    SetTip(#GadgetBatteryLogPreview, "Retained PowerPilot CSV rows for battery samples, power events, and app status messages.")
    SetTip(#GadgetBatteryLogCopyRow, "Copy selected PowerPilot log rows to the clipboard. If none are selected, copy the latest row.")
    SetTip(#GadgetBatteryLogCopyAll, "Copy the full retained battery CSV log to the clipboard.")
    SetTip(#GadgetBatterySessionSummary, "Latest startup, shutdown, sleep, wake, hibernate, or improper-shutdown event.")
    SetTip(#GadgetBatteryDailySummary, "Today-only battery range, active on-battery time, drain, wear, and cycle count.")
    SetTip(#GadgetBatteryOffLossSummary, "Battery percentage lost across sleep, hibernate, shutdown, startup, or large missing-sample gaps.")
    SetTip(#GadgetLogShowAverage, "Show or hide the average remaining-time column in the recent log.")
    SetTip(#GadgetLogShowInstant, "Show or hide the instant remaining-time and instant-drain columns in the recent log.")
    SetTip(#GadgetLogShowConnected, "Show or hide the connected column in the recent log.")
    SetTip(#GadgetLogShowEvents, "Show or hide power-event rows in the recent log.")
    SetTip(#GadgetSettingsExport, "Export PowerPilot settings to an INI file.")
    SetTip(#GadgetSettingsImport, "Import PowerPilot settings from an INI file.")
    SetTip(#GadgetHideToTray, "Hide PowerPilot to the tray while it continues following Windows power mode.")
    SetTip(#GadgetExit, "Exit PowerPilot and remove the tray icon.")
  Else
    SetTip(#GadgetPanel, "")
    SetTip(gIntroOverview, "")
    SetTip(gFrameProcessor, "")
    SetTip(#GadgetCpuInfo, "")
    SetTip(gFrameState, "")
    SetTip(#GadgetActivePlan, "")
    SetTip(#GadgetPowerSource, "")
    SetTip(#GadgetLastAction, "")
    SetTip(gFrameGraphics, "")
    SetTip(#GadgetGpuInfo, "")
    SetTip(gFrameStartup, "")
    SetTip(#GadgetAutoStart, "")
    SetTip(#GadgetKeepSettings, "")
    SetTip(#GadgetThrottleMaintenance, "")
    SetTip(#GadgetDeepIdleSaver, "")
    SetTip(gIntroPlans, "")
    SetTip(gFrameManagedPlans, "")
    SetTip(#GadgetPlanList, "")
    SetTip(gFramePlanSettings, "")
    SetTip(#GadgetPlanSummary, "")
    SetTip(#GadgetPlanAcEpp, "")
    SetTip(#GadgetPlanDcEpp, "")
    SetTip(#GadgetPlanAcBoost, "")
    SetTip(#GadgetPlanDcBoost, "")
    SetTip(#GadgetPlanAcState, "")
    SetTip(#GadgetPlanDcState, "")
    SetTip(#GadgetPlanAcFreq, "")
    SetTip(#GadgetPlanDcFreq, "")
    SetTip(#GadgetPlanAcCooling, "")
    SetTip(#GadgetPlanDcCooling, "")
    SetTip(#GadgetPlanSave, "")
    SetTip(#GadgetPlanReset, "")
    SetTip(gFrameBatteryStatus, "")
    SetTip(gFrameBatteryEstimate, "")
    SetTip(#GadgetBatteryPercent, "")
    SetTip(#GadgetBatteryConnection, "")
    SetTip(#GadgetBatteryCharging, "")
    SetTip(#GadgetBatteryCapacity, "")
    SetTip(#GadgetBatteryRates, "")
    SetTip(#GadgetBatteryEstimate, "")
    SetTip(#GadgetBatteryInstantEstimate, "")
    SetTip(#GadgetBatteryRuntime, "")
    SetTip(#GadgetBatteryFullEstimate, "")
    SetTip(#GadgetBatteryWear, "")
    SetTip(#GadgetBatteryMaxCapacity, "")
    SetTip(#GadgetBatteryCycle, "")
    SetTip(#GadgetBatteryGraph, "")
    SetTip(gFrameBatterySettings, "")
    SetTip(#GadgetBatteryLogEnabled, "")
    SetTip(#GadgetBatteryLogMinutes, "")
    SetTip(#GadgetBatteryRefreshSeconds, "")
    SetTip(#GadgetBatteryMinPercent, "")
    SetTip(#GadgetBatteryMaxPercent, "")
    SetTip(#GadgetBatteryLimiterEnabled, "")
    SetTip(#GadgetBatteryLimiterMaxPercent, "")
    SetTip(#GadgetBatterySmoothingMinutes, "")
    SetTip(#GadgetBatteryStartupDrain, "")
    SetTip(#GadgetBatteryStatsReset, "")
    SetTip(#GadgetBatteryLogPreview, "")
    SetTip(#GadgetBatteryLogCopyRow, "")
    SetTip(#GadgetBatteryLogCopyAll, "")
    SetTip(#GadgetBatterySessionSummary, "")
    SetTip(#GadgetBatteryDailySummary, "")
    SetTip(#GadgetBatteryOffLossSummary, "")
    SetTip(#GadgetLogShowAverage, "")
    SetTip(#GadgetLogShowInstant, "")
    SetTip(#GadgetLogShowConnected, "")
    SetTip(#GadgetLogShowEvents, "")
    SetTip(#GadgetSettingsExport, "")
    SetTip(#GadgetSettingsImport, "")
    SetTip(#GadgetHideToTray, "")
    SetTip(#GadgetExit, "")
    SetTip(#GadgetShowToolTips, "Show or hide hover explanations.")
    ProcedureReturn
  EndIf
EndProcedure

; Refresh Overview text. Hidden/tray mode skips expensive static UI updates
; unless forced by ShowFromTray/startup.
Procedure RefreshDisplay(force.i = #False)
  Protected activeGuid$
  Protected active$
  Protected powerModeGuid$
  Protected powerModeText$
  If force = #False And MainWindowVisible() = #False
    ProcedureReturn
  EndIf

  activeGuid$ = GetActiveSchemeGuid()
  If force Or activeGuid$ <> gCachedActiveGuid$ Or gCachedActiveName$ = ""
    gCachedActiveGuid$ = activeGuid$
    gCachedActiveName$ = GetSchemeNameByGuid(activeGuid$)
  EndIf

  powerModeGuid$ = GetWindowsPowerModeGuid()
  If force Or powerModeGuid$ <> gCachedPowerModeGuid$ Or gCachedPowerModeText$ = ""
    gCachedPowerModeGuid$ = powerModeGuid$
    powerModeText$ = PowerModeTextFromGuid(powerModeGuid$)
    If powerModeText$ = ""
      powerModeText$ = "Classic power plan"
    EndIf
    gCachedPowerModeText$ = powerModeText$
  EndIf

  active$ = gCachedActiveName$
  SetGadgetTextIfChanged(#GadgetCpuInfo, CpuInfo())
  SetGadgetTextIfChanged(#GadgetGpuInfo, GpuInfo())
  If active$ = "" : active$ = "Unknown" : EndIf
  SetGadgetTextIfChanged(#GadgetActivePlan, active$)
  SetGadgetTextIfChanged(#GadgetPowerSource, gCachedPowerModeText$)
  If gLastAction$ <> ""
    SetGadgetTextIfChanged(#GadgetLastAction, gLastAction$)
  EndIf
EndProcedure

; Follow Windows power mode. External active plans become the new base for
; PowerPilot's three managed plans; managed plans switch according to overlay.
Procedure.i ApplyWindowsPowerFollow(force.i = #False)
  Protected activeGuid$ = GetActiveSchemeGuid()
  Protected activeName$
  Protected powerModeGuid$ = GetWindowsPowerModeGuid()
  Protected targetPlan$
  Protected shouldApply.i
  Protected usedExternalBase.i
  Protected applied.i

  If activeGuid$ <> ""
    activeName$ = GetSchemeNameByGuid(activeGuid$)
  EndIf
  targetPlan$ = TargetPlanForPowerModeGuid(powerModeGuid$)
  If targetPlan$ = ""
    targetPlan$ = TargetPlanForWindowsPlan(activeName$)
  EndIf
  If targetPlan$ = ""
    targetPlan$ = #PlanBalanced$
  EndIf

  ; First run initializes observation state. Later runs react to either an
  ; external plan change or a Windows power-mode overlay change.
  If force
    shouldApply = Bool(activeName$ <> targetPlan$ Or activeGuid$ = "")
  ElseIf gMonitorInitialized = #False
    gMonitorInitialized = #True
    shouldApply = Bool(IsManagedPlanName(activeName$) = #False Or activeName$ <> targetPlan$ Or activeGuid$ = "")
  Else
    If activeGuid$ <> "" And IsManagedPlanName(activeName$) = #False And activeGuid$ <> gLastObservedActiveGuid$
      shouldApply = #True
    ElseIf activeGuid$ <> "" And IsManagedPlanName(activeName$) And activeName$ <> targetPlan$
      shouldApply = #True
    ElseIf powerModeGuid$ <> "" And powerModeGuid$ <> gLastObservedPowerModeGuid$ And activeName$ <> targetPlan$
      shouldApply = #True
    EndIf
  EndIf

  If shouldApply
    ; If the user selected a non-PowerPilot plan, rebuild the fixed plans from
    ; that plan so OEM/vendor hidden defaults are preserved.
    If activeGuid$ <> "" And IsManagedPlanName(activeName$) = #False
      If CreateManagedPlansFromBase(activeGuid$, #True)
        usedExternalBase = #True
      EndIf
    ElseIf GetSchemeGuidByName(targetPlan$) = ""
      CreateManagedPlansFromBase("SCHEME_BALANCED", #True)
    EndIf

    If ActivatePlanByName(targetPlan$)
      If usedExternalBase
        LogAction(activeName$ + " followed as " + targetPlan$ + ".")
      Else
        LogAction(targetPlan$ + " activated to follow Windows power mode.")
      EndIf
      applied = #True
    EndIf
    activeGuid$ = GetActiveSchemeGuid()
  EndIf

  gLastObservedActiveGuid$ = activeGuid$
  gLastObservedPowerModeGuid$ = powerModeGuid$
  ProcedureReturn applied
EndProcedure

; Timer task for power-mode following plus optional EcoQoS maintenance throttle.
Procedure MonitorAutomaticPlans()
  Protected powerModeGuid$ = GetWindowsPowerModeGuid()
  Protected throttleEnabled.i = IsEfficiencyPowerMode(powerModeGuid$)
  If ApplyWindowsPowerFollow(#False)
    RefreshPlanList(#True)
  EndIf
  ApplyMaintenanceThrottling(throttleEnabled)
EndProcedure

; Tray menu is intentionally tiny: open or exit.
Procedure CreateTrayMenu()
  If CreatePopupMenu(#PopupTray)
    MenuItem(#MenuOpen, "Open PowerPilot")
    MenuBar()
    MenuItem(#MenuExit, "Exit")
  EndIf
EndProcedure

; Add the tray icon if possible. Failure is tolerated because the window can
; remain visible and continue refreshing.
Procedure SetupTray()
  Protected iconPath$ = GetPathPart(ProgramFilename()) + "powerpilot_tray.ico"
  If gTrayReady
    ProcedureReturn
  EndIf
  If FileSize(iconPath$) <= 0
    iconPath$ = GetCurrentDirectory() + "powerpilot_tray.ico"
  EndIf
  If IsImage(#ImageTray) Or LoadImage(#ImageTray, iconPath$)
    gTrayReady = AddSysTrayIcon(#TrayIconMain, WindowID(#WindowMain), ImageID(#ImageTray))
    If gTrayReady
      SysTrayIconToolTip(#TrayIconMain, #TrayTooltip$)
    EndIf
  EndIf
EndProcedure

; Hidden mode can refresh less often when deep idle saver is enabled.
Procedure.i DesiredRefreshInterval()
  If MainWindowVisible()
    ProcedureReturn #RefreshVisibleMs
  EndIf
  If gSettings\DeepIdleSaver
    ProcedureReturn #RefreshHiddenDeepIdleMs
  EndIf
  ProcedureReturn #RefreshHiddenMs
EndProcedure

; Replace the existing timer only when the interval actually changes.
Procedure StartRefreshTimer(intervalMs.i = 0)
  If intervalMs <= 0
    intervalMs = DesiredRefreshInterval()
  EndIf
  If gRefreshTimerActive And gRefreshTimerMs = intervalMs
    ProcedureReturn
  EndIf
  If gRefreshTimerActive
    RemoveWindowTimer(#WindowMain, #TimerRefresh)
  EndIf
  AddWindowTimer(#WindowMain, #TimerRefresh, intervalMs)
  gRefreshTimerActive = #True
  gRefreshTimerMs = intervalMs
EndProcedure

Procedure RefreshActiveTimer()
  If gRefreshTimerActive
    StartRefreshTimer(DesiredRefreshInterval())
  EndIf
EndProcedure

; Hide to tray when the tray icon exists. If the tray icon could not be created,
; keep the window visible so the user is not left with an invisible app.
Procedure HideToTray()
  ApplyPendingBatterySettings()
  CaptureBatteryLogColumnWidths(#True)
  If gTrayReady Or gStartedInTrayMode
    HideWindow(#WindowMain, #True)
    StartRefreshTimer()
  Else
    HideWindow(#WindowMain, #False)
    StartRefreshTimer(#RefreshVisibleMs)
    LogAction("Tray icon unavailable. Window stays visible.")
  EndIf
EndProcedure

; Showing the window forces a refresh so the UI is current immediately.
Procedure ShowFromTray()
  HideWindow(#WindowMain, #False)
  StartRefreshTimer(#RefreshVisibleMs)
  RefreshPlanList(#True)
  RefreshBattery(#True)
  RefreshDisplay(#True)
  SetForegroundWindow_(WindowID(#WindowMain))
EndProcedure

; Normal explicit app exit writes an app row, not a PC shutdown event.
Procedure ShutdownApp()
  ApplyPendingBatterySettings()
  CaptureBatteryLogColumnWidths(#False)
  SaveSettings()
  WriteBatteryAppEvent("PowerPilot exit")
  If gTrayReady
    RemoveSysTrayIcon(#TrayIconMain)
  EndIf
  End
EndProcedure

; Installer-driven replacement exits use a separate app row so the log and
; graph do not look like the user pressed Exit or the PC shut down.
Procedure ShutdownForUpdate()
  ApplyPendingBatterySettings()
  CaptureBatteryLogColumnWidths(#False)
  SaveSettings()
  WriteBatteryAppEvent("PowerPilot update close")
  If gTrayReady
    RemoveSysTrayIcon(#TrayIconMain)
  EndIf
  End
EndProcedure

; Central gadget event dispatcher.
Procedure HandleAction(gadget.i)
  Protected row.i
  Select gadget
    Case #GadgetPlanList
      row = GetGadgetState(#GadgetPlanList)
      If row >= 0 And row <= 2
        gSelectedPlan = row
        RefreshPlanEditor()
      EndIf

    Case #GadgetPlanSave
      SavePlanEditor()

    Case #GadgetPlanReset
      ResetSelectedPlan()

    Case #GadgetAutoStart, #GadgetKeepSettings, #GadgetThrottleMaintenance, #GadgetDeepIdleSaver, #GadgetShowToolTips
      SaveSettingsFromGui()

    Case #GadgetBatteryLogEnabled, #GadgetBatteryLogMinutes, #GadgetBatteryRefreshSeconds, #GadgetBatteryMinPercent, #GadgetBatteryMaxPercent, #GadgetBatteryLimiterEnabled, #GadgetBatteryLimiterMaxPercent, #GadgetBatterySmoothingMinutes, #GadgetBatteryStartupDrain
      ScheduleBatterySettingsApply()

    Case #GadgetBatteryStatsReset
      ResetBatteryStats()

    Case #GadgetLogShowAverage, #GadgetLogShowInstant, #GadgetLogShowConnected, #GadgetLogShowEvents
      SaveBatterySettingsFromGui()

    Case #GadgetSettingsExport
      ExportSettings()

    Case #GadgetSettingsImport
      ImportSettings()

    Case #GadgetBatteryLogCopyRow
      CopyBatteryLogRow()

    Case #GadgetBatteryLogCopyAll
      CopyBatteryLogAll()

    Case #GadgetHideToTray
      HideToTray()

    Case #GadgetExit
      ShutdownApp()
  EndSelect
EndProcedure

; Tray menu dispatcher.
Procedure HandleMenu(menu.i)
  Select menu
    Case #MenuOpen
      ShowFromTray()
    Case #MenuExit
      ShutdownApp()
  EndSelect
  RefreshPlanList()
  RefreshDisplay()
EndProcedure

; Native window callback catches power/session messages that PureBasic's normal
; event loop does not expose with enough detail for shutdown/sleep logging.
Procedure.i MainWindowCallback(hwnd.i, message.i, wParam.i, lParam.i)
  Protected resumeEvent$
  Protected closeForAppRestart.i
  Select message
    Case #WM_POWERPILOT_UPDATE_CLOSE
      ShutdownForUpdate()
      ProcedureReturn #True

    Case #WM_POWERBROADCAST
      Select wParam
        Case #PBT_APMSUSPEND
          gLastSuspendTime = Date()
          WriteBatteryEvent("Sleep/Hibernate")

        Case #PBT_APMRESUMEAUTOMATIC, #PBT_APMRESUMESUSPEND, #PBT_APMRESUMECRITICAL
          resumeEvent$ = RecentResumeEventName()
          If resumeEvent$ <> ""
            WriteBatteryEvent(resumeEvent$)
          ElseIf gLastSuspendTime > 0 And Date() - gLastSuspendTime >= 7200
            WriteBatteryEvent("Return from hibernation")
          Else
            WriteBatteryEvent("Wake")
          EndIf
          gLastSuspendTime = 0
          RefreshBattery(#True)
      EndSelect
      ProcedureReturn #True

    Case #WM_QUERYENDSESSION
      ; Restart Manager sends ENDSESSION_CLOSEAPP when setup/restart flows close
      ; the app. Those are app lifecycle rows, not PC shutdown rows.
      closeForAppRestart = Bool(lParam & #ENDSESSION_CLOSEAPP)
      If closeForAppRestart = #False
        WriteBatteryEvent("Shutdown requested")
      EndIf

    Case #WM_ENDSESSION
      closeForAppRestart = Bool(lParam & #ENDSESSION_CLOSEAPP)
      If wParam <> 0 And gShutdownLogged = #False
        If closeForAppRestart
          WriteBatteryAppEvent("PowerPilot update close")
        Else
          WriteBatteryEvent("Shutdown")
        EndIf
        gShutdownLogged = #True
      EndIf
  EndSelect
  ProcedureReturn #PB_ProcessPureBasicEvents
EndProcedure

; Build all tabs in one place. The window is fixed-size and dense on purpose:
; PowerPilot is a utility, not a landing page.
Procedure CreateMainWindow(showWindow.i)
  Protected flags.i = #PB_Window_SystemMenu | #PB_Window_MinimizeGadget | #PB_Window_ScreenCentered
  Protected activeLabel.i
  Protected modeLabel.i
  Protected lastActionLabel.i
  Protected acHeader.i
  Protected dcHeader.i
  Protected acCoolingHeader.i
  Protected dcCoolingHeader.i
  Protected batteryLabel.i
  Protected batterySettingsLabel.i
  If showWindow = #False
    flags | #PB_Window_Invisible
  EndIf
  OpenWindow(#WindowMain, 0, 0, 760, 560, #AppFullName$, flags)
  SetWindowCallback(@MainWindowCallback(), #WindowMain)
  EnsureUiFonts()
  CreateTrayMenu()
  SetupTray()

  PanelGadget(#GadgetPanel, 12, 12, 736, 486)

  ; Overview tab: static hardware summaries, current plan/mode, and the latest
  ; full action message. Short action messages also go to the PowerPilot Log.
  AddGadgetItem(#GadgetPanel, -1, "Overview")
  gIntroOverview = TextGadget(#PB_Any, 18, 14, 700, 22, "PowerPilot follows Windows power mode: Best performance, Balanced, or Best power efficiency.")
  UseBoldFont(gIntroOverview)
  gFrameProcessor = FrameGadget(#PB_Any, 18, 42, 700, 104, "Processor")
  TextGadget(#GadgetCpuInfo, 34, 64, 668, 78, "Reading CPU...")
  gFrameState = FrameGadget(#PB_Any, 18, 154, 700, 86, "Current State")
  activeLabel = TextGadget(#PB_Any, 34, 184, 92, 22, "Active plan:")
  TextGadget(#GadgetActivePlan, 132, 184, 210, 22, "")
  modeLabel = TextGadget(#PB_Any, 360, 184, 108, 22, "Windows mode:")
  TextGadget(#GadgetPowerSource, 476, 184, 226, 22, "")
  lastActionLabel = TextGadget(#PB_Any, 34, 214, 92, 22, "Last action:")
  TextGadget(#GadgetLastAction, 132, 214, 570, 22, "")
  UseBoldFont(activeLabel)
  UseBoldFont(#GadgetActivePlan)
  UseBoldFont(modeLabel)
  UseBoldFont(#GadgetPowerSource)
  UseBoldFont(lastActionLabel)
  gFrameGraphics = FrameGadget(#PB_Any, 18, 248, 342, 160, "Graphics")
  TextGadget(#GadgetGpuInfo, 34, 272, 310, 112, "Reading GPU...")
  gFrameStartup = FrameGadget(#PB_Any, 376, 248, 342, 160, "Startup")
  CheckBoxGadget(#GadgetAutoStart, 406, 280, 152, 20, "Start with Windows")
  CheckBoxGadget(#GadgetKeepSettings, 560, 280, 140, 20, "Keep on reinstall")
  CheckBoxGadget(#GadgetThrottleMaintenance, 406, 318, 152, 20, "Throttle maintenance")
  CheckBoxGadget(#GadgetDeepIdleSaver, 560, 318, 140, 20, "Deep idle saver")
  CheckBoxGadget(#GadgetShowToolTips, 483, 360, 130, 20, "Show tips")

  ; Plans tab: fixed three-plan editor. Manual plan activation is intentionally
  ; not exposed; Windows power mode decides which plan is active.
  AddGadgetItem(#GadgetPanel, -1, "Plans")
  gIntroPlans = TextGadget(#PB_Any, 18, 14, 700, 22, "Edit the three fixed PowerPilot plans; Windows mode chooses Maximum, Balanced, or Battery.")
  UseBoldFont(gIntroPlans)
  gFrameManagedPlans = FrameGadget(#PB_Any, 18, 40, 700, 134, "Fixed Plans")
  ListIconGadget(#GadgetPlanList, 34, 62, 668, 96, "Plan", 176, #PB_ListIcon_FullRowSelect | #PB_ListIcon_AlwaysShowSelection)
  AddGadgetColumn(#GadgetPlanList, 1, "Installed", 70)
  AddGadgetColumn(#GadgetPlanList, 2, "Purpose", 395)

  gFramePlanSettings = FrameGadget(#PB_Any, 18, 190, 700, 216, "Selected Plan Settings")
  TextGadget(#PB_Any, 34, 212, 64, 20, "Purpose:")
  StringGadget(#GadgetPlanSummary, 104, 208, 598, 22, "")
  acHeader = TextGadget(#PB_Any, 154, 238, 110, 20, "Plugged in")
  dcHeader = TextGadget(#PB_Any, 318, 238, 110, 20, "Battery")
  UseBoldFont(acHeader)
  UseBoldFont(dcHeader)
  TextGadget(#PB_Any, 34, 262, 86, 20, "Efficiency:")
  SpinGadget(#GadgetPlanAcEpp, 154, 258, 72, 22, 0, 100, #PB_Spin_Numeric)
  SpinGadget(#GadgetPlanDcEpp, 318, 258, 72, 22, 0, 100, #PB_Spin_Numeric)
  TextGadget(#PB_Any, 34, 286, 86, 20, "Boost:")
  ComboBoxGadget(#GadgetPlanAcBoost, 154, 282, 112, 22)
  ComboBoxGadget(#GadgetPlanDcBoost, 318, 282, 112, 22)
  TextGadget(#PB_Any, 34, 310, 86, 20, "Max CPU:")
  SpinGadget(#GadgetPlanAcState, 154, 306, 72, 22, 1, 100, #PB_Spin_Numeric)
  SpinGadget(#GadgetPlanDcState, 318, 306, 72, 22, 1, 100, #PB_Spin_Numeric)
  TextGadget(#PB_Any, 34, 334, 86, 20, "MHz cap:")
  SpinGadget(#GadgetPlanAcFreq, 154, 330, 72, 22, 0, 6000, #PB_Spin_Numeric)
  SpinGadget(#GadgetPlanDcFreq, 318, 330, 72, 22, 0, 6000, #PB_Spin_Numeric)
  TextGadget(#PB_Any, 458, 262, 64, 20, "Cooling:")
  acCoolingHeader = TextGadget(#PB_Any, 528, 238, 80, 20, "Plugged in")
  dcCoolingHeader = TextGadget(#PB_Any, 618, 238, 80, 20, "Battery")
  UseBoldFont(acCoolingHeader)
  UseBoldFont(dcCoolingHeader)
  ComboBoxGadget(#GadgetPlanAcCooling, 528, 258, 80, 22)
  ComboBoxGadget(#GadgetPlanDcCooling, 618, 258, 80, 22)
  ButtonGadget(#GadgetPlanSave, 528, 358, 80, 26, "Save")
  ButtonGadget(#GadgetPlanReset, 618, 358, 80, 26, "Reset")

  ; Battery Graph tab: live telemetry and the large gliding percent graph.
  AddGadgetItem(#GadgetPanel, -1, "Battery Graph")
  gFrameBatteryStatus = FrameGadget(#PB_Any, 18, 18, 328, 180, "Live Battery")
  batteryLabel = TextGadget(#PB_Any, 34, 46, 92, 20, "Battery:")
  TextGadget(#GadgetBatteryPercent, 132, 46, 184, 20, "Reading...")
  TextGadget(#PB_Any, 34, 72, 92, 20, "Connected:")
  TextGadget(#GadgetBatteryConnection, 132, 72, 184, 20, "")
  TextGadget(#PB_Any, 34, 98, 92, 20, "Charging:")
  TextGadget(#GadgetBatteryCharging, 132, 98, 184, 20, "")
  TextGadget(#PB_Any, 34, 124, 92, 20, "Remaining:")
  TextGadget(#GadgetBatteryCapacity, 132, 124, 184, 20, "")
  TextGadget(#PB_Any, 34, 150, 92, 20, "Rates:")
  TextGadget(#GadgetBatteryRates, 132, 150, 184, 20, "")
  UseBoldFont(batteryLabel)
  UseBoldFont(#GadgetBatteryPercent)

  gFrameBatteryEstimate = FrameGadget(#PB_Any, 368, 18, 350, 180, "Estimate")
  TextGadget(#PB_Any, 384, 40, 112, 18, "Average:")
  TextGadget(#GadgetBatteryEstimate, 502, 40, 186, 18, "")
  TextGadget(#PB_Any, 384, 62, 112, 18, "Instant:")
  TextGadget(#GadgetBatteryInstantEstimate, 502, 62, 186, 18, "")
  TextGadget(#PB_Any, 384, 84, 112, 18, "Windows:")
  TextGadget(#GadgetBatteryRuntime, 502, 84, 186, 18, "")
  TextGadget(#PB_Any, 384, 106, 112, 18, "Max avg:")
  TextGadget(#GadgetBatteryFullEstimate, 502, 106, 186, 18, "")
  TextGadget(#PB_Any, 384, 128, 112, 18, "Wear:")
  TextGadget(#GadgetBatteryWear, 502, 128, 186, 18, "")
  TextGadget(#PB_Any, 384, 150, 112, 18, "Max capacity:")
  TextGadget(#GadgetBatteryMaxCapacity, 502, 150, 186, 18, "")
  TextGadget(#PB_Any, 384, 172, 112, 18, "Cycle count:")
  TextGadget(#GadgetBatteryCycle, 502, 172, 186, 18, "")

  gFrameBatteryGraph = FrameGadget(#PB_Any, 18, 204, 700, 278, "Battery Percent")
  CanvasGadget(#GadgetBatteryGraph, 34, 226, 668, 244)

  ; PowerPilot Log tab: settings plus retained CSV rows. The visible list shows
  ; the full retained 168-hour log window and supports multi-row copy.
  AddGadgetItem(#GadgetPanel, -1, "PowerPilot Log")
  gFrameBatterySettings = FrameGadget(#PB_Any, 18, 18, 700, 130, "PowerPilot Log and Estimate Settings")
  CheckBoxGadget(#GadgetBatteryLogEnabled, 34, 44, 128, 20, "Log battery")
  TextGadget(#PB_Any, 184, 46, 82, 20, "Log every:")
  SpinGadget(#GadgetBatteryLogMinutes, 272, 42, 70, 22, 1, 1440, #PB_Spin_Numeric)
  TextGadget(#PB_Any, 348, 46, 48, 20, "min")
  TextGadget(#PB_Any, 420, 46, 82, 20, "Refresh:")
  SpinGadget(#GadgetBatteryRefreshSeconds, 508, 42, 70, 22, 5, 3600, #PB_Spin_Numeric)
  TextGadget(#PB_Any, 584, 46, 48, 20, "sec")

  TextGadget(#PB_Any, 34, 80, 92, 20, "Min percent:")
  SpinGadget(#GadgetBatteryMinPercent, 132, 76, 70, 22, 1, 99, #PB_Spin_Numeric)
  TextGadget(#PB_Any, 224, 80, 92, 20, "Max percent:")
  SpinGadget(#GadgetBatteryMaxPercent, 322, 76, 70, 22, 2, 100, #PB_Spin_Numeric)
  CheckBoxGadget(#GadgetBatteryLimiterEnabled, 420, 78, 124, 20, "Limiter active")
  SpinGadget(#GadgetBatteryLimiterMaxPercent, 568, 76, 70, 22, 2, 100, #PB_Spin_Numeric)

  TextGadget(#PB_Any, 34, 116, 92, 20, "Glide window:")
  SpinGadget(#GadgetBatterySmoothingMinutes, 132, 112, 70, 22, 5, 240, #PB_Spin_Numeric)
  TextGadget(#PB_Any, 208, 116, 42, 20, "min")
  TextGadget(#PB_Any, 272, 116, 126, 20, "Startup drain:")
  SpinGadget(#GadgetBatteryStartupDrain, 404, 112, 70, 22, 1, 100, #PB_Spin_Numeric)
  TextGadget(#PB_Any, 480, 116, 48, 20, "%/h")
  ButtonGadget(#GadgetBatteryStatsReset, 584, 110, 104, 26, "Reset stats")

  gFrameBatteryLog = FrameGadget(#PB_Any, 18, 160, 700, 292, "Retained PowerPilot Log")
  ListIconGadget(#GadgetBatteryLogPreview, 34, 184, 668, 226, "Timestamp", BatteryLogColumnWidth(0), #PB_ListIcon_FullRowSelect | #PB_ListIcon_MultiSelect)
  AddGadgetColumn(#GadgetBatteryLogPreview, 1, "Battery", BatteryLogColumnWidth(1))
  AddGadgetColumn(#GadgetBatteryLogPreview, 2, "Avg time", BatteryLogColumnWidth(2))
  AddGadgetColumn(#GadgetBatteryLogPreview, 3, "Instant time", BatteryLogColumnWidth(3))
  AddGadgetColumn(#GadgetBatteryLogPreview, 4, "Windows", BatteryLogColumnWidth(4))
  AddGadgetColumn(#GadgetBatteryLogPreview, 5, "Instant", BatteryLogColumnWidth(5))
  AddGadgetColumn(#GadgetBatteryLogPreview, 6, "Connected", BatteryLogColumnWidth(6))
  ButtonGadget(#GadgetBatteryLogCopyRow, 514, 420, 86, 24, "Copy row")
  ButtonGadget(#GadgetBatteryLogCopyAll, 608, 420, 94, 24, "Copy CSV")

  ; Battery Stats tab: derived summaries and display/export controls.
  AddGadgetItem(#GadgetPanel, -1, "Battery Stats")
  FrameGadget(#PB_Any, 18, 18, 340, 92, "Session")
  TextGadget(#GadgetBatterySessionSummary, 34, 42, 308, 54, "Waiting for power events.", #PB_Text_Border)
  FrameGadget(#PB_Any, 378, 18, 340, 92, "Off-Time Battery Loss")
  TextGadget(#GadgetBatteryOffLossSummary, 394, 42, 308, 54, "Waiting for battery gaps.", #PB_Text_Border)
  FrameGadget(#PB_Any, 18, 124, 700, 112, "Daily Battery Summary")
  TextGadget(#GadgetBatteryDailySummary, 34, 148, 668, 74, "Waiting for battery samples.", #PB_Text_Border)
  FrameGadget(#PB_Any, 18, 254, 340, 112, "PowerPilot Log Columns")
  CheckBoxGadget(#GadgetLogShowAverage, 34, 286, 84, 20, "Average")
  CheckBoxGadget(#GadgetLogShowInstant, 126, 286, 78, 20, "Instant")
  CheckBoxGadget(#GadgetLogShowConnected, 212, 286, 92, 20, "Connected")
  CheckBoxGadget(#GadgetLogShowEvents, 34, 322, 84, 20, "Events")
  FrameGadget(#PB_Any, 378, 254, 340, 112, "Settings Backup")
  ButtonGadget(#GadgetSettingsExport, 394, 296, 126, 26, "Export settings")
  ButtonGadget(#GadgetSettingsImport, 536, 296, 126, 26, "Import settings")
  CloseGadgetList()

  ButtonGadget(#GadgetHideToTray, 14, 512, 96, 28, "Hide")
  ButtonGadget(#GadgetExit, 650, 512, 96, 28, "Exit")

  AddGadgetItem(#GadgetPlanAcBoost, -1, "Disabled")
  AddGadgetItem(#GadgetPlanAcBoost, -1, "Efficient")
  AddGadgetItem(#GadgetPlanAcBoost, -1, "Aggressive")
  AddGadgetItem(#GadgetPlanDcBoost, -1, "Disabled")
  AddGadgetItem(#GadgetPlanDcBoost, -1, "Efficient")
  AddGadgetItem(#GadgetPlanDcBoost, -1, "Aggressive")
  AddGadgetItem(#GadgetPlanAcCooling, -1, "Passive")
  AddGadgetItem(#GadgetPlanAcCooling, -1, "Active")
  AddGadgetItem(#GadgetPlanDcCooling, -1, "Passive")
  AddGadgetItem(#GadgetPlanDcCooling, -1, "Active")

  ; Startup order matters: settings first, then power-event cleanup/logging,
  ; learned drain, retained graph reload, live battery refresh, and plan follow.
  ApplySettingsToGui()
  LogStartupPowerEvents()
  AutoSetInitialBatteryDrainFromLog()
  ApplySettingsToGui()
  WriteBatteryAppEvent("PowerPilot start")
  CleanupOldPowerPilotVersions(#False, #True)
  LoadBatteryGraphFromLog()
  RefreshBatteryStatsSummary()
  RefreshPlanList(#True)
  RefreshPlanEditor()
  RefreshBattery(#True)
  RefreshDisplay(#True)
  MonitorAutomaticPlans()
  RefreshBattery(#True)
  RefreshDisplay(#True)

  If showWindow
    HideWindow(#WindowMain, #False)
    StartRefreshTimer()
  Else
    HideToTray()
  EndIf
EndProcedure

; Main GUI event loop. Closing/minimizing hides to tray; explicit Exit ends.
Procedure RunGui(showWindow.i)
  Protected event.i
  gStartedInTrayMode = Bool(showWindow = #False)
  CreateMainWindow(showWindow)
  Repeat
    event = WaitWindowEvent()
    Select event
      Case #PB_Event_CloseWindow
        HideToTray()
      Case #PB_Event_Gadget
        HandleAction(EventGadget())
      Case #PB_Event_Menu
        HandleMenu(EventMenu())
      Case #PB_Event_SysTray
        If EventType() = #PB_EventType_LeftClick Or EventType() = #PB_EventType_LeftDoubleClick
          ShowFromTray()
        ElseIf EventType() = #PB_EventType_RightClick
          DisplayPopupMenu(#PopupTray, WindowID(#WindowMain))
        EndIf
      Case #PB_Event_Timer
        Select EventTimer()
          Case #TimerRefresh
            ; Tray setup can fail during early startup, so retry quietly on timer.
            If gTrayReady = #False
              SetupTray()
            EndIf
            CaptureBatteryLogColumnWidths(#True)
            MonitorAutomaticPlans()
            RefreshBattery()
            RefreshDisplay()

          Case #TimerBatterySettingsApply
            ApplyPendingBatterySettings()
        EndSelect
      Case #PB_Event_MinimizeWindow
        HideToTray()
    EndSelect
  ForEver
EndProcedure

; Program entry point. Maintenance commands are used by the installer and should
; exit with conventional success/failure codes. No command opens the GUI.
LoadSettings()
gSelectedPlan = PlanIndexByName(gSettings\LastPlan)
If gSelectedPlan < 0 : gSelectedPlan = 1 : EndIf

If CountProgramParameters() > 0
  Select LCase(ProgramParameter(0))
    Case "/create-plans"
      If CreateManagedPlans() : End 0 : Else : End 1 : EndIf
    Case "/cleanup-plans"
      If CleanupManagedPlans() : End 0 : Else : End 1 : EndIf
    Case "/install-refresh"
      If InstallRefresh() : End 0 : Else : End 1 : EndIf
    Case "/cleanup-old-versions"
      If CleanupOldPowerPilotVersions(#True, #False) : End 0 : Else : End 1 : EndIf
    Case "/log-update-close-if-running"
      If LogUpdateCloseIfSameExeRunning() : End 0 : Else : End 1 : EndIf
    Case "/log-update-close-if-powerpilot-running"
      If LogUpdateCloseIfAnyPowerPilotRunning() : End 0 : Else : End 1 : EndIf
    Case "/startup-on"
      gSettings\AutoStartWithApp = #True
      SaveSettings()
      If SetStartupRegistry(#True) : End 0 : Else : End 1 : EndIf
    Case "/startup-off"
      gSettings\AutoStartWithApp = #False
      SaveSettings()
      If SetStartupRegistry(#False) : End 0 : Else : End 1 : EndIf
    Case "/cleanup-settings"
      If CleanupSettingsData() : End 0 : Else : End 1 : EndIf
    Case "/query-keep-settings"
      If gSettings\KeepSettingsOnReinstall : End 1 : Else : End 0 : EndIf
    Case "/follow-once"
      If ApplyWindowsPowerFollow(#True) : End 0 : Else : End 1 : EndIf
    Case "/tray"
      RunGui(#False)
    Case "/show"
      RunGui(#True)
  EndSelect
EndIf

RunGui(#True)

; IDE Options = PureBasic 6.40 (Windows - x64)
; CursorPosition = 1
; EnableThread
