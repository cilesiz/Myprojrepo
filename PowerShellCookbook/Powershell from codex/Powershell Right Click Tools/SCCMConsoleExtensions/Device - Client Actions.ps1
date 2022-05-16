<#
Written by Ryan Ephgrave for ConfigMgr 2012 PS Right Click Tools
http://psrightclicktools.codeplex.com/
#>

#Get Arguments
$ResourceID = $args[0]
$strAction = $args[1]
$strActionName = $args[2]
$Server = $args[3]
$Namespace = $args[4]

$strQuery = "Select ResourceID,ResourceNames from SMS_R_System where ResourceID='$ResourceID'"
Get-WmiObject -Query $strQuery -Namespace $Namespace -ComputerName $Server | ForEach-Object {$CompName = $_.ResourceNames[0]}

$objpopup = new-object -comobject wscript.shell

If (test-connection -computername $CompName -count 1 -quiet){
	$Error.Clear()
	$WMIPath = "\\" + $CompName + "\root\ccm:SMS_Client"
	$SMSwmi = [wmiclass] $WMIPath
	[Void]$SMSwmi.TriggerSchedule($strAction)
	if($Error[0]){$actualpopup = $objpopup.popup(“Error triggering $strActionName on $CompName“,0,”Results”,16)}
	else{$actualpopup = $objpopup.popup(“Successfully triggered $strActionName on $CompName“,0,”Results”,0)}
}
else {$actualpopup = $objpopup.popup(“$CompName is not on“,0,”Results”,16)}