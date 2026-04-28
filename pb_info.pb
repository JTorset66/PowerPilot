CompilerIf #PB_Compiler_Thread
  Debug "THREAD=1"
CompilerElse
  Debug "THREAD=0"
CompilerEndIf
Debug "VERSION=" + Str(#PB_Compiler_Version)
Debug "OS=" + Str(#PB_Compiler_OS)
