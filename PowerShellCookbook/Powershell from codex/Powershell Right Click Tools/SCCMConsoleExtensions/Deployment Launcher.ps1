﻿<#
Written by Ryan Ephgrave for ConfigMgr 2012 Right Click Tools
http://psrightclicktools.codeplex.com/
GUI Generated By: SAPIEN Technologies PrimalForms (Community Edition) v1.0.10.0
#>

$Tool = $args[0]
$DeploymentName = $args[1]
$DeploymentID = $args[2]
$AssignmentID = $args[3]
$FeatureType = $args[4]
$Server = $args[5]
$Namespace = $args[6]

$Popup = new-object -comobject wscript.shell
$GetDirectory = $MyInvocation.MyCommand.path
$Directory = Split-Path $GetDirectory

function GenerateForm {

#region Import the Assemblies
[reflection.assembly]::loadwithpartialname("System.Drawing") | Out-Null
[reflection.assembly]::loadwithpartialname("System.Windows.Forms") | Out-Null
#endregion

#region Generated Form Objects
$form1 = New-Object System.Windows.Forms.Form
$CancelBtn = New-Object System.Windows.Forms.Button
$StartBtn = New-Object System.Windows.Forms.Button
$AboutBtn = New-Object System.Windows.Forms.Button
$panel1 = New-Object System.Windows.Forms.Panel
$UnknownBox = New-Object System.Windows.Forms.CheckBox
$RequireBox = New-Object System.Windows.Forms.CheckBox
$ErrorBox = New-Object System.Windows.Forms.CheckBox
$InProgBox = New-Object System.Windows.Forms.CheckBox
$SuccessBox = New-Object System.Windows.Forms.CheckBox
$RunOnLbl = New-Object System.Windows.Forms.Label
$ToolLbl = New-Object System.Windows.Forms.Label
$DeploymentLbl = New-Object System.Windows.Forms.Label
$InitialFormWindowState = New-Object System.Windows.Forms.FormWindowState
#endregion Generated Form Objects

$AboutBtn_OnClick= 
{
	$ArgList = @()
	$ArgList += @("`"$Directory\SilentOpenPS.vbs`"")
	$ArgList += @("`"$Directory\About.ps1`"")
	Start-Process wscript.exe -ArgumentList $ArgList
}

$CancelBtn_OnClick= 
{
	$form1.close()
}

$StartBtn_OnClick= 
{
	$Statuses = $null
	if ($SuccessBox.Checked -eq $true) {$Statuses = $Statuses + "1"}
	if ($InProgBox.checked -eq $true) {$Statuses = $Statuses + "2"}
	if ($RequireBox.checked -eq $true) {$Statuses = $Statuses + "3"}
	if ($UnknownBox.Checked -eq $true) {$Statuses = $Statuses + "4"}
	if ($ErrorBox.checked -eq $true) {$Statuses = $Statuses + "5"}
	if ($Statuses -eq $null) {$Popup.popup("Please check at least one box...",0,"Error",16)}
	else {
		$ArgList = @()
		$ArgList += @("`"$Directory\SilentOpenPS.vbs`"")
		if ($Tool.contains(" Cycle")) {
			$ArgList += @("`"$Directory\Deployment - Client Actions.ps1`"")
			$ArgList += @("`"$Tool`"")
		}
		elseif ($Tool -eq "System Information") {$ArgList += @("`"$Directory\Deployment - System Information.ps1`"")}
		elseif ($Tool -eq "Change Cache Size") {$ArgList += @("`"$Directory\Deployment - Change Cache.ps1`"")}
		elseif ($Tool -eq "Clear Client Cache") {$ArgList += @("`"$Directory\Deployment - Clear Cache.ps1`"")}
		elseif ($Tool -eq "Rerun Deployment") {$ArgList += @("`"$Directory\Deployment - Rerun Deployment.ps1`"")}
		elseif ($Tool -eq "Restart SMS Agent Host Service") {$ArgList += @("`"$Directory\Deployment - Restart SMS Service.ps1`"")}
		elseif ($Tool -eq "Repair Client") {$ArgList += @("`"$Directory\Deployment - Repair Client.ps1`"")}
		elseif ($Tool -eq "Uninstall Client") {$ArgList += @("`"$Directory\Deployment - Uninstall Client.ps1`"")}
		elseif ($Tool -eq "Ping") {$ArgList += @("`"$Directory\Deployment - Ping.ps1`"")}
		elseif ($Tool -eq "Wake on LAN") {$ArgList += @("`"$Directory\Deployment - WOL.ps1`"")}
		elseif ($Tool -eq "Cancel Pending Shutdown") {$ArgList += @("`"$Directory\Deployment - Cancel Pending Restart Shutdown.ps1`"")}
		elseif ($Tool -eq "Schedule Restart or Shutdown") {$ArgList += @("`"$Directory\Deployment - Schedule Shutdown Menu.ps1`"")}
		elseif ($Tool -eq "Restart" -or $Tool -eq "Shutdown") {
			$ArgList += @("`"$Directory\Deployment - Shutdown Restart Menu.ps1`"")
			$ArgList += @("`"$Tool`"")
		}
		$ArgList += @("`"$DeploymentName`"")
		$ArgList += @("`"$DeploymentID`"")
		$ArgList += @("`"$AssignmentID`"")
		$ArgList += @("`"$FeatureType`"")
		$ArgList += @("`"$Server`"")
		$ArgList += @("`"$Namespace`"")
		$ArgList += @("`"$Statuses`"")
		Start-Process wscript.exe -ArgumentList $ArgList
		$form1.close()
	}
}

$OnLoadForm_StateCorrection=
{
	$form1.WindowState = $InitialFormWindowState
	$SuccessNum = 0
	$InProgNum = 0
	$ReqNum = 0
	$UnknownNum = 0
	$ErrorNum = 0
	if ($FeatureType -eq 1) {
		if ($Tool -eq "Rerun Deployment") {
			$Popup.Popup("Error, you can only rerun Packages and Task Sequences with this tool",0,"Error",16)
			$ProcessID = [System.Diagnostics.Process]::GetCurrentProcess()
			$ProcID = $ProcessID.ID
			& taskkill /PID $ProcID /T /F
		}
		$strquery = "select * from SMS_CIDeploymentUnknownAssetDetails where AssignmentID = '$AssignmentID'"
		Get-WmiObject -Query $strquery -Namespace $Namespace -ComputerName $Server | ForEach-Object {$UnknownNum++}
		$strquery = "select * from SMS_AppDeploymentAssetDetails where AssignmentID = '$AssignmentID'"
		Get-WmiObject -Query $strquery -Namespace $Namespace -ComputerName $Server | ForEach-Object {
			$StatusCode = $_.StatusType
			if ($StatusCode -eq 1){$SuccessNum++}
			elseif ($StatusCode -eq 2){$InProgNum++}
			elseif ($StatusCode -eq 3) {$ReqNum++}
			elseif ($StatusCode -eq 5) {$ErrorNum++}
		}
	}
	elseif ($FeatureType -eq 5) {
		if ($Tool -eq "Rerun Deployment") {
			$Popup.Popup("Error, you can only rerun Packages and Task Sequences with this tool",0,"Error",16)
			$ProcessID = [System.Diagnostics.Process]::GetCurrentProcess()
			$ProcID = $ProcessID.ID
			& taskkill /PID $ProcID /T /F
		}
		$strquery = "select * from SMS_SUMDeploymentAssetDetails where AssignmentID = '$AssignmentID'"
		Get-WmiObject -Query $strquery -Namespace $Namespace -ComputerName $Server | ForEach-Object {
			$StatusCode = $_.StatusType
			if ($StatusCode -eq 1){$SuccessNum++}
			elseif ($StatusCode -eq 2){$InProgNum++}
			elseif ($StatusCode -eq 3) {$ReqNum++}
			elseif ($StatusCode -eq 4) {$UnknownNum++}
			elseif ($StatusCode -eq 5) {$ErrorNum++}
		}
	}
	elseif ($FeatureType -eq 2 -or $FeatureType -eq 7) {
		$strquery = "select * from SMS_ClassicDeploymentAssetDetails where DeploymentID = '$DeploymentID'"
		Get-WmiObject -Query $strquery -Namespace $Namespace -ComputerName $Server | ForEach-Object {
			$StatusCode = $_.StatusType
			if ($StatusCode -eq 1){$SuccessNum++}
			elseif ($StatusCode -eq 2){$InProgNum++}
			elseif ($StatusCode -eq 3) {$ReqNum++}
			elseif ($StatusCode -eq 4) {$UnknownNum++}
			elseif ($StatusCode -eq 5) {$ErrorNum++}
		}
	}
	else {
		$Popup.popup("Only Packages, Applications, Task Sequences and Software Updates are currently supported...",0,"Error",16)
		$form1.close()
	}
	if ($SuccessNum -eq 0) {$SuccessBox.enabled = $false}
	if ($InProgNum -eq 0) {$InProgBox.enabled = $false}
	if ($ReqNum -eq 0) {$RequireBox.enabled = $false}
	if ($UnknownNum -eq 0) {$UnknownBox.enabled = $false}
	if ($ErrorNum -eq 0) {$ErrorBox.enabled = $false}
	$UnknownBox.Text = "Unknown: $UnknownNum"
	$RequireBox.Text = "Requirements Not Met: $ReqNum"
	$ErrorBox.Text = "Error: $ErrorNum"
	$InProgBox.Text = "In Progress: $InProgNum"
	$SuccessBox.Text = "Successful: $SuccessNum"
}

#----------------------------------------------
#region Generated Form Code
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 220
$System_Drawing_Size.Width = 462
$form1.ClientSize = $System_Drawing_Size
$form1.ControlBox = $False
$form1.DataBindings.DefaultDataSourceUpdateMode = 0
$form1.FormBorderStyle = 1
$form1.Name = "form1"
$form1.Text = "$Tool Deployment"


$CancelBtn.DataBindings.DefaultDataSourceUpdateMode = 0

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 294
$System_Drawing_Point.Y = 187
$CancelBtn.Location = $System_Drawing_Point
$CancelBtn.Name = "CancelBtn"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 23
$System_Drawing_Size.Width = 75
$CancelBtn.Size = $System_Drawing_Size
$CancelBtn.TabIndex = 7
$CancelBtn.Text = "Cancel"
$CancelBtn.UseVisualStyleBackColor = $True
$CancelBtn.add_Click($CancelBtn_OnClick)

$form1.Controls.Add($CancelBtn)


$StartBtn.DataBindings.DefaultDataSourceUpdateMode = 0

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 375
$System_Drawing_Point.Y = 187
$StartBtn.Location = $System_Drawing_Point
$StartBtn.Name = "StartBtn"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 23
$System_Drawing_Size.Width = 75
$StartBtn.Size = $System_Drawing_Size
$StartBtn.TabIndex = 6
$StartBtn.Text = "Start"
$StartBtn.UseVisualStyleBackColor = $True
$StartBtn.add_Click($StartBtn_OnClick)

$form1.Controls.Add($StartBtn)


$AboutBtn.DataBindings.DefaultDataSourceUpdateMode = 0

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 16
$System_Drawing_Point.Y = 187
$AboutBtn.Location = $System_Drawing_Point
$AboutBtn.Name = "AboutBtn"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 23
$System_Drawing_Size.Width = 75
$AboutBtn.Size = $System_Drawing_Size
$AboutBtn.TabIndex = 5
$AboutBtn.Text = "About"
$AboutBtn.UseVisualStyleBackColor = $True
$AboutBtn.add_Click($AboutBtn_OnClick)

$form1.Controls.Add($AboutBtn)


$panel1.BorderStyle = 1
$panel1.DataBindings.DefaultDataSourceUpdateMode = 0
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 12
$System_Drawing_Point.Y = 112
$panel1.Location = $System_Drawing_Point
$panel1.Name = "panel1"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 69
$System_Drawing_Size.Width = 438
$panel1.Size = $System_Drawing_Size
$panel1.TabIndex = 4

$form1.Controls.Add($panel1)

$UnknownBox.DataBindings.DefaultDataSourceUpdateMode = 0

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 254
$System_Drawing_Point.Y = 33
$UnknownBox.Location = $System_Drawing_Point
$UnknownBox.Name = "UnknownBox"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 24
$System_Drawing_Size.Width = 143
$UnknownBox.Size = $System_Drawing_Size
$UnknownBox.TabIndex = 4
$UnknownBox.Text = "Unknown: $UnknownNum"
$UnknownBox.UseVisualStyleBackColor = $True

$panel1.Controls.Add($UnknownBox)


$RequireBox.DataBindings.DefaultDataSourceUpdateMode = 0

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 23
$System_Drawing_Point.Y = 33
$RequireBox.Location = $System_Drawing_Point
$RequireBox.Name = "RequireBox"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 24
$System_Drawing_Size.Width = 193
$RequireBox.Size = $System_Drawing_Size
$RequireBox.TabIndex = 3
$RequireBox.Text = "Requirements Not Met: $ReqNum"
$RequireBox.UseVisualStyleBackColor = $True

$panel1.Controls.Add($RequireBox)


$ErrorBox.DataBindings.DefaultDataSourceUpdateMode = 0

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 329
$System_Drawing_Point.Y = 3
$ErrorBox.Location = $System_Drawing_Point
$ErrorBox.Name = "ErrorBox"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 24
$System_Drawing_Size.Width = 104
$ErrorBox.Size = $System_Drawing_Size
$ErrorBox.TabIndex = 2
$ErrorBox.Text = "Error: $ErrorNum"
$ErrorBox.UseVisualStyleBackColor = $True

$panel1.Controls.Add($ErrorBox)


$InProgBox.DataBindings.DefaultDataSourceUpdateMode = 0

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 161
$System_Drawing_Point.Y = 3
$InProgBox.Location = $System_Drawing_Point
$InProgBox.Name = "InProgBox"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 24
$System_Drawing_Size.Width = 131
$InProgBox.Size = $System_Drawing_Size
$InProgBox.TabIndex = 1
$InProgBox.Text = "In Progress: $InProgNum"
$InProgBox.UseVisualStyleBackColor = $True

$panel1.Controls.Add($InProgBox)


$SuccessBox.DataBindings.DefaultDataSourceUpdateMode = 0

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 3
$System_Drawing_Point.Y = 3
$SuccessBox.Location = $System_Drawing_Point
$SuccessBox.Name = "SuccessBox"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 24
$System_Drawing_Size.Width = 132
$SuccessBox.Size = $System_Drawing_Size
$SuccessBox.TabIndex = 0
$SuccessBox.Text = "Successful: $SuccessNum"
$SuccessBox.UseVisualStyleBackColor = $True

$panel1.Controls.Add($SuccessBox)


$RunOnLbl.DataBindings.DefaultDataSourceUpdateMode = 0

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 12
$System_Drawing_Point.Y = 75
$RunOnLbl.Location = $System_Drawing_Point
$RunOnLbl.Name = "RunOnLbl"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 23
$System_Drawing_Size.Width = 438
$RunOnLbl.Size = $System_Drawing_Size
$RunOnLbl.TabIndex = 3
$RunOnLbl.Text = "Run tool on devices with these statuses:"
$RunOnLbl.TextAlign = 16

$form1.Controls.Add($RunOnLbl)

$ToolLbl.DataBindings.DefaultDataSourceUpdateMode = 0

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 12
$System_Drawing_Point.Y = 42
$ToolLbl.Location = $System_Drawing_Point
$ToolLbl.Name = "ToolLbl"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 23
$System_Drawing_Size.Width = 438
$ToolLbl.Size = $System_Drawing_Size
$ToolLbl.TabIndex = 1
$ToolLbl.Text = "Tool: $Tool"
$ToolLbl.TextAlign = 32

$form1.Controls.Add($ToolLbl)

$DeploymentLbl.DataBindings.DefaultDataSourceUpdateMode = 0

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 12
$System_Drawing_Point.Y = 9
$DeploymentLbl.Location = $System_Drawing_Point
$DeploymentLbl.Name = "DeploymentLbl"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 23
$System_Drawing_Size.Width = 438
$DeploymentLbl.Size = $System_Drawing_Size
$DeploymentLbl.TabIndex = 0
$DeploymentLbl.Text = "Deployment: $DeploymentName"
$DeploymentLbl.TextAlign = 32

$form1.Controls.Add($DeploymentLbl)

#endregion Generated Form Code

#Save the initial state of the form
$InitialFormWindowState = $form1.WindowState
#Init the OnLoad event to correct the initial state of the form
$form1.add_Load($OnLoadForm_StateCorrection)
#Show the Form
$form1.ShowDialog()| Out-Null

} #End Function

#Call the Function
GenerateForm
