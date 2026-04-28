OpenConsole()

Define iconPath$ = #PB_Compiler_Home + "Examples\Sources\Data\CdPlayer.ico"
Define result.i

PrintN("Icon path: " + iconPath$)
result = LoadImage(1, iconPath$)
PrintN("LoadImage return: " + Str(result))
PrintN("IsImage(1): " + Str(IsImage(1)))
PrintN("ImageID(1): " + Str(ImageID(1)))

Input()
