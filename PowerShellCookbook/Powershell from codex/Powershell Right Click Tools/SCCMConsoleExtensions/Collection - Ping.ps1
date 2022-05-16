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

$FormName = "Pinging $ColName"
$strAction = "Pinging Collection"
$script:CancelAction = $false
$Popup = new-object -comobject wscript.shell

$GetDirectory = $MyInvocation.MyCommand.path
$Directory = Split-Path $GetDirectory

function GenerateForm {

<#
Variables:

$Colname - Collection name for the ColNameLbl
$StrAction - Action name for the ActionNameLbl
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
$SuccesscontextMenuStrip = New-Object System.Windows.Forms.ContextMenuStrip
$UnSuccesscontextMenuStrip = New-Object System.Windows.Forms.ContextMenuStrip
#endregion Generated Form Objects

$ReRunBtn_OnClick= 
{
	$ArgList = @()
	$ArgList += @("`"$Directory\SilentOpenPS.vbs`"")
	$ArgList += @("`"$Directory\Collection - Ping.ps1`"")
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

$RestartDevices_Menu1=
{
	$SelectedCellsCount = 0
	$CompListArray = $null
	$SuccessView.SelectedCells | ForEach-Object {
		if ($_.ColumnIndex -eq 0) {
			$SelectedCellsCount++
			$CompListArray += @($_.Value)
		}
	}
	$PopupAnswer = $Popup.Popup("Do you want to restart $SelectedCellsCount devices?",0,"Are you sure?",1)
	if ($PopupAnswer -eq 1){
		$JobName = "SysInfo_" + $strColID
		Foreach ($CompName in $CompListArray) {
			[System.Windows.Forms.Application]::DoEvents()
			if ($script:CancelAction -eq $false){
				$CurrTime = Get-Date
				$CurrentTime = $CurrTime.ToLongTimeString()
				$LogText = "$CurrentTime - Starting restart of $CompName"
				$LogText = $LogText.replace("`n","")
				$LogBox.Text = $LogBox.Text + $LogText + "`n"
				$LogScrollTo = $LogBox.Text.Length - 250
				$LogBox.Select($LogScrollTo,0)
				$LogBox.ScrollToCaret()
				Start-Job -Name $JobName -ArgumentList $CompName -ScriptBlock {
					$CompName = $args
					if (Test-connection -computername $CompName -count 1) {
						& shutdown.exe /r /f /t 00 /d p:0:0 /m $CompName
						$strOutput = "$CompName ||On"
					}
					else {
						$strOutput = "$CompName ||Off"
					}
					Write-Output $strOutput
				}
				Receive-Job -Name $JobName | ForEach-Object {
					$strOutput = $_
					$strOutput = $strOutput | Out-String
					$OutputArray = $strOutput.Split("||")
					$CurrTime = Get-Date
					$CurrentTime = $CurrTime.ToLongTimeString()
					if ($strOutput.contains("||Off")){
						$OutputArray = $strOutput.Split("||")
						$LogBox.Text = $LogBox.Text + "$CurrentTime - Error pinging" + $OutputArray[0] + "`n"
					}
					elseif ($strOutput.contains("||On")){
						$LogBox.Text = $LogBox.Text + "$CurrentTime - Sent restart command to " + $OutputArray[0] + "`n"
					}
					$LogScrollTo = $LogBox.Text.Length - 250
					$LogBox.Select($LogScrollTo,0)
					$LogBox.ScrollToCaret()
				}
				while (((get-job | where-object { $_.Name -like "$JobName" -and $_.State -eq "Running" }) | measure).Count -gt 20 -and $script:CancelAction -eq $false){
					[System.Windows.Forms.Application]::DoEvents()
					if ($script:CancelAction -eq $true){}
					else {
						$CurrTime = Get-Date
						$CurrentTime = $CurrTime.ToLongTimeString()
						$LogBox.Text = $LogBox.Text + "$CurrentTime - Can only run 20 jobs at once, waiting on some to finish before continuing...`n"
						Start-Sleep -Seconds 1
						$LogScrollTo = $LogBox.Text.Length - 250
						$LogBox.Select($LogScrollTo,0)
						$LogBox.ScrollToCaret()
					}
				}
			}
		}
		while (((get-job | where-object { $_.Name -like "$JobName" -and $_.State -eq "Running" }) | measure).Count -gt 0 -and $script:CancelAction -eq $false){
			[System.Windows.Forms.Application]::DoEvents()
			if ($script:CancelAction -eq $true){}
			else {
				$CurrTime = Get-Date
				$CurrentTime = $CurrTime.ToLongTimeString()
				$LogBox.Text = $LogBox.Text + "$CurrentTime - Waiting on the last few jobs to finish...`n"
				Start-Sleep -Seconds 1
				$LogScrollTo = $LogBox.Text.Length - 250
				$LogBox.Select($LogScrollTo,0)
				$LogBox.ScrollToCaret()
			}
		}
		Receive-Job -Name $JobName | ForEach-Object {
			$strOutput = $_
			$strOutput = $strOutput | Out-String
			$OutputArray = $strOutput.Split("||")
			$CurrTime = Get-Date
			$CurrentTime = $CurrTime.ToLongTimeString()
			if ($strOutput.contains("||Off")){
				$OutputArray = $strOutput.Split("||")
				$LogBox.Text = $LogBox.Text + "$CurrentTime - Error pinging" + $OutputArray[0] + "`n"
			}
			elseif ($strOutput.contains("||On")){
				$LogBox.Text = $LogBox.Text + "$CurrentTime - Sent restart command to " + $OutputArray[0] + "`n"
			}
			$LogScrollTo = $LogBox.Text.Length - 250
			$LogBox.Select($LogScrollTo,0)
			$LogBox.ScrollToCaret()
		}
		$CurrTime = Get-Date
		$CurrentTime = $CurrTime.ToLongTimeString()
		$LogBox.Text = $LogBox.Text + "$CurrentTime - Finished restarting selected devices!`n"
		$LogScrollTo = $LogBox.Text.Length - 250
		$LogBox.Select($LogScrollTo,0)
		$LogBox.ScrollToCaret()
	}
	else {
		$CurrTime = Get-Date
		$CurrentTime = $CurrTime.ToLongTimeString()
		$LogBox.Text = $LogBox.Text + "$CurrentTime - User cancelled restart`n"
		$LogScrollTo = $LogBox.Text.Length - 250
		$LogBox.Select($LogScrollTo,0)
		$LogBox.ScrollToCaret()
	}
}

$ShutdownDevices_Menu1=
{
	$SelectedCellsCount = 0
	$CompListArray = $null
	$SuccessView.SelectedCells | ForEach-Object {
		if ($_.ColumnIndex -eq 0) {
			$SelectedCellsCount++
			$CompListArray += @($_.Value)
		}
	}
	$PopupAnswer = $Popup.Popup("Do you want to shutdown $SelectedCellsCount devices?",0,"Are you sure?",1)
	if ($PopupAnswer -eq 1){
		$JobName = "SysInfo_" + $strColID
		Foreach ($CompName in $CompListArray) {
			[System.Windows.Forms.Application]::DoEvents()
			if ($script:CancelAction -eq $false){
				$CurrTime = Get-Date
				$CurrentTime = $CurrTime.ToLongTimeString()
				$LogText = "$CurrentTime - Starting shutdown of $CompName"
				$LogText = $LogText.replace("`n","")
				$LogBox.Text = $LogBox.Text + $LogText + "`n"
				$LogScrollTo = $LogBox.Text.Length - 250
				$LogBox.Select($LogScrollTo,0)
				$LogBox.ScrollToCaret()
				Start-Job -Name $JobName -ArgumentList $CompName -ScriptBlock {
					$CompName = $args
					if (Test-connection -computername $CompName -count 1) {
						& shutdown.exe /s /f /t 00 /d p:0:0 /m $CompName
						$strOutput = "$CompName ||On"
					}
					else {
						$strOutput = "$CompName ||Off"
					}
					Write-Output $strOutput
				}
				Receive-Job -Name $JobName | ForEach-Object {
					$strOutput = $_
					$strOutput = $strOutput | Out-String
					$OutputArray = $strOutput.Split("||")
					$CurrTime = Get-Date
					$CurrentTime = $CurrTime.ToLongTimeString()
					if ($strOutput.contains("||Off")){
						$OutputArray = $strOutput.Split("||")
						$LogBox.Text = $LogBox.Text + "$CurrentTime - Error pinging" + $OutputArray[0] + "`n"
					}
					elseif ($strOutput.contains("||On")){
						$LogBox.Text = $LogBox.Text + "$CurrentTime - Sent shutdown command to " + $OutputArray[0] + "`n"
					}
					$LogScrollTo = $LogBox.Text.Length - 250
					$LogBox.Select($LogScrollTo,0)
					$LogBox.ScrollToCaret()
				}
				while (((get-job | where-object { $_.Name -like "$JobName" -and $_.State -eq "Running" }) | measure).Count -gt 20 -and $script:CancelAction -eq $false){
					[System.Windows.Forms.Application]::DoEvents()
					if ($script:CancelAction -eq $true){}
					else {
						$CurrTime = Get-Date
						$CurrentTime = $CurrTime.ToLongTimeString()
						$LogBox.Text = $LogBox.Text + "$CurrentTime - Can only run 20 jobs at once, waiting on some to finish before continuing...`n"
						Start-Sleep -Seconds 1
						$LogScrollTo = $LogBox.Text.Length - 250
						$LogBox.Select($LogScrollTo,0)
						$LogBox.ScrollToCaret()
					}
				}
			}
		}
		while (((get-job | where-object { $_.Name -like "$JobName" -and $_.State -eq "Running" }) | measure).Count -gt 0 -and $script:CancelAction -eq $false){
			[System.Windows.Forms.Application]::DoEvents()
			if ($script:CancelAction -eq $true){}
			else {
				$CurrTime = Get-Date
				$CurrentTime = $CurrTime.ToLongTimeString()
				$LogBox.Text = $LogBox.Text + "$CurrentTime - Waiting on the last few jobs to finish...`n"
				Start-Sleep -Seconds 1
				$LogScrollTo = $LogBox.Text.Length - 250
				$LogBox.Select($LogScrollTo,0)
				$LogBox.ScrollToCaret()
			}
		}
		Receive-Job -Name $JobName | ForEach-Object {
			$strOutput = $_
			$strOutput = $strOutput | Out-String
			$OutputArray = $strOutput.Split("||")
			$CurrTime = Get-Date
			$CurrentTime = $CurrTime.ToLongTimeString()
			if ($strOutput.contains("||Off")){
				$OutputArray = $strOutput.Split("||")
				$LogBox.Text = $LogBox.Text + "$CurrentTime - Error pinging" + $OutputArray[0] + "`n"
			}
			elseif ($strOutput.contains("||On")){
				$LogBox.Text = $LogBox.Text + "$CurrentTime - Sent shutdown command to " + $OutputArray[0] + "`n"
			}
			$LogScrollTo = $LogBox.Text.Length - 250
			$LogBox.Select($LogScrollTo,0)
			$LogBox.ScrollToCaret()
		}
		$CurrTime = Get-Date
		$CurrentTime = $CurrTime.ToLongTimeString()
		$LogBox.Text = $LogBox.Text + "$CurrentTime - Finished shutting down selected devices!`n"
		$LogScrollTo = $LogBox.Text.Length - 250
		$LogBox.Select($LogScrollTo,0)
		$LogBox.ScrollToCaret()
	}
	else {
		$CurrTime = Get-Date
		$CurrentTime = $CurrTime.ToLongTimeString()
		$LogBox.Text = $LogBox.Text + "$CurrentTime - User cancelled shutdown`n"
		$LogScrollTo = $LogBox.Text.Length - 250
		$LogBox.Select($LogScrollTo,0)
		$LogBox.ScrollToCaret()
	}
}

$WOLDevices_Menu2=
{
	$wolpath = "$Directory\wolcmd.exe"
	$SelectedCellsCount = 0
	$CompListArray = $null
	$UnsuccessView.SelectedCells | ForEach-Object {
		if ($_.ColumnIndex -eq 0) {
			$SelectedCellsCount++
			$CompListArray += @($_.Value)
		}
	}
	$PopupAnswer = $Popup.Popup("Do you want to wake up $SelectedCellsCount devices?",0,"Are you sure?",1)
	if ($PopupAnswer -eq 1){
		Foreach ($CompName in $CompListArray) {
			$SentPacket = $false
			$CompName = $CompName.replace("`n","")
			$CompName = $CompName.replace("`t","")
			$strQuery = "Select * from SMS_G_System_NETWORK_ADAPTER_CONFIGURATION inner join SMS_R_System on SMS_R_System.ResourceID = SMS_G_System_NETWORK_ADAPTER_CONFIGURATION.ResourceID where SMS_R_System.ResourceNames[0] like '" + $CompName + "'"
			Get-WmiObject -Query $strQuery -Namespace $Namespace -ComputerName $Server | ForEach-Object {
				$strIP = $_.SMS_G_System_NETWORK_ADAPTER_CONFIGURATION.IPAddress
				$strMask = $_.SMS_G_System_NETWORK_ADAPTER_CONFIGURATION.IPSubnet
				if ($strIP -ne $null){
					$IPArray = $strIP.Split(",")
					$MaskArray = $strMask.Split(",")
					foreach ($instance in $IPArray){
						if ($instance.contains(".")){
							foreach ($MaskInstance in $MaskArray){
								if ($MaskInstance.contains(".")){
									$strMac = $_.SMS_G_System_NETWORK_ADAPTER_CONFIGURATION.MACAddress
									$strEditedMac = $strMac | Out-String
									$strEditedMac = $strEditedMac.replace(":","")
									$strEditedMac = $strEditedMac.Substring(0,12)
									& $wolPath $strEditedMac $instance $MaskInstance "12287"
									$CurrTime = Get-Date
									$CurrentTime = $CurrTime.ToLongTimeString()
									$LogBox.Text = $LogBox.Text + "$CurrentTime - $CompName - Sent packet to MAC: $strMac IP: $instance  Subnet: $MaskInstance `n"
									$LogScrollTo = $LogBox.Text.Length - 250
									$LogBox.Select($LogScrollTo,0)
									$LogBox.ScrollToCaret()
									$SentPacket = $true
								}
							}
						}
					}
				}
			}
			if ($SentPacket -eq $false) {
				$CurrTime = Get-Date
				$CurrentTime = $CurrTime.ToLongTimeString()
				$LogBox.Text = $LogBox.Text + "$CurrentTime - Could not find valid MAC for $CompName `n"
				$LogScrollTo = $LogBox.Text.Length - 250
				$LogBox.Select($LogScrollTo,0)
				$LogBox.ScrollToCaret()
			}
		}
		$CurrTime = Get-Date
		$CurrentTime = $CurrTime.ToLongTimeString()
		$LogBox.Text = $LogBox.Text + "$CurrentTime - Finished sending WOL packets`n"
		$LogScrollTo = $LogBox.Text.Length - 250
		$LogBox.Select($LogScrollTo,0)
		$LogBox.ScrollToCaret()
	}
	else {
		$CurrTime = Get-Date
		$CurrentTime = $CurrTime.ToLongTimeString()
		$LogBox.Text = $LogBox.Text + "$CurrentTime - User cancelled wake up`n"
		$LogScrollTo = $LogBox.Text.Length - 250
		$LogBox.Select($LogScrollTo,0)
		$LogBox.ScrollToCaret()
	}
}

$ResizeEnd=
{
<#
	Used in other forms...
	
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
	$System_Windows_Forms_DataGridViewTextBoxColumn_2 = New-Object System.Windows.Forms.DataGridViewTextBoxColumn
	$System_Windows_Forms_DataGridViewTextBoxColumn_2.HeaderText = "IP Address"
	$System_Windows_Forms_DataGridViewTextBoxColumn_2.Name = ""
	$System_Windows_Forms_DataGridViewTextBoxColumn_2.ReadOnly = $True
	$System_Windows_Forms_DataGridViewTextBoxColumn_2.AutoSizeMode = 6
	$SuccessView.Columns.Add($System_Windows_Forms_DataGridViewTextBoxColumn_2)|Out-Null
	$System_Windows_Forms_DataGridViewTextBoxColumn_3 = New-Object System.Windows.Forms.DataGridViewTextBoxColumn
	$System_Windows_Forms_DataGridViewTextBoxColumn_3.HeaderText = "Time"
	$System_Windows_Forms_DataGridViewTextBoxColumn_3.Name = ""
	$System_Windows_Forms_DataGridViewTextBoxColumn_3.ReadOnly = $True
	$System_Windows_Forms_DataGridViewTextBoxColumn_3.AutoSizeMode = 6
	$SuccessView.Columns.Add($System_Windows_Forms_DataGridViewTextBoxColumn_3)|Out-Null
	$System_Windows_Forms_DataGridViewTextBoxColumn_4 = New-Object System.Windows.Forms.DataGridViewTextBoxColumn
	$System_Windows_Forms_DataGridViewTextBoxColumn_4.HeaderText = "Bytes Sent"
	$System_Windows_Forms_DataGridViewTextBoxColumn_4.Name = ""
	$System_Windows_Forms_DataGridViewTextBoxColumn_4.ReadOnly = $True
	$System_Windows_Forms_DataGridViewTextBoxColumn_4.AutoSizeMode = 6
	$SuccessView.Columns.Add($System_Windows_Forms_DataGridViewTextBoxColumn_4)|Out-Null
	$System_Windows_Forms_DataGridViewTextBoxColumn_5 = New-Object System.Windows.Forms.DataGridViewTextBoxColumn
	$System_Windows_Forms_DataGridViewTextBoxColumn_5.HeaderText = "TTL"
	$System_Windows_Forms_DataGridViewTextBoxColumn_5.Name = ""
	$System_Windows_Forms_DataGridViewTextBoxColumn_5.ReadOnly = $True
	$System_Windows_Forms_DataGridViewTextBoxColumn_5.AutoSizeMode = 6
	$SuccessView.Columns.Add($System_Windows_Forms_DataGridViewTextBoxColumn_5)|Out-Null
	$System_Windows_Forms_DataGridViewTextBoxColumn_6 = New-Object System.Windows.Forms.DataGridViewTextBoxColumn
	$System_Windows_Forms_DataGridViewTextBoxColumn_6.AutoSizeMode = 6
	$System_Windows_Forms_DataGridViewTextBoxColumn_6.HeaderText = "Device Name"
	$System_Windows_Forms_DataGridViewTextBoxColumn_6.Name = ""
	$System_Windows_Forms_DataGridViewTextBoxColumn_6.ReadOnly = $True
	$UnSuccessView.Columns.Add($System_Windows_Forms_DataGridViewTextBoxColumn_6)|Out-Null
	$script:CancelAction = $false
	$CloseCancelBtn.Text = "Cancel"
	$ReRunBtn.Enabled = $false
	$NumSuccess = 0
	$NumUnsuccess = 0
	$count = 0
	$MaxJobs = 0
	$AddToMaxJobs = 0
	$ReallyAdd = 3
	$JobName = "Pinging_" + $strColID
	$strQuery = "select * from SMS_CM_RES_COLL_$ColID as Col inner join SMS_R_System on Col.ResourceID = SMS_R_System.ResourceID"
	Get-WmiObject -Query $strQuery -Namespace $Namespace -ComputerName $Server | ForEach-Object {
		[System.Windows.Forms.Application]::DoEvents()
		if ($script:CancelAction -eq $false){
			<#There is a bug with Start-Job that causes all jobs to complete before it removes any. 
			It only happens when it encouters a computer that is off
			If max jobs is set too high, this makes the script freeze for a long time.
			If max jobs is set too low, the script will pause a lot as it waits for jobs to complete
			So this function sets max jobs low at first, and then increases it hopefully after the bug happens.
			The max is set at 20, because after the bug happens, you shouldn't have more than 10 running at once.
			This only really shaves about 15-20 seconds off the script, no matter how many computers you ping.
			That could be a lot of time if you are only pinging 40 computers, not that much if you're pinging 4000.#>
			if ($AddToMaxJobs -eq 1) {
				$ReallyAdd++
				$AddToMaxJobs = 0
			}
			if ($ReallyAdd -eq 3 -and $MaxJobs -ne 20){
				$ReallyAdd = 0
				$MaxJobs = $MaxJobs + 10
			}
			$CompName = $_.SMS_R_System.ResourceNames[0]
			$CurrTime = Get-Date
			$CurrentTime = $CurrTime.ToLongTimeString()
			$LogText = "$CurrentTime - Starting ping of $CompName"
			$LogText = $LogText.replace("`n","")
			$LogBox.Text = $LogBox.Text + $LogText + "`n"
			$LogScrollTo = $LogBox.Text.Length - 250
			$LogBox.Select($LogScrollTo,0)
			$LogBox.ScrollToCaret()
			Start-Job -Name $JobName -ArgumentList $CompName -ScriptBlock {
				$CompName = $args
				$Error.Clear()
				$strOutput = "$CompName||"
				$count = 1
				$pingcount = 0
				#do {
					$pingcount++
					Test-connection -computername $CompName -count 1 | ForEach-Object {
						$StrOutput = $strOutput + $_.ProtocolAddress
						$StrOutput = $strOutput + "||" + $_.ReplySize
						$StrOutput = $strOutput + "||" + $_.ResponseTime
						$StrOutput = $strOutput + "||" + $_.ResponseTimeToLive + "||"
					}
				#} while ($pingcount -le $count)
				if ($Error[0]) {$strOutput = "$CompName||Off"}
				Write-Output $strOutput
			} | Out-Null
			Receive-Job -Name $JobName | ForEach-Object {
				[System.Windows.Forms.Application]::DoEvents()
				$count++
				$strOutput = $_
				$strOutput = $strOutput | Out-String
				$CurrTime = Get-Date
				$CurrentTime = $CurrTime.ToLongTimeString()
				if ($strOutput.contains("||Off")){
					$NumUnsuccess++
					$OutputArray = $strOutput.Split("||")
					$LogBox.Text = $LogBox.Text + "$CurrentTime - Error pinging " + $OutputArray[0] + "`n"
					$UnsuccessView.Rows.Add($OutputArray[0])
					$UnsuccessLbl.Text = "$NumUnsuccess Unsuccessful"
				}
				else {
					$OutputArray = $strOutput.Split("||")
					$SuccessView.Rows.Add($OutputArray[0],$OutputArray[2],$OutputArray[6] + "ms",$OutputArray[4],$OutputArray[8])
					$LogBox.Text = $LogBox.Text + "$CurrentTime - Received reply from " + $OutputArray[0] + "`n"
					$Numsuccess++
					$SuccessLbl.Text = "$NumSuccess Successful"
				}
				$LogScrollTo = $LogBox.Text.Length - 250
				$LogBox.Select($LogScrollTo,0)
				$LogBox.ScrollToCaret()
			}
			while (((get-job | where-object { $_.Name -like "$JobName" -and $_.State -eq "Running" }) | measure).Count -gt $MaxJobs -and $script:CancelAction -eq $false){
				[System.Windows.Forms.Application]::DoEvents()
				if ($script:CancelAction -eq $true){}
				else {
					$CurrTime = Get-Date
					$CurrentTime = $CurrTime.ToLongTimeString()
					$AddToMaxJobs = 1
					$LogBox.Text = $LogBox.Text + "$CurrentTime - Can only run $MaxJobs jobs at once, waiting on some to finish before continuing...`n"
					Start-Sleep -Seconds 1
					$LogScrollTo = $LogBox.Text.Length - 250
					$LogBox.Select($LogScrollTo,0)
					$LogBox.ScrollToCaret()
				}
			}
		}
	}
	while (((get-job | where-object { $_.Name -like "$JobName" -and $_.State -eq "Running" }) | measure).Count -gt 0 -and $script:CancelAction -eq $false){
		[System.Windows.Forms.Application]::DoEvents()
		if ($script:CancelAction -eq $true){}
		else {
			Start-Sleep -Seconds 1
			$CurrTime = Get-Date
			$CurrentTime = $CurrTime.ToLongTimeString()
			$LogBox.Text = $LogBox.Text + "$CurrentTime - Waiting on the last few jobs to finish...`n"
			$LogScrollTo = $LogBox.Text.Length - 250
			$LogBox.Select($LogScrollTo,0)
			$LogBox.ScrollToCaret()
		}
	}
	Receive-Job -Name $JobName | ForEach-Object {
		[System.Windows.Forms.Application]::DoEvents()
		$count++
		$strOutput = $_
		$strOutput = $strOutput | Out-String
		$CurrTime = Get-Date
		$CurrentTime = $CurrTime.ToLongTimeString()
		if ($strOutput.contains("||Off")){
			$NumUnsuccess++
			$OutputArray = $strOutput.Split("||")
			$LogBox.Text = $LogBox.Text + "$CurrentTime - Error pinging " + $OutputArray[0] + "`n"
			$UnsuccessView.Rows.Add($OutputArray[0])
			$UnsuccessLbl.Text = "$NumUnsuccess Unsuccessful"
		}
		else {
			$OutputArray = $strOutput.Split("||")
			$SuccessView.Rows.Add($OutputArray[0],$OutputArray[2],$OutputArray[6] + "ms",$OutputArray[4],$OutputArray[8])
			$LogBox.Text = $LogBox.Text + "$CurrentTime - Received reply from " + $OutputArray[0] + "`n"
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

$menuItem1 = New-Object System.Windows.Forms.ToolStripMenuItem -ArgumentList "Restart Selected Devices"
$SuccesscontextMenuStrip.Items.Add($menuItem1)
$menuItem1.add_Click($RestartDevices_Menu1)
$menuItem2 = New-Object System.Windows.Forms.ToolStripMenuItem -ArgumentList "Shutdown Selected Devices"
$SuccesscontextMenuStrip.Items.Add($menuItem2)
$menuItem2.add_Click($ShutdownDevices_Menu1)

$SuccessView.ContextMenuStrip = $SuccesscontextMenuStrip

$menuItem3 = New-Object System.Windows.Forms.ToolStripMenuItem -ArgumentList "WOL Selected Devices"
$UnSuccesscontextMenuStrip.Items.Add($menuItem3)
$menuItem3.add_Click($WOLDevices_Menu2)

$UnSuccessView.ContextMenuStrip = $UnSuccesscontextMenuStrip



#region Generated Form Code
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 557
$System_Drawing_Size.Width = 632
$ResultsForm.ClientSize = $System_Drawing_Size
$ResultsForm.DataBindings.DefaultDataSourceUpdateMode = 0
$ResultsForm.Name = "ResultsForm"
$ResultsForm.Text = "$FormName"

$ReRunBtn.Anchor = 10

$ReRunBtn.DataBindings.DefaultDataSourceUpdateMode = 0

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 461
$System_Drawing_Point.Y = 522
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
$System_Drawing_Point.Y = 420
$LogBox.Location = $System_Drawing_Point
$LogBox.Name = "LogBox"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 96
$System_Drawing_Size.Width = 605
$LogBox.Size = $System_Drawing_Size
$LogBox.TabIndex = 8
$LogBox.Text = ""

$ResultsForm.Controls.Add($LogBox)

$UnsuccessLbl.Anchor = 9
$UnsuccessLbl.DataBindings.DefaultDataSourceUpdateMode = 0

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 431
$System_Drawing_Point.Y = 55
$UnsuccessLbl.Location = $System_Drawing_Point
$UnsuccessLbl.Name = "UnsuccessLbl"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 23
$System_Drawing_Size.Width = 186
$UnsuccessLbl.Size = $System_Drawing_Size
$UnsuccessLbl.TabIndex = 7
$UnsuccessLbl.Text = "$NumUnSuccess Unsuccessful"
$UnsuccessLbl.TextAlign = 32

$ResultsForm.Controls.Add($UnsuccessLbl)

$UnsuccessView.AllowUserToAddRows = $False
$UnsuccessView.AllowUserToDeleteRows = $False
$UnsuccessView.AllowUserToResizeRows = $False
$UnsuccessView.SelectionMode = 1
$UnsuccessView.Anchor = 11
$UnsuccessView.ClipboardCopyMode = 2
$UnsuccessView.ColumnHeadersHeightSizeMode = 1
$UnsuccessView.DataBindings.DefaultDataSourceUpdateMode = 0
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 431
$System_Drawing_Point.Y = 81
$UnsuccessView.Location = $System_Drawing_Point
$UnsuccessView.Name = "UnsuccessView"
$UnsuccessView.ReadOnly = $True
$UnsuccessView.RowHeadersVisible = $False
$UnsuccessView.RowHeadersWidthSizeMode = 1
$UnsuccessView.RowTemplate.Height = 24
$UnsuccessView.ShowCellErrors = $False
$UnsuccessView.ShowRowErrors = $False
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 333
$System_Drawing_Size.Width = 186
$UnsuccessView.Size = $System_Drawing_Size
$UnsuccessView.TabIndex = 6

$ResultsForm.Controls.Add($UnsuccessView)

$CloseCancelBtn.Anchor = 10

$CloseCancelBtn.DataBindings.DefaultDataSourceUpdateMode = 0

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 542
$System_Drawing_Point.Y = 522
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
$System_Drawing_Point.Y = 522
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
$SuccessView.SelectionMode = 1
$SuccessView.Anchor = 15
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
$SuccessView.ShowCellErrors = $False
$SuccessView.ShowRowErrors = $False
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 333
$System_Drawing_Size.Width = 400
$SuccessView.Size = $System_Drawing_Size
$SuccessView.TabIndex = 3

$ResultsForm.Controls.Add($SuccessView)

$SuccessLbl.Anchor = 13
$SuccessLbl.DataBindings.DefaultDataSourceUpdateMode = 0

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 12
$System_Drawing_Point.Y = 55
$SuccessLbl.Location = $System_Drawing_Point
$SuccessLbl.Name = "SuccessLbl"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 23
$System_Drawing_Size.Width = 400
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
$System_Drawing_Size.Width = 605
$ActionNameLbl.Size = $System_Drawing_Size
$ActionNameLbl.TabIndex = 1
$ActionNameLbl.Text = "$StrAction"
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
$System_Drawing_Size.Width = 605
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

GenerateForm