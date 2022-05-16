'==========================================================================
'
'
' NAME: Windows Servers Disk Space notifier Script
'
' AUTHOR: Ameer Mohammed,
' Hewlett-Packard GlobalSoft, Digital Park, Electronic City
' Hosur Road, Bangalore 560100, India
'
' COMMENT: 
'
'==========================================================================
Const cdoSendUsingMethod = "http://schemas.microsoft.com/cdo/configuration/sendusing", _
cdoSendUsingPort = 2, _
cdoSMTPServer = "http://schemas.microsoft.com/cdo/configuration/smtpserver"
Const HARD_DISK = 3
Const ForReading = 1
Const ForWriting = 2
Const ForAppending = 8

Dim strComputer, Silent, strGBFree, strDiskFreeSpace
Dim strDiskDrive, strPercFree, strDiskUsed, CurTime, OutputDir
Dim cbgcolor, wbgcolor, strbgcolor, varlastemail, vartoday, fstyle
Dim sMailSched, strMailTo, strMailFrom, strSubject, StrMessage, strSMTPServer
Dim Command, Count
Dim f, r, w, ws, WshSysEnv, WshShell
On Error Resume Next

'------------------
' Set variables here:
'------------------
strCompany = "COMPANY NAME"
Silent = 1 '0/1 - '1' does not open summary after execution
Email = 1 '0/1 - '1' sends email after execution
strCrit = 10 'if free space % is below this threshold, make critical
strWarn = 20 'if free space % is below this threshold but not below sCrit, 
' then don't make critical, make warning instead
cbgcolor = "Lavender" 'set critical background color
wbgcolor = "#darr" 'set warning background color
nbgcolor = "white" 'set normal background color
SourceFile = ".\Servers.txt" 'set where to pull server names from
'server names must not have leading backslashes (format below): 
'         server1 
'         server2 
fstyle = "Verdana" 'set default font for table
sMailSched = "1,2,3,4,5,6,7" 'set the days of week that you want to email on
' 1 is sunday, 2 is monday, etc. - separate numbers by commas
strMailto = "TO-ADDRESS@YOUR-DOMAIN.COM" 'who are you mailing to
strMailFrom = "FROM-ADDRESS@YOUR-DOMAIN.COM" 'recipient address
strSubject = "ProActive DiskSpace Monitoring Report" 'mail subject
'strMessage = "See attachment, low drive space report" 'message
strSMTPServer = "mail.YOUR-DOMAIN.com"
OutputDir = "C:\HP\Wintel\Admin_Tasks\DiskSpace" 'set root directory that you will save HTMs in
' if blank, it will default to your temp folder
' folder format must not have a trailing backslash!
' i.e. "c:\temp"
sMailOnceDaily = 1 '0/1 - '1' sends email every time script 
' is run - otherwise, it is emailed once on days of the 
' week specified in strMailSched above.

Count = 0
'------------------

Set WshShell = WScript.CreateObject("WScript.Shell")
Set WshSysEnv = WshShell.Environment("PROCESS")
Set ws = CreateObject ("Scripting.FileSystemObject")

WshShell.RegWrite "HKLM\SOFTWARE\" & strCompany & "\IS\DriveSpace\", 1, "REG_SZ"
WshShell.RegWrite "HKLM\SOFTWARE\" & strCompany & "\IS\DriveSpace\LastEmail", "", "REG_SZ"

'------------------
If OutputDir = "" Then 
    OutputFile = WshSysEnv("TEMP") & "\Drivespace.htm"
    WarningFile = WshSysEnv("TEMP") & "\Warning.htm"
Else
    OutputFile = OutputDir & "\Drivespace.htm"
    WarningFile = OutputDir & "\Warning.htm"
End If

'Checks to see if this file exists, then deletes it prior to making a new
'one (otherwise it would append to the end of the file).
If CheckFileExists(outputfile) Then
    Set oldfile = ws.GetFile(OutputFile)
    'wscript.echo OutPutFile & " exists. Now deleting." 
    oldfile.Delete
End If

If CheckFileExists(warningfile) Then
    Set oldfile = ws.GetFile(warningfile)
	Set oldfile2 = ws.GetFile(OutputFile)
    wscript.echo WarningFile & " exists. Now deleting." 
	wscript.echo OutPutFile & " exists. Now deleting."
    oldfile.Delete
	oldfile2.Delete
End If
'------------------

CurTime = Now 'find current time that you executed the script
strSubject = "ProActive DiskSpace Report - " & CurTime

'Set w = ws.OpenTextFile (OutputFile, ForAppending, True)

Do While Count <= 1
If Count = 1 Then
    Set w = ws.OpenTextFile (WarningFile, ForAppending, True)
ElseIf Count = 0 Then 
    Set w = ws.OpenTextFile (OutputFile, ForAppending, True)
End If
    w.Writeline ("<html>")
    w.Writeline ("<head>")
    w.Writeline ("<title> DiskSpace Report Generated at " & CurTime & "</title>")
    w.Writeline ("</head>")
    w.Writeline ("<table BORDER=0 width=100% cellspacing=0 cellpadding=3>")
    w.Writeline ("<tr>")
    w.Writeline ("<th bgcolor=#CCCCCC colspan=5 width=100%>")
    w.Writeline ("<p align=Center><font face= 'verdana' " & fstyle & " color=black size=6>""C O M P A N Y    N A M E""</font>")
    w.Writeline ("</th>")
    w.Writeline ("</tr>")
    'w.Writeline ("<h0><B><font face='Segoe UI' color=#000033 size=2> DiskSpace Report Generated at "_
    '& CurTime & "</B></font></h0>")
    w.Writeline ("<th bgcolor=#000080 colspan=5 width=100%>")
	w.Writeline ("<p align=Center><font face= 'Tahoma' " & fstyle & " color=white size=4>""Pro-Active DiskSpace Monitoring Report""</font>")
    'w.Writeline ("<p align=Center>")
    w.Writeline ("<BR>")
    w.Writeline ("</tr>")
w.Writeline ("<TR>")
w.Writeline ("<TD><B><font face='Verdana'" & fstyle & " color=#000033 size=2> Server Name </font></B></TD>")
w.Writeline ("<TD><B><font face='Verdana'" & fstyle & " color=#000033 size=2> Drive Letter </font></B></TD>")
w.Writeline ("<TD><B><font face='Verdana'" & fstyle & " color=#000033 size=2> Total Size </font></B></TD>")
w.Writeline ("<TD><B><font face='Verdana'" & fstyle & " color=#000033 size=2> Space Used </font></B></TD>")
w.Writeline ("<TD><B><font face='Verdana'" & fstyle & " color=#000033 size=2> FreeSpace % </font></B></TD>")
w.Writeline ("</TR>")
    Count = Count + 1
    w.close
Loop
'------------------
Count = 0

Set f = ws.OpenTextFile (SourceFile, ForReading, True) 
Do While f.AtEndOfStream <> True
If f.AtEndOfStream <> True Then

    strComputer = f.ReadLine 'set input string to computername
    
    Set objWMIService = GetObject("winmgmts:" _
    & "{impersonationLevel=impersonate}!\\" & strComputer & "\root\cimv2")
    Set colDisks = objWMIService.ExecQuery _
    ("Select * from Win32_LogicalDisk Where DriveType = " & HARD_DISK & "")
    
    For Each objDisk in colDisks
        strDiskDrive = objDisk.DeviceID
        strDiskUsed = FormatNumber((((objDisk.Size - objDisk.FreeSpace) / 1024) / 1024) / 1024)
        strDiskSize = FormatNumber(((objDisk.Size / 1024) / 1024) / 1024,2)
        strDiskFree = FormatNumber(((objDisk.Freespace / 1024) / 1024) / 1024,2)
        strPercFree = FormatNumber(objDisk.FreeSpace/objDisk.Size,2)
        strPercFree = strPercFree * 100 'multiply percent by 100 to get whole number
        'wscript.echo strPercFree & "% free."

        'If the percentage free is less than or equal to warning level %
        ' and percentage free is greater than critical level % then set to warning
        If strPercFree <= strWarn and strPercFree > strCrit Then
            'wscript.echo "Warning! Drive " & Chr(34) & strDiskDrive & Chr(34) & ""_
            '& " has triggered the threshold warning! Drive has " & strPercFree & "% free."
            strBgcolor = wbgcolor 'set bgcolor of row to warning color
            Count = Count + 1    
            'If percentage free is less than warning % and percentage free is
            ' less than or equal to critical %, then set to critical
        
        ElseIf strPercFree < strWarn and strPercFree <= strCrit Then
            'wscript.echo "Critical! Drive " & Chr(34) & strDiskDrive & Chr(34) & ""_
            '& " has triggered the threshold warning! Drive has " & strPercFree & "% free."
            strBgcolor = cbgcolor 'set bgcolor of row to critical color
            Count = Count + 1
        End If

        Call WriteLines
    Next
Count = 0
End If
Loop 

CurTime = Now

'Now finishing the HTM file...
Do While Count <= 1
If Count = 1 Then
Set w = ws.OpenTextFile(WarningFile, ForAppending,True)
w.Writeline ("<th bgcolor=" & Chr(34) & strbgcolor & Chr(34) & ""_
& "colspan=5 width=100%><font size=0 color=white font=" & fstyle & ""_
& "> finished processing at " & CurTime & "</font></tr></table></html>")
w.close
Set w = ws.OpenTextFile(WarningFile, ForReading, False, TristateUseDefault) 

ElseIf Count = 0 Then 
Set w = ws.OpenTextFile (OutputFile, ForAppending, True)
w.Writeline ("<th bgcolor=" & Chr(34) & strbgcolor & Chr(34) & ""_
& "colspan=5 width=100%><font size=0 color=white font=" & fstyle & ""_
& "> finished processing at " & CurTime & "</font></tr></table></html>")
w.close
Set w = ws.OpenTextFile(OutputFile, ForReading, False, TristateUseDefault) 
End If 

Count = Count + 1
strMessage = w.ReadAll
w.close
loop

If Silent = 0 Then 
    'Now run the file in your default associated program...
    Command = OutputFile
    WshShell.Run Command,1,False
End If

'get the day of the week at time of execution
varToday = Weekday(Date)

If sMailOnceDaily = 0 Then
    bkey = WSHShell.RegRead("HKLM\SOFTWARE\KerryInc\IS\DriveSpace\LastEmail")
    If InStr(1,bkey,Date) Then
        Email = 0
    End If
End If

If Email = 1 Then
    'if today's numerical value is found in the sMailSched string
    ' then run the email function.
    If InStr(1,sMailSched,varToday) Then 
        'wscript.echo "Now emailing to " & strMailto & "..." 
        WshShell.RegWrite "HKLM\SOFTWARE\KerryInc\IS\DriveSpace\LastEmail",Date, "REG_SZ"
        Call EmailFile
    End If
End If
    
'------------------
'Write the actual lines of data into the file
'------------------
Function Writelines
     If Count = 1 Then
         Set w = ws.OpenTextFile (WarningFile, ForAppending, True)
     ElseIf Count = 0 Then 
         Set w = ws.OpenTextFile (OutputFile, ForAppending, True)
     End If         
        w.Writeline ("<TR>")
        w.Writeline ("<TD bgcolor=" & Chr(34) & strbgcolor & Chr(34) & "><B><font face="_
        & "" & fstyle & " color=#000080 size=1>" & strComputer & "</font></B></TD>")
        w.Writeline ("<TD bgcolor=" & Chr(34) & strbgcolor & Chr(34) & "><B><font face="_
        & "" & fstyle & " color=#000080 size=1>" & strDiskDrive & "</font></B></TD>")
        w.Writeline ("<TD bgcolor=" & Chr(34) & strbgcolor & Chr(34) & "><B><font face="_
        & "" & fstyle & " color=#000080 size=1>" & strDiskSize & " GB </font></B></TD>")
        w.Writeline ("<TD bgcolor="& Chr(34) & strbgcolor & Chr(34) & "><B><font face="_
        & "" & fstyle & " color=#000080 size=1>" & strDiskUsed & " GB </font></B></TD>")
        w.Writeline ("<TD bgcolor=" & Chr(34) & strbgcolor & Chr(34) & "><B><font face="_
        & "" & fstyle & " color=#000080 size=1>" & strPercFree & "% </font></B></TD>")
        w.Writeline ("</TR>")
        w.close
     If Count = 1 Then
         Count = Count - 1
        WriteLines
     End If

    'Count = 0
    strDiskDrive = ""
    strDiskSize = ""
    strDiskUsed = ""
    strPercFree = ""
    strbgcolor = ""

End Function

'------------------
'Function CheFileExists - to see if file exists
'------------------
Function CheckFileExists(sFileName)

Dim FileSystemObject

Set FileSystemObject = CreateObject("Scripting.FileSystemObject")

If (FileSystemObject.FileExists(sFileName)) Then
    CheckFileExists = True
Else
    CheckFileExists = False
End If

Set FileSystemObject = Nothing

End Function


'------------------
'Function EmailFile - email the warning file
'------------------
Function EmailFile
Dim iMsg, iConf, Flds

'// Create the CDO connections.
Set iMsg = CreateObject("CDO.Message")
Set iConf = CreateObject("CDO.Configuration")
Set Flds = iConf.Fields

'// SMTP server configuration.
With Flds
.Item(cdoSendUsingMethod) = cdoSendUsingPort

'// Set the SMTP server address here.
.Item(cdoSMTPServer) = strSMTPServer
.Update
End With

'// Set the message properties.
With iMsg
Set .Configuration = iConf
.To = strMailTo
.From = strMailFrom
.Subject = strSubject
.TextBody = strMessage
End With

iMsg.HTMLBody = strMessage
'// An attachment can be included.
'iMsg.AddAttachment WarningFile 

'// To add another attachment, add a new line...
'iMsg.AddAttachment OutputFile

'// Send the message.
iMsg.Send ' send the message.
End Function