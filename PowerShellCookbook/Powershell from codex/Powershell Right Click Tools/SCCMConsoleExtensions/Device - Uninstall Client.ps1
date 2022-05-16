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
	$PopupAnswer = $Popup.Popup("Do you want to uninstall the client on $CompName",0,"Are you sure?",1)
	if ($PopupAnswer -eq 1){
		Get-WmiObject -ComputerName $CompName -Class CCM_InstalledProduct -Namespace root\ccm | ForEach-Object {$ProductCode = $_.ProductCode}
		$UninstallCommand = "msiexec /x `"$ProductCode`" REBOOT=ReallySuppress /q"
		$WMIPath = "\\" + $CompName + "\root\cimv2:Win32_Process"
		$StartProcess = [wmiclass] $WMIPath
		$ProcError = $StartProcess.Create($UninstallCommand,$null,$null)
		$ProcError = $ProcError.ReturnValue
		if ($ProcError -eq 0){$Popup.Popup("Successfully triggered uninstall on $CompName",0,"Successful",0)}
		else {$Popup.Popup("Error, could not trigger uninstall on $CompName",0,"Error",16)}
	}
}
else {$Popup.Popup("Error, cannot ping $CompName",0,"Error",16)}