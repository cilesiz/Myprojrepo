On Error Resume Next
Dim objshell
set objshell=createobject("Wscript.shell")
strCommand = Wscript.arguments.item(0)
strarg1 = Wscript.arguments.item(1)
strarg2 = Wscript.arguments.item(2)
strarg3 = Wscript.arguments.item(3)
strarg4 = Wscript.arguments.item(4)
strarg5 = Wscript.arguments.item(5)
strarg6 = Wscript.arguments.item(6)
strarg7 = Wscript.arguments.item(7)
strarg8 = Wscript.arguments.item(8)
strarg9 = Wscript.arguments.item(9)
strCMD="Powershell -ExecutionPolicy Bypass -file " & chr(34) & strCommand & Chr(34) & " " & Chr(34) & strarg1 & Chr(34) & " " & Chr(34) & strarg2 & Chr(34) & " " & Chr(34) & strarg3 & Chr(34) & " " & Chr(34) & strarg4 & Chr(34) & " " & Chr(34) & strarg5 & Chr(34) & " " & Chr(34) & strarg6 & Chr(34) & " " & Chr(34) & strarg7 & Chr(34) & " " & Chr(34) & strarg8 & Chr(34) & " " & Chr(34) & strarg9 & Chr(34)
Err.Clear
objShell.Run strCMD
If Err.Number <> 0 Then
	strCmd = "Powershell.exe Get-ChildItem " & chr(34) & "C:\Program Files\SCCMConsoleExtensions" & chr(34) & "| Unblock-File"
	strPS = "Powershell.exe Set-ExecutionPolicy Unrestricted"
	objShell.Run strPS,0
	objShell.Run strCMD,0
	objShell.Popup "Error launching Powershell script."
End If