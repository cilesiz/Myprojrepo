<#
Title: DeleteOldIISLogFiles.ps1
Description: Deletes IIS LogFiles older than X days from all of the W3SVC Logfiles folder on remote systems
Comments: None
Author: Daniel Sarfati
Original Date: April 19 2013
Modified Date: June 10 2013
Version: 1.1
#>

#Sets the number of days files to keep
$Days=7

$ComputerList = @("computer1","computer2")
#or, for just one computer
# $ComputerList = @("computer1")

Function Ping($computername)
{
	$query = "select * from win32_pingstatus where address = '" + $computername + "'"
	$wmi = get-wmiobject -query $query
	if ($($wmi.statuscode) -eq $null)
		{
		$rtnvalue = $($wmi.PrimaryAddressResolutionStatus)
		}
	else {$rtnvalue = $($wmi.statuscode)}
	if ( $rtnvalue -eq 0 ) {$true}
	else {$false}
	
}

Function WMIConnectionTest($computername)
{
	$wmiClass = "Win32_OperatingSystem"
	if ((Get-WmiObject -ComputerName $computerName win32_operatingsystem -ErrorAction silentlycontinue)) 
		{ return $true } 
	else { return $false }	
}

Function GetWebLogFilesLocation($ComputerName)
{
	$Location = [adsi]"IIS://$ComputerName/w3svc" | select LogFileDirectory | %{$_.LogFileDirectory}
	$LogFileFolder = $Location -replace ":", "$"
	return "\\$Computername\$LogFileFolder"
}

Foreach ($Computername in $ComputerList)
{
if (Ping($ComputerName) -eq $true -and if (WMIConnectionTest($ComputerName) -eq $true))
{
	$a = GetWebLogFilesLocation($computername)
    $W3SVCList = gci $a | where {$_.mode -match "d"}

    Foreach ($LogFilesFolder in $W3SVCList)
    {
	Dir "$a\$LogFilesFolder\*.log" | ?{$_.LastWriteTime -lt (Get-Date).AddDays(-($Days))} | del
    }
}
}
<#
$Location = [adsi]"IIS://$ComputerName/w3svc" | select LogFileDirectory | %{$_.LogFileDirectory} 
#>
	