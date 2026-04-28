EnableExplicit
#NIM_ADD = 0
#NIF_MESSAGE = 1
#NIF_ICON = 2
#NIF_TIP = 4
#WM_APP = $8000
Procedure.i TestCallback(hwnd.i, msg.i, wParam.i, lParam.i)
  ProcedureReturn #PB_ProcessPureBasicEvents
EndProcedure
Define nid.NOTIFYICONDATA
Define large.i
Define small.i
If OpenWindow(0,0,0,100,100,"t",#PB_Window_SystemMenu)
  SetWindowCallback(@TestCallback())
  ExtractIconEx_("C:\\Windows\\System32\\shell32.dll", 112, @large, @small, 1)
  nid\cbSize = SizeOf(NOTIFYICONDATA)
  nid\hWnd = WindowID(0)
  nid\uID = 1
  nid\uFlags = #NIF_MESSAGE | #NIF_ICON | #NIF_TIP
  nid\uCallbackMessage = #WM_APP + 10
  nid\hIcon = small
  PokeS(@nid\szTip[0], "test", -1, #PB_Unicode)
  Debug Shell_NotifyIcon_(#NIM_ADD, @nid)
EndIf
End
