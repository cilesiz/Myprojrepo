﻿<#
Written by Ryan Ephgrave for ConfigMgr 2012 Right Click Tools
http://psrightclicktools.codeplex.com/
GUI Generated By: SAPIEN Technologies PrimalForms (Community Edition) v1.0.10.0
#>

$ResourceID = $args[0]
$Server = $args[1]
$Namespace = $args[2]

$strQuery = "Select ResourceID,ResourceNames from SMS_R_System where ResourceID='$ResourceID'"
Get-WmiObject -Query $strQuery -Namespace $Namespace -ComputerName $Server | ForEach-Object {$CompName = $_.ResourceNames[0]}

$GetDirectory = $MyInvocation.MyCommand.path
$Directory = Split-Path $GetDirectory

$Popup = new-object -comobject wscript.shell
if (Test-Connection -computername $CompName -count 1 -quiet){
	& shutdown.exe /m $CompName /a
	$ShutdownExitCode = $LastExitCode
	if ($ShutdownExitCode -eq 1116) {$Popup.popup(“No pending shutdown on $CompName“,0,”Results”,0)}
	elseif ($ShutdownExitCode -eq 0) {$Popup.popup(“Successfully cancelled the pending shutdown $CompName“,0,”Results”,0)}
	else {$Popup.popup(“Error - Can not cancel pending shutdown on $CompName“,0,”Results”,16)}
}
else {$Popup.popup(“Error - Can not ping $CompName“,0,”Results”,16)}