On Error Resume Next
Dim objShell
set Objshell=createobject("WScript.shell")
Dim strcmd, PopupAnswer, strTime, EndTime, objFSO

strComputer = "."
EndTime = WScript.arguments.item(0)

strTime = EndTime
StartTime = Timer()
do while strtime > 5

	if strtime MOD 30 = 0 or strTime = EndTime Then
		strmsg = "The system will shut down in " & strTime & " seconds. Please save your work and log off, or press cancel to abort the shutdown."
		PopupAnswer = objShell.Popup(strmsg,19,"You are about to be logged off",1+48+4096)
	End if

	if PopupAnswer = 2 Then
		strCMD = "shutdown -a"
		objshell.run strCMD
        Set objFSO = CreateObject("Scripting.FileSystemObject")
        objFSO.DeleteFile WScript.ScriptFullName
        Set objFSO = Nothing
		wscript.quit
	end if
	CurrentTime = Timer()
	RunTime = FormatNumber(CurrentTime - StartTime, 0)
	strTime = EndTime - RunTime
Loop

Set objFSO = CreateObject("Scripting.FileSystemObject")
objFSO.DeleteFile WScript.ScriptFullName
Set objFSO = Nothing