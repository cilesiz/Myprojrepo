<#
Written by Ryan Ephgrave for ConfigMgr 2012 Right Click Tools
http://psrightclicktools.codeplex.com/
#>

$CompName = $args[0]
$ResourceID = $args[1]
$strServer = $args[2]
$strNamespace = $args[3]

$GetDirectory = $MyInvocation.MyCommand.path
$Directory = Split-Path $GetDirectory

$wolPath = "$Directory\wolcmd.exe"
$SentMsg = $null
$Popup = New-Object -ComObject wscript.shell

$strQuery = "Select * from SMS_G_System_NETWORK_ADAPTER_CONFIGURATION where ResourceID='$ResourceID'"
Get-WmiObject -Query $strQuery -Namespace $strNamespace -ComputerName $strServer | ForEach-Object {
	$strIP = $_.IPAddress
	$strMask = $_.IPSubnet
	if ($strIP -ne $null){
		$IPArray = $strIP.Split(",")
		$MaskArray = $strMask.Split(",")
		foreach ($instance in $IPArray){
			if ($instance.contains(".")){
				foreach ($MaskInstance in $MaskArray){
					if ($MaskInstance.contains(".")){
						$strMac = $_.MACAddress
						$strMac = $strMac | Out-String
						$strMac = $strMac.replace(":","")
						$strMac = $strMac.Substring(0,12)
						& $wolPath $strMac $instance $MaskInstance "12287"
						$strMac = $_.MACAddress
						$SentMsg = $SentMsg + "Sent packet to MAC: $strMac   IP: $instance  Subnet: $MaskInstance `n"}}}}}}
if ($SentMsg -ne $null){$Popup.popup($Sentmsg,0,"Sent Packets!",0)}
else {
$msg = "Could not find enough information to send packets..."
$PopupAnswer = $Popup.popup($msg,0,"Did not send packets",0)}