#ImageTrayMain = 1

Procedure.i CreateTrayImage()
  Protected loaded.i
  Protected fallbackIcon$

  fallbackIcon$ = #PB_Compiler_Home + "Examples\Sources\Data\CdPlayer.ico"
  loaded = LoadImage(#ImageTrayMain, fallbackIcon$)
  If loaded
    ProcedureReturn #ImageTrayMain
  EndIf

  ProcedureReturn 0
EndProcedure

OpenConsole()
PrintN("CreateTrayImage return: " + Str(CreateTrayImage()))
PrintN("IsImage(1): " + Str(IsImage(#ImageTrayMain)))
PrintN("ImageID(1): " + Str(ImageID(#ImageTrayMain)))
Input()
