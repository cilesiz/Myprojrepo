<#
Written by Ryan Ephgrave for ConfigMgr 2012 PS Right Click Tools
http://psrightclicktools.codeplex.com/
#>

$ResourceID = $args[0]
$Server = $args[1]
$Namespace = $args[2]

$strQuery = "Select ResourceID,ResourceNames from SMS_R_System where ResourceID='$ResourceID'"
Get-WmiObject -Query $strQuery -Namespace $Namespace -ComputerName $Server | ForEach-Object {$CompName = $_.ResourceNames[0]}

$Popup = new-object -comobject wscript.shell

$PopupAnswer = $Popup.popup("Do you want to repair the client on $CompName",0,"Are you sure?",1)
if ($PopupAnswer -eq 1) {
	If (test-connection -computername $CompName -count 1 -quiet){
		$Error.Clear()
		$WMIPath = "\\" + $CompName + "\root\ccm:SMS_Client"
		$SMSwmi = [wmiclass] $WMIPath
		[Void]$SMSwmi.RepairClient()
		if ($Error[0]) {$Popup.popup("Error repairing client on $CompName `n $Error",0,"Error",16)}
		else {$Popup.popup("Successfully repaired the client on $CompName",0,"Successful",0)}
	}
	else {$Popup.popup("Can not ping $CompName",0,"Error",16)}
}