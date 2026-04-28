EnableExplicit

; PowerPilot v1.0
; Windows tray utility for custom power plans and temperature-aware cool-plan control.

#AppName$            = "PowerPilot"
#AppVersion$         = "1.0"
#AppFullName$        = #AppName$ + " v" + #AppVersion$
#AppRunKey$          = "PowerPilot"
#SettingsFolderName$ = "PowerPilot"
#SettingsFileName$   = "settings.ini"
#CustomPlansFileName$ = "custom_plans.tsv"
#TrayTooltip$        = #AppFullName$

#PowerSourceUnknown = 0
#PowerSourceBattery = 1
#PowerSourcePlugged = 2

#PlanPrefixNew$   = "PowerPilot "
#PlanPrefixOld$   = "Codex "
#PlanVisible$     = "PowerPilot"
#PlanBattery$     = "PowerPilot Battery Saver"
#PlanPlugged$     = "PowerPilot Plugged In"
#PlanGame12$      = "PowerPilot Cool 12W"
#PlanGame15$      = "PowerPilot Cool 15W"
#PlanGame18$      = "PowerPilot Cool 18W"
#PlanGame21$      = "PowerPilot Cool 21W"
#PlanGame24$      = "PowerPilot Cool 24W"
#PlanFull$        = "PowerPilot Full Power"

#LegacyPlanBattery$ = "Codex Battery Saver"
#LegacyPlanPlugged$ = "Codex Plugged In"
#LegacyPlanGame12$  = "Codex GameCool 12W"
#LegacyPlanGame15$  = "Codex GameCool 15W"
#LegacyPlanGame18$  = "Codex GameCool 18W"
#LegacyPlanGame21$  = "Codex GameCool 21W"
#LegacyPlanGame24$  = "Codex GameCool 24W"
#LegacyPlanFull$    = "Codex Full Power"

#FILE_MAP_READ    = $0004
#HKEY_LOCAL_MACHINE = $80000002
#KEY_READ         = $20019
#REG_SZ           = 1
#REG_EXPAND_SZ    = 2
#NIM_ADD          = 0
#NIM_MODIFY       = 1
#NIM_DELETE       = 2
#NIF_MESSAGE      = $00000001
#NIF_ICON         = $00000002
#NIF_TIP          = $00000004
#WM_APP           = $8000
#WM_SETREDRAW     = $000B
#WM_SETICON       = $0080
#WM_CONTEXTMENU   = $007B
#WM_LBUTTONUP     = $0202
#WM_LBUTTONDBLCLK = $0203
#WM_RBUTTONUP     = $0205
#EM_LINESCROLL    = $00B6
#EM_GETFIRSTVISIBLELINE = $00CE
#TrayCallbackMsg  = #WM_APP + 77
#SW_SHOW          = 5
#SW_RESTORE       = 9
#HWND_TOPMOST     = -1
#HWND_NOTOPMOST   = -2
#SWP_NOMOVE       = $0002
#SWP_NOSIZE       = $0001
#SWP_NOACTIVATE   = $0010
#VK_CONTROL       = $11
#VK_SHIFT         = $10
#VK_LWIN          = $5B
#VK_B             = $42
#KEYEVENTF_KEYUP  = $0002

#WindowMain       = 1
#WindowTray       = 2
#WindowDependency = 3
#ImageTrayMain    = 1
#TrayIconMain     = 1
#PopupTray        = 1
#StateMutex       = 1

#TimerUiRefresh   = 1
#UiRefreshMs      = 500
#UiLogLineCount   = 8
#DefaultGameCoolAverageSeconds = 10 ; Auto Cool control uses this average window by default. Overview and Live Telemetry stay on current snapshots.
#TelemetryHistorySize = 24
#TelemetryLatchGracePolls = 3
#TelemetryLatchMinimumMs = 15000
#TelemetryLatchMaximumMs = 120000
#MinimumMeaningfulPowerW = 0.05

#PDH_MORE_DATA    = $800007D2
#PDH_CSTATUS_VALID_DATA = 0
#PDH_CSTATUS_NEW_DATA = 1
#PDH_FMT_DOUBLE   = $00000200
#WinCounterCpu    = 1
#WinCounterGpu    = 2
#WinCounterMem    = 3
#WinCounterTempHp = 4
#WinCounterTemp   = 5

Enumeration 100
  #MenuOpen
  #MenuToggleAuto
  #MenuAutoOnce
  #MenuBattery
  #MenuPlugged
  #MenuFull
  #MenuDependencies
  #MenuCreatePlans
  #MenuCleanupPlans
  #MenuExit
EndEnumeration

Enumeration 200
  #GadgetMainPanel
  #GadgetOverviewSourceValue
  #GadgetOverviewTempSensorValue
  #GadgetOverviewTempValue
  #GadgetOverviewGpuLoadValue
  #GadgetOverviewApuPowerValue
  #GadgetOverviewGpuMemoryValue
  #GadgetOverviewGpuPowerValue
  #GadgetOverviewCpuPowerValue
  #GadgetOverviewPowerValue
  #GadgetOverviewPlanValue
  #GadgetOverviewGameStateValue
  #GadgetSourceValue
  #GadgetSensorValue
  #GadgetTempValue
  #GadgetCpuPowerValue
  #GadgetGpuPowerValue
  #GadgetGpuLoadValue
  #GadgetGpuMemoryValue
  #GadgetPowerValue
  #GadgetGameStateValue
  #GadgetPlanValue
  #GadgetLiveBlendSourceMix
  #GadgetLiveBlendTempSensor
  #GadgetLiveBlendTemp
  #GadgetLiveBlendCpu
  #GadgetLiveBlendApu
  #GadgetLiveBlendGpuPower
  #GadgetLiveBlendGpuLoad
  #GadgetLiveBlendGpuMemory
  #GadgetLiveBlendPowerSource
  #GadgetLiveBlendActivePlan
  #GadgetLiveBlendGameState
  #GadgetLiveFallbackStatus
  #GadgetActionValue
  #GadgetOverviewHardwareDetails
  #GadgetAutoEnabled
  #GadgetAutoDetectGame
  #GadgetUseWindows
  #GadgetWindowsInfo
  #GadgetUsePowerControl
  #GadgetAutoStart
  #GadgetKeepSettings
  #GadgetAutoBatteryPlan
  #GadgetPollSpin
  #GadgetHysteresisSpin
  #GadgetPowerHysteresisSpin
  #GadgetCpuPowerTarget
  #GadgetGpuPowerTarget
  #GadgetGpuLoadThreshold
  #GadgetGameCoolAverage
  #GadgetGameStartDelay
  #GadgetGameStopDelay
  #GadgetThresholdFull24
  #GadgetThreshold2421
  #GadgetThreshold2118
  #GadgetThreshold1815
  #GadgetThreshold1512
  #GadgetPlanList
  #GadgetPlanEditorName
  #GadgetPlanEditorPreset
  #GadgetPlanEditorLoadPreset
  #GadgetPlanEditorSave
  #GadgetPlanEditorNew
  #GadgetPlanEditorDelete
  #GadgetPlanEditorSummary
  #GadgetPlanAcEpp
  #GadgetPlanAcBoost
  #GadgetPlanAcState
  #GadgetPlanAcFreq
  #GadgetPlanAcCooling
  #GadgetPlanDcEpp
  #GadgetPlanDcBoost
  #GadgetPlanDcState
  #GadgetPlanDcFreq
  #GadgetPlanDcCooling
  #GadgetPlanRefreshAll
  #GadgetPlanRemoveAll
  #GadgetPlanCombo
  #GadgetActivatePlan
  #GadgetAutoOnce
  #GadgetResetDisplay
  #GadgetSaveSettings
  #GadgetDependencies
  #GadgetHideToTray
  #GadgetExit
  #GadgetStatusLine
  #GadgetDependencyInfo
  #GadgetDependencySummary
  #GadgetDependencyRefresh
  #GadgetDependencyCopy
  #GadgetDependencyLaunch
  #GadgetDependencyClose
EndEnumeration

Structure TempReading
  valid.i
  source.s
  sensor.s
  celsius.d
  windowsTempValid.i
  windowsTempSensor.s
  windowsTempCelsius.d
  cpuPackageValid.i
  cpuPackageSensor.s
  cpuPackageWatts.d
  apuPowerValid.i
  apuPowerSensor.s
  apuPowerWatts.d
  gpuPowerValid.i
  gpuPowerSensor.s
  gpuPowerWatts.d
  gpuLoadValid.i
  gpuLoadSensor.s
  gpuLoadPct.d
  gpuMemoryValid.i
  gpuMemorySensor.s
  gpuMemoryMb.d
  gpuSharedMemoryValid.i
  gpuSharedMemorySensor.s
  gpuSharedMemoryMb.d
  gpuDeviceNames.s
  gameDetected.i
  gameReason.s
EndStructure

Structure TelemetryLatchState
  Last.TempReading
  TempTick.q
  PreviousTempTick.q
  WindowsTempTick.q
  PreviousWindowsTempTick.q
  CpuPowerTick.q
  PreviousCpuPowerTick.q
  ApuPowerTick.q
  PreviousApuPowerTick.q
  GpuPowerTick.q
  PreviousGpuPowerTick.q
  GpuLoadTick.q
  PreviousGpuLoadTick.q
  GpuMemoryTick.q
  PreviousGpuMemoryTick.q
EndStructure

Structure AppSettings
  AutoEnabled.i
  AutoDetectGame.i
  UseWindows.i
  UsePowerControl.i
  AutoStartWithApp.i
  KeepSettingsOnReinstall.i
  AutoBatteryPlan.i
  PollSeconds.i
  Hysteresis.i
  PowerHysteresis.i
  CpuPowerTarget.i
  GpuPowerTarget.i
  GpuLoadThreshold.i
  GameCoolAverageSeconds.i
  GameStartDelay.i
  GameStopDelay.i
  ThresholdFull24.i
  Threshold2421.i
  Threshold2118.i
  Threshold1815.i
  Threshold1512.i
  LastPluggedPlan.s
  LastDgpuPluggedPlan.s
  CurrentManagedPlan.s
EndStructure

Structure RuntimeState
  LastTemp.TempReading
  LastControl.TempReading
  LastWindows.TempReading
  LastFallback.TempReading
  ActivePlan.s
  LastAction.s
  PowerSource.i
  AutoEnabled.i
  AutoDetectGame.i
  StopWorker.i
  WorkerRunning.i
  ImmediateRefresh.i
EndStructure

Structure DependencyStatus
  WindowsEnabled.i
  WindowsTelemetryReady.i
  WindowsTempReady.i
  WindowsPowerReady.i
  WindowsGpuReady.i
  FallbackAvailable.i
  ManagedPlansReady.i
  SensorReady.i
  SensorSource.s
  SensorName.s
EndStructure

Structure PlanDefinition
  Name.s
  BuiltIn.i
  DefaultInstalled.i
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

Structure PDH_FMT_COUNTERVALUE_DOUBLE
  CStatus.l
  Padding.l
  doubleValue.d
EndStructure

Structure DoubleHolder
  value.d
EndStructure

Structure WindowsCounterEntry
  kind.i
  path.s
  handle.i
EndStructure

Prototype.i PdhOpenQueryProto(szDataSource.i, dwUserData.i, *phQuery.Integer)
Prototype.i PdhAddEnglishCounterProto(hQuery.i, szFullCounterPath.p-unicode, dwUserData.i, *phCounter.Integer)
Prototype.i PdhCollectQueryDataProto(hQuery.i)
Prototype.i PdhGetFormattedCounterValueProto(hCounter.i, dwFormat.l, *lpdwType.Long, *pValue.PDH_FMT_COUNTERVALUE_DOUBLE)
Prototype.i PdhExpandWildCardPathProto(szDataSource.i, szWildCardPath.p-unicode, *mszExpandedPathList, *pcchPathListLength.Long, dwFlags.l)
Prototype.i PdhCloseQueryProto(hQuery.i)

Global gSettings.AppSettings
Global gState.RuntimeState
Global gWorkerThread.i
Global gStateMutex.i
Global gTrayStart.i
Global gTrayImage.i
Global gTrayReady.i
Global gTrayIconSmall.i
Global gTrayIconLarge.i
Global gTrayData.NOTIFYICONDATA
Global Dim gUiLogLines.s(#UiLogLineCount - 1)
Global gHelpAlertNeeded.i
Global gCachedDependency.DependencyStatus
Global gLastUiLogText$
Global gLastStatusText$
Global gLastOverviewHardwareText$
Global gLastDependencyInfoText$
Global gLastPlanListSignature$
Global gLastPlanComboSignature$
Global gManualOverrideUntil.i
Global gSelectedPlanName$
Global gEditingNewPlan.i
Global gCachedCpuName$
Global gInstalledMemoryBytes.q
Global NewList gPlanDefs.PlanDefinition()
Global gPdhLibrary.i
Global PdhOpenQueryW.PdhOpenQueryProto
Global PdhAddEnglishCounterW.PdhAddEnglishCounterProto
Global PdhCollectQueryData.PdhCollectQueryDataProto
Global PdhGetFormattedCounterValue.PdhGetFormattedCounterValueProto
Global PdhExpandWildCardPathW.PdhExpandWildCardPathProto
Global PdhCloseQuery.PdhCloseQueryProto
Global Dim gTempSampleTick.q(#TelemetryHistorySize - 1)
Global Dim gTempSampleValue.d(#TelemetryHistorySize - 1)
Global gTempSampleIndex.i
Global gTempLastSource$
Global gTempLastSensor$
Global Dim gCpuPowerSampleTick.q(#TelemetryHistorySize - 1)
Global Dim gCpuPowerSampleValue.d(#TelemetryHistorySize - 1)
Global gCpuPowerSampleIndex.i
Global gCpuPowerLastSensor$
Global Dim gGpuPowerSampleTick.q(#TelemetryHistorySize - 1)
Global Dim gGpuPowerSampleValue.d(#TelemetryHistorySize - 1)
Global gGpuPowerSampleIndex.i
Global gGpuPowerLastSensor$
Global Dim gGpuLoadSampleTick.q(#TelemetryHistorySize - 1)
Global Dim gGpuLoadSampleValue.d(#TelemetryHistorySize - 1)
Global gGpuLoadSampleIndex.i
Global gGpuLoadLastSensor$
Global Dim gGpuMemorySampleTick.q(#TelemetryHistorySize - 1)
Global Dim gGpuMemorySampleValue.d(#TelemetryHistorySize - 1)
Global gGpuMemorySampleIndex.i
Global gGpuMemoryLastSensor$
Global gBlendTelemetryLatch.TelemetryLatchState
Global gWindowsTelemetryLatch.TelemetryLatchState
Global gFallbackTelemetryLatch.TelemetryLatchState
Global gFontBold.i
Global gFontBoldSmall.i
Global gWindowsPerfHelperHandle.i
Global gWindowsPerfHelperIntervalMs.i
Global gWindowsPerfHelperInBlock.i
Global gWindowsPerfHelperCurrentBlock$
Global gWindowsPerfHelperLatestBlock$
Global gWindowsPerfHelperLatestTick.q
Global gLastHelpAlertState.i = -1

Declare ReadDependencyStatus(*status.DependencyStatus)
Declare.s GetCurrentManagedPlan()
Declare.s EnsureScheme(planName$)
Declare.s GetSchemeGuidByName(planName$)
Declare.s GetRememberedDgpuPluggedPlan()
Declare.i ReadWindowsPmiTelemetry(*reading.TempReading)
Declare.i ReadWindowsEmiTelemetry(*reading.TempReading)
Declare RefreshDependencyWindow()
Declare RememberPluggedPlan(planName$, persist.i = #False)
Declare RememberCurrentManagedPlan(planName$, persist.i = #False)
Declare InitializePlanDefinitions()
Declare.i ManagedPlansPresent()
Declare RefreshPlanEditor()
Declare RefreshPlanList()
Declare EnsureSettingsDirectory()
Declare SelectPlanComboByName(planName$)
Declare.s MergeLineLists(baseText$, extraText$)
Declare.s ExtractHardwareNameFromSensor(sensorText$)
Declare.s BuildTelemetrySourceDisplay(*reading.TempReading)
Declare.s CurrentGpuHardwareDisplay(*reading.TempReading)
Declare.s BuildGpuDeviceSummary(*reading.TempReading, *windows.TempReading)
Declare.s CachedCpuName()
Declare.s FormatGpuTelemetryValue(valid.i, valueText$, sensorText$, deviceList$)
Declare.i ActiveDiscreteGpuConnected(*reading.TempReading)
Declare.i IsEstimatedGpuPowerSensor(sensor$)
Declare.s SecondaryFallbackSummary(*reading.TempReading, *windows.TempReading, *fallback.TempReading, *settings.AppSettings)
Declare ResetTempReading(*reading.TempReading)
Declare.i HasUsableTelemetry(*reading.TempReading)
Declare.i HasVisibleTelemetry(*reading.TempReading)
Declare.i CaptureTelemetrySnapshot(*reading.TempReading, *windows.TempReading, *fallback.TempReading)
Declare.s FindBundledWindowsPerfHelper()
Declare.i ReadWindowsPerfStreamTelemetry(*reading.TempReading)
Declare RememberDgpuPluggedPlan(planName$, persist.i = #False)
Declare RememberRuntimeDgpuPlanIfActive(planName$, persist.i = #False)
Declare.i IsGameCoolPlanName(planName$)
Declare.s ResolveIdleRememberedPluggedPlan(*settings.AppSettings)
Declare.s ResolveIdleRememberedDgpuPlan(*settings.AppSettings)
Declare StopWindowsPerfHelper()
Declare ResetTelemetrySmoothing()
Declare ApplyTelemetryAveraging(*reading.TempReading, averageWindowMs.i)
Procedure.s AppDataRoot()
  Protected path$ = GetEnvironmentVariable("APPDATA")
  If path$ = ""
    path$ = GetTemporaryDirectory()
  EndIf
  ProcedureReturn path$
EndProcedure

Procedure.s SettingsDirectory()
  ProcedureReturn AppDataRoot() + "\" + #SettingsFolderName$
EndProcedure

Procedure.s SettingsPath()
  ProcedureReturn SettingsDirectory() + "\" + #SettingsFileName$
EndProcedure

Procedure.s CustomPlansPath()
  ProcedureReturn SettingsDirectory() + "\" + #CustomPlansFileName$
EndProcedure

Procedure.s CleanPlanText(text$)
  text$ = ReplaceString(text$, #CR$, " ")
  text$ = ReplaceString(text$, #LF$, " ")
  text$ = ReplaceString(text$, #TAB$, " ")
  ProcedureReturn Trim(text$)
EndProcedure

Procedure ResetTelemetrySmoothing()
  FillMemory(@gTempSampleTick(), SizeOf(Quad) * #TelemetryHistorySize, 0)
  FillMemory(@gTempSampleValue(), SizeOf(Double) * #TelemetryHistorySize, 0)
  gTempSampleIndex = 0
  gTempLastSource$ = ""
  gTempLastSensor$ = ""

  FillMemory(@gCpuPowerSampleTick(), SizeOf(Quad) * #TelemetryHistorySize, 0)
  FillMemory(@gCpuPowerSampleValue(), SizeOf(Double) * #TelemetryHistorySize, 0)
  gCpuPowerSampleIndex = 0
  gCpuPowerLastSensor$ = ""

  FillMemory(@gGpuPowerSampleTick(), SizeOf(Quad) * #TelemetryHistorySize, 0)
  FillMemory(@gGpuPowerSampleValue(), SizeOf(Double) * #TelemetryHistorySize, 0)
  gGpuPowerSampleIndex = 0
  gGpuPowerLastSensor$ = ""

  FillMemory(@gGpuLoadSampleTick(), SizeOf(Quad) * #TelemetryHistorySize, 0)
  FillMemory(@gGpuLoadSampleValue(), SizeOf(Double) * #TelemetryHistorySize, 0)
  gGpuLoadSampleIndex = 0
  gGpuLoadLastSensor$ = ""

  FillMemory(@gGpuMemorySampleTick(), SizeOf(Quad) * #TelemetryHistorySize, 0)
  FillMemory(@gGpuMemorySampleValue(), SizeOf(Double) * #TelemetryHistorySize, 0)
  gGpuMemorySampleIndex = 0
  gGpuMemoryLastSensor$ = ""
EndProcedure

Procedure ApplyTelemetryAveraging(*reading.TempReading, averageWindowMs.i)
  Protected nowTick.q = ElapsedMilliseconds()
  Protected averageTotal.d
  Protected averageCount.i
  Protected averageIndex.i

  If averageWindowMs < 1000
    averageWindowMs = 1000
  ElseIf averageWindowMs > 60000
    averageWindowMs = 60000
  EndIf

  If *reading\valid
    gTempSampleTick(gTempSampleIndex) = nowTick
    gTempSampleValue(gTempSampleIndex) = *reading\celsius
    gTempLastSensor$ = *reading\sensor
    gTempSampleIndex = (gTempSampleIndex + 1) % #TelemetryHistorySize
  EndIf
  If *reading\valid
    gTempLastSource$ = *reading\source
  EndIf

  If *reading\cpuPackageValid
    gCpuPowerSampleTick(gCpuPowerSampleIndex) = nowTick
    gCpuPowerSampleValue(gCpuPowerSampleIndex) = *reading\cpuPackageWatts
    gCpuPowerLastSensor$ = *reading\cpuPackageSensor
    gCpuPowerSampleIndex = (gCpuPowerSampleIndex + 1) % #TelemetryHistorySize
  EndIf

  If *reading\gpuPowerValid
    gGpuPowerSampleTick(gGpuPowerSampleIndex) = nowTick
    gGpuPowerSampleValue(gGpuPowerSampleIndex) = *reading\gpuPowerWatts
    gGpuPowerLastSensor$ = *reading\gpuPowerSensor
    gGpuPowerSampleIndex = (gGpuPowerSampleIndex + 1) % #TelemetryHistorySize
  EndIf

  If *reading\gpuLoadValid
    gGpuLoadSampleTick(gGpuLoadSampleIndex) = nowTick
    gGpuLoadSampleValue(gGpuLoadSampleIndex) = *reading\gpuLoadPct
    gGpuLoadLastSensor$ = *reading\gpuLoadSensor
    gGpuLoadSampleIndex = (gGpuLoadSampleIndex + 1) % #TelemetryHistorySize
  EndIf

  If *reading\gpuMemoryValid
    gGpuMemorySampleTick(gGpuMemorySampleIndex) = nowTick
    gGpuMemorySampleValue(gGpuMemorySampleIndex) = *reading\gpuMemoryMb
    gGpuMemoryLastSensor$ = *reading\gpuMemorySensor
    gGpuMemorySampleIndex = (gGpuMemorySampleIndex + 1) % #TelemetryHistorySize
  EndIf

  averageTotal = 0.0
  averageCount = 0
  For averageIndex = 0 To #TelemetryHistorySize - 1
    If gTempSampleTick(averageIndex) > 0 And nowTick - gTempSampleTick(averageIndex) <= averageWindowMs
      averageTotal + gTempSampleValue(averageIndex)
      averageCount + 1
    EndIf
  Next
  If averageCount > 0
    *reading\valid = #True
    *reading\celsius = averageTotal / averageCount
    *reading\sensor = gTempLastSensor$
  Else
    *reading\valid = #False
    *reading\celsius = 0.0
    *reading\sensor = "No sensor data"
  EndIf
  If *reading\valid
    *reading\source = gTempLastSource$
  Else
    *reading\source = "Unavailable"
  EndIf

  averageTotal = 0.0
  averageCount = 0
  For averageIndex = 0 To #TelemetryHistorySize - 1
    If gCpuPowerSampleTick(averageIndex) > 0 And nowTick - gCpuPowerSampleTick(averageIndex) <= averageWindowMs
      averageTotal + gCpuPowerSampleValue(averageIndex)
      averageCount + 1
    EndIf
  Next
  If averageCount > 0
    *reading\cpuPackageValid = #True
    *reading\cpuPackageWatts = averageTotal / averageCount
    *reading\cpuPackageSensor = gCpuPowerLastSensor$
  Else
    *reading\cpuPackageValid = #False
    *reading\cpuPackageWatts = 0.0
    *reading\cpuPackageSensor = ""
  EndIf

  averageTotal = 0.0
  averageCount = 0
  For averageIndex = 0 To #TelemetryHistorySize - 1
    If gGpuPowerSampleTick(averageIndex) > 0 And nowTick - gGpuPowerSampleTick(averageIndex) <= averageWindowMs
      averageTotal + gGpuPowerSampleValue(averageIndex)
      averageCount + 1
    EndIf
  Next
  If averageCount > 0
    *reading\gpuPowerValid = #True
    *reading\gpuPowerWatts = averageTotal / averageCount
    *reading\gpuPowerSensor = gGpuPowerLastSensor$
  Else
    *reading\gpuPowerValid = #False
    *reading\gpuPowerWatts = 0.0
    *reading\gpuPowerSensor = ""
  EndIf

  averageTotal = 0.0
  averageCount = 0
  For averageIndex = 0 To #TelemetryHistorySize - 1
    If gGpuLoadSampleTick(averageIndex) > 0 And nowTick - gGpuLoadSampleTick(averageIndex) <= averageWindowMs
      averageTotal + gGpuLoadSampleValue(averageIndex)
      averageCount + 1
    EndIf
  Next
  If averageCount > 0
    *reading\gpuLoadValid = #True
    *reading\gpuLoadPct = averageTotal / averageCount
    *reading\gpuLoadSensor = gGpuLoadLastSensor$
  Else
    *reading\gpuLoadValid = #False
    *reading\gpuLoadPct = 0.0
    *reading\gpuLoadSensor = ""
  EndIf

  averageTotal = 0.0
  averageCount = 0
  For averageIndex = 0 To #TelemetryHistorySize - 1
    If gGpuMemorySampleTick(averageIndex) > 0 And nowTick - gGpuMemorySampleTick(averageIndex) <= averageWindowMs
      averageTotal + gGpuMemorySampleValue(averageIndex)
      averageCount + 1
    EndIf
  Next
  If averageCount > 0
    *reading\gpuMemoryValid = #True
    *reading\gpuMemoryMb = averageTotal / averageCount
    *reading\gpuMemorySensor = gGpuMemoryLastSensor$
  Else
    *reading\gpuMemoryValid = #False
    *reading\gpuMemoryMb = 0.0
    *reading\gpuMemorySensor = ""
  EndIf
EndProcedure

Procedure.s BoostModeText(value.i)
  Select value
    Case 0
      ProcedureReturn "Disabled"
    Case 1
      ProcedureReturn "Efficient"
    Case 2
      ProcedureReturn "Aggressive"
  EndSelect

  ProcedureReturn "Custom"
EndProcedure

Procedure.s CoolingPolicyText(value.i)
  If value
    ProcedureReturn "Active"
  EndIf

  ProcedureReturn "Passive"
EndProcedure

Procedure AddPlanDefinition(planName$, builtIn.i, defaultInstalled.i, description$, acEpp.i, acBoost.i, acState.i, acFreq.i, acCooling.i, dcEpp.i, dcBoost.i, dcState.i, dcFreq.i, dcCooling.i)
  AddElement(gPlanDefs())
  gPlanDefs()\Name = CleanPlanText(planName$)
  gPlanDefs()\BuiltIn = builtIn
  gPlanDefs()\DefaultInstalled = defaultInstalled
  gPlanDefs()\Description = CleanPlanText(description$)
  gPlanDefs()\AcEpp = acEpp
  gPlanDefs()\AcBoostMode = acBoost
  gPlanDefs()\AcMaxState = acState
  gPlanDefs()\AcFreqMHz = acFreq
  gPlanDefs()\AcCooling = acCooling
  gPlanDefs()\DcEpp = dcEpp
  gPlanDefs()\DcBoostMode = dcBoost
  gPlanDefs()\DcMaxState = dcState
  gPlanDefs()\DcFreqMHz = dcFreq
  gPlanDefs()\DcCooling = dcCooling
EndProcedure

Procedure ResetBuiltInPlanDefinitions()
  ClearList(gPlanDefs())
  AddPlanDefinition(#PlanBattery$, #True, #True, "Most aggressive unplugged plan. Keeps boost off, raises efficiency preference, lowers CPU demand further, and allows deeper parking for better battery life.", 65, 0, 90, 2800, 0, 90, 0, 80, 2200, 0)
  AddPlanDefinition(#PlanPlugged$, #True, #True, "Balanced plugged-in plan for normal desktop work. Good responsiveness without pushing full performance all the time.", 15, 1, 100, 0, 1, 80, 0, 85, 2500, 0)
  AddPlanDefinition(#PlanGame12$, #True, #True, "Lowest Cool level. Strong CPU cap for quiet operation, heavy GPU use, or very warm rooms.", 85, 0, 45, 1800, 1, 80, 0, 85, 2500, 0)
  AddPlanDefinition(#PlanGame15$, #True, #True, "Light Cool level. Good for lighter GPU-heavy work and heat reduction.", 75, 0, 55, 2200, 1, 80, 0, 85, 2500, 0)
  AddPlanDefinition(#PlanGame18$, #True, #True, "Moderate Cool level. Useful middle point between cooling and performance.", 65, 0, 65, 2600, 1, 80, 0, 85, 2500, 0)
  AddPlanDefinition(#PlanGame21$, #True, #True, "Performance-oriented Cool level with a mild cap for better temperatures.", 55, 0, 75, 3000, 1, 80, 0, 85, 2500, 0)
  AddPlanDefinition(#PlanGame24$, #True, #True, "Highest Cool level before full power. Suits demanding GPU workloads while still keeping some thermal restraint.", 45, 0, 85, 3400, 1, 80, 0, 85, 2500, 0)
  AddPlanDefinition(#PlanFull$, #True, #True, "Maximum plugged-in performance. Leaves frequency open and allows aggressive boosting.", 5, 2, 100, 0, 1, 80, 0, 85, 2500, 0)
EndProcedure

Procedure.i FindPlanDefinition(planName$)
  ForEach gPlanDefs()
    If gPlanDefs()\Name = planName$
      ProcedureReturn #True
    EndIf
  Next

  ProcedureReturn #False
EndProcedure

Procedure.s SanitizeCustomPlanName(planName$)
  planName$ = CleanPlanText(planName$)
  If planName$ = ""
    ProcedureReturn ""
  EndIf
  If planName$ = #PlanVisible$
    ProcedureReturn ""
  EndIf
  If Left(planName$, Len(#PlanPrefixNew$)) <> #PlanPrefixNew$
    planName$ = #PlanPrefixNew$ + planName$
  EndIf
  ProcedureReturn planName$
EndProcedure

Procedure SaveCustomPlanDefinitions()
  Protected file.i
  Protected line$

  EnsureSettingsDirectory()
  file = CreateFile(#PB_Any, CustomPlansPath())
  If file = 0
    ProcedureReturn
  EndIf

  ForEach gPlanDefs()
    If gPlanDefs()\BuiltIn = #False
      line$ = CleanPlanText(gPlanDefs()\Name) + #TAB$ +
              CleanPlanText(gPlanDefs()\Description) + #TAB$ +
              Str(gPlanDefs()\AcEpp) + #TAB$ +
              Str(gPlanDefs()\AcBoostMode) + #TAB$ +
              Str(gPlanDefs()\AcMaxState) + #TAB$ +
              Str(gPlanDefs()\AcFreqMHz) + #TAB$ +
              Str(gPlanDefs()\AcCooling) + #TAB$ +
              Str(gPlanDefs()\DcEpp) + #TAB$ +
              Str(gPlanDefs()\DcBoostMode) + #TAB$ +
              Str(gPlanDefs()\DcMaxState) + #TAB$ +
              Str(gPlanDefs()\DcFreqMHz) + #TAB$ +
              Str(gPlanDefs()\DcCooling)
      WriteStringN(file, line$)
    EndIf
  Next

  CloseFile(file)
EndProcedure

Procedure LoadCustomPlanDefinitions()
  Protected file.i
  Protected line$
  Protected planName$
  Protected description$

  If FileSize(CustomPlansPath()) <= 0
    ProcedureReturn
  EndIf

  file = ReadFile(#PB_Any, CustomPlansPath())
  If file = 0
    ProcedureReturn
  EndIf

  While Eof(file) = 0
    line$ = ReadString(file)
    If CountString(line$, #TAB$) >= 11
      planName$ = SanitizeCustomPlanName(StringField(line$, 1, #TAB$))
      description$ = CleanPlanText(StringField(line$, 2, #TAB$))
      If planName$ <> "" And FindPlanDefinition(planName$) = #False
        AddPlanDefinition(planName$, #False, #False, description$,
                          Val(StringField(line$, 3, #TAB$)),
                          Val(StringField(line$, 4, #TAB$)),
                          Val(StringField(line$, 5, #TAB$)),
                          Val(StringField(line$, 6, #TAB$)),
                          Val(StringField(line$, 7, #TAB$)),
                          Val(StringField(line$, 8, #TAB$)),
                          Val(StringField(line$, 9, #TAB$)),
                          Val(StringField(line$, 10, #TAB$)),
                          Val(StringField(line$, 11, #TAB$)),
                          Val(StringField(line$, 12, #TAB$)))
      EndIf
    EndIf
  Wend

  CloseFile(file)
EndProcedure

Procedure InitializePlanDefinitions()
  ResetBuiltInPlanDefinitions()
  LoadCustomPlanDefinitions()
EndProcedure

Procedure.s InstalledIconPath()
  ProcedureReturn GetPathPart(ProgramFilename()) + "powerpilot.ico"
EndProcedure

Procedure.s InstalledTrayIconPath()
  ProcedureReturn GetPathPart(ProgramFilename()) + "powerpilot_tray.ico"
EndProcedure

Procedure.s SystemIconLibraryPath()
  Protected path$ = GetEnvironmentVariable("WINDIR")
  If path$ = ""
    path$ = "C:\Windows"
  EndIf
  ProcedureReturn path$ + "\System32\imageres.dll"
EndProcedure

Procedure.i InitializePdh()
  If gPdhLibrary = 0
    gPdhLibrary = OpenLibrary(#PB_Any, "pdh.dll")
    If gPdhLibrary
      PdhOpenQueryW = GetFunction(gPdhLibrary, "PdhOpenQueryW")
      PdhAddEnglishCounterW = GetFunction(gPdhLibrary, "PdhAddEnglishCounterW")
      PdhCollectQueryData = GetFunction(gPdhLibrary, "PdhCollectQueryData")
      PdhGetFormattedCounterValue = GetFunction(gPdhLibrary, "PdhGetFormattedCounterValue")
      PdhExpandWildCardPathW = GetFunction(gPdhLibrary, "PdhExpandWildCardPathW")
      PdhCloseQuery = GetFunction(gPdhLibrary, "PdhCloseQuery")
    EndIf
  EndIf

  If gPdhLibrary = 0 Or PdhOpenQueryW = 0 Or PdhAddEnglishCounterW = 0 Or PdhCollectQueryData = 0 Or PdhGetFormattedCounterValue = 0 Or PdhExpandWildCardPathW = 0 Or PdhCloseQuery = 0
    ProcedureReturn #False
  EndIf

  ProcedureReturn #True
EndProcedure

Procedure.s YesNoText(value.i)
  If value
    ProcedureReturn "Yes"
  EndIf
  ProcedureReturn "No"
EndProcedure

Procedure SetEditorText(gadget.i, text$)
  Protected normalized$ = ReplaceString(text$, #CR$, "")
  Protected lineCount.i
  Protected i.i

  ClearGadgetItems(gadget)
  lineCount = CountString(normalized$, #LF$) + 1
  For i = 1 To lineCount
    AddGadgetItem(gadget, -1, StringField(normalized$, i, #LF$))
  Next
EndProcedure

Procedure EnsureUiFonts()
  If IsFont(gFontBold) = 0
    gFontBold = LoadFont(#PB_Any, "Segoe UI", 11, #PB_Font_Bold)
  EndIf
  If IsFont(gFontBoldSmall) = 0
    gFontBoldSmall = LoadFont(#PB_Any, "Segoe UI", 9, #PB_Font_Bold)
  EndIf
EndProcedure

Procedure.i HandleBelongsToGadget(handle.i, gadget.i)
  Protected gadgetHandle.i = GadgetID(gadget)

  While handle
    If handle = gadgetHandle
      ProcedureReturn #True
    EndIf
    handle = GetParent_(handle)
  Wend

  ProcedureReturn #False
EndProcedure

Procedure.i TelemetryEditorInteractionActive()
  ProcedureReturn #False
EndProcedure

Procedure.s UpdateEditorTextIfNeeded(gadget.i, text$, cachedText$)
  Protected handle.i
  Protected firstVisibleLine.i

  If cachedText$ <> text$ And GetActiveGadget() <> gadget And TelemetryEditorInteractionActive() = #False
    handle = GadgetID(gadget)
    firstVisibleLine = SendMessage_(handle, #EM_GETFIRSTVISIBLELINE, 0, 0)
    SendMessage_(handle, #WM_SETREDRAW, 0, 0)
    SetEditorText(gadget, text$)
    If firstVisibleLine > 0
      SendMessage_(handle, #EM_LINESCROLL, 0, firstVisibleLine)
    EndIf
    SendMessage_(handle, #WM_SETREDRAW, 1, 0)
    InvalidateRect_(handle, 0, #True)
    UpdateWindow_(handle)
    ProcedureReturn text$
  EndIf

  ProcedureReturn cachedText$
EndProcedure

Procedure.i UpdateTextGadgetIfNeeded(gadget.i, text$)
  If IsGadget(gadget) = 0
    ProcedureReturn #False
  EndIf

  If GetGadgetText(gadget) <> text$
    SetGadgetText(gadget, text$)
    ProcedureReturn #True
  EndIf

  ProcedureReturn #False
EndProcedure

Procedure.i UpdateGadgetStateIfNeeded(gadget.i, state.i)
  If IsGadget(gadget) = 0
    ProcedureReturn #False
  EndIf

  If GetGadgetState(gadget) <> state
    SetGadgetState(gadget, state)
    ProcedureReturn #True
  EndIf

  ProcedureReturn #False
EndProcedure

Procedure.i UpdateGadgetDisabledIfNeeded(gadget.i, disabled.i)
  Protected handle.i
  Protected currentlyDisabled.i

  If IsGadget(gadget) = 0
    ProcedureReturn #False
  EndIf

  handle = GadgetID(gadget)
  currentlyDisabled = Bool(IsWindowEnabled_(handle) = 0)
  If currentlyDisabled <> Bool(disabled)
    DisableGadget(gadget, disabled)
    ProcedureReturn #True
  EndIf

  ProcedureReturn #False
EndProcedure

Procedure CopyTempReading(*target.TempReading, *source.TempReading)
  *target\valid = *source\valid
  *target\source = *source\source
  *target\sensor = *source\sensor
  *target\celsius = *source\celsius
  *target\windowsTempValid = *source\windowsTempValid
  *target\windowsTempSensor = *source\windowsTempSensor
  *target\windowsTempCelsius = *source\windowsTempCelsius
  *target\cpuPackageValid = *source\cpuPackageValid
  *target\cpuPackageSensor = *source\cpuPackageSensor
  *target\cpuPackageWatts = *source\cpuPackageWatts
  *target\apuPowerValid = *source\apuPowerValid
  *target\apuPowerSensor = *source\apuPowerSensor
  *target\apuPowerWatts = *source\apuPowerWatts
  *target\gpuPowerValid = *source\gpuPowerValid
  *target\gpuPowerSensor = *source\gpuPowerSensor
  *target\gpuPowerWatts = *source\gpuPowerWatts
  *target\gpuLoadValid = *source\gpuLoadValid
  *target\gpuLoadSensor = *source\gpuLoadSensor
  *target\gpuLoadPct = *source\gpuLoadPct
  *target\gpuMemoryValid = *source\gpuMemoryValid
  *target\gpuMemorySensor = *source\gpuMemorySensor
  *target\gpuMemoryMb = *source\gpuMemoryMb
  *target\gpuSharedMemoryValid = *source\gpuSharedMemoryValid
  *target\gpuSharedMemorySensor = *source\gpuSharedMemorySensor
  *target\gpuSharedMemoryMb = *source\gpuSharedMemoryMb
  *target\gpuDeviceNames = *source\gpuDeviceNames
  *target\gameDetected = *source\gameDetected
  *target\gameReason = *source\gameReason
EndProcedure

Procedure.i HasMeaningfulPowerWatts(watts.d)
  ProcedureReturn Bool(watts > #MinimumMeaningfulPowerW)
EndProcedure

Procedure ResetTempReading(*reading.TempReading)
  *reading\valid = #False
  *reading\source = "Unavailable"
  *reading\sensor = "No sensor data"
  *reading\celsius = 0.0
  *reading\windowsTempValid = #False
  *reading\windowsTempSensor = ""
  *reading\windowsTempCelsius = 0.0
  *reading\cpuPackageValid = #False
  *reading\cpuPackageSensor = ""
  *reading\cpuPackageWatts = 0.0
  *reading\apuPowerValid = #False
  *reading\apuPowerSensor = ""
  *reading\apuPowerWatts = 0.0
  *reading\gpuPowerValid = #False
  *reading\gpuPowerSensor = ""
  *reading\gpuPowerWatts = 0.0
  *reading\gpuLoadValid = #False
  *reading\gpuLoadSensor = ""
  *reading\gpuLoadPct = 0.0
  *reading\gpuMemoryValid = #False
  *reading\gpuMemorySensor = ""
  *reading\gpuMemoryMb = 0.0
  *reading\gpuSharedMemoryValid = #False
  *reading\gpuSharedMemorySensor = ""
  *reading\gpuSharedMemoryMb = 0.0
  *reading\gpuDeviceNames = ""
  *reading\gameDetected = #False
  *reading\gameReason = ""
EndProcedure

Procedure ResetTelemetryLatchState(*state.TelemetryLatchState)
  ResetTempReading(@*state\Last)
  *state\TempTick = 0
  *state\PreviousTempTick = 0
  *state\WindowsTempTick = 0
  *state\PreviousWindowsTempTick = 0
  *state\CpuPowerTick = 0
  *state\PreviousCpuPowerTick = 0
  *state\ApuPowerTick = 0
  *state\PreviousApuPowerTick = 0
  *state\GpuPowerTick = 0
  *state\PreviousGpuPowerTick = 0
  *state\GpuLoadTick = 0
  *state\PreviousGpuLoadTick = 0
  *state\GpuMemoryTick = 0
  *state\PreviousGpuMemoryTick = 0
EndProcedure

Procedure.i TelemetryLatchTimeoutMs()
  Protected timeoutMs.i
  Protected windowVisible.i = #False

  LockMutex(gStateMutex)
  timeoutMs = gSettings\PollSeconds
  UnlockMutex(gStateMutex)

  If timeoutMs < 1
    timeoutMs = 1
  ElseIf timeoutMs > 60
    timeoutMs = 60
  EndIf
  timeoutMs * 1000

  If IsWindow(#WindowMain)
    windowVisible = IsWindowVisible_(WindowID(#WindowMain))
  EndIf
  If windowVisible
    timeoutMs = 1000
  EndIf

  timeoutMs * #TelemetryLatchGracePolls
  If timeoutMs < #TelemetryLatchMinimumMs
    timeoutMs = #TelemetryLatchMinimumMs
  EndIf
  If timeoutMs > #TelemetryLatchMaximumMs
    timeoutMs = #TelemetryLatchMaximumMs
  EndIf

  ProcedureReturn timeoutMs
EndProcedure

Procedure.i TelemetryLatchFresh(lastTick.q, nowTick.q, timeoutMs.i)
  If lastTick <= 0 Or nowTick < lastTick
    ProcedureReturn #False
  EndIf

  ProcedureReturn Bool(nowTick - lastTick <= timeoutMs)
EndProcedure

Procedure.i TelemetryFieldTimeoutMs(lastTick.q, previousTick.q, baseTimeoutMs.i)
  Protected timeoutMs.i = baseTimeoutMs
  Protected intervalMs.q

  If previousTick > 0 And lastTick > previousTick
    intervalMs = lastTick - previousTick
    If intervalMs < 1000
      intervalMs = 1000
    EndIf
    If intervalMs * 4 > timeoutMs
      timeoutMs = intervalMs * 4
    EndIf
  EndIf

  If timeoutMs < #TelemetryLatchMinimumMs
    timeoutMs = #TelemetryLatchMinimumMs
  EndIf
  If timeoutMs > #TelemetryLatchMaximumMs
    timeoutMs = #TelemetryLatchMaximumMs
  EndIf

  ProcedureReturn timeoutMs
EndProcedure

Procedure ApplyTelemetryLatch(*reading.TempReading, *state.TelemetryLatchState)
  Protected nowTick.q = ElapsedMilliseconds()
  Protected baseTimeoutMs.i = TelemetryLatchTimeoutMs()

  LockMutex(gStateMutex)

  If *reading\valid
    *state\Last\valid = #True
    *state\Last\source = *reading\source
    *state\Last\sensor = *reading\sensor
    *state\Last\celsius = *reading\celsius
    *state\PreviousTempTick = *state\TempTick
    *state\TempTick = nowTick
  ElseIf *state\Last\valid And TelemetryLatchFresh(*state\TempTick, nowTick, TelemetryFieldTimeoutMs(*state\TempTick, *state\PreviousTempTick, baseTimeoutMs))
    *reading\valid = #True
    *reading\source = *state\Last\source
    *reading\sensor = *state\Last\sensor
    *reading\celsius = *state\Last\celsius
  EndIf

  If *reading\windowsTempValid
    *state\Last\windowsTempValid = #True
    *state\Last\windowsTempSensor = *reading\windowsTempSensor
    *state\Last\windowsTempCelsius = *reading\windowsTempCelsius
    *state\PreviousWindowsTempTick = *state\WindowsTempTick
    *state\WindowsTempTick = nowTick
  ElseIf *state\Last\windowsTempValid And TelemetryLatchFresh(*state\WindowsTempTick, nowTick, TelemetryFieldTimeoutMs(*state\WindowsTempTick, *state\PreviousWindowsTempTick, baseTimeoutMs))
    *reading\windowsTempValid = #True
    *reading\windowsTempSensor = *state\Last\windowsTempSensor
    *reading\windowsTempCelsius = *state\Last\windowsTempCelsius
  EndIf

  If *reading\cpuPackageValid
    *state\Last\cpuPackageValid = #True
    *state\Last\cpuPackageSensor = *reading\cpuPackageSensor
    *state\Last\cpuPackageWatts = *reading\cpuPackageWatts
    *state\PreviousCpuPowerTick = *state\CpuPowerTick
    *state\CpuPowerTick = nowTick
  ElseIf *state\Last\cpuPackageValid And TelemetryLatchFresh(*state\CpuPowerTick, nowTick, TelemetryFieldTimeoutMs(*state\CpuPowerTick, *state\PreviousCpuPowerTick, baseTimeoutMs))
    *reading\cpuPackageValid = #True
    *reading\cpuPackageSensor = *state\Last\cpuPackageSensor
    *reading\cpuPackageWatts = *state\Last\cpuPackageWatts
  EndIf

  If *reading\apuPowerValid
    *state\Last\apuPowerValid = #True
    *state\Last\apuPowerSensor = *reading\apuPowerSensor
    *state\Last\apuPowerWatts = *reading\apuPowerWatts
    *state\PreviousApuPowerTick = *state\ApuPowerTick
    *state\ApuPowerTick = nowTick
  ElseIf *state\Last\apuPowerValid And TelemetryLatchFresh(*state\ApuPowerTick, nowTick, TelemetryFieldTimeoutMs(*state\ApuPowerTick, *state\PreviousApuPowerTick, baseTimeoutMs))
    *reading\apuPowerValid = #True
    *reading\apuPowerSensor = *state\Last\apuPowerSensor
    *reading\apuPowerWatts = *state\Last\apuPowerWatts
  EndIf

  If *reading\gpuPowerValid
    *state\Last\gpuPowerValid = #True
    *state\Last\gpuPowerSensor = *reading\gpuPowerSensor
    *state\Last\gpuPowerWatts = *reading\gpuPowerWatts
    *state\PreviousGpuPowerTick = *state\GpuPowerTick
    *state\GpuPowerTick = nowTick
  ElseIf *state\Last\gpuPowerValid And TelemetryLatchFresh(*state\GpuPowerTick, nowTick, TelemetryFieldTimeoutMs(*state\GpuPowerTick, *state\PreviousGpuPowerTick, baseTimeoutMs))
    *reading\gpuPowerValid = #True
    *reading\gpuPowerSensor = *state\Last\gpuPowerSensor
    *reading\gpuPowerWatts = *state\Last\gpuPowerWatts
  EndIf

  If *reading\gpuLoadValid
    *state\Last\gpuLoadValid = #True
    *state\Last\gpuLoadSensor = *reading\gpuLoadSensor
    *state\Last\gpuLoadPct = *reading\gpuLoadPct
    *state\PreviousGpuLoadTick = *state\GpuLoadTick
    *state\GpuLoadTick = nowTick
  ElseIf *state\Last\gpuLoadValid And TelemetryLatchFresh(*state\GpuLoadTick, nowTick, TelemetryFieldTimeoutMs(*state\GpuLoadTick, *state\PreviousGpuLoadTick, baseTimeoutMs))
    *reading\gpuLoadValid = #True
    *reading\gpuLoadSensor = *state\Last\gpuLoadSensor
    *reading\gpuLoadPct = *state\Last\gpuLoadPct
  EndIf

  If *reading\gpuMemoryValid
    *state\Last\gpuMemoryValid = #True
    *state\Last\gpuMemorySensor = *reading\gpuMemorySensor
    *state\Last\gpuMemoryMb = *reading\gpuMemoryMb
    *state\Last\gpuSharedMemoryValid = *reading\gpuSharedMemoryValid
    *state\Last\gpuSharedMemorySensor = *reading\gpuSharedMemorySensor
    *state\Last\gpuSharedMemoryMb = *reading\gpuSharedMemoryMb
    *state\PreviousGpuMemoryTick = *state\GpuMemoryTick
    *state\GpuMemoryTick = nowTick
  ElseIf *state\Last\gpuMemoryValid And TelemetryLatchFresh(*state\GpuMemoryTick, nowTick, TelemetryFieldTimeoutMs(*state\GpuMemoryTick, *state\PreviousGpuMemoryTick, baseTimeoutMs))
    *reading\gpuMemoryValid = #True
    *reading\gpuMemorySensor = *state\Last\gpuMemorySensor
    *reading\gpuMemoryMb = *state\Last\gpuMemoryMb
    *reading\gpuSharedMemoryValid = *state\Last\gpuSharedMemoryValid
    *reading\gpuSharedMemorySensor = *state\Last\gpuSharedMemorySensor
    *reading\gpuSharedMemoryMb = *state\Last\gpuSharedMemoryMb
  EndIf

  If *reading\gpuDeviceNames <> ""
    *state\Last\gpuDeviceNames = *reading\gpuDeviceNames
  ElseIf *state\Last\gpuDeviceNames <> ""
    *reading\gpuDeviceNames = *state\Last\gpuDeviceNames
  EndIf

  UnlockMutex(gStateMutex)
EndProcedure

Procedure PushUiLogLine(line$)
  Protected i.i

  For i = 0 To #UiLogLineCount - 2
    gUiLogLines(i) = gUiLogLines(i + 1)
  Next
  gUiLogLines(#UiLogLineCount - 1) = line$
EndProcedure

Procedure.s BuildUiLogText()
  Protected text$
  Protected i.i

  For i = 0 To #UiLogLineCount - 1
    If gUiLogLines(i) <> ""
      If text$ <> ""
        text$ + #LF$
      EndIf
      text$ + gUiLogLines(i)
    EndIf
  Next

  If text$ = ""
    text$ = "Ready."
  EndIf

  ProcedureReturn text$
EndProcedure

Procedure UpdateCachedDependencyStatus()
  Protected status.DependencyStatus

  ReadDependencyStatus(@status)

  LockMutex(gStateMutex)
  gCachedDependency\WindowsEnabled = status\WindowsEnabled
  gCachedDependency\WindowsTelemetryReady = status\WindowsTelemetryReady
  gCachedDependency\WindowsTempReady = status\WindowsTempReady
  gCachedDependency\WindowsPowerReady = status\WindowsPowerReady
  gCachedDependency\WindowsGpuReady = status\WindowsGpuReady
  gCachedDependency\FallbackAvailable = status\FallbackAvailable
  gCachedDependency\ManagedPlansReady = status\ManagedPlansReady
  gCachedDependency\SensorReady = status\SensorReady
  gCachedDependency\SensorSource = status\SensorSource
  gCachedDependency\SensorName = status\SensorName
  UnlockMutex(gStateMutex)
EndProcedure

Procedure CacheDependencyStatus(*status.DependencyStatus)

  LockMutex(gStateMutex)
  gCachedDependency\WindowsEnabled = *status\WindowsEnabled
  gCachedDependency\WindowsTelemetryReady = *status\WindowsTelemetryReady
  gCachedDependency\WindowsTempReady = *status\WindowsTempReady
  gCachedDependency\WindowsPowerReady = *status\WindowsPowerReady
  gCachedDependency\WindowsGpuReady = *status\WindowsGpuReady
  gCachedDependency\FallbackAvailable = *status\FallbackAvailable
  gCachedDependency\ManagedPlansReady = *status\ManagedPlansReady
  gCachedDependency\SensorReady = *status\SensorReady
  gCachedDependency\SensorSource = *status\SensorSource
  gCachedDependency\SensorName = *status\SensorName
  UnlockMutex(gStateMutex)
EndProcedure

Procedure CopyCachedDependencyStatus(*status.DependencyStatus)
  LockMutex(gStateMutex)
  *status\WindowsEnabled = gCachedDependency\WindowsEnabled
  *status\WindowsTelemetryReady = gCachedDependency\WindowsTelemetryReady
  *status\WindowsTempReady = gCachedDependency\WindowsTempReady
  *status\WindowsPowerReady = gCachedDependency\WindowsPowerReady
  *status\WindowsGpuReady = gCachedDependency\WindowsGpuReady
  *status\FallbackAvailable = gCachedDependency\FallbackAvailable
  *status\ManagedPlansReady = gCachedDependency\ManagedPlansReady
  *status\SensorReady = gCachedDependency\SensorReady
  *status\SensorSource = gCachedDependency\SensorSource
  *status\SensorName = gCachedDependency\SensorName
  UnlockMutex(gStateMutex)
EndProcedure

Procedure BuildDependencyStatusFromSnapshots(*status.DependencyStatus, *reading.TempReading, *windows.TempReading, *fallback.TempReading, *settings.AppSettings)
  *status\WindowsEnabled = *settings\UseWindows
  *status\WindowsTelemetryReady = HasUsableTelemetry(*windows)
  *status\WindowsTempReady = *windows\windowsTempValid
  *status\WindowsPowerReady = Bool(*windows\cpuPackageValid Or *windows\apuPowerValid Or *windows\gpuPowerValid)
  *status\WindowsGpuReady = Bool(*windows\gpuLoadValid Or *windows\gpuMemoryValid Or *windows\gpuPowerValid)
  *status\FallbackAvailable = Bool(*status\WindowsTelemetryReady = #False And HasUsableTelemetry(*fallback))
  *status\ManagedPlansReady = ManagedPlansPresent()
  *status\SensorReady = #False
  *status\SensorSource = "Unavailable"
  *status\SensorName = "No sensor data"

  If *windows\valid Or *windows\cpuPackageValid Or *windows\apuPowerValid Or *windows\gpuLoadValid Or *windows\gpuMemoryValid
    *status\SensorReady = #True
    If *windows\valid
      *status\SensorSource = *windows\source
      *status\SensorName = *windows\sensor
    ElseIf *windows\cpuPackageValid
      *status\SensorSource = "Power telemetry"
      *status\SensorName = *windows\cpuPackageSensor
    ElseIf *windows\apuPowerValid
      *status\SensorSource = "Power telemetry"
      *status\SensorName = *windows\apuPowerSensor
    ElseIf *windows\gpuLoadValid
      *status\SensorSource = "Performance telemetry"
      *status\SensorName = *windows\gpuLoadSensor
    ElseIf *windows\gpuMemoryValid
      *status\SensorSource = "Performance telemetry"
      *status\SensorName = *windows\gpuMemorySensor
    EndIf
  ElseIf *reading\valid Or *reading\cpuPackageValid Or *reading\apuPowerValid Or *reading\gpuPowerValid Or *reading\gpuLoadValid Or *reading\gpuMemoryValid
    *status\SensorReady = #True
    If *reading\valid
      *status\SensorSource = *reading\source
      *status\SensorName = *reading\sensor
    ElseIf *reading\cpuPackageValid
      *status\SensorSource = "Power telemetry"
      *status\SensorName = *reading\cpuPackageSensor
    ElseIf *reading\apuPowerValid
      *status\SensorSource = "Power telemetry"
      *status\SensorName = *reading\apuPowerSensor
    ElseIf *reading\gpuPowerValid
      *status\SensorSource = "Power telemetry"
      *status\SensorName = *reading\gpuPowerSensor
    ElseIf *reading\gpuLoadValid
      *status\SensorSource = "Performance telemetry"
      *status\SensorName = *reading\gpuLoadSensor
    ElseIf *reading\gpuMemoryValid
      *status\SensorSource = "Performance telemetry"
      *status\SensorName = *reading\gpuMemorySensor
    EndIf
  ElseIf *status\FallbackAvailable
    *status\SensorReady = #True
    *status\SensorSource = *fallback\source
    *status\SensorName = *fallback\sensor
  EndIf
EndProcedure

Procedure EnsureSettingsDirectory()
  If FileSize(SettingsDirectory()) <> -2
    CreateDirectory(SettingsDirectory())
  EndIf
EndProcedure

Procedure AppendRuntimeLog(text$)
  Protected file.i
  Protected path$ = SettingsDirectory() + "\runtime.log"

  EnsureSettingsDirectory()
  file = OpenFile(#PB_Any, path$)
  If file = 0
    file = CreateFile(#PB_Any, path$)
  Else
    FileSeek(file, Lof(file))
  EndIf

  If file
    WriteStringN(file, FormatDate("%yyyy-%mm-%dd %hh:%ii:%ss", Date()) + "  " + text$)
    CloseFile(file)
  EndIf
EndProcedure

Procedure.i ClampInt(value.i, minValue.i, maxValue.i)
  If value < minValue : ProcedureReturn minValue : EndIf
  If value > maxValue : ProcedureReturn maxValue : EndIf
  ProcedureReturn value
EndProcedure

Procedure.d ClampDouble(value.d, minValue.d, maxValue.d)
  If value < minValue : ProcedureReturn minValue : EndIf
  If value > maxValue : ProcedureReturn maxValue : EndIf
  ProcedureReturn value
EndProcedure

Procedure.i PlanDefinitionInstalled(planName$)
  If planName$ = #PlanVisible$
    ProcedureReturn Bool(GetSchemeGuidByName(#PlanVisible$) <> "")
  EndIf

  ProcedureReturn Bool(GetSchemeGuidByName(planName$) <> "")
EndProcedure

Procedure.i IsRememberedPluggedPlanName(planName$)
  Protected builtInAllowed.i

  Select planName$
    Case #PlanPlugged$, #PlanGame12$, #PlanGame15$, #PlanGame18$, #PlanGame21$, #PlanGame24$, #PlanFull$
      builtInAllowed = #True
  EndSelect

  If builtInAllowed
    ProcedureReturn #True
  EndIf

  ForEach gPlanDefs()
    If gPlanDefs()\Name = planName$ And gPlanDefs()\BuiltIn = #False And PlanDefinitionInstalled(planName$)
      ProcedureReturn #True
    EndIf
  Next

  ProcedureReturn #False
EndProcedure

Procedure.i IsSelectableManagedPlanName(planName$)
  If planName$ = #PlanBattery$
    ProcedureReturn #True
  EndIf

  If IsRememberedPluggedPlanName(planName$)
    ProcedureReturn #True
  EndIf

  ProcedureReturn #False
EndProcedure

Procedure.s NormalizeRememberedPluggedPlan(planName$)
  If IsRememberedPluggedPlanName(planName$)
    ProcedureReturn planName$
  EndIf

  ProcedureReturn #PlanPlugged$
EndProcedure

Procedure.s NormalizeDgpuPluggedPlan(planName$)
  If IsRememberedPluggedPlanName(planName$)
    ProcedureReturn planName$
  EndIf

  ProcedureReturn #PlanFull$
EndProcedure

Procedure.i IsGameCoolPlanName(planName$)
  Select planName$
    Case #PlanGame12$, #PlanGame15$, #PlanGame18$, #PlanGame21$, #PlanGame24$
      ProcedureReturn #True
  EndSelect

  ProcedureReturn #False
EndProcedure

Procedure.s ResolveIdleRememberedPluggedPlan(*settings.AppSettings)
  Protected plan$ = NormalizeRememberedPluggedPlan(*settings\LastPluggedPlan)

  If Bool(*settings\AutoEnabled Or *settings\AutoDetectGame) And IsGameCoolPlanName(plan$)
    ProcedureReturn #PlanFull$
  EndIf

  ProcedureReturn plan$
EndProcedure

Procedure.s ResolveIdleRememberedDgpuPlan(*settings.AppSettings)
  Protected plan$ = NormalizeDgpuPluggedPlan(*settings\LastDgpuPluggedPlan)

  If Bool(*settings\AutoEnabled Or *settings\AutoDetectGame) And IsGameCoolPlanName(plan$)
    plan$ = ResolveIdleRememberedPluggedPlan(*settings)
    If plan$ = ""
      plan$ = #PlanFull$
    EndIf
  EndIf

  ProcedureReturn plan$
EndProcedure

Procedure.s NormalizeManagedPlan(planName$)
  If IsSelectableManagedPlanName(planName$)
    ProcedureReturn planName$
  EndIf

  ProcedureReturn #PlanPlugged$
EndProcedure

Procedure.i PlanLevelFromName(planName$)
  Select planName$
    Case #PlanGame12$ : ProcedureReturn 0
    Case #PlanGame15$ : ProcedureReturn 1
    Case #PlanGame18$ : ProcedureReturn 2
    Case #PlanGame21$ : ProcedureReturn 3
    Case #PlanGame24$ : ProcedureReturn 4
    Case #PlanFull$   : ProcedureReturn 5
    Case #PlanPlugged$
      ProcedureReturn 5
  EndSelect

  ProcedureReturn 5
EndProcedure

Procedure.s PlanNameFromLevel(level.i)
  Select ClampInt(level, 0, 5)
    Case 0 : ProcedureReturn #PlanGame12$
    Case 1 : ProcedureReturn #PlanGame15$
    Case 2 : ProcedureReturn #PlanGame18$
    Case 3 : ProcedureReturn #PlanGame21$
    Case 4 : ProcedureReturn #PlanGame24$
  EndSelect

  ProcedureReturn #PlanFull$
EndProcedure

Procedure.i HasPowerTelemetry(*reading.TempReading)
  If *reading\cpuPackageValid Or *reading\gpuPowerValid
    ProcedureReturn #True
  EndIf

  ProcedureReturn #False
EndProcedure

Procedure.i HasUsableTelemetry(*reading.TempReading)
  If *reading\valid Or *reading\cpuPackageValid Or *reading\apuPowerValid Or *reading\gpuPowerValid Or *reading\gpuLoadValid Or *reading\gpuMemoryValid
    ProcedureReturn #True
  EndIf

  ProcedureReturn #False
EndProcedure

Procedure.i HasVisibleTelemetry(*reading.TempReading)
  ProcedureReturn HasUsableTelemetry(*reading)
EndProcedure

Procedure.i NeedsMoreTelemetry(*reading.TempReading)
  If *reading\valid = #False
    ProcedureReturn #True
  EndIf

  If *reading\cpuPackageValid = #False Or *reading\apuPowerValid = #False Or *reading\gpuPowerValid = #False Or *reading\gpuLoadValid = #False Or *reading\gpuMemoryValid = #False
    ProcedureReturn #True
  EndIf

  ProcedureReturn #False
EndProcedure

Procedure.i HasControlTelemetry(*reading.TempReading, *settings.AppSettings)
  If *reading\valid
    ProcedureReturn #True
  EndIf

  If *settings\UsePowerControl And HasPowerTelemetry(*reading)
    ProcedureReturn #True
  EndIf

  ProcedureReturn #False
EndProcedure

Procedure.s BuildGameStateText(*reading.TempReading, *settings.AppSettings)
  If *settings\AutoBatteryPlan And *reading\gameDetected = #False
    If gState\PowerSource = #PowerSourceBattery
      ProcedureReturn "Battery/plugged auto is holding Battery Saver."
    EndIf
    If gState\PowerSource = #PowerSourcePlugged
      ProcedureReturn "Battery/plugged auto is holding Full Power."
    EndIf
  EndIf

  If *settings\AutoEnabled
    If *settings\AutoDetectGame And *reading\gameReason <> ""
      If *reading\gameDetected
        ProcedureReturn "Cool mode active. " + *reading\gameReason
      EndIf
      ProcedureReturn "Armed for GPU load. " + *reading\gameReason
    EndIf

    ProcedureReturn "Automatic Cool control enabled."
  EndIf

  If *settings\AutoDetectGame = #False
    ProcedureReturn "GPU load trigger off."
  EndIf

  If *reading\gameDetected
    If *reading\gameReason <> ""
      ProcedureReturn "GPU load detected. " + *reading\gameReason
    EndIf
    ProcedureReturn "GPU load detected."
  EndIf

  If *reading\gameReason <> ""
    ProcedureReturn "Waiting for GPU load. " + *reading\gameReason
  EndIf

  ProcedureReturn "Waiting for GPU load."
EndProcedure

Procedure.s BuildWindowsInfoText()
  Protected text$

  text$ + "PowerPilot reads live telemetry from Windows first." + #LF$ + #LF$
  text$ + "Leave Windows telemetry enabled for temperature, CPU power, GPU power, GPU load, GPU memory, and GPU device names whenever Windows exposes them." + #LF$
  text$ + "If Windows cannot provide a usable temperature, PowerPilot can still fall back to a generic thermal-zone reading." + #LF$ + #LF$
  text$ + "PowerPilot prefers the documented Windows PMI provider first, then the Windows EMI energy-meter interface, and only uses older Windows power counters when neither modern interface is available." + #LF$
  text$ + "GPU load and GPU memory stay alive through the persistent WMI refresher helper instead of rebuilding those queries on every poll." + #LF$
  text$ + "Brief telemetry gaps hold the last good value until a new reading arrives or the gap grows much longer than the normal polling pattern." + #LF$
  text$ + "On APU systems, Windows APU or GPU power can still be useful even when a dedicated GPU watt reading is not available." + #LF$
  text$ + "GPU power appears only when Windows exposes a usable watt reading for the current GPU."

  ProcedureReturn text$
EndProcedure

Procedure ApplyMainWindowToolTips()
  GadgetToolTip(#GadgetAutoEnabled, "Lets PowerPilot manage Cool plans automatically when usable telemetry is available.")
  GadgetToolTip(#GadgetAutoDetectGame, "When enabled, PowerPilot only enters Cool plans after sustained GPU load is detected.")
  GadgetToolTip(#GadgetUsePowerControl, "Uses CPU and GPU power targets as control input instead of relying on temperature steps alone.")
  GadgetToolTip(#GadgetUseWindows, "Use the native Windows telemetry stack for temperature, CPU power, GPU power, GPU load, GPU memory, and any GPU names Windows exposes.")
  GadgetToolTip(#GadgetWindowsInfo, "Show a short explanation of the telemetry path PowerPilot uses.")
  GadgetToolTip(#GadgetAutoStart, "Starts PowerPilot with Windows and opens only in the tray.")
  GadgetToolTip(#GadgetKeepSettings, "Keeps your settings on reinstall. Leave off if you want reinstall to reset to defaults.")
  GadgetToolTip(#GadgetAutoBatteryPlan, "On battery it holds Battery Saver. On AC it holds Full Power unless sustained GPU load activates the Cool logic.")
  GadgetToolTip(#GadgetPollSpin, "Background polling interval in seconds when the window is hidden.")
  GadgetToolTip(#GadgetHysteresisSpin, "Temperature margin used to avoid fast up/down switching between plans.")
  GadgetToolTip(#GadgetPowerHysteresisSpin, "Power margin used before the CPU/GPU power controller changes plans.")
  GadgetToolTip(#GadgetCpuPowerTarget, "Target CPU power level in watts for power-based control.")
  GadgetToolTip(#GadgetGpuPowerTarget, "Target GPU power level in watts when GPU power telemetry is available.")
  GadgetToolTip(#GadgetGpuLoadThreshold, "GPU load level used to decide when a sustained GPU-heavy workload is active.")
  GadgetToolTip(#GadgetGameCoolAverage, "Averaging window in seconds for Auto Cool decisions. Overview and Live Telemetry stay on current readings.")
  GadgetToolTip(#GadgetGameStartDelay, "How long GPU load must stay above the trigger before Cool mode is considered active.")
  GadgetToolTip(#GadgetGameStopDelay, "How long GPU load must stay below the trigger before Cool mode is considered inactive.")
  GadgetToolTip(#GadgetThresholdFull24, "Temperature threshold for stepping down from Full Power to 24W.")
  GadgetToolTip(#GadgetThreshold2421, "Temperature threshold for stepping down from 24W to 21W.")
  GadgetToolTip(#GadgetThreshold2118, "Temperature threshold for stepping down from 21W to 18W.")
  GadgetToolTip(#GadgetThreshold1815, "Temperature threshold for stepping down from 18W to 15W.")
  GadgetToolTip(#GadgetThreshold1512, "Temperature threshold for stepping down from 15W to 12W.")
  GadgetToolTip(#GadgetPlanList, "Tick a plan to keep it installed. Untick it to remove that plan only. Select a row to edit its settings.")
  GadgetToolTip(#GadgetPlanEditorName, "Custom plan name. Built-in plan names stay fixed so automation logic remains clear.")
  GadgetToolTip(#GadgetPlanEditorSummary, "Short description shown in the plan list so you can quickly remember what a plan is for.")
  GadgetToolTip(#GadgetPlanEditorPreset, "Choose a built-in preset to use as the starting point for a new custom plan or to reload default-style values.")
  GadgetToolTip(#GadgetPlanEditorLoadPreset, "Loads the selected preset values into the editor without changing the installed plans yet.")
  GadgetToolTip(#GadgetPlanAcEpp, "Energy Performance Preference for plugged-in use. Lower values push performance harder; higher values save more power.")
  GadgetToolTip(#GadgetPlanDcEpp, "Energy Performance Preference for battery use. Higher values favor longer battery life.")
  GadgetToolTip(#GadgetPlanAcBoost, "CPU boost mode for plugged-in use. Disabled keeps clocks steadier, Efficient is moderate, Aggressive allows strongest boosting.")
  GadgetToolTip(#GadgetPlanDcBoost, "CPU boost mode for battery use. Disabling boost usually lowers heat and battery drain.")
  GadgetToolTip(#GadgetPlanAcState, "Maximum processor state for plugged-in use. Lower values cap CPU demand and reduce heat.")
  GadgetToolTip(#GadgetPlanDcState, "Maximum processor state for battery use. Lower values trade speed for cooler and longer-running battery behavior.")
  GadgetToolTip(#GadgetPlanAcFreq, "Maximum CPU frequency in MHz for plugged-in use. Set 0 for unlimited.")
  GadgetToolTip(#GadgetPlanDcFreq, "Maximum CPU frequency in MHz for battery use. Set 0 for unlimited.")
  GadgetToolTip(#GadgetPlanAcCooling, "Active uses fans first. Passive lowers CPU demand first.")
  GadgetToolTip(#GadgetPlanDcCooling, "Battery-side cooling policy. Passive is quieter and often better for battery life.")
  GadgetToolTip(#GadgetPlanEditorSave, "Save the selected plan definition. If the plan is installed, its Windows power plan is refreshed immediately.")
  GadgetToolTip(#GadgetPlanEditorNew, "Start a new custom plan from the chosen preset.")
  GadgetToolTip(#GadgetPlanEditorDelete, "Delete the selected custom plan definition and remove its installed Windows plan.")
  GadgetToolTip(#GadgetPlanRefreshAll, "Create or refresh the default built-in PowerPilot plans and any saved custom plans.")
  GadgetToolTip(#GadgetPlanRemoveAll, "Remove all PowerPilot-managed plans from Windows.")
  GadgetToolTip(#GadgetPlanCombo, "Choose the plan to force manually right now.")
  GadgetToolTip(#GadgetActivatePlan, "Turns automation off and keeps the selected plan active until you re-enable automatic control.")
  GadgetToolTip(#GadgetAutoOnce, "Runs one automatic decision using the current rules without changing your checkboxes.")
  GadgetToolTip(#GadgetResetDisplay, "Sends the Windows graphics reset hotkey (Win+Ctrl+Shift+B) so Windows can refresh the display path without a full reboot.")
  GadgetToolTip(#GadgetDependencies, "Open detailed help and telemetry-status explanations.")
  GadgetToolTip(#GadgetSaveSettings, "Writes the current controls to settings.ini.")
  GadgetToolTip(#GadgetHideToTray, "Hide the window and keep PowerPilot running in the tray.")
  GadgetToolTip(#GadgetExit, "Fully close PowerPilot.")
  GadgetToolTip(#GadgetStatusLine, "Short live explanation of what PowerPilot is doing right now.")
EndProcedure

Procedure ApplyDefaultSettings()
  gSettings\AutoEnabled      = #True
  gSettings\AutoDetectGame   = #True
  gSettings\UseWindows       = #True
  gSettings\UsePowerControl  = #True
  gSettings\AutoStartWithApp = #True
  gSettings\KeepSettingsOnReinstall = #False
  gSettings\AutoBatteryPlan  = #True
  gSettings\PollSeconds      = 5
  gSettings\Hysteresis       = 5
  gSettings\PowerHysteresis  = 8
  gSettings\CpuPowerTarget   = 28
  gSettings\GpuPowerTarget   = 65
  gSettings\GpuLoadThreshold = 40
  gSettings\GameCoolAverageSeconds = #DefaultGameCoolAverageSeconds
  gSettings\GameStartDelay   = 10
  gSettings\GameStopDelay    = 20
  gSettings\ThresholdFull24  = 65
  gSettings\Threshold2421    = 72
  gSettings\Threshold2118    = 78
  gSettings\Threshold1815    = 84
  gSettings\Threshold1512    = 90
  gSettings\LastPluggedPlan  = #PlanPlugged$
  gSettings\LastDgpuPluggedPlan = #PlanFull$
  gSettings\CurrentManagedPlan = #PlanPlugged$
EndProcedure

Procedure NormalizeSettings()
  gSettings\PollSeconds      = ClampInt(gSettings\PollSeconds, 1, 60)
  gSettings\Hysteresis       = ClampInt(gSettings\Hysteresis, 1, 20)
  gSettings\PowerHysteresis  = ClampInt(gSettings\PowerHysteresis, 1, 30)
  gSettings\CpuPowerTarget   = ClampInt(gSettings\CpuPowerTarget, 5, 120)
  gSettings\GpuPowerTarget   = ClampInt(gSettings\GpuPowerTarget, 5, 250)
  gSettings\GpuLoadThreshold = ClampInt(gSettings\GpuLoadThreshold, 1, 100)
  gSettings\GameCoolAverageSeconds = ClampInt(gSettings\GameCoolAverageSeconds, 1, 60)
  gSettings\GameStartDelay   = ClampInt(gSettings\GameStartDelay, 2, 120)
  gSettings\GameStopDelay    = ClampInt(gSettings\GameStopDelay, 2, 300)
  gSettings\ThresholdFull24  = ClampInt(gSettings\ThresholdFull24, 45, 100)
  gSettings\Threshold2421    = ClampInt(gSettings\Threshold2421, gSettings\ThresholdFull24 + 1, 105)
  gSettings\Threshold2118    = ClampInt(gSettings\Threshold2118, gSettings\Threshold2421 + 1, 110)
  gSettings\Threshold1815    = ClampInt(gSettings\Threshold1815, gSettings\Threshold2118 + 1, 115)
  gSettings\Threshold1512    = ClampInt(gSettings\Threshold1512, gSettings\Threshold1815 + 1, 120)
  gSettings\LastPluggedPlan  = NormalizeRememberedPluggedPlan(gSettings\LastPluggedPlan)
  gSettings\LastDgpuPluggedPlan = NormalizeDgpuPluggedPlan(gSettings\LastDgpuPluggedPlan)
  gSettings\CurrentManagedPlan = NormalizeManagedPlan(gSettings\CurrentManagedPlan)
EndProcedure

Procedure LoadSettings()
  ApplyDefaultSettings()
  EnsureSettingsDirectory()

  If OpenPreferences(SettingsPath())
    gSettings\AutoEnabled      = ReadPreferenceInteger("AutoEnabled", gSettings\AutoEnabled)
    gSettings\AutoDetectGame   = ReadPreferenceInteger("GpuLoadCoolTrigger", gSettings\AutoDetectGame)
    gSettings\UseWindows       = ReadPreferenceInteger("UseWindows", gSettings\UseWindows)
    gSettings\UsePowerControl  = ReadPreferenceInteger("UsePowerControl", gSettings\UsePowerControl)
    gSettings\AutoStartWithApp = ReadPreferenceInteger("AutoStartWithApp", gSettings\AutoStartWithApp)
    gSettings\KeepSettingsOnReinstall = ReadPreferenceInteger("KeepSettingsOnReinstall", gSettings\KeepSettingsOnReinstall)
    gSettings\AutoBatteryPlan  = ReadPreferenceInteger("AutoBatteryPlan", gSettings\AutoBatteryPlan)
    gSettings\PollSeconds      = ReadPreferenceInteger("PollSeconds", gSettings\PollSeconds)
    gSettings\Hysteresis       = ReadPreferenceInteger("Hysteresis", gSettings\Hysteresis)
    gSettings\PowerHysteresis  = ReadPreferenceInteger("PowerHysteresis", gSettings\PowerHysteresis)
    gSettings\CpuPowerTarget   = ReadPreferenceInteger("CpuPowerTarget", gSettings\CpuPowerTarget)
    gSettings\GpuPowerTarget   = ReadPreferenceInteger("GpuPowerTarget", gSettings\GpuPowerTarget)
    gSettings\GpuLoadThreshold = ReadPreferenceInteger("GpuLoadThreshold", gSettings\GpuLoadThreshold)
    gSettings\GameCoolAverageSeconds = ReadPreferenceInteger("GameCoolAverageSeconds", gSettings\GameCoolAverageSeconds)
    gSettings\GameStartDelay   = ReadPreferenceInteger("GameStartDelay", gSettings\GameStartDelay)
    gSettings\GameStopDelay    = ReadPreferenceInteger("GameStopDelay", gSettings\GameStopDelay)
    gSettings\ThresholdFull24  = ReadPreferenceInteger("ThresholdFull24", gSettings\ThresholdFull24)
    gSettings\Threshold2421    = ReadPreferenceInteger("Threshold2421", gSettings\Threshold2421)
    gSettings\Threshold2118    = ReadPreferenceInteger("Threshold2118", gSettings\Threshold2118)
    gSettings\Threshold1815    = ReadPreferenceInteger("Threshold1815", gSettings\Threshold1815)
    gSettings\Threshold1512    = ReadPreferenceInteger("Threshold1512", gSettings\Threshold1512)
    gSettings\LastPluggedPlan  = ReadPreferenceString("LastPluggedPlan", gSettings\LastPluggedPlan)
    gSettings\LastDgpuPluggedPlan = ReadPreferenceString("LastDgpuPluggedPlan", gSettings\LastDgpuPluggedPlan)
    gSettings\CurrentManagedPlan = ReadPreferenceString("CurrentManagedPlan", gSettings\CurrentManagedPlan)
    ClosePreferences()
  EndIf

  NormalizeSettings()
EndProcedure

Procedure SaveSettings()
  NormalizeSettings()
  EnsureSettingsDirectory()

  If CreatePreferences(SettingsPath())
    WritePreferenceInteger("AutoEnabled", gSettings\AutoEnabled)
    WritePreferenceInteger("GpuLoadCoolTrigger", gSettings\AutoDetectGame)
    WritePreferenceInteger("AutoDetectGame", gSettings\AutoDetectGame)
    WritePreferenceInteger("UseWindows", gSettings\UseWindows)
    WritePreferenceInteger("UsePowerControl", gSettings\UsePowerControl)
    WritePreferenceInteger("AutoStartWithApp", gSettings\AutoStartWithApp)
    WritePreferenceInteger("KeepSettingsOnReinstall", gSettings\KeepSettingsOnReinstall)
    WritePreferenceInteger("AutoBatteryPlan", gSettings\AutoBatteryPlan)
    WritePreferenceInteger("PollSeconds", gSettings\PollSeconds)
    WritePreferenceInteger("Hysteresis", gSettings\Hysteresis)
    WritePreferenceInteger("PowerHysteresis", gSettings\PowerHysteresis)
    WritePreferenceInteger("CpuPowerTarget", gSettings\CpuPowerTarget)
    WritePreferenceInteger("GpuPowerTarget", gSettings\GpuPowerTarget)
    WritePreferenceInteger("GpuLoadThreshold", gSettings\GpuLoadThreshold)
    WritePreferenceInteger("GameCoolAverageSeconds", gSettings\GameCoolAverageSeconds)
    WritePreferenceInteger("GameStartDelay", gSettings\GameStartDelay)
    WritePreferenceInteger("GameStopDelay", gSettings\GameStopDelay)
    WritePreferenceInteger("ThresholdFull24", gSettings\ThresholdFull24)
    WritePreferenceInteger("Threshold2421", gSettings\Threshold2421)
    WritePreferenceInteger("Threshold2118", gSettings\Threshold2118)
    WritePreferenceInteger("Threshold1815", gSettings\Threshold1815)
    WritePreferenceInteger("Threshold1512", gSettings\Threshold1512)
    WritePreferenceString("LastPluggedPlan", gSettings\LastPluggedPlan)
    WritePreferenceString("LastDgpuPluggedPlan", gSettings\LastDgpuPluggedPlan)
    WritePreferenceString("CurrentManagedPlan", gSettings\CurrentManagedPlan)
    ClosePreferences()
  EndIf
EndProcedure

Procedure PullSettingsFromGui()
  gSettings\AutoEnabled      = GetGadgetState(#GadgetAutoEnabled)
  gSettings\AutoDetectGame   = GetGadgetState(#GadgetAutoDetectGame)
  gSettings\UseWindows       = GetGadgetState(#GadgetUseWindows)
  gSettings\UsePowerControl  = GetGadgetState(#GadgetUsePowerControl)
  gSettings\AutoStartWithApp = GetGadgetState(#GadgetAutoStart)
  gSettings\KeepSettingsOnReinstall = GetGadgetState(#GadgetKeepSettings)
  gSettings\AutoBatteryPlan  = GetGadgetState(#GadgetAutoBatteryPlan)
  gSettings\PollSeconds      = GetGadgetState(#GadgetPollSpin)
  gSettings\Hysteresis       = GetGadgetState(#GadgetHysteresisSpin)
  gSettings\PowerHysteresis  = GetGadgetState(#GadgetPowerHysteresisSpin)
  gSettings\CpuPowerTarget   = GetGadgetState(#GadgetCpuPowerTarget)
  gSettings\GpuPowerTarget   = GetGadgetState(#GadgetGpuPowerTarget)
  gSettings\GpuLoadThreshold = GetGadgetState(#GadgetGpuLoadThreshold)
  gSettings\GameCoolAverageSeconds = GetGadgetState(#GadgetGameCoolAverage)
  gSettings\GameStartDelay   = GetGadgetState(#GadgetGameStartDelay)
  gSettings\GameStopDelay    = GetGadgetState(#GadgetGameStopDelay)
  gSettings\ThresholdFull24  = GetGadgetState(#GadgetThresholdFull24)
  gSettings\Threshold2421    = GetGadgetState(#GadgetThreshold2421)
  gSettings\Threshold2118    = GetGadgetState(#GadgetThreshold2118)
  gSettings\Threshold1815    = GetGadgetState(#GadgetThreshold1815)
  gSettings\Threshold1512    = GetGadgetState(#GadgetThreshold1512)
  NormalizeSettings()
EndProcedure

Procedure PushSettingsToGui()
  UpdateGadgetStateIfNeeded(#GadgetAutoEnabled, gSettings\AutoEnabled)
  UpdateGadgetStateIfNeeded(#GadgetAutoDetectGame, gSettings\AutoDetectGame)
  UpdateGadgetStateIfNeeded(#GadgetUseWindows, gSettings\UseWindows)
  UpdateGadgetStateIfNeeded(#GadgetUsePowerControl, gSettings\UsePowerControl)
  UpdateGadgetStateIfNeeded(#GadgetAutoStart, gSettings\AutoStartWithApp)
  UpdateGadgetStateIfNeeded(#GadgetKeepSettings, gSettings\KeepSettingsOnReinstall)
  UpdateGadgetStateIfNeeded(#GadgetAutoBatteryPlan, gSettings\AutoBatteryPlan)
  UpdateGadgetStateIfNeeded(#GadgetPollSpin, gSettings\PollSeconds)
  UpdateGadgetStateIfNeeded(#GadgetHysteresisSpin, gSettings\Hysteresis)
  UpdateGadgetStateIfNeeded(#GadgetPowerHysteresisSpin, gSettings\PowerHysteresis)
  UpdateGadgetStateIfNeeded(#GadgetCpuPowerTarget, gSettings\CpuPowerTarget)
  UpdateGadgetStateIfNeeded(#GadgetGpuPowerTarget, gSettings\GpuPowerTarget)
  UpdateGadgetStateIfNeeded(#GadgetGpuLoadThreshold, gSettings\GpuLoadThreshold)
  UpdateGadgetStateIfNeeded(#GadgetGameCoolAverage, gSettings\GameCoolAverageSeconds)
  UpdateGadgetStateIfNeeded(#GadgetGameStartDelay, gSettings\GameStartDelay)
  UpdateGadgetStateIfNeeded(#GadgetGameStopDelay, gSettings\GameStopDelay)
  UpdateGadgetStateIfNeeded(#GadgetThresholdFull24, gSettings\ThresholdFull24)
  UpdateGadgetStateIfNeeded(#GadgetThreshold2421, gSettings\Threshold2421)
  UpdateGadgetStateIfNeeded(#GadgetThreshold2118, gSettings\Threshold2118)
  UpdateGadgetStateIfNeeded(#GadgetThreshold1815, gSettings\Threshold1815)
  UpdateGadgetStateIfNeeded(#GadgetThreshold1512, gSettings\Threshold1512)
EndProcedure

Procedure LogAction(text$)
  Protected line$ = FormatDate("%hh:%ii:%ss", Date()) + "  " + text$

  LockMutex(gStateMutex)
  gState\LastAction = line$
  PushUiLogLine(line$)
  UnlockMutex(gStateMutex)

  AppendRuntimeLog("LOG " + text$)
EndProcedure

Procedure.s QuoteArgument(value$)
  ProcedureReturn Chr(34) + value$ + Chr(34)
EndProcedure

Procedure.s FirstLine(text$)
  ProcedureReturn Trim(StringField(ReplaceString(text$, #CR$, ""), 1, #LF$))
EndProcedure

Procedure.s RunCapture(program$, arguments$, workingDir$ = "")
  Protected handle.i
  Protected output$
  Protected line$

  handle = RunProgram(program$, arguments$, workingDir$, #PB_Program_Open | #PB_Program_Read | #PB_Program_Hide)
  If handle = 0
    ProcedureReturn ""
  EndIf

  While ProgramRunning(handle)
    While AvailableProgramOutput(handle)
      line$ = ReadProgramString(handle)
      output$ + line$ + #LF$
    Wend
    Delay(5)
  Wend

  While AvailableProgramOutput(handle)
    line$ = ReadProgramString(handle)
    output$ + line$ + #LF$
  Wend

  CloseProgram(handle)
  ProcedureReturn output$
EndProcedure

Procedure.i RunExitCode(program$, arguments$, workingDir$ = "")
  Protected handle.i
  Protected exitCode.i
  Protected line$

  handle = RunProgram(program$, arguments$, workingDir$, #PB_Program_Open | #PB_Program_Read | #PB_Program_Hide)
  If handle = 0
    ProcedureReturn -1
  EndIf

  While ProgramRunning(handle)
    While AvailableProgramOutput(handle)
      line$ = ReadProgramString(handle)
    Wend
    Delay(5)
  Wend

  While AvailableProgramOutput(handle)
    line$ = ReadProgramString(handle)
  Wend

  exitCode = ProgramExitCode(handle)
  CloseProgram(handle)
  ProcedureReturn exitCode
EndProcedure

Procedure.i RunPowerCfg(arguments$)
  ProcedureReturn RunExitCode("powercfg", arguments$)
EndProcedure

Procedure.s RunPowerCfgCapture(arguments$)
  ProcedureReturn RunCapture("powercfg", arguments$)
EndProcedure

Procedure CleanupDetachedWindowsPerfHelpers()
  Protected script$

  script$ = "$currentPid = " + Str(GetCurrentProcessId_()) + "; " +
            "Get-CimInstance Win32_Process -Filter " + QuoteArgument("Name = 'PowerPilotWindowsPerfHelper.exe'") + " | ForEach-Object { " +
            "$parent = Get-Process -Id $_.ParentProcessId -ErrorAction SilentlyContinue; " +
            "if ($null -eq $parent -or ($parent.ProcessName -ne 'PowerPilot_V1.0' -and $_.ParentProcessId -ne $currentPid)) { " +
            "Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue } }"

  RunExitCode("powershell.exe", "-NoProfile -ExecutionPolicy Bypass -Command " + QuoteArgument(script$))
EndProcedure

Procedure.i RunPowerCfgElevated(arguments$)
  Protected psCommand$

  psCommand$ = "& { " +
               "$p = Start-Process -FilePath 'powercfg.exe' -ArgumentList " + QuoteArgument(arguments$) + " -Verb RunAs -WindowStyle Hidden -PassThru -Wait; " +
               "exit $p.ExitCode }"

  ProcedureReturn RunExitCode("powershell.exe", "-NoProfile -ExecutionPolicy Bypass -Command " + QuoteArgument(psCommand$))
EndProcedure

Procedure.i RunTemporaryPowerShell(scriptText$, scriptName$)
  Protected scriptPath$ = SettingsDirectory() + "\" + scriptName$
  Protected file.i
  Protected result.i

  EnsureSettingsDirectory()
  file = CreateFile(#PB_Any, scriptPath$)
  If file = 0
    ProcedureReturn -1
  EndIf

  WriteString(file, scriptText$, #PB_UTF8)
  CloseFile(file)

  result = RunExitCode("powershell.exe", "-NoProfile -ExecutionPolicy Bypass -File " + QuoteArgument(scriptPath$))
  DeleteFile(scriptPath$)
  ProcedureReturn result
EndProcedure

Procedure.s RunTemporaryPowerShellCapture(scriptText$, scriptName$)
  Protected scriptPath$ = SettingsDirectory() + "\" + scriptName$
  Protected file.i
  Protected result$

  EnsureSettingsDirectory()
  file = CreateFile(#PB_Any, scriptPath$)
  If file = 0
    ProcedureReturn ""
  EndIf

  WriteString(file, scriptText$, #PB_UTF8)
  CloseFile(file)

  result$ = RunCapture("powershell.exe", "-NoProfile -ExecutionPolicy Bypass -File " + QuoteArgument(scriptPath$))
  DeleteFile(scriptPath$)
  ProcedureReturn result$
EndProcedure

Procedure TriggerDisplayReset()
  keybd_event_(#VK_LWIN, 0, 0, 0)
  keybd_event_(#VK_CONTROL, 0, 0, 0)
  keybd_event_(#VK_SHIFT, 0, 0, 0)
  keybd_event_(#VK_B, 0, 0, 0)
  Delay(60)
  keybd_event_(#VK_B, 0, #KEYEVENTF_KEYUP, 0)
  keybd_event_(#VK_SHIFT, 0, #KEYEVENTF_KEYUP, 0)
  keybd_event_(#VK_CONTROL, 0, #KEYEVENTF_KEYUP, 0)
  keybd_event_(#VK_LWIN, 0, #KEYEVENTF_KEYUP, 0)
EndProcedure

Procedure.i IsHexChar(char$)
  ProcedureReturn Bool(FindString("0123456789abcdefABCDEF", char$, 1) > 0)
EndProcedure

Procedure.i IsGuidText(text$)
  Protected i.i
  Protected char$

  If Len(text$) <> 36
    ProcedureReturn #False
  EndIf

  For i = 1 To 36
    char$ = Mid(text$, i, 1)
    Select i
      Case 9, 14, 19, 24
        If char$ <> "-"
          ProcedureReturn #False
        EndIf
      Default
        If IsHexChar(char$) = #False
          ProcedureReturn #False
        EndIf
    EndSelect
  Next

  ProcedureReturn #True
EndProcedure

Procedure.s FindGuidInText(text$)
  Protected cleaned$ = ReplaceString(ReplaceString(text$, "{", ""), "}", "")
  Protected i.i
  Protected candidate$

  For i = 1 To Len(cleaned$) - 35
    candidate$ = Mid(cleaned$, i, 36)
    If IsGuidText(candidate$)
      ProcedureReturn LCase(candidate$)
    EndIf
  Next

  ProcedureReturn ""
EndProcedure

Procedure.s GetActiveSchemeGuid()
  ProcedureReturn FindGuidInText(RunPowerCfgCapture("/GETACTIVESCHEME"))
EndProcedure

Procedure.s GetSchemeGuidByName(planName$)
  Protected output$ = ReplaceString(RunPowerCfgCapture("/L"), #CR$, "")
  Protected lines.i = CountString(output$, #LF$) + 1
  Protected i.i
  Protected line$

  For i = 1 To lines
    line$ = Trim(StringField(output$, i, #LF$))
    If FindString(LCase(line$), "(" + LCase(planName$) + ")", 1)
      ProcedureReturn FindGuidInText(line$)
    EndIf
  Next

  ProcedureReturn ""
EndProcedure

Procedure.s GetSchemeNameByGuid(schemeGuid$)
  Protected output$ = ReplaceString(RunPowerCfgCapture("/L"), #CR$, "")
  Protected lines.i = CountString(output$, #LF$) + 1
  Protected i.i
  Protected line$
  Protected planName$

  If schemeGuid$ = ""
    ProcedureReturn ""
  EndIf

  For i = 1 To lines
    line$ = Trim(StringField(output$, i, #LF$))
    If line$ = "" : Continue : EndIf
    If FindString(LCase(line$), LCase(schemeGuid$), 1)
      If FindString(line$, "(", 1) And FindString(line$, ")", 1)
        planName$ = StringField(StringField(line$, 2, "("), 1, ")")
        ProcedureReturn Trim(planName$)
      EndIf
    EndIf
  Next

  ProcedureReturn ""
EndProcedure

Procedure.s GetActiveSchemeName()
  ProcedureReturn GetSchemeNameByGuid(GetActiveSchemeGuid())
EndProcedure

Procedure.i ManagedPlansPresent()
  ProcedureReturn Bool(GetSchemeGuidByName(#PlanVisible$) <> "")
EndProcedure

Procedure.i IsManagedPlanName(planName$)
  If planName$ = #PlanVisible$
    ProcedureReturn #True
  EndIf
  If Left(planName$, Len(#PlanPrefixNew$)) = #PlanPrefixNew$
    ProcedureReturn #True
  EndIf
  If Left(planName$, Len(#PlanPrefixOld$)) = #PlanPrefixOld$
    ProcedureReturn #True
  EndIf
  ProcedureReturn #False
EndProcedure

Procedure.i SetSchemeValue(schemeGuid$, acMode.i, subgroup$, setting$, value.i)
  Protected command$

  If acMode
    command$ = "/SETACVALUEINDEX " + schemeGuid$ + " " + subgroup$ + " " + setting$ + " " + Str(value)
  Else
    command$ = "/SETDCVALUEINDEX " + schemeGuid$ + " " + subgroup$ + " " + setting$ + " " + Str(value)
  EndIf

  ProcedureReturn RunPowerCfg(command$)
EndProcedure

Procedure.i TrySetSchemeValue(schemeGuid$, acMode.i, subgroup$, setting$, value.i)
  SetSchemeValue(schemeGuid$, acMode, subgroup$, setting$, value)
  ProcedureReturn #True
EndProcedure

Procedure.i SetFrequencyCaps(schemeGuid$, acMode.i, mhz.i)
  If SetSchemeValue(schemeGuid$, acMode, "SUB_PROCESSOR", "PROCFREQMAX", mhz) <> 0 : ProcedureReturn #False : EndIf
  If SetSchemeValue(schemeGuid$, acMode, "SUB_PROCESSOR", "PROCFREQMAX1", mhz) <> 0 : ProcedureReturn #False : EndIf
  If SetSchemeValue(schemeGuid$, acMode, "SUB_PROCESSOR", "PROCFREQMAX2", mhz) <> 0 : ProcedureReturn #False : EndIf
  ProcedureReturn #True
EndProcedure

Procedure.i ApplyDcBaseline(schemeGuid$)
  If SetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "PERFEPP", 80) <> 0 : ProcedureReturn #False : EndIf
  If SetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "PERFBOOSTMODE", 0) <> 0 : ProcedureReturn #False : EndIf
  If SetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "PROCTHROTTLEMAX", 85) <> 0 : ProcedureReturn #False : EndIf
  If SetFrequencyCaps(schemeGuid$, #False, 2500) = #False : ProcedureReturn #False : EndIf
  If SetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "SYSCOOLPOL", 0) <> 0 : ProcedureReturn #False : EndIf
  ProcedureReturn #True
EndProcedure

Procedure.i ApplyAcBattery(schemeGuid$)
  If SetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PERFEPP", 65) <> 0 : ProcedureReturn #False : EndIf
  If SetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PERFBOOSTMODE", 0) <> 0 : ProcedureReturn #False : EndIf
  If SetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PROCTHROTTLEMAX", 90) <> 0 : ProcedureReturn #False : EndIf
  If SetFrequencyCaps(schemeGuid$, #True, 2800) = #False : ProcedureReturn #False : EndIf
  If SetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "SYSCOOLPOL", 0) <> 0 : ProcedureReturn #False : EndIf
  ProcedureReturn #True
EndProcedure

Procedure.i ApplyAcPlugged(schemeGuid$)
  If SetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PERFEPP", 15) <> 0 : ProcedureReturn #False : EndIf
  If SetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PERFBOOSTMODE", 1) <> 0 : ProcedureReturn #False : EndIf
  If SetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PROCTHROTTLEMAX", 100) <> 0 : ProcedureReturn #False : EndIf
  If SetFrequencyCaps(schemeGuid$, #True, 0) = #False : ProcedureReturn #False : EndIf
  If SetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "SYSCOOLPOL", 1) <> 0 : ProcedureReturn #False : EndIf
  ProcedureReturn #True
EndProcedure

Procedure.i ApplyAcGame(schemeGuid$, epp.i, maxState.i, mhz.i)
  If SetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PERFEPP", epp) <> 0 : ProcedureReturn #False : EndIf
  If SetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PERFBOOSTMODE", 0) <> 0 : ProcedureReturn #False : EndIf
  If SetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PROCTHROTTLEMAX", maxState) <> 0 : ProcedureReturn #False : EndIf
  If SetFrequencyCaps(schemeGuid$, #True, mhz) = #False : ProcedureReturn #False : EndIf
  If SetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "SYSCOOLPOL", 1) <> 0 : ProcedureReturn #False : EndIf
  ProcedureReturn #True
EndProcedure

Procedure.i ApplyAcFull(schemeGuid$)
  If SetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PERFEPP", 5) <> 0 : ProcedureReturn #False : EndIf
  If SetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PERFBOOSTMODE", 2) <> 0 : ProcedureReturn #False : EndIf
  If SetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PROCTHROTTLEMAX", 100) <> 0 : ProcedureReturn #False : EndIf
  If SetFrequencyCaps(schemeGuid$, #True, 0) = #False : ProcedureReturn #False : EndIf
  If SetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "SYSCOOLPOL", 1) <> 0 : ProcedureReturn #False : EndIf
  ProcedureReturn #True
EndProcedure

Procedure.i DerivedPlanMinState(epp.i, boostMode.i, cooling.i, maxState.i, freqMHz.i)
  Protected minState.i

  If boostMode >= 2
    ProcedureReturn 15
  EndIf
  If boostMode = 1
    ProcedureReturn 8
  EndIf

  If epp >= 90 Or maxState <= 50 Or (freqMHz > 0 And freqMHz <= 1800)
    minState = 0
  ElseIf epp >= 80 Or maxState <= 60 Or (freqMHz > 0 And freqMHz <= 2200)
    minState = 1
  ElseIf epp >= 70 Or maxState <= 70 Or (freqMHz > 0 And freqMHz <= 2600)
    minState = 2
  ElseIf epp >= 60 Or maxState <= 80 Or (freqMHz > 0 And freqMHz <= 3000)
    minState = 3
  Else
    minState = 4
  EndIf

  If cooling = 0 And minState > 0
    minState - 1
  EndIf

  ProcedureReturn minState
EndProcedure

Procedure.i DerivedPlanCoreParkingMin(epp.i, boostMode.i, cooling.i, maxState.i, freqMHz.i)
  Protected parkingMin.i

  If boostMode >= 2
    parkingMin = 100
  ElseIf boostMode = 1
    parkingMin = 85
  ElseIf epp >= 90 Or maxState <= 50 Or (freqMHz > 0 And freqMHz <= 1800)
    parkingMin = 0
  ElseIf epp >= 80 Or maxState <= 60 Or (freqMHz > 0 And freqMHz <= 2200)
    parkingMin = 15
  ElseIf epp >= 70 Or maxState <= 70 Or (freqMHz > 0 And freqMHz <= 2600)
    parkingMin = 30
  ElseIf epp >= 60 Or maxState <= 80 Or (freqMHz > 0 And freqMHz <= 3000)
    parkingMin = 45
  Else
    parkingMin = 60
  EndIf

  If cooling = 0 And parkingMin >= 15
    parkingMin - 15
  EndIf

  ProcedureReturn parkingMin
EndProcedure

Procedure.i ApplyAdvancedProcessorTuning(*plan.PlanDefinition, schemeGuid$)
  Protected dcMinState.i
  Protected acMinState.i
  Protected dcCoreParkingMin.i
  Protected acCoreParkingMin.i

  If *plan = 0
    ProcedureReturn #False
  EndIf

  dcMinState = DerivedPlanMinState(*plan\DcEpp, *plan\DcBoostMode, *plan\DcCooling, *plan\DcMaxState, *plan\DcFreqMHz)
  acMinState = DerivedPlanMinState(*plan\AcEpp, *plan\AcBoostMode, *plan\AcCooling, *plan\AcMaxState, *plan\AcFreqMHz)
  dcCoreParkingMin = DerivedPlanCoreParkingMin(*plan\DcEpp, *plan\DcBoostMode, *plan\DcCooling, *plan\DcMaxState, *plan\DcFreqMHz)
  acCoreParkingMin = DerivedPlanCoreParkingMin(*plan\AcEpp, *plan\AcBoostMode, *plan\AcCooling, *plan\AcMaxState, *plan\AcFreqMHz)

  ; These processor knobs are optional so older systems can still accept the
  ; base plan even if a specific alias is absent. The existing EPP/boost/cooling
  ; values remain the source of truth, and the extra aliases follow them.
  TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PERFEPP1", *plan\AcEpp)
  TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PERFEPP2", *plan\AcEpp)
  TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PROCTHROTTLEMAX1", *plan\AcMaxState)
  TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PROCTHROTTLEMAX2", *plan\AcMaxState)
  TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PROCTHROTTLEMIN", acMinState)
  TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PROCTHROTTLEMIN1", acMinState)
  TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PROCTHROTTLEMIN2", acMinState)
  TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "CPMINCORES", acCoreParkingMin)
  TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "CPMINCORES1", acCoreParkingMin)
  TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PERFAUTONOMOUS", 1)

  TrySetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "PERFEPP1", *plan\DcEpp)
  TrySetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "PERFEPP2", *plan\DcEpp)
  TrySetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "PROCTHROTTLEMAX1", *plan\DcMaxState)
  TrySetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "PROCTHROTTLEMAX2", *plan\DcMaxState)
  TrySetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "PROCTHROTTLEMIN", dcMinState)
  TrySetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "PROCTHROTTLEMIN1", dcMinState)
  TrySetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "PROCTHROTTLEMIN2", dcMinState)
  TrySetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "CPMINCORES", dcCoreParkingMin)
  TrySetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "CPMINCORES1", dcCoreParkingMin)
  TrySetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "PERFAUTONOMOUS", 1)

  ProcedureReturn #True
EndProcedure

Procedure.i ApplyPlanDefinitionToScheme(*plan.PlanDefinition, schemeGuid$)
  If *plan = 0
    ProcedureReturn #False
  EndIf

  If SetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "PERFEPP", *plan\DcEpp) <> 0 : ProcedureReturn #False : EndIf
  If SetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "PERFBOOSTMODE", *plan\DcBoostMode) <> 0 : ProcedureReturn #False : EndIf
  If SetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "PROCTHROTTLEMAX", *plan\DcMaxState) <> 0 : ProcedureReturn #False : EndIf
  If SetFrequencyCaps(schemeGuid$, #False, *plan\DcFreqMHz) = #False : ProcedureReturn #False : EndIf
  If SetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "SYSCOOLPOL", *plan\DcCooling) <> 0 : ProcedureReturn #False : EndIf

  If SetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PERFEPP", *plan\AcEpp) <> 0 : ProcedureReturn #False : EndIf
  If SetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PERFBOOSTMODE", *plan\AcBoostMode) <> 0 : ProcedureReturn #False : EndIf
  If SetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PROCTHROTTLEMAX", *plan\AcMaxState) <> 0 : ProcedureReturn #False : EndIf
  If SetFrequencyCaps(schemeGuid$, #True, *plan\AcFreqMHz) = #False : ProcedureReturn #False : EndIf
  If SetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "SYSCOOLPOL", *plan\AcCooling) <> 0 : ProcedureReturn #False : EndIf
  If ApplyAdvancedProcessorTuning(*plan, schemeGuid$) = #False : ProcedureReturn #False : EndIf

  ProcedureReturn #True
EndProcedure

Procedure.i ConfigureScheme(planName$, schemeGuid$)
  If planName$ = #PlanVisible$
    planName$ = GetCurrentManagedPlan()
  EndIf

  ForEach gPlanDefs()
    If gPlanDefs()\Name = planName$
      ProcedureReturn ApplyPlanDefinitionToScheme(@gPlanDefs(), schemeGuid$)
    EndIf
  Next

  ProcedureReturn #False
EndProcedure

Procedure.s EnsureVisibleScheme()
  ProcedureReturn EnsureScheme(#PlanVisible$)
EndProcedure

Procedure.i SyncVisibleScheme(planName$)
  Protected visibleGuid$ = EnsureVisibleScheme()

  If visibleGuid$ = ""
    LogAction("Failed to create " + #PlanVisible$)
    ProcedureReturn #False
  EndIf

  If ConfigureScheme(planName$, visibleGuid$) = #False
    LogAction("Failed to synchronize " + #PlanVisible$ + " with " + planName$)
    ProcedureReturn #False
  EndIf

  ProcedureReturn #True
EndProcedure

Procedure.s EnsureScheme(planName$)
  Protected guid$ = GetSchemeGuidByName(planName$)

  If guid$ <> ""
    ProcedureReturn guid$
  EndIf

  guid$ = FindGuidInText(RunPowerCfgCapture("/DUPLICATESCHEME SCHEME_BALANCED"))
  If guid$ = ""
    ProcedureReturn ""
  EndIf

  If RunPowerCfg("/CHANGENAME " + guid$ + " " + QuoteArgument(planName$)) <> 0
    ProcedureReturn ""
  EndIf

  ProcedureReturn guid$
EndProcedure

Procedure.i EnsurePlanInstalled(planName$)
  Protected schemeGuid$

  schemeGuid$ = EnsureScheme(planName$)
  If schemeGuid$ = ""
    LogAction("Failed to create " + planName$)
    ProcedureReturn #False
  EndIf

  If ConfigureScheme(planName$, schemeGuid$) = #False
    LogAction("Failed to configure " + planName$)
    ProcedureReturn #False
  EndIf

  ProcedureReturn #True
EndProcedure

Procedure.i RemoveManagedPlanByName(planName$)
  Protected guid$
  Protected activePlan$

  If planName$ = "" Or planName$ = #PlanVisible$
    ProcedureReturn #False
  EndIf

  guid$ = GetSchemeGuidByName(planName$)
  If guid$ = ""
    ProcedureReturn #True
  EndIf

  activePlan$ = GetActiveSchemeName()
  If activePlan$ = planName$ Or (activePlan$ = #PlanVisible$ And GetCurrentManagedPlan() = planName$)
    RunPowerCfg("/SETACTIVE SCHEME_BALANCED")
  EndIf

  If gSettings\CurrentManagedPlan = planName$
    RememberCurrentManagedPlan(#PlanPlugged$, #True)
  EndIf
  If gSettings\LastPluggedPlan = planName$
    RememberPluggedPlan(#PlanPlugged$, #True)
  EndIf
  If gSettings\LastDgpuPluggedPlan = planName$
    RememberDgpuPluggedPlan(#PlanFull$, #True)
  EndIf

  If RunPowerCfg("/DELETE " + guid$) <> 0
    LogAction("Failed to remove " + planName$)
    ProcedureReturn #False
  EndIf

  LogAction("Removed " + planName$)
  ProcedureReturn #True
EndProcedure

Procedure.s BuildPlanComboSignature()
  Protected signature$

  ForEach gPlanDefs()
    If PlanDefinitionInstalled(gPlanDefs()\Name)
      signature$ + gPlanDefs()\Name + #LF$
    EndIf
  Next

  ProcedureReturn signature$
EndProcedure

Procedure.s BuildPlanListSignature()
  Protected signature$

  ForEach gPlanDefs()
    signature$ + gPlanDefs()\Name + "|" +
                 Str(gPlanDefs()\BuiltIn) + "|" +
                 gPlanDefs()\Description + "|" +
                 Str(PlanDefinitionInstalled(gPlanDefs()\Name)) + #LF$
  Next

  ProcedureReturn signature$
EndProcedure

Procedure PopulatePlanCombo()
  Protected selectedName$
  Protected signature$

  If IsGadget(#GadgetPlanCombo) = 0
    ProcedureReturn
  EndIf

  selectedName$ = ""
  If GetGadgetState(#GadgetPlanCombo) >= 0
    selectedName$ = GetGadgetText(#GadgetPlanCombo)
  EndIf

  signature$ = BuildPlanComboSignature()
  If gLastPlanComboSignature$ <> signature$
    ClearGadgetItems(#GadgetPlanCombo)
    ForEach gPlanDefs()
      If PlanDefinitionInstalled(gPlanDefs()\Name)
        AddGadgetItem(#GadgetPlanCombo, -1, gPlanDefs()\Name)
      EndIf
    Next
    gLastPlanComboSignature$ = signature$
  EndIf

  If CountGadgetItems(#GadgetPlanCombo) > 0
    UpdateGadgetStateIfNeeded(#GadgetPlanCombo, 0)
    If selectedName$ <> ""
      SelectPlanComboByName(selectedName$)
    EndIf
  EndIf
EndProcedure

Procedure PopulatePlanPresetCombo()
  If IsGadget(#GadgetPlanEditorPreset) = 0
    ProcedureReturn
  EndIf

  ClearGadgetItems(#GadgetPlanEditorPreset)
  AddGadgetItem(#GadgetPlanEditorPreset, -1, #PlanBattery$)
  AddGadgetItem(#GadgetPlanEditorPreset, -1, #PlanPlugged$)
  AddGadgetItem(#GadgetPlanEditorPreset, -1, #PlanGame12$)
  AddGadgetItem(#GadgetPlanEditorPreset, -1, #PlanGame15$)
  AddGadgetItem(#GadgetPlanEditorPreset, -1, #PlanGame18$)
  AddGadgetItem(#GadgetPlanEditorPreset, -1, #PlanGame21$)
  AddGadgetItem(#GadgetPlanEditorPreset, -1, #PlanGame24$)
  AddGadgetItem(#GadgetPlanEditorPreset, -1, #PlanFull$)
  UpdateGadgetStateIfNeeded(#GadgetPlanEditorPreset, 0)
EndProcedure

Procedure RefreshPlanList()
  Protected row.i
  Protected selectedRow.i = -1
  Protected typeText$
  Protected signature$

  If IsGadget(#GadgetPlanList) = 0
    ProcedureReturn
  EndIf

  signature$ = BuildPlanListSignature()
  If gLastPlanListSignature$ <> signature$
    ClearGadgetItems(#GadgetPlanList)
    row = 0
    ForEach gPlanDefs()
      If gPlanDefs()\BuiltIn
        typeText$ = "Built-in"
      Else
        typeText$ = "Custom"
      EndIf
      AddGadgetItem(#GadgetPlanList, -1, gPlanDefs()\Name + #LF$ + typeText$ + #LF$ + gPlanDefs()\Description)
      If PlanDefinitionInstalled(gPlanDefs()\Name)
        SetGadgetItemState(#GadgetPlanList, row, #PB_ListIcon_Checked)
      EndIf
      row + 1
    Next
    gLastPlanListSignature$ = signature$
  EndIf

  row = 0
  ForEach gPlanDefs()
    If gSelectedPlanName$ = gPlanDefs()\Name
      selectedRow = row
      Break
    EndIf
    row + 1
  Next

  If selectedRow >= 0
    UpdateGadgetStateIfNeeded(#GadgetPlanList, selectedRow)
  ElseIf row > 0
    UpdateGadgetStateIfNeeded(#GadgetPlanList, 0)
    gSelectedPlanName$ = GetGadgetItemText(#GadgetPlanList, 0)
  EndIf
EndProcedure

Procedure RefreshPlanEditor()
  Protected selected$

  If IsGadget(#GadgetPlanEditorName) = 0
    ProcedureReturn
  EndIf

  selected$ = gSelectedPlanName$
  If selected$ = ""
    If FirstElement(gPlanDefs())
      selected$ = gPlanDefs()\Name
      gSelectedPlanName$ = selected$
    EndIf
  EndIf

  ForEach gPlanDefs()
    If gPlanDefs()\Name = selected$
      UpdateTextGadgetIfNeeded(#GadgetPlanEditorName, gPlanDefs()\Name)
      UpdateTextGadgetIfNeeded(#GadgetPlanEditorSummary, gPlanDefs()\Description)
      UpdateGadgetStateIfNeeded(#GadgetPlanAcEpp, gPlanDefs()\AcEpp)
      UpdateGadgetStateIfNeeded(#GadgetPlanAcBoost, gPlanDefs()\AcBoostMode)
      UpdateGadgetStateIfNeeded(#GadgetPlanAcState, gPlanDefs()\AcMaxState)
      UpdateGadgetStateIfNeeded(#GadgetPlanAcFreq, gPlanDefs()\AcFreqMHz)
      UpdateGadgetStateIfNeeded(#GadgetPlanAcCooling, gPlanDefs()\AcCooling)
      UpdateGadgetStateIfNeeded(#GadgetPlanDcEpp, gPlanDefs()\DcEpp)
      UpdateGadgetStateIfNeeded(#GadgetPlanDcBoost, gPlanDefs()\DcBoostMode)
      UpdateGadgetStateIfNeeded(#GadgetPlanDcState, gPlanDefs()\DcMaxState)
      UpdateGadgetStateIfNeeded(#GadgetPlanDcFreq, gPlanDefs()\DcFreqMHz)
      UpdateGadgetStateIfNeeded(#GadgetPlanDcCooling, gPlanDefs()\DcCooling)
      UpdateGadgetDisabledIfNeeded(#GadgetPlanEditorDelete, Bool(gPlanDefs()\BuiltIn))
      UpdateGadgetDisabledIfNeeded(#GadgetPlanEditorName, Bool(gPlanDefs()\BuiltIn))
      gEditingNewPlan = #False
      Break
    EndIf
  Next
EndProcedure

Procedure LoadPlanEditorFromPreset(planName$)
  ForEach gPlanDefs()
    If gPlanDefs()\Name = planName$
      UpdateGadgetStateIfNeeded(#GadgetPlanAcEpp, gPlanDefs()\AcEpp)
      UpdateGadgetStateIfNeeded(#GadgetPlanAcBoost, gPlanDefs()\AcBoostMode)
      UpdateGadgetStateIfNeeded(#GadgetPlanAcState, gPlanDefs()\AcMaxState)
      UpdateGadgetStateIfNeeded(#GadgetPlanAcFreq, gPlanDefs()\AcFreqMHz)
      UpdateGadgetStateIfNeeded(#GadgetPlanAcCooling, gPlanDefs()\AcCooling)
      UpdateGadgetStateIfNeeded(#GadgetPlanDcEpp, gPlanDefs()\DcEpp)
      UpdateGadgetStateIfNeeded(#GadgetPlanDcBoost, gPlanDefs()\DcBoostMode)
      UpdateGadgetStateIfNeeded(#GadgetPlanDcState, gPlanDefs()\DcMaxState)
      UpdateGadgetStateIfNeeded(#GadgetPlanDcFreq, gPlanDefs()\DcFreqMHz)
      UpdateGadgetStateIfNeeded(#GadgetPlanDcCooling, gPlanDefs()\DcCooling)
      UpdateTextGadgetIfNeeded(#GadgetPlanEditorSummary, gPlanDefs()\Description)
      Break
    EndIf
  Next
EndProcedure

Procedure StartNewPlanFromPreset()
  Protected presetName$
  Protected state.i

  state = GetGadgetState(#GadgetPlanEditorPreset)
  If state >= 0
    presetName$ = GetGadgetItemText(#GadgetPlanEditorPreset, state)
  EndIf
  If presetName$ = ""
    presetName$ = #PlanPlugged$
  EndIf

  gSelectedPlanName$ = ""
  gEditingNewPlan = #True
  UpdateTextGadgetIfNeeded(#GadgetPlanEditorName, #PlanPrefixNew$ + "Custom")
  LoadPlanEditorFromPreset(presetName$)
  UpdateGadgetDisabledIfNeeded(#GadgetPlanEditorDelete, #True)
  UpdateGadgetDisabledIfNeeded(#GadgetPlanEditorName, #False)
  LogAction("New plan editor loaded from " + presetName$)
EndProcedure

Procedure SavePlanEditorDefinition()
  Protected targetName$
  Protected existingGuid$
  Protected oldName$

  targetName$ = SanitizeCustomPlanName(GetGadgetText(#GadgetPlanEditorName))
  If gEditingNewPlan = #False And gSelectedPlanName$ <> ""
    targetName$ = gSelectedPlanName$
  EndIf

  If targetName$ = ""
    LogAction("Plan name cannot be empty.")
    ProcedureReturn
  EndIf

  oldName$ = gSelectedPlanName$
  ForEach gPlanDefs()
    If gPlanDefs()\Name = targetName$
      gPlanDefs()\Description = CleanPlanText(GetGadgetText(#GadgetPlanEditorSummary))
      gPlanDefs()\AcEpp = GetGadgetState(#GadgetPlanAcEpp)
      gPlanDefs()\AcBoostMode = GetGadgetState(#GadgetPlanAcBoost)
      gPlanDefs()\AcMaxState = GetGadgetState(#GadgetPlanAcState)
      gPlanDefs()\AcFreqMHz = GetGadgetState(#GadgetPlanAcFreq)
      gPlanDefs()\AcCooling = GetGadgetState(#GadgetPlanAcCooling)
      gPlanDefs()\DcEpp = GetGadgetState(#GadgetPlanDcEpp)
      gPlanDefs()\DcBoostMode = GetGadgetState(#GadgetPlanDcBoost)
      gPlanDefs()\DcMaxState = GetGadgetState(#GadgetPlanDcState)
      gPlanDefs()\DcFreqMHz = GetGadgetState(#GadgetPlanDcFreq)
      gPlanDefs()\DcCooling = GetGadgetState(#GadgetPlanDcCooling)
      SaveCustomPlanDefinitions()
      existingGuid$ = GetSchemeGuidByName(targetName$)
      If existingGuid$ <> ""
        ConfigureScheme(targetName$, existingGuid$)
      EndIf
      gSelectedPlanName$ = targetName$
      RefreshPlanList()
      PopulatePlanCombo()
      RefreshPlanEditor()
      LogAction("Updated plan definition for " + targetName$)
      ProcedureReturn
    EndIf
  Next

  AddPlanDefinition(targetName$, #False, #False, GetGadgetText(#GadgetPlanEditorSummary),
                    GetGadgetState(#GadgetPlanAcEpp),
                    GetGadgetState(#GadgetPlanAcBoost),
                    GetGadgetState(#GadgetPlanAcState),
                    GetGadgetState(#GadgetPlanAcFreq),
                    GetGadgetState(#GadgetPlanAcCooling),
                    GetGadgetState(#GadgetPlanDcEpp),
                    GetGadgetState(#GadgetPlanDcBoost),
                    GetGadgetState(#GadgetPlanDcState),
                    GetGadgetState(#GadgetPlanDcFreq),
                    GetGadgetState(#GadgetPlanDcCooling))
  SaveCustomPlanDefinitions()
  gSelectedPlanName$ = targetName$
  gEditingNewPlan = #False
  RefreshPlanList()
  PopulatePlanCombo()
  RefreshPlanEditor()
  LogAction("Saved new custom plan " + targetName$)
EndProcedure

Procedure DeleteSelectedCustomPlan()
  Protected name$

  name$ = gSelectedPlanName$
  If name$ = ""
    ProcedureReturn
  EndIf

  ForEach gPlanDefs()
    If gPlanDefs()\Name = name$
      If gPlanDefs()\BuiltIn
        LogAction("Built-in plans cannot be deleted.")
        ProcedureReturn
      EndIf
      DeleteElement(gPlanDefs())
      Break
    EndIf
  Next

  RemoveManagedPlanByName(name$)
  SaveCustomPlanDefinitions()
  gSelectedPlanName$ = ""
  gEditingNewPlan = #False
  RefreshPlanList()
  PopulatePlanCombo()
  RefreshPlanEditor()
  LogAction("Deleted custom plan " + name$)
EndProcedure

Procedure.i CreateManagedPlans()
  Protected visibleGuid$
  Protected schemeGuid$

  visibleGuid$ = EnsureVisibleScheme()
  If visibleGuid$ = "" : LogAction("Failed to create " + #PlanVisible$) : ProcedureReturn #False : EndIf

  ForEach gPlanDefs()
    If gPlanDefs()\DefaultInstalled Or gPlanDefs()\BuiltIn = #False
      schemeGuid$ = EnsureScheme(gPlanDefs()\Name)
      If schemeGuid$ = "" : LogAction("Failed to create " + gPlanDefs()\Name) : ProcedureReturn #False : EndIf
      If ConfigureScheme(gPlanDefs()\Name, schemeGuid$) = #False : LogAction("Failed to configure " + gPlanDefs()\Name) : ProcedureReturn #False : EndIf
    EndIf
  Next

  If ConfigureScheme(GetCurrentManagedPlan(), visibleGuid$) = #False : LogAction("Failed to configure " + #PlanVisible$) : ProcedureReturn #False : EndIf
  LogAction("Custom PowerPilot plans are present.")
  ProcedureReturn #True
EndProcedure

Procedure.i CleanupManagedPlans()
  Protected script$
  Protected result$

  script$ = "& { " +
            "$entries = @(); " +
            "powercfg /L | ForEach-Object { " +
            "  if($_ -match '([a-fA-F0-9-]{36}).*\\(([^\\)]+)\\)\\s*(\\*)?') { " +
            "    if($matches[2] -match '^(PowerPilot($| )|Codex )') { " +
            "      $entries += [pscustomobject]@{ Guid = $matches[1]; Active = ($_ -match '\\*') } " +
            "    } " +
            "  } " +
            "}; " +
            "if(($entries | Where-Object { $_.Active }).Count -gt 0) { powercfg /SETACTIVE SCHEME_BALANCED | Out-Null }; " +
            "$entries | ForEach-Object { powercfg /DELETE $_.Guid | Out-Null }; " +
            "Write-Output 'OK' }"

  result$ = RunCapture("powershell.exe", "-NoProfile -ExecutionPolicy Bypass -Command " + QuoteArgument(script$))
  If FindString(result$, "OK", 1)
    LogAction("Managed custom plans removed.")
    ProcedureReturn #True
  EndIf

  LogAction("Failed to remove managed custom plans.")
  ProcedureReturn #False
EndProcedure

Procedure.i ActivatePlanByName(planName$, allowElevation.i = #False)
  Protected guid$
  Protected activeTargetPlan$
  Protected result.i

  If IsSelectableManagedPlanName(planName$)
    RememberCurrentManagedPlan(planName$, #True)

    If SyncVisibleScheme(planName$) = #False
      ProcedureReturn #False
    EndIf

    activeTargetPlan$ = #PlanVisible$
  Else
    activeTargetPlan$ = planName$
  EndIf

  guid$ = GetSchemeGuidByName(activeTargetPlan$)

  If guid$ = ""
    LogAction("Plan not found: " + planName$)
    ProcedureReturn #False
  EndIf

  result = RunPowerCfg("/SETACTIVE " + guid$)
  If result <> 0 And allowElevation
    result = RunPowerCfgElevated("/SETACTIVE " + guid$)
  EndIf

  If result = 0
    LockMutex(gStateMutex)
    If IsSelectableManagedPlanName(planName$)
      gState\ActivePlan = planName$
    Else
      gState\ActivePlan = activeTargetPlan$
    EndIf
    UnlockMutex(gStateMutex)
    LogAction("Activated " + planName$)
    ProcedureReturn #True
  EndIf

  LogAction("Failed to activate " + planName$ + " (exit " + Str(result) + ")")
  ProcedureReturn #False
EndProcedure

Procedure.i DetectPowerSource()
  Protected status.SYSTEM_POWER_STATUS
  If GetSystemPowerStatus_(@status) = 0
    ProcedureReturn #PowerSourceUnknown
  EndIf

  Select status\ACLineStatus
    Case 0 : ProcedureReturn #PowerSourceBattery
    Case 1 : ProcedureReturn #PowerSourcePlugged
  EndSelect

  ProcedureReturn #PowerSourceUnknown
EndProcedure

Procedure.s PowerSourceText(powerSource.i)
  Select powerSource
    Case #PowerSourceBattery : ProcedureReturn "Battery"
    Case #PowerSourcePlugged : ProcedureReturn "Plugged In"
  EndSelect
  ProcedureReturn "Unknown"
EndProcedure

Procedure.i ExpandWindowsCounterPaths(counterPath$, List expandedPaths.s())
  Protected needed.l = 0
  Protected result.i
  Protected *buffer
  Protected *cursor
  Protected onePath$

  ClearList(expandedPaths())
  result = PdhExpandWildCardPathW(0, counterPath$, 0, @needed, 0)
  If needed <= 0
    ProcedureReturn #False
  EndIf

  *buffer = AllocateMemory((needed + 2) * SizeOf(Character))
  If *buffer = 0
    ProcedureReturn #False
  EndIf

  result = PdhExpandWildCardPathW(0, counterPath$, *buffer, @needed, 0)
  If result <> 0
    FreeMemory(*buffer)
    ProcedureReturn #False
  EndIf

  *cursor = *buffer
  While PeekU(*cursor) <> 0
    onePath$ = PeekS(*cursor, -1, #PB_Unicode)
    If onePath$ <> ""
      AddElement(expandedPaths())
      expandedPaths() = onePath$
    EndIf
    *cursor + (Len(onePath$) + 1) * SizeOf(Character)
  Wend

  FreeMemory(*buffer)
  ProcedureReturn Bool(ListSize(expandedPaths()) > 0)
EndProcedure

Procedure.s WindowsCounterInstanceName(counterPath$)
  Protected startPos.i = FindString(counterPath$, "(", 1)
  Protected endPos.i

  If startPos > 0
    endPos = FindString(counterPath$, ")", startPos + 1)
    If endPos > startPos
      ProcedureReturn Mid(counterPath$, startPos + 1, endPos - startPos - 1)
    EndIf
  EndIf

  ProcedureReturn ""
EndProcedure

Procedure.i WindowsCpuCounterScore(instanceName$)
  Protected inst$ = LCase(instanceName$)

  If inst$ = "rapl_package0_pkg" : ProcedureReturn 5000 : EndIf
  If inst$ = "current socket power" : ProcedureReturn 4500 : EndIf
  If inst$ = "apu power" : ProcedureReturn 4200 : EndIf
  If FindString(inst$, "cpu", 1) : ProcedureReturn 3900 : EndIf
  If FindString(inst$, "socket", 1) : ProcedureReturn 3800 : EndIf
  If FindString(inst$, "power", 1) And FindString(inst$, "gpu", 1) = 0 : ProcedureReturn 3400 : EndIf
  If FindString(inst$, "ppt", 1) : ProcedureReturn 3200 : EndIf
  If FindString(inst$, "stapm", 1) : ProcedureReturn 3100 : EndIf
  If FindString(inst$, "pkg", 1) : ProcedureReturn 2500 : EndIf

  ProcedureReturn -1
EndProcedure

Procedure.i WindowsGpuPowerCounterScore(instanceName$)
  Protected inst$ = LCase(instanceName$)

  If inst$ = "vddgfx power" : ProcedureReturn 7000 : EndIf
  If inst$ = "vddcr_gfx power" : ProcedureReturn 6900 : EndIf
  If FindString(inst$, "gfx", 1) : ProcedureReturn 6600 : EndIf
  If FindString(inst$, "gpu", 1) : ProcedureReturn 6300 : EndIf
  If inst$ = "vddcr_soc power" : ProcedureReturn 4200 : EndIf
  If FindString(inst$, "soc", 1) : ProcedureReturn 3200 : EndIf

  ProcedureReturn -1
EndProcedure

Procedure.i WindowsGpuEngineRelevant(instanceName$)
  Protected inst$ = LCase(instanceName$)

  If FindString(inst$, "engtype_3d", 1) : ProcedureReturn #True : EndIf
  If FindString(inst$, "engtype_high priority 3d", 1) : ProcedureReturn #True : EndIf
  If FindString(inst$, "engtype_compute", 1) : ProcedureReturn #True : EndIf
  If FindString(inst$, "engtype_high priority compute", 1) : ProcedureReturn #True : EndIf

  ProcedureReturn #False
EndProcedure

Procedure.i ReadWindowsCounterDouble(counterHandle.i, *out.DoubleHolder)
  Protected fmt.PDH_FMT_COUNTERVALUE_DOUBLE
  Protected counterType.l
  Protected result.i

  result = PdhGetFormattedCounterValue(counterHandle, #PDH_FMT_DOUBLE, @counterType, @fmt)
  If result = 0 And (fmt\CStatus = #PDH_CSTATUS_VALID_DATA Or fmt\CStatus = #PDH_CSTATUS_NEW_DATA)
    *out\value = fmt\doubleValue
    ProcedureReturn #True
  EndIf

  ProcedureReturn #False
EndProcedure

Procedure.i ReadWindowsTelemetry(*reading.TempReading)
  Protected queryHandle.i
  Protected counterHandle.i
  Protected result.i
  Protected cpuBestScore.i = -1
  Protected gpuPowerBestScore.i = -1
  Protected tempBestScore.i = -1
  Protected powerFallbackNeeded.i
  Protected gpuLoadSeen.i
  Protected gpuMemorySeen.i
  Protected value.DoubleHolder
  Protected instanceName$
  Protected tempC.d
  Protected watts.d
  Protected NewList counterPaths.s()
  Protected NewList counters.WindowsCounterEntry()

  ReadWindowsPmiTelemetry(*reading)
  ReadWindowsEmiTelemetry(*reading)
  ReadWindowsPerfStreamTelemetry(*reading)
  powerFallbackNeeded = Bool(*reading\cpuPackageValid = #False Or *reading\apuPowerValid = #False Or *reading\gpuPowerValid = #False)

  If InitializePdh() = #False
    ProcedureReturn HasUsableTelemetry(*reading)
  EndIf

  result = PdhOpenQueryW(0, 0, @queryHandle)
  If result <> 0 Or queryHandle = 0
    ProcedureReturn HasUsableTelemetry(*reading)
  EndIf

  If powerFallbackNeeded And ExpandWindowsCounterPaths("\Energy Meter(*)\Power", counterPaths())
    ForEach counterPaths()
      If PdhAddEnglishCounterW(queryHandle, counterPaths(), 0, @counterHandle) = 0
        AddElement(counters())
        counters()\kind = #WinCounterCpu
        counters()\path = counterPaths()
        counters()\handle = counterHandle
      EndIf
    Next
  EndIf

  If *reading\gpuLoadValid = #False And ExpandWindowsCounterPaths("\GPU Engine(*)\Utilization Percentage", counterPaths())
    ForEach counterPaths()
      If PdhAddEnglishCounterW(queryHandle, counterPaths(), 0, @counterHandle) = 0
        AddElement(counters())
        counters()\kind = #WinCounterGpu
        counters()\path = counterPaths()
        counters()\handle = counterHandle
      EndIf
    Next
  EndIf

  If *reading\gpuMemoryValid = #False And ExpandWindowsCounterPaths("\GPU Adapter Memory(*)\Dedicated Usage", counterPaths())
    ForEach counterPaths()
      If PdhAddEnglishCounterW(queryHandle, counterPaths(), 0, @counterHandle) = 0
        AddElement(counters())
        counters()\kind = #WinCounterMem
        counters()\path = counterPaths()
        counters()\handle = counterHandle
      EndIf
    Next
  EndIf

  If ExpandWindowsCounterPaths("\Thermal Zone Information(*)\High Precision Temperature", counterPaths())
    ForEach counterPaths()
      If PdhAddEnglishCounterW(queryHandle, counterPaths(), 0, @counterHandle) = 0
        AddElement(counters())
        counters()\kind = #WinCounterTempHp
        counters()\path = counterPaths()
        counters()\handle = counterHandle
      EndIf
    Next
  EndIf

  If ExpandWindowsCounterPaths("\Thermal Zone Information(*)\Temperature", counterPaths())
    ForEach counterPaths()
      If PdhAddEnglishCounterW(queryHandle, counterPaths(), 0, @counterHandle) = 0
        AddElement(counters())
        counters()\kind = #WinCounterTemp
        counters()\path = counterPaths()
        counters()\handle = counterHandle
      EndIf
    Next
  EndIf

  If ListSize(counters()) = 0
    PdhCloseQuery(queryHandle)
    ProcedureReturn HasUsableTelemetry(*reading)
  EndIf

  PdhCollectQueryData(queryHandle)
  Delay(150)
  PdhCollectQueryData(queryHandle)

  ForEach counters()
    If ReadWindowsCounterDouble(counters()\handle, @value) = #False
      Continue
    EndIf

    instanceName$ = WindowsCounterInstanceName(counters()\path)

    Select counters()\kind
      Case #WinCounterCpu
        watts = value\value / 1000.0
        If *reading\apuPowerValid = #False And LCase(instanceName$) = "apu power"
          If HasMeaningfulPowerWatts(watts)
            *reading\apuPowerValid = #True
            *reading\apuPowerSensor = "Windows power reading / " + instanceName$
            *reading\apuPowerWatts = watts
          EndIf
        EndIf

        result = WindowsCpuCounterScore(instanceName$)
        If *reading\cpuPackageValid = #False And result >= 0 And HasMeaningfulPowerWatts(watts) And (result > cpuBestScore Or (result = cpuBestScore And value\value > (*reading\cpuPackageWatts * 1000.0)))
          cpuBestScore = result
          *reading\cpuPackageValid = #True
          *reading\cpuPackageSensor = "Windows power reading / " + instanceName$
          *reading\cpuPackageWatts = watts
        EndIf

        result = WindowsGpuPowerCounterScore(instanceName$)
        If *reading\gpuPowerValid = #False And result >= 0 And HasMeaningfulPowerWatts(watts) And (result > gpuPowerBestScore Or (result = gpuPowerBestScore And value\value > (*reading\gpuPowerWatts * 1000.0)))
          gpuPowerBestScore = result
          *reading\gpuPowerValid = #True
          *reading\gpuPowerSensor = "Windows power reading / " + instanceName$
          *reading\gpuPowerWatts = watts
        EndIf

      Case #WinCounterGpu
        If WindowsGpuEngineRelevant(instanceName$)
          gpuLoadSeen = #True
          If *reading\gpuLoadValid = #False Or value\value > *reading\gpuLoadPct
            *reading\gpuLoadValid = #True
            *reading\gpuLoadSensor = "Windows " + instanceName$
            *reading\gpuLoadPct = value\value
          EndIf
        EndIf

      Case #WinCounterMem
        gpuMemorySeen = #True
        If *reading\gpuMemoryValid = #False Or value\value > (*reading\gpuMemoryMb * 1024.0 * 1024.0)
          *reading\gpuMemoryValid = #True
          *reading\gpuMemorySensor = "Windows " + instanceName$
          *reading\gpuMemoryMb = value\value / (1024.0 * 1024.0)
        EndIf

      Case #WinCounterTempHp
        tempC = (value\value / 10.0) - 273.15
        If tempC > -50 And tempC < 150 And (tempBestScore < 2000 Or (tempBestScore = 2000 And tempC > *reading\windowsTempCelsius))
          tempBestScore = 2000
          *reading\windowsTempValid = #True
          *reading\windowsTempSensor = "Windows " + instanceName$
          *reading\windowsTempCelsius = tempC
        EndIf

      Case #WinCounterTemp
        tempC = value\value - 273.15
        If tempC > -50 And tempC < 150 And (tempBestScore < 1000 Or (tempBestScore = 1000 And tempC > *reading\windowsTempCelsius))
          tempBestScore = 1000
          *reading\windowsTempValid = #True
          *reading\windowsTempSensor = "Windows " + instanceName$
          *reading\windowsTempCelsius = tempC
        EndIf
    EndSelect
  Next

  PdhCloseQuery(queryHandle)

  If gpuLoadSeen And *reading\gpuLoadValid = #False
    *reading\gpuLoadValid = #True
    *reading\gpuLoadSensor = "Windows GPU Engine"
    *reading\gpuLoadPct = 0.0
  EndIf

  If gpuMemorySeen And *reading\gpuMemoryValid = #False
    *reading\gpuMemoryValid = #True
    *reading\gpuMemorySensor = "Windows GPU Adapter Memory"
    *reading\gpuMemoryMb = 0.0
  EndIf

  If *reading\windowsTempValid
    *reading\valid = #True
    *reading\source = "Windows Performance Counters"
    *reading\sensor = *reading\windowsTempSensor
    *reading\celsius = *reading\windowsTempCelsius
  EndIf

  ProcedureReturn Bool(*reading\windowsTempValid Or *reading\cpuPackageValid Or *reading\apuPowerValid Or *reading\gpuPowerValid Or *reading\gpuLoadValid Or *reading\gpuMemoryValid)
EndProcedure

Procedure.i ReadFallbackSensor(*reading.TempReading)
  Protected code$
  Protected line$

  code$ = "& { " +
          "$ErrorActionPreference='SilentlyContinue'; " +
          "try { " +
          "  $zones = Get-WmiObject -Namespace 'root\\WMI' -Class 'MSAcpi_ThermalZoneTemperature'; " +
          "  if($zones) { $hot = $zones | ForEach-Object { New-Object psobject -Property @{ Name = $_.InstanceName; Value = (([double]$_.CurrentTemperature / 10) - 273.15) } } | Sort-Object Value -Descending | Select-Object -First 1; if($hot) { Write-Output ('ACPI|' + $hot.Name + '|' + [string]([math]::Round([double]$hot.Value,1))); exit 0 } } " +
          "} catch {} " +
          "exit 1 }"

  line$ = FirstLine(RunCapture("powershell.exe", "-NoProfile -ExecutionPolicy Bypass -Command " + QuoteArgument(code$)))

  If Left(line$, 5) = "ACPI|"
    *reading\valid = #True
    *reading\source = "ACPI Thermal Zone"
    *reading\sensor = StringField(line$, 2, "|")
    *reading\celsius = ValD(StringField(line$, 3, "|"))
    ProcedureReturn #True
  EndIf

  ProcedureReturn #False
EndProcedure

Procedure MergeTelemetryReading(*target.TempReading, *source.TempReading)
  If *target\valid = #False And *source\valid
    *target\valid = #True
    *target\source = *source\source
    *target\sensor = *source\sensor
    *target\celsius = *source\celsius
  EndIf

  If *target\windowsTempValid = #False And *source\windowsTempValid
    *target\windowsTempValid = #True
    *target\windowsTempSensor = *source\windowsTempSensor
    *target\windowsTempCelsius = *source\windowsTempCelsius
  EndIf

  If *target\cpuPackageValid = #False And *source\cpuPackageValid
    *target\cpuPackageValid = #True
    *target\cpuPackageSensor = *source\cpuPackageSensor
    *target\cpuPackageWatts = *source\cpuPackageWatts
  EndIf

  If *target\apuPowerValid = #False And *source\apuPowerValid
    *target\apuPowerValid = #True
    *target\apuPowerSensor = *source\apuPowerSensor
    *target\apuPowerWatts = *source\apuPowerWatts
  EndIf

  If *source\gpuPowerValid
    If *target\gpuPowerValid = #False Or (IsEstimatedGpuPowerSensor(*target\gpuPowerSensor) And IsEstimatedGpuPowerSensor(*source\gpuPowerSensor) = #False)
      *target\gpuPowerValid = #True
      *target\gpuPowerSensor = *source\gpuPowerSensor
      *target\gpuPowerWatts = *source\gpuPowerWatts
    EndIf
  EndIf

  If *target\gpuLoadValid = #False And *source\gpuLoadValid
    *target\gpuLoadValid = #True
    *target\gpuLoadSensor = *source\gpuLoadSensor
    *target\gpuLoadPct = *source\gpuLoadPct
  EndIf

  If *target\gpuMemoryValid = #False And *source\gpuMemoryValid
    *target\gpuMemoryValid = #True
    *target\gpuMemorySensor = *source\gpuMemorySensor
    *target\gpuMemoryMb = *source\gpuMemoryMb
  EndIf

  If *target\gpuSharedMemoryValid = #False And *source\gpuSharedMemoryValid
    *target\gpuSharedMemoryValid = #True
    *target\gpuSharedMemorySensor = *source\gpuSharedMemorySensor
    *target\gpuSharedMemoryMb = *source\gpuSharedMemoryMb
  EndIf

  If *source\gpuDeviceNames <> ""
    *target\gpuDeviceNames = MergeLineLists(*target\gpuDeviceNames, *source\gpuDeviceNames)
  EndIf
EndProcedure

Procedure.i TelemetryCompletenessScore(*reading.TempReading)
  Protected score.i

  If *reading\valid Or *reading\windowsTempValid
    score + 1
  EndIf
  If *reading\cpuPackageValid
    score + 1
  EndIf
  If *reading\apuPowerValid
    score + 1
  EndIf
  If *reading\gpuPowerValid
    score + 1
  EndIf
  If *reading\gpuLoadValid
    score + 1
  EndIf
  If *reading\gpuMemoryValid
    score + 1
  EndIf

  ProcedureReturn score
EndProcedure

Procedure.i IsEstimatedGpuPowerSensor(sensor$)
  Protected upper$ = UCase(sensor$)

  If upper$ = ""
    ProcedureReturn #False
  EndIf

  ProcedureReturn Bool(FindString(upper$, "ESTIMATED", 1) > 0 Or FindString(upper$, "WINDOWS POWER READING", 1) > 0)
EndProcedure

Procedure.i CaptureTelemetrySnapshot(*reading.TempReading, *windows.TempReading, *fallback.TempReading)
  Protected useWindows.i
  Protected windowsReady.i
  Protected fallbackReady.i

  ResetTempReading(*reading)
  ResetTempReading(*windows)
  ResetTempReading(*fallback)

  LockMutex(gStateMutex)
  useWindows = gSettings\UseWindows
  UnlockMutex(gStateMutex)

  If useWindows
    windowsReady = ReadWindowsTelemetry(*windows)
    ApplyTelemetryLatch(*windows, @gWindowsTelemetryLatch)
    windowsReady = HasUsableTelemetry(*windows)
    If windowsReady
      MergeTelemetryReading(*reading, *windows)
    EndIf
  EndIf

  If *reading\valid = #False And *reading\windowsTempValid
    *reading\valid = #True
    *reading\source = "Windows Performance Counters"
    *reading\sensor = *reading\windowsTempSensor
    *reading\celsius = *reading\windowsTempCelsius
  EndIf

  fallbackReady = ReadFallbackSensor(*fallback)
  ApplyTelemetryLatch(*fallback, @gFallbackTelemetryLatch)
  fallbackReady = HasUsableTelemetry(*fallback)
  If HasUsableTelemetry(*reading) = #False And fallbackReady
    CopyTempReading(*reading, *fallback)
  EndIf

  ApplyTelemetryLatch(*reading, @gBlendTelemetryLatch)

  ProcedureReturn HasVisibleTelemetry(*reading)
EndProcedure

Procedure.i ReadBestSensor(*reading.TempReading)
  Protected windows.TempReading
  Protected fallback.TempReading

  ProcedureReturn CaptureTelemetrySnapshot(*reading, @windows, @fallback)
EndProcedure

Procedure.s FindBundledWindowsEmiHelper()
  Protected path$

  path$ = GetPathPart(ProgramFilename()) + "PowerPilotWindowsEmiHelper.exe"
  If FileSize(path$) >= 0
    ProcedureReturn path$
  EndIf

  path$ = GetCurrentDirectory() + "PowerPilotWindowsEmiHelper.exe"
  If FileSize(path$) >= 0
    ProcedureReturn path$
  EndIf

  path$ = GetPathPart(GetPathPart(ProgramFilename())) + "PowerPilotWindowsEmiHelper.exe"
  If FileSize(path$) >= 0
    ProcedureReturn path$
  EndIf

  ProcedureReturn ""
EndProcedure

Procedure.s FindBundledWindowsPerfHelper()
  Protected path$

  path$ = GetPathPart(ProgramFilename()) + "PowerPilotWindowsPerfHelper.exe"
  If FileSize(path$) >= 0
    ProcedureReturn path$
  EndIf

  path$ = GetCurrentDirectory() + "PowerPilotWindowsPerfHelper.exe"
  If FileSize(path$) >= 0
    ProcedureReturn path$
  EndIf

  path$ = GetPathPart(GetPathPart(ProgramFilename())) + "PowerPilotWindowsPerfHelper.exe"
  If FileSize(path$) >= 0
    ProcedureReturn path$
  EndIf

  ProcedureReturn ""
EndProcedure

Procedure.s FindBundledWindowsPmiHelper()
  Protected path$

  path$ = GetPathPart(ProgramFilename()) + "PowerPilotWindowsPmiHelper.exe"
  If FileSize(path$) >= 0
    ProcedureReturn path$
  EndIf

  path$ = GetCurrentDirectory() + "PowerPilotWindowsPmiHelper.exe"
  If FileSize(path$) >= 0
    ProcedureReturn path$
  EndIf

  path$ = GetPathPart(GetPathPart(ProgramFilename())) + "PowerPilotWindowsPmiHelper.exe"
  If FileSize(path$) >= 0
    ProcedureReturn path$
  EndIf

  ProcedureReturn ""
EndProcedure

Procedure StopWindowsPerfHelper()
  If gWindowsPerfHelperHandle
    CloseProgram(gWindowsPerfHelperHandle)
    gWindowsPerfHelperHandle = 0
  EndIf

  gWindowsPerfHelperIntervalMs = 0
  gWindowsPerfHelperInBlock = #False
  gWindowsPerfHelperCurrentBlock$ = ""
  gWindowsPerfHelperLatestBlock$ = ""
  gWindowsPerfHelperLatestTick = 0
EndProcedure

Procedure.i WindowsPerfHelperIntervalMs()
  Protected pollSeconds.i

  LockMutex(gStateMutex)
  pollSeconds = gSettings\PollSeconds
  UnlockMutex(gStateMutex)

  If pollSeconds < 1
    pollSeconds = 1
  EndIf

  ProcedureReturn ClampInt(pollSeconds * 1000, 500, 10000)
EndProcedure

Procedure.i ShouldUseWindowsPerfHelper()
  Protected powerSource.i
  Protected autoBatteryPlan.i

  LockMutex(gStateMutex)
  powerSource = gState\PowerSource
  autoBatteryPlan = gSettings\AutoBatteryPlan
  UnlockMutex(gStateMutex)

  If powerSource = #PowerSourceBattery And autoBatteryPlan
    ProcedureReturn #False
  EndIf

  ProcedureReturn #True
EndProcedure

Procedure DrainWindowsPerfHelperOutput()
  Protected line$

  If gWindowsPerfHelperHandle = 0
    ProcedureReturn
  EndIf

  While AvailableProgramOutput(gWindowsPerfHelperHandle)
    line$ = Trim(ReadProgramString(gWindowsPerfHelperHandle))

    Select line$
      Case "WINDOWSPERFBEGIN"
        gWindowsPerfHelperInBlock = #True
        gWindowsPerfHelperCurrentBlock$ = ""

      Case "WINDOWSPERFEND"
        If gWindowsPerfHelperInBlock
          gWindowsPerfHelperLatestBlock$ = gWindowsPerfHelperCurrentBlock$
          gWindowsPerfHelperLatestTick = ElapsedMilliseconds()
        EndIf
        gWindowsPerfHelperInBlock = #False
        gWindowsPerfHelperCurrentBlock$ = ""

      Default
        If gWindowsPerfHelperInBlock
          gWindowsPerfHelperCurrentBlock$ + line$ + #LF$
        EndIf
    EndSelect
  Wend

  If ProgramRunning(gWindowsPerfHelperHandle) = #False
    CloseProgram(gWindowsPerfHelperHandle)
    gWindowsPerfHelperHandle = 0
    gWindowsPerfHelperInBlock = #False
    gWindowsPerfHelperCurrentBlock$ = ""
  EndIf
EndProcedure

Procedure.i EnsureWindowsPerfHelper()
  Protected helper$
  Protected desiredIntervalMs.i = WindowsPerfHelperIntervalMs()

  If gWindowsPerfHelperHandle
    DrainWindowsPerfHelperOutput()
    If gWindowsPerfHelperHandle And gWindowsPerfHelperIntervalMs = desiredIntervalMs
      ProcedureReturn #True
    EndIf

    CloseProgram(gWindowsPerfHelperHandle)
    gWindowsPerfHelperHandle = 0
    gWindowsPerfHelperInBlock = #False
    gWindowsPerfHelperCurrentBlock$ = ""
  EndIf

  helper$ = FindBundledWindowsPerfHelper()
  If helper$ = ""
    ProcedureReturn #False
  EndIf

  gWindowsPerfHelperHandle = RunProgram(helper$, "--stream --interval-ms " + Str(desiredIntervalMs) + " --parent-pid " + Str(GetCurrentProcessId_()), GetPathPart(helper$), #PB_Program_Open | #PB_Program_Read | #PB_Program_Hide)
  If gWindowsPerfHelperHandle = 0
    ProcedureReturn #False
  EndIf

  gWindowsPerfHelperIntervalMs = desiredIntervalMs
  ProcedureReturn #True
EndProcedure

Procedure.i ReadWindowsPerfStreamTelemetry(*reading.TempReading)
  Protected freshnessMs.i
  Protected waitDeadline.q
  Protected nowTick.q
  Protected normalized$
  Protected lineCount.i
  Protected i.i
  Protected line$
  Protected kind$
  Protected sensor$
  Protected value$

  If ShouldUseWindowsPerfHelper() = #False
    StopWindowsPerfHelper()
    ProcedureReturn #False
  EndIf

  freshnessMs = ClampInt(WindowsPerfHelperIntervalMs() * 3, 1500, 12000)

  If EnsureWindowsPerfHelper()
    waitDeadline = ElapsedMilliseconds() + ClampInt(gWindowsPerfHelperIntervalMs + 250, 500, 2500)
    Repeat
      DrainWindowsPerfHelperOutput()
      If gWindowsPerfHelperLatestTick > 0 And ElapsedMilliseconds() - gWindowsPerfHelperLatestTick <= freshnessMs
        Break
      EndIf

      If ElapsedMilliseconds() >= waitDeadline
        Break
      EndIf

      Delay(25)
    ForEver
  EndIf

  nowTick = ElapsedMilliseconds()
  If gWindowsPerfHelperLatestTick = 0 Or nowTick - gWindowsPerfHelperLatestTick > freshnessMs
    ProcedureReturn #False
  EndIf

  normalized$ = ReplaceString(gWindowsPerfHelperLatestBlock$, #CR$, "")
  lineCount = CountString(normalized$, #LF$) + 1

  For i = 1 To lineCount
    line$ = Trim(StringField(normalized$, i, #LF$))
    If line$ = ""
      Continue
    EndIf

    kind$ = StringField(line$, 1, "|")
    sensor$ = StringField(line$, 2, "|")
    value$ = StringField(line$, 3, "|")

    Select kind$
      Case "WINDOWSGPULOAD"
        *reading\gpuLoadValid = #True
        *reading\gpuLoadSensor = sensor$
        *reading\gpuLoadPct = ValD(value$)

      Case "WINDOWSGPUMEM"
        *reading\gpuMemoryValid = #True
        *reading\gpuMemorySensor = sensor$
        *reading\gpuMemoryMb = ValD(value$)

      Case "WINDOWSGPUMEMSHARED"
        *reading\gpuSharedMemoryValid = #True
        *reading\gpuSharedMemorySensor = sensor$
        *reading\gpuSharedMemoryMb = ValD(value$)

      Case "WINDOWSGPUDEVICE"
        *reading\gpuDeviceNames = MergeLineLists(*reading\gpuDeviceNames, sensor$)
    EndSelect
  Next

  ProcedureReturn Bool(*reading\gpuLoadValid Or *reading\gpuMemoryValid)
EndProcedure

Procedure.s DependencyLaunchLabel()
  ProcedureReturn "Refresh Status"
EndProcedure

Procedure.i LaunchPreferredDependencyApp()
  RefreshDependencyWindow()
  LogAction("Dependency status refreshed.")
  ProcedureReturn #True
EndProcedure

Procedure.i ReadWindowsPmiTelemetry(*reading.TempReading)
  Protected helper$
  Protected output$
  Protected normalized$
  Protected lineCount.i
  Protected i.i
  Protected line$
  Protected kind$
  Protected sensor$
  Protected value$

  helper$ = FindBundledWindowsPmiHelper()
  If helper$ = ""
    ProcedureReturn #False
  EndIf

  output$ = RunCapture(helper$, "")
  If output$ = ""
    ProcedureReturn #False
  EndIf

  normalized$ = ReplaceString(output$, #CR$, "")
  lineCount = CountString(normalized$, #LF$) + 1

  For i = 1 To lineCount
    line$ = Trim(StringField(normalized$, i, #LF$))
    If line$ = ""
      Continue
    EndIf

    kind$ = StringField(line$, 1, "|")
    sensor$ = StringField(line$, 2, "|")
    value$ = StringField(line$, 3, "|")

    Select kind$
      Case "WINDOWSCPUPOWER"
        If HasMeaningfulPowerWatts(ValD(value$))
          *reading\cpuPackageValid = #True
          *reading\cpuPackageSensor = sensor$
          *reading\cpuPackageWatts = ValD(value$)
        EndIf

      Case "WINDOWSAPUPOWER"
        If HasMeaningfulPowerWatts(ValD(value$))
          *reading\apuPowerValid = #True
          *reading\apuPowerSensor = sensor$
          *reading\apuPowerWatts = ValD(value$)
        EndIf

      Case "WINDOWSGPUPOWER"
        If HasMeaningfulPowerWatts(ValD(value$))
          *reading\gpuPowerValid = #True
          *reading\gpuPowerSensor = sensor$
          *reading\gpuPowerWatts = ValD(value$)
        EndIf
    EndSelect
  Next

  ProcedureReturn Bool(*reading\cpuPackageValid Or *reading\apuPowerValid Or *reading\gpuPowerValid)
EndProcedure

Procedure.i ReadWindowsEmiTelemetry(*reading.TempReading)
  Protected helper$
  Protected output$
  Protected normalized$
  Protected lineCount.i
  Protected i.i
  Protected line$
  Protected kind$
  Protected sensor$
  Protected value$

  helper$ = FindBundledWindowsEmiHelper()
  If helper$ = ""
    ProcedureReturn #False
  EndIf

  output$ = RunCapture(helper$, "")
  If output$ = ""
    ProcedureReturn #False
  EndIf

  normalized$ = ReplaceString(output$, #CR$, "")
  lineCount = CountString(normalized$, #LF$) + 1

  For i = 1 To lineCount
    line$ = Trim(StringField(normalized$, i, #LF$))
    If line$ = ""
      Continue
    EndIf

    kind$ = StringField(line$, 1, "|")
    sensor$ = StringField(line$, 2, "|")
    value$ = StringField(line$, 3, "|")

    Select kind$
      Case "WINDOWSCPUPOWER"
        If HasMeaningfulPowerWatts(ValD(value$))
          *reading\cpuPackageValid = #True
          *reading\cpuPackageSensor = sensor$
          *reading\cpuPackageWatts = ValD(value$)
        EndIf

      Case "WINDOWSAPUPOWER"
        If HasMeaningfulPowerWatts(ValD(value$))
          *reading\apuPowerValid = #True
          *reading\apuPowerSensor = sensor$
          *reading\apuPowerWatts = ValD(value$)
        EndIf

      Case "WINDOWSGPUPOWER"
        If HasMeaningfulPowerWatts(ValD(value$))
          *reading\gpuPowerValid = #True
          *reading\gpuPowerSensor = sensor$
          *reading\gpuPowerWatts = ValD(value$)
        EndIf
    EndSelect
  Next

  ProcedureReturn Bool(*reading\cpuPackageValid Or *reading\apuPowerValid Or *reading\gpuPowerValid)
EndProcedure

Procedure ReadDependencyStatus(*status.DependencyStatus)
  Protected useWindows.i
  Protected reading.TempReading
  Protected windows.TempReading
  Protected fallback.TempReading
  Protected settings.AppSettings

  LockMutex(gStateMutex)
  useWindows = gSettings\UseWindows
  UnlockMutex(gStateMutex)

  settings\UseWindows = useWindows

  ReadWindowsTelemetry(@windows)
  ApplyTelemetryLatch(@windows, @gWindowsTelemetryLatch)
  If HasUsableTelemetry(@windows) = #False
    ReadFallbackSensor(@fallback)
    ApplyTelemetryLatch(@fallback, @gFallbackTelemetryLatch)
  EndIf
  BuildDependencyStatusFromSnapshots(*status, @reading, @windows, @fallback, @settings)
EndProcedure

Procedure.s BuildDependencySummary()
  Protected status.DependencyStatus

  CopyCachedDependencyStatus(@status)

  If status\ManagedPlansReady = #False
    ProcedureReturn "Problem now: the PowerPilot plans are missing, so create them once before using Auto Cool."
  EndIf

  If status\WindowsTelemetryReady
    ProcedureReturn "Status now: live telemetry is active."
  EndIf

  If status\FallbackAvailable
    ProcedureReturn "Status now: generic fallback temperature is active."
  EndIf

  If status\WindowsEnabled And status\WindowsTelemetryReady = #False
    ProcedureReturn "Problem now: telemetry is enabled, but Windows is not returning usable counters."
  EndIf

  ProcedureReturn "Problem now: no telemetry source is producing usable data."
EndProcedure

Procedure.s BuildDependencyInstructions()
  Protected status.DependencyStatus
  Protected text$

  CopyCachedDependencyStatus(@status)

  text$ + "Current status" + #LF$
  text$ + "Use Windows telemetry in PowerPilot: " + YesNoText(status\WindowsEnabled) + #LF$
  text$ + "Live Windows telemetry available: " + YesNoText(status\WindowsTelemetryReady) + #LF$
  text$ + "Windows temperature available: " + YesNoText(status\WindowsTempReady) + #LF$
  text$ + "Windows CPU power available: " + YesNoText(status\WindowsPowerReady) + #LF$
  text$ + "Windows GPU counters available: " + YesNoText(status\WindowsGpuReady) + #LF$
  text$ + "Fallback temperature available: " + YesNoText(status\FallbackAvailable) + #LF$
  text$ + "PowerPilot managed plans present: " + YesNoText(status\ManagedPlansReady) + #LF$
  If status\SensorReady
    text$ + "Sensor PowerPilot can use now: " + status\SensorSource + " / " + status\SensorName + #LF$
  Else
  text$ + "Sensor PowerPilot can use now: none" + #LF$
  EndIf

  text$ + #LF$
  text$ + "How PowerPilot reads data" + #LF$
  text$ + "PowerPilot reads live telemetry from Windows first." + #LF$
  text$ + "If Windows cannot provide a usable temperature, PowerPilot can still fall back to a generic thermal-zone reading." + #LF$
  text$ + "For power data, PowerPilot prefers PMI first, EMI second, and only uses older Windows power counters when neither modern interface is available." + #LF$
  text$ + "For GPU load and memory, PowerPilot prefers the persistent WMI refresher helper and only falls back to older Windows counters if that helper is unavailable." + #LF$
  text$ + "Brief telemetry gaps hold the last good field value until a new reading arrives or the gap grows much larger than the normal successful polling pattern." + #LF$
  text$ + "Windows APU or GPU power can still be useful even when it is not a direct dedicated-GPU watt reading." + #LF$
  text$ + "GPU power is only used when Windows exposes a usable watt reading." + #LF$
  text$ + "Overview and Live Telemetry show the current snapshot, while Auto Cool uses the Control tab average window before changing plans." + #LF$
  text$ + "If 'Auto battery/plugged plan' is ticked, it holds Battery Saver on battery and Full Power when plugged in unless sustained GPU load is currently detected." + #LF$

  text$ + #LF$
  text$ + "Telemetry pipeline" + #LF$
  text$ + "1. GPU load from a persistent Windows WMI performance refresher over the GPU engine classes." + #LF$
  text$ + "2. GPU memory from a persistent Windows WMI performance refresher over the GPU adapter memory classes." + #LF$
  text$ + "3. CPU power from Windows Energy Meter counters when your firmware exposes it." + #LF$
  text$ + "4. Fallback temperature from Windows thermal zone counters when Windows temperature is not usable." + #LF$
  If status\WindowsPowerReady
    text$ + "5. Windows is currently supplying the active CPU-power reading." + #LF$
  EndIf

  text$ + #LF$
  text$ + "GPU power" + #LF$
  text$ + "1. PowerPilot now relies on Windows telemetry only." + #LF$
  text$ + "2. If Windows exposes a usable GPU-power watt reading, PowerPilot will use it." + #LF$
  text$ + "3. If Windows does not expose GPU power, PowerPilot will continue using temperature, CPU power, GPU load, and GPU memory when those are available." + #LF$

  text$ + #LF$
  text$ + "What to do next" + #LF$
  If status\WindowsTelemetryReady
    text$ + "- Live telemetry is already working, so PowerPilot can operate without extra tools." + #LF$
  Else
    text$ + "- Live Windows telemetry is not available right now, so Auto Cool will lean on fallback temperature only when it exists." + #LF$
  EndIf

  If status\WindowsPowerReady = #False
    text$ + "- CPU power is not currently exposed by Windows on this pass, so power-based control may lean more on temperature." + #LF$
  EndIf

  If status\WindowsEnabled And status\WindowsGpuReady = #False
    text$ + "- GPU load and GPU memory are not currently available from Windows, so the Cool trigger may be limited." + #LF$
  EndIf

  If status\FallbackAvailable And status\WindowsTelemetryReady = #False
    text$ + "- A generic fallback temperature source is visible, but it is lower quality than the named sources above." + #LF$
  ElseIf status\FallbackAvailable = #False And status\WindowsTelemetryReady = #False
    text$ + "- No enabled telemetry source is producing data right now, so Auto Cool will stay paused." + #LF$
  EndIf

  If status\ManagedPlansReady = #False
    text$ + "- Click 'Create Plans' in the main PowerPilot window once to install the Battery Saver, Plugged In, Cool, and Full Power plans." + #LF$
  Else
    text$ + "- The custom PowerPilot power plans are already present." + #LF$
  EndIf

  text$ + #LF$
  text$ + "Quick reminder" + #LF$
  text$ + "Windows remains the normal live-data path. Generic fallback temperature is only used when Windows cannot provide a usable temperature." + #LF$

  ProcedureReturn text$
EndProcedure

Procedure.s BuildMainStatusText(*reading.TempReading, autoEnabled.i, autoDetectGame.i)
  Protected status.DependencyStatus

  CopyCachedDependencyStatus(@status)

  If autoEnabled And status\ManagedPlansReady = #False
    ProcedureReturn "Plans missing. Use Create Plans or Help."
  EndIf

  If HasControlTelemetry(*reading, @gSettings)
    If status\WindowsTelemetryReady
      If autoEnabled
        If *reading\gameDetected
          ProcedureReturn "Telemetry active. GPU load trigger active."
        EndIf
        ProcedureReturn "Telemetry active. Auto Cool armed."
      EndIf

      If autoDetectGame
        If *reading\gameDetected
          ProcedureReturn "Telemetry active. GPU load trigger active."
        EndIf
        ProcedureReturn "Telemetry active. Waiting for GPU load."
      EndIf

      ProcedureReturn "Telemetry active."
    EndIf
    If Left(*reading\source, 4) = "ACPI" Or FindString(UCase(*reading\source), "FALLBACK", 1)
      If autoEnabled
        ProcedureReturn "Fallback temperature active. Auto Cool armed."
      EndIf
      If autoDetectGame
        If *reading\gameDetected
          ProcedureReturn "Fallback temperature active. GPU load trigger active."
        EndIf
        ProcedureReturn "Fallback temperature active. Waiting for GPU load."
      EndIf
      ProcedureReturn "Fallback temperature active."
    EndIf

    If autoEnabled
      If *reading\gameDetected
        ProcedureReturn "Auto Cool enabled. GPU load trigger active."
      EndIf
      ProcedureReturn "Auto Cool enabled."
    EndIf

    If autoDetectGame
      If *reading\gameDetected
        ProcedureReturn "GPU load trigger active. Auto active."
      EndIf
      ProcedureReturn "Waiting for GPU load."
    EndIf

    ProcedureReturn "Auto Cool disabled."
  EndIf

  If status\WindowsEnabled And status\WindowsTelemetryReady = #False
    If status\FallbackAvailable
      ProcedureReturn "Live telemetry unavailable. PowerPilot will use generic fallback temperature."
    EndIf
    ProcedureReturn "Live telemetry unavailable. PowerPilot is waiting for data."
  EndIf

  If autoEnabled
    ProcedureReturn "Auto Cool enabled."
  EndIf

  If autoDetectGame
    ProcedureReturn "Waiting for GPU load."
  EndIf

  ProcedureReturn "Auto Cool disabled."
EndProcedure

Procedure.i DependencyAlertNeeded()
  Protected status.DependencyStatus

  CopyCachedDependencyStatus(@status)

  If status\ManagedPlansReady = #False
    ProcedureReturn #True
  EndIf

  If status\WindowsTelemetryReady
    ProcedureReturn #False
  EndIf

  If status\WindowsEnabled And status\WindowsTelemetryReady = #False
    ProcedureReturn #True
  EndIf

  ProcedureReturn Bool(status\SensorReady = #False)
EndProcedure

Procedure DrawHelpButton()
  Protected width.i
  Protected height.i
  Protected fillColor.i
  Protected outerBorder.i
  Protected topBorder.i
  Protected bottomBorder.i
  Protected textColor.i
  Protected label$ = "Help"
  Protected textX.i
  Protected textY.i

  If gLastHelpAlertState = gHelpAlertNeeded
    ProcedureReturn
  EndIf

  If IsGadget(#GadgetDependencies) = 0
    ProcedureReturn
  EndIf

  width = GadgetWidth(#GadgetDependencies)
  height = GadgetHeight(#GadgetDependencies)

  If gHelpAlertNeeded
    fillColor = RGB(220, 35, 35)
    outerBorder = RGB(110, 0, 0)
    topBorder = RGB(255, 150, 150)
    bottomBorder = RGB(110, 0, 0)
    textColor = RGB(255, 255, 255)
  Else
    fillColor = RGB(240, 240, 240)
    outerBorder = RGB(140, 140, 140)
    topBorder = RGB(255, 255, 255)
    bottomBorder = RGB(150, 150, 150)
    textColor = RGB(35, 35, 35)
  EndIf

  If StartDrawing(CanvasOutput(#GadgetDependencies))
    Box(0, 0, width, height, fillColor)
    DrawingMode(#PB_2DDrawing_Default)
    Box(0, 0, width, 1, outerBorder)
    Box(0, 0, 1, height, outerBorder)
    Box(width - 1, 0, 1, height, outerBorder)
    Box(0, height - 1, width, 1, outerBorder)
    Box(1, 1, width - 2, 1, topBorder)
    Box(1, 1, 1, height - 2, topBorder)
    Box(1, height - 2, width - 2, 1, bottomBorder)
    Box(width - 2, 1, 1, height - 2, bottomBorder)
    DrawingMode(#PB_2DDrawing_Transparent)
    textX = (width - TextWidth(label$)) / 2
    textY = (height - TextHeight(label$)) / 2
    DrawText(textX, textY, label$, textColor)
    StopDrawing()
  EndIf

  gLastHelpAlertState = gHelpAlertNeeded
EndProcedure

Procedure.s DecideAutoPlan(tempC.d, currentPlan$)
  Protected h.i = gSettings\Hysteresis

  Select currentPlan$
    Case ""
      If tempC >= gSettings\Threshold1512 : ProcedureReturn #PlanGame12$ : EndIf
      If tempC >= gSettings\Threshold1815 : ProcedureReturn #PlanGame15$ : EndIf
      If tempC >= gSettings\Threshold2118 : ProcedureReturn #PlanGame18$ : EndIf
      If tempC >= gSettings\Threshold2421 : ProcedureReturn #PlanGame21$ : EndIf
      If tempC >= gSettings\ThresholdFull24 : ProcedureReturn #PlanGame24$ : EndIf
      ProcedureReturn #PlanFull$

    Case #PlanFull$
      If tempC >= gSettings\ThresholdFull24 : ProcedureReturn #PlanGame24$ : EndIf
      ProcedureReturn #PlanFull$

    Case #PlanGame24$
      If tempC >= gSettings\Threshold2421 : ProcedureReturn #PlanGame21$ : EndIf
      If tempC <= gSettings\ThresholdFull24 - h : ProcedureReturn #PlanFull$ : EndIf
      ProcedureReturn #PlanGame24$

    Case #PlanGame21$
      If tempC >= gSettings\Threshold2118 : ProcedureReturn #PlanGame18$ : EndIf
      If tempC <= gSettings\Threshold2421 - h : ProcedureReturn #PlanGame24$ : EndIf
      ProcedureReturn #PlanGame21$

    Case #PlanGame18$
      If tempC >= gSettings\Threshold1815 : ProcedureReturn #PlanGame15$ : EndIf
      If tempC <= gSettings\Threshold2118 - h : ProcedureReturn #PlanGame21$ : EndIf
      ProcedureReturn #PlanGame18$

    Case #PlanGame15$
      If tempC >= gSettings\Threshold1512 : ProcedureReturn #PlanGame12$ : EndIf
      If tempC <= gSettings\Threshold1815 - h : ProcedureReturn #PlanGame18$ : EndIf
      ProcedureReturn #PlanGame15$

    Case #PlanGame12$
      If tempC <= gSettings\Threshold1512 - h : ProcedureReturn #PlanGame15$ : EndIf
      ProcedureReturn #PlanGame12$
  EndSelect

  ProcedureReturn #PlanFull$
EndProcedure

Procedure CopySettings(*settings.AppSettings)
  LockMutex(gStateMutex)
  *settings\AutoEnabled = gSettings\AutoEnabled
  *settings\AutoDetectGame = gSettings\AutoDetectGame
  *settings\UseWindows = gSettings\UseWindows
  *settings\UsePowerControl = gSettings\UsePowerControl
  *settings\AutoStartWithApp = gSettings\AutoStartWithApp
  *settings\KeepSettingsOnReinstall = gSettings\KeepSettingsOnReinstall
  *settings\AutoBatteryPlan = gSettings\AutoBatteryPlan
  *settings\PollSeconds = gSettings\PollSeconds
  *settings\Hysteresis = gSettings\Hysteresis
  *settings\PowerHysteresis = gSettings\PowerHysteresis
  *settings\CpuPowerTarget = gSettings\CpuPowerTarget
  *settings\GpuPowerTarget = gSettings\GpuPowerTarget
  *settings\GpuLoadThreshold = gSettings\GpuLoadThreshold
  *settings\GameCoolAverageSeconds = gSettings\GameCoolAverageSeconds
  *settings\GameStartDelay = gSettings\GameStartDelay
  *settings\GameStopDelay = gSettings\GameStopDelay
  *settings\ThresholdFull24 = gSettings\ThresholdFull24
  *settings\Threshold2421 = gSettings\Threshold2421
  *settings\Threshold2118 = gSettings\Threshold2118
  *settings\Threshold1815 = gSettings\Threshold1815
  *settings\Threshold1512 = gSettings\Threshold1512
  *settings\LastPluggedPlan = gSettings\LastPluggedPlan
  *settings\LastDgpuPluggedPlan = gSettings\LastDgpuPluggedPlan
  *settings\CurrentManagedPlan = gSettings\CurrentManagedPlan
  UnlockMutex(gStateMutex)
EndProcedure

Procedure.s GetRememberedPluggedPlan()
  Protected plan$

  LockMutex(gStateMutex)
  plan$ = gSettings\LastPluggedPlan
  UnlockMutex(gStateMutex)

  ProcedureReturn NormalizeRememberedPluggedPlan(plan$)
EndProcedure

Procedure RememberPluggedPlan(planName$, persist.i = #False)
  Protected normalized$
  Protected changed.i

  If IsRememberedPluggedPlanName(planName$) = #False
    ProcedureReturn
  EndIf

  normalized$ = NormalizeRememberedPluggedPlan(planName$)

  LockMutex(gStateMutex)
  If gSettings\LastPluggedPlan <> normalized$
    gSettings\LastPluggedPlan = normalized$
    changed = #True
  EndIf
  UnlockMutex(gStateMutex)

  If changed And persist
    SaveSettings()
  EndIf
EndProcedure

Procedure.s GetRememberedDgpuPluggedPlan()
  Protected plan$

  LockMutex(gStateMutex)
  plan$ = gSettings\LastDgpuPluggedPlan
  UnlockMutex(gStateMutex)

  ProcedureReturn NormalizeDgpuPluggedPlan(plan$)
EndProcedure

Procedure RememberDgpuPluggedPlan(planName$, persist.i = #False)
  Protected normalized$
  Protected changed.i

  If IsRememberedPluggedPlanName(planName$) = #False
    ProcedureReturn
  EndIf

  normalized$ = NormalizeDgpuPluggedPlan(planName$)

  LockMutex(gStateMutex)
  If gSettings\LastDgpuPluggedPlan <> normalized$
    gSettings\LastDgpuPluggedPlan = normalized$
    changed = #True
  EndIf
  UnlockMutex(gStateMutex)

  If changed And persist
    SaveSettings()
  EndIf
EndProcedure

Procedure.s GetCurrentManagedPlan()
  Protected plan$

  LockMutex(gStateMutex)
  plan$ = gSettings\CurrentManagedPlan
  UnlockMutex(gStateMutex)

  ProcedureReturn NormalizeManagedPlan(plan$)
EndProcedure

Procedure RememberCurrentManagedPlan(planName$, persist.i = #False)
  Protected normalized$
  Protected changed.i

  If IsSelectableManagedPlanName(planName$) = #False
    ProcedureReturn
  EndIf

  normalized$ = NormalizeManagedPlan(planName$)

  LockMutex(gStateMutex)
  If gSettings\CurrentManagedPlan <> normalized$
    gSettings\CurrentManagedPlan = normalized$
    changed = #True
  EndIf
  UnlockMutex(gStateMutex)

  If changed And persist
    SaveSettings()
  EndIf
EndProcedure

Procedure EnsureVisiblePlanActive(allowElevation.i = #False)
  Protected activePlan$ = GetActiveSchemeName()

  If IsSelectableManagedPlanName(activePlan$)
    ActivatePlanByName(activePlan$, allowElevation)
  EndIf
EndProcedure

Procedure.i ManagedPlansExist()
  If GetSchemeGuidByName(#PlanVisible$) = "" : ProcedureReturn #False : EndIf
  If GetSchemeGuidByName(#PlanBattery$) = "" : ProcedureReturn #False : EndIf
  If GetSchemeGuidByName(#PlanPlugged$) = "" : ProcedureReturn #False : EndIf
  If GetSchemeGuidByName(#PlanGame12$) = "" : ProcedureReturn #False : EndIf
  If GetSchemeGuidByName(#PlanGame15$) = "" : ProcedureReturn #False : EndIf
  If GetSchemeGuidByName(#PlanGame18$) = "" : ProcedureReturn #False : EndIf
  If GetSchemeGuidByName(#PlanGame21$) = "" : ProcedureReturn #False : EndIf
  If GetSchemeGuidByName(#PlanGame24$) = "" : ProcedureReturn #False : EndIf
  If GetSchemeGuidByName(#PlanFull$) = "" : ProcedureReturn #False : EndIf
  ProcedureReturn #True
EndProcedure

Procedure.i SetStartupRegistry(enabled.i)
  Protected key$ = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
  Protected Data$ = Chr(34) + ProgramFilename() + Chr(34) + " /tray"
  Protected code$

  If enabled
    code$ = "$key = '" + ReplaceString(key$, "'", "''") + "'; " +
            "$value = '" + ReplaceString(Data$, "'", "''") + "'; " +
            "New-Item -Path $key -Force | Out-Null; " +
            "New-ItemProperty -Path $key -Name '" + ReplaceString(#AppRunKey$, "'", "''") + "' -PropertyType String -Value $value -Force | Out-Null; " +
            "exit 0"
  Else
    code$ = "$key = '" + ReplaceString(key$, "'", "''") + "'; " +
            "Remove-ItemProperty -Path $key -Name '" + ReplaceString(#AppRunKey$, "'", "''") + "' -ErrorAction SilentlyContinue; " +
            "exit 0"
  EndIf

  ProcedureReturn Bool(RunExitCode("powershell.exe", "-NoProfile -ExecutionPolicy Bypass -Command " + QuoteArgument(code$)) = 0)
EndProcedure

Procedure.i CleanupSettingsData()
  Protected settingsDir$ = SettingsDirectory()

  SetStartupRegistry(#False)

  If FileSize(settingsDir$) = -2
    ProcedureReturn DeleteDirectory(settingsDir$, "", #PB_FileSystem_Recursive | #PB_FileSystem_Force)
  EndIf

  ProcedureReturn #True
EndProcedure

Procedure.s DecideTempDrivenPlan(tempC.d, currentPlan$, *settings.AppSettings)
  Protected h.i = *settings\Hysteresis

  Select currentPlan$
    Case ""
      If tempC >= *settings\Threshold1512 : ProcedureReturn #PlanGame12$ : EndIf
      If tempC >= *settings\Threshold1815 : ProcedureReturn #PlanGame15$ : EndIf
      If tempC >= *settings\Threshold2118 : ProcedureReturn #PlanGame18$ : EndIf
      If tempC >= *settings\Threshold2421 : ProcedureReturn #PlanGame21$ : EndIf
      If tempC >= *settings\ThresholdFull24 : ProcedureReturn #PlanGame24$ : EndIf
      ProcedureReturn #PlanFull$

    Case #PlanFull$
      If tempC >= *settings\ThresholdFull24 : ProcedureReturn #PlanGame24$ : EndIf
      ProcedureReturn #PlanFull$

    Case #PlanGame24$
      If tempC >= *settings\Threshold2421 : ProcedureReturn #PlanGame21$ : EndIf
      If tempC <= *settings\ThresholdFull24 - h : ProcedureReturn #PlanFull$ : EndIf
      ProcedureReturn #PlanGame24$

    Case #PlanGame21$
      If tempC >= *settings\Threshold2118 : ProcedureReturn #PlanGame18$ : EndIf
      If tempC <= *settings\Threshold2421 - h : ProcedureReturn #PlanGame24$ : EndIf
      ProcedureReturn #PlanGame21$

    Case #PlanGame18$
      If tempC >= *settings\Threshold1815 : ProcedureReturn #PlanGame15$ : EndIf
      If tempC <= *settings\Threshold2118 - h : ProcedureReturn #PlanGame21$ : EndIf
      ProcedureReturn #PlanGame18$

    Case #PlanGame15$
      If tempC >= *settings\Threshold1512 : ProcedureReturn #PlanGame12$ : EndIf
      If tempC <= *settings\Threshold1815 - h : ProcedureReturn #PlanGame18$ : EndIf
      ProcedureReturn #PlanGame15$

    Case #PlanGame12$
      If tempC <= *settings\Threshold1512 - h : ProcedureReturn #PlanGame15$ : EndIf
      ProcedureReturn #PlanGame12$
  EndSelect

  ProcedureReturn #PlanFull$
EndProcedure

Procedure.s DecideAutoPlanSnapshot(*reading.TempReading, currentPlan$, *settings.AppSettings)
  Protected currentLevel.i = PlanLevelFromName(currentPlan$)
  Protected desiredLevel.i = currentLevel
  Protected tempPlan$
  Protected powerError.d
  Protected powerCount.i
  Protected normalizedCpuError.d
  Protected normalizedGpuError.d
  Protected thresholdW.d
  Static powerIntegrator.d

  If currentPlan$ = ""
    currentLevel = 5
    desiredLevel = 5
  EndIf

  If *reading\valid
    tempPlan$ = DecideTempDrivenPlan(*reading\celsius, currentPlan$, *settings)
    desiredLevel = PlanLevelFromName(tempPlan$)
  EndIf

  If *settings\UsePowerControl And HasPowerTelemetry(*reading)
    thresholdW = *settings\PowerHysteresis

    If *reading\cpuPackageValid
      normalizedCpuError = (*reading\cpuPackageWatts - *settings\CpuPowerTarget) / thresholdW
      powerError + normalizedCpuError
      powerCount + 1
    EndIf

    If *reading\gpuPowerValid
      normalizedGpuError = (*reading\gpuPowerWatts - *settings\GpuPowerTarget) / thresholdW
      powerError + normalizedGpuError
      powerCount + 1
    EndIf

    If powerCount > 0
      powerError / powerCount
      powerIntegrator = ClampDouble((powerIntegrator * 0.55) + powerError, -3.0, 3.0)

      If powerError >= 1.0 Or powerIntegrator >= 1.2
        desiredLevel - 1
      ElseIf powerError <= -1.0 Or powerIntegrator <= -1.2
        If *reading\valid = #False Or *reading\celsius <= *settings\ThresholdFull24 - *settings\Hysteresis
          desiredLevel + 1
        EndIf
      EndIf
    EndIf
  Else
    powerIntegrator * 0.5
  EndIf

  If *reading\valid And *reading\celsius >= *settings\Threshold1512
    desiredLevel = 0
  EndIf

  desiredLevel = ClampInt(desiredLevel, 0, 5)
  ProcedureReturn PlanNameFromLevel(desiredLevel)
EndProcedure

Procedure UpdateRuntimeState(*reading.TempReading, powerSource.i, activePlan$)
  LockMutex(gStateMutex)
  CopyTempReading(@gState\LastTemp, *reading)
  gState\PowerSource = powerSource
  If activePlan$ <> ""
    gState\ActivePlan = activePlan$
  EndIf
  UnlockMutex(gStateMutex)
EndProcedure

Procedure UpdateRuntimeControlState(*reading.TempReading)
  LockMutex(gStateMutex)
  CopyTempReading(@gState\LastControl, *reading)
  UnlockMutex(gStateMutex)
EndProcedure

Procedure UpdateRuntimeSourceSnapshots(*windows.TempReading, *fallback.TempReading)
  LockMutex(gStateMutex)
  CopyTempReading(@gState\LastWindows, *windows)
  CopyTempReading(@gState\LastFallback, *fallback)
  UnlockMutex(gStateMutex)
EndProcedure

Procedure.i AutoGameCoolStep(announceKeep.i = #False)
  Protected settings.AppSettings
  Protected reading.TempReading
  Protected controlReading.TempReading
  Protected windows.TempReading
  Protected fallback.TempReading
  Protected dependency.DependencyStatus
  Protected powerSource.i
  Protected previousPowerSource.i
  Protected currentPlan$
  Protected targetPlan$
  Protected autoWanted.i
  Protected pollSeconds.i
  Protected dgpuActive.i
  Protected dgpuPlan$
  Protected averageLabel$
  Static warnedMissing.i
  Static warnedSensor.i
  Static gameDetected.i
  Static highLoadSeconds.i
  Static lowLoadSeconds.i
  Static detectionActive.i
  Static detectionRestorePlan$

  CopySettings(@settings)
  pollSeconds = settings\PollSeconds
  powerSource = DetectPowerSource()

  LockMutex(gStateMutex)
  previousPowerSource = gState\PowerSource
  gState\PowerSource = powerSource
  UnlockMutex(gStateMutex)

  CaptureTelemetrySnapshot(@reading, @windows, @fallback)
  CopyTempReading(@controlReading, @reading)
  ApplyTelemetryAveraging(@controlReading, settings\GameCoolAverageSeconds * 1000)
  averageLabel$ = Str(settings\GameCoolAverageSeconds) + " sec avg"
  BuildDependencyStatusFromSnapshots(@dependency, @reading, @windows, @fallback, @settings)
  CacheDependencyStatus(@dependency)
  dgpuActive = Bool(ActiveDiscreteGpuConnected(@reading) Or ActiveDiscreteGpuConnected(@controlReading))
  currentPlan$ = GetActiveSchemeName()

  If currentPlan$ = #PlanVisible$
    currentPlan$ = GetCurrentManagedPlan()
  EndIf

  If currentPlan$ = ""
    LockMutex(gStateMutex)
    currentPlan$ = gState\ActivePlan
    UnlockMutex(gStateMutex)
  EndIf

  LockMutex(gStateMutex)
  gState\AutoEnabled = settings\AutoEnabled
  gState\AutoDetectGame = settings\AutoDetectGame
  UnlockMutex(gStateMutex)

  If settings\AutoDetectGame
    If controlReading\gpuLoadValid And controlReading\gpuLoadPct >= settings\GpuLoadThreshold
      highLoadSeconds + pollSeconds
      lowLoadSeconds = 0
      If gameDetected = #False And highLoadSeconds >= settings\GameStartDelay
        gameDetected = #True
        LogAction("GPU load trigger became active from " + averageLabel$ + " GPU load " + StrD(controlReading\gpuLoadPct, 1) + "%.")
      EndIf
    Else
      lowLoadSeconds + pollSeconds
      highLoadSeconds = 0
      If gameDetected And lowLoadSeconds >= settings\GameStopDelay
        gameDetected = #False
        LogAction("GPU load trigger cleared after load stayed below " + Str(settings\GpuLoadThreshold) + "%.")
      EndIf
    EndIf

    If controlReading\gpuLoadValid
      If gameDetected
        reading\gameReason = averageLabel$ + " GPU load " + StrD(controlReading\gpuLoadPct, 1) + "% is holding above the trigger."
      Else
        reading\gameReason = averageLabel$ + " GPU load " + StrD(controlReading\gpuLoadPct, 1) + "%, waiting for " + Str(settings\GameStartDelay) + " sec above " + Str(settings\GpuLoadThreshold) + "% before Cool mode starts."
      EndIf
    Else
      reading\gameReason = "Waiting for GPU load telemetry from the enabled sources."
    EndIf
  Else
    gameDetected = #False
    highLoadSeconds = 0
    lowLoadSeconds = 0
    reading\gameReason = ""
  EndIf

  reading\gameDetected = gameDetected
  controlReading\gameDetected = gameDetected
  controlReading\gameReason = reading\gameReason
  UpdateRuntimeState(@reading, powerSource, currentPlan$)
  UpdateRuntimeControlState(@controlReading)
  UpdateRuntimeSourceSnapshots(@windows, @fallback)

  If settings\AutoBatteryPlan And gameDetected = #False
    warnedSensor = #False
    detectionActive = #False
    detectionRestorePlan$ = ""

    Select powerSource
      Case #PowerSourceBattery
        If currentPlan$ <> #PlanBattery$
          LogAction("Battery/plugged auto is switching to " + #PlanBattery$)
          ProcedureReturn ActivatePlanByName(#PlanBattery$)
        ElseIf announceKeep
          LogAction("Battery/plugged auto is keeping " + #PlanBattery$)
        EndIf
        ProcedureReturn #False

      Case #PowerSourcePlugged
        If currentPlan$ <> #PlanFull$
          LogAction("Battery/plugged auto is switching to " + #PlanFull$)
          ProcedureReturn ActivatePlanByName(#PlanFull$)
        ElseIf announceKeep
          LogAction("Battery/plugged auto is keeping " + #PlanFull$)
        EndIf
        ProcedureReturn #False
    EndSelect
  EndIf

  autoWanted = settings\AutoEnabled
  If settings\AutoDetectGame
    autoWanted = Bool(autoWanted And gameDetected)
  EndIf

  If autoWanted = #False
    If detectionActive And powerSource = #PowerSourcePlugged
      detectionActive = #False
      If detectionRestorePlan$ <> ""
        targetPlan$ = detectionRestorePlan$
      Else
        targetPlan$ = ResolveIdleRememberedPluggedPlan(@settings)
      EndIf
      detectionRestorePlan$ = ""
      If targetPlan$ <> "" And currentPlan$ <> targetPlan$
        LogAction("Restoring " + targetPlan$ + " because the GPU load trigger is inactive.")
        ProcedureReturn ActivatePlanByName(targetPlan$)
      EndIf
    EndIf
    ProcedureReturn #False
  EndIf

  If ManagedPlansExist() = #False
    If warnedMissing = #False
      LogAction("Managed power plans are missing. Use Create Plans once as administrator.")
      warnedMissing = #True
    EndIf
    ProcedureReturn #False
  EndIf

  warnedMissing = #False

  Select powerSource
    Case #PowerSourceBattery
      warnedSensor = #False
      detectionActive = #False
      detectionRestorePlan$ = ""
      If currentPlan$ <> #PlanBattery$
        ProcedureReturn ActivatePlanByName(#PlanBattery$)
      ElseIf announceKeep
        LogAction("Battery power detected. Keeping " + #PlanBattery$)
      EndIf

    Case #PowerSourcePlugged
      detectionActive = #False
      detectionRestorePlan$ = ""

      If Date() < gManualOverrideUntil
        If announceKeep
          LogAction("Manual plan override is active. Keeping " + currentPlan$)
        EndIf
        ProcedureReturn #False
      EndIf

      If previousPowerSource = #PowerSourceBattery Or currentPlan$ = #PlanBattery$
        targetPlan$ = ResolveIdleRememberedPluggedPlan(@settings)
        If targetPlan$ <> "" And currentPlan$ <> targetPlan$
          LogAction("Plugged in power detected. Restoring " + targetPlan$)
          ProcedureReturn ActivatePlanByName(targetPlan$)
        EndIf
      EndIf

      If HasControlTelemetry(@controlReading, @settings) = #False
        If warnedSensor = #False
          ReadDependencyStatus(@dependency)
          If dependency\WindowsTelemetryReady = #False And dependency\FallbackAvailable = #False
            LogAction("No supported live Windows or fallback telemetry is currently available.")
          Else
            LogAction("No supported live temperature or power telemetry is currently available.")
          EndIf
          warnedSensor = #True
        EndIf
        ProcedureReturn #False
      EndIf

      warnedSensor = #False
      targetPlan$ = DecideAutoPlanSnapshot(@controlReading, currentPlan$, @settings)
      If targetPlan$ <> currentPlan$
        If ActivatePlanByName(targetPlan$)
          ProcedureReturn #True
        EndIf
        ProcedureReturn #False
      ElseIf announceKeep
        LogAction(BuildGameStateText(@reading, @settings) + " -> keep " + currentPlan$)
      EndIf

    Default
      If announceKeep
        LogAction("Power source is unknown. No plan change was made.")
      EndIf
  EndSelect
  ProcedureReturn #False
EndProcedure

Procedure WorkerThread(*unused)
  Protected pollSeconds.i
  Protected stopThread.i
  Protected waitSteps.i
  Protected immediateRefresh.i
  Protected windowVisible.i

  LockMutex(gStateMutex)
  gState\WorkerRunning = #True
  gState\StopWorker = #False
  UnlockMutex(gStateMutex)

  Repeat
    AutoGameCoolStep()

    LockMutex(gStateMutex)
    pollSeconds = gSettings\PollSeconds
    stopThread = gState\StopWorker
    UnlockMutex(gStateMutex)

    windowVisible = #False
    If IsWindow(#WindowMain)
      windowVisible = IsWindowVisible_(WindowID(#WindowMain))
    EndIf

    If stopThread
      Break
    EndIf

    pollSeconds = ClampInt(pollSeconds, 1, 60)
    If windowVisible And pollSeconds > 1
      pollSeconds = 1
    EndIf
    waitSteps = pollSeconds * 10
    While waitSteps > 0
      Delay(100)
      LockMutex(gStateMutex)
      stopThread = gState\StopWorker
      immediateRefresh = gState\ImmediateRefresh
      If immediateRefresh
        gState\ImmediateRefresh = #False
      EndIf
      UnlockMutex(gStateMutex)
      If stopThread
        Break
      EndIf
      If immediateRefresh
        Break
      EndIf
      waitSteps - 1
    Wend

  ForEver

  LockMutex(gStateMutex)
  gState\WorkerRunning = #False
  gWorkerThread = 0
  UnlockMutex(gStateMutex)
EndProcedure

Procedure StartWorkerThread()
  Protected alreadyRunning.i

  LockMutex(gStateMutex)
  alreadyRunning = gState\WorkerRunning
  gState\StopWorker = #False
  UnlockMutex(gStateMutex)

  If alreadyRunning = #False
    gWorkerThread = CreateThread(@WorkerThread(), 0)
    If gWorkerThread = 0
      LogAction("Failed to start the background worker thread.")
    Else
      AppendRuntimeLog("Background worker thread created.")
      LogAction("Background worker started.")
    EndIf
  EndIf
EndProcedure

Procedure StopWorkerThread()
  Protected worker.i

  LockMutex(gStateMutex)
  gState\StopWorker = #True
  worker = gWorkerThread
  UnlockMutex(gStateMutex)

  If worker
    WaitThread(worker)
  EndIf

  LockMutex(gStateMutex)
  gState\WorkerRunning = #False
  gWorkerThread = 0
  UnlockMutex(gStateMutex)
EndProcedure

Procedure.i CreateTrayImage()
  Protected loaded.i
  Protected fallbackIcon$

  If IsImage(#ImageTrayMain)
    FreeImage(#ImageTrayMain)
  EndIf

  If FileSize(InstalledTrayIconPath()) > 0
    loaded = LoadImage(#ImageTrayMain, InstalledTrayIconPath())
    If loaded
      ProcedureReturn #ImageTrayMain
    EndIf
  EndIf

  If FileSize(InstalledIconPath()) > 0
    loaded = LoadImage(#ImageTrayMain, InstalledIconPath())
    If loaded
      ProcedureReturn #ImageTrayMain
    EndIf
  EndIf

  fallbackIcon$ = #PB_Compiler_Home + "Examples\Sources\Data\CdPlayer.ico"
  If FileSize(fallbackIcon$) > 0
    loaded = LoadImage(#ImageTrayMain, fallbackIcon$)
    If loaded
      ProcedureReturn #ImageTrayMain
    EndIf
  EndIf

  ; Final fallback if icon loading fails.
  loaded = CreateImage(#ImageTrayMain, 16, 16, 24, RGB(255, 255, 255))

  If loaded And StartDrawing(ImageOutput(#ImageTrayMain))
    Box(0, 0, 16, 16, RGB(255, 255, 255))
    Box(1, 2, 12, 12, RGB(26, 34, 46))
    Box(2, 3, 10, 10, RGB(39, 167, 255))
    Box(13, 6, 2, 4, RGB(255, 196, 61))
    Box(4, 5, 3, 6, RGB(255, 255, 255))
    Box(7, 6, 1, 4, RGB(39, 167, 255))
    Box(8, 5, 3, 6, RGB(255, 255, 255))
    StopDrawing()
    ProcedureReturn #ImageTrayMain
  EndIf

  ProcedureReturn 0
EndProcedure

Procedure FreeNativeTrayIcons()
  If gTrayIconSmall
    DestroyIcon_(gTrayIconSmall)
    gTrayIconSmall = 0
  EndIf

  If gTrayIconLarge
    DestroyIcon_(gTrayIconLarge)
    gTrayIconLarge = 0
  EndIf
EndProcedure

Procedure.i LoadNativeTrayIcons()
  Protected largeIcon.i
  Protected smallIcon.i
  Protected iconSource$

  FreeNativeTrayIcons()

  iconSource$ = SystemIconLibraryPath()
  If FileSize(iconSource$) > 0
    ExtractIconEx_(iconSource$, 101, @largeIcon, @smallIcon, 1)
  EndIf

  If smallIcon = 0
    iconSource$ = InstalledTrayIconPath()
    If FileSize(iconSource$) > 0
      ExtractIconEx_(iconSource$, 0, @largeIcon, @smallIcon, 1)
    EndIf
  EndIf

  If smallIcon = 0
    iconSource$ = InstalledIconPath()
    If FileSize(iconSource$) > 0
      ExtractIconEx_(iconSource$, 0, @largeIcon, @smallIcon, 1)
    EndIf
  EndIf

  gTrayIconSmall = smallIcon
  gTrayIconLarge = largeIcon

  ProcedureReturn Bool(gTrayIconSmall <> 0)
EndProcedure

Procedure ApplyWindowIcons()
  Protected windowHandle.i

  If IsWindow(#WindowMain) = 0
    ProcedureReturn
  EndIf

  If gTrayIconSmall = 0
    If LoadNativeTrayIcons() = #False
      ProcedureReturn
    EndIf
  EndIf

  windowHandle = WindowID(#WindowMain)
  If gTrayIconSmall
    SendMessage_(windowHandle, #WM_SETICON, 0, gTrayIconSmall)
  EndIf
  If gTrayIconLarge
    SendMessage_(windowHandle, #WM_SETICON, 1, gTrayIconLarge)
  ElseIf gTrayIconSmall
    SendMessage_(windowHandle, #WM_SETICON, 1, gTrayIconSmall)
  EndIf
EndProcedure

Procedure PrepareNativeTrayData()
  If IsWindow(#WindowMain) = 0
    ProcedureReturn
  EndIf

  FillMemory(@gTrayData, SizeOf(NOTIFYICONDATA), 0)
  gTrayData\cbSize = SizeOf(NOTIFYICONDATA)
  gTrayData\hWnd = WindowID(#WindowMain)
  gTrayData\uID = #TrayIconMain
  gTrayData\uFlags = #NIF_MESSAGE | #NIF_ICON | #NIF_TIP
  gTrayData\uCallbackMessage = #TrayCallbackMsg
  gTrayData\hIcon = gTrayIconSmall
  PokeS(@gTrayData\szTip[0], #TrayTooltip$, -1, #PB_Unicode)
EndProcedure

Procedure.i AddNativeTrayIcon()
  If IsWindow(#WindowMain) = 0
    ProcedureReturn #False
  EndIf

  If gTrayIconSmall = 0
    If LoadNativeTrayIcons() = #False
      AppendRuntimeLog("LoadNativeTrayIcons failed")
      ProcedureReturn #False
    EndIf
  EndIf

  PrepareNativeTrayData()
  If Shell_NotifyIcon_(#NIM_ADD, @gTrayData)
    gTrayReady = #True
    AppendRuntimeLog("Shell_NotifyIcon add ok")
    ProcedureReturn #True
  EndIf

  AppendRuntimeLog("Shell_NotifyIcon add failed")
  ProcedureReturn #False
EndProcedure

Procedure.i AddNativeTrayIconWithRetry(attempts.i, delayMs.i)
  Protected attempt.i

  If attempts < 1
    attempts = 1
  EndIf

  For attempt = 1 To attempts
    If AddNativeTrayIcon()
      ProcedureReturn #True
    EndIf

    If attempt < attempts And delayMs > 0
      Delay(delayMs)
    EndIf
  Next

  ProcedureReturn #False
EndProcedure

Procedure RemoveNativeTrayIcon()
  If gTrayReady
    PrepareNativeTrayData()
    Shell_NotifyIcon_(#NIM_DELETE, @gTrayData)
    gTrayReady = #False
  EndIf
EndProcedure

Procedure SelectPlanComboByName(planName$)
  Protected i.i
  Protected count.i

  count = CountGadgetItems(#GadgetPlanCombo)
  For i = 0 To count - 1
    If GetGadgetItemText(#GadgetPlanCombo, i) = planName$
      UpdateGadgetStateIfNeeded(#GadgetPlanCombo, i)
      Break
    EndIf
  Next
EndProcedure

Procedure.s ValueWithSourceTag(valueText$, sourceText$)
  ProcedureReturn valueText$
EndProcedure

Procedure.s MergeLineLists(baseText$, extraText$)
  Protected merged$ = baseText$
  Protected cleaned$
  Protected lineCount.i
  Protected i.i
  Protected existing$

  cleaned$ = Trim(extraText$)
  If cleaned$ = ""
    ProcedureReturn merged$
  EndIf

  lineCount = CountString(cleaned$, #LF$) + 1
  For i = 1 To lineCount
    existing$ = Trim(StringField(cleaned$, i, #LF$))
    If existing$ = ""
      Continue
    EndIf

    If FindString(#LF$ + LCase(merged$) + #LF$, #LF$ + LCase(existing$) + #LF$, 1) = 0
      If merged$ <> ""
        merged$ + #LF$
      EndIf
      merged$ + existing$
    EndIf
  Next

ProcedureReturn merged$
EndProcedure

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

Procedure.s ResolveAmdGraphicsCuName(cuCount.i)
  If cuCount <= 0
    ProcedureReturn "AMD Radeon Graphics"
  EndIf

  ProcedureReturn "AMD Radeon Graphics (" + Str(cuCount) + " CUs)"
EndProcedure

Procedure.i IsGenericAmdIntegratedGpuName(hardwareName$)
  Protected lowered$ = LCase(Trim(hardwareName$))

  ProcedureReturn Bool(lowered$ = "amd radeon graphics" Or lowered$ = "radeon graphics" Or lowered$ = "amd radeon(tm) graphics" Or lowered$ = "radeon(tm) graphics")
EndProcedure

Procedure.s ResolveAmdIntegratedGpuName(cpuName$)
  Protected cpuMatchText$ = BuildCpuMatchText(cpuName$)

  If cpuMatchText$ = ""
    ProcedureReturn ""
  EndIf
  If FindString(cpuMatchText$, " amd ", 1) = 0
    ProcedureReturn ""
  EndIf

  ; Prefer AMD's published graphics model where the CPU family exposes one.
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

  ; When AMD only publishes a generic "Radeon Graphics" name, add CU count from the CPU SKU.
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

Procedure.s NormalizeGpuHardwareName(hardwareName$)
  Protected cleaned$ = Trim(hardwareName$)
  Protected lowered$
  Protected splitPos.i
  Protected resolvedAmdName$

  If cleaned$ = ""
    ProcedureReturn ""
  EndIf

  cleaned$ = ReplaceString(cleaned$, #CR$, " ")
  cleaned$ = ReplaceString(cleaned$, #LF$, " ")
  splitPos = FindString(cleaned$, " / ", 1)
  If splitPos > 0
    cleaned$ = Trim(Left(cleaned$, splitPos - 1))
  EndIf

  lowered$ = LCase(cleaned$)
  If lowered$ = ""
    ProcedureReturn ""
  EndIf

  If Left(lowered$, 5) = "luid_"
    ProcedureReturn ""
  EndIf
  If FindString(lowered$, "engtype_", 1)
    ProcedureReturn ""
  EndIf
  If lowered$ = "gpu adapter memory" Or lowered$ = "gpu engine" Or lowered$ = "emi meter" Or lowered$ = "pmi meter"
    ProcedureReturn ""
  EndIf
  If lowered$ = "vddgfx power" Or lowered$ = "vddcr_gfx power" Or lowered$ = "vddcr_soc power" Or lowered$ = "gpu power" Or lowered$ = "apu power" Or lowered$ = "current socket power" Or lowered$ = "rapl_package0_pkg" Or lowered$ = "gpu" Or lowered$ = "gfx" Or lowered$ = "soc"
    ProcedureReturn ""
  EndIf

  cleaned$ = ReplaceString(cleaned$, "(TM)", "")
  cleaned$ = ReplaceString(cleaned$, "(R)", "")
  cleaned$ = ReplaceString(cleaned$, "Microsoft Corporation ", "")
  While FindString(cleaned$, "  ", 1)
    cleaned$ = ReplaceString(cleaned$, "  ", " ")
  Wend

  If IsGenericAmdIntegratedGpuName(cleaned$)
    resolvedAmdName$ = ResolveAmdIntegratedGpuName(CachedCpuName())
    If resolvedAmdName$ <> ""
      cleaned$ = resolvedAmdName$
    EndIf
  EndIf

  ProcedureReturn cleaned$
EndProcedure

Procedure.s StripGpuRoleTags(hardwareName$)
  Protected cleaned$ = Trim(hardwareName$)

  cleaned$ = ReplaceString(cleaned$, "[iGPU]", "")
  cleaned$ = ReplaceString(cleaned$, "[dGPU]", "")
  cleaned$ = ReplaceString(cleaned$, "[eGPU]", "")
  While FindString(cleaned$, "  ", 1)
    cleaned$ = ReplaceString(cleaned$, "  ", " ")
  Wend

  ProcedureReturn Trim(cleaned$)
EndProcedure

Procedure.s CompactGpuHardwareName(hardwareName$, stripVendor.i = #False)
  Protected cleaned$ = NormalizeGpuHardwareName(StripGpuRoleTags(hardwareName$))
  Protected lowered$

  If cleaned$ = ""
    cleaned$ = StripGpuRoleTags(hardwareName$)
  EndIf

  If cleaned$ = ""
    ProcedureReturn ""
  EndIf

  If stripVendor
    lowered$ = LCase(cleaned$)
    If Left(lowered$, 4) = "amd "
      cleaned$ = Mid(cleaned$, 5)
    ElseIf Left(lowered$, 7) = "nvidia "
      cleaned$ = Mid(cleaned$, 8)
    ElseIf Left(lowered$, 6) = "intel "
      cleaned$ = Mid(cleaned$, 7)
    EndIf
  EndIf

  While FindString(cleaned$, "  ", 1)
    cleaned$ = ReplaceString(cleaned$, "  ", " ")
  Wend

  ProcedureReturn Trim(cleaned$)
EndProcedure

Procedure.s ExtractHardwareNameFromSensor(sensorText$)
  Protected cleaned$ = Trim(sensorText$)
  Protected trimmed$
  Protected prefix$

  If cleaned$ = ""
    ProcedureReturn ""
  EndIf

  prefix$ = "Preferred GPU: "
  If Left(cleaned$, Len(prefix$)) = prefix$
    trimmed$ = Mid(cleaned$, Len(prefix$) + 1)
    ProcedureReturn NormalizeGpuHardwareName(trimmed$)
  EndIf

  prefix$ = "Windows WMI performance / "
  If Left(cleaned$, Len(prefix$)) = prefix$
    trimmed$ = Mid(cleaned$, Len(prefix$) + 1)
    ProcedureReturn NormalizeGpuHardwareName(trimmed$)
  EndIf

  prefix$ = "Windows PMI power reading / "
  If Left(cleaned$, Len(prefix$)) = prefix$
    trimmed$ = Mid(cleaned$, Len(prefix$) + 1)
    ProcedureReturn NormalizeGpuHardwareName(trimmed$)
  EndIf

  prefix$ = "Windows power reading / EMI "
  If Left(cleaned$, Len(prefix$)) = prefix$
    trimmed$ = Mid(cleaned$, Len(prefix$) + 1)
    ProcedureReturn NormalizeGpuHardwareName(trimmed$)
  EndIf

  prefix$ = "Windows power reading / "
  If Left(cleaned$, Len(prefix$)) = prefix$
    trimmed$ = Mid(cleaned$, Len(prefix$) + 1)
    ProcedureReturn NormalizeGpuHardwareName(trimmed$)
  EndIf

  ProcedureReturn ""
EndProcedure

Procedure.i IsExternalGpuHardwareHint(text$)
  Protected lowered$ = LCase(Trim(text$))

  If lowered$ = ""
    ProcedureReturn #False
  EndIf

  ProcedureReturn Bool(FindString(lowered$, "external", 1) Or FindString(lowered$, "egpu", 1) Or FindString(lowered$, "usb4", 1) Or FindString(lowered$, "usb 4", 1) Or FindString(lowered$, "thunderbolt", 1) Or FindString(lowered$, "tapex creek", 1) Or FindString(lowered$, "goshen ridge", 1) Or FindString(lowered$, "maple ridge", 1) Or FindString(lowered$, "oculink", 1) Or FindString(lowered$, "ocu link", 1) Or FindString(lowered$, "external pcie", 1) Or FindString(lowered$, "external pci express", 1) Or FindString(lowered$, "egfx", 1))
EndProcedure

Procedure.s AnnotateGpuHardwareName(hardwareName$)
  Protected cleaned$ = Trim(hardwareName$)
  Protected lowered$
  Protected tag$

  If cleaned$ = ""
    ProcedureReturn ""
  EndIf

  lowered$ = LCase(cleaned$)

  If IsExternalGpuHardwareHint(lowered$)
    tag$ = "[eGPU]"
  ElseIf FindString(lowered$, "geforce", 1) Or FindString(lowered$, "nvidia", 1) Or FindString(lowered$, "radeon rx", 1) Or FindString(lowered$, " rx ", 1) Or FindString(lowered$, "arc ", 1)
    tag$ = "[dGPU]"
  ElseIf FindString(lowered$, "radeon graphics", 1) Or FindString(lowered$, "uhd", 1) Or FindString(lowered$, "iris", 1) Or FindString(lowered$, "xe graphics", 1) Or FindString(lowered$, "vega", 1) Or FindString(lowered$, "890m", 1) Or FindString(lowered$, "880m", 1) Or FindString(lowered$, "860m", 1) Or FindString(lowered$, "840m", 1) Or FindString(lowered$, "780m", 1) Or FindString(lowered$, "760m", 1) Or FindString(lowered$, "740m", 1) Or FindString(lowered$, "680m", 1) Or FindString(lowered$, "660m", 1) Or FindString(lowered$, "610m", 1) Or FindString(lowered$, "8060s", 1) Or FindString(lowered$, "8050s", 1) Or FindString(lowered$, "8040s", 1) Or FindString(lowered$, "integrated", 1) Or (FindString(lowered$, "intel", 1) And FindString(lowered$, "graphics", 1))
    tag$ = "[iGPU]"
  EndIf

  If tag$ <> ""
    ProcedureReturn cleaned$ + " " + tag$
  EndIf

  ProcedureReturn cleaned$
EndProcedure

Procedure.s GpuHardwareNamesFromReading(*reading.TempReading)
  Protected names$
  Protected hardware$
  Protected lineCount.i
  Protected i.i

  If *reading\gpuDeviceNames <> ""
    lineCount = CountString(*reading\gpuDeviceNames, #LF$) + 1
    For i = 1 To lineCount
      hardware$ = NormalizeGpuHardwareName(StringField(*reading\gpuDeviceNames, i, #LF$))
      If hardware$ <> ""
        names$ = MergeLineLists(names$, AnnotateGpuHardwareName(hardware$))
      EndIf
    Next
  EndIf

  hardware$ = ExtractHardwareNameFromSensor(*reading\gpuPowerSensor)
  If hardware$ <> ""
    names$ = MergeLineLists(names$, AnnotateGpuHardwareName(hardware$))
  EndIf

  hardware$ = ExtractHardwareNameFromSensor(*reading\gpuLoadSensor)
  If hardware$ <> ""
    names$ = MergeLineLists(names$, AnnotateGpuHardwareName(hardware$))
  EndIf

  hardware$ = ExtractHardwareNameFromSensor(*reading\gpuMemorySensor)
  If hardware$ <> ""
    names$ = MergeLineLists(names$, AnnotateGpuHardwareName(hardware$))
  EndIf

  ProcedureReturn names$
EndProcedure

Procedure.s CombinedGpuDeviceList(*reading.TempReading, *windows.TempReading)
  Protected names$

  names$ = MergeLineLists(names$, GpuHardwareNamesFromReading(*windows))
  names$ = MergeLineLists(names$, GpuHardwareNamesFromReading(*reading))

  ProcedureReturn names$
EndProcedure

Procedure.s SingleGpuHardwareFromList(deviceList$)
  Protected cleaned$ = Trim(deviceList$)
  Protected lineCount.i
  Protected i.i
  Protected value$
  Protected single$

  If cleaned$ = ""
    ProcedureReturn ""
  EndIf

  lineCount = CountString(cleaned$, #LF$) + 1
  For i = 1 To lineCount
    value$ = Trim(StringField(cleaned$, i, #LF$))
    If value$ = ""
      Continue
    EndIf

    If single$ = ""
      single$ = value$
    Else
      ProcedureReturn ""
    EndIf
  Next

  ProcedureReturn single$
EndProcedure

Procedure.s GpuRoleLabel(hardwareName$)
  Protected cleaned$ = Trim(hardwareName$)
  Protected lowered$ = LCase(cleaned$)

  If cleaned$ = ""
    ProcedureReturn ""
  EndIf

  If FindString(cleaned$, "[eGPU]", 1) Or IsExternalGpuHardwareHint(lowered$)
    ProcedureReturn "eGPU"
  EndIf
  If FindString(cleaned$, "[dGPU]", 1)
    ProcedureReturn "dGPU"
  EndIf
  If FindString(cleaned$, "[iGPU]", 1)
    ProcedureReturn "iGPU"
  EndIf

  ProcedureReturn ""
EndProcedure

Procedure.s CompactGpuSourceDisplay(*reading.TempReading)
  Protected names$ = GpuHardwareNamesFromReading(*reading)
  Protected lineCount.i
  Protected i.i
  Protected value$
  Protected role$
  Protected roles$
  Protected fallbackCount.i

  If names$ = ""
    ProcedureReturn ""
  EndIf

  lineCount = CountString(names$, #LF$) + 1
  For i = 1 To lineCount
    value$ = Trim(StringField(names$, i, #LF$))
    If value$ = ""
      Continue
    EndIf

    role$ = GpuRoleLabel(value$)
    If role$ <> ""
      roles$ = MergeLineLists(roles$, role$)
    Else
      fallbackCount + 1
    EndIf
  Next

  If roles$ <> ""
    roles$ = ReplaceString(roles$, #LF$, " + ")
    ProcedureReturn roles$
  EndIf

  If fallbackCount = 1
    ProcedureReturn "GPU"
  ElseIf fallbackCount > 1
    ProcedureReturn Str(fallbackCount) + " GPUs"
  EndIf

  ProcedureReturn ""
EndProcedure

Procedure.s ShortGpuSuffix(sensorText$, deviceList$)
  Protected hardware$
  Protected role$

  hardware$ = ExtractHardwareNameFromSensor(sensorText$)
  If hardware$ <> ""
    role$ = GpuRoleLabel(AnnotateGpuHardwareName(hardware$))
    If role$ <> ""
      ProcedureReturn role$
    EndIf
  EndIf

  hardware$ = SingleGpuHardwareFromList(deviceList$)
  If hardware$ <> ""
    role$ = GpuRoleLabel(hardware$)
    If role$ <> ""
      ProcedureReturn role$
    EndIf
  EndIf

  ProcedureReturn ""
EndProcedure

Procedure.i IsSharedGpuMemorySensor(sensorText$)
  ProcedureReturn Bool(FindString(UCase(sensorText$), "SHARED USAGE", 1) > 0)
EndProcedure

Procedure.i IsDedicatedGpuMemorySensor(sensorText$)
  ProcedureReturn Bool(FindString(UCase(sensorText$), "DEDICATED USAGE", 1) > 0)
EndProcedure

Procedure.i PreferSharedGpuMemoryDisplay(*reading.TempReading, deviceList$)
  Protected suffix$

  If *reading\gpuSharedMemoryValid = #False
    ProcedureReturn #False
  EndIf

  suffix$ = ShortGpuSuffix(*reading\gpuSharedMemorySensor, deviceList$)
  If suffix$ = ""
    suffix$ = ShortGpuSuffix(*reading\gpuMemorySensor, deviceList$)
  EndIf

  ProcedureReturn Bool(suffix$ = "iGPU")
EndProcedure

Procedure.s DisplayGpuMemoryValue(*reading.TempReading, deviceList$)
  Protected sharedSuffix$
  Protected primarySuffix$
  Protected sharedMb.d
  Protected dedicatedMb.d
  Protected totalMb.d
  Protected tagSensor$

  sharedSuffix$ = ShortGpuSuffix(*reading\gpuSharedMemorySensor, deviceList$)
  primarySuffix$ = ShortGpuSuffix(*reading\gpuMemorySensor, deviceList$)

  If *reading\gpuSharedMemoryValid And sharedSuffix$ = "iGPU"
    sharedMb = *reading\gpuSharedMemoryMb
    tagSensor$ = *reading\gpuSharedMemorySensor
  EndIf

  If *reading\gpuMemoryValid And primarySuffix$ = "iGPU"
    If IsSharedGpuMemorySensor(*reading\gpuMemorySensor)
      If sharedMb = 0.0
        sharedMb = *reading\gpuMemoryMb
        If tagSensor$ = ""
          tagSensor$ = *reading\gpuMemorySensor
        EndIf
      EndIf
    Else
      dedicatedMb = *reading\gpuMemoryMb
      If tagSensor$ = ""
        tagSensor$ = *reading\gpuMemorySensor
      EndIf
    EndIf
  EndIf

  totalMb = dedicatedMb + sharedMb
  If totalMb > 0.0
    If tagSensor$ <> ""
      ProcedureReturn ValueWithSourceTag(StrD(totalMb, 0) + " MB", tagSensor$) + " iGPU"
    EndIf
    ProcedureReturn StrD(totalMb, 0) + " MB iGPU"
  EndIf

  If PreferSharedGpuMemoryDisplay(*reading, deviceList$)
    ProcedureReturn FormatGpuTelemetryValue(#True, StrD(*reading\gpuSharedMemoryMb, 0) + " MB", *reading\gpuSharedMemorySensor, deviceList$)
  EndIf

  If *reading\gpuMemoryValid
    ProcedureReturn FormatGpuTelemetryValue(#True, StrD(*reading\gpuMemoryMb, 0) + " MB", *reading\gpuMemorySensor, deviceList$)
  EndIf

  If *reading\gpuSharedMemoryValid
    ProcedureReturn FormatGpuTelemetryValue(#True, StrD(*reading\gpuSharedMemoryMb, 0) + " MB", *reading\gpuSharedMemorySensor, deviceList$)
  EndIf

  ProcedureReturn "Unavailable"
EndProcedure

Procedure.s BuildTelemetrySourceDisplay(*reading.TempReading)
  Protected display$ = *reading\source
  Protected gpuHardware$
  Protected primary$

  gpuHardware$ = CompactGpuSourceDisplay(*reading)

  primary$ = UCase(*reading\source)
  If FindString(primary$, "WINDOWS", 1)
    display$ = "Windows telemetry"
  ElseIf FindString(primary$, "ACPI", 1)
    display$ = "Fallback temperature"
  ElseIf FindString(primary$, "FALLBACK", 1)
    display$ = "Fallback temperature"
  ElseIf *reading\source = ""
    display$ = ""
  EndIf

  If gpuHardware$ <> ""
    If display$ = "Windows telemetry"
      display$ + ", " + gpuHardware$
    ElseIf display$ = ""
      display$ = gpuHardware$
    Else
      display$ + " / " + gpuHardware$
    EndIf
  EndIf

  If display$ = ""
    display$ = "Unavailable"
  EndIf

  ProcedureReturn display$
EndProcedure

Procedure.s FormatReadingValue(label$, valid.i, valueText$, sensorText$)
  Protected hardware$

  If valid
    If sensorText$ <> ""
      hardware$ = ExtractHardwareNameFromSensor(sensorText$)
      If hardware$ <> ""
        ProcedureReturn label$ + ": " + valueText$ + " on " + AnnotateGpuHardwareName(hardware$)
      EndIf
      ProcedureReturn label$ + ": " + valueText$
    EndIf
    ProcedureReturn label$ + ": " + valueText$
  EndIf

  ProcedureReturn label$ + ": unavailable"
EndProcedure

Procedure.s FormatTelemetryValue(valid.i, valueText$, sensorText$, includeHardware.i = #False)
  Protected hardware$

  If valid = #False
    ProcedureReturn "Unavailable"
  EndIf

  If sensorText$ <> ""
    hardware$ = ExtractHardwareNameFromSensor(sensorText$)
    If includeHardware And hardware$ <> ""
      ProcedureReturn ValueWithSourceTag(valueText$, sensorText$) + " on " + AnnotateGpuHardwareName(hardware$)
    EndIf
    ProcedureReturn ValueWithSourceTag(valueText$, sensorText$)
  EndIf

  ProcedureReturn valueText$
EndProcedure

Procedure.s FormatGpuTelemetryValue(valid.i, valueText$, sensorText$, deviceList$)
  Protected suffix$

  If valid = #False
    ProcedureReturn "Unavailable"
  EndIf

  suffix$ = ShortGpuSuffix(sensorText$, deviceList$)
  If suffix$ <> ""
    If sensorText$ <> ""
      ProcedureReturn ValueWithSourceTag(valueText$, sensorText$) + " " + suffix$
    EndIf
    ProcedureReturn valueText$ + " " + suffix$
  EndIf

  ProcedureReturn FormatTelemetryValue(valid, valueText$, sensorText$)
EndProcedure

Procedure.s CurrentGpuHardwareDisplay(*reading.TempReading)
  Protected names$ = GpuHardwareNamesFromReading(*reading)
  Protected lineCount.i
  Protected i.i
  Protected value$
  Protected display$

  If names$ = ""
    ProcedureReturn ""
  EndIf

  lineCount = CountString(names$, #LF$) + 1
  For i = 1 To lineCount
    value$ = Trim(StringField(names$, i, #LF$))
    If value$ = ""
      Continue
    EndIf

    If display$ <> ""
      display$ + ", "
    EndIf
    display$ + value$
  Next

  ProcedureReturn display$
EndProcedure

Procedure.s BuildGpuDeviceSummary(*reading.TempReading, *windows.TempReading)
  Protected names$
  Protected lineCount.i
  Protected i.i
  Protected value$
  Protected text$

  names$ = CombinedGpuDeviceList(*reading, *windows)

  If names$ = ""
    ProcedureReturn "GPU names appear here when Windows exposes them."
  EndIf

  lineCount = CountString(names$, #LF$) + 1
  For i = 1 To lineCount
    value$ = Trim(StringField(names$, i, #LF$))
    If value$ = ""
      Continue
    EndIf

    If text$ <> ""
      text$ + #LF$
    EndIf

    If FindString(value$, "[eGPU]", 1)
      text$ + "eGPU: " + CompactGpuHardwareName(value$, #False)
    ElseIf FindString(value$, "[iGPU]", 1)
      text$ + "iGPU: " + CompactGpuHardwareName(value$, #False)
    ElseIf FindString(value$, "[dGPU]", 1)
      text$ + "dGPU: " + CompactGpuHardwareName(value$, #False)
    Else
      text$ + "GPU: " + CompactGpuHardwareName(value$, #False)
    EndIf
  Next

  ProcedureReturn text$
EndProcedure

Procedure.s ReadRegistryString(rootKey.i, subKey$, valueName$)
  Protected keyHandle.i
  Protected result.i
  Protected valueType.l
  Protected dataSize.l
  Protected *buffer
  Protected value$

  result = RegOpenKeyEx_(rootKey, subKey$, 0, #KEY_READ, @keyHandle)
  If result <> 0
    ProcedureReturn ""
  EndIf

  result = RegQueryValueEx_(keyHandle, valueName$, 0, @valueType, 0, @dataSize)
  If result = 0 And dataSize > 1 And (valueType = #REG_SZ Or valueType = #REG_EXPAND_SZ)
    *buffer = AllocateMemory(dataSize + 2)
    If *buffer
      FillMemory(*buffer, dataSize + 2, 0)
      If RegQueryValueEx_(keyHandle, valueName$, 0, @valueType, *buffer, @dataSize) = 0
        value$ = PeekS(*buffer, -1, #PB_Unicode)
      EndIf
      FreeMemory(*buffer)
    EndIf
  EndIf

  RegCloseKey_(keyHandle)
  ProcedureReturn Trim(value$)
EndProcedure

Procedure.s NormalizeCpuName(cpuName$)
  Protected cleaned$ = Trim(cpuName$)
  Protected lowered$
  Protected splitPos.i

  cleaned$ = ReplaceString(cleaned$, "(TM)", "")
  cleaned$ = ReplaceString(cleaned$, "(R)", "")
  lowered$ = LCase(cleaned$)
  splitPos = FindString(lowered$, " with ", 1)
  If splitPos > 0 And FindString(lowered$, "graphics", splitPos + 6)
    cleaned$ = Trim(Left(cleaned$, splitPos - 1))
  EndIf

  While FindString(cleaned$, "  ", 1)
    cleaned$ = ReplaceString(cleaned$, "  ", " ")
  Wend

  ProcedureReturn Trim(cleaned$)
EndProcedure

Procedure.s CachedCpuName()
  If gCachedCpuName$ = ""
    gCachedCpuName$ = NormalizeCpuName(ReadRegistryString(#HKEY_LOCAL_MACHINE, "HARDWARE\DESCRIPTION\System\CentralProcessor\0", "ProcessorNameString"))
  EndIf

  ProcedureReturn gCachedCpuName$
EndProcedure

Procedure.i QueryMemoryStatus(*memory.MEMORYSTATUSEX)
  FillMemory(*memory, SizeOf(MEMORYSTATUSEX), 0)
  *memory\dwLength = SizeOf(MEMORYSTATUSEX)
  ProcedureReturn GlobalMemoryStatusEx_(*memory)
EndProcedure

Procedure.q InstalledSystemMemoryBytes()
  Protected output$
  Protected memory.MEMORYSTATUSEX

  If gInstalledMemoryBytes <= 0
    output$ = RunCapture("powershell.exe", "-NoProfile -ExecutionPolicy Bypass -Command " + QuoteArgument("(Get-CimInstance Win32_PhysicalMemory | Measure-Object Capacity -Sum).Sum"))
    If Trim(output$) <> ""
      gInstalledMemoryBytes = Int(ValD(Trim(output$)))
    EndIf

    If gInstalledMemoryBytes <= 0 And QueryMemoryStatus(@memory)
      gInstalledMemoryBytes = memory\ullTotalPhys
    EndIf
  EndIf

  ProcedureReturn gInstalledMemoryBytes
EndProcedure

Procedure.s FormatBytesAsGb(bytes.q)
  If bytes <= 0
    ProcedureReturn "Unavailable"
  EndIf

  ProcedureReturn StrD(bytes / (1024.0 * 1024.0 * 1024.0), 1) + " GB"
EndProcedure

Procedure.s FormatMegabytesCompact(valueMb.d)
  If valueMb <= 0.0
    ProcedureReturn "0 MB"
  EndIf

  If valueMb >= 1024.0
    ProcedureReturn StrD(valueMb / 1024.0, 1) + " GB"
  EndIf

  ProcedureReturn StrD(valueMb, 0) + " MB"
EndProcedure

Procedure.s BuildOverviewHardwareDetails(*reading.TempReading, *windows.TempReading)
  Protected text$
  Protected cpu$
  Protected gpu$
  Protected installedBytes.q
  Protected memory.MEMORYSTATUSEX
  Protected visibleBytes.q
  Protected usedBytes.q
  Protected sharedMb.d
  Protected dedicatedMb.d
  Protected totalMb.d
  Protected sharedValid.i
  Protected dedicatedValid.i
  Protected sharedSensor$
  Protected dedicatedSensor$
  Protected sharedLabel$
  Protected memoryLabel$
  Protected deviceList$

  cpu$ = CachedCpuName()
  If cpu$ = ""
    cpu$ = "Unavailable"
  EndIf

  text$ = "CPU: " + cpu$

  gpu$ = BuildGpuDeviceSummary(*reading, *windows)
  If gpu$ = "GPU names appear here when Windows exposes them."
    text$ + #LF$ + "GPU: Waiting for Windows"
  Else
    text$ + #LF$ + gpu$
  EndIf

  If QueryMemoryStatus(@memory)
    visibleBytes = memory\ullTotalPhys
    usedBytes = memory\ullTotalPhys - memory\ullAvailPhys
    text$ + #LF$ + "RAM: " + FormatBytesAsGb(usedBytes) + " used / " + FormatBytesAsGb(visibleBytes)
  Else
    text$ + #LF$ + "RAM: Unavailable"
  EndIf

  installedBytes = InstalledSystemMemoryBytes()
  If installedBytes > 0
    text$ + #LF$ + "Installed RAM: " + FormatBytesAsGb(installedBytes)
  EndIf

  deviceList$ = CombinedGpuDeviceList(*reading, *windows)

  If *windows\gpuMemoryValid
    dedicatedValid = #True
    dedicatedMb = *windows\gpuMemoryMb
    dedicatedSensor$ = *windows\gpuMemorySensor
  ElseIf *reading\gpuMemoryValid
    dedicatedValid = #True
    dedicatedMb = *reading\gpuMemoryMb
    dedicatedSensor$ = *reading\gpuMemorySensor
  EndIf

  If *windows\gpuSharedMemoryValid
    sharedValid = #True
    sharedMb = *windows\gpuSharedMemoryMb
    sharedSensor$ = *windows\gpuSharedMemorySensor
  ElseIf *reading\gpuSharedMemoryValid
    sharedValid = #True
    sharedMb = *reading\gpuSharedMemoryMb
    sharedSensor$ = *reading\gpuSharedMemorySensor
  EndIf

  memoryLabel$ = ShortGpuSuffix(sharedSensor$, deviceList$)
  If memoryLabel$ = ""
    memoryLabel$ = ShortGpuSuffix(dedicatedSensor$, deviceList$)
  EndIf

  If memoryLabel$ = "iGPU"
    If dedicatedValid And IsSharedGpuMemorySensor(dedicatedSensor$) = #False
      totalMb + dedicatedMb
    EndIf
    If sharedValid
      totalMb + sharedMb
    EndIf

    If totalMb > 0.0
      text$ + #LF$ + "iGPU memory: " + FormatMegabytesCompact(totalMb) + " total"
      If dedicatedValid And IsDedicatedGpuMemorySensor(dedicatedSensor$)
        text$ + " (" + FormatMegabytesCompact(dedicatedMb) + " reserved"
        If sharedValid
          text$ + " + " + FormatMegabytesCompact(sharedMb) + " shared"
        EndIf
        text$ + ")"
      ElseIf sharedValid
        text$ + " (" + FormatMegabytesCompact(sharedMb) + " shared)"
      ElseIf dedicatedValid
        text$ + " (" + FormatMegabytesCompact(dedicatedMb) + " primary)"
      EndIf
    EndIf
  ElseIf sharedValid
    sharedLabel$ = ShortGpuSuffix(sharedSensor$, deviceList$)
    If sharedLabel$ <> ""
      text$ + #LF$ + sharedLabel$ + " shared RAM: " + FormatMegabytesCompact(sharedMb) + " in use"
    Else
      text$ + #LF$ + "GPU shared RAM: " + FormatMegabytesCompact(sharedMb) + " in use"
    EndIf
  Else
    text$ + #LF$ + "GPU shared RAM: Not exposed"
  EndIf

  ProcedureReturn text$
EndProcedure

Procedure.i ActiveDiscreteGpuConnected(*reading.TempReading)
  Protected hardware$ = CurrentGpuHardwareDisplay(*reading)

  If FindString(hardware$, "[eGPU]", 1) Or FindString(hardware$, "[dGPU]", 1)
    ProcedureReturn #True
  EndIf

  ProcedureReturn #False
EndProcedure

Procedure RememberRuntimeDgpuPlanIfActive(planName$, persist.i = #False)
  Protected reading.TempReading

  If IsRememberedPluggedPlanName(planName$) = #False
    ProcedureReturn
  EndIf

  LockMutex(gStateMutex)
  CopyTempReading(@reading, @gState\LastControl)
  UnlockMutex(gStateMutex)

  If ActiveDiscreteGpuConnected(@reading)
    RememberDgpuPluggedPlan(planName$, persist)
  EndIf
EndProcedure

Procedure.s DriverProviderText(*reading.TempReading)
  Protected sourceUpper$ = UCase(*reading\gpuPowerSensor)
  Protected hardware$

  hardware$ = CurrentGpuHardwareDisplay(*reading)

  If *reading\gpuPowerSensor = ""
    If hardware$ <> ""
      ProcedureReturn "No GPU power reading for " + hardware$
    EndIf
    ProcedureReturn "No GPU power reading"
  EndIf

  If IsEstimatedGpuPowerSensor(*reading\gpuPowerSensor)
    If hardware$ <> ""
      ProcedureReturn "Windows power reading for " + hardware$
    EndIf
    ProcedureReturn "Windows power reading"
  EndIf

  If FindString(sourceUpper$, "WINDOWS", 1)
    If hardware$ <> ""
      ProcedureReturn "Windows telemetry for " + hardware$
    EndIf
    ProcedureReturn "Windows telemetry"
  EndIf

  If hardware$ <> ""
    ProcedureReturn hardware$
  EndIf

  ProcedureReturn *reading\gpuPowerSensor
EndProcedure

Procedure.s SecondaryFallbackSummary(*reading.TempReading, *windows.TempReading, *fallback.TempReading, *settings.AppSettings)
  If *fallback\valid
    ProcedureReturn "Generic fallback sensor" + #LF$ + FormatTelemetryValue(#True, StrD(*fallback\celsius, 1) + " C", *fallback\sensor)
  EndIf

  If *windows\valid Or *windows\cpuPackageValid Or *windows\gpuPowerValid Or *windows\gpuLoadValid Or *windows\gpuMemoryValid
    ProcedureReturn "No generic fallback reading is active."
  EndIf

  ProcedureReturn "No generic fallback reading is active."
EndProcedure

Procedure RefreshStatusDisplay()
  Protected reading.TempReading
  Protected windows.TempReading
  Protected fallback.TempReading
  Protected powerSource.i
  Protected activePlan$
  Protected autoEnabled.i
  Protected autoDetectGame.i
  Protected logText$
  Protected status.DependencyStatus
  Protected tempText$
  Protected cpuPowerText$
  Protected apuPowerText$
  Protected gpuPowerText$
  Protected gpuLoadText$
  Protected gpuMemoryText$
  Protected gameStateText$
  Protected telemetrySourceText$
  Protected blendGpuDevices$
  Protected liveGpuDevicesText$
  Protected overviewHardwareText$

  LockMutex(gStateMutex)
  CopyTempReading(@reading, @gState\LastTemp)
  CopyTempReading(@windows, @gState\LastWindows)
  CopyTempReading(@fallback, @gState\LastFallback)
  powerSource = gState\PowerSource
  activePlan$ = gState\ActivePlan
  autoEnabled = gState\AutoEnabled
  autoDetectGame = gState\AutoDetectGame
  logText$ = BuildUiLogText()
  UnlockMutex(gStateMutex)
  CopyCachedDependencyStatus(@status)

  If reading\valid
    tempText$ = ValueWithSourceTag(StrD(reading\celsius, 1) + " C", reading\source)
  Else
    tempText$ = "Unavailable"
  EndIf

  If reading\cpuPackageValid
    cpuPowerText$ = ValueWithSourceTag(StrD(reading\cpuPackageWatts, 1) + " W", reading\cpuPackageSensor)
  ElseIf status\WindowsTelemetryReady And status\WindowsPowerReady = #False
    cpuPowerText$ = "Windows not exposed"
  Else
    cpuPowerText$ = "Unavailable"
  EndIf

  If reading\apuPowerValid
    apuPowerText$ = ValueWithSourceTag(StrD(reading\apuPowerWatts, 1) + " W", reading\apuPowerSensor)
  Else
    apuPowerText$ = "Unavailable"
  EndIf

  blendGpuDevices$ = GpuHardwareNamesFromReading(@reading)

  If reading\gpuPowerValid
    gpuPowerText$ = FormatGpuTelemetryValue(#True, StrD(reading\gpuPowerWatts, 1) + " W", reading\gpuPowerSensor, blendGpuDevices$)
  Else
    gpuPowerText$ = "Unavailable"
  EndIf

  If reading\gpuLoadValid
    gpuLoadText$ = FormatGpuTelemetryValue(#True, StrD(reading\gpuLoadPct, 1) + " %", reading\gpuLoadSensor, blendGpuDevices$)
  Else
    gpuLoadText$ = "Unavailable"
  EndIf

  gpuMemoryText$ = DisplayGpuMemoryValue(@reading, blendGpuDevices$)

  gameStateText$ = BuildGameStateText(@reading, @gSettings)
  If activePlan$ = "" : activePlan$ = "Unknown" : EndIf
  telemetrySourceText$ = BuildTelemetrySourceDisplay(@reading)

  UpdateTextGadgetIfNeeded(#GadgetOverviewSourceValue, telemetrySourceText$)
  If reading\sensor <> ""
    UpdateTextGadgetIfNeeded(#GadgetOverviewTempSensorValue, reading\sensor)
  Else
    UpdateTextGadgetIfNeeded(#GadgetOverviewTempSensorValue, "Unavailable")
  EndIf
  UpdateTextGadgetIfNeeded(#GadgetOverviewTempValue, tempText$)
  UpdateTextGadgetIfNeeded(#GadgetOverviewApuPowerValue, apuPowerText$)
  UpdateTextGadgetIfNeeded(#GadgetOverviewGpuPowerValue, gpuPowerText$)
  UpdateTextGadgetIfNeeded(#GadgetOverviewCpuPowerValue, cpuPowerText$)
  UpdateTextGadgetIfNeeded(#GadgetOverviewGpuLoadValue, gpuLoadText$)
  UpdateTextGadgetIfNeeded(#GadgetOverviewGpuMemoryValue, gpuMemoryText$)
  UpdateTextGadgetIfNeeded(#GadgetOverviewPowerValue, PowerSourceText(powerSource))
  UpdateTextGadgetIfNeeded(#GadgetOverviewPlanValue, activePlan$)
  UpdateTextGadgetIfNeeded(#GadgetOverviewGameStateValue, gameStateText$)
  overviewHardwareText$ = BuildOverviewHardwareDetails(@reading, @windows)
  UpdateTextGadgetIfNeeded(#GadgetOverviewHardwareDetails, overviewHardwareText$)

  liveGpuDevicesText$ = BuildGpuDeviceSummary(@reading, @windows)

  UpdateTextGadgetIfNeeded(#GadgetLiveBlendSourceMix, telemetrySourceText$)
  If reading\sensor <> ""
    UpdateTextGadgetIfNeeded(#GadgetLiveBlendTempSensor, reading\sensor)
  Else
    UpdateTextGadgetIfNeeded(#GadgetLiveBlendTempSensor, "Unavailable")
  EndIf
  UpdateTextGadgetIfNeeded(#GadgetLiveBlendTemp, tempText$)
  UpdateTextGadgetIfNeeded(#GadgetLiveBlendCpu, cpuPowerText$)
  UpdateTextGadgetIfNeeded(#GadgetLiveBlendApu, apuPowerText$)
  UpdateTextGadgetIfNeeded(#GadgetLiveBlendGpuPower, gpuPowerText$)
  UpdateTextGadgetIfNeeded(#GadgetLiveBlendGpuLoad, gpuLoadText$)
  UpdateTextGadgetIfNeeded(#GadgetLiveBlendGpuMemory, gpuMemoryText$)
  UpdateTextGadgetIfNeeded(#GadgetLiveBlendPowerSource, PowerSourceText(powerSource))
  UpdateTextGadgetIfNeeded(#GadgetLiveBlendActivePlan, activePlan$)
  UpdateTextGadgetIfNeeded(#GadgetLiveBlendGameState, gameStateText$)

  UpdateTextGadgetIfNeeded(#GadgetLiveFallbackStatus, liveGpuDevicesText$)

  If gLastUiLogText$ <> logText$
    SetEditorText(#GadgetActionValue, logText$)
    gLastUiLogText$ = logText$
  EndIf
  gHelpAlertNeeded = DependencyAlertNeeded()
  DrawHelpButton()
  logText$ = BuildMainStatusText(@reading, autoEnabled, autoDetectGame)
  If gLastStatusText$ <> logText$
    UpdateTextGadgetIfNeeded(#GadgetStatusLine, logText$)
    gLastStatusText$ = logText$
  EndIf
EndProcedure

Procedure RefreshRuntimeSnapshot()
  Protected reading.TempReading
  Protected windows.TempReading
  Protected fallback.TempReading
  Protected dependency.DependencyStatus
  Protected settings.AppSettings
  Protected powerSource.i
  Protected activePlan$

  CopySettings(@settings)
  CaptureTelemetrySnapshot(@reading, @windows, @fallback)
  powerSource = DetectPowerSource()
  activePlan$ = GetActiveSchemeName()
  BuildDependencyStatusFromSnapshots(@dependency, @reading, @windows, @fallback, @settings)
  CacheDependencyStatus(@dependency)

  If activePlan$ = #PlanVisible$
    activePlan$ = GetCurrentManagedPlan()
  EndIf

  If activePlan$ = ""
    LockMutex(gStateMutex)
    activePlan$ = gState\ActivePlan
    UnlockMutex(gStateMutex)
  EndIf

  UpdateRuntimeState(@reading, powerSource, activePlan$)
  UpdateRuntimeSourceSnapshots(@windows, @fallback)

  LockMutex(gStateMutex)
  gState\AutoEnabled = gSettings\AutoEnabled
  gState\AutoDetectGame = gSettings\AutoDetectGame
  UnlockMutex(gStateMutex)
EndProcedure

Procedure UpdateUiRefreshTimer()
  If IsWindow(#WindowMain)
    RemoveWindowTimer(#WindowMain, #TimerUiRefresh)
    AddWindowTimer(#WindowMain, #TimerUiRefresh, #UiRefreshMs)
  EndIf
EndProcedure

Procedure RequestImmediateTelemetryRefresh()
  LockMutex(gStateMutex)
  gState\LastTemp\valid = #False
  gState\LastTemp\source = "Refreshing..."
  gState\LastTemp\sensor = "Waiting for enabled data sources"
  gState\LastTemp\celsius = 0.0
  gState\LastTemp\windowsTempValid = #False
  gState\LastTemp\windowsTempSensor = ""
  gState\LastTemp\windowsTempCelsius = 0.0
  gState\LastTemp\cpuPackageValid = #False
  gState\LastTemp\cpuPackageSensor = ""
  gState\LastTemp\cpuPackageWatts = 0.0
  gState\LastTemp\apuPowerValid = #False
  gState\LastTemp\apuPowerSensor = ""
  gState\LastTemp\apuPowerWatts = 0.0
  gState\LastTemp\gpuPowerValid = #False
  gState\LastTemp\gpuPowerSensor = ""
  gState\LastTemp\gpuPowerWatts = 0.0
  gState\LastTemp\gpuLoadValid = #False
  gState\LastTemp\gpuLoadSensor = ""
  gState\LastTemp\gpuLoadPct = 0.0
  gState\LastTemp\gpuMemoryValid = #False
  gState\LastTemp\gpuMemorySensor = ""
  gState\LastTemp\gpuMemoryMb = 0.0
  gState\LastTemp\gpuSharedMemoryValid = #False
  gState\LastTemp\gpuSharedMemorySensor = ""
  gState\LastTemp\gpuSharedMemoryMb = 0.0
  gState\LastTemp\gameDetected = #False
  gState\LastTemp\gameReason = ""
  ResetTempReading(@gState\LastControl)
  gState\LastWindows\valid = #False
  gState\LastWindows\source = ""
  gState\LastFallback\valid = #False
  gState\LastFallback\source = ""
  ResetTelemetryLatchState(@gBlendTelemetryLatch)
  ResetTelemetryLatchState(@gWindowsTelemetryLatch)
  ResetTelemetryLatchState(@gFallbackTelemetryLatch)
  gLastHelpAlertState = -1
  gState\ImmediateRefresh = #True
  UnlockMutex(gStateMutex)
EndProcedure

Procedure SaveSettingsFromGui()
  PullSettingsFromGui()
  SaveSettings()
  SetStartupRegistry(gSettings\AutoStartWithApp)
  UpdateUiRefreshTimer()

  LockMutex(gStateMutex)
  gState\AutoEnabled = gSettings\AutoEnabled
  UnlockMutex(gStateMutex)

  PushSettingsToGui()
  LogAction("Settings saved.")
  RefreshStatusDisplay()
EndProcedure

Procedure ApplyLiveCheckboxSettings(logText$ = "")
  Protected previousAutoStart.i

  LockMutex(gStateMutex)
  previousAutoStart = gSettings\AutoStartWithApp
  UnlockMutex(gStateMutex)

  PullSettingsFromGui()
  SaveSettings()
  ResetTelemetrySmoothing()
  If previousAutoStart <> gSettings\AutoStartWithApp
    SetStartupRegistry(gSettings\AutoStartWithApp)
  EndIf
  UpdateUiRefreshTimer()

  LockMutex(gStateMutex)
  gState\AutoEnabled = gSettings\AutoEnabled
  gState\AutoDetectGame = gSettings\AutoDetectGame
  UnlockMutex(gStateMutex)

  RequestImmediateTelemetryRefresh()
  RefreshStatusDisplay()

  If logText$ <> ""
    LogAction(logText$)
    RefreshStatusDisplay()
  EndIf
EndProcedure

Procedure SelectPrimaryTelemetrySource(enabled.i)
  UpdateGadgetStateIfNeeded(#GadgetUseWindows, enabled)
EndProcedure

Procedure HideToTray()
  If gTrayReady
    HideWindow(#WindowMain, #True)
  Else
    HideWindow(#WindowMain, #False)
    SetForegroundWindow_(WindowID(#WindowMain))
    LogAction("Tray unavailable. Window stays visible.")
    RefreshStatusDisplay()
  EndIf
EndProcedure

Procedure ShowFromTray()
  Protected windowHandle.i

  If IsWindow(#WindowMain) = 0
    ProcedureReturn
  EndIf

  windowHandle = WindowID(#WindowMain)
  HideWindow(#WindowMain, #False)
  ShowWindow_(windowHandle, #SW_RESTORE)
  SetWindowPos_(windowHandle, #HWND_TOPMOST, 0, 0, 0, 0, #SWP_NOMOVE | #SWP_NOSIZE | #SWP_NOACTIVATE)
  SetWindowPos_(windowHandle, #HWND_NOTOPMOST, 0, 0, 0, 0, #SWP_NOMOVE | #SWP_NOSIZE | #SWP_NOACTIVATE)
  BringWindowToTop_(windowHandle)
  SetActiveWindow_(windowHandle)
  SetForegroundWindow_(windowHandle)
EndProcedure

Procedure.i MainWindowCallback(windowHandle.i, message.i, wParam.i, lParam.i)
  Select message
    Case #TrayCallbackMsg
      Select lParam
        Case #WM_LBUTTONUP, #WM_LBUTTONDBLCLK
          ShowFromTray()
          ProcedureReturn 0

        Case #WM_RBUTTONUP, #WM_CONTEXTMENU
          If IsWindow(#WindowMain)
            SetForegroundWindow_(WindowID(#WindowMain))
            DisplayPopupMenu(#PopupTray, WindowID(#WindowMain))
          EndIf
          ProcedureReturn 0
      EndSelect
  EndSelect

  ProcedureReturn #PB_ProcessPureBasicEvents
EndProcedure

Procedure ShutdownApp(exitCode.i = 0)
  StopWorkerThread()
  StopWindowsPerfHelper()
  RemoveNativeTrayIcon()
  If IsImage(gTrayImage)
    FreeImage(gTrayImage)
    gTrayImage = 0
  EndIf
  FreeNativeTrayIcons()
  End exitCode
EndProcedure

Procedure CreateTrayMenu()
  If CreatePopupImageMenu(#PopupTray)
    MenuItem(#MenuOpen, "Open PowerPilot")
    MenuBar()
    MenuItem(#MenuToggleAuto, "Toggle Auto Cool")
    MenuItem(#MenuAutoOnce, "Run Auto Cool Once")
    MenuBar()
    MenuItem(#MenuBattery, "Activate Battery Saver")
    MenuItem(#MenuPlugged, "Activate Plugged In")
    MenuItem(#MenuFull, "Activate Full Power")
    MenuBar()
    MenuItem(#MenuDependencies, "Help")
    MenuBar()
    MenuItem(#MenuCreatePlans, "Create Or Refresh Plans")
    MenuItem(#MenuCleanupPlans, "Remove Managed Plans")
    MenuBar()
    MenuItem(#MenuExit, "Exit")
  EndIf
EndProcedure

Procedure RefreshDependencyWindow()
  Protected summary$
  Protected info$
  Protected launch$

  If IsWindow(#WindowDependency) = 0
    ProcedureReturn
  EndIf

  summary$ = BuildDependencySummary()
  info$ = BuildDependencyInstructions()
  launch$ = DependencyLaunchLabel()

  UpdateTextGadgetIfNeeded(#GadgetDependencySummary, summary$)
  gLastDependencyInfoText$ = UpdateEditorTextIfNeeded(#GadgetDependencyInfo, info$, gLastDependencyInfoText$)
  UpdateTextGadgetIfNeeded(#GadgetDependencyLaunch, launch$)
  UpdateGadgetDisabledIfNeeded(#GadgetDependencyLaunch, #False)
EndProcedure

Procedure ShowDependencyWindow()
  If IsWindow(#WindowDependency) = 0
    If OpenWindow(#WindowDependency, 0, 0, 760, 600, #AppName$ + " Dependency Help", #PB_Window_SystemMenu | #PB_Window_ScreenCentered) = 0
      ProcedureReturn
    EndIf

    TextGadget(#GadgetDependencySummary, 20, 20, 720, 50, "", #PB_Text_Border)
    EditorGadget(#GadgetDependencyInfo, 20, 80, 720, 455, #PB_Editor_WordWrap | #PB_Editor_ReadOnly)
    ButtonGadget(#GadgetDependencyRefresh, 20, 550, 130, 30, "Refresh Status")
    ButtonGadget(#GadgetDependencyCopy, 160, 550, 140, 30, "Copy Instructions")
    ButtonGadget(#GadgetDependencyLaunch, 310, 550, 200, 30, "Refresh Status")
    ButtonGadget(#GadgetDependencyClose, 620, 550, 120, 30, "Close")
    gLastDependencyInfoText$ = ""
  EndIf

  RefreshDependencyWindow()
  HideWindow(#WindowDependency, #False)
  SetForegroundWindow_(WindowID(#WindowDependency))
EndProcedure

Procedure HandleDependencyAction(action.i)
  Select action
    Case #GadgetDependencyRefresh
      RefreshRuntimeSnapshot()
      RefreshStatusDisplay()
      RefreshDependencyWindow()
      LogAction("Dependency status refreshed.")

    Case #GadgetDependencyCopy
      SetClipboardText(BuildDependencyInstructions())
      LogAction("Dependency instructions copied.")
      RefreshStatusDisplay()

    Case #GadgetDependencyLaunch
      LaunchPreferredDependencyApp()
      RefreshRuntimeSnapshot()
      RefreshStatusDisplay()
      RefreshDependencyWindow()

    Case #GadgetDependencyClose
      If IsWindow(#WindowDependency)
        CloseWindow(#WindowDependency)
      EndIf
  EndSelect
EndProcedure

Procedure.i CreateMainWindow(showWindow.i)
  Protected windowFlags.i = #PB_Window_SystemMenu | #PB_Window_ScreenCentered | #PB_Window_MinimizeGadget
  Protected headingId.i

  If showWindow = #False
    windowFlags | #PB_Window_Invisible
  EndIf

  If OpenWindow(#WindowMain, 0, 0, 760, 670, #AppFullName$, windowFlags) = 0
    ProcedureReturn #False
  EndIf
  AppendRuntimeLog("CreateMainWindow: OpenWindow ok")

  SetWindowCallback(@MainWindowCallback())
  AppendRuntimeLog("CreateMainWindow: SetWindowCallback ok")
  ApplyWindowIcons()
  AppendRuntimeLog("CreateMainWindow: ApplyWindowIcons ok")
  EnsureUiFonts()
  AppendRuntimeLog("CreateMainWindow: EnsureUiFonts ok")

  PanelGadget(#GadgetMainPanel, 20, 16, 720, 510)
  AppendRuntimeLog("CreateMainWindow: PanelGadget ok")

  AddGadgetItem(#GadgetMainPanel, -1, "Overview")
  TextGadget(#PB_Any, 18, 12, 660, 34, "Quick dashboard for the current snapshot, control state, and hardware context." + #CRLF$ + "Overview shows the live readings. Auto Cool still reacts to the Control tab average window.")
  FrameGadget(#PB_Any, 18, 54, 340, 150, "Current Snapshot")
  TextGadget(#PB_Any, 34, 84, 94, 20, "Temperature:")
  TextGadget(#GadgetOverviewTempValue, 136, 82, 190, 22, "Waiting...")
  SetGadgetFont(#GadgetOverviewTempValue, FontID(gFontBold))
  TextGadget(#PB_Any, 34, 112, 94, 20, "Telemetry:")
  TextGadget(#GadgetOverviewSourceValue, 136, 110, 190, 30, "Waiting...")
  SetGadgetFont(#GadgetOverviewSourceValue, FontID(gFontBoldSmall))
  TextGadget(#PB_Any, 34, 148, 94, 20, "Temp Sensor:")
  TextGadget(#GadgetOverviewTempSensorValue, 136, 146, 190, 34, "Waiting...")
  SetGadgetFont(#GadgetOverviewTempSensorValue, FontID(gFontBoldSmall))

  FrameGadget(#PB_Any, 18, 216, 340, 198, "Power and State")
  TextGadget(#PB_Any, 34, 246, 68, 20, "APU Power:")
  TextGadget(#GadgetOverviewApuPowerValue, 108, 246, 72, 20, "Waiting...")
  SetGadgetFont(#GadgetOverviewApuPowerValue, FontID(gFontBoldSmall))
  TextGadget(#PB_Any, 188, 246, 68, 20, "GPU Power:")
  TextGadget(#GadgetOverviewGpuPowerValue, 260, 246, 66, 20, "Waiting...")
  SetGadgetFont(#GadgetOverviewGpuPowerValue, FontID(gFontBoldSmall))
  TextGadget(#PB_Any, 34, 272, 68, 20, "CPU Power:")
  TextGadget(#GadgetOverviewCpuPowerValue, 108, 272, 72, 20, "Waiting...")
  SetGadgetFont(#GadgetOverviewCpuPowerValue, FontID(gFontBoldSmall))
  TextGadget(#PB_Any, 188, 272, 68, 20, "GPU Load:")
  TextGadget(#GadgetOverviewGpuLoadValue, 260, 272, 66, 20, "Waiting...")
  SetGadgetFont(#GadgetOverviewGpuLoadValue, FontID(gFontBoldSmall))
  TextGadget(#PB_Any, 34, 300, 82, 20, "GPU Memory:")
  TextGadget(#GadgetOverviewGpuMemoryValue, 122, 300, 204, 20, "Waiting...")
  SetGadgetFont(#GadgetOverviewGpuMemoryValue, FontID(gFontBoldSmall))
  TextGadget(#PB_Any, 34, 326, 82, 20, "Power Source:")
  TextGadget(#GadgetOverviewPowerValue, 122, 326, 204, 20, "Waiting...")
  SetGadgetFont(#GadgetOverviewPowerValue, FontID(gFontBoldSmall))
  TextGadget(#PB_Any, 34, 352, 82, 20, "Active Plan:")
  TextGadget(#GadgetOverviewPlanValue, 122, 350, 204, 28, "Waiting...")
  SetGadgetFont(#GadgetOverviewPlanValue, FontID(gFontBoldSmall))
  TextGadget(#PB_Any, 34, 382, 82, 20, "Cool State:")
  TextGadget(#GadgetOverviewGameStateValue, 122, 380, 204, 28, "Waiting...")
  SetGadgetFont(#GadgetOverviewGameStateValue, FontID(gFontBoldSmall))

  FrameGadget(#PB_Any, 376, 54, 302, 220, "Activity Log")
  TextGadget(#PB_Any, 392, 82, 260, 18, "Recent plan and control activity.")
  EditorGadget(#GadgetActionValue, 392, 106, 270, 144, #PB_Editor_ReadOnly | #PB_Editor_WordWrap)

  FrameGadget(#PB_Any, 376, 286, 302, 150, "System Details")
  TextGadget(#GadgetOverviewHardwareDetails, 392, 312, 270, 112, "Waiting...")
  SetGadgetFont(#GadgetOverviewHardwareDetails, FontID(gFontBoldSmall))

  TextGadget(#PB_Any, 18, 448, 660, 34, "GPU memory combines dedicated and shared use when Windows exposes both." + #CRLF$ + "Overview and Live Telemetry show the current snapshot, while Auto Cool still uses the averaged Control window.")
  AppendRuntimeLog("CreateMainWindow: Overview tab ok")

  AddGadgetItem(#GadgetMainPanel, -1, "Live Telemetry")
  TextGadget(#PB_Any, 18, 12, 660, 34, "Live snapshot of the readings PowerPilot is using right now." + #CRLF$ + "This tab focuses on the active blend, detected GPUs, and current operating state.")

  FrameGadget(#PB_Any, 18, 54, 314, 286, "Blend Snapshot")
  TextGadget(#PB_Any, 34, 86, 96, 20, "Temperature:")
  TextGadget(#GadgetLiveBlendTemp, 136, 84, 178, 22, "")
  SetGadgetFont(#GadgetLiveBlendTemp, FontID(gFontBold))
  TextGadget(#PB_Any, 34, 116, 96, 20, "Telemetry:")
  TextGadget(#GadgetLiveBlendSourceMix, 136, 114, 178, 34, "")
  SetGadgetFont(#GadgetLiveBlendSourceMix, FontID(gFontBoldSmall))
  TextGadget(#PB_Any, 34, 152, 96, 20, "Temp Sensor:")
  TextGadget(#GadgetLiveBlendTempSensor, 136, 150, 178, 42, "")
  SetGadgetFont(#GadgetLiveBlendTempSensor, FontID(gFontBoldSmall))
  TextGadget(#PB_Any, 34, 200, 96, 20, "APU Power:")
  TextGadget(#GadgetLiveBlendApu, 136, 198, 178, 20, "")
  SetGadgetFont(#GadgetLiveBlendApu, FontID(gFontBoldSmall))
  TextGadget(#PB_Any, 34, 224, 96, 20, "GPU Power:")
  TextGadget(#GadgetLiveBlendGpuPower, 136, 222, 178, 20, "")
  SetGadgetFont(#GadgetLiveBlendGpuPower, FontID(gFontBoldSmall))
  TextGadget(#PB_Any, 34, 248, 96, 20, "CPU Power:")
  TextGadget(#GadgetLiveBlendCpu, 136, 246, 178, 20, "")
  SetGadgetFont(#GadgetLiveBlendCpu, FontID(gFontBoldSmall))

  FrameGadget(#PB_Any, 344, 54, 334, 286, "GPU and System State")
  TextGadget(#PB_Any, 360, 86, 110, 20, "Detected GPUs:")
  TextGadget(#GadgetLiveFallbackStatus, 360, 108, 300, 64, "")
  SetGadgetFont(#GadgetLiveFallbackStatus, FontID(gFontBoldSmall))
  TextGadget(#PB_Any, 360, 178, 100, 20, "GPU Load:")
  TextGadget(#GadgetLiveBlendGpuLoad, 466, 178, 194, 20, "")
  SetGadgetFont(#GadgetLiveBlendGpuLoad, FontID(gFontBoldSmall))
  TextGadget(#PB_Any, 360, 204, 100, 20, "GPU Memory:")
  TextGadget(#GadgetLiveBlendGpuMemory, 466, 204, 194, 20, "")
  SetGadgetFont(#GadgetLiveBlendGpuMemory, FontID(gFontBoldSmall))
  TextGadget(#PB_Any, 360, 230, 100, 20, "Power Source:")
  TextGadget(#GadgetLiveBlendPowerSource, 466, 230, 194, 20, "")
  SetGadgetFont(#GadgetLiveBlendPowerSource, FontID(gFontBoldSmall))
  TextGadget(#PB_Any, 360, 256, 100, 20, "Active Plan:")
  TextGadget(#GadgetLiveBlendActivePlan, 466, 254, 194, 30, "")
  SetGadgetFont(#GadgetLiveBlendActivePlan, FontID(gFontBoldSmall))
  TextGadget(#PB_Any, 360, 290, 100, 20, "Cool State:")
  TextGadget(#GadgetLiveBlendGameState, 466, 288, 194, 32, "")
  SetGadgetFont(#GadgetLiveBlendGameState, FontID(gFontBoldSmall))

  FrameGadget(#PB_Any, 18, 352, 660, 96, "Notes")
  TextGadget(#PB_Any, 34, 378, 628, 38, "GPU memory combines dedicated and shared RAM when Windows exposes both." + #CRLF$ + "Live Telemetry shows the current instant snapshot; Auto Cool still reacts to the averaged Control window.")
  AppendRuntimeLog("CreateMainWindow: Live Telemetry tab ok")

  AddGadgetItem(#GadgetMainPanel, -1, "Automation")
  TextGadget(#PB_Any, 18, 12, 660, 36, "Choose when PowerPilot should manage plans automatically." + #CRLF$ + "This tab controls when Auto Cool is allowed to act and how startup behavior works.")
  FrameGadget(#PB_Any, 18, 54, 320, 154, "Automatic Control")
  CheckBoxGadget(#GadgetAutoEnabled, 34, 84, 280, 24, "Enable automatic plan control")
  CheckBoxGadget(#GadgetAutoDetectGame, 34, 114, 280, 24, "Trigger Cool plans from GPU load")
  CheckBoxGadget(#GadgetUsePowerControl, 34, 144, 280, 24, "Use power targets, not just heat")
  CheckBoxGadget(#GadgetAutoBatteryPlan, 34, 174, 280, 24, "Force Battery Saver / Full Power by power source")

  FrameGadget(#PB_Any, 356, 54, 322, 154, "Startup and Install")
  CheckBoxGadget(#GadgetAutoStart, 372, 84, 170, 24, "Start in tray")
  CheckBoxGadget(#GadgetKeepSettings, 372, 114, 220, 24, "Keep settings on reinstall")
  TextGadget(#PB_Any, 372, 150, 280, 34, "Start in tray keeps PowerPilot hidden until you open it from the tray." + #CRLF$ + "Keep settings preserves your saved config across reinstalls.")

  FrameGadget(#PB_Any, 18, 220, 660, 156, "Telemetry")
  TextGadget(#PB_Any, 34, 248, 610, 42, "Leave Windows enabled to use Windows for temperature, CPU power, GPU power, GPU load, GPU memory, and GPU device names whenever Windows exposes them." + #CRLF$ + "If Windows cannot provide a usable temperature, PowerPilot can still fall back to a generic thermal-zone reading.")
  CheckBoxGadget(#GadgetUseWindows, 34, 302, 185, 24, "Use Windows telemetry")
  ButtonGadget(#GadgetWindowsInfo, 222, 296, 24, 24, "i")
  TextGadget(#PB_Any, 34, 334, 610, 26, "Disable Windows telemetry only for troubleshooting. Fallback temperature alone gives PowerPilot much less detail to work with.")
  AppendRuntimeLog("CreateMainWindow: Automation tab ok")

  AddGadgetItem(#GadgetMainPanel, -1, "Control")
  TextGadget(#PB_Any, 18, 12, 660, 36, "These targets decide how aggressively PowerPilot reacts to rising power draw and sustained GPU load." + #CRLF$ + "Use smaller margins and shorter delays for quicker reactions, or larger ones for steadier plan switching.")
  FrameGadget(#PB_Any, 18, 54, 320, 174, "Polling and Smoothing")
  TextGadget(#PB_Any, 34, 86, 170, 20, "Poll interval (sec):")
  SpinGadget(#GadgetPollSpin, 248, 82, 72, 25, 1, 60, #PB_Spin_Numeric)
  TextGadget(#PB_Any, 34, 116, 170, 20, "Temp hysteresis (C):")
  SpinGadget(#GadgetHysteresisSpin, 248, 112, 72, 25, 1, 20, #PB_Spin_Numeric)
  TextGadget(#PB_Any, 34, 146, 170, 20, "Power hysteresis (W):")
  SpinGadget(#GadgetPowerHysteresisSpin, 248, 142, 72, 25, 1, 30, #PB_Spin_Numeric)
  TextGadget(#PB_Any, 34, 176, 170, 20, "Control average (sec):")
  SpinGadget(#GadgetGameCoolAverage, 248, 172, 72, 25, 1, 60, #PB_Spin_Numeric)

  FrameGadget(#PB_Any, 356, 54, 322, 174, "GPU Trigger")
  TextGadget(#PB_Any, 372, 86, 166, 20, "GPU load trigger (%):")
  SpinGadget(#GadgetGpuLoadThreshold, 588, 82, 72, 25, 1, 100, #PB_Spin_Numeric)
  TextGadget(#PB_Any, 372, 116, 166, 20, "Load start delay (sec):")
  SpinGadget(#GadgetGameStartDelay, 588, 112, 72, 25, 2, 120, #PB_Spin_Numeric)
  TextGadget(#PB_Any, 372, 146, 166, 20, "Load stop delay (sec):")
  SpinGadget(#GadgetGameStopDelay, 588, 142, 72, 25, 2, 300, #PB_Spin_Numeric)
  TextGadget(#PB_Any, 372, 176, 270, 28, "Longer delays make plan changes steadier when GPU load bounces during short spikes.")

  FrameGadget(#PB_Any, 18, 242, 660, 104, "Power Targets")
  TextGadget(#PB_Any, 34, 274, 156, 20, "CPU power target (W):")
  SpinGadget(#GadgetCpuPowerTarget, 196, 270, 72, 25, 5, 120, #PB_Spin_Numeric)
  TextGadget(#PB_Any, 344, 274, 156, 20, "GPU power target (W):")
  SpinGadget(#GadgetGpuPowerTarget, 506, 270, 72, 25, 5, 250, #PB_Spin_Numeric)
  TextGadget(#PB_Any, 34, 306, 610, 20, "These targets matter most when Windows exposes usable CPU and GPU power readings.")

  FrameGadget(#PB_Any, 18, 358, 660, 88, "Tuning Notes")
  TextGadget(#PB_Any, 34, 384, 610, 34, "Smaller margins react faster but can switch plans more often." + #CRLF$ + "Larger margins and longer delays usually feel steadier.")
  AppendRuntimeLog("CreateMainWindow: Control tab ok")

  AddGadgetItem(#GadgetMainPanel, -1, "Thermal Steps")
  TextGadget(#PB_Any, 18, 12, 660, 36, "These safety thresholds step PowerPilot down from Full Power through the Cool levels as temperatures rise." + #CRLF$ + "Keep them in ascending order so each lower-power plan becomes the next protection step.")
  FrameGadget(#PB_Any, 18, 54, 660, 186, "Temperature Thresholds")
  TextGadget(#PB_Any, 34, 86, 190, 20, "Full -> 24W threshold (C):")
  SpinGadget(#GadgetThresholdFull24, 250, 82, 72, 25, 45, 100, #PB_Spin_Numeric)
  TextGadget(#PB_Any, 34, 116, 190, 20, "24W -> 21W threshold (C):")
  SpinGadget(#GadgetThreshold2421, 250, 112, 72, 25, 46, 105, #PB_Spin_Numeric)
  TextGadget(#PB_Any, 34, 146, 190, 20, "21W -> 18W threshold (C):")
  SpinGadget(#GadgetThreshold2118, 250, 142, 72, 25, 47, 110, #PB_Spin_Numeric)
  TextGadget(#PB_Any, 34, 176, 190, 20, "18W -> 15W threshold (C):")
  SpinGadget(#GadgetThreshold1815, 250, 172, 72, 25, 48, 115, #PB_Spin_Numeric)
  TextGadget(#PB_Any, 34, 206, 190, 20, "15W -> 12W threshold (C):")
  SpinGadget(#GadgetThreshold1512, 250, 202, 72, 25, 49, 120, #PB_Spin_Numeric)

  FrameGadget(#PB_Any, 18, 252, 660, 84, "How Thresholds Are Used")
  TextGadget(#PB_Any, 34, 278, 610, 28, "When temperature crosses a threshold, PowerPilot steps down to the next cooler plan." + #CRLF$ + "As temperature falls back with hysteresis, it can step upward again.")

  FrameGadget(#PB_Any, 18, 348, 660, 88, "Tuning Tips")
  TextGadget(#PB_Any, 34, 374, 610, 34, "Lower thresholds protect temperature sooner." + #CRLF$ + "Higher thresholds hold performance longer, but they also allow more heat before stepping down.")
  AppendRuntimeLog("CreateMainWindow: Thermal Steps tab ok")

  AddGadgetItem(#GadgetMainPanel, -1, "Plan Manager")
  TextGadget(#PB_Any, 18, 12, 660, 36, "Manage which plans PowerPilot keeps installed in Windows and edit the behavior of each one." + #CRLF$ + "Select a plan to tune its AC/DC behavior, or create a new custom plan from a preset.")
  FrameGadget(#PB_Any, 18, 54, 314, 392, "Installed Plans")
  ListIconGadget(#GadgetPlanList, 34, 84, 282, 250, "Plan", 155, #PB_ListIcon_CheckBoxes | #PB_ListIcon_FullRowSelect | #PB_ListIcon_AlwaysShowSelection)
  AddGadgetColumn(#GadgetPlanList, 1, "Type", 60)
  AddGadgetColumn(#GadgetPlanList, 2, "Purpose", 200)
  ButtonGadget(#GadgetPlanRefreshAll, 34, 348, 132, 28, "Create Missing Defaults")
  ButtonGadget(#GadgetPlanRemoveAll, 184, 348, 132, 28, "Remove All Managed")
  TextGadget(#PB_Any, 34, 384, 282, 34, "Tick a plan to keep it installed. Untick it to remove only that plan." + #CRLF$ + "Select a row to edit it on the right.")

  FrameGadget(#PB_Any, 346, 54, 332, 392, "Plan Editor")
  TextGadget(#PB_Any, 362, 84, 78, 20, "Plan Name:")
  StringGadget(#GadgetPlanEditorName, 446, 80, 216, 24, "")
  TextGadget(#PB_Any, 362, 114, 78, 20, "Purpose:")
  StringGadget(#GadgetPlanEditorSummary, 446, 110, 216, 24, "")
  TextGadget(#PB_Any, 362, 144, 78, 20, "Preset:")
  ComboBoxGadget(#GadgetPlanEditorPreset, 446, 140, 124, 24)
  ButtonGadget(#GadgetPlanEditorLoadPreset, 580, 140, 82, 24, "Load")

  FrameGadget(#PB_Any, 362, 176, 300, 112, "Behavior")
  TextGadget(#PB_Any, 378, 204, 50, 20, "AC EPP:")
  SpinGadget(#GadgetPlanAcEpp, 432, 200, 60, 24, 0, 100, #PB_Spin_Numeric)
  TextGadget(#PB_Any, 518, 204, 50, 20, "DC EPP:")
  SpinGadget(#GadgetPlanDcEpp, 572, 200, 60, 24, 0, 100, #PB_Spin_Numeric)
  TextGadget(#PB_Any, 378, 232, 48, 20, "AC Boost:")
  ComboBoxGadget(#GadgetPlanAcBoost, 430, 228, 82, 24)
  TextGadget(#PB_Any, 520, 232, 48, 20, "DC Boost:")
  ComboBoxGadget(#GadgetPlanDcBoost, 572, 228, 82, 24)
  TextGadget(#PB_Any, 378, 260, 58, 20, "AC Cooling:")
  ComboBoxGadget(#GadgetPlanAcCooling, 440, 256, 72, 24)
  TextGadget(#PB_Any, 518, 260, 58, 20, "DC Cooling:")
  ComboBoxGadget(#GadgetPlanDcCooling, 580, 256, 72, 24)

  FrameGadget(#PB_Any, 362, 296, 300, 86, "Limits")
  TextGadget(#PB_Any, 378, 324, 50, 20, "AC Max %:")
  SpinGadget(#GadgetPlanAcState, 432, 320, 60, 24, 1, 100, #PB_Spin_Numeric)
  TextGadget(#PB_Any, 516, 324, 54, 20, "DC Max %:")
  SpinGadget(#GadgetPlanDcState, 572, 320, 60, 24, 1, 100, #PB_Spin_Numeric)
  TextGadget(#PB_Any, 378, 352, 50, 20, "AC MHz:")
  SpinGadget(#GadgetPlanAcFreq, 432, 348, 70, 24, 0, 5000, #PB_Spin_Numeric)
  TextGadget(#PB_Any, 516, 352, 50, 20, "DC MHz:")
  SpinGadget(#GadgetPlanDcFreq, 572, 348, 60, 24, 0, 5000, #PB_Spin_Numeric)

  ButtonGadget(#GadgetPlanEditorSave, 362, 394, 88, 28, "Save Plan")
  ButtonGadget(#GadgetPlanEditorNew, 460, 394, 94, 28, "New Custom")
  ButtonGadget(#GadgetPlanEditorDelete, 564, 394, 98, 28, "Delete Custom")
  AppendRuntimeLog("CreateMainWindow: Plan Manager tab ok")

  AddGadgetItem(#GadgetMainPanel, -1, "Manual Override")
  TextGadget(#PB_Any, 18, 12, 660, 36, "Use manual override when you want to take over plan selection yourself." + #CRLF$ + "Activate forces the chosen plan and turns automation off until you re-enable it.")
  FrameGadget(#PB_Any, 18, 54, 660, 116, "Manual Plan")
  TextGadget(#PB_Any, 34, 90, 80, 20, "Select Plan:")
  ComboBoxGadget(#GadgetPlanCombo, 120, 86, 320, 28)
  PopulatePlanCombo()
  ButtonGadget(#GadgetActivatePlan, 454, 85, 92, 28, "Activate")
  ButtonGadget(#GadgetAutoOnce, 556, 85, 106, 28, "Auto Once")
  TextGadget(#PB_Any, 34, 122, 628, 24, "Activate keeps the selected plan in effect until you turn Auto Cool back on. Auto Once runs a single automatic decision without changing your checkboxes.")

  FrameGadget(#PB_Any, 18, 184, 660, 96, "Display Recovery")
  ButtonGadget(#GadgetResetDisplay, 34, 220, 190, 30, "Reset Display")
  TextGadget(#PB_Any, 244, 218, 418, 34, "Reset Display sends the Windows graphics reset hotkey (Win+Ctrl+Shift+B) so Windows can refresh the display path without a full reboot.")

  FrameGadget(#PB_Any, 18, 294, 660, 132, "Notes")
  TextGadget(#PB_Any, 34, 320, 628, 72, "Only plans that are currently installed in Plan Manager appear here." + #CRLF$ + "Use Plan Manager to create, remove, or tune plans before forcing one manually." + #CRLF$ + "If you want PowerPilot to take over again after a manual activation, re-enable automatic control on the Automation tab.")

  CloseGadgetList()
  AppendRuntimeLog("CreateMainWindow: Manual Override tab ok")

  CanvasGadget(#GadgetDependencies, 20, 538, 95, 30)
  ButtonGadget(#GadgetSaveSettings, 125, 538, 90, 30, "Save")
  ButtonGadget(#GadgetHideToTray, 225, 538, 95, 30, "Hide")
  ButtonGadget(#GadgetExit, 630, 538, 110, 30, "Exit")
  TextGadget(#GadgetStatusLine, 20, 582, 720, 36, "Ready.", #PB_Text_Border)

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
  PopulatePlanPresetCombo()
  RefreshPlanList()
  RefreshPlanEditor()
  PushSettingsToGui()
  ResetTelemetrySmoothing()
  PopulatePlanCombo()
  UpdateUiRefreshTimer()
  DrawHelpButton()
  ApplyMainWindowToolTips()
  AppendRuntimeLog("CreateMainWindow: final setup ok")

  ProcedureReturn #True
EndProcedure

Procedure HandleManualAction(action.i)
  Protected planName$
  Protected planIndex.i
  Protected itemState.i

  Select action
    Case #GadgetPlanRefreshAll
      If CreateManagedPlans()
        RefreshPlanList()
        PopulatePlanCombo()
        RefreshPlanEditor()
        LogAction("Default and saved plans created or refreshed.")
      EndIf

    Case #GadgetPlanRemoveAll
      If CleanupManagedPlans()
        RefreshPlanList()
        PopulatePlanCombo()
        RefreshPlanEditor()
      EndIf

    Case #GadgetPlanList
      planIndex = GetGadgetState(#GadgetPlanList)
      If planIndex >= 0
        planName$ = GetGadgetItemText(#GadgetPlanList, planIndex)
        gSelectedPlanName$ = planName$
        itemState = GetGadgetItemState(#GadgetPlanList, planIndex)
        If (itemState & #PB_ListIcon_Checked) And PlanDefinitionInstalled(planName$) = #False
          EnsurePlanInstalled(planName$)
          PopulatePlanCombo()
        ElseIf (itemState & #PB_ListIcon_Checked) = 0 And PlanDefinitionInstalled(planName$)
          RemoveManagedPlanByName(planName$)
          PopulatePlanCombo()
        EndIf
        RefreshPlanList()
        RefreshPlanEditor()
      EndIf

    Case #GadgetPlanEditorLoadPreset
      planIndex = GetGadgetState(#GadgetPlanEditorPreset)
      If planIndex >= 0
        LoadPlanEditorFromPreset(GetGadgetItemText(#GadgetPlanEditorPreset, planIndex))
      EndIf

    Case #GadgetPlanEditorSave
      SavePlanEditorDefinition()

    Case #GadgetPlanEditorNew
      StartNewPlanFromPreset()

    Case #GadgetPlanEditorDelete
      DeleteSelectedCustomPlan()

    Case #GadgetActivatePlan
      planIndex = GetGadgetState(#GadgetPlanCombo)
      If planIndex >= 0
        planName$ = GetGadgetItemText(#GadgetPlanCombo, planIndex)
      EndIf
      If planName$ <> ""
        If ActivatePlanByName(planName$, #True) And IsRememberedPluggedPlanName(planName$)
          RememberPluggedPlan(planName$, #True)
          RememberRuntimeDgpuPlanIfActive(planName$, #True)
          gManualOverrideUntil = 0
          LockMutex(gStateMutex)
          gSettings\AutoEnabled = #False
          gState\AutoEnabled = #False
          UnlockMutex(gStateMutex)
          SaveSettings()
          PushSettingsToGui()
          LogAction("Manual plan activated. Auto Cool was turned off so the plan stays in effect.")
        EndIf
      Else
        LogAction("No manual plan is selected.")
      EndIf

    Case #GadgetAutoOnce
      AutoGameCoolStep(#True)

    Case #GadgetResetDisplay
      TriggerDisplayReset()
      LogAction("Requested Windows graphics/display reset hotkey.")

    Case #GadgetAutoEnabled
      ApplyLiveCheckboxSettings("Auto Cool setting updated.")

    Case #GadgetAutoDetectGame
      ApplyLiveCheckboxSettings("GPU load trigger setting updated.")

    Case #GadgetUseWindows
      SelectPrimaryTelemetrySource(GetGadgetState(#GadgetUseWindows))
      ApplyLiveCheckboxSettings("Windows telemetry setting updated.")

    Case #GadgetUsePowerControl
      ApplyLiveCheckboxSettings("CPU power control setting updated.")

    Case #GadgetAutoStart
      ApplyLiveCheckboxSettings("Start With Windows setting updated.")

    Case #GadgetKeepSettings
      ApplyLiveCheckboxSettings("Keep settings on reinstall setting updated.")

    Case #GadgetAutoBatteryPlan
      ApplyLiveCheckboxSettings("Battery/plugged auto setting updated.")

    Case #GadgetSaveSettings
      SaveSettingsFromGui()

    Case #GadgetDependencies
      If EventType() = #PB_EventType_LeftClick Or EventType() = #PB_EventType_LeftButtonUp Or EventType() = 0
        ShowDependencyWindow()
      EndIf

    Case #GadgetWindowsInfo
      MessageRequester(#AppName$ + " Telemetry Info", BuildWindowsInfoText())

    Case #GadgetHideToTray
      HideToTray()

    Case #GadgetExit
      ShutdownApp()
  EndSelect
EndProcedure

Procedure HandleTrayMenu(menuID.i)
  Select menuID
    Case #MenuOpen
      ShowFromTray()

    Case #MenuToggleAuto
      LockMutex(gStateMutex)
      gSettings\AutoEnabled = Bool(gSettings\AutoEnabled = 0)
      gState\AutoEnabled = gSettings\AutoEnabled
      UnlockMutex(gStateMutex)
      SaveSettings()
      PushSettingsToGui()
      LogAction("Auto Cool toggled to " + Str(gSettings\AutoEnabled))

    Case #MenuAutoOnce
      AutoGameCoolStep(#True)

    Case #MenuBattery
      ActivatePlanByName(#PlanBattery$, #True)

    Case #MenuPlugged
      If ActivatePlanByName(#PlanPlugged$, #True)
        RememberPluggedPlan(#PlanPlugged$, #True)
        RememberRuntimeDgpuPlanIfActive(#PlanPlugged$, #True)
      EndIf

    Case #MenuFull
      If ActivatePlanByName(#PlanFull$, #True)
        RememberPluggedPlan(#PlanFull$, #True)
        RememberRuntimeDgpuPlanIfActive(#PlanFull$, #True)
      EndIf

    Case #MenuDependencies
      ShowDependencyWindow()

    Case #MenuCreatePlans
      CreateManagedPlans()

    Case #MenuCleanupPlans
      CleanupManagedPlans()

    Case #MenuExit
      ShutdownApp()
  EndSelect
EndProcedure

Procedure RunGui(showWindow.i)
  Protected event.i
  Protected eventWindow.i
  Protected workerRunning.i

  AppendRuntimeLog("RunGui start, showWindow=" + Str(showWindow))
  CreateTrayMenu()
  If CreateMainWindow(showWindow) = #False
    AppendRuntimeLog("CreateMainWindow failed")
    End 1
  EndIf
  AppendRuntimeLog("CreateMainWindow ok")
  gTrayImage = 0
  If showWindow = #False
    gTrayReady = AddNativeTrayIconWithRetry(12, 500)
  Else
    gTrayReady = AddNativeTrayIcon()
  EndIf
  AppendRuntimeLog("AddNativeTrayIcon=" + Str(gTrayReady))

  RefreshRuntimeSnapshot()
  AppendRuntimeLog("RefreshRuntimeSnapshot ok")
  SelectPlanComboByName(gState\ActivePlan)
  AppendRuntimeLog("SelectPlanComboByName ok")
  RefreshStatusDisplay()
  AppendRuntimeLog("RefreshStatusDisplay ok")
  StartWorkerThread()
  AppendRuntimeLog("StartWorkerThread ok")

  If showWindow = #False And gTrayReady
    HideWindow(#WindowMain, #True)
    AppendRuntimeLog("HideWindow(true)")
  Else
    HideWindow(#WindowMain, #False)
    SetForegroundWindow_(WindowID(#WindowMain))
    If showWindow = #False
      LogAction("Tray icon unavailable at startup. Showing the window.")
    EndIf
    AppendRuntimeLog("HideWindow(false)")
  EndIf
  AppendRuntimeLog("Event loop start")

  Repeat
    event = WaitWindowEvent()
    eventWindow = EventWindow()

    Select event
      Case #PB_Event_CloseWindow
        Select eventWindow
          Case #WindowMain
            HideToTray()
          Case #WindowDependency
            CloseWindow(#WindowDependency)
        EndSelect

      Case #PB_Event_Gadget
        Select eventWindow
          Case #WindowDependency
            HandleDependencyAction(EventGadget())
          Default
            HandleManualAction(EventGadget())
        EndSelect

      Case #PB_Event_Menu
        HandleTrayMenu(EventMenu())

      Case #PB_Event_SysTray
        Select EventType()
          Case #PB_EventType_LeftClick, #PB_EventType_LeftDoubleClick
            ShowFromTray()
        EndSelect

      Case #PB_Event_Timer
        Select EventTimer()
          Case #TimerUiRefresh
            LockMutex(gStateMutex)
            workerRunning = gState\WorkerRunning
            UnlockMutex(gStateMutex)
            If workerRunning = #False
              AutoGameCoolStep()
              RefreshRuntimeSnapshot()
            EndIf
            RefreshStatusDisplay()
            If IsWindow(#WindowDependency)
              If workerRunning = #False
                RefreshDependencyWindow()
              EndIf
            EndIf
        EndSelect

      Case #PB_Event_MinimizeWindow
        If eventWindow = #WindowMain And gTrayReady
          HideToTray()
        EndIf
    EndSelect
  ForEver
EndProcedure

gStateMutex = CreateMutex()
CleanupDetachedWindowsPerfHelpers()
LoadSettings()
InitializePlanDefinitions()

LockMutex(gStateMutex)
gState\AutoEnabled = gSettings\AutoEnabled
gState\AutoDetectGame = gSettings\AutoDetectGame
gState\PowerSource = DetectPowerSource()
gState\ActivePlan = GetActiveSchemeName()
UnlockMutex(gStateMutex)

If gState\ActivePlan = #PlanVisible$
  LockMutex(gStateMutex)
  gState\ActivePlan = GetCurrentManagedPlan()
  UnlockMutex(gStateMutex)
EndIf

If gState\PowerSource = #PowerSourcePlugged And IsRememberedPluggedPlanName(gState\ActivePlan)
  RememberPluggedPlan(gState\ActivePlan, #True)
EndIf
If IsSelectableManagedPlanName(gState\ActivePlan)
  RememberCurrentManagedPlan(gState\ActivePlan, #True)
EndIf
EnsureVisiblePlanActive()

If CountProgramParameters() > 0
  Select LCase(ProgramParameter(0))
    Case "/create-plans"
      If CreateManagedPlans()
        End 0
      Else
        End 1
      EndIf

    Case "/cleanup-plans"
      If CleanupManagedPlans()
        End 0
      Else
        End 1
      EndIf

    Case "/auto-gamecool-once", "/auto-cool-once"
      AutoGameCoolStep(#True)
      End 0

    Case "/startup-on"
      gSettings\AutoStartWithApp = #True
      SaveSettings()
      If SetStartupRegistry(#True)
        End 0
      Else
        End 1
      EndIf

    Case "/startup-off"
      gSettings\AutoStartWithApp = #False
      SaveSettings()
      If SetStartupRegistry(#False)
        End 0
      Else
        End 1
      EndIf

    Case "/cleanup-settings"
      If CleanupSettingsData()
        End 0
      Else
        End 1
      EndIf

    Case "/query-keep-settings"
      If gSettings\KeepSettingsOnReinstall
        End 1
      Else
        End 0
      EndIf

    Case "/tray"
      gTrayStart = #True

    Case "/show"
      gTrayStart = #False
  EndSelect
EndIf

RunGui(Bool(gTrayStart = #False))

; IDE Options = PureBasic 6.40 (Windows - x64)
; FirstLine = 198
; Folding = ------------
; Optimizer
; EnableAsm
; EnableThread
; EnableXP
; DPIAware
; DisableDebugger

