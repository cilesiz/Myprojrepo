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
$Popup = new-object -comobject wscript.shell

$PacketsToSend = 2
$strAction = "WOL Collection"
$FormName = "WOL $ColName"
$GetDirectory = $MyInvocation.MyCommand.path
$Directory = Split-Path $GetDirectory

function GenerateForm {

<#
Variables:

$FormName = Form Name
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
#endregion Generated Form Objects

$ReRunBtn_OnClick= 
{
	$ArgList = @()
	$ArgList += @("`"$Directory\SilentOpenPS.vbs`"")
	$ArgList += @("`"$Directory\Collection - WOL.ps1`"")
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
	$System_Drawing_Size = New-Object System.Drawing.Size
	$System_Drawing_Size.Height = 555
	$System_Drawing_Size.Width = 675
	$ResultsForm.ClientSize = $System_Drawing_Size
	$System_Windows_Forms_DataGridViewTextBoxColumn_1 = New-Object System.Windows.Forms.DataGridViewTextBoxColumn
	$System_Windows_Forms_DataGridViewTextBoxColumn_1.AutoSizeMode = 6
	$System_Windows_Forms_DataGridViewTextBoxColumn_1.HeaderText = "Device Name"
	$System_Windows_Forms_DataGridViewTextBoxColumn_1.Name = ""
	$System_Windows_Forms_DataGridViewTextBoxColumn_1.ReadOnly = $True
	$SuccessView.Columns.Add($System_Windows_Forms_DataGridViewTextBoxColumn_1)|Out-Null
	$System_Windows_Forms_DataGridViewTextBoxColumn_2 = New-Object System.Windows.Forms.DataGridViewTextBoxColumn
	$System_Windows_Forms_DataGridViewTextBoxColumn_2.HeaderText = "MAC Address"
	$System_Windows_Forms_DataGridViewTextBoxColumn_2.Name = ""
	$System_Windows_Forms_DataGridViewTextBoxColumn_2.ReadOnly = $True
	$System_Windows_Forms_DataGridViewTextBoxColumn_2.AutoSizeMode = 6
	$SuccessView.Columns.Add($System_Windows_Forms_DataGridViewTextBoxColumn_2)|Out-Null
	$System_Windows_Forms_DataGridViewTextBoxColumn_3 = New-Object System.Windows.Forms.DataGridViewTextBoxColumn
	$System_Windows_Forms_DataGridViewTextBoxColumn_3.HeaderText = "IP Address"
	$System_Windows_Forms_DataGridViewTextBoxColumn_3.Name = ""
	$System_Windows_Forms_DataGridViewTextBoxColumn_3.ReadOnly = $True
	$System_Windows_Forms_DataGridViewTextBoxColumn_3.AutoSizeMode = 6
	$SuccessView.Columns.Add($System_Windows_Forms_DataGridViewTextBoxColumn_3)|Out-Null
	$System_Windows_Forms_DataGridViewTextBoxColumn_4 = New-Object System.Windows.Forms.DataGridViewTextBoxColumn
	$System_Windows_Forms_DataGridViewTextBoxColumn_4.HeaderText = "Subnet Mask"
	$System_Windows_Forms_DataGridViewTextBoxColumn_4.Name = ""
	$System_Windows_Forms_DataGridViewTextBoxColumn_4.ReadOnly = $True
	$System_Windows_Forms_DataGridViewTextBoxColumn_4.AutoSizeMode = 6
	$SuccessView.Columns.Add($System_Windows_Forms_DataGridViewTextBoxColumn_4)|Out-Null
	$System_Windows_Forms_DataGridViewTextBoxColumn_5 = New-Object System.Windows.Forms.DataGridViewTextBoxColumn
	$System_Windows_Forms_DataGridViewTextBoxColumn_5.HeaderText = "Port Sent On"
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
	$count = 0
	$SuccessCount = 0
	$UnsuccessfulCount = 0
	$PacketSentCount = 0
	$wolpath = "$Directory\wolcmd.exe"
	$SentPacketArray = @()
	$script:CancelAction = $false
	$CloseCancelBtn.Text = "Cancel"
	$ReRunBtn.Enabled = $false
	$strQuery = "select * from SMS_CM_RES_COLL_$ColID As Col join SMS_G_System_NETWORK_ADAPTER_CONFIGURATION as Net on Col.ResourceID = Net.ResourceID where Net.IPAddress IS NOT NULL"
	Get-WMIObject -Query $strQuery -Namespace $Namespace -ComputerName $Server | ForEach-Object {
		$CompName = $_.Col.Name
		$MAC = $_.Net.MACAddress
		$IP = $_.Net.IPAddress
		$SubnetMask = $_.Net.IPSubnet
		$IPArray = $IP.Split(",")
		$MaskArray = $SubnetMask.Split(",")
		foreach ($instance in $IPArray){
			if ($instance.contains(".")){
				foreach ($MaskInstance in $MaskArray){
					if ($MaskInstance.contains(".")){
						$Error.Clear()
						$strEditedMac = $MAC | Out-String
						$strEditedMac = $strEditedMac.replace(":","")
						$strEditedMac = $strEditedMac.Substring(0,12)
						Do {
						& $wolPath $strEditedMac $instance $MaskInstance "12287"
						$PacketSentCount++
						} while ($PacketSentCount -lt $PacketsToSend)
						if ($Error[0]) {
							$CurrTime = Get-Date
							$CurrentTime = $CurrTime.ToLongTimeString()
							$LogBox.Text = $LogBox.Text + "$CurrentTime - $CompName - Error sending packet to MAC: $Mac IP: $instance  Subnet: $MaskInstance `n"
							$LogScrollTo = $LogBox.Text.Length - 250
							$LogBox.Select($LogScrollTo,0)
							$LogBox.ScrollToCaret()
						}
						else {
							$CurrTime = Get-Date
							$CurrentTime = $CurrTime.ToLongTimeString()
							$LogBox.Text = $LogBox.Text + "$CurrentTime - $CompName - Sent packet to MAC: $Mac IP: $instance  Subnet: $MaskInstance `n"
							$LogScrollTo = $LogBox.Text.Length - 250
							$LogBox.Select($LogScrollTo,0)
							$LogBox.ScrollToCaret()
							if ($SentPacketArray -inotcontains $CompName) {
								$SuccessCount++
								$SuccessLbl.Text = "Successfully sent WOL magic packet to $SuccessCount devices"
								$SentPacketArray += @($CompName)
							}
							$SuccessView.rows.add($CompName,$MAC,$instance,$MaskInstance,"12287")
						}
					}
				}
			}
		}
	}
	$CurrTime = Get-Date
	$CurrentTime = $CurrTime.ToLongTimeString()
	$LogBox.Text = $LogBox.Text + "$CurrentTime - Finished sending packets. Checking to see if any computers were missed `n"
	$LogScrollTo = $LogBox.Text.Length - 250
	$LogBox.Select($LogScrollTo,0)
	$LogBox.ScrollToCaret()
	$strQuery = "select Name from SMS_CM_RES_COLL_$ColID"
	Get-WMIObject -Query $strQuery -Namespace $Namespace -ComputerName $Server | ForEach-Object {
		if ($SentPacketArray -inotcontains $_.Name) {
			$CompName = $_.Name
			$CurrTime = Get-Date
			$CurrentTime = $CurrTime.ToLongTimeString()
			$LogBox.Text = $LogBox.Text + "$CurrentTime - Did not send WOL packet to $CompName `n"
			$LogScrollTo = $LogBox.Text.Length - 250
			$LogBox.Select($LogScrollTo,0)
			$LogBox.ScrollToCaret()
			$UnsuccessfulCount++
			$UnsuccessLbl.Text = "$UnsuccessfulCount Unsuccessful"
			$UnsuccessView.Rows.Add($CompName)
		}
	}
	$UnsuccessLbl.Text = "$UnsuccessfulCount Unsuccessful"
	$CurrTime = Get-Date
	$CurrentTime = $CurrTime.ToLongTimeString()
	$LogBox.Text = $LogBox.Text + "$CurrentTime - Finished! `n"
	$LogScrollTo = $LogBox.Text.Length - 250
	$LogBox.Select($LogScrollTo,0)
	$LogBox.ScrollToCaret()
	$ReRunBtn.Enabled = $true
	$CloseCancelBtn.Text = "Close"
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

$UnsuccessLbl.Anchor = 9
$UnsuccessLbl.DataBindings.DefaultDataSourceUpdateMode = 0

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 366
$System_Drawing_Point.Y = 55
$UnsuccessLbl.Location = $System_Drawing_Point
$UnsuccessLbl.Name = "UnsuccessLbl"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 23
$System_Drawing_Size.Width = 150
$UnsuccessLbl.Size = $System_Drawing_Size
$UnsuccessLbl.TabIndex = 7
$UnsuccessLbl.Text = "$NumUnSuccess Unsuccessful"
$UnsuccessLbl.TextAlign = 32

$ResultsForm.Controls.Add($UnsuccessLbl)

$UnsuccessView.AllowUserToAddRows = $False
$UnsuccessView.AllowUserToDeleteRows = $False
$UnsuccessView.AllowUserToResizeRows = $False
$UnsuccessView.Anchor = 11
$UnsuccessView.ClipboardCopyMode = 2
$UnsuccessView.ColumnHeadersHeightSizeMode = 1
$UnsuccessView.DataBindings.DefaultDataSourceUpdateMode = 0
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 366
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
$System_Drawing_Size.Width = 150
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
$SuccessView.SelectionMode = 0
$SuccessView.ShowCellErrors = $False
$SuccessView.ShowRowErrors = $False
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 331
$System_Drawing_Size.Width = 335
$SuccessView.Size = $System_Drawing_Size
$SuccessView.TabIndex = 3
$SuccessView.add_SelectionChanged($ViewSelection_Changed)

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
$System_Drawing_Size.Width = 335
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

GenerateForm