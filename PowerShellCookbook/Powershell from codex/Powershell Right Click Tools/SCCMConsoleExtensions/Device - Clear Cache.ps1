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
	$PopupAnswer = $Popup.Popup("Do you want to clear the cache of $CompName",0,"Are you sure?",1)
	if ($PopupAnswer -eq 1){
		Get-WmiObject -ComputerName $CompName -Class CacheInfoEx -Namespace root\ccm\softmgmtagent | ForEach-Object {
			$CachePath = $_.Location
			$CachePath = $CachePath.replace(":","$")
			$CachePath = "\\$CompName\$CachePath"
			Remove-Item $CachePath -Recurse -Force
			$_ | Remove-WmiObject
		}
		if ($Error[0]){$Popup.Popup("Error clearing cache on $CompName",0,"Error",16)}
		else {$Popup.Popup("Successfully cleared the cache on $CompName",0,"Successful",0)}
	}
}
else {$Popup.Popup("Error, cannot ping $CompName",0,"Error",16)}