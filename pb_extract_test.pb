EnableExplicit
Define large.i
Define small.i
ExtractIconEx_("C:\\Windows\\System32\\shell32.dll", 112, @large, @small, 1)
If large Or small
  End 0
EndIf
End 1
