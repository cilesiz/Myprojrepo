﻿<#
Written by Ryan Ephgrave for ConfigMgr 2012 Right Click Tools
http://psrightclicktools.codeplex.com/
GUI Generated By: SAPIEN Technologies PrimalForms (Community Edition) v1.0.10.0
Set-TopMost function found at http://poshcode.org/1837 by OmarMAlobeidy
#>

#region Get Arguments
$ErrorActionPreference = "SilentlyContinue"
$count = 0
$action = $null
$msg = $null
$Delay = 30
$Skip = $false
$SchTask = $false

foreach ($arg in $args) {
	$count++
	if ($arg.ToLower() -eq "/s" -or $arg.ToLower() -eq "-s") {
		$action = "Shutdown"
		if ($msg -eq $null) {$msg = "Computer is shutting down. Please save your work or press abort to cancel the shutdown."}
	}
	elseif ($arg.ToLower() -eq "/r" -or $arg.ToLower() -eq "-r") {
		$action = "Restart"
		if ($msg -eq $null) {$msg = "Computer is restarting. Please save your work or press abort to cancel the restart."}
	}
	elseif ($arg.ToLower() -eq "/msg" -or $arg.ToLower() -eq "-msg") {$msg = $args[$count]}
	elseif ($arg.ToLower() -eq "/t" -or $arg.ToLower() -eq "-t") {$Delay = $args[$count]}
	elseif ($arg.ToLower() -eq "/skip" -or $arg.ToLower() -eq "-skip") {$Skip = $true}
	elseif ($arg.ToLower() -eq "/schtask" -or $arg.ToLower() -eq "-schtask") {
		$SchTask = $true
		$RunFile = $args[$count]
	}
}
#endregion

#region Get Action

#I need to make sure action is specified, otherwise it doesn't know what to do:

if ($action -eq $null) {
	$ProcessID = [System.Diagnostics.Process]::GetCurrentProcess()
	$ProcID = $ProcessID.ID
	& taskkill /PID $ProcID /F | Out-Null
}
#endregion

#region Scheduled Task

#Here, if the script is set to run as a scheduled task, it needs to find the current user.
#Scheduled tasks will only display the UI if they are set to run as the current user when they are created.

if ($SchTask -eq $true) {
	$DeleteSelf = $false
	$LoggedOnUser = $null
	$strQuery = "Select UserName from Win32_ComputerSystem"
	Get-WmiObject -Query $strQuery | ForEach-Object {$LoggedOnUser = $_.UserName}
	if ($LoggedOnUser.Length -lt 1) {
		$strQuery = "Select * from Win32_Process where Name like 'explorer.exe'"
		Get-WmiObject -Query $strQuery | ForEach-Object {$LoggedOnUser = $_.GetOwner()}
		$LoggedOnUser = $LoggedOnUser.Domain + "\" + $LoggedOnUser.User
	}
	$LoggedOnUser = $LoggedOnUser | Out-String
	$LoggedOnUser = $LoggedOnUser.replace("`n","")
	if ($LoggedOnUser.Length -gt 2) {
		if ($Skip -eq $true) {
			$ProcessID = [System.Diagnostics.Process]::GetCurrentProcess()
			$ProcID = $ProcessID.ID
			& taskkill /PID $ProcID /F | Out-Null
		}
		else {
			$Today = Get-Date
			$Tomorrow = $Today.AddDays(1)
			$Today = "{0:MM/dd/yyyy}" -f [DateTime]$Today
			$Tomorrow = "{0:MM/dd/yyyy}" -f [DateTime]$Tomorrow
			$VBSFile = $RunFile.replace(".exe",".vbs")
			if ($action -eq "Restart") {
				$ShutdownCommand = "wscript.exe $VBSFile $RunFile /r /t $Delay"
				& cmd /c schtasks.exe /create /RU "$LoggedOnUser" /SC DAILY /SD "$Today" /ST "00:02" /ED "$Tomorrow" /Z /F /TN "Temp_Restart_Task" /TR "`"$ShutdownCommand`""
				Start-Sleep 10
				& cmd /c schtasks.exe /run /i /tn "Temp_Restart_Task"
				& cmd /c schtasks.exe /delete /f /tn "Temp_Restart_Task"
				$ProcessID = [System.Diagnostics.Process]::GetCurrentProcess()
				$ProcID = $ProcessID.ID
				& taskkill /PID $ProcID /F | Out-Null
			}
			elseif ($action -eq "Shutdown") {
				$ShutdownCommand = "wscript.exe $VBSFile $RunFile /s /t $Delay"
				& cmd /c schtasks.exe /create /RU "$LoggedOnUser" /SC DAILY /SD "$Today" /ST "00:02" /ED "$Tomorrow" /Z /F /TN "Temp_Shutdown_Task" /TR "`"$ShutdownCommand`""
				Start-Sleep 10
				& cmd /c schtasks.exe /run /i /tn "Temp_Shutdown_Task"
				& cmd /c schtasks.exe /delete /f /tn "Temp_Shutdown_Task"
				$ProcessID = [System.Diagnostics.Process]::GetCurrentProcess()
				$ProcID = $ProcessID.ID
				& taskkill /PID $ProcID /F | Out-Null
			}
		}
	}
	else {
		if ($action  -eq "Restart") {
			& shutdown /r /f /t $Delay
			$ProcessID = [System.Diagnostics.Process]::GetCurrentProcess()
			$ProcID = $ProcessID.ID
			& taskkill /PID $ProcID /F | Out-Null
		}
		elseif ($action -eq "Shutdown") {
			& shutdown /s /f /t $Delay
			$ProcessID = [System.Diagnostics.Process]::GetCurrentProcess()
			$ProcID = $ProcessID.ID
			& taskkill /PID $ProcID /F | Out-Null
		}
	}
}
#endregion

function GenerateForm {

#region Import the Assemblies
[reflection.assembly]::loadwithpartialname("System.Windows.Forms") | Out-Null
[reflection.assembly]::loadwithpartialname("System.Drawing") | Out-Null
#endregion

#region Generated Form Objects
$ActionForm = New-Object System.Windows.Forms.Form
$Panel = New-Object System.Windows.Forms.Panel
$IconBox = New-Object System.Windows.Forms.PictureBox
$SecLeftBox = New-Object System.Windows.Forms.Label
$MsgBox = New-Object System.Windows.Forms.Label
$AbortBox = New-Object System.Windows.Forms.Button
$InitialFormWindowState = New-Object System.Windows.Forms.FormWindowState
#endregion Generated Form Objects

#region Abort button
$Abort_Btn_Select= 
{
	$AbortHit = $true
	& shutdown -a
	$ProcessID = [System.Diagnostics.Process]::GetCurrentProcess()
	$ProcID = $ProcessID.ID
	& taskkill /PID $ProcID /F | Out-Null
}
#endregion


$OnLoadForm_StateCorrection=
{
	$ActionForm.WindowState = $InitialFormWindowState
	if($action -eq "Shutdown") {& shutdown -s -f -t $Delay}
	elseif($action -eq "Restart") {& shutdown -r -f -t $Delay}
	
#region Set Top Most
$signature = @"
	
	[DllImport("user32.dll")]  
	public static extern IntPtr FindWindow(string lpClassName, string lpWindowName);  

	public static IntPtr FindWindow(string windowName){
		return FindWindow(null,windowName);
	}

	[DllImport("user32.dll")]
	public static extern bool SetWindowPos(IntPtr hWnd, 
	IntPtr hWndInsertAfter, int X,int Y, int cx, int cy, uint uFlags);

	[DllImport("user32.dll")]  
	public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow); 

	static readonly IntPtr HWND_TOPMOST = new IntPtr(-1);
	static readonly IntPtr HWND_NOTOPMOST = new IntPtr(-2);

	const UInt32 SWP_NOSIZE = 0x0001;
	const UInt32 SWP_NOMOVE = 0x0002;

	const UInt32 TOPMOST_FLAGS = SWP_NOMOVE | SWP_NOSIZE;

	public static void MakeTopMost (IntPtr fHandle)
	{
		SetWindowPos(fHandle, HWND_TOPMOST, 0, 0, 0, 0, TOPMOST_FLAGS);
	}

	public static void MakeNormal (IntPtr fHandle)
	{
		SetWindowPos(fHandle, HWND_NOTOPMOST, 0, 0, 0, 0, TOPMOST_FLAGS);
	}
"@

$app = Add-Type -MemberDefinition $signature -Name Win32Window -Namespace ScriptFanatic.WinAPI -ReferencedAssemblies System.Windows.Forms -Using System.Windows.Forms -PassThru
function Set-TopMost
{
	param(		
		[Parameter(
			Position=0,ValueFromPipelineByPropertyName=$true
		)][Alias('MainWindowHandle')]$hWnd=0,

		[Parameter()][switch]$Disable

	)
	
	if($hWnd -ne 0)
	{
		if($Disable)
		{
			Write-Verbose "Set process handle :$hWnd to NORMAL state"
			$null = $app::MakeNormal($hWnd)
			return
		}
		
		Write-Verbose "Set process handle :$hWnd to TOPMOST state"
		$null = $app::MakeTopMost($hWnd)
	}
	else
	{
		Write-Verbose "$hWnd is 0"
	}
}
#endregion
	#region Countdown timer
	$StartTime = Get-Date
	Get-WindowByName "*"
	do {
		$ProcessID = [System.Diagnostics.Process]::GetCurrentProcess()
		$ProcID = $ProcessID.ID
		#Get-WindowByID "$ProcID" | Set-TopMost
		Get-Process | Where-Object {$_.ID -like "$ProcID"} | Select-Object Id,Name,MainWindowHandle,MainWindowTitle | Set-TopMost
		
		[System.Windows.Forms.Application]::DoEvents()
		$CurrentTime = Get-Date
		$CompareTime = $CurrentTime - $StartTime
		$CompareSeconds = $CompareTime.Minutes * 60
		$CompareSeconds = $CompareTime.Seconds + $CompareSeconds
		$SecondsRemaining = $Delay - $CompareSeconds
		if ($PreviousSecondsRemaining -ne $SecondsRemaining){
			$PreviousSecondsRemaining = $SecondsRemaining
			$MinutesRemaining = 0
			$FindMinutesLeft = $SecondsRemaining
			do {
				$FindMinutesLeft = $FindMinutesLeft - 60
				if ($FindMinutesLeft -gt 0) {$MinutesRemaining++}
			} while ($FindMinutesLeft -gt 0)
			if ($SecondsRemaining -gt 60) {
				$SecRemaining = $MinutesRemaining * 60
				$SecRemaining = $SecondsRemaining - $SecRemaining
				if ($MinutesRemaining -eq 1) {$SecLeftBox.Text = "$action in $MinutesRemaining minute and $SecRemaining seconds..."}
				else {$SecLeftBox.Text = "$action in $MinutesRemaining minutes and $SecRemaining seconds..."}
			}
			else {
				$SecLeftBox.Text = "$action in $SecondsRemaining seconds..."
			}
		}
	} while ($SecondsRemaining -ge 0)
	else {& shutdown -a}
	#endregion
	$ActionForm.Close()
}

#----------------------------------------------
#region Generated Form Code
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 218
$System_Drawing_Size.Width = 352
$ActionForm.ClientSize = $System_Drawing_Size
$ActionForm.ControlBox = $False
$ActionForm.DataBindings.DefaultDataSourceUpdateMode = 0
$ActionForm.FormBorderStyle = 1
$ActionForm.MaximizeBox = $False
$ActionForm.Icon = [System.Drawing.SystemIcons]::Warning
$ActionForm.Name = "ActionForm"
$ActionForm.ShowIcon = $False
$ActionForm.StartPosition = 1
$ActionForm.Text = "Computer will $action"
$ActionForm.TopMost = $True
$ActionForm.add_FormClosing($FormClosing)


$Panel.BorderStyle = 1
$Panel.DataBindings.DefaultDataSourceUpdateMode = 0
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 12
$System_Drawing_Point.Y = 12
$Panel.Location = $System_Drawing_Point
$Panel.Name = "Panel"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 170
$System_Drawing_Size.Width = 336
$Panel.Size = $System_Drawing_Size
$Panel.TabIndex = 2

$ActionForm.Controls.Add($Panel)

$IconBox.DataBindings.DefaultDataSourceUpdateMode = 0

$IconBox.Image = [System.Drawing.SystemIcons]::Warning

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 3
$System_Drawing_Point.Y = 36
$IconBox.Location = $System_Drawing_Point
$IconBox.Name = "IconBox"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 72
$System_Drawing_Size.Width = 73
$IconBox.Size = $System_Drawing_Size
$IconBox.SizeMode = 1
$IconBox.TabIndex = 4
$IconBox.TabStop = $False

$Panel.Controls.Add($IconBox)

$SecLeftBox.DataBindings.DefaultDataSourceUpdateMode = 0
$SecLeftBox.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",10,0,3,1)

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 3
$System_Drawing_Point.Y = 136
$SecLeftBox.Location = $System_Drawing_Point
$SecLeftBox.Name = "SecLeftBox"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 23
$System_Drawing_Size.Width = 328
$SecLeftBox.Size = $System_Drawing_Size
$SecLeftBox.TabIndex = 3
$SecLeftBox.TextAlign = 32

$Panel.Controls.Add($SecLeftBox)

$MsgBox.DataBindings.DefaultDataSourceUpdateMode = 0
$MsgBox.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",12,0,3,1)

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 82
$System_Drawing_Point.Y = 9
$MsgBox.Location = $System_Drawing_Point
$MsgBox.Name = "MsgBox"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 118
$System_Drawing_Size.Width = 245
$MsgBox.Size = $System_Drawing_Size
$MsgBox.TabIndex = 2
$MsgBox.Text = "$msg"
$MsgBox.TextAlign = 32

$Panel.Controls.Add($MsgBox)



$AbortBox.DataBindings.DefaultDataSourceUpdateMode = 0

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 125
$System_Drawing_Point.Y = 191
$AbortBox.Location = $System_Drawing_Point
$AbortBox.Name = "AbortBox"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 23
$System_Drawing_Size.Width = 115
$AbortBox.Size = $System_Drawing_Size
$AbortBox.TabIndex = 1
$AbortBox.Text = "Abort $action"
$AbortBox.UseVisualStyleBackColor = $True
$AbortBox.add_Click($Abort_Btn_Select)
$AbortBox.add_KeyPress($Abort_Btn_Select)

$ActionForm.Controls.Add($AbortBox)

#endregion Generated Form Code

#Save the initial state of the form
$InitialFormWindowState = $ActionForm.WindowState
#Init the OnLoad event to correct the initial state of the form
$ActionForm.add_Load($OnLoadForm_StateCorrection)
#Show the Form
$ActionForm.ShowDialog()| Out-Null

} #End Function

#Call the Function
GenerateForm