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
strarg10 = Wscript.arguments.item(10)
strarg11 = Wscript.arguments.item(11)
strarg12 = Wscript.arguments.item(12)
strarg13 = Wscript.arguments.item(13)
strarg14 = Wscript.arguments.item(14)
strarg15 = Wscript.arguments.item(15)
strarg16 = Wscript.arguments.item(16)
strarg17 = Wscript.arguments.item(17)
strarg18 = Wscript.arguments.item(18)
strCMD="Powershell -sta -ExecutionPolicy Bypass -file " & chr(34) & strCommand & Chr(34) & " " & Chr(34) & strarg1 & Chr(34) & " " & Chr(34) & strarg2 & Chr(34) & " " & Chr(34) & strarg3 & Chr(34) & " " & Chr(34) & strarg4 & Chr(34) & " " & Chr(34) & strarg5 & Chr(34) & " " & Chr(34) & strarg6 & Chr(34) & " " & Chr(34) & strarg7 & Chr(34) & " " & Chr(34) & strarg8 & Chr(34) & " " & Chr(34) & strarg9 & Chr(34) & " " & Chr(34) & strarg10 & Chr(34) & " " & Chr(34) & strarg11 & Chr(34) & " " & Chr(34) & strarg12 & Chr(34) & " " & Chr(34) & strarg13 & chr(34) & " " & chr(34) & strarg14 & chr(34) & " " & chr(34) & strarg15 & chr(34) & " " & chr(34) & strarg16 & chr(34) & " " & chr(34) & strarg17 & chr(34) & " " & chr(34) & strarg18 & chr(34)
Err.Clear
objShell.Run strCMD,0
If Err.Number <> 0 Then
	strCmd = "Powershell.exe Get-ChildItem " & chr(34) & "C:\Program Files\SCCMConsoleExtensions" & chr(34) & "| Unblock-File"
	strPS = "Powershell.exe Set-ExecutionPolicy Unrestricted"
	objShell.Run strPS,0
	objShell.Run strCMD,0
	objShell.Popup "Error launching Powershell script."
End If