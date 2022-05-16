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
	Get-WmiObject -ComputerName $CompName -Class Win32_OperatingSystem | ForEach-Object {$WindowsDirectory = $_.WindowsDirectory}
	$RemoteCompDirPath = "\\" + $CompName + "\C$"
	$WindowsDirectory = $WindowsDirectory.replace("C:",$RemoteCompDirPath)
	$TestPath1 = $WindowsDirectory + "\CCM\Logs"
	$TestPath2 = $WindowsDirectory + "\System32\CCM\Logs"
	$TestPath3 = $WindowsDirectory + "\syswow64\CCM\Logs"
	if (Test-Path $TestPath1){$CCMLogs = $TestPath1}
	elseif (Test-Path $TestPath2){$CCMLogs = $TestPath2}
	elseif (Test-Path $TestPath3){$CCMLogs = $TestPath3}
	else {
		$Popup.Popup("Error, could not find client log folder on $CompName",0,"Error",16)
		break
	}
	& explorer $CCMLogs
}
else {$Popup.Popup("Error, can not ping $CompName",0,"Error",16)}