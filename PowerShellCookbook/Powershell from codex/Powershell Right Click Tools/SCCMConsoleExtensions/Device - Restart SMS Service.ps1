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
$PopupAnswer = $Popup.popup("Do you want to restart the SMS Agent Host Service on $CompName",0,"Are you sure?",1)
if ($PopupAnswer -eq 1) {
	If (test-connection -computername $CompName -count 1 -quiet){
		$Error.Clear()
		$strQuery = "select Name,State from Win32_Service where Name='CcmExec'"
		$colService = Get-WmiObject -Query $strQuery -ComputerName $CompName -Namespace root\CIMV2
		foreach ($instance in $colService){
		$instance.StopService() | Out-Null
			do{
				Start-Sleep -Seconds 1
				$colService = Get-WmiObject -Query $strQuery -ComputerName $CompName -Namespace root\CIMV2
				foreach ($instance in $colService){$strState = $instance.State}
				$count++
			} while ($strState -ne "Stopped" -or $count -eq 60)
		$instance.StartService() | Out-Null
		}
		if ($Error[0]){$Popup.popup(“Error restarting service on $CompName“,0,”Error”,16)}
		else {$Popup.popup(“Successfully restarted the service on $CompName“,0,”Successful”,0)}
	}
	else {$Popup.popup(“$CompName is not on“,0,”Error”,16)}
}