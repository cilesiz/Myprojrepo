On Error Resume Next
Dim objshell
set objshell=createobject("Wscript.shell")
strCommand = Wscript.arguments.item(0)
strarg1 = Wscript.arguments.item(1)
strarg2 = Wscript.arguments.item(2)
strarg3 = Wscript.arguments.item(3)
strCMD=chr(34) & strCommand & Chr(34) & " " & Chr(34) & strarg1 & Chr(34) & " " & Chr(34) & strarg2 & Chr(34) & " " & Chr(34) & strarg3 & Chr(34)
objShell.Run strCMD,0