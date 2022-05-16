<#
Written by Ryan Ephgrave for ConfigMgr 2012 Right Click Tools
http://psrightclicktools.codeplex.com/
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
	$Path = "\\" + $CompName + "\c$"
	explorer $Path
}
else {$Popup.Popup("Error, can not ping $CompName",0,"Error",16)}