EnableExplicit

; PowerPilot v1.0
; PureBasic-only Windows power-plan manager with local CPU/GPU identification.

#AppName$            = "PowerPilot"
#AppVersion$         = "1.0.2605.00770"
#AppFullName$        = #AppName$ + " v" + #AppVersion$
#AppRunKey$          = "PowerPilot"
#SettingsFolderName$ = "PowerPilot"
#SettingsFileName$   = "settings.ini"
#TrayTooltip$        = #AppFullName$

#PlanPrefixNew$ = "PowerPilot "
#PlanPrefixOld$ = "Codex "
#PlanFull$      = "PowerPilot Maximum"
#PlanBalanced$  = "PowerPilot Balanced"
#PlanBattery$   = "PowerPilot Battery"

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
#RefreshMs = 5000
#ProgramTimeoutMs = 10000

Prototype.i PowerGetActiveSchemeProto(userRoot.i, *activeScheme)
Prototype.i PowerGetGuidValueProto(*guid)

Enumeration 100
  #MenuOpen
  #MenuMaximum
  #MenuBalanced
  #MenuBattery
  #MenuCreatePlans
  #MenuCleanupPlans
  #MenuExit
EndEnumeration

Enumeration 200
  #GadgetPanel
  #GadgetCpuInfo
  #GadgetGpuInfo
  #GadgetActivePlan
  #GadgetPowerSource
  #GadgetLastAction
  #GadgetRefreshInfo
  #GadgetPlanList
  #GadgetCreatePlans
  #GadgetRemovePlans
  #GadgetActivatePlan
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
  #GadgetSaveSettings
  #GadgetHideToTray
  #GadgetExit
  #GadgetStatus
EndEnumeration

Structure CpuidRegs
  Eax.q
  Ebx.q
  Ecx.q
  Edx.q
EndStructure

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

Structure AppSettings
  AutoStartWithApp.i
  KeepSettingsOnReinstall.i
  LastPlan.s
EndStructure

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
Global gRefreshTimerActive.i
Global gFontUi.i
Global gFontBold.i
Global gPowrProfLibrary.i
Global gPowerApiTried.i
Global gPowerGetActiveScheme.PowerGetActiveSchemeProto
Global gPowerGetEffectiveOverlayScheme.PowerGetGuidValueProto
Global gPowerGetUserConfiguredACPowerMode.PowerGetGuidValueProto
Global gPowerGetUserConfiguredDCPowerMode.PowerGetGuidValueProto
Global gMonitorInitialized.i
Global gLastObservedActiveGuid$
Global gLastObservedPowerModeGuid$
Global NewMap gSchemeGuidByName.s()
Global NewMap gSchemeNameByGuid.s()

Declare RefreshDisplay(force.i = #False)
Declare RefreshPlanList(force.i = #False)
Declare RefreshPlanEditor()
Declare ApplySettingsToGui()
Declare SaveSettingsFromGui()
Declare.i CreateManagedPlans()
Declare.i CreateManagedPlansFromBase(baseGuid$, forceRebase.i = #False)
Declare.i CleanupManagedPlans()
Declare.i ActivatePlanByName(planName$)

Procedure.s QuoteArgument(value$)
  ProcedureReturn Chr(34) + value$ + Chr(34)
EndProcedure

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

Procedure.s CleanPlanText(text$)
  text$ = ReplaceString(text$, #CR$, " ")
  text$ = ReplaceString(text$, #LF$, " ")
  text$ = ReplaceString(text$, #TAB$, " ")
  While FindString(text$, "  ", 1)
    text$ = ReplaceString(text$, "  ", " ")
  Wend
  ProcedureReturn Trim(text$)
EndProcedure

Procedure.i ClampInt(value.i, minValue.i, maxValue.i)
  If value < minValue : ProcedureReturn minValue : EndIf
  If value > maxValue : ProcedureReturn maxValue : EndIf
  ProcedureReturn value
EndProcedure

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

Procedure LoadDefaultPlan(index.i)
  Select index
    Case 0
      AddPlan(0, #PlanFull$, "Maximum performance profile based on your selected Windows plan.", 5, 2, 100, 0, 1, 60, 1, 100, 0, 1)
    Case 1
      AddPlan(1, #PlanBalanced$, "Balanced daily profile based on your selected Windows plan.", 55, 1, 85, 0, 1, 75, 1, 80, 0, 1)
    Case 2
      AddPlan(2, #PlanBattery$, "Battery profile based on your selected Windows plan.", 85, 0, 70, 2500, 0, 95, 0, 60, 1800, 0)
  EndSelect
EndProcedure

Procedure LoadDefaultPlans()
  LoadDefaultPlan(0)
  LoadDefaultPlan(1)
  LoadDefaultPlan(2)
EndProcedure

Procedure.i PlanIndexByName(planName$)
  Protected i.i
  For i = 0 To 2
    If gPlans(i)\Name = planName$
      ProcedureReturn i
    EndIf
  Next
  ProcedureReturn -1
EndProcedure

Procedure.s NormalizePlanName(planName$)
  If PlanIndexByName(planName$) >= 0
    ProcedureReturn planName$
  EndIf
  ProcedureReturn #PlanBalanced$
EndProcedure

Procedure.i IsManagedPlanName(planName$)
  ProcedureReturn Bool(planName$ = #AppName$ Or Left(planName$, Len(#PlanPrefixNew$)) = #PlanPrefixNew$ Or Left(planName$, Len(#PlanPrefixOld$)) = #PlanPrefixOld$)
EndProcedure

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

Procedure LoadSettings()
  Protected i.i
  LoadDefaultPlans()
  gSettings\AutoStartWithApp = #True
  gSettings\KeepSettingsOnReinstall = #False
  gSettings\LastPlan = #PlanBalanced$

  If OpenPreferences(SettingsPath())
    gSettings\AutoStartWithApp = ReadPreferenceInteger("AutoStartWithApp", gSettings\AutoStartWithApp)
    gSettings\KeepSettingsOnReinstall = ReadPreferenceInteger("KeepSettingsOnReinstall", gSettings\KeepSettingsOnReinstall)
    gSettings\LastPlan = ReadPreferenceString("LastPlan", gSettings\LastPlan)
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
EndProcedure

Procedure SaveSettings()
  Protected i.i
  EnsureSettingsDirectory()
  If CreatePreferences(SettingsPath())
    WritePreferenceInteger("AutoStartWithApp", Bool(gSettings\AutoStartWithApp))
    WritePreferenceInteger("KeepSettingsOnReinstall", Bool(gSettings\KeepSettingsOnReinstall))
    WritePreferenceString("LastPlan", NormalizePlanName(gSettings\LastPlan))
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

Procedure LogAction(text$)
  gLastAction$ = FormatDate("%hh:%ii:%ss", Date()) + "  " + text$
  If IsGadget(#GadgetLastAction)
    SetGadgetText(#GadgetLastAction, gLastAction$)
  EndIf
  If IsGadget(#GadgetStatus)
    SetGadgetText(#GadgetStatus, text$)
  EndIf
EndProcedure

Procedure.i ProgramWaitTimedOut(startTick.q, timeoutMs.i)
  If timeoutMs <= 0
    ProcedureReturn #False
  EndIf
  ProcedureReturn Bool(ElapsedMilliseconds() - startTick >= timeoutMs)
EndProcedure

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

Procedure.i RunPowerCfg(arguments$)
  ProcedureReturn RunExitCode("powercfg.exe", arguments$)
EndProcedure

Procedure.s RunPowerCfgCapture(arguments$)
  ProcedureReturn RunCapture("powercfg.exe", arguments$)
EndProcedure

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

Procedure.i CurrentPowerSupplyIsBattery()
  Protected status.SYSTEM_POWER_STATUS
  If GetSystemPowerStatus_(@status)
    ProcedureReturn Bool(status\ACLineStatus = 0)
  EndIf
  ProcedureReturn #False
EndProcedure

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

Procedure.s GetWindowsPowerModeText()
  Protected guid$ = GetWindowsPowerModeGuid()
  Protected text$ = PowerModeTextFromGuid(guid$)
  If text$ = ""
    ProcedureReturn "Classic power plan"
  EndIf
  ProcedureReturn text$
EndProcedure

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

Procedure InvalidateSchemeCache()
  gSchemeCacheValid = #False
  gCachedActiveName$ = ""
  ClearMap(gSchemeGuidByName())
  ClearMap(gSchemeNameByGuid())
EndProcedure

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

Procedure.s GetActiveSchemeGuid()
  Protected guid$ = GetActiveSchemeGuidByApi()
  If guid$ = ""
    guid$ = FindGuidInText(RunPowerCfgCapture("/GETACTIVESCHEME"))
  EndIf
  ProcedureReturn guid$
EndProcedure

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

Procedure.s GetActiveSchemeName()
  ProcedureReturn GetSchemeNameByGuid(GetActiveSchemeGuid())
EndProcedure

Procedure.i SetSchemeValue(schemeGuid$, acMode.i, subgroup$, setting$, value.i)
  Protected mode$ = "/SETDCVALUEINDEX "
  If acMode
    mode$ = "/SETACVALUEINDEX "
  EndIf
  ProcedureReturn RunPowerCfg(mode$ + schemeGuid$ + " " + subgroup$ + " " + setting$ + " " + Str(value))
EndProcedure

Procedure TrySetSchemeValue(schemeGuid$, acMode.i, subgroup$, setting$, value.i)
  SetSchemeValue(schemeGuid$, acMode, subgroup$, setting$, value)
EndProcedure

Procedure SetFrequencyCaps(schemeGuid$, acMode.i, mhz.i)
  TrySetSchemeValue(schemeGuid$, acMode, "SUB_PROCESSOR", "PROCFREQMAX", mhz)
  TrySetSchemeValue(schemeGuid$, acMode, "SUB_PROCESSOR", "PROCFREQMAX1", mhz)
  TrySetSchemeValue(schemeGuid$, acMode, "SUB_PROCESSOR", "PROCFREQMAX2", mhz)
EndProcedure

Procedure.i ConfigureScheme(*plan.PlanDefinition, schemeGuid$)
  Protected acMinState.i = 5
  Protected dcMinState.i = 5
  Protected acCoreParkingMin.i = 100
  Protected dcCoreParkingMin.i = 25

  If schemeGuid$ = ""
    ProcedureReturn #False
  EndIf

  If *plan\Name = #PlanBattery$
    acCoreParkingMin = 50
    dcCoreParkingMin = 10
  ElseIf *plan\Name = #PlanFull$
    acMinState = 20
    dcMinState = 10
  EndIf

  SetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PERFEPP", *plan\AcEpp)
  TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PERFEPP1", *plan\AcEpp)
  TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PERFEPP2", *plan\AcEpp)
  SetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PERFBOOSTMODE", *plan\AcBoostMode)
  SetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PROCTHROTTLEMAX", *plan\AcMaxState)
  TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PROCTHROTTLEMAX1", *plan\AcMaxState)
  TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PROCTHROTTLEMAX2", *plan\AcMaxState)
  TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "PROCTHROTTLEMIN", acMinState)
  TrySetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "CPMINCORES", acCoreParkingMin)
  SetFrequencyCaps(schemeGuid$, #True, *plan\AcFreqMHz)
  SetSchemeValue(schemeGuid$, #True, "SUB_PROCESSOR", "SYSCOOLPOL", *plan\AcCooling)

  SetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "PERFEPP", *plan\DcEpp)
  TrySetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "PERFEPP1", *plan\DcEpp)
  TrySetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "PERFEPP2", *plan\DcEpp)
  SetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "PERFBOOSTMODE", *plan\DcBoostMode)
  SetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "PROCTHROTTLEMAX", *plan\DcMaxState)
  TrySetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "PROCTHROTTLEMAX1", *plan\DcMaxState)
  TrySetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "PROCTHROTTLEMAX2", *plan\DcMaxState)
  TrySetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "PROCTHROTTLEMIN", dcMinState)
  TrySetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "CPMINCORES", dcCoreParkingMin)
  SetFrequencyCaps(schemeGuid$, #False, *plan\DcFreqMHz)
  SetSchemeValue(schemeGuid$, #False, "SUB_PROCESSOR", "SYSCOOLPOL", *plan\DcCooling)

  ProcedureReturn #True
EndProcedure

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

Procedure.s BuildCpuInfo()
  Protected text$
  text$ = CpuBrand()
  text$ + #LF$ + CpuVendor() + " | " + CpuFamilyModelText()
  text$ + #LF$ + CpuTopologyText()
  text$ + #LF$ + "Cache: " + CpuCacheText() + " | " + SystemMemoryText()
  text$ + #LF$ + "Features: " + CpuFeatureText()
  ProcedureReturn text$
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

Procedure.i IsGenericAmdIntegratedGpuName(hardwareName$)
  Protected lowered$ = LCase(Trim(hardwareName$))
  ProcedureReturn Bool(lowered$ = "amd radeon graphics" Or lowered$ = "radeon graphics" Or lowered$ = "amd radeon(tm) graphics" Or lowered$ = "radeon(tm) graphics")
EndProcedure

Procedure.s ResolveAmdGraphicsCuName(cuCount.i)
  If cuCount <= 0
    ProcedureReturn "AMD Radeon Graphics"
  EndIf
  ProcedureReturn "AMD Radeon Graphics (" + Str(cuCount) + " CUs)"
EndProcedure

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

Procedure.i IsLikelyIntegratedGpuName(name$)
  Protected lower$ = LCase(name$)
  ProcedureReturn Bool(FindString(lower$, "radeon 680m", 1) Or FindString(lower$, "radeon 660m", 1) Or FindString(lower$, "radeon 610m", 1) Or FindString(lower$, "radeon 740m", 1) Or FindString(lower$, "radeon 760m", 1) Or FindString(lower$, "radeon 780m", 1) Or FindString(lower$, "radeon 840m", 1) Or FindString(lower$, "radeon 860m", 1) Or FindString(lower$, "radeon 880m", 1) Or FindString(lower$, "radeon 890m", 1) Or FindString(lower$, "vega", 1) Or FindString(lower$, "uhd", 1) Or FindString(lower$, "iris", 1) Or FindString(lower$, "xe graphics", 1))
EndProcedure

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

Procedure.i IsUsefulGpuName(name$)
  Protected lower$ = LCase(name$)
  If Trim(name$) = "" : ProcedureReturn #False : EndIf
  If FindString(lower$, "mirage", 1) : ProcedureReturn #False : EndIf
  If FindString(lower$, "remote display", 1) : ProcedureReturn #False : EndIf
  If FindString(lower$, "basic render", 1) : ProcedureReturn #False : EndIf
  ProcedureReturn #True
EndProcedure

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

Procedure.i CleanupSettingsData()
  SetStartupRegistry(#False)
  If FileSize(SettingsDirectory()) = -2
    ProcedureReturn DeleteDirectory(SettingsDirectory(), "", #PB_FileSystem_Recursive | #PB_FileSystem_Force)
  EndIf
  ProcedureReturn #True
EndProcedure

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

Procedure SavePlanEditor()
  Protected guid$
  ReadPlanEditor()
  SaveSettings()
  guid$ = GetSchemeGuidByName(gPlans(gSelectedPlan)\Name)
  If guid$ <> ""
    ConfigureScheme(@gPlans(gSelectedPlan), guid$)
    LogAction(gPlans(gSelectedPlan)\Name + " saved and applied to Windows.")
  Else
    LogAction(gPlans(gSelectedPlan)\Name + " saved. Click Create/Refresh Plans to install it.")
  EndIf
  RefreshPlanList()
EndProcedure

Procedure ResetSelectedPlan()
  Protected name$ = gPlans(gSelectedPlan)\Name
  LoadDefaultPlan(gSelectedPlan)
  SaveSettings()
  RefreshPlanEditor()
  LogAction(name$ + " reset to defaults.")
EndProcedure

Procedure ApplySettingsToGui()
  SetGadgetState(#GadgetAutoStart, Bool(gSettings\AutoStartWithApp))
  SetGadgetState(#GadgetKeepSettings, Bool(gSettings\KeepSettingsOnReinstall))
EndProcedure

Procedure SaveSettingsFromGui()
  gSettings\AutoStartWithApp = GetGadgetState(#GadgetAutoStart)
  gSettings\KeepSettingsOnReinstall = GetGadgetState(#GadgetKeepSettings)
  SaveSettings()
  SetStartupRegistry(gSettings\AutoStartWithApp)
  LogAction("Settings saved.")
EndProcedure

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

Procedure MonitorAutomaticPlans()
  If ApplyWindowsPowerFollow(#False)
    RefreshPlanList(#True)
  EndIf
EndProcedure

Procedure CreateTrayMenu()
  If CreatePopupMenu(#PopupTray)
    MenuItem(#MenuOpen, "Open PowerPilot")
    MenuBar()
    MenuItem(#MenuMaximum, "Activate Maximum")
    MenuItem(#MenuBalanced, "Activate Balanced")
    MenuItem(#MenuBattery, "Activate Battery")
    MenuBar()
    MenuItem(#MenuCreatePlans, "Create/Refresh Plans")
    MenuItem(#MenuCleanupPlans, "Remove Managed Plans")
    MenuBar()
    MenuItem(#MenuExit, "Exit")
  EndIf
EndProcedure

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

Procedure StartRefreshTimer()
  If gRefreshTimerActive = #False
    AddWindowTimer(#WindowMain, #TimerRefresh, #RefreshMs)
    gRefreshTimerActive = #True
  EndIf
EndProcedure

Procedure StopRefreshTimer()
  If gRefreshTimerActive
    RemoveWindowTimer(#WindowMain, #TimerRefresh)
    gRefreshTimerActive = #False
  EndIf
EndProcedure

Procedure HideToTray()
  StartRefreshTimer()
  If gTrayReady Or gStartedInTrayMode
    HideWindow(#WindowMain, #True)
  Else
    HideWindow(#WindowMain, #False)
    LogAction("Tray icon unavailable. Window stays visible.")
  EndIf
EndProcedure

Procedure ShowFromTray()
  HideWindow(#WindowMain, #False)
  StartRefreshTimer()
  RefreshPlanList(#True)
  RefreshDisplay(#True)
  SetForegroundWindow_(WindowID(#WindowMain))
EndProcedure

Procedure ShutdownApp()
  If gTrayReady
    RemoveSysTrayIcon(#TrayIconMain)
  EndIf
  End
EndProcedure

Procedure HandleAction(gadget.i)
  Protected row.i
  Select gadget
    Case #GadgetRefreshInfo
      gCachedGpuInfo$ = ""
      RefreshDisplay(#True)
      RefreshPlanList(#True)
      LogAction("Hardware and plan display refreshed.")

    Case #GadgetPlanList
      row = GetGadgetState(#GadgetPlanList)
      If row >= 0 And row <= 2
        gSelectedPlan = row
        RefreshPlanEditor()
      EndIf

    Case #GadgetCreatePlans
      ReadPlanEditor()
      SaveSettings()
      CreateManagedPlans()
      RefreshPlanList(#True)
      RefreshDisplay(#True)

    Case #GadgetRemovePlans
      CleanupManagedPlans()
      RefreshPlanList(#True)
      RefreshDisplay(#True)

    Case #GadgetActivatePlan
      ReadPlanEditor()
      ActivatePlanByName(gPlans(gSelectedPlan)\Name)
      RefreshDisplay(#True)

    Case #GadgetPlanSave
      SavePlanEditor()

    Case #GadgetPlanReset
      ResetSelectedPlan()

    Case #GadgetSaveSettings
      SaveSettingsFromGui()

    Case #GadgetHideToTray
      HideToTray()

    Case #GadgetExit
      ShutdownApp()
  EndSelect
EndProcedure

Procedure HandleMenu(menu.i)
  Select menu
    Case #MenuOpen
      ShowFromTray()
    Case #MenuMaximum
      ActivatePlanByName(#PlanFull$)
    Case #MenuBalanced
      ActivatePlanByName(#PlanBalanced$)
    Case #MenuBattery
      ActivatePlanByName(#PlanBattery$)
    Case #MenuCreatePlans
      CreateManagedPlans()
    Case #MenuCleanupPlans
      CleanupManagedPlans()
    Case #MenuExit
      ShutdownApp()
  EndSelect
  RefreshPlanList()
  RefreshDisplay()
EndProcedure

Procedure CreateMainWindow(showWindow.i)
  Protected flags.i = #PB_Window_SystemMenu | #PB_Window_MinimizeGadget | #PB_Window_ScreenCentered
  Protected introOverview.i
  Protected introPlans.i
  Protected activeLabel.i
  Protected modeLabel.i
  Protected lastActionLabel.i
  Protected acHeader.i
  Protected dcHeader.i
  If showWindow = #False
    flags | #PB_Window_Invisible
  EndIf
  OpenWindow(#WindowMain, 0, 0, 760, 520, #AppFullName$, flags)
  EnsureUiFonts()
  CreateTrayMenu()
  SetupTray()

  PanelGadget(#GadgetPanel, 12, 12, 736, 390)
  AddGadgetItem(#GadgetPanel, -1, "Overview")
  introOverview = TextGadget(#PB_Any, 18, 14, 700, 22, "PowerPilot follows Windows power mode: Best performance, Balanced, or Best power efficiency.")
  UseBoldFont(introOverview)
  FrameGadget(#PB_Any, 18, 42, 700, 126, "Processor")
  TextGadget(#GadgetCpuInfo, 34, 64, 668, 92, "Reading CPU...")
  FrameGadget(#PB_Any, 18, 176, 700, 86, "Current State")
  activeLabel = TextGadget(#PB_Any, 34, 206, 92, 22, "Active plan:")
  TextGadget(#GadgetActivePlan, 132, 206, 210, 22, "")
  modeLabel = TextGadget(#PB_Any, 360, 206, 108, 22, "Windows mode:")
  TextGadget(#GadgetPowerSource, 476, 206, 226, 22, "")
  lastActionLabel = TextGadget(#PB_Any, 34, 236, 92, 22, "Last action:")
  TextGadget(#GadgetLastAction, 132, 236, 430, 22, "")
  ButtonGadget(#GadgetRefreshInfo, 586, 230, 116, 28, "Refresh Info")
  UseBoldFont(activeLabel)
  UseBoldFont(#GadgetActivePlan)
  UseBoldFont(modeLabel)
  UseBoldFont(#GadgetPowerSource)
  UseBoldFont(lastActionLabel)
  FrameGadget(#PB_Any, 18, 270, 342, 78, "Graphics")
  TextGadget(#GadgetGpuInfo, 34, 294, 310, 34, "Reading GPU...")
  FrameGadget(#PB_Any, 376, 270, 342, 78, "Startup")
  CheckBoxGadget(#GadgetAutoStart, 392, 292, 150, 20, "Start with Windows")
  CheckBoxGadget(#GadgetKeepSettings, 392, 318, 126, 20, "Keep settings")
  ButtonGadget(#GadgetSaveSettings, 630, 302, 72, 24, "Save")

  AddGadgetItem(#GadgetPanel, -1, "Plans")
  introPlans = TextGadget(#PB_Any, 18, 14, 700, 22, "Create/Refresh copies the selected Windows plan as the base; Windows mode chooses Maximum, Balanced, or Battery.")
  UseBoldFont(introPlans)
  FrameGadget(#PB_Any, 18, 40, 700, 142, "Managed Plans")
  ListIconGadget(#GadgetPlanList, 34, 62, 668, 82, "Plan", 176, #PB_ListIcon_FullRowSelect | #PB_ListIcon_AlwaysShowSelection)
  AddGadgetColumn(#GadgetPlanList, 1, "Installed", 70)
  AddGadgetColumn(#GadgetPlanList, 2, "Purpose", 395)
  ButtonGadget(#GadgetCreatePlans, 34, 150, 122, 24, "Create/Refresh")
  ButtonGadget(#GadgetRemovePlans, 166, 150, 124, 24, "Remove Managed")
  ButtonGadget(#GadgetActivatePlan, 300, 150, 90, 24, "Activate")

  FrameGadget(#PB_Any, 18, 190, 700, 168, "Selected Plan Settings")
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
  ComboBoxGadget(#GadgetPlanAcCooling, 528, 258, 80, 22)
  ComboBoxGadget(#GadgetPlanDcCooling, 618, 258, 80, 22)
  ButtonGadget(#GadgetPlanSave, 528, 310, 80, 26, "Save")
  ButtonGadget(#GadgetPlanReset, 618, 310, 80, 26, "Reset")
  CloseGadgetList()

  ButtonGadget(#GadgetHideToTray, 14, 420, 96, 28, "Hide")
  ButtonGadget(#GadgetExit, 650, 420, 96, 28, "Exit")
  TextGadget(#GadgetStatus, 14, 466, 732, 26, "Ready.", #PB_Text_Border)

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

  ApplySettingsToGui()
  RefreshPlanList(#True)
  RefreshPlanEditor()
  RefreshDisplay(#True)
  MonitorAutomaticPlans()
  RefreshDisplay(#True)

  If showWindow
    HideWindow(#WindowMain, #False)
    StartRefreshTimer()
  Else
    HideToTray()
  EndIf
EndProcedure

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
        If EventTimer() = #TimerRefresh
          If gTrayReady = #False
            SetupTray()
          EndIf
          MonitorAutomaticPlans()
          RefreshDisplay()
        EndIf
      Case #PB_Event_MinimizeWindow
        HideToTray()
    EndSelect
  ForEver
EndProcedure

LoadSettings()
gSelectedPlan = PlanIndexByName(gSettings\LastPlan)
If gSelectedPlan < 0 : gSelectedPlan = 1 : EndIf

If CountProgramParameters() > 0
  Select LCase(ProgramParameter(0))
    Case "/create-plans"
      If CreateManagedPlans() : End 0 : Else : End 1 : EndIf
    Case "/cleanup-plans"
      If CleanupManagedPlans() : End 0 : Else : End 1 : EndIf
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
