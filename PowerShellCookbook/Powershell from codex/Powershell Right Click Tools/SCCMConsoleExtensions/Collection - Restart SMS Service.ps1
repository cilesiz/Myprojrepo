﻿<#
Written by Ryan Ephgrave for ConfigMgr 2012 Right Click Tools
http://psrightclicktools.codeplex.com/
GUI Generated By: SAPIEN Technologies PrimalForms (Community Edition) v1.0.10.0
#>

$ColID = $args[0]
$ColName = $args[1]
$ColMemberCount = $args[2]
$Server = $args[3]
$Namespace = $args[4]
$script:CancelAction = $false

$FormName = "Restart SMS Agent Host Service - $ColName"
$strActionLbl = "Restart SMS Agent Host Service"
$Popup = new-object -comobject wscript.shell
$GetDirectory = $MyInvocation.MyCommand.path
$Directory = Split-Path $GetDirectory

function GenerateForm {

<#
Variables:

$Colname - Collection name for the ColNameLbl
$StrActionLbl - Action name for the ActionNameLbl
$NumSuccess - Number of successful actions
$NumUnsuccess - Number of unsuccessful actions
$SuccessView - Datagridview of successful actions
$UnsuccessView - Datagridview of unsuccessful actions
$LogBox - Richtextbox for logs
$CloseCancel - What the close/cancel button will show

#>

#region Import the Assemblies
[reflection.assembly]::loadwithpartialname("System.Drawing") | Out-Null
[reflection.assembly]::loadwithpartialname("System.Windows.Forms") | Out-Null
#endregion

#region Generated Form Objects
$ResultsForm = New-Object System.Windows.Forms.Form
$ReRunBtn = New-Object System.Windows.Forms.Button
$LogBox = New-Object System.Windows.Forms.RichTextBox
$UnsuccessLbl = New-Object System.Windows.Forms.Label
$UnsuccessView = New-Object System.Windows.Forms.DataGridView
$CloseCancelBtn = New-Object System.Windows.Forms.Button
$AboutBtn = New-Object System.Windows.Forms.Button
$SuccessView = New-Object System.Windows.Forms.DataGridView
$SuccessLbl = New-Object System.Windows.Forms.Label
$ActionNameLbl = New-Object System.Windows.Forms.Label
$ColNameLbl = New-Object System.Windows.Forms.Label
$InitialFormWindowState = New-Object System.Windows.Forms.FormWindowState
#endregion Generated Form Objects

$ReRunBtn_OnClick= 
{
	$ArgList = @()
	$ArgList += @("`"$Directory\SilentOpenPS.vbs`"")
	$ArgList += @("`"$Directory\Collection - Restart SMS Service.ps1`"")
	$ArgList += @("`"$ColID`"")
	$ArgList += @("`"$ColName`"")
	$ArgList += @("`"$ColMemberCount`"")
	$ArgList += @("`"$Server`"")
	$ArgList += @("`"$Namespace`"")
	Start-Process wscript.exe -ArgumentList $ArgList
}

$AboutBtn_OnClick= 
{
	$ArgList = @()
	$ArgList += @("`"$Directory\SilentOpenPS.vbs`"")
	$ArgList += @("`"$Directory\About.ps1`"")
	Start-Process wscript.exe -ArgumentList $ArgList
}

$CloseCancelBtn_OnClick= 
{
	$CloseCancelText = $CloseCancelBtn.Text
	if ($CloseCancelText -eq "Close") {
		$ResultsForm.close()
	}
	else {
		$script:CancelAction = $true
		$CurrTime = Get-Date
		$CurrentTime = $CurrTime.ToLongTimeString()
		$LogBox.Text = $LogBox.Text + "$CurrentTime - Action cancelled"
		$LogScrollTo = $LogBox.Text.Length - 250
		$LogBox.Select($LogScrollTo,0)
		$LogBox.ScrollToCaret()
	}
}

$OnClose=
{
	$ProcessID = [System.Diagnostics.Process]::GetCurrentProcess()
	$ProcID = $ProcessID.ID
	& taskkill /PID $ProcID /T /F
}

$ResizeEnd=
{
	<#
	$FormWidth = $ResultsForm.Size.Width
	$DataGridWidth = $FormWidth - 70
	$DataGridWidth = $DataGridWidth / 2
	$System_Drawing_Size.Height = $UnsuccessView.Size.Height
	$System_Drawing_Size.Width = $DataGridWidth
	$UnsuccessView.Size = $System_Drawing_Size
	$SuccessView.Size = $System_Drawing_Size
	$System_Drawing_Point.X = 12
	$System_Drawing_Point.Y = 81
	$SuccessView.Location = $System_Drawing_Point
	$System_Drawing_Size.Height = 23
	$System_Drawing_Size.Width = $DataGridWidth
	$UnsuccessLbl.Size = $System_Drawing_Size
	$SuccessLbl.Size = $System_Drawing_Size
	$System_Drawing_Point.X = 12
	$System_Drawing_Point.Y = 55
	$SuccessLbl.Location = $System_Drawing_Point
	#>
}

$OnLoadForm_StateCorrection=
{
	$ResultsForm.WindowState = $InitialFormWindowState
	$System_Windows_Forms_DataGridViewTextBoxColumn_1 = New-Object System.Windows.Forms.DataGridViewTextBoxColumn
	$System_Windows_Forms_DataGridViewTextBoxColumn_1.AutoSizeMode = 6
	$System_Windows_Forms_DataGridViewTextBoxColumn_1.HeaderText = "Device Name"
	$System_Windows_Forms_DataGridViewTextBoxColumn_1.Name = ""
	$System_Windows_Forms_DataGridViewTextBoxColumn_1.ReadOnly = $True
	$SuccessView.Columns.Add($System_Windows_Forms_DataGridViewTextBoxColumn_1)|Out-Null
	$System_Windows_Forms_DataGridViewTextBoxColumn_6 = New-Object System.Windows.Forms.DataGridViewTextBoxColumn
	$System_Windows_Forms_DataGridViewTextBoxColumn_6.AutoSizeMode = 6
	$System_Windows_Forms_DataGridViewTextBoxColumn_6.HeaderText = "Device Name"
	$System_Windows_Forms_DataGridViewTextBoxColumn_6.Name = ""
	$System_Windows_Forms_DataGridViewTextBoxColumn_6.ReadOnly = $True
	$UnSuccessView.Columns.Add($System_Windows_Forms_DataGridViewTextBoxColumn_6)|Out-Null
	$System_Windows_Forms_DataGridViewTextBoxColumn_7 = New-Object System.Windows.Forms.DataGridViewTextBoxColumn
	$System_Windows_Forms_DataGridViewTextBoxColumn_7.AutoSizeMode = 6
	$System_Windows_Forms_DataGridViewTextBoxColumn_7.HeaderText = "Off/Error"
	$System_Windows_Forms_DataGridViewTextBoxColumn_7.Name = ""
	$System_Windows_Forms_DataGridViewTextBoxColumn_7.ReadOnly = $True
	$UnSuccessView.Columns.Add($System_Windows_Forms_DataGridViewTextBoxColumn_7)|Out-Null
	$System_Windows_Forms_DataGridViewTextBoxColumn_8 = New-Object System.Windows.Forms.DataGridViewTextBoxColumn
	$System_Windows_Forms_DataGridViewTextBoxColumn_8.AutoSizeMode = 6
	$System_Windows_Forms_DataGridViewTextBoxColumn_8.HeaderText = "Error Message"
	$System_Windows_Forms_DataGridViewTextBoxColumn_8.Name = ""
	$System_Windows_Forms_DataGridViewTextBoxColumn_8.ReadOnly = $True
	$UnSuccessView.Columns.Add($System_Windows_Forms_DataGridViewTextBoxColumn_8)|Out-Null
	$script:CancelAction = $false
	$CloseCancelBtn.Text = "Cancel"
	$ReRunBtn.Enabled = $false
	$NumSuccess = 0
	$NumUnsuccess = 0
	$count = 0
	$MaxJobs = 20
	$JobTimer = @{}
	$strQuery = "select * from SMS_CM_RES_COLL_$ColID as Col inner join SMS_R_System on Col.ResourceID = SMS_R_System.ResourceID"
	Get-WmiObject -Query $strQuery -Namespace $Namespace -ComputerName $Server | ForEach-Object {
		[System.Windows.Forms.Application]::DoEvents()
		if ($script:CancelAction -eq $false){
			$CompName = $_.SMS_R_System.ResourceNames[0]
			$CurrTime = Get-Date
			$JobName = "RestartService_" + $CompName
			$JobTimer.add("$CompName",$CurrTime)
			$CurrentTime = $CurrTime.ToLongTimeString()
			$LogText = "$CurrentTime - Restarting service on $CompName"
			$LogText = $LogText.replace("`n","")
			$LogBox.Text = $LogBox.Text + $LogText + "`n"
			$LogScrollTo = $LogBox.Text.Length - 250
			$LogBox.Select($LogScrollTo,0)
			$LogBox.ScrollToCaret()
			Start-Job -Name $JobName -ArgumentList $CompName -ScriptBlock {
				$CompName = $null
				$CompName = $args[0]
				If (test-connection -computername $CompName -count 1 -quiet){
					$Error.Clear()
					$CcmExecService = Get-Service -ComputerName $CompName -Name "CcmExec"
					Restart-Service -InputObject $CcmExecService
					if ($Error[0]) {$strOutput = "$CompName" + "||Error|| " + $Error}
					else {$strOutput = "$CompName" + "||Successful"}
				}
				else {$strOutput = "$CompName" + "||Off"}
				Write-Output $strOutput
			} | Out-Null
			Receive-Job -Name "RestartService_*" | ForEach-Object {
				[System.Windows.Forms.Application]::DoEvents()
				$count++
				$strOutput = $_
				$strOutput = $strOutput | Out-String
				$CurrTime = Get-Date
				$CurrentTime = $CurrTime.ToLongTimeString()
				if ($strOutput.contains("||Off")){
					$NumUnsuccess++
					$OutputArray = $strOutput.Split("||")
					$LogBox.Text = $LogBox.Text + "$CurrentTime - Can't ping " + $OutputArray[0] + "`n"
					$UnsuccessView.Rows.Add($OutputArray[0],"Off")
					$UnsuccessLbl.Text = "$NumUnsuccess Unsuccessful"
				}
				elseif ($strOutput.contains("||Error")){
					$NumUnsuccess++
					$OutputArray = $strOutput.Split("||")
					$LogBox.Text = $LogBox.Text + "$CurrentTime - Error on " + $OutputArray[0] + "`n"
					$UnsuccessView.Rows.Add($OutputArray[0],"Error",$OutputArray[4])
					$UnsuccessLbl.Text = "$NumUnsuccess Unsuccessful"
				}
				else {
					$OutputArray = $strOutput.Split("||")
					$SuccessView.Rows.Add($OutputArray[0])
					$LogBox.Text = $LogBox.Text + "$CurrentTime - Successfully restarted service on " + $OutputArray[0] + "`n"
					$Numsuccess++
					$SuccessLbl.Text = "$NumSuccess Successful"
				}
				$LogScrollTo = $LogBox.Text.Length - 250
				$LogBox.Select($LogScrollTo,0)
				$LogBox.ScrollToCaret()
			}
			do {
				[System.Windows.Forms.Application]::DoEvents()
				$RunningJobs = 0
				$IgnoredJobs = 0
				get-job | where-object {$_.Name -like "RestartService_*" -and $_.State -eq "Running"} | ForEach-Object {
					[System.Windows.Forms.Application]::DoEvents()
					$JobID = $_.ID
					if ($SkippedJobs -inotcontains "$JobID") {
						$RunningJobs++
						$CurrTime = Get-Date
						$CurrentTime = $CurrTime.ToLongTimeString()
						$JobCompName = $_.Name
						$JobCompName = $JobCompName.replace("RestartService_","")
						$StartTime = $JobTimer["$JobCompName"]
						$CompareTime = $CurrTime - $StartTime
						if ($CompareTime.Minutes -gt 2 -and $IgnoredJobs -eq 0){
							$SkippedJobs += @("$JobID")
							$IgnoredJobs++
							$LogBox.Text = $LogBox.Text + "$CurrentTime - $JobCompName timed out...`n"
							$LogScrollTo = $LogBox.Text.Length - 250
							$LogBox.Select($LogScrollTo,0)
							$LogBox.ScrollToCaret()
							$UnsuccessView.Rows.Add("$JobCompName","Timed out after 2 minutes","Possible WMI problems")
							$NumUnsuccess++
							$UnsuccessLbl.Text = "$NumUnsuccess Unsuccessful"
						}
					}
				}
				if ($RunningJobs -gt $MaxJobs) {
					[System.Windows.Forms.Application]::DoEvents()
					Start-Sleep 1
					$LogBox.Text = $LogBox.Text + "$CurrentTime - Can only run $MaxJobs jobs at once, waiting on some to finish before continuing...`n"
					$LogScrollTo = $LogBox.Text.Length - 250
					$LogBox.Select($LogScrollTo,0)
					$LogBox.ScrollToCaret()
				}
			} while ($RunningJobs -gt $MaxJobs -and $script:CancelAction -ne $true)
		}
	}
	do {
		[System.Windows.Forms.Application]::DoEvents()
		$RunningJobs = 0
		$IgnoredJobs = 0
		get-job | where-object {$_.Name -like "RestartService_*" -and $_.State -eq "Running"} | ForEach-Object {
			[System.Windows.Forms.Application]::DoEvents()
			$JobID = $_.ID
			if ($SkippedJobs -inotcontains "$JobID") {
				$RunningJobs++
				$CurrTime = Get-Date
				$CurrentTime = $CurrTime.ToLongTimeString()
				$JobCompName = $_.Name
				$JobCompName = $JobCompName.replace("RestartService_","")
				$StartTime = $JobTimer["$JobCompName"]
				$CompareTime = $CurrTime - $StartTime
				if ($CompareTime.Minutes -gt 2 -and $IgnoredJobs -eq 0){
					$SkippedJobs += @($_.ID)
					$IgnoredJobs++
					$LogBox.Text = $LogBox.Text + "$CurrentTime - $JobCompName timed out...`n"
					$LogScrollTo = $LogBox.Text.Length - 250
					$LogBox.Select($LogScrollTo,0)
					$LogBox.ScrollToCaret()
					$UnsuccessView.Rows.Add("$JobCompName","Timed out after 2 minutes","Possible WMI problems")
					$NumUnsuccess++
					$UnsuccessLbl.Text = "$NumUnsuccess Unsuccessful"
				}
			}
		}
		if ($RunningJobs -gt 0) {
			[System.Windows.Forms.Application]::DoEvents()
			Start-Sleep 1
			$LogBox.Text = $LogBox.Text + "$CurrentTime - Waiting on $RunningJobs jobs to complete still. It will time out after 2 minutes if it is still running...`n"
			$LogScrollTo = $LogBox.Text.Length - 250
			$LogBox.Select($LogScrollTo,0)
			$LogBox.ScrollToCaret()
		}
	} while ($RunningJobs -gt 0 -and $script:CancelAction -ne $true)
	Receive-Job -Name "RestartService_*" | ForEach-Object {
		[System.Windows.Forms.Application]::DoEvents()
		$count++
		$strOutput = $_
		$strOutput = $strOutput | Out-String
		$CurrTime = Get-Date
		$CurrentTime = $CurrTime.ToLongTimeString()
		if ($strOutput.contains("||Off")){
			$NumUnsuccess++
			$OutputArray = $strOutput.Split("||")
			$LogBox.Text = $LogBox.Text + "$CurrentTime - Can't ping " + $OutputArray[0] + "`n"
			$UnsuccessView.Rows.Add($OutputArray[0],"Off")
			$UnsuccessLbl.Text = "$NumUnsuccess Unsuccessful"
		}
		elseif ($strOutput.contains("||Error")){
			$NumUnsuccess++
			$OutputArray = $strOutput.Split("||")
			$LogBox.Text = $LogBox.Text + "$CurrentTime - Error on " + $OutputArray[0] + "`n"
			$UnsuccessView.Rows.Add($OutputArray[0],"Error",$OutputArray[4])
			$UnsuccessLbl.Text = "$NumUnsuccess Unsuccessful"
		}
		else {
			$OutputArray = $strOutput.Split("||")
			$SuccessView.Rows.Add($OutputArray[0])
			$LogBox.Text = $LogBox.Text + "$CurrentTime - Successfully restarted service on " + $OutputArray[0] + "`n"
			$Numsuccess++
			$SuccessLbl.Text = "$NumSuccess Successful"
		}
		$LogScrollTo = $LogBox.Text.Length - 250
		$LogBox.Select($LogScrollTo,0)
		$LogBox.ScrollToCaret()
	}
	$SuccessLbl.Text = "$NumSuccess Successful"
	$FailLbl.Text = "$NumUnsuccess Unsuccessful"		
	$ReRunBtn.Enabled = $true
	$CloseCancelBtn.Text = "Close"
	$CurrTime = Get-Date
	$CurrentTime = $CurrTime.ToLongTimeString()
	$LogBox.Text = $LogBox.Text + "$CurrentTime - Finished!`n"
}

#region Generated Form Code
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 555
$System_Drawing_Size.Width = 532
$ResultsForm.ClientSize = $System_Drawing_Size
$ResultsForm.DataBindings.DefaultDataSourceUpdateMode = 0
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 600
$System_Drawing_Size.Width = 550
$ResultsForm.MinimumSize = $System_Drawing_Size
$ResultsForm.Name = "ResultsForm"
$ResultsForm.Text = "$FormName"

$ReRunBtn.Anchor = 10

$ReRunBtn.DataBindings.DefaultDataSourceUpdateMode = 0

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 361
$System_Drawing_Point.Y = 520
$ReRunBtn.Location = $System_Drawing_Point
$ReRunBtn.Name = "ReRunBtn"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 23
$System_Drawing_Size.Width = 75
$ReRunBtn.Size = $System_Drawing_Size
$ReRunBtn.TabIndex = 9
$ReRunBtn.Text = "Rerun"
$ReRunBtn.UseVisualStyleBackColor = $True
$ReRunBtn.add_Click($ReRunBtn_OnClick)

$ResultsForm.Controls.Add($ReRunBtn)

$LogBox.Anchor = 14
$LogBox.DataBindings.DefaultDataSourceUpdateMode = 0
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 12
$System_Drawing_Point.Y = 418
$LogBox.Location = $System_Drawing_Point
$LogBox.Name = "LogBox"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 96
$System_Drawing_Size.Width = 505
$LogBox.Size = $System_Drawing_Size
$LogBox.TabIndex = 8
$LogBox.WordWrap = $False
$LogBox.Text = ""

$ResultsForm.Controls.Add($LogBox)

$UnsuccessLbl.Anchor = 13
$UnsuccessLbl.DataBindings.DefaultDataSourceUpdateMode = 0

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 188
$System_Drawing_Point.Y = 55
$UnsuccessLbl.Location = $System_Drawing_Point
$UnsuccessLbl.Name = "UnsuccessLbl"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 23
$System_Drawing_Size.Width = 330
$UnsuccessLbl.Size = $System_Drawing_Size
$UnsuccessLbl.TabIndex = 7
$UnsuccessLbl.Text = "$NumUnSuccess Unsuccessful"
$UnsuccessLbl.TextAlign = 32

$ResultsForm.Controls.Add($UnsuccessLbl)

$UnsuccessView.AllowUserToAddRows = $False
$UnsuccessView.AllowUserToDeleteRows = $False
$UnsuccessView.AllowUserToResizeRows = $False
$UnsuccessView.Anchor = 15
$UnsuccessView.ClipboardCopyMode = 2
$UnsuccessView.ColumnHeadersHeightSizeMode = 1
$UnsuccessView.DataBindings.DefaultDataSourceUpdateMode = 0
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 188
$System_Drawing_Point.Y = 81
$UnsuccessView.Location = $System_Drawing_Point
$UnsuccessView.Name = "UnsuccessView"
$UnsuccessView.ReadOnly = $True
$UnsuccessView.RowHeadersVisible = $False
$UnsuccessView.RowHeadersWidthSizeMode = 1
$UnsuccessView.RowTemplate.Height = 24
$UnsuccessView.SelectionMode = 0
$UnsuccessView.ShowCellErrors = $False
$UnsuccessView.ShowRowErrors = $False
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 331
$System_Drawing_Size.Width = 330
$UnsuccessView.Size = $System_Drawing_Size
$UnsuccessView.TabIndex = 6
$UnsuccessView.add_SelectionChanged($ViewSelection_Changed)

$ResultsForm.Controls.Add($UnsuccessView)

$CloseCancelBtn.Anchor = 10

$CloseCancelBtn.DataBindings.DefaultDataSourceUpdateMode = 0

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 442
$System_Drawing_Point.Y = 520
$CloseCancelBtn.Location = $System_Drawing_Point
$CloseCancelBtn.Name = "CloseCancelBtn"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 23
$System_Drawing_Size.Width = 75
$CloseCancelBtn.Size = $System_Drawing_Size
$CloseCancelBtn.TabIndex = 5
$CloseCancelBtn.Text = "$CloseCancel"
$CloseCancelBtn.UseVisualStyleBackColor = $True
$CloseCancelBtn.add_Click($CloseCancelBtn_OnClick)

$ResultsForm.Controls.Add($CloseCancelBtn)

$AboutBtn.Anchor = 6

$AboutBtn.DataBindings.DefaultDataSourceUpdateMode = 0

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 12
$System_Drawing_Point.Y = 520
$AboutBtn.Location = $System_Drawing_Point
$AboutBtn.Name = "AboutBtn"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 23
$System_Drawing_Size.Width = 75
$AboutBtn.Size = $System_Drawing_Size
$AboutBtn.TabIndex = 4
$AboutBtn.Text = "About"
$AboutBtn.UseVisualStyleBackColor = $True
$AboutBtn.add_Click($AboutBtn_OnClick)

$ResultsForm.Controls.Add($AboutBtn)

$SuccessView.AllowUserToAddRows = $False
$SuccessView.AllowUserToDeleteRows = $False
$SuccessView.AllowUserToResizeRows = $False
$SuccessView.Anchor = 7
$SuccessView.ClipboardCopyMode = 2
$SuccessView.ColumnHeadersHeightSizeMode = 1
$SuccessView.DataBindings.DefaultDataSourceUpdateMode = 0
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 12
$System_Drawing_Point.Y = 81
$SuccessView.Location = $System_Drawing_Point
$SuccessView.Name = "SuccessView"
$SuccessView.ReadOnly = $True
$SuccessView.RowHeadersVisible = $False
$SuccessView.RowHeadersWidthSizeMode = 1
$SuccessView.RowTemplate.Height = 24
$SuccessView.SelectionMode = 0
$SuccessView.ShowCellErrors = $False
$SuccessView.ShowRowErrors = $False
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 331
$System_Drawing_Size.Width = 160
$SuccessView.Size = $System_Drawing_Size
$SuccessView.TabIndex = 3
$SuccessView.add_SelectionChanged($ViewSelection_Changed)

$ResultsForm.Controls.Add($SuccessView)

$SuccessLbl.DataBindings.DefaultDataSourceUpdateMode = 0

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 12
$System_Drawing_Point.Y = 55
$SuccessLbl.Location = $System_Drawing_Point
$SuccessLbl.Name = "SuccessLbl"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 23
$System_Drawing_Size.Width = 150
$SuccessLbl.Size = $System_Drawing_Size
$SuccessLbl.TabIndex = 2
$SuccessLbl.Text = "$NumSuccess Successful"
$SuccessLbl.TextAlign = 32

$ResultsForm.Controls.Add($SuccessLbl)

$ActionNameLbl.Anchor = 13
$ActionNameLbl.DataBindings.DefaultDataSourceUpdateMode = 0

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 12
$System_Drawing_Point.Y = 32
$ActionNameLbl.Location = $System_Drawing_Point
$ActionNameLbl.Name = "ActionNameLbl"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 23
$System_Drawing_Size.Width = 505
$ActionNameLbl.Size = $System_Drawing_Size
$ActionNameLbl.TabIndex = 1
$ActionNameLbl.Text = "$strActionLbl"
$ActionNameLbl.TextAlign = 32

$ResultsForm.Controls.Add($ActionNameLbl)

$ColNameLbl.Anchor = 13
$ColNameLbl.DataBindings.DefaultDataSourceUpdateMode = 0

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 12
$System_Drawing_Point.Y = 9
$ColNameLbl.Location = $System_Drawing_Point
$ColNameLbl.Name = "ColNameLbl"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 23
$System_Drawing_Size.Width = 505
$ColNameLbl.Size = $System_Drawing_Size
$ColNameLbl.TabIndex = 0
$ColNameLbl.Text = "$ColName"
$ColNameLbl.TextAlign = 32

$ResultsForm.Controls.Add($ColNameLbl)

#endregion Generated Form Code

$InitialFormWindowState = $ResultsForm.WindowState

$ResultsForm.add_Load($OnLoadForm_StateCorrection)
$ResultsForm.add_SizeChanged($ResizeEnd)
$ResultsForm.add_Closing($OnClose)

$ResultsForm.ShowDialog()| Out-Null

}
$Answer = $Popup.Popup("Are you sure you want to restart the SMS agent host service on $ColName",0,"Are you sure?",1)
if ($Answer -eq 1) {GenerateForm}