EnableExplicit
Procedure.i TestCallback(hwnd.i, msg.i, wParam.i, lParam.i)
  ProcedureReturn #PB_ProcessPureBasicEvents
EndProcedure
If OpenWindow(0,0,0,100,100,"t",#PB_Window_SystemMenu)
  SetWindowCallback(@TestCallback())
EndIf
End
